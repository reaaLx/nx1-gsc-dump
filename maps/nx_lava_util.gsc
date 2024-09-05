//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Mission Utils												**
//                                                                          **
//    Created: DATE - CREATOR												**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_utility_code;
#include maps\_hud_util;
#include common_scripts\utility;
#include maps\_nx_utility;
#include maps\_vehicle;

DEBUG_ANIMATED_TRAIN_SPEEDS = false;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_start( player_start_origin_name )
{
	// Move player to start
	player_start_origin = GetEnt( player_start_origin_name, "targetname" );
	level._player setOrigin( player_start_origin.origin );
	level._player setPlayerAngles( player_start_origin.angles );
}


//*******************************************************************
//  ALLY SCRIPTS                                                    *
//                                                                  *
//*******************************************************************

// Add structs for each ally you want to spawn
// structs should have the "targetname": [whatever]_[ally name]
// for example keene's origin at the Outpost start is: outpost_start_keene
lava_ally_spawn( start_name )
{	
	// Spawn Keene
	keene_start = getStruct( start_name + "_keene", "targetname" );

	if( isDefined( keene_start ) )
	{
		keene_spawner = GetEnt( "keene", "targetname" );
		keene_spawner add_spawn_function( maps\nx_lava_util::lava_ally_common );
		level.keene = keene_spawner spawn_ai();
		level.keene.animname = "keene";
		level.keene.countryID = "jswc";
		level.keene set_battlechatter_id( "kee" );
	//	level.keene thread enable_cqbwalk();;

		level.keene thread l3_start_ally( keene_start );
	}


	// Spawn tilman
	tilman_start = getStruct( start_name + "_tilman", "targetname" );

	if( isDefined( tilman_start ) )
	{
		tilman_spawner = GetEnt( "tilman", "targetname" );
		tilman_spawner add_spawn_function( maps\nx_lava_util::lava_ally_common );
		level.tilman = tilman_spawner spawn_ai();
		level.tilman.animname = "tillman";
		level.tilman.countryID = "jswc";
		level.tilman set_battlechatter_id( "2" );

		level.tilman thread l3_start_ally( tilman_start );
	}

	// Spawn baker
	baker_start = getStruct( start_name + "_baker", "targetname" );

	if( isDefined( baker_start ) )
	{
		baker_spawner = GetEnt( "baker", "targetname" );
		baker_spawner add_spawn_function( maps\nx_lava_util::lava_ally_common );
		level.baker = baker_spawner spawn_ai();
		level.baker.animname = "baker";
		level.baker.countryID = "jswc";
		level.baker set_battlechatter_id( "bak" );

		level.baker thread l3_start_ally( baker_start );
	}

	// Spawn Franklin
	franklin_start = getStruct( start_name + "_franklin", "targetname" );

	if( isDefined( franklin_start ) )
	{
		franklin_spawner = GetEnt( "franklin", "targetname" );
		franklin_spawner add_spawn_function( maps\nx_lava_util::lava_ally_common );
		level.franklin = franklin_spawner spawn_ai();
		level.franklin.animname = "franklin";
		level.franklin.countryID = "jswc";
		level.franklin set_battlechatter_id( "0" );

		level.franklin thread l3_start_ally( franklin_start );
	}
}

lava_ally_common()
{
	self endon( "death" );

	// self enable_cqbwalk();
	self thread magic_bullet_shield();

	self.grenadeammo = 0;

	// Allies push player
	self pushplayer( true );

	// To setup thread bias
	// self SetThreatBiasGroup( "player_squad" );
	self thread hidden_dynamic_run_speed();
}

l3_start_ally( start_struct )
{
	self ForceTeleport( start_struct.origin, start_struct.angles );
	if( IsDefined( start_struct.target ) )
	{
		node = GetNode( start_struct.target, "targetname" );
		if( IsDefined( node ) )
		{
			self follow_path( node );
		}
	}
}

