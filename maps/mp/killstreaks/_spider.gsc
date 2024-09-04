#include maps\mp\_utility;
#include common_scripts\utility;

//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Prototype killstreak - Roboturret                            **
//             Once the killstreak is deployed, it will follow the player   **
//             around the map and kill enemies.                             **
//                                                                          **
//    Created: May 31th, 2011 - James Chen                                  **
//                                                                          **
//***************************************************************************/

//tagJC<NOTE>: The current implementation consists of three components: one very small joint as vehicle serving as the connecting
//             base for the turret and the legs.
//tagJC<TODO>: Known Issues (bugs)
//             (1) The animation for the turret is controlled by the another underlying (turret) script. Currently, the turret
//                 does not play the proper animation when tracking/shooting enemies.
//             (2) The robo legs is 90 degree from the correct orientation of the vehicle.
//tagJC<TODO>: Determine a better pathing logic under the current vehicle pathing limitation so the roboturret can really follow
//             the players around the level.             

init()
{
	//tagJC<NOTE>: Precache all the assets needed.
	//tagJC<NOTE>: nx_vehicle_roboturret_legs_vehicle is a very small joint which has all the required TAG for a vehicle.
	//             It is used so the robo legs and the roboturrets can be attached to it and the game will handle it properly
	//             according to the default vehicle animation.
	PrecacheVehicle( "proto_nx_vehicle_roboturret_legs_vehicle" );
	precacheModel( "nx_vehicle_roboturret_legs_vehicle" );

	//tagJC<NOTE>: nx_vehicle_spider is the robo legs.
	PrecacheVehicle( "nx_spider_mp" );
	precacheModel( "nx_vehicle_spider" );
                
	//tagJC<NOTE>: nx_ugv_robo_turret is the robo turret.
	precacheTurret( "ugv_robo_turret_mp" );
	precacheModel( "nx_ugv_robo_turret" );

	//tagJC<NOTE>: These are the animations for the robo legs.
	precacheMpAnim( "nx_vh_roboturret_run" );
	precacheMpAnim( "nx_vh_roboturret_walk" );
	precacheMpAnim( "nx_vh_roboturret_idle" );

	//level._spiderSpawners = Vehicle_GetSpawnerArray();
	
	//tagJC<NOTE>: This is the killstreak activation callback for the roboturret.
	level._killstreakFuncs["spider"] = ::try_use_killstreak;
	
	//tagJC<NOTE>: Use this script to update/initialize players as they connect to the game.
	level thread onPlayerConnect();

	//tagJC<NOTE>: In order for the roboturret to work correctly, the level needs to have at least one "spidernode".
	level._spiderNodes = getVehicleNodeArray( "spidernode", "script_noteworthy" );
	StartNodeMappingTable();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: Checking whether the level is properly set up for the roboturret killstreak.
try_use_killstreak( lifeId )
{
    if ( ! level._spiderNodes.size )
    {
		self iPrintLnBold( "Spider is currently not supported in this level, bug your friendly neighborhood Level Designer, Failed to locate valid spider node." );
		return false;
	}

	//tagJC<NOTE>: Test script of which any desired testing can be performed before integrated into working prototype.
	//testscript();

	killstreak_template_use( lifeId );
	
	return true;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: This function creates a mapping table for all the start nodes.  It uses the coordinate of the start node as the 
//             the index for the first dimension of the array.  The second dimension of the array stores all the start nodes that
//             the current start node can travel to.
StartNodeMappingTable()
{
	println( "StartNodeMappingTable" );
	level._StartNodeMapping = [];
	println( "################################" );
	for ( i = 0; i < level._spiderNodes.size; i++ )
	{
		StartNode = level._spiderNodes[i];
		//tagJC<NOTE>: Getting the end node of the path whose start node is StartNode
		EndNode = GetVehicleNode( StartNode.target, "targetname" );
		//tagJC<NOTE>: Creating the index using the StartNode's coordinate
		index = "X" + StartNode.origin[0] + "Y" + StartNode.origin[1] + "Z" + StartNode.origin[2];
		println( "The index is " + index );  
		for ( j = 0; j < level._spiderNodes.size; j++ )
		{
			TargetStartNode = level._spiderNodes[j];
			//tagJC<NOTE>: Store the TargetStartNode into the array if its distance is less than 250 units from the EndNode
			if ( distance( EndNode.origin, TargetStartNode.origin ) < 250 )
			{
				if ( ! IsDefined (level._StartNodeMapping[index]) )
				{
					level._StartNodeMapping[index][0] = TargetStartNode;
				}
				else
				{
					ArraySize = level._StartNodeMapping[index].size;
					level._StartNodeMapping[index][ArraySize] = TargetStartNode;
				}
			} 
		} 
		//tagJC<NOTE>: Debugging output to look at the array
		println( "There are " + level._StartNodeMapping[index].size + " startnodes connected" );
		for ( r = 0; r < level._StartNodeMapping[index].size; r++)
		{ 
			println( "   The coordinate is " + level._StartNodeMapping[index][r].origin );
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: Test script for any desired functionality, such as loading model, playing certain animation etc..
//             This is to make sure things are working properly before they are integrated into the working prototype.
testscript()
{
	 
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// tagJC<NOTE>: This is the callback that executes when the killstreak is activated by a player pressing on the dpad.
killstreak_template_use( lifeId )
{
	assert( isDefined( self ) );
	
	//tagJC<NOTE>: spawning the small joint as the vehicle and setting the associated attributes.
	level._spider = spawnVehicle( "nx_vehicle_roboturret_legs_vehicle", "roboturret", "proto_nx_vehicle_roboturret_legs_vehicle", (0, 0, 0), (0, 0, 0) );
	level._spider.health = 3000;
	level._spider.targeting_delay = 1;
	level._spider.team = self.team;
	level._spider.pers["team"] = level._spider.team;
	level._spider.owner = self;
	level._spider setCanDamage( true );
	level._spider.standardSpeed = 10;
	level._spider.evadeSpeed = 50;
	level._spider.dangerSpeed = 15;
	level._spider.miniEngagementSpeed = 15;
	level._spider.engagementSpeed = 15;
	//tagJC<NOTE>: Kill the vehicle if it is dropped for more than 2048 units
	level._spider thread deleteOnZ();

	//tagJC<NOTE>: Spawning the robo legs
	spiderScriptModel = spawn ( "script_model", level._spider.origin );
	spiderScriptModel setModel ( "nx_vehicle_spider" );
	spiderScriptModel ScriptModelPlayAnim ( "nx_vh_roboturret_idle" );
	level._spiderCurrentAnimation = "nx_vh_roboturret_idle";
	//tagJC<NOTE>: Linking the robo legs to the vehicle.
	spiderScriptModel linkTo ( level._spider, "TAG_ORIGIN" , (0, 0, 0), (0, 0, 0) );
	spiderScriptModel thread loopOnLegs ( level._spider );
	
	//tagJC<NOTE>: Spawning the roboturret and setting its attributes.
	spiderTurret = spawnTurret( "misc_turret", level._spider.origin, "ugv_main_turret_mp" );
	//tagJC<NOTE>: Linking the turret to the scripted robo legs model.
	spiderTurret linkTo( spiderScriptModel, "TAG_TURRET", (0,0,0), (0,0,0) );
	spiderTurret setModel( "nx_ugv_robo_turret" );
	spiderTurret.angles = level._spider.angles; 
    spiderTurret.owner = level._spider.owner;
    spiderTurret makeTurretInoperable();
	level._spider.mgTurret = spiderTurret; 
    level._spider.mgTurret SetDefaultDropPitch( 0 );
	//tagJC<NOTE>: Start the turret to track and shoot enemies.
	level._spider thread tankGetMiniTargets();

	//tagJC<NOTE>: Finding the spider start node that is closest to the player.
	closest_spidernode = find_closest_spidernode( self, level._spiderNodes );
	
	//tagJC<NOTE>: Start moving the roboturret according to player's position.
	level._spider thread move_spider ( self, closest_spidernode );
	
	return true;  
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: There are three animations that the robo legs can play: idel, walk and run
loopOnLegs ( vehicle )
{
	timer = 0;
	while ( 1 )
	{
		self.angle = vehicle.angle;
		speed = vehicle Vehicle_GetSpeed();

		//tagJC<NOTE>: If the vehicle speed is faster than 10 MPH, the legs will run
		if ( speed  > 10 )
		{
			timer = 0;
			if ( level._spiderCurrentAnimation != "nx_vh_roboturret_run" )
			{
				self ScriptModelPlayAnim ( "nx_vh_roboturret_run" );
				level._spiderCurrentAnimation = "nx_vh_roboturret_run";
				self stoploopsound("robot_sentry_walk");
				self playloopsound("robot_sentry_run");
			}
		}
		//tagJC<NOTE>: If the vehicle speed is between 10 and 0 MPH, the legs will walk
		else if ( speed < 10 && speed > 0 )
		{
			timer = 0;
			if ( level._spiderCurrentAnimation != "nx_vh_roboturret_walk" )
			{
				self ScriptModelPlayAnim ( "nx_vh_roboturret_walk" );
				level._spiderCurrentAnimation = "nx_vh_roboturret_walk";
				self stoploopsound("robot_sentry_run");
				self playloopsound("robot_sentry_walk");
			}
		}
		//tagJC<NOTE>: If the vehicle speed is 0 MPH, the legs will be idel
		else
		{
			timer = timer + 1;
			//tagJC<NOTE>: If the roboturret has been idle for 15 seconds
			if ( timer == 30 )
			{
				vehicle playsound ( "roboturret_idle_vo" );
				//vehicle playsound ( "roboturret_kill_vo" );
				timer = 0;
			}
			if ( level._spiderCurrentAnimation != "nx_vh_roboturret_idle" )
			{
				self stoploopsound("robot_sentry_run");
				self stoploopsound("robot_sentry_walk");
				self ScriptModelPlayAnim ( "nx_vh_roboturret_idle" );
				level._spiderCurrentAnimation = "nx_vh_roboturret_idle";
			}
		}
		println ( "timer is: " + timer );
		wait ( 0.5 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: Currently, in order for this implementation to work, designers would have to place many pairs of bi-directional vehicle nodes
//             in the level.  Given the limitation that vehicle seems to be only moving when it is on a vehicle path, the roboturret
//             cannot quite follow the players perfectly yet.  Players would have to get close to the roboturret and then guide
//             it to a different position.
move_spider ( owner, startNode )
{
	//self playsound( "roboturret_deploy_vo" );
	self Vehicle_SetSpeed( 30, 5, 5 );
	//tagJC<NOTE>: Starting the roboturret along the path where its starting node is the roboturret's spawning node
	self AttachPath( startNode );
	self StartPath( startNode );
	self waittill( "reached_end_node" );
	self playsound( "roboturret_deploy_vo" );

	prev_node = startNode;
	while ( 1 )
	{
		index = "X" + prev_node.origin[0] + "Y" + prev_node.origin[1] + "Z" + prev_node.origin[2];
		best_node = find_best_spidernode( owner, level._StartNodeMapping[index] );
		//if ( distance ( owner.origin, level._spider.origin ) > 50 )
		if ( isGettingCloserToPlayer ( owner, best_node ) )
		{
			//if ( prev_node != best_node )
			//{
				self StartPath( best_node );
				self waittill( "reached_end_node" );
				prev_node = best_node;
				//println( "This is after subsequent reached_end_node" );
			//}
		}
		else
		{ 
			wait 0.5;
		} 
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: This function checks whether the turret will be moving away from the player or not
isGettingCloserToPlayer ( owner, StartNode )
{
	EndNode = GetVehicleNode( StartNode.target, "targetname" );
	if ( distance ( owner.origin, EndNode.origin ) > distance ( owner.origin, StartNode.origin ) )
	{
		return false;
	}
	else
	{
		return true;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: From the ReachableNodeList, determine the node that is will lead the turret to the player
find_best_spidernode( owner, ReachableNodeList )
{
	target_vector = VectorNormalize ( owner.origin - level._spider.origin );
	//tagJC<NOTE>: Creating an arbitrary base line using the first node in the node awway
	best_node = ReachableNodeList [0];
	best_dot_product = VectorDot ( VectorNormalize( best_node.origin - level._spider.origin ), target_vector );
	for ( i = 1; i < ReachableNodeList.size; i++)
	{
		//tagJC<NOTE>: If another node in the list can produce a larger dot product, that node is the best node
		dot_product = VectorDot ( VectorNormalize( ReachableNodeList[i].origin - level._spider.origin ), target_vector );
		if ( dot_product > best_dot_product )
		{
			best_node = ReachableNodeList[i];
		}
	}
	return best_node;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
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

        //tagJC<NOTE>: Putting all the players on the oppositing team into a array.
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
		//tagJC<NOTE>: If there is at least one enemy, start acquiring the target
		if ( miniTargets.size > 0 )
		{
			self acquireMiniTarget( miniTargets );
			return;  
		}              
		else
		wait( 0.5 );
		}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: From the potential target list, determine whether there is any target that is feasible/practical for the turret 
//             to target.
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
		{
			return false;
		}       
	}
	return true;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: From the target list, determine which one is the best target and shoot it.
acquireMiniTarget( targets )
{
	self endon( "death" );
 
    //tagJC<NOTE>: If there is only one target in the list, it is the best target.
	if ( targets.size == 1 )
	{
		self.bestMiniTarget = targets[0];
	}
	//tagJC<NOTE>: Else, determine the best target in the list.
	else
	{
		self.bestMiniTarget = self getBestMiniTarget( targets );
	}
                
	self notify( "acquiringMiniTarget" );
	//tagJC<NOTE>: Set turret to target the best target.
	self.mgTurret SetTargetEntity( self.bestMiniTarget, ( 0,0,42 ) );
	wait( .15 );
	//tagJC<NOTE>: Set turret to fire at the best target.
	self thread fireMiniOnTarget(); 
	//tagJC<NOTE>: Abandon the target when it is killed.
	self thread watchMiniTargetDeath( targets );          
	self thread watchMiniTargetDistance( targets );
	self thread watchMiniTargetThreat( self.bestMiniTarget );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: Determine the best target from the target list
getBestMiniTarget( targets )
{
	self endon( "death" );
	tankOrigin = self.origin;
                
	closest = undefined;
	bestTarget = undefined;
                
	foreach ( targ in targets )
	{                              
		curDist = Distance( self.origin, targ.origin );
                                
		//tagJC<NOTE>: If the target is holding or using explosives, push the target to a higher priority
		curWeaon = targ GetCurrentWeapon();
		if ( isSubStr( curWeaon, "at4" ) || isSubStr( curWeaon, "jav" ) || isSubStr( curWeaon, "c4" ) || isSubStr( curWeaon, "smart" ) || isSubStr( curWeaon, "grenade" ) )
		{
			curDist -= 200;
		}									   
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

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: Firing the turret at the target.
fireMiniOnTarget()
{
	self endon( "death" );
	self endon( "abandonedMiniTarget" );
	self endon( "killedMiniTarget" );
	noTargTime = undefined;
	miniAcquiredTime = getTime();
                
	if ( !isDefined( self.bestMiniTarget ) )
	{
		println( "No Targ to fire on" );
		return;
	}
                
	println( "firing at best target" );
                
	while( 1 )
	{
		if ( !isDefined ( self.mgTurret getTurretTarget( true ) ) )
		{
			if ( !isDefined( noTargTime ) )
			{
				noTargTime = getTime();
			}
                                                
			curTime = getTime();
            
			//tagJC<NOTE>: If there has been more than 1 milliseconds without a target, abandon the target.
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
		//tagJC<NOTE>: Firing a random number of shots between 2 to 6.	                                               
		numShots = randomIntRange( 2, 6 );
		for ( i = 0; i < numShots; i++ )
		{
			println( "actually shooting turret" );
			self.mgTurret ShootTurret();
			wait ( .25 );
		}
		wait ( randomFloatRange( 0.05, 0.1 ) );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: Clearing the current target list for the turret and starting to get more targets.
explicitAbandonMiniTarget( noNewTarget )
{
	self notify( "abandonedMiniTarget" );
	println( "ABANDONED MINI TARGET" );
                
	self.bestMiniTarget = undefined;
	self.mgTurret ClearTargetEntity();
                
	if ( isDefined(noNewTarget) && noNewTarget )
	{
		return;
	}
                
	self thread tankGetMiniTargets();
	return;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: Wait for the target's death.  Once the target is killed, clear the target list and get more targets.
watchMiniTargetDeath( targets )
{
	self endon( "abandonedMiniTarget" );
	self endon( "death" );
	if ( ! isDefined( self.bestMiniTarget ) )
	return;
                
	self.bestMiniTarget waittill( "death" );
	//self playsound ( "roboturret_idle_vo" );
	self playsound ( "roboturret_kill_vo" ); 				

	self notify( "killedMiniTarget" );
	println( "Killed Mini Target" );
                
	self.bestMiniTarget = undefined;
	self.mgTurret ClearTargetEntity();
	self tankGetMiniTargets();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: If the target is more than 1024 units away, abandon the target
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

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: If there is a target that is closer to the current target, abandon the curret target
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
				{
					continue;
				}
                                                                
				if( !isdefined(curTarget) )
				{
					return;
				}
                                                                
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

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: From the entity_list, return the one that is closest to the entity
find_closest_spidernode ( target, entity_list )
{
	//tagJC<NOTE>: Use an arbitrary distance as the base for comparision
	closest_distance = distance( target.origin , entity_list[0].origin );
	closest_entity = entity_list[0];
	for ( i = 1; i < entity_list.size; i++ )
	{
		//tagJC<NOTE>: If another entity on the list results in a shorter distance, update the results accordingly
		if ( distance( target.origin , entity_list[i].origin ) < closest_distance )
		{
			closest_distance = distance( target.origin , entity_list[i].origin );
			closest_entity = entity_list[i];
		}
	}
	return closest_entity;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: If a vehicle is dropped more than 2048 units, kill it.
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

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: This function tracks player's movement and put the closest node to the player into a queue
TrackingPlayers( owner )
{
	self.PlayerLocations = [];
	while ( 1 )
	{	
		close_node = find_closest_spidernode( owner, level._spiderNodes );
		if ( self.PlayerLocations.size == 0 )
		{
			self.PlayerLocations[0] = close_node;
		}
		else
		{
			size = self.PlayerLocations.size;
			Player_last_location = self.PlayerLocations[ size - 1 ];
			if ( close_node != Player_last_location )
			{
				self.PlayerLocations[ size ] = close_node;
				//println ( "========== This is inside Tracking Player ============" ); 
				//println ( "The location of the node being added is: " + self.PlayerLocations[ size ].origin);
				//println ( "The size of PlayerLocations is: " + self.PlayerLocations.size );
				//println ( "======================================================" );
			}
		}
		wait( 0.5 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: Remove the first item in the list by shifting entities in the list forward by one slot in the list
RemoveFirstItem ( list )
{
	if ( list.size > 0 )
	{
		for ( i = 0 ; i < list.size - 1 ; i ++ )
		{
			list[ i ] = list[ i + 1 ];
		}
		list[ list.size - 1 ] = undefined; 
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// tagJC<NOTE>: This script is running on the global level object, it monitors players connecting to the game.
//              Its main purpose is to apply the onPlayerSpawned script to each player as they connect to the game.
onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// tagJC<NOTE>: This script is running on each player in the game, it recieves a notification each time the player it is running on spawns in the game
//              Its main purpose is to initialize any per player data, as well as update the player subject to any global killstreak data when that player spawns.
onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill( "spawned_player" );
		println( "player spwaned" );
		
		// init/manage any per player killstreak data here
	}
}

main ( vehicle, model ) 
{

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*
QUAKED script_vehicle_nx_proto_roboturret (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

maps\mp\killstreaks\_spider::main( "nx_vehicle_roboturret_legs_vehicle", "proto_nx_vehicle_roboturret_legs_vehicle" );

include,prototype_nx_vehicle_roboturret

defaultmdl="nx_vehicle_roboturret_legs_vehicle"
default:"vehicletype" "proto_nx_vehicle_roboturret_legs_vehicle"
default:"script_team" "allies"
*/