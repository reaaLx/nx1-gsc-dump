#include animscripts\SetPoseMovement;
#include animscripts\combat_utility;
#include animscripts\utility;
#include common_scripts\utility;
#include maps\_utility;

#using_animtree( "generic_human" );

// constants for exposed approaches
maxSpeed = 250;// units / sec
allowedError = 8;


main()
{
	self endon( "killanimscript" );
	self endon( "abort_approach" );

	approachnumber = self.approachNumber;

	assert( isdefined( self.approachtype ) );

	arrivalAnim = anim.coverTrans[ self.approachtype ][ approachnumber ];
	if ( use_custom_coverset( self.approachtype ) )
	{
		arrivalAnim = self.customCoverEnterTrans[ self.approachtype ][ approachnumber ];
	}
	
	assert( isdefined( arrivalAnim ) );
	
	if ( !isdefined( self.heat ) )
		self thread abortApproachIfThreatened();
	
	// tagJW<NOTE>: Use the blend_finish tag to determine blend time on the arrival animation
	blend_time = 0.2;
	if( self IsCQBWalking() )
	{
		blend_finish_time = GetNotetrackTimes( arrivalAnim, "cqb_blend_finish" );
	}
	else
	{
		blend_finish_time = GetNotetrackTimes( arrivalAnim, "blend_finish" );
	}
	
	if ( blend_finish_time.size > 0 )
	{
		blend_time = blend_finish_time[0] * GetAnimLength( arrivalAnim );
	}

	self clearanim( %body, blend_time );
	self setFlaggedAnimRestart( "coverArrival", arrivalAnim, 1, blend_time, self.moveTransitionRate );
	self animscripts\shared::DoNoteTracks( "coverArrival", ::handleStartAim );

	newstance = anim.arrivalEndStance[ self.approachType ];
	assertex( isdefined( newstance ), "bad node approach type: " + self.approachtype );

	if ( isdefined( newstance ) )
		self.a.pose = newstance;
		
	self.a.movement = "stop";

	self.a.arrivalType = self.approachType;

	// we rely on cover to start doing something else with animations very soon.
	// in the meantime, we don't want any of our parent nodes lying around with positive weights.
	self clearanim( %root, .3 );
	
	self.lastApproachAbortTime = undefined;
}

handleStartAim( note )
{
	if ( note == "start_aim" )
	{
		if ( self.a.pose == "stand" )
		{
			self animscripts\init_common::set_animarray_standing();
		}
		else if ( self.a.pose == "crouch" )
		{
			self animscripts\init_common::set_animarray_crouching();
		}
		else
		{
			assertMsg( "Unsupported self.a.pose: " + self.a.pose );
		}
	
		self animscripts\combat::set_aim_and_turn_limits();

		self.previousPitchDelta = 0.0;
		
		setupAim( 0 );
		
		self thread animscripts\shared::trackShootEntOrPos();
	}
}


isThreatenedByEnemy()
{
	if ( !isdefined( self.node ) )
		return false;
		
	if ( isdefined( self.enemy ) && self seeRecently( self.enemy, 1.5 ) && distanceSquared( self.origin, self.enemy.origin ) < 250000 )
		return !( self isCoverValidAgainstEnemy() );
		
	return false;
}


abortApproachIfThreatened()
{
	self endon( "killanimscript" );
	
	while ( 1 )
	{
		if ( !isdefined( self.node ) )
			return;

		if ( isThreatenedByEnemy() )
		{
			self clearanim( %root, .3 );
			self notify( "abort_approach" );
			self.lastApproachAbortTime = getTime();
			return;
		}
		
		wait 0.1;
	}
}

getNodeStanceYawOffset( approachtype )
{
	// returns the base stance's yaw offset when hiding at a node, based off the approach type
	if ( isdefined( self.heat ) )
		return 0;

	if ( approachtype == "left" || approachtype == "left_crouch" || approachtype == "left_cqb" || approachtype == "left_crouch_cqb" )
		return 90.0;
	else if ( approachtype == "right" || approachtype == "right_crouch" || approachtype == "right_cqb" || approachtype == "right_crouch_cqb" )
		return - 90.0;

	return 0;
}


canUseSawApproach( node )
{
	if ( !usingMG() )
		return false;

	if ( !isDefined( node.turretInfo ) )
		return false;

	if ( node.type != "Cover Stand" && node.type != "Cover Prone" && node.type!= "Cover Crouch" )
		return false;

	if ( isDefined( self.enemy ) && distanceSquared( self.enemy.origin, node.origin ) < 256 * 256 )
		return false;

	if ( GetNodeYawToEnemy() > 40 || GetNodeYawToEnemy() < - 40 )
		return false;

	return true;
}

determineNodeApproachType( node )
{
	if ( canUseSawApproach( node ) )
	{
		if ( node.type == "Cover Stand" )
			return "stand_saw";
		if ( node.type == "Cover Crouch" )
			return "crouch_saw";
		else if ( node.type == "Cover Prone" )
			return "prone_saw";
	}

	if ( !isdefined( anim.approach_types[ node.type ] ) )
		return;

	if ( isdefined( node.arrivalStance ) )
		stance = node.arrivalStance;
	else
		stance = node getHighestNodeStance();

	// no approach to prone
	if ( stance == "prone" )
		stance = "crouch";
		
	type = anim.approach_types[ node.type ][ stance ];
	
	if ( self shouldCQB() )
	{
		cqbType = type + "_cqb";
		if ( isdefined( anim.coverTrans[ cqbType ] ) )
			type = cqbType;
	}
	
	return type;		
}

determineNodeExitType( node )
{
	if ( canUseSawApproach( node ) )
	{
		if ( node.type == "Cover Stand" )
			return "stand_saw";
		if ( node.type == "Cover Crouch" )
			return "crouch_saw";
		else if ( node.type == "Cover Prone" )
			return "prone_saw";
	}

	if ( !isdefined( anim.approach_types[ node.type ] ) )
		return;
		
	if ( isdefined( anim.requiredExitStance[ node.type ] ) && anim.requiredExitStance[ node.type ] != self.a.pose )
		return;

	stance = self.a.pose;

	// no exit from prone
	if ( stance == "prone" )
		stance = "crouch";
		
	type = anim.approach_types[ node.type ][ stance ];
	
	if ( self shouldCQB() )
	{
		cqbType = type + "_cqb";
		if ( isdefined( anim.coverExit[ cqbType ] ) )
			type = cqbType;
	}
	
	return type;		
}

determineExposedApproachType( node )
{
	if ( isdefined( self.heat ) )
	{
		return "heat";
	}

	if ( isdefined( node.arrivalStance ) )
		stance = node.arrivalStance;
	else
		stance = node getHighestNodeStance();

	// no approach to prone
	if ( stance == "prone" )
		stance = "crouch";

	if ( stance == "crouch" )
		type = "exposed_crouch";
	else
		type = "exposed";
		
	if ( shouldCQB() )
		return type + "_cqb";
		
	return type;
}


getMaxDirectionsAndExcludeDirFromApproachType( node )
{
	returnobj = spawnstruct();

	if ( isdefined( node ) && isdefined( anim.maxDirections[ node.type ] ) )
	{
		returnobj.maxDirections = anim.maxDirections[ node.type ];
		returnobj.excludeDir = anim.excludeDir[ node.type ];
	}
	else
	{
		returnobj.maxDirections = 9;
		returnobj.excludeDir = -1;
	}
	
	return returnobj;
}

shouldApproachToExposed( approachType )
{
	// decide whether it's a good idea to go directly into the exposed position as we approach this node.

	if ( !isdefined( self.enemy ) )
		return false;// nothing to shoot!

	if ( self NeedToReload( 0.5 ) )
		return false;

	if ( self isSuppressedWrapper() )
		return false;// too dangerous, we need cover

	// path nodes have no special "exposed" position
	if ( isdefined( anim.exposedTransition[ approachtype ] ) )
		return false;

	// no arrival animations into exposed for left/right crouch
	if ( approachtype == "left_crouch" || approachtype == "right_crouch" )
		return false;

	return canSeePointFromExposedAtNode( self.enemy getShootAtPos(), self.node );
}


calculateNodeOffsetFromAnimationDelta( nodeAngles, delta )
{
	// in the animation, forward = +x and right = -y
	right = anglestoright( nodeAngles );
	forward = anglestoforward( nodeAngles );

	return vector_multiply( forward, delta[ 0 ] ) + vector_multiply( right, 0 - delta[ 1 ] );
}

getApproachEnt()
{
	if ( isdefined( self.scriptedArrivalEnt ) )
		return self.scriptedArrivalEnt;

	if ( isdefined( self.node ) )
		return self.node;

	return undefined;
}

getApproachPoint( node, approachtype )
{
	if ( approachType == "stand_saw" )
	{
		approachPoint = ( node.turretInfo.origin[ 0 ], node.turretInfo.origin[ 1 ], node.origin[ 2 ] );
		forward = anglesToForward( ( 0, node.turretInfo.angles[ 1 ], 0 ) );
		right = anglesToRight( ( 0, node.turretInfo.angles[ 1 ], 0 ) );
		approachPoint = approachPoint + vector_multiply( forward, -32.545 ) - vector_multiply( right, 6.899 ); // -41.343 would work better for the first number if that weren't too far from the node =(
	}
	else if ( approachType == "crouch_saw" )
	{
		approachPoint = ( node.turretInfo.origin[ 0 ], node.turretInfo.origin[ 1 ], node.origin[ 2 ] );
		forward = anglesToForward( ( 0, node.turretInfo.angles[ 1 ], 0 ) );
		right = anglesToRight( ( 0, node.turretInfo.angles[ 1 ], 0 ) );
		approachPoint = approachPoint + vector_multiply( forward, -32.545 ) - vector_multiply( right, 6.899 );
	}
	else if ( approachType == "prone_saw" )
	{
		approachPoint = ( node.turretInfo.origin[ 0 ], node.turretInfo.origin[ 1 ], node.origin[ 2 ] );
		forward = anglesToForward( ( 0, node.turretInfo.angles[ 1 ], 0 ) );
		right = anglesToRight( ( 0, node.turretInfo.angles[ 1 ], 0 ) );
		approachPoint = approachPoint + vector_multiply( forward, -37.36 ) - vector_multiply( right, 13.279 );
	}
	else if ( isdefined( self.scriptedArrivalEnt ) )
	{
		approachPoint = self.goalpos;
	}
	else
	{
		approachPoint = node.origin;
	}

	return approachPoint;
}


