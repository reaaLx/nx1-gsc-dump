//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_LUNAR Mission Utils										**
//                                                                          **
//    Created: 10/14/2010 - Travis Chen										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_utility_code;
#include maps\_hud_util;
#include common_scripts\utility;
#include maps\_nx_utility;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

lunar_enemy_interior_common( zero_goalradius )
{
	if( !IsDefined( zero_goalradius ) )
	{
		zero_goalradius = true;
	}

	self endon( "death" );

	self enable_cqbwalk();
	self thread lunar_headshot_monitor();
	self thread lunar_accuracy_limiter();

	// Ally team mates ingore enemy for a period of time
	self thread enemy_ignore( 3.0 );

	// Don't throw grenades in the interior
	self.grenadeammo = 0;
	self.script_forcegoal = 1;

	// Zero the goal radius
	if( zero_goalradius )
	{
		self.goalradius = 0;
	}

	self.ignoresuppression = true;
}

lunar_enemy_exterior_common()
{
	self endon( "death" );

	self enable_cqbwalk();
	self thread lunar_headshot_monitor();
//  self thread lunar_accuracy_limiter();

	// Ally team mates ingore enemy for a period of time
	self thread enemy_ignore( 1.0 );

	self.script_forcegoal = 1;
}

lunar_enemy_exterior_exit()
{
	self endon( "death" );

	self thread lunar_headshot_monitor();

	self enable_cqbwalk();

	self.script_startrunning = 1;
	self thread lunar_do_not_shoot_detect_and_switch( 300 );

	// Ally team mates ingore enemy for a period of time
	self thread enemy_ignore( 10.0 );

	self.script_forcegoal = 1;
	self.force_grenade_drop = true;
}

lunar_enemy_exterior_valley()
{
	self endon( "death" );

	self thread lunar_headshot_monitor();

	self enable_cqbwalk();

	// Setup runners
	if ( !players_within_distance( 2500, self.origin ) )
	{
		self thread lunar_accuracy_limiter_over_time( 50 );
		self.script_startrunning = 1;
		self thread lunar_do_not_shoot_detect_and_switch( 500 );
	}

	// Ally team mates ingore enemy for a period of time
	self thread enemy_ignore( 10.0 );

	self.script_forcegoal = 1;
	self.force_grenade_drop = true;
}

lunar_enemy_exterior_behind()
{
	self endon( "death" );

	self enable_cqbwalk();
	self thread lunar_headshot_monitor();
	self thread lunar_accuracy_limiter_no_hit();

	// Ally team mates ingore enemy for a period of time
	self thread enemy_ignore( 5.0 );

	self.script_forcegoal = 1;
	self.script_startrunning = 1;
}

lunar_enemy_plateau()
{
	self endon( "death" );

	self enable_cqbwalk();
	self thread lunar_headshot_monitor();
//  self thread lunar_accuracy_limiter();

	// Ally team mates ingore enemy for a period of time
	self thread enemy_ignore( 3.0 );

	self.goalradius = 10;
	self.script_forcegoal = 1;
	self.force_grenade_drop = true;

//  self.ignoresuppression = true;
}

lunar_enemy_rover_backup()
{
	self endon( "death" );

	self enable_cqbwalk();
	self thread lunar_headshot_monitor();
//  self thread lunar_accuracy_limiter();

	// Ally team mates ingore enemy for a period of time
	self thread enemy_ignore( 3.0 );

	// Don't throw grenades
	self.grenadeammo = 0;
	self.goalradius = 0;
	self.script_forcegoal = 1;

//  self.ignoresuppression = true;
}

lunar_enemy_exterior_stealth()
{
	self endon( "death" );

	self enable_cqbwalk();
	self thread lunar_headshot_monitor();

// tagDK<note> - temp for stealth
	self SetThreatBiasGroup( "enemy_in_shadows" );
//  self.maxsightdistsqrd = 880 * 880;

	self.ignoresuppression = true;
}

lunar_enemy_exterior_shadows_rover_riders()
{
	self endon( "death" );

	self.script_forcegoal = 1;
	self thread lunar_cqb_detect_and_switch( 500 );
	self thread lunar_headshot_monitor();
	self thread lunar_vision_limiter_over_time( 80 );
}

lunar_enemy_exterior_long_range()
{
	self endon( "death" );

	self enable_cqbwalk();
	self thread lunar_headshot_monitor();

	self.maxsightdistsqrd = 8000 * 8000;

	self.script_forcegoal = 1;

	self.ignoresuppression = true;
}

enemy_ignore( ignore_time )
{
	self endon( "death" );

	self.ignoreme = 1;
	wait( ignore_time );
	self.ignoreme = 0; 
}

// Lowers accuracy, waits for enemy to arrive at the initial goal node, then bumps to normal
lunar_accuracy_limiter()
{
	self endon( "death" );
	self.baseaccuracy = 0.8;
	self waittill( "goal" );
	self.baseaccuracy = 1.0;
}

lunar_accuracy_limiter_no_hit()
{
	self endon( "death" );
	self.baseaccuracy = 0.0;
	self waittill( "goal" );
	self.baseaccuracy = 1.0;
}

lunar_accuracy_limiter_over_time( time ) //seconds
{
	self endon( "death" );

	self.baseaccuracy = 0.0;

	accuracy_increase = 1/time;

	release_distance = 200;

	for( i = 0; i < time; i++ )
	{
		if( players_within_distance( release_distance, self.origin ) )
		{
			break;
		}
		{
			self.baseaccuracy = self.baseaccuracy + accuracy_increase;
			wait( 1.0 );
		}
	}

	self.baseaccuracy = 1.0;
}

lunar_cqb_detect_and_switch( distance )
{
	self endon( "death" );

	// distance from goal to switch from run to cqb
	if( !IsDefined( distance ) )
	{
		distance = 100;
	}

	self.goalradius = distance;

	self waittill( "goal" );

	self.goalradius = 10;

	self enable_cqbwalk();
}

lunar_do_not_shoot_detect_and_switch( distance )
{
	self endon( "death" );

	self enable_dontevershoot();

	// Allow ai to shoot
	if( !IsDefined( distance ) )
	{
		distance = 500;
	}

	self.goalradius = distance;

	self waittill( "goal" );

	self.goalradius = 10;

	self disable_dontevershoot();
}

lunar_vision_limiter_over_time( time ) //seconds
{
	self endon( "death" );

	self.maxsightdistsqrd = 1 * 1;

	vision_increase = 8192/time;

	for( i = 0; i < time; i++ )
	{
		self.maxsightdistsqrd = self.maxsightdistsqrd + ( vision_increase * vision_increase );
		wait( 1.0 );
	}
}