//*******************************************************************
//  			                                                    *
//                                                                  *
//*******************************************************************

ally_protect()
{
	if( IsDefined( self ) )
	{
		self.ignorerandombulletdamage = true;
		self.ignoresuppression = true;
		self.disableBulletWhizbyReaction = true;
		self thread disable_pain();
		self thread disable_surprise();
	}
}

ally_unprotect()
{
	if( IsDefined( self ) )
	{
		self.ignorerandombulletdamage = false;
		self.ignoresuppression = false;
		self.disableBulletWhizbyReaction = false;
		self thread enable_pain();
		self.dontavoidplayer = false;
		self thread enable_surprise();
	}
}

//*******************************************************************
//  DYNAMIC SPEED                                                   *
//                                                                  *
//*******************************************************************

// dynamic ally speed
hidden_dynamic_run_speed()
{
	self endon( "death" );
	level endon( "stop_dynamic_run_speed" );

	while( 1 )
	{
		look_at_ally = within_fov( level._player.origin, level._player.angles, self.origin, Cos( 100 ) );

		if( look_at_ally )
		{
			// slow down visible allies
			if( self.moveplaybackrate > 1.2 )
			{
				self set_moveplaybackrate( 1.2, 0.5 );
				self set_moveplaybackrate( RandomFloatRange( 1.0, 1.2 ) , 0.5 );
			}
		}
		else if( self.moveplaybackrate < 1.5 )
		{
			// speed up out of view allies
			self set_moveplaybackrate( 1.5 );
		}

		wait( 0.05 );
	}
}


// dynamic player speed
lunar_player_movement_control()
{
	self lunar_player_movement_controller();
	player_speed_default( 5.0 );
}

lunar_player_movement_controller()
{
	level endon( "stop_player_movement_control" );
	self endon( "dealth" );
	ai = self;

	while( 1 )
	{
		if( within_fov( ai.origin, ai.angles, level._player.origin, Cos( 90 ) ) )
		{	
			player_speed_set( 120, 2.0 );
		}
		else
		{
			if( players_within_distance( 200, ai.origin ) )
			{
				player_speed_set( 120, 2.0 );
			}
			else if( players_within_distance( 300, ai.origin ) )
			{
				player_speed_set( 130, 2.0 );
		
			}
			else if( players_within_distance( 400, ai.origin ) )
			{
				player_speed_set( 140, 2.0 );	
			}
			else
			{
				player_speed_default( 1.0 );
			}
		}
	
		wait( 0.5 );
	}
}


//*******************************************************************
//  ENEMY SCRIPTS                                                   *
//                                                                  *
//*******************************************************************

l3_enemy_common( isCQB )
{
	self endon( "death" );

	if( !IsDefined( isCQB ) )
		isCQB = false;

	if( isCQB )
	self enable_cqbwalk();
}

enemy_ignore( ignore_time )
{
	self endon( "death" );

	self.ignoreme = 1;
	wait( ignore_time );
	self.ignoreme = 0; 
}


//*******************************************************************
//  ENEMY SPAWN UTILS                                               *
//                                                                  *
//*******************************************************************

spawn_group_by_name( name, term, stagger )
{
	if( !isdefined( name ) )
		return false;
	if( !isdefined( term ) )
		term = "targetname";
	if( !isdefined( stagger ) )
		stagger = false;
	else if( stagger < .2 )
		stagger = .2;

	spawners = GetEntArray( name, term );

	foreach ( spawner in spawners )
	{
		spawner spawn_ai();

		if( stagger )
			wait( RandomFloatRange( .1, stagger ) );
		else
			waittillframeend;
	}
}

queue_next_flag( flag, aigroup, num_left, wait_time )
{
	if( isdefined( wait_time ) )
		wait( wait_time );
	if( !isdefined( num_left ) )
		num_left = 0;

	waittill_aigroupcount( aigroup, num_left );
	flag_set( flag );
}

