
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

/*
	Mercenary Timetrial
	Objective: 	Hit as many of the enemy targets as possible while avoiding civilian targets.
	Map ends:	When the time limit is reached or all the targets are hit.
	Respawning:	No wait / Near teammates

	Level requirementss
	------------------
		Spawnpoints:
			classname		mp_dm_spawn
			All players spawn from these. The spawnpoint chosen is dependent on the current locations of teammates and enemies
			at the time of spawn. Players generally spawn behind their teammates relative to the direction of enemies.

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.
*/

/*QUAKED mp_dm_spawn (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Players spawn away from enemies at one of these positions.*/

main()
{
	if(getdvar("mapname") == "mp_background")
		return;
	
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	registerRoundSwitchDvar( level._gameType, 0, 0, 9 );
	registerTimeLimitDvar( level._gameType, 2, 0, 2 );
	registerScoreLimitDvar( level._gameType, 500, 0, 5000 );
	registerRoundLimitDvar( level._gameType, 1, 0, 10 );
	registerWinLimitDvar( level._gameType, 1, 0, 10 );
	registerRoundSwitchDvar( level._gameType, 3, 0, 30 );
	registerNumLivesDvar( level._gameType, 0, 0, 10 );
	registerHalfTimeDvar( level._gameType, 0, 0, 1 );

	level._teamBased = false;
	level._onStartGameType = ::onStartGameType;
	level._getSpawnPoint = ::getSpawnPoint;
	level._onSpawnPlayer = ::onSpawnPlayer;
	level._onPlayerKilled = ::onPlayerKilled;
	level._onNormalDeath = ::onNormalDeath;

	// Turn off killstreaks
	setDvar( "scr_game_hardpoints", "0" );

	game["dialog"]["gametype"] = "freeforall";
	
	if ( getDvarInt( "g_hardcore" ) )
		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "camera_thirdPerson" ) )
		game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "scr_diehard" ) )
		game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
	else if (getDvarInt( "scr_" + level._gameType + "_promode" ) )
		game["dialog"]["gametype"] = game["dialog"]["gametype"] + "_pro";
	
	game["strings"]["overtime_hint"] = &"MP_FIRST_BLOOD";

	precacheshader( "nx_hud_merc_frame" );
}


onStartGameType()
{
	setClientNameMode("auto_change");

	setObjectiveText( "allies", &"OBJECTIVES_WAR" );
	setObjectiveText( "axis", &"OBJECTIVES_WAR" );

	if ( !isdefined( game["switchedsides"] ) )
		game["switchedsides"] = false;

	if ( game["switchedsides"] )
	{
		oldAttackers = game["attackers"];
		oldDefenders = game["defenders"];
		game["attackers"] = oldDefenders;
		game["defenders"] = oldAttackers;
	}
	
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
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dm_spawn" );
	
	level._mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level._spawnMins, level._spawnMaxs );
	setMapCenter( level._mapCenter );
	
	allowed[0] = level._gameType;
	allowed[1] = "airdrop_pallet";
	
	maps\mp\gametypes\_gameobjects::main(allowed);

	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 0 );
	//maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 0 );
	//maps\mp\gametypes\_rank::registerScoreInfo( "assist", 0 );
	//maps\mp\gametypes\_rank::registerScoreInfo( "suicide", 0 );
	//maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", 0 );

	level._QuickMessageToAll = true;

	// Merc mode object and rules setup
	thread merc_mode_init();	
}


getSpawnPoint()
{
	spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( spawnPoints );

	return spawnPoint;
}


onNormalDeath( victim, attacker, lifeId )
{
	// Register a score event
	score = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
	assert( isDefined( score ) );

	attacker maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( attacker.pers["team"], score );
	
	if ( game["state"] == "postgame" && game["teamScores"][attacker.team] > game["teamScores"][level._otherTeam[attacker.team]] )
		attacker.finalKill = true;
}


