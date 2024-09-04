#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
 
 /*
 	UGV Escort Plus
 	Objective: 	Escort the UGV throught all the checkpoints
 	Map ends:	When one team reaches the score limit, or time limit is reached
 	Respawning:	No wait / Specific locations for the current checkpoint
 */
 
 /*QUAKED mp_convoy_spawn_attackers_group1 (0.0 1.0 1.0) (-16 -16 0) (16 16 72)
 Players spawn away from enemies and near their team at one of these positions.*/
 
 /*QUAKED mp_convoy_spawn_attackers_group2 (0.0 1.0 1.0) (-16 -16 0) (16 16 72)
 Team 0 players spawn at one of these positions at the start of a round.*/
 
 /*QUAKED mp_convoy_spawn_attackers_group3 (0.0 1.0 1.0) (-16 -16 0) (16 16 72)
 Team 1 players spawn at one of these positions at the start of a round.*/
 
 /*QUAKED mp_convoy_spawn_attackers_group4 (0.0 1.0 1.0) (-16 -16 0) (16 16 72)
 Team 2 players spawn at one of these positions at the start of a round.*/
 
 /*QUAKED mp_convoy_spawn_attackers_group5 (0.0 1.0 1.0) (-16 -16 0) (16 16 72)
 Team 3 players spawn at one of these positions at the start of a round.*/
 
 /*QUAKED mp_convoy_spawn_defenders_group1 (0.0 1.0 1.0) (-16 -16 0) (16 16 72)
 Team 4 players spawn at one of these positions at the start of a round.*/
 
 /*QUAKED mp_convoy_spawn_defenders_group2 (0.0 1.0 1.0) (-16 -16 0) (16 16 72)
 Team 5 players spawn at one of these positions at the start of a round.*/
 
 /*QUAKED mp_convoy_spawn_defenders_group3 (0.0 1.0 1.0) (-16 -16 0) (16 16 72)
 Team 6 players spawn at one of these positions at the start of a round.*/
 
 /*QUAKED mp_convoy_spawn_defenders_group4 (0.0 1.0 1.0) (-16 -16 0) (16 16 72)
 Team 7 players spawn at one of these positions at the start of a round.*/
 
 /*QUAKED mp_convoy_spawn_defenders_group5 (0.0 1.0 1.0) (-16 -16 0) (16 16 72)
 Team 8 players spawn at one of these positions at the start of a round.*/
 
 /*QUAKED mp_convoy_spawn_attackers_init (0.5 1.0 1.0) (-16 -16 0) (16 16 72)
 Players spawn away from enemies and near their team at one of these positions.*/
 
 /*QUAKED mp_convoy_spawn_defenders_init (0.5 1.0 1.0) (-16 -16 0) (16 16 72)
 Team 0 players spawn at one of these positions at the start of a round.*/
 
 //tagTMR<TODO>: Make these dvars or make them derrived from the size of the tank model
 TANK_TRIGGER_RADIUS=200;
 TANK_TRIGGER_HEIGHT=80;
 TANK_IDLE_TO_REVERSE_TIME_IN_SECONDS=7.0;
 TANK_STANDARD_SPEED=2;
 
 CONVOY_NUM_VEHICLES = 3;
 
 BOMB_SWITCH_TIME = 2.0;
 
 //TagZP<NOTE> use this to delay the next objective message so that it does not play right on top of the previous objective complete message
 CHECKPOINT_COMPLETE_GRACE_PERIOD=2.5;
 
 PATH_MARKER_PREFIX = "ugv_pathmarker_";
 
 MAX_ESCORT_CHECKPOINTS=5;
 
 BOMB_PATH_MARKER_MATERIAL = "compassping_bounty";
 
 //****************************************************************************
 //* CREATION DATE:  6/21/2011 4:19pm
 //* DESCRIPTION:    
 //****************************************************************************
 getentArray_and_assert( ent_name )
 {
 	object = getEntArray( ent_name, "targetname" );
 	AssertEX( object.size > 0 , "There is no entity for " + ent_name );
 	return object;
 } 
 
 //****************************************************************************
 //* CREATION DATE:  6/21/2011 4:09pm
 //* DESCRIPTION:    
 //****************************************************************************
 main()
 {
 	setDevDvar( "escortPlusDebug", 1 );
 
 	maps\mp\gametypes\_globallogic::init();
 	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
 	maps\mp\gametypes\_globallogic::SetupCallbacks();
 
 
 	// tagTMR<NOTE>: Keep in mind the values set here are fucking meaningless
 	registerRoundSwitchDvar( level._gameType, 3, 0, 9 );
 	registerTimeLimitDvar( level._gameType, 2.5, 0, 1440 );
 	registerScoreLimitDvar( level._gameType, 1, 0, 500 );
 	registerRoundLimitDvar( level._gameType, 0, 0, 12 );
 	registerWinLimitDvar( level._gameType, 4, 0, 12 );
 	registerNumLivesDvar( level._gameType, 1, 0, 10 );
 	registerHalfTimeDvar( level._gameType, 0, 0, 1 );
 	registerWatchDvarInt( "checktime", 1 );
 	registerWatchDvarInt( "countdown", 10 );
 	
 	level._mode_convoy = true;
 	level._teamBased = true;
 	level._scoreLimitOverride = true;
 	level._maintainScoresBetweenRounds = true;
 	//level._objectiveBased = true;  // tagTMR<NOTE>: Not sure if I want to use this
 	level._onPrecacheGameType = ::onPrecacheGameType;
 	level._onStartGameType = ::onStartGameType;
 	level._getSpawnPoint = ::getSpawnPoint;
 	level._initGametypeAwards = ::initGametypeAwards;
 	level._onTimeLimit = ::onTimeLimit;
 	level._onScoreLimit = ::onScoreLimit;
 	level._onSpawnPlayer = ::onSpawnPlayer;
 	level._onNormalDeath = ::onNormalDeath;
 	level._secondaryCountdown = getWatchedDvar( "countdown" );
 	level._showSpawnTimer = true;
 	level._negativeTime = 0;
 	level._alwaysResetKillstreaks = 1;
 	level._escortActiveCheckpoint = 0; // 0-4 because all levels will have 5 total checkpoints
 	level._escortActiveCheckpointForTimer = 0;
 	level._captureTime = 0;
 	level._captureTimeStamp = 0;
 	level._captureTeam = "none";
 
 	level._escortInboundCountDown = false;
 	level._escortInboundStartTime = -1;
 	level._escortInboundDuration = -1;
 	level._escortInboundMessage = &"MP_ESCORT_INBOUND";
 	
 	level._captureTextAttacker = &"MP_PLANTING_VIRUS";
 	level._captureTextDefender = &"MP_STOPING_VIRUS";
 	
 	//used to know weather or not there is an active countdown on screen. This is used to reset timers on players hud when they respawn
 	level._activeCountDown = false;
 
 	level._escortUGVModel = "nx_vehicle_escort_ugv_mp";
 	level._escortUGVTurretModel = "nx_vehicle_escort_ugv_main_turret";
 
 	level._escortUGVVehicleInfo = "nx_ugv_mp";
 	level._escortUGVTurretInfo = "nx_ugv_turret_mp";
 
 	level._escortTrophyReadyFx = loadfx( "nx/misc/nx_mp_green_steady_light" );
 	level._escortTrophyCooldownFx = loadfx( "nx/misc/nx_mp_red_blinking_light" );
 
 	// vehicle destruction FX
 	level._vehicleDestructionFX = loadFx( "explosions/helicopter_explosion_cobra_low" );
 	level._convoyExploadedVehicle = "nx_vehicle_escort_ugv_mp";
 
 	// icon refs
 	level._iconCapture["enemy"] = "nx_waypoint_capture_enemy";
 	level._iconCapture["friendly"] = "nx_waypoint_capture_friendly";
 	level._iconCapture["neutral"] = "nx_waypoint_capture_neutral";
 
 	level._iconDefend["friendly"] = "nx_waypoint_defend_friendly";
 	level._iconDefend["enemy"] = "nx_waypoint_defend_enemy";
 	level._iconDefend["neutral"] = "nx_waypoint_defend_neutral";
 
 	level._iconTank["friendly"] = "hud_minimap_ugv_green";
 	level._iconTank["enemy"] = "hud_minimap_ugv_red";
 	level._iconTank["neutral"] = "hud_minimap_ugv_neutral";
 
 	level._iconActivate["enemy"] = "nx_waypoint_activate_enemy";
 
 	game["dialog"]["gametype"] = "escort";
 
 	if ( getDvarInt( "g_hardcore" ) )
 		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
 	else if ( getDvarInt( "camera_thirdPerson" ) )
 		game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
 	else if ( getDvarInt( "scr_diehard" ) )
 		game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
 	else if (getDvarInt( "scr_" + level._gameType + "_promode" ) )
 		game["dialog"]["gametype"] = game["dialog"]["gametype"] + "_pro";
 
 	game["strings"]["extracted_escort_vehicle"] = &"MP_EXTRACTED_UGV";
 }
 
 //****************************************************************************
 //* CREATION DATE:  6/28/2011 3:30pm
 //* DESCRIPTION:    
 //****************************************************************************
 onPrecacheGameType()
 {
 	//precache vehicle and model
 	precacheVehicle( level._escortUGVVehicleInfo );
 	precacheTurret( level._escortUGVTurretInfo );
 	precacheModel( level._escortUGVModel );
 	precacheModel( level._escortUGVTurretModel );
 
 	//precache icons
 	precacheShader( level._iconCapture["enemy"] );
 	precacheShader( level._iconCapture["friendly"] );
 	precacheShader( level._iconCapture["neutral"] );
 	
 	precacheShader( level._iconDefend["friendly"] );
 	precacheShader( level._iconDefend["enemy"] );
 	precacheShader( level._iconDefend["neutral"] );
 
 	precacheShader( level._iconTank["friendly"] );
 	precacheShader( level._iconTank["enemy"] );
 	precacheShader( level._iconTank["neutral"] );
 
 	precacheShader( level._iconActivate["enemy"] );
 
 	precacheShader( BOMB_PATH_MARKER_MATERIAL );
 
 	// bombsite shaders
 	precacheShader("waypoint_defend_a");
 	precacheShader("waypoint_defuse_a");
 	precacheShader("waypoint_target_a");
 	precacheShader("waypoint_defend_b");
 	precacheShader("waypoint_defuse_b");
 	precacheShader("waypoint_target_b");
 	precacheShader("waypoint_bomb");
 
 
 	//precache strings
 	precachestring( &"MP_CAPTURING" );
 	precachestring( &"MP_LOSING_CONTROLS" );
 	precachestring( &"MP_DOOR_OPENING" );
 	precachestring( &"MP_DOOR_CLOSING" );
 	precachestring( &"MP_PLANTING_VIRUS" );
 	precachestring( &"MP_STOPING_VIRUS" );
 	precachestring( &"MP_ESCORT_INBOUND" );
 
 	precachestring( &"OBJECTIVES_UGVHH_A_OBJECTIVE01" );
 	precachestring( &"OBJECTIVES_UGVHH_A_OBJECTIVE02" );
 	precachestring( &"OBJECTIVES_UGVHH_A_OBJECTIVE03" );
 	precachestring( &"OBJECTIVES_UGVHH_A_OBJECTIVE04" );
 	precachestring( &"OBJECTIVES_UGVHH_A_OBJECTIVE05" );
 
 	precachestring( &"OBJECTIVES_UGVHH_D_OBJECTIVE01" );
 	precachestring( &"OBJECTIVES_UGVHH_D_OBJECTIVE02" );
 	precachestring( &"OBJECTIVES_UGVHH_D_OBJECTIVE03" );
 	precachestring( &"OBJECTIVES_UGVHH_D_OBJECTIVE04" );
 	precachestring( &"OBJECTIVES_UGVHH_D_OBJECTIVE05" );
 
 	//escort brief descriptions for the upper right hand corner element
 	precachestring( &"OBJECTIVES_ESC_A_PUSH" );
 	precachestring( &"OBJECTIVES_ESC_A_VIRUS" );
 	precachestring( &"OBJECTIVES_ESC_A_OPEN" );
 
 	precachestring( &"OBJECTIVES_ESC_D_PUSH" );
 	precachestring( &"OBJECTIVES_ESC_D_VIRUS" );
 	precachestring( &"OBJECTIVES_ESC_D_OPEN" );
 }
 
 //****************************************************************************
 //* CREATION DATE:  6/28/2011 3:30pm
 //* DESCRIPTION:    
 //****************************************************************************
 onStartGameType()
 {
 	//level._killstreakRewards = false;
 
 	if ( !isdefined( game["switchedsides"] ) )
 		game["switchedsides"] = false;
 
 	if ( !isdefined( game["original_defenders"] ) )
 		game["original_defenders"] = game["defenders"];
 
 	if ( game["switchedsides"] )
 	{
 		oldAttackers = game["attackers"];
 		oldDefenders = game["defenders"];
 		game["attackers"] = oldDefenders;
 		game["defenders"] = oldAttackers;
 	}
 
 	game["dialog"]["offense_obj"] = "off_1ststart";
 	game["dialog"]["defense_obj"] = "def_1ststart";
 
 	// Setup all game dialog.
 	setupVOSoundAliases();
 
 	// Set Scoring & stat vars.
 
 	// tagJWP<TODO> This evaluation will be meaningless since veryone gets the same score on the winning t
 	maps\mp\_awards::initStatAward( "convoyscore", 0, maps\mp\_awards::highestWins );
 	
 	//attacker points
 	maps\mp\gametypes\_rank::registerScoreInfo( "vehiclepastcheckpoint", 150 );		// score per vehicle past a checkpoint
 	maps\mp\gametypes\_rank::registerScoreInfo( "capturecheckpoint", 150 );			// score for each person on a team for capturing a checkpoint or "bomb" location
 	maps\mp\gametypes\_rank::registerScoreInfo( "capturecheckpointbonus", 100 );	// score for being the person to catpure or defust the bomb location
 	
 	//defender points
 	maps\mp\gametypes\_rank::registerScoreInfo( "vehicledestruction", 150 );		// score for destroying a vehicle
 	maps\mp\gametypes\_rank::registerScoreInfo( "missedcheckpoint", 300 );			// score for missing a checkpoint
 
 	setClientNameMode("auto_change");
 	
 	//tagTMR<TODO>: get these strings setup and precache in onPrecacheGameType()
 	setObjectiveScoreText( game["attackers"], &"OBJECTIVES_ESCORT_ATTACKER_SCORE" );
 	setObjectiveScoreText( game["defenders"], &"OBJECTIVES_ESCORT_DEFENDER_SCORE" );
 
 	fx = maps\mp\gametypes\_teams::getTeamFlagFX( game[ "defenders" ] );
 	level._fxid = loadfx( fx );
 
 	level._spawnMins = ( 0, 0, 0 );
 	level._spawnMaxs = ( 0, 0, 0 );
 
 	// Place spawn points for attackers & defenders at all checkpoints.  Note, no specific team checkpoints.
 	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_escort_spawn_attackers_group1" );
 	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_escort_spawn_attackers_group2" );
 	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_escort_spawn_attackers_group3" );
 	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_escort_spawn_attackers_group4" );
 	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_escort_spawn_attackers_group5" );
 	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_escort_spawn_defenders_group1" );
 	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_escort_spawn_defenders_group2" );
 	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_escort_spawn_defenders_group3" );
 	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_escort_spawn_defenders_group4" );
 	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_escort_spawn_defenders_group5" );
 	
 	level._mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level._spawnMins, level._spawnMaxs );
 	setMapCenter( level._mapCenter );
 
 	hideAllEscortPathMarkers();
 	
 	thread maps\mp\gametypes\_dev::init();
 	
 	allowed[0] = "convoy";
 	allowed[1] = "escortplus";
 
 	maps\mp\gametypes\_gameobjects::main(allowed);
 
 	thread missionScriptExec();
 	
 	// tagJWP<NOTE> There should be no overtime in this game mode
 	//level thread overtimewatcher();
 }
 
 overtimewatcher()
 {
 	level endon( "game_ended" );
 	for( ;; )
 	{
 		updateUIOvertime();
 		waitframe();
 	}
 }
 
 
 updateUIOvertime()
 {
 	timeLeft = maps\mp\gametypes\_gamelogic::getTimeRemaining();
 	if( timeLeft < 0 )
 	{
 		if( getDvarInt( "ui_overtime" ) == 0 )
 		{
 			setDvar( "ui_overtime", 1 );
 			foreach( player in level._players )
 			{
 				//tagZP<NOTE> adding extra hud message to make it even more obvious that the game has shifted into overtime.
 				player thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"]["overtime"], game["strings"]["overtime_hint"], undefined, (1, 0, 0), "mp_last_stand" );
 
 				playDialog( "ExtendedTime" );
 			}
 		}
 	}
 	else
 	{
 		if( getDvarInt( "ui_overtime" ) == 1 )
 		{
 			setDvar( "ui_overtime", 0 );
 		}
 	}
 }
 
 
 //****************************************************************************
 //* CREATION DATE:  6/28/2011 3:30pm
 //* DESCRIPTION:    
 //****************************************************************************
 setupVOSoundAliases()
 {
 	// the script generic_endGame dynamically sets the end round VO using the following sound aliases
 	//"off_losegame", "def_losegame";
 	//"off_tiegame", "def_tiegame";
 	//"off_wingame", "def_wingame";
 	
 	//plays for offence when they gain control of the UGV
 	game["dialog"]["off_ugvproximity"] = "off_ugvproximity";
 
 	game["dialog"]["off_checkpointreached"] = "off_wincheckpoint";
 	game["dialog"]["def_checkpointreached"] = "def_losecheckpoint";
 	
 	game["dialog"]["off_restartcheckpoint"] = "off_restartcheckpoint";
 	game["dialog"]["def_restartcheckpoint"] = "def_restartcheckpoint";
 	
 	game["dialog"]["off_UGVAtSecurityDoor"] = "off_ugvdoor";
 	game["dialog"]["def_UGVAtSecurityDoor"] = "def_ugv_door";
 	
 	game["dialog"]["off_UGVOnGround"] = "off_ugvlanded";
 	game["dialog"]["def_UGVOnGround"] = "def_ugv_drop";
 	
 	//game["dialog"]["off_defendersFinishClosingDoor"] = "TagZP<NOTE>: I do not see this in the list";
 	game["dialog"]["def_defendersFinishClosingDoor"] = "def_door_closed";
 
 	// tagZP<NOTE> there is some confusion here, these two events; Attackers Finish Opening Door and, push the UGV to the elevator are the exact same thing...
 	// I am removing the fnishOpening door event and using the push to the elevator event to play the dialogs.  Side note, the door open line contains the 
 	// attacker dialog we want, and the push to the elevator one contains the correct defender vo line...
 	
 	game["dialog"]["off_pushToTheElevator"] = "off_dooropen";		//using the pushtothe elevator event to invoke the dialogs.
 	game["dialog"]["def_pushToTheElevator"] = "def_elevobjective";  
 
 	game["dialog"]["off_UGVOnElevator"] = "off_ugvonelevator";
 	game["dialog"]["def_UGVOnElevator"] = "def_ugv_elevator";
 
 	game["dialog"]["off_UGVTopOfElevator"] = "off_elevatorstop";
 	game["dialog"]["def_UGVTopOfElevator"] = "def_elevator_stopped";
 	
 	game["dialog"]["off_attackersActivatedDoor"] = "off_activatedoor";
 	game["dialog"]["def_attackersActivatedDoor"] = "def_attk_door_controls";
 
 	game["dialog"]["off_defendersActivatedDoor"] = "off_doorclosing";
 	game["dialog"]["def_defendersActivatedDoor"] = "def_door_closing";
 
 	game["dialog"]["off_AttackersBeginCappingDomPoint"] = "off_begincapture";
 	game["dialog"]["def_AttackersBeginCappingDomPoint"] = "def_attk_capturing_first";
 
 	game["dialog"]["off_AttackersFinishCappingDomPoint"] = "off_capturedfirst";
 	game["dialog"]["def_AttackersFinishCappingDomPoint"] = "def_attk_captured_first";
 
 	game["dialog"]["off_ExtendedTime"] = "off_extendedtime";
 	game["dialog"]["def_ExtendedTime"] = "def_extendedtime";
 
 
 
 // 	game["dialog"]["off_winround"] = "off_attackwin";
 // 	game["dialog"]["off_loseround"] = "off_attacklose";
 // 	game["dialog"]["def_winround"] = "def_ugv_win";
 // 	game["dialog"]["def_loseround"] = "def_ugv_lose";
 
 	//turning these dialogs off for now, they dont really make sense in the attacker defender framework
 	game["dialog"]["lead_lost"] = "null";
 	game["dialog"]["lead_tied"] = "null";
 	game["dialog"]["lead_taken"] = "null";
 	game["dialog"]["last_alive"] = "null";
 
 	level._disableRoundSwitchVo = 1;
 }
 
 //Use this if you want to play a dialog after some amount of delay.
 waitAndPlayDialog( time, refstring )
 {
 	level endon( "game_end" );
 
 	wait( time );
 
 	playDialog( refstring );
 }
 
 //use this to play dialogs in UGV escort(plus) mode.
 playDialog( refstring, group )
 {	
 	if( !isDefined( group ))
 	{
 		group = "ugv_status";
 	}
 	
 	alias_off_reference = "off_" + refstring;
 	alias_def_reference = "def_" + refstring;
 	
 	if( isDefined( game["dialog"][alias_off_reference] ))
 	{
 		leaderDialog( alias_off_reference, game["attackers"], group );
 	}
 	/#
 	if( !isDefined( game["dialog"][alias_off_reference] ))
 	{
 		println( "warning dialog reference " + alias_off_reference + " could not be resolved.");
 	}
 	#/
 
 	if( isDefined( game["dialog"][alias_def_reference] ))
 	{
 		leaderDialog( alias_def_reference, game["defenders"], group );
 	}
 	/#
 	if( !isDefined( game["dialog"][alias_def_reference] ))
 	{
 		println( "warning dialog reference " + alias_def_reference + " could not be resolved.");
 	}
 	#/
 }
 
 
 
 //****************************************************************************
 //* CREATION DATE:  6/28/2011 3:30pm
 //* DESCRIPTION:    
 //****************************************************************************
 onSpawnPlayer()
 {
 	self clearLowerMessage( "escort_info" );
 	self clearLowerMessage( "door_info" );
 
 	self thread clearLowerMessagesOnDeath();
 
 	//handle game status text
 	self setupBriefHudObjectiveText();
 	
 }
 
 
 updateBriefHudObjectiveTextForAll()
 {
 	foreach( player in level._players )
 	{
 		player setupBriefHudObjectiveText();
 	}
 }
 
 setupBriefHudObjectiveText()
 {
 	if( isDefined( self._infoHudElem ))
 	{
 		self._infoHudElem destroy();
 	}
 	
 	item = undefined;
 	text_idx = level._escortActiveCheckpoint + 1;
 	
 	if ( self.pers["team"] == game["attackers"] )
 	{
 		if( isDefined( level._objective_brief_a ))
 		{
 			if( isDefined( level._objective_brief_a[text_idx] ))
 			{
 				item = newClientHudElem( self );
 				item SetText( level._objective_brief_a[text_idx] );
 				item.alpha = 1.0;
 			}
 		}
 	}
 	else
 	{
 		if( isDefined( level._objective_brief_d ))
 		{
 			if( isDefined( level._objective_brief_d[text_idx] ))
 			{
 				item = newClientHudElem( self );
 				item SetText( level._objective_brief_d[text_idx] );
 				item.alpha = 1.0;
 			}
 		}
 	}
 
 	if( isDefined( item ))
 	{
 		item.x = 0;
 		item.y = -7;
 		item.alignX = "right";
 		item.alignY = "top";
 		item.horzAlign = "right";
 		item.vertAlign = "top";
 		item.fontScale = 1.1;
 		item.hidewheninmenu = true;
 		self._infoHudElem = item;
 	}
 }
 
 clearLowerMessagesOnDeath()
 {
 	level endon( "game_end" );
 
 	self waittill( "death" );
 
 	self clearLowerMessage( "escort_info" );
 	self clearLowerMessage( "door_info" );
 	self clearLowerMessage( "escort_inbound_info" );
 
 	if( isDefined ( self._infoHudElem ))
 	{
 		self._infoHudElem Destroy();
 	}
 }
 
 //****************************************************************************
 //* CREATION DATE:  6/28/2011 3:30pm
 //* DESCRIPTION:  Handels bonus points for kills near the UGV
 //****************************************************************************
 onNormalDeath( victim, attacker, lifeId )
 {
 }
 
 
 
 //****************************************************************************
 //* CREATION DATE:  6/30/2011 9:29am
 //* DESCRIPTION:    
 //****************************************************************************
 missionScriptExec()
 {
 	objective = 0;
 
 	rv = true;
 	while ( rv )
 	{
 		if ( isDefined( level._missionScript ) )
 		{
 			rv = [[level._missionScript]]( objective );
 		}
 		else
 		{
 			rv = defaultMissionScript( objective );
 		}
 		if ( ( rv == true ) && ( objective > 0 ) )
 		{
 			objectiveAchieved( game["attackers"] );
 			level._escortActiveCheckpoint++;
 			level._escortActiveCheckpointForTimer++;
 			updateBriefHudObjectiveTextForAll();
 		}
 		objective++;
 		if ( ( rv == true ) && ( objective > 1 ) )
 		{
 			level thread objectiveDisplayText( objective );
 		}
 	}
 	// End the game.
 	[[level._onScoreLimit]]();
 }
 
 //****************************************************************************
 //* CREATION DATE:  6/29/2011 11:30am
 //* DESCRIPTION:    
 //****************************************************************************
 objectiveAchieved( team )
 {
 	type = [[level._missionType]](level._escortActiveCheckpoint + 1 );
 	
 	if( type != "null" )
 	{
 		maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( team, level._convoyVehicles.size );
 	}
 
 	foreach ( player in level._players )
 	{
 		if ( player.pers["team"] == team )
 		{
 			player incPersStat( "checkpoints", level._convoyVehicles.size );
 			player.checkpoints = player getPersStat( "checkpoints" );
 			player incPlayerStat( "checkpoints", level._convoyVehicles.size );
 		}
 	}
 
 	//If the attacking team scores more than the previous attacking team they win the game.
 	if ( game["roundsPlayed"] > 0 )
 	{
 		// We're in the 2nd half.  If we have more points than the other team, end the game.
 		if ( maps\mp\gametypes\_gamescore::getWinningTeam() == team )
 		{
 			[[level._onScoreLimit]]();
 		}
 	}
 
 	
 //	println( ">>>>>>>>>>>>>>>>>>>>>>>>>>>> Rounds played: " + game["roundsPlayed"] );
 }
 
 //****************************************************************************
 //* CREATION DATE:  6/30/2011 5:26pm
 //* DESCRIPTION:    
 //****************************************************************************
 objectiveSetText( objective, attack, defend, attack_hint, defend_hint )
 {
 	level._objective_a[objective] = attack;
 	level._objective_d[objective] = defend;
 	precacheString( attack );
 	precacheString( defend );
 
 	if ( objective == 1 )
 	{
 		if ( isDefined( attack_hint ) )
 		{
 			// Full set.
 			setObjectiveText( game["attackers"], attack );
 			setObjectiveText( game["defenders"], defend );
 			setObjectiveHintText( game["attackers"], attack_hint );
 			setObjectiveHintText( game["defenders"], defend_hint );
 		}
 		else
 		{
 			// Only 2 defined, repeat.
 			setObjectiveText( game["attackers"], attack );
 			setObjectiveText( game["defenders"], defend );
 			setObjectiveHintText( game["attackers"], attack );
 			setObjectiveHintText( game["defenders"], defend );
 		}
 	}
 }
 
 objectiveSetBriefText( objective, attack, defend )
 {	
 	level._objective_brief_a[objective] = attack;
 	level._objective_brief_d[objective] = defend;
 }
 
 objectiveDisplayText( objective )
 {
 	level endon( "game_ended" );
 
 	wait( CHECKPOINT_COMPLETE_GRACE_PERIOD );
 	
 	game[ "strings" ][ "objective_" + game["attackers"] ] = level._objective_a[objective];
 	game[ "strings" ][ "objective_" + game["defenders"] ] = level._objective_d[objective];
 	game[ "strings" ][ "objective_hint_" + game["attackers"] ] = level._objective_a[objective];
 	game[ "strings" ][ "objective_hint_" + game["defenders"] ] = level._objective_d[objective];
 
 	if ( objective != 0 )
 	{
 		for ( index = 0; index < level._players.size; index++ )
 		{
 			hintMessage = getObjectiveHintText( level._players[index].pers["team"] );
 			if ( isDefined( hintMessage ) )
 			{
 				level._players[index] setClientDvar( "scr_objectiveText", hintMessage );
 				level._players[index] thread maps\mp\gametypes\_hud_message::hintMessage( hintMessage );
 			}
 		}
 	}
 }
 
 //****************************************************************************
 //* CREATION DATE:  6/28/2011 3:30pm
 //* DESCRIPTION:    
 //****************************************************************************
 defaultMissionScript( objective )
 {
 	rv = true;
 	switch( objective )
 	{
 		case 0:
 			// If you get this, your level does not have a mission script defined.  Please define one.
 			wait 20.0;
 			foreach ( player in level._players )
 			{
 				player setLowerMessage( "escort_info", "Default mission script - exiting in:", 10.0, 1, true );
 			}
 			wait 10.0;
 			break; 
 		case 1:
 			rv = false;
 			break; 
 		default:
 			rv = false;
 			break; 
 	}
 	return rv;
 }
 
 //****************************************************************************
 //* CREATION DATE:  6/28/2011 3:35pm
 //* DESCRIPTION:    Creates the escort vehicle.
 //****************************************************************************
 objectiveCreateConvoy( numVehicles )
 {
 	println( "Convoy: objectiveCreateConvoy()" );
 
 	tankSpawners = Vehicle_GetSpawnerArray();
 	assertEx( tankSpawners.size > 1, "There are no tank spawners on this map!  UGV Escort game mode is impossible");
 	
 	playDialog( "UGVOnGround" );
 	
 	if ( level._splitScreen )
 		hudElemAlpha = 0;
 	else
 		hudElemAlpha = 0.85;
 
 	convoyOrigin = GetVehicleNodeArray( "convoyorigin", "script_noteworthy" );
 
 	level._currentConvyPathNode = convoyOrigin[0];
 
 	assertEx( convoyOrigin.size == 1, "There appears to be no convoyOrigin node.  Set the first non UGV node to have script_noteworthy set to convoyorigin" );
 
 	level._ugvstartnodes = GetVehicleNodeArray( "convoystartnode", "script_noteworthy" );
 
 	level._ugvstartnodes = SortByDistance( level._ugvstartnodes, convoyOrigin[0].origin );
 
 	level._vehicleExplodeMoveNodes = GetEntArray( "bombnode_a_move", "targetname" );
 	b_move = GetEntArray( "bombnode_b_move", "targetname" );
 
 	foreach( node in b_move )
 	{
 		level._vehicleExplodeMoveNodes[level._vehicleExplodeMoveNodes.size] = node;
 	}
 
 	level._convoyVehicles = [];
 
 	// tagJWP<TODO> Choose the vehicle spawners correctly...
 	for( i = 0; i < numVehicles; i++ )
 	{
 		spawnerName = "convoy_spawn_" + (i+1);
 		useSpawner = undefined;
 		foreach( spawner in tankSpawners )
 		{
 			if( isDefined( spawner.script_linkname ) && isSubStr( spawner.script_linkname, spawnerName ))
 			{
 				useSpawner = spawner;
 				break;
 			}
 		}
 
 		if( !isDefined( useSpawner ))
 		{
 			assertmsg( "Convoy: Could not find spawner named: " + spawnerName );
 		}
 
 		println( tankSpawners[i].script_linkname );
 		vehicle = createEscortVehicle( useSpawner );
 		startNode = level._ugvstartnodes[i];
 		vehicle.origin = startNode.origin;
 		//startNode = startNodeArray[0];
 		vehicle attachPath( startNode );
 		
 		// attach the vehicle to tha path and setup the mechanism for seamlessly attaching to the next path when the time comes
 		vehicle thread vehicleReachCheckpointSapwned();
 		level._convoyVehicles[level._convoyVehicles.size] = vehicle;
 	}
 }
 
 
 handleTeamTrophyEffects()
 {
 	level endon( "game_ended" );
 	self endon( "death" );
 	
 	for( ;; )
 	{
 		self waittill( "ownership_changed" );
 
 		//clear out any fx that might be playing
 		stopfxontag( level._escortTrophyReadyFx, self, "tag_front_cam_fx", true );
 		stopfxontag( level._escortTrophyReadyFx, self, "tag_back_cam_fx", true );
 
 		stopfxontag( level._escortTrophyCooldownFx, self, "tag_front_cam_fx" );
 		stopfxontag( level._escortTrophyCooldownFx, self, "tag_back_cam_fx" );
 		
 		//trophy is disabled so long at no team owns the ugv
 		if( self.curr_owner == "neutral" )
 		{
 			continue;	
 		}
 		else
 		{
 			//wait one frame since the notify that triggered this is the same one that kills handleTrophyEffects();
 			waitframe();
 			self thread handleTrophyEffects();
 
 		}
 	}
 }
 
 handleTrophyEffects()
 {
 	self endon( "death" );
 	self endon( "ownership_changed" );
 	level endon( "game_ended" );
 	
 	for(;;)
 	{
 		playFXonTag( level._escortTrophyReadyFx, self, "tag_front_cam_fx" );
 		playFXonTag( level._escortTrophyReadyFx, self, "tag_back_cam_fx" );
 		
 		self waittill( "trophy_kill_projectile", reload_time );
 		
 		//TagZP<NOTE> - yeah, gotta turn this off for now, that sound is just too strange/annoying, but thanks for getting something temp in so quickly
 		//will uncomment when we get a better sound
 		//self PlaySound( "mp_ugv_trophy_fire" );
 		
 		stopfxontag( level._escortTrophyReadyFx, self, "tag_front_cam_fx", true );
 		stopfxontag( level._escortTrophyReadyFx, self, "tag_back_cam_fx", true );
 
 		playfxontag( level._escortTrophyCooldownFx, self, "tag_front_cam_fx" );
 		playfxontag( level._escortTrophyCooldownFx, self, "tag_back_cam_fx" );
 
 		wait( reload_time );
 
 		self PlaySound( "mp_ugv_trophy_reloaded" );
 
 		stopfxontag( level._escortTrophyCooldownFx, self, "tag_front_cam_fx" );
 		stopfxontag( level._escortTrophyCooldownFx, self, "tag_back_cam_fx" );
 	}
 }
 
 hideAllEscortPathMarkers()
 {
 	for( i = 0; i < MAX_ESCORT_CHECKPOINTS; i++ )
 	{
 		index = i+1;
 		name = PATH_MARKER_PREFIX + index;
 		pathmodels = GetEntArray( name, "targetname" );
 
 		if( pathmodels.size > 0 )
 		{
 			foreach( model in pathmodels )
 			{
 				model hide();
 			}
 		}
 	}
 }
 
 showEscortPathMarker( index )
 {
 	name = PATH_MARKER_PREFIX + index;
 	pathmodels = GetEntArray( name, "targetname" );
 
 	if( pathmodels.size > 0 )
 	{
 		foreach( model in pathmodels )
 		{
 			model show();
 		}
 	}
 }
 
 hideEscortPathMarker( index )
 {
 	name = PATH_MARKER_PREFIX + index;
 	pathmodels = GetEntArray( name, "targetname" );
 
 	if( pathmodels.size > 0 )
 	{
 		foreach( model in pathmodels )
 		{
 			model hide();
 		}
 	}
 }
 
 //****************************************************************************
 //* CREATION DATE:  6/28/2011 3:30pm
 //* DESCRIPTION:    Objective requiring the attackers to escort the UGV to the end of the path.
 //****************************************************************************
 objectiveEscortToCheckPoint( convoySpeed, voRefString )
 {
 	println( "Convoy: objectiveEscortToCheckPoint()" );	
 	//play any specified VO
 	if( isDefined( voRefString ))
 	{
 		playDialog( voRefString );
 	}
 
 	if( !isDefined( convoySpeed ))
 	{
 		convoySpeed = TANK_STANDARD_SPEED;
 	}
 
 	// tagJWP<TODO> Fix the bomb explode logic
 	level thread prepareBombSite( "a", level._escortActiveCheckpoint + 1);
 	level thread prepareBombSite( "b", level._escortActiveCheckpoint + 1);
 
 	// show the path
 	showEscortPathMarker( level._escortActiveCheckpoint + 1 ); 
 	
 	if( isDefined( level._currentConvyPathNode ))
 	{
 		CreateCheckpointNodeForPath( level._currentConvyPathNode );
 		level._currentConvyPathNode.checkpointObject ActivateCheckpoint();
 
 		placeRoadBombMarkers( level._currentConvyPathNode );
 	}
 	else
 	{
 		assertMsg( "Convoy: level._currentConvyPathNode not set properly!" );
 	}
 
 	setConvoySpeed( level._convoyVehicles, convoySpeed );
 
 	level waittill( "checkpoint_reached", endnode );
 	level._currentConvyPathNode.checkpointObject DeactivateCheckpoint();
 
 	// turn off the path
 	hideEscortPathMarker( level._escortActiveCheckpoint + 1 );
 	
 	// queue up the next node in the path
 	nextPath = maps\mp\killstreaks\_tank::getNearestUGVNode( endnode.origin, level._ugvstartnodes );
 	// let the main control flow know what the next node is
 	level._currentConvyPathNode = nextPath;
 
 	setConvoySpeed( level._convoyVehicles, 0 );
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 placeRoadBombMarkers( startNode )
 {
 	node = startNode;
 	while( IsDefined( node ))
 	{
 		if( isDefined( node.script_noteworthy ) && ( node.script_noteworthy == "bombnode_a" || node.script_noteworthy == "bombnode_b" ))
 		{
 			node thread createRaodBombMarker( node );
 		}
 
 		if( !IsDefined( node.target ))
 		{
 			node = undefined;
 		}
 		else
 		{
 			node = GetVehicleNode( node.target, "targetname" );
 		}
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 createRaodBombMarker( node )
 {
 	println( "Convoy: createRoadBombMarker()" );
 	visuals = [];
 
 	checkpointTrigger = spawn( "trigger_radius", node.origin, 0, 1.0, 1.0 );
 	checkpointTrigger.radius = 1.0;
 
 	bombMarker = maps\mp\gametypes\_gameobjects::createUseObject( game["defenders"], checkpointTrigger, visuals, (0,0,64) );
 	bombMarker maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
 
 	bombMarker maps\mp\gametypes\_gameobjects::allowUse( "none" );
 	bombMarker maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", BOMB_PATH_MARKER_MATERIAL );
 	bombMarker maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", BOMB_PATH_MARKER_MATERIAL );
 	
 	level waittill( "cross_" + self.script_noteworthy );
 
 	bombMarker maps\mp\gametypes\_gameobjects::deleteUseObject();
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 prepareBombSite( label, checkpoint )
 {
 	level endon( "checkpoint_reached" );
 	
 	bombname = "bombnode_" + label;
 	bombTriggerName = "convoy_" + bombName + "_" + checkpoint;
 	bombTrigger = getEnt( bombTriggerName, "targetname" );
 
 	if( isDefined( bombTrigger ))
 	{
 		bombTrigger.useObject = createBombZone( bombTrigger, label );
 
 		if( isDefined( bombTrigger.useObject ))
 		{
 			bombTrigger thread waitCleanupBombZone();
 
 			level waittill( "cross_" + bombName, vehicle );
 	
 			if( bombTrigger.useObject.armed )
 			{
 				println( "Convoy: Kaboom at " + bombName );
 
 				foreach ( player in level._players )
 				{
 					if ( player.pers["team"] == game["defenders"] )
 					{
 						points = maps\mp\gametypes\_rank::getScoreInfoValue( "vehicledestruction" );
 						maps\mp\gametypes\_gamescore::givePlayerScore( "vehicledestruction", player );	
 					}
 				}
 
 				explodeVehicle( vehicle );
 
 				level thread waitCheckGameEnd();
 
 			}
 			else
 			{
 				println( "Convoy: Fizzle at " + bombName );
 			}
 			bombTrigger notify( "bombzone_used" );
 			bombTrigger.useObject maps\mp\gametypes\_gameobjects::deleteUseObject();
 		}
 		else
 		{
 			println( "Error Convoy: could not create bombzone" );
 		}
 	}
 	else
 	{
 		println( "Error Could not find bomb trigger ent! name = " + bombTriggerName );
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 waitCheckGameEnd()
 {
 	if( level._convoyVehicles.size == 0 )
 	{
 		wait 5.0;
 		[[level._onTimelimit]]();
 /*		if ( isDefined( game["switchedsides"] ) && game["switchedsides"] )
 		{
 			[[level._onTimelimit]]();
 		}
 		else
 		{
 			thread maps\mp\gametypes\_gamelogic::endGameHalfTime();
 		}*/
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 explodeVehicle( vehicle )
 {
 	// explode the vehicle
 	upAngles = AnglesToUP( vehicle.angles );
 	playFx( level._vehicleDestructionFX, vehicle.origin, upAngles );
 
 // 	tagJWP<NOTE> Vehicle hulc not used in favor of destructable vehicle for now
 //	vehicleHulc = spawn( "script_model", vehicle.origin );
 //	vehicleHulc setModel( level._convoyExploadedVehicle );
 //	vehicleHulc.angles = vehicle.angles;
 
 //	vehicleHulc CloneBrushmodelToScriptmodel( level._airDropCrateCollision );
 
 	// find the resting spot and move the destroyed model to it
 	moveToNode = maps\mp\killstreaks\_tank::getNearestUGVNode( vehicle.origin, level._vehicleExplodeMoveNodes );
 
 	trace = bullettrace( moveToNode.origin + (0,0,128), moveToNode.origin - (0,0,2000), false, undefined );
 	restingPos = trace[ "position" ];
 
 	println( "Convoy: Finding destructable " + vehicle.script_noteworthy + " for " + vehicle.script_linkname );
 	hummer = getEntArray( vehicle.script_noteworthy, "script_linkname" );
 
 	if( hummer.size == 0 )
 	{
 		println( "Convoy: could not find destructable, the destructable should have its 'script_linkname' set to " + vehicle.script_noteworthy );
 	}
 
 	foreach( ent in hummer )
 	{
 		ent notify( "damage", 10000, undefined, undefined, undefined, "unknown", undefined, undefined, undefined, undefined );
 		ent.origin = vehicle.origin;
 		ent.angles = vehicle.angles;
 		ent moveTo( restingPos, 0.1, 0.01, 0.01 );
 	}
 
 	//wait 0.05;
 	// tagJWP<NOTE> physicsLuanchServer fails for an unspecified error, my have something to do with using the collision for the airdrop container?
 	//vehicleHulc PhysicsLaunchServer( (0,0,0), (randomInt(5),randomInt(5),randomInt(5)) );
 
 	// damage everything
 	RadiusDamage( vehicle.origin + (0,0,10), 240, 5000, 1000, undefined, "MOD_UNKNOWN" );
 
 	vehicle delete();
 
 	level._convoyVehicles = array_removeUndefined( level._convoyVehicles );
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 waitCleanupBombZone()
 {
 	self waittill( "bombzone_used" );
 	visualsOrigin = self.origin;
 	visualsAngles = self.angles;
 
 	// tagJWP<TODO> need a proper bone and effect to play on the bombsite
 	playFx( getFx( "sentry_explode_mp" ), visualsOrigin + (0,0,35), AnglesToUp( visualsAngles ) );
 	wait ( 1.5 );		
 	self playSound( "sentry_explode_smoke" );
 	for ( smokeTime = 8; smokeTime > 0; smokeTime -= 0.4 )
 	{
 		playFx( getFx( "sentry_smoke_mp" ), visualsOrigin + (0,0,35), AnglesToUp( visualsAngles ) );
 		wait ( 0.4 );
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 createBombZone( triggerBox, label )
 {
 	bombZone = undefined;
 
 	if( !isDefined( triggerBox.target ))
 	{
 		assertmsg( "TagergetName " + triggerBox.targetname + " is missing target" );
 	}
 	visuals = getEntArray( triggerBox.target, "targetname" );
 
 	if( visuals.size > 0 )
 	{
 		bombZone = maps\mp\gametypes\_gameobjects::createUseObject( game["defenders"], triggerBox, visuals, (0,0,64) );
 		bombZone maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
 		bombZone.label = label;
 		bombZone disarmBombsite();
 
 		bombZone.onBeginUse = ::onBeginUse;
 		bombZone.onEndUse = ::onEndUse;
 		bombZone.onUse = ::onUseObject;
 		bombZone.onCantUse = ::onCantUse;
 		bombZone.useWeapon = "briefcase_bomb_mp";
 
 
 //		bombZone.onUse = ::onBombzoneUse;	
 
 	}
 	else
 	{
 		println( "Error Convoy: No visuals defined! target = " + triggerBox.target + " on  targetName " + triggerBox.targetName );
 	}
 	
 	return bombZone;
 }
 
 onUseObject( player )
 {
 	team = player.pers["team"];
 	otherTeam = level._otherTeam[team];
 
 	if ( self maps\mp\gametypes\_gameobjects::isFriendlyTeam( player.pers["team"] ) )
 	{
 //		player notify ( "bomb_planted" );
 		player playSound( "mp_bomb_plant" );
 
 //		thread teamPlayerCardSplash( "callout_bombplanted", player );
 //		iPrintLn( &"MP_EXPLOSIVES_PLANTED_BY", player );
 //		leaderDialog( "bomb_planted" );
 
 //		player thread maps\mp\gametypes\_hud_message::SplashNotify( "plant", maps\mp\gametypes\_rank::getScoreInfoValue( "plant" ) );
 //		player thread maps\mp\gametypes\_rank::giveRankXP( "plant" );
 //		maps\mp\gametypes\_gamescore::givePlayerScore( "plant", player );		
 //		player incPlayerStat( "bombsplanted", 1 );
 //		player thread maps\mp\_matchdata::logGameEvent( "plant", player.origin );
 
 
 		self.useWeapon = "briefcase_bomb_defuse_mp";
 		println( "Convoy: arming the bomb!" );
 		self armBombsite();
 	}
 	else // defused the bomb
 	{
 		println( "Convoy: disarming the bomb!" );
 		self disarmBombsite();
 	}
 }
 
 onBeginUse( player )
 {
 	if ( self maps\mp\gametypes\_gameobjects::isFriendlyTeam( player.pers["team"] ) )
 	{
 		player playSound( "mp_bomb_defuse" );
 	}
 	else
 	{
 	}
 }
 
 onEndUse( team, player, result )
 {
 }
 
 onCantUse( player )
 {
 	player iPrintLnBold( &"MP_BOMBSITE_IN_USE" );
 }
 
 onReset()
 {
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 disarmBombsite()
 {
 	self maps\mp\gametypes\_gameobjects::allowUse( "friendly" );
 	self maps\mp\gametypes\_gameobjects::setUseTime( BOMB_SWITCH_TIME );
 	self maps\mp\gametypes\_gameobjects::setUseText( &"MP_PLANTING_EXPLOSIVE" );
 	self maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_PLANT_EXPLOSIVES" );
 	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_target_" + self.label );
 	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_target_" + self.label );
 	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_defend_" + self.label );
 	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_defend_" + self.label );
 	self.useWeapon = "briefcase_bomb_mp";
 	self.armed = false;
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 armBombsite()
 {
 	self maps\mp\gametypes\_gameobjects::allowUse( "enemy" );
 	self maps\mp\gametypes\_gameobjects::setUseTime( BOMB_SWITCH_TIME );
 	self maps\mp\gametypes\_gameobjects::setUseText( &"MP_DEFUSING_EXPLOSIVE" );
 	self maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
 	self maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_defend_" + self.label );
 	self maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defend_" + self.label );
 	self maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_defuse_" + self.label );
 	self maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_defuse_" + self.label );
 	self.armed = true;
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 onBombzoneUse( player )
 {
 	println( "Convoy: onBombZoneUse()" );
 	// planted the bomb
 	if ( self maps\mp\gametypes\_gameobjects::isFriendlyTeam( player.pers["team"] ) )
 	{
 		println( "Convoy: armBombsite() label = " + self.label );
 		self armBombsite();
 	}
 	else // defused the bomb
 	{
 		println( "Convoy: disarmBombsite() label = " + self.label );
 		self disarmBombsite();
 	}
 }
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 setBombLocationSpawned( startNode )
 {
 	// don't process bomb checkpoints once we setBombLocationSpawned the end of the path!
 	level endon( "checkpoint_reached" );
 	 
 	// walk the path till we get to a bomb location
 	node = startNode;
 	while( IsDefined( node ))
 	{
 		if( isDefined( node.script_noteworthy ) && ( node.script_noteworthy == "bombnode_a"|| node.script_noteworthy == "bombnode_b" ) )
 		{
 			node waittillmatch( "trigger", self );
 			// check to see if we should explode
 			println( "Convoy: crossing bombsite  " + node.script_noteworthy );
 			level notify( "cross_" + node.script_noteworthy, self );
 		}
 		if( isDefined( node.target ))
 		{
 			temp = GetVehicleNode( node.target, "targetname" );
 			node=temp;
 		}
 		else
 		{
 			node = undefined;
 		}
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 vehicleReachCheckpointSapwned()
 {
 
 	while( level._inGracePeriod )
 	{
 		waitframe();
 	}
 
 	// Start escort loop!
 	while ( 1 )
 	{
 		// find new nodes and continue
 		startNode = maps\mp\killstreaks\_tank::getNearestUGVNode( self.origin, level._ugvstartnodes );
 		self startPath( startNode );
 		
 		// walk the nodes to the first bomb on the path
 		self thread setBombLocationSpawned( startNode );
 
 		self waittill( "reached_end_node", endnode );
 
 		println("Convoy: Vehicle reached checkpoint");
 
 		assert( isDefined( endnode ));
 			
 		if( !isDefined( endnode._convoyPassed ))
 		{
 			endnode._convoyPassed = true;
 
 			println( "Convoy: Processing checkpoint" );
 
 			//award points to each attacker ( attackers next to the UGV get a bonus
 			foreach ( player in level._players )
 			{
 				if ( player.pers["team"] == game["attackers"] )
 				{
 					points = maps\mp\gametypes\_rank::getScoreInfoValue( "vehiclepastcheckpoint" );
 					foreach( vehicle in level._convoyVehicles )
 					{
 						maps\mp\gametypes\_gamescore::givePlayerScore( "vehiclepastcheckpoint", player );
 					}
 				}
 			}
 
 			PlayDialog( "checkpointreached" );
 
 //			hideEscortPathMarker( level._escortActiveCheckpoint + 1 );
 //			startNode.checkpointObject DeactivateCheckpoint();
 			level._timeLimitOverride = false;
 			
 			//HIDE UGV HEAD ICONS
 			if( isDefined( self.defendersObjPoint ))
 			{
 				self.defendersObjPoint.alpha = 0.0;
 				self.attackersObjPoint.alpha = 0.0;
 			}
 			
 			level notify( "checkpoint_reached", endnode );
 		}
 	}
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 CreateCheckpointNodeForPath( firstStartNode )
 {
 
 	node = firstStartNode;
 	while( IsDefined( node ))
 	{
 		if( !IsDefined( node.target ))
 		{
 			firstStartNode.checkpointObject = CreateCheckpointNode( node );
 			break;
 		}
 
 		temp = GetVehicleNode( node.target, "targetname" );
 		node=temp;
 	}
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 CreateCheckpointNode( node )
 {
 	println( "Convoy: Creating convoy node FX" );
 	checkpointTrigger = spawn( "trigger_radius", node.origin, 0, 1.0, 1.0 );
 	checkpointTrigger.radius = 1.0;
 
 	visuals = [];
 	gameobjectCheckpoint = maps\mp\gametypes\_gameobjects::createUseObject( game[ "attackers" ], checkpointTrigger, visuals, (0,0,0) );
 	gameobjectCheckpoint maps\mp\gametypes\_gameobjects::allowUse( "none" );
 	gameobjectCheckpoint maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
 	
 	//Create the MINI map and Capture point ICONS.  For now do not create the 3D icon, it only seems to confuse things.
 	//gameobjectCheckpoint maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", level._iconDefend["neutral"] );
 	//gameobjectCheckpoint maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", level._iconDefend["neutral"] );
 	
 	//gameobjectCheckpoint maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level._iconCapture["neutral"] );
 	//gameobjectCheckpoint maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level._iconCapture["neutral"] );
 
 	gameobjectCheckpoint maps\mp\gametypes\_gameobjects::setUseTime( 0 );
 
 	SpawnCheckpointFX( gameobjectCheckpoint );
 
 	return gameobjectCheckpoint;
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 SpawnCheckpointFX( gameobjectCheckpoint )
 {
 	traceStart = gameobjectCheckpoint.curOrigin + (0,0,128);
 	traceEnd = gameobjectCheckpoint.curOrigin  + (0,0,-128);
 
 	trace = bulletTrace( traceStart, traceEnd, false, undefined );
 	
 	upangles = vectorToAngles( trace["normal"] );
 	forward = anglesToForward( upangles );
 	right = anglesToRight( upangles );
 	
 	thread spawnFxDelay( level._fxid, trace["position"], forward, right, 0.5 );
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 ActivateCheckpoint()
 {
 	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 DeactivateCheckpoint()
 {
 	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 spawnFxDelay( fxid, pos, forward, right, delay )
 {
 	wait delay;
 	effect = spawnFx( fxid, pos, forward, right );
 	triggerFx( effect );
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 generic_endGame( reason )
 {
 
 	assert( isDefined( game["strings"][reason] ));
 	
 	text = game["strings"][reason];
 
 	// Set dialog based on teams.
 	winner = undefined;
 	if( game["teamScores"][game["attackers"]] > game["teamScores"][game["defenders"]] )
 	{
 		// Allies winning.
 		game["dialog"]["round_success"] = "off_wingame";
 		game["dialog"]["round_failure"] = "def_losegame";
 		winner = game["attackers"];
 	}
 	else if( game["teamScores"][game["defenders"]] > game["teamScores"][game["attackers"]] )
 	{
 		// Axis winning.
 		game["dialog"]["round_success"] = "def_wingame";
 		game["dialog"]["round_failure"] = "off_losegame";
 		winner = game["defenders"];
 	}
 	else if( game["teamScores"][game["attackers"]] == game["teamScores"][game["defenders"]] )
 	{
 		game["dialog"]["round_draw"] = "off_tiegame";
 		winner = "tie";
 	}
 
 	thread maps\mp\gametypes\_gamelogic::endGame( winner, text );
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 onTimeLimit()
 {
 	assert( isDefined( level._missionType ));
 	//award defenders for each checkpoint that was not completed by the attackers.
 	foreach ( player in level._players )
 	{
 		if ( player.pers["team"] == game["defenders"] )
 		{
 			for( i = level._escortActiveCheckpoint + 1; i < ( MAX_ESCORT_CHECKPOINTS + 1 ); i++ )
 			{
 				type = "null";
 				type = [[level._missionType]]( i );
 
 				switch( type )
 				{
 					case "capture":
 						println( "award pts for a cap checkpt" );
 						maps\mp\gametypes\_gamescore::givePlayerScore( "missedcapture", player );
 						break;
 					case "escort":
 						println( "award pts for a escort checkpt" );
 						maps\mp\gametypes\_gamescore::givePlayerScore( "missedcheckpoint", player );
 						break;
 					case "open":
 						println( "award pts for a open checkpt" );
 						maps\mp\gametypes\_gamescore::givePlayerScore( "misseddoor", player );
 						break;
 				}
 			}
 		}
 	}
 
 	generic_endGame( "time_limit_reached" );
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 onScoreLimit()
 {
 	generic_endGame( "score_limit_reached" );
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 createEscortVehicle( spawner )
 {
 	tank = spawner spawnEscortTank( game["attackers"] );
 	
 	tank.nodes = GetVehicleNodeArray( "info_vehicle_node", "classname" );
 
 	tank thread maps\mp\_mp_trophy_turret::trophy_turret_update();
 
 	tank thread handleTeamTrophyEffects();
 
 	tank createConvoyVehicleObjectives();
 
 	tank.curr_owner = "attackers";
 
 	return tank;
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 createConvoyVehicleObjectives()
 {
 	self.objIdAttackers = maps\mp\gametypes\_gameobjects::getNextObjID();
 	objective_add( self.objIdAttackers, "invisible", (0,0,0) );
 
 	//removed mini map icon from the vehicle def, using these insted since the vehicle def does not support neutral colors, nor does it handle team changing very easily.
 	objective_position( self.objIdAttackers, self.origin );
 	objective_icon( self.objIdAttackers, level._iconTank["friendly"] );
 	objective_team( self.objIdAttackers, game["attackers"] );
 	objective_state( self.objIdAttackers, "active" );
 
 	self.objIdDefenders = maps\mp\gametypes\_gameobjects::getNextObjID();
 	objective_add( self.objIdDefenders, "invisible", (0,0,0) );
 
 	//removed mini map icon from the vehicle def, using these insted since the vehicle def does not support neutral colors, nor does it handle team changing very easily.
 	objective_position( self.objIdDefenders, self.origin );
 	objective_icon( self.objIdDefenders, level._iconTank["enemy"] );
 	objective_team( self.objIdDefenders, game["defenders"] );
 	objective_state( self.objIdDefenders, "active" );
 	
 	objective_onentity( self.objIdAttackers, self );
 	objective_onentity( self.objIdDefenders, self );
 
 	self.curr_owner = "neutral";
 	self thread MonitorTankObjectiveIcons();
 	self thread WaitCleanupTankObjectiveIcons();
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 
 WaitCleanupTankObjectiveIcons()
 {
 	self waittill( "death" );
 	objective_delete( self.objIdAttackers );
 	objective_delete( self.objIdDefenders );
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 //This script refreshed Head icons for the UGV when it is notified.
 MonitorTankObjectiveIcons()
 {
 	self endon( "death" );
 
 	for( ;; )
 	{
 		self waittill( "update_ugv_status_icons" );
 		//println( "updating ugv status icons" );
 		
 		if( isDefined( self.curr_owner ))
 		{	
 			if( self.curr_owner == "attackers" )
 			{
 				//println( "attacker owned" );
 				objective_icon( self.objIdAttackers, level._iconTank["friendly"] );
 				objective_icon( self.objIdDefenders, level._iconTank["enemy"] );
 			}
 			else if( self.curr_owner == "defenders" )
 			{
 				//println( "defender owned" );
 				objective_icon( self.objIdAttackers, level._iconTank["enemy"] );
 				objective_icon( self.objIdDefenders, level._iconTank["friendly"] );
 			}
 			else
 			{
 				//println( "nutral owned" );
 				objective_icon( self.objIdAttackers, level._iconTank["neutral"] );
 				objective_icon( self.objIdDefenders, level._iconTank["neutral"] );
 			}
 		}
 	}
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 setConvoySpeed( convoyVehicles, speed )
 {
 	println( "set convoy speed " + speed );
 	//positive speed, push vehicle forward
 	foreach( vehicle in convoyVehicles )
 	{
 		if ( speed > 0 )
 		{
    			vehicle.veh_transmission = "forward";
    			vehicle.veh_pathDir = "forward";
 			vehicle vehicle_SetSpeed( speed, 10, 10 );
 			vehicle.reversing = false;
 			vehicle.atBackPathsEnd = false;
 			vehicle.curr_owner = "attackers";
 		}
 		//negative speed, not allowed
 		else if( speed < 0 )
 		{
 			AssertMsg( "Convoy: tried to set speed negative!" );
 		}
 		//0 speed, slow to a stop
 		else
 		{
 			vehicle vehicle_SetSpeed( 0, 6, 5 );
 			vehicle.curr_owner = "neutral";
 		}
 
 		vehicle notify( "update_ugv_status_icons" );
 	}
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 spawnEscortTank( team )
 {
 	escortDbg( "Spawning escort tank for " + team );
 	tank = self Vehicle_DoSpawn( );
 
 	tank SetVehicleTeam( team );
 
 	//tank.health = 3000;
 	//tank.targeting_delay = 1;
 	tank.team = team;
 	tank.pers["team"] = tank.team;
 	//tank.owner = owner;
 	tank setCanDamage( false );
 	tank.numTouching[game["attackers"]] = 0;
 	tank.numTouching[game["defenders"]] = 0;
 
 	//tank maps\mp\killstreaks\_tank::addToTankList();
 	//tank.damageCallback = ::Callback_VehicleDamage;
 	
 	return tank;
 }
 
 //****************************************************************************
 //* CREATION DATE:  6/28/2011 3:31pm
 //* DESCRIPTION:    
 //****************************************************************************
 initGametypeAwards()
 {
 	//maps\mp\_awards::initStatAward( "flagscaptured",		0, maps\mp\_awards::highestWins );
 	//maps\mp\_awards::initStatAward( "flagsreturned", 		0, maps\mp\_awards::highestWins );
 	//maps\mp\_awards::initStatAward( "flagcarrierkills", 	0, maps\mp\_awards::highestWins );
 	//maps\mp\_awards::initStatAward( "flagscarried",			0, maps\mp\_awards::highestWins );
 	//maps\mp\_awards::initStatAward( "killsasflagcarrier", 	0, maps\mp\_awards::highestWins );
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 getSpawnPoint()
 {
 	index = ( level._escortActiveCheckpoint + 1 );
 	if( index > MAX_ESCORT_CHECKPOINTS )
 	{
 		index = MAX_ESCORT_CHECKPOINTS;
 	}
 	if ( self.team == game["attackers"] )
 	{
 		if ( level._inGracePeriod )
 		{
 			// In this case, we're the attackers & this is the first spawn in the game.  Grab from the init list & return.
 			spawnPoints = getentarray("mp_convoy_spawn_attackers_init", "classname");
 			if ( spawnPoints.size > 0 )
 			{
 				spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
 				if( !isDefined( spawnpoint ))
 				{
 					println( "Convoy: couldn't find spawn, case A" );
 					assert( spawnpoint );
 				}
 				return spawnPoint;
 			}
 		}
 		// Grab list of spawns for attackers at this checkpoint..
 		spawnPoints = getentarray("mp_convoy_spawn_attackers_group" + index, "classname");
 		if( spawnPoints.size == 0 )
 		{
 			println( "Don't have spawnpoints for attackers group ", index, " using escort nodes" );
 			spawnPoints = getentarray("mp_escort_spawn_attackers_group" + index, "classname");
 			if( spawnPoints.size == 0 )
 			{
 				println( "Don't have spawnpoints for attackers group ", index );
 			}
 		}
 	}
 	else
 	{
 		if ( level._inGracePeriod )
 		{
 			// In this case, we're the attackers & this is the first spawn in the game.  Grab from the init list & return.
 			spawnPoints = getentarray("mp_convoy_spawn_defenders_init", "classname");
 			if ( spawnPoints.size > 0 )
 			{
 				spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
 				if( !isDefined( spawnpoint ))
 				{
 					println( "Convoy: couldn't find spawn, case B" );
 					assert( spawnpoint );
 				}
 				return spawnPoint;
 			}
 		}
 		// Grab list of spawns for defenders at this checkpoint..
 		spawnPoints = getentarray("mp_convoy_spawn_defenders_group" + index, "classname");
 		if( spawnPoints.size == 0 )
 		{
 			println( "Don't have spawnpoints for defenders group ", index, " using escort nodes" );
 			spawnPoints = getentarray("mp_escort_spawn_defenders_group" + index, "classname");
 			if( spawnPoints.size == 0 )
 			{
 				println( "Don't have spawnpoints for defenders group ", index );
 			}
 		}
 	}
 
 	// Grab spawn point.
 	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
 
 	if( !isDefined( spawnpoint ))
 	{
 		println( "Convoy: couldn't find spawn, case C" );
 		assert( spawnpoint );
 	}
 	return spawnPoint;
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 escortDbg( string )
 {
 	/#
 	if( getDvarInt( "escortDebug" ))
 	{
 		println( "ESCORT: " + string );
 	}
 	#/
 }