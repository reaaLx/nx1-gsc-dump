//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  FX Support													**
//                                                                          **
//    Created: DATE - CREATOR												
//                                                                          **
//****************************************************************************
#include maps\_utility;
#include common_scripts\utility;

main()
{
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\nx_lava_fx::main();
	}

	level._effect[ "tunnel_light_1" ] 		    = LoadFX( "nx/nx_lava/nx_lava_tunnel_spotlight_01" );
	level._effect[ "tunnel_light_2" ] 		    = LoadFX( "nx/nx_lava/nx_lava_tunnel_spotlight_02" );
	level._effect[ "tunnel_light_static_1" ]    = LoadFX( "nx/nx_lava/nx_lava_tunnel_fx_static_light_01" );
	level._effect[ "tunnel_travlin_motes" ] 	= LoadFX( "nx/nx_lava/nx_lava_tunnel_lit_motes_runners" );
	level._effect[ "train_headlight" ] 		    = LoadFX( "nx/nx_lava/nx_lava_train_headlight01" );

	level._effect[ "wall_light_white_01" ]      = LoadFX( "misc/light_glow_walllight_white" );
	level._effect[ "train_rego_falling_dust01" ]  = LoadFX( "nx/nx_lava/nx_lava_large_falling_rego_emit" );
	level._effect[ "train_rego_train_trail01" ]  = LoadFX( "nx/nx_lava/nx_lava_train_rego_trail_emit" );

	//train interior seperation fx
	level._effect[ "fake_tracer_hits" ] 		 = LoadFX( "nx/nx_lava/nx_lava_fake_impacts_01" );
	level._effect[ "fake_tracer_hits_backside" ] = LoadFX( "nx/nx_lava/nx_lava_fake_impacts_backside_01" );
	level._effect[ "fake_tracer_hits_rocks" ]    = LoadFX( "nx/impacts/nx_lava_skimmer_rocket_hit" );
    level._effect[ "oxygen_tank_explosion" ]    = LoadFX( "nx/explosions/nx_lunar_oxygen_tank_explosion_01" );

	// welding arm sparks
	//level._effect[ "welding_arm_spark01" ]  = LoadFX( "nx/nx_lava/nx_lava_welding_sparks" );
	level._effect[ "welding_arm_spark01" ]       = LoadFX( "nx/nx_lava/nx_lava_welding_sparks_runner" );
		        

	//Lighting and rego amb ef
	level._effect[ "rego_cloud_low_loop" ]      = LoadFX( "nx/dust/nx_lunar_rego_slow_dust" );
	level._effect[ "falling_rego_light01" ]     = LoadFX( "nx/nx_lava/nx_falling_rego_light_warm_smllspread_01" );

    //footstep FX overide stuff  
	footstep_effects();
	//treadfx_override();

    // Derail explosion, TEMP FX
	level._effect[ "turret_explosion" ]			= loadfx( "explosions/tanker_explosion" );
	level._effect[ "train_3_part_explosion_01" ]      = loadfx( "nx/nx_lava/nx_lava_train_part_explosion_01" );
	level._effect[ "train_3_part_explosion_02" ]      = loadfx( "nx/nx_lava/nx_lava_train_part_explosion_02" );
	level._effect[ "train_3_part_explosion_large_01" ]      = loadfx( "nx/nx_lava/nx_lava_train_part_explosion_large_01" );
	level._effect[ "train_platform_fire" ]      = LoadFX( "nx/nx_lava/nx_lava_train_platform_fire" );
	level._effect[ "train_pod_damage_01" ]      = LoadFX( "nx/nx_lava/nx_lava_train_part_pod_damage_01" );
	level._effect[ "train_pod_damage_02" ]      = LoadFX( "nx/nx_lava/nx_lava_train_part_pod_damage_02" );
	level._effect[ "train_derail_smoke_01" ]      = LoadFX( "nx/nx_lava/nx_lava_train_derail_smoke_01" );
	level._effect[ "train_derail_drag_sparks" ]      = LoadFX( "nx/nx_lava/nx_lava_train_drag_sparks" );
	level._effect[ "train_derail_impact_dust" ]      = LoadFX( "nx/nx_lava/nx_lava_train_rego_impact_med" ); 

    // Derail explosion, TEMP FX
	level._effect[ "derail_explosion" ]			= loadfx( "nx/nx_lava/nx_lava_derail_explosion_med" );

    // bridge_to_train explosion, TEMP FX
    level._effect[ "bridge_to_train_explosion" ] = loadfx( "explosions/generator_explosion" );

	// Derail explosion, TEMP FX
	level._effect[ "derail_end_dust_cloud" ]	 = loadfx( "nx/dust/nx_rego_impact_huge" );
	level._effect[ "derail_end_explosion" ]		 = loadfx( "nx/lunar/nx_lunar_control_breach_explosion" );

	// auto kill_deathflag fx
	level._effect[ "flesh_hit" ]				  = loadfx( "impacts/flesh_hit" );

	// Elevator to garage steam, TEMP FX
	level._effect[ "nx_lunar_steam_jet_blow" ]	  = loadFX( "nx/lunar/nx_lunar_steam_jet_blow" );

	// Elevator to garage steam, TEMP FX
	level._effect[ "station_2_depressurize_fx" ]	= loadFX( "nx/lunar/nx_lunar_armory_depressurization" );

	//skimmer_running into rocksfx
	level._effect[ "skimmer_rocks_impact_fx" ]      = loadFX( "nx/nx_lava/nx_lava_skimmer_stunt_blownup" );
	//level._effect[ "skimmer_rocks_impact_fx" ]    = loadFX( "nx/nx_lava/nx_lava_skimmer_rocks_dustcloud" );
	
	// Added blood FX
	level._effect[ "nx_lunar_falcon_death_blood_hit" ]					= LoadFX( "nx/lunar/nx_lunar_falcon_death_blood_hit" );
	level._effect[ "nx_lunar_intro_blood_squirt" ]						= LoadFX( "nx/lunar/nx_lunar_intro_blood_squirt" );
	level._effect[ "nx_lunar_intro_glass_hit" ] 						= loadfx( "nx/lunar/nx_lunar_intro_glass_hit" );
}

