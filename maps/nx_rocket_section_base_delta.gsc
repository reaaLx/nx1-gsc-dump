
//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_ROCKET_SECTION_BASE_DELTA									**
//                                                                          **
//    Created: 7/13/2011 - Justin Rote										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

ROCKET_2_INITIAL_DEPTH = -6000;	// How deep underground rocket 2 starts
ROCKET_2_RISE_DELAY = 10;		// Delay before it starts rising
ROCKET_2_RISE_TIME = 75;		// How long it takes for rocket 2 to emerge
ROCKET_2_LAUNCH_FX_DELAY = 2;	   // Delay untill prelaunch FX start
ROCKET_2_LAUNCH_DELAY = 27;	   // Initial delay before it launches
ROCKET_2_LAUNCH_HEIGHT = 16000; // How high it launches into the air
ROCKET_2_LAUNCH_TIME = 18;		// How long it takes to launch ( effects upward speed )

ROCKET_3_INITIAL_DEPTH = -3000; // How deep underground rocket 3 starts
ROCKET_3_RISE_DELAY = 0;		// How long it takes for rocket 3 to emerge
ROCKET_3_RISE_TIME = 30;		// How it takes to rise ( effects rise speed )
ROCKET_3_LAUNCH_DELAY = 62;	   // Initial delay before it launches
ROCKET_3_LAUNCH_FX_DELAY = 2;	   // Delay untill prelaunch FX start
ROCKET_3_LAUNCH_HEIGHT = 16000; // How high it launches into the air
ROCKET_3_LAUNCH_TIME = 18;		// How long it takes to launch ( effects upward speed )

ROCKET_4_INITIAL_DEPTH = -1660;	// How deep underground rocket 4 starts
ROCKET_4_RISE_DELAY = 0;		// How long it takes for rocket 4 to emerge
ROCKET_4_RISE_TIME = 20;		// How it takes to rise ( effects rise speed )
ROCKET_4_FX_DELAY = 16;			// Delay before FX start
ROCKET_4_LAUNCH_DELAY = 28;	   // Initial delay before it launches
ROCKET_4_LAUNCH_HEIGHT = 16000; // How high it launches into the air
ROCKET_4_LAUNCH_TIME = 18;		// How long it takes to launch ( effects upward speed )


