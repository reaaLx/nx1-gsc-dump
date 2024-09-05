//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Mission Utils												**
//                                                                          **
//    Created: 8/9/11 - Justin Rote											**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;

// Use more
// AssertEx( IsDefined( object ), "Assert message" );

RAILGUN_COOLDOWN_DURATION = 8;	// How long the player must wait between shots
RAILGUN_FIRE_DELAY = 0.25;  		// The delay between designating a target, and firing the railgun ( to simulate distance )
RAILGUN_LOCK_LENGTH = 1800;		// How much time on target is required to get a lock

RAILGUN_RETICULE_CLEANUP_DELAY = 4;	// Amount of time after firing, before the reticule gets deleted

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


// Main railgun usage script
RailgunUsage( player )
{
	level endon( "railgun_complete" );

	// Setup basic railgun params
	InitRailgunUsage( player );

	for ( ;; )
	{
		wait 0.01;

		// Watches for railgun toggle on/off
		player waittill_railgun_toggle_or_fire();
		flag_set( "player_activated_railgun" );


		// Turned railgun OFF
		if ( player.laserForceOn )
		{
			//iprintln( "Railgun Off" );
			level._player playsound("nx_rocket_hud_off");

			// Player fired or switched it off.
			player laserForceOff();
			player.laserForceOn = false;

			level notify( "railgun_off" );

			// turn off visor fluff
			level._player thread railgun_visor_off();

			wait 1;

			// Give back turret fire control
			//player allowFire( true );
			level.player_turret maps\_minigun::enable_turret_fire();

			// Railgun can only be fired so often
			if ( IsDefined( level.railgun_cooldown_start ) )
			{
				time_since_fire = ( GetTime() - level.railgun_cooldown_start ) / 1000;
				if ( time_since_fire < RAILGUN_COOLDOWN_DURATION )
				{
					//level.railTimer settenthstimer( RAILGUN_COOLDOWN_DURATION - time_since_fire );

					wait RAILGUN_COOLDOWN_DURATION - time_since_fire;

					//iprintlnbold( "Railgun Ready" );
					level._player playsound("rail_gun_ready");
				}
			}
		}
		// Turned railgun ON
		else
		{			
			// Is the railgun globally allowed?
			if( level.railgun_allowed == 0 )
			{
				wait 1;
				continue;
			}
			else
			{

				level._player playsound("nx_rocket_hud_on");

			}

			player.laserForceOn = true;


			player laserForceOn();
			//player allowFire( false );
			level.player_turret maps\_minigun::disable_turret_fire();

			// turn on visor fluff
			level._player thread railgun_visor_on();

			// Show the 3d reticule
			//player thread show_3d_reticle();

			// Main railgun locking logic script
			player thread RailgunLockStages();
		}
	}
}


// Resets railgun settings
InitRailgunUsage( player )
{
	player.laserForceOn = false;
	player.railgunLockStartTime = undefined;
	player.current_area = undefined;
	player.visor_animating = false;

	// Set the dpad ICON
	player setWeaponHudIconOverride( "actionslot4", "dpad_laser_designator" );

	// Set up the dpad weapon switch hooks
	player notifyOnPlayerCommand( "use_laser", "+actionslot 4" );
	player notifyOnPlayerCommand( "fired_laser", "+attack" );

	level._player VisionSetUGVForPlayer( "nx_ugv_hud" );
}


// Resets locking params
ResetRailgunLocking()
{
	//iprintln( "Reset lock" );
	self WeaponLockFree();
	self WeaponLockTargetTooClose( false );
	self WeaponLockNoClearance( false );
	self.currentlyLocking = false;
	self.currentlyLocked = false;
	self.railgunTarget = undefined;
	self.railgunLockStartTime = undefined;
	SetSavedDvar( "cg_railGunLockOnProgress", 0.0 );
	SetSavedDvar( "hud_railgun_state", "rdy" );

	self WeaponLockFree();

	//InitRailgunUsage();
}


// Watches for dpad pressed to turn on/off railgun
waittill_railgun_toggle_or_fire()
{
	if ( level._player.visor_animating )
	{
		// don't let player toggle visor until visor is done animating
		level._player waittill( "visor_anim_done" );
	}

	level endon( "railgun_complete" );
	self endon( "use_laser" );

	while ( true )
	{
		// Wait for the railgun to be used
		//self waittill( "fired_laser" );

		// Wait for a successful lock
		//self waittill( "target_locked" );

		//level waittill( "rocket_destroyed" );
		level waittill( "remove_visor" );

		if ( level._player.laserForceOn )
		{
			return;
		}
	}
}


