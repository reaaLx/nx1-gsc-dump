#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;



getHighestScoringPlayer()
{
	updatePlacement();
	
	if ( !level._placement["all"].size )
		return ( undefined );
	else 
		return ( level._placement["all"][0] );
}


getLosingPlayers()
{
	updatePlacement();
	
	players = level._placement["all"];
	losingPlayers = [];
	
	foreach ( player in players )
	{
		if ( player == level._placement["all"][0] )
			continue;
		
		losingPlayers[losingPlayers.size] = player;
	}

	return losingPlayers;
}


givePlayerScore( event, player, victim, overrideCheckPlayerScoreLimitSoon )
{
	if ( isDefined( level._nukeIncoming ) )
		return;
	
	score = player.pers["score"];
	onPlayerScore( event, player, victim );
	
	if ( score == player.pers["score"] )
		return;

	if ( !player rankingEnabled() && !level._hardcoreMode )
		player thread maps\mp\gametypes\_rank::scorePopup( (player.pers["score"] - score), false, (0.85,0.85,0.85), 0 );
	
	player maps\mp\gametypes\_persistence::statAdd( "score", (player.pers["score"] - score) );

	if( getDvarInt( "prototype_adrenaline_enabled" ) == 1 )
	{
		player maps\mp\_adrenaline::adrenalineAddScore( (player.pers["score"] - score) );
	}
	
	player.score = player.pers["score"];
	player maps\mp\gametypes\_persistence::statSetChild( "round", "score", player.score );
	
	if ( !level._teambased )
		thread sendUpdatedDMScores();
	
	//	tagJC<NOTE>: In game mode where winning is not dependent on players' or team's score, it is unnecessary to check whether 
	//               the score limit will be reached soon.
	if ( !isDefined( overrideCheckPlayerScoreLimitSoon ) || !overrideCheckPlayerScoreLimitSoon )
		player maps\mp\gametypes\_gamelogic::checkPlayerScoreLimitSoon();

	scoreEndedMatch = player maps\mp\gametypes\_gamelogic::checkScoreLimit();
	
	if ( scoreEndedMatch && event == "kill" )
		player.finalKill = true;
}


onPlayerScore( event, player, victim )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( event );
	
	assert( isDefined( score ) );
	
	player.pers["score"] += score * level._objectivePointsMod;
}


// Seems to only be used for reducing a player's score due to suicide
_setPlayerScore( player, score )
{
	if ( score == player.pers["score"] )
		return;

	player.pers["score"] = score;
	player.score = player.pers["score"];

	player thread maps\mp\gametypes\_gamelogic::checkScoreLimit();
}


_getPlayerScore( player )
{
	return player.pers["score"];
}


giveTeamScoreForObjective( team, score )
{
	if ( isDefined( level._nukeIncoming ) )
		return;

	score *= level._objectivePointsMod;
	
	teamScore = game["teamScores"][team];
	
	/*
	otherTeam = level._otherTeam[team];
	if ( game["teamScores"][team] > game["teamScores"][otherTeam] )
		level._wasWinning = team;
	else if ( game["teamScores"][otherTeam] > game["teamScores"][team] )
		level._wasWinning = otherTeam;
	*/
	
	level._wasWinning = getWinningTeam();
		
	_setTeamScore( team, _getTeamScore( team ) + score );

	isWinning = getWinningTeam();
	/*
	isWinning = "none";
	if ( game["teamScores"][team] > game["teamScores"][otherTeam] )
		isWinning = team;
	else if ( game["teamScores"][otherTeam] > game["teamScores"][team] )
		isWinning = otherTeam;
	*/

	if ( !level._splitScreen && isWinning != "none" && isWinning != level._wasWinning && getTime() - level._lastStatusTime  > 5000 && getScoreLimit() != 1 )
	{
		level._lastStatusTime = getTime();
		leaderDialog( "lead_taken", isWinning, "status" );
		if ( level._wasWinning != "none")
			leaderDialog( "lead_lost", level._wasWinning, "status" );
	}

	if ( isWinning != "none" )
		level._wasWinning = isWinning;
}


