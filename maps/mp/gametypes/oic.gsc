//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  The One-In-The_Chamber game mode ported from MW3             **
//             (1) Players use only one predetermined weapon.               **
//             (2) No class change is allowed in the game mode.             **
//             (3) Players have limited ammo to start the game.             **                   
//             (4) Obtaining kills will reward players with additional ammo.**
//             (5) Match terminates when there is only one player left.     **
//                                                                          **
//                                                                          ** 
//    Created: August 23rd, 2011 - James Chen                               **
//                                                                          **
//***************************************************************************/

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_class;

MATCHRULES_INITIALAMMO = 1;
MATCHRULES_REWARDAMMO = 1;
NUMBER_OF_LIVES = 3;
WARNING_START_WHEN_LIFE_LEFT = 2;
WEAPON_NAME = "coltanaconda_mp";

main()
{
	precachestring( &"SPLASHES_SURVIVOR" );
	precachestring( &"SPLASHES_OIC_LAST_LIFE" );
	precachestring( &"SPLASHES_OIC_LIFE_LEFT" );

	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	/* if ( isUsingMatchRulesData() )
	{
		//	set common values
		setCommonRulesFromMatchRulesData( true );
		
		//	set everything else (private match options, default .cfg file values, and what normally is registered in the 'else' below)	
		level.matchRules_initialAmmo = GetMatchRulesData( "oicData", "initialAmmoCount" );
		level.matchRules_rewardAmmo = GetMatchRulesData( "oicData", "killRewardAmmoCount" );			
		
		SetDvar( "scr_oic_winlimit", 1 );
		registerWinLimitDvar( "oic", 1 );
		SetDvar( "scr_oic_roundlimit", 1 );
		registerRoundLimitDvar( "oic", 1 );
		SetDvar( "scr_oic_halftime", 0 );
		registerHalfTimeDvar( "oic", 0 );
			
		SetDvar( "scr_oic_promode", 0 );		
	}
	else
	{ */
		registerTimeLimitDvar( level._gameType, 10, 0, 1440 );
		registerScoreLimitDvar( level._gameType, 0, 0, 1000 );
		registerRoundLimitDvar( level._gameType, 1, 0, 10 );
		registerWinLimitDvar( level._gameType, 1, 0, 10 );
		registerNumLivesDvar( level._gameType, NUMBER_OF_LIVES, 0, 10 );
		registerHalfTimeDvar( level._gameType, 0, 0, 1 ); 		
	// }
	
	level._teamBased = false;
	level._doPrematch = true;
	level._killstreakRewards = false;
	level._onStartGameType = ::onStartGameType;
	level._onSpawnPlayer = ::onSpawnPlayer;
	level._getSpawnPoint = ::getSpawnPoint;
	level._onPlayerKilled = ::onPlayerKilled;
	level._modifyPlayerDamage = ::modifyPlayerDamage;
	level._blockWeaponDrops = true;
	level._blockRechargeablePerk = true; 
	level._blockClassChange = true;
	level._overridePlayerModel = true;
	level._disableWarSuit = true;
	setDvar( "scr_game_hardpoints", "0" );
	setDvar( "scr_game_perks", "0" );
	setDvar( "scr_player_maxhealth", "30" );

	game["dialog"]["gametype"] = "oic";
}


onStartGameType()
{
	setClientNameMode("auto_change");

	setObjectiveText( "allies", &"OBJECTIVES_OIC" );
	setObjectiveText( "axis", &"OBJECTIVES_OIC" );

	if ( level._splitscreen )
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_OIC" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_OIC" );
	}
	else
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_OIC_SCORE" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_OIC_SCORE" );
	}
	setObjectiveHintText( "allies", &"OBJECTIVES_OIC_HINT" );
	setObjectiveHintText( "axis", &"OBJECTIVES_OIC_HINT" );

	level._spawnMins = ( 0, 0, 0 );
	level._spawnMaxs = ( 0, 0, 0 );

	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dm_spawn" );

	level._mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level._spawnMins, level._spawnMaxs );
	setMapCenter( level._mapCenter );

	allowed[0] = "oic";
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 100 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "suicide", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "survive", 25 );

	level._QuickMessageToAll = true;	
	level._blockWeaponDrops = true;

	level thread watchElimination();	
}


getSpawnPoint()
{
	spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( spawnPoints );

	return spawnPoint;
}


onSpawnPlayer()
{
	//	award ammo that the player might have been waiting to receive on death
	if ( isDefined( self.oic_rewardAmmo ) && self.oic_rewardAmmo )
		self giveAmmo();
	else
		self.oic_rewardAmmo = 0;	
	
	self thread waitLoadoutDone();
	
	level notify ( "spawned_player" );	
}

