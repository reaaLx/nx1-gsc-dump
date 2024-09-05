//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  FX Support													**
//                                                                          **
//    Created: 2010 Brian Marvin											**
//                                                                          **
//****************************************************************************
#include maps\_utility;
#include common_scripts\utility;

main()
{
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\nx_hithard_fx::main();
	}

	SetSavedDVar ("r_fog_height_blend", 0.80);
	SetSavedDVar ("r_fog_height_start", 0.6);
	SetSavedDVar ("r_fog_height_end", 1.40);

	
	//ambient fx
	level._effect[ "nx_smoke_plume_large_03_preseed" ]					= loadfx( "nx/smoke/nx_smoke_plume_large_03_preseed" );	
	level._effect[ "100ton_bomb_cheap" ]								= loadfx( "nx/explosions/nx_110ton_bomb_cheap" );	
	level._effect[ "nx_grenade_smoke_5sec" ]							= loadfx( "nx/smoke/nx_grenade_smoke_5sec" );	
	level._effect[ "firelp_med_pm_bh1" ] 								= LoadFX( "fire/firelp_med_pm" );
	level._effect[ "nx_smoke_wall_long_preseed" ] 						= LoadFX( "nx/smoke/nx_smoke_wall_long_preseed" );
  	level._effect[ "nx_smoke_wall_long_04_preseed" ] 					= LoadFX( "nx/smoke/nx_smoke_wall_long_04_preseed" );
	level._effect[ "nx_smoke_wall_street_preseed" ] 					= LoadFX( "nx/smoke/nx_smoke_wall_street_preseed" );
	level._effect[ "nx_smoke_plume_huge" ] 								= LoadFX( "nx/smoke/nx_smoke_plume_huge" );
	level._effect[ "nx_amb_smoke_blend_large" ] 						= LoadFX( "nx/smoke/nx_amb_smoke_blend_large" );
	level._effect[ "nx_amb_smoke_blend_large_02" ] 						= LoadFX( "nx/smoke/nx_amb_smoke_blend_large_02" );
	level._effect[ "nx_ash_cloud_light" ] 								= LoadFX( "nx/misc/nx_ash_cloud_light" );
	level._effect[ "nx_ash_cloud_heavy" ] 								= LoadFX( "nx/misc/nx_ash_cloud_heavy" );
    level._effect[ "ash_turb_aftermath" ]								= LoadFX( "weather/ash_turb_aftermath" );
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
    level._effect[ "police_lights" ]									= LoadFX( "nx/misc/nx_light_police_lights" );
    level._effect[ "fire_light" ]										= LoadFX( "nx/misc/nx_light_orange_large" );
    level._effect[ "fire_light_small" ]									= LoadFX( "nx/misc/nx_light_orange_small" );
    level._effect[ "nx_light_emergency_red" ]							= LoadFX( "nx/misc/nx_light_emergency_red" );
    level._effect[ "blast_mark" ]										= LoadFX( "nx/misc/nx_blast_mark_large" );
    level._effect[ "blast_mark_02" ]									= LoadFX( "nx/misc/nx_blast_mark_large_02" );
	level._effect[ "godray_large" ]										= LoadFX( "nx/misc/nx_gfx_godray_side" );
	level._effect[ "godray_huge" ]										= LoadFX( "nx/misc/nx_gfx_godray_side_huge" );
	level._effect[ "nx_smoke_missilehits_periph" ]						= LoadFX( "nx/smoke/nx_smoke_missilehits_periph" );
	level._effect[ "nx_smoke_missilehits_periph_no_child" ]				= LoadFX( "nx/smoke/nx_smoke_missilehits_periph_no_child" );
	level._effect[ "nx_fire_buildingtop_embers" ]						= LoadFX( "nx/fire/nx_fire_buildingtop_embers" );
	level._effect[ "nx_fire_buildingtop_embers_preseed" ]				= LoadFX( "nx/fire/nx_fire_buildingtop_embers_preseed" );
	level._effect[ "embers_whitehouse" ]								= LoadFX( "fire/embers_whitehouse" );
	level._effect[ "nx_ash_cloud_heavy_parkinglot" ]					= LoadFX( "nx/misc/nx_ash_cloud_heavy_parkinglot" );
	level._effect[ "nx_big_orange_glows" ]								= LoadFX( "nx/misc/nx_big_orange_glows" );
	level._effect[ "nx_fire_tree_embers_preseed" ]						= LoadFX( "nx/fire/nx_fire_tree_embers_preseed" );
	level._effect[ "nx_fire_buildingtop_03_preseed" ]					= LoadFX( "nx/fire/nx_fire_buildingtop_03_preseed" );
	level._effect[ "battlefield_smokebank_S_warm" ]						= LoadFX( "smoke/battlefield_smokebank_S_warm" );
	level._effect[ "nx_smoke_parkinglot_entrance_preseed" ]				= LoadFX( "nx/smoke/nx_smoke_parkinglot_entrance_preseed" );
	level._effect[ "nx_explosion_skybridge" ]							= LoadFX( "nx/explosions/nx_explosion_skybridge" );
	level._effect[ "nx_smoke_n_fire_plume_preseed" ]					= LoadFX( "nx/smoke/nx_smoke_n_fire_plume_preseed" );
	level._effect[ "nx_smoke_n_fire_plume_small_preseed" ]				= LoadFX( "nx/smoke/nx_smoke_n_fire_plume_small_preseed" );
	level._effect[ "nx_smoke_mid_bldg_preseed" ]						= LoadFX( "nx/smoke/nx_smoke_mid_bldg_preseed" );
	level._effect[ "nx_fire_building_distant" ]							= LoadFX( "nx/fire/nx_fire_building_distant" );
	level._effect[ "nx_smoke_n_fire_plume_side_preseed" ]				= LoadFX( "nx/smoke/nx_smoke_n_fire_plume_side_preseed" );

	//temp building 1 hit fx
	level._effect[ "tracer_incoming_bh1" ] 								= LoadFX( "nx/misc/nx_tracer_incoming" );
	level._effect[ "nx_buildinghit1_props_exp" ]						= LoadFX( "nx/props/nx_buildinghit1_props_exp" );
	level._effect[ "nx_building01_missilehit" ]							= LoadFX( "nx/explosions/nx_building01_missilehit" );
	level._effect[ "nx_fire_buildingtop_02" ]							= LoadFX( "nx/fire/nx_fire_buildingtop_02" );
	level._effect[ "nx_building01_missilehit_windows" ]					= LoadFX( "nx/explosions/nx_building01_missilehit_windows" );
	level._effect[ "nx_building01_missilehit_windows_small" ]			= LoadFX( "nx/explosions/nx_building01_missilehit_windows_small" );
	level._effect[ "nx_building01_explosion" ]							= loadfx( "nx/explosions/nx_building01_explosion" );	
	level._effect[ "nx_building01_explosion_small" ]					= loadfx( "nx/explosions/nx_building01_explosion_small" );	


	// blinking light on your parachute dudes jumping out of the plane
	level._effect[ "aircraft_light_white_blink" ]						= loadfx( "misc/aircraft_light_white_blink" );

	// Building 2
	level._effect[ "nx_hhh_bldg_fire_column_big_01_preseed" ]			= loadfx( "nx/hithard/nx_hhh_bldg_fire_column_big_01_preseed" );
	level._effect[ "nx_hhh_bldg_fire_column_dark_01_preseed" ]			= loadfx( "nx/hithard/nx_hhh_bldg_fire_column_dark_01_preseed" );
	level._effect[ "nx_hhh_bldg_fire_column_dark_02_preseed" ]			= loadfx( "nx/hithard/nx_hhh_bldg_fire_column_dark_02_preseed" );
	level._effect[ "nx_hhh_bldg_smoke_column_thin_01" ]					= loadfx( "nx/hithard/nx_hhh_bldg_smoke_column_thin_01" );
	level._effect[ "nx_hhh_bldg_2_falling_brick_runner" ]				= loadfx( "nx/hithard/nx_hhh_bldg_2_falling_brick_runner" );
	level._effect[ "nx_distortion_large" ]								= loadfx( "nx/misc/nx_distortion_large" );
	
	// Building 3
	level._effect[ "smoke_column_light01" ]								= loadfx( "nx/hithard/nx_hhh_bldg3_fire_column_light_01" );
	level._effect[ "bld_damage_card01" ]								= loadfx( "nx/hithard/nx_bld_dmg_card_blend01" );
	level._effect[ "bld_damage_card01_wfire" ]							= loadfx( "nx/hithard/nx_bld_dmg_fire_card_blend01" );
	level._effect[ "bld_damage_card02_wfire" ]							= loadfx( "nx/hithard/nx_bld_dmg_fire_card_blend02" );
	level._effect[ "looping_fireball_01" ]								= loadfx( "nx/hithard/nx_looping_fireball_01" );
	level._effect[ "looping_smoke_patch_01" ]							= loadfx( "nx/hithard/nx_looping_smoke_patch_01" );
	level._effect[ "bld3_glass_xplosion_01" ]							= loadfx( "nx/hithard/nx_hhh_bld3_glass_xplosion_01" );
	level._effect[ "bld3_big_smoke_column" ]							= loadfx( "nx/hithard/nx_hhh_apm_large_smoke_column" );
	//level._effect[ "wall_explosion_1_low" ]								= loadfx( "explosions/wall_explosion_1_low" );

	// Building 4 fall
	level._effect[ "nx_hhh_bldg_4_smoke_bottom" ]						= loadfx("nx/hithard/nx_hhh_bldg_4_smoke_bottom");
	level._effect[ "nx_hhh_bldg_4_smoke_top" ]							= loadfx("nx/hithard/nx_hhh_bldg_4_smoke_top");

	level._effect[ "nx_trash_runner_1024" ]								= loadfx( "nx/misc/nx_trash_runner_1024" );

	level._effect[ "firelp_large_pm" ] 									= loadfx( "fire/firelp_large_pm" );
	level._effect[ "amb_dust" ] 										= loadfx( "smoke/amb_dust" );
	level._effect[ "amb_smoke_add" ] 									= loadfx( "smoke/amb_smoke_add" );
	level._effect[ "nx_fire_falling_palmtree" ] 						= loadfx( "nx/fire/nx_fire_falling_palmtree" );

	//NX Motorcade--Not used, I think... 
	//level._effect[ "vehicle_explosion_hummer" ] 						= LoadFX( "explosions/vehicle_explosion_hummer" );

	// sniper rooftop encounter
	level._effect[ "nx_helicopter_explosion1" ]							= LoadFX( "nx/explosions/nx_helicopter_explosion1" );
	level._effect[ "nx_smoke_hh_sniper_intersection_reveal" ]			= LoadFX( "nx/smoke/nx_smoke_hh_sniper_intersection_reveal" );
	level._effect[ "firelp_med_pm_nolight" ]							= LoadFX( "fire/firelp_med_pm_nolight" );
	level._effect[ "firelp_small_pm_nolight" ]							= LoadFX( "fire/firelp_small_pm_nolight" );
	level._effect[ "nx_hhh_intersection_side_smoke" ]							= LoadFX( "nx/hithard/nx_hhh_intersection_side_smoke" );


	// setexpFog(near, half plane, r, g, b, max, transition time)

	//scripted FX
	//Osprey intro crashy sequence
	level._effect[ "old_osprey_missle_hit_xplosion01" ] = loadfx( "nx/explosions/nx_osprey_explosion_1" );
	level._effect[ "osprey_missle_hit_xplosion01" ] = loadfx( "nx/explosions/nx_missle_air_hit01" );
	level._effect[ "osprey_missle_hit_debris01" ] = loadfx( "nx/explosions/nx_too_much_debri_directional01" );
	level._effect[ "osprey_missle_launch01" ] = loadfx( "nx/smoke/nx_missle_and_smokertail01" );
	level._effect[ "osprey_missle_hit_xplosion01b" ] = loadfx( "nx/explosions/nx_missle_air_hit02" );
	level._effect[ "osprey_wing_burn_emmiter" ] = loadfx( "nx/fire/nx_fire_smoke_trail_l_emitter_01" );
	level._effect[ "osprey_engine_burn_emmiter" ] = loadfx( "fire/fire_smoke_trail_L_emitter" );
	level._effect[ "osprey_engine_flame_out" ] = loadfx( "nx/fire/nx_osprey_engine_crashing" );
	level._effect[ "osprey_missle_hit_explosion_l" ] = loadfx( "explosions/aerial_explosion_heli" );
	level._effect[ "osprey_takeoff_afterburn" ] = loadfx( "fire/jet_afterburner_ignite" );
	level._effect[ "osprey_takeoff_thrust" ] = loadfx( "fire/jet_afterburner_harrier" );
	level._effect[ "osprey_2ndary_explosion_l_01" ] = loadfx( "nx/explosions/nx_explosion_osprey_engine" );
	level._effect[ "nx_smoke_osprey_engine_hit" ] = loadfx( "nx/smoke/nx_smoke_osprey_engine_hit" );
	level._effect[ "nx_light_hhh_osprey_intro_back_door" ] = loadfx( "nx/lights/nx_light_hhh_osprey_intro_back_door" );
	level._effect[ "nx_light_hhh_osprey_intro_windshield" ] = loadfx( "nx/lights/nx_light_hhh_osprey_intro_windshield" );

	
	// level._effect[ "osprey_large_afterburner" ] = loadfx( "nx/fire/nx_repel_looping_large_afterburner" );
	level._effect[ "osprey_small_afterburner" ] = loadfx( "nx/fire/nx_repel_looping_small_afterburner" );
	level._effect[ "osprey_medium_afterburner" ] = loadfx( "nx/fire/nx_repel_looping_medium_afterburner" );
	level._effect[ "osprey_windshield_light" ] = loadfx( "nx/lights/nx_repel_osprey_light_0" );
	level._effect[ "osprey_engine_impact_explosion01" ] = loadfx( "nx/explosions/nx_big_clusterbomb" );
	level._effect[ "osprey_engine_impact_smoke01" ] = loadfx( "nx/fire/nx_repel_fire_column_med" );
	level._effect[ "osprey_engine_dustrush01" ] = loadfx( "nx/explosions/nx_repel_osprey_engine_dustrush01" );

	level._effect[ "osprey_dust" ] = loadfx( "nx/treadfx/osprey_dust" );
	level._effect[ "smoke_swirl" ] = loadfx( "smoke/smoke_swirl" );
	level._effect[ "expRound" ] = loadfx( "impacts/expRound" );

    //osprey_intro_fx/////////////
    //
    level._effect[ "looping_aa_fire_osp_02" ] = loadfx( "nx/hithard/nx_osprey_intro_osp2_aa" );
    level._effect[ "looping_aa_fire_osp_02_focused" ] = loadfx( "nx/misc/nx_ec_faux_aa_child_a" );
    level._effect[ "cabin_rail_impacts_01" ] = loadfx( "nx/hithard/nx_osprey_cabin_rail_impacts_01" );
    level._effect[ "redblinker" ] = loadfx( "nx/hithard/nx_osprey_red_blinker_cabin" );
    level._effect[ "cabin_smoke_med_01" ] = loadfx( "nx/hithard/nx_osprey_cabin_smoke_med" );
    level._effect[ "cabin_smoke_small_01" ] = loadfx( "nx/hithard/nx_osprey_cabin_smoke_dark_small" );
    level._effect[ "cabin_glass_blow_out_01" ] = loadfx( "nx/hithard/nx_osprey_glass_shatter_cabin" );
    level._effect[ "wire_sparks_01" ] = loadfx( "nx/hithard/nx_wire_sparks_01" );
    level._effect[ "lil_osprey_fires" ] = loadfx( "nx/hithard/nx_osprey_intro_flame_ember_01" );
    level._effect[ "cabin_explosion" ] = loadfx( "nx/hithard/nx_osprey_cabin_explosion_01" );
    level._effect[ "nx_cloud_huge_light_preseed" ] = loadfx( "nx/weather/nx_cloud_huge_light_preseed" );

	// Cortel sequence
	level._effect[ "hhh_cortel_breach_hit" ] 		= loadfx( "nx/hithard/hhh_cortel_breach_hit" );
	level._effect[ "nx_hhh_cortel_door_breach" ] 	= loadfx( "nx/explosions/nx_hhh_cortel_door_breach" );
	level._effect[ "nx_explosion_cortel_stairwell" ] 		= loadfx( "nx/explosions/nx_explosion_cortel_stairwell" );

	apply_vision_and_fog_osprey(); /// starting vision and fog

	// Stairway shake
	level._effect[ "ceiling_rock_collapse" ]		 = loadfx( "explosions/ceiling_rock_collapse" );

    //UGV_drop_onto_SUV
    level._effect[ "car_glass_large" ]		         = loadfx( "props/car_glass_large" ); 
    level._effect[ "car_glass_med" ]		         = loadfx( "props/car_glass_med" );
    level._effect[ "car_crushfx_01" ]		         = loadfx( "nx/hithard/nx_crushing_ugv_impact" );
    level._effect[ "car_smokenfire_01" ]		     = loadfx( "nx/smoke/nx_car_damage_blacksmoke_fire" );
    level._effect[ "car_alarm_light_01" ]		     = loadfx( "nx/misc/nx_copcar_light_red_loop_01" );


    SetLightGridIntensity(0.50);

	flag_init( "parachute_trigger_building02_amb_fx" );	
	//level thread playerEffect();
}
/*
playerEffect()
{
	flag_wait( "parachute_trigger_building02_amb_fx" );
	player = getentarray( "player", "classname" )[ 0 ];
	for ( ;; )
	{
		playfx( level._effect[ "nx_ash_cloud_heavy_runner" ], player.origin + ( 0, 0, -200 ) );
		wait( 0.3 );
	}
}
*/