checkApproachPreConditions()
{
	// if we're going to do a negotiation, we want to wait until it's over and move.gsc is called again
	if ( isdefined( self getnegotiationstartnode() ) )
	{
		/# debug_arrival( "Not doing approach: path has negotiation start node" ); #/
		return false;
	}

	if ( isdefined( self.disableArrivals ) && self.disableArrivals )
	{
		/# debug_arrival( "Not doing approach: self.disableArrivals is true" ); #/
		return false;
	}

/#
	if ( isdefined( self.disableCoverArrivalsOnly ) )
	{
		debug_arrival( "Not doing approach: self.disableCoverArrivalsOnly is true" );
		return false;
	}
#/

	/*if ( self shouldCQB() )
	{
		/# debug_arrival("Not doing approach: self.cqbwalking is true"); #/
		return false;
	}*/

	return true;
}


checkApproachConditions( approachType, approach_dir, node )
{
	// we're doing default exposed approaches in doLastMinuteExposedApproach now
	if ( isdefined( anim.exposedTransition[ approachtype ] ) )
		return false;

	if ( approachType == "stand" || approachType == "crouch" )
	{
		assert( isdefined( node ) );
		if ( AbsAngleClamp180( vectorToYaw( approach_dir ) - node.angles[ 1 ] + 180 ) < 60 )
		{
			/# debug_arrival( "approach aborted: approach_dir is too far forward for node type " + node.type ); #/
			return false;
		}
	}

	if ( self isThreatenedByEnemy() || ( isdefined( self.lastApproachAbortTime ) && self.lastApproachAbortTime + 500 > getTime() ) )
	{
		/# debug_arrival( "approach aborted: nearby enemy threat" ); #/
		return false;
	}
	
	return true;
}

/#
setupApproachNode_debugInfo( actor, approachType, approach_dir, approachNodeYaw, node )
{
	if ( debug_arrivals_on_actor() )
	{
		println( "^5approaching cover (ent " + actor getentnum() + ", type \"" + approachType + "\"):" );
		println( "   approach_dir = (" + approach_dir[ 0 ] + ", " + approach_dir[ 1 ] + ", " + approach_dir[ 2 ] + ")" );
		angle = AngleClamp180( vectortoyaw( approach_dir ) - approachNodeYaw + 180 );
		if ( angle < 0 )
			println( "   (Angle of " + ( 0 - angle ) + " right from node forward.)" );
		else
			println( "   (Angle of " + angle + " left from node forward.)" );

		if ( approachType == "exposed" )
		{
			if ( isdefined( node ) )
			{
				if ( isdefined( approachtype ) )
					debug_arrival( "Aborting cover approach: node approach type was " + approachtype );
				else
					debug_arrival( "Aborting cover approach: node approach type was undefined" );
			}
			else
			{
				debug_arrival( "Aborting cover approach: node is undefined" );
			}
		}
		else
		{
			thread drawApproachVec( approach_dir );
		}
	}
}
#/


setupApproachNode( firstTime )
{
	self endon( "killanimscript" );
	//self endon("path_changed");

	if ( isdefined( self.heat ) )
	{
		self thread doLastMinuteExposedApproachWrapper();
		return;
	}

	// this lets code know that script is expecting the "cover_approach" notify
	if ( firstTime )
		self.requestArrivalNotify = true;

	self.a.arrivalType = undefined;
	self thread doLastMinuteExposedApproachWrapper();
	
	self waittill( "cover_approach", approach_dir );

	if ( !self checkApproachPreConditions() )
		return;

	self thread setupApproachNode( false );	// wait again incase path goal changes

	approachType = "exposed";
	approachPoint = self.pathGoalPos;
	approachNodeYaw = vectorToYaw( approach_dir );
	approachFinalYaw = approachNodeYaw;

	node = getApproachEnt();

	if ( isdefined( node ) )
	{
		approachType = determineNodeApproachType( node );
		if ( isdefined( approachtype ) && approachtype != "exposed" )
		{
			approachPoint = getApproachPoint( node, approachtype );
			approachNodeYaw = node.angles[ 1 ];
			approachFinalYaw = getNodeForwardYaw( node );
		}
	}

	/# setupApproachNode_debugInfo( self, approachType, approach_dir, approachNodeYaw, node ); #/

	if ( !checkApproachConditions( approachType, approach_dir, node ) )
		return;

	startCoverApproach( approachType, approachPoint, approachNodeYaw, approachFinalYaw, approach_dir );
}


coverApproachLastMinuteCheck( approachPoint, approachFinalYaw, approachType, approachNumber, requiredYaw )
{
	if ( isdefined( self.disableArrivals ) && self.disableArrivals )
	{
		 /# debug_arrival( "approach aborted at last minute: self.disableArrivals is true" ); #/
		return false;
	}

	// so we don't make guys turn around when they're (smartly) facing their enemy as they walk away
	if ( abs( self getMotionAngle() ) > 45 && isdefined( self.enemy ) && vectorDot( anglesToForward( self.angles ), vectorNormalize( self.enemy.origin - self.origin ) ) > .8 )
	{
		/# debug_arrival( "approach aborted at last minute: facing enemy instead of current motion angle" ); #/
		return false;
	}

	if ( self.a.pose != "stand" || ( self.a.movement != "run" && !( self isCQBWalkingOrFacingEnemy() ) ) )
	{
		 /# debug_arrival( "approach aborted at last minute: not standing and running" ); #/
		return false;
	}

	if ( AbsAngleClamp180( requiredYaw - self.angles[ 1 ] ) > 30 )
	{
		// don't do an approach away from an enemy that we would otherwise face as we moved away from them
		if ( isdefined( self.enemy ) && self canSee( self.enemy ) && distanceSquared( self.origin, self.enemy.origin ) < 256 * 256 )
		{
			// check if enemy is in frontish of us
			if ( vectorDot( anglesToForward( self.angles ), self.enemy.origin - self.origin ) > 0 )
			{
				 /# debug_arrival( "aborting approach at last minute: don't want to turn back to nearby enemy" ); #/
				return false;
			}
		}
	}

	// make sure the path is still clear
	if ( !checkCoverEnterPos( approachPoint, approachFinalYaw, approachType, approachNumber, false ) )
	{
		 /# debug_arrival( "approach blocked at last minute" ); #/
		return false;
	}

	return true;
}

approachWaitTillClose( node, checkDist )
{
	if ( !isdefined( node ) )
		return;
		
	// wait until we get to the point where we have to decide what approach animation to play
	while ( 1 )
	{
		if ( !isdefined( self.pathGoalPos ) )
			self waitForPathGoalPos();

		dist = distance( self.origin, self.pathGoalPos );

		if ( dist <= checkDist + allowedError )
			break;

		// underestimate how long to wait so we don't miss the crucial point
		waittime = ( dist - checkDist ) / maxSpeed - .1;
		if ( waittime < .05 )
			waittime = .05;

		wait waittime;
	}
}

startCoverApproach( approachType, approachPoint, approachNodeYaw, approachFinalYaw, approach_dir )
{
	self endon( "killanimscript" );
	self endon( "cover_approach" );

	assert( isdefined( approachType ) );
	assert( approachType != "exposed" );

	node = getApproachEnt();
	result = getMaxDirectionsAndExcludeDirFromApproachType( node );
	maxDirections = result.maxDirections;
	excludeDir = result.excludeDir;

	arrivalFromFront = vectorDot( approach_dir, anglestoforward( node.angles ) ) >= 0;
	
	// find best possible position to start arrival animation
	result = self CheckArrivalEnterPositions( approachPoint, approachFinalYaw, approachType, approach_dir, maxDirections, excludeDir, arrivalFromFront );

	if ( result.approachNumber < 0 )
	{
		/# debug_arrival( "approach aborted: " + result.failure ); #/
		self notify( "approach_aborted" );
		return;
	}

	approachNumber = result.approachNumber;
	/# debug_arrival( "approach success: dir " + approachNumber ); #/

	if ( level._newArrivals && approachNumber <= 6 && arrivalFromFront )
	{
		self endon( "goal_changed" );

		if (use_custom_coverset( approachtype ) )
		{
			self.arrivalStartDist = self.customCoverTransLongestDist[ approachtype ];
		}
		else
		{
			self.arrivalStartDist = anim.coverTransLongestDist[ approachtype ];
		}
		
		approachWaitTillClose( node, self.arrivalStartDist );
		
		// get the best approach direction from current position
		dirToNode = vectorNormalize( approachPoint - self.origin );
		result = self CheckArrivalEnterPositions( approachPoint, approachFinalYaw, approachType, dirToNode, maxDirections, excludeDir, arrivalFromFront );
		
		if (use_custom_coverset( approachtype ) )
		{
			self.arrivalStartDist = length( self.customCoverEnterDist[ approachtype ][ approachNumber ] );
		}
		else
		{
			self.arrivalStartDist = length( anim.coverTransDist[ approachtype ][ approachNumber ] );
		}
		approachWaitTillClose( node, self.arrivalStartDist );
		
		if ( !( self maymovetopoint( approachPoint ) ) )
		{
			/# debug_arrival( "approach blocked at last minute" ); #/
			self.arrivalStartDist = undefined;
			self notify( "approach_aborted" );
			return;
		}
		
		if ( result.approachNumber < 0 )
		{
			/# debug_arrival( "final approach aborted: " + result.failure ); #/
			self.arrivalStartDist = undefined;
			self notify( "approach_aborted" );
			return;
		}		
		
		approachNumber = result.approachNumber;
		/# debug_arrival( "final approach success: dir " + approachNumber ); #/
			
		requiredYaw = approachFinalYaw - get_approach_yaw( approachType, approachNumber );
	}
	else
	{
	    // set arrival position and wait	
	    self setRunToPos( self.coverEnterPos );
	    self waittill( "runto_arrived" );

		requiredYaw = approachFinalYaw - get_approach_yaw( approachType, approachNumber );	

	    if ( !self coverApproachLastMinuteCheck( approachPoint, approachFinalYaw, approachType, approachNumber, requiredYaw ) )
		{
			self notify( "approach_aborted" );
		    return;		    
		}
	}

	self.approachNumber = approachNumber;	// used in cover_arrival::main()
	self.approachType = approachType;
	self.arrivalStartDist = undefined;
	self startcoverarrival( self.coverEnterPos, requiredYaw );
}

