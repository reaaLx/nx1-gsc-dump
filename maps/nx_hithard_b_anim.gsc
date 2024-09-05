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
	flag_init( "fx_back_half_turn_off" );
	flag_init( "fx_back_half_turn_on" );

	script_models();
	generic_human();
	vehicles();
	player();
	dialog();

	// Threading the vignette scripts
	level thread vignettes();

	level thread fx_cleanup();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Vignettes is threaded at the start of the mission, each anim dept
// implemented vignette should be threaded here a block until triggered
vignettes()
{
//	level thread vignette_register( ::tank_lapes_spawn, "tank_lapes_flag" );
//  level thread vignette_register( ::vphit_spawn, "vignette_hithard_vphit" );
//  level thread vignette_register( ::vpdrag_spawn, "vignette_hithard_vpdrag" );
//	level thread vignette_register( ::bravomeetgreet_spawn, "vignette_bravomeet" );
//	level thread vignette_register( ::new_tank_lapes_spawn, "tank_lapes_flag" );
//level thread vignette_register( ::lapes_unlatch_spawn, "lapes_unlatch" );

// vp hit secret service guy runs up and waves vp and Baker on
//  level thread vignette_register( ::vphit_ssrunup_spawn, "vignette_play_vphit_ssrunup" );

// vp hit all four guys start in the vignette
//  level thread vignette_register( ::vphit_start_spawn, "vignette_play_vphit_start" );
}

// Setting up dead bodies
#using_animtree( "generic_human" );
dead_men_setup()
{
	dead_men = GetEntArray( "dead_civilians", "script_noteworthy" );

	foreach( guy in dead_men )
	{
		guy.animname = "generic";
		guy show();
        guy UseAnimTree( #animtree );
        guy thread anim_generic( guy, guy.animation );
        guy SetAnimTime( getanim_generic( guy.animation ), 1 );        
	}
}

#using_animtree( "script_model" );
script_models()
{
	//City Hall Swat Door
    level._scr_animtree[ "cityhall_door" ] = #animtree;
    level._scr_anim[ "cityhall_door" ][ "cityhall_swat_door_start" ] = %nx_pr_hithard_cityhall_swat_door_start;
    level._scr_model[ "cityhall_door" ] = "com_door_01_handleleft";
    level._scr_animtree[ "cityhall_door" ] = #animtree;
    level._scr_anim[ "cityhall_door" ][ "cityhall_swat_door_end" ] = %nx_pr_hithard_cityhall_swat_door_end;
    level._scr_model[ "cityhall_door" ] = "com_door_01_handleleft";
    level._scr_animtree[ "cityhall_door" ] = #animtree;
    level._scr_anim[ "cityhall_door" ][ "cityhall_swat_door_idle" ] [ 0 ] = %nx_pr_hithard_cityhall_swat_door_idle;
    level._scr_model[ "cityhall_door" ] = "com_door_01_handleleft";

	//New Tank Lapes
	level._scr_animtree[ "lapes_c102" ] = #animtree;
	level._scr_anim[ "lapes_c102" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_c102_01;
	level._scr_model[ "lapes_c102" ] = "nx_vehicle_c102";

	level._scr_animtree[ "lapes_tank" ] = #animtree;
	level._scr_anim[ "lapes_tank" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_tank_01;
	level._scr_model[ "lapes_tank" ] = "nx_vehicle_us_tank";
	addNotetrack_customFunction( "lapes_tank", "unhide_tank", ::Lapes_unhide_tank );

	level._scr_animtree[ "lapes_bus" ] = #animtree;
	level._scr_anim[ "lapes_bus" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_bus_01;
	level._scr_model[ "lapes_bus" ] = "nx_vehicle_us_bus_static";
	addNotetrack_customFunction( "lapes_bus", "bus_swap", ::Lapes_bus_swap );

	level._scr_animtree[ "lapes_bus2" ] = #animtree;
	level._scr_anim[ "lapes_bus2" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_bus_01;
	level._scr_model[ "lapes_bus2" ] = "nx_vehicle_us_bus_crushed_static";
	addNotetrack_customFunction( "lapes_bus2", "bus_swap", ::Lapes_bus_swap2 );

	level._scr_animtree[ "lapes_sedan01" ] = #animtree;
	level._scr_anim[ "lapes_sedan01" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_sedan01_01;
	level._scr_model[ "lapes_sedan01" ] = "nx_vehicle_sedan_destructible";

	level._scr_animtree[ "lapes_car01" ] = #animtree;
	level._scr_anim[ "lapes_car01" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_car01_01;
	level._scr_model[ "lapes_car01" ] = "nx_vehicle_sedan_destructible";

	level._scr_animtree[ "lapes_car02" ] = #animtree;
	level._scr_anim[ "lapes_car02" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_car02_01;
	level._scr_model[ "lapes_car02" ] = "nx_vehicle_micro_brightyellow";

	level._scr_animtree[ "lapes_car03" ] = #animtree;
	level._scr_anim[ "lapes_car03" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_car03_01;
	level._scr_model[ "lapes_car03" ] = "nx_vehicle_civilian_suv_green";

	level._scr_animtree[ "lapes_car04" ] = #animtree;
	level._scr_anim[ "lapes_car04" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_car04_01;
	level._scr_model[ "lapes_car04" ] = "nx_vehicle_micro";

	level._scr_animtree[ "lapes_car05" ] = #animtree;
	level._scr_anim[ "lapes_car05" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_car05_01;
	level._scr_model[ "lapes_car05" ] = "nx_vehicle_sedan_destructible";

	level._scr_animtree[ "lapes_car06" ] = #animtree;
	level._scr_anim[ "lapes_car06" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_car06_01;
	level._scr_model[ "lapes_car06" ] = "nx_vehicle_micro";

	level._scr_animtree[ "lapes_car07" ] = #animtree;
	level._scr_anim[ "lapes_car07" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_car07_01;
	level._scr_model[ "lapes_car07" ] = "nx_vehicle_civilian_suv_red";

	level._scr_animtree[ "lapes_car08" ] = #animtree;
	level._scr_anim[ "lapes_car08" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_car08_01;
	level._scr_model[ "lapes_car08" ] = "nx_vehicle_sedan_destructible";

	level._scr_animtree[ "lapes_car09" ] = #animtree;
	level._scr_anim[ "lapes_car09" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_car09_01;
	level._scr_model[ "lapes_car09" ] = "nx_vehicle_civilian_suv_green";

	level._scr_animtree[ "lapes_car10" ] = #animtree;
	level._scr_anim[ "lapes_car10" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_car10_01;
	level._scr_model[ "lapes_car10" ] = "nx_vehicle_sedan_destructible";

	level._scr_animtree[ "lapes_car11" ] = #animtree;
	level._scr_anim[ "lapes_car11" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_car11_01;
	level._scr_model[ "lapes_car11" ] = "nx_vehicle_civilian_suv_red";

	level._scr_animtree[ "lapes_dragchute" ] = #animtree;
	level._scr_anim[ "lapes_dragchute" ][ "new_tank_lapes" ] = %nx_pr_hhh_tanklapes_dragchute_01;
	level._scr_model[ "lapes_dragchute" ] = "nx_pr_hithard_drag_chute";
	addNotetrack_customFunction( "lapes_dragchute", "unhide_dragchute", ::Lapes_dragchute_unhide );

	level._scr_animtree[ "lapes_lights" ] = #animtree;
	level._scr_anim[ "lapes_lights" ][ "new_tank_lapes" ] = %nx_pr_hhh_tanklapes_lightposts;
	level._scr_model[ "lapes_lights" ] = "nx_pr_hithard_highway_lightposts_01";

	level._scr_animtree[ "lapes_pallet" ] = #animtree;
	level._scr_anim[ "lapes_pallet" ][ "new_tank_lapes" ] = %nx_pr_hhh_tanklapes_pallet;
	level._scr_model[ "lapes_pallet" ] = "nx_vehicle_us_lapes_pallet";
	addNotetrack_customFunction( "lapes_pallet", "unhide_pallet", ::Lapes_unhide_pallet );

	//Tank Lapes Unlatch
	level._scr_animtree[ "lapes_pallet_unlatch" ] = #animtree;
	level._scr_anim[ "lapes_pallet_unlatch" ][ "lapes_unlatch" ] = %nx_pr_hhh_tanklapes_unlatch_pallet;
	level._scr_model[ "lapes_pallet_unlatch" ] = "nx_vehicle_us_lapes_pallet";

	level._scr_animtree[ "lapes_tank_unlatch" ] = #animtree;
	level._scr_anim[ "lapes_tank_unlatch" ][ "lapes_unlatch" ] = %nx_vh_hhh_tanklapes_tank_unlatch_01;
	level._scr_model[ "lapes_tank_unlatch" ] = "nx_vehicle_us_tank";

	//fx geo
	level._scr_animtree[ "lapes_fx" ] = #animtree;
	level._scr_anim[ "lapes_fx" ][ "new_tank_lapes" ] = %nx_fx_lapes_flares_anim;
	level._scr_model[ "lapes_fx" ] = "nx_pr_hithard_lapes_fx_geo";

	addNotetrack_customFunction( "lapes_fx", "drop_dust", ::lapes_tank_drop_fx );
	addNotetrack_customFunction( "lapes_fx", "car_hit_01", ::lapes_car01_hitfx );
	addNotetrack_customFunction( "lapes_fx", "car_hit_02", ::lapes_car02_hitfx );
	addNotetrack_customFunction( "lapes_fx", "car_hit_03", ::lapes_car03_hitfx );
	addNotetrack_customFunction( "lapes_fx", "car_hit_04", ::lapes_car04_hitfx );
	addNotetrack_customFunction( "lapes_fx", "car_hit_05", ::lapes_car05_hitfx );
	addNotetrack_customFunction( "lapes_fx", "car_hit_06", ::lapes_car06_hitfx );
	addNotetrack_customFunction( "lapes_fx", "car_hit_07", ::lapes_car07_hitfx );
	addNotetrack_customFunction( "lapes_fx", "car_hit_08", ::lapes_car08_hitfx );
	addNotetrack_customFunction( "lapes_fx", "car_hit_09", ::lapes_car09_hitfx );
	addNotetrack_customFunction( "lapes_fx", "car_hit_10", ::lapes_car10_hitfx );
	addNotetrack_customFunction( "lapes_fx", "car_hit_10_wall_sparks", ::lapes_car10_wall_sparks );
	addNotetrack_customFunction( "lapes_fx", "car_hit_10_flip", ::lapes_car10_flip );
	addNotetrack_customFunction( "lapes_fx", "car_hit_10_land", ::lapes_car10_land );
	addNotetrack_customFunction( "lapes_fx", "flare_l_01", ::lapes_flare_l_01 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_02", ::lapes_flare_l_02 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_03", ::lapes_flare_l_03 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_04", ::lapes_flare_l_04 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_05", ::lapes_flare_l_05 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_06", ::lapes_flare_l_06 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_07", ::lapes_flare_l_07 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_08", ::lapes_flare_l_08 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_09", ::lapes_flare_l_09 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_10", ::lapes_flare_l_10 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_11", ::lapes_flare_l_11 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_12", ::lapes_flare_l_12 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_13", ::lapes_flare_l_13 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_14", ::lapes_flare_l_14 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_15", ::lapes_flare_l_15 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_16", ::lapes_flare_l_16 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_17", ::lapes_flare_l_17 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_18", ::lapes_flare_l_18 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_19", ::lapes_flare_l_19 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_20", ::lapes_flare_l_20 );
	addNotetrack_customFunction( "lapes_fx", "flare_l_21", ::lapes_flare_l_21 );
	addNotetrack_customFunction( "lapes_fx", "lapes_aa", ::lapes_aa );
	addNotetrack_customFunction( "lapes_c102", "front_thrusters_on", ::c102_front_thrusters_on );
	addNotetrack_customFunction( "lapes_c102", "front_thrusters_off", ::c102_front_thrusters_off );
	addNotetrack_customFunction( "lapes_c102", "back_thrusters_on", ::c102_back_thrusters_on );
	addNotetrack_customFunction( "lapes_c102", "enginehit", ::c102_enginehit );
	addNotetrack_customFunction( "lapes_fx", "c102_tread_dust", ::c102_tread_dust );
	addNotetrack_customFunction( "lapes_fx", "phalanx_fire_start", ::phalanx_fire_start );
	addNotetrack_customFunction( "lapes_fx", "bushit_car01", ::bushit_car01 );
	addNotetrack_customFunction( "lapes_fx", "bushit_car02", ::bushit_car02 );
	addNotetrack_customFunction( "lapes_fx", "busparks", ::busparks );
}

phalanx_fire_start( lapes_fx )
{
	thread phalanx_fire_start_left( lapes_fx );

	PlayFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  lapes_fx, "tag_c102_phalanx_l");
	wait 1;
	StopFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  lapes_fx, "tag_c102_phalanx_l");
	wait 0.5;
	PlayFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  lapes_fx, "tag_c102_phalanx_l");
	wait 1;
	StopFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  lapes_fx, "tag_c102_phalanx_l");
	wait 1;
	PlayFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  lapes_fx, "tag_c102_phalanx_l");
	wait 2;
	StopFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  lapes_fx, "tag_c102_phalanx_l");
	wait 0.5;
	PlayFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  lapes_fx, "tag_c102_phalanx_l");
	wait 1;
	StopFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  lapes_fx, "tag_c102_phalanx_l");
}

phalanx_fire_start_left( lapes_fx )
{
	PlayFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  lapes_fx, "tag_c102_phalanx_r");
	wait 1;
	StopFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  lapes_fx, "tag_c102_phalanx_r");
	wait 0.5;
	PlayFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  lapes_fx, "tag_c102_phalanx_r");
	wait 1;
	StopFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  lapes_fx, "tag_c102_phalanx_r");
	wait 1;
	PlayFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  lapes_fx, "tag_c102_phalanx_r");
	wait 2;
	StopFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  lapes_fx, "tag_c102_phalanx_r");
	wait 0.5;
	PlayFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  lapes_fx, "tag_c102_phalanx_r");
	wait 1;
	StopFXOnTag( level._effect[ "nx_c102_phalanx_runner" ],  lapes_fx, "tag_c102_phalanx_r");
}

c102_front_thrusters_on( lapes_c102 )
{
	//StopFXOnTag( level._effect[ "osprey_small_afterburner" ],  ospreycrashvp, "tag_engine_left_fx1");
	PlayFXOnTag( level._effect[ "nx_c102_looping_large_afterburner" ],  lapes_c102, "tag_fx_afterburn_front_01");
	PlayFXOnTag( level._effect[ "nx_c102_looping_large_afterburner" ],  lapes_c102, "tag_fx_afterburn_front_02");
	PlayFXOnTag( level._effect[ "nx_c102_looping_large_afterburner" ],  lapes_c102, "tag_fx_afterburn_front_03");
	PlayFXOnTag( level._effect[ "nx_c102_looping_large_afterburner" ],  lapes_c102, "tag_fx_afterburn_front_04");
}

c102_front_thrusters_off( lapes_c102 )
{
	StopFXOnTag( level._effect[ "c102_large_afterburner" ],  lapes_c102, "tag_fx_afterburn_front_01");
	StopFXOnTag( level._effect[ "c102_large_afterburner" ],  lapes_c102, "tag_fx_afterburn_front_02");
	StopFXOnTag( level._effect[ "c102_large_afterburner" ],  lapes_c102, "tag_fx_afterburn_front_03");
	StopFXOnTag( level._effect[ "c102_large_afterburner" ],  lapes_c102, "tag_fx_afterburn_front_04");
}

c102_back_thrusters_on( lapes_c102 )
{
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  lapes_c102, "tag_fx_enginesmoke_01");
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  lapes_c102, "tag_fx_enginesmoke_02");
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  lapes_c102, "tag_fx_enginesmoke_03");
	PlayFXOnTag( level._effect[ "c102_medium_afterburner" ],  lapes_c102, "tag_fx_enginesmoke_04");
}

