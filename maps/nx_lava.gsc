//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  MISSION DESCRIPTION											**
//                                                                          **
//    Created: DATE - CREATOR												**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main()
{
	// Starts
	default_start( ::train_interior );

	// tagBK<NOTE> Changed for tuesday tech presentation of moving platforms. 
	set_default_start( "train_1" );

	add_start( "outpost", 				::outpost_start, 				"Outpost", 	 		::outpost );
	add_start( "garage", 				::garage_start, 				"Garage", 	 			::garage );
	add_start( "platform_tower",		::platform_tower_start, 		"Platform Tower", 		::platform_tower );
	add_start( "station_1", 			::station_1_start, 			"Station 1", 			::station_1 );
	add_start( "s1_command_center", 	::s1_command_center_start, 	"Command Center", 		::s1_command_center );
	add_start( "train_1", 				::train_1_start, 				"Train 1", 	 		::train_1 );
	add_start( "station_2", 			::station_2_start,				"Station 2", 			::station_2 );
	add_start( "station_2_arrive",		::station_2_arrive_start,		"Station 2 Arrive",	::station_2_arrive );
	add_start( "bridge_to_train",		::bridge_to_train_start,		"Bridge to Train",		::bridge_to_train );
	// tagDK<hack> - Removed add_start string (Train Interior) to stop it from showing for greenlight
	add_start( "train_interior", 		::train_interior_start,		"", 		::train_interior );
	add_start( "train_interior_front",	::train_interior_front_start,	"Train Interior Front", ::train_interior_front );
	add_start( "train_2", 				::train_2_start,				"Train 2", 			::train_2 );
	add_start( "train_2_skimmers", 		::train_2_skimmers_start,		"Train 2 Skimmers",	::train_2_skimmers );
	add_start( "derail", 				::train_derail_start,			"Derail",		 		::train_derail );

	// External Initialization
	maps\nx_lava_precache::main();
	maps\nx_lava_fx::main();
	maps\_moon_actor::main();
	huds = [];
	huds[huds.size] = "hud_lunar";
	maps\_load::main( huds );
	maps\_moon::main();
	maps\nx_lava_anim::main();

	// tagTC<note> - this main has a blocker wait, need to 
	// check with audio to see if they can remove it.
	maps\nx_lava_amb::main(); // TagBM<note>: removed thread to make sure level vars are initialized before being used

	// Internal Initialization
	mission_flag_inits();
	mission_precache();
	
	// Vision Set Init
	level thread maps\nx_lava_fx::vision_set_main();

	//set timescale factors
	SoundSetTimeScaleFactor( "Music", 0 );
	SoundSetTimeScaleFactor( "Vignette2d", 0);
	SoundSetTimeScaleFactor( "menu", 0);
	SoundSetTimeScaleFactor( "nx_verb3d", 0);

	// Hide all trains
	init_and_hide_all_trains();
 
	// Mission threads
	level thread mission_objectives();
	level thread mission_player_thread();
	//thread the music script
	level thread maps\nx_lava_audio::mission_music();		

	// Per section main
	level thread maps\nx_lava_outpost::section_main();
	level thread maps\nx_lava_station_1::section_main();
	level thread maps\nx_lava_train_1::section_main();
	level thread maps\nx_lava_station_2::section_main();
	level thread maps\nx_lava_train_interior::section_main();
	level thread maps\nx_lava_train_2::section_main();
	level thread maps\nx_lava_train_derail::section_main();

	// Falling death trigger
	level thread falling_death_trigger();
	
	// Setup Explosives
	thread maps\nx_lava_util::explodables_init();

	CreateThreatBiasGroup( "player" );
	CreateThreatBiasGroup( "ambusher" );
	level._player SetThreatBiasGroup( "player" );
	
	// Check IPrintlnBold triggers
	// level thread maps\nx_lava_util::IPrintlnBold_triggers();

	// In Lava, movers do not push other entities.  This is a significant optimization due to the large number
	// of movers in Lava, especially in train-interior where movers surround the encounter.
	SetSavedDvar( "g_mover_no_push", 1 );
}

