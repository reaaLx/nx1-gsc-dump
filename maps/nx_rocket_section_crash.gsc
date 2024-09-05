
//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_ROCKET_SECTION_											**
//                                                                          **
//    Created: 7/13/2011 - 													**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

//*******************************************************************
//                                                                  *
//*******************************************************************
start()
{
	maps\nx_rocket_section_intro::start_railgun_ride( "heli_start_ride_nuke", "cinematic" );

	// Setup jump to start objectives
	// "Destroy launch site Alpha"
	Objective_Add( obj( "OBJ_DESTROY_BASE_ALPHA" ), "done", &"NX_ROCKET_OBJ_BASE_ALPHA" );

	// "Destroy launch site Delta"
	Objective_Add( obj( "OBJ_DESTROY_BASE_DELTA" ), "done", &"NX_ROCKET_OBJ_BASE_DELTA" );

	// "Destroy launch site November"
	Objective_Add( obj( "OBJ_DESTROY_LAUNCHING_ROCKETS" ), "active", &"NX_ROCKET_OBJ_LAUNCHING_ROCKETS" );

	// Start some low power rumble to simulate chopper bumps
	thread maps\nx_rocket_util::slightly_vibrate_camera();

	level.playerHeli Vehicle_SetSpeed( 60 );

	level.playerHeli maps\nx_rocket_util::intro_chopper_allies_setup();

}

main()
{
	// SAVE POINT
	level thread autosave_now();

	// Actors no longer shoot blanks
	anim.shootEnemyWrapper_func = animscripts\utility::ShootEnemyWrapper_shootNotify;

	// Temporary - complete the objective
	flag_set( "base_delta_destroyed" );

	flag_wait( "crash_section_transition" );	

	thread vignette_dialogue();

	// Railgun section is over, turn it all off
	maps\nx_rocket_railgun::disable_railgun();
	level notify( "railgun_complete" );

	// Turn off player god
	level._player notify( "stop_god_mode" );
	//level._player disableinvulnerability();

	level.playerheli thread maps\nx_rocket_util::heli_start_path( "crash_heli_start", "targetname" );

	flag_wait( "vignette_nuke_crash" );
	//flag_set( "music_chk_crash" );

	maps\nx_rocket_anim::nuke_and_crash( 
		level.playerHeli, 
		level.squad[ "ALLY_JENKINS" ], 
		level.squad[ "ALLY_BAKER" ], 
		level.squad[ "ALLY_WILLIAMS" ] 
		);
/*
///// GREENLIGHT: End the mission here /////
	level._player EnableInvulnerability();	// Because the player falls to his death once the anim is done
	SoundFade(1);
	//thread fadeout_heli_sfx();
	level._player DisableWeapons();
	level._player FreezeControls(true);
	black_overlay = create_client_overlay( "black", 1 );
	wait 6.1;
	nextmission();
	wait 12.0;
////////////////////////////////////////////
*/

//  // Goes untill the path is over
//  level.playerHeli waittill( "reached_dynamic_path_end" );

//
//  // Vehicle crashes and player dismounts
//  level.playerHeli maps\_nx_blackhawk_minigun::player_dismount_blackhawk_turret();
//  level._player unlink();
//
//  // Railgun section is over, turn it all off
//  maps\nx_rocket_railgun::disable_railgun();
//  level notify( "railgun_complete" );
//
//  level.playerHeli vehicle_stoppath();
//  level.playerHeli suspend_drive_anims_for_vignette();
//
//  maps\nx_rocket_anim::crash_nuke( level.playerHeli );
//
//  thread vignette_allies_falling();
//  maps\nx_rocket_anim::crash_blackhawk( level.squad[ "ALLY_BAKER" ], level.squad[ "ALLY_WILLIAMS" ], level.squad[ "ALLY_JENKINS" ], level.playerHeli );

}

fadeout_heli_sfx()
{
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	thread maps\_utility::set_ambient( "nx_rocket_heli_intro_silent" );
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	thread maps\_utility::set_ambient( "nx_rocket_heli_intro_silent" );
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 2 );
	wait 0.1;
}

vignette_allies_falling()
{
	wait 6.766;
	maps\nx_rocket_anim::crash_falling();
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
	flag_init( "base_echo_exit" );
}

vignette_dialogue()
{
	// USED TO ATTACH SOUNDS TO CHARACTERS.
	baker = level.squad[ "ALLY_BAKER" ];
	jenkins = level.squad[ "ALLY_JENKINS" ];
	williams = level.squad[ "ALLY_WILLIAMS" ];

	// DELAY TIME USED FOR DIALOG SYNCING.
	wait 5.8;
	
	// "Deadeye 1, proceed to grid square 8-6 Actual and scan for additional targets."
	level thread play_dialogue( "roc_dra_nuke_ded1proceed86actual", 1 );

	// "Copy Dragon, turning for 8-6 Actual."
	level thread play_dialogue( "roc_ded1_nuke_turningfor86actual", 6.25 );

	// "Dragon, we have visual track on cruise missiles headed your way!"
	level thread play_dialogue( "roc_ded1_nuke_cruisemissiles", 15.1 );

	// "Fleet wide flash alarm!  All ships activate point defense systems...."
	level thread play_dialogue( "roc_dra_nuke_fleetwideflashalarm", 18.2 );

	// "Stay on guns!  We're not done Zulu! Get us the fuck out of here!"
	baker thread play_dialogue( "roc_bak_nuke_stayongunsnotdone", 26.5 );

	// "HANG ON!"
	// williams thread play_dialogue( "roc_wil_nuke_hangon", 25 );

	// "We've lost rotor control!"
	level thread play_dialogue( "roc_ded1_nuke_lostrotorcontrol", 36.1 );

	// "Mayday Mayday!"
	level thread play_dialogue( "roc_ded1_nuke_mayday", 37 );

	// "Brace for impact!"
	level thread play_dialogue( "roc_ded1_nuke_braceforimpact", 39.75 );
}
