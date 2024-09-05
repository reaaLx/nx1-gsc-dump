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
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_anim;


TRAIN_FLOOR_BOTTOM = 0;
TRAIN_FLOOR_TOP = 1;
TRAIN_FRONT = 2;
TRAIN_BACK = 3;
TRAIN_BLACKHAWK_LOOKAT = 4;

//*******************************************************************
//   Anim	                                                        *
//                                                                  *
//*******************************************************************
anim_create_paths()
{
// Bottom floor
	anim_create_path( "anim_window_back_left", "anim_window_mid_left", "bottom_window_right" );
	anim_create_path( "anim_window_back_left", "anim_window_back_right", "bottom_window_cross_left" );

	anim_create_path( "anim_window_back_right", "anim_window_mid_right", "bottom_window_left" );
	anim_create_path( "anim_window_back_right", "anim_window_back_left", "bottom_window_cross_left" );

	anim_create_path( "anim_window_front_left", "anim_window_mid_left", "bottom_window_left" );
	anim_create_path( "anim_window_front_left", "anim_window_front_right", "bottom_window_cross_left" );

	anim_create_path( "anim_window_front_right", "anim_window_mid_right", "bottom_window_right" );
	anim_create_path( "anim_window_front_right", "anim_window_front_left", "bottom_window_cross_left" );

	anim_create_path( "anim_window_mid_left", "anim_window_mid_right", "bottom_window_cross_left" );
	anim_create_path( "anim_window_mid_left", "anim_window_back_left", "bottom_window_left" );
	anim_create_path( "anim_window_mid_left", "anim_window_front_left", "bottom_window_right" );

	anim_create_path( "anim_window_mid_right", "anim_window_mid_left", "bottom_window_cross_left" );
	anim_create_path( "anim_window_mid_right", "anim_window_back_right", "bottom_window_right" );
	anim_create_path( "anim_window_mid_right", "anim_window_front_right", "bottom_window_left" );

// Top floor
	anim_create_path( "anim_window_back_left_top", "anim_window_mid_left_top", "bottom_window_right" );
	anim_create_path( "anim_window_back_left_top", "anim_window_back_right_top", "bottom_window_cross_left" );

	anim_create_path( "anim_window_back_right_top", "anim_window_mid_right_top", "bottom_window_left" );
	anim_create_path( "anim_window_back_right_top", "anim_window_back_left_top", "bottom_window_cross_left" );

	anim_create_path( "anim_window_front_left_top", "anim_window_mid_left_top", "bottom_window_left" );
	anim_create_path( "anim_window_front_left_top", "anim_window_front_right_top", "bottom_window_cross_left" );

	anim_create_path( "anim_window_front_right_top", "anim_window_mid_right_top", "bottom_window_right" );
	anim_create_path( "anim_window_front_right_top", "anim_window_front_left_top", "bottom_window_cross_left" );

	anim_create_path( "anim_window_mid_left_top", "anim_window_mid_right_top", "bottom_window_cross_left" );
	anim_create_path( "anim_window_mid_left_top", "anim_window_back_left_top", "bottom_window_left" );
	anim_create_path( "anim_window_mid_left_top", "anim_window_front_left_top", "bottom_window_right" );

	anim_create_path( "anim_window_mid_right_top", "anim_window_mid_left_top", "bottom_window_cross_left" );
	anim_create_path( "anim_window_mid_right_top", "anim_window_back_right_top", "bottom_window_right" );
	anim_create_path( "anim_window_mid_right_top", "anim_window_front_right_top", "bottom_window_left" );

}

anim_create_path( from_node_name, to_node_name, anim_scene )
{
	from_node = GetEnt( from_node_name, "targetname" );
	to_node = GetEnt( to_node_name, "targetname" );

	if( !IsDefined( level.anim_paths ) )
		level.anim_paths = [];

	if( !IsDefined( from_node.connections ) )
		from_node.connections = [];

	from_node.connections[ to_node_name ] = anim_scene;
	from_node.occupied = false;
	to_node.occupied = false;

	level.anim_paths[ from_node_name ] = from_node;
}


