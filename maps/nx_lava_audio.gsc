//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Hit Hard at Home Audio										**
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
#include maps\nx_lava_util;



flag_inits()
{
	//DR: needed for music cues
	flag_init( "music_chk_outpost" );
	flag_init( "music_chk_garage" );
	flag_init( "music_chk_platform_tower" );
	flag_init( "music_chk_station_1");
	flag_init( "music_chk_train_1" );
	flag_init( "music_chk_station_2" );
	flag_init( "music_chk_station_2_arrive" );
	flag_init( "music_chk_train_interior" );
	flag_init( "music_chk_train_2" );
	flag_init( "music_chk_train_2_skimmers" );
	flag_init( "music_chk_derail" );
	flag_init( "train3_sfx_on" );
}



// Mission specific music thread


mission_music()
{
	//Set the music flags for this start point
	jump_to_music_flag_setup();

	//Start the music script at this start point
	switch ( level._start_point )
	{
		// Game will jump to the jump to checkpoint selected and continue execution from there
		case "default":
		case "outpost":
		{
			flag_wait( "music_chk_outpost" );
			//iprintlnbold ( "MUSIC: OUPOST" );
			if( !flag( "music_chk_garage" ) )
			{
				wait ( 1.0 );
			}
			//play_music_once( "mus_lava_intro" );
			//play_music_num_times("mus_lava_intro", 2, 2);
			play_music_loop_infinite("mus_lava_intro");
			/*						
			flag_wait( "music_chk_osprey_intro" );
			wait (0.75);
			play_music_once( "music_chk_nx_hithard_osprey_intro" );
			*/
		}

		case "garage":
		{
			flag_wait( "music_chk_garage" );			
			//iprintlnbold ( "MUSIC: GARAGE" );
			
			if( !flag( "music_chk_platform_tower" ) )
			{
				music_stop(3);
				wait ( 3.0 );
			}
			play_music_once( "mus_lava_reveal" );
			/*
			flag_wait( "music_chk_parachute_start" );			
			wait 2.5;
			play_music_once( "music_chk_nx_hithard_parachute" );
			flag_wait( "music_chk_parachute_ends" );
			music_stop(12);
			*/
		}

		case "platform_tower":
		{
			flag_wait( "music_chk_platform_tower" );
			//play_music_loop_infinite( "mus_lava_battle" );
			if( !flag( "music_chk_station_1" ) )
			{
				wait ( 7.0 );
			}
		}
		case "station_1":
		{			
			play_music_num_times("mus_lava_battle", 2, 2);
			//play_music_loop_infinite( "mus_lava_battle" );
			//iprintlnbold ( "MUSIC: PLATFORM OR STATION" );
			/*
			flag_wait( "music_chk_rooftop_battle_starts");
			play_music_loop_infinite( "music_chk_nx_hithard_rooftop" );		
			flag_wait( "music_chk_snipe_ends" );			
			music_stop(10);
			*/
		}

		case "train_1":
		
		{
			flag_wait( "music_chk_train_1" );
			if( !flag( "music_chk_station_2" ) )
			{
				wait ( 3.0 );
			}
			play_music_once( "mus_lava_battle2" );
		}

		case "station_2":
		case "station_2_arrive":
		case "bridge_to_train":
		case "train_interior":
		case "train_interior_front":
		case "train_2":
		case "train_2_skimmers":
		{
			flag_wait( "music_chk_train_interior" );			
			play_music_loop_infinite( "mus_lava_battle2" );
		}

		case "derail":
		{
			flag_wait( "music_chk_derail" );
			music_stop(4);
			//iprintlnbold ( "MUSIC: DERAIL" );
			//do nothing.
		}
		
		
		
	}
}

jump_to_music_flag_setup()
{
	jump_to = level._start_point;
	
	// Return if this is the current checkpoint
	// Thus, sets all flags up to a given checkpoint
	
	//DR: in order to turn off music, comment out this next line
	flag_set( "music_chk_outpost" );

	if (jump_to == "default")
		return;	

	if (jump_to == "outpost")
		return;

	flag_set( "music_chk_garage" );

	if (jump_to == "garage")		
		return;
	
	flag_set( "music_chk_platform_tower" );

	if (jump_to == "platform_tower")		
		return;

	flag_set( "music_chk_station_1" );

	if (jump_to == "station_1")		
		return;	

	flag_set( "music_chk_train_1" );

	if (jump_to == "train_1")		
		return;

	flag_set( "music_chk_station_2" );

	if (jump_to == "station_2")		
		return;	

	flag_set( "music_chk_station_2_arrive" );

	if (jump_to == "station_2_arrive")		
		return;

	if (jump_to == "bridge_to_train")		
		return;
	
	flag_set( "music_chk_train_interior" );

	if (jump_to == "train_interior")		
		return;

	if (jump_to == "train_interior_front")		
		return;

	flag_set( "music_chk_train_2" );

	if (jump_to == "train_2")		
		return;
	
	flag_set( "music_chk_train_2_skimmers" );

	if (jump_to == "train_2_skimmers")		
		return;

	flag_set( "music_chk_derail" );

	if (jump_to == "derail")		
		return;
	
}
