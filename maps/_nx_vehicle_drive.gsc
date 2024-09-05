//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Generic utility script for first-person drivable vehicles    **
//                                                                          **
//    Created: 12/16/2010 - Pedram Javidpour								**
//                                                                          **
//****************************************************************************
#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;


UPDATE_INTERVAL = 0.05;

// main: Call on a player
main( attributes )
{
	self.vehicle = [];

	if( IsDefined( attributes ) )
	{
		self.vehicle = attributes;

		foreach( key, value in self.vehicle )
		{
			set_key( key, value );
		}
	}
	else
	{
		AssertMsg( "Call to maps\_nx_vehicle_drive::main() is missing required argument" );
		return;
	}

	if( !is_key_defined( "vehicle" ) )
	{
		AssertMsg( "_nx_vehicle_drive::main(): You must supply a vehicle attribute." );
		return;
	}

	player_anims_init( get_key( "player_anims" ) );
	player_model_init( get_key( "player_model" ) );
//  vehicle_anims_init( get_key( "vehicle_anims" ) );
//  vehicle_model_init( get_key( "vehicle_model" ) );

	player_view_init();

	self thread drive( );
}

drive()
{
	vehicle = get_key( "vehicle" );

	vehicle waittill( "vehicle_mount",  player );

	if( player != self )
		return;

	vehicle MakeUsable();
	player SetPlayerAngles( vehicle.angles );
}

// Animation

#using_animtree( "vehicles" );
player_anims_init( anim_array )
{
	if( !IsDefined( anim_array ) )
		return;

	key = get_key( "vehicle" ).vehicletype + "_player";

	vehicle = get_key( "vehicle" );
	vehicle.animname = key;

	level._scr_animtree[ key ] = #animtree;
	level._scr_anim[ key ] = anim_array;
}

// Player model

player_model_init( model )
{
	if( !IsDefined( model ) )
		return;

	PrecacheModel( model );

	key = get_key( "vehicle" ).vehicletype + "_player";

	level._scr_model[ key ] = model;
}

player_view_init( )
{
	vehicle = get_key( "vehicle" );

	if ( IsDefined( vehicle.firstPerson ) )
		return;

//  vehicle SetModel( level._snowmobile_playerSnowmobileModel );
	vehicle Attach( get_key( "player_model" ), "tag_player" );
//  vehicle ClearAnim( vehicle getanim( "root" ), 0 );

	vehicle.firstPerson = true;

	self thread player_anims_update( );
}

player_anims_update()
{
	vehicle = get_key( "vehicle" );

	vehicle endon( "vehicle_dismount" );
	vehicle endon( "death" );

	self childthread player_anims_turning_update();
}

player_anims_turning_update()
{
	vehicle = get_key( "vehicle" );

	steering = 0;
	steering_prev = 0;
	steering_delta = 0;

	direction = 0;
	direction_prev = 0;
	direction_switch = false;

	left_to_right = "turn_left2right_";
	right_to_left = "turn_right2left_";

	anim_speed = [];
	anim_speed[ "L" ] = 0.0;
	anim_speed[ "R" ] = 0.0;
	anim_start_time = [];
	anim_start_time[ "L" ] = 0.0;
	anim_start_time[ "R" ] = 0.0;

	anim_left_to_right = [];
	anim_left_to_right[ "L" ] = vehicle getanim( "turn_left2right_L" );
	anim_left_to_right[ "R" ] = vehicle getanim( "turn_left2right_R" );

	anim_right_to_left = [];
	anim_right_to_left[ "L" ] = vehicle getanim( "turn_right2left_L" );
	anim_right_to_left[ "R" ] = vehicle getanim( "turn_right2left_R" );

	anim_dir = anim_left_to_right;
	anim_dir_prev = anim_dir;

	while( 1 )
	{
		// Steering value

		steering_prev		= steering;
		direction_prev 		= direction;
		anim_dir_prev		= anim_dir;

		steering			= clamp( vehicle Vehicle_GetSteering(), -1.0, 1.0 );
		steering_delta		= steering - steering_prev;
		direction_switch	= false;

//  	if( steering > 0 )
//  	{
//  		anim_speed[ "L" ] = steering;
//  		anim_speed[ "R" ] = abs( 1 - steering );
//  	}
//  	else if( steering < 0 )
//  	{
//  		anim_speed[ "L" ] = 1 - abs( steering );
//  		anim_speed[ "R" ] = abs( steering );
//  	}

		// Change in steering value
		if( steering_delta < 0)
		{
			direction = 1;
			anim_dir = anim_left_to_right;
		}
		else if ( steering_delta > 0 )
		{
			direction = -1;
			anim_dir = anim_right_to_left;
		}

		if( steering_delta == 0 )
		{
			anim_speed[ "L" ] = 0;
			anim_speed[ "R" ] = 0;
		}
		else
		{
			anim_speed[ "L" ] = abs( steering );
			anim_speed[ "R" ] = abs( steering );
		}

		anim_start_time[ "L" ] = anim_speed[ "L" ] * GetAnimLength( anim_dir[ "L" ] );
		anim_start_time[ "R" ] = anim_speed[ "R" ] * GetAnimLength( anim_dir[ "R" ] );


		// Change in steering direction?
		if( direction != direction_prev )
			direction_switch = true;

		// Set animations and animation times
		if( direction_switch )
		{
			vehicle ClearAnim( anim_dir_prev[ "L" ], 0 );
			vehicle ClearAnim( anim_dir_prev[ "R" ], 0 );
//  		vehicle ClearAnim( anim_dir[ "L" ], 0 );
//  		vehicle ClearAnim( anim_dir[ "R" ], 0 );

			vehicle SetAnim( anim_dir[ "L" ], 1, UPDATE_INTERVAL, anim_speed[ "L" ] );
			vehicle SetAnim( anim_dir[ "R" ], 1, UPDATE_INTERVAL, anim_speed[ "R" ] );
		}
		else
		{
		}

//  	vehicle SetAnimTime( anim_dir[ "L" ], anim_start_time[ "L" ] );
//  	vehicle SetAnimTime( anim_dir[ "R" ], anim_start_time[ "R" ] );

		wait UPDATE_INTERVAL;
	}

}


// Attribute mutator/accessor
is_key_defined( key )
{
	if( !IsPlayer( self ) )
		return;

	return ( IsDefined( self.vehicle[ key ] ) );
}

set_key( key, value )
{
	if( !IsPlayer( self ) )
		return;
	
	self.vehicle[ key ] = value;
}

get_key( key )
{
	if( !IsPlayer( self ) )
		return;

	if( IsDefined( self.vehicle[ key ] ) )
		return self.vehicle[ key ];
	else
		return undefined;
}
