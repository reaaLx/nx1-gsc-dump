#include common_scripts\utility;
#include animscripts\utility;
#include animscripts\combat_utility;
#include maps\_utility;

#using_animtree( "generic_human" );


//
//		 Damage Yaw
//
//           front
//        /----|----\
//       /    180    \
//      /\     |     /\
//     / -135  |  135  \
//     |     \ | /     |
// left|-90----+----90-|right
//     |     / | \     |
//     \  -45  |  45   /
//      \/     |     \/
//       \     0     / 
//        \----|----/
//           back

main()
{
	self endon( "killanimscript" );

	// make sure the guy doesn't talk after death
	self stopsoundchannel( "voice" );
	changeTime = 0.3;
	self clearanim( %scripted_talking, 				changeTime );
	
	// don't abort at this point unless you're going to play another animation!
	// just playing ragdoll isn't sufficient because sometimes ragdoll fails, and then
	// you'll just have a corpse standing around in limbo.
	
	if ( self.a.nodeath == true )
		return;

	if ( isdefined( self.deathFunction ) )
	{
		result = self [[ self.deathFunction ]]();
		if ( !isdefined( result ) )
			result = true;
		if ( result )
			return;
	}

	animscripts\utility::initialize( "death" );

	// should move this to squad manager somewhere...
	removeSelfFrom_SquadLastSeenEnemyPos( self.origin );

	anim.numDeathsUntilCrawlingPain -- ;
	anim.numDeathsUntilCornerGrenadeDeath -- ;

	self notify( "deathanim" );

	if ( isDefined( self.ragdoll_immediate ) || self.forceRagdollImmediate )
	{
		self doImmediateRagdollDeath();
		// ragdoll can fail so don't assume that we can quit the function
	}

	if ( isDefined( self.deathanim ) )
	{
		playDeathAnim( self.deathAnim );

		// Added so that I can do special stuff in Level scripts on an ai
		if ( isdefined( self.deathanimscript ) )
			self [[ self.deathanimscript ]]();
		return;
	}

	if ( isDefined( self.deathscript ) )
	{
		self [[ self.deathscript ]]();
		return;
	}

	explosiveDamage = self animscripts\pain::wasDamagedByExplosive();
	if ( is_railgun( self.damageWeapon ) )
	{
		if ( RandomInt( 3 ) == 0 )
		{
			explosiveDamage = true;
		}
	}

	if ( self.damageLocation == "helmet" || self.damageLocation == "head" )
		self helmetPop( true );
	else if ( explosiveDamage && randomint( 3 ) == 0 )
		self helmetPop( false );

	self clearanim( %root, 0.3 );

	if ( !damageLocationIsAny( "head", "helmet" ) )
	{
		if ( self.dieQuietly )
		{
			// replace with actual die quietly gurglesque sound
//			if ( randomint(3) < 2 )
//				self animscripts\face::SayGenericDialogue("pain");
		}
		else
		{
			PlayDeathSound();
		}
	}

	if ( explosiveDamage && playExplodeDeathAnim() )
		return;
		
	// different from deathFunction above, doesn't skip explosion deaths, immediate ragdoll, sounds, etc
	if ( isdefined( self.specialDeathFunc ) )
	{
		if ( [[ self.specialDeathFunc ]]() )
			return;
	}

	// TODO: replace these with the above specialDeathFunc
	if ( specialDeath() )
		return;

	// Dan - Commenting out gib.
	//if ( play_bulletgibbed_death_anim())
	//{
	//	return; 
	//}
	
	deathAnim = getDeathAnim();

	 /#
	if ( getdvarint( "scr_paindebug" ) == 1 )
		println( "^2Playing pain: ", deathAnim, " ; pose is ", self.a.pose );
	#/

	playDeathAnim( deathAnim );
}

doImmediateRagdollDeath()
{
	self animscripts\shared::DropAllAIWeapons();
	self.skipDeathAnim = true;  // this helps playDeathAnim() do failsafes for ragdoll failures later
	
	initialImpulse = 10;
	
	damageType = common_scripts\_destructible::getDamageType( self.damageMod );
	if( IsDefined( self.attacker ) && self.attacker == level._player && damageType == "melee" )
	{
		initialImpulse = 5;
	}

	if ( self.subclass == "moon" )
	{
		initialImpulse = 5;

		// tagBR< note >: This is to fix explosion barrel deaths during traversals (impulse was way too high)
		if ( damageType == "splash" )
		{
			initialImpulse = 2;
		}
	}
	
	damageTaken = self.damagetaken;
	if ( damageType == "bullet" )
		damageTaken = max( damageTaken, 300 );

	if ( GetDVarInt( "zero_g_proto" ) == 1 )
	{
		self animscripts\shared::detachAllWeaponModels();
		initialImpulse = 4;
		damageTaken /= 3;
	}
	
	directionScale = initialImpulse * damageTaken;
	directionUp = max( 0.3, self.damagedir[ 2 ] );
	direction = ( self.damagedir[ 0 ], self.damagedir[ 1 ], directionUp );
	direction *= directionScale;
	
	if ( self.forceRagdollImmediate )
		direction += self.prevAnimDelta * 20 * 10;	// 20 frames/sec
	
	self startragdollfromimpact( self.damagelocation, direction );
	
	// wait a bit so that the ragdoll can start before the death script tries to play a regular
	//  death animation as a failsafe - if ragdolling, the regular death anim won't do anything when called
	wait( 0.2 );
}

playDeathAnim( deathAnim )
{
	if ( !animHasNoteTrack( deathAnim, "dropgun" ) && !animHasNoteTrack( deathAnim, "fire_spray" ) )// && !animHasNotetrack( deathAnim, "gun keep" )
		self animscripts\shared::DropAllAIWeapons();

	if ( isdefined( self.locked_combat ) )
	{
		self StopAnimScripted();
	}

	//if ( isdefined( self.faceDamageDir ) )
	//	self orientmode( "face angle", self.damageYaw );

	self setFlaggedAnimKnobAllRestart( "deathanim", deathAnim, %body, 1, .1 );

	if ( IsDefined( self.skipDeathAnim ) )
	{
		ASSERTEX( self.skipDeathAnim, "self.skipDeathAnim must be either true or undefined." );
		
		//self thread do_gib();
		
		if( !isdefined( self.noragdoll ) || !self.noRagdoll )
			self startRagDoll();
		
		wait( 0.05 );
		// failsafe in case ragdoll fails: he'll still be playing a deathanim,
		//  but at least he'll fall to the ground
		self AnimMode( "gravity" );
	}
	else if ( !animHasNotetrack( deathanim, "start_ragdoll" ) )
	{
		//self thread do_gib(); 
		self thread waitForRagdoll( getanimlength( deathanim ) * 0.35 );
	}

	// do we really need this anymore?
	 /#
	if ( getdebugdvar( "debug_grenadehand" ) == "on" )
	{
		if ( animhasnotetrack( deathAnim, "bodyfall large" ) )
			return;
		if ( animhasnotetrack( deathAnim, "bodyfall small" ) )
			return;

		println( "Death animation ", deathAnim, " does not have a bodyfall notetrack" );
		iprintlnbold( "Death animation needs fixing (check console and report bug in the animation to Boon)" );
	}
	#/
	
	// SRS 11/20/08: blood pools don't always line up with ragdoll corpses, so skip them if
	//  we did ragdoll without a death anim (which usually sends the body farther away from the death spot)
	if ( !IsDefined( self.skipDeathAnim ) )
	{
		self thread playDeathFX();
	}
	
	self animscripts\shared::DoNoteTracks( "deathanim" );
	self animscripts\shared::DropAllAIWeapons();
}

