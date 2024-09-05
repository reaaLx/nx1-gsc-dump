//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Nx_Hospital - Hallway Second Floor							**
//                                                                          **
//    Created: 11/11/11 - 													**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


//*******************************************************************
//																	*
// Hallway Second Floor - Summary goes here							*
//																	*
//*******************************************************************
start()
{
	maps\nx_hospital_util::actor_teleport( level.squad[ "ALLY_ALPHA" ], "corridor_01_floor_02_alpha" );
	maps\nx_hospital_util::actor_teleport( level.squad[ "ALLY_BRAVO" ], "corridor_01_floor_02_bravo" );
	maps\nx_hospital_util::actor_teleport( level._player, "corridor_01_floor_02_player" );
//	issue_color_orders( "b100 g100", "allies" );
}

main()
{
	flag_wait( "corridor_01_second_floor_exit" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
section_precache()
{
}


section_flag_inits()
{
}
