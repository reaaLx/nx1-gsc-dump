#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;


init()
{
	level._sentryType = [];
	level._sentryType[ "sentry_minigun" ] 	= "sentry";
	level._sentryType[ "minigun_turret" ] 	= "minigun_turret";
	level._sentryType[ "gl_turret" ] 		= "gl_turret";
	
	level._killStreakFuncs[ level._sentryType[ "sentry_minigun" ] ] 	= ::tryUseAutoSentry;
	level._killStreakFuncs[ level._sentryType[ "minigun_turret" ] ] 	= ::tryUseMinigun;
	level._killStreakFuncs[ level._sentryType[ "gl_turret" ] ] 		= ::tryUseGL;
	
	level._sentrySettings = [];
	
	level._sentrySettings[ "sentry_minigun" ] = spawnStruct();
	level._sentrySettings[ "sentry_minigun" ].burstMin = 20;
	level._sentrySettings[ "sentry_minigun" ].burstMax = 120;
	level._sentrySettings[ "sentry_minigun" ].pauseMin = 0.15;
	level._sentrySettings[ "sentry_minigun" ].pauseMax = 0.35;	
	level._sentrySettings[ "sentry_minigun" ].sentryModeOn = "sentry";	
	level._sentrySettings[ "sentry_minigun" ].sentryModeOff = "sentry_offline";	
	level._sentrySettings[ "sentry_minigun" ].timeOut = 90.0;	
	level._sentrySettings[ "sentry_minigun" ].spinupTime = 0.05;	
	level._sentrySettings[ "sentry_minigun" ].overheatTime = 8.0;	
	level._sentrySettings[ "sentry_minigun" ].cooldownTime = 0.1;	
	level._sentrySettings[ "sentry_minigun" ].fxTime = 0.3;	
	level._sentrySettings[ "sentry_minigun" ].weaponInfo = "sentry_minigun_mp";
	level._sentrySettings[ "sentry_minigun" ].modelBase = "sentry_minigun";
	level._sentrySettings[ "sentry_minigun" ].modelPlacement = "sentry_minigun_obj";
	level._sentrySettings[ "sentry_minigun" ].modelPlacementFailed = "sentry_minigun_obj_red";
	level._sentrySettings[ "sentry_minigun" ].modelDestroyed = "sentry_minigun_destroyed";	
	level._sentrySettings[ "sentry_minigun" ].hintString = &"SENTRY_PICKUP";	
	level._sentrySettings[ "sentry_minigun" ].headIcon = true;	
	level._sentrySettings[ "sentry_minigun" ].teamSplash = "used_sentry";	
	level._sentrySettings[ "sentry_minigun" ].shouldSplash = false;	
	level._sentrySettings[ "sentry_minigun" ].flashTime = 3;
	level._sentrySettings[ "sentry_minigun" ].stunTime = 6;

	level._sentrySettings[ "minigun_turret" ] = spawnStruct();
	level._sentrySettings[ "minigun_turret" ].sentryModeOn = "manual";	
	level._sentrySettings[ "minigun_turret" ].sentryModeOff = "sentry_offline";	
	level._sentrySettings[ "minigun_turret" ].timeOut = 90.0;	
	level._sentrySettings[ "minigun_turret" ].spinupTime = 0.05;	
	level._sentrySettings[ "minigun_turret" ].overheatTime = 4.0;	
	level._sentrySettings[ "minigun_turret" ].cooldownTime = 0.5;	
	level._sentrySettings[ "minigun_turret" ].fxTime = 0.3;	
	level._sentrySettings[ "minigun_turret" ].weaponInfo = "manned_minigun_turret_mp";
	level._sentrySettings[ "minigun_turret" ].modelBase = "sentry_minigun";
	level._sentrySettings[ "minigun_turret" ].modelPlacement = "sentry_minigun_obj";
	level._sentrySettings[ "minigun_turret" ].modelPlacementFailed = "sentry_minigun_obj_red";
	level._sentrySettings[ "minigun_turret" ].modelDestroyed = "sentry_minigun_destroyed";		
	level._sentrySettings[ "minigun_turret" ].hintString = &"MP_MINIGUN_TURRET_PICKUP";	
	level._sentrySettings[ "minigun_turret" ].ownerHintString = &"MP_DOUBLE_TAP_TO_CARRY";	
	level._sentrySettings[ "minigun_turret" ].headIcon = false;	
	level._sentrySettings[ "minigun_turret" ].teamSplash = "used_minigun_turret";	
	level._sentrySettings[ "minigun_turret" ].shouldSplash = false;	

	level._sentrySettings[ "gl_turret" ] = spawnStruct();
	level._sentrySettings[ "gl_turret" ].sentryModeOn = "manual";	
	level._sentrySettings[ "gl_turret" ].sentryModeOff = "sentry_offline";	
	level._sentrySettings[ "gl_turret" ].timeOut = 90.0;	
	level._sentrySettings[ "gl_turret" ].spinupTime = 0.05;	
	level._sentrySettings[ "gl_turret" ].overheatTime = 2.5;	
	level._sentrySettings[ "gl_turret" ].cooldownTime = 0.5;	
	level._sentrySettings[ "gl_turret" ].fxTime = 0.3;	
	level._sentrySettings[ "gl_turret" ].weaponInfo = "manned_gl_turret_mp";
	level._sentrySettings[ "gl_turret" ].modelBase = "sentry_minigun";
	level._sentrySettings[ "gl_turret" ].modelPlacement = "sentry_minigun_obj";
	level._sentrySettings[ "gl_turret" ].modelPlacementFailed = "sentry_minigun_obj_red";
	level._sentrySettings[ "gl_turret" ].modelDestroyed = "sentry_minigun_destroyed";		
	level._sentrySettings[ "gl_turret" ].hintString = &"MP_MINIGUN_TURRET_PICKUP";	
	level._sentrySettings[ "gl_turret" ].ownerHintString = &"MP_DOUBLE_TAP_TO_CARRY";	
	level._sentrySettings[ "gl_turret" ].headIcon = false;	
	level._sentrySettings[ "gl_turret" ].teamSplash = "used_gl_turret";	
	level._sentrySettings[ "gl_turret" ].shouldSplash = false;	

	foreach ( sentryInfo in level._sentrySettings )
	{
		precacheItem( sentryInfo.weaponInfo );
		precacheModel( sentryInfo.modelBase );		
		precacheModel( sentryInfo.modelPlacement );		
		precacheModel( sentryInfo.modelPlacementFailed );		
		precacheModel( sentryInfo.modelDestroyed );		
		PreCacheString( sentryInfo.hintString );	
		if( IsDefined( sentryInfo.ownerHintString ) )
			PreCacheString( sentryInfo.ownerHintString );
	}

	level._effect[ "sentry_overheat_mp" ]	= loadfx( "smoke/sentry_turret_overheat_smoke" );
	level._effect[ "sentry_explode_mp" ]	= loadfx( "explosions/sentry_gun_explosion" );
	level._effect[ "sentry_smoke_mp" ]		= loadfx( "smoke/car_damage_blacksmoke" );
}