waitForRagdoll( time )
{
	wait( time );
	if ( isdefined( self ) )
		self animscripts\shared::DropAllAIWeapons();
	if ( isdefined( self ) && ( !isdefined( self.noragdoll ) || !self.noRagdoll ) )
		self startragdoll();
}

playDeathFX()
{
	self endon( "killanimscript" );
	//iprintlnbold("bleed'n");

	if ( self.stairsState != "none" )
		return;

	wait 2;
	
	play_blood_pool();
}

play_blood_pool( note, flagName )
{
	if ( !isdefined( self ) )
		return;
	
	if ( isdefined( self.skipBloodPool ) )
	{
		assertex( self.skipBloodPool, "Setting must be either true or undefined" );
		return;
	}
/*
	//play vacuum blood pool fx
	if( GetDvar("environment_pressurized") == "0" )
	{
		iprintlnbold("got moon blood");
		tagPos = self gettagorigin( "j_SpineUpper" );	// rough tag to play fx on
		tagAngles = self gettagangles( "j_SpineUpper" );
		forward = anglestoforward( tagAngles );
		up = anglestoup( tagAngles );
		right = anglestoright( tagAngles );
	
		tagPos = tagPos + vector_multiply( forward, -8.5 ) + vector_multiply( up, 5 ) + vector_multiply( right, 0 );
	
		trace = bulletTrace( tagPos + ( 0, 0, 30 ), tagPos - ( 0, 0, 100 ), false, undefined );
		
		if ( trace[ "normal" ][2] > 0.9 )
		{
			playfx( level._effect[ "blood_pool_vacuum" ], tagPos, forward, up );
		}
		return;
	}
*/
	//play normal blood pool fx
	tagPos = self gettagorigin( "j_SpineUpper" );	// rough tag to play fx on
	tagAngles = self gettagangles( "j_SpineUpper" );
	forward = anglestoforward( tagAngles );
	up = anglestoup( tagAngles );
	right = anglestoright( tagAngles );

	tagPos = tagPos + vector_multiply( forward, -8.5 ) + vector_multiply( up, 5 ) + vector_multiply( right, 0 );

	trace = bulletTrace( tagPos + ( 0, 0, 30 ), tagPos - ( 0, 0, 100 ), false, undefined );

			if( GetDvar("environment_pressurized") == "0" )
			{
				for ( i = 0; i < 4; i++ )
				{
					rand_x = RandomIntRange( -30, 30 );
					rand_y = RandomIntRange( -10, 10 );
					rand_z = RandomIntRange( 0, 1 );
					randomoffset = ( rand_x, rand_y, rand_z );
					bloodpos = tagpos + randomoffset;
					newtrace = bulletTrace( bloodpos + ( 0, 0, 30 ), bloodpos - ( 0, 0, 100 ), false, undefined );
					if ( newtrace[ "normal" ][2] > 0.9 )
					{
						if ( newtrace[ "position" ][2] < bloodpos[2] )
						{
							playfx( level._effect[ "blood_pool_vacuum" ], bloodpos );
							//newbloodpos = vector_multiply( newtrace[ "position" ][0], bloodpos[0] ) + vector_multiply( newtrace[ "position" ][1], bloodpos[1] ) + vector_multiply( newtrace[ "position" ][2], bloodpos[2] ); 

							//playfx( level._effect[ "blood_pool_steam" ], newbloodpos );

							//iprintlnbold( newbloodpos );
						}
					}
				}
			}
			else if ( trace[ "normal" ][2] > 0.9 )
			{
				playfx( level._effect[ "deathfx_bloodpool_generic" ], tagPos );
			}
			
}


// TODO: replace these with specialDeathFunc
// Special death is for corners, rambo behavior, mg42's, anything out of the ordinary stand, crouch and prone.  
// It returns true if it handles the death for the special animation state, or false if it wants the regular 
// death function to handle it.
specialDeath()
{
	if ( self.a.special == "none" )
		return false;

	switch( self.a.special )
	{
	case "cover_right":
		if ( self.a.pose == "stand" )
		{
			DoDeathFromArray( getDeathAnimByName("cover_right_stand") );
		}
		else
		{
			deathArray = [];
			//TagCC<NOTE>: why is this different from the left? it doesnt cut out death back.
			if ( damageLocationIsAny( "head", "neck" ) )
			{
				DoDeathFromArray( getDeathAnimByName("cover_right_crouch_head_neck") );
			}
			else
			{
				DoDeathFromArray( getDeathAnimByName("cover_right_crouch") );
			}
		}
		return true;

	case "cover_left":
		if ( self.a.pose == "stand" )
		{
			DoDeathFromArray( getDeathAnimByName("cover_left_stand") );
		}
		else
		{
			DoDeathFromArray( getDeathAnimByName("cover_left_crouch") );
		}
		return true;

	case "cover_stand":
		DoDeathFromArray( getDeathAnimByName("cover_stand") );
		return true;

	case "cover_crouch":
		deathArray = [];
		if ( damageLocationIsAny( "head", "neck" ) && ( self.damageyaw > 135 || self.damageyaw <= -45 ) )	// Front / Left quadrant
		{
			deathArray = getDeathAnimByName("cover_crouch_head");
		}
		else if ( ( self.damageyaw > - 45 ) && ( self.damageyaw <= 45 ) )	// Back quadrant
		{
			deathArray = getDeathAnimByName("cover_crouch_back");			
		}

		deathArray = array_combine( deathArray, getDeathAnimByName( "cover_crouch" ) );
		DoDeathFromArray( deathArray );

		return true;

	case "saw":
		if ( self.a.pose == "stand" )
		{
			DoDeathFromArray( getDeathAnimByName("saw_stand") );
		}
		else if ( self.a.pose == "crouch" )
		{
			DoDeathFromArray( getDeathAnimByName("saw_crouch") );
		}	
		else
		{
			DoDeathFromArray( getDeathAnimByName("saw_prone") );
		}
		return true;

	case "dying_crawl":
		if ( isdefined( self.a.onback ) && self.a.pose == "crouch" )
		{
			DoDeathFromArray( getDeathAnimByName("crawl_crouch") );
		}
		else
		{
			DoDeathFromArray( getDeathAnimByName("crawl_prone") );
		}
		return true;
	}
	return false;
}


DoDeathFromArray( deathArray )
{
	deathAnim = deathArray[ randomint( deathArray.size ) ];

	playDeathAnim( deathAnim );
	//nate - adding my own special death flag on top of special death. 
	if ( isdefined( self.deathanimscript ) )
		self [[ self.deathanimscript ]]();
}


