//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module: Lava Station 1												**
//                                                                          **
//    Created: 07/25/10 - Travis Chen (trchen x 4143)						**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
	// setup station 1 spawners
	self thread setup_spawners();
	
	// setup train (no vehicle)
	if( !IsDefined( level.e_train ) )
	{
		level.e_train = setup_train_by_name( "s1_eTrain" );
		
		// hide train
		foreach( train in level.e_train )
		{
			train maps\_nx_moving_platform::platform_process_all_elements( "hide" );
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
	PreCacheRumble( "falling_land" );
}

section_flag_inits()
{
	// Pre-Platform
	flag_init( "player_falling_death" );
	flag_init( "s1p_lift_almost_down" );
	flag_init( "s1p_lift_down" );
	
	// Platform Battle - Lift
	flag_init( "s1p_player_near_lift_jump" );
	flag_init( "s1p_player_jump_lift" );
	flag_init( "s1p_jump_managed" );

	// Platform Battle
	flag_init( "s1p_player_jump_5th" );
	flag_init( "s1p_kill_5th_bad" );
	flag_init( "s1p_player_jump_4th" );
	flag_init( "s1p_kill_4th_bad" );
	flag_init( "s1p_player_jump_3rd" );
	flag_init( "s1p_kill_3rd_bad" );
	
	// Under Tracks
	flag_init( "s1_tracks_begin" );
	flag_init( "s1_player_jump_tracks" );
	flag_init( "s1_tracks_spawn_ar_roll" );
	flag_init( "s1_tracks_backtrack_ar" );
	flag_init( "s1_tracks_train_pass" );
	
	// Command Center
	flag_init( "s1_under_tracks_done" );
	flag_init( "s1_cc_lev_ready" );
	flag_init( "s1_cc_lev_open" );
	flag_init( "cc_lev_ready_baker" );
	flag_init( "cc_lev_ready_tilman" );
	flag_init( "cc_lev_ready_franklin" );
	flag_init( "s1_cc_lev_use" );
	flag_init( "s1c_reached_command_room" );
	flag_init( "s1_command_train_begin" );
	flag_init( "cc_open_airlock" );
	
	// Station 1 - COMPLETE!
	flag_init( "s1_station_complete" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

platform_tower_objectives( objective_num )
{
	// objectives go here

	return objective_num;
}

station_1_objectives( objective_num )
{
	// enter the command room
	flag_wait( "s1_under_tracks_done" );
	objective_complete( objective_num );
	objective_num++;

	// Open CC Elevator
	objective_add( objective_num, "current", &"NX_LAVA_OBJECTIVE_S1_EXPLORE_COMMAND" );
	waypoint = getStruct( "cc_lev_open_objective", "targetname" );
	objective_position( objective_num, waypoint.origin );
	
	// Use CC Elevator
	flag_wait( "s1_cc_lev_open" );
	objective_clearAdditionalPositions( objective_num );
	waypoint = getStruct( "cc_lev_first_objective", "targetname" );
	objective_position( objective_num, waypoint.origin );
	
	// Go into the command center
	return objective_num;
}

s1_command_center_objectives( objective_num )
{
	
	// Continue exploring (follow baker)
	flag_wait( "s1_cc_lev_use" );
	objective_clearAdditionalPositions( objective_num );
	objective_onEntity( objective_num, level.baker, (0, 0, 74) );
	
	// Station 1 complete... run to the train!
	flag_wait( "s1_station_complete" );
	objective_complete( objective_num );
	objective_num++;
	
	// Come on, ride the train.
	return objective_num;
}


//*******************************************************************
//	Station 1 - Main Logic                                          *
//                                                                  *
//*******************************************************************

platform_tower_start()
{
	// spawn and teleport allies
	maps\nx_lava_util::lava_ally_spawn( "station_1_plat_start" );

	// setup and teleport player
	maps\nx_lava_util::player_start( "station_1_plat_player_start" );

	// init elevator
	flag_set( "op_s1_lift_baker" );
	flag_set( "op_s1_lift_tilman" );
	flag_set( "op_s1_lift_franklin" );

	// set initial vision and fog for this checkpoint.
	thread maps\nx_lava_fx::set_vision_and_fog("garage", 0);
}

platform_tower()
{
	autosave_by_name( "platform_tower" );
	
	//**********************************************
	// Setup
	
	// Setup allies
	level.baker disable_cqbwalk();
	level.tilman disable_cqbwalk();
	level.franklin disable_cqbwalk();
	
	// Setup train
	maps\nx_lava_util::setup_train_vehicles( level.e_train, false );
		
	foreach( train in level.e_train )
	{
		train maps\_nx_moving_platform::platform_process_all_elements( "show" );
	}
	

	//**********************************************
	// Pre-Platform
	level thread s1_move_lavatube_elevator();

	//**********************************************
	// Platform Battle - Lift
	flag_wait( "s1p_lift_almost_down" );
	s1_platform_cleanup();
	autosave_by_name( "platform_tower_battle" );
	self thread start_lift_battle();

	//**********************************************
	// Platform Battle - Lift Jump

	flag_wait( "s1p_player_near_lift_jump" );
	self thread prep_5th_battle();

	//**********************************************
	// Platform Battle - 5th
	flag_wait( "s1p_player_jump_lift" );
	self start_5th_battle(); 
	
	// note: start_5th_battle isn't threaded... no man left behind
	flag_wait( "s1p_player_jump_5th" );
	self thread escalate_5th_battle();
	self thread start_3rd_lift();

	//**********************************************
	// Platform Battle - 4th
	self thread start_4th_battle();
	
	flag_wait( "s1p_player_jump_4th" );
	self thread escalate_4th_battle();

	//**********************************************
	// Platform Battle - 3rd
	self thread start_3rd_battle();

	flag_wait( "s1p_player_jump_3rd" );
	self thread escalate_3rd_battle();

	//**********************************************
	// Platform Battle - Exit
	flag_wait( "s1p_kill_3rd_bad" );
	self thread exit_platform_tower();
	
	flag_wait( "s1_tracks_begin" );
}

station_1_start()
{
	// spawn and teleport allies
	maps\nx_lava_util::lava_ally_spawn( "station_1_start" );
	level.franklin forceUseWeapon( "lunar_sniper_l3", "primary" );
	
	// move train to spawn spot
	maps\nx_lava_util::setup_train_vehicles( level.e_train, false );	
	
	foreach( train in level.e_train )
	{
		train maps\_nx_moving_platform::platform_process_all_elements( "show" );
	}
	
	level.e_train reset_s1_train();

	// setup and teleport player
	maps\nx_lava_util::player_start( "station_1_player_start" );

	// set initial vision and fog for this checkpoint.
	thread maps\nx_lava_fx::set_vision_and_fog("garage", 0);

	thread audio_train_pass();
}

station_1()
{
	autosave_by_name( "station_1" );
	

	//**********************************************
	// Under Tracks

	// set up ally colors
	level thread s1_setup_tracks_allies(); // TEMP TEMP - Need traversal to tracks

	// spawn shotguns & snipers
	level thread spawn_tracks_frontline();
	level thread spawn_catwalk();

	// spawn tracks jumpers & ar roll
	flag_wait( "s1_player_jump_tracks" );
	level thread s1_to_tracks_franklin();
	level thread spawn_tracks_jumper();
	level thread spawn_catwalk_w2();
	
	// wait till snipers stuff is dead
	level thread spawn_tracks_ar_roll();
	
	// player advances to find
		// rear def - not added yet!
		// cc rollout
	
	// get under-tracks train ready
	// in "spawn_tracks_jumper()"

	//**********************************************
	// Command Center - 1st floor
	
	// go to the command center
	flag_wait( "s1_under_tracks_done" );
	level thread s1_goto_cc();
	level thread s1_cc_lower_lev();
	
	// open and use the elevator / air lock
	s1_cc_open_lev_use();
	s1_cc_use_lev_use();
}

s1_command_center_start()
{
	// teleport command center elevator to start point
	s1_teleport_cc_lev();
	
	// spawn and teleport allies
	maps\nx_lava_util::lava_ally_spawn( "s1_cc_start" );

	// setup and teleport player
	maps\nx_lava_util::player_start( "s1_cc_player_start" );
	
	// move elevator
	trig = GetEnt( "cc_lev_first_trig", "targetname" );
	trig trigger_off();
	wait( 0.2 );
	s1_cc_move_lev();
}

s1_command_center()
{
	flag_wait( "s1c_reached_command_room" );
	autosave_by_name( "s1_command_center" );
	
	// start the command room scene
	s1_command_room_scene();
	
	// move allies into airlock
	thread s1c_goto_airlock();
	
	// trigger airlock vignette
	flag_wait( "s1c_player_in_airlock" );
	
	// leave the command center airlock
	s1c_leave_airlock();
	
	
	//**********************************************
	// Station 1 - COMPLETE!

	// clean up train
	if( IsDefined( level.e_train[0].vehicle ) )
		thread maps\nx_lava_util::delete_train( level.e_train );

	// once the vignette is done... station one is finished
	level.keene = level.baker; // tagBM<Hack> - TEMP TEMP - baker is referenced as keen on Train_1
	level.keene.animname = "keene"; // tagBM<Hack> - TEMP TEMP - baker is referenced as keen on Train_1
	flag_set( "s1_station_complete" );
}


//*******************************************************************
//	Lava Tube Elevator                                              *
//                                                                  *
//*******************************************************************

s1_move_lavatube_elevator()
{
	// Elevator button actioned
	battlechatter_off();

	// Lavatube elevator ents
	lavatube_elevator_trigger = GetEnt( "lavatube_elevator_trigger", "targetname" );
	lavatube_elevator_target_01 = GetEnt( "lavatube_elevator_target_01", "targetname" );
	lavatube_elevator_target_02 = GetEnt( "lavatube_elevator_target_02", "targetname" );
	lavatube_elevator = GetEnt( "lavatube_elevator", "targetname" );
	lavatube_elevator_linkers = GetEntArray( "lavatube_elevator_link", "targetname" );

	// Lavatube main door elevator ents
	lavatube_main_door_l1 = GetEnt( "main_lava_tube_elevator_door_l1", "targetname" );
	lavatube_main_door_l2 = GetEnt( "main_lava_tube_elevator_door_l2", "targetname" );
	lavatube_main_door_r1 = GetEnt( "main_lava_tube_elevator_door_r1", "targetname" );
	lavatube_main_door_r2 = GetEnt( "main_lava_tube_elevator_door_r2", "targetname" );

	// Lavatube top door elevator ents
	lavatube_top_door_l = GetEnt( "top_lava_tube_elevator_door_l", "targetname" );
	lavatube_top_door_r = GetEnt( "top_lava_tube_elevator_door_r", "targetname" );

	// Lavatube bottom door elevator ents
	lavatube_bottom_door_l = GetEnt( "bottom_lava_tube_elevator_door_l", "targetname" );
	lavatube_bottom_door_r = GetEnt( "bottom_lava_tube_elevator_door_r", "targetname" );

	// Open the top door
	wait( 0.5 );
	lavatube_top_door_l MoveX( -352, 7, .5, .2 );
	lavatube_top_door_r MoveX( 352, 7, .5, .2 );

	// Close the main door
	lavatube_main_door_l1 MoveX( 356, 5, 0.5, 0.2 );
	lavatube_main_door_r1 MoveX( -356, 5, 0.5, 0.2 );
	wait( 2.5 );
	lavatube_main_door_l2 MoveX( 178, 2.5, 0.1, 0.2 );
	lavatube_main_door_r2 MoveX( -178, 2.5, 0.1, 0.2 );
	wait( 2.5 );

	// Move the elevator
	foreach( linker in lavatube_elevator_linkers )
	{
		linker LinkTo( lavatube_elevator );
	}

	level.baker linkTo( lavatube_elevator );
	level.tilman linkTo( lavatube_elevator );
	level.franklin linkTo( lavatube_elevator );

	wait( 1.0 );

	thread maps\nx_lava_fx::set_vision_and_fog("station1", 6.0); // transition to new vision
	
	// Start moving elevator down to shaft dock
	lavatube_elevator MoveTo( lavatube_elevator_target_01.origin, 25.0, 2.0, 2.0 );
	lavatube_elevator PlaySound( "scn_lava_lift02" );

	wait( 4 );
	// Close the top door
	lavatube_top_door_l MoveX( 352, 7, .5, .2 );
	lavatube_top_door_r MoveX( -352, 7, .5, .2 );

	wait( 7 );
	// open bottom door
	lavatube_bottom_door_l MoveX( -352, 7, .5, .2 );
	lavatube_bottom_door_r MoveX( 352, 7, .5, .2 );
	
	// start station 1 hustle and bustle
	level thread s1_ground_flair();
	level thread s1_lavatube_elevator_dialog();
	
	// give franklin a sniper rifle
	level.franklin forceUseWeapon( "lunar_sniper_l3", "primary" );

	// Close bottom door
	wait( 12 );
	lavatube_bottom_door_l MoveX( 352, 7, .5, .2 );
	lavatube_bottom_door_r MoveX( -352, 7, .5, .2 );
	
	// Wait for elevator to reach destination 1
	wait( 2 );

	// Hold at rail change
	wait( 1 );

	// Reached shaft dock, move down to elevator shaft
	lavatube_elevator MoveTo( lavatube_elevator_target_02.origin, 3.5, 0.5, 0.2 );

	flag_set( "s1p_lift_almost_down" );
	
	// turn on battlechatter and save
	battlechatter_on( "allies" );

	// Wait for elevator to reach destination 2
	wait( 3.5 );

	level.baker unlink();
	level.tilman unlink();
	level.franklin unlink();
	flag_set( "s1p_lift_down" );
}

s1_ground_flair()
{
	// Crane and forklifts
	thread maps\nx_lava_anim::underground_reveal();
	
	// move east train
	level.e_train train_switch_target( "s1_eTrain" );
	thread maps\nx_lava_util::move_train( level.e_train, 100, 1000, 500 );
	thread maps\nx_lava_fx::cargo_train_rego_fx();
}

s1_lavatube_elevator_dialog()
{
	wait( 1.5 );
	level.baker radio_dialogue( "lava_kee_station1_holyshit" );					// dialog: "...holy shit..."
	wait( 0.5 );
	level.baker radio_dialogue( "lava_kee_station1_miningtracks" );			// dialog: "Who knows how big this thing is!"
	wait( 1 );
	level.baker radio_dialogue( "lava_kee_station1_canyoureadme" );				// dialog: "Base!? Can you read me, base?! -shit... nothing..."
}

s1_platform_cleanup()
{
	// clean up garage vehicle
	if( IsDefined( level.op_sub_vehicle ) )
		level.op_sub_vehicle delete();
}


//*******************************************************************
//	Platform Battle                                                 *
//                                                                  *
//*******************************************************************

start_lift_battle()
{
	// Elevator finished decent
	
	// spawn lift baddies
	self thread maps\nx_lava_util::spawn_group_by_name( "s1p_lift_bad_spawner" );

	// Jump lift and move to cover
	thread maps\nx_lava_anim::scaffold_jump_baker();
	thread maps\nx_lava_anim::scaffold_jump_tilman();
	thread maps\nx_lava_anim::scaffold_jump_franklin();

	flag_set( "s1p_jump_managed" );

	// lower accuracy until the player jumps
	if( !flag( "s1p_player_jump_lift" ) )
	{
		level.baker thread set_baseaccuracy( .1 );
		level.tilman thread set_baseaccuracy( .1 );
		level.franklin thread set_baseaccuracy( .1 );
	}
}

prep_5th_battle()
{
	// Player has walked near the jump zone

	// spawn 6th & 5th bad
	self thread maps\nx_lava_util::spawn_group_by_name( "s1p_6th_bad_spawner" );
	self thread maps\nx_lava_util::spawn_group_by_name( "s1p_5th_bad_spawner" );
}


start_5th_battle()
{
	// Player jumps over lift chute
	
	// spawn 6th -> 5th jump down
	self thread maps\nx_lava_util::spawn_group_by_name( "s1p_5th_jump_spawner" );

	// baker and Tilman raise accuracy
	level.baker thread set_baseaccuracy( 1 );
	level.tilman thread set_baseaccuracy( 1 );
	level.franklin thread set_baseaccuracy( 1 );

	// baker moves on 5th
	flag_wait( "s1p_jump_managed" );
	if( !flag( "s1p_player_jump_5th" ) )
	{
		wait( 1 );
		level.baker set_force_color( "c" );
	}
}

escalate_5th_battle()
{
	// Player jumps to 5th floor

	// move Tilman to 5th
	level.tilman set_force_color( "b" );
	
	// move baker to 4th (lower accuracy)
	wait( randomFloatRange( 0.2, 0.7 ) );
	level.baker disable_ai_color();
	node = getNode( "s1p_4th_floor_baker", "targetname" );
	level.baker thread follow_path( node );
	level.baker thread set_baseaccuracy( .5 );
	
	// wait and spawn 4th enemies
	wait( 2 );
	self thread maps\nx_lava_util::spawn_group_by_name( "s1p_4th_bad_spawner", "targetname", 1.0 );
}

start_4th_battle()
{
	flag_wait( "s1p_kill_5th_bad" );

	if( !flag( "s1p_player_jump_4th" ) )
	{
		// spawn 4th enemies
		self thread maps\nx_lava_util::spawn_group_by_name( "s1p_4th_bad_spawner", "targetname", 1.0 );

		// move Tilman to 4th (lower accuracy)
		level.tilman disable_ai_color();
		node = getNode( "s1p_4th_floor_tilman", "targetname" );
		level.tilman thread follow_path( node );
		level.tilman thread set_baseaccuracy( .5 );

		// move Franklin to 5th
		wait( randomFloatRange( 0.2, 0.7 ) );
		level.franklin disable_ai_color();
		node = getNode( "s1p_5th_floor_franklin", "targetname" );
		level.franklin thread follow_path( node );
	}
}

escalate_4th_battle()
{
	// player jumps to 4th floor
	
	// spawn 4th enemies
	self thread maps\nx_lava_util::spawn_group_by_name( "s1p_4th_bad_spawner", "targetname" );
	
	// move Tilman (4th) and baker(3rd)
	level.tilman set_force_color( "b" );
	level.tilman thread set_baseaccuracy( 1 );
	wait( randomFloatRange( 0.2, 0.7 ) );
	level.baker disable_ai_color();
	node = getNode( "s1p_3rd_floor_baker", "targetname" );
	level.baker thread follow_path( node );
	level.baker thread set_baseaccuracy( .5 );

	// move Franklin to 5th
	wait( randomFloatRange( 0.2, 0.7 ) );
	level.franklin disable_ai_color();
	node = getNode( "s1p_5th_floor_franklin", "targetname" );
	level.franklin thread follow_path( node );
}

start_3rd_lift()
{
	// move lift down
	lift = GetEnt( "lavatube_elevator", "targetname" );
	lift_target = GetEnt( "lift_bottom_target", "targetname" );
	lift MoveTo( lift_target.origin, 12.0, 1.0, 2.0 );
	// lift PlaySound( "scn_lava_lift02" );

	// wait for lift to reach ground floor
	wait( 12 );

	// spawn enemies
	maps\nx_lava_util::spawn_group_by_name( "s1p_3rd_bad_spawner" );

	// link enemies
	baddies = get_ai_group_ai( "s1p_3rd_bad" );
	foreach( baddie in baddies )
	{
		baddie linkTo( lift );
	}

	// raise the lift
	lift_target = GetEnt( "lift_mid_target", "targetname" );
	lift MoveTo( lift_target.origin, 5.0, 1.0, 2.0 );

	// move out
	wait( 5 );
	baddies = get_ai_group_ai( "s1p_3rd_bad" );
	foreach( baddie in baddies )
	{
		baddie unLink();
	}
}

start_3rd_battle()
{
	flag_wait( "s1p_kill_4th_bad" );

	if( !flag( "s1p_player_jump_3rd" ) )
	{
		// Move allies to 3rd
		level.tilman disable_ai_color();
		node = getNode( "s1p_3rd_sneak_tilman", "targetname" );
		level.tilman thread follow_path( node );
	
		level.franklin disable_ai_color();
		node = getNode( "s1p_4th_floor_franklin", "targetname" );
		level.franklin thread follow_path( node );
	}
}

escalate_3rd_battle()
{
	// move tilman
	level.tilman set_force_color( "b" );
	
	// move baker (up accuracy)
	level.baker set_force_color( "c" );
	level.baker thread set_baseaccuracy( 1 );
	
	// give franklin gun and move
	level.franklin forceUseWeapon( "lunarrifle", "primary" );
	wait( 1 );
	level.franklin set_force_color( "o" );
}

exit_platform_tower()
{
	// move allies
	level.baker disable_ai_color();
	node = getNode( "s1p_leave_baker", "targetname" );
	level.baker thread follow_path( node );
	level.baker thread radio_dialogue( "lava_kee_station1_keepmoving" );				// dialog: "Keep moving!"

	level.franklin forceUseWeapon( "lunar_sniper_l3", "primary" );
	level.franklin disable_ai_color();
	node = getNode( "s1p_leave_franklin", "targetname" );
	level.franklin thread follow_path( node );
	
	flag_wait( "s1p_exit_jump_tilman" );
	maps\nx_lava_anim::flank_area_jump();
	level.tilman disable_ai_color();
	node = getNode( "s1p_leave_tilman", "targetname" );
	level.tilman thread follow_path( node );
}


//*******************************************************************
//	Under Tracks                                                    *
//                                                                  *
//*******************************************************************
spawn_tracks_frontline()
{
	self maps\nx_lava_util::spawn_group_by_name( "s1_tracks_frontline_spawner" );
	
	// spawn fronline wave 2 once 1 dude is killed
	waittill_aigroupsentientcount( "s1_tracks_frontline", 3);
	spawn_tracks_frontline_w2();
}

spawn_catwalk()
{
	self thread maps\nx_lava_util::spawn_group_by_name( "s1_catwalk_sniper_w1" );

	wait( 6 );
	self thread maps\nx_lava_util::queue_next_flag( "s1_tracks_spawn_ar_roll", "s1_catwalk_sniper", 3);
}

spawn_tracks_frontline_w2()
{
	if( !flag( "s1_player_jump_tracks" ) )
	{
		self thread maps\nx_lava_util::spawn_group_by_name( "s1_tracks_frontline_w2_spawner" );
		
		wait( 4 );
		s1_prompt_jumpdown();
	}
}

spawn_catwalk_w2()
{
	self thread maps\nx_lava_util::spawn_group_by_name( "s1_catwalk_sniper_w2", "targetname", 2 );
}

s1_prompt_jumpdown()
{
	// wait till only 7 guys on the floor
	waittill_aigroupsentientcount( "s1_tracks_frontline", 5 );
	
	// move franklin
	if( !flag( "s1_player_jump_tracks" ) )
	{
		level.franklin disable_ai_color();
		node = getNode( "s1_tracks_jump_franklin", "targetname" );
		
		level.franklin forceUseWeapon( "lunarrifle", "primary" );
		wait( 1 );
		
		level.franklin thread follow_path( node );
	}
	
	// call for player
	while( !flag( "s1_player_jump_tracks" ) )
	{
		if( RandomInt( 100 ) >= 50 )
			level.baker radio_dialogue( "lava_kee_station1_letsmove" );
		else
			level.baker radio_dialogue( "lava_kee_station1_keepmoving" );
		
		wait( RandomIntRange( 4, 8 ) );
	}
}

s1_to_tracks_franklin()
{
	if( level.franklin.primaryweapon != "lunarrifle" )
	{
		level.franklin forceUseWeapon( "lunarrifle", "primary" );
	}
	
	level.franklin set_force_color( "o" );
}

spawn_tracks_jumper()
{
	// move train to spawn spot
	level.e_train reset_s1_train();
	wait( .2 );

	// make sure frontline reinforcements are dead / not spawned
	waittill_aigroupsentientcount( "s1_tracks_frontline", 4);
	
	// spawn enemies
	self maps\nx_lava_util::spawn_group_by_name( "s1_tracks_jumper_spawner" );
	train_baddies = get_ai_group_ai( "s1_tracks_jumper" );
	
	// link baddies
	foreach( baddie in train_baddies )
	{
		baddie linkTo( level.e_train[2].vehicle );
	}

	// move train into station 1
	level.e_train train_switch_target( "s1_mTrain" );
	maps\nx_lava_util::move_train( level.e_train, 100, 1000, 30 );
	thread maps\nx_lava_fx::cargo_train_rego_fx();

	// unlink baddies
	level.e_train[0].vehicle waittill( "reached_end_node" );
	foreach( baddie in train_baddies )
	{
		baddie unlink();
	}
	
	wait( 2 );
	level.baker thread radio_dialogue( "lava_kee_station1_hostilestrain" );				// dialog: "More hostiles are jumping from that train!"
	
	// wait for baddies to jump off train and leave
	wait( 8 );
	level.e_train train_switch_target( "s1_mTrain_mid" );
	thread maps\nx_lava_util::move_train( level.e_train, 100, 40, 1000 );
	thread maps\nx_lava_fx::cargo_train_rego_fx();
	// queue next train passby
	wait( 8 );
	level thread s1_ground_train_passby();
}

spawn_tracks_ar_roll()
{
	flag_wait( "s1_tracks_spawn_ar_roll" );
	self thread maps\nx_lava_util::spawn_group_by_name( "s1_tracks_ar_roll_spawner", "targetname", 1 );

	flag_wait( "s1_tracks_backtrack_ar" );
	self maps\nx_lava_util::give_aigroup_new_goal( "s1_tracks_west", "s1_tracks_ar_roll" );
}

s1_ground_train_passby()
{
	// wait till the player is under the tracks
	flag_wait( "s1_tracks_train_pass" );
	
	// move a train down the middle track
	level.e_train train_switch_target( "s1_mTrain_full" );
	maps\nx_lava_util::move_train( level.e_train, 100, 1000, 30 );
	thread maps\nx_lava_fx::cargo_train_rego_fx();
}


//*******************************************************************
//	Command Center                                                  *
//                                                                  *
//*******************************************************************

s1_goto_cc()
{
	// move allies to the command center
	level.baker disable_ai_color();
	node = getNode( "cc_first_baker", "targetname" );
	level.baker thread follow_path( node );
	level.baker thread radio_dialogue( "lava_kee_station1_letsmove" );					// dialog: "Let's move!"
	
	level.tilman disable_ai_color();
	node = getNode( "cc_first_tilman", "targetname" );
	level.tilman thread follow_path( node );

	level.franklin disable_ai_color();
	node = getNode( "cc_first_franklin", "targetname" );
	level.franklin thread follow_path( node );
}

s1_cc_lower_lev()
{
	// Command Center elevator ents
	cc_lev = GetEnt( "command_center_elevator", "targetname" );
	
	// Elevator Entry doors
	cc_lev_enter_r = GetEnt( "command_center_elevator_door_side_r", "script_noteworthy" );
	cc_lev_enter_l = GetEnt( "command_center_elevator_door_side_l", "script_noteworthy" );

	// Link elevator parts
	cc_lev_linkers = GetEntArray( "command_center_elevator_link", "targetname" );
	foreach( linker in cc_lev_linkers )
	{
		linker LinkTo( cc_lev );
	}

	// lower the elevator
	cc_lev MoveZ( -264, 8, .05, 1 );
	wait( 8 );

	// open lev doors & announce ready
	cc_lev_enter_r unlink();
	cc_lev_enter_l unlink();
	flag_set( "s1_cc_lev_ready" );
}

s1_cc_open_lev_use()
{
	// Wait for player to use lev
	use = GetEnt( "cc_lev_open_trig", "targetname" );
	use sethintstring( &"NX_LAVA_S1_OPEN_CC_LEV" );		

	use waittill( "trigger" );
	use trigger_off();
	
	// Wait for elevator to reach the ground floor
	flag_wait( "s1_cc_lev_ready" );

	// Elevator Entry doors
	cc_lev_enter_r = GetEnt( "command_center_elevator_door_side_r", "script_noteworthy" );
	cc_lev_enter_l = GetEnt( "command_center_elevator_door_side_l", "script_noteworthy" );

	// First Floor Interior Doors 
	cc_lev_first_r = GetEnt( "command_center_door_r", "script_noteworthy" );
	cc_lev_first_l = GetEnt( "command_center_door_l", "script_noteworthy" );

	// open lev doors
	cc_lev_first_r MoveX( 44, 3, .05, .5 );
	cc_lev_first_l MoveX( -44, 3, .05, .5 );
	wait( 0.5 );
	cc_lev_enter_r MoveX( 44, 3, .05, .5 );
	cc_lev_enter_l MoveX( -44, 3, .05, .5 );
	wait( 2 );
	
	// connect paths and move allies
	cc_lev_enter_r ConnectPaths();
	cc_lev_enter_l ConnectPaths();
	cc_lev_first_r ConnectPaths();
	cc_lev_first_l ConnectPaths();
	thread s1_goto_cc_lev();

	flag_set( "s1_cc_lev_open" );
}

s1_goto_cc_lev()
{
	// enable CQB
	level.baker enable_cqbwalk();
	level.tilman enable_cqbwalk();
	level.franklin enable_cqbwalk();
	
	// move allies to elevator
	level.baker disable_ai_color();
	node = getNode( "cc_lev_baker", "targetname" );
	level.baker thread follow_path( node );
	level.baker thread s1_cc_lev_ready_check( "baker" );
	
	level.tilman disable_ai_color();
	node = getNode( "cc_lev_tilman", "targetname" );
	level.tilman thread follow_path( node );
	level.tilman thread s1_cc_lev_ready_check( "tilman" );

	level.franklin disable_ai_color();
	node = getNode( "cc_lev_franklin", "targetname" );
	level.franklin thread follow_path( node );
	level.franklin thread s1_cc_lev_ready_check( "franklin" );
}

s1_cc_lev_ready_check( name )
{
	self waittill( "reached_path_end" );
	flag_set( "cc_lev_ready_" + name );
}

s1_cc_use_lev_use()
{
	// Wait for player to use lev
	use = GetEnt( "cc_lev_first_trig", "targetname" );
	use sethintstring( &"NX_LAVA_S1_USE_CC_LEV" );		

	use waittill( "trigger" );
	use trigger_off();
	flag_set( "s1_cc_lev_use" );
	
	// wait for allies
	flag_wait( "cc_lev_ready_baker" );
	flag_wait( "cc_lev_ready_tilman" );
	flag_wait( "cc_lev_ready_franklin" );
	
	// Elevator Entry doors
	cc_lev_enter_r = GetEnt( "command_center_elevator_door_side_r", "script_noteworthy" );
	cc_lev_enter_l = GetEnt( "command_center_elevator_door_side_l", "script_noteworthy" );

	// First Floor Interior Doors 
	cc_lev_first_r = GetEnt( "command_center_door_r", "script_noteworthy" );
	cc_lev_first_l = GetEnt( "command_center_door_l", "script_noteworthy" );

	// close lev doors
	cc_lev_first_r MoveX( -44, 3, .05, .5 );
	cc_lev_first_l MoveX( 44, 3, .05, .5 );
	wait( 0.5 );
	cc_lev_enter_r MoveX( -44, 3, .05, .5 );
	cc_lev_enter_l MoveX( 44, 3, .05, .5 );
	wait( 3 );

	// move elevator
	self s1_cc_move_lev();
}

s1_cc_move_lev()
{
	// Command Center elevator ents
	cc_lev = GetEnt( "command_center_elevator", "targetname" );

	// Elevator Exit doors
	cc_lev_exit_r = GetEnt( "command_center_elevator_door_r", "script_noteworthy" ); 
	cc_lev_exit_l = GetEnt( "command_center_elevator_door_l", "script_noteworthy" );

	// Top Floor Interior Doors 
	cc_lev_top_r = GetEnt( "command_center_top_door_r", "script_noteworthy" );
	cc_lev_top_l = GetEnt( "command_center_top_door_l", "script_noteworthy" );

	cc_lev_linkers = GetEntArray( "command_center_elevator_link", "targetname" );

	// Link elevator parts
	foreach( linker in cc_lev_linkers )
	{
		linker LinkTo( cc_lev );
	}

	// Pressurize the elevator
	thread audio_pressurize();

	// Move the elevator
	level.baker linkTo( cc_lev );
	level.tilman linkTo( cc_lev );
	level.franklin linkTo( cc_lev );

	// actually move the elevator
	cc_lev MoveZ( 264, 10, .05, 1 );
	wait( 10 );

	// open lev doors
	cc_lev_exit_r unlink();
	cc_lev_exit_l unlink();
	cc_lev_exit_r MoveY( -44, 3, .05, .5 );
	cc_lev_exit_l MoveY( 44, 3, .05, .5 );
	wait( 0.5 );
	cc_lev_top_r MoveY( 44, 3, .05, .5 );
	cc_lev_top_l MoveY( -44, 3, .05, .5 );
	wait( 2 );

	// unlink allies
	level.baker unlink();
	level.tilman unlink();
	level.franklin unlink();
	
	// connect paths
	cc_lev_exit_r ConnectPaths();
	cc_lev_exit_l ConnectPaths();
	cc_lev_top_r ConnectPaths();
	cc_lev_top_l ConnectPaths();
	
	// anounce your entrance
	flag_set( "s1c_reached_command_room" );
}

s1_teleport_cc_lev()
{
	// Command Center elevator ents
	cc_lev = GetEnt( "command_center_elevator", "targetname" );
	cc_lev_target = GetEnt( "s1_cc_lev_start_org", "targetname" );

	// Elevator Exit doors
	cc_lev_exit_r = GetEnt( "command_center_elevator_door_r", "script_noteworthy" ); 
	cc_lev_exit_l = GetEnt( "command_center_elevator_door_l", "script_noteworthy" );

	// Top Floor Interior Doors
	cc_lev_top_r = GetEnt( "command_center_top_door_r", "script_noteworthy" );
	cc_lev_top_l = GetEnt( "command_center_top_door_l", "script_noteworthy" );

	cc_lev_linkers = GetEntArray( "command_center_elevator_link", "targetname" );

	// Link elevator parts
	foreach( linker in cc_lev_linkers )
	{
		linker LinkTo( cc_lev );
	}

	// actually move the elevator
	cc_lev.origin = cc_lev_target.origin;
}

s1_command_room_scene()
{
	// send allies to their respective locations
	thread maps\nx_lava_anim::camren_sacrific_idle();
	node = getNode( "s1c_open_airlock_baker", "targetname" );
	level.baker thread follow_path( node );
	node = getNode( "s1c_open_airlock_franklin", "targetname" );
	level.franklin thread follow_path( node );
	
	thread command_room_scene_dialog();
	
	// wait for baker to get to airlock doors
	level.baker waittill( "reached_path_end" );

	flag_wait( "cc_open_airlock" );
	
	// get airlock doors
	right_door = GetEnt( "command_center_airlock_door_interior_r", "script_noteworthy" );
	left_door = GetEnt( "command_center_airlock_door_interior_l", "script_noteworthy" );

	// open airlock doors
	right_door MoveX( -36, 3, .05, .5 );
	left_door MoveX( 36, 3, .05, .5 );
	wait( 3 );
	right_door ConnectPaths();
	left_door ConnectPaths();
}

s1c_goto_airlock()
{
	// move allies to the command center
	level.baker disable_ai_color();
	node = getNode( "s1c_airlock_baker", "targetname" );
	level.baker thread follow_path( node );

	level.franklin disable_ai_color();
	node = getNode( "s1c_airlock_franklin", "targetname" );
	level.franklin thread follow_path( node );
	
	// close doors during vignette
	flag_wait( "s1c_player_in_airlock" );
	wait( 1 );
	
	// get airlock doors
	right_door = GetEnt( "command_center_airlock_door_interior_r", "script_noteworthy" );
	left_door = GetEnt( "command_center_airlock_door_interior_l", "script_noteworthy" );
	
	// close doors
	right_door MoveX( 36, 3, .05, .5 );
	left_door MoveX( -36, 3, .05, .5 );

	thread audio_depressurize();
	
}

s1c_leave_airlock()
{
	// move baker to door
	node = getNode( "s1c_leave_airlock_baker", "targetname" );
	level.baker thread follow_path( node );
	
	level.baker waittill( "reached_path_end" );
	
	// get airlock doors
	right_door = GetEnt( "command_center_airlock_door_exterior_r", "script_noteworthy" );
	left_door = GetEnt( "command_center_airlock_door_exterior_l", "script_noteworthy" );

	// open airlock doors
	right_door MoveX( 28, 3, .05, .5 );
	left_door MoveX( -28, 3, .05, .5 );
	wait( 3 );
	right_door ConnectPaths();
	left_door ConnectPaths();
	
	flag_set( "s1_command_train_begin" );
}

command_room_scene_dialog()
{
	wait( 1 );
	level.tilman radio_dialogue( "lava_cam_st1cmd_clear" );							// dialog: "Clear"
	wait( 0.5 );
	level.baker radio_dialogue( "lava_bak_st1cmd_clear" );							// dialog: "Clear"
	
	wait( 1.5 );
	level.baker radio_dialogue( "lava_bak_st1cmd_makeitquick" );					// dialog: "make it quick. Snakes'll be here any minute"
	wait( 0.5 );
	level.tilman radio_dialogue( "lava_cam_st1cmd_camera3" );						// dialog: "Check it out, boss. Camera three."
	
	wait( 1 );
	level.baker radio_dialogue( "lava_bak_st1cmd_warhead" );						// dialog: "He's still carrying the warhead"
	level.tilman radio_dialogue( "lava_cam_st1cmd_fewklicks" );						// dialog: "That station's a few clicks from here."
	
	wait( 0.5 );
	level.baker radio_dialogue( "lava_bak_st1cmd_wtfkeene" );						// dialog: What the fuck are you up to, Keene?"
	
	wait( 1.5 );
	level.tilman radio_dialogue( "lava_cam_st1cmd_inluck" );						// dialog: "We're in luck. There's another train headed for this station. I should be able to reroute it from here."
	level.baker radio_dialogue( "lava_bak_st1cmd_eta" );							// dialog: "What's the ETA on the train?"
	level.tilman radio_dialogue( "lava_cam_st1cmd_60sec" );							// dialog: "60 seconds, give or take."
	level.baker radio_dialogue( "lava_bak_st1cmd_notgoingtomakeit" );				// dialog: "We're not going to make it."

	// Queue to open the airlock
	flag_set( "cc_open_airlock" );
	
	level.tilman radio_dialogue( "lava_cam_st1cmd_stayandprogram" );				// dialog: "You will. If you leave now. I'll stay here and program the new route."
	
	wait( 1.0 );
	level.tilman radio_dialogue( "lava_cam_st1cmd_sortkeene" );						// dialog: "Just promise me you'll sort Keene. Slot that two-faced bastard for me... then finish this."
	
	wait( 1 );
	level.baker radio_dialogue( "lava_bak_st1cmd_seeyoucam" );						// dialog: "See you around, Cameron"
	wait( 0.5 );
	level.baker radio_dialogue( "lava_bak_st1cmd_charliemike" );					// dialog: "We're Charlie Mike."
	wait( 0.5 );
	level.tilman radio_dialogue( "lava_bak_st1cmd_cheerupmate" );					// dialog: "Cheer up, mate. I'll save you a bar stool in hell."
	
}


//*******************************************************************
//	ALLIES & ENEMIES                                                *
//                                                                  *
//*******************************************************************

setup_spawners()
{
	spawners = GetEntArray( "s1p_enemy_spawner", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, maps\nx_lava_util::l3_enemy_common );

	spawners = GetEntArray( "s1_enemy_spawner", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, maps\nx_lava_util::l3_enemy_common );
}

s1_setup_tracks_allies()
{
	level.baker set_force_color( "c" );
	level.tilman set_force_color( "b" );
	level.franklin set_force_color( "o" );
}

//*******************************************************************
//	TRAINS			                                                *
//                                                                  *
//*******************************************************************

// function takes a train with base name [t_name] and returns a train array
// in max your train should be named as such:
// car models:	t_name_0, t_name_1, etc...
// vehicles:	t_name_v0, t_name_v1, etc...
setup_train_by_name( t_name )
{
	ta = []; // train array
	temp_train = getEnt( t_name + "_0", "targetname" );
	
	// build train
	while( IsDefined( temp_train ) )
	{
		ta[ ta.size ] = [ t_name + "_" + string( ta.size ), t_name + "_v" + string( ta.size ) ];
		
		temp_train = getEnt( t_name + "_" + string( ta.size ), "targetname" );
	}

	// send the train back
	return maps\nx_lava_util::setup_train_platforms( ta );
}

// take a train and switch what nodes the vehicle targets
// new target nodes should be named: target_name_start0, target_name_start1, etc...
train_switch_target( target_name )
{
	for( i=0; i < self.size; i++)
	{
		new_target = target_name + "_start" + string( i );
		self[i].vehicle.target = new_target;
	}
}

reset_s1_train()
{
	self train_switch_target( "s1_train" );
	maps\nx_lava_util::move_train( self, 10, 10, 10 );
}

//*******************************************************************
//	AUDIO					                                        *
//                                                                  *
//*******************************************************************

audio_train_pass()
{

	train_pass = spawn( "sound_emitter", ( -52273, -6772, -4086 ) );
	
	while ( !flag( "s1_station_complete" ) )
	{
		train_pass PlaySound( "emt_lava_trans_pass" ); //play sound on ent
		wait 4.5;
		train_pass moveto( ( -52396, -10372, -4086 ), 5.0, .5, .5 ); 
		wait 6.5;
		train_pass moveto( ( -51730, -11871, -4107 ), 1.0, .5, .5 );
		wait( randomFloatRange( 2, 4.5 ) );
		train_pass PlaySound( "emt_lava_trans_pass" ); //play sound on ent
		wait 4.5;
		train_pass moveto( ( -51662, -3000, -4107 ), 5.0, .5, .5 );
		wait 6.5;
		train_pass moveto( ( -52273, -6772, -4086 ), 1.0, .5, .5 ); 
		wait( randomFloatRange( 2, 4.5 ) );
	}
}

audio_pressurize()
{

	level._player playsound( "nx_lunar_pressurize" );
	
	wait 1.5;	

	thread maps\_utility::set_ambient( "nx_lava_pressurized" );	

	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_lava_pressurized", 5.5 );

	wait 3;

	level._player_helmet_loop = "amb_space_suit_null";

}

audio_depressurize()
{

	level._player playsound("nx_lunar_depressurize");

	wait 0.5;

	thread maps\_utility::set_ambient( "nx_lunar_exterior_depress" );
	
	level._player deactivatechannelvolumes( "snd_channelvolprio_pain", 5.5 );
		
	wait 0.5;

	level._player_helmet_loop = "amb_space_suit_amb";

}