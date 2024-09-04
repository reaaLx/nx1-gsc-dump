#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

FACTION_REF_COL 					= 0;
FACTION_NAME_COL 					= 1;
FACTION_SHORT_NAME_COL 				= 1;
FACTION_WIN_GAME_COL 				= 3; 
FACTION_WIN_ROUND_COL 				= 4;
FACTION_MISSION_ACCOMPLISHED_COL 	= 5;
FACTION_ELIMINATED_COL 				= 6;
FACTION_FORFEITED_COL 				= 7;
FACTION_ICON_COL 					= 8;
FACTION_HUD_ICON_COL 				= 9;
FACTION_VOICE_PREFIX_COL 			= 10;
FACTION_SPAWN_MUSIC_COL 			= 11;
FACTION_WIN_MUSIC_COL 				= 12;
FACTION_COLOR_R_COL 				= 13;
FACTION_COLOR_G_COL 				= 14;
FACTION_COLOR_B_COL 				= 15;

// when a team leaves completely, that team forfeited, team left wins round, ends game
// pass in the team scheduled to win the game.
onForfeit( team )
{
	if ( isDefined( level._forfeitInProgress ) )
		return;

	level endon( "abort_forfeit" );			//end if the team is no longer in forfeit status

	level._forfeitInProgress = true;
	
	// in 1v1 DM, give players time to change teams
	if ( !level._teambased && level._players.size > 1 )
		wait 10;
	
	forfeit_delay = 20.0;						//forfeit wait, for switching teams and such
	
	foreach ( player in level._players )
	{
		player setLowerMessage( "forfeit_warning", game["strings"]["opponent_forfeiting_in"], forfeit_delay, 100 );
		player thread forfeitWaitforAbort();
	}
		
	wait ( forfeit_delay );
	
	endReason = &"";
	if ( !isDefined( team ) )
	{
		endReason = game["strings"]["players_forfeited"];
		winner = level._players[0];
	}
	else if ( team == "axis" )
	{
		endReason = game["strings"]["allies_forfeited"];
		winner = "axis";
	}
	else if ( team == "allies" )
	{
		endReason = game["strings"]["axis_forfeited"];
		winner = "allies";
	}
	else
	{
		if( level._multiTeamBased )
		{
			winner = team;
		}
		else
		{
			//shouldn't get here
			assertEx( isdefined( team ), "Forfeited team is not defined" );
			assertEx( 0, "Forfeited team " + team + " is not allies or axis" );
			winner = "tie";
		}
	}
	//exit game, last round, no matter if round limit reached or not
	level._forcedEnd = true;
	
	if ( isPlayer( winner ) )
		logString( "forfeit, win: " + winner getXuid() + "(" + winner.name + ")" );
	else
	{
		if( level._multiTeamBased )
		{
			logString( "forfeit, win: " + winner );
		}
		else
		{
			logString( "forfeit, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
		}
	}
	
	thread endGame( winner, endReason );
}


forfeitWaitforAbort()
{
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	
	level waittill ( "abort_forfeit" );
	
	self clearLowerMessage( "forfeit_warning" );
}


default_onDeadEvent( team )
{
	if ( team == "allies" )
	{
		iPrintLn( game["strings"]["allies_eliminated"] );

		logString( "team eliminated, win: opfor, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
		
		thread endGame( "axis", game["strings"]["allies_eliminated"] );
	}
	else if ( team == "axis" )
	{
		iPrintLn( game["strings"]["axis_eliminated"] );

		logString( "team eliminated, win: allies, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );

		thread endGame( "allies", game["strings"]["axis_eliminated"] );
	}
	else
	{
		logString( "tie, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );

		if ( level._teamBased )
			thread endGame( "tie", game["strings"]["tie"] );
		else
			thread endGame( undefined, game["strings"]["tie"] );
	}
}


default_onOneLeftEvent( team )
{
	if ( level._teamBased )
	{		
		assert( team == "allies" || team == "axis" );
		
		lastPlayer = getLastLivingPlayer( team );
		lastPlayer thread giveLastOnTeamWarning();
	}
	else
	{
		lastPlayer = getLastLivingPlayer();
		
		logString( "last one alive, win: " + lastPlayer.name );
		thread endGame( lastPlayer, &"MP_ENEMIES_ELIMINATED" );
	}

	return true;
}


default_onTimeLimit()
{
	winner = undefined;
	
	if ( level._teamBased )
	{
		if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
			winner = "tie";
		else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
			winner = "axis";
		else
			winner = "allies";

		logString( "time limit, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
	}
	else
	{
		winner = maps\mp\gametypes\_gamescore::getHighestScoringPlayer();

		if ( isDefined( winner ) )
			logString( "time limit, win: " + winner.name );
		else
			logString( "time limit, tie" );
	}
	
	thread endGame( winner, game["strings"]["time_limit_reached"] );
}


default_onHalfTime()
{
	winner = undefined;
	
	thread endGame( "halftime", game["strings"]["time_limit_reached"] );
}


forceEnd()
{
	if ( level._hostForcedEnd || level._forcedEnd )
		return;

	winner = undefined;
	
	if ( level._teamBased )
	{
		if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
			winner = "tie";
		else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
			winner = "axis";
		else
			winner = "allies";
		logString( "host ended game, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
	}
	else
	{
		winner = maps\mp\gametypes\_gamescore::getHighestScoringPlayer();
		if ( isDefined( winner ) )
			logString( "host ended game, win: " + winner.name );
		else
			logString( "host ended game, tie" );
	}
	
	level._forcedEnd = true;
	level._hostForcedEnd = true;
	
	if ( level._splitscreen )
		endString = &"MP_ENDED_GAME";
	else
		endString = &"MP_HOST_ENDED_GAME";
	
	thread endGame( winner, endString );
}


default_onScoreLimit()
{
	scoreText = game["strings"]["score_limit_reached"];	
	winner = undefined;
	if( level._multiTeamBased )
	{
		winner = maps\mp\gametypes\_gamescore::getWinningTeam();
		if( winner == "none" )
		{
			winner = "tie";
		}
	}
	else if ( level._teamBased )
	{
		if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
			winner = "tie";
		else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
			winner = "axis";
		else
			winner = "allies";
		logString( "scorelimit, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
	}
	else
	{
		winner = maps\mp\gametypes\_gamescore::getHighestScoringPlayer();
		if ( isDefined( winner ) )
			logString( "scorelimit, win: " + winner.name );
		else
			logString( "scorelimit, tie" );
	}
	
	thread endGame( winner, scoreText );
	return true;
}


updateGameEvents()
{
	if ( matchMakingGame() && !level._inGracePeriod )
	{
		if( level._multiTeamBased )
		{
			totalPlayers = 0;
			numActiveTeams = 0;
			for( i = 0; i < level._teamNameList.size; i++ )
			{
				totalPlayers = totalPlayers + level._teamCount[level._teamNameList[i]];
				if( level._teamCount[level._teamNameList[i]] )
				{
					numActiveTeams = numActiveTeams + 1;
				}
			}
			
			//now check if all players are on one team
			for( i = 0; i < level._teamNameList.size; i++ )
			{
				if( totalPlayers == level._teamCount[level._teamNameList[i]] && game["state"] == "playing" )
				{
					thread onForfeit( level._teamCount[level._teamNameList[i]] );
					return;
				}
			}
			
			if ( numActiveTeams > 1 )
			{
				level._forfeitInProgress = undefined;
				level notify( "abort_forfeit" );
			}
			
		}
		else if ( level._teamBased )
		{
			// if allies disconnected, and axis still connected, axis wins round and game ends to lobby
			if ( (level._hasSpawned["allies"] || level._console) && level._teamCount["allies"] < 1 && level._teamCount["axis"] > 0 && game["state"] == "playing" )
			{
				//allies forfeited
				thread onForfeit( "axis" );
				return;
			}
			
			// if axis disconnected, and allies still connected, allies wins round and game ends to lobby
			if ( (level._hasSpawned["axis"] || level._console) && level._teamCount["axis"] < 1 && level._teamCount["allies"] > 0 && game["state"] == "playing" )
			{
				//axis forfeited
				thread onForfeit( "allies" );
				return;
			}
	
			if ( level._teamCount["axis"] > 0 && level._teamCount["allies"] > 0 )
			{
				level._forfeitInProgress = undefined;
				level notify( "abort_forfeit" );
			}
		}
		else
		{
			if ( level._teamCount["allies"] + level._teamCount["axis"] == 1 && level._maxPlayerCount > 1 )
			{
				thread onForfeit();
				return;
			}

			if ( level._teamCount["axis"] + level._teamCount["allies"] > 1 )
			{
				level._forfeitInProgress = undefined;
				level notify( "abort_forfeit" );
			}
		}
	}

	if ( !getGametypeNumLives() && (!isDefined( level._disableSpawning ) || !level._disableSpawning) )
		return;
		
	if ( !gameHasStarted() ) 
		return;
	
	if ( level._inGracePeriod )
		return;

	if ( level._teamBased )
	{
		livesCount["allies"] = level._livesCount["allies"];
		livesCount["axis"] = level._livesCount["axis"];

		if ( isDefined( level._disableSpawning ) && level._disableSpawning )
		{
			livesCount["allies"] = 0;
			livesCount["axis"] = 0;
		}
		
		// if both allies and axis were alive and now they are both dead in the same instance
		if ( !level._aliveCount["allies"] && !level._aliveCount["axis"] && !livesCount["allies"] && !livesCount["axis"] )
		{
			return [[level._onDeadEvent]]( "all" );
		}

		// if allies were alive and now they are not
		if ( !level._aliveCount["allies"] && !livesCount["allies"] )
		{
			return [[level._onDeadEvent]]( "allies" );
		}

		// if axis were alive and now they are not
		if ( !level._aliveCount["axis"] && !livesCount["axis"] )
		{
			return [[level._onDeadEvent]]( "axis" );
		}

		// one ally left
		if ( level._aliveCount["allies"] == 1 && !livesCount["allies"] )
		{
			if ( !isDefined( level._oneLeftTime["allies"] ) )
			{
				level._oneLeftTime["allies"] = getTime();
				return [[level._onOneLeftEvent]]( "allies" );
			}
		}

		// one axis left
		if ( level._aliveCount["axis"] == 1 && !livesCount["axis"] )
		{
			if ( !isDefined( level._oneLeftTime["axis"] ) )
			{
				level._oneLeftTime["axis"] = getTime();
				return [[level._onOneLeftEvent]]( "axis" );
			}
		}
	}
	else
	{
		// everyone is dead
		if ( (!level._aliveCount["allies"] && !level._aliveCount["axis"]) && (!level._livesCount["allies"] && !level._livesCount["axis"]) )
		{
			return [[level._onDeadEvent]]( "all" );
		}

		livePlayers = getPotentialLivingPlayers();
		
		if ( livePlayers.size == 1 )
		{
			return [[level._onOneLeftEvent]]( "all" );
		}
	}
}


waittillFinalKillcamDone()
{
	if ( !level._showingFinalKillcam )
		return false;
	
	while ( level._showingFinalKillcam )
		wait ( 0.05 );
	
	return true;
}


timeLimitClock_Intermission( waitTime )
{
	setGameEndTime( getTime() + int(waitTime*1000) );
	clockObject = spawn( "script_origin", (0,0,0) );
	clockObject hide();
	
	if ( waitTime >= 10.0 )
		wait ( waitTime - 10.0 );
		
	for ( ;; )
	{
		clockObject playSound( "ui_mp_timer_countdown" );
		wait ( 1.0 );
	}	
}


waitForPlayers( maxTime )
{
	endTime = gettime() + maxTime * 1000 - 200;
	
	if ( level._teamBased )
		while( (!level._hasSpawned[ "axis" ] || !level._hasSpawned[ "allies" ]) && gettime() < endTime )
			wait ( 0.05 );
	else
		while ( level._maxPlayerCount < 2 && gettime() < endTime )
			wait ( 0.05 );
}


prematchPeriod()
{
	level endon( "game_ended" );

	if ( level._prematchPeriod > 0 )
	{
		if ( level._console )
		{
			thread matchStartTimerConsole( "match_starting_in", level._prematchPeriod );
			wait ( level._prematchPeriod );
		}
		else
		{
			matchStartTimerPC();
		}
	}
	else
	{
		matchStartTimerSkip();
	}
	
	for ( index = 0; index < level._players.size; index++ )
	{
		level._players[index] freezeControlsWrapper( false );
		level._players[index] enableWeapons();

		hintMessage = getObjectiveHintText( level._players[index].pers["team"] );
		if ( !isDefined( hintMessage ) || !level._players[index].hasSpawned )
			continue;

		level._players[index] setClientDvar( "scr_objectiveText", hintMessage );
		level._players[index] thread maps\mp\gametypes\_hud_message::hintMessage( hintMessage );
	}

	if ( game["state"] != "playing" )
		return;
}


gracePeriod()
{
	level endon("game_ended");
	
	while ( level._inGracePeriod )
	{
		wait ( 1.0 );
		level._inGracePeriod--;
	}

	//wait ( level.gracePeriod );
	
	level notify ( "grace_period_ending" );
	wait ( 0.05 );
	
	gameFlagSet( "graceperiod_done" );
	level._inGracePeriod = false;
	
	if ( game["state"] != "playing" )
		return;
	
	if ( getGametypeNumLives() )
	{
		// Players on a team but without a weapon show as dead since they can not get in this round
		players = level._players;
		
		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];
			
			if ( !player.hasSpawned && player.sessionteam != "spectator" && !isAlive( player ) )
				player.statusicon = "hud_status_dead";
		}
	}
	
	level thread updateGameEvents();
}


updateWinStats( winner )
{
	if ( !winner rankingEnabled() )
		return;
	
	winner maps\mp\gametypes\_persistence::statAdd( "losses", -1 );
	
	println( "setting winner: " + winner maps\mp\gametypes\_persistence::statGet( "wins" ) );
	winner maps\mp\gametypes\_persistence::statAdd( "wins", 1 );
	winner updatePersRatio( "winLossRatio", "wins", "losses" );
	winner maps\mp\gametypes\_persistence::statAdd( "currentWinStreak", 1 );
	
	cur_win_streak = winner maps\mp\gametypes\_persistence::statGet( "currentWinStreak" );
	if ( cur_win_streak > winner maps\mp\gametypes\_persistence::statGet( "winStreak" ) )
		winner maps\mp\gametypes\_persistence::statSet( "winStreak", cur_win_streak );
	
	winner maps\mp\gametypes\_persistence::statSetChild( "round", "win", true );
	winner maps\mp\gametypes\_persistence::statSetChild( "round", "loss", false );
}


updateLossStats( loser )
{
	if ( !loser rankingEnabled() )
		return;
	
	loser maps\mp\gametypes\_persistence::statAdd( "losses", 1 );
	loser updatePersRatio( "winLossRatio", "wins", "losses" );
	loser maps\mp\gametypes\_persistence::statSetChild( "round", "loss", true );
}


updateTieStats( loser )
{	
	if ( !loser rankingEnabled() )
		return;
	
	loser maps\mp\gametypes\_persistence::statAdd( "losses", -1 );
	
	loser maps\mp\gametypes\_persistence::statAdd( "ties", 1 );
	loser updatePersRatio( "winLossRatio", "wins", "losses" );
	loser maps\mp\gametypes\_persistence::statSet( "currentWinStreak", 0 );	
}


updateWinLossStats( winner )
{
	if ( privateMatch() )
		return;
		
	if ( !wasLastRound() )
		return;
		
	players = level._players;

	if ( !isDefined( winner ) || ( isDefined( winner ) && isString( winner ) && winner == "tie" ) )
	{
		foreach ( player in level._players )
		{
			if ( isDefined( player.connectedPostGame ) )
				continue;

			if ( level._hostForcedEnd && player isHost() )
			{
				player maps\mp\gametypes\_persistence::statSet( "currentWinStreak", 0 );
				continue;
			}
				
			updateTieStats( player );
		}		
	} 
	else if ( isPlayer( winner ) )
	{
		if ( level._hostForcedEnd && winner isHost() )
		{
			winner maps\mp\gametypes\_persistence::statSet( "currentWinStreak", 0 );
			return;
		}
				
		updateWinStats( winner );
	}
	else if ( isString( winner ) )
	{
		foreach ( player in level._players )
		{
			if ( isDefined( player.connectedPostGame ) )
				continue;

			if ( level._hostForcedEnd && player isHost() )
			{
				player maps\mp\gametypes\_persistence::statSet( "currentWinStreak", 0 );
				continue;
			}

			if ( winner == "tie" )
				updateTieStats( player );
			else if ( player.pers["team"] == winner )
				updateWinStats( player );
			else
				player maps\mp\gametypes\_persistence::statSet( "currentWinStreak", 0 );
		}
	}
}


freezePlayerForRoundEnd( delay )
{
	self endon ( "disconnect" );
	self clearLowerMessages();
	
	if ( !isDefined( delay ) )
		delay = 0.05;
	
	self closepopupMenu();
	self closeInGameMenu();
	
	wait ( delay );
	self freezeControlsWrapper( true );
//	self disableWeapons();
}


updateMatchBonusScores( winner )
{
	if ( !game["timePassed"] )
		return;

	if ( !matchMakingGame() )
		return;

	if ( !getTimeLimit() || level._forcedEnd )
	{
		gameLength = getTimePassed() / 1000;		
		// cap it at 20 minutes to avoid exploiting
		gameLength = min( gameLength, 1200 );
	}
	else
	{
		gameLength = getTimeLimit() * 60;
	}
		
	if ( level._teamBased )
	{
		if ( winner == "allies" )
		{
			winningTeam = "allies";
			losingTeam = "axis";
		}
		else if ( winner == "axis" )
		{
			winningTeam = "axis";
			losingTeam = "allies";
		}
		else
		{
			winningTeam = "tie";
			losingTeam = "tie";
		}

		if ( winningTeam != "tie" )
		{
			winnerScale = maps\mp\gametypes\_rank::getScoreInfoValue( "win" );
			loserScale = maps\mp\gametypes\_rank::getScoreInfoValue( "loss" );
			setWinningTeam( winningTeam );
		}
		else
		{
			winnerScale = maps\mp\gametypes\_rank::getScoreInfoValue( "tie" );
			loserScale = maps\mp\gametypes\_rank::getScoreInfoValue( "tie" );
		}
		
		foreach ( player in level._players )
		{
			if ( isDefined( player.connectedPostGame ) )
				continue;
			
			if ( !player rankingEnabled() )
				continue;
			
			if ( player.timePlayed["total"] < 1 || player.pers["participation"] < 1 )
			{
				player thread maps\mp\gametypes\_rank::endGameUpdate();
				continue;
			}
	
			// no bonus for hosts who force ends
			if ( level._hostForcedEnd && player isHost() )
				continue;

			spm = player maps\mp\gametypes\_rank::getSPM();				
			if ( winningTeam == "tie" )
			{
				playerScore = int( (winnerScale * ((gameLength/60) * spm)) * (player.timePlayed["total"] / gameLength) );
				player thread giveMatchBonus( "tie", playerScore );
				player.matchBonus = playerScore;
			}
			else if ( isDefined( player.pers["team"] ) && player.pers["team"] == winningTeam )
			{
				playerScore = int( (winnerScale * ((gameLength/60) * spm)) * (player.timePlayed["total"] / gameLength) );
				player thread giveMatchBonus( "win", playerScore );
				player.matchBonus = playerScore;
			}
			else if ( isDefined(player.pers["team"] ) && player.pers["team"] == losingTeam )
			{
				playerScore = int( (loserScale * ((gameLength/60) * spm)) * (player.timePlayed["total"] / gameLength) );
				player thread giveMatchBonus( "loss", playerScore );
				player.matchBonus = playerScore;
			}
		}
	}
	else
	{
		if ( isDefined( winner ) )
		{
			winnerScale = maps\mp\gametypes\_rank::getScoreInfoValue( "win" );
			loserScale = maps\mp\gametypes\_rank::getScoreInfoValue( "loss" );
		}
		else
		{
			winnerScale = maps\mp\gametypes\_rank::getScoreInfoValue( "tie" );
			loserScale = maps\mp\gametypes\_rank::getScoreInfoValue( "tie" );
		}
		
		foreach ( player in level._players )
		{
			if ( isDefined( player.connectedPostGame ) )
				continue;
			
			if ( player.timePlayed["total"] < 1 || player.pers["participation"] < 1 )
			{
				player thread maps\mp\gametypes\_rank::endGameUpdate();
				continue;
			}
			
			spm = player maps\mp\gametypes\_rank::getSPM();

			isWinner = false;
			for ( pIdx = 0; pIdx < min( level._placement["all"].size, 3 ); pIdx++ )
			{
				if ( level._placement["all"][pIdx] != player )
					continue;
				isWinner = true;				
			}
			
			if ( isWinner )
			{
				playerScore = int( (winnerScale * ((gameLength/60) * spm)) * (player.timePlayed["total"] / gameLength) );
				player thread giveMatchBonus( "win", playerScore );
				player.matchBonus = playerScore;
			}
			else
			{
				playerScore = int( (loserScale * ((gameLength/60) * spm)) * (player.timePlayed["total"] / gameLength) );
				player thread giveMatchBonus( "loss", playerScore );
				player.matchBonus = playerScore;
			}
		}
	}
}


giveMatchBonus( scoreType, score )
{
	self endon ( "disconnect" );

	level waittill ( "give_match_bonus" );
	
	self maps\mp\gametypes\_rank::giveRankXP( scoreType, score );
	//logXPGains();
	
	self maps\mp\gametypes\_rank::endGameUpdate();
}


setXenonRanks( winner )
{
	players = level._players;

	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if( !isdefined(player.score) || !isdefined(player.pers["team"]) )
			continue;

	}

	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if( !isdefined(player.score) || !isdefined(player.pers["team"]) )
			continue;		
		
		setPlayerTeamRank( player, player.clientid, player.score - 5 * player.deaths );
	}
	sendranks();
}


checkTimeLimit( prevTimePassed )
{
	if ( isDefined( level._timeLimitOverride ) && level._timeLimitOverride )
	{
		// Need to set GameEndTime for Escort since we could add time while timeLimitOverride is true (which will be the case when the UGV is moving).
		// No other game modes require this, but it should not cause problems as it will be simply setting it back to the current amount.
		timeLeft = getTimeRemaining();
		setGameEndTime( getTime() + int(timeLeft) );
		return;
	}
	
	if ( game["state"] != "playing" )
	{
		setGameEndTime( 0 );
		return;
	}
		
	if ( getTimeLimit() <= 0 )
	{
		if ( isDefined( level._startTime ) )
			setGameEndTime( level._startTime );
		else
			setGameEndTime( 0 );
		return;
	}
		
	if ( !gameFlag( "prematch_done" ) )
	{
		setGameEndTime( 0 );
		return;
	}
	
	if ( !isdefined( level._startTime ) )
		return;
	
	timeLeft = getTimeRemaining();
	
	// want this accurate to the millisecond
//	if ( getHalfTime() && game["status"] != "halftime" )
//		setGameEndTime( getTime() + (int(timeLeft) - int(getTimeLimit()*60*1000*0.5)) );
//	else
		setGameEndTime( getTime() + int(timeLeft) );

	if ( timeLeft > 0 )
	{
		if ( getHalfTime() && checkHalfTime( prevTimePassed ) )
			[[level._onHalfTime]]();

		return;
	}
	
	[[level._onTimeLimit]]();
}


checkHalfTime( prevTimePassed )
{
	if ( !level._teamBased )
		return false;
		
	if ( getTimeLimit() )
	{
		halfTime = (getTimeLimit() * 60 * 1000) * 0.5;
		
		if ( getTimePassed() >= halfTime && prevTimePassed < halfTime && prevTimePassed > 0 )
		{
			game["roundMillisecondsAlreadyPassed"] = getTimePassed();
			return true;
		}
	}
	
	return false;
}



getTimeRemaining()
{
	return getTimeLimit() * 60 * 1000 - getTimePassed();
}


checkTeamScoreLimitSoon( team )
{
	assert( isDefined( team ) );

	if ( getWatchedDvar( "scorelimit" ) <= 0 || isObjectiveBased() )
		return;
		
	if ( isDefined( level._scoreLimitOverride ) && level._scoreLimitOverride )
		return;
		
	if ( !level._teamBased )
		return;

	// No checks until a minute has passed to let wild data settle
	if ( getTimePassed() < (60 * 1000) ) // 1 min
		return;
	
	timeLeft = estimatedTimeTillScoreLimit( team );

	if ( timeLeft < 2 )
		level notify( "match_ending_soon", "score" );
}


checkPlayerScoreLimitSoon()
{
	if ( getWatchedDvar( "scorelimit" ) <= 0 || isObjectiveBased() )
		return;
		
	if ( level._teamBased )
		return;

	// No checks until a minute has passed to let wild data settle
	if ( getTimePassed() < (60 * 1000) ) // 1 min
		return;

	timeLeft = self estimatedTimeTillScoreLimit();

	if ( timeLeft < 2 )
		level notify( "match_ending_soon", "score" );
}


checkScoreLimit()
{
	if ( isObjectiveBased() )
		return false;

	if ( isDefined( level._scoreLimitOverride ) && level._scoreLimitOverride )
		return false;
	
	if ( game["state"] != "playing" )
		return false;

	if ( getWatchedDvar( "scorelimit" ) <= 0 )
		return false;

	if( level._multiTeamBased )
	{
		limitReached = false;
		
		for( i = 0; i < level._teamNameList.size; i++ )
		{
			if( game["teamScores"][level._teamNameList[i]] >= getWatchedDvar( "scorelimit" ))
			{
				limitReached = true;
			}
		}
		
		if( !limitReached )
		{
			return false;
		}
	}
	else if ( level._teamBased )
	{
		if( game["teamScores"]["allies"] < getWatchedDvar( "scorelimit" ) && game["teamScores"]["axis"] < getWatchedDvar( "scorelimit" ) )
			return false;
	}
	else
	{
		if ( !isPlayer( self ) )
			return false;

		if ( self.score < getWatchedDvar( "scorelimit" ) )
			return false;
	}

	return [[level._onScoreLimit]]();
}


updateGameTypeDvars()
{
	level endon ( "game_ended" );
	
	while ( game["state"] == "playing" )
	{
		// make sure we check time limit right when game ends
		if ( isdefined( level._startTime ) )
		{
			if ( getTimeRemaining() < 3000 )
			{
				wait .1;
				continue;
			}
		}
		wait 1;
	}
}


matchStartTimerPC()
{	
	visionSetNaked( "mpIntro", 0 );
	
	matchStartText = createServerFontString( "objective", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -20 );
	matchStartText.sort = 1001;
	matchStartText setText( game["strings"]["waiting_for_teams"] );
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = true;
	
	matchStartTimer = createServerTimer( "objective", 1.4 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, 0 );
	matchStartTimer setTimer( level._prematchPeriod );
	matchStartTimer.sort = 1001;
	matchStartTimer.foreground = false;
	matchStartTimer.hideWhenInMenu = true;
	
	waitForPlayers( level._prematchPeriod );
	
	if ( level._prematchPeriodEnd > 0 )
	{
		matchStartText setText( game["strings"]["match_starting_in"] );
		matchStartTimer setTimer( level._prematchPeriodEnd );
		
		wait level._prematchPeriodEnd;
	}
	
	visionSetNaked( getDvar( "mapname" ), 2.0 );
	
	matchStartText destroyElem();
	matchStartTimer destroyElem();
}

matchStartTimerConsole_Internal( countTime, matchStartTimer )
{
	waittillframeend; // wait till cleanup of previous start timer if multiple happen at once
	visionSetNaked( "mpIntro", 0 );
	
	level endon( "match_start_timer_beginning" );
	while ( countTime > 0 && !level._gameEnded )
	{
		matchStartTimer thread maps\mp\gametypes\_hud::fontPulse( level );
		wait ( matchStartTimer.inFrames * 0.05 );
		matchStartTimer setValue( countTime );
		if ( countTime == 2 )
			visionSetNaked( getDvar( "mapname" ), 3.0 );
		countTime--;
		wait ( 1 - (matchStartTimer.inFrames * 0.05) );
	}
}

matchStartTimerConsole( type, duration )
{
	level notify( "match_start_timer_beginning" );
	
	matchStartText = createServerFontString( "objective", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -40 );
	matchStartText.sort = 1001;
	matchStartText setText( game["strings"]["waiting_for_teams"] );
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = true;
	
	matchStartText setText( game["strings"][type] ); // "match begins in:"
	
	matchStartTimer = createServerFontString( "hudbig", 1 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, 0 );
	matchStartTimer.sort = 1001;
	matchStartTimer.color = (1,1,0);
	matchStartTimer.foreground = false;
	matchStartTimer.hidewheninmenu = true;
	
	matchStartTimer maps\mp\gametypes\_hud::fontPulseInit();

	countTime = int( duration );
	
	if ( countTime >= 2 )
	{
		matchStartTimerConsole_Internal( countTime, matchStartTimer );
		visionSetNaked( getDvar( "mapname" ), 3.0 );
	}
	else
	{
		visionSetNaked( "mpIntro", 0 );
		visionSetNaked( getDvar( "mapname" ), 1.0 );
	}
	
	matchStartTimer destroyElem();
	matchStartText destroyElem();
}

matchStartTimerSkip()
{
	visionSetNaked( getDvar( "mapname" ), 0 );
}


onRoundSwitch()
{
	if ( !isDefined( game["switchedsides"] ) )
		game["switchedsides"] = false;
	
	// overtime
	if ( game["roundsWon"]["allies"] == getWatchedDvar( "winlimit" ) - 1 && game["roundsWon"]["axis"] == getWatchedDvar( "winlimit" ) - 1 )
	{
		aheadTeam = getBetterTeam();
		if ( aheadTeam != game["defenders"] )
		{
			game["switchedsides"] = !game["switchedsides"];
		}
		else
		{
			level._halftimeSubCaption = "";
		}
		level._halftimeType = "overtime";
	}
	else
	{
		level._halftimeType = "halftime";
		game["switchedsides"] = !game["switchedsides"];
	}
}


checkRoundSwitch()
{
	if ( !level._teamBased )
		return false;
		
	if ( !isDefined( level._roundSwitch ) || !level._roundSwitch )
		return false;
		
	assert( game["roundsPlayed"] > 0 );	
	if ( game["roundsPlayed"] % level._roundSwitch == 0 )
	{
		onRoundSwitch();
		return true;
	}
		
	return false;
}


// returns the best guess of the exact time until the scoreboard will be displayed and player control will be lost.
// returns undefined if time is not known
timeUntilRoundEnd()
{
	if ( level._gameEnded )
	{
		timePassed = (getTime() - level._gameEndTime) / 1000;
		timeRemaining = level._postRoundTime - timePassed;
		
		if ( timeRemaining < 0 )
			return 0;
		
		return timeRemaining;
	}
	
	if ( getTimeLimit() <= 0 )
		return undefined;
	
	if ( !isDefined( level._startTime ) )
		return undefined;
	
	tl = getTimeLimit();
	
	timePassed = (getTime() - level._startTime)/1000;
	timeRemaining = (getTimeLimit() * 60) - timePassed;
	
	if ( isDefined( level._timePaused ) )
		timeRemaining += level._timePaused; 
	
	return timeRemaining + level._postRoundTime;
}



freeGameplayHudElems()
{
	// free up some hud elems so we have enough for other things.
	
	// perk icons
	if ( isdefined( self.perkicon ) )
	{
		if ( isdefined( self.perkicon[0] ) )
		{
			self.perkicon[0] destroyElem();
			self.perkname[0] destroyElem();
		}
		if ( isdefined( self.perkicon[1] ) )
		{
			self.perkicon[1] destroyElem();
			self.perkname[1] destroyElem();
		}
		if ( isdefined( self.perkicon[2] ) )
		{
			self.perkicon[2] destroyElem();
			self.perkname[2] destroyElem();
		}
	}
	self notify("perks_hidden"); // stop any threads that are waiting to hide the perk icons
	
	// lower message
	self.lowerMessage destroyElem();
	self.lowerTimer destroyElem();
	
	// progress bar
	if ( isDefined( self.proxBar ) )
		self.proxBar destroyElem();
	if ( isDefined( self.proxBarText ) )
		self.proxBarText destroyElem();
}


getHostPlayer()
{
	players = getEntArray( "player", "classname" );
	
	for ( index = 0; index < players.size; index++ )
	{
		if ( players[index] isHost() )
			return players[index];
	}
}


hostIdledOut()
{
	hostPlayer = getHostPlayer();
	
	// host never spawned
	if ( isDefined( hostPlayer ) && !hostPlayer.hasSpawned && !isDefined( hostPlayer.selectedClass ) )
		return true;

	return false;
}



roundEndWait( defaultDelay, matchBonus )
{
	//setSlowMotion( 1.0, 0.15, defaultDelay / 2 );

	notifiesDone = false;
	while ( !notifiesDone )
	{
		players = level._players;
		notifiesDone = true;
		
		foreach ( player in players )
		{
			if ( !isDefined( player.doingSplash ) )
				continue;

			if ( !player maps\mp\gametypes\_hud_message::isDoingSplash() )
				continue;

			notifiesDone = false;
		}
		wait ( 0.5 );
	}

	if ( !matchBonus )
	{
		wait ( defaultDelay );
		level notify ( "round_end_finished" );
		//setSlowMotion( 1.0, 1.0, 0.05 );
		return;
	}

    wait ( defaultDelay / 2 );
	level notify ( "give_match_bonus" );
	wait ( defaultDelay / 2 );

	notifiesDone = false;
	while ( !notifiesDone )
	{
		players = level._players;
		notifiesDone = true;
		foreach ( player in players )
		{
			if ( !isDefined( player.doingSplash ) )
				continue;

			if ( !player maps\mp\gametypes\_hud_message::isDoingSplash() )
				continue;

			notifiesDone = false;
		}
		wait ( 0.5 );
	}
	//setSlowMotion( 1.0, 1.0, 0.05);
	
	level notify ( "round_end_finished" );
}


roundEndDOF( time )
{
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
}


Callback_StartGameType()
{
	maps\mp\_load::main();
	
	levelFlagInit( "round_over", false );
	levelFlagInit( "game_over", false );
	levelFlagInit( "block_notifies", false ); 

	level._prematchPeriod = 0;
	level._prematchPeriodEnd = 0;
	level._postGameNotifies = 0;
	
	level._intermission = false;
	
	makeDvarServerInfo( "cg_thirdPersonAngle", 356 );

	makeDvarServerInfo( "scr_gameended", 0 );

	if ( !isDefined( game["gamestarted"] ) )
	{
		game["clientid"] = 0;
		
		alliesCharSet = getMapCustom( "allieschar" );
		if ( (!isDefined( alliesCharSet ) || alliesCharSet == "") )
		{
			if ( !isDefined( game["allies"] ) )
				alliesCharSet = "nx_us";
			else
				alliesCharSet = game["allies"];
		}

		axisCharSet = getMapCustom( "axischar" );
		if ( (!isDefined( axisCharSet ) || axisCharSet == "") )
		{
			if ( !isDefined( game["axis"] ) )
				axisCharSet = "nx_ec";
			else
				axisCharSet = game["axis"];
		}


		if( level._multiTeamBased )
		{
			for( i = 0; i < level._teamNameList.size; i++ )
			{
				//this call will not find anything until we add team specifications to basemaps.arena
				multiTeamDefaultCharacterSet = getMapCustom( level._teamNameList[i] + "char" );
				if (( !isDefined( multiTeamDefaultCharacterSet ) || multiTeamDefaultCharacterSet == "" ))
				{
					//TagZP<TODO> fix.  Temporary solution is to alternate between axis and allies char set for mtdm.
					if( i % 2 == 0 )
					{
						multiTeamDefaultCharacterSet = alliesCharSet;
					}
					else
					{
						multiTeamDefaultCharacterSet = axisCharSet;
					}
				}
				//println( "assigning char set team = " + level._teamNameList[i] + " " + multiTeamDefaultCharacterSet );
				game[level._teamNameList[i]] = multiTeamDefaultCharacterSet;
			}
		}

		game["allies"] = alliesCharSet;
		game["axis"] = axisCharSet;	

		if ( !isDefined( game["attackers"] ) || !isDefined( game["defenders"] ))
			thread error( "No attackers or defenders team defined in level .gsc." );

		if (  !isDefined( game["attackers"] ) )
			game["attackers"] = "allies";
		if (  !isDefined( game["defenders"] ) )
			game["defenders"] = "axis";

		if ( !isDefined( game["state"] ) )
			game["state"] = "playing";
	
		precacheStatusIcon( "hud_status_dead" );
		precacheStatusIcon( "hud_status_connecting" );
		precacheString( &"MPUI_REVIVING" );
		precacheString( &"MPUI_BEING_REVIVED" );
		
		precacheRumble( "damage_heavy" );
		precacheRumble( "dtp_rumble" );

		precacheShader( "white" );
		precacheShader( "black" );
			
		game["strings"]["press_to_spawn"] = &"PLATFORM_PRESS_TO_SPAWN";
		if ( level._teamBased )
		{
			game["strings"]["waiting_for_teams"] = &"MP_WAITING_FOR_TEAMS";
			game["strings"]["opponent_forfeiting_in"] = &"MP_OPPONENT_FORFEITING_IN";
		}
		else
		{
			game["strings"]["waiting_for_teams"] = &"MP_WAITING_FOR_MORE_PLAYERS";
			game["strings"]["opponent_forfeiting_in"] = &"MP_OPPONENT_FORFEITING_IN";
		}
		game["strings"]["match_starting_in"] = &"MP_MATCH_STARTING_IN";
		game["strings"]["match_resuming_in"] = &"MP_MATCH_RESUMING_IN";
		game["strings"]["waiting_for_players"] = &"MP_WAITING_FOR_PLAYERS";
		game["strings"]["spawn_next_round"] = &"MP_SPAWN_NEXT_ROUND";
		game["strings"]["waiting_to_spawn"] = &"MP_WAITING_TO_SPAWN";
		game["strings"]["waiting_to_safespawn"] = &"MP_WAITING_TO_SAFESPAWN";
		game["strings"]["match_starting"] = &"MP_MATCH_STARTING";
		game["strings"]["change_class"] = &"MP_CHANGE_CLASS_NEXT_SPAWN";
		game["strings"]["last_stand"] = &"MPUI_LAST_STAND";
		game["strings"]["final_stand"] = &"MPUI_FINAL_STAND";
		game["strings"]["c4_death"] = &"MPUI_C4_DEATH";
		
		game["strings"]["cowards_way"] = &"PLATFORM_COWARDS_WAY_OUT";
		
		game["strings"]["tie"] = &"MP_MATCH_TIE";
		game["strings"]["round_draw"] = &"MP_ROUND_DRAW";

		game["strings"]["grabbed_flag"] = &"MP_GRABBED_FLAG_FIRST";
		game["strings"]["enemies_eliminated"] = &"MP_ENEMIES_ELIMINATED";
		game["strings"]["score_limit_reached"] = &"MP_SCORE_LIMIT_REACHED";
		game["strings"]["round_limit_reached"] = &"MP_ROUND_LIMIT_REACHED";
		game["strings"]["time_limit_reached"] = &"MP_TIME_LIMIT_REACHED";
		game["strings"]["players_forfeited"] = &"MP_PLAYERS_FORFEITED";
		game["strings"]["S.A.S Win"] = &"SAS_WIN";
		game["strings"]["Spetsnaz Win"] = &"SPETSNAZ_WIN";

		game["colors"]["blue"] = (0.25,0.25,0.75);
		game["colors"]["red"] = (0.75,0.25,0.25);
		game["colors"]["white"] = (1.0,1.0,1.0);
		game["colors"]["black"] = (0.0,0.0,0.0);
		game["colors"]["green"] = (0.25,0.75,0.25);
		game["colors"]["yellow"] = (0.65,0.65,0.0);
		game["colors"]["orange"] = (1.0,0.45,0.0);

		//TagZP<NOTE> future cleanup - integrate this chunk of code with the loop below.
		game["strings"]["allies_eliminated"] = maps\mp\gametypes\_teams::getTeamEliminatedString( "allies" );
		game["strings"]["allies_forfeited"] = maps\mp\gametypes\_teams::getTeamForfeitedString( "allies" );
		game["strings"]["allies_name"] = maps\mp\gametypes\_teams::getTeamName( "allies" );	
		game["icons"]["allies"] = maps\mp\gametypes\_teams::getTeamIcon( "allies" );	
		game["colors"]["allies"] = maps\mp\gametypes\_teams::getTeamColor( "allies" );	

		game["strings"]["axis_eliminated"] = maps\mp\gametypes\_teams::getTeamEliminatedString( "axis" );
		game["strings"]["axis_forfeited"] = maps\mp\gametypes\_teams::getTeamForfeitedString( "axis" );
		game["strings"]["axis_name"] = maps\mp\gametypes\_teams::getTeamName( "axis" );	
		game["icons"]["axis"] = maps\mp\gametypes\_teams::getTeamIcon( "axis" );
		game["colors"]["axis"] = maps\mp\gametypes\_teams::getTeamColor( "axis" );
		
		//TagZP<NOTE> this should be able to replace the 10 lines above for all gametypes, for now just focusing on MTDM
		if( level._multiTeamBased == true )
		{
			for( i = 0; i < level._teamNameList.size; i++ )
			{
				str_team_eliminated = level._teamNameList[i] + "_eliminated";
				str_team_forfeited = level._teamNameList[i] + "_forfeited";
				str_team_name = level._teamNameList[i] + "_name";
				
				game["strings"][str_team_eliminated] = maps\mp\gametypes\_teams::getTeamEliminatedString( level._teamNameList[i] );
				game["strings"][str_team_forfeited] = maps\mp\gametypes\_teams::getTeamForfeitedString( level._teamNameList[i] );
				game["strings"][str_team_name] = maps\mp\gametypes\_teams::MTDM_getTeamName( level._teamNameList[i] );
				
				game["icons"][level._teamNameList[i]] = maps\mp\gametypes\_teams::MTDM_getTeamIcon( level._teamNameList[i] );
				game["colors"][level._teamNameList[i]] = maps\mp\gametypes\_teams::getTeamColor( level._teamNameList[i] );
			}
		}
		
		if ( game["colors"]["allies"] == (0,0,0) )
			game["colors"]["allies"] = (0.5,0.5,0.5);

		if ( game["colors"]["axis"] == (0,0,0) )
			game["colors"]["axis"] = (0.5,0.5,0.5);
			
		//safty catch for color setup
		if( level._multiTeamBased == true )
		{
			for( i = 0; i < level._teamNameList.size; i++ )
			{
				if ( game["colors"][level._teamNameList[i]] == (0,0,0) )
				{
					game["colors"][level._teamNameList[i]] = (0.5,0.5,0.5);
				}
			}
		}

		[[level._onPrecacheGameType]]();

		if ( level._console )
		{
			if ( !level._splitscreen )
				level._prematchPeriod = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "graceperiod" );
		}
		else
		{
			// first round, so set up prematch
			level._prematchPeriod = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "playerwaittime" );
			level._prematchPeriodEnd = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "matchstarttime" );
		}
	}
	else
	{
		if ( isDefined( level._secondaryCountdown ) && level._secondaryCountdown )
		{
			level._prematchPeriod = level._secondaryCountdown;
		}
	}

	if ( !isDefined( game["status"] ) )
		game["status"] = "normal";

	makeDvarServerInfo( "ui_overtime", (game["status"] == "overtime") );

	if ( game["status"] != "overtime" && game["status"] != "halftime" )
	{
		// If flag is set & we're not on round 0, do not reset the score.
		if ( isDefined( level._maintainScoresBetweenRounds ) && ( level._maintainScoresBetweenRounds == true ) && isDefined( game["roundsPlayed"] ) && ( game[ "roundsPlayed" ] > 0 ) )
		{
			// We're in between rounds, skip resetting the score.
		}
		else
		{
			// Reset the score.
			game["teamScores"]["allies"] = 0;
			game["teamScores"]["axis"] = 0;
		}
		
		//init team scores for mtdm
		if( level._multiTeamBased == true )
		{
			for( i = 0; i < level._teamNameList.size; i++ )
			{
				game["teamScores"][level._teamNameList[i]] = 0;
			}
		}
	}
	
	if( !isDefined( game["timePassed"] ) )
		game["timePassed"] = 0;

	if( !isDefined( game["roundsPlayed"] ) )
		game["roundsPlayed"] = 0;

	if ( !isDefined( game["roundsWon"] ) )
		game["roundsWon"] = [];

	if ( level._teamBased )
	{
		if ( !isDefined( game["roundsWon"]["axis"] ) )
			game["roundsWon"]["axis"] = 0;
		if ( !isDefined( game["roundsWon"]["allies"] ) )		
			game["roundsWon"]["allies"] = 0;
			
		//init match history for mtdm
		if( level._multiTeamBased )
		{
			for( i = 0; i < level._teamNameList.size; i++ )
			{
				if ( !isDefined( game["roundsWon"][level._teamNameList[i]] ))
				{
					game["roundsWon"][level._teamNameList[i]] = 0;
				}
			}
		}
	}
	
	level._gameEnded = false;
	level._forcedEnd = false;
	level._hostForcedEnd = false;

	level._hardcoreMode = getDvarInt( "g_hardcore" );
	if ( level._hardcoreMode )
		logString( "game mode: hardcore" );

	level._dieHardMode = getDvarInt( "scr_diehard" );
	
	if ( !level._teamBased )
		level._dieHardMode = 0;

	if ( level._dieHardMode )
		logString( "game mode: diehard" );

	level._killstreakRewards = getDvarInt( "scr_game_hardpoints" );

	/#
	printLn( "SESSION INFO" );
	printLn( "=====================================" );
	printLn( "  Map:         " + level._script );
	printLn( "  Script:      " + level._gametype );
	printLn( "  HardCore:    " + level._hardcoreMode );
	printLn( "  Diehard:     " + level._dieHardMode );
	printLn( "  3rd Person:  " + getDvarInt( "camera_thirdperson" ) );
	printLn( "  Round:       " + game[ "roundsPlayed" ] );
	printLn( "  scr_" + level._gametype + "_scorelimit " + getDvar( "scr_" + level._gametype + "_scorelimit" ) );
	printLn( "  scr_" + level._gametype + "_roundlimit " +getDvar( "scr_" + level._gametype + "_roundlimit" ) );
	printLn( "  scr_" + level._gametype + "_winlimit " + getDvar( "scr_" + level._gametype + "_winlimit" ) );
	printLn( "  scr_" + level._gametype + "_timelimit " + getDvar( "scr_" + level._gametype + "_timelimit" ) );
	printLn( "  scr_" + level._gametype + "_numlives " + getDvar( "scr_" + level._gametype + "_numlives" ) );
	printLn( "  scr_" + level._gametype + "_halftime " + getDvar( "scr_" + level._gametype + "_halftime" ) );
	printLn( "  scr_" + level._gametype + "_roundswitch " + getDvar( "scr_" + level._gametype + "_roundswitch" ) );
	printLn( "=====================================" );
	#/

	// this gets set to false when someone takes damage or a gametype-specific event happens.
	level._useStartSpawns = true;

	// multiplier for score from objectives
	level._objectivePointsMod = 1;

	if ( matchMakingGame() )	
		level._maxAllowedTeamKills = 2;
	else
		level._maxAllowedTeamKills = -1;
		
	thread maps\mp\gametypes\_persistence::init();
	thread maps\mp\gametypes\_menus::init();
	thread maps\mp\gametypes\_hud::init();
	thread maps\mp\gametypes\_serversettings::init();
	thread maps\mp\gametypes\_teams::init();			//tagZP<NOTE> team setup still needs work for mtdm in setupScoreboard.
	thread maps\mp\gametypes\_weapons::init();
	thread maps\mp\gametypes\_killcam::init();
	thread maps\mp\gametypes\_shellshock::init();
	thread maps\mp\gametypes\_deathicons::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	thread maps\mp\gametypes\_healthoverlay::init();
	thread maps\mp\gametypes\_spectating::init();
	thread maps\mp\gametypes\_objpoints::init();
	thread maps\mp\gametypes\_gameobjects::init();
	thread maps\mp\gametypes\_spawnlogic::init();		//tagZP<NOTE> spawnpoint setup still needs work for mtdm.
	thread maps\mp\gametypes\_battlechatter_mp::init();
	thread maps\mp\gametypes\_music_and_dialog::init();	//tagZP<NOTE> still a bit of work to do here as well
	thread maps\mp\_matchdata::init();
	thread maps\mp\_awards::init();
	thread maps\mp\_intel::init();
	thread maps\mp\_adrenaline::init();
	thread maps\mp\_skill::init();
	thread maps\mp\_areas::init();
	thread maps\mp\killstreaks\_killstreaks::init();	//tagZP<NOTE> disabled for mtdm first pass.
	//thread maps\mp\_perks::init(); // No longer in use, removed from common scripts. (smart arrow)
	thread maps\mp\perks\_perks::init();
	thread maps\mp\perks\_buffs::init();
	thread maps\mp\_events::init();
	thread maps\mp\_defcon::init();
	thread maps\mp\_upgrade::init();
	
	if ( level._teamBased )
		thread maps\mp\gametypes\_friendicons::init();
		
	thread maps\mp\gametypes\_hud_message::init();

	if ( !level._console )
		thread maps\mp\gametypes\_quickmessages::init();

	foreach ( locString in game["strings"] )
		precacheString( locString );

	foreach ( icon in game["icons"] )
		precacheShader( icon );
		
	game["gamestarted"] = true;

	level._maxPlayerCount = 0;
	level._waveDelay["allies"] = 0;
	level._waveDelay["axis"] = 0;
	level._lastWave["allies"] = 0;
	level._lastWave["axis"] = 0;
	level._wavePlayerSpawnIndex["allies"] = 0;
	level._wavePlayerSpawnIndex["axis"] = 0;
	level._alivePlayers["allies"] = [];
	level._alivePlayers["axis"] = [];
	level._activePlayers = [];
	
	//mtdm setup wave delay
	if( level._multiTeamBased == true )
	{
		for( i = 0; i < level._teamNameList.size; i++ )
		{
			level._waveDelay[level._teamNameList[i]] = 0;
			level._lastWave[level._teamNameList[i]] = 0;
			level._wavePlayerSpawnIndex[level._teamNameList[i]] = 0;
			level._alivePlayers[level._teamNameList[i]] = [];
		}
	}

	makeDvarServerInfo( "ui_scorelimit", 0 );
	makeDvarServerInfo( "ui_allow_classchange", getDvar( "ui_allow_classchange" ) );
	makeDvarServerInfo( "ui_allow_teamchange", 1 );
	setDvar( "ui_allow_teamchange", 1 );
	
	if ( getGametypeNumLives() )
		setdvar( "g_deadChat", 0 );
	else
		setdvar( "g_deadChat", 1 );
	
	waveDelay = getDvarInt( "scr_" + level._gameType + "_waverespawndelay" );
	if ( waveDelay )
	{
		level._waveDelay["allies"] = waveDelay;
		level._waveDelay["axis"] = waveDelay;
		level._lastWave["allies"] = 0;
		level._lastWave["axis"] = 0;
		
		if( level._multiTeamBased == true )
		{
			for( i = 0; i < level.maxNumTeams; i++ )
			{
				level._waveDelay[level._teamNameList[i]] = waveDelay;
				level._lastWave[level._teamNameList[i]] = 0;
			}
		}
		
		level thread maps\mp\gametypes\_gamelogic::waveSpawnTimer();
	}
	
	gameFlagInit( "prematch_done", false );
	
	level._gracePeriod = 15;
	
	level._inGracePeriod = level._gracePeriod;
	gameFlagInit( "graceperiod_done", false );
	
	level._roundEndDelay = 4;
	level._halftimeRoundEndDelay = 4;
	

	if ( level._teamBased )
	{
		maps\mp\gametypes\_gamescore::updateTeamScore( "axis" );
		maps\mp\gametypes\_gamescore::updateTeamScore( "allies" );
		
		if( level._multiTeamBased == true )
		{
			for( i = 0; i < level._teamNameList.size; i++ )
			{
				maps\mp\gametypes\_gamescore::updateTeamScore( level._teamNameList[i] );
			}
		}
	}
	else
	{
		thread maps\mp\gametypes\_gamescore::initialDMScoreUpdate();
	}

	thread updateUIScoreLimit();
	level notify ( "update_scorelimit" );

	
	[[level._onStartGameType]]();
	
	// this must be after onstartgametype for scr_showspawns to work when set at start of game
	thread maps\mp\gametypes\_dev::init();
	
	thread startGame();

	level thread updateWatchedDvars();
	level thread timeLimitThread();
}


