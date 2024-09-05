
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

#include common_scripts\utility;
#include animscripts\utility;
#include animscripts\combat_utility;
#include maps\_utility;

main()
{
	//if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	maps\createfx\nx_hithard_b_fx::main();

	level._effect[ "freeway_explosion" ]			 					= LoadFX( "explosions/wall_explosion_2_short_nosmoke" );
	level._effect[ "nx_debri_explosion" ]	 		 					= LoadFX( "nx/explosions/nx_debri_explosion_exit_building_1" );
	level._effect[ "building_explosion_gulag_bh1" ]	 					= LoadFX( "explosions/building_explosion_gulag" );
	level._effect[ "ceiling_collapse_dirt1" ] 							= LoadFX( "dust/ceiling_collapse_dirt1" );
	level._effect[ "ceiling_dust_bunker" ] 							 	= LoadFX( "dust/ceiling_dust_bunker" );
	level._effect[ "ceiling_dust_default" ] 							= LoadFX( "dust/ceiling_dust_default" );

	// NX smoke - copied over from first hithard, probably need to cleanup once we know which effects we'll be using in hithard_b				
	level._effect[ "nx_smoke_amb_scrolling_smoke" ]						= loadfx( "nx/smoke/nx_smoke_amb_scrolling_smoke" );	
	level._effect[ "nx_amb_smoke_plume_scattered_light" ]				= loadfx( "nx/smoke/nx_amb_smoke_plume_scattered_light" );	
	level._effect[ "nx_smoke_plume_periph_large_black" ]				= loadfx( "nx/smoke/nx_smoke_plume_periph_large_black" );	
	level._effect[ "nx_smoke_plume_huge_periph" ]						= loadfx( "nx/smoke/nx_smoke_plume_huge_periph" );	
	level._effect[ "nx_amb_smoke_fastground" ]							= loadfx( "nx/smoke/nx_amb_smoke_fastground" );
	level._effect[ "nx_amb_smoke_blend_large" ] 						= LoadFX( "nx/smoke/nx_amb_smoke_blend_large" );
	level._effect[ "nx_amb_smoke_blend_large_02" ] 						= LoadFX( "nx/smoke/nx_amb_smoke_blend_large_02" );
	level._effect[ "nx_fire_building_large" ] 							= LoadFX( "nx/fire/nx_fire_building_large" );
	level._effect[ "nx_grenade_smoke_5sec" ]							= loadfx( "nx/smoke/nx_grenade_smoke_5sec" );	

	//Lapes drop fx
	level._effect[ "nx_smoke_lapse_amb_smoke" ] 						= LoadFX( "nx/smoke/nx_smoke_lapse_amb_smoke" );
	level._effect[ "nx_c102_angel_flare_geotrail" ]						= loadfx( "nx/smoke/nx_c102_angel_flare_geotrail" );
	level._effect[ "nx_smoke_swirls_lapes_c102" ] 						= LoadFX( "nx/smoke/nx_smoke_swirls_lapes_c102" );
	level._effect[ "aircraft_light_wingtip_green" ] 					= LoadFX( "misc/aircraft_light_wingtip_green" );
	level._effect[ "aircraft_light_wingtip_red" ] 						= LoadFX( "misc/aircraft_light_wingtip_red" );
	level._effect[ "aircraft_light_white_blink" ] 						= LoadFX( "misc/aircraft_light_white_blink" );
	level._effect[ "aircraft_light_red_blink" ] 						= LoadFX( "misc/aircraft_light_red_blink" );
	level._effect[ "nx_lapes_tank_drop_dust" ] 							= LoadFX( "nx/dust/nx_lapes_tank_drop_dust" );
	level._effect[ "nx_lapes_tank_dust_looping_runner" ] 				= LoadFX( "nx/dust/nx_lapes_tank_dust_looping_runner" );
	level._effect[ "nx_impact_lapes_carhit" ] 							= LoadFX( "nx/impacts/nx_impact_lapes_carhit" );
	level._effect[ "nx_impact_lapes_carhit_small" ] 					= LoadFX( "nx/impacts/nx_impact_lapes_carhit_small" );
	level._effect[ "nx_c102_engine_explosion" ]							= LoadFX( "nx/explosions/nx_c102_engine_explosion" );
	level._effect[ "nx_chinese_ugv_turret_trail_ambient" ]				= LoadFX( "nx/misc/nx_chinese_ugv_turret_trail_ambient" );
	level._effect[ "c102_medium_afterburner" ] 							= loadfx( "nx/fire/nx_repel_looping_medium_afterburner" );
	level._effect[ "c102_large_afterburner" ] 							= loadfx( "nx/fire/nx_repel_looping_large_afterburner" );
	level._effect[ "nx_c102_looping_large_afterburner" ] 				= loadfx( "nx/fire/nx_c102_looping_large_afterburner" );
	level._effect[ "c102_engine_burn_emmiter" ] 						= loadfx( "fire/fire_smoke_trail_L_emitter" );
	level._effect[ "nx_lapes_carhit_explosion" ] 						= loadfx( "nx/explosions/nx_lapes_carhit_explosion" );
	level._effect[ "c102_dust_runner" ] 								= loadfx( "nx/treadfx/nx_c102_lapes_dust_runner" );
	level._effect[ "nx_c102_phalanx_runner" ] 							= loadfx( "nx/misc/nx_c102_phalanx_runner" );
	level._effect[ "nx_amb_smoke_plume_scattered_light_large" ] 		= loadfx( "nx/smoke/nx_amb_smoke_plume_scattered_light_large" );
	level._effect[ "nx_smoke_lapes_drop_linger" ] 						= loadfx( "nx/smoke/nx_smoke_lapes_drop_linger" );
	level._effect[ "nx_debri_paper_fast" ] 								= loadfx( "nx/misc/nx_debri_paper_fast" );
	level._effect[ "nx_fire_car_fire_n_smoke" ] 						= loadfx( "nx/fire/nx_fire_car_fire_n_smoke" );
	level._effect[ "nx_impact_lapes_bus_hit" ]							= LoadFX( "nx/impacts/nx_impact_lapes_bus_hit" );
	level._effect[ "nx_impact_lapes_carhit_sparks_scrape" ]				= LoadFX( "nx/impacts/nx_impact_lapes_carhit_sparks_scrape" );
	level._effect[ "nx_impact_lapes_debri_directional_runner" ]			= LoadFX( "nx/impacts/nx_impact_lapes_debri_directional_runner" );

	//ambient fx                                                        
	level._effect[ "firelp_large_pm_bh1" ] 								= LoadFX( "fire/firelp_large_pm_nolight" );
	level._effect[ "firelp_med_pm_bh1" ] 								= LoadFX( "fire/firelp_med_pm_nolight" );
	level._effect[ "firelp_small_pm" ] 									= LoadFX( "fire/firelp_small_pm_nolight" );
	level._effect[ "fire_falling_runner_point_infrequent" ] 			= LoadFX( "fire/fire_falling_runner_point_infrequent" );
	level._effect[ "firelp_huge_pm_nolight" ] 							= LoadFX( "fire/firelp_huge_pm_nolight" );
	level._effect[ "amb_smoke_add" ] 									= LoadFX( "smoke/amb_smoke_add" );
	level._effect[ "amb_smoke_blend" ] 									= LoadFX( "smoke/amb_smoke_blend" );
	level._effect[ "room_smoke_200" ] 									= LoadFX( "smoke/room_smoke_200" );
	level._effect[ "steam_cs" ] 										= LoadFX( "smoke/steam_cs" );
	level._effect[ "nx_light_floor_square_small_red" ] 					= LoadFX( "nx/misc/nx_light_floor_square_small_red" );
    level._effect[ "fire_light_small" ]									= LoadFX( "nx/misc/nx_light_orange_small" );
    level._effect[ "nx_light_emergency_red" ]							= LoadFX( "nx/misc/nx_light_emergency_red" );

	level._effect[ "nx_sparks_falling_runner" ]							= LoadFX( "nx/explosions/nx_sparks_falling_runner" );

	//light shaft fx                                                    
	level._effect[ "light_dust_particles" ] 							= LoadFX( "dust/light_dust_particles" );
	level._effect[ "light_shaft_dust_large" ] 							= LoadFX( "dust/light_shaft_dust_large" );
	level._effect[ "light_shaft_dust_med" ] 							= LoadFX( "dust/light_shaft_dust_med" );
	level._effect[ "light_shaft_motes_airport" ] 						= LoadFX( "dust/light_shaft_motes_airport" );
	level._effect[ "nx_gfx_godray_side" ] 								= LoadFX( "nx/misc/nx_gfx_godray_side" );
	level._effect[ "nx_gfx_godray_side_small" ] 						= LoadFX( "nx/misc/nx_gfx_godray_side_small" );
	level._effect[ "nx_gfx_godray_down" ] 								= LoadFX( "nx/misc/nx_gfx_godray_down" );

	level._effect[ "flashlight" ]												=LoadFX( "misc/flashlight" );
	level._effect[ "flashlight_spotlight" ]												=LoadFX( "misc/flashlight_spotlight" );
	level._effect[ "spotlight_dlight" ]												=LoadFX( "misc/spotlight_dlight" );
	level._effect[ "spotlight_small" ]												=LoadFX( "misc/spotlight_small" );
	level._effect[ "hunted_spotlight_model" ]										=LoadFX( "misc/hunted_spotlight_model" );
//	level._effect[ "nx_lunar_rover_headlight_light" ]										=LoadFX( "misc/nx_lunar_rover_headlight_light" );
	
	level._effect[ "dust_outdoor_large" ] 								= LoadFX( "dust/dust_outdoor_large" );
	level._effect[ "dust_wind_fast_paper" ] 							= LoadFX( "dust/dust_wind_fast_paper" );
	level._effect[ "paper_falling_burning" ] 							= LoadFX( "misc/paper_falling_burning" );
	level._effect[ "ground_fog" ] 										= LoadFX( "dust/ground_fog" );
	
    // Door opening sequence
	level._effect[ "decompression_exitdoor_dust" ]			 			= loadfx( "dust/decompression_exitdoor_dust" );

	//vp hit fx
	level._effect[ "nx_vphit_explosion" ] 								= LoadFX( "nx/hithard/nx_vphit_explosion" );
	level._effect[ "crawling_death_blood_smear" ] 						= LoadFX( "impacts/blood_smear_decal" );
	level._effect[ "blood_pool" ]					 					= loadfx( "impacts/deathfx_bloodpool_generic" );
	level._effect[ "nx_flesh_hit_splat_large" ]					 		= loadfx( "impacts/nx_flesh_hit_splat_large" );
	level._effect[ "nx_flesh_hit_splat" ]					 			= loadfx( "impacts/nx_flesh_hit_splat" );

	apply_hh_b_fog_();
}                                                                       


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