//*******************************************************************
//                                                                  *
//	BASE DELTA - Valley with 3 rockets								*
//                                                                  *
//*******************************************************************
start()
{
	maps\nx_rocket_section_intro::start_railgun_ride( "heli_start_ride_p3", "gameplay" );
	maps\nx_rocket_fx::fx_vision_fog_init();
	maps\nx_rocket_fx::set_vision_and_fog("bridge", 0); // force it to bridge, as we haven't hit the trigger for delta yet

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
	thread maps\nx_rocket_fx::rocket_introfx_cleanup_delta();
	thread maps\nx_rocket_fx::rocket02_gantrylights_fx();
	thread maps\nx_rocket_fx::rocket03_gantrylights_fx();
	thread maps\nx_rocket_fx::rocket04_gantrylights_fx();
	thread setup_rocket_exploders();

	level.playerHeli thread chopper_path_base_delta();


	flag_wait( "flag_entered_base_delta" );
	level.playerHeli thread base_delta_dialogue();

	// Make sure player's chopper doesnt die
	level.playerHeli godon();

	//==========================
	// SETUP RAILGUN TARGETS
	//==========================
	// Setup rocket targets
	level.base_delta_rockets = GetEntArray( "railgun_rocket_delta_target", "targetname" );
	level.base_delta_rocket_2 = GetEnt( "rocketexplode_02", "script_noteworthy" );
	level.base_delta_rocket_3 = GetEnt( "rocketexplode_03", "script_noteworthy" );
	level.base_delta_rocket_4 = GetEnt( "rocketexplode_04", "script_noteworthy" );

	// Setup spawn funcs for enemy APCs that fire their turrets
	ally_copters = [ level.delta_looping_chopper_1, level.delta_looping_chopper_2, level.delta_looping_chopper_3 ];
	array_spawn_function_noteworthy( "delta_shooting_apc", maps\nx_rocket_util::apc_turret_logic, level.playerHeli, ally_copters );
	//level.playerHeli thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_left_delta", level.delta_shooting_apcs );

	thread maps\nx_rocket_section_intro::allies_choose_targets( ally_copters );
	
	wait 0.05; 
	// Spawn stationary ground vehicles
	level.base_delta_vehicles_static = spawn_vehicles_from_targetname( "base_delta_vehicles_static" );
	level.playerHeli thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_left_delta", level.base_delta_vehicles_static );
	wait 0.05; 

	// Turn off red boxes on parked BTRs
	thread disable_threat_box_on_vehicles( level.base_delta_vehicles_static );


	//==========================
	//==========================

	// Set the current area
	level.current_area = "base_delta";

	// Watch for rocket destruction
	thread watch_for_rocket_destruction();

	// Start rocket launch animations and FX
	thread rocket_two_anim();
	thread rocket_three_anim();
	thread rocket_four_anim();

	//play launch PA SFX
	level thread maps\nx_rocket_audio::base_delta_countdown_sfx();


	// Spawn looping chopper allies
	level.delta_looping_chopper_1 = spawn_vehicle_from_targetname_and_drive( "base_delta_loop_ally_1" );
	level.delta_looping_chopper_2 = spawn_vehicle_from_targetname_and_drive( "base_delta_loop_ally_2" );
	level.delta_looping_chopper_3 = spawn_vehicle_from_targetname_and_drive( "base_delta_loop_ally_3" );

	// Reduce ally chopper accuracy
	level.delta_looping_chopper_1 thread maps\nx_rocket_util::set_ally_chopper_spread( 8 );
	level.delta_looping_chopper_2 thread maps\nx_rocket_util::set_ally_chopper_spread( 8 );
	level.delta_looping_chopper_3 thread maps\nx_rocket_util::set_ally_chopper_spread( 8 );

	// Make allies more agile
	level.delta_looping_chopper_1 SetMaxPitchRoll( 50, 50 );
	level.delta_looping_chopper_2 SetMaxPitchRoll( 50, 50 );
	level.delta_looping_chopper_3 SetMaxPitchRoll( 50, 50 );

	flag_wait( "base_delta_destroyed" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
section_precache()
{
}


section_flag_inits()
{
	flag_init( "rocket_2_destroyed" );
	flag_init( "rocket_3_destroyed" );
	flag_init( "rocket_4_destroyed" );
	flag_init( "base_delta_destroyed" );
}


// Creates the damage detectors for each of the 4 rockets
setup_rocket_exploders()
{
	// ALPHA 1
	damage_detector = GetEnt( "damage_detector_r1", "script_noteworthy" );
	damage_detector thread maps\nx_rocket_section_base_alpha::rocket_exploder_logic( 1 );

	// DELTA 2
	damage_detector = GetEnt( "damage_detector_r2", "script_noteworthy" );
	damage_detector thread maps\nx_rocket_section_base_alpha::rocket_exploder_logic( 2 );

	// DELTA 3
	damage_detector = GetEnt( "damage_detector_r3", "script_noteworthy" );
	damage_detector thread maps\nx_rocket_section_base_alpha::rocket_exploder_logic( 3 );

	// DELTA 4
	damage_detector = GetEnt( "damage_detector_r4", "script_noteworthy" );
	damage_detector thread maps\nx_rocket_section_base_alpha::rocket_exploder_logic( 4 );
}


// Dialogue for this section
base_delta_dialogue()
{
	baker = level.squad[ "ALLY_BAKER" ];
	jenkins = level.squad[ "ALLY_JENKINS" ];
	williams = level.squad[ "ALLY_WILLIAMS" ];

	//Wilco, Dragon. Switchblade en route to target.
	level thread play_dialogue( "roc_swi_bridge_eyeson3rockets", 0 );
	//Copy Switchblade.  Go for IR scan
	level thread play_dialogue( "roc_dra_bridge_copyswbladeirscan", 3.2 );
	//IR scan shows heat blooms in Stage 1 boosters.  Candles are lit! Repeat, candles are lit! 
	level thread play_dialogue( "roc_swi_bridge_candlesarelit", 7.1 );
	//Deadeye 1, proceed to target point Delta at maximum speed!
	level thread play_dialogue( "roc_dra_bridge_ded1proceedtodelta", 13 );
	//Copy that, Dragon.  We're on it.
	level thread play_dialogue( "roc_ded1_bridge_copywereonit", 17.1 );
//  //Guns up, Zulu. They know we're coming!
//  baker thread play_dialogue( "roc_bak_delta_gunsup", 18.9 );

	// Before first rocket launch - 
	level thread play_dialogue( "roc_dra_delta_donotallowrockets", 34.0 );

	flag_wait( "rocket_4_destroyed" );
	//BDA is 1 for 1.  Kill confirmed.
	baker thread play_dialogue( "roc_bak_alpha_bda1for1", 3.0 );

	// After destruction of Delta rocket 1 
	level thread play_dialogue( "roc_dra_delta_proceedtosecond", 5.8 );

	// After VTOL is down, just before targeting Rocket 2  
	level thread play_dialogue( "roc_dra_delta_airbornin10sec", 9.2 );

	level waittill( "chopper_dogfight_base_delta_01_anim_started" );	
	// When circling the Rocket and chasing the VTOL - 
	level thread play_dialogue( "roc_ded1_bridge_ded3breakleft", 2.0 );
	level thread play_dialogue( "roc_ded1_bridge_countermeasures", 8.0 );

	level waittill( "chopper_dogfight_base_delta_01_anim_done" );
	level thread play_dialogue( "roc_ded4_alpha_goodkill", 0.5 );

	flag_wait( "rocket_3_destroyed" );
	// After confirm kill on Rocket 2 
	level thread play_dialogue( "roc_dra_delta_outoftime", 6.0 );
	// As we're bringing it into view
	level thread play_dialogue( "roc_dra_delta_targetcandlestick3", 12.0 );

	flag_wait( "rocket_2_destroyed" );
	baker thread play_dialogue( "roc_bak_delta_ontarget", 0.4 );
	// As we're bringing it into view	
	baker thread play_dialogue( "roc_bak_delta_strkmissioncomplete", 4.0 );
	level thread play_dialogue( "roc_dra_delta_outstandingstandby", 8.0 );

//    self waittill( "chopper_path_approaching_1st_bunker" );
//    // Baker: "Tangos in the open!"
////  maps\nx_rocket_util::wait_play_dialogue_wait( 1.5, "roc_bak_alpha_tangosopen" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_alpha_tangosopen", 1.5 );
//
//    self waittill( "chopper_path_1st_bunker_1" );
//    // Baker: "The North-East rocket is launching!"
////  maps\nx_rocket_util::wait_play_dialogue_wait( 1.5, "roc_bak_delta_nerocketlaunching" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_delta_nerocketlaunching", 1.5 );
//
//    self waittill( "chopper_path_approach_2nd_bunker_2" );
//    // Baker: "Tangos on the bunker!"
////  maps\nx_rocket_util::wait_play_dialogue_wait( 1.5, "roc_bak_alpha_tangosbunker" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_alpha_tangosbunker", 1.5 );
//
//    //self waittill( "chopper_path_behind_rocket_4_2" );
//    // Baker: "Paint the target now!"
//    //maps\nx_rocket_util::wait_play_dialogue_wait( 3, "roc_bak_alpha_painttargetnow" );
//
//    self waittill( "chopper_path_terrace_1" );
//    // Baker: "Tangos on the terrace, waste em!"
////  maps\nx_rocket_util::wait_play_dialogue_wait( 1, "roc_bak_alpha_tangosopen" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_alpha_tangosopen", 1 );
//
//    //self waittill( "chopper_path_terrace_3" );
//    //wait 3.0;
//    //thread add_dialogue_line( "Baker", "Enemy choppers incoming!!", "w" );
//
//    //self waittill( "chopper_path_rocket_3_2" );
//    // Baker: "We have a window, target the rocket!"
//    //maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_bak_delta_window" );
//
//    // Baker: "Paint the rocket!"
//    //maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_bak_delta_paintrocket" );
//
//    //self waittill( "chopper_path_leaving_rocket_3" );
//    //wait 1.0;
//    //thread add_dialogue_line( "Baker", "Be advised more targets spotted on the roofs", "w" );
//
//    self waittill( "chopper_path_rocket_2_1" );
//    // Baker: "The rocket is launching!  Climb! Climb!"
////  maps\nx_rocket_util::wait_play_dialogue_wait( 1, "roc_bak_delta_climb" );
//    level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_delta_climb", 1 );
//
//    //self waittill( "chopper_path_rocket_2_3" );
//    //thread add_dialogue_line( "Baker", "Enemy VTOL!", "w" );
//
//    //self waittill( "chopper_path_rocket_2_3" );
//    // Baker: "Get a laze on that rocket now!!"
//    //maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_bak_alpha_railshotnow" );
}



//*******************************************************************
//                                                                  *
// MAIN CHOPPER LOGIC SCRIPT										*
//                                                                  *
//*******************************************************************
// Self = player chopper
chopper_path_base_delta()
{
	//==========================
	// Pre-Intro
	//==========================
	flag_wait( "flag_approach_base_delta" );

	// Spawn a small convoy driving to first bunker
	// level.base_delta_intro_path_vehicles = spawn_vehicles_from_targetname_and_drive( "delta_intro_path_vehicles" );
	//maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( level.base_delta_intro_path_vehicles );
	//level thread maps\nx_rocket_util::handle_caravan_stopping( level.base_delta_intro_path_vehicles, "chopper_path_approach_2nd_bunker_2" );

	// JR - Removed for better reveal
	//level.base_delta_intro_path_vehicles = maps\nx_rocket_util::caravan_setup( "delta_intro_path_vehicles_" );
	//self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_approach_2nd_bunker_2", level.base_delta_intro_path_vehicles );
	//thread disable_threat_box_on_vehicles( level.base_delta_intro_path_vehicles );

	// Spawn allied chopper to fly by
	level.base_delta_intro_chopper_1 = spawn_vehicle_from_targetname_and_drive( "base_delta_intro_ally_1" );
	level.base_delta_intro_chopper_1 thread maps\nx_rocket_util::set_ally_chopper_spread( 8 );
	level.base_delta_intro_chopper_1 SetMaxPitchRoll( 25, 25 );

	level.base_delta_intro_chopper_2 = spawn_vehicle_from_targetname_and_drive( "base_delta_intro_ally_2" );
	level.base_delta_intro_chopper_2 thread maps\nx_rocket_util::set_ally_chopper_spread( 8 );
	level.base_delta_intro_chopper_2 SetMaxPitchRoll( 25, 25 );


	//==========================
	// Intro
	//==========================
	flag_wait( "flag_entered_base_delta" );

	self thread railgun_window_controller();
	self SetMaxPitchRoll( 25, 25 );


	//==========================
	// First bunker
	//==========================

	wait 1.0;

	// Spawn some guys on and around the first bunkers
	array_spawn_function_targetname("base_delta_first_bunker_guys", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.base_delta_first_bunker_guys = maps\nx_rocket_util::spawn_guys_from_targetname( "base_delta_first_bunker_guys" );
	self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_approach_2nd_bunker_2", level.base_delta_first_bunker_guys );

	wait 1.0;

	// Spawn runner drones
	self thread start_drone_pack( "drones_delta_bunker_1", 		5, 10, "chopper_path_approach_2nd_bunker_2" );
	self thread start_drone_pack( "drones_delta_bunker_1_2",	6, 14, "chopper_path_approach_2nd_bunker_2" );
	self thread start_drone_pack( "drones_delta_road_1",		20, 22, "chopper_path_approach_2nd_bunker_2" );

	wait 1.0;

	// SAM Turrets
	//iprintln( "spawning SAMs" );
	level.delta_sam_sites = [];
	level.delta_sam_sites [ level.delta_sam_sites.size ] = thread sam_turret_init ("base_delta_sam_turret_2", "chopper_path_approaching_1st_bunker"); 
	level.delta_sam_sites [ level.delta_sam_sites.size ] = thread sam_turret_init ("base_delta_sam_turret_4", "chopper_path_approach_2nd_bunker_2"); 
	level.delta_sam_sites [ level.delta_sam_sites.size ] = thread sam_turret_init ("base_delta_sam_turret_3", "chopper_path_terrace_1"); 

	self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_left_delta", level.delta_sam_sites );

	self waittill( "chopper_path_1st_bunker_1" );
	self SetMaxPitchRoll( 10, 10 );
	self thread do_bunker_1_runners();


	//==========================
	// Road to Second bunker
	//==========================
	self waittill( "chopper_path_1st_bunker_2" );

	self SetMaxPitchRoll( 25, 25 );

	// Spawn a small moving convoy on the road
	// These vehicles delete themselves at the end of their path
	level.base_delta_road_to_2nd_bunker_vehicles = spawn_vehicles_from_targetname_and_drive( "delta_road_to_2nd_bunker_vehicles" );
	level.blackhawk_targets = level.base_delta_road_to_2nd_bunker_vehicles;
	//maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( level.base_delta_road_to_2nd_bunker_vehicles );
	// No delete needed, these have a self cleanup KVP set

	//==========================
	// Second bunker
	//==========================
	self waittill( "chopper_path_approach_2nd_bunker_1" );

	// JR - Turning these off
	//level.base_delta_second_buker_hummers = self thread spawn_vehicles_from_targetname_and_drive( "delta_4_path_vehicles" );
	//self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_terrace_1", level.base_delta_second_buker_hummers );

	// Spawn runner drones
	self thread start_drone_pack( "drones_delta_bunker_2_1", 5, 10, "chopper_path_at_2nd_bunker_1" );
	self thread start_drone_pack( "drones_delta_bunker_2_2", 6, 10, "chopper_path_behind_rocket_4_2" );
	self thread start_drone_pack( "drones_delta_bunker_2_3", 6, 10, "chopper_path_behind_rocket_4_2" );

	wait 1.0;

	// Littlebird fodder flyby
	level.base_delta_littlebird_fodder_1 = spawn_vehicles_from_targetname_and_drive( "delta_littlebird_fodder_1" );

	level.base_delta_littlebird_fodder_1[0] thread maps\nx_rocket_audio::rocket_air_vehicle_flyby_sfx("rocket_heli_flyby_01", 2.22);
	level.base_delta_littlebird_fodder_1[1] thread maps\nx_rocket_audio::rocket_air_vehicle_flyby_sfx("rocket_heli_flyby_02", 3.12);

	level.base_delta_littlebird_fodder_1[0] thread littlebird_fodder_1_0_attack( level.playerHeli );
	level.base_delta_littlebird_fodder_1[1] thread littlebird_fodder_1_0_attack( level.playerHeli );

	//maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( level.base_delta_littlebird_fodder_1 );
	self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_at_2nd_bunker_1", level.base_delta_littlebird_fodder_1 );



	self waittill( "chopper_path_approach_2nd_bunker_2" );

	// Spawn some guys in the bunker 2 area
	array_spawn_function_targetname("base_delta_second_bunker_guys", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.base_delta_second_bunker_guys = maps\nx_rocket_util::spawn_guys_from_targetname( "base_delta_second_bunker_guys" );
	self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_behind_rocket_4_2", level.base_delta_second_bunker_guys );

	self thread do_bunker_2_runners_1();
	self thread do_bunker_2_runners_2();
	//self thread do_bunker_2_runners_3();

	self waittill( "chopper_path_at_2nd_bunker_1" );
	self SetMaxPitchRoll( 10, 10 );

	self waittill( "chopper_path_at_2nd_bunker_3" );
	self SetMaxPitchRoll( 15, 15 );

	// Start Ally 4 and 5
	level.delta_looping_chopper_4 = spawn_vehicle_from_targetname_and_drive( "base_delta_loop_ally_4" );
	level.delta_looping_chopper_4 thread maps\nx_rocket_util::set_ally_chopper_spread( 8 );
	level.delta_looping_chopper_4 SetMaxPitchRoll( 50, 50 );
	level.delta_looping_chopper_5 = spawn_vehicle_from_targetname_and_drive( "base_delta_loop_ally_5" );
	level.delta_looping_chopper_5 thread maps\nx_rocket_util::set_ally_chopper_spread( 8 );
	level.delta_looping_chopper_5 SetMaxPitchRoll( 50, 50 );

	// Kick off some drones
	self thread start_drone_pack( "drones_delta_bunker_3_1", 2, 8, "chopper_path_behind_rocket_4_3" );

	//==========================
	// Blow up the Rocket
	//==========================
	//self waittill( "chopper_path_delta_window_1_open" );
	//self waittill( "chopper_path_behind_rocket_4_1" );


	//==========================
	// Littlebird flyby 2 
	//==========================
	self waittill( "chopper_path_behind_rocket_4_3" );
	level.base_delta_littlebird_fodder_2 = spawn_vehicles_from_targetname_and_drive( "delta_littlebird_fodder_2" );
	//maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( level.base_delta_littlebird_fodder_2 );
	level.base_delta_chase_ally_1 = spawn_vehicle_from_targetname_and_drive( "base_delta_chase_ally_1" );
	level.base_delta_chase_ally_1 SetMaxPitchRoll( 25, 25 );
	level.base_delta_chase_ally_1 godon();

	level.base_delta_littlebird_fodder_2[0] thread littlebird_fodder_2_0_attack( level.base_delta_chase_ally_1 );
	level.base_delta_littlebird_fodder_2[0] thread maps\nx_rocket_audio::rocket_air_vehicle_flyby_sfx("rocket_heli_flyby_04", 0 );
	level.base_delta_littlebird_fodder_2[1] thread littlebird_fodder_2_1_attack( level.base_delta_chase_ally_1 );
	level.base_delta_littlebird_fodder_2[1] thread maps\nx_rocket_audio::rocket_air_vehicle_flyby_sfx("rocket_heli_flyby_05", 1.5 );

	// Cleanup for the fodder choppers
	self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_rocket_3_1", level.base_delta_littlebird_fodder_2 );


	//==========================
	// Terrace / Rocket Three
	//==========================
	self waittill( "chopper_path_approach_terrace" );
	level.base_delta_terrace_path_vehicles = self thread spawn_vehicles_from_targetname_and_drive( "delta_terrace_path_vehicles" );
	self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_rocket_2_3", level.base_delta_terrace_path_vehicles );
	level.blackhawk_targets = array_combine( level.blackhawk_targets, level.base_delta_terrace_path_vehicles );

	level.base_delta_r3_vehicles = spawn_vehicles_from_targetname_and_drive( "delta_r3_path_vehicles" );
	self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_approaching_rocket_2", level.base_delta_r3_vehicles );
	level.blackhawk_targets = array_combine( level.blackhawk_targets, level.base_delta_terrace_path_vehicles );

	// Spawn some trucks going down the hill.

	// Spawn some guys on the terrace
	//array_spawn_function_targetname("base_delta_terrace_guys", maps\nx_rocket_util::protect_player_helicopter_rear );
	//level.base_delta_terrace_guys = maps\nx_rocket_util::spawn_guys_from_targetname( "base_delta_terrace_guys" );
	//self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_rocket_3_1", level.base_delta_terrace_guys );

	// Spawn some pathing vehicles in the rocket 3 area
	self waittill( "chopper_path_terrace_1" );

	// Kick off some drones
	self thread start_drone_pack( "drones_delta_bunker_4_1", 5, 10, "chopper_path_rocket_3_6" );

	//==========================
	// Rocket Three
	//==========================

	// Spawn some guys on the rocket 3 bunkers
	array_spawn_function_targetname("base_delta_rocket_3_guys", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.base_delta_rocket_3_guys = maps\nx_rocket_util::spawn_guys_from_targetname( "base_delta_rocket_3_guys" );
	self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_approaching_rocket_2", level.base_delta_rocket_3_guys );


	// ****************
	//  ANIM GOES HERE
	// ****************
	level waittill( "chopper_dogfight_base_delta_01_anim_started" );

	// Turn on new ground reference ent.
	//iprintln( "Start ground ref ent" );
	//level._player_ground_origin = spawn_tag_origin();
	//level._player_ground_origin LinkTo( level.playerHeli, "tag_player" );
	//level._player_ground_origin PlayerSetGroundReferenceEnt( level._player_ground_origin );


	wait 12;
	level.dogfight_01_vtol godoff();
	level.dogfight_01_vtol.health = 25000;
	level.dogfight_01_vtol thread maps\_nx_chinese_vtol_low::playDamageEffects( 24999, 2 );
	level.dogfight_01_ally godoff();


	level waittill( "chopper_dogfight_base_delta_01_anim_done" );

	// Teleport player chopper to end of anim
	level.playerHeli maps\nx_rocket_util::transition_chopper_to_new_path_noteworthy( "dogfight_01_resume_node" );

	// Teleport VTOL to new path
	level.dogfight_01_vtol maps\nx_rocket_util::transition_chopper_to_new_path_noteworthy( "dogfight_01_vtol_resume_node" );
	level.dogfight_01_vtol vehicle_SetSpeedImmediate( 90 );
	level.dogfight_01_vtol.health = 1000;

	// Teleport ally chopper to new path
	level.dogfight_01_ally maps\nx_rocket_util::transition_chopper_to_new_path_noteworthy( "dogfight_01_ally_resume_node" );
	level.dogfight_01_ally vehicle_SetSpeedImmediate( 90 );

	// Turn off special ground reference ent
	//iprintln( "Delete ground ref ent" );
	//level._player_ground_origin delete();


	self waittill( "chopper_path_rocket_3_8" );

	self thread do_rocket_3_runners();


	//==========================
	// Rocket Two
	//==========================
	// Spawn some guys on the rocket 2 bunkers
	array_spawn_function_targetname("base_delta_rocket_2_guys", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.base_delta_rocket_2_guys = maps\nx_rocket_util::spawn_guys_from_targetname( "base_delta_rocket_2_guys" );
	self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_rocket_2_3", level.base_delta_rocket_2_guys );

	self thread do_rocket_2_runners();

	// Kick off some drones
	self thread start_drone_pack( "drones_delta_bunker_5_1", 5, 10, "chopper_path_rocket_2_3" );


	self waittill( "chopper_path_leaving_rocket_3" );

	// Clean up the vehicles from dogfight 01 anim
	maps\nx_rocket_util::safe_delete( level.dogfight_01_vtol );
	maps\nx_rocket_util::safe_delete( level.dogfight_01_ally );


	//==========================
	// Done
	//==========================
	self waittill( "chopper_path_leaving_delta_2" );

	//temp music_chk flag
	flag_set( "music_chk_delta_end" );

	// Remove the chopper attractor
	//missile_DeleteAttractor( level.playerHeli.attractor );
	//missile_DeleteAttractor( level.playerHeli.repulsor );
}

// Controls when the player can fire the railgun at rockets
railgun_window_controller()
{
	//==============================
	// WINDOW ONE
	self waittill( "chopper_path_delta_window_1_open" );
	level.current_area = "base_delta_r4";
	maps\nx_rocket_railgun::enable_railgun();
	//thread add_dialogue_line( "Baker", "We have a window, paint a target on the rocket!", "w" );
//  thread maps\nx_rocket_util::wait_play_dialogue_wait( 3, "roc_bak_alpha_painttargetnow" );
	level.squad[ "ALLY_BAKER" ] thread maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_alpha_painttargetnow", 3.0 );

	thread disable_rail_after_event( "rocket_4_destroyed" );

	self waittill( "chopper_path_behind_rocket_4_1" );

	self waittill( "chopper_path_approach_terrace" );
	maps\nx_rocket_railgun::disable_railgun();
	thread check_delta_fail_window( "rocket_4_destroyed", &"NX_ROCKET_DELTA_FAIL" );

	//==============================
	// WINDOW TWO
	//self waittill( "chopper_path_rocket_3_6" );
	level waittill( "chopper_dogfight_base_delta_01_anim_started" );
	wait 14;
	level.current_area = "base_delta_r3";
	maps\nx_rocket_railgun::enable_railgun();
	thread disable_rail_after_event( "rocket_3_destroyed" );

	// Baker: "We have a window, target the rocket!"
//  thread maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_bak_delta_window" );
	level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_delta_window", 0 );

	// Baker: "Paint the rocket!"
//  thread maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_bak_delta_paintrocket" );
	level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_delta_paintrocket", 0 );


	self waittill( "chopper_path_approaching_rocket_2" );
	maps\nx_rocket_railgun::disable_railgun();
	thread check_delta_fail_window( "rocket_3_destroyed", &"NX_ROCKET_DELTA_FAIL" );

	//==============================
	// WINDOW THREE
	self waittill( "chopper_path_rocket_2_2" );
	level.current_area = "base_delta_r2";
	maps\nx_rocket_railgun::enable_railgun();
	thread disable_rail_after_event( "rocket_2_destroyed" );

	// Baker: "Get a laze on that rocket now!!"
//  thread maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_bak_alpha_railshotnow" );
	level.squad[ "ALLY_BAKER" ] thread maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_delta_climbclimbclimb", 0 );

	wait 1.8;

	level.squad[ "ALLY_BAKER" ] thread maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_alpha_railshotnow", 0 );


	self waittill( "chopper_path_rocket_2_4" );

	self waittill( "chopper_path_leaving_delta_2" );
	maps\nx_rocket_railgun::disable_railgun();
	thread check_delta_fail_window( "rocket_2_destroyed", &"NX_ROCKET_DELTA_FAIL" );
}


//******************************************************************************************
//******************************************************************************************

sam_turret_init ( sam_turret_targetname, attack_notify )
{
	// Spawn a turret from the indicated spawner
	sam_turret = spawn_vehicle_from_targetname( sam_turret_targetname );

	// Slap a bunch of missiles on that bad boy
	sam_turret.missileTags = [];
	sam_turret.missileTags[ 0 ] = "tag_missle1";
	sam_turret.missileTags[ 1 ] = "tag_missle2";
	sam_turret.missileTags[ 2 ] = "tag_missle3";
	sam_turret.missileTags[ 3 ] = "tag_missle4";
	sam_turret.missileTags[ 4 ] = "tag_missle5";
	sam_turret.missileTags[ 5 ] = "tag_missle6";
	sam_turret.missileTags[ 6 ] = "tag_missle7";
	sam_turret.missileTags[ 7 ] = "tag_missle8";
	
	foreach( tag in sam_turret.missileTags )
	{
		sam_turret Attach( "projectile_slamraam_missile", tag, true );
	}

	sam_turret thread sam_turret_targeting( attack_notify);
	
	return sam_turret;
}

sam_turret_targeting( attack_notify )
{
	self endon( "exploded" );

	// Set the delay between missile firings
	fire_delay = 1;

	self thread sam_turret_damage_logic();
	
	// Turret rotates to face player
	self setturrettargetent( level._player );

	// The notify that tells it it's time to start firing missiles
	level.playerHeli waittill ( attack_notify );

	eMissile = undefined;
	tag = undefined;
	targetOrg = level._player;
	while ( ( isdefined( self ) ) && ( self.missileTags.size > 0 ) )
	{
		// Shoot the missiles with delay.
		wait fire_delay;

		// Pick a random remaining missile
		tag = random( self.missileTags );

		// delete the missile model and remove that tag from the array
		self.missileTags = array_remove( self.missileTags, tag );
		self detach( self.missileModel, tag );

		// Spawn a real deal missile and send it towards the player
		eMissile = magicBullet( "slamraam_missile_dcburning", self gettagorigin( tag ), targetOrg.origin );
		if ( self.missileTags.size < 1 ) 
			break;
	}
	self clearturrettarget();
}

sam_turret_damage_logic()
{
	// This is how many hits it takes to destroy the turret (there's only one weapon being used here, so this simple method is fine)
	self.hitsRemaining = 3;
	self maps\_vehicle::godon();
	while ( isdefined( self ) )
	{
		// Turret got shot
		self waittill( "damage" );
		// If it has more than 1 hit remaining, reduce hits remaining
		if ( self.hitsRemaining > 0 )
		{
			self.hitsRemaining --;
		}
		// No hits remain, blow that sucker up.
		else
		{
			// Big kablooey
			self thread maps\nx_rocket_audio::rocket_sam_turret_explode_audio();
			playfx( getfx( "helicopter_explosion" ), self.origin );
			// Remove any remaining missiles
			foreach (tag in self.missileTags )
			{
				self detach( self.missileModel, tag );
			}
			// Swap model for destroyed state
			self setmodel( "vehicle_slamraam_destroyed" );
			break;
		}
	}
	self notify ("exploded");
	target_remove ( self );
}

do_bunker_1_runners()
{
	// Spawn some guys that run out and engage
	array_spawn_function_targetname( "base_delta_first_bunker_runners_1", maps\nx_rocket_util::protect_player_helicopter_rear );
	array_spawn_function_targetname( "base_delta_first_bunker_runners_1", maps\nx_rocket_util::run_to_goal_then_aggro );
	level.base_delta_first_bunker_runners_1 = maps\nx_rocket_util::spawn_guys_from_targetname( "base_delta_first_bunker_runners_1" );
	self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_approach_2nd_bunker_2", level.base_delta_first_bunker_runners_1 );
}

do_bunker_2_runners_1()
{
	wait 2.0;
	// Spawn some guys that run out and engage
	array_spawn_function_targetname( "base_delta_second_bunker_runners_1", maps\nx_rocket_util::protect_player_helicopter_rear );
	array_spawn_function_targetname( "base_delta_second_bunker_runners_1", maps\nx_rocket_util::run_to_goal_then_aggro );
	level.base_delta_second_bunker_runners_1 = maps\nx_rocket_util::spawn_guys_from_targetname( "base_delta_second_bunker_runners_1" );
	self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_behind_rocket_4_2", level.base_delta_second_bunker_runners_1 );
}

do_bunker_2_runners_2()
{
	wait 4.0;
	// Spawn some guys that run out and engage
	//array_spawn_function_targetname( "base_delta_second_bunker_runners_2", maps\nx_rocket_util::run_to_goal_then_aggro );
	array_spawn_function_targetname("base_delta_second_bunker_runners_2", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.base_delta_second_bunker_runners_2 = maps\nx_rocket_util::spawn_guys_from_targetname( "base_delta_second_bunker_runners_2" );
	self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_behind_rocket_4_2", level.base_delta_second_bunker_runners_2 );
}

do_bunker_2_runners_3()
{
	wait 2.0;
	// Spawn some guys that run out and engage
	array_spawn_function_targetname( "base_delta_second_bunker_runners_3", maps\nx_rocket_util::run_to_goal_then_aggro );
	array_spawn_function_targetname( "base_delta_second_bunker_runners_3", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.base_delta_second_bunker_runners_3 = maps\nx_rocket_util::spawn_guys_from_targetname( "base_delta_second_bunker_runners_3" );
	self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_behind_rocket_4_2", level.base_delta_second_bunker_runners_3 );
}


do_rocket_3_runners()
{
	wait 3.0;
	// Spawn some guys that run out and engage
	array_spawn_function_targetname( "base_delta_rocket_3_runners", maps\nx_rocket_util::run_to_goal_then_aggro );
	array_spawn_function_targetname( "base_delta_rocket_3_runners", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.base_delta_rocket_3_runners = maps\nx_rocket_util::spawn_guys_from_targetname( "base_delta_rocket_3_runners" );
	self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_approaching_rocket_2", level.base_delta_rocket_3_runners );
}

do_rocket_2_runners()
{
	// Spawn some guys that run out and engage
	array_spawn_function_targetname( "base_delta_rocket_2_runners", maps\nx_rocket_util::run_to_goal_then_aggro );
	array_spawn_function_targetname( "base_delta_rocket_2_runners", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.base_delta_rocket_2_runners = maps\nx_rocket_util::spawn_guys_from_targetname( "base_delta_rocket_2_runners" );
	self thread maps\nx_rocket_util::delete_objects_on_notify( "chopper_path_rocket_2_3", level.base_delta_rocket_2_runners );
}


// Helper script to make drones more organized
start_drone_pack( group_name, low_int, high_int, end_event )
{
	drones = getentarray( group_name, "targetname" );
	thread maps\nx_rocket_util::drone_flood_start( drones, group_name, low_int, high_int, true );
	self thread maps\nx_rocket_util::delayThreadNotify( end_event, maps\nx_rocket_util::drone_flood_stop, group_name );
}


//******************************************************************************************
//******************************************************************************************

// Fires a railgun shot at node, after delay
one_off_railgun_shot( delay, targetname )
{
	wait delay;

	//iprintln( "railgun shot" );
	
	// This is where the railshot starts from
	missile_origin = maps\nx_rocket_railgun::get_railgun_node();

	// Get the target node
	target_ent = GetEnt( targetname, "targetname" );

	// Spawn the railgun shot 
	rail_shot = MagicBullet( "nx_rocket_railgun", missile_origin.origin + randomvectorrange( -100, 100 ), target_ent.origin );
}


// Make the littlebirds fire at the player for a while
littlebird_fodder_1_0_attack( target )
{
	self endon( "death" );

	turrets = self.turrets;
	if ( !isdefined( turrets ) )
		turrets = self.mgturret;

	wait 3.0;
	self thread littlebird_fire_untill_notify( target, turrets, "stop_fire" );
	wait 6.0;
	self notify( "stop_fire" );
}


// Makes a littlebird fire at a target for a while
littlebird_fodder_2_0_attack( target )
{
	self endon( "death" );

	turrets = self.turrets;
	if ( !isdefined( turrets ) )
		turrets = self.mgturret;

	self thread littlebird_fire_untill_notify( target, turrets, "stop_fire" );
	wait 4.0;
	self notify( "stop_fire" );
}

// Makes a littlebird fire at a target for a while
littlebird_fodder_2_1_attack( target )
{
	self endon( "death" );

	turrets = self.turrets;
	if ( !isdefined( turrets ) )
		turrets = self.mgturret;

	wait 2.0;
	self thread littlebird_fire_untill_notify( target, turrets, "stop_fire" );
	wait 3.0;
	self notify( "stop_fire" );
}


// Fires this choppers turret untill the notify event is called
littlebird_fire_untill_notify( target, turrets, notify_event )
{
	self endon( notify_event );
	self endon( "death" );

	// Force a target
	foreach ( turret in turrets )
	{
		turret SetTargetEntity( target );
	}

	// Fire untill the script kills itself
	for ( ;; )
	{
		foreach ( turret in turrets )
		{
			turret Show();
			if ( !turret IsFiringTurret() )
				turret ShootTurret();
		}

		wait 0.1;
	}
}


// Turn off 
disable_rail_after_event( event )
{
	level waittill( event );
	maps\nx_rocket_railgun::disable_railgun();
}

// Turns off the red target boxes on parked BTRs
disable_threat_box_on_vehicles( vehicles )
{
	//  Wait a frame
	waittillframeend;

	foreach( vehicle in vehicles )
	{
		if( !isDefined( vehicle.script_noteworthy ) && Target_IsTarget( vehicle ))
		{
			Target_Remove( vehicle );
		}
	}
}


//*******************************************************************
//                                                                  *
// ROCKET TWO														*
//                                                                  *
//*******************************************************************
// Animates the rocket coming out of the ground, then launching shortly after
/*
// JR - This was used to get gantry pieces animating out of the ground
rocket_two_anim()
{
	// Get gantry
	gantry_pieces = getentarray( "rocket_2_gantry", "targetname" );

	// Get rocket
	rocket = GetEnt( "rocket_two", "targetname" );

	array_thread( gantry_pieces, ::move_gantry_piece, (0,0,-3000), 0.01 );
	rocket MoveTo( rocket.origin + (0,0,-3000), 0.01 );
}*/

rocket_two_anim()
{
	// Get anim node
	anim_node = getEnt( "vignette_nx_rocket_explosion_02", "targetname" );

	//=============================================
	// SETUP THE PIECES
	//=============================================
	rocket_two = spawn_anim_model("rocket_shuttle_exp1_010");
	rocket_two.origin = anim_node.origin;
	rocket_two.angles = anim_node.angles;


	// Link rocket to node
	rocket_two linkTo( anim_node );

	// Link collision cylinder to anim node
	damage_detector = GetEnt( "damage_detector_r2", "script_noteworthy" );
	damage_detector linkTo( anim_node );

	// Link target indicator node to the anim node
	target_indicator = GetEnt( "rocketexplode_02", "script_noteworthy" );
	target_indicator linkTo( anim_node );

	// Start the rocket below ground
	anim_node.origin = anim_node.origin + (0,0, ROCKET_2_INITIAL_DEPTH );

	// Start the gantry below ground
	// This gantry is already below ground in Radiant.
	//thread gantry_setup_two();

	script_models = [];
	script_models["rocket_shuttle_exp1_010"] = rocket_two;

	anim_node anim_first_frame( script_models, "rocket_shuttle_exp1");

	// Handle rocket movement and FX
	anim_node thread move_rocket_two();
	anim_node thread launch_rocket_two();
	rocket_two thread rocket_two_fx();

	//========================================
	// Wait for the rocket to be destroyed
	//========================================
	level waittill( "rocket_2_destroyed" );
	
	// Determine which anim should play
	explosion_anim = undefined;
	explosion_models = [];

	//==========================================================
	//==========================================================
	if( level.rocket_2_state == "rising" )
	{
		explosion_anim = "rocket_shuttle_exp1";
		thread maps\nx_rocket_fx::rocket_02_hit_fx( rocket_two );
	}
	//==========================================================
	//==========================================================
	else if( level.rocket_2_state == "waiting" )
	{
		explosion_anim = "rocket_shuttle_exp1";
		thread maps\nx_rocket_fx::rocket_02_hit_fx( rocket_two );
	}
	//==========================================================
	//==========================================================
	else if( level.rocket_2_state == "launching" )
	{
		explosion_anim = "rocket_shuttle_exp1";
		thread maps\nx_rocket_fx::rocket_02_launch_hit_fx( rocket_two );
	}

	// Play Sounds
	//rocket_two PlaySound( "scn_rocket_lrgrocketexplo" );
	rocket_two StopLoopSound( "rocket_launch_loop" );

	// Play the anim
	anim_node anim_single( script_models, explosion_anim );

	anim_node delete();
}


// Moves the rocket and gantry up out of the ground
move_rocket_two()
{
	level endon( "rocket_2_destroyed" );

	wait ROCKET_2_RISE_DELAY;

	self thread move_gantry_inner_two();
	self thread move_gantry_outer_two();
	
	level.rocket_2_state = "rising";
	//iprintln( "r2 rising" );
	self moveto( self.origin + (0,0, ROCKET_2_INITIAL_DEPTH * -1 ), ROCKET_2_RISE_TIME );
	self waittill( "movedone" );
	level notify( "rocket_2_done_moving" );
	level.rocket_2_state = "waiting";
	//iprintln( "r2 done rising" );

	wait 25;

	thread maps\nx_rocket_section_base_alpha::animate_gantry_arms( "gantry_inner_2" );
}

gantry_setup_two()
{
	// Get all Ents in the Outer Gantry prefab
	gantry_parts = GetEntArray ("gantry_outer_2", "script_noteworthy");

	// Teleport them under ground
	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			part.origin =  ( part.origin + (0, 0, (ROCKET_2_INITIAL_DEPTH + 600)));
		}
	}

	// Get all Ents in the Inner Gantry prefab
	gantry_parts = GetEntArray ("gantry_inner_2", "script_noteworthy");

	// Teleport them under ground
	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			part.origin =  ( part.origin + (0, 0, ROCKET_2_INITIAL_DEPTH ));
		}
	} 
}

move_gantry_outer_two()
{
	// Get all Ents in the Gantry prefab
	gantry_parts = GetEntArray ("gantry_outer_2", "script_noteworthy");

	// Move them in sync with the rocket
	// But stop 600 units short, 5 seconds sooner
	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			part MoveTo( part.origin + (0, 0, ((ROCKET_2_INITIAL_DEPTH * -1) - 600)), (ROCKET_2_RISE_TIME - 5), 2, 2 );
		}
	}
}

move_gantry_inner_two()
{
	// Get all Ents in the Gantry prefab
	gantry_parts = GetEntArray ("gantry_inner_2", "script_noteworthy");

	// Move them in sync with the rocket
	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			part MoveTo( part.origin + (0, 0, (ROCKET_2_INITIAL_DEPTH * -1)), ROCKET_2_RISE_TIME, 2, 2 );
		}
	} 
}

launch_rocket_two()
{
	level waittill( "rocket_2_done_moving" );
	level thread maps\nx_rocket_util::launch_coutdown_logic( ROCKET_2_LAUNCH_DELAY, 2, "rocket_2_destroyed" );
	wait ROCKET_2_LAUNCH_DELAY;

	// Check to see if the rocket was popped before launching
	if( flag( "rocket_2_destroyed" ))
	{
		return;
	}

	level notify( "rocket_two_launching" );
	level.rocket_2_state = "launching";
	self moveto( self.origin + (0,0, ROCKET_2_LAUNCH_HEIGHT ), ROCKET_2_LAUNCH_TIME, ROCKET_2_LAUNCH_TIME/2 );

	// When the rocket gets destroyed, cancel the launch with a small move
	level waittill( "rocket_2_destroyed" );
	self moveto( self.origin + (0,0,1), 1 );
}

// FX and sound for for rocket 2
rocket_two_fx()
{
	level endon( "rocket_2_destroyed" );

	self playsound("rocket_launch_close"); //plays the rocket launching sequence sound

	level waittill( "rocket_2_done_moving" );
	wait ROCKET_2_LAUNCH_FX_DELAY;

	//iprintln( "rocket 2 fx" );
	exploder("rocketlaunch_base_smoke_jets");
	exploder("rocketlaunch_base_sparkjets");
	wait 5;
	exploder("rocketlaunch_jet_ignite");
	//wait 2;
	//exploder("rocketlaunch_exhaust_01");
	wait 5;

	// JR - Turning this off cause it causes a crash
	PlayFXOnTag( level._effect[ "nx_smoke_rocket_afterburner_liftoff" ], self, "j_tag_booster" );

	wait 1;

	exploder("rocketlaunch_blast");

	self playloopsound("rocket_launch_loop"); //looping rocket sound for when it goes in the air forever

	// Stop FX with:
	thread stop_rocket_two_prelaunch_fx_on_destroy( self );
	thread stop_rocket_two_afterburn_fx_on_destroy( self );
	thread stop_rocket_two_prelaunch_fx_on_wait();
}

stop_rocket_two_prelaunch_fx_on_destroy( rocket_two )
{
    level endon( "rocket_two_launching" );

    flag_Wait( "rocket_2_destroyed" );

	stop_exploder_nx( "rocketlaunch_base_smoke_jets" );
	stop_exploder_nx( "rocketlaunch_base_sparkjets" );
	stop_exploder_nx( "rocketlaunch_jet_ignite" );
	stop_exploder_nx( "rocketlaunch_blast" );
	StopFXOnTag( level._effect[ "nx_smoke_rocket_afterburner_liftoff" ], rocket_two, "j_tag_booster" );
}

stop_rocket_two_prelaunch_fx_on_wait()
{
    level waittill( "rocket_two_launching" );

	stop_exploder_nx( "rocketlaunch_base_smoke_jets" );
	stop_exploder_nx( "rocketlaunch_base_sparkjets" );
	stop_exploder_nx( "rocketlaunch_jet_ignite" );
    wait 18;
	stop_exploder_nx( "rocketlaunch_blast" );
}

stop_rocket_two_afterburn_fx_on_destroy( rocket_two )
{
    flag_Wait( "rocket_2_destroyed" );
	StopFXOnTag( level._effect[ "nx_smoke_rocket_afterburner_liftoff" ], rocket_two, "j_tag_booster" );
}

//*******************************************************************
//                                                                  *
// ROCKET THREE														*
//                                                                  *
//*******************************************************************
rocket_three_anim()
{
	// Get anim node
	anim_node = getEnt( "vignette_nx_rocket_explosion_03", "targetname" );

	//=============================================
	// SETUP THE PIECES
	//=============================================
	rocket_three = spawn_anim_model("rocket_shuttle_exp1_010");
	rocket_three.origin = anim_node.origin;
	rocket_three.angles = anim_node.angles;


	// Link rocket to node
	rocket_three linkTo( anim_node );

	// Link collision cylinder to anim node
	damage_detector = GetEnt( "damage_detector_r3", "script_noteworthy" );
	damage_detector linkTo( anim_node );

	// Link target indicator node to the anim node
	target_indicator = GetEnt( "rocketexplode_03", "script_noteworthy" );
	target_indicator linkTo( anim_node );

	// Start the rocket below ground
	anim_node.origin = anim_node.origin + (0,0, ROCKET_3_INITIAL_DEPTH );

	// Start the gantry below ground
	thread gantry_setup_three();

	script_models = [];
	script_models["rocket_shuttle_exp1_010"] = rocket_three;

	anim_node anim_first_frame( script_models, "rocket_shuttle_exp1");

	// Set the initial rocket state
	level.rocket_3_state = "waiting";

	// Handle rocket movement and FX
	anim_node thread move_rocket_three();
	anim_node thread launch_rocket_three();
	rocket_three thread rocket_three_fx();

	//========================================
	// Wait for the rocket to be destroyed
	//========================================
	level waittill( "rocket_3_destroyed" );

	// Determine which anim should play
	explosion_anim = undefined;
	explosion_models = [];

	//==========================================================
	//==========================================================
	if( level.rocket_3_state == "waiting" )
	{
		explosion_anim = "rocket_shuttle_exp1";
		thread maps\nx_rocket_fx::rocket_03_hit_fx( rocket_three );
	}
	//==========================================================
	//==========================================================
	else if( level.rocket_3_state == "launching" )
	{
		explosion_anim = "rocket_shuttle_exp1";
		thread maps\nx_rocket_fx::rocket_03_launch_hit_fx( rocket_three );
	}
	//==========================================================
	//==========================================================

	// Play Sounds
	//rocket_three PlaySound( "scn_rocket_lrgrocketexplo" );
	rocket_three StopLoopSound( "rocket_launch_loop" );

	// Play the anim
	anim_node anim_single( script_models, explosion_anim );
	
	anim_node delete();
}


// Moves the rocket up out of the ground
move_rocket_three()
{
	level endon( "rocket_3_destroyed" );

	wait ROCKET_3_RISE_DELAY;

	self thread move_gantry_inner_three();
	self thread move_gantry_outer_three();

	level.rocket_3_state = "rising";
	//iprintln( "r3 rising" );
	self moveto( self.origin + (0,0, ROCKET_3_INITIAL_DEPTH * -1 ), ROCKET_3_RISE_TIME );
	self waittill( "movedone" );
	level notify( "rocket_3_done_moving" );
	level.rocket_3_state = "waiting";
	//iprintln( "r3 done rising" );

	wait 20;

	thread maps\nx_rocket_section_base_alpha::animate_gantry_arms( "gantry_inner_3" );
}

gantry_setup_three()
{
	// Get all Ents in the Outer Gantry prefab
	gantry_parts = GetEntArray ("gantry_outer_3", "script_noteworthy");

	// Teleport them under ground
	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			part.origin =  ( part.origin + (0, 0, (ROCKET_3_INITIAL_DEPTH + 600)));
		}
	}

	// Get all Ents in the Inner Gantry prefab
	gantry_parts = GetEntArray ("gantry_inner_3", "script_noteworthy");

	// Teleport them under ground
	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			part.origin =  ( part.origin + (0, 0, ROCKET_3_INITIAL_DEPTH ));
		}
	} 
}