//*******************************************************************
//  AI - GIVE NEW GOAL                                              *
//                                                                  *
//*******************************************************************

give_aigroup_new_goal( goal_name, ai_name, new_accuracy )
{
	if( !get_ai_group_sentient_count( ai_name ) )
		return false;
	
	guys = get_ai_group_ai( ai_name );
	goal_nodes = getNodeArray( goal_name + "_node", "targetname" );
	goal_volume = getent( goal_name + "_vol", "targetname" );

	if( guys.size > goal_nodes.size )
		num_runners = goal_nodes.size;
	else
		num_runners = guys.size;

	for( i = 0 ; i < num_runners ; i++ )
	{
		guy = guys[i];

		guy ClearGoalVolume();
		guy setGoalNode( goal_nodes[i] );
		guy setGoalVolume( goal_volume );

		if( isdefined( new_accuracy ) )
			guy set_baseaccuracy( new_accuracy );
	}
}


//*******************************************************************
//  MISC UTILITY	                                                *
//                                                                  *
//*******************************************************************

explodables_init()
{
	exploders = getentarray( "explode_target", "script_noteworthy" );
	
	foreach( exploder in exploders )
	{
		exploder enableAimAssist();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

platform_enemy_setup_locked_combat( platform, enemy_name, kill_flag, position_script, position_script_param )
{
	if( !IsDefined( position_script ) )
	{
		position_script = ::platform_enemy_update_positions;
	}
	
	// Setup each enemy
	platform.platform_enemies = [];
	platform_enemies = platform maps\_nx_moving_platform::get_platform_ents( enemy_name );

	foreach( index, platform_enemy_spawner in platform_enemies )
	{
		// Add spawn func
		platform_enemy_spawner add_spawn_function( ::platform_enemy_train_to_train_combat_spawn_func, kill_flag );

		// Spawn AI
		platform_enemy = platform_enemy_spawner spawn_ai();
		assert( isAlive( platform_enemy ) );
		platform.platform_enemies[ index ] = platform_enemy;

		// Check if has a hit box
		spawner_target = GetEnt( platform_enemy_spawner.target, "targetname" );
		if( spawner_target.classname == "script_brushmodel" )
		{		
			hit_box = spawner_target;
			platform_enemy thread platform_enemy_train_to_train_process_hit_box( hit_box );
			
			locked_combat_node = hit_box.target;
			platform_enemy maps\_locked_combat::init_locked_combat( locked_combat_node );
		}
		else
		{
			// Init locked combat
			locked_combat_node = platform_enemy_spawner.target;
			platform_enemy maps\_locked_combat::init_locked_combat( locked_combat_node );
		}
		
		// check for custom death anim
		if( IsDefined( platform_enemy_spawner.script_deathanim ) )
		{
			platform_enemy.animname = "generic";
			platform_enemy.linked_deathanim = platform_enemy_spawner.script_deathanim; // getGenericAnim( platform_enemy_spawner.script_deathanim );
		}
			
		if( IsDefined( position_script_param ) )
		{
			platform_enemy thread [[ position_script ]]( position_script_param );
		}
		else
		{
			platform_enemy thread [[ position_script ]]();
		}
	}
}

platform_enemy_train_to_train_combat_spawn_func( kill_flag )
{
	self endon( "death" );

	// Allow enemy to be killed
	self.allowdeath = true;
	self.no_gib = true;	

	// Lower accuracy
	self.baseaccuracy = 0.25;
	
	// Special death for platform enemies
	self.noragdoll 	= true;
	
	// Locked grenade tuning
	level._locked_grenade_check_interval = 5;
	level._locked_grenade_min_player_move_dist_sqr = 128 * 128;

	if( IsDefined( kill_flag ) )
	{
		flag_wait( kill_flag );
		if( IsDefined( self.magic_bullet_shield ) )
		{
			self stop_magic_bullet_shield();
		}
		self kill();
	}
}

DEBUG_TRAIN_TO_TRAIN_HIT_BOX = false;

platform_enemy_train_to_train_process_hit_box( hit_box )
{
	self endon( "death" );
	self endon( "hitbox_no_death" );
	self thread magic_bullet_shield();
	self.enable_hit_box = true;
	
	if( DEBUG_TRAIN_TO_TRAIN_HIT_BOX )
	{
		hit_box show();
	}
	else
	{
		hit_box hide();
	}	
	
	hit_box setCanDamage( true );
	hit_box LinkTo( self, "tag_origin", (0,0,40),  (0,0,0) );
	
	num_hits = 1;
	while( 1 )
	{
		hit_box waittill ( "damage", amount, attacker, direction_vec, point, type );		
		if( attacker == level._player && self.enable_hit_box )
		{
			num_hits--;	
		}

		if( num_hits <= 0 )
		{
			break;
		}
	}
	
	self thread stop_magic_bullet_shield();
	hit_box delete();
	self Kill();
}

DEBUG_LOCKED_COMBAT_TRANSITIONS = false;

platform_enemy_update_positions()
{
	self endon( "death" );
	self endon( "hitbox_no_death" );
	
	while( 1 )
	{
		// tagTC<note> - need has_transitions function or safe get_transitions
		transitions = self maps\_locked_combat::get_transitions();
		if( transitions.size > 0 )
		{
			random_transition = transitions[ randomint(transitions.size) ];
			self maps\_locked_combat::locked_combat_transition( random_transition );
		}
		
		if( !DEBUG_LOCKED_COMBAT_TRANSITIONS )
		{
			wait RandomFloatRange( 3.0, 4.0 );
		}
		else
		{
			wait RandomFloatRange( 1.0, 2.0 );
		}
	}
}

platform_enemy_move_on_flag( flag )
{
	self endon( "death" );

	transitions = self maps\_locked_combat::get_transitions();
	if( transitions.size > 0 )
	{
		random_transition = transitions[ randomint(transitions.size) ];

		flag_wait( flag );

		// Wait for player to see enemy
		while( 1 )
		{
			look_at_enemy = within_fov( level._player.origin, level._player getplayerangles(), self.origin, Cos( 20 ) );
			if( look_at_enemy )
			{
				//IPrintln( flag + " LOOK AT" );
				break;
			}
			wait( 0.05 );
		}
		
		self maps\_locked_combat::locked_combat_transition( random_transition );
	}
}

platform_enemy_move_on_flag_protect( flag )
{
	self endon( "death" );
	
	self thread platform_enemy_move_on_flag( flag );
	wait( 0.05 );
	self.enable_hit_box = false;
	flag_wait( flag );
	wait( 4.0 );
	self.enable_hit_box = true;
}

platform_enemy_move_on_flag_protect_short( flag )
{
	self endon( "death" );
	
	self thread platform_enemy_move_on_flag( flag );
	wait( 0.05 );
	self.enable_hit_box = false;
	flag_wait( flag );
	wait( 2.0 );
	self.enable_hit_box = true;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

turret_enemy_setup( platform, enemy_name, kill_flag )
{
	// Setup each enemy
	platform_enemies = GetEntArray( enemy_name, "targetname" );
	foreach( index, platform_enemy_spawner in platform_enemies )
	{
		// Add spawn func
		platform_enemy_spawner add_spawn_function( ::turret_enemy_spawn_func, platform, kill_flag );

		// Spawn AI
		platform_enemy = platform_enemy_spawner spawn_ai();
		assert( isAlive( platform_enemy ) );
		platform.platform_enemies[ index ] = platform_enemy;

		// check for custom death anim
		if( IsDefined( platform_enemy_spawner.script_deathanim ) )
		{
			platform_enemy.animname = "generic";
			platform_enemy.linked_deathanim = platform_enemy_spawner.script_deathanim; // getGenericAnim( platform_enemy_spawner.script_deathanim );
		}
	}
}

turret_enemy_spawn_func( platform, kill_flag )
{
	self endon( "death" );

	self thread maps\nx_lava_util::platform_enemy_train_to_train_combat_spawn_func();

	// Check if has a hit box
	turret_name = self.target;
	spawner_target = GetEnt( self.target, "targetname" );
	if( spawner_target.classname == "script_brushmodel" )
	{		
		hit_box = spawner_target;
		self thread platform_enemy_train_to_train_process_hit_box( hit_box );
		turret_name = hit_box.target;
	}
		
	// Give enemy the turret.
	turret = platform.vehicle.mgturret[0];
	platform.vehicle thread maps\_vehicle_aianim::guy_man_turret( self, 0, undefined ); //assuming only position 0.	
	
	self.baseaccuracy = 0.1;
	
	self thread turret_cleanup_ai_kill( turret );

	// No grenades
	self.grenadeammo = 0;
	
	// Kill flag
	if( IsDefined( kill_flag ) )
	{
		self thread turret_cleanup_kill_flag( turret, kill_flag );
		
		flag_wait( kill_flag );
		if( IsDefined( self.magic_bullet_shield ) )
		{
			self stop_magic_bullet_shield();
		}
		self kill();
	}
}

turret_cleanup_ai_kill( turret )
{
	self waittill( "death" );
	turret notify( "stopfiring" );
}

turret_cleanup_kill_flag( turret, kill_flag )
{
	flag_wait( kill_flag );
	turret notify( "stopfiring" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

setup_train( train_name_array, hide_vehicle )
{
	train_array = setup_train_platforms( train_name_array );
	setup_train_vehicles( train_array, hide_vehicle );
	
	return train_array;
}

setup_train_platforms( train_name_array )
{
	train_array = [];
	foreach( train_name in train_name_array )
	{
		train = maps\_nx_moving_platform::init( train_name[0] );
		
		if( IsDefined( train ) )
		{
		train.vehicle_name = train_name[1];
		
		train_array[ train_array.size ] = train;
	}
	}

	return train_array;
}

setup_train_vehicles( train_array, hide_vehicle )
{
	foreach( train in train_array )
		{
		vehicle = GetEnt( train.vehicle_name, "targetname" );
			if( IsSpawner( vehicle ) )
			{
				vehicle = vehicle_spawn( vehicle );
			}

		// Link train to vehicle
		train maps\_nx_moving_platform::link_platform_to_vehicle( vehicle, hide_vehicle );
		train.vehicle = vehicle;
	}
	}

move_train( train_array, speed, accel, decel )
{
	foreach( train in train_array )
	{
		vehicle = train.vehicle;
		vehicle_node = GetVehicleNode( vehicle.target, "targetname" );
		vehicle AttachPath( vehicle_node );
		vehicle Vehicle_SetSpeed( speed, accel, decel );
		vehicle GoPath();
	}

	level thread stop_all_trains( train_array );
}

stop_all_trains( train_array )
{
	train_array[0].vehicle waittill( "reached_end_node" );

	set_train_speed( train_array, 0, 10000, 10000 );
}

set_train_speed( train_array, speed, accel, decel )
{
	foreach( train in train_array )
	{
		if( IsDefined( train ) )
		{
		vehicle = train.vehicle;
		vehicle Vehicle_SetSpeed( speed, accel, decel );
	}
}
}

delete_train( train_array )
{
	foreach( train in train_array )
	{
		train.vehicle delete();
		train maps\_nx_moving_platform::platform_delete();
	}
}


//*******************************************************************
//	AUTOMATED TRAIN SETUP                                           *
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

// take a train and make it visible or invisible ("show" or "hide")
// send in a train array and a string "show" or "hide"
show_hide_train( train_array, vis, andVehicle )
{
	if( !IsDefined( andVehicle ) )
		andVehicle = false;
	
	foreach( train in train_array )
	{
		// train vis
		train maps\_nx_moving_platform::platform_process_all_elements( vis );
		
		// vehicle vis
		if( andVehicle )
		{
			if( vis == "hide" )
				train.vehicle hide();
			else if( vis == "show" )
				train.vehicle show();
		}
	}
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

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vehicle_array_follow_ai_group( ai_group_name, train_array, center_link_point, time_low, time_high, speed_percent, arc, base_speed )
{
	self endon( "stop_follow_ai_group" );
	self endon( "reached_end_node" );
	
	ai_group = get_ai_group_ai( ai_group_name );
	
	foreach( ai in ai_group )
	{
		self stop_follow_player();
		self thread vehicle_array_follow_player_shared( train_array, ai, center_link_point, time_low, time_high, speed_percent, arc, base_speed );
		
		while( 1 )
		{
			if( !IsAlive( ai ) )
			{
				break;
			}
			wait( 0.05 );
		}
	}	
}

vehicle_array_follow_player( train_array, follow_ent, time_low, time_high, speed_percent, arc, base_speed )
{
	self thread vehicle_array_follow_player_shared( train_array, follow_ent, follow_ent, time_low, time_high, speed_percent, arc, base_speed );	
}

// tagTC<hack> - merge this and below into one function
vehicle_array_follow_player_shared( train_array, origin_ent, angles_ent, time_low, time_high, speed_percent, arc, base_speed )
{
	origin_ent endon( "death" );
	self endon( "stop_follow_player" );
	self endon( "reached_end_node" );

	while( 1 ) 
	{
		if( !IsDefined( origin_ent ) )
		{
			break;
		}
		
		to_player = VectorNormalize( origin_ent.origin - level._player.origin );
		right_angles = AnglesToForward( angles_ent.angles );
		dot = VectorDot( right_angles, to_player );

		foreach( train in train_array )
		{
			vehicle = train.vehicle;
			vehicle vehicle_follow_player_set_speed( dot, arc, base_speed, speed_percent );
		}

		random_wait = RandomFloatRange( time_low, time_high );
		wait( random_wait );
	}

}

vehicle_follow_player_set_speed( dot, arc, base_speed, speed_percent )
{
	if( dot > ( arc / 100 ) ) 
	{
		//IPrintlnBold( "AHEAD " + dot );
		if( IsDefined( self.animated ) && self.animated )
		{
			self thread set_car_speed_animated( base_speed - ( base_speed * speed_percent ) );
		}
		else
		{
			self Vehicle_SetSpeed( base_speed - ( base_speed * speed_percent ) );
		}
	}
	else if( dot < ( -1 * arc / 100 ) )
	{
		//IPrintlnBold( "BEHIND " + dot );	
		if( IsDefined( self.animated ) && self.animated )
		{
			self thread set_car_speed_animated( base_speed + ( base_speed * speed_percent ) );
		}
		else
		{
			self Vehicle_SetSpeed( base_speed + ( base_speed * speed_percent ) );
		}
	}
	else
	{
		//IPrintlnBold( "IN RANGE" );
		if( IsDefined( self.animated ) && self.animated )
		{
			self thread set_car_speed_animated( base_speed );
		}
		else
		{
			self Vehicle_SetSpeed( base_speed );
		}
	}
}

vehicle_follow_player( follow_ent, time_low, time_high, speed_percent, arc, base_speed )
{
	self endon( "death" );
	self endon( "stop_follow_player" );
	self endon( "reached_end_node" );

	while( 1 ) 
	{
		to_player = VectorNormalize( follow_ent.origin - level._player.origin );
		right_angles = AnglesToForward( follow_ent.angles );
		dot = VectorDot( right_angles, to_player );

		self vehicle_follow_player_set_speed( dot, arc, base_speed, speed_percent );

		random_wait = RandomFloatRange( time_low, time_high );
		wait( random_wait );
	}
}

stop_follow_ai_group()
{
	self notify( "stop_follow_ai_group" );
	self notify( "stop_follow_player" );
}

stop_follow_player()
{
	self notify( "stop_follow_player" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

BASE_ANIMATED_TRAIN_SPEED = 100; // MPH

setup_animated_train( train_name_array, type )
{
	train_array = [];
	vehicle_array = [];
	foreach( train_name in train_name_array )
	{
		train = maps\_nx_moving_platform::init( train_name[0] );
		vehicle = train_name[1];

		// Link train to vehicle
		train maps\_nx_moving_platform::link_platform_to_vehicle( vehicle, false );
		train.vehicle = vehicle;	
		train_array[ train_array.size ] = train;
	}

	return train_array;
}

set_car_speed_animated_internal( speed, accel, decel )
{
	// Bail if we start another speed change. 
	self endon( "set_car_speed_animated" );

	// Make sure we have the default speed set. 
	if ( !IsDefined( self.train_anim_speed )) 
	{
		// Defaults to 100mph.
		self.train_anim_speed = BASE_ANIMATED_TRAIN_SPEED;
	}

	// Acceleration. 
	if ( !IsDefined( accel ))
	{
		if ( IsDefined( self.train_anim_accel ))
		{
			accel = self.train_anim_accel;
		}
		else 
		{
			accel = 50;
		}
	}

	// Deceleration. 
	if ( !IsDefined( decel ))
	{
		if ( IsDefined( self.train_anim_decel ))
		{
			decel = self.train_anim_decel;
		}
		else 
		{
			decel = 10;
		}
	}

	self.train_anim_accel = accel;
	self.train_anim_decel = decel;

	// If we are already at the correct speed, bail out. 
	if ( speed == self.train_anim_speed )
	{
		return;
	}

	// Get local acceleration. 
	if( speed >= self.train_anim_speed )
	{
		slow_down = false;
		mph_per_frame = accel * 0.05;
	}
	else 
	{
		slow_down = true;
		mph_per_frame = decel * -0.05;
	}

	// Apply acceleration to speed and set anim rate. 
	while ( 1 )
	{
		// Accelerate. 
		self.train_anim_speed += mph_per_frame;

		// Clamp.
		if ( slow_down == false && self.train_anim_speed > speed 
			|| ( slow_down && self.train_anim_speed < speed ))
		{
			self.train_anim_speed = speed;
		}

		// Set anim rate based on speed. 
		rate = self.train_anim_speed / BASE_ANIMATED_TRAIN_SPEED;
		anime = level._scr_anim[ self.animname ][ self.train_anim ];
		self SetAnim( anime, 1, 0, rate );

		if ( DEBUG_ANIMATED_TRAIN_SPEEDS )
		{
			if ( self.animname == "train_allied_car01" )
			{
				iprintln( self.train_anim + " rate = " + rate );
			}
		}

		// Finished. 
		if ( self.train_anim_speed == speed )
		{
			break;
		}

		wait( 0.01 );
	}
}

set_car_speed_animated( speed, accel, decel )
{
	self notify( "set_car_speed_animated" );

	self set_car_speed_animated_internal( speed, accel, decel );

	if ( DEBUG_ANIMATED_TRAIN_SPEEDS )
	{
		if ( self.animname == "train_allied_car01" )
		{
			IPrintLnBold( "ending thread for " + self.animname );
		}
	}
}

move_train_animated( train_array, speed, accel, decel )
{
	foreach( train in train_array )
	{
		train.vehicle thread set_car_speed_animated( speed, accel, decel );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

all_triggers_off( trigger_name )
{
	triggers = GetEntArray( trigger_name, "script_noteworthy" );
	foreach( trigger in triggers )
	{
		trigger trigger_off();
	}
}

all_triggers_on( trigger_name )
{
	triggers = GetEntArray( trigger_name, "script_noteworthy" );
	foreach( trigger in triggers )
	{
		trigger trigger_on();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

IPrintlnBold_triggers()
{
	triggers = GetEntArray( "iprintlnbold", "targetname" );
	foreach( trigger in triggers )
	{
		trigger thread IPrintlnBold_triggers_thread();	
	}
}

IPrintlnBold_triggers_thread()
{
	self waittill( "trigger" );
	IPrintlnBold( self.script_parameters );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

delete_entire_ai_group( ai_group )
{
	// Delete this ai group
	ai_group = get_ai_group_ai_including_dying( ai_group );

	foreach( guy in ai_group )
	{
		if( IsDefined( guy.magic_bullet_shield )  && guy.magic_bullet_shield )
		{ 	
			guy stop_magic_bullet_shield();
		}
		guy delete();
	}
}

blowup_ai_group( ai_group_name )
{
	// kill alive guys
	ai_group = get_ai_group_ai( ai_group_name );
	foreach( guy in ai_group )
		guy thread blowup_ai_func();
	
	// cleanup dead guys
	dying_ai = get_ai_group_ai_dying( ai_group_name );
	foreach( ai in dying_ai )
	{
		ai delete();
	}
}

blowup_ai_func()
{
	self endon( "death" );
	
	if( IsDefined( self.linked_deathanim ) )
	{
		// setup
		self notify( "hitbox_no_death" );
		
		// unlock
		self.locked_combat = undefined;
		
		// animate
		node = getent( self.target, "targetname" );
		node  maps\_anim::anim_generic( self, self.linked_deathanim );
		
		// cleanup
		self stop_magic_bullet_shield();
		self delete();
	}
}

// Low powered earthquake used to simulate chopper rumble
slightly_vibrate_camera()
{
	level endon( "end_camera_vibrate" );
	for( ;; )
	{
		Earthquake( 0.1, 0.5, level._player.origin, 0 );
		level._player PlayRumbleOnEntity( "train_rail_seam" );
		wait 0.90;
	}
}

slightly_vibrate_camera_end()
{
	level notify( "end_camera_vibrate" );

	Earthquake( 0.06, 0.05, level._player.origin, 0 );
}

slightly_tilt_ground_plane()
{
	level endon( "end_tilt_ground" );

	
	level._ground_ref_ent = spawn( "script_model", ( 0, 0, 0 ) );
	level._player PlayerSetGroundReferenceEnt( level._ground_ref_ent );

	pitch_sin = 0;
		
	time = 0.9;
	last_angles = level._player getplayerangles()[1];
	while ( true )
	{
		new_angles = level._player getplayerangles()[1];
		dif = new_angles - last_angles;
		yaw = dif;//ent.origin[0] + dif;
		last_angles = new_angles;

		new_sin = sin( gettime() * -0.1 );
		pitch_sin += new_sin * 10;
		
		pitch = sin( pitch_sin ) * RandomFloatRange(2, 5);
		wait 0.05;

		pitch_portion = RandomFloatRange(0, 1); //so it's not the same pitch/roll ratio.
		level._ground_ref_ent RotateTo( ( pitch *pitch_portion, 0, pitch * (1.0-pitch_portion) ), time, time * 0.5, time * 0.5 );
	
		wait (time - 0.05);
	}	
}

slightly_tilt_ground_plane_end()
{
	 level notify( "end_tilt_ground" );
}

start_fake_train_movement( tilt_ground )
{
	level notify ("end_fake_train_movement"); //just to make sure it's cleared out.
	waittillframeend;

	level thread slightly_vibrate_camera();

	if( !IsDefined(tilt_ground) || tilt_ground )
	{
		level thread slightly_tilt_ground_plane();
	}

	level waittill( "end_fake_train_movement" );

	slightly_vibrate_camera_end();
	slightly_tilt_ground_plane_end();
}