// Main locking script for the railgun
// Controls the 3 stages of locking on
// SELF = level
RailgunLockStages()
{

	audio_sfx = 0;

	// Stop this script if the railgun turns off for any reason
	level endon( "railgun_complete" );
	level endon( "railgun_off" );

	debugDraw = false;
	debugText = false;

	// Setup the railgun stage if it isnt defined
	if ( !IsDefined( self.railgunStage ) )
	{
		self.railgunStage = 1;
	}

	// Update the list of railgun targets
	targets = GetTargetList();

	// Main loop
	for( ;; )
	{
		wait 0.05;

		//=====================================================================
		// Stage 1 SCANNING: try to find a good object to lock to
		//=====================================================================
		if ( self.railgunStage == 1 )
		{
			// Refresh targets list
			//targets = GetTargetList();
			if ( targets.size != 0 && !IsDefined( level.railgun_locked_on_target ) )
			{
				self ResetRailgunLocking();

				// Find all targets that are within the players reticule
				targetsInReticle = [];
				foreach ( target in targets )
				{
					insideReticle = self WorldPointInReticle_Circle( target.origin, 65, 50 );
					AssertEx( isDefined( insideReticle ), "Error: insideReticle is undefined" );

					// Found a target inside the reticule
					if ( insideReticle )
					{
						targetsInReticle[targetsInReticle.size] = target;
					}
				}
				
				// Look more cloesely at targets directly in the reticule
				if ( targetsInReticle.size != 0 )
				{
					// Sort them by distance
					sortedTargets = SortByDistance( targetsInReticle, self.origin );

					level._player notify( "target_in_reticule", sortedTargets[0] );
				
					// Make sure its in LoS
					if ( !( self RailgunLockSightTest( sortedTargets[0] ) ) )
					{
						continue;
					}
		
					// Wait for trigger pull
					if( !( self attackbuttonpressed()))
					{
						continue;
					}

					// Player pulled the trigger
					flag_set( "player_used_railgun" );

					//if ( debugText )
					//{
					//	iPrintLn( "Found a target" );
					//}

					// Save the target
					self.railgunTarget = sortedTargets[0];
					self WeaponLockStart( sortedTargets[0] );

					// Save the start lock time
					if ( !isDefined( self.railgunLockStartTime ) )
					{
						self.railgunLockStartTime = GetTime();
					}
					
					// Switch to stage 2
					self.railgunStage = 2;
					continue;
				}
			}
		}

		//=====================================================================
		// Stage 2 LOCKING: Hold it while locking on
		//=====================================================================
		if ( self.railgunStage == 2 )
		{
			if ( audio_sfx == 0 )
			{
				audio_sfx = 1;
				level._player playsound("nx_railgun_locking");
			}
			// Make sure they keep holding down fire while locking
			if( !( self attackbuttonpressed()))
			{
				audio_sfx = 0;
				level._player playsound("nx_railgun_fail");
				// Let go of trigger - Reset back to stage 1
				self.railgunStage = 1;
				self ResetRailgunLocking();
				continue;
			}

			// Make sure it is still in the reticule
			target = self.railgunTarget;
			insideReticle = self WorldPointInReticle_Circle( target.origin, 65, 85 );
			if( !insideReticle )
			{
				audio_sfx = 0;
				level._player playsound("nx_railgun_fail");
				// Out of reticule - Reset back to stage 1
				self.railgunStage = 1;
				self ResetRailgunLocking();
				continue;
			}

			// Check line of sight while locking
			if ( !( self RailgunLockSightTest( target )))
			{
				audio_sfx = 0;
				level._player playsound("nx_railgun_fail");
				// Out of LoS - Reset back to stage 1
				self.railgunStage = 1;
				self ResetRailgunLocking();
				continue;
			}

			SetSavedDvar( "hud_railgun_state", "lock" );

			// Keep track of how long the player is locking
			timePassed = getTime() - self.railgunLockStartTime;
			//iPrintLn( "Locking [" + timePassed + "]..." );
			SetSavedDvar( "cg_railGunLockOnProgress", timePassed / RAILGUN_LOCK_LENGTH );
			if ( timePassed < RAILGUN_LOCK_LENGTH )
				continue;

			level.railgun_locked_on_target = target;

			self.railgunStage = 3;
		}

		//=====================================================================
		// Stage 3 LOCKED: Fire the railgun
		//=====================================================================
		if ( self.railgunStage == 3 )
		{
			SetSavedDvar( "hud_railgun_state", "ok" );

			self notify( "target_locked" );

			level notify( "railgun_fired" );

			// Railgun Success Beep
			 level._player playsound("nx_railgun_success");

			// Tell the game the lock is finished
			self WeaponLockFinalize( self.railgunTarget );

			// Shoot the railgun
			self thread delay_fire_railgun( self.railgunTarget );

			// Start the railgun re-use timer
			level.railgun_cooldown_start = GetTime();

			thread railgun_cooldown_anims();

			// Remove the target that was just shot from all targeting lists
			RemoveTargetFromList( self.railgunTarget );

			// Reset back to stage 1
			self.railgunStage = 1;
			SetSavedDvar( "cg_railGunLockOnProgress", 0.0 );

			continue;
		}
	}
}


