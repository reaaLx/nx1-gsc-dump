
//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_ROCKET_SECTION_BASE_ALPHA									**
//                                                                          **
//    Created: 7/13/2011 - Justin Rote										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

ROCKET_1_INITIAL_DEPTH = -2750;	// How deep underground rocket 2 starts
ROCKET_1_RISE_DELAY = 10;		// Delay before it starts rising
ROCKET_1_RISE_TIME = 35;		// How long it takes for rocket 2 to emerge
ROCKET_1_LAUNCH_FX_DELAY = 25;	   // Delay untill prelaunch FX start
ROCKET_1_LAUNCH_DELAY = 42;	   // Initial delay before it launches
ROCKET_1_LAUNCH_HEIGHT = 16000; // How high it launches into the air
ROCKET_1_LAUNCH_TIME = 18;		// How long it takes to launch ( effects upward speed )

//*******************************************************************
//                                                                  *
//	BASE ALPHA - First rocket valley								*
//                                                                  *
//*******************************************************************
start()
{
	maps\nx_rocket_section_intro::start_railgun_ride( "heli_start_ride_p1", "gameplay" );

	// "Destroy launch site Alpha"
	Objective_Add( obj( "OBJ_DESTROY_BASE_ALPHA" ), "active", &"NX_ROCKET_OBJ_BASE_ALPHA" );

	// "Destroy launch site Delta"
	Objective_Add( obj( "OBJ_DESTROY_BASE_DELTA" ), "active", &"NX_ROCKET_OBJ_BASE_DELTA" );

	// "Destroy launch site November"
	Objective_Add( obj( "OBJ_DESTROY_LAUNCHING_ROCKETS" ), "active", &"NX_ROCKET_OBJ_LAUNCHING_ROCKETS" );

	// Spawn looping chopper allies
	level.intro_ally_1 = spawn_vehicle_from_targetname_and_drive( "base_alpha_loop_ally_1" );
	level.intro_ally_2 = spawn_vehicle_from_targetname_and_drive( "base_alpha_loop_ally_2" );

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
	// FX for Rocket01 Prelaunch and Intro FX cleanup
	//thread maps\nx_rocket_fx::rocket_01_prelaunch_fx();
	thread maps\nx_rocket_fx::rocket_introfx_cleanup();
	thread maps\nx_rocket_fx::rocket01_gantrylights_fx();

	// Enemy spawnfuncs
	array_spawn_function_targetname( "base_alpha_roof_runners_1", maps\nx_rocket_util::run_to_goal_then_aggro );
	array_spawn_function_targetname( "base_alpha_roof_runners_2", maps\nx_rocket_util::run_to_goal_then_aggro );
	array_spawn_function_targetname( "base_alpha_garage_guys", maps\nx_rocket_util::run_to_goal_then_aggro );

	// Sets up and waits for rocket one destruction
	thread rocket_one_anim();
	thread mission_fail_logic();

	thread chopper_transition_to_bridge();

	// Main player chopper control script for this section
	level.playerHeli thread chopper_path_base_alpha();
	
	//rocket launch VO announcements for section
	level thread maps\nx_rocket_audio::base_alpha_countdown_sfx();

	// Watch for railgun impacts on various secondary targets
	thread railgun_damage_watcher();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
section_precache()
{
	// Temp weapon FX used for railgun
	PrecacheItem( "nx_rocket_railgun" );
	PrecacheItem( "nx_rocket_railgun_secondary" );
	PrecacheItem( "rpg_straight" );

	// tagMJS<NOTE> 10/18/2011 - 3D reticule no longer being used
	// Precache the reticule pieces
	//PreCacheModel("nx_reticule_outer_ring");
	//PreCacheModel("nx_reticule_middle_ring");
	//PreCacheModel("nx_reticule_inner_ring");
	//PreCacheModel("nx_reticule_triangle");
	//PreCacheModel("nx_reticule_ticks");

	// DPad Icon
	precacheShader( "dpad_laser_designator" );

	// railgun target icons
	preCacheShader( "railgun_target_base" );
	preCacheShader( "railgun_target_offscreen" );
	preCacheShader( "railgun_trajectory_dot_white" );
	preCacheShader( "railgun_trajectory_dot_red" );

	// Setup hint strings
	add_hint_string( "hint_railgun_activate",	&"NX_ROCKET_HINT_RAILGUN_ACTIVATE",	::hint_railgun_activate );
	add_hint_string( "hint_railgun_lock",		&"NX_ROCKET_HINT_RAILGUN_LOCK",		::hint_railgun_lock );

	preCacheShader( "ac130_overlay_grain" );

	// SLAMRAAM

	PreCacheItem( "slamraam_missile_dcburning" );
	precacheModel( "vehicle_slamraam_destroyed" );
}


section_flag_inits()
{
	flag_init( "player_on_minigun" );
	flag_init( "player_off_minigun" );

	// Whether the player can use the railgun or not
	flag_init( "railgun_available" );

	flag_init( "player_activated_railgun" );
	flag_init( "player_used_railgun" );

	flag_init( "rocket_1_destroyed" );
	flag_init( "chopper_path_entering_base_alpha" );
	flag_init( "chopper_path_after_reveal" );
	
	flag_init( "chopper_ride_starting_rocket_one_loop" );
	flag_init( "chopper_path_leaving_base_alpha" );

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Main chopper control script for this section
chopper_path_base_alpha()
{
	// FLAG: chopper_ride_approaching_base_alpha
	flag_wait( "chopper_ride_approaching_base_alpha" );

	// SAM Turrets
	level.alpha_sam_turrets= [];
	level.alpha_sam_turrets[level.alpha_sam_turrets.size] = thread maps\nx_rocket_section_base_delta::sam_turret_init ("base_alpha_sam_turret_1", "chopper_path_alpha_bunker_roof"); 
	level.alpha_sam_turrets[level.alpha_sam_turrets.size] = thread maps\nx_rocket_section_base_delta::sam_turret_init ("base_alpha_sam_turret_2", "chopper_ride_starting_rocket_one_loop"); 
	level.alpha_sam_turrets[level.alpha_sam_turrets.size] = thread maps\nx_rocket_section_base_delta::sam_turret_init ("base_alpha_sam_turret_3", "chopper_path_after_reveal"); 

	// Dialogue for first base
	thread base_alpha_dialogue();
	thread base_alpha_dialogue_launch();

	// FLAG: chopper_path_entering_base_alpha
	flag_wait( "chopper_path_entering_base_alpha" );

	// Add an attractor to the chopper
	//level.playerHeli.attractor = missile_createAttractorEnt( level.playerHeli, 25000, 40000 );
	//level.playerHeli.repulsor = missile_createRepulsorEnt( level.playerHeli, 15000, 5000 );

	// Add weak attractors to the allied choppers
	level.intro_ally_1.attractor = missile_createAttractorEnt( level.intro_ally_1, 15000, 20000 );
	level.intro_ally_2.attractor = missile_createAttractorEnt( level.intro_ally_2, 15000, 20000 );


	//==========================
	// SETUP RAILGUN TARGETS
	//==========================
	// Spawn TEMP ground troops
	// TagCC<NOTE>: Also give these guys a spawn function to decrease their accuracy when the player's helicopter is facing away.
	array_spawn_function_targetname("base_alpha_guys_1", maps\nx_rocket_util::protect_player_helicopter_rear );
	array_spawn_function_targetname("base_alpha_guys_2", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.base_alpha_guys_1 = maps\nx_rocket_util::spawn_guys_from_targetname( "base_alpha_guys_1" );
	level.base_alpha_guys_2 = maps\nx_rocket_util::spawn_guys_from_targetname( "base_alpha_guys_2" );
	level.base_alpha_guys_3 = maps\nx_rocket_util::spawn_guys_from_targetname( "base_alpha_guys_3" );

	// Spawn stationary ground vehicles
	// JR - These were replaced with destructibles
	//level.base_alpha_vehicles_static = spawn_vehicles_from_targetname( "base_alpha_vehicles_static" );

	

	// Spawn pathing ground vehicles
	level.base_alpha_vehicles_pathing = spawn_vehicles_from_targetname_and_drive( "base_alpha_vehicles_pathing" );
	maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( level.base_alpha_vehicles_pathing );	
	level.blackhawk_targets = level.base_alpha_vehicles_pathing;

	// Setup rocket targets
	level.base_alpha_rocket = getent( "railgun_rocket_alpha_target", "targetname" );

	// Setup building targets
	//level.base_alpha_buildings = [];
	//level.base_alpha_buildings = GetEntArray( "base_alpha_buildings", "targetname" );

	//==========================
	//==========================

	// Set the current area
	// This is used to determine what railgun targets to use
	level.current_area = "base_alpha";

	// DEBUG
	// JR - Uncomment this if you want the railgun usable immediatly
	//maps\nx_rocket_railgun::enable_railgun();
	// DEBUG

	// Turn down accuracy on allied choppers
	level.intro_ally_1 thread maps\nx_rocket_util::set_ally_chopper_spread( 8 );
	level.intro_ally_2 thread maps\nx_rocket_util::set_ally_chopper_spread( 8 );
	level.intro_ally_1.health *= 2;
	level.intro_ally_2.health *= 2;

	level.alpha_littlebird_01 = spawn_vehicle_from_targetname_and_drive( "alpha_littlebird_01" );
	level.alpha_littlebird_01 maps\nx_rocket_util::set_ally_chopper_spread( 4 );
	level.alpha_littlebird_01 thread maps\nx_rocket_util::vehicle_follow( level.playerHeli, 500, 5, 140, level.playerHeli );

	level.alpha_littlebird_02 = vehicle_spawn( GetEnt( "alpha_littlebird_02", "targetname" ) );
	Target_Remove( level.alpha_littlebird_02  );
	level.alpha_littlebird_02 godon();
	level.alpha_littlebird_02.perferred_crash_location = GetEnt ("helipad_rooftop_crash_location", "targetname");
	level.alpha_littlebird_02 maps\nx_rocket_util::set_ally_chopper_spread( 4 );
	level.alpha_littlebird_02 thread littlebird_liftoff( "alpha_littlebird_02", 550 );

	level.tunnel_humvee_02 = spawn_vehicle_from_targetname_and_drive( "tunnel_humvee_02" );
	maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( level.tunnel_humvee_02 );
	level.blackhawk_targets = array_add( level.blackhawk_targets, level.tunnel_humvee_02 );	

	// Spawn heli that will crash
	crash_chopper = spawn_vehicle_from_targetname_and_drive( "base_alpha_crash_ally" );
	crash_chopper thread wait_and_crash();

	// FLAG: chopper_path_alpha_bunkers
	flag_wait( "chopper_path_alpha_bunkers" );
	thread do_roof_guys_2();
	level.garage_apc = spawn_vehicle_from_targetname_and_drive( "garage_apc" );
	level.garage_apc.kill_player_time = 5;
	maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( level.garage_apc );
	level.garage_apc mgon();

	ally_copters = [ level.intro_ally_1, level.intro_ally_2 ];
	
	thread maps\nx_rocket_section_intro::allies_choose_targets( ally_copters );

	level.garage_apc thread maps\nx_rocket_util::apc_turret_logic( level.playerHeli, ally_copters );

	// FLAG: chopper_path_alpha_roof
	flag_wait( "chopper_path_alpha_bunker_roof" );
	thread do_roof_guys_1();
	thread do_garage_guys();


	// FLAG: chopper_ride_bunkers_done
	flag_wait( "chopper_ride_tunnel_humvee_go" );
	level.tunnel_humvee_01 = spawn_vehicle_from_targetname_and_drive( "tunnel_humvee_01" );
	maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( level.tunnel_humvee_01 );
	level.blackhawk_targets = array_add( level.blackhawk_targets, level.tunnel_humvee_01 );	

	level.base_alpha_guys_4 = maps\nx_rocket_util::spawn_guys_from_targetname( "base_alpha_guys_4" );

	// Allow railgun usage
	flag_wait( "chopper_ride_starting_rocket_one_loop" );
	wait 8.0;
	maps\nx_rocket_railgun::enable_railgun();

	// Display tooltip "Press D-Pad Right to activate Railgun targeter"
	level._player display_hint( "hint_railgun_activate" );

	// JR - Probably need a nag loop here telling the player to fire the railgun
	thread maps\nx_rocket_util::nag_for_fire_railgun( "railgun_fired" );

	flag_wait( "player_activated_railgun" );
	wait 0.5;

	// Display tooltip "Press RT to lock and fire Railgun"
	level._player display_hint( "hint_railgun_lock" );

	// FLAG: chopper_path_leaving_base_alpha
	// Leaving the area
	flag_wait( "chopper_path_leaving_base_alpha" );
	thread cleanup_base_alpha_ents();

	// Remove the chopper attractor
	//missile_DeleteAttractor( level.playerHeli.attractor );
	//missile_DeleteAttractor( level.playerHeli.repulsor );

	// Disable railgun usage
	maps\nx_rocket_railgun::disable_railgun();
}


// Spawns some guys on the roof, and makes them run
do_roof_guys_1()
{
	array_spawn_function_targetname("base_alpha_roof_runners_1", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.base_alpha_roof_guys_1 = maps\nx_rocket_util::spawn_guys_from_targetname( "base_alpha_roof_runners_1" );
}


// Spawns some guys on the roof, and makes them run
do_roof_guys_2()
{
	array_spawn_function_targetname("base_alpha_roof_runners_2", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.base_alpha_roof_guys_2 = maps\nx_rocket_util::spawn_guys_from_targetname( "base_alpha_roof_runners_2" );

}


// Spawns guys in the garage, who run out
do_garage_guys()
{
	array_spawn_function_targetname("base_alpha_garage_guys", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.base_alpha_garage_guys = maps\nx_rocket_util::spawn_guys_from_targetname( "base_alpha_garage_guys" );
}

littlebird_liftoff( liftoff_flag, liftoff_height )
{
	// self endon( "death" );

	self maps\nx_rocket_util::vehicle_enable_fire( false );
	flag_wait( liftoff_flag );
	if ( !Target_IsTarget ( self ))
	{
		Target_Set ( self, ( 0, 0, -55 ) ); 
		target_setshader( self, "javelin_hud_target_red" );
	}
	self vehicle_liftoff( liftoff_height );
	self maps\nx_rocket_util::vehicle_enable_fire( true );
	self GoPath();
	self thread maps\nx_rocket_util::vehicle_follow( level.playerHeli, 500, 5, 140, level.playerHeli );
	// Make it destroyable once it's airborne
	self godoff();
	// if it crashes, kill anyone nearby the crash site
	self waittill ("crash_done");
	foreach ( guy in level.base_alpha_roof_guys_2)
	{
		if ( isAlive ( guy ))
			guy kill();
	}

}

// Allied chopper gets shot down
wait_and_crash()
{
	//attractor = missile_createAttractorEnt( self, 100000, 60000 );

	//wait 1.0;
	//missile_origin = getent( "heli_crash_missile_origin", "targetname" );
	//MagicBullet( "rpg_player", missile_origin.origin, self.origin );

	flag_wait( "alpha_chopper_blow_up" );

	num_rounds = RandomIntRange( 2, 4 );

    self.missile_attractor = Missile_CreateAttractorEnt( self, 50000, 8000 );	

	for( i = 0; i < num_rounds; i++ )
	{
		start_offset = AnglesToForward( self.angles ) * 1000 + random_vector( RandomFloatRange( 750, 1200 ) );
		start_offset = ( start_offset[0], start_offset[1], -1400 );
		end_offset = AnglesToForward( self.angles ) * 100;

		bullet_start = self.origin + start_offset;
		bullet_end = self.origin + end_offset;

		rpg = MagicBullet( "rpg_straight", bullet_start, bullet_end );
		wait 0.2;
	}

	wait 3.0;
	if( IsAlive( self ) )
		self kill();
	self notify( "newpath" );

	//missile_deleteAttractor( attractor );
}


// Fails the player if rocket 1 launches
mission_fail_logic()
{
	level endon( "rocket_1_destroyed" );
	level waittill( "rocket_one_done_launching" );
	SetDvar( "ui_deadquote", &"NX_ROCKET_ALPHA_FAIL" );
	maps\_utility::missionFailedWrapper();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Setup and animation for the first rocket
rocket_one_anim()
{
	// Get anim node
	anim_node = getEnt( "vignette_nx_rocket_explosion_test_01", "targetname" );

	//=============================================
	// SETUP THE PIECES
	//=============================================
	rocket_one = spawn_anim_model("rocket_shuttle_exp1_010");
	rocket_one.origin = anim_node.origin;
	rocket_one.angles = anim_node.angles;


	// Link pieces to node
	rocket_one linkTo( anim_node );

	// Link collision cylinder to anim node
	damage_detector = GetEnt( "damage_detector_r1", "script_noteworthy" );
	damage_detector linkTo( anim_node );

	// Link target indicator node to the anim node
	target_indicator = GetEnt( "railgun_rocket_alpha_target", "targetname" );
	target_indicator linkTo( anim_node );

	// Start the rocket below ground
	anim_node.origin = anim_node.origin + (0,0, ROCKET_1_INITIAL_DEPTH );

	// Start the gantry below ground
	thread gantry_setup_one();

	script_models = [];
	script_models["rocket_shuttle_exp1_010"] = rocket_one;

	anim_node anim_first_frame( script_models, "rocket_shuttle_exp1");

	// Move the rocket up
	anim_node thread move_rocket_one();
	anim_node thread launch_rocket_one();
	rocket_one thread rocket_one_fx();

	//=======================================
	// Wait for the rocket to be destroyed
	//=======================================
	level waittill( "rocket_1_destroyed" );

	// Determine which anim should play
	explosion_anim = undefined;
	explosion_models = [];

	//==========================================================
	//==========================================================
	if( level.rocket_1_state == "rising" )
	{
		explosion_anim = "rocket_shuttle_exp1";
		thread maps\nx_rocket_fx::rocket_01_hit_fx( rocket_one );
	}

	//==========================================================
	//==========================================================
	else if( level.rocket_1_state == "waiting" )
	{
		explosion_anim = "rocket_shuttle_exp1";
		thread maps\nx_rocket_fx::rocket_01_hit_fx( rocket_one );
	}


	//==========================================================
	//==========================================================
	else if( level.rocket_1_state == "launching" )
	{
		explosion_anim = "rocket_shuttle_exp1";
		thread maps\nx_rocket_fx::rocket_01_launch_hit_fx( rocket_one );
	}
	//==========================================================
	//==========================================================

	// Play the anim
	anim_node thread anim_single( script_models, explosion_anim );

	// Play Sounds
	//rocket_one PlaySound( "scn_rocket_lrgrocketexplo" );
	rocket_one StopLoopSound( "rocket_launch_loop" );
}

// FX and sound for for rocket 4
rocket_one_fx()
{
	level endon( "rocket_1_destroyed" );
	self playsound("rocket_launch_close"); //plays the rocket launching sequence sound

	//need to change once global waits are in
	wait ROCKET_1_LAUNCH_FX_DELAY;

	exploder("rocketlaunch01_base_smoke_jets");
	exploder("rocketlaunch01_base_sparkjets");
	
	wait 8;
	exploder("rocketlaunch01_jet_ignite");
	exploder("rocketlaunch01_prelaunch_light");
	wait 6;

	//exploder("rocketlaunch_exhaust_01");
	wait 5;

	PlayFXOnTag( level._effect[ "nx_smoke_rocket_afterburner_liftoff" ], self, "j_tag_booster" );

	wait 1;

	exploder("rocketlaunch01_blast");

	self playloopsound("rocket_launch_loop"); //looping rocket sound for when it goes in the air forever

	// Stop FX with:
	thread stop_rocket_one_prelaunch_fx_on_destroy( self );
	thread stop_rocket_one_afterburn_fx_on_destroy( self );
	thread stop_rocket_one_prelaunch_fx_on_wait();
}

stop_rocket_one_prelaunch_fx_on_destroy( rocket_one )
{
    level endon( "rocket_one_launching" );

    flag_Wait( "rocket_1_destroyed" );

	stop_exploder_nx( "rocketlaunch01_base_smoke_jets" );
	stop_exploder_nx( "rocketlaunch01_base_sparkjets" );
	stop_exploder_nx( "rocketlaunch01_jet_ignite" );
	stop_exploder_nx( "rocketlaunch01_prelaunch_light" );
	stop_exploder_nx( "rocketlaunch01_blast" );
	StopFXOnTag( level._effect[ "nx_smoke_rocket_afterburner_liftoff" ], rocket_one, "j_tag_booster" );
}

stop_rocket_one_prelaunch_fx_on_wait()
{
    level waittill( "rocket_one_launching" );

	stop_exploder_nx( "rocketlaunch01_base_smoke_jets" );
	stop_exploder_nx( "rocketlaunch01_base_sparkjets" );
	stop_exploder_nx( "rocketlaunch01_jet_ignite" );
	stop_exploder_nx( "rocketlaunch01_prelaunch_light" );
    wait 18;
	stop_exploder_nx( "rocketlaunch01_blast" );
}

stop_rocket_one_afterburn_fx_on_destroy( rocket_one )
{
    flag_Wait( "rocket_1_destroyed" );
	StopFXOnTag( level._effect[ "nx_smoke_rocket_afterburner_liftoff" ], rocket_one, "j_tag_booster" );
}


// Moves rocket 1 up out of its silo
move_rocket_one()
{
	flag_wait( "chopper_path_entering_base_alpha" );
	self thread move_gantry_inner_one();
	self thread move_gantry_outer_one();

	level.rocket_1_state = "rising";
	self moveto( self.origin + (0,0,(ROCKET_1_INITIAL_DEPTH * -1)), ROCKET_1_RISE_TIME );
	self waittill( "movedone" );
	//level notify( "rocket_1_done_moving" );
	level.rocket_1_state = "waiting";

	wait 1;
	thread animate_gantry_arms( "gantry_inner_1" );
}

gantry_setup_one()
{
	// Get all Ents in the Outer Gantry prefab
	gantry_parts = GetEntArray ("gantry_outer_1", "script_noteworthy");

	// Teleport them under ground
	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			part.origin =  ( part.origin + (0, 0, (ROCKET_1_INITIAL_DEPTH + 600)));
		}
	}

	// Get all Ents in the Inner Gantry prefab
	gantry_parts = GetEntArray ("gantry_inner_1", "script_noteworthy");

	// Teleport them under ground
	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			part.origin =  ( part.origin + (0, 0, ROCKET_1_INITIAL_DEPTH ));
		}
	} 
}

move_gantry_outer_one()
{
	// Get all Ents in the Gantry prefab
	gantry_parts = GetEntArray ("gantry_outer_1", "script_noteworthy");

	// Move them in sync with the rocket
	// But stop 600 units short, 5 seconds sooner
	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			part MoveTo( part.origin + (0, 0, ((ROCKET_1_INITIAL_DEPTH * -1) - 600)), (ROCKET_1_RISE_TIME - 5), 2, 2 );
		}
	}
}

move_gantry_inner_one()
{
	// Get all Ents in the Gantry prefab
	gantry_parts = GetEntArray ("gantry_inner_1", "script_noteworthy");

	// Move them in sync with the rocket
	// But stop them at a lower point
	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			part MoveTo( part.origin + (0, 0, (ROCKET_1_INITIAL_DEPTH * -1)), ROCKET_1_RISE_TIME, 2, 2 );
		}
	} 
}