apply_hh_b_fog_()
{
	//transition_time = 3.0;
	//set_vision_set( "nx_hithard_landing", transition_time );
	setExpFog( 2166, 20398, 0.6156863, 0.5137255, 0.4, 0.4151667, 0, 0.9215686, 0.9019608, 0.772549, ( 0.945059, -0.0464278, 0.323587 ), 0, 38, 2.17 );
}

//vp blood smear
vphit_dyingCrawlBloodSmear( vp_vpdrag )
{	
/*

	tagPos = vp_vphit gettagorigin( "j_SpineUpper" );	// rough tag to play fx on
	origintag = "J_SpineLower";
	angletag = "tag_origin";
	
	fx_rate = .25;
	fx = level._effect[ "crawling_death_blood_smear" ];
	
	while( fx_rate )
	{
		org = vp_vpdrag gettagorigin( origintag );
		angles = vp_vpdrag GetTagAngles( angletag );
		forward = anglestoright( angles );
		up = anglestoforward( ( 270, 0, 0 ) );
		
		playfx( fx, org, up, forward );
		
		wait( fx_rate );
	}
	*/

	fx = level._effect[ "crawling_death_blood_smear" ];

	fx_rate = .25;
	//self endon( "death" );

	last_org = vp_vpdrag.origin;

	while ( fx_rate )
	{
		randomoffset = flat_origin( randomvectorrange( -10, 10 ) );
		org = vp_vpdrag.origin + randomoffset;
		org = drop_to_ground( org ) + ( 0, 0, 5 );
		angles = VectorToAngles( vp_vpdrag.origin - last_org );
		forward = AnglesToRight( angles );
		up = AnglesToForward( ( 270, 0, 0 ) );
//		Line( org, level.player.origin,(0,0,0),1,false,40 );
		PlayFX( fx, org, up, forward );
		wait( fx_rate );
	}

}

