#include common_scripts\utility;
#include maps\_utility;
#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );

MIN_DELAY = 0.0;
MAX_DELAY = 2.0;

main( model, type )
{
	build_template( "nx_miniuav", model, type );
	build_localinit( ::init_local );

 	build_life( 100 );

	// Use this to have a death model swap
	//build_deathmodel( "nx_vehicle_miniuav", "nx_vehicle_miniuav" );

	// tagBR<note> Set up the death fx/sounds
	miniuav_death_fx[ "nx_vehicle_miniuav" ] = "nx/explosions/nx_miniuav_hit";
	build_deathfx( miniuav_death_fx[ model ], undefined, "nx_miniuav_explode", undefined, undefined, undefined, 1.0 );

	// This must be called for all SAV's after all build_deathfx calls
	build_SAV_death_delay(MIN_DELAY, MAX_DELAY);

	level._SAV_circling_func = maps\_attack_heli::SAV_switch_to_circling;

	//build_radiusdamage( ( 0, 0, 32 ), 500, 80, 20, false );
	build_radiusdamage( ( 0, 0, 32 ), 120, 20, 5, false );

	build_drive( %Nx_Miniuav_Idle, undefined, 0 );

	// This is required for setting up the "dust kickup" fx
	build_treadfx( "nx_miniuav" );

	build_team( "axis" );
	build_mainturret();

	//turret = "minigun_littlebird_spinnup";
	//build_turret( turret, "TAG_BARREL", "vehicle_little_bird_minigun_left" );

	build_vehicle_parent_attach_spawn( ::vehicle_parent_attach_unload );

	PreCacheItem( "nx_miniuav_rifle" );
	precacheitem( "smoke_grenade_miniuav" );

	maps\_attack_heli::preLoad();

	miniuav_init_fx();

	miniuav_find_linear_dmg_func();

}


