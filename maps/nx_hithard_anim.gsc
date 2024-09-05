//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Hit Hard at Home Anim Support								**
//                                                                          **
//    Created: 10/4/2010 - Brian Marvin										**
//                                                                          **
//****************************************************************************
#include common_scripts\utility;
#include common_scripts\_nx_fx;
#include maps\_utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_nx_vignette_util;
//#include maps\_hud_util;

main()
{
	// Building falls and other sequences
	flag_init( "flag_building_fall_1" );
	flag_init( "flag_building_fall_2" );
	flag_init( "flag_building_fall_4" );
	flag_init( "flag_building_fall_5" );
	flag_init( "hanging_guys_delete" );
	flag_init( "hithard_motorcade_building_fall" );
	flag_init( "parachute_trigger_building03_04_fx_cleanup_building01" );
	flag_init( "flag_parachute_building3_pre_explosions" );
	flag_init( "flag_parachute_building3_explosion_right_fx1" );
	flag_init( "flag_parachute_building3_explosion_left_fx1" );
	flag_init( "intro_aa_start" );
	flag_init( "parachute_trigger_building02_amb_fx" );	
	flag_init( "parachute_trigger_amb_fx_1" );	
	flag_init( "flag_script_parachute_rooftop_civvies" );

	player();
	generic_human();
	vehicles();
	vehicle_parachute();
	script_models();
	dialog();

	// building script model spawning
	building_script_models();

	thread parachute_missilehits_periph();
	thread building03_pre_fx();
	thread misc_parachute_fx_cleanup();
	thread parachute_amb_explosions();
	//thread parachute_rooftop_civvies();  -Disabled until we can find a better way to implement this scene

	thread building03_explosion_right(); 
	thread building03_explosion_left(); 
	// Initializes the crowd controller
	maps\nx_crowd_controller::main();

	level thread vignettes();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Civilians on rooftop prior to building 2
parachute_rooftop_civvies()
{
    civvies = GetEntArray( "actor_parachute_rooftop_civvie", "script_noteworthy" );
    foreach( guy in civvies )
    {
        guy spawn_ai();
    }

    flag_wait( "floatingbody_civ_01_delete" );

    foreach( guy in civvies )
    {
        guy delete();
    }
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
vignettes()
{
		// vp meet and greet loop - commented out so it could be triggered by design
		//level thread vignette_register( ::vp_loop_spawn, "vignette_vpmeetandgreet_loop" );

		// vp meet and greet. - commented out so it could be triggered by design
	   //level thread vignette_register( ::vp_meet_and_greet_spawn, "vignette_vp_meet_and_greet" );

		//osprey vp pick up crash - commented out so it could be triggered by design
	   //level thread vignette_register( ::nx_vh_ospreycrashvp_osprey_01_spawn, "vignette_ospreycrashvp_osprey_01" );


		//chinese vtol ugv dropoff - commented out so it could be triggered by design
	   //level thread vignette_register( ::nx_vh_chinese_vtol_ugv_drop_spawn, "vignette_chinese_vtol_ugv_dropoff" );

		//baker door smash in the cortel - commented out so it could be triggered by design
		//level thread vignette_register( ::nx_tp_hithard_doorsmash_ally_01_spawn, "vignette_hithard_doorsmash_ally_01" );
		
		// vp gets hit running up highway ramp
		
		// Civilian floating in pool
		level thread vignette_register( ::floatingbody_civ_01_spawn, "vignette_floating_civ" );

		//ec ugv reveal and blows up cars
		level thread vignette_register( ::nx_vh_hithard_ugv_reveal_spawn, "vignette_ec_ugv_blow_up_cars" );
          
		//ec_vtol_miniuav_deploy
        flag_init( "start_vtol_miniuav_unload" );  // init flag (since the flag is called from script, not on trigger in radiant)
		level thread vignette_register( ::nx_vh_hithard_vtol_uav_deploy_spawn, "start_vtol_miniuav_unload" );
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "player" );
player()
{
	level._scr_animtree[ "player_rig" ]								= #animtree;
	level._scr_model[ "player_rig" ] 								= "nx_fp_viewmodel_parachute";

	level._scr_anim[ "player_rig" ][ "parachute_jump" ]				= %nx_fp_viewmodel_parachute_jumping;
	level._scr_anim[ "player_rig" ][ "Osprey_Intro" ]				= %nx_fp_hithard_intro_player_01;
	addNotetrack_customFunction( "player_rig", "player_unlink", ::player_unlink );
	addNotetrack_customFunction( "player_rig", "ally_parachute_spawn", ::ally_parachute_spawn );
	addNotetrack_customFunction( "player_rig", "intro_aa_start", ::intro_aa_start );

	//vp meet and greet
	level._scr_anim[ "player_rig" ][ "vp_meet_and_greet" ] = %nx_fp_hithard_vp_meetandgreet2_player_01;

	// Rappel. 	
	level._scr_animtree[ "player_rig_rappel" ]								= #animtree;
	level._scr_model[ "player_rig_rappel" ] 								= "viewhands_us_specops_scripted"; 
	level._scr_anim[ "player_rig_rappel" ][ "rappel_hookup" ] 				= %nx_fp_hithard_rappel;
//	level._scr_anim[ "player_rig_rappel" ][ "rappel_root" ] 				= %cave_rappel;	
}

#using_animtree( "vehicles" );
vehicle_parachute()
{
	// Parachute land
	level._scr_anim[ "anim_parachute_ally_01" ][ "anim_parachute_land" ]	= %nx_vh_hhh_parachute_landed;
	level._scr_model[ "anim_parachute_ally_01" ]							= "vehicle_parachute";
	level._scr_animtree[ "anim_parachute_ally_01" ]							= #animtree;
	
    level._scr_anim[ "anim_parachute_ally_02" ][ "anim_parachute_land" ]	= %nx_vh_hhh_parachute_landed_guy2;
    level._scr_model[ "anim_parachute_ally_02" ]							= "vehicle_parachute";
    level._scr_animtree[ "anim_parachute_ally_02" ]							= #animtree;
}

#using_animtree( "generic_human" );
generic_human()
{
	// Parachute land
	level._scr_anim[ "anim_parachute_land_ally_01" ][ "anim_parachute_land" ] = %nx_tp_hhh_parachute_landed;
    level._scr_anim[ "anim_parachute_land_ally_02" ][ "anim_parachute_land" ] = %nx_tp_hhh_parachute_landed_guy2;

	// Building02 Hanging Civilians
	/*level._scr_anim[ "hanging_01" ][ "hanging" ][0] = %nx_tp_hithard_hanging_civ_loop_01;
	level._scr_anim[ "hanging_02" ][ "hanging" ][0] = %nx_tp_hithard_hanging_civ_loop_02;
	level._scr_anim[ "hanging_03" ][ "hanging" ][0] = %nx_tp_hithard_hanging_civ_loop_01;
	level._scr_anim[ "hanging_04" ][ "hanging" ][0] = %nx_tp_hithard_hanging_civ_loop_01;
	level._scr_anim[ "hanging_05" ][ "hanging" ][0] = %nx_tp_hithard_hanging_civ_loop_02;
	level._scr_anim[ "hanging_06" ][ "hanging" ][0] = %nx_tp_hithard_hanging_civ_loop_02;
	level._scr_anim[ "hanging_07" ][ "hanging" ][0] = %nx_tp_hithard_hanging_civ_loop_01;
	level._scr_anim[ "hanging_08" ][ "hanging" ][0] = %nx_tp_hithard_hanging_civ_loop_01;
	level._scr_anim[ "hanging_09" ][ "hanging" ][0] = %nx_tp_hithard_hanging_civ_loop_02;
	level._scr_anim[ "hanging_10" ][ "hanging" ][0] = %nx_tp_hithard_hanging_civ_loop_01;
	level._scr_anim[ "hanging_11" ][ "hanging" ][0] = %nx_tp_hithard_hanging_civ_loop_02;
	level._scr_anim[ "hanging_12" ][ "hanging" ][0] = %nx_tp_hithard_hanging_civ_loop_01;
	level._scr_anim[ "hanging_13" ][ "hanging" ][0] = %nx_tp_hithard_hanging_civ_loop_02;
	level._scr_anim[ "hanging_14" ][ "hanging" ][0] = %nx_tp_hithard_hanging_civ_loop_02;*/

	//level._scr_anim[ "hanging_civ" ][ "falling" ]	= %nx_tp_hithard_hanging_civ_01;

    level._scr_anim[ "ally01" ][ "Osprey_Intro" ] = %nx_tp_hithard_intro_ally01;
    level._scr_anim[ "ally02" ][ "Osprey_Intro" ] = %nx_tp_hithard_intro_ally02;
    level._scr_anim[ "ally03" ][ "Osprey_Intro" ] = %nx_tp_hithard_intro_ally03;
    level._scr_anim[ "ally04" ][ "Osprey_Intro" ] = %nx_tp_hithard_intro_ally04;
    level._scr_anim[ "ally05" ][ "Osprey_Intro" ] = %nx_tp_hithard_intro_ally05;
    level._scr_anim[ "player_body" ][ "Osprey_Intro" ] = %nx_tp_hithard_intro_player_body;
    level._scr_anim[ "pilot01" ][ "Osprey_Intro" ] = %nx_tp_hithard_intro_pilot01;
    level._scr_anim[ "pilot02" ][ "Osprey_Intro" ] = %nx_tp_hithard_intro_pilot02;

	//level._scr_anim[ "secret_service2" ][ "vp_meet_and_greet" ] = %nx_tp_hithard_vp_meetandgreet_ally_02;
	level._scr_anim[ "baker" ][ "vp_meet_and_greet" ] = %nx_tp_hithard_vp_meetandgreet_ally_03;
	level._scr_anim[ "gypsy" ][ "vp_meet_and_greet" ] = %nx_tp_hithard_vp_meetandgreet_ally_04;

	// Civilian floating in pool
	level._scr_anim[ "floating_civ_01" ][ "floatingbody_civ_01" ] [0] = %nx_tp_hithard_floatingbody_civ_01;

	// Sniper perch climb up
	level._scr_anim[ "baker" ][ "nx_tp_hithard_sniper_climbing_a" ] = %nx_tp_hithard_sniper_climbing_a;
	level._scr_anim[ "gypsy" ][ "nx_tp_hithard_sniper_climbing_b" ] = %nx_tp_hithard_sniper_climbing_b;
	addNotetrack_customFunction( "baker", "climb_start", ::rooftop_climb_up_notify );
	addNotetrack_customFunction( "gypsy", "climb_start", ::rooftop_climb_up_notify );

	// vp meet and greet loop
	level._scr_anim[ "secret_service1" ][ "vp_loop" ][0] = %nx_tp_hithard_vp_meetandgreet_ss1_loop;
	level._scr_anim[ "vp" ][ "vp_loop" ][0] = %nx_tp_hithard_vp_meetandgreet_vp2_loop;

	//vp meet and greet
	level._scr_anim[ "vp" ][ "vp_meet_and_greet" ] = %nx_tp_hithard_vp_meetandgreet_vp2;
	level._scr_anim[ "secret_service1" ][ "vp_meet_and_greet" ] = %nx_tp_hithard_vp_meetandgreet_ally_01;

	// vp idle
	level._scr_anim[ "vp" ][ "idle_combat" ] = [ %nx_tp_hithard_VP_idle ];
	level._scr_anim[ "vp" ][ "idle_noncombat" ] = [ %nx_tp_hithard_VP_idle ];

	// baker door smash in the cortel 
	level._scr_anim[ "baker_doorsmash" ][ "nx_tp_hithard_doorsmash_ally_01" ] = %nx_tp_hithard_doorsmash_ally_01;

	// hallway scene
	level._scr_anim["baker"]["bog_radio_dialogue"]	= %bog_radio_dialogue;
	level._scr_anim["vp"]["nx_tp_hithard_vp_rest_VP"]	= %nx_tp_hithard_vp_rest_VP;
	level._scr_anim["vp"]["nx_tp_hithard_vp_rest_VP_end"]	= %nx_tp_hithard_vp_rest_VP_end;
	level._scr_anim["vp"]["nx_tp_hithard_vp_rest_VP_idle"][0]	= %nx_tp_hithard_vp_rest_VP_idle;
	level._scr_anim["ss"]["nx_tp_hithard_vp_rest_SS_idle"][0]	= %nx_tp_hithard_vp_rest_SS_idle;
	level._scr_anim["ss"]["nx_tp_hithard_vp_rest_ss_end"]	= %nx_tp_hithard_vp_rest_ss_end;
	//level._scr_anim["gypsy"]["CornerCrR_alert_painA"]	= %CornerCrR_alert_painA;

	// Door Kick
	level._scr_anim[ "baker" ][ "door_kick_in" ] = %door_kick_in;

	// SS Agent loop
	//level._scr_anim[ "agent" ][ "casual_crouch_idle" ][ 0 ] = %casual_crouch_idle;
	level._scr_anim[ "agent2" ][ "hunted_tunnel_guy2_idle" ][ 0 ] = %hunted_tunnel_guy2_idle;
	level._scr_anim[ "agent3" ][ "hunted_tunnel_guy1_idle" ][ 0 ] = %hunted_tunnel_guy1_idle;

	// VP protect
	level._scr_anim[ "vp" ][ "vp_arrival_in" ] = %nx_tp_hithard_vp_dodge_in;
    level._scr_anim[ "vp" ][ "vp_arrival_idle" ] = %nx_tp_hithard_vp_dodge_idle;
    level._scr_anim[ "vp" ][ "vp_arrival_out" ] = %nx_tp_hithard_vp_dodge_out;
	level._scr_anim[ "ss" ][ "vp_arrival_in" ] = %nx_tp_hithard_ss_dodge_in;
    level._scr_anim[ "ss" ][ "vp_arrival_idle" ] = %nx_tp_hithard_ss_dodge_idle;
    level._scr_anim[ "ss" ][ "vp_arrival_out" ] = %nx_tp_hithard_ss_dodge_out;

	// Rappel
	level._scr_anim[ "baker" ][ "rappel_idle" ][0] = %nx_tp_hithard_rappel_baker_idle;
	level._scr_anim[ "baker" ][ "rappel_intro" ] = %nx_tp_hithard_rappel_baker_intro;
	level._scr_anim[ "baker" ][ "rappel_outro" ] = %nx_tp_hithard_rappel_baker_outro;
	level._scr_anim[ "duke" ][ "rappel_idle" ][0] = %nx_tp_hithard_rappel_duke_idle;
	level._scr_anim[ "duke" ][ "rappel_intro" ] = %nx_tp_hithard_rappel_duke_intro;
	level._scr_anim[ "duke" ][ "rappel_outro" ] = %nx_tp_hithard_rappel_duke_outro;

}

#using_animtree("vehicles");
vehicles()
{
    level._scr_anim[ "hithard_osprey_02" ][ "Osprey_Intro" ] = %nx_vh_hithard_Intro_Osprey02;
    level._scr_anim[ "hithard_osprey_01" ][ "Osprey_Intro" ] = %nx_vh_hithard_Intro_Osprey01;
	addNotetrack_customFunction( "hithard_osprey_01", "intro_explosion_hide", maps\nx_hithard_parachute::intro_explosion_hide );

    level._scr_anim[ "hithard_osprey_03" ][ "Osprey_Intro" ] = %nx_vh_hithard_Intro_Osprey03;
	level._scr_anim[ "hithard_osprey_04" ][ "Osprey_Intro" ] = %nx_vh_hithard_Intro_Osprey04;

	//ec_vtol_miniuav_deploy
	level._scr_anim[ "ec_vtol_miniuav_deploy_vtol" ][ "nx_vh_hithard_vtol_uav_deploy" ] = %nx_vh_hithard_vtol_uav_deploy;
	addNotetrack_customFunction( "ec_vtol_miniuav_deploy_vtol", "unload_miniuavs", ::unloadvtolminiuavs );

	level._scr_anim[ "dropoff_suv_01" ][ "nx_vh_chinese_vtol_ugv_drop" ] = %nx_vh_chinese_vtol_ugv_dropoff_suv_01;
	addNotetrack_customFunction( "dropoff_suv_01", "modelswap", ::chinese_vtol_ugv_dropoff_swap );

	level._scr_anim[ "dropoff_ugv_01" ][ "nx_vh_chinese_vtol_ugv_drop" ] = %nx_vh_chinese_vtol_ugv_dropoff_ugv_01;
	level._scr_anim[ "dropoff_chinese_vtol_01" ][ "nx_vh_chinese_vtol_ugv_drop" ] = %nx_vh_chinese_vtol_ugv_dropoff_chinese_vtol_01;

	//osprey vp pick up crash
	level._scr_anim[ "ospreycrashvp" ][ "nx_vh_ospreycrashvp_osprey_01" ] = %nx_vh_hithard_ospreycrashvp_osprey_01;
	
	// [kmckisic] these are the note track hooks to cue the Osprey effects - disabled for now...

    addNotetrack_customFunction( "ospreycrashvp", "fx_start", maps\nx_hithard_fx::fx_ospreycrashvp_start );
	addNotetrack_customFunction( "ospreycrashvp", "fx_start", maps\nx_hithard_fx::fx_ospreycrashvp_hit_by_ugv );
	addNotetrack_customFunction( "ospreycrashvp", "fx_start_flare",  maps\nx_hithard_fx::fx_ospreycrashvp_flare );
	//addNotetrack_customFunction( "ospreycrashvp", "fx_start_hover",  maps\nx_hithard_fx::fx_ospreycrashvp_hover );
	//addNotetrack_customFunction( "ospreycrashvp", "fx_start_veer",  maps\nx_hithard_fx::fx_ospreycrashvp_veer );
	addNotetrack_customFunction( "ospreycrashvp", "fx_start_crash",  maps\nx_hithard_fx::fx_ospreycrashvp_crash );

    // [andym] notetrack hooks for the osprey intro.
    addNotetrack_customFunction( "hithard_osprey_01", "fx_test_osp01_nt", maps\nx_hithard_fx::fx_start_osprey_intro );
    addNotetrack_customFunction( "hithard_osprey_02", "fx_engines_on_osp02_nt", maps\nx_hithard_fx::fx_ospreyintro_osp02_engines_on );
    addNotetrack_customFunction( "hithard_osprey_03", "fx_engines_on_osp03_nt", maps\nx_hithard_fx::fx_ospreyintro_osp03_engines_on );
    addNotetrack_customFunction( "hithard_osprey_04", "fx_engines_on_osp04_nt", maps\nx_hithard_fx::fx_ospreyintro_osp04_engines_on );
    addNotetrack_customFunction( "hithard_osprey_02", "fx_thrust_osp02_nt", maps\nx_hithard_fx::fx_ospreyintro_osp02_thrust );
    addNotetrack_customFunction( "hithard_osprey_01", "fx_start_aa_osp01_nt", maps\nx_hithard_fx::fx_ospreyintro_start_aa );
    addNotetrack_customFunction( "hithard_osprey_02", "fx_hit_osp02_nt", maps\nx_hithard_fx::fx_ospreyintro_osp02_hit );


    addNotetrack_customFunction( "player_rig", "intro_aa_start", maps\nx_hithard_fx::fx_ospreyintro_jumping_out );
    addNotetrack_customFunction( "pilot02", "ps_hithard_pilot_intro_clearjump", maps\nx_hithard_fx::fx_ospreyintro_backdoor_open );

    //ec ugv reveal and blows up cars
	level._scr_anim[ "sedan_car1" ][ "nx_vh_hithard_ugv_reveal" ] = %nx_vh_hithard_ec_ugv_pullup_sedan_1;
	level._scr_anim[ "sedan_car2" ][ "nx_vh_hithard_ugv_reveal" ] = %nx_vh_hithard_ec_ugv_pullup_sedan_2;

}

#using_animtree("script_model");
script_models()
{
	level._scr_animtree[ "dropoff_suv_02" ] = #animtree;
	level._scr_anim[ "dropoff_suv_02" ][ "nx_vh_chinese_vtol_ugv_drop" ] = %nx_vh_chinese_vtol_ugv_dropoff_suv_02;
	level._scr_model[ "dropoff_suv_02" ] = "nx_pr_vh_president_suv_damaged_back";
	addNotetrack_customFunction( "dropoff_suv_02", "fx_suv_02_smash_01_nt", maps\nx_hithard_fx::fx_suv_02_smash_01 );

	
	//baker door smash in the cortel 
	level._scr_animtree[ "baker_doorsmash_door" ] = #animtree;
	level._scr_anim[ "baker_doorsmash_door" ][ "nx_tp_hithard_doorsmash_ally_01" ] = %nx_pr_hithard_doorsmash_cortel_door_01;
	level._scr_model[ "baker_doorsmash_door" ] = "nx_pr_hithard_doorsmash_cortel_door_01";

	level._scr_animtree[ "vehicle_osprey_door_intro" ] = #animtree;
	level._scr_anim[ "vehicle_osprey_door_intro" ][ "Osprey_Intro" ] = %nx_vh_hithard_intro_osprey_door;
	level._scr_model[ "vehicle_osprey_door_intro" ] = "vehicle_osprey_door_intro";

	level._scr_animtree[ "osprey_damaged" ] = #animtree;
	level._scr_anim[ "osprey_damaged" ][ "Osprey_Intro" ] = %nx_vh_hithard_Intro_Osprey01_Damaged;
	level._scr_model[ "osprey_damaged" ] = "nx_vehicle_osprey_interiordamage";
	addNotetrack_customFunction( "osprey_damaged", "osprey_damaged_unhide", maps\nx_hithard_parachute::osprey_damaged_unhide );
    addNotetrack_customFunction( "osprey_damaged", "fx_flackhit_osp01_d_nt", maps\nx_hithard_fx::fx_ospreyintro_osp01_flackhit );
    addNotetrack_customFunction( "osprey_damaged", "fx_chutin_osp01_d_nt", maps\nx_hithard_fx::fx_ospreyintro_osp01_particle_cleanup );
    //addNotetrack_customFunction( "osprey_damaged", "fx_last_osp01_d_nt", maps\nx_hithard_fx::fx_ospreyintro_osp01_d_end );

	level._scr_animtree[ "model0" ] = #animtree;
	level._scr_anim[ "model0" ][ "nx_vh_hithard_ugv_reveal" ] = %nx_vh_hithard_ec_ugv_pullup_ec_ugv;
	level._scr_model[ "model0" ] = "nx_vehicle_chinese_ugv";

	level._scr_animtree[ "model1" ] = #animtree;
	level._scr_anim[ "model1" ][ "nx_vh_hithard_ugv_reveal" ] = %nx_vh_hithard_ec_ugv_pullup_ec_ugv_turret;
	level._scr_model[ "model1" ] = "nx_vehicle_chinese_ugv_main_turret";

	level._scr_animtree[ "model5" ] = #animtree;
	level._scr_anim[ "model5" ][ "nx_vh_hithard_ugv_reveal" ] = %nx_vh_hithard_ec_ugv_pullup_SUV;
	level._scr_model[ "model5" ] = "nx_vehicle_civilian_suv";

	level._scr_animtree[ "rope" ] = #animtree;
	level._scr_model[ "rope" ] = "viewmodel_hook_and_harness";
	level._scr_anim[ "rope" ][ "rappel_hookup" ] = %nx_fp_hithard_rappel_hook_and_harness; 
}

dialog()
{
	// Dialogue
	level._scr_radio[ "hithard_bak_amb_01" ] = "hithard_bak_amb_01";
	level._scr_radio[ "hithard_bak_amb_02" ] = "hithard_bak_amb_02";
	level._scr_radio[ "hithard_bak_amb_03" ] = "hithard_bak_amb_03";
	level._scr_radio[ "hithard_bak_amb_04" ] = "hithard_bak_amb_04";
	level._scr_radio[ "hithard_bak_amb_05" ] = "hithard_bak_amb_05";
	level._scr_radio[ "hithard_bak_amb_06" ] = "hithard_bak_amb_06";
	level._scr_radio[ "hithard_bak_amb_07" ] = "hithard_bak_amb_07";
	level._scr_radio[ "hithard_bak_amb_08" ] = "hithard_bak_amb_08";
	level._scr_radio[ "hithard_bak_amb_09" ] = "hithard_bak_amb_09";
	level._scr_radio[ "hithard_bak_amb_10" ] = "hithard_bak_amb_10";
	level._scr_radio[ "hithard_bak_amb_11" ] = "hithard_bak_amb_11";
	level._scr_radio[ "hithard_bak_amb_12" ] = "hithard_bak_amb_12";
	level._scr_radio[ "hithard_bak_amb_13" ] = "hithard_bak_amb_13";
	level._scr_radio[ "hithard_bak_amb_14" ] = "hithard_bak_amb_14";
	level._scr_radio[ "hithard_bak_amb_15" ] = "hithard_bak_amb_15";
	level._scr_radio[ "hithard_bak_amb_16" ] = "hithard_bak_amb_16";
	level._scr_radio[ "hithard_bak_amb_17" ] = "hithard_bak_amb_17";
	level._scr_radio[ "hithard_bak_amb_18" ] = "hithard_bak_amb_18";
	level._scr_radio[ "hithard_bak_amb_19" ] = "hithard_bak_amb_19";
	level._scr_radio[ "hithard_bak_amb_20" ] = "hithard_bak_amb_20";
	level._scr_radio[ "hithard_bak_amb_21" ] = "hithard_bak_amb_21";
	level._scr_radio[ "hithard_bak_amb_22" ] = "hithard_bak_amb_22";
	level._scr_radio[ "hithard_bak_amb_23" ] = "hithard_bak_amb_23";
	level._scr_radio[ "hithard_bak_amb_24" ] = "hithard_bak_amb_24";
	level._scr_radio[ "hithard_bak_amb_25" ] = "hithard_bak_amb_25";
	level._scr_radio[ "hithard_bak_amb_26" ] = "hithard_bak_amb_26";
	level._scr_radio[ "hithard_bak_amb_27" ] = "hithard_bak_amb_27";
	level._scr_radio[ "hithard_bak_amb_28" ] = "hithard_bak_amb_28";
	level._scr_radio[ "hithard_bak_amb_29" ] = "hithard_bak_amb_29";
	level._scr_radio[ "hithard_bak_amb_30" ] = "hithard_bak_amb_30";
	level._scr_radio[ "hithard_bak_amb_31" ] = "hithard_bak_amb_31";
	level._scr_radio[ "hithard_bak_amb_32" ] = "hithard_bak_amb_32";
	level._scr_radio[ "hithard_bak_amb_33" ] = "hithard_bak_amb_33";
	level._scr_radio[ "hithard_bak_amb_34" ] = "hithard_bak_amb_34";
	level._scr_radio[ "hithard_bak_amb_35" ] = "hithard_bak_amb_35";
	level._scr_radio[ "hithard_bak_amb_36" ] = "hithard_bak_amb_36";
	level._scr_radio[ "hithard_bak_amb_37" ] = "hithard_bak_amb_37";
	level._scr_radio[ "hithard_bak_amb_38" ] = "hithard_bak_amb_38";
	level._scr_radio[ "hithard_bak_amb_39" ] = "hithard_bak_amb_39";
	level._scr_radio[ "hithard_bak_amb_40" ] = "hithard_bak_amb_40";
	level._scr_radio[ "hithard_bak_amb_41" ] = "hithard_bak_amb_41";
	level._scr_radio[ "hithard_bak_amb_42" ] = "hithard_bak_amb_42";
	level._scr_radio[ "hithard_bak_amb_43" ] = "hithard_bak_amb_43";
	level._scr_radio[ "hithard_bak_amb_45" ] = "hithard_bak_amb_45";
	level._scr_radio[ "hithard_bak_amb_46" ] = "hithard_bak_amb_46";
	level._scr_radio[ "hithard_bak_amb_47" ] = "hithard_bak_amb_47";
	level._scr_radio[ "hithard_bak_bravo_01" ] = "hithard_bak_bravo_01";
	level._scr_radio[ "hithard_bak_bravo_02" ] = "hithard_bak_bravo_02";
	level._scr_radio[ "hithard_bak_bravo_03" ] = "hithard_bak_bravo_03";
	level._scr_radio[ "hithard_bak_bravo_04" ] = "hithard_bak_bravo_04";
	level._scr_radio[ "hithard_bak_bravo_05" ] = "hithard_bak_bravo_05";
	level._scr_radio[ "hithard_bak_highway_01" ] = "hithard_bak_highway_01";
	level._scr_radio[ "hithard_bak_highway_02" ] = "hithard_bak_highway_02";
	level._scr_radio[ "hithard_bak_highway_03" ] = "hithard_bak_highway_03";
	level._scr_radio[ "hithard_bak_highway_04" ] = "hithard_bak_highway_04";
	level._scr_radio[ "hithard_bak_highway_05" ] = "hithard_bak_highway_05";
	level._scr_radio[ "hithard_bak_highway_06" ] = "hithard_bak_highway_06";
	level._scr_radio[ "hithard_bak_highway_07" ] = "hithard_bak_highway_07";
	level._scr_radio[ "hithard_bak_highway_08" ] = "hithard_bak_highway_08";
	level._scr_radio[ "hithard_bak_highway_09" ] = "hithard_bak_highway_09";
	level._scr_radio[ "hithard_bak_highway_10" ] = "hithard_bak_highway_10";
	level._scr_radio[ "hithard_bak_highway_11" ] = "hithard_bak_highway_11";
	level._scr_radio[ "hithard_bak_highway_12" ] = "hithard_bak_highway_12";
	level._scr_radio[ "hithard_bak_introm_01" ] = "hithard_bak_introm_01";
	level._scr_radio[ "hithard_bak_introm_02" ] = "hithard_bak_introm_02";
	level._scr_radio[ "hithard_bak_introm_03" ] = "hithard_bak_introm_03";
	level._scr_radio[ "hithard_bak_introm_04" ] = "hithard_bak_introm_04";
	level._scr_radio[ "hithard_bak_introm_05" ] = "hithard_bak_introm_05";
	level._scr_radio[ "hithard_bak_intro_01" ] = "hithard_bak_intro_01";
	level._scr_radio[ "hithard_bak_intro_02" ] = "hithard_bak_intro_02";
	level._scr_radio[ "hithard_bak_intro_03" ] = "hithard_bak_intro_03";
	level._scr_radio[ "hithard_bak_intro_04" ] = "hithard_bak_intro_04";
	level._scr_radio[ "hithard_bak_intro_05" ] = "hithard_bak_intro_05";
	level._scr_radio[ "hithard_bak_intro_06" ] = "hithard_bak_intro_06";
	level._scr_radio[ "hithard_bak_intro_07" ] = "hithard_bak_intro_07";
	level._scr_radio[ "hithard_bak_intro_08" ] = "hithard_bak_intro_08";
	level._scr_radio[ "hithard_bak_intro_09" ] = "hithard_bak_intro_09";
	level._scr_radio[ "hithard_bak_intro_11" ] = "hithard_bak_intro_11";
	level._scr_radio[ "hithard_bak_intro_12" ] = "hithard_bak_intro_12";
	level._scr_radio[ "hithard_bak_intro_13" ] = "hithard_bak_intro_13";
	level._scr_radio[ "hithard_bak_intro_14" ] = "hithard_bak_intro_14";
	level._scr_radio[ "hithard_bak_intro_15" ] = "hithard_bak_intro_15";
	level._scr_radio[ "hithard_bak_intro_16" ] = "hithard_bak_intro_16";
	level._scr_radio[ "hithard_bak_intro_17" ] = "hithard_bak_intro_17";
	level._scr_radio[ "hithard_bak_intro_18" ] = "hithard_bak_intro_18";
	level._scr_radio[ "hithard_bak_intro_19" ] = "hithard_bak_intro_19";
	level._scr_radio[ "hithard_bak_intro_20" ] = "hithard_bak_intro_20";
	level._scr_radio[ "hithard_bak_intro_21" ] = "hithard_bak_intro_21";
	level._scr_radio[ "hithard_bak_intro_22" ] = "hithard_bak_intro_22";
	level._scr_radio[ "hithard_bak_intro_23" ] = "hithard_bak_intro_23";
	level._scr_radio[ "hithard_bak_kill_low_01" ] = "hithard_bak_kill_low_01";
	level._scr_radio[ "hithard_bak_kill_low_02" ] = "hithard_bak_kill_low_02";
	level._scr_radio[ "hithard_bak_kill_low_03" ] = "hithard_bak_kill_low_03";
	level._scr_radio[ "hithard_bak_kill_low_04" ] = "hithard_bak_kill_low_04";
	level._scr_radio[ "hithard_bak_kill_low_05" ] = "hithard_bak_kill_low_05";
	level._scr_radio[ "hithard_bak_kill_low_06" ] = "hithard_bak_kill_low_06";
	level._scr_radio[ "hithard_bak_kill_yell_01" ] = "hithard_bak_kill_yell_01";
	level._scr_radio[ "hithard_bak_kill_yell_02" ] = "hithard_bak_kill_yell_02";
	level._scr_radio[ "hithard_bak_kill_yell_03" ] = "hithard_bak_kill_yell_03";
	level._scr_radio[ "hithard_bak_kill_yell_04" ] = "hithard_bak_kill_yell_04";
	level._scr_radio[ "hithard_bak_kill_yell_05" ] = "hithard_bak_kill_yell_05";
	level._scr_radio[ "hithard_bak_kill_yell_06" ] = "hithard_bak_kill_yell_06";
	level._scr_radio[ "hithard_bak_mall_01" ] = "hithard_bak_mall_01";
	level._scr_radio[ "hithard_bak_mall_02" ] = "hithard_bak_mall_02";
	level._scr_radio[ "hithard_bak_mall_03" ] = "hithard_bak_mall_03";
	level._scr_radio[ "hithard_bak_mall_04" ] = "hithard_bak_mall_04";
	level._scr_radio[ "hithard_bak_mall_05" ] = "hithard_bak_mall_05";
	level._scr_radio[ "hithard_bak_mall_06" ] = "hithard_bak_mall_06";
	level._scr_radio[ "hithard_bak_mall_07" ] = "hithard_bak_mall_07";
	level._scr_radio[ "hithard_bak_mall_08" ] = "hithard_bak_mall_08";
	level._scr_radio[ "hithard_bak_mall_09" ] = "hithard_bak_mall_09";
	level._scr_radio[ "hithard_bak_mall_10" ] = "hithard_bak_mall_10";
	level._scr_radio[ "hithard_bak_mall_11" ] = "hithard_bak_mall_11";
	level._scr_radio[ "hithard_bak_mono_01" ] = "hithard_bak_mono_01";
	level._scr_radio[ "hithard_bak_mono_02" ] = "hithard_bak_mono_02";
	level._scr_radio[ "hithard_bak_mono_03" ] = "hithard_bak_mono_03";
	level._scr_radio[ "hithard_bak_mono_04" ] = "hithard_bak_mono_04";
	level._scr_radio[ "hithard_bak_mono_05" ] = "hithard_bak_mono_05";
	level._scr_radio[ "hithard_bak_mono_06" ] = "hithard_bak_mono_06";
	level._scr_radio[ "hithard_bak_move_01" ] = "hithard_bak_move_01";
	level._scr_radio[ "hithard_bak_move_02" ] = "hithard_bak_move_02";
	level._scr_radio[ "hithard_bak_move_03" ] = "hithard_bak_move_03";
	level._scr_radio[ "hithard_bak_move_04" ] = "hithard_bak_move_04";
	level._scr_radio[ "hithard_bak_move_05" ] = "hithard_bak_move_05";
	level._scr_radio[ "hithard_bak_move_06" ] = "hithard_bak_move_06";
	level._scr_radio[ "hithard_bak_move_07" ] = "hithard_bak_move_07";
	level._scr_radio[ "hithard_bak_pain_01" ] = "hithard_bak_pain_01";
	level._scr_radio[ "hithard_bak_para_01" ] = "hithard_bak_para_01";
	level._scr_radio[ "hithard_bak_para_02" ] = "hithard_bak_para_02";
	level._scr_radio[ "hithard_bak_para_03" ] = "hithard_bak_para_03";
	level._scr_radio[ "hithard_bak_para_04" ] = "hithard_bak_para_04";
	level._scr_radio[ "hithard_bak_para_05" ] = "hithard_bak_para_05";
	level._scr_radio[ "hithard_bak_para_06" ] = "hithard_bak_para_06";
	level._scr_radio[ "hithard_bak_para_07" ] = "hithard_bak_para_07";
	level._scr_radio[ "hithard_bak_para_08" ] = "hithard_bak_para_08";
	level._scr_radio[ "hithard_bak_para_09" ] = "hithard_bak_para_09";
	level._scr_radio[ "hithard_bak_para_10" ] = "hithard_bak_para_10";
	level._scr_radio[ "hithard_bak_para_11" ] = "hithard_bak_para_11";
	level._scr_radio[ "hithard_bak_para_12" ] = "hithard_bak_para_12";
	level._scr_radio[ "hithard_bak_para_13" ] = "hithard_bak_para_13";
	level._scr_radio[ "hithard_bak_para_14" ] = "hithard_bak_para_14";
	level._scr_radio[ "hithard_bak_para_15" ] = "hithard_bak_para_15";
	level._scr_radio[ "hithard_bak_para_16" ] = "hithard_bak_para_16";
	level._scr_radio[ "hithard_bak_para_18" ] = "hithard_bak_para_18";
	level._scr_radio[ "hithard_bak_para_19" ] = "hithard_bak_para_19";
	level._scr_radio[ "hithard_bak_para_20" ] = "hithard_bak_para_20";
	level._scr_radio[ "hithard_bak_para_21" ] = "hithard_bak_para_21";
	level._scr_radio[ "hithard_bak_para_22" ] = "hithard_bak_para_22";
	level._scr_radio[ "hithard_bak_para_23" ] = "hithard_bak_para_23";
	level._scr_radio[ "hithard_bak_para_24" ] = "hithard_bak_para_24";
	level._scr_radio[ "hithard_bak_para_26" ] = "hithard_bak_para_26";
	level._scr_radio[ "hithard_bak_para_27" ] = "hithard_bak_para_27";
	level._scr_radio[ "hithard_bak_para_28" ] = "hithard_bak_para_28";
	level._scr_radio[ "hithard_bak_plaza2_01" ] = "hithard_bak_plaza2_01";
	level._scr_radio[ "hithard_bak_plaza2_02" ] = "hithard_bak_plaza2_02";
	level._scr_radio[ "hithard_bak_plaza2_03" ] = "hithard_bak_plaza2_03";
	level._scr_radio[ "hithard_bak_plaza2_04" ] = "hithard_bak_plaza2_04";
	level._scr_radio[ "hithard_bak_plaza2_05" ] = "hithard_bak_plaza2_05";
	level._scr_radio[ "hithard_bak_plaza2_06" ] = "hithard_bak_plaza2_06";
	level._scr_radio[ "hithard_bak_plaza2_07" ] = "hithard_bak_plaza2_07";
	level._scr_radio[ "hithard_bak_plaza2_08" ] = "hithard_bak_plaza2_08";
	level._scr_radio[ "hithard_bak_plaza_01" ] = "hithard_bak_plaza_01";
	level._scr_radio[ "hithard_bak_plaza_02" ] = "hithard_bak_plaza_02";
	level._scr_radio[ "hithard_bak_plaza_03" ] = "hithard_bak_plaza_03";
	level._scr_radio[ "hithard_bak_plaza_04" ] = "hithard_bak_plaza_04";
	level._scr_radio[ "hithard_bak_plaza_05" ] = "hithard_bak_plaza_05";
	level._scr_radio[ "hithard_bak_plaza_06" ] = "hithard_bak_plaza_06";
	level._scr_radio[ "hithard_bak_plaza_07" ] = "hithard_bak_plaza_07";
	level._scr_radio[ "hithard_bak_plaza_08" ] = "hithard_bak_plaza_08";
	level._scr_radio[ "hithard_bak_plaza_09" ] = "hithard_bak_plaza_09";
	level._scr_radio[ "hithard_bak_plaza_10" ] = "hithard_bak_plaza_10";
	level._scr_radio[ "hithard_bak_plaza_11" ] = "hithard_bak_plaza_11";
	level._scr_radio[ "hithard_bak_plaza_12" ] = "hithard_bak_plaza_12";
	level._scr_radio[ "hithard_bak_plaza_13" ] = "hithard_bak_plaza_13";
	level._scr_radio[ "hithard_bak_plaza_14" ] = "hithard_bak_plaza_14";
	level._scr_radio[ "hithard_bak_plaza_15" ] = "hithard_bak_plaza_15";
	level._scr_radio[ "hithard_bak_plaza_16" ] = "hithard_bak_plaza_16";
	level._scr_radio[ "hithard_bak_plaza_17" ] = "hithard_bak_plaza_17";
	level._scr_radio[ "hithard_bak_plaza2_01" ] = "hithard_bak_plaza2_01";
	level._scr_radio[ "hithard_bak_plaza2_02" ] = "hithard_bak_plaza2_02";
	level._scr_radio[ "hithard_bak_plaza2_03" ] = "hithard_bak_plaza2_03";
	level._scr_radio[ "hithard_bak_plaza2_04" ] = "hithard_bak_plaza2_04";
	level._scr_radio[ "hithard_bak_plaza2_05" ] = "hithard_bak_plaza2_05";
	level._scr_radio[ "hithard_bak_plaza2_06" ] = "hithard_bak_plaza2_06";
	level._scr_radio[ "hithard_bak_plaza2_08" ] = "hithard_bak_plaza2_08";
	level._scr_radio[ "hithard_bak_secure_01" ] = "hithard_bak_secure_01";
	level._scr_radio[ "hithard_bak_secure_02" ] = "hithard_bak_secure_02";
	level._scr_radio[ "hithard_bak_secure_03" ] = "hithard_bak_secure_03";
	level._scr_radio[ "hithard_bak_secure_04" ] = "hithard_bak_secure_04";
	level._scr_radio[ "hithard_bak_secure_05" ] = "hithard_bak_secure_05";
	level._scr_radio[ "hithard_bak_secure_06" ] = "hithard_bak_secure_06";
	level._scr_radio[ "hithard_bak_secure_07" ] = "hithard_bak_secure_07";
	level._scr_radio[ "hithard_bak_secure_08" ] = "hithard_bak_secure_08";
	level._scr_radio[ "hithard_bak_secure_09" ] = "hithard_bak_secure_09";
	level._scr_radio[ "hithard_bak_secure_10" ] = "hithard_bak_secure_10";
	level._scr_radio[ "hithard_bak_secure_11" ] = "hithard_bak_secure_11";
	level._scr_radio[ "hithard_bak_secure_12" ] = "hithard_bak_secure_12";
	level._scr_radio[ "hithard_bak_secure_13" ] = "hithard_bak_secure_13";
	level._scr_radio[ "hithard_bak_secure_14" ] = "hithard_bak_secure_14";
	level._scr_radio[ "hithard_bak_secure_15" ] = "hithard_bak_secure_15";
	level._scr_radio[ "hithard_bak_secure_16" ] = "hithard_bak_secure_16";
	level._scr_radio[ "hithard_bak_secure_17" ] = "hithard_bak_secure_17";
	level._scr_radio[ "hithard_bak_secure_18" ] = "hithard_bak_secure_18";
	level._scr_radio[ "hithard_bak_secure_19" ] = "hithard_bak_secure_19";
	level._scr_radio[ "hithard_bak_secure_20" ] = "hithard_bak_secure_20";
	level._scr_radio[ "hithard_bak_secure_21" ] = "hithard_bak_secure_21";
	level._scr_radio[ "hithard_bak_secure_22" ] = "hithard_bak_secure_22";
	level._scr_radio[ "hithard_bak_secure_23" ] = "hithard_bak_secure_23";
	level._scr_radio[ "hithard_bak_secure_24" ] = "hithard_bak_secure_24";
	level._scr_radio[ "hithard_bak_secure_25" ] = "hithard_bak_secure_25";
	level._scr_radio[ "hithard_bak_secure_26" ] = "hithard_bak_secure_26";
	level._scr_radio[ "hithard_bak_secure_27" ] = "hithard_bak_secure_27";
	level._scr_radio[ "hithard_bak_secure_28" ] = "hithard_bak_secure_28";
	level._scr_radio[ "hithard_bak_secure_29" ] = "hithard_bak_secure_29";
	level._scr_radio[ "hithard_bak_secure_30" ] = "hithard_bak_secure_30";
	level._scr_radio[ "hithard_bak_secure_31" ] = "hithard_bak_secure_31";
	level._scr_radio[ "hithard_bak_secure_32" ] = "hithard_bak_secure_32";
	level._scr_radio[ "hithard_bak_secure_33" ] = "hithard_bak_secure_33";
	level._scr_radio[ "hithard_bak_secure_34" ] = "hithard_bak_secure_34";
	level._scr_radio[ "hithard_bak_secure_35" ] = "hithard_bak_secure_35";
	level._scr_radio[ "hithard_bak_secure_36" ] = "hithard_bak_secure_36";
	level._scr_radio[ "hithard_bak_secure_37" ] = "hithard_bak_secure_37";
	level._scr_radio[ "hithard_bak_secure_38" ] = "hithard_bak_secure_38";
	level._scr_radio[ "hithard_bak_secure_39" ] = "hithard_bak_secure_39";
	level._scr_radio[ "hithard_bak_secure_40" ] = "hithard_bak_secure_40";
	level._scr_radio[ "hithard_bak_secure_41" ] = "hithard_bak_secure_41";
	level._scr_radio[ "hithard_bak_secure_42" ] = "hithard_bak_secure_42";
	level._scr_radio[ "hithard_bak_secure_43" ] = "hithard_bak_secure_43";
	level._scr_radio[ "hithard_bak_secure_44" ] = "hithard_bak_secure_44";
	level._scr_radio[ "hithard_bak_secure_45" ] = "hithard_bak_secure_45";
	level._scr_radio[ "hithard_bak_secure_46" ] = "hithard_bak_secure_46";
	level._scr_radio[ "hithard_bak_secure_47" ] = "hithard_bak_secure_47";
	level._scr_radio[ "hithard_bak_secure_48" ] = "hithard_bak_secure_48";
	level._scr_radio[ "hithard_bak_secure_49" ] = "hithard_bak_secure_49";
	level._scr_radio[ "hithard_bak_secure_50" ] = "hithard_bak_secure_50";
	level._scr_radio[ "hithard_bak_secure_51" ] = "hithard_bak_secure_51";
	level._scr_radio[ "hithard_bak_secure_52" ] = "hithard_bak_secure_52";
	level._scr_radio[ "hithard_bak_secure_53" ] = "hithard_bak_secure_53";
	level._scr_radio[ "hithard_bak_secure_54" ] = "hithard_bak_secure_54";
	level._scr_radio[ "hithard_bak_secure_55" ] = "hithard_bak_secure_55";
	level._scr_radio[ "hithard_bak_secure_56" ] = "hithard_bak_secure_56";
	level._scr_radio[ "hithard_bak_secure_57" ] = "hithard_bak_secure_57";
	level._scr_radio[ "hithard_bak_secure_58" ] = "hithard_bak_secure_58";
	level._scr_radio[ "hithard_bak_secure_59" ] = "hithard_bak_secure_59";
	level._scr_radio[ "hithard_bak_secure_60" ] = "hithard_bak_secure_60";
	level._scr_radio[ "hithard_bak_secure_61" ] = "hithard_bak_secure_61";
	level._scr_radio[ "hithard_bak_secure_62" ] = "hithard_bak_secure_62";
	level._scr_radio[ "hithard_bak_secure_63" ] = "hithard_bak_secure_63";
	level._scr_radio[ "hithard_bak_secure_64" ] = "hithard_bak_secure_64";
	level._scr_radio[ "hithard_bak_secure_65" ] = "hithard_bak_secure_65";
	level._scr_radio[ "hithard_bak_secure_66" ] = "hithard_bak_secure_66";
	level._scr_radio[ "hithard_bak_snipe_01" ] = "hithard_bak_snipe_01";
	level._scr_radio[ "hithard_bak_snipe_02" ] = "hithard_bak_snipe_02";
	level._scr_radio[ "hithard_bak_snipe_03" ] = "hithard_bak_snipe_03";
	level._scr_radio[ "hithard_bak_snipe_04" ] = "hithard_bak_snipe_04";
	level._scr_radio[ "hithard_bak_snipe_05" ] = "hithard_bak_snipe_05";
	level._scr_radio[ "hithard_bak_snipe_06" ] = "hithard_bak_snipe_06";
	level._scr_radio[ "hithard_bak_snipe_07" ] = "hithard_bak_snipe_07";
	level._scr_radio[ "hithard_bak_snipe_08" ] = "hithard_bak_snipe_08";
	level._scr_radio[ "hithard_bak_snipe_09" ] = "hithard_bak_snipe_09";
	level._scr_radio[ "hithard_bak_snipe_10" ] = "hithard_bak_snipe_10";
	level._scr_radio[ "hithard_bak_snipe_11" ] = "hithard_bak_snipe_11";
	level._scr_radio[ "hithard_bak_snipe_12" ] = "hithard_bak_snipe_12";
	level._scr_radio[ "hithard_bak_snipe_13" ] = "hithard_bak_snipe_13";
	level._scr_radio[ "hithard_bak_snipe_14" ] = "hithard_bak_snipe_14";
	level._scr_radio[ "hithard_bak_snipe_15" ] = "hithard_bak_snipe_15";
	level._scr_radio[ "hithard_bak_snipe_16" ] = "hithard_bak_snipe_16";
	level._scr_radio[ "hithard_bak_snipe_17" ] = "hithard_bak_snipe_17";
	level._scr_radio[ "hithard_bak_snipe_18" ] = "hithard_bak_snipe_18";
	level._scr_radio[ "hithard_bak_snipe_19" ] = "hithard_bak_snipe_19";
	level._scr_radio[ "hithard_bak_snipe_20" ] = "hithard_bak_snipe_20";
	level._scr_radio[ "hithard_bak_snipe_21" ] = "hithard_bak_snipe_21";
	level._scr_sound[ "baker"][ "hithard_bak_snipe_22" ] = "hithard_bak_snipe_22";
	level._scr_sound[ "baker"][ "hithard_bak_snipe_23" ] = "hithard_bak_snipe_23";
	level._scr_sound[ "baker"][ "hithard_bak_snipe_24" ] = "hithard_bak_snipe_24";
	level._scr_radio[ "hithard_bak_snipe_33" ] = "hithard_bak_snipe_33";
	level._scr_radio[ "hithard_bak_snipe_34" ] = "hithard_bak_snipe_34";
	level._scr_sound[ "baker"][ "hithard_bak_snipe_35" ] = "hithard_bak_snipe_35";
	level._scr_radio[ "hithard_bak_snipe_bluecar" ] = "hithard_bak_snipe_bluecar";
	level._scr_radio[ "hithard_bak_snipe_check" ] = "hithard_bak_snipe_check";
	level._scr_radio[ "hithard_bak_snipe_cortel" ] = "hithard_bak_snipe_cortel";
	level._scr_radio[ "hithard_bak_snipe_cover" ] = "hithard_bak_snipe_cover";
	level._scr_radio[ "hithard_bak_snipe_dropem" ] = "hithard_bak_snipe_dropem";
	level._scr_radio[ "hithard_bak_snipe_dropthat" ] = "hithard_bak_snipe_dropthat";
	level._scr_radio[ "hithard_bak_snipe_goodkill" ] = "hithard_bak_snipe_goodkill";
	level._scr_radio[ "hithard_bak_snipe_graycar" ] = "hithard_bak_snipe_graycar";
	level._scr_radio[ "hithard_bak_snipe_greencar" ] = "hithard_bak_snipe_greencar";
	level._scr_radio[ "hithard_bak_snipe_ground" ] = "hithard_bak_snipe_ground";
	level._scr_radio[ "hithard_bak_snipe_gunship" ] = "hithard_bak_snipe_gunship";
	level._scr_radio[ "hithard_bak_snipe_headshot" ] = "hithard_bak_snipe_headshot";
	level._scr_radio[ "hithard_bak_snipe_keepdrop" ] = "hithard_bak_snipe_keepdrop";
	level._scr_radio[ "hithard_bak_snipe_kill" ] = "hithard_bak_snipe_kill";
	level._scr_radio[ "hithard_bak_snipe_monorail" ] = "hithard_bak_snipe_monorail";
	level._scr_radio[ "hithard_bak_snipe_nearbus" ] = "hithard_bak_snipe_nearbus";
	level._scr_radio[ "hithard_bak_snipe_patriot" ] = "hithard_bak_snipe_patriot";
	level._scr_radio[ "hithard_bak_snipe_planter" ] = "hithard_bak_snipe_planter";
	level._scr_radio[ "hithard_bak_snipe_plaza" ] = "hithard_bak_snipe_plaza";
	level._scr_radio[ "hithard_bak_snipe_redcar" ] = "hithard_bak_snipe_redcar";
	level._scr_radio[ "hithard_bak_snipe_sculpture" ] = "hithard_bak_snipe_sculpture";
	level._scr_radio[ "hithard_bak_snipe_shot" ] = "hithard_bak_snipe_shot";
	level._scr_radio[ "hithard_bak_snipe_sidewalk" ] = "hithard_bak_snipe_sidewalk";
	level._scr_radio[ "hithard_bak_snipe_suv" ] = "hithard_bak_snipe_suv";
	level._scr_radio[ "hithard_bak_snipe_threats" ] = "hithard_bak_snipe_threats";
	level._scr_radio[ "hithard_bak_snipe_topbus" ] = "hithard_bak_snipe_topbus";
	level._scr_radio[ "hithard_bak_snipe_tree" ] = "hithard_bak_snipe_tree";
	level._scr_radio[ "hithard_bak_snipe_yellowcar" ] = "hithard_bak_snipe_yellowcar";
	level._scr_radio[ "hithard_bak_suv_01" ] = "hithard_bak_suv_01";
	level._scr_radio[ "hithard_bak_suv_02" ] = "hithard_bak_suv_02";
	level._scr_radio[ "hithard_bak_suv_03" ] = "hithard_bak_suv_03";
	level._scr_radio[ "hithard_bak_suv_04" ] = "hithard_bak_suv_04";
	level._scr_radio[ "hithard_bak_suv_05" ] = "hithard_bak_suv_05";
	level._scr_radio[ "hithard_bak_suv_06" ] = "hithard_bak_suv_06";
	level._scr_radio[ "hithard_bak_suv_07" ] = "hithard_bak_suv_07";
	level._scr_radio[ "hithard_bak_suv_08" ] = "hithard_bak_suv_08";
	level._scr_radio[ "hithard_bak_suv_09" ] = "hithard_bak_suv_09";
	level._scr_radio[ "hithard_bak_suv_10" ] = "hithard_bak_suv_10";
	level._scr_radio[ "hithard_bak_suv_11" ] = "hithard_bak_suv_11";
	level._scr_radio[ "hithard_bak_suv_12" ] = "hithard_bak_suv_12";
	level._scr_radio[ "hithard_bak_suv_13" ] = "hithard_bak_suv_13";
	level._scr_radio[ "hithard_bak_suv_14" ] = "hithard_bak_suv_14";
	level._scr_radio[ "hithard_bak_suv_15" ] = "hithard_bak_suv_15";
	level._scr_radio[ "hithard_bak_suv_16" ] = "hithard_bak_suv_16";
	level._scr_radio[ "hithard_bak_trans_01" ] = "hithard_bak_trans_01";
	level._scr_radio[ "hithard_bak_trans_01a" ] = "hithard_bak_trans_01a";
	level._scr_radio[ "hithard_bak_trans_02" ] = "hithard_bak_trans_02";
	level._scr_radio[ "hithard_bak_trans_03" ] = "hithard_bak_trans_03";
	level._scr_radio[ "hithard_bak_trans_04" ] = "hithard_bak_trans_04";
	level._scr_radio[ "hithard_bak_vp2_01" ] = "hithard_bak_vp2_01";
	level._scr_radio[ "hithard_bak_vp2_02" ] = "hithard_bak_vp2_02";
	level._scr_radio[ "hithard_bak_vp2_03" ] = "hithard_bak_vp2_03";
	level._scr_radio[ "hithard_bak_vp2_04" ] = "hithard_bak_vp2_04";
	level._scr_radio[ "hithard_bak_vp2_05" ] = "hithard_bak_vp2_05";
	level._scr_radio[ "hithard_bak_vp2_06" ] = "hithard_bak_vp2_06";
	level._scr_radio[ "hithard_bak_vp2_08" ] = "hithard_bak_vp2_08";
	level._scr_radio[ "hithard_bak_snipe_letsgo" ] = "hithard_bak_snipe_letsgo";
	level._scr_radio[ "hithard_bak_snipe_downthere" ] = "hithard_bak_snipe_downthere";
	level._scr_radio[ "hithard_bak_snipe_weremovin" ] = "hithard_bak_snipe_weremovin";
	level._scr_radio[ "hithard_bak_vphit_01" ] = "hithard_bak_vphit_01";
	level._scr_radio[ "hithard_bak_vphit_02" ] = "hithard_bak_vphit_02";
	level._scr_radio[ "hithard_bak_vphit_03" ] = "hithard_bak_vphit_03";
	level._scr_radio[ "hithard_bak_vphit_04" ] = "hithard_bak_vphit_04";
	level._scr_radio[ "hithard_bak_vphit_05" ] = "hithard_bak_vphit_05";
	level._scr_radio[ "hithard_bak_vphit_06" ] = "hithard_bak_vphit_06";
	level._scr_radio[ "hithard_bak_vphit_07" ] = "hithard_bak_vphit_07";
	level._scr_radio[ "hithard_bak_vphit_08" ] = "hithard_bak_vphit_08";
	level._scr_radio[ "hithard_bak_vphit_09" ] = "hithard_bak_vphit_09";
	level._scr_radio[ "hithard_bak_vphit_10" ] = "hithard_bak_vphit_10";
	level._scr_radio[ "hithard_bak_vphit_11" ] = "hithard_bak_vphit_11";
	level._scr_radio[ "hithard_bak_vphit_12" ] = "hithard_bak_vphit_12";
	level._scr_radio[ "hithard_bak_vphit_13" ] = "hithard_bak_vphit_13";
	level._scr_radio[ "hithard_bak_vphit_14" ] = "hithard_bak_vphit_14";
	level._scr_radio[ "hithard_bak_vphit_15" ] = "hithard_bak_vphit_15";
	level._scr_radio[ "hithard_bak_vphit_16" ] = "hithard_bak_vphit_16";
	level._scr_radio[ "hithard_bravoradioop_highway_01" ] = "hithard_bravoradioop_highway_01";
	level._scr_radio[ "hithard_btl_amb_01" ] = "hithard_btl_amb_01";
	level._scr_radio[ "hithard_btl_amb_02" ] = "hithard_btl_amb_02";
	level._scr_radio[ "hithard_btl_amb_03" ] = "hithard_btl_amb_03";
	level._scr_radio[ "hithard_btl_amb_04" ] = "hithard_btl_amb_04";
	level._scr_radio[ "hithard_btl_amb_05" ] = "hithard_btl_amb_05";
	level._scr_radio[ "hithard_btl_amb_06" ] = "hithard_btl_amb_06";
	level._scr_radio[ "hithard_btl_bravo_01" ] = "hithard_btl_bravo_01";
	level._scr_radio[ "hithard_btl_bravo_02" ] = "hithard_btl_bravo_02";
	level._scr_radio[ "hithard_btl_bravo_03" ] = "hithard_btl_bravo_03";
	level._scr_radio[ "hithard_btl_bravo_04" ] = "hithard_btl_bravo_04";
	level._scr_radio[ "hithard_btl_bravo_05" ] = "hithard_btl_bravo_05";
	level._scr_radio[ "hithard_btl_bravo_06" ] = "hithard_btl_bravo_06";
	level._scr_radio[ "hithard_btl_bravo_07" ] = "hithard_btl_bravo_07";
	level._scr_radio[ "hithard_btl_bravo_08" ] = "hithard_btl_bravo_08";
	level._scr_radio[ "hithard_btl_bravo_09" ] = "hithard_btl_bravo_09";
	level._scr_radio[ "hithard_btl_mono_01" ] = "hithard_btl_mono_01";
	level._scr_radio[ "hithard_btl_trans_01" ] = "hithard_btl_trans_01";
	level._scr_radio[ "hithard_civ1_mall_01" ] = "hithard_civ1_mall_01";
	level._scr_radio[ "hithard_civ1_mall_02" ] = "hithard_civ1_mall_02";
	level._scr_radio[ "hithard_civ1_mall_03" ] = "hithard_civ1_mall_03";
	level._scr_radio[ "hithard_civ1_mall_04" ] = "hithard_civ1_mall_04";
	level._scr_radio[ "hithard_civ2_mall_01" ] = "hithard_civ2_mall_01";
	level._scr_radio[ "hithard_civ2_mall_02" ] = "hithard_civ2_mall_02";
	level._scr_radio[ "hithard_copilot_pullingup" ] = "hithard_copilot_pullingup";
	level._scr_radio[ "hithard_ecso_mall_01" ] = "hithard_ecso_mall_01";
	level._scr_radio[ "hithard_ecso_mall_02" ] = "hithard_ecso_mall_02";
	level._scr_radio[ "hithard_ecso_mall_03" ] = "hithard_ecso_mall_03";
	level._scr_radio[ "hithard_ecso_mall_04" ] = "hithard_ecso_mall_04";
	level._scr_radio[ "hithard_ecso_mall_05" ] = "hithard_ecso_mall_05";
	level._scr_radio[ "hithard_ecso_mall_06" ] = "hithard_ecso_mall_06";
	level._scr_radio[ "hithard_gyp_amb_01" ] = "hithard_gyp_amb_01";
	level._scr_radio[ "hithard_gyp_amb_02" ] = "hithard_gyp_amb_02";
	level._scr_radio[ "hithard_gyp_amb_03" ] = "hithard_gyp_amb_03";
	level._scr_radio[ "hithard_gyp_amb_04" ] = "hithard_gyp_amb_04";
	level._scr_radio[ "hithard_gyp_amb_05" ] = "hithard_gyp_amb_05";
	level._scr_radio[ "hithard_gyp_amb_06" ] = "hithard_gyp_amb_06";
	level._scr_radio[ "hithard_gyp_amb_07" ] = "hithard_gyp_amb_07";
	level._scr_radio[ "hithard_gyp_amb_08" ] = "hithard_gyp_amb_08";
	level._scr_radio[ "hithard_gyp_amb_09" ] = "hithard_gyp_amb_09";
	level._scr_radio[ "hithard_gyp_amb_10" ] = "hithard_gyp_amb_10";
	level._scr_radio[ "hithard_gyp_bravo_01" ] = "hithard_gyp_bravo_01";
	level._scr_radio[ "hithard_gyp_highway_01" ] = "hithard_gyp_highway_01";
	level._scr_radio[ "hithard_gyp_highway_02" ] = "hithard_gyp_highway_02";
	level._scr_radio[ "hithard_gyp_highway_03" ] = "hithard_gyp_highway_03";
	level._scr_radio[ "hithard_gyp_intro_01" ] = "hithard_gyp_intro_01";
	level._scr_radio[ "hithard_gyp_kill_low_01" ] = "hithard_gyp_kill_low_01";
	level._scr_radio[ "hithard_gyp_kill_low_02" ] = "hithard_gyp_kill_low_02";
	level._scr_radio[ "hithard_gyp_kill_low_03" ] = "hithard_gyp_kill_low_03";
	level._scr_radio[ "hithard_gyp_kill_low_04" ] = "hithard_gyp_kill_low_04";
	level._scr_radio[ "hithard_gyp_kill_low_05" ] = "hithard_gyp_kill_low_05";
	level._scr_radio[ "hithard_gyp_kill_low_06" ] = "hithard_gyp_kill_low_06";
	level._scr_radio[ "hithard_gyp_kill_yell_01" ] = "hithard_gyp_kill_yell_01";
	level._scr_radio[ "hithard_gyp_kill_yell_02" ] = "hithard_gyp_kill_yell_02";
	level._scr_radio[ "hithard_gyp_kill_yell_03" ] = "hithard_gyp_kill_yell_03";
	level._scr_radio[ "hithard_gyp_kill_yell_04" ] = "hithard_gyp_kill_yell_04";
	level._scr_radio[ "hithard_gyp_kill_yell_05" ] = "hithard_gyp_kill_yell_05";
	level._scr_radio[ "hithard_gyp_kill_yell_06" ] = "hithard_gyp_kill_yell_06";
	level._scr_radio[ "hithard_gyp_mall_01" ] = "hithard_gyp_mall_01";
	level._scr_radio[ "hithard_gyp_mall_02" ] = "hithard_gyp_mall_02";
	level._scr_radio[ "hithard_gyp_mall_03" ] = "hithard_gyp_mall_03";
	level._scr_radio[ "hithard_gyp_mall_04" ] = "hithard_gyp_mall_04";
	level._scr_radio[ "hithard_gyp_mall_05" ] = "hithard_gyp_mall_05";
	level._scr_radio[ "hithard_gyp_mall_06" ] = "hithard_gyp_mall_06";
	level._scr_radio[ "hithard_gyp_mall_07" ] = "hithard_gyp_mall_07";
	level._scr_radio[ "hithard_gyp_meet_01" ] = "hithard_gyp_meet_01";
	level._scr_radio[ "hithard_gyp_monorail_01" ] = "hithard_gyp_monorail_01";
	level._scr_radio[ "hithard_gyp_mono_02" ] = "hithard_gyp_mono_02";
	level._scr_radio[ "hithard_gyp_monorail_01" ] = "hithard_gyp_monorail_01";
	level._scr_radio[ "hithard_gyp_move_01" ] = "hithard_gyp_move_01";
	level._scr_radio[ "hithard_gyp_move_02" ] = "hithard_gyp_move_02";
	level._scr_radio[ "hithard_gyp_move_03" ] = "hithard_gyp_move_03";
	level._scr_radio[ "hithard_gyp_move_04" ] = "hithard_gyp_move_04";
	level._scr_radio[ "hithard_gyp_move_05" ] = "hithard_gyp_move_05";
	level._scr_radio[ "hithard_gyp_move_06" ] = "hithard_gyp_move_06";
	level._scr_radio[ "hithard_gyp_move_07" ] = "hithard_gyp_move_07";
	level._scr_radio[ "hithard_gyp_pain_01" ] = "hithard_gyp_pain_01";
	level._scr_radio[ "hithard_gyp_para_01" ] = "hithard_gyp_para_01";
	level._scr_radio[ "hithard_gyp_para_02" ] = "hithard_gyp_para_02";
	level._scr_radio[ "hithard_gyp_para_03" ] = "hithard_gyp_para_03";
	level._scr_radio[ "hithard_gyp_plaza_01" ] = "hithard_gyp_plaza_01";
	level._scr_radio[ "hithard_gyp_plaza2_01" ] = "hithard_gyp_plaza2_01";
	level._scr_radio[ "hithard_gyp_plaza2_02" ] = "hithard_gyp_plaza2_02";
	level._scr_radio[ "hithard_gyp_plaza2_03" ] = "hithard_gyp_plaza2_03";
	level._scr_radio[ "hithard_gyp_plaza2_04" ] = "hithard_gyp_plaza2_04";
	level._scr_radio[ "hithard_gyp_plaza_01" ] = "hithard_gyp_plaza_01";
	level._scr_radio[ "hithard_gyp_secure_01" ] = "hithard_gyp_secure_01";
	level._scr_radio[ "hithard_gyp_secure_02" ] = "hithard_gyp_secure_02";
	level._scr_sound[ "duke" ][ "hithard_gyp_secure_03" ] = "hithard_gyp_secure_03";
	level._scr_sound[ "duke" ][ "hithard_gyp_snipe_01" ] = "hithard_gyp_snipe_01";
	//level._scr_radio[ "hithard_gyp_snipe_comms" ] = "hithard_gyp_snipe_comms";
	level._scr_sound[ "duke" ][ "hithard_gyp_snipe_tin" ] = "hithard_gyp_snipe_tin";
	level._scr_radio[ "hithard_gyp_suv_01" ] = "hithard_gyp_suv_01";
	level._scr_radio[ "hithard_gyp_suv_02" ] = "hithard_gyp_suv_02";
	level._scr_radio[ "hithard_gyp_trans_01" ] = "hithard_gyp_trans_01";
	level._scr_radio[ "hithard_gyp_vp2_01" ] = "hithard_gyp_vp2_01";
	level._scr_radio[ "hithard_gyp_vp2_02" ] = "hithard_gyp_vp2_02";
	level._scr_radio[ "hithard_gyp_vpmeet2_01" ] = "hithard_gyp_vpmeet2_01";
	level._scr_radio[ "hithard_gyp_vpmeet2_02" ] = "hithard_gyp_vpmeet2_02";
	level._scr_radio[ "hithard_gyp_vpmeet_01" ] = "hithard_gyp_vpmeet_01";
	level._scr_radio[ "hithard_gyp_vpmeet_02" ] = "hithard_gyp_vpmeet_02";
	level._scr_radio[ "hithard_gyp_vpmeet2_01" ] = "hithard_gyp_vpmeet2_01";
	level._scr_radio[ "hithard_gyp_vpmeet2_02" ] = "hithard_gyp_vpmeet2_02";
	level._scr_radio[ "hithard_ovl_amb_01" ] = "hithard_ovl_amb_01";
	level._scr_radio[ "hithard_ovl_introm_01" ] = "hithard_ovl_introm_01";
	level._scr_radio[ "hithard_ovl_introm_02" ] = "hithard_ovl_introm_02";
	level._scr_radio[ "hithard_ovl_introm_03" ] = "hithard_ovl_introm_03";
	level._scr_radio[ "hithard_ovl_intro_01" ] = "hithard_ovl_intro_01";
	level._scr_radio[ "hithard_ovl_intro_02" ] = "hithard_ovl_intro_02";
	level._scr_radio[ "hithard_ovl_intro_03" ] = "hithard_ovl_intro_03";
	level._scr_radio[ "hithard_ovl_intro_04" ] = "hithard_ovl_intro_04";
	level._scr_radio[ "hithard_ovl_intro_05" ] = "hithard_ovl_intro_05";
	level._scr_radio[ "hithard_ovl_intro_06" ] = "hithard_ovl_intro_06";
	level._scr_radio[ "hithard_ovl_intro_07" ] = "hithard_ovl_intro_07";
	level._scr_radio[ "hithard_ovl_intro_08" ] = "hithard_ovl_intro_08";
	level._scr_radio[ "hithard_ovl_intro_09" ] = "hithard_ovl_intro_09";
	level._scr_radio[ "hithard_ovl_intro_10" ] = "hithard_ovl_intro_10";
	level._scr_radio[ "hithard_ovl_secure_01" ] = "hithard_ovl_secure_01";
	level._scr_radio[ "hithard_ovl_secure_02" ] = "hithard_ovl_secure_02";
	level._scr_radio[ "hithard_ovl_secure_03" ] = "hithard_ovl_secure_03";
	level._scr_radio[ "hithard_ovl_secure_04" ] = "hithard_ovl_secure_04";
	level._scr_radio[ "hithard_ovl_secure_05" ] = "hithard_ovl_secure_05";
	level._scr_radio[ "hithard_ovl_trans_01" ] = "hithard_ovl_trans_01";
	level._scr_radio[ "hithard_ovl_trans_01a" ] = "hithard_ovl_trans_01a";
	level._scr_radio[ "hithard_ovl_trans_02" ] = "hithard_ovl_trans_02";
	level._scr_radio[ "hithard_pilot_death_01" ] = "hithard_pilot_death_01";
	level._scr_radio[ "hithard_pilot_introm_01" ] = "hithard_pilot_introm_01";
	level._scr_radio[ "hithard_pilot_introm_02" ] = "hithard_pilot_introm_02";
	level._scr_radio[ "hithard_pilot_introm_03" ] = "hithard_pilot_introm_03";
	level._scr_radio[ "hithard_pilot_introm_04" ] = "hithard_pilot_introm_04";
	level._scr_radio[ "hithard_rad_intro_01" ] = "hithard_rad_intro_01";
	level._scr_radio[ "hithard_rad_intro_02" ] = "hithard_rad_intro_02";
	level._scr_radio[ "hithard_rad_snipe_01" ] = "hithard_rad_snipe_01";
	level._scr_radio[ "hithard_rad_vp2_01" ] = "hithard_rad_vp2_01";
	level._scr_radio[ "hithard_redshirt_introm_03" ] = "hithard_redshirt_introm_03";
	level._scr_radio[ "hithard_redshirt_intromed_01" ] = "hithard_redshirt_intromed_01";
	level._scr_radio[ "hithard_redshirt_intromed_02" ] = "hithard_redshirt_intromed_02";
	level._scr_radio[ "hithard_redshirt_intromed_03" ] = "hithard_redshirt_intromed_03";
	level._scr_radio[ "hithard_redshirt_introm_03" ] = "hithard_redshirt_introm_03";
	level._scr_radio[ "hithard_rev_intro_01" ] = "hithard_rev_intro_01";
	level._scr_radio[ "hithard_rev_intro_02" ] = "hithard_rev_intro_02";
	level._scr_radio[ "hithard_rev_intro_03" ] = "hithard_rev_intro_03";
	level._scr_radio[ "hithard_sis_amb_01" ] = "hithard_sis_amb_01";
	level._scr_radio[ "hithard_sis_amb_02" ] = "hithard_sis_amb_02";
	level._scr_radio[ "hithard_sis_amb_03" ] = "hithard_sis_amb_03";
	level._scr_radio[ "hithard_sis_amb_04" ] = "hithard_sis_amb_04";
	level._scr_radio[ "hithard_sis_amb_05" ] = "hithard_sis_amb_05";
	level._scr_radio[ "hithard_sis_bravoco_01" ] = "hithard_sis_bravoco_01";
	level._scr_radio[ "hithard_sis_bravoco_02" ] = "hithard_sis_bravoco_02";
	level._scr_radio[ "hithard_sslead_highway_01" ] = "hithard_sslead_highway_01";
	level._scr_radio[ "hithard_sslead_highway_03" ] = "hithard_sslead_highway_03";
	level._scr_radio[ "hithard_sslead_mall_01" ] = "hithard_sslead_mall_01";
	level._scr_radio[ "hithard_sslead_mall_02" ] = "hithard_sslead_mall_02";
	level._scr_radio[ "hithard_sslead_monorail_01" ] = "hithard_sslead_monorail_01";
	level._scr_radio[ "hithard_sslead_plaza2_01" ] = "hithard_sslead_plaza2_01";
	level._scr_radio[ "hithard_sslead_plaza_01" ] = "hithard_sslead_plaza_01";
	level._scr_radio[ "hithard_sslead_plaza_02" ] = "hithard_sslead_plaza_02";
	level._scr_radio[ "hithard_sslead_plaza2_01" ] = "hithard_sslead_plaza2_01";
	level._scr_radio[ "hithard_sslead_snipe_01" ] = "hithard_sslead_snipe_01";
	level._scr_radio[ "hithard_sslead_snipe_02" ] = "hithard_sslead_snipe_02";
	level._scr_radio[ "hithard_sslead_snipe_03" ] = "hithard_sslead_snipe_03";
	level._scr_radio[ "hithard_sslead_snipe_04" ] = "hithard_sslead_snipe_04";
	level._scr_radio[ "hithard_sslead_snipe_05" ] = "hithard_sslead_snipe_05";
	level._scr_radio[ "hithard_sslead_snipe_06" ] = "hithard_sslead_snipe_06";
	level._scr_radio[ "hithard_sslead_snipe_07" ] = "hithard_sslead_snipe_07";
	level._scr_radio[ "hithard_sslead_snipe_08" ] = "hithard_sslead_snipe_08";
	level._scr_radio[ "hithard_sslead_snipe_overrun" ] = "hithard_sslead_snipe_overrun";
	level._scr_radio[ "hithard_sslead_snipe_support" ] = "hithard_sslead_snipe_support";
	level._scr_radio[ "hithard_sslead_vp2_01" ] = "hithard_sslead_vp2_01";
	level._scr_radio[ "hithard_sslead_vphit_death" ] = "hithard_sslead_vphit_death";
	level._scr_radio[ "hithard_ssred_highway_01" ] = "hithard_ssred_highway_01";
	level._scr_radio[ "hithard_ssred_snipe_01" ] = "hithard_ssred_snipe_01";
	level._scr_radio[ "hithard_ssred_snipe_02" ] = "hithard_ssred_snipe_02";
	level._scr_radio[ "hithard_ss_amb_01" ] = "hithard_ss_amb_01";
	level._scr_radio[ "hithard_ss_secure_01" ] = "hithard_ss_secure_01";
	level._scr_radio[ "hithard_ss_secure_02" ] = "hithard_ss_secure_02";
	level._scr_radio[ "hithard_ss_secure_03" ] = "hithard_ss_secure_03";
	level._scr_radio[ "hithard_ss_secure_04" ] = "hithard_ss_secure_04";
	level._scr_radio[ "hithard_ss_suv_01" ] = "hithard_ss_suv_01";
	level._scr_radio[ "hithard_ss_suv_02" ] = "hithard_ss_suv_02";
	level._scr_radio[ "hithard_swat_amb_01" ] = "hithard_swat_amb_01";
	level._scr_radio[ "hithard_swat_amb_02" ] = "hithard_swat_amb_02";
	level._scr_radio[ "hithard_swat_amb_03" ] = "hithard_swat_amb_03";
	level._scr_radio[ "hithard_swat_amb_04" ] = "hithard_swat_amb_04";
	level._scr_radio[ "hithard_swat_amb_05" ] = "hithard_swat_amb_05";
	level._scr_radio[ "hithard_swat_amb_06" ] = "hithard_swat_amb_06";
	level._scr_radio[ "hithard_tfp_intro_01" ] = "hithard_tfp_intro_01";
	level._scr_radio[ "hithard_tfp_intro_02" ] = "hithard_tfp_intro_02";
	level._scr_radio[ "hithard_tfp_intro_03" ] = "hithard_tfp_intro_03";
	level._scr_radio[ "hithard_tfp_intro_04" ] = "hithard_tfp_intro_04";
	level._scr_radio[ "hithard_tfp_intro_05" ] = "hithard_tfp_intro_05";
	level._scr_radio[ "hithard_tfp_intro_06" ] = "hithard_tfp_intro_06";
	level._scr_radio[ "hithard_tfp_intro_08" ] = "hithard_tfp_intro_08";
	level._scr_radio[ "hithard_tfp_intro_09" ] = "hithard_tfp_intro_09";
	level._scr_radio[ "hithard_tfp_intro_10" ] = "hithard_tfp_intro_10";
	level._scr_radio[ "hithard_tfp_intro_11" ] = "hithard_tfp_intro_11";
	level._scr_radio[ "hithard_tfp_intro_12" ] = "hithard_tfp_intro_12";
	level._scr_radio[ "hithard_tfp_intro_13" ] = "hithard_tfp_intro_13";
	level._scr_radio[ "hithard_tfp_intro_14" ] = "hithard_tfp_intro_14";
	level._scr_radio[ "hithard_tfp_intro_15" ] = "hithard_tfp_intro_15";
	level._scr_radio[ "hithard_tfp_intro_16" ] = "hithard_tfp_intro_16";
	level._scr_radio[ "hithard_vp_amb_01" ] = "hithard_vp_amb_01";
	level._scr_radio[ "hithard_vp_amb_02" ] = "hithard_vp_amb_02";
	level._scr_radio[ "hithard_vp_amb_03" ] = "hithard_vp_amb_03";
	level._scr_radio[ "hithard_vp_amb_04" ] = "hithard_vp_amb_04";
	level._scr_radio[ "hithard_vp_amb_05" ] = "hithard_vp_amb_05";
	level._scr_radio[ "hithard_vp_amb_06" ] = "hithard_vp_amb_06";
	level._scr_radio[ "hithard_vp_mall_01" ] = "hithard_vp_mall_01";
	level._scr_radio[ "hithard_vp_plaza2_01" ] = "hithard_vp_plaza2_01";
	level._scr_radio[ "hithard_vp_secure_01" ] = "hithard_vp_secure_01";
	level._scr_radio[ "hithard_vp_secure_02" ] = "hithard_vp_secure_02";
	level._scr_radio[ "hithard_vp_secure_03" ] = "hithard_vp_secure_03";
	level._scr_radio[ "hithard_vp_suv_01" ] = "hithard_vp_suv_01";
	level._scr_radio[ "hithard_vp_transition_01" ] = "hithard_vp_transition_01";
	level._scr_radio[ "hithard_vp_trans_01" ] = "hithard_vp_trans_01";
	level._scr_radio[ "hithard_vp_vpmeet2_01" ] = "hithard_vp_vpmeet2_01";
	level._scr_radio[ "hithard_vp_vpmeet2_01a" ] = "hithard_vp_vpmeet2_01a";
	level._scr_radio[ "hithard_vp_vpmeet2_01b" ] = "hithard_vp_vpmeet2_01b";
	level._scr_radio[ "hithard_vp_vpt2_01" ] = "hithard_vp_vpt2_01";
	level._scr_radio[ "hithard_bak_roof_rogerthat" ] = "hithard_bak_roof_rogerthat";
	level._scr_radio[ "hithard_bak_roof_whatstatus" ] = "hithard_bak_roof_whatstatus";
	level._scr_radio[ "hithard_sslead_roof_ambushed" ] = "hithard_sslead_roof_ambushed";
	level._scr_radio[ "hithard_pilot_intro_clearjump" ] = "hithard_pilot_intro_clearjump";
	level._scr_radio[ "hithard_pilot_jumpnow" ] = "hithard_pilot_jumpnow";
	level._scr_radio[ "hithard_redshirt_intro_getthehell01" ] = "hithard_redshirt_intro_getthehell01";
	level._scr_radio[ "hithard_redshirt_intro_getthehell02" ] = "hithard_redshirt_intro_getthehell02";
	level._scr_radio[ "hithard_sslead_snipe_behindbus" ] = "hithard_sslead_snipe_behindbus";
	level._scr_radio[ "hithard_sslead_snipe_getdown" ] = "hithard_sslead_snipe_getdown";
	level._scr_radio[ "hithard_sslead_snipe_gonnablow" ] = "hithard_sslead_snipe_gonnablow";
	level._scr_radio[ "hithard_sslead_snipe_goright" ] = "hithard_sslead_snipe_goright";
	level._scr_radio[ "hithard_sslead_snipe_gunship" ] = "hithard_sslead_snipe_gunship";
	level._scr_radio[ "hithard_sslead_snipe_shitcar" ] = "hithard_sslead_snipe_shitcar";
	level._scr_radio[ "hithard_sslead_snipe_shitescort" ] = "hithard_sslead_snipe_shitescort";
	level._scr_radio[ "hithard_sslead_snipe_totheright" ] = "hithard_sslead_snipe_totheright";



}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
#using_animtree("script_model");
building_script_models()
{
//Building 2

	//level._scr_animtree[ "model0" ] = #animtree;
	//level._scr_anim[ "model0" ][ "Building_02" ] = %nx_pr_hithard_building02_0_anim;

	//level._scr_animtree[ "model1" ] = #animtree;
	//level._scr_anim[ "model1" ][ "Building_02" ] = %nx_pr_hithard_building02_1_anim;

// Building 4

	level._scr_animtree[ "nx_pr_hithard_building_04r" ]	 = #animtree;
	level._scr_anim[ "nx_pr_hithard_building_04r" ][ "nx_pr_hithard_build_4" ] = %nx_pr_hithard_building_04r_anim;

	//level._scr_animtree[ "nx_pr_hithard_building_04cd" ]	 = #animtree;
	//level._scr_anim[ "nx_pr_hithard_building_04cd" ][ "nx_pr_hithard_build_4" ] = %nx_pr_hithard_building_04cd_anim;

	// addNotetrack_customFunction( "animation", "notetrack id", ::function_to_call );
	//addNotetrack_customFunction( "nx_pr_hithard_building_04r", "dust_ledge", ::fx_building_4_ledge );
	//addNotetrack_customFunction( "nx_pr_hithard_building_04r", "dust_ledge2", ::fx_building_4_ledge2 );
	//addNotetrack_customFunction( "nx_pr_hithard_building_04r", "dust_ground", ::fx_building_4_ground );

}
//*******************************************************************
//					                                              	*
//*******************************************************************
//old
building_bomb_01()
{
/*
	//Building 01 Crowd:
	crowd = maps\nx_crowd_controller::new_crowd( "building_01_civilians_roof", 
	12, 																		// Number of actors to spawn in this crowd
	GetEntArray( "buidling_01_civilian_spawner", "script_noteworthy" ), 		// Spawners to use for this crowd
	GetEntArray( "building_01_civilian_spawnpoint", "script_noteworthy"),		// Spawn points for this crowd
	GetEntArray( "building_01_civilian_path", "script_noteworthy") );			// Paths this crowd can use	
	*/

	// Spawn the crowd
	//maps\nx_crowd_controller::spawn_crowd( "building_01_civilians_roof" );
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

parachute_missilehits_periph()
{
	level._player waittill( "intro_aa_start" );
	//iPrintLnBold("--- missiles periph ---");
	wait 5;
	exploder("parachute_missilehits_periph");
}
 

building01_missile_exp_fx() 
{
	//exploder("parachute_amb_fx_1");
	thread first_missile_strikes_sfx();
	exploder("building01_tracermissile");
	wait 1.8;
	set_vision_set( "nx_hithard_parachuting_explosion_bloom", 0.4 );
	exploder("building01_switch");

	quakeobj = spawn( "script_origin", level._player.origin );
	quakeobj PlayRumbleOnEntity( "artillery_rumble" );

	wait 0.2;

	quakeobj PlayRumbleOnEntity( "artillery_rumble" );
	Earthquake( .5, 2.0, level._player.origin, 5000 );
	wait 0.4;
	// ramp back to the normal parachuting bloom levels.
	set_vision_set( "nx_hithard_parachuting", 0.5 );
} 
 
first_missile_strikes_sfx()
{
        building1 = spawn( "sound_emitter", ( 20183, -15700, 2399 ) );
        wait 0.2;
	building1 PlaySound( "hithard_buildhit_01" );

        wait 1.5;
        building1 playloopsound( "hithard_buildhit_01_fire" );
} 

bomber_flyby_sfx()
{
        bomber = spawn( "sound_emitter", ( 15074, -14108, 4397 ) );
 	bomber PlaySound( "hithard_bomber_flyby" );
        bomber moveto( ( 23722, -24484, 4397 ), 3.0, 1.0, 1.0 );
} 


bomber_flyby_bldg2_sfx()
{
        wait 2.5;
        bomber = spawn( "sound_emitter", ( 12033, -13068, 3893 ) );
	bomber PlaySound( "hithard_bomber_bldg2_flyby" );
        bomber moveto( ( 11605, -26574, 3893 ), 1.5, 0.5, 0.5 );
} 


//*******************************************************************
//					                                              	*
//*******************************************************************
// Building Hit 2 Fall Sequence
// this is the building that falls and creates the dust in the scene.
building_2_fall()
{
	// spawn the models .. this needs to be there ahead of time

	//model0 = getent( "building2_0", "script_noteworthy" );
	//model0.animname = "model0";
	//model0 assign_animtree("model0");

	//model1 = getent( "building2_1", "script_noteworthy" );
	//model1.animname = "model1";
	//model1 assign_animtree("model1");
	
	node_Building_02 = getstruct("node_building_02", "script_noteworthy");
	
	guys = [];
	//guys["model0"] = model0;
	//guys["model1"] = model1;
	
	// play the first frame of the animtion to set the building in the correct location.	
	node_Building_02 anim_first_frame(guys, "Building_02");

	// Wait for the trigger plane to start the animation
	level._player waittill( "notify_player_jump_anim_complete" );
	flag_clear("flag_building_fall_2");	// This is here because the current osprey path passes through the trigger plane
	flag_wait ("flag_building_fall_2");
        thread bomber_flyby_bldg2_sfx();
	thread fx_bldg_2_rubble();

	foreach(guy in guys)
	{
		guy Show();
	}
	
	node_Building_02 anim_single(guys, "Building_02");

	// Deletes the skinned models after the animation completes
	foreach(guy in guys)
	{
		guy delete();
	}
}


//*******************************************************************
//					                                              	*
//*******************************************************************

fx_bldg_2_rubble()
{
	exploder( "parachute_amb_exp_01" );
	wait 4.0;
	exploder( "parachute_amb_exp_03" );
	wait 1.0;
	exploder( "fx_bldg_2_rubble" );
	//exploder( "building02_sparks" );
	wait 1;
        thread bldg_2_collapse_sfx();
	Earthquake( .1, 2.0, level._player.origin, 5000 );
	wait 2;
	Earthquake( .3, 2.0, level._player.origin, 5000 );
	wait 2;
	Earthquake( .2, 5.0, level._player.origin, 5000 );
}

//*******************************************************************
//					                                              	*
//*******************************************************************
// Building 3 Explosion Sequence

building03_explosion_right( ) 
{
	flag_wait ("flag_parachute_building3_explosion_right_fx1");
	//iPrintLnBold("--- got building3 exp right ---");
	exploder("flag_parachute_building3_explosion_right_fx1");
        level._player playsound("hithard_buildhit_03_5");
	stop_exploder("building03_amb_fx");
} 

building03_explosion_left( ) 
{
	flag_wait ("flag_parachute_building3_explosion_left_fx1");
	//iPrintLnBold("--- got building3 exp left ---");
	exploder("flag_parachute_building3_explosion_left_fx1");
        level._player playsound("hithard_buildhit_03_5");
	stop_exploder("building03_amb_fx");
} 

building03_pre_fx() 
{
	flag_wait ("flag_parachute_building3_pre_explosions");

	//iPrintLnBold("--- got building3 pre ---");
	Earthquake( .2, 1.0, level._player.origin, 5000 );
	exploder("building3_pre_explosions");

	//starting building04 smoke avalance here so it will be going in time
	exploder("building04_debri_smoke");

	wait 1.0;
	Earthquake( .4, 2.0, level._player.origin, 5000 );
}

parachute_amb_explosions() 
{
	level._player waittill("intro_aa_start");
	//iPrintLnBold("--- got intro_aa_start ---");
	exploder("parachute_amb_fx_1");
	exploder("smoke_walls");
	exploder("parachute_amb_explosions");
}
 
//*******************************************************************
//					                                              	*
//*******************************************************************
// Misc FX Cleanup
trigger_building03_04_fx_cleanup_building01( ) 
{
	flag_wait ("parachute_trigger_building03_04_fx_cleanup_building01");
	exploder("building03_amb_fx");
	exploder("building03_amb_fx_left");
	exploder("building03_amb_fx_right");
	exploder("parachute_amb_fx_2");
	wait 4;
	exploder("parachute_amb_exp_intersection");
} 

misc_parachute_fx_cleanup( ) 
{
	flag_wait( "parachute_trigger_building02_amb_fx" );
	//iPrintLnBold("--- got trigger for build02 ---");
	wait 3;
	exploder("building02_amb_fx");
	wait 2;
	fx_delete_createFXEnt_by_fxID( "nx_smoke_plume_huge", true, true );
	flag_wait ("parachute_trigger_building03_04_fx_cleanup_building01");
	//iPrintLnBold("--- got build34 cleanup ---");
	//array_thread( getFXArrayByID( "nx_smoke_plume_huge" ), ::pauseEffect );
	//exploder("smoke_walls_2");
	fx_delete_createFXEnt_by_vol( "parachute_fxvolume_building02_amb_fx", true, true );
	stop_exploder_nx( "building01_switch", 1 );
	stop_exploder_nx( "building01_tracermissile", 1 );
	stop_exploder_nx( "parachute_amb_exp_01", 1 );
	stop_exploder_nx("parachute_amb_fx_1", 1 );
	//stop_exploder("building02_amb_fx");

	flag_wait ("flag_parachute_building3_pre_explosions");
	//iPrintLnBold("--- got building3 for 02 ---");
	//array_thread( getFXArrayByID( "nx_smoke_wall_long" ), ::pauseEffect );
	exploder("building04_amb_fx");
	exploder("rooftop_amb_fx");
	exploder("rooftop_amb_fx_noint");
	//fx_delete_createFXEnt_by_fxID( "nx_smoke_wall_long", true, true );
	stop_exploder_nx("smoke_walls", 1 );
	//stop_exploder( "building02_sparks" );

	flag_wait ("flag_parasecure_parachute_landed_player");
	//iPrintLnBold("--- got player landed ---");
	fx_delete_createFXEnt_by_vol( "parachute_fxvolume_1", true, true );

	//stop_exploder("building03_amb_fx_left");
	//stop_exploder("building03_amb_fx_right");
	//stop_exploder("parachute_amb_fx_2");
	
} 

//*******************************************************************
//					                                              	*
//*******************************************************************
// Building 4 Fall Sequence
building_4_fall()
{
	nx_pr_hithard_building_04r = getent( "building_4r", "script_noteworthy" );
	nx_pr_hithard_building_04r.animname = "nx_pr_hithard_building_04r";
	nx_pr_hithard_building_04r assign_animtree("nx_pr_hithard_building_04r");
	
	//nx_pr_hithard_building_04cd = getent( "building_4cd", "script_noteworthy" );
	//nx_pr_hithard_building_04cd.animname = "nx_pr_hithard_building_04cd";
	//nx_pr_hithard_building_04cd assign_animtree("nx_pr_hithard_building_04cd");

	wait 2.0; // getStruct() fails unless there's a delay here - not entirely sure why

	node_nx_pr_hithard_build_4 = getstruct("node_play_building4", "script_noteworthy");

	guys = [];
	guys["nx_pr_hithard_building_04r"] = nx_pr_hithard_building_04r;
	//guys["nx_pr_hithard_building_04cd"] = nx_pr_hithard_building_04cd;

	node_nx_pr_hithard_build_4 anim_first_frame(guys, "nx_pr_hithard_build_4");

	nx_pr_hithard_building_04r Hide();
	//nx_pr_hithard_building_04cd Hide();

	//This is used if the osprey flys through the trigger plane during the intro
	//flag_wait ("flag_building_fall_4");
	//wait 2;	 
	//level._player waittill( "notify_player_jump_anim_complete" );
	flag_wait ("flag_building_fall_4");


	nx_pr_hithard_building_04r Show();
	//nx_pr_hithard_building_04cd Show();

	wait 0.2;

	node_nx_pr_hithard_build_4 thread anim_single(guys, "nx_pr_hithard_build_4");

	thread fx_building_4( nx_pr_hithard_building_04r );

        thread bldg_4_collapse_sfx();
	// Deletes the skinned models after the animation completes
/*
	foreach(guy in guys)
	{
		guy delete();
	}
*/
}

fx_building_4( nx_pr_hithard_building_04r )
{
	Earthquake( .3, 4.0, level._player.origin, 5000 );
}

bldg_2_collapse_sfx()
{
    building2 = spawn( "sound_emitter", ( 9915, -22518, 2111 ) );
    wait 0.1;
	building2 PlaySound( "hithard_buildhit_02" );

    flag_wait ("flag_parasecure_parachute_landed_player");
    building2 delete();
}

bldg_4_collapse_sfx()
{
        
    building4alarm = spawn( "sound_emitter", ( 12720, -11926, 954 ) );
    building4 = spawn( "sound_emitter", ( 12365, -8107, 617 ) );
	nx_pr_hithard_building_04r = getent( "building_4r", "script_noteworthy" );
    wait 0.1;
	building4 PlaySound( "hithard_buildhit_04" );
	nx_pr_hithard_building_04r playloopsound( "hithard_buildhit_04_fire" );
	building4alarm playloopsound( "hithard_buildhit_04_alarm" );
    nx_pr_hithard_building_04r thread maps\_utility::play_sound_on_tag( "hithard_buildhit_04_whoosh", "j_nx_pr_hithard_building_04r_73" );

    flag_wait ("flag_parasecure_parachute_landed_player");
    nx_pr_hithard_building_04r StopLoopSound( "hithard_buildhit_04_fire" );
    building4alarm StopLoopSound( "hithard_buildhit_04_alarm" );
    building4alarm delete();
    building4 delete();
}

bldg_5_collapse_sfx()
{

	nx_hhh_facade_collapse5 = getent( "nx_hhh_facade_collapse0", "script_noteworthy" );

	nx_hhh_facade_collapse5 PlaySound( "hithard_buildhit_05" );

} 

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Sniper perch climb up
nx_tp_hithard_sniper_climbing_a()
{
	self.animname = "baker";

	self enable_cqbwalk();

	node = getstruct( "nx_tp_hithard_sniper_climbing_a", "targetname");

	node anim_reach_solo( self, "nx_tp_hithard_sniper_climbing_a" );
	node thread anim_single_solo( self, "nx_tp_hithard_sniper_climbing_a" );

}

// Sniper perch climb up
nx_tp_hithard_sniper_climbing_b()
{
	self.animname = "gypsy";

	// Second guy cant go untill 1st guy is rdy
	level waittill("climb_start");

	self enable_cqbwalk();

	node = getstruct( "nx_tp_hithard_sniper_climbing_b", "targetname");

	node anim_reach_solo( self, "nx_tp_hithard_sniper_climbing_b" );
	node thread anim_single_solo( self, "nx_tp_hithard_sniper_climbing_b" );

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vp_meet_and_greet_spawn()
{
	vp = vignette_actor_spawn("vp", "vp");
	secret_service1 = vignette_actor_spawn("secret_service1", "secret_service1");
	//secret_service2 = vignette_actor_spawn("secret_service2", "secret_service2");
	baker = vignette_actor_spawn("baker", "baker");
	gypsy = vignette_actor_spawn("gypsy", "gypsy");

	vp_meet_and_greet( vp, secret_service1, baker, gypsy  );

	vp vignette_actor_delete();
	secret_service1 vignette_actor_delete();
	//secret_service2 vignette_actor_delete();
	baker vignette_actor_delete();
	gypsy vignette_actor_delete();	
}

vp_meet_and_greet( vp, secret_service1, baker, gypsy )
{

	flag_set("flag_vp_meet_vignette_start");
	//node = getstruct("vignette_vp_meet_and_greet", "script_noteworthy");
	// changed to a node in the script_motorcade.map file
	node = getstruct("node_vp_ss_loop", "script_noteworthy");

	guys = [];
	guys2 = [];
	guys3 = [];
	guys["vp"] = vp;
	guys["secret_service1"] = secret_service1;
	guys3["vp"] = vp;
	guys3["secret_service1"] = secret_service1;
	//guys["secret_service2"] = secret_service2;
	guys["baker"] = baker;
	guys["gypsy"] = gypsy;
	guys2["baker"] = baker;
	//guys2["gypsy"] = gypsy;
	//guys["player_rig"] = player_rig;

	arc = 15;

	//node thread anim_first_frame(guys3, "vp_meet_and_greet");
	node anim_reach(guys2, "vp_meet_and_greet");
	flag_set ("flag_vp_meet_greet_anim_reached");
	secret_service1 anim_stopanimscripted();
	vp anim_stopanimscripted();
	node anim_single(guys, "vp_meet_and_greet");
	//wait 0.1;

	flag_set ( "flag_VP_Meet_Greet_Done" );

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//osprey vp pick up crash
nx_vh_ospreycrashvp_osprey_01_spawn()
{
	ospreycrashvp = vignette_vehicle_spawn("ospreycrashvp", "ospreycrashvp"); //"value" (kvp), "anim_name"

	nx_vh_ospreycrashvp_osprey_01(ospreycrashvp);

	ospreycrashvp vignette_vehicle_delete();
}

nx_vh_ospreycrashvp_osprey_01(ospreycrashvp)
{

	node = getstruct("vignette_node_play_ospreycrashvp_osprey_01", "script_noteworthy");

	guys = [];
	guys["ospreycrashvp"] = ospreycrashvp;

	thread scn_hithard_exfil_osprey_sfx();

	node anim_first_frame(guys, "nx_vh_ospreycrashvp_osprey_01");
	node anim_single(guys, "nx_vh_ospreycrashvp_osprey_01");

}

scn_hithard_exfil_osprey_sfx()
{
	org = Spawn( "sound_emitter", ( 6318, -2636, -84 ) );
	org playsound( "scn_hithard_exfil_osprey", "scn_hithard_exfil_osprey", true );
	wait 13.47;
	level.squad[1] playsound( "hithard_gyp_sonofabitch" );
	wait 1.5;
	level.vp_transition playsound( "hithard_vp_ohno" );
	org waittill( "scn_hithard_exfil_osprey" );
	org delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//chinese vtol ugv dropoff
nx_vh_chinese_vtol_ugv_drop_spawn()
{
	dropoff_suv_01 = vignette_vehicle_spawn("dropoff_suv_01", "dropoff_suv_01"); //"value" (kvp), "anim_name"
	dropoff_ugv_01 = vignette_vehicle_spawn("dropoff_ugv_01", "dropoff_ugv_01"); //"value" (kvp), "anim_name"
	dropoff_chinese_vtol_01 = vignette_vehicle_spawn("dropoff_chinese_vtol_01", "dropoff_chinese_vtol_01"); //"value" (kvp), "anim_name"

	nx_vh_chinese_vtol_ugv_drop(dropoff_suv_01, dropoff_ugv_01, dropoff_chinese_vtol_01);

	dropoff_suv_01 vignette_vehicle_delete();
	dropoff_ugv_01 vignette_vehicle_delete();
	dropoff_chinese_vtol_01 vignette_vehicle_delete();
}

nx_vh_chinese_vtol_ugv_drop(dropoff_suv_01, dropoff_ugv_01, dropoff_chinese_vtol_01)
{

	node = getstruct("vignette_node_play_chinese_vtol_ugv_dropoff", "script_noteworthy");

	//dropoff_suv_02 = spawn_anim_model("dropoff_suv_02");

	//dropoff_suv_02 Hide();

	level thread ent_earthquake( dropoff_chinese_vtol_01, 0.17, 14, 1000 );

	guys = [];
	//guys["dropoff_suv_02"] = dropoff_suv_02;
	guys["dropoff_suv_01"] = dropoff_suv_01;
	guys["dropoff_ugv_01"] = dropoff_ugv_01;
	guys["dropoff_chinese_vtol_01"] = dropoff_chinese_vtol_01;
	
	node anim_first_frame(guys, "nx_vh_chinese_vtol_ugv_drop");

	node anim_single(guys, "nx_vh_chinese_vtol_ugv_drop");

	node waittill("nx_vh_chinese_vtol_ugv_drop");
	flag_set("flag_vignette_vtol_ugv_drop_done");
}

ent_earthquake( ent, scale, duration, radius )
{
	ent endon( "delete" );
	ent endon( "death" );
	
	wait_time = 0;
	interval = 0.05;

	while( wait_time <= duration )
	{
		Earthquake( scale, duration, ent.origin, radius );
		wait_time += interval;
		wait interval;
	}
}

play_dropoff_suv_02_anim()
{
	node = getstruct("vignette_node_play_chinese_vtol_ugv_dropoff", "script_noteworthy");

	dropoff_suv_02 = spawn_anim_model("dropoff_suv_02");

	guys = [];
	guys["dropoff_suv_02"] = dropoff_suv_02;
	
	node anim_first_frame(guys, "nx_vh_chinese_vtol_ugv_drop");

	node anim_single(guys, "nx_vh_chinese_vtol_ugv_drop");	

}

chinese_vtol_ugv_dropoff_swap( dropoff_suv_01 ) 
{
	dropoff_suv_01 Hide();
	//dropoff_suv_02 Show();

	play_dropoff_suv_02_anim();
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//EC VTOL mimiuav deploy

nx_vh_hithard_vtol_uav_deploy_spawn()
{
	ec_vtol_miniuav_deploy_vtol = vignette_vehicle_spawn( "ec_vtol_miniuav_deploy_vtol","ec_vtol_miniuav_deploy_vtol" ); //"value" (kvp), "anim_name"
	ec_vtol_miniuav_deploy_vtol suspend_drive_anims_for_vignette();
	nx_vh_hithard_vtol_uav_deploy(ec_vtol_miniuav_deploy_vtol);

	ec_vtol_miniuav_deploy_vtol vignette_vehicle_delete();
}

nx_vh_hithard_vtol_uav_deploy(ec_vtol_miniuav_deploy_vtol)
{

	node = getstruct("vignette_ec_vtol_miniuav_deploy", "script_noteworthy");

	guys = [];
	guys["ec_vtol_miniuav_deploy_vtol"] = ec_vtol_miniuav_deploy_vtol;

	node anim_first_frame(guys, "nx_vh_hithard_vtol_uav_deploy");

	node anim_single(guys, "nx_vh_hithard_vtol_uav_deploy");

}


unloadvtolminiuavs( ec_vtol_miniuav_deploy_vtol )
{
	ec_vtol_miniuav_deploy_vtol vehicle_unload();
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//baker door smash in the cortel
nx_tp_hithard_doorsmash_ally_01_spawn()
{
	baker_doorsmash = vignette_actor_spawn("baker_doorsmash", "baker_doorsmash"); //"value" (kvp), "anim_name"

	nx_tp_hithard_doorsmash_ally_01(baker_doorsmash);

	baker_doorsmash vignette_actor_delete();
}

nx_tp_hithard_doorsmash_ally_01(baker_doorsmash)
{
	//node = getstruct("vignette_node_play_doorsmash_cortel_door", "script_noteworthy");
	// changed this to a node inside nx_hithard_script_motorcade.map for easier tweaking on the design side
	node = getstruct("node_vignette_doorsmash", "script_noteworthy");

	baker_doorsmash_door = spawn_anim_model("baker_doorsmash_door");

	guys = [];
	guys["baker_doorsmash"] = baker_doorsmash;
	// added to smooth out transition from AI to vignette
	node anim_reach(guys, "nx_tp_hithard_doorsmash_ally_01");
	flag_set("flag_doorsmash_anim_reached");

	guys["baker_doorsmash_door"] = baker_doorsmash_door;

	node anim_first_frame(guys, "nx_tp_hithard_doorsmash_ally_01");

	thread fx_nx_tp_hithard_doorsmash_ally_01();	// vfx
	node anim_single(guys, "nx_tp_hithard_doorsmash_ally_01");
}

fx_nx_tp_hithard_doorsmash_ally_01()
{
	// effects around the door for the breach effect
	wait 0.40;
	Exploder( "fx_cortel_breach_1" );
	wait 0.16;
	Exploder( "fx_cortel_breach_2" );
	wait 0.33;
	Exploder( "fx_cortel_breach_3" );
	wait 0.70;
	Exploder("fx_cortel_breach_door");
}

fx_nx_tp_hithard_doorsmash_door()
{
// notetrack = "smash_door"
// "nx_hhh_cortel_door_breach"
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_unlink( player_rig )
{
	player_rig unlink();
}

ally_parachute_spawn( player_rig )
{
	level._player notify( "ally_parachute_spawn" );
}

intro_aa_start( player_rig )
{
	level._player notify( "intro_aa_start" );
}

intro_osprey_swap( player_rig )
{
}

//*******************************************************************
//					                                              	*
//*******************************************************************

fx_bldg_5_start ( ent )
{
	exploder( "fx_bldg_5_falling_brick" );
}

fx_bldg_5_big_dust( ent )
{
	playfxontag( level._effect[ "nx_hhh_bldg_5_dust_main" ], ent, "tag_fx_big_dust");
	exploder( "fx_bldg_5_dust_linger_1" );
	wait 3.0;
	exploder( "fx_bldg_5_dust_linger_2" );
	wait 4.0;
	exploder( "fx_bldg_5_dust_side" );

	// Cleanup.
	wait 8.0;
	stop_exploder( "fx_bldg_5_dust_linger_1" );
	stop_exploder( "fx_bldg_5_dust_linger_2" );
}

//*******************************************************************
//					                                              	*
//*******************************************************************
// civilians hanging from building 2

/*
hanging()
{
	// Set up the actors.
	hanging_guys = [];
	foreach( actor in GetEntArray( "actor_hanging_vignette", "targetname" ) )
	{
		actor.animname = actor.script_noteworthy;
		hanging_guys[ actor.script_noteworthy ] = actor;
	}

	// Set up the nodes.
	hanging_nodes = [];	
	foreach( node in GetStructArray( "node_hanging_vignette", "targetname" ) )
	{
		hanging_nodes[ node.script_noteworthy ] = node;
		hanging_guy = hanging_guys[ node.script_noteworthy ];
//  	node anim_first_frame_solo( hanging_guy, "hanging" );
	}

	// Start the animation.
	flag_wait ("flag_building_fall_2");
	wait 1.0;
	foreach( node in hanging_nodes )
	{
		hanging_guy = hanging_guys[ node.script_noteworthy ];
		hanging_guy ForceTeleport( node.origin, node.angles );
//  	node thread anim_single_solo( hanging_guy, "hanging" );
		node thread anim_loop_solo( hanging_guy, "hanging" );
//  	node thread hanging_guy_on_anim_end( hanging_guy );
		wait 0.05;
//  	hanging_guy_anim = hanging_guy getanim( "hanging" );
		hanging_guy_anim = level._scr_anim[ hanging_guy.animname ][ "hanging" ][ 0 ];
		hanging_guy SetAnimTime( hanging_guy_anim, RandomFloatRange( 0, 0.5 ) );

		hanging_guy thread hanging_guy_drop( node );
		hanging_guy thread hanging_guy_delete();

	}
}

hanging_guy_drop( node )
{
	self endon( "death" );
	self endon( "delete" );
	
	chance_fall = 0.6; // 0 to 1, percent chance that guy will fall.
	fall_min_wait = 6.0;
	fall_max_wait = 10.0;

	fall = ( RandomFloatRange( 0, 1 ) > 1.0 - chance_fall );
	wait_time = RandomFloatRange( fall_min_wait, fall_max_wait );

	interval = 0.05;

	while( wait_time > 0 )
	{
		wait_time -= interval;

		if( wait_time <= 0)
		{
			if( fall )
			{
				self.animname = "hanging_civ";
				node anim_single_solo( self, "falling" );
			}
		}

		wait interval;
	}
}

hanging_guy_delete()
{
	self endon( "death" );
	flag_wait( "hanging_guys_delete" );
	self Delete();
}
*/

//*******************************************************************
//					                                              	*
//*******************************************************************
//vp meet and greet
vp_loop_spawn()
{
	secret_service1_loop = vignette_actor_spawn("secret_service1_loop", "secret_service1_loop"); //"value" (kvp), "anim_name"
	vp_loop = vignette_actor_spawn("vp_loop", "vp_loop"); //"value" (kvp), "anim_name"

	vp_loop(secret_service1_loop, vp_loop);

	secret_service1_loop vignette_actor_delete();
	vp_loop vignette_actor_delete();
}

vp_loop(secret_service1_loop, vp_loop)
{

	//node = getstruct("vignette_vp_meet_and_greet", "script_noteworthy");
	// changed to a node in the script_motorcade.map file
	node = getstruct("node_vp_ss_loop2", "script_noteworthy");


	guys = [];
	guys[0] = secret_service1_loop;
	guys[1] = vp_loop;

	//anim_reach( guys, "vp_loop" );

	node thread anim_loop(guys, "vp_loop");
	flag_wait("flag_vp_meet_greet_anim_reached");
	node notify( "stop_loop" );
}

//*******************************************************************
//					                                              	*
//*******************************************************************
// Civilian floating in pool
floatingbody_civ_01_spawn()
{
	floating_civ_01 = vignette_actor_spawn("floating_civ_01", "floating_civ_01"); //"value" (kvp), "anim_name"

	floatingbody_civ_01(floating_civ_01);

	//floating_civ_01 vignette_actor_delete();
}

floatingbody_civ_01(floating_civ_01)
{

	node = getstruct("vignette_play_floatingbody_civ", "script_noteworthy");


	guys = [];
	guys["floating_civ_01"] = floating_civ_01;

	node thread anim_loop(guys, "floatingbody_civ_01");

	flag_wait ("floatingbody_civ_01_delete");

	floating_civ_01 vignette_actor_delete();  


}

//*******************************************************************
//					                                              	*
//*******************************************************************
//ec ugv reveal and blows up cars
nx_vh_hithard_ugv_reveal_spawn()
{
	sedan_car1 = vignette_vehicle_spawn("sedan_car1", "sedan_car1"); //"value" (kvp), "anim_name"
	sedan_car2 = vignette_vehicle_spawn("sedan_car2", "sedan_car2"); //"value" (kvp), "anim_name
	
	// Commenting out for now
	//nx_vh_hithard_ugv_reveal(sedan_car1, sedan_car2);

	sedan_car1 vignette_vehicle_delete();
	sedan_car2 vignette_vehicle_delete();
}

nx_vh_hithard_ugv_reveal(sedan_car1, sedan_car2)
{

	node = getstruct("vignette_ugv_reveal", "script_noteworthy");

	model0 = spawn_anim_model("model0");

	model1 = spawn_anim_model("model1");

	model5 = spawn_anim_model("model5");


	guys = [];
	guys["model0"] = model0;
	guys["model1"] = model1;
	guys["sedan_car1"] = sedan_car1;
	guys["sedan_car2"] = sedan_car2;
	guys["model5"] = model5;
	
	//sedan_car1 suspend_drive_anims_for_vignette();
	//sedan_car2 suspend_drive_anims_for_vignette();
	
    node anim_first_frame(guys, "nx_vh_hithard_ugv_reveal");
	node anim_single(guys, "nx_vh_hithard_ugv_reveal");

}

rooftop_climb_up_notify( parm )
{
	level notify( "climb_start" );
}

//*******************************************************************
//					                                              	*
//*******************************************************************
// Called as spawn func on VP
#using_animtree( "generic_human" );
init_vp_anims()
{
	initAnimSet = [];
	initAnimSet[ "sprint" ] = %sprint_loop_distant;
	initAnimSet[ "sprint_short" ] = %sprint1_loop;
	initAnimSet[ "prone" ] = %prone_crawl;

	initAnimSet[ "straight" ] = %civilian_run_upright;
	
	initAnimSet[ "move_f" ] = %civilian_run_upright;
	initAnimSet[ "move_l" ] = %walk_left;
	initAnimSet[ "move_r" ] = %walk_right;
	initAnimSet[ "move_b" ] = %walk_backward;
	
	initAnimSet[ "crouch" ] = %crouch_fastwalk_F;
	initAnimSet[ "crouch_l" ] = %crouch_fastwalk_L;
	initAnimSet[ "crouch_r" ] = %crouch_fastwalk_R;
	initAnimSet[ "crouch_b" ] = %crouch_fastwalk_B;	
	
	initAnimSet[ "stairs_up" ] = %nx_tp_hithard_VP_stairs_up;
	initAnimSet[ "stairs_down" ] = %nx_tp_hithard_VP_stairs_down;

	self.customMoveAnimSet[ "walk" ] = initAnimSet;
	self.customMoveAnimSet[ "run" ] = initAnimSet;
	self.customMoveAnimSet[ "cqb" ] = initAnimSet;
}


//*******************************************************************
//					                                              	*
//*******************************************************************
// Called as spawn func on SS
#using_animtree( "generic_human" );
init_ss_anims()
{
	initAnimSet = [];
	initAnimSet[ "sprint" ] = %sprint_loop_distant;
	initAnimSet[ "sprint_short" ] = %sprint1_loop;
	initAnimSet[ "prone" ] = %prone_crawl;

	initAnimSet[ "straight" ] = %run_lowready_F;
	
	initAnimSet[ "move_f" ] = %walk_forward;
	initAnimSet[ "move_l" ] = %walk_left;
	initAnimSet[ "move_r" ] = %walk_right;
	initAnimSet[ "move_b" ] = %walk_backward;
	
	initAnimSet[ "crouch" ] = %crouch_fastwalk_F;
	initAnimSet[ "crouch_l" ] = %crouch_fastwalk_L;
	initAnimSet[ "crouch_r" ] = %crouch_fastwalk_R;
	initAnimSet[ "crouch_b" ] = %crouch_fastwalk_B;	
	
	initAnimSet[ "stairs_up" ] = %nx_tp_hithard_SS_stairs_up;
	initAnimSet[ "stairs_down" ] = %nx_tp_hithard_SS_stairs_down;

	self.customMoveAnimSet[ "run" ] = initAnimSet;
}