/* ============================
	Killstreak Functions
   ============================ */

tryUseAutoSentry( lifeId )
{
	result = self giveSentry( "sentry_minigun" );
	if ( result )
		self maps\mp\_matchdata::logKillstreakEvent( "sentry", self.origin );
	
	return ( result );
}

tryUseMinigun( lifeId )
{
	result = self giveSentry( "minigun_turret" );
	if ( result )
		self maps\mp\_matchdata::logKillstreakEvent( "minigun_turret", self.origin );
	
	return ( result );	
}

tryUseGL( lifeId )
{
	result = self giveSentry( "gl_turret" );
	if ( result )
		self maps\mp\_matchdata::logKillstreakEvent( "gl_turret", self.origin );

	return ( result );	
}

tryUseAutoGlSentry( lifeId )
{
	result = self giveSentry( "sentry_gun" );
	if ( result )
		self maps\mp\_matchdata::logKillstreakEvent( "sentry_gl", self.origin );
		
	return ( result );
}


giveSentry( sentryType )
{
	self.last_sentry = sentryType;

	sentryGun = createSentryForPlayer( sentryType, self );
	
	//	returning from this streak activation seems to strip this?
	//	manually removing and restoring
	self removePerks();		
	
	self setCarryingSentry( sentryGun, true );
	
	self thread waitRestorePerks();
	
	// if we failed to place the sentry, it will have been deleted at this point
	if ( isDefined( sentryGun ) )
		return true;
	else
		return false;
}


/* ============================
	Player Functions
   ============================ */

setCarryingSentry( sentryGun, allowCancel )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	assert( isReallyAlive( self ) );
	
	sentryGun sentry_setCarried( self );
	
	self _disableWeapon();

	self notifyOnPlayerCommand( "place_sentry", "+attack" );
	self notifyOnPlayerCommand( "cancel_sentry", "+actionslot 4" );
	
	for ( ;; )
	{
		result = waittill_any_return( "place_sentry", "cancel_sentry" );

		if ( result == "cancel_sentry" )
		{
			if ( !allowCancel )
				continue;
				
			sentryGun sentry_setCancelled();
			self _enableWeapon();
			return false;
		}

		if ( !sentryGun.canBePlaced )
			continue;
			
		sentryGun sentry_setPlaced();		
		self _enableWeapon();		
		return true;
	}
}

