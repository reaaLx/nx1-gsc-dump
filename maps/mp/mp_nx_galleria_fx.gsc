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

//#include common_scripts\utility;

main()
{
	level._effect[ "drips_fast" ]	 									= loadfx( "misc/drips_fast" );
	level._effect[ "nx_smoke_plume_huge" ] 								= loadfx( "nx/smoke/nx_smoke_plume_huge" );
	level._effect[ "nx_ash_cloud_heavy" ] 								= loadfx( "nx/misc/nx_ash_cloud_heavy" );
	level._effect[ "nx_smoke_plume_huge_periph_preseed" ]				= loadfx( "nx/smoke/nx_smoke_plume_huge_periph_preseed" );	
	level._effect[ "nx_smoke_plume_huge_periph_dark_preseed" ]			= loadfx( "nx/smoke/nx_smoke_plume_huge_periph_dark_preseed" );	
	level._effect[ "nx_fire_building_large" ] 							= loadfx( "nx/fire/nx_fire_building_large" );
	level._effect[ "nx_debri_paper_falling_building" ] 					= loadfx( "nx/misc/nx_debri_paper_falling_building" );
	//level._effect[ "nx_ash_cloud_heavy_runner" ] 						= loadfx( "nx/misc/nx_ash_cloud_heavy_runner" );
	//level._effect[ "nx_godray_medium" ]									= loadfx( "nx/misc/nx_godray_medium" );
	//level._effect[ "nx_ash_cloud_heavy_parkinglot" ]					= loadfx( "nx/misc/nx_ash_cloud_heavy_parkinglot" );
	level._effect[ "nx_big_orange_glows" ]								= loadfx( "nx/misc/nx_big_orange_glows" );
	level._effect[ "nx_fire_building_distant" ]							= loadfx( "nx/fire/nx_fire_building_distant" );
	//level._effect[ "dust_outdoor_large" ] 								= loadfx( "dust/dust_outdoor_large" );
	level._effect[ "dust_wind_fast_paper" ] 							= loadfx( "dust/dust_wind_fast_paper" );
	level._effect[ "paper_falling_burning" ] 							= loadfx( "misc/paper_falling_burning" );
	//level._effect[ "ground_fog" ] 										= loadfx( "dust/ground_fog" );
	level._effect[ "ground_smoke_dcburning1200x1200" ]					= loadfx( "smoke/ground_smoke1200x1200_dcburning" );
	level._effect[ "trash_spiral_runner" ]								= loadfx( "misc/trash_spiral_runner" );
	level._effect[ "paper_blowing_trash" ]								= loadfx( "misc/paper_blowing_trash" );
	level._effect[ "room_smoke_400" ]									= loadfx( "smoke/room_smoke_400" );

    level._effect[ "nx_light_emergency_red" ]							= loadfx( "nx/misc/nx_light_emergency_red" );
	level._effect[ "nx_sparks_falling_runner" ]							= loadfx( "nx/explosions/nx_sparks_falling_runner" );
	level._effect[ "crawling_death_blood_smear" ] 						= loadfx( "impacts/blood_smear_decal" );
	level._effect[ "blood_pool" ]					 					= loadfx( "impacts/deathfx_bloodpool_generic" );
	level._effect[ "nx_flesh_hit_splat_large" ]					 		= loadfx( "impacts/nx_flesh_hit_splat_large" );
	level._effect[ "nx_flesh_hit_splat" ]					 			= loadfx( "impacts/nx_flesh_hit_splat" );
	//level._effect[ "nx_gfx_godray_side" ] 								= loadfx( "nx/misc/nx_gfx_godray_side" );
	//level._effect[ "nx_gfx_godray_side_small" ] 						= loadfx( "nx/misc/nx_gfx_godray_side_small" );
	//level._effect[ "nx_gfx_godray_down" ] 								= loadfx( "nx/misc/nx_gfx_godray_down" );
	level._effect[ "amb_smoke_add" ] 									= loadfx( "smoke/amb_smoke_add" );
	level._effect[ "amb_smoke_blend" ] 									= loadfx( "smoke/amb_smoke_blend" );


	level._effect[ "nx_godray_150" ]									= loadfx( "nx/misc/nx_godray_150" );
	level._effect[ "nx_godray_225_soft" ]								= loadfx( "nx/misc/nx_godray_225_soft" );
	level._effect[ "nx_godray_75" ]										= loadfx( "nx/misc/nx_godray_75" );

    level._effect[ "police_lights" ]									= loadfx( "nx/misc/nx_light_police_lights" );
	level._effect[ "nx_ash_cloud_light" ] 								= loadfx( "nx/misc/nx_ash_cloud_light" );
	level._effect[ "nx_smoke_mid_bldg_preseed" ]						= loadfx( "nx/smoke/nx_smoke_mid_bldg_preseed" );
	level._effect[ "nx_trash_runner_1024" ]								= loadfx( "nx/misc/nx_trash_runner_1024" );

	if ( getdvar( "clientsideeffects" ) != "1" )
	{
		maps\createfx\mp_nx_galleria_fx::main();
	}

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************