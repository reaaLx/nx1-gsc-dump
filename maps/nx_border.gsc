//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Mexican Border Combat Mission								**
//                                                                          **
//    Created: Created: 11/11/11 - Travis Chen (trchen x 4143)				**
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
	default_start( ::border_start );

	// Jump-To Points
	add_start( "border", 	::border_start, 	"Border", 	 	::border );
	add_start( "streets", 	::streets_start, 	"Streets", 	 	::streets );
	add_start( "market",	::market_start, 	"Market", 		::market );
	add_start( "church", 	::church_start, 	"Church", 		::church );

	// Internal Initialization
	mission_flag_inits();
	mission_precache();
	
	// Door anims
	maps\_hiding_door_anims::main();

	// Heli boss
	maps\_attack_heli::preLoad();
	
	// External Initialization
	maps\nx_border_precache::main();
	maps\nx_border_fx::main();
	maps\_load::main();
	maps\nx_border_anim::main();
	
	// Objectives
	level thread mission_objectives();

	//set timescale factors
	SoundSetTimeScaleFactor( "Music", 0 );

	// Helicopter Support
	maps\_helicopter_support::startHeliSupport( 1 );

	// Ally Setup
	maps\nx_border_util::leader_spawner_setup();
	maps\nx_border_util::ally_spawner_setup();
	
	// Mission threads
	level thread maps\nx_border_audio::mission_music();
	
	maps\nx_border_amb::main();

	// Per section main
	// level thread maps\nx_border_border::section_main();
	level thread maps\nx_border_streets::section_main();
	level thread maps\nx_border_market::section_main();
	// level thread maps\nx_border_church::section_main();
}

// All mission specific PreCache calls
mission_precache()
{
	// Per section precache
	level thread maps\nx_border_border::section_precache();
	level thread maps\nx_border_streets::section_precache();
	level thread maps\nx_border_market::section_precache();
	level thread maps\nx_border_church::section_precache();
	
	// Precache Helicopter Support
	level thread maps\_helicopter_support::precacheHeliSupport();
}										

// All mission specific flag_init() calls
mission_flag_inits()
{
	// Per section flag init
	level thread maps\nx_border_border::section_flag_inits();
	level thread maps\nx_border_streets::section_flag_inits();
	level thread maps\nx_border_market::section_flag_inits();
	level thread maps\nx_border_church::section_flag_inits();
	level thread maps\nx_border_anim::section_flag_inits();

	//music flag inits
	level thread maps\nx_border_audio::flag_inits();

	//vo flag init for border-to-streets transition
	flag_init( "vo_border_section_done");


}

mission_objectives()
{
	// Wait for friendlies to spawn
	waittillframeend; 
	
	objective_num = 0;
	switch ( level._start_point )
	{
		case "default":
		case "border":
			objective_num = maps\nx_border_border::section_objectives( objective_num );
		case "streets":
			objective_num = maps\nx_border_streets::section_objectives( objective_num );
		case "market":
			objective_num = maps\nx_border_market::section_objectives( objective_num );
		case "church":			
			objective_num = maps\nx_border_church::section_objectives( objective_num );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

border_start()
{
	maps\nx_border_border::border_start();	
}

border()
{
	maps\nx_border_border::border();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

streets_start()
{
	maps\nx_border_streets::streets_start();
}

streets()
{
	maps\nx_border_streets::streets();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

market_start()
{
	maps\nx_border_market::market_start();	
}

market()
{
	maps\nx_border_market::market();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

church_start()
{
	maps\nx_border_church::church_start();	
}

church()
{
	maps\nx_border_church::church();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
