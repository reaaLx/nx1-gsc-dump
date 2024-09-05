#include maps\_utility;
#include common_scripts\utility;

SUIT_SHIELD_MAX_HEALTH = 150;
SUIT_SHIELD_DAMAGE_DIST_SHIELD = 1;
SUIT_SHIELD_DAMAGE_DIST_HEALTH = 0;
SUIT_SHIELD_DEATH_TIME = 4;
SUIT_SHIELD_PATCH_DURATION = 1.1;//lame sauce. 
SUIT_SHIELD_PATCH_WAIT = 1.4;//how long to wait in the middle of the patch duration to actually dole out the health.
SUIT_SHIELD_WAIT_UNTIL_INJECTION = 1.0;
SUIT_PATCH_PROMPT_HEALTH_PERC = 0.25;
init_suit_shield()
{
	PreCacheItem("nx_suitshield");

	// Added test stuff & checks to stop changes from breaking
	if( !isdefined( level.suit_shield ) )
		level.suit_shield = SUIT_SHIELD_MAX_HEALTH;
	if( !isdefined( level.suit_dist_shield ) )
		level.suit_dist_shield = SUIT_SHIELD_DAMAGE_DIST_SHIELD;
	if( !isdefined( level.suit_dist_health ) )
		level.suit_dist_health = SUIT_SHIELD_DAMAGE_DIST_HEALTH;
	if( !isdefined( level.env_death ) )
		level.env_death = true;
	if( !isdefined( level.env_death_time ) )
		level.env_death_time = SUIT_SHIELD_DEATH_TIME;
	
	level._player EnableSuitShield( true );
	level._player SetSuitShieldHealth( level.suit_shield );
	
	SetSavedDvar( "player_suitshield_max_health", level.suit_shield);
	SetSavedDvar( "suit_shield_suit_damage_distribution", level.suit_dist_shield);
	SetSavedDvar( "suit_shield_player_damage_distribution", level.suit_dist_health);
	SetDvar( "suit_shield_death_time", level.env_death_time);
	SetDvar( "suit_shield_patch_duration", SUIT_SHIELD_PATCH_DURATION);
	SetDvar( "suit_shield_patch_wait", SUIT_SHIELD_PATCH_WAIT);
	SetDvar( "suit_shield_wait_until_injection", SUIT_SHIELD_WAIT_UNTIL_INJECTION);
	
	maps\_utility::add_hint_string( "patch", &"LUNAR_HUD_PATCH_HINT", ::should_break_patch_hint );
	
	level._player thread monitor_suit_health();
}

monitor_suit_health()
{
	sfx_variable = 0;

	while ( true )
	{
		self waittill( "suitshield", damage, attacker, direction, point, type, modelName, tagName, partName, dflags, weaponName );
		
		self FlashSuitShieldHealthMeter();
		
		//only kill the player when they're in a vacuum
		if( GetDvar("environment_pressurized") == "0" )
		{
			//check if the suit is toast. If so spawn a monitor function to kill the player and what not in the right conditions.
			if( self GetSuitShieldHealth() <= 0)
			{
				self thread monitor_suit_vacuum();
				if( sfx_variable == 0 )
				{
					sfx_variable = 1;
					//level._player playsound( "lunar_low_health" );
				}
			}
			else
			{

				sfx_variable = 0;	

			}
		}
		
		//regardless of if pressurized, when the suit is damaged down to this constant percent threshold, give the prompt.
		if( self GetSuitShieldHealth() / Float(GetDvar("player_suitshield_max_health")) <= SUIT_PATCH_PROMPT_HEALTH_PERC )
		{
			if( level.env_death )
			{
				self thread maps\_utility::display_hint( "patch" );
				thread eagle_reminder_vo();
			}
		}
	}
}


suit_health_regen()
{
	level._player.hit_again = true;
	level._player thread suit_health_regen_proc();
	
	while( true )
	{
		self waittill( "suitshield", damage );
		level._player.hit_again = true;

		iprintln( "I just took damage!" );
	}
}

suit_health_regen_proc()
{
	player = level._player;
	hit_timer = 0;

	while( true )
	{
		// increment timer
		if( player.hit_again )
		{
			player.hit_again = false;
			hit_timer = 0;
		}
		else
		{
			hit_timer += .05;
			
			// check if enough time went by
			if( hit_timer > 6)
			{
				if( player GetSuitShieldHealth() < level.suit_shield )
					self suit_shield_smooth_give_health();
				else
					self waittill( "suitshield", damage );
			}
		}

		wait( .05 );
	}
}

