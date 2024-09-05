// Notes about scripts
//=====================
//
// Anim variables
// -------------- 
// Anim variables keep track of what the character is doing with respect to his 
// animations.  They know if he's standing, crouching, kneeling, walking, running, etc, 
// so that he can play appropriate transitions to get to the animation he wants.
// anim_movement - "stop", "walk", "run"
// anim_pose - "stand", "crouch", "prone", some others for pain poses.
// I'm putting functions to do the basic animations to change these variables in 
// SetPoseMovement.gsc, 
//
// Error Reporting
// ---------------
// To report a script error condition (similar to assert(0)), I assign a non-existent variable to 
// the variable homemade_error  I use the name of the non-existent variable to try to explain the 
// error.  For example:
// 		homemade_error = Unexpected_anim_pose_value + self.a.pose;
// I also have a kind of assert, called as follows:
//		[[anim.assertEX(condition, message_string);
// If condition evaluates to 0, the assert fires, prints message_string and stops the server. Since 
// I don't have stack traces of any kind, the message string needs to say from where the assert was 
// called.

#include animscripts\Utility;
#include maps\_utility;
#include animscripts\Combat_utility;
#include common_scripts\Utility;
#using_animtree( "generic_human" );

initWeapon( weapon )
{
	self.weaponInfo[ weapon ] = spawnstruct();
	self.weaponInfo[ weapon ].position = "none";
	self.weaponInfo[ weapon ].hasClip = true;
	self.weaponInfo[ weapon ].recharges = ( weapon != "none" && WeaponAmmoRecharges( weapon ) );
	
	if ( getWeaponClipModel( weapon ) != "" )
		self.weaponInfo[ weapon ].useClip = true;
	else
		self.weaponInfo[ weapon ].useClip = false;
}

isWeaponInitialized( weapon )
{
	return isDefined( self.weaponInfo[ weapon ] );
}

// Persistent global aiming limits / tolerances
setGlobalAimSettings()
{
	anim.coverCrouchLeanPitch = 55;
			
	// Used by 'Explosed' combat (combat scirpt)
	anim.aimYawDiffFarTolerance = 10;
	anim.aimYawDiffCloseDistSQ = 64 * 64;
	anim.aimYawDiffCloseTolerance = 45;
	anim.aimPitchDiffTolerance = 20;
	
	// Used by LastStand (pain script)
	anim.painYawDiffFarTolerance = 25;
	anim.painYawDiffCloseDistSQ = anim.aimYawDiffCloseDistSQ;
	anim.painYawDiffCloseTolerance = anim.aimYawDiffCloseTolerance;
	anim.painPitchDiffTolerance = 30;
	
	// Absolute maximum trackLoop angles after which the weights are reset to 0
	// These must be greater than the maximum possible aiming limit for all stances
	anim.maxAngleCheckYawDelta = 65;
	anim.maxAngleCheckPitchDelta = 65;
}

everUsesSecondaryWeapon()
{
	if ( isShotgun( self.secondaryweapon ) )
		return true;
	if ( weaponClass( self.primaryweapon ) == "rocketlauncher" )
		return true;
	return false;
}

pre_first_init()
{
	self.a = spawnStruct();
	self.a.laserOn = false;
	self.primaryweapon = self.weapon;
}

