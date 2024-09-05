#include maps\_vehicle;
#include maps\_utility;
#include maps\_hud_util;
#include maps\_vehicle_aianim;
#include common_scripts\utility;
#using_animtree( "vehicles" );



//*******************************************************************
//																	*
//																	*
//*******************************************************************
// Min distance to track projectile. 
// tagBK<NOTE> Should be in GDT?
CONST_TROPHY_MAX_DISTANCE = 700;
CONST_MAX_TRACK_TIME_MS = 500;



//*******************************************************************
//																	*
//																	*
//*******************************************************************
init( turret_template )
{
	self.ownerVehicle.trophy_turret = self;
	self.trophy_sound = turret_template.trophy_sound;

	if( turret_template.trophy_owner == "vehicle" )
	{
	 	self SetSentryOwner( turret_template.ownerVehicle );
	}
	else 
	{
	 	self SetSentryOwner( level._player );
	}

 	self setmode( "trophy" );
 	self.ownerVehicle thread trophy_turret_update();

	if( IsDefined( turret_template.trophy_effect ))
	{
		self.trophy_effect = turret_template.trophy_effect;
	}
	else 
	{
		self.trophy_effect = undefined;
	}
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
find_closest_projectile( pos, current_projectile )
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
		disallow_trophy_destroy_allies = ( GetDvar( "g_allowTrophyToDestroyAllies" ) == "0" );

		foreach ( ent in projectiles )
		{
			if ( IsDefined( self.script_team ) )
			{
				// Check team if we need to prevent the trophy from damaging allies.
				if ( disallow_trophy_destroy_allies )
				{
					team = ent MissileGetTeam();
					if ( team == self.script_team )
					{
						continue;
					}
					else if ( "invalid" == team )
					{
						// projectiles from vehicles fall under "invalid", so we'll check the team of their owner
						team = ent VehicleMissleGetTeam();
						if ( team == self.script_team )
						{
							continue;
						}
					}
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
	turret = self.trophy_turret;
    soundorg = Spawn( "script_origin", turret.origin );
    soundorg LinkTo( turret );

	projectile = undefined;

	tracked_time = 0;

	// Think. 
	for( ;; )
	{
		if ( IsDefined( self.cheap_turrets ) && self.cheap_turrets == true )
		{
	 		turret laserForceOff();
			return;
		}

		if ( IsDefined( turret.trophy_effect ))
		{
			heat_up_effect = getfx( turret.trophy_effect );
		}
		else 
		{
			heat_up_effect = undefined;
		}

		// Get target. 
		prev = projectile;
		projectile = find_closest_projectile( self.origin, projectile );

		// Timer update. 
		if ( isdefined( projectile ))
		{
			// Check for change. 
			had_change = false;
			if ( isdefined( prev ))
			{
				if ( prev != projectile )
				{
					had_change = true;
				}
			}
			else 
			{
				had_change = true;
			}

			// Apply. 
			if ( had_change )
			{
				tracked_time = GetTime();
			}
			else 
			{
				ellapsed_time = GetTime() - tracked_time;
				if( ellapsed_time > CONST_MAX_TRACK_TIME_MS )
				{
					projectile MissileForceTrophyExplode( self );
					projectile = undefined;
				}
			}
		}

		// Make sure within our min distance. 
		if( isdefined( projectile ))
		{
			distance_squared = DistanceSquared( projectile.origin, self.origin );
			if ( distance_squared > ( CONST_TROPHY_MAX_DISTANCE * CONST_TROPHY_MAX_DISTANCE ))
			{
				if( isdefined( projectile.has_effect_on_tag ))
				{
					if ( IsDefined( heat_up_effect ))
					{
						stopfxontag( heat_up_effect, projectile, projectile.has_effect_on_tag );
					}
					projectile.has_effect_on_tag = undefined;
				}
				projectile = undefined;
			}
		}

		// Lock on. C++ logic will shoot it down. 
		if( isdefined( projectile ))
		{
			if( !isdefined( projectile.has_effect_on_tag ))
			{
				tag = "undefined";
				if( projectile DoesTagExistOnEntity( "tag_origin" ) == 1 )
				{
					tag = "tag_origin";
				}
				else if( projectile DoesTagExistOnEntity( "tag_weapon" ) == 1 )
				{
					tag = "tag_weapon";
				}
				else 
				{
					tag = "origin";
				}

				if( tag != "undefined" )
				{
					projectile.has_effect_on_tag = tag;

					if ( IsDefined( heat_up_effect ))
					{
						playfxontag( heat_up_effect, projectile, projectile.has_effect_on_tag );
					}

					if( IsDefined( turret.trophy_sound ))
					{
						soundorg PlaySound( turret.trophy_sound );
					}
				}
			}

			turret SetTargetEntity( projectile );
	 		turret laserForceOn( projectile );
		}
		else 
		{
			// Clear target. 
	 		turret laserForceOff();
			turret ClearTargetEntity();
		}
		
		self ent_flag_waitopen( "secondary_turret_override" );
		wait( 0.05 );
	}
}



