#include animscripts\SetPoseMovement;
#include animscripts\Utility;
#include common_scripts\Utility;
#using_animtree( "generic_human" );

main()
{
	self endon( "killanimscript" );
	animscripts\utility::initialize( "reactions" );
	
	self newEnemySurprisedReaction();
}

getReactionAnim( name )
{
	if ( IsDefined( self.customCoverReactions ) && IsDefined( self.customCoverReactions[ name ] ) )
	{
		return self.customCoverReactions[ name ];
	}
	else
	{
		return anim.reactionAnimArray[ name ];
	}
}


///////////////////////////////////////////////////////////////////////////
// 
///////////////////////////////////////////////////////////////////////////
reactionsCheckLoop()
{	
	self thread bulletWhizbyCheckLoop();
}


///////////////////////////////////////////////////////////////////////////
// death reactions
///////////////////////////////////////////////////////////////////////////
/* disabled for now since the animations aren't in common csv

MoveDeathReaction()
{
	// Decide what pose to use
	desiredPose = self animscripts\utility::choosePose();
    
    if ( desiredPose == "stand" )
	{
		deathAnim = getDeathReactionAnim();
		DoDeathReactionAnim( deathAnim );
	}
}

ExposedCombatDeathReaction()
{
	// Decide what pose to use
	desiredPose = self animscripts\utility::choosePose();
    
    if ( desiredPose == "stand" )
	{
		deathAnim = getDeathReactionAnim();
		DoDeathReactionAnim( deathAnim );
	}
}

DoDeathReactionAnim( deathAnim )
{
	self endon( "movemode" );

	rate = self.moveplaybackrate;

	self setFlaggedAnimKnobAll( "deathanim", deathAnim, %body, 1, 1, rate, true );

	self animscripts\shared::DoNoteTracks( "deathanim" );
	self.deathTeamate = false;
}

getDeathReactionAnim()
{
    if ( self.deathTeamateReaction == "back" )
        return %run_reaction_180;
    else if ( self.deathTeamateReaction == "left" )
        return %run_reaction_L_quick;
    else if ( self.deathTeamateReaction == "right" )
        return %run_reaction_R_quick;
}

deathCheck()
{
	self endon( "killanimscript" );
	
    self.deathTeamateReaction = "none";
    self.deathTeamate = false;

	minDeathDistance = 100;
	maxDeathDistance = 500;
	minGoalDistance = 200;
	maxTurnAngle = 135;
	minTurnAngle = 10;
	
    self AddAIEventListener( "death" );

	for ( ;; )
	{
	    self waittill( "ai_event", event, originator, position );
	    if ( event != "death" )
			continue;
			
	    deathDirection = position - self.origin;
	    deathDistance = Length( deathDirection );
	    if ( deathDistance >= minDeathDistance && deathDistance <= maxDeathDistance )
	    {
    	    goalDirection = self.goalpos - self.origin;
    	    goalDistance = Length( goalDirection );
    	    if ( goalDistance >= minGoalDistance )
    	    {
        	    goalAngles = VectorToAngles( goalDirection );
        	    deltaAngles = Abs( self.angles[1] - goalAngles[1] );
        	    if ( deltaAngles > minTurnAngle )
        	    {
            	    if ( deltaAngles > maxTurnAngle )
            	        self.deathTeamateReaction = "back";
            	    else if ( self.angles[1] > goalAngles[1] )
            	        self.deathTeamateReaction = "left";
            	    else
            	        self.deathTeamateReaction = "right";
            	    
            	    self.deathTeamate = true;
        	    }
    	    }
	    }
	}
}

*/

canReactAgain()
{
	return ( !isdefined( self.lastReactTime ) || gettime() - self.lastReactTime > 2000 );
}

///////////////////////////////////////////////////////////////////////////
// bullet whizby reaction
///////////////////////////////////////////////////////////////////////////

