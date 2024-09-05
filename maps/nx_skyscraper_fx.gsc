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
#include common_scripts\_nx_fx;
#include maps\_utility;
#include common_scripts\utility;

main()
{
	// Temp FX
	level._effect[ "firelp_large_pm_bh1" ] 								= LoadFX( "fire/firelp_large_pm_nolight" );
	level._effect[ "firelp_med_pm_bh1" ] 								= LoadFX( "fire/firelp_med_pm_nolight" );
	level._effect[ "firelp_small_pm" ] 									= LoadFX( "fire/firelp_small_pm_nolight" );
	level._effect[ "firelp_huge_pm_nolight" ] 							= LoadFX( "fire/firelp_huge_pm_nolight" );
	level._effect[ "amb_smoke_add" ] 									= LoadFX( "smoke/amb_smoke_add" );
	level._effect[ "amb_smoke_blend" ] 									= LoadFX( "smoke/amb_smoke_blend" );
	level._effect[ "room_smoke_200" ] 									= LoadFX( "smoke/room_smoke_200" );
	level._effect[ "fire_light_small" ]									= LoadFX( "nx/misc/nx_light_orange_small" );
	level._effect[ "laser_impact" ] 									= LoadFX( "impacts/small_metalhit" );
	level._effect[ "steam_hall_200" ]									= LoadFX( "smoke/steam_hall_200" );
	level._effect[ "steam_large_vent" ]									= LoadFX( "smoke/steam_large_vent" );
	level._effect[ "steam_room_100_orange" ]							= LoadFX( "smoke/steam_room_100_orange" );
	level._effect[ "nx_explosion_skybridge" ]							= LoadFX( "nx/explosions/nx_explosion_skybridge" );
	level._effect[ "cloud_bank_gulag" ]									= LoadFX( "weather/cloud_bank_gulag" );
	level._effect[ "explosion_type_1" ]					 				= loadfx( "explosions/wall_explosion_1" );
	level._effect[ "concrete_pillar_explosion" ]					 	= loadfx( "explosions/breach_wall_concrete_whitehouse" );
	level._effect["fire_fallingdebris"]									= loadfx ("fire/fire_fallingdebris");	
	level._effect[ "nx_smoke_n_fire_plume_preseed" ]					= LoadFX( "nx/smoke/nx_smoke_n_fire_plume_preseed" );
	level._effect[ "elevator_ceiling_light" ]							= LoadFX( "nx/misc/nx_simple_light" );

	// Flashlight and spotlights
	level._effect[ "flashlight" ]                   = LoadFX( "misc/flashlight" );
	level._effect[ "flashlight_spotlight" ]         = LoadFX( "misc/flashlight_spotlight" );
	level._effect[ "spotlight_white" ]				= LoadFX( "nx/misc/nx_ec_uav_spotlight_model_fake" );
	level._effect[ "spotlight_red" ]				= LoadFX( "misc/lighthaze_snow_spotlight" );
	level._effect[ "spotlight_dynamic" ]			= LoadFX( "nx/misc/nx_ec_uav_spotlight_model" );

	// Halon fx
	level._effect[ "nx_halon_gas_cloud" ]								= loadfx( "nx/smoke/nx_halon_gas_cloud" );
	level._effect[ "nx_halon_gas_cloud_far" ]							= loadfx( "nx/smoke/nx_halon_gas_cloud_far" );
	level._effect[ "nx_halon_gas_cloud_standing" ]						= loadfx( "nx/smoke/nx_halon_gas_cloud_standing" );
	level._effect[ "nx_halon_gas_jet" ]									= loadfx( "nx/smoke/nx_halon_gas_jet" );
	
	// Space Laser!
	level._effect[ "nx_laser_orbital_runner" ]							= LoadFX( "nx/misc/nx_laser_orbital_runner" );
	level._effect[ "nx_laser_orbital_strike" ]							= LoadFX( "nx/misc/nx_laser_orbital_strike" );
	level._effect[ "nx_laser_orbital_strike_short" ]					= LoadFX( "nx/misc/nx_laser_orbital_strike_short" );

	level._effect[ "amb_smoke_add_1" ]									= LoadFX( "smoke/amb_smoke_add_1" );
	level._effect[ "nx_ash_dust_400" ]									= LoadFX( "nx/dust/nx_ash_dust_400" );
	level._effect[ "nx_dust_dark_200" ]									= LoadFX( "nx/dust/nx_dust_dark_200" );
	level._effect[ "nx_falling_debris_small_runner_400x400" ]			= LoadFX( "nx/misc/nx_falling_debris_small_runner_400x400" );
	level._effect[ "nx_godray_ss_slats" ]								= LoadFX( "nx/misc/nx_godray_ss_slats" );

	// Lower Smog Layer
	level._effect[ "nx_smog_patch_01" ]									= loadFX( "nx/weather/nx_smog_patch_01" );
	level._effect[ "nx_smog_patch_02" ]									= loadFX( "nx/weather/nx_smog_patch_02" );
	level._effect[ "nx_smog_patch_thin_01" ]							= loadFX( "nx/weather/nx_smog_patch_thin_01" );

	// Upper Smog Layer
	level._effect[ "nx_smog_building_base_01" ]							= LoadFX( "nx/weather/nx_smog_building_base_01" );
	level._effect[ "nx_smog_building_base_01_far" ]						= LoadFX( "nx/weather/nx_smog_building_base_01_far" );

	// Office Inferno
	level._effect[ "fire_falling_runner" ]								= LoadFX( "fire/fire_falling_runner" );
	level._effect[ "nx_fire_ceiling_corner_runner_01" ]					= LoadFX( "nx/fire/nx_fire_ceiling_corner_runner_01" );
	level._effect[ "nx_fire_ceiling_corner_runner_02" ]					= LoadFX( "nx/fire/nx_fire_ceiling_corner_runner_02" );
	level._effect[ "nx_fire_ceiling_column_01" ]						= LoadFX( "nx/fire/nx_fire_ceiling_column_01" );
	level._effect[ "nx_fire_column_corner_01" ]							= LoadFX( "nx/fire/nx_fire_column_corner_01" );
	level._effect[ "nx_fire_column_small_01" ]							= LoadFX( "nx/fire/nx_fire_column_small_01" );
	level._effect[ "nx_fire_ground_spots_medium_01" ] 					= LoadFX( "nx/fire/nx_fire_ground_spots_medium_01" );
	level._effect[ "nx_fire_tree_medium_01" ] 							= LoadFX( "nx/fire/nx_fire_tree_medium_01" );
	level._effect[ "nx_fire_wall_flat_01" ]								= LoadFX( "nx/fire/nx_fire_wall_flat_01" );
	level._effect[ "nx_fire_wall_flat_02" ]								= LoadFX( "nx/fire/nx_fire_wall_flat_02" );
	level._effect[ "nx_fire_wall_medium_01" ] 							= LoadFX( "nx/fire/nx_fire_wall_medium_01" );
	level._effect[ "nx_embers_ambient_swirl_local" ] 					= LoadFX( "nx/fire/nx_embers_ambient_swirl_local" );
	level._effect[ "nx_ceiling_smoke_400" ]								= LoadFX( "nx/smoke/nx_ceiling_smoke_400" );
	level._effect[ "nx_smoke_amb_scrolling_smoke_small" ]				= LoadFX( "nx/smoke/nx_smoke_amb_scrolling_smoke_small" );

	// Window cut
	level._effect[ "spark_fountain" ]									= loadFX( "misc/spark_fountain" );
	level._effect[ "nx_ss_window_debris" ]								= loadFX( "nx/misc/nx_ss_window_debris" );
	level._effect[ "nx_ss_window_debris_swirl" ]						= loadFX( "nx/misc/nx_ss_window_debris_swirl" );

	maps\createfx\nx_skyscraper_fx::main();
}