SetLightGridIntensity(val)
{
    SetSavedDVar("r_lightGridEnableTweaks", 1);
    SetSavedDVar("r_lightGridIntensity", val );
}

RevertLightGridIntensity()
{
    SetSavedDVar("r_lightGridEnableTweaks", 0);
    SetSavedDVar("r_lightGridIntensity", 1 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Effects Sequencing for intersection sniping encounter



// ***************************************************
// Jump Points

// rooftop jump point start
fx_rooftop_init()
{
	apply_vision_and_fog_parachute_land();
	// startup the ambient effects
	//Exploder("fx_sniper_intersection_ambient");

	// spawn the first fireball
	// flag_intersection_first_fireball

	flag_wait ("flag_intersection_first_fireball");	

	wait 0.40;
	// fireball from a car below when you climb up the ladder
	Exploder("fx_rooftop_sniper_first_fireball");

	fx_sniper_encounter_sequencing();

	flag_wait ("flag_rooftop_sniper_down_stairs"); // we're heading down stairs
	fx_sniper_down_the_stairs_sequencing();

	flag_wait ("flag_rooftop_sniper_exit_to_street"); // we're exiting the garage(?)
	fx_sniper_exit_to_street_sequencing();

	// fx_rooftop_ambient - ambient effects on the rooftop sniper perch
	// fx_sniper_intersection_ambient -- ambient fire and effects in the sniper intersection

	// wait 10.0f
	// Clean up
	// DeleteExploder("fx fx_rooftop_sniper_first_fireball");
}

// startjump point for the start of the sniper encounter
fx_secure_init()
{
	// startup the ambient effects
	Exploder("fx_sniper_intersection_ambient");

	// Timing is dependent on prep_secure_intersection() in nx_hithard_secure.gsc - BMarv
	//flag_wait ("flag_intersection_first_fireball");	
	
	//wait 0.75;
	// fireball from a car below when you climb up the ladder
	Exploder("fx_rooftop_sniper_first_fireball");

	//clean up parking lot and building04 fx
	stop_exploder_nx("rooftop_amb_fx_noint", 1 );
	stop_exploder_nx("building04_amb_fx", 1 );

	// fireball from a car below when you climb up the ladder
	fx_sniper_encounter_sequencing();

	flag_wait ("flag_rooftop_sniper_down_stairs"); // we're heading down stairs
	fx_sniper_down_the_stairs_sequencing();

	flag_wait ("flag_rooftop_sniper_exit_to_street"); // we're exiting the garage(?)
	fx_sniper_exit_to_street_sequencing();
}

// startjump point for the end of the sniper encounter before the player goes downstairs to the motorcade.
fx_motorcade_init()
{
	apply_effects_sniper_wave4();
	// startup the ambient effects
	//Exploder("fx_sniper_intersection_ambient");

	flag_wait ("flag_rooftop_sniper_down_stairs"); // we're heading down stairs
	fx_sniper_down_the_stairs_sequencing();

	flag_wait ("flag_rooftop_sniper_exit_to_street"); // we're exiting the garage(?)
	fx_sniper_exit_to_street_sequencing();
}
// ***************************************************

fx_sniper_encounter_sequencing()
{
	apply_vision_and_fog_secure_start();

	//for ( i=0; i<2; i++ )
	//{
		//playfx( level._effect[ "nx_ash_cloud_heavy" ], level._player.origin + ( 0, 0, 100 ), ( 1, 0, 0 ) );
		//wait 3.0;
	//}	

	// WAVE 1 ******************************************************************************************************
	// After killing a certain number of dudes on the ground
	level waittill( "notify_secure_objective_wave_1_complete");
	apply_effects_sniper_wave2();

	// WAVE 2 ******************************************************************************************************
	// After killing the guys in the Cortel building's balcony, inside, terrace (across from the player)
	level waittill( "notify_secure_objective_cortel_complete");
	apply_effects_sniper_wave3();
	
	// WAVE 3 ******************************************************************************************************
	// After killing the guys on the Bonaventure ( 10'oclock from the player's position).  Sniper on rooftop, guys on bridge.
	level waittill( "notify_secure_objective_bon_complete");
	apply_effects_sniper_wave4();

	//adding some red lights and fire to the stairwell
	Exploder("parkinggarage_stairwell_fx");
}

fx_sniper_down_the_stairs_sequencing()
{
	// Add the smoke in the downstairs area
	Exploder("fx_sniper_lobby_ambient");
	apply_vision_and_fog_secure_mid();

	//getting rid of building 04 fx since we can't see them anymore
	delete_exploder("building04_amb_fx");

	// add dust falling, etc.

}

fx_sniper_exit_to_street_sequencing()
{
	flag_wait ("flag_rooftop_sniper_exit_to_street"); // we're exiting the garage(?)

	//removing some red lights and fire
	//delete_Exploder("parkinggarage_stairwell_fx");
	//iPrintLnBold("--- deleting stairwell exploder ---");

	apply_vision_and_fog_secure_end();
}

// ***************************************************
// [andym] Osprey_Intro_FX 
// ***************************************************

parachute_guys_blink_lights(ally01, ally05)
{
	level waittill( "notify_ospery_guys_jumping" ); // wait until the osprey is hit

	// blinking lights on your parachuting buddies
	PlayFXOnTag(level._effect[ "aircraft_light_white_blink" ], ally01, "tag_effect");
	PlayFXOnTag(level._effect[ "aircraft_light_white_blink" ], ally05, "tag_effect");
}

fx_ospreyintro_jumping_out(hithard_osprey_01)
{
	level notify( "notify_ospery_guys_jumping" );

//    iPrintLnBold("--- JUMPING OUT --- ");
	wait 2.0;
	RevertLightGridIntensity();
}

fx_ospreyintro_backdoor_open(osprey_damaged)
{
	level notify( "notify_osprey_back_light_on" );
    //iPrintLnBold("--- Back Door Opening --- ");
	// wait 6.3333;
// 	wait 6.8;
	wait 5.0;
//	set_vision_set( "nx_hithard_osprey_door_open", 1.0);
	set_vision_set( "nx_hithard_osprey_door_open", 2.5);
// 	wait 4.0;
	wait 5.0;
	apply_vision_and_fog_parachute_jump(3.0);

}

fx_ospreyintro_backdoor_open_light_on( osprey_damaged )
{
	level waittill( "notify_osprey_back_light_on" );

	// iPrintLnBold("--- back door light on ---");
	PlayFXOnTag( level._effect[ "nx_light_hhh_osprey_intro_back_door" ],  osprey_damaged, "tag_osprey_back_door" );
}

fx_start_osprey_intro(hithard_osprey_01)
{
	// iPrintLnBold("--- fx_start_osprey_intro ---");
	wait 2.5;
	// iPrintLnBold("--- Start Cabin Vision set Change ---");
	thread set_vision_set("nx_hithard_osprey_cabin", 5.0);
	lerp_fov_overtime( 5.0 , 45.0 );
}

fx_test_osp01_nt( hithard_osprey_01 )
{
	PlayFXOnTag( level._effect[ "redblinker" ],  hithard_osprey_01, "tag_death_fx" );
    wait 3.0;
    StopFXOnTag( level._effect[ "redblinker" ],  hithard_osprey_01, "tag_death_fx" );	        
}

fx_ospreyintro_osp02_engines_on( hithard_osprey_02 )
{
	PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_02, "tag_engine_left_fx1" );
	PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_02, "tag_engine_right_fx1" );
	wait 10.0;
	PlayFXOnTag( level._effect[ "osprey_small_afterburner" ],  hithard_osprey_02, "tag_engine_left_fx1" );
	PlayFXOnTag( level._effect[ "osprey_small_afterburner" ],  hithard_osprey_02, "tag_engine_right_fx1" ); 	        
}