PlayDeathSound()
{
	self animscripts\face::SayGenericDialogue( "death" );
}

print3dfortime( place, text, time )
{
	numframes = time * 20;
	for ( i = 0; i < numframes; i++ )
	{
		print3d( place, text );
		wait .05;
	}
}

helmetPop( was_headshot )
{
	if ( !isdefined( self ) )
		return;
	// used to check self removableHat() in cod2... probably not necessary though

	// Potentially switch to a headshot version of the head model.
	if ( was_headshot && isdefined( self.headshotModel ) )
	{
		self Detach( self.headmodel );
		self.headmodel = self.headshotModel;
		self Attach( self.headshotModel );
	}

	// Potentially pop a hat off.
	if ( isdefined( self.hatModel ) )
	{
		partName = GetPartName( self.hatModel, 0 );
		model = spawn( "script_model", self.origin + ( 0, 0, 64 ) );
		model setmodel( self.hatModel );
		model.origin = self GetTagOrigin( partName );// self . origin + ( 0, 0, 64 );
		model.angles = self GetTagAngles( partName );// ( -90, 0 + randomint( 90 ), 0 + randomint( 90 ) );
		model thread helmetLaunch( self.damageDir );
	
		hatModel = self.hatModel;
		self.hatModel = undefined;
	
		wait 0.05;
	
		if ( !isdefined( self ) )
			return;
		self detach( hatModel, "" );
	}
}

helmetLaunch( damageDir )
{
    launchForce = damageDir;
	launchForce = launchForce * randomFloatRange( 2000, 4000 );

	forcex = launchForce[ 0 ];
	forcey = launchForce[ 1 ];
	forcez = randomFloatRange( 1500, 3000 );

	contactPoint = self.origin + ( randomfloatrange( -1, 1 ), randomfloatrange( -1, 1 ), randomfloatrange( -1, 1 ) ) * 5;

	self PhysicsLaunchClient( contactPoint, ( forcex, forcey, forcez ) );

	wait 60;

	while ( 1 )
	{
		if ( !isdefined( self ) )
			return;

		if ( distanceSquared( self.origin, level._player.origin ) > 512 * 512 )
			break;

		wait 30;
	}

	self delete();
}


removeSelfFrom_SquadLastSeenEnemyPos( org )
{
	for ( i = 0;i < anim.squadIndex.size;i++ )
		anim.squadIndex[ i ] clearSightPosNear( org );
}


clearSightPosNear( org )
{
	if ( !isdefined( self.sightPos ) )
		return;

	if ( distance( org, self.sightPos ) < 80 )
	{
		self.sightPos = undefined;
		self.sightTime = gettime();
	}
}


shouldDoRunningForwardDeath()
{
	if ( self.a.movement != "run" )
		return false;

	if ( self getMotionAngle() > 60 || self getMotionAngle() < - 60 )
		return false;

/*
	if ( ( self.damageyaw >= 120 ) || ( self.damageyaw <= -120 ) )// Front quadrant
		return true;

	if ( ( self.damageyaw >= -45 ) && ( self.damageyaw <= 45 ) )// Back quadrant
		return true;

	return false;
*/
	return true;
}

shouldDoStrongBulletDamage( damageWeapon, damageMod, damagetaken, attacker )
{
	ASSERT( IsDefined( damageWeapon ) );

	if ( isdefined( self.a.doingLongDeath ) )
	{
		return false;
	}

	if ( self.a.pose == "prone" || isdefined( self.a.onback ) )
	{
		return false;
	}
	
	if( damageWeapon == "none" )
	{
		return false;
	}
	
	if ( damagetaken > 500 )
	{
		return true;
	}
	
	if( damageMod == "MOD_MELEE" )
	{
		return false;	
	}
	
	// if I'm running, and the attacker is far enough away, sometimes let me do
	//  a running death instead.  this helps minimize repetition of strong damage animations
	//  when a line of dudes is running towards you and you're mowing them down, etc.
	if( self.a.movement == "run" && !isAttackerWithinDist( attacker, 275 ) )
	{
		if( RandomInt( 100 ) < 65 )
		{
			return false;
		}
	}
	
	if ( isSniperRifle( damageWeapon ) && self.maxHealth < damageTaken )
	{
		return true;
	}
	
	if( isShotgun( damageWeapon ) && isAttackerWithinDist( attacker, 512 ) )
	{
		return true;
	}
	
	if( isDesertEagle( damageWeapon ) && isAttackerWithinDist( attacker, 425 ) )
	{
		return true;
	}

	if( is_railgun( damageWeapon ) )
	{
		return true;
	}
	
	return false;
}

isDesertEagle( damageWeapon )
{
	if( damageWeapon == "deserteagle" )
	{
		return true;
	}
	
	return false;
}

is_railgun( damageWeapon )
{
	if( damageWeapon == "ugv_main_turret" || damageWeapon == "ugv_main_turret_player" || damageWeapon == "ugv_main_turret_mp" || damageWeapon == "nx_chinese_lgv_turret" )
	{
		return true;
	}
	
	return false;
}

isAttackerWithinDist( attacker, maxDist )
{
	if( !IsDefined( attacker ) )
	{
		return false;
	}
	
	if( Distance( self.origin, attacker.origin ) > maxDist )
	{
		return false;
	}
	
	return true;
}

getDeathAnim()
{
	if ( shouldDoStrongBulletDamage( self.damageWeapon, self.damageMod, self.damagetaken, self.attacker ) )
	{
		deathAnim = getStrongBulletDamageDeathAnim();
		
		if ( IsDefined( deathAnim ) )
		{
			return deathAnim;
		}
	}

	if ( isdefined( self.a.onback ) )
	{
		if ( self.a.pose == "crouch" )
			return getBackDeathAnim();
		else
			animscripts\shared::stopOnBack();
	}

	if ( self.a.pose == "stand" )
	{
		if ( shouldDoRunningForwardDeath() )
		{
			return getRunningForwardDeathAnim();
		}
		else
		{
			return getStandDeathAnim();
		}
	}
	else if ( self.a.pose == "crouch" )
	{
		return getCrouchDeathAnim();
	}
	else if ( self.a.pose == "prone" )
	{
		return getProneDeathAnim();
	}
}


// may return undefined
// large death animation for shotguns, snipers etc.
getStrongBulletDamageDeathAnim()
{
	damageYaw = abs( self.damageYaw );

	//TagCC<NOTE>: note, it's using ABS of damageYaw
	//TagCC<NOTE>: Shot from behind?
	if ( damageYaw < 45 )
		return;
		
	//TagCC<NOTE>: This probably can all be optimized more by just using logic to decide array name. I'm not sure if it's passing
	//a handle to the array, or the actual array around (my guess is it's the actual array). It's atleast not any worse than before.

	//TagCC<NOTE>: Front
	if ( damageYaw > 150 )
	{
		if ( damageLocationIsAny( "left_leg_upper", "left_leg_lower", "right_leg_upper", "right_leg_lower", "left_foot", "right_foot" ) )
		{
			deathArray = getDeathAnimByName("strong_leg_front");
		}
		else
		{							
			if ( self.damageLocation == "torso_lower" )
			{
				deathArray = getDeathAnimByName("strong_lower_torso_front");
			}
			else
			{
				deathArray = getDeathAnimByName("strong_torso_front");
			}
		}
	}
	else if ( self.damageYaw < 0 ) // LEFT
	{
		deathArray = getDeathAnimByName("strong_left");
	}
	else // RIGHT
	{
		deathArray = getDeathAnimByName("strong_right");
	}

	return deathArray[ randomint( deathArray.size ) ];
}

