//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Mission Utils												**
//                                                                          **
//    Created: 7/05/2011 - Ken Moodie										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_utility_code;
#include maps\_nx_objective_util;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_nx_utility;
#include maps\_hud_util;

player_weapon_init( full_auto )
{
	if( !IsDefined( full_auto ))
	{
		full_auto = false;
	}

	// This could change once we establish a loadout
	if( full_auto )
		level._player GiveWeapon ("lancer_xray");
 	else
		level._player GiveWeapon ("lancer_silencer_xray");
	//level._player GiveWeapon ("m9");
	level._player setOffhandPrimaryClass( "frag" );
	level._player GiveWeapon ("fraggrenade");
	if( full_auto )
		level._player SwitchToWeapon( "lancer_xray" ); 
  	else
		level._player SwitchToWeapon( "lancer_silencer_xray" ); 
}

player_remove_abilities()
{
	level._player AllowSprint(false);
	level._player AllowMelee(false);
	level._player AllowProne(false);
	level._player AllowJump(false);
	SetSavedDvar ( "weapon_view_bob_speed_modifier", 1.5);
	level._player SetMoveSpeedScale(0.5);
}

player_restore_abilities()
{
	level._player SetMoveSpeedScale( 1 );
	SetSavedDvar ( "weapon_view_bob_speed_modifier", 1);
	level._player AllowSprint(true);
	level._player AllowMelee(true);
	level._player AllowProne(true);
	level._player AllowJump(true);
}

pip_setup(  )
{
	// Turn on pip capability
	setSavedDvar ("alternateSceneEnable", "1" );

	// Create the PIP HUD element and define its properties
	pip = NewHUDElem();
    pip.alignX = "right";
	pip.alignY = "bottom";
	pip.horzAlign = "right";
	pip.vertAlign = "bottom";
	pip.x = -480;
	pip.y = -240;
	pip SetShader( "alternate_scene_overlay", 164, 128 );

	// Use "level notify ("remove_pip");" to turn off pip in script
	level waittill ("remove_pip");

	// Turn off all the pip stuff
	setSavedDvar ("alternateSceneEnable", "0" );
	level._player AlternateSceneCameraUnlink ();
	pip Destroy();

}


spawn_baker()
{

	// Spawn and set up Baker
	level.baker = spawn_targetname ("ally_specops_spawner", true);
	level.baker SetIsVisibleInXray ( true );
	level.baker thread magic_bullet_shield();

	// Until his default weapons are set up:
	level.baker ForceUseWeapon( "lancer_xray", "primary" );
	level.baker ForceUseWeapon( "lancer", "secondary" );
	level.baker.animname = "ally_01";
}

spawn_business_baker()
{

	// Spawn and set up Baker
	level.baker = spawn_targetname ("ally_suit_spawner", true);
	level.baker SetIsVisibleInXray ( true );
	level.baker thread magic_bullet_shield();

	// Until his default weapons are set up:
	level.baker gun_remove();
	level.baker.animname = "ally_01";
}