Callback_CodeEndGame()
{
	endparty();

	if ( !level._gameEnded )
		level thread maps\mp\gametypes\_gamelogic::forceEnd();
}


timeLimitThread()
{
	level endon ( "game_ended" );
	
	prevTimePassed = getTimePassed();
	
	while ( game["state"] == "playing" )
	{
		thread checkTimeLimit( prevTimePassed );
		prevTimePassed = getTimePassed();
		
		// make sure we check time limit right when game ends
		if ( isdefined( level._startTime ) )
		{
			if ( getTimeRemaining() < 3000 )
			{
				wait .1;
				continue;
			}
		}
		wait 1;
	}	
}


updateUIScoreLimit()
{
	for ( ;; )
	{
		level waittill_either ( "update_scorelimit", "update_winlimit" );
		
		if ( !isRoundBased() || !isObjectiveBased() )
		{
			setDvar( "ui_scorelimit", getWatchedDvar( "scorelimit" ) );
			thread checkScoreLimit();
		}
		else
		{
			setDvar( "ui_scorelimit", getWatchedDvar( "winlimit" ) );
		}
	}
}


playTickingSound()
{
	self endon("death");
	self endon("stop_ticking");
	level endon("game_ended");
	
	time = level._bombTimer;
	
	while(1)
	{
		self playSound( "ui_mp_suitcasebomb_timer" );
		
		if ( time > 10 )
		{
			time -= 1;
			wait 1;
		}
		else if ( time > 4 )
		{
			time -= .5;
			wait .5;
		}
		else if ( time > 1 )
		{
			time -= .4;
			wait .4;
		}
		else
		{
			time -= .3;
			wait .3;
		}
		maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
	}
}

