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
	generic_human();
	player_anims();
	script_models();
}

#using_animtree("generic_human");
generic_human()
{
	level._scr_anim[ "ally" ][ "top_at_console" ] 				= %proto_nx_harbor_ally_top_atconsole;
	level._scr_anim[ "ally" ][ "top_from_console" ]				= %proto_nx_harbor_ally_top_fromconsole;
	level._scr_anim[ "ally" ][ "top_to_console" ]				= %proto_nx_harbor_ally_top_toconsole;

	level._scr_anim[ "ally" ][ "top_door_cross_left" ]			= %proto_nx_harbor_ally_top_cross1;
	level._scr_anim[ "ally" ][ "top_door_cross_right" ] 		= %proto_nx_harbor_ally_top_cross2;
	level._scr_anim[ "ally" ][ "top_door_left" ]				= %proto_nx_harbor_ally_top_left;
	level._scr_anim[ "ally" ][ "top_door_right" ]				= %proto_nx_harbor_ally_top_right;

	level._scr_anim[ "ally" ][ "bottom_window_cross_left" ]		= %proto_nx_harbor_ally_bottom_cross1;
	level._scr_anim[ "ally" ][ "bottom_window_cross_right" ]	= %proto_nx_harbor_ally_bottom_cross2;
	level._scr_anim[ "ally" ][ "bottom_window_left" ]			= %proto_nx_harbor_ally_bottom_left;
	level._scr_anim[ "ally" ][ "bottom_window_right" ]			= %proto_nx_harbor_ally_bottom_right;

	// wakeup in vehicle bay
	level._scr_anim[ "ally" ][ "tram_derail" ] 					= %proto_nx_harbor_tp_ending_ally01;
}

#using_animtree( "player" );
player_anims()
{
	level._scr_animtree[ "player_rig" ]							= #animtree;
	level._scr_model[ "player_rig" ]							= "viewmodel_base_viewhands";
	level._scr_anim[ "player_rig" ][ "tram_derail" ] 			= %proto_nx_harbor_fp_ending;
}

#using_animtree("script_model");
script_models()
{
	level._scr_animtree[ "tram" ] 						= #animtree;
	level._scr_model[ "tram" ] 							= "nx_prototype_harbor_train";
	level._scr_anim[ "tram" ][ "tram_derail" ] 			= %proto_nx_harbor_pr_ending_tram;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
