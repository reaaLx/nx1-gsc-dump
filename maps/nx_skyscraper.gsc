//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  MISSION DESCRIPTION											**
//                                                                          **
//    Created: 7/05/2011 - Ken Moodie										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_utility_code;
#include maps\_nx_objective_util;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_nx_utility;
#include maps\nx_skyscraper_util;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main()
{
	default_start( ::drive_up_start );
	add_start( "drive_up", 		::drive_up_start, 		"Drive Intro", ::drive_up );
	add_start( "lobby_enter", 	::lobby_enter_start, 	"Atrium Lobby Entrance", ::lobby_enter );
	add_start( "elevator", 		::elevator_start, 		"Elevator", ::elevator );
	add_start( "shaft", 		::shaft_start, 			"Shaft Traversal", ::shaft );
	add_start( "window", 		::window_start, 		"Window to Hangar", ::window );
	add_start( "hangar", 		::hangar_start, 		"Hangar", ::hangar );
	add_start( "lab_enter", 	::lab_enter_start, 		"Lab Infiltration", ::lab_enter );
	add_start( "lab_to_vault",	::lab_to_vault_start, 	"Lab To Vault", ::lab_to_vault );
	add_start( "vault", 		::vault_start, 			"Vault", ::vault );
	add_start( "lab_exit", 		::lab_exit_start, 		"Lab Exit", ::lab_exit );
	add_start( "halon", 		::start_halon, 			"Halon", ::halon );
	add_start( "vtol", 			::vtol_start, 			"VTOL and Floor Collapse", ::vtol );
	add_start( "rappel", 		::rappel_start, 		"Rappel Down Building", ::rappel );
	// add_start( "lobby_crash", 	::lobby_crash_start,	"Atrium Lobby Crash", ::lobby_crash );
	add_start( "outro", 		::outro_start,			"outro", ::outro );

	// External Initialization
	maps\nx_skyscraper_precache::main();

	// Internal Initialization
	mission_flag_inits();
	mission_precache();
	maps\nx_skyscraper_fx::main();
	maps\_load::main();
	maps\nx_skyscraper_anim::main();

	//start ambiences
	maps\nx_skyscraper_amb::main();

	// Translation
	maps\_translation::main();

	// Rappel
	maps\_rappel::main();

	// Stealth
	maps\_patrol_anims::main();
	maps\_stealth::main();

	//set timescale factors
	SoundSetTimeScaleFactor( "Music", 0 );

	// Vision Sets.
	maps\nx_skyscraper_fx::init_vision_set_triggers();

	// Mission threads
	level thread maps\nx_skyscraper_audio::mission_music();
	thread mission_objective_logic();
	level._player TakeAllWeapons();

}

// All mission specific PreCache calls
mission_precache()
{
	PreCacheItem( "lancer" );
	PreCacheItem( "lancer_xray" );
	PreCacheItem( "lancer_silencer_xray" );
	PreCacheItem( "m9" );
	PreCacheItem( "zippy_rockets" );
	PreCacheModel( "viewhands_player_us_army" );
	PreCacheModel( "viewmodel_lancer_xray" );
	PreCacheModel( "vehicle_blackhawk_crash" );
	PreCacheModel( "nx_ec_lab_body_hazmat_a" );
	PreCacheItem( "rpgx_straight" );
	
	PreCacheModel( "com_cellphone_on");
	PreCacheShader( "alternate_scene_overlay");
	precacheShader( "hud_temperature_gauge" );
	precacheshader( "cinematic_trans" );

	add_hint_string( "hint_prone_for_cover", &"NX_SKYSCRAPER_HINT_GO_PRONE", maps\nx_skyscraper_lab_enter::hint_prone_for_cover );
	add_hint_string( "hint_crouch_for_cover", &"NX_SKYSCRAPER_HINT_HALON_CROUCH", maps\nx_skyscraper_halon::hint_crouch_for_cover );
	add_hint_string( "NX_SKYSCRAPER_HINT_USE_XRAY", &"NX_SKYSCRAPER_HINT_USE_XRAY", ::should_break_used_ads );
	add_hint_string( "NX_SKYSCRAPER_HINT_LEFT_HAND", &"NX_SKYSCRAPER_HINT_LEFT_HAND", ::should_break_used_ads );
	add_hint_string( "NX_SKYSCRAPER_HINT_RIGHT_HAND", &"NX_SKYSCRAPER_HINT_RIGHT_HAND", ::should_break_used_attack );
	add_hint_string( "NX_SKYSCRAPER_HINT_PICK_UP_LASER", &"NX_SKYSCRAPER_HINT_PICK_UP_LASER", ::should_break_used );
	add_hint_string( "NX_SKYSCRAPER_HINT_GO_PRONE", &"NX_SKYSCRAPER_HINT_GO_PRONE", ::should_break_used_prone );
	add_hint_string( "NX_SKYSCRAPER_HINT_HOOK_UP", &"NX_SKYSCRAPER_HINT_HOOK_UP", ::should_break_used_hook );
}