getWinningTeam()
{
	//if( level._multiTeamBased == true )
	//{
		winning_team = level._teamNameList[0];
		winning_score = game["teamScores"][level._teamNameList[0]];
		num_teams_tied_for_winning = 1;
		for( i = 1; i < level._teamNameList.size; i++ )
		{
			if( game["teamScores"][level._teamNameList[i]] > winning_score )
			{
				//new winning team found
				winning_team = level._teamNameList[i];
				winning_score = game["teamScores"][level._teamNameList[i]];
				num_teams_tied_for_winning = 1;
			}
			else if( game["teamScores"][level._teamNameList[i]] == winning_score )
			{
				num_teams_tied_for_winning = num_teams_tied_for_winning + 1;
				winning_team = "none";
			}
		}
		return( winning_team );
	//}
	/*
	
	if ( game["teamScores"]["allies"] > game["teamScores"]["axis"] )
		return ( "allies" );
	else if ( game["teamScores"]["allies"] < game["teamScores"]["axis"] )
		return ( "axis" );
	*/	
	return ( "none" );
}

_setTeamScore( team, teamScore )
{
	if ( teamScore == game["teamScores"][team] )
		return;

	if ( isDefined( level._nukeIncoming ) )
		return;

	game["teamScores"][team] = teamScore;
	
	updateTeamScore( team );
	
	if ( game["status"] == "overtime" )
		thread [[level._onScoreLimit]]();
	else
	{
		thread maps\mp\gametypes\_gamelogic::checkTeamScoreLimitSoon( team );
		thread maps\mp\gametypes\_gamelogic::checkScoreLimit();
	}
}


updateTeamScore( team )
{
	assert( level._teamBased );
	
	teamScore = 0;
	if ( !isRoundBased() || !isObjectiveBased() )
		teamScore = _getTeamScore( team );
	else
		teamScore = game["roundsWon"][team];
	
 	setTeamScore( team, teamScore );
 	
	//thread sendUpdatedTeamScores();
}


_getTeamScore( team )
{
	return game["teamScores"][team];
}


sendUpdatedTeamScores()
{
	level notify("updating_scores");
	level endon("updating_scores");
	wait .05;
	
	WaitTillSlowProcessAllowed();

	foreach ( player in level._players )
		player updateScores();
}

sendUpdatedDMScores()
{
	level notify("updating_dm_scores");
	level endon("updating_dm_scores");
	wait .05;
	
	WaitTillSlowProcessAllowed();
	
	for ( i = 0; i < level._players.size; i++ )
	{
		level._players[i] updateDMScores();
		level._players[i].updatedDMScores = true;
	}
}


removeDisconnectedPlayerFromPlacement()
{
	offset = 0;
	numPlayers = level._placement["all"].size;
	found = false;
	for ( i = 0; i < numPlayers; i++ )
	{
		if ( level._placement["all"][i] == self )
			found = true;
		
		if ( found )
			level._placement["all"][i] = level._placement["all"][ i + 1 ];
	}
	if ( !found )
		return;
	
	level._placement["all"][ numPlayers - 1 ] = undefined;
	assert( level._placement["all"].size == numPlayers - 1 );

	if( level._multiTeamBased )
	{
		MTDM_updateTeamPlacement();
	}
	else if ( level._teamBased )
	{
		updateTeamPlacement();
		return;
	}
		
	numPlayers = level._placement["all"].size;
	for ( i = 0; i < numPlayers; i++ )
	{
		player = level._placement["all"][i];
		player notify( "update_outcome" );
	}
	
}

updatePlacement()
{
	prof_begin("updatePlacement");
	
	placementAll = [];
	foreach ( player in level._players )
	{
		if ( isDefined( player.connectedPostGame ))
		{
			continue;
		}
			
		if( player.pers["team"] == "spectator" )
		{
			continue;
		}
		
		if( player.pers["team"] == "none" )
		{
			continue;
		}
			
		placementAll[placementAll.size] = player;
	}
	
	for ( i = 1; i < placementAll.size; i++ )
	{
		player = placementAll[i];
		playerScore = player.score;
//		for ( j = i - 1; j >= 0 && (player.score > placementAll[j].score || (player.score == placementAll[j].score && player.deaths < placementAll[j].deaths)); j-- )
		for ( j = i - 1; j >= 0 && getBetterPlayer( player, placementAll[j] ) == player; j-- )
			placementAll[j + 1] = placementAll[j];
		placementAll[j + 1] = player;
	}
	
	level._placement["all"] = placementAll;
	
	if( level._multiTeamBased )
	{
		MTDM_updateTeamPlacement();
	}
	else if ( level._teamBased )
	{
		updateTeamPlacement();
	}

	prof_end("updatePlacement");
}


getBetterPlayer( playerA, playerB )
{
	if ( playerA.score > playerB.score )
		return playerA;
		
	if ( playerB.score > playerA.score )
		return playerB;
		
	if ( playerA.deaths < playerB.deaths )
		return playerA;
		
	if ( playerB.deaths < playerA.deaths )
		return playerB;
		
	// TODO: more metrics for getting the better player
		
	if ( cointoss() )
		return playerA;
	else
		return playerB;
}