removeWeapons()
{
	if ( self HasWeapon( "riotshield_mp" ) )
	{
		self.restoreWeapon = "riotshield_mp";
		self takeWeapon( "riotshield_mp" );
	}	
}

removePerks()
{
	if ( self _hasPerk( "specialty_explosivebullets" ) )
	{
		self.restorePerk = "specialty_explosivebullets";
		self _unsetPerk( "specialty_explosivebullets" );
	}		
}

restoreWeapons()
{
	if ( isDefined( self.restoreWeapon ) )	
	{
		self _giveWeapon( self.restoreWeapon );
		self.restoreWeapon = undefined;
	}	
}

restorePerks()
{
	if ( isDefined( self.restorePerk ) )
	{
		self _setPerk( self.restorePerk );	
		self.restorePerk = undefined;
	}	
}

waitRestorePerks()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	wait( 0.05 );
	self restorePerks();
}

/* ============================
	Sentry Functions
   ============================ */

createSentryForPlayer( sentryType, owner )
{
	assertEx( isDefined( owner ), "createSentryForPlayer() called without owner specified" );

	sentryGun = spawnTurret( "misc_turret", owner.origin, level._sentrySettings[ sentryType ].weaponInfo );
	sentryGun.angles = owner.angles;
	
	sentryGun sentry_initSentry( sentryType, owner );
	
	return ( sentryGun );	
}


sentry_initSentry( sentryType, owner )
{
	self.sentryType = sentryType;
	self.canBePlaced = true;

	self setModel( level._sentrySettings[ self.sentryType ].modelBase );
	self.health = 1000;
	self.shouldSplash = true; // we only want to splash on the first placement

	self setCanDamage( true );
	switch( sentryType )
	{
	case "minigun_turret":
	case "gl_turret":
		self SetLeftArc( 80 );
		self SetRightArc( 80 );
		self SetBottomArc( 50 );
		self setDefaultDropPitch( 0.0 );
		self.originalOwner = owner;
		break;
	default:
		self makeTurretInoperable();
		self setDefaultDropPitch( -89.0 );	// setting this mainly prevents Turret_RestoreDefaultDropPitch() from running
		break;
	}
	
	self setTurretModeChangeWait( true );
//	self setConvergenceTime( .25, "pitch" );
//	self setConvergenceTime( .25, "yaw" );
	self sentry_setInactive();
	
	self sentry_setOwner( owner );
	self thread sentry_handleDamage();
	self thread sentry_handleDeath();
	self thread sentry_timeOut();
	self thread sentry_handleEmpDamage();
	
	switch( sentryType )
	{
	case "minigun_turret":
		self.momentum = 0;
		self.heatLevel = 0;
		self.overheated = false;		
		self thread sentry_heatMonitor();
		break;
	case "gl_turret":
		self.momentum = 0;
		self.heatLevel = 0;
		self.cooldownWaitTime = 0;
		self.overheated = false;		
		self thread turret_heatMonitor();
		self thread turret_coolMonitor();
		break;
	default:
		self thread sentry_handleUse();
		self thread sentry_attackTargets();
		self thread sentry_beepSounds();	
		break;
	}
}


/* ============================
	Sentry Handlers
   ============================ */

sentry_handleDamage()
{
	// use a health buffer to prevent the turret from dying to friendly fire
	healthBuffer = 20000;
	self.health += healthbuffer;

	while ( self.health > 0 )
	{
		self waittill( "damage", amount, attacker, dir, point, type );
		
		if ( isDefined( attacker ) && isPlayer( attacker ) && attacker != self.owner && attacker isFriendlyToSentry( self ) && !isDefined( level._nukeDetonated ) )
		{
			self.health += amount;
			continue;
		}

		// 7x damage for explosives - GRENADES
		if ( isExplosiveDamage( type ) )
			self.health -= (amount * 1);
			
		if ( type == "MOD_MELEE" )
			self.health = 0;

		if ( isPlayer( attacker ) )
		{
			attacker maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "sentry" );

			if ( attacker _hasPerk( "specialty_armorpiercing" ) )
			{
				damageAdd = amount*level._armorPiercingMod;
				self.health -= int(damageAdd);
			}			
		}

		if ( self.health - healthbuffer < 0 )
		{
			thread maps\mp\gametypes\_missions::vehicleKilled( self.owner, self, undefined, attacker, amount, type );

			if ( isPlayer( attacker ) && (!isDefined(self.owner) || attacker != self.owner) )
			{
				attacker thread maps\mp\gametypes\_rank::giveRankXP( "kill", 100 );				
				attacker notify( "destroyed_killstreak" );
			}
		
			if ( isDefined( self.owner ) )
				self.owner thread leaderDialogOnPlayer( "sentry_destroyed" );
		
			self notify ( "death" );
			return;
		}
	}
}


