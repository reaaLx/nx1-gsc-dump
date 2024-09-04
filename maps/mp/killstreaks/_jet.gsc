#include maps\mp\_utility;
#include common_scripts\utility;

JET_MISSILE_DIRECTION = ( 1.0, 1.0, 20.0 );

// Each Killstreak has its own initialization function.  This Script has two main purposes.
// (1). All global data and assets used by this killstreak should be initialized here.
// (2). The callback that executes when a player activates this killstreak should be set here.
// TODO: A call to this script must be added to the script init() in the file c:\trees\nx1\game\share\raw\maps\mp\killstreaks\_killstreaks.gsc, 
// this is were each individual killstreak is initialized.
init()
{
	//precacheItem( "f50_remote_mp" );
	precacheModel( "vehicle_f50" );
	PrecacheMiniMapIcon( "compass_objpoint_airstrike_friendly" );
	PrecacheMiniMapIcon( "compass_objpoint_airstrike_busy" );
	PrecacheMiniMapIcon( "compass_objpoint_b2_airstrike_friendly" );

	PrecacheMiniMapIcon( "compass_objpoint_b2_airstrike_enemy" );


	level._killStreakFuncs["jet"] = ::tryUseJet;

	level._onfirefx = loadfx ("fire/fire_smoke_trail_L");
	level._fx_airstrike_afterburner = loadfx ("fire/jet_afterburner");
	level._fx_airstrike_contrail = loadfx ("smoke/jet_contrail");
	level._planes = 0;
	level._rockets = [];

}

tryUseJet( lifeId )
{
	println( "tryuseJet" );
	if ( isDefined( level._civilianJetFlyBy ) )
	{
		self iPrintLnBold( &"MP_CIVILIAN_AIR_TRAFFIC" );
		return false;
	}

	if ( self isUsingRemote() )
	{
		return false;
	}

	result = self selectJetLocation( lifeId );

	if ( !isDefined( result ) || !result )
		return false;
	
	return true;
}

selectJetLocation( lifeId )
{
	println( "SelectJetLocation" );
	chooseDirection = true;

	targetSize = level._mapSize / 5.625; // 138 in 720
	if ( level._splitscreen )
		targetSize *= 1.5;
	
	self beginLocationSelection( "map_artillery_selector", chooseDirection, false, targetSize );
	self.selectingLocation = true;

	self setblurforplayer( 4.0, 0.3 );
	self thread waitForJetCancel();

	self thread endJetSelectionOn( "cancel_location" );
	self thread endJetSelectionOn( "death" );
	self thread endJetSelectionOn( "disconnect" );
	self thread endJetSelectionOn( "used" ); // so that this thread doesn't kill itself when we use an airstrike
	self thread endJetSelectionOnGameEnd();
	self thread endJetSelectionOnEMP();

	self endon( "stop_location_selection" );

	// wait for the selection. randomize the yaw if we're not doing a precision airstrike.
	self waittill( "confirm_location", location, directionYaw );
	
	self setblurforplayer( 0, 0.3 );
	
	self thread finishJetUsage( lifeId, location, directionYaw );
	return true;
}

finishJetUsage( lifeId, location, directionYaw )
{
	println( "finishJetUsage" );
	self notify( "used" );

	// find underside of top of skybox
	trace = bullettrace( level._mapCenter + (0,0,1000000), level._mapCenter, false, undefined );
	location = (location[0], location[1], trace["position"][2] - 514);

	self thread doJetAirStrike( lifeId, location, directionYaw, self, self.pers["team"] );
}