lunar_headshot_monitor()
{
	for( ; ; )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, idFlags );
		if ( ( isdefined( attacker ) ) && ( isplayer( attacker ) ) )
		{
			if ( ( isdefined( partName ) ) && ( partName == "j_head" || partName == "j_neck" ) )
			{
				self kill();
			}
		}

		if( !isalive( self ) )
		{
			return;
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

lunar_ally_spawn()
{
	// Spawn Eagle
	eagle_spawner = GetEnt( "eagle", "targetname" );
	eagle_spawner thread add_spawn_function( maps\nx_lunar_util::lunar_ally_interior_common );
	level.eagle = eagle_spawner spawn_ai();
	level.eagle.animname = "eagle";
	level.eagle.countryID = "jswc";
	level.eagle set_battlechatter_id( "eag" );

	// Spawn Falcon
	falcon_spawner = GetEnt( "falcon", "targetname" );
	falcon_spawner thread add_spawn_function( maps\nx_lunar_util::lunar_ally_interior_common );
	level.falcon = falcon_spawner spawn_ai();
	level.falcon.animname = "falcon";
	level.falcon.countryID = "jswc";
	level.falcon set_battlechatter_id( "fal" );
}

lunar_ally_interior_common()
{
	self endon( "death" );

	self enable_cqbwalk();
	self thread magic_bullet_shield();

	self.grenadeammo = 0;

	// Allies push player
	self pushplayer( true );

	// To setup thread bias
	self SetThreatBiasGroup( "player_squad" );
	self thread hidden_dynamic_run_speed();
}

lunar_ally_exterior_fodder()
{
	self endon( "death" );

	self enable_cqbwalk();

	self.baseaccuracy = 0.0;

	self.health = 1;

	self.grenadeammo = 0;

	self.ignoreSuppression = true;

	self.grenadeawareness = 0;
}

lunar_ally_exterior_fleeing_fodder()
{
	self endon( "death" );

	self enable_cqbwalk();

	self.script_startrunning = 1;

	self.grenadeammo = 0;

	self.baseaccuracy = 0.0;

	self.health = 1;

	self.ignoreSuppression = true;

	self.grenadeawareness = 0;
}

ignore_allies( ignore )
{
	level.eagle.ignoreme = ignore;
	level.falcon.ignoreme = ignore;
}

ally_ignore_all( distance )
{
	self endon( "death" );

	self.ignoreall = 1;

//  self.goalradius = distance;

	self waittill( "goal" );

	self.ignoreall = 0; 
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

lunar_start( player_struct, eagle_struct, falcon_struct, hawk_struct, pigeon_struct, seagull_struct )
{
	// Spawn AI allies
	level thread lunar_ally_spawn();
	waittillframeend;

	// Move player to start
	start = getstruct( player_struct, "targetname" );
	level._player setOrigin( start.origin );
	level._player setPlayerAngles( start.angles );

	// Teleport allies
	if( IsDefined( level.eagle ) )
	{
		level.eagle lunar_start_ally( eagle_struct );
	}

	if( IsDefined( level.falcon ) )
	{
		level.falcon lunar_start_ally( falcon_struct );
	}

	if( IsDefined( level.hawk ) )
	{
		level.hawk lunar_start_ally( hawk_struct );
	}

	if( IsDefined( level.pigeon ) )
	{
		level.pigeon lunar_start_ally( pigeon_struct );
	}

	if( IsDefined( level.seagull ) )
	{
		level.seagull lunar_start_ally( seagull_struct );
	}
}

lunar_start_ally( start_struct_name )
{
	if( IsDefined( start_struct_name ) )
	{
		start_struct = getstruct( start_struct_name, "targetname" );
		self ForceTeleport( start_struct.origin, start_struct.angles );
		if( IsDefined( start_struct.target ) )
		{
			node = GetNode( start_struct.target, "targetname" );
			if( IsDefined( node ) )
			{
				self SetGoalNode( node );
			}
		}
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

all_mantles_off( mantle_name )
{
	mantles = GetEntArray( mantle_name, "targetname" );
	foreach( mantle in mantles )
	{
		mantle MakeUnusable();
	}
}

all_mantles_on( mantle_name )
{
	mantles = GetEntArray( mantle_name, "targetname" );
	foreach( mantle in mantles )
	{
		mantle MakeUsable();
	}
}

hide_scriptmodels_by_targetname( targetname )
{
	script_brushes = GetEntArray( targetname, "targetname" );

	foreach( brush in script_brushes )
	{
		brush Hide();
		brush NotSolid();

		if( brush.classname == "script_brushmodel" )
		{
			brush ConnectPaths();
		}
	}
}

show_scriptmodels_by_targetname( targetname )
{
	script_brushes = GetEntArray( targetname, "targetname" );

	foreach( brush in script_brushes )
	{
		brush Show();
		brush Solid();

		if( brush.classname == "script_brushmodel" )
		{
			brush DisconnectPaths();
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

trigger_choice_spawn( trigger_name )
{
	// Get the triggers we are considering
	triggers = GetEntArray( trigger_name, "targetname" );

	foreach( trigger in triggers ) 
	{
		// Check for spawn
		trigger thread trigger_choice_spawn_think( trigger_name ); 
	}
}

// this - trigger multiple
trigger_choice_spawn_think( trigger_name )
{
	// End if one of the triggers has been flipped
	level endon( trigger_name );

	// Wait for trigger
	self waittill( "trigger" );

	// Stop all other triggers
	triggers = GetEntArray( trigger_name, "targetname" );
	array_thread( triggers, ::trigger_off );

	// Do the spawn
	if( IsDefined( self.target ) )
	{
		spawners = GetEntArray( self.target, "targetname" );
		foreach( spawner in spawners )
		{
			// Add spawn func based on mission ai group
			if( IsDefined( spawner.script_aigroup ) )
			{
				spawner spawn_ai_type_check();
			}
			else
			{
				spawner thread add_spawn_function( ::lunar_enemy_interior_common );
			}

			spawner script_delay();

			// Spawn the enemy
			spawned_enemy = spawner spawn_ai();

			// Check any retreat triggers on enemy
			if( IsDefined( spawned_enemy ) )
			{
				spawned_enemy thread check_retreat_triggers();
			}
		}
	}
	
	// Notify all others waiting
	level notify( trigger_name );
}


//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************
spawn_ai_type_check()
{
	spawner = self;

	switch( spawner.script_aigroup )
	{
		case "enemy_storage":
			spawner thread add_spawn_function( maps\nx_lunar_escape_interior::enemy_storage_spawn_func );
			break;
		case "enemy_storage_breachers":
			spawner thread add_spawn_function( maps\nx_lunar_escape_interior::enemy_storage_spawn_func );
			break;
		case "enemy_life_support":
			spawner thread add_spawn_function( maps\nx_lunar_escape_interior::enemy_life_support_spawn_func );
			break;
		case "enemy_medical":
			spawner thread add_spawn_function( maps\nx_lunar_escape_interior::enemy_medical_spawn_func );
			break;
		case "enemy_living_floor_1":
			spawner thread add_spawn_function( maps\nx_lunar_escape_interior::enemy_living_floor_1_spawn_func );
			break;
		case "enemy_living_floor_1_hidden":
			spawner thread add_spawn_function( maps\nx_lunar_escape_interior::enemy_living_floor_1_hidden_spawn_func );
			break;
		case "enemy_living_floor_1_mover":
			spawner thread add_spawn_function( maps\nx_lunar_escape_interior::enemy_living_floor_1_mover_spawn_func );
			break;
		case "enemy_living_floor_2":
			spawner thread add_spawn_function( maps\nx_lunar_escape_interior::enemy_living_floor_2_spawn_func );
			break;
//		case "enemy_hydro":
//		case "enemy_hydro_jumper":
//			spawner thread add_spawn_function( maps\nx_lunar_escape_interior::enemy_hydro_spawn_func );
//			break;
//		case "enemy_crew_floor_1":
//			spawner thread add_spawn_function( maps\nx_lunar_escape_interior::enemy_crew_floor_1_spawn_func );
//			break;
//		case "enemy_crew_floor_2":
//			spawner thread add_spawn_function( maps\nx_lunar_escape_interior::enemy_crew_floor_2_spawn_func );
//			break;
		case "enemy_airlock_exit":
			spawner thread add_spawn_function( ::lunar_enemy_exterior_exit );
			break;
		case "enemy_valley":
			spawner thread add_spawn_function( ::lunar_enemy_exterior_valley );
			break;
		case "enemy_valley_behind":
			spawner thread add_spawn_function( ::lunar_enemy_exterior_behind );
			break;
		case "enemy_plateau":
			spawner thread add_spawn_function( ::lunar_enemy_plateau );
			break;
		case "enemy_rover_backup":
			spawner thread add_spawn_function( ::lunar_enemy_rover_backup );
			break;
		case "enemy_outside_vehicle_bay":
			spawner thread add_spawn_function( ::lunar_enemy_exterior_stealth );
			break;
		case "enemy_inside_vehicle_bay":
			spawner thread add_spawn_function( ::lunar_enemy_exterior_stealth );
			break;
		case "enemy_control_floor_1_side":
			spawner thread add_spawn_function( maps\nx_lunar_take_back_control::enemy_control_floor_1_side_spawn_func );
			break;
		case "enemy_control_floor_1_main":
			spawner thread add_spawn_function( maps\nx_lunar_take_back_control::enemy_control_floor_1_main_spawn_func );
			break;
		case "enemy_control_floor_1_main_scripted":
			spawner thread add_spawn_function( maps\nx_lunar_take_back_control::enemy_control_floor_1_main_scripted_spawn_func );
			break;
		case "enemy_control_floor_1_resupply":
 			spawner thread add_spawn_function( maps\nx_lunar_take_back_control::enemy_control_floor_1_resupply_spawn_func );
			break;
		case "enemy_control_floor_2":
			spawner thread add_spawn_function( maps\nx_lunar_take_back_control::enemy_control_floor_2_spawn_func );
			break;
		default:
			spawner thread add_spawn_function( ::lunar_enemy_interior_common );
			break;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// this - enemy ai
check_retreat_triggers()
{
	if( !IsDefined( self.script_battleplan ) )
	{
		return;
	}
	retreat_trigger_name = self.script_battleplan;

	self endon( "death" );

	// Get the associated retreat triggers
	triggers = GetEntArray( retreat_trigger_name, "targetname" );

	foreach( trigger in triggers )
	{
		self thread retreat_trigger( trigger, retreat_trigger_name );
	}
}

// this - enemy ai
retreat_trigger( trigger, retreat_trigger_name )
{
	self endon( "death" );

	// Wait for retreat trigger
	//IPrintln( retreat_trigger_name + " waiting for retreat trigger" );
	trigger waittill( "trigger" );
	//IPrintln( retreat_trigger_name + " trigger" );

	// Notify that enemy has new retreat
	self notify( "new_retreat" );
	self endon( "new_retreat" ); 

	// Wait for look at if defined
	if( IsDefined( trigger.script_dot ) )
	{
		self wait_for_look_at_enemy( retreat_trigger_name, trigger.script_dot );
	}

	// Retreat enemy
	if( IsAlive( self ) )
	{
		self.goalradius = 0;

		retreat_node = GetNode( trigger.target, "targetname" );  
		if( IsDefined( retreat_node ) )
		{
			self SetGoalNode( retreat_node );
		}
		else
		{
			//IPrintln( "WARNING: Retreat " + retreat_trigger_name + " missing Goal Node" );
		}
		//IPrintln( retreat_trigger_name + " retreat trigger" );
	}
}

// this - enemy ai
wait_for_look_at_enemy( retreat_trigger_name, dot )
{
	self endon( "death" );
	self endon( "new_retreat" );

	// Wait for player to see enemy
	while( 1 )
	{
		look_at_enemy = within_fov( level._player.origin, level._player getplayerangles(), self.origin, Cos( dot ) );
		if( look_at_enemy )
		{
			//IPrintln( retreat_trigger_name + " look at Cos( " + dot + " ) ");
			break;
		}
		wait( 0.05 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

LUNAR_DOOR_DISTANCE = 46;
LUNAR_DOOR_OPEN_TIME = 1.0;
LUNAR_DOOR_CLOSE_TIME = 1.0;

open_lunar_door_vignette( door_name, animate, door_wait, hawk, start_flag )
{
	if( !IsDefined( animate ) )
	{
		animate = true;
	}

	if( !IsDefined( hawk ) )
	{
		hawk = false;
	}

	if( IsDefined ( door_name ))
	{
		thread lunar_door_keypad_cycle ( door_name ) ;
	}

	lunar_door_parts = GetEntArray( door_name, "script_noteworthy" );

	ally_trigger = undefined;
	player_trigger = undefined;
	vignette_origin = undefined;
	foreach ( door_part in lunar_door_parts )
	{
		if( door_part.code_classname == "trigger_multiple" )
		{
			if( door_part.targetname == "ally_trigger" )
			{
				ally_trigger = door_part;
			}
			if( door_part.targetname == "player_trigger" )
			{
				player_trigger = door_part;
			}
		}
		if( door_part.code_classname == "script_origin" )
		{
			if( door_part.targetname == "vignette_ally_door_breach" )
			{
				vignette_origin = door_part;
			}
		}
	}

	// Reach the vignette
	if( IsDefined( vignette_origin ) && animate )
	{
		vignette_origin maps\nx_lunar_anim::ally_door_breach_reach( hawk );
	}

	// Wait for start flag if defined
	if( IsDefined( start_flag ) )
	{
		flag_wait( start_flag );
	}

	// Wait for player at door
	player_trigger waittill( "trigger" );

	flag_set( "ally_door_open_start" );

	// Wait at door for dialog
	if( IsDefined( door_wait ) )
	{
		wait( door_wait );
	}
	
	if( IsDefined( level.hawk ) )
	{
		level.hawk notify( "stop_ally_door_breach_idle" );
	}
	if( IsDefined( level.eagle ) )
	{
		level.eagle notify( "stop_ally_door_breach_idle" );
	}
//	if( IsDefined( level.falcon ) )
//	{
//		level.falcon notify( "stop_ally_door_breach_idle" );
//	}

	// Play the vignette
	if( IsDefined( vignette_origin ) && animate )
	{
		vignette_origin thread maps\nx_lunar_anim::ally_door_breach_play( hawk );
		
		// Wait for the switch
		wait( 1.4 );
	}

	flag_clear( "ally_door_open_start" );

	level notify( "start_airlock_sequence" );
}

open_lunar_door( door_name, time, explosion )
{
	lunar_door_movement( door_name, time, 1, explosion );
}

close_lunar_door( door_name, time )
{
	lunar_door_movement( door_name, time, -1 );
}

lunar_door_movement( door_name, time, direction, explosion )
{
	if( !IsDefined( time ) )
	{
		time = LUNAR_DOOR_OPEN_TIME;
	}

	// Get parts array
	lunar_door_parts = GetEntArray( door_name, "script_noteworthy" );

	// Get the door facing
	door_rotate = 0;
	foreach ( door_part in lunar_door_parts )
	{
		if( door_part.code_classname == "script_origin" )
		{
			if( door_part.targetname == "angles_check" )
			{
				door_rotate = Int( door_part.angles[1] );
				break;
			}
		}
	}

	// Can't find valid door rotation node
	if( !IsDefined( door_rotate ) )
	{
		return;
	}

	open_door_distance = LUNAR_DOOR_DISTANCE;
	explosion_door_distance = LUNAR_DOOR_DISTANCE; 
	if( IsDefined( explosion ) && explosion )
	{
		open_door_distance = 30;
		explosion_door_distance = 18;
	}
	else
	{
		explosion = false;
	} 

	// Get if door is rotated and flipped ( might want to come back to this.. )
	rotated = false;
	flipped = false;
	switch( door_rotate )
	{
		case 0:
			break;
		case 90:
			rotated = true;
			flipped = true;
			break;
		case 180:
			flipped = true;
			break;
		case 270:
			rotated = true;
			break;
		default:
			AssertMsg( "Door rotate not valid: " + door_rotate );
			break;
	}

	// Save off movement direction, used for MoveTo calculation
	// Direction still indicates if we are opening or closing
	movement_direction = direction;
	if( flipped )
	{
		movement_direction = ( movement_direction * -1 );
	}

	// Sound script
	level thread lunar_door_movement_sfx( door_name, lunar_door_parts, direction );

	// Open the visual doors
	door_model_left = undefined;
	door_model_right = undefined;
	foreach ( door_part in lunar_door_parts )
	{
		if( door_part.code_classname == "script_brushmodel" || door_part.code_classname == "script_model" )
		{
			door_distance = open_door_distance;
			if( explosion && door_part.code_classname == "script_model" )
			{
				door_distance = explosion_door_distance;
			} 

			if( door_part.targetname == "left" )
			{
				if( !rotated )
					door_part moveX( movement_direction * door_distance, time );
				else
					door_part moveY( -1 *movement_direction * door_distance, time );
			}
			else if ( door_part.targetname == "right" )
			{
				if( !rotated )
					door_part moveX( ( -1 * movement_direction * door_distance ), time );
				else
					door_part moveY( ( movement_direction * door_distance ), time );
			}
		}

		// Find the models
		if( door_part.code_classname == "script_model" )
		{
			if( door_part.targetname == "left" )
			{
				door_model_left = door_part;
			}
			else
			{
				door_model_right = door_part;
			}
		}
	}

	// Update door model if damaged
	if( explosion )
	{
		if( IsDefined( door_model_left ) )
		{
			door_model_left SetModel( door_model_left.model + "_breached" );
		}

		if( IsDefined( door_model_right ) )
		{
			door_model_right SetModel( door_model_right.model + "_breached" );
		}
 	}

	wait( time );

	// Connect the paths
	foreach ( door_part in lunar_door_parts )
	{
		if( door_part.code_classname == "script_brushmodel" )
		{
			if( door_part.targetname == "right" || door_part.targetname == "left")  
			{
				if( direction == 1 )
				{
					door_part ConnectPaths();
				}
				else
				{
					door_part DisconnectPaths();
				}
			}
		}
	}
}

// tagTC<note> - audio owned script
lunar_door_movement_sfx( door_name, lunar_door_parts, direction )
{
	// Play lunar door opening sound
	foreach ( door_part in lunar_door_parts )
	{
		if( door_part.code_classname == "script_brushmodel" || "script_model" == door_part.code_classname )
		{
			if( door_name == "armory_door" )
			{
				if( door_part.targetname == "right" )
				{
					if( door_name == "armory_door" )
					{       
						door_part playsound ( "lunar_door_press_close_armory" );
						break;
					}
				}
			}
			else
			{  
				if( door_part.targetname == "right" )
				{
                    
					if( direction == 1 )
					{
						if( GetDvar("environment_pressurized") == "1" )
						{
							door_part playsound ( "lunar_door_depress_open" );
						}
						else
						{
							door_part playsound ( "lunar_door_press_open" );
						}
					}
					else if( direction == -1 )
					{
						if( GetDvar("environment_pressurized") == "1" )
						{
							if ( flag ( "vehicle_airlock_open"))
							{
								door_part playsound ( "lunar_door_depress_close" );
							}
						}
						else
						{
							door_part playsound ( "lunar_door_press_close" );
						}
					}
					break;
				}
			}
		}
	}
}

lunar_door_keypad_cycle ( door_name )
{
	keypad = GetEnt ( door_name + "_keypad", "script_noteworthy");

	if ( IsDefined ( keypad ) )
	{
		// Triggered by animation notetrack
		level waittill ("keypad_cycle");
		keypad SetModel ( "nx_lunar_hatch_keypad_anim" );
		wait 1;
		keypad SetModel ( "nx_lunar_hatch_keypad_green");
		wait 1;
		keypad SetModel ( "nx_lunar_hatch_keypad" );
	}
	
	/*
	// initialising variables
	keypad_green = undefined;
	keypad_scan = undefined;
	keypad_ready = undefined;

	keypad_states = GetEntArray( keypad_name, "script_noteworthy" );
	foreach ( keypad in keypad_states )
	{
		if( keypad.targetname == "keypad_green" )
		{
			keypad_green = keypad;
		}
		if( keypad.targetname == "keypad_scan" )
		{
			keypad_scan = keypad;
		}
		if( keypad.targetname == "keypad_ready" )
		{
			keypad_ready = keypad;
		}
	}

	// Animate the keypad scan sequence
	keypad_scan show();
	keypad_ready hide();
	wait 1;
	keypad_green show();
	keypad_scan hide();
	*/
}

lunar_door_keypad_error( door_name )
{
	keypads = GetEntArray ( door_name + "_keypad", "targetname");
	foreach ( keypad in keypads)
	{
		keypad SetModel ("nx_lunar_hatch_keypad_error");
	}
}

lunar_door_breach_fx( door_name )
{
	// Get parts array
	lunar_door_parts = GetEntArray( door_name, "script_noteworthy" );

	breach_explosion_fx = undefined;
	foreach ( door_part in lunar_door_parts )
	{
		if( door_part.code_classname == "script_origin" )
		{
			if( door_part.targetname == "breach_explosion_fx" )
			{
				breach_explosion_fx = door_part;
				break;
			}
		}
	}

	if( IsDefined( breach_explosion_fx ) )
	{
		// Explosion FX
		PlayFX( level._effect[ "breach_explosion" ], breach_explosion_fx.origin, (breach_explosion_fx.angles + ( 90, 0, 0)) );

		// Sound Effect
		breach_explosion_fx PlaySound("scn_lunar_breach_detonate");

		if ( door_name == "vehicle_hatch_breach" )
		{
			wait 0.1;
			exploder( "fx_allies_breach_flash" );

			wait 0.5;
			exploder( "fx_allies_breach_debris" );

			wait 1.1;
			stop_exploder( "fx_allies_breach_debris" );
		}
	} 
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

lunar_door_status( door_name, status )
{
	// Just name the script models on each side of the door with the targetname "name_of_door_status" to get this to work.
	status_lights = GetEntArray ( door_name + "_status", "targetname");
	status_dynamic_lights = GetEntArray ( door_name + "_dynamic_light_status", "targetname");

	foreach ( light in status_lights)
	{
		switch (status)
		{
			case "status_green":
				light SetModel ( "nx_lunar_door_alertsign_green" );
				change_status_window_dialogue_color( "green" );
				light playsound("airlock_status_light_green");
				break;
			case "status_yellow":
				light SetModel ( "nx_lunar_door_alertsign_orange" );
				change_status_window_dialogue_color( "orange" );
				//light playsound("airlock_status_light_yellow");
				break;
			case "status_red":
				light SetModel ( "nx_lunar_door_alertsign_red" );
				change_status_window_dialogue_color( "red" );
				break;
		}
	}

	// handle dynamic light states for the doors
	foreach ( dynamic_light in status_dynamic_lights)
	{
		dynamic_light SetLightIntensity(0);

		/*
		switch (status)
		{
			case "status_green":
				dynamic_light SetLightColor( (0.2, 1.0, 0.2) );
				dynamic_light SetLightIntensity(0.50);
				//dynamic_light SetLightRadius(150);
				break;
			case "status_yellow":
				dynamic_light SetLightColor( (1.0, 0.8, 0.2) );
				dynamic_light SetLightIntensity(0.70);
				//dynamic_light SetLightRadius(200);
				break;
			case "status_red":
				dynamic_light SetLightColor( (0.7294, 0.1921, 0.0196) );
				dynamic_light SetLightIntensity(2.0);
				//dynamic_light SetLightRadius(200);
				break;
		}*/
	}


// Original method
/*
	lunar_door_parts = GetEntArray( door_name, "script_noteworthy" );
	foreach ( door_part in lunar_door_parts )
	{
		// Sign
		if( door_part.code_classname == "script_brushmodel" )
		{
			switch( door_part.targetname )
			{
				case "status_green":
				case "status_yellow":
				case "status_red":
					door_part door_sign_update( status );
					break;
			}
		}

		// Lights
		if( door_part.code_classname == "light" )
		{
			door_part door_light_update( status );
		}		
	}
*/
}

// self - door part
door_sign_update( status )
{
	self Hide();
	if( self.targetname == status )
	{
		self Show();
	}
}

// self - door part
door_light_update( status )
{
	self setLightIntensity( 1.0 );
	switch( status )
	{
		case "status_green":
			self setLightIntensity( 0.75 );
			self notify( "stop_pulse" );
			self setLightColor( (0.0, 1.0, 0.0) );
			break;
		case "status_yellow":
			self setLightIntensity( 0.75 );
			self notify( "stop_pulse" );
			self thread door_light_pulse();
			self setLightColor( (1.0, 1.0, 0.0) );
			break;
		case "status_red":
			self notify( "stop_pulse" );
			self thread door_light_pulse();
			self setLightColor( (1.0, 0.0, 0.0) );
			break;
	}
}

door_light_pulse()
{
	self endon( "stop_pulse" );
	on = self getLightIntensity();
	off = .2;
	curr = on;
	transition_on = 0.3;
	transition_off = 0.5;
	wait_time = 0.05;
	increment_on = ( on - off ) / ( transition_on / .05 );
	increment_off = ( on - off ) / ( transition_off / .05 );

	for ( ;; )
	{
		//ramp down
		time = 0;
		while ( ( time < transition_off ) )
		{
			curr -= increment_off;
			curr = clamp( curr, 0, 100 );
			self setLightIntensity( curr );
			time += .05;
			wait( .05 );
		}

		//off wait time
		wait( wait_time );

		//ramp up
		time = 0;
		while ( time < transition_on )
		{
			curr += increment_on;
			curr = clamp( curr, 0, 100 );
			self setLightIntensity( curr );
			time += .05;
			wait( .05 );
		}

		//on wait time
		wait( wait_time );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

airlock_vignette( door_1, door_2, pressure )
{
	sound_pressure = 0;	

	if( pressure == "moon" )
	{
		sound_pressure = 1;
		// lunar_door_status( door_1, "status_green" );
		// lunar_door_status( door_2, "status_red" );
	}
	else
	{
		sound_pressure = 0;
		// lunar_door_status( door_1, "status_green" );
		// lunar_door_status( door_2, "status_green" );
	}

	// Lower weapon
	enablePlayerWeapons( false );

	// Wait for airlock cycle
	if ( sound_pressure == 0 )
	{
		//soundent2 = spawn( "sound_emitter", level._player.origin );
		//soundent2 linkto( level._player );
		//soundent2 playsound ( "nx_lunar_pressurize" );
		//DR:set the flag here for the crew hub airlock helmet state
		//DR:eventually, this will need to change to have this generic script
		//DR:accept a variable of a flag to set in the middle of the 
		//DR:pressurization sequence
		flag_set( "sfx_int_base_milsuit_press2" );
		//done setting flag for crew hub airlock
	}
	else
	{
		soundent2 = spawn( "sound_emitter", level._player.origin );
		soundent2 linkto( level._player );
		soundent2 playsound ( "nx_lunar_depressurize" );
		//DR:set the flag here for the airlock to the exterior
		//DR:eventually, this will need to change to have this generic script
		//DR:accept a variable of a flag to set in the middle of the 
		//DR:pressurization sequence
		flag_set( "sfx_ext_surface_milsuit_depress" );
		//done setting flag for crew hub airlock

	}

//	level thread airlock_fx( door_2 );
	exploder( "fx_crew_module_pressurize" );	
	level thread maps\nx_lunar_util::airlock_cycle();

	// Wait for cycle complete
	wait( 9.5 );

	// Open door second door
	stop_exploder( "fx_crew_module_pressurize" );
	level thread maps\nx_lunar_util::open_lunar_door( door_2 );	
	enablePlayerWeapons( true );
}

//set pressurization because other bits of the game look at this including the suit shield.
airlock_set_environment( pressure )
{
	if( pressure == "moon" )
	{
		SetSavedDvar( "environment_pressurized", "0" );
	}
	else
	{
		SetSavedDvar( "environment_pressurized", "1" );
	}
}

airlock_pressure( pressure )
{
	// Change pressure to pressurized interior
	if( IsDefined( pressure ) )
	{
		// blend over some time.
		level._player set_suit_fade( pressure, 2.1 );
	}
}

airlock_fx( door_name )
{
// 	tagTC<note> - commenting out designer airlock FX because of framerate issues
//	lunar_door_parts = GetEntArray( door_name, "script_noteworthy" );
//
//	foreach ( door_part in lunar_door_parts )
//	{
//		if( door_part.code_classname == "script_origin" )
//		{
//			PlayFx( level._effect[ "airlock_cycle" ], door_part.origin );
//		}
//	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

lunar_helmet_bootup_sequence()
{
	SetSavedDvar( "lunar_hud_show_boot_up", 1 );
	header_items = [
		&"NX_LUNAR_HUD_BOOT_SEQ_0_HEADER",			//ECLSS DIAGNOSTICS
		&"NX_LUNAR_HUD_BOOT_DIVIDER"				//--------------------------------------------------------
	];

	status_items_left = [
		&"NX_LUNAR_HUD_BOOT_SEQ_0_ENTRY_0_0",		//Batteries
		&"NX_LUNAR_HUD_BOOT_SEQ_0_ENTRY_0_1",		//O2 Reserves
		&"NX_LUNAR_HUD_BOOT_SEQ_0_ENTRY_0_2",		//IDB Reserves
		&"NX_LUNAR_HUD_BOOT_SEQ_0_ENTRY_0_3",		//Suit Integrity
		&"NX_LUNAR_HUD_BOOT_SEQ_0_ENTRY_0_4",		//Thermal Regulation
		&"NX_LUNAR_HUD_BOOT_SEQ_0_ENTRY_0_5",		//Solor Converter Status
		&"NX_LUNAR_HUD_BOOT_SEQ_0_ENTRY_0_6"		//Heart Rate
	];

	status_items_right = [
		&"NX_LUNAR_HUD_BOOT_SEQ_0_ENTRY_1_0",		//94
		&"NX_LUNAR_HUD_BOOT_SEQ_0_ENTRY_1_1",		//98
		&"NX_LUNAR_HUD_BOOT_SEQ_0_ENTRY_1_2",		//32 oz.
		&"NX_LUNAR_HUD_BOOT_SEQ_0_ENTRY_1_3",		//100
		&"NX_LUNAR_HUD_BOOT_SEQ_0_ENTRY_1_4",		//Nominal
		&"NX_LUNAR_HUD_BOOT_SEQ_0_ENTRY_1_5",		//Nominal
		&"NX_LUNAR_HUD_BOOT_SEQ_0_ENTRY_1_6"		//132 BPM
	];

	boot_sequence( header_items, status_items_left, status_items_right );

	SetSavedDvar( "lunar_hud_show_boot_up_pressure", 1 );

	header_items = [
		&"NX_LUNAR_HUD_BOOT_SEQ_1_HEADER",			//EXTERNAL READINGS
		&"NX_LUNAR_HUD_BOOT_DIVIDER"				//--------------------------------------------------------
	];

	status_items_left = [
		&"NX_LUNAR_HUD_BOOT_SEQ_1_ENTRY_0_0",		//Ambient Radiation
		&"NX_LUNAR_HUD_BOOT_SEQ_1_ENTRY_0_1",		//Atmospheric Pressure
		&"NX_LUNAR_HUD_BOOT_SEQ_1_ENTRY_0_2",		//Air Quality
		&"NX_LUNAR_HUD_BOOT_SEQ_1_ENTRY_0_3"		//Temperature
	];

	status_items_right = [
		&"NX_LUNAR_HUD_BOOT_SEQ_1_ENTRY_1_0",		//.38 uR		// tagMJS<TODO> we need to add the micro sybmol to our text
		&"NX_LUNAR_HUD_BOOT_SEQ_1_ENTRY_1_1",		//32.4 kPa
		&"NX_LUNAR_HUD_BOOT_SEQ_1_ENTRY_1_2",		//Nominal
		&"NX_LUNAR_HUD_BOOT_SEQ_1_ENTRY_1_3"		//-22 C			// tagMJS<TODO> we need to add the degree symbol to our text
	];

	boot_sequence( header_items, status_items_left, status_items_right );

	SetSavedDvar( "lunar_hud_show_boot_up_pressure", 0 );

	header_items = [
		&"NX_LUNAR_HUD_BOOT_SEQ_2_HEADER",			//COMMUNICATIONS
		&"NX_LUNAR_HUD_BOOT_DIVIDER"				//--------------------------------------------------------
	];

	status_items_left = [
		&"NX_LUNAR_HUD_BOOT_SEQ_2_ENTRY_0_0",		//Voice com
		&"NX_LUNAR_HUD_BOOT_SEQ_2_ENTRY_0_1",		//Sat Comm
		&"NX_LUNAR_HUD_BOOT_SEQ_2_ENTRY_0_2",		//Nav Link
		&"NX_LUNAR_HUD_BOOT_SEQ_2_ENTRY_0_3"		//Weapon Link
	];

	status_items_right = [
		&"NX_LUNAR_HUD_BOOT_SEQ_2_ENTRY_1_0",		//OK
		&"NX_LUNAR_HUD_BOOT_SEQ_2_ENTRY_1_0",		//Failure
		&"NX_LUNAR_HUD_BOOT_SEQ_2_ENTRY_1_0",		//OK
		&"NX_LUNAR_HUD_BOOT_SEQ_2_ENTRY_1_0"		//OK
	];

	boot_sequence( header_items, status_items_left, status_items_right );


	// need to kill the hud and turn off the outline
	SetSavedDvar( "lunar_hud_show_boot_up", 0 );


	// final text complete
	display_lunar_boot_sequence_complete();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

boot_sequence( header_items, status_items_left, status_items_right )
{
	level._player setHudNoiseEffect( 0.6, 16, 12, 0.695313, ( getdvarfloat("color_enemy_r"), getdvarfloat("color_enemy_g"), getdvarfloat("color_enemy_b") ) );
	length = 0;

	init_status_window_dialogue( "boot_up" );

	// turn on the status window dialogue and set color
	change_status_window_dialogue_color( "green" );


	// get total time to display all text, this is needed for controlling loading bar
	thread loading_bar_progress( header_items, status_items_left, status_items_right );


	// add our header
	foreach( string in header_items )
	{
		length = strlength( string );
		wait_time = ( length * level._status_window_dialogue.section["header"].time_per_char ) / 1000;
		add_line_to_status_window_dialogue( string, "header" );
		wait ( wait_time );
	}


	// add all of the items on the left first
	foreach( string in status_items_left )
	{
		length = strlength( string );
		wait_time = ( length * level._status_window_dialogue.section["column_0"].time_per_char ) / 1000;
		add_line_to_status_window_dialogue( string, "column_0" );
		wait ( wait_time );
	}


	level._player setHudNoiseEffect( 0.0, 16, 12, 0.695313 );


	// now finally add all the items on the right
	foreach( string in status_items_right )
	{
		length = strlength( string );
		wait_time = ( length * level._status_window_dialogue.section["column_0"].time_per_char ) / 1000;
		add_line_to_status_window_dialogue( string, "column_1" );
		wait ( wait_time + 0.3 );
	}


	// and now we fade everything out and delete it all
	fade_out_and_delete_all_status_window_elements();


	// turn off the status window dialogue
	change_status_window_dialogue_color( "none" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

display_lunar_boot_sequence_complete()
{
	hud_elem = maps\_hud_util::get_countdown_hud( -175, 16 );

	hud_elem.alignX		= "left";
	hud_elem.fontscale	= level._status_window_dialogue.fontscale;
	hud_elem.layer		= level._status_window_dialogue.layer;
	hud_elem.label		= &"NX_LUNAR_HUD_BOOT_COMPLETE";
	for ( index = 0; index < 6; index++ )
	{
		hud_elem.alpha = 1.0;
		wait ( 0.1 );
		hud_elem.alpha = 0.0;
		wait ( 0.1 );
	}
	hud_elem Destroy();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

airlock_cycle()
{
	quick_status_items = [ "Bypass Sequence", "Welcome back Travis" ];

	status_items = [ &"NX_LUNAR_HUD_AIRLOCK_SEQ_LINE_0", &"NX_LUNAR_HUD_AIRLOCK_SEQ_LINE_1",
					 &"NX_LUNAR_HUD_AIRLOCK_SEQ_LINE_2", &"NX_LUNAR_HUD_AIRLOCK_SEQ_LINE_3",
					 &"NX_LUNAR_HUD_AIRLOCK_SEQ_LINE_4", &"NX_LUNAR_HUD_AIRLOCK_SEQ_LINE_5",
					 &"NX_LUNAR_HUD_AIRLOCK_SEQ_LINE_6", &"NX_LUNAR_HUD_AIRLOCK_SEQ_LINE_7",
					 &"NX_LUNAR_HUD_AIRLOCK_SEQ_LINE_8", &"NX_LUNAR_HUD_AIRLOCK_SEQ_LINE_9",
					 &"NX_LUNAR_HUD_AIRLOCK_SEQ_LINE_10", &"NX_LUNAR_HUD_AIRLOCK_SEQ_LINE_11" ];

	//terminal_status_check( quick_status_items );
	SetSavedDvar( "lunar_hud_show_pressure", 1 );
	terminal_status_check( status_items );
	SetSavedDvar( "lunar_hud_show_pressure", 0 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

terminal_status_check( status_items )
{
	length = 0;

	init_status_window_dialogue( "pressurization" );

	change_status_window_dialogue_color( "orange" );

	for ( index = 0; index < status_items.size; index = ( index + 2 ) )
	{
		length = strlength( status_items[index] );
		wait_time = ( length * level._status_window_dialogue.section["column_0"].time_per_char ) / 1000;
		add_line_to_status_window_dialogue( status_items[index], "column_0" );
		wait ( wait_time );

		length = strlength( status_items[index + 1] );
		wait_time = ( length * level._status_window_dialogue.section["column_0"].time_per_char ) / 1000;
		add_line_to_status_window_dialogue( status_items[index + 1], "column_0" );
		wait ( wait_time );
	}
	//wait( 0.5 );


	thread scroll_status_window_section_up_and_off_of_screen( "header" );
	thread scroll_status_window_section_up_and_off_of_screen( "column_0" );

	change_status_window_dialogue_color( "none" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

init_status_window_dialogue( type )
{
	if ( !IsDefined( level._status_window_dialogue ) )
	{
		status_window_struct = spawnstruct();
		level._status_window_dialogue = status_window_struct;
		level._status_window_dialogue.section = [];
	}
	if ( !IsDefined( level._status_window_dialogue.section["header"] ) )
	{
		header_struct = spawnstruct();
		level._status_window_dialogue.section["header"] = header_struct;
	}
	if ( !IsDefined( level._status_window_dialogue.section["column_0"] ) )
	{
		col_struct = spawnstruct();
		level._status_window_dialogue.section["column_0"] = col_struct;
	}
	if ( !IsDefined( level._status_window_dialogue.section["column_1"] ) )
	{
		col_struct = spawnstruct();
		level._status_window_dialogue.section["column_1"] = col_struct;
	}


	if ( "pressurization" == type )
	{
		// common
		level._status_window_dialogue.alignX = "right";
		level._status_window_dialogue.alignY = "top";
		level._status_window_dialogue.horzAlign = "right_adjustable";
		level._status_window_dialogue.vertAlign = "top_adjustable";
		level._status_window_dialogue.line_spacing = 13;
		level._status_window_dialogue.fontscale = 1.2;
		level._status_window_dialogue.layer = "visor";
		level._status_window_dialogue.color = ( 0, 0, 0 );

		// header;
		level._status_window_dialogue.section["header"].max_lines = 1;
		level._status_window_dialogue.section["header"].start_index = 0;
		level._status_window_dialogue.section["header"].last_index = 0;
		level._status_window_dialogue.section["header"].pos_x = -24;
		level._status_window_dialogue.section["header"].pos_y = 32;
		level._status_window_dialogue.section["header"].time_per_char = 18;
		level._status_window_dialogue.section["header"].hud_elems = [];

		// column 0
		level._status_window_dialogue.section["column_0"].max_lines = 6;
		level._status_window_dialogue.section["column_0"].start_index = 0;
		level._status_window_dialogue.section["column_0"].last_index = 0;
		level._status_window_dialogue.section["column_0"].pos_x = -32;
		level._status_window_dialogue.section["column_0"].pos_y = 56;
		level._status_window_dialogue.section["column_0"].time_per_char = 18;
		level._status_window_dialogue.section["column_0"].elems = [];
	}
	else if ( "boot_up" == type )
	{
		// common
		level._status_window_dialogue.alignX = "left";
		level._status_window_dialogue.alignY = "top";
		level._status_window_dialogue.horzAlign = "right_adjustable";
		level._status_window_dialogue.vertAlign = "top_adjustable";
		level._status_window_dialogue.line_spacing = 15;
		level._status_window_dialogue.fontscale = 1.0;
		level._status_window_dialogue.layer = "visor";
		level._status_window_dialogue.color = ( 0, 0, 0 );

		// header;
		level._status_window_dialogue.section["header"].max_lines = 2;
		level._status_window_dialogue.section["header"].start_index = 0;
		level._status_window_dialogue.section["header"].last_index = 0;
		level._status_window_dialogue.section["header"].pos_x = -192;
		level._status_window_dialogue.section["header"].pos_y = 50;
		level._status_window_dialogue.section["header"].time_per_char = 15;
		level._status_window_dialogue.section["header"].hud_elems = [];

		// column 0
		level._status_window_dialogue.section["column_0"].max_lines = 7;
		level._status_window_dialogue.section["column_0"].start_index = 0;
		level._status_window_dialogue.section["column_0"].last_index = 0;
		level._status_window_dialogue.section["column_0"].pos_x = -192;
		level._status_window_dialogue.section["column_0"].pos_y = 82;
		level._status_window_dialogue.section["column_0"].time_per_char = 15;
		level._status_window_dialogue.section["column_0"].hud_elems = [];

		// column 1
		level._status_window_dialogue.section["column_1"].max_lines = 7;
		level._status_window_dialogue.section["column_1"].start_index = 0;
		level._status_window_dialogue.section["column_1"].last_index = 0;
		level._status_window_dialogue.section["column_1"].pos_x = -62;
		level._status_window_dialogue.section["column_1"].pos_y = 82;
		level._status_window_dialogue.section["column_1"].time_per_char = 30;
		level._status_window_dialogue.section["column_1"].hud_elems = [];
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

add_line_to_status_window_dialogue( hud_elem_string, section )
{
	// make sure we have everthing we need
	Assert( IsDefined( hud_elem_string ) );
	Assert( IsDefined( section ) );

	// check if we have the max amount of items
	if (	level._status_window_dialogue.section[section].max_lines
			<= ( level._status_window_dialogue.section[section].last_index - level._status_window_dialogue.section[section].start_index ) )
	{
		shift_status_window_lines( section );
	}
	hud_elem = maps\_hud_util::get_countdown_hud( level._status_window_dialogue.section[section].pos_x, level._status_window_dialogue.section[section].pos_y );

	hud_elem.x			= level._status_window_dialogue.section[section].pos_x;		// get_countdown_hud on PC sets onw default x value, make sure this value is set correctly
	hud_elem.alignX		= level._status_window_dialogue.alignX;
	hud_elem.alignY		= level._status_window_dialogue.alignY;
	hud_elem.horzAlign	= level._status_window_dialogue.horzAlign;
	hud_elem.vertAlign	= level._status_window_dialogue.vertAlign;
	hud_elem.fontscale	= level._status_window_dialogue.fontscale;
	hud_elem.layer		= level._status_window_dialogue.layer;
	hud_elem.color		= level._status_window_dialogue.color;
	hud_elem.foreground = 0;
	hud_elem.label		= hud_elem_string;

	// special case for boot sequence
// 	if ( "Failure" == hud_elem_string )
// 	{
// 		hud_elem.color = ( GetDvarFloat( "color_enemy_r" ), GetDvarFloat( "color_enemy_g" ), GetDvarFloat( "color_enemy_b" ) );
// 	}

	hud_elem SetPulseFX( level._status_window_dialogue.section[section].time_per_char, 900000, 700, true );

	level._status_window_dialogue.section[section].hud_elems[level._status_window_dialogue.section[section].last_index] = hud_elem;
	level._status_window_dialogue.section[section].last_index++;

	level._status_window_dialogue.section[section].pos_y += level._status_window_dialogue.line_spacing;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

shift_status_window_lines( section )
{
	Assert( IsDefined( section ) );

	// first we need to fade out our top line
	level._status_window_dialogue.section[section].hud_elems[level._status_window_dialogue.section[section].start_index] fadeOverTime( 0.2 );
	level._status_window_dialogue.section[section].hud_elems[level._status_window_dialogue.section[section].start_index].alpha = 0.0;
	//wait ( 0.3 );

	// then delete it
	if ( IsDefined( level._status_window_dialogue.section[section].hud_elems[level._status_window_dialogue.section[section].start_index] ) )
	{
		level._status_window_dialogue.section[section].hud_elems[level._status_window_dialogue.section[section].start_index] destroy();
		level._status_window_dialogue.section[section].start_index++;
	}

	// then we move all of our other lines up
	foreach( hud_elem in level._status_window_dialogue.section[section].hud_elems )
	{
		if ( IsDefined( hud_elem ) )
		{
			hud_elem thread shift_single_status_line();
		}
	}
	level._status_window_dialogue.section[section].pos_y -= level._status_window_dialogue.line_spacing;
	wait ( 0.2 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

shift_single_status_line()
{
	self MoveOverTime( 0.1 );
	self.y -= level._status_window_dialogue.line_spacing;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

scroll_status_window_section_up_and_off_of_screen( section )
{
	Assert( IsDefined( section ) );

	if ( IsDefined( level._status_window_dialogue.section ) && IsDefined( level._status_window_dialogue.section[section].hud_elems ) )
	{
		foreach( hud_elem in level._status_window_dialogue.section[section].hud_elems )
		{
			if ( IsDefined( hud_elem ) )
			{
				hud_elem shift_status_window_lines( section );
			}
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

change_status_window_dialogue_color( color )
{
	new_color = ( 0.0, 0.0, 0.0 );
	if ( IsDefined( color ) )
	{
		switch( color )
		{
			case "green":
				new_color = ( GetDvarFloat( "color_neutral_r" ), GetDvarFloat( "color_neutral_g" ), GetDvarFloat( "color_neutral_b" ) );
				SetSavedDvar( "lunar_hud_status_window_r", GetDvarFloat( "color_neutral_r" ) );
				SetSavedDvar( "lunar_hud_status_window_g", GetDvarFloat( "color_neutral_g" ) );
				SetSavedDvar( "lunar_hud_status_window_b", GetDvarFloat( "color_neutral_b" ) );
				break;
			case "orange":
				new_color = ( GetDvarFloat( "color_enemy_r" ), GetDvarFloat( "color_enemy_g" ), GetDvarFloat( "color_enemy_b" ) );
				SetSavedDvar( "lunar_hud_status_window_r", GetDvarFloat( "color_enemy_r" ) );
				SetSavedDvar( "lunar_hud_status_window_g", GetDvarFloat( "color_enemy_g" ) );
				SetSavedDvar( "lunar_hud_status_window_b", GetDvarFloat( "color_enemy_b" ) );
				break;
			case "yellow":
				new_color = ( 0.230, 0.230, 0.80 );
				SetSavedDvar( "lunar_hud_status_window_r", 0.230 );
				SetSavedDvar( "lunar_hud_status_window_g", 0.230 );
				SetSavedDvar( "lunar_hud_status_window_b", 0.80 );
				break;
			case "none":
			default:
				new_color = ( 0.0, 0.0, 0.0 );
				SetSavedDvar( "lunar_hud_status_window_r", 0.0 );
				SetSavedDvar( "lunar_hud_status_window_g", 0.0 );
				SetSavedDvar( "lunar_hud_status_window_b", 0.0 );
				break;
		}

		if ( IsDefined( level._status_window_dialogue ) )
		{
		// set all current lines to new color
		if ( IsDefined( level._status_window_dialogue.section ) )
		{
			foreach( element_array in level._status_window_dialogue.section )
			{
				if ( IsDefined( element_array.hud_elems ) )
				{
					foreach( hud_elem in element_array.hud_elems )
					{
						if ( IsDefined( hud_elem ) )
							{
								hud_elem.color = new_color;
							}
						}
					}
				}
			}

			// save color off so all new lines will be this color as well.
			level._status_window_dialogue.color = new_color;
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

fade_out_all_status_window_elements( fade_time )
{
	if ( IsDefined( level._status_window_dialogue.section ) )
	{
		foreach( element_array in level._status_window_dialogue.section )
		{
			if ( IsDefined( element_array.hud_elems ) )
			{
				foreach( hud_elem in element_array.hud_elems )
				{
					if ( IsDefined( hud_elem ) )
					{
						hud_elem FadeOverTime( fade_time );
						hud_elem.alpha = 0;
					}
				}
			}
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

delete_all_status_window_elements()
{
	if ( IsDefined( level._status_window_dialogue.section ) )
	{
		foreach( element_array in level._status_window_dialogue.section )
		{
			if ( IsDefined( element_array.hud_elems ) )
			{
				foreach( hud_elem in element_array.hud_elems )
				{
					if ( IsDefined( hud_elem ) )
					{
						hud_elem destroy();
					}
				}
			}
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

fade_out_and_delete_all_status_window_elements()
{
	fade_time = 0.3;
	fade_out_all_status_window_elements( fade_time );
	wait ( fade_time );
	delete_all_status_window_elements();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

loading_bar_progress( header, column_0, column_1 )
{
	hud_elem = maps\_hud_util::get_countdown_hud( -175, 34 );
	hud_elem.x			= -175;
	hud_elem.horzAlign	=  "right_adjustable";
	hud_elem.vertAlign	= "top_adjustable";
	hud_elem.alignX		= "right";
	hud_elem.fontscale	= level._status_window_dialogue.fontscale;
	hud_elem.layer		= level._status_window_dialogue.layer;
	hud_elem.color		= level._status_window_dialogue.color;

	// reset our value so we start at the correct value
	SetSavedDvar( "lunar_hud_boot_up_percent", 0.0 );
	hud_elem.label = Int( GetDvarFloat( "lunar_hud_boot_up_percent" ) * 100 );
	

	total_wait_time = boot_sequence_get_total_text_display_time( header, column_0, column_1 );
	num_loops = Int( total_wait_time / 0.05 );
	step = Float( 1 / num_loops );
	for ( index = 0; index < num_loops; index++ )
	{
		SetSavedDvar( "lunar_hud_boot_up_percent", GetDvarFloat( "lunar_hud_boot_up_percent" ) + step );
		hud_elem.label = Int( GetDvarFloat( "lunar_hud_boot_up_percent" ) * 100 );
		wait 0.05;
	}
	SetSavedDvar( "lunar_hud_boot_up_percent", 1.0 );
	hud_elem.label = Int( GetDvarFloat( "lunar_hud_boot_up_percent" ) * 100 );


	wait ( 0.15 );
	hud_elem Destroy();
	SetSavedDvar( "lunar_hud_boot_up_percent", 0.0 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

boot_sequence_get_total_text_display_time( header, column_0, column_1 )
{
	total = 0.0;
	
	foreach( string in header )
	{
		length = strlength( string );
		total += ( length * level._status_window_dialogue.section["header"].time_per_char ) / 1000;
	}

	foreach( string in column_0 )
	{
		length = strlength( string );
		total += ( length * level._status_window_dialogue.section["column_0"].time_per_char ) / 1000;
	}

	foreach( string in column_1 )
	{
		length = strlength( string );
		total += 0.3 + ( ( length * level._status_window_dialogue.section["column_0"].time_per_char ) / 1000 );
	}

	return total;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

proximity_paper_exploder()
{
	paper_exploders = GetEntArray( "paper_explode", "targetname" );
	foreach( paper_exploder in paper_exploders )
	{
		paper_exploder thread paper_explode();	
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

paper_explode()
{
	while( 1 )
	{
		// Wait for paper to be shot
		self setCanDamage( true );
		self waittill ( "damage", amount, attacker, direction_vec, point, type );		
	
		// Explode paper
		PlayFX( level._effect[ "paper" ], self.origin );
	
		// Hold a bit before FX again
		wait( 2 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

proximity_glass_break( glass_name )
{
	glass_triggers = GetEntArray( glass_name, "script_noteworthy" );
	foreach( glass_trigger in glass_triggers )
	{
		if( glass_trigger.code_classname == "trigger_multiple" )
		{
			glass_trigger thread proximity_glass_break_wait();
		}	
	}
}

// this - glass trigger
proximity_glass_break_wait()
{
	self waittill( "trigger" );
	bullet_start_pos = GetEnt( self.target, "targetname" );
	glass_pos = GetEnt( bullet_start_pos.target, "targetname" );
	end_pos = GetEnt( glass_pos.target, "targetname" );
	glass = GetGlass( end_pos.target );
	scale_force = 1.0;
	
	// tagTC<temp> - temp fix for broken hydroponics glass
	if( !IsDefined( glass ) )
	{
		return;
	}	

	random_glass_break = ( RandomFloat( 1.0 ) );
	direction = ( ( end_pos.origin - glass_pos.origin ) * scale_force );

	// Destroy the glass
	if( random_glass_break > 0.4 )
	{
		wait ( 0.1 + RandomFloat( 0.3 ) );
		MagicBullet( "lunarrifle", bullet_start_pos.origin, glass_pos.origin );
		DestroyGlass( glass, direction );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

suit_patch_hint()
{
	add_hint_string( "suit_patch_hint", &"NX_LUNAR_SUIT_PATCH_HINT", ::suit_patch_hint_remove );

	level._player waittill( "suit_destroyed" );
	display_hint( "suit_patch_hint" );

	wait( 10.0 );
	flag_set( "remove_patch_hint" ); 
}

suit_patch_hint_remove()
{		
	return flag( "remove_patch_hint" );
}

suit_patch_pickups()
{
	suit_patch_icon_triggers = GetEntArray( "suit_patch_icon_trigger", "targetname" );
	array_thread( suit_patch_icon_triggers, ::suit_patch_icon_trigger );

	suit_patch_pickup_triggers = GetEntArray( "suit_patch_pickup_trigger", "targetname" );
	array_thread( suit_patch_pickup_triggers, ::suit_patch_pickup_trigger );

	level._player thread suit_patch_pickup_trigger_watch_hint();
}

suit_patch_pickup_trigger()
{
	self trigger_on();

	// Press and hold X to Take Suit Patch Kit
	self sethintstring( &"NX_LUNAR_SUIT_PATCH_PICKUP_HINT" );	
	self UseTriggerRequireLookAt();

	if ( !isDefined( self.has_custom_icon_trigger ) || !self.has_custom_icon_trigger )
	{
		self thread create_patch_icon_trigger();
	}

	while ( true )
	{
		self waittill( "trigger" );

		if ( level._player GetFractionMaxAmmo( "nx_suitshield" ) < 1.0 || level._player GetWeaponAmmoClip( "nx_suitshield" ) == 0 )
		{
			break;
		}
	}

	// Add a patch kit for the player
	suit_patch_ammo = level._player GetWeaponAmmoClip( "nx_suitshield" );
	level._player GiveWeapon( "nx_suitshield"  ); // have to give weapon in case player has 0 patches left
	level._player SetWeaponAmmoClip( "nx_suitshield", ( suit_patch_ammo + 1 ) );

	if( GetDvar("environment_pressurized") == "1" )
                level._player playsound("suit_inject_patchkit_pickup_press");
	else
                level._player playsound("suit_inject_patchkit_pickup_depress");

	// Delete the patch kit geo
	patch_kits = GetEntArray( self.target, "targetname" );
	foreach( patch_kit in patch_kits )
	{
		patch_kit Delete();
	}

	self trigger_off();
}

suit_patch_pickup_trigger_watch_hint()
{
	pickup_allowed = true;

	while ( true )
	{
		wait 0.05;

		previous_pickup_allowed = pickup_allowed;
		pickup_allowed = self GetFractionMaxAmmo( "nx_suitshield" ) < 1.0 || level._player GetWeaponAmmoClip( "nx_suitshield" ) == 0;

		if ( previous_pickup_allowed != pickup_allowed )
		{
			suit_patch_pickup_triggers = GetEntArray( "suit_patch_pickup_trigger", "targetname" );

			if ( pickup_allowed )
			{
				array_call( suit_patch_pickup_triggers, ::sethintstring, &"NX_LUNAR_SUIT_PATCH_PICKUP_HINT" );
			}
			else
			{
				array_call( suit_patch_pickup_triggers, ::sethintstring, &"NX_LUNAR_SUIT_PATCH_PICKUP_FULL_HINT" );
			}
		}
	}
}

create_patch_icon_trigger()
{
	trigger = Spawn( "trigger_radius", self.origin, 0, 300, 100 );
	pickup_icon = create_suit_patch_pickup_icon( self );
	trigger thread watch_suit_patch_pickup_icon( self, pickup_icon );

	self waittill( "trigger" );

	pickup_icon Destroy();
}

suit_patch_icon_trigger()
{
	use_trigger = undefined;
	links = GetEntArray( self.script_noteworthy, "script_noteworthy" );
	foreach ( link in links )
	{
		if ( isDefined( link.targetname ) && link.targetname == "suit_patch_pickup_trigger" )
		{
			use_trigger = link;
		}
	}

	if ( isDefined( use_trigger ) )
	{
		use_trigger.has_custom_icon_trigger = true;

		pickup_icon = create_suit_patch_pickup_icon( use_trigger );
	
		self thread watch_suit_patch_pickup_icon( use_trigger, pickup_icon );

		use_trigger waittill( "trigger" );

		pickup_icon Destroy();
	}
}

create_suit_patch_pickup_icon( use_trigger )
{
	use_trigger endon( "trigger" );

	icon = NewHudElem();
	icon SetShader( "waypoint_patchkit", 1, 1 );
	icon.alpha = 0;
	icon.x = 0;
	icon.y = 0;
	icon.z = 0;
	icon.hidewhendead = true;
	icon.hidewheninmenu = true;

	patch_kit = GetEnt( use_trigger.target, "targetname" );
	icon.x = patch_kit.origin[ 0 ];
	icon.y = patch_kit.origin[ 1 ];
	icon.z = patch_kit.origin[ 2 ];

	icon.z += 12;
	icon SetWayPoint( true, true );
	return icon;
}

watch_suit_patch_pickup_icon( use_trigger, icon )
{
	use_trigger endon( "trigger" );

	while ( true )
	{
		self waittill( "trigger", other );

		if ( !isplayer( other ) )
		{
			continue;
		}

		while ( other IsTouching( self ) )
		{
			show = true;
			icon.color = ( getdvarfloat("color_enemy_r"), getdvarfloat("color_enemy_g"), getdvarfloat("color_enemy_b") );
			
			if ( player_looking_at( use_trigger.origin, 0.0, true ) && show )
			{
				icon_fade_in( icon );
			}
			else
			{
				icon_fade_out( icon );
			}

			wait 0.25;
		}
		icon_fade_out( icon );
	}
}

icon_fade_in( icon )
{
	if ( icon.alpha != 0 )
	{
		return;
	}

	icon FadeOverTime( 0.1 );
	icon.alpha = 1;
	wait( 0.1 );
}

icon_fade_out( icon )
{
	if ( icon.alpha == 0 )
	{
		return;
	}

	icon FadeOverTime( 0.2 );
	icon.alpha = 0;
	wait( 0.2 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

move_life_support_cart( name, distance, time )
{
	// Move the cart
	life_support_cart_parts = GetEntArray( name, "targetname" );
	foreach ( part in life_support_cart_parts )
	{
		part moveX( distance, time );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

flickering_lights()
{
	flickering_lights = getentarray( "flickering_lights", "targetname" );
	for ( i = 0; i < flickering_lights.size; i++ )
	{
		flickering_lights[ i ] thread maps\_lights::flickerLightIntensity( .2, .6 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// tagDK<note>: script stolen from repel util, possibly make global utility

ignore_everything()
{
	self.ignoreall = true;
	self.ignoreme = true;
	self.grenadeawareness = 0;
	self.ignoreexplosionevents = true;
	self.ignorerandombulletdamage = true;
	self.ignoresuppression = true;
	self.disableBulletWhizbyReaction = true;
	self disable_pain();
	self.dontavoidplayer = true;
	self.og_newEnemyReactionDistSq = self.newEnemyReactionDistSq;
	self.newEnemyReactionDistSq = 0;
}

// tagDK<note>: script stolen from repel util, possibly make global utility

clear_ignore_everything()
{
	self.ignoreall = false;
	self.ignoreme = false;
	self.grenadeawareness = 1;
	self.ignoreexplosionevents = false;
	self.ignorerandombulletdamage = false;
	self.ignoresuppression = false;
	self.disableBulletWhizbyReaction = false;
	self enable_pain();
	self.dontavoidplayer = false;
	if( IsDefined( self.og_newEnemyReactionDistSq ) )
	{
		self.newEnemyReactionDistSq = self.og_newEnemyReactionDistSq;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

set_deadly_tracking_ai( extra )
{
	// Get Ai Super Aggressive and Deadly
	enemy = self;
	enemy clear_force_color();
	enemy.maxsightdistsqrd = 8192 * 8192;
	enemy.favoriteenemy = level._player;
	if( IsDefined( extra ) )
	{
		enemy.baseaccuracy = 1000000.0;
	}
	else
	{
		enemy.baseaccuracy = 1.0;
	}
    enemy.pathrandompercent = 200;
    enemy SetGoalEntity( level._player );
    enemy.goalradius = 400;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

hidden_dynamic_run_speed()
{
	self endon( "death" );
	level endon( "stop_dynamic_run_speed" );

	while( 1 )
	{
		look_at_ally = within_fov( level._player.origin, level._player getplayerangles(), self.origin, Cos( 100 ) );
		if( look_at_ally )
		{
			if( self.moveplaybackrate > 1.2 )
			{
//  			self enable_cqbwalk();
				// Variable speeds
				normal_speed = ( 1.0 + RandomFloat( 0.2 ) );
				self.moveplaybackrate = normal_speed;
			}
		}
		else
		{
			if( self.moveplaybackrate < 1.5 )
			{
//  			self disable_cqbwalk();
				self.moveplaybackrate = 1.5;
			}
		}
		wait( 0.05 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

lunar_combat_init( give_helmet )
{
	lunar_weapon_init();
	lunar_patch_init();
	
	if ( !IsDefined( give_helmet ) || give_helmet == true )
	{
		// set the hud to military and instantly put on the player's helmet
		level._player maps\_moon::set_suit_hud_type("military");
		level._player PutOnHelmet( true );
	}
}

lunar_weapon_init()
{
	// Give the player the loadout
	maps\_loadout::give_loadout();
}

lunar_patch_init()
{
	// Give suit health mechanic to player
	level._player maps\_suitshield::suit_shield_give_patch_tool();

	// Suit patch pickups throughout the level
	level._player thread suit_patch_pickups();
	
	SetSavedDvar( "lunar_hud", "military" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_danger_zone()
{
	self endon( "end_danger_zone" );

	while( true )
	{
		// Wait for player in danger
		flag_wait( "player_in_danger" );
		self player_in_danger();
		//IPrintln( "Player in danger" );

		// Wait for player to leave danger
		while( true )
		{
			if( !flag( "player_in_danger" ) )
			{
				// Set not in danger
				self player_not_in_danger();
				//IPrintln( "Player safe" );
				break;	
			}
			wait( 0.05 );
		}
	}
}

end_danger_zone()
{
	flag_wait( "turn_off_danger_zones" );
	self notify( "end_danger_zone" );
}

player_in_danger()
{
	if( flag( "living_module" ) ) 
	{
		level._player set_player_attacker_accuracy( 25.0 );
	}
	else
	{
		level._player set_player_attacker_accuracy( 75.0 );
	}
	SetThreatBias( "axis", "player", 5000 );
}

player_not_in_danger( attacker_accuracy )
{
	level._player set_player_attacker_accuracy( 1.0 );
	SetThreatBias( "axis", "player", 0 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_flank_zone()
{
	// Create thread bias group if doesn't exist
	if( !ThreatBiasGroupExists( "flanked_enemies" ) )
	{
		CreateThreatBiasGroup( "flanked_enemies" );
	}

	self endon( "end_flank_zone" );

	while( true )
	{
		// Wait for player in flank
		flag_wait( "player_in_flank" );
		self player_in_flank();
		//IPrintln( "Player in flank" );

		// Wait for player to leave flank
		while( true )
		{
			if( !flag( "player_in_flank" ) )
			{
				// Set not in flank
				self player_not_in_flank();
				//IPrintln( "Player left flank" );
				break;	
			}
			wait( 0.05 );
		}
	}
}

end_flank_zone()
{
	self notify( "end_flank_zone" );
}

player_in_flank()
{
	SetThreatBias( "flanked_enemies", "player", -10000 );
}

player_not_in_flank( attacker_accuracy )
{
	SetThreatBias( "flanked_enemies", "player", 0 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

lunar_suit_state_settings( suit_type, suit_setting, helmet_loop, time )
{
		//this script should do multiple things to change the soundscape
		//and functionality of the sounds in lunar levels


		//first it must accept a time variable for setting a suit sound, and
		//use that variable when setting the suit
		if( !isdefined ( time ) )
			{
				//iprintln ("**************** time is NOT defined, now defining to 0");
				time = 0.0;	
			}
		else
			{
				//iprintln ("**************** time IS defined, not changing it.  time = " + time);
			}


		//the set_suit should set both the alias prefixes, and if there is an
		//associated EQ and reverb setting, then it will set those, too        
        if ( isdefined ( suit_type ) )
        {
			//check to see if the time variable exists, if so, then use set_suit_fade,
			//otherwise, just use set_suit
			//iprintln ("**************** Suit type IS defined.  suit_type = " + suit_type );

			if ( time == 0.0 )
				{
					//iprintln ("**************** Suit type IS defined and time equals ZERO");
					set_suit( suit_type );
				}
			else
				{
					//iprintln ("**************** Suit type IS defined and time DOES NOT equal ZERO");
					set_suit_fade( suit_type, time);
				}
        }
		else
		{
			//iprintln ("**************** There is NO suit type defined at all");
		}

		//next we need to set the game's "pressurization" variables
		//these variables are what the game uses to determine
		//which weapon sound to play, a pressurized, or depressurized version
		//it also has something to do with activating the suit shield, it seems
		//this changes the dvar for pressurized/depressurized
		maps\nx_lunar_util::airlock_set_environment( suit_type );



		//we now need to set the breathing for this helmet/suit/press state.
		//this means we should either stop breathing, use normal moon breathing
		//in the future, we should try and make this work for different emotional 
		//states of breathing, like dying, chasing, sneaking, battle, etc...



		//lastly, we should set the ambience for this state
		//DR: need to check to see if these are also being called outside of the set suit...might be...					

                   
        if ( isdefined ( helmet_loop ) ) 
        {  
                if ( helmet_loop == "null" )
                        //level._player stoploopsound( "amb_space_suit_amb" );
                        return;           
                else
			level._player PlayLoopSound( helmet_loop );
        }            

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

waittill_all_enemies_dead_or_dying( timeout )
{
	living_enemies = GetAIArray( "axis" );
	living_enemies_to_kill = living_enemies.size;
	waittill_dead_or_dying( living_enemies, living_enemies_to_kill, timeout );
}

waittill_number_of_enemies_remaining( count, timeout )
{
	living_enemies = GetAIArray( "axis" );
	living_enemies_to_kill = living_enemies.size;
	enemies_to_remain = living_enemies_to_kill - count;
	waittill_dead_or_dying( living_enemies, living_enemies_to_kill, timeout );
}

waittill_number_of_enemies_killed( count, timeout )
{
	living_enemies = GetAIArray( "axis" );
	living_enemies_to_kill = count;
	waittill_dead_or_dying( living_enemies, living_enemies_to_kill, timeout );
}

waittill_targetname_triggered( targetname )
{
	trigger_brush = GetEnt( targetname, "targetname" ); 
	trigger_brush waittill( "trigger" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// OPTIONAL: Pass in array of enemies to not be removed
clean_all_enemies( array )
{
	enemies = GetAIArray( "axis" );

	if( IsDefined( array ) )
	{
		enemies_to_remove = array_exclude( enemies, array );
	}
	else
	{
		enemies_to_remove = enemies;
	}	
		
	array_thread( enemies_to_remove, maps\_nx_utility::delete_ai_not_bullet_shielded );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

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
//                                                                  *
//                                                                  *
//*******************************************************************

lunar_traversal_killer_by_flag( targetname, ender )
{
	level endon( ender );

	flag_trigger = GetEnt( targetname, "targetname" );

	while( 1 )
	{
		level thread hide_scriptmodels_by_targetname( flag_trigger.target );
	
		flag_wait( flag_trigger.script_flag );
	
		level thread show_scriptmodels_by_targetname( flag_trigger.target );
	
		flag_waitopen( flag_trigger.script_flag );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Loads and plays the animated lunar display binks
lunar_screen_binks()
{
	wait 0.05;

	// stop any previous playback
	StopCinematicInGame();
	
	SetSavedDvar( "cg_cinematicFullScreen", "0" );
	CinematicInGameLoopResident( "nx_lunar_screen1_big" );
}

lunar_water_treatment_screen_binks()
{	
	// stop any previous playback
	StopCinematicInGame();
	
	SetSavedDvar( "cg_cinematicFullScreen", "0" );
	CinematicInGameLoopResident( "nx_lunar_screen2" );
}



