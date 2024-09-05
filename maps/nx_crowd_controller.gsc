#include maps\_utility;
#include common_scripts\utility;

/*
=============
Using Crowds for Fun and Profit

INCLUDING:
-In your .csv, add the following line:
	include, nx_crowd_controller
-In your .gsc, add the following line to your main() function:
	maps\nx_crowd_controller::main();

//////////////////////
SETTING UP A CROWD:

Crowds are created by calling the function maps\nx_crowd_controller::new_crowd( name, count, spawners, starts, ends, <minInterval>,  <maxInterval> )

When the crowd is done spawning, the level will notify with the name you supplied.
For example, if you named your crowd "dudes" the level will notify "dudes".


Required args:
name:		A name that can be used to identify this crowd.
count:		The number of drones to spawn in this crowd.
spawners:	An array of spawner entities to populate this crowd.
starts:		An array of entities that the spawners can spawn at.
ends:		An array of entities that the spawners will travel to once they are spawned in.  If these entities have targets, the spawned drone will follow
			each target like a chain until it reaches an entity with no targets.  See map nx_crowd for an example.
minInterval:	The minimum amount of time to wait between each actor spawn (defaults to 0.5 seconds).
maxInterval:	The maximum amount of time to wait between each actor spawn (defaults to minInterval). 
				The interval time will be a random value between minInterval and maxInterval.

Example:
maps\nx_crowd_controller::new_crowd( "ewoks", 12, ewok_spawners, start_nodes, end_nodes, 0.5, 2.0 );

//////////////////////
SPAWNING A CROWD:
Once you have created a crowd with new_crowd, call maps\nx_crowd_controller::spawn_crowd( name ) to spawn the crowd and let it run.

Required args:
name:		The name of the crowd (should match the name supplied to new_crowd).

Example:
maps\nx_crowd_controller::spawn_crowd( "ewoks" );
//Now, you can wait for the crowd to finish spawning by calling:
level waittill( "ewoks" );

//////////////////////

=============
*/


main( attributes )
{
	level.crowds = [];
}

init_crowd( name, count, spawners, starts, minInterval, maxInterval )
{
	if( !IsDefined( name ) || !IsDefined( count ) || !IsDefined( spawners ) || !IsDefined( starts ) )
		return;

	level.crowds[ name ] = [];
	level.crowds[ name ][ "count" ] = count;
	level.crowds[ name ][ "spawner" ] = spawners;
	level.crowds[ name ][ "start" ] = starts;
	level.crowds[ name ][ "number" ] = 0;
	
	minTime = 0.5;
	if( IsDefined( minInterval ) && minInterval >= 0.5 )
		minTime = minInterval;
	level.crowds[ "minInterval" ] = minTime;

	maxTime = level.crowds[ "minInterval" ];
	if( IsDefined( maxInterval ) && maxInterval >= level.crowds[ "minInterval" ] )
		maxTime = maxInterval;
	level.crowds[ "maxInterval" ] = maxTime;

	foreach( spawner in level.crowds[ name ][ "spawner" ] )
	{
		spawner add_spawn_function( ::crowd_actor_update, name );
	}

	return name;
}

new_crowd( name, count, spawners, starts, ends, minInterval, maxInterval )
{
// NOTE: use init_crowd() from now on

//  if( !IsDefined( name ) || !IsDefined( count ) || !IsDefined( spawners ) || !IsDefined( starts ) || !IsDefined( ends ) )
//  	return;
//
//  level.crowds[ name ] = [];
//  level.crowds[ name ][ "count" ] = count;
//  level.crowds[ name ][ "spawner" ] = spawners;
//  level.crowds[ name ][ "start" ] = starts;
//  level.crowds[ name ][ "end" ] = ends;
//
//
//  minTime = 0.5;
//  if( IsDefined( minInterval ) && minInterval >= 0.5 )
//  	minTime = minInterval;
//  level.crowds[ "minInterval" ] = minTime;
//
//  maxTime = level.crowds[ "minInterval" ];
//  if( IsDefined( maxInterval ) && maxInterval >= level.crowds[ "minInterval" ] )
//  	maxTime = maxInterval;
//  level.crowds[ "maxInterval" ] = maxTime;
//
//  foreach( spawner in level.crowds[ name ][ "spawner" ] )
//  {
//  	spawner add_spawn_function( ::crowd_actor_update );
//  }
//
//  return name;
}

crowd_actor_update( name )
{
	self endon( "death" );

	level.crowds[ name ][ "number" ]++;
	thread crowd_actor_death( name );

	while( 1 )
	{
		self waittill( "goal" );

		// AI treat each node in the path as a separate goal
		// Drones only treat the last node in the path as a goal.
		curTarget = GetEnt( self.target, "targetname" );
		if( IsAI( self ) && IsDefined( curTarget.target ) && IsDefined( GetEnt( curTarget.target, "targetname" ) ) )
			self.target = curTarget.target;
		else
			self Delete();
	}
}

crowd_actor_death( name )
{
	self waittill( "death" );

	level.crowds[ name ][ "number" ]--;
}

spawn_crowd( name, kill_flag )
{
	if( !IsDefined( level.crowds[ name ] ) )
		return;
	
	level thread spawn_crowd_actors( name, kill_flag );
}

spawn_crowd_actors( name, kill_flag )
{
	// tagBR< note >: It was possible, because of the wait at the end of this script, for crowds to spawn
	// after they've been deleted. This kill_flag insures this won't happen.
	if ( IsDefined( kill_flag ) )
	{
		level endon( kill_flag );
	}

	crowd = level.crowds[ name ];

	for( i = 0; i < crowd[ "count" ]; i++ )
	{
		start = random( crowd[ "start" ] );
		spawner = random( crowd[ "spawner" ] );
		spawner.target = start.targetname;
		spawner.count = -1;

		ai = spawner spawn_ai( true );

		if( IsDefined( ai ) )
		{	
			if( IsAI( ai ) )
				ai ForceTeleport( start.origin, start.angles );
			else
				ai.origin = start.origin;
		}

		if( level.crowds[ "maxInterval" ] > level.crowds[ "minInterval" ] )
			wait RandomFloatRange( level.crowds[ "minInterval" ], level.crowds[ "maxInterval" ] );
		else
			wait level.crowds[ "minInterval" ];
	}

	level notify ( name );
}

//spawn_crowd_actors( name, kill_flag )
//{
//    // tagBR< note >: It was possible, because of the wait at the end of this script, for crowds to spawn
//    // after they've been deleted. This kill_flag insures this won't happen.
//    if ( IsDefined( kill_flag ) )
//    {
//        level endon( kill_flag );
//    }
//
//    crowd = level.crowds[ name ];
//
//    for( i = 0; i < crowd[ "count" ]; i++ )
//    {
//        start = random( crowd[ "start" ] );
//        end = random( crowd[ "end" ] );
//        spawner = random( crowd[ "spawner" ] );
//        spawner.target = end.targetname;
//        spawner.count = -1;
//
//        ai = spawner spawn_ai( true );
//
//        if( IsDefined( ai ) )
//        {
//            if( IsAI( ai ) )
//                ai ForceTeleport( start.origin, start.angles );
//            else
//                ai.origin = start.origin;
//        }
//
//        if( level.crowds[ "maxInterval" ] > level.crowds[ "minInterval" ] )
//            wait RandomFloatRange( level.crowds[ "minInterval" ], level.crowds[ "maxInterval" ] );
//        else
//            wait level.crowds[ "minInterval" ];
//    }
//
//    level notify ( name );
//}