stopTickingSound()
{
	self notify("stop_ticking");
}

timeLimitClock()
{
	level endon ( "game_ended" );
	
	wait .05;
	
	clockObject = spawn( "script_origin", (0,0,0) );
	clockObject hide();
	
	while ( game["state"] == "playing" )
	{
		if ( !level._timerStopped && getTimeLimit() )
		{
			timeLeft = getTimeRemaining() / 1000;
			timeLeftInt = int(timeLeft + 0.5); // adding .5 and flooring rounds it.
			
			if ( getHalfTime() && timeLeftInt > (getTimeLimit()*60) * 0.5 )
				timeLeftInt -= int((getTimeLimit()*60) * 0.5);
			
			if ( (timeLeftInt >= 30 && timeLeftInt <= 60) )
				level notify ( "match_ending_soon", "time" );

			if ( timeLeftInt <= 10 || (timeLeftInt <= 30 && timeLeftInt % 2 == 0) )
			{
				level notify ( "match_ending_very_soon" );
				// don't play a tick at exactly 0 seconds, that's when something should be happening!
				if ( timeLeftInt == 0 )
					break;
				
				clockObject playSound( "ui_mp_timer_countdown" );
			}
			
			// synchronize to be exactly on the second
			if ( timeLeft - floor(timeLeft) >= .05 )
				wait timeLeft - floor(timeLeft);
		}

		wait ( 1.0 );
	}
}