fx_ospreyintro_osp03_engines_on( hithard_osprey_03 )
{
	PlayFXOnTag( level._effect[ "osprey_small_afterburner" ],  hithard_osprey_03, "tag_engine_left_fx1" );
	PlayFXOnTag( level._effect[ "osprey_small_afterburner" ],  hithard_osprey_03, "tag_engine_right_fx1" ); 
    wait 20.0;
    StopFXOnTag( level._effect[ "osprey_small_afterburner" ],  hithard_osprey_03, "tag_engine_left_fx1" );
	StopFXOnTag( level._effect[ "osprey_small_afterburner" ],  hithard_osprey_03, "tag_engine_right_fx1" );              
}

fx_ospreyintro_osp04_engines_on( hithard_osprey_04 )
{
	PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_04, "tag_engine_left_fx1" );
	PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_04, "tag_engine_right_fx1" ); 
    wait 20.0;
    StopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_04, "tag_engine_left_fx1" );
	StopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_04, "tag_engine_right_fx1" );              
}

fx_ospreyintro_osp02_thrust( hithard_osprey_02 )
{
	PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_02, "tag_engine_left_fx1" );
	PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_02, "tag_engine_right_fx1" ); 
    wait 2.0;
    StopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_02, "tag_engine_left_fx1" );
	StopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_02, "tag_engine_right_fx1" );              
}

