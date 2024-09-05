
//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_ROCKET_SECTION_BRIDGE										**
//                                                                          **
//    Created: 7/13/2011 - Justin Rote										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

VTOL_MISSILE_TYPE = "nx_sidewinder_straight";
//*******************************************************************
//                                                                  *
//	BRIDGE - Ride to next set of rockets							*
//                                                                  *
//*******************************************************************
start()
{
	maps\nx_rocket_section_intro::start_railgun_ride( "heli_start_ride_p2", "gameplay" );
	//maps\nx_rocket_section_intro::start_railgun_ride( "heli_start_ride_bridge", "gameplay" );

	// Setup jump to start objectives
	// "Destroy launch site Alpha"
	Objective_Add( obj( "OBJ_DESTROY_BASE_ALPHA" ), "done", &"NX_ROCKET_OBJ_BASE_ALPHA" );

	// "Destroy launch site Delta"
	Objective_Add( obj( "OBJ_DESTROY_BASE_DELTA" ), "active", &"NX_ROCKET_OBJ_BASE_DELTA" );

	// "Destroy launch site November"
	Objective_Add( obj( "OBJ_DESTROY_LAUNCHING_ROCKETS" ), "active", &"NX_ROCKET_OBJ_LAUNCHING_ROCKETS" );

	// Start some low power rumble to simulate chopper bumps
	thread maps\nx_rocket_util::slightly_vibrate_camera();

	// Prevent the player from being dmaged from behind
	level._player thread maps\nx_rocket_util::player_prevent_damage_from_behind_until_flag( "base_delta_destroyed" );

	// Actors shoot blanks
	anim.shootEnemyWrapper_func = maps\nx_rocket_util::ShootEnemyWrapper_blanks;

	level.playerHeli maps\nx_rocket_util::intro_chopper_allies_setup();
}

