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

//#include maps\_utility;
//#include common_scripts\utility;
//#include maps\_anim;
//#include maps\_vehicle;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*
main()
{
	// External Initialization
	maps\mp_nx_fallout_precache::main();
	//maps\mp_nx_fallout_anim::main();
	maps\mp_nx_fallout_fx::main();
	maps\_load::main();

	// Internal Initialization
	mission_flag_inits();
	mission_precache();
}
*/

main()
{
	maps\mp\mp_nx_fallout_precache::main();
	maps\createart\mp_nx_fallout_art::main();
	maps\mp\mp_nx_fallout_fx::main();

	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap("compass_map_mp_nx_fallout");

	ambientPlay( "ambient_mp_default" );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";
}

// All mission specific PreCache calls
mission_precache()
{
}

// All mission specific flag_init() calls
mission_flag_inits()
{
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************