c102_enginehit( lapes_c102 )
{
	PlayFXOnTag( level._effect[ "nx_c102_engine_explosion" ],  lapes_c102, "tag_fx_afterburn_front_03");
	wait 1;
	PlayFXOnTag( level._effect[ "c102_engine_burn_emmiter" ],  lapes_c102, "tag_fx_afterburn_front_03");
}

c102_tread_dust( lapes_fx )
{
	PlayFXOnTag( level._effect[ "c102_dust_runner" ],  lapes_fx, "tag_c102_dust");
}

lapes_aa( ent )
{
	exploder( "lapes_aa" );
}

lapes_flare_l_01( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_01" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_01" );
	*/
}

lapes_flare_l_02( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_02" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_02" );
	*/
}

lapes_flare_l_03( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_03" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_03" );
	*/
}

lapes_flare_l_04( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_04" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_04" );
	*/
}

lapes_flare_l_05( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_05" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_05" );
	*/
}

lapes_flare_l_06( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_06" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_06" );
	*/
}

lapes_flare_l_07( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_07" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_07" );
	*/
}

lapes_flare_l_08( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_08" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_08" );
	*/
}

lapes_flare_l_09( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_09" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_09" );
	*/
}

lapes_flare_l_10( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_10" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_10" );
	*/
}

lapes_flare_l_11( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_11" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_11" 
	*/
}

lapes_flare_l_12( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_12" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_12" );
	*/
}
lapes_flare_l_13( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_13" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_13" );
	*/
}
lapes_flare_l_14( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_14" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_14" );
	*/
}
lapes_flare_l_15( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_15" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_15" );
	*/
}
lapes_flare_l_16( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_16" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_16" );
	*/
}
lapes_flare_l_17( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_17" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_17" );
	*/
}
lapes_flare_l_18( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_18" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_18" );
	*/
}
lapes_flare_l_19( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_19" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_19" );
	*/
}
lapes_flare_l_20( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_20" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_20" );
	*/
}
lapes_flare_l_21( lapes_fx )
{
/*
	PlayFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_21" );
	wait 1.3;
	StopFXOnTag( getfx( "nx_c102_angel_flare_geotrail" ), lapes_fx, "tag_flare_21" );
	*/
}

