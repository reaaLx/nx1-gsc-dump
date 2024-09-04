//	Callback Setup
//	This script provides the hooks from code into script for the gametype callback functions.

//=============================================================================
// Code Callback functions

/*================
Called by code after the level's main script function has run.
================*/
CodeCallback_StartGameType()
{
	if( getDvar( "r_reflectionProbeGenerate" ) == "1" )
		level waittill( "eternity" );

	// If the gametype has not beed started, run the startup
	if(!isDefined(level._gametypestarted) || !level._gametypestarted)
	{
		[[level._callbackStartGameType]]();

		level._gametypestarted = true; // so we know that the gametype has been started up
	}
}


/*================
Called when a player begins connecting to the server.
Called again for every map change or tournement restart.

Return undefined if the client should be allowed, otherwise return
a string with the reason for denial.

Otherwise, the client will be sent the current gamestate
and will eventually get to ClientBegin.

firstTime will be qtrue the very first time a client connects
to the server machine, but qfalse on map changes and tournement
restarts.
================*/
CodeCallback_PlayerConnect()
{
	if( getDvar( "r_reflectionProbeGenerate" ) == "1" )
		level waittill( "eternity" );

	self endon("disconnect");
	[[level._callbackPlayerConnect]]();

	// tagGHS< BB adds >
	lpselfnum = self getEntityNumber();
	bbPrint( "mpjoins: name %s client %s", self.name, lpselfnum );
}

/*================
Called when a player drops from the server.
Will not be called between levels.
self is the player that is disconnecting.
================*/
CodeCallback_PlayerDisconnect()
{
	self maps\mp\gametypes\_gamelogic::dump_score_board_to_black_box_for_player_bailed_early();

	self notify("disconnect");
	
	[[level._callbackPlayerDisconnect]]();

	lpselfnum = self getEntityNumber();
	bbPrint( "mpquits: name %s client %d", self.name, lpselfnum );
}

