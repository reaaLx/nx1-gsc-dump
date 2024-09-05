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
#include maps\_lights;
#include common_scripts\utility;
#include common_scripts\_nx_fx;
#include maps\_anim;
#include maps\_nx_vignette_util;
#include maps\_vehicle;

main()
{
	fx_init_flags();
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\nx_rocket_fx::main();

	//Ambient FX
	//level._effect[ "bird_seagull_flock_large" ]							= loadfx( "misc/bird_seagull_flock_large" );
	level._effect[ "nx_rocket_intro_lightglow" ]						= loadfx( "nx/misc/nx_light_fake_white_small_lowflare" );
	level._effect[ "nx_light_white_small_lowflare" ]					= loadfx( "nx/misc/nx_light_white_small_lowflare" );
	level._effect[ "nx_light_white_small_lowflare_blink" ]				= loadfx( "nx/misc/nx_light_white_small_lowflare_blink" );
	level._effect[ "nx_light_blue_small" ]								= loadfx( "nx/misc/nx_light_blue_small" );
	level._effect[ "intro_chopper_light"]								= loadfx( "nx/lights/nx_light_rocket_intro_chopper");
	level._effect[ "nx_water_watefall_crash_runner_fast" ]				= loadfx( "nx/water/nx_water_watefall_crash_runner_fast" );

	//intro fx
	level._effect[ "nx_antiair_runner_rocket_intro_close" ]				= loadfx( "nx/misc/nx_antiair_runner_rocket_intro_close" );
	level._effect[ "nx_aa_explosion_large" ]							= loadfx( "nx/explosions/nx_aa_explosion_large" );
	level._effect[ "c102_medium_afterburner" ] 							= loadfx( "nx/fire/nx_repel_looping_medium_afterburner" );
	level._effect[ "nx_rocket_jet_contrail_intro" ] 					= loadfx( "nx/smoke/nx_rocket_jet_contrail_intro" );

	//vehicle fx
	//level._effect[ "nx_car_headlight_beam_far" ]						= loadfx( "nx/misc/nx_car_headlight_beam_far" );
	//level._effect[ "car_brakelight_btr80" ]								= loadfx( "misc/car_brakelight_btr80" );

	//rocket fx
	level._effect[ "nx_explosion_rocket_01" ]							= loadfx( "nx/explosions/nx_explosion_rocket_01" );
	level._effect[ "nx_smoke_rocket_blast_01" ]							= loadfx( "nx/smoke/nx_smoke_rocket_blast_01" );
	level._effect[ "nx_sparks_rocket_fan" ]								= loadfx( "nx/fire/nx_sparks_rocket_fan" );
	level._effect[ "nx_smoke_rocket_base_jet" ]							= loadfx( "nx/smoke/nx_smoke_rocket_base_jet" );
	level._effect[ "nx_jet_rocket_afterburner_ignite" ]					= loadfx( "nx/fire/nx_jet_rocket_afterburner_ignite" );
	level._effect[ "nx_smoke_rocket_afterburner_liftoff" ]				= loadfx( "nx/smoke/nx_smoke_rocket_afterburner_liftoff" );
	level._effect[ "nx_smoke_rocket_exhaust_01" ]						= loadfx( "nx/smoke/nx_smoke_rocket_exhaust_01" );
	level._effect[ "nx_rocket_railgun_hit_01" ]							= loadfx( "nx/explosions/nx_rocket_railgun_hit_01" );
	level._effect[ "nx_explosion_rocket01" ]							= loadfx( "nx/explosions/nx_explosion_rocket01" );
	level._effect[ "nx_explosion_rocket01_small" ]						= loadfx( "nx/explosions/nx_explosion_rocket01_small" );
	level._effect[ "nx_fire_smoke_trail_emitter_rocket" ] 				= loadfx( "nx/fire/nx_fire_smoke_trail_emitter_rocket" );
	level._effect[ "nx_fire_smoke_trail_emitter_large" ] 				= loadfx( "nx/fire/nx_fire_smoke_trail_emitter_large" );

	level._effect[ "nx_explosion_rocket01_runner" ] 					= loadfx( "nx/explosions/nx_explosion_rocket01_runner" );
	level._effect[ "nx_explosion_rocket_01_child" ] 					= loadfx( "nx/explosions/nx_explosion_rocket_01_child" );
	level._effect[ "nx_light_rocket_prelaunch" ] 						= loadfx( "nx/misc/nx_light_rocket_prelaunch" );

	//Intro bomber explosions, etc
	level._effect[ "nx_explosion_rocket_intro_bombers" ] 				= loadfx( "nx/explosions/nx_explosion_rocket_intro_bombers" );
	level._effect[ "nx_antiair_runner_rocket_intro" ] 					= loadfx( "nx/misc/nx_antiair_runner_rocket_intro" );

	//secondary fx test stuff
/*
	level._effect[ "nx_debri_rocket_gen" ]								= loadfx( "nx/misc/nx_debri_rocket_gen" );
	level._effect[ "nx_debri_rocket_gen_mid" ]							= loadfx( "nx/misc/nx_debri_rocket_gen_mid" );
	level._effect[ "nx_debri_rocket_gen_mid_far" ]						= loadfx( "nx/misc/nx_debri_rocket_gen_mid_far" );
	level._effect[ "nx_debri_bunker_explode_01" ]						= loadfx( "nx/misc/nx_debri_bunker_explode_01" );
	*/
	// level._effect[ "vehicle_explosion_slamraam" ]	 					= LoadFX( "explosions/vehicle_explosion_slamraam" );

	// misc fx
	//level._effect[ "explosion_defualt" ]								= LoadFX( "explosions/aa_explosion" );
    //level._effect[ "antiair_runner_cloudy" ]							= loadfx( "misc/antiair_runner_cloudy" );
	level._effect[ "nx_explosion_silo" ]								= loadfx( "nx/explosions/nx_explosion_silo" );

	//bridge fx
	level._effect[ "nx_rocket_exploding_pipes" ]						= loadfx( "nx/explosions/nx_rocket_exploding_pipes" );
	level._effect[ "nx_rocket_vtol_explosion_bridge" ]					= loadfx( "nx/explosions/nx_rocket_vtol_explosion_bridge" );

	// Cloud FX
	level._effect[ "cloud_bank_far_gulag" ]								= LoadFX( "weather/cloud_bank_far_gulag" );
	level._effect[ "nx_cloud_fray" ]									= LoadFX( "nx/weather/nx_cloud_fray" );
	level._effect[ "nx_cloud_fray_large" ]								= LoadFX( "nx/weather/nx_cloud_fray_large" );
	level._effect[ "nx_cloud_fray_layer_large" ]						= LoadFX( "nx/weather/nx_cloud_fray_layer_large" );
	//level._effect[ "nx_cloud_huge_light_preseed" ]						= LoadFX( "nx/weather/nx_cloud_huge_light_preseed" );
	level._effect[ "nx_cloud_rocket_periph_01" ]						= LoadFX( "nx/weather/nx_cloud_rocket_periph_01" );
	//level._effect[ "nx_fog_layer_large" ]								= LoadFX( "nx/weather/nx_fog_layer_large" );
	//level._effect[ "nx_cloud_dark_line" ]								= LoadFX( "nx/weather/nx_cloud_dark_line" );
	level._effect[ "nx_fog_upfog" ]										= LoadFX( "nx/weather/nx_fog_upfog" );
	level._effect[ "nx_cloud_storm_fast_intro" ]						= LoadFX( "nx/weather/nx_cloud_storm_fast_intro" );
	// level._effect[ "nx_cloud_rocket_periph_02" ]						= LoadFX( "nx/weather/nx_cloud_rocket_periph_02" );
	//level._effect[ "nx_glow_rocket_warm_intro" ]						= LoadFX( "nx/misc/nx_glow_rocket_warm_intro" );

	//test fx from forest fire
	//level._effect[ "nx_smoke_plume_large_03_preseed" ]					= loadfx( "nx/smoke/nx_smoke_plume_large_03_preseed" );	
	//level._effect[ "100ton_bomb_cheap" ]								= loadfx( "nx/explosions/nx_110ton_bomb_cheap" );	
	//level._effect[ "nx_smoke_wall_long_preseed" ] 						= LoadFX( "nx/smoke/nx_smoke_wall_long_preseed" );
  	//level._effect[ "nx_smoke_wall_long_04_preseed" ] 					= LoadFX( "nx/smoke/nx_smoke_wall_long_04_preseed" );
	//level._effect[ "nx_smoke_wall_street_preseed" ] 					= LoadFX( "nx/smoke/nx_smoke_wall_street_preseed" );
	level._effect[ "nx_smoke_plume_huge" ] 								= LoadFX( "nx/smoke/nx_smoke_plume_huge" );
	//level._effect[ "nx_amb_smoke_blend_large" ] 						= LoadFX( "nx/smoke/nx_amb_smoke_blend_large" );
	//level._effect[ "nx_amb_smoke_blend_large_02" ] 						= LoadFX( "nx/smoke/nx_amb_smoke_blend_large_02" );
	//level._effect[ "nx_ash_cloud_light" ] 								= LoadFX( "nx/misc/nx_ash_cloud_light" );
	level._effect[ "nx_ash_cloud_heavy" ] 								= LoadFX( "nx/misc/nx_ash_cloud_heavy" );
    //level._effect[ "ash_turb_aftermath" ]								= LoadFX( "weather/ash_turb_aftermath" );
	level._effect[ "nx_smoke_amb_scrolling_smoke" ]						= loadfx( "nx/smoke/nx_smoke_amb_scrolling_smoke" );	
	level._effect[ "nx_amb_smoke_plume_scattered_light_preseed" ]		= loadfx( "nx/smoke/nx_amb_smoke_plume_scattered_light_preseed" );	
	level._effect[ "nx_amb_smoke_scattered_light_large_preseed" ] 		= loadfx( "nx/smoke/nx_amb_smoke_scattered_light_large_preseed" );
	level._effect[ "nx_smoke_plume_periph_large_black" ]				= loadfx( "nx/smoke/nx_smoke_plume_periph_large_black" );	
	level._effect[ "nx_smoke_plume_periph_large_black_preseed" ]		= loadfx( "nx/smoke/nx_smoke_plume_periph_large_black_preseed" );	
	level._effect[ "nx_smoke_plume_huge_periph_preseed" ]				= loadfx( "nx/smoke/nx_smoke_plume_huge_periph_preseed" );	
	level._effect[ "nx_smoke_plume_huge_periph_dark_preseed" ]			= loadfx( "nx/smoke/nx_smoke_plume_huge_periph_dark_preseed" );	
	level._effect[ "nx_amb_smoke_fastground" ]							= loadfx( "nx/smoke/nx_amb_smoke_fastground" );
	level._effect[ "nx_amb_smoke_blend_large" ] 						= LoadFX( "nx/smoke/nx_amb_smoke_blend_large" );
	level._effect[ "nx_amb_smoke_blend_large_02" ] 						= LoadFX( "nx/smoke/nx_amb_smoke_blend_large_02" );
	level._effect[ "nx_fire_building_large" ] 							= LoadFX( "nx/fire/nx_fire_building_large" );
	level._effect[ "nx_debri_paper_falling_building" ] 					= LoadFX( "nx/misc/nx_debri_paper_falling_building" );
	level._effect[ "nx_ash_cloud_heavy_runner" ] 						= LoadFX( "nx/misc/nx_ash_cloud_heavy_runner" );
    level._effect[ "nx_smoke_street_fog_oriented" ]						= LoadFX( "nx/smoke/nx_smoke_street_fog_oriented" );
    level._effect[ "nx_smoke_street_mid_periph" ]						= LoadFX( "nx/smoke/nx_smoke_street_mid_periph" );
    level._effect[ "fire_light" ]										= LoadFX( "nx/misc/nx_light_orange_large" );
    level._effect[ "fire_light_small" ]									= LoadFX( "nx/misc/nx_light_orange_small" );
    //level._effect[ "blast_mark" ]										= LoadFX( "nx/misc/nx_blast_mark_large" );
    //level._effect[ "blast_mark_02" ]									= LoadFX( "nx/misc/nx_blast_mark_large_02" );
	level._effect[ "godray_large" ]										= LoadFX( "nx/misc/nx_gfx_godray_side" );
	level._effect[ "godray_huge" ]										= LoadFX( "nx/misc/nx_gfx_godray_side_huge" );
	level._effect[ "nx_godray_medium" ]									= LoadFX( "nx/misc/nx_godray_medium" );
	//level._effect[ "nx_smoke_missilehits_periph" ]						= LoadFX( "nx/smoke/nx_smoke_missilehits_periph" );
	//level._effect[ "nx_smoke_missilehits_periph_no_child" ]				= LoadFX( "nx/smoke/nx_smoke_missilehits_periph_no_child" );
	level._effect[ "nx_fire_buildingtop_embers" ]						= LoadFX( "nx/fire/nx_fire_buildingtop_embers" );
	level._effect[ "nx_fire_buildingtop_embers_preseed" ]				= LoadFX( "nx/fire/nx_fire_buildingtop_embers_preseed" );
	level._effect[ "embers_whitehouse" ]								= LoadFX( "fire/embers_whitehouse" );
	level._effect[ "nx_ash_cloud_heavy_parkinglot" ]					= LoadFX( "nx/misc/nx_ash_cloud_heavy_parkinglot" );
	level._effect[ "nx_big_orange_glows" ]								= LoadFX( "nx/misc/nx_big_orange_glows" );
	level._effect[ "nx_fire_tree_embers_preseed" ]						= LoadFX( "nx/fire/nx_fire_tree_embers_preseed" );
	level._effect[ "nx_fire_buildingtop_03_preseed" ]					= LoadFX( "nx/fire/nx_fire_buildingtop_03_preseed" );
	level._effect[ "battlefield_smokebank_S_warm" ]						= LoadFX( "smoke/battlefield_smokebank_S_warm" );
	level._effect[ "nx_smoke_n_fire_plume_preseed" ]					= LoadFX( "nx/smoke/nx_smoke_n_fire_plume_preseed" );
	level._effect[ "nx_smoke_n_fire_plume_small_preseed" ]				= LoadFX( "nx/smoke/nx_smoke_n_fire_plume_small_preseed" );
	level._effect[ "nx_smoke_mid_bldg_preseed" ]						= LoadFX( "nx/smoke/nx_smoke_mid_bldg_preseed" );
	level._effect[ "nx_fire_building_distant" ]							= LoadFX( "nx/fire/nx_fire_building_distant" );
	//level._effect[ "nx_distortion_large" ]								= loadfx( "nx/misc/nx_distortion_large" );
	//level._effect[ "amb_dust" ] 										= loadfx( "smoke/amb_dust" );
	//level._effect[ "amb_smoke_add" ] 									= loadfx( "smoke/amb_smoke_add" );
	level._effect[ "nx_smoke_lapse_amb_smoke" ] 						= LoadFX( "nx/smoke/nx_smoke_lapse_amb_smoke" );
	level._effect[ "nx_debri_paper_fast" ] 								= loadfx( "nx/misc/nx_debri_paper_fast" );
	level._effect[ "nx_gfx_godray_side" ] 								= LoadFX( "nx/misc/nx_gfx_godray_side" );
	level._effect[ "nx_gfx_godray_side_small" ] 						= LoadFX( "nx/misc/nx_gfx_godray_side_small" );
	level._effect[ "nx_gfx_godray_down" ] 								= LoadFX( "nx/misc/nx_gfx_godray_down" );
	level._effect[ "dust_outdoor_large" ] 								= LoadFX( "dust/dust_outdoor_large" );
	level._effect[ "dust_wind_fast_paper" ] 							= LoadFX( "dust/dust_wind_fast_paper" );
	level._effect[ "paper_falling_burning" ] 							= LoadFX( "misc/paper_falling_burning" );
	level._effect[ "ground_fog" ] 										= LoadFX( "dust/ground_fog" );
	level._effect[ "nx_embers_ambient_swirl" ] 							= LoadFX( "nx/fire/nx_embers_ambient_swirl" );
	//level._effect[ "nx_fire_test_tex" ] 								= LoadFX( "nx/fire/nx_fire_test_tex" );
	//level._effect[ "nx_smoke_wisp_tests" ] 								= LoadFX( "nx/fire/nx_smoke_wisp_tests" );
	level._effect[ "nx_smoke_billow_slow_small" ] 						= LoadFX( "nx/smoke/nx_smoke_billow_slow_small" );
	level._effect[ "nx_smoke_ground_wispy" ] 							= LoadFX( "nx/smoke/nx_smoke_ground_wispy" );
	level._effect[ "nx_embers_ambient_swirl" ] 							= LoadFX( "nx/fire/nx_embers_ambient_swirl" );
	level._effect[ "nx_smoke_plume_diffuse" ] 							= LoadFX( "nx/smoke/nx_smoke_plume_diffuse" );
	level._effect[ "nx_fire_ground_small_wind" ] 						= LoadFX( "nx/fire/nx_fire_ground_small_wind" );
	level._effect[ "nx_fire_tree_small_01" ] 							= LoadFX( "nx/fire/nx_fire_tree_small_01" );
	level._effect[ "nx_fire_tree_medium_01" ] 							= LoadFX( "nx/fire/nx_fire_tree_medium_01" );
	level._effect[ "nx_fire_ground_spots_medium_01" ] 					= LoadFX( "nx/fire/nx_fire_ground_spots_medium_01" );
	level._effect[ "nx_fire_tree_intense_small_01" ] 					= LoadFX( "nx/fire/nx_fire_tree_intense_small_01" );
	level._effect[ "nx_fire_wall_medium_01" ] 							= LoadFX( "nx/fire/nx_fire_wall_medium_01" );
	level._effect[ "nx_embers_ambient_swirl_local" ] 					= LoadFX( "nx/fire/nx_embers_ambient_swirl_local" );
	level._effect[ "nx_embers_ambient_swirl_local_small" ] 				= LoadFX( "nx/fire/nx_embers_ambient_swirl_local_small" );
	level._effect[ "nx_fire_wall_small_01" ] 							= LoadFX( "nx/fire/nx_fire_wall_small_01" );

	// nuke fx
	//level._effect[ "nx_explosion_nuke_01" ]								= loadfx( "nx/explosions/nx_explosion_nuke_01" );
	level._effect[ "nx_explosion_nuke_02" ]								= loadfx( "nx/explosions/nx_explosion_nuke_02" );
	level._effect[ "nx_explosion_nuke_02_reflection" ]					= loadfx( "nx/explosions/nx_explosion_nuke_02_reflection" );
	level._effect[ "nx_explosion_nuke_shockwave_debri_01" ]				= loadfx( "nx/explosions/nx_explosion_nuke_shockwave_debri_01" );
	level._effect[ "nx_rocket_trail_nuke_missile" ]						= loadfx( "nx/smoke/nx_rocket_trail_nuke_missile" );

	level._effect[ "nx_rocket_rocketfuel_fire_base" ]					= loadfx( "nx/fire/nx_rocket_rocketfuel_fire_base" );
	level._effect[ "nx_smoke_plume_huge_preseed" ]						= loadfx( "nx/smoke/nx_smoke_plume_huge_preseed" );

	//water fx
	//level._effect[ "nx_water_tex_test" ]								= loadfx( "nx/water/nx_water_tex_test" );
	level._effect[ "nx_water_wave_crash" ]								= loadfx( "nx/water/nx_water_wave_crash" );
	level._effect[ "nx_water_wave_crash_small" ]						= loadfx( "nx/water/nx_water_wave_crash_small" );
	level._effect[ "nx_water_wave_crash_runner" ]						= loadfx( "nx/water/nx_water_wave_crash_runner" );
	//level._effect[ "nx_water_waveswash" ]								= loadfx( "nx/water/nx_water_waveswash" );
	//level._effect[ "nx_water_waveswash02" ]								= loadfx( "nx/water/nx_water_waveswash02" );
	//level._effect[ "nx_water_waveswash02_small" ]						= loadfx( "nx/water/nx_water_waveswash02" );
	//level._effect[ "nx_water_waveswash_runner" ]						= loadfx( "nx/water/nx_water_waveswash_runner" );
	//level._effect[ "nx_water_edge_turbulent" ]							= loadfx( "nx/water/nx_water_edge_turbulent" );
	//level._effect[ "nx_water_edge_turbulent_long" ]						= loadfx( "nx/water/nx_water_edge_turbulent_long" );
	level._effect[ "nx_blackhawk_minigun_water_default" ]				= loadfx( "nx/treadfx/nx_blackhawk_minigun_water_default" );

	//heli crash fx
	level._effect[ "helicopter_explosion_secondary_small" ]				= loadfx( "explosions/helicopter_explosion_secondary_small" );
	level._effect[ "fire_smoke_trail_L_emitter" ]						= loadfx( "fire/fire_smoke_trail_L_emitter" );
	level._effect[ "helicopter_explosion" ]								= loadfx( "explosions/helicopter_explosion" );
	level._effect[ "aerial_explosion_heli_large" ]						= loadfx( "explosions/aerial_explosion_heli_large" );
	level._effect[ "nx_rocket_aa_heli" ]								= loadfx( "nx/misc/nx_rocket_aa_heli" );
	level._effect[ "nx_rocket_heli_explosion_player" ]					= loadfx( "nx/explosions/nx_rocket_heli_explosion_player" );

	//hanging fx
	level._effect[ "leaves_hanging_falling" ]							= loadfx( "misc/leaves" );
	level._effect[ "nx_leaves_impact" ]									= loadfx( "nx/misc/nx_leaves_impact" );
	level._effect[ "nx_embers_ambient_local_small" ]					= loadfx( "nx/fire/nx_embers_ambient_local_small" );

	//robert temp fx for aa exit
	level._effect[ "ground_smoke_dcburning1200x1200" ]					= loadfx( "smoke/ground_smoke1200x1200_dcburning" );

	//hallway destruction
	level._effect[ "hallway_collapsing_major" ] 						 = LoadFX( "misc/hallway_collapsing_major" );
	level._effect[ "hallway_collapsing_major_norocks" ] 				 = LoadFX( "misc/hallway_collapsing_major_norocks" );
	level._effect[ "ceiling_rock_break" ] 								 = LoadFX( "misc/ceiling_rock_break" );
	level._effect[ "nx_ceiling_dust_debri_rocket" ]						 = LoadFX( "nx/dust/nx_ceiling_dust_debri_rocket" );
	level._effect[ "nx_hallway_collapsing_big" ]						 = LoadFX( "nx/misc/nx_hallway_collapsing_big" );

	//aa turret fx
	level._effect[ "nx_rocket_aa_flash_view" ] 							= LoadFX( "nx/muzzleflashes/nx_rocket_aa_flash_view" );

	//heli battle fx
	level._effect[ "smoke_geotrail_hellfire" ] 							= LoadFX( "smoke/smoke_geotrail_hellfire" );
	level._effect[ "cobra_rocket_flash_wv" ] 							= LoadFX( "muzzleflashes/cobra_rocket_flash_wv" );
	level._effect[ "nx_heli_countermeasures" ] 							= LoadFX( "nx/smoke/nx_heli_countermeasures_02" );

	// Flashlight
	level._effect[ "flashlight" ]										= LoadFX( "misc/flashlight_cargoship" );

	thread treadfx_override();
	thread sequence_ocean();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
sequence_ocean()
{
	ocean_a = GetEnt( "ocean_water_a", "targetname" );
	ocean_b = GetEnt( "ocean_water_b", "targetname" );
	ocean_c = GetEnt( "ocean_water_c", "targetname" );
	ocean_d = GetEnt( "ocean_water_d", "targetname" );

	thread delete_ocean_a(ocean_a);
	thread delete_ocean_b(ocean_b);
	thread delete_ocean_c(ocean_c);
	thread delete_ocean_d(ocean_d);

}

delete_ocean_a(ocean_obj)
{
	flag_wait( "intro_delete_ocean_a" );
	wait 5;
	ocean_obj delete();
}

delete_ocean_b(ocean_obj)
{
	flag_wait( "intro_delete_ocean_b" );
	wait 48;
	ocean_obj delete();
}

delete_ocean_c(ocean_obj)
{
	flag_wait( "intro_delete_ocean_c" );
	wait 48;
	ocean_obj delete();
}

delete_ocean_d(ocean_obj)
{
	flag_wait( "intro_delete_ocean_d" );
	wait 8;
	ocean_obj delete();
}


ocean_anim()
{
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		ocean_objs = GetEntArray( "ocean_anim", "script_noteworthy" );	// get my object
		for ( i=0; i<ocean_objs.size; i++ )
		{
			ocean_objs[i].animname = "ocean_idle";
			ocean_objs[i] assign_animtree();
			ocean_objs[i] thread play_ocean_anim( RandomFloat(5.0) );
		}
	}
}