//**************************************************
// VISION SET TRIGGERS
//**************************************************

vision_set_main()
{
	// Wait a frame for flags to set
	wait( 0.05 );
	
	switch ( level._start_point )
	{
		case "default":
		case "train_interior":
		case "train_interior_front":
		{
			// Train Interior
			flag_wait( "infinite_tunnel_start" );
			thread set_vision_and_fog("trainInterior", 2.0);
		}
		case "train_2":
		{
			// Train 2, Player Boards Turret
			flag_wait( "player_on_turret" );
			thread set_vision_and_fog("train2", 2.0);
		}
		case "train_2_skimmers":
		{
			// Train Leaves Tunnels, Goes Outside
			flag_wait( "skimmers_spawned" );
			thread set_vision_and_fog("skimmers", 2.0);
		}
		case "derail":
		{
			// Derail
			//flag_wait( "vignette_train_derailment" );
			flag_wait( "final_derail_tunnel_enter" );
			//flag_wait( "final_derail_tunnel_exit" );
			thread set_vision_and_fog("derail", 2.0);			
		}
	}
}

//**************************************************
// VISION SET LOGIC
//**************************************************
set_vision_and_fog(area, transition_time)
{
	switch ( area )
	{
		case "outpost":
			set_lunar_outpost_vision_and_fog(transition_time);
			break;

		case "garage":
			set_lunar_garage_vision_and_fog(transition_time);
			break;

		case "station1":
			set_lunar_station1_vision_and_fog(transition_time);
			break;

		case "trainInterior":
			set_lunar_trainInterior_vision_and_fog(transition_time);
			break;

		case "train2":
			set_lunar_train2_vision_and_fog(transition_time);
			break;

		case "skimmers":
			set_lunar_skimmers_vision_and_fog(transition_time);
			break;

		case "derail":
			set_lunar_derail_vision_and_fog(transition_time);
			break;
/*
		case "NEW":
			set_lunar_NEW_vision_and_fog(transition_time);
			break;
*/
		default:
			set_lunar_outpost_vision_and_fog(transition_time);
	}
}

//**************************************************
// VISION SET DEFINITIONS
//**************************************************

// VISION SET - outopst (exterior)
//--------------------------------------------------
set_lunar_outpost_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_lava_101_outpost_ext", transition_time);
	//setExpFog( 2888, 9568, 0.8235294, 0.7372549, 0.5764706, .25, transition_time, 0.148, 0, 1, 1, 1, 0.1411765, 0.1215686, 0.07450981 );
	//fx_set_skyfog( 0.0, 0.0, 0.85, transition_time );
}

// VISION SET - outopst; garage (first elevator)
//--------------------------------------------------
set_lunar_garage_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_lava_102_outpost_int", transition_time);
	//setExpFog( 2888, 9568, 0.8235294, 0.7372549, 0.5764706, .25, transition_time, 0.148, 0, 1, 1, 1, 0.1411765, 0.1215686, 0.07450981 );
	//fx_set_skyfog( 0.0, 0.0, 0.85, transition_time );
}

