#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
/*
	"Cyber War Test"
	
	// ...etc...
*/

/*QUAKED mp_sab_spawn_axis (0.75 0.0 0.5) (-16 -16 0) (16 16 72)
Axis players spawn away from enemies and near their team at one of these positions.*/

/*QUAKED mp_sab_spawn_axis_planted (0.75 0.0 0.5) (-16 -16 0) (16 16 72)
Axis players spawn away from enemies and near their team at one of these positions.*/

/*QUAKED mp_sab_spawn_allies (0.0 0.75 0.5) (-16 -16 0) (16 16 72)
Allied players spawn away from enemies and near their team at one of these positions.*/

/*QUAKED mp_sab_spawn_allies_planted (0.0 0.75 0.5) (-16 -16 0) (16 16 72)
Allied players spawn away from enemies and near their team at one of these positions.*/

/*QUAKED mp_sab_spawn_axis_start (1.0 0.0 0.5) (-16 -16 0) (16 16 72)
Axis players spawn away from enemies and near their team at one of these positions at the start of a round.*/

/*QUAKED mp_sab_spawn_allies_start (0.0 1.0 0.5) (-16 -16 0) (16 16 72)
Allied players spawn away from enemies and near their team at one of these positions at the start of a round.*/

main()
{
	if ( getdvar("mapname") == "mp_background" )
		return;
	
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();
	
	level._teamBased = true;

	registerRoundSwitchDvar( level._gameType, 0, 0, 9 );
	registerTimeLimitDvar( level._gameType, 10, 0, 1440 );
	registerScoreLimitDvar( level._gameType, 6, 0, 25 );
	registerRoundLimitDvar( level._gameType, 1, 0, 10 );
	registerWinLimitDvar( level._gameType, 1, 0, 10 );
	registerNumLivesDvar( level._gameType, 0, 0, 10 );
	registerHalfTimeDvar( level._gameType, 0, 0, 1 );

	setOverTimeLimitDvar( 2 );

	level._onPrecacheGameType = ::onPrecacheGameType;
	level._onStartGameType = ::onStartGameType;
	level._getSpawnPoint = ::getSpawnPoint;
	level._onSpawnPlayer = ::onSpawnPlayer;
	level._onOneLeftEvent = ::onOneLeftEvent;
	level._onTimeLimit = ::onTimeLimit;
	level._onNormalDeath = ::onNormalDeath;
	level._initGametypeAwards = ::initGametypeAwards;
	
	game["dialog"]["gametype"] = "cyberwar";

	if ( getDvarInt( "g_hardcore" ) )
		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "camera_thirdPerson" ) )
		game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "scr_diehard" ) )
		game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
	else if (getDvarInt( "scr_" + level._gameType + "_promode" ) )
		game["dialog"]["gametype"] = game["dialog"]["gametype"] + "_pro";
	
	game["dialog"]["offense_obj"] = "capture_obj";
	game["dialog"]["defense_obj"] = "capture_obj";

}

onPrecacheGameType()
{
	game["intel_dropped_sound"] = "mp_war_objective_lost";
	game["intel_recovered_sound"] = "mp_war_objective_taken";
	
	precacheShader("waypoint_captureneutral");
	precacheShader("waypoint_kill");
	precacheShader("waypoint_target");
	precacheShader("waypoint_escort");
	precacheShader("hud_suitcase_bomb");
	
	precacheString(&"MP_EXPLOSIVES_RECOVERED_BY");
	precacheString(&"MP_EXPLOSIVES_DROPPED_BY");
	precacheString(&"PLATFORM_HOLD_TO_UPLOAD_INTEL");
	precacheString(&"MP_UPLOADING_INTEL");
	precacheString(&"MP_NO_RESPAWN");
	precacheString(&"MP_TIE_BREAKER");	
	precacheString(&"MP_SUDDEN_DEATH");
}