sentry_handleEmpDamage()
{
	self endon( "deleted" );
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "emp_damage", attacker, type );

		// TODO: friendly fire check here

		self thread sentry_burstFireStop();

		self thread sentry_setInactive();

		duration = 0;

		switch( type )
		{
		case "flash":
			duration = level._sentrySettings[ "sentry_minigun" ].flashTime;
			break;

		case "stun":
			duration = level._sentrySettings[ "sentry_minigun" ].stunTime;
			break;

		case "emp":
			duration = -1;
			break;

		default:
			assertEx( undefined, "emp_damage type is not set correctly!, type = " + type );
			break;
		}

		if( duration > 0 )
		{
			wait duration;
			self thread sentry_setActive();
		}
		else if( duration == -1 )
		{
			// blow up
			self notify ( "death" );
		}
	}
}


sentry_handleDeath()
{
	entNum = self GetEntityNumber();
	
	switch( self.sentryType )
	{
	case "gl_turret":
		break;
	default:
		self addToTurretList( entNum );
		break;
	}
	
	self waittill ( "death" );

	switch( self.sentryType )
	{
	case "gl_turret":
		break;
	default:
		self removeFromTurretList( entNum );
		break;
	}
	
	// this handles cases of deletion
	if ( !isDefined( self ) )
		return;
		
	self setModel( level._sentrySettings[ self.sentryType ].modelDestroyed );

	self sentry_setInactive();
	self setDefaultDropPitch( 40 );
	self SetSentryOwner( undefined );
	self SetTurretMinimapVisible( false );
	
	if( IsDefined( self.ownerTrigger ) )
		self.ownerTrigger delete();

	self playSound( "sentry_explode" );		
	
	switch( self.sentryType )
	{
	case "minigun_turret":
	case "gl_turret":
		self.forceDisable = true;
		self TurretFireDisable(); 
		break;
	default:
		break;
	}

	if ( isDefined( self.inUseBy ) )
	{
		playFxOnTag( getFx( "sentry_explode_mp" ), self, "tag_origin" );
		playFxOnTag( getFx( "sentry_smoke_mp" ), self, "tag_aim" );
		
		self.inUseBy.turret_overheat_bar destroyElem();
		self.inUseBy restorePerks();
		self.inUseBy restoreWeapons();
		self.inUseBy TurretDismount();				
		
		self notify( "deleting" );
		wait ( 1.0 );
		StopFXOnTag( getFx( "sentry_explode_mp" ), self, "tag_origin" );
		StopFXOnTag( getFx( "sentry_smoke_mp" ), self, "tag_aim" );
	}	
	else
	{		
		playFxOnTag( getFx( "sentry_explode_mp" ), self, "tag_aim" );
		wait ( 1.5 );		
		self playSound( "sentry_explode_smoke" );
		for ( smokeTime = 8; smokeTime > 0; smokeTime -= 0.4 )
		{
			playFxOnTag( getFx( "sentry_smoke_mp" ), self, "tag_aim" );
			wait ( 0.4 );
		}
		self notify( "deleting" );
	}
		
	self delete();
}


sentry_handleUse()
{
	self endon ( "death" );
	level endon ( "game_ended" );
	
	for ( ;; )
	{
		self waittill ( "trigger", player );
		
		assert( player == self.owner );
		assert( !isDefined( self.carriedBy ) );

		if ( !isReallyAlive( player ) )
			continue;
		
		player setCarryingSentry( self, false );
	}
}

turret_handlePickup( turret ) // self == owner (player)
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	turret endon( "death" );

	if( !IsDefined( turret.ownerTrigger ) )
	{
		return;
	}

	
	buttonTime = 0;
	for ( ;; )
	{
		if( IsAlive( self ) && 
			self IsTouching( turret.ownerTrigger ) && 
			!IsDefined( turret.inUseBy ) && 
			!IsDefined( turret.carriedBy ) &&
			self IsOnGround() )
		{
			if ( self UseButtonPressed() )
			{
				if( IsDefined( self.using_remote_turret ) && self.using_remote_turret )
					continue;

				buttonTime = 0;
				while ( self UseButtonPressed() )
				{
					buttonTime += 0.05;
					wait( 0.05 );
				}

				println( "pressTime1: " + buttonTime );
				if ( buttonTime >= 0.5 )
					continue;

				buttonTime = 0;
				while ( !self UseButtonPressed() && buttonTime < 0.5 )
				{
					buttonTime += 0.05;
					wait( 0.05 );
				}

				println( "delayTime: " + buttonTime );
				if ( buttonTime >= 0.5 )
					continue;

				if ( !isReallyAlive( self ) )
					continue;

				if( IsDefined( self.using_remote_turret ) && self.using_remote_turret )
					continue;

				turret setMode( level._sentrySettings[ turret.sentryType ].sentryModeOff );
				self thread setCarryingSentry( turret, false );
				turret.ownerTrigger delete();
				return;
			}
		}
		wait( 0.05 );
	}
}