post_first_init()
{
	if ( self.primaryweapon == "" )
		self.primaryweapon = "none";
	if ( self.secondaryweapon == "" )
		self.secondaryweapon = "none";
	if ( self.sidearm == "" )
		self.sidearm = "none";
	
	self initWeapon( self.primaryweapon );
	self initWeapon( self.secondaryweapon );
	self initWeapon( self.sidearm );
	
	// this will cause us to think we're using our sidearm when we're not. the aitype should not allow this.
	assertex( self.primaryweapon != self.sidearm || self.primaryweapon == "none", "AI \"" + self.classname + "\" with export " + self.export + " has both a sidearm and primaryweapon of \"" + self.primaryweapon + "\"." );
	assertex( self.secondaryweapon != self.sidearm || self.secondaryweapon == "none" || !self everUsesSecondaryWeapon(), "AI \"" + self.classname + "\" with export " + self.export + " has both a sidearm and secondaryweapon of \"" + self.primaryweapon + "\"." );
	
	self setDefaultAimLimits();

	self.a.weaponPos[ "left" ] = "none";
	self.a.weaponPos[ "right" ] = "none";
	self.a.weaponPos[ "chest" ] = "none";
	self.a.weaponPos[ "back" ] = "none";
	
	self.a.weaponPosDropping[ "left" ] = "none";
	self.a.weaponPosDropping[ "right" ] = "none";
	self.a.weaponPosDropping[ "chest" ] = "none";
	self.a.weaponPosDropping[ "back" ] = "none";
	
	self.lastWeapon = self.weapon;
	self.root_anim = %root;

	self thread beginGrenadeTracking();
	
	hasRocketLauncher = usingRocketLauncher();
	self.a.neverLean = hasRocketLauncher;
	if ( hasRocketLauncher )
		self thread animscripts\shared::rpgPlayerRepulsor();

	// TODO: proper ammo tracking
	self.a.rockets = 3;
	self.a.rocketVisible = true;

//	SetWeaponDist();

	// Set initial states for poses
	self.a.pose = "stand";
	self.a.grenadeThrowPose = "stand";
	self.a.movement = "stop";
	self.a.state = "stop";
	self.a.special = "none";
	self.a.gunHand = "none";	// Initialize so that PutGunInHand works properly.
	self.a.PrevPutGunInHandTime = -1;
	self.dropWeapon = true;
	self.minExposedGrenadeDist = 750;

	animscripts\shared::placeWeaponOn( self.primaryweapon, "right" );
	if ( isShotgun( self.secondaryweapon ) )
		animscripts\shared::placeWeaponOn( self.secondaryweapon, "back" );

	self.a.needsToRechamber = 0;
	self.a.combatEndTime = gettime();
	self.a.lastEnemyTime = gettime();
	self.a.suppressingEnemy = false;
	self.a.disableLongDeath = !( self isBadGuy() );
	self.a.lookangle = 0;
	self.a.painTime = 0;
	self.a.lastShootTime = 0;
	self.a.nextGrenadeTryTime = 0;
	self.a.reactToBulletChance = 0.8;

	if ( self.team != "allies" )
	{
		// only select allies have IR laser and beacon
		self.has_no_ir = true;
	}

	self.a.postScriptFunc = undefined;
	self.a.stance = "stand";
	self.choosePoseFunc = animscripts\utility::choosePose;
	//self.a.state = "idle";

	self._animActive = 0;
	self._lastAnimTime = 0;

	self thread enemyNotify();

	self.baseAccuracy = 1;
	self.a.missTime = 0;

	self.a.nodeath = false;
	self.a.missTime = 0;
	self.a.missTimeDebounce = 0;
	self.a.disablePain = false;

	self.accuracyStationaryMod = 1;
	self.chatInitialized = false;
	self.sightPosTime = 0;
	self.sightPosLeft = true;
	self.needRecalculateGoodShootPos = true;
	self.defaultTurnThreshold = 55;
	self.painPlaybackRate = 1.0;

	self.a.nextStandingHitDying = false;

	// Makes AI able to throw grenades at other AI.
	if ( !isdefined( self.script_forcegrenade ) )
		self.script_forcegrenade = 0;

	/# self.a.lastDebugPrint = ""; #/

	SetupUniqueAnims();

	/# thread animscripts\utility::UpdateDebugInfo(); #/

	self animscripts\weaponList::RefillClip();	// Start with a full clip.

	// state tracking
	self.lastEnemySightTime = 0;// last time we saw our current enemy
	self.combatTime = 0;// how long we've been in / out of combat

	self.suppressed = false;// if we're currently suppressed
	self.suppressedTime = 0;// how long we've been in / out of suppression

	if ( self.team == "allies" )
		self.suppressionThreshold = 0.5;
	else
		self.suppressionThreshold = 0.0;

	// Random range makes the grenades less accurate and do less damage, but also makes it difficult to throw back.
	if ( self.team == "allies" )
		self.randomGrenadeRange = 0;
	else
		self.randomGrenadeRange = 256;

	self.ammoCheatInterval = 8000;	// if out of ammo and it's been this long since last time, do an instant reload
	self.ammoCheatTime = 0;
	animscripts\init_common::set_animset_run_n_gun();
	
    self.exception = [];

    self.exception[ "corner" ] = 1;
    self.exception[ "cover_crouch" ] = 1;
    self.exception[ "stop" ] = 1;
    self.exception[ "stop_immediate" ] = 1;
    self.exception[ "move" ] = 1;
    self.exception[ "exposed" ] = 1;
    self.exception[ "corner_normal" ] = 1;

	keys = getArrayKeys( self.exception );
	for ( i = 0; i < keys.size; i++ )
	{
		clear_exception( keys[ i ] );
	}

	self.reacquire_state = 0;

	self thread setNameAndRank_andAddToSquad();

	self.shouldConserveAmmoTime = 0;

	 /#
	self thread printEyeOffsetFromNode();
	self thread showLikelyEnemyPathDir();
	#/

	self thread monitorFlash();

	self thread onDeath();
}

