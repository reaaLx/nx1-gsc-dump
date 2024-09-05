
//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Skyscraper Exfil Alley Section								**
//                                                                          **
//    Created: 12/8/2011 - John Webb										**
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
	maps\nx_exfil_util::exfil_setup_allies( "alley" );
	maps\nx_exfil_util::player_start( "alley_player" );
	exploder ( "hallway_pre" );
	maps\nx_exfil_fx::fx_set_hall_spot_params();

	flag_set( "street_enc_end" );
	battlechatter_off( "allies" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
main()
{
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Called from nx_exfil.gsc
flag_inits()
{
}