move_gantry_outer_three()
{
	// Get all Ents in the Gantry prefab
	gantry_parts = GetEntArray ("gantry_outer_3", "script_noteworthy");

	// Move them in sync with the rocket
	// But stop 600 units short, 5 seconds sooner
	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			part MoveTo( part.origin + (0, 0, ((ROCKET_3_INITIAL_DEPTH * -1) - 600)), (ROCKET_3_RISE_TIME - 5), 2, 2 );
		}
	}
}

move_gantry_inner_three()
{
	// Get all Ents in the Gantry prefab
	gantry_parts = GetEntArray ("gantry_inner_3", "script_noteworthy");

	// Move them in sync with the rocket
	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			part MoveTo( part.origin + (0, 0, (ROCKET_3_INITIAL_DEPTH * -1)), ROCKET_3_RISE_TIME, 2, 2 );
		}
	}
}

launch_rocket_three()
{
	// Wait for pre-launch FX to finish
	level waittill( "rocket_3_done_moving" );
	level thread maps\nx_rocket_util::launch_coutdown_logic( ROCKET_3_LAUNCH_DELAY, 3, "rocket_3_destroyed" );
	wait ROCKET_3_LAUNCH_DELAY;

	// Check to see if the rocket was popped before launching
	if( flag( "rocket_3_destroyed" ))
	{
		return;
	}

	level notify( "rocket_three_launching" );
	level.rocket_3_state = "launching";
	self moveto( self.origin + (0,0, ROCKET_3_LAUNCH_HEIGHT ), ROCKET_3_LAUNCH_TIME, ROCKET_3_LAUNCH_TIME/2 );

	// When the rocket gets destroyed, cancel the launch with a small move
	level waittill( "rocket_3_destroyed" );
	self moveto( self.origin + (0,0,1), 1 );
}