turret_handleUse() // self == turret
{
	self notify ( "turret_handluse" );
	self endon ( "turret_handleuse" );
	self endon ( "deleting" );
	level endon ( "game_ended" );
	
	self.forceDisable = false;
	colorStable = (1, 0.9, 0.7);
	colorUnstable = (1, 0.65, 0);
	colorOverheated = (1, 0.25, 0);
		
	for( ;; )
	{
		self waittill( "trigger", player );	
		
		//	exceptions
		if( isDefined( self.carriedBy ) )
			continue;
		if( isDefined( self.inUseBy ) )
			continue;
		if( !isReallyAlive( player ) )
			continue;		
		player removePerks();
		player removeWeapons();	
		
		//	ownership
		self.inUseBy = player;
		self setMode( level._sentrySettings[ self.sentryType ].sentryModeOff );
		self sentry_setOwner( player );	
		self setMode( level._sentrySettings[ self.sentryType ].sentryModeOn );							

		player thread turret_shotMonitor( self );
		
		//	overheat bar
		player.turret_overheat_bar = player createBar( colorStable, 100, 6 );
		player.turret_overheat_bar setPoint("CENTER", "BOTTOM", 0, -70 );		
		player.turret_overheat_bar.alpha = 0.65;
		player.turret_overheat_bar.bar.alpha = 0.65;
		
		//lastHeatLevel = self.heatLevel;
		//firing = false;
		
		playingHeatFX = false;
		
		for( ;; )
		{
			//	exceptions
			if ( !isReallyAlive( player ) )
			{
				self.inUseBy = undefined;
				player.turret_overheat_bar destroyElem();
				break;	
			}					
			if ( !player IsUsingTurret() )
			{
				self notify( "player_dismount" );
				self.inUseBy = undefined;
				player.turret_overheat_bar destroyElem();
				player restorePerks();
				player restoreWeapons();
				self setHintString( level._sentrySettings[ self.sentryType ].hintString );
				self setMode( level._sentrySettings[ self.sentryType ].sentryModeOff );
				self sentry_setOwner( self.originalOwner );	
				self setMode( level._sentrySettings[ self.sentryType ].sentryModeOn );							
				break;
			}
						
			if ( self.heatLevel >= level._sentrySettings[ self.sentryType ].overheatTime )
			{
				barFrac = 1;
			}
			else
				barFrac = self.heatLevel / level._sentrySettings[ self.sentryType ].overheatTime;
			player.turret_overheat_bar updateBar( barFrac );
											
			if ( self.forceDisable || self.overheated )
			{
				self TurretFireDisable();
				player.turret_overheat_bar.bar.color = colorOverheated;	
				playingHeatFX = false;			
			}
			else if ( self.heatLevel > level._sentrySettings[ self.sentryType ].overheatTime * 0.75  && self.sentryType == "minigun_turret" )
			{
				player.turret_overheat_bar.bar.color = colorUnstable;
				if ( RandomIntRange( 0, 10 ) < 6 )
					self TurretFireEnable();
				else
					self TurretFireDisable();
				if ( !playingHeatFX )
				{
					playingHeatFX = true;
					self thread PlayHeatFX();	
				}	
			}
			else
			{
				player.turret_overheat_bar.bar.color = colorStable;
				self TurretFireEnable();	
				playingHeatFX = false;
				self notify( "not_overheated" );		
			}
			/*
			if ( !firing && lastHeatLevel < self.heatLevel )
			{
				firing = true;
				self.momentum = 1;
				self StartBarrelSpin();
			}
			else if ( firing && lastHeatLevel > self.heatLevel )
			{
				firing = false;
				self.momentum = 0;
				self StopBarrelSpin();
			}			
			lastHeatLevel = self.heatLevel;
			*/
			wait( 0.05 );
		}
		self setDefaultDropPitch( 0.0 );
	}
}

sentry_handleOwnerDisconnect()
{
	self endon ( "death" );
	level endon ( "game_ended" );
	
	self notify ( "sentry_handleOwner" );
	self endon ( "sentry_handleOwner" );
	
	self.owner waittill_any( "disconnect", "joined_team", "joined_spectators" );
	
	self notify( "death" );
}