onStartGameType()
{
	if ( !isdefined( game["switchedsides"] ) )
		game["switchedsides"] = false;

	setClientNameMode("auto_change");
	

	// tagTG<TODO> Need new objective hints and text
	setObjectiveText( "allies", &"OBJECTIVES_SAB" );
	setObjectiveText( "axis", &"OBJECTIVES_SAB" );

	if ( level._splitscreen )
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_SAB" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_SAB" );
	}
	else
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_SAB_SCORE" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_SAB_SCORE" );
	}
	setObjectiveHintText( "allies", &"OBJECTIVES_SAB_HINT" );
	setObjectiveHintText( "axis", &"OBJECTIVES_SAB_HINT" );
	
	level._spawnMins = ( 0, 0, 0 );
	level._spawnMaxs = ( 0, 0, 0 );	
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );
	
	level._mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level._spawnMins, level._spawnMaxs );
	setMapCenter( level._mapCenter );

	maps\mp\gametypes\_rank::registerScoreInfo( "plant", 200 );
	maps\mp\gametypes\_rank::registerScoreInfo( "destroy", 1000 );
	maps\mp\gametypes\_rank::registerScoreInfo( "defuse", 150 );

	allowed[0] = "cwtest";
	
	maps\mp\gametypes\_gameobjects::main(allowed);
		
	thread updateGametypeDvars();
	
	thread cyberWarSetup();
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
	self.isPlanting = false;

	if( ( inOvertime() ) && !isDefined( self.otSpawned ) )
		self thread printOTHint();
}


printOTHint()
{
	self endon ( "disconnect" );

	// give the "Overtime!" message time to show
	wait ( 0.25 );

	self thread maps\mp\gametypes\_hud_message::SplashNotify( "sudden_death" );
	self.otSpawned = true;
	
}

updateGametypeDvars()
{
	level._plantTime = dvarFloatValue( "planttime", 5, 0, 20 );
	level._num_active_intel = dvarIntValue( "num_intel", 2, 1, 5 );
	level._intel_spawn_delay = dvarFloatValue( "intelspawndelay", 5.0, 0, 20.0 );
	level._intel_to_spawn_turret = dvarIntValue( "spawnturretrate", 2, 0, 15 );
}