play_ocean_anim(wait_timer)
{
	wait wait_timer;
	self SetAnim(self getAnim("nx_rocket_ocean_idle_0"), 1.0, 0.1, 0.15);
}

hanging_amb_fx()
{
	//wait 1;
	//iPrintLnBold("hanging_amb_fx");
	exploder("hanging_amb_fx");
}

vtol_explode_fx( ec_vtol_destroyed )
{
	//iPrintLnBold("hanging_amb_fx");
	PlayFXOnTag( level._effect[ "nx_rocket_vtol_explosion_bridge" ],  ec_vtol_destroyed, "tag_body");
	wait 0.1;
	//PlayFXOnTag( level._effect[ "helicopter_explosion" ],  ec_vtol_destroyed, "tag_deathfx");
	//wait 0.1;
	//PlayFXOnTag( level._effect[ "helicopter_explosion_secondary_small" ],  ec_vtol_destroyed, "elevator_jnt");
	//wait 0.1;
	PlayFXOnTag( level._effect[ "fire_smoke_trail_L_emitter" ],  ec_vtol_destroyed, "tag_left_wing");
	wait 0.1;
	PlayFXOnTag( level._effect[ "fire_smoke_trail_L_emitter" ],  ec_vtol_destroyed, "tag_front_flame_fx");
	//wait 0.1;
	//PlayFXOnTag( level._effect[ "helicopter_explosion_secondary_small" ],  ec_vtol_destroyed, "tag_engine_right");
	//wait 3;
}