onSpawnPlayer()
{
	println( "onSpawnPlayer() player = " + self.name );
	self merc_player_init();
	self thread merc_create_HUD();
}


// A player has died
onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, killId)
{
	self thread merc_destroy_HUD();

	// Clear attackers multiplier
	if( attacker != self )
	{
		// Multiplier drops by 1 when you kill a player
		if( attacker.mult > 1 )
		{
			attacker.mult -= 1;
		}
		attacker thread merc_update_HUD();
	}
}


//=================================================================================================
//=================================================================================================

// Does general initialization and setup
merc_mode_init()
{
	// Make sure targets exist in the map
	if ( !isDefined( getentarray( "target_enemy", "targetname" ) ) )
	{
		iprintlnbold( "No Merc Mode targets were found in the map" );
	}

	level.targets_total = 0;
	level.targets_remaining = 0;
	level.mult_curve = [ 1.0, 1.0, 2.0, 2.8, 3.4, 3.9, 4.2, 4.4, 4.6, 4.8, 5.0 ];

	// Target values
	//level.target_normal.value = 100;

	// Merc mode target and scoring logic
	thread merc_mode_logic();
}


// Sets up data for each player in the game
merc_player_init()
{
	// If this is the first time the script is run,
	// initialize targets_hit
	if( !isDefined( self.targets_hit ))
	{
		self.targets_hit = 0;
	}

	// If this is the first time the script is run,
	// initialize targets_hit
	if( !isDefined( self.score ))
	{
		self.score = 0;
		//maps\mp\gametypes\_gamescore::_setPlayerScore( self, 0 );
	}
	
	// Reset multiplier to 1
	self.mult = 1;
}

//=================================================================================================
//=================================================================================================

merc_mode_logic()
{
	// Get a list of all the moving target start points
	//level.target_rail_start_points = getentarray( "target_rail_start_point", "targetname" );

	// Run the target think script on all the enemy targets
	targets = getentarray( "target_enemy", "targetname" );
	foreach( target in targets )
	{
		target thread target_think( "enemy" );
		level.targets_total++;
		level.targets_remaining++;
	}

	// Run the target think script on all the small round targets
	targets = getentarray( "target_enemy_small", "targetname" );
	foreach( target in targets )
	{
		target thread target_think( "enemy_small" );
		level.targets_total++;
		level.targets_remaining++;
	}
	
	// Run the target think script on all the friendly targets
	targets = getentarray( "target_friendly", "targetname" );
	foreach( target in targets )
	{
		target thread target_think( "friendly" );
		// Civilians dont count towards the total
		//level.targets_total++;
	}
}