cyberWarSetup()
{
	level._bombExploded = false;
		
	level._effect["bombexplosion"] = loadfx("explosions/tanker_explosion");

	triggers = getEntArray( "cwtest_intel_pickup", "targetname" );
	if( triggers.size < 1 ) 
	{
		error( "No cwtest_intel_pickup triggers found in map." );
		return;
	}
	
	intel_visuals = getEntArray( "cwtest_intel", "targetname" );
	if( intel_visuals.size < 1 )
	{
		error( "No cwtest_intel script_model found in map." );
		return;
	}

	maperrors = [];
	level._cw_intel = [];
	for ( i = 0; i < intel_visuals.size; i++ )
	{
		errored = false;
		
		intel = intel_visuals[i];
		intel.trig = undefined;
		for ( j = 0; j < triggers.size; j++ )
		{
			if ( intel istouching( triggers[j] ) )
			{
				if ( isdefined( intel.trig ) )
				{
					maperrors[maperrors.size] = "Intel at " + intel.origin + " is touching more than one \"cwtest_intel_pickup\" trigger";
					break;
				}
				intel.trig = triggers[j];
			}
		}

		visuals = [];
		visuals[0] = intel;
		intel.visuals = visuals;
		//intel maps\mp\gametypes\_gameobjects::setModelVisibility( false );
		intel.gameObject = maps\mp\gametypes\_gameobjects::createCarryObject( "neutral", intel.trig, intel.visuals, (0,0,32) );
		intel.gameObject maps\mp\gametypes\_gameobjects::allowCarry( "none" );
		intel.gameObject maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
		intel.gameObject maps\mp\gametypes\_gameobjects::setModelVisibility( false );
		intel.trig.useObj = intel.gameObject;
		level._cw_intel[level._cw_intel.size] = intel;
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

	upload_terminals = getEntArray( "terminal_upload", "targetname" );
	if( upload_terminals.size < 1 )
	{
		error("No upload terminals trigger found in map.");
		return;
	}
	level._bombZones["any"] = [];
	for ( i = 0; i < upload_terminals.size; i++ )
	{
		level._bombZones["any"][level._bombZones["any"].size] = createUploadTerminalZone( "any", upload_terminals[i] );
	}

	level._active_intels = [];
	for( i = 0; i < level._num_active_intel; i++ )
	{
		level._active_intels[i] = undefined;
		intel = pickIntelToSpawn();
		intel.gameobject makeIntelActive();
	}

	if ( inOvertime() )
		level thread overtimeThread();
}

pickIntelToSpawn()
{
	println("pickIntelToSpawn");
	validAllies = [];
	validAxis = [];

	potential_intel = [];
	println( "Potential intel size 0" );
	for( i = 0; i < level._cw_intel.size; i++ )
	{
		intel_active = false;
// 		if( level.cw_intel.size > level.num_active_intel )
// 		{
			// if we have more than the number active needed remove the active intel
			for( j = 0; j < level._active_intels.size; j++ )
			{
				if( isDefined(level._active_intels[j]) && level._active_intels[j] == level._cw_intel[i].gameObject )
				{
					intel_active = true;
					break;
				}
			}
//		}
		
		if( !intel_active )
		{
			println( "Adding potential intel" );
			potential_intel[ potential_intel.size ] = level._cw_intel[i];
		}
	}
	println( "Potential intel size" + potential_intel.size );
	foreach ( player in level._players )
	{
		if ( player.team == "spectator" )
			continue;
			
		if ( !isAlive( player ) )
			continue;
			
		player.dist = 0;
		if ( player.team == "allies" )
			validAllies[validAllies.size] = player;
		else
			validAxis[validAxis.size] = player;
	}

	if ( !validAllies.size || !validAxis.size )
	{
		intel = potential_intel[ randomint( potential_intel.size) ];
		return intel;
	}
	
	for ( i = 0; i < validAllies.size; i++ )
	{
		for ( j = i + 1; j < validAllies.size; j++ )
		{
			dist = distanceSquared( validAllies[i].origin, validAllies[j].origin );
			
			validAllies[i].dist += dist;
			validAllies[j].dist += dist;
		}
	}

	for ( i = 0; i < validAxis.size; i++ )
	{
		for ( j = i + 1; j < validAxis.size; j++ )
		{
			dist = distanceSquared( validAxis[i].origin, validAxis[j].origin );
			
			validAxis[i].dist += dist;
			validAxis[j].dist += dist;
		}
	}

	bestPlayer = validAllies[0];
	foreach ( player in validAllies )
	{
		if ( player.dist < bestPlayer.dist )
			bestPlayer = player;
	}
	avgpos["allies"] = bestPlayer.origin;

	bestPlayer = validAxis[0];
	foreach ( player in validAxis )
	{
		if ( player.dist < bestPlayer.dist )
			bestPlayer = player;
	}
	avgpos["axis"] = validAxis[0].origin;
	
	bestintel = undefined;
	lowestcost = undefined;
	for ( i = 0; i < potential_intel.size; i++ )
	{
		intel = potential_intel[i];
		
		// (purposefully using distance instead of distanceSquared)
		cost = abs( distance( intel.origin, avgpos["allies"] ) - distance( intel.origin, avgpos["axis"] ) );
		
		for( j = 0; j < level._active_intels.size; j++ )
		{
			if( isDefined(level._active_intels[j]) && level._active_intels[j] == intel )
			{
				cost += 512;
				break;
			}
		}
		
		if ( !isdefined( lowestcost ) || cost < lowestcost )
		{
			lowestcost = cost;
			bestintel = intel;
		}
	}
	assert( isdefined( bestintel ) );
	
	return bestintel;
}

makeIntelActive( use_wait_delay )
{
	level endon( "game_ended" );
	if( isDefined( use_wait_delay ) && use_wait_delay )
		wait level._intel_spawn_delay;

	self maps\mp\gametypes\_gameobjects::allowCarry( "any" );
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	self maps\mp\gametypes\_gameobjects::setModelVisibility( true );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_flag_friendly" );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_flag_friendly" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_flag_friendly" );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_flag_friendly" );
	self maps\mp\gametypes\_gameobjects::setCarryIcon( "hud_suitcase_bomb" );
	self.objIDPingEnemy = true;
	self.onPickup = ::onPickup;
	self.onDrop = ::onDrop;
	self.allowWeapons = true;
	self.objPoints["allies"].archived = true;
	self.objPoints["axis"].archived = true;
	self.autoResetTime = 60.0;

	found_empty_spot = false;
	for( j = 0; j < level._num_active_intel; j++ )
	{
		// find an empty spot in our array
		if( !isDefined( level._active_intels[j] ))
		{
			found_empty_spot = true;
			level._active_intels[j] = self;
			break;
		}
	}
	
	if( !found_empty_spot )
	{
		error( "Too many active intel( " + level._active_intels.size +" ) ... maybe the current one needs to be disabled first?" );
	}
}