lapes_tank_drop_fx( lapes_fx )
{
	PlayFXOnTag( getfx( "nx_lapes_tank_drop_dust" ), lapes_fx, "tag_tankdust" );
	wait 0.5;
	//iPrintLnBold("--- got looping ---");
	PlayFXOnTag( getfx( "nx_lapes_tank_dust_looping_runner" ), lapes_fx, "tag_tankdust" );
	PlayFXOnTag( getfx( "nx_impact_lapes_debri_directional_runner" ), lapes_fx, "tag_tankdust" );
/*
	level._player thread maps\_gameskill::grenade_dirt_on_screen( "left" );
	wait 2.5;
	level._player thread maps\_gameskill::grenade_dirt_on_screen( "right" );
	wait 1.34;
	level._player thread maps\_gameskill::grenade_dirt_on_screen( "left" );
	wait 1.5;
	level._player thread maps\_gameskill::grenade_dirt_on_screen( "right" );
	*/
}

lapes_car01_hitfx( lapes_fx )
{
	PlayFXOnTag( getfx( "nx_impact_lapes_carhit" ), lapes_fx, "tag_car01_hit" );
	wait 2;
	PlayFXOnTag( getfx( "firelp_large_pm_bh1" ), lapes_fx, "tag_car01_hit" );
	PlayFXOnTag( getfx( "nx_fire_car_fire_n_smoke" ), lapes_fx, "tag_car01_hit" );
	exploder("lapes_afterfx");
}

lapes_car02_hitfx( lapes_fx )
{
	//PlayFXOnTag( getfx( "nx_impact_lapes_carhit_small" ), lapes_fx, "tag_car02_hit" );
	wait 2;
	PlayFXOnTag( getfx( "firelp_med_pm_bh1" ), lapes_fx, "tag_car02_hit" );
}

lapes_car03_hitfx( lapes_fx )
{
	//PlayFXOnTag( getfx( "nx_impact_lapes_carhit_small" ), lapes_fx, "tag_car03_hit" );
	wait 2;
	PlayFXOnTag( getfx( "firelp_small_pm" ), lapes_fx, "tag_car03_hit" );
}

lapes_car04_hitfx( lapes_fx )
{
	PlayFXOnTag( getfx( "nx_impact_lapes_carhit" ), lapes_fx, "tag_car04_hit" );
	wait 2;
	PlayFXOnTag( getfx( "firelp_small_pm" ), lapes_fx, "tag_car04_hit" );
}

lapes_car05_hitfx( lapes_fx )
{
	//PlayFXOnTag( getfx( "nx_impact_lapes_carhit_small" ), lapes_fx, "tag_car05_hit" );
	PlayFXOnTag( getfx( "nx_lapes_carhit_explosion" ), lapes_fx, "tag_car05_hit" );
	wait 2;
	PlayFXOnTag( getfx( "firelp_large_pm_bh1" ), lapes_fx, "tag_car05_hit" );
	PlayFXOnTag( getfx( "nx_fire_car_fire_n_smoke" ), lapes_fx, "tag_car05_hit" );
}

lapes_car06_hitfx( lapes_fx )
{
	PlayFXOnTag( getfx( "nx_impact_lapes_carhit_small" ), lapes_fx, "tag_car06_hit" );
	wait 2;
	PlayFXOnTag( getfx( "firelp_large_pm_bh1" ), lapes_fx, "tag_car06_hit" );
}

lapes_car07_hitfx( lapes_fx )
{
	PlayFXOnTag( getfx( "nx_impact_lapes_carhit" ), lapes_fx, "tag_car07_hit" );
	wait 2;
	//PlayFXOnTag( getfx( "firelp_small_pm" ), lapes_fx, "tag_car07_hit" );
	//PlayFXOnTag( getfx( "nx_fire_car_fire_n_smoke" ), lapes_fx, "tag_car07_hit" );
}

lapes_car08_hitfx( lapes_fx )
{
	//PlayFXOnTag( getfx( "nx_impact_lapes_carhit_small" ), lapes_fx, "tag_car08_hit" );
	wait 2;
	PlayFXOnTag( getfx( "firelp_med_pm_bh1" ), lapes_fx, "tag_car08_hit" );
}
//bus
lapes_car09_hitfx( lapes_fx )
{
	PlayFXOnTag( getfx( "nx_impact_lapes_bus_hit" ), lapes_fx, "tag_car09_hit" );
	wait 2;
	PlayFXOnTag( getfx( "firelp_med_pm_bh1" ), lapes_fx, "tag_car09_hit" );
	//PlayFXOnTag( getfx( "nx_fire_car_fire_n_smoke" ), lapes_fx, "tag_car09_hit" );
}

bushit_car01( lapes_fx )
{
	PlayFXOnTag( getfx( "nx_impact_lapes_carhit_small" ), lapes_fx, "tag_buscar_01" );
}

bushit_car02( lapes_fx )
{
	//PlayFXOnTag( getfx( "nx_impact_lapes_carhit_small" ), lapes_fx, "tag_buscar_02" );
}

busparks( lapes_fx )
{
	PlayFXOnTag( getfx( "nx_impact_lapes_carhit_sparks_scrape" ), lapes_fx, "tag_bus_sparks_01" );
	PlayFXOnTag( getfx( "nx_impact_lapes_carhit_sparks_scrape" ), lapes_fx, "tag_bus_sparks_02" );
}

lapes_car10_hitfx( lapes_fx )
{
	PlayFXOnTag( getfx( "nx_impact_lapes_carhit_small" ), lapes_fx, "tag_car10_hit" );
	wait 5;
	PlayFXOnTag( getfx( "firelp_med_pm_bh1" ), lapes_fx, "tag_car10_hit" );
	PlayFXOnTag( getfx( "nx_fire_car_fire_n_smoke" ), lapes_fx, "tag_car10_hit" );
}

lapes_car10_wall_sparks( lapes_fx )
{
	PlayFXOnTag( getfx( "nx_impact_lapes_carhit_sparks_scrape" ), lapes_fx, "tag_car10_wallsparks" );
}

lapes_car10_flip( lapes_fx )
{
	PlayFXOnTag( getfx( "nx_impact_lapes_carhit_small" ), lapes_fx, "tag_car10_flip" );
}

lapes_car10_land( lapes_fx )
{
	PlayFXOnTag( getfx( "nx_impact_lapes_carhit" ), lapes_fx, "tag_car10_land" );
}