// FX and sound for for rocket 3
rocket_three_fx()
{
	level endon( "rocket_3_destroyed" );


	self playsound("rocket_launch_close"); //plays the rocket launching sequence sound

	level waittill( "rocket_3_done_moving" );
	wait ROCKET_3_LAUNCH_FX_DELAY;

	//iprintln( "rocket 3 fx" );
	exploder("rocketlaunch03_base_smoke_jets");
	exploder("rocketlaunch03_base_sparkjets");
	wait 7;
	exploder("rocketlaunch03_jet_ignite");
	//wait 2;
	//exploder("rocketlaunch_exhaust_01");
	wait 5;

	// JR - Turning this off cause it causes a crash
	PlayFXOnTag( level._effect[ "nx_smoke_rocket_afterburner_liftoff" ], self, "j_tag_booster" );

	wait 1;

	exploder("rocketlaunch03_exhaust_01");

	self playloopsound("rocket_launch_loop"); //looping rocket sound for when it goes in the air forever

	thread stop_rocket_three_prelaunch_fx_on_destroy( self );
	thread stop_rocket_three_afterburn_fx_on_destroy( self );
	thread stop_rocket_three_prelaunch_fx_on_wait();
}

stop_rocket_three_prelaunch_fx_on_destroy( rocket_three )
{
    level endon( "rocket_three_launching" );

    flag_Wait( "rocket_3_destroyed" );

	stop_exploder_nx( "rocketlaunch03_base_smoke_jets" );
	stop_exploder_nx( "rocketlaunch03_base_sparkjets" );
	stop_exploder_nx( "rocketlaunch03_jet_ignite" );
	stop_exploder_nx( "rocketlaunch03_exhaust_01" );
	StopFXOnTag( level._effect[ "nx_smoke_rocket_afterburner_liftoff" ], rocket_three, "j_tag_booster" );
}

