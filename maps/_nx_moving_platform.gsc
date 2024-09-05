#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;

DEFAULT_SPEED = 30.0;
MPH_TO_IPS = ( 63360.0 / 3600.0 );	// Constant for converting Miles per hour to inches per second
IPS_TO_MPH = ( 1.0 / MPH_TO_IPS );

/*QUAKED script_origin_linkto (1 0 0) (-8 -8 -8) (8 8 8)
*/

init( targetname, speed )
{
	if( !IsDefined( speed ) )
	{
		speed = DEFAULT_SPEED;
	}

	platform_model = undefined;
	platform = undefined;
	pieces = [];
	components = [];

	platform_model = GetEnt( targetname, "targetname" );
	if( !IsDefined( platform_model ) )
	{
		//IPrintln( "WARNING: Platform " + targetname + " doesn't exist. Possibly compiled out." );
		return undefined;
	}

	// Attach geo
	if( IsDefined( platform_model.script_moving_platform_geo ) )
	{
		components = GetEntArray( platform_model.script_moving_platform_geo, "script_noteworthy" );
	}

	foreach( component in components )
	{
		type = 	component.code_classname;

		if( type == "script_model" || type == "script_brushmodel" )
		{
			pieces[ pieces.size ] = component;
		}
	}

	// Collision Map
	if( IsDefined( platform_model.collmap_targetname ) )
	{ 
		platform = platform_model setup_moving_platform(); // Setup
	}
	else
	{
		platform = platform_model;
	}

	// Set speed
	platform set_speed( speed ); // Set default speed

	// Attach all pieces
	if( !isDefined( platform.linked_ents) )
		platform.linked_ents = [];
	if( pieces.size > 0 )
		platform attach_pieces( pieces ); // Link pieces

	// Link all scritable entities to platform
	if( IsDefined( platform_model.script_moving_platform_script ) )
	{ 
		platform attach_platform_ents( platform_model.script_moving_platform_script );
	}

	return platform;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

attach_pieces( pieces )
{
	foreach( piece in pieces )
	{
		piece link_to_platform( self );
	}
}

//*******************************************************************
// Script Entities on platform                                      *
//                                                                  *
//*******************************************************************

attach_platform_ents( script_name )
{
	if( IsDefined( self.script_ents ) )
		return;

	self.script_ents = [];
	script_ents = GetEntArray( script_name, "script_noteworthy" );

	invalid_types = [ "trigger_use", "spawner" ];

	foreach( ent in script_ents )
	{		
		// Don't add invalid types
		if( !IsDefined( ent.code_classname ) || is_invalid_type( invalid_types, ent.code_classname ) )
		{
			continue;
		} 
	
		if( !IsDefined( ent.targetname ) )
		{
			ent.targetname = "misc";
		}

		if( !IsDefined( self.script_ents[ ent.targetname ] ) )
		{
			self.script_ents[ ent.targetname ] = ent;
		}
		else
		{
			// Multiple ents with same targetname, create array
			if( IsArray( self.script_ents[ ent.targetname ] ) )	
			{
				// Array already exists, add to array
				array_size = self.script_ents[ ent.targetname ].size;
				self.script_ents[ ent.targetname ][array_size] = ent;
			}
			else
			{
				// Create array of elements
				old_ent = self.script_ents[ ent.targetname ];
				array_of_ents = [ old_ent, ent ];
				self.script_ents[ ent.targetname ] = array_of_ents;
			}
		}
		
		// tagTC<note> - for some reason spawners aren't linking
		if( !IsSpawner( ent ) )
		{ 
			ent LinkTo( self );
		}

		self link_weapons( script_name );
	}
}

is_invalid_type( invalid_types, code_classname )
{
	foreach( type in invalid_types )
	{
		if( type == code_classname ) 
		{
			return true;
		}
	}
	return false;
}

get_platform_ent( index )
{
	//assert( !IsArray( self.script_ents[ index ] ), "Index: " + index + "is an array of ents. Use get_platform_ents instead." );
	return self.script_ents[ index ];
}

get_platform_ents( index )
{
	//assert( IsArray( self.script_ents[ index ] ), "Index: " + index + "is not an array of ents. Use get_platform_ent instead." );
	ent_array = [];
	if( !IsArray( self.script_ents[ index ] ) )
	{
		ent_array[0] = self.script_ents[ index ]; 
	}
	else
	{
		ent_array = self.script_ents[ index ];
	}
	
	
	return ent_array;
}

init_player_start()
{
	player_start = get_platform_ent( "player_start" );
	level._player SetOrigin( player_start.origin );
	level._player SetPlayerAngles( player_start.angles );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

start_path( path_value, path_key, vibrate )
{
	self thread move( path_value, path_key, vibrate );
}

move( path_value, path_key, vibrate )
{
	self endon( "platform_path_end" );

	self.current_node = GetEnt( path_value, path_key );

	if( !IsDefined( self.current_node ) )
		return;

	self.origin = self.current_node.origin;
	self.angles = self.current_node.angles;

	while ( 1 )
	{
		self notify( "next_move" );

		// Notify of the current node's script_noteworthy string if there is one.
		if( IsDefined( self.current_node.script_noteworthy ) )
			self notify( self.current_node.script_noteworthy );

		// Set the next node if there is one
		if( IsDefined( self.current_node.target ) )
			self.current_node = GetEnt( self.current_node.target, "targetname" );
		else
			self.current_node = undefined;

		// Notify end of path if there are no other nodes
		if( !IsDefined( self.current_node ) )
		{
			self notify( "platform_path_end" );
			break;
		}

		// Set speed from node
		accel_time = 0;
		decel_time = 0;
		old_speed = 0;
		if( IsDefined( self.current_node.speed ) )
		{
			old_speed = self get_speed();
			self set_speed( self.current_node.speed );
		}

		// Do the actual movement, wait to be done
		travel_time = self update_movement( vibrate );
		self thread wait_move_done( travel_time );
		self waittill( "move_done" );
	}
}

wait_move_done( travel_time )
{
	self endon( "next_move" );
	wait( travel_time );
	self notify( "move_done" );
}

update_movement( vibrate )
{
	// Calculate travel time based on current speed
	travel_time = Distance( self.origin, self.current_node.origin ) / ( self get_speed() * MPH_TO_IPS );

	if( travel_time <= 0 )
	{
		return;
	}

	// Interpolate origin and angles to the next node.
	self MoveTo( self.current_node.origin, travel_time );

	// Get angles
	rotate_to_angles = VectorToAngles( self.current_node.origin - self.origin );

	if( IsDefined( vibrate ) && vibrate )
	{
		self thread rotateto_and_vibrate( rotate_to_angles, travel_time );
	}
	else
	{
		self RotateTo( rotate_to_angles, travel_time );
	}

	// Do linked movment
	self thread update_linked_movement( rotate_to_angles, travel_time, vibrate );

	return travel_time;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

update_linked_movement( rotate_to_angles, travel_time, vibrate )
{
	// Get front link point
	front_link_point = self maps\_nx_moving_platform::get_platform_ent( "front_link_point" );
	rear_link_point = self maps\_nx_moving_platform::get_platform_ent( "rear_link_point" );

	if( !IsDefined( rear_link_point ) || !IsDefined( front_link_point ) )
	{
		return;
	}

	// Wait delay
	delay = Distance( front_link_point.origin, rear_link_point.origin ) / ( self get_speed() * MPH_TO_IPS );
	
	link_cars = self.link_cars;

	if( IsDefined( link_cars ) )
	{
		foreach( link_car in link_cars )
		{
			wait( delay );

			if( IsDefined( vibrate ) && vibrate )
			{
				link_car thread rotateto_and_vibrate( rotate_to_angles, travel_time );
			}
			else
			{
				link_car RotateTo( rotate_to_angles, travel_time );
			}
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rotateto_and_vibrate( target_angles, travel_time )
{	
	self notify( "stop_random_rotations" );
	self endon( "stop_random_rotations" );
	toggle_dir = false;
	while( 1 )
	{
		// Add random, turn based rotation
		rotate_to_angles = add_random_turn_rotation( self.angles, target_angles, toggle_dir );

		// Do car rotation
		self RotateTo( rotate_to_angles, travel_time );		

		toggle_dir = toggle_bool( toggle_dir );

		// Update travel time
		random_wait = RandomFloatRange( 0.25, 0.35 );
		travel_time = ( travel_time - random_wait );
		if( travel_time <= 0.25 )
		{
			break;
		}
		wait( random_wait );	
	}
}

toggle_bool( bool )
{
	if( bool )
	{
		bool = false;
	}
	else
	{
		bool = true;
	}

	return bool;
}

add_random_turn_rotation( foward_angles, target_angles, toggle_dir )
{
	if( toggle_dir )
	{
		target_angles = ( target_angles - ( 0, 0, RandomFloatRange( -2, -1 ) ) );
	}
	else
	{
		target_angles = ( target_angles - ( 0, 0, RandomFloatRange( 1, 2 ) ) );
	}

	
	// Code to get direction of turning movement
	/*dir = angle_dir( foward_angles, target_angles, AnglesToUp( foward_angles ) );

	if( dir > 0 )
	{
		target_angles = ( target_angles - ( 0, 0, RandomFloatRange( 1, 2 ) ) );
	}
	else if ( dir < 0 )
	{
		target_angles = ( target_angles + ( 0, 0, RandomFloatRange( 1, 2 ) ) );
	}
	else
	{
		target_angles = ( target_angles - ( 0, 0, RandomFloatRange( -1, 1 ) ) );
	}*/

	return target_angles;
}

angle_dir( foward_angles, target_angles, up )
{
	perp = VectorCross( foward_angles, target_angles );
	dir = VectorDot( perp, up );

	if ( dir > 0.0 ) {
		return 1.0;
	} else if ( dir < 0.0 ) {
		return -1.0;
	} else {
		return 0.0;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

platform_process_all_elements( type )
{
	foreach( ent in self.linked_ents )
	{  	
		ent platform_process_element( type );
	}

	foreach( ent_i in self.script_ents )
	{  	
		if( IsArray( ent_i ) )	
		{
			foreach( ent_j in ent_i )
			{
				ent_j platform_process_element( type );
			}
		}
		else
		{
			ent_i platform_process_element( type );
		}	
	}
}

platform_process_element( type )
{
	if( IsDefined( self ) )
	{
		switch ( type )
		{
			case "hide":
			{
				self Hide();
				break;
			}
			case "show":
			{
				self Show();
				break;
			}			
			case "delete":
			{
				self Unlink();
				self Delete();
				break;
			}
		}
	}
}

platform_hide()
{
	self platform_process_all_elements( "hide" );
}

platform_show()
{
	self platform_process_all_elements( "show" );

}

platform_delete()
{
	self notify( "platform_path_end" );

	self platform_process_all_elements( "delete" );

	self Delete();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

waittill_path_end()
{
	self waittill( "platform_path_end" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

link_to_platform( platform )
{
	if( !IsDefined( platform.linked_ents ) )
	{
		platform.linked_ents = [];
	}

	platform.linked_ents[ platform.linked_ents.size ] = self;

	self LinkTo( platform );
}

set_speed( mph )
{
	self.speed = mph;
}

set_speed_moving( mph )
{
	self endon( "next_move" );
	self.speed = mph;
	travel_time = self update_movement();
	wait( travel_time );
	self notify( "move_done" );
}

get_speed()
{
	return self.speed;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

follow_player( follow_ent, time_low, time_high, speed_percent, arc )
{
	self endon( "stop_follow_player" );
	self endon( "platform_path_end" );
	
	base_speed = maps\_nx_moving_platform::get_speed();
	while( 1 ) 
	{
		to_player = VectorNormalize( follow_ent.origin - level._player.origin );
		right_angles = AnglesToForward( follow_ent.angles );
		dot = VectorDot( right_angles, to_player );

		if( dot > ( arc / 100 ) ) 
		{
			self maps\_nx_moving_platform::set_speed_moving( base_speed - ( base_speed * speed_percent ) );
		}
		else if( dot < ( -1 * arc / 100 ) )
		{						 
			self maps\_nx_moving_platform::set_speed_moving( base_speed + ( base_speed * speed_percent ) );
		}
		else
		{
			self maps\_nx_moving_platform::set_speed_moving( base_speed );
		}

		random_wait = RandomFloatRange( time_low, time_high );
		wait( random_wait );
	}
}

stop_follow_player()
{
	self notify( "stop_follow_player" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

link_platform_to_vehicle( vehicle, hide_vehicle )
{
	if( !IsDefined( hide_vehicle ) )
	{
		hide_vehicle = true;
	}

	// tagTC<note> - Link to vehicle, write util for this
	vehicle VehicleDisableGravity( 1 );
	self LinkTo( vehicle, "TAG_TURRET", ( 0, 0, 0 ), (0,0,0) );

	if( hide_vehicle )
	{
		vehicle Hide();
	}

	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// tagTC<note> - temp hack until LinkTo is updated for have angular movement support
follow_car( follow_car )
{
	rear_link_point = follow_car maps\_nx_moving_platform::get_platform_ent( "rear_link_point" );

	while( 1 )
	{
		self.origin = rear_link_point.origin;
		wait( 0.05 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

link_weapons( script_name )
{
	weapon_linkto = GetEntArray( "script_origin_linkto", "classname" );

	foreach( weapon_linkto_origin in weapon_linkto )
	{
		//only want to link for the platform it's currently on. The origin should have inherited the script_noteworthy from above it 
		//in the prefab tree.
		if( !IsDefined(weapon_linkto_origin.script_noteworthy) || weapon_linkto_origin.script_noteworthy != script_name ) 
		{
			continue;
		}

		Assert( IsDefined( weapon_linkto_origin.target ) );

		//weapon_linkto_origin thread debug_script_origin_linkto();

		weapon = GetEnt( weapon_linkto_origin.target, "targetname" );

		Assert( IsDefined( weapon ) );
		AssertEx( IsDefined( weapon.code_classname), "The weapon " + weapon.classname + " appears to be missing and will fail to linkto." );

		weapon.origin = weapon_linkto_origin.origin;
		weapon.angles = weapon_linkto_origin.angles;

		weapon LinkTo( weapon_linkto_origin );
	}
}
/*
debug_script_origin_linkto()
{
	while( true )
	{
		debug_draw_origin( self.origin );
		wait 0.05;
	}
}

debug_draw_origin( origin )
{
	Line( origin + ( 16, 0, 0 ), origin + ( -16, 0, 0 ), ( 1, 0, 0 ), 1, 0, 1 );
	Line( origin + ( 0, 16, 0 ), origin + ( 0, -16, 0 ), ( 0, 1, 0 ), 1, 0, 1 );
	Line( origin + ( 0, 0, 16 ), origin + ( 0, 0, -16 ), ( 0, 0, 1 ), 1, 0, 1 );
}
*/