//*******************************************************************
//   Ally                                                           *
//                                                                  *
//*******************************************************************
ally_setup( ally_name, targetname, node_name )
{
	if( !IsDefined( level.squad ) )
		level.squad = [];

	ally = GetEnt( targetname, "targetname" );
	ally ally_set_node( node_name );
	ally LinkTo( level.platform );

	ally thread ally_update();

	ally.animname = "ally";

	ally magic_bullet_shield();

	level.squad[ ally_name ] = ally;
}

ally_set_node( node_name )
{
	node = level.anim_paths[ node_name ];
	self Teleport( node.origin, node.angles );
	self ally_occupy_node( node_name, true );
}

ally_occupy_node( node_name, occupied )
{
	level.anim_paths[ node_name ].occupied = occupied;

	if( occupied )
	{
		node = level.anim_paths[ node_name ];
		self.current_anim_node = node;

		if( IsDefined( node.script_stance ) )
		{
			self AllowedStances( node.script_stance );
		}
	}
	else
		self.current_anim_node = undefined;
}

ally_attack( target )
{
	self thread ally_attack_target( target );
}

ally_attack_target( target )
{
	self SetEntityTarget( target, 1.0 );
	target waittill( "death" );
	self ClearEntityTarget();
}


ally_update()
{
	self endon( "death" );

	while( 1 )
	{
		ally_update_position();
		wait 0.05;
	}
}

ally_update_position()
{
	if( !IsDefined( self.current_anim_node ) )
		return;

	if( !IsDefined( self.shootent) )
		return;

	current_node = self.current_anim_node;
	target = self.shootent;
	connections = current_node.connections;
	valid_nodes = [];

	foreach( node_name, connection in connections )
	{
		node = GetEnt( node_name, "targetname" );
		if( !node.occupied && Distance( node.origin, level._player.origin ) > 256 )
			valid_nodes[ valid_nodes.size ] = node;
	}

	valid_nodes[ valid_nodes.size ] = current_node;
	valid_nodes = get_array_of_closest( target.origin, valid_nodes );

	dest_node = valid_nodes[ 0 ];

	if( dest_node == current_node )
		return;

	anim_scene = connections[ dest_node.targetname ];
	self ally_occupy_node( current_node.targetname, false );
	dest_node Unlink();
	dest_node.angles = VectorToAngles( current_node.origin - dest_node.origin );
	dest_node LinkTo( level.platform );
	dest_node anim_single_solo( self, anim_scene );
	self ally_occupy_node( dest_node.targetname, true );
	wait RandomFloatRange( 2.0, 3.0 );
}

draw_node_angles()
{
	while( 1 )
	{
		r = 30;
		Line( self.origin, self.origin + ( 0, 0, r ), (1,0,0),1, false, 1);
		Line( self.origin, self.origin + ( cos (self.angles[1])*r, sin(self.angles[1])*r, 0 ), (0,0.7,1),1, false, 1);
		wait 0.05;
	}
}
//*******************************************************************
//   Player                                                         *
//                                                                  *
//*******************************************************************
player_setup()
{
	level._player GiveWeapon( "xm108_asco" );
	level._player SwitchToWeapon( "xm108_asco" );
}

on_player_floor_switch( action )
{
}

//*******************************************************************
//   Train                                                          *
//                                                                  *
//*******************************************************************
train_setup( train )
{
	train_glass_setup( "nx_prototype_harbor_window01", "nx_prototype_harbor_window02" );
	train_glass_setup( "nx_prototype_harbor_floor01", "nx_prototype_harbor_floor02" );
	train_glass_setup( "nx_prototype_harbor_glass_botb01", "nx_prototype_harbor_glass_botb02" );
	train_glass_setup( "nx_prototype_harbor_glass_botf01", "nx_prototype_harbor_glass_botf02" );
	train_glass_setup( "nx_prototype_harbor_glass_topb01", "nx_prototype_harbor_glass_topb02" );
	train_glass_setup( "nx_prototype_harbor_glass_topfc01", "nx_prototype_harbor_glass_topfc02" );
	train_glass_setup( "nx_prototype_harbor_glass_tops01", "nx_prototype_harbor_glass_tops02" );

	foreach( glass in GetEntArray( "train_glass", "script_noteworthy" ) )
	{
		glass thread train_glass_update();
	}
}

