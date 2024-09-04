#include maps\mp\_utility;
#include common_scripts\utility;

init()
{
	mapname = getDvar( "mapname" );
	if ( mapname == "mp_suburbia" )
	{
		level._missileRemoteLaunchVert = 7000;
		level._missileRemoteLaunchHorz = 10000;
		level._missileRemoteLaunchTargetDist = 2000;
	}
	else if ( mapname == "mp_mainstreet" )
	{
		level._missileRemoteLaunchVert = 7000;
		level._missileRemoteLaunchHorz = 10000;
		level._missileRemoteLaunchTargetDist = 2000;
	}
	else
	{
		level._missileRemoteLaunchVert = 14000;
		level._missileRemoteLaunchHorz = 7000;
		level._missileRemoteLaunchTargetDist = 1500;

	}	
	precacheItem( "remotemissile_projectile_mp" );
	precacheShader( "ac130_overlay_grain" );
	precacheString( &"MP_CIVILIAN_AIR_TRAFFIC" );
	
	level._rockets = [];
	
	level._killstreakFuncs["predator_missile"] = ::tryUsePredatorMissile;
	level._killstreakFuncs["predator_marker"] = ::tryUsePredatorMarker;
	
	level._missilesForSightTraces = [];
}

tryUsePredatorMarker( lifeId )
{
	
	//okToUsePredatorMarker = true;
	//level endon( "game_ended" );
	//self endon( "death" );

	
	//println( "Got off" );
	//if (okToUsePredatorMarker == true)
	//{
		self usePredatorMarker();
		return true;
	//}
	//msg = self waittill_any_return( "pred_grenade_thrown" );

	//if ( msg != "pred_grenade_thrown" )
	//	self switchToOffhand( grenade );
	//return false;

}

usePredatorMarker()
{
	level endon( "game_ended" );
	self endon( "death" );	
	self endon("disconnect");

	ognade = self GetCurrentOffhand();
	ognadeCount = self GetWeaponAmmoClip(ognade);

	self SetWeaponAmmoClip( ognade, 0 );

	self _giveWeapon("pred_grenade_mp");
	//println( "gave pred" );

	self thread waitForPredatorMarker( ognade, ognadeCount );
	

}

waitForPredatorMarker( nadeId, nadeCount){
	level endon( "game_ended" );
	self endon( "death" );	
	self endon("disconnect");	

	for(;;)
	{
		self waittill( "grenade_fire", grenade, weaponName ); 
		//println( weaponName );
		if( weaponName == "pred_grenade_mp" )
		{
			break;
		}
		
	}

	if (nadeCount > 0)
	{
		self _giveWeapon(nadeId);
		//println( "gave grenade back" );
	}
}

/*
dontLosePredMarker()
{
	self endon( "grenade_fire"); 

	self waittill("death");
	println( "in dontLose FOR" );
	predNadeCheck = self GetCurrentOffhand();
	predNadeCount = self GetWeaponAmmoClip(predNadeCheck);
	if ( predNadeCheck != "pred_grenade_mp" && predNadeCount != 1 )
	{
		self SetWeaponAmmoClip( "pred_grenade_mp" , 1 );
		println( "not gonna lose it!" );
	}
	
}
*/

tryUsePredatorMissile( lifeId )
{
	if ( isDefined( level._civilianJetFlyBy ) )
	{
		self iPrintLnBold( &"MP_CIVILIAN_AIR_TRAFFIC" );
		return false;
	}

	self setUsingRemote( "remotemissile" );
	result = self maps\mp\killstreaks\_killstreaks::initRideKillstreak();
	if ( result != "success" )
	{
		if ( result != "disconnect" )
			self clearUsingRemote();

		return false;
	}

	level thread _fire( lifeId, self );
	
	return true;
}


