//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Audio Support										**
//                                                                          **
//    Created: 8/2/2011 - David Rowe										**
//                                                                          **
//****************************************************************************

//This is the mission's _audio.gsc
//All audio scripts should be put into this file

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;			  
#include maps\_vehicle;
#include maps\_nx_utility;
#include maps\nx_rocket_util;



flag_inits()
{
	//DR: needed for music cues
	//examples, for copying and pasting:
	
	flag_init( "music_chk_intro" );
	flag_init( "music_chk_base_alpha" );
	flag_init( "music_chk_bridge" );
	flag_init( "music_chk_base_delta");
	flag_init( "music_chk_delta_end" );
	flag_init( "music_chk_crash" );
	flag_init( "music_chk_hanging" );
	flag_init( "music_chk_base_echo" );
	flag_init( "music_chk_turret_base" );
	flag_init( "music_chk_turret_control" );
	flag_init( "music_chk_rescue" );
	flag_init( "music_chk_littlebird" );
	flag_init( "music_chk_gantry" );
	flag_init( "music_chk_escape" );
	
}


// Mission specific music thread
mission_music()
{
	//Set the music flags for this start point
	jump_to_music_flag_setup();

	//Now jump to the start point that we just started, and roll from there.	
	//example scripts below
	
	switch ( level._start_point )
	{
		// Game will jump to the jump to checkpoint selected and continue execution from there
		case "default":
		case "intro":
		{
			flag_wait( "music_chk_intro" );
			if( !flag( "music_chk_base_alpha" ) )
			{
				//wait ( 6.0 );
			}			
			//play_music_loop_infinite("mus_lava_intro");
			play_music_once( "mus_rocket_intro" );
			//play_music_num_times("mus_lava_intro", 2, 2);
		}

		case "base_alpha":
		{
			flag_wait( "music_chk_base_alpha" );
			//do nothing - let previous music continue, abut don't start anything if jump to it			
		}

		case "bridge":
		{
			flag_wait( "music_chk_bridge" );
			play_music_once( "mus_rocket_bridge" );
		}

		case "base_delta":
		case "crash":
		{
			flag_wait( "music_chk_delta_end" );
			play_music_once( "mus_rocket_delta_end" );

			flag_wait( "music_chk_crash" );
			if( !flag( "music_chk_hanging" ) )
			{
				wait ( 8.562 );
			}
			play_music_once( "mus_rocket_crash" );
		}

		case "hanging":
		{
			flag_wait( "music_chk_hanging" );
			if( !flag( "music_chk_base_echo" ) )
			{
				//music_stop(4);
			}
		}

		case "base_echo":
		{
			flag_wait( "music_chk_base_echo" );
			play_music_once( "mus_rocket_base_echo" );
		}

		case "turret_base":
		{
			flag_wait( "music_chk_turret_base" );
			play_music_once( "mus_rocket_turret_base" );
		}
		case "turret_control":
		{
			flag_wait( "music_chk_turret_control" );
			if( !flag( "music_chk_rescue" ) )
			{
				music_stop(9);
				wait (10);
			}			
			play_music_once( "mus_rocket_turret_control" );
		}
		case "rescue":
		case "littlebird":
		case "gantry":
		{
			flag_wait( "music_chk_rescue" );
			if( !flag( "music_chk_escape" ) )
			{
				music_stop(7);
				wait (8);
			}
			play_music_loop_infinite( "mus_rocket_rescue" );
		}

		case "escape":
		{
			flag_wait( "music_chk_escape" );
			music_stop(2);
			wait (2.5);
			play_music_once( "mus_rocket_escape" );
		}
	}
	
}

jump_to_music_flag_setup()
{
	//This script will set music flags for whichever checkpoint the game last started on,
	//so that the music can pick up and continue from there on out
	//this gets run at the beginning of the level, and anytime the user debugs 
	//to any checkpoint.

	//example below, for copying and pasting

	
	jump_to = level._start_point;
	
	// Return if this is the current checkpoint
	// Thus, sets all flags up to a given checkpoint
	
	//DR: in order to turn off music, comment out this next line
	flag_set( "music_chk_intro" );

	if (jump_to == "default")
		return;

	if (jump_to == "intro")
		return;

	flag_set( "music_chk_base_alpha" );

	if (jump_to == "base_alpha")
		return;
	
	flag_set( "music_chk_bridge" );

	if (jump_to == "bridge")
		return;

	flag_set( "music_chk_base_delta" );

	if (jump_to == "base_delta")
		return;

	flag_set( "music_chk_delta_end" );	

	if (jump_to == "crash")
		return;

	flag_set( "music_chk_crash" );
	flag_set( "music_chk_hanging" );

	if (jump_to == "hanging")
		return;

	flag_set( "music_chk_base_echo" );

	if (jump_to == "base_echo")
		return;

	flag_set( "music_chk_turret_base" );

	if (jump_to == "turret_base")
		return;

	flag_set( "music_chk_turret_control" );

	if (jump_to == "turret_control")
		return;
	
	flag_set( "music_chk_rescue" );

	if (jump_to == "rescue")
		return;

	flag_set( "music_chk_littlebird" );

	if (jump_to == "littlebird")
		return;

	flag_set( "music_chk_gantry" );

	if (jump_to == "gantry")
		return;

	flag_set( "music_chk_escape" );

	if (jump_to == "escape")
		return;
	
}