weapons_with_ir( weapon )
{
	weapons[ 0 ] = "m4_grenadier";
	weapons[ 1 ] = "m4_grunt";
	weapons[ 2 ] = "m4_silencer";
	weapons[ 3 ] = "m4m203";

	if ( !isdefined( weapon ) )
		return false;

	for ( i = 0 ; i < weapons.size ; i++ )
	{
		if ( issubstr( weapon, weapons[ i ] ) )
			return true;
	}
	return false;
}

 /#
printEyeOffsetFromNode()
{
	self endon( "death" );
	while ( 1 )
	{
		if ( getdvarint( "scr_eyeoffset" ) == self getentnum() )
		{
			if ( isdefined( self.coverNode ) )
			{
				offset = self geteye() - self.coverNode.origin;
				forward = anglestoforward( self.coverNode.angles );
				right = anglestoright( self.coverNode.angles );
				trueoffset = ( vectordot( right, offset ), vectordot( forward, offset ), offset[ 2 ] );
				println( trueoffset );
			}
		}
		else
			wait 2;
		wait .1;
	}
}

showLikelyEnemyPathDir()
{
	self endon( "death" );
	setDvarIfUninitialized( "scr_showlikelyenemypathdir", "-1" );
	while ( 1 )
	{
		if ( getdvarint( "scr_showlikelyenemypathdir" ) == self getentnum() )
		{
			yaw = self.angles[ 1 ];
			dir = self getAnglesToLikelyEnemyPath();
			if ( isdefined( dir ) )
				yaw = dir[ 1 ];
			printpos = self.origin + ( 0, 0, 60 ) + anglestoforward( ( 0, yaw, 0 ) ) * 100;
			line( self.origin + ( 0, 0, 60 ), printpos );
			if ( isdefined( dir ) )
				print3d( printpos, "likelyEnemyPathDir: " + yaw, ( 1, 1, 1 ), 1, 0.5 );
			else
				print3d( printpos, "likelyEnemyPathDir: undefined", ( 1, 1, 1 ), 1, 0.5 );

			wait .05;
		}
		else
			wait 2;
	}
}
#/

setNameAndRank_andAddToSquad()
{
	self endon( "death" );
	if ( !isdefined( level._loadoutComplete ) )
		level waittill( "loadout complete" );

	self maps\_names::get_name();
	
	// Init BC location cache
	self.bc_last_get_location_time = 0;
	self.bc_cache_time = 0;
	self.bc_locations = [];

	// needs to run after the name has been set since bcs changes self.voice from "multilingual"
	//  to something more specific
	self thread animscripts\squadManager::addToSquad();// slooooow
}


