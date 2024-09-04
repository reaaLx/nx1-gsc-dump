#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
	precacheString( &"MP_LASE_TARGET_FOR_GUIDED_MORTAR" );
	precacheString( &"MP_WAIT_FOR_MORTAR_READY" );
	precacheString( &"MP_MORTAR_ROUNDS_DEPLETED" );
	
	precacheItem( "remote_mortar_missile_mp" );
	PreCacheItem( "mortar_remote_mp" );
	
	level._remote_mortar_fx["tracer"] = loadFx( "misc/tracer_incoming" );
	level._remote_mortar_fx["explosion"] = loadFx( "explosions/building_explosion_huge_gulag" );
	
	level._effect[ "laserTarget" ] 	 = loadfx("nx/misc/nx_laser_glow");
	level._killstreakFuncs["remote_mortar"] = ::tryUseRemoteMortar;

}


tryUseRemoteMortar( lifeId )
{
	if ( isDefined( self.lastStand ) && !self _hasPerk( "specialty_finalstand" ) )
	{
		self iPrintLnBold( &"MP_UNAVILABLE_IN_LASTSTAND" );
		return false;
	}

	self setUsingRemote( "remote_mortar" );
	result = self maps\mp\killstreaks\_killstreaks::initRideKillstreak();
	if ( result != "success" )
	{
		if ( result != "disconnect" )
			self clearUsingRemote();

		return false;
	}

	self thread teamPlayerCardSplash( "used_remote_mortar", self );
	return startRemoteMortar( lifeId );
}


startRemoteMortar( lifeId )
{
	remote = spawnRemote( lifeId, self );
	if ( !isDefined( remote ) )
		return false;

	self thread linkRemoteTargeting( remote );
	
	self maps\mp\_matchdata::logKillstreakEvent( "remote_mortar", self.origin );
	return true;
}


spawnRemote( lifeId, owner )
{
	remote = spawnplane( owner, "script_model", level._UAVRig getTagOrigin( "tag_origin" ) );
	if ( !isDefined( remote ) )
		return undefined;
		
	remote setModel( "vehicle_uav_static_mp" );
	remote thread maps\mp\killstreaks\_uav::damageTracker( false );
	remote.team = owner.team;
	remote.owner = owner;
	remote.lifeId = lifeId;
	remote.heliType = "remote_mortar";
	
	remote thread maps\mp\killstreaks\_helicopter::heli_flares_monitor();
	
	maps\mp\killstreaks\_uav::addUAVModel( remote );	

	//	3000, 4000, and 6500 are all average numbers pulled from the random ranges UAV uses
	//	since the player's camera is linked to this vehicle, we want to control the location
	zOffset = 3000;
	angle = 0;
	radiusOffset = 4000;
	xOffset = cos( angle ) * radiusOffset;
	yOffset = sin( angle ) * radiusOffset;
	angleVector = vectorNormalize( (xOffset,yOffset,zOffset) );
	angleVector = ( angleVector * 6500 );
	
	remote linkTo( level._UAVRig, "tag_origin", angleVector, (0,angle-90,0) );
	
	remote thread handleDeath( owner );
	remote thread handleTimeout( owner );
	remote thread handleOwnerDisconnect( owner );
	
	return remote;	
}


showLazeMessage( remote, state, time )
{
	level endon( "game_ended" );
	self endon ( "disconnect" );
	remote endon ( "death" );	
	self notify( "showing_laze_message" );
	self  endon( "showing_laze_message" );
	
	if ( isDefined( remote.msg ) )
		remote.msg destroyElem();	
		
	text = "";
	switch( state )
	{
		case "ready":
			text = &"MP_LASE_TARGET_FOR_GUIDED_MORTAR";
			color = (0.2, 1.0, 0.2);
			break;			
		case "wait":
			text = &"MP_WAIT_FOR_MORTAR_READY";
			color = (0.8, 0.8, 0.2);		
			break;
		case "done":
			text = &"MP_MORTAR_ROUNDS_DEPLETED";
			color = (1.0, 0.2, 0.2);		
			break;	
		default:
			return;	
	}	
	
	remote.msg = self maps\mp\gametypes\_hud_util::createFontString( "objective", 1.5 );
	remote.msg maps\mp\gametypes\_hud_util::setPoint( "CENTER", "CENTER", 0 , 150 );
	remote.msg setText( text );	
	remote.msg.color = color;
	
	if ( !isDefined( time ) )
		time = 2.0;
	wait( time );
	
	if ( isDefined( remote.msg ) )
		remote.msg destroyElem();	
}


lookCenter()
{
	wait( 0.05 );
	
	lookVec = vectorToAngles( level._UAVRig.origin - self GetEye() );
	
	self setPlayerAngles( lookVec  );
}