fx_ospreyintro_start_aa( hithard_osprey_01 )
{
    playfxOnTag( level._effect[ "looping_aa_fire_osp_02" ], hithard_osprey_01, "tag_flash" );
    wait 10.0;
    StopFxonTag( level._effect[ "looping_aa_fire_osp_02" ], hithard_osprey_01, "tag_flash" );
}

fx_ospreyintro_osp02_hit( hithard_osprey_02 )
{
    playfxOnTag( level._effect[ "looping_aa_fire_osp_02_focused" ], hithard_osprey_02, "tag_passenger" ); 
    wait 0.2;
    
    //iprintlnbold( "WTS!!!" );
    
    playfxOnTag( level._effect[ "osprey_missle_hit_explosion_l" ], hithard_osprey_02, "tag_passenger" );
    playfxOnTag( level._effect[ "osprey_engine_burn_emmiter" ], hithard_osprey_02, "tag_passenger" );
    
    stutter_interval = 0.2;

    wait stutter_interval;
    stopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_02, "tag_engine_left_fx1" );
stopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_02, "tag_engine_right_fx1" ); 

    wait stutter_interval;
    PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_02, "tag_engine_left_fx1" );
PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_02, "tag_engine_right_fx1" ); 
    
    playfxOnTag( level._effect[ "osprey_missle_hit_explosion_l" ], hithard_osprey_02, "tag_driver" );

    wait stutter_interval;
    stopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_02, "tag_engine_left_fx1");
stopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_02, "tag_engine_right_fx1");
    
    wait stutter_interval;
    PlayFXOnTag( level._effect[ "osprey_small_afterburner" ],  hithard_osprey_02, "tag_engine_left_fx1" );
PlayFXOnTag( level._effect[ "osprey_small_afterburner" ],  hithard_osprey_02, "tag_engine_right_fx1" ); 

    wait stutter_interval;
    stopFXOnTag( level._effect[ "osprey_small_afterburner" ],  hithard_osprey_02, "tag_engine_left_fx1" );
stopFXOnTag( level._effect[ "osprey_small_afterburner" ],  hithard_osprey_02, "tag_engine_right_fx1" ); 

    wait stutter_interval;
    PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_02, "tag_engine_left_fx1" );
PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_02, "tag_engine_right_fx1" );

    wait stutter_interval;
    StopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_02, "tag_engine_left_fx1" );
StopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  hithard_osprey_02, "tag_engine_right_fx1" );  
}