getBestSpawnPoint( remoteMissileSpawnPoints )
{
	validEnemies = [];

	foreach ( spawnPoint in remoteMissileSpawnPoints )
	{
		spawnPoint.validPlayers = [];
		spawnPoint.spawnScore = 0;
	}
	
	foreach ( player in level._players )
	{
		if ( !isReallyAlive( player ) )
			continue;

		if ( player.team == self.team )
			continue;
		
		if ( player.team == "spectator" )
			continue;
		
		bestDistance = 999999999;
		bestSpawnPoint = undefined;
	
		foreach ( spawnPoint in remoteMissileSpawnPoints )
		{
			//could add a filtering component here but i dont know what it would be.
			spawnPoint.validPlayers[spawnPoint.validPlayers.size] = player;
		
			potentialBestDistance = Distance2D( spawnPoint.targetent.origin, player.origin );
			
			if ( potentialBestDistance <= bestDistance )
			{
				bestDistance = potentialBestDistance;
				bestSpawnpoint = spawnPoint;	
			}	
		}
		
		assertEx( isDefined( bestSpawnPoint ), "Closest remote-missile spawnpoint undefined for player: " + player.name );
		bestSpawnPoint.spawnScore += 2;
	}

	bestSpawn = remoteMissileSpawnPoints[0];
	foreach ( spawnPoint in remoteMissileSpawnPoints )
	{
		foreach ( player in spawnPoint.validPlayers )
		{
			spawnPoint.spawnScore += 1;
			
			if ( bulletTracePassed( player.origin + (0,0,32), spawnPoint.origin, false, player ) )
				spawnPoint.spawnScore += 3;
		
			if ( spawnPoint.spawnScore > bestSpawn.spawnScore )
			{
				bestSpawn = spawnPoint;
			}
			else if ( spawnPoint.spawnScore == bestSpawn.spawnScore ) // equal spawn weights so we toss a coin.
			{			
				if ( coinToss() )
					bestSpawn = spawnPoint;	
			}
		}
	}
	
	return ( bestSpawn );
}

drawLine( start, end, timeSlice, color )
{
	drawTime = int(timeSlice * 20);
	for( time = 0; time < drawTime; time++ )
	{
		line( start, end, color,false, 1 );
		wait ( 0.05 );
	}
}
_fire( lifeId, player )
{
	remoteMissileSpawnArray = getEntArray( "remoteMissileSpawn" , "targetname" );
	//assertEX( remoteMissileSpawnArray.size > 0 && getMapCustom( "map" ) != "", "No remote missile spawn points found.  Contact friendly neighborhood designer" );
	
	foreach ( spawn in remoteMissileSpawnArray )
	{
		if ( isDefined( spawn.target ) )
			spawn.targetEnt = getEnt( spawn.target, "targetname" );	
	}
	
	if ( remoteMissileSpawnArray.size > 0 )
		remoteMissileSpawn = player getBestSpawnPoint( remoteMissileSpawnArray );
	else
		remoteMissileSpawn = undefined;
	
	if ( isDefined( remoteMissileSpawn ) )
	{	
		startPos = remoteMissileSpawn.origin;	
		targetPos = remoteMissileSpawn.targetEnt.origin;

		//thread drawLine( startPos, targetPos, 30, (0,1,0) );

		vector = vectorNormalize( startPos - targetPos );		
		startPos = vector_multiply( vector, 14000 ) + targetPos;

		//thread drawLine( startPos, targetPos, 15, (1,0,0) );
		
		rocket = MagicBullet( "remotemissile_projectile_mp", startpos, targetPos, player );
	}
	else
	{
		upVector = (0, 0, level._missileRemoteLaunchVert );
		backDist = level._missileRemoteLaunchHorz;
		targetDist = level._missileRemoteLaunchTargetDist;
	
		forward = AnglesToForward( player.angles );
		startpos = player.origin + upVector + forward * backDist * -1;
		targetPos = player.origin + forward * targetDist;
		
		rocket = MagicBullet( "remotemissile_projectile_mp", startpos, targetPos, player );
	}

	if ( !IsDefined( rocket ) )
	{
		player clearUsingRemote();
		return;
	}
	
	rocket thread maps\mp\gametypes\_weapons::AddMissileToSightTraces( player.team );
	
	rocket thread handleDamage();
	
	rocket.lifeId = lifeId;
	rocket.type = "remote";
	MissileEyes( player, rocket );
}

