//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Lunar Audio		  											**
//                                                                          **
//    Created: 8/2/2011 - David Rowe										**
//                                                                          **
//****************************************************************************

//This is the mission's _audio.gsc
//All audio scripts should be put into this file

#include maps\_utility;
#include maps\_utility_code;
#include maps\_nx_objective_util;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


flag_inits()
{
	//DR: needed for music to trigger
	flag_init( "music_intro_rover_drive_starts" );
	flag_init( "music_intro_rover_drive_stops" );
	flag_init( "music_exited_rover" );
	flag_init( "music_charlie_reaches_tower_goal" );
	flag_init( "music_charlie_sees_lights" );
	flag_init( "music_rover_crashed" );
	flag_init( "music_player_wakes_up" );
	flag_init( "music_player_in_vehicle_airlock" );
	flag_init( "music_2nd_floor_breach_starts" );
	flag_init( "music_2nd_floor_breach_ends" );
	flag_init( "music_player_at_the_armory" );
	flag_init( "music_breach_starting" );
	flag_init( "music_start_battle_out_of_armory" );	
	flag_init( "music_player_arrived_at_airlock" );
	flag_init( "music_stop_airlock_ending" );
	flag_init( "music_battle_exterior" );
	flag_init( "music_moonscape_cue" );
	flag_init( "music_rover_battle_starts" );
	flag_init( "music_rover_battle_ends" );
	flag_init( "music_sneaking_behind_enemy" );
	flag_init( "music_end_stop_all" );
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
		case "get_to_the_armory":
		{						
			//start music for the intro wake up sequence
			flag_wait( "music_player_wakes_up" );
			if( !flag( "music_player_in_vehicle_airlock" ) )
			{
				wait 29;
			}
			play_music_once("music_nx_lunar_wake_up");
		
		
			//wait for airlock sequence to start, then restart music
			flag_wait( "music_player_in_vehicle_airlock" );
			if( !flag( "music_player_at_the_armory" ) )
			{
				wait 2;
			}	
			play_music_once("music_nx_lunar_run_thru_base");
		
			//stop the music for when the 2nd floor breach occurs
			flag_wait( "music_2nd_floor_breach_starts" );
			music_stop ( 0.5 );	
		
			//restart themusic for the rest of the chase thru the base
			flag_wait( "music_2nd_floor_breach_ends" );
			play_music_once("music_nx_lunar_run_thru_base_b");
			
			//now wait until you get to the armory
			flag_wait( "music_player_at_the_armory" );	
			if( !flag( "music_breach_starting" ) )
			{
				wait 4;
			}
			music_stop( 7 );

			//now wait until the breach is about to happen, must make this louder than the previous cue, separating for mix reasons
			flag_wait( "music_breach_starting" );
			if( !flag( "music_start_battle_out_of_armory" ) )
			{
				wait ( 7.6 );
			}
			play_music_once("music_nx_lunar_armory_buildup");
		}

		case "armory_module":
		case "life_support_module":
		case "living_module":
		{
			//now wait until the breach ccurs
			flag_wait( "music_start_battle_out_of_armory" );
			if( !flag( "music_player_arrived_at_airlock" ) )
			{
				wait ( 2 );
			}	
			play_music_num_times("music_nx_lunar_armory_fight", 2, 2);
			
		
			//wait until we get to pressurization lock and then play end stinger
			flag_wait( "music_player_arrived_at_airlock" );
			//cheating here, until we get the crossfading in...just playing overtop
			if( !flag( "music_stop_airlock_ending" ) )
			{
				//wait 1;
				music_stop( 3 );
				level._player play_sound_on_entity( "music_nx_lunar_armory_fight_end" );
			}
		}

		case "exterior_vista":
		case "airlock_exterior":
		case "mining_valley":
		case "rough_terrain":
		{
			//should start playing when the door starts opening to the exterior battle section
			flag_wait( "music_battle_exterior" );
			if( !flag( "music_rover_battle_starts" ) )
			{
				wait ( 1.1 );
			}
			play_music_once("music_nx_lunar_ext_battle");			
		}

		case "rover_battle":
		{
			//should start playing when the rover reveals itself
			flag_wait( "music_rover_battle_starts" );
			play_music_once("music_nx_lunar_rover_battle_gl");
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

	flag_set( "music_player_wakes_up" );

	if (jump_to == "get_to_the_armory")
		return;

	flag_set( "music_player_in_vehicle_airlock" );
	flag_set( "music_2nd_floor_breach_starts" );
	flag_set( "music_2nd_floor_breach_ends" );
	flag_set( "music_player_at_the_armory" );
	flag_set( "music_breach_starting" );			
	flag_set( "music_start_battle_out_of_armory" );				

	if (jump_to == "armory_module")		
		return;

	if (jump_to == "life_support_module")		
		return;

	if (jump_to == "living_module")		
		return;

	flag_set( "music_player_arrived_at_airlock" );
	
	if (jump_to == "exterior_vista")		
		return;

	flag_set( "music_stop_airlock_ending" );
	flag_set( "music_battle_exterior" );	

	if (jump_to == "airlock_exterior")		
		return;
	
	if (jump_to == "mining_valley")		
		return;
	
	if (jump_to == "rough_terrain")		
		return;
		
	if (jump_to == "rover_battle")		
		return;

}