rocket_air_vehicle_flyby_sfx( soundalias, wait_time )
{
	wait wait_time;

	if(( isAlive( self ) && ( self vehicle_is_crashing()) == false ))
	{
		self playsound( soundalias );
	}
}

rocket_sam_turret_explode_audio()
{
	
	if( isAlive( self ))
	{
		self playsound( "nx_rocket_sam_turret_explode" );
	}
}


rocket_helo_battle_delta_05_sounds (chopperent)
{	
	chopperent thread rocket_air_vehicle_flyby_sfx ("helo_hit", 0.0); 
	chopperent thread rocket_air_vehicle_flyby_sfx ("nx_rocket_delta_chopper_crash", 2.0); 
	chopperent thread rocket_air_vehicle_flyby_sfx ("helo_crash", 4.0); 
	chopperent thread rocket_air_vehicle_flyby_sfx ("helo_secondary_exp", 4.0);		
		

	if(( isAlive( chopperent ) && ( chopperent vehicle_is_crashing()) == false ))
	{		
		chopperent playloopsound ("helo_dying_loop");		
	}
	wait (4.0);
	if(( isAlive( chopperent ) && ( chopperent vehicle_is_crashing()) == false ))
	{
		chopperent stoploopsound("helo_dying_loop");
	}
}


nuke_and_crash_sfx()
{
	flag_set( "music_chk_crash" );

	wait 0.89;
	level._player playsound("scn_rocket_nuke_crash");

	wait 2.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "rocket_nuke_crash", 0.4 );
	
	wait 31.0;
	level._player setchannelvolumes( "snd_channelvolprio_level", "rocket_nuke_crash", 0.1 );
	
	wait 6.0;
	level._player deactivatechannelvolumes( "snd_channelvolprio_level", 6.0 );
}

base_alpha_countdown_sfx()
{
	level endon( "rocket_1_destroyed" );
	soundorg1 = Spawn( "sound_emitter", (-6808, 21147, 1882) );
	soundorg2 = Spawn( "sound_emitter", (-9821, 17889, 1882) );
	soundorg3 = Spawn( "sound_emitter", (-8898, 14017, 1882) );
	soundorg4 = Spawn( "sound_emitter", (-4601, 12767, 1882) );
	wait 10;
	soundorg1 PlaySound( "roc_kpa_delta_clearallblastways" );
	soundorg2 PlaySound( "roc_kpa_delta_clearallblastways" );
	soundorg3 PlaySound( "roc_kpa_delta_clearallblastways" );
	soundorg4 PlaySound( "roc_kpa_delta_clearallblastways" );
	wait 10;
	soundorg1 PlaySound( "roc_kpa_delta_launchcommencing" );
	soundorg2 PlaySound( "roc_kpa_delta_launchcommencing" );
	soundorg3 PlaySound( "roc_kpa_delta_launchcommencing" );
	soundorg4 PlaySound( "roc_kpa_delta_launchcommencing" );
	wait 10;
	soundorg2 PlaySound( "roc_kpa_delta_30sectolaunch" );
	soundorg3 PlaySound( "roc_kpa_delta_30sectolaunch" );
	soundorg4 PlaySound( "roc_kpa_delta_30sectolaunch" );
	soundorg1 PlaySound( "roc_kpa_delta_30sectolaunch" );
	wait 5;
	soundorg1 PlaySound( "roc_kpa_delta_launchcommencing" );
	soundorg2 PlaySound( "roc_kpa_delta_launchcommencing" );
	soundorg3 PlaySound( "roc_kpa_delta_launchcommencing" );
	soundorg4 PlaySound( "roc_kpa_delta_launchcommencing" );
	wait 5;
	soundorg1 PlaySound( "roc_kpa_delta_notpossibletoabort" );
	soundorg2 PlaySound( "roc_kpa_delta_notpossibletoabort" );
	soundorg3 PlaySound( "roc_kpa_delta_notpossibletoabort" );
	soundorg4 PlaySound( "roc_kpa_delta_notpossibletoabort" );
	wait 5;
	soundorg1 PlaySound( "roc_kpa_delta_proceedwithcountdown" );
	soundorg2 PlaySound( "roc_kpa_delta_proceedwithcountdown" );
	soundorg3 PlaySound( "roc_kpa_delta_proceedwithcountdown" );
	soundorg4 PlaySound( "roc_kpa_delta_proceedwithcountdown" );
	wait 5;
	soundorg1 PlaySound( "roc_kpa_delta_countdown30" );
	soundorg2 PlaySound( "roc_kpa_delta_countdown30" );
	soundorg3 PlaySound( "roc_kpa_delta_countdown30" );
	soundorg4 PlaySound( "roc_kpa_delta_countdown30" );
	wait 5;
	soundorg1 PlaySound( "roc_kpa_delta_proceedwithcountdown" );
	soundorg2 PlaySound( "roc_kpa_delta_proceedwithcountdown" );
	soundorg3 PlaySound( "roc_kpa_delta_proceedwithcountdown" );
	soundorg4 PlaySound( "roc_kpa_delta_proceedwithcountdown" );

	wait 5;

	soundorg1 PlaySound( "roc_kpa_delta_countdown20" );
	soundorg2 PlaySound( "roc_kpa_delta_countdown20" );
	soundorg3 PlaySound( "roc_kpa_delta_countdown20" );
	soundorg4 PlaySound( "roc_kpa_delta_countdown20" );

	wait 5;

	soundorg1 PlaySound( "roc_kpa_delta_notpossibletoabort" );
	soundorg2 PlaySound( "roc_kpa_delta_notpossibletoabort" );
	soundorg3 PlaySound( "roc_kpa_delta_notpossibletoabort" );
	soundorg4 PlaySound( "roc_kpa_delta_notpossibletoabort" );

	level waittill( "rocket_1_10s_warning" );
	soundorg1 PlaySound( "roc_kpa_delta_countdown10" );
	soundorg2 PlaySound( "roc_kpa_delta_countdown10" );
	soundorg3 PlaySound( "roc_kpa_delta_countdown10" );
	soundorg4 PlaySound( "roc_kpa_delta_countdown10" );
}