// All mission specific flag_init() calls
mission_flag_inits()
{
// Drive up/Walk up flags
	flag_init( "flag_baker_nag1" );
	flag_init( "flag_baker_nag2" );
	flag_init( "flag_baker_nag3" );
	flag_init ("spawn_taxi_passengers");
	flag_init ("flag_fx_atrium");
	flag_init ("flag_fx_default");


// Elevator flags
	flag_init ( "play_elevator_pip");
	flag_init ( "outelevator_fg" );
	flag_init ( "baker_in_elevator" );
	flag_init ( "elevator_in_motion" );
	flag_init ( "shaft_player_past_pole" );
	flag_init ( "player_elevator_dive" );
	flag_init ( "player_made_first_elevator_jump" );
	flag_init ( "elevator_a_in_position" );
	flag_init ( "player_pressed_prone");
	flag_init ( "player_elevator_ready");
	flag_init ( "player_used_hook" );
	flag_init ( "elevator_b_in_position" );
	flag_init ( "shaftclimb_player_done" );

// Hangar Flags
	flag_init ("guys_in_room_dead");
	flag_init ("landing_pad_window_open");
	flag_init ("flag_fx_ext_up_high");

// Halon flags
	flag_init( "flag_halon_finished" );
	flag_init( "flag_halon_office_door" );
	flag_init( "flag_halon_catwalk_enemies_dead" );
	flag_init( "flag_halon_floor_enemies_rush" );
	flag_init( "flag_halon_main_encounter_start" );
	flag_init( "flag_halon_floor1_enemies_dead" );
	flag_init( "flag_halon_floor2_enemies_dead" );
	flag_init( "flag_player_danger" );
	flag_init( "flag_fx_halon" );

// VTOL flags
	flag_init ("force_vtol_move_d");
	flag_init ("force_vtol_move_e");
	flag_init ("force_vtol_move_f");
	flag_init ("force_vtol_move_g");
	flag_init ("vtol_spawn_wave_2");
	flag_init ("vtol_spawn_wave_3");
	flag_init ("vtol_enemies_dead");

// New VTOL flags
	flag_init( "flag_spawn_vtol" );
	flag_init( "flag_spawn_vtol2" );
	flag_init( "flag_uav_blow_shutters" );
	flag_init( "flag_baker_move" );
	flag_init( "flag_baker_move0" );
	flag_init( "flag_baker_move1" );
	flag_init( "flag_baker_move2" );
	flag_init( "flag_baker_move3" );
	flag_init( "flag_baker_pos1" );
	flag_init( "flag_baker_pos2" );
	flag_init( "flag_baker_end_pos" );
	flag_init( "flag_spawn_wave2" );
	flag_init( "flag_spawn_wave3" );
	flag_init( "flag_player_move_end" );
	flag_init( "flag_vtol_delete" );
	flag_init ("play_orbital_pip_1");
	flag_init ("play_orbital_pip_2");
	flag_init("flag_fx_fire_offices");
	flag_init( "flag_baker_blown_up" );
	flag_init( "flag_baker_explo_pos" );
	flag_init( "flag_fx_vtol");

// Anim flags
	flag_init ("flag_getup");
	flag_init ("flag_halon_gas_mask");
	flag_init ("flag_lab_exit_stairs");
	flag_init ("flag_lab_exit_stairs_corner");
	flag_init ("flag_vault_entrance");
	flag_init ("flag_retrieve_intel");
	flag_init ("flag_retrieve_intel_player");
	flag_init ("flag_security_talks_to_fp");
	
	// flag_init ("flag_elevator_shaft");
	flag_init ("flag_landing_pad_vtol_disembark");
	flag_init ("flag_landing_pad_vtol");
	flag_init ("flag_landing_pad_window");
	flag_init ("flag_landing_pad_climbjump_ally");
	// flag_init ("flag_landing_pad_climbjump_player");
	flag_init ("flag_landing_pad_window_player");
	// flag_init ("flag_landing_pad_edgeclimb");
	flag_init ("flag_elevator_red_disembark");
	flag_init ("vignette_lab_stealth_kill");
	flag_init ("flag_uav_crash");
	flag_init ("flag_atriumcrash");
	flag_init( "flag_atrum_crash_done" );
	flag_init ("flag_intro_ride");
	flag_init( "flag_vtol_floor_collapse_done" );
	flag_init ("elevator_out_lift_done");
	flag_init( "flag_vault_holo_p1" );
	flag_init( "flag_vault_holo_p2" );

// Lab Flags	
	flag_init( "flag_script_lab_to_vault_start" );
	flag_init( "flag_script_halon_gas_mask" );
	flag_init( "flag_dooropen_left" );
	flag_init( "flag_dooropen_right" );
	flag_init( "flag_lab_enter_dooropen_left" );
	flag_init( "flag_lab_enter_dooropen_right" );
	flag_init( "flag_fx_infiltration");
	flag_init( "flag_fx_robotics_01");
	flag_init( "flag_fx_vault");
	flag_init( "flag_security_doors_opening" );
	flag_init( "flag_lab_enter_player_through_door" );
	flag_init( "flag_baker_melee_in_progress" );
	flag_init( "flag_halon_robot_arms_moving" );	

	
// Rappel flags
	flag_init("flag_rappel_jump");
	flag_init("flag_swing_slide");
	flag_init("flag_bakersign");
	flag_init("flag_baker_section_01");
	flag_init("flag_baker_section_02");
	flag_init("flag_baker_section_03");
	flag_init("flag_bakerwindow");
	flag_init("flag_rappel_incline_start");
	flag_init("flag_rappel_incline_end");
	flag_init("flag_rappel_dodge_end");
	flag_init("flag_rappel_mid");
	flag_init("flag_rappel_big_explosion");
	flag_init( "flag_spawn_heli1" );
	flag_init( "flag_spawn_heli2" );
	flag_init( "flag_spawn_heli3" );
	flag_init( "flag_spawn_heli4" );
	flag_init( "flag_spawn_heli5" );
	flag_init("flag_rappel_jump_start");
	flag_init("flag_retether1");
	flag_init("flag_retether2");
	flag_init( "flag_rappel_swing_done" );
	flag_init("flag_fx_rappel_vision_1");
	flag_init("flag_lobby_airlock");
	flag_init("flag_lobby_walk");	
	flag_init("flag_security_baker");
	flag_init("flag_fx_rappel");



// outro flags

	flag_init( "flag_outro_start" );

	// AUDIO: Example music flag inits
	maps\nx_skyscraper_audio::flag_inits();
}

