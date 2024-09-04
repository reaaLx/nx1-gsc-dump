#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
	precacheString( &"MP_WAR_RADAR_ACQUIRED" );
	precacheString( &"MP_WAR_RADAR_ACQUIRED_ENEMY" );
	precacheString( &"MP_WAR_RADAR_EXPIRED" );
	precacheString( &"MP_WAR_RADAR_EXPIRED_ENEMY" );
	
	precacheString( &"MP_WAR_COUNTER_RADAR_ACQUIRED" );	
	precacheString( &"MP_WAR_COUNTER_RADAR_ACQUIRED_ENEMY" );
	precacheString( &"MP_WAR_COUNTER_RADAR_EXPIRED" );
	precacheString( &"MP_WAR_COUNTER_RADAR_EXPIRED_ENEMY" );
	
	precacheString( &"MP_LASE_TARGET_FOR_PREDATOR_STRIKE" );
	
	precacheModel( "vehicle_uav_static_mp" );
	
	precacheItem( "uavstrikebinoculars_mp" );
	precacheItem( "uav_strike_projectile_mp" );

	level._radarViewTime = 30; // time radar remains active
	level._uavBlockTime = 30; // this only seems to be used for the FFA version.
	
	assert( level._radarViewTime > 7 );
	assert( level._uavBlockTime > 7 );

	level._uav_fx[ "explode" ] = loadFx( "explosions/helicopter_explosion_cobra_low" );

	level._killStreakFuncs["uav"] = ::tryUseUAV;
	level._killStreakFuncs["double_uav"] = ::tryUseDoubleUAV;
	level._killStreakFuncs["counter_uav"] = ::tryUseCounterUAV;
	level._killstreakFuncs["uav_strike"] = ::tryUseUAVStrike;
	level._killstreakSetupFuncs["uav_strike"] = ::UAVStrikeSetup;

	level._effect[ "laserTarget" ] 	 = loadfx("nx/misc/nx_laser_glow");

	minimapOrigins = getEntArray( "minimap_corner", "targetname" );
	if ( miniMapOrigins.size )
		uavOrigin = maps\mp\gametypes\_spawnlogic::findBoxCenter( miniMapOrigins[0].origin, miniMapOrigins[1].origin );
	else
		uavOrigin = (0,0,0);
	
	level._UAVRig = spawn( "script_model", uavOrigin );
	level._UAVRig setModel( "c130_zoomrig" );
	level._UAVRig.angles = (0,115,0);
	level._UAVRig hide();

	level._UAVRig thread rotateUAVRig();
	
	if ( level._teamBased )
	{
		level._radarMode["allies"] = "normal_radar";
		level._radarMode["axis"] = "normal_radar";
		level._activeUAVs["allies"] = 0;
		level._activeUAVs["axis"] = 0;
		level._activeCounterUAVs["allies"] = 0;
		level._activeCounterUAVs["axis"] = 0;
		level._uavModels["allies"] = [];
		level._uavModels["axis"] = [];
		
		if( level._multiTeamBased )
		{
			for( i = 0; i < level._teamNameList.size; i++ )
			{
				level._radarMode[level._teamNameList[i]] = "normal_radar";
				level._activeUAVs[level._teamNameList[i]] = 0;
				level._activeCounterUAVs[level._teamNameList[i]] = 0;
				level._uavModels[level._teamNameList[i]] = [];
			}
		}
	}
	else
	{	
		level._radarMode = [];
		level._activeUAVs = [];
		level._activeCounterUAVs = [];
		
		level._uavModels = [];
		
		level thread onPlayerConnect();		
	}

	level thread UAVTracker();
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		level._activeUAVs[ player.guid ] = 0;
		level._activeCounterUAVs[ player.guid ] = 0;
		
		level._radarMode[ player.guid ] = "normal_radar";
	}
}

