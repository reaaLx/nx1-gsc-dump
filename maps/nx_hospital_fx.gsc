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

main()
{	
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\nx_hospital_fx::main();
	
	fx_init_flags();

	//level._pipe_fx_time = 5;

	// Flashlight
	level._effect[ "flashlight" ]												= LoadFX( "nx/misc/nx_flashlight_spotlight" );
	level._effect[ "silencer_flash" ]											= LoadFX( "muzzleflashes/m4m203_silencer" );	
	level._effect[ "offensive_grenade_window" ]									= LoadFX( "nx/explosions/nx_concussion_grenade_window" );
	level._effect[ "offensive_grenade_door" ]									= LoadFX( "nx/explosions/nx_concussion_grenade_door" );
	level._effect[ "offensive_grenade_indoor_explosion" ]						= LoadFX( "nx/explosions/nx_concussion_grenade" );
	level._effect[ "nx_concussion_grenade_gibs" ]								= LoadFX( "nx/impacts/nx_concussion_grenade_gibs" );

	//ambient fx
	level._effect[ "nx_godray_ss_slats" ]										= LoadFX( "nx/misc/nx_godray_ss_slats" );
	level._effect[ "nx_dust_mote_80" ]											= loadfx( "nx/dust/nx_dust_mote_80_small" );
	level._effect[ "nx_dust_spiral_runner_mp" ]									= loadfx( "nx/dust/nx_dust_spiral_runner_mp" );
	level._effect[ "nx_dust_wind_canyon_mp" ]									= loadfx( "nx/dust/nx_dust_wind_canyon_mp" );
	level._effect[ "nx_godray_150_soft" ]										= loadfx( "nx/misc/nx_godray_150_soft" );
	level._effect[ "nx_godray_225_soft" ]										= loadfx( "nx/misc/nx_godray_225_soft" );
	level._effect[ "nx_godray_75_soft" ]										= loadfx( "nx/misc/nx_godray_75_soft" );
	level._effect[ "nx_hawks_mp" ]												= loadfx( "nx/misc/nx_hawks_mp" );
	level._effect[ "amb_smoke_blend" ]											= loadfx( "smoke/amb_smoke_blend" );
	level._effect[ "nx_trash_runner_1024" ]										= loadfx( "nx/misc/nx_trash_runner_1024" );
	level._effect[ "nx_sparks_falling_runner" ]									= loadfx( "nx/explosions/nx_sparks_falling_runner" );
	level._effect[ "trash_spiral_runner" ]										= loadfx( "misc/trash_spiral_runner" );
	level._effect[ "paper_blowing_trash" ]										= loadfx( "misc/paper_blowing_trash" );
	level._effect[ "room_smoke_400" ]											= loadfx( "nx/smoke/nx_room_smoke_400" );
	level._effect[ "drips_fast" ]	 											= loadfx( "misc/drips_fast" );

	//propane explosion fx
	level._effect[ "nx_building01_missilehit_windows_small" ]					= loadfx( "nx/explosions/nx_building01_missilehit_windows_small" );
	level._effect[ "nx_fire_wall_flat_01" ]										= loadfx( "nx/fire/nx_fire_wall_flat_01" );
	level._effect[ "nx_fire_wall_flat_02" ]										= loadfx( "nx/fire/nx_fire_wall_flat_02" );
	level._effect[ "nx_fire_tree_small_01_short" ]								= loadfx( "nx/fire/nx_fire_tree_small_01_short" );
	level._effect[ "nx_fire_tree_small_01" ]									= loadfx( "nx/fire/nx_fire_tree_small_01" );
	level._effect[ "nx_fire_tree_medium_01" ]									= loadfx( "nx/fire/nx_fire_tree_medium_01" );
	level._effect[ "nx_fire_wall_small_01_short" ]								= loadfx( "nx/fire/nx_fire_wall_small_01_short" );
	level._effect[ "powerline_runner_cheap" ]									= loadfx( "explosions/powerline_runner_cheap" );
	level._effect[ "ceiling_dust_default" ]										= loadfx( "dust/ceiling_dust_default" );

    // Spotlight
	level._effect[ "light_blowout" ]											= loadfx( "misc/light_blowout_large_radial" );
	level._effect[ "generator_blink" ]											= loadfx( "misc/aircraft_light_red_blink" );

	//wall chunk fx
	level._effect[ "nx_impact_plaster_hospital" ]								= loadfx( "nx/impacts/nx_impact_plaster_hospital" );

	//assasination blood
	level._effect[ "nx_flesh_hospital_bed" ]									= loadfx( "nx/impacts/nx_flesh_hospital_bed" );

	fx_vision_fog_init();
}	

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