fx_ospreyintro_osp01_flackhit( osprey_damaged )
{
    //iprintlnbold( "flackhit!!!" );

    level._player DoDamage( level._player.health - 10, level._player.origin );

    quakeobj = spawn( "script_origin", level._player.origin );
    quakeobj PlayRumbleOnEntity( "artillery_rumble" );
   	lerp_fov_overtime( 0.20 , 65.0 );

    playfxOnTag( level._effect[ "cabin_explosion" ], osprey_damaged, "tag_fx_fire_04"  );
    wait 0.01;
    playfxOnTag( level._effect[ "cabin_smoke_med_01" ], osprey_damaged, "tag_osprey_windshield" );
    wait 0.01;
    playfxOnTag( level._effect[ "cabin_smoke_small_01" ], osprey_damaged, "tag_fx_dark_smoke_01" );
    wait 0.01;
    playfxOnTag( level._effect[ "cabin_glass_blow_out_01" ], osprey_damaged, "tag_osprey_windshield" );
    wait 0.01;
    PlayFXOnTag( level._effect[ "lil_osprey_fires" ],  osprey_damaged, "tag_fx_fire_01");
    wait 0.01;
    PlayFXOnTag( level._effect[ "lil_osprey_fires" ],  osprey_damaged, "tag_fx_fire_02");
    wait 0.01;
    PlayFXOnTag( level._effect[ "lil_osprey_fires" ],  osprey_damaged, "tag_fx_fire_03");
    wait 0.01;
    PlayFXOnTag( level._effect[ "lil_osprey_fires" ],  osprey_damaged, "tag_fx_fire_04");
    wait 0.01;
    PlayFXOnTag( level._effect[ "lil_osprey_fires" ],  osprey_damaged, "tag_fx_fire_05");
    playfxOnTag( level._effect[ "redblinker" ], osprey_damaged, "tag_red_light" );
    wait 0.1;
    playfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_a_sparks_01" );
    playfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_b_sparks_01" );
    wait 0.1;
    playfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_c_sparks_01" );
    playfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_d_sparks_01" );
    wait 0.1;
    playfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_e_sparks_01" );
    playfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_f_sparks_01" );
    wait 0.1;
    playfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_g_sparks_01" );
    playfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_h_sparks_01" );
    playfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_i_sparks_01" );       
}

fx_ospreyintro_osp01_particle_cleanup( osprey_damaged )
{
    //iprintlnbold( "particle_cleanup" );
    stopfxOnTag( level._effect[ "osprey_2ndary_explosion_l_01" ], osprey_damaged, "tag_passenger"  );
    stopfxOnTag( level._effect[ "cabin_smoke_med_01" ], osprey_damaged, "tag_osprey_windshield" );
    wait 0.01;
    stopfxOnTag( level._effect[ "cabin_smoke_small_01" ], osprey_damaged, "tag_fx_dark_smoke_01" );
    stopfxOnTag( level._effect[ "cabin_glass_blow_out_01" ], osprey_damaged, "tag_osprey_windshield" );
    wait 0.01;
    stopFXOnTag( level._effect[ "lil_osprey_fires" ],  osprey_damaged, "tag_fx_fire_01");
    stopFXOnTag( level._effect[ "lil_osprey_fires" ],  osprey_damaged, "tag_fx_fire_02");
    wait 0.01;
    stopFXOnTag( level._effect[ "lil_osprey_fires" ],  osprey_damaged, "tag_fx_fire_03");
    stopFXOnTag( level._effect[ "lil_osprey_fires" ],  osprey_damaged, "tag_fx_fire_04");
    wait 0.01;
    stopFXOnTag( level._effect[ "lil_osprey_fires" ],  osprey_damaged, "tag_fx_fire_05");
    stopfxOnTag( level._effect[ "redblinker" ], osprey_damaged, "tag_red_light" );        
    wait 0.01;
    stopfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_a_sparks_01" );
    stopfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_b_sparks_01" );
    wait 0.01;
    stopfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_c_sparks_01" );
    stopfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_d_sparks_01" );
    wait 0.01;
    stopfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_e_sparks_01" );
    stopfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_f_sparks_01" );
    wait 0.01;
    stopfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_g_sparks_01" );
    stopfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_h_sparks_01" );
    wait 0.01;
    stopfxOnTag( level._effect[ "wire_sparks_01" ], osprey_damaged, "tag_fx_wire_i_sparks_01" );                
}


// ***************************************************
/*
osprey_engine_fx_01 ( osprey ) 
{
        //iprintlnbold( "Missle_hit" );
        //tagPos = osprey_engine GetTagOrigin( "tag_engine_left" );
        playfxOnTag( level._effect[ "osprey_engine_flame_out" ], osprey, "tag_engine_left" );
        PlayFXOnTag( level._effect[ "osprey_engine_burn_emmiter" ],  osprey, "tag_engine_left_fx1");    
}
*/

fx_ospreycrashvp_start( ospreycrashvp )
{
	// iprintlnbold( "OSPREY_VP_CRASH: Start" );
	//PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_left_fx1");
	//PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_right_fx1");

	wait 4.0;
	// play swirl smoke effects as the osprey goes through the smoke column at the end of the intersection.
	for (i=0; i<4 ; i++)
	{
		PlayFXOnTag( level._effect[ "smoke_swirl" ],  ospreycrashvp, "tag_engine_right_fx1");
		PlayFXOnTag( level._effect[ "smoke_swirl" ],  ospreycrashvp, "tag_engine_left_fx1");
		wait 0.25;
	}

	//StopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_left_fx1");
	//StopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_right_fx1");
}

fx_ospreycrashvp_flare( ospreycrashvp )
{
	// iprintlnbold( "OSPREY_VP_CRASH: Flare" );
	// 9.7 secs later, kill the wash and stuff on the player's view.

	wait 2.0;
	PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_left_fx1");
	PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_right_fx1");

	wait 0.50;
	Exploder("fx_hhh_osprey_intersection_wash");
// 2.5
	// add some grit to the screen
	wait 2.3;
	level._player thread maps\_gameskill::grenade_dirt_on_screen( "left" );
// 4.8
	wait 2.5;
	level._player thread maps\_gameskill::grenade_dirt_on_screen( "right" );
// 6.3
	wait 1.34;
	level._player thread maps\_gameskill::grenade_dirt_on_screen( "left" );
// 7.64
	wait 1.5;
	level._player thread maps\_gameskill::grenade_dirt_on_screen( "right" );
// 9.14
	//StopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_left_fx1");
	// StopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_right_fx1");

	// wait 0.56;
	stop_exploder("fx_hhh_osprey_intersection_wash");
}


