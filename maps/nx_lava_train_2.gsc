//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module: Lava Train 2													**
//                                                                          **
//    Created: 07/25/10 - Travis Chen (trchen x 4143)						**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_anim;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
	maps\_ec_lunar_turret::turret_vehicle_anims();
}

TRAIN_2_SPEED_TURRET = 120;
TRAIN_2_SPEED_TURRET_TUNNEL = 120;
TRAIN_2_SPEED_TURRET_SLOWER = 125;
TRAIN_2_SPEED_SKIMMER = 115;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
	PreCacheModel( "mil_frame_charge_obj" );
	PreCacheTurret( "nx_chinese_lgv_turret_skimmer" );
}

section_flag_inits()
{
	flag_init( "vignette_turret_battle_tanker_explosion" );
	flag_init( "vignette_turret_battle_crate_explosion" );
	flag_init( "vignette_turret_battle_rocket_engine_explosion" );
	flag_init( "vignette_turret_battle_rocket_engine_tanks_explosion" );
	flag_init( "vignette_turret_battle_tank_near_hit" );
	flag_init( "vignette_turret_battle_train_derail" );
	flag_init( "vignette_turret_battle_train_derail_done" );
	flag_init( "vignette_turret_battle_train_derail_02" );
	flag_init( "vignette_turret_battle_train_derail_02_done" );
	
	flag_init( "train_3_derail" );
	flag_init( "skimmer_start_vo" );
	flag_init( "start_skimmer_fight" );
	flag_init( "skimmers_spawned" );
	flag_init( "skimmers_wave_1_spawned" );
	flag_init( "skimmers_wave_2_spawned" );
	
	flag_init( "train_3_car_4_a" );
	flag_init( "train_3_car_4_b" );
	flag_init( "train_3_car_3_a" );
	flag_init( "train_3_car_3_b" );
	flag_init( "train_3_car_2" );
	flag_init( "train_3_car_1" );
	flag_init( "train_3_move_to_car_1" );
	flag_init( "train_3_aim_low" );
	
	flag_init( "train_2_player_left_tunnel_enemy_movement_a" );
	flag_init( "train_2_player_left_tunnel_enemy_movement_b" );
		
	flag_init( "car_4_front_explosion" );
	flag_init( "car_4_middle_explosion" );
	flag_init( "car_4_rear_explosion" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_sounds()
{

	flag_wait( "player_on_turret" );
	wait 10.5;
	audio_train_groan_01 = spawn( "sound_emitter", (50777, 68761, -4071) );
	audio_train_groan_01 playsound ("nx_lava_enemy_train_groan_01");
	wait 5.5;
	level._player playsound("nx_lava_enemy_train_groan_02");
}

train_2_vo()
{
	flag_wait( "player_on_turret" );
	radio_dialogue( "lava_bak_tr2turr_lightemup" );
	radio_dialogue( "lava_bak_tr2turr_takeoutguncrews" );
	
	flag_wait( "train_3_car_4_a" );
	radio_dialogue( "lava_bak_tr2turr_keepfiring");
	flag_wait( "train_3_car_4_b" );
	radio_dialogue( "lava_bak_tr2turr_hittanks" );
	
	flag_wait( "train_2_player_left_tunnel" );
	radio_dialogue( "lava_bak_tr2turr_trainat3oclock" );
	
	flag_wait( "train_3_car_3_a" );
	radio_dialogue( "lava_bak_tr2turr_teartrainapart" );
	flag_wait( "train_3_car_3_b" );
	radio_dialogue( "lava_bak_tr2turr_targeto2tanks" );
	
	flag_wait( "train_3_car_2" );
	wait( 3.0 );
	radio_dialogue( "lava_bak_tr2turr_tangosonplatform" );
	
	flag_wait( "train_3_car_1" );
	wait( 0.5 );
	flag_set( "train_3_aim_low" );
	radio_dialogue( "lava_bak_tr2turr_aimlow" );
	radio_dialogue( "lava_bak_tr2turr_knockoffrails" );
	
	flag_wait( "train_3_derail" );
	wait( 3.0 );
	radio_dialogue( "lava_bak_tr2turr_ceasefire" );
	
	wait( 2 );
	flag_set( "skimmer_start_vo" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_objectives( objective_num )
{
//	flag_wait( "vignette_turret_battle_tanker_explosion" );
//
//	// Add objective
//	waypoint = getEnt( "objective_coupling", "targetname" );
//	Objective_Add( objective_num, "current", &"NX_LAVA_OBJECTIVE_TURRET_FEET" );
//	Objective_OnEntity( objective_num, waypoint );
//
//	flag_wait( "vignette_turret_battle_train_derail_02" );
//	
//	// Clear Objective
//	objective_complete( objective_num );
//	objective_num++;
	
	flag_wait( "train_3_aim_low" );

	// Add objective
	waypoint = getEnt( "objective_turret_feet", "targetname" );
	Objective_Add( objective_num, "current", &"NX_LAVA_OBJECTIVE_TURRET_FEET" );
	Objective_OnEntity( objective_num, waypoint );

	flag_wait( "train_3_derail" );

	// Clear Objective
	objective_complete( objective_num );
	objective_num++;

	return objective_num;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_2_start()
{
	// Setup Train 2 Turret vehicle and Init player start location
	maps\nx_lava_util::setup_train_vehicles( level.train_turret, false );
	maps\nx_lava_util::show_hide_train( level.train_turret, "show" );

	// Used for player_gets_on_turret
	level.train_2_jump_to = true;

	level thread maps\nx_lava_util::start_fake_train_movement( false );
	
	//adding in headlights for train 2 :apm
	 level.train_turret[4].vehicle maps\nx_lava_fx::set_train_headlight_fx_on();

	flag_set( "player_on_turret_anim_complete" );
}

train_2()
{
	level thread autosave_now();
		
	// VO
	level thread train_2_vo();

	level thread train_sounds();

	// Turret
	level thread player_gets_on_turret();
	level thread train_2_ally_thread();

	// Move train
	level thread train_2_setup();
	level thread train_2_move();

	// Wait for train 3 start
	level thread train_3_setup();
	level thread train_3_cleanup();
	level thread train_3_move();
	level thread train_3_states();

}

player_gets_on_turret( angle_adjust )
{
	// Give the player the turret.
	turret = GetEnt( "turret_player", "targetname" );

	// Force on turret if jump to
	if( ( IsDefined( level.train_2_jump_to ) && level.train_2_jump_to == true ) )
	{
		turret MakeUsable();
		turret SetMode( "manual" );
		turret UseBy( level._player );
		turret MakeUnusable();
		angle_adjust = 0;
	}

	// Lock the player to the turret.
	flag_wait( "player_on_turret_anim_complete" );
	level.player_turret = turret;
	if( IsDefined( angle_adjust )) 
	{
		level._player SetPlayerAngles( ( 0, turret.angles[ 1 ] - angle_adjust, 0 ) );
	}
	level._player PlayerLinkToDelta( turret, undefined, 1.0, 360, 360, 45, 18, true );//tagCC<NOTE>: Restrict player view arcs so they cant shoot themselves.


	// Enable turret angles
	level._player PlayerLinkedTurretAnglesEnable();
	level._player DisableTurretDismount();

	// Turret flag
	flag_set( "player_on_turret" );

	// Show special hand model for this turret.
	turret thread maps\_ec_lunar_turret::animate_player_hands();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_2_ally_thread()
{
	platform_ally_spawners = GetEntArray( "train_2_ally_2", "targetname" );
	array_thread( platform_ally_spawners, ::add_spawn_function, ::train_2_tillman_spawn_func );
	array_thread( platform_ally_spawners, ::spawn_ai );
}

train_2_tillman_spawn_func()							
{
	self endon( "death" );

	self enable_cqbwalk();
	self maps\nx_lava_util::ally_protect();

	self thread magic_bullet_shield();
	self.baseaccuracy = 0.25;

	// Give tillman the turret.
	turret = level.train_turret[4].vehicle.mgturret[0];
	turret.closeEnoughAimDegrees = 45;
	turret SetAISpread( 20 );
	level.train_turret[4].vehicle thread maps\_vehicle_aianim::guy_man_turret( self, 0, undefined ); //assuming only position 0.

	flag_wait( "skimmers_spawned" );

	thread audio_ambience_change();
	
	// setup turret & tilman
	turret SetBottomArc( 10 );
	self.baseaccuracy = 0.0;
	
	
	// inside the tunnel before final derail
	flag_wait( "final_derail_tunnel_enter" );
	turret SetLeftArc( 25 );
	turret SetRightArc( 25 );
}

audio_ambience_change()
{
	wait 3.2;
	level._player playsound("elm_lava_cave_whoosh");
	level.amb_train_ext setsoundvolume( "amb_lava_train_ext", -5, 1 );
	level.amb_train_int setsoundvolume( "amb_lava_train_int", -100, 1.5 );

}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_2_setup()
{
}

train_2_move()
{
	// Move front vehicle
	if( ( IsDefined( level.train_2_jump_to ) && level.train_2_jump_to == true ) )
	{
		level.train_turret maps\nx_lava_util::train_switch_target( "train_2_front_t2t");
		thread maps\nx_lava_util::move_train( level.train_turret, TRAIN_2_SPEED_TURRET, 10000, 10 );
		level.player_train_speed = TRAIN_2_SPEED_TURRET;
	}
	else
	{
		thread maps\nx_lava_util::set_train_speed( level.train_turret, TRAIN_2_SPEED_TURRET, 10000, 10 );
		level.player_train_speed = TRAIN_2_SPEED_TURRET;
	}

	flag_wait( "train_2_player_in_tunnel" );
	thread maps\nx_lava_util::set_train_speed( level.train_turret, TRAIN_2_SPEED_TURRET_TUNNEL, 100, 100 );
	level.player_train_speed = TRAIN_2_SPEED_TURRET_TUNNEL;
	
	// Wait for decel
	trigger_wait( "train_2_decel_1", "targetname" );
	thread maps\nx_lava_util::set_train_speed( level.train_turret, TRAIN_2_SPEED_TURRET_SLOWER, 100, 100 );
	level.player_train_speed = TRAIN_2_SPEED_TURRET_SLOWER;

	// Wait for decel
	trigger_wait( "train_2_decel_2", "targetname" );
	thread maps\nx_lava_util::set_train_speed( level.train_turret, TRAIN_2_SPEED_SKIMMER, 100, 100 );
	level.player_train_speed = TRAIN_2_SPEED_SKIMMER;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_3_setup()
{
	train_name_array = [ 	[ "train_3_car_1", "train_3_car_1_vehicle" ], 
							[ "train_3_car_2", "train_3_car_2_vehicle" ], 
							[ "train_3_car_3", "train_3_car_3_vehicle" ],
							[ "train_3_car_4", "train_3_car_4_vehicle" ],
							[ "train_3_car_5", "train_3_car_5_vehicle" ] ];

	if( !IsDefined( level.train_3 ) )
	{
		level.train_3 = maps\nx_lava_util::setup_train( train_name_array, false );
	
		// Thread vignettes
		level thread train_3_vignettes();
	}
	
	if( ( IsDefined( level.train_2_jump_to ) && level.train_2_jump_to ) ||
    	( IsDefined( level.train_interior_front_jump_to ) && level.train_interior_front_jump_to ) )
	{
		// Set train start point on train_3 cars
		foreach( i, train in level.train_3 )
		{
			train_3_vehicle = level.train_3[i].vehicle;
			start_point_name = "train_2_car_" + ( i + 1 ) + "_debug_start";
			train_3_vehicle.target = start_point_name;
		}
	}

	wait( 0.05 );
		
	//SFX for enemy train
	if ( !flag( "train3_sfx_on" ) )
	{
		level.train_sfxarray = GetEntArray( "train_sfx_node", "targetname");
		//level.train_sfxarray2 = GetEntArray( "train_sfx_node", "targetname");
	level.train_3[0].vehicle thread maps\_vehicle::play_train_line_sfx( level.train_sfxarray, "nx_lava_enemy_train" );	
	level.train_3[0].vehicle thread maps\_vehicle::play_train_line_sfx( level.train_sfxarray, "nx_lava_enemy_train_squeaks" );		
		flag_set( "train3_sfx_on" );
	}
			
	// Setup the locked combat for the enemies
	train_3_setup_locked_combat_nodes();
	level thread maps\nx_lava_util::platform_enemy_setup_locked_combat( level.train_3[0], "train_3_car_1_enemy" );
	level thread maps\nx_lava_util::platform_enemy_setup_locked_combat( level.train_3[1], "train_3_car_2_enemy" );
	level thread maps\nx_lava_util::platform_enemy_setup_locked_combat( level.train_3[1], "train_3_car_2_enemy_move_on_flag_1", "train_2_stop", maps\nx_lava_util::platform_enemy_move_on_flag_protect, "train_3_car_2" );
	level thread maps\nx_lava_util::platform_enemy_setup_locked_combat( level.train_3[2], "train_3_car_3_enemy" );
	level thread maps\nx_lava_util::platform_enemy_setup_locked_combat( level.train_3[2], "train_3_car_3_enemy_move_on_flag_1", "train_2_stop", maps\nx_lava_util::platform_enemy_move_on_flag_protect, "train_2_player_left_tunnel_enemy_movement_a" );
	level thread maps\nx_lava_util::platform_enemy_setup_locked_combat( level.train_3[2], "train_3_car_3_enemy_move_on_flag_2", "train_2_stop", maps\nx_lava_util::platform_enemy_move_on_flag_protect, "train_2_player_left_tunnel_enemy_movement_b" );
	level thread maps\nx_lava_util::platform_enemy_setup_locked_combat( level.train_3[2], "train_3_car_3_enemy_move_on_flag_3", "train_2_stop", maps\nx_lava_util::platform_enemy_move_on_flag_protect, "train_2_player_left_tunnel_enemy_movement_a" );
	level thread train_3_car_3_enemy_movement_thread();
	
	level thread maps\nx_lava_util::platform_enemy_setup_locked_combat( level.train_3[3], "train_3_car_4_enemy" );
	level thread maps\nx_lava_util::platform_enemy_setup_locked_combat( level.train_3[3], "train_3_car_4_enemy_move_on_flag_1", "train_2_stop", maps\nx_lava_util::platform_enemy_move_on_flag_protect_short, "train_3_car_4_a" );
	level thread maps\nx_lava_util::platform_enemy_setup_locked_combat( level.train_3[3], "train_3_car_4_enemy_move_on_flag_2", "train_2_stop", maps\nx_lava_util::platform_enemy_move_on_flag_protect_short, "train_3_car_4_a" );
	level thread maps\nx_lava_util::platform_enemy_setup_locked_combat( level.train_3[4], "train_3_car_5_enemy" );

	//adding in some fx for the headlight train 3: apm	
	level.train_3[0].vehicle maps\nx_lava_fx::set_train_headlight_fx_on();
	//maps\nx_lava_fx::set_train3_accentlight_fx_on();
}

train_3_car_3_enemy_movement_thread()
{
	flag_wait( "train_2_player_left_tunnel" );
	flag_set( "train_2_player_left_tunnel_enemy_movement_a" );
	wait( 2.0 );
	flag_set( "train_2_player_left_tunnel_enemy_movement_b" );
}

train_3_cleanup()
{
	flag_wait( "vignette_turret_battle_train_derail_done" );

	//_cleanup the headlight fx train 3: apm
	level.train_3[0].vehicle maps\nx_lava_fx::set_train_headlight_fx_off();
	
	// make sure train 3 enemies are dead
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_3_rocket_enemy" );
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_3_tanks_enemy" );
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_4_enemy" );
	//maps\nx_lava_util::delete_entire_ai_group( "train_3_car_5_enemy" );
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_1_enemy" );
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_2_enemy" );
	ClearAllCorpses();
		
	maps\nx_lava_util::delete_train( level.train_3 );
}

train_3_move()
{ 
	if( IsDefined( level.train_2_jump_to ) && level.train_2_jump_to )
	{
		maps\nx_lava_util::move_train( level.train_3, TRAIN_2_SPEED_TURRET, 10000, 10 );
	}
	else
	{
		maps\nx_lava_util::set_train_speed( level.train_3, TRAIN_2_SPEED_TURRET + 10, 10000, 10000 );
	}
	
	flag_wait( "train_2_player_approach_tunnel" );
	
	level.train_3[0].vehicle maps\nx_lava_util::stop_follow_player();
	
	maps\nx_lava_util::set_train_speed( level.train_3, TRAIN_2_SPEED_TURRET + 30, 100, 10 );
	
	flag_wait( "train_2_player_in_tunnel" );

	maps\nx_lava_util::set_train_speed( level.train_3, TRAIN_2_SPEED_TURRET, 1000, 1000 );
}

train_3_states()
{
	// Car 5, Explosion
	{
		// tagTC<note> commented out some logic here, add back once we have a vignette
		train_3_follow_player( 4, "follow_point_1" );
		level thread car_5_thread();
		waittill_2_of_3_flags( "car_4_front_explosion", "car_4_middle_explosion", "car_4_rear_explosion" );
		radio_dialogue( "lava_bak_tr2turr_goodkill" );
	}
	
	// Car 4, Explosion
	{
		train_3_follow_player( 3, "follow_point_1"  );
		flag_set( "train_3_car_4_a" );
		level thread car_4_thread();
		flag_wait( "vignette_turret_battle_tanker_explosion" );
	}
	
	// Car 3, Explosion
	{	
		flag_wait( "train_2_player_in_tunnel" );
		train_3_follow_player( 2, "follow_point_1" );
		flag_set( "train_3_car_3_a" );
		level thread car_3_thread();
		flag_wait_all( "vignette_turret_battle_rocket_engine_explosion", "vignette_turret_battle_rocket_engine_tanks_explosion" );
	}
	
	// Car 2, Derail
/*	{
		//train_3_follow_player( 1, "derail_follow_point" );
		wait( 1.0 );
		turret_battle_train_derail_02();
		flag_wait( "vignette_turret_battle_train_derail_02" );
		level thread autosave_now();
	}
*/
	
	// Car 2
	{
		train_3_follow_player( 1 );
		flag_set( "train_3_car_2" );
		level thread car_2_thread();
		flag_wait( "train_3_move_to_car_1" );
	}
	
	// Car 1, Derail
	{
		train_3_follow_player( 0 );
		flag_set( "train_3_car_1" );
		// level thread turret_battle_train_derail();
		flag_wait( "train_3_derail" );
	}

	// REFACTOR
	flag_wait( "train_3_derail" );
	foreach( train in level.train_3 )
	{
		train maps\_nx_moving_platform::platform_hide();
		train.vehicle hide();
	}

	flag_wait( "vignette_turret_battle_train_derail_done" );
	level thread autosave_now();
}

waittill_2_of_3_flags( flag_1, flag_2, flag_3 )
{
	while( 1 )
	{
		num_flags = 0;
		if( flag( flag_1 ) )
		{
			num_flags++;
		}
		if( flag( flag_2 ) )
		{
			num_flags++;
		}
		if( flag( flag_3 ) )
		{
			num_flags++;
		}
		
		if( num_flags >= 2 )
		{
			break;
		}
		
		wait( 0.05 );
	}
}

car_5_thread()
{
	level endon( "train_3_car_4_a" );
	
	waittill_either( "car_4_rear_explosion", "car_4_middle_explosion" );
	train_3_follow_player( 4, "follow_point_2" );
}

car_4_thread()
{
	level endon( "vignette_turret_battle_tanker_explosion" );
	
	flag_wait( "vignette_turret_battle_crate_explosion" );
	train_3_follow_player( 3, "follow_point_2" );
	flag_set( "train_3_car_4_b" );
}

car_3_thread()
{
	level endon( "vignette_turret_battle_rocket_engine_tanks_explosion" );
	
	flag_wait( "vignette_turret_battle_rocket_engine_explosion" );
	train_3_follow_player( 2, "follow_point_2" );
	flag_set( "train_3_car_3_b" );
}

car_2_thread()
{
	level thread car_2_thread_cleared();
	level thread car_2_thread_straightaway();
}

car_2_thread_cleared()
{
	waittill_aigroupcleared( "train_3_car_2_enemy" );
	flag_set( "train_3_move_to_car_1" );
}

car_2_thread_straightaway()
{
	flag_wait( "train_2_straightaway" );
	flag_set( "train_3_move_to_car_1" );
}

set_flag_if_flag( set_flag, if_flag )
{
	flag_wait( if_flag );
	flag_set( set_flag );
}

train_3_follow_player( car, follow_point_name )
{
	if( !IsDefined( follow_point_name ) )
	{
		follow_point_name = "center_link_point";
	}
	
	assert( IsDefined( level.player_train_speed ) );
	level.train_3[0].vehicle maps\nx_lava_util::stop_follow_player();
	follow_point = level.train_3[car] maps\_nx_moving_platform::get_platform_ent( follow_point_name );
	level.train_3[0].vehicle thread maps\nx_lava_util::vehicle_array_follow_player( level.train_3, follow_point, 0.1, 0.2, 0.2, 20, level.player_train_speed );	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_3_vignettes()
{
	level thread car_4_front_explosion();
	level thread car_4_middle_explosion();
	level thread car_4_rear_explosion();
	
	level thread turret_battle_tanker_explosion();
	level thread turret_battle_crate_explosion();
	level thread turret_battle_rocket_engine_explosion();
	level thread turret_battle_rocket_engine_tanks_explosion();
	level thread turret_battle_train3_car1_derail();
}

car_4_front_explosion()
{
	level thread maps\nx_lava_anim::train3_car4_front( "car_4_front_explosion" );
	
	level thread set_flag_if_flag( "car_4_front_explosion", "train_2_player_in_tunnel" );
	vignette_trigger_hit( "trigger_car_4_front", "crate_explosion", 2, "car_4_front_explosion" );
}

car_4_middle_explosion()
{
	level thread maps\nx_lava_anim::train3_car4_mid( "car_4_middle_explosion" );
	
	level thread set_flag_if_flag( "car_4_middle_explosion", "train_2_player_in_tunnel" );
	vignette_trigger_hit( "trigger_car_4_middle", "crate_explosion", 2, "car_4_middle_explosion" );
	
	// Delete the turret
	turret = level.train_3[4].vehicle.mgturret[0];
	turret Hide();
}

car_4_rear_explosion()
{
	level thread maps\nx_lava_anim::train3_car4_rear( "car_4_rear_explosion" );
	
	level thread set_flag_if_flag( "car_4_rear_explosion", "train_2_player_in_tunnel" );
	vignette_trigger_hit( "trigger_car_4_rear", "crate_explosion", 2, "car_4_rear_explosion" );
}

turret_battle_crate_explosion()
{
	level thread maps\nx_lava_anim::turret_battle_crate_explosion( "vignette_turret_battle_crate_explosion" );
	
	// wait till Train 3 section
	flag_wait( "train_3_start" );
	level thread set_flag_if_flag( "vignette_turret_battle_crate_explosion", "train_2_player_in_tunnel" );
	vignette_trigger_hit( "trigger_turret_battle_crate_explosion", "crate_explosion", 2, "vignette_turret_battle_crate_explosion" );
}

turret_battle_tanker_explosion()
{
	level thread maps\nx_lava_anim::turret_battle_tanker_explosion( "vignette_turret_battle_tanker_explosion" );
	
	// wait till Train 3 section
	flag_wait( "train_3_start" );
	level thread set_flag_if_flag( "vignette_turret_battle_tanker_explosion", "train_2_player_in_tunnel" );
	vignette_trigger_hit( "trigger_turret_battle_tanker_explosion", "turret_explosion", 2, "vignette_turret_battle_tanker_explosion" );
	
	// Force crate explosion if player is out of order
	flag_set( "vignette_turret_battle_crate_explosion" );
}

turret_battle_tank_near_hit()
{
	level thread maps\nx_lava_anim::turret_battle_tank_near_hit( "vignette_turret_battle_tank_near_hit" );
	
	// wait till Train 3 section
	flag_wait( "train_3_start" );
	level thread set_flag_if_flag( "vignette_turret_battle_tank_near_hit", "train_2_player_in_tunnel" );
	vignette_trigger_hit( "trigger_turret_battle_tank_near_hit", "turret_explosion", 2, "vignette_turret_battle_tank_near_hit" );
}

turret_battle_rocket_engine_explosion()
{
	level thread maps\nx_lava_anim::turret_battle_rocket_engine_explosion( "vignette_turret_battle_rocket_engine_explosion" );
	
	// wait till around the bend
	flag_wait( "train_2_player_in_tunnel" );
	level thread set_flag_if_flag( "vignette_turret_battle_rocket_engine_explosion", "train_2_rise" );
	vignette_trigger_hit( "trigger_turret_battle_rocket_engine_explosion", "turret_explosion", 4, "vignette_turret_battle_rocket_engine_explosion" );

	// kill_entire_ai_group( "train_3_car_3_rocket_enemy" );
}

turret_battle_rocket_engine_tanks_explosion()
{
	level thread maps\nx_lava_anim::turret_battle_rocket_engine_tanks_explosion( "vignette_turret_battle_rocket_engine_tanks_explosion" );
	
	// wait till around the bend
	flag_wait( "train_2_player_in_tunnel" );
	level thread set_flag_if_flag( "vignette_turret_battle_rocket_engine_tanks_explosion", "train_2_rise" );
	vignette_trigger_hit( "trigger_turret_battle_rocket_engine_tanks_explosion", "turret_explosion", 4, "vignette_turret_battle_rocket_engine_tanks_explosion" );

	// Force rocket rxplosion if player is out of order
	flag_set( "vignette_turret_battle_rocket_engine_explosion" );
	
	kill_entire_ai_group( "train_3_car_3_tanks_enemy" );
}

turret_battle_train3_car1_derail()
{
	level thread maps\nx_lava_anim::train3_car1_derail( "vignette_turret_battle_train_derail", "vignette_turret_battle_train_derail_done" );

	// wait till at final straight away
	flag_wait( "train_2_straightaway" );
	level thread set_flag_if_flag( "vignette_turret_battle_train_derail", "train_3_force_derail" );
	vignette_trigger_hit( "trigger_turret_battle_train_derail", "turret_explosion", 2, "vignette_turret_battle_train_derail" );
	
	
	level._player playsound("scn_lava_train_slomo");
	// attach car 1 enemies to script car
	car1_group = get_ai_group_ai( "train_3_car_1_enemy" );
	foreach( guy in car1_group )
	{
		guy Unlink();
		guy linkTo( level.train_3[0].vignette_script_model );
	}
	
	ClearAllCorpses();
	
	// throw off car 1 enemies
	// wait( 1 );
	maps\nx_lava_util::blowup_ai_group( "train_3_car_1_enemy" );
	
	// clean up the exploded train car
	wait( 3 );
	
	// Clear fx. 
	//IPrintln( "die particles, die." );
	level.train_3[0].vehicle maps\nx_lava_fx::set_train_headlight_fx_off();
	level.train_3[0].vehicle maps\_nx_moving_platform_vh::stop_train_maglex_fx();
	level.train_3[1].vehicle maps\_nx_moving_platform_vh::stop_train_maglex_fx();
	
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_3_rocket_enemy" );
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_3_tanks_enemy" );
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_4_enemy" );
	//maps\nx_lava_util::delete_entire_ai_group( "train_3_car_5_enemy" );
	// maps\nx_lava_util::delete_entire_ai_group( "train_3_car_1_enemy" );
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_2_enemy" );
	ClearAllCorpses();

	level thread turret_battle_train_derail_slowmo();
	PlayFX( level._effect[ "derail_explosion" ], level.train_3[1].origin );
	flag_set( "train_3_derail" );
	
	level.player_turret thread maps\_ec_lunar_turret::turret_player_viewhands_react( "train_derail_look_at_point" );
}

turret_battle_train_derail_02()
{
		//trying to turn off the hedlight fx here, might be a tad early 
	level.train_3[0].vehicle maps\nx_lava_fx::set_train_headlight_fx_off();

	level thread maps\nx_lava_anim::turret_battle_train_derail_02( "vignette_turret_battle_train_derail_02", "vignette_turret_battle_train_derail_02_done" );
	level thread set_flag_if_flag( "vignette_turret_battle_train_derail_02", "train_2_rise" );
	//vignette_trigger_hit( "trigger_turret_battle_train_derail_02", "turret_explosion", 1, "vignette_turret_battle_train_derail_02" );
	flag_set( "vignette_turret_battle_train_derail_02" );
	
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_3_rocket_enemy" );
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_3_tanks_enemy" );
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_4_enemy" );
	//maps\nx_lava_util::delete_entire_ai_group( "train_3_car_5_enemy" );
	ClearAllCorpses();

	level.train_3[2] maps\_nx_moving_platform::platform_hide();
	level.train_3[3] maps\_nx_moving_platform::platform_hide(); 
	level.train_3[4] maps\_nx_moving_platform::platform_hide();	

	// Clear fx. 
	level.train_3[2].vehicle maps\_nx_moving_platform_vh::stop_train_maglex_fx();
	level.train_3[3].vehicle maps\_nx_moving_platform_vh::stop_train_maglex_fx();
	level.train_3[4].vehicle maps\_nx_moving_platform_vh::stop_train_maglex_fx();

	level.train_3[2].vehicle hide();
	level.train_3[3].vehicle hide(); 
	level.train_3[4].vehicle hide();	
}

turret_battle_train_derail()
{
	//trying to turn off the hedlight fx here, might be a tad early 
	level.train_3[0].vehicle maps\nx_lava_fx::set_train_headlight_fx_off();

	// Don't allow derail till straightaway
	flag_wait( "train_2_straightaway" );
		
	level thread maps\nx_lava_anim::turret_battle_train_derail( "vignette_turret_battle_train_derail", "vignette_turret_battle_train_derail_done" );
	level thread turret_battle_train_trigger_hit();
	level thread turret_battle_train_end_path();
	flag_wait( "train_3_derail" );	
	flag_set( "vignette_turret_battle_train_derail" );
	
	// Clear fx. 
	//IPrintln( "die particles, die." );
	level.train_3[0].vehicle maps\_nx_moving_platform_vh::stop_train_maglex_fx();
	level.train_3[1].vehicle maps\_nx_moving_platform_vh::stop_train_maglex_fx();
	
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_3_rocket_enemy" );
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_3_tanks_enemy" );
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_4_enemy" );
	//maps\nx_lava_util::delete_entire_ai_group( "train_3_car_5_enemy" );
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_1_enemy" );
	maps\nx_lava_util::delete_entire_ai_group( "train_3_car_2_enemy" );
	ClearAllCorpses();

	level thread turret_battle_train_derail_slowmo();
	PlayFX( level._effect[ "derail_explosion" ], level.train_3[1].origin );
	flag_set( "train_3_derail" );
	
	level.player_turret thread maps\_ec_lunar_turret::turret_player_viewhands_react();
}

turret_battle_train_trigger_hit()
{
	self endon( "train_3_derail" );

	vignette_trigger_hit( "trigger_turret_battle_train_derail", "turret_explosion", 3, "train_3_derail" );
	flag_set( "train_3_derail" );
}

turret_battle_train_end_path()
{	
	self endon( "train_3_derail" );

	flag_wait( "train_3_force_derail" );
	flag_set( "train_3_derail" );
}

turret_battle_train_derail_slowmo()
{	
	// Slow motion

	SetSlowMotion( 1.0, 0.35, 0.2 );

	wait( 1.5 );
	
	// Slow motion
	SetSlowMotion( 0.4, 1.0, 0.2 );	
}

kill_entire_ai_group( group_name )
{
	ai_group = get_ai_group_ai( group_name );
	
	foreach( guy in ai_group )
	{
		if( IsDefined( guy.magic_bullet_shield )  && guy.magic_bullet_shield )
		{ 	
			guy stop_magic_bullet_shield();
		}
		guy kill();
	}
}

vignette_trigger_hit( trigger_name, fx_name, num_hits, flag )
{
	if( !IsDefined( num_hits ) )
	{
		num_hits = 1;
	}

	trigger = GetEnt( trigger_name, "targetname" );
	
	// Glow model
	glow_model = undefined;
	if( IsDefined( trigger.target ) )
	{
		glow_model = GetEnt( trigger.target, "targetname" );
		glow_model Glow();
	}

	trigger show();
	trigger setCanDamage( true );
	
	// Wait for vignette
	level thread vignette_trigger_hit_thread( trigger, num_hits, flag );
	flag_wait( flag );

	// FX / Earth Quake
	Earthquake( 0.3, 2, level._player.origin, 10000 );
	
	// kill nearby AI
	RadiusDamage( trigger.origin, 512, 300, 300 );
	
	// Cleanup
	trigger delete();
	if( IsDefined( glow_model ) )
	{
		glow_model delete();
	}
}

vignette_trigger_hit_thread( trigger, num_hits, flag )
{
	while( 1 )
	{
		trigger waittill ( "damage", amount, attacker, direction_vec, point, type );		
		if( attacker == level._player )
		{
			num_hits--;	
		}

		if( num_hits <= 0 )
		{
			break;
		}
	}
	
	flag_set( flag );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "generic_human" );
train_3_setup_locked_combat_nodes()
{
	// Car 5
	maps\_locked_combat::node_setup( "train_3_car_5_node_1" );
	maps\_locked_combat::node_setup( "train_3_car_5_node_2" );
	maps\_locked_combat::node_setup( "train_3_car_5_node_4" );

	//maps\_locked_combat::node_add_transition( "train_3_car_5_node_2", "train_3_car_5_node_3", %tp_moon_coverL_stand_2_coverR_stand_144 );
	//maps\_locked_combat::node_add_transition( "train_3_car_5_node_3", "train_3_car_5_node_2", %tp_moon_coverR_stand_2_coverL_stand_144 );
	
	// Car 4
	maps\_locked_combat::node_setup( "train_3_car_4_node_1" );
	maps\_locked_combat::node_setup( "train_3_car_4_node_2" );
	maps\_locked_combat::node_setup( "train_3_car_4_node_3" );
	maps\_locked_combat::node_setup( "train_3_car_4_node_4" );
	maps\_locked_combat::node_setup( "train_3_car_4_node_5" );
	maps\_locked_combat::node_setup( "train_3_car_4_node_6" );
	maps\_locked_combat::node_setup( "train_3_car_4_node_7" );

	maps\_locked_combat::node_add_transition( "train_3_car_4_node_1", "train_3_car_4_node_2", %tp_moon_lava_exposed_stand_2_exposed_crouch_f152 );
	maps\_locked_combat::node_add_transition( "train_3_car_4_node_3", "train_3_car_4_node_4", %tp_moon_coverL_stand_2_coverR_stand_144 );
	maps\_locked_combat::node_add_transition( "train_3_car_4_node_4", "train_3_car_4_node_3", %tp_moon_coverR_stand_2_coverL_stand_144 );

	maps\_locked_combat::node_add_transition( "train_3_car_4_node_5", "train_3_car_4_node_6", %tp_moon_trav_cover_crouch_L_R_200 );
	maps\_locked_combat::node_add_transition( "train_3_car_4_node_6", "train_3_car_4_node_5", %tp_moon_trav_cover_crouch_R_L_200 );

	// Car 3
	maps\_locked_combat::node_setup( "train_3_car_3_node_1" );
	maps\_locked_combat::node_setup( "train_3_car_3_node_2" );
	maps\_locked_combat::node_setup( "train_3_car_3_node_3" );
	maps\_locked_combat::node_setup( "train_3_car_3_node_4" );
	maps\_locked_combat::node_setup( "train_3_car_3_node_5" );
	maps\_locked_combat::node_setup( "train_3_car_3_node_6" );
	maps\_locked_combat::node_setup( "train_3_car_3_node_7" );

	maps\_locked_combat::node_add_transition( "train_3_car_3_node_1", "train_3_car_3_node_2", %tp_moon_lava_exposed_stand_2_stand_R352_u52_R40 );
	maps\_locked_combat::node_add_transition( "train_3_car_3_node_3", "train_3_car_3_node_4", %tp_moon_exposed_stand_2_coverR_crouch_d56_f76_l64 );

	maps\_locked_combat::node_add_transition( "train_3_car_3_node_6", "train_3_car_3_node_5", %tp_moon_trav_cover_crouch_L_R_200 );
	maps\_locked_combat::node_add_transition( "train_3_car_3_node_5", "train_3_car_3_node_6", %tp_moon_trav_cover_crouch_R_L_200 );

	// Car 2
	maps\_locked_combat::node_setup( "train_3_car_2_node_1" );
	maps\_locked_combat::node_setup( "train_3_car_2_node_2" );
	//maps\_locked_combat::node_setup( "train_3_car_2_node_3" );
	maps\_locked_combat::node_setup( "train_3_car_2_node_4" );
	maps\_locked_combat::node_setup( "train_3_car_2_node_5" );

	maps\_locked_combat::node_add_transition( "train_3_car_2_node_1", "train_3_car_2_node_2", %tp_moon_lava_exposed_crouch_2_stand_R152_u80_R104 );	
	maps\_locked_combat::node_add_transition( "train_3_car_2_node_5", "train_3_car_2_node_4", %tp_moon_trav_cover_crouch_L_R_200 );
	maps\_locked_combat::node_add_transition( "train_3_car_2_node_4", "train_3_car_2_node_5", %tp_moon_trav_cover_crouch_R_L_200 );

	// Car 1
	maps\_locked_combat::node_setup( "train_3_car_1_node_1" );
	maps\_locked_combat::node_setup( "train_3_car_1_node_2" );
	maps\_locked_combat::node_setup( "train_3_car_1_node_3" );
	maps\_locked_combat::node_setup( "train_3_car_1_node_4" );
	maps\_locked_combat::node_setup( "train_3_car_1_node_5" );
	maps\_locked_combat::node_setup( "train_3_car_1_node_6" );
	maps\_locked_combat::node_setup( "train_3_car_1_node_7" );
	maps\_locked_combat::node_setup( "train_3_car_1_node_8" );

	maps\_locked_combat::node_add_transition( "train_3_car_1_node_2", "train_3_car_1_node_1", %tp_moon_trav_cover_crouch_L_R_200 );
	maps\_locked_combat::node_add_transition( "train_3_car_1_node_1", "train_3_car_1_node_2", %tp_moon_trav_cover_crouch_R_L_200 );

	maps\_locked_combat::node_add_transition( "train_3_car_1_node_4", "train_3_car_1_node_3", %tp_moon_trav_cover_crouch_L_R_200 );
	maps\_locked_combat::node_add_transition( "train_3_car_1_node_3", "train_3_car_1_node_4", %tp_moon_trav_cover_crouch_R_L_200 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_2_skimmers_vo()
{
	flag_wait( "skimmer_start_vo" );
	radio_dialogue( "lava_bak_tr2turr_hightowerzulu1" );				// dialog: "Hightower this Zulu 1, do you copy."
	// wait( 0.5 );
	radio_dialogue( "lava_mctrl_tr2turr_statusandloc" );				// dialog: "Roger that Zulu, what is your status and location."
	// wait( 0.5 );
	radio_dialogue( "lava_bak_tr2turr_recoveredintel" );				// dialog: "Grid square Whiskey Ultra, we have recovered the intel and are continuing mission. Repeat, we are Charlie Mike."
	// wait( 0.5 );
	radio_dialogue( "lava_mctrl_tr2turr_dispatchingsear" );				// dialog: "Copy that, Zulu, we’re dispatching a SEAR unit to recover your team. "
	// wait( 0.1 );
	radio_dialogue( "lava_bak_tr2turr_dontneedrescue" );				// dialog: "What the fuck are you talking about! We don’t need a rescue! We need backup!"
	
	flag_wait( "skimmers_wave_2_spawned" );
	wait( 1 );
	oddCoin = RandomInt( 100 );
	if(oddCoin > 66 )
		radio_dialogue( "lava_bak_tr2turr_enemyairinbound" );			// dialog: "Enemy air inbound!"
	else if( oddCoin > 33 )
		radio_dialogue( "lava_bak_tr2turr_incoming" );					// dialog: "Incoming!"
	else
		radio_dialogue( "lava_bak_tr2turr_skimmers12oclock" );			// dialog: "Skimmers! 12 O'clock!"
	
	flag_wait( "final_derail_tunnel_exit" );
	radio_dialogue( "lava_bak_derail_heretheycomeagain" );				// dialog: "Here they come again!"
}

train_2_skimmers_start()
{
	// Setup Train 2 Turret vehicle and Init player start location
	maps\nx_lava_util::setup_train_vehicles( level.train_turret, false );
	maps\nx_lava_util::show_hide_train( level.train_turret, "show" );

	// Used for player_gets_on_turret
	level.train_2_jump_to = true;
	level thread player_gets_on_turret( 10 );
	level thread train_2_ally_thread();
	flag_set( "player_on_turret_anim_complete" );
	
	wait( 0.05 );
	
	// Start the movement from debug position
	level thread train_2_skimmers_move_start();
	
	wait( 2 );
	flag_set( "skimmer_start_vo" );
}

train_2_skimmers()
{
	// VO 
	level thread train_2_skimmers_vo();

	level thread maps\nx_lava_util::start_fake_train_movement( false );

	// Turn off friendly fire & gimp baker
	maps\_friendlyfire::TurnOff();

	// Wait for skimmer spawn
	spawn_skimmers();
}

train_2_skimmers_move_start()
{
	// Move front vehicle
	level.train_turret maps\nx_lava_util::train_switch_target( "train_2_front_skim");
	thread maps\nx_lava_util::move_train( level.train_turret, TRAIN_2_SPEED_SKIMMER, 10000, 10 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_2_skimmers_ally_thread()
{
	
}


train_2_skimmers_player_thread()
{
	// tagTC<hack> - need to figure out why bullets aren't aiming correctly
	level._player magic_bullet_shield();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_skimmers()
{
	// Wait for skimmer spawn
	spawn_trigger = GetEnt( "spawn_skimmers_wave_0", "targetname" );
	spawn_trigger waittill( "trigger" );

	level.target_skimmer = [];

	skimmers = GetEntArray( spawn_trigger.target, "targetname" );
	foreach( skimmer_spawner in skimmers )
	{
		skimmer = skimmer_spawner maps\_attack_heli::SAV_setup( "pathing_shooting" );
		
		skimmer thread skimmer_wave_0_spawn_func();
	}
		
	// spawn target skimmers
	thread skimmer_target_spawn( 0 );

	flag_set( "skimmers_spawned" );
	
	// Wait for skimmer spawn
	spawn_trigger = GetEnt( "spawn_skimmers_wave_1", "targetname" );
	spawn_trigger waittill( "trigger" );

	skimmers = GetEntArray( spawn_trigger.target, "targetname" );
	foreach( skimmer_spawner in skimmers )
	{
		skimmer = skimmer_spawner maps\_attack_heli::SAV_setup( "pathing_shooting" );
		skimmer thread skimmer_wave_1_spawn_func();
	}

	flag_set( "skimmers_wave_1_spawned" );

	// Wait for skimmer target spawn
	spawn_trigger = GetEnt( "spawn_skimmers_target_2", "targetname" );
	spawn_trigger waittill( "trigger" );
	
	// spawn target skimmers
	thread skimmer_target_spawn( 2 );

	
	// Wait for skimmer spawn
	spawn_trigger = GetEnt( "spawn_skimmers_wave_2", "targetname" );
	spawn_trigger waittill( "trigger" );

	skimmers = GetEntArray( spawn_trigger.target, "targetname" );
	foreach( skimmer_spawner in skimmers )
	{
		skimmer = skimmer_spawner maps\_attack_heli::SAV_setup( "pathing_shooting" );
		skimmer thread skimmer_wave_2_spawn_func();
	}

	flag_set( "skimmers_wave_2_spawned" );
	
	// Wait for skimmer target spawn
	spawn_trigger = GetEnt( "spawn_skimmers_target_3", "targetname" );
	spawn_trigger waittill( "trigger" );
	
	// spawn target skimmers
	thread skimmer_target_spawn( 3 );
}

skimmer_target_spawn( wave )
{
	for( i=0; i<2; i++)
	{
		if( !IsDefined( level.target_skimmer[i] ) )
		{
			skimmer_spawner = GetEnt( "enemy_skimmer_target_" + string(i) + string(wave), "targetname" );
			skimmer = skimmer_spawner maps\_attack_heli::SAV_setup( "pathing_shooting" );
			
			skimmer thread skimmer_target_spawn_func();
			level.target_skimmer[i] = skimmer;
		}
	}
}

skimmer_target_spawn_func()
{
	self endon( "death" );

	// move and damage reduce
	self Vehicle_SetSpeedImmediate( TRAIN_2_SPEED_SKIMMER*.33, TRAIN_2_SPEED_SKIMMER, TRAIN_2_SPEED_SKIMMER );
	
	// start dynamic speed
	wait( 2 );
	self thread skimmer_follow_player( 0.1, 0.25, .25, TRAIN_2_SPEED_SKIMMER, 1536, 0.7, true );
	
	// delete at end of path
	self waittill( "goal" );
	self delete();
}

skimmer_wave_0_spawn_func()
{
	self endon( "death" );

	// move and damage reduce
	self Vehicle_SetSpeedImmediate( TRAIN_2_SPEED_SKIMMER, TRAIN_2_SPEED_SKIMMER, TRAIN_2_SPEED_SKIMMER );
	
	// start dynamic speed
	wait( 2 );
	self thread skimmer_follow_player( 1, 2, .25, TRAIN_2_SPEED_SKIMMER, 3072, 0.7 );
	
	// delete at end of path
	self waittill( "goal" );
	self delete();
}

skimmer_wave_1_spawn_func()
{
	self endon( "death" );

	// move and damage reduce
	self Vehicle_SetSpeedImmediate( TRAIN_2_SPEED_SKIMMER, TRAIN_2_SPEED_SKIMMER, TRAIN_2_SPEED_SKIMMER );
	
	// start dynamic speed
	wait( 2 );
	self thread skimmer_follow_player( 1, 2, .25, TRAIN_2_SPEED_SKIMMER, 3072, 0.7 );
	
	// delete at end of path
	self waittill( "goal" );
	self delete();
}

skimmer_wave_2_spawn_func()
{
	self endon( "death" );

	self Vehicle_SetSpeedImmediate( TRAIN_2_SPEED_SKIMMER + 20, TRAIN_2_SPEED_SKIMMER, TRAIN_2_SPEED_SKIMMER );
	
	// start dynamic speed
	wait( 8 );
	self thread skimmer_follow_player( 1, 2, .25, TRAIN_2_SPEED_SKIMMER, 3072, 0.7 );
	
	//self thread skimmer_health_print();
	
	// delete at end of path
	self waittill( "goal" );
	self delete();
}

skimmer_health_print()
{
	self endon( "death" );

	base_health = self.health;
	while( 1 )
	{
		if( self.health < base_health )
		{
			IPrintln( self.health );
		}
		wait( 0.05 );
	}
}


//*******************************************************************
//		SKIMMER UNTILS                                              *
//                                                                  *
//*******************************************************************

skimmer_follow_player( time_low, time_high, speed_percent, base_speed, max_dist, arc, isFollow )
{
	self endon( "death" );
	self endon( "stop_follow_player" );
	self endon( "reached_end_node" );

	if( !IsDefined( arc ) )
		arc = 0;
	if( !IsDefined( isFollow) )
		isFollow = false;

	while( 1 ) 
	{
		ra_seed = level._player.angles;
		if( IsDefined( level.train_turret[4].vehicle ) )
			ra_seed = level.train_turret[4].vehicle.angles;
			
		to_player = VectorNormalize( self.origin - level._player.origin );
		right_angles = AnglesToForward( ra_seed );
		dot = VectorDot( right_angles, to_player );
		dist = Distance( self.origin, level._player.origin );

		// check location and adjust speed
		if( dot < arc )
		{
			// IPrintlnBold( "BEHIND " + dist );
			skim_speed = base_speed * 1.33;
			self Vehicle_SetSpeed( skim_speed, skim_speed, skim_speed );
		}
		else if( dist < 1024 )
		{
			// IPrintlnBold( "BEHINDISH " + dist );
			skim_speed = base_speed + ( base_speed  * speed_percent );
			self Vehicle_SetSpeed( skim_speed, skim_speed, skim_speed );
		}
		else if( dist > max_dist ) 
		{
			// IPrintlnBold( "AHEAD " + dist );
			skim_speed = base_speed - ( base_speed  * speed_percent );
			self Vehicle_SetSpeed( skim_speed, skim_speed, skim_speed );
		}
		else if( isFollow )
		{
			self Vehicle_SetSpeed( base_speed, base_speed, base_speed );
		}

		wait( RandomFloatRange( time_low, time_high ) );
	}
}