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

#include common_scripts\utility;
#include common_scripts\_nx_fx;
#include maps\_utility;
#include maps\_anim;
#include maps\_nx_vignette_util;
#include maps\_vehicle;

main() 
{
	level.vignette_models = [];

	generic_human();
	player();
	script_models();
	level thread vignettes();
	dialogue();
	vehicles();

	// tagMJS<NOTE> needed for turret viewmodel hands
	maps\_minigun_viewmodel::anim_minigun_hands();
	thread maps\nx_rocket_fx::ocean_anim();
}

vignettes()
{
//  level thread vignette_register( ::aa_control_melee_spawn, "vignette_aa_control_melee_flag" );
//  level thread vignette_register( ::aa_exit_melee_spawn, "vignette_aa_control_exit_flag" );
//  level thread vignette_register( ::aa_exitdoors_spawn, "vignette_rocket_aa_exitdoors_flag" );
	level thread vignette_register( ::aa_gantry_escape_spawn, "vignette_rocket_gantry_escape_flag" );
//  level thread vignette_register( ::crash_site_wakeup_allyshot_spawn, "vignette_crash_site_wakeup_allyshot_flag" );
//  level thread vignette_register( ::crash_site_wakeup_allydive_spawn, "vignette_crash_site_wakeup_allydive_flag" );
//  level thread vignette_register( ::crash_site_wakeup_allyshotb_spawn, "vignette_crash_site_wakeup_allyshotb_flag" );
//  level thread vignette_register( ::crash_site_wakeup_spawn, "vignette_crash_site_wakeup_allyshot_flag" );
//  level thread vignette_register( ::crash_site_wakeup_cutdown_spawn, "vignette_crash_site_wakeup_cutdown_flag" );
//  level thread vignette_register( ::helicopter_crash_rocket_spawn, "vignette_rocket_helicoper_crash_flag" );
//  level thread vignette_register( ::witness_nuke_spawn, "vignette_witness_nuke_flag" );
//  level thread vignette_register( ::nuke_and_crash_spawn, "vignette_nuke_crash" );
	level thread vignette_register( ::jump_onto_gantry_spawn, "vignette_jump_onto_gantry_flag" );
//  level thread vignette_register( ::climb_onto_littlebird_spawn, "vignette_climb_onto_littlebird_flag" );
	level thread vignette_register( ::rocket_explosion_02_spawn, "vignette_rocket_explosion_02_flag" );
//  level thread vignette_register( ::aa_corridor_run_out_01_spawn, "vignette_aa_cor_run_out_flag" );
//  level thread vignette_register( ::aa_corridor_run_out_02_spawn, "vignette_aa_corridor_run_02_flag" );
//  level thread vignette_register( ::aa_corridor_wall_01_spawn, "aa_cor_wall_01_flag" );
//  level thread vignette_register( ::woods_mantel_spawn, "vignette_woods_mantel_flag" );
//  level thread vignette_register( ::woods_ledge_01_spawn, "woods_ledge_01_flag" );
//  level thread vignette_register( ::woods_chopper_fly_over_spawn, "vignette_woods_chopper_fly_over_flag" );
//  level thread vignette_register( ::woods_traversal_01_spawn, "vignette_woods_traversal01_flag" );
//  level thread vignette_register( ::woods_traversal_02_spawn, "vignette_woods_traversal02_flag" );
/*	
	level thread vignette_register( ::pipe_traversal_01_spawn, "pipe_traversal_01_flag" );

	level thread vignette_register( ::pipe_traversal_02_spawn, "pipe_traversal_02_flag" );
*/
	
	// opfor helicopter intro
	level thread vignette_register( ::opfor_helicopter_intro_spawn, "opfor_helicopter_intro" );

	// helicopter bridge
	level thread vignette_register( ::helicopter_bridge_spawn, "helicopter_bridge" );

	level thread vignette_register( ::chopper_battle_base_delta_02_spawn, "chopper_battle_base_delta_02_flag" );
	level thread vignette_register( ::chopper_battle_base_delta_01_spawn, "vignette_delta_chopper_fight_flag" );
	level thread vignette_register( ::intro_choppers_spawn, "vignette_rocket_intro_vehicles" );
	level thread vignette_register( ::intro_allies_in_chopper_spawn, "vignette_rocket_intro_vehicles" );

	// Delta Chopper Battle 03
	level thread vignette_register( ::chopper_battle_base_delta_03_spawn, "chopper_battle_delta_03_flag" );

	// Delta Chopper Battle 04
	//level thread vignette_register( ::chopper_battle_base_delta_04_spawn, "chopper_battle_delta_04_flag" );

	// Delta Chopper Battle 05
	//level thread vignette_register( ::chopper_battle_base_delta_05_spawn, "vignette_choppter_battle_5_flag" );

	// Delta dogfight 01
	level thread vignette_register( ::chopper_dogfight_base_delta_01_spawn, "vignette_delta_dogfight_01" );

	// Delta dogfight 02
	level thread vignette_register( ::chopper_dogfight_base_delta_02_spawn, "chopper_dogfight_base_delta_02_flag" );

	//Echo Base AA Shoot Down Helicopter
	level thread vignette_register( ::aa_turret_shoot_helicopter_spawn, "start_aa_shoot_down" );

	//EC_VTOL Breakapart
	//level thread vignette_register( ::ec_vtol_breakapart_spawn, "vtol_breakapart_flag" );
}

#using_animtree("generic_human");
generic_human()
{
	// helicopter bridge
	level._scr_anim[ "pilot" ][ "helicopter_bridge" ] = %nx_tp_rocket_helicopter_bridge_pilot;
	level._scr_anim[ "ally_01" ][ "helicopter_bridge" ] = %nx_tp_rocket_helicopter_bridge_ally;
	level._scr_anim[ "copilot" ][ "helicopter_bridge" ] = %nx_tp_rocket_helicopter_bridge_copilot;
	level._scr_anim[ "ally_gunner" ][ "helicopter_bridge" ] = %nx_tp_rocket_helicopter_bridge_ally_gunner;	
	level._scr_anim[ "ally_02" ][ "helicopter_bridge" ] = %nx_tp_rocket_helicopter_bridge_ally_02;	

	level._scr_anim[ "ally_baker" ][ "helicopter_bridge" ] = %nx_tp_rocket_helicopter_bridge_ally;
	level._scr_anim[ "ally_williams" ][ "helicopter_bridge" ] = %nx_tp_rocket_helicopter_bridge_ally_gunner;
	level._scr_anim[ "ally_jenkins" ][ "helicopter_bridge" ] = %nx_tp_rocket_helicopter_bridge_ally_02;	

	level._scr_anim[ "hanging_ally" ][ "hanging_ally_stumble" ]				= %hunted_dazed_walk_a_zombie;
	level._scr_anim[ "hanging_ally" ][ "hanging_ally_crawl" ]				= %civilian_crawl_1;
	level._scr_anim[ "hanging_ally" ][ "hanging_ally_stumble_death" ]		= %stand_death_tumbleforward;
	level._scr_anim[ "hanging_ally" ][ "hanging_ally_crawl_death" ]			= %crawl_death_front;

	level._scr_anim[ "enemy_opfor" ][ "turret_enemy_turret_idle" ][0]		= %nx_tp_lunar_endbreach_scientist_sit_idle;
	level._scr_anim[ "enemy_opfor" ][ "aa_control_melee" ] 					= %nx_tp_rocket_aa_control_melee_opfor_01;
	level._scr_anim[ "enemy_opfor" ][ "turret_guard_takedown" ] 			= %nx_tp_melee_kill_guard;
	level._scr_anim[ "enemy_opfor" ][ "rescue_enemy_preview_direct" ] 		= %CQB_stand_wave_on_me;

	level._scr_anim[ "ally_williams" ][ "aa_control_melee" ] 				= %nx_tp_rocket_aa_control_melee_williams;
	level._scr_anim[ "ally_williams" ][ "aa_exit_melee" ]					= %nx_tp_rocket_aa_control_exit_williams;
	level._scr_anim[ "ally_jenkins" ][ "aa_exitdoors" ] 					= %nx_tp_rocket_aa_control_exitdoors_williams;

	level._scr_anim[ "ally_williams" ][ "cqb_wave_on_me" ] 					= %CQB_stand_wave_on_me;
	level._scr_anim[ "ally_williams" ][ "cqb_wave_on_me" ] 					= %CQB_stand_wave_on_me;
	level._scr_anim[ "ally_williams" ][ "rocket_reveal_point" ] 			= %killhouse_gaz_point_side;
	level._scr_anim[ "ally_williams" ][ "turret_guard_takedown" ] 			= %nx_tp_melee_kill_ally;

	level._scr_anim[ "ally_jenkins" ][ "hanging_interrogation" ] 			= %nx_tp_rocket_crash_site_wakeup_allyshot_jenkins;
	level._scr_anim[ "hanging_enemy_01" ][ "hanging_interrogation" ]		= %nx_tp_rocket_crash_site_wakeup_allyshot_opfor_01;
	level._scr_anim[ "hanging_enemy_02" ][ "hanging_interrogation" ]		= %nx_tp_rocket_crash_site_wakeup_allyshot_opfor_02;
	level._scr_anim[ "hanging_enemy_03" ][ "hanging_interrogation" ]		= %nx_tp_rocket_crash_site_wakeup_allyshot_opfor_03;

	level._scr_anim[ "ally_jenkins" ][ "hanging_loop" ][0]					= %nx_tp_rocket_crash_site_wakeup_allyshot_jenkins_loop;
	level._scr_anim[ "hanging_enemy_01" ][ "hanging_loop" ][0]				= %nx_tp_rocket_crash_site_wakeup_allyshot_opfor_01_loop;
	level._scr_anim[ "hanging_enemy_02" ][ "hanging_loop" ][0]				= %nx_tp_rocket_crash_site_wakeup_allyshot_opfor_02_loop;
	level._scr_anim[ "hanging_enemy_03" ][ "hanging_loop" ][0]				= %nx_tp_rocket_crash_site_wakeup_allyshot_opfor_03_loop;

	level._scr_anim[ "ally_jenkins" ][ "hanging_struggle" ]  				= %nx_tp_rocket_crash_site_wakeup_allydive_jenkins;
	level._scr_anim[ "ally_jenkins" ][ "hanging_execution" ]   				= %nx_tp_rocket_crash_site_wakeup_allyshotb_jenkins;

	level._scr_anim[ "hanging_enemy_01" ][ "hanging_struggle" ] 			= %nx_tp_rocket_crash_site_wakeup_allydive_opfor_01;
	level._scr_anim[ "hanging_enemy_02" ][ "hanging_struggle" ]  			= %nx_tp_rocket_crash_site_wakeup_allydive_opfor_01;
	level._scr_anim[ "hanging_enemy_03" ][ "hanging_struggle" ]  			= %nx_tp_rocket_crash_site_wakeup_allydive_opfor_01;
	level._scr_anim[ "hanging_enemy_03" ][ "hanging_execution" ]  			= %nx_tp_rocket_crash_site_wakeup_allyshotb_opfor_03;

	level._scr_anim[ "ally_williams" ][ "hanging_wakeup" ] 					= %nx_tp_rocket_crash_site_wakeup_ally1;
	level._scr_anim[ "ally_williams" ][ "hanging_cutdown" ] 				= %nx_tp_rocket_crash_site_wakeup_cutdown_ally1;

	level._scr_anim[ "hanging_player_legs" ][ "hanging_wakeup" ] 			= %nx_tp_rocket_crash_site_wakeup_player_legs;
	level._scr_anim[ "hanging_player_legs" ][ "hanging_cutdown" ] 			= %nx_tp_rocket_crash_site_wakeup_cutdown_player_legs;

	level._scr_anim[ "ally_baker" ][ "crash_blackhawk" ] 					= %nx_tp_rocket_helicoptercrash_baker;
	level._scr_anim[ "ally_williams" ][ "crash_blackhawk" ] 				= %nx_tp_rocket_helicoptercrash_williams;
	level._scr_anim[ "ally_jenkins" ][ "crash_blackhawk" ]					= %nx_tp_rocket_helicoptercrash_jenkings;
	level._scr_anim[ "helicopter_crash_ally_01" ][ "crash_blackhawk" ]		= %nx_tp_rocket_helicoptercrash_ally_01;

	level._scr_anim[ "crash_falling_ally_01" ][ "crash_falling" ]			= %nx_tp_rocket_helicoptercrash_ally_02;
	level._scr_anim[ "crash_falling_ally_02" ][ "crash_falling" ] 			= %nx_tp_rocket_helicoptercrash_ally_03;

	level._scr_anim[ "aa_control_exit_williams_01" ][ "aa_control_room_doors" ] = %nx_tp_rocket_aa_control_doors_exit_williams;

	level._scr_anim[ "jump_gantry_baker" ][ "jump_onto_gantry" ] 		   	 		= %nx_tp_rocket_jump_onto_gantry_baker_01;
	level._scr_anim[ "jump_gantry_opfor_01" ][ "jump_onto_gantry" ] 	   	 		= %nx_tp_rocket_jump_onto_gantry_opfor_01;
	
	level._scr_anim[ "vignette_rocket_baker" ][ "climb_onto_littlebird" ] 	 		= %nx_tp_rocket_climb_onto_littlebird_baker_01;
	level._scr_anim[ "vignette_rocket_opfor_01" ][ "climb_onto_littlebird" ] 		= %nx_tp_rocket_climb_onto_littlebird_opfor_01;
	level._scr_anim[ "vignette_rocket_opfor_02" ][ "climb_onto_littlebird" ] 		= %nx_tp_rocket_climb_onto_littlebird_opfor_02;
	
	level._scr_anim[ "ally_williams" ][ "aa_corridor_run_out_01" ] 					= %nx_tp_rocket_aa_corridor_williams_01;
	level._scr_anim[ "ally_williams" ][ "aa_corridor_run_out_02" ]					= %nx_tp_rocket_aa_corridor_williams_02;
	level._scr_anim[ "enemy_opfor" ][ "aa_corridor_wall_01" ] 						= %nx_tp_rocket_aa_corridor_cavein_opfor_01;
	level._scr_anim[ "enemy_opfor" ][ "aa_corridor_wall_01" ] 						= %nx_tp_rocket_aa_corridor_cavein_opfor_02;

	level._scr_anim[ "aa_corridor_run_player_legs_01" ][ "aa_corridor_run_out_01" ] = %nx_tp_rocket_aa_corridor_player_01_legs;
	level._scr_anim[ "aa_corridor_run_player_legs_02" ][ "aa_corridor_run_out_02" ] = %nx_tp_rocket_aa_corridor_player_02_legs;

	//BASE ECHO: ALLY WOODS TRAVERSAL
	level._scr_anim[ "ally_williams" ][ "woods_traversals_01" ] 					= %nx_tp_rocket_woods_trav_williams_01;
	level._scr_anim[ "ally_williams" ][ "woods_traversal_02" ] 						= %nx_tp_rocket_woods_trav_williams_02;

	//BASE ECHO: ALLY MANTLE
	level._scr_anim[ "ally_williams" ][ "woods_mantle" ] 							= %nx_tp_rocket_woods_mantel_williams_01;
	level._scr_anim[ "ally_jenkins" ][ "woods_mantle" ] 							= %nx_tp_rocket_woods_mantel_jenkins_01;

	//BASE ECHO: LEDGE
	level._scr_anim[ "ally_williams" ][ "woods_ledge_01" ]    = %nx_tp_rocket_woods_ledge_williams_01;
	level._scr_anim[ "ally_jenkins" ][ "woods_ledge_01" ]    = %nx_tp_rocket_woods_ledge_williams_01;
	level._scr_anim[ "vignette_woods_ledge_player_legs_01" ][ "woods_ledge_01" ] = %nx_tp_rocket_woods_ledge_player_01_legs;
	
	//BASE ECHO: CHOPPER
	level._scr_anim[ "ally_williams" ][ "woods_chopper_fly_over" ] = %nx_tp_rocket_woods_chopperflyover_williams_01;

	level._scr_anim[ "pipe_traversal_williams_01" ][ "pipe_traversal_01" ] 	= %nx_tp_rocket_pipe_traversals_williams_01;
	level._scr_anim[ "pipe_traversal_williams_02" ][ "pipe_traversal_02" ]	= %nx_tp_rocket_pipe_traversals_williams_02;

	//Intro player scene
	level._scr_anim[ "pilot_01" ][ "intro_allies_in_chopper" ] = %nx_tp_rocket_intro_pilot_01;
	level._scr_anim[ "pilot_02" ][ "intro_allies_in_chopper" ] = %nx_tp_rocket_intro_pilot_02;
	level._scr_anim[ "ally_01" ][ "intro_allies_in_chopper" ] = %nx_tp_rocket_intro_ally_01;
	level._scr_anim[ "ally_02" ][ "intro_allies_in_chopper" ] = %nx_tp_rocket_intro_ally_02;
	level._scr_anim[ "ally_03" ][ "intro_allies_in_chopper" ] = %nx_tp_rocket_intro_ally_03;

	level._scr_anim[ "ally_jenkins" ][ "intro_allies_in_chopper" ] = %nx_tp_rocket_intro_ally_01;
	level._scr_anim[ "ally_baker" ][ "intro_allies_in_chopper" ] = %nx_tp_rocket_intro_ally_02;
	level._scr_anim[ "ally_williams" ][ "intro_allies_in_chopper" ] = %nx_tp_rocket_intro_ally_03;

	//BASE ECHO: PIPE TRAVERSAL
	level._scr_anim[ "ally_williams" ][ "pipe_traversal_01" ] 	= %nx_tp_rocket_pipe_traversals_williams_01;
	level._scr_anim[ "ally_williams" ][ "pipe_traversal_02" ]	= %nx_tp_rocket_pipe_traversals_williams_02;

	//nuke and crash
	level._scr_anim[ "ally_baker" ][ "nuke_and_crash" ] = %nx_tp_rocket_nuke_crash_ally1;
	level._scr_anim[ "ally_jenkins" ][ "nuke_and_crash" ] = %nx_tp_rocket_nuke_crash_ally3;
	level._scr_anim[ "ally_williams" ][ "nuke_and_crash" ] = %nx_tp_rocket_nuke_crash_ally2;
	level._scr_anim[ "player_legs" ][ "nuke_and_crash" ] = %nx_fp_rocket_nuke_crash_playerlegs;
	level._scr_anim[ "nuke_crash_pilot" ][ "nuke_and_crash" ] = %nx_tp_rocket_nuke_crash_ally_pilot;

	// AA CONTROL MELEE
//  level._scr_anim[ "ally_jenkins" ][ "aa_control_melee" ] 		= %nx_tp_rocket_aa_control_melee_jenkins;
	level._scr_anim[ "ally_jenkins" ][ "aa_control_melee" ] 		= %nx_tp_rocket_aa_control_melee_jenkins;
	level._scr_anim[ "ally_williams" ][ "aa_control_melee" ] 		= %nx_tp_rocket_aa_control_melee_williams;
	level._scr_anim[ "enemy_opfor_01" ][ "aa_control_melee" ] 		= %nx_tp_rocket_aa_control_melee_opfor_01;
	level._scr_anim[ "enemy_opfor_02" ][ "aa_control_melee" ] 		= %nx_tp_rocket_aa_control_melee_opfor_02;
	level._scr_anim[ "player_legs" ][ "aa_control_melee" ] 			= %nx_tp_rocket_aa_control_melee_player_legs;
}

