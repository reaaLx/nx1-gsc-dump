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
#include maps\_nx_objective_util;
#include maps\nx_hithard_util;



flag_inits()
{
	//DR: needed for music cues
	flag_init( "music_osprey_intro" );
	flag_init( "music_parachute_start" );
	flag_init( "music_parachute_ends" );
	flag_init( "music_rooftop_battle_starts");
	flag_init( "music_snipe_ends" );
	flag_init( "music_smoke_battle_starts" );
	flag_init( "music_smoke_battle_ends" );
	flag_init( "music_run_from_ugv" );
	flag_init( "music_run_from_ugv_ends" );
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
		case "osprey":
		{						
			flag_wait( "music_osprey_intro" );
			wait (0.75);
			play_music_once( "music_nx_hithard_osprey_intro" );
		}

		case "parachute":
		{
			flag_wait( "music_parachute_start" );			
			wait 2.5;
			play_music_once( "music_nx_hithard_parachute" );
			flag_wait( "music_parachute_ends" );
			music_stop(12);
		}

		case "rooftop":
		case "secure_start":
		{
			flag_wait( "music_rooftop_battle_starts");
			play_music_loop_infinite( "music_nx_hithard_rooftop" );		
			flag_wait( "music_snipe_ends" );			
			music_stop(10);
		}

		case "secure_rappel":
		case "secure_ground":
		{
			flag_wait( "music_smoke_battle_starts" );
			play_music_loop_infinite( "music_nx_hithard_rooftop" );
			flag_wait( "music_smoke_battle_ends" );			
			if( !flag( "music_run_from_ugv" ) )
			{
				wait ( 1 );
			}
			music_stop(1);		
			if( !flag( "music_run_from_ugv" ) )
			{
				wait ( 1.6 );
			}
			play_music_once( "music_nx_hithard_finish_smoke" );
		}		

		case "motorcade_start":
		{
			flag_wait( "music_run_from_ugv" );
			wait 2;
			play_music_once( "music_nx_hithard_ugv_run" );
		}

		case "motorcade_end":
		{
			//do nothing.
		}		
	}
}

jump_to_music_flag_setup()
{
	jump_to = level._start_point;
	
	// Return if this is the current checkpoint
	// Thus, sets all flags up to a given checkpoint
	if (jump_to == "default")
		return;

	if (jump_to == "osprey")
		return;

	flag_set( "music_osprey_intro" );

	if (jump_to == "parachute")		
		return;
	
	flag_set( "music_parachute_start" );
	flag_set( "music_parachute_ends" );
	flag_set( "music_rooftop_battle_starts" );

	if (jump_to == "rooftop")		
		return;

	if (jump_to == "secure_start")		
		return;

	flag_set( "music_snipe_ends" );	

	if (jump_to == "secure_rappel")		
		return;

	if (jump_to == "secure_ground")		
		return;	

	flag_set( "music_smoke_battle_starts" );
	flag_set( "music_smoke_battle_ends" );

	if (jump_to == "motorcade_start")		
		return;
}