base_delta_countdown_sfx()
{
	level endon( "rocket_2_destroyed" );
	soundorg1 = Spawn( "sound_emitter", (-90160, 66944, 1473) );
	soundorg2 = Spawn( "sound_emitter", (-96288, 67504, 1473) );
	soundorg3 = Spawn( "sound_emitter", (-98120, 73424, 1473) );
	soundorg4 = Spawn( "sound_emitter", (-92672, 76224, 1473) );
	soundorg5 = Spawn( "sound_emitter", (-93072, 87504, 1651) );
	soundorg6 = Spawn( "sound_emitter", (-98624, 87904, 1651) );
	soundorg7 = Spawn( "sound_emitter", (-93456, 97616, 1651) );
	soundorg8 = Spawn( "sound_emitter", (-87232, 97472, 1651) );
	soundorg9 = Spawn( "sound_emitter", (-84368, 92656, 1651) );
	soundorg10 = Spawn( "sound_emitter", (-101328, 76768, 3419) );
	soundorg11 = Spawn( "sound_emitter", (-109584, 76240, 3419) );
	soundorg12 = Spawn( "sound_emitter", (-108448, 83376, 3419) );
	soundorg13 = Spawn( "sound_emitter", (-101360, 80992, 3419) );
	soundorgArray = [];
	soundorgArray = array_add( soundorgArray, soundorg1 );
	soundorgArray = array_add( soundorgArray, soundorg2 );
	soundorgArray = array_add( soundorgArray, soundorg3 );
	soundorgArray = array_add( soundorgArray, soundorg4 );
	soundorgArray = array_add( soundorgArray, soundorg5 );
	soundorgArray = array_add( soundorgArray, soundorg6 );
	soundorgArray = array_add( soundorgArray, soundorg7 );
	soundorgArray = array_add( soundorgArray, soundorg8 );
	soundorgArray = array_add( soundorgArray, soundorg9 );
	soundorgArray = array_add( soundorgArray, soundorg10 );
	soundorgArray = array_add( soundorgArray, soundorg11 );
	soundorgArray = array_add( soundorgArray, soundorg12 );
	soundorgArray = array_add( soundorgArray, soundorg13 );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_clearallblastways" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_launchcommencing" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_30sectolaunch" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_launchcommencing" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_notpossibletoabort" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_proceedwithcountdown" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_countdown30" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_proceedwithcountdown" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_countdown20" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_notpossibletoabort" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_countdown10" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_clearallblastways" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_launchcommencing" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_30sectolaunch" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_launchcommencing" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_notpossibletoabort" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_proceedwithcountdown" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_countdown30" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_proceedwithcountdown" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_countdown20" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_notpossibletoabort" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_countdown10" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_clearallblastways" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_launchcommencing" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_30sectolaunch" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_launchcommencing" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_notpossibletoabort" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_proceedwithcountdown" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_countdown30" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_proceedwithcountdown" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_countdown20" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_notpossibletoabort" );
	wait 5;
	speaker = getClosest( level._player.origin, soundorgArray );
	speaker PlaySound( "roc_kpa_delta_countdown10" );
}