getRunningForwardDeathAnim()
{
	deathArray = getDeathAnimByName("running_forward");
	sanityCheckDeathArray( deathArray );

	deathArray = animscripts\pain::removeBlockedAnims( deathArray );

	if ( !deathArray.size )
		return getStandDeathAnim();

	return deathArray[ randomint( deathArray.size ) ];
}

// remove undefined entries from array
removeUndefined( array )
{
	newArray = [];
	for ( index = 0; index < array.size; index++ )
	{
		if ( !isDefined( array[ index ] ) )
			continue;

		newArray[ newArray.size ] = array[ index ];
	}
	return newArray;
}

getStandPistolDeathAnim()
{
	deathArray = [];
	
	if ( abs( self.damageYaw ) < 50 )
	{
		deathArray[ deathArray.size ] = getDeathAnimByName("stand_pistol_back");// falls forwards
	}
	else
	{
		if ( abs( self.damageYaw ) < 110 )
			deathArray[ deathArray.size ] = getDeathAnimByName("stand_pistol_back");// falls forwards

		if ( damageLocationIsAny( "torso_lower", "torso_upper", "left_leg_upper", "left_leg_lower", "right_leg_upper", "right_leg_lower" ) )
		{
			deathArray[ deathArray.size ] = getDeathAnimByName("stand_pistol_legs");// hit in groin from front
			if ( !damageLocationIsAny( "torso_upper" ) )
				deathArray[ deathArray.size ] = getDeathAnimByName("stand_pistol_legs");// ( twice as likely )
		}

		if ( !damageLocationIsAny( "head", "neck", "helmet", "left_foot", "right_foot", "left_hand", "right_hand", "gun" ) && randomint( 2 ) == 0 )
			deathArray[ deathArray.size ] = getDeathAnimByName("stand_pistol_chest");// hit at top and falls backwards, but more dragged out

		if ( deathArray.size == 0 || damageLocationIsAny( "torso_lower", "torso_upper", "neck", "head", "helmet", "right_arm_upper", "left_arm_upper" ) )
			deathArray[ deathArray.size ] = getDeathAnimByName("stand_pistol_head");// falls backwards
	}
	
	return deathArray;
}

getStandDeathAnim()
{
	deathArray = [];
	extendedDeathArray = [];

	if ( usingSidearm() )
	{
		deathArray = getStandPistolDeathAnim();
	}
	else
	{
		// torso or legs
		if ( damageLocationIsAny( "torso_lower", "left_leg_upper", "left_leg_lower", "right_leg_lower", "right_leg_lower" ) )
		{
			deathArray = array_combine( deathArray, getDeathAnimByName("stand_legs") );
			extendedDeathArray = array_combine( extendedDeathArray, getDeathAnimByName("stand_legs_extended") );
		}
		
		if ( damageLocationIsAny( "head", "helmet" ) )
		{
			deathArray = array_combine( deathArray, getDeathAnimByName("stand_head") );
		}

		if ( damageLocationIsAny( "neck" ) )
		{
			deathArray = array_combine( deathArray, getDeathAnimByName("stand_neck") );
		}
		
		if ( damageLocationIsAny( "left_arm_upper" ) )
		{
			deathArray = array_combine( deathArray, getDeathAnimByName("stand_upper_left") );
		}	
		
		if ( damageLocationIsAny( "torso_upper" ) )
		{
			deathArray = array_combine( deathArray, getDeathAnimByName("stand_upper_torso") );
			extendedDeathArray = array_combine( extendedDeathArray, getDeathAnimByName("stand_upper_torso_extended") );
		}			
		
		// quadrants
		if ( ( self.damageyaw > 135 ) || ( self.damageyaw <= -135 ) )// Front quadrant
		{
			if ( damageLocationIsAny( "neck", "head", "helmet" ) )
			{
				deathArray = array_combine( deathArray, getDeathAnimByName("stand_front_head") );
				extendedDeathArray = array_combine( extendedDeathArray, getDeathAnimByName("stand_front_head_extended") );
			}

			if ( damageLocationIsAny( "torso_upper" ) )
			{
				deathArray = array_combine( deathArray, getDeathAnimByName("stand_front_torso") );
				extendedDeathArray = array_combine( extendedDeathArray, getDeathAnimByName("stand_front_torso_extended") );
			}
		}
		else if ( ( self.damageyaw > -45 ) && ( self.damageyaw <= 45 ) )// Back quadrant
		{
			deathArray = array_combine( deathArray, getDeathAnimByName("stand_back") );
		}
		
		foundLocDamageDeath = ( deathArray.size > 0 );
		
		if ( !foundLocDamageDeath || RandomInt( 100 ) < 15 )
		{
			deathArray = array_combine( deathArray, getDeathAnimByName("stand_generic") );
		}
		
		sanityCheckDeathArray( deathArray );
		
		if ( RandomInt( 100 ) < 10 && firingDeathAllowed() )
		{
			standing_file = getDeathAnimByName("stand_firing");
			sanityCheckFireDeathArray( standing_file );
			deathArray = array_combine( deathArray, getDeathAnimByName("stand_firing") );
		}
		
		deathArray = removeUndefined( deathArray );
	}

	assertex( deathArray.size > 0, deathArray.size );
	if ( deathArray.size == 0 )
		deathArray = getDeathAnimByName("stand_exposed");

	if ( !self.a.disableLongDeath && self.stairsState == "none" && !isdefined( self.a.painOnStairs ) )
	{
		index = randomint( deathArray.size + extendedDeathArray.size );
		if ( index < deathArray.size )
			return deathArray[ index ];
		else
			return extendedDeathArray[ index - deathArray.size ];
	}

	assertex( deathArray.size > 0, deathArray.size );
	return deathArray[ randomint( deathArray.size ) ];
}


getCrouchDeathAnim()
{
	deathArray = [];

	if ( damageLocationIsAny( "head", "neck" ) )	// Front / Left quadrant
		deathArray[ deathArray.size ] = getDeathAnimByName("crouch_head");

	if ( damageLocationIsAny( "torso_upper", "torso_lower", "left_arm_upper", "right_arm_upper", "neck" ) )
		deathArray[ deathArray.size ] = getDeathAnimByName("crouch_torso");

	if ( deathArray.size < 2 )
		deathArray[ deathArray.size ] = getDeathAnimByName("crouch_twist");
	if ( deathArray.size < 2 )
		deathArray[ deathArray.size ] = getDeathAnimByName("crouch_generic");
		
	sanityCheckDeathArray( deathArray );	

	assertex( deathArray.size > 0, deathArray.size );
	return deathArray[ randomint( deathArray.size ) ];
}

