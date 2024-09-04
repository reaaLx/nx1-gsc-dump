#include common_scripts\utility;
#include maps\mp\_utility;

init()
{
	precacheItem( "nuke_mp" );
	precacheLocationSelector( "map_nuke_selector" );
	precacheString( &"MP_TACTICAL_NUKE_CALLED" );
	precacheString( &"MP_FRIENDLY_TACTICAL_NUKE" );
	precacheString( &"MP_TACTICAL_NUKE" );

	level._effect[ "nuke_player" ] = loadfx( "explosions/player_death_nuke" );
	level._effect[ "nuke_flash" ] = loadfx( "explosions/player_death_nuke_flash" );
	level._effect[ "nuke_aftermath" ] = loadfx( "dust/nuke_aftermath_mp" );

	game["strings"]["nuclear_strike"] = &"MP_TACTICAL_NUKE";
	
	level._killstreakFuncs["nuke"] = ::tryUseNuke;

	setDvarIfUninitialized( "scr_nukeTimer", 10 );
	setDvarIfUninitialized( "scr_nukeCancelMode", 0 );
	
	level._nukeTimer = getDvarInt( "scr_nukeTimer" );
	level._cancelMode = getDvarInt( "scr_nukeCancelMode" );
	
	/#
	setDevDvarIfUninitialized( "scr_nukeDistance", 5000 );
	setDevDvarIfUninitialized( "scr_nukeEndsGame", true );
	setDevDvarIfUninitialized( "scr_nukeDebugPosition", false );
	#/
}

tryUseNuke( lifeId, allowCancel )
{
	if( isDefined( level._nukeIncoming ) )
	{
		self iPrintLnBold( &"MP_NUKE_ALREADY_INBOUND" );
		return false;	
	}

	if ( self isUsingRemote() && ( !isDefined( level._gtnw ) || !level._gtnw ) )
		return false;

	if ( !isDefined( allowCancel ) )
		allowCancel = true;

	self thread doNuke( allowCancel );
	self notify( "used_nuke" );
	
	return true;
}

delaythread_nuke( delay, func )
{
	level endon ( "nuke_cancelled" );
	
	wait ( delay );
	
	thread [[ func ]]();
}

doNuke( allowCancel )
{
	level endon ( "nuke_cancelled" );
	
	level._nukeInfo = spawnStruct();
	level._nukeInfo.player = self;
	level._nukeInfo.team = self.pers["team"];

	level._nukeIncoming = true;
	
	maps\mp\gametypes\_gamelogic::pauseTimer();
	level._timeLimitOverride = true;
	setGameEndTime( int( gettime() + (level._nukeTimer * 1000) ) );
	setDvar( "ui_bomb_timer", 4 ); // Nuke sets '4' to avoid briefcase icon showing
	
	if ( level._teambased )
	{
		thread teamPlayerCardSplash( "used_nuke", self, self.team );
		/*
		players = level.players;
		
		foreach( player in level.players )
		{
			playerteam = player.pers["team"];
			if ( isdefined( playerteam ) )
			{
				if ( playerteam == self.pers["team"] )
					player iprintln( &"MP_TACTICAL_NUKE_CALLED", self );
			}
		}
		*/
	}
	else
	{
		if ( !level._hardcoreMode )
			self iprintlnbold(&"MP_FRIENDLY_TACTICAL_NUKE");
	}

	level thread delaythread_nuke( (level._nukeTimer - 3.3), ::nukeSoundIncoming );
	level thread delaythread_nuke( level._nukeTimer, ::nukeSoundExplosion );
	level thread delaythread_nuke( level._nukeTimer, ::nukeSlowMo );
	level thread delaythread_nuke( level._nukeTimer, ::nukeEffects );
	level thread delaythread_nuke( (level._nukeTimer + 0.25), ::nukeVision );
	level thread delaythread_nuke( (level._nukeTimer + 1.5), ::nukeDeath );
	level thread delaythread_nuke( (level._nukeTimer + 1.5), ::nukeEarthquake );
	level thread nukeAftermathEffect();

	if ( level._cancelMode && allowCancel )
		level thread cancelNukeOnDeath( self ); 

	// leaks if lots of nukes are called due to endon above.
	clockObject = spawn( "script_origin", (0,0,0) );
	clockObject hide();

	while ( !isDefined( level._nukeDetonated ) )
	{
		clockObject playSound( "ui_mp_nukebomb_timer" );
		wait( 1.0 );
	}
}

cancelNukeOnDeath( player )
{
	player waittill_any( "death", "disconnect" );

	if ( isDefined( player ) && level._cancelMode == 2 )
		player thread maps\mp\killstreaks\_emp::EMP_Use( 0, 0 );


	maps\mp\gametypes\_gamelogic::resumeTimer();
	level._timeLimitOverride = false;

	setDvar( "ui_bomb_timer", 0 ); // Nuke sets '4' to avoid briefcase icon showing

	level notify ( "nuke_cancelled" );
}

nukeSoundIncoming()
{
	level endon ( "nuke_cancelled" );
	
	foreach( player in level._players )
		player playlocalsound( "nuke_incoming" );
}