stop_rocket_three_prelaunch_fx_on_wait()
{
    level waittill( "rocket_three_launching" );
	stop_exploder_nx( "rocketlaunch03_base_smoke_jets" );
	stop_exploder_nx( "rocketlaunch03_base_sparkjets" );
	stop_exploder_nx( "rocketlaunch03_jet_ignite" );
    wait 18;
	stop_exploder_nx( "rocketlaunch03_exhaust_01" );
}

stop_rocket_three_afterburn_fx_on_destroy( rocket_three )
{
    flag_Wait( "rocket_3_destroyed" );
	StopFXOnTag( level._effect[ "nx_smoke_rocket_afterburner_liftoff" ], rocket_three, "j_tag_booster" );
}

//*******************************************************************
//                                                                  *
// ROCKET FOUR														*
//                                                                  *
//*******************************************************************
rocket_four_anim()
{
	// Get anim node
	anim_node = getEnt( "vignette_nx_rocket_explosion_04", "targetname" );

	//=============================================
	// SETUP THE PIECES
	//=============================================
	rocket_four = spawn_anim_model("rocket_shuttle_exp1_010");
	rocket_four.origin = anim_node.origin;
	rocket_four.angles = anim_node.angles;


	// Link rocket to node
	rocket_four linkTo( anim_node );

	// Link collision cylinder to anim node
	damage_detector = GetEnt( "damage_detector_r4", "script_noteworthy" );
	damage_detector linkTo( anim_node );

	// Link target indicator node to the anim node
	target_indicator = GetEnt( "rocketexplode_04", "script_noteworthy" );
	target_indicator linkTo( anim_node );

	// Start the rocket below ground
	anim_node.origin = anim_node.origin + (0,0, ROCKET_4_INITIAL_DEPTH );

	// Start the gantry below ground
	thread gantry_setup_four();

	script_models = [];
	script_models["rocket_shuttle_exp1_010"] = rocket_four;

	anim_node anim_first_frame( script_models, "rocket_shuttle_exp1");

	// Handle rocket movement and FX
	anim_node thread move_rocket_four();
	anim_node thread launch_rocket_four();
	rocket_four thread rocket_four_fx();

	//========================================
	// Wait for the rocket to be destroyed
	//========================================
	level waittill( "rocket_4_destroyed" );

	// Determine which anim should play
	explosion_anim = undefined;
	explosion_models = [];
	//==========================================================
	//==========================================================
	if( level.rocket_4_state == "rising" )
	{
		explosion_anim = "rocket_shuttle_exp1";
		thread maps\nx_rocket_fx::rocket_04_hit_fx( rocket_four );
	}
	//==========================================================
	//==========================================================
	else if( level.rocket_4_state == "waiting" )
	{
		explosion_anim = "rocket_shuttle_exp1";
		thread maps\nx_rocket_fx::rocket_04_hit_fx( rocket_four);
	}
	//==========================================================
	//==========================================================
	else if( level.rocket_4_state == "launching" )
	{
		explosion_anim = "rocket_shuttle_exp1";
		thread maps\nx_rocket_fx::rocket_04_launch_hit_fx( rocket_four );
	}
	//==========================================================
	//==========================================================

	// Play Sounds
	//rocket_four PlaySound( "scn_rocket_lrgrocketexplo" );
	rocket_four StopLoopSound( "rocket_launch_loop" );

	// Play the anim
	anim_node anim_single( script_models, explosion_anim );

	anim_node delete();
}


