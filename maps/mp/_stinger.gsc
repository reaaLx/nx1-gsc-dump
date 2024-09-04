#include maps\mp\_utility;

InitStingerUsage()
{
	self.stingerStage = undefined;
	self.stingerTarget = undefined;
	self.stingerLockStartTime = undefined;
	self.stingerLostSightlineTime = undefined;
	
	self thread ResetStingerLockingOnDeath();
	level._stingerTargets = [];
}


ResetStingerLocking()
{
	if ( !IsDefined( self.stingerUseEntered ) )
		return;
	self.stingerUseEntered = undefined;

	self notify( "stop_javelin_locking_feedback" );
	self notify( "stop_javelin_locked_feedback" );

	self WeaponLockFree();
	InitStingerUsage();
}


ResetStingerLockingOnDeath()
{
	self endon( "disconnect" );

	self notify ( "ResetStingerLockingOnDeath" );
	self endon ( "ResetStingerLockingOnDeath" );

	for ( ;; )
	{
		self waittill( "death" );
		self ResetStingerLocking();
	}
}


StillValidStingerLock( ent )
{
	assert( IsDefined( self ) );

	if ( !IsDefined( ent ) )
		return false;
	if ( !(self WorldPointInReticle_Circle( ent.origin, 65, 85 )) )
		return false;

	if ( self.stingerTarget == level._ac130.planeModel && !isDefined( level._ac130player ) )
		return false;

	return true;
}


LoopStingerLockingFeedback()
{
	self endon( "stop_javelin_locking_feedback" );

	for ( ;; )
	{
		if ( isDefined( level._chopper ) && isDefined( level._chopper.gunner ) && isDefined( self.stingerTarget ) && self.stingerTarget == level._chopper.gunner )
			level._chopper.gunner playLocalSound( "missile_locking" );

		if ( isDefined( level._ac130player ) && isDefined( self.stingerTarget ) && self.stingerTarget == level._ac130.planeModel )
			level._ac130player playLocalSound( "missile_locking" );
		
		self playLocalSound( "stinger_locking" );
		self PlayRumbleOnEntity( "ac130_25mm_fire" );

		wait 0.6;
	}
}


LoopStingerLockedFeedback()
{
	self endon( "stop_javelin_locked_feedback" );

	for ( ;; )
	{
		if ( isDefined( level._chopper ) && isDefined( level._chopper.gunner ) && isDefined( self.stingerTarget ) && self.stingerTarget == level._chopper.gunner )
			level._chopper.gunner playLocalSound( "missile_locking" );

		if ( isDefined( level._ac130player ) && isDefined( self.stingerTarget ) && self.stingerTarget == level._ac130.planeModel )
			level._ac130player playLocalSound( "missile_locking" );

		self playLocalSound( "stinger_locked" );
		self PlayRumbleOnEntity( "ac130_25mm_fire" );

		wait 0.25;
	}
}


/#
DrawStar( point )
{
	Line( point + (10,0,0), point - (10,0,0) );
	Line( point + (0,10,0), point - (0,10,0) );
	Line( point + (0,0,10), point - (0,0,10) );
}
#/


LockSightTest( target )
{
	eyePos = self GetEye();
	
	if ( !isDefined( target ) ) //targets can disapear during targeting.
		return false;
	
	passed = BulletTracePassed( eyePos, target.origin, false, target );
	if ( passed )
		return true;

	front = target GetPointInBounds( 1, 0, 0 );
	passed = BulletTracePassed( eyePos, front, false, target );
	if ( passed )
		return true;

	back = target GetPointInBounds( -1, 0, 0 );
	passed = BulletTracePassed( eyePos, back, false, target );
	if ( passed )
		return true;

	return false;
}


StingerDebugDraw( target )
{
/#
	if ( GetDVar( "missileDebugDraw" ) != "1" )
		return;
	if ( !IsDefined( target ) )
		return;

	org = target.origin;
	DrawStar( org );
	org = target GetPointInBounds( 1, 0, 0 );
	DrawStar( org );
	org = target GetPointInBounds( -1, 0, 0 );
	DrawStar( org );
#/
}


SoftSightTest()
{
	LOST_SIGHT_LIMIT = 500;

	if ( self LockSightTest( self.stingerTarget ) )
	{
		self.stingerLostSightlineTime = 0;
		return true;
	}

	if ( self.stingerLostSightlineTime == 0 )
		self.stingerLostSightlineTime = getTime();

	timePassed = GetTime() - self.stingerLostSightlineTime;
	//PrintLn( "Losing sight of target [", timePassed, "]..." );

	if ( timePassed >= LOST_SIGHT_LIMIT )
	{
		//PrintLn( "Lost sight of target." );
		ResetStingerLocking();
		return false;
	}
	
	return true;
}