// Debug thread to see when stances are being allowed
PollAllowedStancesThread()
{
	for ( ;; )
	{
		if ( self isStanceAllowed( "stand" ) )
		{
			line[ 0 ] = "stand allowed";
			color[ 0 ] = ( 0, 1, 0 );
		}
		else
		{
			line[ 0 ] = "stand not allowed";
			color[ 0 ] = ( 1, 0, 0 );
		}
		if ( self isStanceAllowed( "crouch" ) )
		{
			line[ 1 ] = "crouch allowed";
			color[ 1 ] = ( 0, 1, 0 );
		}
		else
		{
			line[ 1 ] = "crouch not allowed";
			color[ 1 ] = ( 1, 0, 0 );
		}
		if ( self isStanceAllowed( "prone" ) )
		{
			line[ 2 ] = "prone allowed";
			color[ 2 ] = ( 0, 1, 0 );
		}
		else
		{
			line[ 2 ] = "prone not allowed";
			color[ 2 ] = ( 1, 0, 0 );
		}


		aboveHead = self getshootatpos() + ( 0, 0, 30 );
		offset = ( 0, 0, -10 );
		for ( i = 0 ; i < line.size ; i++ )
		{
			textPos = ( aboveHead[ 0 ] + ( offset[ 0 ] * i ), aboveHead[ 1 ] + ( offset[ 1 ] * i ), aboveHead[ 2 ] + ( offset[ 2 ] * i ) );
			print3d( textPos, line[ i ], color[ i ], 1, 0.75 );	// origin, text, RGB, alpha, scale
		}
		wait 0.05;
	}
}

SetupUniqueAnims()
{
	if ( !isDefined( self.animplaybackrate ) || !isDefined( self.moveplaybackrate ) )
	{
		set_anim_playback_rate();
	}
}

set_anim_playback_rate()
{
	self.animplaybackrate = 0.9 + randomfloat( 0.2 );
	self.moveTransitionRate = 0.9 + randomfloat( 0.2 );
	self.moveplaybackrate = 1;
	self.sideStepRate = 1.35;
}


infiniteLoop( one, two, three, whatever )
{
	anim waittill( "new exceptions" );
}

empty( one, two, three, whatever )
{
}

enemyNotify()
{
	self endon( "death" );
	if ( 1 ) return;
	for ( ;; )
	{
		self waittill( "enemy" );
		if ( !isalive( self.enemy ) )
			continue;
		while ( isplayer( self.enemy ) )
		{
			if ( hasEnemySightPos() )
				level._lastPlayerSighted = gettime();
			wait( 2 );
		}
	}
}


initWindowTraverse()
{
	// used to blend the traverse window_down smoothly at the end
	level._window_down_height[ 0 ] = -36.8552;
	level._window_down_height[ 1 ] = -27.0095;
	level._window_down_height[ 2 ] = -15.5981;
	level._window_down_height[ 3 ] = -4.37769;
	level._window_down_height[ 4 ] = 17.7776;
	level._window_down_height[ 5 ] = 59.8499;
	level._window_down_height[ 6 ] = 104.808;
	level._window_down_height[ 7 ] = 152.325;
	level._window_down_height[ 8 ] = 201.052;
	level._window_down_height[ 9 ] = 250.244;
	level._window_down_height[ 10 ] = 298.971;
	level._window_down_height[ 11 ] = 330.681;
}

pre_anim_init()
{	
	anim.NotFirstTime = true;

	anim.useFacialAnims = false;// remove me when facial anims are fixed

	maps\_load::init_level_players();

	level._player.invul = false;
	level._nextGrenadeDrop = randomint( 3 );
	level._lastPlayerSighted = 100;
	
	anim.defaultException = animscripts\init_common::empty;

	initDeveloperDvars();

	setdvar( "scr_expDeathMayMoveCheck", "on" );

	maps\_names::setup_names();

	anim.animFlagNameIndex = 0;
}

