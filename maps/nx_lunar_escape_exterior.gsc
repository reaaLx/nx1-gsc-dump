//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_LUNAR Exterior Escape Mission Script						**
//                                                                          **
//    Created: 2/24/2010 - Daryl Kimoto										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_utility_code;
#include maps\_nx_objective_util;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
//#include maps\_stealth_utility;


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main()
{
//  maps\_stealth::main();
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

mission_flag_inits()
{
	flag_init( "rover_battle_start" );
	flag_init( "rover_turret_cooling" );
	flag_init( "into_shadows_gunner_1_enemy_dead" );
	flag_init( "into_shadows_gunner_2_enemy_dead" );
	flag_init( "stealth_group_killed" );
	flag_init( "into_shadows_stealth_kills_success" );
	flag_init( "lsp_explosion_2_is_current" );
	flag_init( "rover_battle_enemies_aware" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

airlock_exterior_start()
{
	// Start the player and allies
	maps\nx_lunar_util::lunar_start( "airlock_exterior_start", "airlock_exterior_eagle_start", "airlock_exterior_falcon_start" );

	// Close the airlock door going back to crew
	level thread maps\nx_lunar_util::open_lunar_door( "exterior_airlock_door_1" );

	//set the sfx helemt state to the proper sound state
	flag_set( "sfx_ext_surface_milsuit_depress" );  //(after going through airloack to depresurize)

	// Open the airlock door to the exterior
	level thread maps\nx_lunar_util::open_lunar_door( "exterior_airlock_door_2" );

	// cue the vision set change for going to the exterior lunar surface.
	thread maps\nx_lunar_fx::fx_crew_module_exit_vision_change();

	// Init combat
	maps\nx_lunar_util::lunar_combat_init();
}

airlock_exterior()
{
	// Battle chatter
	battlechatter_off( "allies" );

	level.eagle pushplayer( false );
	level.falcon pushplayer( false );

	level.eagle thread airlock_exterior_ally_temporary_protection();
	level.falcon thread airlock_exterior_ally_temporary_protection();

	// Save the game
	level thread autosave_now();

	// Create effect of battle going on with magic bullets
	level thread airlock_exterior_magic_shooting();

	// Thread and spawn enemies and allies
	level thread airlock_exterior_spawns();

	flag_set( "sfx_ext_surface_milsuit_depress" );

	level.eagle thread airlock_exterior_dialog();

	// One of the enemies flanks the allies and kills a few unless the player is fast enough to kill him first
	level thread airlock_exterior_enemy_flanker();

	// Enemy and ally cleanup when down in the valley
	level thread airlock_exterior_cleanup();

	//set the flag for music to start
	//flag_set( "music_battle_exterior" );

	// Enemies run up from below
	level thread airlock_road_runner_movement();

	// Prevent traversal stacking (This carries over into the next check point)
	level thread maps\nx_lunar_util::lunar_traversal_killer_by_flag( "valley_traversal_kill_ally_trigger", "rough_terrain" );
	level thread maps\nx_lunar_util::lunar_traversal_killer_by_flag( "valley_traversal_kill_trigger", "rough_terrain" );

	// Trigger volume at valley reached
	flag_wait( "mining_valley" );
}

airlock_exterior_dialog()
{
	level endon( "mining_valley" );

	airlock_exterior_jumpdown_dialog();

	// Dialog: Go! Go! Go!
	radio_dialogue( "moon_eag_move_04" );

	flag_wait( "airlock_exit_first_step_closer" );

	flag_set( "music_battle_exterior" );

	// Approaching friendlies
	// Crow: Approaching on your six!
	radio_dialogue( "moon_eag_ext_approachingsix" );

	flag_wait( "airlock_exit_second_step_closer" );

	// Battle chatter
	battlechatter_off( "allies" );

	// Dialog: Tangos moving to cover!
	radio_dialogue( "moon_fal_ext_01" );

	wait( 1.0 );

	// Dialog: Oxygen Tanks Chatter
	radio_dialogue( "jswc_eag_co_lm_oxtnks" );

	// Dialog: Affirmative Chatter
	radio_dialogue( "jswc_fal_resp_ack_co_gnrc_affirm" );

	flag_wait( "valley_runners_spawned" );

	// Battle chatter
	battlechatter_on( "allies" );

	wait( 3.0 );

	// Dialog: Watch it! Across the chasm!
	radio_dialogue( "moon_fal_ext_03" );

	waittill_aigroupcleared( "enemy_airlock_exit" );

	wait( 1.0 );

	// Dialog: Ok - moving.
	radio_dialogue( "moon_eag_move_09" );
}

airlock_exterior_jumpdown_dialog()
{
	level endon( "airlock_exit_first_step_closer" );

	look_right_target = create_tag_origin_from_script_origin( "airlock_to_exterior_look_right" );
	look_middle_target = create_tag_origin_from_script_origin( "airlock_to_exterior_look_middle" );
	look_left_target = create_tag_origin_from_script_origin( "airlock_to_exterior_look_left" );

	SetSavedDvar( "ai_lookatblendvalue", 0.05 );

	level.falcon SetLookAtEntity( look_left_target );
	level.eagle SetLookAtEntity( look_middle_target );
	wait( 1.5 );

	level.eagle SetLookAtEntity( look_right_target );	

	// Friendlies seen.
	// Riggs: Friendlies at 3 o'clock!
	radio_dialogue( "moon_fal_ext_friendlies" );

	level.falcon SetLookAtEntity( look_right_target );	

	// Jumpin down
	// Crow: Let's give them support. Come on!
	radio_dialogue( "moon_eag_ext_givesupport" );
	
	level.eagle StopLookAt( 120 );
	level.falcon StopLookAt( 400 );

	// Turn on trigger for jump down
	exterior_vista_jump_down = GetEnt( "exterior_vista_jump_down", "targetname" );
	exterior_vista_jump_down trigger_on();

	wait( 3.0 );

	SetSavedDvar( "ai_lookatblendvalue", 0.2 );
}

create_tag_origin_from_script_origin( script_origin_name )
{
	script_origin = GetEnt( script_origin_name, "targetname" );

	tag_org = spawn_tag_origin();
	tag_org.origin = script_origin.origin;
	tag_org.angles = script_origin.angles;

	return tag_org;
}

airlock_exterior_spawns()
{
	level endon( "mining_valley" );

	level thread maps\nx_lunar_util::trigger_choice_spawn( "spawn_low_to_high" );
	level thread maps\nx_lunar_util::trigger_choice_spawn( "spawn_valley_runners" );
	level thread maps\nx_lunar_util::trigger_choice_spawn( "spawn_enemy_airlock_exit_starter" );
	level thread maps\nx_lunar_util::trigger_choice_spawn( "spawn_enemy_airlock_exit" );
	level thread maps\nx_lunar_util::trigger_choice_spawn( "spawner_road_runners" );

	array_spawn_function_targetname( "airlock_exterior_allies", maps\nx_lunar_util::lunar_ally_exterior_fleeing_fodder );
	array_spawn_function_targetname( "airlock_exterior_allies", ::airlock_exterior_ally_random_shooting );
	array_spawn_function_targetname( "airlock_exterior_allies", ::airlock_exterior_ally_temporary_protection );
	
	maps\_nx_utility::spawn_targetname_and_return_array( "airlock_exterior_allies" );
}

airlock_exterior_magic_shooting()
{
	airlock_shot_source_one = GetEnt( "airlock_to_exterior_magic_shot_source", "script_noteworthy" );
	enemy_target_array = GetEntArray( "airlock_to_exterior_enemy_target", "targetname" );

	// Fire random bullets until player moves closer
	while( !flag( "airlock_exit_first_step_closer" ) )
	{
		wait RandomFloatRange( 0.10, 0.25 );
		target_number = RandomIntRange( 0, enemy_target_array.size );
		MagicBullet( "lunarrifle", airlock_shot_source_one.origin, enemy_target_array[target_number].origin );
	}

	run_thread_on_targetname( "enemy_airlock_exit_side_runner", maps\nx_lunar_util::spawn_ai_type_check );
	maps\_nx_utility::spawn_targetname_and_return_array( "enemy_airlock_exit_side_runner" );

	living_airlock_enemies = get_ai_group_ai( "enemy_airlock_exit" );
	level thread maps\nx_lunar_util::clean_all_enemies( living_airlock_enemies );

//  wait( 2.25 );
//
//  // Dialog: Shit...
//  level.eagle thread radio_dialogue( "moon_eag_ext_03" );
//
//  wait( 2.0 );
//
//  // 11.25 seconds to this point
//  MagicBullet( "lunarrifle_silent", airlock_shot_source_two.origin, worker GetTagOrigin ("TAG_EYE") );
}

airlock_exterior_ally_random_shooting()
{
	self endon( "death" );

	ally_target_array = GetEntArray( "airlock_to_exterior_random_shot", "targetname" );

	target_number = RandomIntRange( 0, ally_target_array.size );
	target = ally_target_array[target_number];

	while( !flag( "airlock_exit_second_step_closer" ) )
	{
		wait RandomFloatRange( 2.0, 3.0 );
		target_number = RandomIntRange( 0, ally_target_array.size );
		target = ally_target_array[target_number];

		self SetEntityTarget( target );
	}

	self ClearEntityTarget( target );
}

airlock_exterior_ally_temporary_protection()
{
	if( ( self != level.eagle ) && ( self != level.falcon ) )
	{
		self magic_bullet_shield();
	}

	self.ignorerandombulletdamage = true;
	self.ignoresuppression = true;
	self.disableBulletWhizbyReaction = true;
	self disable_pain();
	
	allies_move_trigger = GetEnt( "allies_move_forward", "targetname" );
	allies_move_trigger waittill( "trigger" );

	self.ignorerandombulletdamage = false;
	self.ignoresuppression = false;
	self.disableBulletWhizbyReaction = false;
	self enable_pain();

	if( ( self != level.eagle ) && ( self != level.falcon ) )
	{
		self stop_magic_bullet_shield();
	}
}

airlock_exterior_enemy_flanker()
{
	level endon( "mining_valley" );

	airlock_allies_move_trigger = GetEnt( "allies_move_forward", "targetname" );
	airlock_allies_move_trigger waittill( "trigger" );

	// Spawn first exterior enemy
	first_exterior_enemy_spawner = GetEnt( "first_exterior_enemy", "script_noteworthy" );
	first_exterior_enemy = first_exterior_enemy_spawner spawn_ai();

	// First exterior enemy thread
	first_exterior_enemy thread first_exterior_enemy_thread();
}

first_exterior_enemy_thread()
{
	self endon( "death" );

	self thread enable_cqbwalk();

	self.baseaccuracy = 100.0;

	flag_wait( "exterior_exit_flank_killed" );

	self enable_dontevershoot();

	wait( 1.0 );

	self.baseaccuracy = 0.8;

	self disable_dontevershoot();

	first_enemy_flee_node = GetNode( "first_enemy_flee_node", "targetname" );
	self set_goal_radius( 10 );
	self SetGoalNode( first_enemy_flee_node );
}

//airlock_exterior_scripted_squad_movement()
//{
//  level endon( "mining_valley" );

//  first_exterior_ally_movement_trigger = GetEnt( "first_exterior_ally_movement_trigger", "targetname" );
//  first_exterior_ally_movement_trigger endon( "trigger" );
//

//
//  first_exterior_enemy thread airlock_exterior_enemy_surprise();

//  level.eagle.ignoreSuppression = true;
//  level.falcon.ignoreSuppression = true;
//
//  level.falcon set_goal_radius( 10 );
//  falcon_exterior_first_kill_node = GetNode( "falcon_exterior_first_kill", "targetname" );
//  level.falcon SetGoalNode ( falcon_exterior_first_kill_node );
//
//  flag_wait( "exited_the_building" );

//  issue_color_orders( "y100", "allies" );
//  issue_color_orders( "r100", "allies" );
	
//  level.eagle.shootObjective = "suppress";
//
//  level.falcon waittill( "goal" );
//
//  level.eagle.shootObjective = "normal";
//
//  level.falcon.ignoreSuppression = false;
//  level.eagle.ignoreSuppression = false;
//}

airlock_road_runner_movement()
{
	level endon( "into_the_valley" );

	level.falcon.oldbaseaccuracy = level.falcon.baseaccuracy;
	level.eagle.oldbaseaccuracy = level.eagle.baseaccuracy;

	flag_wait( "road_runners_running" );

	SetThreatBias( "player_squad", "road_runners", 300000 );
	SetThreatBias( "road_runners", "player_squad", 300000 );

	level.falcon.baseaccuracy = 10.0;
	level.eagle.baseaccuracy = 10.0;

		// Battle chatter
	battlechatter_off( "allies" );

	wait( 1.0 );

	// Dialog: Tangos low!
	radio_dialogue( "moon_eag_ext_06" );

	waittill_aigroupcleared( "road_runners" );
	
	issue_color_orders( "r130", "allies" );
	issue_color_orders( "y103", "allies" );

	level.falcon.baseaccuracy = 0.0;
	level.eagle.baseaccuracy = 0.0;

	// Dialog: They're down.
	radio_dialogue( "moon_eag_kill_low_03" );

	// Battle chatter
	battlechatter_on( "allies" );
}

airlock_exterior_cleanup()
{
	flag_wait( "into_the_valley" );

	road_runners = get_ai_group_ai( "road_runners" );
	array_thread( road_runners, maps\_nx_utility::delete_ai_not_bullet_shielded );

	enemy_airlock_exit = get_ai_group_ai( "enemy_airlock_exit" );
	array_thread( enemy_airlock_exit, maps\_nx_utility::delete_ai_not_bullet_shielded );

//  fodder_allies = get_ai_group_ai( "allies" );
//  array_thread( fodder_allies, maps\_nx_utility::delete_ai_not_bullet_shielded );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

mining_valley_start()
{
	// Start the player and allies
	maps\nx_lunar_util::lunar_start( "mining_valley_start", "mining_valley_eagle_start", "mining_valley_falcon_start" );

	level thread maps\nx_lunar_util::trigger_choice_spawn( "spawn_valley_runners" );
	
	//Init Combat
	maps\nx_lunar_util::lunar_combat_init();
	
	//Play the water treatment bink
	thread maps\nx_lunar_util::lunar_water_treatment_screen_binks();

	// Initial Vision
	thread maps\nx_lunar_fx::fx_init_vision_surface();

	spawn_trigger = GetEnt( "spawn_valley_runners", "targetname" );
	spawn_trigger notify( "trigger" );

	level.falcon.baseaccuracy = 0.0;
	level.eagle.baseaccuracy = 0.0;

	level thread maps\nx_lunar_util::lunar_traversal_killer_by_flag( "valley_traversal_kill_trigger", "rough_terrain" );
	level thread maps\nx_lunar_util::lunar_traversal_killer_by_flag( "valley_traversal_kill_ally_trigger", "rough_terrain" );
}

mining_valley()
{	
	// Save the game
	level thread autosave_by_name( "mining_valley" );
	
	thread maps\nx_lunar_util::lunar_water_treatment_screen_binks();

	// Battle chatter
	battlechatter_on( "allies" );

	// Make sure allies get into their valley positions
	level.eagle pushplayer( true );
	level.falcon pushplayer( true );

	level thread mining_valley_spawns();

	// Enemy gets pipes steaming and firing by shooting them
	level thread mining_valley_pipe_attack();

	level thread mining_valley_dialog();

	flag_wait( "rough_terrain" );
}

mining_valley_dialog()
{
	level endon( "rough_terrain" );

//  // Dialog: Walker! Keep moving!
//  radio_dialogue( "moon_eag_move_01" );

	flag_wait( "into_the_valley" );

	// Make sure allies don't push player around
	level.eagle pushplayer( false );
	level.falcon pushplayer( false );

	level.falcon.baseaccuracy = 0.5;
	level.eagle.baseaccuracy = 0.5;

	// Dialog: Watch it!
	radio_dialogue( "moon_eag_ext_19" );

	maps\nx_lunar_util::waittill_number_of_enemies_killed( 1 );

	level.falcon.baseaccuracy = 0.75;
	level.eagle.baseaccuracy = 0.75;
	
	// Dialog: He's down!
	radio_dialogue( "moon_eag_kill_yell_01" );

	maps\nx_lunar_util::waittill_number_of_enemies_killed( 3 );

	level.falcon.baseaccuracy = 1.0;
	level.eagle.baseaccuracy = 1.0;

	// Dialog: That's a kill!
	radio_dialogue( "moon_eag_kill_yell_02" );

	maps\nx_lunar_util::waittill_all_enemies_dead_or_dying();

	// Dialog: They're down!
	radio_dialogue( "moon_eag_kill_yell_03" );
}

mining_valley_spawns()
{
	level endon( "rough_terrain" );

	level thread maps\nx_lunar_util::trigger_choice_spawn( "spawn_valley_backup" );
	level thread maps\nx_lunar_util::trigger_choice_spawn( "enemy_valley_lane_runner" );

	flag_wait( "into_the_valley" );
	
	// Spawn more enemies based on the number currently alive
	wait( .05 ); // Wait for clean up first
	current_count = get_ai_group_sentient_count( "enemy_valley" );
	valley_fillers = GetEntArray( "enemy_valley_backup", "targetname" )
	run_thread_on_targetname( "enemy_valley_backup", maps\nx_lunar_util::spawn_ai_type_check );
	spawn_limit = 7 - current_count;
	maps\_nx_utility::spawn_targetname_and_return_array( "enemy_valley_backup", spawn_limit );
	
	level thread mining_valley_enemy_movement(); 
}

mining_valley_enemy_movement()
{
	level endon( "rough_terrain" );

	wait( 5.0 );

	while( !flag( "rough_terrain" ) )
	{
		issue_color_orders( "c100", "axis" );
		issue_color_orders( "o101", "axis" );

		wait RandomFloatRange( 10.0, 15.0 );		

		issue_color_orders( "c101", "axis" );
		issue_color_orders( "o100", "axis" );

		wait RandomFloatRange( 10.0, 15.0 );
	}
}

mining_valley_traversal_killer()
{
	level endon( "rough_terrain" );

	while( 1 )
	{
		level thread maps\nx_lunar_util::hide_scriptmodels_by_targetname( "valley_traversal_blocker" );	
	
		flag_wait( "valley_traversal_kill" );
	
		level thread maps\nx_lunar_util::show_scriptmodels_by_targetname( "valley_traversal_blocker" );
	
		flag_waitopen( "valley_traversal_kill" );
	}
}

mining_valley_pipe_attack()
{
	level endon( "rough_terrain" );

	valley_pipe_shooter = get_living_ai( "pipe_shooter", "script_noteworthy" );

	if( IsDefined( valley_pipe_shooter ) )
	{
		valley_pipe_shooter endon( "death" );
		valley_pipe_shooter thread mining_valley_pipe_attack_release();
		valley_pipe_shooter.ignoreme = true;
		valley_pipe_shooter.threatbias = -500000;
		valley_pipe_shooter disable_dontevershoot();
		valley_pipe_shooter.script_attackeraccuracy = 0;

		while( IsAlive( valley_pipe_shooter ) )
		{
			flag_wait( "player_near_pipes" );
			if( IsAlive( valley_pipe_shooter ) )
			{
				pipe_shooter_target = GetEnt( "pipe_shooter_target", "targetname" );
				valley_pipe_shooter SetEntityTarget( pipe_shooter_target );
				valley_pipe_shooter.ignoreme = true;
				valley_pipe_shooter.threatbias = -500000;
				wait( 1.0 );
				pipe_shooter_target = GetEnt( "pipe_shooter_target", "targetname" );
				valley_pipe_shooter ClearEntityTarget( pipe_shooter_target );
				valley_pipe_shooter.favoriteenemy = level._player;
			}
			flag_waitopen( "player_near_pipes" );

			if( IsAlive( valley_pipe_shooter ) )
			{
				valley_pipe_shooter.script_attackeraccuracy = 0.5;
				pipe_shooter_target = GetEnt( "pipe_shooter_target", "targetname" );
				valley_pipe_shooter ClearEntityTarget( pipe_shooter_target );
				valley_pipe_shooter.ignoreme = false;
				valley_pipe_shooter.threatbias = 500000;
			}
		}
	}
}

mining_valley_pipe_attack_release()
{
	level endon( "rough_terrain" );

	pipe_shooter = self;
	pipe_shooter endon( "death" );

	flag_wait( "into_the_valley" );

	pipe_shooter.suppressionwait = 2;
	pipe_shooter.attackeraccuracy = 1;
}

mining_valley_cleanup()
{
	allies_move_into_rough_terrain_trigger = GetEnt( "allies_move_into_rough_terrain", "targetname" );
	allies_move_into_rough_terrain_trigger waittill( "trigger" );

	enemy_valley = get_ai_group_ai( "enemy_valley" );
	array_thread( enemy_valley, maps\_nx_utility::delete_ai_not_bullet_shielded );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rough_terrain_start()
{
	// Start the player and allies
	maps\nx_lunar_util::lunar_start( "rough_terrain_start", "rough_terrain_eagle_start", "rough_terrain_falcon_start" );
	
	// Initial Vision
	thread maps\nx_lunar_fx::fx_init_vision_surface();
	
	//Init Combat
	maps\nx_lunar_util::lunar_combat_init();
	
	// Play water treatment binks
	thread maps\nx_lunar_util::lunar_water_treatment_screen_binks();
}

rough_terrain()
{	
	level.falcon.baseaccuracy = 10.0;
	level.eagle.baseaccuracy = 10.0;
	
	level thread rough_terrain_meteors();

	level thread rough_terrain_spawns();

	level thread rough_terrain_enemy_retreat();

	level thread rough_terrain_area_scan();

	level thread rough_terrain_ally_and_player_speed_control();

	maps\nx_lunar_util::waittill_all_enemies_dead_or_dying( 8 );

	// Save the game
	level thread autosave_now();

	level.eagle pushplayer( true );
	level.falcon pushplayer( true );

	issue_color_orders( "y106", "allies" );
	issue_color_orders( "r106", "allies" );

	level thread rough_terrain_ally_movement();

	level thread rough_terrain_dialog();

	level thread rough_terrain_lsp_explosion();

	flag_wait( "rover_battle" );
}

rough_terrain_dialog()
{
	level endon( "rover_battle_start" );

	wait( 1.0 );

	// Battle chatter
	battlechatter_off( "allies" );

	// Dialog: This is the only way around, let's move.
	level thread radio_dialogue( "moon_eag_ext_onlyway" );

	rough_terrain_top_trigger = GetEnt( "allies_move_into_rough_terrain", "targetname" );
	if( IsDefined( rough_terrain_top_trigger ) )
	{
		rough_terrain_top_trigger rough_terrain_up_path_dialog();
	}

	// Dialog: Tangos right…
	level thread radio_dialogue( "moon_eag_int_14" );

	// Dialog: Chatter Affirmative
	level thread radio_dialogue( "jswc_fal_resp_ack_co_gnrc_affirm" );

	wait( 0.5 );

	// Crow: Use the terrain for cover!
	level thread radio_dialogue( "moon_eag_ext_useterrain" );

	maps\nx_lunar_util::waittill_number_of_enemies_killed( 4 );

	// Dialog: Chatter Move
	level thread radio_dialogue( "jswc_eag_order_move_noncombat" );

	// Battle chatter
	battlechatter_on( "allies" );

	level waittill( "rough_terrain_enemies_cleared" );

	battlechatter_off( "allies" );

	// Dialog: Chatter Move
	level thread radio_dialogue( "jswc_eag_order_move_noncombat" );

	wait( 3.0 );

	if( !flag( "rover_battle" ) )
	{
	//  Dialog: We can go through here…
		radio_dialogue( "moon_eag_ext_thruhere" );
	}
}

rough_terrain_up_path_dialog()
{
	trigger = self;
	trigger endon( "trigger" );

	wait( 5.5 );

	// Riggs: Why are they attacking now?
	radio_dialogue( "moon_fal_ext_whynow" );

	wait( 1.0 );

	// Crow: They're after the LSP transmitters.
	radio_dialogue( "moon_eag_ext_afterlsp" );

	wait( 0.5 );

	// Crow: I gaurantee this isn't the only attack.
	radio_dialogue( "moon_eag_ext_notonlyattack" );

	// Crow: I only hope the other bases are faring better than us.
	radio_dialogue( "moon_eag_ext_hopeothers" );

	wait( 3.0 );

	// Dialog: Look alert.
	radio_dialogue( "moon_eag_livhal_01" );

	maps\nx_lunar_util::waittill_targetname_triggered( "allies_move_into_rough_terrain" );
	
}

rough_terrain_area_scan()
{
	level endon( "rover_battle" );

	start_combat_trigger = GetEnt( "allies_move_into_rough_terrain", "targetname" );
	start_combat_trigger endon( "trigger" );

	maps\nx_lunar_util::waittill_all_enemies_dead_or_dying();

	flag_wait( "rough_terrain_allies_heading_up" );

	level.eagle maps\nx_lunar_util::ignore_everything();
	level.falcon maps\nx_lunar_util::ignore_everything();
	
	level.eagle thread rough_terrain_ally_scanning();
	level.falcon rough_terrain_ally_scanning();

	level.eagle cqb_aim();
	level.falcon cqb_aim();
}

rough_terrain_ally_scanning()
{
	ally = self;	

	start_combat_trigger = GetEnt( "allies_move_into_rough_terrain", "targetname" );
	start_combat_trigger endon( "trigger" );

	look_at_target_array = GetEntArray( "rough_terrain_look_around_target", "targetname" );

	wait RandomFloatRange( 1.0, 3.0 );

	while( 1 )
	{
		target_number = RandomIntRange( 0, look_at_target_array.size );
		look_at_target = look_at_target_array[target_number];
		ally cqb_aim( look_at_target );
		wait RandomFloatRange( 4.0, 8.0 );
	}
}

rough_terrain_enemy_retreat()
{
	level endon( "rover_battle" );

	maps\nx_lunar_util::waittill_targetname_triggered( "allies_move_into_rough_terrain" );

	wait( 0.05 );

	maps\nx_lunar_util::waittill_number_of_enemies_killed( 4 );

	issue_color_orders( "p102", "axis" );
	issue_color_orders( "y113", "allies" );
	issue_color_orders( "r113", "allies" );
}

rough_terrain_ally_and_player_speed_control()
{
	level endon( "rover_battle" );

	level.eagle thread maps\nx_lunar_util::lunar_player_movement_control();

	maps\nx_lunar_util::waittill_targetname_triggered( "allies_move_into_rough_terrain" );

	level.falcon.baseaccuracy = 1.0;
	level.eagle.baseaccuracy = 1.0;
	level.eagle cqb_aim();
	level.falcon cqb_aim();

	level.eagle pushplayer( false );
	level.falcon pushplayer( false );

	level.eagle maps\nx_lunar_util::clear_ignore_everything();
	level.falcon maps\nx_lunar_util::clear_ignore_everything();

	level notify( "stop_player_movement_control" );

	level.eagle.grenadeawareness = 0;
	level.eagle.ignoreexplosionevents = true;
	level.eagle.ignorerandombulletdamage = true;
	level.eagle.ignoresuppression = true;
	level.eagle.disableBulletWhizbyReaction = true;
	level.eagle disable_pain();

	level.falcon.grenadeawareness = 0;
	level.falcon.ignoreexplosionevents = true;
	level.falcon.ignorerandombulletdamage = true;
	level.falcon.ignoresuppression = true;
	level.falcon.disableBulletWhizbyReaction = true;
	level.falcon disable_pain();

	wait( 2.0 );

	level.eagle.grenadeawareness = 1;
	level.eagle.ignoreexplosionevents = false;
	level.eagle.ignorerandombulletdamage = false;
	level.eagle.ignoresuppression = false;
	level.eagle.disableBulletWhizbyReaction = false;
	level.eagle enable_pain();

	level.falcon.grenadeawareness = 1;
	level.falcon.ignoreexplosionevents = false;
	level.falcon.ignorerandombulletdamage = false;
	level.falcon.ignoresuppression = false;
	level.falcon.disableBulletWhizbyReaction = false;
	level.falcon enable_pain();
}

rough_terrain_spawns()
{
	level thread maps\nx_lunar_util::trigger_choice_spawn( "spawn_plateau_battle" );
	level thread maps\nx_lunar_util::trigger_choice_spawn( "allies_move_into_rough_terrain" );
	level thread maps\nx_lunar_util::trigger_choice_spawn( "rough_terrain_final_wave" );
}

rough_terrain_ally_movement()
{
	level endon( "rover_battle" );	

	// Wait until final wave has triggered and spawned
	final_wave_trigger = GetEnt( "rough_terrain_final_wave", "targetname" ); 
	final_wave_trigger waittill( "trigger" );

	wait( 1.0 );

//  maps\nx_lunar_util::waittill_number_of_enemies_remaining( 2 );
// Pull enemies out of cover

	maps\nx_lunar_util::waittill_all_enemies_dead_or_dying();

	level notify( "rough_terrain_enemies_cleared" );

	// Move to Rover Battle start
	issue_color_orders( "y115", "allies" );
	issue_color_orders( "r115", "allies" );
}


rough_terrain_meteors()
{
	level endon( "rover_battle" );

	meteor_trigger = GetEnt( "meteor_shower_trigger", "targetname" );
	meteor_trigger waittill( "trigger" );

	meteor_1 = GetEnt( "meteor_1", "targetname" );
	meteor_1_target = GetEnt( "meteor_1_target", "targetname" );
	meteor_1 MoveTo( meteor_1_target.origin, 2.0, .5, .05 );
	meteor_1 RotateTo( meteor_1_target.angles, 0.5, .05, .05 );
	PlayFXOnTag( GetFx( "meteor_trail" ), meteor_1, "tag_origin" );

	meteor_1a = GetEnt( "meteor_1a", "targetname" );
	meteor_1a_target = GetEnt( "meteor_1a_target", "targetname" );
	meteor_1a MoveTo( meteor_1a_target.origin, 1.50, .5, .05 );
	meteor_1a RotateTo( meteor_1a_target.angles, 0.5, .05, .05 );
	PlayFXOnTag( GetFx( "meteor_trail" ), meteor_1a, "tag_origin" );

	wait( 3.0 );

	meteor_1b = GetEnt( "meteor_1b", "targetname" );
	meteor_1b_target = GetEnt( "meteor_1b_target", "targetname" );
	meteor_1b MoveTo( meteor_1b_target.origin, 2.0, .5, .05 );
	meteor_1b RotateTo( meteor_1b_target.angles, 0.5, .05, .05 );
	PlayFXOnTag( GetFx( "meteor_trail" ), meteor_1b, "tag_origin" );

	wait( 1.5 );

	meteor_1c = GetEnt( "meteor_1c", "targetname" );
	meteor_1c_target = GetEnt( "meteor_1c_target", "targetname" );
	meteor_1c MoveTo( meteor_1c_target.origin, 1.30, .5, .05 );
	meteor_1c RotateTo( meteor_1c_target.angles, 0.5, .05, .05 );
	PlayFXOnTag( GetFx( "meteor_trail" ), meteor_1c, "tag_origin" );

	wait( 0.5 );

	meteor_1d = GetEnt( "meteor_1d", "targetname" );
	meteor_1d_target = GetEnt( "meteor_1d_target", "targetname" );
	meteor_1d MoveTo( meteor_1d_target.origin, 2.0, .5, .05 );
	meteor_1d RotateTo( meteor_1d_target.angles, 0.25, .05, .05 );
	PlayFXOnTag( GetFx( "meteor_trail" ), meteor_1d, "tag_origin" );

	wait( 1.0 );

	meteor_2 = GetEnt( "meteor_2", "targetname" );
	meteor_2_target = GetEnt( "meteor_2_target", "targetname" );
	meteor_2 MoveTo( meteor_2_target.origin, 1.0, .5, .05 );
	meteor_2 RotateTo( meteor_2_target.angles, 0.5, .05, .05 );
	PlayFXOnTag( GetFx( "meteor_trail" ), meteor_2, "tag_origin" );

//  wait( 1.0 );

//  meteor_3 = GetEnt( "meteor_3", "targetname" );
//  meteor_3_target = GetEnt( "meteor_3_target", "targetname" );
//  meteor_3 MoveTo( meteor_3_target.origin, 2, .5, .05 );
//  meteor_3 RotateTo( meteor_3_target.angles, 1, .05, .05 );

	wait( 5.0 );

	meteor_1 delete();
	meteor_1a delete();
	meteor_1b delete();
	meteor_1c delete();
	meteor_1d delete();
	meteor_2 delete();
//  meteor_3 delete();
}

rough_terrain_lsp_explosion()
{
	flag_wait( "transformer_one_explosion" );

	// Tower delete after explosion
	level thread rough_terrain_lsp_explosion_tower_delete();

	level._player AllowSprint( false );

	player_speed_set( 100, 0.5 );

	level thread maps\nx_lunar_take_back_control::lsp_explosion_1();
	level thread play_lsp_explode_sound();

	wait( 2.5 );

	PlayRumbleOnPosition( "heavy_3s", level._player.origin );
	Earthquake( 0.25, 3.0, level._player.origin, 500 );

	// Crow: One of the transmitters!
	radio_dialogue( "moon_eag_ext_onetransmitter" );
	
	// Crow: We can't afford to lose any more.
	radio_dialogue( "moon_eag_ext_cantlose" );

	// Crow: We've got to secure the LSP controls.
	radio_dialogue( "moon_eag_ext_securelsp" );

	player_speed_default( 4.0 );

	level._player AllowSprint( true );
}

play_lsp_explode_sound()
{            
	mynodeEntitylsp = spawn("sound_emitter", (3806, -1592, -782));
	mynodeEntitylsp PlaySound( "scn_lunar_lsp_explode", "scn_lunar_lsp_explode", true );
	mynodeEntitylsp waittill( "scn_lunar_lsp_explode" );
	mynodeEntitylsp delete();
}

rough_terrain_lsp_explosion_tower_delete()
{
	wait( 0.75 );

	// Get the first tower and delete (eventually replace with destroyed tower) 
	lsp_transmitter_tower_1 = GetEnt( "lsp_transmitter_tower_1", "targetname" );
	lsp_transmitter_tower_1 delete();
}

rough_terrain_cleanup()
{
	// tagDK<note>This clean up is now handled in the anim script for timing
//  flag_wait( "vignette_falcon_death" );

//  enemy_plateau = get_ai_group_ai( "enemy_plateau" );
//  array_thread( enemy_plateau, maps\_nx_utility::delete_ai_not_bullet_shielded );
	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rover_battle_start()
{
	// Start the player and allies
	maps\nx_lunar_util::lunar_start( "rover_battle_start", "rover_battle_eagle_start", "rover_battle_falcon_start" );

	// Initial Vision
	thread maps\nx_lunar_fx::fx_init_vision_surface();

	// Init combat
	maps\nx_lunar_util::lunar_combat_init();
}

rover_battle()
{
	// Make sure that flags are on for next section.
	maps\nx_lunar_util::all_triggers_on( "into_shadows_triggers" );

	// Battle chatter
	battlechatter_off( "allies" );

	// Setup vehicle bay shutters to open
	level thread maps\nx_lunar_anim::top_floor_reopen();

	// Setup Supplies
	level thread maps\nx_lunar_util::show_scriptmodels_by_targetname( "into_shadows_supplies" );

	// Save the game
	level thread autosave_by_name( "rover_battle_1" );

	level thread rover_battle_dialog();

	//play the sfx and music for the rover scene here
	level thread rover_intro_scene_sfx_and_music();	

	// Prepare rover troops before rover is spawned
	array_spawn_function_targetname( "rover_enemies", maps\nx_lunar_util::lunar_enemy_rover_backup );
	array_spawn_function_targetname( "rover_ground_enemies", maps\nx_lunar_util::lunar_enemy_rover_backup );

	// Commenting to see how it goes without a new gunner
//  array_spawn_function_targetname( "rover_enemies", ::keep_turret_manned_spawn_func );
//  array_spawn_function_targetname( "rover_ground_enemies", ::keep_turret_manned_spawn_func );

	// Start gameplay
	flag_wait( "rover_battle_start" );

	level thread autosave_by_name( "rover_battle_2" );

	level.battle_rover thread vehicle_unload();

	level thread rover_battle_enemy_order_progression();

	issue_color_orders( "y107", "allies" );
	level.eagle.oldbaseaccuracy = level.eagle.baseaccuracy;
	level.eagle.baseaccuracy = 0.3;

	level.battle_rover.main_turret.secsOfFiringBeforeReload = 15;
	level.battle_rover.main_turret.reloadDuration = 3;
	level.battle_rover.main_turret TurretFireEnable(); // vignette disables the turret
	level.battle_rover.main_turret MakeUnusable();

	// Ben's test line
//  level.battle_rover.main_turret thread draw_line_of_site();

	// Keep track of gunners and associate scripts
	level.battle_rover thread rover_battle_gunner_tracker();

	// Influence grenades when player is out of the box
	level.battle_rover thread rover_battle_grenade_tracker();

	// Check enemy status for progression
	level.battle_rover thread rover_battle_progression_tracker();

	// Cleanup if necessary
	level thread rover_battle_cleanup();

	// tagTC<note> - GREENLIGHT END OF MISSION
	rover_battle_greenlight_nextmission();

	// Battle chatter
	battlechatter_on( "allies" );

	// Player moved forward to next checkpoint
	flag_wait( "into_shadows" );

	level.eagle pushplayer( true );

	// Make sure eagle is heading to goal if the player jumps ahead without killing all enemies
	remaining_enemies = get_ai_group_count( "enemy_rover_backup" );
	if( remaining_enemies > 0 )
	{
		level.eagle set_goal_radius( 30 );
		vehicle_bay_scan_node = GetNode( "vehicle_bay_scan_node", "targetname" );
		level.eagle SetGoalNode ( vehicle_bay_scan_node );
	}

	// If turret is manned, make sure it is shooting the player if he makes a run for it
	level.battle_rover.main_turret thread turret_attack_player();

	level notify( "rover_battle_threat_removed" );

	flag_set( "music_rover_battle_ends" );

	level.eagle.baseaccuracy = level.eagle.oldbaseaccuracy;

	// Release the enemies to move more freely if they're still alive
	rover_backup = get_ai_group_ai( "enemy_rover_backup" );
	array_thread( rover_backup, maps\nx_lunar_util::set_deadly_tracking_ai );

	level.battle_rover notify( "keep_turret_manned_stop" );
}

greenlight_sfx_fadeout_lunar()
{
	level._player setchannelvolumes( "snd_channelvolprio_level", "fadetoblack", 1.0 );
	//JL: Not needed. The game resets the channels when it going back to the main menu or when starting a new level.
	//wait 1.5;
	//level._player deactivatechannelvolumes( "snd_channelvolprio_level", 0.2 );
}

// tagTC<note> - temp mission end for the greenlight demo
rover_battle_greenlight_nextmission()
{
	level._player.health = 100;
	level._player EnableInvulnerability();
	wait( 3.0 );
	level notify( "green_light_stop" );
	wait( 4.0 );
	thread greenlight_sfx_fadeout_lunar();
	endmission_goto_frontend();
}


rover_intro_scene_sfx_and_music()
{
	flag_wait( "vignette_falcon_death" );
	flag_set( "music_rover_battle_starts" );	
	wait 0.4;
	level._player playsound( "scn_lunar_rover_entrance" );
	
	level._player setchannelvolumes( "snd_channelvolprio_shellshock", "lunar_rover_battle", 0.3 );
}

green_light_fade_to_black()
{
	level._player.health = 100;
	level._player EnableInvulnerability();

	wait( 3.0 );

	black = greenlight_create_overlay_element( "black", 0 );
	black fadeovertime( 2 );
	black.alpha = 1;

	wait( 2.0 );

	level notify( "green_light_stop" );

	level._player FreezeControls( true );

	// Stop progression
	while( 1 )
	{
		wait( 1.0 );
	}
}

greenlight_hud_hide( state )
{
	wait 1;
	if ( state )
	{
		SetSavedDvar( "compass", "0" );
		SetSavedDvar( "ammoCounterHide", "1" );
		SetSavedDvar( "hud_showstance", "0" );
		level._nocompass = true;
	}
	else
	{
		SetSavedDvar( "compass", "1" );
		SetSavedDvar( "ammoCounterHide", "0" );
		SetSavedDvar( "hud_showstance", "1" );
		level._nocompass = undefined;
	}
}

greenlight_create_overlay_element( shader_name, start_alpha )
{
	overlay = newHudElem();
	overlay.x = 0;
	overlay.y = 0;
	overlay setshader( shader_name, 640, 480 );
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha = start_alpha;
	overlay.foreground = true;
	return overlay;
}

rover_battle_enemy_order_progression()
{
	level endon( "into_shadows" );
	level endon( "moving_into_shadows" );

	// Commented out to see how single gunner will work
//  level.battle_rover thread keep_turret_manned();

	issue_color_orders( "g100", "axis" );

	maps\_nx_utility::spawn_targetname_and_return_array( "rover_ground_enemies" );

	wait( 15.0 );

	issue_color_orders( "g101", "axis" );
	issue_color_orders( "b100", "axis" );

	while( 1 )
	{
		wait( 10.0 );
	
		issue_color_orders( "g102", "axis" );
		issue_color_orders( "b101", "axis" );
	
		wait( 10.0 );
	
		issue_color_orders( "g101", "axis" );
		issue_color_orders( "b102", "axis" );
	
		wait( 10.0 );
	
		enemies_alive = get_ai_group_sentient_count( "enemy_rover_backup" );
		if( enemies_alive < 8 )
		{
			issue_color_orders( "g103", "axis" );
		}
		else
		{
			issue_color_orders( "g102", "axis" );
		}

		issue_color_orders( "b101", "axis" );
	
		wait( 10.0 );

		enemies_alive = get_ai_group_sentient_count( "enemy_rover_backup" );
		if( enemies_alive < 6 )
		{
			issue_color_orders( "b103", "axis" );
			issue_color_orders( "g101", "axis" );
		}
		else
		{
			issue_color_orders( "b102", "axis" );
			issue_color_orders( "g101", "axis" );
		}
	}
}

rover_battle_progression_tracker()
{
	level endon( "into_shadows" );

	waittill_aigroupcount( "enemy_rover_backup", 5 );

	level notify( "moving_into_shadows" );

	issue_color_orders( "b101", "axis" );
	issue_color_orders( "g101", "axis" );

	waittill_aigroupcount( "enemy_rover_backup", 4 );

	level thread maps\nx_lunar_util::all_triggers_off( "rover_battle_ally_triggers" );

	issue_color_orders( "b100", "axis" );
	issue_color_orders( "g100", "axis" );

	waittill_aigroupcount( "enemy_rover_backup", 3 );

	// Save the game
	level thread autosave_by_name( "end_rover_battle" );

	level.eagle pushplayer( true );

	issue_color_orders( "y140", "allies" );

	// Dialog: Alright lets finish them off...
	radio_dialogue( "moon_eag_ext_24" );

	rover_backup = get_ai_group_ai( "enemy_rover_backup" );
	foreach( enemy in rover_backup )
	{ 
		enemy.pathrandompercent = 200;
		enemy.favoriteenemy = level.eagle;
		enemy.health = 50;
		enemy.aggressivemode = true;
		enemy setgoalentity( level.eagle );
		enemy.goalradius = 400; 
	}
	
	level.eagle.baseaccuracy = 50000.0;

	waittill_aigroupcleared( "enemy_rover_backup" );

	level notify( "rover_battle_threat_removed" );

	level.eagle set_goal_radius( 30 );
	vehicle_bay_scan_node = GetNode( "vehicle_bay_scan_node", "targetname" );
	level.eagle SetGoalNode ( vehicle_bay_scan_node );

	// Dialog: Keep moving forward – we need to get to the command center!
	radio_dialogue( "moon_eag_ext_34" );
}

rover_battle_grenade_tracker()
{
	rover_backup = get_ai_group_ai( "enemy_rover_backup" );
	array_thread( rover_backup, ::rover_battle_remove_grenades );

	while( !flag( "into_shadows" ) )
	{
		flag_waitopen( "rover_in_the_box" );
		rover_backup = get_ai_group_ai( "enemy_rover_backup" );
		array_thread( rover_backup, ::rover_battle_add_grenades );

		flag_wait( "rover_in_the_box" );
		rover_backup = get_ai_group_ai( "enemy_rover_backup" );
		array_thread( rover_backup, ::rover_battle_remove_grenades );
	}

	rover_backup = get_ai_group_ai( "enemy_rover_backup" );
	array_thread( rover_backup, ::rover_battle_add_grenades );
}

rover_battle_add_grenades()
{
	self.grenadeammo = 3;
}

rover_battle_remove_grenades()
{
	self.grenadeammo = 0;
}

// Ben's test line
draw_line_of_site()
{
	self endon( "death" );
	while ( 1 )
	{
		angles = self GetTagAngles( "tag_aim" );
		forward = AnglesToForward( angles );
		forward_scaled = vector_multiply( forward, 100 );
		start = self GetTagOrigin( "tag_aim" );
		end = start + forward_scaled;
		line( start, end, ( 1, 0, 0 ), false, 1 );
		wait( 0.0001 );
	}
}

rover_battle_turret_cooling( battle_rover_gunner )
{
	battle_rover_gunner endon( "death" );
	level endon( "green_light_stop" );
	level endon( "into_shadows" );

	while( 1 )
	{
		// Rover is armed and shooting, waiting to overheat
		level.battle_rover.main_turret waittill( "starting_reload" );

		// Dialog: Take out that gunner!
		// Dialog: Walker, take out that gunner!
		// Dialog: The gun is cooling!
		dialog_array = [ "moon_eag_ext_47", "moon_eag_ext_48", "moon_eag_ext_49" ];
		random_dialog = RandomIntRange( 0, dialog_array.size );

		random_chance = RandomIntRange( 1, 10 );
		if( random_chance > 8 )
		{
			level thread radio_dialogue( dialog_array[ random_dialog ] );
		}

		wait( 3 );
	}
}

rover_battle_aiming( battle_rover_gunner )
{
	self rover_battle_aiming_worker( battle_rover_gunner );
	
	//cleanup when rover_battle_aiming_worker ends on gunner death. 
	//can't have it continuing to aim at the player with no gunner.
	wait 0.05;//waiting to make sure rover_battle_target_seeker is also ended.
	level.battle_rover.main_turret ClearTargetEntity();
	level.battle_rover.main_turret SetMode( "manual" );
}
rover_battle_aiming_worker( battle_rover_gunner )
{
	battle_rover_gunner endon( "death" );
	level endon( "into_shadows" );

	while( IsAlive( battle_rover_gunner ) )
	{
		// Seek player when cannot see him and start firing at destructable cover
		level thread rover_battle_target_seeker( battle_rover_gunner );

		while( !battle_rover_gunner CanSee( level._player ) && flag( "rover_in_the_box" ) )
		{
			wait( RandomFloatRange( 0.2, 0.8 ) );	
		}

		// Dialog: Get to cover!
		// Dialog: Get back to cover!
		// Dialog: Watch it!
		dialog_array = [ "moon_eag_ext_08", "moon_eag_ext_18", "moon_eag_ext_19" ];

		random_chance = RandomIntRange( 1, 10 );
		if( random_chance > 7 )
		{
			random_dialog = RandomIntRange( 0, dialog_array.size );
			level thread radio_dialogue( dialog_array[ random_dialog ] );
		}
		
		// Rover can see player
		level.battle_rover notify( "rover_target_player" );

		// in sentry mode, the turret will attack the player
		level.battle_rover.main_turret SetMode( "sentry" );
		level.battle_rover.main_turret ClearTargetEntity();

		// Make sure rover is firing at the player
		flag_waitopen( "rover_turret_cooling" );

		// Wait until rover cannot see player to go into seek again
		while( battle_rover_gunner CanSee( level._player ) )
		{
			wait( RandomFloatRange( 0.2, 0.8 ) );	
		}

		// tagBR< note >: It is possible to get to the end of this while() loop without ever
		// hitting a wait...which was causing an infinite loop.
		wait 0.05;
	}
}

rover_battle_target_seeker( battle_rover_gunner )
{
	level.battle_rover endon( "rover_target_player" );
	battle_rover_gunner endon( "death" );
	
	// in manual_ai mode, the turret will target the things we explicitly set
	level.battle_rover.main_turret SetMode( "manual_ai" );
	level.battle_rover.main_turret ClearTargetEntity();

	while( 1 )
	{
		// Fire at random target for duration
		flag_waitopen( "rover_turret_cooling" );
	
		// Get array of targets			
		rover_array_of_targets = GetEntArray( "rover_panel_target", "targetname" );
	
		target_time = RandomIntRange( 1, 2 );
	
		change_target_chance = 10;
	
		for ( i = 0; i < target_time; i++ )
		{
			// Turret possibly changes target
			if( change_target_chance > 6 )
			{
				// Choose a new random target
				target_number = RandomIntRange( 0, 19 );
				rover_target = rover_array_of_targets[target_number];
				level.battle_rover.main_turret maps\_mgturret::set_turret_target( rover_target );
			}
	
			wait RandomFloatRange( 2.0, 4.5 );
			change_target_chance = RandomIntRange( 1, 10 );
		}
	
		// Turret fire time
		wait RandomFloatRange( 0.0, 4.5 );
	}
}

rover_battle_gunner_tracker()
{
	battle_rover_gunner = level.battle_rover.riders[1];
	level endon( "into_shadows" );
	level endon( "rover_battle_threat_removed" );

	while( 1 )
	{
		// Rover gunner/cooling/aiming control
		level thread rover_battle_aiming( battle_rover_gunner );
		level thread rover_battle_turret_cooling( battle_rover_gunner );

		// Wait until the current gunner dies
		battle_rover_gunner waittill( "death", attacker );

        if ( IsDefined( attacker ) && IsPlayer( attacker ) )
		{
			// Dialog: Great shot!
			// Dialog: That's it!
			// Dialog: Tango down!
			dialog_array = [ "moon_eag_ext_23", "moon_eag_kill_yell_04", "moon_eag_kill_yell_05" ];
			random_dialog = RandomIntRange( 0, dialog_array.size );
			level thread radio_dialogue( dialog_array[ random_dialog ] );	
		}

		// wait until rover is empty (this is necessary initially because the rover remains full for a while)
		while( 1 )
		{
			if( level.battle_rover.riders.size == 0 )
			{
				break;
			} 
			wait( 0.05 );
		}

		// Reset all cooling flags and effects
		flag_clear( "rover_turret_cooling" );

		// Wait until the gunner is in place.
		while( 1 )
		{
			// New Gunner (get the new gunner)
			battle_rover_gunner = level.battle_rover.riders[0];
			if( IsDefined( battle_rover_gunner ) )
			{	
			  // Dialog: Watch it! New gunner!
			  // Dialog: Another one on the turret!
			  // Dialog: Another gunner!
				dialog_array = [ "moon_eag_ext_newgun01", "moon_eag_ext_newgun03", "moon_eag_ext_newgun04" ];
				random_dialog = RandomIntRange( 0, dialog_array.size );
				level thread radio_dialogue( dialog_array[ random_dialog ] );
				break;
			}
			wait( 0.05 );
		}
	}
}

keep_turret_manned()
{
	self notify( "keep_turret_manned_stop" );
	self endon( "keep_turret_manned_stop" );

	while ( 1 )
	{
		self waittill( "gunner_dead" );

		while ( 1 )
		{
			level.keep_turret_manned_actors = array_removeundefined( level.keep_turret_manned_actors );
			if ( level.keep_turret_manned_actors.size == 0 )
			{
				wait 1;
				continue;
			}

			chosen_actor = undefined;
			foreach ( actor in level.keep_turret_manned_actors )
			{
				if ( isalive( actor ) )
				{
					actor.script_startingposition = 1; // Set the starting position to the gunner position
					chosen_actor = actor;					
					break;
				}
			}

			if ( isdefined( chosen_actor ) )
			{
				chosen_actor thread run_to_turret( self );
				break;
			}

			wait 1;
		}		
	}
}

run_to_turret( vehicle )
{
	vehicle notify ( "run_to_turret" );
	thread maps\_vehicle_aianim::guy_runtovehicle( self, vehicle );
	vehicle thread maps\_vehicle_aianim::gunnerdead( self );
}

keep_turret_manned_spawn_func()
{
	// Add self to array of keep_turret_manned_actors
	if ( !isdefined( level.keep_turret_manned_actors ) )
	{
		level.keep_turret_manned_actors = [];
	}

	level.keep_turret_manned_actors = array_add( level.keep_turret_manned_actors, self );
}

rover_battle_dialog()
{
	level endon( "into_shadows" );
	level endon( "green_light_stop" );
	level._player endon( "death" );

//  wait( 0.5 );
//
//  // Dialog: Get to cover!
//  radio_dialogue( "moon_eag_ext_08" );
//
//  wait( 2.0 );
//
//  // Dialog: Damn it Falcon…
//  radio_dialogue( "moon_eag_ext_09" );
//
//  wait( 1.0 );

	flag_wait( "rover_battle_start" );

	// Dialog: Keep the those troops off us!
	radio_dialogue( "moon_eag_ext_10" );

	wait( 5.0 );

	// Dialog: They're blasting our cover apart!
	radio_dialogue( "moon_eag_ext_12" );

	gunner = level.battle_rover.riders[0];

	if( IsAlive( gunner ) )
	{
		// Dialog: Take out that gunner!
		radio_dialogue( "moon_eag_ext_47" );
	}

	// Dialog: Take a shot at the gunner when his gun is cooling!
//  radio_dialogue( "moon_eag_ext_13" );

	// Dialog: Alright lets clear them out...
//  radio_dialogue( "moon_eag_ext_24" );

	// Dialog: Careful! Keep out of line of sight from that gunner!
//  radio_dialogue( "moon_eag_ext_14" );

	enemies_close = GetEnt( "rover_battle_enemies_close", "targetname" );
	enemies_close waittill( "trigger" );

	// Dialog: They're closing in!
	radio_dialogue( "moon_eag_ext_20" );

	// Dialog: Get over here and take out that gunner!
//  radio_dialogue( "moon_eag_ext_21" );

	// Dialog: Get up here! You don't have a shot from back there!
//  radio_dialogue( "moon_eag_ext_22" );

	// Dialog: Great shot! Wait there's another on the gun!
//  radio_dialogue( "moon_eag_ext_23" );

	// Dialog: Get back here!
//  radio_dialogue( "moon_eag_ext_25" );

	// Dialog: Fall back!
//  radio_dialogue( "moon_eag_ext_26" );

	// Dialog: Get over here!
//  radio_dialogue( "moon_eag_ext_27" );

	// Dialog: We're almost out of cover! Take the shot!
//  radio_dialogue( "moon_eag_ext_28" );

}

rover_battle_cleanup()
{
	flag_wait( "rover_battle_start" );

	rover_ai_remaining = get_ai_group_sentient_count( "enemy_rover_backup" );
	if ( rover_ai_remaining < 1 )
	{	
		enemy_rover_backup = get_ai_group_ai( "enemy_rover_backup" );
		array_thread( enemy_rover_backup, maps\_nx_utility::delete_ai_not_bullet_shielded );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

into_shadows_start()
{
	// Start the player and allies
	maps\nx_lunar_util::lunar_start( "into_shadows_start", "into_shadows_eagle_start" );

	// Clean up Falcon
	level.falcon stop_magic_bullet_shield();
	level.falcon delete();

	// Initial Vision
	thread maps\nx_lunar_fx::fx_init_vision_surface();

	// Init combat
	maps\nx_lunar_util::lunar_combat_init();

	// Make sure that flags are on for next section.
	maps\nx_lunar_util::all_triggers_on( "into_shadows_triggers" );

	level.eagle set_goal_radius( 30 );

	// Follow eagle
	self thread maps\nx_lunar::eagle_follow_objective();

	// Setup vehicle bay shutters to open
	level thread maps\nx_lunar_anim::top_floor_reopen();

	// Setup Supplies
	level thread maps\nx_lunar_util::show_scriptmodels_by_targetname( "into_shadows_supplies" );
}

into_shadows()
{
	// Make sure all vehicle bay doors are open
	maps\nx_lunar_get_to_the_armory::open_all_vehicle_bay_doors();
	level thread maps\nx_lunar_util::open_lunar_door( "vehicle_hatch_breach", 0.2 );

	level.eagle thread into_shadows_dialog();

	level thread into_shadows_lsp_explosion();
	
	flag_wait( "into_shadows" );

	level.eagle thread maps\nx_lunar_util::lunar_player_movement_control();

	// Alert new enemies if previous enemies were not all killed
	rover_ai_remaining = get_ai_group_sentient_count( "enemy_rover_backup" );
	if ( rover_ai_remaining > 0 )
	{
		flag_set( "rover_battle_enemies_aware" );

		// Clear out previous objective so scripts can move on
		level notify( "rover_enemies_cleared" );
		flag_set( "player_made_it_to_shadows" );
		flag_set( "player_in_kill_position_rover" );
	}
	else
	{
		level thread into_shadows_forced_cleanup();
		flag_clear( "rover_battle_enemies_aware" );

		// Save the game
		level thread autosave_by_name( "into_shadows" );
	}

	// Setup spawning threads
	level thread into_shadows_spawns();

	// Rovers at the bay, unload, and fight/guard, death checks
	level thread into_shadows_rover_unload_and_attack();

	wait( 1.0 );

	// Player nears the vehicle bay
	flag_wait( "vehicle_bay_return" );

	issue_color_orders( "y110", "allies" );

	if( IsDefined( level.eagle.oldbaseaccuracy ) )
	{
		level.eagle.baseaccuracy = level.eagle.oldbaseaccuracy;
	}

	// maps\nx_lunar_get_to_the_armory::remove_vehicle_bay_blockers();
}

into_shadows_player_on_turret( rover_1, rover_2 )
{
	level endon( "enemy_on_rovers_low_count" );

	first_time_on = undefined;

	while( !flag( "vehicle_bay_return" ) )
	{
		level._player waittill( "mount_turret" );

		// Make sure turret is working
		rover_1 turret_attack_player();
		rover_2 turret_attack_player();

		if( !IsDefined( first_time_on ) )
		{
			// Dialog: Clear them out!
			level thread radio_dialogue( "moon_eag_ext_clearout" );
			first_time_on = true;
		}
	
//  	interior_goal_vol = GetEnt( "interior_bay_enemies", "targetname" );
//  	living_enemies = get_ai_group_ai( "enemy_on_rovers" );
//  	array_thread( living_enemies, ::into_shadows_change_goalvolume, interior_goal_vol );

		vehicle_bay_rover_enemies = get_ai_group_ai( "enemy_on_rovers" );
		vehicle_bay_rover_enemies array_thread( vehicle_bay_rover_enemies, ::into_shadows_player_on_turret_behavior );

		level thread into_shadows_enemy_color_switcher();

		// Temp invulnerability
		level._player EnableInvulnerability();
		level._player.script_attackeraccuracy = 0.1;

		level._player waittill( "dismount_turret" );

//  	exterior_goal_vol = GetEnt( "exterior_bay_enemies", "targetname" );
//  	living_enemies = get_ai_group_ai( "enemy_on_rovers" );
//  	array_thread( living_enemies, ::into_shadows_change_goalvolume, exterior_goal_vol );

		vehicle_bay_rover_enemies = get_ai_group_ai( "enemy_on_rovers" );
		vehicle_bay_rover_enemies array_thread( vehicle_bay_rover_enemies, maps\nx_lunar_util::set_deadly_tracking_ai );
		
		// Temp invulnerability
		level._player DisableInvulnerability();
		level._player.script_attackeraccuracy = 1.0;
	}
}

into_shadows_enemy_color_switcher()
{
	level._player endon( "dismount_turret" );

	while( 1 )
	{
		issue_color_orders( "y101", "axis" );
		issue_color_orders( "r101", "axis" );

		wait RandomFloatRange( 2.0, 6.0 );

		issue_color_orders( "y102", "axis" );
		issue_color_orders( "r102", "axis" );

		wait RandomFloatRange( 2.0, 6.0 );
	}
}

//into_shadows_change_goalvolume( goal )
//{
//    enemy = self;
//    enemy endon( "death" );
//
//    wait( 2.0 );
//
//    enemy ClearGoalVolume();
//    enemy ClearEntityTarget( enemy.target );
//    enemy SetGoalVolumeAuto( goal );
//}

into_shadows_dialog()
{
	level endon( "vehicle_bay_return" );
	
	level thread into_shadows_move_on_dialog();
	level thread into_shadows_upper_deck_dialog();
	level thread into_shadows_kill_dialog();

	into_shadows_initial_dialog();

	wait( 2.0 );
	
	level notify( "eagle_heading_to_shadows" );	

	wait( 0.05 );

	into_shadows_move_to_shadows_dialog();

	level notify( "stop_player_movement_control" );

	level.eagle notify( "stealth_attack" );

	into_shadows_move_to_kill_dialog();

	into_shadows_stealth_kill_dialog();
}

into_shadows_initial_dialog()
{
	level endon( "vehicle_bay_return" );
	level endon( "vehicle_bay_shadow_enemies_aware" );
	level endon( "rover_battle_enemies_aware" );

	if( flag( "vehicle_bay_return" ) || flag( "vehicle_bay_shadow_enemies_aware" ) || flag( "rover_battle_enemies_aware" ) )
	{
		return;
	}

//  // Dialog: Walker, keep out of sight…
//  radio_dialogue( "moon_eag_ext_keepout" );

	wait( 1.0 );

	// Wait for player to join Eagle
	flag_wait( "into_shadows" );

	level.eagle waittill ( "goal" );

	if( !flag( "vehicle_bay_return" ) && !flag( "vehicle_bay_shadow_enemies_aware" ) && !flag( "rover_battle_enemies_aware" ) )
	{
		// Dialog: Hold fire! Shit... 
		radio_dialogue( "moon_eag_ext_29" );

		wait( 0.5 );
	
		// Dialog: We can’t do this head on…
		radio_dialogue( "moon_eag_ext_30" );
	}
}

into_shadows_move_to_shadows_dialog()
{
	level endon( "vehicle_bay_return" );
	level endon( "vehicle_bay_shadow_enemies_aware" );
	level endon( "rover_battle_enemies_aware" );

	if( flag( "vehicle_bay_return" ) || flag( "vehicle_bay_shadow_enemies_aware" ) || flag( "rover_battle_enemies_aware" ) )
	{
		return;
	}

//  wait( 1.0 );
//
//  // Dialog: They're headed our way. We have to get moving.
//  radio_dialogue( "moon_eag_ext_31" );

	// Dialog: Walker, follow me - stay in the shadows!
	radio_dialogue( "moon_eag_ext_31" );

	wait( 3.0 );
	
	// Dialog: Come on, they're coming around!
	radio_dialogue( "moon_eag_ext_comingaround" );	

	wait( 5.0 );
	// Dialog: We can get behind them over here.
	radio_dialogue( "moon_eag_ext_getbehind" );

	flag_wait( "player_made_it_to_shadows" );
}

into_shadows_move_to_kill_dialog()
{
	level endon( "vehicle_bay_return" );
	level endon( "vehicle_bay_shadow_enemies_aware" );
	level endon( "rover_battle_enemies_aware" );

//  // Dialog: Hold your fire
//  radio_dialogue( "moon_eag_ext_32" );

	if( flag( "vehicle_bay_return" ) || flag( "vehicle_bay_shadow_enemies_aware" ) || flag( "rover_battle_enemies_aware" ) )
	{
		return;
	}

	wait( 5.0 );

	// Dialog: Let's take these turrets.
	radio_dialogue( "moon_eag_ext_taketheseturrets" );

	flag_wait( "into_shadows_round_the_corner");

	wait( 2.0 );

	// Dialog: Alright, let's take these gunners down.
	radio_dialogue( "moon_eag_ext_gunnersdown" );

	level.eagle waittill ( "goal" );
}

into_shadows_stealth_kill_dialog()
{
	level endon( "vehicle_bay_return" );
	level endon( "vehicle_bay_shadow_enemies_aware" );
	level endon( "rover_battle_enemies_aware" );

	if( flag( "vehicle_bay_return" ) || flag( "vehicle_bay_shadow_enemies_aware" ) || flag( "rover_battle_enemies_aware" ) )
	{
		return;
	}

//  flag_wait( "player_in_kill_position_rover" );

	// Dialog: Ready?
	radio_dialogue( "moon_eag_ext_ready" );

	wait( 0.75 );

	// Dialog: Weapons Free!
	radio_dialogue( "moon_eag_ext_33" );

	flag_wait( "into_shadows_gunner_1_enemy_dead" );
	flag_wait( "into_shadows_gunner_2_enemy_dead" );

	wait( 1.0 );

	// Dialog: They're down.
	// Dialog: That's it.
	dialog_array = [ "moon_eag_kill_yell_03", "moon_eag_kill_yell_04" ];
	random_dialog = RandomIntRange( 0, dialog_array.size );
	level thread radio_dialogue( dialog_array[random_dialog] );

	wait( 1.0 );

	// Dialog: Walker, get on that turret!
	radio_dialogue( "moon_eag_ext_getturret" );
}

into_shadows_upper_deck_dialog()
{
	level endon( "vehicle_bay_return" );

	waittill_aigroupcount( "enemy_on_rovers", 15 );

	level notify( "start_shadows_shutter_open" );

	wait( 0.5 );

	if( !flag( "vehicle_bay_return" ) )
	{
		// Dialog: Watch it, up high!
		radio_dialogue( "moon_eag_ext_watchhigh" );
	}

	wait( 5.0 );

	if( !flag( "vehicle_bay_return" ) )
	{
		// Dialog: Watch the right side!
		radio_dialogue( "moon_eag_ext_rightside" );
	}
}

into_shadows_kill_dialog()
{
	level endon( "vehicle_bay_return" );

	waittill_aigroupcount( "enemy_on_rovers", 17 );
	// Dialog: He's down.
	// Dialog: That's a kill.
	// Dialog: Tango down!
	// Dialog: Good hit.
	dialog_array = [ "moon_eag_kill_yell_01", "moon_eag_kill_yell_02", "moon_eag_kill_yell_05", "moon_eag_kill_yell_06" ];
	random_dialog = RandomIntRange( 0, dialog_array.size );
	level thread radio_dialogue( dialog_array[random_dialog] );

	waittill_aigroupcount( "enemy_on_rovers", 13 );
	// Dialog: He's down.
	// Dialog: That's a kill.
	// Dialog: Tango down!
	// Dialog: Good hit.
	dialog_array = [ "moon_eag_kill_yell_01", "moon_eag_kill_yell_02", "moon_eag_kill_yell_05", "moon_eag_kill_yell_06" ];
	random_dialog = RandomIntRange( 0, dialog_array.size );
	level thread radio_dialogue( dialog_array[random_dialog] );

	waittill_aigroupcount( "enemy_on_rovers", 7 );
	// Dialog: He's down.
	// Dialog: That's a kill.
	// Dialog: Tango down!
	// Dialog: Good hit.
	dialog_array = [ "moon_eag_kill_yell_01", "moon_eag_kill_yell_02", "moon_eag_kill_yell_05", "moon_eag_kill_yell_06" ];
	random_dialog = RandomIntRange( 0, dialog_array.size );
	level thread radio_dialogue( dialog_array[random_dialog] );
}

into_shadows_move_on_dialog()
{
	level endon( "vehicle_bay_return" );
	level waittill( "into_shadows_all_enemies_spawned" );

	waittill_aigroupcount( "enemy_on_rovers", 2 );

	level notify( "enemy_on_rovers_low_count" );

//  exterior_goal_vol = GetEnt( "exterior_bay_enemies", "targetname" );
//  living_enemies = get_ai_group_ai( "enemy_on_rovers" );
//  array_thread( living_enemies, ::into_shadows_change_goalvolume, exterior_goal_vol );

	maps\nx_lunar_util::waittill_all_enemies_dead_or_dying( 15 );

	// Dialog: Okay lets move in.
	radio_dialogue( "moon_eag_ext_letsmove" );

	flag_set( "vehicle_bay_return" );
}

into_shadows_lsp_explosion()
{	
	flag_set( "lsp_explosion_2_is_current" );	

	level thread maps\nx_lunar_take_back_control::lsp_explosion_2();

	wait( 0.25 );

	PlayRumbleOnPosition( "heavy_3s", level._player.origin );
	Earthquake( 0.3, 3.0, level._player.origin, 500 );

	wait( 0.5 );

	thread audio_wait_for_volume_change();
	// Dialog: Damn it, there goes another one.
	level thread radio_dialogue( "moon_eag_ext_anothertrans" );

	// Dialog: They're trying to take the base.
	level thread radio_dialogue( "moon_eag_ext_takebase" );

	flag_clear( "lsp_explosion_2_is_current" );
}

audio_wait_for_volume_change()
{
	wait 3;
	level._player deactivatechannelvolumes( "snd_channelvolprio_shellshock", 1 );
}
into_shadows_spawns()
{
	level endon( "vehicle_bay_return" );

	array_spawn_function_targetname( "vehicle_bay_rover_enemies_1", maps\nx_lunar_util::lunar_enemy_exterior_common );
	array_spawn_function_targetname( "vehicle_bay_rover_enemies_1", ::into_shadows_idle_enemy_behavior );
	array_spawn_function_targetname( "vehicle_bay_rover_enemies_2", maps\nx_lunar_util::lunar_enemy_exterior_shadows_rover_riders );
	array_spawn_function_targetname( "rover_enemy_inside_vehicle_bay", maps\nx_lunar_util::lunar_enemy_exterior_long_range );

	rover_battle_enemies_remaining = get_ai_group_sentient_count( "enemy_rover_backup" );
	rover_enemies_group_1 = GetEntArray( "vehicle_bay_rover_enemies_1", "targetname" );
	spawn_limit = 12 - rover_battle_enemies_remaining;
	rover_1_enemies = maps\_nx_utility::spawn_targetname_and_return_array( "vehicle_bay_rover_enemies_1", spawn_limit );

	waittill_aigroupcount( "enemy_on_rovers", 18 );

	vehicle_bay_backup_enemies = maps\_nx_utility::spawn_targetname_and_return_array( "vehicle_bay_rover_enemies_backup" );

	if( level._player IsUsingTurret() )
	{
		vehicle_bay_rover_enemies = get_ai_group_ai( "enemy_on_rovers" );
		vehicle_bay_rover_enemies array_thread( vehicle_bay_rover_enemies, ::into_shadows_player_on_turret_behavior );
	}
	else
	{
		array_thread( vehicle_bay_backup_enemies, maps\nx_lunar_util::set_deadly_tracking_ai );
	}

	level waittill( "start_shadows_shutter_open" );

	maps\_nx_utility::spawn_targetname_and_return_array( "rover_enemy_inside_vehicle_bay" );

	wait( 0.05 );

	level notify( "into_shadows_all_enemies_spawned" );
}

into_shadows_idle_enemy_behavior()
{
	self disable_cqbwalk();
	self.maxsightdistsqrd = 750 * 750;
	self ClearEnemy();
	self ClearPotentialThreat();
	self.alertlevel = "noncombat";
}

/* into_shadows_stealth_shadows_switcher()
{
	level endon( "vehicle_bay_shadow_enemies_aware" );

	// Set initial visual range
//  enemies_alive = get_ai_group_ai( "enemy_on_rovers" );
//  array_thread( enemies_alive, ::into_shadows_player_out_of_shadows_behavior );

//  while(1)
//  {
//  	flag_wait( "currently_in_shadows" );
//  	// Lower visual range
		enemies_alive = get_ai_group_ai( "enemy_on_rovers" );
		array_thread( enemies_alive, ::into_shadows_player_in_shadows_behavior );
//  	wait( 0.05 );
//  	flag_waitopen( "currently_in_shadows" );
//  	// Raise visual range
//  	enemies_alive = get_ai_group_ai( "enemy_on_rovers" );
//  	array_thread( enemies_alive, ::into_shadows_player_out_of_shadows_behavior );
//  	wait( 0.05 );
//  }
} */

into_shadows_rover_unload_and_attack()
{
	bay_rover_1 = spawn_vehicle_from_targetname( "second_wave_rover_1" );
	bay_rover_1.main_turret = bay_rover_1.mgturret[0];
	bay_rover_2 = spawn_vehicle_from_targetname_and_drive( "second_wave_rover_2" );
	bay_rover_2.main_turret = bay_rover_2.mgturret[0];

	bay_rover_1.main_turret.hummer_turret_intial_mode = "manual";
	bay_rover_2.main_turret.hummer_turret_intial_mode = "manual";

	bay_rover_1 vehicle_lights_on( "running" );
	bay_rover_2 vehicle_lights_on( "running" );

	rover_array_of_targets = GetEntArray( "rover_bay_random_targets", "targetname" );

	target_number = RandomIntRange( 0, 3 );
	rover_target = rover_array_of_targets[target_number];
   
	target_number = RandomIntRange( 0, 3 );
	rover_target = rover_array_of_targets[target_number];

	bay_rover_1_turret_gunner = bay_rover_1.riders[1];
	bay_rover_1_driver = bay_rover_1.riders[0];
	bay_rover_2_turret_gunner = bay_rover_2.riders[1];
	
	level thread into_shadows_rover_turret_glow( bay_rover_1 );
	level thread into_shadows_rover_turret_glow( bay_rover_2 );

	wait( 0.5 );
	
	vehicle_bay_rover_enemies = get_ai_group_ai( "enemy_on_rovers" );

	issue_color_orders( "r100", "axis" );

	// Until player can patch himself while on the turret
	level._player thread into_shadows_player_on_turret( bay_rover_1.main_turret, bay_rover_2.main_turret );

	// Eagle moves to shadows
	level.eagle thread into_shadows_squad_movement( bay_rover_1, bay_rover_2 );

	level thread into_shadows_rovers_attack( bay_rover_1.main_turret, bay_rover_2.main_turret );
	level thread into_shadows_time_to_alert_counter( bay_rover_1_turret_gunner, bay_rover_2_turret_gunner, bay_rover_1.main_turret, bay_rover_2.main_turret );
	level thread into_shadows_eagle_kill( bay_rover_1_turret_gunner, bay_rover_2_turret_gunner );

	// Alert others if player is seen
	array_thread( vehicle_bay_rover_enemies, ::into_shadows_enemy_vision );

	bay_rover_1 thread vehicle_unload();

	// Get driver into the vehicle bay
	into_shadows_door_runner_node = GetNode( "into_shadows_door_runner_node", "targetname" );
	bay_rover_1_driver SetGoalNode ( into_shadows_door_runner_node );
	bay_rover_1_driver set_goal_radius( 10 );
	bay_rover_1_driver enable_cqbwalk();
	bay_rover_1_driver waittill( "goal" );

	bay_rover_2 waittill( "unloaded" );

	// Turn on specified mantles
	maps\nx_lunar_util::all_mantles_on( "into_shadows_mantles" ); 
}

into_shadows_rover_turret_glow( vehicle )
{
	self into_shadows_rover_turret_glow_worker( vehicle );
	
	//when the worker script is killed, we cleanup here:
	vehicle.mgturret[0] SetModel("nx_vehicle_chinese_lgv_main_turret");

}

into_shadows_rover_turret_glow_worker( vehicle )
{
	level endon( "vehicle_bay_return" ); //if the playe skips using the turret.
	level._player endon( "mount_turret" );
	
	vehicle waittill( "gunner_dead" );
	
	vehicle.mgturret[0] SetModel("nx_vehicle_ec_lgv_main_turret_obj");
	
	vehicle waittill( "run_to_turret" );	
}

into_shadows_death_alert_check( gunner_1, gunner_2, rover_1, rover_2 )
{
	level endon( "vehicle_bay_shadow_enemies_aware" );
	level endon( "into_shadows_alert_all" );

	if( flag( "vehicle_bay_shadow_enemies_aware" ) )
	{
		return;
	}

	gunner_1 thread into_shadows_set_flag_on_dead_or_dying( "into_shadows_gunner_1_enemy_dead" );
	gunner_2 thread into_shadows_set_flag_on_dead_or_dying( "into_shadows_gunner_2_enemy_dead" );

	enemies_alive = get_ai_group_ai( "enemy_on_rovers" );
	waittill_dead_or_dying( enemies_alive, 1 );

//  rover_1 turret_attack_player();
//  rover_2 turret_attack_player();

	// Let flags get set before checking them
	wait( 0.05 );

	for ( i = 0; i < 4; i++ )
	{
		// Check if gunner guard was killed
		if( flag( "into_shadows_gunner_1_enemy_dead" ) && !flag( "vehicle_bay_shadow_enemies_aware" ) )
		{
			// If killed was one of the intended two, wait
			wait( 2.0 );
		}
		// Check if gunner guard was killed
		if( flag( "into_shadows_gunner_2_enemy_dead" ) && !flag( "vehicle_bay_shadow_enemies_aware" ) )
		{
			// If killed was one of the intended two, wait
			wait( 2.0 );
		}
		if( flag( "into_shadows_gunner_1_enemy_dead" ) && flag( "into_shadows_gunner_2_enemy_dead" ) && !flag( "vehicle_bay_shadow_enemies_aware" ) )
		{
			flag_set( "into_shadows_stealth_kills_success" );
			wait( 2.0 );
		} 
	}
}

into_shadows_time_to_alert_counter( gunner_1, gunner_2, rover_1, rover_2 )
{	
	into_shadows_death_alert_check( gunner_1, gunner_2, rover_1, rover_2 );

	level notify( "stop_player_movement_control" );

	// Wait minimal time
	wait( 1.0 );

	// Dialog: Watch it, you’ve been spotted!
	radio_dialogue( "moon_eag_ext_spotted" );

	if( !flag( "into_shadows_stealth_kills_success" ) )
	{
		// Dialog: Weapons Free!
		radio_dialogue( "moon_eag_ext_33" );
	}

	flag_set( "vehicle_bay_shadow_enemies_aware" );

	// Set for progression
	flag_set( "player_made_it_to_shadows" );
	flag_set( "player_in_kill_position_rover" );

	if( level._player IsUsingTurret() )
	{
		vehicle_bay_rover_enemies = get_ai_group_ai( "enemy_on_rovers" );
		vehicle_bay_rover_enemies array_thread( vehicle_bay_rover_enemies, ::into_shadows_player_on_turret_behavior, true );
	}
	else
	{
		vehicle_bay_rover_enemies = get_ai_group_ai( "enemy_on_rovers" );
		vehicle_bay_rover_enemies array_thread( vehicle_bay_rover_enemies, ::into_shadows_death_alert_behavior, true );
	}

	// Wake up Eagle
	level.eagle maps\nx_lunar_util::clear_ignore_everything();	
	level.eagle disable_dontevershoot();

	// Run aggressive behaviors on two special ai and target player
	enemy_array = [gunner_1, gunner_2];

	for ( i = 0; i < 2; i++ )
	{
		selected_enemy = enemy_array[i];

		if( IsAlive( selected_enemy ) )
		{
			selected_enemy thread into_shadows_death_alert_behavior();
		}
	}
}

into_shadows_death_alert_behavior( first_time )
{
	alerted_enemy = self;
	alerted_enemy endon( "death" );

	if( IsDefined( first_time ) )
	{
		wait RandomFloatRange( 0.0, 1.0 );
		self enable_cqbwalk();
	}

	alerted_enemy maps\nx_lunar_util::set_deadly_tracking_ai( true );
}

into_shadows_player_on_turret_behavior( first_time )
{
	alerted_enemy = self;
	alerted_enemy endon( "death" );

	if( IsDefined( first_time ) )
	{
		wait RandomFloatRange( 0.0, 1.0 );
		self thread maps\nx_lunar_util::lunar_cqb_detect_and_switch( 750 );
	}

	alerted_enemy.maxsightdistsqrd = 8192 * 8192;
	alerted_enemy ClearEnemy();
	alerted_enemy ClearEntityTarget();

	random_chance = RandomIntRange( 1, 10 );
	if( random_chance < 6 )
	{
		alerted_enemy set_force_color( "r" );
	}
	else
	{
		alerted_enemy set_force_color( "y" );
	}

	alerted_enemy.favoriteenemy = level._player;

	if( IsDefined( first_time ) )
	{
		alerted_enemy.baseaccuracy = 0.0;
		// Slowly increase the enemy's accuracy
		for( i = 0; i < 7; i++ )
		{
			wait( 1.0 );
			alerted_enemy.baseaccuracy = alerted_enemy.baseaccuracy + 0.1;
		}
	}
}

into_shadows_set_flag_on_dead_or_dying( flag )
{
	level endon( "vehicle_bay_shadow_enemies_aware" );

	self waittill( "death" );
	flag_set( flag );
}

into_shadows_rovers_attack( rover_1, rover_2 )
{
	level waittill( "vehicle_bay_shadow_enemies_aware" );

	// Give player a moment to understand that he screwed up
	wait( 1.0 );

	rover_1 turret_attack_player();
	rover_2 turret_attack_player();
}

into_shadows_enemy_vision()
{
	enemy = self;
	enemy endon( "death" );
	enemy endon( "turn_off_vision" );

	starting_health = self.health;

	while( 1 )
	{
		if( enemy CanSee( level._player ) )
		{
			level notify( "into_shadows_alert_all" );
			break;
		}
			
		current_health = self.health;		
		if( current_health < starting_health )
		{
			level notify( "into_shadows_alert_all" );
			break;
		}
		wait( 1.0 );
	}
}

into_shadows_squad_movement( rover_1, rover_2 )
{
	level.eagle maps\nx_lunar_util::ignore_everything();
	level.eagle enable_dontevershoot();

	if( !flag( "rover_battle_enemies_aware" ) )
	{
		level.eagle waittill ( "goal" );
	}
	
	flag_wait( "into_shadows" );
	
	wait( 3.0 );	

	level waittill( "eagle_heading_to_shadows" );

	wait( 0.5 );

	level.eagle set_goal_radius( 10 );
	to_the_shadows_node = GetNode( "to_the_shadows_node", "targetname" );
	level.eagle SetGoalNode ( to_the_shadows_node );

	if( !flag( "vehicle_bay_shadow_enemies_aware" ) )
	{
		flag_wait( "player_made_it_to_shadows" );
	}

	level.eagle set_goal_radius( 10 );
	eagle_rover_shoot_node = GetNode( "eagle_rover_shoot_position", "targetname" );
	level.eagle SetGoalNode ( eagle_rover_shoot_node );
	
	flag_wait( "vehicle_bay_shadow_enemies_aware" );

	level.eagle set_goal_radius( 10 );
	into_shadows_eagle_perch_node = GetNode( "into_shadows_eagle_perch", "targetname" );
	level.eagle SetGoalNode ( into_shadows_eagle_perch_node );
	
	// This needs turret dismounts before implementation
//  level._player waittill( "mount_turret" );
//
//  rover_1.main_turret = bay_rover_1.mgturret[0];
//  rover_2.main_turret = bay_rover_1.mgturret[0];
//
//  gunner_1 = rover_1.main_turret GetTurretOwner();
//  gunner_2 = rover_2.main_turret GetTurretOwner();
//
//  if( !IsDefined( gunner_1 ) )
//  {
//  	level.eagle thread run_to_turret( rover_1 );
//  }
//  else if( !IsDefined( gunner_2 ) )
//  {
//  	level.eagle thread run_to_turret( rover_2 );
//  }
}

//into_shadows_rover_target_seeker( vehicle, turret )
//{
//    level endon( "vehicle_bay_shadow_enemies_aware" );
//
//    if( flag( "vehicle_bay_shadow_enemies_aware" ) )
//    {
//        return;
//    }
//
//    turret turret_do_not_attack_player();
//
//    vehicle waittill( "unloaded" );
//
//    if( IsAlive( vehicle.riders[0] ) )
//    {
//        gunner = vehicle.riders[0];
//        gunner endon( "death" );
//    }
//    else
//    {
//        return;
//    }
//
//    while( 1 )
//    {
//        turret turret_do_not_attack_player();
//
//        // Pause for searching
//        wait RandomFloatRange( 1.0, 4.0 );
//
//        // Fire at random target for duration
//        turret turret_attack_player();
//
//        // Get array of targets
//        rover_array_of_targets = GetEntArray( "rover_bay_random_targets", "targetname" );
//
//        target_time = RandomIntRange( 1, 3 );
//
//        change_target_chance = 10;
//
//        for ( i = 0; i < target_time; i++ )
//        {
//            // Turret possibly changes target
//            if( change_target_chance > 6 )
//            {
//                // Choose a new random target
//                target_number = RandomIntRange( 0, 3 );
//                rover_target = rover_array_of_targets[target_number];
//                turret maps\_mgturret::set_turret_target( rover_target );
//                // Turret explosion
//                wait .2;
//                PlayFX( level._effect[ "turret_explosion" ], rover_target.origin );
//            }
//
//            wait( 1.0 );
//            change_target_chance = RandomIntRange( 1, 10 );
//        }
//
//        // Turret fire time
//        wait RandomFloatRange( 1.0, 1.5 );
//    }
//}

//into_shadows_enemy_target_seeker( exclude_1, exclude_2, vehicle )
//{
//    if( flag( "vehicle_bay_shadow_enemies_aware" ) )
//    {
//        return;
//    }
//
//    vehicle waittill( "unloaded" );
//
//    if( IsAlive( self ) )
//    {
//        enemy = self;
//        enemy endon( "death" );
//    }
//    else
//    {
//        return;
//    }
//
//    if( enemy == exclude_1 || enemy == exclude_2 )
//    {
//        return;
//    }
//
//    // Get array of targets
//    enemy_array_of_targets = GetEntArray( "rover_bay_random_squad_targets", "targetname" );
//
//    enemy_target = undefined;
//
//    wait RandomFloatRange( 1.0, 2.0 );
//
//    while( !flag( "vehicle_bay_shadow_enemies_aware" ) )
//    {
//        // Pause fire time
//        wait RandomFloatRange( 1.0, 2.0 );
//
//        target_time = RandomIntRange( 1, 3 );
//
//        change_target_chance = 10;
//
//        for ( i = 0; i < target_time; i++ )
//        {
//            // Turret possibly changes target
//            if( change_target_chance > 8 )
//            {
//                // Choose a new random target
//                target_number = RandomIntRange( 0, 5 );
//                enemy_target = enemy_array_of_targets[target_number];
//                if( IsAlive( enemy ) )
//                {
//                    enemy SetEntityTarget( enemy_target );
//                    enemy SetLookAtEntity( enemy_target );
//                    enemy Shoot();
//
//                    wait( 0.5 );
//
//                    enemy SetLookAtEntity( enemy_target );
//                    enemy Shoot();
//                }
//                else
//                {
//                    break;
//                }
//            }
//            change_target_chance = RandomIntRange( 1, 10 );
//        }
//    }
//
//    if( IsAlive( enemy ) )
//    {
//        if( IsDefined( enemy_target ) )
//        {
//            enemy ClearEntityTarget( enemy_target );
//        }
//
//        enemy into_shadows_death_alert_behavior();
//    }
//}

into_shadows_eagle_kill( gunner_1, gunner_2 )
{
	level.eagle waittill_any( "stealth_attack", "vehicle_bay_shadow_enemies_aware" );

	level.eagle maps\nx_lunar_util::clear_ignore_everything();
	level.eagle ClearEnemy();

	if( IsDefined( level.eagle.maxsightdistsqrd ) )
	{
		level.eagle.oldmaxsightdistsqrd = level.eagle.maxsightdistsqrd;
	}

	level.eagle.maxsightdistsqrd = 2000 * 2000;

	level.eagle.oldbaseaccuracy = level.eagle.baseaccuracy;

	gunner_1 notify( "turn_off_vision" );
	gunner_2 notify( "turn_off_vision" );
	
	enemy_array = [gunner_1, gunner_2];

	waittill_dead_or_dying( enemy_array, 1, 23 );

	if( IsAlive( gunner_1 ) && IsAlive( gunner_2 ) )
	{
		eagle_does_the_work = true;
	}
	else
	{
		// Dialog: He's down.
		// Dialog: That's a kill.
		// Dialog: Good hit.
		dialog_array = [ "moon_eag_kill_yell_01", "moon_eag_kill_yell_02", "moon_eag_kill_yell_06" ];
		random_dialog = RandomIntRange( 0, dialog_array.size );
		level thread radio_dialogue( dialog_array[random_dialog] );
	}

	wait( 0.5 );

	foreach( enemy in enemy_array  )
	{
		if( IsAlive( enemy ) )
		{
			level.eagle.favoriteenemy = enemy;
			level.eagle.baseaccuracy = 50000.0;
			enemy.threatbias = 500000;	
			enemy.health = 1;

			level.eagle SetLookAtEntity();
			level.eagle OrientMode( "face enemy" );
			level.eagle.fixednode = false;
			level.eagle setgoalpos( level.eagle.origin );

			level.eagle disable_dontevershoot();

			MagicBullet( "lunarrifle", level.eagle.origin, enemy.origin );
			level.eagle Shoot( 1, enemy.origin);
			PlayFX( level._effect[ "charlie_impact" ], enemy.origin );

			enemy kill();
				
			enemy waittill( "death" );

			level.eagle enable_dontevershoot();

			level.eagle ClearEnemy();
			level.eagle.baseaccuracy = 0.0;
	
			wait( 1.0 );
		}
		else
		{
			wait( 0.05 );
		}
	}

	level.eagle waittill( "goal" );

	level.eagle disable_dontevershoot();

	level.eagle ClearEnemy();

	if( IsDefined( level.eagle.oldmaxsightdistsqrd ) )
	{
		level.eagle.maxsightdistsqrd = level.eagle.oldmaxsightdistsqrd;
	}

	if( IsDefined( level.eagle.oldbaseaccuracy ) )
	{
		level.eagle.baseaccuracy = level.eagle.oldbaseaccuracy;
	}
}

into_shadows_cleanup()
{
}

into_shadows_forced_cleanup()
{
	enemy_on_rovers = get_ai_group_ai( "enemy_on_rovers" );
	array_thread( enemy_on_rovers, maps\_nx_utility::delete_ai_not_bullet_shielded );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

turret_do_not_attack_player()
{
	self SetMode( "manual" );
	self ClearTargetEntity();
}

turret_attack_player()
{
	self endon( "death" );
	
	//early out if the turret gunner is already dead.
	if ( !IsTurretActive( self ) )
	{
		return;
	}
	
	self SetMode( "sentry" );
	self.ownervehicle waittill( "gunner_dead" );
	self SetMode( "manual" );
}
