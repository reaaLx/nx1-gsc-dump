#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
/*
	Domination
	Objective: 	Capture all the flags by touching them
	Map ends:	When one team captures all the flags, or time limit is reached
	Respawning:	No wait / Near teammates

	Level requirements
	------------------
		Spawnpoints:
			classname		mp_tdm_spawn
			All players spawn from these. The spawnpoint chosen is dependent on the current locations of owned flags, teammates and 
			enemies at the time of spawn. Players generally spawn behind their teammates relative to the direction of enemies.
			Optionally, give a spawnpoint a script_linkto to specify which flag it "belongs" to (see Flag Descriptors).

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.

		Flags:
			classname       trigger_radius
			targetname      flag_primary or flag_secondary
			Flags that need to be captured to win. Primary flags take time to capture; secondary flags are instant.
		
		Flag Descriptors:
			classname       script_origin
			targetname      flag_descriptor
			Place one flag descriptor close to each flag. Use the script_linkname and script_linkto properties to say which flags
			it can be considered "adjacent" to in the level. For instance, if players have a primary path from flag1 to flag2, and 
			from flag2 to flag3, flag2 would have a flag_descriptor with these properties:
			script_linkname flag2
			script_linkto flag1 flag3
			
			Set scr_domdebug to 1 to see flag connections and what spawnpoints are considered connected to each flag.
*/

/*QUAKED mp_dom_spawn (0.5 0.5 1.0) (-16 -16 0) (16 16 72)
Players spawn near their flags at one of these positions.*/

/*QUAKED mp_dom_spawn_axis_start (1.0 0.0 1.0) (-16 -16 0) (16 16 72)
Axis players spawn away from enemies and near their team at one of these positions at the start of a round.*/

/*QUAKED mp_dom_spawn_allies_start (0.0 1.0 1.0) (-16 -16 0) (16 16 72)
Allied players spawn away from enemies and near their team at one of these positions at the start of a round.*/

main()
{
	if(getdvar("mapname") == "mp_background")
		return;

	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	registerTimeLimitDvar( level._gameType, 30, 0, 1440 );
	registerScoreLimitDvar( level._gameType, 300, 0, 1000 );
	registerRoundLimitDvar( level._gameType, 1, 0, 10 );
	registerWinLimitDvar( level._gameType, 1, 0, 10 );
	registerNumLivesDvar( level._gameType, 0, 0, 10 );
	registerHalfTimeDvar( level._gameType, 0, 0, 1 );
	registerNumLivesDvar( level._gameType, 1, 0, 5 );

	level._teamBased = true;
	level._onStartGameType = ::onStartGameType;
	level._getSpawnPoint = ::getSpawnPoint;
	level._onPrecacheGameType = ::onPrecacheGameType;
	level._onSpawnPlayer = ::onSpawnPlayer;
	level._onNormalDeath = ::onNormalDeath;
	level._onDeadEvent = ::onDeadEvent;
	
	game["dialog"]["gametype"] = "domination";

	if ( getDvarInt( "g_hardcore" ) )
		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "camera_thirdPerson" ) )
		game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "scr_diehard" ) )
		game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
	else if (getDvarInt( "scr_" + level._gameType + "_promode" ) )
		game["dialog"]["gametype"] = game["dialog"]["gametype"] + "_pro";

	game["dialog"]["offense_obj"] = "capture_objs";
	game["dialog"]["defense_obj"] = "capture_objs";
}