fx_ospreycrashvp_hit_by_ugv( ospreycrashvp )
{
	level waittill( "notify_osprey_hit" ); // wait until the osprey is hit

	// iprintlnbold( "OSPREY_VP_CRASH: BOOM!" );

	// wait 0.1;
	// StopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_right_fx1");

	// the explosion
	thread fx_ospreycrashvp_right_engine_sputter(9.40, 2.0, ospreycrashvp);
	PlayFXOnTag( level._effect[ "osprey_2ndary_explosion_l_01" ],  ospreycrashvp, "tag_engine_right_fx1");
	PlayFXOnTag( level._effect[ "nx_smoke_osprey_engine_hit" ],  ospreycrashvp, "tag_engine_right_fx1");

	// PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_right_fx1");
	wait 1.90;
	//PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_left_fx1");
	//StopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_right_fx1");

	thread fx_ospreycrashvp_left_engine_sputter(5.0, 1.333, ospreycrashvp);
	// thread fx_ospreycrashvp_right_engine_sputter(6.40, 0.40, ospreycrashvp);

	wait 0.9;
	PlayFXOnTag(level._effect[ "old_osprey_missle_hit_xplosion01" ], ospreycrashvp, "tag_engine_right");
	wait 0.17;
	// PlayFXOnTag(level._effect[ "old_osprey_missle_hit_xplosion01" ], ospreycrashvp, "tag_engine_right");

	wait 2.5;
	// StopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_right_fx1");
	// StopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_left_fx1");

	StopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_right_fx1");
	PlayFXOnTag(level._effect[ "old_osprey_missle_hit_xplosion01" ], ospreycrashvp, "tag_engine_right");
	wait 0.55;
	PlayFXOnTag(level._effect[ "old_osprey_missle_hit_xplosion01" ], ospreycrashvp, "TAG_UGV");
	wait 0.2;
	PlayFXOnTag(level._effect[ "nx_building01_explosion_small" ], ospreycrashvp, "tag_ground");
	wait 1.5;
	Exploder("fx_osprey_crash_aftermath");
	// PlayFXOnTag(level._effect[ "nx_hhh_bldg_fire_column_dark_01_preseed" ], ospreycrashvp, "tag_ground");

//	fx_ospreycrashvp_right_engine_sputter(5.0, 0.3330, ospreycrashvp);
//	wait 3.0;
//	fx_ospreycrashvp_left_engine_sputter(4.0, 0.26, ospreycrashvp);

}

// sputter_time = how long the effect shouild sputter
// sputter_rate = 
fx_ospreycrashvp_left_engine_sputter(sputter_time, sputter_rate, ospreycrashvp)
{
	sputter_loop_count = floor ( sputter_time / sputter_rate );

	for (i=0; i < sputter_loop_count; i++)
	{
		// Start the burner
		PlayFXOnTag( level._effect[ "osprey_small_afterburner" ],  ospreycrashvp, "tag_engine_left_fx1");
		wait (sputter_rate * 0.80);
		// Stop the burner, start the fire and smoke
		StopFXOnTag( level._effect[ "osprey_small_afterburner" ],  ospreycrashvp, "tag_engine_left_fx1");
		wait (sputter_rate * 0.10);
		PlayFXOnTag( level._effect[ "osprey_engine_flame_out" ],  ospreycrashvp, "tag_engine_left_fx1");
		wait (sputter_rate * 0.20);
		StopFXOnTag( level._effect[ "osprey_engine_flame_out" ],  ospreycrashvp, "tag_engine_left_fx1");
		wait 0.10;
	}

	// emd on the fire and smoke
	PlayFXOnTag( level._effect[ "osprey_engine_burn_emmiter" ],  ospreycrashvp, "tag_engine_left_fx1");

}

fx_ospreycrashvp_right_engine_sputter(sputter_time, sputter_rate, ospreycrashvp)
{
	sputter_loop_count = floor ( sputter_time / sputter_rate );

	for (i=0; i < sputter_loop_count; i++)
	{
		// Start the burner
		PlayFXOnTag( level._effect[ "osprey_small_afterburner" ],  ospreycrashvp, "tag_engine_right_fx1");
		wait (sputter_rate * 0.80);
		// Stop the burner, start the fire and smoke
		StopFXOnTag( level._effect[ "osprey_small_afterburner" ],  ospreycrashvp, "tag_engine_right_fx1");
		wait (sputter_rate * 0.20);
		//PlayFXOnTag( level._effect[ "osprey_engine_flame_out" ],  ospreycrashvp, "tag_engine_right_fx1");
		//wait (sputter_rate * 0.20);
		//StopFXOnTag( level._effect[ "osprey_engine_flame_out" ],  ospreycrashvp, "tag_engine_right_fx1");
		wait 0.10;
	}

	// emd on the fire and smoke
	PlayFXOnTag( level._effect[ "osprey_engine_burn_emmiter" ],  ospreycrashvp, "tag_engine_right_fx1");

}

fx_ospreycrashvp_hover( ospreycrashvp )
{
	// iprintlnbold( "OSPREY_VP_CRASH: Hover" );

/*
	wait 0.50;
	PlayFXOnTag( level._effect[ "osprey_small_afterburner" ],  ospreycrashvp, "tag_engine_left_fx1");
	PlayFXOnTag( level._effect[ "osprey_small_afterburner" ],  ospreycrashvp, "tag_engine_right_fx1");

	wait 0.50;
*/
	/*
	wait 2.0;
	hit_interval = 0.333;
	PlayFXOnTag( level._effect[ "expRound" ],  ospreycrashvp, "tag_exfil_hit_1");
	wait hit_interval;

	PlayFXOnTag( level._effect[ "expRound" ],  ospreycrashvp, "tag_exfil_hit_2");
	wait hit_interval;

	PlayFXOnTag( level._effect[ "expRound" ],  ospreycrashvp, "tag_exfil_hit_3");
	wait hit_interval;

	PlayFXOnTag( level._effect[ "expRound" ],  ospreycrashvp, "tag_exfil_hit_4");
	wait ( hit_interval + hit_interval );
	*/
}

fx_ospreycrashvp_veer( ospreycrashvp )
{

	// iprintlnbold( "OSPREY_VP_CRASH: crash" );

	//wait 2.0;
	//PlayFXOnTag(level._effect[ "old_osprey_missle_hit_xplosion01" ], ospreycrashvp, "tag_engine_right");
	//wait 1.03;
	//PlayFXOnTag(level._effect[ "old_osprey_missle_hit_xplosion01" ], ospreycrashvp, "tag_engine_left");
	//wait 1.7;
	//PlayFXOnTag(level._effect[ "nx_building01_explosion_small" ], ospreycrashvp, "tag_body");


/*
	// left engine throttles up!
	StopFXOnTag( level._effect[ "osprey_small_afterburner" ],  ospreycrashvp, "tag_engine_left_fx1");
	PlayFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_left_fx1");

	wait 0.50;
	StopFXOnTag( level._effect[ "osprey_small_afterburner" ],  ospreycrashvp, "tag_engine_right_fx1");

    //PlayfxOnTag( level._effect[ "osprey_engine_flame_out" ], ospreycrashvp, "tag_engine_left" );

	wait 1.50;
	stop_exploder("fx_hhh_osprey_intersection_wash");


	wait 1.0;
	PlayFXOnTag( level._effect[ "osprey_2ndary_explosion_l_01" ],  ospreycrashvp, "tag_engine_left_fx1");
	StopFXOnTag( level._effect[ "osprey_medium_afterburner" ],  ospreycrashvp, "tag_engine_left_fx1");
    PlayFXOnTag( level._effect[ "osprey_engine_burn_emmiter" ],  ospreycrashvp, "tag_engine_left_fx1");

*/
	/*
	for (i=0; i<6; i++)
	{
		StopFXOnTag( level._effect[ "osprey_engine_burn_emmiter" ],  ospreycrashvp, "tag_engine_left_fx1");    
		wait 0.25;
		PlayFXOnTag( level._effect[ "osprey_engine_burn_emmiter" ],  ospreycrashvp, "tag_engine_left_fx1");    
		wait 0.7;
	}
	*/
}