player_rappel_blur_off()
{
	level._player SetBlurForPlayer(0, 0.001, 1, 0, 0, 0, 0, (1,1,1) );
}

player_rappel_blur()
{
	// todo: function endon()

	wait 1.0; // temp to make sure the player stuff is setup for the objects we're dealing with.
	//level._player waittill( "notify_rappel_setup_complete" );

	// these are the values to play with, ask kmckisic if you have any questions...
	max_vel = 1000; // max velocity as it maps to the 0-1 range of the blur_strength
	update_timer = 0.40; // interval to update this effect with a new target set or parameters - a larger value will make the in/out of the effect take longer, and feel more swimmy
	max_blur_str = 0.5; //0.7; // throttle the maximum amount of blur
	darkening_amt = 0.4; // 0 is none, 1 is a lot
	streak_str = 1.5; // length of the streaks, realtive to the overal blur strength.
	blur_inside = 0.5; //0.3; // interior radius - this will be clear
	blur_outside = 0.8; //0.6; // outside radius of the effect
	vignette_radius = 0.7;  // radius where the darkening kicks in
	bPrint_debug_info = false;


	mover_origin_last = level._player_mover.origin;

	while (1)
	{
		mover_origin_now = level._player_mover.origin;
		vel = (mover_origin_now - mover_origin_last) * (1.0/update_timer);
		blur_level = (clamp((abs(vel[2]) / max_vel), 0.001, 1.0)) * max_blur_str; // resulting blur amt between 0 and 1;
		cam_dir = level._player GetPlayerViewAngles(); // player's view direction.
		cam_pitch = cam_dir[0];
		pitch_str = 0.0;
		if (cam_pitch > 0)
			pitch_str = (cam_pitch / 90.0); // looking down, get a % of the max angle

		pitch_str = clamp(pitch_str, 0.001, 1.0); // resulting blur amt between 0 and 1;
		streak_amt = blur_level * streak_str; // update streak amt
		darkness_amt = abs (1.0-blur_level * darkening_amt); // darkening is goverened overall by the blur_amt

		// debug values
		if (bPrint_debug_info)
			IPrintLn( "blr%= " + blur_level + "  ; vel=" + vel[2] + "  ; ptch % = " + pitch_str ); // debug

		// SetBlurForPlayer( &lt;target_blur&gt;, &lt;time&gt;, &lt;radialBlur&gt;, radius, &lt;radialBlurInner&gt;, &lt;radialBlurOuter&gt;, &lt;radialBlurColorRadius&gt;, &lt;radialBlurColor&gt; )
		level._player SetBlurForPlayer((blur_level * pitch_str), update_timer, 1, streak_amt, blur_inside, blur_outside, vignette_radius, (darkness_amt,darkness_amt,darkness_amt) ); // set the blur
		mover_origin_last = mover_origin_now;

		wait update_timer;
	}
}

