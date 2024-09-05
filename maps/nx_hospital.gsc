//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Nx_Hospital													**
//                                                                          **
//    Created: 11/11/11 - Allen Freese										**
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
	// Add start points
	default_start(::intro_start );
	add_start( "intro",				::intro_start,				"Intro Vignette",			::intro );
	add_start( "hall_first_floor",	::hall_first_floor_start,	"Corridor 01, Floor 01",	::hall_first_floor );
	add_start( "hall_second_floor",	::hall_second_floor_start,	"Corridor 01, Floor 02",	::hall_second_floor );
	add_start( "construction",		::atrium_start,				"Construction",				::atrium );
	add_start( "exit_corridor",		::exit_corridor_start,		"Exit Corridor",			::exit_corridor );
	add_start( "assassination",		::assassination_start,		"Assassination",			::assassination );

	// External Initialization
	maps\nx_hospital_precache::main();
	maps\nx_hospital_fx::main();
	maps\_load::main();
	maps\nx_hospital_amb::main();
	maps\nx_hospital_anim::main();

	// Shootable pipes
	thread common_scripts\_pipes::main();

	// Dynamic cover
	maps\_dynamic_cover::main(); 

	// Offensive Grenades
	thread maps\nx_hospital_util::grenade_behavior();

	// Internal Initialization
	mission_flag_inits();
	mission_precache();

	//set timescale factors
	SoundSetTimeScaleFactor( "Music", 0 );

	// Mission threads
	level thread maps\nx_hospital_audio::mission_music();
	thread mission_objective_logic();

	// Setup mission squad
	mission_squad();
}

// All mission specific PreCache calls
mission_precache()
{
	PreCacheItem ("offensive_grenade");
	precacheString( &"NX_HOSPITAL_FAIL_OFFENSIVE_GRENADE" );
	maps\nx_hospital_hall_first_floor::section_precache();
	maps\nx_hospital_hall_second_floor::section_precache();
	maps\nx_hospital_atrium::section_precache();
	maps\nx_hospital_exit_corridor::section_precache();
}

// All mission specific flag_init() calls
mission_flag_inits()
{
	maps\nx_hospital_hall_first_floor::section_flag_inits();
	maps\nx_hospital_hall_second_floor::section_flag_inits();
	maps\nx_hospital_atrium::section_flag_inits();
	maps\nx_hospital_exit_corridor::section_flag_inits();

	maps\nx_hospital_audio::flag_inits();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

mission_squad()// SCRIPT_KEEP
{
	///// KEY /////
	// ALLY_ALPHA:		Alpha
	// ALLY_BRAVO:		Bravo
	
	maps\nx_hospital_util::squad_add_ally( "ALLY_ALPHA", 	"ally_alpha", 	"ally_alpha" );
	maps\nx_hospital_util::squad_add_ally( "ALLY_BRAVO", 	"ally_bravo", 	"ally_bravo" );
}


//*******************************************************************
//  OBJECTIVES                                                      *
//                                                                  *
//*******************************************************************

mission_objective_logic()
{
	// Wait for friendlies to spawn
	waittillframeend; 
	
	switch ( level._start_point )
	{
		case "default":
		case "intro":
		case "hall_first_floor":	
		case "hall_second_floor":
			objective_add( obj( "obj_infiltrate" ), "current", &"NX_HOSPITAL_OBJ_INFILTRATE" );
			flag_wait( "corridor_01_second_floor_exit" );
			Objective_State( obj( "obj_infiltrate" ), "done" );
		case "construction":
		case "exit_corridor":
			objective_add( obj( "obj_eliminate" ), "current", &"NX_HOSPITAL_OBJ_ELIMINATE_RESISTANCE" );
			flag_wait( "vignette_outro" );	
			Objective_State( obj( "obj_eliminate" ), "done" );
		case "assassination":
			objective_add( obj( "obj_capture" ), "current", &"NX_HOSPITAL_OBJ_CAPTURE_LEADER" );
			level waittill ("kill_orders_received");
			Objective_State( obj( "obj_capture" ), "failed" );
			objective_add( obj( "obj_kill" ), "current", &"NX_HOSPITAL_OBJ_KILL_LEADER" );
		case "no_game":
			break;
		default:
			AssertMsg( "No objectives set for this start point" );
	}
}

//*******************************************************************
//	Intro															*
//*******************************************************************
intro_start()
{
	maps\nx_hospital_hall_first_floor::start_intro();
}

intro()
{
	maps\nx_hospital_hall_first_floor::intro();	
}

//*******************************************************************
//	Hall First Floor												*
//*******************************************************************
hall_first_floor_start()
{
	maps\nx_hospital_hall_first_floor::start_floor_01();
}

hall_first_floor()
{
	maps\nx_hospital_hall_first_floor::main_floor_01();
}


//*******************************************************************
//	Hall Second Floor												*
//*******************************************************************
hall_second_floor_start()
{
	maps\nx_hospital_hall_first_floor::start_floor_02();
}

hall_second_floor()
{
	maps\nx_hospital_hall_first_floor::main_floor_02();
}


//*******************************************************************
//	Atrium															*
//*******************************************************************
atrium_start()
{
	maps\nx_hospital_atrium::start();
}

atrium()
{
	maps\nx_hospital_atrium::main();
}

//*******************************************************************
//	Exit Corridor													*
//*******************************************************************
exit_corridor_start()
{
	maps\nx_hospital_exit_corridor::start();
}

exit_corridor()
{
	maps\nx_hospital_exit_corridor::main();
}

//*******************************************************************
//	Assassination Sequence											*
//*******************************************************************
assassination_start()
{
	maps\nx_hospital_exit_corridor::assassination_start();
}

assassination()
{
	maps\nx_hospital_exit_corridor::assassination_main();
}