linkRemoteTargeting( remote )
{
	level  endon( "game_ended" );
	self   endon( "disconnect" );
	remote endon( "helicopter_done" );
	remote endon( "death" );

	self VisionSetThermalForPlayer( game["thermal_vision"], 0 );
	self _giveWeapon("mortar_remote_mp");
	self SwitchToWeapon("mortar_remote_mp");	
	self ThermalVisionOn();
	self ThermalVisionFOFOverlayOn();
	self thread maps\mp\killstreaks\_helicopter::thermalVision( remote );
	if ( getDvarInt( "camera_thirdPerson" ) )
		self setThirdPersonDOF( false );

	self PlayerLinkWeaponviewToDelta( remote, "tag_player", 1.0, 180, 180, 0, 180, true );	
	self thread lookCenter();
	
	remote thread maps\mp\killstreaks\_helicopter::heli_targeting();	
	self thread maps\mp\killstreaks\_helicopter::weaponLockThink( remote );
	
	//	msg
	self thread showLazeMessage( remote, "ready", 5 );
	
	//	fire
	shotsFired = 0;
	while ( true )
	{
		if ( self attackButtonPressed() )
		{
		 	origin = self GetEye();
			forward = AnglesToForward( self GetPlayerAngles() );
			endpoint = origin + forward * 15000;
	
			traceData = BulletTrace( origin, endpoint, true, self );
			if ( isDefined( traceData["position"] ) ) 	
			{
				self playLocalSound( "stinger_locking" );
				self PlayRumbleOnEntity( "ac130_25mm_fire" );
				
				remote.fxEnt = SpawnFx( level._effect[ "laserTarget" ], traceData["position"] );
				TriggerFx( remote.fxEnt );
				// wait ( 1.0 );
				self thread launchMortar( remote, traceData["position"] );
				
				shotsFired++;
				if ( shotsFired < 3 )
				{
					self thread showLazeMessage( remote, "wait" );
					wait( 2.0 );
					remote.fxEnt delete();
					self thread showLazeMessage( remote, "ready" );
				}
				else
				{
					self thread showLazeMessage( remote, "wait" );
					wait( 2.0 );
					remote.fxEnt delete();
					self thread showLazeMessage( remote, "done" );
					wait( 2.0 );
					break;
				}				
			}
			else
				wait( 0.05 );
		}
		else
			wait( 0.05 );
	}	
	
	self unlinkRemoteTargeting();
	remote thread remoteLeave();
}


launchMortar( remote, pos )
{
	PlayFx( level._remote_mortar_fx["tracer"], pos );
	thread playSoundinSpace( "fast_artillery_round", pos );
	
	wait( 1 );
	
	PlayFx( level._remote_mortar_fx["explosion"], pos );
	Earthquake( 1.0, 0.6, pos, 2000 );	
	thread playSoundinSpace( "exp_suitcase_bomb_main", pos );
	physicsExplosionSphere( pos + (0,0,30), 250, 125, 2 );		
	if ( isDefined( self ) )	
		remote RadiusDamage( pos, 400, 200, 50, self, "MOD_EXPLOSIVE", "remote_mortar_missile_mp" );
	else
		remote RadiusDamage( pos, 400, 200, 50, undefined, "MOD_EXPLOSIVE", "remote_mortar_missile_mp" );
}


unlinkRemoteTargeting()
{
	self RemoteCameraSoundscapeOff();
	self ThermalVisionOff();
	self ThermalVisionFOFOverlayOff();
	self unlink();
	self clearUsingRemote();
	if ( getDvarInt( "camera_thirdPerson" ) )
		self setThirdPersonDOF( true );
	self visionSetThermalForPlayer( game["thermal_vision"], 0 );
	
	self switchToWeapon( self getLastWeapon() );
	weaponList = self GetWeaponsListExclusives();
	foreach ( weapon in weaponList )
		self takeWeapon( weapon );	
}


handleTimeout( owner )
{
	level endon( "game_ended" );
	owner endon( "disconnect" );
	self  endon( "death" );	
	self  endon( "helicopter_done" );
	
	maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( 45.0 );
	
	if ( isDefined( owner ) )
		owner unlinkRemoteTargeting();
	self thread remoteLeave();	
}


handleDeath( owner )
{
	level endon( "game_ended" );	
	owner endon( "disconnect" );
	self endon( "helicopter_done" );
	
	self waittill( "death" );
	
	owner unlinkRemoteTargeting();		
	
	forward = ( AnglesToRight( self.angles ) * 200 );
	playFx ( level._uav_fx[ "explode" ], self.origin, forward );
	
	level thread removeRemote( self );
	self notify( "helicopter_done" );
}


handleOwnerDisconnect( owner )
{
	level endon( "game_ended" );
	owner endon( "death" );
	self  endon( "death" );
	
	owner waittill( "disconnect" );
	
	self thread remoteLeave();
}


removeRemote( remote )
{
	if ( isDefined( remote.msg ) )
		remote.msg destroyElem();	
	if ( isDefined( remote.fxEnt ) )
		remote.fxEnt delete();
	remote delete();
	maps\mp\killstreaks\_uav::removeUAVModel( remote );	
}


remoteLeave()
{
	level endon( "game_ended" );
	self  endon( "death" );
	
	self notify( "helicopter_done" );
	self unlink();

	destPoint = self.origin + ( AnglesToForward( self.angles ) * 20000 );
	self moveTo( destPoint, 60 );
	PlayFXOnTag( level._effect[ "ac130_engineeffect" ] , self, "tag_origin" );
	maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( 3 );

	self moveTo( destPoint, 4, 4, 0.0 );
	maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( 4 );	
	
	level thread removeRemote( self );	
}