#using_animtree("generic_human");
generic_human()
{
	// Dead bodies posed
	level._scr_anim[ "generic" ][ "nx_tp_chinese_lgv_driver_death" ] = %nx_tp_chinese_lgv_driver_death;
	level._scr_anim[ "generic" ][ "nx_tp_chinese_lgv_guy1_death" ] = %nx_tp_chinese_lgv_guy1_death;
	level._scr_anim[ "generic" ][ "airport_civ_pillar_exit_death" ] = %airport_civ_pillar_exit_death;
	level._scr_anim[ "generic" ][ "civilian_leaning_death_shot" ] = %civilian_leaning_death_shot;
	level._scr_anim[ "generic" ][ "javelin_death_1" ] = %javelin_death_1;
	level._scr_anim[ "generic" ][ "security_guard_pillar_death_v1" ] = %security_guard_pillar_death_v1;
	level._scr_anim[ "generic" ][ "boneyard_driver_death" ] = %boneyard_driver_death;
	
	// quiet door open - City Hall East exit
	level._scr_anim[ "baker" ][ "hunted_open_barndoor" ] = 			%hunted_open_barndoor;
	level._scr_anim[ "baker" ][ "hunted_open_barndoor_stop" ] = 		%hunted_open_barndoor_stop;
	level._scr_anim[ "baker" ][ "hunted_open_barndoor_idle" ][ 0 ] = 	%hunted_open_barndoor_idle;

	level._scr_anim[ "ss_williams" ][ "exposed_reload" ] =              %exposed_reload;
	level._scr_anim[ "ss_hayes" ][ "exposed_reloadb" ] =              %exposed_reloadb;
	level._scr_anim[ "vp_price" ][ "cargoship_ch46_rescue_load_1_idle" ][ 0 ] =  %cargoship_ch46_rescue_load_1_idle;

	// UAV moment
	level._scr_anim[ "baker" ][ "training_intro_foley_idle_talk_2_first" ] = %training_intro_foley_idle_talk_2;
	level._scr_anim[ "baker" ][ "casual_crouch_V2_idle_in" ] = %casual_crouch_V2_idle_in;
	level._scr_anim[ "baker" ][ "stand_exposed_wave_move_out" ] = %stand_exposed_wave_move_out;

	// SS/VP movement
    level._scr_anim[ "vp_price" ][ "vp_arrival_in" ] = %nx_tp_hithard_vp_dodge_in;
    level._scr_anim[ "vp_price" ][ "vp_arrival_idle" ] = %nx_tp_hithard_vp_dodge_idle;
    level._scr_anim[ "vp_price" ][ "vp_arrival_out" ] = %nx_tp_hithard_vp_dodge_out;
	level._scr_anim[ "vp_price" ][ "idle_combat" ] = [ %nx_tp_hithard_VP_idle ];
	level._scr_anim[ "vp_price" ][ "react_stumble" ] = [ %run_react_stumble ];

    level._scr_anim[ "ss_williams" ][ "vp_arrival_in" ] = %nx_tp_hithard_ss_dodge_in;
    level._scr_anim[ "ss_williams" ][ "vp_arrival_idle" ] = %nx_tp_hithard_ss_dodge_idle;
    level._scr_anim[ "ss_williams" ][ "vp_arrival_out" ] = %nx_tp_hithard_ss_dodge_out;

    level._scr_anim[ "ss_hayes" ][ "vp_arrival_in" ] = %nx_tp_hithard_ss_dodge_in;
    level._scr_anim[ "ss_hayes" ][ "vp_arrival_idle" ] = %nx_tp_hithard_ss_dodge_idle;
    level._scr_anim[ "ss_hayes" ][ "vp_arrival_out" ] = %nx_tp_hithard_ss_dodge_out;
	level._scr_anim[ "ss_hayes" ][ "hunted_open_barndoor" ] =              %hunted_open_barndoor;
	level._scr_anim[ "ss_hayes" ][ "hunted_open_barndoor_stop" ] = 		%hunted_open_barndoor_stop;
	level._scr_anim[ "ss_hayes" ][ "hunted_open_barndoor_idle" ][ 0 ] = 	%hunted_open_barndoor_idle;


	// quiet door open - Plaza Exit
	level._scr_anim[ "gypsy" ][ "hunted_open_barndoor" ] = 			%hunted_open_barndoor;
	level._scr_anim[ "gypsy" ][ "hunted_open_barndoor_stop" ] = 		%hunted_open_barndoor_stop;
	level._scr_anim[ "gypsy" ][ "hunted_open_barndoor_idle" ][ 0 ] = 	%hunted_open_barndoor_idle;
	level._scr_anim[ "gypsy" ][ "CQB_stand_signal_stop" ] =                         %CQB_stand_signal_stop;

	// SWAT guys opening door to City Hall
    level._scr_anim[ "swat_ally01" ][ "cityhall_swat_door_start" ] = %nx_tp_hithard_cityhall_swat_door_ally01_start;
    level._scr_anim[ "swat_ally02" ][ "cityhall_swat_door_start" ] = %nx_tp_hithard_cityhall_swat_door_ally02_start;
    level._scr_anim[ "swat_ally01" ][ "cityhall_swat_door_end" ] = %nx_tp_hithard_cityhall_swat_door_ally01_end;
    level._scr_anim[ "swat_ally02" ][ "cityhall_swat_door_end" ] = %nx_tp_hithard_cityhall_swat_door_ally02_end;
    level._scr_anim[ "swat_ally01" ][ "cityhall_swat_door_idle" ] [ 0 ] = %nx_tp_hithard_cityhall_swat_door_ally01_idle;
    level._scr_anim[ "swat_ally02" ][ "cityhall_swat_door_idle" ] [ 0 ] = %nx_tp_hithard_cityhall_swat_door_ally02_idle;

	// Civilian Moment 
	level._scr_anim[ "hall_shooter"][ "mall_civ_moment" ] = %hunted_farmsequence_brute1;
	level._scr_anim[ "hall_guard" ][ "mall_civ_moment" ] = %hunted_farmsequence_brute2;

	level._scr_anim[ "vp_price" ][ "onramp_explosion_reaction" ] = %death_explosion_run_f_v1;

	// vp gets hit running up highway ramp
	level._scr_anim[ "baker_vphit" ][ "vphit" ] = %nx_tp_hithard_vphit_baker;
	level._scr_anim[ "vp_vphit" ][ "vphit" ] = %nx_tp_hithard_vphit_vp;
	level._scr_anim[ "secret_service1_vphit" ][ "vphit" ] = %nx_tp_hithard_vphit_ss1;
	addNotetrack_customFunction( "vp_vphit", "vp_blood_fall", maps\nx_hithard_b_fx::vp_blood_fall );
	addNotetrack_customFunction( "vp_vphit", "vp_blood_pool", maps\nx_hithard_b_fx::vp_blood_fall );

	// vp is pulled up the ramp by first person to safty
	level._scr_anim[ "baker_vpdrag" ][ "vpdrag_start" ] = %nx_tp_hithard_vpdrag_baker;
	level._scr_anim[ "baker_vpdrag" ][ "vpdrag_end" ] = %nx_tp_hithard_vpdrag_ivegotit_baker;
	level._scr_anim[ "vp_vpdrag" ][ "vpdrag" ] = %nx_tp_hithard_vpdrag_vp;

	// Bravp company meet and greet
	level._scr_anim[ "bravoc_bravomeet" ][ "bravomeetgreet" ] = %nx_tp_hithard_bravomeetgreet_bravoc_01;
	level._scr_anim[ "duke_bravomeet" ][ "bravomeetgreet" ] = %nx_tp_hithard_bravomeetgreet_duke_01;

	// First-aid (Temp, Pedram)
	level._scr_anim[ "vp_firstaid" ][ "firstaid" ][ 0 ]		= %DC_burning_stop_bleeding_medic_endidle;
	level._scr_anim[ "baker_firstaid" ][ "firstaid" ][ 0 ]	= %DC_burning_stop_bleeding_wounded_endidle;

	// vp hit secret service guy runs up and waves vp and Baker on
	level._scr_anim[ "secret_service1_vphit" ][ "vphit_ssrunup" ] = %nx_tp_hithard_vphit_run_ss1;

	// vp hit secret service waves vp loop
	level._scr_anim[ "secret_service1_vphit" ][ "vphit_hurry" ][0] = %nx_tp_hithard_vphit_hurryup_loop_ss1;

	// vp hit all four guys start in the vignette
	level._scr_anim[ "baker_vphit" ][ "vphit_start" ] = %nx_tp_hithard_vphit_baker;
	level._scr_anim[ "vp_vphit" ][ "vphit_start" ] = %nx_tp_hithard_vphit_vp;
	level._scr_anim[ "secret_service1_vphit" ][ "vphit_start" ] = %nx_tp_hithard_vphit_wavetoend_ss1;
	level._scr_anim[ "opfor_vphit" ][ "vphit_start" ] = %nx_tp_hithard_vphit_rpgshoot_opfor;

	// vp hit hurt loop
	level._scr_anim[ "vp_vphit" ][ "vphit_hurt_loop" ][0]			= %nx_tp_hithard_vphit_vphurt_loop_vp;
	level._scr_anim[ "vp_vphit" ][ "vphit_hurt_loop_dragged" ][0]	= %nx_tp_hithard_vphit_vphurt_loop_vp_end;
	level._scr_anim[ "baker_vphit" ][ "vphit_hurt_loop" ][0]		= %nx_tp_hithard_vphit_vphurt_loop_baker;

	// vp hit assist loop
	level._scr_anim[ "vp_vphit" ][ "vphit_assist_loop" ][0]		= %nx_tp_hithard_vphit_comehere_loop_vp;
	level._scr_anim[ "baker_vphit" ][ "vphit_assist_loop" ][0]	= %nx_tp_hithard_vphit_comehere_loop_baker;

	// Baker door kick
	level._scr_anim[ "baker" ][ "door_kick_in" ] = %door_kick_in;

	//Tank Lapes Unlatch
	level._scr_anim[ "lapes_unlatch_ally01" ][ "lapes_unlatch" ] = %nx_tp_hhh_tanklapes_unlatch_ally01;
	level._scr_anim[ "lapes_unlatch_ally02" ][ "lapes_unlatch" ] = %nx_tp_hhh_tanklapes_unlatch_ally02;

}

#using_animtree("vehicles");
vehicles()
{
	//Tank Lapes
	level._scr_anim[ "lapes_us_tank" ][ "new_tank_lapes" ] = %nx_vh_hhh_tanklapes_tank_01;
	addNotetrack_customFunction( "lapes_us_tank", "unhide_tank", ::Lapes_unhide_tank );
	level._scr_anim[ "bravo_tank" ][ "tank_climb" ] = %nx_vh_future_tank_loading;

}

#using_animtree("player");
player()
{
	// vp is drug up the ramp by first person to safty
	level._scr_animtree[ "player_rig" ] = #animtree;
	level._scr_anim[ "player_rig" ][ "vpdrag" ] = %nx_fp_hithard_vpdrag_player_01;
	level._scr_model[ "player_rig" ] = "viewhands_us_specops";
	level._scr_anim[ "player_rig" ][ "tank_climb" ] = %nx_fp_future_tank_loading;
}