vtol_bridge_missile_fx( bridge_missile )
{
	/* iPrintLnBold("bridge missile"); */
	wait 1;
	PlayFXOnTag( level._effect[ "smoke_geotrail_hellfire" ],  bridge_missile, "tag_fx");
}

rocket01_gantrylights_fx()
{
	// Get all Ents in the Gantry prefab
	gantry_parts = GetEntArray ("gantry_inner_1", "script_noteworthy");

	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			if( part DoesTagExistOnEntity( "tag_fx_gantrylight_001" ) == 1 && part DoesTagExistOnEntity( "tag_fx_gantrylight_002" ) == 1)
			{
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_001");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_002");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_003");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_004");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_005");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_006");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_007");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_008");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_009");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_010");
			}
		}
	}
}

rocket02_gantrylights_fx()
{
	// Get all Ents in the Gantry prefab
	gantry_parts = GetEntArray ("gantry_inner_2", "script_noteworthy");

	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			if( part DoesTagExistOnEntity( "tag_fx_gantrylight_001" ) == 1 && part DoesTagExistOnEntity( "tag_fx_gantrylight_002" ) == 1)
			{
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_001");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_002");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_003");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_004");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_005");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_006");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_007");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_008");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_009");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_010");
			}
		}
	}
}

rocket03_gantrylights_fx()
{
	// Get all Ents in the Gantry prefab
	gantry_parts = GetEntArray ("gantry_inner_3", "script_noteworthy");

	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			if( part DoesTagExistOnEntity( "tag_fx_gantrylight_001" ) == 1 && part DoesTagExistOnEntity( "tag_fx_gantrylight_002" ) == 1)
			{
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_001");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_002");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_003");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_004");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_005");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_006");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_007");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_008");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_009");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_010");
			}
		}
	}
}