/* Dan - Commenting out gib.
get_gib_ref( direction )
{
	anim.gibDelay = 0;

	// Dvars for testing gibs.
	//if ( GetDvarInt( "gib_delay" ) > 0 )
	//{
	//	anim.gibDelay = GetDvarInt( "gib_delay" ); 
	//}
	//
	//if ( GetDvar( "gib_test" ) != "" )
	//{
	//	self.a.gib_ref = GetDvar( "gib_test" ); 
	//	return; 
	//}

	// If already set, then use it. Useful for canned gib deaths.
	if ( IsDefined( self.a.gib_ref ))
	{
		return; 
	}

	// Don't gib if we haven't taken enough damage by the explosive
	// Grenade damage usually range from 160 - 250, so we go above teh minimum
	// so if the splash damage is near it's lowest, don't gib.
	if( self.damageTaken < 165 )
	{
		return; 
	}

	if ( GetTime() > anim.lastGibTime + anim.gibDelay && anim.totalGibs > 0 )
	{
		anim.totalGibs--; 

		anim thread set_last_gib_time(); 

		refs = []; 
		switch( direction )
		{
			case "right":
				refs[refs.size] = "left_arm"; 
				refs[refs.size] = "left_leg"; 

				gib_ref = get_random( refs ); 				
				break; 

			case "left":
				refs[refs.size] = "right_arm"; 
				refs[refs.size] = "right_leg"; 

				gib_ref = get_random( refs ); 				
				break; 

			case "forward":
				refs[refs.size] = "right_arm"; 
				refs[refs.size] = "left_arm"; 
				refs[refs.size] = "right_leg"; 
				refs[refs.size] = "left_leg"; 
				//refs[refs.size] = "guts"; 
				refs[refs.size] = "no_legs"; 

				gib_ref = get_random( refs ); 				
				break; 

			case "back":
				refs[refs.size] = "right_arm"; 
				refs[refs.size] = "left_arm"; 
				refs[refs.size] = "right_leg"; 
				refs[refs.size] = "left_leg"; 
				refs[refs.size] = "no_legs"; 

				gib_ref = get_random( refs ); 				
				break; 

			default: // "up"
				refs[refs.size] = "right_arm"; 
				refs[refs.size] = "left_arm"; 
				refs[refs.size] = "right_leg"; 
				refs[refs.size] = "left_leg"; 
				refs[refs.size] = "no_legs"; 
				//refs[refs.size] = "guts"; 

				gib_ref = get_random( refs ); 
				break; 
		}


		self.a.gib_ref = gib_ref; 
	}
	else
	{
		self.a.gib_ref = undefined; 
	}
}

set_last_gib_time()
{
	anim notify( "stop_last_gib_time" ); 
	anim endon( "stop_last_gib_time" ); 

	wait( 0.05 ); 
	anim.lastGibTime 	 = GetTime(); 
	anim.totalGibs		 = RandomIntRange( anim.minGibs, anim.maxGibs ); 
}

get_random( array )
{
	return array[RandomInt( array.size )]; 
}

do_gib()
{
	if( !IsDefined( self.a.gib_ref ) )
	{
		return; 
	}
 
	gib_ref = self.a.gib_ref; 

	limb_data = get_limb_data( gib_ref ); 

	if ( !IsDefined( limb_data ))
	{
		println( "^3animscripts\death.gsc - limb_data is not setup for gib_ref on model: " + self.model + " and gib_ref of: " + self.a.gib_ref ); 
		return; 
	}

	forward = undefined; 
	velocity = undefined; 

	pos1 = []; 
	pos2 = []; 
	velocities = []; 

	if ( gib_ref == "head" )
	{
		self Detach( self.headModel, "" ); 
		self helmetPop();

		if ( IsDefined( self.hatModel ) )
		{
			self detach( self.hatModel, "" ); 
			self.hatModel = undefined;
		}
	}

	if ( limb_data["spawn_tags"][0] != "" )
	{
		if ( IsDefined( self.gib_vel ) )
		{
			for ( i = 0; i < limb_data["spawn_tags"].size; i++ )
			{
				velocities[i] = self.gib_vel; 
			}
		}
		else
		{
			for ( i = 0; i < limb_data["spawn_tags"].size; i++ )
			{
				pos1[pos1.size] = self GetTagOrigin( limb_data["spawn_tags"][i] ); 
			}

			wait( 0.05 ); 

			for ( i = 0; i < limb_data["spawn_tags"].size; i++ )
			{
				pos2[pos2.size] = self GetTagOrigin( limb_data["spawn_tags"][i] ); 
			}

			for ( i = 0; i < pos1.size; i++ )
			{
				forward = VectorNormalize( pos2[i] - pos1[i] ); 
				velocities[i] = forward * RandomIntRange( 600, 1000 ); 
				velocities[i] = velocities[i] +( 0, 0, RandomIntRange( 400, 700 ) ); 
			}
		}
	}

	if ( IsDefined( limb_data["fx"] ) )
	{
		for ( i = 0; i < limb_data["spawn_tags"].size; i++ )
		{
			if ( limb_data["spawn_tags"][i] == "" )
			{
				continue; 
			}

			PlayFxOnTag( anim._effect[limb_data["fx"]], self, limb_data["spawn_tags"][i] ); 
		}
	}

	//tagrRR<TODO>: Play a sound here?
	self thread throw_gib( limb_data["spawn_models"], limb_data["spawn_tags"], velocities ); 

	// Set the upperbody model
	self SetModel( limb_data["body_model"] ); 

	// Attach the legs
	self Attach( limb_data["legs_model"] ); 
}

precache_gib_fx()
{
	anim._effect["animscript_gib_fx"] 		 = LoadFx( "impacts/flesh_hit_head_fatal_exit" );//LoadFx( "weapon/bullet/fx_flesh_gib_fatal_01" ); 
	anim._effect["animscript_gibtrail_fx"] 	 = LoadFx( "impacts/flesh_hit_head_fatal_exit" );//LoadFx( "trail/fx_trail_blood_streak" ); 
	
	// Not gib; split out into another function before this gets out of hand.
	anim._effect["death_neckgrab_spurt"] = LoadFx( "impacts/flesh_hit_head_fatal_exit" ); //LoadFx( "impacts/fx_flesh_hit_neck_fatal" ); 
}

get_limb_data( gib_ref )
{
	temp_array = []; 

	// Slightly faster, store the IsDefined stuff before checking, which will be less code-calls.
	torsoDmg1_defined 	 = IsDefined( self.torsoDmg1 ); 
	torsoDmg2_defined 	 = IsDefined( self.torsoDmg2 ); 
	torsoDmg3_defined 	 = IsDefined( self.torsoDmg3 ); 
	torsoDmg4_defined 	 = IsDefined( self.torsoDmg4 ); 
	torsoDmg5_defined 	 = IsDefined( self.torsoDmg5 ); 
	legDmg1_defined 	 = IsDefined( self.legDmg1 ); 
	legDmg2_defined 	 = IsDefined( self.legDmg2 ); 
	legDmg3_defined 	 = IsDefined( self.legDmg3 ); 
	legDmg4_defined 	 = IsDefined( self.legDmg4 ); 

	gibSpawn1_defined 	 = IsDefined( self.gibSpawn1 ); 
	gibSpawn2_defined 	 = IsDefined( self.gibSpawn2 ); 
	gibSpawn3_defined 	 = IsDefined( self.gibSpawn3 ); 
	gibSpawn4_defined 	 = IsDefined( self.gibSpawn4 ); 
	gibSpawn5_defined 	 = IsDefined( self.gibSpawn5 ); 

	gibSpawnTag1_defined 	 = IsDefined( self.gibSpawnTag1 ); 
	gibSpawnTag2_defined 	 = IsDefined( self.gibSpawnTag2 ); 
	gibSpawnTag3_defined 	 = IsDefined( self.gibSpawnTag3 ); 
	gibSpawnTag4_defined 	 = IsDefined( self.gibSpawnTag4 ); 
	gibSpawnTag5_defined 	 = IsDefined( self.gibSpawnTag5 ); 

	// Right arm is getting blown off! /////////////////////////////////////////////////////	
	if ( torsoDmg2_defined && legDmg1_defined && gibSpawn1_defined && gibSpawnTag1_defined )
	{
		temp_array["right_arm"]["body_model"] 		 = self.torsoDmg2; 
		temp_array["right_arm"]["legs_model"] 		 = self.legDmg1; 
		temp_array["right_arm"]["spawn_models"][0] 	 = self.gibSpawn1; 

		temp_array["right_arm"]["spawn_tags"][0]	 = self.gibSpawnTag1; 
		temp_array["right_arm"]["fx"]				 = "animscript_gib_fx"; 
	}

	// Left arm is getting blown off! //////////////////////////////////////////////////////	
	if ( torsoDmg3_defined && legDmg1_defined && gibSpawn2_defined && gibSpawnTag2_defined )
	{
		temp_array["left_arm"]["body_model"] 		 = self.torsoDmg3; 
		temp_array["left_arm"]["legs_model"] 		 = self.legDmg1; 
		temp_array["left_arm"]["spawn_models"][0] 	 = self.gibSpawn2; 

		temp_array["left_arm"]["spawn_tags"][0]		 = self.gibSpawnTag2; 
		temp_array["left_arm"]["fx"]				 = "animscript_gib_fx"; 
	}

	// Right leg is getting blown off! ////////////////////////////////////////////////////
	if ( torsoDmg1_defined && legDmg2_defined && gibSpawn3_defined && gibSpawnTag3_defined )
	{
		temp_array["right_leg"]["body_model"] 		 = self.torsoDmg1; 
		temp_array["right_leg"]["legs_model"] 		 = self.legDmg2; 
		temp_array["right_leg"]["spawn_models"][0] 	 = self.gibSpawn3; 

		temp_array["right_leg"]["spawn_tags"][0]	 = self.gibSpawnTag3; 
		temp_array["right_leg"]["fx"]				 = "animscript_gib_fx"; 
	}


	// Left leg is getting blown off! /////////////////////////////////////////////////////
	if ( torsoDmg1_defined && legDmg3_defined && gibSpawn4_defined && gibSpawnTag4_defined )
	{
		temp_array["left_leg"]["body_model"] 		 = self.torsoDmg1; 
		temp_array["left_leg"]["legs_model"] 		 = self.legDmg3; 
		temp_array["left_leg"]["spawn_models"][0] 	 = self.gibSpawn4; 

		temp_array["left_leg"]["spawn_tags"][0]		 = self.gibSpawnTag4; 
		temp_array["left_leg"]["fx"]				 = "animscript_gib_fx"; 
	}

	// No legs! ///////////////////////////////////////////////////////////////////////////
	if ( torsoDmg1_defined && legDmg4_defined && gibSpawn4_defined && gibSpawn3_defined && gibSpawnTag3_defined && gibSpawnTag4_defined )
	{
		temp_array["no_legs"]["body_model"] 		 = self.torsoDmg1; 
		temp_array["no_legs"]["legs_model"] 		 = self.legDmg4; 
		temp_array["no_legs"]["spawn_models"][0] 	 = self.gibSpawn4; 
		temp_array["no_legs"]["spawn_models"][1] 	 = self.gibSpawn3; 

		temp_array["no_legs"]["spawn_tags"][0]		 = self.gibSpawnTag4; 
		temp_array["no_legs"]["spawn_tags"][1]		 = self.gibSpawnTag3; 
		temp_array["no_legs"]["fx"]					 = "animscript_gib_fx"; 
	}

	// Guts! //////////////////////////////////////////////////////////////////////////////
	if ( torsoDmg4_defined && legDmg1_defined )
	{
		temp_array["guts"]["body_model"] 			 = self.torsoDmg4; 
		temp_array["guts"]["legs_model"] 			 = self.legDmg1; 

		temp_array["guts"]["spawn_models"][0] 		 = ""; 
	//	temp_array["guts"]["spawn_tags"][0]			 = "J_SpineLower"; 
		temp_array["guts"]["spawn_tags"][0]			 = ""; 
		temp_array["guts"]["fx"]					 = "animscript_gib_fx"; 
	}

	// Head! //////////////////////////////////////////////////////////////////////////////
	if ( torsoDmg5_defined && legDmg1_defined )
	{
		temp_array["head"]["body_model"] 			 = self.torsoDmg5; 
		temp_array["head"]["legs_model"] 			 = self.legDmg1; 

		if( gibSpawn5_defined && gibSpawnTag5_defined )
		{
			temp_array["head"]["spawn_models"][0] 		 = self.gibSpawn5; 
			temp_array["head"]["spawn_tags"][0]			 = self.gibSpawnTag5;
		}
		else
		{
			temp_array["head"]["spawn_models"][0] 		 = ""; 
			temp_array["head"]["spawn_tags"][0]			 = "";
		}
		temp_array["head"]["fx"]					 = "animscript_gib_fx"; 
	}

	if ( IsDefined( temp_array[gib_ref] ) )
	{
		return temp_array[gib_ref]; 
	}
	else
	{
		return undefined; 
	}
}

throw_gib( spawn_models, spawn_tags, velocities )
{
	if ( velocities.size < 1 ) // For guts
	{
		return; 
	}

	for ( i = 0; i < spawn_models.size; i++ )
	{
		origin = self GetTagOrigin( spawn_tags[i] ); 
		angles = self GetTagAngles( spawn_tags[i] ); 
		CreateDynEntAndLaunch( spawn_models[i], origin, angles, origin, velocities[i], anim._effect["animscript_gibtrail_fx"], 1 ); 

		//gib = Spawn( "script_model", self GetTagOrigin( spawn_tags[i] ) ); 
		//gib.angles = self GetTagAngles( spawn_tags[i] ); 
		//gib SetModel( spawn_models[i] ); 

		//// Play trail fX
		//PlayFxOnTag( anim._effect["animscript_gibtrail_fx"], gib, "tag_fx" ); 

		//gib PhysicsLaunch( self.origin, velocities[i] ); 
	
		//gib thread gib_delete(); 
	}
}

play_bulletgibbed_death_anim()
{
	maxDist = 300; 
	
	if ( self.damagemod == "MOD_MELEE" )
	{
		return false; 
	}

	// Allow script to turn off gibbing.
	if ( IsDefined( self.no_gib ) && ( self.no_gib == 1 ) )
	{
		return false;
	}

	gib_chance = 75;
	shotty_gib = false;
	force_gib  = IsDefined( self.force_gib ) && self.force_gib;
	if ( WeaponClass( self.damageWeapon ) == "spread" ) // shotgun
	{
		maxDist = 300;
		shotty_gib = true;
		distSquared = DistanceSquared( self.origin, self.attacker.origin );
		if ( distSquared < 110*110 )
		{
			gib_chance = 100;
		}
		else if ( distSquared < 200*200 )
		{
			gib_chance = 75;
		}
		else if ( distSquared < 270*270 )
		{
			gib_chance = 50;
		}
		else if ( distSquared < 330*330 )
		{
			if ( RandomInt( 100 ) < 50 )
			{
				gib_chance = 50;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}
	else if ( IsDefined(self.damageWeapon) && self.damageWeapon != "none" && IsSubStr( self.damageWeapon, "dragunov" ) )
	{
		// SUMEET - Adding special case for draganov for some levels with 30% chance
		maxDist = WeaponMaxGibDistance( self.damageWeapon );
		gib_chance = 30;
	}
	else if ( IsDefined(self.damageWeapon) && self.damageWeapon != "none" && WeaponDoGibbing( self.damageWeapon ))
	{
		maxDist = WeaponMaxGibDistance( self.damageWeapon );
		gib_chance = 101;
	}
	else if ( !force_gib )
	{
		return false; 
	}
	
	if ( force_gib )
	{
		maxDist = 6000; 
		gib_chance = 101;
	}

	if ( !IsDefined( self.attacker ) || !IsDefined( self.damageLocation ))
	{
		return false; 
	}

	// shotgun damage is less than 50
	if ( self.damagetaken < 50 && !shotty_gib && !force_gib)
	{
		return false; 
	}
	
	self.a.gib_ref = undefined; 
	
	distSquared = DistanceSquared( self.origin, self.attacker.origin ); 

	if ( RandomInt( 100 ) < gib_chance 
		&& distSquared < maxDist*maxDist 
		&& ( force_gib || GetTime() > anim.lastGibTime + anim.gibDelay ))
	{
		anim.lastGibTime = GetTime(); 

		refs = []; 
		switch( self.damageLocation )
		{
			case "torso_upper":
			case "torso_lower":
				//refs[refs.size] = "guts"; 
				refs[refs.size] = "right_arm"; 
				refs[refs.size] = "left_arm"; 
				break; 
			case "right_arm_upper":
			case "right_arm_lower":
			case "right_hand":
				refs[refs.size] = "right_arm"; 
				break; 
			case "left_arm_upper":
			case "left_arm_lower":
			case "left_hand":
				refs[refs.size] = "left_arm"; 
				break; 
			case "right_leg_upper":
			case "right_leg_lower":
			case "right_foot":
				refs[refs.size] = "right_leg"; 
				refs[refs.size] = "no_legs"; 
				break; 
			case "left_leg_upper":
			case "left_leg_lower":
			case "left_foot":
				refs[refs.size] = "left_leg"; 
				refs[refs.size] = "no_legs"; 
				break; 
			case "helmet":
			case "head":
				refs[refs.size] = "head"; 
				break; 
		}

		// Allow script to customize gib parts
		if ( IsDefined( self.custom_gib_refs ))
		{
			refs = self.custom_gib_refs;
		}

		if ( refs.size )
		{
			self.a.gib_ref = get_random( refs ); 
		}
	}

	range = 600; 
	nrange = -600; 
	self.gib_vel = self.damagedir * RandomIntRange( 500, 900 ); 
	self.gib_vel += ( RandomIntRange( nrange, range ), RandomIntRange( nrange, range ), RandomIntRange( 400, 1000 ) ); 

	if ( try_gib_extended_death( 101 )) //50 ))
	{
		return true; 
	}
	
	deathAnim = getDeathAnim();
	playDeathAnim( deathAnim ); 

	//self setFlaggedAnimKnobAllRestart( "deathanim", deathAnim, %body, 1, .1 ); 
	//
	//wait 0.05;
	//
	//self launch_ragdoll_based_on_damage_type( 2.0 );
	//self thread death_anim_short_circuit();	// do this just for consistency
	//
	//// wait here so that the client can get the model changes before it becomes an AI_CORPSE
	//wait 0.5;

	return true; 
}

// checks if the gib ref provided is valid one
isValidGibRef( gib_ref )
{	
	// SUMEET_TODO - make this list global list so that it can be updated/edited easily
	refs = []; 
	
	refs[refs.size] = "right_arm"; 
	refs[refs.size] = "left_arm"; 
	refs[refs.size] = "right_leg"; 
	refs[refs.size] = "left_leg"; 
	refs[refs.size] = "no_legs"; 
	refs[refs.size] = "head"; 

	if( is_in_array( refs, gib_ref ) )
		return true;
	
	return false;
}

try_gib_extended_death( chance )
{
	if ( RandomInt( 100 ) >= chance )
	{
		return false; 
	}	

	if ( self.a.pose == "prone" || self.a.pose == "back" )
	{
		return false;
	}

	deathseq = get_gib_extended_death_anims(); 

	if ( deathSeq.size == 3 )
	{
		do_extended_death( deathSeq ); 
		return true; 
	}

	return false; 
}
*/

