//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  _OBJECTIVE UTIL												**
//                                                                          **
//    Created: 1/27/2010 - Travis Chen										**
//                                                                          **
//****************************************************************************

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// README: wait_for_objective
// maps\nx_lunar_util::wait_for_objective( objective_num, objective_text, curr_trigger, next_trigger );
// curr_trigger - the start point trigger of the objective
// next_trigger - the end point trigger of the objective
// additional_current - makes the objective the additional current 

// KenM Notes:
// The trigger type used for the start and end points should be trigger_multiple.
// To create a path of waypoints, simply link each waypoint script_origin to the next in Radiant.
// Give each one a radius KVP to indicate how close the player must be to trigger the waypoint.

wait_for_objective( objective, objective_text, curr_trigger, next_trigger, additional_current )
{
	// Process objective for string
	objective = objective_add_to_level_var( objective );

	// Get target waypoint, add objective
	waypoint = get_objective_waypoint( curr_trigger );
	Objective_Add( objective, "current", objective_text, waypoint.origin );
	
	// Make objective additional current
	if( IsDefined( additional_current ) && additional_current )
	{
		Objective_AdditionalCurrent( objective );
	}

	// Check if we have a path of waypoints
	if( IsDefined( waypoint.target ) )
	{
		objective_waypoint_path( objective, waypoint );
	}

	// Wait for trigger
	wait_for_objective_trigger( next_trigger );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

wait_for_objective_additional( objective, objective_text, curr_trigger, next_trigger )
{
	// Check objective reference against level._objective
	objective = objective_string_convert( objective );

	wait_for_objective( objective, objective_text, curr_trigger, next_trigger, true );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

get_objective_waypoint( trigger_name )
{
	trigger = GetEnt( trigger_name, "targetname" );	
	if( !IsDefined( trigger ) )
	{
		AssertMsg( "Objective start trigger " + trigger_name + " doesn't exist" );
	}

	if( IsDefined( trigger.target ) )
	{
		// Return the waypoint
		waypoint = getEnt( trigger.target, "targetname" );
		if( !IsDefined( waypoint ) )
		{
			AssertMsg( "Objective trigger " + trigger_name + " target doesn't exist" );
		}
		return waypoint;	
	}
	else
	{
		AssertMsg( "Objective trigger " + trigger_name + " doesn't have target" );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

objective_waypoint_path( objective, waypoint )
{
	// Check objective reference against level._objective
	objective = objective_string_convert( objective );

	// Loop through waypoints and wait for player proximity 
	while( 1 )
	{
		// End of waypoint chain
		if( !IsDefined( waypoint.target ) )
		{
			break;
		}

		// Wait for player in waypoint radius proximity
		wait_for_player_near_waypoint( waypoint );
		
		// Get next waypoint and update objective position
		waypoint = getEnt( waypoint.target, "targetname" );
		objective_position( objective, waypoint.origin );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

wait_for_player_near_waypoint( waypoint )
{
	// Wait for player in waypoint radius proximity
	while( 1 )
	{
		player_near_waypoint = distance( level._player.origin, waypoint.origin ) < waypoint.radius;
		if( player_near_waypoint )
		{
			break;
		}
		wait( 0.05 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

wait_for_objective_trigger( trigger_name )
{
	trigger = GetEnt( trigger_name, "targetname" );

	if( !IsDefined( trigger ) )
	{
		AssertMsg( "Objective end trigger " + trigger_name + " doesn't exist" );
	}

	trigger waittill( "trigger" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Loads all objectives into level._objective
objective_add_to_level_var( objective )
{
	// Check to see if objective is string or int and add to a global objective array (level._objective[ NAME OR NUMBER ] = NUMBER)
	if( IsString( objective ))
	{
		obj_number = undefined;

		if( isdefined( level._objective ))
		{
			obj_number = level._objective.size;

			// Look for duplicate entry
			if( isdefined( level._objective[ objective ] ))
			{
				AssertMsg( "Objective '" + objective + "' already exists!" );
			}
		}
		else
		{
			obj_number = 1;
		}

		level._objective[ objective ] = obj_number;
		objective = obj_number;
	}
	else
	{		
		// Look for duplicate entry
		if( isdefined( level._objective ))
		{
			if( isdefined( level._objective[ objective ] ))
			{
				AssertMsg( "Objective '" + objective + "' already exists!" );
			}
		}

		level._objective[ objective ] = objective;
	}

	return objective;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Checks to see if user is referencing string or number in level._objective, returns number
objective_string_convert( objective )
{
	if( !isdefined( level._objective ))
	{
		AssertMsg( "Objective '" + objective + "' does not exist!" );
	}

	if( !isdefined( level._objective[ objective ] ))
	{
		AssertMsg( "Objective '" + objective + "' does not exist!" );
	}

	if( IsString( objective ))
	{
		objective = level._objective[ objective ];
	}

	return objective;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Adds an objective to level._objective and to game
objective_add_string( string, state, text )
{
	Objective_Add( objective_add_to_level_var( string ), state, text ); 
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