rocket04_gantrylights_fx()
{
	// Get all Ents in the Gantry prefab
	gantry_parts = GetEntArray ("gantry_inner_4", "script_noteworthy");

	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			if( part DoesTagExistOnEntity( "tag_fx_gantrylight_001" ) == 1 && part DoesTagExistOnEntity( "tag_fx_gantrylight_002" ) == 1)
			{
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_001");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_002");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_003");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_004");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_005");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_006");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_007");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_008");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_009");
				wait 0.01;
				PlayFXOnTag( level._effect[ "nx_light_white_small_lowflare" ],  part, "tag_fx_gantrylight_010");
			}
		}
	}
}

intro_bombers_fx( bomber_01, bomber_02, bomber_03, bomber_04 )
{
	PlayFXOnTag( level._effect[ "nx_rocket_jet_contrail_intro" ],  bomber_01, "tag_fx_wing_r_red_steady");
	wait 0.1;
	PlayFXOnTag( level._effect[ "nx_rocket_jet_contrail_intro" ],  bomber_01, "tag_fx_wing_l_green_steady");
	wait 0.1;
	PlayFXOnTag( level._effect[ "nx_rocket_jet_contrail_intro" ],  bomber_02, "tag_fx_wing_r_red_steady");
	wait 0.1;
	PlayFXOnTag( level._effect[ "nx_rocket_jet_contrail_intro" ],  bomber_02, "tag_fx_wing_l_green_steady");
	wait 0.1;
	PlayFXOnTag( level._effect[ "nx_rocket_jet_contrail_intro" ],  bomber_03, "tag_fx_wing_r_red_steady");
	wait 0.1;
	PlayFXOnTag( level._effect[ "nx_rocket_jet_contrail_intro" ],  bomber_03, "tag_fx_wing_l_green_steady");
	wait 0.1;
	PlayFXOnTag( level._effect[ "nx_rocket_jet_contrail_intro" ],  bomber_04, "tag_fx_wing_r_red_steady");
	wait 0.1;
	PlayFXOnTag( level._effect[ "nx_rocket_jet_contrail_intro" ],  bomber_04, "tag_fx_wing_l_green_steady");
	wait 0.1;
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  bomber_01, "tag_fx_enginesmoke_01");
	wait 0.1;
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  bomber_01, "tag_fx_enginesmoke_02");
	wait 0.1;
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  bomber_01, "tag_fx_enginesmoke_03");
	wait 0.1;
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  bomber_01, "tag_fx_enginesmoke_04");
	wait 0.1;
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  bomber_02, "tag_fx_enginesmoke_01");
	wait 0.1;                                                                                  
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  bomber_02, "tag_fx_enginesmoke_02");
	wait 0.1;                                                                                  
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  bomber_02, "tag_fx_enginesmoke_03");
	wait 0.1;                                                                                  
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  bomber_02, "tag_fx_enginesmoke_04");
	wait 0.1;
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  bomber_03, "tag_fx_enginesmoke_01");
	wait 0.1;                                                                                  
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  bomber_03, "tag_fx_enginesmoke_02");
	wait 0.1;                                                                                  
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  bomber_03, "tag_fx_enginesmoke_03");
	wait 0.1;                                                                                  
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  bomber_03, "tag_fx_enginesmoke_04");
	wait 0.1;
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  bomber_04, "tag_fx_enginesmoke_01");
	wait 0.1;                                                                                  
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  bomber_04, "tag_fx_enginesmoke_02");
	wait 0.1;                                                                                  
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  bomber_04, "tag_fx_enginesmoke_03");
	wait 0.1;                                                                                  
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  bomber_04, "tag_fx_enginesmoke_04");
	wait 25;
	//iPrintLnBold("intro_bombers_fx");
	exploder("bomber_aa");
	wait 2.3;
	exploder("bomber_aa_close");
}

base_delta_heli_crash_01( chopper_battle_delta_bh_03 )
{
	self endon( "death" );

	//wait 5;
	//iPrintLnBold("heli_crash");
	PlayFXOnTag( level._effect[ "fire_smoke_trail_L_emitter" ],  chopper_battle_delta_bh_03, "elevator_jnt");
	wait 2;
	PlayFXOnTag( level._effect[ "helicopter_explosion" ],  chopper_battle_delta_bh_03, "tag_origin");
	wait 2;
	PlayFXOnTag( level._effect[ "aerial_explosion_heli_large" ],  chopper_battle_delta_bh_03, "tag_origin");
}

chopper_fly_over_fx( woods_chopper_fly_over_blackhawk )
{
	//iPrintLnBold("chopper fx");
	wait 1;
	PlayFXOnTag( level._effect[ "aerial_explosion_heli_large" ],  woods_chopper_fly_over_blackhawk, "tag_deathfx");
	wait 2;
	PlayFXOnTag( level._effect[ "fire_smoke_trail_L_emitter" ],  woods_chopper_fly_over_blackhawk, "elevator_jnt");
}

heli_battle_first_missile( opfor_heli_missile_01 )
{	
	//iPrintLnBold("first_missile");
	//PlayFXOnTag( level._effect[ "cobra_rocket_flash_wv" ],  opfor_heli_missile_01, "tag_origin");
	//wait 0.2;
	PlayFXOnTag( level._effect[ "smoke_geotrail_hellfire" ],  opfor_heli_missile_01, "tag_origin");
	//wait 6;
	//StopFXOnTag( level._effect[ "smoke_geotrail_hellfire" ],  opfor_heli_missile_01, "tag_origin");
}

heli_battle_second_missile( opfor_heli_missile_02 )
{	
	//iPrintLnBold("second_missile");
	//PlayFXOnTag( level._effect[ "cobra_rocket_flash_wv" ],  opfor_heli_missile_02, "tag_origin");
	//wait 0.2;
	PlayFXOnTag( level._effect[ "smoke_geotrail_hellfire" ],  opfor_heli_missile_02, "tag_origin");
	//wait 5;
	//StopFXOnTag( level._effect[ "smoke_geotrail_hellfire" ],  opfor_heli_missile_02, "tag_origin");
}

heli_battle_countermeasures( blackhawk_01 )
{	
	//iPrintLnBold("countermeasures");
	//wait 0.1;
	PlayFXOnTag( level._effect[ "nx_heli_countermeasures" ],  level.bridge_intro_ally, "tag_origin");
	//wait 5;
	//StopFXOnTag( level._effect[ "nx_heli_countermeasures" ],  blackhawk_01, "tag_origin");
}

heli_battle_missile_hit( blackhawk_01 )
{	
	//iPrintLnBold("missile_hit");
	//wait 0.1;
	PlayFXOnTag( level._effect[ "helicopter_explosion" ],  level.bridge_intro_ally, "tag_origin");
	wait 0.1;
	PlayFXOnTag( level._effect[ "fire_smoke_trail_L_emitter" ],  level.bridge_intro_ally, "elevator_jnt");
}

heli_battle_heli_crash( blackhawk_01 )
{	
	//iPrintLnBold("crash");
	//wait 0.1;
	PlayFXOnTag( level._effect[ "aerial_explosion_heli_large" ],  level.bridge_intro_ally, "tag_origin");
}

heli_battle_first_missile_launch_fx( opfor_heli_01 )
{	
	//iPrintLnBold("launch");
	//wait 0.1;
	PlayFXOnTag( level._effect[ "cobra_rocket_flash_wv" ],  opfor_heli_01, "tag_flash_2");
}

heli_battle_first_missile_launch_02_fx( opfor_heli_01 )
{	
	//iPrintLnBold("launch_02");
	//wait 0.1;
	PlayFXOnTag( level._effect[ "cobra_rocket_flash_wv" ],  opfor_heli_01, "tag_flash_22");
}

hanging_leaves_fx()
{
	//iPrintLnBold("falling leaves");
	exploder("leaves_hanging_falling");
	wait 7;
	//iPrintLnBold("leaves impact");
	exploder("leaves_impact");
}

