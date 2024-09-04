#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
	
	level._empInitialBlastTime = getDvarInt( "scr_empInitialEffectDuration", "10");
	level._empCloudTickTime = getDvarInt( "scr_empTickEffectDuration", "3");

	level._gasCloudDuration = getDvarInt( "scr_gasCloudDuration", "9");
	level._gasCloudRadius = getDvarInt( "scr_gasCloudRadius", "185");
	level._gasCloudHeight = getDvarInt( "scr_gasCloudHeight", "20");
	level._gasCloudTickDamage = getDvarInt( "scr_gasCloudTickDamage", "13");
	level._gasCloudTickDamageHardcore = getDvarInt( "scr_gasCloudTickDamageHardcore", "5");

	level._empCloudDuration = getDvarInt( "scr_empCloudDuration", "9");
	level._empCloudRadius = getDvarInt( "scr_empCloudRadius", "185");
	level._empCloudHeight = getDvarInt( "scr_empCloudHeight", "20");
	level._empCloudTickDamage = getDvarInt( "scr_empCloudTickDamage", "1");

	level._gasCloudList = [];
	level._empCloudList = [];
}

increaseEmpCloudedTime( amount )
{
	self.empCloudedTime += amount;
}

watchEmpClouded()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	self.empCloudedTime = 0.0;
	empCloudDeltaTime = 0.5;
	
	for(;;)
	{
		self waittill( "emp_cloud_update" );

		self playLocalSound( "emp_activate" );

		if ( self _hasPerk( "specialty_localjammer" ))
			self RadarJamOff();

		self setEMPJammed( true );

		//wait for the decay to finish
		while( self.empCloudedTime > 0 )
		{
			wait( empCloudDeltaTime );
			self.empCloudedTime -= empCloudDeltaTime;
		}

		if( self.empCLoudedTime < 0 )
		{
			self.empCloudedTime = 0;
		}

		//tagZP<NOTE> this should probably make sure that my team is not emp'd so that i do not turn off fx from the killstreak.
		self setEMPJammed( false );
	
		if ( self _hasPerk( "specialty_localjammer" ))
			self RadarJamOn();
	}
}

AddCloudToGasList( cloud )
{	
	list = level._gasCloudList;
	list[ list.size ] = cloud;
	level._gasCloudList = list;
}

RemoveCloudFromGasList( cloud )
{	
	newArray = [];
	for( i = 0; i < level._gasCloudList.size; i++ )
	{
		if( level._gasCloudList[i] != cloud )
		{
			newArray[ newArray.size ] = level._gasCloudList[i];
		}
	}
	level._gasCloudList = newArray;
}

AddCloudToEMPList( cloud )
{	
	list = level._empCloudList;
	list[ list.size ] = cloud;
	level._empCloudList = list;
}

RemoveCloudFromEMPList( cloud )
{
	newArray = [];
	for( i = 0; i < level._empCloudList.size; i++ )
	{
		if( level._empCloudList[i] != cloud )
		{
			newArray[ newArray.size ] = level._empCLoudList[i];
		}
	}
	level._empCloudList = newArray;
}

//used by spawnlogic to determine the safty of this spawn point.
getCloudDanger( spawner )
{
	cloudCount = 0;
	
	triggers = level._gasCloudList;

	foreach( trigger in triggers )
	{
		if( spawner isTouching( trigger ))
		{
			cloudCount++;
		}
	}

	triggers = level._empCloudList;

	foreach( trigger in triggers )
	{
		if( spawner isTouching( trigger ))
		{
			cloudCount++;
		}
	}

	return cloudCount;
}

//returns true if the entity passed in is in any enemy clouds.  Team should be passed in as my team.  anyteam that doesnt match what is passed
//in is considered enemy.  If team is not passed in all clouds are checked.
checkIsInCloud( entity, list, team )
{	
	foreach( cloud in list )
	{
		if( entity isTouching( cloud ))
		{
			if( isDefined( team ))
			{
				assert( isDefined( cloud.owner ));
				assert( isplayer( cloud.owner ));
			
				if( cloud.owner.pers["team"] != team )
				{
					return true;
				}
			}
			else
			{
				return true;
			}
		}
	}

	return false;
}