// Moves the rocket and gantry up out of the ground
move_rocket_four()
{
	level endon( "rocket_4_destroyed" );

	// JR - There should be a flag wait here triggered by a heli node

	wait ROCKET_4_RISE_DELAY;

	//flag_wait( "chopper_path_entering_base_alpha" );

	self thread move_gantry_inner_four();
	self thread move_gantry_outer_four();

	level.rocket_4_state = "rising";

	//iprintln( "r4 rising" );

	self moveto( self.origin + (0,0, ROCKET_4_INITIAL_DEPTH * -1 ), ROCKET_4_RISE_TIME );
	self waittill( "movedone" );
	level notify( "rocket_4_done_moving" );
	level.rocket_4_state = "waiting";
	//iprintln( "r4 done rising" );

	wait 20;

	thread maps\nx_rocket_section_base_alpha::animate_gantry_arms( "gantry_inner_4" );
}

gantry_setup_four()
{
	// Get all Ents in the Outer Gantry prefab
	gantry_parts = GetEntArray ("gantry_outer_4", "script_noteworthy");

	// Teleport them under ground
	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			part.origin =  ( part.origin + (0, 0, (ROCKET_4_INITIAL_DEPTH + 600)));
		}
	}

	// Get all Ents in the Inner Gantry prefab
	gantry_parts = GetEntArray ("gantry_inner_4", "script_noteworthy");

	// Teleport them under ground
	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			part.origin =  ( part.origin + (0, 0, ROCKET_4_INITIAL_DEPTH ));
		}
	}
}