heli_01_hit_fx( nuke_crash_chopper2 )
{
	wait 29;
	//iPrintLnBold("chopper2 start");
	//exploder("heli_crash_aa");
	wait 4;
	PlayFXOnTag( level._effect[ "helicopter_explosion" ],  nuke_crash_chopper2, "tag_deathfx");
	wait 0.2;
	PlayFXOnTag( level._effect[ "helicopter_explosion_secondary_small" ],  nuke_crash_chopper2, "elevator_jnt");
	wait 0.1;
	PlayFXOnTag( level._effect[ "fire_smoke_trail_L_emitter" ],  nuke_crash_chopper2, "elevator_jnt");
	wait 0.1;
	PlayFXOnTag( level._effect[ "helicopter_explosion_secondary_small" ],  nuke_crash_chopper2, "tag_engine_left");
	wait 0.1;
	PlayFXOnTag( level._effect[ "helicopter_explosion_secondary_small" ],  nuke_crash_chopper2, "tag_engine_right");
	wait 3;
	PlayFXOnTag( level._effect[ "aerial_explosion_heli_large" ],  nuke_crash_chopper2, "tag_deathfx");

	//StopFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  blackhawk_tp, "tag_c102_phalanx_l");
}

heli_03_hit_fx( nuke_crash_chopper3 )
{
	wait 37;
	//iPrintLnBold("chopper2 start");
	//exploder("heli_crash_aa");
	//wait 1;
	PlayFXOnTag( level._effect[ "helicopter_explosion" ],  nuke_crash_chopper3, "tag_deathfx");
	wait 0.2;
	PlayFXOnTag( level._effect[ "helicopter_explosion_secondary_small" ],  nuke_crash_chopper3, "elevator_jnt");
	wait 0.1;
	PlayFXOnTag( level._effect[ "fire_smoke_trail_L_emitter" ],  nuke_crash_chopper3, "elevator_jnt");
	wait 0.1;
	PlayFXOnTag( level._effect[ "helicopter_explosion_secondary_small" ],  nuke_crash_chopper3, "tag_engine_left");
	wait 0.1;
	PlayFXOnTag( level._effect[ "helicopter_explosion_secondary_small" ],  nuke_crash_chopper3, "tag_engine_right");
	wait 3;
	PlayFXOnTag( level._effect[ "aerial_explosion_heli_large" ],  nuke_crash_chopper3, "tag_deathfx");

	//StopFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  blackhawk_tp, "tag_c102_phalanx_l");
}

heli_02_hit_fx( blackhawk_player )
{
	wait 37.5;
	//iPrintLnBold("player_chopper_start");
	//exploder("heli_crash_aa_02");
	//wait 3;
	//iPrintLnBold("heli02");
	PlayFXOnTag( level._effect[ "nx_rocket_heli_explosion_player" ],  blackhawk_player, "tag_deathfx");
	quakeobj = spawn( "script_origin", level._player.origin );
	quakeobj PlayRumbleOnEntity( "artillery_rumble" );
	Earthquake( .5, 1.0, level._player.origin, 5000 );
	wait 0.2;
	PlayFXOnTag( level._effect[ "helicopter_explosion_secondary_small" ],  blackhawk_player, "elevator_jnt");
	quakeobj PlayRumbleOnEntity( "artillery_rumble" );
	Earthquake( .3, 0.5, level._player.origin, 5000 );
	wait 0.1;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_rocket" ],  blackhawk_player, "elevator_jnt");
	wait 0.2;
	PlayFXOnTag( level._effect[ "aerial_explosion_heli_large" ],  blackhawk_player, "tag_deathfx");
	wait 0.1;
	PlayFXOnTag( level._effect[ "helicopter_explosion_secondary_small" ],  blackhawk_player, "tag_engine_left");
	quakeobj PlayRumbleOnEntity( "artillery_rumble" );
	Earthquake( .3, 0.5, level._player.origin, 5000 );
	wait 0.3;
	PlayFXOnTag( level._effect[ "helicopter_explosion_secondary_small" ],  blackhawk_player, "tag_engine_right");
	wait 7;
	PlayFXOnTag( level._effect[ "aerial_explosion_heli_large" ],  blackhawk_player, "tag_deathfx");
	Earthquake( .5, 2, level._player.origin, 5000 );
	quakeobj PlayRumbleOnEntity( "artillery_rumble" );

	//StopFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  blackhawk_tp, "tag_c102_phalanx_l");
}

nuke_fx()
{
	wait 23.3;
	//iPrintLnBold("got nuke");
	exploder("nuke_explosion");
}

nuke_missiles_fx( nuke_crash_missile1, nuke_crash_missile2, nuke_crash_missile3 )
{
	wait 11;
	//iPrintLnBold("got missiles");

	PlayFXOnTag( level._effect[ "nx_rocket_trail_nuke_missile" ],  nuke_crash_missile1, "tag_origin" );
	wait .5;
	PlayFXOnTag( level._effect[ "nx_rocket_trail_nuke_missile" ],  nuke_crash_missile2, "tag_origin" );
	wait 0.05;
	PlayFXOnTag( level._effect[ "nx_rocket_trail_nuke_missile" ],  nuke_crash_missile3, "tag_origin" );
}

treadfx_override()
{

	flying_tread_fx = "nx/treadfx/nx_blackhawk_minigun_water_default";

	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "brick",			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "bark",			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "carpet", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "cloth", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "concrete",		undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "dirt", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "flesh", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "foliage", 		undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "glass", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "grass", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "gravel", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "ice", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "metal", 			undefined	);
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "mud", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "paper", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "plaster", 		undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "rock", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "sand", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "snow", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "slush", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "water", 			flying_tread_fx );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "wood", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "asphalt", 		undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "ceramic", 		undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "plastic", 		undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "rubber", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "cushion", 		undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "fruit", 			undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "painted metal", 	undefined );
 	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "default", 		undefined );
	maps\_treadfx::setvehiclefx( "nx_blackhawk_minigun", "none", 			undefined );

}

/*
rocket_01_prelaunch_fx()
{
	// This script should end early if the rocket gets destroyed
	level endon( "rocket_1_destroyed" );

	flag_wait( "chopper_ride_starting_rocket_one_loop" );
	//iPrintLnBold("got rocket 1");
	wait 8;
	exploder("rocketlaunch01_base_smoke_jets");
	exploder("rocketlaunch01_base_sparkjets");
	wait 8;
	exploder("rocketlaunch01_jet_ignite");
	wait 2;
	exploder("rocketlaunch01_exhaust");
	wait 9;
	//PlayFXOnTag( level._effect[ "nx_smoke_rocket_afterburner_liftoff" ], rocket, "tag_origin" );
	wait 1;

	exploder("rocketlaunch01_blast");
	//rocket MoveTo( rocket.origin + (0,0,30000), 40, 5, 0.1 );
	//rocket playloopsound("rocket_launch_loop");//looping rocket sound for when it goes in the air forever

	// Stop FX with:
	wait 12;
	stop_exploder_nx( "rocketlaunch01_base_smoke_jets" );
	stop_exploder_nx( "rocketlaunch01_base_sparkjets" );
	stop_exploder_nx( "rocketlaunch01_jet_ignite" );
	stop_exploder_nx( "rocketlaunch01_blast" );
	stop_exploder_nx( "rocketlaunch01_exhaust" );
}
*/

fallenrocket_fx()
{
	//flag_wait( "base_echo_wave_player" );
	exploder("fallenrocket_fx");
}

fallenrocket_fx_cleanup()
{
	flag_wait( "base_echo_exit" );
	stop_exploder_nx( "fallenrocket_fx" );
}

rocket_introfx_cleanup()
{
	//flag_wait( "base_echo_exit" );
	flag_wait( "chopper_path_entering_base_alpha" );
	//iPrintLnBold("got intro cleanup");
	fx_delete_createFXEnt_by_vol( "rocket_introfx_volume", true, true );
	wait 0.5;
	fx_delete_createFXEnt_by_vol( "rocket_introfx_volume_02", true, true );
}
rocket_introfx_cleanup_delta()
{
	//flag_wait( "base_echo_exit" );
	flag_wait( "flag_entered_base_delta" );
	//iPrintLnBold("got intro cleanup delta");
	fx_delete_createFXEnt_by_vol( "rocket_introfx_volume", true, true );
	wait 0.5;
	fx_delete_createFXEnt_by_vol( "rocket_introfx_volume_02", true, true );
}

forest_fire_fx()
{
	flag_wait( "turret_control_complete" );
	exploder("forestfire_fx");
}

