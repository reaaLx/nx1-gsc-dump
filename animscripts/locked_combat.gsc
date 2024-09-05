//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Actor locked combat system					                **
//    Created: 7/13/11 - John Webb		                                    **
//                                                                          **
//****************************************************************************

#include common_scripts\utility;
#include animscripts\combat_utility;
#include animscripts\utility;

#using_animtree( "generic_human" );
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_combat()
{
	self notify( "killanimscript" );

	self endon( "death" );
	self endon( "killanimscript" );
	self endon( "locked_combat_transition" );
	animscripts\utility::initialize( "locked_combat" );
	self.noRunNGun = true;
	self.dontMelee = true;
	self.disableExits = true;
	self.disableArrivals = true;
	self.disableBulletWhizbyReaction = true;
	self.keepClaimedNode = false;
	self.combatMode = "no_cover";

	self animmode( "point_relative" );

	// Setup the locked covernode
	self locked_setup_covernode( level._locked_combat.nodes[ self.current_node_key ] );

	// Run the cover behavior
	while ( 1 )
	{
		self [[ level._locked_combat.coverTypes[ self.coverType ].behavior_func ]]();
		wait 0.05;
	}

}

locked_setup_covernode( node )
{
    self.coverNode = node;
    self.coverType = self.coverNode.type;
	self.a.coverMode = "hide";
	self.a.atConcealmentNode = false;
	self.locked_combat = true;
	self.fixed_node = true; // Need to use something else
	self.a.pose = "stand";
	self.fixedNode = false;

	AssertEx( isdefined( level._locked_combat.coverTypes[ self.coverType ] ), "Locked Combat Cover Type " + self.coverType + " has not been initialized." );
	
	self.hideYawOffset = 0;
	self.a.leanAim = undefined;
	self [[ level._locked_combat.coverTypes[ self.coverType ].init_func ]]();

	locked_combat_orient( self.hideYawOffset );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_combat_orient( nodeAngleOffset )
{
	node = self.coverNode;
	self orientmode( "face angle", self.angles[1] );
	//self animmode( "point_relative" );

	relYaw = AngleClamp180( self.angles[1] - ( node.angles[1] + nodeAngleOffset ) );

	self thread maintain_orientation();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
maintain_orientation()
{
	self endon( "killanimscript" );
	while ( 1 )
	{
		self OrientMode( "face angle", self.coverNode.angles[ 1 ] );
		wait 0.05;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
get_valid_peekouts()
{
	modes = [];
	modes[ modes.size ] = "stand";
	modes[ modes.size ] = "crouch";
	return modes;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_popUpAndShoot()
{
	self.keepClaimedNodeIfValid = true;

	locked_combat_orient( self.hideYawOffset );

	if ( !locked_pop_up() )
		return false;

	locked_shoot();

	self endFireAndAnimIdleThread();

	locked_go_to_hide();

	self.coverCrouchLean_aimmode = undefined;
	self.keepClaimedNodeIfValid = false;

	return true;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_shoot()
{
	self endon( "return_to_cover" );

	self maps\_gameskill::didSomethingOtherThanShooting();

	while ( 1 )
	{
		if ( isdefined( self.shouldReturnToCover ) )
			break;

		if ( !isdefined( self.shootPos ) ) 
		{
			assert( !isdefined( self.shootEnt ) );
			// give shoot_behavior a chance to iterate
			self waittill( "do_slow_things" );
			waittillframeend;
			if ( isdefined( self.shootPos ) )
			{
				continue;
			}
			break;
		}		

		if ( !self.bulletsInClip )
			break;

		self thread aimIdleThread();
		//println( "Shooting" );
		shootUntilShootBehaviorChange();

		self clearAnim( %add_fire, .2 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_go_to_hide()
{
	self notify( "return_to_cover" );

	self.changingCoverPos = true; 
	self notify( "done_changing_cover_pos" );

	self endAimIdleThread();

	animRate = 1.0;
	//animRate = pop_up_and_hide_speed();
	animation = animArray( self.a.coverMode + "_2_hide" );

	self clearAnim( %body, 0.2 );
	if ( isdefined( self.current_node_key ) )
	{
		node = level._locked_combat.nodes[ self.current_node_key ];
		assert( isdefined( node ) );
		self animrelative( "go_to_hide", self.origin, self.angles, animation );
	}
	
	//println( "Returning to hide" );	

	self animscripts\shared::DoNoteTracks( "go_to_hide" );

	self StopAnimScripted();

	self.a.coverMode = "hide";
	self animmode( "point_relative" );

	if ( self.coverType == "stand" )
		self.a.special = "cover_stand";
	else
		self.a.special = "cover_crouch";

	self.changingCoverPos = false;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_pop_up()
{
	assert( !isdefined( self.a.coverMode ) || self.a.coverMode == "hide" );

	newCoverMode = self [[ level._locked_combat.coverTypes[ self.coverType ].cover_mode_func ]]();

	if ( !isdefined( newCoverMode ) )
	{
		//println( "No valid coverMode found" );
		return false;
	}
	//println( "Entering coverMode " + newCoverMode );

	timeleft = .1;
	
	popupAnim = animArray( "hide_2_" + newCoverMode );

	//if ( !self mayMoveToPoint( getAnimEndPos( popupAnim ) ) )
		//return false;

	if ( self.script == "cover_crouch" && newCoverMode == "lean" )
		self.coverCrouchLean_aimmode = true;

	self.a.special = "none";
	self.specialDeathFunc = undefined;
	
	if ( self.coverType == "stand" )
		self.a.special = "cover_stand_aim";
	else if ( self.coverType == "crouch" )
		self.a.special = "cover_crouch_aim";		
		
	self.changingCoverPos = true; 
	self notify( "done_changing_cover_pos" );

	self animmode( "point_relative" );

	animRate = animscripts\cover_wall::pop_up_and_hide_speed();

	node = level._locked_combat.nodes[ self.current_node_key ];
	assert( isdefined( node ) );
	offset_angles = node.angles + ( 0, self.hideYawOffset, 0 );

	self animrelative( "pop_up", node.origin, offset_angles, popUpAnim );
	
	self thread animscripts\cover_wall::DoNoteTracksForPopup( "pop_up" );

	if ( animHasNoteTrack( popupAnim, "start_aim" ) )
	{
		// Store our final step out angle so that we may use it when doing track loop aiming
		self.stepOutYaw = self.angles[1] + getAngleDelta( popupAnim, 0, 1 );

		self waittillmatch( "pop_up", "start_aim" );
		timeleft = getAnimLength( popupAnim ) / animRate * ( 1 - self getAnimTime( popupAnim ) );
	}
	else
	{
		self waittillmatch( "pop_up", "end" );
		timeleft = .1;
	}

	//self clearAnim( %cover, timeleft + 0.05 );

	self.a.coverMode = newCoverMode;
	self.a.prevAttack = newCoverMode;

	self locked_setup_additive_aim( timeleft );
	self thread animscripts\shared::trackShootEntOrPos();

	wait( timeleft );

	self StopAnimScripted();

	//self clearAnim( popupAnim, 0.1 );
	
	if ( self isSniper() )
	{
		thread animscripts\shoot_behavior::sniper_glint_behavior();
	}

	self.changingCoverPos = false;
	self.coverPosEstablishedTime = gettime();

	self notify( "stop_popup_donotetracks" );

	return true;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_setup_additive_aim( transTime )
{
	if ( self.a.coverMode == "left" || self.a.coverMode == "right" )
		aimCoverMode = "crouch";
	else
		aimCoverMode = self.a.coverMode;

	self setAnimKnobAll( animArray( aimCoverMode + "_aim" ), %body, 1, transTime );
	self setanimlimited( animArray( aimCoverMode + "_aim2" ), 1, 0 );
	self setanimlimited( animArray( aimCoverMode + "_aim4" ), 1, 0 );
	self setanimlimited( animArray( aimCoverMode + "_aim6" ), 1, 0 );
	self setanimlimited( animArray( aimCoverMode + "_aim8" ), 1, 0 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_aim_idle()
{
	self endon( "killanimscript" );
	self endon( "end_aim_idle_thread" );
	
	mode = self.a.coverMode;

	if ( isdefined( self.a.aimIdleThread ) )
		return;
	self.a.aimIdleThread = true;
	
	// wait a bit before starting idle since firing will end the idle thread
	wait 0.1;
	
	// this used to be setAnim, but it caused problems with turning on its parent nodes when they were supposed to be off (like during pistol pullout).
	self setAnimLimited( %add_idle, 1, .2 );
	
	for ( i = 0; ; i++ )
	{
		flagname = "idle" + i;
		idleanim = animArrayPickRandom( mode + "_idle" );		
		self setFlaggedAnimKnobLimitedRestart( flagname, idleanim, 1, 0.2 );		
		self waittillmatch( flagname, "end" );
	}
	
	self clearAnim( %add_idle, .1 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_corner_think( direction, nodeAngleOffset )
{
	self.animArrayFuncs[ "exposed" ][ "stand" ] = animscripts\corner::set_standing_animarray_aiming;
	self.animArrayFuncs[ "exposed" ][ "crouch" ] = animscripts\corner::set_crouching_animarray_aiming;

	if ( IsDefined( self.customAnimFunc ) && IsDefined( self.customAnimFunc[ "corner_exposed" ] ) )
	{
		if ( IsDefined( self.customAnimFunc[ "corner_exposed" ][ "stand" ] ) )
		{
			self.animArrayFuncs[ "exposed" ][ "stand" ] = self.customAnimFunc[ "corner_exposed" ][ "stand" ];
		}

		if ( IsDefined( self.customAnimFunc[ "corner_exposed" ][ "crouch" ] ) )
		{
			self.animArrayFuncs[ "exposed" ][ "crouch" ] = self.customAnimFunc[ "corner_exposed" ][ "crouch" ];
		}
	}	

	self.cornerDirection = direction;
	self.a.cornerMode = "unknown";

	self.a.aimIdleThread = undefined;

	animscripts\cover_behavior::turnToMatchNodeDirection( nodeAngleOffset );

	animscripts\corner::set_corner_anim_array();
	
	self.isshooting = false;
	self.tracking = false;

	self.cornerAiming = false;

	animscripts\shared::setAnimAimWeight( 0 );

	self.haveGoneToCover = false;

	behaviorCallbacks = spawnstruct();

	if ( !self.fixedNode )
		behaviorCallbacks.moveToNearByCover	 = animscripts\cover_behavior::moveToNearbyCover;
	
	behaviorCallbacks.mainLoopStart			 = ::locked_corner_mainLoopStart;
	behaviorCallbacks.reload				 = animscripts\corner::cornerReload;
	behaviorCallbacks.leaveCoverAndShoot	 = animscripts\corner::stepOutAndShootEnemy;
	behaviorCallbacks.look					 = animscripts\corner::lookForEnemy;
	behaviorCallbacks.fastlook				 = animscripts\corner::fastlook;
	behaviorCallbacks.idle					 = animscripts\corner::idle;
	behaviorCallbacks.grenade				 = ::return_false;
	behaviorCallbacks.grenadehidden			 = ::return_false;
	behaviorCallbacks.blindfire				 = animscripts\corner::blindfire;

	animscripts\cover_behavior::main( behaviorCallbacks );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_corner_mainLoopStart()
{
	desiredStance = "stand";
	
	 /#
	if ( getdvarint( "scr_cornerforcecrouch" ) == 1 )
		desiredStance = "crouch";
	#/

   	self animscripts\corner::transitionToStance( desiredStance );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_moveToNearbyCover()
{
	return false;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_reload()
{
	return Reload( 2.0, animArray( "reload" ) );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_look( lookTime )
{
	if ( !isdefined( self.a.array[ "hide_to_look" ] ) )
		return false;

	if ( !locked_peekOut() )
		return false;

	animscripts\shared::playLookAnimation( animArray( "look_idle" ), lookTime );// TODO: replace

	lookanim = undefined;
	if ( self isSuppressedWrapper() )
		lookanim = animArray( "look_to_hide_fast" );
	else
		lookanim = animArray( "look_to_hide" );

	self setflaggedanimknoballrestart( "looking_end", lookanim, %body, 1, .1 );
	animscripts\shared::DoNoteTracks( "looking_end" );

	return true;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_peekOut()
{
	if ( isdefined( self.coverNode.script_dontpeek ) )
		return false;	

	// assuming no delta, so no maymovetopoint check

	self setFlaggedAnimKnobAll( "looking_start", animArray( "hide_to_look" ), %body, 1, .2 );
	animscripts\shared::DoNoteTracks( "looking_start" );

	return true;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_fastlook()
{
	self setFlaggedAnimKnobAllRestart( "look", animArrayPickRandom( "look" ), %body, 1, .1 );
	self animscripts\shared::DoNoteTracks( "look" );

	return true;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_idle()
{
	self endon( "end_idle" );
	
	while ( 1 )
	{
		useTwitch = ( randomint( 2 ) == 0 && animArrayAnyExist( "hide_idle_twitch" ) );
		if ( useTwitch )
			idleanim = animArrayPickRandom( "hide_idle_twitch" );
		else
			idleanim = animarray( "hide_idle" );

		locked_playIdleAnimation( idleAnim, useTwitch );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_playIdleAnimation( idleAnim, needsRestart )
{
	if ( needsRestart )
		self setFlaggedAnimKnobAllRestart( "idle", idleAnim, %body, 1, 0.25, 1 );
	else
		self setFlaggedAnimKnobAll( "idle", idleAnim, %body, 1, 0.25, 1 );

	self.a.coverMode = "hide";

	self animscripts\shared::DoNoteTracks( "idle" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_flinch()
{
	if ( !animArrayAnyExist( "hide_idle_flinch" ) )
		return false;

	forward = anglesToForward( self.angles );
	stepto = self.origin + vector_multiply( forward, -16 );

	if ( !self mayMoveToPoint( stepto ) )
		return false;

	self animmode( "point_relative" );
	self.keepClaimedNodeIfValid = true;

	flinchanim = animArrayPickRandom( "hide_idle_flinch" );
	locked_playIdleAnimation( flinchanim, true );

	self.keepClaimedNodeIfValid = false;

	return true;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_blindfire()
{
	if ( !animArrayAnyExist( "blind_fire" ) )
		return false;

	self animMode( "point_relative" );
	self.keepClaimedNodeIfValid = true;

	self setFlaggedAnimKnobAllRestart( "blindfire", animArrayPickRandom( "blind_fire" ), %body, 1, 0.2, 1 );
	self animscripts\shared::DoNoteTracks( "blindfire" );

	self.keepClaimedNodeIfValid = false;

	return true;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
return_false( param1 )
{
	return false;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
locked_grenade( throwAt, safe )
{
	if ( !isPlayer( throwAt ) ) // Only throw grenades at players for now
	{
		return false;
	}

	if ( isdefined( self.dontEverShoot ) || isdefined( throwAt.dontAttackMe ) )
		return false;

	// We want to only throw locked_combat grenades if the player is trying to hide
	if ( !(throwAt should_grenade_player()) )
	{
		return false;
	}

	theanim = undefined;
	if ( isdefined( safe ) && safe )
		theanim = animArrayPickRandom( "grenade_safe" );
	else
		theanim = animArrayPickRandom( "grenade_exposed" );

	threwGrenade = TryGrenade( throwAt, theanim );

	return threwGrenade;
}

should_grenade_player()
{
	assert( isPlayer( self ) );
	assert( isDefined( self.locked_shouldGrenade ) );
	return self.locked_shouldGrenade;
}
