//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Mission Utils												**
//                                                                          **
//    Created: 11/11/11 - Travis Chen (trchen x 4143)						**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_nx_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_anim;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_start( player_start_struct_name )
{
	// Move player to start
	player_start_struct = GetStruct( player_start_struct_name, "targetname" );
	level._player setOrigin( player_start_struct.origin );
	level._player setPlayerAngles( player_start_struct.angles );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Removes all ai NOW (except bulletshielded) 
delete_all_ai_immediately()
{
	aAI = getaiarray();	
	array_thread( aAI, ::delete_ai_not_bullet_shielded );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
actor_detection_movement_control( dist, angle )
{
	self endon ( "terminate_actor_detection" );

	self thread stop_when_actor_in_front( dist, angle );

	while ( 1 )
	{
		level waittill ( "ally_convoy_stop_actor_in_front" );
		self Vehicle_SetSpeed( 0, 10 );
		level waittill ( "ally_convoy_go_no_actor_in_front" );
		self ResumeSpeed( 3 );
		wait ( 0.05 );
	}
}

stop_when_actor_in_front( dist, angle )
{
	self endon ( "terminate_actor_detection" );
	self.stop_due_to_actors_in_front = false;

	while ( 1 )
	{
		if ( self vehicle_actors_in_front( dist, angle ))
		{
			if ( isDefined ( self.stop_due_to_actors_in_front ) && self.stop_due_to_actors_in_front == false )
			{
				level notify ( "ally_convoy_stop_actor_in_front" );
				self.stop_due_to_actors_in_front = true;
				//iPrintlnBold ( "##### Vehicle stopping due to actors in front" );
			}
		}
		else if (!( self vehicle_actors_in_front( dist, angle )))
		{
			if ( isDefined ( self.stop_due_to_actors_in_front ) && self.stop_due_to_actors_in_front == true )
			{
				level notify ( "ally_convoy_go_no_actor_in_front" );
				self.stop_due_to_actors_in_front = false;
				//iPrintlnBold ( "##### Vehicle moving.  Actors clear." );
			}
		}
		wait ( 0.5 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Returns true if any actors (player, squad-mate or enemy) is standing in the way of the vehicle (within a specified angle and distance)
vehicle_actors_in_front( dist, angle )
{
	actors_in_front = false;

	if( vehicle_entity_in_front( level._player, dist, angle ) )
	{
		actors_in_front = true;
	}
	else 
	{
		ai_array = GetAISpeciesArray( "all", "all" );
		foreach( ai in ai_array )
		{
			if( vehicle_entity_in_front( ai, dist, angle ))
			{
				actors_in_front = true;
				break;
			}
		}
	}
	return actors_in_front;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Setting up badplace.  This thread runs on the vehicle trigger 
vehicle_path_disconnector()
{
	zone = getent( self.target, "targetname" );
	assert( isdefined( zone ) );
	zone notsolid();
	zone.origin -= ( 0, 0, 1024 );
	badplaceName = "vehicle_bad_place_brush_" + zone getEntityNumber();

	for ( ;; )
	{
		self waittill( "trigger", vehicle );

		//println ( "##### Vehicle trigger activated" );
		
		if ( !isalive( level.vehicle_convoy[ "vehicle_convoy_1" ] ) || !isalive( level.vehicle_convoy[ "vehicle_convoy_2" ] ))
		{
			return;
		}
		
		if ( !isdefined( vehicle ) )
		{
			continue;
		}

		if ( ( vehicle != level.vehicle_convoy[ "vehicle_convoy_1" ] ) && ( vehicle != level.vehicle_convoy[ "vehicle_convoy_2" ] ))
		{
			continue;
		}
		
		if ( vehicle vehicle_getspeed() == 0 )
		{
			continue;
		}

		if ( !isdefined( zone.pathsDisconnected ) )
		{
			zone solid();

			badplace_brush( badplaceName, 0, zone, "allies", "axis" );

			zone notsolid();
			zone.pathsDisconnected = true;
			println ( "##### Bad place brush created" );
		}

		self thread vehicle_reconnects_paths( zone, badplaceName );
	}
}

vehicle_reconnects_paths( zone, badplaceName )
{
	assert( isdefined( zone ) );
	assert( isdefined( badplaceName ) );
	zone notify( "waiting_for_path_reconnection" );
	zone endon( "waiting_for_path_reconnection" );

	level waittill ( "delete_bad_place_brush" );

	zone solid();
	badplace_delete( badplaceName );
	zone notsolid();
	zone.pathsDisconnected = undefined;
}

waitForVehicleToPass()
{
	self waittillmatch( "trigger", level.vehicle_convoy[ "vehicle_convoy_2" ] );

	level notify ( "delete_bad_place_brush" );

	println ( "##### After delete the bad place brush" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Sets up leader spawner
leader_spawner_setup()
{
	ally_spawners = GetEntArray( "actor_squad", "script_noteworthy" );
	Assert( IsDefined( ally_spawners ));

	found = false;

	foreach( guy in ally_spawners )
	{
		if( IsDefined( guy.script_friendname ))
		{
			if( guy.script_friendname == "Baker" )
			{
				guy add_spawn_function( ::spawnfunc_leader );
				found = true;
				break;
			}	
		}
	}
	
	if( !found )
		AssertMsg( "Could not find the squad leader spawner!" );	
}

// Leader spawnfunc
spawnfunc_leader()
{
	self.animname = "passengerfront";
	level.leader = self;
	self thread magic_bullet_shield();	
        level.leader set_battlechatter_id( "bak" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawns allies based on initial spawners
spawn_allies( location_objects )
{	
	spawners = GetEntArray( "actor_squad", "script_noteworthy" );
	Assert( IsDefined( spawners ));	

	// Expected ally number is two less than the spawners because of the drivers
	ally_num = spawners.size - 2;

	if( location_objects.size != ally_num )
		AssertMsg( "Ally # is not equal to position #: (" + ally_num + " / " + location_objects.size );

	level.allies = [];
	position_counter = 0;

	for( i = 0; i < spawners.size; i++ )
	{
		if( IsDefined( spawners[ i ].script_startingposition ))
		{
			if( spawners[ i ].script_startingposition > 0 )
			{
				guy = spawners[ i ] spawn_ai();
				Assert( IsDefined( guy ));

				guy ForceTeleport( location_objects[ position_counter ].origin, location_objects[ position_counter ].angles ); 
				level.allies = array_add( level.allies, guy );
				position_counter++;
			}
		}
	}
}

ally_spawner_setup()
{
	level.allies = [];

	array_spawn_function_noteworthy( "actor_squad", ::spawnfunc_allies );

	// Keep ally variable up to date with allies (as they die off)
	thread ally_global_watcher();

}

// Keep ally level variable up to date
ally_global_watcher()
{
   	while( 1 )
	{
		level.allies = GetAIArray( "allies" );
		wait 0.05;
	}
}

spawnfunc_allies()
{
	self thread replace_on_death();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

