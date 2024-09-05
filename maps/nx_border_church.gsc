//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module: Border, Church												**
//                                                                          **
//    Created: 11/11/11 - Travis Chen (trchen x 4143)						**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_nx_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_anim;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
}

section_flag_inits()
{
	flag_init( "flag_market_objective_complete" );
	flag_init( "flag_church_heli_inbound" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_objectives( objective_num )
{
	return objective_num;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

church_start()
{
	maps\nx_border_util::player_start( "player_start_church" );

	nodes = GetNodeArray( "node_ally_church_final", "script_noteworthy" );
	Assert( IsDefined( nodes ));

	maps\nx_border_util::spawn_allies( nodes );			
}

church()
{
	CreateThreatBiasGroup( "church_player" );
	CreateThreatBiasGroup( "church_enemies" );
	CreateThreatBiasGroup( "church_allies" );
	level._player SetThreatBiasGroup( "church_player" );

	level.church_num_enemies_done = 0;

	// Enemy spawners
	thread enemy_spawner_setup();

	// Ally / enemy movement
	thread ally_control();
	thread enemy_control();

	// Kills the flood spawners
	thread heli_called_in();

	// Church voiceovers
	thread church_vo();

	// Setting flag so you play the correct helicopter sound
	flag_set( "helicopter_reveal" );

	// Danger zone to keep player in quad
	thread player_danger_zone();	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

church_vo()
{
	flag_wait( "flag_church_start" );

	battlechatter_off( "allies" );
	battlechatter_off( "axis" );

	if( !flag( "flag_church_heli_inbound" ))
	{
		// Dialogue: Baker - We can't get through!  Cartel is digging in!  Jackson, call in the chopper!
		level.leader dialogue_queue( "bor_bak_church_carteldiggingin3" );
	}

	battlechatter_on( "allies" );
	battlechatter_on( "axis" );

	level waittill( "notify_church_all_enemies_dead" );

	wait 3;
	
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );

	// Dialogue: Baker - We're still registering heat signatures from inside the church. Continue with the assault, Panther One. 
	radio_dialogue( "bor_oly_market_heatsignatures" );

	// Dialogue: Baker - Solid copy. (to squad) Check you weapons and ammo. We're not done yet.
	//radio_dialogue( "bor_bak_market_notdoneyet" );
	
	flag_set( "flag_market_objective_complete" );	

	thread ending_blackout();

	// Dialogue: Baker - Solid copy. Charlie Mike. <beat, to squad> Let's go.
	level.leader dialogue_queue( "bor_bak_market_letsgo" );
	
	
	nextmission();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

heli_target_focus()
{
	self endon( "notify_church_all_enemies_dead" );

	target = GetEnt( "origin_anything_I_want", "targetname" );
	Assert( IsDefined( target ));

	// Focus on generic target when no targets in sight
	while( 1 )
	{
		level waittill( "helicopter_support_inbound" );
		
		level.heli_support_turret SetTargetEntity( target );
		
		level waittill( "helicopter_support_unloaded" );
		
		level.heli_support_turret ClearTargetEntity();
		level.heli_support_turret_guy.ignoreall = true;
	}
}

heli_kills_heli()
{
	// Destroyed model
	destroyed = GetEnt( "vehicle_hind_destroyed", "targetname" );
	Assert( IsDefined( destroyed ));
	destroyed hide();
	
	fx = GetEnt( "origin_church_heli_destroy", "targetname" );
	Assert( IsDefined( fx ));		

	// Get heli on ground and kill it
	heli = GetEnt( "vehicle_church_hind", "targetname" );
	Assert( IsDefined( heli ));

	MagicBullet( "nx_turret_blackhawk_ai", level.heli_support_turret.origin + (0, 0, 300), fx.origin );
	MagicBullet( "nx_turret_blackhawk_ai", level.heli_support_turret.origin + (0, 0, 300), fx.origin );
	MagicBullet( "nx_turret_blackhawk_ai", level.heli_support_turret.origin + (0, 0, 300), fx.origin );
	
	wait( 1 );

	PlayFX( GetFX( "nx_border_helicopter_explosion" ), fx.origin );
	


	heli hide();	
	destroyed show();

	destroyed playsound ("scn_helo_explode");
	destroyed PlayLoopSound ("scn_helo_burn");

	// Focuses heli fire when it doesn't have a target
	thread heli_target_focus();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_danger_zone()
{
	while( 1 )
	{
		// Player enters danger zone enemies seek the player out
		if( flag( "flag_church_player_danger" ))
 		{
			SetThreatBias( "church_enemies", "church_player", 1000 );			

			while( flag( "flag_church_player_danger" ))
			{
				guys = GetAIArray( "axis" );
	
				foreach( guy in guys )
				{
					if( IsAlive( guy ))
					{
						guy set_baseaccuracy( 10000 );
						guy player_seek_enable();
					}
				}

				wait( 0.05 );
			}

			// Player leaves zone, return enemies to normal
			SetThreatBias( "church_enemies", "church_player", 0 );			

			guys = GetAIArray( "axis" );

			foreach( guy in guys )
			{
				if( IsAlive( guy ))
				{
					guy set_baseaccuracy( 1 );				
					guy player_seek_disable();
				}
			}
		}

		wait( 0.05 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ally_control()
{
	issue_color_orders( "r400", "allies" );	
	issue_color_orders( "y400", "allies" );

	foreach( guy in level.allies )
	{
		if( guy != level.leader )
		{
			if( !IsDefined( self.Melee ) ) 
			{
				guy thread magic_bullet_shield();
			}
		}
		guy SetThreatBiasGroup( "church_allies" );
	}	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

enemy_control()
{
	// Waits for spawners to be triggered
	flag_wait( "flag_church_start" );

	wait( 0.05 );

	// Enemies initially ignore player
	SetIgnoreMeGroup( "church_enemies", "church_player" );	

	// Wait for guys to die
	while( 1 )
	{
		ai = get_living_ai_array( "actor_church_spawners" , "script_noteworthy" );

		if( ai.size == level.church_num_enemies_done )
			break;

		wait( 0.05 );
	}

	level notify( "notify_church_all_enemies_dead" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

enemy_spawner_setup()
{
	// Add spawnfunc to all enemies
	array_spawn_function_noteworthy( "actor_church_spawners", ::spawnfunc_enemy_church );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

heli_called_in()
{
	flag_wait( "flag_church_start" );

	// Grab spawn flood kill trigger
	kill_flooder = GetEnt( "trig_church_ground_spawner", "targetname" );

	// If the player decides not to throw the grenade
	thread heli_not_called_in( kill_flooder );

	level waittill( "helicopter_support_inbound" );

	flag_set( "flag_church_heli_inbound" );

	thread heli_kills_heli();

	// Kill spawners
	kill_flooder notify( "trigger" );
																							
	// Enemies ignores player and allies
	SetIgnoreMeGroup( "church_enemies", "church_allies" );
	SetIgnoreMeGroup( "church_enemies", "church_player" );
	level._player.ignoreme = true;

	ai = get_living_ai_array(  "actor_church_spawners", "script_noteworthy" );

	Assert( IsDefined( level.support_heli ));

	foreach( guy in ai )
	{
		if( IsSubStr( guy.classname, "rpg" ))
			guy thread rpg_target_heli();
		guy.baseaccuracy = 0.01; 
	}
}

heli_not_called_in( trig )
{
	level endon( "helicopter_support_inbound" );
	
	wait 30;

	trig notify( "trigger" );	

	level.church_num_enemies_done = 4;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rpg_target_heli()
{
	self endon( "death" );

	self enable_cqbwalk();

	while( 1 )
	{
		while( self CanSee( level.support_heli ))
		{
			//self.ignoreall = true;			
			//self cqb_aim( level.support_heli );
			//self Shoot();
			//wait_random( 4, 10 );
			self SetEntityTarget( level.support_heli );

			wait( 0.05 );
		}

		self ClearEntityTarget();

		self.ignoreall = false;
		wait( 0.05 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawnfunc_enemy_church()
{
	if( IsSubStr( self.classname, "rpg" ))
	{
		self.health = 1;
		self.ragdoll_immediate = true;
 	}
	self disable_long_death();
	self SetThreatBiasGroup( "church_enemies" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Blackout at end of level
ending_blackout()
{
	wait 1;

	fadeInTime = 2;
	
	//setSavedDvar( "compass", 0 );
	//setSavedDvar( "hud_showStance", 0 );
	
	overlay = newHudElem();
	overlay.x = 0;
	overlay.y = 0;
	overlay setshader( "black", 640, 480 );
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	
	overlay.alpha = 0;
	overlay fadeOverTime( fadeInTime );
	overlay.alpha = 1;
	
	wait fadeInTime;
	
	level._player freezeControls( true );
	enablePlayerWeapons( false );		
}