makeIntelInactive()
{
	self maps\mp\gametypes\_gameobjects::returnHome();
	self maps\mp\gametypes\_gameobjects::setModelVisibility( false );
	self maps\mp\gametypes\_gameobjects::allowCarry( "none" );
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );

	for( j = 0; j < level._num_active_intel; j++ )
	{
		if( isDefined(level._active_intels[j]) && level._active_intels[j] == self )
		{
			println( "setting active_intel to undefined index = " + j );
			level._active_intels[j] = undefined;
			break;
		}
	}
}

createUploadTerminalZone( team, trigger )
{
	visuals = getEntArray( trigger.target, "targetname" );
	
	// tagTG<TODO> figure out why we can't use any as the team here....
	terminalZone = maps\mp\gametypes\_gameobjects::createUseObject( "neutral", trigger, visuals, (0,0,64) );
	terminalZone resetTermimalSite();
	terminalZone.onUse = ::onUse;
	terminalZone.onBeginUse = ::onBeginUse;
	terminalZone.onEndUse = ::onEndUse;
	terminalZone.onCantUse = ::onCantUse;
	terminalZone.useWeapon = "briefcase_bomb_mp";
	terminalZone.teamUploads["axis"] = 0;
	terminalZone.teamUploads["allies"] = 0;

	return terminalZone;
}


onBeginUse( player )
{
	// uploading intel
	player.isPlanting = true;
}

onEndUse( team, player, result )
{
	if ( !isAlive( player ) )
		return;
	
	player.isPlanting = false;
}


onPickup( player )
{
	level notify ( "bomb_picked_up" );
	
	self.autoResetTime = 60.0;
	
	level._useStartSpawns = false;
	
	team = player.pers["team"];
	
	if ( team == "allies" )
		otherTeam = "axis";
	else
		otherTeam = "allies";
	
	player playLocalSound( "mp_suitcase_pickup" );
	
	player leaderDialogOnPlayer( "obj_destroy", "bomb" );
	excludeList[0] = player;
	leaderDialog( "bomb_taken", team, "bomb", excludeList );

	if ( !level._splitscreen )
	{
		leaderDialog( "bomb_lost", otherTeam, "bomb" );
		leaderDialog( "obj_defend", otherTeam, "bomb" );
	}
	player.isBombCarrier = true;

	// recovered the bomb before abandonment timer elapsed
	// tagTG<TODO> this is where in sab it would notify people that the bomb is recovered maybe intel recovery needs one too?
// 	if ( team == self maps\mp\gametypes\_gameobjects::getOwnerTeam() )
// 	{
// 		//printOnTeamArg( &"MP_EXPLOSIVES_RECOVERED_BY", team, player );
// 		playSoundOnPlayers( game["bomb_recovered_sound"], team );
// 	}
// 	else
// 	{
// 		//printOnTeamArg( &"MP_EXPLOSIVES_RECOVERED_BY", team, player );
// 		playSoundOnPlayers( game["bomb_recovered_sound"] );
// 	}
	
	self maps\mp\gametypes\_gameobjects::setOwnerTeam( team );
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_kill" );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_kill" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_escort" );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_escort" );

	
	player incPlayerStat( "bombscarried", 1 );
	player thread maps\mp\_matchdata::logGameEvent( "pickup", player.origin );
}