// Eagle VO to remind the player to patch their suit
eagle_reminder_vo()
{
	// Stop any already-running instances of the function. This will also reset the timer.
	level notify ("already_nagging_about_patching");
	waittillframeend;
	level endon ("already_nagging_about_patching");

	// Stop nagging them after they repair their suit
	level._player endon ("suit_repaired");

	// Initial delay before a line is said.
	delay = 5;
	reminders = [];
	unused_reminders = [];

	// define all the possible lines
	reminders [ reminders.size] = "moon_eag_patch_01";
	reminders [ reminders.size] = "moon_eag_patch_02";
	reminders [ reminders.size] = "moon_eag_patch_03";
	reminders [ reminders.size] = "moon_eag_int_05";
	reminders [ reminders.size] = "moon_eag_ext_patch";

	// Wait here if the player doesn't have any patch kits.
	while ( level._player GetAmmoCount( "nx_suitshield" ) == 0 )
	{
		wait .5;
	}

	// If the player actually has at least one patch kit
	while ( 1 )
	{	
		// Wait before starting
		wait ( delay );
		
		// reset line array if it's empty
		if ( unused_reminders.size == 0 )
			unused_reminders = reminders;

		// Choose a line randomly
		line = random( unused_reminders );

		/* Debug stuff
		iprintln ( "delay: " + delay);
		iprintln ( "line: " + line);
		iprintln ( "size: " + unused_reminders.size);
		*/	

		// Suit health gets reset on checkpoint load. This is here to stop the nag if that occurs.
		// Basically, if their health magically went over SUIT_PATCH_PROMPT_HEALTH_PERC without them repairing, it stops this nag
		// Or: If the player is using the suitshield at this very moment.
		if( (level._player GetSuitShieldHealth() / Float(GetDvar("player_suitshield_max_health")) >= SUIT_PATCH_PROMPT_HEALTH_PERC) || (level._player GetCurrentWeapon() == "nx_suitshield") )
		{
			// Don't want to hijack "suit_repaired" for this, even though this makes less semantic sense
			// Here it means, stop reminding them, as they are in the middle of patching.
			level notify ("already_nagging_about_patching");
		}
		
		// Play it if not currently saying anything else.
		if( (IsDefined( level._scr_radio[ line ] )) && (!flag ("vignette_playing")) )
		{
			thread radio_dialogue_safe ( line );
		}

		// remove the line just played from the array
		unused_reminders = array_remove( unused_reminders, line );
		unused_reminders = array_removeUndefined( unused_reminders );

		// Wait a bit longer every time.
		delay ++;
	}
	
}


//in here we do shit like kill the player and throw up effects that the player is suffocating. 
monitor_suit_vacuum()
{
	self endon("death");
	self endon("suit_repaired");
	
	self childthread camera_shake( 0.3, 2.0 );
	self childthread blur_pulse( 4.0, 0.5, 1.0, 0.0 );

	if ( !IsGodMode( self ) )
	{
		self thread monitor_suit_vacuum_kill_player();
	}
	
	self thread monitor_suit_leave_vacuum();
}

//the suit was repaired, remove the effects set in monitor_suit_vacuum
monitor_suit_leave_vacuum()
{
	self endon("death");
	self waittill("suit_repaired");
	self childthread blur_pulse( 0.0, 2.0, 0.5 );
}

monitor_suit_vacuum_kill_player()
{
	self endon("death");
	self endon("suit_repaired");

	wait GetDvarFloat("suit_shield_death_time");
	IPrintLn( "suit_shield_death_time UP!" );

	// If the player has started patching already, give him a little extra time before death.
	if ( IsDefined( self._suit_repair_started ) )
	{
		time_since_start_of_repair = 0.001 * ( GetTime() - self._suit_repair_started );
		if ( time_since_start_of_repair < GetDvarFloat( "suit_shield_patch_wait" ) + 0.5 )
		{
			IPrintLn( "Granting extension!" );
			wait GetDvarFloat( "suit_shield_patch_wait" );
		}
	}
	
	if( self GetSuitShieldHealth() <= 0) //if they're respawned because of a death, and their health is refilled.
	{
		//if this script hasn't been killed by this point by a suit_repair notify, kill the player. It's like a time bomb!
		//might want to set the death quote here about patching so the player learns from their mistakes.
		// KenM - Done. Might be good to get some better "dying from vacuum" effects in here too.
		SetDvar( "ui_deadquote", "NX_LUNAR_FAIL_DID_NOT_PATCH" );
		level._player DisableWeapons();
		level._player setstance( "prone" );
		missionFailedWrapper();
	}
}