gameTimer()
{
	level endon ( "game_ended" );
	
	level waittill("prematch_over");
	
	level._startTime = getTime();
	level._discardTime = 0;
	
	if ( isDefined( game["roundMillisecondsAlreadyPassed"] ) )
	{
		level._startTime -= game["roundMillisecondsAlreadyPassed"];
		game["roundMillisecondsAlreadyPassed"] = undefined;
	}
	
	prevtime = gettime();
	
	while ( game["state"] == "playing" )
	{
		if ( !level._timerStopped )
		{
			// the wait isn't always exactly 1 second. dunno why.
			game["timePassed"] += gettime() - prevtime;
		}
		prevtime = gettime();
		wait ( 1.0 );
	}
}

UpdateTimerPausedness()
{
	shouldBeStopped = level._timerStoppedForGameMode || isDefined( level._hostMigrationTimer );
	if ( !gameFlag( "prematch_done" ) )
		shouldBeStopped = false;
	
	if ( !level._timerStopped && shouldBeStopped )
	{
		level._timerStopped = true;
		level._timerPauseTime = gettime();
	}
	else if ( level._timerStopped && !shouldBeStopped )
	{
		level._timerStopped = false;
		level._discardTime += gettime() - level._timerPauseTime;
	}
}

pauseTimer()
{
	level._timerStoppedForGameMode = true;
	UpdateTimerPausedness();
}