rocket_01_hit_fx( rocket_one )
{

	if( isDefined( level.active_rail_shot ))
	{
		//iPrintLnBold("got rocket sauce");
		missile_angles = level.active_rail_shot.angles;
		forward = anglestoforward( missile_angles ) * -1;
		//MagicBullet( "nx_rocket_railgun_secondary", self.origin, self.origin + forward );
		PlayFX( level._effect[ "nx_rocket_railgun_hit_01" ],  level.active_rail_shot.origin, forward );
	}
	
	//Audio: Play ground big explosion.
	//Iprintlnbold( "AUDIO: GROUND ROCKET 1 EXPL" );
	rocket_one PlaySound( "scn_rocket_lrgrocket_ground_expl" );

	quakeobj = spawn( "script_origin", level._player.origin );
	quakeobj PlayRumbleOnEntity( "artillery_rumble" );
	Earthquake( .5, 1.0, level._player.origin, 5000 );
	wait 1;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_one, "j_nx_pr_rocket_shuttle_exp1_011_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_rocket" ],  rocket_one, "j_nx_pr_rocket_shuttle_exp1_012_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_one, "j_nx_pr_rocket_shuttle_exp1_010_1");
	wait 2;
	PlayFXOnTag( level._effect[ "nx_explosion_rocket01_runner" ],  rocket_one, "j_nx_pr_rocket_shuttle_exp1_011_1");
	rocket_one PlaySound( "scn_rocket_lrgrocket_runner_expl" );

    while ( true )
    {
        if ( rocket_one.origin[ 2 ] < -30 )
        {
			//iPrintLnBold("roooockkettt");
            Earthquake( .3, 1.0, level._player.origin, 5000 );
            quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			exploder("rocket01_explosion_small");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 2.0;
			exploder("rocket01_explosion_small_02");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 4.5;
			exploder("rocket01_explosion");
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .5, 2.5, level._player.origin, 5000 );
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
            break;
        }
        wait 0.05;
    }
}

rocket_02_hit_fx( rocket_two )
{
	if( isDefined( level.active_rail_shot ))
	{
		//iPrintLnBold("got rocket sauce");
		missile_angles = level.active_rail_shot.angles;
		forward = anglestoforward( missile_angles ) * -1;
		//MagicBullet( "nx_rocket_railgun_secondary", self.origin, self.origin + forward );
		PlayFX( level._effect[ "nx_rocket_railgun_hit_01" ],  level.active_rail_shot.origin, forward );
	}


	//Audio: Play ground big explosion
	//Iprintlnbold( "AUDIO: GROUND ROCKET 2 EXPL" );
	rocket_two PlaySound( "scn_rocket_lrgrocket_ground_expl" );

	quakeobj = spawn( "script_origin", level._player.origin );
	quakeobj PlayRumbleOnEntity( "artillery_rumble" );
	Earthquake( .5, 1.0, level._player.origin, 5000 );
	wait 1;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_two, "j_nx_pr_rocket_shuttle_exp1_021_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_rocket" ],  rocket_two, "j_nx_pr_rocket_shuttle_exp1_022_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_two, "j_nx_pr_rocket_shuttle_exp1_020_1");
	wait 2;
	PlayFXOnTag( level._effect[ "nx_explosion_rocket01_runner" ],  rocket_two, "j_nx_pr_rocket_shuttle_exp1_021_1");
	rocket_two PlaySound( "scn_rocket_lrgrocket_runner_expl" );

    while ( true )
    {
        if ( rocket_two.origin[ 2 ] < -150 )
        {
			//iPrintLnBold("roooockkettt");
            Earthquake( .3, 1.0, level._player.origin, 5000 );
            quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			exploder("rocket02_explosion_small");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 2.0;
			exploder("rocket02_explosion_small_02");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 4.5;
			exploder("rocket02_explosion");
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .5, 2.5, level._player.origin, 5000 );
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
            break;
        }
        wait 0.05;
    }
}

rocket_03_hit_fx( rocket_three )
{
	if( isDefined( level.active_rail_shot ))
	{
		//iPrintLnBold("got rocket sauce");
		missile_angles = level.active_rail_shot.angles;
		forward = anglestoforward( missile_angles ) * -1;
		//MagicBullet( "nx_rocket_railgun_secondary", self.origin, self.origin + forward );
		PlayFX( level._effect[ "nx_rocket_railgun_hit_01" ],  level.active_rail_shot.origin, forward );
	}

	//Audio: Play ground big explosion
	//Iprintlnbold( "AUDIO: GROUND ROCKET 3 EXPL" );
	rocket_three PlaySound( "scn_rocket_lrgrocket_ground_expl" );

	quakeobj = spawn( "script_origin", level._player.origin );
	quakeobj PlayRumbleOnEntity( "artillery_rumble" );
	Earthquake( .5, 1.0, level._player.origin, 5000 );
	wait 1;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_three, "j_nx_pr_rocket_shuttle_exp1_031_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_rocket" ],  rocket_three, "j_nx_pr_rocket_shuttle_exp1_032_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_three, "j_nx_pr_rocket_shuttle_exp1_030_1");
	wait 2;
	PlayFXOnTag( level._effect[ "nx_explosion_rocket01_runner" ],  rocket_three, "j_nx_pr_rocket_shuttle_exp1_031_1");
	rocket_three PlaySound( "scn_rocket_lrgrocket_runner_expl" );

    while ( true )
    {
        if ( rocket_three.origin[ 2 ] < 1800 )
        {
			//iPrintLnBold("roooockkettt");
            Earthquake( .3, 1.0, level._player.origin, 5000 );
            quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			exploder("rocket03_explosion_small");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 2.0;
			exploder("rocket03_explosion_small_02");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 4.5;
			exploder("rocket03_explosion");
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .5, 2.5, level._player.origin, 5000 );
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
            break;
        }
        wait 0.05;
    }
}

rocket_04_hit_fx( rocket_four )
{
	if( isDefined( level.active_rail_shot ))
	{
		//iPrintLnBold("got rocket sauce");
		missile_angles = level.active_rail_shot.angles;
		forward = anglestoforward( missile_angles ) * -1;
		//MagicBullet( "nx_rocket_railgun_secondary", self.origin, self.origin + forward );
		PlayFX( level._effect[ "nx_rocket_railgun_hit_01" ],  level.active_rail_shot.origin, forward );
	}

	//Audio: Play ground big explosion
	//Iprintlnbold( "AUDIO: GROUND ROCKET 4 EXPL" );
	rocket_four PlaySound( "scn_rocket_lrgrocket_ground_expl" );

	quakeobj = spawn( "script_origin", level._player.origin );
	quakeobj PlayRumbleOnEntity( "artillery_rumble" );
	Earthquake( .5, 1.0, level._player.origin, 5000 );
	wait 1;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_four, "j_nx_pr_rocket_shuttle_exp1_041_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_rocket" ],  rocket_four, "j_nx_pr_rocket_shuttle_exp1_042_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_four, "j_nx_pr_rocket_shuttle_exp1_040_1");
	wait 2;
	PlayFXOnTag( level._effect[ "nx_explosion_rocket01_runner" ],  rocket_four, "j_nx_pr_rocket_shuttle_exp1_041_1");
	rocket_four PlaySound( "scn_rocket_lrgrocket_runner_expl" );

    while ( true )
    {
        if ( rocket_four.origin[ 2 ] < 190 )
        {
			//iPrintLnBold("roooockkettt");
            Earthquake( .3, 1.0, level._player.origin, 5000 );
            quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			exploder("rocket04_explosion_small");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 2.0;
			exploder("rocket04_explosion_small_02");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 4.5;
			exploder("rocket04_explosion");
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .5, 2.5, level._player.origin, 5000 );
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
            break;
        }
        wait 0.05;
    }
}

rocket_01_launch_hit_fx( rocket_one )
{
	if( isDefined( level.active_rail_shot ))
	{
		//iPrintLnBold("got rocket sauce");
		missile_angles = level.active_rail_shot.angles;
		forward = anglestoforward( missile_angles ) * -1;
		//MagicBullet( "nx_rocket_railgun_secondary", self.origin, self.origin + forward );
		PlayFX( level._effect[ "nx_rocket_railgun_hit_01" ],  level.active_rail_shot.origin, forward );
	}

	//Audio: Play launch explosion 01
	//Iprintlnbold( "AUDIO: LAUNCH ROCKET 1 EXPL_01" );
	rocket_one PlaySound( "scn_rocket_lrgrocket_launch_expl_01" );

	quakeobj = spawn( "script_origin", level._player.origin );
	quakeobj PlayRumbleOnEntity( "artillery_rumble" );
	Earthquake( .5, 1.0, level._player.origin, 5000 );
	wait 1;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_one, "j_nx_pr_rocket_shuttle_exp1_011_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_rocket" ],  rocket_one, "j_nx_pr_rocket_shuttle_exp1_012_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_one, "j_nx_pr_rocket_shuttle_exp1_010_1");
	wait 1;
	PlayFXOnTag( level._effect[ "nx_explosion_rocket01_runner" ],  rocket_one, "j_nx_pr_rocket_shuttle_exp1_011_1");
	rocket_one PlaySound( "scn_rocket_lrgrocket_runner_expl" );

    while ( true )
    {
        if ( rocket_one.origin[ 2 ] < 8 )
        {
			//iPrintLnBold("roooockkettt");

			//Audio: Play launch explosion 02
			//Iprintlnbold( "AUDIO: LAUNCH ROCKET 1 EXPL_02" );
			rocket_one PlaySound( "scn_rocket_lrgrocket_launch_expl_02" );

            Earthquake( .3, 1.0, level._player.origin, 5000 );
            quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			exploder("rocket01_explosion_small");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 2.0;
			exploder("rocket01_explosion_small_02");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 4.5;
			exploder("rocket01_explosion");
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .5, 2.5, level._player.origin, 5000 );
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
            break;
        }
        wait 0.05;
    }
}

