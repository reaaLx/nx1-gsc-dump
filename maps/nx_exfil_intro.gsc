//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Skyscraper Exfil Intro Section								**
//                                                                          **
//    Created: 11/30/2011 - John Webb										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


//*******************************************************************
//                                                                  *
//	INTRO															*
//                                                                  *
//*******************************************************************
start()
{
	maps\nx_exfil_util::exfil_setup_allies( "market" );

	flag_set( "flag_exfil_intro_temp" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
main()
{
	battlechatter_off( "allies" );

	level thread intro_dialogue();
	level thread intro_sfx();
	level thread start_limp();
	flag_wait( "flag_exfil_intro_player_door" );
	level._player playsound( "scn_exfil_van_exit_front" );
	level._player deactivatechannelvolumes( "snd_channelvolprio_level", 1.0 );

	flag_set( "intro_ended" );  // Kick off market logic
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Called from nx_exfil.gsc
flag_inits()
{
	flag_init( "intro_dialogue_complete" );
	flag_init( "intro_ended" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
start_limp()
{	
	level endon( "swat_encounter_start" ); 

	level waittill( "introscreen_complete" );

	friend_name = level.baker.name;
	level.baker.name = undefined;

	// Add some blur as the player is waking up.
	thread maps\nx_exfil_util::player_random_blur( 15, 3 );

	level waittill( "exfil_intro_spawn_finished" );

	//player now has control, lets do some stumble and some blur. Don't decay though.
	thread maps\nx_exfil_util::stumble_walk( 0.18, 6.0, 0.0, 1/1200, undefined, true );

	level waittill( "exfil_intro_player_door_finished" );

	//display baker's friend name again.
	level.baker.name = friend_name;

	//now the player has exited the van, don't stumble or blur, but still walk slow.
	thread maps\nx_exfil_util::stumble_walk( 0.35, 8.0, 0.0, 1/1200, true );

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
intro_dialogue()
{
	wait 14.9;
	level.baker radio_dialogue( "exf_bak_van_youok" ); // Walker, you ok?
	wait 1.25;
	level.baker radio_dialogue( "exf_bak_van_gottago" ); // We gotta get scarce.
	//wait 1.8;

	flag_wait( "radio_exfil_begin" ); // Waiting for Baker to get into position

	//level.baker radio_dialogue( "exf_bak_van_needexfil" ); // Overlord, we need an exit NOW!
	level.baker radio_dialogue( "exf_bak_intro_requestingexfil" ); // Overlord, Whiskey acquired, requesting exfil
	//add_dialogue_line( "OVERLORD", "Zulu Birds are 5 marks out.  Recommend exfil north-northwest.", "yellow", 3.0 );
	radio_dialogue( "exf_ovl_van_zulubird" );
	
	level.baker radio_dialogue( "exf_bak_van_solidcopy" ); // Solid copy Overlord.  Out.  

	wait 1.2;

	//level.baker radio_dialogue( "exf_bak_intro_switchingtomic" ); //switching to mic
	//radio_dialogue( "exf_bak_van_easyday" );

	flag_set( "intro_dialogue_complete" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
intro_sfx()
{
	exfil_intro_sfx = spawn( "sound_emitter", ( 0, 0, 1 ) );
	exfil_intro_sfx PlaySound( "scn_exfil_intro" );
	thread emitter_sounds();
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_exfil_intro", 0.1 );
	wait 9.5;
	thread maps\_utility::set_ambient( "nx_exfil_amb01" );
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_exfil_intro", 0.1 );
	
}

emitter_sounds()
{

	level.dogs_barking = spawn( "sound_emitter", ( 3600, 1240, 260 ) );
	level.dogs_barking PlayloopSound( "emt_exfil_dogs" );
	engine_cool = spawn( "sound_emitter", ( -670, -2660, 40 ) );
	engine_cool PlayloopSound( "emt_exfil_engine_cool" );
	car_alarm_sfx = spawn( "sound_emitter", ( -600, -3700, 34 ) );
	car_alarm_sfx PlayloopSound( "emt_exfil_car_alarm" );
	wait 5;
	engine_cool setsoundvolume( "emt_exfil_engine_cool", 0, 5 );
	car_alarm_sfx setsoundvolume( "emt_exfil_car_alarm", 7, 5 );

}