//*******************************************************************
// HINT BREAKS                                                      *
//                                                                  *
//*******************************************************************

should_break_used_ads()
{
	if( level._player AdsButtonPressed() )
	{
		return true;
	}
	else
	{
		return false;
	}
}

should_break_used_attack()
{
	if( level._player AttackButtonPressed() )
	{
		return true;
	}
	else
	{
		return false;
	}
}

should_break_used()
{
	if( level._player UseButtonPressed() )
	{
		return true;
	}
	else
	{
		return false;
	}
}

should_break_used_hook()
{
	if( level._player UseButtonPressed())
	{
		flag_set ("player_used_hook");
		return true;
	}
	else
	{
		return false;
	}
}

should_break_used_prone()
{
	if( level._player ButtonPressed( "BUTTON_B")  )
	{
		flag_set ("player_pressed_prone");
		return true;
	}
	if ( flag ("player_elevator_dive"))
	{
		return true;
	}
	else
	{
		return false;
	}
}

//*******************************************************************
//  OBJECTIVES                                                      *
//                                                                  *
//*******************************************************************

mission_objective_logic()
{
	// Wait for friendlies to spawn
	waittillframeend; 
	
	// README: wait_for_objective
	// maps\_nx_objective_util::wait_for_objective( objective_num, objective_text, curr_trigger, next_trigger );
 	// curr_trigger - the start point trigger of the objective
	// next_trigger - the end point trigger of the objective 
	// Uses script_origin nodes for pathing ( be sure to have a radius on the nodes )	

	switch ( level._start_point )
	{
		case "default":
		case "drive_up":	
			level waittill ("taxi_parked");
		case "lobby_enter":
			security_scan_objective();
			objective_complete( obj( "obj_go_through_security" ));
		case "elevator":
			wait_for_objective( obj( "obj_enter_elevator" ), &"NX_SKYSCRAPER_OBJ_ENTER_ELEVATOR", "obj_enter_elevator", "obj_reach_freight_shaft" ); 
			objective_complete( obj( "obj_enter_elevator" ));
		case "shaft":
			objective_add( obj( "obj_reach_freight_shaft" ), "current", &"NX_SKYSCRAPER_OBJ_REACH_FREIGHT_SHAFT" );
			Objective_OnEntity( obj( "obj_reach_freight_shaft" ), level.baker ); 
			setSavedDvar( "ObjectiveFadeTooFar", 1 );
			level waittill ("freight_elevator_stop");
			obj_marker_reach_freight_shaft_2 = GetEnt ("obj_marker_reach_freight_shaft_2", "targetname");
			Objective_Position( obj( "obj_reach_freight_shaft" ), obj_marker_reach_freight_shaft_2.origin );
			flag_wait ("flag_elevator_red_disembark");
			objective_complete( obj( "obj_reach_freight_shaft" ));
		case "window":
			//wait_for_objective( obj( "obj_enter_lab" ), &"NX_SKYSCRAPER_OBJ_ENTER_LAB", "obj_enter_lab", "obj_enter_vault" ); 
			//objective_complete( obj( "obj_enter_lab" ));
		case "hangar":
		case "lab_enter":
			objective_add( obj( "obj_lab_enter" ), "current", &"NX_SKYSCRAPER_OBJ_ENTER_LAB" );			
			flag_wait( "flag_script_lab_to_vault_start" );	
			objective_complete( obj( "obj_lab_enter" ));
		case "lab_layout_2":
		case "lab_to_vault":
			objective_add( obj( "obj_lab_to_vault" ), "current", "Get to the vault (placeholder)" );
			setSavedDvar( "ObjectiveFadeTooFar", 1 );
			objective_onentity( obj( "obj_lab_to_vault" ), level.baker );
			trigger_wait_targetname( "entering_vault" );
			objective_complete( obj( "obj_lab_to_vault" ));
			setSavedDvar( "ObjectiveFadeTooFar", 25 );
		case "vault":
			//wait_for_objective( obj( "obj_enter_vault" ), &"NX_SKYSCRAPER_OBJ_ENTER_VAULT", "obj_enter_vault", "obj_escape_lab" ); 
			objective_add( obj( "obj_enter_vault" ), "current", &"NX_SKYSCRAPER_OBJ_ENTER_VAULT" ); 
			level waittill ("macguffin_obtained");
			objective_complete( obj( "obj_enter_vault" ));
		case "lab_exit":
			//wait_for_objective( obj( "obj_escape_lab" ), &"NX_SKYSCRAPER_OBJ_ESCAPE_LAB", "obj_escape_lab", "trig_halon_button_use" ); 
			objective_add( obj( "obj_escape_lab" ), "current", &"NX_SKYSCRAPER_OBJ_ESCAPE_LAB" );			
			setSavedDvar( "ObjectiveFadeTooFar", 1 );
			objective_onentity( obj( "obj_escape_lab" ), level.baker );
			thread motor_objective();
			level waittill( "notify_security_doors_opening" );						
			objective_complete( obj( "obj_escape_lab_motor" ));
			objective_state( obj( "obj_escape_lab" ), "current" );
			objective_onentity( obj( "obj_escape_lab" ), level.baker );
			
			level waittill( "notify_baker_at_goal" );
			escape_marker = GetEnt( "origin_lab_exit_escape_1", "targetname" );
			Assert( IsDefined( escape_marker ));
			objective_onentity( obj( "obj_escape_lab" ), escape_marker ); 

			marker_move( "trig_lab_exit_escape_2" );
			marker_move( "trig_lab_exit_escape_3" );
			marker_move( "trig_lab_exit_escape_4" );			

			trigger_wait_targetname( "trig_halon_button_use" );
			objective_complete( obj( "obj_escape_lab" ));
			setSavedDvar( "ObjectiveFadeTooFar", 25 );
		case "halon":	
			objective_add( obj( "obj_halon" ), "current", &"NX_SKYSCRAPER_OBJ_HALON" );
			setSavedDvar( "ObjectiveFadeTooFar", 1 );
			halon_lab_door = GetEnt( "origin_spinning_emergency_light_3", "targetname" );
			Assert( IsDefined( halon_lab_door ));			
			Objective_OnEntity( obj( "obj_halon" ), level.baker );  
			Objective_AdditionalPosition( obj( "obj_halon" ), 0, halon_lab_door.origin );
			trigger_wait_targetname( "entering_robotics" );
			setSavedDvar( "ObjectiveFadeTooFar", 25 );
			objective_complete( obj( "obj_halon" ));
		case "vtol":				 
			// wait_for_objective( obj( "obj_destroy_vtol" ), &"NX_SKYSCRAPER_OBJ_DESTROY_VTOL", "obj_destroy_vtol", "obj_rappel_to_ground" ); 
			flag_wait( "flag_baker_move1" );
			objective_add( obj( "obj_destroy_vtol" ), "current", "NX_SKYSCRAPER_OBJ_DESTROY_VTOL" );
			Objective_OnEntity( obj( "obj_destroy_vtol" ), level.baker ); 
			level waittill ("laser_coordinates_received");
			objective_complete( obj( "obj_destroy_vtol" ));
		case "rappel":
			flag_wait( "flag_vtol_floor_collapse_done" );
			objective_add( obj( "obj_rappel_to_ground" ), "current", "NX_SKYSCRAPER_OBJ_RAPPEL_TO_GROUND" );
			level waittill ("office_enemies_dead");
			marker = GetEnt ("obj_marker_rappel_to_ground_1", "targetname");
			Objective_Position( obj( "obj_rappel_to_ground" ), marker.origin ); 
			level waittill ("rappel_hook_up_start");
			Objective_State( obj( "obj_rappel_to_ground" ), "active" );
			flag_wait ("flag_rappel_swing_done");
			objective_complete( obj( "obj_rappel_to_ground" ));
		case "lobby_crash":
		case "outro":
			objective_add( obj( "obj_outro" ), "current", "Get into the ex-fil vehicle." );
			setSavedDvar( "ObjectiveFadeTooFar", 1 );
			Objective_OnEntity( obj( "obj_outro" ), level.baker );
		case "no_game":
			break;
		default:
			AssertMsg( "No objectives set for this start point" );
	}
}

