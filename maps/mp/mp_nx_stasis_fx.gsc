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

	level._effect[ "snow_light" ]		 = loadfx( "snow/snow_light_mp_stasis" );
	level._effect[ "snow_wind" ]		 = loadfx( "snow/snow_wind" );

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\mp_nx_stasis_fx::main();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************