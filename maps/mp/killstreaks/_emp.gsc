#include maps\mp\_utility;
#include common_scripts\utility;


init()
{
	level._effect[ "emp_flash" ] = loadfx( "explosions/emp_flash_mp" );

	level._teamEMPed["allies"] = false;
	level._teamEMPed["axis"] = false;
	
	if( level._multiTeamBased )
	{
		for( i = 0; i < level._teamNameList.size; i++ )
		{
			level._teamEMPed[level._teamNameList[i]] = false;
		}
	
	}
	level._empPlayer = undefined;
	
	if ( level._teamBased )
		level thread EMP_TeamTracker();
	else
		level thread EMP_PlayerTracker();
	
	level._killstreakFuncs["emp"] = ::EMP_Use;
	
	level thread onPlayerConnect();
	
}



onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
	}
}


onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill( "spawned_player" );
		
		if ( (level._teamBased && level._teamEMPed[self.team]) || (!level._teamBased && isDefined( level._empPlayer ) && level._empPlayer != self) )
			self setEMPJammed( true );
	}
}


EMP_Use( lifeId, delay )
{
	assert( isDefined( self ) );

	if ( !isDefined( delay ) )
		delay = 5.0;

	myTeam = self.pers["team"];
	
	if ( level._teamBased )
		self thread EMP_JamTeams( myTeam, 60.0, delay );
	else
		self thread EMP_JamPlayers( self, 60.0, delay );

	self maps\mp\_matchdata::logKillstreakEvent( "emp", self.origin );
	self notify( "used_emp" );

	return true;
}


EMP_JamTeams( teamName, duration, delay )
{
	level endon ( "game_ended" );

	thread teamPlayerCardSplash( "used_emp", self );

	level notify ( "EMP_JamTeams" + teamName );
	level endon ( "EMP_JamTeams" + teamName );
	
	foreach ( player in level._players )
	{
		player playLocalSound( "emp_activate" );
		
		if ( player.team == teamName )
		{
			continue;
		}
		else 
		{
			player.gotEMPed = true;
			if ( player _hasPerk( "specialty_flakjacket" ))
			{
				player notify ( "disableTrophy" );
			}
		}		
		
		if ( player _hasPerk( "specialty_localjammer" ) )
			player RadarJamOff();
	}
	
	visionSetNaked( "coup_sunblind", 0.1 );
	thread empEffects();
	
	wait ( 0.1 );
	
	// resetting the vision set to the same thing won't normally have an effect.
	// however, if the client receives the previous visionset change in the same packet as this one,
	// this will force them to lerp from the bright one to the normal one.
	visionSetNaked( "coup_sunblind", 0 );
	visionSetNaked( getDvar( "mapname" ), 3.0 );
	
	foreach( team in level._teamNameList )
	{
		if ( team != teamName )
		{
			level._teamEMPed[team] = true;
		}
	}
	
	level notify ( "emp_update" );
	
	level destroyActiveVehicles( self );
	
	maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( duration );
	
	foreach( team in level._teamNameList )
	{
		if ( team != teamName )
		{
			level._teamEMPed[team] = false;
		}
	}
	
	foreach ( player in level._players )
	{
		if ( player.team == teamName )
		{
			continue;
		}
		else
		{
			player.gotEMPed = false;
			if ( (player _hasPerk( "specialty_flakjacket" )) && !(isDefined ( player.gotEMPGrenaded ) && player.gotEMPGrenaded == true))
			{
				player notify ( "enableTrophy" );
			}
		}	
		
		if ( player _hasPerk( "specialty_localjammer" ) )
			player RadarJamOn();
	}
	level notify ( "emp_update" );
	level notify ( "enableTrophy" );
}

EMPGrenade_JamPlayer( duration )
{
	level endon ( "EMP_JamPlayers" );
	self endon ( "death" );
	self endon ( "disconnect" );
		
	self playLocalSound( "emp_activate" );
	
	if ( self _hasPerk( "specialty_localjammer" ) )
		self RadarJamOff();

	self.gotEMPGrenaded = true;
	if (self _hasPerk( "specialty_flakjacket" ))
	{
		self notify ( "disableTrophy" );
	}

	wait ( 0.1 );
	
	self setEMPJammed( true );
	
	maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( duration );
	
	self setEMPJammed( false );
	
	if ( self _hasPerk( "specialty_localjammer" ) )
		self RadarJamOn();

	self.gotEMPGrenaded = false;
	if ( (self _hasPerk( "specialty_flakjacket" )) && !(isDefined ( self.gotEMPed ) && self.gotEMPed == true ))
	{
		self notify ( "enableTrophy" );
	}
}