dialogue()
{

	// INTRO
	level._scr_sound["ally_baker"][ "roc_bak_intro_mandoorguns" ] = "roc_bak_intro_mandoorguns";
	level._scr_sound["ally_baker"][ "roc_bak_intro_hugthedeck" ] = "roc_bak_intro_hugthedeck";
	level._scr_sound["ally_baker"][ "roc_bak_intro_clockinzulu" ] = "roc_bak_intro_clockinzulu";
	level._scr_sound["ally_baker"][ "roc_bak_intro_nosearchandrescue" ] = "roc_bak_intro_nosearchandrescue";
	level._scr_sound["ally_baker"][ "roc_bak_intro_thatsanorder" ] = "roc_bak_intro_thatsanorder";
	level._scr_sound["ally_baker"][ "roc_bak_delta_climbclimbclimb"] = "roc_bak_delta_climbclimbclimb";

	level._scr_sound[ "ally_baker" ][ "roc_bak_intro_objective" ] 			=  "roc_bak_intro_objective";
	level._scr_sound[ "ally_baker" ][ "roc_bak_intro_pilotdrop" ] 			=  "roc_bak_intro_pilotdrop";
	level._scr_sound[ "ally_baker" ][ "roc_bak_intro_eyesonenemy" ] 		=  "roc_bak_intro_eyesonenemy";
	level._scr_sound[ "ally_williams" ][ "roc_wil_intro_hooah" ] 			=  "roc_wil_intro_hooah";
	level._scr_sound[ "ally_williams" ][ "roc_wil_intro_pullingback" ] 		=  "roc_wil_intro_pullingback";


	// BASE ALPHA
	level._scr_sound["ally_baker"][ "roc_bak_alpha_engagegroundtargets" ] = "roc_bak_alpha_engagegroundtargets";
	level._scr_sound["ally_baker"][ "roc_bak_alpha_gunshipat2oclock" ] = "roc_bak_alpha_gunshipat2oclock";
	level._scr_sound["ally_baker"][ "roc_bak_alpha_ordnanceontarget" ] = "roc_bak_alpha_ordnanceontarget";
	level._scr_sound["ally_baker"][ "roc_bak_alpha_bda1for1" ] = "roc_bak_alpha_bda1for1";
	level._scr_sound["ally_baker"][ "roc_bak_alpha_niceshot" ] = "roc_bak_alpha_niceshot";

	level._scr_sound[ "ally_baker" ][ "roc_bak_alpha_objgriduniform" ] 	   	= "roc_bak_alpha_objgriduniform";
	level._scr_sound[ "ally_baker" ][ "roc_bak_alpha_alpha2insight" ] 	   	= "roc_bak_alpha_alpha2insight";
	level._scr_sound[ "ally_baker" ][ "roc_bak_alpha_deadeyehit" ] 		    = "roc_bak_alpha_deadeyehit";
	level._scr_sound[ "ally_baker" ][ "roc_bak_alpha_engageground" ] 	   	= "roc_bak_alpha_engageground";
	level._scr_sound[ "ally_baker" ][ "roc_bak_alpha_mobilesonbunkers" ]    = "roc_bak_alpha_mobilesonbunkers";
	level._scr_sound[ "ally_baker" ][ "roc_bak_alpha_tangosopen" ] 		   	= "roc_bak_alpha_tangosopen";
	level._scr_sound[ "ally_baker" ][ "roc_bak_alpha_niceshot" ] 		   	= "roc_bak_alpha_niceshot";
	level._scr_sound[ "ally_baker" ][ "roc_bak_alpha_keepmoving" ] 		   	= "roc_bak_alpha_keepmoving";
	level._scr_sound[ "ally_baker" ][ "roc_bak_alpha_enroutebravo" ] 	   	= "roc_bak_alpha_enroutebravo";
	level._scr_sound[ "ally_baker" ][ "roc_bak_alpha_railshotnow" ] 	   	= "roc_bak_alpha_railshotnow";

	level._scr_sound[ "ally_baker" ][ "roc_bak_alpha_gantrymovingtolaunch" ] = "roc_bak_alpha_gantrymovingtolaunch";

	// BRIDGE
	level._scr_sound["ally_baker"][ "roc_bak_bridge_onourtail2" ] = "roc_bak_bridge_onourtail2";
	level._scr_sound["ally_baker"][ "roc_bak_delta_gunsup" ] = "roc_bak_delta_gunsup";

	level._scr_sound[ "ally_baker" ][ "roc_bak_bridge_helos1oclock" ]		= "roc_bak_bridge_helos1oclock";
	level._scr_sound[ "ally_baker" ][ "roc_bak_bridge_onourtail" ] 			= "roc_bak_bridge_onourtail";
	level._scr_sound[ "ally_baker" ][ "roc_bak_bridge_weaponsfree" ] 		= "roc_bak_bridge_weaponsfree";
	level._scr_sound[ "ally_baker" ][ "roc_bak_bridge_rpgsdive" ] 			= "roc_bak_bridge_rpgsdive";
	level._scr_sound[ "ally_baker" ][ "roc_bak_bridge_hangon" ] 			= "roc_bak_bridge_hangon";
	level._scr_sound[ "ally_baker" ][ "roc_bak_bridge_takeoutvtol" ] 		= "roc_bak_bridge_takeoutvtol";

	level._scr_sound[ "ally_williams" ][ "roc_wil_bridge_incoming" ]		= "roc_wil_bridge_incoming";
	level._scr_sound[ "ally_williams" ][ "roc_wil_bridge_anotherpatrol" ]	= "roc_wil_bridge_anotherpatrol";


	// BASE DELTA
	level._scr_sound[ "ally_baker" ][ "roc_bak_alpha_tangosopen" ]			= "roc_bak_alpha_tangosopen";
	level._scr_sound[ "ally_baker" ][ "roc_bak_delta_nerocketlaunching" ]	= "roc_bak_delta_nerocketlaunching";
	level._scr_sound[ "ally_baker" ][ "roc_bak_alpha_tangosbunker" ]		= "roc_bak_alpha_tangosbunker";
	level._scr_sound[ "ally_baker" ][ "roc_bak_alpha_tangosopen" ]			= "roc_bak_alpha_tangosopen";
	level._scr_sound[ "ally_baker" ][ "roc_bak_delta_climb" ]				= "roc_bak_delta_climb";
	level._scr_sound[ "ally_baker" ][ "roc_bak_alpha_painttargetnow" ]		= "roc_bak_alpha_painttargetnow";
	level._scr_sound[ "ally_baker" ][ "roc_bak_delta_window" ]				= "roc_bak_delta_window";
	level._scr_sound[ "ally_baker" ][ "roc_bak_delta_paintrocket" ]			= "roc_bak_delta_paintrocket";
	level._scr_sound[ "ally_baker" ][ "roc_bak_alpha_railshotnow" ]			= "roc_bak_alpha_railshotnow";
	level._scr_sound[ "ally_baker" ][ "roc_bak_delta_strkmissioncomplete" ] = "roc_bak_delta_strkmissioncomplete";
	level._scr_sound[ "ally_baker" ][ "roc_bak_delta_ontarget" ] 			= "roc_bak_delta_ontarget";

	// NUKE-CRASH
	level._scr_sound["ally_baker"][ "roc_bak_nuke_stayongunsnotdone" ] = "roc_bak_nuke_stayongunsnotdone";
	level._scr_sound["ally_williams"][ "roc_wil_nuke_hangon" ] = "roc_wil_nuke_hangon";

	// HANGING
	level._scr_sound["hanging_enemy_01"][ "roc_ec1_hang_luckyday" ] = "roc_ec1_hang_luckyday";
	level._scr_sound["hanging_enemy_01"][ "roc_ec1_hang_whereareyourfriends" ] = "roc_ec1_hang_whereareyourfriends";
	level._scr_sound["hanging_enemy_01"][ "roc_ec1_hang_deadman" ] = "roc_ec1_hang_deadman";
	level._scr_sound["hanging_enemy_01"][ "roc_ec2_hang_grunt_01" ] = "roc_ec2_hang_grunt_01";
	level._scr_sound["hanging_enemy_01"][ "roc_ec2_hang_grunt_02" ] = "roc_ec2_hang_grunt_02";

	// RADIO
	level._scr_radio[ "rocket_railgun_fire" ] = "rocket_railgun_fire";
	level._scr_radio[ "rocket_railgun_direct_hit" ] = "rocket_railgun_direct_hit";
	level._scr_radio[ "rocket_railgun_missed_target" ] = "rocket_railgun_missed_target";
	level._scr_radio[ "roc_bak_intro_objective" ] = "roc_bak_intro_objective";
	level._scr_radio[ "roc_bak_intro_hooah" ] = "roc_bak_intro_hooah";
	level._scr_radio[ "roc_bak_intro_holdshit" ] = "roc_bak_intro_holdshit";
	level._scr_radio[ "roc_bak_intro_pilotdrop" ] = "roc_bak_intro_pilotdrop";
	level._scr_radio[ "roc_bak_intro_checkingin" ] = "roc_bak_intro_checkingin";
	level._scr_radio[ "roc_bak_intro_eyesonenemy" ] = "roc_bak_intro_eyesonenemy";
	level._scr_radio[ "roc_bak_intro_cleartoengage" ] = "roc_bak_intro_cleartoengage";
	level._scr_radio[ "roc_bak_alpha_objgriduniform" ] = "roc_bak_alpha_objgriduniform";
	level._scr_radio[ "roc_bak_alpha_alpha2insight" ] = "roc_bak_alpha_alpha2insight";
	level._scr_radio[ "roc_bak_alpha_deadeyehit" ] = "roc_bak_alpha_deadeyehit";
	level._scr_radio[ "roc_bak_alpha_engageground" ] = "roc_bak_alpha_engageground";
	level._scr_radio[ "roc_bak_alpha_mobilesonbunkers" ] = "roc_bak_alpha_mobilesonbunkers";
	level._scr_radio[ "roc_bak_alpha_moerails" ] = "roc_bak_alpha_moerails";
	level._scr_radio[ "roc_bak_alpha_targetsupressed" ] = "roc_bak_alpha_targetsupressed";
	level._scr_radio[ "roc_bak_alpha_niceshot" ] = "roc_bak_alpha_niceshot";
	level._scr_radio[ "roc_bak_alpha_keepmoving" ] = "roc_bak_alpha_keepmoving";
	level._scr_radio[ "roc_bak_alpha_enroutebravo" ] = "roc_bak_alpha_enroutebravo";
	level._scr_radio[ "roc_bak_alpha_railshotnow" ] = "roc_bak_alpha_railshotnow";
	level._scr_radio[ "roc_bak_bridge_helos1oclock" ] = "roc_bak_bridge_helos1oclock";
	level._scr_radio[ "roc_bak_bridge_onourtail" ] = "roc_bak_bridge_onourtail";
	level._scr_radio[ "roc_bak_bridge_stayoncourse" ] = "roc_bak_bridge_stayoncourse";
	level._scr_radio[ "roc_bak_bridge_weaponsfree" ] = "roc_bak_bridge_weaponsfree";
	level._scr_radio[ "roc_bak_delta_markingtargets" ] = "roc_bak_delta_markingtargets";
	level._scr_radio[ "roc_bak_delta_takeoutrocket" ] = "roc_bak_delta_takeoutrocket";
	level._scr_radio[ "roc_bak_lbird_letsroll" ] = "roc_bak_lbird_letsroll";
	level._scr_radio[ "roc_bak_lbird_notimeforstories" ] = "roc_bak_lbird_notimeforstories";
	level._scr_radio[ "roc_bak_lbird_omegaundmgd" ] = "roc_bak_lbird_omegaundmgd";
	level._scr_radio[ "roc_bak_lbird_deadeyemia" ] = "roc_bak_lbird_deadeyemia";
	level._scr_radio[ "roc_bak_lbird_preparetoengage" ] = "roc_bak_lbird_preparetoengage";
	level._scr_radio[ "roc_bak_lbird_tangosongantry" ] = "roc_bak_lbird_tangosongantry";
	level._scr_radio[ "roc_bak_lbird_anycharges" ] = "roc_bak_lbird_anycharges";
	level._scr_radio[ "roc_bak_lbird_jenkins" ] = "roc_bak_lbird_jenkins";
	level._scr_radio[ "roc_bak_lbird_givetolockwood" ] = "roc_bak_lbird_givetolockwood";
	level._scr_radio[ "roc_bak_lbird_tangos10oclock" ] = "roc_bak_lbird_tangos10oclock";
	level._scr_radio[ "roc_bak_lbird_jenkinscontrols" ] = "roc_bak_lbird_jenkinscontrols";
	level._scr_radio[ "roc_bak_lbird_lockwoodwithme" ] = "roc_bak_lbird_lockwoodwithme";
	level._scr_radio[ "roc_bak_lbird_coverusfromchopper" ] = "roc_bak_lbird_coverusfromchopper";
	level._scr_radio[ "roc_bak_gantry_letsgo" ] = "roc_bak_gantry_letsgo";
	level._scr_radio[ "roc_bak_gantry_getchargeonhull" ] = "roc_bak_gantry_getchargeonhull";
	level._scr_radio[ "roc_bak_gantry_poppingwalkways" ] = "roc_bak_gantry_poppingwalkways";
	level._scr_radio[ "roc_bom_intro_approachingalpha" ] = "roc_bom_intro_approachingalpha";
	level._scr_radio[ "roc_bom_intro_incomingaa" ] = "roc_bom_intro_incomingaa";
	level._scr_radio[ "roc_cmd_intro_freebirdcopy" ] = "roc_cmd_intro_freebirdcopy";
	level._scr_radio[ "roc_cmd_intro_6b2sdown" ] = "roc_cmd_intro_6b2sdown";
	level._scr_radio[ "roc_cmd_intro_continuetocontact" ] = "roc_cmd_intro_continuetocontact";
	level._scr_radio[ "roc_cmd_intro_engageatwill" ] = "roc_cmd_intro_engageatwill";
	level._scr_radio[ "roc_cmd_alpha_rogercopyall" ] = "roc_cmd_alpha_rogercopyall";
	level._scr_radio[ "roc_cmd_alpha_railgunsonline" ] = "roc_cmd_alpha_railgunsonline";
	level._scr_radio[ "roc_cmd_alpha_circleobjective" ] = "roc_cmd_alpha_circleobjective";
	level._scr_radio[ "roc_cmd_alpha_railout" ] = "roc_cmd_alpha_railout";
	level._scr_radio[ "roc_cmd_alpha_solidcopy" ] = "roc_cmd_alpha_solidcopy";
	level._scr_radio[ "roc_cmd_bridge_lostyouinmntns" ] = "roc_cmd_bridge_lostyouinmntns";
	level._scr_radio[ "roc_cmd_bridge_railunavail" ] = "roc_cmd_bridge_railunavail";
	level._scr_radio[ "roc_cmd_delta_railsonline" ] = "roc_cmd_delta_railsonline";
	level._scr_radio[ "roc_jen_intro_hooah" ] = "roc_jen_intro_hooah";
	level._scr_radio[ "roc_jen_intro_goddamn" ] = "roc_jen_intro_goddamn";
	level._scr_radio[ "roc_jen_lbird_thoughtwelostyou" ] = "roc_jen_lbird_thoughtwelostyou";
	level._scr_radio[ "roc_jen_lbird_missionaccomplished" ] = "roc_jen_lbird_missionaccomplished";
	level._scr_radio[ "roc_jen_lbird_igot3" ] = "roc_jen_lbird_igot3";
	level._scr_radio[ "roc_pil_intro_hooah" ] = "roc_pil_intro_hooah";
	level._scr_radio[ "roc_sqd_intro_hooah" ] = "roc_sqd_intro_hooah";
	level._scr_radio[ "roc_wil_intro_hooah" ] = "roc_wil_intro_hooah";
	level._scr_radio[ "roc_wil_intro_pullingback" ] = "roc_wil_intro_pullingback";
	level._scr_radio[ "roc_wil_bridge_incoming" ] = "roc_wil_bridge_incoming";
	level._scr_radio[ "roc_wil_bridge_anotherpatrol" ] = "roc_wil_bridge_anotherpatrol";
	level._scr_radio[ "roc_wil_bridge_footmobs4victors" ] = "roc_wil_bridge_footmobs4victors";
	level._scr_radio[ "roc_wil_hanging_lockwood1" ] = "roc_wil_hanging_lockwood1";
	level._scr_radio[ "roc_wil_hanging_lockwood2" ] = "roc_wil_hanging_lockwood2";
	level._scr_radio[ "roc_wil_hanging_lockwoodwakeup" ] = "roc_wil_hanging_lockwoodwakeup";
	level._scr_radio[ "roc_wil_hanging_isjenkinsok" ] = "roc_wil_hanging_isjenkinsok";
	level._scr_radio[ "roc_wil_hanging_cutyoudown" ] = "roc_wil_hanging_cutyoudown";
	level._scr_radio[ "roc_wil_hanging_gotcompany" ] = "roc_wil_hanging_gotcompany";
	level._scr_radio[ "roc_wil_hanging_dosomething" ] = "roc_wil_hanging_dosomething";
	level._scr_radio[ "roc_wil_lbird_gladtoseebaker" ] = "roc_wil_lbird_gladtoseebaker";
	level._scr_radio[ "roc_wil_lbrid_deadeyesobjective" ] = "roc_wil_lbrid_deadeyesobjective";
	level._scr_radio[ "roc_wil_lbird_nosir" ] = "roc_wil_lbird_nosir";
	level._scr_radio[ "roc_wil_gantry_jumpin" ] = "roc_wil_gantry_jumpin";
	level._scr_radio[ "roc_pil_alpha_enroutebravo" ] = "roc_pil_alpha_enroutebravo";
	level._scr_radio[ "roc_bak_alpha_tangosground" ] = "roc_bak_alpha_tangosground";
	level._scr_radio[ "roc_bak_alpha_tangosbunker" ] = "roc_bak_alpha_tangosbunker";
	level._scr_radio[ "roc_bak_alpha_tangosopen" ] = "roc_bak_alpha_tangosopen";
	level._scr_radio[ "roc_bak_alpha_suppressapc" ] = "roc_bak_alpha_suppressapc";
	level._scr_radio[ "roc_bak_alpha_paintrocket" ] = "roc_bak_alpha_paintrocket";
	level._scr_radio[ "roc_bak_alpha_painttargetnow" ] = "roc_bak_alpha_painttargetnow";
	level._scr_radio[ "roc_pil_bridge_shouldicircle" ] = "roc_pil_bridge_shouldicircle";
	level._scr_radio[ "roc_bak_bridge_shotup" ] = "roc_bak_bridge_shotup";
	level._scr_radio[ "roc_bak_bridge_destroyvtols" ] = "roc_bak_bridge_destroyvtols";
	level._scr_radio[ "roc_bak_bridge_rpgsdive" ] = "roc_bak_bridge_rpgsdive";
	level._scr_radio[ "roc_bak_bridge_hangon" ] = "roc_bak_bridge_hangon";
	level._scr_radio[ "roc_bak_bridge_holdon" ] = "roc_bak_bridge_holdon";
	level._scr_radio[ "roc_bak_bridge_enemyvtol" ] = "roc_bak_bridge_enemyvtol";
	level._scr_radio[ "roc_bak_bridge_takeoutvtol" ] = "roc_bak_bridge_takeoutvtol";
	level._scr_radio[ "roc_bak_delta_nerocketlaunching" ] = "roc_bak_delta_nerocketlaunching";
	level._scr_radio[ "roc_bak_delta_climb" ] = "roc_bak_delta_climb";
	level._scr_radio[ "roc_bak_delta_rocketlaunching" ] = "roc_bak_delta_rocketlaunching";
	level._scr_radio[ "roc_bak_delta_window" ] = "roc_bak_delta_window";
	level._scr_radio[ "roc_bak_delta_paintrocket" ] = "roc_bak_delta_paintrocket";
	level._scr_radio[ "roc_bak_delta_vtolincoming" ] = "roc_bak_delta_vtolincoming";
	level._scr_radio[ "roc_bak_delta_holyshitdive" ] = "roc_bak_delta_holyshitdive";
	level._scr_radio[ "roc_bak_gantry_keepmoving" ] = "roc_bak_gantry_keepmoving";
	level._scr_radio[ "roc_bak_gantry_gogo" ] = "roc_bak_gantry_gogo";
	level._scr_radio[ "roc_bak_gantry_tangosleft" ] = "roc_bak_gantry_tangosleft";
	level._scr_radio[ "roc_bak_gantry_tangosright" ] = "roc_bak_gantry_tangosright";
	level._scr_radio[ "roc_bak_gantry_outoftime" ] = "roc_bak_gantry_outoftime";
	level._scr_radio[ "roc_bak_gantry_getdownhere" ] = "roc_bak_gantry_getdownhere";
	level._scr_radio[ "roc_cam_nuke_incoming" ] = "roc_cam_nuke_incoming";
	level._scr_radio[ "roc_pil_nuke_whoa" ] = "roc_pil_nuke_whoa";
	level._scr_radio[ "roc_pil_nuke_beaware" ] = "roc_pil_nuke_beaware";
	level._scr_radio[ "roc_cam_nuke_wtf" ] = "roc_cam_nuke_wtf";
	level._scr_radio[ "roc_gun_nuke_seethat" ] = "roc_gun_nuke_seethat";
	level._scr_radio[ "roc_cam_nuke_holyshit" ] = "roc_cam_nuke_holyshit";
	level._scr_radio[ "roc_bak_nuke_stfu" ] = "roc_bak_nuke_stfu";
	level._scr_radio[ "roc_pil_nuke_comein" ] = "roc_pil_nuke_comein";
	level._scr_radio[ "roc_cam_nuke_ohshit" ] = "roc_cam_nuke_ohshit";
	level._scr_radio[ "roc_pil_nuke_grabon" ] = "roc_pil_nuke_grabon";
	level._scr_radio[ "roc_wil_hang_lockwood" ] = "roc_wil_hang_lockwood";
	level._scr_radio[ "roc_wil_hang_yourealive" ] = "roc_wil_hang_yourealive";
	level._scr_radio[ "roc_wil_hang_imuphere" ] = "roc_wil_hang_imuphere";
	level._scr_radio[ "roc_wil_hang_gotcompany" ] = "roc_wil_hang_gotcompany";
	level._scr_radio[ "roc_wil_hang_dosomething" ] = "roc_wil_hang_dosomething";
	level._scr_radio[ "roc_jen_hang_thoughtiwasdead" ] = "roc_jen_hang_thoughtiwasdead";
	level._scr_radio[ "roc_jen_hang_baker" ] = "roc_jen_hang_baker";
	level._scr_radio[ "roc_wil_hang_bettergetmoving" ] = "roc_wil_hang_bettergetmoving";
	level._scr_radio[ "roc_wil_echo_tangosahead" ] = "roc_wil_echo_tangosahead";
	level._scr_radio[ "roc_wil_echo_objecho" ] = "roc_wil_echo_objecho";
	level._scr_radio[ "roc_jen_echo_flightdelayed" ] = "roc_jen_echo_flightdelayed";
	level._scr_radio[ "roc_wil_echo_stfujenkins" ] = "roc_wil_echo_stfujenkins";
	level._scr_radio[ "roc_jen_echo_pipe" ] = "roc_jen_echo_pipe";
	level._scr_radio[ "roc_wil_echo_worthashot" ] = "roc_wil_echo_worthashot";
	level._scr_radio[ "roc_wil_echo_downhere" ] = "roc_wil_echo_downhere";
	level._scr_radio[ "roc_wil_echo_moveout" ] = "roc_wil_echo_moveout";
	level._scr_radio[ "roc_jen_echo_flagdownbird" ] = "roc_jen_echo_flagdownbird";
	level._scr_radio[ "roc_wil_echo_shit" ] = "roc_wil_echo_shit";
	level._scr_radio[ "roc_wil_echo_cantdoanythingforthem" ] = "roc_wil_echo_cantdoanythingforthem";
	level._scr_radio[ "roc_wil_trbase_structureahead" ] = "roc_wil_trbase_structureahead";
	level._scr_radio[ "roc_wil_trbase_getdropontangos" ] = "roc_wil_trbase_getdropontangos";
	level._scr_radio[ "roc_wil_trbase_gotanidea" ] = "roc_wil_trbase_gotanidea";
	level._scr_radio[ "roc_wil_trbase_tangocatwalk" ] = "roc_wil_trbase_tangocatwalk";
	level._scr_radio[ "roc_jen_trbase_tangohallway" ] = "roc_jen_trbase_tangohallway";
	level._scr_radio[ "roc_wil_tubase_leadtheway" ] = "roc_wil_tubase_leadtheway";
	level._scr_radio[ "roc_wil_trctrl_takethecontrols" ] = "roc_wil_trctrl_takethecontrols";
	level._scr_radio[ "roc_wil_trctrl_needtomove" ] = "roc_wil_trctrl_needtomove";
	level._scr_radio[ "roc_will_trctrl_jenkinsgetdoor" ] = "roc_will_trctrl_jenkinsgetdoor";
	level._scr_radio[ "roc_wil_trctrl_keepmoving" ] = "roc_wil_trctrl_keepmoving";
	level._scr_radio[ "roc_wil_trctrl_gogogo" ] = "roc_wil_trctrl_gogogo";
	level._scr_radio[ "roc_jen_rescue_holyshit" ] = "roc_jen_rescue_holyshit";
	level._scr_radio[ "roc_jen_rescue_strongmsg" ] = "roc_jen_rescue_strongmsg";
	level._scr_radio[ "roc_wil_rescue_rollout" ] = "roc_wil_rescue_rollout";
	level._scr_radio[ "roc_wil_rescue_tangowarehouse" ] = "roc_wil_rescue_tangowarehouse";
	level._scr_radio[ "roc_wil_rescue_getoutofhere" ] = "roc_wil_rescue_getoutofhere";
	level._scr_radio[ "roc_jen_rescue_moretangosincoming" ] = "roc_jen_rescue_moretangosincoming";
	level._scr_radio[ "roc_wil_rescue_takecoverawhile" ] = "roc_wil_rescue_takecoverawhile";
	level._scr_radio[ "roc_jen_rescue_tangosdrivingin" ] = "roc_jen_rescue_tangosdrivingin";
	level._scr_radio[ "roc_wil_rescue_takethemout" ] = "roc_wil_rescue_takethemout";
	level._scr_radio[ "roc_jen_rescue_vtolbadnews" ] = "roc_jen_rescue_vtolbadnews";
	level._scr_radio[ "roc_jen_rescue_humveetakecover" ] = "roc_jen_rescue_humveetakecover";
	level._scr_radio[ "roc_wil_rescue_takeoutgunner" ] = "roc_wil_rescue_takeoutgunner";
	level._scr_radio[ "roc_wil_rescue_getongun" ] = "roc_wil_rescue_getongun";
	level._scr_radio[ "roc_jen_rescue_apc" ] = "roc_jen_rescue_apc";
	level._scr_radio[ "roc_jen_rescue_baker" ] = "roc_jen_rescue_baker";
	level._scr_radio[ "roc_wil_rescue_makearun" ] = "roc_wil_rescue_makearun";
	level._scr_radio[ "roc_bak_gantry_takepoint" ] = "roc_bak_gantry_takepoint";
	level._scr_radio[ "roc_bak_gantry_coveryoursix" ] = "roc_bak_gantry_coveryoursix";
	level._scr_radio[ "roc_bak_gantry_gettotherocket" ] = "roc_bak_gantry_gettotherocket";
	level._scr_radio[ "roc_bak_gantry_runningoutoftime" ] = "roc_bak_gantry_runningoutoftime";
	level._scr_radio[ "roc_bak_gantry_120sec" ] = "roc_bak_gantry_120sec";
	level._scr_radio[ "roc_bak_gantry_60sec" ] = "roc_bak_gantry_60sec";
	level._scr_radio[ "roc_bak_gantry_30sec" ] = "roc_bak_gantry_30sec";
	level._scr_radio[ "roc_bak_gantry_keepgoing" ] = "roc_bak_gantry_keepgoing";
	level._scr_radio[ "roc_bak_gantry_jumpdowntothearm" ] = "roc_bak_gantry_jumpdowntothearm";
	level._scr_radio[ "roc_bak_gantry_jump" ] = "roc_bak_gantry_jump";
	level._scr_radio[ "roc_bak_gantry_holdon" ] = "roc_bak_gantry_holdon";
	level._scr_radio[ "roc_bak_gantry_followme" ] = "roc_bak_gantry_followme";
	level._scr_radio[ "roc_bak_gantry_cmon" ] = "roc_bak_gantry_cmon";
	level._scr_radio[ "roc_bak_gantry_hurryup" ] = "roc_bak_gantry_hurryup";
	level._scr_radio[ "roc_bak_gantry_doubletime" ] = "roc_bak_gantry_doubletime";
	level._scr_radio[ "roc_bak_gantry_letsgetoutofhere" ] = "roc_bak_gantry_letsgetoutofhere";
	level._scr_radio[ "roc_wil_gantry_getin" ] = "roc_wil_gantry_getin";
	level._scr_radio[ "roc_bak_gantry_detonatec4" ] = "roc_bak_gantry_detonatec4";
	level._scr_radio[ "roc_bak_gantry_blowc4" ] = "roc_bak_gantry_blowc4";
	level._scr_radio[ "roc_bak_gantry_waitingforblowit" ] = "roc_bak_gantry_waitingforblowit";
	level._scr_radio[ "roc_bak_gantry_holdupblowit" ] = "roc_bak_gantry_holdupblowit";
	level._scr_radio[ "roc_bak_gantry_lockwoodblowc4" ] = "roc_bak_gantry_lockwoodblowc4";
	level._scr_radio[ "roc_bak_nuke_multiplesinbound" ] = "roc_bak_nuke_multiplesinbound";
	level._scr_radio[ "roc_bak_nuke_warheadsinbound" ] = "roc_bak_nuke_warheadsinbound";
	level._scr_radio[ "roc_car_nuke_engaging" ] = "roc_car_nuke_engaging";
	level._scr_radio[ "roc_wil_nuke_holyshit" ] = "roc_wil_nuke_holyshit";
	level._scr_radio[ "roc_jen_nuke_aretheygone" ] = "roc_jen_nuke_aretheygone";
	level._scr_radio[ "roc_wil_nuke_jesustheyregone" ] = "roc_wil_nuke_jesustheyregone";
	level._scr_radio[ "roc_bak_nuke_doesntchangeanything" ] = "roc_bak_nuke_doesntchangeanything";
	level._scr_radio[ "roc_wil_nuke_werefucked" ] = "roc_wil_nuke_werefucked";
	level._scr_radio[ "roc_jen_nuke_holyshittheyregone" ] = "roc_jen_nuke_holyshittheyregone";
	level._scr_radio[ "roc_jen_nuke_theyrefuckingone" ] = "roc_jen_nuke_theyrefuckingone";
	level._scr_radio[ "roc_wil_nuke_shit" ] = "roc_wil_nuke_shit";
	level._scr_radio[ "roc_wil_nuke_thisisntgood" ] = "roc_wil_nuke_thisisntgood";
	level._scr_radio[ "roc_wil_nuke_jesus" ] = "roc_wil_nuke_jesus";
	level._scr_radio[ "roc_wil_nuke_ohshit" ] = "roc_wil_nuke_ohshit";
	level._scr_radio[ "roc_jen_nuke_fuck" ] = "roc_jen_nuke_fuck";
	level._scr_radio[ "roc_jen_nuke_holdon" ] = "roc_jen_nuke_holdon";
	level._scr_radio[ "roc_jen_nuke_noo" ] = "roc_jen_nuke_noo";
	level._scr_radio[ "roc_bak_rescue_comeindeadeye" ] = "roc_bak_rescue_comeindeadeye";
	level._scr_radio[ "roc_jen_rescue_isthatbaker" ] = "roc_jen_rescue_isthatbaker";
	level._scr_radio[ "roc_wil_rescue_solidcopy" ] = "roc_wil_rescue_solidcopy";
	level._scr_radio[ "roc_bak_rescue_currentlocation" ] = "roc_bak_rescue_currentlocation";
	level._scr_radio[ "roc_wil_rescue_satcomuplink" ] = "roc_wil_rescue_satcomuplink";
	level._scr_radio[ "roc_bak_rescue_gotitonourway" ] = "roc_bak_rescue_gotitonourway";
	level._scr_radio[ "roc_bak_rescue_takecoverdefendloc" ] = "roc_bak_rescue_takecoverdefendloc";
	level._scr_radio[ "roc_wil_rescue_jenkinstakeleft" ] = "roc_wil_rescue_jenkinstakeleft";
	level._scr_radio[ "roc_wil_rescue_defendthislocation" ] = "roc_wil_rescue_defendthislocation";
	level._scr_radio[ "roc_wil_rescue_allavailunits" ] = "roc_wil_rescue_allavailunits";
	level._scr_radio[ "roc_wil_rescue_pinnedheavyfire" ] = "roc_wil_rescue_pinnedheavyfire";
	level._scr_radio[ "roc_wil_rescue_needevacnow" ] = "roc_wil_rescue_needevacnow";
	level._scr_radio[ "roc_wil_rescue_eta" ] = "roc_wil_rescue_eta";
	level._scr_radio[ "roc_bak_rescue_1min" ] = "roc_bak_rescue_1min";
	level._scr_radio[ "roc_bak_rescue_2min" ] = "roc_bak_rescue_2min";
	level._scr_radio[ "roc_bak_rescue_3min" ] = "roc_bak_rescue_3min";
	level._scr_radio[ "roc_bak_rescue_almostthere" ] = "roc_bak_rescue_almostthere";
	level._scr_radio[ "roc_car_alpha_wehavegolink" ] = "roc_car_alpha_wehavegolink";
	level._scr_radio[ "roc_car_alpha_targetlinkconfirmed" ] = "roc_car_alpha_targetlinkconfirmed";
	level._scr_radio[ "roc_car_alpha_weaponhot" ] = "roc_car_alpha_weaponhot";
	level._scr_radio[ "roc_car_alpha_payloadcountdown" ] = "roc_car_alpha_payloadcountdown";
	level._scr_radio[ "roc_pil_alpha_incoming" ] = "roc_pil_alpha_incoming";
	level._scr_radio[ "roc_pil_alpha_holdon" ] = "roc_pil_alpha_holdon";
	level._scr_radio[ "roc_pil_alpha_herewego" ] = "roc_pil_alpha_herewego";
	level._scr_radio[ "roc_car_alpha_weshowimpact" ] = "roc_car_alpha_weshowimpact";
	level._scr_radio[ "roc_bak_alpha_confirmedheavykia" ] = "roc_bak_alpha_confirmedheavykia";
	level._scr_radio[ "roc_bak_alpha_negativestrikemiss" ] = "roc_bak_alpha_negativestrikemiss";
	level._scr_radio[ "roc_car_nuke_confirmstrike" ] = "roc_car_nuke_confirmstrike";
	level._scr_radio[ "roc_car_nuke_confirmdelta" ] = "roc_car_nuke_confirmdelta";
	level._scr_radio[ "roc_bak_nuke_deltaconfirmed" ] = "roc_bak_nuke_deltaconfirmed";
	level._scr_radio[ "roc_car_nuke_redirectnovember" ] = "roc_car_nuke_redirectnovember";
	level._scr_radio[ "roc_bak_nuke_novembernewprimary" ] = "roc_bak_nuke_novembernewprimary";
	level._scr_radio[ "roc_car_nuke_proceedtonovember" ] = "roc_car_nuke_proceedtonovember";
	level._scr_radio[ "roc_dra_intro_winteranvil" ] = "roc_dra_intro_winteranvil";
	level._scr_radio[ "roc_bak_intro_mandoorguns" ] = "roc_bak_intro_mandoorguns";
	level._scr_radio[ "roc_dra_intro_angels12ipalpha" ] = "roc_dra_intro_angels12ipalpha";
	level._scr_radio[ "roc_con_intro_letswakethemup" ] = "roc_con_intro_letswakethemup";
	level._scr_radio[ "roc_con_intro_approachingrmax" ] = "roc_con_intro_approachingrmax";
	level._scr_radio[ "roc_ven_intro_rfscopelitup" ] = "roc_ven_intro_rfscopelitup";
	level._scr_radio[ "roc_con_intro_strobesat350" ] = "roc_con_intro_strobesat350";
	level._scr_radio[ "roc_ven_intro_condor1breakright" ] = "roc_ven_intro_condor1breakright";
	level._scr_radio[ "roc_con_intro_goevasive" ] = "roc_con_intro_goevasive";
	level._scr_radio[ "roc_con_intro_incomingpullup" ] = "roc_con_intro_incomingpullup";
	level._scr_radio[ "roc_dra_intro_condor1reportstatus" ] = "roc_dra_intro_condor1reportstatus";
	level._scr_radio[ "roc_dra_intro_condor1acknowledge" ] = "roc_dra_intro_condor1acknowledge";
	level._scr_radio[ "roc_ven_intro_squawkstheyregone" ] = "roc_ven_intro_squawkstheyregone";
	level._scr_radio[ "roc_bak_intro_hugthedeck" ] = "roc_bak_intro_hugthedeck";
	level._scr_radio[ "roc_dra_intro_cannotallowrockets" ] = "roc_dra_intro_cannotallowrockets";
	level._scr_radio[ "roc_ded1_intro_proceeding2ipalpha" ] = "roc_ded1_intro_proceeding2ipalpha";
	level._scr_radio[ "roc_swi_nuke_wilcoswbladeenroute" ] = "roc_swi_nuke_wilcoswbladeenroute";
	level._scr_radio[ "roc_bak_intro_clockinzulu" ] = "roc_bak_intro_clockinzulu";
	level._scr_radio[ "roc_ded2_intro_irscanengingeflares" ] = "roc_ded2_intro_irscanengingeflares";
	level._scr_radio[ "roc_bak_intro_fireatwill" ] = "roc_bak_intro_fireatwill";
	level._scr_radio[ "roc_bak_intro_enemyarmorinbound" ] = "roc_bak_intro_enemyarmorinbound";
	level._scr_radio[ "roc_bak_intro_targetdestroyed" ] = "roc_bak_intro_targetdestroyed";
	level._scr_radio[ "roc_bak_intro_killconfirmed" ] = "roc_bak_intro_killconfirmed";
	level._scr_radio[ "roc_ded1_intro_niceshootingzulu" ] = "roc_ded1_intro_niceshootingzulu";
	level._scr_radio[ "roc_ded2_intro_takingfire" ] = "roc_ded2_intro_takingfire";
	level._scr_radio[ "roc_ded1_intro_ded2evasiveaction" ] = "roc_ded1_intro_ded2evasiveaction";
	level._scr_radio[ "roc_ded2_intro_hitlosingaltitude" ] = "roc_ded2_intro_hitlosingaltitude";
	level._scr_radio[ "roc_ded1_intro_ded2isdown" ] = "roc_ded1_intro_ded2isdown";
	level._scr_radio[ "roc_ded1_intro_checkforsurvivors" ] = "roc_ded1_intro_checkforsurvivors";
	level._scr_radio[ "roc_bak_intro_nosearchandrescue" ] = "roc_bak_intro_nosearchandrescue";
	level._scr_radio[ "roc_ded1_intro_theycouldbealive" ] = "roc_ded1_intro_theycouldbealive";
	level._scr_radio[ "roc_bak_intro_thatsanorder" ] = "roc_bak_intro_thatsanorder";
	level._scr_radio[ "roc_ded1_intro_copyzulucharliemike" ] = "roc_ded1_intro_copyzulucharliemike";
	level._scr_radio[ "roc_ded1_alpha_approachingalpha" ] = "roc_ded1_alpha_approachingalpha";
	level._scr_radio[ "roc_dra_alpha_doyouhaveavisual" ] = "roc_dra_alpha_doyouhaveavisual";
	level._scr_radio[ "roc_ded1_alpha_eyesoncandlestick1" ] = "roc_ded1_alpha_eyesoncandlestick1";
	level._scr_radio[ "roc_dra_alpha_xbowcleartoengage" ] = "roc_dra_alpha_xbowcleartoengage";
	level._scr_radio[ "roc_cro_alpha_lincolnfirecontrol" ] = "roc_cro_alpha_lincolnfirecontrol";
	level._scr_radio[ "roc_cro_alpha_linkactive" ] = "roc_cro_alpha_linkactive";
	level._scr_radio[ "roc_bak_alpha_paintrocket" ] = "roc_bak_alpha_paintrocket";
	level._scr_radio[ "roc_bak_alpha_usetargettinglaser" ] = "roc_bak_alpha_usetargettinglaser";
	level._scr_radio[ "roc_bak_alpha_wtfwaitingfor" ] = "roc_bak_alpha_wtfwaitingfor";
	level._scr_radio[ "roc_dra_alpha_runningoutoftime" ] = "roc_dra_alpha_runningoutoftime";
	level._scr_radio[ "roc_bak_alpha_dropthehammer" ] = "roc_bak_alpha_dropthehammer";
	level._scr_radio[ "roc_cro_alpha_firemissionconfirmed" ] = "roc_cro_alpha_firemissionconfirmed";
	level._scr_radio[ "roc_cro_alpha_tti3sec" ] = "roc_cro_alpha_tti3sec";
	level._scr_radio[ "roc_cro_alpha_maintaintargetlock" ] = "roc_cro_alpha_maintaintargetlock";
	level._scr_radio[ "roc_cro_alpha_21splash" ] = "roc_cro_alpha_21splash";
	level._scr_radio[ "roc_bak_alpha_ordnanceontarget" ] = "roc_bak_alpha_ordnanceontarget";
	level._scr_radio[ "roc_bak_alpha_bda1for1" ] = "roc_bak_alpha_bda1for1";
	level._scr_radio[ "roc_bak_alpha_engagegroundtargets" ] = "roc_bak_alpha_engagegroundtargets";
	level._scr_radio[ "roc_bak_alpha_gunshipat2oclock" ] = "roc_bak_alpha_gunshipat2oclock";
	level._scr_radio[ "roc_ded3_alpha_irshowsecdismounts" ] = "roc_ded3_alpha_irshowsecdismounts";
	level._scr_radio[ "roc_bak_alpha_wastethemwalker" ] = "roc_bak_alpha_wastethemwalker";
	level._scr_radio[ "roc_ded3_alpha_glassingmultavs" ] = "roc_ded3_alpha_glassingmultavs";
	level._scr_radio[ "roc_ded4_alpha_yougothim" ] = "roc_ded4_alpha_yougothim";
	level._scr_radio[ "roc_ded4_alpha_goodkill" ] = "roc_ded4_alpha_goodkill";
	level._scr_radio[ "roc_ded1_alpha_enemysupressed" ] = "roc_ded1_alpha_enemysupressed";
	level._scr_radio[ "roc_ded1_alpha_watchforaaa" ] = "roc_ded1_alpha_watchforaaa";
	level._scr_radio[ "roc_ded1_alpha_goingdefensive" ] = "roc_ded1_alpha_goingdefensive";
	level._scr_radio[ "roc_bak_alpha_knockoutbunker" ] = "roc_bak_alpha_knockoutbunker";
	level._scr_radio[ "roc_bak_alpha_watchrooftops" ] = "roc_bak_alpha_watchrooftops";
	level._scr_radio[ "roc_bak_alpha_targetaaa" ] = "roc_bak_alpha_targetaaa";
	level._scr_radio[ "roc_bak_alpha_birdat2oclock" ] = "roc_bak_alpha_birdat2oclock";
	level._scr_radio[ "roc_ded3_alpha_werehit" ] = "roc_ded3_alpha_werehit";
	level._scr_radio[ "roc_ded1_alpha_ded4isdown" ] = "roc_ded1_alpha_ded4isdown";
	level._scr_radio[ "roc_dra_alpha_engagein36actual" ] = "roc_dra_alpha_engagein36actual";
	level._scr_radio[ "roc_ded1_alpha_copybuggingout" ] = "roc_ded1_alpha_copybuggingout";
	level._scr_radio[ "roc_cro_alpha_payloadcountdown" ] = "roc_cro_alpha_payloadcountdown";
	level._scr_radio[ "roc_ded4_bridge_boogie12oclock" ] = "roc_ded4_bridge_boogie12oclock";
	level._scr_radio[ "roc_ded1_bridge_visualon2gunships" ] = "roc_ded1_bridge_visualon2gunships";
	level._scr_radio[ "roc_ded1_bridge_ded3breakleft" ] = "roc_ded1_bridge_ded3breakleft";
	level._scr_radio[ "roc_ded1_bridge_negativevisual" ] = "roc_ded1_bridge_negativevisual";
	level._scr_radio[ "roc_bak_bridge_onourtail2" ] = "roc_bak_bridge_onourtail2";
	level._scr_radio[ "roc_ded1_bridge_splash1" ] = "roc_ded1_bridge_splash1";
	level._scr_radio[ "roc_ded1_bridge_splash2" ] = "roc_ded1_bridge_splash2";
	level._scr_radio[ "roc_ded1_bridge_irtargeting" ] = "roc_ded1_bridge_irtargeting";
	level._scr_radio[ "roc_bak_bridge_hostilesonbridge" ] = "roc_bak_bridge_hostilesonbridge";
	level._scr_radio[ "roc_ded1_bridge_targetlock" ] = "roc_ded1_bridge_targetlock";
	level._scr_radio[ "roc_ded1_bridge_launchdetected" ] = "roc_ded1_bridge_launchdetected";
	level._scr_radio[ "roc_ded1_bridge_missileinbound" ] = "roc_ded1_bridge_missileinbound";
	level._scr_radio[ "roc_ded1_bridge_evasiveaction" ] = "roc_ded1_bridge_evasiveaction";
	level._scr_radio[ "roc_ded1_bridge_countermeasures" ] = "roc_ded1_bridge_countermeasures";
	level._scr_radio[ "roc_ded1_bridge_flaresout" ] = "roc_ded1_bridge_flaresout";
	level._scr_radio[ "roc_ded1_bridge_chaff" ] = "roc_ded1_bridge_chaff";
	level._scr_radio[ "roc_swi_bridge_eyeson3rockets" ] = "roc_swi_bridge_eyeson3rockets";
	level._scr_radio[ "roc_dra_bridge_copyswbladeirscan" ] = "roc_dra_bridge_copyswbladeirscan";
	level._scr_radio[ "roc_swi_bridge_candlesarelit" ] = "roc_swi_bridge_candlesarelit";
	level._scr_radio[ "roc_dra_bridge_takethoserocketsout" ] = "roc_dra_bridge_takethoserocketsout";
	level._scr_radio[ "roc_swi_bridge_copythatgoingin" ] = "roc_swi_bridge_copythatgoingin";
	level._scr_radio[ "roc_swi_bridge_hornetsnest" ] = "roc_swi_bridge_hornetsnest";
	level._scr_radio[ "roc_dra_bridge_swbladecomeback" ] = "roc_dra_bridge_swbladecomeback";
	level._scr_radio[ "roc_dra_bridge_swbladeacknowledge" ] = "roc_dra_bridge_swbladeacknowledge";
	level._scr_radio[ "roc_dra_bridge_ded1proceedtodelta" ] = "roc_dra_bridge_ded1proceedtodelta";
	level._scr_radio[ "roc_ded1_bridge_copywereonit" ] = "roc_ded1_bridge_copywereonit";
	level._scr_radio[ "roc_bak_bridge_helos1oclock" ] = "roc_bak_bridge_helos1oclock";
	level._scr_radio[ "roc_ded1_delta_approachingdelta" ] = "roc_ded1_delta_approachingdelta";
	level._scr_radio[ "roc_dra_delta_donotallowlaunch" ] = "roc_dra_delta_donotallowlaunch";
	level._scr_radio[ "roc_dra_delta_stopthatlaunch" ] = "roc_dra_delta_stopthatlaunch";
	level._scr_radio[ "roc_bak_delta_gunsup" ] = "roc_bak_delta_gunsup";
	level._scr_radio[ "roc_swi_delta_goodtoseeyoudeadeye" ] = "roc_swi_delta_goodtoseeyoudeadeye";
	level._scr_radio[ "roc_ded1_delta_swbladegotyoursix" ] = "roc_ded1_delta_swbladegotyoursix";
	level._scr_radio[ "roc_cro_delta_railgunonlinestandby" ] = "roc_cro_delta_railgunonlinestandby";
	level._scr_radio[ "roc_cro_delta_targeting" ] = "roc_cro_delta_targeting";
	level._scr_radio[ "roc_cro_delta_fox1railout" ] = "roc_cro_delta_fox1railout";
	level._scr_radio[ "roc_cro_delta_3sectoimpact" ] = "roc_cro_delta_3sectoimpact";
	level._scr_radio[ "roc_bak_delta_killconfirmed" ] = "roc_bak_delta_killconfirmed";
	level._scr_radio[ "roc_ded1_delta_engage2ndtarget" ] = "roc_ded1_delta_engage2ndtarget";
	level._scr_radio[ "roc_swi_delta_bogiegoevasive" ] = "roc_swi_delta_bogiegoevasive";
	level._scr_radio[ "roc_swi_delta_getassholeoffmytail" ] = "roc_swi_delta_getassholeoffmytail";
	level._scr_radio[ "roc_ded1_delta_clearswblade" ] = "roc_ded1_delta_clearswblade";
	level._scr_radio[ "roc_swi_delta_oweyouone" ] = "roc_swi_delta_oweyouone";
	level._scr_radio[ "roc_cro_delta_railgunonline" ] = "roc_cro_delta_railgunonline";
	level._scr_radio[ "roc_cro_delta_calcfiringsolution" ] = "roc_cro_delta_calcfiringsolution";
	level._scr_radio[ "roc_cro_delta_firing" ] = "roc_cro_delta_firing";
	level._scr_radio[ "roc_cro_delta_railout" ] = "roc_cro_delta_railout";
	level._scr_radio[ "roc_cro_delta_321impact" ] = "roc_cro_delta_321impact";
	level._scr_radio[ "roc_bak_delta_bda1for1" ] = "roc_bak_delta_bda1for1";
	level._scr_radio[ "roc_dra_delta_candle3airborne" ] = "roc_dra_delta_candle3airborne";
	level._scr_radio[ "roc_ded1_delta_movingtoengage" ] = "roc_ded1_delta_movingtoengage";
	level._scr_radio[ "roc_bak_delta_buckleup" ] = "roc_bak_delta_buckleup";
	level._scr_radio[ "roc_bak_delta_climbclimbclimb" ] = "roc_bak_delta_climbclimbclimb";
	level._scr_radio[ "roc_bak_delta_lightemup" ] = "roc_bak_delta_lightemup";
	level._scr_radio[ "roc_cro_delta_targetislit" ] = "roc_cro_delta_targetislit";
	level._scr_radio[ "roc_cro_delta_firingforeffect" ] = "roc_cro_delta_firingforeffect";
	level._scr_radio[ "roc_bak_delta_ontarget" ] = "roc_bak_delta_ontarget";
	level._scr_radio[ "roc_cro_delta_splashin321" ] = "roc_cro_delta_splashin321";
	level._scr_radio[ "roc_cro_delta_standingbyforbda" ] = "roc_cro_delta_standingbyforbda";
	level._scr_radio[ "roc_bak_delta_thatfuckeristoast" ] = "roc_bak_delta_thatfuckeristoast";
	level._scr_radio[ "roc_kpa_delta_launchcommencing" ] = "roc_kpa_delta_launchcommencing";
	level._scr_radio[ "roc_kpa_delta_30sectolaunch" ] = "roc_kpa_delta_30sectolaunch";
	level._scr_radio[ "roc_kpa_delta_proceedwithcountdown" ] = "roc_kpa_delta_proceedwithcountdown";
	level._scr_radio[ "roc_kpa_delta_notpossibletoabort" ] = "roc_kpa_delta_notpossibletoabort";
	level._scr_radio[ "roc_kpa_delta_countdown30" ] = "roc_kpa_delta_countdown30";
	level._scr_radio[ "roc_kpa_delta_countdown20" ] = "roc_kpa_delta_countdown20";
	level._scr_radio[ "roc_kpa_delta_countdown10" ] = "roc_kpa_delta_countdown10";
	level._scr_radio[ "roc_kpa_delta_clearallblastways" ] = "roc_kpa_delta_clearallblastways";
	level._scr_radio[ "roc_dra_nuke_ded1proceed86actual" ] = "roc_dra_nuke_ded1proceed86actual";
	level._scr_radio[ "roc_ded1_nuke_turningfor86actual" ] = "roc_ded1_nuke_turningfor86actual";
	level._scr_radio[ "roc_kee_nuke_shitwhatwasthat" ] = "roc_kee_nuke_shitwhatwasthat";
	level._scr_radio[ "roc_ded1_nuke_cruisemissiles" ] = "roc_ded1_nuke_cruisemissiles";
	level._scr_radio[ "roc_dra_nuke_fleetwideflashalarm" ] = "roc_dra_nuke_fleetwideflashalarm";
	level._scr_radio[ "roc_bak_nuke_shieldyoureyes" ] = "roc_bak_nuke_shieldyoureyes";
	level._scr_radio[ "roc_swi_nuke_cantsee" ] = "roc_swi_nuke_cantsee";
	level._scr_radio[ "roc_kee_nuke_holyshit" ] = "roc_kee_nuke_holyshit";
	level._scr_radio[ "roc_kee_nuke_thefleet" ] = "roc_kee_nuke_thefleet";
	level._scr_radio[ "roc_kee_nuke_theyrefuckinggone" ] = "roc_kee_nuke_theyrefuckinggone";
	level._scr_radio[ "roc_kee_nuke_seethatshit" ] = "roc_kee_nuke_seethatshit";
	level._scr_radio[ "roc_kee_nuke_holdon" ] = "roc_kee_nuke_holdon";
	level._scr_radio[ "roc_bak_nuke_getbackongun" ] = "roc_bak_nuke_getbackongun";
	level._scr_radio[ "roc_bak_nuke_getusthefuckoutofhere" ] = "roc_bak_nuke_getusthefuckoutofhere";
	level._scr_radio[ "roc_ded1_nuke_lostrotorcontrol" ] = "roc_ded1_nuke_lostrotorcontrol";
	level._scr_radio[ "roc_ded1_nuke_mayday" ] = "roc_ded1_nuke_mayday";
	level._scr_radio[ "roc_ded1_nuke_braceforimpact" ] = "roc_ded1_nuke_braceforimpact";
	level._scr_radio[ "roc_ec1_hang_luckyday" ] = "roc_ec1_hang_luckyday";
	level._scr_radio[ "roc_ec2_hang_whereareyourfriends" ] = "roc_ec2_hang_whereareyourfriends";
	level._scr_radio[ "roc_ec2_hang_deadman" ] = "roc_ec2_hang_deadman";
	level._scr_radio[ "roc_ec2_hang_grunt_01" ] = "roc_ec2_hang_grunt_01";
	level._scr_radio[ "roc_ec2_hang_grunt_02" ] = "roc_ec2_hang_grunt_02";
	level._scr_radio[ "roc_bac_misc_gridsixniner" ] = "roc_bac_misc_gridsixniner";
	level._scr_radio[ "roc_bac_misc_abortstrikertb" ] = "roc_bac_misc_abortstrikertb";
	level._scr_radio[ "roc_bac_misc_setangels10" ] = "roc_bac_misc_setangels10";
	level._scr_radio[ "roc_bac_misc_strobesconfirmed" ] = "roc_bac_misc_strobesconfirmed";
	level._scr_radio[ "roc_bac_misc_ghostflightreport" ] = "roc_bac_misc_ghostflightreport";
	level._scr_radio[ "roc_bac_misc_disengageturn65" ] = "roc_bac_misc_disengageturn65";
	level._scr_radio[ "roc_bac_misc_ghostacknowledge" ] = "roc_bac_misc_ghostacknowledge";
	level._scr_radio[ "roc_bac_misc_multbanditsinbound" ] = "roc_bac_misc_multbanditsinbound";
	level._scr_radio[ "roc_bac_misc_interceptfastmovers" ] = "roc_bac_misc_interceptfastmovers";
	level._scr_radio[ "roc_bac_misc_kingfishreport" ] = "roc_bac_misc_kingfishreport";
	level._scr_radio[ "roc_bac_misc_providealphasierra" ] = "roc_bac_misc_providealphasierra";
	level._scr_radio[ "roc_bac_misc_slingergotoready5" ] = "roc_bac_misc_slingergotoready5";
	level._scr_radio[ "roc_bac_misc_highballgoasw" ] = "roc_bac_misc_highballgoasw";
	level._scr_radio[ "roc_bac_misc_aegistracking" ] = "roc_bac_misc_aegistracking";
	level._scr_radio[ "roc_bak_intro_convoy2oclock" ] = "roc_bak_intro_convoy2oclock";
	level._scr_radio[ "roc_bak_intro_takeoutsa10" ] = "roc_bak_intro_takeoutsa10";
	level._scr_radio[ "roc_bak_intro_samlaunch" ] = "roc_bak_intro_samlaunch";
	level._scr_radio[ "roc_bak_intro_lightemup" ] = "roc_bak_intro_lightemup";
	level._scr_radio[ "roc_bak_intro_hammerdown" ] = "roc_bak_intro_hammerdown";
	level._scr_radio[ "roc_bak_intro_shortbursts" ] = "roc_bak_intro_shortbursts";
	level._scr_radio[ "roc_bak_intro_supressingfire" ] = "roc_bak_intro_supressingfire";
	level._scr_radio[ "roc_bak_intro_walkyourfirein" ] = "roc_bak_intro_walkyourfirein";
	level._scr_radio[ "roc_bak_alpha_launchseqinitiated" ] = "roc_bak_alpha_launchseqinitiated";
	level._scr_radio[ "roc_cro_alpha_launch30sec" ] = "roc_cro_alpha_launch30sec";
	level._scr_radio[ "roc_bak_alpha_punchthrough" ] = "roc_bak_alpha_punchthrough";
	level._scr_radio[ "roc_ded3_alpha_lookatsize" ] = "roc_ded3_alpha_lookatsize";
	level._scr_radio[ "roc_ded4_strobes350" ] = "roc_ded4_strobes350";
	level._scr_radio[ "roc_ded3_alpha_gadgetgold" ] = "roc_ded3_alpha_gadgetgold";
	level._scr_radio[ "roc_bak_alpha_incoming" ] = "roc_bak_alpha_incoming";
	level._scr_radio[ "roc_bak_alpha_straferooftops" ] = "roc_bak_alpha_straferooftops";
	level._scr_radio[ "roc_bak_alpha_rockets1oclock" ] = "roc_bak_alpha_rockets1oclock";
	level._scr_radio[ "roc_bak_alpha_apc2oclock" ] = "roc_bak_alpha_apc2oclock";
	level._scr_radio[ "roc_bak_alpha_gantrymovingtolaunch" ] = "roc_bak_alpha_gantrymovingtolaunch";
	level._scr_radio[ "roc_bak_alpha_launchimminent" ] = "roc_bak_alpha_launchimminent";
	level._scr_radio[ "roc_bak_alpha_hardkill" ] = "roc_bak_alpha_hardkill";
	level._scr_radio[ "roc_cro_alpha_mark" ] = "roc_cro_alpha_mark";
	level._scr_radio[ "roc_cro_alpha_payloadout" ] = "roc_cro_alpha_payloadout";
	level._scr_radio[ "roc_ded4_gadgetred" ] = "roc_ded4_gadgetred";
	level._scr_radio[ "roc_ded3_alpha_ded4isdown" ] = "roc_ded3_alpha_ded4isdown";
	level._scr_radio[ "roc_ded4_takingfire" ] = "roc_ded4_takingfire";
	level._scr_radio[ "roc_bak_alpha_ordnanceincoming" ] = "roc_bak_alpha_ordnanceincoming";
	level._scr_radio[ "roc_bak_alpha_roundincoming" ] = "roc_bak_alpha_roundincoming";
	level._scr_radio[ "roc_bak_alpha_hereitcomes" ] = "roc_bak_alpha_hereitcomes";
	level._scr_radio[ "roc_bak_alpha_railontheway" ] = "roc_bak_alpha_railontheway";
	level._scr_radio[ "roc_bak_alpha_gunsupzulu" ] = "roc_bak_alpha_gunsupzulu";
	level._scr_radio[ "roc_bak_alpha_takeittothedeck" ] = "roc_bak_alpha_takeittothedeck";
	level._scr_radio[ "roc_bak_alpha_checksix" ] = "roc_bak_alpha_checksix";
	level._scr_radio[ "roc_bak_alpha_ambush" ] = "roc_bak_alpha_ambush";
	level._scr_radio[ "roc_bak_alpha_bankleft" ] = "roc_bak_alpha_bankleft";
	level._scr_radio[ "roc_bak_alpha_affirmative" ] = "roc_bak_alpha_affirmative";
	level._scr_radio[ "roc_bak_alpha_lightarmor12oclock" ] = "roc_bak_alpha_lightarmor12oclock";
	level._scr_radio[ "roc_bak_alpha_wasteem" ] = "roc_bak_alpha_wasteem";
	level._scr_radio[ "roc_bak_alpha_chewemup" ] = "roc_bak_alpha_chewemup";
	level._scr_radio[ "roc_bak_alpha_maintaincontour" ] = "roc_bak_alpha_maintaincontour";
	level._scr_radio[ "roc_bak_alpha_targetcanopy" ] = "roc_bak_alpha_targetcanopy";
	level._scr_radio[ "roc_bak_alpha_takeemout" ] = "roc_bak_alpha_takeemout";
	level._scr_radio[ "roc_ded3_alpha_wherethefuck" ] = "roc_ded3_alpha_wherethefuck";
	level._scr_radio[ "roc_ded3_alpha_gettingpainted" ] = "roc_ded3_alpha_gettingpainted";
	level._scr_radio[ "roc_dra_alpha_zulu1report" ] = "roc_dra_alpha_zulu1report";
	level._scr_radio[ "roc_bak_alpha_stillinthefight" ] = "roc_bak_alpha_stillinthefight";
	level._scr_radio[ "roc_dra_alpha_turnforipdelta" ] = "roc_dra_alpha_turnforipdelta";
	level._scr_radio[ "roc_ded2_bridge_boogie12oclock" ] = "roc_ded2_bridge_boogie12oclock";
	level._scr_radio[ "roc_dra_delta_getyourasstotarget" ] = "roc_dra_delta_getyourasstotarget";
	level._scr_radio[ "roc_bak_delta_downtheirthroats" ] = "roc_bak_delta_downtheirthroats";
	level._scr_radio[ "roc_bak_delta_outoftime" ] = "roc_bak_delta_outoftime";
	level._scr_radio[ "roc_bak_delta_getustorocketnow" ] = "roc_bak_delta_getustorocketnow";
	level._scr_radio[ "roc_bak_delta_keeptheirheadsdown" ] = "roc_bak_delta_keeptheirheadsdown";
	level._scr_radio[ "roc_bak_delta_fireatwill" ] = "roc_bak_delta_fireatwill";
	level._scr_radio[ "roc_bak_delta_choppers12oclock" ] = "roc_bak_delta_choppers12oclock";
	level._scr_radio[ "roc_bak_delta_bandits4oclock" ] = "roc_bak_delta_bandits4oclock";
	level._scr_radio[ "roc_dra_delta_donotallowrockets" ] = "roc_dra_delta_donotallowrockets";
	level._scr_radio[ "roc_dra_delta_interceptin31" ] = "roc_dra_delta_interceptin31";
	level._scr_radio[ "roc_bak_delta_candlestick1islit" ] = "roc_bak_delta_candlestick1islit";
	level._scr_radio[ "roc_bak_delta_clearapath" ] = "roc_bak_delta_clearapath";
	level._scr_radio[ "roc_dra_delta_stoplaunchnow" ] = "roc_dra_delta_stoplaunchnow";
	level._scr_radio[ "roc_dra_delta_proceedtosecond" ] = "roc_dra_delta_proceedtosecond";
	level._scr_radio[ "roc_dra_delta_airbornin10sec" ] = "roc_dra_delta_airbornin10sec";
	level._scr_radio[ "roc_bak_delta_gogogo" ] = "roc_bak_delta_gogogo";
	level._scr_radio[ "roc_bak_delta_liftingoff" ] = "roc_bak_delta_liftingoff";
	level._scr_radio[ "roc_dra_delta_target3rdrocket" ] = "roc_dra_delta_target3rdrocket";
	level._scr_radio[ "roc_dra_delta_thehellisgoingon" ] = "roc_dra_delta_thehellisgoingon";
	level._scr_radio[ "roc_bak_delta_ignoredefenses" ] = "roc_bak_delta_ignoredefenses";
	level._scr_radio[ "roc_dra_delta_outoftime" ] = "roc_dra_delta_outoftime";
	level._scr_radio[ "roc_bak_delta_takeusup" ] = "roc_bak_delta_takeusup";
	level._scr_radio[ "roc_dra_delta_targetcandlestick3" ] = "roc_dra_delta_targetcandlestick3";
	level._scr_radio[ "roc_bak_delta_losinghim" ] = "roc_bak_delta_losinghim";
	level._scr_radio[ "roc_bak_delta_painttargetnow" ] = "roc_bak_delta_painttargetnow";
	level._scr_radio[ "roc_cro_delta_1sectoimpact" ] = "roc_cro_delta_1sectoimpact";
	level._scr_radio[ "roc_cro_delta_impact" ] = "roc_cro_delta_impact";
	level._scr_radio[ "roc_cro_delta_impactconfirm" ] = "roc_cro_delta_impactconfirm";
	level._scr_radio[ "roc_bak_delta_strkmissioncomplete" ] = "roc_bak_delta_strkmissioncomplete";
	level._scr_radio[ "roc_dra_delta_outstandingstandby" ] = "roc_dra_delta_outstandingstandby";
	level._scr_radio[ "roc_kee_hang_clear" ] = "roc_kee_hang_clear";
}