gasGrenadeExplodeWaiter( type )
{
	self endon( "end_explode" );
	team = self.owner.team;
	
	self waittill( "explode", position );
	
	cloudObj = Spawn( "script_origin", position );
	
	cloudObj.owner = self.owner;
	cloudObj.team = team;
	
	if( type == "gas" )
	{
		cloudObj thread gasCloudMonitor( level._gasCloudDuration );
	}
	else if( type == "emp" )
	{
		cloudObj thread empCloudMonitor( level._empCloudDuration );
	}
}

gasCloudMonitor( duration )
{
	//self endon( "death" );
	position = self.origin;

	gasCloudRadius = level._gasCloudRadius;
	gasCloudHeight = level._gasCloudHeight;
	gasCloudTickDamage = level._gasCloudTickDamage;

	if ( level._hardcoreMode )
	{
		gasCloudTickDamage = level._gasCloudTickDamageHardcore;
	} 

	// spawn trigger radius for the effect areas
	gasEffectArea = spawn( "trigger_radius", position, 0, gasCloudRadius, gasCloudHeight );
	gasEffectArea.owner = self.owner;
	AddCloudToGasList( gasEffectArea );
	
	gasTotalTime = 0.0;		// keeps track of the total time the gas cloud has been "alive"
	gasTickTime = 1.0;		// gas cloud ticks damage every second
	gasInitialWait = 1.5;	// wait this long before the cloud starts ticking for damage
	gasTickCounter = 0;		// just an internal counter to count gas damage ticks
	
	wait( gasInitialWait );
	gasTotalTime += gasInitialWait;
	
	for( ;; )
	{
		if( gasTotalTime >= duration )
		{
			break;
		}
		
		//send out some radial damage
		//RadiusDamage( self.origin, gasCloudRadius, gasCloudTickDamageMax, gasCloudTickDamageMin, self.owner );
		
		//apply shellshock/damage fx to players in the gas cloud
		foreach( player in level._players )
		{	
			if( level._teamBased )
			{
				if( !isDefined( player.team ))
				{
					continue;
				}
				
				if( !isDefined( self.owner ))
				{
					continue;
				}
				
				if( player.team == self.team && player != self.owner )
				{
					continue;
				}
			}

			if( player istouching( gasEffectArea ) && player.sessionstate == "playing" )
			{
				if( ! ( player _hasPerk( "specialty_gasmask" )))
				{
					trace = bullettrace( position, player.origin, false, player );
					if ( trace["fraction"] == 1 )
					{
						// NOTE: DoDamage( <health>, <source position>, <attacker>, <inflictor>, <hit-on-head>, <mod>, <dflags>, <weapon> )
						//player DoDamgae( gasCloudTickDamageMin, position, self.owner, self, 0, "MOD_GAS", 0, "gas_grenade_mp" );

						player shellShock( "gas_grenade_mp", 2 );		// Long enough...
						RadiusDamage( player.origin, 16, gasCloudTickDamage, gasCloudTickDamage, self.owner); // "MOD_GAS", "gas_grenade_mp" );

						//play coughing noise
						player PlaySoundToPlayer( "breathing_gas_hurt", player );
					}
				}
			}
		}
		
		wait( gasTickTime );
		gasTotalTime += gasTickTime;
		gasTickCounter += 1;
	}

	//clean up
	RemoveCloudFromGasList( gasEffectArea );
	gasEffectArea delete();
	
	self delete();
}

