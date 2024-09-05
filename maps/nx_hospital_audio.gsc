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
#include maps\nx_hospital_util;



flag_inits()
{
	//DR: needed for music cues
	//examples, for copying and pasting:
	
	flag_init( "music_intro" );
	flag_init( "music_stealth02" );
	flag_init( "music_2" );
	flag_init( "music_3" );
	flag_init( "music_4" );
	flag_init( "hvt_killed" );
	heli_pass_trig = GetEnt( "heli_sfx_trigger", "targetname" );
	heli_pass_trig thread helicopter_pass_sfx();
	thread heartmonitor_sfx();
}

heartmonitor_sfx()
{
	level waittill( "heart_beat_monitor_start" ); //delay so that this doesn't execute during level load.
	wait 0.1;
	soundorg = spawn( "sound_emitter", ( -3881, -1324, 68 ) );
	soundorg PlayLoopSound( "hos_heartmonitor_sfx" );
	flag_wait( "hvt_killed" );
	soundorg StopLoopSound( "hos_heartmonitor_sfx" );
	wait 0.05;
	soundorg PlaySound( "hos_heartfail_sfx" );
}

hos_outro_docpush_sfx()
{
	wait 4.5;
	self PlaySound( "scn_hos_outro_docpush" );
}

helicopter_pass_sfx()
{
	self waittill( "trigger" );
	wait 1.5;
	level._player PlaySound( "elm_hos_heli_pass" );
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
			flag_wait( "music_intro" );
			wait 7.8;
			play_music_once( "mus_hos_1stfloor01" );
		case "hall_first_floor":
		{
			flag_wait( "music_stealth02" );		
			play_music_once( "mus_hos_1stfloor02" );
			//play_music_loop_infinite("mus_lava_intro");
			//play_music_loop_infinite("mus_lava_intro");
			//play_music_num_times("mus_lava_intro", 2, 2);
		}

		case "hall_second_floor":
		{
			wait 2;
			//play_music_once( "mus_hospital_stealthdone" );
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
	//flag_set( "music_chk_[chk1]" );
	if (jump_to == "default")
		return;

	if (jump_to == "intro")
		return;

	if (jump_to == "hall_first_floor")
		return;

	flag_set( "music_intro" );
	flag_set( "music_stealth02" );

	if (jump_to == "hall_second_floor")
		return;
	

}