GetTargetList()
{
	targets = [];

	if ( level._teamBased )
	{
		if ( IsDefined( level._chopper ) && ( level._chopper.team != self.team || level._chopper.owner == self ) )
			targets[targets.size] = level._chopper;

		if ( IsDefined( level._raven ) && ( level._raven.team != self.team || level._raven.owner == self ) )
			targets[targets.size] = level._raven;

		if ( isDefined( level._ac130player ) && level._ac130player.team != self.team )
			targets[targets.size] = level._ac130.planemodel;
		
		if ( isDefined( level._harriers) )
		{
			foreach( harrier in level._harriers )
			{
				if ( isDefined( harrier ) && ( harrier.team != self.team || ( isDefined( harrier.owner ) && harrier.owner == self ) ) )
					targets[targets.size] = harrier;
			}
		}

		foreach( target_player in level._players )
		{
			if (( target_player.team != self.team ) && (target_player _hasPerk("specialty_juggersuit")))
			{
				targets[targets.size] = target_player;
			}
		}
	
		if( level._multiTeamBased )
		{
			//for all teams
			for( i = 0; i < level._teamNameList.size; i++ )
			{
				//that are not our team
				if( self.team != level._teamNameList[i] )
				{
					//does that team have any uav's
					if( level._UAVModels[level._teamNameList[i]].size )
					{
						//add each uav to the target list
						foreach ( UAV in level._UAVModels[level._teamNameList[i]] )
						{
							targets[targets.size] = UAV;
						}
					}
				}
			}
		}
		else if ( level._UAVModels[level._otherTeam[self.team]].size )
		{
			foreach ( UAV in level._UAVModels[level._otherTeam[self.team]] )
				targets[targets.size] = UAV;
		}

		if ( isDefined( level._littleBird ) )
		{
			foreach ( bird in level._littleBird )
			{
				if ( !isDefined( bird ) )
					continue;
				
				if ( self.team != bird.owner.team || self == bird.owner )
				targets[targets.size] = bird;
			}
		}

	}
	else
	{
		if ( IsDefined( level._chopper ) && ( level._chopper.owner != self ) ) ///check for teams
			targets[targets.size] = level._chopper;

		if ( isDefined( level._ac130player ) )
			targets[targets.size] = level._ac130.planemodel;
		
		if ( isDefined( level._harriers) )
		{
			foreach( harrier in level._harriers )
			{
				if ( isDefined( harrier ) )
					targets[targets.size] = harrier;
			}
		}

		foreach( target_player in level._players )
		{
			if (( target_player != self ) && (target_player _hasPerk("specialty_juggersuit")))
			{
				targets[targets.size] = target_player;
			}
		}

		if ( level._UAVModels.size )
		{
			foreach ( ownerGuid, UAV in level._UAVModels )
			{
				if ( isDefined( UAV.owner ) && UAV.owner == self )
					continue;
					
				targets[targets.size] = UAV;
			}
		}
	}
	
	return targets;
}


StingerUsageLoop()
{
	self endon("death");
	self endon("disconnect");

	LOCK_LENGTH = 1000;

	InitStingerUsage();

	for( ;; )
	{
		wait 0.05;

		weapon = self getCurrentWeapon();
		
		if ( weapon != "stinger_mp" && weapon != "at4_mp" )
		{
			ResetStingerLocking();
			continue;
		}

		if ( self PlayerADS() < 0.95 )
		{
			ResetStingerLocking();
			continue;
		}

		self.stingerUseEntered = true;

		if ( !IsDefined( self.stingerStage ) )
			self.stingerStage = 0;

		StingerDebugDraw( self.stingerTarget );

		if ( self.stingerStage == 0 )  // searching for target
		{
			targets = GetTargetList();
			if ( targets.size == 0 )
				continue;

			targetsInReticle = [];
			foreach ( target in targets )
			{
				if ( !isDefined( target ) )
					continue;
				
				insideReticle = self WorldPointInReticle_Circle( target.origin, 65, 75 );
				
				if ( insideReticle )
					targetsInReticle[targetsInReticle.size] = target;
			}
			if ( targetsInReticle.size == 0 )
				continue;

			sortedTargets = SortByDistance( targetsInReticle, self.origin );
			if ( !( self LockSightTest( sortedTargets[0] ) ) )
				continue;

			//PrintLn( "Found a target to lock to..." );
			thread LoopStingerLockingFeedback();
			self.stingerTarget = sortedTargets[0];
			self.stingerLockStartTime = GetTime();
			self.stingerStage = 1;
			self.stingerLostSightlineTime = 0;
		}

		if ( self.stingerStage == 1 )  // locking on to a target
		{
			if ( !(self StillValidStingerLock( self.stingerTarget )) )
			{
				//PrintLn( "Failed to get lock." );
				ResetStingerLocking();
				continue;
			}

			passed = SoftSightTest();
			if ( !passed )
				continue;

			timePassed = getTime() - self.stingerLockStartTime;
			//PrintLn( "Locking [", timePassed, "]..." );
			if( self _hasPerk( "specialty_fasterlockon" ))
			{
				if( timePassed < ( LOCK_LENGTH * 0.5 ))
				{
					continue;
				}
			}
			else
			{
				if ( timePassed < LOCK_LENGTH )
					continue;
			}

			self notify( "stop_javelin_locking_feedback" );
			thread LoopStingerLockedFeedback();

			//PrintLn( "Locked!");
			if ( self.stingerTarget.model == "vehicle_av8b_harrier_jet_mp"  || self.stingerTarget.model == "vehicle_little_bird_armed" )
			{
				self WeaponLockFinalize( self.stingerTarget );
			}
			else if ( IsPlayer( self.stingerTarget ) )
			{
				self WeaponLockFinalize( self.stingerTarget, (0,0,32) );
			}
			else
			{
				self WeaponLockFinalize( self.stingerTarget, (100,0,-32) );
			}
			
			self.stingerStage = 2;		
		}

		if ( self.stingerStage == 2 )  // target locked
		{
			passed = SoftSightTest();
			if ( !passed )
				continue;

			if ( !(self StillValidStingerLock( self.stingerTarget )) )
			{
				//PrintLn( "Gave up lock." );
				ResetStingerLocking();
				continue;
			}
		}
	}
}