get_approach_yaw( approachType, approachNumber )
{
		if( use_custom_coverset( approachtype ) )
		{			
			requiredYaw = self.customCoverEnterAngles[ approachType ][ approachNumber ];
		}
		else
		{
			requiredYaw = anim.coverTransAngles[ approachType ][ approachNumber ];
		}

		return requiredYaw;
}


CheckArrivalEnterPositions( approachpoint, approachYaw, approachtype, approach_dir, maxDirections, excludeDir, arrivalFromFront )
{
	assert( approachtype != "exposed" );
	angleDataObj = spawnstruct();

	calculateNodeTransitionAngles( angleDataObj, approachtype, true, approachYaw, approach_dir, maxDirections, excludeDir );
	sortNodeTransitionAngles( angleDataObj, maxDirections );

	resultobj = spawnstruct();
	/#resultobj.data = [];#/

	arrivalPos = ( 0, 0, 0 );
	resultobj.approachNumber = -1;

	numAttempts = 2;
	
	for ( i = 1; i <= numAttempts; i++ )
	{
		assert( angleDataObj.transIndex[ i ] != excludeDir );// shouldn't hit excludeDir unless numAttempts is too big

		resultobj.approachNumber = angleDataObj.transIndex[ i ];
		
		if ( !self checkCoverEnterPos( approachpoint, approachYaw, approachtype, resultobj.approachNumber, arrivalFromFront ) )
		{
			/#resultobj.data[ resultobj.data.size ] = "approach blocked: dir " + resultobj.approachNumber;#/
			continue;
		}
		break;
	}

	if ( i > numAttempts )
	{
		/#resultobj.failure = numAttempts + " direction attempts failed";#/
		resultobj.approachNumber = -1;
		return resultobj;
	}

	// if AI is closer to node than coverEnterPos is, don't do arrival
	distToApproachPoint = distanceSquared( approachpoint, self.origin );
	distToAnimStart = distanceSquared( approachpoint, self.coverEnterPos );
	if ( distToApproachPoint < distToAnimStart * 2 * 2 )
	{
		if ( distToApproachPoint < distToAnimStart )
		{
			/#resultobj.failure = "too close to destination";#/
			resultobj.approachNumber = -1;
			return resultobj;
		}

		if ( !level._newArrivals || !arrivalFromFront )
		{
			// if AI is less than twice the distance from the node than the beginning of the approach animation,
			// make sure the angle we'll turn when we start the animation is small.
			selfToAnimStart = vectorNormalize( self.coverEnterPos - self.origin );

			if( use_custom_coverset( approachtype ) )
			{			
				requiredYaw = approachYaw - self.customCoverEnterAngles[ approachType ][ resultobj.approachNumber ];
			}
			else
			{
				requiredYaw = approachYaw - anim.coverTransAngles[ approachType ][ resultobj.approachNumber ];
			}	

			AnimStartToNode = anglesToForward( ( 0, requiredYaw, 0 ) );
			cosAngle = vectorDot( selfToAnimStart, AnimStartToNode );

			if ( cosAngle < 0.707 )// 0.707 == cos( 45 )
			{
				/#resultobj.failure = "angle to start of animation is too great (angle of " + acos( cosAngle ) + " > 45)";#/
				resultobj.approachNumber = -1;
				return resultobj;
			}
		}
	}

	/#
	for ( i = 0; i < resultobj.data.size; i++ )
		debug_arrival( resultobj.data[ i ] );
	#/

	return resultobj;
}

doLastMinuteExposedApproachWrapper()
{
	self endon( "killanimscript" );
	self endon( "move_interrupt" );

	self notify( "doing_last_minute_exposed_approach" );
	self endon( "doing_last_minute_exposed_approach" );

	self thread watchGoalChanged();

	while ( 1 )
	{
		doLastMinuteExposedApproach();

		// try again when our goal pos changes
		while ( 1 )
		{
			self waittill_any( "goal_changed", "goal_changed_previous_frame" );

			// our goal didn't *really* change if it only changed because we called setRunToPos
			if ( isdefined( self.coverEnterPos ) && isdefined( self.pathGoalPos ) && distance2D( self.coverEnterPos, self.pathGoalPos ) < 1 )
				continue;
			break;
		}
	}
}

watchGoalChanged()
{
	self endon( "killanimscript" );
	self endon( "doing_last_minute_exposed_approach" );

	while ( 1 )
	{
		self waittill( "goal_changed" );
		wait .05;
		self notify( "goal_changed_previous_frame" );
	}
}


exposedApproachConditionCheck( node, goalMatchesNode )
{
	if ( !isdefined( self.pathGoalPos ) )
	{
		 /# debug_arrival( "Aborting exposed approach because I have no path" ); #/
		return false;
	}

	if ( isdefined( self.disableArrivals ) && self.disableArrivals )
	{
		 /# debug_arrival( "Aborting exposed approach because self.disableArrivals is true" ); #/
		return false;
	}

	if ( isdefined( self.approachConditionCheckFunc ) )
	{
		if ( !self [[self.approachConditionCheckFunc]]( node ) )
			return false;
	}
	else
	{
		if ( !self.faceMotion && ( !isdefined( node ) || node.type == "Path" )  )
		{
			 /# debug_arrival( "Aborting exposed approach because not facing motion and not going to a node" ); #/
			return false;
		}

		if ( self.a.pose != "stand" )
		{
			 /# debug_arrival( "approach aborted at last minute: not standing" ); #/
			return false;
		}
	}

	if ( self isThreatenedByEnemy() || ( isdefined( self.lastApproachAbortTime ) && self.lastApproachAbortTime + 500 > getTime() ) )
	{
		/# debug_arrival( "approach aborted: nearby enemy threat" ); #/
		return false;
	}
	
	// only do an arrival if we have a clear path
	if ( !self maymovetopoint( self.pathGoalPos ) )
	{
		 /#debug_arrival( "Aborting exposed approach: maymove check failed" );#/
		return false;
	}

	return true;
}

exposedApproachWaitTillClose()
{
	// wait until we get to the point where we have to decide what approach animation to play
	while ( 1 )
	{
		if ( !isdefined( self.pathGoalPos ) )
			self waitForPathGoalPos();

		node = getApproachEnt();
		if ( isdefined( node ) && !isdefined( self.heat ) )
			arrivalPos = node.origin;
		else
			arrivalPos = self.pathGoalPos;
			
		dist = distance( self.origin, arrivalPos );
		
		checkDist = anim.longestExposedApproachDist;		

		if ( dist <= checkDist + allowedError )
			break;

		// underestimate how long to wait so we don't miss the crucial point
		waittime = ( dist - checkDist ) / maxSpeed - .1;
		if ( waittime < 0 )
			break;
			
		if ( waittime < .05 )
			waittime = .05;

		// /#self thread animscripts\shared::showNoteTrack("wait " + waittime);#/
		wait waittime;
	}
}


faceEnemyAtEndOfApproach( node )
{
	if ( !isdefined( self.enemy ) )
		return false;
		
	if ( isdefined( self.heat ) && isdefined( node ) ) 
		return false;
		
	if ( self.combatmode == "cover" && isSentient( self.enemy ) && gettime() - self lastKnownTime( self.enemy ) > 15000 )
		return false;
		
	return sightTracePassed( self.enemy getShootAtPos(), self.pathGoalPos + ( 0, 0, 60 ), false, undefined );
}