init_vision_set_triggers()
{
	// Vision Set Triggers
	thread trigger_rappel_fog();
	thread trigger_atrium();
	thread trigger_fire_offices();
	thread trigger_default();
	thread trigger_halon();
	thread trigger_robotics_01();
	thread trigger_infiltration();
	thread trigger_vault();
	thread trigger_vtol();
	thread trigger_ext_up_high();
	thread trigger_rappel();
}


// DEFAULT vission set from trigger
set_default_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_skyscraper_default", transition_time);
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 0, 1, 0.7529412, 0.7529412, 0.7529412, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1 );
	// fx_set_skyfog( height_start, height_end, height_blend, transition_time );
	//no skyfog

}
// exterior street level... set the vision and fog settings for the exterior, at the street level
set_exterior_street_level_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_skyscraper", transition_time);
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 3971, 15885, 0.9019608, 0.8784314, 0.8588235, 0.6245334, 0, 0, 0, 0.8666667, 0.8117647, 0.7843137, 0.6862745, 0.5647059, 0.4039216 );
	SetSavedDVar ("r_fog_height_blend", 0.9);
	SetSavedDVar ("r_fog_height_start", 0);
	SetSavedDVar ("r_fog_height_end", 0.1);


	// fx_set_skyfog( height_start, height_end, height_blend, transition_time );
	//fx_set_skyfog( 0.0, 0.0, 0.85, transition_time );
}
// exterior above smog... set the vision and fog settings for the exterior, above the smog layer
set_ext_up_high_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_skyscraper_ext_up_high", transition_time);
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 6137, 38628, 0.8039216, 0.6588235, 0.5921569, 1, transition_time, 0, 0, 1, 1, 1, 1, 1, 1 );	
	fx_set_skyfog( 0.8, 1.5, 1.65, transition_time );
}