// Returns a list of potential railgun targets
GetTargetList()
{
	AssertEx( isDefined( level.current_area ), "Tried to GetTargetList when level.current_area is undefined" );
	targets = [];

	// Set potential targets based on current area
	switch( level.current_area )
	{
		case "base_alpha":
			if( isDefined( level.base_alpha_rocket ))
			{
				targets[targets.size] = level.base_alpha_rocket;		
			}
			break;

		case "base_delta_r2":
			if( isDefined( level.base_delta_rocket_2 ))
			{
				targets[targets.size] = level.base_delta_rocket_2;
			}
			break;

		case "base_delta_r3":
			if( isDefined( level.base_delta_rocket_3 ))
			{
				targets[targets.size] = level.base_delta_rocket_3;
			}
			break;

		case "base_delta_r4":
			if( isDefined( level.base_delta_rocket_4 ))
			{
				targets[targets.size] = level.base_delta_rocket_4;
			}
			break;

		default:
			AssertEx( false, "Tried to GetTargetList with unknown level.current_area" );
			return;
	}

	return targets;
}


// Returns a list of aimassist brushmodels for this area
GetAimAssistList()
{
	AssertEx( isDefined( level.current_area ), "Tried to GetTargetList when level.current_area is undefined" );

	aimassist_brushmodels = [];

	// Set potential targets based on current area
	switch( level.current_area )
	{
		case "base_alpha":
			aimassist_brushmodels = GetEntArray( "rocket_alpha_damage_detector", "targetname" );
			break;

		/*
		case "base_delta":
			if( !flag( "rocket_2_destroyed" ))
			{
				aimassist_brushmodel = GetEnt( "damage_detector_r2", "script_noteworthy" );
				aimassist_brushmodels[aimassist_brushmodels.size] = aimassist_brushmodel;
			}

			if( !flag( "rocket_3_destroyed" ))
			{
				aimassist_brushmodel = GetEnt( "damage_detector_r3", "script_noteworthy" );
				aimassist_brushmodels[aimassist_brushmodels.size] = aimassist_brushmodel;
			}

			if( !flag( "rocket_4_destroyed" ))
			{
				aimassist_brushmodel = GetEnt( "damage_detector_r4", "script_noteworthy" );
				aimassist_brushmodels[aimassist_brushmodels.size] = aimassist_brushmodel;
			}
			break;
		*/

		case "base_delta_r2":
			if( !flag( "rocket_2_destroyed" ))
			{
				aimassist_brushmodel = GetEnt( "damage_detector_r2", "script_noteworthy" );
				aimassist_brushmodels[aimassist_brushmodels.size] = aimassist_brushmodel;
			}
			break;

		case "base_delta_r3":
			if( !flag( "rocket_3_destroyed" ))
			{
				aimassist_brushmodel = GetEnt( "damage_detector_r3", "script_noteworthy" );
				aimassist_brushmodels[aimassist_brushmodels.size] = aimassist_brushmodel;
			}
			break;

		case "base_delta_r4":
			if( !flag( "rocket_4_destroyed" ))
			{
				aimassist_brushmodel = GetEnt( "damage_detector_r4", "script_noteworthy" );
				aimassist_brushmodels[aimassist_brushmodels.size] = aimassist_brushmodel;
			}
			break;

		default:
			AssertEx( false, "Tried to GetAimAssistList with unknown level.current_area" );
			return;
	}

	return aimassist_brushmodels;
}



// Remove this target from the targeting list
// JR TODO - This is not a good solution
// Some objects may be shot at but not destroyed
RemoveTargetFromList( target )
{
	AssertEx( isDefined( level.current_area ), "Tried to RemoveTargetFromList when level.current_area is undefined" );
	
	// BASE ALPHA TARGETS
	if( level.current_area == "base_alpha" )
	{
		// Check rocket targets
		if( isDefined( level.base_alpha_rocket ) && level.base_alpha_rocket == target )
		{
			level.base_alpha_rocket = undefined;
		}
	}
	
	else if( level.current_area == "base_delta_r2" )
	{
		if( isDefined( level.base_delta_rocket_2 ) && level.base_delta_rocket_2 == target )
		{
			level.base_delta_rocket_2 = undefined;
		}
	}

	else if( level.current_area == "base_delta_r3" )
	{
		if( isDefined( level.base_delta_rocket_3 ) && level.base_delta_rocket_3 == target )
		{
			level.base_delta_rocket_3 = undefined;
		}
	}

	else if( level.current_area == "base_delta_r4" )
	{
		if( isDefined( level.base_delta_rocket_4 ) && level.base_delta_rocket_4 == target )
		{
			level.base_delta_rocket_4 = undefined;
		}
	}
}


// Allows use of the railgun
enable_railgun()
{
	// Safety check for double enable
	if( isDefined( level.railgun_allowed ) && level.railgun_allowed == true )
	{
		return;
	}

	SetSavedDvar( "railgun_enabled", 1 );
	level.railgun_allowed = true;
	level notify( "enable_railgun" );
	//iprintln( "Railgun online" );

	// Create the HUD
	//setup_railgun_hud();
}