animate_gantry_arms( gantry_script_noteworthy )
{
	gantry_arms_01 = undefined;
	gantry_arms_02 = undefined;
	gantry_hose_01 = undefined;
	anim_node = undefined;

	gantry_parts = GetEntArray ( gantry_script_noteworthy, "script_noteworthy");

	// Get the anim node
	foreach ( part in gantry_parts )
	{
		if( isDefined (part.targetname) && part.targetname == "vignette_gantry_arms_01" )
		{
			anim_node = part;
		}
	}

	// Get all the gantry arms
	foreach( part in gantry_parts )
	{
		if( isDefined (part.targetname) )
		{
			// Assign them their roles in the animation
			switch( part.targetname )
			{
				case "gantry_arms_01":
				gantry_arms_01 = part;
				gantry_arms_01 UseAnimTree( level._scr_animtree[ "gantry_arms_01" ] );
				gantry_arms_01.animname = "gantry_arms_01";
				break;
				case "gantry_arms_02":
				gantry_arms_02 = part;
				gantry_arms_02 UseAnimTree( level._scr_animtree[ "gantry_arms_02" ] );
				gantry_arms_02.animname = "gantry_arms_02";
				break;
				case "gantry_hose_01":
				gantry_hose_01 = part;
				gantry_hose_01 UseAnimTree( level._scr_animtree[ "gantry_hose_01" ] );
				gantry_hose_01.animname = "gantry_hose_01";
				break;
			}
		}
	}
	
	guys = [];
	guys["gantry_arms_01"] = gantry_arms_01;
	guys["gantry_arms_02"] = gantry_arms_02;
	guys["gantry_hose_01"] = gantry_hose_01;

	anim_node anim_single(guys, "gantry_arms_hose_01");
}

