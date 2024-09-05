//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module: Lava Train Interior											**
//                                                                          **
//    Created: 07/25/10 - Travis Chen (trchen x 4143)						**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_anim;
#include maps\_nx_vignette_util;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
	// tagTC<temp> delete after daryl has removed car
	destroy_car = GetEnt( "train_interior_destroy_car", "targetname" );
	if( IsDefined( destroy_car ) )
	{
		destroy_car delete();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
	precachestring( &"NX_LAVA_INTROSCREEN_1" );
	precachestring( &"NX_LAVA_INTROSCREEN_2" );
	precachestring( &"NX_LAVA_INTROSCREEN_3" );
	precachestring( &"NX_LAVA_INTROSCREEN_4" );
	precachestring( &"NX_LAVA_INTROSCREEN_5" );
	
	PreCacheItem( "lunar_ecr" );
	PreCacheItem( "lunar_srm1216" );

	//viewmodels precached for train separate fall vignette
	PreCacheModel( "viewmodel_lunarrifle_prototype" );
	PreCacheModel( "viewmodel_lunar_ecr" );
	PreCacheModel( "viewmodel_lunar_glo" );
	PreCacheModel( "viewmodel_lunar_srm1216" );
	PreCacheModel( "viewmodel_dragunov" );
	//these are old and will eventaully need to be removed
	PreCacheModel( "viewmodel_lunarrifle" );
	PreCacheModel( "viewmodel_ecr" );
	PreCacheModel( "viewmodel_spas12" );
	
	PreCacheRumble( "train_rail_seam" );
}