// Denies use of the railgun
disable_railgun()
{
	// Safety check for double disable
	if( isDefined( level.railgun_allowed ) && level.railgun_allowed == false )
	{
		return;
	}

	SetSavedDvar( "railgun_enabled", 0 );
	level notify( "railgun_off" );
	level notify( "disable_railgun" );
	level.railgun_allowed = false;
	//iprintln( "Railgun offline" );

	// Destroy railgun HUD
	//remove_railgun_hud();
}


// Make sure the target is in LoS
RailgunLockSightTest( target )
{
	eyePos = self GetEye();

	center = target GetPointInBounds( 0, 0, 0 );
	passed = BulletTracePassed( eyePos, center, false, target );
	//DebugSightLine( eyePos, center, passed );
	if ( passed )
		return true;

	front = target GetPointInBounds( 1, 0, 0 );
	passed = BulletTracePassed( eyePos, front, false, target );
	//DebugSightLine( eyePos, front, passed );
	if ( passed )
		return true;

	back = target GetPointInBounds( -1, 0, 0 );
	passed = BulletTracePassed( eyePos, back, false, target );
	//DebugSightLine( eyePos, back, passed );
	if ( passed )
		return true;

	// Special check for buildings
	trace = BulletTrace( eyePos, center, false, target );
	hit_ent = trace[ "entity" ];

	// Does the hit entity have script_parameters?
	if( isDefined( hit_ent ) && isDefined( hit_ent.script_parameters ))
	{
		// If the hit entity has "script_parameters", it may be part of
		// a larger targetable building.  Use the script_parameters as
		// a script_noteworthy to grab the target node.
		hit_ent_node = getent( hit_ent.script_parameters, "script_noteworthy" );
		if( isDefined( hit_ent_node ) && hit_ent_node == target )
		{
			// Found an entity with this script_noteworthy
			// This is our target, return true.
			//DebugSightLine( eyePos, center, true );
			return true;
		}
	}

	return false;
}


// Checks if the ent is still in the players reticule
StillValidJavelinLock( ent )
{
	assert( IsDefined( self ) );

	if ( !IsDefined( ent ) )
		return false;
	if ( !(self WorldPointInReticle_Circle( ent.origin, 65, 85 )) )
		return false;

	return true;
}


// Do a raytrace from the player's eye
EyeTraceForward()
{
	origin = self GetEye();
	angles = self GetPlayerAngles();
	forward = AnglesToForward( angles );
	endpoint = origin + forward * 15000;
	
	res = BulletTrace( origin, endpoint, false, undefined );

	if ( res["surfacetype"] == "none" )
		return undefined;
	if ( res["surfacetype"] == "default" )
		return undefined;

	ent = res["entity"];
	if ( IsDefined( ent ) )
	{
		if ( ent == level._ac130.planeModel )
			return undefined;
	}

	results = [];
	results[0] = res["position"];
	results[1] = res["normal"];
	return results;
}


// Wait a bit, then fire the actual weapon
delay_fire_railgun( target_ent )
{
	// This is where the railshot starts from
	missile_origin = get_railgun_node(); //GetEnt( "node_rail_origin", "targetname" );

	missile_origin playsound("rail_gun_fire_dist");

	// TEMP WAY OF GETTING VO TO PLAY DURING/AFTER LOCK-ON. - AEF
	//thread audio_railgun_fire_vo();

	// Delay to simulate distance
	//wait RAILGUN_FIRE_DELAY;

	thread calculate_railgun_target_distance();
	thread calculate_railgun_time_on_target();

	// TEMP WAY OF GETTING VO TO PLAY DURING/AFTER LOCK-ON. - AEF
	// Command: "Payload out.  8 mikes.  5 mikes.  2 mikes.  Impacting."
	switch( level.current_area )
	{
		case "base_alpha":
			// Crossbow: "Mork"
			level radio_dialogue_interupt( "roc_cro_alpha_mark");

			// Crossbow: "2, 1…  Splash."
			level radio_dialogue_interupt( "roc_cro_alpha_21splash");
//  		level radio_dialogue_interupt( "roc_cro_alpha_21splash" );
			level notify( "remove_visor" );
			wait( .75 );
			break;
		case "base_delta_r2":
			// Crossbow: "Playload out"
			level radio_dialogue_interupt( "roc_cro_alpha_payloadout");

			// Crossbow: "2, 1…  Splash."
			level radio_dialogue_interupt( "roc_cro_alpha_21splash" );
			level notify( "remove_visor" );
			//wait( .75 );
			break;
		case "base_delta_r3":
			// Crossbow: "Rall out"
			level radio_dialogue_interupt( "roc_cro_delta_railout");

			// Crossbow: "Fire mission confirmed. Firing for effect.."
			level radio_dialogue_interupt( "roc_cro_alpha_firemissionconfirmed" );
			level notify( "remove_visor" );
			//wait( .75 );
			break;
		case "base_delta_r4":
			// Crossbow: "Mork"
			level radio_dialogue_interupt( "roc_cro_alpha_mark");

			// Crossbow: "TTI 3 seconds."
			level radio_dialogue_interupt( "roc_cro_alpha_tti3sec" );
			level notify( "remove_visor" );
			//wait( .75 );
			wait 2;
			break;
		default:
			AssertEx( false, "Tried to play audio for unknown level.current_area" );
			return;
	}

	// Spawn the railgun shot 
	rail_shot = MagicBullet( "nx_rocket_railgun", missile_origin.origin, target_ent.origin, level._player, 1 );

	// JR - This is a hack to get railshots penetrating the rocket
	// Find a better solution
	level.active_rail_shot = rail_shot;

	thread calculate_railgun_target_distance_final( missile_origin.origin, target_ent.origin );

	// Notify the gun was been shot
	level notify( "railgun_shot" );

	// TEMP WAY OF GETTING VO TO PLAY DURING/AFTER LOCK-ON. - AEF
	wait 2;

	level notify( "rocket_destroyed" );

	// TEMP WAY OF GETTING VO TO PLAY DURING/AFTER LOCK-ON. - AEF
	// Command: "Deadeye 2-1 confirm strike."
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_car_nuke_confirmstrike" , 0.0 );
}