post_anim_init()
{
	anim.combatMemoryTimeConst = 10000;
	anim.combatMemoryTimeRand = 6000;

	initAdvanceToEnemy();

	setEnv( "none" );
	
	if ( !isdefined( anim.optionalStepEffectFunction ) )
	{
		anim.optionalStepEffectSmallFunction = animscripts\shared::playFootStepEffectSmall;
		anim.optionalStepEffectFunction = animscripts\shared::playFootStepEffect;
	}

	if ( !isdefined( anim.optionalStepEffects ) )
		anim.optionalStepEffects = [];

	if ( !isdefined( anim.optionalStepEffectsSmall ) )
		anim.optionalStepEffectsSmall = [];


	anim.shootEnemyWrapper_func = ::shootEnemyWrapper_shootNotify;

	// scripted mode uses a special function. Faster to use a function pointer based on script than use an if statement in a popular loop.
	anim.fire_notetrack_functions[ "scripted" ] = animscripts\shared::fire_straight;
	anim.fire_notetrack_functions[ "custom" ] = animscripts\shared::fire_straight;
	anim.fire_notetrack_functions[ "cover_right" ] = animscripts\shared::shootNotetrack;
	anim.fire_notetrack_functions[ "cover_left" ] = animscripts\shared::shootNotetrack;
	anim.fire_notetrack_functions[ "cover_crouch" ] = animscripts\shared::shootNotetrack;
	anim.fire_notetrack_functions[ "cover_stand" ] = animscripts\shared::shootNotetrack;
	anim.fire_notetrack_functions[ "move" ] = animscripts\shared::shootNotetrack;

	// string based array for notetracks
	animscripts\shared::registerNoteTracks();

	 /#
	setDvarIfUninitialized( "debug_delta", "off" );
	#/
	
	if ( !isdefined( level._flag ) )
		common_scripts\utility::init_flags();

	maps\_gameskill::setSkill();
	level._painAI = undefined;

	animscripts\SetPoseMovement::InitPoseMovementFunctions();
	animscripts\face::InitLevelFace();

	// probabilities of burst fire shots
	anim.burstFireNumShots =     array( 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 5 );
	anim.fastBurstFireNumShots = array( 2, 3, 3, 3, 4, 4, 4, 5, 5 );
	anim.semiFireNumShots =      array( 1, 2, 2, 3, 3, 4, 4, 4, 4, 5, 5, 5 );

	anim.badPlaces = [];// queue for animscript badplaces
	anim.badPlaceInt = 0;// assigns unique names to animscript badplaces since we cant save a badplace as an entity

	anim.player = getentarray( "player", "classname" )[ 0 ];

	initBattlechatter();

	initWindowTraverse();

	animscripts\flashed::initFlashed();

	animscripts\cqb::setupCQBPointsOfInterest();

	initDeaths();
	
	setGlobalAimSettings();

	anim.lastCarExplosionTime = -100000;

	setupRandomTable();

	level._player thread watchReloading();

	thread AITurnNotifies();
}



initDeveloperDvars()
{
/#
	if ( getdebugdvar( "debug_noanimscripts" ) == "" )
		setdvar( "debug_noanimscripts", "off" );
	else if ( getdebugdvar( "debug_noanimscripts" ) == "on" )
		anim.defaultException = animscripts\init_common::infiniteLoop;

	if ( getdebugdvar( "debug_grenadehand" ) == "" )
		setdvar( "debug_grenadehand", "off" );
	if ( getdebugdvar( "anim_dotshow" ) == "" )
		setdvar( "anim_dotshow", "-1" );
	if ( getdebugdvar( "anim_debug" ) == "" )
		setdvar( "anim_debug", "" );
	if ( getdebugdvar( "debug_misstime" ) == "" )
		setdvar( "debug_misstime", "" );
#/
}