section_flag_inits()
{
	flag_init( "infinite_tunnel_start" );
	flag_init( "first_door_open" );
	flag_init( "player_on_turret" );
	flag_init( "player_on_turret_anim_complete" );
	flag_init( "ally_1_reveal_vignette_done" );
	flag_init( "ally_2_reveal_vignette_done" );
	flag_init( "car_1_move_train" );
	flag_init( "car_2_move_train" );
	
	flag_init( "car_2_ally_push_1" );
	flag_init( "car_2_ally_push_2" );
	//fx flags
	flag_init( "fakehits_fx_01" );
	flag_init( "fakehits_fx_02" );
	
	flag_init( "train_interior_spawn_enemies" );
	flag_init( "ally_1_reveal_vignette" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_objectives( objective_num )
{
	flag_wait( "train_interior_car_5" );

	// Add objective
	waypoint = getEnt( "turret_objective", "targetname" );
	Objective_Add( objective_num, "current", &"NX_LAVA_OBJECTIVE_TURRET" );
	Objective_Current( objective_num );
	Objective_OnEntity( objective_num, waypoint );

	flag_wait( "player_on_turret" );

	// Clear Objective
	objective_complete( objective_num );
	objective_num++;

	return objective_num;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_interior_vo()
{
	flag_wait( "ally_1_reveal_vignette" );
	
	wait( 2.5 );
	
	radio_dialogue( "lava_bak_trnint_needtokeepmoving" );

	flag_wait( "train_interior_car_3" );
	
	radio_dialogue( "lava_bak_trnint_contactsocfor" );

	flag_wait( "train_interior_car_3_move_up" );

	radio_dialogue( "lava_bak_trnint_pushforward" );
	
	flag_wait( "train_interior_car_4" );
	
	radio_dialogue( "lava_bak_trnint_tangosahead" );
	
	flag_wait( "train_interior_car_4_up_front" );

	radio_dialogue( "lava_bak_trnint_3upfront" );
	radio_dialogue( "lava_bak_trnint_engaging" );
}

// tagTC<note> - remove global and write a get function
TRAIN_2_SPEED = 130;

train_interior_start()
{
	maps\nx_lava_util::player_start( "player_start_train_interior" );
	
	flag_set( "vignette_bridge_to_train_done" );
}

train_interior()
{
	// tagTC<note>, temp for demo, need to remove once we compile back in whole mission
	flag_wait( "introscreen_complete" );

	level._player TakeAllWeapons();
	level._player GiveWeapon( "lunarrifle" );
	level._player GiveWeapon( "lunar_srm1216" );
	level._player GiveWeapon( "moon_grenade" );
	level._player SwitchToWeapon( "lunarrifle" );
	
	// VO
	level thread train_interior_vo();
	
	flag_wait( "vignette_bridge_to_train_done" );
	
	// Setup transport train
	level thread train_interior_setup();
	
	// Move transport train
	level thread train_interior_move();

	// Setup train 3
	level thread train_3_setup();
	
	// Infinite tunnel
	level thread train_interior_infinite_tunnel();

	level thread maps\nx_lava_util::start_fake_train_movement();

	// Turret fire
	level thread train_3_turret_gunner();
		
	level thread fakehits_fx_01();
	//level thread fakehits_fx_02(); 
}

train_interior_standup_setup()
{
	// Setup the train interior start mover
	train_name_array = [ [ "train_interior_standup_train", "train_interior_standup_train_vehicle" ] ];
	level.train_interior_standup_train = maps\nx_lava_util::setup_train( train_name_array, true ); 
		
	// Move front vehicle
	vehicle_node = GetVehicleNode( "train_interior_standup_start", "targetname" );
	level.train_interior_standup_train[0].vehicle AttachPath( vehicle_node );
	level.train_interior_standup_train[0].vehicle Vehicle_SetSpeed( TRAIN_2_SPEED, 100, 10 );
	level.train_interior_standup_train[0].vehicle suspend_drive_anims_for_vignette();
	level.train_interior_standup_train[0].vehicle GoPath();
	level.train_interior_standup_train[0].vehicle Hide();

	level.train_interior_standup_train[0].vehicle waittill( "reached_end_node" );
	level notify( "standup_train_stop" );
}

train_interior_standup()
{	
	node = GetEnt( "train_interior_standup_anim_node", "targetname" );

	level._player disableweapons();
	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	
	player_rig = spawn_anim_model( "player_rig" );
	player_rig LinkTo( node );
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, 0, 0, 0, 0, true );

	guys = [];
	guys["player_rig"] = player_rig;

	level thread train_interior_standup_setup();
	level thread train_interior_standup_delay_enemies();
	
	node anim_single( guys, "train_interior_getup" );

	player_rig Delete();
	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );	
	level._player enableweapons();
}

train_interior_standup_delay_enemies()
{
	wait( 2.0 );
	flag_set( "train_interior_spawn_enemies" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_interior_setup()
{
	// Setup Train 2 Turret vehicle
	maps\nx_lava_util::setup_train_vehicles( level.train_turret, false );

	turret = GetEnt( "turret_player", "targetname" );
	turret SetDefaultDropPitch( 15 );

	maps\nx_lava_util::show_hide_train( level.train_turret, "hide", true );

	destroy_car_vehicle = GetEnt( "train_interior_vignette_destroy_car_vehicle", "targetname" );
	destroy_car_array = GetEntArray( "train_interior_vignette_destroy_car", "targetname" );
	destroy_car_vehicle hide();
	foreach( part in destroy_car_array )
	{
		part Hide();
	}
	
	flag_wait( "train_interior_car_3" );
	
	// Show the turret car 
	level.train_turret[4] maps\_nx_moving_platform::platform_show();
	level.train_turret[4].vehicle Show();

	destroy_car_vehicle Show();
	foreach( part in destroy_car_array )
	{
		part Show();
	}
		
	flag_wait( "train_seperate_fall_player_done" );
	
	maps\nx_lava_util::show_hide_train( level.train_turret, "show", true );
}

train_interior_move()
{
	// Move train at 0 on path
	level.train_turret maps\nx_lava_util::train_switch_target( "train_2_front_t2t");
	thread maps\nx_lava_util::move_train( level.train_turret, 0.0, 10000, 10 );
	
	// tagTC<note> Don't turn on headlight till on turret train
	flag_wait( "train_seperate_fall_player_done" );
		
	//adding in some fx for the headlight: apm
	if( IsDefined( level.train_3 ) )
	{
		level.train_3[0].vehicle maps\nx_lava_fx::set_train_headlight_fx_on();
	}
	
	//adding in some fx for the headlight: apm
	level.train_turret[4].vehicle maps\nx_lava_fx::set_train_headlight_fx_on(); 
}

infinite_tunnel_init() 
{
	if( !IsDefined( level.infinite_tunnel_init ) )
	{
		// Init the infinite tunnel segments
		infinite_tunnel_segment_array = [ "infinite_tunnel_segment_1", 
										  "infinite_tunnel_segment_2",
										  "infinite_tunnel_segment_3",
										  "infinite_tunnel_segment_4" ];
	
		maps\_nx_infinite_tunnel::infinite_tunnel_init( infinite_tunnel_segment_array, "infinite_tunnel_before", "infinite_tunnel_after", "infinite_tunnel_clip" );
	
		level.infinite_tunnel_init = true;
	}
}

train_interior_infinite_tunnel()
{
	// Standup Vignette
	level thread train_interior_standup();
	
	// tagTC<note> - Temp model, talk to Mike about replacing
	static_model_array = GetEntArray( "train_interior_rear_geo", "targetname" );
	foreach( static_model in static_model_array )
		static_model Hide();

	infinite_tunnel_init();
	
	flag_wait( "vignette_bridge_to_train_done" );

	level thread autosave_now();
	
	flag_set( "infinite_tunnel_start" );

	// Start the infinite tunnel
	maps\_nx_infinite_tunnel::infinite_tunnel_start( TRAIN_2_SPEED );

	// tagTC<note> - Temp model, talk to Mike about replacing
	static_model_array = GetEntArray( "train_interior_rear_geo", "targetname" );
	foreach( static_model in static_model_array )
		static_model Show();
	
	// Wait for player to open door, remove door
	//first_door_use = GetEnt( "first_door_use", "targetname" );
	//first_door_use sethintstring( &"NX_LAVA_FIRST_DOOR_USE" );		
	//first_door_use waittill( "trigger" );
	//first_door_use trigger_off();
	//first_door = GetEnt( "first_door", "targetname" );
	//first_door delete();

	//flag_set( "first_door_open" );

	level thread train_interior_encounters();

	flag_wait( "player_on_turret" );
	
	// End the infinite tunnel
	maps\_nx_infinite_tunnel::infinite_tunnel_end();
	
	// Show the moving train model
	//moving_model = getEnt( "train_transport_front_moving_model", "targetname" );
	//moving_model show();
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

	level.train_3 = maps\nx_lava_util::setup_train( train_name_array, false );

	// Thread vignettes
	level thread maps\nx_lava_train_2::train_3_vignettes();
	
	//SFX for enemy train
	if ( !flag( "train3_sfx_on" ) )
	{
		level.train_sfxarray = GetEntArray( "train_sfx_node", "targetname");
	level.train_3[0].vehicle thread maps\_vehicle::play_train_line_sfx( level.train_sfxarray, "nx_lava_enemy_train" );	
	level.train_3[0].vehicle thread maps\_vehicle::play_train_line_sfx( level.train_sfxarray, "nx_lava_enemy_train_squeaks" );		
		flag_set( "train3_sfx_on" );
	}

	maps\nx_lava_util::move_train( level.train_3, TRAIN_2_SPEED + 20, 115, 10 );

	level waittill( "standup_train_stop" );

	maps\nx_lava_util::set_train_speed( level.train_3, 20, 10000, 10000 );
	
	wait( 3.45 );
	
	maps\nx_lava_util::set_train_speed( level.train_3, 0.0, 10, 10 );
	
	flag_wait( "car_1_move_train" );

	maps\nx_lava_util::set_train_speed( level.train_3, 15, 10, 10 );
	wait( 8.75 );
	maps\nx_lava_util::set_train_speed( level.train_3, 0.0, 10, 10 );
	
	flag_wait( "car_2_move_train" );
	
	maps\nx_lava_util::set_train_speed( level.train_3, 15, 10, 10 );
	
	wait( 16.0 );

	maps\nx_lava_util::set_train_speed( level.train_3, 0.0, 10, 10 );

	flag_wait( "train_seperate_fall_player_done" );
	
	maps\nx_lava_util::set_train_speed( level.train_3, 15, 10, 10 );
	
	wait( 5.0 );
	
	maps\nx_lava_util::set_train_speed( level.train_3, 0.0, 10, 10 );
}

train_3_turret_gunner()
{
	flag_wait( "train_interior_turret_fire_start" );
	level thread maps\nx_lava_util::turret_enemy_setup( level.train_3[4], "train_3_car_5_turret_enemy", "train_2_player_in_tunnel" );	
	level thread fake_turret_fire( level.train_3[4].vehicle );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_interior_encounters()
{
	level thread train_interior_ally_thread();
	level thread train_interior_enemy_thread();
}

train_interior_ally_thread()
{
	level thread ally_1_reveal_vignette();
	//level thread ally_2_reveal_vignette();
}

ally_1_reveal_vignette()
{
	platform_ally_spawner = GetEnt( "train_interior_ally_1", "targetname" );
	platform_ally_spawner add_spawn_function( ::train_interior_ally_1_spawn_func );
	
	flag_wait( "introscreen_complete" );
	flag_wait( "vignette_train2_keene_reveal" );

	flag_set( "ally_1_reveal_vignette" );
	
	ally_1 = platform_ally_spawner spawn_ai();
	opfor = vignette_actor_spawn("vignette_tillman_reveal_opfor", "opfor");
	level.ally_1 = ally_1;
	
	ally_1.animname = "keene";
	maps\nx_lava_anim::train2_keenereveal( ally_1, opfor );
	
	level thread autosave_now();
	
	opfor vignette_actor_delete();

	flag_set( "ally_1_reveal_vignette_done" );
}

train_interior_ally_1_spawn_func()
{
	self endon( "death" );

	self enable_cqbwalk();
	self maps\nx_lava_util::ally_protect();
	self.noreload = true;

	self thread magic_bullet_shield();

	self.ignoreme = true;
	
	flag_wait( "car_2_ally_push_1" );

	self thread ally_1_rambo_thread();
	
	flag_wait( "car_2_ally_push_2" );
	
	self.ignoreme = false;
	
	flag_wait( "train_interior_car_3_ally_run" );
	
	self PushPlayer( true );
	self disable_cqbwalk();
	
	flag_wait( "train_interior_car_3_player_vignette_done" );
	
	teleport_struct = GetStruct( "ally_car_3_teleport",  "targetname" );
	self ForceTeleport( teleport_struct.origin, teleport_struct.angles );
	target_node = GetNode( teleport_struct.target, "targetname" );
	self SetGoalNode( target_node );
	self.baseaccuracy = 0.25;	

	level thread autosave_now();
	
	// Scale back accuracy for car 4
	flag_wait( "train_interior_car_4" );
	
	teleport_struct = GetStruct( "ally_car_4_teleport",  "targetname" );
	self ForceTeleport( teleport_struct.origin, teleport_struct.angles );
	self.baseaccuracy = 0.25;	
}

ally_1_rambo_thread()
{
	level endon( "train_interior_car_2_middle" );
	
	while ( 1 )
	{
		self ShootBlank();
		interval = RandomFloatRange( 0.2, 0.3 );
		wait( interval );
	}
}

train_interior_ally_2_spawn_func()
{
	self endon( "death" );

	self enable_cqbwalk();
	self maps\nx_lava_util::ally_protect();

	self thread magic_bullet_shield();
	
	// Scale back accuracy for car 4
	flag_wait( "train_interior_car_4" );
	self.baseaccuracy = 0.25;
}

teleport_ally_to_node( eNode )
{
	self ForceTeleport( eNode.origin, eNode.angles );
	self SetGoalPos( self.origin );
}

ally_unprotect()
{
	if( IsDefined( self ) )
	{
		self.ignorerandombulletdamage = false;
		self.ignoresuppression = false;
		self.disableBulletWhizbyReaction = false;
		self thread enable_pain();
		self thread enable_surprise();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_interior_enemy_thread()
{
	flag_wait( "train_interior_spawn_enemies" );
	
	// Car 1  
	car_1_spawners = GetEntArray( "train_interior_enemy_car_1_wave_1", "targetname" );
	array_thread( car_1_spawners, ::add_spawn_function, ::train_interior_enemy_car_1_spawn_func );
	flag_wait( "vignette_bridge_to_train_done" );
	array_thread( car_1_spawners, ::spawn_ai );

	car_1_spawners = GetEntArray( "train_interior_enemy_car_1_wave_2", "targetname" );
	array_thread( car_1_spawners, ::add_spawn_function, ::train_interior_enemy_car_1_spawn_func );

	car_1_spawners = GetEntArray( "train_interior_enemy_car_1_wave_2_jumper", "targetname" );
	array_thread( car_1_spawners, ::add_spawn_function, ::train_interior_enemy_car_1_jumper_spawn_func );
	
	// Car 2
	level thread train_interior_car_2_spawn_jumpers();
	
	car_2_spawners = GetEntArray( "train_interior_enemy_car_2_wave_1", "targetname" );
	array_thread( car_2_spawners, ::add_spawn_function, ::train_interior_enemy_car_2_wave_1_spawn_func );

	//car_2_spawners = GetEntArray( "train_interior_enemy_car_2_wave_2", "targetname" );
	//array_thread( car_2_spawners, ::add_spawn_function, ::train_interior_car_2_shared_spawn_func );
	
	car_2_spawners = GetEntArray( "train_interior_enemy_car_2_wave_3", "targetname" );
	array_thread( car_2_spawners, ::add_spawn_function, ::train_interior_enemy_car_2_wave_3_spawn_func );

	car_2_spawners = GetEntArray( "train_interior_enemy_car_2_wave_4", "targetname" );
	array_thread( car_2_spawners, ::add_spawn_function, ::train_interior_enemy_car_2_wave_4_spawn_func );

	car_2_spawners = GetEntArray( "train_interior_enemy_car_2_wave_4_retreater", "targetname" );
	array_thread( car_2_spawners, ::add_spawn_function, ::train_interior_car_2_retreater_spawn_func );
	
	// Car 3
	car_3_spawners = GetEntArray( "train_interior_enemy_car_3_wave_1", "targetname" );
	array_thread( car_3_spawners, ::add_spawn_function, ::train_interior_enemy_car_3_spawn_func );

	car_3_spawners = GetEntArray( "train_interior_enemy_car_3_wave_2", "targetname" );
	array_thread( car_3_spawners, ::add_spawn_function, ::train_interior_enemy_car_3_spawn_func );

	car_3_spawners = GetEntArray( "train_interior_enemy_car_3_jumper", "targetname" );
	array_thread( car_3_spawners, ::add_spawn_function, ::train_interior_enemy_car_3_jumper_spawn_func );

	// Car 4
	car_4_spawners = GetEntArray( "train_interior_enemy_car_4_wave_1", "targetname" );
	array_thread( car_4_spawners, ::add_spawn_function, ::train_interior_enemy_car_4_spawn_func );
	
	level thread car_4_group_thread();
}

train_interior_enemy_shared_spawn_func()
{
	self endon( "death" );

	self enable_cqbwalk();

	if( IsDefined( self.script_battleplan ) && self.script_battleplan == "follow_path" )
	{
		start_node = GetNode( self.target, "targetname" );
		maps\_spawner::go_to_node( start_node );
	}
		
	self maps\_nx_retreat::check_retreat_triggers();

	self.dontmelee = true;
	self.no_gib = true;
	self thread disable_surprise();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_interior_enemy_car_1_spawn_func()
{
	self thread train_interior_enemy_shared_spawn_func();
	
	self.goalradius = 0;
	self.ignoresuppression = true;
	self.noreload = true;
}

train_interior_enemy_car_1_jumper_spawn_func()
{
	self thread train_interior_enemy_shared_spawn_func();
	self.goalradius = 0;
	self.ignoresuppression = true;
	self.noreload = true;
	
	self waittill( "traverse_started" );
	wait( 2.0 );
	
	flag_set( "car_1_move_train" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_interior_car_2_shared_spawn_func()
{
	self thread train_interior_enemy_shared_spawn_func();
	
	self.ignoresuppression = true;
	self.noreload = true;
	self thread set_baseaccuracy( 0.75 );
}

train_interior_car_2_spawn_jumpers()
{
	car_2_jumper_1 = GetEntArray( "train_interior_enemy_car_2_jumper_1", "targetname" );
	array_thread( car_2_jumper_1, ::add_spawn_function, ::train_interior_enemy_car_2_jumper_1_spawn_func );

	car_2_jumper_2 = GetEntArray( "train_interior_enemy_car_2_jumper_2", "targetname" );
	array_thread( car_2_jumper_2, ::add_spawn_function, ::train_interior_enemy_car_2_jumper_2_spawn_func );

	flag_wait( "car_2_jumpers_ready" );
	
	if( !flag( "car_2_player_on_right_side" ) )
	{
		// Wait for player to see enemy
		look_at = GetEnt( "car_2_jumpers_look_at",  "targetname" );
		while( 1 )
		{
			look_at_enemy = within_fov( level._player.origin, level._player getplayerangles(), look_at.origin, Cos( 50 ) );
			if( look_at_enemy )
			{
				break;
			}
			wait( 0.05 );
		}
	}
	
	array_thread( car_2_jumper_1, ::spawn_ai );
	
	if( !flag( "car_2_player_on_right_side" ) )
	{
		wait( 1.5 );
	}
	
	array_thread( car_2_jumper_2, ::spawn_ai );
	
	wait( 2.0 );
	
	flag_set( "car_2_move_train" );
}

train_interior_enemy_car_2_jumper_1_spawn_func()
{
	self thread train_interior_car_2_shared_spawn_func();
	
	self.baseaccuracy = 0.25;
	self.allowdeath = true;
	self.script_forcegoal = 1;
	self.ignoresuppression = true;
	self.goalradius = 0;

	self waittill( "traverse_finished" );
}

train_interior_enemy_car_2_jumper_2_spawn_func()
{
	self thread train_interior_car_2_shared_spawn_func();
	
	self.baseaccuracy = 0.25;
	self.allowdeath = true;
	self.script_forcegoal = 1;
	self.ignoresuppression = true;
	self.goalradius = 0;
	//self magic_bullet_shield();
	
	self waittill( "traverse_finished" );
	
	//self stop_magic_bullet_shield();
	
	// Custom death anim
	self.animname = "generic";
	self set_generic_deathanim( "train_car_2_death" );
	self.health = 5;
	self.allowdeath = true;
	self.DropWeapon = false;
	self.noreload = true;
}

train_interior_enemy_car_2_wave_1_spawn_func()
{
	level endon( "car_2_player_on_right_side" );
	self thread train_interior_enemy_car_2_wave_1_right_side();
	
	self thread train_interior_car_2_glass_thread();
	
	self.health = 5;
	self.noreload = true;
	
	self endon( "death" );
	
	self thread train_interior_enemy_car_2_wave_1_vo();
	
	self thread train_interior_car_2_shared_spawn_func();
	
	self.ignoreme = true;
	
	self waittill( "retreating" );
	
	wait( 1.0 );
	
	// Push ally up
	flag_set( "car_2_ally_push_1" );
	issue_color_orders( "r13", "allies" );
	
	// Allow player some time to kill
	wait( 1.0 );
	
	// Ally kill enemy, shoot out right window
	self.ignoreme = false;
	level.ally_1 Shoot( 0.0, self.origin );
	glass = GetGlass( "car_2_window_right" );
	DestroyGlass( glass, ( 0, 1, 0 ) );
	
	playfxontag( level._effect[ "nx_lunar_intro_blood_squirt" ], self, "tag_eye" );
	playfxontag( level._effect[ "nx_lunar_intro_glass_hit" ], self, "tag_eye" );
	self Kill();
}

train_interior_enemy_car_2_wave_1_right_side()
{
	self endon( "death" );
	
	flag_wait( "car_2_player_on_right_side" );

	// Push ally up
	flag_set( "car_2_ally_push_1" );
	issue_color_orders( "r13", "allies" );
	
	// Allow player some time to kill
	wait( 0.5 );
	
	// Ally kill enemy, shoot out right window
	self.ignoreme = false;
	level.ally_1 Shoot( 0.0, self.origin );
	glass = GetGlass( "car_2_window_right" );
	DestroyGlass( glass, ( 0, 1, 0 ) );
	
	playfxontag( level._effect[ "nx_lunar_intro_blood_squirt" ], self, "tag_eye" );
	playfxontag( level._effect[ "nx_lunar_intro_glass_hit" ], self, "tag_eye" );
	self Kill();
}

train_interior_enemy_car_2_wave_1_vo()
{
	wait( 0.5 );
	radio_dialogue( "lava_bak_trnint_contactright" );
	
	self waittill( "death" );
	radio_dialogue( "lava_bak_trnint_goodkill" );
	
	wait( 0.5 );
	
	radio_dialogue( "lava_bak_trnint_advancingwatchleft" );	
}

train_interior_car_2_glass_thread()
{
	self waittill( "retreating" );
	wait( 0.2 );
	
	self Shoot( 0.0, level._player.origin );
	glass = GetGlass( "car_2_window_left" );
	DestroyGlass( glass, ( 0, 1, 0 ) );
	
	self waittill( "death" );
}


train_interior_enemy_car_2_wave_3_spawn_func()
{
	self endon( "death" );

	self thread train_interior_car_2_shared_spawn_func();
	
	self.script_forcegoal = 1;
	self.goalradius = 0;
	self.noreload = true;
	
	// Custom death anim
	self.animname = "generic";
	self set_generic_deathanim( "train_car_2_death_2" );
	self.health = 5;
	self.allowdeath = true;
	self.DropWeapon = false;
	
	self thread train_interior_enemy_car_2_wave_3_vo();
	
	self.ignoreme = true;
	self thread magic_bullet_shield();
	
	flag_wait( "train_interior_car_2_middle" );
	
	self.ignoreme = false;
	wait( 0.5 );
	self thread stop_magic_bullet_shield();
	level.ally_1 Shoot( 0.0, self.origin );
	
	playfxontag( level._effect[ "nx_lunar_intro_blood_squirt" ], self, "tag_eye" );
	playfxontag( level._effect[ "nx_lunar_intro_glass_hit" ], self, "tag_eye" );
	
	self Kill();
}

train_interior_enemy_car_2_wave_3_vo()
{
	self waittill( "death" );
	radio_dialogue( "lava_bak_trnint_clear_02" );
	
	wait( 0.5 );

	radio_dialogue( "lava_bak_trnint_tangos12oclock" );
}

train_interior_car_2_retreater_spawn_func()
{
	self thread train_interior_car_2_shared_spawn_func();
	self thread train_interior_car_2_retreater_vo();
}

train_interior_car_2_retreater_vo()
{
	self waittill( "death" );
	radio_dialogue( "lava_bak_trnint_clearmoveup" );
}

train_interior_enemy_car_2_wave_4_spawn_func()
{
	self endon( "death" );
	self thread train_interior_car_2_shared_spawn_func();

	flag_wait( "car_2_player_on_right_side_2" );
	
	self Kill();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_interior_enemy_car_3_jumper_spawn_func()
{
	self endon( "death" );
	
	self thread train_interior_enemy_shared_spawn_func();
	self.baseaccuracy = 0.1;

	self waittill( "traverse_finished" );
	
	self thread magic_bullet_shield();
	train_roof_clip = GetEnt( "train_roof_clip", "targetname" );
	train_roof_clip delete();

	self.noragdoll = false;
	//self.health = 5;
	self.allowdeath = true;
	self.skipDeathAnim = true;
	self.DropWeapon = false;
	self.noreload = true;
	
	self waittill ( "damage", amount, attacker, direction_vec, point, type );	
	
	self.animname = "generic";
	node = spawn( "script_origin", ( 0, 0, 0 ) );
	node.origin = self.origin;
	node.angles = self.angles;
	node anim_single_solo( self, "train_roof_death" );
	self stop_magic_bullet_shield();
	self delete();
}

train_interior_enemy_car_3_spawn_func()
{
	self thread train_interior_enemy_shared_spawn_func();
	self.script_forcegoal = 1;
	self.goalradius = 0;
	self.noreload = true;
	
	self.ignoreall = true;
	
	flag_wait( "train_interior_car_3_player_vignette_done" );
	
	self.ignoreall = false;
}

train_interior_enemy_car_4_spawn_func()
{
	self thread train_interior_enemy_shared_spawn_func();
	self.ignoresuppression = true;
	self.noreload = true;
	self thread set_baseaccuracy( 0.4 );	
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

car_4_group_thread()
{
	waittill_aigroupcleared( "car_4_ai_group" );
	radio_dialogue( "lava_bak_trnint_roomclear" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_interior_front_VO()
{
	flag_wait( "fakehits_fx_02" );
	
	radio_dialogue( "lava_bak_tr2turr_hvywpn10oclock" );

	flag_wait( "train_seperate_fall_player_done" );
	radio_dialogue( "lava_bak_tr2turr_takingfire" );
	radio_dialogue( "lava_bak_trnint_jump" );
	
	//flag_wait( "vignette_trainseperate_player_jump_done" );

	//radio_dialogue( "lava_bak_tr2turr_manturret" );
}

train_interior_front_start()
{	
	maps\nx_lava_util::player_start( "player_start_train_interior_front" );

	// Setup transport train
	level thread train_interior_setup();
	
	// Move transport train
	level thread train_interior_move();

	level.train_interior_front_jump_to = true;
	
	// Delete the moving train model
	moving_model = getEnt( "train_transport_moving_model", "targetname" );
	if( IsDefined( moving_model ) )
	{
		moving_model delete();
	}

	level._player TakeAllWeapons();
	level._player GiveWeapon( "ecr_ar" );
	level._player GiveWeapon( "spas12" );
	level._player SwitchToWeapon( "ecr_ar" );

	ally_1_spawner = GetEnt( "train_interior_ally_1", "targetname" );
	ally_1_spawner add_spawn_function( ::train_interior_ally_1_spawn_func );
	ally_1 = ally_1_spawner spawn_ai();
	level.ally_1 = ally_1;

	ally_1_start = GetStruct( "train_interior_front_ally_1", "targetname" );
	ally_1 StopAnimScripted();
	ally_1 ForceTeleport( ally_1_start.origin, ally_1_start.angles );
	
	flag_set( "train_interior_car_3" );
}

train_interior_front()
{
	level thread train_interior_front_VO();
	
	level thread maps\nx_lava_util::start_fake_train_movement();
	
	flag_wait( "vignette_trainseperate_fall" );
	
	level._player playsound("scn_lava_train_fall");

	train_destruction_sfx = spawn( "sound_emitter", ( 10, 10, 10 ) );
	train_destruction_sfx linkto ( level._player );
	train_destruction_sfx PlaySound( "scn_lava_train_build_destruction" );
	//level._player playsound("scn_lava_train_build_destruction");

	// Animate vehicle
	animate_vehicle = level.train_turret[4].vehicle;

	// Ally fall down -> jump, player fall down
	level thread train_seperate_fall_fx();
	level.ally_1.animname = "keene";
	level thread maps\nx_lava_anim::train_seperate_fall( level.ally_1, animate_vehicle );
	flag_wait( "train_seperate_fall_player_done" );
	
	// Player jump
	flag_wait( "vignette_trainseperate_player_jump" );
	train_destruction_sfx stopsounds();
	level thread train_seperate_player_jump_fx();
	level._player playsound("scn_lava_train_seperate");
	//level._player StopLoopSound("scn_lava_train_build_destruction");
	maps\nx_lava_anim::train_seperate_player_jump( level.ally_1 );
	
	train_interior_board_turret();
}

train_seperate_fall_fx()
{
	//exploder ( "fakehits01" );
	thread maps\nx_lava_fx::train_sep_jump_blast_fx();	

	wait( 0.2 );
	
	train_seperate_fall_fx = GetEnt( "train_seperate_fall_fx", "targetname" );
	
	Earthquake( 0.5, 2, level._player.origin, 10000 );
	
	 
	//playfx( getfx( "turret_explosion" ), train_seperate_fall_fx.origin );
}

train_seperate_player_jump_fx()
{

//exploder ( "train_sep_jump_blast" );

	wait( 1.5 );
	
	train_seperate_player_jump_fx = GetEnt( "train_seperate_player_jump_fx", "targetname" );
	
	Earthquake( 0.3, 2, level._player.origin, 10000 );
	
	thread maps\nx_lava_fx::train_sep_big_blast_fx();
	//playfx( getfx( "turret_explosion" ), train_seperate_player_jump_fx.origin );
}

animate_board( turret )
{
	self maps\_nx_chinese_lgv::turret_animate_board( turret );
	flag_set( "player_on_turret_anim_complete" );
}

train_interior_board_turret()
{
	turret = GetEnt( "turret_player", "targetname" );

	vehicle = GetEnt( "turret_player_vehicle", "targetname" );

	// tagBK<NOTE> Position the turret correctly, because it is not on a vehicle. 
	turret Unlink();
	tag_turret = vehicle GetTagOrigin( "tag_turret" );
	turret.origin = tag_turret;
	tag_turret = vehicle GetTagAngles( "tag_turret" );
	turret.angles = tag_turret;
	turret LinkTo( vehicle, "tag_turret" );

	//Add in the hint.
	mount = Spawn( "script_model", ( 0, 0, 0 ) );
	mount LinkTo( vehicle, "TAG_PLAYER_TURRET_MOUNT", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	mount MakeUsable();
	// Press and hold^3 &&1 ^7to board.
	mount SetHintString( &"NX_VEHICLES_TURRET_MOUNT" );

	turret MakeUnusable();

	mount waittill( "trigger" );
	level._player playsound("lava_mount_lgv");

	turret SetDefaultDropPitch( 0 );

	vehicle thread animate_board( turret );

	// Wait for a prime moment in the animation to unhide everything. 
	wait( 0.4 );

	flag_set( "player_on_turret" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

fakehits_fx_01()
{
    flag_wait( "fakehits_fx_01" ); 
    thread maps\nx_lava_fx::start_fake_railgun_fx();//exploder ( "fakehits01" ); 
}

fakehits_fx_02()
{
///nuthin to do here
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

fake_turret_fire( vehicle )
{
	level._player thread fake_turret_target_thread( vehicle );
	level._player fake_turret_fire_targeting( vehicle );
}

fake_turret_target_thread( vehicle )
{
	target_1 = GetEnt( "train_interior_turret_target_1", "targetname" );
	level.fake_turret_target = target_1;
	
	vehicle.mgturret[0].baseaccuracy = 0.0;
	
	flag_wait( "player_on_turret" );
	
	vehicle.mgturret[0].baseaccuracy = 0.25;
	
	self notify ( "stop_fake_turret_fire" );
	vehicle.mgturret[0] SetTargetEntity( level._player );
}

fake_turret_fire_targeting( vehicle )
{
	self endon( "stop_fake_turret_fire" );
	
	offsetMinX = 32;
	offsetMaxX = 256;
	offsetMinY = 32;
	offsetMaxY = 256;	
	offsetMinZ = 32;
	offsetMaxZ = 128;	

	//vehicle.mgturret[0] SetTurretWeapon( "nx_chinese_lgv_turret_fake" );
	vehicle.mgturret[0].fireInterval = 1.0;

	while ( 1 )
	{
		vehicle.mgturret[0] SetTargetEntity( level.fake_turret_target );
	
		// Re-roll the randoms
		randX_offset = RandomIntRange( offsetMinX, offsetMaxX );
		randY_offset = RandomIntRange( offsetMinY, offsetMaxY );
		randZ_offset = RandomIntRange( offsetMinZ, offsetMaxZ );

		// Randomize left/right Y offset
		if( cointoss() )
		{
			randY_offset *= -1;
		}

		// Move the target entity to the random position
		level.fake_turret_target.origin =  (self.origin + (randX_offset,randY_offset,randZ_offset));
		wait 1;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************