marker_move( tTrigger )
{
	trigger = GetEnt( tTrigger, "targetname" );
	Assert( IsDefined( trigger ));
	trigger waittill( "trigger" ); 
	escape_marker = GetEnt( trigger.target, "targetname" );
	Assert( IsDefined( escape_marker ));
	objective_onentity( obj( "obj_escape_lab" ), escape_marker );
}

motor_objective()
{
	level endon( "notify_security_doors_opening" );

	door_motor = GetEnt( "origin_motor_shoot", "targetname" );
	Assert( IsDefined( door_motor ));

	level waittill( "notify_lab_exit_motor_search_starting" );	
	objective_add( obj( "obj_escape_lab_motor" ), "current", "Find and shoot the motor (placeholder)" );	
	objective_state( obj( "obj_escape_lab" ), "active" );
	wait 5;

	objective_onentity( obj( "obj_escape_lab_motor" ), door_motor );
}

security_scan_objective()
{			
	objective_add( obj( "obj_go_through_security" ), "current", &"NX_SKYSCRAPER_OBJ_GO_THROUGH_SECURITY"); 
	// Objective_OnEntity( obj( "obj_go_through_security" ), level.baker ); 
	// level waittill ("player_scanner_ready");
	scanner_3 = GetEnt ("scanner_3", "script_noteworthy");
	scanner_4 = GetEnt ("scanner_4", "script_noteworthy");
	Objective_Position( obj( "obj_go_through_security" ), scanner_4.origin ); 
	Objective_AdditionalPosition( obj( "obj_go_through_security" ), 1, scanner_3.origin );
	Objective_SetPointerTextOverride( obj( "obj_go_through_security" ), "Look" );
	level waittill ("player_through_security");

	// Objective_OnEntity( 1, level.baker );
}