// All mission specific PreCache calls
mission_precache()
{
	// Per section precache
	level thread maps\nx_lava_outpost::section_precache();
	level thread maps\nx_lava_station_1::section_precache();
	level thread maps\nx_lava_train_1::section_precache();
	level thread maps\nx_lava_station_2::section_precache();
	level thread maps\nx_lava_train_interior::section_precache();
	level thread maps\nx_lava_train_2::section_precache();
	level thread maps\nx_lava_train_derail::section_precache();
}										

// All mission specific flag_init() calls
mission_flag_inits()
{
	// Per section flag init
	level thread maps\nx_lava_outpost::section_flag_inits();
	level thread maps\nx_lava_station_1::section_flag_inits();
	level thread maps\nx_lava_train_1::section_flag_inits();
	level thread maps\nx_lava_station_2::section_flag_inits();
	level thread maps\nx_lava_train_interior::section_flag_inits();
	level thread maps\nx_lava_train_2::section_flag_inits();
	level thread maps\nx_lava_train_derail::section_flag_inits();

	// Anim flag_init
	level thread maps\nx_lava_anim::section_flag_inits();

	// Audio flag_init
	maps\nx_lava_audio::flag_inits();
}

mission_player_thread()
{
}

mission_objectives()
{
	// Wait for friendlies to spawn
	waittillframeend; 
	
	// README: wait_for_objective
	// maps\_nx_objective_util::wait_for_objective( objective_num, objective_text, curr_trigger, next_trigger );
 	// curr_trigger - the start point trigger of the objective
	// next_trigger - the end point trigger of the objective 
	// Uses script_origin nodes for pathing ( be sure to have a radius on the nodes )	
	
	objective_num = 0;
	switch ( level._start_point )
	{
		case "default":
		case "outpost":
			objective_num = maps\nx_lava_outpost::outpost_objectives( objective_num );
		case "garage":
			objective_num = maps\nx_lava_outpost::garage_objectives( objective_num );
		case "platform_tower":
			objective_num = maps\nx_lava_station_1::platform_tower_objectives( objective_num );
		case "station_1":			
			objective_num = maps\nx_lava_station_1::station_1_objectives( objective_num );
		case "s1_command_center":			
			objective_num = maps\nx_lava_station_1::s1_command_center_objectives( objective_num );
		case "train_1":
			objective_num = maps\nx_lava_train_1::section_objectives( objective_num );
		case "station_2":
		case "station_2_arrive":
		case "bridge_to_train":
			objective_num = maps\nx_lava_station_2::section_objectives( objective_num );
		case "train_interior":
		case "train_interior_front":
			objective_num = maps\nx_lava_train_interior::section_objectives( objective_num );
		case "train_2":
			objective_num = maps\nx_lava_train_2::section_objectives( objective_num );
		case "derail":
			objective_num = maps\nx_lava_train_derail::section_objectives( objective_num );
	}
}

//*******************************************************************
//                                                                  *
//*******************************************************************

falling_death_trigger()
{
	flag_wait( "player_falling_death" );
	
	SetSavedDvar( "compass", "0" );
	SetSavedDvar( "ammoCounterHide", 1 );
	SetSavedDvar( "actionSlotsHide", 1 );
	SetSavedDvar( "hud_showStance", 0 );
	//SetSavedDvar( "hud_drawhud", 0 );


	VisionSetNaked( "black_bw", 2.5 );
	wait( 2.5 );
	level._player PlayRumbleOnEntity( "falling_land" );
	wait( 0.5 );

	level._player Kill();
}

//*******************************************************************
//                                                                  *
//*******************************************************************