onDrop( player )
{
	println( "onDrop" );
	if ( isDefined( player ) )
	{
		// tagTG<TODO> Notify the team that we have dropped intel... we need a new string here
		printOnTeamArg( &"MP_EXPLOSIVES_DROPPED_BY", self maps\mp\gametypes\_gameobjects::getOwnerTeam(), player );

		if( player.isPlanting )
		{
			intel = pickIntelToSpawn();

			// old intel needs to be deactivated prior to new activation
			self makeIntelInactive();

			intel.gameobject thread makeIntelActive( true );
		}
		else
		{
			playSoundOnPlayers( game["intel_dropped_sound"], self maps\mp\gametypes\_gameobjects::getOwnerTeam() );
			thread abandonmentThink( 0.0 );
		}

	}
	else
	{
		playSoundOnPlayers( game["intel_dropped_sound"], self maps\mp\gametypes\_gameobjects::getOwnerTeam() );
		thread abandonmentThink( 0.0 );
	}
}


abandonmentThink( delay )
{
	level endon ( "bomb_picked_up" );
	
	wait ( delay );

	if ( isDefined( self.carrier ) )
		return;

	if ( self maps\mp\gametypes\_gameobjects::getOwnerTeam() == "allies" )
		otherTeam = "axis";
	else
		otherTeam = "allies";

	playSoundOnPlayers( game["intel_dropped_sound"], otherTeam );

	self maps\mp\gametypes\_gameobjects::setOwnerTeam( "neutral" );
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_flag_friendly" );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_flag_friendly" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_flag_friendly" );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_flag_friendly" );

}


onUse( player )
{
	println( "onUse" );
	team = player.pers["team"];
	otherTeam = level._otherTeam[team];
	// uploaded the intel... 
	player notify ( "bomb_planted" );

	player playSound( "mp_bomb_plant" );

	//Add player callout card here if neccesary

	player thread maps\mp\gametypes\_hud_message::SplashNotify( "upload", maps\mp\gametypes\_rank::getScoreInfoValue( "plant" ) );
	player thread maps\mp\gametypes\_rank::giveRankXP( "plant" );
	maps\mp\gametypes\_gamescore::givePlayerScore( "plant", player );		
	player incPlayerStat( "bombsplanted", 1 );
	player thread maps\mp\_matchdata::logGameEvent( "plant", player.origin );

	intel_object = player.carryObject;
	team = player.pers["team"];

	//if ( !inOvertime() )
	maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( team, 1 );

	self.teamUploads[team] = self.teamUploads[team] + 1;

	if( self.teamUploads[team] >= level._intel_to_spawn_turret )
	{
		self.teamUploads[player.pers["team"]] = 0;
		println( "Turret info" );
		println( self.curOrigin );

		terminalTurret = spawnTurret( "misc_turret", self.curOrigin, level._sentrySettings[ "sentry_minigun" ].weaponInfo );
		terminalTurret.angles = self.visuals[0].baseAngles; // tagTG<TODO> find a better place to get angles from
		if( isDefined( terminalTurret ) )
		{
			println( "turret is defined" );
			terminalTurret maps\mp\killstreaks\_autosentry::sentry_initSentry( "sentry_minigun", player );
			//terminalTurret maps\mp\killstreaks\_autosentry::sentry_setPlaced();
			terminalTurret setModel( level._sentrySettings[ "sentry_minigun" ].modelBase );
			terminalTurret maps\mp\killstreaks\_autosentry::sentry_makeSolid();
			terminalTurret maps\mp\killstreaks\_autosentry::sentry_setActive();
			terminalTurret MakeUnusable();
		}
		else
		{
			println( "turret is NOT defined" );
		}
	}

	intel = pickIntelToSpawn();

	// old intel needs to be deactivated prior to new activation
	intel_object makeIntelInactive();

	intel.gameobject thread makeIntelActive( true );
}