/* ============================
	Sentry Utility Functions
   ============================ */

sentry_setOwner( owner )
{
	assertEx( isDefined( owner ), "sentry_setOwner() called without owner specified" );
	assertEx( isPlayer( owner ), "sentry_setOwner() called on non-player entity type: " + owner.classname );

	self.owner = owner;

	self SetSentryOwner( self.owner );
	self SetTurretMinimapVisible( true );
	
	if ( level._teamBased )
	{
		self.team = self.owner.team;
		self setTurretTeam( self.team );
	}
	
	self thread sentry_handleOwnerDisconnect();
}


sentry_setPlaced()
{
	self setModel( level._sentrySettings[ self.sentryType ].modelBase );

	// failsafe check, for some reason this could be manual and setSentryCarried doesn't like that
	if( self GetMode() == "manual" )
		self SetMode( level._sentrySettings[ self.sentryType ].sentryModeOff );

	self setSentryCarried( false );
	self setCanDamage( true );
	
	//	JDS TODO: - turret aligns to ground normal which the player will align to when they mount the turret
	//						- temp fix to keep up vertical
	switch( self.sentryType )
	{
	case "minigun_turret":
	case "gl_turret":
		self.angles = self.carriedBy.angles;
		// show the pickup message
		if( IsAlive( self.originalOwner ) )
	    self.originalOwner setLowerMessage( "pickup_hint", level._sentrySettings[ self.sentryType ].ownerHintString, 3.0 );
		// spawn a trigger so we know if the owner is within range to pick it up
		self.ownerTrigger = Spawn( "trigger_radius", self.origin + ( 0, 0, 1 ), 0, 105, 64 );
		assert( IsDefined( self.ownerTrigger ) );
		self.originalOwner thread turret_handlePickup( self );
		self thread turret_handleUse();
		break;
	default:
		break;
	}
	
	self sentry_makeSolid();

	self.carriedBy forceUseHintOff();
	self.carriedBy = undefined;

	if( IsDefined( self.owner ) )
		self.owner.isCarrying = false;

	self sentry_setActive();

	self playSound( "sentry_gun_plant" );

	self notify ( "placed" );
}


sentry_setCancelled()
{
	self.carriedBy forceUseHintOff();

	self delete();
}


sentry_setCarried( carrier )
{
	assert( isPlayer( carrier ) );
	if( IsDefined( self.originalOwner ) )
		assertEx( carrier == self.originalOwner, "sentry_setCarried() specified carrier does not own this sentry" );
	else
		assertEx( carrier == self.owner, "sentry_setCarried() specified carrier does not own this sentry" );

	self setModel( level._sentrySettings[ self.sentryType ].modelPlacement );

	self setSentryCarried( true );
	self setCanDamage( false );
	self sentry_makeNotSolid();

	self.carriedBy = carrier;
	carrier.isCarrying = true;

	carrier thread updateSentryPlacement( self );
	
	self thread sentry_onCarrierDeath( carrier );
	self thread sentry_onCarrierDisconnect( carrier );
	self thread sentry_onCarrierChangedTeam( carrier );
	self thread sentry_onGameEnded();

	self sentry_setInactive();
	
	self notify ( "carried" );
}

updateSentryPlacement( sentryGun )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	
	sentryGun endon ( "placed" );
	sentryGun endon ( "death" );
	
	sentryGun.canBePlaced = true;
	lastCanPlaceSentry = -1; // force initial update

	for( ;; )
	{
		placement = self canPlayerPlaceSentry();

		sentryGun.origin = placement[ "origin" ];
		sentryGun.angles = placement[ "angles" ];
		sentryGun.canBePlaced = self isOnGround() && placement[ "result" ] && ( abs(sentryGun.origin[2]-self.origin[2]) < 10 );
	
		if ( sentryGun.canBePlaced != lastCanPlaceSentry )
		{
			if ( sentryGun.canBePlaced )
			{
				sentryGun setModel( level._sentrySettings[ sentryGun.sentryType ].modelPlacement );
				self ForceUseHintOn( &"SENTRY_PLACE" );
			}
			else
			{
				sentryGun setModel( level._sentrySettings[ sentryGun.sentryType ].modelPlacementFailed );
				self ForceUseHintOn( &"SENTRY_CANNOT_PLACE" );
			}
		}
		
		lastCanPlaceSentry = sentryGun.canBePlaced;		
		wait ( 0.05 );
	}
}

sentry_onCarrierDeath( carrier )
{
	self endon ( "placed" );
	self endon ( "death" );

	carrier waittill ( "death" );
	
	if ( self.canBePlaced )
		self sentry_setPlaced();
	else
		self delete();
}