rotateUAVRig()
{
	for (;;)
	{
		self rotateyaw( -360, 60 );
		wait ( 60 );
	}
}


launchUAV( owner, team, duration, isCounter )
{
	UAVModel = spawn( "script_model", level._UAVRig getTagOrigin( "tag_origin" ) );

	UAVModel setModel( "vehicle_uav_static_mp" );
		
	UAVModel thread damageTracker( isCounter );
	UAVModel.team = team;
	UAVModel.owner = owner;

	UAVModel thread handleIncomingStinger();

	addUAVModel( UAVModel );

	zOffset = randomIntRange( 3000, 5000 );

	angle = randomInt( 360 );
	radiusOffset = randomInt( 2000 ) + 5000;

	xOffset = cos( angle ) * radiusOffset;
	yOffset = sin( angle ) * radiusOffset;

	angleVector = vectorNormalize( (xOffset,yOffset,zOffset) );
	angleVector = vector_multiply( angleVector, randomIntRange( 6000, 7000 ) );
	
	UAVModel linkTo( level._UAVRig, "tag_origin", angleVector, (0,angle - 90,0) );

	UAVModel thread updateUAVModelVisibility();	
		
	if ( isCounter )
		UAVModel addActiveCounterUAV();
	else
		UAVModel addActiveUAV();

	level notify ( "uav_update" );
	
	UAVModel waittill_notify_or_timeout_hostmigration_pause( "death", duration - 7 );

	if ( UAVModel.health <= 0 )
	{
		forward = vector_multiply( anglesToRight( UAVModel.angles ), 200 );
		playFx ( level._uav_fx[ "explode" ], UAVModel.origin, forward );
	}
	else
	{
		UAVModel unlink();
	
		destPoint = UAVModel.origin + vector_multiply( anglestoforward( UAVModel.angles ), 20000 );
		UAVModel moveTo( destPoint, 60 );
		PlayFXOnTag( level._effect[ "ac130_engineeffect" ] , UAVModel, "tag_origin" );

		UAVModel waittill_notify_or_timeout_hostmigration_pause( "death", 3 );

		UAVModel moveTo( destPoint, 4, 4, 0.0 );
	
		UAVModel waittill_notify_or_timeout_hostmigration_pause( "death", 4 );
	}

	if ( isCounter )
		UAVModel removeActiveCounterUAV();
	else
		UAVModel removeActiveUAV();

	UAVModel delete();
	removeUAVModel( UAVModel );

	level notify ( "uav_update" );
}

monitorUAVStrike()
{
	level endon( "game_ended" );
	for ( ;; )
	{
		msg = self waittill_any_return( "death", "uav_strike_cancel", "uav_strike_successful" );
		if ( msg == "uav_strike_successful" )
			return true;
		else
			return false;
	}
}

showLazeMessage()
{
	msg = self maps\mp\gametypes\_hud_util::createFontString( "bigfixed", 0.75 );
	msg maps\mp\gametypes\_hud_util::setPoint( "CENTER", "CENTER", 0 , 150 );
	msg setText( &"MP_LASE_TARGET_FOR_PREDATOR_STRIKE" );	
	
	self waittill_any_timeout( 4.0, "death", "uav_strike_cancel", "uav_strike_successful" );
	
	msg destroyElem();	
}

waitForLazeDiscard()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "uav_strike_used" );
	for ( ;; )
	{
		self waittill ( "weapon_change", newWeapon );
		
		if ( newWeapon != "uavstrikebinoculars_mp" )
		{		
			self notify( "uav_strike_cancel" );
			break;
		}
		else
			wait( 0.05 );
	}	
}