waitLoadoutDone()
{	
	level endon( "game_ended" );
	self endon( "disconnect" );
	
	level waittill( "player_spawned" );

	if ( !isDefined( self.oic_life_remaining ))
	{
		self.oic_life_remaining = NUMBER_OF_LIVES;
	}
	else
	{
		self.oic_life_remaining -= 1;
	}

	if ( self.oic_life_remaining == 1 )
	{
		self thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_OIC_LAST_LIFE" );
	}
	else if ( self.oic_life_remaining <= WARNING_START_WHEN_LIFE_LEFT )
	{
		self iPrintLnBold ( &"SPLASHES_OIC_LIFE_LEFT", self.oic_life_remaining );
	}
	
	//	clear temp data
	self takeAllWeapons();
	
	//	give gun
	_giveWeapon( WEAPON_NAME );		
	self switchToWeapon( WEAPON_NAME );
	self setSpawnWeapon( WEAPON_NAME );
	primaryTokens = strtok( WEAPON_NAME, "_" );
	self.pers["primaryWeapon"] = primaryTokens[0];		
	self.primaryWeapon = WEAPON_NAME;
	
	//	give ammo	
	clipAmmo = MATCHRULES_INITIALAMMO;
	if( isDefined( self.pers["clip_ammo"] ) )
	{
		clipAmmo = self.pers["clip_ammo"];
		self.pers["clip_ammo"] = undefined;
	}
	self SetWeaponAmmoClip( self.primaryWeapon, clipAmmo );

	stockAmmo = 0;
	if( isDefined( self.pers["stock_ammo"] ) )
	{
		stockAmmo = self.pers["stock_ammo"];
		self.pers["stock_ammo"] = undefined;
	}
	self SetWeaponAmmoStock( self.primaryWeapon, stockAmmo );	
	
	//	give knife
	//self SetOffhandPrimaryClass( "throwingknife" );
	//_giveWeapon( "throwingknife_mp" );		
}


modifyPlayerDamage( victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc )
{
	if ( ( sMeansOfDeath == "MOD_PISTOL_BULLET" ) || ( sMeansOfDeath == "MOD_RIFLE_BULLET" ) || ( sMeansOfDeath == "MOD_HEAD_SHOT" ) )	
		iDamage = 999;

	return iDamage;
}


onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, lifeId )
{
	if ( isDefined( attacker ) && isPlayer( attacker ) && self != attacker )
	{
		attacker.oic_rewardAmmo += MATCHRULES_REWARDAMMO;
		if ( self attackButtonPressed() )
			attacker thread waitGiveAmmo();
		else
			attacker giveAmmo();		
	}
}


waitGiveAmmo()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	self notify( "oic_waitGiveAmmo" );
	self  endon( "oic_waitGiveAmmo" );
	
	while( self attackButtonPressed() )
		wait( 0.05 );
		
	giveAmmo();
}


giveAmmo()
{
	currentWeapon = self getCurrentWeapon();
	clipAmmo = self GetWeaponAmmoClip( currentWeapon );
	self SetWeaponAmmoClip( currentWeapon, clipAmmo + self.oic_rewardAmmo );
	self playLocalSound( "scavenger_pack_pickup" );
	
	self.oic_rewardAmmo = 0;
}


watchElimination()
{
	level endon( "game_ended" );
	
	for ( ;; )
	{
		level waittill( "player_eliminated", player );
		
		thread teamPlayerCardSplash( "callout_eliminated", player );
		
		remainingPlayers = [];
		foreach ( player in level._players )
		{
			if ( IsDefined( player ) && ( IsAlive( player ) || player.pers["lives"] > 0 ) )
			{
				remainingPlayers[remainingPlayers.size] = player;				
				player thread maps\mp\gametypes\_rank::xpEventPopup( &"SPLASHES_SURVIVOR" );
				maps\mp\gametypes\_gamescore::givePlayerScore( "survive", player, undefined, true );
			}
		}
		
		if ( remainingPlayers.size > 2 )
		{
			playSoundOnPlayers( "mp_enemy_obj_captured" );
		}
		else if ( remainingPlayers.size == 2 )
		{
			playSoundOnPlayers( "mp_obj_captured" );
			
			remainingPlayers[0] thread maps\mp\gametypes\_hud_message::playerCardSplashNotify( "callout_lastenemyalive", remainingPlayers[1] );
			remainingPlayers[1] thread maps\mp\gametypes\_hud_message::playerCardSplashNotify( "callout_lastenemyalive", remainingPlayers[0] );
		}
	}
}