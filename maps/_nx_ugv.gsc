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

// Player's shot delay. 
CONST_SHOT_DELAY = 250;

// Max spread scale that the reticle will change per frame
CONST_MAX_EXPAND_SPREAD_RATE = 8.0;
CONST_MAX_CONTRACT_SPREAD_RATE = 24.0;


//*******************************************************************
//																	*
//																	*
//*******************************************************************
init_local()
{
	ent_flag_init("primary_turret_override");
	ent_flag_init("secondary_turret_override");
	ent_flag_init("committed_action");
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
assign_ugv_weapon_to_slot()
{
	weapon = "ugv_player_weapon";
	self SetActionSlot( 4, "weapon", weapon );	
 	self giveWeapon( weapon );
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************
enter_ugv_vision( turret, vehicle )
{
//	self DisableWeaponSwitch();
	wait( 0.7 );
	turret laserForceOn();
	turret SetTurretWeapon( "ugv_main_turret_player" );
	turret SetSentryOwner( self );
	self EnableThreatVisualization();
	self UGVVisionOn();
	self laserForceOn();
	self allowFire( false );
	self._in_ugv_vision = "update";
	if( vehicle.vehicletype != "nx_chinese_ugv" )
	{
		level.ugv_vision_overlay.alpha = 1;
	}
//	self EnableWeaponSwitch();
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
toggle_ugv_vision()
{
	self NotifyOnPlayerCommand( "exit_ugv", "+actionslot 4" );
	self NotifyOnPlayerCommand( "exit_ugv", "weapnext" );
	self waittill( "exit_ugv" );
	wait( 0.7 );
	self._in_ugv_vision = "exit";
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
ugv_vision_think( turret, vehicle )
{
	self endon( "death" );
	self childthread toggle_ugv_vision();

	spread = 0.5;
	last_shot = GetTime();

	while ( self._in_ugv_vision == "update" )
	{
		self DisableRemoteTurretLock();
		self DisableRemoteTurretOutOfSight();

		// tagBK<NOTE> Such a hack! Check for random weapon changes. 
		current_weapon = self getcurrentweapon();
		if ( current_weapon != "ugv_player_weapon" && self isMantling() == false )
		{
			break;
		}

		trace = self laser_trace();
		tag_origin = turret GetTagOrigin( "tag_flash" );

		if( isdefined( trace[ "position" ] ) )
		{
			// Check for matching traces. 
			turret_trace = turret turret_trace();
			if( isdefined( turret_trace[ "position" ] ))
			{
				newSpread = 0.0;
				out_of_sight = false;
				sight_trace = bullettrace( tag_origin, trace[ "position" ], true, turret );
				if( isdefined( sight_trace[ "position" ] ) && sight_trace[ "fraction" ] < 1.0 )
				{
					self EnableRemoteTurretOutOfSight();
					out_of_sight = true;
				}

				if( !(turret TurretCanTargetPoint( trace[ "position" ] )) )
				{
					self EnableRemoteTurretOutOfSight();
					out_of_sight = true;
				}

				if ( !out_of_sight )
				{
					tag_angles = turret GetTagAngles( "tag_flash" );	
					forward = anglestoforward( tag_angles );

					normalForward = VectorNormalize( forward );
					normalTarget = VectorNormalize( trace[ "position" ] - tag_origin );

					dotProduct = VectorDot( normalForward, normalTarget );
					if ( dotProduct == 1.0 )
					{
						newSpread = 0.0;
					}
					else
					{
						angle = acos( dotProduct );

						newSpread = angle * 255.0 / 180.0;
					}
				}

				if ( newSpread > spread + CONST_MAX_EXPAND_SPREAD_RATE )
				{
					spread = spread + CONST_MAX_EXPAND_SPREAD_RATE;
				}
				else if ( newSpread < spread - CONST_MAX_CONTRACT_SPREAD_RATE )
				{
					spread = spread - CONST_MAX_CONTRACT_SPREAD_RATE;
				}
				else
				{
					spread = newSpread;
				}

				if ( spread <= 5.0 )
				{
					spread = 0.5;
					if ( !out_of_sight )
					{
						self EnableRemoteTurretLock();
					}
				}

				self SetRemoteTurretReticleSpreadScale( spread );
				
				if ( getdvarint( "cg_setugvdebugdraw" ) == 1 )
				{
					player_origin = self GetOrigin();
					line( player_origin, trace[ "position" ], ( 1, 1, 1 ), false, 1 );
					tag_flash = turret GetTagOrigin( "tag_flash" );
					line( tag_flash, turret_trace[ "position" ], ( 1, 0, 0 ), false, 1 );
				}
			}

			// Have the striker turret follow the laser target. 
			if( isdefined( self ))
			{
				turret SetTurretTargetPosition( trace[ "position" ] );
			}

			// Fire turret. 
			if( self AttackButtonPressed() && self IsFriendlyFire() == false )
			{
				// Block friendlies along both the UGV's line of fire, and the player's line of sight
				self apply_player_ugv_suppression( self GetEye(), trace[ "position" ], tag_origin, trace[ "position" ] );
	
				turret StartBarrelSpin();

				last_shot_delta = ( GetTime() - last_shot );
				if( last_shot_delta > CONST_SHOT_DELAY )
				{
					turret ShootTurret();
					last_shot = GetTime();
				}
			}
			else 
			{
				turret StopBarrelSpin();
			}
		}

		// tagBK<NOTE> Moved this here when refactoring. Needs testing. Believe the owner is Pedram. 
		// Regular updates.
		vehicle ent_flag_waitopen("primary_turret_override");

		wait( 0.001 );
	}
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************
apply_player_ugv_suppression( player_trace_start, player_trace_end, turret_trace_start, turret_trace_end )
{
	// Apply suppression along player's line of sight
	self BlockFriendliesAlongLine( player_trace_start, player_trace_end );

	// Apply suppression along turret' line of fire
	self BlockFriendliesAlongLine( turret_trace_start, turret_trace_end );
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************
update_ugv_vision( turret, vehicle )
{
	self enter_ugv_vision( turret, vehicle );
	self ugv_vision_think( turret, vehicle );
	self exit_ugv_vision( turret, vehicle );
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
exit_ugv_vision( turret, vehicle )
{
	turret SetTurretWeapon( "ugv_main_turret" );
	turret SetSentryOwner( vehicle );
	turret laserForceOff();
	turret ClearTurretTargetPosition();
	turret StopBarrelSpin();
	self UGVVisionOff();
	self DisableThreatVisualization();
	self laserForceOff();
	self allowFire( true );
	if( vehicle.vehicletype != "nx_chinese_ugv" )
	{
		level.ugv_vision_overlay.alpha = 0;
	}
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
barrel_smoke()
{
	for ( ;; )
	{
		ellapsed = GetTime() - self.last_shot_fired_time;
		if ( ellapsed > 500 )
		{
			if( self.shots_fired >= 5 ) 
			{
				//playfxontag( getfx( "nx_ugv_barrel_smoke" ), self, "tag_flash" );
			}
			self.shots_fired = 0;
		}
		wait( 0.001 );
	}
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
shoot_anim()
{
	// Barrel smoke childthread. 
	self.shots_fired = 0;
	self.last_shot_fired_time = 0;
	self childthread barrel_smoke();

	// Anim update. 
	self UseAnimTree( #animtree );
	for ( ;; )
	{
		self waittill( "turretshoot" );
		self SetAnimRestart( %nx_vh_ugv_main_turret_fire, 1, 0, 1 );
		self.last_shot_fired_time = GetTime();
		self.shots_fired += 1;
		wait( 0.001 );
	}
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
main_turret_update( player )
{
	self endon( "death" );

	// Locals. 
	if ( !isdefined( self.main_turret ))
	{
		self.main_turret = self.mgturret[0];
	}
	turret = self.main_turret;
	turret childthread shoot_anim();

	// Setup. 
	player VisionSetUGVForPlayer( "nx_ugv_hud" );
	player DisableThreatVisualization();
	player._in_ugv_vision = "inactive";

	// Think.
	for ( ;; )
	{
		// Update laser sight firing. 
		current_weapon = player getcurrentweapon();
		if ( current_weapon == "ugv_player_weapon" )
		{
			if ( player._in_ugv_vision == "inactive" )
			{
				player update_ugv_vision( turret, self );
			}
		}
		else 
		{
			player._in_ugv_vision = "inactive";
		}

		wait( 0.01 );
	}
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
turret_trace()
{
	tag_origin = self GetTagOrigin( "tag_flash" );
	tag_angles = self GetTagAngles( "tag_flash" );
	forward = anglestoforward( tag_angles );
	end = tag_origin + vector_multiply( forward, 7000 );
	trace = bullettrace( tag_origin, end, true, self );
	return trace;
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
laser_trace()
{
	eye = self geteye();
	angles = self getplayerangles();
	forward = anglestoforward( angles );
	end = eye + vector_multiply( forward, 7000 );
	trace = bullettrace( eye, end, true, self );
	return trace;
}


//*******************************************************************
//	ACTIONS															*
//																	*
//*******************************************************************

add_action(actionName, actionFunc)
{
	if(!IsDefined(self.actions))
		self.actions = [];

	self.actions[actionName] = actionFunc;
}

handle_actions()
{
	foreach(notifier, action in self.actions)
	{
		self thread handle_action(notifier, action);
	}

	self thread handle_random();
}

handle_action(notifier, action)
{
	while(1)
	{
		self waittill(notifier);
		self process_action(action);
	}
}

handle_random()
{
	while(1)
	{
		self waittill( "action_random" );
		action = random(self.actions);	
		self process_action(action);
	}
}

process_action(action)
{
	self notify( "new_action" );
	self [[ action ]]();
}



//*******************************************************************
//	SCANNING														*
//																	*
//*******************************************************************
scan_start(turretIndex)
{
	if(turretIndex == 0)
	{
		turret = self.main_turret;
		turretOverride = "primary_turret_override";
	}
	else
	{
		turret = self.trophy_turret;
		turretOverride = "secondary_turret_override";
	}

	dummyTarget = spawn("script_origin", (cos(turret.angles[1])*100, sin(turret.angles[1])*100, 24));

	self thread scan_onStop(turret, dummyTarget, turretOverride);

	self endon( "death" );
	self endon( "stop_scan" );

	self ent_flag_set(turretOverride);

	turret ClearTurretTargetPosition();
	turret ClearTargetEntity();
	turret TurretFireDisable();

	theta = 0;
	rotSpeed = 40;//degrees/sec

	scanStartTime = getTime();
	while(1)
	{	
		theta = RandomFloatRange(-360, 360);
		newTargetPos = (cos(theta)*100, sin(theta)*100, RandomFloatRange(24, 50));
		dummyTarget MoveTo(newTargetPos, abs(theta)/rotSpeed);
		turret thread turret_follow_target(dummyTarget);
		dummyTarget waittill( "movedone" );
		wait 0.01;
	}
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************
scan_stop()
{
	self notify( "stop_scan" );
}

scan_onStop(turret, dummyTarget, turretOverride)
{
	self waittill( "stop_scan" );

	self ent_flag_clear(turretOverride);

	// Reset the turret's properties
	turret LaserForceOff();
	turret ClearTurretTargetPosition();
	turret ClearTargetEntity();
	turret TurretFireEnable();
	dummyTarget Delete();
}


waittill_stopped()
{
	while(self.veh_speed > 0)
	{
		wait 0.05;
	}
}


turret_follow_target(target)
{
	vehicle = self.ownervehicle;
	vehicle endon( "death" );
	vehicle endon( "stop_scan" );
	target endon( "movedone" );

	while(1)
	{
		if( level._player getcurrentweapon() == "ugv_player_weapon" )
		{		
			level._player LaserForceOn();
			if( level._player AttackButtonPressed() )
			{
				vehicle notify("stop_scan");
			}
		}
		else
			level._player LaserForceOff();

		self LaserForceOn();
		self SetTurretTargetPosition(self.origin + target.origin);
		wait(0.01);
	}		
}

attack_array(enemies, onFinish)
{
	self endon("death");
	self endon("stop_attack_array");

	turret = self.main_turret;

	foreach(enemy in enemies)
	{
		while(IsAlive(enemy))
		{
			turret SetTargetEntity(enemy);
			wait 0.05;
		}
		turret ClearTargetEntity();
	}

	turret ClearTargetEntity();

	self notify(onFinish);
}

attack_array_within_range(enemies, minRange, maxRange, onFinish)
{
	self endon("death");
	self endon("stop_attack_array");
	
	excluders = [];
	enemies = get_array_of_closest(self.origin, enemies, excluders, enemies.size, maxRange, minRange);

	attack_array(enemies, onFinish);	
}