doLastMinuteExposedApproach()
{
	self endon( "goal_changed" );
	self endon( "move_interrupt" );

	if ( isdefined( self getnegotiationstartnode() ) )
		return;

	self exposedApproachWaitTillClose();

	if ( isdefined( self.grenade ) && isdefined( self.grenade.activator ) && self.grenade.activator == self )
		return;
		
	approachType = "exposed";
	maxDistToNodeSq = 1;

	if ( isdefined( self.approachTypeFunc ) )
	{
		approachtype = self [[ self.approachTypeFunc ]]();
	}
	else if ( self shouldCQB() )
	{
		approachtype = "exposed_cqb";
	}
	else if ( isdefined( self.heat ) )
	{
		approachtype = "heat";
		maxDistToNodeSq = 64 * 64;
	}
		
	node = getApproachEnt();

	if ( isdefined( node ) && isdefined( self.pathGoalPos ) && !isdefined( self.disableCoverArrivalsOnly ) )
		goalMatchesNode = distanceSquared( self.pathGoalPos, node.origin ) < maxDistToNodeSq;
	else
		goalMatchesNode = false;

	if ( goalMatchesNode )
		approachtype = determineExposedApproachType( node );

	approachDir = VectorNormalize( self.pathGoalPos - self.origin );

	// by default, want to face forward
	desiredFacingYaw = vectorToYaw( approachDir );
	
	if ( isdefined( self.faceEnemyArrival ) )
	{
		desiredFacingYaw = self.angles[1];
	}
	else if ( faceEnemyAtEndOfApproach( node ) )
	{
		desiredFacingYaw = vectorToYaw( self.enemy.origin - self.pathGoalPos );
	}
	else
	{
		faceNodeAngle = isdefined( node ) && goalMatchesNode;
		faceNodeAngle = faceNodeAngle && ( node.type != "Path" ) && ( node.type != "Ambush" || !recentlySawEnemy() );

		if ( faceNodeAngle )
		{
			desiredFacingYaw = getNodeForwardYaw( node );
		}
		else
		{
			likelyEnemyDir = self getAnglesToLikelyEnemyPath();
			if ( isdefined( likelyEnemyDir ) )
				desiredFacingYaw = likelyEnemyDir[ 1 ];
		}
	}

	angleDataObj = spawnstruct();
	calculateNodeTransitionAngles( angleDataObj, approachType, true, desiredFacingYaw, approachDir, 9, -1 );

	// take best animation
	best = 1;
	for ( i = 2; i <= 9; i++ )
	{
		if ( angleDataObj.transitions[ i ] > angleDataObj.transitions[ best ] )
			best = i;
	}
	self.approachNumber = angleDataObj.transIndex[ best ];
	self.approachType = approachType;

	 /# debug_arrival( "Doing exposed approach in direction " + self.approachNumber );	#/

	approachAnim = anim.coverTrans[ approachType ][ self.approachNumber ];

	if ( use_custom_coverset( approachtype ) )
	{
		animDist = length( self.customCoverEnterDist[ approachtype ][ self.approachNumber ] );
	}
	else
	{
		animDist = length( anim.coverTransDist[ approachtype ][ self.approachNumber ] );
	}

	requiredDistSq = animDist + allowedError;
	requiredDistSq = requiredDistSq * requiredDistSq;

	// we should already be close
	while ( isdefined( self.pathGoalPos ) && distanceSquared( self.origin, self.pathGoalPos ) > requiredDistSq )
		wait .05;

	if ( isdefined( self.arrivalStartDist ) && self.arrivalStartDist < animDist + allowedError )
	{
		/# debug_arrival( "Aborting exposed approach because cover arrival dist is shorter" ); #/
		return;
	}

	if ( !self exposedApproachConditionCheck( node, goalMatchesNode ) )
	{
		return;
	}

	dist = distance( self.origin, self.pathGoalPos );
	if ( abs( dist - animDist ) > allowedError )
	{
		/# debug_arrival( "Aborting exposed approach because distance difference exceeded allowed error: " + dist + " more than " + allowedError + " from " + animDist ); #/
		return;
	}

	facingYaw = vectorToYaw( self.pathGoalPos - self.origin );

	if ( isdefined( self.heat ) && goalMatchesNode )
	{
		requiredYaw = desiredFacingYaw - get_approach_yaw( approachType, self.approachNumber );		
		idealStartPos = getArrivalStartPos( self.pathGoalPos, desiredFacingYaw, approachtype, self.approachNumber );
	}
	else if ( animDist > 0 )
	{
		if ( use_custom_coverset( approachtype ) )
		{
			delta = self.customCoverEnterDist[ approachtype ][ self.approachNumber ];
		}
		else
		{
			delta = anim.coverTransDist[ approachtype ][ self.approachNumber ];
		}
		
		assert( delta[ 0 ] != 0 );
		yawToMakeDeltaMatchUp = atan( delta[ 1 ] / delta[ 0 ] );

		if ( !isdefined( self.faceEnemyArrival ) || self.faceMotion )
		{
			requiredYaw = facingYaw - yawToMakeDeltaMatchUp;
			if ( AbsAngleClamp180( requiredYaw - self.angles[ 1 ] ) > 30 )
			{
				/# debug_arrival( "Aborting exposed approach because angle change was too great" ); #/
				return;
			}
		}
		else
		{
			requiredYaw = self.angles[1];
		}

		closerDist = dist - animDist;
		idealStartPos = self.origin + vector_multiply( vectorNormalize( self.pathGoalPos - self.origin ), closerDist );
	}
	else
	{
		requiredYaw = self.angles[1];
		idealStartPos = self.origin;
	}

	self startcoverarrival( idealStartPos, requiredYaw );
}

waitForPathGoalPos()
{
	while ( 1 )
	{
		if ( isdefined( self.pathgoalpos ) )
			return;

		wait 0.1;
	}
}


startMoveTransitionPreConditions()
{
	// if we don't know where we're going, we can't check if it's a good idea to do the exit animation
	// (and it's probably not)
	if ( !isdefined( self.pathGoalPos ) )
	{
		 /# debug_arrival( "not exiting cover (ent " + self getentnum() + "): self.pathGoalPos is undefined" ); #/
		return false;
	}

	if ( !self shouldFaceMotion() )
	{
		 /# debug_arrival( "not exiting cover (ent " + self getentnum() + "): self.faceMotion is false" ); #/
		return false;
	}

	if ( self.a.pose == "prone" )
	{
		 /# debug_arrival( "not exiting cover (ent " + self getentnum() + "): self.a.pose is \"prone\"" ); #/
		return false;
	}

	if ( isdefined( self.disableExits ) && self.disableExits )
	{
		 /# debug_arrival( "not exiting cover (ent " + self getentnum() + "): self.disableExits is true" ); #/
		return false;
	}

	if ( self.stairsState != "none" )
	{
		 /# debug_arrival( "not exiting cover (ent " + self getentnum() + "): on stairs" ); #/
		return false;
	}

	if ( !self isStanceAllowed( "stand" ) && !isdefined( self.heat ) )
	{
		 /# debug_arrival( "not exiting cover (ent " + self getentnum() + "): not allowed to stand" ); #/
		return false;
	}
	
	if ( distanceSquared( self.origin, self.pathGoalPos ) < 10000 )
	{
		/# debug_arrival( "not exiting cover (ent " + self getentnum() + "): too close to goal" ); #/
		return false;
	}

	return true;
}


startMoveTransitionConditions( exittype, exitNode )
{
	if ( !isdefined( exittype ) )
	{
		 /# debug_arrival( "aborting exit: not supported for node type " + exitNode.type ); #/
		return false;
	}

	// since we transition directly into a standing run anyway,
	// we might as well just use the standing exits when crouching too
	if ( exittype == "exposed" || isdefined( self.heat ) )
	{
		if ( self.a.pose != "stand" && self.a.pose != "crouch" )
		{
			 /# debug_arrival( "exposed exit aborted because anim_pose is not \"stand\" or \"crouch\"" ); #/
			return false;
		}
		if ( self.a.movement != "stop" )
		{
			 /# debug_arrival( "exposed exit aborted because anim_movement is not \"stop\"" ); #/
			return false;
		}
	}

	// don't do an exit away from an enemy that we would otherwise face as we moved away from them
	if ( !isdefined( self.heat ) && isdefined( self.enemy ) && vectorDot( self.lookaheaddir, self.enemy.origin - self.origin ) < 0 )
	{
		if ( self canSeeEnemyFromExposed() && distanceSquared( self.origin, self.enemy.origin ) < 300 * 300 )
		{
			 /# debug_arrival( "aborting exit: don't want to turn back to nearby enemy" ); #/
			return false;
		}
	}

	return true;
}

/#
startMoveTransition_debugInfo( exittype, exityaw )
{
	if ( debug_arrivals_on_actor() )
	{
		println( "^3exiting cover (ent " + self getentnum() + ", type \"" + exittype + "\"):" );
		println( "   lookaheaddir = (" + self.lookaheaddir[ 0 ] + ", " + self.lookaheaddir[ 1 ] + ", " + self.lookaheaddir[ 2 ] + ")" );
		angle = AngleClamp180( vectortoyaw( self.lookaheaddir ) - exityaw );
		if ( angle < 0 )
			println( "   (Angle of " + ( 0 - angle ) + " right from node forward.)" );
		else
			println( "   (Angle of " + angle + " left from node forward.)" );
	}
}
#/

getExitNode()
{
	exitNode = undefined;
	
	if ( !isdefined( self.heat ) )
		limit = 400;	// 20 * 20
	else
		limit = 4096;	// 64 * 64

	if ( isdefined( self.node ) && ( distanceSquared( self.origin, self.node.origin ) < limit ) )
		exitNode = self.node;
	else if ( isdefined( self.prevNode ) && ( distanceSquared( self.origin, self.prevNode.origin ) < limit ) )
		exitNode = self.prevNode;

	if ( isdefined( exitNode ) && isdefined( self.heat ) && AbsAngleClamp180( self.angles[1] - exitNode.angles[1] ) > 30 )
		return undefined;

	return exitNode;
}

customMoveTransitionFunc()
{
	if ( !isdefined( self.startMoveTransitionAnim ) )
		return;
		
	self animmode( "zonly_physics", false );
	self orientmode( "face current" );
	
	self SetFlaggedAnimKnobAllRestart( "move", self.startMoveTransitionAnim, %root, 1 );

	if ( animHasNotetrack( self.startMoveTransitionAnim, "code_move" ) )
	{
		self animscripts\shared::DoNoteTracks( "move" );	// return on code_move
		self OrientMode( "face motion" );	// want to face motion since we are only playing exit animation( no l / r / b animations )
		self animmode( "none", false );
	}
	
	self animscripts\shared::DoNoteTracks( "move" );
}