// building interior vision set from trigger
set_building_interior_vision_and_fog(transition_time)
{
/*
	VisionSetNaked("nx_skyscraper_default", transition_time);
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 0, 1, 0.7529412, 0.7529412, 0.7529412, 0, transition_time, 0, 0, 1, 1, 1, 1, 1, 1 );
	// fx_set_skyfog( height_start, height_end, height_blend, transition_time );
	//no skyfog
*/
}

// atrium trigger
set_atrium_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_skyscraper_atrium", transition_time);
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 2888, 9568, 0.8235294, 0.7372549, 0.5764706, .25, transition_time, 0.148, 0, 1, 1, 1, 0.1411765, 0.1215686, 0.07450981 );
	// fx_set_skyfog( height_start, height_end, height_blend, transition_time );
	fx_set_skyfog( 0.0, 0.0, 0.85, transition_time );
}

// elev_shaft trigger
set_elev_shaft_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_skyscraper_elev_shaft", transition_time);
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 20, 11914, 0.5882353, 0.6431373, 0.7294118, 0.1372, 4.0, 0.7256, 0, 0.5882353, 0.6431373, 0.7294118, 0.1372549, 0.1215686, 0.06666667 );
	// fx_set_skyfog( height_start, height_end, height_blend, transition_time );
	//no skyfog
}

// fire_offices trigger
set_fire_offices_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_skyscraper_floor_collapse_offices", transition_time);
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 5, 904, 0.6235294, 0.1176471, 0.05882353, 0.1408, transition_time, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0.7490196, ( 0, 0, 0 ), 0, 1, 0 );	
	// fx_set_skyfog( height_start, height_end, height_blend, transition_time );
	//no skyfog
}

// infiltration trigger
set_infiltration_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_skyscraper_infiltration", transition_time);
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 5, 20000, 0.0611764, 0.07058824, 0.07058824, 0, transition_time, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0.7490196, ( 0, 0, 0 ), 0, 1, 0 );
	//no skyfog
}

// robotics_01 trigger
set_robotics_01_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_skyscraper_robotics_01", transition_time);
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 300, 1200, 0.3568628, 0.4666667, 0.6392157, 1, transition_time, 1, 0, 0.5450981, 0.5450981, 0.5450981, 1, 1, 1 );
	//no skyfog
}

// vault trigger
set_vault_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_skyscraper_vault", transition_time);
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 300, 1200, 0.3568628, 0.4666667, 0.6392157, 1, transition_time, 1, 0, 0.5450981, 0.5450981, 0.5450981, 1, 1, 1 );
	//no skyfog
}

// vtol trigger
set_vtol_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_skyscraper_vtol", transition_time);
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 1444, 1806, 0.9921569, 0.7137255, 0.5254902, 1, transition_time, 0, 0, 1, 1, 1, 1, 1, 1 );
	fx_set_skyfog( 1.0, 0.2, 0.5, transition_time );
}

