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
	level._effect[ "fog_ground_200" ]						= loadfx( "weather/fog_ground_200" );
	level._effect[ "mist" ]						= loadfx( "weather/mist_hunted_add" );
	level._effect[ "mist2" ]						= loadfx( "weather/mist_icbm" );
	level._effect[ "cloudbank" ]						= loadfx( "weather/cloud_bank" );
	level._effect[ "cloudfiller" ]						= loadfx( "weather/cloud_bank_cloud_filler_gulag" );
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\mp_nx_meteor_fx::main();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
=�"maps/createfx/mp_nx_meteor_fx.gsc//_createfx generated. Do not touch!!
#include common_scripts\utility;
#include common_scripts\_createfx;
main()
{
	// CreateFX entities size: 77
	ent = createOneshotEffect( "fog_ground_200" );
	ent.v[ "origin" ] = ( -180.341, -175.433, 258 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "fog_ground_200";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "fog_ground_200" );
	ent.v[ "origin" ] = ( 762.07, 1084.98, 216 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "fog_ground_200";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "fog_ground_200" );
	ent.v[ "origin" ] = ( -123.904, 924.534, 259.405 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "fog_ground_200";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "mist" );
	ent.v[ "origin" ] = ( 910.028, 1358.37, 216 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "mist";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "mist" );
	ent.v[ "origin" ] = ( 1240.9, 1221.17, 216 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "mist";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "mist" );
	ent.v[ "origin" ] = ( 828.875, 914.303, 216 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "mist";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "mist2" );
	ent.v[ "origin" ] = ( 585.75, 1319.23, 223.397 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "mist2";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "cloudbank" );
	ent.v[ "origin" ] = ( -813.373, -13200.1, 5602.79 );
	ent.v[ "angles" ] = ( 272, 270, 90 );
	ent.v[ "fxid" ] = "cloudbank";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "cloudbank" );
	ent.v[ "origin" ] = ( -6270.18, -10989.7, 4598.52 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "cloudbank";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "cloudbank" );
	ent.v[ "origin" ] = ( -10712.5, -10167.8, 5328.67 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "cloudbank";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "cloudbank" );
	ent.v[ "origin" ] = ( -13140.7, -7878.57, 5281.98 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "cloudbank";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "cloudbank" );
	ent.v[ "origin" ] = ( -12820.9, -5366.55, 4431.58 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "cloudbank";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "cloudbank" );
	ent.v[ "origin" ] = ( -14618.8, -4503.89, 4607.65 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "cloudbank";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "cloudbank" );
	ent.v[ "origin" ] = ( -13874.1, -297.337, 3321.88 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "cloudbank";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "cloudbank" );
	ent.v[ "origin" ] = ( -6800.44, -6240.07, 3175.94 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "cloudbank";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "cloudbank" );
	ent.v[ "origin" ] = ( -9526.73, -4589.14, 3440.72 );
	ent.v[ "angles" ] = ( 274, 90, -90 );
	ent.v[ "fxid" ] = "cloudbank";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "cloudbank" );
	ent.v[ "origin" ] = ( -6902.65, -8022.34, 3902.24 );
	ent.v[ "angles" ] = ( 290, 90, -90 );
	ent.v[ "fxid" ] = "cloudbank";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "cloudbank" );
	ent.v[ "origin" ] = ( -3144.96, -11236, 4049.97 );
	ent.v[ "angles" ] = ( 272, 90, -90 );
	ent.v[ "fxid" ] = "cloudbank";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "cloudfiller" );
	ent.v[ "origin" ] = ( -17854.8, -10706, 5865.46 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "cloudfiller";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "cloudfiller" );
	ent.v[ "origin" ] = ( -16814.3, 86.6709, 5390.72 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "cloudfiller";
	ent.v[ "delay" ] = -15;

	ent = createOneshotEffect( "cloudfiller" );
	ent.v[ "origin" ] = ( -2756.2, -18327.4, 6573.81 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "cloudfiller";
	ent.v[ "delay" ] = -15;

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 0, 392, -63.9 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf138_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 0, 394, -65.9 );
	ent.v[ "angles" ] = ( 281.421, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf138_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 144, 539, -65.9 );
	ent.v[ "angles" ] = ( 286.858, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf139_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 144, 536, -63.9 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf139_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( -192, 139, -66 );
	ent.v[ "angles" ] = ( 0, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf144_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( -192, 136, -64 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf144_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 192, 139, -66 );
	ent.v[ "angles" ] = ( 0, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf145_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 192, 136, -64 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf145_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 0, 392, -63.9 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf138_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 0, 394, -65.9 );
	ent.v[ "angles" ] = ( 281.421, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf138_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 144, 539, -65.9 );
	ent.v[ "angles" ] = ( 286.858, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf139_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 144, 536, -63.9 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf139_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( -192, 139, -66 );
	ent.v[ "angles" ] = ( 0, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf144_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( -192, 136, -64 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf144_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 192, 139, -66 );
	ent.v[ "angles" ] = ( 0, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf145_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 192, 136, -64 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf145_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 0, 392, -63.9 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf138_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 0, 394, -65.9 );
	ent.v[ "angles" ] = ( 281.421, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf138_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 144, 539, -65.9 );
	ent.v[ "angles" ] = ( 286.858, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf139_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 144, 536, -63.9 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf139_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( -192, 139, -66 );
	ent.v[ "angles" ] = ( 0, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf144_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( -192, 136, -64 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf144_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 192, 139, -66 );
	ent.v[ "angles" ] = ( 0, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf145_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 192, 136, -64 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf145_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 0, 392, -63.9 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf138_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 0, 394, -65.9 );
	ent.v[ "angles" ] = ( 281.421, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf138_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 144, 539, -65.9 );
	ent.v[ "angles" ] = ( 286.858, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf139_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 144, 536, -63.9 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf139_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( -192, 139, -66 );
	ent.v[ "angles" ] = ( 0, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf144_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( -192, 136, -64 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf144_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 192, 139, -66 );
	ent.v[ "angles" ] = ( 0, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf145_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 192, 136, -64 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf145_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 0, 392, -63.9 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf138_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 0, 394, -65.9 );
	ent.v[ "angles" ] = ( 281.421, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf138_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 144, 539, -65.9 );
	ent.v[ "angles" ] = ( 286.858, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf139_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 144, 536, -63.9 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf139_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( -192, 139, -66 );
	ent.v[ "angles" ] = ( 0, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf144_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( -192, 136, -64 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf144_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 192, 139, -66 );
	ent.v[ "angles" ] = ( 0, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf145_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 192, 136, -64 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf145_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 0, 392, -63.9 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf138_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 0, 394, -65.9 );
	ent.v[ "angles" ] = ( 281.421, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf138_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 144, 539, -65.9 );
	ent.v[ "angles" ] = ( 286.858, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf139_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 144, 536, -63.9 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf139_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( -192, 139, -66 );
	ent.v[ "angles" ] = ( 0, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf144_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( -192, 136, -64 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf144_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 192, 139, -66 );
	ent.v[ "angles" ] = ( 0, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf145_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 192, 136, -64 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf145_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 0, 392, -63.9 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf136_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 0, 394, -65.9 );
	ent.v[ "angles" ] = ( 281.421, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf136_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 144, 539, -65.9 );
	ent.v[ "angles" ] = ( 286.858, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf137_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 144, 536, -63.9 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf137_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( -192, 139, -66 );
	ent.v[ "angles" ] = ( 0, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf142_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( -192, 136, -64 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf142_1";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 192, 139, -66 );
	ent.v[ "angles" ] = ( 0, 270, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf143_2";

	ent = createExploder( "No FX" );
	ent.v[ "origin" ] = ( 192, 136, -64 );
	ent.v[ "angles" ] = ( 0, 90, 0 );
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "pf143_2";

	// CreateFX entities placed: 77
}