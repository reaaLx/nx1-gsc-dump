//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Audio Support												**
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
#include maps\nx_exfil_util;



flag_inits()
{
	//DR: needed for music cues
	//examples, for copying and pasting:

	flag_init( "music_intro" );
	flag_init( "music_market_start" );
	flag_init( "music_market_end" );
	flag_init( "music_street_start" );
	flag_init( "music_street_end" );

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

		}

		case "market":
		{
			flag_wait( "music_market_start" );
			wait 4.0;
			//iprintlnbold ( "MUSIC MARKET START" );
			play_music_loop_infinite("mus_nx_exfil_battle_01");
			//flag_wait ( "music_market_end" );
			//music_stop (2);
		}

		case "street":
		{
			flag_wait( "music_street_start" );
			//wait 2.5;
			//iprintlnbold ( "MUSIC STREET START" );
			play_music_loop_infinite("mus_nx_exfil_battle_02");
			flag_wait ( "music_street_end" );
			//iprintlnbold ( "MUSIC STREET END" );
			music_stop (7);
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
	
	flag_set( "music_intro" );

	if (jump_to == "default")
		return;

	if (jump_to == "intro")
		return;

	if (jump_to == "market")
		return;
	
	flag_set( "music_street_start" );

	if (jump_to == "street")
		return;
}


police_bullhorn_vo()
{
	self endon( "death" );
	
	wait 2.0;

	xfade_time = 2.0;
	soundent = spawn( "sound_emitter", self.origin );
	soundent linkto( self );

	soundent1 = spawn( "sound_emitter", self.origin );
	soundent1 linkto( self );

	soundent2 = spawn( "sound_emitter", self.origin );
	soundent2 linkto( self );

	soundent playloopsound("emt_exfil_helicopter_speaker");
	soundent1 playloopsound("emt_exfil_helicopter_speaker_close");
	soundent2 playloopsound("emt_exfil_helicopter_speaker_baker");

	thread police_bullhorn_vo_cleanup( soundent, soundent1, soundent2 );

	while ( 1 )
	{
		if ( self.spotTarget == level._player )
		{
			//iprintlnbold("Found The Player!!!!!");
			soundent  setsoundvolume( "emt_exfil_helicopter_speaker", -100, xfade_time );
			soundent1 setsoundvolume( "emt_exfil_helicopter_speaker_close", 3, xfade_time );
			soundent2 setsoundvolume( "emt_exfil_helicopter_speaker_baker", -100, xfade_time );
		}
		else if ( self.spotTarget == level.allies[ "ally1" ] )
		{
			//iprintlnbold("Found Baker!!!!!");
			soundent setsoundvolume( "emt_exfil_helicopter_speaker", -100, xfade_time );
			soundent1 setsoundvolume( "emt_exfil_helicopter_speaker_close", -100, xfade_time );
			soundent2 setsoundvolume( "emt_exfil_helicopter_speaker_baker", -3, xfade_time );
		}
		else //play the distant loop
		{
			//iprintlnbold("Who? Where?!?!?!?");
			soundent setsoundvolume( "emt_exfil_helicopter_speaker", -3, xfade_time );
			soundent1 setsoundvolume( "emt_exfil_helicopter_speaker_close", -100, xfade_time );
			soundent2 setsoundvolume( "emt_exfil_helicopter_speaker_baker", -100, xfade_time );
		}

		wait xfade_time + 0.7;
  	}


}

police_bullhorn_vo_cleanup( soundent, soundent1, soundent2 )
{
	self waittill ( "death" );
	//iprintlnbold("killing sound due helo death!");	


	soundent setsoundvolume( "emt_exfil_helicopter_speaker", -100, 0.1 );
	soundent1 setsoundvolume( "emt_exfil_helicopter_speaker_close", -100, 0.1 );
	soundent2 setsoundvolume( "emt_exfil_helicopter_speaker_baker", -100, 0.1 );
	
	wait 0.11;

	soundent StopLoopSound( "emt_exfil_helicopter_speaker" );
	soundent1 StopLoopSound( "emt_exfil_helicopter_speaker_close" );
	soundent2 StopLoopSound( "emt_exfil_helicopter_speaker_baker" );

	soundent delete();
	soundent1 delete();
	soundent2 delete();
}

police_bullhorn_vo_end( soundent, soundent1, soundent2 )
{
	//self waittill ( "market_enc_end" );
	//iprintlnbold("killing sound!");	
	if ( IsDefined( level._spotlight_heli ) )
	{
		soundent setsoundvolume( "emt_exfil_helicopter_speaker", -100, 0.1 );
		soundent1 setsoundvolume( "emt_exfil_helicopter_speaker_close", -100, 0.1 );
		soundent2 setsoundvolume( "emt_exfil_helicopter_speaker_baker", -100, 0.1 );
		
		wait 0.11;
		soundent StopLoopSound( "emt_exfil_helicopter_speaker" );
		soundent1 StopLoopSound( "emt_exfil_helicopter_speaker_close" );
		soundent2 StopLoopSound( "emt_exfil_helicopter_speaker_baker" );
	
		soundent delete();
		soundent1 delete();
		soundent2 delete();
 	}
}

police_car_radio_chatter()
{
	soundent = spawn( "sound_emitter", self.origin );
	soundent linkto( self );

	soundent playloopsound("emt_police_car_radio_chatter");

	self waittill ( "death" );

	soundent StopLoopSound( "emt_police_car_radio_chatter" );
	soundent playloopsound("emt_police_car_radio_static");

}

police_barricade_warning_vo()
{

	self waittill( "trigger" );

	barricade_cars = get_vehicle_array( "barricade_cars", "targetname" );

	if ( isdefined( barricade_cars[0] ) )
	{
		barricade_cars[0] playsound("exf_cop_barri_surrender");
		barricade_cars[0] endon( "death" );
	
		wait 6;
		
		barricade_cars[0] playsound("exf_cop_barri_shootyou");
	}
}