outro_blood_fx( vignette_outro_opfor )
{
	wait 22.3;
	//iPrintLnBold("blood 1");
	PlayFXOnTag( level._effect[ "nx_flesh_hospital_bed" ],  vignette_outro_opfor, "tag_inhand");
	wait .85;
	PlayFXOnTag( level._effect[ "nx_flesh_hospital_bed" ],  vignette_outro_opfor, "tag_inhand");
}

fx_init_flags()
{
	// flags you're using need to be initialized	

	flag_init( "first_floor_room_enter");
	flag_init( "first_floor_room_leave");
	flag_init( "vf_enter_construction");
	flag_init( "vf_enter_corridor");
	flag_init( "vf_corridor_flare_none" );
	flag_init( "vf_corridor_flare_1" );
	flag_init( "vf_corridor_flare_2" );
	flag_init( "lobby_light_destroyed" );
	flag_init( "hallway_light_destroyed" );
	//flag_init( "" );

}

fx_vision_fog_init()
{
	//fx_init_flags();
	thread trigger_vf_default();
	thread trigger_vf_first_floor();
	//thread trigger_vf_first_floor_room();
	//thread trigger_vf_second_floor();
	thread trigger_vf_construction();
	//thread trigger_vf_atrium();
	thread trigger_vf_enter_corridor();
	thread trigger_vf_corridor_flare_1();
	thread trigger_vf_corridor_flare_2();
	thread trigger_vf_corridor_flare_none();
}



// set the vision and fog settings for base alpha
set_default_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_hospital", transition_time);
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	//setExpFog( 0, 12095, 0.4941176, 0.5686275, 0.572549, 0.05416667, transition_time, 0.5667667, 0, 0.5921569, 0.4941176, 0.4078431, 0.4823529, 0.5019608, 0.5176471 );
}

set_first_floor_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_hospital_first_floor", transition_time);
	//setExpFog( 0, 12095, 0.4941176, 0.5686275, 0.572549, 0.05416667, transition_time, 0.5667667, 0, 0.5921569, 0.4941176, 0.4078431, 0.4823529, 0.5019608, 0.5176471 );
}

set_second_floor_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_hospital", transition_time);
	//setExpFog( 0, 12095, 0.4941176, 0.5686275, 0.572549, 0.05416667, transition_time, 0.5667667, 0, 0.5921569, 0.4941176, 0.4078431, 0.4823529, 0.5019608, 0.5176471 );
}

set_construction_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_hospital_construction", transition_time);
	//setExpFog( 0, 12095, 0.4941176, 0.5686275, 0.572549, 0.05416667, transition_time, 0.5667667, 0, 0.5921569, 0.4941176, 0.4078431, 0.4823529, 0.5019608, 0.5176471 );
}

set_atrium_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_hospital_atrium", transition_time);
	//setExpFog( 0, 12095, 0.4941176, 0.5686275, 0.572549, 0.05416667, transition_time, 0.5667667, 0, 0.5921569, 0.4941176, 0.4078431, 0.4823529, 0.5019608, 0.5176471 );
}

set_enter_corridor_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_hospital_enter_corridor", transition_time);
	//setExpFog( 0, 12095, 0.4941176, 0.5686275, 0.572549, 0.05416667, transition_time, 0.5667667, 0, 0.5921569, 0.4941176, 0.4078431, 0.4823529, 0.5019608, 0.5176471 );
}

set_corridor_vision_and_fog(transition_time)
{
	//VisionSetNaked("nx_hospital", transition_time);
	VisionSetNaked("nx_hospital_corridor", transition_time);
	VisionSetSun("nx_hospital_corridor", transition_time);
	//setExpFog( 0, 12095, 0.4941176, 0.5686275, 0.572549, 0.05416667, transition_time, 0.5667667, 0, 0.5921569, 0.4941176, 0.4078431, 0.4823529, 0.5019608, 0.5176471 );
}