calculate_railgun_target_distance()
{
	level endon( "railgun_shot" );

	rate = 0.05;
	new_dist = 10.0;
	while( true )
	{
		if( new_dist <= 0 )
		{
			SetSavedDvar("hud_railgun_target_distance", 0.0 );//for the UI, just set it 0.
			break;
		}

		//iprintlnbold( "distance is" + new_dist );		
		SetSavedDvar("hud_railgun_target_distance", new_dist );

		wait 0.05;
		new_dist -= rate;
	}
}

calculate_railgun_time_on_target()
{
	level endon( "rocket_destroyed" );

	RATE = 0.05;
	new_time = 0.0;
	while( true )
	{	
		SetSavedDvar("hud_railgun_time_on_target", new_time );

		wait RATE;
		new_time += RATE;
	}
}

calculate_railgun_target_distance_final( missile_origin, target_origin )
{
	RAILGUN_BULLET_SPEED = 60000.0;

	total_time_to_impact = ( distance( missile_origin, target_origin ) / RAILGUN_BULLET_SPEED );
	curr_dist = getdvarfloat( "hud_railgun_target_distance" );

	time_in_flight = 0.0;
	while( true )
	{
		new_dist = ( 1 - ( time_in_flight / total_time_to_impact )) * curr_dist;

		if( new_dist <= 0 )
		{
			SetSavedDvar("hud_railgun_target_distance", 0.0 );//for the UI, just set it 0.
			break;
		}

		//iprintlnbold( "distance is" + new_dist );		
		SetSavedDvar("hud_railgun_target_distance", new_dist );

		wait 0.05;
		time_in_flight += 0.05;
	}
}

// Returns the railgun origin node based on current location
get_railgun_node()
{
	switch( level.current_area )
	{
		case "base_alpha":
			railgun_node = GetEnt( "node_rail_origin_alpha", "targetname" );
			break;

		case "base_delta":
		case "base_delta_r2":
		case "base_delta_r3":
		case "base_delta_r4":
			railgun_node = GetEnt( "node_rail_origin_delta", "targetname" );
			break;

		default:
			AssertEx( false, "Tried to get_railgun_node with unknown level.current_area" );
			return;
	}

	return railgun_node;
}


// 3d RETICULE SCRIPTS
//Display loop for the 3d railgun reticle
show_3d_reticle()
{
	self endon( "use_laser" );
	self endon( "target_locked" );
	self endon( "railgun_off" );

	level.reticule_1 = spawn( "script_model", ( 0,0,0 ) );
	level.reticule_1 setmodel( "nx_reticule_outer_ring" );

	level.reticule_2 = spawn( "script_model", ( 0,0,0 ) );
	level.reticule_2 setmodel( "nx_reticule_middle_ring" );

	level.reticule_3 = spawn( "script_model", ( 0,0,0 ) );
	level.reticule_3 setmodel( "nx_reticule_inner_ring" );

	level.reticule_4 = spawn( "script_model", ( 0,0,0 ) );
	level.reticule_4 setmodel( "nx_reticule_triangle" );

	level.reticule_5 = spawn( "script_model", ( 0,0,0 ) );
	level.reticule_5 setmodel( "nx_reticule_ticks" );

	missile_origin = get_railgun_node(); //GetEnt( "node_rail_origin", "targetname" ).origin;
	missile_origin = ( missile_origin.origin );

	self thread clean_up_reticule();

	while( true )
	{
		direction_vec = AnglesToForward( level._player GetPlayerViewAngles() );
		eye = self getEye();

		trace = bullettrace( eye, eye + ( direction_vec * 20000 ), false, level.playerHeli );

		dist = distance( eye, trace["position"] );
		position = eye + ( direction_vec * ( dist - 12 ) );

		normal_angles = VectorToAngles( trace["normal"] );

		missile_direction = missile_origin - position;
		missile_direction = VectorToAngles( missile_direction );

		// debug
		//thread draw_line_for_time( eye - (1,1,1), position, 1, 0, 0, 0.05 );

		// Safety check the reticule bits still exist
		if( !isDefined( level.reticule_1 ))
		{
			return;
		}

		level.reticule_1.origin = position;
		level.reticule_1.angles = normal_angles;
		
		level.reticule_2.origin = position;
		level.reticule_2.angles = normal_angles;
		
		level.reticule_3.origin = position;
		level.reticule_3.angles = normal_angles;
		
		level.reticule_4.origin = position;
		level.reticule_4.angles = normal_angles;
		
		level.reticule_5.origin = position;
		level.reticule_5.angles = missile_direction;

		wait 0.05;
	}
}