EMP_JamPlayers( owner, duration, delay )
{
	level notify ( "EMP_JamPlayers" );
	level endon ( "EMP_JamPlayers" );
	
	assert( isDefined( owner ) );
	
	//wait ( delay );
	
	foreach ( player in level._players )
	{
		player playLocalSound( "emp_activate" );
		
		if ( player == owner )
		{
			continue;
		}
		else 
		{
			player.gotEMPed = true;
			if ( player _hasPerk( "specialty_flakjacket" ))
			{
				player notify ( "disableTrophy" );
			}
		}			
		
		if ( player _hasPerk( "specialty_localjammer" ) )
			player RadarJamOff();
	}
	
	visionSetNaked( "coup_sunblind", 0.1 );
	thread empEffects();

	wait ( 0.1 );
	
	// resetting the vision set to the same thing won't normally have an effect.
	// however, if the client receives the previous visionset change in the same packet as this one,
	// this will force them to lerp from the bright one to the normal one.
	visionSetNaked( "coup_sunblind", 0 );
	visionSetNaked( getDvar( "mapname" ), 3.0 );
	
	level notify ( "emp_update" );
	
	level._empPlayer = owner;
	level._empPlayer thread empPlayerFFADisconnect();
	level destroyActiveVehicles( owner );
	
	level notify ( "emp_update" );
	
	maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( duration );
	
	foreach ( player in level._players )
	{
		if ( player == owner )
	    {
			continue;
		}
		else
		{
			player.gotEMPed = false;
			if ( (player _hasPerk( "specialty_flakjacket" )) && !(isDefined ( player.gotEMPGrenaded ) && player.gotEMPGrenaded == true))
			{
				player notify ( "enableTrophy" );
			}
		}	
		
		if ( player _hasPerk( "specialty_localjammer" ) )
			player RadarJamOn();
	}
	
	level._empPlayer = undefined;
	level notify ( "emp_update" );
	level notify ( "emp_ended" );
	level notify ( "enableTrophy" );
}

empPlayerFFADisconnect()
{
	level endon ( "EMP_JamPlayers" );	
	level endon ( "emp_ended" );
	
	self waittill( "disconnect" );
	level notify ( "emp_update" );
}

empEffects()
{
	foreach( player in level._players )
	{
		playerForward = anglestoforward( player.angles );
		playerForward = ( playerForward[0], playerForward[1], 0 );
		playerForward = VectorNormalize( playerForward );
	
		empDistance = 20000;

		empEnt = Spawn( "script_model", player.origin + ( 0, 0, 8000 ) + Vector_Multiply( playerForward, empDistance ) );
		empEnt setModel( "tag_origin" );
		empEnt.angles = empEnt.angles + ( 270, 0, 0 );
		empEnt thread empEffect( player );
	}
}

empEffect( player )
{
	player endon( "disconnect" );

	wait( 0.5 );
	PlayFXOnTagForClients( level._effect[ "emp_flash" ], self, "tag_origin", player );
}

EMP_TeamTracker()
{
	level endon ( "game_ended" );
	
	for ( ;; )
	{
		level waittill_either ( "joined_team", "emp_update" );
		
		foreach ( player in level._players )
		{
			if ( player.team == "spectator" )
				continue;
				
			player setEMPJammed( level._teamEMPed[player.team] );
		}
	}
}


EMP_PlayerTracker()
{
	level endon ( "game_ended" );
	
	for ( ;; )
	{
		level waittill_either ( "joined_team", "emp_update" );
		
		foreach ( player in level._players )
		{
			if ( player.team == "spectator" )
				continue;
				
			if ( isDefined( level._empPlayer ) && level._empPlayer != player )
				player setEMPJammed( true );
			else
				player setEMPJammed( false );				
		}
	}
}

destroyActiveVehicles( attacker )
{
	if ( isDefined( attacker ) )
	{
		foreach ( heli in level._helis )
			radiusDamage( heli.origin, 384, 5000, 5000, attacker );
	
		foreach ( littleBird in level._littleBird )
			radiusDamage( littleBird.origin, 384, 5000, 5000, attacker );
		
		foreach ( turret in level._turrets )
			radiusDamage( turret.origin, 2, 5000, 5000, attacker );
	
		foreach ( rocket in level._rockets )
			rocket notify ( "death" );
		
		if ( level._teamBased )
		{
			foreach ( uav in level._uavModels["allies"] )
				radiusDamage( uav.origin, 384, 5000, 5000, attacker );
	
			foreach ( uav in level._uavModels["axis"] )
				radiusDamage( uav.origin, 384, 5000, 5000, attacker );
		}
		else
		{	
			foreach ( uav in level._uavModels )
				radiusDamage( uav.origin, 384, 5000, 5000, attacker );
		}
		
		if ( isDefined( level._ac130player ) )
			radiusDamage( level._ac130.planeModel.origin+(0,0,10), 1000, 5000, 5000, attacker );
	}
	else
	{
		foreach ( heli in level._helis )
			radiusDamage( heli.origin, 384, 5000, 5000 );
	
		foreach ( littleBird in level._littleBird )
			radiusDamage( littleBird.origin, 384, 5000, 5000 );
		
		foreach ( turret in level._turrets )
			radiusDamage( turret.origin, 2, 5000, 5000 );
	
		foreach ( rocket in level._rockets )
			rocket notify ( "death" );
		
		if ( level._teamBased )
		{
			foreach ( uav in level._uavModels["allies"] )
				radiusDamage( uav.origin, 384, 5000, 5000 );
	
			foreach ( uav in level._uavModels["axis"] )
				radiusDamage( uav.origin, 384, 5000, 5000 );
		}
		else
		{	
			foreach ( uav in level._uavModels )
				radiusDamage( uav.origin, 384, 5000, 5000 );
		}
		
		if ( isDefined( level._ac130player ) )
			radiusDamage( level._ac130.planeModel.origin+(0,0,10), 1000, 5000, 5000 );
	}
}