doJetAirStrike( lifeId, origin, yaw, owner, team )
{	
	println( "doJetAirStrike" );
	assert( isDefined( origin ) );
	assert( isDefined( yaw ) );
	
	if ( isDefined( level._airstrikeInProgress ) )
	{
		while ( isDefined( level._airstrikeInProgress ) )
			level waittill ( "begin_airstrike" );

		level._airstrikeInProgress = true;
		wait ( 2.0 );
	}

	if ( !isDefined( owner ) )
	{
		return;
	}

	level._airstrikeInProgress = true;
	
	num = 17 + randomint(3);
	trace = bullettrace(origin, origin + (0,0,-1000000), false, undefined);
	targetpos = trace["position"];

	if ( level._teambased )
	{
		players = level._players;
		
		for ( i = 0; i < level._players.size; i++ )
		{
			player = level._players[i];
			playerteam = player.pers["team"];
			if ( isdefined( playerteam ) )
			{
				player iprintln( &"MP_WAR_AIRSTRIKE_INBOUND", owner );
			}
		}
	}
	
	self callJetStrike( lifeId, owner, targetpos, yaw );
	

	wait( 1.0 );
	level._airstrikeInProgress = undefined;
	owner notify ( "begin_airstrike" );
	level notify ( "begin_airstrike" );
	
	wait 7.5;

	found = false;
	
}

callJetStrike( lifeId, owner, coord, yaw )
{	
	println( "calljetstrike" );
	heightEnt = undefined;
	// Get starting and ending point for the plane
	direction = ( 0, yaw, 0 );
	heightEnt = GetEnt( "airstrikeheight", "targetname" );

	thread teamPlayerCardSplash( "used_stealth_airstrike", owner, owner.team );
		
	planeHalfDistance = 12000;
	planeFlySpeed = 2000;
		
	if ( !isDefined( heightEnt ) )//old system 
		{
			println( "NO DEFINED AIRSTRIKE HEIGHT SCRIPT_ORIGIN IN LEVEL" );
			planeFlyHeight = 2000;
			if ( isdefined( level._airstrikeHeightScale ) )
			{
				planeFlyHeight *= level._airstrikeHeightScale;
			}
		}
		else
		{
			planeFlyHeight = heightEnt.origin[2];
		}

	startPoint = coord + vector_multiply( anglestoforward( direction ), -1 * planeHalfDistance );
	
	if ( isDefined( heightEnt ) )// used in the new height system
		startPoint *= (1,1,0);
		
	startPoint += ( 0, 0, planeFlyHeight );


		endPoint = coord + vector_multiply( anglestoforward( direction ), planeHalfDistance*4 );
		
	if ( isDefined( heightEnt ) )// used in the new height system
		endPoint *= (1,1,0);
		
	endPoint += ( 0, 0, planeFlyHeight );
	
	// Make the plane fly by
	d = length( startPoint - endPoint );
	flyTime = ( d / planeFlySpeed ); 	
	owner endon("disconnect");
	
	requiredDeathCount = lifeId;

	self doJetStrike( lifeId, owner, startPoint+(0,0,randomInt(1000)), endPoint+(0,0,randomInt(1000)), flyTime, direction );
	
}

endJetSelectionOn( waitfor )
{
	self endon( "stop_location_selection" );
	self waittill( waitfor );
	self thread stopJetLocationSelection( (waitfor == "disconnect") );
}

endJetSelectionOnGameEnd()
{
	self endon( "stop_location_selection" );
	level waittill( "game_ended" );
	self thread stopJetLocationSelection( false );
}

endJetSelectionOnEMP()
{
	self endon( "stop_location_selection" );
	for ( ;; )
	{
		level waittill( "emp_update" );
	
		if ( !self isEMPed() )
			continue;
			
		self thread stopJetLocationSelection( false );
		return;
	}
}