resumeTimer()
{
	level._timerStoppedForGameMode = false;
	UpdateTimerPausedness();
}


startGame()
{
	thread gameTimer();
	level._timerStopped = false;
	level._timerStoppedForGameMode = false;
	thread maps\mp\gametypes\_spawnlogic::spawnPerFrameUpdate();

	prematchPeriod();
	gameFlagSet( "prematch_done" );	
	level notify("prematch_over");
	
	UpdateTimerPausedness();
	
	thread timeLimitClock();
	thread gracePeriod();

	thread maps\mp\gametypes\_missions::roundBegin();	
}


waveSpawnTimer()
{
	level endon( "game_ended" );

	while ( game["state"] == "playing" )
	{
		time = getTime();
		
		if ( time - level._lastWave["allies"] > (level._waveDelay["allies"] * 1000) )
		{
			level notify ( "wave_respawn_allies" );
			level._lastWave["allies"] = time;
			level._wavePlayerSpawnIndex["allies"] = 0;
		}

		if ( time - level._lastWave["axis"] > (level._waveDelay["axis"] * 1000) )
		{
			level notify ( "wave_respawn_axis" );
			level._lastWave["axis"] = time;
			level._wavePlayerSpawnIndex["axis"] = 0;
		}
		
		if( level._multiTeamBased == true )
		{
			for( i = 0; i < level._teamNameList.size; i++ )
			{
				if ( time - level._lastWave[level._teamNameList[i]] > (level._waveDelay[level._teamNameList[i]] * 1000) )
				{
					str_notify = "wave_rewpawn_" + level._teamNameList[i];
					//tsgZP<NOTE> this is not getting recieved yet
					level notify ( str_notify );
					level._lastWave[level._teamNameList[i]] = time;
					level._wavePlayerSpawnIndex[level._teamNameList[i]] = 0;
				}
			}
		}
		
		wait ( 0.05 );
	}
}