dialog()
{
//	level._scr_sound[ "animname" ][ "yyy" ]			 = "yyy";
//	level._scr_radio[ "yyy" ] = "yyy";

	// Baker
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_01" ]				    = "hithard_bak_plaza_01";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_01" ]				    = "hithard_bak_plaza_01";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_02" ]				    = "hithard_bak_plaza_02";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_03" ]				    = "hithard_bak_plaza_03";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_04" ]				    = "hithard_bak_plaza_04";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_05" ]				    = "hithard_bak_plaza_05";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_06" ]				    = "hithard_bak_plaza_06";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_07" ]				    = "hithard_bak_plaza_07";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_08" ]				    = "hithard_bak_plaza_08";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_09" ]				    = "hithard_bak_plaza_09";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_10" ]				    = "hithard_bak_plaza_10";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_11" ]				    = "hithard_bak_plaza_11";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_12" ]				    = "hithard_bak_plaza_12";
	level._scr_radio[ "hithard_bak_plaza_12" ]				    = "hithard_bak_plaza_12";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_13" ]				    = "hithard_bak_plaza_13";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_14" ]				    = "hithard_bak_plaza_14";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_15" ]				    = "hithard_bak_plaza_15";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_16" ]				    = "hithard_bak_plaza_16";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza_17" ]				    = "hithard_bak_plaza_17";

	level._scr_sound[ "baker" ][ "hithard_bak_vp2_04" ]						= "hithard_bak_vp2_04";

	level._scr_sound[ "baker" ][ "hithard_bak_secure_21" ]						= "hithard_bak_secure_21";
	level._scr_sound[ "baker" ][ "hithard_bak_secure_49" ]						= "hithard_bak_secure_49";

	level._scr_sound[ "baker" ][ "hithard_bak_move_06" ]						= "hithard_bak_move_06";

	level._scr_sound[ "baker" ][ "hithard_bak_para_20" ] 						= "hithard_bak_para_20";

	level._scr_sound[ "baker" ][ "hithard_bak_mall_01" ]					 = "hithard_bak_mall_01";
	level._scr_sound[ "baker" ][ "hithard_bak_amb_38" ]				    = "hithard_bak_amb_38";
	level._scr_sound[ "baker" ][ "hithard_bak_mall_02" ]					 = "hithard_bak_mall_02";
	level._scr_sound[ "baker" ][ "hithard_bak_mall_03" ]					 = "hithard_bak_mall_03";
	level._scr_sound[ "baker" ][ "hithard_bak_mall_04" ]					 = "hithard_bak_mall_04";
	level._scr_sound[ "baker" ][ "hithard_bak_mall_05" ]					 = "hithard_bak_mall_05";
	level._scr_sound[ "baker" ][ "hithard_bak_mall_06" ]					 = "hithard_bak_mall_06";
	level._scr_sound[ "baker" ][ "hithard_bak_mall_07" ]					 = "hithard_bak_mall_07";
	level._scr_sound[ "baker" ][ "hithard_bak_mall_08" ]					 = "hithard_bak_mall_08";
	level._scr_sound[ "baker" ][ "hithard_bak_mall_09" ]					 = "hithard_bak_mall_09";
	level._scr_sound[ "baker" ][ "hithard_bak_mall_10" ]					 = "hithard_bak_mall_10";

	level._scr_radio[ "hithard_bak_plaza2_01" ]					 = "hithard_bak_plaza2_01";
	level._scr_radio[ "hithard_bak_plaza2_02" ]					 = "hithard_bak_plaza2_02";
	level._scr_radio[ "hithard_bak_plaza2_03" ]					 = "hithard_bak_plaza2_03";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza2_03" ]   = "hithard_bak_plaza2_03";
	level._scr_radio[ "hithard_bak_plaza2_04" ]					 = "hithard_bak_plaza2_04";
	level._scr_radio[ "hithard_bak_plaza2_05" ]					 = "hithard_bak_plaza2_05";
	level._scr_sound[ "baker" ][ "hithard_bak_plaza2_05" ]					 = "hithard_bak_plaza2_05";
	level._scr_radio[ "hithard_bak_plaza2_06" ]					 = "hithard_bak_plaza2_06";
	level._scr_radio[ "hithard_bak_plaza2_07" ]					 = "hithard_bak_plaza2_07";
	level._scr_radio[ "hithard_bak_plaza2_08" ]					 = "hithard_bak_plaza2_08";

	level._scr_radio[ "hithard_bak_mono_01" ]					 = "hithard_bak_mono_01";
	level._scr_radio[ "hithard_bak_mono_02" ]					 = "hithard_bak_mono_02";
	level._scr_radio[ "hithard_bak_mono_03" ]					 = "hithard_bak_mono_03";
	level._scr_radio[ "hithard_bak_move_02" ]					= "hithard_bak_move_02";

	level._scr_radio[ "hithard_bak_highway_01" ]					 = "hithard_bak_highway_01";
	level._scr_radio[ "hithard_bak_highway_02" ]					 = "hithard_bak_highway_02";
	level._scr_radio[ "hithard_bak_highway_03" ]					 = "hithard_bak_highway_03";
	level._scr_radio[ "hithard_bak_highway_04" ]					 = "hithard_bak_highway_04";
	level._scr_radio[ "hithard_bak_highway_05" ]					 = "hithard_bak_highway_05";
	level._scr_radio[ "hithard_bak_highway_06" ]					 = "hithard_bak_highway_06";
	level._scr_radio[ "hithard_bak_highway_07" ]					 = "hithard_bak_highway_07";
	level._scr_radio[ "hithard_bak_highway_08" ]					 = "hithard_bak_highway_08";
	level._scr_radio[ "hithard_bak_highway_09" ]					 = "hithard_bak_highway_09";
	level._scr_radio[ "hithard_bak_highway_10" ]					 = "hithard_bak_highway_10";
	level._scr_radio[ "hithard_bak_highway_11" ]					 = "hithard_bak_highway_11";
	level._scr_radio[ "hithard_bak_highway_12" ]					 = "hithard_bak_highway_12";

	level._scr_radio[ "hithard_bak_vp2_01" ]					 = "hithard_bak_vp2_01";
	level._scr_radio[ "hithard_bak_vp2_02" ]					 = "hithard_bak_vp2_02";
	level._scr_radio[ "hithard_bak_vp2_03" ]					 = "hithard_bak_vp2_03";
	level._scr_radio[ "hithard_bak_vp2_04" ]					 = "hithard_bak_vp2_04";
	level._scr_radio[ "hithard_bak_vp2_05" ]					 = "hithard_bak_vp2_05";
	level._scr_radio[ "hithard_bak_vp2_06" ]					 = "hithard_bak_vp2_06";

	level._scr_radio[ "hithard_bak_trans_01" ]					 = "hithard_bak_trans_01";
	level._scr_radio[ "hithard_bak_trans_02" ]					 = "hithard_bak_trans_02";
	level._scr_radio[ "hithard_bak_trans_03" ]					 = "hithard_bak_trans_03";
	level._scr_radio[ "hithard_bak_trans_04" ]					 = "hithard_bak_trans_04";

	level._scr_radio[ "hithard_bak_vphit_01" ]					 = "hithard_bak_vphit_01";
	level._scr_radio[ "hithard_bak_vphit_02" ]					 = "hithard_bak_vphit_02";
	level._scr_radio[ "hithard_bak_vphit_03" ]					 = "hithard_bak_vphit_03";
	level._scr_radio[ "hithard_bak_vphit_04" ]					 = "hithard_bak_vphit_04";
	level._scr_radio[ "hithard_bak_vphit_05" ]					 = "hithard_bak_vphit_05";
	level._scr_radio[ "hithard_bak_vphit_06" ]					 = "hithard_bak_vphit_06";
	level._scr_radio[ "hithard_bak_vphit_07" ]					 = "hithard_bak_vphit_07";
	level._scr_radio[ "hithard_bak_vphit_08" ]					 = "hithard_bak_vphit_08";
	level._scr_radio[ "hithard_bak_vphit_09" ]					 = "hithard_bak_vphit_09";
	level._scr_radio[ "hithard_bak_vphit_10" ]					 = "hithard_bak_vphit_10";
	level._scr_radio[ "hithard_bak_vphit_11" ]					 = "hithard_bak_vphit_11";
	level._scr_radio[ "hithard_bak_vphit_12" ]					 = "hithard_bak_vphit_12";
	level._scr_radio[ "hithard_bak_vphit_13" ]					 = "hithard_bak_vphit_13";
	level._scr_radio[ "hithard_bak_vphit_14" ]					 = "hithard_bak_vphit_14";
	level._scr_radio[ "hithard_bak_vphit_15" ] 					= "hithard_bak_vphit_15";
	level._scr_radio[ "hithard_bak_vphit_16" ] 					= "hithard_bak_vphit_16";

	level._scr_radio[ "hithard_bak_bravo_01" ]					 = "hithard_bak_bravo_01";
	level._scr_radio[ "hithard_bak_bravo_02" ]					 = "hithard_bak_bravo_02";

	level._scr_radio["hithard_bak_intro_15"]  						= "hithard_bak_intro_15";
	
	level._scr_radio[ "hithard_bak_para_20" ] 					= "hithard_bak_para_20";
	level._scr_radio[ "hithard_bak_move_07" ] 					= "hithard_bak_move_07";
	level._scr_sound[ "baker" ][ "hithard_bak_move_07" ] 					= "hithard_bak_move_07";

	level._scr_radio[ "hithard_bak_mall_09" ] 					= "hithard_bak_mall_09";
	
	// Duke
	level._scr_sound[ "gypsy" ][ "hithard_gyp_plaza_01" ]					= "hithard_gyp_plaza_01";
	level._scr_sound[ "gypsy" ][ "hithard_gyp_plaza_01" ]				    = "hithard_gyp_plaza_01";

	level._scr_sound[ "gypsy" ][ "hithard_gyp_plaza2_02" ] 				= "hithard_gyp_plaza2_02";
	level._scr_sound[ "gypsy" ][ "hithard_gyp_para_03" ] 					= "hithard_gyp_para_03";

	level._scr_radio[ "hithard_gyp_mono_02" ]					= "hithard_gyp_mono_02";
	level._scr_radio[ "hithard_gyp_move_02" ]					= "hithard_gyp_move_02";
	level._scr_radio[ "hithard_gyp_move_03" ]					= "hithard_gyp_move_03";
	level._scr_radio[ "hithard_gyp_move_06" ]					= "hithard_gyp_move_06";

	level._scr_sound[ "gypsy" ][ "hithard_gyp_mall_01" ]					 = "hithard_gyp_mall_01";
	level._scr_sound[ "gypsy" ][ "hithard_gyp_mall_02" ]					 = "hithard_gyp_mall_02";
	level._scr_sound[ "gypsy" ][ "hithard_gyp_mall_03" ]					 = "hithard_gyp_mall_03";
	level._scr_sound[ "gypsy" ][ "hithard_gyp_mall_04" ]					 = "hithard_gyp_mall_04";
	level._scr_sound[ "gypsy" ][ "hithard_gyp_mall_05" ]					 = "hithard_gyp_mall_05";
	level._scr_sound[ "gypsy" ][ "hithard_gyp_mall_06" ]					 = "hithard_gyp_mall_06";

	level._scr_radio[ "hithard_gyp_plaza2_01" ]					 = "hithard_gyp_plaza2_01";
	level._scr_radio[ "hithard_gyp_plaza2_02" ]					 = "hithard_gyp_plaza2_02";
	level._scr_radio[ "hithard_gyp_plaza2_03" ]					 = "hithard_gyp_plaza2_03";
	level._scr_radio[ "hithard_gyp_plaza2_04" ]					 = "hithard_gyp_plaza2_04";

	level._scr_radio[ "hithard_gyp_monorail_01" ]					 = "hithard_gyp_monorail_01";
	level._scr_sound[ "gypsy" ][ "hithard_gyp_monorail_01" ]					 = "hithard_gyp_monorail_01";

	level._scr_radio[ "hithard_gyp_mono_02" ]					 = "hithard_gyp_mono_02";

	level._scr_radio[ "hithard_bak_secure_37" ] 				= "hithard_bak_secure_37";

	level._scr_radio[ "hithard_gyp_highway_01" ]					 = "hithard_gyp_highway_01";
	level._scr_radio[ "hithard_gyp_highway_02" ]					 = "hithard_gyp_highway_02";
	level._scr_radio[ "hithard_gyp_highway_03" ] =					 "hithard_gyp_highway_03";

	level._scr_radio[ "hithard_gyp_vpmeet_01" ]					 = "hithard_gyp_vpmeet_01";
	level._scr_radio[ "hithard_gyp_vpmeet2_01" ]					 = "hithard_gyp_vpmeet2_01";

	level._scr_radio[ "hithard_gyp_intro_01" ] 						= "hithard_gyp_intro_01";

	level._scr_radio[ "hithard_gyp_kill_yell_03" ] 						= "hithard_gyp_kill_yell_03";

	// SS Lead
	level._scr_radio[ "hithard_sslead_mall_01" ]				    = "hithard_sslead_mall_01";
	level._scr_radio[ "hithard_sslead_mall_02" ]				    = "hithard_sslead_mall_02";

	level._scr_radio[ "hithard_sslead_plaza_01" ]				    = "hithard_sslead_plaza_01";
	level._scr_sound[ "ss_williams" ][ "hithard_sslead_plaza_02" ]				    = "hithard_sslead_plaza_02";

	level._scr_radio[ "hithard_sslead_plaza2_01" ]				    = "hithard_sslead_plaza2_01";

	level._scr_radio[ "hithard_sslead_monorail_01" ]			  = "hithard_sslead_monorail_01";
	
	level._scr_radio[ "hithard_sslead_highway_01" ]				 = "hithard_sslead_highway_01";
	level._scr_radio[ "hithard_sslead_highway_03" ]				 = "hithard_sslead_highway_03";
	level._scr_radio[ "hithard_sslead_vphit_death" ] = "hithard_sslead_vphit_death";


	// VP
	level._scr_radio[ "hithard_vp_mall_01" ]                         = "hithard_vp_mall_01";
	level._scr_radio[ "hithard_vp_plaza2_01" ]                      = "hithard_vp_plaza2_01";
	level._scr_radio["hithard_vp_trans_01"] = "hithard_vp_trans_01";
	level._scr_radio[ "hithard_vp_vphit_pain" ] = "hithard_vp_vphit_pain";

	// Bravo team
	level._scr_radio["hithard_bak_bravo_02"] = "hithard_bak_bravo_02";
	level._scr_radio["hithard_btl_bravo_01"] = "hithard_btl_bravo_01";
	level._scr_radio["hithard_btl_bravo_02"] = "hithard_btl_bravo_02";
	level._scr_radio["hithard_gyp_bravo_01"] = "hithard_gyp_bravo_01";
	level._scr_radio["hithard_btl_bravo_03"] = "hithard_btl_bravo_03";
	level._scr_radio["hithard_sis_bravoco_01"] = "hithard_sis_bravoco_01";
	level._scr_radio["hithard_btl_bravo_04"] = "hithard_btl_bravo_04";
	level._scr_radio["hithard_btl_bravo_05"] = "hithard_btl_bravo_05";	

	level._scr_radio["hithard_ovl_trans_01"] = "hithard_ovl_trans_01";
	level._scr_radio["hithard_ovl_trans_02"] = "hithard_ovl_trans_02";
	level._scr_radio["hithard_tfp_intro_09"] = "hithard_tfp_intro_09";
	level._scr_radio["hithard_btl_trans_01"] = "hithard_btl_trans_01";
	level._scr_radio["hithard_btl_mono_01"] = "hithard_btl_mono_01";



	level._scr_radio[ "hithard_bravoradioop_highway_01" ] = "hithard_bravoradioop_highway_01";
	level._scr_radio[ "hithard_sis_bravoco_01" ] = "hithard_sis_bravoco_01";
	level._scr_radio[ "hithard_sis_bravoco_02" ] = "hithard_sis_bravoco_02";
	level._scr_radio[ "hithard_btl_bravo_06" ] = "hithard_btl_bravo_06";
	level._scr_radio[ "hithard_btl_bravo_09" ] = "hithard_btl_bravo_09";
	level._scr_radio[ "hithard_btl_bravo_07" ] = "hithard_btl_bravo_07";
	level._scr_radio[ "hithard_btl_bravo_08" ] = "hithard_btl_bravo_08";
	level._scr_radio[ "hithard_bak_bravo_03" ] = "hithard_bak_bravo_03";
	level._scr_radio[ "hithard_bak_bravo_04" ] = "hithard_bak_bravo_04";
	level._scr_radio[ "hithard_bak_bravo_05" ] = "hithard_bak_bravo_05";

	// enemies
	level._scr_sound[ "hall_shooter" ][ "hithard_ecso_mall_01" ] = "hithard_ecso_mall_01";
	level._scr_sound[ "hall_shooter" ][ "hithard_ecso_mall_02" ] = "hithard_ecso_mall_02";
	level._scr_sound[ "hall_shooter" ][ "hithard_ecso_mall_03" ] = "hithard_ecso_mall_03";
	level._scr_sound[ "hall_shooter" ][ "hithard_ecso_mall_04" ] = "hithard_ecso_mall_04";
	level._scr_sound[ "hall_shooter" ][ "hithard_ecso_mall_05" ] = "hithard_ecso_mall_05";
	level._scr_sound[ "civ1" ][ "hithard_civ1_mall_01" ] = "hithard_civ1_mall_01";
	level._scr_sound[ "civ1" ][ "hithard_civ1_mall_02" ] = "hithard_civ1_mall_02";
	level._scr_sound[ "civ1" ][ "hithard_civ1_mall_03" ] = "hithard_civ1_mall_03";
	level._scr_sound[ "civ1" ][ "hithard_civ1_mall_04" ] = "hithard_civ1_mall_04";
	level._scr_sound[ "civ2" ][ "hithard_civ2_mall_01" ] = "hithard_civ2_mall_01";
	level._scr_sound[ "civ2" ][ "hithard_civ2_mall_02" ] = "hithard_civ2_mall_02";
	level._scr_sound[ "gypsy" ][ "hithard_gyp_mall_07" ] = "hithard_gyp_mall_07";
	level._scr_sound[ "baker" ][ "hithard_bak_mall_11" ] = "hithard_bak_mall_11";



}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//New tank LAPES