determineNonNodeExitType( exittype )
{
	if ( self.a.pose == "stand" )
		exittype = "exposed";
	else
		exittype = "exposed_crouch";
		
	if ( shouldCQB() )
		exittype = exittype + "_cqb";
	else if ( isdefined( self.heat ) )
		exittype = "heat";
		
	return exittype;
}

determineHeatCoverExitType( exitNode, exittype )
{
	if ( exitNode.type == "Cover Right" )
		exittype = "heat_right";
	else if ( exitNode.type == "Cover Left" )
		exittype = "heat_left";
		
	return exittype;
}


startMoveTransition()
{
	if ( isdefined( self.customMoveTransition ) )
	{
		customTransition = self.customMoveTransition;
		if ( !isdefined( self.permanentCustomMoveTransition ) )
			self.customMoveTransition = undefined;
			
		[[ customTransition ]]();

		if ( !isdefined( self.permanentCustomMoveTransition ) )
			self.startMoveTransitionAnim = undefined;

		self clearanim( %root, 0.2 );
		self orientmode( "face default" );
		self animmode( "none", false );
		
		return;
	}
	
	self endon( "killanimscript" );

	if ( !self startMoveTransitionPreConditions() )
		return;

	// assume an exit from exposed.
	exitpos = self.origin;
	exityaw = self.angles[ 1 ];
	exittype = "exposed";
	exitTypeFromNode = false;

	exitNode = getExitNode();

	// if we're at a node, try to do an exit from the node.
	if ( isdefined( exitNode ) )
	{
		nodeExitType = determineNodeExitType( exitNode );
		
		if ( isdefined( nodeExitType ) )
		{
			exitType = nodeExitType;
			exitTypeFromNode = true;
		
			if ( isdefined( self.heat ) )
				exitType = determineHeatCoverExitType( exitNode, exittype );

			if ( !isdefined( anim.exposedTransition[ exitType ] ) && exittype != "stand_saw" && exittype != "crouch_saw" )
			{
				// if angle is wrong, don't do exit behavior for the node. Distance check already done in getExitNode

				anglediff = AbsAngleClamp180( self.angles[ 1 ] - GetNodeForwardYaw( exitNode ) );
				if ( anglediff < 5 )
				{
					// do exit behavior for the node.
					if ( !isdefined( self.heat ) )
						exitpos = exitNode.origin;
					exityaw = GetNodeForwardYaw( exitNode );
				}
			}
		}
	}

	/# self startMoveTransition_debugInfo( exittype, exityaw ); #/

	if ( !self startMoveTransitionConditions( exittype, exitNode ) )
		return;

	isExposedExit = isdefined( anim.exposedTransition[ exittype ] );
	if ( !exitTypeFromNode )
		exittype = determineNonNodeExitType();

	// since we're leaving, take the opposite direction of lookahead
	leaveDir = ( -1 * self.lookaheaddir[ 0 ], -1 * self.lookaheaddir[ 1 ], 0 );

	result = getMaxDirectionsAndExcludeDirFromApproachType( exitNode );
	maxDirections = result.maxDirections;
	excludeDir = result.excludeDir;

	angleDataObj = spawnstruct();

	calculateNodeTransitionAngles( angleDataObj, exittype, false, exityaw, leaveDir, maxDirections, excludeDir );
	sortNodeTransitionAngles( angleDataObj, maxDirections );

	approachnumber = -1;
	numAttempts = 3;

	for ( i = 1; i <= numAttempts; i++ )
	{
		assert( angleDataObj.transIndex[ i ] != excludeDir );// shouldn't hit excludeDir unless numAttempts is too big

		approachNumber = angleDataObj.transIndex[ i ];
		if ( self checkCoverExitPos( exitpos, exityaw, exittype, isExposedExit, approachNumber ) )
			break;

		/# debug_arrival( "exit blocked: dir " + approachNumber ); #/
	}

	if ( i > numAttempts )
	{
		/# debug_arrival( "aborting exit: too many exit directions blocked" ); #/
		return;
	}

	// if AI is closer to destination than exitPos is, don't do exit
	allowedDistSq = distanceSquared( self.origin, self.coverExitPos ) * 1.25 * 1.25;
	if ( distanceSquared( self.origin, self.pathgoalpos ) < allowedDistSq )
	{
		/# debug_arrival( "exit failed, too close to destination" ); #/
		return;
	}

	/# debug_arrival( "exit success: dir " + approachNumber ); #/
	self doCoverExitAnimation( exittype, approachNumber );
}

str( val )
{
	if ( !isdefined( val ) )
		return "{undefined}";
	return val;
}

doCoverExitAnimation( exittype, approachNumber )
{
	assert( isdefined( approachNumber ) );
	assert( approachnumber > 0 );

	assert( isdefined( exittype ) );

	leaveAnim = anim.coverExit[ exittype ][ approachnumber ];
	if ( IsDefined( self.customCoverExitTrans ) && IsDefined( self.customCoverExitTrans[ exittype ] ) && IsDefined( self.customCoverExitTrans[ exittype ][ approachnumber ] ) )
	{
		leaveAnim = self.customCoverExitTrans[ exittype ][ approachnumber ];
	}

	assert( isdefined( leaveAnim ) );

	lookaheadAngles = vectortoangles( self.lookaheaddir );

	/#
	if ( debug_arrivals_on_actor() )
	{
		endpos = self.origin + vector_multiply( self.lookaheaddir, 100 );
		thread debugLine( self.origin, endpos, ( 1, 0, 0 ), 1.5 );
	}
	#/

	if ( self.a.pose == "prone" )
		return;

	// tagJW<NOTE>: Use the blend_finish tag to determine blend time on the arrival animation
	transTime = 0.2;
	blend_out_time = 0.2;
	self.cqb_blend_finish_time = undefined;
	self.run_blend_finish_time = undefined;
	
	if ( animHasNotetrack( leaveAnim, "blend_finish" ) && !(self IsCQBWalking()) )
	{		
		finish_time = GetNoteTrackTimes( leaveAnim, "finish" );
		blend_finish_time = GetNotetrackTimes( leaveAnim, "blend_finish" );

		/#
		if ( blend_finish_time[0] < finish_time[0] )
		{
			AssertMsg( "blend_finish tag must occur later than finish tag." );
		}
		#/

		assert( blend_finish_time[0] > finish_time[0] );
		self.run_blend_finish_time = (blend_finish_time[0] - finish_time[0]) * GetAnimLength( leaveAnim );
		blend_out_time = self.run_blend_finish_time;
	}
	else if ( animHasNotetrack( leaveAnim, "cqb_blend_finish" ) && (self IsCQBWalking()) )
	{		
		finish_time = GetNoteTrackTimes( leaveAnim, "finish" );
		blend_finish_time = GetNotetrackTimes( leaveAnim, "cqb_blend_finish" );

		/#
		if ( blend_finish_time[0] < finish_time[0] )
		{
			AssertMsg( "blend_finish tag must occur later than finish tag." );
		}
		#/

		assert( blend_finish_time[0] > finish_time[0] );
		self.cqb_blend_finish_time = (blend_finish_time[0] - finish_time[0]) * GetAnimLength( leaveAnim );
		blend_out_time = self.cqb_blend_finish_time;
	}

	// tagJW<NOTE>: Check to see if a run anim start has been defined for this anim
	self animscripts\utility::handle_move_transition_notes( leaveAnim );

	self animMode( "zonly_physics", false );
	self OrientMode( "face angle", self.angles[ 1 ] );
	self setFlaggedAnimKnobAllRestart( "coverexit", leaveAnim, %body, 1, transTime, self.moveTransitionRate );

	assert( animHasNotetrack( leaveAnim, "code_move" ) );

	self animscripts\shared::DoNoteTracks( "coverexit" ); // until "code_move"

	self.a.pose = "stand";
	self.a.movement = "run";

	self.ignorePathChange = undefined;
	self OrientMode( "face motion" );	// want to face motion since we are only playing exit animation( no l / r / b animations )
	self animmode( "none", false );

	self finishCoverExitNotetracks( "coverexit" );

	// need to clear everything above leaveAnim
	//self clearanim( leaveAnim, 0.2 );
	self clearanim( %root, blend_out_time );

	self OrientMode( "face default" );
	//self thread faceEnemyOrMotionAfterABit();
	self animMode( "normal", false );
}

finishCoverExitNotetracks( flagname )
{
	self endon( "move_loop_restart" );
	self animscripts\shared::DoNoteTracks( flagname );
}

/*faceEnemyOrMotionAfterABit()
{
	self endon( "killanimscript" );
	self endon( "move_interrupt" );

	wait 1.0;

	// don't want to spin around if we're almost where we're going anyway
	while ( isdefined( self.pathGoalPos ) && distanceSquared( self.origin, self.pathGoalPos ) < 200 * 200 )
		wait .25;

	self OrientMode( "face default" );
}*/


drawVec( start, end, duration, color )
{
	for ( i = 0; i < duration * 100; i++ )
	{
		line( start + ( 0, 0, 30 ), end + ( 0, 0, 30 ), color );
		wait 0.05;
	}
}

drawApproachVec( approach_dir )
{
	self endon( "killanimscript" );
	for ( ;; )
	{
		if ( !isdefined( self.node ) )
			break;
		line( self.node.origin + ( 0, 0, 20 ), ( self.node.origin - vector_multiply( approach_dir, 64 ) ) + ( 0, 0, 20 ) );
		wait( 0.05 );
	}
}