// Waits for a long time, then launches rocket 1
launch_rocket_one()
{
	flag_wait( "chopper_ride_starting_rocket_one_loop" );
	level thread maps\nx_rocket_util::launch_coutdown_logic( ROCKET_1_LAUNCH_DELAY, 1, "rocket_1_destroyed" );
	wait ROCKET_1_LAUNCH_DELAY;

	// Check to see if the rocket was popped before launching
	if( flag( "rocket_1_destroyed" ))
	{
		return;
	}

	level notify( "rocket_one_launching" );
	level.rocket_1_state = "launching";
	self moveto( self.origin + (0,0,ROCKET_1_LAUNCH_HEIGHT), ROCKET_1_LAUNCH_TIME, ROCKET_1_LAUNCH_TIME/2 );

	self thread notify_on_launch();

	// When the rocket gets destroyed, cancel the launch with a small move
	level waittill( "rocket_1_destroyed" );
	self moveto( self.origin + (0,0,1), 1 );
}

notify_on_launch()
{
	self waittill( "movedone" );
	level notify( "rocket_one_done_launching" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Dialogue for this section
base_alpha_dialogue()
{
	baker = level.squad[ "ALLY_BAKER" ];
	jenkins = level.squad[ "ALLY_JENKINS" ];
	williams = level.squad[ "ALLY_WILLIAMS" ];

	//Approaching target point Alpha. 
	level thread play_dialogue( "roc_ded1_alpha_approachingalpha", 0.1 );
	//Deadeye, do you have a visual on the target?
	level thread play_dialogue( "roc_dra_alpha_doyouhaveavisual", 2.4 );
	//That's affirmative. We have eyes on candlestick 1. 
	level thread play_dialogue( "roc_ded1_alpha_eyesoncandlestick1", 6.4 );
	//Engage all ground targets!
	baker thread play_dialogue( "roc_bak_alpha_engagegroundtargets", 11.2 );
	//Glassing multiple AV's inbound, north side of the gantry.
	level thread play_dialogue( "roc_ded3_alpha_glassingmultavs", 16.1 );

	//EC Gunship, lifting off at 2 o'clock.
	baker thread play_dialogue( "roc_bak_alpha_gunshipat2oclock", 19.1 );

	//Alpha, to be played at a lull, when player sees gantry rising up, after little bird crashes into bunker but before railgun vo:
	baker thread play_dialogue( "roc_bak_alpha_gantrymovingtolaunch", 30.1 );

	//Crossbow, you are clear to engage. 
	level thread play_dialogue( "roc_dra_alpha_xbowcleartoengage", 45.1 );
	//Copy, Dragon. This is Lincoln fire control, standing by for fire mission.
	level thread play_dialogue( "roc_cro_alpha_lincolnfirecontrol", 48.2 );

	flag_wait( "rocket_1_destroyed" );
	//Ordnance On target. 
	baker thread play_dialogue( "roc_bak_alpha_niceshot", 3.8 );
//  //BDA is 1 for 1.  Kill confirmed.
//  baker thread play_dialogue( "roc_bak_alpha_bda1for1", 2.3 );
	//Deadeye, engage EC column oscar mike in grid square 3-6 Actual. 
	level thread play_dialogue( "roc_dra_alpha_engagein36actual", 21.2 );
	//Copy that, Dragon. Bugging out.
	level thread play_dialogue( "roc_ded1_alpha_copybuggingout", 27.0 );



/*
	// ALL RAILGUN VO IS DONE IN NX_ROCKET_RAILGUN. NOT SURE WHAT TO DO HERE

	//Target link active.
	level thread play_dialogue( "roc_cro_alpha_linkactive", 53.3 );
	level waittill( "railgun_fired" );
	//Target is lit.
	level thread play_dialogue( "roc_cro_delta_targetislit", 56 );
	//Fire mission confirmed. Firing for effect.
	level thread play_dialogue( "roc_cro_alpha_firemissionconfirmed", 57.4 );
	//TTI 3 seconds
	level thread play_dialogue( "roc_cro_alpha_tti3sec", 61.2 );
	//2, 1…  Splash.
	level thread play_dialogue( "roc_cro_alpha_21splash", 64.1 );
*/



//    //thread add_dialogue_line( "Baker", "Dragon 1-5, this is Deadeye 2-1.  We are in objective grid Uniform.", "w" );
////  maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_bak_alpha_objgriduniform" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_alpha_objgriduniform" );
//
//    //thread add_dialogue_line( "Baker", "Objective Alpha-two in sight.", "w" );
////  maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_bak_alpha_alpha2insight" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_alpha_alpha2insight" );
//
//    /*
//    //thread add_dialogue_line( "Command", "Roger that. Copy all.", "w" );
//    maps\nx_rocket_util::wait_play_dialogue_wait( 0.5, "roc_cmd_alpha_rogercopyall" );
//    */
//
//    //thread add_dialogue_line( "Baker", "Deadeye 2-4 is hit!  I repeat Deadeye 2-4 is going down!", "w" );
////  maps\nx_rocket_util::wait_play_dialogue_wait( 0.5, "roc_bak_alpha_deadeyehit" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_alpha_deadeyehit", 0.5 );
//
//    //thread add_dialogue_line( "Baker", "Engage all ground targets!!", "w" );
////  maps\nx_rocket_util::wait_play_dialogue_wait( 1, "roc_bak_alpha_engageground" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_alpha_engageground", 1 );
//
//    // Bunker encounter
//    flag_wait( "chopper_path_alpha_bunkers" );
//    //thread add_dialogue_line( "Baker", "Foot mobiles on the bunkers!", "w" );
////  maps\nx_rocket_util::wait_play_dialogue_wait( 1, "roc_bak_alpha_mobilesonbunkers" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_alpha_mobilesonbunkers", 1 );
//
//    flag_wait( "chopper_ride_tunnel_humvee_go" );
//    //thread add_dialogue_line( "Baker", "Targets in the open!", "w" );
////  maps\nx_rocket_util::wait_play_dialogue_wait( 1, "roc_bak_alpha_tangosopen" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_alpha_tangosopen", 1 );
//
//    // Starting the rocket loop
//    flag_wait( "chopper_ride_starting_rocket_one_loop" );
//    //thread add_dialogue_line( "Command", "Deadeye 2-1, this is Dragon 1-5, railguns are online.", "w" );
//    maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_cmd_alpha_railgunsonline" );
//
//    //thread add_dialogue_line( "Command", "Continue to circle the objective until it is destroyed. Over.", "w" );
//    maps\nx_rocket_util::wait_play_dialogue_wait( 0.4, "roc_cmd_alpha_circleobjective" );
//
//    //thread add_dialogue_line( "Baker", "Paint a target on that rocket!", "w" );
//    //maps\nx_rocket_util::wait_play_dialogue_wait( 2.0, "roc_bak_alpha_paintrocket" );
//
//
//    // On Fire
//    //level waittill( "railgun_fired" );
//    //thread add_dialogue_line( "Baker", "This is deadeye 2-1, fire for effect. MOE rails, 1 round. On my lase. Authenticate Over.", "w" );
//    //wait 3.0;
//    //thread add_dialogue_line( "Command", "This is dragon 1-5, copy all, I authenticate. Rail out, TOT one zero seconds.", "w" );
//
//
//    // On Hit
//    flag_wait( "rocket_1_destroyed" );
//    wait 2.5;
//
////  maps\nx_rocket_util::wait_play_dialogue_wait( 0.5, "roc_bak_alpha_niceshot" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_alpha_niceshot", 0.5 );
//
//    //thread add_dialogue_line( "Baker", "Let's keep moving.", "w" );
////  maps\nx_rocket_util::wait_play_dialogue_wait( 1.0, "roc_bak_alpha_keepmoving" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_alpha_keepmoving", 1 );
//
//    //thread add_dialogue_line( "Baker", "Roger that, en route to target site Bravo. Hang on.", "w" );
////  maps\nx_rocket_util::wait_play_dialogue_wait( 1.2, "roc_bak_alpha_enroutebravo" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_alpha_enroutebravo", 1.2 );
}

/*
railgun_fire_nag_loop()
{
	level endon();

	while( true )
	{
	}
}
*/


// Warn the player that the rocket is taking off
base_alpha_dialogue_launch()
{
	level endon( "rocket_1_destroyed" );

	level waittill( "rocket_one_launching" );

	// Baker: "It's taking off!  Get a rail shot on it NOW!"
//  maps\nx_rocket_util::wait_play_dialogue_wait( 2.2, "roc_bak_alpha_railshotnow" );
	level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_alpha_railshotnow", 2.2 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Chopper finishes rocket one section and continues to bridge section
// JR - Needs to be updated with infinite loop and smart exit
chopper_transition_to_bridge()
{
	//iprintln( "waiting for transition to bridge" );

	// Wait untill it enters bridge area
	//flag_wait( "chopper_transition_two" );
	level waittill( "rocket_1_destroyed" );

	// Disable railgun usage
	maps\nx_rocket_railgun::disable_railgun();

	// Dont exit the area unless we hit the exit_ok node.
	// This ensures the player has plenty of time to see the rocket
	// explosion before leaving the area
	while( 1 )
	{
		if( flag( "chopper_ride_exit_ok" ))
		{
			break;
		}
		wait 1;
	}

	// After the player hits the exit_ok node, wait for the actual exit_node.
	while( 1 )
	{
		if( flag( "chopper_ride_exit_node" ))
		{
			break;
		}
		wait 1;
	}

	AssertEx( IsDefined( level.playerHeli ), "Tried to transition chopper when level.playerHeli does not exist" );

	// Get rid of old path
	level.playerHeli thread vehicle_detachfrompath();

	// Get the new path
	transition_node = getstruct( "chopper_transition_node_two", "targetname" );

	// Use new patch
	level.playerHeli.currentnode = transition_node;


	// Continue on new path
	level.playerHeli thread vehicle_resumepath();
	level.playerHeli GoPath();

	// Reset chopper agility settings
	level.playerHeli SetMaxPitchRoll( 15, 15 );
	level.playerHeli SetYawSpeed( 140, 55, 30, 0 );

	//temp music_chk flag
	flag_set( "music_chk_bridge" );

	// Set the current area
	level.current_area = "bridge";
}

// Delete all the base alpha objects after the player leaves the area
cleanup_base_alpha_ents()
{
	//iprintln( "base alpha cleanup" );

	// actor cleanup should be done by the cleanup volumes
	maps\nx_rocket_util::safe_delete_array( level.base_alpha_guys_1 );
	maps\nx_rocket_util::safe_delete_array( level.base_alpha_guys_2 );
	maps\nx_rocket_util::safe_delete_array( level.base_alpha_guys_3 );
	maps\nx_rocket_util::safe_delete_array( level.base_alpha_guys_4 );

	//maps\nx_rocket_util::safe_delete_array( level.base_alpha_vehicles_static );
	maps\nx_rocket_util::safe_delete_array( level.base_alpha_vehicles_pathing );

	// Ground vehicles
	maps\nx_rocket_util::safe_delete( level.garage_apc );
	maps\nx_rocket_util::safe_delete( level.tunnel_humvee );

	// Allied choppers
	maps\nx_rocket_util::safe_delete( level.intro_ally_1 );
	maps\nx_rocket_util::safe_delete( level.intro_ally_2 );

	// SAM Turrets
	maps\nx_rocket_util::safe_delete_array( level.alpha_sam_turrets );

	maps\nx_rocket_util::safe_delete( level.alpha_littlebird_01 );
	maps\nx_rocket_util::safe_delete( level.alpha_littlebird_02 );
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Checks for damage on self ( a rocket ), and triggers an exploder
rocket_exploder_logic( rocket_number )
{
	self setCanDamage( true );

	while( true )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, damageType, modelName, tagName );

		if( damage >= 4000 && damagetype == "MOD_GRENADE" )
		{
			// Create a notify message for this rocket
			event_string = "rocket_" + rocket_number + "_destroyed";

			// Notify
			level notify( event_string );
			flag_set( event_string );

			// Trigger this rockets exploder
			// JR - This is a hack to turn off the exploder on rocket 1
			// since it has its own unique explosion anim now
			//if( rocket_number != 1 )
			//{
				//Exploder( self.script_parameters );
			//}

			self PlaySound( "nx_rocket_explosion" );

			// TEMP WAY OF GETTING VO TO PLAY DURING/AFTER LOCK-ON. 
			// thread maps\nx_rocket_railgun::sound_railgun_hit_vo();

			// Spawn a new rocket with the same trajectory
			// JR FIX ME - This is a hack, find a better solution - FIX ME
			if( isDefined( level.active_rail_shot ))
			{
				missile_angles = level.active_rail_shot.angles;
				forward = anglestoforward( missile_angles );
				//MagicBullet( "nx_rocket_railgun_secondary", self.origin, self.origin + forward );
				if (rocket_number == 2)
				{
					MagicBullet( "nx_rocket_railgun_secondary", level.active_rail_shot.origin + ( 2000 * forward ), level.active_rail_shot.origin + ( 2100 * forward ) );
				}
				else
				{
					MagicBullet( "nx_rocket_railgun_secondary", level.active_rail_shot.origin + ( 600 * forward ), level.active_rail_shot.origin + ( 700 * forward ) );
				}
			}
		}
	}
}



railgun_damage_watcher()
{
	// Bunker 1
	//thread railgun_damage_bunker_1();

	// Bunker 2
	//thread railgun_damage_bunker_2();
}

// Bunker 1 - The C shaped bunker
railgun_damage_bunker_1()
{
	flag_wait( "base_alpha_bunker_1_exploder_triggered" );
	//iprintlnbold( "Bunker 1 destroyed" );
}

// Bunker 2 - the small square bunker
railgun_damage_bunker_2()
{
	flag_wait( "base_alpha_bunker_2_exploder_triggered" );
	//iprintlnbold( "Bunker 2 destroyed" );
}


// Used for hint strings
// Returns false untill player turns on railgun for the first time
hint_railgun_activate()
{
	return flag( "player_activated_railgun" );
}

// Used for hint strings
// Returns false untill player uses railgun for the first time
hint_railgun_lock()
{
	return flag( "player_used_railgun" );
}
