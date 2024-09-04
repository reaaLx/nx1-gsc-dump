#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

//*******************************************************************
//																	*
//																	*
//*******************************************************************
// Min distance to start to track projectile. 
CONST_TROPHY_MAX_TRACK_DISTANCE = 500;
CONST_MAX_TRACK_TIME_MS = 500;
TROPHY_SOUND_AFTER_COOLDOWN = "weap_recharge_stop";
TROPHY_RELOAD_TIME_SEC = 3.0;
TROPHY_ACTIVE_RADIUS = 400.0;
TROPHY_INACTIVE_RADIUS = 200.0;
TROPHY_TABLE_FILE = "mp/trophyTable.csv";

//*******************************************************************
//																	*
//																	*
//*******************************************************************
find_closest_projectile( pos, current_projectile, friendlyTeam )
{
	projectiles = GetEntArray( "grenade", "classname" );

	// Is there a better way to do this?
	rockets = GetEntArray( "rocket", "classname" );
	foreach ( ent in rockets )
	{
		projectiles[ projectiles.size ] = ent;
	}

	min_distance = 999999999999999.0;
	return_obj = undefined;

	// First check for the current projectile. 
	if ( isdefined( current_projectile ))
	{
		foreach ( ent in projectiles )
		{
			if ( current_projectile == ent )
			{
				return_obj = ent;
				break;
			}
		}
	}

	// No dice, find a new one by range. 
	if ( !isdefined( return_obj ))
	{

		foreach ( ent in projectiles )
		{			
			team = ent MissileGetTeam();
			if ( "invalid" == team )
			{
				// projectiles from vehicles fall under "invalid", so we'll check the team of their owner
				team = ent VehicleMissleGetTeam();
			}

			// team check
			if( isDefined( friendlyTeam ))
			{
				if( team == friendlyTeam )
				{
					continue;
				}
			}

			if( isDefined( ent.type ))
			{	
				if( ent.type == "remote" )
				{
					// remote missile, those are ok
					continue;
				}
			}
					
			// Distance.
			d = DistanceSquared( ent.origin, pos );
			if ( d < min_distance )
			{
				min_distance = d;
				return_obj = ent;
			}
		}
	}

	return return_obj;
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
trophy_turret_update()
{
	// Exit cases. 
	self endon( "death" );

	// Locals.
	soundEnt = self;
	turret = self.trophy_turret;
	if( isDefined( turret ))
	{ 
		soundEnt = turret;
	}
	
	soundorg = Spawn( "script_origin", soundEnt.origin );
	soundorg LinkTo( soundEnt );

	projectile = undefined;

	tracked_time = 0;
	self.trophyLastFireTime = 0;

	// Think. 
	for( ;; )
	{
		wait( 0.05 );
		//println( "update" );
		friendlyTeam = undefined;
		// this is a escort plus check
		if( isDefined( self.curr_owner ))
		{
			// if the current owner is neutral, trophy system is off
			if( self.curr_owner == "neutral" )
			{
				continue;
			}

			if( isDefined( game[self.curr_owner] ))
			{
				friendlyTeam = game[self.curr_owner];
			}
		}
		else
		{
			friendlyTeam = self.owner.team;
		}

		//println( "friendly team is ", friendlyTeam );

		// Get target. 
		prev = projectile;
		projectile = find_closest_projectile( self.origin, projectile, friendlyTeam );

		if ( isdefined( projectile ))
		{
			//println( "got projectile" );
			distance_squared = DistanceSquared( projectile.origin, self.origin );
			if ( distance_squared < ( CONST_TROPHY_MAX_TRACK_DISTANCE * CONST_TROPHY_MAX_TRACK_DISTANCE ))
			{
				canFire = false;
				if( TROPHY_RELOAD_TIME_SEC * 1000 < getTime() - self.trophyLastFireTime )
				{
					canFire = true;
				}
				inRange = false;
				if( distance_squared < TROPHY_ACTIVE_RADIUS * TROPHY_ACTIVE_RADIUS )
				{
					if( distance_squared > TROPHY_INACTIVE_RADIUS * TROPHY_INACTIVE_RADIUS )
					{
						inRange = true;
					}
				}

				if( canFire && inRange )
				{
					weaponName = projectile getWeaponName();
					if( !canGoThroughTrophy ( weaponName, "ugv" ))
					{
						//projectile MissileTryTrophyExplode( self );
						self notify( "trophy_kill_projectile", TROPHY_RELOAD_TIME_SEC );
						self.trophyLastFireTime = getTime();
						PlayFX ( level._effect[ "trophy_explosion" ], projectile.origin );
						projectile delete();
						projectile = undefined;
						self PlaySound( TROPHY_SOUND_AFTER_COOLDOWN );
					}
				}
			}
			else
			{
//				println( "not close enough... dsqr ", distance_squared, " ", projectile.origin, " ", self.origin );
			}
		}
		else
		{
			if( isDefined( turret ))
			{
				turret ClearTargetEntity();
			}
		}
	}
}

canGoThroughTrophy ( weaponName, type )
{
	index = undefined;
	switch ( type )
	{
		case "suit":
			index = 2;
			break;
		case "ugv":
			index = 3;
			break;
		default:
			assertMsg( "Invalid trophy type.  Must be either 'suit' or 'ugv'" );
	}

	result = tablelookup( TROPHY_TABLE_FILE, 1, weaponName, index );

	if ( result == "1")
	{
		return true;
	}
	else
	{
		return false;
	}
}