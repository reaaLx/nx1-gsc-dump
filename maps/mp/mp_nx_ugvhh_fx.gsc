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
 		maps\createfx\mp_nx_ugvhh_fx::main();
 
 	level._effect[ "large_fire" ]		   								= LoadFX( "nx/fire/nx_fire_building_large" );
 	level._effect[ "firelp_large_pm_bh1" ] 								= LoadFX( "fire/firelp_large_pm_nolight" );
 	level._effect[ "firelp_med_pm_bh1" ] 								= LoadFX( "fire/firelp_med_pm_nolight" );
 
 	level._effect[ "nx_amb_smoke_plume_scattered_light" ]				= loadfx( "nx/smoke/nx_amb_smoke_plume_scattered_light" );
 	level._effect[ "nx_orbital_laser_01" ]								= loadFX( "nx/explosions/nx_orbital_laser_01" );
 	level._effect[ "nx_orbital_laser_02" ]								= loadFX( "nx/explosions/nx_orbital_laser_02" );
 	level._effect[ "nx_smoke_amb_scrolling_smoke" ]						= loadfx( "nx/smoke/nx_smoke_amb_scrolling_smoke" );
 	level._effect[ "nx_smoke_plume_periph_large_black" ]				= loadfx( "nx/smoke/nx_smoke_plume_periph_large_black" );
 
 	level._effect[ "ash_aftermath_ugv_mp" ]		 = loadfx( "weather/ash_aftermath_ugv_mp" );
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************