waitForLazedTarget()
{	
	level endon( "game_ended" );
	self endon( "death" );	
	
	self thread showLazeMessage();	
	self thread waitForLazeDiscard();

	weapon = self getLastWeapon();
	secondaryWeapon = undefined;	
	primaryWeapons = self GetWeaponsListPrimaries();
	foreach	( primaryWeapon in primaryWeapons )
	{
		if ( primaryWeapon != weapon )
		{
			secondaryWeapon = primaryWeapon;
			self takeWeapon( secondaryWeapon );
			break;
		}
	}	
	self _giveWeapon("uavstrikebinoculars_mp");
	self switchToWeapon( "uavstrikebinoculars_mp" );

	traceData = undefined;
	for(;;)
	{
		msg = self waittill_any_return( "weapon_fired", "uav_strike_cancel" );
		
		if ( msg == "uav_strike_cancel" )
			break;
		
		origin = self GetEye();
		forward = AnglesToForward( self GetPlayerAngles() );
		endpoint = origin + forward * 15000;
		
		traceData = BulletTrace( origin, endpoint, true, self );		
		if ( isDefined(traceData["position"]) )
			break;
	}
	
	if ( isDefined( traceData ) )
	{	

		targetPosition = traceData["position"];		
		
		fxEnt = SpawnFx( level._effect[ "laserTarget" ], targetPosition);
		TriggerFx( fxEnt );
		fxEnt thread waitFxEntDie();
	
		magicBullet( "uav_strike_projectile_mp", targetPosition + (0,0,4000) , targetPosition, self );
		self notify( "uav_strike_used" );	
	}
	 
		self takeWeapon( "uavstrikebinoculars_mp" );
		if ( msg != "uav_strike_cancel" )
			self switchToWeapon( weapon );
		if ( isDefined( secondaryWeapon ) )
			self _giveWeapon( secondaryWeapon );		
		
		if ( isDefined( traceData ) )
			self notify( "uav_strike_successful" );
}

waitFxEntDie()
{
	wait( 2 );
	self delete();
}

waittill_notify_or_timeout_hostmigration_pause( msg, timer )
{
	self endon( msg );
	
	maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( timer );
}


updateUAVModelVisibility()
{
	self endon ( "death" );

	for ( ;; )
	{
		level waittill_either ( "joined_team", "uav_update" );
		
		self hide();
		foreach ( player in level._players )
		{
			if ( level._teamBased )
			{
				if ( player.team != self.team )
					self showToPlayer( player );
			}
			else
			{
				if ( isDefined( self.owner ) && player == self.owner )
					continue;
					
				self showToPlayer( player );
			}
		}
	}	
}


damageTracker( isCounterUAV )
{
	level endon ( "game_ended" );
	
	self setCanDamage( true );
	self.maxhealth = 700;
	self.health = self.maxhealth;
	
	for ( ;; )
	{
		self waittill ( "damage", damage, attacker, direction_vec, point, sMeansOfDeath );
		
		if ( !isPlayer( attacker ) )
		{
			if ( !isDefined( self ) )
				return;
				
			continue;
		}
			
		attacker maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "" );

		if ( attacker _hasPerk( "specialty_armorpiercing" ) && isDefined( self ) )
		{
			damageAdd = damage*level._armorPiercingMod;
			self.health -= int(damageAdd);
		}
		
		if ( !isDefined( self ) )
		{
			if ( isPlayer( attacker ) && (!isDefined(self.owner) || attacker != self.owner) )
			{
				if ( isCounterUAV )
					thread teamPlayerCardSplash( "callout_destroyed_counter_uav", attacker );
				else
					thread teamPlayerCardSplash( "callout_destroyed_uav", attacker );

				thread maps\mp\gametypes\_missions::vehicleKilled( self.owner, self, undefined, attacker, damage, sMeansOfDeath );
				attacker thread maps\mp\gametypes\_rank::giveRankXP( "kill", 50 );
				attacker notify( "destroyed_killstreak" );
			}
			return;
		}
	}
}


tryUseUAV( lifeId )
{
	return useUAV( "uav" );
}


tryUseDoubleUAV( lifeId )
{
	return useUAV( "double_uav" );
}


