//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Audio Support												**
//                                                                          **
//    Created: 11/11/11 - Travis Chen (trchen x 4143)						**
//                                                                          **
//****************************************************************************

//This is the mission's _audio.gsc
//All audio scripts should be put into this file

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;			  
#include maps\_vehicle;
#include maps\_nx_utility;
#include maps\nx_border_util;



flag_inits()
{
	//DR: needed for music cues
	//examples, for copying and pasting:
	flag_init( "music_battle_start" );
	
	flag_init( "music_chk_border" );
	flag_init( "music_chk_streets" );
	flag_init( "music_chk_market" );
	flag_init( "music_chk_church");
	flag_init( "helicopter_reveal");	
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
		case "border":
		{
			thread maps\_utility::set_ambient( "amb_border_ext_intro" );
			flag_wait( "music_chk_border" );
			if( !flag( "music_chk_streets" ) )
			{
				//wait ( 25.0 );
			}
			flag_wait( "music_battle_start" );

			thread maps\_utility::set_ambient( "amb_border_ext" );
			play_music_loop_infinite("mus_border_battle");
		}

		case "streets":
		{
			thread maps\_utility::set_ambient( "amb_border_ext" );
			//play_music_num_times("mus_lava_battle", 2, 2);
		}

		case "market":
		{
			thread maps\_utility::set_ambient( "amb_border_ext" );
			//play_music_num_times("mus_lava_battle", 2, 2);
		}
		case "church":
		{					
			thread maps\_utility::set_ambient( "amb_border_ext" );	
			//play_music_num_times("mus_lava_battle", 2, 2);
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
	flag_set( "music_chk_border" );

	if (jump_to == "default")
		return;

	if (jump_to == "border")
		return;

	flag_set( "vo_border_section_done");
	flag_set( "music_chk_streets" );
	flag_set( "music_battle_start" );	

	if (jump_to == "streets")
		return;
	
	flag_set( "music_chk_market" );

	if (jump_to == "market")
		return;

	flag_set( "music_chk_church" );
	flag_set( "helicopter_reveal" );

	if (jump_to == "church")
		return;	
}