set_corridor_flare_1_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_hospital_corridor", transition_time);
	//VisionSetSun(vision_set_name, <transition_time>. <intensity>. <sun_direction>
	VisionSetSun("nx_hospital_corridor_flare", transition_time, 0.5, 20, 40, (-0.99, 0.06, 0.053));	
	//setExpFog( 0, 12095, 0.4941176, 0.5686275, 0.572549, 0.05416667, transition_time, 0.5667667, 0, 0.5921569, 0.4941176, 0.4078431, 0.4823529, 0.5019608, 0.5176471 );
}

set_corridor_flare_2_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_hospital_corridor", transition_time);
	VisionSetSun("nx_hospital_corridor_flare", transition_time, 1, 20, 40, (-0.075, -0.996, 0.049));
	//setExpFog( 0, 12095, 0.4941176, 0.5686275, 0.572549, 0.05416667, transition_time, 0.5667667, 0, 0.5921569, 0.4941176, 0.4078431, 0.4823529, 0.5019608, 0.5176471 );
}

set_vision_and_fog(area, transition_time)
{
	//iPrintLnBold("Change vision and fog - " + area);
	switch ( area )
	{
		case "first_floor":
			set_first_floor_vision_and_fog(transition_time);
			break;
		case "second_floor":
			set_second_floor_vision_and_fog(transition_time);
			break;
		case "construction":
			set_construction_vision_and_fog(transition_time);
			break;
		case "atrium":
			set_atrium_vision_and_fog(transition_time);
			break;
		case "enter_corridor":
			set_enter_corridor_vision_and_fog(transition_time);
			break;
		case "corridor":
			set_corridor_vision_and_fog(transition_time);
			break;
		case "corridor_flare_1":
			set_corridor_flare_1_vision_and_fog(transition_time);
			break;
		case "corridor_flare_2":
			set_corridor_flare_2_vision_and_fog(transition_time);
			break;
		case "default":
			set_default_vision_and_fog(transition_time);
			break;
		default:
			set_default_vision_and_fog(transition_time);
	}
}

trigger_vf_default()
{
	//flag_wait( "chopper_ride_bridge_intro" );
	//set_vision_and_fog("default", 0);
}

trigger_vf_first_floor()
{
	//flag_wait( "chopper_path_entering_base_alpha" );
	set_vision_and_fog("first_floor", 5.0);
}

trigger_vf_first_floor_room()
{
	//flag_wait( "chopper_path_entering_base_alpha" );
	//set_vision_and_fog("first_floor", 5.0);
}

trigger_vf_second_floor()
{
	//flag_wait( "music_chk_bridge" );
	//wait 7;
	//set_vision_and_fog("second_floor", 7);
}

trigger_vf_construction()
{
	flag_wait( "vf_enter_construction" );
	//set_vision_and_fog("construction", 0.05);
	wait 1;
	set_vision_and_fog("atrium", 3.0);
}

trigger_vf_atrium()
{
	//flag_wait( "crash_section_transition" );
	//set_vision_and_fog("atrium", 3.0);
}

trigger_vf_enter_corridor()
{
	flag_wait( "vf_enter_corridor");
	set_vision_and_fog("enter_corridor", 4);
	wait 2;
	set_vision_and_fog("corridor", 3);
}

trigger_vf_corridor_flare_1()
{
	flag_wait( "vf_corridor_flare_1");
	set_vision_and_fog("corridor_flare_1", 1.5);
	flag_wait( "lobby_light_destroyed");
	set_vision_and_fog("corridor", 0.25);
}

trigger_vf_corridor_flare_2()
{
	flag_wait( "vf_corridor_flare_2");
	set_vision_and_fog("corridor_flare_2", 1.5);
	flag_wait( "hallway_light_destroyed");
	set_vision_and_fog("corridor", 0.25);
}

trigger_vf_corridor_flare_none()
{
	flag_wait( "vf_corridor_flare_none");
	//set_vision_and_fog("corridor_flare_none", 0);
	set_vision_and_fog("corridor", 2);
}