tryUseCounterUAV( lifeId )
{
	return useUAV( "counter_uav" );
}


UAVStrikeSetup()
{
	self.usedStrikeUAV = 0;
}

tryUseUAVStrike( lifeId )
{
	if ( self.usedStrikeUAV == 0 )
	{
		self.usedStrikeUAV = 1;
		//useUAV( "uav_strike" );
	}
	self thread waitForLazedTarget();
	return monitorUAVStrike();
}

useUAV( uavType )
{
	self maps\mp\_matchdata::logKillstreakEvent( uavType, self.origin );

	team = self.pers["team"];		
	useTime = level._radarViewTime;

	level thread launchUAV( self, team, useTime, uavType == "counter_uav" );

	if ( uavType == "counter_uav" )
		self notify( "used_counter_uav" );
	else
		self notify( "used_uav" );
	
	return true;
}


UAVTracker()
{
	level endon ( "game_ended" );
	
	for ( ;; )
	{
		level waittill ( "uav_update" );
		
		if ( level._multiTeamBased )
		{
			for( i = 0; i < level._teamNameList.size; i++ )
			{
				updateTeamUAVStatus( level._teamNameList[i] );
			}
		}
		else if ( level._teamBased )
		{
			updateTeamUAVStatus( "allies" );
			updateTeamUAVStatus( "axis" );		
		}
		else
		{
			updatePlayersUAVStatus();
		}
	}
}


updateTeamUAVStatus( team )
{
	activeUAVs = level._activeUAVs[team];
	activeCounterUAVs = 0;
	
	if( level._multiTeamBased )
	{
		for( i = 0; i < level._teamNameList.size; i++ )
		{
			if( team != level._teamNameList[i] )
			{
				activeCounterUAVs += level._activeCounterUAVs[level._teamNameList[i]];
			}
		}
	}
	else
	{
		activeCounterUAVs = level._activeCounterUAVs[level._otherTeam[team]];
	}

	if ( !activeCounterUAVs )
		unblockTeamRadar( team );
	else
		blockTeamRadar( team );
		
	if ( !activeUAVs )
	{
		setTeamRadarWrapper( team, 0 );
		return;
	}

	if ( activeUAVs > 1 )
		level._radarMode[team] = "fast_radar";
	else
		level._radarMode[team] = "normal_radar";

	updateTeamUAVType();
	setTeamRadarWrapper( team, 1 );	
}


updatePlayersUAVStatus()
{
	totalActiveCounterUAVs = 0;
	counterUAVPlayer = undefined;
	
	foreach ( player in level._players )
	{
		activeUAVs = level._activeUAVs[ player.guid ];
		activeCounterUAVs = level._activeCounterUAVs[ player.guid ];
		
		if ( activeCounterUAVs )
		{
			totalActiveCounterUAVs++;
			counterUAVPlayer = player;
		}
		
		if ( !activeUAVs )
		{
			player.hasRadar = false;
			if( player.radarMode != "directional_radar" )
			{
				player.radarMode = "normal_radar";
				player.nextRadarMode = "normal_radar";
			}
			else
			{
				player.nextRadarMode = "normal_radar";
			}
			continue;
		}
		
		if ( activeUAVs > 1 )
			if( player.radarMode != "directional_radar" )
			{
				player.radarMode = "fast_radar";
			}
			else
			{
				player.nextRadarMode = "fast_radar";
			}
		else
		{
			if( player.radarMode != "directional_radar" )
			{
				player.radarMode = "normal_radar";
				player.nextRadarMode = "normal_radar";
			}
			else
			{
				player.nextRadarMode = "normal_radar";
			}
		}
			
		player.hasRadar = true;
	}
	
	foreach ( player in level._players )
	{
		if ( !totalActiveCounterUAVs )
		{
			player.isRadarBlocked = false;
			continue;
		}
		
		if ( totalActiveCounterUAVs == 1 && player == counterUAVPlayer )
			player.isRadarBlocked = false;
		else
			player.isRadarBlocked = true;
	}
}