doJetStrike( lifeId, owner, startPoint, endPoint, flyTime, direction )
{
	self notifyOnPlayerCommand( "trigger_pulled", "+attack" );
	// plane spawning randomness = up to 125 units, biased towards 0
	// radius of bomb damage is 512
	println( "doJetStrike" );
	if ( !isDefined( owner ) ) 
		return;
	
	startPathRandomness = 100;
	endPathRandomness = 150;
	
	pathStart = startPoint + ( (randomfloat(2) - 1)*startPathRandomness, (randomfloat(2) - 1)*startPathRandomness, 0 );
	pathEnd   = endPoint   + ( (randomfloat(2) - 1)*endPathRandomness  , (randomfloat(2) - 1)*endPathRandomness  , 0 );
	
	// Spawn the planes
	plane = spawnplane( owner, "script_model", pathStart, "compass_objpoint_b2_airstrike_friendly", "compass_objpoint_b2_airstrike_enemy" );
	
	plane playLoopSound( "veh_b2_dist_loop" );
	plane setModel( "vehicle_f50" );
	plane thread handleJetEMP( owner );
	plane.lifeId = lifeId;

	plane.angles = direction;
	forward = anglesToForward( direction );
	plane thread playJetPlaneFx();
	
	//self HideHud();

	//self VisionSetMissilecamForPlayer( game["thermal_vision"], 1.0 );
	self PlayerLinkWeaponviewToDelta( plane, "tag_player", 1.0, 45, 45, 0, 45, false );
	//self CameraLinkTo( plane, "tag_player" );

	//self ThermalVisionOn();
	//self ThermalVisionFOFOverlayOn();

	self _giveWeapon("heli_remote_mp");
	self SwitchToWeapon( "heli_remote_mp" );
	self DisableWeaponSwitch();
	self _disableOffhandWeapons();

	plane moveTo( pathEnd, flyTime, 0, 0 );

	println ("Before loop");

	plane thread jetTimeout( flyTime );

	self waittill ("trigger_pulled");

	println ("Fired Gun" );
	origin = self GetEye();
	forward = AnglesToForward( self GetPlayerAngles() );
	endpoint = origin + forward;
	println ( "origin :" + origin );
	println ( "endpoint :" + endpoint );
	println ( "forward :" + forward );


	//bomb = spawnbomb( plane.origin, plane.angles );
	//bomb moveGravity( vector_multiply( anglestoforward( plane.angles ), 7000/1.5 ), 3.0 );

	rocket = MagicBullet( "remotemissile_projectile_mp", origin, endpoint, owner );

	rocket thread JetMissilehandleDamage();
	self unlink();
	self CameraLinkTo( rocket, "tag_origin" );
	self ControlsLinkTo( rocket );
	//self ThermalVisionFOFOverlayOff();
	rocket thread JetRocket_CleanupOnDeath();


	rocket waittill( "death" );
	self thread staticEffect( 0.5 );
	self ControlsUnlink();
	self CameraUnlink();

	self thread Weapon_Return ();

	println ("done with loop");	
}

jetTimeout( flyTime )
{
	// Delete the plane after its flyby
	wait ( flyTime / 2.3 );
	self notify( "delete" );
	self delete();
}

waitForJetCancel()
{
	self waittill( "cancel_location" );
	self setblurforplayer( 0, 0.3 );
}

stopJetLocationSelection( disconnected )
{
	if ( !disconnected )
	{
		self setblurforplayer( 0, 0.3 );
		self endLocationSelection();
		self.selectingLocation = undefined;
	}
	self notify( "stop_location_selection" );
}

useJet( lifeId, pos, yaw )
{
}

handleJetEMP( owner )
{
	self endon ( "death" );

	if ( owner isEMPed() )
	{
		playFxOnTag( level._onfirefx, self, "tag_engine_right" );
		playFxOnTag( level._onfirefx, self, "tag_engine_left" );
		return;
	}
	
	for ( ;; )
	{
		level waittill ( "emp_update" );
		
		if ( !owner isEMPed() )
			continue;
			
		playFxOnTag( level._onfirefx, self, "tag_engine_right" );
		playFxOnTag( level._onfirefx, self, "tag_engine_left" );		
	}
}

JetRocket_CleanupOnDeath()
{
	entityNumber = self getEntityNumber();
	level._rockets[ entityNumber ] = self;
	self waittill( "death" );	
	
	level._rockets[ entityNumber ] = undefined;
}

Weapon_Return()
{
	//self showhud; 
	self takeWeapon( "heli_remote_mp" );
	self enableWeaponSwitch();
	self switchToWeapon( self getLastWeapon() );
	self _enableOffhandWeapons();
}		


JetMissilehandleDamage()
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
	
playJetPlaneFx()
{
	self endon ( "death" );

	wait( 0.5);
	playfxontag( level._fx_airstrike_afterburner, self, "tag_engine_right" );
	wait( 0.5);
	playfxontag( level._fx_airstrike_afterburner, self, "tag_engine_left" );
	wait( 0.5);
	playfxontag( level._fx_airstrike_contrail, self, "tag_right_wingtip" );
	wait( 0.5);
	playfxontag( level._fx_airstrike_contrail, self, "tag_left_wingtip" );
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