//*******************************************************************
//																	*
//																	*
//*******************************************************************
miniuav_init_fx()
{
	level._effect[ "miniuav_flashlight" ]	 = LoadFX( "misc/flashlight" );
	level._effect[ "miniuav_muzzleflash" ]	= LoadFX( "muzzleflashes/m16_flash_wv" );
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************
vehicle_parent_attach_unload()
{
	wait( 1.0 );
	self maps\_attack_heli::SAV_setup( "pathing" );
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
init_local()
{
	self.script_badplace = false; // All helicopters dont need to create bad places

	level._SAV_setup_script = maps\_attack_heli::SAV_setup;

	self._SAV_searching_script = ::searching_miniuav_think;
	self._SAV_damage_script = ::miniuav_damage_script;
	self._SAV_turret_type = "nx_miniuav_rifle";

	// Set up accuracy.
	self set_baseaccuracy( .50 );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
miniuav_find_linear_dmg_func()
{
	// Using liner regression to find a function that will provide output values
	// for use in determining hit anim start time based on damage
	// Ref: http://www.zweigmedia.com/RealWorld/calctopic1/regression.html
	// x is dmg, y is anim start times
	max_x = 200.0;
	min_x = 0.0;
	max_y = 0.0;
	min_y = 0.4;

	sum_x = ( max_x + min_x );
	sum_y = ( max_y + min_y );
	sum_xy = ( max_x * max_y ) + ( min_x * min_y );
	sum_x2 = ( max_x * max_x ) + ( min_x * min_x );

	m = ( ( 2 * sum_xy ) - ( sum_x * sum_y ) ) / ( ( 2 * sum_x2 ) - ( sum_x * sum_x ) );

	b = ( sum_y - ( m * sum_x ) ) / 2;

	// f(x) = mx + b;

	// Save them off
	level._miniuav_dmg_func_slope = m;
	level._miniuav_dmg_func_intersect = b;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
miniuav_get_hit_anim_start_time( damage )
{
	// f(x) = mx + b;
	return ( ( level._miniuav_dmg_func_slope * damage ) + level._miniuav_dmg_func_intersect );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
miniuav_damage_script()
{
	self endon( "death" );

	while ( 1 )
	{
		// Wait till uav is damaged
		self waittill( "damage", amount, attacker, direction_vec, point );
	
		self notify( "new_hit_react" );

		// Set the anim
		self SetFlaggedAnim( "hitreact", %nx_miniuav_hitreact, 1, 0.1, 1 );

		// Find the start time based on our dmg_func
		start_time = miniuav_get_hit_anim_start_time( amount );

		// Add in a small offset (so the anim doesn't always look the same)
		start_time += RandomFloatRange( -0.1, 0.1 );

		// Clamping
		if ( start_time < 0 )
		{
			start_time = 0;
		}

		// For now, just getting a random time to end
		end_time = RandomFloatRange( 0.66, 0.98 ); // <-- 0.98 because it will never get to 1.0 apparently...

		self SetAnimTime( %nx_miniuav_hitreact, start_time );

		// Wait until the anim is finished
		self thread miniuav_hitreact_anim_clear( end_time );
		self waittill( "anim_cleared" );

		waittillframeend;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
miniuav_hitreact_anim_clear( limit )
{
	self endon( "death" );
	self endon( "new_hit_react" );
	
	//self waittillmatch( "hitreact", "end" );

	while ( 1 )
	{
		// Kill the anim as soon as we've reached our limit
		curr_time = self GetAnimTime( %nx_miniuav_hitreact );
		if ( curr_time >= limit )
		{
			self ClearAnim( %nx_miniuav_hitreact, 0.1 );

			self notify( "anim_cleared" );
			break;
		}

		wait( 0.05 );
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
searching_miniuav_think()
{
	self endon( "death" );

	// If stealthgroups are in use, watch for spotted events
	if ( isdefined( self.script_stealthgroup ) )
	{
		self thread miniuav_handle_stealthgroup();
	}

	// Look for enemies and listen for gunshot events
	self.circling = false;

	self thread miniuav_listen_for_events();
	self thread miniuav_looking_for_player( level._player );
	
	//self SetJitterParams( ( 0, 0, 0 ), 0, 0 );
	self SetHoverParams( 0, 0, 0.0 );
	self SetYawSpeed( 120, 60, 60, 0 );	

	while( 1 )
	{
		switch( self.state )
		{
			case "move":
				self miniuav_move_state();
				break;
	
			case "search":
				self miniuav_search_state();
				break;
	
			case "engage":
				self miniuav_engage_state();
				break;

			case "notify":
				self miniuav_notify_state();
				break;
	
			default:
				Assert( "miniuav does not have an appropriate state defined." );
				break;
		}

		wait 0.1;
	}	
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
miniuav_handle_stealthgroup()
{
	self endon( "death" );
	self endon( "player_spotted" );

	thread [[ level._global_callbacks[ "_patrol_endon_spotted_flag" ] ]]();

	self waittill( "end_patrol" );
	thread miniuav_player_spotted();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
miniuav_move_state()
{
	self endon( "death" );
	self endon( "investigate" );
	self endon( "player_spotted" );


	goal = undefined;
	goal_yaw = undefined;

	// Possibly follow a path, ignoring other nodes
	if ( isdefined( self.current_node ) && isdefined( self.current_node.target ) )
	{
		goal = GetEnt( self.current_node.target, "targetname" );
		assert( isdefined( goal ) );
		goal_yaw = goal.angles[1];
		goal.used = 1;
		goal.use_position = [];
	}
	else
	{
		valid_nodes = [];
	
		// If there are no valid nodes in sight
		while ( !valid_nodes.size )
		{
			wait 0.3;
			// Eventually do something else?
			valid_nodes = maps\_attack_heli::SAV_get_valid_nodes( self.sight_nodes );		
			
		}
	
		/#
		if ( GetDvar( "scr_debug_miniuav_search" ) == "1" )
		{
			foreach ( node in valid_nodes )
			{
				Line( self.origin, node.origin, ( 1, 0, 0 ), 1, 0, 120 );
			}
		}	
		#/
		
		if ( isdefined( self.SAV_search_pos ) )
		{
			// If we are told to search a specific position, find the closest sight node, and look at it
			goal = valid_nodes[0];
			best_dist = distance( self.SAV_search_pos, valid_nodes[ 0 ].origin );
			node_index = 1;
			while ( node_index < valid_nodes.size )
			{
				new_dist = distance( self.SAV_search_pos, valid_nodes[ node_index ].origin );
				if ( new_dist < best_dist )
				{
					goal = valid_nodes[ node_index ];
					best_dist = new_dist;
				}
				node_index+=1;
			}
	
			assert( isdefined( goal ) );
	
			goal_yaw = VectorToYaw( self.SAV_search_pos - goal.origin );
			self.SAV_using_search_pos = true;
			self.SAV_search_pos = undefined;
		}
		else
		{
			// Set the goal to a random node within sight
			goal = valid_nodes[ RandomInt( valid_nodes.size ) ];
			self.SAV_using_search_pos = false;
			goal_yaw = goal.angles[1];
		}
	}

	
	/#
	if ( !isdefined( goal.angles ) )
	{
		AssertMsg( "Miniuav search node missing 'angles' KVP" );
	}
	#/
	
	maps\_attack_heli::SAV_use_node( goal );

	goal_pos = maps\_attack_heli::SAV_get_offset_node_pos( goal );

	self SetTargetYaw( goal_yaw );
	self SetVehGoalPos( goal_pos, 1 );

	// Set the heli's nodes to the nodes within sight of the goal
	if ( isdefined( goal.sight_nodes ) )
	{
		self.sight_nodes = goal.sight_nodes;
	}
	
	self waittill( "goal" );

	// Set new uav params based on the node, if it has any
	if ( isdefined( goal.script_yawspeed ) )
	{
		self SetYawSpeed( goal.script_yawspeed, 60 );
	}
	else
	{
		self SetYawSpeed( 120, 60, 60, 0 );
	}

	self ClearTargetYaw();

	wait 1;

	// Transition to search state if we are at the end of a path
	if ( !isdefined( self.current_node.target ) || ( isdefined( self.current_node.script_noteworthy ) && self.current_node.script_noteworthy == "search_node" ) )
	{
		self.state = "search";	
	}
	
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
miniuav_turn( offset_angle )
{
	yaw = self.angles[ 1 ] + offset_angle;
	self SetTargetYaw( yaw );

	EPSILON = 1.0;
	while( AngleClamp( self.angles[ 1 ] - yaw ) > EPSILON )
	{
		wait 0.1;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
miniuav_search_state()
{
	self endon( "death" );
	self endon( "investigate" );

	// Stop searching when player spotted
	self endon( "player_spotted" );

	EPSILON = 5.0; // Relatively high epsilon to account for animation affecting the turn

	// Set speeds

	// Do searching ---
	turn_angle = 135;
	if ( isdefined( self.current_node.script_goalyaw ) )
	{
		turn_angle = self.current_node.script_goalyaw;
	}

	self miniuav_turn( turn_angle );
	self miniuav_turn( turn_angle*-1 );
	self miniuav_turn( turn_angle*-1 );

	// Stop searching, and transition back to move state
	self notify( "stop_searching" );
	self.state = "move";
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
miniuav_looking_for_player( player )
{
	self endon( "death" );

	while( 1 )
	{
		if ( !self.circling )
		{
			tag_flash_loc = self GetTagOrigin( "tag_flash" );
			
			// If player is within heli's FOV
			if( within_fov( tag_flash_loc, self.angles, player GetEye(), level._cosine[ "45" ] ) )
			{
				// And, the heli can see the player
				if( SightTracePassed( tag_flash_loc, player GetEye(), false, self ) )
				{
					// And, distance check
					if( distance( self.origin, player.origin ) < self.sight_distance )
					{
						miniuav_player_spotted();
					}
				}
			}
		}

		wait 0.1;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
miniuav_player_spotted()
{
	self.eTarget = level._player;
	self notify( "player_spotted" );
	//IPrintLnBold( "PLAYER SPOTTED!!!" );
	self notify( "enemy" );

	if( self.behavior_type == "searching" )
	{
		self.state = "engage";
	}
	else // "notifying"
	{
		self.state = "notify";
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
miniuav_listen_for_events()
{
	self endon( "death" );
	self endon( "player_spotted" );
	
	self.investigate_goal = undefined;
	self addAIEventListener( "bulletwhizby" );
	self addAIEventListener( "gunshot" );

	while ( 1 )
	{
		self waittill( "ai_event", event, originator, position );
		if ( ( event == "bulletwhizby" ) || ( event == "gunshot" ) )
		{

				if ( !self.circling && !self.SAV_using_search_pos )
				{
					self.SAV_search_pos = position;
					self.state = "move";
					//IPrintLnBold( "BULLET DETECTED" );
					self notify( "investigate" );
				}
	
		}
	}
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************
miniuav_engage_state()
{
	self endon( "death" );

	self.eTarget = level._player;

	self thread miniuav_check_for_stop_engage( level._player );

	// Go to circling/attack behavior
	self SetYawSpeed( 120, 60, 60, 0 );	// If our yaw speed has changed, reset it back to combat levels
	self maps\_attack_heli::start_circling_heli_logic( self.circle_nodes, maps\_attack_heli::SAV_shoot_think, maps\_attack_heli::SAV_circle_node_choice, maps\_attack_heli::SAV_get_offset_node_pos );

	// The circling won't proceed until you are near your goal...well, we are already at our goal
	self notify( "near_goal" );

	self waittill( "stop_engaging" );

	// Stop circling behavior, transition to move state
	self notify( "stop_circling" );
	self notify( "stop_shooting" );
	self.circling = false;
	self ClearLookAtEnt();

	self.state = "move";

	// Also need to re-process the sight nodes now
	self maps\_attack_heli::process_heli_sight_nodes( self.search_nodes );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
miniuav_check_for_stop_engage( player )
{
	self endon( "death" );

	// Just doing a distance check, if player leaves the "bubble", stop engaging
	// tagBR< note >: May want other conditions here?
	while( 1 )
	{
		if ( isdefined( self.can_lose_player ) && self.can_lose_player )
		{
			if( distance( self.origin, player.origin ) > ( self.sight_distance * 2.0 ) )
			{
				self notify( "stop_engaging" );
				IPrintLnBold( "TARGET LOST" );
				return;
			}
		}
		wait 0.1;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
miniuav_notify_state()
{
	self endon( "death" );

	// miniuav will return to this location once the notify logic is complete
	return_origin = Spawn( "script_origin", self.origin );

	self notify( "notify_begin" );

	// --- Wait for notify logic ---

	self waittill( "notify_complete" );

	// Once we've notified once, we revert to searching logic in the engage state
	self.behavior_type = "searching";
	self.state = "engage";

	// Return to the position
	self SetLookAtEnt( return_origin );
	self SetVehGoalPos( return_origin.origin, 1 );
	self waittill( "goal" );

	// Don't need this anymore
	return_origin delete();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

/*QUAKED script_vehicle_nx_miniuav (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_miniuav::main( "nx_vehicle_miniuav", "nx_miniuav" );


include,nx_vehicle_miniuav
include,_attack_heli

defaultmdl="nx_vehicle_miniuav"
default:"vehicletype" "nx_miniuav"
default:"script_team" "axis"
*/