initBattlechatter()
{
	animscripts\squadmanager::init_squadManager();
	anim.player thread animscripts\squadManager::addPlayerToSquad();

	animscripts\battleChatter::init_battleChatter();
	anim.player thread animscripts\battleChatter_ai::addToSystem();

	anim thread animscripts\battleChatter::bcsDebugWaiter();
}

initDeaths()
{
	anim.numDeathsUntilCrawlingPain = randomintrange( 0, 15 );
	anim.numDeathsUntilCornerGrenadeDeath = randomintrange( 0, 10 );
	anim.nextCrawlingPainTime = gettime() + randomintrange( 0, 20000 );
	anim.nextCrawlingPainTimeFromLegDamage = gettime() + randomintrange( 0, 10000 );
	anim.nextCornerGrenadeDeathTime = gettime() + randomintrange( 0, 15000 );
}




initAdvanceToEnemy()
{
	// use team ID for now. Should be done per group of AI or something more specific
	level._lastAdvanceToEnemyTime = [];
	level._lastAdvanceToEnemyTime[ "axis" ] = 0;
	level._lastAdvanceToEnemyTime[ "allies" ] = 0;
	level._lastAdvanceToEnemyTime[ "team3" ] = 0;
	level._lastAdvanceToEnemyTime[ "neutral" ] = 0;
	
	level._lastAdvanceToEnemyDest = [];
	level._lastAdvanceToEnemyDest[ "axis" ] = ( 0, 0, 0 );
	level._lastAdvanceToEnemyDest[ "allies" ] = ( 0, 0, 0 );
	level._lastAdvanceToEnemyDest[ "team3" ] = ( 0, 0, 0 );
	level._lastAdvanceToEnemyDest[ "neutral" ] = ( 0, 0, 0 );

	level._lastAdvanceToEnemySrc = [];
	level._lastAdvanceToEnemySrc[ "axis" ] = ( 0, 0, 0 );
	level._lastAdvanceToEnemySrc[ "allies" ] = ( 0, 0, 0 );
	level._lastAdvanceToEnemySrc[ "team3" ] = ( 0, 0, 0 );
	level._lastAdvanceToEnemySrc[ "neutral" ] = ( 0, 0, 0 );

	level._lastAdvanceToEnemyAttacker = [];
	
	level._advanceToEnemyGroup = [];
	level._advanceToEnemyGroup[ "axis" ] = 0;
	level._advanceToEnemyGroup[ "allies" ] = 0;
	level._advanceToEnemyGroup[ "team3" ] = 0;
	level._advanceToEnemyGroup[ "neutral" ] = 0;
	
	level._advanceToEnemyInterval = 30000;	// how often AI will try to run directly to their enemy if the enemy is not visible
	level._advanceToEnemyGroupMax = 3;		// group size for AI running to their enemy
}


AITurnNotifies()
{
	numTurnsThisFrame = 0;
	maxAIPerFrame = 3;
	while ( 1 )
	{
		ai = getAIArray();
		if ( ai.size == 0 )
		{
			wait .05;
			numTurnsThisFrame = 0;
			continue;
		}
		for ( i = 0; i < ai.size; i++ )
		{
			if ( !isdefined( ai[ i ] ) )
				continue;
			ai[ i ] notify( "do_slow_things" );
			numTurnsThisFrame++ ;
			if ( numTurnsThisFrame == maxAIPerFrame )
			{
				wait .05;
				numTurnsThisFrame = 0;
			}
		}
	}
}