getBetterTeam()
{
	kills["allies"] = 0;
	kills["axis"] = 0;
	deaths["allies"] = 0;
	deaths["axis"] = 0;
	
	foreach ( player in level._players )
	{
		team = player.pers["team"];
		if ( isDefined( team ) && (team == "allies" || team == "axis") )
		{
			kills[ team ] += player.kills;
			deaths[ team ] += player.deaths;
		}
	}
	
	if ( kills["allies"] > kills["axis"] )
		return "allies";
	else if ( kills["axis"] > kills["allies"] )
		return "axis";
	
	// same number of kills

	if ( deaths["allies"] < deaths["axis"] )
		return "allies";
	else if ( deaths["axis"] < deaths["allies"] )
		return "axis";
	
	// same number of deaths
	
	if ( randomint(2) == 0 )
		return "allies";
	return "axis";
}


rankedMatchUpdates( winner )
{
	if ( matchMakingGame() )
	{
		setXenonRanks();
		
		if ( hostIdledOut() )
		{
			level._hostForcedEnd = true;
			logString( "host idled out" );
			endLobby();
		}

		updateMatchBonusScores( winner );
	}

	updateWinLossStats( winner );
}


displayRoundEnd( winner, endReasonText )
{
	foreach ( player in level._players )
	{
		if ( isDefined( player.connectedPostGame ) || player.pers["team"] == "spectator" )
			continue;
		
		if( level._multiTeamBased )
			player thread maps\mp\gametypes\_hud_message::MTDM_outcomeNotify( winner, endReasonText );
		else if ( level._teamBased )
			player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, true, endReasonText );
		else
			player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );
	}

	if ( !wasLastRound() )
		level notify ( "round_win", winner );
	
	if ( wasLastRound() )
		roundEndWait( level._roundEndDelay, false );
	else
		roundEndWait( level._roundEndDelay, true );	
}