/#
_fire_noplayer( lifeId, player )
{
	upVector = (0, 0, level._missileRemoteLaunchVert );
	backDist = level._missileRemoteLaunchHorz;
	targetDist = level._missileRemoteLaunchTargetDist;

	forward = AnglesToForward( player.angles );
	startpos = player.origin + upVector + forward * backDist * -1;
	targetPos = player.origin + forward * targetDist;
	
	rocket = MagicBullet( "remotemissile_projectile_mp", startpos, targetPos, player );

	if ( !IsDefined( rocket ) )
		return;

	rocket thread handleDamage();
	
	rocket.lifeId = lifeId;
	rocket.type = "remote";
	
	player CameraLinkTo( rocket, "tag_origin" );
	player ControlsLinkTo( rocket );

	rocket thread Rocket_CleanupOnDeath();

	wait ( 2.0 );

	player ControlsUnlink();
	player CameraUnlink();	
}
#/

handleDamage()
{
	self endon ( "death" );
	self endon ( "deleted" );

	self setCanDamage( true );

	for ( ;; )
	{
	  self waittill( "damage" );
	  
	  println ( "projectile damaged!" );
	}
}	


MissileEyes( player, rocket )
{
	//level endon ( "game_ended" );
	player endon ( "joined_team" );
	player endon ( "joined_spectators" );

	rocket thread Rocket_CleanupOnDeath();
	player thread Player_CleanupOnGameEnded( rocket );
	player thread Player_CleanupOnTeamChange( rocket );
	
	player VisionSetMissilecamForPlayer( "black_bw", 0 );

	player endon ( "disconnect" );

	if ( isDefined( rocket ) )
	{
		player VisionSetMissilecamForPlayer( game["thermal_vision"], 1.0 );
		player thread delayedFOFOverlay();
		player CameraLinkTo( rocket, "tag_origin" );
		player ControlsLinkTo( rocket );

		if ( getDvarInt( "camera_thirdPerson" ) )
			player setThirdPersonDOF( false );
	
		rocket waittill( "death" );

		// is defined check required because remote missile doesnt handle lifetime explosion gracefully
		// instantly deletes its self after an explode and death notify
		if ( isDefined(rocket) )
			player maps\mp\_matchdata::logKillstreakEvent( "predator_missile", rocket.origin );
		
		player ControlsUnlink();
		player freezeControlsWrapper( true );
	
		// If a player gets the final kill with a hellfire, level.gameEnded will already be true at this point
		if ( !level._gameEnded || isDefined( player.finalKill ) )
			player thread staticEffect( 0.5 );

		wait ( 0.5 );
		
		player ThermalVisionFOFOverlayOff();
		
		player CameraUnlink();
		
		if ( getDvarInt( "camera_thirdPerson" ) )
			player setThirdPersonDOF( true );
		
	}
	
	player clearUsingRemote();
}


delayedFOFOverlay()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	
	wait ( 0.15 );
	
	self ThermalVisionFOFOverlayOn();
}

staticEffect( duration )
{
	self endon ( "disconnect" );
	
	staticBG = newClientHudElem( self );
	staticBG.horzAlign = "fullscreen";
	staticBG.vertAlign = "fullscreen";
	staticBG setShader( "white", 640, 480 );
	staticBG.archive = true;
	staticBG.sort = 10;

	static = newClientHudElem( self );
	static.horzAlign = "fullscreen";
	static.vertAlign = "fullscreen";
	static setShader( "ac130_overlay_grain", 640, 480 );
	static.archive = true;
	static.sort = 20;
	
	wait ( duration );
	
	static destroy();
	staticBG destroy();
}


Player_CleanupOnTeamChange( rocket )
{
	rocket endon ( "death" );
	self endon ( "disconnect" );

	self waittill_any( "joined_team" , "joined_spectators" );

	if ( self.team != "spectator" )
	{
		self ThermalVisionFOFOverlayOff();
		self ControlsUnlink();
		self CameraUnlink();	

		if ( getDvarInt( "camera_thirdPerson" ) )
			self setThirdPersonDOF( true );
	}
	self clearUsingRemote();
	
	level._remoteMissileInProgress = undefined;
}


Rocket_CleanupOnDeath()
{
	entityNumber = self getEntityNumber();
	level._rockets[ entityNumber ] = self;
	self waittill( "death" );	
	
	level._rockets[ entityNumber ] = undefined;
}


Player_CleanupOnGameEnded( rocket )
{
	rocket endon ( "death" );
	self endon ( "death" );
	
	level waittill ( "game_ended" );
	
	self ThermalVisionFOFOverlayOff();
	self ControlsUnlink();
	self CameraUnlink();	

	if ( getDvarInt( "camera_thirdPerson" ) )
		self setThirdPersonDOF( true );
}