// VISION SET - Station 1 (second elevator)
//--------------------------------------------------
set_lunar_station1_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_lava_201_station1_int", transition_time);
	//setExpFog( 2888, 9568, 0.8235294, 0.7372549, 0.5764706, .25, transition_time, 0.148, 0, 1, 1, 1, 0.1411765, 0.1215686, 0.07450981 );
	//fx_set_skyfog( 0.0, 0.0, 0.85, transition_time );
}

// VISION SET - Train Interior
//--------------------------------------------------
set_lunar_trainInterior_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_lava_train_interior", transition_time);
//Note: This fog setting darkens the ends of the tunnels to hide the loop
	setExpFog( 1561.96, 897.287, 0.160416, 0.136243, 0.0780553, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1);
	//fx_set_skyfog( 0.0, 0.0, 0.85, transition_time );
}

// VISION SET - Train 2
//--------------------------------------------------
set_lunar_train2_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_lava_train_2", transition_time);
	setExpFog( 3000, 10000, 0.5686275, 0.7843137, 0.9411765, 0.02, transition_time, 0.4499667, 0, 0.7882353, 0.7843137, 0.7450981, 0.6588235, 0.7607843, 0.8, 1, 1, 0.7529412, ( 0, 0, 0 ), 0, 1, 0 );	//setExpFog( 2888, 9568, 0.8235294, 0.7372549, 0.5764706, .25, transition_time, 0.148, 0, 1, 1, 1, 0.1411765, 0.1215686, 0.07450981 );
	//fx_set_skyfog( 0.0, 0.0, 0.85, transition_time );
}

// VISION SET - Skimmers (CARLO)
//--------------------------------------------------
set_lunar_skimmers_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_lava_skimmers", transition_time);
	//setExpFog( 200, 15000, 0.500, 0.500, 0.500, 0.080, transition_time, 0, 0, 0, 0, 0, 1, 1, 1 );	
	//fx_set_skyfog( 0.0, 0.0, 0.85, transition_time );
}

// VISION SET - Derail (CARLO)
//--------------------------------------------------
set_lunar_derail_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_lava_derail", transition_time);
	//setExpFog( 200, 15000, 0.500, 0.500, 0.500, 0.080, transition_time, 0, 0, 0, 0, 0, 1, 1, 1 );	
	//fx_set_skyfog( 0.0, 0.0, 0.85, transition_time );
}

/*
// VISION SET - BLANK
//--------------------------------------------------
set_lunar_BLANK_vision_and_fog(transition_time)
{
	VisionSetNaked("nx_lava_train_2", transition_time);
	//setExpFog( 200, 15000, 0.500, 0.500, 0.500, 0.080, transition_time, 0, 0, 0, 0, 0, 1, 1, 1 );		
	//fx_set_skyfog( 0.0, 0.0, 0.85, transition_time );
}
*/

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

