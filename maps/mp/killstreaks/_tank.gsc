 #include maps\mp\_utility;
 #include common_scripts\utility;
 
 //time that the ugv will hang out in the level
 UGV_TIMEOUT_SEC = 60;
 
 //ugv will exit the level if it has stopped this many times
 UGV_MAX_STOPS = 50;
 
 //easy tweaking of the hud UGV timer
 UGV_HUD_TIMER_POS_X = 0;
 UGV_HUD_TIMER_POS_Y = -35;
 
 init()
 {
 	//can remove these once we have completley shifted to using the nx ugv
 	PrecacheVehicle( "bmp_mp" );
 	precacheModel( "vehicle_bmp" );
 	precacheModel( "vehicle_bmp_dsty" );
 
 	PreCacheTurret( "abrams_minigun_mp" );
 	precacheTurret( "pavelow_minigun_mp" );
 
 	/#
 	setDevDvar( "tankDir", "" );
 	setDevDvar( "tankForceTrigger", 0 );
 	if ( getDvar( "tankDebug" ) == "" )
 		setDevDvar( "tankDebug", 0 );
 	#/
 
 	level._killstreakFuncs["tank"] = ::tryUseTank;
 
 	level._tankFire = loadfx( "explosions/large_vehicle_explosion" );
 	level._tankCover = loadfx( "props/american_smoke_grenade_mp" );
 
 	level._otherDir["forward"] = "reverse";
 	level._otherDir["reverse"] = "forward";
 
 	tankSpawners = Vehicle_GetSpawnerArray();
 
 	if ( !tankSpawners.size )
 		return;
 
 	ugvStartNodes = getVehicleNodeArray( "ugvstartnode", "script_noteworthy" );
 
 	if ( !ugvStartNodes.size )
 	{
 		assertEx ( !ugvStartNodes.size, "Vehicle spawn is setup but, tank path is not setup in this level bug your friendly neighborhood LD."  );
 		return false;
 	}
 
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
 
 	//this is from old IW code, looks like it could be useful, but i'm not using it for now.
 	//level setupPaths();
 
 	//a generic tank timeOut in sec.
 	level._tankTimeOut = 8;
 
 	//number of stops allowed before the ugv will move to the exit path.
 	level._maxUGVStops = 4;
                 
 }
 
 tryUseTank( lifeId )
 {
 	println( "tryUseTank" );
 
 	if ( isDefined( level._tankInUse ) && level._tankInUse )
 	{
 		self iPrintLnBold( "Armor support unavailable. A UGV is already in use, future task: support multiple UGVs" );
 		return false;
 	}
 
 	ugvSpawnNodes = getVehicleNodeArray( "ugvstartnodespawn", "targetname" );
 	if ( !ugvSpawnNodes.size )
 	{
 		self iPrintLnBold( "Tank is currently not supported in this level, bug your friendly neighborhood LD, Failed to locate valid spawn node." );
 		return false;
 	}
 
 	ugvStartNodes = getVehicleNodeArray( "ugvstartnode", "script_noteworthy" );
 	if ( !ugvStartNodes.size )
 	{
 		self iPrintLnBold( "Tank is currently not supported in this level, bug your friendly neighborhood LD, Failed to locate valid start node." );
 		return false;
 	}
 
 	ugvExitNodes = getVehicleNodeArray( "ugvexitnode", "script_noteworthy" );
 	if ( !ugvExitNodes.size )
 	{
 		println( "^1Warning: UGV Exit path is undefined" );
 	}
 
 	ugvBackNodes = getVehicleNodeArray( "ugvstartnodeback", "script_noteworthy" );
 	if ( !ugvBackNodes.size )
 	{
 		println( "^1Warning: UGV Backward paths are undefined" );
 	}
 
 	if ( !Vehicle_GetSpawnerArray().size )
 	{
 		self iPrintLnBold( "Vehicle spawn array empty" );
 		return false;
 	}
 
 	//picks UGV Location and kicks off the UGV Killstreak.
 	result = self selectTankLocation( lifeId );
 
 	if ( !isDefined( result ) || !result )
 		return false;
 
 	return true;
 }
 
 selectTankLocation( lifeId )
 {
 	//if we want to use the directional on the selector
 	chooseDirection = false;
 
 	targetSize = level._mapSize / 5.625; // 138 in 720
 	if ( level._splitscreen )
 		targetSize *= 1.5;
 
 	self createUGVNodeHudElements();
 	                                
 	self beginLocationSelection( "map_artillery_selector", chooseDirection, true, targetSize );
 	self.selectingLocation = true;
 
 	self setblurforplayer( 4.0, 0.3 );
 	self thread waitForTankCancel();
 
 	self thread endSelectionOn( "cancel_location" );
 	self thread endSelectionOn( "death" );
 	self thread endSelectionOn( "disconnect" );
 	self thread endSelectionOn( "used" ); // so that this thread doesn't kill itself when we use a tank
 	self thread endSelectionOnGameEnd();
 	self thread endSelectionOnEMP();
 
 	self endon( "stop_location_selection" );
 
 	self waittill( "confirm_location", location, directionYaw );
 
 	if ( !chooseDirection )
 		directionYaw = randomint(360);
 
 	self setblurforplayer( 0, 0.3 );
 	self thread finishTankSelectLocation( lifeId, location, directionYaw );
 	return true;
 }
 
 createUGVNodeHudElements()
 {                              
 	//get a list of UGV drop nodes, stuff the data in hud elements so the client can draw them on the mini map selector.
 	//startNodes = GetVehicleNodeArray( "ugvstartnode", "script_noteworthy" );
 	spawnNodes = GetVehicleNodeArray( "ugvstartnodespawn", "targetname" );
 	self.ugvhudElements = [];
 	loopcount = 0;
 	foreach( node in spawnNodes )
 	{
 		self.ugvhudElements[loopcount] = newClientHudElem( self );
 		self.ugvhudElements[loopcount].x = node.origin[0];
 		self.ugvhudElements[loopcount].y = node.origin[1];
 		self.ugvhudElements[loopcount] SetWorldPosition( node.origin[0], node.origin[1] );
 		self.ugvhudElements[loopcount].alpha = 0.0;
 		loopcount = loopcount + 1;
 	}
 }
 
 destroyUGVNodeHudElements()
 {
 	//destroy the drop nodes
 	if( isDefined( self.ugvhudElements ))
 	{
 		for( i = 0; i < self.ugvhudElements.size; i++ )
 		{
 			elem = self.ugvhudElements[i];
 			elem Destroy();
 		}
 	}
 }
 
 waitForTankCancel()
 {
 	self waittill( "cancel_location" );
 	self setblurforplayer( 0, 0.3 );
 }
 
 endSelectionOn( waitfor )
 {
 	self endon( "stop_location_selection" );
 	self waittill( waitfor );
 	self thread stopTankLocationSelection( (waitfor == "disconnect") );
 }
 
 
 endSelectionOnGameEnd()
 {
 	self endon( "stop_location_selection" );
 	level waittill( "game_ended" );
 	self thread stopTankLocationSelection( false );
 }
 
 
 endSelectionOnEMP()
 {
 	self endon( "stop_location_selection" );
 	for ( ;; )
 	{
 		level waittill( "emp_update" );
 
 		if ( !self isEMPed() )
 			continue;
 	                    
 		self thread stopTankLocationSelection( false );
 		return;
 	}
 }
 
 
 stopTankLocationSelection( disconnected )
 {
 	if ( !disconnected )
 	{
 		self setblurforplayer( 0, 0.3 );
 		self endLocationSelection();
 		self.selectingLocation = undefined;
 	}
 	self destroyUGVNodeHudElements();
 	self notify( "stop_location_selection" );
 }
 
 finishTankSelectLocation( lifeId, location, directionYaw )
 {
 	self notify( "used" );
 
 	//thread useTank( lifeId, location, directionYaw, self, self.pers["team"] );
 	//println( "chosen location is ( " + location[0] + ", " + location[1] + ", " + location[2] + " )" );
 
 	thread useTank( lifeId, location );
 }
 
 useTank( lifeId, location )
 {
 	println( "useTank" );
                 
 	if ( self.team == "allies" )
 		tank = level._tankSpawner["allies"] spawnArmor( self, "nx_vehicle_ugv" );	
 	else
 		tank = level._tankSpawner["axis"] spawnArmor( self, "nx_vehicle_ugv" );	
                 
 	tank startTank( location );
 	return true;
 }
 
 
 spawnArmor( owner, vehicletype, model )
 {
 	armor = self Vehicle_DoSpawn( "tank", owner );
 	armor setModel( vehicletype );
 
 	armor.health = 3000;
 	armor.targeting_delay = 1;
 	armor.team = owner.team;
 	armor.pers["team"] = armor.team;
 	armor.owner = owner;
 	armor setCanDamage( true );
 	armor.standardSpeed = 10;
 	armor.evadeSpeed = 50;
 	armor.dangerSpeed = 15;
 	armor.miniEngagementSpeed = 15;
 	armor.engagementSpeed = 15;
 
 	armor thread deleteOnZ();
 	armor addToTankList();
 	armor.damageCallback = ::Callback_VehicleDamage;
 
 	return armor;
 }
 
 deleteOnZ()
 {
 	self endon ( "death" );
 
 	originalZ = self.origin[2];
 
 	for ( ;; )
 	{
 		if ( originalZ - self.origin[2] > 2048 )
 		{
 				self.health = 0;
 				self notify( "death" );
 				return;
 		}
 		wait ( 1.0 );
 	}
 }
 
 startTank( location )
 {
 	//give the UGV a list of all vehicle nodes
 	self.nodes = GetVehicleNodeArray( "info_vehicle_node", "classname" );
 
 	//seems like these lists should just be set once when the level loads but for some reason that was not working.
 	level._ugvstartnodes = GetVehicleNodeArray( "ugvstartnode", "script_noteworthy" );
 	level._ugvbacknodes = GetVehicleNodeArray( "ugvstartnodeback", "script_noteworthy" );
 	level._ugvexitnodes = GetVehicleNodeArray( "ugvexitnode", "script_noteworthy" );
 	level._ugvspawnnodes = GetVehicleNodeArray( "ugvstartnodespawn", "targetname" );
 
 	//A little debug info
 	//println( " ================================================== " ); 
 	//println( "found " + level._ugvstartnodes.size + " ugvstartnodes" );
 	//println( "found " + level._ugvbacknodes.size + " ugvbacknodes" );
 	//println( "found " + level._ugvexitnodes.size + " ugvexitnodes" );
 	//println( "found " + level._ugvspawnnodes.size + " ugvspawnnodes" );
 	//println( " ================================================== " );
 
 	//find the start node nearest to the location the player selected on the mini map
 	startNode = getNearestUGVNode( location, level._ugvspawnnodes );
 
 	//init num stops
 	self._numstops = 0;
 	self._time_is_up = 0;
 
 	level._tankInUse = true;
 	//self thread TankUpdate( startNode, waitNode );
 	//self thread tankUpdateReverse( startNode, waitNode );
 
 	self thread ugvUpdate( startNode );
 
 	self.owner hudUGVTimer( UGV_TIMEOUT_SEC, self );
 
 	self thread tankDamageMonitor();
 	level._tank = self;
 
 	if ( level._teamBased )
 	{
 		/*
 		objIDAllies = maps\mp\gametypes\_gameobjects::getNextObjID();
 		objective_add( objIDAllies, "invisible", (0,0,0) );
 		objective_team( objIDAllies, "allies" );
 		level._tank.objID["allies"] = objIDAllies;
 
 		objIDAxis = maps\mp\gametypes\_gameobjects::getNextObjID();
 		objective_add( objIDAxis, "invisible", (0,0,0) );
 		objective_team( objIDAxis, "axis" );
 		level._tank.objID["axis"] = objIDAxis;
 		*/
 
 		team = self.team;
 		level._tank.team = team;
 		level._tank.pers[ "team" ] = team;
 	}
 
 	//NOT USING VEHICLE MAIN WEAPON ANYMORE, model was split into vehicle and turret components
 	//equip the vehicle with harrier 20mm bullets
 	//self setVehWeapon( "harrier_20mm_mp" ); 
 
 	//TagZP<NOTE> removing ugv mini gun for now.
 	mgTurret = spawnTurret( "misc_turret", self.origin, "ugv_main_turret_mp" );
 	//mgTurret = spawnTurret( "misc_turret", self.origin, "abrams_minigun_mp" );
 
 	//TagZP<NOTE> attach the turret to the UGV
 	mgTurret linkTo( self, "TAG_TURRET", (0,0,0), (0,0,0) );
 	//mgTurret setModel( "weapon_minigun" );
 	mgTurret setModel( "nx_ugv_main_turret" );
 	mgTurret.angles = self.angles; 
 	mgTurret.owner = self.owner;
 	mgTurret makeTurretInoperable();
 	self.mgTurret = mgTurret; 
 	self.mgTurret SetDefaultDropPitch( 0 );
 
 	oldangles = self.angles;
 	self.angles = (0,0,0);
 	tankTurretPoint = self getTagOrigin( "TAG_TURRET" );
 	self.angles = oldangles;
 	offset = tankTurretPoint - self.origin;
 
 	self thread waitForChangeTeams();
 	self thread waitForDisco();
 
 	self.timeLastFired = getTime();
 
 	neutralTargetEnt = spawn("script_origin", self.mgTurret getTagOrigin("tag_flash") );
 	neutralTargetEnt linkTo( self, "tag_origin", offset, (0,0,0) );
 	neutralTargetEnt hide();
 	self.neutralTarget = neutralTargetEnt;
 
 	//TagZP<NOTE> not using UGV built in gun anymore, removed the turret and broke the the model into components
 	//self thread tankGetTargets();
 
 	self thread destroyTank();
 	self thread tankGetMiniTargets();
 	self thread checkDanger();
 
 	//self thread watchForThreat(); //reacts to players about to fire with rockets
 
 	/#
 	self thread forceDirection();
 #/
                 
 }
 
 hudUGVTimer( duration, tank )
 {
 	tank endon ( "death" );
 
 	self.ugvTimer = newClientHudElem( self );
 	self.ugvTimer.x = UGV_HUD_TIMER_POS_X;
 	self.ugvTimer.y = UGV_HUD_TIMER_POS_Y;
 	self.ugvTimer.alignX = "center";
 	self.ugvTimer.alignY = "bottom";
 	self.ugvTimer.horzAlign = "center_adjustable";
 	self.ugvTimer.vertAlign = "bottom_adjustable";
 	self.ugvTimer.fontScale = 2.5;
 	self.ugvTimer setTimer( 1.0 );
 	self.ugvTimer.alpha = 1.0;
 
 	self.ugvTimer setTimer( duration );
 	println( "done setting hud timer" );
 
 	tank thread UGVWaitForTimeout( duration, "ugv_time_is_up" );
 }
 
 UGVWaitForTimeout( duration, msg )
 {
 	self endon( "death" );
 	wait duration;
 	self.owner notify( msg );
 	self._time_is_up = 1;
 }
 
 destroyUGVTimer()
 {
 	self.ugvTimer Destroy();
 }
 
 moveTank( pathnode )
 {
 	println( "starting ugv killstreak path" );
 	self startPath( pathnode );
 	self waittill( "reached_end_node" );
 	println( "reached ugv killstreak path end" );
 }
 
 ugvUpdate( startNode )
 {
 	println( "Starting UGV Killstreak Update Loop" );
 
 	total_time = 0;
 
 	//allows the player to advance the tank when it is waiting at a path node
 	self.owner NotifyOnPlayerCommand( "advance_tank_forwards", "+actionslot 1" );
 	self.owner NotifyOnPlayerCommand( "advance_tank_backwards", "+actionslot 2" );
 	self endon( "death" );
 
 	self attachPath( startNode );
 	wait( 0.1 );
 
 	//main tank update loop
 	for ( ;; )
 	{
 		self moveTank( startnode );
 		self._numstops = self._numstops + 1;
 
 		if( self._time_is_up == 1 )
 		{
 			break;
 		}
 
 		if( !isDefined( self.owner ))
 		{
 			continue;
 			wait 0.05;
 		}
 
 		startnode = getNearestUGVNode( self.origin, level._ugvstartnodes );
 										                             
 
 		/*
 		msg = self.owner waittill_any_return( "advance_tank_forwards", "advance_tank_backwards", "ugv_time_is_up", "death" );
 
 		if( msg == "death" )
 		{
 			//when a player dies, self.owner is temporarily undefined.  So I am catching the player death, and reinstating the input command wait.
 			continue;
 		}
 
 		//println( "msg = " + msg );
 
 		//move to next node, or to exit path
 		if( self._numstops < UGV_MAX_STOPS && self._time_is_up == 0 )
 		{
 			if( msg == "advance_tank_forwards" )
 			{
 				//make sure we have at least one startnode in the list
 				if( level._ugvstartnodes.size )
 				{
 					startnode = getNearestUGVNode( self.origin, level._ugvstartnodes );
 				}
 			}
 			else if( msg == "advance_tank_backwards" )
 			{
 				if( level._ugvbacknodes.size )
 				{
 					startnode = getNearestUGVNode( self.origin, level._ugvbacknodes );
 				}
 			}
 			else
 			{
 				if( msg == "ugv_time_is_up" )
 				{
 					break;
 				}
 			}
 		}
 		else
 		{
 			break;
 		}
 		*/
 	}
 
 	//if exit nodes are not defined blow up the tank.
 	if( !level._ugvexitnodes.size )
 	{
 		//destroy the ugv
 		println( "^1Warning: UGV Exit path is undefined SELF DESTRUCT" );
 		self notify( "death" );
 		return;
 	}
 
 	//move to exit location
 	exitnode = getNearestUGVNode( self.origin, level._ugvexitnodes );
 	self moveTank( exitnode );
 
 	//destroy the ugv
 	self notify( "death" );
 }
 
 //returns the node in nodelist that is the closest to pos
 getNearestUGVNode( pos, nodelist )
 {
 	num_nodes = nodelist.size;
 	mindist = Distance2d( pos, nodelist[0].origin );
 	//println( "distance = " + mindist );
 	nodeidx = 0;
 	cnt = 1;
 	while( cnt < num_nodes )
 	{
 		dist = Distance2d( pos, nodelist[cnt].origin );
 		//println( "distance = " + dist );
 		if( dist < mindist )
 		{
 			nodeidx = cnt;
 			mindist = dist;
 		}
 		cnt++;
 	}
 	//println( "closest node index is " + nodelist[nodeidx].targetname );
 
 	return nodelist[nodeidx];
 }
 
 //given a node on the ugv path, this retunrs the last node in that path
 getPathEnd( pathnode )
 {
 	node = pathnode;
 	while( IsDefined( node ))
 	{
 		if( !IsDefined( node.target ))
 			return node;
 		                
 		temp = GetVehicleNode( node.target, "targetname" );
 
 		if( !IsDefined( temp ))
 			break;
 			//return node;
 
 		node = temp;
 	}
 
 	return node;
 }
 
 waitForChangeTeams()
 {
 	self endon ( "death" );
 	self.owner endon ( "disconnect" );
 
 	self.owner waittill ( "joined_team" );
 	self.health = 0;
 	self notify( "death" );
 }
 
 waitForDisco()
 {
 	self endon ( "death" );
 
 	self.owner waittill ( "disconnect" );
 	self.health = 0;
 	self notify( "death" );
 }
 
 /#
 forceDirection()
 {
 	for ( ;; )
 	{
 		if ( getDvar( "tankDir" ) != "" )
 		{
 			forceDir = getDvar( "tankDir" );
 			if ( self.veh_pathdir != forceDir )
 			{
 				if ( forceDir == "forward" )
 					self stopToForward();
 				else
 					self stopToReverse();
 			}
 		}
 
 		wait ( 0.05 );
 	}
 }
 #/
 
 //=================================================================
 //
 //                                                                            Movement/Update Functions
 //
 //=================================================================
 
 setDirection( direction )
 {
 	if ( self.veh_pathdir != direction )
 	{
 		if ( direction == "forward" )
 			self stopToForward();
 		else
 			self stopToReverse();
 	}
 }
 
 setEngagementSpeed()
 {
 	self endon( "death" );
 
 	self notify ( "path_abandoned" );
 
 	while ( isDefined( self.changingDirection ) )
 		wait ( 0.05 );
 
 	self vehicle_SetSpeed( self.engagementSpeed, 10, 10 );
 	self.speedType = "engage";
 }
 
 setMiniEngagementSpeed()
 {
 	self endon( "death" );
 
 	self notify ( "path_abandoned" );
 
 	while ( isDefined( self.changingDirection ) )
 		wait ( 0.05 );
 
 	self vehicle_SetSpeed( self.miniEngagementSpeed, 10, 10 );
 	self.speedType = "engage";
 }
 
 setStandardSpeed()
 {
 	self endon( "death" );
 
 	while ( isDefined( self.changingDirection ) )
 		wait ( 0.05 );
 
 	self vehicle_SetSpeed( self.standardSpeed, 10, 10 );
 	self.speedType = "standard";
 }
 
 setEvadeSpeed()
 {
 	self endon( "death" );
 
 	while ( isDefined( self.changingDirection ) )
 		wait ( 0.05 );
 
 	self vehicle_setSpeed( self.evadeSpeed, 15, 15 );
 	self.speedType = "evade";
 	wait(1.5);
 	self vehicle_setSpeed( self.standardSpeed, 10, 10);        
 }
 
 setDangerSpeed()
 {
 	self endon( "death" );
 
 	while ( isDefined( self.changingDirection ) )
 		wait ( 0.05 );
 
 	self vehicle_SetSpeed( self.dangerSpeed, 5, 5 );
 	self.speedType = "danger";
 }
 
 stopToReverse()
 {
 	debugPrintLn2( "tank changing direction at " + getTime() );
 	self vehicle_setSpeed( 0, 5, 6 );
 
 	self.changingDirection = true;
 	while ( self.veh_speed > 0 )
 		wait ( 0.05 );
 
 	wait( 0.25 );
 	self.changingDirection = undefined;
 	debugPrintLn2( "tank done changing direction" );
 
 	self.veh_transmission = "reverse";
 	self.veh_pathDir = "reverse";
 	self vehicle_setSpeed( self.standardSpeed, 5, 6 );
 }
 
 stopToForward()
 {
 	debugPrintLn2( "tank changing direction at " + getTime() );
 	self vehicle_setSpeed( 0, 5, 6 );
 
 	self.changingDirection = true;
 	while ( self.veh_speed > 0 )
 		wait ( 0.05 );
 
 	wait( 0.25 );
 	self.changingDirection = undefined;
 	debugPrintLn2( "tank done changing direction" );
 
 	self.veh_transmission = "forward";
 	self.veh_pathDir = "forward";
 	self vehicle_setSpeed( self.standardSpeed, 5, 6 );
 }
 
 checkDanger()
 {
 	self endon( "death" );
 
 	targets = [];
 	players = level._players;
 	self.numEnemiesClose = 0;
 
 	for( ;; )
 	{
 		foreach (potentialTarget in players)
 		{
 			if ( !isDefined( potentialTarget ) )
 				continue;
 
 			if ( potentialTarget.team == self.team )
 			{
 				wait( .05 );
 				continue;
 			}
 
 			dist = Distance2d( potentialTarget.origin, self.origin );
 
 			if ( dist < 2048 )
 			{
 				self.numEnemiesClose++;           
 			}
 			wait( .05 );
 		}
 	    
 		if ( isDefined( self.speedType ) && ( self.speedType == "evade" || self.speedType == "engage" ) )
 		{
 			self.numEnemiesClose = 0;
 			continue;
 		}
 	    
 		if ( self.numEnemiesClose > 1 )
 			self thread setDangerSpeed();
 		else
 			self thread setStandardSpeed();
 	    
 		self.numEnemiesClose = 0;
 		wait( .05 );
 	}
 }
                                                 
 tankUpdate( startNode, waitNode )
 {
 	self endon( "tankDestroyed" );
 	self endon( "death" );
 
 	if ( !isDefined( level._graphNodes ) )
 	{
 		println( "bailing from tankupdate no graphnodes" );
 		self startPath( startNode );
 		return;
 	}
 
 	self attachPath( startNode );
 	self startPath( startNode );
 	startNode notify ( "trigger", self, true );
 
 	wait ( 0.05 );
 
 	for ( ;; )
 	{
 		/#
 		while ( getDvar( "tankDir" ) != "" )
 			wait ( 0.05 );
 		#/
 
 		while ( isDefined( self.changingDirection ) )
 			wait ( 0.05 );
 
 		endNode = self getNodeNearEnemies();
 
 		if ( isDefined( endNode ) )
 			self.endNode = endNode;
 		else
 			self.endNode = undefined;
 
 		wait ( 0.65 );
 	}
 }
 
 
 Callback_VehicleDamage( inflictor, attacker, damage, dFlags, meansOfDeath, weapon, point, dir, hitLoc, timeOffset, modelIndex, partName )
 {
 	if ( ( attacker == self || attacker == self.mgTurret || ( isDefined( attacker.pers ) && attacker.pers["team"] == self.team ) ) && ( attacker != self.owner || meansOfDeath == "MOD_MELEE" ) )
 		return;
 
 	tankDamage = modifyDamage( meansOfDeath, damage, attacker );
 
 	self Vehicle_FinishDamage( inflictor, attacker, tankDamage, dFlags, meansOfDeath, weapon, point, dir, hitLoc, timeOffset, modelIndex, partName );
 }
 
 
 // accumulate damage and react
 tankDamageMonitor()
 {
 	self endon( "death" );
 	self.damageTaken = 0;
 	speed = self vehicle_GetSpeed();
 	maxHealth = self.health;
 	stage1 = false;
 	stage2 = false;
 	stage3 = false;
 
 	for( ;; )
 	{
 		self waittill( "damage", amount, attacker, direction_vec, point, damageType );
 	    
 		if ( isDefined( attacker.classname ) && attacker.classname == "script_vehicle"  )
 		{
 			if ( isDefined( self.bestTarget ) && self.bestTarget != attacker )
 			{
 				self.forcedTarget = attacker;
 				println( "Abandoning Target due to vehicle attacker" );  
 				self thread explicitAbandonTarget();
 			}                                              
 		}
 		else
 		{
 			if ( isPlayer( attacker ) )
 			{
 				attacker maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "hitHelicopter" );
 
 				if ( attacker _hasPerk( "specialty_armorpiercing" ) )
 				{
 					damageAdd = amount*level._armorPiercingMod;
 					self.health -= int(damageAdd);
 				}                                              
 			}
 		}
 	    
 		//stages will be used to effect effeciency of the tank 
 		//accuracy, speed, smoke emitters etc....
 		if ( self.health <= 0 )
 		{
 			self notify( "death" );     
 			print("sent death notify via script");
 			return;
 		}
 		else if (self.health < (maxHealth/4) && stage3 == false )
 		{
 			//newSpeed = 4;
 			//self vehicle_SetSpeed( newSpeed, 10, 10 );
 			//self.standardSpeed = newSpeed;
 			stage3 = true;       
 		}
 		else if (self.health < (maxHealth/2) && stage2 == false )
 		{
 			//newSpeed = 6;
 			//self vehicle_SetSpeed( newSpeed, 10, 10 );
 			//self.standardSpeed = newSpeed;
 			stage2 = true;              
 		}
 		else if (self.health < (maxHealth/1.5) && stage1 == false )
 		{
 			//newSpeed = 10;
 			//self vehicle_SetSpeed( newSpeed, 10, 10 );
 			//self.standardSpeed = newSpeed;
 			stage1 = true;
 		}
 	    
 		if ( amount > 1000 )
 		{
 			self handleThreat( attacker );
 		}                              
 	}
 }
 
 handleThreat( attacker )
 {
     self endon( "death" );
     
     rand = randomInt(100);
     
 	if ( isDefined( self.bestTarget) && self.bestTarget != attacker && rand > 30 )
 	{              
 		targ = [];
 		targ[0] = self.bestTarget;
 		explicitAbandonTarget( true, self.bestTarget );
 		self thread acquireTarget( targ );
 	}
 	else if ( !isDefined( self.bestTarget ) && rand > 30 )
 	{
 		targ = [];
 		targ[0] = attacker;
 		self thread acquireTarget( targ );              
 	}
 	else if ( rand < 30 )
 	{
 		// all we know here is that it didnt hit the 70%
 		playFX( level._tankCover, self.origin);
 		self thread setEvadeSpeed();
 	}
 	else
 	{
 		self fireWeapon();           
 		self playSound( "bmp_fire" );
 	}
 }
 
 handlePossibleThreat( attacker )
 {
 	self endon( "death" );
 
 	position = relativeAngle( attacker );
 	distance = distance( self.origin, attacker.origin );
 
 	if ( RandomInt( 4 ) < 3 )
 		return;
 
 	if( position == "front"  && distance < 768 ) //attempts to crush player
 	{
 		self thread setEvadeSpeed();
 	}
 	else if ( position == "rear_side" || ( position == "rear" && distance >= 768 ) )
 	{
 		playFX( level._tankCover, self.origin);
 		self thread setEvadeSpeed();     
 	}
 	else if( position == "rear" && distance < 768 ) //attempts to crush player
 	{              
 	    
 		self stopToReverse();
 		self setEvadeSpeed();
 		wait( 4 );
 		self stopToForward();
 
 	}
 	else if( position == "front_side" || position == "front" )
 	{
 		playFX( level._tankCover, self.origin);
 		self stopToReverse();
 		self setEvadeSpeed();
 		wait( 8 );
 		self stopToForward();
 	}
 }
 
 relativeAngle( ent1 )
 {
 	self endon( "death" );
 	ent1 endon( "death" );
 	ent1 endon( "disconnect" );
 
 	tankForwardVector = anglesToForward( self.angles );
 	tankToEnt = ent1.origin - self.origin;
 	tankForwardVector *= (1,1,0);
 	tankToEnt *= (1,1,0 );
 
 	tankToEnt = VectorNormalize( tankToEnt );
 	TankForwardVector = VectorNormalize( tankForwardVector );
 
 	targetCosine = VectorDot( tankToEnt, tankForwardVector );
 
 	if ( targetCosine > 0 )
 	{
 		if ( targetCosine > .9 )
 			return "front";
 		else
 			return "front_side";
 	}
 	else
 	{
 		if ( targetCosine < -.9 )
 			return "rear";
 		else
 			return "rear_side";
 	}              
 	    
 	ent1 iPrintLnBold( targetCosine );
 }
 
 watchForThreat()
 {
 	self endon( "death" );
 
 	for ( ;; )
 	{
 		targets = [];
 		players = level._players;
 	    
 		foreach (player in players)
 		{
 			if ( !isDefined( player ) )
 			{
 				wait( .05 );
 				continue;
 			}
 
 			if ( !isTarget( player ) )
 			{
 				wait ( .05 );
 				continue;
 			}
 
 			currentWeapon = player GetCurrentWeapon();
 
 			if ( isSubStr( currentWeapon, "at4" ) || isSubStr( currentWeapon, "stinger" ) || isSubStr( currentWeapon, "javelin" ) )
 			{
 				self thread handlePossibleThreat( player );
 				wait( 8 );
 			}
 
 			wait( .15 );
 		}
 	}
 }
 
 //=================================================================
 //
 //                                                                            Accessory Functions
 //
 //=================================================================
 
 // checks if owner is valid, returns false if not valid
 checkOwner()
 {
 	if ( !isdefined( self.owner ) || !isdefined( self.owner.pers["team"] ) || self.owner.pers["team"] != self.team )
 	{
 		self notify ( "abandoned" );
 		return false;       
 	}
 	return true;
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
 
 modifyDamage( damageType, amount, attacker )
 {
 	if ( damageType == "MOD_RIFLE_BULLET" )        
 		return ( amount );
 	else if ( damageType == "MOD_PISTOL_BULLET" )
 		return ( amount );
 	else if ( damageType == "MOD_IMPACT" )
 		return ( amount );
 	else if (damageType == "MOD_MELEE" )
 		return ( 0 );
 	else if (damageType == "MOD_EXPLOSIVE_BULLET" )
 		return ( amount );
 	else if (damageType == "MOD_GRENADE" )
 		return ( amount * 5 );
 	else if (damageType == "MOD_GRENADE_SPLASH" )
 		return ( amount * 5 );
 	else 
 		return amount * 10;
 }
 
 destroyTank()
 {
 	self waittill ( "death" );
 
 	//remove hud timer if the player has not disconnected
 	if( isDefined( self.owner ))
 	{
 		self.owner destroyUGVTimer();
 	}
 	/*           
 	if ( level._teamBased )
 	{
 		team = level._tank.team;
 		objective_state( level._tank.objID[team], "invisible" );
 		objective_state( level._tank.objID[level._otherTeam[team]], "invisible" );
 
 		if( level._multiTeamBased )
 		{
 			for( i = 0; i < level._teamNameList.size; i++ )
 			{
 				if( level._teamNameList[i] != team )
 				{
 					objective_state( level._tank.objID[level._teamNameList[i]], "invisible" );
 				}
 			}
 		}
 	}
 	*/
 
 	// award attacker
 	self notify( "tankDestroyed" );
 	self Vehicle_SetSpeed( 0,10,10 );
 	level._tankInUse = false;
 	playFX( level._spawnFire, self.origin);
 
 	playFX( level._tankFire, self.origin);
 
 	self removeFromTankList();
 
 	destroyedTank = Spawn( "script_model", self.origin );
 	// set model to current destroyed model.
 //	if ( self.team == "allies" )
 //		destroyedTank setModel( "vehicle_bradley_destroyed" );
 //	else
 		destroyedTank setModel( "vehicle_bmp_dsty" );
 
 	destroyedTank.angles = self.angles; 
 	self.mgTurret delete();
 	self delete();
 
 	wait(4);
 	destroyedTank delete();
 }
 
 //=================================================================
 //
 //                                                                            Main Weapon Targeting Functions
 //
 //=================================================================
 
 onHitPitchClamp()
 {              
 	self notify( "onTargOrTimeOut" );
 
 	self endon( "onTargOrTimeOut" );
 	self endon( "turret_on_target" );
 
 	self waittill( "turret_pitch_clamped" );
 	println( "Abandoning Target due to turret not being able to reach target" );
 	self thread explicitAbandonTarget( false, self.bestTarget );
 }
 
 fireOnTarget()
 {
 	self endon( "abandonedTarget" );
 	self endon( "killedTarget" );
 	self endon( "death" );
 	self endon( "targetRemoved" );
 	self endon( "lostLOS" );
                 
                 
 	for ( ;; )
 	{
 		self onHitPitchClamp();
 	    
 		if ( !isDefined( self.bestTarget ) )
 			continue;
 	    
 		flashOrigin = self.mgTurret GetTagOrigin( "tag_flash" ); 
 		trace = BulletTrace( self.origin, flashOrigin, false, self );
 		if ( trace["position"] != flashOrigin )
 		{
 			println( "Abandoning Target due to turret not being able to reach target without clipping" );        
 			self thread explicitAbandonTarget( false, self.bestTarget );
 		}
 	    
 		trace = BulletTrace( flashOrigin, self.bestTarget.origin, true, self );
 		distance = Distance(self.origin, trace["position"] );
 		realDistance = Distance( self.bestTarget.origin, self.origin );
 	    
 		//hitting somthing not even close
 		if ( distance < 384 || distance + 256 < realDistance )
 		{
 			wait( .5 );
 
 			if ( distance > 384 )
 			{
 				self waitForTurretReady();
 				self FireWeapon();
 				self playSound( "bmp_fire" );
 				self.timeLastFired = getTime();
 			}
 			println( "Abandoning due to not hitting intended space" );
 
 			// Adjust forward or backward to hit target...
 			// check angle of target
 			position = relativeAngle( self.bestTarget );
 
 			//if ( position == "rear_side" )
 				// backup
 			//if ( position == "front_side" )
 
 
 			self thread explicitAbandonTarget( false, self.bestTarget );
 			return;
 		}
 	                    
 		self waitForTurretReady();
 	    
 		self FireWeapon();
 		self playSound( "bmp_fire" );
 		self.timeLastFired = getTime();
 	}
 }
 
 waitForTurretReady()
 {
 	self endon( "abandonedTarget" );
 	self endon( "killedTarget" );
 	self endon( "death" );
 	self endon( "targetRemoved" );
 	self endon( "lostLOS" );
 
 	timeWaited = getTime() - self.timeLastFired;
 
 	if ( timeWaited < 1499 )
 		wait( 1.5 - timeWaited/1000 );
 }
 
 tankGetTargets( badTarget )
 {
 	self endon( "death" );
 	self endon( "leaving" );
 	targets = [];
 
 	prof_begin( "tankTargets" );
                 
 	for ( ;; )
 	{
 		targets = [];
 		players = level._players;
 	    
 		if ( isDefined( self.forcedTarget ) )
 		{
 			targets = [];
 			targets[0] = self.ForcedTarget;
 			self acquireTarget( targets );
 			self.forcedTarget = undefined;
 		}
 
 		if ( isDefined( level._harrier ) && level._harrier.team != self.team && isAlive( level._harrier ) )
 		{
 			if( isVehicleTarget( level._tank ) )
 				targets[targets.size] = level._tank;
 		}
 
 		if ( isDefined( level._chopper ) && level._chopper.team != self.team  && isAlive( level._chopper ) )
 		{              
 			if( isVehicleTarget( level._chopper ) )
 				targets[targets.size] = level._chopper;
 		}
 	    
 		foreach ( potentialTarget in players )
 		{
 			if (!isDefined( potentialTarget ) )
 			{
 				wait(.05);
 				continue;
 			}
 
 			if ( isDefined( badTarget ) && potentialTarget == badTarget )
 			{ 
 				continue;
 			}
 
 			if ( isTarget( potentialTarget ) )
 			{
 				if( isDefined( potentialTarget ) )
 				{
 					targets[targets.size] = potentialTarget;
 				}
 			}
 			else
 			{
 				continue;
 			}
 		}
 		if ( targets.size > 0 )
 		{
 			self acquireTarget( targets );
 		}
 		else
 			wait( 1 );
 	}
 	prof_end( "tankTargets" );
 }
 
 acquireTarget( targets )
 {
     self endon( "death" );
     
     if ( targets.size == 1 )
                     self.bestTarget = targets[0];
     else
                     self.bestTarget = self getBestTarget( targets );
     
     self thread setEngagementSpeed(); // slows tank down to fire on target
     
     // checks to abandon target
     //self thread lostTarget(); // sets lost LOS and time of lost target
     //self thread abandonTarget(); // if target is lost for 3+ seconds drops target and gets new one
     self thread watchTargetDeath( targets ); //abandons target when target killed
     
     
     self SetTurretTargetEnt( self.bestTarget, ( 0, 0, 48 ));       // sets turret to target entity
     self fireOnTarget(); // fires on current target.
     self thread setNoTarget();
 }
 
 setNoTarget()
 {
     self endon( "death" );
     
     self setStandardSpeed();
     self removeTarget();
     self setTurretTargetEnt( self.neutralTarget );
 }
 
 getBestTarget( targets )
 {
     self endon( "death" );
     mainGunPointOrigin = self.mgTurret getTagOrigin( "tag_flash" );
     tankOrigin = self.origin;
     
     bestYaw = undefined;
     bestTarget = undefined;
     targetHasRocket = false;
     
     foreach ( targ in targets )
     {
         angle = abs ( vectorToAngles ( ( targ.origin - self.origin ) )[1] );
         cannonAngle = abs( self.mgTurret getTagAngles( "tag_flash" )[1] );
         angle = abs ( angle - cannonAngle );                                        
         
         //vehicle priorities
         if ( isDefined( level._chopper ) && targ == level._chopper )
             return targ;
         
         if ( isDefined( level._harrier ) && targ == level._harrier )
             return targ;
         
         // in this calculation having a rocket removes 40d of rotation cost from best target calculation
         // to prioritize targeting dangerous targets.
         weaponsArray = targ GetWeaponsListItems();
         foreach ( weapon in weaponsArray )
         {
 			if ( isSubStr( weapon, "at4" ) || isSubStr( weapon, "jav" ) || isSubStr( weapon, "c4" ) )
 							angle -= 40;
         }
                                         
 		if ( !isDefined( bestYaw ) )
 		{                                                              
 			bestYaw = angle;
 			bestTarget = targ;
 		} 
 		else if ( bestYaw > angle )
 		{
 			bestYaw = angle;
 			bestTarget = targ;                                            
 		}
     }
     
     return ( bestTarget );
 }
 
 watchTargetDeath( targets )
 {
 	self endon( "abandonedTarget" );
 	self endon( "lostLOS" );
 	self endon( "death" );
 	self endon( "targetRemoved" );
 	                
 	bestTarg = self.bestTarget;
 	bestTarg endon ( "disconnect" );
 
 	bestTarg waittill( "death" );
 
 	self notify( "killedTarget" );
 	self removeTarget();
 	self setStandardSpeed();
 	self thread setNoTarget();
 }
 
 explicitAbandonTarget( noNewTarget, targ )
 {
 	self endon( "death" );
 
 	self notify( "abandonedTarget" );
 	println("ABANDON TARGET EXPLICIT");
 	self setStandardSpeed();
 	self thread Setnotarget();
 	self removeTarget();
 
 	if ( isDefined(targ) )
 	{
 		self.badTarget = targ;
 		badTargetReset();
 	}              
 
 	if ( isDefined(noNewTarget) && noNewTarget )
 		return;
 
 	return;
 }
 
 badTargetReset()
 {
     self endon("death");
     
     wait (1.5);
     self.badTarget = undefined;                       
 }
 
 removeTarget()
 {
     self notify( "targetRemoved" );
     
     self.bestTarget = undefined;
     self.lastLostTime = undefined;   
 }
 
 isVehicleTarget( potentialTarget )
 {
     if ( distance2D( potentialTarget.origin, self.origin ) > 4096 )
 		return false;
     
     if ( distance( potentialTarget.origin , self.origin ) < 512 )
         return false;
                     
     return turretSightTrace( potentialTarget, false );
 }
 
 isTarget( potentialTarget )
 {
 	self endon( "death" );
 
 	dist = distanceSquared( potentialTarget.origin, self.origin );
 
 	if ( !level._teamBased && isDefined( self.owner ) && potentialTarget == self.owner )
 		return false;
 
 	if ( !isalive( potentialTarget ) || potentialTarget.sessionstate != "playing" )
 		return false;
 	    
 	if ( dist > 4096*4096 )
 		return false;
 
 	if ( dist < 512*512 )
 		return false;
 
 	if ( !isdefined( potentialTarget.pers["team"] ) )
 		return false;
 	    
 	if ( potentialTarget == self.owner )
 		return false;
 
 	if ( level._teamBased && potentialTarget.pers["team"] == self.team )
 		return false;
 
 	if ( potentialTarget.pers["team"] == "spectator" )
 		return false;
 
 	if ( isdefined( potentialTarget.spawntime ) && ( gettime() - potentialTarget.spawntime )/1000 <= 5 )
 		return false;
 
 	if ( potentialTarget _hasPerk( "specialty_blindeye" ) )
 		return false;
 
 	return self Vehicle_CanTurretTargetPoint( potentialTarget.origin, 1, self );
 
 	//return self turretSightTrace( potentialTarget, false );
 }
 
 turretSightTrace( targ, debug )
 {
 	turretCanSeeTarget = targ sightConeTrace( self getTagOrigin( "tag_turret" ), self );
 
 	if ( turretCanSeeTarget < .7 )
 	{
 		return false;       
 	}
 
 	if ( isDefined(debug) && debug )
 		self thread drawLine( targ.origin, self getTagOrigin( "tag_turret" ), 10, (1,0,0) );
 
 	return true;        
 }
 
 //=================================================================
 //
 //                                                                            Secondary Weapon Targeting Functions
 //
 //=================================================================
 
 isMiniTarget( potentialTarget )
 {
 	self endon( "death" );
 
 	if ( !isalive( potentialTarget ) || potentialTarget.sessionstate != "playing" )
 		return false;
 
 	if ( !isdefined( potentialTarget.pers["team"] ) )
 		return false;
 
 	if ( potentialTarget == self.owner )
 		return false;
 
 	if ( distanceSquared( potentialTarget.origin , self.origin ) > 1024*1024 )
 		return false;
 
 	if ( level._teamBased && potentialTarget.pers["team"] == self.team )
 		return false;
 
 	if ( potentialTarget.pers["team"] == "spectator" )
 		return false;
 
 	if ( isdefined( potentialTarget.spawntime ) && ( gettime() - potentialTarget.spawntime )/1000 <= 5 )
 		return false;
 
 
 	if ( isDefined( self ) )
 	{
 		minTurretEye = self.mgTurret.origin + ( 0, 0, 64 );
 		minTurretCanSeeTarget = potentialTarget sightConeTrace( minTurretEye, self );
 
 		if ( minTurretCanSeeTarget < 1 )
 			return false;       
 	}
 
 	return true;
 }
 
 tankGetMiniTargets()
 {
 	self endon( "death" );
 	self endon( "leaving" );
 	miniTargets = [];
 	println( "Geting Mini Targets" );
 
 	for ( ;; )
 	{
 		miniTargets = [];
 		players = level._players;
 	    
 		for (i = 0; i <= players.size; i++)
 		{
 			if ( isMiniTarget( players[i] ) )
 			{
 				if( isdefined( players[i] ) )
 					miniTargets[miniTargets.size] = players[i];
 			}
 			else
 			{
 				continue;
 			}
 		    
 			wait( .05 );
 		}
 		if ( miniTargets.size > 0 )
 		{
 			self acquireMiniTarget( miniTargets );
 			return;  
 		}              
 		else
 		{
 			wait( .5 );
 		}
 	}
 }
 
 getBestMiniTarget( targets )
 {
 	self endon( "death" );
 	tankOrigin = self.origin;
 
 	closest = undefined;
 	bestTarget = undefined;
 
 	foreach ( targ in targets )
 	{                              
 		curDist = Distance( self.origin, targ.origin );
 	    
 		// in this calculation having a rocket javelin or c4 increases mini turret priority
 		// to prioritize targeting dangerous targets.
 		curWeaon = targ GetCurrentWeapon();
 		if ( isSubStr( curWeaon, "at4" ) || isSubStr( curWeaon, "jav" ) || isSubStr( curWeaon, "c4" ) || isSubStr( curWeaon, "smart" ) || isSubStr( curWeaon, "grenade" ) )
 			curDist -= 200;
 	    
 		if ( !isDefined( closest ) )
 		{
 			closest = curDist;
 			bestTarget = targ;
 		} 
 		else if ( closest > curDist )
 		{
 			closest = curDist;
 			bestTarget = targ;
 		}              
 	}
 	return ( bestTarget );
 }
 
 acquireMiniTarget( targets )
 {
 	self endon( "death" );
 
 	if ( targets.size == 1 )
 		self.bestMiniTarget = targets[0];
 	else
 		self.bestMiniTarget = self getBestMiniTarget( targets );
 
 	if ( distance2D( self.origin, self.bestMiniTarget.origin) > 768 ) 
 		self thread setMiniEngagementSpeed();
 
 	self notify( "acquiringMiniTarget" );
 	self.mgTurret SetTargetEntity( self.bestMiniTarget, ( 0,0,42 ) );  // sets turret to target entity
 	wait( .15 );
 	self thread fireMiniOnTarget(); // fires on current target.
 	self thread watchMiniTargetDeath( targets ); //abandons target when target killed         
 	self thread watchMiniTargetDistance( targets );
 	self thread watchMiniTargetThreat( self.bestMiniTarget );
 }
 
 fireMiniOnTarget()
 {
 	self endon( "death" );
 	self endon( "abandonedMiniTarget" );
 	self endon( "killedMiniTarget" );
 	noTargTime = undefined;
 	miniAcquiredTime = getTime();
 
 	if ( !isDefined( self.bestMiniTarget ) )
 	{
 		println("No Targ to fire on");
 		return;
 	}
 
 	println("firing on best target");
 
 	while( 1 )
 	{
 		if ( !isDefined ( self.mgTurret getTurretTarget( true ) ) )
 		{
 			if ( !isDefined( noTargTime ) )
 				noTargTime = getTime();
 
 			curTime = getTime();
 
 			if ( noTargTime - curTime > 1 )
 			{              
 				noTargTime = undefined;
 				self thread explicitAbandonMiniTarget();
 				return;
 			}
 
 			println("Waiting because the turret doesnt have a target" );
 
 			wait ( .5 );
 			continue;
 		}
 
 // 		if ( getTime() > miniAcquiredTime + 1000 && !isDefined( self.bestTarget ) )
 // 		{
 // 			if ( distance2D(self.origin, self.bestMiniTarget.origin ) > 768 )
 // 			{
 // 				targets[0] = self.bestMiniTarget;
 // 				self acquireTarget( targets );
 // 			}
 // 		}
 	    
 		numShots = randomIntRange( 2, 6 );
 		for ( i = 0; i < numShots; i++ )
 		{
 			println( "actually shooting turret" );
 			self.mgTurret ShootTurret();
 			wait ( .25 );
 		}
 		wait ( randomFloatRange( 0.5, 3.0 ) );
 	}
 }
 
 watchMiniTargetDeath( targets )
 {
 	self endon( "abandonedMiniTarget" );
 	self endon( "death" );
 	if ( ! isDefined( self.bestMiniTarget ) )
 		return;
 
 	self.bestMiniTarget waittill( "death" );
 
 	self notify( "killedMiniTarget" );
 	println( "Killed Mini Target" );
 
 	self.bestMiniTarget = undefined;
 	self.mgTurret ClearTargetEntity();
 	self tankGetMiniTargets();
 }
 
 watchMiniTargetDistance( targets )
 {
     self endon( "abandonedMiniTarget" );
     self endon( "death" );
     
     for ( ;; )
     {
         if (! isDefined( self.bestMiniTarget ) )
             return;
 
         trace = BulletTrace( self.mgTurret.origin, self.bestMiniTarget.origin, false, self );
         traceDistance = Distance(self.origin, trace["position"] );
         
         if ( traceDistance > 1024 )
         {
             println( "MINI TARGET DIST TOO FAR!!!" );
             self thread explicitAbandonMiniTarget();
             return;  
         }
         println( traceDistance );
         wait ( 2 );
     }              
 }
 
 watchMiniTargetThreat( curTarget )
 {
     self endon( "abandonedMiniTarget" );
     self endon( "death" );
     self endon( "killedMiniTarget" );
                 
 	for ( ;; )
 	{
 		miniTargets = [];
 		players = level._players;
 	    
 		for (i = 0; i <= players.size; i++)
 		{
 			if ( isMiniTarget( players[i] ) )
 			{
 				if( !isdefined( players[i] ) )
 					continue;
 
 				if( !isdefined(curTarget) )
 					return;
 
 				traceOldTarg = Distance(self.origin, CurTarget.origin );
 				traceNewTarg = Distance(self.origin, players[i].origin );
 
 				if ( traceNewTarg < traceOldTarg )
 				{
 					self thread explicitAbandonMiniTarget();
 					return;  
 				}
 			}
             
 			wait( .05 );
 		}
 	    
 		wait( .25 );                           
 	}              
 }
 
 explicitAbandonMiniTarget( noNewTarget )
 {
 	self notify( "abandonedMiniTarget" );
 
 	println( "ABANDONED MINI TARGET" );
 
 	self.bestMiniTarget = undefined;
 	self.mgTurret ClearTargetEntity();
 
 	if ( isDefined(noNewTarget) && noNewTarget )
 		return;
 
 	self thread tankGetMiniTargets();
 	return;
 }
 
 
 addToTankList()
 {
     level._tanks[self getEntityNumber()] = self;        
 }
 
 removeFromTankList()
 {
     level._tanks[self getEntityNumber()] = undefined;
 }              
 
 
 /*************************************************************************
 *
 *             PATHFINDING AND PATH NODE FUNCTIONS
 *
 ***************************************************************************/
 
 getNodeNearEnemies()
 {
     validEnemies = [];
     
     foreach ( player in level._players )
     {
 		if ( player.team == "spectator" )
 			continue;
 		    
 		if ( player.team == self.team )
 			continue;
 		    
 		if ( !isAlive( player ) )
 			continue;
 		    
 		player.dist = 0;
 		validEnemies[validEnemies.size] = player;                            
     }
     
     if ( !validEnemies.size )
         return undefined;
 
     for ( i = 0; i < validEnemies.size; i++ )
     {
         for ( j = i + 1; j < validEnemies.size; j++ )
         {
             dist = distanceSquared( validEnemies[i].origin, validEnemies[j].origin );
             
             validEnemies[i].dist += dist;
             validEnemies[j].dist += dist;
         }
     }
     
     bestPlayer = validEnemies[0];
     foreach ( player in validEnemies )
     {
 		if ( player.dist < bestPlayer.dist )
 			bestPlayer = player;
     }
 
     bestOrigin = bestPlayer.origin;
     
     sortedNodes = sortByDistance( level._graphNodes, bestOrigin );
     
     //thread drawLine( bestOrigin, sortedNodes[0].origin, 10.0, (1,0,1) );
     
     return ( sortedNodes[0] );
 }
 
 
 setupPaths()
 {
     tankNodes = [];
     startNodes = [];
     endNodes = [];
     aStarGraphNodes = [];
                 
     // setup the start node
     tankNode = GetVehicleNode( "startnode", "targetname" );
     tankNodes[tankNodes.size] = tankNode;
     startNodes[startNodes.size] = tankNode;
                 
 	while ( isDefined( tankNode.target ) )
 	{
 		lastNode = tankNode;
 		tankNode = GetVehicleNode( tankNode.target, "targetname" );
 		tankNode.prev = lastNode;
 	    
 		// case for connected path
 		if ( tankNode == tankNodes[0] )               
 			break;
 
 		tankNodes[tankNodes.size] = tankNode;
 	    
 		// case for disconnected path
 		if ( !isDefined( tankNode.target ) )
 			return;
 	}
 
 	tankNodes[0].branchNodes = [];
 	tankNodes[0] thread handleBranchNode( "forward" );
 	aStarGraphNodes[aStarGraphNodes.size] = tankNodes[0];
 
 	// find the start and end nodes of the branches
 	branchNodes = GetVehicleNodeArray( "branchnode", "targetname" );
 	foreach ( branchNode in branchNodes )
 	{
 		tankNode = branchNode;
 		tankNodes[tankNodes.size] = tankNode;
 		startNodes[startNodes.size] = tankNode;
 
 		while ( isDefined( tankNode.target ) )
 		{
 			lastNode = tankNode;
 			tankNode = GetVehicleNode( tankNode.target, "targetname" );
 			tankNodes[tankNodes.size] = tankNode;
 			tankNode.prev = lastNode;
 			if ( !isDefined( tankNode.target ) )
 			{
 				endNodes[endNodes.size] = tankNode;
 			}
 		}
 	}
 
     // detect and initialize the branch nodes.  These will be used for the aStar node graph
     foreach ( tankNode in tankNodes )
     {                              
 		isBranchNode = false;
 		foreach ( startNode in startNodes )
 		{
 			if ( startNode == tankNode )
 				continue;
 
 			if ( startNode.target == tankNode.targetname )
 				continue;
 			    
 			if ( isDefined( tankNode.target ) && tankNode.target == startNode.targetname )
 				continue;
 
 			if ( distance2d( tankNode.origin, startNode.origin ) > 80 )
 				continue;
 
 			startNode thread handleCapNode( tankNode, "reverse" );
 			startNode.prev = tankNode;
 
 			if ( !isDefined( tankNode.branchNodes ) )
 				tankNode.branchNodes = [];
 
 			tankNode.branchNodes[tankNode.branchNodes.size] = startNode;
 		    
 			isBranchNode = true;
 		}
                     
 		if ( isBranchNode )
 		{
 			tankNode thread handleBranchNode( "forward" );
 		}
                     
         isJoinNode = false;
 		foreach ( endNode in endNodes)
 		{
 			if ( endNode == tankNode )
 				continue;
 		    
 			if ( !isDefined( tankNode.target ) )
 				continue;
 		    
 			if ( tankNode.target == endNode.targetname )
 				continue;             
 
 			if ( isDefined( endNode.target ) && endNode.target == tankNode.targetname )
 				continue;             
 		    
 			if ( distance2d( tankNode.origin, endNode.origin ) > 80 )
 				continue;
 
 			endNode thread handleCapNode( tankNode, "forward" );
 			endNode.next = getVehicleNode( tankNode.targetname, "targetname" );
 			//endNode.target = tankNode.targetname; // READ-ONLY field...
 			endNode.length = distance( endNode.origin, tankNode.origin );
 
 			if ( !isDefined( tankNode.branchNodes ) )
 				tankNode.branchNodes = [];
 
 			tankNode.branchNodes[tankNode.branchNodes.size] = endNode;
 		    
 			isJoinNode = true;
 		}
                     
 		if ( isJoinNode )
 		{
 			assert( !isBranchNode );
 			tankNode thread handleBranchNode( "reverse" );
 		}
                     
 		if ( isJoinNode || isBranchNode )
 			aStarGraphNodes[aStarGraphNodes.size] = tankNode;
     }
 
     if ( aStarGraphNodes.size < 3 )
     {
         level notify ( "end_tankPathHandling" );
         return;
     }
 
     // subdivide the path a bit...
     segmentNodes = [];
     foreach( tankNode in tankNodes )
     {
 		if ( !isDefined( tankNode.branchNodes ) )
 			continue;
 		    
 		segmentNodes[segmentNodes.size] = tankNode;
     }
 
     foreach ( segmentNode in segmentNodes )
     {
         tankNode = segmentNode;
         pathLength = 0;
                     
         while ( isDefined( tankNode.target ) )
         {
 			prevNode = tankNode;
 			tankNode = GetVehicleNode( tankNode.target, "targetname" );
 			pathLength += distance( tankNode.origin, prevNode.origin );
 
 			if ( tankNode == segmentNode )              
 				break;
 			    
 			if ( isDefined( tankNode.branchNodes ) )
 				break;
         }
 
         if ( pathLength > 1000 )
         {
             tankNode = segmentNode;
             curLength = 0;
 
             while ( isDefined( tankNode.target ) )
             {
                 prevNode = tankNode;
                 tankNode = GetVehicleNode( tankNode.target, "targetname" );
                 
                 curLength += distance( tankNode.origin, prevNode.origin );
                 if ( curLength < pathLength / 2 )
                     continue;
 
                 tankNode.branchNodes = []; // necessary?
                 tankNode thread handleBranchNode( "forward" );
                 aStarGraphNodes[aStarGraphNodes.size] = tankNode;
                 break;
             }
         }
     }
 
     level._graphNodes = initNodeGraph( aStarGraphNodes );
     if( !isDefined(level._graphNodes) )
     {
          println("level.graphnodes undefined");
     }
     
     foreach ( tankNode in tankNodes )
     {
 		if ( !isDefined( tankNode.graphId ) )
 			tankNode thread nodeTracker();
     }
 }
 
 
 
 getRandomBranchNode( direction )
 {
 	branchNodes = [];
 	foreach ( graphId, linkNode in self.links )
 	{
 		// pick a branch in the direction we're already heading
 		if ( self.linkDirs[graphId] != direction )
 			continue;
 	                    
 		branchNodes[branchNodes.size] = linkNode;
 	}
 
 	return ( branchNodes[randomInt( branchNodes.size )] );
 }
 
 
 getNextNodeForEndNode( endNode, direction )
 {
 	graphNode = level._graphNodes[self.graphId];
 
 	continuePath = generatePath( graphNode, endNode, undefined, direction );
 	continueG = continuePath[0].g;
 
 	changePath = generatePath( graphNode, endNode, undefined, level._otherDir[direction] );
 	changeG = changePath[0].g;
 
 	// temporarily force the tank to only go forward
 	if ( !getDvarInt( "tankDebug" ) )
 		changeG = 9999999;
 
 	if ( continueG <= changeG )
 		return ( continuePath[1] );
 }
 
 
 handleBranchNode( direction )
 {
     level endon ( "end_tankPathHandling" );
     for ( ;; )
     {
         self waittill( "trigger", tank, wasForced );
 
         graphNode = level._graphNodes[self.graphId];
 
         tank.node = self;
         
         nextGraphNode = undefined;
         if ( isDefined( tank.endNode ) && tank.endNode != graphNode )
         {
 			nextGraphNode = getNextNodeForEndNode( tank.endNode, tank.veh_pathdir );
 
 			if ( !isDefined( nextGraphNode ) )
 				tank thread setDirection( level._otherDir[tank.veh_pathdir] );
         }
         
         if ( !isDefined( nextGraphNode ) || nextGraphNode == graphNode )
         {
             nextGraphNode = graphNode getRandomBranchNode( tank.veh_pathdir );
         }
 
         goalNode = graphNode.linkStartNodes[nextGraphNode.graphId];
 
         if ( tank.veh_pathdir == "forward" )
             nextLinkNode = self getNextNode();
         else
             nextLinkNode = self getPrevNode();
 
         // if we're already on this path, just keep going
         if ( nextLinkNode != goalNode )
             tank startPath( goalNode );
     }
 }
 
 
 handleCapNode( joinNode, direction )
 {
     for ( ;; )
     {
         self waittill( "trigger", tank );
         
         if ( tank.veh_pathdir != direction )
             continue;
         
         debugPrintLn2( "tank starting path at join node: " + joinNode.graphId );
                         
         tank startPath( joinNode );
     }
 }
 
 
 nodeTracker()
 {
 	self.forwardGraphId = getForwardGraphNode().graphId;
 	self.reverseGraphId = getReverseGraphNode().graphId;
                 
 	for ( ;; )
 	{
 		self waittill ( "trigger", tank, wasForced );
 	    
 		tank.node = self;
 	    
 		/#
 		if ( getDvarInt( "tankForceTrigger" ) )
 		{
 			if ( tank.veh_pathdir == "forward" )
 				tank thread forceTrigger( self, self getNextNode(), tank );
 			else
 				tank thread forceTrigger( self, self getPrevNode(), tank );
 		}
 		#/
 
 		tank.forwardGraphId = self.forwardGraphId;
 		tank.reverseGraphId = self.reverseGraphId;
 	    
 		if ( !isDefined( self.target ) || self.targetname == "branchnode" )
 			nodeType = "TRANS";
 		else
 			nodeType = "NODE";
 
 		if ( isDefined( wasForced ) )
 			debugPrint3D( self.origin, nodeType, (1,0.5,0), 1, 2, 100 );
 		else
 			debugPrint3D( self.origin, nodeType, (0,1,0), 1, 2, 100 );
 	}
 }
 
 
 forceTrigger( prevNode, nextNode, tank )
 {
     nextNode endon ( "trigger" );
     prevNode endon ( "trigger" );
     tank endon ( "death" );
     
     minDist = distanceSquared( tank.origin, nextNode.origin );
     tankDir = tank.veh_pathdir;
 
     debugPrint3D( prevNode.origin+(0,0,30), "LAST", (0,0,1), 0.5, 1, 100 );
     debugPrint3D( nextNode.origin+(0,0,60), "NEXT", (0,1,0), 0.5, 1, 100 );
 
     timeOutNextFrame = false;
     for ( ;; )
     {
         wait ( 0.05 );
         
         // tank changed direction
         if ( tankDir != tank.veh_pathdir )
         {
             debugPrintLn2( "tank missed node: reversing direction" );
             tank thread forceTrigger( nextNode, prevNode, tank );
             return;
         }
         
         if ( timeOutNextFrame )
         {
             debugPrintLn2( "... sending notify." );
             nextNode notify ( "trigger", tank, true );
             return;
         }
         
         curDist = distanceSquared( tank.origin, nextNode.origin );
         
         if ( curDist > minDist )
         {
             timeOutNextFrame = true;
             debugPrintLn2( "tank missed node: forcing notify in one frame..." );
         }
                         
         minDist = curDist;                             
     }
 }
 
 
 getForwardGraphNode()
 {
     assert( !isDefined( self.graphId ) );
     
     checkNode = self;            
     while ( !isDefined( checkNode.graphId ) )
 		checkNode = checkNode getNextNode();
                     
     return checkNode;
 }
 
 
 getReverseGraphNode()
 {
     assert( !isDefined( self.graphId ) );
     
     checkNode = self;            
     while ( !isDefined( checkNode.graphId ) )
         checkNode = checkNode getPrevNode();
                     
     return checkNode;
 }
 
 
 getNextNode()
 {
 	if ( isDefined( self.target ) )
 		return ( GetVehicleNode( self.target, "targetname" ) );
 	else
 		return ( self.next );
 }
 
 
 getPrevNode()
 {
     return self.prev;
 }
 
 
 
 // Builds the aStar node graph
 initNodeGraph( astarBaseNodes )
 {
     graphNodes = [];
     foreach ( pathNode in aStarBaseNodes )
     {
         graphNode = spawnStruct();
         graphNode.linkInfos = [];
         graphNode.links = [];
         graphNode.linkLengths = [];
         graphNode.linkDirs = [];
         graphNode.linkStartNodes = [];
         graphNode.node = pathNode;
         graphNode.origin = pathNode.origin;
         graphNode.graphId = graphNodes.size;
         pathNode.graphId = graphNodes.size;
 
         debugPrint3D( graphNode.origin + (0,0,80), graphNode.graphId, (1,1,1), 0.65, 2, 100000 );
 
         graphNodes[graphNodes.size] = graphNode;                     
     }
 
     foreach ( pathNode in aStarBaseNodes )
     {
 		graphId = pathNode.graphId;
 
 		checkNode = GetVehicleNode( pathNode.target, "targetname" );
 		linkLength = distance( pathNode.origin, checkNode.origin );
 		linkStartNode = checkNode;
 	    
 		while ( !isDefined( checkNode.graphId ) )
 		{
 						linkLength += distance( checkNode.origin, checkNode.prev.origin );
 	                    
 						if ( isDefined( checkNode.target ) )
 										checkNode = GetVehicleNode( checkNode.target, "targetname" );
 						else
 										checkNode = checkNode.next;
 		}
 
 		assert( checkNode != pathNode );
 		graphNodes[graphId] addLinkNode( graphNodes[checkNode.graphId], linkLength, "forward", linkStartNode );
 
 		checkNode = pathNode.prev;
 		linkLength = distance( pathNode.origin, checkNode.origin );
 		linkStartNode = checkNode;
 	    
 		while ( !isDefined( checkNode.graphId ) )
 		{
 						linkLength += distance( checkNode.origin, checkNode.prev.origin );
 						checkNode = checkNode.prev;
 		}
 
 		assert( checkNode != pathNode );                           
 		graphNodes[graphId] addLinkNode( graphNodes[checkNode.graphId], linkLength, "reverse", linkStartNode );
 	    
 		foreach ( branchNode in pathNode.branchNodes )
 		{
 			checkNode = branchNode;
 			linkLength = distance( pathNode.origin, checkNode.origin );
 			linkStartNode = checkNode;
             
 			if ( checkNode.targetname == "branchnode" )
 			{
 				while ( !isDefined( checkNode.graphId ) )
 				{
 					if ( isDefined( checkNode.target ) )
 									nextNode = GetVehicleNode( checkNode.target, "targetname" );
 					else
 									nextNode = checkNode.next;
                                     
 					linkLength += distance( checkNode.origin, nextNode.origin );
 					checkNode = nextNode;
 				}
                 
 				assert( checkNode != pathNode );                           
 				graphNodes[graphId] addLinkNode( graphNodes[checkNode.graphId], linkLength, "forward", linkStartNode );
 			}              
 			else
 			{
 				while ( !isDefined( checkNode.graphId ) )
 				{
 					linkLength += distance( checkNode.origin, checkNode.prev.origin );
 					checkNode = checkNode.prev;
 				}
 
 				assert( checkNode != pathNode );                           
 				graphNodes[graphId] addLinkNode( graphNodes[checkNode.graphId], linkLength, "reverse", linkStartNode );
 			}
 		}
     }
 
     return graphNodes;
 }
 
 
 addLinkNode( graphNode, linkLength, linkDir, linkStartNode )
 {
     assert( self.graphId != graphNode.graphId );
     assert( !isDefined( self.links[graphNode.graphId] ) );
     
     self.links[graphNode.graphId] = graphNode;
     self.linkLengths[graphNode.graphId] = linkLength;
     self.linkDirs[graphNode.graphId] = linkDir;
     self.linkStartNodes[graphNode.graphId] = linkStartNode;
 
     linkInfo = spawnStruct();
     linkInfo.toGraphNode = graphNode;
     linkInfo.toGraphId = graphNode.graphId;
     linkInfo.length = linkLength;
     linkInfo.direction = linkDir;
     linkInfo.startNode = linkStartNode;
     
     self.linkInfos[graphNode.graphId] = linkInfo;
 }
 
 
 // call function as generatePath(startNode, destNode), otherwise paths will be reversed
 generatePath( destNode, startNode, blockedNodes, direction )
 {
 	level._openList = [];
 	level._closedList = [];
 	foundPath = false;
 	pathNodes = [];
 
 	if ( !isDefined( blockedNodes ) )
 					blockedNodes = [];
 
 	startNode.g = 0;
 	startNode.h = getHValue( startNode, destNode );
 	startNode.f = startNode.g + startNode.h;
 
 	addToClosedList( startNode );
 
 	curNode = startNode;
 	for ( ;; )
 	{
 		foreach ( linkId, checkNode in curNode.links )
 		{
 			if ( is_in_array( blockedNodes, checkNode ) )
 				continue;
 			    
 			if ( is_in_array( level._closedList, checkNode ) )
 				continue;
 			    
 			if ( isDefined( direction ) && checkNode.linkDirs[curNode.graphId] != direction )
 				continue;
                             
 			if ( !is_in_array( level._openList, checkNode ) )
 			{
 				addToOpenList( checkNode );
                 
 				checkNode.parentNode = curNode;
 				checkNode.g = getGValue( checkNode, curNode );
 				checkNode.h = getHValue( checkNode, destNode );
 				checkNode.f = checkNode.g + checkNode.h;
                 
 				if ( checkNode == destNode )
 					foundPath = true;            
 			}
 			else
 			{
 				if ( checkNode.g < getGValue( curNode, checkNode ) )
 								continue;
                                 
 				checkNode.parentNode = curNode;
 				checkNode.g = getGValue( checkNode, curNode );
 				checkNode.f = checkNode.g + checkNode.h;
 			}
 		}
         
 		if ( foundPath )
 						break;
                         
 		addToClosedList( curNode );
         
 		bestNode = level._openList[0];
 
 		foreach ( testNode in level._openList )
 		{
 			if ( testNode.f > bestNode.f )
 				continue;
                             
 			bestNode = testNode;
 		}
         
 		assert( isDefined( bestNode ) ); // the tank should always have a path
 
 		addToClosedList( bestNode );
 		curNode = bestNode;
 	}
 
 	assert( isDefined( destNode.parentNode ) );
 
 	curNode = destNode;
 	while (curNode != startNode)
 	{
 		pathNodes[pathNodes.size] = curNode;
 		curNode = curNode.parentNode;
 	}
 	pathNodes[pathNodes.size] = curNode;
 
 	return pathNodes;          
 }
 
 
 addToOpenList( node )
 {
 	node.openListID = level._openList.size;
 	level._openList[level._openList.size] = node;
 	node.closedListID = undefined;
 }
 
 
 addToClosedList( node )
 {
 	if (isdefined (node.closedListID))
 		return;
 
 	node.closedListID = level._closedList.size;
 	level._closedList[level._closedList.size] = node;
 
 	if (!is_in_array (level._openList, node))
 		return;
 	    
 	level._openList[node.openListID] = level._openList[level._openList.size - 1];
 	level._openList[node.openListID].openListID = node.openListID;
 	level._openList[level._openList.size - 1] = undefined;
 	node.openListID = undefined;
 }
 
 
 getHValue (node1, node2)
 {
 	return (distance (node1.node.origin, node2.node.origin));
 }
 
 
 getGValue(node1, node2)
 {
 	return ( node1.parentNode.g + node1.linkLengths[node2.graphId] );
 }
 
 
 is_in_array( aeCollection, eFindee )
 {
 	for ( i = 0; i < aeCollection.size; i++ )
 	{
 		if ( aeCollection[ i ] == eFindee )
 			return( true );
 	}
 
 	return( false );
 }
 
 
 drawPath( pathNodes )
 {
 	for ( i = 1; i < pathNodes.size; i++ )
 	{
 		startNode = pathNodes[i-1];
 		endNode = pathNodes[i];
 	    
 		if ( startNode.linkDirs[endNode.graphId] == "reverse" )
 			level thread drawLink( startNode.node.origin, endNode.node.origin, (1,0,0) );
 		else
 			level thread drawLink( startNode.node.origin, endNode.node.origin, (0,1,0) );
 	                    
 		vehNode = startNode.linkStartNodes[endNode.graphId];
 		level thread drawLink( startNode.node.origin + (0,0,4), vehNode.origin + (0,0,4), (0,0,1) );
 	    
 		if ( startNode.linkDirs[endNode.graphId] == "reverse" )
 		{
 			while ( !isDefined( vehNode.graphId ) )
 			{
 				lastVehNode = vehNode;
 				vehNode = vehNode.prev;
 				level thread drawLink( lastVehNode.origin + (0,0,4), vehNode.origin + (0,0,4), (0,1,1) );
 			}
 		}
 		else
 		{
 			while ( !isDefined( vehNode.graphId ) )
 			{
 				lastVehNode = vehNode;
 			    
 				if ( isDefined( vehNode.target ) )
 					vehNode = GetVehicleNode( vehNode.target, "targetname" );                                                 
 				else
 					vehNode = vehNode.next;
 
 				level thread drawLink( lastVehNode.origin + (0,0,4), vehNode.origin + (0,0,4), (0,1,1) );
 			}                                              
 		}
 	}
 }
 
 
 drawGraph( pathNodes )
 {
 	/*
 	level.pathZOffset = 0;
 	foreach ( node in pathNodes )
 	{
 		println( node.links.size );
 		foreach ( linkId, graphNode in node.links )
 		{
 			if ( node.linkDirs[linkId] == "reverse" )
 				level thread drawLink( node.node.origin, graphNode.node.origin, (0,1,0) );
 			else
 				level thread drawLink( node.node.origin, graphNode.node.origin, (1,0,0) );
 
 			//if ( node.linkDirs[linkId] == "reverse" )
 			//	continue;
 			    
 			//level thread drawLink( pathNodes[graphId].node.origin, pathNodes[node.graphId].node.origin, (randomFloat( 2 ), randomFloat( 2 ), randomFloat( 2 )) );                               
 		}
 	}
 	*/
 }
 
 
 drawLink( start, end, color )
 {
 	level endon ( "endpath" );
 	for ( ;; )
 	{
 		line(start, end, color, true);
 		wait 0.05;
 	}
 }
 
 debugPrintLn2( printString )
 {
 	/#
 	if ( getDvarInt( "tankDebug" ) )
 		printLn( printString );
 	#/
 }
 
 debugPrint( printString )
 {
 	/#
 	if ( getDvarInt( "tankDebug" ) )
 		print( printString );
 	#/
 }
 
 
 debugPrint3D( origin, printString, color, alpha, scale, duration )
 {
 	/#
 	if ( getDvarInt( "tankDebug" ) )
 	{
 		print3d( origin, printString, color, alpha, scale, duration );
 		println( "3D: " + printString );
 	}
 	#/
 }
 
 
 drawTankGraphIds()
 {
 	/#
 	if ( getDvarInt( "tankDebug" ) )
 	{
 		self notify ( "drawTankGraphIds" );
 		self endon ( "drawTankGraphIds" );
 	    
 		for ( ;; )
 		{
 			print3d( self.origin + (0,0,128), "FW: " + self.forwardGraphId + " RV: " + self.reverseGraphId, (0,1,0), 1, 3, 1 );
 			wait ( 0.05 );
 		}
 	}
 	#/
 }
 
 main( model )
 {
                 
 
 }
 
 //*******************************************************************
 //                                                                                                                                                                                                                                                                            *
 //                                                                                                                                                                                                                                                                            *
 //*******************************************************************
 /*QUAKED script_vehicle_nx_chinese_ugv_mp_mp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER
 
 
 maps\mp\killstreaks\_tank::main( "nx_vehicle_chinese_ugv" );
 
 
 include,nx_vehicle_chinese_ugv_mp
 sound,nx_ugv,,all_sp
 
 defaultmdl="nx_vehicle_chinese_ugv"
 default:"vehicletype" "nx_ugv"
 default:"script_team" "allies"
 */