calculateNodeTransitionAngles( angleDataObj, approachtype, isarrival, arrivalYaw, approach_dir, maxDirections, excludeDir )
{
	angleDataObj.transitions = [];
	angleDataObj.transIndex = [];

	anglearray = undefined;
	sign = 1;
	offset = 0;
	if ( isarrival )
	{
		if( use_custom_coverset( approachtype ) )
		{			
			anglearray = self.customCoverEnterAngles[ approachtype ];
		}
		else
		{
			anglearray = anim.coverTransAngles[ approachtype ];
		}		
		sign = -1;
		offset = 0;
	}
	else
	{
		if( use_custom_coverset( approachtype ) )
		{
			anglearray = self.customCoverExitAngles[ approachtype ];
		}
		else
		{
			anglearray = anim.coverExitAngles[ approachtype ];
		}
		
		sign = 1;
		offset = 180;
	}

	for ( i = 1; i <= maxDirections; i++ )
	{
		angleDataObj.transIndex[ i ] = i;

		if ( i == 5 || i == excludeDir || !isdefined( anglearray[ i ] ) )
		{
			angleDataObj.transitions[ i ] = -1.0003;	// cos180 - epsilon
			continue;
		}

		angles = ( 0, arrivalYaw + sign * anglearray[ i ] + offset, 0 );

		dir = vectornormalize( anglestoforward( angles ) );
		angleDataObj.transitions[ i ] = vectordot( approach_dir, dir );
	}
}

/#
printdebug( pos, offset, text, color, linecolor )
{
	for ( i = 0; i < 20 * 5; i++ )
	{
		line( pos, pos + offset, linecolor );
		print3d( pos + offset, text, ( color, color, color ) );
		wait .05;
	}
}
#/


sortNodeTransitionAngles( angleDataObj, maxDirections )
{
	for ( i = 2; i <= maxDirections; i++ )
	{
		currentValue = angleDataObj.transitions[ angleDataObj.transIndex[ i ] ];
		currentIndex = angleDataObj.transIndex[ i ];

		for ( j = i - 1; j >= 1; j -- )
		{
			if ( currentValue < angleDataObj.transitions[ angleDataObj.transIndex[ j ] ] )
				break;

			angleDataObj.transIndex[ j + 1 ]  = angleDataObj.transIndex[ j ];
		}

		angleDataObj.transIndex[ j + 1 ] = currentIndex;
	}
}

checkCoverExitPos( exitpoint, exityaw, exittype, isExposedExit, approachNumber )
{
	angle = ( 0, exityaw, 0 );

	forwardDir = anglestoforward( angle );
	rightDir = anglestoright( angle );

	if( use_custom_coverset( exittype ) )
	{
		forward = vector_multiply( forwardDir, self.customCoverExitDist[ exittype ][ approachNumber ][ 0 ] );
		right   = vector_multiply( rightDir, self.customCoverExitDist[ exittype ][ approachNumber ][ 1 ] );
	}
	else
	{
		forward = vector_multiply( forwardDir, anim.coverExitDist[ exittype ][ approachNumber ][ 0 ] );
		right   = vector_multiply( rightDir, anim.coverExitDist[ exittype ][ approachNumber ][ 1 ] );
	}

	exitPos = exitpoint + forward - right;
	self.coverExitPos = exitPos;

	/#
	if ( debug_arrivals_on_actor() )
		thread debugLine( self.origin, exitpos, ( 1, .5, .5 ), 1.5 );
	#/

	if ( !isExposedExit && !( self checkCoverExitPosWithPath( exitPos ) ) )
	{
		 /#
		debug_arrival( "cover exit " + approachNumber + " path check failed" );
		#/
		return false;
	}

	if ( !( self maymovefrompointtopoint( self.origin, exitPos ) ) )
		return false;

	if ( approachNumber <= 6 || isExposedExit )
		return true;

	// if 7, 8, 9 direction, split up check into two parts of the 90 degree turn around corner
	// (already did the first part, from node to corner, now doing from corner to end of exit anim)
	if( use_custom_coverset( exittype ) )
	{
		forward = vector_multiply( forwardDir, self.customCoverExitPostDist[ exittype ][ approachNumber ][ 0 ] );
		right   = vector_multiply( rightDir, self.customCoverExitPostDist[ exittype ][ approachNumber ][ 1 ] );
	}
	else
	{
		forward = vector_multiply( forwardDir, anim.coverExitPostDist[ exittype ][ approachNumber ][ 0 ] );
		right   = vector_multiply( rightDir, anim.coverExitPostDist[ exittype ][ approachNumber ][ 1 ] );
	}
	

	finalExitPos = exitPos + forward - right;
	self.coverExitPos = finalExitPos;

	 /#
	if ( debug_arrivals_on_actor() )
		thread debugLine( exitpos, finalExitPos, ( 1, .5, .5 ), 1.5 );
	#/
	return( self maymovefrompointtopoint( exitPos, finalExitPos ) );
}

// don't want to pass in anim.coverTransDist or coverTransPreDist as paramter, since it will be copied
getArrivalStartPos( arrivalPoint, arrivalYaw, approachType, approachNumber )
{
	if( use_custom_coverset( approachtype ) )
	{			
		angle = ( 0, arrivalYaw - self.customCoverEnterAngles[ approachtype ][ approachNumber ], 0 );
	}
	else
	{
		angle = ( 0, arrivalYaw - anim.coverTransAngles[ approachtype ][ approachNumber ], 0 );
	}	

	forwardDir = anglestoforward( angle );
	rightDir = anglestoright( angle );
	
	if ( use_custom_coverset( approachtype ) )
	{
		animDist = length( self.customCoverEnterDist[ approachtype ][ approachNumber ] );
		forward = vector_multiply( forwardDir, self.customCoverEnterDist[ approachtype ][ approachNumber ][ 0 ] );
		right   = vector_multiply( rightDir, self.customCoverEnterDist[ approachtype ][ approachNumber ][ 1 ] );
	}
	else
	{
		forward = vector_multiply( forwardDir, anim.coverTransDist[ approachtype ][ approachNumber ][ 0 ] );
		right   = vector_multiply( rightDir, anim.coverTransDist[ approachtype ][ approachNumber ][ 1 ] );
	}

	return arrivalpoint - forward + right;
}

getArrivalPreStartPos( arrivalPoint, arrivalYaw, approachType, approachNumber )
{
	if( use_custom_coverset( approachtype ) )
	{			
		angle = ( 0, arrivalYaw - self.customCoverEnterAngles[ approachtype ][ approachNumber ], 0 );
	}
	else
	{
		angle = ( 0, arrivalYaw - anim.coverTransAngles[ approachtype ][ approachNumber ], 0 );
	}	

	forwardDir = anglestoforward( angle );
	rightDir = anglestoright( angle );

	if(use_custom_coverset( approachtype ))
	{
		forward = vector_multiply( forwardDir, self.customCoverTransPreDist[ approachtype ][ approachNumber ][ 0 ] );
		right   = vector_multiply( rightDir, self.customCoverTransPreDist[ approachtype ][ approachNumber ][ 1 ] );
	}
	else
	{
		forward = vector_multiply( forwardDir, anim.coverTransPreDist[ approachtype ][ approachNumber ][ 0 ] );
		right   = vector_multiply( rightDir, anim.coverTransPreDist[ approachtype ][ approachNumber ][ 1 ] );
	}	

	return arrivalpoint - forward + right;
}


checkCoverEnterPos( arrivalpoint, arrivalYaw, approachtype, approachNumber, arrivalFromFront )
{
	enterPos = getArrivalStartPos( arrivalPoint, arrivalYaw, approachType, approachNumber );
	self.coverEnterPos = enterPos;

	/#
	if ( debug_arrivals_on_actor() )
		thread debugLine( enterPos, arrivalpoint, ( 1, .5, .5 ), 1.5 );
	#/
	
	if ( level._newArrivals && approachNumber <= 6 && arrivalFromFront )
		return true;
		
	if ( !( self maymovefrompointtopoint( enterPos, arrivalpoint ) ) )
		return false;

	if ( approachNumber <= 6 || isdefined( anim.exposedTransition[ approachtype ] ) )
		return true;

	// if 7, 8, 9 direction, split up check into two parts of the 90 degree turn around corner
	// (already did the second part, from corner to node, now doing from start of enter anim to corner)

	originalEnterPos = getArrivalPreStartPos( enterPos, arrivalYaw, approachType, approachNumber );
	self.coverEnterPos = originalEnterPos;

	/#
	if ( debug_arrivals_on_actor() )
		thread debugLine( originalEnterPos, enterPos, ( 1, .5, .5 ), 1.5 );
	#/
	return( self maymovefrompointtopoint( originalEnterPos, enterPos ) );
}

use_custom_coverset( approachtype )
{
	if ( IsDefined( self.customCoverEnterTrans ) && IsDefined( self.customCoverEnterTrans[ approachtype ] ) )
	{
		return true;
	}
	else
	{
		return false;
	}
}

debug_arrivals_on_actor()
{
	 /#
	dvar = getdebugdvar( "debug_arrivals" );
	if ( dvar == "off" )
		return false;

	if ( dvar == "on" )
		return true;

	if ( int( dvar ) == self getentnum() )
		return true;
	#/

	return false;
}


debug_arrival( msg )
{
	if ( !debug_arrivals_on_actor() )
		return;
		
	if ( IsDefined( self.name ) ) 
	{
		msg = self.name + ": " + msg;
	}
	println( msg );
}

// --------------------------------------------------------------------------------
// ---- Cover Arrival/Exit Tool  ----
// --------------------------------------------------------------------------------

/#
fakeAiLogic()
{
	self.animType		= "default";
	self.a.script		= "move";
	self.a.pose			= "stand";
	self.a.prevPose		= "stand";
	self.weapon			= "ak47_sp";

	self.ignoreMe		= true;
	self.ignoreAll		= true;

	self AnimMode("nogravity");
	self ForceTeleport( level._player.origin + (0,0,-1000), self.origin );

	while( IsDefined(self) && IsAlive(self) )
	{
		wait(0.05);
	}
}