blockPlayerUAV()
{
	self endon ( "disconnect" );
	
	self notify ( "blockPlayerUAV" );
	self endon ( "blockPlayerUAV" );

	self.isRadarBlocked = true;
	
	wait ( level._uavBlockTime );

	self.isRadarBlocked = false;

	//self iPrintLn( &"MP_WAR_COUNTER_RADAR_EXPIRED" );
}


updateTeamUAVType()
{
	foreach ( player in level._players )
	{
		if ( player.team == "spectator" )
			continue;
		
		if( player.radarMode != "directional_radar" )
		{
			player.radarMode = level._radarMode[player.team];
		}
		else
		{
			player.nextRadarMode = level._radarMode[player.team];
		}
	}
}



usePlayerUAV( doubleUAV, useTime )
{
	level endon("game_ended");
	self endon("disconnect");

	self notify ( "usePlayerUAV" );
	self endon ( "usePlayerUAV" );
	
	if ( doubleUAV )
	{
		if( self.radarMode != "directional_radar" )
		{
			self.radarMode = "fast_radar";
		}
		else
		{
			self.nextRadarMode = "fast_radar";
		}
	}
	else
	{
		if( self.radarMode != "directional_radar" )
		{
			self.radarMode = "normal_radar";
			self.nextRadarMode = "normal_radar";
		}
		else
		{
			self.nextRadarMode = "normal_radar";
		}
	}

	self.hasRadar = true;
	
	wait ( useTime );
	
	if( self.radarMode != "directional_radar" )
	{
		self.hasRadar = false;
	}
	
	//self iPrintLn( &"MP_WAR_RADAR_EXPIRED" );
}


setTeamRadarWrapper( team, value )
{
	setTeamRadar( team, value );
	level notify( "radar_status_change", team );
}



handleIncomingStinger()
{
	level endon ( "game_ended" );
	self endon ( "death" );
	
	for ( ;; )
	{
		level waittill ( "stinger_fired", player, missile, lockTarget );
		
		if ( !IsDefined( lockTarget ) || (lockTarget != self) )
			continue;
			
		missile thread stingerProximityDetonate( lockTarget, player );
	}
}


stingerProximityDetonate( targetEnt, player )
{
	self endon ( "death" );

	minDist = distance( self.origin, targetEnt GetPointInBounds( 0, 0, 0 ) );
	lastCenter = targetEnt GetPointInBounds( 0, 0, 0 );

	for ( ;; )
	{
		// UAV already destroyed
		if ( !isDefined( targetEnt ) )
			center = lastCenter;
		else
			center = targetEnt GetPointInBounds( 0, 0, 0 );
			
		lastCenter = center;		
		
		curDist = distance( self.origin, center );
		
		if ( curDist < minDist )
			minDist = curDist;
		
		if ( curDist > minDist )
		{
			if ( curDist > 1536 )
				return;
				
			radiusDamage( self.origin, 1536, 600, 600, player );
			playFx( level._stingerFXid, self.origin );

			//self playSound( "remotemissile_explode" );
			self hide();
			
			self notify("deleted");
			wait ( 0.05 );
			self delete();
			player notify( "killstreak_destroyed" );
		}
		
		wait ( 0.05 );
	}	
}


addUAVModel( UAVModel )
{
	if ( level._teamBased )
		level._UAVModels[UAVModel.team][level._UAVModels[UAVModel.team].size] = UAVModel;
	else
		level._UAVModels[UAVModel.owner.guid + "_" + getTime()] = UAVModel;	
}	