nukeSoundExplosion()
{
	level endon ( "nuke_cancelled" );

	foreach( player in level._players )
	{
		player playlocalsound( "nuke_explosion" );
		player playlocalsound( "nuke_wave" );
	}
}

nukeEffects()
{
	level endon ( "nuke_cancelled" );

	setDvar( "ui_bomb_timer", 0 );
	setGameEndTime( 0 );

	level._nukeDetonated = true;
	level maps\mp\killstreaks\_emp::destroyActiveVehicles( level._nukeInfo.player );

	foreach( player in level._players )
	{
		playerForward = anglestoforward( player.angles );
		playerForward = ( playerForward[0], playerForward[1], 0 );
		playerForward = VectorNormalize( playerForward );
	
		nukeDistance = 5000;
		/# nukeDistance = getDvarInt( "scr_nukeDistance" );	#/

		nukeEnt = Spawn( "script_model", player.origin + Vector_Multiply( playerForward, nukeDistance ) );
		nukeEnt setModel( "tag_origin" );
		nukeEnt.angles = ( 0, (player.angles[1] + 180), 90 );

		/#
		if ( getDvarInt( "scr_nukeDebugPosition" ) )
		{
			lineTop = ( nukeEnt.origin[0], nukeEnt.origin[1], (nukeEnt.origin[2] + 500) );
			thread draw_line_for_time( nukeEnt.origin, lineTop, 1, 0, 0, 10 );
		}
		#/

		nukeEnt thread nukeEffect( player );
		player.nuked = true;
	}
}

nukeEffect( player )
{
	level endon ( "nuke_cancelled" );

	player endon( "disconnect" );

	waitframe();
	PlayFXOnTagForClients( level._effect[ "nuke_flash" ], self, "tag_origin", player );
}

nukeAftermathEffect()
{
	level endon ( "nuke_cancelled" );

	level waittill ( "spawning_intermission" );
	
	afermathEnt = getEntArray( "mp_global_intermission", "classname" );
	afermathEnt = afermathEnt[0];
	up = anglestoup( afermathEnt.angles );
	right = anglestoright( afermathEnt.angles );

	PlayFX( level._effect[ "nuke_aftermath" ], afermathEnt.origin, up, right );
}

nukeSlowMo()
{
	level endon ( "nuke_cancelled" );

	//SetSlowMotion( <startTimescale>, <endTimescale>, <deltaTime> )
	setSlowMotion( 1.0, 0.25, 0.5 );
	level waittill( "nuke_death" );
	setSlowMotion( 0.25, 1, 2.0 );
}

nukeVision()
{
	level endon ( "nuke_cancelled" );

	level._nukeVisionInProgress = true;
	visionSetNaked( "mpnuke", 3 );

	level waittill( "nuke_death" );

	visionSetNaked( "mpnuke_aftermath", 5 );
	wait 5;
	level._nukeVisionInProgress = undefined;
}

nukeDeath()
{
	level endon ( "nuke_cancelled" );
	
	level notify( "nuke_death" );
	
	maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
	
	AmbientStop(1);

	foreach( player in level._players )
	{
		if ( isAlive( player ) )
			player thread maps\mp\gametypes\_damage::finishPlayerDamageWrapper( level._nukeInfo.player, level._nukeInfo.player, 999999, 0, "MOD_EXPLOSIVE", "nuke_mp", player.origin, player.origin, "none", 0, 0 );
	}

	level._postRoundTime = 10;

	nukeEndsGame = true;

	if ( level._teamBased )
		thread maps\mp\gametypes\_gamelogic::endGame( level._nukeInfo.team, game["strings"]["nuclear_strike"], true );
	else
	{
		if ( isDefined( level._nukeInfo.player ) )
			thread maps\mp\gametypes\_gamelogic::endGame( level._nukeInfo.player, game["strings"]["nuclear_strike"], true );
		else
			thread maps\mp\gametypes\_gamelogic::endGame( level._nukeInfo, game["strings"]["nuclear_strike"], true );
	}
}

nukeEarthquake()
{
	level endon ( "nuke_cancelled" );

	level waittill( "nuke_death" );

	// TODO: need to get a different position to call this on
	//earthquake( 0.6, 10, nukepos, 100000 );

	//foreach( player in level.players )
		//player PlayRumbleOnEntity( "damage_heavy" );
}


waitForNukeCancel()
{
	self waittill( "cancel_location" );
	self setblurforplayer( 0, 0.3 );
}

endSelectionOn( waitfor )
{
	self endon( "stop_location_selection" );
	self waittill( waitfor );
	self thread stopNukeLocationSelection( (waitfor == "disconnect") );
}

endSelectionOnGameEnd()
{
	self endon( "stop_location_selection" );
	level waittill( "game_ended" );
	self thread stopNukeLocationSelection( false );
}

stopNukeLocationSelection( disconnected )
{
	if ( !disconnected )
	{
		self setblurforplayer( 0, 0.3 );
		self endLocationSelection();
		self.selectingLocation = undefined;
	}
	self notify( "stop_location_selection" );
}