// Spawned on all the targets at map init
// Each popup target is made of multiple brushes and each brush targets the origin node
target_think( targetType )
{
	while( true )
	{
		// Get this entity origin.  Self must have a target key, and the target must have a targetName
		self.orgEnt = getEnt( self.target, "targetname" );
		
		// Assert if no origin node found
		//assert( isdefined( self.orgEnt ) );
	
		// Attach the geo to this origin node
		self linkto ( self.orgEnt );
	
		// No shadows
		//self DontCastShadows();

		// Hide the aim assist squares
		aim_assist_target = getEnt( self.orgEnt.target, "targetname" );
		aim_assist_target hide();
		aim_assist_target notsolid();


		// No collision on dead target
		self solid();

		// Make this target shootable
		self setCanDamage( true );


		/*------------------------------
		SETUP LATERALLY MOVING TARGETS
		--------------------------------*/
		/*
		// Only do this logic if object has script_parameters, and it is set to use_rail
		if ( ( isdefined( self.script_parameters ) ) && ( self.script_parameters == "use_rail" ) )
		{
			// Links the aim assist block to the target, so they move together 
			//aim_assist_target linkTo( self );

			// Grab closest rail start to this target
			self.lateralStartPosition = getclosest( self.orgEnt.origin, level.target_rail_start_points, 10 );

			assert( isdefined( self.lateralStartPosition ) );
			assert( isdefined( self.lateralStartPosition.target ) );

			// Set an end pos.  The rail should have an end linked to its start
			self.lateralEndPosition = getent( self.lateralStartPosition.target, "targetname" );

			assert( isdefined( self.lateralEndPosition ) );

			// Setup an array of movement positions
			self.lateralMovementOrgs = [];
			self.lateralMovementOrgs[ 0 ] = self.lateralStartPosition;
			self.lateralMovementOrgs[ 1 ] = self.lateralEndPosition;

			dist = distance( self.lateralMovementOrgs[ 0 ].origin, self.lateralMovementOrgs[ 1 ].origin );
			self.lateralMoveTime = ( dist / 22 );

			// Safety check the movement points
			foreach( org in self.lateralMovementOrgs )
			{
				assertex( org.code_classname == "script_origin", "Pop up targets that move laterally need to be targeting 2 script_origins" );
			}

			// Randomize the target position
			self target_lateral_reset_random();
		}

		// Movers start moving
		if ( isdefined( self.lateralStartPosition ) )
		{
			self thread target_lateral_movement();
		}
		*/
	
		/*-----------------------
		WAIT FOR TARGET DAMAGE
		-------------------------*/	
		while ( true )
		{
			// Waits for damage
			self waittill ( "damage", amount, attacker, direction_vec, point, type );
	
			// Play some sound
			//self playSound( "nx_target_metal_hit" );

			if( isDefined( attacker ))
			{
				// Show hit marker
				if( isAlive( attacker ))
				{
					level._func[ "damagefeedback" ] = maps\mp\gametypes\_damagefeedback::updateDamageFeedback;
					attacker maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "" );
				}
				println( "attacker = " + attacker.name );
	
				// Increase number of targets hit
				if ( targetType == "friendly" )
				{
					//iprintlnbold( "YOU SHOT A CIVILIAN" );
					attacker.score += int( -300.0 * merc_get_multiplier( attacker ));
					//score = maps\mp\gametypes\_gamescore::_getPlayerScore( attacker );
					//maps\mp\gametypes\_gamescore::_setPlayerScore( attacker, score + ( -100 * attacker.mult ));
					attacker.mult = 1;
					attacker thread merc_update_HUD();
					//thread maps\mp\gametypes\_gamescore::sendUpdatedDMScores();
	
					self playSound( "nx_target_mistake_buzzer" );
				}
				else if( targetType == "enemy_small" )
				{
					attacker.targets_hit++;
					level.targets_remaining--;
					attacker.score += int( 100.0 * merc_get_multiplier( attacker ) );
					//score = maps\mp\gametypes\_gamescore::_getPlayerScore( attacker );
					//maps\mp\gametypes\_gamescore::_setPlayerScore( attacker, score + ( 100 * attacker.mult ));
					
					attacker thread merc_increase_multiplier();

					attacker thread merc_update_HUD();
					//thread maps\mp\gametypes\_gamescore::sendUpdatedDMScores();

					self playSound( "nx_target_enemy_hit" );
				}
				else
				{
					attacker.targets_hit++;
					level.targets_remaining--;
					attacker.score += int( 300.0 * merc_get_multiplier( attacker ) );
					//score = maps\mp\gametypes\_gamescore::_getPlayerScore( attacker );
					//maps\mp\gametypes\_gamescore::_setPlayerScore( attacker, score + ( 300 * attacker.mult ));
					attacker merc_increase_multiplier();
					attacker thread merc_update_HUD();
					//thread maps\mp\gametypes\_gamescore::sendUpdatedDMScores();
	
					self playSound( "nx_target_enemy_hit" );
				}

				// Check for last target
				if( level.targets_remaining <= 0 )
				{
					thread maps\mp\gametypes\_gamelogic::endGame( attacker, "All Targets Eliminated" );
				}

				break;			
			}
		}
		
		// No collision on dead target
		self notsolid();
	
		// Lay the target down again.  Facedown targets drop facedown, contrary to physics.
		if ( isdefined( self.orgEnt.script_noteworthy ) && self.orgEnt.script_noteworthy == "reverse" )
		{
			self.orgEnt rotatePitch( 90, 0.25 );
		}
		else if( isdefined( self.orgEnt.script_noteworthy ) && self.orgEnt.script_noteworthy == "sideways" )
		{
			self.orgEnt rotateYaw( -180, 0.5 );
		}
		else
		{
			self.orgEnt rotatePitch( -90, 0.25 );
		}

		self setCanDamage( false );

		break;
	}
}