//vp blood pools
vp_blood_fall( vp_vphit )
{

	tagPos = vp_vphit gettagorigin( "j_SpineUpper" );	// rough tag to play fx on
	tagAngles = vp_vphit gettagangles( "j_SpineUpper" );
	forward = anglestoforward( tagAngles );
	up = anglestoup( tagAngles );
	right = anglestoright( tagAngles );

	tagPos = tagPos + vector_multiply( forward, -8.5 ) + vector_multiply( up, 5 ) + vector_multiply( right, 0 );

	trace = bulletTrace( tagPos + ( 0, 0, 30 ), tagPos - ( 0, 0, 100 ), false, undefined );
	
	if ( trace[ "normal" ][2] > 0.9 )
		playfx( level._effect[ "blood_pool" ], tagPos );
}

vphit_slomo()
{
	slomoLerpTime_in = 0.6;
	slomoLerpTime_out = 0.65;
	slomobreachplayerspeed = 0.1;
	slomoSpeed = 0.1;
	slomoDuration = 10;	

	// Start slo motion
	slowmo_start();
	slowmo_setspeed_slow( slomoSpeed );
	slowmo_setlerptime_in( slomoLerpTime_in );
	slowmo_lerp_in();
	
	level._player SetMoveSpeedScale( slomobreachplayerspeed );
	 
	// Wait slo mo duration
	wait slomoDuration * slomoSpeed;
	
	// Stop slo motion
	slowmo_setlerptime_out( slomoLerpTime_out );
	slowmo_lerp_out();
	slowmo_end();
	level._player SetMoveSpeedScale( 1.0 );
}
