#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

/*
	Gun Game
	Objective: 	Score points for your team by eliminating players on the opposing team
	Map ends:	When one player reaches the max level gun, or time limit is reached
	Respawning:	No wait / Near teammates

	Level requirementss
	------------------
		Spawnpoints:
			classname		mp_tdm_spawn
			All players spawn from these. The spawnpoint chosen is dependent on the current locations of teammates and enemies
			at the time of spawn. Players generally spawn behind their teammates relative to the direction of enemies.

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.
*/

/*QUAKED mp_tdm_spawn (0.0 0.0 1.0) (-16 -16 0) (16 16 72)
Players spawn away from enemies and near their team at one of these positions.*/

/*QUAKED mp_tdm_spawn_axis_start (0.5 0.0 1.0) (-16 -16 0) (16 16 72)
Axis players spawn away from enemies and near their team at one of these positions at the start of a round.*/

/*QUAKED mp_tdm_spawn_allies_start (0.0 0.5 1.0) (-16 -16 0) (16 16 72)
Allied players spawn away from enemies and near their team at one of these positions at the start of a round.*/

main()
{
	if(getdvar("mapname") == "mp_background")
		return;
	
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	registerRoundSwitchDvar( level._gameType, 0, 0, 9 );
	registerTimeLimitDvar( level._gameType, 10, 0, 1440 );
	registerScoreLimitDvar( level._gameType, 400 , 400, 400 );
	registerRoundLimitDvar( level._gameType, 1, 0, 10 );
	registerWinLimitDvar( level._gameType, 1, 0, 10 );
	registerRoundSwitchDvar( level._gameType, 3, 0, 30 );
	registerNumLivesDvar( level._gameType, 0, 0, 10 );
	registerHalfTimeDvar( level._gameType, 0, 0, 1 );

	level._teamBased = true;
	level._onStartGameType = ::onStartGameType;
	level._getSpawnPoint = ::getSpawnPoint;
	level._onNormalDeath = ::onNormalDeath;
	level._onSpawnPlayer = ::onSpawnPlayer;

	//level.onTimeLimit = ::onTimeLimit;	// overtime not fully supported yet

	game["dialog"]["gametype"] = "gg";
	
	game["strings"]["overtime_hint"] = &"MP_FIRST_BLOOD";
}


onStartGameType()
{
	setClientNameMode("auto_change");

	if ( !isdefined( game["switchedsides"] ) )
		game["switchedsides"] = false;

	if ( game["switchedsides"] )
	{
		oldAttackers = game["attackers"];
		oldDefenders = game["defenders"];
		game["attackers"] = oldDefenders;
		game["defenders"] = oldAttackers;
	}

	setObjectiveText( "allies", &"OBJECTIVES_WAR" );
	setObjectiveText( "axis", &"OBJECTIVES_WAR" );
	
	if ( level._splitscreen )
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_WAR" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_WAR" );
	}
	else
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_WAR_SCORE" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_WAR_SCORE" );
	}
	setObjectiveHintText( "allies", &"OBJECTIVES_WAR_HINT" );
	setObjectiveHintText( "axis", &"OBJECTIVES_WAR_HINT" );
			
	level._spawnMins = ( 0, 0, 0 );
	level._spawnMaxs = ( 0, 0, 0 );	
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );
	
	level._mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level._spawnMins, level._spawnMaxs );
	setMapCenter( level._mapCenter );

	level._killstreakRewards = false;
	allowed[0] = level._gameType;
	allowed[1] = "airdrop_pallet";
	
	maps\mp\gametypes\_gameobjects::main(allowed);	
}


getSpawnPoint()
{
	spawnteam = self.pers["team"];
	if ( game["switchedsides"] )
		spawnteam = getOtherTeam( spawnteam );

	if ( level._inGracePeriod )
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn_" + spawnteam + "_start" );
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
	}
	else
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnteam );
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
	}
	
	return spawnPoint;
}


onSpawnPlayer()
{
	self thread onPlayerSpawned();
}

onPlayerSpawned()
{
	self waittill( "spawned_player" );
	giveGunGameWeapon( self, self.score );
}


onNormalDeath( victim, attacker, lifeId )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
	assert( isDefined( score ) );

	update_team_score( attacker, victim );
	
	if ( game["state"] == "postgame" && game["teamScores"][attacker.team] > game["teamScores"][level._otherTeam[attacker.team]] )
		attacker.finalKill = true;
}


update_team_score( player, victim )
{
	if ( isDefined( level._nukeIncoming ) )
		return;
	
	score = player.pers["score"];

	player.score = player.pers["score"];
	
	if( player.score % 500 == 0 )
		giveGunGameWeapon( player, player.score );

	team = player.pers["team"];
	team_score = game["teamScores"][team];
	if( player.score > team_score )
	{
		player maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( team, ( player.score - team_score ));
	}
}


giveGunGameWeapon( player, score )
{

	score_value = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
	assert( isDefined( score_value ) );

	num_kills = ( score / score_value );
	score_limit_kills = ( getScoreLimit() / score_value );
	kills_per_level = ( score_limit_kills / 5 );
	
	weapon = player getCurrentWeapon();
	off_hand = player getCurrentOffhand();

	while( player IsMeleeing() )
		wait( 0.01 );
	while( player IsThrowingGrenade() )
		wait( 0.01 );

	if( num_kills <= 0 )
	{
		player maps\mp\gametypes\_class::giveLoadout( player.pers["team"], "class0" );
		player _clearPerks();
	}
	else if( num_kills <= ( 1 * kills_per_level ))
	{
		player maps\mp\gametypes\_class::giveLoadout( player.pers["team"], "class1" );
		player _clearPerks();
	}
	else if( num_kills <= ( 2 * kills_per_level ))
	{
		player maps\mp\gametypes\_class::giveLoadout( player.pers["team"], "class2" );
		player _clearPerks();
	}
	else if( num_kills <= ( 3 * kills_per_level ))
	{
		player maps\mp\gametypes\_class::giveLoadout( player.pers["team"], "class3" );
		player _clearPerks();
	}
	else
	{
		player maps\mp\gametypes\_class::giveLoadout( player.pers["team"], "class4" );
		player _clearPerks();
	}
}

onTimeLimit()
{
	if ( game["status"] == "overtime" )
	{
		winner = "forfeit";
	}
	else if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
	{
		winner = "overtime";
	}
	else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
	{
		winner = "axis";
	}
	else
	{
		winner = "allies";
	}
	
	thread maps\mp\gametypes\_gamelogic::endGame( winner, game["strings"]["time_limit_reached"] );
}