rocket_02_launch_hit_fx( rocket_two )
{
	if( isDefined( level.active_rail_shot ))
	{
		//iPrintLnBold("got rocket sauce");
		missile_angles = level.active_rail_shot.angles;
		forward = anglestoforward( missile_angles ) * -1;
		//MagicBullet( "nx_rocket_railgun_secondary", self.origin, self.origin + forward );
		PlayFX( level._effect[ "nx_rocket_railgun_hit_01" ],  level.active_rail_shot.origin, forward );
	}

	//Audio: Play launch explosion 01
	//Iprintlnbold( "AUDIO: LAUNCH ROCKET 2 EXPL_01" );
	rocket_two PlaySound( "scn_rocket_lrgrocket_launch_expl_01" );

	quakeobj = spawn( "script_origin", level._player.origin );
	quakeobj PlayRumbleOnEntity( "artillery_rumble" );
	Earthquake( .5, 1.0, level._player.origin, 5000 );
	wait 1;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_two, "j_nx_pr_rocket_shuttle_exp1_011_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_rocket" ],  rocket_two, "j_nx_pr_rocket_shuttle_exp1_012_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_two, "j_nx_pr_rocket_shuttle_exp1_010_1");
	wait 1;
	PlayFXOnTag( level._effect[ "nx_explosion_rocket01_runner" ],  rocket_two, "j_nx_pr_rocket_shuttle_exp1_011_1");
	rocket_two PlaySound( "scn_rocket_lrgrocket_runner_expl" );

    while ( true )
    {
        if ( rocket_two.origin[ 2 ] < 0 )
        {
			//iPrintLnBold("roooockkettt");

			//Audio: Play launch explosion 02
			//Iprintlnbold( "AUDIO: LAUNCH ROCKET 2 EXPL_02" );
			rocket_two PlaySound( "scn_rocket_lrgrocket_launch_expl_02" );

            Earthquake( .3, 1.0, level._player.origin, 5000 );
            quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			exploder("rocket02_explosion_small");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 2.0;
			exploder("rocket02_explosion_small_02");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 4.5;
			exploder("rocket02_explosion");
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .5, 2.5, level._player.origin, 5000 );
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
            break;
        }
        wait 0.05;
    }
}

rocket_03_launch_hit_fx( rocket_three )
{
	if( isDefined( level.active_rail_shot ))
	{
		//iPrintLnBold("got rocket sauce");
		missile_angles = level.active_rail_shot.angles;
		forward = anglestoforward( missile_angles ) * -1;
		//MagicBullet( "nx_rocket_railgun_secondary", self.origin, self.origin + forward );
		PlayFX( level._effect[ "nx_rocket_railgun_hit_01" ],  level.active_rail_shot.origin, forward );
	}

	//Audio: Play launch explosion 01
	//Iprintlnbold( "AUDIO: LAUNCH ROCKET 3 EXPL_01" );
	rocket_three PlaySound( "scn_rocket_lrgrocket_launch_expl_01" );

	quakeobj = spawn( "script_origin", level._player.origin );
	quakeobj PlayRumbleOnEntity( "artillery_rumble" );
	Earthquake( .5, 1.0, level._player.origin, 5000 );
	wait 1;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_three, "j_nx_pr_rocket_shuttle_exp1_011_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_rocket" ],  rocket_three, "j_nx_pr_rocket_shuttle_exp1_012_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_three, "j_nx_pr_rocket_shuttle_exp1_010_1");
	wait 1;
	PlayFXOnTag( level._effect[ "nx_explosion_rocket01_runner" ],  rocket_three, "j_nx_pr_rocket_shuttle_exp1_011_1");
	rocket_three PlaySound( "scn_rocket_lrgrocket_runner_expl" );

    while ( true )
    {
        if ( rocket_three.origin[ 2 ] < 2300 )
        {
			//Audio: Play launch explosion 01
			//Iprintlnbold( "AUDIO: LAUNCH ROCKET 3 EXPL_02" );
			rocket_three PlaySound( "scn_rocket_lrgrocket_launch_expl_02" );

			//iPrintLnBold("roooockkettt");
            Earthquake( .3, 1.0, level._player.origin, 5000 );
            quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			exploder("rocket03_explosion_small");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 2.0;
			exploder("rocket03_explosion_small_02");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 4.5;
			exploder("rocket03_explosion");
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .5, 2.5, level._player.origin, 5000 );
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
            break;
        }
        wait 0.05;
    }
}

rocket_04_launch_hit_fx( rocket_four )
{
	if( isDefined( level.active_rail_shot ))
	{
		//iPrintLnBold("got rocket sauce");
		missile_angles = level.active_rail_shot.angles;
		forward = anglestoforward( missile_angles ) * -1;
		//MagicBullet( "nx_rocket_railgun_secondary", self.origin, self.origin + forward );
		PlayFX( level._effect[ "nx_rocket_railgun_hit_01" ],  level.active_rail_shot.origin, forward );
	}

	//Audio: Play launch explosion 01
	//Iprintlnbold( "AUDIO: LAUNCH ROCKET 4 EXPL_01" );
	rocket_four PlaySound( "scn_rocket_lrgrocket_launch_expl_01" );

	quakeobj = spawn( "script_origin", level._player.origin );
	quakeobj PlayRumbleOnEntity( "artillery_rumble" );
	Earthquake( .5, 1.0, level._player.origin, 5000 );
	wait 1;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_four, "j_nx_pr_rocket_shuttle_exp1_011_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_rocket" ],  rocket_four, "j_nx_pr_rocket_shuttle_exp1_012_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_four, "j_nx_pr_rocket_shuttle_exp1_010_1");
	wait 1;
	PlayFXOnTag( level._effect[ "nx_explosion_rocket01_runner" ],  rocket_four, "j_nx_pr_rocket_shuttle_exp1_011_1");
	rocket_four PlaySound( "scn_rocket_lrgrocket_runner_expl" );

    while ( true )
    {
        if ( rocket_four.origin[ 2 ] < 200 )
        {
			//iPrintLnBold("roooockkettt");
			//Audio: Play launch explosion 02
			//Iprintlnbold( "AUDIO: LAUNCH ROCKET 4 EXPL_02" );
			rocket_four PlaySound( "scn_rocket_lrgrocket_launch_expl_02" );

            Earthquake( .3, 1.0, level._player.origin, 5000 );
            quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			exploder("rocket04_explosion_small");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 2.0;
			exploder("rocket04_explosion_small_02");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 4.5;
			exploder("rocket04_explosion");
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .5, 2.5, level._player.origin, 5000 );
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
            break;
        }
        wait 0.05;
    }
}

aa_rocket_hit_fx( rocket_four_p1, rocket_four_p2, rocket_four_p3 )
{
	PlayFXOnTag( level._effect[ "nx_rocket_railgun_hit_01" ],  rocket_four_p2, "j_nx_pr_rocket_shuttle_exp1_041_1");
	quakeobj = spawn( "script_origin", level._player.origin );
	quakeobj PlayRumbleOnEntity( "artillery_rumble" );
	Earthquake( .5, 1.0, level._player.origin, 5000 );
	wait 1;
	PlayFXOnTag( level._effect[ "nx_explosion_rocket_01" ],  rocket_four_p2, "j_nx_pr_rocket_shuttle_exp1_041_1");
	wait 2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_four_p2, "j_nx_pr_rocket_shuttle_exp1_041_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_rocket" ],  rocket_four_p3, "j_nx_pr_rocket_shuttle_exp1_042_1");
	wait 0.2;
	PlayFXOnTag( level._effect[ "nx_fire_smoke_trail_emitter_large" ],  rocket_four_p1, "j_nx_pr_rocket_shuttle_exp1_040_1");
	//wait 1;
	//PlayFXOnTag( level._effect[ "nx_explosion_rocket01_runner" ],  rocket_four_p2, "j_nx_pr_rocket_shuttle_exp1_041_1");

/*
    while ( true )
    {
        if ( rocket_four_p1.origin[ 2 ] < -20 )
        {
			//iPrintLnBold("roooockkettt");
            Earthquake( .3, 1.0, level._player.origin, 5000 );
            quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			exploder("rocket04_explosion_small");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 2.0;
			exploder("rocket04_explosion_small_02");
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .3, 1.0, level._player.origin, 5000 );
			wait 4.5;
			exploder("rocket04_explosion");
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
			Earthquake( .5, 2.5, level._player.origin, 5000 );
			wait 0.5;
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );
            break;
        }
        wait 0.05;
    }
	*/
}

fx_init_flags()
{
	// flags you're using need to be initialized	
	//flag_init( "flag_hanging_ext_01" );
	//flag_init( "flag_turret_int_01" );
	flag_init( "intro_delete_ocean_a" );
	flag_init( "intro_delete_ocean_b" );
	flag_init( "intro_delete_ocean_c" );
	flag_init( "intro_delete_ocean_d" );
}