setNextPlayerGrenadeTime()
{
	assert( isPlayer( self ) );
	waittillframeend;
	// might not be defined if maps\_load::main() wasn't called
	if ( isdefined( self.gs.playerGrenadeRangeTime ) )
	{
		maxTime = int( self.gs.playerGrenadeRangeTime * 0.7 );
		if ( maxTime < 1 )
			maxTime = 1;
		self.grenadeTimers[ "fraggrenade" ] = randomIntRange( 0, maxTime );
		self.grenadeTimers[ "flash_grenade" ] = randomIntRange( 0, maxTime );
	}
	if ( isdefined( self.gs.playerDoubleGrenadeTime ) )
	{
		maxTime = int( self.gs.playerDoubleGrenadeTime );
		minTime = int( maxTime / 2 );
		if ( maxTime <= minTime )
			maxTime = minTime + 1;
		self.grenadeTimers[ "double_grenade" ] = randomIntRange( minTime, maxTime );
	}
}

beginGrenadeTracking()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "grenade_fire", grenade, weaponName );
		grenade thread grenade_earthQuake();
	}
}

setupRandomTable()
{
	// 60 is chosen because it is divisible by 1,2,3,4,5, and 6,
	// and it's also high enough to get some good randomness over different seed values
	anim.randomIntTableSize = 60;

	// anim.randomIntTable is a permutation of integers 0 through anim.randomIntTableSize - 1
	anim.randomIntTable = [];
	for ( i = 0; i < anim.randomIntTableSize; i++ )
		anim.randomIntTable[ i ] = i;

	for ( i = 0; i < anim.randomIntTableSize; i++ )
	{
		switchwith = randomint( anim.randomIntTableSize );
		temp = anim.randomIntTable[ i ];
		anim.randomIntTable[ i ] = anim.randomIntTable[ switchwith ];
		anim.randomIntTable[ switchwith ] = temp;
	}
}

onDeath()
{
	self waittill( "death" );
	if ( !isdefined( self ) )
	{
		// we were deleted and we're not running the death script.
		// still safe to access our variables as a removed entity though:
		if ( isdefined( self.a.usingTurret ) )
			self.a.usingTurret delete();
	}
}

init_animset_custom_stand( fireAnim, aimStraight, idleAnim, reloadAnim )
{
	assert( isdefined( anim.animsets ) && isdefined( anim.animsets.defaultStand ) );
	
	anim.initAnimSet = anim.animsets.defaultStand;

	if ( isdefined( aimStraight ) )
		anim.initAnimSet[ "straight_level" ] = aimStraight;
	
	if ( isdefined( fireAnim ) )
	{
		anim.initAnimSet[ "fire" ] = fireAnim;
		anim.initAnimSet[ "single" ] = array( fireAnim );
		set_animarray_custom_burst_and_semi_fire_stand( fireAnim );
	}

	if ( isdefined( idleAnim ) )
		anim.initAnimSet[ "exposed_idle" ] = array( idleAnim );

	if ( isdefined( reloadAnim ) )
	{
		anim.initAnimSet[ "reload" ] = array( reloadAnim );
		anim.initAnimSet[ "reload_crouchhide" ] = array( reloadAnim );
	}

	self.combatStandAnims = anim.initAnimSet;
}

////////////////////////////////////////////
// Crouch
////////////////////////////////////////////

set_animarray_crouching()
{
	if ( usingSidearm() )
		animscripts\shared::placeWeaponOn( self.primaryweapon, "right" );
	
	if ( isdefined( self.combatCrouchAnims ) )
	{
		assert( isArray( self.combatCrouchAnims ) );
		self.a.array = self.combatCrouchAnims;
	}
	else if ( usingRocketLauncher() )
	{
		self.a.array = anim.animsets.rpgCrouch;
	}
	else if ( isdefined( self.weapon ) && weapon_pump_action_shotgun() )
	{
		self.a.array = anim.animsets.shotgunCrouch;
	}
	else
	{
		self.a.array = anim.animsets.defaultCrouch;
	}
}

////////////////////////////////////////////
// Stand
////////////////////////////////////////////