tank_lapes_setup()
{
	if( !IsDefined( level.lapes_models ) )
		level.lapes_models = [];

	tank_lapes_setup_add_model( "lapes_c102" );
	tank_lapes_setup_add_model( "lapes_tank", true );
	tank_lapes_setup_add_model( "lapes_bus", true );
	tank_lapes_setup_add_model( "lapes_bus2", true );
	tank_lapes_setup_add_model( "lapes_sedan01" , true );
	tank_lapes_setup_add_model( "lapes_car01" );
	tank_lapes_setup_add_model( "lapes_car02" );
	tank_lapes_setup_add_model( "lapes_car03" );
	tank_lapes_setup_add_model( "lapes_car04" );
	tank_lapes_setup_add_model( "lapes_car05" );
	tank_lapes_setup_add_model( "lapes_car06" );
	tank_lapes_setup_add_model( "lapes_car07" );
	tank_lapes_setup_add_model( "lapes_car08" );
	tank_lapes_setup_add_model( "lapes_car09", true );
	tank_lapes_setup_add_model( "lapes_car10", true );
	tank_lapes_setup_add_model( "lapes_car11" );
	tank_lapes_setup_add_model( "lapes_fx" );
	tank_lapes_setup_add_model( "lapes_dragchute" );
	tank_lapes_setup_add_model( "lapes_lights" );
	tank_lapes_setup_add_model( "lapes_pallet" );

	node = getstruct("vinette_tank_lapes", "script_noteworthy");

	node anim_first_frame( level.lapes_models, "new_tank_lapes" );
}