// Deletes the 3d reticule when the railgun is turned off
clean_up_reticule()
{
	level waittill( "railgun_off" );

	level.reticule_1 Delete();
	level.reticule_2 Delete();
	level.reticule_3 Delete();
	level.reticule_4 Delete();
	level.reticule_5 Delete();
}

// Deletes the 3d reticule after a short delay
clean_up_reticule_after_delay()
{
	// grab the current reticles in case the level variables change during our wait
	reticule_1 = level.reticule_1;
	reticule_2 = level.reticule_2;
	reticule_3 = level.reticule_3;
	reticule_4 = level.reticule_4;
	reticule_5 = level.reticule_5;

	wait RAILGUN_RETICULE_CLEANUP_DELAY;

	reticule_1 Delete();
	reticule_2 Delete();
	reticule_3 Delete();
	reticule_4 Delete();
	reticule_5 Delete();
}


// AUDIO
audio_railgun_fire_vo()
{
	wait 0.5;
	radio_dialogue ( "rocket_railgun_fire" );
}

sound_railgun_hit_vo()
{
	wait 2.5;
	radio_dialogue ( "rocket_railgun_direct_hit" );
}


// HUD
// Some quick temp HUD for the railgun
setup_railgun_hud()
{
	level.railTimer = maps\_hud_util::get_countdown_hud();	
	level.railTimer.label = &"NX_ROCKET_RECHARGE";
	level.railTimer settenthstimer( 0.05 );
	level.railTimer.y = 90;
}

remove_railgun_hud()
{
	if( isDefined( level.railTimer ))
	{
		level.railTimer destroy();
	}
}


// DEBUG HELPERS
DebugSightLine( start, end, passed )
{
	/#
	if ( passed )
		color = ( 0.3, 1.0, 0.3 );
	else
		color = ( 1.0, 0.2, 0.2 );

	MY_OFFSET = ( 0, 0, 5 );

	Line( start + MY_OFFSET, end, color );
	#/
}


draw_circle_on_entity_until_notify( entity, radius, r, g, b, notifyEnt, notifyString )
{
	Assert( IsDefined( notifyEnt ) );
	Assert( IsDefined( notifyString ) );

	notifyEnt endon( notifyString );
	
	while( 1 )
	{
		draw_circle_for_time( entity.origin, radius, r, g, b, 0.05 );
	}
}


TargetCleanUp( target )
{
	level waittill_either( "clear_rocket_targets", "railgun_fired" );

	// turn off aim assist for target
	target DisableAimAssist();

	if ( IsDefined( level.railgun_locked_on_target ) )
	{
		aim_assist_target = get_aim_assist_target_from_target_origin();
		if ( target == aim_assist_target )
		{
			// TEMP WAY OF GETTING VO TO PLAY DURING/AFTER LOCK-ON. - AEF
			level thread looping_ping(target);
			level waittill( "rocket_destroyed" );

			level.railgun_locked_on_target = undefined;
		}
	}

	// remove target markers
	target_remove( target );
}

// TEMP WAY OF GETTING VO TO PLAY DURING/AFTER LOCK-ON. - AEF
looping_ping( target )
{
	level endon("rocket_destroyed");

	wait 0.75;
	while (1){
		// tagMJS<TODO> there is an anim for when a target is successfully locked on
		
		// play our anim for the final ping
		target_setcustomownerdraw( target, true );
		// let it play out and then remove the target
		wait 1.0;
		target_setcustomownerdraw( target, false );
	}
}


draw_circle_for_time( center, radius, r, g, b, time )
{
	circle_sides = 16;

	angleFrac = 360 / circle_sides;

	// Z circle
	circlepoints = [];
	for ( i = 0; i < circle_sides; i++ )
	{
		angle = ( angleFrac * i );
		xAdd = Cos( angle ) * radius;
		yAdd = Sin( angle ) * radius;
		x = center[ 0 ] + xAdd;
		y = center[ 1 ] + yAdd;
		z = center[ 2 ];
		circlepoints[ circlepoints.size ] = ( x, y, z );
	}
	draw_circle_lines_for_time( circlepoints, r, g, b, time );
	wait ( time );
}