move_gantry_outer_four()
{
	// Get all Ents in the Gantry prefab
	gantry_parts = GetEntArray ("gantry_outer_4", "script_noteworthy");

	// Move them in sync with the rocket
	// But stop 600 units short, 5 seconds sooner
	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			part MoveTo( part.origin + (0, 0, ((ROCKET_4_INITIAL_DEPTH * -1) - 600)), (ROCKET_4_RISE_TIME - 5), 2, 2 );
		}
	}
}

move_gantry_inner_four()
{
	// Get all Ents in the Gantry prefab
	gantry_parts = GetEntArray ("gantry_inner_4", "script_noteworthy");

	// Move them in sync with the rocket
	foreach( part in gantry_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_model")
		{
			part MoveTo( part.origin + (0, 0, (ROCKET_4_INITIAL_DEPTH * -1)), ROCKET_4_RISE_TIME, 2, 2 );
		}
	}
}


launch_rocket_four()
{
	// Wait for pre-launch FX to finish
	level waittill( "rocket_4_done_moving" );
	level thread maps\nx_rocket_util::launch_coutdown_logic( ROCKET_4_LAUNCH_DELAY, 4, "rocket_4_destroyed" );
	wait ROCKET_4_LAUNCH_DELAY;
	
	// Check to see if the rocket was popped before launching
	if( flag( "rocket_4_destroyed" ))
	{
		return;
	}

	level notify( "rocket_four_launching" );
	level.rocket_4_state = "launching";
	self moveto( self.origin + (0,0, ROCKET_4_LAUNCH_HEIGHT ), ROCKET_4_LAUNCH_TIME, ROCKET_4_LAUNCH_TIME/4 );

	// When the rocket gets destroyed, cancel the launch with a small move
	level waittill( "rocket_4_destroyed" );
	self moveto( self.origin + (0,0,1), 1 );
}