footstep_effects()
{

	//Regular footstep fx
	animscripts\utility::setFootstepEffect( "dirt",		loadfx ( "nx/impacts/nx_lunar_footstep_rego_dust_01_med" ) );
	animscripts\utility::setFootstepEffect( "concrete",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "asphalt",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "rock",		loadfx ( "impacts/footstep_dust" ) );
	
	//Small footstep fx
	animscripts\utility::setFootstepEffectSmall( "dirt",		loadfx ( "nx/impacts/nx_lunar_footstep_rego_dust_01_med" ) );
	animscripts\utility::setFootstepEffectSmall( "concrete",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffectSmall( "asphalt",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffectSmall( "rock",		loadfx ( "impacts/footstep_dust" ) );
}


train_1_headlights_on()
{
	train_1_car_1 = GetEnt( "train_1_car_1", "targetname" );
	playfxontag  ( level._effect[ "train_headlight" ], train_1_car_1, "tag_front_left_light01" );
	playfxontag  ( level._effect[ "train_headlight" ], train_1_car_1, "tag_front_right_light01" );  
}

train_2_int_lights_on()
{
	train_2_car_1_fx = GetEnt( "train_2_car_1_geo", "script_noteworthy" );
	playfxontag  ( level._effect[ "train_int_light_01" ], train_2_car_1_fx, "TAG_FRONT_INT_LIGHT_01" ); 
}

cargo_train_rego_fx()
{
	PlayFXOnTag( level._effect[ "train_rego_falling_dust01" ], level.e_train[0].vehicle, "TAG_ORIGIN" );
	PlayFXOnTag( level._effect[ "train_rego_falling_dust01" ], level.e_train[1].vehicle, "TAG_ORIGIN" );
	wait (0.1);
	PlayFXOnTag( level._effect[ "train_rego_falling_dust01" ], level.e_train[2].vehicle, "TAG_ORIGIN" );
	PlayFXOnTag( level._effect[ "train_rego_falling_dust01" ], level.e_train[3].vehicle, "TAG_ORIGIN" );
	wait (0.1);
	PlayFXOnTag( level._effect[ "train_rego_falling_dust01" ], level.e_train[4].vehicle, "TAG_ORIGIN" );
	PlayFXOnTag( level._effect[ "train_rego_falling_dust01" ], level.e_train[5].vehicle, "TAG_ORIGIN" );
	wait (0.1);
	PlayFXOnTag( level._effect[ "train_rego_train_trail01" ], level.e_train[5].vehicle, "TAG_ORIGIN" );  
}

release_the_dustmotes_fx_1()
{
	wait (1.75);
	exploder ( "infinite_dust_motes" );
}

release_the_dustmotes_fx_2()
{
	wait (0.1);
	exploder ( "infinite_dust_motes" );
}


 
start_fake_railgun_fx()
{
    level endon( "vignette_trainseperate_player_jump" );

    while ( 1 )
    {
		exploder ( "fakehits_4_1" );
		wait (0.6);
		exploder ( "fakehits_4_2" );
		wait (0.6);
		exploder ( "fakehits_4_3" );
		wait (0.6);
		exploder ( "fakehits_4_4" );
		wait (0.6);
    }
}

train_sep_jump_blast_fx()
{
	wait ( 0.0 );
	exploder ( "train_sep_jump_blast" );
}

train_sep_big_blast_fx()
{
	exploder ( "train_sep_jump_blast" );
	wait ( 1.5 );
	exploder ( "train_sep_big_blast" );
}




////TRain Headlights
set_train_headlight_fx_off()
{
	//IPrintln( "die particles, die." );
	stopfxontag  ( level._effect[ "train_headlight" ], self, "tag_origin", true  );
}

set_train_headlight_fx_on()
{
	stopfxontag  ( level._effect[ "train_headlight" ], self, "tag_origin", true );
	wait (0.1);
	playfxontag  ( level._effect[ "train_headlight" ], self, "tag_origin" );
}

fx_train3_car1_derail_start(train3_car1_platform)
{
	//IPrintln( "DERAIL DERAIL DERAIL DERAIL" );
	stopfxontag  ( level._effect[ "train_headlight" ], level.train_3[0].vehicle, "tag_origin", true );
	PlayFXOnTag( getfx( "train_pod_damage_01" ), train3_car1_platform, "TAG_FX_LEFT_REAR_POD_04" );
	playfxontag( getfx( "train_headlight" ), train3_car1_platform, "tag_origin" );//"TAG_FX_LIGHT_FRONT_RIGHT" );
	wait(0.1);
	PlayFXOnTag( getfx( "train_derail_drag_sparks" ), train3_car1_platform, "TAG_ORIGIN" );
}

fx_train3_car1_derail_pod_breakoff(train3_car1_platform)
{
	stopFXOnTag( getfx( "train_derail_drag_sparks" ), train3_car1_platform, "TAG_ORIGIN" );
	PlayFXOnTag( getfx( "train_pod_damage_02" ), train3_car1_platform, "TAG_FX_LEFT_REAR_POD_04" );
	wait(0.1);
	PlayFXOnTag( getfx( "train_derail_smoke_01" ), train3_car1_platform, "TAG_FX_LEFT_FRONT_POD_05" );
	//PlayFXOnTag( getfx( "train_derail_smoke_01" ), train3_car1_platform, "TAG_FX_CAR1_PLATFORM_04" );
	wait(0.1);
	//PlayFXOnTag( getfx( "train_derail_smoke_01" ), train3_car1_platform, "TAG_ORIGIN" );
	PlayFXOnTag( getfx( "train_derail_smoke_01" ), train3_car1_platform, "TAG_FX_CAR1_PLATFORM_01" );

}

fx_train3_car1_derail_lr_touchdown(train3_car1_platform)
{
	playFXOnTag( getfx( "train_derail_impact_dust" ), train3_car1_platform, "TAG_FX_CAR1_PLATFORM_LEFT_REAR" );
}