#using_animtree("player");
player()
{
	level._scr_animtree[ "player_rig" ]									= #animtree;
	level._scr_anim[ "player_rig" ][ "hanging_player_hang" ]			= %nx_fp_proto_rocket_hang;
	level._scr_anim[ "player_rig" ][ "hanging_player_fall" ]			= %nx_fp_proto_rocket_fall;
	level._scr_anim[ "player_rig" ][ "aa_control_melee" ] 				= %nx_fp_rocket_aa_control_melee_player;
	level._scr_anim[ "player_rig" ][ "aa_exit_melee" ] 					= %nx_fp_rocket_aa_control_exit_player;
	level._scr_anim[ "player_rig" ][ "aa_gantry_escape" ]				= %nx_fp_rocket_aa_gantry_escape_player;
	level._scr_anim[ "player_rig" ][ "hanging_wakeup" ] 				= %nx_fp_rocket_crash_site_wakeup_player;
	level._scr_anim[ "player_rig" ][ "hanging_cutdown" ]		 		= %nx_fp_rocket_crash_site_wakeup_cutdown_player;
	level._scr_anim[ "player_rig" ][ "crash_blackhawk" ] 				= %nx_fp_rocket_helicoptercrash_player_01;
	level._scr_anim[ "player_rig" ][ "witness_nuke" ] 					= %nx_fp_rocket_witness_nuke_player_01;
	level._scr_anim[ "player_rig" ][ "jump_onto_gantry" ] 				= %nx_fp_rocket_jump_onto_gantry_player_01;
	level._scr_anim[ "player_rig" ][ "aa_corridor_run_out_01" ]   		= %nx_fp_rocket_aa_corridor_player_01;
	level._scr_anim[ "player_rig" ][ "aa_corridor_run_out_02" ] 		= %nx_fp_rocket_aa_corridor_player_02;
	level._scr_anim[ "player_rig" ][ "woods_ledge_01" ] 				= %nx_fp_rocket_woods_ledge_player_01;
	level._scr_anim[ "player_rig" ][ "woods_chopper_fly_over" ] 		= %nx_fp_rocket_woods_chopperflyover_player_01;
	level._scr_model[ "player_rig" ] 									= "viewhands_player_us_army";

	//Intro player scene
	level._scr_animtree[ "player_rig" ] = #animtree;
	level._scr_anim[ "player_rig" ][ "intro_allies_in_chopper" ] = %nx_fp_rocket_intro_player_01;
	level._scr_model[ "player_rig" ] = "viewhands_player_us_army";

	// opfor helicopter intro
	level._scr_animtree[ "player_rig" ] = #animtree;
	level._scr_anim[ "player_rig" ][ "opfor_helicopter_intro" ] = %nx_fp_rocket_opfor_helicopter_intro_player;
	level._scr_model[ "player_rig" ] = "viewhands_player_us_army";

	//helicopter bridge
	level._scr_animtree[ "player_rig" ] = #animtree;
	level._scr_anim[ "player_rig" ][ "helicopter_bridge" ] = %nx_fp_rocket_helicopter_bridge_player;
	level._scr_model[ "player_rig" ] = "viewhands_player_us_army";
	addNotetrack_customFunction( "player_rig", "start_player_vignette", ::helicopter_bridge_player );

	//nuke and crash
	level._scr_animtree[ "player_rig" ] = #animtree;
	level._scr_anim[ "player_rig" ][ "nuke_and_crash" ] = %nx_fp_rocket_nuke_crash_player;
	level._scr_model[ "player_rig" ] = "viewhands_player_us_army";

	//aa_control_melee
	level._scr_animtree[ "player_rig" ] = #animtree;
	level._scr_anim[ "player_rig" ][ "aa_control_melee" ] = %nx_fp_rocket_aa_control_melee_player;
	level._scr_model[ "player_rig" ] = "viewhands_player_us_army";

	addNotetrack_customFunction( "player_rig", "loose_player_control", ::nuke_and_crash_player );
	addNotetrack_customFunction( "player_rig", "pov_change", ::nuke_and_crash_begin_fov_blend );
}