removeUAVModel( UAVModel )
{
	UAVModels = [];

	if ( level._teamBased )
	{
		team = UAVModel.team;
		
		foreach ( uavModel in level._UAVModels[team] )
		{
			if ( !isDefined( uavModel ) )
				continue;
				
			UAVModels[UAVModels.size] = uavModel;
		}

		level._UAVModels[team] = UAVModels;
	}
	else
	{
		foreach ( uavModel in level._UAVModels )
		{
			if ( !isDefined( uavModel ) )
				continue;
				
			UAVModels[UAVModels.size] = uavModel;
		}

		level._UAVModels = UAVModels;
	}	
}


addActiveUAV()
{
	if ( level._teamBased )
		level._activeUAVs[self.team]++;	
	else
		level._activeUAVs[self.owner.guid]++;
/*
	if ( level._teamBased )
	{
		foreach ( player in level._players )
		{
			if ( player.team == self.team )
				player iPrintLn( &"MP_WAR_RADAR_ACQUIRED", self.owner, level._radarViewTime );
			else if ( player.team == level._otherTeam[self.team] )
				player iPrintLn( &"MP_WAR_RADAR_ACQUIRED_ENEMY", level._radarViewTime  );
		}
	}	
	else
	{
		foreach ( player in level._players )
		{
			if ( player == self.owner )
				player iPrintLn( &"MP_WAR_RADAR_ACQUIRED", self.owner, level._radarViewTime );
			else
				player iPrintLn( &"MP_WAR_RADAR_ACQUIRED_ENEMY", level._radarViewTime );
		}
	}
*/
}


addActiveCounterUAV()
{
	if ( level._teamBased )
		level._activeCounterUAVs[self.team]++;	
	else
		level._activeCounterUAVs[self.owner.guid]++;	
/*
	if ( level._teamBased )
	{
		foreach ( player in level._players )
		{
			if ( player.team == self.team )
				player iPrintLn( &"MP_WAR_COUNTER_RADAR_ACQUIRED", self.owner, level._uavBlockTime );
			else if ( player.team == level._otherTeam[self.team] )
				player iPrintLn( &"MP_WAR_COUNTER_RADAR_ACQUIRED_ENEMY", level._uavBlockTime );
		}
	}	
	else
	{
		foreach ( player in level._players )
		{
			if ( player == self.owner )
				player iPrintLn( &"MP_WAR_COUNTER_RADAR_ACQUIRED", self.owner, level._uavBlockTime );
			else
				player iPrintLn( &"MP_WAR_COUNTER_RADAR_ACQUIRED_ENEMY", level._uavBlockTime );
		}
	}
*/
}


removeActiveUAV()
{
	if ( level._teamBased )
	{
		level._activeUAVs[self.team]--;
		
		if ( !level._activeUAVs[self.team] )
		{
			//printOnTeam( &"MP_WAR_RADAR_EXPIRED", self.team );
			//printOnTeam( &"MP_WAR_RADAR_EXPIRED_ENEMY", level._otherTeam[self.team] );
		}
	}
	else if ( isDefined( self.owner ) )
	{
		level._activeUAVs[self.owner.guid]--;
	}
}


removeActiveCounterUAV()
{
	if ( level._teamBased )
	{
		level._activeCounterUAVs[self.team]--;

		if ( !level._activeCounterUAVs[self.team] )
		{
			//printOnTeam( &"MP_WAR_COUNTER_RADAR_EXPIRED", self.team );
			//printOnTeam( &"MP_WAR_COUNTER_RADAR_EXPIRED_ENEMY", level._otherTeam[self.team] );
		}
	}
	else if ( isDefined( self.owner ) )
	{
		level._activeCounterUAVs[self.owner.guid]--;
	}
}

MeleeUAV()
{
	level endon ( "game_ended" );
	self endon ( "disconnect" );

	self.radarMode = "directional_radar";
//	self.hasRadar = true;
		
	wait ( 5 );
		
//	self.hasRadar = false;
	if( isDefined( self.nextRadarMode ))
	{
		self.radarMode = self.nextRadarMode;
	}
	else
	{
		self.radarMode = "normal_radar";
	}
}