
//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_ROCKET_SECTION_GANTRY										**
//                                                                          **
//    Created: 7/13/2011 - Justin Rote										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


//*******************************************************************
//                                                                  *
//	GANTRY ATTACK - From jumping out of the chopper to placing C4	*
//                                                                  *
//*******************************************************************
start()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_gantry_attack" );

	// Spawn chopper that just dropped you off
	dropoff_chopper = spawn_vehicle_from_targetname_and_drive( "littlebird_rescue_heli" );
//  dropoff_chopper = maps\nx_rocket_util::rescue_chopper_setup( "littlebird_rescue_heli", "targetname" );
	dropoff_chopper thread maps\nx_rocket_section_littlebird::kill_littlebird_after_path();

	// Hide the final gantry animated swing arm
	swing_arm_bits = GetEntArray( "final_gantry_arm_extended", "targetname" );
	foreach( bit in swing_arm_bits )
	{
		bit hide();
	}
}

main()
{
	thread maps\_utility::set_ambient( "nx_rocket_ext" );

	// Setup some spawn funcs
	//array_spawn_function_noteworthy( "fgantry_f0_guys_01", maps\nx_rocket_util::run_to_goal_then_aggro );
	array_spawn_function_noteworthy( "fgantry_f0_guys_02", maps\nx_rocket_util::run_to_goal_then_aggro );
	array_spawn_function_noteworthy( "fgantry_f1_guys_01", maps\nx_rocket_util::run_to_goal_then_aggro );
	array_spawn_function_noteworthy( "fgantry_f1_guys_03", maps\nx_rocket_util::run_to_goal_then_aggro );

	// Move baker to gantry
	// Eventually he will jump out of the chopper
	level.squad[ "ALLY_BAKER" ] StopAnimScripted();
	level.squad[ "ALLY_BAKER" ] Unlink();
	teleport_info = [];
	teleport_info[ "ALLY_BAKER" ]	= "start_baker_gantry";
	maps\nx_rocket_util::squad_teleport( teleport_info );

	//level.squad[ "ALLY_BAKER" ] thread show_debug_follow_on_baker();
	Objective_SetPointerTextOverride( obj( "OBJ_DESTROY_FINAL_ROCKET" ), &"NX_ROCKET_FOLLOW_MARKER" );
	Objective_OnEntity( obj( "OBJ_DESTROY_FINAL_ROCKET" ), level.squad[ "ALLY_BAKER" ], (0, 0, 90) );

	// Start the dialogue thread
	thread gantry_dialogue();
	thread rocket_five_fx();

	// Start the baker movement thread
	thread gantry_baker_movement();

	flag_wait( "flag_at_gantry_jump_down" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
section_precache()
{
	PreCacheModel("machinery_railing_single_long02");
}


section_flag_inits()
{
	flag_init( "gantry_arm_anim_done" );
}


gantry_baker_movement()
{
	level endon( "flag_at_gantry_jump_down" );

	// Baker setup
	level.squad[ "ALLY_BAKER" ].script_forcegoal = true;


	// Ignore everything
	level.squad[ "ALLY_BAKER" ].moveplaybackrate = 1.2;
	level.squad[ "ALLY_BAKER" ].grenadeawareness = 0;
	level.squad[ "ALLY_BAKER" ].ignoreexplosionevents = true;
	level.squad[ "ALLY_BAKER" ].ignorerandombulletdamage = true;
	level.squad[ "ALLY_BAKER" ].ignoresuppression = true;
	level.squad[ "ALLY_BAKER" ].disableBulletWhizbyReaction = true;
	level.squad[ "ALLY_BAKER" ] disable_pain();


	//==========================
	// FLOOR 0
	//==========================
	flag_wait( "flag_gantry_f0_01" );

	// Wait for tangos to die
	flag_wait( "flag_gantry_f0_01_guys_dead" );
	issue_color_orders( "g400", "allies" );


	//==========================
	// FLOOR 1
	//==========================
	flag_wait( "flag_gantry_f1_03_guys_dead" );
	issue_color_orders( "g404", "allies" );


	//==========================
	// FLOOR 2
	//==========================

	// Spawn this extra safety thread to make sure baker doesnt get stuck
	thread gantry_floor_two_move_baker();
	thread final_gantry_objective_logic();

	flag_wait( "flag_gantry_f1_stairs_down" );
	level.squad[ "ALLY_BAKER" ].ignoreall = true;

	flag_wait( "flag_gantry_f2_baker_in_pos" );
	level.squad[ "ALLY_BAKER" ].ignoreall = false;
}


// Baker was getting stuck here,
// so this extra script will make sure he moves his ass
gantry_floor_two_move_baker()
{
	level endon( "flag_gantry_f2_baker_in_pos" );
	level waittill( "flag_gantry_f2_01_guys_dead" );
	issue_color_orders( "g405", "allies" );
}

// Handles the mission objective markers for the end of the mission
final_gantry_objective_logic()
{
	flag_wait( "flag_at_gantry_jump_down" );
	hint_node = GetEnt( "gantry_jump_objective", "targetname" );

	// JR - This does not work
	// We need a special version of the asset that is suffixed "_obj" to act as the glow model version
	// Make railing glow
	//railing = getent( "gantry_jump_railing", "targetname" );
	//railing glow();

	// Turn off follow marker on Baker
	Objective_ClearAllAdditionalEntities( obj( "OBJ_DESTROY_FINAL_ROCKET" ));

	// Add extra objective text
	objective_setpointertextoverride( obj( "OBJ_DESTROY_FINAL_ROCKET" ), &"NX_ROCKET_JUMP_DOWN" );
	objective_position( obj( "OBJ_DESTROY_FINAL_ROCKET" ), hint_node.origin );

	flag_wait( "flag_gantry_player_jumped_down" );
	hint_node = GetEnt( "place_c4_objective", "targetname" );
	objective_setpointertextoverride( obj( "OBJ_DESTROY_FINAL_ROCKET" ), &"NX_ROCKET_PLACE_C4" );
	objective_position( obj( "OBJ_DESTROY_FINAL_ROCKET" ), hint_node.origin );

	level waittill( "gantry_attack_c4_placed" );
	objective_clearAdditionalPositions( obj( "OBJ_DESTROY_FINAL_ROCKET" ));

	flag_wait( "gantry_arm_anim_done" );
	wait 0.1;
	objective_setpointertextoverride( obj( "OBJ_DESTROY_FINAL_ROCKET" ), &"" );
	Objective_OnEntity( obj( "OBJ_DESTROY_FINAL_ROCKET" ), level.playerHeli, (0, 0, -50) );
}


gantry_dialogue()
{
	// JR - Disabled the debug VO untill it can be updated with the proper audio VO lines
/*
	wait 3.0;
	thread add_dialogue_line( "Baker", "Lets go!!", "w" );

	flag_wait( "gantry_attack_at_gantry" );
	thread add_dialogue_line( "Baker", "Lockwood go! Get a charge on the hull!! Ill cover you.", "w" );

	level waittill( "gantry_attack_c4_placed" );
	wait 3.0;
	thread add_dialogue_line( "Baker", "Theyre popping the walkways!!", "w" );

	level waittill( "gantry_attack_swing_arm_done" );
	wait 2.0;
	thread add_dialogue_line( "Williams", "Come on!  Jump in!!", "w" );
*/
}

rocket_five_fx()
{
	wait 2;
	//level endon( "rocket_1_destroyed" );
	//self playsound("rocket_launch_close"); //plays the rocket launching sequence sound


	exploder("rocketlaunch05_base_smoke_jets");
	exploder("rocketlaunch05_base_sparkjets");
	wait 10;
	exploder("rocketlaunch05_jet_ignite");
	wait 5;
	//exploder("rocketlaunch_exhaust_01");
	//wait 9;

	//PlayFXOnTag( level._effect[ "nx_smoke_rocket_afterburner_liftoff" ], self, "j_tag_booster" );

	//wait 1;

	exploder("rocketlaunch05_blast");

	//self playloopsound("rocket_launch_loop"); //looping rocket sound for when it goes in the air forever

	// Stop FX with:
	//thread stop_rocket_one_prelaunch_fx_on_destroy( self );
	//thread stop_rocket_one_afterburn_fx_on_destroy( self );
	//thread stop_rocket_one_prelaunch_fx_on_wait();
}

// Displays a debug follow text on Baker
show_debug_follow_on_baker()
{
	level endon( "flag_at_gantry_jump_down" );
	for( ; ; )
	{
		Print3d( self.origin + (0,0,60), "FOLLOW", (1,1,1), 1, 0.8, 1 );
		wait(0.05);
	}
}
