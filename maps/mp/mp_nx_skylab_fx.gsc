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
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\mp_nx_skylab_fx::main();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************