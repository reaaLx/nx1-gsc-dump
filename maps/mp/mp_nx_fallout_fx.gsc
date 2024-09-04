//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  FX Support													**
//                                                                          **
//    Created: DATE - CREATOR												**
//                                                                          **
//****************************************************************************

main()
{

	//level._effect[ "ash_aftermath_ugv_mp" ]		 	= loadfx( "weather/ash_aftermath_ugv_mp" );
	level._effect[ "tank_fire_hatch" ]			 	= loadfx( "fire/tank_fire_hatch" );
	level._effect[ "nx_mp_fallout_steam_jet" ]		= loadfx( "nx/mp/steam/nx_mp_fallout_steam_jet" );
	level._effect[ "nx_mp_fallout_steam_filler" ]	= loadfx( "nx/mp/steam/nx_mp_fallout_steam_filler" );
	level._effect[ "nx_mp_ash_aftermath_fallout" ]	= loadfx( "nx/mp/weather/nx_mp_ash_aftermath_fallout" );
	level._effect[ "battlefield_smokebank_S_warm_thick" ]	= loadfx( "smoke/battlefield_smokebank_S_warm_thick" );

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\mp_nx_fallout_fx::main();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************