displayGameEnd( winner, endReasonText )
{	
	// catching gametype, since DM forceEnd sends winner as player entity, instead of string
	foreach ( player in level._players )
	{
		if ( isDefined( player.connectedPostGame ) || player.pers["team"] == "spectator" )
			continue;
		
		if( level._multiTeamBased )
			player thread maps\mp\gametypes\_hud_message::MTDM_outcomeNotify( winner, endReasonText );
		else if ( level._teamBased )
			player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, false, endReasonText );
		else
			player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );
	}
	
	level notify ( "game_win", winner );
	
	bbPrint( "session_epilogs: reason %s", endReasonText );

	roundEndWait( level._postRoundTime, true );
}


displayRoundSwitch()
{
	switchType = level._halftimeType;
	if ( switchType == "halftime" )
	{
		if ( getWatchedDvar( "roundlimit" ) )
		{
			if ( (game["roundsPlayed"] * 2) == getWatchedDvar( "roundlimit" ) )
				switchType = "halftime";
			else
				switchType = "intermission";
		}
		else if ( getWatchedDvar( "winlimit" ) )
		{
			if ( game["roundsPlayed"] == (getWatchedDvar( "winlimit" ) - 1) )
				switchType = "halftime";
			else
				switchType = "intermission";
		}
		else
		{
			switchType = "intermission";
		}
	}

	level notify ( "round_switch", switchType );

	foreach ( player in level._players )
	{
		if ( isDefined( player.connectedPostGame ) || player.pers["team"] == "spectator" )
			continue;
		
		player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( switchType, true, level._halftimeSubCaption );
	}
	
	roundEndWait( level._halftimeRoundEndDelay, false );
}


endGameOvertime( winner, endReasonText )
{
	// freeze players
	foreach ( player in level._players )
	{
		player thread freezePlayerForRoundEnd( 0 );
		player thread roundEndDoF( 4.0 );
		
		player freeGameplayHudElems();

		player setClientDvars( "cg_everyoneHearsEveryone", 1 );
		player setClientDvars( "cg_drawSpectatorMessages", 0,
							   "g_compassShowEnemies", 0 );
							   
		if ( player.pers["team"] == "spectator" )
			player thread maps\mp\gametypes\_playerlogic::spawnIntermission();
	}

	level notify ( "round_switch", "overtime" );

	// catching gametype, since DM forceEnd sends winner as player entity, instead of string
	foreach ( player in level._players )
	{
		if ( isDefined( player.connectedPostGame ) || player.pers["team"] == "spectator" )
			continue;
		
		if( level._multiTeamBased )
			player thread maps\mp\gametypes\_hud_message::MTDM_outcomeNotify( winner, endReasonText );
		else if ( level._teamBased )
			player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, false, endReasonText );
		else
			player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );
	}
	
	roundEndWait( level._roundEndDelay, false );

	game["status"] = "overtime";
	level notify ( "restarting" );
    game["state"] = "playing";
    map_restart( true );
}



endGameHalfTime()
{
	visionSetNaked( "mpOutro", 0.5 );		
	setDvar( "scr_gameended", 2 );

	game["switchedsides"] = !game["switchedsides"];

	// freeze players
	foreach ( player in level._players )
	{
		player thread freezePlayerForRoundEnd( 0 );
		player thread roundEndDoF( 4.0 );
		
		player freeGameplayHudElems();

		player setClientDvars( "cg_everyoneHearsEveryone", 1 );
		player setClientDvars( "cg_drawSpectatorMessages", 0,
							   "g_compassShowEnemies", 0 );
							   
		if ( player.pers["team"] == "spectator" )
			player thread maps\mp\gametypes\_playerlogic::spawnIntermission();
	}

	foreach ( player in level._players )
		player.pers["stats"] = player.stats;

	level notify ( "round_switch", "halftime" );
		
	foreach ( player in level._players )
	{
		if ( isDefined( player.connectedPostGame ) || player.pers["team"] == "spectator" )
			continue;

		player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( "halftime", true, level._halftimeSubCaption );
	}
	
	roundEndWait( level._roundEndDelay, false );

	game["status"] = "halftime";
	level notify ( "restarting" );
    game["state"] = "playing";
    map_restart( true );
}


endGame( winner, endReasonText, nukeDetonated )
{
	if ( !isDefined(nukeDetonated) )
		nukeDetonated = false;
	
	// return if already ending via host quit or victory, or nuke incoming
	if ( game["state"] == "postgame" || level._gameEnded || (isDefined(level._nukeIncoming) && !nukeDetonated) && ( !isDefined( level._gtnw ) || !level._gtnw ) )
		return;

	game["state"] = "postgame";

	level._gameEndTime = getTime();
	level._gameEnded = true;
	level._inGracePeriod = false;
	level notify ( "game_ended", winner );
	levelFlagSet( "game_over" );
	levelFlagSet( "block_notifies" );
	waitframe(); // give "game_ended" notifies time to process
	
	setGameEndTime( 0 ); // stop/hide the timers
	
	maps\mp\gametypes\_playerlogic::printPredictedSpawnpointCorrectness();
	
	if ( isDefined( winner ) && isString( winner ) && winner == "overtime" )
	{
		endGameOvertime( winner, endReasonText );
		return;
	}
	
	if ( isDefined( winner ) && isString( winner ) && winner == "halftime" )
	{
		endGameHalftime();
		return;
	}

	game["roundsPlayed"]++;
	
	if ( level._teamBased )
	{
		if ( winner == "axis" || winner == "allies" )
			game["roundsWon"][winner]++;

		maps\mp\gametypes\_gamescore::updateTeamScore( "axis" );
		maps\mp\gametypes\_gamescore::updateTeamScore( "allies" );
	}
	else
	{
		if ( isDefined( winner ) && isPlayer( winner ) )
			game["roundsWon"][winner.guid]++;
	}
	
	maps\mp\gametypes\_gamescore::updatePlacement();

	rankedMatchUpdates( winner );

	foreach ( player in level._players )
	{
		player setClientDvar( "ui_opensummary", 1 );
	}
	
	setDvar( "g_deadChat", 1 );
	setDvar( "ui_allow_teamchange", 0 );

	// freeze players
	foreach ( player in level._players )
	{
		player thread freezePlayerForRoundEnd( 1.0 );
		player thread roundEndDoF( 4.0 );
		
		player freeGameplayHudElems();

		player setClientDvars( "cg_everyoneHearsEveryone", 1 );
		player setClientDvars( "cg_drawSpectatorMessages", 0,
							   "g_compassShowEnemies", 0,
							   "cg_fovScale", 1 );
							   
		if ( player.pers["team"] == "spectator" )
			player thread maps\mp\gametypes\_playerlogic::spawnIntermission();
	}

	if( !nukeDetonated )
		visionSetNaked( "mpOutro", 0.5 );		
	
	// End of Round
	if ( !wasOnlyRound() && !nukeDetonated )
	{
		setDvar( "scr_gameended", 2 );
	
		displayRoundEnd( winner, endReasonText );

		if ( level._showingFinalKillcam )
		{
			foreach ( player in level._players )
				player notify ( "reset_outcome" );

			level notify ( "game_cleanup" );

			waittillFinalKillcamDone();
		}
				
		if ( !wasLastRound() )
		{
			levelFlagClear( "block_notifies" );
			if ( checkRoundSwitch() )
				displayRoundSwitch();

			foreach ( player in level._players )
				player.pers["stats"] = player.stats;

        	level notify ( "restarting" );
            game["state"] = "playing";
            map_restart( true );
            return;
		}
		
		if ( !level._forcedEnd )
			endReasonText = updateEndReasonText( winner );
	}

	setDvar( "scr_gameended", 1 );
	
	if ( !isDefined( game["clientMatchDataDef"] ) )
	{
		game["clientMatchDataDef"] = "mp/clientmatchdata.def";
		setClientMatchDataDef( game["clientMatchDataDef"] );
	}

	maps\mp\gametypes\_missions::roundEnd( winner );

	displayGameEnd( winner, endReasonText );

	if ( level._showingFinalKillcam && wasOnlyRound() )
	{
		foreach ( player in level._players )
			player notify ( "reset_outcome" );

		level notify ( "game_cleanup" );

		waittillFinalKillcamDone();
	}				

	levelFlagClear( "block_notifies" );

	level._intermission = true;

	level notify ( "spawning_intermission" );
	
	foreach ( player in level._players )
	{
		player closepopupMenu();
		player closeInGameMenu();
		player notify ( "reset_outcome" );
		player thread maps\mp\gametypes\_playerlogic::spawnIntermission();
	}

	processLobbyData();
	
	wait ( 1.0 );

	if ( matchMakingGame() )
		sendMatchData();

	foreach ( player in level._players )
		player.pers["stats"] = player.stats;

	dump_score_board_to_black_box();
	
	maps\mp\gametypes\_weapons::weapon_stats_dump_to_black_box();

	//logString( "game ended" );
	if( !nukeDetonated && !level._postGameNotifies )
	{
		if ( !wasOnlyRound() )
			wait 6.0;
		else
			wait 3.0;
	}
	else
	{
		wait ( min( 10.0, 4.0 + level._postGameNotifies ) );
	}
	
	level notify( "exitLevel_called" );
	exitLevel( false );
}

