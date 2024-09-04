#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

/*
	UGV Escort Plus
	Objective: 	Escort the UGV throught all the checkpoints
	Map ends:	When one team reaches the score limit, or time limit is reached
	Respawning:	No wait / Specific locations for the current checkpoint
*/

/*QUAKED mp_escort_spawn_attackers_group1 (0.0 0.0 1.0) (-16 -16 0) (16 16 72)
Players spawn away from enemies and near their team at one of these positions.*/

/*QUAKED mp_escort_spawn_attackers_group2 (0.0 0.0 1.0) (-16 -16 0) (16 16 72)
Team 0 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_escort_spawn_attackers_group3 (0.0 0.0 1.0) (-16 -16 0) (16 16 72)
Team 1 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_escort_spawn_attackers_group4 (0.0 0.0 1.0) (-16 -16 0) (16 16 72)
Team 2 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_escort_spawn_attackers_group5 (0.0 0.0 1.0) (-16 -16 0) (16 16 72)
Team 3 players spawn at one of these positions at the start of a round.*/

 /*QUAKED mp_escort_spawn_defenders_group1 (0.0 0.0 1.0) (-16 -16 0) (16 16 72)
 Team 4 players spawn at one of these positions at the start of a round.*/
 
 /*QUAKED mp_escort_spawn_defenders_group2 (0.0 0.0 1.0) (-16 -16 0) (16 16 72)
 Team 5 players spawn at one of these positions at the start of a round.*/
 
 /*QUAKED mp_escort_spawn_defenders_group3 (0.0 0.0 1.0) (-16 -16 0) (16 16 72)
 Team 6 players spawn at one of these positions at the start of a round.*/
 
 /*QUAKED mp_escort_spawn_defenders_group4 (0.0 0.0 1.0) (-16 -16 0) (16 16 72)
 Team 7 players spawn at one of these positions at the start of a round.*/
 
 /*QUAKED mp_escort_spawn_defenders_group5 (0.0 0.0 1.0) (-16 -16 0) (16 16 72)
 Team 8 players spawn at one of these positions at the start of a round.*/
 
 /*QUAKED mp_escort_spawn_attackers_init (0.5 0.0 1.0) (-16 -16 0) (16 16 72)
 Players spawn away from enemies and near their team at one of these positions.*/
 
 /*QUAKED mp_escort_spawn_defenders_init (0.5 0.0 1.0) (-16 -16 0) (16 16 72)
 Team 0 players spawn at one of these positions at the start of a round.*/
 
 //tagTMR<TODO>: Make these dvars or make them derrived from the size of the tank model
 TANK_TRIGGER_RADIUS=300;
 TANK_TRIGGER_HEIGHT=80;
 TANK_IDLE_TO_REVERSE_TIME_IN_SECONDS=7.0;
 TANK_STANDARD_SPEED=1.75;
 
 ATTACKERS_PUSH_SCORE_TIME_SEC = 5.0;
 
 //TagZP<NOTE> use this to delay the next objective message so that it does not play right on top of the previous objective complete message
 CHECKPOINT_COMPLETE_GRACE_PERIOD=2.5;
 
 MAX_ESCORT_CHECKPOINTS=5;
 
 NOTIFY_MESSAGE_DOOR_OPENING = "door_opening";                  //the notify message when the door is opening
 NOTIFY_MESSAGE_DOOR_CLOSING = "door_closing";                  //the notify message when the door is closing
 NOTIFY_MESSAGE_DOOR_AT_TOP = "door_at_top";                    //the notify message when the door is at the top
 NOTIFY_MESSAGE_DOOR_AT_BOTTOM = "door_at_bottom";              //the notify message when the door is at the bottom
 NOTIFY_MESSAGE_DISABLE_DOOR_SWITCH = "disable_door_switch";    //the notify message to disable the door switch
 DOOR_STATE_COMPLETELY_CLOSED = "completely_closed";            //the flag message when the door is completely closed
 DOOR_STATE_COMPLETELY_OPENED = "completely_opened";            //the flag message when the door is completely opened
 DOOR_STATE_OPENING = "door_opening";                           //the flag message when the door is opening
 DOOR_STATE_CLOSING = "door_closing";                           //the flag message when the door is closeing
 
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
 
 	//This should be viewed as a const array.
 	//map the nth person pushing the ugv to the nth position in this array to find the % speed increase.  
 	//Example - 2nd person pushing adds 90% of the tank standard speed to the tanks cumulative speed.
 	level._TANK_SPEED_DIMINISHING_PROPERTY = [ 1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.0 ];
 
 
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
 	
 	level._mode_escortplus = true;
 	level._ugv_can_get_pushed_back = false;
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
 
 	// icon refs
 	level._iconCapture["enemy"] = "nx_waypoint_capture_enemy";
 	level._iconCapture["friendly"] = "nx_waypoint_capture_friendly";
 	level._iconCapture["neutral"] = "nx_waypoint_capture_neutral";
 
 	level._iconSecure["enemy"] = "nx_waypoint_secure_enemy";
 	level._iconSecure["friendly"] = "nx_waypoint_secure_friendly";
 	level._iconSecure["neutral"] = "nx_waypoint_secure_neutral";
 
 	level._iconEscort["friendly"] = "nx_waypoint_escort_friendly";
 	level._iconEscort["enemy"] = "nx_waypoint_escort_enemy";
 	level._iconEscort["neutral"] = "nx_waypoint_escort_neutral";
 
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
 	
 	precacheShader( level._iconSecure["enemy"] );
 	precacheShader( level._iconSecure["friendly"] );
 	precacheShader( level._iconSecure["neutral"] );
 
 	precacheShader( level._iconEscort["friendly"] );
 	precacheShader( level._iconEscort["enemy"] );
 	precacheShader( level._iconEscort["neutral"] );
 
 	precacheShader( level._iconDefend["friendly"] );
 	precacheShader( level._iconDefend["enemy"] );
 	precacheShader( level._iconDefend["neutral"] );
 
 	precacheShader( level._iconTank["friendly"] );
 	precacheShader( level._iconTank["enemy"] );
 	precacheShader( level._iconTank["neutral"] );
 
 	precacheShader( level._iconActivate["enemy"] );
 
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
 
 	/* TagZP<NOTE> can uncomment this stuff if we decide we want unique vo starts for round 1 and 2
 	if ( game["switchedsides"] )
 	{
 		game["dialog"]["offense_obj"] = "off_2ndstart";
 		game["dialog"]["defense_obj"] = "def_2ndstart";
 	}
 	else
 	{ */
 		game["dialog"]["offense_obj"] = "off_1ststart";
 		game["dialog"]["defense_obj"] = "def_1ststart";
 	//}
 
 	// Setup all game dialog.
 	setupVOSoundAliases();
 
 	// Set Scoring & stat vars.
 
 	maps\mp\_awards::initStatAward( "escortcheckpoints", 0, maps\mp\_awards::highestWins );
 	
 	//attacker points
 	maps\mp\gametypes\_rank::registerScoreInfo( "escortugv", 25 );
 	maps\mp\gametypes\_rank::registerScoreInfo( "doorcheckpoint", 150 );
 	maps\mp\gametypes\_rank::registerScoreInfo( "capturecheckpoint", 150 );
 	maps\mp\gametypes\_rank::registerScoreInfo( "escortcheckpoint", 250 );
 	maps\mp\gametypes\_rank::registerScoreInfo( "escortcheckpointbonus", 100 );  //for being with the UGV when it hits the checkpoint
 	
 	//defender points
 	maps\mp\gametypes\_rank::registerScoreInfo( "missedcapture", 150 );
 	maps\mp\gametypes\_rank::registerScoreInfo( "misseddoor", 150 );
 	maps\mp\gametypes\_rank::registerScoreInfo( "missedcheckpoint", 300 );
 
 	//attacker/defender points
 	maps\mp\gametypes\_rank::registerScoreInfo( "ugvkill", 50 );  //kill an attacker by the UGV, or kill a defender from near the UGV
 	//maps\mp\gametypes\_rank::registerScoreInfo( "kill", 50 );
 	//maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );  //we want the player to get extra xp for this but not player score
 	//maps\mp\gametypes\_rank::registerScoreInfo( "assist", 20 );
 
 	setClientNameMode("auto_change");
 	
 	//tagTMR<TODO>: get these strings setup and precache in onPrecacheGameType()
 	setObjectiveScoreText( game["attackers"], &"OBJECTIVES_ESCORT_ATTACKER_SCORE" );
 	setObjectiveScoreText( game["defenders"], &"OBJECTIVES_ESCORT_DEFENDER_SCORE" );
 
 //	setObjectiveText( game["attackers"], &"OBJECTIVES_ATTACK_ESCORT" );
 //	setObjectiveText( game["defenders"], &"OBJECTIVES_DEFEND_ESCORT" );
 //	setObjectiveHintText( game["attackers"], &"OBJECTIVES_ESCORT_ATTACKER_HINT" );
 //	setObjectiveHintText( game["defenders"], &"OBJECTIVES_ESCORT_DEFENDER_HINT" );
 
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
 	
 	allowed[0] = "escortplus";
 
 	maps\mp\gametypes\_gameobjects::main(allowed);
 
 	thread missionScriptExec();
 	level thread overtimewatcher();
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
 
 	if( isDefined( level._activeCountDown ))
 	{
 		//if there is an active timer on screen set it up when the player respawns
 		if( level._activeCountDown )
 		{
 			if ( self.pers["team"] == game["attackers"] )
 			{
 				self setLowerMessage( "escort_info", &"MP_CAPTURING", level._own_time - ((level._captureTime + ( getTime() - level._captureTimeStamp )) / 1000.0 ), 1, true );
 			}
 			else
 			{
 				self setLowerMessage( "escort_info", &"MP_LOSING_CONTROLS", level._own_time - ((level._captureTime + ( getTime() - level._captureTimeStamp )) / 1000.0 ), 1, true );
 			}
 		}
 	}
 
 	if( isDefined( level._escortInboundCountDown ))
 	{
 		if( level._escortInboundCountDown )
 		{
 			self setUGVInboundMessage();
 		}
 	}
 
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
 
 updateUGVInboundMessageForAll()
 {
 	foreach( player in level._players )
 	{
 		player setUGVInboundMessage();
 	}
 }
 
 setUGVInboundMessage()
 {
 	if( isDefined( level._escortInboundCountDown ))
 	{
 		if( level._escortInboundCountDown )
 		{
 			assert( level._escortInboundStartTime > -1 );	//make sure the calling system has initialized this value
 			assert( level._escortInboundDuration  > -1 );	//make sure the calling system has initialized this value
 		
 			time_remaining = ( level._escortInboundDuration - (( getTime() - level._escortInboundStartTime ) / 1000.0 ));
 			
 			//some debug prints
 			//println( "curr time = " + getTime( ));
 			//println( "level._escortInboundStartTime = " + level._escortInboundStartTime );
 			//println( "inbound duratin = " + level._escortInboundDuration );
 			//println( "time_remaining = " + time_remaining );
 
 			self setLowerMessage( "escort_inbound_info", level._escortInboundMessage, time_remaining, 1, true );
 		}
 		else
 		{
 			self clearLowerMessage( "escort_inbound_info" );
 		}
 	}
 }
 
 //****************************************************************************
 //* CREATION DATE:  6/28/2011 3:30pm
 //* DESCRIPTION:  Handels bonus points for kills near the UGV
 //****************************************************************************
 onNormalDeath( victim, attacker, lifeId )
 {
 	if ( isDefined( level._escortVehicle ) )
 	{
 		tank = level._escortVehicle;
 		// If attacker is on offense & touching UGV, or if defender is on defense & victim is touching UGV.
 		if ( attacker.pers["team"] == game["attackers"] )
 		{
 			// Attacker killing defender - if I'm in the UGV's radius, add bonus points.
 			if ( attacker isTouching( tank.trig ))
 			{
 				maps\mp\gametypes\_gamescore::givePlayerScore( "ugvkill", attacker );
 				attacker incPlayerStat( "killswhilepushingugv", 1 );
 			}
 		}
 		else
 		{
 			// Defender killing attacker - if victim is in the UGV's radius, add bonus points.
 			if ( victim isTouching( tank.trig ))
 			{
 				maps\mp\gametypes\_gamescore::givePlayerScore( "ugvkill", attacker );
 				attacker incPlayerStat( "killsenemywhopushesugv", 1 );
 			}
 		}
 	}
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
 		maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( team, 1 );
 	}
 
 	foreach ( player in level._players )
 	{
 		if ( player.pers["team"] == team )
 		{
 			player incPersStat( "checkpoints", 1 );
 			player.checkpoints = player getPersStat( "checkpoints" );
 			player incPlayerStat( "checkpoints", 1 );
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
 //* CREATION DATE:  6/28/2011 2:56pm
 //* DESCRIPTION:    Objective that requires the attackers to capture a switch for <own_time> seconds.
 //****************************************************************************
 objectiveSwitch( switch_name, trigger_name, capture_time, own_time, capture_text_attacker, capture_text_defender )
 {
 	//update capture text if necessary
 	if( isDefined( capture_text_attacker ))
 	{
 		level._captureTextAttacker = capture_text_attacker;
 	}
 	
 	if( isDefined( capture_text_defender ))
 	{
 		level._captureTextDefender = capture_text_defender;
 	}
 	
 	// Objectives are synchronous
 	level._own_time = own_time;
 	level._activeCountDown = false;
 
 	level._escortSwitch = getentArray_and_assert( switch_name );
 	level._escortSwitchTrigger = getentArray_and_assert( trigger_name );
 
 	game["flagmodels"] = [];
 	game["flagmodels"]["neutral"] = "prop_flag_neutral";
 	trigger = level._escortSwitchTrigger[0];
 	visuals[0] = level._escortSwitch[0];
 
 	domFlag = maps\mp\gametypes\_gameobjects::createUseObject( game["defenders"], trigger, visuals, (0,0,100) );
 	domFlag maps\mp\gametypes\_gameobjects::allowUse( "enemy" );		// "none", "any", "friendly", "enemy"; 
 	domFlag maps\mp\gametypes\_gameobjects::setUseTime( capture_time );
 
 	domFlag maps\mp\gametypes\_gameobjects::setOwnerTeam( game["defenders"] );
 	domFlag maps\mp\gametypes\_gameobjects::setUseText( level._captureTextAttacker );
 	domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level._iconDefend["friendly"] );
 	domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level._iconDefend["friendly"] );
 	domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", level._iconCapture["enemy"] );
 	domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", level._iconCapture["enemy"] );
 	domFlag maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
 	
 	domFlag.onUse = ::onUse;
 	domFlag.onBeginUse = ::onBeginUse;
 	domFlag.onUseUpdate = ::onUseUpdate;
 	domFlag.onEndUse = ::onEndUse;
 
 	traceStart = visuals[0].origin + (0,0,32);
 	traceEnd = visuals[0].origin + (0,0,-32);
 	trace = bulletTrace( traceStart, traceEnd, false, undefined );
 	
 	upangles = vectorToAngles( trace["normal"] );
 	domFlag.baseeffectforward = anglesToForward( upangles );
 	domFlag.baseeffectright = anglesToRight( upangles );
 		
 	domFlag.baseeffectpos = trace["position"];
 
 	level._domFlag = domFlag;
 
 	// Monitor the flag to see if we've held it long enough.
 	while ( 1 )
 	{
 		if ( level._captureTeam == game["attackers"] )
 		{
 			// Attackers own the flag, check to see if we've captured long enough.
 			time = getTime();
 			total_time = ( ( time - level._captureTimeStamp ) + level._captureTime );
 			if ( total_time > ( level._own_time * 1000.0 ) )
 			{
 				foreach ( player in level._players )
 				{
 					if ( player.pers["team"] == game["attackers"] )
 					{
 						player thread maps\mp\gametypes\_hud_message::SplashNotify( "escortswitchacomplete", maps\mp\gametypes\_rank::getScoreInfoValue( "capturecheckpoint" ) );
 						
 						//everyone on the attacking team gets "capturecheckpoint" points
 						maps\mp\gametypes\_gamescore::givePlayerScore( "capturecheckpoint", player );
 					}
 					else
 					{
 						player thread maps\mp\gametypes\_hud_message::SplashNotify( "escortswitchdcomplete", maps\mp\gametypes\_rank::getScoreInfoValue( "capturecheckpoint" ) );
 					}
 					player clearLowerMessage( "escort_info" );
 				}
 				
 				//play objective complete dialog
 				PlayDialog( "AttackersFinishCappingDomPoint" );
 				
 				level._activeCountDown = false;
 				level._domFlag maps\mp\gametypes\_gameobjects::allowUse( "none" );
 				level._domFlag maps\mp\gametypes\_gameobjects::setOwnerTeam( "none" );
 				level._domFlag maps\mp\gametypes\_gameobjects::disableObject();
 				level._domFlag maps\mp\gametypes\_gameobjects::deleteUseObject();
 				level._escortSwitch[0] hide();
 
 				return;
 			}
 		}
 
 		waitframe();
 	}
 }
 
 //****************************************************************************
 //* CREATION DATE:  6/28/2011 3:30pm
 //* DESCRIPTION:    
 //****************************************************************************
 onUse( player )
 {	
 	//get team of the player who capped
 	team = player.pers["team"];
 	level._domFlag maps\mp\gametypes\_gameobjects::setOwnerTeam( team );
 
 	level._domFlag maps\mp\gametypes\_gameobjects::allowUse( "enemy" );
 
 	//println( "UseScriptBegin" );
 	//println( "attackers = " + game["attackers"] );
 	//println( "defenders = " + game["defenders"] );
 	//println( "dom point captured by a player on team " + team );
 
 	if ( team == game["attackers"] )
 	{
 		// If captured by attackers, set start time stamp for use by monitor thread.
 		level._captureTimeStamp = getTime();
 
 		// println( "attackers captured, resetting icons and text" );
 		level._domFlag maps\mp\gametypes\_gameobjects::setUseText( level._captureTextDefender );
 		level._domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level._iconDefend["friendly"] );
 		level._domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level._iconDefend["friendly"] );
 		level._domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", level._iconCapture["enemy"] );
 		level._domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", level._iconCapture["enemy"] );
 
 		foreach ( check_player in level._players )
 		{
 			if ( level._captureTime == 0 )
 			{
 				// First capture - no existing capture.
 				
 				//beggining to own point, play dialog
 				//PlayDialog( "AttackersBeginCappingDomPoint" );
 				
 				if ( check_player.pers["team"] == game["attackers"] )
 				{
 					check_player thread maps\mp\gametypes\_hud_message::SplashNotify( "escortswitchaplant", maps\mp\gametypes\_rank::getScoreInfoValue( "capturecheckpoint" ) );
 					check_player setLowerMessage( "escort_info", &"MP_CAPTURING", level._own_time - ( level._captureTime / 1000.0 ), 1, true );
 				}
 				else
 				{
 					check_player thread maps\mp\gametypes\_hud_message::SplashNotify( "escortswitchdplant", maps\mp\gametypes\_rank::getScoreInfoValue( "capturecheckpoint" ) );
 					check_player setLowerMessage( "escort_info", &"MP_LOSING_CONTROLS", level._own_time - ( level._captureTime / 1000.0 ), 1, true );
 				}
 			}
 			else
 			{
 				// Recapture.
 				if ( check_player.pers["team"] == game["attackers"] )
 				{
 					check_player thread maps\mp\gametypes\_hud_message::SplashNotify( "escortswitcharesume", maps\mp\gametypes\_rank::getScoreInfoValue( "capturecheckpoint" ) );
 					check_player setLowerMessage( "escort_info", &"MP_CAPTURING", level._own_time - ( level._captureTime / 1000.0 ), 1, true );
 				}
 				else
 				{
 					check_player thread maps\mp\gametypes\_hud_message::SplashNotify( "escortswitchdresume", maps\mp\gametypes\_rank::getScoreInfoValue( "capturecheckpoint" ) );
 					check_player setLowerMessage( "escort_info", &"MP_LOSING_CONTROLS", level._own_time - ( level._captureTime / 1000.0 ), 1, true );
 				}
 			}
 		}
 
 		level._activeCountDown = true;
 	}
 	else
 	{	
 		// If captured by defenders, accumulate time so far.
 		// println( "defenders captured, resetting icons" );
 		level._domFlag maps\mp\gametypes\_gameobjects::setUseText( level._captureTextAttacker );
 		level._domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level._iconDefend["friendly"] );
 		level._domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level._iconDefend["friendly"] );
 		level._domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", level._iconCapture["enemy"] );
 		level._domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", level._iconCapture["enemy"] );
 
 		if ( level._captureTeam != "none" )
 		{
 			level._captureTime += ( getTime() - level._captureTimeStamp );
 			foreach ( check_player in level._players )
 			{
 				if ( check_player.pers["team"] == game["attackers"] )
 				{
 					check_player thread maps\mp\gametypes\_hud_message::SplashNotify( "escortswitchastop", maps\mp\gametypes\_rank::getScoreInfoValue( "capturecheckpoint" ) );
 				}
 				else
 					check_player thread maps\mp\gametypes\_hud_message::SplashNotify( "escortswitchdstop", maps\mp\gametypes\_rank::getScoreInfoValue( "capturecheckpoint" ) );
 
 				check_player clearLowerMessage( "escort_info" );
 			}
 		}
 		level._activeCountDown = false;
 	}
 
 	level._captureTeam = team;
 	println( "UseScriptEnd" );
 }
 
 //****************************************************************************
 //* CREATION DATE:  6/28/2011 3:30pm
 //* DESCRIPTION:    
 //****************************************************************************
 onBeginUse( player )
 {
 	PlayDialog( "AttackersBeginCappingDomPoint" );
 	self.objPoints["allies"] thread maps\mp\gametypes\_objpoints::startFlashing();
 	self.objPoints["axis"] thread maps\mp\gametypes\_objpoints::startFlashing();
 	println( "onBeginUse: " );
 }
 
 //****************************************************************************
 //* CREATION DATE:  6/28/2011 3:30pm
 //* DESCRIPTION:    
 //****************************************************************************
 onUseUpdate( team, progress, change )
 {
 //	println( "onUseUpdate: " );
 }
 
 //****************************************************************************
 //* CREATION DATE:  6/28/2011 3:30pm
 //* DESCRIPTION:    
 //****************************************************************************
 onEndUse( team, player, success )
 {
 	self.objPoints["allies"] thread maps\mp\gametypes\_objpoints::stopFlashing();
 	self.objPoints["axis"] thread maps\mp\gametypes\_objpoints::stopFlashing();
 	println( "onEndUse: " );
 }
 
 //****************************************************************************
 //* CREATION DATE:  6/28/2011 3:35pm
 //* DESCRIPTION:    Creates the escort vehicle.
 //****************************************************************************
 objectiveCreateEscortVehicle()
 {
 	tankSpawners = Vehicle_GetSpawnerArray();
 	assertEx( tankSpawners.size, "There are no tank spawners on this map!  UGV Escort game mode is impossible");
 	
 	assert( tankSpawners.size == 1 );
 	
 	
 	// tagTMR<TODO>: Fix this for "attackers" only...
 	level._tankSpawner["allies"] = tankSpawners[0];
 	level._tankSpawner["axis"] = tankSpawners[0];
 	level._pathCount = 0; 
 	
 	foreach ( spawner in tankSpawners )
 	{
 		if ( isSubStr( spawner.model, "bradley" ) )
 			level._tankSpawner["allies"] = spawner;
 		
 		if ( isSubStr( spawner.model, "bmp" ) )
 			level._tankSpawner["axis"] = spawner;
 	}
 
 	level._escortVehicle = createEscortVehicle( game["attackers"] );
 	playDialog( "UGVOnGround" );
 	
 	if ( level._splitScreen )
 		hudElemAlpha = 0;
 	else
 		hudElemAlpha = 0.85;
 
 	// tagTMR<TODO>: setup a status icon for the UGV to notify of reversing or advancing (see examples in CTF friendlyFlagStatusIcons)
 
 	spawnPoints = getentarray("mp_tdm_spawn_" + game["attackers"] + "_start", "classname");
 	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
 	location = spawnPoint.origin;
 
 	escortStartNodes = getVehicleNodeArray( "escortugvstartpos", "script_noteworthy" );
 	//interesting this seems like a bug, shouldn't escortStartNodes.size just be nonzero
 	if ( isDefined( escortStartNodes ) && ( escortStartNodes.size == 1 ) )
 	{
 		startNode = maps\mp\killstreaks\_tank::getNearestUGVNode( escortStartNodes[0].origin, level._ugvstartnodes );
 	}
 	else
 	{
 		startNode = level._ugvspawnnodes[0];
 	}
 
 	//init script members
 	level._escortVehicle.reversing = false;
 	level._escortVehicle.atBackPathsEnd = true;
 
 	//attach the vehicle to its initial path
 	level._escortVehicle attachPath( startNode );
 
 	//thread updateTankSpeed();
 
 	level._escortVehicle thread handleTeamTrophyEffects();
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
 		name = "ugv_pathmarker_" + index;
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
 	name = "ugv_pathmarker_" + index;
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
 	name = "ugv_pathmarker_" + index;
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
 objectiveEscortToCheckPoint( voRefString )
 {	
 	//play any specified VO
 	if( isDefined( voRefString ))
 	{
 		playDialog( voRefString );
 	}
 
 	// find new nodes and continue
 	startNode = maps\mp\killstreaks\_tank::getNearestUGVNode( level._escortVehicle.origin, level._ugvstartnodes );
 	CreateCheckpointNodes( startNode );
 
 	showEscortPathMarker( level._escortActiveCheckpoint + 1 );
 
 	//unhide the UGV Head Icons
 	if( isDefined( level._escortVehicle.defendersObjPoint ))
 	{
 		level._escortVehicle.defendersObjPoint.alpha = 1.0;
 		level._escortVehicle.attackersObjPoint.alpha = 1.0;
 	}
 	
 	//start the vehicle on the path
 	level._escortVehicle startPath( startNode );
 	level._escortVehicle updateUseRate( 0 );
 	level._escortVehicle thread updateTankSpeed();
 
 	// Start escort loop!
 	while ( 1 )
 	{
 
 //		assert(( level._escortActiveCheckpoint < 5 ) && ( level._escortActiveCheckpoint >= 0 ));
 
 		startNode.checkpointObject ActivateCheckpoint();
 
 		level._escortVehicle waittill( "reached_end_node", endnode );
 
 		assert( isDefined( endnode ));
 
 		//if this is a start node
 		if ( isDefined( endnode.target ))
 		{
 			level._escortVehicle startPath( startNode );
 			self.veh_transmission = "forward";
    			self.veh_pathDir = "forward";
 			level._escortVehicle updateUseRate( 0 );
 
 			level._escortVehicle.atBackPathsEnd = true;
 			
 			//Play VO for when defenders push UGV back to the start of the current Checkpoint
 			PlayDialog( "restartcheckpoint" );
 
 			// no points if this end node is from a trip backwards
 			continue;
 		}
 		else
 		{
 			// UGV has reached the checkpoint!!
 
 			tank = level._escortVehicle;
 			
 			timeLeft = maps\mp\gametypes\_gamelogic::getTimeRemaining();
 			if ( timeLeft < 0 )
 			{
 				level._negativeTime += ( 0 - ( timeLeft / ( 60 * 1000 ) ) );
 			}
 
 			//award points to each attacker ( attackers next to the UGV get a bonus )
 			foreach ( player in level._players )
 			{
 				if ( player.pers["team"] == game["attackers"] )
 				{
 					points = maps\mp\gametypes\_rank::getScoreInfoValue( "escortcheckpoint" );
 					maps\mp\gametypes\_gamescore::givePlayerScore( "escortcheckpoint", player );
 					
 					// If this player is touching the UGV, add bonus points.
 					if ( player isTouching( tank.trig ) )
 					{
 						points = points + maps\mp\gametypes\_rank::getScoreInfoValue( "escortcheckpointbonus" );
 						maps\mp\gametypes\_gamescore::givePlayerScore( "escortcheckpointbonus", player );
 					}
 
 					// Regular checkpoint
 					player thread maps\mp\gametypes\_hud_message::SplashNotify( "escortcheckpoint", points );
 				}
 			}
 
 			PlayDialog( "checkpointreached" );
 
 			hideEscortPathMarker( level._escortActiveCheckpoint + 1 );
 			startNode.checkpointObject DeactivateCheckpoint();
 			level._escortVehicle notify( "segment_complete" );
 			level._timeLimitOverride = false;
 			
 			//HIDE UGV HEAD ICONS
 			if( isDefined( level._escortVehicle.defendersObjPoint ))
 			{
 				level._escortVehicle.defendersObjPoint.alpha = 0.0;
 				level._escortVehicle.attackersObjPoint.alpha = 0.0;
 			}
 			
 			//break from the loop to continue to the next objective
 			break;
 		}
 	}
 }
 
 //****************************************************************************
 //* CREATION DATE:  6/30/2011 5:00pm
 //* DESCRIPTION:    Objective requiring the attackers to open the door fully.
 //****************************************************************************
 objectiveDoorFullyOpened( door_index )
 {
 	level._canPlayerUseDoor = ::gameModeLogic;	
 	level._shouldTheObjectiveEnd = ::objectiveTerminationLogic;
 	level._doorOpeningSound = ::playtheOpeningSound;
 	level._doorClosingSound = ::playtheClosingSound;
 	level._doorCompletelyOpenSound = ::playCompletelyOpenSound;
 	level._doorCompletelyCloseSound = ::playCompletelyCloseSound;
 	level._doorActivationSound = ::playDoorActivationSound;
 
 	//play vo for the UGV is at the security door
 	waitAndPlayDialog( 4.0, "UGVAtSecurityDoor" );
 
 	level thread maps\mp\_DoorSwitch::main();
 	level._DoorSwitchTrigger[ door_index ] thread HandlePlayerDoorMessages();
 	level._DoorSwitchTrigger[ door_index ] thread updateTriggerUsibilityTeam();
 
 	checkpointTrigger = spawn( "trigger_radius", level._DoorSwitchTrigger[0].origin, 0, 1.0, 1.0 );
 	checkpointTrigger.radius = 1.0;
 
 	visuals = [];
 	gameobjectCheckpoint = maps\mp\gametypes\_gameobjects::createUseObject( game[ "attackers" ], checkpointTrigger, visuals, (0,0,0) );
 	gameobjectCheckpoint maps\mp\gametypes\_gameobjects::allowUse( "none" );
 
 	gameobjectCheckpoint maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
 	gameobjectCheckpoint maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", level._iconDefend["friendly"] );
 	gameobjectCheckpoint maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", level._iconDefend["friendly"] );
 	gameobjectCheckpoint maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level._iconActivate["enemy"] );
 	gameobjectCheckpoint maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level._iconActivate["enemy"] );
 
 	gameobjectCheckpoint maps\mp\gametypes\_gameobjects::setUseTime( 5 );
 	level._domFlag = gameobjectCheckpoint;
 	
 	level waittill ( "door_opening" );
 		
 	level._DoorSwitchTrigger[door_index] delete();
 	gameobjectCheckpoint maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
 	println( "door objective complete, remove door_info msg" );
 		
 	wait (15.0);
 	//level waittill ( "disable_door_switch" );
 	//for ( i = 0; i < level._DoorSwitchTrigger.size; i++)
 	//{
 		
 	//} 
 
 	foreach( player in level._players )
 	{
 		//give attackers points
 		if( player.pers[ "team" ] == game[ "attackers" ] )
 		{
 			player clearLowerMessage( "door_info" );
 			maps\mp\gametypes\_gamescore::givePlayerScore( "doorcheckpoint", player );
 		}
 	}
 
 	
 }
 
 updateTriggerUsibilityTeam()
 {
 	self endon ( NOTIFY_MESSAGE_DISABLE_DOOR_SWITCH );
 
 	self SetTeamForTrigger( game[ "attackers" ] );
 
 /*	while ( 1 )
 	{
 		msg = waittill_any_return ( NOTIFY_MESSAGE_DOOR_OPENING, NOTIFY_MESSAGE_DOOR_CLOSING );
 
 		if ( msg == NOTIFY_MESSAGE_DOOR_OPENING )
 		{
 			self SetTeamForTrigger( game[ "defenders" ] );
 		}	
 		else if ( msg == NOTIFY_MESSAGE_DOOR_CLOSING )
 		{
 			self SetTeamForTrigger( game[ "attackers" ] );
 		}
 	}*/
 }
 
 HandlePlayerDoorMessages()
 {
 	self endon( "death" );
 
 	last_msg = "undefined";
 
 	for(;;)
 	{
 		msg = waittill_any_return( NOTIFY_MESSAGE_DOOR_OPENING, NOTIFY_MESSAGE_DOOR_CLOSING, NOTIFY_MESSAGE_DOOR_AT_TOP, NOTIFY_MESSAGE_DOOR_AT_BOTTOM );
 		
 		if( msg != last_msg )
 		{
 			last_msg = msg;
 
 			//play VO
 			if ( msg == NOTIFY_MESSAGE_DOOR_OPENING )
 			{
 				playDialog( "attackersActivatedDoor" );
 			}
 			else if ( msg == NOTIFY_MESSAGE_DOOR_CLOSING )
 			{
 				playDialog( "defendersActivatedDoor" );
 			}
 			
 			foreach( player in level._players )
 			{
 				if ( msg == NOTIFY_MESSAGE_DOOR_OPENING )
 				{
 					player setLowerMessage( "door_info", &"MP_DOOR_OPENING" );
 				}	
 				else if ( msg == NOTIFY_MESSAGE_DOOR_CLOSING )
 				{
 					player setLowerMessage( "door_info", &"MP_DOOR_CLOSING" );
 				}
 				else
 				{
 					player clearLowerMessage( "door_info" );
 				}
 			}
 
 			if( msg == NOTIFY_MESSAGE_DOOR_AT_BOTTOM )
 			{
 				playDialog( "defendersFinishClosingDoor" );
 				break;
 			}
 		}
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 //tagJC<NOTE>: The following function is created to modify the door switch functionality for the UGV escort plus game mode.
 gameModeLogic( player, switch_trigger, door_state )
 {
 	if ( door_state == DOOR_STATE_COMPLETELY_CLOSED )
 	{
 		//tagJC<NOTE>: Case 1: If the door is completely closed and the player is an attacker, the door should be operable
 		if ( player.pers[ "team" ] == game[ "attackers" ] )
 		{
 			return true;
 		}
 		else
 		{
 			//tagJC<NOTE>: Case 2: If the door is completely closed and the player is a defender, the door should not move
 			player IPrintLnBold ( "The door is already completely closed" ); 
 			return false;
 		}
 	}
 	else if ( door_state == DOOR_STATE_OPENING )
 	{
 		//tagJC<NOTE>: Case 3: If an attacker is trying to open the door that is already opening, nothing should happen
 		if ( player.pers[ "team" ] == game[ "attackers" ] )
 		{
 			player IPrintLnBold ( "The door is already opening" ); 
 			return false;
 		}
 		else
 		{
 			//tagJC<NOTE>: Case 4: If a defender is trying to close the opening door, the door should close
 			return false;
 		}
 	}
 	else if ( door_state == DOOR_STATE_CLOSING )
 	{
 		//tagJC<NOTE>: Case 5: If a attacker is trying to open the closing door, the door should open
 		if ( player.pers[ "team" ] == game[ "attackers" ] )
 		{
 			return true;
 		}
 		else
 		{
 			//tagJC<NOTE>: Case 6: If a defender is trying to close the door that is already closing, nothing should happen
 			player IPrintLnBold ( "The door is already closing" ); 
 			return false;
 		}
 	}
 	else if ( door_state == DOOR_STATE_COMPLETELY_OPENED )
 	{
 		//tagJC<NOTE>: Case 7: If the door is completely opened, notify all related threads to terminate
 		player IPrintLnBold ( "The door is completely opened.  The door switch is disabled" );
 		switch_trigger notify ( NOTIFY_MESSAGE_DISABLE_DOOR_SWITCH );
 		return false;
 	}
 	println( "This is bad and should never happen.  Something is terribly wrong!" );
 	return true;
 }
 
 //tagJC<NOTE>: This function defines the objective ending condition for the escort plus mode, in addition to the basic door
 //             switch functionality.
 objectiveTerminationLogic()
 {
 	self endon ( NOTIFY_MESSAGE_DISABLE_DOOR_SWITCH );
 	
 	while ( 1 )
 	{
 		if ( isdefined ( self.pairedTriggerOn ) && isdefined ( self.pairedTriggerTop ))
 		{
 			if ( self.pairedTriggerOn.origin[2] == self.pairedTriggerTop.origin[2] )
 			{
 				if ( isDefined( level._doorCompletelyOpenSound ) && ( self.state != DOOR_STATE_COMPLETELY_OPENED ))
 				{
 					self [[level._doorCompletelyOpenSound]]();
 				}
 				//tagJC<NOTE>: Once the door reaches the top, notify the level regarding the condition and delete the trigger
 				self notify ( NOTIFY_MESSAGE_DOOR_AT_TOP );
 				self.state = DOOR_STATE_COMPLETELY_OPENED;
 				level notify ( NOTIFY_MESSAGE_DISABLE_DOOR_SWITCH );
 				self notify ( NOTIFY_MESSAGE_DISABLE_DOOR_SWITCH );
 			}
 
 			if ( self.state == DOOR_STATE_OPENING )
 			{
 				level._domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level._iconDefend["friendly"] );
 				level._domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level._iconDefend["friendly"] );
 				level._domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", level._iconActivate["enemy"] );
 				level._domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", level._iconActivate["enemy"] );
 			}
 			if ( self.state == DOOR_STATE_CLOSING )
 			{
 				level._domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", level._iconDefend["friendly"] );
 				level._domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", level._iconDefend["friendly"] );
 				level._domFlag maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", level._iconActivate["enemy"] );
 				level._domFlag maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", level._iconActivate["enemy"] );
 			}
 		}
 
 		waitframe();
 	}
 }
 
 //tagJC<NOTE>: This function would overwrite the default movement logic for the killing doors
 escortPlusKillingDoorLogic( moving_vector, moving_time, door_time_remain_open, door_time_remain_close )
 {
 	self moveTo( self.origin + moving_vector, moving_time, moving_time * 0.5, moving_time * 0.5 );
     self waittill( "movedone" );
 	level.escortPlusKillingDoorClosed = level.escortPlusKillingDoorClosed + 1;
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 playtheOpeningSound()
 {
 	if ( self.state == DOOR_STATE_COMPLETELY_CLOSED )
 	{
 		self.pairedClip playsound ("ugv_door_up_start");
 		self.pairedClip playloopsound ("ugv_door_up_loop");
 		self playsound ("ugv_panel_up_start");
 		self playloopsound ("ugv_panel_up_loop");
 	}
 	else if ( self.state == DOOR_STATE_CLOSING )
 	{
 		self.pairedClip stoploopsound( "ugv_door_down_loop");
 		self.pairedClip playsound ("ugv_door_up_start");
 		self.pairedClip playloopsound ("ugv_door_up_loop");
 		self stoploopsound( "ugv_panel_down_loop");
 		self playsound ("ugv_panel_up_start");
 		self playloopsound ("ugv_panel_up_loop");
 	}
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 playtheClosingSound()
 {
 	if ( self.state == DOOR_STATE_COMPLETELY_OPENED )
 	{
 		self.pairedClip playsound ("ugv_door_down_start");
 		self.pairedClip playloopsound ("ugv_door_down_loop");
 		self playsound ("ugv_panel_down_start");
 		self playloopsound ("ugv_panel_down_loop");
 	}
 	else if ( self.state == DOOR_STATE_OPENING )
 	{
 		self.pairedClip stoploopsound( "ugv_door_up_loop");
 		self.pairedClip playsound ("ugv_door_down_start");
 		self.pairedClip playloopsound ("ugv_door_down_loop");
 		self stoploopsound( "ugv_panel_up_loop");
 		self playsound ("ugv_panel_down_start");
 		self playloopsound ("ugv_panel_down_loop");
 	}
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 playCompletelyCloseSound()
 {
 	self.pairedClip stoploopsound( "ugv_door_down_loop");
 	self.pairedClip playsound ("ugv_door_down_end");
 	self stoploopsound( "ugv_panel_down_loop");
 	self playsound ("ugv_panel_down_end");
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 playCompletelyOpenSound()
 {
 	self.pairedClip stoploopsound( "ugv_door_up_loop");
 	self.pairedClip playsound ("ugv_door_up_end");
 	self stoploopsound( "ugv_panel_up_loop");
 	self playsound ("ugv_panel_up_end");
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 playDoorActivationSound( player )
 {
 	player playsound( "prototype_door_activate" );
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 findPathMidpointDistance( startNode )
 {
 	dist = 0.0;
 	node = startNode;
 	while( IsDefined( node ))
 	{
 		if( !IsDefined( node.target ))
 		{
 			return ( dist / 2 );
 		}
 
 		temp = GetVehicleNode( node.target, "targetname" );
 
 		if( !IsDefined( temp ))
 		{
 			break;
 		}
 
 		dist += distance2d( node.origin, temp.origin );
 
 		escortDbg( "Node: " + node.origin + " Next: " + temp.origin + " Totes Dist: " + dist );
 
 		node=temp;
 	}
 
 	return ( dist / 2 );
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 CreateCheckpointNodes( firstStartNode )
 {
 	level._escortCheckpoints = [];
 	ugvStartNode = firstStartNode;
 
 	for( i=0; i < MAX_ESCORT_CHECKPOINTS; i++)
 	{
 		escortDbg( "StartNode " + (i+1) + ": Setup checkpoint at end node" );
 
 		node = ugvStartNode;
 		while( IsDefined( node ))
 		{
 			if( !IsDefined( node.target ))
 			{
 				ugvStartNode.checkpointObject = CreateCheckpointNode( node );
 				break;
 			}
 
 			temp = GetVehicleNode( node.target, "targetname" );
 			node=temp;
 		}
 
 		ugvStartNode = maps\mp\killstreaks\_tank::getNearestUGVNode( ugvStartNode.checkpointObject.curOrigin, level._ugvstartnodes );
 	}
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 CreateCheckpointNode( node )
 {
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
 
 	// Stop the tank moving.
 	if ( isDefined( level._areaTrigger ) )
 	{
 		level._areaTrigger notify( "kill_ugv" );
 		level._escortVehicle.numTouching[game["attackers"]] = 0;
 		level._escortVehicle.numTouching[game["defenders"]] = 0;
 		level._escortVehicle updateUseRate( 0 );
 	}
 
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
 
 	//if ( !inOvertime() && game["teamScores"]["allies"] == game["teamScores"]["axis"] && game["switchedsides"] )
 	//{
 	//	thread maps\mp\gametypes\_gamelogic::endGame( "overtime", game["strings"]["time_limit_reached"] );
 	//}
 	//else if( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
 	//{
 	//	thread maps\mp\gametypes\_gamelogic::endGame( "axis", game["strings"]["time_limit_reached"] );
 	//}
 	//else if( game["teamScores"]["axis"] < game["teamScores"]["allies"] )
 	//{
 	//	thread maps\mp\gametypes\_gamelogic::endGame( "allies", game["strings"]["time_limit_reached"] );
 	//}
 	//else if ( inOvertime() )
 	//{
 	//	thread maps\mp\gametypes\_gamelogic::endGame( "tie", game["strings"]["time_limit_reached"] );
 	//}
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
 createEscortVehicle( team )
 {
 	tank = level._tankSpawner[team] spawnEscortTank( team );
 	tank.trig = undefined;
 	
 	tank.nodes = GetVehicleNodeArray( "info_vehicle_node", "classname" );
 
 	level._ugvstartnodes = GetVehicleNodeArray( "ugvstartnode", "script_noteworthy" );
 	level._ugvbacknodes = GetVehicleNodeArray( "ugvstartnodeback", "script_noteworthy" );
 	level._ugvexitnodes = GetVehicleNodeArray( "ugvexitnode", "script_noteworthy" );
 	level._ugvspawnnodes = GetVehicleNodeArray( "ugvstartnodespawn", "targetname" );
 
 	// make the turret for the UGV to use
 	turretPoint = tank getTagOrigin( "TAG_TURRET" );
 	tank.trophy_turret = spawnTurret( "misc_turret", turretPoint, level._escortUGVTurretInfo );
     tank.trophy_turret linkTo( tank, "TAG_TURRET", (0,0,0), (0,0,0) );
 	tank.trophy_turret setModel( level._escortUGVTurretModel );
     tank.trophy_turret.angles = tank.angles; 
     tank.trophy_turret makeTurretInoperable(); 
     tank.trophy_turret SetDefaultDropPitch( 0 );
 	//tank.trophy_turret MakeEntitySolid();
 	tank thread maps\mp\_mp_trophy_turret::trophy_turret_update();
 
 	areaTrigger = spawn( "trigger_radius", tank.origin, 0, TANK_TRIGGER_RADIUS, TANK_TRIGGER_HEIGHT );
 	areaTrigger EnableLinkTo();
 	areaTrigger LinkTo( tank );
 	areaTrigger.radius = TANK_TRIGGER_RADIUS;
 	areaTrigger.entNum = areaTrigger getEntNum();
 
 	tank.trig = areaTrigger;
 
 	areaTrigger thread tankTriggerThink();
 
 	level._areaTrigger = areaTrigger;
 	tank.curr_owner = "neutral";
 	tank createEscoreVehicleObjectives();
 	return tank;
 }
 
 createEscoreVehicleObjectives()
 {
 	self.objIdAttackers = maps\mp\gametypes\_gameobjects::getNextObjID();
 	objective_add( self.objIdAttackers, "invisible", (0,0,0) );
 
 	self.attackersObjPoint = maps\mp\gametypes\_objpoints::createTeamObjpoint( "objpoint_attackers", self.origin + (0,0,85), game["attackers"], level._iconEscort["neutral"] );
 	self.attackersObjPoint setWayPoint( true, true );
 	self.attackersShader = level._iconEscort["neutral"];
 
 	//removed mini map icon from the vehicle def, using these insted since the vehicle def does not support neutral colors, nor does it handle team changing very easily.
 	objective_position( self.objIdAttackers, self.origin );
 	objective_icon( self.objIdAttackers, level._iconTank["friendly"] );
 	objective_team( self.objIdAttackers, game["attackers"] );
 	objective_state( self.objIdAttackers, "active" );
 
 	self.objIdDefenders = maps\mp\gametypes\_gameobjects::getNextObjID();
 	objective_add( self.objIdDefenders, "invisible", (0,0,0) );
 
 	self.defendersObjPoint = maps\mp\gametypes\_objpoints::createTeamObjpoint( "objpoint_defenders", self.origin + (0,0,85), game["defenders"], level._iconSecure["neutral"] );
 	self.defendersObjPoint setWayPoint( true, true );
 	self.defendersShader = level._iconSecure["neutral"];
 
 	//removed mini map icon from the vehicle def, using these insted since the vehicle def does not support neutral colors, nor does it handle team changing very easily.
 	objective_position( self.objIdDefenders, self.origin );
 	objective_icon( self.objIdDefenders, level._iconTank["enemy"] );
 	objective_team( self.objIdDefenders, game["defenders"] );
 	objective_state( self.objIdDefenders, "active" );
 	
 	self.attackersObjPoint SetTargetEnt( self );
 	self.defendersObjPoint SetTargetEnt( self );
 
 	objective_onentity( self.objIdAttackers, self );
 	objective_onentity( self.objIdDefenders, self );
 
 	self.curr_owner = "neutral";
 	self thread MonitorTankObjectiveIcons();
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
 				defendersShader = level._iconSecure["enemy"];
 				attackersShader = level._iconEscort["friendly"];
 
 				objective_icon( self.objIdAttackers, level._iconTank["friendly"] );
 				objective_icon( self.objIdDefenders, level._iconTank["enemy"] );
 			}
 			else if( self.curr_owner == "defenders" )
 			{
 				//println( "defender owned" );
 				defendersShader = level._iconSecure["friendly"];
 				attackersShader = level._iconEscort["enemy"];
 
 				objective_icon( self.objIdAttackers, level._iconTank["enemy"] );
 				objective_icon( self.objIdDefenders, level._iconTank["friendly"] );
 			}
 			else
 			{
 				//println( "nutral owned" );
 				defendersShader = level._iconSecure["neutral"];
 				attackersShader = level._iconEscort["neutral"];
 
 				objective_icon( self.objIdAttackers, level._iconTank["neutral"] );
 				objective_icon( self.objIdDefenders, level._iconTank["neutral"] );
 			}
 
 			//Update defender icon if it changed
 			if( self.defendersShader != defendersShader )
 			{
 				println( "setting defender shader to " + defendersShader + " with size " + level._objPointSize );
 				self.defendersObjPoint SetShader( defendersShader, level._objPointSize, level._objPointSize );
 				self.defendersObjPoint setWayPoint( true, true );
 				self.defendersShader = defendersShader;
 			}
 			
 			//Update attacker icon if it changed
 			if( self.attackersShader != attackersShader )
 			{
 				println( "setting attackers shader to " + attackersShader + " with size " + level._objPointSize );
 				self.attackersObjPoint SetShader( attackersShader, level._objPointSize, level._objPointSize );
 				self.attackersObjPoint setWayPoint( true, true );
 				self.attackersShader = attackersShader;
 			}
 		}
 	}
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 tankTriggerThink()
 {
 	level endon ( "game_ended" );
 	self endon ( "kill_ugv" );
 
 	entityNumber = self.entNum;
 
 	while ( 1 )
 	{
 		self waittill( "trigger", player );
 		
 		if ( !isReallyAlive( player ) || ( player IsUsingRemote()))
 		{
 			continue;
 		}
 
 		if ( isReallyAlive( player ) && !isDefined( player.touchTriggers[entityNumber] ) )
 		{
 			player thread triggerTouchThink( self );
 		}
 	}
 }
 
 
//*******************************************************************
//																	*
//																	*
//*******************************************************************
triggerTouchThink( trigger )
{
	team = self.pers["team"];

	level._escortVehicle.numTouching[team]++;

	touchName = self.guid;
	struct = spawnstruct();
	struct.player = self;
	struct.starttime = gettime();
	trigger.touchList[ touchName ] = struct;

	self.touchTriggers[ trigger.entNum ] = trigger;

	self.escortTouchTime = gettime();
	while ( isReallyAlive( self ) && isDefined( trigger ) && self isTouching( trigger ) && !level._gameEnded )
	{
		wait ( 0.05 );
		if( gettime() - self.escortTouchTime > ATTACKERS_PUSH_SCORE_TIME_SEC * 1000
		&& level._escortVehicle.curr_owner != "neutral"
		&& self.pers["team"] == game[level._escortVehicle.curr_owner] )
 		{
 			self.escortTouchTime = gettime();
 			maps\mp\gametypes\_gamescore::givePlayerScore( "escortugv", self );
 			value = maps\mp\gametypes\_rank::getScoreInfoValue( "escortugv" );
 			self thread maps\mp\gametypes\_rank::giveRankXP( "escortugv", value );
 		} 
 	}
 
 	// disconnected player will skip this code
 	if ( isDefined( self ) )
 	{
 		self.touchTriggers[ trigger.entNum ] = undefined;
 	}
 
 	if ( level._gameEnded )
 		return;
 	
 	trigger.touchList[ touchName ] = undefined;
 
 	level._escortVehicle.numTouching[team]--;
 }
 
 //*******************************************************************
 //																	*
 //																	*
 //*******************************************************************
 updateUseRate( multiple )
 {
 	direction_change = false;
 	//determine if we are changing directions
 	old_owner = self.curr_owner;
 	if( multiple > 0 && self.reversing == true || multiple < 0 && self.reversing == false )
 	{
 		//println( "direction change detected" );
 		direction_change = true;
 	}
 
 	//positive speed, push vehicle forward
 	if ( multiple > 0 )
 	{
    		s = 0;
 		for( i = 0; i < multiple; i++ )
 		{
 			s += level._TANK_SPEED_DIMINISHING_PROPERTY[i] * level._escortVehicle.standardSpeed;
 		}
 		
 		self.veh_transmission = "forward";
    		self.veh_pathDir = "forward";
 		//self vehicle_SetSpeed( level._escortVehicle.standardSpeed * multiple, 10, 10 );
 		self vehicle_SetSpeed( s, 10, 10 );
 		self.reversing = false;
 		self.atBackPathsEnd = false;
 		self.curr_owner = "attackers";
 	}
 	//negative speed, pull vehicle backwards
 	else if( multiple < 0 && level._ugv_can_get_pushed_back )
 	{
 		if( !self.atBackPathsEnd )
 		{
 			self.veh_transmission = "reverse";
    			self.veh_pathDir = "reverse";
 			self vehicle_SetSpeed( level._escortVehicle.standardSpeed * ( 0 - multiple ), 10, 10 );
 			self.reversing = true;
 		}
 		self.curr_owner = "defenders";
 	}
 	//0 speed, slow to a stop
 	else
 	{
 		self vehicle_SetSpeed( 0, 6, 5 );
 		self.curr_owner = "neutral";
 	}
 
 	if( direction_change )
 	{
 		self StartPath();
 	}
 
 	self notify( "update_ugv_status_icons" );
 
 	if( old_owner != self.curr_owner )
 	{
 		self notify( "ownership_changed" );
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
 	tank setModel( level._escortUGVModel );
 
 	tank SetVehicleTeam( team );
 
 	//tank.health = 3000;
 	//tank.targeting_delay = 1;
 	tank.team = team;
 	tank.pers["team"] = tank.team;
 	//tank.owner = owner;
 	tank setCanDamage( false );
 	tank.standardSpeed = TANK_STANDARD_SPEED;
 	//tank.evadeSpeed = 50;
 	//tank.dangerSpeed = 15;
 	//tank.miniEngagementSpeed = 15;
 	//tank.engagementSpeed = 15;
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
 updateTankSpeed()
 {
 	self endon ( "kill_ugv" );
 	self endon ( "segment_complete" );
 
 	current_touching[game["attackers"]] = 0;
 	current_touching[game["defenders"]] = 0;
 	current_speed = 0;
 
 	level._escortVehicle updateUseRate( 0 );
 
 	while ( 1 )
 	{
 		waitframe();
 
 		// Deal with first touch case.
 		if ( ( level._escortVehicle.numTouching[game["attackers"]] > 0 ) && ( current_touching[game["attackers"]] == 0 ) && ( current_touching[game["defenders"]] == 0 ) )
 		{
 			// First touch by attacker, no defenders touching.
 			playDialog( "ugvproximity" );
 		}
 		
 		
 		// Update touching values.
 		current_touching[game["attackers"]] = level._escortVehicle.numTouching[game["attackers"]];
 		current_touching[game["defenders"]] = level._escortVehicle.numTouching[game["defenders"]];
 
 		// Update speed based on who is touching.
 		new_speed = current_speed;
 		if ( ( current_touching[game["attackers"]] > 0 ) && ( current_touching[game["attackers"]] > current_touching[game["defenders"]] ) )
 		{
 			// Attackers are touching, but no defenders.
 			new_speed = current_touching[game["attackers"]] - current_touching[game["defenders"]];
 		}
 		else if ( ( current_touching[game["defenders"]] > 0 ) && ( current_touching[game["defenders"]] > current_touching[game["attackers"]] ) )
 		{
 			// Defenders are touching, but no attackers.
 			new_speed = ( 0 - ( current_touching[game["defenders"]] - current_touching[game["attackers"]] ));
 		}
 		else
 		{
 			// Both sides are touching, or neither side is touching, stop the UGV.
 			new_speed = 0;
 		}
 		
 		//while the tank is making forward progress allow for time extension into overtime
 		//adding OT condition that says if there is and equal number of attackers and defenders on the UGV and that number is greater than 0 allow for OT to continue
 		diff = current_touching[game["defenders"]] - current_touching[game["attackers"]];
 		if( new_speed > 0 || ( diff == 0 && current_touching[game["defenders"]] > 0 ))
 		{
 			level._timeLimitOverride = true;
 		}
 		else
 		{
 			level._timeLimitOverride = false;
 		}
 		
 
 		//update changes in vehicle speed
 		level._escortVehicle updateUseRate( new_speed );
 		current_speed = new_speed;
 	}
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
 			spawnPoints = getentarray("mp_escort_spawn_attackers_init", "classname");
 			if ( spawnPoints.size > 0 )
 			{
 				spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
 				if( !isDefined( spawnpoint ))
 				{
 					println( "EscortPlus: couldn't find spawn, case A" );
 					assert( spawnpoint );
 				}
 				return spawnPoint;
 			}
 		}
 		// Grab list of spawns for attackers at this checkpoint..
 		spawnPoints = getentarray("mp_escort_spawn_attackers_group" + index, "classname");
 		if( spawnPoints.size == 0 )
 		{
 			println( "Don't have spawnpoints for defenders group ", index );
 		}
 	}
 	else
 	{
 		if ( level._inGracePeriod )
 		{
 			// In this case, we're the attackers & this is the first spawn in the game.  Grab from the init list & return.
 			spawnPoints = getentarray("mp_escort_spawn_defenders_init", "classname");
 			if ( spawnPoints.size > 0 )
 			{
 				spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
 				if( !isDefined( spawnpoint ))
 				{
 					println( "EscortPlus: couldn't find spawn, case B" );
 					assert( spawnpoint );
 				}
 				return spawnPoint;
 			}
 		}
 		// Grab list of spawns for defenders at this checkpoint..
 		spawnPoints = getentarray("mp_escort_spawn_defenders_group" + index, "classname");
 		if( spawnPoints.size == 0 )
 		{
 			println( "Don't have spawnpoints for defenders group ", index );
 		}
 	}
 
 	// Grab spawn point.
 	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
 
 	if( !isDefined( spawnpoint ))
 	{
 		println( "EscortPlus: couldn't find spawn, case C" );
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