// FX and sound for for rocket 4
rocket_four_fx()
{
	level endon( "rocket_4_destroyed" );
	self playsound("rocket_launch_close"); //plays the rocket launching sequence sound

	wait ROCKET_4_FX_DELAY;

	//iprintln( "rocket 4 fx" );

	exploder("rocketlaunch04_base_smoke_jets");
	exploder("rocketlaunch04_base_sparkjets");
	wait 8;
	exploder("rocketlaunch04_jet_ignite");
	wait 2;
	//exploder("rocketlaunch_exhaust_01");
	wait 9;

	PlayFXOnTag( level._effect[ "nx_smoke_rocket_afterburner_liftoff" ], self, "j_tag_booster" );

	wait 1;

	exploder("rocketlaunch04_blast");

	self playloopsound("rocket_launch_loop"); //looping rocket sound for when it goes in the air forever

	// Stop FX with:
	thread stop_rocket_four_prelaunch_fx_on_destroy( self );
	thread stop_rocket_four_afterburn_fx_on_destroy( self );
	thread stop_rocket_four_prelaunch_fx_on_wait();
}

stop_rocket_four_prelaunch_fx_on_destroy( rocket_four )
{
    level endon( "rocket_four_launching" );

    flag_Wait( "rocket_4_destroyed" );

	stop_exploder_nx( "rocketlaunch04_base_smoke_jets" );
	stop_exploder_nx( "rocketlaunch04_base_sparkjets" );
	stop_exploder_nx( "rocketlaunch04_jet_ignite" );
	stop_exploder_nx( "rocketlaunch04_blast" );
	StopFXOnTag( level._effect[ "nx_smoke_rocket_afterburner_liftoff" ], rocket_four, "j_tag_booster" );
}

stop_rocket_four_prelaunch_fx_on_wait()
{
    level waittill( "rocket_four_launching" );

	stop_exploder_nx( "rocketlaunch04_base_smoke_jets" );
	stop_exploder_nx( "rocketlaunch04_base_sparkjets" );
	stop_exploder_nx( "rocketlaunch04_jet_ignite" );
    wait 18;
	stop_exploder_nx( "rocketlaunch04_blast" );
}

stop_rocket_four_afterburn_fx_on_destroy( rocket_four )
{
    flag_Wait( "rocket_4_destroyed" );
	StopFXOnTag( level._effect[ "nx_smoke_rocket_afterburner_liftoff" ], rocket_four, "j_tag_booster" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Deletes a rocket
// JR - May not be needed
cleanup_rocket( rocket_name )
{
	rocket = GetEnt( rocket_name, "targetname" );
	rocket delete();
}


// Fails the mission if rocket 4 isnt destroyed in the next 5 seconds
check_delta_fail_window( flag, fail_text )
{
	level endon( flag );

	// Check the rocket
	if( !flag( flag ))
	{
		// If they got this far and the rockets havnt popped, they fail.
		SetDvar( "ui_deadquote", fail_text );
		maps\_utility::missionFailedWrapper();
	}
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Flips a flag once all 3 rockets in this section are destroyed
watch_for_rocket_destruction()
{
	flag_wait( "rocket_4_destroyed" );
	flag_wait( "rocket_3_destroyed" );
	flag_wait( "rocket_2_destroyed" );
	flag_set( "base_delta_destroyed" );
}


// Quick and easy way to move the gantry, one piece at a time
move_gantry_piece( offset, time )
{
	self MoveTo( self.origin + offset, time );	
}
