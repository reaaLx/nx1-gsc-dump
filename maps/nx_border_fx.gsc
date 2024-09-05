//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  FX Support													**
//                                                                          **
//    Created: 11/11/11 - Travis Chen (trchen x 4143)						**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;

main()
{
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\nx_border_fx::main();

	// Vision Parameters
	//-------------------------------------------------------
	VisionSetNaked( "nx_border", 0 );

	setDevDvar( "scr_fog_disable", "0" );

	setExpFog( 1000, 20000, 0.6431373, 0.7843137, 0.8666667, 0.8, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0.7529412, ( 0, 0, 0 ), 0, 1, 0 );

	SetSavedDVar ("r_fog_height_blend", 0.5);
	SetSavedDVar ("r_fog_height_start", 0.5);
	SetSavedDVar ("r_fog_height_end", 1);

	// Ambient FX
	level._effect[ "battlefield_smokebank_S" ]						= LoadFX( "smoke/battlefield_smokebank_S" );
	level._effect[ "nx_dust_mote_80" ]								= LoadFX( "nx/dust/nx_dust_mote_80" );
	level._effect[ "nx_dust_wind_canyon_mp" ]						= LoadFX( "nx/dust/nx_dust_wind_canyon_mp" );
	level._effect[ "nx_godray_150_soft" ]							= LoadFX( "nx/misc/nx_godray_150_soft" );
	level._effect[ "nx_godray_50_soft" ]							= LoadFX( "nx/misc/nx_godray_50_soft" );
	level._effect[ "nx_godray_75_soft" ]							= LoadFX( "nx/misc/nx_godray_75_soft" );
	level._effect[ "firelp_small_dl" ]								= LoadFX( "fire/firelp_small_dl" );
	level._effect[ "trash_spiral_runner" ]							= LoadFX( "misc/trash_spiral_runner" );

	// Border FX
	level._effect[ "nx_amb_smoke_dark_warm" ]						= LoadFX( "nx/smoke/nx_amb_smoke_dark_warm" );
	level._effect[ "nx_border_cabin_smoke" ]						= LoadFX( "nx/smoke/nx_border_cabin_smoke" );
	level._effect[ "nx_border_hummer_explosion" ]					= LoadFX( "nx/explosions/nx_border_hummer_explosion" );
	level._effect[ "nx_border_hummer_light" ]						= LoadFX( "nx/misc/nx_border_hummer_light" );

	// Streets FX
	level._effect[ "nx_border_light_explosion" ]					= LoadFX( "nx/explosions/nx_border_light_explosion" );
	level._effect[ "nx_border_light_sparks_runner_01" ]				= LoadFX( "nx/explosions/nx_border_light_sparks_runner_01" );
	level._effect[ "nx_border_light_impact_sparks_runner" ]			= LoadFX( "nx/explosions/nx_border_light_impact_sparks_runner" );
	level._effect[ "nx_border_tumbleweed" ]							= LoadFX( "nx/misc/nx_border_tumbleweed" );
	level._effect[ "nx_border_waterspray_0" ]						= LoadFX( "nx/water/nx_border_waterspray_0" );
	level._effect[ "nx_border_waterspray_1" ]						= LoadFX( "nx/water/nx_border_waterspray_1" );
	level._effect[ "nx_ceiling_dust_debris_200" ]					= LoadFX( "nx/dust/nx_ceiling_dust_debris_200" );
	level._effect[ "nx_ugv_deck_dust" ]								= LoadFX( "nx/dust/nx_ugv_deck_dust" );
	level._effect[ "corner_building_exploder_fx" ]                  = loadfx( "nx/explosions/nx_border_wall_explode_01" );
//	level._effect[ "streets_rightside_store_1_fx" ]                 = loadfx( "nx/explosions/nx_border_wall_explode_02" );
	level._effect[ "streets_rightside_store_2_fx" ]                 = loadfx( "nx/explosions/nx_border_wall_explode_02" );
	level._effect[ "streets_rightside_store_3_fx" ]                 = loadfx( "nx/explosions/nx_border_wall_explode_02" );
	level._effect[ "frontside_streets_destruction_fx" ]             = loadfx( "nx/explosions/nx_border_wall_explode_02" );
	level._effect[ "market_end_left_1_fx" ]                         = loadfx( "nx/misc/nx_border_balcony_collapse" );
	level._effect[ "market_end_left_2_fx" ]                         = loadfx( "nx/misc/nx_border_balcony_collapse" );
	level._effect[ "market_end_left_3_fx" ]                         = loadfx( "nx/misc/nx_border_balcony_collapse" );
	level._effect[ "market_end_right_1_fx" ]                        = loadfx( "nx/misc/nx_border_balcony_collapse" );
	level._effect[ "market_end_right_2_fx" ]                        = loadfx( "nx/misc/nx_border_balcony_collapse" );
	level._effect[ "market_end_right_3_fx" ]                        = loadfx( "nx/misc/nx_border_balcony_collapse" );

	// Marketplace FX
	level._effect[ "birds_takeoff_coup" ]							= LoadFX( "misc/birds_takeoff_coup" );
	level._effect[ "nx_birds_takeoff_border" ]						= LoadFX( "nx/misc/nx_birds_takeoff_border" );
	level._effect[ "nx_border_watersplash_0" ]						= LoadFX( "nx/water/nx_border_watersplash_0" );
	level._effect[ "nx_border_watersplash_1" ]						= LoadFX( "nx/water/nx_border_watersplash_1" );
	level._effect[ "nx_border_watersplash_2" ]						= LoadFX( "nx/water/nx_border_watersplash_2" );
	level._effect[ "nx_border_watersplash_3" ]						= LoadFX( "nx/water/nx_border_watersplash_3" );

	// For deathflag kills
	level._effect[ "flesh_hit" ]									= loadfx( "impacts/flesh_hit" );

	// Church heli destroy
	level._effect[ "nx_border_helicopter_explosion" ]						= LoadFX( "nx/explosions/nx_border_helicopter_explosion" );

	fx_setup();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

fx_setup()
{
	// Border
	thread fx_border_explosion_done();

	// Marketplace
	trigVol = GetEnt( "fx_market_birds", "targetname" );
	trigVol thread fx_market_birds();
}

fx_hummer_interior_light()
{
	PlayFXOnTag( level._effect[ "nx_border_hummer_light" ], self, "TAG_ORIGIN" );

	level waittill( "notify_border_explosion_done" );
	StopFXOnTag( level._effect[ "nx_border_hummer_light" ], self, "TAG_ORIGIN" );
}

fx_border_cabin_smoke()
{
	wait 3;
	PlayFX( level._effect[ "nx_border_cabin_smoke" ], self.origin );

	wait 3;
	Exploder ( "fx_border_explosion" );

	wait 6;
	Stop_Exploder ( "fx_border_explosion" );
}

fx_border_explosion()
{
	level waittill( "notify_border_intro_hummer_explosion" );
	PlayFX( level._effect[ "nx_border_hummer_explosion" ], self.origin );
}

fx_border_explosion_done()
{
	level waittill( "notify_border_explosion_done" );
	Exploder( "fx_border_explosion_done" );
}

fx_street_tumbleweed()
{
	wait 2.0;
	Exploder( "fx_street_tumbleweed" );
}

fx_market_birds()
{
	self waittill( "trigger" );
	Exploder( "fx_market_birds" );
	wait 1.0;
	Exploder( "fx_market_birds" );
}

fx_street_light_explosion()
{
	impactPos = self.origin + ( 0, 0, 200 );
	PlayFX( level._effect[ "nx_border_light_explosion" ], impactPos );

	wait 2.5;
	Exploder( "fx_street_light_explosion" );

	wait 2.5;
	Exploder( "fx_street_light_sparks" );
}
