//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module: Lava Train 1													**
//                                                                          **
//    Created: 07/25/10 - Travis Chen (trchen x 4143)						**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;

// tagTC<note> - Variable for ben to test animated train path in real mission
DEBUG_ANIMATED_TRAIN = false;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
	maps\_locked_combat::main();
	maps\_locked_covertypes_lunar::init_default_covertypes();

	createthreatbiasgroup( "player" );
	level._player setthreatbiasgroup( "player" );
	
	level thread train_1_setup();
	level thread train_2_setup();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
	PrecacheItem( "lunar_glo" );
}

section_flag_inits()
{
	flag_init( "objective_train_1_start" );

	flag_init( "train_1_at_platform" );
	flag_init( "train_1_moving" );
	flag_init( "train_1_stop" );
	flag_init( "train_1_track_switch" );
	flag_init( "train_2_stop" );
	flag_init( "train_2_car_2" );
	flag_init( "train_2_car_1" );
	flag_init( "train_1_introduction_done" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_objectives( objective_num )
{
	flag_wait( "train_1_introduction_done" );
	
	// Use train 1
	waypoint = getEnt( "waypoint_train_1_start", "targetname" );
	objective_add( objective_num, "current", &"NX_LAVA_OBJECTIVE_TRAIN_1_START", waypoint.origin );
	objective_current( objective_num );

	flag_wait( "train_1_player_near_button_push" );
	objective_complete( objective_num );
	objective_num++;

	return objective_num;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

TRAIN_1_SPEED = 125;
TRAIN_1_INTRODUCTION_SPEED = 30;
TRAIN_2_SPEED = 125;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_1_vo()
{
	// thread add_dialogue_line( "Cameron", "Train route re-programmed. Good hunting...", "w" );
	radio_dialogue( "lava_cam_st1cmd_reprogrammed" );
	
	//thread add_dialogue_line( "Baker", "Get to that train! We only have seconds before it's programmed to leave.", "w" );	
	radio_dialogue( "lava_bak_train1_get2train" );
	
	flag_wait( "train_1_moving" );

	// Baker - "We’re off."
	radio_dialogue( "lava_kee_st1train_wereoff" );
	//thread add_dialogue_line( "Keene", "We’re off.", "w" );

	wait( 0.5 );

	// Carson - "We’ve got another train approaching from the rear!"
	radio_dialogue( "lava_car_st1train_trainfromrear" );
	//thread add_dialogue_line( "Tillman", "We’ve got another train approaching from the rear!", "w" );
	
	wait( 2.0 );

	// Baker - "We’ve got company, look alive!"
	radio_dialogue( "lava_kee_st1train_gotcompany1" );
	//thread add_dialogue_line( "Keene", "We’ve got company, look alive!", "w" );
	
	wait( 1.0 );
	
	//thread add_dialogue_line( "Baker", "Take out that turret gunner!", "w" );	
	//radio_dialogue( "lav_bak_st1train_takeoutturret" );
	
	wait( 20.0 );
	
	//thread add_dialogue_line( "Baker", "Keene's tracking beacon has stopped. We're closing in on him.", "w" );
	radio_dialogue( "lava_bak_st1train_trackingbeacon" );
	
	flag_wait( "train_1_track_switch" );

	// Baker - "We're pulling into the next station."
	radio_dialogue( "lava_ser_st2_nextstation" );

	wait( 5.0 );

	// Baker - "Keene's near by. This is our stop. Get ready, they know we're coming."
	radio_dialogue( "lava_bak_st2_ourstopgetready" );

	wait( 10.0 );
	
	//thread add_dialogue_line( "Baker", "Aim for those compressed air canisters.", "w" );	
	radio_dialogue( "lava_bak_st2_aimforaircanisters" );
}

train_1_start()
{
	maps\nx_lava_util::player_start( "player_start_train_1" );
	thread maps\nx_lava_fx::set_vision_and_fog("station1", 0); // set initial vision and fog for this checkpoint.

	// Spawn the allies
	maps\nx_lava_util::lava_ally_spawn( "train_1" );

	// Give player loadout
	level._player TakeAllWeapons();
	level._player GiveWeapon( "lunarrifle" );
	level._player GiveWeapon( "lunar_glo" );
	level._player SwitchToWeapon( "lunarrifle" );
}

train_1()
{
	flag_wait( "train_1_introduction" );
	flag_set( "train_1_at_platform" );

	// VO
	level thread train_1_vo();
	
	// Player thread
	level thread train_1_player_thread();
	
	// Show train 2
	if( !DEBUG_ANIMATED_TRAIN )
	{
		level thread train_1_setup();
		level thread train_2_setup();
	}

	// Ally thread
	level.keene thread keene_thread();
	level.tilman thread tillman_thread();
	
	// Move the train to the right place
	level thread train_1_introduction_move();
	
	if( !DEBUG_ANIMATED_TRAIN )
	{
		// Move the cargo train
		level thread train_1_move();
	}
	else 
	{
		level thread maps\nx_lava_anim::train1_section_8car_train_spawn();
		level thread maps\nx_lava_anim::train1_section_4car_train_spawn();
		level thread train_1_move_animated();
		level thread train_2_move_animated();
		level thread train_2_enemy_setup();
	}

	// Setup locked combat nodes
	level thread train_1_setup_locked_combat_nodes();
	
	// Wait for keene to start the train
	flag_wait( "train_1_moving" );
	
	// Move the cargo train
	if( !DEBUG_ANIMATED_TRAIN )
	{
		level thread train_2_move();
		level thread train_2_stop();
	}
}

train_1_player_thread()
{
	flag_wait( "train_1_moving" );
	
	// tagTC<temp> - Give player loadout until we can get weapon pickups working on train
	level._player TakeAllWeapons();
	level._player GiveWeapon( "lunarrifle" );
	level._player GiveWeapon( "lunar_glo" );
	level._player SwitchToWeapon( "lunar_glo" );
}

keene_thread()
{
	board_node = GetNode( "train_1_keene_board", "targetname" );
	maps\_spawner::go_to_node( board_node );

	self thread enable_cqbwalk();
	
	flag_wait( "train_1_player_near_button_push" );
	
	// Button push scene
	self.animname = "keene";
	maps\nx_lava_anim::button_push( self );
	
	flag_set( "train_1_moving" );

	self maps\_locked_combat::init_locked_combat( "train_1_keene_fixed_node" );
}

tillman_thread()
{
	board_node = GetNode( "train_1_tillman_board", "targetname" );
	maps\_spawner::go_to_node( board_node );
	
	self thread enable_cqbwalk();
	
	flag_wait( "train_1_moving" );

	self maps\_locked_combat::init_locked_combat( "train_1_tillman_fixed_node" );
}

#using_animtree( "generic_human" );
train_1_setup_locked_combat_nodes()
{
	maps\_locked_combat::node_setup( "train_1_tillman_fixed_node" );
	maps\_locked_combat::node_setup( "train_1_keene_fixed_node" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_1_use()
{
	// Wait for player to use train 1
	use = GetEnt( "use_train_1", "targetname" );
	use sethintstring( &"NX_LAVA_USE_TRAIN_1" );		
	use waittill( "trigger" );
	use trigger_off();

	flag_set( "objective_train_1_start" );
}

train_1_setup()
{
	if( !IsDefined( level.train_1 ) )
	{
		train_name_array = [ 	[ "train_1_car_1", "train_1_car_1_vehicle" ], 
								[ "train_1_car_2", "train_1_car_2_vehicle" ], 
								[ "train_1_car_3", "train_1_car_3_vehicle" ],
								[ "train_1_car_4", "train_1_car_4_vehicle" ] ];
	
		// Setup the enemy train
		level.train_1 = maps\nx_lava_util::setup_train_platforms( train_name_array );
		
		foreach( train in level.train_1 )
		{
			train maps\_nx_moving_platform::platform_process_all_elements( "hide" );
		}
	}
	else
	{
		maps\nx_lava_util::setup_train_vehicles( level.train_1, false );
		
		foreach( train in level.train_1 )
		{
			train maps\_nx_moving_platform::platform_process_all_elements( "show" );
		}
	}
}

train_1_move()
{
	flag_wait( "train_1_moving" );
	
	// Link vehicles to new path
	foreach( i, train in level.train_1 )
	{
		train_1_vehicle = train.vehicle;
		start_point_name = "train_1_car_" + ( i + 1 ) + "_start";
		train_1_vehicle.target = start_point_name;
	}
	
	level.train_1[0] PlaySound( "nx_lava_train1" );

	SetThreatBias( "axis", "player", 999999 );	
		
	level thread autosave_now();
	
	maps\nx_lava_util::move_train( level.train_1, TRAIN_1_SPEED, 22, 10 );

	// Wait for decel
	trigger_wait( "train_1_decel", "targetname" );

	flag_set( "train_1_track_switch" );
	maps\nx_lava_util::set_train_speed( level.train_1, 55, 10, 2 );

	level thread autosave_now();
	
	trigger_wait( "train_1_decel_2", "targetname" );

	maps\nx_lava_util::set_train_speed( level.train_1, 6, 15, 2 );

	level thread autosave_now();
	
	level thread train_1_open_doors();
	
	// Wait till stop
	level.train_1[0].vehicle waittill( "reached_end_node" );
	flag_set( "train_1_stop" );
	
	SetThreatBias( "axis", "player", 0 );
}

train_1_open_doors()
{
	clip_array = GetEntArray( "station_1_train_1_player_clip", "targetname" );
	foreach( clip in clip_array )
		clip NotSolid();
	
	flag_wait( "train_1_stop" );

	// Delete the collmap
	collmap = GetEnt( level.train_1[0].targetname, "targetname" );
	collmap delete();

	clip_array = GetEntArray( "station_1_train_1_player_clip", "targetname" );
	foreach( clip in clip_array )
		clip Solid();
	
	door_right = GetEnt( "train_1_door_right", "targetname" );
	door_left = GetEnt( "train_1_door_left", "targetname" );

	// Close Front
	door_right MoveY( -36, 3, .05, .5 );
	door_left MoveY( 36, 3, .05, .5 );
}

train_1_move_animated()
{
	foreach( train in level.train_1 )
	{
		train.vehicle.train_anim = "train1_section_4car_train";
		train.vehicle.animated = true;
	}

	self thread maps\nx_lava_util::move_train_animated( level.train_1, 0, 10000, 10000 );

	// Move the train
	flag_wait( "train_1_moving" );
	self thread maps\nx_lava_util::move_train_animated( level.train_1, TRAIN_1_SPEED, 22, 10 );

	level thread autosave_now();
	
	// Wait for decel.
	trigger_wait( "train_1_decel", "targetname" );
	flag_set( "train_1_track_switch" );
	self thread maps\nx_lava_util::move_train_animated( level.train_1, 45, 10, 10 );

	// Wait for decel. 
	trigger_wait( "train_1_decel_2", "targetname" );
	self thread maps\nx_lava_util::move_train_animated( level.train_1, 4.5, 10, 15 );

	level thread autosave_now();
}

train_1_introduction_move()
{
	// Move the player's train into position
	maps\nx_lava_util::move_train( level.train_1, 25, 1000, 1.0 );
	wait( 2.0 );
	maps\nx_lava_util::set_train_speed( level.train_1, 0, 20, 1.0 );
	
	level.train_1[0].vehicle waittill( "reached_end_node" );
	flag_set( "train_1_introduction_done" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_2_setup()
{
	if( !IsDefined( level.train_2 ) )
	{
		train_name_array = [ 	[ "train_2_car_0", "train_2_car_0_vehicle" ], 
								[ "train_2_car_1", "train_2_car_1_vehicle" ], 
								[ "train_2_car_2", "train_2_car_2_vehicle" ],
								[ "train_2_car_3", "train_2_car_3_vehicle" ],
								[ "train_2_car_4", "train_2_car_4_vehicle" ],
								[ "train_2_car_5", "train_2_car_5_vehicle" ],
								[ "train_2_car_6", "train_2_car_6_vehicle" ],
								[ "train_2_car_7", "train_2_car_7_vehicle" ],
								[ "train_2_car_8", "train_2_car_8_vehicle" ],
								[ "train_2_car_9", "train_2_car_9_vehicle" ] ];
	
		// Setup the enemy train
		level.train_2 = maps\nx_lava_util::setup_train_platforms( train_name_array ); 
	
		level thread train_2_enemy_setup();
		
		foreach( train in level.train_2 )
		{
			train maps\_nx_moving_platform::platform_process_all_elements( "hide" );
		}
	}
	else
	{
		maps\nx_lava_util::setup_train_vehicles( level.train_2, false ); 
		
		foreach( train in level.train_2 )
		{
			train maps\_nx_moving_platform::platform_process_all_elements( "show" );
			train.vehicle Show();
		}
	}
}

train_2_enemy_setup()
{	
	flag_wait( "train_1_moving" );

	// Setup the locked combat for the enemies
	train_2_setup_locked_combat_nodes();
	level thread maps\nx_lava_util::platform_enemy_setup_locked_combat( level.train_2[1], "platform_enemy_1", "train_2_stop" );
	level thread maps\nx_lava_util::platform_enemy_setup_locked_combat( level.train_2[1], "platform_enemy_1_move_on_flag", "train_2_stop", maps\nx_lava_util::platform_enemy_move_on_flag, "train_2_car_1" );
	level thread maps\nx_lava_util::platform_enemy_setup_locked_combat( level.train_2[2], "platform_enemy_2", "train_2_stop" );
	level thread maps\nx_lava_util::platform_enemy_setup_locked_combat( level.train_2[2], "platform_enemy_2_move_on_flag", "train_2_stop", maps\nx_lava_util::platform_enemy_move_on_flag, "train_2_car_2" );
	level thread maps\nx_lava_util::platform_enemy_setup_locked_combat( level.train_2[3], "platform_enemy_3", "train_2_stop" );
	
	// Setup turret enemies
	//level thread maps\nx_lava_util::turret_enemy_setup( level.train_2[3], "train_2_car_3_turret_enemy", "train_2_stop" );
}

train_2_move()
{	
	// Move the enemy train
	maps\nx_lava_util::move_train( level.train_2, TRAIN_2_SPEED + 45, 90, 10 );

	flag_wait( "train_1_player_in_tunnel" );

	// Car 3, Follow Player, Turrets
	center_link_point = level.train_2[3] maps\_nx_moving_platform::get_platform_ent( "center_link_point" );
	level.train_2[0].vehicle thread maps\nx_lava_util::vehicle_array_follow_player( level.train_2, center_link_point, 0.5, 1.0, 0.1, 20, TRAIN_2_SPEED );
	waittill_aigroupcount( "platform_enemy_3", 1 );
	
//	// Kill left over enemies
//	ai_group = get_ai_group_ai( "platform_enemy_3" );
//	foreach( ai in ai_group )
//	{
//		ai Kill();
//	}
	
	// Car 2, Follow Player
	flag_set( "train_2_car_2" );
	level.train_2[0].vehicle maps\nx_lava_util::stop_follow_ai_group();
	center_link_point = level.train_2[2] maps\_nx_moving_platform::get_platform_ent( "center_link_point" );
	level.train_2[0].vehicle thread maps\nx_lava_util::vehicle_array_follow_player( level.train_2, center_link_point, 0.5, 1.0, 0.1, 20, TRAIN_2_SPEED );
	
	waittill_aigroupcount( "platform_enemy_2", 1 );

	flag_set( "train_2_car_1" );
	level.train_2[0].vehicle maps\nx_lava_util::stop_follow_ai_group();
	center_link_point = level.train_2[1] maps\_nx_moving_platform::get_platform_ent( "center_link_point" );
	level.train_2[0].vehicle thread maps\nx_lava_util::vehicle_array_follow_player( level.train_2, center_link_point, 0.5, 1.0, 0.1, 20, TRAIN_2_SPEED );
}

train_2_move_animated()
{	
	foreach( train in level.train_2 )
	{
		train.vehicle.train_anim = "train1_section_8car_train";
		train.vehicle.animated = true;
	}

	self thread maps\nx_lava_util::move_train_animated( level.train_2, 0, 10000, 10000 );

	// Wait for keene to start the train
	flag_wait( "train_1_moving" );
	
	// Move the enemy train
	maps\nx_lava_util::move_train_animated( level.train_2, TRAIN_2_SPEED + 35, 80, 10 );
	
	flag_wait( "train_1_player_in_tunnel" );
	
	// Car 3, Follow Player, Turrets
	center_link_point = level.train_2[3] maps\_nx_moving_platform::get_platform_ent( "center_link_point" );
	level.train_2[0].vehicle thread maps\nx_lava_util::vehicle_array_follow_player( level.train_2, center_link_point, 0.5, 1.0, 0.1, 20, TRAIN_2_SPEED );
	waittill_aigroupcount( "platform_enemy_3", 1 );
	
	// Car 2, Follow Player
	flag_set( "train_2_car_2" );
	level.train_2[0].vehicle maps\nx_lava_util::stop_follow_ai_group();
	center_link_point = level.train_2[2] maps\_nx_moving_platform::get_platform_ent( "center_link_point" );
	level.train_2[0].vehicle thread maps\nx_lava_util::vehicle_array_follow_player( level.train_2, center_link_point, 0.5, 1.0, 0.1, 20, TRAIN_2_SPEED );
	
	waittill_aigroupcount( "platform_enemy_2", 1 );

	flag_set( "train_2_car_1" );
	level.train_2[0].vehicle maps\nx_lava_util::stop_follow_ai_group();
	center_link_point = level.train_2[1] maps\_nx_moving_platform::get_platform_ent( "center_link_point" );
	level.train_2[0].vehicle thread maps\nx_lava_util::vehicle_array_follow_player( level.train_2, center_link_point, 0.5, 1.0, 0.1, 20, TRAIN_2_SPEED );
}

train_2_stop()
{
	level.train_2[0].vehicle waittill( "reached_end_node" );
	flag_set( "train_2_stop" );
	
	wait( 0.05 );
	
	maps\nx_lava_util::delete_train( level.train_2 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "generic_human" );
train_2_setup_locked_combat_nodes()
{
	// Car 1
	maps\_locked_combat::node_setup( "car_1_crouch_right" );
	maps\_locked_combat::node_setup( "car_1_crouch_left" );
	//maps\_locked_combat::node_setup( "car_1_stand_right" );
	//maps\_locked_combat::node_setup( "car_1_stand_left" );
	maps\_locked_combat::node_setup( "car_1_down_right" );
	maps\_locked_combat::node_setup( "car_1_down_left" );
	maps\_locked_combat::node_setup( "car_1_static_1" );
	maps\_locked_combat::node_setup( "car_1_static_2" );
	maps\_locked_combat::node_setup( "car_1_static_3" );
	maps\_locked_combat::node_setup( "car_1_static_4" );
	
	maps\_locked_combat::node_add_transition( "car_1_crouch_right", "car_1_crouch_left", %tp_moon_trav_cover_crouch_L_R_200 );
	maps\_locked_combat::node_add_transition( "car_1_crouch_left", "car_1_crouch_right", %tp_moon_trav_cover_crouch_R_L_200 );
	//maps\_locked_combat::node_add_transition( "car_1_stand_right", "car_1_stand_left", %tp_moon_coverL_crouch_2_coverR_stand_144 );
	//maps\_locked_combat::node_add_transition( "car_1_stand_left", "car_1_stand_right", %tp_moon_coverR_crouch_2_coverL_stand_144 );	
	maps\_locked_combat::node_add_transition( "car_1_down_left", "car_1_down_right", %tp_moon_exposed_stand_2_coverR_crouch_d56_f76_l64 );

	// Car 2
	maps\_locked_combat::node_setup( "car_2_crouch_right" );
	maps\_locked_combat::node_setup( "car_2_crouch_left" );
	maps\_locked_combat::node_setup( "car_2_crouch_right_2" );
	maps\_locked_combat::node_setup( "car_2_crouch_left_2" );
	maps\_locked_combat::node_setup( "car_2_stand_right" );
	maps\_locked_combat::node_setup( "car_2_stand_left" );
	//maps\_locked_combat::node_setup( "car_2_stand_right_2" );
	//maps\_locked_combat::node_setup( "car_2_stand_left_2" );
	maps\_locked_combat::node_setup( "car_2_up_right" );
	maps\_locked_combat::node_setup( "car_2_up_left" );

	maps\_locked_combat::node_add_transition( "car_2_crouch_right", "car_2_crouch_left", %tp_moon_trav_cover_crouch_L_R_200 );
	maps\_locked_combat::node_add_transition( "car_2_crouch_left", "car_2_crouch_right", %tp_moon_trav_cover_crouch_R_L_200 );
	maps\_locked_combat::node_add_transition( "car_2_crouch_right_2", "car_2_crouch_left_2", %tp_moon_trav_cover_crouch_L_R_200 );
	maps\_locked_combat::node_add_transition( "car_2_crouch_left_2", "car_2_crouch_right_2", %tp_moon_trav_cover_crouch_R_L_200 );
	maps\_locked_combat::node_add_transition( "car_2_stand_right", "car_2_stand_left", %tp_moon_coverL_stand_2_coverR_stand_144 );
	maps\_locked_combat::node_add_transition( "car_2_stand_left", "car_2_stand_right", %tp_moon_coverR_stand_2_coverL_stand_144 );
	//maps\_locked_combat::node_add_transition( "car_2_stand_right_2", "car_2_stand_left_2", %tp_moon_coverL_crouch_2_coverR_stand_144 );
	//maps\_locked_combat::node_add_transition( "car_2_stand_left_2", "car_2_stand_right_2", %tp_moon_coverR_crouch_2_coverL_stand_144 );
	maps\_locked_combat::node_add_transition( "car_2_up_right", "car_2_up_left", %tp_moon_run_2_coverR_stand_f320_u56_f64_R50 );

	// Car 3
	maps\_locked_combat::node_setup( "car_3_crouch_right" );
	maps\_locked_combat::node_setup( "car_3_crouch_left" );
	maps\_locked_combat::node_setup( "car_3_static" );

	maps\_locked_combat::node_add_transition( "car_3_crouch_right", "car_3_crouch_left", %tp_moon_trav_cover_crouch_L_R_200 );
	maps\_locked_combat::node_add_transition( "car_3_crouch_left", "car_3_crouch_right", %tp_moon_trav_cover_crouch_R_L_200 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

