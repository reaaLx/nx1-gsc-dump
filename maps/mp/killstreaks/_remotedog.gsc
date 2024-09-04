#include maps\mp\_utility;
#include common_scripts\utility;

DOG_TIMEOUT_SEC = 45;
DOG_HUD_TIMER_POS_X = 0;
DOG_HUD_TIMER_POS_Y = -35;
DOG_TURRET_MAX_TARGETING_RANGE = 600;			// 45 feet
DOG_TURRET_SPAWN_GRACE_TIME = 3;				// dog wont shoot any anyone who hasn't been spawned for 3 seconds
DOG_TURRET_MIN_SHOTS = 10;						// minimum shots to fire at a player
DOG_TURRET_MAX_SHOTS = 20;						// maximum shots to fire at a player
DOG_TURRET_FIRE_DELAY = .1;					// how long to wait between shots at a target
DOG_TURRET_MIN_BARRAGE_DELAY = 0;				// how long to wait between firing bursts of shots at a target
DOG_TURRET_MAX_BARRAGE_DELAY = .1;				// how long between burts of shots
DOG_TURRET_MAX_YAW = 60;						// how far the turret can turn from the dogs centerline

//*******************************************************************
//																	*
//																	*
//*******************************************************************

init()
{
	level._killstreakFuncs["remote_dog"] = ::tryRemoteDog;
	level._remoteDogVehicleInfo = "PROTO_nx_remote_dog_play_mp";
	level._remoteDogVehicleModel = "prototype_vehicle_remotedog_vehicle"; // "defaultvehicle"
	level._remoteDogScriptModel = "prototype_vehicle_remotedog";
	level._remoteDogMoveAnim = "german_shepherd_run";
	level._remoteDogIdleAnim = "german_shepherd_idle";
	level._remoteDogTranProp = "miniuav_transition_prop";
	level._remoteDogTurretInfo = "proto_robot_dog_turret_mp";
	level._remoteDogTurretModel = "proto_remotedog_turret";
	level._remoteDogFOV = 120;
	level._remoteDogHealth = 200;
	level._remoteDogAmmo = 100;
	level._remoteDogFireRate = 1; // in tenths of a second, so 10 is fires once a second
	level._remoteDogCrossHair = "ac130_overlay_25mm";

	PreCacheItem( level._remoteDogTranProp );
	precacheString( &"NX_MINIUAV_USE_DRONE" );
	PreCacheShader( "ac130_overlay_grain" );
	PreCacheShader( level._remoteDogCrossHair );

	precacheVehicle( level._remoteDogVehicleInfo );
	precacheModel( level._remoteDogVehicleModel );
	precacheMpAnim( level._remoteDogMoveAnim );
	precacheMpAnim( level._remoteDogIdleAnim );
	precacheModel( level._remoteDogScriptModel );
	precacheTurret( level._remoteDogTurretInfo );
	precacheModel( level._remoteDogTurretModel );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

remoteDogDebugPrint( msg )
{
	IPrintLnBold( msg );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

tryRemoteDog( lifeId )
{
	self thread remoteDogStartup();										// Kick of main UAV loop.
	msg = self waittill_any_return( "death", "cleanup_remote_dog" );	// Wait for death or timeout.

	if( msg == "cleanup_remote_dog" )
	{
		// Wait for weapon transition to happen.
		wait 2.0;
	}

	return true;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

remoteDogPlayerEventListenerThread()
{
	self waittill( "exit_remote_dog" );
	self.remotedog notify( "exit_remote_dog" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

remoteDogStartup()
{
	self endon( "death" );
	self endon( "remote_dog_time_is_up" );
	self endon( "remote_dog_out_of_ammo" );

//	self NotifyOnPlayerCommand( "switch_to_remote_dog", "+actionslot 4" );

    self DisableOffhandWeapons();
    self._dogPlayerOrigin = self GetOrigin();
    self._dogPlayerAngles = self GetPlayerAngles();

	// Wait for transition anim to finish. 
    wait 1.75;

	// Enter the Dawg. 
	pos = self._dogPlayerOrigin + ( 0, 0, 50 );
	
	// setup vehicle
	self.remotedog = spawnVehicle( level._remoteDogVehicleModel, "test_dog", level._remoteDogVehicleInfo, pos, self._dogPlayerAngles );
	self.remotedog.health = level._remoteDogHealth; 
	self.remotedog.maxhealth = self.remotedog.health;
	self.remotedog setCanDamage( true );
	self.remotedog.owner = self;
	self.remotedog.team = self.team;
	self.remotedog.ammo = level._remoteDogAmmo;
	self.remotedog.fireRate = level._remoteDogFireRate;
	self.remotedog.damageCallback = ::Callback_DogDamage;
	// hide the remote dog, we're going to attach another model to it
	self.remotedog Hide();
	
	// setup dog model
	self.remotedog.remoteDogModel = spawn( "script_model", pos );
	self.remotedog.remoteDogModel.owner = self;
	self.remotedog.remoteDogModel setModel( level._remoteDogScriptModel );
	self.remotedog.remoteDogModel ScriptModelPlayAnim( level._remoteDogIdleAnim );
	self.remotedog.remoteDogModel.angles = self._dogPlayerAngles;
	self.remotedog.currAnim = level._remoteDogIdleAnim;
	self.remotedog.remoteDogModel linkto( self.remotedog );
	
	// setup hud and stuff
	self.remotedog notify( "stop_turret_shoot" );
    self.in_dog = true;
	self thread remotedogHud();
	self CameraLinkTo( self.remotedog, "tag_player" );
	self.remote_dog_orig_fov = GetDvarFloat( "cg_fov" );
	self setClientDvar( "cg_fov", level._remoteDogFOV );
	self ThermalVisionFOFOverlayOn();
	self visionSetNakedForPlayer( "cheat_bw", 0 );

	// create the turret for the dawg
	turretPoint = self.remotedog getTagOrigin( "TAG_TURRET" );
	self.remotedog.turret = spawnTurret( "misc_turret", turretPoint, level._remoteDogTurretInfo );
    self.remotedog.turret linkTo( self.remotedog, "TAG_TURRET", (0,0,0), (0,0,0) );
	self.remotedog.turret setModel( level._remoteDogTurretModel );
    self.remotedog.turret.angles = self.remotedog.angles; 
    self.remotedog.turret.owner = self.remotedog.owner;
    self.remotedog.turret makeTurretInoperable(); 
    self.remotedog.turret SetDefaultDropPitch( 0 );
	//self.remotedog.turret.owner = self; 
	 
    // find a point to for the turret to look at when it isn't trying to fire
    offset = turretPoint - self.remotedog.origin;     
    neutralTargetEnt = spawn("script_origin", self.remotedog.turret getTagOrigin("tag_flash") );
    neutralTargetEnt linkTo( self, "tag_origin", offset, (0,0,0) );
    neutralTargetEnt hide();
    self.remotedog.neutralTarget = neutralTargetEnt;
                
    // spawn a thread to control the turret
    self.remotedog thread remoteDogFindTargets();	

	// get them controls hooked up!
//	self ControlsLinkTo( self.remotedog );
	self MiniUAVOn( self.remotedog );
	
	// Kick off timer.
	self hudRemoteDogTimer( DOG_TIMEOUT_SEC );						
	self.remotedog thread RemoteDogWaitForTimeout( DOG_TIMEOUT_SEC );


	// loop for the dog 
	self thread remoteDogLoop( self.remotedog );
	
	// setup a thread to listen for the exit
	self thread remoteDogPlayerEventListenerThread();

	self.remotedog thread remoteDogExitCleanup();		

	return true;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

remoteDogExitCleanup()
{
	remoteDogDebugPrint( "remoteDogExitCleanup()" );	
	msg = self waittill_any_return( "death", "exit_remote_dog", "remote_dog_time_is_up", "remote_dog_out_of_ammo" );	// Wait for either way of exiting a uav.
	remoteDogDebugPrint( "Running cleanup after msg " + msg );
	self.owner thread remoteDogExitPlayer();
	self notify( "cleanup_remote_dog" );
	self.owner notify( "cleanup_remote_dog" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

remoteDogFindTargets()
{
	self endon( "death" );
	self endon( "cleanup_remote_dog" );

	println( "Geting Targets" );

	for ( ;; )
	{
		targets = [];
		players = level._players;
	    
		for (i = 0; i <= players.size; i++)
		{
			if ( isDogTarget( players[i] ) && isdefined( players[i] ) )
			{
				targets[targets.size] = players[i];
			}
			else
			{
				continue;
			}
	        
			wait( .05 );
		}
		if ( targets.size > 0 )
		{
			self acquireTarget( targets );
			return;  
		}              
		else
		{
			wait( .05 );
		}
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

isDogTarget( potentialTarget )
{
	self endon( "death" );

	if ( !isalive( potentialTarget ) || potentialTarget.sessionstate != "playing" )
		return false;

	if ( !isdefined( potentialTarget.pers["team"] ) )
		return false;

	if ( potentialTarget == self.owner )
		return false;

	if ( distanceSquared( potentialTarget.origin , self.origin ) > DOG_TURRET_MAX_TARGETING_RANGE*DOG_TURRET_MAX_TARGETING_RANGE )
		return false;

	if ( level._teamBased && potentialTarget.pers["team"] == self.team )
		return false;

	if ( potentialTarget.pers["team"] == "spectator" )
		return false;

	if ( isdefined( potentialTarget.spawntime ) && ( gettime() - potentialTarget.spawntime )/1000 <= DOG_TURRET_SPAWN_GRACE_TIME )
		return false;
		
	// check to see if they are in our yaw range
	vecToTarget = potentialTarget.origin - self.origin;
	targetYaw = AngleClamp( VectorToYaw( vecToTarget ) );
	turretYaw = AngleClamp( self.angles[1] );
	degrees = abs( targetYaw - self.angles[1] );
	degrees = AngleClamp( degrees );
	if( degrees > DOG_TURRET_MAX_YAW && ( 360 - degrees ) > DOG_TURRET_MAX_YAW )
	{
//		println( "bad degrees " + degrees + " angles " + turretYaw + " target yaw " + targetYaw );
		return false;
	}
//	println( "good degrees " + degrees + " angles " + turretYaw + " target yaw " + targetYaw );


	if ( isDefined( self ) )
	{
		minTurretEye = self.turret.origin + ( 0, 0, 64 );
		minTurretCanSeeTarget = potentialTarget sightConeTrace( minTurretEye, self );

		if ( minTurretCanSeeTarget < 1 )
			return false;       
	}

	return true;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

getBestTarget( targets )
{
    self endon( "death" );
    origin = self.origin;
    
    closest = undefined;
    bestTarget = undefined;
    
    foreach ( targ in targets )
    {                              
		curDist = Distance( self.origin, targ.origin );
	    	    
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
//																	*
//																	*
//*******************************************************************

acquireTarget( targets )
{
    self endon( "death" );
    
    if ( targets.size == 1 )
    {
		self.bestTarget = targets[0];
	}
	else
	{
        self.bestTarget = self getBestTarget( targets );
	}
    
    self notify( "acquiringTarget" );
    self.turret SetTargetEntity( self.bestTarget, ( 0,0,42 ) );  // sets turret to target entity
    wait( .15 );
    self thread fireOnTarget(); // fires on current target.
    self thread watchTargetDeath( targets ); //abandons target when target killed         
    self thread watchTargetDistance( targets );
    self thread watchTargetAngle( targets );
    self thread watchTargetThreat( self.bestTarget );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

fireOnTarget()
{
    self endon( "death" );
    self endon( "abandonedTarget" );
    self endon( "killedTarget" );
    noTargTime = undefined;
    acquiredTime = getTime();
    
    if ( !isDefined( self.bestTarget ) )
    {
        println("No Targ to fire on");
        return;
    }
    
    println("firing on best target");
    
    while( 1 )
    {
        if ( !isDefined ( self.turret getTurretTarget( true ) ) )
        {
            if ( !isDefined( noTargTime ) )
				noTargTime = getTime();
                        
            curTime = getTime();
                        
            if ( noTargTime - curTime > 1 )
            {              
                noTargTime = undefined;
                self thread explicitAbandonTarget();
                return;
            }
                        
            println("Waiting because the turret doesnt have a target" );
            
            wait ( .5 );
            continue;
        }
    
                    
        numShots = randomIntRange( DOG_TURRET_MIN_SHOTS, DOG_TURRET_MAX_SHOTS );
        for ( i = 0; i < numShots; i++ )
        {
            println( "actually shooting turret" );
            self.turret ShootTurret();
            wait ( DOG_TURRET_FIRE_DELAY );
        }
        wait ( randomFloatRange( DOG_TURRET_MIN_BARRAGE_DELAY, DOG_TURRET_MAX_BARRAGE_DELAY ) );
    }
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

watchTargetDeath( targets )
{
    self endon( "abandonedTarget" );
    self endon( "death" );
    if ( !isDefined( self.bestTarget ) )
		return;
    
    self.bestTarget waittill( "death" );
    
    self notify( "killedTarget" );
    println( "Killed Target" );
    
    self.bestTarget = undefined;
    self.turret ClearTargetEntity();
    self remoteDogFindTargets();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

watchTargetAngle( targets )
{
    self endon( "abandonedTarget" );
    self endon( "death" );
    
    for ( ;; )
    {
        if ( !isDefined( self.bestTarget ) )
            return;

        // check to see if they are in our yaw range
		vecToTarget = self.bestTarget.origin - self.origin;
		targetYaw = AngleClamp( VectorToYaw( vecToTarget ) );
		turretYaw = AngleClamp( self.angles[1] );
		degrees = abs( targetYaw - self.angles[1] );
		degrees = AngleClamp( degrees );
		if( degrees > DOG_TURRET_MAX_YAW && ( 360 - degrees ) > DOG_TURRET_MAX_YAW )
		{
			println( "Abandon! degrees " + degrees + " angles " + self.angles[1] + " target yaw " + targetYaw );
			self thread explicitAbandonTarget();
			return;
		}
        wait ( 0.5 );
    }              
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

watchTargetDistance( targets )
{
    self endon( "abandonedTarget" );
    self endon( "death" );
    
    for ( ;; )
    {
        if ( !isDefined( self.bestTarget ) )
            return;

        trace = BulletTrace( self.turret.origin, self.bestTarget.origin, false, self );
        traceDistance = Distance(self.origin, trace["position"] );
        
        if ( traceDistance > DOG_TURRET_MAX_TARGETING_RANGE )
        {
            println( "TARGET DIST TOO FAR!!!" );
            self thread explicitAbandonTarget();
            return;  
        }
        println( traceDistance );
        wait ( 2 );
    }              
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

watchTargetThreat( curTarget )
{
    self endon( "abandonedTarget" );
    self endon( "death" );
    self endon( "killedTarget" );
    
    for ( ;; )
    {
        targets = [];
        players = level._players;
        
        for (i = 0; i <= players.size; i++)
        {
            if ( isDogTarget( players[i] ) )
            {
                if( !isdefined( players[i] ) )
                    continue;
                
                if( !isdefined(curTarget) )
                    return;
                
                traceOldTarg = Distance(self.origin, CurTarget.origin );
                traceNewTarg = Distance(self.origin, players[i].origin );
                
                if ( traceNewTarg < traceOldTarg )
                {
                    self thread explicitAbandonTarget();
                    return;  
                }
            }
            
            wait( .05 );
        }
        
        wait( .25 );                           
    }              
}

explicitAbandonTarget( noNewTarget )
{
    self notify( "abandonedTarget" );
    
    println( "ABANDONED TARGET" );
    
    self.bestTarget = undefined;
    self.turret ClearTargetEntity();
    
    if ( isDefined(noNewTarget) && noNewTarget )
		return;
    
    self thread remoteDogFindTargets();
    return;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

remoteDogLoop( vehicle )
{
	self endon( "death" );
	vehicle endon( "cleanup_remote_dog" );
	
	self NotifyOnPlayerCommand( "exit_remote_dog", "+usereload" ); // BUTTON_X
	
	vehicle._oldOrigin = vehicle.origin;
	vehicle.fireCycle = 0;

	while ( isalive( self ) )
	{
		if( vehicle.fireCycle > 0 )
		{
			vehicle.fireCycle = vehicle.fireCycle - 1;
		}
	
		// steal the player's angles to control turning the dog, for now...
		angles = vehicle.angles;
		player_angles = self GetPlayerAngles();
		angles = ( player_angles[0], angles[1], angles[2] );
		target = vehicle.origin + vector_multiply( AnglesToForward( angles ), 2000.0 );
		
		// don't do this anymore, the turret is auto targetting now
		// vehicle SetTurretTargetVec( target );
		
		vehicle.remoteDogModel.angels = vehicle.angles;

		// no more attack buttons to shoot
		/*		
		if( self AttackButtonPressed() )
		{
			if( vehicle.ammo > 0 && vehicle.fireCycle == 0)
			{
				vehicle fireweapon();
				vehicle.fireCycle = vehicle.fireRate;
				vehicle.ammo = vehicle.ammo - 1;
				// out of ammo! lets get out of this thing!
				if( vehicle.ammo == 0 )
				{
					self thread remotedogOutOfAmmoThead( vehicle );
				}
			}
		}
		*/

		if( distance( vehicle._oldOrigin, vehicle.origin ) > 0 )
		{
			if( vehicle.currAnim != level._remoteDogMoveAnim )
			{
				vehicle.remoteDogModel ScriptModelPlayAnim( level._remoteDogMoveAnim );
				vehicle.currAnim = level._remoteDogMoveAnim;
			}
		} 
		else
		{
			if( vehicle.currAnim != level._remoteDogIdleAnim )
			{
				vehicle.remoteDogModel ScriptModelPlayAnim( level._remoteDogIdleAnim );
				vehicle.currAnim = level._remoteDogIdleAnim;
			}
		}
				
		vehicle._oldOrigin = vehicle.origin;	
		wait 0.1;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

remotedogOutOfAmmoThead( vehicle )
{
	remoteDogDebugPrint( "remotedogOutOfAmmoThead() out of ammo!" );
	vehicle endon( "cleanup_remote_dog" );
	wait 2;
	vehicle notify( "remote_dog_out_of_ammo" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

Callback_DogDamage( inflictor, attacker, damage, dFlags, meansOfDeath, weapon, point, dir, hitLoc, timeOffset, modelIndex, partName )
{
	remoteDogDebugPrint( "damage callback" );	
    if ( ( attacker == self || ( isDefined( attacker.pers ) && attacker.pers["team"] == self.team ) ) && attacker != self.owner )
                    return;
    
    remoteDogDebugPrint( "damaged dog! " + damage );
    self Vehicle_FinishDamage( inflictor, attacker, damage, dFlags, meansOfDeath, weapon, point, dir, hitLoc, timeOffset, modelIndex, partName );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

remoteDogExitPlayer()
{
	// cleanup the models
	self.remotedog.remoteDogModel Unlink();
	self.remotedog.remoteDogModel Delete();
	
	// cleanup the actual things
	self.remotedog.turret Delete();
	self.remotedog Delete();

	self ThermalVisionFOFOverlayOff();
	self CameraUnlink();
	self setClientDvar( "cg_fov", self.remote_dog_orig_fov );
	self MiniUAVOff();
//	self ControlsUnlink();
	self visionSetNakedForPlayer( getDvar( "mapname" ), 0 );
	self setVelocity(( 0, 0, 0 ));
   	self setOrigin( self._dogPlayerOrigin );
   	self setPlayerAngles( self._dogPlayerAngles );
    self switchToWeapon( self._pre_killstreak_weapon_name );
    self destroyRemoteDogTimer();
    wait 2.0;
	self EnableOffhandWeapons();
    self.in_dog = false;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

remotedogHud()
{
/*
 	crossHair = newClientHudElem( self );
 	crossHair.x = 0;
 	crossHair.y = 0;
 	crossHair.alignX = "center";
 	crossHair.alignY = "middle";
 	crossHair.horzAlign = "center";
 	crossHair.vertAlign = "middle";
 	crossHair setshader( level._remoteDogCrossHair, 640, 480 );
  	static = NewClientHudElem( self );
  	static.horzAlign = "fullscreen";
  	static.vertAlign = "fullscreen";
  	static SetShader( "ac130_overlay_grain", 640, 480 );
 
 	self waittill( "cleanup_remote_dog" );	// Wait for either way of exiting a uav.
 	crossHair Destroy();
*/
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

hudRemoteDogTimer( duration )
{
	remoteDogDebugPrint( "hudRemoteDogTimer()" );
	self.remoteDogTimer = newClientHudElem( self );
	self.remoteDogTimer.x = DOG_HUD_TIMER_POS_X;
	self.remoteDogTimer.y = DOG_HUD_TIMER_POS_Y;
	self.remoteDogTimer.alignX = "center";
	self.remoteDogTimer.alignY = "bottom";
	self.remoteDogTimer.horzAlign = "center_adjustable";
	self.remoteDogTimer.vertAlign = "bottom_adjustable";
	self.remoteDogTimer.fontScale = 2.5;
	self.remoteDogTimer setTimer( 1.0 );
	self.remoteDogTimer.alpha = 1.0;
		
	self.remoteDogTimer setTimer( duration );
	println( "done setting hud timer" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

RemoteDogWaitForTimeout( duration )
{
	self endon( "cleanup_remote_dog" );
	wait duration;
	remoteDogDebugPrint( "RemoteDogWaitForTimeout() Time's up!" );
	self notify(  "remote_dog_time_is_up" );
	self._time_is_up = 1;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

destroyRemoteDogTimer()
{
	remoteDogDebugPrint( "cleanup timer!" );
	self.remoteDogTimer Destroy();
}

/*
QUAKED script_vehicle_nx_miniuav_player_mp (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

put this in your GSC:
maps\mp\killstreaks\_miniuav::main( "nx_vehicle_miniuav" );

and these lines in your CSV:
include,nx_vehicle_miniuav_player

defaultmdl="nx_vehicle_miniuav"
default:"vehicletype" "nx_miniuav_player"
default:"script_team" "allies"
*/