init_and_hide_all_trains()
{
	// Train 2 Interior
	level.train_interior = maps\_nx_moving_platform::init( "train_2", 30 );

	// Hide Train 2 Interior
	if( IsDefined( level.train_interior ) ) 
		level.train_interior maps\_nx_moving_platform::platform_hide();

	// Link Train 2 Interior to its vehicle 
	level.train_interior_vehicle = getEnt( "train_2_vehicle", "targetname" );
	if( IsDefined( level.train_interior_vehicle ) ) 
		level.train_interior maps\_nx_moving_platform::link_platform_to_vehicle( level.train_interior_vehicle );
	
	
	// Spawn and hide Train 2 Turret
	level.train_turret = maps\nx_lava_util::setup_train_by_name( "train_2_front" );
	maps\nx_lava_util::show_hide_train( level.train_turret, "hide" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

outpost_start()
{
	maps\nx_lava_outpost::outpost_start();
}

outpost()
{
	maps\nx_lava_outpost::outpost();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

garage_start()
{
	maps\nx_lava_outpost::garage_start();	
}

garage()
{
	//temp music_chk flag
	flag_set( "music_chk_garage" );
	maps\nx_lava_outpost::garage();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

platform_tower_start()
{
	maps\nx_lava_station_1::platform_tower_start();
}

platform_tower()
{
	//temp music_chk flag
	flag_set( "music_chk_platform_tower" );
	maps\nx_lava_station_1::platform_tower();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

station_1_start()
{
	maps\nx_lava_station_1::station_1_start();
}

station_1()
{
	//temp music_chk flag
	flag_set( "music_chk_station_1" );
	maps\nx_lava_station_1::station_1();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

s1_command_center_start()
{
	maps\nx_lava_station_1::s1_command_center_start();
}

s1_command_center()
{
	//temp music_chk flag
	flag_set( "music_chk_station_1" );
	maps\nx_lava_station_1::s1_command_center();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_1_start()
{
	maps\nx_lava_train_1::train_1_start();
}

train_1()
{
	//temp music_chk flag
	flag_set( "music_chk_train_1" );
	maps\nx_lava_train_1::train_1();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

station_2_start()
{
	maps\nx_lava_station_2::station_2_start();
}

station_2()
{
	//temp music_chk flag
	flag_set( "music_chk_station_2" );
	maps\nx_lava_station_2::station_2();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

station_2_arrive_start()
{
	maps\nx_lava_station_2::station_2_arrive_start();
}

station_2_arrive()
{
	//temp music_chk flag
	flag_set( "music_chk_station_2_arrive" );
	maps\nx_lava_station_2::station_2_arrive();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

bridge_to_train_start()
{
	maps\nx_lava_station_2::bridge_to_train_start();
}

bridge_to_train()
{
	maps\nx_lava_station_2::bridge_to_train();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_interior_start()
{
	maps\nx_lava_train_interior::train_interior_start();
}

train_interior()
{
	//temp music_chk flag
	flag_set( "music_chk_train_interior" );
	maps\nx_lava_train_interior::train_interior();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_interior_front_start()
{
	maps\nx_lava_train_interior::train_interior_front_start();
}

train_interior_front()
{
	maps\nx_lava_train_interior::train_interior_front();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_2_start()
{
	maps\nx_lava_train_2::train_2_start();
}

train_2()
{
	//temp music_chk flag
	flag_set( "music_chk_train_2" );
	maps\nx_lava_train_2::train_2();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_2_skimmers_start()
{
	maps\nx_lava_train_2::train_2_skimmers_start();
}

train_2_skimmers()
{
	//temp music_chk flag
	flag_set( "music_chk_train_2_skimmers" );
	maps\nx_lava_train_2::train_2_skimmers();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_derail_start()
{
	maps\nx_lava_train_derail::train_derail_start();
}

train_derail()
{
	// tagTC<note> - temp fix to delay train derail music flag
	level thread train_derail_thread();
	maps\nx_lava_train_derail::train_derail();
}

train_derail_thread()
{
	flag_wait( "vignette_train_derailment" );
	flag_set( "music_chk_derail" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************