bulletWhizbyReaction()
{
	self endon( "killanimscript" );

	self.lastReactTime = gettime();
	self.a.movement = "stop";
	
	enemyNear = ( isDefined( self.whizbyEnemy ) && distanceSquared( self.origin, self.whizbyEnemy.origin ) < 400 * 400 );

	self animmode( "gravity" );		
	self orientmode( "face current" );

	// react and go to prone
	if ( enemyNear || cointoss() )
	{
		self clearanim( %root, 0.1 );
		
		reactionAnims = getReactionAnim( "wizby_idle" );

		reaction = reactionAnims[ randomint( reactionAnims.size ) ];

		if ( enemyNear )
			waitTime = 1 + randomfloat( 0.5 );
		else
			waitTime = 0.2 + randomfloat( 0.5 );

		self setFlaggedAnimKnobRestart( "reactanim", reaction, 1, 0.1, 1 );
		self animscripts\shared::DoNoteTracksForTime( waitTime, "reactanim" );

		self clearanim( %root, 0.1 );
		
		if ( !enemyNear && self.stairsState == "none" )
		{
			rate = 1 + randomfloat( 0.2 );
			
			reactionAnims = getReactionAnim( "wizby_dive" );
		
			diveAnim = reactionAnims[ randomint( reactionAnims.size ) ];

			self setFlaggedAnimKnobRestart( "dive", diveAnim, 1, 0.1, rate );
			self animscripts\shared::DoNoteTracks( "dive" );
		}
	}
	else	// crouch then handsignal or turn
	{
		wait randomfloat( 0.2 );
		
		rate = 1.2 + randomfloat( 0.3 );
		
		if ( self.a.pose == "stand" )
		{
			self clearanim( %root, 0.1 );
			reactionAnim = getReactionAnim( "wizby_crouch" );
			self setFlaggedAnimKnobRestart( "crouch", reactionAnim, 1, 0.1, rate );
			self animscripts\shared::DoNoteTracks( "crouch" );
		}

		forward = anglesToForward( self.angles );

		if ( isDefined( self.whizbyEnemy ) )
			dirToEnemy = vectorNormalize( self.whizbyEnemy.origin - self.origin );
		else
			dirToEnemy = forward;

		if ( vectordot( dirToEnemy, forward ) > 0 )
		{
			reactionAnims = getReactionAnim( "wizby_twitch" );
			twitchAnim = reactionAnims[ randomint( reactionAnims.size ) ];
		
			self clearanim( %root, 0.1 );
			self setFlaggedAnimKnobRestart( "twitch", twitchAnim, 1, 0.1, 1 );
			self animscripts\shared::DoNoteTracks( "twitch" );			
			
			//if ( cointoss() )
			//	self handsignal( "go" );
		}
		else
		{
			reactionAnims = getReactionAnim( "wizby_turn" );
			turnAnim = reactionAnims[ randomint( reactionAnims.size ) ];
			
			self clearanim( %root, 0.1 );
			self setFlaggedAnimKnobRestart( "turn", turnAnim, 1, 0.1, 1 );
			self animscripts\shared::DoNoteTracks( "turn" );
		}
	}
	
	self clearanim( %root, 0.1 );
	self.whizbyEnemy = undefined;
	self animmode( "normal" );
	self orientmode( "face default" );		
}


bulletWhizbyCheckLoop()
{
	self endon( "killanimscript" );
	
	if ( isdefined( self.disableBulletWhizbyReaction ) )
		return;

	while ( 1 )
	{
		self waittill( "bulletwhizby", shooter );

		if ( !isdefined( shooter.team ) || self.team == shooter.team )
			continue;
			
		if ( isdefined( self.coverNode ) || isdefined( self.ambushNode ) )
			continue;
			
		if ( self.a.pose != "stand" )
			continue;

		if ( !canReactAgain() )
			continue;
			
		self.whizbyEnemy = shooter;
		self animcustom( ::bulletWhizbyReaction );
	}
}


///////////////////////////////////////////////////////////////////////////
// surprised by new enemy reaction
///////////////////////////////////////////////////////////////////////////