do_extended_death( deathSeq )
{
	self animscripts\shared::DropAllAIWeapons(); 
	
	//self thread do_gib(); 

	self thread end_extended_death( deathSeq ); 

	numDeathLoops = RandomInt( 2 ) + 1; 
	self thread extended_death_loop( deathSeq, numDeathLoops ); 

	// We must wait for the sequence to end, or else self will get removed before we're done.
	self waittill( "extended_death_ended" ); 
}

end_extended_death( deathSeq )
{
	assert( IsDefined( deathSeq[2] ) ); 

	// Normally, the final death anim runs at the end of the loop, but the loop can be intterupted by shooting.
	// Code sends a special notify "damage_afterdeath" if the AI is shot while in extended death
	self waittill_any( "damage_afterdeath", "ending_extended_death" ); 
	
	
	self setFlaggedAnimKnobAllRestart( "deathdieanim", deathSeq[2], %body, 1, .1 ); 
	self animscripts\shared::DoNoteTracks( "deathdieanim" ); 
	
	// All done with extended death sequence.
	self notify( "extended_death_ended" ); 
}

extended_death_loop( deathSeq, numLoops )
{
	// If someone shoots or damages self in any way, play final death immediately.
	self endon( "damage" ); 

	assert( IsDefined( deathSeq[1] ) ); 	
	
	animLength = GetAnimLength( deathSeq[1] ); 
	for ( i = 0; i < numLoops; i++ )
	{
		self setFlaggedAnimKnobAllRestart( "deathloopanim", deathSeq[1], %body, 1, .1 ); 
		self animscripts\shared::DoNoteTracks( "deathloopanim" ); 
	}

	// If the loop hasn't already been cut short by the actor taking further damage, 
	// go into the final death anim.	
	self notify( "ending_extended_death" ); 
}