onPrecacheGameType()
{
	precacheShader( "waypoint_captureneutral" );
	precacheShader( "waypoint_capture" );
	precacheShader( "waypoint_defend" );
	precacheShader( "waypoint_captureneutral_a" );
	precacheShader( "waypoint_capture_a" );
	precacheShader( "waypoint_defend_a" );
	precacheShader( "waypoint_captureneutral_b" );
	precacheShader( "waypoint_capture_b" );
	precacheShader( "waypoint_defend_b" );
	precacheShader( "waypoint_captureneutral_c" );
	precacheShader( "waypoint_capture_c" );
	precacheShader( "waypoint_defend_c" );

	precacheShader( "waypoint_captureneutral" );
	precacheShader( "waypoint_capture" );
	precacheShader( "waypoint_defend" );
	precacheShader( "waypoint_captureneutral_a" );
	precacheShader( "waypoint_capture_a" );
	precacheShader( "waypoint_defend_a" );
	precacheShader( "waypoint_captureneutral_b" );
	precacheShader( "waypoint_capture_b" );
	precacheShader( "waypoint_defend_b" );
	precacheShader( "waypoint_captureneutral_c" );
	precacheShader( "waypoint_capture_c" );
	precacheShader( "waypoint_defend_c" );
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
	
	allowed[0] = "dom"; //level.gameType;
	allowed[1] = "airdrop_pallet";
	
	maps\mp\gametypes\_gameobjects::main(allowed);	
	
	level._flagBaseFXid[ "allies" ] = loadfx( maps\mp\gametypes\_teams::getTeamFlagFX( "allies" ) );
	level._flagBaseFXid[ "axis"   ] = loadfx( maps\mp\gametypes\_teams::getTeamFlagFX( "axis" ) );
			
	thread domFlags();
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

onNormalDeath( victim, attacker, lifeId )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
	assert( isDefined( score ) );

	attacker maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( attacker.pers["team"], score );
	
	if ( game["state"] == "postgame" && game["teamScores"][attacker.team] > game["teamScores"][level._otherTeam[attacker.team]] )
		attacker.finalKill = true;
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

onDeadEvent( team )
{
	total_lives = 0;
	foreach ( other_player in level._players )
	{
		if( other_player.pers["team"] == team )
		{
   			total_lives += other_player.pers["lives"];
		}
	}

	if( total_lives <= 0 )
	{
		if ( team == "allies" )
		{
			iPrintLn( game["strings"]["allies_eliminated"] );
	
			logString( "team eliminated, win: opfor, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
			
			thread maps\mp\gametypes\_gamelogic::endGame( "axis", game["strings"]["allies_eliminated"] );
		}
		else if ( team == "axis" )
		{
			iPrintLn( game["strings"]["axis_eliminated"] );
	
			logString( "team eliminated, win: allies, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
	
			thread maps\mp\gametypes\_gamelogic::endGame( "allies", game["strings"]["axis_eliminated"] );
		}
		else
		{
			logString( "tie, allies: " + game["teamScores"]["allies"] + ", opfor: " + game["teamScores"]["axis"] );
	
			if ( level._teamBased )
				thread maps\mp\gametypes\_gamelogic::endGame( "tie", game["strings"]["tie"] );
			else
				thread maps\mp\gametypes\_gamelogic::endGame( undefined, game["strings"]["tie"] );
		}
	}
}

domFlags()
{
	level._lastStatus["allies"] = 0;
	level._lastStatus["axis"] = 0;
	
	game["flagmodels"] = [];
	game["flagmodels"]["neutral"] = "prop_flag_neutral";

	game["flagmodels"]["allies"] = maps\mp\gametypes\_teams::getTeamFlagModel( "allies" );
	game["flagmodels"]["axis"] = maps\mp\gametypes\_teams::getTeamFlagModel( "axis" );

 	game["flagmodels"]["crate"] = "com_plasticcase_friendly";
	
	precacheModel( game["flagmodels"]["neutral"] );
	precacheModel( game["flagmodels"]["allies"] );
	precacheModel( game["flagmodels"]["axis"] );
	precacheModel( game["flagmodels"]["crate"] );

	precacheShader( "waypoint_ammo_friendly" );
	precacheShader( "compass_objpoint_ammo_friendly" );

	precacheString( &"MP_SECURING_POSITION" );	
	
	primaryFlags = getEntArray( "flag_primary", "targetname" );
	secondaryFlags = getEntArray( "flag_secondary", "targetname" );
	
	if ( (primaryFlags.size + secondaryFlags.size) < 2 )
	{
		printLn( "^1Not enough domination flags found in level!" );
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}
	
	level._flags = [];
	for ( index = 0; index < primaryFlags.size; index++ )
		level._flags[level._flags.size] = primaryFlags[index];
	
	for ( index = 0; index < secondaryFlags.size; index++ )
		level._flags[level._flags.size] = secondaryFlags[index];
	
	level._domFlags = [];
	for ( index = 0; index < level._flags.size; index++ )
	{
		trigger = level._flags[index];
		if ( isDefined( trigger.target ) )
		{
			visuals[0] = getEnt( trigger.target, "targetname" );
		}
		else
		{
			visuals[0] = spawn( "script_model", trigger.origin );
			visuals[0].angles = trigger.angles;
		}

		visuals[0] setModel( game["flagmodels"]["neutral"] );
		if( index == 2 )
		{
			visuals[0] setModel( game["flagmodels"]["crate"] );
		}

		domFlag = maps\mp\gametypes\_gameobjects::createUseObject( "neutral", trigger, visuals, (0,0,100) );
		domFlag maps\mp\gametypes\_gameobjects::allowUse( "any" );
		domFlag maps\mp\gametypes\_gameobjects::setUseTime( 10.0 );
		domFlag maps\mp\gametypes\_gameobjects::setUseText( &"MP_SECURING_POSITION" );
		label = domFlag maps\mp\gametypes\_gameobjects::getLabel();
		domFlag.label = label;
		printLn( "Flag Label: " + label );
		domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_defend" + label );
		domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend" + label );
		domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_captureneutral" + label );
		domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_captureneutral" + label );
		domFlag maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
		if( index == 2 )
		{
			domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "compass_objpoint_ammo_friendly" );
			domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_ammo_friendly" );

			domFlag.onUse = ::onUseMiddle;
			domFlag.onBeginUse = ::onBeginUse;
			domFlag.onUseUpdate = ::onUseUpdate;
			domFlag.onEndUse = ::onEndUse;
		}
		else
		{
			domFlag.onUse = ::onUse;
			domFlag.onBeginUse = ::onBeginUse;
			domFlag.onUseUpdate = ::onUseUpdate;
			domFlag.onEndUse = ::onEndUse;
		}	
		
		traceStart = visuals[0].origin + (0,0,32);
		traceEnd = visuals[0].origin + (0,0,-32);
		trace = bulletTrace( traceStart, traceEnd, false, undefined );
	
		upangles = vectorToAngles( trace["normal"] );
		domFlag.baseeffectforward = anglesToForward( upangles );
		domFlag.baseeffectright = anglesToRight( upangles );
		
		domFlag.baseeffectpos = trace["position"];
		
		// legacy spawn code support
		level._flags[index].useObj = domFlag;
		level._flags[index].adjflags = [];
		level._flags[index].nearbyspawns = [];
		
		domFlag.levelFlag = level._flags[index];
		
		level._domFlags[level._domFlags.size] = domFlag;
	}
	
	// level.bestSpawnFlag is used as a last resort when the enemy holds all flags.
//	level.bestSpawnFlag = [];
//	level.bestSpawnFlag[ "allies" ] = getUnownedFlagNearestStart( "allies", undefined );
//	level.bestSpawnFlag[ "axis" ] = getUnownedFlagNearestStart( "axis", level.bestSpawnFlag[ "allies" ] );
	
//	flagSetup();
	
}

getUnownedFlagNearestStart( team, excludeFlag )
{
	best = undefined;
	bestdistsq = undefined;
	for ( i = 0; i < level._flags.size; i++ )
	{
		flag = level._flags[i];
		
		if ( flag getFlagTeam() != "neutral" )
			continue;
		
		distsq = distanceSquared( flag.origin, level._startPos[team] );
		if ( (!isDefined( excludeFlag ) || flag != excludeFlag) && (!isdefined( best ) || distsq < bestdistsq) )
		{
			bestdistsq = distsq;
			best = flag;
		}
	}
	return best;
}

onBeginUse( player )
{
	ownerTeam = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
	self.didStatusNotify = false;

	if ( ownerTeam == "neutral" )
	{
		statusDialog( "securing"+self.label, player.pers["team"] );
		self.objPoints[player.pers["team"]] thread maps\mp\gametypes\_objpoints::startFlashing();
		return;
	}
		
	if ( ownerTeam == "allies" )
		otherTeam = "axis";
	else
		otherTeam = "allies";

	self.objPoints["allies"] thread maps\mp\gametypes\_objpoints::startFlashing();
	self.objPoints["axis"] thread maps\mp\gametypes\_objpoints::startFlashing();
}


onUseUpdate( team, progress, change )
{
	if ( progress > 0.05 && change && !self.didStatusNotify )
	{
		ownerTeam = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
		if ( ownerTeam == "neutral" )
		{
			statusDialog( "securing"+self.label, team );
		}
		else
		{
			statusDialog( "losing"+self.label, ownerTeam );
			statusDialog( "securing"+self.label, team );
		}

		self.didStatusNotify = true;
	}
}


statusDialog( dialog, team, forceDialog )
{
	time = getTime();
	
	if ( getTime() < level._lastStatus[team] + 5000 && (!isDefined( forceDialog ) || !forceDialog) )
		return;
		
	thread delayedLeaderDialog( dialog, team );
	level._lastStatus[team] = getTime();	
}


onEndUse( team, player, success )
{
	self.objPoints["allies"] thread maps\mp\gametypes\_objpoints::stopFlashing();
	self.objPoints["axis"] thread maps\mp\gametypes\_objpoints::stopFlashing();
}


resetFlagBaseEffect()
{
	if ( isdefined( self.baseeffect ) )
		self.baseeffect delete();
	
	team = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
	
	if ( team != "axis" && team != "allies" )
		return;
	
	fxid = level._flagBaseFXid[ team ];

	self.baseeffect = spawnFx( fxid, self.baseeffectpos, self.baseeffectforward, self.baseeffectright );
	triggerFx( self.baseeffect );
}

onUse( player )
{
	// return straight away if we are doing this too quickly
	// I think this is a side affect of allowing you to capture a flag that is owned by your team already...
	if( isDefined( self.captureTime ) && getTime() < self.captureTime + 3000 )
	{ 
   		return;
	}

	team = player.pers["team"];
	oldTeam = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
	label = self maps\mp\gametypes\_gameobjects::getLabel();

	player.pers["lives"] = player.pers["lives"] + 1;
	printLn( "Player " + player.name + "got another set of lives, teammates get 1 more! lives=" + player.pers["lives"] );
	
	println( "My Team Lives" );
	foreach ( other_player in level._players )
	{
		if( other_player.pers["team"] == player.pers["team"] )
		{
			println( other_player.name + " has " + other_player.pers["lives"] + " lives" );
   			other_player.pers["lives"] = other_player.pers["lives"] + 1;
			if( !isAlive( other_player ))
			{
				// if the player went from 0 lives (dead) to 1 life, then we should spawn them a new client
				if ( isValidClass( other_player.class ) )
				{
					println( "Now has " + other_player.pers["lives"] + " lives! Respawning" );
					other_player thread maps\mp\gametypes\_playerlogic::spawnClient();
				}
			}
		}
	} 
	
	//player logString( "flag captured: " + self.label );
	
	self.captureTime = getTime();
	
	self maps\mp\gametypes\_gameobjects::setOwnerTeam( team );
//	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_capture" + label );
//	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_capture" + label );
	self.visuals[0] setModel( game["flagmodels"][team] );
	
	self resetFlagBaseEffect();
	
	level._useStartSpawns = false;
	
	assert( team != "neutral" );
	
	if ( oldTeam == "neutral" )
	{
		otherTeam = getOtherTeam( team );
		thread printAndSoundOnEveryone( team, otherTeam, undefined, undefined, "mp_war_objective_taken", undefined, player );
		
		statusDialog( "secured"+self.label, team, true );
		statusDialog( "enemy_has"+self.label, otherTeam, true );
	}
	else
	{
		thread printAndSoundOnEveryone( team, oldTeam, undefined, undefined, "mp_war_objective_taken", "mp_war_objective_lost", player );
		
//		thread delayedLeaderDialogBothTeams( "obj_lost", oldTeam, "obj_taken", team );

		if ( getTeamFlagCount( team ) == level._flags.size )
		{
			statusDialog( "secure_all", team );
			statusDialog( "lost_all", oldTeam );
		}
		else
		{	
			statusDialog( "secured"+self.label, team, true );
			statusDialog( "lost"+self.label, oldTeam, true );
		}
		
		level._bestSpawnFlag[ oldTeam ] = self.levelFlag;
	}
	
	player notify( "objective", "captured" );
	self thread giveFlagCaptureXP( self.touchList[team] );
	self maps\mp\gametypes\_gameobjects::allowUse( "none" ); 
	wait( 10 );
	self maps\mp\gametypes\_gameobjects::setOwnerTeam( "neutral" );
	self maps\mp\gametypes\_gameobjects::allowUse( "any" );
	self.visuals[0] setModel( game["flagmodels"]["neutral"] );
}

onUseMiddle( player )
{
	team = player.pers["team"];
//	oldTeam = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
	label = self maps\mp\gametypes\_gameobjects::getLabel();

	
	//player logString( "flag captured: " + self.label );
	
	self.captureTime = getTime();
	
//	self maps\mp\gametypes\_gameobjects::setOwnerTeam( team );
//	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_capture" + label );
//	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_capture" + label );
//	self.visuals[0] setModel( game["flagmodels"][team] );
	
	self resetFlagBaseEffect();
	
	level._useStartSpawns = false;

	streakName = "precision_airstrike";
	if ( isDefined( level._killstreakFuncs[streakName] ) )
	{
		player maps\mp\killstreaks\_killstreaks::giveKillstreak( streakName );
	}
	
	
	otherTeam = getOtherTeam( team );
	thread printAndSoundOnEveryone( team, otherTeam, undefined, undefined, "mp_war_objective_taken", undefined, player );
	
	statusDialog( "secured"+self.label, team, true );
	statusDialog( "enemy_has"+self.label, otherTeam, true );
	
	player notify( "objective", "captured" );
	//self thread giveFlagCaptureXP( self.touchList[team] );
	self maps\mp\gametypes\_gameobjects::allowUse( "none" );
	self maps\mp\gametypes\_gameobjects::disableObject();

	self waitTillCanUse( 10 );
}

waitTillCanUse( time )
{
	wait( time );
	self maps\mp\gametypes\_gameobjects::allowUse( "any" );
	self maps\mp\gametypes\_gameobjects::enableObject();
}

giveFlagCaptureXP( touchList )
{
	level endon ( "game_ended" );
	
	players = getArrayKeys( touchList );
	for ( index = 0; index < players.size; index++ )
	{
		player = touchList[players[index]].player;
		player thread maps\mp\gametypes\_hud_message::SplashNotify( "capture", maps\mp\gametypes\_rank::getScoreInfoValue( "capture" ) );
		player thread updateCPM();
		player thread maps\mp\gametypes\_rank::giveRankXP( "capture", maps\mp\gametypes\_rank::getScoreInfoValue( "capture" ) * player getCapXPScale() );
		printLn( maps\mp\gametypes\_rank::getScoreInfoValue( "capture" ) * player getCapXPScale() );
		maps\mp\gametypes\_gamescore::givePlayerScore( "capture", player );
//    	player incPlayerStat( "pointscaptured", 1 );
	}
	
	player = self maps\mp\gametypes\_gameobjects::getEarliestClaimPlayer();

	level thread teamPlayerCardSplash( "callout_securedposition" + self.label, player );

	player thread maps\mp\_matchdata::logGameEvent( "capture", player.origin );	
}

delayedLeaderDialog( sound, team )
{
	level endon ( "game_ended" );
	wait .1;
	WaitTillSlowProcessAllowed();
	
	leaderDialog( sound, team );
}
delayedLeaderDialogBothTeams( sound1, team1, sound2, team2 )
{
	level endon ( "game_ended" );
	wait .1;
	WaitTillSlowProcessAllowed();
	
	leaderDialogBothTeams( sound1, team1, sound2, team2 );
}


getOwnedDomFlags()
{
	domFlags = [];
	foreach ( domFlag in level._domFlags )
	{
		if ( domFlag maps\mp\gametypes\_gameobjects::getOwnerTeam() != "neutral" && isDefined( domFlag.captureTime ) )
			domFlags[domFlags.size] = domFlag;
	}
	
	return domFlags;
}


getTeamFlagCount( team )
{
	score = 0;
	for (i = 0; i < level._flags.size; i++) 
	{
		if ( level._domFlags[i] maps\mp\gametypes\_gameobjects::getOwnerTeam() == team )
			score++;
	}	
	return score;
}

getFlagTeam()
{
	return self.useObj maps\mp\gametypes\_gameobjects::getOwnerTeam();
}

getBoundaryFlags()
{
	// get all flags which are adjacent to flags that aren't owned by the same team
	bflags = [];
	for (i = 0; i < level._flags.size; i++)
	{
		for (j = 0; j < level._flags[i].adjflags.size; j++)
		{
			if (level._flags[i].useObj maps\mp\gametypes\_gameobjects::getOwnerTeam() != level._flags[i].adjflags[j].useObj maps\mp\gametypes\_gameobjects::getOwnerTeam() )
			{
				bflags[bflags.size] = level._flags[i];
				break;
			}
		}
	}
	
	return bflags;
}

getBoundaryFlagSpawns(team)
{
	spawns = [];
	
	bflags = getBoundaryFlags();
	for (i = 0; i < bflags.size; i++)
	{
		if (isdefined(team) && bflags[i] getFlagTeam() != team)
			continue;
		
		for (j = 0; j < bflags[i].nearbyspawns.size; j++)
			spawns[spawns.size] = bflags[i].nearbyspawns[j];
	}
	
	return spawns;
}

getSpawnsBoundingFlag( avoidflag )
{
	spawns = [];

	for (i = 0; i < level._flags.size; i++)
	{
		flag = level._flags[i];
		if ( flag == avoidflag )
			continue;
		
		isbounding = false;
		for (j = 0; j < flag.adjflags.size; j++)
		{
			if ( flag.adjflags[j] == avoidflag )
			{
				isbounding = true;
				break;
			}
		}
		
		if ( !isbounding )
			continue;
		
		for (j = 0; j < flag.nearbyspawns.size; j++)
			spawns[spawns.size] = flag.nearbyspawns[j];
	}
	
	return spawns;
}

// gets an array of all spawnpoints which are near flags that are
// owned by the given team, or that are adjacent to flags owned by the given team.
getOwnedAndBoundingFlagSpawns(team)
{
	spawns = [];

	for (i = 0; i < level._flags.size; i++)
	{
		if ( level._flags[i] getFlagTeam() == team )
		{
			// add spawns near this flag
			for (s = 0; s < level._flags[i].nearbyspawns.size; s++)
				spawns[spawns.size] = level._flags[i].nearbyspawns[s];
		}
		else
		{
			for (j = 0; j < level._flags[i].adjflags.size; j++)
			{
				if ( level._flags[i].adjflags[j] getFlagTeam() == team )
				{
					// add spawns near this flag
					for (s = 0; s < level._flags[i].nearbyspawns.size; s++)
						spawns[spawns.size] = level._flags[i].nearbyspawns[s];
					break;
				}
			}
		}
	}
	
	return spawns;
}

// gets an array of all spawnpoints which are near flags that are
// owned by the given team
getOwnedFlagSpawns(team)
{
	spawns = [];

	for (i = 0; i < level._flags.size; i++)
	{
		if ( level._flags[i] getFlagTeam() == team )
		{
			// add spawns near this flag
			for (s = 0; s < level._flags[i].nearbyspawns.size; s++)
				spawns[spawns.size] = level._flags[i].nearbyspawns[s];
		}
	}
	
	return spawns;
}

flagSetup()
{
	maperrors = [];
	descriptorsByLinkname = [];

	// (find each flag_descriptor object)
	descriptors = getentarray("flag_descriptor", "targetname");
	
	flags = level._flags;
	
	for (i = 0; i < level._domFlags.size; i++)
	{
		closestdist = undefined;
		closestdesc = undefined;
		for (j = 0; j < descriptors.size; j++)
		{
			dist = distance(flags[i].origin, descriptors[j].origin);
			if (!isdefined(closestdist) || dist < closestdist) {
				closestdist = dist;
				closestdesc = descriptors[j];
			}
		}
		
		if (!isdefined(closestdesc)) {
			maperrors[maperrors.size] = "there is no flag_descriptor in the map! see explanation in dom.gsc";
			break;
		}
		if (isdefined(closestdesc.flag)) {
			maperrors[maperrors.size] = "flag_descriptor with script_linkname \"" + closestdesc.script_linkname + "\" is nearby more than one flag; is there a unique descriptor near each flag?";
			continue;
		}
		flags[i].descriptor = closestdesc;
		closestdesc.flag = flags[i];
		descriptorsByLinkname[closestdesc.script_linkname] = closestdesc;
	}
	
	if (maperrors.size == 0)
	{
		// find adjacent flags
		for (i = 0; i < flags.size; i++)
		{
			if (isdefined(flags[i].descriptor.script_linkto))
				adjdescs = strtok(flags[i].descriptor.script_linkto, " ");
			else
				adjdescs = [];
			for (j = 0; j < adjdescs.size; j++)
			{
				otherdesc = descriptorsByLinkname[adjdescs[j]];
				if (!isdefined(otherdesc) || otherdesc.targetname != "flag_descriptor") {
					maperrors[maperrors.size] = "flag_descriptor with script_linkname \"" + flags[i].descriptor.script_linkname + "\" linked to \"" + adjdescs[j] + "\" which does not exist as a script_linkname of any other entity with a targetname of flag_descriptor (or, if it does, that flag_descriptor has not been assigned to a flag)";
					continue;
				}
				adjflag = otherdesc.flag;
				if (adjflag == flags[i]) {
					maperrors[maperrors.size] = "flag_descriptor with script_linkname \"" + flags[i].descriptor.script_linkname + "\" linked to itself";
					continue;
				}
				flags[i].adjflags[flags[i].adjflags.size] = adjflag;
			}
		}
	}
	
	// assign each spawnpoint to nearest flag
	spawnpoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dom_spawn" );
	for (i = 0; i < spawnpoints.size; i++)
	{
		if (isdefined(spawnpoints[i].script_linkto)) {
			desc = descriptorsByLinkname[spawnpoints[i].script_linkto];
			if (!isdefined(desc) || desc.targetname != "flag_descriptor") {
				maperrors[maperrors.size] = "Spawnpoint at " + spawnpoints[i].origin + "\" linked to \"" + spawnpoints[i].script_linkto + "\" which does not exist as a script_linkname of any entity with a targetname of flag_descriptor (or, if it does, that flag_descriptor has not been assigned to a flag)";
				continue;
			}
			nearestflag = desc.flag;
		}
		else {
			nearestflag = undefined;
			nearestdist = undefined;
			for (j = 0; j < flags.size; j++)
			{
				dist = distancesquared(flags[j].origin, spawnpoints[i].origin);
				if (!isdefined(nearestflag) || dist < nearestdist)
				{
					nearestflag = flags[j];
					nearestdist = dist;
				}
			}
		}
		nearestflag.nearbyspawns[nearestflag.nearbyspawns.size] = spawnpoints[i];
	}
	
	if (maperrors.size > 0)
	{
		println("^1------------ Map Errors ------------");
		for(i = 0; i < maperrors.size; i++)
			println(maperrors[i]);
		println("^1------------------------------------");
		
		error("Map errors. See above");
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		
		return;
	}
}

onSpawnPlayer()
{
}

updateCPM()
{
	if ( !isDefined( self.CPM ) )
	{
		self.numCaps = 0;
		self.CPM = 0;
	}
	
	self.numCaps++;
	
	if ( getMinutesPassed() < 1 )
		return;
		
	self.CPM = self.numCaps / getMinutesPassed();
}

getCapXPScale()
{
	if ( self.CPM < 4 )
		return 1;
	else
		return 0.25;
}