fx_ospreycrashvp_crash( ospreycrashvp )
{

	// iprintlnbold( "OSPREY_VP_CRASH: Crash" );


/*
	wait 0.2;
	PlayFXOnTag(level._effect[ "old_osprey_missle_hit_xplosion01" ], ospreycrashvp, "tag_engine_left");
	wait 1.03;
	PlayFXOnTag(level._effect[ "old_osprey_missle_hit_xplosion01" ], ospreycrashvp, "tag_engine_right");
	wait 1.7;
	PlayFXOnTag(level._effect[ "nx_building01_explosion_small" ], ospreycrashvp, "tag_body");

	Exploder("fx_intersection_osprey_crash_tree_fire");

	wait 10.0;
    //StopfxOnTag( level._effect[ "osprey_engine_flame_out" ], ospreycrashvp, "tag_engine_left" );
    StopFXOnTag( level._effect[ "osprey_engine_burn_emmiter" ],  ospreycrashvp, "tag_engine_left_fx1");    
    //StopfxOnTag( level._effect[ "osprey_engine_flame_out" ], ospreycrashvp, "tag_engine_right" );
    StopFXOnTag( level._effect[ "osprey_engine_burn_emmiter" ],  ospreycrashvp, "tag_engine_right_fx1");    

*/

	// thread the next set of triggers for vision and fog.
	thread fx_apply_vision_and_fog_cortel_side_street();
	thread fx_apply_vision_and_fog_cortel_enter();
	thread fx_apply_vision_and_fog_cortel_stairwell_enter();

}

// Cortel Sequencing
// Exploders: fx_cortel_breach

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// hold onto this... intersection fireball
// flag_intersection_first_fireball



//************************************************************************
//	suv crushing by dropped ugv
//************************************************************************


fx_suv_02_smash_01 ( dropoff_suv_02 )
{
	//iprintlnbold( "Monsterrrr Truuuckkk Rally, GO!" );
    PlayFXOnTag(level._effect[ "car_crushfx_01" ], dropoff_suv_02, "TAG_GLASS_BACK");
	PlayFXOnTag(level._effect[ "car_glass_large" ], dropoff_suv_02, "tag_glass_back_fx");
    wait 0.01;
    PlayFXOnTag(level._effect[ "car_glass_med" ], dropoff_suv_02, "tag_glass_right_back_fx");
    PlayFXOnTag(level._effect[ "car_glass_med" ], dropoff_suv_02, "tag_glass_left_back_fx");
    wait 0.01;
    PlayFXOnTag(level._effect[ "car_glass_med" ], dropoff_suv_02, "tag_glass_right_back_fx_02");
    PlayFXOnTag(level._effect[ "car_glass_med" ], dropoff_suv_02, "tag_glass_left_back_fx_02");
    wait 0.01;
    PlayFXOnTag(level._effect[ "car_glass_med" ], dropoff_suv_02, "tag_glass_right_front_fx");;
    PlayFXOnTag(level._effect[ "car_glass_med" ], dropoff_suv_02, "tag_glass_LEFT_front_fx");
    wait 0.01;
    PlayFXOnTag(level._effect[ "car_glass_large" ], dropoff_suv_02, "tag_glass_front_fx");
	wait 0.01;
	PlayFXOnTag(level._effect[ "car_alarm_light_01" ], dropoff_suv_02, "TAG_TAIL_LIGHT_RIGHT");
	wait 0.1;
	PlayFXOnTag(level._effect[ "car_alarm_light_01" ], dropoff_suv_02, "TAG_TAIL_LIGHT_left");

 

    

}

//************************************************************************


hide_lz()
{
	augmented_lz = getent( "hhh_LZ", "targetname" );

	if ( !isdefined( augmented_lz ))
	{
		AssertMsg( "Could not find LZ!" );
	} else {
		augmented_lz Hide();
	}
}

show_lz()
{
	augmented_lz = getent( "hhh_LZ", "targetname" );

	if ( !isdefined( augmented_lz ))
	{
		AssertMsg( "Could not find LZ!" );
	} else {
		augmented_lz show();
	}
}

lz_flicker_on()
{
	augmented_lz = getent( "hhh_LZ", "targetname" );

	if ( !isdefined( augmented_lz ))
	{
		AssertMsg( "Could not find LZ!" );
	} else {
		short_flicker_time = 0.03;
		med_flicker_time = 0.10;

		for( i = 0; i < 5; i++ )
		{
			augmented_lz Show();
			wait short_flicker_time;
			augmented_lz Hide();
			wait short_flicker_time;
		}
		for( i = 0; i < 3; i++ )
		{
			augmented_lz Show();
			wait med_flicker_time;
			augmented_lz Hide();
			wait med_flicker_time;
		}
		for( i = 0; i < 3; i++ )
		{
			augmented_lz Show();
			wait short_flicker_time;
			augmented_lz Hide();
			wait short_flicker_time;
		}
		// actually on now
		augmented_lz Show();
	}
}

lz_flicker_off()
{
	augmented_lz = getent( "hhh_LZ", "targetname" );

	if ( !isdefined( augmented_lz ))
	{
		AssertMsg( "Could not find LZ!" );
	} else {
		short_flicker_time = 0.03;

		for( i = 0; i < 5; i++ )
		{
			augmented_lz Hide();
			wait short_flicker_time;
			augmented_lz Show();
			wait short_flicker_time;
		}
		// actually on now
		augmented_lz Hide();
	}
}

// fx_cortel_enter
// fx_cortel_side_street
// fx_cortel_stairwell_enter

// ************************************************************************
// trigger setting the vision and fog when you walk down the street to the cortel building
// the main thing here is that we're turning off the sunfog,
// as that direction is occulded by the building to the player's right.
fx_apply_vision_and_fog_cortel_side_street()
{
	flag_wait("fx_cortel_side_street");

	transition_time = 4.0;
	// set_vision_set( "nx_hithard_sniper_intersection", transition_time );
 	setExpFog( 500, 2500, 0.3921569, 0.3333333, 0.2745098, 0.2, transition_time);
	// setExpFog( 0, 1000, 0.3921569, 0.3333333, 0.2745098, 0.6, transition_time, 0.7333333, 0.6352941, 0.5568628, ( 0.975479, 0.0189773, 0.219272 ), 0, 45, 0.0 );
}

fx_apply_cortel_bldg_vision_fog()
{
	// this function only used for the motorcade_end jump point
	set_vision_set( "nx_hithard_cortel_interior", 0.0 );
	setExpFog( 1000, 5000, 0.3921569, 0.3333333, 0.2745098, 0.1, 0.0);
	thread fx_apply_vision_and_fog_cortel_stairwell_enter();
}

// trigger entering the Cortel building itself
fx_apply_vision_and_fog_cortel_enter()
{
	flag_wait("fx_cortel_enter");
	transition_time = 5.0;
	set_vision_set( "nx_hithard_cortel_interior", transition_time );
	setExpFog( 1000, 5000, 0.3921569, 0.3333333, 0.2745098, 0.1, transition_time);
}

// Trigger entering the stairwell inside the Cortel building
fx_apply_vision_and_fog_cortel_stairwell_enter()
{
	flag_wait("fx_cortel_stairwell_enter");
	transition_time = 6.0;
	set_vision_set( "nx_hithard_cortel_stairwell", transition_time );
	setExpFog( 1000, 5000, 0.3921569, 0.3333333, 0.2745098, 0.0, transition_time);
}
// ************************************************************************