get_gib_extended_death_anims()
{
	hitfrom = undefined; 
		
	if (( self.damageyaw > 90 ) || ( self.damageyaw <= -90 ))
	{
		hitfrom = "front"; 
	}
	else
	{
		hitfrom = "back"; 
	}
	
	gib_ref = self.a.gib_ref; 
	
	deathSeq = []; 
	if ( IsDefined( hitfrom ) && IsDefined( gib_ref ) && gib_ref != "head" )
	{
		hitIndex = 0; 
		loopIndex = 1; 
		dieIndex = 2;

		if ( gib_ref == "guts" || gib_ref == "no_legs" ) // don't have directional anims
		{
			hitfrom = "";
		}
		else
		{
			hitfrom = "_" + hitfrom;
		}

		// TEMP
		deathSeq[hitIndex]  = anim.animsets.gibAnimSet["gib_shoulder_twist"];
		deathSeq[loopIndex] = anim.animsets.gibAnimSet["gib_shoulder_spin"];
		deathSeq[dieIndex]  = anim.animsets.gibAnimSet["gib_shoulder_back"];
		//deathSeq[hitIndex]  = animArray("gib_" + gib_ref + hitfrom + "_start"); 
		//deathSeq[loopIndex] = animArray("gib_" + gib_ref + hitfrom + "_loop");
		//deathSeq[dieIndex]  = animArray("gib_" + gib_ref + hitfrom + "_end");
	}
	
	return deathSeq; 
}