// Increases the players multiplier up to a max of 10
merc_increase_multiplier()
{
	if( self.mult < 10 )
	{
		self.mult += 1;
	}
}

// Fetches the player's current multiplier
merc_get_multiplier( player )
{
	return ( level.mult_curve[ player.mult ] );
}



//=================================================================================================
// HUD Scripts
//=================================================================================================

// Creates our proto HUD
// self = player
merc_create_HUD()
{
	// Horrible hacked HUD
	self.barOne		= merc_hacky_hud_create_bar( -32, 108 );
	self.barTwo		= merc_hacky_hud_create_bar( -32, 126 );
	self.barThree	= merc_hacky_hud_create_bar( -32, 144 );
	self.barFour	= merc_hacky_hud_create_bar( -32, 162 );

	//=============================================================

	// Targets Hit Counter
	self.counterElem		= merc_hacky_hud_create_text( 12, 118, "TARGETS HIT" );
	self.counter_valueElem	= merc_hacky_hud_create_value( 127, 118 );

	// Targets remaining counter
	self.remainingElem		= merc_hacky_hud_create_text( 12, 136, "REMAINING" );
	self.remaining_valueElem= merc_hacky_hud_create_value( 127, 136 );

	// Combo counter
	self.multElem			= merc_hacky_hud_create_text( 12, 154, "COMBO" );
	self.mult_valueElem		= merc_hacky_hud_create_value( 127, 154 );

	// Score counter
	self.scoreElem			= merc_hacky_hud_create_text( 12, 172, "SCORE" );
	self.score_valueElem	= merc_hacky_hud_create_value( 127, 172 );

	// Force an update now
	self thread merc_update_HUD();
}


// This creates a HUD bar background for the text.
// There must be a better way to do this.
merc_hacky_hud_create_bar( xpos, ypos )
{
	hudBar = createFontString( "fwmed", 1.0 );
	hudBar setPoint( "TOPLEFT", undefined, xpos, ypos );
	hudBar setText( "blank" );
	hudBar.layer = "visor";
	hudBar.shader = "nx_hud_merc_frame"; 
	hudBar setShader( hudBar.shader, 200, 30 );

	return hudBar;
}

merc_hacky_hud_create_text( xpos, ypos, text )
{
	hudText = createFontString( "fwmed", 1.0 );
	hudText setPoint( "TOPLEFT", undefined, xpos, ypos );
	hudText setText( text );
	hudText.layer = "visor";
	return hudText;
}

merc_hacky_hud_create_value( xpos, ypos )
{
	hudValue = createFontString( "fwmed", 1.0 );
	hudValue setPoint( "TOPLEFT", undefined, xpos, ypos );
	hudValue.alignX = "right";
	hudValue.layer = "visor";
	return hudValue;
}