train_glass_setup( normal_model_name, destroyed_model_name )
{
	if( !IsDefined( level.train_glass ) )
		level.train_glass = [];

	level.train_glass[ normal_model_name ] = destroyed_model_name;
}

train_glass_update()
{
	self endon( "delete" );

	self SetCanDamage( true );
	self.health = 450;

	while( 1 )
	{
		self waittill( "damage" );
		if( self.health <= 0 )
		{
			// Play FX / SFX
			playFX( level._effect[ "train_glass_break" ], self.origin );

			self SetModel( level.train_glass[ self.model ] );
			break;
		}
	}
}

train_get_object( index )
{
	return level.platform.script_objects[ index ];
}

train_get_speed()
{
	return level.platform maps\_nx_moving_platform::get_speed();
}

train_set_speed( speed_mph )
{
	level.platform maps\_nx_moving_platform::set_speed( speed_mph );
}

link_to_train( platform )
{
	self maps\_nx_moving_platform::link_to_platform( platform );
}

train_delete()
{
	foreach( ally in level.squad )
	{
		ally Unlink();
		ally stop_magic_bullet_shield();
		ally delete();
	}

	level.platform maps\_nx_moving_platform::platform_delete();
}

//*******************************************************************
//  Chopper                                                         *
//                                                                  *
//*******************************************************************
chopper_attack( attack, target )
{
	self endon( "death" );
	self endon( "delete" );

	switch( attack )
	{
		case "gun":
			self thread maps\_helicopter_globals::shootEnemyTarget_Bullets( target );
			break;
		case "missile":
			self thread chopper_missiles( target );
			break;
		default:
			break;
	}
}

chopper_end_missiles()
{
	self notify( "missile_end" );
}

chopper_missiles( target )
{
	self endon( "death" );
	self endon( "delete" );
	self endon( "missile_end" );

	while( 1 )
	{
		shots = randomintrange( 2, 4 );
		delay = 0.5;
		self thread maps\_helicopter_globals::fire_missile( "ffar_hind", shots, target, delay );
		wait( shots * delay );
	}
}

//*******************************************************************
//  Vehicle                                                         *
//                                                                  *
//*******************************************************************
vehicle_create( targetname, thread_func )
{
	if( !IsDefined( level.vehicles ) )
		level.vehicle = [];

	vehicle = vehicle_spawn( GetEnt( targetname, "targetname" ) );
	vehicle GoPath();

	vehicle vehicle_update();

	level.vehicle[ targetname ] = vehicle;

	if( IsDefined( thread_func ) )
		vehicle thread [[thread_func]]();

	return vehicle;
}

vehicle_update()
{
	self thread vehicle_update_health();
	self thread vehicle_on_death();
}

vehicle_on_death()
{
}


vehicle_update_collision()
{
	self endon( "death" );
	self endon( "delete" );
	while( 1 )
	{
		enemy_vehicles = GetEntArray( "enemy_car", "script_noteworthy" );
		foreach( vehicle in enemy_vehicles )
		{
			if( Distance( self.origin, vehicle.origin ) <= 512 && !IsSpawner( vehicle ))
			{
//                mph = vehicle Vehicle_GetSpeed() * 3.0;
//                velocity = ( mph * cos( vehicle.angles[ 1 ] ), mph * sin( vehicle.angles[ 1 ] ), 0 );
////  			self VehPhys_Launch( velocity, 1.0, vehicle.origin );
				wait RandomFloatRange( 3.0, 5.0 );
//  			self Kill();
			}
		}
		wait 0.05;
	}
}