tank_lapes_setup_add_model( model_name, can_damage_player )
{
	model = spawn_anim_model( model_name );
	level.lapes_models[ model_name ] = model;
	model.radius = 128;
	model Solid();
	if( IsDefined( can_damage_player ) && can_damage_player )
	{
//  	RYAN: uncomment these lines when the damage notetracks are in for each model
//  	addNotetrack_customFunction( model_name, "player_damage_start", ::tank_lapes_damage_start, "new_tank_lapes" );
//  	addNotetrack_customFunction( model_name, "player_damage_end", ::tank_lapes_damage_end, "new_tank_lapes" );

	}
}

tank_lapes_damage_start()	{	self notify( "tank_lapes_damage_start" );	}
tank_lapes_damage_end()		{	self notify( "tank_lapes_damage_end" );	}

tank_lapes_damage( model )
{
// RYAN: uncomment these lines when the damage notetracks are in for each model
//  self waittill( "tank_lapes_damage_start" );
//  self endon( "tank_lapes_damage_end" );
	self endon( "new_tank_lapes" );

	while( 1 )
	{
		if( level._player IsTouching( model ) )
			level._player DoDamage( 50, model.origin, level._player );

		wait 0.05;
	}
}

new_tank_lapes_spawn()
{
	lapes_us_tank = vignette_vehicle_spawn("vehicle_nx_future_tank_lapes", "lapes_us_tank"); //"value" (kvp), "anim_name"

	new_tank_lapes(lapes_us_tank);

	//lapes_us_tank vignette_vehicle_delete();
}