// Updates the proto HUD
// self = player
merc_update_HUD()
{
	if ( isDefined( self.counter_valueElem ) )
	{
		self.counter_valueElem setText( "" + self.targets_hit );
	}

	// Update the remaining targets on everyones HUD
	foreach( player in level._players )
	{
		if ( isDefined( player.remaining_valueElem ) )
		{
			player.remaining_valueElem setText( "" + level.targets_remaining );
		}
	}

	if ( isDefined( self.mult_valueElem ) )
	{
		multiplier = merc_get_multiplier( self );
		self.mult_valueElem setText( "" + multiplier );
	}

	if ( isDefined( self.score_valueElem ) )
	{
		self.score_valueElem setText( "" + self.score );
	}
}

// Cleans up our proto HUD
// self = player
merc_destroy_HUD()
{
	self.barOne destroyElem();
	self.barTwo destroyElem();
	self.barThree destroyElem();
	self.barFour destroyElem();

	self.counterElem destroyElem();
	self.counter_valueElem destroyElem();

	self.remainingElem destroyElem();
	self.remaining_valueElem destroyElem();

	self.multElem destroyElem();
	self.mult_valueElem destroyElem();

	self.scoreElem destroyElem();
	self.score_valueElem destroyElem();
}



//=================================================================================================
// Moving target scripts
//=================================================================================================
// This randomizes the mover direction
target_lateral_reset_random()
{	
	if ( cointoss() ) // 50/50 random func
	{
		self.lateralStartPosition = self.lateralMovementOrgs[ 0 ];
		self.lateralEndPosition = self.lateralMovementOrgs[ 1 ];
	}
	else
	{
		self.lateralStartPosition = self.lateralMovementOrgs[ 1 ];
		self.lateralEndPosition = self.lateralMovementOrgs[ 0 ];
	}

	// Move to the designated spot
	self.orgEnt moveTo( self.lateralStartPosition.origin, .1 );
}

// This moves the mover targets back and forth
target_lateral_movement()
{
	// Make a brand new script origin object
	dummy = spawn( "script_origin", ( 0, 0, 0 ) );
	dummy.angles = self.orgEnt.angles;
	dummy.origin = self.orgEnt.origin;
	self.orgEnt thread lateral_dummy_move( dummy );
	
	// Kill dummy when player gets too close - Prevents player getting stuck in target
	dummy endon( "deleted_because_player_was_too_close" );
	dummy endon( "death" );

	// Run the get too close thread
	foreach( player in level._players )
	{
		dummy thread delete_when_player_too_close( player );
	}

	self thread dummy_delete_when_target_goes_back_down( dummy );	


	while ( true )
	{
		// Move back and forth
		dummy moveTo( self.lateralEndPosition.origin, self.lateralMoveTime );
		wait( self.lateralMoveTime );
		dummy moveTo( self.lateralStartPosition.origin, self.lateralMoveTime );
		wait( self.lateralMoveTime );
	}
}

lateral_dummy_move( dummy )
{
	dummy endon( "death" );
	while( true )
	{
		wait( 0.05 );
		self.origin = dummy.origin;
	}
}

// A dummy object helps the target move
// Destroy it when the target is shot down
dummy_delete_when_target_goes_back_down( dummy )
{
	dummy endon( "death" );
	//self --> the target
	self waittill( "target_going_back_down" );
	dummy delete();
}

// Stop the mover when player is too close
// This is run on the lateral mover script
delete_when_player_too_close( player )
{
	self endon( "death" );
	dist = 128;
	distSquared = dist * dist;

	// Loop untill player is too close
	while( true )
	{
		wait( .05 );
		if ( distancesquared( player.origin, self.origin ) < distSquared )
			break;
	}
	self notify( "deleted_because_player_was_too_close" );
	self delete();
}

// Copied from single player _utility.gsc
getClosest( org, array, maxdist )
{
	if ( !IsDefined( maxdist ) )
		maxdist = 500000; // twice the size of the grid
		
	ent = undefined;
	foreach ( item in array )
	{
		newdist = Distance( item.origin, org );
		if ( newdist >= maxdist )
			continue;
		maxdist = newdist;
		ent = item;
	}
	return ent;
}