apply_vision_and_fog_osprey()
{
	// iPrintLnBold("--- Applying Osprey vision and fog ---");
	//iPrintLn("--- Applying Osprey vision and fog ---");
	set_vision_set( "nx_hithard_osprey", 1 );
	setExpFog( 3610, 18051, 0.6392157, 0.7333333, 0.7882353, 0.02526667, 0, 1, 0.8941177, 0.5333334, ( 0.975479, 0.0189773, 0.219272 ), 0, 35, 0 );
}

apply_vision_and_fog_osprey_door_open()
{
	// iPrintLnBold("--- Applying Osprey vision and fog ---");
	level._player PlaySound( "hithard_osprey_door" );	
	thread maps\_utility::set_ambient( "nx_hithard_osp_open" );
	transition_time = 2.0;
	//iPrintLn("--- Applying Osprey DOOR OPEN vision and fog ---");			
	set_vision_set( "nx_hithard_osprey_door_open", transition_time);
}

apply_vision_and_fog_parachute_jump( transition_time )
{
	//iPrintLn("--- Applying Parachute Jump vision and fog ---");
	set_vision_set( "nx_hithard_parachuting", transition_time );
	setExpFog( 361, 3611, 0.4352941, 0.4509804, 0.509804, 0.2599, transition_time, 0.4980392, 0.4470588, 0.2627451, ( 0.975479, 0.0189773, 0.219272 ), 0, 35, 0 );
    RevertLightGridIntensity();
}

sequence_vision_and_fog_parachute_land()
{
	flag_wait("flag_parasecure_parachute_landed_player");

	//iPrintLn("--- Applying Parachute Land vision and fog ---");
	apply_vision_and_fog_parachute_land();
}

apply_vision_and_fog_parachute_land()
{
	transition_time = 3.0;
	set_vision_set( "nx_hithard_landing", transition_time );
	setExpFog( 3610, 18051, 0.6392157, 0.7333333, 0.7882353, 0.4801, transition_time, 1, 0.8941177, 0.5333334, ( 0.975479, 0.0189773, 0.219272 ), 0, 35, 1.12 );
}

apply_vision_and_fog_secure_start()
{
	transition_time = 5.0;
	//iPrintLn("--- Applying Secure Start vision and fog ---");
	set_vision_set( "nx_hithard_sniper_rooftop", transition_time );
	setExpFog( 2166, 3792, 0.4431373, 0.4039216, 0.4784314, 0.3068667, transition_time, 1, 0.945098, 0.7254902, ( 0, 0, 0 ), 0, 29, 0.62 );
	// setExpFog( 1805, 6680, 0.4078431, 0.3882353, 0.3019608, 0.4801, transition_time, 0.5843138, 0.5607843, 0.4156863, ( 0.975479, 0.0189773, 0.219272 ), 16, 59, 2.24 );

	
	/* while( 1 )
	{
		playfx( level._effect[ "ash_turb_aftermath" ], level._player.origin + ( 0, 0, 100 ), level._player.origin + ( 0, 0, 150 ) );
		wait 0.2;
	} */	
}

apply_effects_sniper_wave2()
{
	transition_time = 6.0;
	//iPrintLn("--- apply_effects_sniper_wave2() ---");
	set_vision_set( "nx_hithard_sniper_wave_2", transition_time );
	setExpFog( 2166, 3792, 0.4431373, 0.4039216, 0.4784314, 0.3068667, transition_time, 1, 0.945098, 0.7254902, ( 0, 0, 0 ), 0, 29, 0.62 );
	// add more crap in the air
	//playfx( level._effect[ "nx_ash_cloud_light" ], level._player.origin + ( 0, 0, 100 ), ( 1, 0, 0 ) );
}

apply_effects_sniper_wave3()
{
	transition_time = 6.0;
	//iPrintLn("--- apply_effects_sniper_wave3() ---");
	set_vision_set( "nx_hithard_sniper_wave_3", transition_time );
	setExpFog( 2166, 3792, 0.4431373, 0.4039216, 0.4784314, 0.6068667, transition_time, 1, 0.945098, 0.7254902, ( 0, 0, 0 ), 0, 29, 0.62 );
	// add more crap in the air
	//playfx( level._effect[ "nx_ash_cloud_light" ], level._player.origin + ( 0, 0, 100 ), ( 1, 0, 0 ) );
}

apply_effects_sniper_wave4()
{
	transition_time = 5.0;
	//iPrintLn("--- apply_effects_sniper_wave4() ---");
	set_vision_set( "nx_hithard_sniper_wave_4", transition_time );
	setExpFog( 2166, 3792, 0.5450, 0.4980, 0.4078, 0.9068667, transition_time, 1, 0.945098, 0.7254902, ( 0, 0, 0 ), 0, 29, 0.62 );
	// add more crap in the air
	//playfx( level._effect[ "nx_ash_cloud_light" ], level._player.origin + ( 0, 0, 100 ), ( 1, 0, 0 ) );

}

apply_vision_and_fog_secure_mid()
{
	transition_time = 6.0;
	//iPrintLn("--- Applying Secure Start vision and fog ---");
	set_vision_set( "nx_hithard_sniper_stairwell", transition_time );
	setExpFog( 1805, 6680, 0.4078431, 0.3882353, 0.3019608, 0.4801, transition_time, 0.5843138, 0.5607843, 0.4156863, ( 0.975479, 0.0189773, 0.219272 ), 16, 59, 2.24 );

/*
	while( 1 )
	{
		playfx( level._effect[ "ash_turb_aftermath" ], level._player.origin + ( 0, 0, 100 ), level._player.origin + ( 0, 0, 150 ) );
		wait 0.2;
	}	*/
}

apply_vision_and_fog_secure_end()
{
	transition_time = 3.0;
	// iPrintLn("--- Applying Secure Start vision and fog ---");
	set_vision_set( "nx_hithard_sniper_intersection", transition_time );
	setExpFog( 0, 1000, 0.3921569, 0.3333333, 0.2745098, 0.6, 0, 0.7333333, 0.6352941, 0.5568628, ( 0.975479, 0.0189773, 0.219272 ), 0, 45, 0.28 );
//	setExpFog( 0, 1445, 0.4431373, 0.4117647, 0.3176471, 0.750, transition_time, 0.972549, 0.8509804, 0.6705883, ( 0.975479, 0.0189773, 0.219272 ), 0, 35, 0.1 );
	// setExpFog( 1805, 6680, 0.4078431, 0.3882353, 0.3019608, 0.4801, transition_time, 0.5843138, 0.5607843, 0.4156863, ( 0.975479, 0.0189773, 0.219272 ), 16, 59, 2.24 );

	//for ( i=0; i<5; i++ )
	//{
		//playfx( level._effect[ "nx_ash_cloud_light" ], level._player.origin + ( 0, 0, 100 ), ( 1, 0, 0 ) );
		// wait ( randomFloat (2.0 ) + 2.0 );
	//}	

	// turn on stuff when you're going down stairs - these are effects in the cortel building
	// and in the doorway we need to block into the cortel building
	Exploder( "fx_intersection_downstairs_ambient" );
}

apply_vision_and_fog_motorcade_start()
{
	//iPrintLn("--- Applying Motorcade vision and fog ---");
	set_vision_set( "nx_hithard", 1 );
}

apply_vision_and_fog_city_hall_escape_start()
{
	//iPrintLn("--- Applying City Hall vision and fog ---");
	set_vision_set( "nx_hithard", 1 );
}

apply_vision_and_fog_escort_start()
{
	//iPrintLn("--- Applying Escort vision and fog ---");
	set_vision_set( "nx_hithard", 1 );
}