onCantUse( player )
{
	player iPrintLnBold( &"MP_CANT_UPLOAD_WITHOUT_INTEL" );
}


giveLastOnTeamWarning()
{
	self endon("death");
	self endon("disconnect");
	level endon( "game_ended" );
		
	self waitTillRecoveredHealth( 3 );
	
	otherTeam = getOtherTeam( self.pers["team"] );
	level thread teamPlayerCardSplash( "callout_lastteammemberalive", self, self.pers["team"] );
	level thread teamPlayerCardSplash( "callout_lastenemyalive", self, otherTeam );
	level notify ( "last_alive", self );	
	//self maps\mp\gametypes\_missions::lastManSD();
}


onTimeLimit()
{
	if( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
	{
		thread maps\mp\gametypes\_gamelogic::endGame( "axis", game["strings"]["time_limit_reached"] );
	}
	else if( game["teamScores"]["axis"] < game["teamScores"]["allies"] )
	{
		thread maps\mp\gametypes\_gamelogic::endGame( "allies", game["strings"]["time_limit_reached"] );
	}
	else if( game["teamScores"]["axis"] == game["teamScores"]["allies"] )
	{
		if ( inOvertime() )
			thread maps\mp\gametypes\_gamelogic::endGame( "tie", game["strings"]["time_limit_reached"] );
		else
			thread maps\mp\gametypes\_gamelogic::endGame( "overtime", game["strings"]["time_limit_reached"] );
	}
}


overtimeThread( time )
{
	level endon( "game_ended" );

	level._inOvertime = true;
	
	wait ( 5.0 );
	level._disableSpawning = true;
}

resetTermimalSite()
{
	self maps\mp\gametypes\_gameobjects::allowUse( "any" );
	self maps\mp\gametypes\_gameobjects::setUseTime( level._plantTime );
	self maps\mp\gametypes\_gameobjects::setUseText( &"MP_UPLOADING_INTEL" );
	self maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_UPLOAD_INTEL" );

	for( i = 0; i < level._cw_intel.size; i++ )
	{
		self maps\mp\gametypes\_gameobjects::addKeyObject( level._cw_intel[i].gameobject );
	}
	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_targetneutral" );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_targetneutral" );
	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_targetneutral" );
	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_targetneutral" );
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	self.useWeapon = "briefcase_bomb_mp";
}


onOneLeftEvent( team )
{
	lastPlayer = getLastLivingPlayer( team );

	lastPlayer thread giveLastOnTeamWarning();
}


onNormalDeath( victim, attacker, lifeId, lifeId )
{
	if ( victim.isPlanting )
	{
		thread maps\mp\_matchdata::logKillEvent( lifeId, "planting" );
	}
}

initGametypeAwards()
{
	maps\mp\_awards::initStatAward( "targetsdestroyed", 	0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStatAward( "bombsplanted", 		0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStatAward( "bombcarrierkills", 	0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStatAward( "bombscarried", 		0, maps\mp\_awards::highestWins );
	maps\mp\_awards::initStatAward( "killsasbombcarrier", 	0, maps\mp\_awards::highestWins );
}
