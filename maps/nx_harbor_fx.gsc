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
#include maps\_utility;
#include common_scripts\utility;

main()
{
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\nx_harbor_fx::main();

	setExpFog( 12635, 14802, 0.7215686, 0.7882353, 0.7803922, 0.4, 0 );
	set_vision_set("nx_harbor_outside",0);

	SetSavedDVar ("r_fog_height_blend", 0.60);
	SetSavedDVar ("r_fog_height_start", 0.6);
	SetSavedDVar ("r_fog_height_end", 1.40);

	// FX
	level._effect[ "train_glass_break" ]		= loadfx( "props/car_glass_large" );
	level._effect[ "splash" ]					= loadfx( "impacts/water_splash_bodydump" );
	level._effect[ "tram_splash" ]				= loadfx( "misc/watersplash_large" );
	level._effect[ "underwater_splash" ]		= loadfx( "water/splash_underwater_afchase" );
	level._effect[ "derail_fx" ]				= loadfx( "nx/explosions/nx_building_hit_explosion" );
	level._effect[ "derail_sparks_fx" ]			= loadfx( "explosions/electrical_transformer_explosion" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