//*******************************************************************
//  DRIVE UP                                                        *
//                                                                  *
//*******************************************************************

drive_up_start()
{
	maps\nx_skyscraper_drive_up::drive_up_start();
}

drive_up()
{
	flag_set( "music_chk_drive_up" );
	maps\nx_skyscraper_drive_up::drive_up_sequence();
}


//*******************************************************************
// LOBBY ENTER                                                      *
//                                                                  *
//*******************************************************************

lobby_enter_start()
{
	maps\nx_skyscraper_drive_up::lobby_enter_start();

}

lobby_enter()
{
	flag_set( "music_chk_lobby_enter" );
	maps\nx_skyscraper_drive_up::lobby_enter_sequence();
}


//*******************************************************************
// ELEVATOR                                                         *
//                                                                  *
//*******************************************************************

elevator_start()
{
	maps\nx_skyscraper_elevator::elevator_start();
}

elevator()
{
	flag_set( "music_chk_elevator" );
	maps\nx_skyscraper_elevator::elevator_sequence();
}


//*******************************************************************
// SHAFT                                                            *
//                                                                  *
//*******************************************************************

shaft_start()
{
	maps\nx_skyscraper_elevator::shaft_start();
}

shaft()
{
	flag_set( "music_chk_shaft" );
	maps\nx_skyscraper_elevator::shaft_sequence();
}

