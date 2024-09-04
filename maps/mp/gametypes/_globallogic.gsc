#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
	level._splitscreen = isSplitScreen();
	level._ps3 = (getDvar( "ps3Game" ) == "true");
	level._xenon = (getDvar( "xenonGame" ) == "true");
	level._console = (level._ps3 || level._xenon);
	
	level._onlineGame = getDvarInt( "onlinegame" );
	level._rankedMatch = ( !level._onlineGame || !getDvarInt( "xblive_privatematch" ) );
	
	if ( !level._console )
	{
		if ( !getDvarInt( "sv_pure" ) )
		{
			oldvalue = level._rankedMatch;
			level._rankedMatch = false;
			/#
			level._rankedMatch = oldvalue;
			#/
		}
	}
	
	/#
	if ( getdvarint( "scr_forcerankedmatch" ) == 1 )
	{
		level._onlineGame = true;
		level._rankedMatch = true;
	}
	#/

	level._script = toLower( getDvar( "mapname" ) );
	level._gametype = toLower( getDvar( "g_gametype" ) );

	//TagZP<NOTE>blocking this out in MTDM will force crashes/asserts where these are used.  So nothing slips by.
	if( level._gametype != "mtdm" )
	{
		level._otherTeam["allies"] = "axis";
		level._otherTeam["axis"] = "allies";
	}
	
	level._maxNumTeams = 2;
	
	level._teamNameList = ["allies", "axis"];

	level._teamBased = false;
	
	level._multiTeamBased = false;
	
	level._objectiveBased = false;
	
	level._endGameOnTimeLimit = true;
	
	level._showingFinalKillcam = false;
	
	level._tiSpawnDelay = getDvarInt( "scr_tispawndelay" );
	
	// hack to allow maps with no scripts to run correctly
	if ( !isDefined( level._tweakablesInitialized ) )
		maps\mp\gametypes\_tweakables::init();
	
	precacheString( &"MP_HALFTIME" );
	precacheString( &"MP_OVERTIME" );
	precacheString( &"MP_ROUNDEND" );
	precacheString( &"MP_INTERMISSION" );
	precacheString( &"MP_SWITCHING_SIDES" );
	precacheString( &"MP_FRIENDLY_FIRE_WILL_NOT" );
	precacheString( &"PLATFORM_REVIVE" );
	
	precacheString( &"MP_OBITUARY_NEUTRAL" );
	precacheString( &"MP_OBITUARY_FRIENDLY" );
	precacheString( &"MP_OBITUARY_ENEMY" );

	if ( level._splitScreen )
		precacheString( &"MP_ENDED_GAME" );
	else
		precacheString( &"MP_HOST_ENDED_GAME" );
	
	level._halftimeType = "halftime";
	level._halftimeSubCaption = &"MP_SWITCHING_SIDES";
	
	level._lastStatusTime = 0;
	level._wasWinning = "none";
	
	level._lastSlowProcessFrame = 0;
	
	for( i = 0; i < level._teamNameList.size; i++ )
	{
		level._placement[level._teamNameList[i]] = [];
	}
	level._placement["all"] = [];
	
	/*
	level._placement["allies"] = [];
	level._placement["axis"] = [];
	level._placement["all"] = [];
	*/
	
	level._postRoundTime = 5.0;
	
	level._playersLookingForSafeSpawn = [];
	
	registerDvars();

	precacheModel( "vehicle_mig29_desert" );
	precacheModel( "projectile_cbu97_clusterbomb" );
	precacheModel( "tag_origin" );	

	level._fx_airstrike_afterburner = loadfx ("fire/jet_afterburner");
	level._fx_airstrike_contrail = loadfx ("smoke/jet_contrail");
	
	if ( level._console )
		precacheLeaderboards( "LB_KILLS LB_WINS LB_TOTALXP LB_ACCURACY" );

	for( i = 0; i < level._teamNameList.size; i++ )
	{
		level._teamCount[level._teamNameList[i]] = 0;
		level._aliveCount[level._teamNameList[i]] = 0;
		level._livesCount[level._teamNameList[i]] = 0;
		level._hasSpawned[level._teamNameList[i]] = 0;
	}
	level._teamCount["spectator"] = 0;
	level._aliveCount["spectator"] = 0;
	
	level._oneLeftTime = [];

	/#
	if ( getdvarint( "scr_runlevelandquit" ) == 1 )
	{
		thread runLevelAndQuit();
	}
	#/
}


/#
runLevelAndQuit()
{
	wait 1;
	while ( level._players.size < 1 )
	{
		wait 0.5;
	}
	wait 0.5;
	level notify( "game_ended" );
	exitLevel();	
}
#/


registerDvars()
{
	makeDvarServerInfo( "ui_bomb_timer", 0 );
	makeDvarServerInfo( "ui_danger_team", "" );	
}

SetupCallbacks()
{
	level._onXPEvent = ::onXPEvent;
	
	level._getSpawnPoint = ::blank;
	level._onSpawnPlayer = ::blank;
	level._onRespawnDelay = ::blank;

	level._onTimeLimit = maps\mp\gametypes\_gamelogic::default_onTimeLimit;
	level._onScoreLimit = maps\mp\gametypes\_gamelogic::default_onScoreLimit;
	level._onHalfTime = maps\mp\gametypes\_gamelogic::default_onHalfTime;
	level._onDeadEvent = maps\mp\gametypes\_gamelogic::default_onDeadEvent;
	level._onOneLeftEvent = maps\mp\gametypes\_gamelogic::default_onOneLeftEvent;
	
	level._onPrecacheGametype = ::blank;
	level._onStartGameType = ::blank;
	level._onPlayerKilled = ::blank;

	level._autoassign = maps\mp\gametypes\_menus::menuAutoAssign;
	level._spectator = maps\mp\gametypes\_menus::menuSpectator;
	level._class = maps\mp\gametypes\_menus::menuClass;
	level._onTeamSelection = maps\mp\gametypes\_menus::onMenuTeamSelect;
}



blank( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 )
{
}



/#
xpRateThread()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );

	gameFlagWait( "prematch_done" );

	for ( ;; )
	{
		wait ( 5.0 );
		if ( level._players[0].pers["team"] == "allies" || level._players[0].pers["team"] == "axis" )
			self maps\mp\gametypes\_rank::giveRankXP( "kill", int(min( getDvarInt( "scr_xprate" ), 50 )) );
	}
}
#/

testMenu()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	for ( ;; )
	{
		wait ( 10.0 );
		
		notifyData = spawnStruct();
		notifyData.titleText = &"MP_CHALLENGE_COMPLETED";
		notifyData.notifyText = "wheee";
		notifyData.sound = "mp_challenge_complete";
	
		self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
	}
}

testShock()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	for ( ;; )
	{
		wait ( 3.0 );

		numShots = randomInt( 6 );
		
		for ( i = 0; i < numShots; i++ )
		{
			iPrintLnBold( numShots );
			self shellShock( "frag_grenade_mp", 0.2 );
			wait ( 0.1 );
		}
	}
}


onXPEvent( event )
{
	//self thread maps\mp\_loot::giveMoney( event, 10 );
	self thread maps\mp\gametypes\_rank::giveRankXP( event );
}



fakeLag()
{
	self endon ( "disconnect" );
	self.fakeLag = randomIntRange( 50, 150 );
	
	for ( ;; )
	{
		self setClientDvar( "fakelag_target", self.fakeLag );
		wait ( randomFloatRange( 5.0, 15.0 ) );
	}
}




debugLine( start, end )
{
	for ( i = 0; i < 50; i++ )
	{
		line( start, end );
		wait .05;
	}
}