clearLookAtThread()
{
	self endon( "killanimscript" );

	wait 0.3;
	self setLookAtEntity();
}


getNewEnemyReactionAnim()
{
	reactAnim = undefined;
	
	if ( self nearClaimNodeAndAngle() && isdefined( anim.reactionAnimArray[ self.prevScript ] ) )
	{
		nodeForward = anglesToForward( self.node.angles );
		dirToReactionTarget = vectorNormalize( self.reactionTargetPos - self.origin );
		
		if ( vectorDot( nodeForward, dirToReactionTarget ) < -0.5 )
		{
			self orientmode( "face current" );
			reactionAnims = getReactionAnim( self.prevScript );
			reactAnim = reactionAnims[ randomint( reactionAnims.size ) ];
		}
	}
	
	if ( !isdefined( reactAnim ) )
	{
		if ( isdefined( self.enemy ) && distanceSquared( self.enemy.origin, self.reactionTargetPos ) < 256 * 256 )
			self orientmode( "face enemy" );
		else
			self orientmode( "face point", self.reactionTargetPos );

		if ( self.a.pose == "crouch" )
		{
			dirToReactionTarget = vectorNormalize( self.reactionTargetPos - self.origin );
			forward = anglesToForward( self.angles );
			if ( vectorDot( forward, dirToReactionTarget ) < -0.5 )
			{
				self orientmode( "face current" );	
				reactionAnims = getReactionAnim( "crouch" );			
				return reactionAnims[ randomint( reactionAnims.size ) ];
			}
		}

		reactionAnims = getReactionAnim( "stand" );
		reactAnim = reactionAnims[ randomint( reactionAnims.size ) ];
	}

	return reactAnim;
}


stealthNewEnemyReactAnim()
{
	self clearanim( %root, 0.2 );

	if ( randomint( 4 ) < 3 )
	{
		self orientmode( "face enemy" );
		self setFlaggedAnimKnobRestart( "reactanim", getReactionAnim( "stealth" ), 1, 0.2, 1 );
		time = getAnimLength( getReactionAnim( "stealth" ) );
		self animscripts\shared::DoNoteTracksForTime( time * 0.8, "reactanim" );	

		self orientmode( "face current" );
	}
	else
	{
		self orientmode( "face enemy" );
		self setFlaggedAnimKnobRestart( "reactanim", getReactionAnim( "stealth_backpedal" ), 1, 0.2, 1 );
		time = getAnimLength( getReactionAnim( "stealth_backpedal" ) );
		self animscripts\shared::DoNoteTracksForTime( time * 0.8, "reactanim" );	

		self orientmode( "face current" );

		self clearanim( %root, 0.2 );
		self setFlaggedAnimKnobRestart( "reactanim", getReactionAnim( "stealth_backpedal2" ), 1, 0.2, 1 );
		self animscripts\shared::DoNoteTracks( "reactanim" );	
	}
}


newEnemyReactionAnim()
{
	self endon( "death" );
	self endon( "endNewEnemyReactionAnim" );
	
	self.lastReactTime = gettime();
	self.a.movement = "stop";
	
	if ( isdefined( self._stealth ) && self.alertLevel != "combat" )
	{
		stealthNewEnemyReactAnim();
	}
	else
	{
		reactAnim = self getNewEnemyReactionAnim();
	
		self clearanim( %root, 0.2 );
		self setFlaggedAnimKnobRestart( "reactanim", reactAnim, 1, 0.2, 1 );
		self animscripts\shared::DoNoteTracks( "reactanim" );
	}

	self notify( "newEnemyReactionDone" );
}


newEnemySurprisedReaction()
{
	self endon( "death" );
	
	if ( isdefined( self.disableReactionAnims ) )
		return;		

	if ( !canReactAgain() )
		return;
		
	if ( self.a.pose == "prone" || isdefined( self.a.onback ) )
		return;

	self animmode( "gravity" );
	
	if ( isdefined( self.enemy ) )
		newEnemyReactionAnim();
}