// rappel trigger
set_rappel_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_skyscraper_rappel", transition_time);
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 2166, 15885, 0.9019608, 0.8745098, 0.8588235, 0.1841, transition_time, 0.3646, 0, 0.8666667, 0.8117647, 0.7843137, 0.6862745, 0.5647059, 0.4039216 );
}


set_vision_and_fog(area, transition_time)
{
	switch ( area )
	{
		case "default":
			set_default_vision_and_fog(transition_time);
			break;
		case "atrium":
			set_atrium_vision_and_fog(transition_time);
			break;
		case "elev_shaft":
			set_elev_shaft_vision_and_fog(transition_time);
			break;
		case "fire_offices":
			set_fire_offices_vision_and_fog(transition_time);
			break;
		case "exterior_ground_level":
			set_exterior_street_level_vision_and_fog(transition_time);
			break;
		case "ext_up_high":
			set_ext_up_high_vision_and_fog(transition_time);
			break;
		case "interior":
			set_building_interior_vision_and_fog(transition_time);
			break;
		case "robotics_01":
			set_robotics_01_vision_and_fog(transition_time);
			break;
		case "infiltration":
			set_infiltration_vision_and_fog(transition_time);
			break;
		case "vault":
			set_vault_vision_and_fog(transition_time);
			break;
		case "vtol":
			set_vtol_vision_and_fog(transition_time);
			break;
		case "rappel":
			set_rappel_vision_and_fog(transition_time);
			break;
		default:
			set_default_vision_and_fog(transition_time);
			break;
	}
}

trigger_rappel_fog()
{	
	flag_wait("flag_fx_rappel_vision_1");
	

	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 0, 182, 0.4980392, 0.4980392, 0.4980392, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1 );

	//SetSavedDVar ("r_fog_height_blend", 1);
	//SetSavedDVar ("r_fog_height_start", 0);
	//SetSavedDVar ("r_fog_height_end", 0);

	wait 5;

	VisionSetNaked("nx_skyscraper", 1);
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 2888, 9568, 0.8235294, 0.7372549, 0.5764706, .25, 1, 0.148, 0, 1, 1, 1, 0.1411765, 0.1215686, 0.07450981 );
	// fx_set_skyfog( height_start, height_end, height_blend, transition_time );
	fx_set_skyfog( 0.0, 0.0, 0.85, 1 );

}

//Vision Set Triggers

trigger_atrium()
{
	flag_wait("flag_fx_atrium");

	set_vision_and_fog("atrium", 3.0);
}

trigger_fire_offices()
{
	flag_wait("flag_fx_fire_offices");

	set_vision_and_fog("fire_offices", 10.0);
}

trigger_default()
{
	flag_wait("flag_fx_default");

	set_vision_and_fog("default", 4.0);
}

trigger_halon()
{
	flag_wait("flag_fx_halon");

	set_vision_and_fog("default", 4.0);
}

trigger_elev_shaft()
{
	wait .5;

	set_vision_and_fog("elev_shaft", 4.0);
}

//script_flag (kvp)
trigger_infiltration()
{
	flag_wait("flag_fx_infiltration");

	set_vision_and_fog("infiltration", 4.0);
}

trigger_robotics_01()
{
	flag_wait("flag_fx_robotics_01");

	set_vision_and_fog("robotics_01", 10.0);
}

trigger_vault()
{
	flag_wait("flag_fx_vault");

	set_vision_and_fog("vault", 10.0);
}

trigger_vtol()
{
	flag_wait("flag_fx_vtol");

	set_vision_and_fog("vtol", 10.0);
}

trigger_ext_up_high()
{
	flag_wait("flag_fx_ext_up_high");

	set_vision_and_fog("ext_up_high", 3.0);
}

trigger_rappel()
{
	flag_wait("flag_fx_rappel");
	iprintln("flag_rappel_triggered");
	set_vision_and_fog("rappel", 4.0);
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
