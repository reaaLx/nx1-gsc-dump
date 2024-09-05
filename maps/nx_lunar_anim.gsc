//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Anim Support													**
//                                                                          **
//    Created: DATE - CREATOR												**
//                                                                          **
//****************************************************************************

#include maps\_anim;
#include maps\_utility;
#include common_scripts\utility;
#include maps\_hud_util;
#include maps\_nx_vignette_util;

main() 
{
	generic_human();
	script_models();
	dialog();
	lsp_door_anims();
	player_anims();
	charlie_anims();
	vehicle_anims();

	// Anim Vignettes
	level thread vignettes();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Vignettes is threaded at the start of the mission, each anim dept
// implemented vignette should be threaded here a block until triggered
vignettes()
{
	switch ( level._start_point )
	{
		case "default":
		case "no_game_moon":
		case "intro":			
		case "rover_chase":
		case "get_to_the_armory": 

			// tagTC<note> - INTEGRATED, nx_lunar.gsc in breach_group_01_thread
			// Vehicle bay rover hatch breach: 2 opfor, 2 civ
			// level thread vignette_register( ::vignette_vehiclebay_breach_spawn, "vignette_vh_bay_breach" ); 
		
			// Vehicle bay player stumbles through airlock: player_rig
			level thread vignette_register( ::vignette_vehiclebay_breach_player_enters_airlock, "vignette_vh_bay_breach" ); 

			// topfloor_ breach vignette
			level thread vignette_register( ::top_floor_breach_spawn, "sfx_ext_surface_engsuit_semipress" );

			// Scientist run through the first hub lower floor: civ
			//level thread vignette_register( ::vignette_scientist_run_01_spawn, "scientist_run" );

			// New Taser Scene
			// KenM - Calling this from GTTA script for AI victim
			// level thread vignette_register( ::taser_spawn, "vignette_taser" );

			// Falcon gives you a Taser
			level thread vignette_register( ::vignette_falcon_taser_handoff, "falcon_taser_handoff" );

			// Falcon tazes an enemy who falls over the railing: ally, civ
			// level thread vignette_register( ::vignette_falcon_taser_spawn, "falcon_taser_vignette" );

			// Falcon waits outside the airlock and loops.
			// level thread vignette_register( ::armory_entrance_falcon_spawn, "vignette_armory_entrance" );

			// Spider waits outside the airlock and walks backwards to the door.
			level thread vignette_register( ::armory_entrance_spider_spawn, "vignette_armory_entrance_spider" );

			// Player enters the armory and Eagle hands you a helmet.
			level thread vignette_register( ::armory_entrance_player_spawn, "vignette_armory_enter" );

		case "armory_module":

			// Armory Breach - Spider Dies
			// tagTC<note> - INTEGRATED	in nx_lunar_escape_interior.gsc in ally_armory_breach_vignette
			// level thread vignette_register( ::armory_breach_spawn, "vignette_armory_breach" );

		case "life_support_module":
		case "living_module":

			// Scientist dead in the living hallway
			// tagTC<note> - INTEGRATED	in nx_lunar_escape_interior.gsc
			// level thread vignette_register( ::scientist_dead1_spawn, "vignette_scientist_dead1" );

		case "exterior_vista":
		case "airlock_exterior":
		case "mining_valley":
		case "rough_terrain":		
		case "rover_battle":
			
			// Falcon death scene
			level thread vignette_register( ::falcon_death_spawn, "vignette_falcon_death" );

		case "into_shadows":
		case "vehicle_bay_return":
		case "take_back_control":
			
			// tagTC<note> - INTEGRATED, nx_lunar_take_back_control.gsc, in take_back_control_greeting_vignette
			// vignette_register( ::end_greet_spawn, "vignette_end_greet" );

			// tagTC<note> - INTEGRATED, nx_lunar_take_back_control.gsc
			// End controls scene
			// level thread vignette_register( ::end_controls_spawn, "vignette_end_controls" );

		case "take_back_control_ending":
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree("generic_human");
generic_human()
{

	// wakeup in vehicle bay
	level._scr_anim[ "ally_01" ][ "vehiclebay_wakeup" ] = %nx_tp_lunar_vehiclebay_wakeup_ally_01;
	level._scr_anim[ "ally_02" ][ "vehiclebay_wakeup" ] = %nx_tp_lunar_vehiclebay_wakeup_ally_02;
	addNotetrack_customFunction( "ally_02", "rover_fire_bullet", ::wakeup_ally_shot );
	// addNotetrack_customFunction( "ally_01", "ally_hit_ground", maps\nx_lunar_get_to_the_armory::fx_lunar_vehiclebay_wakeup_ally_01_hit_ground );
	addNotetrack_customFunction( "ally_02", "ally_shot", maps\nx_lunar_get_to_the_armory::fx_lunar_vehiclebay_wakeup_ally_02_shot );
	// addNotetrack_customFunction( "ally_02", "ally_hit_ground", maps\nx_lunar_get_to_the_armory::fx_lunar_vehiclebay_wakeup_ally_02_hit_ground );


	// Hall Explosion 
	level._scr_anim[ "opfor" ][ "hall_explosion" ] = %nx_tp_lunar_hall_explode_opfor;

	// Worker at airlock door
	level._scr_anim[ "worker" ][ "airlock_door_death" ] = %nx_tp_lunar_airlockdeath_ally_01;
	level._scr_sound[ "worker" ][ "airlock_door_death" ] = "scn_lunar_engineer_killed";	

	// generic ally door open/breach
	level._scr_anim[ "eagle" ][ "ally_door_breach" ] = %nx_tp_lunar_ally_breach_ally_01;
	level._scr_anim[ "hawk" ][ "ally_door_breach" ] = %nx_tp_lunar_ally_breach_ally_01;
	level._scr_anim[ "falcon" ][ "ally_door_breach" ] = %nx_tp_lunar_ally_breach_ally_02;
	addNotetrack_customFunction( "eagle", "door_open", ::ally_door_keypad_cycle );
	addNotetrack_customFunction( "hawk", "door_open", ::ally_door_keypad_cycle );
	
	level._scr_anim[ "eagle" ][ "ally_door_breach_idle" ] = [ %tp_moon_coverR_stand_alert_idle ];
	level._scr_anim[ "hawk" ][ "ally_door_breach_idle" ] = [ %tp_moon_coverR_stand_alert_idle ];
	level._scr_anim[ "falcon" ][ "ally_door_breach_idle" ] = [ %tp_moon_coverL_stand_alert_idle ];


	// Armory Enter - Falcon and Spider wait outside
	// KenM note: Falcon and Spider have been swapped for naiming consistency
	level._scr_anim[ "spider" ][ "armory_entrance_spider" ][ 0 ] = %nx_tp_lunar_armory_entrance_falcon;
	level._scr_anim[ "falcon" ][ "armory_entrance_falcon" ] = %nx_tp_lunar_armory_entrance_spider;

	// Armory Enter - Eagle hands you helmet.
	level._scr_anim[ "eagle" ][ "armory_entrance_player" ] = %nx_tp_lunar_armory_entrance_eagle;

	// Armory Breach - Looping Anims
	level._scr_anim[ "eagle" ][ "armory_breach_loop" ][ 0 ] = %nx_tp_lunar_armory_breach_eagle_loop;
	level._scr_anim[ "spider" ][ "armory_breach_loop" ][ 0 ] = %nx_tp_lunar_armory_breach_spider_loop;
	level._scr_anim[ "falcon" ][ "armory_breach_loop" ][ 0 ] = %nx_tp_lunar_armory_breach_falcon_loop;

	// Armory Breach - Spider Dies
	level._scr_anim[ "eagle" ][ "armory_breach_explosion" ] = %nx_tp_lunar_armory_breach_eagle;
	level._scr_anim[ "falcon" ][ "armory_breach_explosion" ] = %nx_tp_lunar_armory_breach_falcon;
	level._scr_anim[ "spider" ][ "armory_breach_explosion" ] = %nx_tp_lunar_armory_breach_spider;

	// opfor door breach 
	level._scr_anim[ "opfor_01" ][ "opfor_door_breach" ] = %nx_tp_lunar_opfor_door_breach_opfor_01_breach;
	// level._scr_sound[ "opfor_01" ][ "opfor_door_breach" ] = "scn_lunar_door_breach2";
	level._scr_anim[ "opfor_02" ][ "opfor_door_breach" ] = %nx_tp_lunar_opfor_door_breach_opfor_02_breach;
	level._scr_anim[ "opfor_01" ][ "opfor_door_breach_loop" ][ 0 ] = %nx_tp_lunar_opfor_door_breach_opfor_01_loop;
	level._scr_anim[ "opfor_02" ][ "opfor_door_breach_loop" ][ 0 ] = %nx_tp_lunar_opfor_door_breach_opfor_02_loop;
	level._scr_anim[ "opfor_01" ][ "opfor_door_breach_detonate" ] = %nx_tp_lunar_opfor_door_breach_opfor_01_detonate;
	level._scr_anim[ "opfor_02" ][ "opfor_door_breach_detonate" ] = %nx_tp_lunar_opfor_door_breach_opfor_02_detonate;

	// hawk intro anims
	level._scr_anim[ "hawk_food" ][ "hawk_intro" ] = %nx_tp_lunar_hawkentrance_opfor_01;
	level._scr_anim[ "hawk" ][ "hawk_intro" ] = %nx_tp_lunar_hawkentrance_hawk_01;
	level._scr_sound[ "hawk" ][ "hawk_intro" ] = "scn_vandenberg_meet";

	// vehicle bay airlock breach anims
	level._scr_anim[ "civ_01" ][ "vehiclebay_breach_loop" ][ 0 ] = %nx_tp_lunar_vehiclebay_breach_loop_civ_01;
	level._scr_anim[ "civ_02" ][ "vehiclebay_breach_loop" ][ 0 ] = %nx_tp_lunar_vehiclebay_breach_loop_civ_02;
	level._scr_anim[ "civ_01" ][ "vehiclebay_breach" ] = %nx_tp_lunar_vehiclebay_breach_civ_01;
	level._scr_anim[ "civ_02" ][ "vehiclebay_breach" ] = %nx_tp_lunar_vehiclebay_breach_civ_02;
	level._scr_anim[ "opfor_01" ][ "vehiclebay_breach" ] = %nx_tp_lunar_vehiclebay_breach_opfor_01;
	// level._scr_sound[ "opfor_01" ][ "vehiclebay_breach" ] = "scn_lunar_door_breach1";
	level._scr_anim[ "opfor_02" ][ "vehiclebay_breach" ] = %nx_tp_lunar_vehiclebay_breach_opfor_02;

	addNotetrack_customFunction( "opfor_01", "breach_charge", ::breach_charge );
	addNotetrack_customFunction( "opfor_01", "breach_detonate", ::breach_detonate );

	// Vignette civilians as script_models
	level._scr_model[ "model_civ_01" ] = "nx_civ_astronaut_body_complete_a";
	level._scr_model[ "model_civ_02" ] = "nx_civ_astronaut_body_complete_b";
	level._scr_model[ "model_civ_03" ] = "nx_civ_astronaut_body_complete_c";
	level._scr_model[ "model_civ_04" ] = "nx_civ_astronaut_body_complete_d";
	level._scr_model[ "model_civ_05" ] = "nx_civ_astronaut_body_complete_e";
	level._scr_model[ "model_civ_06" ] = "nx_civ_astronaut_body_complete_c";
	level._scr_model[ "model_civ_07" ] = "nx_civ_astronaut_body_complete_b";
	level._scr_animtree[ "model_civ_01" ] = #animtree;
	level._scr_animtree[ "model_civ_02" ] = #animtree;
	level._scr_animtree[ "model_civ_03" ] = #animtree;
	level._scr_animtree[ "model_civ_04" ] = #animtree;
	level._scr_animtree[ "model_civ_05" ] = #animtree;
	level._scr_animtree[ "model_civ_06" ] = #animtree;
	level._scr_animtree[ "model_civ_07" ] = #animtree;

	// Vehicle bay civilians run up stairs
	level._scr_anim[ "model_civ_03" ][ "civ_up_stairs" ] = %tp_moon_civ_stair_up;
	level._scr_anim[ "model_civ_04" ][ "civ_up_stairs" ] = %tp_moon_civ_stair_turn_up;

	// Hub room civilians run away
	level._scr_anim[ "model_civ_01" ][ "civ_hub_room" ] = %tp_moon_civ_run_away_door_a;
	level._scr_anim[ "model_civ_02" ][ "civ_hub_room" ] = %tp_moon_civ_run_away_door_b;
	level._scr_anim[ "model_civ_03" ][ "civ_hub_room" ] = %tp_moon_civ_run_away_door_c;
	level._scr_anim[ "model_civ_04" ][ "civ_hub_room" ] = %tp_moon_civ_run_away_door_d;
	level._scr_anim[ "model_civ_05" ][ "civ_hub_room" ] = %tp_moon_civ_run_away_door_e;
	level._scr_anim[ "model_civ_06" ][ "civ_hub_room" ] = %tp_moon_civ_run_away_door_f;
	level._scr_anim[ "model_civ_07" ][ "civ_hub_room" ] = %tp_moon_civ_run_away_door_g;
	addNotetrack_customFunction( "model_civ_02", "door_close", ::close_hub_door );
	addNotetrack_customFunction( "model_civ_04", "explosion", ::hub_room_explosion );

	// Command center civilians get shot
	level._scr_anim[ "model_civ_01" ][ "cnc_civ_shot" ] = %tp_moon_civ_run_control_center_a;
	level._scr_anim[ "model_civ_02" ][ "cnc_civ_shot" ] = %tp_moon_civ_run_control_center_b;
	level._scr_anim[ "model_civ_03" ][ "cnc_civ_shot" ] = %tp_moon_civ_run_control_center_c;
	level._scr_anim[ "model_civ_04" ][ "cnc_civ_shot" ] = %tp_moon_civ_run_control_center_d;
	level._scr_anim[ "model_civ_05" ][ "cnc_civ_shot" ] = %tp_moon_civ_run_control_center_e;
	level._scr_anim[ "model_civ_06" ][ "cnc_civ_shot" ] = %tp_moon_civ_run_control_center_f;

	addNotetrack_customFunction( "model_civ_01", "bullet_hit", ::cnc_enemy_shoots_civ_01 );
	addNotetrack_customFunction( "model_civ_02", "bullet_hit", ::cnc_enemy_shoots_civ_02 );
	addNotetrack_customFunction( "model_civ_03", "bullet_hit", ::cnc_enemy_shoots_civ_03 );
	addNotetrack_customFunction( "model_civ_04", "bullet_hit", ::cnc_enemy_shoots_civ_04 );
	addNotetrack_customFunction( "model_civ_05", "bullet_hit", ::cnc_enemy_shoots_civ_05 );
	addNotetrack_customFunction( "model_civ_06", "bullet_hit", ::cnc_enemy_shoots_civ_06 );

	// topfloor breach
	level._scr_anim[ "model_civ_01" ][ "top_floor_breach" ] = %nx_tp_lunar_topfloorbreach_ally1;
	level._scr_anim[ "model_civ_02" ][ "top_floor_breach" ] = %nx_tp_lunar_topfloorbreach_ally2;
	level._scr_anim[ "model_civ_03" ][ "top_floor_breach" ] = %nx_tp_lunar_topfloorbreach_ally3;
	level._scr_anim[ "model_civ_04" ][ "top_floor_breach" ] = %nx_tp_lunar_topfloorbreach_ally4;
	level._scr_anim[ "vignette_playerlegs" ][ "top_floor_breach" ] = %nx_tp_lunar_topfloorbreach_playerlegs;
	level._scr_anim[ "model_civ_05" ][ "top_floor_breach" ] = %nx_tp_lunar_topfloorbreach_ally5;
	level._scr_anim[ "model_civ_06" ][ "top_floor_breach" ] = %nx_tp_lunar_topfloorbreach_ally6;

	// new taser scene
	level._scr_anim[ "falcon" ][ "taser" ] = %nx_tp_lunar_taser_ally;
	level._scr_anim[ "opfor" ][ "taser" ] = %nx_tp_lunar_taser_opfor;
	addNotetrack_customFunction( "opfor", "taser_fx", ::falcon_shoots_taser );

	level._scr_anim[ "falcon" ][ "taser_loop" ][0] = %nx_tp_lunar_taser_ally_loop;
	level._scr_anim[ "falcon" ][ "taser_handoff" ] = %nx_tp_lunar_taser_ally_taser_hand_off;

	// scientist running
	level._scr_anim[ "civ01" ][ "scientist_run_01" ] = %nx_tp_lunar_scientistrun_ally1;
	level._scr_anim[ "civ02" ][ "scientist_run_02" ] = %nx_tp_lunar_scientistrun_ally2;

	// falcon taser
	level._scr_anim[ "falcon" ][ "falcon_taser_handoff" ] = %nx_tp_lunar_taser_handoff;
	addNotetrack_customFunction( "falcon", "taser_release", ::taser_release );
	level._scr_anim[ "falcon" ][ "falcon_taser" ] = %nx_tp_lunar_taserkill_ally_01;
	level._scr_anim[ "opfor" ][ "falcon_taser" ] = %nx_tp_lunar_taserkill_opfor_01;
	
	//scientist hallway dead scene
	level._scr_anim[ "vignette_scientist_dead1" ][ "scientist_dead1" ] = %nx_tp_lunar_lostcause_scientist;
	level._scr_anim[ "eagle" ][ "scientist_dead1" ] = %nx_tp_lunar_lostcause_ally;
	
	// falcon death
	level._scr_anim[ "falcon" ][ "falcon_death" ] = %nx_tp_lunar_falcon_death_falcon;
	addNotetrack_customFunction( "falcon", "injured_swap", ::falcon_injured );
	level._scr_anim[ "eagle" ][ "falcon_death" ] = %nx_tp_lunar_falcon_death_eagle;
	level._scr_anim[ "vignette_falcondeath_opfor1" ][ "falcon_death" ] = %nx_tp_lunar_falcon_death_opfor;

	// end greet
	level._scr_anim[ "end_greet_body" ][ "end_greet" ] 	= %nx_tp_lunar_endgreet_body;
	addNotetrack_customFunction( "end_greet_body", "vignette_remove_gun", ::vignette_remove_gun );
	level._scr_anim[ "hawk" ][ "end_greet" ] 		= %nx_tp_lunar_endgreet_hawk;
	addNotetrack_customFunction( "hawk", "vignette_stow_gun", ::vignette_stow_gun );
	addNotetrack_customFunction( "hawk", "vignette_use_breacher", ::vignette_use_breacher );
	level._scr_anim[ "pigeon" ][ "end_greet" ] 		= %nx_tp_lunar_endgreet_ally1;
	level._scr_sound[ "hawk" ][ "end_greet" ]		= "scn_vandenberg_meet";
	
	//end_controls
	//enemy dies
	level._scr_anim[ "enemy_body" ][ "end_controls_enemy_die" ] = %nx_tp_lunar_endcontrols_enemy_die;

	//hawk and crow enter their loops
	level._scr_anim[ "hawk" ][ "end_controls_enter" ] = %nx_tp_lunar_endcontrols_hawk_enter;
	level._scr_anim[ "crow" ][ "end_controls_enter" ] = %nx_tp_lunar_endcontrols_crow_enter;
	//hawk and crow lot
	level._scr_anim[ "hawk" ][ "end_controls_loop" ][0] = %nx_tp_lunar_endcontrols_hawk_loop;
	level._scr_anim[ "crow" ][ "end_controls_loop" ][0] = %nx_tp_lunar_endcontrols_crow_loop;
	//vignette
	level._scr_anim[ "enemy_body" ][ "end_controls" ] = %nx_tp_lunar_endcontrols_enemy_dead_remove;
	level._scr_anim[ "hawk" ][ "end_controls" ] = %nx_tp_lunar_endcontrols_hawk_exit;
	level._scr_anim[ "crow" ][ "end_controls" ] = %nx_tp_lunar_endcontrols_crow_exit;
}

#using_animtree("script_model");
script_models()
{
	//Charlie Intro
	level._scr_animtree[ "helmet_charlie" ] = #animtree;
	level._scr_anim[ "helmet_charlie" ][ "rover_intro_drive" ] = %nx_pr_lunar_rover_intro_drive_helmet_charlie;
	level._scr_anim[ "helmet_charlie" ][ "rover_intro_idle" ] = %nx_pr_lunar_rover_intro_idle_helmet_charlie;
	level._scr_anim[ "helmet_charlie" ][ "rover_intro_jump" ] = %nx_pr_lunar_rover_intro_jump_helmet_charlie;
	level._scr_model[ "helmet_charlie" ] = "nx_pr_lunar_helm_scripted";

	level._scr_animtree[ "helmet_player" ] = #animtree;
	level._scr_anim[ "helmet_player" ][ "rover_intro_drive" ] = %nx_pr_lunar_rover_intro_drive_helmet_player;
	level._scr_model[ "helmet_player" ] = "nx_pr_lunar_helm_scripted";

	// Tower Collapse
	level._scr_animtree[ "twr_bottom" ] = #animtree;
	level._scr_anim[ "twr_bottom" ][ "tower_fall" ] = %nx_pr_lunar_tower_collapse_twr_bottom;
	level._scr_model[ "twr_bottom" ] = "nx_pr_lunar_tower_bottom";

	level._scr_animtree[ "twr_top" ] = #animtree;
	level._scr_anim[ "twr_top" ][ "tower_fall" ] = %nx_pr_lunar_tower_collapse_twr_top;
	level._scr_model[ "twr_top" ] = "nx_pr_lunar_tower_top";

	// tagTC<note> - removing rover crash tent anims for now (was causing errors when attempting to exclude ken's geo)
	// Rover Crash
	// level._scr_animtree[ "tent" ] = #animtree;
	// level._scr_anim[ "tent" ][ "rover_crash" ] = %nx_pr_lunar_rovercrash_tent_anim;
	// level._scr_model[ "tent" ] = "nx_pr_lunar_rovercrash_tent";

	// Vehicle Bay Breach
	level._scr_animtree[ "helmet_player" ] = #animtree;
	level._scr_anim[ "helmet_player" ][ "vehiclebay_breach_player" ] = %nx_pr_lunar_vehiclebay_breach_helmet;
	level._scr_model[ "helmet_player" ] = "nx_pr_lunar_helm_scripted";
	addNotetrack_customFunction( "helmet_player", "spawn_helmet", ::spawn_helmet );
	addNotetrack_customFunction( "helmet_player", "helmet_hits_ground", ::helmet_hits_ground );

	// Hall Explosion Debris 
	level._scr_animtree[ "debris_01" ] = #animtree;
	level._scr_anim[ "debris_01" ][ "hall_explosion" ] = %nx_pr_lunar_hall_explode_debris_01;
	level._scr_sound[ "debris_01" ][ "hall_explosion" ] = "nx_lunar_hallway_explode";
	level._scr_model[ "debris_01" ] = "nx_pr_lunar_halldebris0";

	level._scr_animtree[ "debris_02" ] = #animtree;
	level._scr_anim[ "debris_02" ][ "hall_explosion" ] = %nx_pr_lunar_hall_explode_debris_02;
	level._scr_model[ "debris_02" ] = "nx_pr_lunar_halldebris1";

	// Taser Handoff

	level._scr_animtree[ "taser" ] = #animtree;
	level._scr_anim[ "taser" ][ "taser" ] = %nx_pr_lunar_taser;
	level._scr_model[ "taser" ] = "weapon_taser";

	level._scr_animtree[ "taser" ] = #animtree;
	level._scr_anim[ "taser" ][ "taser_loop" ][0] = %nx_pr_lunar_taser_loop;
	level._scr_model[ "taser" ] = "weapon_taser";

	level._scr_animtree[ "taser" ] = #animtree;
	level._scr_anim[ "taser" ][ "taser_handoff" ] = %nx_pr_lunar_taser_hand_off;
	level._scr_model[ "taser" ] = "weapon_taser";
	addNotetrack_customFunction( "taser", "prop_delete", ::taser_catch );

	// CNC civilian slaughter chairs
	level._scr_animtree[ "chair_01" ] = #animtree;
	level._scr_anim[ "chair_01" ][ "cnc_civ_shot" ] = %nx_pr_lunar_swivel_chair_e;
	level._scr_model[ "chair_01" ] = "com_office_chair_black";
	level._scr_animtree[ "chair_02" ] = #animtree;
	level._scr_anim[ "chair_02" ][ "cnc_civ_shot" ] = %nx_pr_lunar_swivel_chair_f;
	level._scr_model[ "chair_02" ] = "com_office_chair_black";

	// Armory Entrance - Player enters airlock and grabs helmet.
	level._scr_animtree[ "cabinet_door" ] = #animtree;
	level._scr_anim[ "cabinet_door" ][ "armory_entrance_player" ] = %nx_pr_lunar_armory_entrance_cabinet_door;
	level._scr_model[ "cabinet_door" ] = "nx_pr_lunar_armory_cabinet_door";

	level._scr_animtree[ "helmet" ] = #animtree;
	level._scr_anim[ "helmet" ][ "armory_entrance_player" ] = %nx_pr_lunar_armory_entrance_helmet;
	level._scr_model[ "helmet" ] = "nx_pr_lunar_helm_scripted";
	addNotetrack_customFunction( "helmet", "hide_helmet", ::hide_helmet );

	// Armory Breach Explosion - Props on shelves.
	level._scr_animtree[ "falcon_crate" ] = #animtree;
	level._scr_anim[ "falcon_crate" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_falcon_crate_02;
	level._scr_model[ "falcon_crate" ] = "nx_moonbase_crate_01";

	level._scr_animtree[ "spider_crate" ] = #animtree;
	level._scr_anim[ "spider_crate" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_spider_crate_01;
	level._scr_model[ "spider_crate" ] = "nx_container_02";
	addNotetrack_customFunction( "spider_crate", "prop_delete", ::prop_delete );

	level._scr_animtree[ "crate_01" ] = #animtree;
	level._scr_anim[ "crate_01" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_01;
	level._scr_model[ "crate_01" ] = "nx_ammobox_02_open";

	level._scr_animtree[ "crate_02" ] = #animtree;
	level._scr_anim[ "crate_02" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_02;
	level._scr_model[ "crate_02" ] = "nx_ammobox_02";

	level._scr_animtree[ "crate_03" ] = #animtree;
	level._scr_anim[ "crate_03" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_03;
	level._scr_model[ "crate_03" ] = "nx_ammobox_02";

	level._scr_animtree[ "crate_04" ] = #animtree;
	level._scr_anim[ "crate_04" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_04;
	level._scr_model[ "crate_04" ] = "nx_ammobox_02";

	level._scr_animtree[ "crate_05" ] = #animtree;
	level._scr_anim[ "crate_05" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_05;
	level._scr_model[ "crate_05" ] = "nx_ammobox_02";

	level._scr_animtree[ "crate_06" ] = #animtree;
	level._scr_anim[ "crate_06" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_06;
	level._scr_model[ "crate_06" ] = "nx_ammobox_02";

	level._scr_animtree[ "crate_07" ] = #animtree;
	level._scr_anim[ "crate_07" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_07;
	level._scr_model[ "crate_07" ] = "nx_ammobox_02";

	level._scr_animtree[ "crate_08" ] = #animtree;
	level._scr_anim[ "crate_08" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_08;
	level._scr_model[ "crate_08" ] = "nx_ammobox_02";

	level._scr_animtree[ "crate_09" ] = #animtree;
	level._scr_anim[ "crate_09" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_09;
	level._scr_model[ "crate_09" ] = "nx_ammobox_03_open";

	level._scr_animtree[ "crate_10" ] = #animtree;
	level._scr_anim[ "crate_10" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_10;
	level._scr_model[ "crate_10" ] = "nx_ammobox_03_open";

	level._scr_animtree[ "crate_11" ] = #animtree;
	level._scr_anim[ "crate_11" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_11;
	level._scr_model[ "crate_11" ] = "nx_ammobox_03_open";

	level._scr_animtree[ "crate_12" ] = #animtree;
	level._scr_anim[ "crate_12" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_12;
	level._scr_model[ "crate_12" ] = "nx_ammobox_03";

	level._scr_animtree[ "crate_13" ] = #animtree;
	level._scr_anim[ "crate_13" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_13;
	level._scr_model[ "crate_13" ] = "nx_ammobox_03";
	addNotetrack_customFunction( "crate_13", "prop_delete", ::prop_delete );

	level._scr_animtree[ "crate_14" ] = #animtree;
	level._scr_anim[ "crate_14" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_14;
	level._scr_model[ "crate_14" ] = "nx_ammobox_03";

	level._scr_animtree[ "crate_15" ] = #animtree;
	level._scr_anim[ "crate_15" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_15;
	level._scr_model[ "crate_15" ] = "nx_ammobox_03";

	level._scr_animtree[ "crate_16" ] = #animtree;
	level._scr_anim[ "crate_16" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_16;
	level._scr_model[ "crate_16" ] = "nx_ammobox_03";

	level._scr_animtree[ "crate_17" ] = #animtree;
	level._scr_anim[ "crate_17" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_17;
	level._scr_model[ "crate_17" ] = "nx_ammobox_03";
	addNotetrack_customFunction( "crate_17", "prop_delete", ::prop_delete );

	level._scr_animtree[ "crate_18" ] = #animtree;
	level._scr_anim[ "crate_18" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_18;
	level._scr_model[ "crate_18" ] = "nx_ammobox_03";

	level._scr_animtree[ "crate_19" ] = #animtree;
	level._scr_anim[ "crate_19" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_19;
	level._scr_model[ "crate_19" ] = "nx_ammobox_03";

	level._scr_animtree[ "crate_20" ] = #animtree;
	level._scr_anim[ "crate_20" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_20;
	level._scr_model[ "crate_20" ] = "nx_ammobox_03";

	level._scr_animtree[ "crate_21" ] = #animtree;
	level._scr_anim[ "crate_21" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_21;
	level._scr_model[ "crate_21" ] = "nx_ammobox_03";
	addNotetrack_customFunction( "crate_21", "prop_delete", ::prop_delete );

	level._scr_animtree[ "crate_22" ] = #animtree;
	level._scr_anim[ "crate_22" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_22;
	level._scr_model[ "crate_22" ] = "nx_ammobox_03";

	level._scr_animtree[ "crate_23" ] = #animtree;
	level._scr_anim[ "crate_23" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_23;
	level._scr_model[ "crate_23" ] = "nx_ammobox_01";

	level._scr_animtree[ "crate_24" ] = #animtree;
	level._scr_anim[ "crate_24" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_24;
	level._scr_model[ "crate_24" ] = "nx_ammobox_01";

	level._scr_animtree[ "crate_25" ] = #animtree;
	level._scr_anim[ "crate_25" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_25;
	level._scr_model[ "crate_25" ] = "nx_ammobox_01";

	level._scr_animtree[ "crate_26" ] = #animtree;
	level._scr_anim[ "crate_26" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_26;
	level._scr_model[ "crate_26" ] = "nx_ammobox_01";
	addNotetrack_customFunction( "crate_26", "prop_delete", ::prop_delete );

	level._scr_animtree[ "crate_27" ] = #animtree;
	level._scr_anim[ "crate_27" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_27;
	level._scr_model[ "crate_27" ] = "nx_ammobox_01";
	addNotetrack_customFunction( "crate_27", "prop_delete", ::prop_delete );

	level._scr_animtree[ "crate_28" ] = #animtree;
	level._scr_anim[ "crate_28" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_28;
	level._scr_model[ "crate_28" ] = "nx_ammobox_01";
	addNotetrack_customFunction( "crate_28", "prop_delete", ::prop_delete );

	level._scr_animtree[ "crate_29" ] = #animtree;
	level._scr_anim[ "crate_29" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_29;
	level._scr_model[ "crate_29" ] = "nx_ammobox_01";
	addNotetrack_customFunction( "crate_29", "prop_delete", ::prop_delete );

	level._scr_animtree[ "crate_30" ] = #animtree;
	level._scr_anim[ "crate_30" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_30;
	level._scr_model[ "crate_30" ] = "nx_ammobox_01";
	addNotetrack_customFunction( "crate_30", "prop_delete", ::prop_delete );

	level._scr_animtree[ "crate_31" ] = #animtree;
	level._scr_anim[ "crate_31" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_31;
	level._scr_model[ "crate_31" ] = "nx_moonbase_plastic_crate_02";

	level._scr_animtree[ "crate_32" ] = #animtree;
	level._scr_anim[ "crate_32" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_32;
	level._scr_model[ "crate_32" ] = "nx_moonbase_plastic_crate_02";

	level._scr_animtree[ "crate_33" ] = #animtree;
	level._scr_anim[ "crate_33" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_33;
	level._scr_model[ "crate_33" ] = "nx_moonbase_plastic_crate_04";

	level._scr_animtree[ "crate_34" ] = #animtree;
	level._scr_anim[ "crate_34" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_34;
	level._scr_model[ "crate_34" ] = "nx_moonbase_plastic_crate_04";

	level._scr_animtree[ "crate_35" ] = #animtree;
	level._scr_anim[ "crate_35" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_35;
	level._scr_model[ "crate_35" ] = "nx_moonbase_plastic_crate_04";

	level._scr_animtree[ "crate_36" ] = #animtree;
	level._scr_anim[ "crate_36" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_36;
	level._scr_model[ "crate_36" ] = "nx_moonbase_plastic_crate_01";

	level._scr_animtree[ "crate_37" ] = #animtree;
	level._scr_anim[ "crate_37" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_37;
	level._scr_model[ "crate_37" ] = "nx_moonbase_plastic_crate_01";

	level._scr_animtree[ "crate_38" ] = #animtree;
	level._scr_anim[ "crate_38" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_ammo_crate_38;
	level._scr_model[ "crate_38" ] = "nx_moonbase_plastic_crate_03";

	level._scr_animtree[ "cabinet_01" ] = #animtree;
	level._scr_anim[ "cabinet_01" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_cabinet_01;
	level._scr_model[ "cabinet_01" ] = "nx_pr_lunar_armory_cabinet_door";

	level._scr_animtree[ "cabinet_02" ] = #animtree;
	level._scr_anim[ "cabinet_02" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_cabinet_02;
	level._scr_model[ "cabinet_02" ] = "nx_pr_lunar_armory_cabinet_door";
	addNotetrack_customFunction( "cabinet_02", "prop_delete", ::prop_delete );

	level._scr_animtree[ "cabinet_03" ] = #animtree;
	level._scr_anim[ "cabinet_03" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_cabinet_03;
	level._scr_model[ "cabinet_03" ] = "nx_pr_lunar_armory_cabinet_door";

	level._scr_animtree[ "cabinet_04" ] = #animtree;
	level._scr_anim[ "cabinet_04" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_cabinet_04;
	level._scr_model[ "cabinet_04" ] = "nx_pr_lunar_armory_cabinet_door";

	level._scr_animtree[ "cabinet_05" ] = #animtree;
	level._scr_anim[ "cabinet_05" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_cabinet_05;
	level._scr_model[ "cabinet_05" ] = "nx_pr_lunar_armory_cabinet_door";
	addNotetrack_customFunction( "cabinet_05", "prop_delete", ::prop_delete );

	level._scr_animtree[ "cabinet_06" ] = #animtree;
	level._scr_anim[ "cabinet_06" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_cabinet_06;
	level._scr_model[ "cabinet_06" ] = "nx_pr_lunar_armory_cabinet_door";

	level._scr_animtree[ "cabinet_07" ] = #animtree;
	level._scr_anim[ "cabinet_07" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_cabinet_07;
	level._scr_model[ "cabinet_07" ] = "nx_pr_lunar_armory_cabinet_door";

	level._scr_animtree[ "cabinet_08" ] = #animtree;
	level._scr_anim[ "cabinet_08" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_cabinet_08;
	level._scr_model[ "cabinet_08" ] = "nx_pr_lunar_armory_cabinet_door";

	level._scr_animtree[ "helmet_01" ] = #animtree;
	level._scr_anim[ "helmet_01" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_helmet_01;
	level._scr_model[ "helmet_01" ] = "nx_pr_lunar_helm_scripted";
	addNotetrack_customFunction( "helmet_01", "prop_delete", ::prop_delete );

	level._scr_animtree[ "helmet_02" ] = #animtree;
	level._scr_anim[ "helmet_02" ][ "armory_breach_explosion" ] = %nx_pr_lunar_armory_breach_helmet_02;
	level._scr_model[ "helmet_02" ] = "nx_pr_lunar_helm_scripted";
	addNotetrack_customFunction( "helmet_02", "prop_delete", ::prop_delete );

	//falcon death blood spurt origin
	level._scr_animtree[ "blood_origin" ] = #animtree;
	level._scr_anim[ "blood_origin" ][ "falcon_death" ] = %nx_vh_lunar_falcon_bloodspurt_origin;
	level._scr_model[ "blood_origin" ] = "nx_pr_lunar_falcondeath_bloodorigin";

	//top floor breach
	level._scr_animtree[ "model6" ] = #animtree;
	level._scr_anim[ "model6" ][ "top_floor_breach" ] = %nx_pr_lunar_topfloorbreach_metalshutter_anim;
	level._scr_anim[ "model6" ][ "into_shadows_shutter_open" ] = %nx_pr_lunar_metalshutter_open_anim; // Re-open Anim
	level._scr_model[ "model6" ] = "nx_pr_lunar_topfloorbreach_metalshutter";

	level._scr_animtree[ "model8" ] = #animtree;
	level._scr_anim[ "model8" ][ "top_floor_breach" ] = %nx_pr_lunar_topfloorbreach_crate_01;
	level._scr_model[ "model8" ] = "nx_moonbase_crate_01";

	level._scr_animtree[ "ammo_box_1" ] = #animtree;
	level._scr_anim[ "ammo_box_1" ][ "top_floor_breach" ] = %nx_pr_lunar_topfloorbreach_AmmoBox_01;
	level._scr_model[ "ammo_box_1" ] = "nx_ammobox_01";

	level._scr_animtree[ "ammo_box_2" ] = #animtree;
	level._scr_anim[ "ammo_box_2" ][ "top_floor_breach" ] = %nx_pr_lunar_topfloorbreach_Ammo_02;
	level._scr_model[ "ammo_box_2" ] = "nx_ammobox_02";

	level._scr_animtree[ "ammo_box_2_open" ] = #animtree;
	level._scr_anim[ "ammo_box_2_open" ][ "top_floor_breach" ] = %nx_pr_lunar_topfloorbreach_ammobox_02_open;
	level._scr_model[ "ammo_box_2_open" ] = "nx_ammobox_02_open";

	level._scr_animtree[ "ammo_box_3" ] = #animtree;
	level._scr_anim[ "ammo_box_3" ][ "top_floor_breach" ] = %nx_pr_lunar_topfloorbreach_Ammo_03;
	level._scr_model[ "ammo_box_3" ] = "nx_ammobox_03";

	level._scr_animtree[ "ammo_box_3_open" ] = #animtree;
	level._scr_anim[ "ammo_box_3_open" ][ "top_floor_breach" ] = %nx_pr_lunar_topfloorbreach_Ammo_03_Open;
	level._scr_model[ "ammo_box_3_open" ] = "nx_ammobox_03_open";

	level._scr_animtree[ "crate2" ] = #animtree;
	level._scr_anim[ "crate2" ][ "top_floor_breach" ] = %nx_pr_lunar_topfloorbreach_crate_02;
	level._scr_model[ "crate2" ] = "nx_moonbase_crate_01";

	level._scr_animtree[ "monitor" ] = #animtree;
	level._scr_anim[ "monitor" ][ "top_floor_breach" ] = %nx_pr_lunar_topfloorbreach_monitor1;
	level._scr_model[ "monitor" ] = "nx_moonbase_monitor";

	level._scr_animtree[ "temp_handles" ] = #animtree;
	level._scr_anim[ "temp_handles" ][ "top_floor_breach" ] = %nx_pr_lunar_topfloorbreach_temphandles;
	level._scr_model[ "temp_handles" ] = "nx_pr_lunar_topfloorbreach_temphandles";

	//end greet
	level._scr_animtree[ "end_greet_detonator" ] = #animtree;
	level._scr_anim[ "end_greet_detonator" ][ "end_greet" ] = %nx_pr_lunar_endgreet_detonator;
	level._scr_model[ "end_greet_detonator" ] = "nx_pr_lunar_breach_detonator";

	//end controls
	level._scr_animtree[ "end_controls_panel" ] = #animtree;
	level._scr_anim[ "end_controls_panel" ][ "end_controls" ] = %nx_pr_lunar_endcontrols_controls;
	level._scr_anim[ "end_controls_panel" ][ "end_controls_idle" ][0] = %nx_pr_lunar_endcontrols_controls_idle;
	level._scr_model[ "end_controls_panel" ] = "nx_pr_lunar_controls_panel";
}


#using_animtree( "generic_human" );
lsp_door_anims()
{
	// Enemy lsp door
	level._scr_anim[ "enemy_lsp_1" ][ "lsp_door" ] = %nx_tp_lunar_chin_hack_01;
	level._scr_anim[ "enemy_lsp_2" ][ "lsp_door" ] = %nx_tp_lunar_chin_hack_02;
	level._scr_anim[ "enemy_lsp_3" ][ "lsp_door" ] = %nx_tp_lunar_chin_hack_03;

	// Life support
	level._scr_anim[ "enemy_life_support" ][ "typing" ] = %nx_tp_lunar_typing;

	// Ally	lsp door
	level._scr_anim[ "eagle" ][ "lsp_door" ] = %nx_tp_lunar_hack_door_01;

	// Door open
	level._scr_anim[ "eagle"  ][ "typing" ] = %nx_tp_lunar_typing;
	level._scr_anim[ "falcon"  ][ "typing" ] = %nx_tp_lunar_typing;

	// Dead crew
	level._scr_anim[ "generic" ][ "dying_back_death_v2" ]					= %dying_back_death_v2;
	level._scr_anim[ "generic" ][ "covercrouch_death_3" ]					= %covercrouch_death_3;
	level._scr_anim[ "generic" ][ "civilian_leaning_death_shot" ]			= %civilian_leaning_death_shot;
	level._scr_anim[ "generic" ][ "nx_tp_lunar_execution_scientist " ] = %nx_tp_lunar_execution_scientist ;
	level._scr_anim[ "generic" ][ "tp_moon_death_cover_crouch_01" ] = %tp_moon_death_cover_crouch_01 ;
	level._scr_anim[ "generic" ][ "tp_moon_death_stand_exposed_01" ] = %tp_moon_death_stand_exposed_01 ;
	level._scr_anim[ "generic" ][ "crawl_death_front" ] = %crawl_death_front ;
	level._scr_anim[ "generic" ][ "nx_tp_lunar_dead_desk_scientist_01" ] = %nx_tp_lunar_dead_desk_scientist_01 ;
	level._scr_anim[ "generic" ][ "tp_moon_death_running_forward_01" ] = %tp_moon_death_running_forward_01 ;
	level._scr_anim[ "generic" ][ "nx_tp_lunar_dead_desk_scientist_03" ] = %nx_tp_lunar_dead_desk_scientist_03 ;
	level._scr_anim[ "generic" ][ "civilian_leaning_death" ] = %civilian_leaning_death ;
	level._scr_anim[ "generic" ][ "civilian_leaning_death" ] = %civilian_leaning_death ;
	level._scr_anim[ "generic" ][ "exposed_death_neckgrab" ] = %exposed_death_neckgrab ;
	level._scr_anim[ "generic" ][ "nx_tp_lunar_dead_desk_scientist_02" ] = %nx_tp_lunar_dead_desk_scientist_02 ;
	level._scr_anim[ "generic" ][ "nx_tp_wounded_cot_thrashing" ] = %nx_tp_wounded_cot_thrashing ;
	level._scr_anim[ "generic" ][ "tp_moon_death_stand_upper_torso_extended_01" ] = %tp_moon_death_stand_upper_torso_extended_01 ;
	level._scr_anim[ "generic" ][ "nx_tp_lunar_dead_scientist_edge_1" ] = %nx_tp_lunar_dead_scientist_edge_1 ;
	level._scr_anim[ "generic" ][ "nx_tp_lunar_dead_scientist_chairdown1" ] = %nx_tp_lunar_dead_scientist_chairdown1 ;
	level._scr_anim[ "generic" ][ "run_death_flop" ] = %run_death_flop ;
	level._scr_anim[ "generic" ][ "nx_tp_lunar_dead_scientist_bed1" ] = %nx_tp_lunar_dead_scientist_bed1 ;
	level._scr_anim[ "generic" ][ "death_stand_sniper_leg" ] = %death_stand_sniper_leg ;
	level._scr_anim[ "generic" ][ "pistol_death_2" ] = %pistol_death_2 ;
	level._scr_anim[ "generic" ][ "nx_tp_lunar_dead_scientist_chair1" ] = %nx_tp_lunar_dead_scientist_chair1 ;
	level._scr_anim[ "generic" ][ "nx_tp_lunar_dead_scientist_chair2" ] = %nx_tp_lunar_dead_scientist_chair2 ;
	level._scr_anim[ "generic" ][ "nx_tp_lunar_dead_scientist_chair3" ] = %nx_tp_lunar_dead_scientist_chair3 ;	
}

#using_animtree( "player" );
player_anims()
{
	level._scr_animtree[ "player_rig" ]						= #animtree;
	level._scr_model[ "player_rig" ]						= "viewhands_us_lunar_scripted";

	// tagTC<note> - wakeup anim from AF_CHASE
	level._scr_anim[ "player_rig" ][ "wakeup" ] 				 = %player_afchase_ending_wakeup;

	level._scr_anim[ "player_rig" ][ "vehiclebay_wakeup" ] = %nx_fp_lunar_vehiclebay_wakeup_player;

	//Rover Intro Drive
	level._scr_anim[ "player_rig" ][ "rover_intro_drive" ]			= %nx_fp_lunar_rover_intro_drive_player;	
	level._scr_anim[ "player_rig" ][ "rover_intro_jump" ]			= %nx_fp_lunar_rover_intro_jump_player;	
	addNotetrack_customFunction( "player_rig", "helmet_overlay", ::helmet_overlay );

	//Door			  
	level._scr_anim[ "player_rig" ][ "lsp_door" ]			= %nx_fp_lunar_hack_door_player;
	
	// Tower Collapse
	level._scr_anim[ "player_rig" ][ "tower_fall" ] = %nx_fp_lunar_tower_collapse_player;

	// Get Back to Rover
	level._scr_anim[ "player_rig" ][ "back_to_rover" ] = %nx_fp_lunar_back_to_rover_player;

	// Rover Crash
	level._scr_anim[ "player_rig" ][ "rover_crash" ]  = %nx_fp_lunar_rovercrash_player;	
	addNotetrack_customFunction( "player_rig", "visor_crack", ::break_visor );

	//top floor breach
	level._scr_anim[ "player_rig" ][ "top_floor_breach" ] = %nx_fp_lunar_topfloorbreach_player;
	addNotetrack_customFunction( "player_rig", "rover_fires", ::top_floor_breach_rover_fires );

	// new taser scene
	level._scr_anim[ "player_rig" ][ "taser" ] = %nx_tp_lunar_taser_player;

	// Vehicle Bay Breach
	level._scr_anim[ "player_rig" ][ "vehiclebay_breach_player" ] = %nx_fp_lunar_vehiclebay_breach_player;	
	addNotetrack_customFunction( "player_rig", "unhide_arms", ::unhide_arms );
	addNotetrack_customFunction( "player_rig", "helmet_overlay_taking_off", ::helmet_overlay_taking_off );
	addNotetrack_customFunction( "player_rig", "start_vh_bay_breach", ::start_vh_bay_breach );
	addNotetrack_customFunction( "player_rig", "close_airlock_door", ::close_airlock_door );

	// Armory Enter And Grab Helmet
	level._scr_anim[ "player_rig" ][ "armory_entrance_player" ] = %nx_fp_lunar_armory_entrance_player;	
	
	//Armory Enter Grab Rifle
	level._scr_anim[ "player_rig" ][ "armory_entrance_grabrifle" ] = %nx_fp_lunar_armory_grabrifle_player;

	//falcon death 
	level._scr_anim[ "player_rig" ][ "falcon_death" ] = %nx_fp_lunar_falcon_death_player;
	//addNotetrack_customFunction( "player_rig", "shellshock_start", ::shellshock_start );

	//slow motion
	addNotetrack_customFunction( "player_rig", "slowmotion_start", ::slowmotion_start );
	addNotetrack_customFunction( "player_rig", "slowmotion_stop", ::slowmotion_stop );

	//end controls
	level._scr_anim[ "player_rig" ][ "end_controls" ] = %nx_fp_lunar_endcontrols_player;
	addNotetrack_customFunction( "player_rig", "end_controls_fade_out", ::end_controls_fade_out );

}

dialog()
{
	level._scr_radio[ "moon_bc_toarm_fallback" ] = "moon_bc_toarm_fallback";
	level._scr_radio[ "moon_bc_toarm_securelsp" ] = "moon_bc_toarm_securelsp";
	level._scr_radio[ "moon_eag_ext_afterlsp" ] = "moon_eag_ext_afterlsp";
	level._scr_radio[ "moon_eag_ext_approachingsix" ] = "moon_eag_ext_approachingsix";
	level._scr_radio[ "moon_eag_ext_cantlose" ] = "moon_eag_ext_cantlose";
	level._scr_radio[ "moon_eag_ext_getouthere" ] = "moon_eag_ext_getouthere";
	level._scr_radio[ "moon_eag_ext_givesupport" ] = "moon_eag_ext_givesupport";
	level._scr_radio[ "moon_eag_ext_hopeothers" ] = "moon_eag_ext_hopeothers";
	level._scr_radio[ "moon_eag_ext_needwayout" ] = "moon_eag_ext_needwayout";
	level._scr_radio[ "moon_eag_ext_notonlyattack" ] = "moon_eag_ext_notonlyattack";
	level._scr_radio[ "moon_eag_ext_onetransmitter" ] = "moon_eag_ext_onetransmitter";
	level._scr_radio[ "moon_eag_ext_securelsp" ] = "moon_eag_ext_securelsp";
	level._scr_radio[ "moon_eag_ext_useterrain" ] = "moon_eag_ext_useterrain";
	level._scr_radio[ "moon_eag_int_findwayaround" ] = "moon_eag_int_findwayaround";
	level._scr_radio[ "moon_eag_int_getready" ] = "moon_eag_int_getready";
	level._scr_radio[ "moon_eag_int_gladuralive" ] = "moon_eag_int_gladuralive";
	level._scr_radio[ "moon_eag_int_halfdestroyed" ] = "moon_eag_int_halfdestroyed";
	level._scr_radio[ "moon_eag_int_hangon" ] = "moon_eag_int_hangon";
	level._scr_radio[ "moon_eag_int_putthison" ] = "moon_eag_int_putthison";
	level._scr_radio[ "moon_eag_int_sittingducks" ] = "moon_eag_int_sittingducks";
	level._scr_radio[ "moon_eag_int_soundbad" ] = "moon_eag_int_soundbad";
	level._scr_radio[ "moon_eag_int_stayawaydoor" ] = "moon_eag_int_stayawaydoor";
	level._scr_radio[ "moon_fal_ext_camefrom" ] = "moon_fal_ext_camefrom";
	level._scr_radio[ "moon_fal_ext_friendlies" ] = "moon_fal_ext_friendlies";
	level._scr_radio[ "moon_fal_ext_getinside" ] = "moon_fal_ext_getinside";
	level._scr_radio[ "moon_fal_ext_incrater" ] = "moon_fal_ext_incrater";
	level._scr_radio[ "moon_fal_ext_notime" ] = "moon_fal_ext_notime";
	level._scr_radio[ "moon_fal_ext_othersmade" ] = "moon_fal_ext_othersmade";
	level._scr_radio[ "moon_fal_ext_theresmore" ] = "moon_fal_ext_theresmore";
	level._scr_radio[ "moon_fal_ext_wayblocked" ] = "moon_fal_ext_wayblocked";
	level._scr_radio[ "moon_fal_ext_whynow" ] = "moon_fal_ext_whynow";
	level._scr_radio[ "moon_fal_toarm_gearup" ] = "moon_fal_toarm_gearup";
	level._scr_radio[ "moon_fal_toarm_gotthese" ] = "moon_fal_toarm_gotthese";
	level._scr_radio[ "moon_fal_toarm_takethis" ] = "moon_fal_toarm_takethis";
	level._scr_radio[ "moon_red1_toarm_getinside" ] = "moon_red1_toarm_getinside";
	level._scr_radio[ "moon_red1_toarm_getup" ] = "moon_red1_toarm_getup";
	level._scr_radio[ "moon_red1_toarm_nochance" ] = "moon_red1_toarm_nochance";
	level._scr_radio[ "moon_red1_toarm_slaughter" ] = "moon_red1_toarm_slaughter";
	level._scr_radio[ "moon_ally_breach_01" ] = "moon_ally_breach_01";
	level._scr_radio[ "moon_ally_breach_02" ] = "moon_ally_breach_02";
	level._scr_radio[ "moon_bc_arm_01" ] = "moon_bc_arm_01";
	level._scr_radio[ "moon_bc_arm_02" ] = "moon_bc_arm_02";
	level._scr_radio[ "moon_bc_intro_01" ] = "moon_bc_intro_01";
	level._scr_radio[ "moon_bc_intro_02" ] = "moon_bc_intro_02";
	level._scr_radio[ "moon_bc_intro_03" ] = "moon_bc_intro_03";
	level._scr_radio[ "moon_bc_intro_04" ] = "moon_bc_intro_04";
	level._scr_radio[ "moon_bc_intro_05" ] = "moon_bc_intro_05";
	level._scr_radio[ "moon_bc_intro_06" ] = "moon_bc_intro_06";
	level._scr_radio[ "moon_bc_intro_07" ] = "moon_bc_intro_07";
	level._scr_radio[ "moon_bc_intro_08" ] = "moon_bc_intro_08";
	level._scr_radio[ "moon_bc_intro_09" ] = "moon_bc_intro_09";
	level._scr_radio[ "moon_bc_intro_10" ] = "moon_bc_intro_10";
	level._scr_radio[ "moon_bc_intro_11" ] = "moon_bc_intro_11";
	level._scr_radio[ "moon_bc_intro_12" ] = "moon_bc_intro_12";
	level._scr_radio[ "moon_bc_intro_13" ] = "moon_bc_intro_13";
	level._scr_radio[ "moon_bc_intro_14" ] = "moon_bc_intro_14";
	level._scr_radio[ "moon_bc_intro_15" ] = "moon_bc_intro_15";
	level._scr_radio[ "moon_bc_intro_16" ] = "moon_bc_intro_16";
	level._scr_radio[ "moon_bc_intro_17" ] = "moon_bc_intro_17";
	level._scr_radio[ "moon_bc_intro_18" ] = "moon_bc_intro_18";
	level._scr_radio[ "moon_bc_rov_01" ] = "moon_bc_rov_01";
	level._scr_radio[ "moon_bc_rov_02" ] = "moon_bc_rov_02";
	level._scr_radio[ "moon_bc_rov_03" ] = "moon_bc_rov_03";
	level._scr_radio[ "moon_bc_rov_04" ] = "moon_bc_rov_04";
	level._scr_radio[ "moon_bc_rov_05" ] = "moon_bc_rov_05";
	level._scr_radio[ "moon_bc_rov_06" ] = "moon_bc_rov_06";
	level._scr_radio[ "moon_bc_rov_07" ] = "moon_bc_rov_07";
	level._scr_radio[ "moon_bc_rov_08" ] = "moon_bc_rov_08";
	level._scr_radio[ "moon_bc_rov_09" ] = "moon_bc_rov_09";
	level._scr_radio[ "moon_bc_rov_10" ] = "moon_bc_rov_10";
	level._scr_radio[ "moon_bc_rov_11" ] = "moon_bc_rov_11";
	level._scr_radio[ "moon_bc_rov_12" ] = "moon_bc_rov_12";
	level._scr_radio[ "moon_char_intro_01" ] = "moon_char_intro_01";
	level._scr_radio[ "moon_char_intro_02" ] = "moon_char_intro_02";
	level._scr_radio[ "moon_char_intro_03" ] = "moon_char_intro_03";
	level._scr_radio[ "moon_char_intro_04" ] = "moon_char_intro_04";
	level._scr_radio[ "moon_char_intro_05" ] = "moon_char_intro_05";
	level._scr_radio[ "moon_char_intro_06" ] = "moon_char_intro_06";
	level._scr_radio[ "moon_char_intro_07" ] = "moon_char_intro_07";
	level._scr_radio[ "moon_char_intro_08" ] = "moon_char_intro_08";
	level._scr_radio[ "moon_char_intro_09" ] = "moon_char_intro_09";
	level._scr_radio[ "moon_char_intro_10" ] = "moon_char_intro_10";
	level._scr_radio[ "moon_char_intro_11" ] = "moon_char_intro_11";
	level._scr_radio[ "moon_char_intro_12" ] = "moon_char_intro_12";
	level._scr_radio[ "moon_char_intro_13" ] = "moon_char_intro_13";
	level._scr_radio[ "moon_char_intro_14" ] = "moon_char_intro_14";
	level._scr_radio[ "moon_char_intro_15" ] = "moon_char_intro_15";
	level._scr_radio[ "moon_char_intro_16" ] = "moon_char_intro_16";
	level._scr_radio[ "moon_char_intro_17" ] = "moon_char_intro_17";
	level._scr_radio[ "moon_char_intro_18" ] = "moon_char_intro_18";
	level._scr_radio[ "moon_char_intro_19" ] = "moon_char_intro_19";
	level._scr_radio[ "moon_char_intro_20" ] = "moon_char_intro_20";
	level._scr_radio[ "moon_char_intro_21" ] = "moon_char_intro_21";
	level._scr_radio[ "moon_char_intro_22" ] = "moon_char_intro_22";
	level._scr_radio[ "moon_char_intro_23" ] = "moon_char_intro_23";
	level._scr_radio[ "moon_char_intro_24" ] = "moon_char_intro_24";
	level._scr_radio[ "moon_char_intro_25" ] = "moon_char_intro_25";
	level._scr_radio[ "moon_char_intro_26" ] = "moon_char_intro_26";
	level._scr_radio[ "moon_char_intro_27" ] = "moon_char_intro_27";
	level._scr_radio[ "moon_char_intro_28" ] = "moon_char_intro_28";
	level._scr_radio[ "moon_char_intro_29" ] = "moon_char_intro_29";
	level._scr_radio[ "moon_char_intro_30" ] = "moon_char_intro_30";
	level._scr_radio[ "moon_char_intro_31" ] = "moon_char_intro_31";
	level._scr_radio[ "moon_char_intro_32" ] = "moon_char_intro_32";
	level._scr_radio[ "moon_char_intro_33" ] = "moon_char_intro_33";
	level._scr_radio[ "moon_char_intro_34" ] = "moon_char_intro_34";
	level._scr_radio[ "moon_char_intro_35" ] = "moon_char_intro_35";
	level._scr_radio[ "moon_char_intro_36" ] = "moon_char_intro_36";
	level._scr_radio[ "moon_char_intro_37" ] = "moon_char_intro_37";
	level._scr_radio[ "moon_char_intro_38" ] = "moon_char_intro_38";
	level._scr_radio[ "moon_char_intro_39" ] = "moon_char_intro_39";
	level._scr_radio[ "moon_char_intro_40" ] = "moon_char_intro_40";
	level._scr_radio[ "moon_char_intro_41" ] = "moon_char_intro_41";
	level._scr_radio[ "moon_char_intro_42" ] = "moon_char_intro_42";
	level._scr_radio[ "moon_char_intro_43" ] = "moon_char_intro_43";
	level._scr_radio[ "moon_char_intro_44" ] = "moon_char_intro_44";
	level._scr_radio[ "moon_char_intro_45" ] = "moon_char_intro_45";
	level._scr_radio[ "moon_char_intro_46" ] = "moon_char_intro_46";
	level._scr_radio[ "moon_char_intro_47" ] = "moon_char_intro_47";
	level._scr_radio[ "moon_char_intro_48" ] = "moon_char_intro_48";
	level._scr_radio[ "moon_char_intro_49" ] = "moon_char_intro_49";
	level._scr_radio[ "moon_char_intro_50" ] = "moon_char_intro_50";
	level._scr_radio[ "moon_char_intro_51" ] = "moon_char_intro_51";
	level._scr_radio[ "moon_char_intro_52" ] = "moon_char_intro_52";
	level._scr_radio[ "moon_char_intro_53" ] = "moon_char_intro_53";
	level._scr_radio[ "moon_char_intro_54" ] = "moon_char_intro_54";
	level._scr_radio[ "moon_char_intro_55" ] = "moon_char_intro_55";
	level._scr_radio[ "moon_char_intro_56" ] = "moon_char_intro_56";
	level._scr_radio[ "moon_char_intro_57" ] = "moon_char_intro_57";
	level._scr_radio[ "moon_char_intro_58" ] = "moon_char_intro_58";
	level._scr_radio[ "moon_char_intro_59" ] = "moon_char_intro_59";
	level._scr_radio[ "moon_char_intro_60" ] = "moon_char_intro_60";
	level._scr_radio[ "moon_char_intro_61" ] = "moon_char_intro_61";
	level._scr_radio[ "moon_char_intro_62" ] = "moon_char_intro_62";
	level._scr_radio[ "moon_char_intro_63" ] = "moon_char_intro_63";
	level._scr_radio[ "moon_char_intro_64" ] = "moon_char_intro_64";
	level._scr_radio[ "moon_char_intro_65" ] = "moon_char_intro_65";
	level._scr_radio[ "moon_char_intro_66" ] = "moon_char_intro_66";
	level._scr_radio[ "moon_char_intro_67" ] = "moon_char_intro_67";
	level._scr_radio[ "moon_char_intro_68" ] = "moon_char_intro_68";
	level._scr_radio[ "moon_eag_arm_01" ] = "moon_eag_arm_01";
	level._scr_radio[ "moon_eag_arm_02" ] = "moon_eag_arm_02";
	level._scr_radio[ "moon_eag_arm_03" ] = "moon_eag_arm_03";
	level._scr_radio[ "moon_eag_cc_01" ] = "moon_eag_cc_01";
	level._scr_radio[ "moon_eag_esc_01" ] = "moon_eag_esc_01";
	level._scr_radio[ "moon_eag_esc_02" ] = "moon_eag_esc_02";
	level._scr_radio[ "moon_eag_esc_03" ] = "moon_eag_esc_03";
	level._scr_radio[ "moon_eag_esc_04" ] = "moon_eag_esc_04";
	level._scr_radio[ "moon_eag_esc_05" ] = "moon_eag_esc_05";
	level._scr_radio[ "moon_eag_esc_06" ] = "moon_eag_esc_06";
	level._scr_radio[ "moon_eag_ext_01" ] = "moon_eag_ext_01";
	level._scr_radio[ "moon_eag_ext_02" ] = "moon_eag_ext_02";
	level._scr_radio[ "moon_eag_ext_03" ] = "moon_eag_ext_03";
	level._scr_radio[ "moon_eag_ext_04" ] = "moon_eag_ext_04";
	level._scr_radio[ "moon_eag_ext_05" ] = "moon_eag_ext_05";
	level._scr_radio[ "moon_eag_ext_06" ] = "moon_eag_ext_06";
	level._scr_radio[ "moon_eag_ext_07" ] = "moon_eag_ext_07";
	level._scr_radio[ "moon_eag_ext_08" ] = "moon_eag_ext_08";
	level._scr_radio[ "moon_eag_ext_09" ] = "moon_eag_ext_09";
	level._scr_radio[ "moon_eag_ext_09a" ] = "moon_eag_ext_09a";
	level._scr_radio[ "moon_eag_ext_10" ] = "moon_eag_ext_10";
	level._scr_radio[ "moon_eag_ext_11" ] = "moon_eag_ext_11";
	level._scr_radio[ "moon_eag_ext_12" ] = "moon_eag_ext_12";
	level._scr_radio[ "moon_eag_ext_13" ] = "moon_eag_ext_13";
	level._scr_radio[ "moon_eag_ext_14" ] = "moon_eag_ext_14";
	level._scr_radio[ "moon_eag_ext_15" ] = "moon_eag_ext_15";
	level._scr_radio[ "moon_eag_ext_16" ] = "moon_eag_ext_16";
	level._scr_radio[ "moon_eag_ext_17" ] = "moon_eag_ext_17";
	level._scr_radio[ "moon_eag_ext_18" ] = "moon_eag_ext_18";
	level._scr_radio[ "moon_eag_ext_19" ] = "moon_eag_ext_19";
	level._scr_radio[ "moon_eag_ext_20" ] = "moon_eag_ext_20";
	level._scr_radio[ "moon_eag_ext_21" ] = "moon_eag_ext_21";
	level._scr_radio[ "moon_eag_ext_22" ] = "moon_eag_ext_22";
	level._scr_radio[ "moon_eag_ext_23" ] = "moon_eag_ext_23";
	level._scr_radio[ "moon_eag_ext_24" ] = "moon_eag_ext_24";
	level._scr_radio[ "moon_eag_ext_25" ] = "moon_eag_ext_25";
	level._scr_radio[ "moon_eag_ext_26" ] = "moon_eag_ext_26";
	level._scr_radio[ "moon_eag_ext_27" ] = "moon_eag_ext_27";
	level._scr_radio[ "moon_eag_ext_28" ] = "moon_eag_ext_28";
	level._scr_radio[ "moon_eag_ext_29" ] = "moon_eag_ext_29";
	level._scr_radio[ "moon_eag_ext_30" ] = "moon_eag_ext_30";
	level._scr_radio[ "moon_eag_ext_31" ] = "moon_eag_ext_31";
	level._scr_radio[ "moon_eag_ext_32" ] = "moon_eag_ext_32";
	level._scr_radio[ "moon_eag_ext_33" ] = "moon_eag_ext_33";
	level._scr_radio[ "moon_eag_ext_34" ] = "moon_eag_ext_34";
	level._scr_radio[ "moon_eag_ext_35" ] = "moon_eag_ext_35";
	level._scr_radio[ "moon_eag_ext_36" ] = "moon_eag_ext_36";
	level._scr_radio[ "moon_eag_ext_37" ] = "moon_eag_ext_37";
	level._scr_radio[ "moon_eag_ext_38" ] = "moon_eag_ext_38";
	level._scr_radio[ "moon_eag_ext_39" ] = "moon_eag_ext_39";
	level._scr_radio[ "moon_eag_ext_40" ] = "moon_eag_ext_40";
	level._scr_radio[ "moon_eag_ext_41" ] = "moon_eag_ext_41";
	level._scr_radio[ "moon_eag_ext_43" ] = "moon_eag_ext_43";
	level._scr_radio[ "moon_eag_ext_44" ] = "moon_eag_ext_44";
	level._scr_radio[ "moon_eag_ext_45" ] = "moon_eag_ext_45";
	level._scr_radio[ "moon_eag_ext_46" ] = "moon_eag_ext_46";
	level._scr_radio[ "moon_eag_ext_47" ] = "moon_eag_ext_47";
	level._scr_radio[ "moon_eag_ext_48" ] = "moon_eag_ext_48";
	level._scr_radio[ "moon_eag_ext_49" ] = "moon_eag_ext_49";
	level._scr_radio[ "moon_eag_ext_alright" ] = "moon_eag_ext_alright";
	level._scr_radio[ "moon_eag_ext_anothertrans" ] = "moon_eag_ext_anothertrans";
	level._scr_radio[ "moon_eag_ext_capacity" ] = "moon_eag_ext_capacity";
	level._scr_radio[ "moon_eag_ext_clearout" ] = "moon_eag_ext_clearout";
	level._scr_radio[ "moon_eag_ext_comeon" ] = "moon_eag_ext_comeon";
	level._scr_radio[ "moon_eag_ext_comingaround" ] = "moon_eag_ext_comingaround";
	level._scr_radio[ "moon_eag_ext_getbehind" ] = "moon_eag_ext_getbehind";
	level._scr_radio[ "moon_eag_ext_getonturret" ] = "moon_eag_ext_getonturret";
	level._scr_radio[ "moon_eag_ext_getturret" ] = "moon_eag_ext_getturret";
	level._scr_radio[ "moon_eag_ext_gunnersdown" ] = "moon_eag_ext_gunnersdown";
	level._scr_radio[ "moon_eag_ext_headourway" ] = "moon_eag_ext_headourway";
	level._scr_radio[ "moon_eag_ext_keepout" ] = "moon_eag_ext_keepout";
	level._scr_radio[ "moon_eag_ext_letsmove" ] = "moon_eag_ext_letsmove";
	level._scr_radio[ "moon_eag_ext_letsmove2" ] = "moon_eag_ext_letsmove2";
	level._scr_radio[ "moon_eag_ext_newgun01" ] = "moon_eag_ext_newgun01";
	level._scr_radio[ "moon_eag_ext_newgun02" ] = "moon_eag_ext_newgun02";
	level._scr_radio[ "moon_eag_ext_newgun03" ] = "moon_eag_ext_newgun03";
	level._scr_radio[ "moon_eag_ext_newgun04" ] = "moon_eag_ext_newgun04";
	level._scr_radio[ "moon_eag_ext_onlyway" ] = "moon_eag_ext_onlyway";
	level._scr_radio[ "moon_eag_ext_patch" ] = "moon_eag_ext_patch";
	level._scr_radio[ "moon_eag_ext_ready" ] = "moon_eag_ext_ready";
	level._scr_radio[ "moon_eag_ext_reinheaded" ] = "moon_eag_ext_reinheaded";
	level._scr_radio[ "moon_eag_ext_rightside" ] = "moon_eag_ext_rightside";
	level._scr_radio[ "moon_eag_ext_spotted" ] = "moon_eag_ext_spotted";
	level._scr_radio[ "moon_eag_ext_takebase" ] = "moon_eag_ext_takebase";
	level._scr_radio[ "moon_eag_ext_takegunner" ] = "moon_eag_ext_takegunner";
	level._scr_radio[ "moon_eag_ext_takeout" ] = "moon_eag_ext_takeout";
	level._scr_radio[ "moon_eag_ext_takerest" ] = "moon_eag_ext_takerest";
	level._scr_radio[ "moon_eag_ext_taketheseturrets" ] = "moon_eag_ext_taketheseturrets";
	level._scr_radio[ "moon_eag_ext_taketurret" ] = "moon_eag_ext_taketurret";
	level._scr_radio[ "moon_eag_ext_thatcame" ] = "moon_eag_ext_thatcame";
	level._scr_radio[ "moon_eag_ext_thruhere" ] = "moon_eag_ext_thruhere";
	level._scr_radio[ "moon_eag_ext_uphere" ] = "moon_eag_ext_uphere";
	level._scr_radio[ "moon_eag_ext_vanready" ] = "moon_eag_ext_vanready";
	level._scr_radio[ "moon_eag_ext_vanstat" ] = "moon_eag_ext_vanstat";
	level._scr_radio[ "moon_eag_ext_watch" ] = "moon_eag_ext_watch";
	level._scr_radio[ "moon_eag_ext_watchhigh" ] = "moon_eag_ext_watchhigh";
	level._scr_radio[ "moon_eag_ext_what" ] = "moon_eag_ext_what";
	level._scr_radio[ "moon_eag_ext_workaround" ] = "moon_eag_ext_workaround";
	level._scr_radio[ "moon_eag_gettocnc" ] = "moon_eag_gettocnc";
	level._scr_radio[ "moon_eag_hearthem" ] = "moon_eag_hearthem";
	level._scr_radio[ "moon_eag_hub_01" ] = "moon_eag_hub_01";
	level._scr_radio[ "moon_eag_hub_02" ] = "moon_eag_hub_02";
	level._scr_radio[ "moon_eag_hub_03" ] = "moon_eag_hub_03";
	level._scr_radio[ "moon_eag_hub_04" ] = "moon_eag_hub_04";
	level._scr_radio[ "moon_eag_hub_05" ] = "moon_eag_hub_05";
	level._scr_radio[ "moon_eag_hub_06" ] = "moon_eag_hub_06";
	level._scr_radio[ "moon_eag_int_01" ] = "moon_eag_int_01";
	level._scr_radio[ "moon_eag_int_02" ] = "moon_eag_int_02";
	level._scr_radio[ "moon_eag_int_03" ] = "moon_eag_int_03";
	level._scr_radio[ "moon_eag_int_04" ] = "moon_eag_int_04";
	level._scr_radio[ "moon_eag_int_05" ] = "moon_eag_int_05";
	level._scr_radio[ "moon_eag_int_06" ] = "moon_eag_int_06";
	level._scr_radio[ "moon_eag_int_07" ] = "moon_eag_int_07";
	level._scr_radio[ "moon_eag_int_08" ] = "moon_eag_int_08";
	level._scr_radio[ "moon_eag_int_09" ] = "moon_eag_int_09";
	level._scr_radio[ "moon_eag_int_10" ] = "moon_eag_int_10";
	level._scr_radio[ "moon_eag_int_11" ] = "moon_eag_int_11";
	level._scr_radio[ "moon_eag_int_12" ] = "moon_eag_int_12";
	level._scr_radio[ "moon_eag_int_13" ] = "moon_eag_int_13";
	level._scr_radio[ "moon_eag_int_14" ] = "moon_eag_int_14";
	level._scr_radio[ "moon_eag_int_15" ] = "moon_eag_int_15";
	level._scr_radio[ "moon_eag_int_16" ] = "moon_eag_int_16";
	level._scr_radio[ "moon_eag_int_17" ] = "moon_eag_int_17";
	level._scr_radio[ "moon_eag_int_18" ] = "moon_eag_int_18";
	level._scr_radio[ "moon_eag_int_19" ] = "moon_eag_int_19";
	level._scr_radio[ "moon_eag_int_20" ] = "moon_eag_int_20";
	level._scr_radio[ "moon_eag_int_21" ] = "moon_eag_int_21";
	level._scr_radio[ "moon_eag_int_22" ] = "moon_eag_int_22";
	level._scr_radio[ "moon_eag_int_23" ] = "moon_eag_int_23";
	level._scr_radio[ "moon_eag_int_24" ] = "moon_eag_int_24";
	level._scr_radio[ "moon_eag_int_25" ] = "moon_eag_int_25";
	level._scr_radio[ "moon_eag_int_26" ] = "moon_eag_int_26";
	level._scr_radio[ "moon_eag_int_27" ] = "moon_eag_int_27";
	level._scr_radio[ "moon_eag_int_28" ] = "moon_eag_int_28";
	level._scr_radio[ "moon_eag_int_29" ] = "moon_eag_int_29";
	level._scr_radio[ "moon_eag_int_30" ] = "moon_eag_int_30";
	level._scr_radio[ "moon_eag_int_31" ] = "moon_eag_int_31";
	level._scr_radio[ "moon_eag_kill_low_01" ] = "moon_eag_kill_low_01";
	level._scr_radio[ "moon_eag_kill_low_02" ] = "moon_eag_kill_low_02";
	level._scr_radio[ "moon_eag_kill_low_03" ] = "moon_eag_kill_low_03";
	level._scr_radio[ "moon_eag_kill_low_04" ] = "moon_eag_kill_low_04";
	level._scr_radio[ "moon_eag_kill_low_05" ] = "moon_eag_kill_low_05";
	level._scr_radio[ "moon_eag_kill_low_06" ] = "moon_eag_kill_low_06";
	level._scr_radio[ "moon_eag_kill_yell_01" ] = "moon_eag_kill_yell_01";
	level._scr_radio[ "moon_eag_kill_yell_02" ] = "moon_eag_kill_yell_02";
	level._scr_radio[ "moon_eag_kill_yell_03" ] = "moon_eag_kill_yell_03";
	level._scr_radio[ "moon_eag_kill_yell_04" ] = "moon_eag_kill_yell_04";
	level._scr_radio[ "moon_eag_kill_yell_05" ] = "moon_eag_kill_yell_05";
	level._scr_radio[ "moon_eag_kill_yell_06" ] = "moon_eag_kill_yell_06";
	level._scr_radio[ "moon_eag_livhal_01" ] = "moon_eag_livhal_01";
	level._scr_radio[ "moon_eag_livhal_02" ] = "moon_eag_livhal_02";
	level._scr_radio[ "moon_eag_livhal_03" ] = "moon_eag_livhal_03";
	level._scr_radio[ "moon_eag_move_01" ] = "moon_eag_move_01";
	level._scr_radio[ "moon_eag_move_02" ] = "moon_eag_move_02";
	level._scr_radio[ "moon_eag_move_03" ] = "moon_eag_move_03";
	level._scr_radio[ "moon_eag_move_04" ] = "moon_eag_move_04";
	level._scr_radio[ "moon_eag_move_05" ] = "moon_eag_move_05";
	level._scr_radio[ "moon_eag_move_06" ] = "moon_eag_move_06";
	level._scr_radio[ "moon_eag_move_07" ] = "moon_eag_move_07";
	level._scr_radio[ "moon_eag_move_08" ] = "moon_eag_move_08";
	level._scr_radio[ "moon_eag_move_09" ] = "moon_eag_move_09";
	level._scr_radio[ "moon_eag_patch_01" ] = "moon_eag_patch_01";
	level._scr_radio[ "moon_eag_patch_02" ] = "moon_eag_patch_02";
	level._scr_radio[ "moon_eag_patch_03" ] = "moon_eag_patch_03";
	level._scr_radio[ "moon_eag_vanrv_01" ] = "moon_eag_vanrv_01";
	level._scr_radio[ "moon_eng_ext_01" ] = "moon_eng_ext_01";
	level._scr_radio[ "moon_fal_esc_01" ] = "moon_fal_esc_01";
	level._scr_radio[ "moon_fal_esc_02" ] = "moon_fal_esc_02";
	level._scr_radio[ "moon_fal_esc_03" ] = "moon_fal_esc_03";
	level._scr_radio[ "moon_fal_esc_04" ] = "moon_fal_esc_04";
	level._scr_radio[ "moon_fal_esc_05" ] = "moon_fal_esc_05";
	level._scr_radio[ "moon_fal_esc_06" ] = "moon_fal_esc_06";
	level._scr_radio[ "moon_fal_ext_01" ] = "moon_fal_ext_01";
	level._scr_radio[ "moon_fal_ext_02" ] = "moon_fal_ext_02";
	level._scr_radio[ "moon_fal_ext_03" ] = "moon_fal_ext_03";
	level._scr_radio[ "moon_fal_ext_04" ] = "moon_fal_ext_04";
	level._scr_radio[ "moon_fal_ext_05" ] = "moon_fal_ext_05";
	level._scr_radio[ "moon_fal_ext_05_var1" ] = "moon_fal_ext_05_var1";
	level._scr_radio[ "moon_fal_ext_05_var2" ] = "moon_fal_ext_05_var2";
	level._scr_radio[ "moon_fal_ext_05_var3" ] = "moon_fal_ext_05_var3";
	level._scr_radio[ "moon_fal_ext_05_var4" ] = "moon_fal_ext_05_var4";
	level._scr_radio[ "moon_fal_ext_06" ] = "moon_fal_ext_06";
	level._scr_radio[ "moon_fal_int_01" ] = "moon_fal_int_01";
	level._scr_radio[ "moon_fal_int_02" ] = "moon_fal_int_02";
	level._scr_radio[ "moon_fal_int_03" ] = "moon_fal_int_03";
	level._scr_radio[ "moon_fal_int_04" ] = "moon_fal_int_04";
	level._scr_radio[ "moon_fal_int_05" ] = "moon_fal_int_05";
	level._scr_radio[ "moon_fal_int_06" ] = "moon_fal_int_06";
	level._scr_radio[ "moon_fal_int_07" ] = "moon_fal_int_07";
	level._scr_radio[ "moon_fal_int_08" ] = "moon_fal_int_08";
	level._scr_radio[ "moon_fal_int_09" ] = "moon_fal_int_09";
	level._scr_radio[ "moon_fal_int_breaching" ] = "moon_fal_int_breaching";
	level._scr_radio[ "moon_fal_int_hear" ] = "moon_fal_int_hear";
	level._scr_radio[ "moon_fal_livhal_01" ] = "moon_fal_livhal_01";
	level._scr_radio[ "moon_fal_toarm_01" ] = "moon_fal_toarm_01";
	level._scr_radio[ "moon_fal_toarm_02" ] = "moon_fal_toarm_02";
	level._scr_radio[ "moon_fal_toarm_03" ] = "moon_fal_toarm_03";
	level._scr_radio[ "moon_fal_toarm_04" ] = "moon_fal_toarm_04";
	level._scr_radio[ "moon_fal_toarm_05" ] = "moon_fal_toarm_05";
	level._scr_radio[ "moon_fal_toarm_06" ] = "moon_fal_toarm_06";
	level._scr_radio[ "moon_fal_toarm_07" ] = "moon_fal_toarm_07";
	level._scr_radio[ "moon_fal_toarm_08" ] = "moon_fal_toarm_08";
	level._scr_radio[ "moon_fal_toarm_09" ] = "moon_fal_toarm_09";
	level._scr_radio[ "moon_fal_toarm_gettoarm" ] = "moon_fal_toarm_gettoarm";
	level._scr_radio[ "moon_fal_toarm_storeroom" ] = "moon_fal_toarm_storeroom";
	level._scr_radio[ "moon_fal_toarm_tangodoor" ] = "moon_fal_toarm_tangodoor";
	level._scr_radio[ "moon_fal_toarm_taser" ] = "moon_fal_toarm_taser";
	level._scr_radio[ "moon_hawk_breach_01" ] = "moon_hawk_breach_01";
	level._scr_radio[ "moon_hawk_breach_02" ] = "moon_hawk_breach_02";
	level._scr_radio[ "moon_hawk_breach_03" ] = "moon_hawk_breach_03";
	level._scr_radio[ "moon_hawk_cc_01" ] = "moon_hawk_cc_01";
	level._scr_radio[ "moon_hawk_cc_02" ] = "moon_hawk_cc_02";
	level._scr_radio[ "moon_hawk_cc_03" ] = "moon_hawk_cc_03";
	level._scr_radio[ "moon_hawk_cc_04" ] = "moon_hawk_cc_04";
	level._scr_radio[ "moon_hawk_ext_01" ] = "moon_hawk_ext_01";
	level._scr_radio[ "moon_hawk_ext_02" ] = "moon_hawk_ext_02";
	level._scr_radio[ "moon_hawk_ext_03" ] = "moon_hawk_ext_03";
	level._scr_radio[ "moon_hawk_ext_04" ] = "moon_hawk_ext_04";
	level._scr_radio[ "moon_hawk_ext_05" ] = "moon_hawk_ext_05";
	level._scr_radio[ "moon_hawk_ext_06" ] = "moon_hawk_ext_06";
	level._scr_radio[ "moon_hawk_ext_07" ] = "moon_hawk_ext_07";
	level._scr_radio[ "moon_hawk_ext_08" ] = "moon_hawk_ext_08";
	level._scr_radio[ "moon_hawk_ext_09" ] = "moon_hawk_ext_09";
	level._scr_radio[ "moon_hawk_ext_10" ] = "moon_hawk_ext_10";
	level._scr_radio[ "moon_hawk_ext_11" ] = "moon_hawk_ext_11";
	level._scr_radio[ "moon_hawk_ext_blind" ] = "moon_hawk_ext_blind";
	level._scr_radio[ "moon_hawk_ext_breaching" ] = "moon_hawk_ext_breaching";
	level._scr_radio[ "moon_hawk_ext_charge1" ] = "moon_hawk_ext_charge1";
	level._scr_radio[ "moon_hawk_ext_charge2" ] = "moon_hawk_ext_charge2";
	level._scr_radio[ "moon_hawk_ext_cncclear" ] = "moon_hawk_ext_cncclear";
	level._scr_radio[ "moon_hawk_ext_cooling" ] = "moon_hawk_ext_cooling";
	level._scr_radio[ "moon_hawk_ext_decompression" ] = "moon_hawk_ext_decompression";
	level._scr_radio[ "moon_hawk_ext_downthere" ] = "moon_hawk_ext_downthere";
	level._scr_radio[ "moon_hawk_ext_glad" ] = "moon_hawk_ext_glad";
	level._scr_radio[ "moon_hawk_ext_headedup" ] = "moon_hawk_ext_headedup";
	level._scr_radio[ "moon_hawk_ext_letsmove" ] = "moon_hawk_ext_letsmove";
	level._scr_radio[ "moon_hawk_ext_notenough" ] = "moon_hawk_ext_notenough";
	level._scr_radio[ "moon_hawk_ext_override" ] = "moon_hawk_ext_override";
	level._scr_radio[ "moon_hawk_ext_payback" ] = "moon_hawk_ext_payback";
	level._scr_radio[ "moon_hawk_ext_ready" ] = "moon_hawk_ext_ready";
	level._scr_radio[ "moon_hawk_ext_readytobreach" ] = "moon_hawk_ext_readytobreach";
	level._scr_radio[ "moon_hawk_ext_roger" ] = "moon_hawk_ext_roger";
	level._scr_radio[ "moon_hawk_ext_secondlvl" ] = "moon_hawk_ext_secondlvl";
	level._scr_radio[ "moon_hawk_ext_targethelmet" ] = "moon_hawk_ext_targethelmet";
	level._scr_radio[ "moon_hawk_ext_transblow" ] = "moon_hawk_ext_transblow";
	level._scr_radio[ "moon_hawk_ext_wonthold" ] = "moon_hawk_ext_wonthold";
	level._scr_radio[ "moon_hawk_int_01" ] = "moon_hawk_int_01";
	level._scr_radio[ "moon_hawk_int_02" ] = "moon_hawk_int_02";
	level._scr_radio[ "moon_hawk_int_03" ] = "moon_hawk_int_03";
	level._scr_radio[ "moon_hawk_int_04" ] = "moon_hawk_int_04";
	level._scr_radio[ "moon_hawk_int_05" ] = "moon_hawk_int_05";
	level._scr_radio[ "moon_hawk_int_06" ] = "moon_hawk_int_06";
	level._scr_radio[ "moon_hawk_int_07" ] = "moon_hawk_int_07";
	level._scr_radio[ "moon_hawk_kill_low_01" ] = "moon_hawk_kill_low_01";
	level._scr_radio[ "moon_hawk_kill_low_02" ] = "moon_hawk_kill_low_02";
	level._scr_radio[ "moon_hawk_kill_low_03" ] = "moon_hawk_kill_low_03";
	level._scr_radio[ "moon_hawk_kill_low_04" ] = "moon_hawk_kill_low_04";
	level._scr_radio[ "moon_hawk_kill_low_05" ] = "moon_hawk_kill_low_05";
	level._scr_radio[ "moon_hawk_kill_low_06" ] = "moon_hawk_kill_low_06";
	level._scr_radio[ "moon_hawk_kill_yell_01" ] = "moon_hawk_kill_yell_01";
	level._scr_radio[ "moon_hawk_kill_yell_02" ] = "moon_hawk_kill_yell_02";
	level._scr_radio[ "moon_hawk_kill_yell_03" ] = "moon_hawk_kill_yell_03";
	level._scr_radio[ "moon_hawk_kill_yell_04" ] = "moon_hawk_kill_yell_04";
	level._scr_radio[ "moon_hawk_kill_yell_05" ] = "moon_hawk_kill_yell_05";
	level._scr_radio[ "moon_hawk_kill_yell_06" ] = "moon_hawk_kill_yell_06";
	level._scr_radio[ "moon_hawk_move_01" ] = "moon_hawk_move_01";
	level._scr_radio[ "moon_hawk_move_02" ] = "moon_hawk_move_02";
	level._scr_radio[ "moon_hawk_move_03" ] = "moon_hawk_move_03";
	level._scr_radio[ "moon_hawk_move_04" ] = "moon_hawk_move_04";
	level._scr_radio[ "moon_hawk_move_05" ] = "moon_hawk_move_05";
	level._scr_radio[ "moon_hawk_move_06" ] = "moon_hawk_move_06";
	level._scr_radio[ "moon_hawk_move_07" ] = "moon_hawk_move_07";
	level._scr_radio[ "moon_hawk_move_08" ] = "moon_hawk_move_08";
	level._scr_radio[ "moon_hawk_move_09" ] = "moon_hawk_move_09";
	level._scr_radio[ "moon_hawk_patch_01" ] = "moon_hawk_patch_01";
	level._scr_radio[ "moon_hawk_patch_02" ] = "moon_hawk_patch_02";
	level._scr_radio[ "moon_hawk_patch_03" ] = "moon_hawk_patch_03";
	level._scr_radio[ "moon_hawk_rochase_01" ] = "moon_hawk_rochase_01";
	level._scr_radio[ "moon_hawk_rochase_02" ] = "moon_hawk_rochase_02";
	level._scr_radio[ "moon_hawk_rochase_03" ] = "moon_hawk_rochase_03";
	level._scr_radio[ "moon_hawk_rochase_04" ] = "moon_hawk_rochase_04";
	level._scr_radio[ "moon_hawk_toarm_01" ] = "moon_hawk_toarm_01";
	level._scr_radio[ "moon_hawk_toarm_02" ] = "moon_hawk_toarm_02";
	level._scr_radio[ "moon_hawk_vanrv_01" ] = "moon_hawk_vanrv_01";
	level._scr_radio[ "moon_hawk_vanrv_02" ] = "moon_hawk_vanrv_02";
	level._scr_radio[ "moon_hawk_vanrv_03" ] = "moon_hawk_vanrv_03";
	level._scr_radio[ "moon_hawk_vanrv_04" ] = "moon_hawk_vanrv_04";
	level._scr_radio[ "moon_hawk_vanrv_05" ] = "moon_hawk_vanrv_05";
	level._scr_radio[ "moon_hawk_vanrv_06" ] = "moon_hawk_vanrv_06";
	level._scr_radio[ "moon_hawk_vanrv_07" ] = "moon_hawk_vanrv_07";
	level._scr_radio[ "moon_hawk_vanrv_08" ] = "moon_hawk_vanrv_08";
	level._scr_radio[ "moon_rad_intro_01" ] = "moon_rad_intro_01";
	level._scr_radio[ "moon_rad_intro_01m" ] = "moon_rad_intro_01m";
	level._scr_radio[ "moon_spid_int_downhere" ] = "moon_spid_int_downhere";
	level._scr_radio[ "moon_spid_int_welcome" ] = "moon_spid_int_welcome";

	level._scr_radio[ "moon_rand2_run_01" ] = "moon_rand2_run_01";
	level._scr_radio[ "moon_rand1_run_02" ] = "moon_rand1_run_02";
	level._scr_radio[ "moon_bc_arm_02" ] = "moon_bc_arm_02";
	level._scr_radio[ "moon_rand2_run_03" ] = "moon_rand2_run_03";
	level._scr_radio[ "moon_rand1_run_04" ] = "moon_rand1_run_04";
	level._scr_radio[ "moon_rand1_run_05" ] = "moon_rand1_run_05";
	level._scr_radio[ "moon_rand1_run_06" ] = "moon_rand1_run_06";
	level._scr_radio[ "moon_rand1_run_07" ] = "moon_rand1_run_07";
	level._scr_radio[ "moon_rand1_run_08" ] = "moon_rand1_run_08";
	level._scr_radio[ "moon_rand2_run_01" ] = "moon_rand2_run_01";
	level._scr_radio[ "moon_rand2_run_02" ] = "moon_rand2_run_02";
	level._scr_radio[ "moon_rand2_run_03" ] = "moon_rand2_run_03";
	level._scr_radio[ "moon_rand2_run_04" ] = "moon_rand2_run_04";
	level._scr_radio[ "moon_rand2_run_05" ] = "moon_rand2_run_05";
	level._scr_radio[ "moon_rand2_run_06" ] = "moon_rand2_run_06";
	level._scr_radio[ "moon_rand2_run_07" ] = "moon_rand2_run_07";
	level._scr_radio[ "moon_rand2_run_08" ] = "moon_rand2_run_08";
	level._scr_radio[ "moon_spid_int_downhere" ] = "moon_spid_int_downhere";
	level._scr_radio[ "moon_spid_int_welcome" ] = "moon_spid_int_welcome";

	level._scr_radio[ "moon_eag_int_emergencydoor" ] = "moon_eag_int_emergencydoor";
	level._scr_radio[ "moon_eag_int_override" ] = "moon_eag_int_override";
	level._scr_radio[ "moon_eag_int_okwere" ] = "moon_eag_int_okwere";
	level._scr_radio[ "moon_eag_int_shitnothing" ] = "moon_eag_int_shitnothing";
	level._scr_radio[ "moon_eag_int_crewcommons" ] = "moon_eag_int_crewcommons";
	level._scr_radio[ "moon_eag_int_cycling" ] = "moon_eag_int_cycling";
	level._scr_radio[ "moon_eag_int_walkerget" ] = "moon_eag_int_walkerget";
	level._scr_radio[ "moon_eag_int_onmy" ] = "moon_eag_int_onmy";
	level._scr_radio[ "moon_fal_toarm_wherehelmet" ] = "moon_fal_toarm_wherehelmet";
	level._scr_radio[ "moon_fal_toarm_poproom" ] = "moon_fal_toarm_poproom";
	level._scr_radio[ "moon_fal_toarm_breachmove" ] = "moon_fal_toarm_breachmove";
	level._scr_radio[ "moon_fal_toarm_moveit" ] = "moon_fal_toarm_moveit";
	level._scr_radio[ "moon_fal_toarm_thisway" ] = "moon_fal_toarm_thisway";
	level._scr_radio[ "moon_fal_toarm_wheregoing" ] = "moon_fal_toarm_wheregoing";
	level._scr_radio[ "moon_fal_toarm_movedamn" ] = "moon_fal_toarm_movedamn";
	level._scr_radio[ "moon_fal_toarm_tangosahead" ] = "moon_fal_toarm_tangosahead";
	level._scr_radio[ "moon_fal_toarm_twomore" ] = "moon_fal_toarm_twomore";

	// Scripted Battle Chatter
	level._scr_radio[ "jswc_eag_co_lm_crt_stk" ] = "jswc_eag_co_lm_crt_stk";
	level._scr_radio[ "jswc_eag_co_lm_oxtnks" ] = "jswc_eag_co_lm_oxtnks";
	level._scr_radio[ "jswc_eag_order_move_noncombat" ] = "jswc_eag_order_move_noncombat";
	level._scr_radio[ "jswc_fal_resp_ack_co_gnrc_affirm" ] = "jswc_fal_resp_ack_co_gnrc_affirm";
	level._scr_radio[ "jswc_fal_resp_ack_co_gnrc_neg" ] = "jswc_fal_resp_ack_co_gnrc_neg";
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "generic_human" );
dead_crew()
{
	dead_crew_members = GetEntArray( "dead_crew", "targetname" );
	// For the first checkpoints hide all the dead crew and wait for the player to get the rifle in the armory
	if ( level._start_point == "get_to_the_armory" || level._start_point == "rover_chase" || level._start_point == "intro" || level._start_point == "default")
	{
		foreach( dead_crew_member in dead_crew_members )
		dead_crew_member hide();
		flag_wait ("player_has_weapon");
	}
	
	// Show and pose all the dead crew
	foreach( dead_crew_member in dead_crew_members )
	{
		dead_crew_member show();
		dead_crew_member UseAnimTree( #animtree );
		dead_crew_member thread anim_generic( dead_crew_member, dead_crew_member.script_animation );
		dead_crew_member SetAnimTime( getanim_generic( dead_crew_member.script_animation ), 1 );		
	}
}


dead_crew_wakeup()
{
	dead_crew_members = GetEntArray( "dead_crew_wakeup", "targetname" );
	
	// Show and pose all the dead crew
	foreach( dead_crew_member in dead_crew_members )
	{
		dead_crew_member UseAnimTree( #animtree );
		dead_crew_member thread anim_generic( dead_crew_member, dead_crew_member.script_animation );
		dead_crew_member SetAnimTime( getanim_generic( dead_crew_member.script_animation ), 1 );		
	}
	flag_wait ("top_floor_breach");
	// Delete them after they're no longer visible for greenlight

	foreach( dead_crew_member in dead_crew_members )
	{
		dead_crew_member delete();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

back_to_rover(rover)
{

	node = getstruct("vignette_back_to_rover", "script_noteworthy");

	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player disableweapons();
	level._player takeallweapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["player_rig"] = player_rig;

	arc = 15;

	player_rig LinkTo( rover, "TAG_DRIVER", (0,0,0), (0,0,0) );

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1, true);

	node anim_single(guys, "back_to_rover");

	level._player Unlink();
	player_rig Delete();

	//these will unlink the player and unfreeze the controls when you need to.
	/*
	level._player FreezeControls( false );
	level._player unlink();
	level._player allowprone( true );
	level._player allowcrouch( true );
	*/
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
 
// self - node origin for vignette
ally_door_breach_reach( hawk )
{
	opener = level.eagle;
	if( hawk )
{
		opener = level.hawk;
	}

	if( IsAlive( opener ) )
	{
		opener ent_flag_init_or_clear( "at_breach_door" );
		self thread ally_door_breach_reach_individual( opener, "Cover Right" );
	}

//	if( IsAlive( level.falcon ) )
//	{
//		level.falcon ent_flag_init_or_clear( "at_breach_door" );
//		self thread ally_door_breach_reach_individual( level.falcon, "Cover Left" );
//	}	

	if( IsAlive( opener ) )
	{
		opener ent_flag_wait( "at_breach_door" );
	}

//	if( IsAlive( level.falcon ) )
//	{
//		level.falcon ent_flag_wait( "at_breach_door" );
//	}
}

ally_door_breach_play( hawk )
{
	opener = level.eagle;
	if( hawk )
	{
		opener = level.hawk;
	}

	guys = [];

	if( IsAlive( opener ) )
	{
		guys[ opener.animname ] = opener;
	}

//	if( IsAlive( level.falcon ) )
//	{
//		guys["falcon"] = level.falcon;
//	}

	self anim_single(guys, "ally_door_breach");

	if( IsAlive( opener ) )
	{
		opener enable_ai_color();
	}

//	if( IsAlive( level.falcon ) )
//	{
//		level.falcon enable_ai_color();
//	}
}

ally_door_breach_reach_individual( opener, breach_approach )
{
	opener endon ( "death" );
	my_anim_node = self create_my_anim_node();

	my_anim_node anim_reach_and_approach_and_idle_solo( opener, "ally_door_breach", breach_approach, "ally_door_breach_idle", "stop_ally_door_breach_idle", undefined );
	opener ent_flag_set( "at_breach_door" );

	my_anim_node Delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

opfor_door_breach( node, opfor_01, opfor_02, breach_name )
{
	if( IsDefined( opfor_01 ) )
	{
		opfor_01.animname = "opfor_01";

		opfor_01 ent_flag_init_or_clear( "at_breach_door" );
		opfor_01 ent_flag_init_or_clear( "door_breached" );

		node thread opfor_door_breach_opfor_01( opfor_01, opfor_02, breach_name );
	}

	if( IsDefined( opfor_02 ) )
	{
		opfor_02.animname = "opfor_02";

		opfor_02 ent_flag_init_or_clear( "at_breach_door" );
		opfor_02 ent_flag_init_or_clear( "door_breached" );

		node thread opfor_door_breach_opfor_02( opfor_01, opfor_02, breach_name );
	}
}

opfor_door_breach_opfor_01( opfor_01, opfor_02, breach_name )
{
	opfor_01 endon ( "death" );	
	opfor_01 endon ( "stop_breach");

	thread breach_charge_fx( opfor_01 );

	my_anim_node = self create_my_anim_node();

	
	if( IsDefined( opfor_01.curr_breach_door ) )
	{
		// If it's the inner lower vehicle bay breach
		if (opfor_01.curr_breach_door == "vehicle_door_02")
		{
			opfor_01 StopAnimScripted();
			my_anim_node anim_teleport_solo ( opfor_01, "opfor_door_breach");
			my_anim_node anim_first_frame_solo (opfor_01, "opfor_door_breach");
			flag_wait ("vehicle_bay_breach_skip_to_charge");
		}
		// If it's the first hub room breach
		if (opfor_01.curr_breach_door == "hub_01_door_01")
		{
			opfor_01 StopAnimScripted();
			my_anim_node anim_teleport_solo ( opfor_01, "opfor_door_breach");
			flag_wait ("hub_room_breach_start");
		}
		else
		{
			my_anim_node anim_reach_and_approach_solo( opfor_01, breach_name, undefined, "Cover Right" );
		}
	}
	else
	{
		my_anim_node anim_reach_and_approach_solo( opfor_01, breach_name, undefined, "Cover Right" );
	}

	// Wait for partner
	opfor_01 ent_flag_set( "at_breach_door" );
	if( IsDefined( opfor_02 ) )
	{
		opfor_02 ent_flag_wait( "at_breach_door" );
	}

	
	// Currently means "if this is any breach other than the vehicle bay breach"
	if ( breach_name == "opfor_door_breach" )
	{
		// KenM - Making sure the breacher has his gun out, sometimes he does not.
		opfor_01 forceUseWeapon( "breacher", "primary" );
		my_anim_node thread anim_single_solo( opfor_01, "opfor_door_breach" );
		// If it's the inner lower vehicle bay breach
		if( IsDefined( opfor_01.curr_breach_door ) )
		{
			if ( opfor_01.curr_breach_door == "vehicle_door_02" || opfor_01.curr_breach_door == "hub_01_door_01" )
			{	
				// Have to wait a bit or else this doesn't work for some reason.
				wait 0.05;
				animation = opfor_01 getanim( "opfor_door_breach" );
				opfor_01 SetAnimTime ( animation, 0.2);
			}
		}
		while ( opfor_01 GetAnimTime( level._scr_anim[ "opfor_01" ][ "opfor_door_breach" ] ) < 1)
		{
			wait .1;
		}
		my_anim_node thread anim_loop_solo( opfor_01, "opfor_door_breach_loop", "stop_loop" );
		opfor_01 notify("charged");
		print ( "charged");
		opfor_01 waittill("detonate");
		opfor_01 ent_flag_set( "door_breached" );
		my_anim_node notify("stop_loop");
		my_anim_node anim_single_solo( opfor_01, "opfor_door_breach_detonate" ); 
	}
	// Otherwise, it is the vehicle bay breach
	else
	{
		my_anim_node anim_single_solo( opfor_01, "vehiclebay_breach" );
		opfor_01 ent_flag_set( "door_breached" );
	}

	// Delete own node
	my_anim_node Delete();

}

opfor_door_breach_opfor_02( opfor_01, opfor_02, breach_name )
{
	opfor_02 endon ( "death" );	
	opfor_01 endon ( "stop_breach" );

	// Create actor's own node
	my_anim_node = self create_my_anim_node();

	
	if( IsDefined( opfor_01.curr_breach_door ) )
	{
		// If it's the inner lower vehicle bay breach
		if (opfor_01.curr_breach_door == "vehicle_door_02" )
		{
			opfor_02 StopAnimScripted();
			my_anim_node anim_teleport_solo ( opfor_02, "opfor_door_breach");
			my_anim_node anim_first_frame_solo (opfor_02, "opfor_door_breach");
			flag_wait ("vehicle_bay_breach_skip_to_charge");
		}
		// If it's the first hub room breach
		if (opfor_01.curr_breach_door == "hub_01_door_01")
		{
			opfor_02 StopAnimScripted();
			my_anim_node anim_teleport_solo ( opfor_02, "opfor_door_breach");
			flag_wait ("hub_room_breach_start");
		}
		else
		{
			my_anim_node anim_reach_and_approach_solo( opfor_02, breach_name, undefined, "Cover Left" );
		}
	}
	else
	{
		my_anim_node anim_reach_and_approach_solo( opfor_02, breach_name, undefined, "Cover Left" );
	}

	// Wait for partner
	opfor_02 ent_flag_set( "at_breach_door" );
	if( IsDefined( opfor_01 ) )
	{
		opfor_01 ent_flag_wait( "at_breach_door" );
	}

	// If it's the generic breach animation
	if ( breach_name == "opfor_door_breach" )
	{

		my_anim_node thread anim_single_solo( opfor_02, "opfor_door_breach" );
		// If it's the inner lower vehicle bay breach
		if( IsDefined( opfor_01.curr_breach_door ) )
		{
			if (opfor_01.curr_breach_door == "vehicle_door_02" || opfor_01.curr_breach_door == "hub_01_door_01")
			{
				// Have to wait a bit or else this doesn't work for some reason.
				wait 0.05;
				animation = opfor_02 getanim( "opfor_door_breach" );
				opfor_02 SetAnimTime ( animation, 0.2);
			}
		}
		while ( opfor_01 GetAnimTime( %nx_tp_lunar_opfor_door_breach_opfor_01_breach ) < 1)
		{
			wait .1;
		}
		my_anim_node thread anim_loop_solo( opfor_02, "opfor_door_breach_loop", "stop_loop" );
		// wait for the breacher guy to get the go ahead
		opfor_01 waittill( "detonate" );
		my_anim_node notify( "stop_loop" );
		my_anim_node anim_single_solo( opfor_02, "opfor_door_breach_detonate" );
		
	}
	// Otherwise, it is the vehicle bay breach
	else
	{
		my_anim_node anim_single_solo( opfor_02, "vehiclebay_breach" );
	}

	opfor_02 ent_flag_set( "door_breached" );

	// Delete own node
	my_anim_node Delete();
}

create_my_anim_node()
{
	my_anim_node = Spawn( "script_origin", self.origin );
	my_anim_node.angles = self.angles;
	return my_anim_node;
}

ent_flag_init_or_clear( ent_flag )
{
	if ( !ent_flag_exist ( ent_flag ) )
	{
		self ent_flag_init( ent_flag );
	}
	else
	{
		self ent_flag_clear( ent_flag );
	}
}

// notetrack functions for door vehicle bay door breach
breach_charge( opfor_01 )
{
	start_org = opfor_01 GetTagOrigin( "tag_flash" );
	// when "shots" are fired into the door
	opfor_01 notify ("charge_inserted");
	// PlayFX( level._effect[ "breach_charge" ], start_org , ( 1, 0, 0 ) );

	// The door they're breaching detects a pressure change
	if( IsDefined( opfor_01.curr_breach_door ) )
	{
		level thread maps\nx_lunar_util::lunar_door_status( opfor_01.curr_breach_door, "status_yellow" );
		print ( opfor_01.curr_breach_door );
	}
	

	// Sound effect
	mynodeEntity = spawn( "sound_emitter", start_org );
	if (isdefined (opfor_01.curr_breach_room))
	{
		room = opfor_01.curr_breach_room;
		if (flag ( room ))
		{
			// The player is in the room being breached
			mynodeEntity PlaySound("scn_lunar_breach_charge", "scn_lunar_breach_charge");
			mynodeEntity thread breach_sound_silencer();
			thread createwarningvo();
		}
		else
		{
			// The player is not in the room being breached
			mynodeEntity PlaySound("scn_lunar_breach_charge", "scn_lunar_breach_charge");
		}
	}
	else
	{
		// No room is defined. This should only occur on the vehicle bay breach vignette 
		mynodeEntity PlaySound("scn_lunar_breach_charge", "scn_lunar_breach_charge");
	}
	if ( Distance( level._player.origin, mynodeEntity.origin ) < 600 )
	{
		level._player PlaySound( "scn_lunar_breach_mtlshake" );
	}
	mynodeEntity waittill( "scn_lunar_breach_charge" );
	mynodeEntity delete();

}

breach_charge_fx (opfor_01)
{
	opfor_01 endon ( "death" );	
	opfor_01 endon ( "stop_breach");

	start_org = opfor_01 GetTagOrigin( "tag_flash" );

	if( IsDefined( opfor_01.curr_breach_door ) )
	{
		
		door_name = opfor_01.curr_breach_door;
		
		// Get parts array
		lunar_door_parts = GetEntArray( door_name, "script_noteworthy" );
	
		// Get the fx origins
		breach_charge_fx_01 = undefined;
		breach_charge_fx_02 = undefined;
		foreach ( door_part in lunar_door_parts )
		{
			if( door_part.code_classname == "script_origin" )
			{
				if( door_part.targetname == "breach_fx_01" )
				{
					breach_charge_fx_01 = door_part;
				}
				if( door_part.targetname == "breach_fx_02" )
				{
					breach_charge_fx_02 = door_part;
				}
			}
		}

		// First Charge
		opfor_01 waittill ("charge_inserted");
	
		// Spark FX.
		PlayFX( level._effect[ "breach_charge" ], breach_charge_fx_01.origin , breach_charge_fx_02.angles + ( 90, 0, 0 ) );
	
		//spawn a model for the breacher wedge
		breach_wedge_1 = spawn_anim_model("breacher_wedge", breach_charge_fx_01.origin );
		breach_wedge_1.angles = ( breach_charge_fx_01.angles + (-180, 0, 0));
		playFXOnTag( level._effect[ "nx_lunar_breach_charge_insert_back_air" ], breach_wedge_1, "tag_fx" );
		
		
		print ("charge one");
	
		// Second Charge
		opfor_01 waittill ("charge_inserted");

		// Spark FX.
		PlayFX( level._effect[ "breach_charge" ], breach_charge_fx_02.origin , breach_charge_fx_02.angles + ( 90, 0, 0 ) );
	
		//spawn a model for the breacher wedge
		breach_wedge_2 = spawn_anim_model("breacher_wedge", breach_charge_fx_02.origin );
		breach_wedge_2.angles = ( breach_charge_fx_01.angles + (-180, 0, 0));
		playFXOnTag( level._effect[ "nx_lunar_breach_charge_insert_back_air" ], breach_wedge_2, "tag_fx" );

		print ("charge two");
	
		// Detonation
		opfor_01 waittill ("detonate");

		wait .3;

		// Cleanup
		stopFXOnTag( level._effect[ "nx_lunar_breach_charge_insert_back_air" ], breach_wedge_1, "tag_fx" );
		stopFXOnTag( level._effect[ "nx_lunar_breach_charge_insert_back_air" ], breach_wedge_2, "tag_fx" );

		breach_wedge_1 delete ();
		breach_wedge_2 delete ();

	}
}

createwarningvo()
{
		//warningvospawn = spawn( "script_origin", ( 4385, -283, -1566 ) );		
		//warningvospawn MoveTo( level._player.origin + ( randomintrange( -1200, 1200 ), randomintrange( -1200, 1200 ), 0 ), 0.01 );
		//warningvospawn PlaySound( "emt_lunar_breach_vo", "emt_lunar_breach_vo", true );
		//warningvospawn waittill( "emt_lunar_breach_vo" );
		//warningvospawn delete();
		level._player playsound( "emt_lunar_breach_vo" );
}

breach_sound_silencer()
{
	// Player was in a breached room, but the door closed behind them. 
	// self endon ("scn_lunar_breach_charge");
	// level waittill ("player_escaped_breached_room");
	// self Stopsounds ();
}

breach_detonate( opfor_01 )
{
	// Destroy the door
	if( IsDefined( opfor_01.curr_breach_door ) )
	{
		level thread maps\nx_lunar_util::open_lunar_door( opfor_01.curr_breach_door, 0.1, true );
		level thread maps\nx_lunar_util::lunar_door_breach_fx( opfor_01.curr_breach_door ); 

		// If it's the armory breach
		if (opfor_01.curr_breach_door == "armory_door_breach")
		{
			// instantly trigger the breach vignette
			flag_set ("vignette_armory_breach");
			return;
		}

		// If it's the vehicle bay breach
		if (opfor_01.curr_breach_door == "vehicle_hatch_breach")
		{
			// trigger some extra effects 
			Earthquake( 0.3, 0.5, level._player.origin, 100 );
			level._player PlayRumbleOnEntity( "damage_light" );
			opfor_01 notify ("detonate");
		}
	}

	// Depressurize room
	if( IsDefined( opfor_01.curr_breach_room ) )
	{
		level thread maps\nx_lunar_get_to_the_armory::room_status_depressurize( opfor_01.curr_breach_room );
	}

	if( IsDefined( opfor_01.curr_breach_door ) )
	{
		wait .3;
		level thread maps\nx_lunar_util::lunar_door_status( opfor_01.curr_breach_door, "status_green" );
		level thread maps\nx_lunar_util::lunar_door_keypad_error ( opfor_01.curr_breach_door );
	}
	opfor_01.curr_breach_door = undefined;
	opfor_01.curr_breach_room = undefined;
	opfor_01 notify ("breach_done");
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_vehiclebay_breach_player_enters_airlock()
{
	level notify ("player_in_vehicle_airlock_notify");
	node = getent("vignette_vh_bay_breach_player", "script_noteworthy");

	helmet_player = spawn_anim_model("helmet_player");
	player_rig = spawn_anim_model( "player_rig" );
	player_rig Hide();

	helmet_player Hide();

	player = [];
	player["player_rig"] = player_rig;
	player ["helmet_player"] = helmet_player;

	level._player playerLinkToBlend( player_rig, "tag_player", 0.75 );

	player_rig thread vignette_vehiclebay_breach_player_look();

	node anim_single(player, "vehiclebay_breach_player");

	// ---might need to use this to link player to view entire breach sequence.  
	// ---will possibly have to use a custom note track to unlink him in the next vignette.

	// flag_wait ("vehicle_airlock_open");

	// Stop the player stumble walk. Doing this here to prevent player from crouching until the anim is done.
	level thread maps\nx_lunar_get_to_the_armory::stop_stumble_walk( 0.05 );
	flag_set ("airlock_animation_done");
	level._player unlink();
	player_rig delete();

}

unhide_arms( player_rig )
{
	player_rig Show();
}

vignette_vehiclebay_breach_player_look()
{
	// Wait until the PC collapses against the window
	wait 16;

	Harc = 45;
	Varc = 15;

	level._player PlayerLinkToDelta( self, "tag_player", 1, Harc, Harc, Varc, Varc, 1);
}

// note track that will unhide script model for player helmet
spawn_helmet( helmet_player )
{
	helmet_player Show();	
	target = GetEnt ("helmet_breach_target", "targetname");


	// trigger security alert VO
	flag_set ("vo_base_compromise_bc");
	
	// Wait until the airlock is breached
	room_status_vehicle_airlock = GetEnt ( "room_status_vehicle_airlock", "targetname");
	room_status_vehicle_airlock ent_flag_wait( "depressurize" );

	// Blow the helmet out the airlock
	helmet_player MoveTo( target.origin, .8, .2, 0 );
	helmet_player RotateTo( target.angles, .8, .2, 0  );
	helmet_player waittill ("movedone");
	wait 10;
	helmet_player delete();
}

helmet_hits_ground(helmet_player)
{
	// play glass breaking effect on the player's helmet when he drops it inside the airlock.
	playfx( level._effect[ "nx_lunar_intro_glass_helmet_drop" ], helmet_player.origin );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_vehiclebay_breach_spawn()
{
	opfor_01 = vignette_actor_spawn("vehiclebay_breach_opfor01", "opfor_01");
	opfor_02 = vignette_actor_spawn("vehiclebay_breach_opfor02", "opfor_02");
	civ_01 = vignette_actor_spawn("vehiclebay_breach_civ01", "civ_01");
	civ_02 = vignette_actor_spawn("vehiclebay_breach_civ02", "civ_02");
	 
	vignette_vehiclebay_breach(civ_01, civ_02, opfor_01, opfor_02);
	
	opfor_01 vignette_actor_delete();
	opfor_02 vignette_actor_delete();	
	civ_01 vignette_actor_delete();	
	civ_02 vignette_actor_delete();		
}

vignette_vehiclebay_breach(civ_01, civ_02, opfor_01, opfor_02)
{
	node = getent("vignette_vh_bay_breach", "script_noteworthy");

	opfor = [];
	opfor["opfor_01"] = opfor_01;
	opfor["opfor_02"] = opfor_02;

	civs["civ_01"] = civ_01;
	civs["civ_02"] = civ_02; 

	//temp commented out loop anim for later integration.
	/*
	node thread anim_loop(civs, "vehiclebay_breach_loop");
	
	wait 5;
	foreach (civ in civs)
	{
		civ StopAnimScripted();
	}
	*/

	opfor = array_combine( opfor, civs );	

	node anim_first_frame( civs, "vehiclebay_breach" );

	// tagTC<note> - added generic breach logic scripts here to call reach
	// and anim play on the opfor actors
	level thread opfor_door_breach( node, opfor_01, opfor_02, "vehiclebay_breach" );
	opfor_01.curr_breach_door = "vehicle_hatch_breach";

	opfor_01 ent_flag_wait( "at_breach_door" );
	opfor_02 ent_flag_wait( "at_breach_door" );

	node anim_single( civs, "vehiclebay_breach" );

	// Kill the civilians
	civ_01 vignette_actor_kill();
	civ_02 vignette_actor_kill();

} 

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

top_floor_breach_spawn()
{
	/*
	vignettescientist1 = vignette_actor_spawn("vignettescientist1", "vignettescientist1"); //"value" (kvp), "anim_name"
	vignettescientist2 = vignette_actor_spawn("vignettescientist2", "vignettescientist2"); //"value" (kvp), "anim_name"
	vignettescientist3 = vignette_actor_spawn("vignettescientist3", "vignettescientist3"); //"value" (kvp), "anim_name"
	vignettescientist4 = vignette_actor_spawn("vignettescientist4", "vignettescientist4"); //"value" (kvp), "anim_name"
	vignette_playerlegs = vignette_actor_spawn("vignette_playerlegs", "vignette_playerlegs"); //"value" (kvp), "anim_name"
	vignettescientist5 = vignette_actor_spawn("vignettescientist5", "vignettescientist5"); //"value" (kvp), "anim_name"
	vignettescientist6 = vignette_actor_spawn("vignettescientist6", "vignettescientist6"); //"value" (kvp), "anim_name"
	*/

	vignettescientist1 = spawn_anim_model("model_civ_01");
	vignettescientist2 = spawn_anim_model("model_civ_02");
	vignettescientist3 = spawn_anim_model("model_civ_03");
	vignettescientist4 = spawn_anim_model("model_civ_04");
	vignette_playerlegs = vignette_actor_spawn("vignette_playerlegs", "vignette_playerlegs"); //"value" (kvp), "anim_name"
	vignettescientist5 = spawn_anim_model("model_civ_05");
	vignettescientist6 = spawn_anim_model("model_civ_06");

	level.model6 = spawn_anim_model("model6");

	vignette_playerlegs hide();

	node = getstruct("vignette_topfloorbreach", "script_noteworthy");

	guys = [];
	guys["vignettescientist1"] = vignettescientist1;
	guys["vignettescientist2"] = vignettescientist2;
	guys["vignettescientist3"] = vignettescientist3;
	guys["vignettescientist4"] = vignettescientist4;
	guys["vignette_playerlegs"] = vignette_playerlegs;
	guys["vignettescientist5"] = vignettescientist5;
	guys["vignettescientist6"] = vignettescientist6;
	guys["model6"] = level.model6;

	node anim_first_frame( guys, "top_floor_breach" );

	flag_wait ("top_floor_breach");

	vignette_playerlegs show();

	top_floor_breach(vignettescientist1, vignettescientist2, vignettescientist3, vignettescientist4, vignette_playerlegs, vignettescientist5, vignettescientist6, level.model6);

	vignettescientist1 vignette_actor_delete();
	vignettescientist2 vignette_actor_kill();
	vignettescientist3 vignette_actor_delete();
	vignettescientist4 vignette_actor_delete();
	vignette_playerlegs vignette_actor_delete();
	vignettescientist5 vignette_actor_delete();
	vignettescientist6 vignette_actor_delete();
}

top_floor_breach(vignettescientist1, vignettescientist2, vignettescientist3, vignettescientist4, vignette_playerlegs, vignettescientist5, vignettescientist6, model6)
{
	// Camera is in the wrong place if player is crouched or prone
	level._player setstance( "stand" );

	node = getstruct("vignette_topfloorbreach", "script_noteworthy");

	// model6 = model6;

	model8 = spawn_anim_model("model8");

	ammo_box_1 = spawn_anim_model("ammo_box_1");

	ammo_box_2 = spawn_anim_model("ammo_box_2");

	ammo_box_2_open = spawn_anim_model("ammo_box_2_open");

	ammo_box_3 = spawn_anim_model("ammo_box_3");

	ammo_box_3_open = spawn_anim_model("ammo_box_3_open");

	crate2 = spawn_anim_model("crate2");

	monitor = spawn_anim_model("monitor");

	temp_handles = spawn_anim_model("temp_handles");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["vignettescientist1"] = vignettescientist1;
	guys["vignettescientist2"] = vignettescientist2;
	guys["vignettescientist3"] = vignettescientist3;
	guys["vignettescientist4"] = vignettescientist4;
	guys["vignette_playerlegs"] = vignette_playerlegs;
	guys["player_rig"] = player_rig;
	guys["model6"] = model6;
	guys["vignettescientist5"] = vignettescientist5;
	guys["model8"] = model8;
	guys["ammo_box_1"] = ammo_box_1;
	guys["ammo_box_2"] = ammo_box_2;
	guys["ammo_box_2_open"] = ammo_box_2_open;
	guys["ammo_box_3"] = ammo_box_3;
	guys["ammo_box_3_open"] = ammo_box_3_open;
	guys["crate2"] = crate2;
	guys["vignettescientist6"] = vignettescientist6;

	guys["monitor"] = monitor;
	guys["temp_handles"] = temp_handles;

	Harc = 15;
	Varc = 15;

	level._player playerLinkToBlend( player_rig, "tag_player", 1.75 );
	// level._player PlayerLinkToDelta( player_rig, "tag_player", 1, Harc, Harc, Varc, Varc, 1);

	// vision set sequencing
	thread maps\nx_lunar_fx::fx_control_room_vision_sequence();

	thread top_floor_breach_fx();

	node anim_single(guys, "top_floor_breach");

	level._player unlink();

	player_rig delete();

	// Clean up trash. Note; Model8 remains in the room. Model6 is the shutter
	ammo_box_1 delete();
	ammo_box_2 delete();
	ammo_box_2_open delete();
	ammo_box_3 delete();
	ammo_box_3_open delete();
	crate2 delete();
	monitor delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

	level notify ("top_floor_breach_done");

	level._player blend_movespeedscale( 0.5, 0.1 );
	level._player delayThread( 1, ::blend_movespeedscale, 1, 5 );

	level._ground_ref_ent = spawn( "script_model", ( 0, 0, 0 ) );
	level._player playerSetGroundReferenceEnt( level._ground_ref_ent ); 
	
	// Stumble walk after breach
	level._player AllowSprint( false );
	level thread maps\nx_lunar_get_to_the_armory::stumble_walk( 0, 20.0, false , true, 0.0, false   );
	wait 5;
	
	level._player AllowSprint( true );
	level thread maps\nx_lunar_get_to_the_armory::stop_stumble_walk( 0.5 );
}

top_floor_breach_rover_fires( player_rig )
{
	level notify ("rover_fires_notify");
}

top_floor_breach_fx()
{
	
	level thread glass_destroyed_sfx();
	wait 0.1;
	magicBullet( "nx_chinese_lgv_turret_magicbullet_metal", ( 4113, -187, -1591), ( 4688, -650, -1560) );
	level._player PlayRumbleOnEntity( "damage_heavy" );

	wait 0.3;
	magicBullet( "nx_chinese_lgv_turret_magicbullet_metal", ( 4113, -187, -1591), ( 4688, -600, -1540) );

	wait 0.1;
	exploder( "fx_top_floor_breach" );

	wait 0.2;
	magicBullet( "nx_chinese_lgv_turret_magicbullet_metal", ( 4113, -187, -1591), ( 4688, -500, -1530) );

	wait 0.2;
	exploder( "fx_top_floor_sparks" );

	wait 3.3;
	exploder( "fx_top_floor_rip_sparks" );
	exploder( "fx_top_floor_rip_explosion" );

	wait 0.5;
	stop_exploder( "fx_top_floor_rip_explosion" );
	exploder( "fx_top_floor_monitor_sparks" );

	wait 1.9;
	stop_exploder( "fx_top_floor_breach" );
	stop_exploder( "fx_top_floor_sparks" );
	stop_exploder( "fx_top_floor_rip_sparks" );
	stop_exploder( "fx_top_floor_monitor_sparks" );
	exploder( "fx_top_floor_linger" );
}

glass_destroyed_sfx()
{

	flag_set( "music_2nd_floor_breach_starts" );
	//level._player setchannelvolumes( "snd_channelvolprio_level", "nx_lunar_2nd_floor_first_stop", 0.1 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_pain", "nx_lunar_2nd_floor_glass", 0.4 );
	wait 0.2;
	level._player playsound( "scn_2nd_floor_glass_break" );
	thread audio_play_localized_vo();
	wait 7.7;
	flag_set( "music_2nd_floor_breach_ends" );
	level._player deactivatechannelvolumes( "snd_channelvolprio_pain", 1 );

}

audio_play_localized_vo()
{

	localizedvo = spawn( "sound_emitter", ( 4516, -164, -1556 ) );
	localizedvo PlaySound( "scn_2nd_floor_glass_break_vo", "scn_2nd_floor_glass_break_vo", true );
	localizedvo waittill( "scn_2nd_floor_glass_break_vo" );
	localizedvo delete();

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

top_floor_reopen()
{
	if( IsDefined( level.model6 ) )
	{
		level.model6 delete();
	}

	model6 = spawn_anim_model( "model6" );

	node = getstruct( "vignette_topfloorbreach", "script_noteworthy" );

	node anim_single_solo( model6, "top_floor_breach" );

	level waittill( "start_shadows_shutter_open" );

	node anim_single_solo( model6, "into_shadows_shutter_open" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


taser_spawn()
{
	//falcon = vignette_actor_spawn("falcon_taser", "falcon"); //"value" (kvp), "anim_name"
	// opfor = vignette_actor_spawn("opfor_taser", "opfor"); //"value" (kvp), "anim_name"
	waittillframeend;

	thread meet_falcon_falcon( level.falcon_taser );
	// thread meet_falcon_enemy( opfor );
	// taser(level.falcon_taser, opfor);

	// falcon vignette_actor_delete();
	// opfor vignette_actor_kill();
}

meet_falcon_falcon( falcon )
{

	node = getstruct("vignette_falcon_taser_handoff", "script_noteworthy");

	taser = spawn_anim_model("taser");

	guys = [];
	guys["falcon"] = falcon;
	guys["taser"] = taser;

	node anim_single( guys, "taser" );

	node thread anim_loop( guys, "taser_loop", "stop_loop");

	// play looping Falcon

	flag_wait( "falcon_taser_handoff" );
	node notify ("stop_loop");

	//falcon hands you the taser
	node anim_single(guys, "taser_handoff");

}

meet_falcon_enemy( opfor )
{
	node = getstruct("vignette_taser", "script_noteworthy");
	opfor SetLookAtEntity( level._player );
	node anim_single_solo( opfor , "taser");
	opfor StopLookAt( );
	opfor vignette_actor_kill();
}

falcon_shoots_taser( opfor )
{
	MagicBullet( "lunarrifle", level.falcon_taser gettagorigin( "tag_flash"), (opfor.origin + (0,0,32)) );
}


taser_catch( taser )
{
	level notify ("taser_catch");
	taser delete();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_scientist_run_01_spawn()
{
	civ01 = vignette_actor_spawn("scientist_run_civ01", "civ01");
	civ02 = vignette_actor_spawn("scientist_run_civ02", "civ02");

	vignette_scientist_run_01(civ01, civ02);


	civ01 vignette_actor_delete();
	civ02 vignette_actor_delete();
}

vignette_scientist_run_01(civ01, civ02)

{
	// there are two nodes in this case because they are considered two different vignettes 
	// that must play at the same time yet can't overlap.
	node_01 = getstruct("vignette_scientist_run_01", "script_noteworthy");

	node_02 = getstruct("vignette_scientist_run_02", "script_noteworthy");

	/*
	guys = [];

	guys["civ01"] = civ01;
	guys["civ02"] = civ02;


*/
	node_01 thread anim_first_frame_solo(civ01, "scientist_run_01");
	node_02 thread anim_first_frame_solo(civ02, "scientist_run_02");



	node_01 thread anim_single_solo(civ01, "scientist_run_01");
	node_02 anim_single_solo(civ02, "scientist_run_02");
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

close_hub_door( civ_07 )
{
	thread maps\nx_lunar_util::close_lunar_door( "control_door_1");
	thread maps\nx_lunar_util::close_lunar_door( "control_door_2");
}

hub_room_explosion ( civ_07 )
{
	node = GetEnt ("hub_room_explosion_source", "targetname");
	node playsound("lunar_explosions_scientist_explo");
	playFX( level._effect[ "hub_room_explosion" ], node.origin, ( 0, -1, 0 ) );
	Earthquake( 1.0, 1.5, level._player.origin, 100 );
	level._player PlayRumbleOnEntity( "damage_light" );

}

cnc_enemy_shoots_civ_01 ( civ_01 )
{
	level notify ("first_shot");
	// iprintln ("first_shot");
}

cnc_enemy_shoots_civ_02 ( civ_02 )
{
	level notify ("second_shot");
	// iprintln ("second_shot");
}

cnc_enemy_shoots_civ_03 ( civ_03 )
{
	level notify ("sixth_shot");
	// iprintln ("sixth_shot");
}

cnc_enemy_shoots_civ_04 ( civ_04 )
{
	level notify ("fifth_shot");
	// iprintln ("fifth_shot");
}

cnc_enemy_shoots_civ_05 ( civ_05 )
{
	level notify ("third_shot");
	// iprintln ("third_shot");
}

cnc_enemy_shoots_civ_06 ( civ_06 )
{
	level notify ("fourth_shot");
	// iprintln ("fourth_shot");
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_falcon_taser_handoff( falcon )
{

	node = getstruct("vignette_falcon_taser_handoff", "script_noteworthy");

	node anim_reach_and_approach_solo( falcon, "falcon_taser_handoff");
	node thread anim_first_frame_solo( falcon, "falcon_taser_handoff");
}

taser_release ( falcon )
{
	level notify ("taser_release");
}

/* Removed, replaced with two AI guys.
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_falcon_taser_spawn()
{
	// falcon = vignette_actor_spawn("falcon_taser_falcon", "falcon");
	// opfor = vignette_actor_spawn("falcon_taser_opfor", "opfor");

	vignette_falcon_taser(level.falcon_taser, level.taser_enemy);


	// falcon vignette_actor_delete();
	// opfor vignette_actor_delete();
}

vignette_falcon_taser(falcon, opfor)
{

	node = getstruct("vignette_falcon_taser", "script_noteworthy");

	guys = [];
	// guys["falcon"] = falcon;
	guys["opfor"] = opfor;

	// node thread anim_single(guys, "falcon_taser", undefined);
	// Time = GetAnimLength( level._scr_anim[ "falcon" ][ "falcon_taser" ] );
	// wait (Time -5);
	// falcon StopAnimScripted();
	// issue_color_orders( "b2", "allies" );
	// Remove the clip brush from the end of the hallway
	blocker = GetEnt ("taser_hallway_end_player_blocker", "targetname");
	blocker delete();
	wait 5;
	// opfor vignette_actor_kill();
}

*/

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

scientist_dead1_spawn()
{
	vignette_scientist_dead1 = vignette_actor_spawn( "vignette_scientist_dead1", "vignette_scientist_dead1" ); //"value" (kvp), "anim_name"
	level.scientist_dead = vignette_scientist_dead1; 

	scientist_dead1( vignette_scientist_dead1 );

	vignette_scientist_dead1 vignette_actor_kill();
}

scientist_dead1(vignette_scientist_dead1)
{
	node = getstruct("vignette_scientist_dead1", "script_noteworthy");
	
	// Scientist can be killed by player
	vignette_scientist_dead1 stop_magic_bullet_shield();
	vignette_scientist_dead1.allowdeath = true;
	vignette_scientist_dead1.heath = 1;
	vignette_scientist_dead1 OverrideMoonFx( 1 );

	guys = [];
	guys["vignette_scientist_dead1"] = vignette_scientist_dead1;

	node anim_single(guys, "scientist_dead1");
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


armory_entrance_falcon_spawn()
{
	//falcon = vignette_actor_spawn("armory_breach_falcon", "falcon"); //"value" (kvp), "anim_name"

	armory_entrance_falcon( level.falcon_taser );

	//falcon vignette_actor_delete();
}

armory_entrance_falcon( falcon )
{
	level endon ("player_in_armory");

	if ( isdefined ( falcon ))
	{
		node = getent("vignette_armory_breach_entrance", "script_noteworthy");
		falcon disable_ai_color();
	
		node anim_reach_and_approach_solo( falcon, "armory_entrance_falcon");
		node anim_single_solo ( falcon, "armory_entrance_falcon");
		falcon enable_ai_color();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

armory_entrance_spider_spawn()
{
	//spider = vignette_actor_spawn("armory_breach_spider", "spider"); //"value" (kvp), "anim_name"

	armory_entrance_spider( level.spider );

	//spider vignette_actor_delete();
}

armory_entrance_spider( spider )
{
	node = getent("vignette_armory_breach_entrance", "script_noteworthy");

	// guys = [];
	// guys["spider"] = spider;

	node thread anim_loop_solo (spider, "armory_entrance_spider", "stop_idle");

	// Spider should have his loop stopped by a notify when he's set to loop at the beginning of the breach sequence as well. This is here for safety.
	flag_wait( "vignette_armory_entrance_player" );

	if ( isAlive (level.spider))
	{
		node notify ("stop_idle");
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

armory_entrance_player_spawn()
{
	// eagle = vignette_actor_spawn("armory_breach_eagle", "eagle"); //"value" (kvp), "anim_name"

	armory_entrance_player( level.eagle);

	// eagle vignette_actor_delete();
}

armory_entrance_player(eagle)
{

	// Stop Eagle from looking at the player
	level.eagle StopLookAt( 20 );

	// Spawn the props and set them to first frame before the player arrives
	node = getent("vignette_armory_breach", "script_noteworthy");
	node anim_teleport_solo( level.eagle, "armory_entrance_player");
	node anim_first_frame_solo( level.eagle, "armory_entrance_player");

	cabinet_door = spawn_anim_model("cabinet_door");

	helmet = spawn_anim_model("helmet");

	node thread anim_first_frame_solo(cabinet_door, "armory_entrance_player");
	node thread anim_first_frame_solo(helmet, "armory_entrance_player");

	// Wait for the player to trigger the scene
	flag_wait ("vignette_armory_entrance_player");
	level notify ("player_in_armory");

	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player disableweapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["cabinet_door"] = cabinet_door;
	guys["helmet"] = helmet;
	guys["eagle"] = eagle;
	guys["player_rig"] = player_rig;

	level._player playerLinkToBlend( player_rig, "tag_player", 0.75 );

	node anim_single(guys, "armory_entrance_player");

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player enableweapons();

	// cabinet_door delete();
}

hide_helmet( helmet )
{
	helmet delete();
	level notify ("armory_helmet_on");	

	// transition to a different vision set for the helmet being on.
	thread maps\nx_lunar_fx::fx_armory_entry_helmet_on_vision_change();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

armory_entrance_grabrifle( rifle )
{

	//level._player allowprone( false );
	//level._player allowcrouch( false );
	//level._player disableweapons();

	node_grabrifle =  getent( "vignette_armory_grabrifle", "script_noteworthy" );

	player_rig = spawn_anim_model( "player_rig" );

	node_grabrifle anim_first_frame_solo( player_rig, "armory_entrance_grabrifle" );

	//Lock the player to the tag_player node of the anim
	//arc = 0;
	//level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, true );
	level._player PlayerLinkToBlend( player_rig, "tag_player", .5, .25, .25 );
	rifle LinkTo( player_rig, "tag_weapon", (0,0,0), (0,0,0) );	
	//rifle LinkTo( player_rig, "j_gun", (0,0,0), (0,0,0) );	
	node_grabrifle anim_single_solo( player_rig, "armory_entrance_grabrifle" );
	level._player unlink();
	//level._player allowprone( true );
	//level._player allowcrouch( true );
	rifle delete();
	player_rig delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
armory_breach_loop_spawn()
{
	eagle = vignette_actor_spawn("armory_breach_eagle", "eagle"); //"value" (kvp), "anim_name"
	spider = vignette_actor_spawn("armory_breach_spider", "spider"); //"value" (kvp), "anim_name"
	falcon = vignette_actor_spawn("armory_breach_falcon", "falcon"); //"value" (kvp), "anim_name"

	armory_breach_loop( eagle, spider, falcon );

	eagle vignette_actor_delete();
	spider vignette_actor_delete();
	falcon vignette_actor_delete();
}

armory_breach_loop( eagle, spider, falcon )
{

	node = getstruct("vignette_armory_breach", "script_noteworthy");

	guys = [];
	guys["eagle"] = eagle;
	guys["spider"] = spider;
	guys["falcon"] = falcon;

	node anim_loop(guys, "armory_breach_loop");

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

armory_breach_spawn()
{
	eagle = vignette_actor_spawn("armory_breach_eagle", "eagle"); //"value" (kvp), "anim_name"
	falcon = vignette_actor_spawn("armory_breach_falcon", "falcon"); //"value" (kvp), "anim_name"
	spider = vignette_actor_spawn("armory_breach_spider", "spider"); //"value" (kvp), "anim_name"

	armory_breach( eagle, falcon, spider );

	eagle vignette_actor_delete();
	falcon vignette_actor_delete();
	spider vignette_actor_delete();
}

armory_breach_create_props()
{
	node = getent("vignette_armory_breach", "script_noteworthy");

	// spawn all the anim models for the shelves and actor cover
	falcon_crate = spawn_anim_model("falcon_crate");
	spider_crate = spawn_anim_model("spider_crate");
	crate_01 = spawn_anim_model("crate_01");
	crate_02 = spawn_anim_model("crate_02");
	crate_03 = spawn_anim_model("crate_03");
	crate_04 = spawn_anim_model("crate_04");
	crate_05 = spawn_anim_model("crate_05");
	crate_06 = spawn_anim_model("crate_06");
	crate_07 = spawn_anim_model("crate_07");
	crate_08 = spawn_anim_model("crate_08");
	crate_09 = spawn_anim_model("crate_09");
	crate_10 = spawn_anim_model("crate_10");
	crate_11 = spawn_anim_model("crate_11");
	crate_12 = spawn_anim_model("crate_12");
	crate_13 = spawn_anim_model("crate_13");
	crate_14 = spawn_anim_model("crate_14");
	crate_15 = spawn_anim_model("crate_15");
	crate_16 = spawn_anim_model("crate_16");
	crate_17 = spawn_anim_model("crate_17");
	crate_18 = spawn_anim_model("crate_18");
	crate_19 = spawn_anim_model("crate_19");
	crate_20 = spawn_anim_model("crate_20");
	crate_21 = spawn_anim_model("crate_21");
	crate_22 = spawn_anim_model("crate_22");
	crate_23 = spawn_anim_model("crate_23");
	crate_24 = spawn_anim_model("crate_24");
	crate_25 = spawn_anim_model("crate_25");
	crate_26 = spawn_anim_model("crate_26");
	crate_27 = spawn_anim_model("crate_27");
	crate_28 = spawn_anim_model("crate_28");
	crate_29 = spawn_anim_model("crate_29");
	crate_30 = spawn_anim_model("crate_30");
	crate_31 = spawn_anim_model("crate_31");
	crate_32 = spawn_anim_model("crate_32");
	crate_33 = spawn_anim_model("crate_33");
	crate_34 = spawn_anim_model("crate_34");
	crate_35 = spawn_anim_model("crate_35");
	crate_36 = spawn_anim_model("crate_36");
	crate_37 = spawn_anim_model("crate_37");
	crate_38 = spawn_anim_model("crate_38");
	cabinet_01 = spawn_anim_model("cabinet_01");
	cabinet_02 = spawn_anim_model("cabinet_02");
	cabinet_03 = spawn_anim_model("cabinet_03");
	cabinet_04 = spawn_anim_model("cabinet_04");
	cabinet_05 = spawn_anim_model("cabinet_05");
	cabinet_06 = spawn_anim_model("cabinet_06");
	cabinet_07 = spawn_anim_model("cabinet_07");
	cabinet_08 = spawn_anim_model("cabinet_08");
	helmet_01 = spawn_anim_model("helmet_01");
	helmet_02 = spawn_anim_model("helmet_02");

	props = [];
	props["falcon_crate"] = falcon_crate;
	props["spider_crate"] = spider_crate;	
	props["crate_01"] = crate_01;
	props["crate_02"] = crate_02;
	props["crate_03"] = crate_03;
	props["crate_04"] = crate_04;
	props["crate_05"] = crate_05;
	props["crate_06"] = crate_06;
	props["crate_07"] = crate_07;
	props["crate_08"] = crate_08;
	props["crate_09"] = crate_09;
	props["crate_10"] = crate_10;
	props["crate_11"] = crate_11;
	props["crate_12"] = crate_12;
	props["crate_13"] = crate_13;
	props["crate_14"] = crate_14;
	props["crate_15"] = crate_15;
	props["crate_16"] = crate_16;
	props["crate_17"] = crate_17;
	props["crate_18"] = crate_18;
	props["crate_19"] = crate_19;
	props["crate_20"] = crate_20;
	props["crate_21"] = crate_21;
	props["crate_22"] = crate_22;
	props["crate_23"] = crate_23;
	props["crate_24"] = crate_24;
	props["crate_25"] = crate_25;
	props["crate_26"] = crate_26;
	props["crate_27"] = crate_27;
	props["crate_28"] = crate_28;
	props["crate_29"] = crate_29;
	props["crate_30"] = crate_30;
	props["crate_31"] = crate_31;
	props["crate_32"] = crate_32;
	props["crate_33"] = crate_33;
	props["crate_34"] = crate_34;
	props["crate_35"] = crate_35;
	props["crate_36"] = crate_36;
	props["crate_37"] = crate_37;
	props["crate_38"] = crate_38;
	props["cabinet_01"] = cabinet_01;
	props["cabinet_02"] = cabinet_02;
	props["cabinet_03"] = cabinet_03;
	props["cabinet_04"] = cabinet_04;
	props["cabinet_05"] = cabinet_05;
	props["cabinet_06"] = cabinet_06;
	props["cabinet_07"] = cabinet_07;
	props["cabinet_08"] = cabinet_08;
	props["helmet_01"] = helmet_01;
	props["helmet_02"] = helmet_02;

	// Save the props array
	level.props = props;
	node anim_first_frame( props, "armory_breach_explosion" );
}

armory_breach( eagle, falcon, spider )
{
	// Stop Spider's idle loop
	node = getent("vignette_armory_breach_entrance", "script_noteworthy");
	node notify ("stop_idle");

	node = getent("vignette_armory_breach", "script_noteworthy");


	if( !IsDefined( level.props ) )
	{
		armory_breach_create_props();
	}

	guys = [];
	guys["eagle"] = eagle;
	guys["falcon"] = falcon;
	guys["spider"] = spider;

	node thread anim_single( level.props, "armory_breach_explosion" );
	thread maps\nx_lunar_fx::fx_armory_breach_vision_change(); // cue the vision set change.
	node anim_single( guys, "armory_breach_explosion" );
}

// deletes props flying out of airlock.
prop_delete( prop )
{
	prop delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


falcon_death_spawn()
{
//  vignette_falcon = vignette_actor_spawn( "vignette_falcon", "vignette_falcon" ); //"value" (kvp), "anim_name"
//  vignette_eagle = vignette_actor_spawn( "vignette_eagle", "vignette_eagle" ); //"value" (kvp), "anim_name"

	// tagDK<note>Clean up all enemies in prep for this vignette
	maps\nx_lunar_util::clean_all_enemies();

	wait( 0.05 );

	level.battle_rover = vignette_vehicle_spawn( "battle_rover", "rover" ); //"value" (kvp), "anim_name"

	vignette_falcondeath_opfor1 = vignette_actor_spawn("vignette_falcondeath_opfor1", "vignette_falcondeath_opfor1"); //"value" (kvp), "anim_name"

	level.battle_rover.main_turret = level.battle_rover.mgturret[0];

	level.battle_rover.main_turret TurretFireDisable();

	level.battle_rover maps\_vehicle::vehicle_lights_on( "running" );
 
	blood_origin = spawn_anim_model("blood_origin");
 
	falcon_death( level.battle_rover, level.falcon, level.eagle, blood_origin, vignette_falcondeath_opfor1 );

//  rover vignette_vehicle_delete();
//  vignette_falcon vignette_actor_delete();
//  vignette_eagle vignette_actor_delete();
}

falcon_death( rover, vignette_falcon, vignette_eagle, blood_origin, vignette_falcondeath_opfor1 )
{
	node = getstruct( "vignette_falcon_death", "script_noteworthy" );

	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player EnableInvulnerability();

	player_rig = spawn_anim_model( "player_rig" );

	thread falcon_death_fx( rover, vignette_falcon, blood_origin, vignette_eagle, player_rig );

	wait 0.58;

	guys = [];
	guys["rover"] = rover;
	guys["falcon"] = vignette_falcon;
	guys["eagle"] = vignette_eagle;
	guys["vignette_falcondeath_opfor1"] = vignette_falcondeath_opfor1;
	guys["player_rig"] = player_rig;
	guys["blood_origin"] = blood_origin;

	arc = 15;

	level._player PlayerLinkToBlend( player_rig, "tag_player", 0.25 );
	level.battle_rover maps\_vehicle::suspend_drive_anims_for_vignette();

	node anim_single( guys, "falcon_death" );

	level.falcon stop_magic_bullet_shield();
	vignette_falcondeath_opfor1 stop_magic_bullet_shield();

	// Kill for clean up
	level.falcon kill();
	vignette_falcondeath_opfor1 kill();

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player enableweapons();
	level._player DisableInvulnerability();

	level.battle_rover DisconnectPaths();

	flag_set( "rover_battle_start" );
}

falcon_injured( falcon )
{
	falcon_injured = GetEnt( "falcon_injured_spawner", "targetname" ) spawn_ai();

	if( IsDefined( falcon_injured ) )
	{
		falcon SetModel( falcon_injured.model );
		falcon Detach( falcon.headmodel );
		falcon.headmodel =  falcon_injured.headmodel;
		falcon Attach( falcon.headmodel );
	}

	falcon_injured Delete();

}

falcon_death_fx( rover, falcon, falcon_blood, eagle, player, vignette_falcondeath_opfor1 )
{
	// Pre Shoot setup
	muzzlePos = GetEnt( "rover_pre_battle_shot", "targetname" );
	targetPos = ( 2695, -3000, -1290 );
	magicBullet( "nx_chinese_lgv_turret_magicbullet_dirt_linger", muzzlePos.origin + 0.1*( targetPos - muzzlePos.origin ), targetPos );

	wait 0.53;

	level._player disableweapons();
	Earthquake( 1.0, 1.5, level._player.origin, 100 );
	level._player PlayRumbleOnEntity( "damage_light" );

	// Shoot the cliff.
	wait 4.2;
	muzzlePos = rover.main_turret getTagOrigin( "tag_flash" );
	targetPos = ( 2695, -3000, -1290 );
	magicBullet( "nx_chinese_lgv_turret_magicbullet_dirt", muzzlePos + 0.1*(targetPos - muzzlePos), targetPos );
	playFXOnTag( level._effect[ "nx_chinese_lgv_turret_wv" ], rover.main_turret, "tag_flash" );

	wait 0.55;
	level._player PlayRumbleOnEntity( "damage_light" );

	wait 1.0;
	muzzlePos = rover.main_turret getTagOrigin( "tag_flash" );
	magicBullet( "nx_chinese_lgv_turret_magicbullet_dirt", muzzlePos, ( 2650, -3100, -1290 ) );
	playFXOnTag( level._effect[ "nx_chinese_lgv_turret_wv" ], rover.main_turret, "tag_flash" );

	wait 0.5;
	level._player PlayRumbleOnEntity( "damage_light" );

	wait 0.5;
	muzzlePos = rover.main_turret getTagOrigin( "tag_flash" );
	magicBullet( "nx_chinese_lgv_turret_magicbullet_dirt", muzzlePos, ( 2700, -3100, -1290 ) );
	playFXOnTag( level._effect[ "nx_chinese_lgv_turret_wv" ], rover.main_turret, "tag_flash" );

	wait 0.5;
	level._player PlayRumbleOnEntity( "heavy_3s" );

	wait 1.8;
	level._player PlayRumbleOnEntity( "damage_light" );

	// Player hand dust.
	wait 0.3;
	dustPos = player getTagOrigin( "J_Wrist_RI" );
	playFX( level._effect[ "nx_lunar_falcon_death_dust_small" ], dustPos );

	// Stray shot.
	wait 0.9;
	muzzlePos = rover.main_turret getTagOrigin( "tag_flash" );
	falconPos = falcon getTagOrigin( "J_Spine4" );
	magicBullet( "nx_chinese_lgv_turret_magicbullet_dirt", muzzlePos, falconPos + ( 24, 24, 24 ) );
	playFXOnTag( level._effect[ "nx_chinese_lgv_turret_wv" ], rover.main_turret, "tag_flash" );

	// Player hand dust.
	dustPos = player getTagOrigin( "J_Wrist_LE" );
	playFX( level._effect[ "nx_lunar_falcon_death_dust_small" ], dustPos + ( 24, 0, -24 ) );

	// Falcon land.
	wait 0.8;
	dustPos = falcon getTagOrigin( "J_Ball_LE" );
	playFX( level._effect[ "nx_lunar_falcon_death_dust_small" ], dustPos );

	wait 0.2;
	dustPos = falcon getTagOrigin( "J_Ball_RI" );
	playFX( level._effect[ "nx_lunar_falcon_death_dust_small" ], dustPos );

	// Hit (near) solar panel.
	wait 0.4;
	muzzlePos = rover.main_turret getTagOrigin( "tag_flash" );
	magicBullet( "nx_chinese_lgv_turret_magicbullet_dirt", muzzlePos, ( 3250, -2800, -1520 ) );
	playFXOnTag( level._effect[ "nx_chinese_lgv_turret_wv" ], rover.main_turret, "tag_flash" );

	// Stray shots.
	wait 0.5;
	muzzlePos = rover.main_turret getTagOrigin( "tag_flash" );
	falconPos = falcon getTagOrigin( "J_Spine4" );
	magicBullet( "nx_chinese_lgv_turret_magicbullet_dirt", muzzlePos, falconPos + ( 24, 12, 32 ) );
	playFXOnTag( level._effect[ "nx_chinese_lgv_turret_wv" ], rover.main_turret, "tag_flash" );

	wait 1.0;
	muzzlePos = rover.main_turret getTagOrigin( "tag_flash" );
	falconPos = falcon getTagOrigin( "J_Spine4" );
	magicBullet( "nx_chinese_lgv_turret_magicbullet_dirt", muzzlePos, falconPos + ( -64, 12, 48 ) );
	playFXOnTag( level._effect[ "nx_chinese_lgv_turret_wv" ], rover.main_turret, "tag_flash" );

	// Hit Falcon.
	wait 1.0;
	muzzlePos = rover.main_turret getTagOrigin( "tag_flash" );
	bloodPos = falcon_blood getTagOrigin( "tag_origin" );
	magicBullet( "nx_chinese_lgv_turret_magicbullet_flesh", muzzlePos, bloodPos );
	playFXOnTag( level._effect[ "nx_chinese_lgv_turret_wv" ], rover.main_turret, "tag_flash" );

	wait 0.3;
	playFXOnTag( level._effect[ "nx_lunar_falcon_death_blood_exit" ], falcon_blood, "tag_origin" );
	playFXOnTag( level._effect[ "nx_lunar_falcon_death_glass_hit" ], falcon, "tag_eye" );

	wait 0.2;
	playFXOnTag( level._effect[ "nx_lunar_falcon_death_blood_squirt" ], falcon_blood, "tag_origin" );

	// Eagle to the rescue.
	// Stray shot.
	wait 0.3;
	muzzlePos = rover.main_turret getTagOrigin( "tag_flash" );
	eaglePos = eagle getTagOrigin( "J_Spine4" );
	magicBullet( "nx_chinese_lgv_turret_magicbullet_dirt", muzzlePos, eaglePos + ( -24, -24, 16 ) );
	playFXOnTag( level._effect[ "nx_chinese_lgv_turret_wv" ], rover.main_turret, "tag_flash" );

	// Cliff shots.
	wait 0.25;
	muzzlePos = rover.main_turret getTagOrigin( "tag_flash" );
	magicBullet( "nx_chinese_lgv_turret_magicbullet_big_dirt", muzzlePos, ( 2770, -2876, -1334 ) );
	playFXOnTag( level._effect[ "nx_chinese_lgv_turret_wv" ], rover.main_turret, "tag_flash" );

	wait 0.45;
	muzzlePos = rover.main_turret getTagOrigin( "tag_flash" );
	magicBullet( "nx_chinese_lgv_turret_magicbullet_big_dirt", muzzlePos, ( 2773, -3023, -1320 ) );
	playFXOnTag( level._effect[ "nx_chinese_lgv_turret_wv" ], rover.main_turret, "tag_flash" );

	wait 1.0;
	dustPos = eagle getTagOrigin( "J_Ball_LE" );
	playFX( level._effect[ "nx_lunar_falcon_death_dust" ], dustPos );

	dustPos = eagle getTagOrigin( "J_Ball_RI" );
	playFX( level._effect[ "nx_lunar_falcon_death_dust" ], dustPos );

	stopFXOnTag( level._effect[ "nx_lunar_falcon_death_blood_squirt"], falcon_blood, "tag_origin" );

	// Stray shots.
	wait 0.3;
	muzzlePos = rover.main_turret getTagOrigin( "tag_flash" );
	eaglePos = eagle getTagOrigin( "J_Spine4" );
	magicBullet( "nx_chinese_lgv_turret_magicbullet_dirt", muzzlePos, eaglePos + ( -24, -24, 16 ) );
	playFXOnTag( level._effect[ "nx_chinese_lgv_turret_wv" ], rover.main_turret, "tag_flash" );

	wait 3.5;
	muzzlePos = rover.main_turret getTagOrigin( "tag_flash" );
	eaglePos = eagle getTagOrigin( "J_Spine4" );
	magicBullet( "nx_chinese_lgv_turret_magicbullet_dirt", muzzlePos, eaglePos + ( -128, -48, 64 ) );
	playFXOnTag( level._effect[ "nx_chinese_lgv_turret_wv" ], rover.main_turret, "tag_flash" );
}

shellshock_start( player_rig )
{
	level._player shellshock( "lunar_rover_battle", 5 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

end_greet_spawn()
{
	end_greet_body = vignette_actor_spawn("end_greet_body", "end_greet_body"); //"value" (kvp), "anim_name"
	end_greet_hawk = vignette_actor_spawn("end_greet_hawk", "end_greet_hawk"); //"value" (kvp), "anim_name"
	end_greet_ally1 = vignette_actor_spawn("end_greet_ally1", "end_greet_ally1"); //"value" (kvp), "anim_name"

	end_greet(end_greet_body, end_greet_hawk, end_greet_ally1);

	end_greet_body vignette_actor_delete();
	end_greet_hawk vignette_actor_delete();
	end_greet_ally1 vignette_actor_delete();
}

end_greet( end_greet_body, end_greet_hawk, end_greet_ally1 )
{
	node = getstruct("vignette_lunar_end_greet", "script_noteworthy");
	end_greet_detonator = spawn_anim_model("end_greet_detonator");

	guys = [];
	guys[ end_greet_body.animname ] = end_greet_body;
	guys[ end_greet_hawk.animname ] = end_greet_hawk;
	guys[ end_greet_ally1.animname ] = end_greet_ally1;
	guys[ "end_greet_detonator" ] = end_greet_detonator;

	node thread anim_first_frame_solo( end_greet_body, "end_greet" );
	node thread anim_first_frame_solo( end_greet_detonator, "end_greet" );

	flag_wait( "vignette_end_greet" );

	node anim_single(guys, "end_greet");

	end_greet_detonator delete();	
}

vignette_remove_gun( guy )
{
	guy gun_remove();
}
vignette_stow_gun( guy )
{
	guy gun_remove();
	guy place_weapon_on( "lunarrifle", "back" );
}
vignette_use_breacher( guy )
{
	guy forceUseWeapon( "breacher", "primary" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
end_controls_spawn()
{
	enemy_body = vignette_actor_spawn("end_controls_enemy_body", "enemy_body"); //"value" (kvp), "anim_name"
	hawk = vignette_actor_spawn("end_controls_hawk", "hawk"); //"value" (kvp), "anim_name"
	crow = vignette_actor_spawn("end_controls_crow", "crow"); //"value" (kvp), "anim_name"

	end_controls(enemy_body, hawk, crow);

	enemy_body vignette_actor_delete();
	hawk vignette_actor_delete();
	crow vignette_actor_delete();
}

end_controls_enemy_first_frame( enemy_body )
{
	node = getstruct("vignette_lunar_end_controls", "script_noteworthy");

	node thread anim_first_frame_solo( enemy_body, "end_controls" );
}

end_controls_enemy_kill( enemy_body )
{
	node = getstruct( "vignette_lunar_end_controls", "script_noteworthy" );

	node thread anim_first_frame_solo( enemy_body, "end_controls_enemy_die" );

	flag_wait( "c_and_c_doors_open" );

	// Kill enemy
	node anim_single_solo( enemy_body, "end_controls_enemy_die" );

	node thread anim_first_frame_solo( enemy_body, "end_controls" );
}

// tagJEG<note> - It works better to run hawk and crow on separate threads so that one doesn't wait for the other animreach
/*
end_controls_enter( hawk, crow )
{
	// tagTC<hack> - temp animname set till we clear up animname descripencies
	hawk.animname = "hawk";
	crow.animname = "crow";

	node = getstruct("vignette_lunar_end_controls", "script_noteworthy");

	guys = [];
	guys["hawk"] = hawk;
	guys["crow"] = crow;

	node anim_reach( guys, "end_controls_enter" );
	node anim_single( guys, "end_controls_enter" );

	// Start their idle
	end_controls_idle( hawk, crow );
}

end_controls_idle( hawk, crow )
{
	node = getstruct("vignette_lunar_end_controls", "script_noteworthy");

	guys = [];
	guys["hawk"] = hawk;
	guys["crow"] = crow;

	node thread anim_loop( guys, "end_controls_loop", "stop_idle");

	flag_wait( "control_lsp_activated" );
	node notify ("stop_idle");
}
*/
end_controls_enter( hawk, crow )
{
	thread end_controls_enter_h( hawk );
	end_controls_enter_c( crow );
}

end_controls_enter_h( hawk )
{
	// tagTC<hack> - temp animname set till we clear up animname descripencies
	hawk.animname = "hawk";
	node = getstruct("vignette_lunar_end_controls", "script_noteworthy");
	node anim_reach_solo( hawk, "end_controls_enter" );
	node anim_single_solo( hawk, "end_controls_enter" );
	node thread anim_loop_solo( hawk, "end_controls_loop", "stop_idle");

	flag_wait( "control_lsp_activated" );
	node notify ("stop_idle");
	
}

end_controls_enter_c( crow )
{
	// tagTC<hack> - temp animname set till we clear up animname descripencies
	crow.animname = "crow";
	node = getstruct("vignette_lunar_end_controls", "script_noteworthy");
	node anim_reach_solo( crow, "end_controls_enter" );
	node anim_single_solo( crow, "end_controls_enter" );
	node thread anim_loop_solo( crow, "end_controls_loop", "stop_idle");

	flag_wait( "control_lsp_activated" );
	node notify ("stop_idle");
}

end_controls( enemy_body, hawk, crow, end_controls_panel )
{
	// tagTC<hack> - temp animname set till we clear up animname descripencies
	hawk.animname = "hawk";
	crow.animname = "crow";

	node = getstruct("vignette_lunar_end_controls", "script_noteworthy");

	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player disableweapons();
	level._player takeallweapons();

	player_rig = spawn_anim_model( "player_rig" );
	//end_controls_panel = spawn_anim_model("end_controls_panel");

	guys = [];
	guys["enemy_body"] = enemy_body;
	guys["player_rig"] = player_rig;
	guys["hawk"] = hawk;
	guys["crow"] = crow;
	guys["end_controls_panel"] = end_controls_panel;

	//arc = 15;

	//level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);
	level._player playerLinkToBlend( player_rig, "tag_player", 0.75 );
	node anim_single(guys, "end_controls");

	//level._player unlink();

	//player_rig delete();

	//level._player FreezeControls( false );
	//level._player allowprone( true );
	//level._player allowcrouch( true );

}

end_controls_fade_out( guy )
{
	black_overlay = create_client_overlay( "black", 0, level._player );
	black_overlay FadeOverTime( 1.75 );
	black_overlay.alpha = 1;
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "generic_human" );
charlie_anims()
{
    //rover intro - charlie
    level._scr_anim[ "charlie" ][ "rover_intro_drive" ] = %nx_tp_lunar_rover_intro_drive_charlie;
    level._scr_anim[ "charlie" ][ "rover_intro_idle" ] = %nx_tp_lunar_rover_intro_idle_charlie;
    level._scr_anim[ "charlie" ][ "rover_intro_jump" ] = %nx_tp_lunar_rover_intro_jump_charlie;

	// death - charlie
	level._scr_anim[ "charlie" ][ "nx_tp_lunar_charlie_death" ] = %nx_tp_lunar_charlie_death;
	addNotetrack_customFunction( "charlie", "bullet_hit", ::charlie_death );
	addNotetrack_customFunction( "charlie", "rover_jolt", ::rover_jolt );
}


#using_animtree( "vehicles" );
vehicle_anims()
{
	level._scr_anim[ "rover" ][ "rover_crash" ]   = %nx_vh_lunar_rovercrash_player;
	level._scr_anim[ "rover" ][ "rover_intro_drive" ]   = %nx_vh_lunar_rover_intro_drive_rover;
	level._scr_anim[ "rover" ][ "rover_intro_jump" ]   = %nx_vh_lunar_rover_intro_jump_rover;
	level._scr_anim[ "rover" ][ "falcon_death" ] = %nx_vh_lunar_falcon_death_rover;

	level._scr_animtree[ "rover" ] 							= #animtree;
}

charlie_death( charlie )
{
	level notify("charlie_hit");
}

rover_jolt( charlie )
{
	rover_charlie = get_vehicle("rover_charlie_spawner", "targetname");
	rover_charlie JoltBody( (rover_charlie.origin + (0,0,-64)), 10 );
}

//Using animknobs we can add animations without affecting the vehicle on the path.
#using_animtree( "vehicles" );
rover_intro_drive_anim()
{
	self useanimtree( #animtree );
	self setanimKnob( %nx_vh_lunar_rover_intro_drive_rover, 1, 0, 1 );
}
#using_animtree( "vehicles" );
rover_intro_jump_anim()
{
	self useanimtree( #animtree );
	self setanimKnob( %nx_vh_lunar_rover_intro_jump_rover, 1, 0, 1 ); 
}

helmet_overlay( player_rig )
{
	// Dan:  Switching this function to use code-side helmet on/off system.
	level._player maps\_moon::set_suit_hud_type("military");
	level._player PutOnHelmet();

	//black_overlay = create_client_overlay( "black", 0, level._player );
	//black_overlay FadeOverTime( .1 );
	//black_overlay.alpha = 1;
	//wait ( .5 );
	//level._player maps\_moon::set_suit_hud_type("civilian");
	//black_overlay FadeOverTime( .1 );
	//black_overlay.alpha = 0;
}

helmet_overlay_taking_off( player_rig )
{
	// Dan:  Switching this function to use code-side helmet on/off system.
	level._player TakeOffHelmet();

	//black_overlay = create_client_overlay( "black", 0, level._player );
	//black_overlay FadeOverTime( .1 );
	//black_overlay.alpha = 1;
	//wait ( .5 );
	////level._player maps\_moon::set_suit_hud_type("military");
	//black_overlay FadeOverTime( .1 );
	//black_overlay.alpha = 0;
}

start_vh_bay_breach( player_rig )
{
	level notify ("start_vh_bay_breach");
}

close_airlock_door( player_rig )
{
	level notify ("keypad_cycle");
	wait 1;
	level thread maps\nx_lunar_util::close_lunar_door( "vehicle_airlock_breach_01", 1.0 );
	level thread maps\nx_lunar_util::lunar_door_status( "vehicle_airlock_breach_01", "status_yellow" );
	level thread maps\nx_lunar_util::lunar_door_status( "vehicle_airlock_door_02", "status_yellow" );
	level notify ("stop_player_visor_glass_cracking");
}


break_visor( player_rig )
{
	level notify("break_visor");
}

slowmotion_start( player_rig )
{
	target_speed = 0.25;
	lerp_time = 0.05;

	slowmo_start();
	slowmo_setspeed_slow( target_speed );
	slowmo_setlerptime_in( lerp_time );
	slowmo_lerp_in();

}

slowmotion_stop( player_rig )
{
	lerp_time = 0.75;

	slowmo_setlerptime_out( lerp_time );
	slowmo_lerp_out();
	slowmo_end();	
}

ally_door_keypad_cycle ( eagle )
{
	level notify ("keypad_cycle");
	// iprintln ("Cycling!");
}

wakeup_ally_shot ( ally_02 )
{
	level notify ("wakeup_ally_shot");
}