vehicle_kill_on_rider_death( index )
{
	self endon( "death" );
	self endon( "delete" );

	self.riders[ index ] waittill( "death" );
	wait RandomFloatRange( 0.5, 0.75 );
	self vehicle_crash( RandomFloatRange( 1.5, 2.0 ) );
}

vehicle_crash( delay_death )
{
	self VehPhys_Crash( 1 );
	if( IsDefined( delay_death ) )
		wait delay_death;
	self Kill();
}

vehicle_update_health()
{
	self endon( "death" );
	self endon( "delete" );

	while( 1 )
	{
		self waittill ( "damage", amount, attacker, direction_vec, point, type );

		if( IsAI( attacker ) )
			self.health += amount;
	}
}

vehicle_follow( target, min_speed, max_speed, look_at )
{
	self endon( "death" );
	self endon( "reached_dynamic_path_end" );
	self endon( "reached_end_node" );
	self endon( "end_follow" );


	if( self isHelicopter() && IsDefined( look_at ) )
	{
		self SetLookAtEnt( look_at );
	}

	interval = 0.05;

	while( 1 )
	{
		if( !within_fov( target.origin, target.angles, self.origin, cos( 90 ) ) )
		{
			if( self Vehicle_GetSpeed() <= max_speed )
				self Vehicle_SetSpeed( self Vehicle_GetSpeed() + 1.0, 15 );
		}
		else if( self Vehicle_GetSpeed() > min_speed )
			self Vehicle_SetSpeed( self Vehicle_GetSpeed() - 1.0, 10 );
	
		wait interval;
	}
}

vehicle_end_follow()
{
	self notify( "end_follow" );
}

vehicle_jump_to_path( path_value, path_key )
{
	node = undefined;
	if( self IsHelicopter() )
		node = GetEnt( path_value, path_key );
	else
		node = GetVehicleNode( path_value, path_key );

	self Vehicle_Teleport( node.origin, node.angles );
	self thread vehicle_detachfrompath();
	self.currentnode = node;
	self thread vehicle_resumepath();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

lane_logic( lane_array_name, base_speed, base_time, delete_radius, endon_flag, headlights_on )
{
	self endon( endon_flag );

	COUNT_CAP = 50;
	lane_array = GetEntArray( lane_array_name, "targetname" );
	
	// Spawn the vehicle, unload and breach
	for( ; ; )
	{
		// Random spawner
		random_index =  RandomInt( lane_array.size );
		vehicle_spawner = lane_array[ random_index ];  

		if( GetNumVehicles() < COUNT_CAP )
		{
			// Spawn vehicle
			vehicle = vehicle_spawn( vehicle_spawner );
			vehicle GoPath();
			vehicle thread vehicle_update_collision();
			vehicle.health = 1000;
			if( IsDefined( headlights_on ) && headlights_on )
				vehicle lights_on( "all" );

			// Speed
			vehicle thread ambient_vehicle_thread( base_speed, delete_radius );
		}

		wait( RandomFloatRange( base_time, ( base_time + 0.5 ) ) );	
	}
}

ambient_vehicle_thread( base_speed, delete_radius )
{
	self endon( "death" );
	self endon( "reached_end_node" );

	self thread ambient_vehicle_end_path();
		
	self Vehicle_SetSpeed( 200, 100000 );
	
	// Slow down if in player range
	while( true )
	{
		dist = Distance2D( self.origin, level._player.origin );
		if( dist < delete_radius )
		{	
			break;
		}
		wait( 0.05 );
	}

	self Vehicle_SetSpeed( RandomIntRange( base_speed, ( base_speed + 5 ) ), 200, 100000 );

	// Delete if left player range
	while( true )
	{
		dist = Distance2D( self.origin, level._player.origin );
		if( dist > delete_radius )
		{	
			break;
		}
		wait( 0.05 );
	}

	self delete();
}

ambient_vehicle_end_path()
{
	self endon( "death" );
	self waittill( "reached_end_node" );

	self delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