#using_animtree("script_model");
script_models()
{
	// Ocean
	// level._scr_animtree[ "ocean_idle" ] 							= #animtree;
	// level._scr_anim[ "ocean_idle" ][ "nx_rocket_ocean_idle_0" ] 	= %nx_rocket_ocean_idle_0;
	// level._scr_model[ "ocean_idle" ] 								= "nx_rocket_ocean_0";

	// First rocket explosion
	level._scr_animtree[ "rocket_one" ]								= #animtree;
	level._scr_anim[ "rocket_one" ][ "nx_pr_rocket_03_anim" ]		= %nx_pr_rocket_03_anim;
	level._scr_model[ "rocket_one" ]								= "nx_pr_rocket_03";

	// Opfor Heli Intro
	level._scr_animtree[ "opfor_heli_missile_01" ] = #animtree;
	level._scr_anim[ "opfor_heli_missile_01" ][ "opfor_helicopter_intro" ] = %nx_pr_rocket_opfor_helicopter_intro_missile_01;
	level._scr_model[ "opfor_heli_missile_01" ] = "projectile_hellfire_missile";
	addNotetrack_customFunction( "opfor_heli_missile_01", "heli_battle_first_missile", maps\nx_rocket_fx::heli_battle_first_missile );

	level._scr_animtree[ "opfor_heli_missile_02" ] = #animtree;
	level._scr_anim[ "opfor_heli_missile_02" ][ "opfor_helicopter_intro" ] = %nx_pr_rocket_opfor_helicopter_intro_missile_02;
	level._scr_model[ "opfor_heli_missile_02" ] = "projectile_hellfire_missile";
	addNotetrack_customFunction( "opfor_heli_missile_02", "heli_battle_second_missile", maps\nx_rocket_fx::heli_battle_second_missile );

	level._scr_animtree[ "player_turret_bridge" ] = #animtree;
	level._scr_anim[ "player_turret_bridge" ][ "opfor_helicopter_intro" ] = %nx_pr_rocket_opfor_helicopter_turret_player;
	level._scr_model[ "player_turret_bridge" ] = "weapon_blackhawk_minigun_turret";

	// helicopter bridge turret
	level._scr_animtree[ "heli_turret" ] = #animtree;
	level._scr_anim[ "heli_turret" ][ "helicopter_bridge" ] = %nx_pr_rocket_helicopter_bridge_turret_gunner;
	level._scr_model[ "heli_turret" ] = "weapon_blackhawk_minigun_turret";

	level._scr_animtree[ "player_turret" ] = #animtree;
	level._scr_anim[ "player_turret" ][ "helicopter_bridge" ] = %nx_pr_rocket_helicopter_bridge_turret_player;
	level._scr_model[ "player_turret" ] = "weapon_blackhawk_minigun_turret";

	level._scr_animtree[ "bridge_missile" ] = #animtree;
	level._scr_anim[ "bridge_missile" ][ "helicopter_bridge" ] = %nx_pr_rocket_helicopter_bridge_missile;
	level._scr_model[ "bridge_missile" ] = "projectile_hellfire_missile"; 



	// Generic Rocket explosion
	level._scr_animtree[ "rocket_shuttle_exp1_010" ]							= #animtree;
	level._scr_anim[ "rocket_shuttle_exp1_010" ][ "rocket_shuttle_exp1" ]	= %nx_pr_rocket_shuttle_exp1_010_anim;
	level._scr_model[ "rocket_shuttle_exp1_010" ]							= "nx_pr_rocket_shuttle_exp1_010";

	level._scr_animtree[ "turret_barrel" ]									= #animtree;
//  level._scr_anim[ "turret_barrel" ][ "rocket_shuttle_exp1" ]	= %nx_pr_rocket_shuttle_exp1_012_anim;
	level._scr_model[ "turret_barrel" ]										= "nx_ugv_main_turret";

	// First doors out of AA room
	level._scr_animtree[ "aa_exit_door_01" ] = #animtree;
	level._scr_anim[ "aa_exit_door_01" ][ "aa_exit_melee" ] = %nx_pr_rocket_aa_control_exit_door_01;
	level._scr_anim[ "aa_exit_door_01" ][ "aa_exitdoors" ] = %nx_pr_rocket_aa_control_exit_door_03;
	level._scr_model[ "aa_exit_door_01" ] = "nx_rocket_door_01";
	// Doors out of AA building
	level._scr_animtree[ "aa_exit_door_02" ] = #animtree;
	level._scr_anim[ "aa_exit_door_02" ][ "aa_exit_melee" ] = %nx_pr_rocket_aa_control_exit_door_02;
	level._scr_anim[ "aa_exit_door_02" ][ "aa_exitdoors" ] = %nx_pr_rocket_aa_control_exit_door_04;
	level._scr_model[ "aa_exit_door_02" ] = "nx_rocket_door_02";
	// Gangways
	level._scr_animtree[ "gantry_gangway_01" ] = #animtree;
	level._scr_model[ "gantry_gangway_01" ] = "nx_rocket_gangway_01";
	level._scr_anim[ "gantry_gangway_01" ][ "aa_gantry_escape" ] = %nx_pr_rocket_gantry_escape_gangway_01;
	level._scr_animtree[ "gantry_gangway_02" ] = #animtree;
	level._scr_model[ "gantry_gangway_02" ] = "nx_rocket_gangway_01";
	level._scr_anim[ "gantry_gangway_02" ][ "aa_gantry_escape" ] = %nx_pr_rocket_gantry_escape_gangway_02;
	level._scr_animtree[ "gantry_gangway_03" ] = #animtree;
	level._scr_model[ "gantry_gangway_03" ] = "nx_rocket_gangway_01";
	level._scr_anim[ "gantry_gangway_03" ][ "aa_gantry_escape" ] = %nx_pr_rocket_gantry_escape_gangway_03;
	// c4 on rocket
	level._scr_animtree[ "gantry_c4" ] = #animtree;
	level._scr_anim[ "gantry_c4" ][ "aa_gantry_escape" ] = %nx_pr_rocket_gantry_escape_c4;
	level._scr_model[ "gantry_c4" ] = "c4_script_model";

	// first person gun while hanging
	level._scr_animtree[ "hanging_gun" ] = #animtree;
	level._scr_anim[ "hanging_gun" ][ "hanging_wakeup" ] = %nx_pr_rocket_crash_site_wakeup_gun;
	level._scr_model[ "hanging_gun" ] = "nx_rocket_crash_wakeup_gunfp";
	// tree that you hit when you fall from chopper
	level._scr_animtree[ "hanging_tree" ] = #animtree;
	level._scr_anim[ "hanging_tree" ][ "hanging_cutdown" ] = %nx_pr_rocket_crash_site_cutdown_tree_01;
	level._scr_model[ "hanging_tree" ] = "nx_pr_rocket_crash_wakeup_cutdown_tree";
	// cable while hanging
	level._scr_animtree[ "hanging_cable_01" ] = #animtree;
	level._scr_anim[ "hanging_cable_01" ][ "hanging_wakeup" ] = %nx_pr_rocket_crash_site_wakeup_cable_01;
	level._scr_model[ "hanging_cable_01" ] = "nx_rocket_crash_rope_01";
	level._scr_animtree[ "hanging_cable_02" ] = #animtree;
	level._scr_anim[ "hanging_cable_02" ][ "hanging_wakeup" ] = %nx_pr_rocket_crash_site_wakeup_cable_02;
	level._scr_model[ "hanging_cable_02" ] = "nx_rocket_crash_rope_02";

	// tree in woods traversals 
	level._scr_animtree[ "woods_chopper_fly_over_tree" ] = #animtree;
	level._scr_anim[ "woods_chopper_fly_over_tree" ][ "woods_chopper_fly_over" ] = %nx_pr_rocket_woods_chopperflyover_tree_01;
	level._scr_model[ "woods_chopper_fly_over_tree" ] = "nx_pr_rocket_crash_wakeup_cutdown_tree";

	level._scr_animtree[ "hanging_chopper" ] = #animtree;
	level._scr_anim[ "hanging_chopper" ][ "hanging_cutdown" ] = %nx_pr_rocket_crash_site_crashedchopper_01;
	level._scr_model[ "hanging_chopper" ] = "nx_vehicle_blackhawk_minigun_crashed";

	level._scr_animtree[ "woods_trav_tree_02" ] = #animtree;
	level._scr_anim[ "woods_trav_tree_02" ][ "woods_traversal_02" ] = %nx_pr_rocket_woods_trav_tree_02;
	level._scr_model[ "woods_trav_tree_02" ] = "nx_pr_rocket_crash_wakeup_cutdown_tree";

	//AA Turret Shoot Helicopter
	level._scr_animtree[ "aa_turret_fire" ] = #animtree;
	level._scr_anim[ "aa_turret_fire" ][ "aa_turret_shoot_helicopter" ] = %nx_pr_rocket_aa_shoot_helicopter_down_turret;
	level._scr_model[ "aa_turret_fire" ] = "nx_pr_rocket_aa_turret";


	// nuke sighting and crash
	level._scr_animtree[ "nuke_crash_chopper1" ] = #animtree;
//  level._scr_anim[ "nuke_crash_chopper1" ][ "nuke_and_crash" ] = %nx_vh_rocket_nuke_crash_chopper1;
	level._scr_model[ "nuke_crash_chopper1" ] = "nx_vehicle_blackhawk_minigun_hero";

//  level._scr_animtree[ "nuke_crash_chopper2" ] = #animtree;
//  level._scr_anim[ "nuke_crash_chopper2" ][ "nuke_and_crash" ] = %nx_vh_rocket_nuke_crash_chopper2;
//  level._scr_model[ "nuke_crash_chopper2" ] = "nx_vehicle_blackhawk_minigun_hero";
//
//  level._scr_animtree[ "nuke_crash_chopper3" ] = #animtree;
//  level._scr_anim[ "nuke_crash_chopper3" ][ "nuke_and_crash" ] = %nx_vh_rocket_nuke_crash_chopper3;
//  level._scr_model[ "nuke_crash_chopper3" ] = "nx_vehicle_blackhawk_minigun_hero";

	level._scr_animtree[ "nuke_crash_missile1" ] = #animtree;
	level._scr_anim[ "nuke_crash_missile1" ][ "nuke_and_crash" ] = %nx_pr_rocket_nuke_crash_nuke1;
	level._scr_model[ "nuke_crash_missile1" ] = "nx_pr_rocket_witness_nuke_missile";

	level._scr_animtree[ "nuke_crash_missile2" ] = #animtree;
	level._scr_anim[ "nuke_crash_missile2" ][ "nuke_and_crash" ] = %nx_pr_rocket_nuke_crash_nuke2;
	level._scr_model[ "nuke_crash_missile2" ] = "nx_pr_rocket_witness_nuke_missile";

	level._scr_animtree[ "nuke_crash_missile3" ] = #animtree;
	level._scr_anim[ "nuke_crash_missile3" ][ "nuke_and_crash" ] = %nx_pr_rocket_nuke_crash_nuke3;
	level._scr_model[ "nuke_crash_missile3" ] = "nx_pr_rocket_witness_nuke_missile";

	level._scr_animtree[ "nuke_crash_missile_4" ] = #animtree;
	level._scr_anim[ "nuke_crash_missile_4" ][ "nuke_and_crash" ] = %nx_pr_rocket_nuke_crash_nuke4;
	level._scr_model[ "nuke_crash_missile_4" ] = "nx_pr_rocket_witness_nuke_missile";

	level._scr_animtree[ "nuke_crash_missile5" ] = #animtree;
	level._scr_anim[ "nuke_crash_missile5" ][ "nuke_and_crash" ] = %nx_pr_rocket_nuke_crash_nuke5;
	level._scr_model[ "nuke_crash_missile5" ] = "nx_pr_rocket_witness_nuke_missile";

	level._scr_animtree[ "nuke_crash_missile6" ] = #animtree;
	level._scr_anim[ "nuke_crash_missile6" ][ "nuke_and_crash" ] = %nx_pr_rocket_nuke_crash_nuke6;
	level._scr_model[ "nuke_crash_missile6" ] = "nx_pr_rocket_witness_nuke_missile";

	// 6 missiles that nuke our ships
	level._scr_animtree[ "crash_nuke_missile_01" ] = #animtree;
	level._scr_model[ "crash_nuke_missile_01" ] = "nx_pr_rocket_witness_nuke_missile";
	level._scr_anim[ "crash_nuke_missile_01" ][ "witness_nuke" ] = %nx_pr_rocket_witness_nuke_missile_01;
	level._scr_animtree[ "crash_nuke_missile_02" ] = #animtree;
	level._scr_model[ "crash_nuke_missile_02" ] = "nx_pr_rocket_witness_nuke_missile";
	level._scr_anim[ "crash_nuke_missile_02" ][ "witness_nuke" ] = %nx_pr_rocket_witness_nuke_missile_02;
	level._scr_animtree[ "crash_nuke_missile_03" ] = #animtree;
	level._scr_model[ "crash_nuke_missile_03" ] = "nx_pr_rocket_witness_nuke_missile";
	level._scr_anim[ "crash_nuke_missile_03" ][ "witness_nuke" ] = %nx_pr_rocket_witness_nuke_missile_03;
	level._scr_animtree[ "crash_nuke_missile_04" ] = #animtree;
	level._scr_model[ "crash_nuke_missile_04" ] = "nx_pr_rocket_witness_nuke_missile";
	level._scr_anim[ "crash_nuke_missile_04" ][ "witness_nuke" ] = %nx_pr_rocket_witness_nuke_missile_04;
	level._scr_animtree[ "crash_nuke_missile_05" ] = #animtree;
	level._scr_model[ "crash_nuke_missile_05" ] = "nx_pr_rocket_witness_nuke_missile";
	level._scr_anim[ "crash_nuke_missile_05" ][ "witness_nuke" ] = %nx_pr_rocket_witness_nuke_missile_05;
	level._scr_animtree[ "crash_nuke_missile_06" ] = #animtree;
	level._scr_model[ "crash_nuke_missile_06" ] = "nx_pr_rocket_witness_nuke_missile";
	level._scr_anim[ "crash_nuke_missile_06" ][ "witness_nuke" ] = %nx_pr_rocket_witness_nuke_missile_06;

	// control room exit doors
	level._scr_animtree[ "control_room_exit_door_01" ] = #animtree;
	level._scr_anim[ "control_room_exit_door_01" ][ "aa_control_room_doors" ] = %nx_pr_rocket_aa_control_exit_door_01;
	level._scr_model[ "control_room_exit_door_01" ] = "nx_rocket_door_01";

	level._scr_animtree[ "control_room_exit_door_02" ] = #animtree;
	level._scr_anim[ "control_room_exit_door_02" ][ "aa_control_room_doors" ] = %nx_pr_rocket_aa_control_exit_door_02;
	level._scr_model[ "control_room_exit_door_02" ] = "nx_rocket_door_02";

	// Rocket 2 explosion - rocket in air
	level._scr_animtree[ "rocket_explosion_02" ] = #animtree;
	level._scr_anim[ "rocket_explosion_02" ][ "rocket_explosion_02" ] = %nx_pr_rocket_explosion_02_anim;
	level._scr_model[ "rocket_explosion_02" ] = "nx_pr_rocket_explosion_02";

	//exploding wall just before exit aa control building
	level._scr_animtree[ "aa_corridor_wall_model" ] = #animtree;
	level._scr_anim[ "aa_corridor_wall_model" ][ "aa_corridor_wall_01" ] = %nx_pr_rocket_aa_corridor_wall_anim;
	level._scr_model[ "aa_corridor_wall_model" ] = "nx_pr_rocket_aa_corridor_wall";

	//tree in woods_trav_williams_01
	level._scr_animtree[ "woods_trav_tree_01" ] = #animtree;
	level._scr_anim[ "woods_trav_tree_01" ][ "woods_traversals_01" ] = %nx_pr_rocket_woods_trav_tree_01;
	level._scr_model[ "woods_trav_tree_01" ] = "nx_pr_rocket_crash_wakeup_cutdown_tree";

	//Intro chopper miniguns
	level._scr_animtree[ "minigun_right" ] = #animtree;
	level._scr_anim[ "minigun_right" ][ "intro_allies_in_chopper" ] = %nx_pr_rocket_intro_minigun_right;
	level._scr_model[ "minigun_right" ] = "weapon_blackhawk_minigun_turret";

	level._scr_animtree[ "minigun_left" ] = #animtree;
	level._scr_anim[ "minigun_left" ][ "intro_allies_in_chopper" ] = %nx_pr_rocket_intro_minigun_left;
	level._scr_model[ "minigun_left" ] = "weapon_blackhawk_minigun_turret";

	//Gantry Arms
	level._scr_animtree[ "gantry_hose_01" ] = #animtree;
	level._scr_anim[ "gantry_hose_01" ][ "gantry_arms_hose_01" ] = %nx_pr_rocket_gantry_arms_01;
	level._scr_model[ "gantry_hose_01" ] = "nx_pr_rocket_hose";

	level._scr_animtree[ "gantry_arms_01" ] = #animtree;
	level._scr_anim[ "gantry_arms_01" ][ "gantry_arms_hose_01" ] = %nx_pr_rocket_gantry_arms_01a;
	level._scr_model[ "gantry_arms_01" ] = "nx_pr_rocket_gantry";

	level._scr_animtree[ "gantry_arms_02" ] = #animtree;
	level._scr_anim[ "gantry_arms_02" ][ "gantry_arms_hose_01" ] = %nx_pr_rocket_gantry_arms_01b;
	level._scr_model[ "gantry_arms_02" ] = "nx_pr_rocket_gantry2";

	//AA Control Melee
	level._scr_animtree[ "aa_control_door_01" ] = #animtree;
	level._scr_anim[ "aa_control_door_01" ][ "aa_control_melee" ] = %nx_pr_rocket_aa_control_melee_door_01;
	level._scr_model[ "aa_control_door_01" ] = "furniture_metal_door01_handleright";

	level._scr_animtree[ "aa_control_door_02" ] = #animtree;
	level._scr_anim[ "aa_control_door_02" ][ "aa_control_melee" ] = %nx_pr_rocket_aa_control_melee_door_02;
	level._scr_model[ "aa_control_door_02" ] = "furniture_metal_door01_handleright";

	level._scr_animtree[ "blackhawk_turret1" ] = #animtree;
	level._scr_model[ "blackhawk_turret1" ] = "weapon_blackhawk_minigun_turret";
	level._scr_anim[ "blackhawk_turret1" ][ "nuke_and_crash" ] = %nx_pr_rocket_nuke_crash_turret1;

	level._scr_animtree[ "blackhawk_turret2" ] = #animtree;
	level._scr_model[ "blackhawk_turret2" ] = "weapon_blackhawk_minigun_turret";
	level._scr_anim[ "blackhawk_turret2" ][ "nuke_and_crash" ] = %nx_pr_rocket_nuke_crash_turret2;

	//EC_VTOL Breakapart
	level._scr_animtree[ "ec_vtol_destroyed" ] = #animtree;
	level._scr_anim[ "ec_vtol_destroyed" ][ "ec_vtol_breakapart" ] = %nx_vh_rocket_ec_vtol_breakapart;
	level._scr_model[ "ec_vtol_destroyed" ] = "nx_vehicle_chinese_vtol_destroy";

	level._scr_animtree[ "blackhawk_01" ] = #animtree;
	level._scr_anim[ "blackhawk_01" ][ "opfor_helicopter_intro" ] = %nx_vh_rocket_opfor_helicopter_intro_ally_heli;
	level._scr_model[ "blackhawk_01" ] = "tag_origin";
	addNotetrack_customFunction( "blackhawk_01", "heli_battle_countermeasures", maps\nx_rocket_fx::heli_battle_countermeasures );
	addNotetrack_customFunction( "blackhawk_01", "heli_battle_missile_hit", maps\nx_rocket_fx::heli_battle_missile_hit );
	addNotetrack_customFunction( "blackhawk_01", "heli_battle_heli_crash", maps\nx_rocket_fx::heli_battle_heli_crash );

	level._scr_animtree[ "blackhawk_02" ] = #animtree;
	level._scr_anim[ "blackhawk_02" ][ "opfor_helicopter_intro" ] = %nx_vh_rocket_opfor_helicopter_intro_player_heli;
	level._scr_model[ "blackhawk_02" ] = "tag_origin";
	
	level._scr_animtree[ "blackhawk_player" ] = #animtree;
	level._scr_anim[ "blackhawk_player" ][ "nuke_and_crash" ] = %nx_vh_rocket_nuke_crash_chopper1;
	level._scr_model[ "blackhawk_player" ] = "tag_origin";

	level._scr_animtree[ "helicopter_ally" ] = #animtree;
	level._scr_anim[ "helicopter_ally" ][ "helicopter_bridge" ] = %nx_vh_rocket_helicopter_bridge_player_heli;
	level._scr_model[ "helicopter_ally" ] = "tag_origin";
	addNotetrack_customFunction( "helicopter_ally", "bridge_ai_start", maps\nx_rocket_section_bridge::rpg_guys_attempt_escape );

}