set_animarray_standing()
{
	if ( usingSidearm() )
	{
		self.a.array = anim.animsets.pistolStand;
	}
	else if ( isdefined( self.combatStandAnims ) )
	{
		assert( isArray( self.combatStandAnims ) );
		self.a.array = self.combatStandAnims;
	}
	else if ( isdefined( self.heat ) )
	{
		self.a.array = anim.animsets.heatStand;
	}
	else if ( usingRocketLauncher() )
	{
		self.a.array = anim.animsets.rpgStand;
	}
	else if ( isdefined( self.weapon ) && weapon_pump_action_shotgun() )
	{
		self.a.array = anim.animsets.shotgunStand;
	}
	else if ( self isCQBWalking() )
	{
		if ( isdefined( self.combatStandCQBAnims ) )
		{
			assert( isArray( self.combatStandCQBAnims ) );
			self.a.array = self.combatStandCQBAnims;
		}
		else
		{
			self.a.array = anim.animsets.cqbStand;
		}
	}
	else
	{
		self.a.array = anim.animsets.defaultStand;
	}
}


////////////////////////////////////////////
// Prone
////////////////////////////////////////////

set_animarray_prone()
{
	if ( usingSidearm() )
		animscripts\shared::placeWeaponOn( self.primaryweapon, "right" );

	self.a.array = anim.animsets.defaultProne;
}

MAX_RUN_N_GUN_ANGLE = 130;
RUN_N_GUN_TRANSITION_POINT = 60 / MAX_RUN_N_GUN_ANGLE;

set_animset_run_n_gun()
{
	self.maxRunNGunAngle = MAX_RUN_N_GUN_ANGLE;
	self.runNGunTransitionPoint = RUN_N_GUN_TRANSITION_POINT;
	self.runNGunIncrement = 0.3;
	
	self.runNGunAnims = anim.runNGunAnims;
}


set_ambush_sidestep_anims()
{
	assert( isdefined( self.a.moveAnimSet ) );

	self.a.moveAnimSet = array_combine_keys( self.a.moveAnimSet, anim.moveAnimSet );
}


set_animarray_custom_burst_and_semi_fire_stand( fireAnim )
{
	anim.initAnimSet[ "burst2" ] = fireAnim;
	anim.initAnimSet[ "burst3" ] = fireAnim;
	anim.initAnimSet[ "burst4" ] = fireAnim;
	anim.initAnimSet[ "burst5" ] = fireAnim;
	anim.initAnimSet[ "burst6" ] = fireAnim;

	anim.initAnimSet[ "semi2" ] = fireAnim;
	anim.initAnimSet[ "semi3" ] = fireAnim;
	anim.initAnimSet[ "semi4" ] = fireAnim;
	anim.initAnimSet[ "semi5" ] = fireAnim;
}

set_animset_complete_custom_stand( completeSet )
{
	self.combatStandAnims = completeSet;
}


set_animset_complete_custom_crouch( completeSet )
{
	self.combatCrouchAnims = completeSet;
}

clear_custom_animset()
{
	self.customMoveAnimSet = undefined;
	self.customIdleAnimSet = undefined;

	self.combatStandAnims = undefined;
	self.combatCrouchAnims = undefined;
	self.combatStandCQBAnims = undefined;

	self.customTurnAnimSet = undefined;

	self.customAnimFunc = undefined;

	self.customCoverEnterTrans = undefined;
	self.customCoverExitTrans = undefined;
	
	self.customDeathAnimSet = undefined;
	
	self.customPainAnimSet = undefined;
}

addGrenadeThrowAnimOffset( throwAnim, offset )
{
	if ( !isdefined( anim.grenadeThrowAnims ) )
	{
		anim.grenadeThrowAnims = [];
		anim.grenadeThrowOffsets = [];
	}

	assert( anim.grenadeThrowAnims.size == anim.grenadeThrowOffsets.size );

	index = anim.grenadeThrowAnims.size;
	anim.grenadeThrowAnims[ index ] = throwAnim;
	anim.grenadeThrowOffsets[ index ] = offset;
}