new_tank_lapes(lapes_us_tank)
{
//  lapes_us_tank.animname = "lapes_us_tank";

	node = getstruct("vinette_tank_lapes", "script_noteworthy");

	//node anim_first_frame(guys, "new_tank_lapes");
	level thread ent_earthquake( level.lapes_models[ "lapes_c102" ], 0.12, 13, 10000 );

	level.lapes_models[ "lapes_bus2" ] Hide();
	//lapes_dragchute Hide();
	level.lapes_models[ "lapes_tank" ] Hide();
	level.lapes_models[ "lapes_pallet" ] Hide();

	foreach( model in level.lapes_models )
	{
		node thread tank_lapes_damage( model );
	}

	thread lapes_fx( level.lapes_models[ "lapes_fx" ], level.lapes_models[ "lapes_c102" ] );

	//lapes_us_tank suspend_drive_anims_for_vignette();

	//lapes_us_tank mgoff();

	//vehicle_kill_treads_forever();

	node anim_single( level.lapes_models, "new_tank_lapes");

	level.lapes_models[ "lapes_c102" ] Delete();
	//lapes_dragchute Delete();
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

Lapes_bus_swap( lapes_bus )
	{
		lapes_bus Hide();
	}

Lapes_bus_swap2( lapes_bus2 )
	{
		lapes_bus2 Show();
	}

Lapes_dragchute_unhide ( lapes_dragchute )
	{
		//lapes_dragchute Show();
	}

Lapes_unhide_tank ( lapes_tank )
	{
		lapes_tank Show();
	}

Lapes_unhide_pallet ( lapes_pallet )
	{
		lapes_pallet Show();
	}

// FX
lapes_fx( lapes_fx, lapes_c102 )
{
	//wait 1;

	//c102 blinking lights
	PlayFXOnTag( getfx( "aircraft_light_wingtip_green" ), lapes_c102, "tag_fx_wing_l_green_steady" );
	PlayFXOnTag( getfx( "aircraft_light_wingtip_red" ), lapes_c102, "tag_fx_wing_r_red_steady" );
	PlayFXOnTag( getfx( "aircraft_light_white_blink" ), lapes_c102, "tag_fx_tail_white_blinking" );
	PlayFXOnTag( getfx( "aircraft_light_red_blink" ), lapes_c102, "tag_fx_belly_red_doubleblink" );

	wait 8;
//engine smoke swirls
	for ( i = 0 ; i < 3 ; i++ )
	{
		PlayFXOnTag( getfx("nx_smoke_swirls_lapes_c102" ), lapes_c102, "tag_fx_enginesmoke_01" );
		wait( RandomFloatRange( 0.1, 0.5 ) );
		PlayFXOnTag( getfx("nx_smoke_swirls_lapes_c102" ), lapes_c102, "tag_fx_enginesmoke_02" );
		wait( RandomFloatRange( 0.2, 0.3 ) );
		PlayFXOnTag( getfx("nx_smoke_swirls_lapes_c102" ), lapes_c102, "tag_fx_enginesmoke_03" );
		wait( RandomFloatRange( 0.3, 0.5 ) );
		PlayFXOnTag( getfx("nx_smoke_swirls_lapes_c102" ), lapes_c102, "tag_fx_enginesmoke_04" );
		wait( RandomFloatRange( 0.8, 1.6 ) );
	}


	//wait( RandomFloat( 1.3 ) );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//LAPES Unlatch

lapes_unlatch_spawn()
{
	lapes_unlatch_ally01 = vignette_actor_spawn("bravo_ally01", "lapes_unlatch_ally01"); //"value" (kvp), "anim_name"
	lapes_unlatch_ally02 = vignette_actor_spawn("bravo_ally02", "lapes_unlatch_ally02"); //"value" (kvp), "anim_name"

	lapes_unlatch(lapes_unlatch_ally01, lapes_unlatch_ally02);

	lapes_unlatch_ally01 vignette_actor_delete();
	lapes_unlatch_ally02 vignette_actor_delete();
}

lapes_unlatch(lapes_unlatch_ally01, lapes_unlatch_ally02)
{
	lapes_unlatch_ally01.animname = "lapes_unlatch_ally01";
	lapes_unlatch_ally02.animname = "lapes_unlatch_ally02";

	node = getstruct("vinette_tank_lapes", "script_noteworthy");

	lapes_pallet_unlatch = spawn_anim_model("lapes_pallet_unlatch");

	lapes_tank_unlatch = spawn_anim_model("lapes_tank_unlatch");


	guys = [];
	guys["lapes_pallet_unlatch"] = lapes_pallet_unlatch;
	guys["lapes_unlatch_ally01"] = lapes_unlatch_ally01;
	guys["lapes_unlatch_ally02"] = lapes_unlatch_ally02;
	guys["lapes_tank_unlatch"] = lapes_tank_unlatch;


	node anim_reach( [ lapes_unlatch_ally01, lapes_unlatch_ally02 ], "lapes_unlatch");
	node anim_single(guys, "lapes_unlatch");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// vp gets hit running up highway ramp
vphit_spawn()
{
	baker_vphit = vignette_actor_spawn("baker_vphit", "baker_vphit"); //"value" (kvp), "anim_name"
	vp_vphit = vignette_actor_spawn("vp_vphit", "vp_vphit"); //"value" (kvp), "anim_name"
	secret_service1_vphit = vignette_actor_spawn("secret_service1_vphit", "secret_service1_vphit"); //"value" (kvp), "anim_name"

	vphit(baker_vphit, vp_vphit, secret_service1_vphit);

	baker_vphit vignette_actor_delete();
	vp_vphit vignette_actor_delete();
	secret_service1_vphit vignette_actor_delete();
}

vphit( baker_vphit, vp_vphit, secret_service1_vphit )
{

	baker_vphit.animname			= "baker_vphit";
	vp_vphit.animname 				= "vp_vphit";
	secret_service1_vphit.animname	= "secret_service1_vphit";

	node = getstruct( "vignette_play_hithard_vphit", "script_noteworthy" );

	guys = [];
	guys["baker_vphit"] = baker_vphit;
	guys["vp_vphit"] = vp_vphit;
	guys["secret_service1_vphit"] = secret_service1_vphit;
	
	node anim_first_frame(guys, "vphit");

	node anim_single(guys, "vphit");

	secret_service1_vphit stop_magic_bullet_shield();
	secret_service1_vphit Kill( );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// vp is drug up the ramp by first person to safty
vpdrag_spawn()
{
	baker_vpdrag = vignette_actor_spawn("baker_vpdrag", "baker_vpdrag"); //"value" (kvp), "anim_name"
	vp_vpdrag = vignette_actor_spawn("vp_vpdrag", "vp_vpdrag"); //"value" (kvp), "anim_name"

	vpdrag(baker_vpdrag, vp_vpdrag);

	baker_vpdrag vignette_actor_delete();
	vp_vpdrag vignette_actor_delete();
}

vpdrag( baker_vpdrag, vp_vpdrag )
{
	baker_vpdrag.animname = "baker_vpdrag";
	vp_vpdrag.animname = "vp_vpdrag";

	node = getstruct( "vignette_play_hithard_vpdrag", "script_noteworthy" );

	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player disableweapons();
//  level._player takeallweapons();
	level._player HideViewModel();
	level._player EnableInvulnerability();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["vp_vpdrag"]	= vp_vpdrag;
	guys["player_rig"]	= player_rig;
	arc = 15;
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	//blood smear fx
	thread maps\nx_hithard_b_fx::vphit_dyingCrawlBloodSmear( vp_vpdrag );

	node thread vpdrag_baker( baker_vpdrag );
	node anim_single( guys, "vpdrag" );
	level notify( "vp_drag_complete" );
	level thread vpdrag_end_vp( vp_vpdrag );

	level._player unlink();
	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player EnableWeapons();
	level._player ShowViewModel();
	level._player DisableInvulnerability();
}

vpdrag_end_vp( vp )
{
	node = getstruct( "vignette_play_hithard_vpdrag", "script_noteworthy" );
	vp.animname = "vp_vphit";

	node thread anim_loop_solo( vp, "vphit_hurt_loop_dragged" );
//
//  node thread anim_single_solo( vp, "vpdrag" );
//  drag_anim = vp getanim( "vpdrag" );
//  vp SetAnimTime( drag_anim, 1 );
//  node anim_set_rate_single( vp, "vpdrag", 0.0 );
}

vpdrag_baker( baker )
{
	self anim_single_solo( baker, "vpdrag_start" );
	baker thread vpdrag_baker_protect();
//  wait 20.0;
//  self notify( "vp_drag_complete" );
	level waittill( "vp_drag_complete" );
	self anim_reach_solo( baker, "vpdrag_end" );
	self anim_single_solo( baker, "vpdrag_end" );
}

vpdrag_baker_protect()
{
	self endon( "vp_drag_complete" );

	if(IsDefined( level.ugv ) )
		self SetLookAtEntity( level.ugv );

	self SetGoalNode( GetNode( "onramp_baker_protect_01", "script_noteworthy") );
	wait 4.0;
	self SetGoalNode( GetNode( "onramp_baker_protect_02", "script_noteworthy") );
	wait 4.0;
	self SetGoalNode( GetNode( "onramp_baker_protect_03", "script_noteworthy") );
	wait 4.0;
	self SetGoalNode( GetNode( "onramp_baker_protect_04", "script_noteworthy") );
	wait 4.0;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Bravp company meet and greet
bravomeetgreet_spawn()
{
	bravoc_bravomeet = vignette_actor_spawn("bravoc_bravomeet", "bravoc_bravomeet"); //"value" (kvp), "anim_name"
	duke_bravomeet = vignette_actor_spawn("duke_bravomeet", "duke_bravomeet"); //"value" (kvp), "anim_name"

	bravomeetgreet(bravoc_bravomeet, duke_bravomeet);

	bravoc_bravomeet	vignette_actor_delete();
	duke_bravomeet		vignette_actor_delete();
}

bravomeetgreet_duke_reach( duke_bravomeet )
{
	duke_bravomeet.animname 	= "duke_bravomeet";
	node = getstruct( "vignette_node_bravomeetgreet", "script_noteworthy" );
	node anim_reach_solo( duke_bravomeet, "bravomeetgreet" );
}

bravomeetgreet( bravoc_bravomeet, duke_bravomeet )
{
	bravoc_bravomeet.animname 	= "bravoc_bravomeet";
	duke_bravomeet.animname 	= "duke_bravomeet";

	node = getstruct( "vignette_node_bravomeetgreet", "script_noteworthy" );

	guys = [];
	guys[ "bravoc_bravomeet" ]	= bravoc_bravomeet;
	guys[ "duke_bravomeet" ] 	= duke_bravomeet;

	node anim_reach( guys, "bravomeetgreet" );
	flag_wait( "player_meet_bravo" );
	node anim_single(guys, "bravomeetgreet");
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
vp_firstaid_loop( baker_firstaid, vp_firstaid )
{
	baker_firstaid.animname 	= "baker_firstaid";
	vp_firstaid.animname 		= "vp_firstaid";

	node = GetEnt( "onramp_vp_injured_node", "targetname" );

	guys = [];
	guys["baker_firstaid"]	= baker_firstaid;
	guys["vp_firstaid"]		= vp_firstaid;

	node anim_loop( guys, "firstaid" );
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// vp hit secret service guy runs up and waves vp and Baker on
vphit_ssrunup_spawn()
{
	secret_service1_vphit = vignette_actor_spawn("secret_service1_vphit", "secret_service1_vphit"); //"value" (kvp), "anim_name"

	vphit_ssrunup(secret_service1_vphit);

	secret_service1_vphit vignette_actor_delete();
}

vphit_ssrunup(secret_service1_vphit, vp_vphit, baker_vphit)
{

	node = getstruct("vignette_play_hithard_vphit", "script_noteworthy");

	secret_service1_vphit.animname = "secret_service1_vphit";
	vp_vphit.animname = "vp_vphit";
	baker_vphit.animname = "vp_vphit";

	guys = [];
	guys["secret_service1_vphit"] = secret_service1_vphit;

	node anim_reach(guys, "vphit_ssrunup");
	node thread vphit_start_reach( baker_vphit, vp_vphit );
	node thread anim_single(guys, "vphit_ssrunup");
	node waittill( "vphit_ssrunup" );
	node thread anim_loop( guys, "vphit_hurry" );
}

vphit_start_reach( baker_vphit, vp_vphit )
{
	self thread anim_reach_solo( vp_vphit, "vphit_start" );
	wait 0.5;
	self thread anim_reach_solo( baker_vphit, "vphit_start" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// vp hit all four guys start in the vignette
vphit_start_spawn()
{
	baker_vphit = vignette_actor_spawn("baker_vphit", "baker_vphit"); //"value" (kvp), "anim_name"
	vp_vphit = vignette_actor_spawn("vp_vphit", "vp_vphit"); //"value" (kvp), "anim_name"
	secret_service1_vphit = vignette_actor_spawn("secret_service1_vphit", "secret_service1_vphit"); //"value" (kvp), "anim_name"
	opfor_vphit = vignette_actor_spawn("opfor_vphit", "opfor_vphit"); //"value" (kvp), "anim_name"

	vphit_start(baker_vphit, vp_vphit, secret_service1_vphit, opfor_vphit);

	baker_vphit vignette_actor_delete();
	vp_vphit vignette_actor_delete();
	secret_service1_vphit vignette_actor_delete();
	opfor_vphit vignette_actor_delete();
}

vphit_start( baker_vphit, vp_vphit, secret_service1_vphit )
{

	node = getstruct("vignette_play_hithard_vphit", "script_noteworthy");

	baker_vphit.animname				=	"baker_vphit";
	vp_vphit.animname					=	"vp_vphit";
	secret_service1_vphit.animname		=	"secret_service1_vphit";
//  opfor_vphit.animname				=	"opfor_vphit";

	vp_vphit.ignoreAll					=	true;
	secret_service1_vphit.ignoreAll		= 	true;
//  opfor_vphit.ignoreMe				= 	true;
//  opfor_vphit.ignoreAll				= 	true;

	guys = [];
	guys["baker_vphit"] = baker_vphit;
	guys["vp_vphit"] = vp_vphit;
	guys["secret_service1_vphit"] = secret_service1_vphit;
//  guys["opfor_vphit"] = opfor_vphit;

//  node anim_first_frame(guys, "vphit_start");

	node anim_reach( guys, "vphit_start" );
	level notify( "vp_hit_moment" );
	vp_vphit thread vphit_injured_swap( );
	node anim_single( guys, "vphit_start" );

	secret_service1_vphit vignette_actor_kill();
//  opfor_vphit vignette_actor_kill();
}

vphit_injured_swap( )
{
	wait 3.0;
	vp_injured = GetEnt( "vp_injured_spawner", "targetname" ) spawn_ai();

	if( IsDefined( vp_injured ) )
	{
		self SetModel( vp_injured.model );
		self Detach( self.headmodel );
		self.headmodel =  vp_injured.headmodel;
		self Attach( self.headmodel );
	}

	vp_injured Delete();

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
vphit_hurt_loop(baker_vphit, vp_vphit)
{

	node = getstruct("vignette_play_hithard_vphit", "script_noteworthy");

	baker_vphit.animname				=	"baker_vphit";
	vp_vphit.animname					=	"vp_vphit";

//  vp_vphit.ignoreAll					=	true;
//  secret_service1_vphit.ignoreAll		= 	true;
//  opfor_vphit.ignoreMe				= 	true;
//  opfor_vphit.ignoreAll				= 	true;

	guys = [];
	guys["baker_vphit"] = baker_vphit;
	guys["vp_vphit"] = vp_vphit;

	node thread anim_loop( guys, "vphit_hurt_loop", "vp_critical_moment" );

	return node;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
vphit_assist_loop( baker_vphit, vp_vphit )
{

	node = getstruct( "vignette_play_hithard_vphit", "script_noteworthy" );

	baker_vphit.animname				=	"baker_vphit";
	vp_vphit.animname					=	"vp_vphit";

	guys = [];
	guys["baker_vphit"] = baker_vphit;
	guys["vp_vphit"] = vp_vphit;

	node thread anim_loop( guys, "vphit_assist_loop", "vp_drag_moment" );

	return node;
}

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


//*******************************************************************
//         FX SECTION                                               *
//                                                                  *
//*******************************************************************

fx_cleanup()
{
	flag_wait( "fx_back_half_turn_off" );

	fx_delete_createFXEnt_by_vol( "fx_back_half", false );
	fx_delete_createFXEnt_by_vol( "fx_plaza_backcorner_crater", false );
//	fx_delete_createFXEnt_by_vol( "fx_escalator_deadend", false );

	flag_wait( "jungle_enc_moveup_mid" );

	fx_delete_createFXEnt_by_vol( "fx_intro_uav_hall", false );
	fx_restart_createFXEnt_by_vol( "fx_plaza_backcorner_crater" );
//	fx_restart_createFXEnt_by_vol( "fx_escalator_deadend" );

	flag_wait( "fx_back_half_turn_on" );

	fx_restart_createFXEnt_by_vol( "fx_back_half" );
	fx_delete_createFXEnt_by_vol( "fx_front_half", true );
	fx_delete_createFXEnt_by_vol( "fx_plaza_backcorner_crater", true );
}