updateTeamPlacement()
{
	placement["allies"]    = [];
	placement["axis"]      = [];
	placement["spectator"] = [];

	assert( level._teamBased );
	
	placementAll = level._placement["all"];
	placementAllSize = placementAll.size;
	
	for ( i = 0; i < placementAllSize; i++ )
	{
		player = placementAll[i];
		team = player.pers["team"];
		
		placement[team][ placement[team].size ] = player;
	}
	
	level._placement["allies"] = placement["allies"];
	level._placement["axis"]   = placement["axis"];
}

//TagZP<TODO> consolidate with updateTeamPlacement()
MTDM_updateTeamPlacement()
{
	placement["spectator"] = [];
	
	foreach( teamname in level._teamNameList )
	{
		placement[teamname] = [];
	}
	
	assert( level._multiTeamBased );
	
	placementAll = level._placement["all"];
	placementAllSize = placementAll.size;
	
	for ( i = 0; i < placementAllSize; i++ )
	{
		player = placementAll[i];
		team = player.pers["team"];
		
		placement[team][ placement[team].size ] = player;
	}
	
	foreach( teamname in level._teamNameList )
	{
		level._placement[teamname] = placement[teamname];
	}
}


initialDMScoreUpdate()
{
	// the first time we call updateDMScores on a player, we have to send them the whole scoreboard.
	// by calling updateDMScores on each player one at a time,
	// we can avoid having to send the entire scoreboard to every single player
	// the first time someone kills someone else.
	wait .2;
	numSent = 0;
	while(1)
	{
		didAny = false;
		
		players = level._players;
		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];
			
			if ( !isdefined( player ) )
				continue;
			
			if ( isdefined( player.updatedDMScores ) )
				continue;
			
			player.updatedDMScores = true;
			player updateDMScores();
			
			didAny = true;
			wait .5;
		}
		
		if ( !didAny )
			wait 3; // let more players connect
	}
}


processAssist( killedplayer )
{
	self endon("disconnect");
	killedplayer endon("disconnect");
	
	wait .05; // don't ever run on the same frame as the playerkilled callback.
	WaitTillSlowProcessAllowed();
	if( !level._multiteambased )
	{
		if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" )
		{
			return;
		}
	}
	
	if ( self.pers["team"] == killedplayer.pers["team"] )
		return;
	
	damagedone = killedplayer.attackerData[self.guid].damage;

	// If the attacker has conducted some damages using any grenades with lasting effect, the player should receive a minimum reward that is not porpotional to the damages done
	playerMaxHealth = getDvarInt ( "scr_player_maxhealth" );
	//Assuming there are four levels for assist rewards, divide player's max health by 4 to get the amount of damage per assist level
	damagePerAssistLevel = playerMaxHealth / 4; 
	if ( isDefined ( killedplayer.attackerData[self.guid].isGrenadeWithLastingEffect ) && killedplayer.attackerData[self.guid].isGrenadeWithLastingEffect == true )
	{
		if ( damagedone <= 50 )
		{
			assist_event = "assist_grenade";
		}
		else
		{
			assist_event = "assist_level_" + int( ceil( damagedone / damagePerAssistLevel ) );
		}
	}
	else
	{
		assist_event = "assist_level_" + int( ceil( damagedone / damagePerAssistLevel ) );
	}
	self thread [[level._onXPEvent]]( assist_event );
	self incPersStat( "assists", 1 );
	self.assists = self getPersStat( "assists" );
	self incPlayerStat( "assists", 1 );
	
	givePlayerScore( assist_event, self, killedplayer );
	self thread giveAdrenaline( "assist" );
	
	self thread maps\mp\gametypes\_missions::playerAssist();
}

processShieldAssist( killedPlayer )
{
	self endon( "disconnect" );
	killedPlayer endon( "disconnect" );
	
	wait .05; // don't ever run on the same frame as the playerkilled callback.
	WaitTillSlowProcessAllowed();
	
	if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" )
		return;
	
	if ( self.pers["team"] == killedplayer.pers["team"] )
		return;
	
	self thread [[level._onXPEvent]]( "assist" );
	self thread [[level._onXPEvent]]( "assist" );
	self incPersStat( "assists", 1 );
	self.assists = self getPersStat( "assists" );
	self incPlayerStat( "assists", 1 );
	
	givePlayerScore( "assist", self, killedplayer );

	self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "shield_assist" );		
	
	self thread maps\mp\gametypes\_missions::playerAssist();
}