fx_vision_fog_init()
{
	thread set_intro_chopper_light();
	thread trigger_vf_default();
	thread trigger_vf_base_alpha();
	thread trigger_vf_bridge();
	thread trigger_vf_crash();
	thread trigger_vf_base_delta();
	thread trigger_vf_hanging();
	// NX_ROCKET_GREENLIGHT: Removing unnecessary sections
	//thread trigger_vf_rescue();
	//thread trigger_vf_turret_base();
	//thread trigger_vf_turret_destroyed();
}

// set the vision and fog settings for the default exterior
set_default_vision_and_fog(transition_time)
{
	SetSavedDvar( "sm_sunSampleSizeNear", 2.0 );
	VisionSetNaked("nx_rocket", transition_time);
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <mulBlend2> 
	//<NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>,
	//<sunRed>, <sunGreen>, <sunBlue>, <sunDir>, <sunBeginFadeAngle>, <sunEndFadeAngle>, <sunFogScale>);
	setExpFog( 25100, 60000, 0.4901961, 0.5764706, 0.6156863, 0.56, transition_time, 0.3249, 0, 1, 1, 1, 0.5490196, 0.654902, 0.7764706, 0.7372549, 0.7019608, 0.827451, ( 0.8, 0.5, 0 ), 0, 110, 0.54 );
	// fx_set_skyfog( height_start, height_end, height_blend, transition_time );
	fx_set_skyfog( 1.5, 3, 0.85, transition_time );
}

set_intro_chopper_light()
{
	flag_wait( "started_intro_anim" );
	if( level.playerHeli DoesTagExistOnEntity( "tag_ai_turret_mount_l" ) == 1 )
	{
		//println("Tag Exists");
		PlayFXOnTag( level._effect[ "intro_chopper_light" ],  level.playerHeli, "tag_ai_turret_mount_l");
		//wait 0.01;
	}
}

// set the vision and fog settings for base alpha
set_base_alpha_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_rocket_intro", transition_time);	
	setExpFog( 1444, 27437, 0.5254902, 0.5372549, 0.6078432, 0.1805, transition_time, 0.7436, 0, 0.5058824, 0.5058824, 0.5058824, 0.4352941, 0.4352941, 0.5176471, 0.5529412, 0.5058824, 0.4627451, ( 0.978427, 0.0227989, 0.205329 ), 33, 87, 1.19 );	
}

// set the vision and fog settings for bridge
set_bridge_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_rocket_bridge", transition_time);
	//setExpFog( 7581, 36462, 0.5411765, 0.5490196, 0.5921569, 0.8411667, 0, 0.4801, 0, 0.5647059, 0.5647059, 0.5647059, 0.3411765, 0.3411765, 0.4078431, 0.5529412, 0.5058824, 0.4627451, ( 0.978427, 0.0227989, 0.205329 ), 33, 87, 1.19 );
	setExpFog( 4693, 24694, 0.8666667, 0.8666667, 0.8666667, 0.4621, transition_time, 0.9314, 0, 0.563, 0.563, 0.563, 0.454902, 0.4784314, 0.5450981, 0.7529412, 0.7529412, 0.7529412, ( 0.7965, 0.5273, 0.2960 ), 36, 80, 3.0 );	
}

set_crash_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_rocket_crash", transition_time);
	setExpFog( 3249, 34622, 0.854902, 0.854902, 0.854902, 0.212667, transition_time, 0.9314, 0, 0.563, 0.563, 0.563, 0.3333333, 0.3607843, 0.4235294, 0.7529412, 0.7529412, 0.7529412, ( 0.7965, 0.5273, 0.2960 ), 36, 80, 3.0 );
}

set_base_delta_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_rocket_delta", transition_time);
	setExpFog( 3249, 34622, 0.854902, 0.854902, 0.854902, 0.212667, transition_time, 0.9314, 0, 0.563, 0.563, 0.563, 0.3333333, 0.3607843, 0.4235294, 0.7529412, 0.7529412, 0.7529412, ( 0.7965, 0.5273, 0.2960 ), 36, 80, 3.0 );
}

// set the vision and fog settings for the exterior hanging section
set_hanging_vision_and_fog(transition_time)
{
	SetSavedDvar( "sm_sunSampleSizeNear", 0.25 );
	VisionSetNaked("nx_rocket_hanging", transition_time);
	setExpFog( 2888, 9568, 0.8235294, 0.7372549, 0.5764706, .25, transition_time, 0.148, 0, 1, 1, 1, 0.1411765, 0.1215686, 0.07450981 );
}

// set the vision and fog settings for base alpha
set_turret_base_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_rocket", transition_time);
	setExpFog( 920, 9930, 0.7058824, 0.7058824, 0.7058824, 0.1924, transition_time, 0.81, 0, 0.6784314, 0.6784314, 0.6784314, 0.4705882, 0.4705882, 0.4705882, 0.3411765, 0.3803922, 0.3921569, ( 0, 0, -1 ), 85, 95, 0); //5.69 );
	//setExpFog( 700, 9929, 0.7019608, 0.7019608, 0.7019608, 0.1696667, 0, 0.7833667, 0, 0.6745098, 0.6745098, 0.6745098, 0.4666667, 0.4666667, 0.4666667, 0.3372549, 0.3764706, 0.3921569, ( 0, 0, -1 ), 0, 95, 0 );
	fx_set_skyfog(0.3, 0.8, 0.5, transition_time);
}

set_turret_destroyed_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_rocket", transition_time);
	setExpFog( 300, 8665, 0.7019608, 0.6392157, 0.4941176, 0.1227, 0, 0.1624667, 0, 0.5019608, 0.5019608, 0.5019608, 0.5019608, 0.5019608, 0.5019608, 0.427451, 0.3764706, 0.3058824, ( 0, 0, -1 ), 85, 93, 0); //1.5 );
}

// set the vision and fog settings for base alpha
set_rescue_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_rocket", transition_time);
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 0, 12095, 0.4941176, 0.5686275, 0.572549, 0.05416667, transition_time, 0.5667667, 0, 0.5921569, 0.4941176, 0.4078431, 0.4823529, 0.5019608, 0.5176471 );
}

set_vision_and_fog(area, transition_time)
{
	//iPrintLnBold("Change vision and fog - " + area);
	switch ( area )
	{
		case "base_alpha":
			set_base_alpha_vision_and_fog(transition_time);
			break;
		case "bridge":
			set_bridge_vision_and_fog(transition_time);
			break;
		case "base_delta":
			set_base_delta_vision_and_fog(transition_time);
			break;
		case "crash":
			set_crash_vision_and_fog(transition_time);
			break;
		case "hanging":		
			set_hanging_vision_and_fog(transition_time);
			break;
		case "turret_base":
			set_turret_base_vision_and_fog(transition_time);
			break;
		case "turret_destroyed":
			set_turret_destroyed_vision_and_fog(transition_time);
			break;
		case "rescue":
			set_rescue_vision_and_fog(transition_time);
			break;
		case "default":
			set_default_vision_and_fog(transition_time);
			break;
		default:
			set_default_vision_and_fog(transition_time);
	}
}

intro_vision_sequencing()
{
	// iPrintLnBold("START: intro_vision_sequencing");	
	VisionSetNaked("nx_rocket", 0);
	wait 10;
	VisionSetNaked("nx_rocket_intro_1", 3.0);
	wait 27;
	VisionSetNaked("nx_rocket_intro_2",5.0);
	wait 8;
	VisionSetNaked("nx_rocket_intro_3",5.0);
	wait 12;
	VisionSetNaked("nx_rocket_intro_4",10.0);
}

trigger_vf_default()
{
	//flag_wait( "chopper_ride_bridge_intro" );
	set_vision_and_fog("default", 0);
}

trigger_vf_base_alpha()
{
	flag_wait( "chopper_path_entering_base_alpha" );
	set_vision_and_fog("base_alpha", 5.0);
}

trigger_vf_bridge()
{
	//flag_wait( "chopper_ride_bridge_intro" );
	flag_wait( "music_chk_bridge" );
	wait 7;
	set_vision_and_fog("bridge", 7);
}

trigger_vf_base_delta()
{
	flag_wait( "flag_entered_base_delta" );
	set_vision_and_fog("base_delta", 10.0);
}

trigger_vf_crash()
{
	flag_wait( "crash_section_transition" );
	set_vision_and_fog("crash", 12.0);
}

trigger_vf_hanging()
{
	self waittill( "hanging_player_start_before_fadein" );
	set_vision_and_fog("hanging", 0);
}

trigger_vf_turret_base()
{
	flag_wait( "discovered_aa_base" );
	set_vision_and_fog("turret_base", 10);
}

trigger_vf_turret_destroyed()
{
	flag_wait("turret_control_complete");
	lgts = getentarray( "lgt_turret_1", "targetname" );
	for ( i = 0; i < lgts.size; i++ )
	{
		if ( is_light_entity( lgts[ i ] ) )
		{		
			lgts[ i ] setLightIntensity (0.75);
		}
	}
	set_vision_and_fog("turret_destroyed", 8);
}

trigger_vf_rescue()
{
	flag_wait( "turret_destroyed" );

	set_vision_and_fog("rescue", 10);	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