sentry_onCarrierDisconnect( carrier )
{
	self endon ( "placed" );
	self endon ( "death" );

	carrier waittill ( "disconnect" );
	
	self delete();
}

sentry_onCarrierChangedTeam( carrier ) // self == sentry
{
	self endon ( "placed" );
	self endon ( "death" );

	carrier waittill_any( "joined_team", "joined_spectators" );

	self delete();
}

sentry_onGameEnded( carrier )
{
	self endon ( "placed" );
	self endon ( "death" );

	level waittill ( "game_ended" );
	
	self delete();
}


sentry_setActive()
{
	self SetMode( level._sentrySettings[ self.sentryType ].sentryModeOn );
	self setCursorHint( "HINT_NOICON" );
	self setHintString( level._sentrySettings[ self.sentryType ].hintString );
	
	if( level._sentrySettings[ self.sentryType ].headIcon )
	{
		if ( level._teamBased )
			self maps\mp\_entityheadicons::setTeamHeadIcon( self.team, (0,0,65) );
		else
			self maps\mp\_entityheadicons::setPlayerHeadIcon( self.owner, (0,0,65) );
	}

	self makeUsable();

	foreach ( player in level._players )
	{
		switch( self.sentryType )
		{
		case "minigun_turret":
		case "gl_turret":
			self enablePlayerUse( player );
			break;
		default:
			if( player == self.owner )
				self enablePlayerUse( player );
			else
				self disablePlayerUse( player );
			break;
		}
	}	

	if( self.shouldSplash )
	{
		level thread teamPlayerCardSplash( level._sentrySettings[ self.sentryType ].teamSplash, self.owner, self.owner.team );
		self.shouldSplash = false;
	}
}


sentry_setInactive()
{
	self setMode( level._sentrySettings[ self.sentryType ].sentryModeOff );
	self makeUnusable();

	if ( level._teamBased )
		self maps\mp\_entityheadicons::setTeamHeadIcon( "none", ( 0, 0, 0 ) );
	else if ( isDefined( self.owner ) )
		self maps\mp\_entityheadicons::setPlayerHeadIcon( undefined, ( 0, 0, 0 ) );
}


sentry_makeSolid()
{
	self makeTurretSolid();
}


sentry_makeNotSolid()
{
	self setContents( 0 );
}


isFriendlyToSentry( sentryGun )
{
	if ( level._teamBased && self.team == sentryGun.team )
		return true;
		
	return false;
}


addToTurretList( entNum )
{
	level._turrets[entNum] = self;	
}


removeFromTurretList( entNum )
{
	level._turrets[entNum] = undefined;
}

/* ============================
	Sentry Logic Functions
   ============================ */

sentry_attackTargets()
{
	self endon( "death" );
	level endon( "game_ended" );

	self.momentum = 0;
	self.heatLevel = 0;
	self.overheated = false;
	
	self thread sentry_heatMonitor();
	
	for ( ;; )
	{
		self waittill_either( "turretstatechange", "cooled" );

		if ( self isFiringTurret() )
		{
			self thread sentry_burstFireStart();
		}
		else
		{
			self sentry_spinDown();
			self thread sentry_burstFireStop();
		}
	}
}


sentry_timeOut()
{
	self endon( "death" );
	level endon ( "game_ended" );
	
	lifeSpan = level._sentrySettings[ self.sentryType ].timeOut;
	
	while ( lifeSpan )
	{
		wait ( 1.0 );
		maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
		
		if ( !isDefined( self.carriedBy ) )
			lifeSpan = max( 0, lifeSpan - 1.0 );
	}
	
	if ( isDefined( self.owner ) )
		self.owner thread leaderDialogOnPlayer( "sentry_gone" );
	
	self notify ( "death" );
}

sentry_targetLockSound()
{
	self endon ( "death" );
	
	self playSound( "sentry_gun_beep" );
	wait ( 0.1 );
	self playSound( "sentry_gun_beep" );
	wait ( 0.1 );
	self playSound( "sentry_gun_beep" );
}

sentry_spinUp()
{
	self thread sentry_targetLockSound();
	
	while ( self.momentum < level._sentrySettings[ self.sentryType ].spinupTime )
	{
		self.momentum += 0.1;
		
		wait ( 0.1 );
	}
}

sentry_spinDown()
{
	self.momentum = 0;
}