suit_shield_give_patch_tool( is_proto )
{
	if( !isdefined( is_proto ) )
		is_proto = false;
	
	self GiveWeapon( "nx_suitshield"  );
	self GiveStartAmmo( "nx_suitshield"  );
	
	self SetActionSlot( 4, "weapon", "nx_suitshield" );
	if( is_proto )
		self SetWeaponAmmoClip( "nx_suitshield", self GetWeaponAmmoClip( "nx_suitshield" ) - 4 );
	
	self thread suit_shield_use_watch();
	self thread suit_shield_disable_watch();
}

suit_shield_remove_patch_tool()
{
	self SetActionSlot( 4, "" );
	self SetWeaponHudIconOverride( "actionslot4", "none" );
	self TakeWeapon( "nx_suitshield" );
	
	self notify("remove_nx_suitshield");
}

suit_shield_use_watch()
{
	self endon("death");
	self endon("remove_nx_suitshield");
	while( true )
	{
		self waittill( "weapon_change", new_weapon, old_weapon);
		
		if ( 0 == self GetAmmoCount( "nx_suitshield" ) && !IsGodMode( self ) )
		{
			continue;
		}
			
		if( new_weapon == "nx_suitshield" )
		{
			self DisableWeaponSwitch();
			self._suit_repair_started = GetTime();
			
			self thread suit_shield_smooth_give_health();
			wait Float(GetDvar("suit_shield_patch_wait"));
			
			self SetWeaponAmmoClip( "nx_suitshield", self GetWeaponAmmoClip( "nx_suitshield" ) - 1 );
			self notify("suit_repaired");					

			wait Float(GetDvar("suit_shield_patch_duration"));

			self EnableWeaponSwitch();
			
			//try and reduce weird problems where switching back is done before a normal weapon is returned to the player.
			if( old_weapon == "none" )
			{
				old_weapon = self GetCurrentPrimaryWeapon();
				if( old_weapon == "none")
				{
					old_weapon = self GetCurrentOffhand();
				}
			}
			self SwitchToWeapon( old_weapon );					
		}
	}
}

suit_shield_smooth_give_health()
{
	self endon("death");
	self endon("remove_nx_suitshield");
	
	HEALTH_INCREASE_TIME_STEP = 0.05;
	
	health_increase_rate = Int( HEALTH_INCREASE_TIME_STEP * Float( GetDvar( "player_suitshield_max_health" ) ) / ( Float( GetDvar( "suit_shield_patch_wait" )) - Float( GetDvar( "suit_shield_wait_until_injection" )) ));	
	health = self GetSuitShieldHealth();
	total_time = 0.0;
	
	wait Float( GetDvar( "suit_shield_wait_until_injection" ));
	
	while( total_time < Float(GetDvar("suit_shield_patch_wait")) )
	{
		self SetSuitShieldHealth( health );
		self FlashSuitShieldHealthMeter();
		health += health_increase_rate;
		
		if ( health >= Int(GetDvar("player_suitshield_max_health")) )
		{
			break;
		}
		
		total_time += HEALTH_INCREASE_TIME_STEP;
		wait HEALTH_INCREASE_TIME_STEP;
	}
	
	self SetSuitShieldHealth( Int(GetDvar("player_suitshield_max_health")) );
	self FlashSuitShieldHealthMeter();
}

suit_shield_disable_watch()
{
	self endon("death");
	self endon("remove_nx_suitshield");
	while( true )
	{
		suit_health = self GetSuitShieldHealth();
		ammo = self GetAmmoCount( "nx_suitshield" );
		if( (suit_health < Int(GetDvar("player_suitshield_max_health")) && ammo > 0) || IsGodMode( self ) )
		{
			//enable
			self EnableActionSlot( 4, true );
		}
		else
		{
			//disable
			self EnableActionSlot( 4, false );
		}
			
		wait 0.05;
	}
}

should_break_patch_hint()
{
	//if the suit health is above the threshold kill the prompt.
	if( (level._player GetSuitShieldHealth() / Float(GetDvar("player_suitshield_max_health")) > SUIT_PATCH_PROMPT_HEALTH_PERC) || self GetAmmoCount( "nx_suitshield" ) <= 0 )
	{
		return true;
	}
	else
	{
		return false;
	}
}

//temporary effects.
blur_pulse( amount, fadeIn, fadeOut, amount_end )
{
	if( !IsDefined( amount_end ) )
	{
		amount_end = 0.0;
	}

	SetBlur( amount, fadeIn );
	wait fadeIn;
	SetBlur( amount_end, fadeOut );
	wait fadeOut;
}

camera_shake( amount, duration )
{
	Earthquake( amount, duration, self.origin,  2000 );
}