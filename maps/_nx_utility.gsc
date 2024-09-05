//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Nx Utility Scripts											**
//                                                                          **
//    Created: 3/10/2011 - John Webb										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_hud_util;

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: move_player_to_start_point( sTargetname )"
"Summary: Move player to start points"
"Module: Utility"
"CallOn: a player "
"MandatoryArg: <sTargetname>: targetname of entity to teleport the player to"
"Example: move_player_to_start_point( "intersection_start" );
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

// Player start code (orients player based on 
move_player_to_start_point( sTargetname )
{
	assert( isdefined( sTargetname ) );
	start = getent( sTargetname, "targetname" );
	self SetOrigin( start.origin );
	
	lookat = undefined;
	if ( isdefined( start.target ) )
	{
		lookat = getent( start.target, "targetname" );
		assert( isdefined( lookat ) );
	}
	
	if ( isdefined( lookat ) )
	{
		self setPlayerAngles( vectorToAngles( lookat.origin - start.origin ) );
	}
	else
	{
		self setPlayerAngles( start.angles );
	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: delete_ai_in_volume_not_bullet_shielded( targetname, team )"
"Summary: Deletes all non bullet shielded actors of the specified team in the volumes with the KVP targetname <targetname>"
"Module: Utility"
"CallOn: "
"MandatoryArg: <targetname>: Targetname of volume(s) to delete AI from"
"OptionalArg: <team>: 'axis' or 'allies'. Left blank the function will try to delete all ai"
"Example: delete_ai_in_volume_not_bullet_shielded( "intersection", "axis" );
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

delete_ai_in_volume_not_bullet_shielded( targetname, team )	
{	 	
	if ( !isdefined( team ) )
	{
		team = "all";
	}

	areas = getentarray( targetname, "targetname" );
	assert( areas.size > 0 );
	
	foreach( area in areas )
	{
		array_thread( area get_ai_touching_volume( team ), ::delete_ai_not_bullet_shielded );
	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************


/*
=============
///ScriptDocBegin
"Name: delete_ai_not_bullet_shielded()"
"Summary: Deletes Ai if not bullet shielded"
"Module: Utility"
"CallOn: An actor"
"Example: actor delete_ai_not_bullet_shielded();
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
delete_ai_not_bullet_shielded()
{
	if ( isdefined( self.magic_bullet_shield ) )
		   return;
	self delete();
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: spawn_targetname_and_return_array( targetname )"
"Summary: Attempts to spawn ai from each spawner with the KVP targetname <targetname>, and returns an array of those spawned"
"Module: Utility"
"CallOn: "
"MandatoryArg: <targetname>: Targetname of spawners to spawn from"
"OptionalArg: <spawn_limit>: Total number of Ai to be spawned from the list of spawners."
"Example: spawn_targetname_and_return_array( "street_spawners" );
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

spawn_targetname_and_return_array( targetname, spawn_limit )
{
	spawners = GetEntArray( targetname, "targetname" );
	guys = [];

	if( IsDefined( spawn_limit ) && spawn_limit < spawners.size )
	{
		spawn_count = spawn_limit;
	}
	else
	{
		spawn_count = spawners.size;
	}

	for( i = 0; i < spawn_count; i++ )
	{
		spawners[i].count = 1;
		guy = spawners[i] spawn_ai();
		if ( IsDefined( guy ) && IsAlive( guy ) )
		{
			guys[ guys.size ] = guy;
		}
	}
	return guys;
}

/*
=============
///ScriptDocBegin
"Name: set_springy_cam_pitch_offset( angle, reset_time )"
"Summary: Sets springy cam pitch offset angle from center (0 degrees)"
"Module: Utility"
"CallOn: "
"MandatoryArg: <angle>"
"OptionalArg: <reset_time>"
"Example: thread set_springy_cam_pitch_offset( 20, 3.0 );
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
set_springy_cam_pitch_offset( angle, reset_time )
{
	if ( level._player IsSpringyCamEnabled() )
	{
		level._player SetSpringyCamPitchOffset( angle );
	
		if ( IsDefined( reset_time ) )
		{
			wait reset_time;

			if ( level._player IsSpringyCamEnabled() )
			{
				level._player SetSpringyCamPitchOffset( 0 );
			}
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: boundry_trigger_planes_init()"
"Summary: Small system to handle players going into area's they aren't supposed to. Like old school minefields"
"Module: Utility"
"CallOn: "
"Example: boundry_trigger_planes_init();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

boundry_trigger_planes_init()
{
	// setup our flags
	flag_init( "player_out_of_bounds" );


	// setup our handlers for players out of bounds
	patrol = GetEntArray( "border_patrol", "targetname" );
	foreach( vehicle in patrol )
	{
		vehicle thread vehicle_handle_player_out_of_bounds();
	}
	// tagMJS<NOTE> other potential out bounds handlers can go here, say a mine field for example


	// setup our triggers to handle a player out of bounds
	array_thread( GetEntArray( "boundary_trigger", "targetname" ), ::out_of_bounds_update );;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: vehicle_handle_player_out_of_bounds()"
"Summary: vehicle handler for player being out of bounds. Currently written for UGVs."
"Module: Utility"
"CallOn: "
"Example: vehicle thread vehicle_handle_player_out_of_bounds();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

vehicle_handle_player_out_of_bounds()
{
	self endon( "death" );


	// we need to make sure our vehicles aren't shooting at all first
	if ( IsDefined( self.mgturret ) )
	{
		foreach( turret in self.mgturret )
		{
			turret SetMode( "manual" );
		}
	}


	while ( 1 )
	{
		if ( flag( "player_out_of_bounds" ) )
		{
			if ( IsDefined( self.mgturret ) && 0 < self.mgturret.size )
			{
				self.mgturret[0] SetMode( "auto_nonai" );
			}
		}
		else
		{
			if ( IsDefined( self.mgturret ) && 0 < self.mgturret.size )
			{
				self.mgturret[0] SetMode( "manual" );
			}
		}
		wait 1;
	}
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: out_of_bounds_update()"
"Summary: loop called on our trigger plane to update our out of bounds flag that handlers are checking."
"Module: Utility"
"CallOn: "
"Example: out_of_bounds_update();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

out_of_bounds_update()
{
	while ( 1 )
	{
		if ( level._player IsTouching( self ) )
		{
			flag_set( "player_out_of_bounds" );
		}
		else
		{
			flag_clear( "player_out_of_bounds" );
		}
		wait 1;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: scriptmodel_last_frame( targetname )"
"Summary: Locks scriptmodels to their animation's last frame"
"Module: Utility"
"CallOn: "
"MandatoryArg: <targetname>: Targetname of script_models.  Script_models must have script_animation and a model defined"
"Example: scriptmodel_last_frame( "dead_crew" );
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

#using_animtree( "generic_human" );
scriptmodel_last_frame( targetname )
{
	scriptmodels = GetEntArray( targetname, "targetname" );
	assert( scriptmodels.size > 0 );	

	foreach ( scriptmodel in scriptmodels )
	{		
		scriptmodel UseAnimTree( #animtree );
		scriptmodel thread maps\_anim::anim_generic( scriptmodel, scriptmodel.script_animation );
		scriptmodel SetAnimTime( getanim_generic( scriptmodel.script_animation ), 1 );		
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: vehicle_get_gunner()"
"Summary: Returns actor manning the first turret on the vehicle, if any"
"Module: Utility"
"CallOn: a vehicle"
"Example: vehicle vehicle_get_gunner();
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

vehicle_get_gunner()
	{
	// Find a turret, if any
	assert( isdefined( level._vehicle_aianims ) );	
	//turret_anim_pos = undefined;

	for ( pos = 0; pos < level._vehicle_aianims[ self.vehicletype ].size; pos++ )
		{
		if ( isdefined( level._vehicle_aianims[ self.vehicletype ].mgturret ) )
			{
			break;
		}
	}
			
	if ( ( pos == level._vehicle_aianims[ self.vehicletype ].size ) || !isdefined( self.riders ) || self.riders.size == 0 )
	{
		return;
			}

	foreach ( rider in self.riders )
	{
		if ( rider.vehicle_position == pos )
		{
			if ( isalive( rider ) )
			{
				return rider;
		}
	}
}

	return;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
=============
///ScriptDocBegin
"Name: set_battlechatter_id()"
"Summary: Sets the battlechatter id of the actor"
"Module: Utility"
"CallOn: AI"
"MandatoryArg: <bcs_id>: The string battlechatter id"
"Example: set_battlechatter_id( "eag" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

set_battlechatter_id( bcs_id )
{
	self.npcid = bcs_id;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
=============
///ScriptDocBegin
"Name: pos_dialogue()"
"Summary: Plays positional audio for dialogue and animates actor's mouth"
"Module: Utility"
"CallOn: AI"
"MandatoryArg: <scene>: The scene name (usually set in _anim.gsc)"
"MandatoryArg: <animname>: The animname to set to actor (usually set in _anim.gsc)"
"Example: set_battlechatter_id( "duke", "hithard_duke_snipe_comms" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

pos_dialogue( scene, animname )
{
	self.animname = animname;
	self dialogue_queue( scene );
}


/*
=============
///ScriptDocBegin
"Name: mantle_text_on()"
"Summary: Displays the mantle hint"
"Module: Utility"
"CallOn: nothing"
"MandatoryArg:"
"Example: mantle_text_on();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
mantle_text_on()
{
	level._hud_mantle[ "text" ].alpha = 1.0;
}


/*
=============
///ScriptDocBegin
"Name: mantle_text_off()"
"Summary: Turns off the mantle hint"
"Module: Utility"
"CallOn: nothing"
"MandatoryArg:"
"Example: mantle_text_off();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
mantle_text_off()
{
	level._hud_mantle[ "text" ].alpha = 0.0;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: waittill_all"
"Summary: waits for multiple notifies on a single entity before continuing"
"Module: Utility"
"CallOn: nothing"
"MandatoryArg:"
"Example: waittill_all( array_of_messages );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

waittill_all( array_of_messages )
{
	flags = [];

	Assert( IsDefined( array_of_messages ));
	Assert( IsArray( array_of_messages ));

	foreach( msg in array_of_messages )
	{
		flagname = "_waittill_flag_" + msg;
		flag_init( flagname );
		flags = add_to_array( flags, flagname );
		self thread waittill_all_solo( msg, flagname );
	}

	foreach( flag in flags )
	{ 
		flag_wait( flag );
	}
}

waittill_all_solo( msg, flag )
{
	Assert( IsDefined( msg ));
	Assert( IsDefined( flag ));

	self waittill( msg );
	flag_set( flag );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: wait_random"
"Summary: Wait a random amount of time"
"Module: Utility"
"CallOn: nothing"
"MandatoryArg: time_low - Lowest possible time (in seconds)"
"MandatoryArg: time_high - Highest possible time (in seconds)"
"Example: wait_random( time_low, time_high );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

wait_random( time_low, time_high )
{
	Assert( IsDefined( time_low ));
	Assert( IsDefined( time_high ));

	wait RandomFloatRange( time_low, time_high );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: assert_isdefined"
"Summary: Assert that something is defined"
"Module: Utility"
"CallOn: nothing"
"MandatoryArg:"
"Example: assert_isdefined( ent );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

assert_isdefined( ent )
{
	Assert( IsDefined( ent ));	
}

/*
=============
///ScriptDocBegin
"Name: enable_trigger_with_targetname( <name> )"
"Summary: calls trigger_on() on a trigger with targetname of <name>"
"Module: Trigger"
"MandatoryArg: <name>: string get the entity that has a targetname of <name>"
"Example: enable_trigger_with_targetname( "red_team1" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
enable_trigger_with_targetname( msg )
{
	trigger = GetEnt( msg, "targetname" );
	trigger trigger_on();
}

/*
=============
///ScriptDocBegin
"Name: enable_trigger_with_noteworthy( <name> )"
"Summary: calls trigger_on() on a trigger with script_noteworthy of <name>"
"Module: Trigger"
"MandatoryArg: <name>: string get the entity that has a script_noteworthy of <name>"
"Example: enable_trigger_with_noteworthy( "red_team1" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
enable_trigger_with_noteworthy( msg )
{
	trigger = GetEnt( msg, "script_noteworthy" );
	trigger trigger_on();
}
/*
=============
///ScriptDocBegin
"Name: SetGoalVolumeAuto_targetname( <name> )"
"Summary: calls trigger_on() on a trigger with script_noteworthy of <name>"
"Module: AI"
"CallOn: AI"
"MandatoryArg: <name>: volume with targetname of <name>"
"Example: SetGoalVolumeAuto_targetname( "red_team1" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
SetGoalVolumeAuto_targetname( targetname )
{
	Assert( IsDefined( targetname ));

	vol = GetEnt( targetname, "targetname" );
	Assert( IsDefined( vol ));
	
	self SetGoalVolumeAuto( vol );
	self._goal_volume = vol;
}

/*
=============
///ScriptDocBegin
"Name: IsAlive_array( <guys> )"
"Summary: Runs IsAlive() on an array and returns true if someone is living"
"Module: Utility"
"CallOn: nothing"
"MandatoryArg: <guys>: array of enemy AI"
"Example: IsAlive_Array( enemies );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

IsAlive_array( entities )
{
	Assert( IsDefined( entities ));
	Assert( IsArray( entities ));

	something_lives = 0;

	foreach( thing in entities )
	{
		if( isalive( thing ))
		{
			something_lives++;
		}
	}

	return something_lives;
}