main()
{
	thread chopper_transition_to_delta();

	// Main player chopper control script for this section
	level.playerHeli thread chopper_path_bridge();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
section_precache()
{
	// Enemy choppers shoot this
	precacheItem( "sidewinder_straight" );
	precacheItem( "nx_sidewinder_straight" );
	PreCacheItem( "turret_attackheli" );
	PreCacheItem( "missile_attackheli" );
	PreCacheModel( "nx_vehicle_chinese_vtol_destroy" );
}


section_flag_inits()
{
	flag_init( "chopper_ride_bridge_intro" );
	flag_init( "chopper_ride_bridge_encounter_1" );
	flag_init( "chopper_transition_three" );
	flag_init( "bridge_enc1_anim_done" );
	flag_init( "bridge_anim_done" );
}

// Watches for flags on the chopper path
chopper_path_bridge()
{
	//==========================
	// Entering the section
	//==========================
	// FLAG: Entering bridge section
	flag_wait( "chopper_ride_bridge_intro" );

	// Dialogue: Rails are unavailable
	thread starting_bridge_section_dialogue();

	add_global_spawn_function( "axis", maps\nx_rocket_util::protect_player_helicopter_rear );
	ally_copters[ 0 ] = level.bridge_intro_ally;
	array_spawn_function_noteworthy( "bridge_apc", maps\nx_rocket_util::apc_turret_logic, level.playerHeli, ally_copters );

	// Spawn enemies on the road
	//enemy_humvee = spawn_vehicles_from_targetname_and_drive( "bridge_road_tunnel_vehicles" );
	//maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( enemy_humvee );
	//level.playerHeli thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_cleanup_bridge_intro", enemy_humvee );

	level.bridge_vehicles = maps\nx_rocket_util::caravan_setup( "bridge_vehicles_group1_", "chopper_path_cleanup_bridge_intro" );	
	wait 0.1;

	//convoy = spawn_vehicles_from_targetname_and_drive( "bridge_road_convoy" );
	//maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( convoy );
	//level thread maps\nx_rocket_util::handle_caravan_stopping( convoy, "chopper_path_cleanup_bridge_intro" );
	//level.playerHeli thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_cleanup_bridge_intro", convoy );

	vehicles = maps\nx_rocket_util::caravan_setup( "bridge_vehicles_group2_", "chopper_path_cleanup_bridge_intro" );
	level.bridge_vehicles = array_combine( level.bridge_vehicles, vehicles );	
	wait 0.1;


	bridge_ally = spawn_vehicle_from_targetname_and_drive( "bridge_intro_ally" );
	bridge_ally godon();
	bridge_ally EnableLinkTo();
	bridge_ally thread bridge_intro_ally_logic();

	// TO BE FIXED
	// Dan: Temporarly commenting out dialogue thread below.  Flag chopper_ride_bridge_encounter_1
	// was previously triggered due to a heli-path-node.  However, now that player helicopter is
	// animated for this sequence, that path node is never triggerered.

	//==================================
	// Approaching chopper encounter
	//==================================
	// FLAG: Approaching chopper combat encounter 1
	flag_wait( "opfor_helicopter_intro" );
	thread chopper_encounter_dialogue();

	remove_global_spawn_function( "axis", maps\nx_rocket_util::protect_player_helicopter_rear );


	//==================================
	// Chopper encounter anim done
	//==================================
	// FLAG: Chopper battle
	flag_wait( "bridge_enc1_anim_done" );
	//iprintln( "FLAG: bridge_enc1_anim_done" );

	// Dan: Moved this logic into vignette's script.
	// Teleport player chopper to end of anim
	//anim_end_node = GetStruct( "opfor_helicopter_anim_end_node", "targetname" );
	//level.playerHeli vehicle_teleport( anim_end_node.origin, anim_end_node.angles );

	// Dan: Moved this logic into vignette's script.
	//level.playerHeli maps\nx_rocket_util::transition_chopper_to_new_path_noteworthy( "chopper_ride_bridge_ambush_resume_node" );
	//level.playerHeli vehicle_SetSpeedImmediate( 120, 120, 120 );


	// Spawn some enemy choppers
	choppers = spawn_vehicles_from_targetname_and_drive( "bridge_chopper_attack_1_vehicles" );
	maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( choppers );
	level.bridge_encounter_1_choppers = choppers;

	// Increase heli attack range
	level._attackheliRange = 6500;

	// Setup enemy chopper 0
	choppers[0].health = 30000;
	choppers[0] thread maps\_nx_chinese_vtol_low::playDamageEffects( 27500, 3 );
	choppers[0].dontWaitForPathEnd = true;
	choppers[0].no_navigation = true;
	choppers[0] = thread maps\_attack_heli::begin_attack_heli_behavior( choppers[0] );
	choppers[0] thread maps\ny_hind::follow_enemy_vehicle( level.playerHeli, ( -4000, -600, 50 ), 2, 2 );

	// Setup enemy chopper 1
	choppers[1].health = 30000;
	choppers[1] thread maps\_nx_chinese_vtol_low::playDamageEffects( 27500, 3 );
	choppers[1].dontWaitForPathEnd = true;
	choppers[1].no_navigation = true;
	choppers[1] = thread maps\_attack_heli::begin_attack_heli_behavior( choppers[1] );
	choppers[1] thread maps\ny_hind::follow_enemy_vehicle( level.playerHeli, ( -5000, -450, -250 ), 0, 2 );


	// DEBUG
	//choppers[0] thread maps\nx_rocket_util::draw_chopper_name( "Chopper 0" );
	//choppers[1] thread maps\nx_rocket_util::draw_chopper_name( "Chopper 1" );
	// DEBUG

	// Start up the chopper encounter scripts
	choppers[0] thread chopper0_fight_logic();
	choppers[1] thread chopper1_fight_logic();

	level._friendlyFireDisabled = 1;
	level thread vtol_dialogue_on_death(choppers);

	//==================================
	// Finish up chopper encounter
	//==================================
	// FLAG: chopper_ride_start_chopper_dmg_check
	flag_wait( "chopper_ride_start_chopper_dmg_check" );
	
	// Hurt the player if the choppers arent dead yet
	if(( isAlive( choppers[0] ) && ( choppers[0] vehicle_is_crashing()) == false ) ||
	   ( isAlive( choppers[1] ) && ( choppers[1] vehicle_is_crashing()) == false ))
	{
		thread do_forced_chopper_damage();
	}
	
	level.escape_vehicles = maps\nx_rocket_util::caravan_setup( "bridge_vehicles_group3_", "flag_entered_base_delta" );
	foreach ( vehicle in level.escape_vehicles)
	{
		vehicle Vehicle_SetSpeedImmediate ( 0, 15, 15 );
	}
	level.bridge_vehicles = array_combine( level.bridge_vehicles, level.escape_vehicles );	

	//================================
	// Approaching bridge encounter
	//================================
	// FLAG: chopper_ride_approaching_bridge
	flag_wait( "chopper_ride_approaching_bridge" );

	// Kill the player if the choppers arent dead yet
	if(( isAlive( choppers[0] ) && ( choppers[0] vehicle_is_crashing()) == false ) ||
	   ( isAlive( choppers[1] ) && ( choppers[1] vehicle_is_crashing()) == false ))
	{
		if( isGodMode( level._player ))
		{
			// Player is allowed to live, and VTOLs die
			if( isDefined( choppers ))
			{
				// Double extra super safe
				if( isDefined( choppers[0] ))
				{
					choppers[0] kill();
				}
				if( isDefined( choppers[1] ))
				{
					choppers[1] kill();
				}
			}
		}
		else
		{
			level.playerHeli kill();
			level._player kill();
			wait 3.0;
			maps\_utility::missionFailedWrapper();
		}
	}

	thread bridge_dialogue();
	thread fire_rpgs_at_player();

	// Spawn enemy convoys
	/*
	level.bridge_vehicles = spawn_vehicles_from_targetname_and_drive( "bridge_convoy_vehicles" );
	level thread maps\nx_rocket_util::handle_caravan_stopping( level.bridge_vehicles, "chopper_path_leaving_bridge" );
	*/

	
	/*
	convoy_2 = spawn_vehicles_from_targetname_and_drive( "bridge_convoy_vehicles2" );
	level thread maps\nx_rocket_util::handle_caravan_stopping( convoy_2, "chopper_path_leaving_bridge" );
	level.bridge_vehicles = array_combine( level.bridge_vehicles, convoy_2 );
	
	maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( level.bridge_vehicles );
	level.playerHeli thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_leaving_bridge", level.bridge_vehicles );
	*/

	vehicles = maps\nx_rocket_util::caravan_setup( "bridge_vehicles_group4_", "flag_entered_base_delta" );
	level.bridge_vehicles = array_combine( level.bridge_vehicles, vehicles );	
	wait 0.1;


	// Spawn guys on bridge
	array_spawn_function_targetname( "bridge_guys_1", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.bridge_guys_1 = maps\nx_rocket_util::spawn_guys_from_targetname( "bridge_guys_1" );
	level.bridge_guys = level.bridge_guys_1;

	array_spawn_function_targetname( "bridge_guys_2", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.bridge_guys_2 = maps\nx_rocket_util::spawn_guys_from_targetname( "bridge_guys_2" );
	level.bridge_guys = array_combine( level.bridge_guys, level.bridge_guys_2 );

	array_spawn_function_targetname( "bridge_guys_3", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.bridge_guys_3 = maps\nx_rocket_util::spawn_guys_from_targetname( "bridge_guys_3" );
	level.bridge_guys = array_combine( level.bridge_guys, level.bridge_guys_3 );
	level.playerHeli thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_leaving_bridge", level.bridge_guys );

	// Spawn drone guys who shoot the RPGs
	//level.bridge_drones = maps\nx_rocket_util::spawn_guys_from_targetname( "bridge_drones" );
	drone_spawners = GetEntArray( "bridge_drones", "targetname" );
	level.bridge_drones = [];
	foreach( drone in drone_spawners )
	{
		level.bridge_drones[level.bridge_drones.size] = droneSpawn( drone );
	}
	level.playerHeli thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_leaving_bridge", level.bridge_drones );


	//==================================
	// Chopper battle
	//==================================
	// FLAG: Chopper battle
	flag_wait( "bridge_anim_done" );

	// Moving deletion of attractor here so rpg rockets track player
	missile_DeleteAttractor( level.playerHeli.attractor );
	level.playerHeli.attractor_ent delete();
	level.playerHeli thread wait_and_setspeed( 0.5, 75, 95 );

	chopper = level.bridge_encounter_2_chopper; 
	chopper thread bridge_chopper_logic();
	chopper thread bridge_chopper_anim();
	chopper SetLookAtEnt( level.playerHeli );

	// Setup enemy chopper 1
	chopper.health = 65000;
	chopper thread maps\_nx_chinese_vtol_low::playDamageEffects( 64999, 2 );
	chopper.dontWaitForPathEnd = true;
	chopper.no_navigation = true;
	level._attackHeliRefire_min = 0.3;
	level._attackHeliRefire_max = 0.6;
	chopper._attack_heli_custom_firing_func = ::bridge_boss_fire_guns;
	chopper = thread maps\_attack_heli::begin_attack_heli_behavior( chopper );


	// Teleport player to end of anim
	//anim_end_node = GetStruct( "chopper_ride_bridge_end_spawn_node", "script_noteworthy" );
	//level.playerHeli vehicle_teleport( anim_end_node.origin, anim_end_node.angles );

	level.playerHeli maps\nx_rocket_util::heli_start_path( "chopper_ride_bridge_continue_node", "script_noteworthy" );

	// Teleport enemy chopper to its spot
	anim_end_node = GetStruct( "bridge_end_enemy_spawn", "script_noteworthy" );
	chopper vehicle_teleport( anim_end_node.origin, anim_end_node.angles );
	chopper maps\nx_rocket_util::heli_start_path( "bridge_end_enemy_continue", "script_noteworthy" );


	// Wait for the enemy chopper to die
	chopper waittill( "death" );

	// Reset attack_heli refire params to normal
	level._attackHeliRefire_min = 0.8;
	level._attackHeliRefire_max = 1.3;

	wait 1.0;

	level.playerHeli maps\nx_rocket_util::heli_start_path( "chopper_ride_bridge_exit_node", "script_noteworthy" );


	//==================================
	// Entered Base Delta
	//==================================
	// FLAG: flag_entered_base_delta
	flag_wait( "flag_entered_base_delta" );
	thread cleanup_bridge_ents();

	level._friendlyFireDisabled = 0;
}

wait_and_setspeed( time, speed, accel )
{
	wait time;
	self vehicle_SetSpeed( speed, accel );
}


rpg_guys_attempt_escape( player_heli )
{
	wait 1;
	foreach ( guy in level.bridge_guys_1 )
	{
		if ( isAlive (guy) && isAlive (level.escape_vehicles [0]))
		{
			guy DropWeapon( guy.primaryweapon, "right", 1 );
			thread guy_runtovehicle_load( guy, level.escape_vehicles [0] ); 
		}
	}
	wait 1;
	foreach ( guy in level.bridge_guys_2 )
	{
		if ( isAlive (guy) && isAlive (level.escape_vehicles [1]))
		{
			guy DropWeapon( guy.primaryweapon, "right", 1 );
			thread guy_runtovehicle_load( guy, level.escape_vehicles [1] ); 
		}
	}
	wait 1;
	foreach ( guy in level.bridge_guys_3 )
	{
		if ( isAlive (guy) && isAlive (level.escape_vehicles [2]))
		{
			guy DropWeapon( guy.primaryweapon, "right", 1 );
			thread guy_runtovehicle_load( guy, level.escape_vehicles [2] ); 
		}
	}
	wait 9;
	if ( isAlive (level.escape_vehicles [0]))
		level.escape_vehicles [0] Vehicle_SetSpeed( 60, 15, 5 );
	wait .4;
	if ( isAlive (level.escape_vehicles [1]))
		level.escape_vehicles [1] Vehicle_SetSpeed( 60, 15, 5 );
	wait .4;
	if ( isAlive (level.escape_vehicles [2]))
		level.escape_vehicles [2] Vehicle_SetSpeed( 60, 15, 5 );
}


// Controls the ally that flies next to you during the start of this section
bridge_intro_ally_logic()
{
	self endon( "death" );
	wait 3.5;

	level.bridge_intro_ally = self;
	self thread maps\ny_hind::follow_enemy_vehicle( level.playerHeli, ( 1500, -100, 150 ), 1, 2 );

	wait 4.0;
	self maps\ny_hind::adjust_follow_offset_angoff( (1750, 100, 100), 0, 2 );

	wait 2.0;
	self maps\ny_hind::adjust_follow_offset_angoff( (1500, -400, 150), 0, 2 );

	wait 1.0;
	self maps\ny_hind::adjust_follow_offset_angoff( (1500, 200, 25), 0, 2 );

	wait 1.0;
	self maps\ny_hind::adjust_follow_offset_angoff( (1200, -25, 80), 0, 2 );

	flag_wait( "opfor_helicopter_intro" );
	self notify( "newpath" );
	self godoff();

	flag_wait( "bridge_enc1_anim_done" );
	self delete();
}


// Main control thread for the enemy chopper at the bridge
bridge_chopper_logic()
{
	self endon( "death" );
	self godon();

	self waittill( "bridge_chopper_fire_2" );
	//self fire_rocket_salvo( level.playerHeli );

	self waittill( "bridge_chopper_fire_3" );
	//self fire_rocket_salvo( level.playerHeli );

	self waittill( "bridge_chopper_fire_4" );

	self godoff();
	self.currenthealth = 1;
	self.health = 1;

	wait 1.0;

	// Hurt the player if the chopper isnt dead yet
	if(( isAlive( self ) && ( self vehicle_is_crashing()) == false ))
	{
		self fire_rocket_salvo( level.playerHeli );
		wait 0.5;
		thread do_forced_chopper_damage();
	}

	wait 4.0;

	// Kill the player if the chopper isnt dead yet
	if(( isAlive( self ) && ( self vehicle_is_crashing()) == false ))
	{
		self fire_rocket_salvo( level.playerHeli );
		wait 0.5;
		thread do_forced_chopper_damage();
	}

	wait 3.0;

	// Kill the player if the chopper isnt dead yet
	if(( isAlive( self ) && ( self vehicle_is_crashing()) == false ))
	{
		self fire_rocket_salvo( level.playerHeli );
		wait 0.5;

		if( isGodMode( level._player ))
		{
			// Player is allowed to live, and VTOL dies
			self kill();
		}
		else
		{
			level.playerHeli kill();
			level._player kill();
			wait 3.0;
			maps\_utility::missionFailedWrapper();
		}
	}
}

// Makes the bridge battle chopper fire non stop
bridge_boss_fire_guns( ignoreMe_1, ignoreMe_2, ignoreMe_3 )
{
	self endon( "death" );

	eTarget = level.playerHeli;
	burstSize = 10;
	fireTime = 0.1;

	while( 1 )
	{
		for ( i = 0; i < burstsize; i++ )
		{
			if ( !IsAlive( eTarget ) )
			{
				return;
			}

			self SetTurretTargetEnt( eTarget, randomvector( 50 ) + ( 0, 0, 32 ) );
			//self SetTurretTargetEnt( eTarget, ( 0, 0, 32 ) );
			if ( ( self.allowShoot ) && ( !self.firingMissiles ) )
			{
				self FireWeapon();
			}
			wait fireTime;
		}
		wait 0.25;
	}
}

bridge_chopper_anim()
{
	self waittill( "death" );
	maps\nx_rocket_anim::vtol_breakapart();
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Fires rockets at the target
fire_rocket_salvo( target, dist_ahead_to_spawn_attractor, dist_below, delayed_explosion_time )
{
	// Hack: Spawning attractor at approximate intercept point
	// If the paths, speeds, or geo changes much the distance will have to be updated
	if ( !isDefined( dist_ahead_to_spawn_attractor ) )
	{
		dist_ahead_to_spawn_attractor = 0;
	}

	if ( !isDefined( dist_below ) )
	{
		dist_below = 0;
	}

	if ( dist_ahead_to_spawn_attractor > 0 )
	{
		target thread rocket_salvo_attractor( dist_ahead_to_spawn_attractor, dist_below );
	}
	
	// HACK: Fire rockets via magic bullets out of the tag_flash of turrets 1 and 3 (the missile turrets)
	assert( isDefined( self.mgturret ) && self.mgturret.size == 4 );
	
	tag_flash = self.mgturret[1] GetTagOrigin( "tag_flash" );
	tag_forward = AnglesToForward( self.mgturret[1] GetTagAngles( "tag_flash" ) );
	PlayFx( getfx( "cobra_rocket_flash_wv" ), tag_flash );
	missile = magicBullet( VTOL_MISSILE_TYPE, tag_flash + tag_forward * 50, target.origin + (0,0,-60));
	if ( isDefined( delayed_explosion_time ) && isDefined( missile ) )
	{
		missile thread explode_soon( delayed_explosion_time );
	}
	//missile thread explode_soon( 1.0 );
	wait 0.1;
	tag_flash = self.mgturret[3] GetTagOrigin( "tag_flash" );
	tag_forward = AnglesToForward( self.mgturret[3] GetTagAngles( "tag_flash" ) );
	PlayFx( getfx( "cobra_rocket_flash_wv" ), tag_flash );
	missile = magicBullet( VTOL_MISSILE_TYPE, tag_flash + tag_forward * 50, target.origin  + (0,0,-60));
	if ( isDefined( delayed_explosion_time ) && isDefined( missile ) )
	{
		missile thread explode_soon( delayed_explosion_time );
	}
}

explode_soon( wait_time )
{
	self endon( "death" );
	wait wait_time;
	self detonate();
}


// This script is a hack to get rockets to be more visible on the player's screen.
// An attractor will be spawned dist_ahead in front of this object so that rockets
// Will seem to be intercepting to a point ahead of it.  After a time, the attractor
// Will revert back to the object's origin.
rocket_salvo_attractor( dist_ahead, dist_below )
{
	self endon( "death" );
	if ( !isdefined( dist_below ) )
	{
		dist_below = 100;
	}

	target_forward = AnglesToForward( self.angles );
	below = ( 0, 0, -1 ) * dist_below;
	attractor_origin = self.origin + target_forward * dist_ahead + below; // Origin is in the rotors, we want it slightly lower
	restore_attractor = false;
	if ( isDefined( self.attractor ) )
	{
		restore_attractor = true;
		missile_DeleteAttractor( self.attractor );
	}
	self.attractor = missile_createAttractorOrigin( attractor_origin, 25000, 60000 );

	// Wait a second, then put the attractor on the real target
	wait 0.7;
	missile_DeleteAttractor( self.attractor );
	if ( restore_attractor && isDefined( self.attractor_ent ) )
	{
		self.attractor = missile_createAttractorEnt( self.attractor_ent, 25000, 60000 );
	}
}

// Enemy troops fire RPGs at the player chopper
fire_rpgs_at_player()
{
	// Give the player a missile attractor
	level.playerHeli.attractor_ent = spawn( "script_origin", level._player.origin + ( 0, 0, -100 ) );
	level.playerHeli.attractor_ent LinkTo( level._player );
	level.playerHeli.attractor = missile_createAttractorEnt( level.playerHeli.attractor_ent, 2500, 60000 );

	rpg_origins = GetEntArray( "bridge_rpg_origin", "script_noteworthy" );
	for( i = 0; i < rpg_origins.size; i++ )
	{
		target = GetEnt ( rpg_origins[i].target, "targetname");
		magicBullet( "rpg_player", rpg_origins[i].origin , target.origin );

		// There are currently 7 rpg launch origins, for doing the wait math here.
		wait .5;
	}
	wait 9.5;

	for( i = 0; i < rpg_origins.size; i++ )
	{
		magicBullet( "rpg_player", rpg_origins[i].origin , level._player.origin );
		wait .1;
	}

}

/*debug_crashes()
{
	level._player endon( "death" );
	while ( 1 )
	{
		foreach ( location in level._helicopter_crash_locations )
		{
			box( location.origin, 16, 0, (1,0,0), 1, 1, 60 );
		}
		wait 1;
	}

}*/

// Moves the chopper around a bit and fires some missiles
chopper0_fight_logic()
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "newpath" );

	// Initial Pos ( -4000, -600, 50 )
	//level thread debug_crashes();

	// Approaches at about 500 units a second, fires in 7 seconds, then backs off
	self thread maps\ny_hind::adjust_follow_offset_angoff( (-3500, -850, 2500), 0, 1 ); // Come up over spawn hill
	wait 1.0;
	self thread maps\ny_hind::adjust_follow_offset_angoff( (-1500, -950, 250), 0, 2 );
	wait 2.0;
	self thread maps\ny_hind::adjust_follow_offset_angoff( (-500, -2150, 75), 0, 2 );
	wait 2.0;
	self SetLookAtEnt( level.playerHeli );
	wait 2.0;
	fire_rocket_salvo( level.playerHeli, 2000, 200, 1.0 );
	wait 0.5;
	self ClearLookAtEnt();
	self thread maps\ny_hind::adjust_follow_offset_angoff( (-2000, -850, 200), 0, 4 );
	wait 8.0;

	// Fire another volley from behind
	self SetLookAtEnt( level.playerHeli );
	wait 3.0;
	fire_rocket_salvo( level.playerHeli );
	wait 0.5;
	self ClearLookAtEnt();
}

chopper1_fight_logic()
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "newpath" );

	// Initial Pos ( -5000, -450, -250 )

	// Approaches at about 750 units a second, fires in 13 seconds, then backs off
	self thread maps\ny_hind::adjust_follow_offset_angoff( (-5000, 1500, 300), 0, 1 );
	wait 3.0;
	self thread maps\ny_hind::adjust_follow_offset_angoff( (-3500, 1500, 300), 0, 2 );
	wait 2.0;
	self thread maps\ny_hind::adjust_follow_offset_angoff( (-2000, -700, -200), 0, 2 );
	wait 2.0;
	self thread maps\ny_hind::adjust_follow_offset_angoff( (-500, -500, -250), 0, 2 );
	wait 2.0;
	self thread maps\ny_hind::adjust_follow_offset_angoff( (1000, -2000, -250), 0, 2 );
	self SetLookAtEnt( level.playerHeli );
	wait 4.0;
	self SetLookAtEnt( level.playerHeli );
	wait 2.0;
	fire_rocket_salvo( level.playerHeli, 1000, -100, 1.0 );
	wait 0.5;
	self ClearLookAtEnt();
	self thread maps\ny_hind::adjust_follow_offset_angoff( (-1800, -650, -275), 0, 3 );
	wait 4.0;

	// Fire another volley from behind
	self SetLookAtEnt( level.playerHeli );
	wait 3.0;
	fire_rocket_salvo( level.playerHeli );
	wait 0.5;
	self ClearLookAtEnt();
}


// Hurts the player because they havnt killed the enemy choppers
do_forced_chopper_damage()
{
	level._player DoDamage( (level._player.health - 1) / 2, level._player.origin );
	wait 1.2;
	level._player DoDamage( (level._player.health - 1) / 2, level._player.origin );
	wait 0.88;
	level._player DoDamage( (level._player.health - 1) / 2, level._player.origin );
	wait 1.1;
	level._player DoDamage( (level._player.health - 1) / 2, level._player.origin );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Dialogue when you enter the bridge section
starting_bridge_section_dialogue()
{
	baker = level.squad[ "ALLY_BAKER" ];
	jenkins = level.squad[ "ALLY_JENKINS" ];
	williams = level.squad[ "ALLY_WILLIAMS" ];

	//Bogie! Bogie!  12 O'clock high!
	level thread play_dialogue( "roc_ded4_bridge_boogie12oclock", 21.2 );
	//Confirmed.  Visual track on 2 gunships!
	level thread play_dialogue( "roc_ded1_bridge_visualon2gunships", 24 );
	//Negative visual.  Where the hell did they go!?
	level thread play_dialogue( "roc_ded1_bridge_negativevisual", 31 );
	//They're on our tail!
	baker thread play_dialogue( "roc_bak_bridge_onourtail2", 33.4 );
	//Strobes at 12 o'clock.  IR targeting.  Looks like shoulder fired missiles.
	level thread play_dialogue( "roc_ded1_bridge_irtargeting", 51 );
	//Launch detected!
	level thread play_dialogue( "roc_ded1_bridge_launchdetected", 58 );
	//Missile inbound!
	level thread play_dialogue( "roc_ded1_bridge_missileinbound", 69.3 );
	//Take evasive action!
	level thread play_dialogue( "roc_ded1_bridge_evasiveaction", 60.3 );

//
//  // Command: "Deadeye two-one, we lost you in the mountains."
//  maps\nx_rocket_util::wait_play_dialogue_wait( 1.0, "roc_cmd_bridge_lostyouinmntns" );
//
//  // Command: "Rail support is unavailable.  You are clear to engage with your M280s"
//  maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_cmd_bridge_railunavail" );
}

vtol_dialogue_on_death(vtols)
{
	lines = [];
	lines[0] = "roc_ded1_bridge_splash1";
	lines[1] = "roc_ded1_bridge_splash2";
	level.vtol_curr_line = 0;

	foreach( vtol in vtols )
	{
		vtol thread vtol_death_dialogue(lines);
	}
//  level thread play_dialogue( "roc_ded1_bridge_splash1", 45.3 );
//  //Splash 2!
//  level thread play_dialogue( "roc_ded1_bridge_splash2", 48 );	
}

vtol_death_dialogue(lines)
{
	self waittill( "death" );
	level thread play_dialogue( lines[level.vtol_curr_line], RandomFloatRange(0.0, 0.7) );
	level.vtol_curr_line++;
	if(level.vtol_curr_line > lines.size) level.vtol_curr_line = 0;
}

// Dialogue for chopper combat sequence
chopper_encounter_dialogue()
{
//    // Baker: "Two enemy helos one o'clock!!!"
////  maps\nx_rocket_util::wait_play_dialogue_wait( 2.0, "roc_bak_bridge_helos1oclock" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_bridge_helos1oclock", 2.0 );
//
//    // Warning: "<beep> <beep> <beep> <beep>"
//    //maps\nx_rocket_util::wait_play_dialogue_wait( 0.5, "roc_warn_bridge_beep" );
//
//    // Williams: "Shit! Incoming!"
////  maps\nx_rocket_util::wait_play_dialogue_wait( 1.0, "roc_wil_bridge_incoming" );
//    level.squad[ "ALLY_WILLIAMS" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_wil_bridge_incoming", 1.0 );
//
//    flag_wait( "bridge_enc1_anim_done" );
//
//    // Baker: "Theyre on our tail, take em out!"
////  maps\nx_rocket_util::wait_play_dialogue_wait( 1.5, "roc_bak_bridge_onourtail" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_bridge_onourtail", 1.5 );
//
//    // Pilot: "Should I circle back around to engage?"
//    //maps\nx_rocket_util::wait_play_dialogue_wait( 0.6, "roc_pil_bridge_shouldicircle" );
//
//    // Baker: "Stay on course! We got it covered!"
//    //maps\nx_rocket_util::wait_play_dialogue_wait( 0.3, "roc_bak_bridge_stayoncourse" );
//
//
//    flag_wait( "chopper_ride_start_chopper_dmg_check" );
//
//    if(( isAlive( level.bridge_encounter_1_choppers[0] ) && ( level.bridge_encounter_1_choppers[0] vehicle_is_crashing()) == false ) ||
//       ( isAlive( level.bridge_encounter_1_choppers[1] ) && ( level.bridge_encounter_1_choppers[1] vehicle_is_crashing()) == false ))
//    {
//        // Baker: "Were getting shot up!  Destroy the choppers!"
//        //maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_bak_bridge_onourtail" );
//    }
}


// Encounter dialogue for the bridge
bridge_dialogue()
{
//// Williams: "Coming up on a bridge, looks like another patrol."
////  maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_wil_bridge_anotherpatrol" );
//    level.squad[ "ALLY_WILLIAMS" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_wil_bridge_anotherpatrol", 0 );
//    // Williams: "Footmobiles, and..  four plus victors."
//    //maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_wil_bridge_footmobs4victors" );
//
//    // Baker: "Weapons free."
////  maps\nx_rocket_util::wait_play_dialogue_wait( 0.1, "roc_bak_bridge_weaponsfree" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_bridge_weaponsfree", 0.1 );
//
//    // Baker: "RPGs! Dive! Dive!"
////  maps\nx_rocket_util::wait_play_dialogue_wait( 2.0, "roc_bak_bridge_rpgsdive" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_bridge_rpgsdive", 2.0 );
//
//    // Baker: "Hang on!"
////  maps\nx_rocket_util::wait_play_dialogue_wait( 7.0, "roc_bak_bridge_hangon" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_bridge_hangon", 7.0 );
//
//    flag_wait( "bridge_anim_done" );
//
//    // Baker: "Take out that VTOL!"
////  maps\nx_rocket_util::wait_play_dialogue_wait( 1.0, "roc_bak_bridge_takeoutvtol" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_bridge_takeoutvtol", 1.0 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Delete bridge enemies and objects when the player leaves the area
cleanup_bridge_ents()
{
	maps\nx_rocket_util::safe_delete_array( level.bridge_guys_1 );
	maps\nx_rocket_util::safe_delete_array( level.bridge_vehicles );
}



// Chopper finishes bridge section and continues to base delta section
chopper_transition_to_delta()
{
	//iprintln( "waiting for transition to delta" );

	// Wait untill it enters bridge area
	flag_wait( "chopper_transition_three" );

	//iprintln( "transition to delta go" );

	AssertEx( IsDefined( level.playerHeli ), "Tried to transition chopper when level.playerHeli does not exist" );

	// Get rid of old path
	level.playerHeli thread vehicle_detachfrompath();

	// Get the new path
	transition_node = getstruct( "chopper_transition_node_three", "targetname" );

	// Use new patch
	level.playerHeli.currentnode = transition_node;

	//iprintln( "new path go" );

	// Continue on new path
	level.playerHeli thread vehicle_resumepath();
	level.playerHeli GoPath();

	// Slow down the heli
	iprintln( "set maxpitchroll" );
	level.playerHeli SetMaxPitchRoll( 5, 15 );
	level.playerHeli set_heli_move( "slow" ); 
}


	 
// JR TEST - Move to util	 
vary_follow_chopper_path( min_freq, max_freq, o_offset, r_offset_min, r_offset_max, move_time )
{
	self endon( "death" );
	self endon( "newpath" );

	while( true )
	{
		r_offset_x = RandomFloatRange( r_offset_min[0], r_offset_max[0] );
		r_offset_y = RandomFloatRange( r_offset_min[1],	r_offset_max[1] );
		r_offset_z = RandomFloatRange( r_offset_min[2],	r_offset_max[2] );

		random_offset = ( r_offset_x, r_offset_y, r_offset_z );

		new_offset = ( o_offset - random_offset );
	
		// Move the chopper
		iprintln( "moving" );
		self thread maps\ny_hind::adjust_follow_offset_angoff( new_offset, 0, move_time );
	
		wait RandomFloatRange( min_freq, max_freq );
	};
}