empCloudMonitor( duration )
{
	//self endon( "death" );

	assert( isDefined( self.owner ));

	empEffectArea = spawn( "trigger_radius", self.origin, 0, level._empCloudRadius, level._empCloudHeight );
	empEffectArea.owner = self.owner;
	AddCloudToEMPList( empEffectArea );

	empCloudGrenadeInitialBlast( empEffectArea, self.owner );

	//println( "added emp cloud to list, size = " + level._empCloudList.size );
	
	empTotalTime = 0.0;		// keeps track of the total time the emp cloud has been "alive"
	empTickTime = 1.0;		// emp cloud ticks damage every second
	empInitialWait = 1.5;	// wait this long before the cloud starts ticking for damage
	empTickCounter = 0;		// just an internal counter to count gas damage ticks
	
	wait( empInitialWait );
	empTotalTime += empInitialWait;
	
	for( ;; )
	{
		if( empTotalTime >= duration )
		{
			break;
		}
		
		//apply emp fx to players in the emp cloud
		foreach( player in level._players )
		{	
			if( level._teamBased )
			{
				if( !isDefined( player.team ))
				{
					continue;
				}
				
				if( !isDefined( self.owner ))
				{
					continue;
				}
				
				if( player.team == self.team && player != self.owner )
				{
					continue;
				}
			}
			
			if( player istouching( empEffectArea ) && player.sessionstate == "playing" )
			{	
				//player thread maps\mp\killstreaks\_emp::EMPGrenade_JamPlayer( level._empCloudTickTime );
				player increaseEmpCloudedTime( level._empCloudTickTime );

				player notify( "emp_cloud_update" );

				if( level._empCloudTickDamage > 0 )
				{
					RadiusDamage( player.origin, 16, level._empCloudTickDamage, level._empCloudTickDamage, self.owner);
				}
			}
		}
		
		wait( empTickTime );
		empTotalTime += empTickTime;
		empTickCounter += 1;
	}
	
	//clean up
	RemoveCloudFromEMPList( empEffectArea );

	//println( "removed emp cloud from list, size = " + level._empCloudList.size );

	empEffectArea delete();

	self delete();
}

//Apply initial damage to world ents on explosion
empCloudGrenadeInitialBlast( trigger, attacker )
{
	assert( isDefined( trigger ));
	assert( isDefined( attacker ));

	//hit players with the initial blast
	foreach( player in level._players )
	{	
		if( level._teamBased )
		{
			if( !isDefined( player.pers["team"] ))
			{
				continue;
			}
				
			if( !isDefined( attacker ))
			{
				continue;
			}
				
			if( player.pers["team"] == attacker.pers["team"] && player != attacker )
			{
				continue;
			}
		}
			
		if( player istouching( trigger ) && player.sessionstate == "playing" )
		{
			//player thread maps\mp\killstreaks\_emp::EMPGrenade_JamPlayer( level._empInitialBlastTime );
			player increaseEmpCloudedTime( level._empInitialBlastTime );
			player notify( "emp_cloud_update" );
		}
	}

	//take out enemy c4 in the initial blast
	destroyEnemyC4( attacker, trigger );
	
	//take down any helis it hits
	foreach ( heli in level._helis )
	{
		if( heli isTouching( trigger ))
		{
			radiusDamage( heli.origin, 384, 5000, 5000, attacker );
		}
	}

	//take down any little birds 
	foreach ( littleBird in level._littleBird )
	{
		if( littleBird isTouching( trigger ))
		{
			radiusDamage( littleBird.origin, 384, 5000, 5000, attacker );
		}
	}

	/*
	foreach ( turret in level._turrets )
		radiusDamage( turret.origin, 16, 5000, 5000, attacker );
	
	foreach ( rocket in level._rockets )
		rocket notify ( "death" );
	*/
	
	//take down any uavs it hits	
	if ( level._teamBased )
	{
		foreach ( uav in level._uavModels["allies"] )
		{
			if( uav isTouching( trigger ))
			{
				radiusDamage( uav.origin, 384, 5000, 5000, attacker );
			}
		}
		
		foreach ( uav in level._uavModels["axis"] )
		{
			if( uav isTouching( trigger ))
			{
				radiusDamage( uav.origin, 384, 5000, 5000, attacker );
			}
		}	
	}
	else
	{	
		foreach ( uav in level._uavModels )
		{
			if( uav isTouching( trigger ))
			{
				radiusDamage( uav.origin, 384, 5000, 5000, attacker );
			}
		}
	}
	
	//take down any ac130's it hits
	if ( isDefined( level._ac130player ) )
	{
		if( level._ac130player isTouching( trigger ))
		{
			radiusDamage( level._ac130.planeModel.origin+(0,0,10), 1000, 5000, 5000, attacker );
		}
	}
}

destroyEnemyC4( attacker, trigger )
{
	foreach ( player in level._players )
	{
		if ( player.pers["team"] != attacker.pers["team"] || ! level._teambased )
		{
			if( isDefined( player.c4array ))
			{
				if ( player.c4Array.size > 0 )
				{
					for( i = 0; i < player.c4Array.size; i++ )
					{
						if( player.c4Array[i] isTouching( trigger ))
						{
							player notify( "alt_detonate" );
						}
					}
				}
			}
		}		
	}
}