//*******************************************************************
// WINDOW TO HANGAR                                                 *
//                                                                  *
//*******************************************************************

window_start()
{
	maps\nx_skyscraper_hangar::window_start();
}

window()
{
	flag_set( "music_chk_window" );
	maps\nx_skyscraper_hangar::window_sequence();
}

//*******************************************************************
// HANGAR                                                           *
//                                                                  *
//*******************************************************************

hangar_start()
{
	maps\nx_skyscraper_hangar::hangar_start();
}

hangar()
{
	flag_set( "music_chk_hangar" );
	maps\nx_skyscraper_hangar::hangar_sequence();
}


//*******************************************************************
// LAB ENTER                                                        *
//                                                                  *
//*******************************************************************

lab_enter_start()
{
	maps\nx_skyscraper_lab_enter::start_lab_enter();
}

lab_enter()
{
	flag_set( "music_chk_lab_enter" );
	maps\nx_skyscraper_lab_enter::sequence_lab_enter();
}

//*******************************************************************
// LAB TO VAULT                                                     *
//                                                                  *
//*******************************************************************

lab_to_vault_start()
{
	maps\nx_skyscraper_lab_to_vault::start_lab_to_vault();
}

lab_to_vault()
{
	flag_set( "music_chk_lab_to_vault" );
	maps\nx_skyscraper_lab_to_vault::sequence_lab_to_vault();
}

//*******************************************************************
// VAULT                                                            *
//                                                                  *
//*******************************************************************

vault_start()
{
	maps\nx_skyscraper_vault::vault_start();
}

vault()
{
	flag_set( "music_chk_vault" );
	maps\nx_skyscraper_vault::vault_sequence();
}

//*******************************************************************
// LAB EXIT                                                         *
//                                                                  *
//*******************************************************************

lab_exit_start()
{
	maps\nx_skyscraper_lab_exit::start_lab_exit();
}

lab_exit()
{
	flag_set( "music_chk_lab_exit" );
	maps\nx_skyscraper_lab_exit::sequence_lab_exit();
}

//*******************************************************************
// HALON 	                                                        *
//                                                                  *
//*******************************************************************

start_halon()
{
	maps\nx_skyscraper_halon::start_halon();
}

halon()
{
	flag_set( "music_chk_halon" );
	maps\nx_skyscraper_halon::sequence_halon();
}

//*******************************************************************
// VTOL                                                             *
//                                                                  *
//*******************************************************************

vtol_start()
{
	maps\nx_skyscraper_vtol::vtol_start();
}

vtol()
{
	flag_set( "music_chk_vtol" );
	maps\nx_skyscraper_vtol::vtol_sequence();
}

//*******************************************************************
// RAPPEL                                                           *
//                                                                  *
//*******************************************************************

rappel_start()
{
	maps\nx_skyscraper_rappel::rappel_start();
}

rappel()
{
	flag_set( "music_chk_rappel" );
	maps\nx_skyscraper_rappel::rappel_sequence();
}

//*******************************************************************
// OUTRO                                                           *
//                                                                  *
//*******************************************************************

outro_start()
{
	maps\nx_skyscraper_outro::outro_start();
}

outro()
{
	flag_set( "music_chk_outro" );
	maps\nx_skyscraper_outro::outro_sequence();
}