#using_animtree("vehicles");
vehicles()
{
	level._scr_anim[ "nuke_crash_chopper2" ][ "nuke_and_crash" ] = %nx_vh_rocket_nuke_crash_chopper2;
	level._scr_anim[ "nuke_crash_chopper3" ][ "nuke_and_crash" ] = %nx_vh_rocket_nuke_crash_chopper3;

	level._scr_anim[ "blackhawk_player" ][ "crash_blackhawk" ] 	= %nx_vh_rocket_helicoptercrash_helicopter_01;
	level._scr_anim[ "blackhawk_tp" ][ "crash_blackhawk" ] 		= %nx_vh_rocket_helicoptercrash_helicopter_02;
	level._scr_anim[ "blackhawk_player" ][ "witness_nuke" ] 	= %nx_vh_rocket_witness_nuke_helicpoter_01;
	level._scr_anim[ "littlebird_jump_onto_gantry" ][ "jump_onto_gantry" ] = %nx_vh_rocket_jump_onto_gantry_littlebird_01;
	level._scr_anim[ "littlebird_jump_onto_gantry" ][ "climb_onto_littlebird" ] = %nx_vh_rocket_climb_onto_littlebird_littlebird_01;
	level._scr_anim[ "woods_chopper_fly_over_blackhawk" ][ "woods_chopper_fly_over" ] = %nx_vh_rocket_woods_chopperflyover_blackhawk_01;
	level._scr_anim[ "woods_chopper_fly_over_blackhawk" ][ "chopper_battle_base_delta_01" ] = %nx_vh_rocket_chopper_btl_delta_blackhawk_01;
	level._scr_anim[ "rocket_basic_hind" ][ "chopper_battle_base_delta_01" ] = %nx_vh_rocket_chopper_btl_delta_blackhind_02;

	level._scr_anim[ "player_chopper" ][ "intro_choppers" ] = %nx_vh_rocket_intro_helicopter_player_01;
	level._scr_anim[ "chopper_formation_01" ][ "intro_choppers" ] = %nx_vh_rocket_intro_helicopter_01;
	level._scr_anim[ "chopper_formation_02" ][ "intro_choppers" ] = %nx_vh_rocket_intro_helicopter_02;
	level._scr_anim[ "chopper_formation_03" ][ "intro_choppers" ] = %nx_vh_rocket_intro_helicopter_03;
	level._scr_anim[ "chopper_formation_04" ][ "intro_choppers" ] = %nx_vh_rocket_intro_helicopter_04;
	level._scr_anim[ "chopper_formation_05" ][ "intro_choppers" ] = %nx_vh_rocket_intro_helicopter_05;
	level._scr_anim[ "chopper_formation_06" ][ "intro_choppers" ] = %nx_vh_rocket_intro_helicopter_06;
	level._scr_anim[ "chopper_formation_07" ][ "intro_choppers" ] = %nx_vh_rocket_intro_helicopter_07;
	level._scr_anim[ "chopper_formation_08" ][ "intro_choppers" ] = %nx_vh_rocket_intro_helicopter_08;
	level._scr_anim[ "bomber_01" ][ "intro_choppers" ] = %nx_vh_rocket_intro_Bomber_01;
	level._scr_anim[ "bomber_02" ][ "intro_choppers" ] = %nx_vh_rocket_intro_Bomber_02;
	level._scr_anim[ "bomber_03" ][ "intro_choppers" ] = %nx_vh_rocket_intro_Bomber_03;
	level._scr_anim[ "bomber_04" ][ "intro_choppers" ] = %nx_vh_rocket_intro_Bomber_04;

	// opfor helicopter intro
	level._scr_anim[ "opfor_heli_02" ][ "opfor_helicopter_intro" ] = %nx_vh_rocket_opfor_helicopter_intro_opfor_heli_02;
	level._scr_anim[ "opfor_heli_01" ][ "opfor_helicopter_intro" ] = %nx_vh_rocket_opfor_helicopter_intro_opfor_heli_01;
	//addNotetrack_customFunction( "blackhawk_02", "start_player_anim", ::opfor_helicopter_intro_begin_fp_vignette );	
	addNotetrack_customFunction( "opfor_heli_01", "heli_battle_first_missile_launch_fx", maps\nx_rocket_fx::heli_battle_first_missile_launch_fx );
	addNotetrack_customFunction( "opfor_heli_01", "heli_battle_first_missile_launch_02_fx", maps\nx_rocket_fx::heli_battle_first_missile_launch_02_fx );

	// helicopter bridge
	level._scr_anim[ "helicopter_opfor" ][ "helicopter_bridge" ] = %nx_vh_rocket_helicopter_bridge_opfor_heli;

	//Chopper battle base delta 02
	level._scr_anim[ "chopper_battle_base_delta_bh_02" ][ "chopper_battle_base_delta_02" ] = %nx_vh_rocket_chopper_btl_delta_blackhawk_02;

	//Chopper battle base delta 03
	level._scr_anim[ "chopper_battle_delta_bh_03" ][ "chopper_battle_base_delta_03" ] = %nx_vh_rocket_chopper_btl_delta_blackhawk_03;
	level._scr_anim[ "chopper_battle_delta_lb_02" ][ "chopper_battle_base_delta_03" ] = %nx_vh_rocket_chopper_btl_delta_ltlbrd_01;
	level._scr_anim[ "chopper_battle_delta_lb_03" ][ "chopper_battle_base_delta_03" ] = %nx_vh_rocket_chopper_btl_delta_ltlbrd_02;

	//Chopper battle base delta 04
	level._scr_anim[ "chopper_battle_delta_bh_03" ][ "chopper_battle_base_delta_04" ] = %nx_vh_rocket_chopper_btl_delta_blackhawk_04;

	//Chopper battle base delta 05
	level._scr_anim[ "chopper_battle_delta_bh_03" ][ "chopper_battle_base_delta_05" ] = %nx_vh_rocket_chopper_btl_delta_blackhawk_05;

	//Chopper dogfight 01
	level._scr_anim[ "delta_01_player_heli" ][ "chopper_dogfight_base_delta_01" ] = %nx_vh_rocket_base_delta_01_player_heli;
	level._scr_anim[ "delta_01_ally_heli" ][ "chopper_dogfight_base_delta_01" ] = %nx_vh_rocket_base_delta_01_ally_heli;
	level._scr_anim[ "delta_01_opfor_heli_02" ][ "chopper_dogfight_base_delta_01" ] = %nx_vh_rocket_base_delta_01_opfor_heli;
	level._scr_anim[ "delta_01_opfor_heli_01" ][ "chopper_dogfight_base_delta_01" ] = %nx_vh_rocket_base_delta_01_opfor_heli_02;

	//Chopper dogfight 02
	level._scr_anim[ "chopper_dogfight_base_delta_bh_02" ][ "chopper_dogfight_base_delta_02" ] = %nx_vh_rocket_chopper_dogfight_delta_blackhawk_01;
	level._scr_anim[ "chopper_dogfight_base_delta_hind_02" ][ "chopper_dogfight_base_delta_02" ] = %nx_vh_rocket_chopper_dogfight_delta_opfor_01;
	level._scr_anim[ "chopper_dogfight_base_delta_hind_02a" ][ "chopper_dogfight_base_delta_02" ] = %nx_vh_rocket_chopper_dogfight_delta_opfor_02;

	//AA Turret Shoot Helicopter
	level._scr_anim[ "nx_blackhawk_shot_down" ][ "aa_turret_shoot_helicopter" ] = %nx_vh_rocket_aa_shoot_helicopter_down_heli;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

link_preexisting_helicopter_to_vignette( link_target )
{
	wait 0.05;

	//link_target thread blend_target_box();
	
	Vehicle_StopPath( self );
	self LinkToBlendToTag( link_target, undefined, false, false );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/#
blend_target_box()
{
	self endon( "death" );
	while ( true )
	{
		Box( self.origin );
		wait 0.05;
	}
}
#/

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// aa_control_melee
aa_control_melee_spawn()
{
	level notify( "stop_turret_outdoor_sfx" );
	aa_control_melee_williams = vignette_actor_spawn("aa_control_melee_williams", "aa_control_melee_williams"); //"value" (kvp), "anim_name"
	aa_control_melee_opfor = vignette_actor_spawn("aa_control_melee_opfor", "aa_control_melee_opfor"); //"value" (kvp), "anim_name"

	aa_control_melee(aa_control_melee_williams, aa_control_melee_opfor);

	aa_control_melee_williams vignette_actor_delete();
	aa_control_melee_opfor vignette_actor_delete();
}

aa_control_melee(aa_control_melee_williams, aa_control_melee_opfor)
{

	node = getstruct("vignette_rocket_aa_control_melee", "script_noteworthy");

	level._player HideViewModel();
	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["aa_control_melee_williams"] = aa_control_melee_williams;
	guys["aa_control_melee_opfor"] = aa_control_melee_opfor;
	guys["player_rig"] = player_rig;

	arc = 15;

	node anim_reach_solo( aa_control_melee_williams, "aa_control_melee" );

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1 );

	node anim_single(guys, "aa_control_melee");

	aa_control_melee_opfor vignette_actor_kill();

	level._player unlink();

	player_rig delete();

	level._player ShowViewModel( );
	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// AA Exit Melee
aa_exit_melee_spawn()
{
	aa_control_exit_williams_01 = vignette_actor_spawn("aa_control_exit_williams_01", "aa_control_exit_williams_01"); //"value" (kvp), "anim_name"

	aa_exit_melee(aa_control_exit_williams_01);

	aa_control_exit_williams_01 vignette_actor_delete();
}

aa_exit_melee(door_01, door_02, aa_control_exit_williams_01)
{

	node = getstruct("vignette_rocket_aa_exit_melee_01", "script_noteworthy");

//  aa_exit_door_01 = spawn_anim_model("aa_exit_door_01");
//
//  aa_exit_door_02 = spawn_anim_model("aa_exit_door_02");

	level._player HideViewModel();
	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["aa_control_exit_williams_01"] = aa_control_exit_williams_01;
	guys["player_rig"] = player_rig;
	guys["aa_exit_door_01"] = door_01;
	guys["aa_exit_door_02"] = door_02;

	arc = 15;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "aa_exit_melee");

	level._player unlink();

	player_rig delete();

	level._player ShowViewModel( );
	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// AA Exit Doors
aa_exitdoors_spawn()
{
	aa_control_exitdoors_williams_01 = vignette_actor_spawn("aa_control_exitdoors_williams_01", "aa_control_exitdoors_williams_01"); //"value" (kvp), "anim_name"

	aa_exitdoors(aa_control_exitdoors_williams_01);

	aa_control_exitdoors_williams_01 vignette_actor_delete();
}

aa_exitdoors(door_01, door_02, ally_jenkins)
{

	node = getstruct("vignette_rocket_aa_exitdoors", "script_noteworthy");

	door_01 = spawn_anim_model("aa_exit_door_01");

	door_02 = spawn_anim_model("aa_exit_door_02");


	guys = [];
	guys["aa_control_exitdoors_williams_01"] = ally_jenkins;
	guys["aa_exit_door_01"] = door_01;
	guys["aa_exit_door_02"] = door_02;

	node anim_reach_solo(ally_jenkins, "aa_exitdoors");
	node anim_single(guys, "aa_exitdoors");
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// AA Gantry Escape
aa_gantry_escape_spawn()
{

	aa_gantry_escape();

}

aa_gantry_escape()
{
	// Starting anim
	level notify( "gantry_attack_c4_placed" );

	node = getstruct("vignette_rocket_aa_gantry_escape", "script_noteworthy");

	gantry_gangway_01 = spawn_anim_model("gantry_gangway_01");
	gantry_gangway_02 = spawn_anim_model("gantry_gangway_02");
	gantry_gangway_03 = spawn_anim_model("gantry_gangway_03");
	gantry_c4 = spawn_anim_model("gantry_c4");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["gantry_gangway_01"] = gantry_gangway_01;
	guys["gantry_gangway_02"] = gantry_gangway_02;
	guys["gantry_gangway_03"] = gantry_gangway_03;
	guys["player_rig"] = player_rig;
	guys["gantry_c4"] = gantry_c4;

	arc = 15;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "aa_gantry_escape");

	// Anim is done
	level notify( "gantry_attack_swing_arm_done" );

	// Show the final gantry animated swing arm
	swing_arm_bits = GetEntArray( "final_gantry_arm_extended", "targetname" );
	foreach( bit in swing_arm_bits )
	{
		bit show();
	}

	// Hide the original arm attached to the rocket
	swing_arm_bits = GetEntArray( "final_gantry_arm_on_missile", "targetname" );
	foreach( bit in swing_arm_bits )
	{
		bit hide();
	}

	level._player unlink();

	gantry_c4 delete();
	gantry_gangway_01 delete();
	gantry_gangway_02 delete();
	gantry_gangway_03 delete();
	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

	flag_set( "gantry_arm_anim_done" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// rocket_crash_site_wakeup_allyshot
crash_site_wakeup_allyshot_spawn()
{
	crash_wakeup_allyshot_jenkins = vignette_actor_spawn("crash_wakeup_allyshot_jenkins", "crash_wakeup_allyshot_jenkins"); //"value" (kvp), "anim_name"
	crash_wakeup_allyshot_opfor_01 = vignette_actor_spawn("crash_wakeup_allyshot_opfor_01", "crash_wakeup_allyshot_opfor_01"); //"value" (kvp), "anim_name"
	crash_wakeup_allyshot_opfor_02 = vignette_actor_spawn("crash_wakeup_allyshot_opfor_02", "crash_wakeup_allyshot_opfor_02"); //"value" (kvp), "anim_name"
	crash_wakeup_allyshot_opfor_03 = vignette_actor_spawn("crash_wakeup_allyshot_opfor_03", "crash_wakeup_allyshot_opfor_03"); //"value" (kvp), "anim_name"

	crash_site_wakeup_allyshot(crash_wakeup_allyshot_jenkins, crash_wakeup_allyshot_opfor_01, crash_wakeup_allyshot_opfor_02, crash_wakeup_allyshot_opfor_03);

	crash_wakeup_allyshot_jenkins vignette_actor_delete();
	crash_wakeup_allyshot_opfor_01 vignette_actor_delete();
	crash_wakeup_allyshot_opfor_02 vignette_actor_delete();
	crash_wakeup_allyshot_opfor_03 vignette_actor_delete();
}

crash_site_wakeup_allyshot(crash_wakeup_allyshot_jenkins, crash_wakeup_allyshot_opfor_01, crash_wakeup_allyshot_opfor_02, crash_wakeup_allyshot_opfor_03)
{

	node = getstruct("vignette_crash_site_wakeup_allyshot", "script_noteworthy");


	guys = [];
	guys["crash_wakeup_allyshot_jenkins"] = crash_wakeup_allyshot_jenkins;
	guys["crash_wakeup_allyshot_opfor_01"] = crash_wakeup_allyshot_opfor_01;
	guys["crash_wakeup_allyshot_opfor_02"] = crash_wakeup_allyshot_opfor_02;
	guys["crash_wakeup_allyshot_opfor_03"] = crash_wakeup_allyshot_opfor_03;

	node anim_single(guys, "crash_site_wakeup_allyshot");

}

hanging_interrogation(crash_wakeup_allyshot_jenkins, crash_wakeup_allyshot_opfor_01, crash_wakeup_allyshot_opfor_02, crash_wakeup_allyshot_opfor_03)
{

	node = getstruct("vignette_crash_site_wakeup_allyshot", "script_noteworthy");


	guys = [];
	guys["crash_wakeup_allyshot_jenkins"] = crash_wakeup_allyshot_jenkins;
	guys["crash_wakeup_allyshot_opfor_01"] = crash_wakeup_allyshot_opfor_01;
	guys["crash_wakeup_allyshot_opfor_02"] = crash_wakeup_allyshot_opfor_02;
	guys["crash_wakeup_allyshot_opfor_03"] = crash_wakeup_allyshot_opfor_03;

	node anim_single(guys, "hanging_interrogation");
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// rocket_crash_site_wakeup_allydive
crash_site_wakeup_allydive_spawn()
{
	crash_wakeup_allydive_jenkins = vignette_actor_spawn("crash_wakeup_allydive_jenkins", "crash_wakeup_allydive_jenkins"); //"value" (kvp), "anim_name"
	crash_wakeup_allydive_opfor_01 = vignette_actor_spawn("crash_wakeup_allydive_opfor_01", "crash_wakeup_allydive_opfor_01"); //"value" (kvp), "anim_name"

	crash_site_wakeup_allydive(crash_wakeup_allydive_jenkins, crash_wakeup_allydive_opfor_01);

	crash_wakeup_allydive_jenkins vignette_actor_delete();
	crash_wakeup_allydive_opfor_01 vignette_actor_delete();
}

crash_site_wakeup_allydive(crash_wakeup_allydive_jenkins, crash_wakeup_allydive_opfor_01)
{

	node = getstruct("vignette_crash_site_wakeup_allydive", "script_noteworthy");


	guys = [];
	guys["crash_wakeup_allydive_jenkins"] = crash_wakeup_allydive_jenkins;
	guys["crash_wakeup_allydive_opfor_01"] = crash_wakeup_allydive_opfor_01;

	node anim_single(guys, "crash_site_wakeup_allydive");
}

hanging_struggle(crash_wakeup_allydive_jenkins, crash_wakeup_allydive_opfor_01)
{

	node = getstruct("vignette_crash_site_wakeup_allydive", "script_noteworthy");


	guys = [];
	guys["crash_wakeup_allydive_jenkins"] = crash_wakeup_allydive_jenkins;
	guys["crash_wakeup_allydive_opfor_01"] = crash_wakeup_allydive_opfor_01;

	node anim_single(guys, "hanging_struggle");

	enemy = guys["crash_wakeup_allydive_opfor_01"];
	enemy vignette_actor_kill();
//  enemy StopAnimScripted();
//  enemy.allowDeath = true;
//  enemy Kill();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// rocket_crash_site_wakeup_allyshotb
crash_site_wakeup_allyshotb_spawn()
{
	crash_wakeup_allyshot_jenkins = vignette_actor_spawn("crash_wakeup_allyshot_jenkins", "crash_wakeup_allyshot_jenkins"); //"value" (kvp), "anim_name"
	crash_wakeup_allyshot_opfor_03 = vignette_actor_spawn("crash_wakeup_allyshot_opfor_03", "crash_wakeup_allyshot_opfor_03"); //"value" (kvp), "anim_name"

	crash_site_wakeup_allyshotb(crash_wakeup_allyshot_jenkins, crash_wakeup_allyshot_opfor_03);

	crash_wakeup_allyshot_jenkins vignette_actor_delete();
	crash_wakeup_allyshot_opfor_03 vignette_actor_delete();
}

crash_site_wakeup_allyshotb(crash_wakeup_allyshot_jenkins, crash_wakeup_allyshot_opfor_03)
{

	node = getstruct("vignette_crash_site_wakeup_allyshot", "script_noteworthy");


	guys = [];
	guys["crash_wakeup_allyshot_jenkins"] = crash_wakeup_allyshot_jenkins;
	guys["crash_wakeup_allyshot_opfor_03"] = crash_wakeup_allyshot_opfor_03;

	node anim_single(guys, "crash_site_wakeup_allyshotb");

}

hanging_execution(crash_wakeup_allyshot_jenkins, crash_wakeup_allyshot_opfor_03)
{

	node = getstruct("vignette_crash_site_wakeup_allyshot", "script_noteworthy");


	guys = [];
	guys["crash_wakeup_allyshot_jenkins"] = crash_wakeup_allyshot_jenkins;
	guys["crash_wakeup_allyshot_opfor_03"] = crash_wakeup_allyshot_opfor_03;

	node anim_single(guys, "hanging_execution");

	guys["crash_wakeup_allyshot_jenkins"] vignette_actor_kill();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// rocket_crash_site_wakeup
crash_site_wakeup_spawn()
{
	crash_wakeup_ally = vignette_actor_spawn("crash_wakeup_ally", "crash_wakeup_ally"); //"value" (kvp), "anim_name"
	wakeup_player_legs = vignette_actor_spawn("wakeup_player_legs", "wakeup_player_legs"); //"value" (kvp), "anim_name"

	crash_site_wakeup(crash_wakeup_ally, wakeup_player_legs);

	crash_wakeup_ally vignette_actor_delete();
	wakeup_player_legs vignette_actor_delete();
}

crash_site_wakeup(crash_wakeup_ally )
{

	node = getstruct("vignette_crash_site_wakeup_allyshot", "script_noteworthy");

	hanging_gun = spawn_anim_model("hanging_gun");
	wakeup_player_legs = vignette_actor_spawn("wakeup_player_legs", "wakeup_player_legs"); //"value" (kvp), "anim_name"

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["crash_wakeup_ally"] = crash_wakeup_ally;
	guys["wakeup_player_legs"] = wakeup_player_legs;
	guys["player_rig"] = player_rig;
	guys["hanging_gun"] = hanging_gun;

	arc = 15;

	//level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "crash_site_wakeup");

	level._player unlink();

	player_rig delete();
	wakeup_player_legs vignette_actor_delete();
	hanging_gun Delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

}

hanging_wakeup(player_rig, crash_wakeup_ally)
{
	node = getstruct("vignette_crash_site_wakeup_allyshot", "script_noteworthy");

	hanging_cable_01 = spawn_anim_model("hanging_cable_01");
	hanging_cable_02 = spawn_anim_model("hanging_cable_02");

	hanging_gun = spawn_anim_model("hanging_gun");
	wakeup_player_legs = vignette_actor_spawn("wakeup_player_legs", "hanging_player_legs"); //"value" (kvp), "anim_name"
	wakeup_player_legs.script_friendname = "";

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

//  player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["crash_wakeup_ally"] = crash_wakeup_ally;
	guys["wakeup_player_legs"] = wakeup_player_legs;
	guys["player_rig"] = player_rig;
	guys["hanging_gun"] = hanging_gun;
	guys["hanging_cable_01"] = hanging_cable_01;
	guys["hanging_cable_02"] = hanging_cable_02;

	arc = 15;

//  level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "hanging_wakeup");

//  level._player unlink();
//  player_rig delete();

	wakeup_player_legs vignette_actor_delete();
	hanging_gun Delete();
	hanging_cable_01 Delete();
	hanging_cable_02 Delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// rocket_crash_site_cutdown
crash_site_wakeup_cutdown_spawn()
{
	wakeup_player_legs = vignette_actor_spawn("wakeup_player_legs", "wakeup_player_legs"); //"value" (kvp), "anim_name"
	crash_wakeup_ally = vignette_actor_spawn("crash_wakeup_ally", "crash_wakeup_ally"); //"value" (kvp), "anim_name"

	crash_site_wakeup_cutdown(wakeup_player_legs, crash_wakeup_ally);

	wakeup_player_legs vignette_actor_delete();
	crash_wakeup_ally vignette_actor_delete();
}

crash_site_wakeup_cutdown(wakeup_player_legs, crash_wakeup_ally)
{

	node = getstruct("vignette_crash_site_wakeup_allyshot", "script_noteworthy");

	hanging_tree = spawn_anim_model("hanging_tree");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["wakeup_player_legs"] = wakeup_player_legs;
	guys["crash_wakeup_ally"] = crash_wakeup_ally;
	guys["player_rig"] = player_rig;
	guys["hanging_tree"] = hanging_tree;

	arc = 15;

	//level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_first_frame(guys, "hanging_cutdown");

	node anim_single(guys, "hanging_cutdown");

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

}

hanging_cutdown(player_rig, crash_wakeup_ally)
{
	wakeup_player_legs = vignette_actor_spawn("wakeup_player_legs", "hanging_player_legs"); //"value" (kvp), "anim_name"
	wakeup_player_legs.script_friendname = "";

	node = getstruct("vignette_crash_site_wakeup_allyshot", "script_noteworthy");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	guys = [];
	guys["wakeup_player_legs"] = wakeup_player_legs;
	guys["crash_wakeup_ally"] = crash_wakeup_ally;
	guys["player_rig"] = player_rig;
	guys["hanging_tree"] = level.vignette_models[ "hanging" ][ "hanging_tree" ];
	guys["hanging_chopper"] = level.vignette_models[ "hanging" ][ "hanging_chopper" ];
	
	thread maps\nx_rocket_fx::hanging_leaves_fx();
	node anim_single(guys, "hanging_cutdown");

	wakeup_player_legs vignette_actor_delete();
	node anim_first_frame( [guys["hanging_tree"], guys["hanging_chopper"]], "hanging_cutdown" );

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
}

hanging_setup()
{
	if( !IsDefined( level.vignette_models ) )
		level.vignette_models = [];

	level.vignette_models[ "hanging" ] = [];
	modelnames = [ "hanging_tree", "hanging_chopper" ];

	node = getstruct("vignette_crash_site_wakeup_allyshot", "script_noteworthy");
	foreach( modelname in modelnames )
	{
		model = spawn_anim_model( modelname );
		node anim_first_frame_solo( model, "hanging_cutdown" );
		level.vignette_models[ "hanging" ][ modelname ] = model;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// helicopter crash in rocket
helicopter_crash_rocket_spawn()
{
	helicopter_crash_baker = vignette_actor_spawn("helicopter_crash_baker", "helicopter_crash_baker"); //"value" (kvp), "anim_name"
	helicopter_crash_williams = vignette_actor_spawn("helicopter_crash_williams", "helicopter_crash_williams"); //"value" (kvp), "anim_name"
	helicopter_crash_jenkins = vignette_actor_spawn("helicopter_crash_jenkins", "helicopter_crash_jenkins"); //"value" (kvp), "anim_name"
	helicopter_crash_ally_01 = vignette_actor_spawn("helicopter_crash_ally_01", "helicopter_crash_ally_01"); //"value" (kvp), "anim_name"
	blackhawk_player = vignette_vehicle_spawn("blackhawk_player", "blackhawk_player"); //"value" (kvp), "anim_name"
	blackhawk_tp = vignette_vehicle_spawn("blackhawk_tp", "blackhawk_tp"); //"value" (kvp), "anim_name"

	helicopter_crash_rocket(helicopter_crash_baker, helicopter_crash_williams, helicopter_crash_jenkins, helicopter_crash_ally_01, blackhawk_player, blackhawk_tp);

	helicopter_crash_baker vignette_actor_delete();
	helicopter_crash_williams vignette_actor_delete();
	helicopter_crash_jenkins vignette_actor_delete();
	helicopter_crash_ally_01 vignette_actor_delete();
	blackhawk_player vignette_vehicle_delete();
	blackhawk_tp vignette_vehicle_delete();
}

helicopter_crash_rocket(helicopter_crash_baker, helicopter_crash_williams, helicopter_crash_jenkins, helicopter_crash_ally_01, blackhawk_player, blackhawk_tp)
{

	node = getstruct("vignette_rocket_helicoper_crash", "script_noteworthy");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["helicopter_crash_baker"] = helicopter_crash_baker;
	guys["helicopter_crash_williams"] = helicopter_crash_williams;
	guys["helicopter_crash_jenkins"] = helicopter_crash_jenkins;
	guys["player_rig"] = player_rig;
	guys["helicopter_crash_ally_01"] = helicopter_crash_ally_01;
	guys["blackhawk_player"] = blackhawk_player;
	guys["blackhawk_tp"] = blackhawk_tp;

	arc = 15;

	//level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "helicopter_crash_rocket");

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
}

crash_blackhawk(helicopter_crash_baker, helicopter_crash_williams, helicopter_crash_jenkins, blackhawk_player)
{

	node = getstruct("vignette_rocket_helicoper_crash", "script_noteworthy");

	arc = 15;

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player HideViewModel();
	level._player DisableWeapons();

	helicopter_crash_ally_01 = vignette_actor_spawn("helicopter_crash_ally_01", "helicopter_crash_ally_01"); //"value" (kvp), "anim_name"

	player_rig = spawn_anim_model( "player_rig" );
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);
	blackhawk_tp = vignette_vehicle_spawn("blackhawk_tp", "blackhawk_tp"); //"value" (kvp), "anim_name"
	blackhawk_player.animname = "blackhawk_player";

	blackhawk_anim_tag = spawn_tag_origin();
	blackhawk_anim_tag.origin = blackhawk_player GetTagOrigin( "tag_origin" ) + ( 45, 0, 8 );
	blackhawk_anim_tag.angles = blackhawk_player GetTagAngles( "tag_origin" );
	blackhawk_anim_tag LinkTo( blackhawk_player );

	player_rig LinkTo( blackhawk_anim_tag );
	helicopter_crash_baker LinkTo( blackhawk_anim_tag );
	helicopter_crash_williams LinkTo( blackhawk_anim_tag );
	helicopter_crash_jenkins LinkTo( blackhawk_anim_tag );

	guys = [];
	guys["helicopter_crash_baker"] = helicopter_crash_baker;
	guys["helicopter_crash_williams"] = helicopter_crash_williams;
	guys["helicopter_crash_jenkins"] = helicopter_crash_jenkins;
	guys["player_rig"] = player_rig;

	ally_guys["helicopter_crash_ally_01"] = helicopter_crash_ally_01;
	ally_guys["blackhawk_tp"] = blackhawk_tp;

	node thread anim_single_solo( blackhawk_player, "crash_blackhawk" );
	node thread anim_single( ally_guys, "crash_blackhawk" );
	thread maps\nx_rocket_fx::heli_01_hit_fx( blackhawk_tp );
	thread maps\nx_rocket_fx::heli_02_hit_fx( blackhawk_player );
	blackhawk_anim_tag anim_single( guys, "crash_blackhawk" );

	level._player unlink();
	helicopter_crash_baker unlink( );
	helicopter_crash_williams unlink( );
	helicopter_crash_jenkins unlink( );

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player ShowViewModel();
	level._player EnableWeapons();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// helicopter crash - two allies falling out
helicopter_crash_falling_ally_spawn()
{
	crash_falling_ally_01 = vignette_actor_spawn("crash_falling_ally_01", "crash_falling_ally_01"); //"value" (kvp), "anim_name"
	crash_falling_ally_02 = vignette_actor_spawn("crash_falling_ally_02", "crash_falling_ally_02"); //"value" (kvp), "anim_name"

	helicopter_crash_falling_ally(crash_falling_ally_01, crash_falling_ally_02);

	crash_falling_ally_01 vignette_actor_delete();
	crash_falling_ally_02 vignette_actor_delete();
}

helicopter_crash_falling_ally(crash_falling_ally_01, crash_falling_ally_02)
{

	node = getstruct("vignette_helicopter_crash_falling_ally", "script_noteworthy");


	guys = [];
	guys["crash_falling_ally_01"] = crash_falling_ally_01;
	guys["crash_falling_ally_02"] = crash_falling_ally_02;

	node anim_single(guys, "helicopter_crash_falling_ally");
}

crash_falling()
{
	node = getstruct("vignette_helicopter_crash_falling_ally", "script_noteworthy");

	crash_falling_ally_01 = vignette_actor_spawn("crash_falling_ally_01", "crash_falling_ally_01"); //"value" (kvp), "anim_name"
	crash_falling_ally_02 = vignette_actor_spawn("crash_falling_ally_02", "crash_falling_ally_02"); //"value" (kvp), "anim_name"

	guys = [];
	guys["crash_falling_ally_01"] = crash_falling_ally_01;
	guys["crash_falling_ally_02"] = crash_falling_ally_02;

	node anim_single(guys, "crash_falling");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// nuke and crash
nuke_and_crash(player_helicopter, nuke_crash_ally1, nuke_crash_ally2, nuke_crash_ally3)
{

	thread nuke_and_crash_dof();

	pilot = vignette_actor_spawn("crash_falling_ally_02", "nuke_crash_pilot"); //"value" (kvp), "anim_name"

	node = getstruct("vignette_nuke_crash", "script_noteworthy");

	blackhawk_player = spawn_anim_model( "blackhawk_player" );

//  nuke_crash_chopper1 = nuke_crash_player_heli;//spawn_anim_model("nuke_crash_chopper1");

	nuke_crash_chopper2 = vignette_vehicle_spawn("nuke_crash_chopper2", "nuke_crash_chopper2");

	nuke_crash_chopper3 = vignette_vehicle_spawn("nuke_crash_chopper3", "nuke_crash_chopper3");

	nuke_crash_missile1 = spawn_anim_model("nuke_crash_missile1");

	nuke_crash_missile2 = spawn_anim_model("nuke_crash_missile2");

	nuke_crash_missile3 = spawn_anim_model("nuke_crash_missile3");

	blackhawk_turret1 = spawn_anim_model("blackhawk_turret1");

	blackhawk_turret2 = spawn_anim_model("blackhawk_turret2");

	//nuke_crash_missile_4 = spawn_anim_model("nuke_crash_missile_4");

	//nuke_crash_missile5 = spawn_anim_model("nuke_crash_missile5");

	//nuke_crash_missile6 = spawn_anim_model("nuke_crash_missile6");

//  level._player FreezeControls( true );
//  level._player HideViewModel();
//  level._player DisableWeapons();
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["blackhawk_player"] = blackhawk_player;		// PLAYER HELI
	guys["nuke_crash_chopper2"] = nuke_crash_chopper2;
	guys["nuke_crash_chopper3"] = nuke_crash_chopper3;
	guys["nuke_crash_missile1"] = nuke_crash_missile1;
	guys["nuke_crash_missile2"] = nuke_crash_missile2;
	guys["nuke_crash_missile3"] = nuke_crash_missile3;
	//guys["nuke_crash_missile_4"] = nuke_crash_missile_4;
	//guys["nuke_crash_missile5"] = nuke_crash_missile5;
	//guys["nuke_crash_missile6"] = nuke_crash_missile6;


	blackhawk_anim_tag = spawn_tag_origin();
	blackhawk_anim_tag.origin = player_helicopter GetTagOrigin( "tag_origin" );// + ( 0, 0, -56 );
	blackhawk_anim_tag.angles = player_helicopter GetTagAngles( "tag_origin" );
	blackhawk_anim_tag LinkTo( player_helicopter, "tag_origin" );

	player_legs = vignette_actor_spawn("wakeup_player_legs", "player_legs"); //"value" (kvp), "anim_name"
	player_legs.script_friendname = "";

	ally_guys = [];
	ally_guys["player_rig"] = player_rig;
	ally_guys["nuke_crash_ally1"] = nuke_crash_ally1;
	ally_guys["nuke_crash_ally2"] = nuke_crash_ally2;
	ally_guys["nuke_crash_ally3"] = nuke_crash_ally3;
	ally_guys["blackhawk_turret1"] = blackhawk_turret1;
	ally_guys["blackhawk_turret2"] = blackhawk_turret2;
	ally_guys["player_legs"] = player_legs;
	ally_guys["nuke_crash_pilot"] = pilot;

	foreach( ally in ally_guys )
	{
		ally LinkTo( blackhawk_anim_tag );
	}

	//FX for missiles and nuke etc
	thread maps\nx_rocket_fx::nuke_missiles_fx( nuke_crash_missile1, nuke_crash_missile2, nuke_crash_missile3 );
	thread maps\nx_rocket_fx::nuke_fx();
	thread maps\nx_rocket_fx::heli_01_hit_fx( nuke_crash_chopper2 );
	thread maps\nx_rocket_fx::heli_03_hit_fx( nuke_crash_chopper3 );
	thread maps\nx_rocket_fx::heli_02_hit_fx( player_helicopter );

	player_rig.turret = ally_guys["blackhawk_turret1"];
	player_rig.legs = player_legs;

	player_rig Hide();
	player_rig.turret Hide();
	player_rig.legs Hide();
	
	node anim_first_frame( guys, "nuke_and_crash" );

	player_helicopter thread link_preexisting_helicopter_to_vignette( blackhawk_player );

	player_rig thread force_player_to_look_in_vingette_direction( "nuke_and_crash", "loose_player_control", 1.5 );
	blackhawk_anim_tag thread anim_single( ally_guys, "nuke_and_crash" );
	node anim_single( guys, "nuke_and_crash" );

	level._player unlink();
	nuke_crash_ally1 Unlink();
	nuke_crash_ally2 Unlink();

	player_legs vignette_actor_delete();
	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player ShowViewModel();
	level._player EnableWeapons();

	pilot vignette_actor_delete();
}

force_player_to_look_in_vingette_direction( vignette_name, event_name, transition_duration )
{
	// Dan: There is an a note track event at the time when the player should link to the player-rig.
	// We want to begin a lerp of the player's view-angle-clamp a few moments before the player-rig
	// takes over.  In this script, we grab the time of that event.  Then we calcuate a point in the
	// anim the correct duration (transition_duration) before the event.  Then we wait for that time
	// in the anim and start the blend.

	anime = level._scr_anim[ self.animname ][ vignette_name ];
	event_point = GetNotetrackTimes( anime, event_name );
	anim_length = GetAnimLength( anime );
	event_time = anim_length * event_point[ 0 ];
	assert( event_time - transition_duration > 0 );

	transition_start_time = event_time - transition_duration;
	transition_start_point = transition_start_time / anim_length;
	
	while ( true )
	{
		time = self GetAnimTime( anime );
		if ( time >= transition_start_point )
		{
			break;
		}
		wait 0.05;
	}

	level._player LerpViewAngleClamp( transition_duration, 0.3, 0.3, 0, 0, 0, 0 );

	if ( transition_duration < 0.75 )
	{
		wait ( 0.5 * transition_duration );
		Earthquake( 0.5, transition_duration, level._player.origin, 0 );
	}
}

nuke_and_crash_player( player_rig )
{
	level._player thread maps\nx_rocket_audio::nuke_and_crash_sfx();

	arc = 0;
	level._player SetRelinkPlayerFlag( 1 );
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, true );

	player_rig Show();
	player_rig.turret Show();
	player_rig.legs Show();
	level.player_turret Delete();

	level._player HideViewModel();
	level._player DisableWeapons();

	wait 0.05;
	level._player SetRelinkPlayerFlag( 0 );
}

nuke_and_crash_begin_fov_blend( player_rig )
{
	lerp_fov_overtime( 0.5, 65 );
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// witness nuke
witness_nuke_spawn()
{
	blackhawk_player = vignette_vehicle_spawn("blackhawk_player", "blackhawk_player"); //"value" (kvp), "anim_name"

	witness_nuke(blackhawk_player);

	blackhawk_player vignette_vehicle_delete();
}

witness_nuke(blackhawk_player)
{

	node = getstruct("vignette_witness_nuke", "script_noteworthy");

	nuke_01 = spawn_anim_model("crash_nuke_missile_01");
	nuke_02 = spawn_anim_model("crash_nuke_missile_02");
	nuke_03 = spawn_anim_model("crash_nuke_missile_03");
	nuke_04 = spawn_anim_model("crash_nuke_missile_04");
	nuke_05 = spawn_anim_model("crash_nuke_missile_05");
	nuke_06 = spawn_anim_model("crash_nuke_missile_06");


	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["blackhawk_player"] = blackhawk_player;
	guys["player_rig"] = player_rig;
	guys["nuke_01"] = nuke_01;
	guys["nuke_02"] = nuke_02;
	guys["nuke_03"] = nuke_03;
	guys["nuke_04"] = nuke_04;
	guys["nuke_05"] = nuke_05;
	guys["nuke_06"] = nuke_06;

	arc = 15;

	//level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "witness_nuke");

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

}

nuke_and_crash_dof ()
{
	wait 23.6;
	start = level._dofDefault;

    dof_jar = [];
    dof_jar[ "nearStart" ] = 0;
    dof_jar[ "nearEnd" ] = 261;
    dof_jar[ "nearBlur" ] = 4.7;
    dof_jar[ "farStart" ] = 1000;
    dof_jar[ "farEnd" ] = 2848;
    dof_jar[ "farBlur" ] = 1.07;

    blend_dof( start, dof_jar, .25 );
	//iprintlnbold( "My stuff is working." );
	wait 2;
	blend_dof(dof_jar, start, 2);

	wait 7.4;
	start = level._dofDefault;

    dof_jar = [];
    dof_jar[ "nearStart" ] = 1;
    dof_jar[ "nearEnd" ] = 210;
    dof_jar[ "nearBlur" ] = 7.7;
    dof_jar[ "farStart" ] = 211;
    dof_jar[ "farEnd" ] = 23820;
    dof_jar[ "farBlur" ] = 7;

    blend_dof( start, dof_jar, .1 );
	//iprintlnbold( "My stuff is working." );
	wait .5;
	blend_dof(dof_jar, start, .5);

	wait 3.8;
	start = level._dofDefault;

    dof_jar = [];
    dof_jar[ "nearStart" ] = 1;
    dof_jar[ "nearEnd" ] = 210;
    dof_jar[ "nearBlur" ] = 7.7;
    dof_jar[ "farStart" ] = 211;
    dof_jar[ "farEnd" ] = 23820;
    dof_jar[ "farBlur" ] = 7;

    blend_dof( start, dof_jar, .1 );
	//iprintlnbold( "My stuff is working." );
	wait .5;
	blend_dof(dof_jar, start, .75);

	wait 3;
	start = level._dofDefault;

    dof_jar = [];
    dof_jar[ "nearStart" ] = 1;
    dof_jar[ "nearEnd" ] = 49;
    dof_jar[ "nearBlur" ] = 9;
    dof_jar[ "farStart" ] = 50;
    dof_jar[ "farEnd" ] = 9840;
    dof_jar[ "farBlur" ] = 1;

    blend_dof( start, dof_jar, .25 );
	//iprintlnbold( "My stuff is working." );
	wait .75;
	blend_dof(dof_jar, start, .25);

	wait 2;
	start = level._dofDefault;

    dof_jar = [];
    dof_jar[ "nearStart" ] = 1;
    dof_jar[ "nearEnd" ] = 49;
    dof_jar[ "nearBlur" ] = 9;
    dof_jar[ "farStart" ] = 50;
    dof_jar[ "farEnd" ] = 9840;
    dof_jar[ "farBlur" ] = 1;

    blend_dof( start, dof_jar, .25 );
	//iprintlnbold( "My stuff is working." );
	wait .5;
	blend_dof(dof_jar, start, .25);

}

crash_nuke( blackhawk_player )
{
	blackhawk_player.animname = "blackhawk_player";

	node = getstruct("vignette_witness_nuke", "script_noteworthy");

	nuke_01 = spawn_anim_model("crash_nuke_missile_01");
	nuke_02 = spawn_anim_model("crash_nuke_missile_02");
	nuke_03 = spawn_anim_model("crash_nuke_missile_03");
	nuke_04 = spawn_anim_model("crash_nuke_missile_04");
	nuke_05 = spawn_anim_model("crash_nuke_missile_05");
	nuke_06 = spawn_anim_model("crash_nuke_missile_06");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player HideViewModel();
	level._player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
//  guys["blackhawk_player"] = blackhawk_player;
//  guys["player_rig"] = player_rig;
	guys["nuke_01"] = nuke_01;
	guys["nuke_02"] = nuke_02;
	guys["nuke_03"] = nuke_03;
	guys["nuke_04"] = nuke_04;
	guys["nuke_05"] = nuke_05;
	guys["nuke_06"] = nuke_06;

	arc = 15;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	blackhawk_anim_tag = spawn_tag_origin();
	blackhawk_anim_tag.origin = blackhawk_player GetTagOrigin( "tag_origin" );// + ( 0, 40, 8 );
	blackhawk_anim_tag.angles = blackhawk_player GetTagAngles( "tag_origin" );
	blackhawk_anim_tag LinkTo( blackhawk_player );

	player_rig LinkTo( blackhawk_anim_tag );
//  player_rig LinkTo( blackhawk_player );
	
	blackhawk_anim_tag thread anim_single_solo( player_rig, "witness_nuke" );
	node thread anim_single( guys, "witness_nuke" );
	//thread maps\nx_rocket_fx::nuke_missiles_fx( nuke_01, nuke_02, nuke_03, nuke_04, nuke_05, nuke_06 );
	//thread maps\nx_rocket_fx::nuke_fx();
	node anim_single_solo(blackhawk_player, "witness_nuke");

	level._player unlink();

	player_rig delete();
	nuke_01 delete();
	nuke_02 delete();
	nuke_03 delete();
	nuke_04 delete();
	nuke_05 delete();
	nuke_06 delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player ShowViewModel();
	level._player EnableWeapons();}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Williams busting out the doors of the control room
aa_control_room_doors_spawn()
{
	aa_control_exit_williams_01 = vignette_actor_spawn("aa_control_exit_williams_01", "aa_control_exit_williams_01"); //"value" (kvp), "anim_name"

	aa_control_room_doors(aa_control_exit_williams_01);

	aa_control_exit_williams_01 vignette_actor_delete();
}

aa_control_room_doors(aa_control_exit_williams_01)
{

	node = getstruct("vignette_contol_room_doors", "script_noteworthy");

	control_room_exit_door_01 = spawn_anim_model("control_room_exit_door_01");

	control_room_exit_door_02 = spawn_anim_model("control_room_exit_door_02");


	guys = [];
	guys["control_room_exit_door_01"] = control_room_exit_door_01;
	guys["control_room_exit_door_02"] = control_room_exit_door_02;
	guys["aa_control_exit_williams_01"] = aa_control_exit_williams_01;

	node anim_single(guys, "aa_control_room_doors");

}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// jump onto gantry
jump_onto_gantry_spawn()
{
	jump_gantry_baker = vignette_actor_spawn("jump_gantry_baker", "jump_gantry_baker"); //"value" (kvp), "anim_name"
	jump_gantry_opfor_01 = vignette_actor_spawn("jump_gantry_opfor_01", "jump_gantry_opfor_01"); //"value" (kvp), "anim_name"
	littlebird_jump_onto_gantry = vignette_vehicle_spawn("littlebird_jump_onto_gantry", "littlebird_jump_onto_gantry"); //"value" (kvp), "anim_name"

	jump_onto_gantry(jump_gantry_baker, jump_gantry_opfor_01, littlebird_jump_onto_gantry);

	jump_gantry_baker vignette_actor_delete();
	jump_gantry_opfor_01 vignette_actor_delete();
	littlebird_jump_onto_gantry vignette_vehicle_delete();
}

jump_onto_gantry(jump_gantry_baker, jump_gantry_opfor_01, littlebird_jump_onto_gantry)
{

	node = getstruct("vignette_jump_onto_gantry", "script_noteworthy");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["jump_gantry_baker"] = jump_gantry_baker;
	guys["jump_gantry_opfor_01"] = jump_gantry_opfor_01;
	guys["player_rig"] = player_rig;
	guys["littlebird_jump_onto_gantry"] = littlebird_jump_onto_gantry;

	arc = 15;

	//level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "jump_onto_gantry");

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// climb onto littlebird after leaving aa building
climb_onto_littlebird_spawn()
{
	littlebird_jump_onto_gantry = vignette_vehicle_spawn("littlebird_jump_onto_gantry", "littlebird_jump_onto_gantry"); //"value" (kvp), "anim_name"
	vignette_rocket_baker = vignette_actor_spawn("vignette_rocket_baker", "vignette_rocket_baker"); //"value" (kvp), "anim_name"
	vignette_rocket_opfor_01 = vignette_actor_spawn("vignette_rocket_opfor_01", "vignette_rocket_opfor_01"); //"value" (kvp), "anim_name"
	vignette_rocket_opfor_02 = vignette_actor_spawn("vignette_rocket_opfor_02", "vignette_rocket_opfor_02"); //"value" (kvp), "anim_name"

	climb_onto_littlebird(littlebird_jump_onto_gantry, vignette_rocket_baker, vignette_rocket_opfor_01, vignette_rocket_opfor_02);

	littlebird_jump_onto_gantry vignette_vehicle_delete();
	vignette_rocket_baker vignette_actor_delete();
	vignette_rocket_opfor_01 vignette_actor_delete();
	vignette_rocket_opfor_02 vignette_actor_delete();
}

climb_onto_littlebird(littlebird_jump_onto_gantry, vignette_rocket_baker, vignette_rocket_opfor_01, vignette_rocket_opfor_02)
{

	node = getstruct("vignette_climb_onto_littlebird", "script_noteworthy");


	guys = [];
	guys["littlebird_jump_onto_gantry"] = littlebird_jump_onto_gantry;
	guys["vignette_rocket_baker"] = vignette_rocket_baker;
	guys["vignette_rocket_opfor_01"] = vignette_rocket_opfor_01;
	guys["vignette_rocket_opfor_02"] = vignette_rocket_opfor_02;

	node anim_single(guys, "climb_onto_littlebird");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Rocket explosion 02
rocket_explosion_02_spawn()
{

	rocket_explosion_02();

}

rocket_explosion_02()
{
	//JR - Commented this out because it was a test anim Chris put in
	// with a test trigger plane.  The real anim is hooked up now.

	/*
	node = getstruct("vignette_rocket_explosion_02", "script_noteworthy");

	rocket_explosion_02 = spawn_anim_model("rocket_explosion_02");


	guys = [];
	guys["rocket_explosion_02"] = rocket_explosion_02;

	node anim_single(guys, "rocket_explosion_02");
	*/
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// aa corridor run out 01

aa_corridor_run_out_01_spawn()
{
	aa_corridor_run_player_legs_01 = vignette_actor_spawn("aa_corridor_run_player_legs_01", "aa_corridor_run_player_legs_01"); //"value" (kvp), "anim_name"

	aa_corridor_run_out_01_player(aa_corridor_run_player_legs_01);

//  aa_corridor_run_williams_01 vignette_actor_delete();
	aa_corridor_run_player_legs_01 vignette_actor_delete();
}

aa_corridor_run_out_01(aa_corridor_run_williams_01, aa_corridor_run_player_legs_01)
{

	node = getstruct("vignette_aa_corridor_run_01", "script_noteworthy");

	//level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["aa_corridor_run_williams_01"] = aa_corridor_run_williams_01;
	guys["aa_corridor_run_player_legs_01"] = aa_corridor_run_player_legs_01;
	guys["player_rig"] = player_rig;

	arc = 15;

	//level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "aa_corridor_run_out_01");

	level._player unlink();

	player_rig delete();

	//level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
}

aa_corridor_run_out_01_ally( aa_corridor_run_williams_01 )
{

	node = getstruct("vignette_aa_corridor_run_01", "script_noteworthy");

	guys = [];
	guys["aa_corridor_run_williams_01"] = aa_corridor_run_williams_01;

	node anim_reach( guys, "aa_corridor_run_out_01" );
	node anim_single( guys, "aa_corridor_run_out_01" );
}

aa_corridor_run_out_01_player( aa_corridor_run_player_legs_01 )
{

	node = getstruct("vignette_aa_corridor_run_01", "script_noteworthy");

	//level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player HideViewModel();
	level._player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["aa_corridor_run_player_legs_01"] = aa_corridor_run_player_legs_01;
	guys["player_rig"] = player_rig;

	arc = 0;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "aa_corridor_run_out_01");

	level._player unlink();

	player_rig delete();

	//level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player ShowViewModel();
	level._player EnableWeapons();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// aa corridor run out 01
aa_corridor_run_out_02_spawn()
{
	aa_corridor_run_player_legs_02 = vignette_actor_spawn("aa_corridor_run_player_legs_02", "aa_corridor_run_player_legs_02"); //"value" (kvp), "anim_name"
//  aa_corridor_run_williams_02 = vignette_actor_spawn("aa_corridor_run_williams_02", "aa_corridor_run_williams_02"); //"value" (kvp), "anim_name"

	aa_corridor_run_out_02_player(aa_corridor_run_player_legs_02);

	aa_corridor_run_player_legs_02 vignette_actor_delete();
//  aa_corridor_run_williams_02 vignette_actor_delete();
}

aa_corridor_run_out_02(aa_corridor_run_player_legs_02, aa_corridor_run_williams_02)
{

	node = getstruct("vignette_aa_corridor_run_02", "script_noteworthy");

	//level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys[ "aa_corridor_run_player_legs_02" ] = aa_corridor_run_player_legs_02;
	guys[ "aa_corridor_run_williams_02" ] = aa_corridor_run_williams_02;
	guys[ "player_rig" ] = player_rig;

	arc = 15;

	//level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "aa_corridor_run_out_02");

	level._player unlink();

	player_rig delete();

	//level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
}

aa_corridor_run_out_02_ally( aa_corridor_run_williams_02 )
{

	node = getstruct("vignette_aa_corridor_run_02", "script_noteworthy");

	guys = [];
	guys["aa_corridor_run_williams_02"] = aa_corridor_run_williams_02;

	node anim_reach( guys, "aa_corridor_run_out_02" );
	node anim_single( guys, "aa_corridor_run_out_02" );
}

aa_corridor_run_out_02_player(aa_corridor_run_player_legs_02)
{

	node = getstruct("vignette_aa_corridor_run_02", "script_noteworthy");

	//level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player HideViewModel();
	level._player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys[ "aa_corridor_run_player_legs_02" ] = aa_corridor_run_player_legs_02;
	guys[ "player_rig" ] = player_rig;

	arc = 15;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "aa_corridor_run_out_02");

	level._player unlink();

	player_rig delete();

	//level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player ShowViewModel();
	level._player EnableWeapons();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// aa corritor wall explosion
aa_corridor_wall_01_spawn()
{
	aa_corridor_wall_opfor_01 = vignette_actor_spawn("aa_corridor_wall_opfor_01", "enemy_opfor"); //"value" (kvp), "anim_name"
	aa_corridor_wall_opfor_02 = vignette_actor_spawn("aa_corridor_wall_opfor_02", "enemy_opfor"); //"value" (kvp), "anim_name"

	aa_corridor_wall_01(aa_corridor_wall_opfor_01, aa_corridor_wall_opfor_02);

	aa_corridor_wall_opfor_01 vignette_actor_delete();
	aa_corridor_wall_opfor_02 vignette_actor_delete();
}

aa_corridor_wall_01(aa_corridor_wall_opfor_01, aa_corridor_wall_opfor_02)
{

	node = getstruct("vignette_aa_cor_wall_01", "script_noteworthy");

	aa_corridor_wall_model = spawn_anim_model("aa_corridor_wall_model");


	guys = [];
	guys["aa_corridor_wall_opfor_01"] = aa_corridor_wall_opfor_01;
	guys["aa_corridor_wall_opfor_02"] = aa_corridor_wall_opfor_02;
	guys["aa_corridor_wall_model"] = aa_corridor_wall_model;

	node anim_single(guys, "aa_corridor_wall_01");

}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// woods mantel 01
woods_mantel_spawn()
{
	vignette_woods_mantel_williams_01 = vignette_actor_spawn("vignette_woods_mantel_williams_01", "vignette_woods_mantel_williams_01"); //"value" (kvp), "anim_name"
	vignette_woods_mantel_jenkins_01 = vignette_actor_spawn("vignette_woods_mantel_jenkins_01", "vignette_woods_mantel_jenkins_01"); //"value" (kvp), "anim_name"

	woods_mantel(vignette_woods_mantel_williams_01, vignette_woods_mantel_jenkins_01);

	vignette_woods_mantel_williams_01 vignette_actor_delete();
	vignette_woods_mantel_jenkins_01 vignette_actor_delete();
}

woods_mantel(vignette_woods_mantel_williams_01, vignette_woods_mantel_jenkins_01)
{

	node = getstruct("vignette_woods_mantel_01", "script_noteworthy");


	guys = [];
	guys["vignette_woods_mantel_williams_01"] = vignette_woods_mantel_williams_01;
	guys["vignette_woods_mantel_jenkins_01"] = vignette_woods_mantel_jenkins_01;

	node anim_single(guys, "woods_mantel");

}

woods_mantle( vignette_woods_mantel_williams_01, vignette_woods_mantel_jenkins_01 )
{

	node = getstruct("vignette_woods_mantel_01", "script_noteworthy");


	guys = [];
	guys["ally_williams"] = vignette_woods_mantel_williams_01;
	guys["ally_jenkins"] = vignette_woods_mantel_jenkins_01;

	node anim_reach( guys, "woods_mantle" );
	node anim_single(guys, "woods_mantle");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// woods ledge walk 01
woods_ledge_01_spawn()
{
//  vignette_woods_ledge_williams_01 = vignette_actor_spawn("vignette_woods_ledge_williams_01", "vignette_woods_ledge_williams_01"); //"value" (kvp), "anim_name"
	vignette_woods_ledge_player_legs_01 = vignette_actor_spawn("vignette_woods_ledge_player_legs_01", "vignette_woods_ledge_player_legs_01"); //"value" (kvp), "anim_name"

//  woods_ledge_01(vignette_woods_ledge_williams_01, vignette_woods_ledge_player_legs_01);
	woods_ledge_player( vignette_woods_ledge_player_legs_01);

//  vignette_woods_ledge_williams_01 vignette_actor_delete();
	vignette_woods_ledge_player_legs_01 vignette_actor_delete();
}

woods_ledge(vignette_woods_ledge_williams_01 )
{
	node = getstruct("vignette_woods_ledge_01", "script_noteworthy");

	guys = [];
	guys["ally_williams"] = vignette_woods_ledge_williams_01;

	node anim_reach( guys, "woods_ledge_01" );
	node anim_single(guys, "woods_ledge_01");
}

woods_ledge_player( vignette_woods_ledge_player_legs_01 )
{

	node = getstruct("vignette_woods_ledge_01", "script_noteworthy");

	//level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player HideViewModel();
	level._player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["vignette_woods_ledge_player_legs_01"] = vignette_woods_ledge_player_legs_01;
	guys["player_rig"] = player_rig;

	arc = 15;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "woods_ledge_01");

	level._player unlink();

	player_rig delete();

	//level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player ShowViewModel();
	level._player EnableWeapons();
}

//                                                                  *
//                                                                  *
//*******************************************************************
// chopper fly over
woods_chopper_fly_over_spawn()
{
//  woods_chopper_fly_over_williams_01 = vignette_actor_spawn("woods_chopper_fly_over_williams_01", "woods_chopper_fly_over_williams_01"); //"value" (kvp), "anim_name"
//  woods_chopper_fly_over_blackhawk = vignette_vehicle_spawn("woods_chopper_fly_over_blackhawk", "woods_chopper_fly_over_blackhawk"); //"value" (kvp), "anim_name"

//  woods_chopper_fly_over( level.squad[ "ALLY_WILLIAMS" );

//  woods_chopper_fly_over_williams_01 vignette_actor_delete();
//  woods_chopper_fly_over_blackhawk vignette_vehicle_delete();
}

woods_chopper_fly_over(woods_chopper_fly_over_williams_01, woods_chopper_fly_over_blackhawk)
{

	woods_chopper_fly_over_blackhawk = vignette_vehicle_spawn("woods_chopper_fly_over_blackhawk", "woods_chopper_fly_over_blackhawk"); //"value" (kvp), "anim_name"

	node = getstruct("vignette_woods_chopper_fly_over", "script_noteworthy");

	woods_chopper_fly_over_tree = spawn_anim_model("woods_chopper_fly_over_tree");

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["ally_williams"] = woods_chopper_fly_over_williams_01;
	guys["player_rig"] = player_rig;
	guys["woods_chopper_fly_over_tree"] = woods_chopper_fly_over_tree;
	guys["woods_chopper_fly_over_blackhawk"] = woods_chopper_fly_over_blackhawk;

	node anim_reach_solo( guys[ "ally_williams" ], "woods_chopper_fly_over" );

	flag_wait( "vignette_woods_chopper_fly_over_flag" );

	//level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player HideViewModel();
	level._player DisableWeapons();

	node anim_first_frame(guys, "woods_chopper_fly_over");
	arc = 15;
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	thread maps\nx_rocket_fx::chopper_fly_over_fx( woods_chopper_fly_over_blackhawk );
	node anim_single(guys, "woods_chopper_fly_over");

	level._player unlink();

	player_rig delete();

	//level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player ShowViewModel();
	level._player EnableWeapons();

	woods_chopper_fly_over_blackhawk vignette_vehicle_delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// woods traversal 01
woods_traversal_01_spawn()
{
	woods_misc_traversals_williams = vignette_actor_spawn("woods_misc_traversals_williams", "woods_misc_traversals_williams"); //"value" (kvp), "anim_name"

	woods_traversal_01(woods_misc_traversals_williams);

	woods_misc_traversals_williams vignette_actor_delete();
}

woods_traversal_01(woods_misc_traversals_williams)
{

	node = getstruct("vignette_woods_traversal_01", "script_noteworthy");

	woods_trav_tree_01 = spawn_anim_model("woods_trav_tree_01");


	guys = [];
	guys["ally_williams"] = woods_misc_traversals_williams;
	guys["tree"] = woods_trav_tree_01;

	node anim_first_frame_solo( guys[ "tree" ], "woods_traversals_01" );
	node anim_reach_solo( guys["ally_williams"], "woods_traversals_01" );

	node anim_single(guys, "woods_traversals_01");

}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// woods traversal 02
woods_traversal_02_spawn()
{
	woods_misc_traversals_williams = vignette_actor_spawn("woods_misc_traversals_williams", "woods_misc_traversals_williams"); //"value" (kvp), "anim_name"

	woods_traversal_02(woods_misc_traversals_williams);

	woods_misc_traversals_williams vignette_actor_delete();
}

woods_traversal_02(woods_misc_traversals_williams)
{

	node = getstruct("vignette_woods_traversal_02", "script_noteworthy");

	woods_trav_tree_02 = spawn_anim_model("woods_trav_tree_02");


	guys = [];
	guys["ally_williams"] = woods_misc_traversals_williams;
	guys["tree"] = woods_trav_tree_02;

	node anim_first_frame_solo( guys[ "tree" ], "woods_traversal_02" );
	node anim_reach_solo( guys["ally_williams"], "woods_traversals_02" );

	node anim_single(guys, "woods_traversal_02");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// copy and paste these functions into <level>_anim.gsc

pipe_traversal_01_spawn()

{

	pipe_traversal_williams_01 = vignette_actor_spawn("pipe_traversal_williams_01", "pipe_traversal_williams_01"); //"value" (kvp), "anim_name"



	pipe_traversal_01(pipe_traversal_williams_01);



	pipe_traversal_williams_01 vignette_actor_delete();

}



pipe_traversal_01(pipe_traversal_williams_01)

{



	node = getstruct("vignette_pipe_traversal_01", "script_noteworthy");





	guys = [];

	guys["pipe_traversal_williams_01"] = pipe_traversal_williams_01;



	node anim_reach(guys, "pipe_traversal_01");

	node anim_single(guys, "pipe_traversal_01");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Pipe Traversal 02
pipe_traversal_02_spawn()
{
	pipe_traversal_williams_02 = vignette_actor_spawn("pipe_traversal_williams_02", "pipe_traversal_williams_02"); //"value" (kvp), "anim_name"

	pipe_traversal_02(pipe_traversal_williams_02);

	pipe_traversal_williams_02 vignette_actor_delete();
}

pipe_traversal_02(pipe_traversal_williams_02)
{

	node = getstruct("vignette_pipe_traversal_02", "script_noteworthy");


	guys = [];
	guys["pipe_traversal_williams_02"] = pipe_traversal_williams_02;

	node anim_reach(guys, "pipe_traversal_02");
	node anim_single(guys, "pipe_traversal_02");
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Delta Chopper Battle 01
chopper_battle_base_delta_01_spawn()
{
	//iprintln("spawing choppers");
	woods_chopper_fly_over_blackhawk = vignette_vehicle_spawn("woods_chopper_fly_over_blackhawk", "woods_chopper_fly_over_blackhawk"); //"value" (kvp), "anim_name"
	rocket_basic_hind = vignette_vehicle_spawn("rocket_basic_hind", "rocket_basic_hind"); //"value" (kvp), "anim_name"
	woods_chopper_fly_over_blackhawk godon();
	
	rocket_basic_hind thread maps\nx_rocket_audio::rocket_air_vehicle_flyby_sfx("rocket_vtol_flyby_01", 7.5 );
	woods_chopper_fly_over_blackhawk thread maps\nx_rocket_audio::rocket_air_vehicle_flyby_sfx("rocket_heli_flyby_03", 6.7);

	// JR - Setting its health low makes it killable
	rocket_basic_hind.health = 16000;

	chopper_battle_base_delta_01(woods_chopper_fly_over_blackhawk, rocket_basic_hind);

	woods_chopper_fly_over_blackhawk vignette_vehicle_delete();

	// Only delete the VTOL if it wasnt shot down
	if(( isAlive( rocket_basic_hind ) && ( rocket_basic_hind vehicle_is_crashing()) == false ))
	{
		rocket_basic_hind vignette_vehicle_delete();
	}
}

chopper_battle_base_delta_01(woods_chopper_fly_over_blackhawk, rocket_basic_hind)
{

	node = getstruct("vignette_chopper_battle_base_delta_01", "script_noteworthy");

	thread maps\_attack_heli::begin_attack_heli_behavior( rocket_basic_hind );
	rocket_basic_hind thread chopper_battle_base_delta_01_logic( woods_chopper_fly_over_blackhawk );
	rocket_basic_hind thread set_speed_when_killed( 60 );

	guys = [];
	guys["woods_chopper_fly_over_blackhawk"] = woods_chopper_fly_over_blackhawk;
	guys["rocket_basic_hind"] = rocket_basic_hind;

	node anim_single(guys, "chopper_battle_base_delta_01");
	rocket_basic_hind notify( "anim_done" );
}

// Animated VTOL is forced to fire on the allied chopper
chopper_battle_base_delta_01_logic( target )
{
	self endon( "death" );
	self endon( "anim_done" );

	while( 1 )
	{
		wait( RandomFloatRange( 0.7, 1.0 ) );
		self.eTarget = target;
		maps\_attack_heli::fire_guns();
	}
}

// Gets the VTOL up to speed when it
// dies and drops out of its anim
set_speed_when_killed( speed )
{
	self endon( "anim_done" );

	self waittill( "death" );
	if( isDefined( self ))
	{
		self Vehicle_SetSpeedImmediate( speed );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

intro_choppers_spawn()
{
	player_chopper = level.playerHeli; //vignette_vehicle_spawn("heli_player", "player_chopper"); //"value" (kvp), "anim_name"
	chopper_formation_01 = vignette_vehicle_spawn("intro_chopper_formation_1", "chopper_formation_01"); //"value" (kvp), "anim_name"
	chopper_formation_02 = vignette_vehicle_spawn("intro_chopper_formation_2", "chopper_formation_02"); //"value" (kvp), "anim_name"
	chopper_formation_03 = vignette_vehicle_spawn("intro_chopper_formation_3", "chopper_formation_03"); //"value" (kvp), "anim_name"
	chopper_formation_04 = vignette_vehicle_spawn("intro_chopper_formation_4", "chopper_formation_04"); //"value" (kvp), "anim_name"
	chopper_formation_05 = vignette_vehicle_spawn("intro_chopper_formation_5", "chopper_formation_05"); //"value" (kvp), "anim_name"
	chopper_formation_06 = vignette_vehicle_spawn("intro_chopper_formation_6", "chopper_formation_06"); //"value" (kvp), "anim_name"
	chopper_formation_07 = vignette_vehicle_spawn("intro_chopper_formation_7", "chopper_formation_07"); //"value" (kvp), "anim_name"
	chopper_formation_08 = vignette_vehicle_spawn("intro_chopper_formation_8", "chopper_formation_08"); //"value" (kvp), "anim_name"
	bomber_01 = vignette_vehicle_spawn("intro_bomber_1", "bomber_01"); //"value" (kvp), "anim_name"
	bomber_02 = vignette_vehicle_spawn("intro_bomber_2", "bomber_02"); //"value" (kvp), "anim_name"
	bomber_03 = vignette_vehicle_spawn("intro_bomber_3", "bomber_03"); //"value" (kvp), "anim_name"
	bomber_04 = vignette_vehicle_spawn("intro_bomber_4", "bomber_04"); //"value" (kvp), "anim_name"

	// Save allied choppers for later use
	level.intro_ally_1 = chopper_formation_01;
	level.intro_ally_2 = chopper_formation_02;
	level.intro_ally_3 = chopper_formation_03;
	level.intro_ally_4 = chopper_formation_04;
	level.intro_ally_5 = chopper_formation_05;

	intro_choppers(player_chopper, chopper_formation_01, chopper_formation_02, chopper_formation_03, chopper_formation_04, chopper_formation_05, chopper_formation_06, chopper_formation_07, chopper_formation_08, bomber_01, bomber_02, bomber_03, bomber_04);

	//player_chopper vignette_vehicle_delete();
	//chopper_formation_01 vignette_vehicle_delete();
	//chopper_formation_02 vignette_vehicle_delete();
	//chopper_formation_03 vignette_vehicle_delete();
	//chopper_formation_04 vignette_vehicle_delete();
	chopper_formation_05 vignette_vehicle_delete();
	chopper_formation_06 vignette_vehicle_delete();
	chopper_formation_07 vignette_vehicle_delete();
	chopper_formation_08 vignette_vehicle_delete();
	bomber_01 vignette_vehicle_delete();
	bomber_02 vignette_vehicle_delete();
	bomber_03 vignette_vehicle_delete();
	bomber_04 vignette_vehicle_delete();
}

intro_choppers(player_chopper, chopper_formation_01, chopper_formation_02, chopper_formation_03, chopper_formation_04, chopper_formation_05, chopper_formation_06, chopper_formation_07, chopper_formation_08, bomber_01, bomber_02, bomber_03, bomber_04)
{

	node = getstruct("intro_start_vignette", "script_noteworthy");

	player_chopper.animname = "player_chopper";

	guys = [];
	guys["player_chopper"] = player_chopper;
	guys["chopper_formation_01"] = chopper_formation_01;
	guys["chopper_formation_02"] = chopper_formation_02;
	guys["chopper_formation_03"] = chopper_formation_03;
	guys["chopper_formation_04"] = chopper_formation_04;
	guys["chopper_formation_05"] = chopper_formation_05;
	guys["chopper_formation_06"] = chopper_formation_06;
	guys["chopper_formation_07"] = chopper_formation_07;
	guys["chopper_formation_08"] = chopper_formation_08;
	guys["bomber_01"] = bomber_01;
	guys["bomber_02"] = bomber_02;
	guys["bomber_03"] = bomber_03;
	guys["bomber_04"] = bomber_04;

	thread maps\nx_rocket_fx::intro_bombers_fx( bomber_01, bomber_02, bomber_03, bomber_04 );
	node anim_single(guys, "intro_choppers");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

intro_allies_in_chopper_spawn()
{
	pilot_01 = vignette_actor_spawn("player_heli_pilot_1", "pilot_01"); //"value" (kvp), "anim_name"
	pilot_02 = vignette_actor_spawn("player_heli_pilot_2", "pilot_02"); //"value" (kvp), "anim_name"
	//ally_01 = vignette_actor_spawn("player_heli_passenger_1", "ally_01"); //"value" (kvp), "anim_name"
	//ally_02 = vignette_actor_spawn("player_heli_passenger_2", "ally_02"); //"value" (kvp), "anim_name"
	//ally_03 = vignette_actor_spawn("player_heli_passenger_3", "ally_03"); //"value" (kvp), "anim_name"

	intro_allies_in_chopper(pilot_01, pilot_02, level.squad[ "ALLY_BAKER" ], level.squad[ "ALLY_JENKINS" ], level.squad[ "ALLY_WILLIAMS" ]);

	pilot_01 vignette_actor_delete();
	pilot_02 vignette_actor_delete();
	//ally_01 vignette_actor_delete();
	//ally_02 vignette_actor_delete();
	//ally_03 vignette_actor_delete();
}

toggle_turret_use()
{
	level.player_turret MakeUsable();
	level.player_turret SetMode( "manual" );
	level.player_turret UseBy( level._player );
	level.player_turret MakeUnusable();
}

intro_allies_in_chopper(pilot_01, pilot_02, ally_01, ally_02, ally_03)
{
	node = getstruct("intro_start_vignette", "script_noteworthy");

	minigun_right = spawn_anim_model("minigun_right");
	minigun_left = spawn_anim_model("minigun_left");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player HideViewModel();
	level._player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["pilot_01"] = pilot_01;
	guys["pilot_02"] = pilot_02;
	guys["ally_01"] = ally_01;
	guys["ally_02"] = ally_02;
	guys["ally_03"] = ally_03;
	guys["player_rig"] = player_rig;
	guys["minigun_right"] = minigun_right; 
	guys["minigun_left"] = minigun_left;

	arc = 0;

	// Hide the real turret
	level.player_turret hide();

	// Create a temp origin to position the player inside the anim
	blackhawk_anim_tag = spawn_tag_origin();
	blackhawk_anim_tag.origin = level.playerHeli GetTagOrigin( "body_animate_vnte_jnt" ) + (0,0,0);
	blackhawk_anim_tag.angles = level.playerHeli GetTagAngles( "body_animate_vnte_jnt" );
	blackhawk_anim_tag LinkTo( level.playerHeli, "body_animate_vnte_jnt" );

	// Align the animnode with the vehicle
	node.origin = blackhawk_anim_tag.origin;
	node.angles = blackhawk_anim_tag.angles;

	// Release player from turret and link to player_rig
	// Get player off the turret
	toggle_turret_use();

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1 );

	// Link all the guys to the anim tag
	foreach( ally in guys )
	{
		ally LinkTo( blackhawk_anim_tag );
	}
	
	// Dan:  Thread the anim_single, so this script continues to run while the anim plays.
	blackhawk_anim_tag thread anim_single(guys, "intro_allies_in_chopper");
	
	// Dan:  Wait until four seconds before the end of the intro animation.
	rig_anim = level._scr_anim[ "player_rig" ][ "intro_allies_in_chopper" ];
	anim_length = GetAnimLength( rig_anim );
	assert( anim_length - 4 > 0 );
	
	level._player thread player_lerp_view( anim_length );

	// Dan:  Because we threaded the anim_single, we need to manually wait for the vignette to finish.
	wait anim_length;

	// Anim is done, unlink the player and rig
	level._player unlink();
	
	// Link the player back onto his original chopper
	level._player disableWeapons();
	level._player PlayerLinkTo( level.playerHeli, "tag_player", 0.9, 80, 85, 50, 55 );

	// Get player back on the turret
	toggle_turret_use();

	// Setup player state
	level._player PlayerLinkedTurretAnglesEnable();
	//level._player SetPlayerAngles( ( 0, level.playerHeli.angles[ 1 ], 0 ) );
	level._player DisableTurretDismount();
	level._player enableWeapons();
	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

	// Setup turret state
	level.player_turret SetTurretInitView( false );
	level.player_turret show();
	//level.player_turret.angles = ( 0, level.playerHeli.angles[ 1 ], 0 );

	// Cleanup
	minigun_right delete();
	minigun_left delete();
	player_rig delete();

	// Dont let the allies teleport into position, as they will glitch for one frame well ahead of the copter
	foreach ( guy in level.squad )
	{
		guy.dont_teleport_on_enter_vehicle = true;
	}

	level.playerHeli maps\nx_rocket_util::intro_chopper_allies_setup();

	// Being extra careful
	foreach ( guy in level.squad )
	{
		guy.dont_teleport_on_enter_vehicle = false;
	}
}

player_lerp_view( anim_length )
{
	wait ( anim_length - 4 );
	// Dan:  Four seconds before the end of the anim, start lerping the player's view arc
	// clamp to zero (over three seconds).
	level._player LerpViewAngleClamp( 3, 1, 1, 0, 0, 0, 0 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

opfor_helicopter_intro_spawn()
{
	// Dan:  Using the player's preexisting helicopter for blackhawk_02.

	blackhawk_01 = spawn_anim_model( "blackhawk_01" );
	blackhawk_02 = spawn_anim_model( "blackhawk_02" );
	opfor_heli_02 = vignette_vehicle_spawn("opfor_heli_02", "opfor_heli_02"); //"value" (kvp), "anim_name"
	opfor_heli_01 = vignette_vehicle_spawn("opfor_heli_01", "opfor_heli_01"); //"value" (kvp), "anim_name"
	
	// Dan: For player heli vignettes, we play the anim on a tag_origin model.  Then
	// we smoothly blend the player's heli to match the invisible heli.  Its the only
	// way to get a seemless start to a heli vignette.

	opfor_helicopter_intro(blackhawk_01, blackhawk_02, opfor_heli_02, opfor_heli_01);

	blackhawk_01 vignette_vehicle_delete();
	blackhawk_02 vignette_vehicle_delete();
	opfor_heli_02 vignette_vehicle_delete();
	opfor_heli_01 vignette_vehicle_delete();
}

opfor_helicopter_intro(blackhawk_01, blackhawk_02, opfor_heli_02, opfor_heli_01)
{

	level._player PlaySound( "scn_rocket_heli_bridge" );
	// Dan:  No player-rig animation.  Player remains mounted on the
	// helicopter turret with standard turret controls.

	node = getstruct("vignette_opfor_helicopter_intro", "script_noteworthy");

	opfor_heli_missile_01 = spawn_anim_model("opfor_heli_missile_01");

	opfor_heli_missile_02 = spawn_anim_model("opfor_heli_missile_02");

	guys = [];
	guys["blackhawk_01"] = blackhawk_01;
	guys["blackhawk_02"] = blackhawk_02;	// PLAYER HELI
	guys["opfor_heli_02"] = opfor_heli_02;
	guys["opfor_heli_01"] = opfor_heli_01;
	guys["opfor_heli_missile_01"] = opfor_heli_missile_01;
	guys["opfor_heli_missile_02"] = opfor_heli_missile_02;

	// Dan: For player heli vignettes, we play the anim on a tag_origin model.  Then
	// we smoothly blend the player's heli to match the invisible heli.  Its the only
	// way to get a seemless start to a heli vignette.	
	
	node anim_first_frame( guys, "opfor_helicopter_intro" );
	
	// Dan: This is threaded because we need the vignette to start before we do the
	// link.
	level.playerHeli thread link_preexisting_helicopter_to_vignette( blackhawk_02 );
	level.bridge_intro_ally thread link_preexisting_helicopter_to_vignette( blackhawk_01 );

	//thread maps\nx_rocket_fx::heli_battle_first_missile( opfor_heli_missile_01 );
	node anim_single( guys, "opfor_helicopter_intro" );
	
	// Dan: Exit the player heli from the vignette.
	level.playerHeli ClearAnimScripted();
	level.playerHeli Unlink();	
	level.playerHeli Vehicle_SetSpeedImmediate( 120 ); // last time I checked, this vignette ends with the heli at approx 120 MPH
	level.playerHeli maps\nx_rocket_util::transition_chopper_to_new_path_noteworthy( "chopper_ride_bridge_ambush_resume_node" );

	// Anim is done - hand off back to script
	flag_set( "bridge_enc1_anim_done" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
unset_relink_player_flag_next_frame()
{
	wait 0.05;
	self SetRelinkPlayerFlag( 0 );
}

opfor_helicopter_intro_begin_fp_vignette( blackhawk_02 )
{
	// Dan:  Leaving the player on the turret for this vingette.
	
	// hiding a camera glitch with an earthquake for now
	//Earthquake( 0.5, 1, level._player.origin, 0 );

	level.player_turret Hide();

	// Create a temp origin to position the player inside the anim
	blackhawk_anim_tag = spawn_tag_origin();
	blackhawk_anim_tag.origin = level.playerHeli GetTagOrigin( "tag_origin" );
	blackhawk_anim_tag.angles = level.playerHeli GetTagAngles( "tag_origin" );
	blackhawk_anim_tag LinkTo( level.playerHeli );

	player_turret_bridge = spawn_anim_model( "player_turret_bridge" );
	player_turret_bridge LinkTo( blackhawk_anim_tag, undefined, ( 0, 0, 0 ), ( 0, 0, 0 ) );

	player_rig = spawn_anim_model( "player_rig" );
	player_rig LinkTo( blackhawk_anim_tag, undefined, ( 0, 0, 0 ), ( 0, 0, 0 ) );

	level._player PlayerLinkTo( player_rig, "tag_player", 0.1, 0, 0, 0, 0 );
	level._player PlayerLinkedTurretAnglesEnable();
	level._player SetRelinkPlayerFlag( 1 );
	level._player thread unset_relink_player_flag_next_frame();
	
	guys = [];
	guys[ "player_rig" ] = player_rig;
	guys[ "player_turret_bridge" ] = player_turret_bridge;

	blackhawk_anim_tag anim_single( guys, "opfor_helicopter_intro" );
	
	player_rig delete();
	player_turret_bridge delete();
	
	// Link the player back onto his original chopper
	level._player PlayerLinkTo( level.playerHeli, "tag_player", 0.1, 80, 85, 50, 55 );
	level._player PlayerLinkedTurretAnglesEnable();
	level.player_turret Show();
}
*/
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

helicopter_bridge_spawn()
{
	helicopter_ally = spawn_anim_model( "helicopter_ally" );
	helicopter_opfor = vignette_vehicle_spawn("helicopter_bridge_opfor", "helicopter_opfor"); //"value" (kvp), "anim_name"
	pilot = vignette_actor_spawn("helicopter_bridge_pilot", "pilot"); //"value" (kvp), "anim_name"
	ally_01 = vignette_actor_spawn("helicopter_bridge_ally_01", "ally_01"); //"value" (kvp), "anim_name"
	copilot = vignette_actor_spawn("helicopter_bridge_copilot", "copilot"); //"value" (kvp), "anim_name"
	ally_gunner = vignette_actor_spawn("helicopter_bridge_ally_gunner", "ally_gunner"); //"value" (kvp), "anim_name"
	ally_02 = vignette_actor_spawn("helicopter_bridge_ally_02", "ally_02"); //"value" (kvp), "anim_name"

/*
	pilot = GetEnt( "helicopter_bridge_pilot", "script_noteworthy" );
	pilot.animname = "pilot";

	ally_01 = GetEnt( "helicopter_bridge_ally_01", "script_noteworthy" );
	ally_01.animname = "ally_01";

	copilot = GetEnt( "helicopter_bridge_copilot", "script_noteworthy" );
	copilot.animname = "copilot";
*/

	level.playerHeli maps\nx_rocket_util::chopper_allies_remove();
	helicopter_bridge(helicopter_ally, helicopter_opfor, pilot, level.squad["ALLY_BAKER"], copilot, level.squad["ALLY_WILLIAMS"], level.squad["ALLY_JENKINS"]);
	level.playerHeli maps\nx_rocket_util::intro_chopper_allies_setup();

	helicopter_ally delete();
	//helicopter_opfor vignette_vehicle_delete();
	pilot vignette_actor_delete();
	ally_01 vignette_actor_delete();
	copilot vignette_actor_delete();
	ally_gunner vignette_actor_delete();
	ally_02 vignette_actor_delete();
}

helicopter_bridge(helicopter_ally, helicopter_opfor, pilot, ally_01, copilot, ally_gunner, ally_02)
{
	// The player may have been force killed moments before this
	if ( !isalive( level._player ) || !isalive( level.playerHeli ))
	{
		return;
	}

	node = getstruct("vignette_helicopter_bridge", "script_noteworthy");

	level._player playsound("scn_rocket_bridge_flyby");

	heli_turret = spawn_anim_model("heli_turret");
	player_turret = spawn_anim_model("player_turret");

	bridge_missile = spawn_anim_model("bridge_missile");

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["helicopter_ally"] = helicopter_ally;	// PLAYER HELI
	guys["helicopter_opfor"] = helicopter_opfor;
	guys["bridge_missile"] = bridge_missile;

	// Create a temp origin to position the player inside the anim
	blackhawk_anim_tag = spawn_tag_origin();
	blackhawk_anim_tag.origin = level.playerHeli GetTagOrigin( "tag_origin" );
	blackhawk_anim_tag.angles = level.playerHeli GetTagAngles( "tag_origin" );
	blackhawk_anim_tag LinkTo( level.playerHeli );

	ally_guys = [];
	ally_guys["player_rig"] = player_rig;
	ally_guys["pilot"] = pilot;
	ally_guys["ally_01"] = ally_01;
	ally_guys["copilot"] = copilot;
	ally_guys["ally_gunner"] = ally_gunner;
	ally_guys["heli_turret"] = heli_turret;
	ally_guys["player_turret"] = player_turret;
	ally_guys["ally_02"] = ally_02;
	

	foreach( ally in ally_guys )
	{
		ally LinkTo( blackhawk_anim_tag );
	}

	player_rig.turret = ally_guys["player_turret"];

	player_rig Hide();
	player_rig.turret Hide();
	
	node anim_first_frame( guys, "helicopter_bridge" );

	level.playerHeli thread link_preexisting_helicopter_to_vignette( helicopter_ally );

	player_rig thread force_player_to_look_in_vingette_direction( "helicopter_bridge", "start_player_vignette", 0.5 );

	// Play the anim for the allies
	blackhawk_anim_tag thread anim_single( ally_guys, "helicopter_bridge" );

	// Play the anim for the vehicles
	thread maps\nx_rocket_fx::vtol_bridge_missile_fx( bridge_missile );
	node anim_single(guys, "helicopter_bridge");

	// Anim is done, unlink the player and rig
	level._player unlink();
	player_rig delete();
	heli_turret delete();
	player_turret delete();
	level.player_turret Show();

	// Link the player back onto his original chopper
	level._player PlayerLinkTo( level.playerHeli, "tag_player", 0.1, 80, 85, 50, 55 );

	// Get player back on the turret
	toggle_turret_use();

	// Enable turret correction scripts
	level._player PlayerLinkedTurretAnglesEnable();
	level.player_turret SetTurretInitView( false );

	// Save the enemy chopper
	level.bridge_encounter_2_chopper = helicopter_opfor;

	flag_set( "bridge_anim_done" );

	level._player EnableWeapons();
	level._player ShowViewModel();

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

helicopter_bridge_player( player_rig )
{
	toggle_turret_use();

	arc = 0;
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, true );
	level._player SetRelinkPlayerFlag( 1 );

	player_rig Show();
	player_rig.turret Show();
	level.player_turret Hide();

	wait 0.05;
	level._player SetRelinkPlayerFlag( 0 );

	level._player DisableWeapons();
	level._player HideViewModel();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Delta Chopper Battle 02
chopper_battle_base_delta_02_spawn()
{
	chopper_battle_base_delta_bh_02 = vignette_vehicle_spawn("chopper_battle_base_delta_bh_02", "chopper_battle_base_delta_bh_02"); //"value" (kvp), "anim_name"

	chopper_battle_base_delta_02(chopper_battle_base_delta_bh_02);

	chopper_battle_base_delta_bh_02 vignette_vehicle_delete();
}

chopper_battle_base_delta_02(chopper_battle_base_delta_bh_02)
{
	node = getstruct("chopper_battle_base_delta_02", "script_noteworthy");


	guys = [];
	guys["chopper_battle_base_delta_bh_02"] = chopper_battle_base_delta_bh_02;

	node anim_single(guys, "chopper_battle_base_delta_02");

}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Delta Chopper Battle 03
chopper_battle_base_delta_03_spawn()
{
	chopper_battle_delta_bh_03 = vignette_vehicle_spawn("chopper_battle_delta_bh_03", "chopper_battle_delta_bh_03"); //"value" (kvp), "anim_name"
	chopper_battle_delta_lb_02 = vignette_vehicle_spawn("chopper_battle_delta_lb_02", "chopper_battle_delta_lb_02"); //"value" (kvp), "anim_name"
	chopper_battle_delta_lb_03 = vignette_vehicle_spawn("chopper_battle_delta_lb_03", "chopper_battle_delta_lb_03"); //"value" (kvp), "anim_name"

	chopper_battle_base_delta_03(chopper_battle_delta_bh_03, chopper_battle_delta_lb_02, chopper_battle_delta_lb_03);

	chopper_battle_delta_bh_03 vignette_vehicle_delete();
	chopper_battle_delta_lb_02 vignette_vehicle_delete();
	chopper_battle_delta_lb_03 vignette_vehicle_delete();
}

chopper_battle_base_delta_03(chopper_battle_delta_bh_03, chopper_battle_delta_lb_02, chopper_battle_delta_lb_03)
{

	node = getstruct("vignette_chopper_delta_base_battle_02", "script_noteworthy");


	guys = [];
	guys["chopper_battle_delta_bh_03"] = chopper_battle_delta_bh_03;
	guys["chopper_battle_delta_lb_02"] = chopper_battle_delta_lb_02;
	guys["chopper_battle_delta_lb_03"] = chopper_battle_delta_lb_03;

	node anim_single(guys, "chopper_battle_base_delta_03");

}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Delta Chopper Battle 04
chopper_battle_base_delta_04_spawn()
{
	chopper_battle_delta_bh_03 = vignette_vehicle_spawn("chopper_battle_delta_bh_03", "chopper_battle_delta_bh_03"); //"value" (kvp), "anim_name"

	chopper_battle_base_delta_04(chopper_battle_delta_bh_03);

	chopper_battle_delta_bh_03 vignette_vehicle_delete();
}

chopper_battle_base_delta_04(chopper_battle_delta_bh_03)
{

	node = getstruct("vignette_chopper_battle_delta_04", "script_noteworthy");


	guys = [];
	guys["chopper_battle_delta_bh_03"] = chopper_battle_delta_bh_03;

	node anim_single(guys, "chopper_battle_base_delta_04");

}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Delta Chopper Battle 05
chopper_battle_base_delta_05_spawn()
{
	chopper_battle_delta_bh_03 = vignette_vehicle_spawn("chopper_battle_delta_bh_03", "chopper_battle_delta_bh_03"); //"value" (kvp), "anim_name"

	//call sounds for this chopper going down
	thread maps\nx_rocket_audio::rocket_helo_battle_delta_05_sounds(chopper_battle_delta_bh_03);	

	chopper_battle_base_delta_05(chopper_battle_delta_bh_03);
	
	chopper_battle_delta_bh_03 vignette_vehicle_delete();
}

chopper_battle_base_delta_05(chopper_battle_delta_bh_03)
{

	node = getstruct("vignette_chopper_battle_delta_05", "script_noteworthy");


	guys = [];
	guys["chopper_battle_delta_bh_03"] = chopper_battle_delta_bh_03;

	chopper_battle_delta_bh_03 thread maps\nx_rocket_fx::base_delta_heli_crash_01( chopper_battle_delta_bh_03 );
	node anim_single(guys, "chopper_battle_base_delta_05");

}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

chopper_dogfight_base_delta_01_spawn()
{
	delta_01_player_heli = vignette_vehicle_spawn("vignette_delta_dogfight_01_player_heli", "delta_01_player_heli"); //"value" (kvp), "anim_name"
	delta_01_ally_heli = vignette_vehicle_spawn("vignette_delta_dogfight_01_ally_heli", "delta_01_ally_heli"); //"value" (kvp), "anim_name"
	delta_01_opfor_heli_02 = vignette_vehicle_spawn("vignette_delta_dogfight_01_opfor_heli", "delta_01_opfor_heli_02"); //"value" (kvp), "anim_name"
	delta_01_opfor_heli_01 = vignette_vehicle_spawn("vignette_delta_dogfight_01_opfor_heli_02", "delta_01_opfor_heli_01"); //"value" (kvp), "anim_name"

	// Save these guys for later.  The player will need to chase and shoot them
	level.dogfight_01_vtol = delta_01_opfor_heli_02;
	level.dogfight_01_vtol godon();
	level.dogfight_01_vtol thread set_speed_when_killed( 120 );
	level.dogfight_01_vtol.no_navigation = true;
	thread maps\_attack_heli::begin_attack_heli_behavior( level.dogfight_01_vtol );
	level.dogfight_01_vtol delayThread( 6, ::chopper_dogfight_base_delta_01_logic, delta_01_ally_heli );

	level.dogfight_01_ally = delta_01_ally_heli;
	level.dogfight_01_ally godon();
	level.dogfight_01_ally thread set_speed_when_killed( 120 );

	// Dan: For player heli vignettes, we play the anim on an invisible heli.  Then
	// we smoothly blend the player's heli to match the invisible heli.  Its the only
	// way to get a seemless start to a heli vignette.
	delta_01_player_heli Hide();

	chopper_dogfight_base_delta_01(delta_01_player_heli, delta_01_ally_heli, delta_01_opfor_heli_02, delta_01_opfor_heli_01);

	delta_01_player_heli vignette_vehicle_delete();
	//delta_01_ally_heli vignette_vehicle_delete();
	//delta_01_opfor_heli_02 vignette_vehicle_delete();
	delta_01_opfor_heli_01 vignette_vehicle_delete();
}

chopper_dogfight_base_delta_01(delta_01_player_heli, delta_01_ally_heli, delta_01_opfor_heli_02, delta_01_opfor_heli_01)
{
	node = getstruct("vignette_delta_dogfight_01", "script_noteworthy");

	guys = [];
	guys["delta_01_player_heli"] = delta_01_player_heli;
	guys["delta_01_ally_heli"] = delta_01_ally_heli;
	guys["delta_01_opfor_heli_02"] = delta_01_opfor_heli_02;
	guys["delta_01_opfor_heli_01"] = delta_01_opfor_heli_01;

	level notify( "chopper_dogfight_base_delta_01_anim_started" );
	
	// Dan: For player heli vignettes, we play the anim on an invisible heli.  Then
	// we smoothly blend the player's heli to match the invisible heli.  Its the only
	// way to get a seemless start to a heli vignette.
	
	node anim_first_frame( guys, "chopper_dogfight_base_delta_01" );
	
	// Dan: This is threaded because we need the vignette to start before we do the
	// link.
	level.playerHeli thread link_preexisting_helicopter_to_vignette( delta_01_player_heli );

	// quickly switch to cinematic camera controls
	maps\nx_rocket_util::set_link_view_fraction_cinematic( 0.2 );
	
	node anim_single( guys, "chopper_dogfight_base_delta_01" );
	

	// Dan: Exit the player heli from the vignette.
	level.playerHeli Unlink();
	level.playerHeli ClearAnimScripted();
	level.playerHeli Vehicle_SetSpeedImmediate( 80 ); // last time I checked, this vignette ends with the heli at approx 80 MPH
	level.playerHeli Vehicle_DetachFromPath();
	level.playerHeli Vehicle_ResumePath();
	level.playerHeli GoPath();

	// smoothly switch to gameplay camera controls
	maps\nx_rocket_util::set_link_view_fraction_gameplay( 3 );

	level notify( "chopper_dogfight_base_delta_01_anim_done" );
}


// Animated VTOL is forced to fire on the allied chopper
chopper_dogfight_base_delta_01_logic( target )
{
	self endon( "death" );

	while( 1 )
	{
		wait( RandomFloatRange( 0.7, 1.0 ) );
		self.eTarget = target;
		maps\_attack_heli::fire_guns();
	
		// Target died? Good shooting soldier
		if( !isAlive( target ))
		{
			return;
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

chopper_dogfight_base_delta_02_spawn()
{
	// Dan: Turning off for now.
}

/*
USE_PLAYER_HELI_FOR_CHOPPER_DOGFIGHT_BASE_DELTA_02 = false;

// chopper dogfight 02
chopper_dogfight_base_delta_02_spawn()
{
	chopper_dogfight_base_delta_bh_02 = vignette_vehicle_spawn("chopper_dogfight_base_delta_bh_02", "chopper_dogfight_base_delta_bh_02"); //"value" (kvp), "anim_name"
	chopper_dogfight_base_delta_hind_02 = vignette_vehicle_spawn("opfor_heli_01", "chopper_dogfight_base_delta_hind_02"); //"value" (kvp), "anim_name"
	chopper_dogfight_base_delta_hind_02a = vignette_vehicle_spawn("opfor_heli_02", "chopper_dogfight_base_delta_hind_02a"); //"value" (kvp), "anim_name"

	if ( USE_PLAYER_HELI_FOR_CHOPPER_DOGFIGHT_BASE_DELTA_02 )
	{
		// Dan: For player heli vignettes, we play the anim on an invisible heli.  Then
		// we smoothly blend the player's heli to match the invisible heli.  Its the only
		// way to get a seemless start to a heli vignette.
		chopper_dogfight_base_delta_bh_02 Hide();
	}

	chopper_dogfight_base_delta_02(chopper_dogfight_base_delta_bh_02, chopper_dogfight_base_delta_hind_02, chopper_dogfight_base_delta_hind_02a);
	
	chopper_dogfight_base_delta_bh_02 vignette_vehicle_delete();
	chopper_dogfight_base_delta_hind_02 vignette_vehicle_delete();
	chopper_dogfight_base_delta_hind_02a vignette_vehicle_delete();
}

chopper_dogfight_base_delta_02(chopper_dogfight_base_delta_bh_02, chopper_dogfight_base_delta_hind_02, chopper_dogfight_base_delta_hind_02a)
{

	node = getstruct("chopper_dogfight_base_delta_flag", "script_noteworthy");

	guys = [];
	guys["chopper_dogfight_base_delta_bh_02"] = chopper_dogfight_base_delta_bh_02;
	guys["chopper_dogfight_base_delta_hind_02"] = chopper_dogfight_base_delta_hind_02;
	guys["chopper_dogfight_base_delta_hind_02a"] = chopper_dogfight_base_delta_hind_02a;

	if ( USE_PLAYER_HELI_FOR_CHOPPER_DOGFIGHT_BASE_DELTA_02 )
	{
		// Dan: For player heli vignettes, we play the anim on an invisible heli.  Then
		// we smoothly blend the player's heli to match the invisible heli.  Its the only
		// way to get a seemless start to a heli vignette.
		
		node anim_first_frame( guys, "chopper_dogfight_base_delta_02" );
		
		// Dan: This is threaded because we need the vignette to start before we do the
		// link.
		level.playerHeli thread link_preexisting_helicopter_to_vignette( chopper_dogfight_base_delta_bh_02 );
	
		// quickly switch to cinematic camera controls
		maps\nx_rocket_util::set_link_view_fraction_cinematic( 0.2 );
	}

	node anim_single(guys, "chopper_dogfight_base_delta_02");
	
	if ( USE_PLAYER_HELI_FOR_CHOPPER_DOGFIGHT_BASE_DELTA_02 )
	{
		// Dan: Exit the player heli from the vignette.
		level.playerHeli Unlink();
		level.playerHeli Vehicle_Teleport( level.playerHeli.origin, level.playerHeli.angles );
		level.playerHeli Vehicle_SetSpeedImmediate( 15 ); // last time I checked, this vignette ends with the heli at approx 15 MPH
		level.playerHeli Vehicle_DetachFromPath();
		level.playerHeli Vehicle_ResumePath();
		level.playerHeli GoPath();
	
		// smoothly switch to gameplay camera controls
		maps\nx_rocket_util::set_link_view_fraction_gameplay( 3 );
	}
}
*/

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//AA Turret Shoot Helicopter
aa_turret_shoot_helicopter_spawn()
{
	nx_blackhawk_shot_down = vignette_vehicle_spawn("nx_blackhawk_shot_down", "nx_blackhawk_shot_down"); //"value" (kvp), "anim_name"

	aa_turret_shoot_helicopter(nx_blackhawk_shot_down);

	nx_blackhawk_shot_down vignette_vehicle_delete();
}

aa_turret_shoot_helicopter(nx_blackhawk_shot_down)
{

	node = getstruct("shoot_heli", "script_noteworthy");

	aa_turret_fire = spawn_anim_model("aa_turret_fire");


	guys = [];
	guys["aa_turret_fire"] = aa_turret_fire;
	guys["nx_blackhawk_shot_down"] = nx_blackhawk_shot_down;

	node anim_single(guys, "aa_turret_shoot_helicopter");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//Gantry Arms 1
gantry_arms_hose_01_spawn()
{

	gantry_arms_hose_01();

}

gantry_arms_hose_01()
{

	node = getstruct("vignette_gantry_arms_01", "script_struct");

	gantry_hose_01 = spawn_anim_model("gantry_hose_01");

	gantry_arms_01 = spawn_anim_model("gantry_arms_01");

	gantry_arms_02 = spawn_anim_model("gantry_arms_02");


	guys = [];
	guys["gantry_hose_01"] = gantry_hose_01;
	guys["gantry_arms_01"] = gantry_arms_01;
	guys["gantry_arms_02"] = gantry_arms_02;

	node anim_single(guys, "gantry_arms_hose_01");

}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

aa_control_breach( enemy_01, enemy_02, door_01, door_02, ally_jenkins, ally_williams )
{

	node = getstruct("vignette_rocket_aa_control_melee", "script_noteworthy");

	guys = [];
	guys["ally_jenkins"] = ally_jenkins;
	guys["ally_williams"] = ally_williams;
	guys["enemy_01"] = enemy_01;
	guys["enemy_02"] = enemy_02;
	guys["door_01"] = door_01;
	guys["door_02"] = door_02;

	enemy_01.animname = "enemy_opfor_01";
	enemy_02.animname = "enemy_opfor_02";

	allies = [ ally_williams, ally_jenkins ];
	enemies = [ enemy_01, enemy_02 ];

	node thread anim_first_frame( enemies, "aa_control_melee" );
	node anim_reach( allies, "aa_control_melee" );

	maps\nx_rocket_util::squad_color_reset();
	issue_color_orders( "p103 b103", "allies" );

//  flag_wait( "vignette_aa_control_melee" );
	breach_trigger = GetEnt( "turret_trigger_breach", "script_noteworthy" );
	breach_trigger maps\nx_rocket_util::trigger_waittill_use( "Hold [{+usereload}] to breach");

	node thread aa_control_breach_player();
	node anim_single( guys, "aa_control_melee" );

	foreach( enemy in enemies )
	{
		enemy vignette_actor_kill();
	}
}

aa_control_breach_player()
{
	node = getstruct("vignette_rocket_aa_control_melee", "script_noteworthy");

	level._player HideViewModel();
	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );
	player_legs = vignette_actor_spawn("wakeup_player_legs", "player_legs"); //"value" (kvp), "anim_name"

	arc = 5;
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1 );

	guys = [];
	guys[ "player_rig" ] = player_rig;
	guys[ "player_legs" ] = player_legs;

	level._player notify( "breaching" );

	node anim_single( guys, "aa_control_melee" );

	level._player notify( "breached" );

	level._player unlink();

	player_rig delete();
	player_legs vignette_actor_delete();

	level._player ShowViewModel( );
	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

	flag_set( "turret_control_player_breached" );
}

aa_control_breach_door_setup()
{
	node = getstruct("vignette_rocket_aa_control_melee", "script_noteworthy");

	doors = [];
	doors[ doors.size ] = spawn_anim_model( "aa_control_door_01" );
	doors[ doors.size ] = spawn_anim_model( "aa_control_door_02" );

	node thread anim_first_frame( doors, "aa_control_melee" );

	return doors;
}

aa_exit_door_setup()
{
	node = getstruct("vignette_rocket_aa_exit_melee_01", "script_noteworthy");

	doors = [];
	doors[ doors.size ] = spawn_anim_model( "aa_exit_door_01" );
	doors[ doors.size ] = spawn_anim_model( "aa_exit_door_02" );

	node thread anim_first_frame( doors, "aa_exit_melee" );

	return doors;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
vtol_breakapart()
{
	node = getstruct("vignette_ec_vtol_breakapart", "script_noteworthy");
	node.origin = self GetTagOrigin( "tag_origin" );
	node.angles = self GetTagAngles( "tag_origin" );
	ec_vtol_destroyed = spawn_anim_model("ec_vtol_destroyed");

	guys = [];
	guys["ec_vtol_destroyed"] = ec_vtol_destroyed;

	self delete();
	node anim_first_frame(guys, "ec_vtol_breakapart");
	ec_vtol_destroyed playsound("scn_rocket_vtol_boss_explode");
	thread maps\nx_rocket_fx::vtol_explode_fx( ec_vtol_destroyed );
	node anim_single(guys, "ec_vtol_breakapart");
}