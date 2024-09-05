//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Actor locked combat init - earth				                **
//    Created: 2/18/11 - John Webb		                                    **
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include animscripts\combat_utility;
#include animscripts\utility;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
main()
{
	level._locked_combat = spawnstruct();
	level._locked_combat.nodes = [];
	level._locked_combat.coverTypes = [];

	// Grenades
	level._locked_grenade_check_interval = 5;
	level._locked_grenade_min_player_move_dist_sqr = 128 * 128;
	assert( isDefined( level._player ) );
	level._player thread locked_grenades_watch_player_movement();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
add_covertype( covertype, cover_init_func, cover_behavior_func, get_covermodes_func )
{
	cover_type_struct = spawnstruct();
	cover_type_struct.init_func = cover_init_func;
	cover_type_struct.behavior_func = cover_behavior_func;
	cover_type_struct.cover_mode_func = get_covermodes_func;
	level._locked_combat.coverTypes[ covertype ] = cover_type_struct;

	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "generic_human" );
init_locked_combat( start_node_targetname )
{
	//self.no_ai = true;
	self.locked_combat = true;
	self notify( "killanimscript" );	
	self.grenadeawareness = 0;
	self disable_surprise();
	self.current_node_key = start_node_targetname;

	assert( isdefined( level._locked_combat ) && isdefined( level._locked_combat.nodes ) && level._locked_combat.nodes.size > 0 );

	start_point = level._locked_combat.nodes[ start_node_targetname ];
	self ForceTeleport( start_point.origin, start_point.angles );
	self LinkTo( start_point );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_combat_transition( to_node_targetname )
{
	self endon( "death" );
	self notify( "locked_combat_transition" );

	from_node = level._locked_combat.nodes[ self.current_node_key ];
	to_node = level._locked_combat.nodes[ to_node_targetname ];

	waittillframeend;
	//to_node.animscripted_angles = VectorToAngles( from_node.origin - to_node.origin );

	self.animname = self.current_node_key;

	/#
	// Debug functionality allowing actors to slide to a target node without having an anim
	if ( level._locked_combat.nodes[ self.current_node_key ].slide_transitions[ to_node_targetname ] == 1 )
	{
		self thread debug_slide_transition( from_node, to_node );
		self.current_node_key = to_node_targetname;

		to_node waittill( "slide_finished" );
		self notify( "locked_combat_transition_finished" );
		self notify( "stop tracking" );
		self thread animscripts\locked_combat::locked_combat();
		return;
	}

	// Show debug lines
	if ( GetDvarInt( "scr_debugtransitions" ) )
	{
		// render box, node type and node forward
		//print3d( node.origin, node.type + " (" + transType + ")", nodeColor, 1, 0.35, frameInterval );
		transition_duration = GetAnimLength( level._scr_anim[ self.animname ][ to_node_targetname ] );
		transition_duration = int( transition_duration * 60 );

		box( from_node.origin, 16, from_node.angles[1], (0, 1, 0), 1, 1, transition_duration );
		nodeForward = anglesToForward( from_node.angles );
		nodeForward = vector_multiply( nodeForward, 8 );
		line( from_node.origin, from_node.origin + nodeForward, (0, 1, 0), 1, 1, transition_duration );

		box( to_node.origin, 16, from_node.angles[1], (1, 0, 0), 1, 1, transition_duration );
		nodeForward = anglesToForward( to_node.angles );
		nodeForward = vector_multiply( nodeForward, 8 );
		line( to_node.origin, to_node.origin + nodeForward, (1, 0, 0), 1, 1, transition_duration );

		line( from_node.origin, to_node.origin, (0, 0, 1), 1, 1, transition_duration );
	}

	#/

	// tagJW<NOTE>: Using anim_single_solo for this is not optimal.
	// Currently this is the only way to play an anim relative to a dynamic entity
	self.current_node_key = to_node_targetname;
	from_node thread anim_single_solo( self, to_node_targetname ); // trans_anim
	from_node waittill( to_node_targetname );
	wait 0.033;
	self notify( "locked_combat_transition_finished" );
	self notify( "stop tracking" );
	self thread animscripts\locked_combat::locked_combat();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
debug_slide_transition( from_node, to_node )
{
	self Unlink();
	self clearAnim( %body, .2 );	
	
	offset = ( 0, 0, 0 );
	self Teleport( from_node.origin, to_node.angles );
	self LinkTo( from_node );
	goal_offset = to_node.origin - from_node.origin;
	wait 0.05;

	SPEED = 140;

	frames = distance( goal_offset, offset ) / SPEED * 20;
	if ( frames <= 0 )
	{
		frames = 1;
	}

	per_frame_offset = goal_offset / frames;
	while ( frames > 0 )
	{
		offset += per_frame_offset;
		self Unlink();
		self Teleport( from_node.origin + offset );
		self LinkTo( from_node );
		frames -= 1;
		wait 0.05;
	}

	to_node notify( "slide_finished" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
node_add_transition( targetname, transition_targetname, transition_anim )
{
	node = level._locked_combat.nodes[ targetname ];
	node.transitions[ node.transitions.size ] = transition_targetname;
	level._scr_anim[ targetname ][ transition_targetname ] = transition_anim;

	/#
	node.slide_transitions[ transition_targetname ] = 0;
	#/
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
debug_node_add_slide_transition( targetname, transition_targetname )
{
	/#	
	node = level._locked_combat.nodes[ targetname ];
	node.transitions[ node.transitions.size ] = transition_targetname;
	node.slide_transitions[ transition_targetname ] = 1;
	#/	
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
node_setup( targetname )
{
 	node = GetEnt( targetname, "targetname" );
	
	AssertEx( isdefined( level._locked_combat.default_covertype ), "Default Covertypes not initialized before node_setup() was called." );
	node.type = level._locked_combat.default_covertype;
	if ( isdefined( node.script_covertype ) )
	{
		node.type = node.script_covertype;
	}
	
	level._locked_combat.nodes[ targetname ] = node;
	node.transitions = [];
	node.slide_transitions = [];
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
get_transitions()
{
	node = level._locked_combat.nodes[ self.current_node_key ];
	//assert( node.transitions.size > 0 );
	return node.transitions;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
get_transition_nodes()
{
	node = level._locked_combat_nodes[ self.current_node_key ];
	assert( node.transitions.size > 0 );
	transition_nodes = [];
	foreach ( targetname in node.transitions )
	{
		transition_nodes[ transition_nodes.size ] = level._locked_combat.nodes[ targetname ];
	}
	return transition_nodes;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
run_covertype_custom()
{
	behaviorCallbacks = spawnstruct();
	behaviorCallbacks.moveToNearByCover		 = animscripts\locked_combat::locked_moveToNearbyCover;
	behaviorCallbacks.reload				 = animscripts\locked_combat::locked_reload;
	behaviorCallbacks.leaveCoverAndShoot	 = animscripts\locked_combat::locked_popUpAndShoot;
	behaviorCallbacks.look					 = animscripts\locked_combat::locked_look;
	behaviorCallbacks.fastlook				 = animscripts\locked_combat::locked_fastlook;
	behaviorCallbacks.idle					 = animscripts\locked_combat::locked_idle;
	behaviorCallbacks.flinch				 = animscripts\locked_combat::locked_flinch;
	behaviorCallbacks.grenade				 = animscripts\locked_combat::locked_grenade;
	behaviorCallbacks.grenadehidden			 = animscripts\locked_combat::return_false;
	behaviorCallbacks.blindfire				 = animscripts\locked_combat::locked_blindfire;
	
	self animscripts\cover_behavior::main( behaviorCallbacks );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Enemies in locked combat will only throw a grenade at the player if the player fails to move a certain distance over a period of time
// To calculate this we need to look at the relative position of the player on their moving platform (if they are on one)
locked_grenades_watch_player_movement()
{
	self endon( "death" );
	self.locked_relPosLastCheck = self.origin;
	self.locked_previousPlatform = self GetEntBelowPlayer();

	while (1)
	{
		platform = self GetEntBelowPlayer();

		if ( !isdefined( platform ) && !isdefined( self.locked_previousPlatform ) )
		{
			// If we are not on a platform, check distance normally
			self.locked_shouldGrenade = level._locked_grenade_min_player_move_dist_sqr > DistanceSquared( self.locked_relPosLastCheck, self locked_player_get_rel_pos( platform ) );			
		}
		else if ( !isdefined( platform ) || !isdefined( self.locked_previousPlatform ) || platform != self.locked_previousPlatform )
		{
			// New platform, do not grenade this time
			self.locked_shouldGrenade = false;
		}
		else
		{
			// Same platform, check distance normally
			self.locked_shouldGrenade = level._locked_grenade_min_player_move_dist_sqr > DistanceSquared( self.locked_relPosLastCheck, self locked_player_get_rel_pos( platform ) );			
		}

		self.locked_previousPlatform = platform;
		self.locked_relPosLastCheck = self locked_player_get_rel_pos( platform );
		wait level._locked_grenade_check_interval;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_player_get_rel_pos( platform )
{
	if ( isdefined( platform ) )
	{
		//rel_struct = 
		// tagTC<temp> - placeholder checkin before John can make a fix
		return platform WorldToLocalCoords( self.origin );
	}

	return self.origin;
}