getProneDeathAnim()
{
	if ( isdefined( self.a.proneAiming ) )
		return getDeathAnimByName("prone_aiming");
	else
		return getDeathAnimByName("prone");
}

getBackDeathAnim()
{
	deathArray = getDeathAnimByName("back");
	return deathArray[ randomint( deathArray.size ) ];
}

firingDeathAllowed()
{
	if ( !isdefined( self.weapon ) || !usingRifleLikeWeapon() || !weaponIsAuto( self.weapon ) || self.dieQuietly )
		return false;
	
	if ( self.a.weaponPos[ "right" ] == "none" )
		return false;
		
	return true;
}

tryAddDeathAnim( animName )
{
	assert( !animHasNoteTrack( animName, "fire" ) && !animHasNoteTrack( animName, "fire_spray" ) );
	return animName;
}

sanityCheckDeathArray( array )
{
	for( i = 0; i < array.size; i = i+1 )
	{
		assert( !animHasNoteTrack( array[i], "fire" ) && !animHasNoteTrack( array[i], "fire_spray" ) );	
	}	
}

sanityCheckFireDeathArray( array )
{
	for( i = 0; i < array.size; i = i+1 )
	{
		assert( animHasNoteTrack( array[i], "fire" ) || animHasNoteTrack( array[i], "fire_spray" ) );
	}
}

getDeathAnimByName( name )
{
	assert( IsDefined( name ) );
	assert( IsDefined( anim.animsets.deathAnimSet[name] ) ); 
	
	if( IsDefined( self.customDeathAnimSet ) && IsDefined( self.customDeathAnimSet[name] ) )
	{
		return self.customDeathAnimSet[name];
	}
	else
	{
		return anim.animsets.deathAnimSet[name];
	}
}

tryAddFiringDeathAnim( animName )
{
	assert( animHasNoteTrack( animName, "fire" ) || animHasNoteTrack( animName, "fire_spray" ) );
	return animName;
}

playExplodeDeathAnim()
{
	if ( isdefined( self.juggernaut ) || isdefined( self.ares ) )
		return false;
		
	if ( self.damageLocation != "none" && self.damageMod != "MOD_GRENADE" )
	{
		if( !is_railgun( self.damageWeapon ) )
		{
			return false;
		}
	}

	deathArray = [];

	if ( self.a.movement != "run" )
	{
		if ( ( self.damageyaw > 135 ) || ( self.damageyaw <= -135 ) )	// Front quadrant
		{
			deathArray = getDeathAnimByName("explode_stand_front");
			//get_gib_ref( "back" );
		}
		else if ( ( self.damageyaw > 45 ) && ( self.damageyaw <= 135 ) )		// Right quadrant
		{
			deathArray = getDeathAnimByName("explode_stand_right");
			//get_gib_ref( "left" );
		}
		else if ( ( self.damageyaw > - 45 ) && ( self.damageyaw <= 45 ) )		// Back quadrant
		{
			deathArray = getDeathAnimByName("explode_stand_back");
			//get_gib_ref( "forward" );
		}
		else
		{															// Left quadrant
			deathArray = getDeathAnimByName("explode_stand_left");
			//get_gib_ref( "right" ); 
		}
	}
	else
	{
		if ( ( self.damageyaw > 135 ) || ( self.damageyaw <= -135 ) )	// Front quadrant
		{
			deathArray = getDeathAnimByName("explode_run_front");
			//get_gib_ref( "back" );
		}
		else if ( ( self.damageyaw > 45 ) && ( self.damageyaw <= 135 ) )		// Right quadrant
		{
			deathArray = getDeathAnimByName("explode_run_right");
			//get_gib_ref( "left" );
		}
		else if ( ( self.damageyaw > - 45 ) && ( self.damageyaw <= 45 ) )		// Back quadrant
		{
			deathArray = getDeathAnimByName("explode_run_back");
			//get_gib_ref( "forward" );
		}
		else
		{															// Left quadrant
			deathArray = getDeathAnimByName("explode_run_left");
			//get_gib_ref( "right" );
		}
	}

	//gib_chance = 50;

	deathAnim = deathArray[ randomint( deathArray.size ) ];

	if ( getdvar( "scr_expDeathMayMoveCheck", "on" ) == "on" )
	{
		ragdoll_point_array = GetNotetrackTimes( deathAnim, "start_ragdoll" );
		if ( ragdoll_point_array.size > 0 )
		{
			ragdoll_point = ragdoll_point_array[ 0 ];
		}
		else
		{
			ragdoll_point = 1;
		}

		localDeltaVector = getMoveDelta( deathAnim, 0, ragdoll_point );
		endPoint = self localToWorldCoords( localDeltaVector );
	
		// Draw trajectory. 
//		line( self.origin, endPoint, ( 1, 0, 0 ), 1, 0, 5000 );

		if ( !self mayMoveToPoint( endPoint, false ) )
		{
			//if( try_gib_extended_death( gib_chance ) )
			//{
			//	return true; 
			//}
			return false;
		}
	}

	// this should really be in the notetracks
	self animMode( "nogravity" );

	//if( try_gib_extended_death( gib_chance ) )
	//{
	//	return true; 
	//}
	
	playDeathAnim( deathAnim );
	return true;
}