sentry_burstFireStart()
{
	self endon( "death" );
	self endon( "stop_shooting" );

	level endon( "game_ended" );

	self sentry_spinUp();

	fireTime = weaponFireTime( level._sentrySettings[ self.sentryType ].weaponInfo );
	minShots = level._sentrySettings[ self.sentryType ].burstMin;
	maxShots = level._sentrySettings[ self.sentryType ].burstMax;
	minPause = level._sentrySettings[ self.sentryType ].pauseMin;
	maxPause = level._sentrySettings[ self.sentryType ].pauseMax;
	for ( ;; )
	{		
		numShots = randomIntRange( minShots, maxShots + 1 );
		
		for ( i = 0; i < numShots && !self.overheated; i++ )
		{
			self shootTurret();
			self.heatLevel += fireTime;
			wait ( fireTime );
		}
		
		wait ( randomFloatRange( minPause, maxPause ) );
	}
}


sentry_burstFireStop()
{
	self notify( "stop_shooting" );
}


turret_shotMonitor( turret )
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon ( "game_ended" );
	turret endon( "death" );
	turret endon( "player_dismount" );
	
	fireTime = weaponFireTime( level._sentrySettings[ turret.sentryType ].weaponInfo );

	for ( ;; )
	{	
		turret waittill ( "turretshoot" );
		turret.heatLevel += fireTime;
		// need to reset the heat wait time so the overheat bar knows that we've fired again before cooldown
		turret.cooldownWaitTime = fireTime;
	}
}

// TODO: think about using the turret_heatMonitor and turret_coolMonitor instead of this because this has a small flaw where it waits twice and gets out of sync with the firing
sentry_heatMonitor()
{
	self endon ( "death" );

	fireTime = weaponFireTime( level._sentrySettings[ self.sentryType ].weaponInfo );

	lastHeatLevel = 0;
	lastFxTime = 0;
	
	overheatTime = level._sentrySettings[ self.sentryType ].overheatTime;
	overheatCoolDown = level._sentrySettings[ self.sentryType ].cooldownTime;

	for ( ;; )
	{
		if ( self.heatLevel != lastHeatLevel )
			wait ( fireTime );
		else
			self.heatLevel = max( 0, self.heatLevel - 0.05 );

		if ( self.heatLevel > overheatTime )
		{
			self.overheated = true;
			self thread PlayHeatFX();
			switch( self.sentryType )
			{
			case "minigun_turret":
				playFxOnTag( getFx( "sentry_smoke_mp" ), self, "tag_aim" );
				//self thread PlaySmokeFX();
				break;
			default:
				break;
			}
			
			while ( self.heatLevel )
			{
				self.heatLevel = max( 0, self.heatLevel - overheatCoolDown );	
				wait ( 0.1 );
			}

			self.overheated = false;
			self notify( "not_overheated" );
		}

		lastHeatLevel = self.heatLevel;
		wait ( 0.05 );
	}
}

turret_heatMonitor()
{
	self endon ( "death" );

	overheatTime = level._sentrySettings[ self.sentryType ].overheatTime;

	while( true )
	{
		if ( self.heatLevel > overheatTime )
		{
			self.overheated = true;
			self thread PlayHeatFX();
			switch( self.sentryType )
			{
			case "gl_turret":
				playFxOnTag( getFx( "sentry_smoke_mp" ), self, "tag_aim" );
				// TODO: get sound for overheating
				break;
			default:
				break;
			}

			while ( self.heatLevel )
			{
				wait ( 0.1 );
			}

			self.overheated = false;
			self notify( "not_overheated" );
		}

		wait ( 0.05 );
	}
}

turret_coolMonitor()
{
	self endon ( "death" );
	
	while( true )
	{
		if( self.heatLevel > 0 )
		{
			if( self.cooldownWaitTime <= 0 )
			{
				self.heatLevel = max( 0, self.heatLevel - 0.05 );
			}
			else
			{
				self.cooldownWaitTime = max( 0, self.cooldownWaitTime - 0.05 );
			}
		}

		wait( 0.05 );
	}
}


playHeatFX()
{
	self endon( "death" );
	self endon( "not_overheated" );
	level endon ( "game_ended" );
	
	self notify( "playing_heat_fx" );
	self endon( "playing_heat_fx" );
	
	for( ;; )
	{
		playFxOnTag( getFx( "sentry_overheat_mp" ), self, "tag_flash" );
	
		wait( level._sentrySettings[ self.sentryType ].fxTime );
	}
}

playSmokeFX()
{
	self endon( "death" );
	self endon( "not_overheated" );
	level endon ( "game_ended" );
	
	for( ;; )
	{
		playFxOnTag( getFx( "sentry_smoke_mp" ), self, "tag_aim" );
		wait ( 0.4 );
	}
}

sentry_beepSounds()
{
	self endon( "death" );
	level endon ( "game_ended" );

	for ( ;; )
	{
		wait ( 3.0 );

		if ( !isDefined( self.carriedBy ) )
			self playSound( "sentry_gun_beep" );
	}
}