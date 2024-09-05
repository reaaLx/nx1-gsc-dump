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
#include maps\nx_skyscraper_util;



flag_inits()
{
	//DR: needed for music cues
	//examples, for copying and pasting:
	
	flag_init( "music_chk_drive_up" );
	flag_init( "music_chk_lobby_enter" );
	flag_init( "music_chk_elevator" );
	flag_init( "music_chk_shaft");
	flag_init( "music_chk_window" );
	flag_init( "music_chk_hangar" );
	flag_init( "music_chk_lab_enter" );
	flag_init( "music_chk_lab_to_vault" );
	flag_init( "music_chk_vault" );
	flag_init( "music_chk_lab_exit" );
	flag_init( "music_chk_halon" );
	flag_init( "music_chk_vtol" );
	flag_init( "music_chk_rappel" );
	flag_init( "music_chk_outro" );

	flag_init ("baker_exit_elevator_start");
	
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
		case "drive_up":
		case "lobby_enter":
		case "elevator":
		{
			flag_wait( "music_chk_drive_up" );
			if( !flag( "music_chk_shaft" ) )
			{
				wait ( 0.5 );
			}			
			play_music_loop_infinite("mus_skyscraper_stealth");			
		}
		
		case "shaft":
		{			
			flag_wait( "music_chk_shaft" );
			if( !flag( "music_chk_window" ) )
			{
				music_stop(10);
			}
		}

		case "window":
		case "hangar":
		case "lab_enter":
		case "lab_to_vault":
		{
			flag_wait( "music_chk_window" );
			if( !flag( "music_chk_vault" ) )
			{
				wait ( 1.0 );
			}			
			play_music_loop_infinite("mus_skyscraper_stealth");
		}

		case "vault":
		{
			flag_wait( "music_chk_vault" );
			if( !flag( "music_chk_lab_exit" ) )
			{
				music_stop(4);
			}
		}

		case "lab_exit":
		{
			flag_wait( "music_chk_lab_exit" );
			play_music_loop_infinite("mus_skyscraper_battle");
		}

		case "halon":
		case "vtol":
		case "rappel":
		{
			flag_wait( "music_chk_halon" );
			if( !flag( "music_chk_outro" ) )
			{
				music_stop(4);
				wait ( 5.0 );
			}			
			play_music_loop_infinite("mus_skyscraper_halon");
		}
		case "outro":
		{
			flag_wait( "music_chk_outro" );
			play_music_once( "mus_skyscraper_outro" );
			//music_stop(10);
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
	flag_set( "music_chk_drive_up" );

	if (jump_to == "default")
		return;	

	if (jump_to == "drive_up")
		return;

	flag_set( "music_chk_lobby_enter" );

	if (jump_to == "lobby_enter")		
		return;
	
	flag_set( "music_chk_elevator" );

	if (jump_to == "elevator")		
		return;

	flag_set( "music_chk_shaft" );

	if (jump_to == "shaft")		
		return;	

	flag_set( "music_chk_window" );

	if (jump_to == "window")		
		return;

	flag_set( "music_chk_hangar" );

	if (jump_to == "hangar")		
		return;	

	flag_set( "music_chk_lab_enter" );

	if (jump_to == "lab_enter")		
		return;

	flag_set( "music_chk_lab_to_vault" );

	if (jump_to == "lab_to_vault")		
		return;

	flag_set( "music_chk_vault" );

	if (jump_to == "vault")		
		return;
	
	flag_set( "music_chk_lab_exit" );

	if (jump_to == "lab_exit")		
		return;

	flag_set( "music_chk_halon" );

	if (jump_to == "halon")		
		return;

	flag_set( "music_chk_vtol" );

	if (jump_to == "vtol")		
		return;

	flag_set( "music_chk_rappel" );

	if (jump_to == "rappel")		
		return;

	flag_set( "music_chk_outro" );

	if (jump_to == "outro")		
		return;
	
}

player_elevator_ride_up_sfx()
{
	self playsound("scn_skyscraper_elevator_ride_inside");	
	self playsound("scn_skyscraper_elevator_ride_outside");	
	iprintlnbold("playing first sound!!!!!!!");

	flag_wait( "baker_exit_elevator_start" );
	wait 4.0;
	iprintlnbold("Fading Up!!!!!!!");
	self playsound("scn_skyscraper_elevator_ride_wind");	
	self SetSoundVolume( "scn_skyscraper_elevator_ride_outside", 25.0 ); //eventually this will have a time parameter

	trigger = GetEnt ("player_ready_for_elevator_lift", "targetname");
	trigger waittill ("trigger");

	wait 1.5;
	iprintlnbold("switching!!!!!!sounds!!!!!!!");
	self SetSoundVolume( "scn_skyscraper_elevator_ride_inside", -100.0 ); //eventually this will have a time parameter
	wait 0.3;
	self SetSoundVolume( "scn_skyscraper_elevator_ride_outside", 12.0 ); //eventually this will have a time parameter

}