draw_circle_lines_for_time( circlepoints, r, g, b, time )
{
	for ( i = 0; i < circlepoints.size; i++ )
	{
		start = circlepoints[ i ];
		if ( i + 1 >= circlepoints.size )
			end = circlepoints[ 0 ];
		else
			end = circlepoints[ i + 1 ];

		thread draw_line_for_time( start, end, r, g, b, time );
	}
}


railgun_cooldown_anims()
{
	time_since_fire = ( GetTime() - level.railgun_cooldown_start ) / 1000;
	while( time_since_fire < RAILGUN_COOLDOWN_DURATION )
	{
		time_since_fire = ( GetTime() - level.railgun_cooldown_start ) / 1000;
		SetSavedDvar( "hud_railgun_cooldown_time", ( time_since_fire / RAILGUN_COOLDOWN_DURATION ) );
		wait 0.05;
	}
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************

get_aim_assist_target_from_target_origin()
{
	target = undefined;
	if ( IsDefined( level.railgun_locked_on_target ) )
	{
		for ( index = 1; index < 5; index++ )
		{
			script_origin = GetEnt( "rocketexplode_0" + index, "script_noteworthy" );
			if ( IsDefined( script_origin ) )
			{
				if ( script_origin == level.railgun_locked_on_target )
				{
					target = GetEnt( "damage_detector_r" + index, "script_noteworthy" );
					if ( IsDefined( target ) )
					{
						break;
					}
				}
			}
		}
	}

	return target;
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************

railgun_visor_on()
{
	// pull down our visor
	level._player PutOnHelmet();
	level.playerheli.mgturret[0] thread railgun_visor_fps_anim( "on" );

	level._player thread railgun_hud_switch_ugv_vision( 1 );


	// hide UI that will not be showing up on visor
	// hide vehicle targeting
	targets = Target_GetArray();
	for ( index = 0; index < targets.size; index++ )
	{
		Target_HideFromPlayer( targets[index], level._player );
	}
	// remove regular hud side brackets
	SetSavedDvar( "sideBracketsHide", 1 );
	// Hide turret reticule
	setsaveddvar( "cg_drawTurretCrosshair", false );


	// make sure the first frame of visor anim moves pieces off of screen
	wait( 0.05 );


	// add our UI elements that are going to be on the visor
	// adjust target sizes
	SetSavedDvar( "vehHudTargetSize", 70 );
	// set flag for railgun reticule to be drawn
	setsaveddvar( "cg_drawRailGunCrosshair", true );
	// add targets to our rockets
	railgun_add_rocket_targets();
	// add chute hud
	level._hud_chute_alpha_fade_time_ms = 0;//1000; // ms to fade in
	level._INCHES_PER_METER = 39.3700787;
	level._hud_chute_altimeter_max = ( 100 * level._INCHES_PER_METER ); // 100 m in inches
	maps\_chute::parachute_hud_bootup( 1, 1 );
	// add visor fluff
	SetSavedDvar( "hud_railgun_visor_active", 1 );


	// kick off our logic to figure out trajectory
	level._player thread railgun_hud_trajectory_update();
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************

railgun_visor_off()
{
	level._player TakeOffHelmet();
	level.playerheli.mgturret[0] thread railgun_visor_fps_anim( "off" );

	level._player thread railgun_hud_switch_ugv_vision( 0 );


	wait( 0.65 );
	// add back all the normal turret HUD
	// add regular hud side brackets
	SetSavedDvar( "sideBracketsHide", 0 );
	// add back the turret reticule
	setsaveddvar( "cg_drawTurretCrosshair", true );


	wait( 0.09666 );		// current duration of visor off anim ( 0.76666 )


	// Display the 2d turret reticule
	setsaveddvar( "cg_drawRailGunCrosshair", false );
	// clear rocket targets
	level notify( "clear_rocket_targets" );
	// turn off chute hud
	SetSavedDvar( "hud_chute_altimeter_active", 0 );
	SetSavedDvar( "hud_chute_compass_active", 0 );
	// turn off visor fluff
	SetSavedDvar( "hud_railgun_visor_active", 0 );
	// kill our trajectory update
	level._player notify( "railgun_hud_trajectory_off" );

	wait( 0.05 );

	SetSavedDvar( "vehHudTargetSize", 30 );
	// show our vehicle targets
	targets = Target_GetArray();
	for ( index = 0; index < targets.size; index++ )
	{
		Target_ShowToPlayer( targets[index], level._player );
	}
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************

railgun_hud_trajectory_update()
{
	self endon( "railgun_hud_trajectory_off" );
	self thread railgun_hud_trajectory_cleanup();


	if ( !IsDefined( level.railgun_trajectory_points ))
	{
		level.railgun_trajectory_points = [];
	}

	for ( ;; )
	{
		self waittill( "target_in_reticule", target );

		AssertEx( isDefined( target ), "Error: no target was passed" );

		for ( ;; )
		{
			//if ( !( self RailgunLockSightTest( target )))
			if ( !( self WorldPointInReticle_Circle( target.origin, 65, 55 )))
			{
				// lost our target, clean stuff up
				for ( index = 0; index < level.railgun_trajectory_points.size; index++ )
				{
					level.railgun_trajectory_points[index] Delete();
				}
				level.railgun_trajectory_points = [];

				break;
			}

			// get our direction vector and we'll start at the target origin for our line
			missile_origin = get_railgun_node();
			dir = VectorNormalize( target.origin - missile_origin.origin );
			scaler_step = 1200;
			start = scaler_step * -11;


			// lets see if we can make 16 points work for us. 8 leading up, and 8 following
			for ( index = 0; index < 16; index++ )
			{
				pos = target.origin + ( start * dir );
				if ( !IsDefined( level.railgun_trajectory_points[index] ))
				{
					level.railgun_trajectory_points[index] = spawn( "script_model", pos );
					level.railgun_trajectory_points[index] setModel( "tag_origin" );
					target_set( level.railgun_trajectory_points[index] );
					target_setvisorlayer( level.railgun_trajectory_points[index], true );
					if ( index < 12 )
					{
						target_setshader( level.railgun_trajectory_points[index], "railgun_trajectory_dot_white" );
					}
					else
					{
						target_setshader( level.railgun_trajectory_points[index], "railgun_trajectory_dot_red" );
					}
					// hide our trajectory dot right at the target
					if ( 11 == index )
					{
						Target_HideFromPlayer( level.railgun_trajectory_points[index], level._player );
					}
				}
				else
				{
					level.railgun_trajectory_points[index].origin = pos;
				}

				start = start + scaler_step;
			}

			wait 0.05;
		}
	}
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************

railgun_hud_trajectory_cleanup()
{
	self waittill( "railgun_hud_trajectory_off" );

	for ( index = 0; index < level.railgun_trajectory_points.size; index++ )
	{
		level.railgun_trajectory_points[index] Delete();
	}
	level.railgun_trajectory_points = [];
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************

railgun_add_rocket_targets()
{
	aim_assist_nodes = GetAimAssistList();

	// Turn on UI for each target
	foreach( node in aim_assist_nodes )
	{
		aim_assist_target = get_aim_assist_target_from_target_origin();
		if ( IsDefined( aim_assist_target ) && node == aim_assist_target )
		{
			continue;
		}

		// turn on aim assist for target
		node EnableAimAssist();

		// add target markers
		target_set( node );
		target_setShader( node, "railgun_target_base" );
		target_setOffScreenShader( node, "railgun_target_offscreen" );
		target_setvisorlayer( node, true );

		// spawn off our cleanup
		thread TargetCleanUp( node );
	}
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************

railgun_hud_switch_ugv_vision( flag )
{
	if ( 0 == flag )
	{
		wait( 0.475 );

		// remove our static 
		//level.railgun_static Destroy();

		level._player UGVVisionOff();
	}
	else
	{
		wait( 0.33 );

		// add static
		//level.railgun_static = NewClientHudElem( level._player );
		//level.railgun_static.horzAlign = "fullscreen";
		//level.railgun_static.vertAlign = "fullscreen";
		//level.railgun_static.alpha = 0.5;
		//level.railgun_static SetShader( "ac130_overlay_grain", 640, 480 );

		level._player UGVVisionOn();
	}
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************

//play a react anim that interupts the current hand anims.
railgun_visor_fps_anim( action )
{
	self endon("death");
	self endon( "dismount" );

	level._player.visor_animating = 1;

	// these anims need to be played on the turret
	// currently working on the assumption that these are the anims currently playing
	// tagMJS<TODO> setup anim tree to do cool trickery that Colin was doing
	self clearAnim( self getanim( "idle_R" ), 0.07 );
	self clearAnim( self getanim( "idle_L" ), 0.07 );

	if ( "on" == action )
	{
		self SetFlaggedAnimRestart( "puton_L", self getanim( "puton_L" ) );
		self SetFlaggedAnimRestart( "puton_L", self getanim( "puton_R" ) );

		self waittillmatch( "puton_L", "end" );
		self clearAnim( self getanim( "puton_L" ), 0.2 );
		self clearAnim( self getanim( "puton_R" ), 0.2 );
	}
	else
	{
		self SetFlaggedAnimRestart( "takeoff_L", self getanim( "takeoff_L" ) );
		self SetFlaggedAnimRestart( "takeoff_L", self getanim( "takeoff_R" ) );

		self waittillmatch( "takeoff_L", "end" );
		self clearAnim( self getanim( "takeoff_L" ), 0.2 );
		self clearAnim( self getanim( "takeoff_R" ), 0.2 );
	}

	self thread maps\_minigun_viewmodel::player_viewhands_minigun_hand( "LEFT" );
	self thread maps\_minigun_viewmodel::player_viewhands_minigun_hand( "RIGHT" );

	level._player notify( "visor_anim_done" );
	level._player.visor_animating = 0;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