coverArrivalDebugTool()
{
	if ( isdefined( level.cover_arrival_debug_tool ) )
	{
		return;
	}

	level.cover_arrival_debug_tool = 1;

	wait 1;

	// same as nodeColorTable in pathnode.cpp
	nodeColors =  [];
	nodeColors["Cover Stand"]			=  (0, 0.54, 0.66);
	nodeColors["Cover Crouch"]			=  (0, 0.93, 0.72);
	nodeColors["Cover Crouch Window"]	=  (0, 0.7, 0.5);
	nodeColors["Cover Prone"]			=  (0, 0.6, 0.46);
	nodeColors["Cover Right"]			=  (0.85, 0.85, 0.1);
	nodeColors["Cover Left"]			=  (1, 0.7, 0);
	nodeColors["Cover Wide Right"]		=  (0.75, 0.75, 0);
	nodeColors["Cover Wide Left"]		=  (0.75, 0.53, 0.38);
	nodeColors["Conceal Stand"]			=  (0, 0, 1);
	nodeColors["Conceal Crouch"]		=  (0, 0, 0.75);
	nodeColors["Conceal Prone"]			=  (0, 0, 0.5);
	nodeColors["Turret"]				=  (0, 0.93, 0.72);
	nodeColors["Bad"]					=  (1, 0, 0);
	nodeColors["Poor"]					=  (1,0.5,0);
	nodeColors["Ok"]					=  (1, 1, 0);
	nodeColors["Good"]					=  (0, 1, 0);

	//wait_for_first_player();

	player = level._player;

	// same as PREDICTION_TRACE_MIN + AIPHYS_STEPSIZE and PREDICTION_TRACE_MAX in actor_navigation.cpp
	traceMin = (-15,-15,18);
	traceMax = (15,15,72);

	hudGood = newHudElem();
	hudGood.location = 0;
	hudGood.alignX = "left";
	hudGood.alignY = "middle";
	hudGood.foreground = 1;
	hudGood.fontScale = 1.3;
	hudGood.sort = 20;
	hudGood.x = 680;
	hudGood.y = 240;
	hudGood.og_scale = 1;
	hudGood.color = nodeColors["Good"];
	hudGood.alpha = 1;

	hudOk = newHudElem();
	hudOk.location = 0;
	hudOk.alignX = "left";
	hudOk.alignY = "middle";
	hudOk.foreground = 1;
	hudOk.fontScale = 1.3;
	hudOk.sort = 20;
	hudOk.x = 680;
	hudOk.y = 260;
	hudOk.og_scale = 1;
	hudOk.color = nodeColors["Ok"];
	hudOk.alpha = 1;

	hudPoor = newHudElem();
	hudPoor.location = 0;
	hudPoor.alignX = "left";
	hudPoor.alignY = "middle";
	hudPoor.foreground = 1;
	hudPoor.fontScale = 1.3;
	hudPoor.sort = 20;
	hudPoor.x = 680;
	hudPoor.y = 280;
	hudPoor.og_scale = 1;
	hudPoor.color = nodeColors["Poor"];
	hudPoor.alpha = 1;

	hudBad = newHudElem();
	hudBad.location = 0;
	hudBad.alignX = "left";
	hudBad.alignY = "middle";
	hudBad.foreground = 1;
	hudBad.fontScale = 1.3;
	hudBad.sort = 20;
	hudBad.x = 680;
	hudBad.y = 300;
	hudBad.og_scale = 1;
	hudBad.color = nodeColors["Bad"];
	hudBad.alpha = 1;

	hudTotal = newHudElem();
	hudTotal.location = 0;
	hudTotal.alignX = "left";
	hudTotal.alignY = "middle";
	hudTotal.foreground = 1;
	hudTotal.fontScale = 1.3;
	hudTotal.sort = 20;
	hudTotal.x = 680;
	hudTotal.y = 330;
	hudTotal.og_scale = 1;
	hudTotal.color = (1,1,1);
	hudTotal.alpha = 1;

	hudGoodText = newHudElem();
	hudGoodText.location = 0;
	hudGoodText.alignX = "right";
	hudGoodText.alignY = "middle";
	hudGoodText.foreground = 1;
	hudGoodText.fontScale = 1.3;
	hudGoodText.sort = 20;
	hudGoodText.x = 670;
	hudGoodText.y = 240;
	hudGoodText.og_scale = 1;
	hudGoodText.color = nodeColors["Good"];
	hudGoodText.alpha = 1;
	hudGoodText SetText("Good: ");

	hudOkText = newHudElem();
	hudOkText.location = 0;
	hudOkText.alignX = "right";
	hudOkText.alignY = "middle";
	hudOkText.foreground = 1;
	hudOkText.fontScale = 1.3;
	hudOkText.sort = 20;
	hudOkText.x = 670;
	hudOkText.y = 260;
	hudOkText.og_scale = 1;
	hudOkText.color = nodeColors["Ok"];
	hudOkText.alpha = 1;
	hudOkText SetText("Ok: ");

	hudPoorText = newHudElem();
	hudPoorText.location = 0;
	hudPoorText.alignX = "right";
	hudPoorText.alignY = "middle";
	hudPoorText.foreground = 1;
	hudPoorText.fontScale = 1.3;
	hudPoorText.sort = 20;
	hudPoorText.x = 670;
	hudPoorText.y = 280;
	hudPoorText.og_scale = 1;
	hudPoorText.color = nodeColors["Poor"];
	hudPoorText.alpha = 1;
	hudPoorText SetText("Poor: ");

	hudBadText = newHudElem();
	hudBadText.location = 0;
	hudBadText.alignX = "right";
	hudBadText.alignY = "middle";
	hudBadText.foreground = 1;
	hudBadText.fontScale = 1.3;
	hudBadText.sort = 20;
	hudBadText.x = 670;
	hudBadText.y = 300;
	hudBadText.og_scale = 1;
	hudBadText.color = nodeColors["Bad"];
	hudBadText.alpha = 1;
	hudBadText SetText("Bad: ");	

	hudLineText = newHudElem();
	hudLineText.location = 0;
	hudLineText.alignX = "left";
	hudLineText.alignY = "middle";
	hudLineText.foreground = 1;
	hudLineText.fontScale = 1.3;
	hudLineText.sort = 20;
	hudLineText.x = 630;
	hudLineText.y = 315;
	hudLineText.og_scale = 1;
	hudLineText.color = (1,1,1);
	hudLineText.alpha = 1;
	hudLineText SetText("------------------");

	hudTotalText = newHudElem();
	hudTotalText.location = 0;
	hudTotalText.alignX = "right";
	hudTotalText.alignY = "middle";
	hudTotalText.foreground = 1;
	hudTotalText.fontScale = 1.3;
	hudTotalText.sort = 20;
	hudTotalText.x = 670;
	hudTotalText.y = 330;
	hudTotalText.og_scale = 1;
	hudTotalText.color = (1,1,1);
	hudTotalText.alpha = 1;
	hudTotalText SetText("Total: ");

	badNode = undefined;

	fakeAi = undefined;

	while(1)
	{
		tool = getdvarint( "ai_debugCoverArrivalsTool");

		// check if there's a node selected in Radiant
		if( tool <= 0 && IsDefined(level.nodedrone) && IsDefined(level.nodedrone.currentnode) )
		{
			tool = 1;
		}

		if( tool <= 0 )
		{
			if( IsDefined(fakeAi) )
			{
				fakeAi Delete();
				fakeAi = undefined;
			}

			// hide the UI
			hudBad.alpha		= 0;
			hudPoor.alpha		= 0;
			hudOk.alpha			= 0;
			hudGood.alpha		= 0;
			hudTotal.alpha		= 0;
			hudBadText.alpha	= 0;
			hudPoorText.alpha	= 0;
			hudOkText.alpha		= 0;
			hudGoodText.alpha	= 0;
			hudLineText.alpha	= 0;
			hudTotalText.alpha	= 0;

			wait 0.2;
			continue;
		}

		// spawn the fakeAi
		if( !IsDefined(fakeAi) )
		{
			spawners = getSpawnerArray();

			for( i=0; i < spawners.size; i++ )
			{
				fakeAi = spawners[i] StalingradSpawn();

				if( IsDefined(fakeAi) )
				{
					spawners[0].count++;
					fakeAi AnimCustom( ::fakeAiLogic );
					break;
				}
			}

			if( !IsDefined(fakeAi) )
			{
				//iprintlnbold("no suitable spawners found in level");
				wait 0.2;
				continue;
			}
		}

		// show the UI
		hudBad.alpha		= 1;
		hudPoor.alpha		= 1;
		hudOk.alpha			= 1;
		hudGood.alpha		= 1;
		hudTotal.alpha		= 1;
		hudBadText.alpha	= 1;
		hudPoorText.alpha	= 1;
		hudOkText.alpha		= 1;
		hudGoodText.alpha	= 1;
		hudLineText.alpha	= 1;
		hudTotalText.alpha	= 1;

		numBad				= 0;
		numPoor				= 0;
		numOk				= 0;
		numGood				= 0;
		tracesThisFrame		= 0;
		renderedThisFrame	= 0;
		evaluatedThisframe	= 0;

		// find all cover node within given radius
		radius = getdvarfloat( "ai_debugCoverArrivalsToolRadius");
		nodes = GetNodesInRadiusSorted( player.origin, radius, 0, 128, "Cover" );

		// show the node selected in Radiant
		if( tool > 0 && IsDefined(level.nodedrone) && IsDefined(level.nodedrone.currentnode) )
		{
			nodes = [];
			nodes[0] = level.nodedrone.currentnode;
		}

		showNodes = getdvarint( "ai_debugCoverArrivalsToolShowNodes");

		totalNodes = 1;
		if( showNodes > 0 || nodes.size == 0 )
		{
			totalNodes = nodes.size;
		}

		fakeAi.cqbwalking	= false;
		fakeAi.weapon		= "ak47_sp";
		fakeAi.heat			= false;

		// set cqb/pistol
		toolType = getdvarint( "ai_debugCoverArrivalsToolType");

		if( toolType == 0 )
		{
			fakeAi.cqbwalking = false;
		}
		else if( toolType == 1 )
		{
			fakeAi.cqbwalking = true;
		}
		else if( toolType == 2 )
		{
			fakeAi.weapon = "m1911_sp";
		}

		// ALEXP_TODO: this is pretty useless.. need to do it off FPS
		// scale based on number of AI (more AI -> lower FPS)
		minAi = 5;
		maxAi = 15;
		nodesMin = 5;
		nodesMax = 30;

		allAi = GetAiArray(); //entsearch( level.CONTENTS_ACTOR, player.origin, 10000 );
		numAi = allAi.size;
		
		// clamp
		if( numAi < minAi )
		{
			numAi = minAi;
		}
		else if( numAi > maxAi )
		{
			numAi = maxAi;
		}

		maxNodesPerFrame = (numAi - minAi) / (maxAi - minAi);
		maxNodesPerFrame = (1-maxNodesPerFrame) * (nodesMax - nodesMin) + nodesMin;

		// how often to evaluate nodes (spread them out for optimization)
		frameInterval = int( ceil( totalNodes / maxNodesPerFrame ) );
		//println("interval: " + frameInterval + " nodes: " + maxNodesPerFrame + " ai: " + numAi);

		for( i=0; i < totalNodes && i < nodes.size; i++ )
		{
			node = nodes[i];

			// clear the cached data
			if( !IsDefined(node.tool) || node.tool != tool || !IsDefined(node.toolType) || node.toolType != toolType )
			{
				node.angleDeltaArray	= undefined;
				node.moveDeltaArray		= undefined;
				node.preMoveDeltaArray	= undefined;
				node.postMoveDeltaArray	= undefined;
				node.tool				= tool;
				node.toolType			= toolType;
			}

			assert( IsDefined(node) );
			if( !IsDefined(node) || node.type == "BAD NODE" || node.type == "Path" )
			{
				totalNodes++;
				continue;
			}
			else if( !IsDefined( anim.approach_types[node.type] ) )
			{
				totalNodes++;
				continue;
			}

			// skip node evaluation every few frames (PhysicsTrace is expensive)
			if( IsDefined(node.lastCheckedTime) && (gettime() - node.lastCheckedTime) < 50*frameInterval )
			{
				if( node.lastRatio == 0 )
				{
					numBad++;
				}
				else if( node.lastRatio < 0.5 )
				{
					numPoor++;
				}
				else if( node.lastRatio < 1.0 )
				{
					numOk++;
				}
				else
				{
					numGood++;
				}

				continue;
			}

			// limit the number of traces per frame
			if( evaluatedThisFrame > maxNodesPerFrame ) // 30 nodes
			{
				continue;
			}

			// use the the AI that's on the node if there is one
			testAi = fakeAi;
			/*nearAiArray = entsearch( level.CONTENTS_ACTOR, node.origin, 16 );

			if( nearAiArray.size > 0 )
			{
				testAi = nearAiArray[0];
			}*/

			renderNode = true;
			if( DistanceSquared(node.origin, player.origin) > 800*800 ) //|| renderedThisFrame*frameInterval > maxNodesPerFrame )
			{
				renderNode = false;
			}

			nodeColor = nodeColors["Good"];

			// find transition type
			//stance = node isNodeDontStand() && !node isNodeDontCrouch();
			//transType = anim.approach_types[node.type][stance];
			transType = fakeAi determineNodeApproachType( node );

			totalTransitions = 0;
			validTransitions = 0;

			/*animName = "arrive_" + transType;

			// exit support
			if( tool == 2 )
			{
				animName = "exit_" + transType;
			}

			if( fakeAi shouldDoCQBTransition( node, transType ) )
				animName = animName + "_cqb";*/

			// cache for performance
			if( !IsDefined(node.angleDeltaArray) )
			{
				if ( tool == 2 ) // Exit
				{
					node.angleDeltaArray = anim.coverExitAngles[ transType ];
				}
				else
				{
					node.angleDeltaArray = anim.coverTransAngles[ transType ];
				}
			}

			// go through all available transitions
			for( j=1; j <= 9; j++ )
			{
				if( IsDefined(node.angleDeltaArray[j]) )
				{
					totalTransitions++;

					lineColor = (0.5,0,0);

					approachIsGood = false;
					originalEnterPos = undefined;

					// final yaw at node
					approachFinalYaw = node.angles[1] + animscripts\cover_arrival::getNodeStanceYawOffset( transType );

					angle = (0, approachFinalYaw - node.angleDeltaArray[j], 0);

					// exits
					if( tool == 2 )
					{
						angle = (0, approachFinalYaw, 0 );
					}
			
					forwardDir = AnglesToForward( angle );
					rightDir = AnglesToRight( angle );

					// cache for performance
					if( !IsDefined(node.moveDeltaArray) )
					{
						if ( tool == 2 )
						{
							node.moveDeltaArray = anim.coverExitDist[ transType ];
						}
						else
						{
							node.moveDeltaArray = anim.coverTransDist[ transType ];
						}
					}

					enterPos = node.origin;

					forward = vector_multiply( forwardDir, node.moveDeltaArray[j][0] );
					right   = vector_multiply( rightDir, node.moveDeltaArray[j][1] );

					// start position of arrival animation
					if( tool == 1 ) // arrival
					{
						enterPos = node.origin - forward + right;
					}
					else
					{
						enterPos = node.origin + forward - right;
					}

					// check if the AI can move between the node and anim start pos or corner
					if( testAi MayMoveFromPointToPoint(node.origin, enterPos) )
					{
						approachIsGood = true;

						lineColor = (0,0.75,0);
					}

					if( renderNode )
					{
						line( node.origin, enterPos, lineColor, 1, 1, frameInterval );
					}
	
					// if 7, 8, 9 direction, split up check into two parts of the 90 degree turn around corner
					// (already did the second part, from corner to node, now doing from start of enter anim to corner)
					if( approachIsGood && j >= 7 && !isSubstr(transType, "exposed") )
					{
						originalEnterPos = enterPos;

						if( tool == 1 ) // arrival
						{
							if( !IsDefined(node.preMoveDeltaArray) )
							{
								node.preMoveDeltaArray = anim.coverTransPreDist[ transType ];//fakeAi preMoveDeltaArray( animName, "move" );
							}

							forward = vector_multiply( forwardDir, node.preMoveDeltaArray[j][0] );
							right   = vector_multiply( rightDir, node.preMoveDeltaArray[j][1] );

							originalEnterPos = enterPos - forward + right;
						}
						else // exit
						{
							if( !IsDefined(node.postMoveDeltaArray) )
							{
								node.postMoveDeltaArray = anim.coverExitPostDist[ transType ];//fakeAi postMoveDeltaArray( animName, "move" );
							}

							forward = vector_multiply( forwardDir, node.postMoveDeltaArray[j][0] );
							right   = vector_multiply( rightDir, node.postMoveDeltaArray[j][1] );

							originalEnterPos = enterPos + forward - right;
						}

						// check if the AI can move between the corner and anim start pos
						if( !testAi MayMoveFromPointToPoint(originalEnterPos, enterPos) )
						{
							approachIsGood = false;
							lineColor = (0.5,0,0);
						}

						if( renderNode )
						{
							line( originalEnterPos, enterPos, lineColor, 1, 1, frameInterval );
							print3d( originalEnterPos, j, lineColor, 1, 0.2, frameInterval );
						}
					}
					else if( renderNode )
					{
						print3d( enterPos, j, lineColor, 1, 0.2, frameInterval );
					}

					if( approachIsGood )
					{
						validTransitions++;
					}

					tracesThisFrame++;
				}
			}

			// assign categories based on number of valid transitions
			node.lastRatio = validTransitions / totalTransitions;
			if( node.lastRatio == 0 )
			{
				nodeColor = nodeColors["Bad"];
				numBad++;

				badNode = node;
			}
			else if( node.lastRatio < 0.5 )
			{
				nodeColor = nodeColors["Poor"];
				numPoor++;
			}
			else if( node.lastRatio < 1.0 )
			{
				nodeColor = nodeColors["Ok"];
				numOk++;
			}
			else
			{
				numGood++;
			}

			if( renderNode )
			{
				// render box, node type and node forward
				print3d( node.origin, node.type + " (" + transType + ")", nodeColor, 1, 0.35, frameInterval );
				box( node.origin, 16, node.angles[1], nodeColor, 1, 1, frameInterval );

				nodeForward = anglesToForward( node.angles );
				nodeForward = vector_multiply( nodeForward, 8 );
				line( node.origin, node.origin + nodeForward, nodeColor, 1, 1, frameInterval );

				renderedThisFrame++;
			}

			// save last time
			evaluatedThisFrame++;
			node.lastCheckedTime = gettime();
		}

		//println("evaluated: " + evaluatedThisFrame + " traced: " + tracesThisFrame + " rendered: " + renderedThisFrame);

		// render stats
		hudTotal	SetValue( numBad + numPoor + numOk + numGood );
		hudBad		SetValue( numBad );
		hudPoor		SetValue( numPoor );
		hudOk		SetValue( numOk );
		hudGood		SetValue( numGood );

		wait(0.05);
	}
}
#/