/*================
Called when a player has taken damage.
self is the player that took damage.
================*/
CodeCallback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	self endon("disconnect");
    [[level._callbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
}

/*================
Called when a player has been killed.
self is the player that was killed.
================*/
CodeCallback_PlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	self endon("disconnect");

	//println( "mpattacks: victimxuid='" + self GetXUID() + "', victimweapon='" + self GetCurrentWeapon() + "'\n" );
	//bbPrint( "breakpoint:" );

	if(self.sessionstate != "dead")
	{
		attackerweaponiskillstreak = 0;
		if ( maps\mp\_utility::isKillstreakWeapon( sWeapon ) )
		{
			attackerweaponiskillstreak = 1;
		}
		attackerweaponisequipment = 0;
		if( maps\mp\gametypes\_weapons::isEquipment( sWeapon ) )
		{
			attackerweaponisequipment = 1;
		}
		attackerweaponisnormal = 1;	// assume weapon is normal unless it's a killstreak or equipment weapon.
		if( ( attackerweaponiskillstreak != 0 ) || ( attackerweaponisequipment != 0 ) )
		{
			attackerweaponisnormal = 0;
		}

		lpattackerorigin = ( 0, 0, 0 );
		if(isPlayer(eAttacker))
		{
			lpattacknum = eAttacker getEntityNumber();
			lpattackGuid = eAttacker getGuid();
			lpattackname = eAttacker.name;
			lpattackerteam = eAttacker.pers["team"];
			lpattackerorigin = eAttacker.origin;
			
			//println( "mpattacks: victimxuid='" + self GetXUID() + "', attackerxuid='" + eAttacker GetXUID() + "'\n" );
			//bbPrint( "breakpoint:" );
			
			bbPrint( "mpattacks: gametime %d attackerspawnid %d attackerxuid %llu attackerweapon %s attackerx %f attackery %f attackerz %f victimspawnid %d victimxuid %llu victimweapon %s victimx %f victimy %f victimz %f damage %d damagetype %s damagelocation %s death 0 attackerweaponisnormal %d attackerweaponiskillstreak %d attackerweaponisequipment %d attackersuit %s victimsuit %s",
						   gettime(), eAttacker getplayerspawnid(), eAttacker GetXUID(), sWeapon, lpattackerorigin, self getplayerspawnid(), self GetXUID(), self GetCurrentWeapon(), self.origin, iDamage, sMeansOfDeath, sHitLoc, attackerweaponisnormal, attackerweaponiskillstreak, attackerweaponisequipment, eAttacker.currentSuit, self.currentSuit ); 
		}
		else
		{
			//println( "mpattacks: victimxuid='" + self GetXUID() + "'\n" );

			lpattacknum = -1;
			lpattackGuid = "";
			lpattackname = "";
			lpattackerteam = "world";
			bbPrint( "mpattacks: gametime %d attackerweapon %s victimspawnid %d victimxuid %llu victimweapon %s victimx %f victimy %f victimz %f damage %d damagetype %s damagelocation %s death 0 attackerweaponisnormal %d attackerweaponiskillstreak %d attackerweaponisequipment %d",
						   gettime(), sWeapon, self getplayerspawnid(), self GetXUID(), self GetCurrentWeapon(), self.origin, iDamage, sMeansOfDeath, sHitLoc, attackerweaponisnormal, attackerweaponiskillstreak, attackerweaponisequipment ); 	
		}
		//bbPrint( "breakpoint:" );
	}
	// We need to do the bbprint before here since the level callbacks will respawn the player by the time this next line returns
	[[level._callbackPlayerKilled]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
}


/*================
Called when a vehicle has taken damage.
self is the vehicle that took damage.
================*/
CodeCallback_VehicleDamage( inflictor, attacker, damage, dFlags, meansOfDeath, weapon, point, dir, hitLoc, timeOffset, modelIndex, partName )
{
	if ( isDefined( self.damageCallback ) )
		self [[self.damageCallback]]( inflictor, attacker, damage, dFlags, meansOfDeath, weapon, point, dir, hitLoc, timeOffset, modelIndex, partName );
	else
		self Vehicle_FinishDamage( inflictor, attacker, damage, dFlags, meansOfDeath, weapon, point, dir, hitLoc, timeOffset, modelIndex, partName );
}


/*================
Called when code is forcibly ending the game.
e.g. we suck as host.
================*/
CodeCallback_CodeEndGame()
{
	self endon("disconnect");
	[[level._callbackCodeEndGame]]();
}


/*================
Called when a player has been killed, but has last stand perk.
self is the player that was killed.
================*/
CodeCallback_PlayerLastStand(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration )
{
	self endon("disconnect");
	[[level._callbackPlayerLastStand]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
}


/*================
Called when a player reconnects to the server
following a host migration.
================*/
CodeCallback_PlayerMigrated()
{
	self endon("disconnect");
	[[level._callbackPlayerMigrated]]();
}


/*================
Called once when a host migration has occured.
================*/
CodeCallback_HostMigration()
{
	[[level._callbackHostMigration]]();
}



//=============================================================================

// Damage flags used in the playerDamage callback
SetupDamageFlags()
{
	// code-defined:
	level._iDFLAGS_RADIUS						= 1;	// damage was indirect
	level._iDFLAGS_NO_ARMOR						= 2;	// armor does not protect from this damage
	level._iDFLAGS_NO_KNOCKBACK					= 4;	// do not affect velocity, just view angles
	level._iDFLAGS_PENETRATION					= 8;	// damage occurred after one or more penetrations
	level._iDFLAGS_STUN							= 16;	// non-lethal
	level._iDFLAGS_SHIELD_EXPLOSIVE_IMPACT		= 32;	// missile impacted on the front of the victim's shield
	level._iDFLAGS_SHIELD_EXPLOSIVE_IMPACT_HUGE	= 64;	//   ...and was from a projectile with "Big Explosion" checked on.
	level._iDFLAGS_SHIELD_EXPLOSIVE_SPLASH		= 128;	// explosive splash, somewhat deflected by the victim's shield

	// script-defined:
	level._iDFLAGS_NO_TEAM_PROTECTION			= 256;
	level._iDFLAGS_NO_PROTECTION					= 512;
	level._iDFLAGS_PASSTHRU						= 1024;
}


/*================
Setup any misc callbacks stuff like defines and default callbacks
================*/
SetupCallbacks()
{
	SetDefaultCallbacks();
	SetupDamageFlags();
}


/*================
Called from the gametype script to store off the default callback functions.
This allows the callbacks to be overridden by level script, but not lost.
================*/
SetDefaultCallbacks()
{
	level._callbackStartGameType = maps\mp\gametypes\_gamelogic::Callback_StartGameType;
	level._callbackPlayerConnect = maps\mp\gametypes\_playerlogic::Callback_PlayerConnect;
	level._callbackPlayerDisconnect = maps\mp\gametypes\_playerlogic::Callback_PlayerDisconnect;
	level._callbackPlayerDamage = maps\mp\gametypes\_damage::Callback_PlayerDamage;
	level._callbackPlayerKilled = maps\mp\gametypes\_damage::Callback_PlayerKilled;
	level._callbackCodeEndGame = maps\mp\gametypes\_gamelogic::Callback_CodeEndGame;
	level._callbackPlayerLastStand = maps\mp\gametypes\_damage::Callback_PlayerLastStand;
	level._callbackPlayerMigrated = maps\mp\gametypes\_playerlogic::Callback_PlayerMigrated;
	level._callbackHostMigration = maps\mp\gametypes\_hostmigration::Callback_HostMigration;
}


/*================
Called when a gametype is not supported.
================*/
AbortLevel()
{
	println("Aborting level - gametype is not supported");

	level._callbackStartGameType = ::callbackVoid;
	level._callbackPlayerConnect = ::callbackVoid;
	level._callbackPlayerDisconnect = ::callbackVoid;
	level._callbackPlayerDamage = ::callbackVoid;
	level._callbackPlayerKilled = ::callbackVoid;
	level._callbackCodeEndGame = ::callbackVoid;
	level._callbackPlayerLastStand = ::callbackVoid;
	level._callbackPlayerMigrated = ::callbackVoid;
	level._callbackHostMigration = ::callbackVoid;

	setdvar("g_gametype", "dm");

	exitLevel(false);
}


/*================
================*/
callbackVoid()
{
}