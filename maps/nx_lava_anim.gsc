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
#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_nx_vignette_util;

main()
{
	generic_human();

	vehicles();

	player_anims();

	script_models();

	level thread vignettes();

        dialogue();
} 


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_flag_inits()
{
	flag_init( "vignette_bridge_to_train_done" );
	flag_init( "vignette_openingwalk" );
	flag_init( "vignette_roverarrive" );
	flag_init( "vignette_holdmotion" );
	flag_init( "vignette_ledgejump" ); 
	flag_init( "vignette_hillslide" );
	flag_init( "vignette_air_resupply_keene_collapse" );
	flag_init( "vignette_weldingarms" );
	flag_init( "vignette_rovermaintance" );
	flag_init( "vignette_underground_reveal" );
	flag_init( "vignette_scaffold_jump" );
	flag_init( "vignette_flankareajump" );
	flag_init( "vignette_crane2" );
	flag_init( "vignette_maproom_point" );
	flag_init( "vignette_camren_sacrifice" );
	flag_init( "vignette_camren_sacrifice_camrenidle" );
	flag_init( "vignette_button_push" );
	flag_init( "vignette_go_go_train" );
	flag_init( "vignette_data_retrieval" );
	flag_init( "vignette_train2_keene_reveal" );

	flag_init( "vignette_tillman_reveal" );
	flag_init( "vignette_trainboard_opfor2" );
	flag_init( "vignette_train_seperate" );
	flag_init( "vignette_trainseperate_fall" );
	flag_init( "vignette_ally_jump" );
	flag_init( "vignette_trainseperate_player_jump" );
	flag_init( "vignette_trainseperate_player_jump_done" );
	flag_init( "vignette_angelsquad_reveal" );

	flag_init( "vignette_keene_standoff_done" );
	
	flag_init( "train_interior_car_3_player_vignette_done" );
	flag_init( "train_seperate_fall_player_done" );
	flag_init( "vignette_trainseperate_player_jump" );

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignettes()
{

	// level thread vignette_register( ::opening_walk_spawn, "vignette_openingwalk" ); // Integrated - Brian McDonald

	//level thread vignette_register( ::rover_arrive_spawn, "vignette_roverarrive" );

	// level thread vignette_register( ::hold_motion_spawn, "vignette_holdmotion" ); // Integrated 9.14 - Brian McDonald

	// level thread vignette_register( ::hillslide_spawn, "vignette_hillslide" ); // Integrated 9.14 - Brian McDonald

	// level thread vignette_register( ::air_resupply_spawn, "vignette_air_resupply" ); // Integrated 9.14 - Brian McDonald

	// level thread vignette_register( ::ledgejump_spawn, "vignette_ledgejump" ); // Integrated 9.27 - Brian McDonald

	// level thread vignette_register( ::air_resupply_baker_faint_spawn, "vignette_air_resupply_baker_collapse" ); // Integrated 9.14 - Brian McDonald

	level thread vignette_register( ::weldingarms_skimmer1_spawn, "vignette_weldingarms" );

	// level thread vignette_register( ::rover_maintance_spawn, "vignette_rovermaintance" ); // Integrated 9.15 - Brian McDonald

	// level thread vignette_register( ::scaffold_jump_spawn, "vignette_scaffold_jump" ); // Integrated - Brian McDonald

	// level thread vignette_register( ::flank_area_jump_spawn, "vignette_flankareajump" ); // Integrated 10.11 - Brian McDonald

	// tagTC<note> - TEMP REMOVE, IT IS CRASHING
	//level thread vignette_register( ::crane_movement2_spawn, "vignette_crane2" );

	// level thread vignette_register( ::maproom_point_spawn, "vignette_maproom_point" ); // OLD - replaced by control_room_breach - BMcD

	// level thread vignette_register( ::data_retrieval_spawn, "vignette_data_retrieval" ); // OLD - replaced by control_room_breach - BMcD

	//level thread vignette_register( ::button_push_spawn, "vignette_button_push" );

	//level thread vignette_register( ::train1_section_8car_train_spawn, "vignette_go_go_train" );

	//level thread vignette_register( ::train1_section_4car_train_spawn, "vignette_go_go_train" );

	// level thread vignette_register( ::control_room_breach_spawn, "vignette_control_room_breach" ); // Integrated 9.21 - Brian McDonald

	// level thread vignette_register( ::camren_sacrifice_player_spawn, "vignette_camren_sacrifice" ); // Integrated 9.29 - Brian McDonald

	// level thread vignette_register( ::camren_sacrific_idle_spawn, "vignette_camren_sacrifice_camrenidle" ); // Integrated 9.29 - Brian McDonald

	//level thread vignette_register( ::keene_standoff_spawn, "vignette_keene_standoff" );

	// level thread vignette_register( ::underground_reveal_spawn, "vignette_underground_reveal" ); // Integrated 10.4 - Brian McD

	//level thread vignette_register( ::bridge_to_train_jump_spawn, "vignette_bridge_to_train_jump" );

	// level thread vignette_register( ::train2_keenereveal_spawn, "vignette_train2_keene_reveal" );

	level thread vignette_register( ::train2_tillmanreveal_spawn, "vignette_tillman_reveal" );

	//level thread vignette_register( ::train_board_spawn, "vignette_trainboard_opfor2" );

	// level thread vignette_register( ::train_seperate_spawn, "vignette_train_seperate" );

	//level thread vignette_register( ::train_seperate_fall_spawn, "vignette_trainseperate_fall" );

	//level thread vignette_register( ::train_seperate_player_jump_spawn, "vignette_trainseperate_player_jump" );

	//level thread vignette_register( ::turret_battle_tanker_explosion_spawn, "vignette_turret_battle_tanker_explosion" );

	//level thread vignette_register( ::turret_battle_tire_explosion_spawn, "vignette_turret_battle_tire_explosion" );

	//level thread vignette_register( ::turret_battle_tank_near_hit_spawn, "vignette_turret_battle_tank_near_hit" );

	//level thread vignette_register( ::turret_battle_train_derail_spawn, "vignette_turret_battle_train_derail" );

	//level thread vignette_register( ::turret_battle_train_derail_02_spawn, "trigger_flag_name" );

	// skimmer battle
	// tagTC<note> - temp remove of tower to make things a little less busy
	//level thread vignette_register( ::skimmer_crash_tower_spawn, "skimmer_crash_tower" );

	level thread vignette_register( ::skimmer_crash_rocks_spawn, "skimmer_crash_rocks" );
	//level thread vignette_register( ::skimmer_crash_rocks_fx, "skimmer_crash_rocks" );

	//level thread vignette_register( ::skimmer_crash_rocks_02_spawn, "skimmer_crash_rocks_02" );

	//level thread vignette_register( ::train_derailment_spawn, "vignette_train_derailment" );

	level thread vignette_register( ::angelsquad_reveal_spawn, "vignette_angelsquad_reveal" ); 
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree("generic_human");
generic_human() 
{
	// opening walk
	level._scr_anim[ "baker" ][ "opening_walk" ] = %nx_tp_lava_opening_walk_keen;
	level._scr_anim[ "franklin" ][ "opening_walk" ] = %nx_tp_lava_opening_walk_ally1;
	level._scr_anim[ "tillman" ][ "opening_walk" ] = %nx_tp_lava_opening_walk_ally2;
	level._scr_anim[ "player_legs" ][ "opening_walk" ] = %nx_fp_lava_opening_walk_player_legs;

	// rover arrive
	level._scr_anim[ "opfor3" ][ "rover_arrive" ] = %nx_tp_lava_roverarrive_opfor3;
	level._scr_anim[ "opfor2" ][ "rover_arrive" ] = %nx_tp_lava_roverarrive_opfor2;
	level._scr_anim[ "opfor1" ][ "rover_arrive" ] = %nx_tp_lava_roverarrive_opfor1;

	// hold motion
	level._scr_anim[ "baker" ][ "hold_motion" ] = %nx_tp_lava_hold_motion_keen;

	// hill slide
	level._scr_anim[ "baker" ][ "hillslide" ] = %nx_tp_lava_hold_hillslide_keene;
	level._scr_anim[ "tillman" ][ "hillslide" ] = %nx_tp_lava_hold_hillslide_tillman;
	level._scr_anim[ "franklin" ][ "hillslide" ] = %nx_tp_lava_hold_hillslide_franklin;

	// ledge_jump
	level._scr_anim[ "baker" ][ "ledgejump" ] = %nx_tp_lava_ledgejump_keene;
	level._scr_anim[ "franklin" ][ "ledgejump" ] = %nx_tp_lava_ledgejump_franklin;
	level._scr_anim[ "tillman" ][ "ledgejump" ] = %nx_tp_lava_ledgejump_tillman;

	// air resupply
	level._scr_anim[ "baker" ][ "air_resupply" ] = %nx_tp_lava_air_resupply_keane;
	level._scr_anim[ "tillman" ][ "air_resupply" ] = %nx_tp_lava_air_resupply_tilman;
	level._scr_anim[ "franklin" ][ "air_resupply" ] = %nx_tp_lava_air_resupply_franklin;

	// air resupply baker collapse
	level._scr_anim[ "baker" ][ "air_resupply_baker_faint" ] = %nx_tp_lava_refill_air_keene_collapse_keene;

	// rover maintance
	level._scr_anim[ "opfor1" ][ "rover_maintance" ] = %nx_tp_lava_rover_maintance1;
	level._scr_anim[ "opfor2" ][ "rover_maintance" ] = %nx_tp_lava_rover_maintance2;
	level._scr_anim[ "opfor3" ][ "rover_maintance" ] = %nx_tp_lava_rover_maintance3;

	// scaffold jump
	level._scr_anim[ "baker" ][ "scaffold_jump" ] = %nx_tp_lava_scaffold_jump_keene;
	level._scr_anim[ "tillman" ][ "scaffold_jump" ] = %nx_tp_lava_scaffold_jump_tillman;
	level._scr_anim[ "franklin" ][ "scaffold_jump" ] = %nx_tp_lava_scaffold_jump_franklin;

	// flank jump
	level._scr_anim[ "tillman" ][ "flank_area_jump" ] = %nx_tp_lava_flankareajump_ally1;

	// maproom point
	level._scr_anim[ "baker" ][ "maproom_point" ] = %nx_tp_lava_maproom_point_keene;

	// camren sacrifice
	level._scr_anim[ "baker" ][ "camren_sacrifice_player" ] = %nx_tp_lava_camrensacrifice_baker;

	level._scr_anim[ "tillman" ][ "camren_sacrific_idle" ] = %nx_tp_lava_camrensacrifice_camrenidle;

	// button push
	level._scr_anim[ "keene" ][ "button_push" ] = %nx_tp_lava_push_button;

	// keene standoff
	level._scr_anim[ "keene" ][ "keene_standoff" ] = %nx_tp_lava_control_breach_keene;
	level._scr_anim[ "baker" ][ "keene_standoff" ] = %nx_tp_lava_control_breach_tillman;
	level._scr_anim[ "redshirt" ][ "keene_standoff" ] = %nx_tp_lava_control_breach_red_shirt;

	// control room breach
	level._scr_anim[ "keene" ][ "control_room_breach" ] = %nx_tp_lava_control_breach_keene;
	level._scr_anim[ "franklin" ][ "control_room_breach" ] = %nx_tp_lava_control_breach_red_shirt;
	level._scr_anim[ "tillman" ][ "control_room_breach" ] = %nx_tp_lava_control_breach_tillman;
	level._scr_anim[ "opfor_01" ][ "control_room_breach" ] = %nx_tp_lava_control_breach_opfor_01;
	level._scr_anim[ "opfor_02" ][ "control_room_breach" ] = %nx_tp_lava_control_breach_opfor_02;

	// bridge to train
	level._scr_anim[ "keene" ][ "bridge_to_train_jump" ] = %nx_tp_lava_bridge_to_train_jump_keane;
	level._scr_anim[ "baker" ][ "bridge_to_train_jump" ] = %nx_tp_lava_bridge_to_train_jump_tilman;

	// train2 keene reveal
	level._scr_anim[ "keene" ][ "train2_keenereveal" ] = %nx_tp_lava_train2_keenereveal_keene;
	level._scr_anim[ "opfor" ][ "train2_keenereveal" ] = %nx_tp_lava_train2_keenereveal_opfor;

	// train2 tillman reveal
	level._scr_anim[ "tillman" ][ "train2_tillmanreveal" ] = %nx_tp_lava_train2_tillmanreveal_tillman;
	level._scr_anim[ "opfor" ][ "train2_tillmanreveal" ] = %nx_tp_lava_train2_tillmanreveal_opfor;

	// train board
	level._scr_anim[ "opfor1" ][ "train_board" ] = %nx_tp_lava_train2_tillmanreveal_opfor2;
	level._scr_anim[ "opfor2" ][ "train_board" ] = %nx_tp_lava_train2_tillmanreveal_opfor3;

	// angel squad reveal
	level._scr_anim[ "opfor1" ][ "angelsquad_reveal" ] = %nx_tp_lava_angelsquad_opfor1;
	level._scr_anim[ "opfor2" ][ "angelsquad_reveal" ] = %nx_tp_lava_angelsquad_opfor2;
	level._scr_anim[ "angelsquad1" ][ "angelsquad_reveal" ] = %nx_tp_lava_angelsquad_angelsquad1;
	level._scr_anim[ "angelsquad2" ][ "angelsquad_reveal" ] = %nx_tp_lava_angelsquad_angelsquad2;
	level._scr_anim[ "angelsquad3" ][ "angelsquad_reveal" ] = %nx_tp_lava_angelsquad_angelsquad3;
	level._scr_anim[ "deadguy" ][ "angelsquad_reveal" ] = %nx_tp_lava_angelsquad_deadguy;
	level._scr_anim[ "shotguy" ][ "angelsquad_reveal" ] = %nx_tp_lava_angelsquad_shotguy;

	// train seperate
	//level._scr_anim[ "keene" ][ "train_seperate" ] = %nx_tp_lava_trainseperate_keene;

	// train seperate fall
	level._scr_anim[ "baker" ][ "train_seperate_fall" ] = %nx_tp_lava_trainseperate_fall_keene;
	level._scr_anim[ "baker" ][ "train_seperate_fall_idle" ][0] = %nx_tp_lava_trainseperate_fall_keene_idle;

	// train seperate ally jump
	//level._scr_anim[ "keene" ][ "train_seperate_player_jump" ] = %nx_tp_lava_trainseperate_keene_jump;

	// train seperate player jump
	level._scr_anim[ "baker" ][ "train_seperate_player_jump" ] = %nx_tp_lava_trainseperate_player_jump_baker;

	// train derailment
	level._scr_anim[ "tillman" ][ "train_derailment" ] = %nx_tp_lava_train_derailment_tillman;
	level._scr_anim[ "player_legs" ][ "train_derailment" ] = %nx_fp_lava_train_derailment_player_legs;
	
	// Dead Crew Anims
	level._scr_anim[ "generic" ][ "dying_back_death_v2" ]				= %dying_back_death_v2;
	level._scr_anim[ "generic" ][ "civilian_leaning_death_shot" ]			= %civilian_leaning_death_shot;
	
	// Custom Death Anims
	level._scr_anim[ "generic" ][ "train_roof_death" ] = %tp_moon_lava_death_shotgun_traintop_f104;
	level._scr_anim[ "generic" ][ "train_car_2_death" ] = %tp_moon_lava_death_into_train_death_f24;
	level._scr_anim[ "generic" ][ "train_car_2_death_2" ] = %death_explosion_stand_B_v2;
	level._scr_anim[ "generic" ][ "train_3_explo_f_1" ] = %death_explosion_stand_F_v4;
	level._scr_anim[ "generic" ][ "train_3_explo_b_1" ] = %death_explosion_stand_B_v1;
	level._scr_anim[ "generic" ][ "train_3_explo_b_2" ] = %death_explosion_stand_B_v4;
	level._scr_anim[ "generic" ][ "train_3_explo_b_3" ] = %death_explosion_stand_B_v3;
	level._scr_anim[ "generic" ][ "train_3_explo_l_1" ] = %death_explosion_stand_L_v3;
	level._scr_anim[ "generic" ][ "train_3_explo_l_2" ] = %death_explosion_stand_L_v3;
	level._scr_anim[ "generic" ][ "train_3_death_rail_fall" ] = %tp_moon_lava_death_handrail_fallover;
	level._scr_anim[ "generic" ][ "train_3_death_rail_stay" ] = %tp_moon_lava_death_handrail_stay;
}

dialogue()
{
	level._scr_radio[ "lava_fra_surface_headtobase" ] = "lava_fra_surface_headtobase";
	level._scr_radio[ "lava_kee_surface_keepmoving" ] = "lava_kee_surface_keepmoving";
	level._scr_radio[ "lava_kee_surface_wontmatter" ] = "lava_kee_surface_wontmatter";
	level._scr_radio[ "lava_kee_surface_movereserves" ] = "lava_kee_surface_movereserves";
	level._scr_radio[ "lava_kee_surface_seeanything" ] = "lava_kee_surface_seeanything";
	level._scr_radio[ "lava_car_surface_nosirohshit" ] = "lava_car_surface_nosirohshit";
	level._scr_radio[ "lava_car_surface_upheresomething" ] = "lava_car_surface_upheresomething";
	level._scr_radio[ "lava_kee_surface_doubletime" ] = "lava_kee_surface_doubletime";
	level._scr_radio[ "lava_kee_surface_threetangos" ] = "lava_kee_surface_threetangos";
	level._scr_radio[ "lava_kee_surface_assigntargets" ] = "lava_kee_surface_assigntargets";
	level._scr_radio[ "lava_kee_surface_holdon321" ] = "lava_kee_surface_holdon321";
	level._scr_radio[ "lava_kee_surface_stackup" ] = "lava_kee_surface_stackup";
	level._scr_radio[ "lava_kee_outpost_foundo2" ] = "lava_kee_outpost_foundo2";
	level._scr_radio[ "lava_fra_outpost_o2" ] = "lava_fra_outpost_o2";
	level._scr_radio[ "lava_fra_outpost_thoughtdonefor" ] = "lava_fra_outpost_thoughtdonefor";
	level._scr_radio[ "lava_fra_outpost_commander" ] = "lava_fra_outpost_commander";
	level._scr_radio[ "lava_kee_outpost_muchbetter" ] = "lava_kee_outpost_muchbetter";
	level._scr_radio[ "lava_kee_outpost_goodforo2" ] = "lava_kee_outpost_goodforo2";
	level._scr_radio[ "lava_kee_outpost_pickupshotgun" ] = "lava_kee_outpost_pickupshotgun";
	level._scr_radio[ "lava_kee_outpost_wtfbasehere" ] = "lava_kee_outpost_wtfbasehere";
	level._scr_radio[ "lava_kee_outpost_figureoutcontrols" ] = "lava_kee_outpost_figureoutcontrols";
	level._scr_radio[ "lava_fra_outpost_christ" ] = "lava_fra_outpost_christ";
	level._scr_radio[ "lava_kee_outpost_elevatorsystem" ] = "lava_kee_outpost_elevatorsystem";
	level._scr_radio[ "lava_car_garage_tangosahead" ] = "lava_car_garage_tangosahead";
	level._scr_radio[ "lava_kee_garage_takethemdown" ] = "lava_kee_garage_takethemdown";
	level._scr_radio[ "lava_car_garage_technicalsandtroops" ] = "lava_car_garage_technicalsandtroops";
	level._scr_radio[ "lava_kee_garage_notlookinggood" ] = "lava_kee_garage_notlookinggood";
	level._scr_radio[ "lava_kee_garage_technicalincoming" ] = "lava_kee_garage_technicalincoming";
	level._scr_radio[ "lava_kee_garage_staydown" ] = "lava_kee_garage_staydown";
	level._scr_radio[ "lava_kee_garage_deadfriends" ] = "lava_kee_garage_deadfriends";
	level._scr_radio[ "lava_car_garage_anotherlift" ] = "lava_car_garage_anotherlift";
	level._scr_radio[ "lava_kee_garage_theconsole" ] = "lava_kee_garage_theconsole";
	level._scr_radio[ "lava_kee_station1_holyshit" ] = "lava_kee_station1_holyshit";
	level._scr_radio[ "lava_kee_station1_hostilestrain" ] = "lava_kee_station1_hostilestrain";
	level._scr_radio[ "lava_kee_station1_miningtracks" ] = "lava_kee_station1_miningtracks";
	level._scr_radio[ "lava_fra_station1_whoknowshowbig" ] = "lava_fra_station1_whoknowshowbig";
	level._scr_radio[ "lava_kee_station1_canyoureadme" ] = "lava_kee_station1_canyoureadme";
	level._scr_radio[ "lava_kee_station1_tangosbelow" ] = "lava_kee_station1_tangosbelow";
	level._scr_radio[ "lava_kee_station1_keepmoving" ] = "lava_kee_station1_keepmoving";
	level._scr_radio[ "lava_kee_station1_letsmove" ] = "lava_kee_station1_letsmove";
	level._scr_radio[ "lava_car_st1cmd_gottabekidding" ] = "lava_car_st1cmd_gottabekidding";
	level._scr_radio[ "lava_kee_st1cmd_oldminingrails" ] = "lava_kee_st1cmd_oldminingrails";
	level._scr_radio[ "lava_car_st1cmd_howtheyhitus" ] = "lava_car_st1cmd_howtheyhitus";
	level._scr_radio[ "lava_kee_st1cmd_takepost" ] = "lava_kee_st1cmd_takepost";
	level._scr_radio[ "lava_kee_st1cmd_moredata" ] = "lava_kee_st1cmd_moredata";
	level._scr_radio[ "lava_kee_st1cmd_databacktobase" ] = "lava_kee_st1cmd_databacktobase";
	level._scr_radio[ "lava_fra_st1cmd_reinforcements" ] = "lava_fra_st1cmd_reinforcements";
	level._scr_radio[ "lava_kee_st1cmd_aintgettingout" ] = "lava_kee_st1cmd_aintgettingout";
	level._scr_radio[ "lava_kee_st1cmd_takecover" ] = "lava_kee_st1cmd_takecover";
	level._scr_radio[ "lava_kee_st1train_getthismoving" ] = "lava_kee_st1train_getthismoving";
	level._scr_radio[ "lava_kee_st1train_getlmgandgeton" ] = "lava_kee_st1train_getlmgandgeton";
	level._scr_radio[ "lava_kee_st1train_figureouttrain" ] = "lava_kee_st1train_figureouttrain";
	level._scr_radio[ "lava_kee_st1train_wereoff" ] = "lava_kee_st1train_wereoff";
	level._scr_radio[ "lava_car_st1train_trainfromrear" ] = "lava_car_st1train_trainfromrear";
	level._scr_radio[ "lava_kee_st1train_gotcompany1" ] = "lava_kee_st1train_gotcompany1";
	level._scr_radio[ "lava_kee_st1train_switchedofftrack" ] = "lava_kee_st1train_switchedofftrack";
	level._scr_radio[ "lava_kee_st1train_trainstopping" ] = "lava_kee_st1train_trainstopping";
	level._scr_radio[ "lava_kee_st1train_gotcompany2" ] = "lava_kee_st1train_gotcompany2";
	level._scr_radio[ "lava_kee_st1train_aimlow" ] = "lava_kee_st1train_aimlow";
	level._scr_radio[ "lava_car_st1train_comsrestored" ] = "lava_car_st1train_comsrestored";
	level._scr_radio[ "lava_kee_st1train_deepshit" ] = "lava_kee_st1train_deepshit";
	level._scr_radio[ "lava_mctrl_st1train_rescuesquad" ] = "lava_mctrl_st1train_rescuesquad";
	level._scr_radio[ "lava_kee_st1train_holdon" ] = "lava_kee_st1train_holdon";
	level._scr_radio[ "lava_ser_surface_ohshit" ] = "lava_ser_surface_ohshit";
	level._scr_radio[ "lava_ser_surface_outpost" ] = "lava_ser_surface_outpost";
	level._scr_radio[ "lava_ser_surface_rover3tangos" ] = "lava_ser_surface_rover3tangos";
	level._scr_radio[ "lava_ser_outpost_christ" ] = "lava_ser_outpost_christ";
	level._scr_radio[ "lava_ser_garage_howtroopsmoved" ] = "lava_ser_garage_howtroopsmoved";
	level._scr_radio[ "lava_ser_st1_holyshit" ] = "lava_ser_st1_holyshit";
	level._scr_radio[ "lava_ser_st1cmd_boss" ] = "lava_ser_st1cmd_boss";
	level._scr_radio[ "lava_ser_st1cmd_leftbehind" ] = "lava_ser_st1cmd_leftbehind";
	level._scr_radio[ "lava_ser_train1_trainfromrear" ] = "lava_ser_train1_trainfromrear";
	level._scr_radio[ "lava_ser_st2_nextstation" ] = "lava_ser_st2_nextstation";
	level._scr_radio[ "lava_ser_st2_bladework" ] = "lava_ser_st2_bladework";
	level._scr_radio[ "lava_ser_st2_handovernuke" ] = "lava_ser_st2_handovernuke";
	level._scr_radio[ "lava_ser_st2_hostiles" ] = "lava_ser_st2_hostiles";
	level._scr_radio[ "lava_ser_st2_deathscream" ] = "lava_ser_st2_deathscream";
	level._scr_radio[ "lava_cam_st1cmd_clear" ] = "lava_cam_st1cmd_clear";
	level._scr_radio[ "lava_bak_st1cmd_clear" ] = "lava_bak_st1cmd_clear";
	level._scr_radio[ "lava_bak_st1cmd_makeitquick" ] = "lava_bak_st1cmd_makeitquick";
	level._scr_radio[ "lava_cam_st1cmd_camera3" ] = "lava_cam_st1cmd_camera3";
	level._scr_radio[ "lava_bak_st1cmd_warhead" ] = "lava_bak_st1cmd_warhead";
	level._scr_radio[ "lava_cam_st1cmd_fewklicks" ] = "lava_cam_st1cmd_fewklicks";
	level._scr_radio[ "lava_bak_st1cmd_wtfkeene" ] = "lava_bak_st1cmd_wtfkeene";
	level._scr_radio[ "lava_cam_st1cmd_inluck" ] = "lava_cam_st1cmd_inluck";
	level._scr_radio[ "lava_bak_st1cmd_eta" ] = "lava_bak_st1cmd_eta";
	level._scr_radio[ "lava_cam_st1cmd_60sec" ] = "lava_cam_st1cmd_60sec";
	level._scr_radio[ "lava_bak_st1cmd_notgoingtomakeit" ] = "lava_bak_st1cmd_notgoingtomakeit";
	level._scr_radio[ "lava_cam_st1cmd_stayandprogram" ] = "lava_cam_st1cmd_stayandprogram";
	level._scr_radio[ "lava_cam_st1cmd_knewthescore" ] = "lava_cam_st1cmd_knewthescore";
	level._scr_radio[ "lava_cam_st1cmd_sortkeene" ] = "lava_cam_st1cmd_sortkeene";
	level._scr_radio[ "lava_bak_st1cmd_seeyoucam" ] = "lava_bak_st1cmd_seeyoucam";
	level._scr_radio[ "lava_bak_st1cmd_charliemike" ] = "lava_bak_st1cmd_charliemike";
	level._scr_radio[ "lava_bak_st1cmd_cheerupmate" ] = "lava_bak_st1cmd_cheerupmate";
	level._scr_radio[ "lava_cam_st1cmd_reprogrammed" ] = "lava_cam_st1cmd_reprogrammed";
	level._scr_radio[ "lava_bak_train1_get2train" ] = "lava_bak_train1_get2train";
	level._scr_radio[ "lava_bak_train1_wereoff" ] = "lava_bak_train1_wereoff";
	level._scr_radio[ "lava_cam_surface_slowingdown" ] = "lava_cam_surface_slowingdown";
	level._scr_radio[ "lava_bak_surface_seeanything" ] = "lava_bak_surface_seeanything";
	level._scr_radio[ "lava_bak_surface_doubletime" ] = "lava_bak_surface_doubletime";
	level._scr_radio[ "lava_bak_surface_readyrifles" ] = "lava_bak_surface_readyrifles";
	level._scr_radio[ "lava_bak_surface_assigntargets" ] = "lava_bak_surface_assigntargets";
	level._scr_radio[ "lava_bak_surface_holdon321" ] = "lava_bak_surface_holdon321";
	level._scr_radio[ "lava_bak_surface_goodshots" ] = "lava_bak_surface_goodshots";
	level._scr_radio[ "lava_bak_surface_stackup" ] = "lava_bak_surface_stackup";
	level._scr_radio[ "lava_bak_outpost_weaponscache" ] = "lava_bak_outpost_weaponscache";
	level._scr_radio[ "lava_cam_surface_loadingbay" ] = "lava_cam_surface_loadingbay";
	level._scr_radio[ "lava_bak_outpost_figureoutcontrols" ] = "lava_bak_outpost_figureoutcontrols";
	level._scr_radio[ "lava_bak_garage_takethemdown" ] = "lava_bak_garage_takethemdown";
	level._scr_radio[ "lava_bak_garage_notlookinggood" ] = "lava_bak_garage_notlookinggood";
	level._scr_radio[ "lava_bak_garage_technicalincoming" ] = "lava_bak_garage_technicalincoming";
	level._scr_radio[ "lava_bak_garage_staydown" ] = "lava_bak_garage_staydown";
	level._scr_radio[ "lava_bak_garage_deadfriends" ] = "lava_bak_garage_deadfriends";
	level._scr_radio[ "lava_bak_garage_theconsole" ] = "lava_bak_garage_theconsole";
	level._scr_radio[ "lava_bak_station1_undetected" ] = "lava_bak_station1_undetected";
	level._scr_radio[ "lava_cam_station1_gothim" ] = "lava_cam_station1_gothim";
	level._scr_radio[ "lava_cam_station1_somethingsup" ] = "lava_cam_station1_somethingsup";
	level._scr_radio[ "lava_cam_station1_bloodyhell" ] = "lava_cam_station1_bloodyhell";
	level._scr_radio[ "lava_bak_station1_caughtalift" ] = "lava_bak_station1_caughtalift";
	level._scr_radio[ "lava_cam_station1_nevercatch" ] = "lava_cam_station1_nevercatch";
	level._scr_radio[ "lava_bak_station1_hitcharide" ] = "lava_bak_station1_hitcharide";
	level._scr_radio[ "lava_bak_station1_tangosbelow" ] = "lava_bak_station1_tangosbelow";
	level._scr_radio[ "lava_bak_station1_keepmoving" ] = "lava_bak_station1_keepmoving";
	level._scr_radio[ "lava_bak_station1_hostilestrain" ] = "lava_bak_station1_hostilestrain";
	level._scr_radio[ "lava_bak_station1_letsmove" ] = "lava_bak_station1_letsmove";
	level._scr_radio[ "lava_bak_st1train_gotcompany1" ] = "lava_bak_st1train_gotcompany1";
	level._scr_radio[ "lav_bak_st1train_takeoutturret" ] = "lav_bak_st1train_takeoutturret";
	level._scr_radio[ "lava_bak_st1train_walkerlowammo" ] = "lava_bak_st1train_walkerlowammo";
	level._scr_radio[ "lava_bak_st1train_trackingbeacon" ] = "lava_bak_st1train_trackingbeacon";
	level._scr_radio[ "lava_bak_st2_ourstopgetready" ] = "lava_bak_st2_ourstopgetready";
	level._scr_radio[ "lava_bak_st2_aimforaircanisters" ] = "lava_bak_st2_aimforaircanisters";
	level._scr_radio[ "lava_bak_st2_moveintobuilding" ] = "lava_bak_st2_moveintobuilding";
	level._scr_radio[ "lava_bak_st2_bodiesiced" ] = "lava_bak_st2_bodiesiced";
	level._scr_radio[ "lava_bak_st2_whatthehell" ] = "lava_bak_st2_whatthehell";
	level._scr_radio[ "lava_bak_st2_moveout" ] = "lava_bak_st2_moveout";
	level._scr_radio[ "lava_bak_st2_isaidmoveout" ] = "lava_bak_st2_isaidmoveout";
	level._scr_radio[ "lava_kee_st2_walker" ] = "lava_kee_st2_walker";
	level._scr_radio[ "lava_bak_st2_traitor" ] = "lava_bak_st2_traitor";
	level._scr_radio[ "lava_kee_st2_nosnake" ] = "lava_kee_st2_nosnake";
	level._scr_radio[ "lava_bak_st2_betrayed" ] = "lava_bak_st2_betrayed";
	level._scr_radio[ "lava_kee_st2_dontbelievethat" ] = "lava_kee_st2_dontbelievethat";
	level._scr_radio[ "lava_bak_st2_explainwarhead" ] = "lava_bak_st2_explainwarhead";
	level._scr_radio[ "lava_kee_st2_griffwasdead" ] = "lava_kee_st2_griffwasdead";
	level._scr_radio[ "lava_bak_st2_who" ] = "lava_bak_st2_who";
	level._scr_radio[ "lava_kee_st2_shotfirst" ] = "lava_kee_st2_shotfirst";
	level._scr_radio[ "lava_kee_st2_onlyoneleft" ] = "lava_kee_st2_onlyoneleft";
	level._scr_radio[ "lava_bak_st2_finishmission" ] = "lava_bak_st2_finishmission";
	level._scr_radio[ "lava_kee_st2_whatwouldyoudo" ] = "lava_kee_st2_whatwouldyoudo";
	level._scr_radio[ "lava_kee_st2_buttonup" ] = "lava_kee_st2_buttonup";
	level._scr_radio[ "lava_kee_bridge_listenup" ] = "lava_kee_bridge_listenup";
	level._scr_radio[ "lava_kee_bridge_followme" ] = "lava_kee_bridge_followme";
	level._scr_radio[ "lava_bak_bridge_heardtheman" ] = "lava_bak_bridge_heardtheman";
	level._scr_radio[ "lava_kee_bridge_jumpdown" ] = "lava_kee_bridge_jumpdown";
	level._scr_radio[ "lava_kee_trnint_crawlingwithec" ] = "lava_kee_trnint_crawlingwithec";
	level._scr_radio[ "lava_kee_trnint_goleft" ] = "lava_kee_trnint_goleft";
	level._scr_radio[ "lava_bak_trnint_showup" ] = "lava_bak_trnint_showup";
	level._scr_radio[ "lava_kee_trnint_moveup2roof" ] = "lava_kee_trnint_moveup2roof";
	level._scr_radio[ "lava_kee_trnint_tornapart" ] = "lava_kee_trnint_tornapart";
	level._scr_radio[ "lava_kee_trnint_jump" ] = "lava_kee_trnint_jump";
	level._scr_radio[ "lava_bak_trint_jackpot" ] = "lava_bak_trint_jackpot";
	level._scr_radio[ "lava_kee_trint_manturret" ] = "lava_kee_trint_manturret";
	level._scr_radio[ "lava_kee_tr2turr_aimforturret" ] = "lava_kee_tr2turr_aimforturret";
	level._scr_radio[ "lava_kee_tr2turr_destroyconnector" ] = "lava_kee_tr2turr_destroyconnector";
	level._scr_radio[ "lava_kee_tr2skim_5birds" ] = "lava_kee_tr2skim_5birds";
	level._scr_radio[ "lava_bak_tr2skim_comsrestored" ] = "lava_bak_tr2skim_comsrestored";
	level._scr_radio[ "lava_kee_tr2skim_moreonright" ] = "lava_kee_tr2skim_moreonright";
	level._scr_radio[ "lava_mctrl_tr2skim_rescuesquad" ] = "lava_mctrl_tr2skim_rescuesquad";
	level._scr_radio[ "lava_bak_tr2skim_getheresoon" ] = "lava_bak_tr2skim_getheresoon";
	level._scr_radio[ "lava_kee_derail_stillwithme" ] = "lava_kee_derail_stillwithme";
	level._scr_radio[ "lava_bak_st2_beacon" ] = "lava_bak_st2_beacon";
	level._scr_radio[ "lava_bak_st2_getliftmoving" ] = "lava_bak_st2_getliftmoving";
	level._scr_radio[ "lava_bak_st2_snakeskin" ] = "lava_bak_st2_snakeskin";
	level._scr_radio[ "lava_cam_st1cmd_getonquick" ] = "lava_cam_st1cmd_getonquick";
	level._scr_radio[ "lava_kee_st2_doingmyjob" ] = "lava_kee_st2_doingmyjob";
	level._scr_radio[ "lava_kee_st2turr_letloose" ] = "lava_kee_st2turr_letloose";
	level._scr_radio[ "lava_kee_st2turr_enemiesplatform" ] = "lava_kee_st2turr_enemiesplatform";
	level._scr_radio[ "lava_kee_derail_braceforimpact" ] = "lava_kee_derail_braceforimpact";
	level._scr_radio[ "lava_ser_station1_snipersoncatwalk" ] = "lava_ser_station1_snipersoncatwalk";
	level._scr_radio[ "lava_ser_station1_tangosoncatwalk" ] = "lava_ser_station1_tangosoncatwalk";
	level._scr_radio[ "lava_bak_station1_wastetangos" ] = "lava_bak_station1_wastetangos";
	level._scr_radio[ "lava_bak_st2_securenuke" ] = "lava_bak_st2_securenuke";
	level._scr_radio[ "lava_bak_trnint_grunts" ] = "lava_bak_trnint_grunts";
	level._scr_radio[ "lava_ec_trnint_aaagh" ] = "lava_ec_trnint_aaagh";
	level._scr_radio[ "lava_bak_trnint_needtokeepmoving" ] = "lava_bak_trnint_needtokeepmoving";
	level._scr_radio[ "lava_bak_trnint_youleftmeright" ] = "lava_bak_trnint_youleftmeright";
	level._scr_radio[ "lava_bak_trnint_contactfront" ] = "lava_bak_trnint_contactfront";
	level._scr_radio[ "lava_bak_trnint_contactright" ] = "lava_bak_trnint_contactright";
	level._scr_radio[ "lava_bak_trnint_niceshot" ] = "lava_bak_trnint_niceshot";
	level._scr_radio[ "lava_bak_trnint_goodkill" ] = "lava_bak_trnint_goodkill";
	level._scr_radio[ "lava_bak_trnint_sweepandclear" ] = "lava_bak_trnint_sweepandclear";
	level._scr_radio[ "lava_bak_trnint_gogogo" ] = "lava_bak_trnint_gogogo";
	level._scr_radio[ "lava_bak_trnint_advancingwatchleft" ] = "lava_bak_trnint_advancingwatchleft";
	level._scr_radio[ "lava_bak_trnint_clear" ] = "lava_bak_trnint_clear";
	level._scr_radio[ "lava_bak_trnint_roomclear" ] = "lava_bak_trnint_roomclear";
	level._scr_radio[ "lava_bak_trnint_clearmoveup" ] = "lava_bak_trnint_clearmoveup";
	level._scr_radio[ "lava_bak_trnint_contactleft" ] = "lava_bak_trnint_contactleft";
	level._scr_radio[ "lava_bak_trnint_tangosahead" ] = "lava_bak_trnint_tangosahead";
	level._scr_radio[ "lava_bak_trnint_takepoint" ] = "lava_bak_trnint_takepoint";
	level._scr_radio[ "lava_bak_trnint_tangos12oclock" ] = "lava_bak_trnint_tangos12oclock";
	level._scr_radio[ "lava_bak_trnint_engaging" ] = "lava_bak_trnint_engaging";
	level._scr_radio[ "lava_bak_trnint_onme" ] = "lava_bak_trnint_onme";
	level._scr_radio[ "lava_bak_trnint_yougohigh" ] = "lava_bak_trnint_yougohigh";
	level._scr_radio[ "lava_bak_trnint_contactsocfor" ] = "lava_bak_trnint_contactsocfor";
	level._scr_radio[ "lava_bak_trnint_pushforward" ] = "lava_bak_trnint_pushforward";
	level._scr_radio[ "lava_bak_trnint_3upfront" ] = "lava_bak_trnint_3upfront";
	level._scr_radio[ "lava_bak_trnint_moveup" ] = "lava_bak_trnint_moveup";
	level._scr_radio[ "lava_bak_trnint_clear_02" ] = "lava_bak_trnint_clear_02";
	level._scr_radio[ "lava_bak_tr2turr_contactleft" ] = "lava_bak_tr2turr_contactleft";
	level._scr_radio[ "lava_bak_tr2turr_cut2pieces" ] = "lava_bak_tr2turr_cut2pieces";
	level._scr_radio[ "lava_bak_trnint_jump" ] = "lava_bak_trnint_jump";
	level._scr_radio[ "lava_bak_tr2turr_hvywpn10oclock" ] = "lava_bak_tr2turr_hvywpn10oclock";
	level._scr_radio[ "lava_bak_tr2turr_trainonleft" ] = "lava_bak_tr2turr_trainonleft";
	level._scr_radio[ "lava_bak_tr2turr_takingfire" ] = "lava_bak_tr2turr_takingfire";
	level._scr_radio[ "lava_bak_tr2turr_manturret" ] = "lava_bak_tr2turr_manturret";
	level._scr_radio[ "lava_bak_tr2turr_lightemup" ] = "lava_bak_tr2turr_lightemup";
	level._scr_radio[ "lava_bak_tr2turr_targeto2tanks" ] = "lava_bak_tr2turr_targeto2tanks";
	level._scr_radio[ "lava_bak_tr2turr_hittanks" ] = "lava_bak_tr2turr_hittanks";
	level._scr_radio[ "lava_bak_tr2turr_takeoutguncrews" ] = "lava_bak_tr2turr_takeoutguncrews";
	level._scr_radio[ "lava_bak_tr2turr_teartrainapart" ] = "lava_bak_tr2turr_teartrainapart";
	level._scr_radio[ "lava_bak_tr2turr_goodkill" ] = "lava_bak_tr2turr_goodkill";
	level._scr_radio[ "lava_bak_tr2turr_trainsonright" ] = "lava_bak_tr2turr_trainsonright";
	level._scr_radio[ "lava_bak_tr2turr_keepfiring" ] = "lava_bak_tr2turr_keepfiring";
	level._scr_radio[ "lava_bak_tr2turr_trainat3oclock" ] = "lava_bak_tr2turr_trainat3oclock";
	level._scr_radio[ "lava_bak_tr2turr_tangosonplatform" ] = "lava_bak_tr2turr_tangosonplatform";
	level._scr_radio[ "lava_bak_tr2turr_aimlow" ] = "lava_bak_tr2turr_aimlow";
	level._scr_radio[ "lava_bak_tr2turr_takeoutwheels" ] = "lava_bak_tr2turr_takeoutwheels";
	level._scr_radio[ "lava_bak_tr2turr_knockoffrails" ] = "lava_bak_tr2turr_knockoffrails";
	level._scr_radio[ "lava_bak_tr2turr_ceasefire" ] = "lava_bak_tr2turr_ceasefire";
	level._scr_radio[ "lava_bak_tr2turr_hightowerzulu1" ] = "lava_bak_tr2turr_hightowerzulu1";
	level._scr_radio[ "lava_mctrl_tr2turr_statusandloc" ] = "lava_mctrl_tr2turr_statusandloc";
	level._scr_radio[ "lava_bak_tr2turr_recoveredintel" ] = "lava_bak_tr2turr_recoveredintel";
	level._scr_radio[ "lava_mctrl_tr2turr_dispatchingsear" ] = "lava_mctrl_tr2turr_dispatchingsear";
	level._scr_radio[ "lava_bak_tr2turr_dontneedrescue" ] = "lava_bak_tr2turr_dontneedrescue";
	level._scr_radio[ "lava_bak_tr2turr_enemyairinbound" ] = "lava_bak_tr2turr_enemyairinbound";
	level._scr_radio[ "lava_bak_tr2turr_incoming" ] = "lava_bak_tr2turr_incoming";
	level._scr_radio[ "lava_bak_tr2turr_skimmers12oclock" ] = "lava_bak_tr2turr_skimmers12oclock";
	level._scr_radio[ "lava_bak_tr2turr_moredrones3oclock" ] = "lava_bak_tr2turr_moredrones3oclock";
	level._scr_radio[ "lava_bak_tr2turr_rightside" ] = "lava_bak_tr2turr_rightside";
	level._scr_radio[ "lava_bak_tr2turr_3oclock" ] = "lava_bak_tr2turr_3oclock";
	level._scr_radio[ "lava_bak_derail_heretheycomeagain" ] = "lava_bak_derail_heretheycomeagain";
	level._scr_radio[ "lava_bak_derail_toomanyofthem" ] = "lava_bak_derail_toomanyofthem";
	level._scr_radio[ "lava_bak_derail_braceforimpact" ] = "lava_bak_derail_braceforimpact";
	level._scr_radio[ "lava_bak_derail_holdon" ] = "lava_bak_derail_holdon";
}

#using_animtree("player");
player_anims()
{
	level._scr_animtree[ "player_rig" ] = #animtree;
	level._scr_anim[ "player_rig" ][ "opening_walk" ] = %nx_fp_lava_opening_walk_player;
	level._scr_model[ "player_rig" ] = "viewhands_us_lunar_scripted";

	level._scr_anim[ "player_rig" ][ "air_resupply_baker_faint" ] = %nx_fp_lava_refill_air_keene_collapse_player;

	// control room breach
	level._scr_anim[ "player_rig" ][ "control_room_breach" ] = %nx_fp_lava_control_breach_player;

	// keene standoff
	level._scr_anim[ "player_rig" ][ "keene_standoff" ] = %nx_fp_lava_control_breach_player;
	level._scr_anim[ "player_rig" ][ "bridge_to_train_jump" ] = %nx_fp_lava_bridge_to_train_jump_player;
	level._scr_anim[ "player_rig" ][ "train2_tillmanreveal" ] = %nx_fp_lava_train2_tillmanreveal_player;

	// train turret battle - near miss with tank
	level._scr_anim[ "player_rig" ][ "turret_battle_tank_near_hit" ] = %nx_fp_lava_turret_battle_near_hit_player;
	level._scr_anim[ "player_rig" ][ "data_retrieval" ] = %nx_fp_lava_retrieve_intel;
	level._scr_anim[ "player_rig" ][ "camren_sacrifice_player" ] = %nx_fp_lava_camrensacrifice_player;
	level._scr_anim[ "player_rig" ][ "angelsquad_reveal" ] = %nx_fp_lava_angelsquad_player;
	level._scr_animtree[ "player_rig" ] = #animtree;
	level._scr_anim[ "player_rig" ][ "train_interior_getup" ] = %nx_fp_lava_bridge_to_train_jump_player_short;

	// train seperate
	//level._scr_anim[ "player_rig" ][ "train_seperate" ] = %nx_fp_lava_trainseperate_player;

	// train seperate fall
	level._scr_anim[ "player_rig" ][ "train_seperate_fall" ] = %nx_fp_lava_trainseperate_fall_player;

	// train seperate jump
	level._scr_anim[ "player_rig" ][ "train_seperate_player_jump" ] = %nx_fp_lava_trainseperate_player_jump;
	addNotetrack_customFunction( "player_rig", "land", ::train_seperate_quake, "train_seperate_player_jump" );
	addNotetrack_customFunction( "player_rig", "trainexplosion", ::train_seperate_quake, "train_seperate_player_jump" );
	// train derailment
	level._scr_anim[ "player_rig" ][ "train_derailment" ] = %nx_fp_lava_train_derailment_player;
}

#using_animtree("script_model");
script_models()
{
	level._scr_animtree[ "train_interior_getup_train" ] = #animtree;
	level._scr_anim[ "train_interior_getup_train" ][ "train_interior_getup" ] = %nx_pr_lava_bridge_to_train_jump_train_short;
	level._scr_model[ "train_interior_getup_train" ] = "nx_lava_train_infinite_fullmodel";
	
	level._scr_animtree[ "weldingarm1" ] = #animtree;
	level._scr_anim[ "weldingarm1" ][ "weldingarms_skimmer1" ] = %nx_pr_lava_weldingarm_skimmer1;
	level._scr_model[ "weldingarm1" ] = "nx_pr_lava_weldingarm";

	level._scr_animtree[ "weldingarm2" ] = #animtree;
	level._scr_anim[ "weldingarm2" ][ "weldingarms_skimmer1" ] = %nx_pr_lava_weldingarm_skimmer2;
	level._scr_model[ "weldingarm2" ] = "nx_pr_lava_weldingarm";

	level._scr_animtree[ "bridge" ] = #animtree;
	level._scr_anim[ "bridge" ][ "bridge_to_train_jump" ] = %nx_pr_lava_bridge_to_train_jump_bridge;
	level._scr_sound[ "bridge" ][ "bridge_to_train_jump" ] = "scn_lava_jump_to_train";
	//level._scr_sound[ "player_rig" ] = "scn_lava_jump_to_train";
	level._scr_model[ "bridge" ] = "nx_pr_lava_bridge_to_train_jump_bridge";

	level._scr_animtree[ "debris" ] = #animtree;
	level._scr_anim[ "debris" ][ "bridge_to_train_jump" ] = %nx_pr_lava_bridge_to_train_jump_debris_anim;
	level._scr_model[ "debris" ] = "nx_pr_lava_bridge_to_train_jump_debris";

	level._scr_animtree[ "crane" ] = #animtree;
	level._scr_anim[ "crane" ][ "underground_reveal" ] = %nx_pr_lava_undergroundreveal_crane;
	level._scr_model[ "crane" ] = "nx_pr_lava_crane_vignette";

	level._scr_animtree[ "luner_lift_1" ] = #animtree;
	level._scr_anim[ "luner_lift_1" ][ "underground_reveal" ] = %nx_vh_lava_undergroundreveal_lift_1;
	level._scr_model[ "luner_lift_1" ] = "nx_vehicle_ec_lunar_lift";

	level._scr_animtree[ "lunar_lift_2" ] = #animtree;
	level._scr_anim[ "lunar_lift_2" ][ "underground_reveal" ] = %nx_vh_lava_undergroundreveal_lift_2;
	level._scr_model[ "lunar_lift_2" ] = "nx_vehicle_ec_lunar_lift";

	//level._scr_animtree[ "crate" ] = #animtree;
	//level._scr_anim[ "crate" ][ "crane_movement2" ] = %nx_pr_lava_undergroundreveal_cargocrate;
	//level._scr_model[ "crate" ] = "nx_pr_lava_cargocrate";

	level._scr_animtree[ "pipe" ] = #animtree;
	level._scr_anim[ "pipe" ][ "bridge_to_train_jump" ] = %nx_pr_lava_bridge_to_train_jump_pipe;
	level._scr_model[ "pipe" ] = "nx_pr_lava_bridge_to_train_jump_pipe";

	level._scr_animtree[ "train_bridge" ] = #animtree;
	level._scr_anim[ "train_bridge" ][ "bridge_to_train_jump" ] = %nx_pr_lava_bridge_to_train_jump_train;
	level._scr_model[ "train_bridge" ] = "nx_lava_train_infinite_fullmodel"; 

	// train turret battle script models
	level._scr_animtree[ "train3_car4_front" ] = #animtree;


	level._scr_anim[ "train3_car4_front" ][ "train3_car4_front" ] = %nx_pr_lava_turret_battle_train3_car4_cargo_front;


	level._scr_model[ "train3_car4_front" ] = "nx_pr_lava_train3_car4_front_cargo";



	level._scr_animtree[ "train3_car4_mid" ] = #animtree;

	level._scr_anim[ "train3_car4_mid" ][ "train3_car4_mid" ] = %nx_pr_lava_turret_battle_train3_car4_cargo_middle;

	level._scr_model[ "train3_car4_mid" ] = "nx_pr_lava_train3_car4_mid_cargo";


	level._scr_animtree[ "train3_car4_rear" ] = #animtree;
	level._scr_anim[ "train3_car4_rear" ][ "train3_car4_rear" ] = %nx_pr_lava_turret_battle_train3_car4_cargo_rear;
	level._scr_model[ "train3_car4_rear" ] = "nx_pr_lava_train3_car4_rear_cargo";

	level._scr_animtree[ "train3_car3_front" ] = #animtree;
	level._scr_anim[ "train3_car3_front" ][ "train3_car3_front" ] = %nx_pr_lava_turret_battle_train3_car3_front;
	level._scr_model[ "train3_car3_front" ] = "nx_pr_lava_train3_car3_cargo_front";
	level._scr_animtree[ "rocket_tanks" ] = #animtree;
	level._scr_anim[ "rocket_tanks" ][ "turret_battle_rocket_engine_tanks_explosion" ] = %nx_pr_lava_turret_battle_train3_car5_front;
	level._scr_model[ "rocket_tanks" ] = "nx_pr_lava_train3_car5_cargo_front";

	level._scr_animtree[ "rocket_engine" ] = #animtree;
	level._scr_anim[ "rocket_engine" ][ "turret_battle_rocket_engine_explosion" ] = %nx_pr_lava_turret_battle_train3_car5_rear;
	level._scr_model[ "rocket_engine" ] = "nx_pr_lava_train3_car5_cargo_rear";

	level._scr_animtree[ "train3_car1_platform" ] = #animtree;
	level._scr_anim[ "train3_car1_platform" ][ "train3_car1_derail" ] = %nx_pr_lava_turret_battle_train3_car1_platform;
	level._scr_model[ "train3_car1_platform" ] = "nx_pr_lava_train3_car1";
	addNotetrack_customFunction( "train3_car1_platform", "fx_derail_start_nt", maps\nx_lava_fx::fx_train3_car1_derail_start );
	addNotetrack_customFunction( "train3_car1_platform", "fx_derail_pod_breakoff_nt", maps\nx_lava_fx::fx_train3_car1_derail_pod_breakoff );
	addNotetrack_customFunction( "train3_car1_platform", "fx_derail_lr_touchdown_nt", maps\nx_lava_fx::fx_train3_car1_derail_lr_touchdown );

	level._scr_animtree[ "train3_car1_cargo_front" ] = #animtree;
	level._scr_anim[ "train3_car1_cargo_front" ][ "train3_car1_derail" ] = %nx_pr_lava_turret_battle_train3_car1_cargo_front;
	level._scr_model[ "train3_car1_cargo_front" ] = "nx_pr_lava_train3_car1_front_cargo";

	level._scr_animtree[ "train3_car1_cargo_rear" ] = #animtree;
	level._scr_anim[ "train3_car1_cargo_rear" ][ "train3_car1_derail" ] = %nx_pr_lava_turret_battle_train3_car1_cargo_rear;
	level._scr_model[ "train3_car1_cargo_rear" ] = "nx_pr_lava_train3_car1_rear_cargo";

	level._scr_animtree[ "crates" ] = #animtree;
	level._scr_anim[ "crates" ][ "turret_battle_crate_explosion" ] = %nx_pr_lava_turret_battle_train3_car3_rear;
	level._scr_model[ "crates" ] = "nx_pr_lava_train3_car3_cargo_rear";

	level._scr_animtree[ "tankers" ] = #animtree;
	level._scr_anim[ "tankers" ][ "turret_battle_tanker_explosion" ] = %nx_pr_lava_turret_battle_train3_car3_front;
	level._scr_model[ "tankers" ] = "nx_pr_lava_train3_car3_cargo_front";
	
	level._scr_animtree[ "tires" ] = #animtree;
	level._scr_anim[ "tires" ][ "turret_battle_tire_explosion" ] = %nx_pr_lava_turret_battle_tire_explosion;
	level._scr_model[ "tires" ] = "nx_pr_lava_train_derailment_tires";

	level._scr_animtree[ "tank" ] = #animtree;
	level._scr_anim[ "tank" ][ "turret_battle_tank_near_hit" ] = %nx_pr_lava_turret_battle_near_hit_tank;
	level._scr_model[ "tank" ] = "nx_pr_lava_turret_battle_tank_near_hit";

	level._scr_animtree[ "train_derail" ] = #animtree;
	level._scr_anim[ "train_derail" ][ "turret_battle_train_derail" ] = %nx_pr_lava_turret_battle_train_derail;
	level._scr_model[ "train_derail" ] = "nx_pr_lava_turret_battle_train_derail";

	level._scr_animtree[ "train_derail_02" ] = #animtree;
	level._scr_anim[ "train_derail_02" ][ "turret_battle_train_derail_02" ] = %nx_pr_lava_turret_battle_train_derail_02;
	level._scr_model[ "train_derail_02" ] = "nx_pr_lava_turret_battle_train_derail_02";

	// skimmer battle
	level._scr_animtree[ "tower_collapse" ] = #animtree;
	level._scr_anim[ "tower_collapse" ][ "skimmer_crash_tower" ] = %nx_pr_lava_skimmer_battle_tower_collapse_anim;
	level._scr_model[ "tower_collapse" ] = "nx_pr_lava_skimmer_battle_tower_collapse";

	level._scr_animtree[ "rocks" ] = #animtree;
	level._scr_anim[ "rocks" ][ "skimmer_crash_rocks" ] = %nx_pr_lava_skimmer_battle_01_rocks_anim;
	level._scr_model[ "rocks" ] = "nx_pr_lava_skimmer_battle_01_rocks";

	level._scr_animtree[ "rocks" ] = #animtree;
	level._scr_anim[ "rocks" ][ "skimmer_crash_rocks_02" ] = %nx_pr_lava_skimmer_battle_01_rocks_anim;
	level._scr_model[ "rocks" ] = "nx_pr_lava_skimmer_battle_01_rocks";

	// train derailment

	level._scr_animtree[ "train_car_01" ] = #animtree;
	level._scr_anim[ "train_car_01" ][ "train_derailment" ] = %nx_pr_lava_train_derailment_train_car_01;
	level._scr_model[ "train_car_01" ] = "nx_pr_lava_end_derail_car";

	level._scr_animtree[ "train_car_02" ] = #animtree;
	level._scr_anim[ "train_car_02" ][ "train_derailment" ] = %nx_pr_lava_train_derailment_train_car_02;
	level._scr_model[ "train_car_02" ] = "nx_pr_lava_end_derail_car";

	level._scr_animtree[ "train_car_03" ] = #animtree;
	level._scr_anim[ "train_car_03" ][ "train_derailment" ] = %nx_pr_lava_train_derailment_train_car_03;
	level._scr_model[ "train_car_03" ] = "nx_pr_lava_end_derail_car";

	level._scr_animtree[ "train_car_04" ] = #animtree;
	level._scr_anim[ "train_car_04" ][ "train_derailment" ] = %nx_pr_lava_train_derailment_train_car_04;
	level._scr_model[ "train_car_04" ] = "nx_pr_lava_end_derail_car";

	level._scr_animtree[ "train_car_player" ] = #animtree;
	level._scr_anim[ "train_car_player" ][ "train_derailment" ] = %nx_pr_lava_train_derailment_train_car_player;
	level._scr_model[ "train_car_player" ] = "nx_pr_lava_end_derail_player_car";

	level._scr_animtree[ "train" ] = #animtree;
	level._scr_anim[ "train" ][ "train_derailment" ] = %nx_pr_lava_train_derailment_train;
	level._scr_model[ "train" ] = "nx_pr_train_derailment_train";

	level._scr_animtree[ "tires" ] = #animtree;
	level._scr_anim[ "tires" ][ "train_derailment" ] = %nx_pr_lava_train_derailment_tires_01;
	level._scr_model[ "tires" ] = "nx_pr_lava_train_derailment_tires";

	//level._scr_animtree[ "train_seperate" ] = #animtree;
	//level._scr_anim[ "train_seperate" ][ "train_seperate_player_jump" ] = %nx_pr_lava_trainseperate_train;
	//level._scr_model[ "train_seperate" ] = "nx_lava_train_infinite_vignette_finalcar";
	
	// tagBK<NOTE> Removed for tuesday tech presentation of moving platforms. 
	//level._scr_animtree[ "train_stationary_car02" ] = #animtree;
	//level._scr_anim[ "train_stationary_car02" ][ "train_seperate_player_jump" ] = %nx_vh_lava_trainseperate_player_jump_train;
	//level._scr_model[ "train_stationary_car02" ] = "nx_vehicle_moving_platform_short";
}

#using_animtree("vehicles");
vehicles()
{
	level._scr_anim[ "skimmer" ][ "keene_standoff" ] = %nx_vh_lava_control_breach_skimmer;

	level._scr_anim[ "rover_arrive" ][ "rover_arrive" ] = %nx_vh_lava_roverarrive_rover;

	level._scr_anim[ "train_axis_car01" ][ "train1_section_8car_train" ] = %nx_lava_train_cart_axis_01;

	level._scr_anim[ "train_axis_car02" ][ "train1_section_8car_train" ] = %nx_lava_train_cart_axis_02;

	level._scr_anim[ "train_axis_car03" ][ "train1_section_8car_train" ] = %nx_lava_train_cart_axis_03;

	level._scr_anim[ "train_axis_car04" ][ "train1_section_8car_train" ] = %nx_lava_train_cart_axis_04;

	level._scr_anim[ "train_axis_car05" ][ "train1_section_8car_train" ] = %nx_lava_train_cart_axis_05;

	level._scr_anim[ "train_axis_car06" ][ "train1_section_8car_train" ] = %nx_lava_train_cart_axis_06;

	level._scr_anim[ "train_axis_car07" ][ "train1_section_8car_train" ] = %nx_lava_train_cart_axis_07;

	level._scr_anim[ "train_axis_car08" ][ "train1_section_8car_train" ] = %nx_lava_train_cart_axis_08;

	level._scr_anim[ "train_allied_car01" ][ "train1_section_4car_train" ] = %nx_lava_train_cart_allied_01;
	level._scr_anim[ "train_allied_car02" ][ "train1_section_4car_train" ] = %nx_lava_train_cart_allied_02;

	level._scr_anim[ "train_allied_car03" ][ "train1_section_4car_train" ] = %nx_lava_train_cart_allied_03;

	level._scr_anim[ "train_allied_car04" ][ "train1_section_4car_train" ] = %nx_lava_train_cart_allied_04;

	// bridge to train
	level._scr_anim[ "skimmer_01" ][ "bridge_to_train_jump" ] = %nx_vh_lava_bridge_to_train_skimmer_01;
	level._scr_anim[ "skimmer_02" ][ "bridge_to_train_jump" ] = %nx_vh_lava_bridge_to_train_skimmer_02;

	//train separate fall
	level._scr_anim[ "train_stationary_car01" ][ "train_seperate_fall" ] = %nx_vh_lava_trainseperate_fall_train;

	// skimmer battle
	level._scr_anim[ "skimmer" ][ "skimmer_crash_tower" ] = %nx_vh_lava_skimmer_battle_02_skimmer;
	level._scr_anim[ "skimmer" ][ "skimmer_crash_rocks" ] = %nx_vh_lava_skimmer_battle_01_skimmer;

	// train derailment
	level._scr_anim[ "rover01" ][ "train_derailment" ] = %nx_vh_lava_train_derailment_rover_01;
	level._scr_anim[ "rover02" ][ "train_derailment" ] = %nx_vh_lava_train_derailment_rover_02;

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "generic_human" );
dead_crew()
{
	dead_crew_members = GetEntArray( "dead_crew", "targetname" );
	
	// Show and pose all the dead crew
	foreach( dead_crew_member in dead_crew_members )
	{
		dead_crew_member thread dead_crew_thread();
	}
}

dead_crew_thread()
{
	self show();
	self anim_generic( self, self.script_animation );
	self gun_remove();
	self vignette_actor_kill();	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

opening_walk_spawn()
{
	baker = vignette_actor_spawn("vignette_baker", "baker"); //"value" (kvp), "anim_name"
	franklin = vignette_actor_spawn("vignette_franklin", "franklin"); //"value" (kvp), "anim_name"
	tillman = vignette_actor_spawn("vignette_tillman", "tillman"); //"value" (kvp), "anim_name"
	player_legs = vignette_actor_spawn("vignette_player_legs", "player_legs"); //"value" (kvp), "anim_name"

	opening_walk(baker, franklin, tillman, player_legs);

	baker vignette_actor_delete();
	franklin vignette_actor_delete();
	tillman vignette_actor_delete();
	player_legs vignette_actor_delete();
}

opening_walk(baker, franklin, tillman, player_legs)
{
	// spawn models
	player_legs = vignette_actor_spawn("vignette_player_legs", "player_legs");
	player_rig = spawn_anim_model( "player_rig" );

	// ready player
	level._player disableweapons();
	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	// setup allies and player
	guys = [];
	guys["baker"] = level.baker;
	guys["franklin"] = level.franklin;
	guys["tillman"] = level.tilman;
	guys["player_legs"] = player_legs;
	guys["player_rig"] = player_rig;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, 15, 15, 15, 15, 1);

	// play animation
	node = getstruct("vignette_openingwalk", "script_noteworthy");
	node anim_single(guys, "opening_walk");

	// clean up player
	level._player unlink();
	level._player enableweapons();
	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

	// clean up models
	player_legs vignette_actor_delete();
	player_rig delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rover_arrive_spawn()
{
	rover_arrive = vignette_vehicle_spawn("vignette_rover_arrive", "rover_arrive"); //"value" (kvp), "anim_name"
	opfor3 = vignette_actor_spawn("vignette_roverarrive_opfor3", "opfor3"); //"value" (kvp), "anim_name"
	opfor2 = vignette_actor_spawn("vignette_roverarrive_opfor2", "opfor2"); //"value" (kvp), "anim_name"
	opfor1 = vignette_actor_spawn("vignette_roverarrive_opfor1", "opfor1"); //"value" (kvp), "anim_name"

	rover_arrive(rover_arrive, opfor3, opfor2, opfor1);

	rover_arrive vignette_vehicle_delete();
	opfor3 vignette_actor_delete();
	opfor2 vignette_actor_delete();
	opfor1 vignette_actor_delete();
}

rover_arrive(rover_arrive, opfor3, opfor2, opfor1)
{

	node = getstruct("vignette_roverarrive", "script_noteworthy");


	guys = [];
	guys["rover_arrive"] = rover_arrive;
	guys["opfor3"] = opfor3;
	guys["opfor2"] = opfor2;
	guys["opfor1"] = opfor1;

	node anim_single(guys, "rover_arrive");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

hold_motion_spawn()
{
	baker = vignette_actor_spawn("vignette_baker", "baker"); //"value" (kvp), "anim_name"

	hold_motion(baker);

	baker vignette_actor_delete();
}

hold_motion(baker)
{
	// hold position vignette at the surface cliff ledge

	// get to ledge
	node = getstruct("vignette_holdmotion", "script_noteworthy");
	node anim_reach_solo( level.baker, "hold_motion" );

	// play hold anim
	node anim_single_solo( level.baker, "hold_motion" );

	node = getNode( "outpost_sniper_baker", "targetname" );
	level.baker follow_path( node );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

hillslide_spawn()
{
	baker = vignette_actor_spawn("vignette_baker", "baker"); //"value" (kvp), "anim_name"
	tillman = vignette_actor_spawn("vignette_tillman", "tillman"); //"value" (kvp), "anim_name"
	franklin = vignette_actor_spawn("vignette_franklin", "franklin"); //"value" (kvp), "anim_name"

	hillslide(baker, tillman, franklin);

	baker vignette_actor_delete();
	tillman vignette_actor_delete();
	franklin vignette_actor_delete();
}

hillslide()
{
	node = getstruct("vignette_hillslide", "script_noteworthy");

	guys = [];
	guys["tillman"] = level.tilman;
	guys["franklin"] = level.franklin;

	// get to edge
	// node anim_reach( guys, "hillslide" );

	// play slide anim
	node anim_single( guys, "hillslide" );

	// TEMP TEMP - teleport
	tele_struct = getStruct( "temp_tele_sniper_tilman", "targetname" );
	level.tilman ForceTeleport( tele_struct.origin, tele_struct.angles );
	tele_struct = getStruct( "temp_tele_sniper_franklin", "targetname" );
	level.franklin ForceTeleport( tele_struct.origin, tele_struct.angles );

	// move tilman and franklin to location
	node = getNode( "outpost_sniper_tilman", "targetname" );
	level.tilman thread follow_path( node );

	node = getNode( "outpost_sniper_franklin", "targetname" );
	level.franklin thread follow_path( node );
}

hillslide_baker()
{
	node = getstruct("vignette_hillslide", "script_noteworthy");

	// get to edge
	wait( 0.5 ); // baker goes first
	node anim_reach_solo( level.baker, "hillslide" );

	// play slide anim
	node anim_single_solo( level.baker, "hillslide" );

	// TEMP TEMP - teleport
	wait( 0.1 );
	tele_struct = getStruct( "temp_tele_sniper_baker", "targetname" );
	level.baker ForceTeleport( tele_struct.origin, tele_struct.angles );

	// move tilman and franklin to location
	node = getNode( "outpost_sniper_tilman", "targetname" );
	level.tilman thread follow_path( node );
}

hillslide_tilman()
{
	node = getstruct("vignette_hillslide", "script_noteworthy");

	// get to edge
	wait( 0.5 ); // baker goes first
	// node anim_reach_solo( level.tilman, "hillslide" ); // TEMP TEMP - Node is in solid
	wait( 1 ); // TEMP TEMP - Wait added to simulate anim_reach

	// play slide anim
	node anim_single_solo( level.tilman, "hillslide" );

	// TEMP TEMP - teleport
	wait( 0.1 );
	tele_struct = getStruct( "temp_tele_sniper_tilman", "targetname" );
	level.tilman ForceTeleport( tele_struct.origin, tele_struct.angles );

	// move tilman and franklin to location
	node = getNode( "outpost_sniper_tilman", "targetname" );
	level.tilman thread follow_path( node );
}

hillslide_franklin()
{
	node = getstruct("vignette_hillslide", "script_noteworthy");

	// get to edge
	node anim_reach_solo( level.franklin, "hillslide" );

	// play slide anim
	node anim_single_solo( level.franklin, "hillslide" );

	// TEMP TEMP - teleport
	wait( 0.1 );
	tele_struct = getStruct( "temp_tele_sniper_franklin", "targetname" );
	level.franklin ForceTeleport( tele_struct.origin, tele_struct.angles );

	// move tilman and franklin to location
	node = getNode( "outpost_sniper_franklin", "targetname" );
	level.franklin thread follow_path( node );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ledgejump_spawn()
{
	baker = vignette_actor_spawn("vignette_baker", "baker"); //"value" (kvp), "anim_name"
	franklin = vignette_actor_spawn("vignette_franklin", "franklin"); //"value" (kvp), "anim_name"
	tillman = vignette_actor_spawn("vignette_tillman", "tillman"); //"value" (kvp), "anim_name"

	ledgejump(baker, franklin, tillman);

	baker vignette_actor_delete();
	franklin vignette_actor_delete();
	tillman vignette_actor_delete();
}

ledgejump()
{

	node = getstruct("vignette_ledgejump", "script_noteworthy");


	guys = [];
	guys["baker"] = level.baker;
	guys["franklin"] = level.franklin;
	guys["tillman"] = level.tilman;

	node anim_single(guys, "ledgejump");

	//temp teleport - till the jump works
	wait( .1 );
	tele_struct = getStruct( "temp_slide_teleport_baker", "targetname" ); // TEMP TEMP - Remove vignette - REMOVE
	level.baker ForceTeleport( tele_struct.origin, tele_struct.angles ); // TEMP TEMP - Remove vignette - REMOVE
	tele_struct = getStruct( "temp_slide_teleport_tilman", "targetname" ); // TEMP TEMP - Remove vignette - REMOVE
	level.tilman ForceTeleport( tele_struct.origin, tele_struct.angles ); // TEMP TEMP - Remove vignette - REMOVE
	tele_struct = getStruct( "temp_slide_teleport_franklin", "targetname" ); // TEMP TEMP - Remove vignette - REMOVE
	level.franklin ForceTeleport( tele_struct.origin, tele_struct.angles ); // TEMP TEMP - Remove vignette - REMOVE
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

air_resupply_spawn()
{
	baker = vignette_actor_spawn("vignette_baker", "baker"); //"value" (kvp), "anim_name"
	tillman = vignette_actor_spawn("vignette_tillman", "tillman"); //"value" (kvp), "anim_name"
	franklin = vignette_actor_spawn("vignette_franklin", "franklin"); //"value" (kvp), "anim_name"

	air_resupply_play(baker, tillman, franklin);

	baker vignette_actor_delete();
	tillman vignette_actor_delete();
	franklin vignette_actor_delete();
}

air_resupply_reach(baker, tillman, franklin)
{
	node = getstruct("vignette_air_resupply", "script_noteworthy");

	guys = [];
	guys["baker"] = level.baker;
	guys["tillman"] = level.tilman;
	guys["franklin"] = level.franklin;

	// get to O2 tank
	node anim_reach( guys, "air_resupply" );
}

air_resupply_play(baker, tillman, franklin)
{
	node = getstruct("vignette_air_resupply", "script_noteworthy");

	guys = [];
	guys["baker"] = level.baker;
	guys["tillman"] = level.tilman;
	guys["franklin"] = level.franklin;

	// play O2 refil anim
	node thread anim_single(guys, "air_resupply");

	// need notetracks for dialog
	level.baker radio_dialogue( "lava_kee_outpost_foundo2" );					// dialog: "I found an o2 tank. Get over here and fill up!"
	level.franklin radio_dialogue( "lava_fra_outpost_o2" ); 					// level.franklin radio_dialogue( "lava_fra_outpost_o2" );			// dialog: "O2!"
	level.franklin radio_dialogue( "lava_fra_outpost_thoughtdonefor" );			// level.franklin radio_dialogue( "lava_fra_outpost_thoughtdonefor" );		// dialog: "I thought we were done for."
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

air_resupply_baker_faint_spawn()
{
	baker = vignette_actor_spawn("vignette_baker", "baker"); //"value" (kvp), "anim_name"

	air_resupply_baker_faint();

	baker vignette_actor_delete();
}

air_resupply_baker_faint()
{
	node = getstruct("vignette_air_resupply_keene_faint", "script_noteworthy");

	// spawn models
	player_rig = spawn_anim_model( "player_rig" );
	
	// ready player
	level._player disableweapons();
	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	guys = [];
	guys["baker"] = level.baker;
	guys["player_rig"] = player_rig;

	arc = 15;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "air_resupply_baker_faint");

	// need notetracks for dialog
	// level.franklin radio_dialogue( "lava_fra_outpost_commander" );				// dialog: "Comander?!"
	// level.baker radio_dialogue( "lava_kee_outpost_muchbetter" );				// dialog: "That's much better."

	// clean up player
	level._player unlink();
	level._player enableweapons();
	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

	// clean up models
	player_rig delete();

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

weldingarms_skimmer1_spawn()
{

	weldingarms_skimmer1();

}

weldingarms_skimmer1()
{

	node = getstruct("vignette_weldingarms1", "script_noteworthy");

	weldingarm1 = spawn_anim_model("weldingarm1");

	weldingarm2 = spawn_anim_model("weldingarm2");
	
	playfxontag  ( level._effect[ "welding_arm_spark01" ], weldingarm1, "tag_fx_sparks" );
	playfxontag  ( level._effect[ "welding_arm_spark01" ], weldingarm2, "tag_fx_sparks" );

	guys = [];
	guys["weldingarm1"] = weldingarm1;
	guys["weldingarm2"] = weldingarm2;

	node anim_single(guys, "weldingarms_skimmer1");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


rover_maintance_spawn()
{
	// spawn mechanics
	opfor1 = spawn_targetname( "op_garage_mech_bad_spawner_1" ); //"value" (kvp), "anim_name"
	opfor1.animname = "opfor1";
	opfor1 set_ignoreall( true );
	opfor2 = spawn_targetname( "op_garage_mech_bad_spawner_2" ); //"value" (kvp), "anim_name"
	opfor2.animname = "opfor2";
	opfor2 set_ignoreall( true );
	opfor3 = spawn_targetname( "op_garage_mech_bad_spawner_3" ); //"value" (kvp), "anim_name"
	opfor3.animname = "opfor3";
	opfor3 set_ignoreall( true );


	// play vignette
	rover_maintance(opfor1, opfor2, opfor3);


	// run away
	node = getNode( "op_mech_run2", "targetname" );
	opfor2 thread follow_path( node );
	opfor2 notify( "fleeing" );
	wait( 0.2 );
	node = getNode( "op_mech_run3", "targetname" );
	opfor3 thread follow_path( node );
	opfor3 notify( "fleeing" );
	wait( 0.7 );
	node = getNode( "op_mech_run1", "targetname" );
	opfor1 thread follow_path( node );
	opfor1 notify( "fleeing" );

	// delete dudes when they're out of sight
	flag_wait( "op_sub_vehicle_sneak" );
	if( isdefined( opfor1 ) )
		opfor1 kill();
	if( isdefined( opfor2 ) )
		opfor2 kill();
	if( isdefined( opfor3 ) )
		opfor3 kill();
}

rover_maintance(opfor1, opfor2, opfor3)
{

	node = getstruct("vignette_rover_maintance", "script_noteworthy");


	guys = [];
	guys["opfor1"] = opfor1;
	guys["opfor2"] = opfor2;
	guys["opfor3"] = opfor3;

	node anim_single(guys, "rover_maintance");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

underground_reveal_spawn()
{

	underground_reveal();

}

underground_reveal()
{

	node = getstruct("vignette_underground_reveal", "script_noteworthy");

	crane = spawn_anim_model("crane");

	luner_lift_1 = spawn_anim_model("luner_lift_1");

	lunar_lift_2 = spawn_anim_model("lunar_lift_2");


	guys = [];
	guys["crane"] = crane;
	guys["luner_lift_1"] = luner_lift_1;
	guys["lunar_lift_2"] = lunar_lift_2;

	node anim_single(guys, "underground_reveal");
	
	foreach( guy in guys )
		guy delete(); // TEMP CLEANUP

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

scaffold_jump_spawn()
{
	baker = vignette_actor_spawn("vignette_baker", "baker"); //"value" (kvp), "anim_name"
	tillman = vignette_actor_spawn("vignette_tillman", "tillman"); //"value" (kvp), "anim_name"
	franklin = vignette_actor_spawn("vignette_franklin", "franklin"); //"value" (kvp), "anim_name"

	scaffold_jump_baker();
	scaffold_jump_tilman();
	scaffold_jump_franklin();

	baker vignette_actor_delete();
	tillman vignette_actor_delete();
	franklin vignette_actor_delete();
}

scaffold_jump_baker()
{

	node = getstruct("vignette_scaffold_jump", "script_noteworthy");
	node anim_reach_solo(level.baker, "scaffold_jump");

	level.baker thread radio_dialogue( "lava_kee_station1_tangosbelow" );					// dialog: "Tangos below... jump across!"
	node anim_single_solo(level.baker, "scaffold_jump");
	
	if( !flag( "s1p_player_jump_5th" ) )
	{
		level.baker disable_ai_color();
		node = getNode( "s1p_jump_baker", "targetname" );
		level.baker thread follow_path( node );
	}
}

scaffold_jump_tilman()
{

	node = getstruct("vignette_scaffold_jump", "script_noteworthy");
	node anim_reach_solo(level.tilman, "scaffold_jump");

	node anim_single_solo(level.tilman, "scaffold_jump");

	level.tilman disable_ai_color();
	node = getNode( "s1p_jump_tilman", "targetname" );
	level.tilman thread follow_path( node );
}

scaffold_jump_franklin()
{

	node = getstruct("vignette_scaffold_jump", "script_noteworthy");
	node anim_reach_solo(level.franklin, "scaffold_jump");
	
	node anim_single_solo(level.franklin, "scaffold_jump");

	level.franklin disable_ai_color();
	node = getNode( "s1p_jump_franklin", "targetname" );
	level.franklin thread follow_path( node );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

flank_area_jump_spawn()
{
	vignette_tilman = vignette_actor_spawn("vignette_tilman", "vignette_tilman"); //"value" (kvp), "anim_name"

	flank_area_jump();

	vignette_tilman vignette_actor_delete();
}

flank_area_jump()
{

	node = getstruct("vignette_flankareajump", "script_noteworthy");
	
	node anim_reach_solo(level.tilman, "flank_area_jump");

	node anim_single_solo(level.tilman, "flank_area_jump");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

crane_movement2_spawn()
{

	crane_movement2();

}

crane_movement2()
{

	node = getstruct("vignette_crane2", "script_noteworthy");

	crane = spawn_anim_model("crane");

	crate = spawn_anim_model("crate");

	lift1 = spawn_anim_model("lift1");

	lift2 = spawn_anim_model("lift2");


	guys = [];
	guys["crane"] = crane;
	guys["crate"] = crate;
	guys["lift1"] = lift1;
	guys["lift2"] = lift2;

	node anim_single(guys, "crane_movement2");

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


maproom_point_spawn()
{
	baker = vignette_actor_spawn("vignette_baker", "baker"); //"value" (kvp), "anim_name"

	maproom_point(baker);

	baker vignette_actor_delete();
}

maproom_point(baker)
{

	node = getstruct("vignette_maproom_point", "script_noteworthy");


	guys = [];
	guys["baker"] = level.baker;

	node anim_single(guys, "maproom_point");

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

data_retrieval_spawn()
{

	data_retrieval();

}

data_retrieval()
{

	node = getstruct("vignette_data_retrieval", "script_noteworthy");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["player_rig"] = player_rig;

	arc = 15;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "data_retrieval");

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



camren_sacrifice_player_spawn()

{
	baker = vignette_actor_spawn("vignette_keene", "baker"); //"value" (kvp), "anim_name"

	camren_sacrifice_player(baker);

	baker vignette_actor_delete();
}



camren_sacrifice_player()

{
	node = getstruct("vignette_camren_sacrifice", "script_noteworthy");

	// spawn models
	player_rig = spawn_anim_model( "player_rig" );
	
	// ready player
	level._player disableweapons();
	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	guys = [];
	guys["baker"] = level.baker;
	guys["player_rig"] = player_rig;
	
	// link player
	arc = 15;
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	// start vignette
	node anim_single(guys, "camren_sacrifice_player");

	// clean up player
	level._player unlink();
	level._player enableweapons();
	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	player_rig delete();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

camren_sacrific_idle_spawn()
{
	camren = vignette_actor_spawn("vignette_franklin", "camren"); //"value" (kvp), "anim_name"

	camren_sacrific_idle(camren);

	camren vignette_actor_delete();
}

camren_sacrific_idle()
{
	node = getstruct("vignette_camren_sacrifice_camrenidle", "script_noteworthy");

	guys = [];
	guys["camren"] = level.tilman;
	
	// go to console
	// node anim_reach( guys, "camren_sacrific_idle" );
	
	// use console - loop
	while( !flag( "s1_command_train_begin" ) )
	{
		node anim_single(guys, "camren_sacrific_idle");
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

button_push_spawn()
{
	keene = vignette_actor_spawn("vignette_keene", "keene"); //"value" (kvp), "anim_name"

	button_push(keene);

	keene vignette_actor_delete();
}

button_push( keene )
{
	node = getstruct("vignette_keene_button_push", "script_noteworthy");

	// Reach
	node anim_reach_solo( keene, "button_push" );

	// Anim
	node anim_single_solo( keene, "button_push" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train1_section_8car_train_spawn()
{
	train_axis_car01 = vignette_vehicle_spawn("train_axis_car01", "train_axis_car01"); //"value" (kvp), "anim_name"
	train_axis_car02 = vignette_vehicle_spawn("train_axis_car02", "train_axis_car02"); //"value" (kvp), "anim_name"
	train_axis_car03 = vignette_vehicle_spawn("train_axis_car03", "train_axis_car03"); //"value" (kvp), "anim_name"
	train_axis_car04 = vignette_vehicle_spawn("train_axis_car04", "train_axis_car04"); //"value" (kvp), "anim_name"
	train_axis_car05 = vignette_vehicle_spawn("train_axis_car05", "train_axis_car05"); //"value" (kvp), "anim_name"
	train_axis_car06 = vignette_vehicle_spawn("train_axis_car06", "train_axis_car06"); //"value" (kvp), "anim_name"
	train_axis_car07 = vignette_vehicle_spawn("train_axis_car07", "train_axis_car07"); //"value" (kvp), "anim_name"
	train_axis_car08 = vignette_vehicle_spawn("train_axis_car08", "train_axis_car08"); //"value" (kvp), "anim_name"

	train_name_array = [ 	[ "train_2_car_0", train_axis_car01 ], 
							[ "train_2_car_1", train_axis_car02 ], 
							[ "train_2_car_2", train_axis_car03 ],
							[ "train_2_car_3", train_axis_car04 ],
							[ "train_2_car_4", train_axis_car05 ],
							[ "train_2_car_5", train_axis_car06 ],
							[ "train_2_car_6", train_axis_car07 ],
							[ "train_2_car_7", train_axis_car08 ] ];

	level.train_2 = maps\nx_lava_util::setup_animated_train( train_name_array, 2 );
	train1_section_8car_train(train_axis_car01, train_axis_car02, train_axis_car03, train_axis_car04, train_axis_car05, train_axis_car06, train_axis_car07, train_axis_car08);

	train_axis_car01 vignette_vehicle_delete();
	train_axis_car02 vignette_vehicle_delete();
	train_axis_car03 vignette_vehicle_delete();
	train_axis_car04 vignette_vehicle_delete();
	train_axis_car05 vignette_vehicle_delete();
	train_axis_car06 vignette_vehicle_delete();
	train_axis_car07 vignette_vehicle_delete();
	train_axis_car08 vignette_vehicle_delete();
}

train1_section_8car_train(train_axis_car01, train_axis_car02, train_axis_car03, train_axis_car04, train_axis_car05, train_axis_car06, train_axis_car07, train_axis_car08)
{

	node = getstruct("vignette_train1_both_trains_motion", "script_noteworthy");

	guys = [];
	guys["train_axis_car01"] = train_axis_car01;
	guys["train_axis_car02"] = train_axis_car02;
	guys["train_axis_car03"] = train_axis_car03;
	guys["train_axis_car04"] = train_axis_car04;
	guys["train_axis_car05"] = train_axis_car05;
	guys["train_axis_car06"] = train_axis_car06;
	guys["train_axis_car07"] = train_axis_car07;
	guys["train_axis_car08"] = train_axis_car08;

	node anim_single(guys, "train1_section_8car_train");

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train1_section_4car_train_spawn()
{
	train_allied_car01 = vignette_vehicle_spawn("train_allied_car01", "train_allied_car01"); //"value" (kvp), "anim_name"
	train_allied_car02 = vignette_vehicle_spawn("train_allied_car02", "train_allied_car02"); //"value" (kvp), "anim_name"
	train_allied_car03 = vignette_vehicle_spawn("train_allied_car03", "train_allied_car03"); //"value" (kvp), "anim_name"
	train_allied_car04 = vignette_vehicle_spawn("train_allied_car04", "train_allied_car04"); //"value" (kvp), "anim_name"

	train_name_array = [ 	[ "train_1_car_1", train_allied_car01 ], 
							[ "train_1_car_2", train_allied_car02 ], 
							[ "train_1_car_3", train_allied_car03 ],
							[ "train_1_car_4", train_allied_car04 ] ];

	level.train_1 = maps\nx_lava_util::setup_animated_train( train_name_array, 1 );

	train1_section_4car_train(train_allied_car01, train_allied_car02, train_allied_car03, train_allied_car04);

	train_allied_car01 vignette_vehicle_delete();
	train_allied_car02 vignette_vehicle_delete();
	train_allied_car03 vignette_vehicle_delete();
	train_allied_car04 vignette_vehicle_delete();
}

train1_section_4car_train(train_allied_car01, train_allied_car02, train_allied_car03, train_allied_car04)
{

	node = getstruct("vignette_train1_both_trains_motion", "script_noteworthy");


	guys = [];
	guys["train_allied_car01"] = train_allied_car01;
	guys["train_allied_car02"] = train_allied_car02;
	guys["train_allied_car03"] = train_allied_car03;
	guys["train_allied_car04"] = train_allied_car04;

	node anim_single(guys, "train1_section_4car_train");

}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

control_room_breach_spawn()
{
	opfor_01 = vignette_actor_spawn("opfor01_control_room_breach", "opfor_01"); //"value" (kvp), "anim_name"
	opfor_02 = vignette_actor_spawn("opfor02_control_room_breach", "opfor_02"); //"value" (kvp), "anim_name"

	control_room_breach(level.keene, level.franklin, level.tilman, opfor_01, opfor_02);

	// clean up and kill franklin
	level.franklin stop_magic_bullet_shield();
	level.franklin kill();
	opfor_01 vignette_actor_delete();
	opfor_02 vignette_actor_delete();
}

control_room_breach(keene, red_shirt, tillman, opfor_01, opfor_02)
{

	node = getstruct("vignette_control_room_breach", "script_noteworthy");

	// ready player
	level._player disableweapons();
	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	
	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["keene"] = keene;
	guys["red_shirt"] = red_shirt;
	guys["tillman"] = tillman;
	guys["opfor_01"] = opfor_01;
	guys["opfor_02"] = opfor_02;
	guys["player_rig"] = player_rig;

	// link player
	arc = 0;
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	// play vignette
	node anim_single(guys, "control_room_breach");

	// clean up player
	level._player unlink();
	level._player enableweapons();
	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

keene_standoff_spawn()
{
	keene = vignette_actor_spawn("keene_control_room_breach", "keene"); //"value" (kvp), "anim_name"
	baker = vignette_actor_spawn("tillman_control_room_breach", "baker"); //"value" (kvp), "anim_name"
	redshirt = vignette_actor_spawn("redshirt_control_room_breach", "redshirt"); //"value" (kvp), "anim_name"
	skimmer = vignette_vehicle_spawn("keene_standoff_skimmer", "skimmer"); //"value" (kvp), "anim_name"

	keene_standoff(keene, baker, redshirt, skimmer);

	keene vignette_actor_delete();
	baker vignette_actor_delete();
	redshirt vignette_actor_delete();
	skimmer vignette_vehicle_delete();
}

keene_standoff(keene, baker, redshirt, skimmer)
{

	node = getstruct("vignette_keene_standoff", "script_noteworthy");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player disableweapons();
	
	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["keene"] = keene;
	guys["baker"] = baker;
	guys["redshirt"] = redshirt;
	guys["player_rig"] = player_rig;
	guys["skimmer"] = skimmer;

	arc = 0;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "keene_standoff");

	level._player unlink();

	player_rig delete();

	// Kill redshirt
	redshirt vignette_actor_kill();
	
	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player EnableWeapons();
	
	flag_set( "vignette_keene_standoff_done" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

bridge_to_train_jump_spawn()
{
	keane = vignette_actor_spawn("bridge_to_train_keane", "keane"); //"value" (kvp), "anim_name"
	tilman = vignette_actor_spawn("bridge_to_train_tilman", "tilman"); //"value" (kvp), "anim_name"
	skimmer_01 = vignette_vehicle_spawn("bridge_to_train_skimmer_01", "skimmer_01"); //"value" (kvp), "anim_name"
	skimmer_02 = vignette_vehicle_spawn("bridge_to_train_skimmer_02", "skimmer_02"); //"value" (kvp), "anim_name"

	bridge_to_train_jump(keane, tilman, skimmer_01, skimmer_02);

	keane vignette_actor_delete();
	tilman vignette_actor_delete();
	skimmer_01 vignette_vehicle_delete();
	skimmer_02 vignette_vehicle_delete();
}

bridge_to_train_jump( keene, baker, skimmer_01, skimmer_02)
{
	level thread bridge_to_train_jump_player();

	node = getstruct("vignette_bridge_to_train_jump", "script_noteworthy");

	bridge = spawn_anim_model("bridge");

	debris = spawn_anim_model("debris");

	pipe = spawn_anim_model("pipe");

	train_bridge = spawn_anim_model("train_bridge");

	guys = [];
	guys["keene"] = keene;
	guys["baker"] = baker;
	guys["bridge"] = bridge;
	guys["debris"] = debris;
	guys["pipe"] = pipe;
	guys["train_bridge"] = train_bridge;
	guys["skimmer_01"] = skimmer_01;
	guys["skimmer_02"] = skimmer_02;

	node anim_single(guys, "bridge_to_train_jump");
	
	train_bridge delete();
	pipe delete();
	debris delete();
	skimmer_01 delete();
	skimmer_02 delete();

	// Set vignette done flag
	flag_set( "vignette_bridge_to_train_done" );
}

bridge_to_train_jump_player()
{
	node = getstruct("vignette_bridge_to_train_jump_player", "script_noteworthy");

	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player disableweapons();

	player_rig = spawn_anim_model( "player_rig" );
	
	arc = 15;
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single_solo( player_rig, "bridge_to_train_jump" );

	level._player unlink();

	player_rig delete();

	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player enableweapons();	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train2_keenereveal_spawn()
{
	keene = vignette_actor_spawn("vignette_keene", "keene"); //"value" (kvp), "anim_name"
	opfor = vignette_actor_spawn("vignette_keenereveal_opfor", "opfor"); //"value" (kvp), "anim_name"

	train2_keenereveal(keene, opfor);

	keene vignette_actor_delete();
	opfor vignette_actor_delete();
}

train2_keenereveal(keene, opfor)
{

	node = getstruct("vignette_train_keenereveal", "script_noteworthy");


	guys = [];
	guys["keene"] = keene;
	guys["opfor"] = opfor;

	node anim_single(guys, "train2_keenereveal");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_board_spawn()
{
	opfor1 = vignette_actor_spawn("vignette_trainboard_opfor1", "opfor1"); //"value" (kvp), "anim_name"
	opfor2 = vignette_actor_spawn("vignette_trainboard_opfor2", "opfor2"); //"value" (kvp), "anim_name"

	level thread train_board(opfor1, opfor2);
	
	wait( 4.0 );
	
	opfor1 StopAnimScripted();
	opfor2 StopAnimScripted();
	
	opfor1 vignette_actor_delete();
	opfor2 vignette_actor_delete();
}

train_board(opfor1, opfor2)
{
	node = getstruct("vignette_opfor_trainboard", "script_noteworthy");

	guys = [];
	guys["opfor1"] = opfor1;
	guys["opfor2"] = opfor2;

	node anim_single(guys, "train_board");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train2_tillmanreveal_spawn()
{
	//tillman = vignette_actor_spawn("vignette_tillman", "tillman"); //"value" (kvp), "anim_name"
	//opfor = vignette_actor_spawn("vignette_tillman_reveal_opfor", "opfor"); //"value" (kvp), "anim_name"
	opfor = vignette_actor_spawn("vignette_keenereveal_opfor", "opfor");
	//iprintln( "Spawned" );
	//train2_tillmanreveal(tillman, opfor);
	train2_tillmanreveal( opfor );

	//tillman vignette_actor_delete();
	opfor vignette_actor_delete();
}

train2_tillmanreveal( opfor )
{
	//iprintln( "PLAYING VIGNETTE");
	node = getstruct("vignette_tillman_reveal", "script_noteworthy");

	level._player disableweapons();
	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	//guys["tillman"] = tillman;
	guys["opfor"] = opfor;
	guys["player_rig"] = player_rig;

	arc = 15;
	level._player PlayerLinkToBlend( player_rig, "tag_player", .25, .1, .1, true );
	//level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);
	level._player playsound("scn_lava_tillman_reveal");
	node anim_single(guys, "train2_tillmanreveal");

	flag_set( "train_interior_car_3_player_vignette_done" );
	
	//iprintln( "Ending VIGNETTE");
	//wait( 14.0 );
	
	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player enableweapons();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_seperate_fall_spawn()
{
	keene = vignette_actor_spawn("vignette_keene", "keene"); //"value" (kvp), "anim_name"

	train_seperate_fall(keene);

	keene vignette_actor_delete();
}

train_seperate_fall( baker, vehicle )
{
	level endon( "vignette_trainseperate_player_jump" );
	
	baker.animname = "baker";
	node = getstruct("vignette_train_seperate_fall", "script_noteworthy");

	train_stationary_car01 = vehicle;
	train_stationary_car01.animname = "train_stationary_car01";

	guys = [];
	guys["baker"] = baker;
	guys["train_stationary_car01"] = train_stationary_car01;

	thread train_seperate_fall_player();

	train_stationary_car01 suspend_drive_anims();
	node anim_single( guys, "train_seperate_fall" );	
	
	///set baker looping
	node thread anim_loop_solo ( baker, "train_seperate_fall_idle", "stop_idle");	
}

train_seperate_first_frame( vehicle )
{
	node = getstruct("vignette_train_seperate_fall", "script_noteworthy");
	
	train_stationary_car01 = vehicle;
	train_stationary_car01.animname = "train_stationary_car01";

	guys = [];
	guys["train_stationary_car01"] = train_stationary_car01;

	node anim_first_frame( guys, "train_seperate_fall" );
}

train_seperate_fall_player( )
{
	node = getstruct("vignette_train_seperate_fall", "script_noteworthy");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player DisableWeapons();
	level._player HideViewModel();

	player_rig = spawn_anim_model( "player_rig" );
	node anim_first_frame_solo( player_rig, "train_seperate_fall" );

	//Get the player's current weapon and attach it to the vignette
	weapon = level._player GetCurrentWeapon();
	weapon_model = level._player GetPlayerWeaponModel();
	weapon_viewmodel = GetWeaponViewModel( weapon );
			
	player_rig Attach( weapon_viewmodel, "tag_weapon" );
	hide_tag_list = GetWeaponHideTags( weapon );
	if ( isDefined( hide_tag_list ) )
	{                              
		foreach ( part in hide_tag_list )
			player_rig HidePart_AllInstances( part, weapon_viewmodel );
	}

	arc = 15;
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single_solo( player_rig, "train_seperate_fall" );	

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player EnableWeapons();
	level._player ShowViewModel();
	
	flag_set( "train_seperate_fall_player_done" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_seperate_player_jump_spawn()
{

	train_seperate_player_jump();

}

train_seperate_player_jump( baker )
{
	flag_set( "vignette_trainseperate_player_jump" );
	node = getstruct("vignette_trainseperate_player_jump", "script_noteworthy");

	//train_seperate = spawn_anim_model("train_seperate");
	train_stationary_car02 = GetEnt( "train_interior_vignette_destroy_car_vehicle", "targetname" );
	train_stationary_car02.animname = "train_stationary_car02";
	train_stationary_car02 assign_animtree();
	
	level._player DisableWeapons();
	
	//wait for the player to hit the blend trigger to start blending to the landing spot
	trigger_blend = GetEnt ("vignette_trainseperate_player_blend", "targetname");
	trigger_blend wait_for_notify_or_timeout ("trigger", 1);
	// Create, hide, and set the player rig to first frame for a blend destination
	player_rig = spawn_anim_model( "player_rig" );
	player_rig hide();

	node anim_first_frame_solo( player_rig, "train_seperate_player_jump" );
	level._player PlayerLinkToBlend( player_rig, "tag_player", .55, .1, .1, true );
	
	baker.animname = "baker";	

	guys = [];
	//guys["train_seperate"] = train_seperate;
	guys["train_stationary_car02"] = train_stationary_car02;
	guys["player_rig"] = player_rig;
	//guys["baker"] = baker;

	//train_stationary_car02 suspend_drive_anims();
	// Since the player may be falling at varied rates, wait until they "collide" with the elevator (trigger) or the blend has finished.
	trigger_land = GetEnt ("vignette_trainseperate_player_land", "targetname");
	trigger_land wait_for_notify_or_timeout ("trigger", .25);

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	player_rig show();
/*
	//Get the player's current weapon and attach it to the vignette
	weapon = level._player GetCurrentWeapon();
	weapon_model = level._player GetPlayerWeaponModel();
	weapon_viewmodel = GetWeaponViewModel( weapon );
			
	player_rig Attach( weapon_viewmodel, "tag_weapon" );
	hide_tag_list = GetWeaponHideTags( weapon );
	if ( isDefined( hide_tag_list ) )
	{                              
		foreach ( part in hide_tag_list )
			player_rig HidePart_AllInstances( part, weapon_viewmodel );
	}
*/
	arc = 15;
	level._player PlayerLinkToDelta( player_rig, "tag_player", 0, arc, arc, arc, arc, 1);
	//level._player PlayerLinkToBlend( player_rig, "tag_player", .05, .1, .1, true );
	// tagTC<temp> remove the old train for now
	
	destroy_car_array = GetEntArray( "train_interior_vignette_destroy_car", "targetname" );
	foreach( part in destroy_car_array )
	{
		part LinkTo( train_stationary_car02, "tag_origin" );
	}
		
	//stop baker's idle
	old_node = getstruct("vignette_train_seperate_fall", "script_noteworthy");
	old_node notify ("stop_idle");		
	
	//play the anims
	node thread anim_Single_solo( baker, "train_seperate_player_jump");
	node anim_single(guys, "train_seperate_player_jump");
	issue_color_orders( "r10", "allies" );
	
	flag_set( "vignette_trainseperate_player_jump_done" );
	
	level._player unlink();

	player_rig delete();

	destroy_car_array = GetEntArray( "train_interior_vignette_destroy_car", "targetname" );
	foreach( part in destroy_car_array )
	{
		part delete();
	}
	train_stationary_car02 delete();
	
	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player EnableWeapons();

}

train_seperate_quake( guy )
{
	level._player PlayRumbleOnEntity( "damage_light" );
	Earthquake( 0.5, 3, level._player.origin, 850 );
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_seperate_spawn()
{
	keene = vignette_actor_spawn("vignette_keene", "keene"); //"value" (kvp), "anim_name"

	train_seperate(keene);

	keene vignette_actor_delete();
}

train_seperate(keene)
{
	node = getstruct("vignette_train_seperate", "script_noteworthy");

	train_seperate = spawn_anim_model("train_seperate");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["player_rig"] = player_rig;
	guys["train_seperate"] = train_seperate;
	guys["keene"] = keene;

	arc = 15;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);
	node anim_single( guys, "train_seperate" );


	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

}


//*******************************************************************
//      ***NEW TURRET BATTLE***                                     *
//                                                                  *
//*******************************************************************

//vignette_register( ::train3_car4_rear_spawn, "trigger_flag_name" );

train3_car4_rear_spawn()
{

	train3_car4_rear();

}

train3_car4_rear( flag )
{
	node = GetEnt("car_4_rear", "targetname");

	train3_car4_rear = spawn_anim_model("train3_car4_rear");


	guys = [];
	guys["train3_car4_rear"] = train3_car4_rear;

	node anim_first_frame(guys, "train3_car4_rear");
	train3_car4_rear LinkTo( node );	
	
	flag_wait( flag );
	
	level thread maps\nx_lava_util::blowup_ai_group( "train_3_car_5_enemy_rear" );
	//PlayFXOnTag( getfx( "train_3_part_explosion_01" ), train3_car4_rear, "TAG_FX_CAR4_CRATE_020" );
	//PlayFXOnTag( getfx( "train_3_part_explosion_01" ), train3_car4_rear, "TAG_FX_CAR4_CRATE_19" );
	//PlayFXOnTag( getfx( "train_3_part_explosion_01" ), train3_car4_rear, "TAG_FX_CAR4_CRATE_04" );
	PlayFXOnTag( getfx( "train_3_part_explosion_large_01" ), train3_car4_rear, "TAG_FX_CAR4_PLATFORM_03" );
	wait ( 0.1 );
	PlayFXOnTag( getfx( "train_platform_fire" ), train3_car4_rear, "TAG_FX_CAR4_PLATFORM_03" );


	node playsound("lava_train_explo_crate");
	
	node anim_single(guys, "train3_car4_rear");

	//train3_car4_rear delete();
}


//vignette_register( ::train3_car4_mid_spawn, "trigger_flag_name" );




train3_car4_mid_spawn()

{



	train3_car4_mid();



}



train3_car4_mid( flag )

{
	node = GetEnt("car_4_middle", "targetname");

	train3_car4_mid = spawn_anim_model("train3_car4_mid");


	guys = [];
	guys["train3_car4_mid"] = train3_car4_mid;

	node anim_first_frame(guys, "train3_car4_mid");
	train3_car4_mid LinkTo( node );	

	flag_wait( flag );

	level thread maps\nx_lava_util::blowup_ai_group( "train_3_car_5_enemy_middle" );

	PlayFXOnTag( getfx( "train_3_part_explosion_02" ), train3_car4_mid, "TAG_FX_CAR4_PLATFORM_02" );
	wait ( 0.1 );
	PlayFXOnTag( getfx( "train_platform_fire" ), train3_car4_mid, "TAG_FX_CAR4_PLATFORM_02" );

	node playsound("lava_train_explo_tire");

	node anim_single(guys, "train3_car4_mid");

	//train3_car4_mid delete();
}



//vignette_register( ::train3_car4_front_spawn, "trigger_flag_name" );





train3_car4_front_spawn()


{





	train3_car4_front();





}





train3_car4_front( flag )


{
	node = GetEnt("car_4_front", "targetname");

	train3_car4_front = spawn_anim_model("train3_car4_front");


	guys = [];
	guys["train3_car4_front"] = train3_car4_front;

	node anim_first_frame(guys, "train3_car4_front");
	train3_car4_front LinkTo( node );	

	flag_wait( flag );

	level thread maps\nx_lava_util::blowup_ai_group( "train_3_car_5_enemy_front" );

	PlayFXOnTag( getfx( "train_3_part_explosion_01" ), train3_car4_front, "TAG_FX_CAR4_TANK_02" );
	PlayFXOnTag( getfx( "train_3_part_explosion_01" ), train3_car4_front, "TAG_FX_CAR4_TANK_03" );

	node playsound("lava_train_explo_tanker");

	node anim_single(guys, "train3_car4_front");

	//train3_car4_front delete();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//vignette_register( ::train3_car3_rear_spawn, "trigger_flag_name" );


train3_car3_rear_spawn()
{

	train3_car3_rear();

}

train3_car3_rear()
{

	node = getstruct("vignette_turret_battle_train3_car3", "script_noteworthy");

	train3_car3_rear = spawn_anim_model("train3_car3_rear");


	guys = [];
	guys["train3_car3_rear"] = train3_car3_rear;

	node anim_single(guys, "train3_car3_rear");

}


//vignette_register( ::train3_car3_front_spawn, "vignette_roverarrive" );


// copy and paste these functions into <level>_anim.gsc
train3_car3_front_spawn()
{

	train3_car3_front();

}

train3_car3_front()
{

	node = getstruct("vignette_turret_battle_train3_car3", "script_noteworthy");

	train3_car3_front = spawn_anim_model("train3_car3_front");



	guys = [];
	guys["train3_car3_front"] = train3_car3_front;

	node anim_single(guys, "train3_car3_front");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//vignette_register( ::train3_car1_spawn, "trigger_flag_name" );


// copy and paste these functions into <level>_anim.gsc
train3_car1_spawn()
{

	train3_car1_derail();

}

train3_car1_derail( flag, flag_done)
{

	node = GetEnt( "vignette_turret_car1_platform", "targetname" );

	// spawn models
	train3_car1_platform = spawn_anim_model("train3_car1_platform");
	train3_car1_cargo_front = spawn_anim_model("train3_car1_cargo_front");
	train3_car1_cargo_rear = spawn_anim_model("train3_car1_cargo_rear");

	// save script model for linking later
	level.train_3[0].vignette_script_model = train3_car1_platform;

	// create anim array
	guys = [];
	guys["train3_car1_platform"] = train3_car1_platform;
	guys["train3_car1_cargo_front"] = train3_car1_cargo_front;
	guys["train3_car1_cargo_rear"] = train3_car1_cargo_rear;

	// snap/link
	node anim_first_frame(guys, "train3_car1_derail");
	foreach( guy in guys )
		guy LinkTo( node );
	
	// hide vehicle
	level.train_3[0].vehicle hide();
	
	// wait/animate
	flag_wait( flag );
	
	//PlayFXOnTag( getfx( "turret_explosion" ), train3_car1_platform, "tag_origin" );
	node anim_single(guys, "train3_car1_derail");

	// finsih and clean up
	flag_set( flag_done );
	
	foreach( guy in guys )
		guy delete();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

turret_battle_tanker_explosion_spawn()
{
	turret_battle_tanker_explosion();
}

turret_battle_tanker_explosion( flag )
{
	node = GetEnt( "vignette_turret_battle_tanker_explosion", "targetname" );

	tankers = spawn_anim_model("tankers");

	guys = [];
	guys["tankers"] = tankers;

	node anim_first_frame(guys, "turret_battle_tanker_explosion");
	tankers LinkTo( node );	
	
	flag_wait( flag );

	node playsound("lava_train_explo_tanker");
	
	PlayFXOnTag( getfx( "train_3_part_explosion_large_01" ), tankers, "TAG_FX_CAR3_PLATFORM_02" );
	wait (0.1);
	PlayFXOnTag( getfx( "train_3_part_explosion_01" ), tankers, "TAG_FX_CAR3_TANK_04" );
	//PlayFXOnTag( getfx( "train_3_part_explosion_01" ), tankers, "TAG_FX_CAR3_TANK_05" );
	PlayFXOnTag( getfx( "train_3_part_explosion_01" ), tankers, "TAG_FX_CAR3_TANK_06" );
	//PlayFXOnTag( getfx( "train_3_part_explosion_01" ), tankers, "TAG_FX_CAR3_TANK_07" );
	//PlayFXOnTag( getfx( "turret_explosion" ), tankers, "tag_origin" );
		wait (0.1);
	PlayFXOnTag( getfx( "train_platform_fire" ), tankers, "TAG_FX_CAR3_PLATFORM_02" );
		
	node anim_single(guys, "turret_battle_tanker_explosion");
	
	tankers delete();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

turret_battle_crate_explosion( flag )
{
	node = GetEnt( "vignette_turret_battle_crate_explosion", "targetname" );

	crates = spawn_anim_model("crates");

	guys = [];
	guys["crates"] = crates;

	node anim_first_frame(guys, "turret_battle_crate_explosion");
	crates LinkTo( node );	
	
	flag_wait( flag );
	
	node playsound("lava_train_explo_crate");
	
	PlayFXOnTag( getfx( "train_3_part_explosion_01" ), crates, "TAG_FX_CAR3_BOX_30" );
	wait (0.1);
	//PlayFXOnTag( getfx( "train_3_part_explosion_01" ), crates, "TAG_FX_CAR3_BOX_25" );
	//wait (0.1);
	PlayFXOnTag( getfx( "train_3_part_explosion_01" ), crates, "TAG_FX_CAR3_BARREL_21" );
	wait (0.1);
	PlayFXOnTag( getfx( "train_3_part_explosion_01" ), crates, "TAG_FX_CAR3_BARREL_19" );
	//PlayFXOnTag( getfx( "train_3_part_explosion_01" ), crates, "TAG_FX_CAR3_BOX_17" );
	

	PlayFXOnTag( getfx( "train_platform_fire" ), crates, "TAG_FX_CAR3_PLATFORM_01" );
		
	node anim_single(guys, "turret_battle_crate_explosion");

	wait (5.0);
	crates delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

turret_battle_rocket_engine_explosion( flag )
{
	node = GetEnt( "vignette_turret_rocket_engine", "targetname" );

	engine = spawn_anim_model("rocket_engine");

	guys = [];
	guys["engine"] = engine;

	node anim_first_frame(guys, "turret_battle_rocket_engine_explosion");
	engine LinkTo( node );	
	
	flag_wait( flag );
	
	node playsound("lava_train_explo_turret");
	//PlayFXOnTag( getfx( "turret_explosion" ), engine, "tag_origin" );
	PlayFXOnTag( getfx( "train_3_part_explosion_02" ), engine, "TAG_FX_ROCKET_012" );
	 	
	node anim_single(guys, "turret_battle_rocket_engine_explosion");
	
	engine delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

turret_battle_rocket_engine_tanks_explosion( flag )
{
	node = GetEnt( "vignette_turret_rocket_engine_tanks", "targetname" );

	tanks = spawn_anim_model("rocket_tanks");

	guys = [];
	guys["tanks"] = tanks;

	node anim_first_frame(guys, "turret_battle_rocket_engine_tanks_explosion");
	tanks LinkTo( node );	
	
	flag_wait( flag );
	
	node playsound("lava_train_explo_rocket");
	//PlayFXOnTag( getfx( "turret_explosion" ), tanks, "tag_origin" );
	PlayFXOnTag( getfx( "train_3_part_explosion_01" ), tanks, "TAG_FX_CANISTER_025" );
	wait (0.1);
	PlayFXOnTag( getfx( "train_3_part_explosion_01" ), tanks, "TAG_FX_CANISTER_035" );
	wait (0.1);
	PlayFXOnTag( getfx( "train_3_part_explosion_01" ), tanks, "TAG_FX_CANISTER_035" );
	wait (0.1);
	PlayFXOnTag( getfx( "train_3_part_explosion_01" ), tanks, "TAG_FX_CANISTER_028" );
	PlayFXOnTag( getfx( "train_3_part_explosion_01" ), tanks, "TAG_FX_CANISTER_018" );
	PlayFXOnTag( getfx( "train_platform_fire" ), tanks, "TAG_FX_PLATFORM_FLOOR_02" );
	PlayFXOnTag( getfx( "train_platform_fire" ), tanks, "TAG_FX_PLATFORM_FLOOR_01" );
		

	node anim_single(guys, "turret_battle_rocket_engine_tanks_explosion");
	
	tanks delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

turret_battle_tire_explosion_spawn()
{
	turret_battle_tire_explosion();
}

turret_battle_tire_explosion( flag )
{
	node = GetEnt("vignette_turret_battle_tire_explosion", "targetname");

	tires = spawn_anim_model("tires");

	guys = [];
	guys["tires"] = tires;

	node anim_first_frame(guys, "turret_battle_tire_explosion");
	tires LinkTo( node );

	// tagTC<remove> - waiting on anims
	tires hide();
	
	flag_wait( flag );

	// tagTC<remove> - waiting on anims
	tires show();
	
	node playsound("lava_train_explo_tire");

	//PlayFXOnTag( getfx( "turret_explosion" ), tires, "tag_origin" );
	
	node anim_single(guys, "turret_battle_tire_explosion");
	
	tires delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

turret_battle_tank_near_hit_spawn()
{

	turret_battle_tank_near_hit();

}

turret_battle_tank_near_hit( flag )
{
	level thread turret_battle_tank_near_hit_player( flag );
	node = GetEnt("vignette_turret_battle_tank_near_hit", "targetname");

	tank = spawn_anim_model("tank");

	guys = [];
	guys["tank"] = tank;

	arc = 15;

	node anim_first_frame( guys, "turret_battle_tank_near_hit" );
	tank LinkTo( node );	

	// tagTC<remove> - waiting on anims
	tank hide();
	
	flag_wait( flag );

	// tagTC<remove> - waiting on anims
	tank show();
	
	node playsound("lava_train_explo_tankernear");

	//PlayFXOnTag( getfx( "turret_explosion" ), tank, "tag_origin" );
	
	node anim_single( guys, "turret_battle_tank_near_hit" );
	
	tank delete();
}

turret_battle_tank_near_hit_player( flag )
{
	/*flag_wait( flag );
	node = Spawn( "script_origin", level._player.origin );
	node LinkTo ( level._player );

	player_rig = spawn_anim_model( "player_rig", node.origin );

	guys = [];
	guys["player_rig"] = player_rig;

	node anim_single( guys, "turret_battle_tank_near_hit" );*/
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

turret_battle_train_derail_spawn()
{

	turret_battle_train_derail();

}

turret_battle_train_derail( flag, flag_done )
{

	node = GetEnt("vignette_turret_battle_train_derail", "targetname");

	train_derail = spawn_anim_model("train_derail");

	guys = [];
	guys["train_derail"] = train_derail;

	train_derail LinkTo( node );	

	flag_wait( flag );

	node anim_single(guys, "turret_battle_train_derail");

	flag_set( flag_done ); 
	
	train_derail delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

turret_battle_train_derail_02_spawn()
{

	turret_battle_train_derail_02();

}

turret_battle_train_derail_02( flag, flag_done )
{

	node = GetEnt("vignette_turret_battle_train_derail_02", "targetname");

	train_derail_02 = spawn_anim_model("train_derail_02");

	guys = [];
	guys["train_derail_02"] = train_derail_02;
	
	train_derail_02 LinkTo( node );

	flag_wait( flag );

	node anim_single(guys, "turret_battle_train_derail_02");

	flag_set( flag_done ); 
	
	train_derail_02 delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skimmer_crash_tower_spawn()
{
	skimmer = vignette_vehicle_spawn("skimmer_battle", "skimmer"); //"value" (kvp), "anim_name"

	skimmer_crash_tower(skimmer);

	skimmer vignette_vehicle_delete();
}

skimmer_crash_tower(skimmer)
{

	node = getstruct("vignette_skimmer_crash_tower", "script_noteworthy");

	tower_collapse = spawn_anim_model("tower_collapse");


	guys = [];
	guys["skimmer"] = skimmer;
	guys["tower_collapse"] = tower_collapse;

	node anim_single(guys, "skimmer_crash_tower");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skimmer_crash_rocks_spawn()
{
	skimmer = vignette_vehicle_spawn("skimmer_battle", "skimmer"); //"value" (kvp), "anim_name"

	skimmer_crash_rocks(skimmer);

	skimmer vignette_vehicle_delete();
}

skimmer_crash_rocks(skimmer)
{

	node = getstruct("vignette_skimmer_crash_rocks", "script_noteworthy");

	//rocks = spawn_anim_model("rocks");

	//apm_adding in an effect for this
	//PlayFX( level._effect[ "skimmer_rocks_impact_fx" ], node.origin + ( 0, 0, 100 ) );
	exploder ( "skimmer_rocks_01" );

	guys = [];
	guys["skimmer"] = skimmer;
	//guys["rocks"] = rocks;

	node anim_single(guys, "skimmer_crash_rocks");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skimmer_crash_rocks_02_spawn()
{

	skimmer_crash_rocks_02();

}

skimmer_crash_rocks_02()
{

	node = getstruct("vignette_skimmer_crash_rocks_02", "script_noteworthy");

	rocks = spawn_anim_model("rocks");


	guys = [];
	guys["rocks"] = rocks;

	node anim_single(guys, "skimmer_crash_rocks_02");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_derailment_spawn()
{
	tillman = vignette_actor_spawn("vignette_tillman_02", "tillman"); //"value" (kvp), "anim_name"
	player_legs = vignette_actor_spawn("vignette_player_legs_02", "player_legs"); //"value" (kvp), "anim_name"
	rover01 = vignette_vehicle_spawn("vignette_rover01", "rover01"); //"value" (kvp), "anim_name"
	rover02 = vignette_vehicle_spawn("vignette_rover02", "rover02"); //"value" (kvp), "anim_name"

	train_derailment(tillman, player_legs, rover01, rover02);

	tillman vignette_actor_delete();
	player_legs vignette_actor_delete();
	rover01 vignette_vehicle_delete();
	rover02 vignette_vehicle_delete();
}

train_derailment(tillman, player_legs, rover01, rover02)
{

	node = getstruct("vignette_train_derailment", "script_noteworthy");

	//train = spawn_anim_model("train");

	// tires = spawn_anim_model("tires");

	train_car_01 = spawn_anim_model("train_car_01");

	train_car_02 = spawn_anim_model("train_car_02");

	train_car_03 = spawn_anim_model("train_car_03");

	train_car_04 = spawn_anim_model("train_car_04");

	train_car_player = spawn_anim_model("train_car_player");

	//level._player FreezeControls( true );
	level._player disableweapons();
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["player_rig"] = player_rig;
	//guys["train"] = train;
	guys["tillman"] = tillman;
	// guys["player_legs"] = player_legs;
	// guys["tires"] = tires;
	guys["rover01"] = rover01;
	guys["rover02"] = rover02;
	guys["train_car_01"] = train_car_01;
	guys["train_car_02"] = train_car_02;
	guys["train_car_03"] = train_car_03;
	guys["train_car_04"] = train_car_04;
	guys["train_car_player"] = train_car_player;

	arc = 5;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	// derail
	exploder( 1 );
	node anim_single(guys, "train_derailment");

	// tagTC<temp> - wait a bit and then end misison for now
	endmission_goto_frontend();

	//level._player unlink();
	//player_rig delete();

	//level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

angelsquad_reveal_spawn()
{
	opfor1 = vignette_actor_spawn("vignette_angelsquad_opfor1", "opfor1"); //"value" (kvp), "anim_name"
	opfor2 = vignette_actor_spawn("vignette_angelsquad_opfor2", "opfor2"); //"value" (kvp), "anim_name"
	angelsquad1 = vignette_actor_spawn("vignette_angelsquad1", "angelsquad1"); //"value" (kvp), "anim_name"
	angelsquad2 = vignette_actor_spawn("vignette_angelsquad2", "angelsquad2"); //"value" (kvp), "anim_name"
	angelsquad3 = vignette_actor_spawn("vignette_angelsquad3", "angelsquad3"); //"value" (kvp), "anim_name"
	deadguy = vignette_actor_spawn("vignette_angelsquad_deadguy", "deadguy"); //"value" (kvp), "anim_name"
	shotguy = vignette_actor_spawn("vignette_angelsquad_shotguy", "shotguy"); //"value" (kvp), "anim_name"

	angelsquad_reveal(opfor1, opfor2, angelsquad1, angelsquad2, angelsquad3, deadguy, shotguy);

	opfor1 vignette_actor_delete();
	opfor2 vignette_actor_delete();
	angelsquad1 vignette_actor_delete();
	angelsquad2 vignette_actor_delete();
	angelsquad3 vignette_actor_delete();
	deadguy vignette_actor_delete();
	shotguy vignette_actor_delete();
}

angelsquad_reveal(opfor1, opfor2, angelsquad1, angelsquad2, angelsquad3, deadguy, shotguy)
{

	node = getstruct("vignette_angelsquad_reveal", "script_noteworthy");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["opfor1"] = opfor1;
	guys["opfor2"] = opfor2;
	guys["angelsquad1"] = angelsquad1;
	guys["angelsquad2"] = angelsquad2;
	guys["angelsquad3"] = angelsquad3;
	guys["deadguy"] = deadguy;
	guys["shotguy"] = shotguy;
	guys["player_rig"] = player_rig;

	arc = 15;

	//level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "angelsquad_reveal");

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


