unsuppressed_weapon_warning()
{
	level endon ("going_loud");
	while ( 1 )
	{
		wait 1;
		weap = level._player GetCurrentWeapon();
		if ( ( weap != "lancer_xray" )
			 && ( weap != "lancer_xray" )
			 && ( weap != "none" ) )// ladders etc
			break;
	}
	thread add_dialogue_line( "Baker", "Careful with that. Unsuppressed weapons could give us away.", "green", 2 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// When turned on, player 
low_cover_on( player_dist, fog_on, ignore_me_enemies, sight_distance )
{
	level._player endon( "notify_halon_cover_off" );

	Assert( IsDefined( player_dist ));
	Assert( IsDefined( fog_on ));
	
	while( 1 )
	{
		stance = level._player GetStance();

		if( ( stance == "stand" ) || flag( "flag_player_danger" ))
		{
			level._player.maxvisibledist = 8192;			

			// Fog
			if( fog_on )
				setExpFog( 0, 200, 0.854902, 0.8470588, 0.8392157, 0.2, 0, 0, 0, 0.4980392, 0.4980392, 0.4980392, 0.4980392, 0.4980392, 0.4980392 );

   			// Enemies
			if( IsDefined( ignore_me_enemies ))
			{
				foreach( guy in ignore_me_enemies )
				{
					if( IsAlive( guy ))
					{
						guy.ignoreall = false;
						if( IsDefined( sight_distance ))
						{
							guy.sight_distance = sight_distance;
						}	
					}
				}
			}

		}
		else if( stance == "crouch" || stance == "prone" )
		{
			level._player.maxvisibledist = player_dist;			

			// Fog
			if( fog_on )
				setExpFog( 0, 200, 0.854902, 0.8470588, 0.8392157, 1.0, 0, 0, 0, 0.4980392, 0.4980392, 0.4980392, 0.4980392, 0.4980392, 0.4980392 );

			// Enemies
			if( IsDefined( ignore_me_enemies ))
			{
				foreach( guy in ignore_me_enemies )
				{
					if( IsAlive( guy ))
					{
						guy.ignoreall = true;
						if( IsDefined( sight_distance ))
						{
							guy.sight_distance = 0;
							guy.state = "search";
						}						
					}
				}
			}
		}

		wait 0.05;
	}
}

low_cover_off()
{
	level._player notify( "notify_halon_cover_off" );
	level._player.maxvisibledist = 8192;	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

// "bink" is the name of the bink, "audio" is the sound file to play along with it, "flag" is the flag to wait on before playing the bink
play_pip_bink( bink, audio, flag )
{

	load_cinematic( bink );

	// Wait on flag
	if (isdefined ( flag ))
		flag_wait( flag );

	// create HUd container for bink
	cinema_overlay = create_cinematic_hud_overlay( 0, -240, 164, 128, true );

	cinema_overlay.alignX = "right";
	cinema_overlay.alignY = "bottom";
	cinema_overlay.horzAlign = "right";
	cinema_overlay.vertAlign = "bottom";

	// Message if the bink was not given enough time to load.
	while ( !IsCinematicLoaded( bink ) )
	{
		wait 0.1;
		iprintln ("still loading...");
	}

	// Play the audio in sync if there is any
	if (isdefined ( audio ))
		level._player playsound ( audio );

	play_cinematic();
	while( IsCinematicPlaying())
	{
		wait 0.05;
	}
	destroy_cinematic_hud_overlay( cinema_overlay );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

stealth_settings()
{
	maps\_stealth_utility::stealth_set_default_stealth_function( "village_patrol", ::stealth_village_patrol );

	ai_event = [];
	ai_event["ai_eventDistNewEnemy"] = [];
	ai_event["ai_eventDistNewEnemy"]["spotted"]		 = 512; 
	ai_event["ai_eventDistNewEnemy"]["hidden"] 		 = 256; 

	ai_event["ai_eventDistExplosion"] = [];
	ai_event["ai_eventDistExplosion"]["spotted"]	 = level.explosion_dist_sense;
	ai_event["ai_eventDistExplosion"]["hidden"] 	 = level.explosion_dist_sense;

	ai_event["ai_eventDistDeath"] = [];
	ai_event["ai_eventDistDeath"]["spotted"] 		 = 512; // 256
	ai_event["ai_eventDistDeath"]["hidden"] 		 = 512; // 64
	
	ai_event["ai_eventDistPain"] = [];
	ai_event["ai_eventDistPain"]["spotted"] 		 = 256;
	ai_event["ai_eventDistPain"]["hidden"] 		 	= 256; // used to be 64
	
	ai_event["ai_eventDistBullet"] = [];
	ai_event["ai_eventDistBullet"]["spotted"]		 = 96;
	ai_event["ai_eventDistBullet"]["hidden"] 		 = 96;	
	
	ai_event["ai_eventDistFootstep"] = [];
	ai_event["ai_eventDistFootstep"]["spotted"]		 = 300; // 300
	ai_event["ai_eventDistFootstep"]["hidden"] 		 = 125; // 300

	ai_event["ai_eventDistFootstepWalk"] = [];
	ai_event["ai_eventDistFootstepWalk"]["spotted"]	 = 300; // 300
	ai_event["ai_eventDistFootstepWalk"]["hidden"] 	 = 125; // 300

	ai_event["ai_eventDistFootstepSprint"] = [];
	ai_event["ai_eventDistFootstepSprint"]["spotted"]	 = 400; // 400
	ai_event["ai_eventDistFootstepSprint"]["hidden"] 	 = 200; // 400

	maps\_stealth_utility::stealth_ai_event_dist_custom( ai_event );
	
	rangesHidden = [];
	rangesHidden["prone"]	= 800;  // 800
	rangesHidden["crouch"]	= 1200; // 1200
	rangesHidden["stand"]	= 1600; // 1600

	rangesSpotted = [];
	rangesSpotted["prone"]	= 8192;	//8192
	rangesSpotted["crouch"]	= 8192;	//8192
	rangesSpotted["stand"]	= 8192; //8192

	maps\_stealth_utility::stealth_detect_ranges_set( rangesHidden, rangesSpotted );
	
	maps\_stealth_utility::stealth_alert_level_duration( 0.5 );	

	maps\_stealth_utility::stealth_ai_event_dist_custom( ai_event );

	array = [];
	array["sight_dist"]	 = 400; //400
	array["detect_dist"]	 = 300; //200
	maps\_stealth_utility::stealth_corpse_ranges_custom( array );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

stealth_village_patrol()
{
	self maps\_stealth_utility::stealth_plugin_basic();

	if ( isplayer( self ) )
	{
		return;
	}		
	switch( self.team )
	{
		case "default":
		case "axis":
			//if( self.type == "dog" )
			//{
			//	self thread dogs_have_small_fovs_when_stopped();
			//}

			self.pathrandompercent = 0;
			self maps\_stealth_utility::stealth_plugin_threat();
			self maps\_stealth_utility::stealth_plugin_corpse();
			self maps\_stealth_utility::stealth_plugin_event_all();
			self.baseaccuracy = 2;
			self.fovcosine = .5;	
			self.fovcosinebusy = .1;
			break;

		case "allies":
			array = [];
			array["hidden"] = ::stealth_friendly_state_hidden;
			array["spotted"] = ::stealth_friendly_state_spotted;
			maps\_stealth_utility::stealth_basic_states_custom( array );
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

stealth_friendly_state_hidden()
{	
	self.no_pistol_switch = true;
	
	self.ignoreCloseFoliage = true;
	
	self pushplayer( true );
	self.fixednode = true;
	self thread set_battlechatter( false );
	self set_friendlyfire_warnings( false );
	self.dontEverShoot 	= true;
	
	self thread enable_cqbwalk();
		
	self.grenadeammo	 = 0;
	
	self.forceSideArm 	= undefined;
	//used to be ignore all - but that makes him not aim at enemies when exposed - which isn't good...also 
	//after stealth groups were created we want to differentiate between who should be shot at and who shouldn't
	//so we don't all of a sudden alert another stealth group by shooting at them
	self.ignoreme 		= true;
	self.ignoresuppression = true;
	setsaveddvar( "ai_friendlyfireblockduration", 0 );
	setsaveddvar( "ai_friendlysuppression", 0 );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

stealth_friendly_state_spotted()
{	
	self notify( "stop_dynamic_run_speed" );
	self.no_pistol_switch = undefined;
	self.ignoreall = false;
	self.fixednode = true;
	self.ignoreCloseFoliage = true;
	
	
	self thread set_battlechatter( false );//BCS sounds bad in combat right now
	self set_friendlyfire_warnings( true );
	self.dontEverShoot 	= undefined;
	
	self.maxsightdistsqrd = 8000*8000;
	self.grenadeammo 	= 0;
	//used to be ignore all - but that makes him not aim at enemies when exposed - which isn't good...also 
	//after stealth groups were created we want to differentiate between who should be shot at and who shouldn't
	//so we don't all of a sudden alert another stealth group by shooting at them	
	self.ignoreme 	 	= false;
	
	self pushplayer( false );
	
	self thread disable_cqbwalk();

	self.ignoresuppression = false;
	setsaveddvar( "ai_friendlyfireblockduration", 2000 );
	setsaveddvar( "ai_friendlysuppression", 1 );
}

fx_elevator_glass_cycle( start, speed, elevator )
{
	elevator_parts = GetEntArray( elevator , "script_noteworthy" );

	foreach( part in elevator_parts )
	{
		if( part.classname == "script_model" )
		{
			part SetAnimParamValue( start, speed );
		}
	}
}

fx_hide_cloud_ring()
{
	cloud = GetEnt( "cloud_ring", "targetname" );

	if (IsDefined( cloud ))
	{
		cloud Hide();
	}

	Stop_Exploder( "fx_upper_smog" );
}

fx_show_cloud_ring()
{
	cloud = GetEnt( "cloud_ring", "targetname" );

	if (IsDefined( cloud ))
	{
		cloud Show();
	}

	Exploder( "fx_upper_smog" );
}
