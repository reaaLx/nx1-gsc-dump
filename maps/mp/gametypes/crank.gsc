#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
/*
	War
	Objective: 	Score points for your team by eliminating players on the opposing team
	Map ends:	When one team reaches the score limit, or time limit is reached
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
	registerScoreLimitDvar( level._gameType, 500, 0, 5000 );
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
	level._onPrecacheGameType = ::onPrecacheGameType;
	//level.onTimeLimit = ::onTimeLimit;	// overtime not fully supported yet

	game["dialog"]["gametype"] = "tm_death";
	
	if ( getDvarInt( "g_hardcore" ) )
		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "camera_thirdPerson" ) )
		game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "scr_diehard" ) )
		game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
	else if (getDvarInt( "scr_" + level._gameType + "_promode" ) )
		game["dialog"]["gametype"] = game["dialog"]["gametype"] + "_pro";
	
	game["strings"]["overtime_hint"] = &"MP_FIRST_BLOOD";
}

onPrecacheGameType()
{
	precacheShader( "waypoint_captureneutral" );
	precacheShader( "waypoint_captureneutral_a" );
	precacheShader( "waypoint_captureneutral_b" );
	precacheShader( "waypoint_captureneutral_c" );
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
	
	allowed[0] = "dom";
	allowed[1] = "airdrop_pallet";
	
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	thread campKiller();
	thread crankBatteries();	
}

crankBatteries()
{
	game["flagmodels"] = [];
	game["flagmodels"]["neutral"] = "prop_flag_neutral";

 	game["flagmodels"]["crate"] = "com_plasticcase_friendly";
	
	precacheModel( game["flagmodels"]["neutral"] );
	precacheModel( game["flagmodels"]["crate"] );

	precacheShader( "waypoint_ammo_friendly" );
	precacheShader( "compass_objpoint_ammo_friendly" );

	
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

		visuals[0] setModel( game["flagmodels"]["crate"] );

		domFlag = maps\mp\gametypes\_gameobjects::createUseObject( "neutral", trigger, visuals, (0,0,100) );
		domFlag maps\mp\gametypes\_gameobjects::allowUse( "any" );
		domFlag maps\mp\gametypes\_gameobjects::setUseTime( 0.5 );
		label = domFlag maps\mp\gametypes\_gameobjects::getLabel();
		domFlag.label = label;
		printLn( "Flag Label: " + label );
		domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_captureneutral" + label );
		domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_captureneutral" + label );
		domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_captureneutral" + label );
		domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_captureneutral" + label );
		domFlag maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
		
		domFlag.onUse = ::onUseBatt;
		domFlag.onBeginUse = ::onBattBeginUse;
		domFlag.onUseUpdate = ::onBattUseUpdate;
		domFlag.onEndUse = ::onBattEndUse;
		
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
	
}

onUseBatt( player )
{
	if( isDefined( player.canUseBatt ) && player.canUseBatt )
	{
		player thread maps\mp\_flashgrenades::applyFlash( 1.5, 1 );
		player.health = player.maxHealth;
		player thread batteryUseCooldown();
	}
}

batteryUseCooldown()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "disconnect" );

	self.canUseBatt = false;
	wait( 10 );
	self.canUseBatt = true;
}

onBattBeginUse( player )
{

}

onBattUseUpdate( team, progress, change )
{

}

onBattEndUse( team, player, success )
{

}

onSpawnPlayer()
{
	println( "onSpawnPlayer() player = " + self.name );

	self thread monitorCrankSprint();
	self.canUseBatt = true;
}

monitorCrankSprint()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "disconnect" );
	println( "Started monitorCrankSprint() player = " + self.name );
	
	while(1)
	{
		println( "waiting monitorCrankSprint()" );
		self waittill("sprint_begin");
		self thread monitorCrankSprintTime();
	}
}

monitorCrankSprintTime()
{
	println( "monitorCrankSprintTime()" );
	level endon( "game_ended" );
	self endon( "spawned_player" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "sprint_end" );

	startTime = getTime();	
	while(1)
	{
		// wait one second, then award health
		wait( 1 );
		// we'll do this until they stop sprinting
		
		self.health += 10;
		if( self.health > self.maxHealth )
		{
			self.health = self.maxHealth;
		}
		println( "Giving health, health = " + self.health );	
	}
}

campKiller()
{
	println( "Started campKiller()" );
	level endon ( "game_ended" );

	// var setup
	level._minCampDistance = 280;
	level._campCounter = 0;
	level._numCampSpots = 3;
	level._campSpots = [];
	if( level._prematchPeriod > 0 )
	{
		wait( level._prematchPeriod + 3 ); // add in a bit of grace time
	}
	while ( !level._gameEnded )
	{
		/*if( isDefined( game["gamestarted"] ) && game["gamestarted"] )
		{
			wait(1);
			continue;
		}*/
		// first update positions
		foreach ( player in level._players )
		{
			player.campSpots[ level._campCounter % level._numCampSpots ] = player.origin;		   
		}

		// now, lets see how far each person has moved
		startNum = ( level._campCounter + 1 ) % level._numCampSpots; // since this is a circular buffer, this should be the oldest num we have
		endNum = level._campCounter % level._numCampSpots;
		foreach ( player in level._players )
		{
			dist = 0;
			prev = 0;
			for( index = startNum; true; index = ( index + 1 ) % level._numCampSpots )
			{
				// skip the first, since we don't have a previous position to compare to
				if( index != startNum )
				{
					if( index < player.campSpots.size )  // make sure we don'
					{
					   	if( isDefined( player.campSpots[index] ) && isDefined( player.campSpots[prev] ) )
						{
   							dist += distance( player.campSpots[ prev ], player.campSpots[ index ] );
						}
					}		
				}
				prev = index;
				if( index == endNum	)
				{
					break;
				}
			}
			
			canTakeDamage = true;
			// are they camping?
			if( isDefined( player.selectingLocation ) && player.selectingLocation == true )
			{
				canTakeDamage = false;
			}
			if( player IsLinked() )
			{
				canTakeDamage = false;
			}
			
			if( canTakeDamage && dist < level._minCampDistance )
			{
				println( "Player " + player.name + " is camping! dist = " + dist );
				//player maps\mp\_radiation::radiationEffect();
				//player shellshock( "mp_radiation_low", 0.5);
				player.radiationSound = "item_geigercouner_level3";
				player stopLoopSound();
				player playLoopSound( player.radiationSound );
				player ViewKick( 3, player.origin );
				player maps\mp\_radiation::doRadiationDamage(15);
			}
			else
			{
				player stopLoopSound();
				if( !canTakeDamage )
				{
					println( "Player " + player.name + " ignored, airstriking" );
				}
				else
				{
					println( "Player " + player.name + " dist = " + dist );
				}
				//player notify( "leftTrigger");
			}				
		}

		level._campCounter++;
		wait ( 1.0 );
	}	
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