updateEndReasonText( winner )
{
	if ( !level._teamBased )
		return true;

	if ( hitRoundLimit() )
		return &"MP_ROUND_LIMIT_REACHED";
	
	if ( hitWinLimit() )
		return &"MP_SCORE_LIMIT_REACHED";
	
	if ( winner == "axis" )
		return &"SPETSNAZ_WIN";
	else
		return &"SAS_WIN";
}

estimatedTimeTillScoreLimit( team )
{
	assert( isPlayer( self ) || isDefined( team ) );

	scorePerMinute = getScorePerMinute( team );
	scoreRemaining = getScoreRemaining( team );

	estimatedTimeLeft = 999999;
	if ( scorePerMinute )
		estimatedTimeLeft = scoreRemaining / scorePerMinute;
	
	//println( "estimatedTimeLeft: " + estimatedTimeLeft );
	return estimatedTimeLeft;
}

getScorePerMinute( team )
{
	assert( isPlayer( self ) || isDefined( team ) );

	scoreLimit = getWatchedDvar( "scorelimit" );
	timeLimit = getTimeLimit();
	minutesPassed = (getTimePassed() / (60*1000)) + 0.0001;

	if ( isPlayer( self ) )
		scorePerMinute = self.score / minutesPassed;
	else
		scorePerMinute = getTeamScore( team ) / minutesPassed;
		
	return scorePerMinute;
}

getScoreRemaining( team )
{
	assert( isPlayer( self ) || isDefined( team ) );

	scoreLimit = getWatchedDvar( "scorelimit" );

	if ( isPlayer( self ) )
		scoreRemaining = scoreLimit - self.score;
	else
		scoreRemaining = scoreLimit - getTeamScore( team );
		
	return scoreRemaining;
}

giveLastOnTeamWarning()
{
	self endon("death");
	self endon("disconnect");
	level endon( "game_ended" );

	self waitTillRecoveredHealth( 3 );

	
	thread teamPlayerCardSplash( "callout_lastteammemberalive", self, self.pers["team"] );
	
	//tagZP<TODO> may want to fix this in the future, would require adding team specific splash text.
	if( !level._multiTeamBased )
	{
		otherTeam = getOtherTeam( self.pers["team"] );
		thread teamPlayerCardSplash( "callout_lastenemyalive", self, otherTeam );
	}
	
	level notify ( "last_alive", self );
}

processLobbyData()
{
	curPlayer = 0;
	foreach ( player in level._players )
	{
		if ( !isDefined( player ) )
			continue;

		player.clientMatchDataId = curPlayer;
		curPlayer++;

		// on PS3 cap long names
		if ( level._ps3 && (player.name.size > level._MaxNameLength) )
		{
			playerName = "";
			for ( i = 0; i < level._MaxNameLength-3; i++ )
				playerName += player.name[i];

			playerName += "...";
		}
		else
		{
			playerName = player.name;
		}
		
		setClientMatchData( "players", player.clientMatchDataId, "xuid", playerName );		
	}
	
	maps\mp\_awards::assignAwards();
	maps\mp\_scoreboard::processLobbyScoreboards();
	
	maps\mp\_fantasyStats::processFantasyStats();
	
	sendClientMatchData();
}

dump_score_board_to_black_box_for_player_bailed_early()
{
	if ( !level._gameEnded )
	{
		if( isDefined( self.usingOnlineDataOffline ))
		{
			if( self rankingEnabled() )
			{
				dump_score_board_to_black_box_for_player( self, true );	// record a fail for this guy because they left too early
			}
		}
	}
}

dump_score_board_to_black_box_for_player(player, force_to_lose)
{
	playername = player.name;
	xuid = player GetXuid();
	
	// defaults
	win = 0;
	loss = 0;
	tie = 0;
	score = 0;
	kills = 0;
	assists = 0;
	deaths = 0;
	betrayals = 0;
	destroyedobjects = 0;
	killstreakusedcount = 0;
	longestkillstreak = 0;
	highestmultikill = 0;
	numtimesmultikill = 0;
	xpgain = 0;
	buzzkillcount = 0;
	longestlife = 0;
	
	if( force_to_lose )
	{
	    loss = 1;
	}
	else
	{
		winner = "";
		teambasedgame = 0;
		if ( level._teamBased )
		{
			teambasedgame = 1;
			alliesScore = getTeamScore( "allies" );
			axisScore = getTeamScore( "axis" );
		
			if ( alliesScore == axisScore )
			{
				winner = "tied";
			}
			else if ( alliesScore > axisScore )
			{
				winner = "allies";
			}
			else
			{
				winner = "axis";
			}
		}
		else
		{
			winner = maps\mp\gametypes\_gamescore::getHighestScoringPlayer();
		}
			
		//statversion = GetPersistentDataDefVersion();
		//statformatchecksum = GetPersistentDataDefFormatChecksum();
			
		//println( "mptestratings: WINNER = '" + winner + "'" );
		//bbPrint( "breakpoint: " );

		//	create table mptestratings
		//	(
		//		mptestratingsid bigint(20) unsigned not null AUTO_INCREMENT PRIMARY KEY,
		//		sessionid bigint(20) unsigned not null default 0,
		//		time float unsigned not null default 0.0,
		//	
		//		playername varchar(32) not null default "",
		//		xuid bigint(20) unsigned not null default 0,
		//		win int unsigned not null default 0,
		//		loss int unsigned not null default 0,
		//		tie int unsigned not null default 0,
		//		score int unsigned not null default 0,
		//		kills int unsigned not null default 0,
		//		assists int unsigned not null default 0,
		//		deaths int unsigned not null default 0,
		//		betrayals int unsigned not null default 0,
		//		destroyedobjects int unsigned not null default 0
		//	)

		faction = game[player.pers["team"]];
		team = player.team;
		//println( "mptestratings: FACTION = " + faction + ", TEAM = " + team + " " );	// faction is stuff like "socom_141_arctic", etc

		if ( level._teamBased )
		{
			if ( winner == "tied" )
			{
				tie = 1;
			}
			else if( team == winner )
			{
				win = 1;
			}
			else
			{
				loss = 1;
			}
		}
		else
		{
			if ( isDefined( winner ) )
			{
				if( player == winner )
				{
					win = 1;
				}
				else
				{
					loss = 1;
				}
			}
			else
			{
				// no winner, therefore it's a tie
				tie = 1;
			}
		}

		if ( isDefined( player.pers["score"] ) )
		{
			score = player.pers["score"];
		}
		kills = player getPlayerStat( "kills" );
		assists = player getPlayerStat( "assists" );
		deaths = player getPlayerStat( "deaths" );
		
		killstreakusedcount = maps\mp\killstreaks\_killstreaks::killstreak_stats_get_use_count( player );

		if( IsDefined( player.pers[ "longestStreak" ] ) )
		{
			longestkillstreak = player.pers[ "longestStreak" ];
		}
		//println( "mptestratings: playername='" + playername + "', killstreakusedcount = " + killstreakusedcount + ", longestkillstreak = " + longestkillstreak + " " );	
		//bbPrint( "breakpoint: " );

		highestmultikill = player getPlayerStat( "multikill" );
		numtimesmultikill = player getPlayerStat( "mostmultikills" );

		//println( "mptestratings: playername='" + playername + "', highestmultikill=" + highestmultikill + ", numtimesmultikill=" + numtimesmultikill + "\n" );	
		//bbPrint( "breakpoint: " );

		xpgain = player maps\mp\gametypes\_rank::getRankXP() - player maps\mp\gametypes\_rank::getRankXPStart();

		//println( "mptestratings: playername='" + playername + "', xpgain=" + xpgain + "\n" );	
		//bbPrint( "breakpoint: " );  

		//println( "mptestratings: playername='" + playername + "', xuid=" + xuid + ", win=" + win + ", loss=" + loss + ", tie=" + tie + ", score=" + score + ", kills=" + kills + ", assists=" + assists + ", deaths=" + deaths + ", betrayals=" + betrayals + ", destroyedobjects=" + destroyedobjects + ", killstreakusedcount=" + killstreakusedcount + ", longestkillstreak = " + longestkillstreak + "\n" );	
		//bbPrint( "breakpoint: " );

		buzzkillcount = player.buzzkillcount;

		longestlife = player getPlayerStat( "longestlife" );
		if( !IsDefined( longestlife ) )
		{
			longestlife = 0;
		}
	}
	
	// IMPORTANT!  XUID will be a string containing a HEX value of a uint64 number.  Below we are attempting to write out this string as a %llu. 
	// I updated the bbPrint() function to support this very special case.  EM 11/8/2010
	bbPrint( "mptestratings: playername %s xuid %llu win %u loss %u tie %u score %u kills %u assists %u deaths %u betrayals %u destroyedobjects %u killstreakusedcount %u longestkillstreak %u highestmultikill %u numtimesmultikill %u xpgain %u buzzkillcount %u longestlife %u ",
		playername, xuid, win, loss, tie, score, kills, assists, deaths, betrayals, destroyedobjects, killstreakusedcount, longestkillstreak, highestmultikill, numtimesmultikill, xpgain, buzzkillcount, longestlife );
}

dump_score_board_to_black_box()
{
	foreach ( player in level._placement["all"] )
	{
		dump_score_board_to_black_box_for_player( player, false );
	}
	foreach ( player2 in level._placement["all"] )
	{
		maps\mp\killstreaks\_killstreaks::killstreak_stats_dump_stats_to_black_box( player2 );
	}
	
	//bbPrint( "breakpoint: " );
}