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
#include maps\_nx_vignette_util;

main()
{
	generic_human();

	player_anims();

	script_models();

	level thread vignettes();

	dialogue();
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignettes()
{
//	level thread vignette_register( ::intro_keene_spawn, "intro_keene" );	

//	level thread vignette_register( ::intro_spawn, "vignette_intro" );

//	level thread vignette_register( ::corner_kill_spawn, "vignette_corner_kill" );


	//level thread vignette_register( ::radio_run_spawn, "vignette_radio_run" );

	//level thread vignette_register( ::outro_spawn, "vignette_outro" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree("generic_human");
generic_human()
{
	// Intro Vignette
	level._scr_anim[ "intro_ally_01" ][ "intro" ] = %nx_tp_hospital_intro_ally_01; 
	level._scr_anim[ "intro_ally_02" ][ "intro" ] = %nx_tp_hospital_intro_ally_02;

	level._scr_anim[ "ally_alpha" ][ "intro" ] = %nx_tp_hospital_intro_ally_01;
	level._scr_anim[ "ally_bravo" ][ "intro" ] = %nx_tp_hospital_intro_ally_02;
	level._scr_anim[ "stealth_enemy" ][ "intro" ] = %nx_tp_hospital_intro_opfor;
	
	// Intro Keene
	level._scr_anim[ "intro_keene" ][ "intro_keene" ] = %nx_tp_hospital_intro_ally_02;
	level._scr_anim[ "intro_opfor" ][ "intro_keene" ] = %nx_tp_hospital_intro_opfor;

	//Outro Vignette
	level._scr_anim[ "ally_alpha" ][ "outro" ] = %nx_tp_hospital_outro_ally_01;
	addNotetrack_customFunction( "ally_alpha", "switch_primary_gun", ::switch_primary_gun, "outro" );

	level._scr_anim[ "ally_bravo" ][ "outro" ] = %nx_tp_hospital_outro_ally_02;
	level._scr_anim[ "vignette_outro_doctor" ][ "outro" ] = %nx_tp_hospital_outro_doctor;
	level._scr_anim[ "vignette_outro_opfor" ][ "outro" ] = %nx_tp_hospital_outro_opfor;

	//Stealth Kills
	level._scr_anim[ "sleeping_guard" ][ "stealth_kill_sleeping_death" ] = %nx_tp_hospital_stealth_kill_sleeping_opfor_01;
	level._scr_anim[ "sleeping_guard" ][ "stealth_kill_sleeping" ][0] = %nx_tp_hospital_stealth_kill_sleeping_opfor_01_loop;
	level._scr_anim[ "surprised_guard" ][ "stealth_kill_sleeping_surprised" ] = %nx_tp_hospital_stealth_kill_sleeping_opfor_02;

	level._scr_anim[ "reloading_guard" ][ "stealth_kill_reloading_death" ] = %nx_tp_hospital_stealth_kill_reloading_opfor;
	level._scr_anim[ "reloading_guard" ][ "stealth_kill_reloading" ][0] = %nx_tp_hospital_stealth_kill_reloading_opfor_loop;
	level._scr_anim[ "radio_run_opfor" ][ "radio_run" ] = %nx_tp_hospital_radio_run_opfor;
	
	level._scr_anim[ "corner_kill_opfor" ][ "corner_kill" ] = %nx_tp_hospital_corner_kill_opfor;
	level._scr_anim[ "corner_kill_baker" ][ "corner_kill" ] = %nx_tp_hospital_corner_kill_baker;
	level._scr_anim[ "corner_kill_baker" ][ "corner_kill_intro" ] = %nx_tp_hospital_corner_kill_baker_intro;
	level._scr_anim[ "corner_kill_baker" ][ "corner_kill_loop" ][0] = %nx_tp_hospital_corner_kill_baker_loop;

	// Grenade Throw
	level._scr_anim[ "generic" ][ "grenade_throw" ] = %favela_chaotic_cornerR_grenade;
	
	level._scr_anim[ "ally_alpha" ][ "corner_kill" ] = %nx_tp_hospital_corner_kill_baker;
	level._scr_anim[ "ally_alpha" ][ "corner_kill_intro" ] = %nx_tp_hospital_corner_kill_baker_intro;
	level._scr_anim[ "ally_alpha" ][ "corner_kill_loop" ][0] = %nx_tp_hospital_corner_kill_baker_loop;
	level._scr_anim[ "stealth_enemy" ][ "corner_kill" ] = %nx_tp_hospital_corner_kill_opfor;
	
	// Door Kick
	level._scr_anim[ "generic" ][ "door_kick_in" ] = 					%doorkick_2_cqbwalk;
	
	level._scr_anim[ "stealth_enemy" ][ "smoking_loop" ][0] =				%patrol_bored_idle_smoke;
	level._scr_anim[ "stealth_enemy" ][ "spotter" ][0] 		=				%roadkill_cover_spotter_idle;
	level._scr_anim[ "stealth_enemy" ][ "clipboard_react" ] =				%cargoship_stunned_clipboard_react;
	level._scr_anim[ "stealth_enemy" ][ "clipboard_death" ] =				%cargoship_stunned_clipboard_death;
	
	level._scr_anim[ "talking_guard_01" ][ "talking" ] =		%coup_talking_patrol_guy1;
	level._scr_anim[ "talking_guard_02" ][ "talking" ] =		%coup_talking_patrol_guy2;

	level._scr_anim[ "stealth_enemy" ][ "dead_01" ] =				%arcadia_ending_sceneA_enemy2_death_pose;//%arcadia_ending_sceneA_dead_civilian;
	
	level._scr_anim[ "generic" ][ "surprise_reaction_01" ] = %patrol_bored_react_look_v1;
	level._scr_anim[ "generic" ][ "surprise_reaction_02" ] = %patrol_bored_react_look_v2;
	level._scr_anim[ "generic" ][ "surprise_reaction_03" ] = %patrol_bored_react_look_retreat;
	level._scr_anim[ "generic" ][ "surprise_reaction_04" ] = %patrolstand_look;
	
	level._scr_anim[ "generic" ][ "surprise_reaction_patrol_01" ] = %patrol_bored_react_walkstop;
	level._scr_anim[ "generic" ][ "surprise_reaction_patrol_02" ] = %patrol_bored_react_walkstop_short;

	level._scr_anim[ "generic" ][ "patrol_walk_flashlight_01" ]		= %active_patrolwalk_v3;
	level._scr_anim[ "generic" ][ "patrol_walk_flashlight_02" ]		= %active_patrolwalk_v4;
	level._scr_anim[ "generic" ][ "patrol_walk_flashlight_03" ]		= %active_patrolwalk_v5;
	level._scr_anim[ "generic" ][ "patrol_walk_flashlight_04" ]		= %active_patrolwalk_v2;
	
	
}

#using_animtree("player");
player_anims()
{
	//Intro Vignette
	level._scr_animtree[ "player_rig" ] = #animtree;
	level._scr_anim[ "player_rig" ][ "intro" ] = %nx_fp_hospital_intro_player;
	level._scr_model[ "player_rig" ] = "viewhands_delta";

	//Outro Vignette
	level._scr_anim[ "player_rig" ][ "outro" ] = %nx_fp_hospital_outro_player;
	
}

#using_animtree("script_model");
script_models()
{
	//Reloading Vignette 
	level._scr_animtree[ "reloading_airport" ] = #animtree;
	level._scr_anim[ "reloading_airport" ][ "stealth_kill_reloading_death" ] = %nx_pr_hospital_stealth_kill_reloading_table;
	level._scr_anim[ "reloading_airport" ][ "stealth_kill_reloading" ][0] = %nx_pr_hospital_stealth_kill_reloading_table_loop;
	level._scr_model[ "reloading_airport" ] = "furniture_table1_airport";

	level._scr_animtree[ "reload_clip_01" ] = #animtree;
	level._scr_anim[ "reload_clip_01" ][ "stealth_kill_reloading_death" ] = %nx_pr_hospital_stealth_kill_reloading_magazine;
	level._scr_anim[ "reload_clip_01" ][ "stealth_kill_reloading" ][0] = %nx_pr_hospital_stealth_kill_reloading_magazine_loop;
	level._scr_model[ "reload_clip_01" ] = "weapon_m4_clip";

	level._scr_animtree[ "reload_clip_02" ] = #animtree;
	level._scr_anim[ "reload_clip_02" ][ "stealth_kill_reloading_death" ] = %nx_pr_hospital_stealth_kill_reloading_magazine_02;
	level._scr_anim[ "reload_clip_02" ][ "stealth_kill_reloading" ][0] = %nx_pr_hospital_stealth_kill_reloading_magazine_02_loop;
	level._scr_model[ "reload_clip_02" ] = "weapon_m4_clip";

	// Radio Run - Radio Prop
	level._scr_animtree[ "radio_run_radio" ] = #animtree;
	level._scr_anim[ "radio_run_radio" ][ "radio_run" ] = %nx_pr_hospital_radio_run_radio;
	level._scr_model[ "radio_run_radio" ] = "com_hand_radio";

	// Outro
	level._scr_animtree[ "outro_ventilator" ] = #animtree;
	level._scr_anim[ "outro_ventilator" ][ "outro" ] = %nx_pr_hospital_outro_ventilator;
	level._scr_model[ "outro_ventilator" ] = "nx_hospital_respirator_animated";

	level._scr_animtree[ "outro_rifle" ] = #animtree;
	level._scr_anim[ "outro_rifle" ][ "outro" ] = %nx_pr_hospital_outro_rifle;
	level._scr_model[ "outro_rifle" ] = "weapon_m4";
	addNotetrack_customFunction( "outro_rifle", "rifle_model_on", ::rifle_model_on, "outro" );

	level._scr_animtree[ "outro_blood" ] = #animtree;
	level._scr_anim[ "outro_blood" ][ "outro" ] = %nx_pr_hospital_outro_blood;
	level._scr_model[ "outro_blood" ] = "nx_hospital_bed_blood";
	addNotetrack_customFunction( "outro_blood", "blood_splatter_on", ::blood_splatter_on, "outro" );

	level._scr_animtree[ "outro_tubes" ] = #animtree;
	level._scr_anim[ "outro_tubes" ][ "outro" ] = %nx_pr_hospital_outro_tubes;
	level._scr_model[ "outro_tubes" ] = "nx_tubes";


	level._scr_animtree[ "outro_bullet_wound" ] = #animtree;
	level._scr_anim[ "outro_bullet_wound" ][ "outro" ] = %nx_pr_hospital_outro_bullet_wound;
	level._scr_model[ "outro_bullet_wound" ] = "nx_hospital_bullethole";
	addNotetrack_customFunction( "outro_bullet_wound", "bullet_wound_on", ::bullet_wound_on, "outro" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


intro_spawn()
{
//	intro_ally_01 = vignette_actor_spawn("vignette_intro_ally_01", "intro_ally_01"); //"value" (kvp), "anim_name"
//	intro_ally_02 = vignette_actor_spawn("vignette_intro_ally_02", "intro_ally_02"); //"value" (kvp), "anim_name"
//
//	intro(intro_ally_01, intro_ally_02);
//
//	intro_ally_01 vignette_actor_delete();
//	intro_ally_02 vignette_actor_delete();
	
	intro(level.squad["ALLY_ALPHA"], level.squad["ALLY_BRAVO"]);
}

intro( intro_ally_01 )
{

	node = getstruct("vignette_intro", "script_noteworthy");

	guys = [];
	guys["intro_ally_01"] = intro_ally_01;


	node anim_single(guys, "intro");	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

intro_keene_spawn()
{
	intro_keene = vignette_actor_spawn("vignette_intro_ally_02", "intro_keene"); //"value" (kvp), "anim_name"
	intro_opfor = vignette_actor_spawn("vignette_intro_opfor", "intro_opfor"); //"value" (kvp), "anim_name"
	
	intro_keene set_battlechatter( false );
	intro_opfor set_battlechatter( false );

	intro_keene(intro_keene, intro_opfor);

	intro_keene vignette_actor_delete();
	intro_opfor vignette_actor_delete();
}

intro_keene(intro_keene, intro_opfor)
{

	node = getstruct("vignette_intro", "script_noteworthy");


	guys = [];
	guys["intro_keene"] = intro_keene;
	guys["intro_opfor"] = intro_opfor;
	
	intro_opfor PlaySound( "scn_hos_intro_kill" );	
	node anim_single(guys, "intro");

	intro_opfor vignette_actor_kill();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//vignette_register( ::stealth_kill_reloading_spawn, "trigger_flag_name" );

stealth_kill_reloading_spawn()
{
	reloading_guard = vignette_actor_spawn("vignette_stealth_kill_reloading_guard", "reloading_guard"); //"value" (kvp), "anim_name"

	stealth_kill_reloading(reloading_guard);

	reloading_guard vignette_actor_delete();
}

stealth_kill_reloading(reloading_guard)
{

	node = getstruct("vignette_stealth_kill_reloading", "script_noteworthy");

	reloading_airport = spawn_anim_model("reloading_airport");

	reload_clip_01 = spawn_anim_model("reload_clip_01");

	reload_clip_02 = spawn_anim_model("reload_clip_02");


	guys = [];
	guys["reloading_guard"] = reloading_guard;
	guys["reloading_airport"] = reloading_airport;
	guys["reload_clip_01"] = reload_clip_01;
	guys["reload_clip_02"] = reload_clip_02;

	node anim_single(guys, "stealth_kill_reloading");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//vignette_register( ::stealth_kill_sleeping_spawn, "trigger_flag_name" );

stealth_kill_sleeping_spawn()
{
	sleeping_guard = vignette_actor_spawn("vignette_stealth_kill_sleeping_guard", "sleeping_guard"); //"value" (kvp), "anim_name"
	stealth_kill_sleeping(sleeping_guard);

	sleeping_guard vignette_actor_delete();
}

stealth_kill_sleeping(sleeping_guard)
{

	node = getstruct("vignette_stealth_kill_sleeping", "script_noteworthy");

	guys = [];
	guys["sleeping_guard"] = sleeping_guard;

	node anim_single(guys, "stealth_kill_sleeping");
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//vignette_register( ::stealth_kill_sleeping_surprised_spawn, "trigger_flag_name" );

stealth_kill_sleeping_surprised_spawn()
{
	surprised_guard = vignette_actor_spawn("vignette_stealth_kill_sleeping_surprised_guard", "surprised_guard"); //"value" (kvp), "anim_name"

	stealth_kill_sleeping_surprised(surprised_guard);

	surprised_guard vignette_actor_delete();
}

stealth_kill_sleeping_surprised(surprised_guard)
{
	node = getstruct("vignette_stealth_kill_sleeping_surprised", "script_noteworthy");

	guys = [];
	guys["surprised_guard"] = surprised_guard;

	node anim_single(guys, "stealth_kill_sleeping_surprised");
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

corner_kill_spawn()
{
	corner_kill_opfor = vignette_actor_spawn("vignette_corner_kill_opfor", "corner_kill_opfor"); //"value" (kvp), "anim_name"
	corner_kill_baker = vignette_actor_spawn("vignette_corner_kill_baker", "corner_kill_baker"); //"value" (kvp), "anim_name"

	corner_kill(corner_kill_opfor, corner_kill_baker);

	corner_kill_opfor vignette_actor_delete();

	corner_kill_baker vignette_actor_delete();
}



corner_kill(corner_kill_opfor, corner_kill_baker)
{
	node = getstruct("vignette_corner_kill", "script_noteworthy");

	guys = [];
	guys["corner_kill_opfor"] = corner_kill_opfor;
	guys["corner_kill_baker"] = corner_kill_baker;

	node anim_single(guys, "corner_kill");
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

radio_run_spawn()
{
	radio_run_opfor = vignette_actor_spawn("vignette_radio_run_opfor", "radio_run_opfor"); //"value" (kvp), "anim_name"

	radio_run(radio_run_opfor);

	radio_run_opfor vignette_actor_delete();
}

radio_run(radio_run_opfor)
{

	node = getstruct("vignette_radio_run", "script_noteworthy");

	radio_run_radio = spawn_anim_model("radio_run_radio");

	guys = [];
	guys["radio_run_opfor"] = radio_run_opfor;
	guys["radio_run_radio"] = radio_run_radio;

	node anim_single(guys, "radio_run");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

outro_spawn()
{
	//vignette_outro_ally_01 = vignette_actor_spawn("vignette_outro_ally_01", "vignette_outro_ally_01"); //"value" (kvp), "anim_name"
	//vignette_outro_ally_02 = vignette_actor_spawn("vignette_outro_ally_02", "vignette_outro_ally_02"); //"value" (kvp), "anim_name"
	vignette_outro_doctor = vignette_actor_spawn("vignette_outro_doctor", "vignette_outro_doctor"); //"value" (kvp), "anim_name"
	vignette_outro_opfor = vignette_actor_spawn("vignette_outro_opfor", "vignette_outro_opfor"); //"value" (kvp), "anim_name"
	vignette_outro_doctor.ignoreall = true;
	vignette_outro_opfor.ignoreall = true;
	vignette_outro_doctor gun_remove();
	vignette_outro_opfor gun_remove();

	outro(vignette_outro_doctor, vignette_outro_opfor);

	//vignette_outro_ally_01 vignette_actor_delete();
	//vignette_outro_ally_02 vignette_actor_delete();
	wait 4;
	vignette_outro_doctor vignette_actor_delete();
	vignette_outro_opfor vignette_actor_delete();
}

outro(vignette_outro_doctor, vignette_outro_opfor)
{
	node = getstruct("vignette_outro", "script_noteworthy");

	outro_ventilator = spawn_anim_model("outro_ventilator");
	outro_ventilator PlayLoopSound( "emt_hos_ventilator_sfx" );
	outro_blood = spawn_anim_model("outro_blood");
	outro_rifle = spawn_anim_model("outro_rifle");
	outro_tubes = spawn_anim_model("outro_tubes");
	outro_bullet_wound = spawn_anim_model("outro_bullet_wound");

	//level._player FreezeControls( true );
	//level._player allowprone( false );
	//level._player allowcrouch( false );

	//player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["vignette_outro_ally_01"] = level.squad[ "ALLY_ALPHA" ];
	guys["vignette_outro_ally_02"] = level.squad[ "ALLY_BRAVO" ];
	guys["vignette_outro_doctor"] = vignette_outro_doctor;
	guys["vignette_outro_opfor"] = vignette_outro_opfor;

	props = [];
	props["outro_ventilator"] = outro_ventilator;
	props["outro_rifle"] = outro_rifle;
	props["outro_blood"] = outro_blood;
	props["outro_tubes"] = outro_tubes;
	props["outro_bullet_wound"] = outro_bullet_wound;
	//guys["player_rig"] = player_rig;

	outro_blood Hide();
	outro_rifle Hide();
	outro_bullet_wound Hide();

	//arc = 0;

	//level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_first_frame_solo( vignette_outro_doctor, "outro" );
	node anim_first_frame_solo( vignette_outro_opfor, "outro" );

	flag_wait ("vignette_outro");

	vignette_outro_opfor thread maps\nx_hospital_exit_corridor::check_for_premature_assassination();

	addNotetrack_customFunction( "vignette_outro_opfor", "hvt_dead", maps\nx_hospital_exit_corridor::set_hvt_dead );

	battlechatter_off( "allies" );
	battlechatter_off( "axis" );

	// node anim_reach_and_approach( guys, "outro" );
	issue_color_orders( "g355 b355", "allies" );
	level.squad["ALLY_ALPHA"] waittill ("goal");
	level.squad["ALLY_BRAVO"] waittill ("goal");
	wait 1;
	thread maps\nx_hospital_exit_corridor::assassination_catchup_nag();

	trigger_wait_targetname ( "player_near_outro" );

	//level.squad[ "ALLY_ALPHA" ] forceUseWeapon( "beretta", "primary" );

	node thread anim_single(guys, "outro");
	thread maps\nx_hospital_fx::outro_blood_fx( vignette_outro_opfor );
	node thread anim_single(props, "outro");

	wait 1.9;
	door = GetEnt ("recovery_room_door", "targetname");
	blocker = GetEnt ("recovery_room_door_blocker", "targetname");

	door thread play_sound_in_space( "metal_door_kick" );
	door RotateTo ( (door.angles - (0, 140, 0)), .4 );
	blocker delete();

	vignette_outro_doctor thread maps\nx_hospital_audio::hos_outro_docpush_sfx();

	//level._player unlink();

	//player_rig delete();

	//level._player FreezeControls( false );
	//level._player allowprone( true );
	//level._player allowcrouch( true );

	wait 18;
	vignette_outro_opfor.team = "axis";
	level notify ("kill_orders_received");
	flag_set ("kill_orders_received");
	wait 6;
	flag_set ("mission_complete");

}

switch_primary_gun( guy )
{
	guy forceUseWeapon( "beretta", "primary" );
}

rifle_model_on( rifle )
{
	rifle Show();
}

bullet_wound_on( wound )
{
	wound Show();
}

blood_splatter_on( blood_on )
{
	blood_on Show();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

dialogue()
{
	level._scr_radio[ "hos_bak_intro_athospital" ] = "hos_bak_intro_athospital";
	level._scr_radio[ "hos_ovl_intro_hvtconfirmed" ] = "hos_ovl_intro_hvtconfirmed";
	level._scr_radio[ "hos_bak_intro_copyoverlord" ] = "hos_bak_intro_copyoverlord";
	level._scr_radio[ "hos_bak_1stflr_weaponsfree" ] = "hos_bak_1stflr_weaponsfree";
	level._scr_radio[ "hos_bak_1stflr_letsdothis" ] = "hos_bak_1stflr_letsdothis";
	level._scr_radio[ "hos_bak_1stflr_onme" ] = "hos_bak_1stflr_onme";
	level._scr_radio[ "hos_bak_1stflr_twoupahead" ] = "hos_bak_1stflr_twoupahead";
	level._scr_radio[ "hos_bak_1stflr_twoaroundcorner" ] = "hos_bak_1stflr_twoaroundcorner";
	level._scr_radio[ "hos_bak_1stflr_twodownhall" ] = "hos_bak_1stflr_twodownhall";
	level._scr_radio[ "hos_bak_1stflr_youtakeone" ] = "hos_bak_1stflr_youtakeone";
	level._scr_radio[ "hos_bak_1stflr_getoneonleft" ] = "hos_bak_1stflr_getoneonleft";
	level._scr_radio[ "hos_bak_1stflr_hesdown" ] = "hos_bak_1stflr_hesdown";
	level._scr_radio[ "hos_bak_1stflr_moveup" ] = "hos_bak_1stflr_moveup";
	level._scr_radio[ "hos_bak_1stflr_puthimdown" ] = "hos_bak_1stflr_puthimdown";
	level._scr_radio[ "hos_bak_1stflr_taketheshot" ] = "hos_bak_1stflr_taketheshot";
	level._scr_radio[ "hos_bak_1stflr_clear" ] = "hos_bak_1stflr_clear";
	level._scr_radio[ "hos_bak_1stflr_move" ] = "hos_bak_1stflr_move";
	level._scr_radio[ "hos_bak_1stflr_getuphere" ] = "hos_bak_1stflr_getuphere";
	level._scr_radio[ "hos_bak_1stflr_getmoving" ] = "hos_bak_1stflr_getmoving";
	level._scr_radio[ "hos_bak_1stflr_letsmove" ] = "hos_bak_1stflr_letsmove";
	level._scr_radio[ "hos_bak_1stflr_careful" ] = "hos_bak_1stflr_careful";
	level._scr_radio[ "hos_bak_1stflr_dontletthathappen" ] = "hos_bak_1stflr_dontletthathappen";
	level._scr_radio[ "hos_bak_1stflr_takehimdown1" ] = "hos_bak_1stflr_takehimdown1";
	level._scr_radio[ "hos_bak_1stflr_clearletsmove" ] = "hos_bak_1stflr_clearletsmove";
	level._scr_radio[ "hos_bak_1stflr_onemoreinside" ] = "hos_bak_1stflr_onemoreinside";
	level._scr_radio[ "hos_bak_1stflr_mvmntacrosshall" ] = "hos_bak_1stflr_mvmntacrosshall";
	level._scr_radio[ "hos_bak_1stflr_takehimdown2" ] = "hos_bak_1stflr_takehimdown2";
	level._scr_radio[ "hos_bak_1stflr_stopbeforebody" ] = "hos_bak_1stflr_stopbeforebody";
	level._scr_radio[ "hos_bak_1stflr_stopthatpatrol" ] = "hos_bak_1stflr_stopthatpatrol";
	level._scr_radio[ "hos_bak_1stflr_anotherpatrol" ] = "hos_bak_1stflr_anotherpatrol";
	level._scr_radio[ "hos_bak_1stflr_damnfoundit" ] = "hos_bak_1stflr_damnfoundit";
	level._scr_radio[ "hos_bak_1stflr_fuck" ] = "hos_bak_1stflr_fuck";
	level._scr_radio[ "hos_bak_1stflr_puthimdown" ] = "hos_bak_1stflr_puthimdown";
	level._scr_radio[ "hos_bak_2ndflr_clearupstairs" ] = "hos_bak_2ndflr_clearupstairs";
	level._scr_radio[ "hos_bak_2ndflr_takepoint" ] = "hos_bak_2ndflr_takepoint";
	level._scr_radio[ "hos_bak_2ndflr_mvmntahead" ] = "hos_bak_2ndflr_mvmntahead";
	level._scr_radio[ "hos_bak_2ndflr_behindwindow" ] = "hos_bak_2ndflr_behindwindow";
	level._scr_radio[ "hos_bak_2ndflr_straightahead" ] = "hos_bak_2ndflr_straightahead";
	level._scr_radio[ "hos_bak_2ndflr_gethisfriend" ] = "hos_bak_2ndflr_gethisfriend";
	level._scr_radio[ "hos_bak_2ndflr_thatwasclose" ] = "hos_bak_2ndflr_thatwasclose";
	level._scr_radio[ "hos_bak_2ndflr_goodkill" ] = "hos_bak_2ndflr_goodkill";
	level._scr_radio[ "hos_bak_2ndflr_puthimdown" ] = "hos_bak_2ndflr_puthimdown";
	level._scr_radio[ "hos_bak_2ndflr_onthemove" ] = "hos_bak_2ndflr_onthemove";
	level._scr_radio[ "hos_bak_2ndflr_ontherun" ] = "hos_bak_2ndflr_ontherun";
	level._scr_radio[ "hos_bak_2ndflr_ontherunputdown" ] = "hos_bak_2ndflr_ontherunputdown";
	level._scr_radio[ "hos_bak_2ndflr_calledusin" ] = "hos_bak_2ndflr_calledusin";
	level._scr_radio[ "hos_bak_2ndflr_knowwherehere" ] = "hos_bak_2ndflr_knowwherehere";
	level._scr_radio[ "hos_bak_atrium_holdit" ] = "hos_bak_atrium_holdit";
	level._scr_radio[ "hos_bak_atrium_behindthedesk" ] = "hos_bak_atrium_behindthedesk";
	level._scr_radio[ "hos_bak_atrium_hallwayclear" ] = "hos_bak_atrium_hallwayclear";
	level._scr_radio[ "hos_bak_atrium_morearoundcorner" ] = "hos_bak_atrium_morearoundcorner";
	level._scr_radio[ "hos_bak_atrium_onyou" ] = "hos_bak_atrium_onyou";
	level._scr_radio[ "hos_bak_atrium_cleanouthallway" ] = "hos_bak_atrium_cleanouthallway";
	
	// Stealth
	level._scr_sound[ "ally_alpha" ][ "hos_bak_intro_athospital" ] = "hos_bak_intro_athospital";
	level._scr_sound[ "ally_alpha" ][ "hos_ovl_intro_hvtconfirmed" ] = "hos_ovl_intro_hvtconfirmed";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_intro_copyoverlord" ] = "hos_bak_intro_copyoverlord";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_weaponsfree" ] = "hos_bak_1stflr_weaponsfree";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_letsdothis" ] = "hos_bak_1stflr_letsdothis";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_onme" ] = "hos_bak_1stflr_onme";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_twoupahead" ] = "hos_bak_1stflr_twoupahead";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_twoaroundcorner" ] = "hos_bak_1stflr_twoaroundcorner";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_twodownhall" ] = "hos_bak_1stflr_twodownhall";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_youtakeone" ] = "hos_bak_1stflr_youtakeone";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_getoneonleft" ] = "hos_bak_1stflr_getoneonleft";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_hesdown" ] = "hos_bak_1stflr_hesdown";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_moveup" ] = "hos_bak_1stflr_moveup";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_puthimdown" ] = "hos_bak_1stflr_puthimdown";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_taketheshot" ] = "hos_bak_1stflr_taketheshot";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_clear" ] = "hos_bak_1stflr_clear";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_move" ] = "hos_bak_1stflr_move";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_getuphere" ] = "hos_bak_1stflr_getuphere";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_getmoving" ] = "hos_bak_1stflr_getmoving";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_letsmove" ] = "hos_bak_1stflr_letsmove";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_careful" ] = "hos_bak_1stflr_careful";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_dontletthathappen" ] = "hos_bak_1stflr_dontletthathappen";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_takehimdown1" ] = "hos_bak_1stflr_takehimdown1";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_clearletsmove" ] = "hos_bak_1stflr_clearletsmove";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_onemoreinside" ] = "hos_bak_1stflr_onemoreinside";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_mvmntacrosshall" ] = "hos_bak_1stflr_mvmntacrosshall";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_takehimdown2" ] = "hos_bak_1stflr_takehimdown2";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_stopbeforebody" ] = "hos_bak_1stflr_stopbeforebody";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_stopthatpatrol" ] = "hos_bak_1stflr_stopthatpatrol";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_anotherpatrol" ] = "hos_bak_1stflr_anotherpatrol";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_damnfoundit" ] = "hos_bak_1stflr_damnfoundit";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_fuck" ] = "hos_bak_1stflr_fuck";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_1stflr_puthimdown" ] = "hos_bak_1stflr_puthimdown";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_clearupstairs" ] = "hos_bak_2ndflr_clearupstairs";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_takepoint" ] = "hos_bak_2ndflr_takepoint";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_mvmntahead" ] = "hos_bak_2ndflr_mvmntahead";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_behindwindow" ] = "hos_bak_2ndflr_behindwindow";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_straightahead" ] = "hos_bak_2ndflr_straightahead";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_gethisfriend" ] = "hos_bak_2ndflr_gethisfriend";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_thatwasclose" ] = "hos_bak_2ndflr_thatwasclose";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_goodkill" ] = "hos_bak_2ndflr_goodkill";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_puthimdown" ] = "hos_bak_2ndflr_puthimdown";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_onthemove" ] = "hos_bak_2ndflr_onthemove";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_ontherun" ] = "hos_bak_2ndflr_ontherun";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_ontherunputdown" ] = "hos_bak_2ndflr_ontherunputdown";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_calledusin" ] = "hos_bak_2ndflr_calledusin";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_knowwherehere" ] = "hos_bak_2ndflr_knowwherehere";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_atrium_holdit" ] = "hos_bak_atrium_holdit";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_atrium_behindthedesk" ] = "hos_bak_atrium_behindthedesk";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_atrium_hallwayclear" ] = "hos_bak_atrium_hallwayclear";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_atrium_morearoundcorner" ] = "hos_bak_atrium_morearoundcorner";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_atrium_onyou" ] = "hos_bak_atrium_onyou";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_atrium_cleanouthallway" ] = "hos_bak_atrium_cleanouthallway";

	// Construction
	level._scr_sound[ "ally_alpha" ][ "hos_bak_const_moveup" ] = "hos_bak_const_moveup";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_const_getdown" ] = "hos_bak_const_getdown";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_const_wereclear" ] = "hos_bak_const_wereclear";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_const_letsgo" ] = "hos_bak_const_letsgo";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_const_moveout" ] = "hos_bak_const_moveout";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_const_cleartodoor" ] = "hos_bak_const_cleartodoor";
	level._scr_sound[ "ally_bravo" ][ "hos_jenk_const_clear" ] = "hos_jenk_const_clear";

	level._scr_sound[ "generic" ][ "oilrig_mrc1_killthem" ] = "oilrig_mrc1_killthem";
	level._scr_sound[ "generic" ][ "est_ru_3_steady" ] = "est_ru_3_steady";
	level._scr_sound[ "generic" ][ "est_ru1_attack" ] = "est_ru1_attack";
	level._scr_sound[ "generic" ][ "est_ru2_attack" ] = "est_ru2_attack";
	level._scr_sound[ "generic" ][ "est_ru3_attack" ] = "est_ru3_attack";
	level._scr_sound[ "generic" ][ "est_ru4_attack" ] = "est_ru4_attack";

	// Exit Corridor
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_takepoint" ] = "hos_bak_corr_takepoint";
	level._scr_sound[ "ally_bravo" ][ "hos_kee_corr_contacts" ] = "hos_kee_corr_contacts";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_tooquiet" ] = "hos_bak_corr_tooquiet";
	level._scr_sound[ "ally_bravo" ][ "hos_kee_corr_grenaderun" ] = "hos_kee_corr_grenaderun";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_grenadeoffice" ] = "hos_bak_corr_grenadeoffice";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_grenaderoffice" ] = "hos_bak_corr_grenaderoffice";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_grenadeloffice" ] = "hos_bak_corr_grenadeloffice";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_lobbyclear" ] = "hos_bak_corr_lobbyclear";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_moveup" ] = "hos_bak_corr_moveup";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_lastofthem" ] = "hos_bak_corr_lastofthem";
	level._scr_sound[ "ally_bravo" ][ "hos_kee_corr_threeguesses" ] = "hos_kee_corr_threeguesses";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_breaching" ] = "hos_bak_corr_breaching";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_overhere" ] = "hos_bak_corr_overhere";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_whatsholdup" ] = "hos_bak_corr_whatsholdup";
	level._scr_sound[ "ally_bravo" ][ "hos_kee_corr_machgunner" ] = "hos_kee_corr_machgunner";
	level._scr_sound[ "ally_bravo" ][ "hos_kee_corr_dugin" ] = "hos_kee_corr_dugin";
	level._scr_sound[ "ally_bravo" ][ "hos_kee_corr_needcover" ] = "hos_kee_corr_needcover";
	level._scr_sound[ "ally_bravo" ][ "hos_kee_corr_pinneddown" ] = "hos_kee_corr_pinneddown";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_improvise" ] = "hos_bak_corr_improvise";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_knockdrinkmach" ] = "hos_bak_corr_knockdrinkmach";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_pushvendmach" ] = "hos_bak_corr_pushvendmach";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_pushsnackmach" ] = "hos_bak_corr_pushsnackmach";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_thatmachinegunner" ] = "hos_bak_corr_thatmachinegunner";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_thosemachinegunners" ] = "hos_bak_corr_thosemachinegunners";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_rushem" ] = "hos_bak_corr_rushem";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_theycantsee" ] = "hos_bak_corr_theycantsee";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_cantseeshit" ] = "hos_bak_corr_cantseeshit";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_shootspotlights" ] = "hos_bak_corr_shootspotlights";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_takeoutgenerator" ] = "hos_bak_corr_takeoutgenerator";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_destroygenerator" ] = "hos_bak_corr_destroygenerator";

	// Outro
	level._scr_radio[ "hos_kee_outro_onyourknees" ] = "hos_kee_outro_onyourknees";
	level._scr_radio[ "hos_bak_outro_thatshim" ] = "hos_bak_outro_thatshim";
	level._scr_radio[ "hos_kee_outro_nowmotherfucker" ] = "hos_kee_outro_nowmotherfucker";
	level._scr_radio[ "hos_bak_outro_wehavethehvt" ] = "hos_bak_outro_wehavethehvt";
	level._scr_radio[ "hos_bak_outro_roger" ] = "hos_bak_outro_roger";
	level._scr_radio[ "hos_kee_outro_now" ] = "hos_kee_outro_now";
	level._scr_radio[ "hos_bak_outro_negativecantmovehim" ] = "hos_bak_outro_negativecantmovehim";

	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_nosignofhvt" ] = "hos_bak_2ndflr_nosignofhvt";
	level._scr_radio[ "hos_ovl_2ndflr_proceedwestwing" ] = "hos_ovl_2ndflr_proceedwestwing";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_const_walkernow" ] = "hos_bak_const_walkernow";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_const_getdownhere" ] = "hos_bak_const_getdownhere";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_const_getoutofhere" ] = "hos_bak_const_getoutofhere";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_machinegunner" ] = "hos_bak_corr_machinegunner";
	level._scr_sound[ "ally_bravo" ][ "hos_kee_corr_lastofem" ] = "hos_kee_corr_lastofem";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_watchforstragglers" ] = "hos_bak_corr_watchforstragglers";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_cantseeanything" ] = "hos_bak_corr_cantseeanything";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_spotlightsblindingus" ] = "hos_bak_corr_spotlightsblindingus";

	// New
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_anothergunner" ] = "hos_bak_corr_anothergunner";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_anotherguyonturret" ] = "hos_bak_corr_anotherguyonturret";
	level._scr_radio[ "hos_ovl_intro_hviconfirmedinside" ] = "hos_ovl_intro_hviconfirmedinside";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_outro_wehavethehvi" ] = "hos_bak_outro_wehavethehvi";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_nosignofhim" ] = "hos_bak_2ndflr_nosignofhim";
	level._scr_radio[ "hos_ovl_2ndflr_continuesearching" ] = "hos_ovl_2ndflr_continuesearching";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_gottagettokoslov" ] = "hos_bak_2ndflr_gottagettokoslov";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_bunchedupinleftroom" ] = "hos_bak_corr_bunchedupinleftroom";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_putgrenadeinthere" ] = "hos_bak_corr_putgrenadeinthere";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_duginroomonright" ] = "hos_bak_corr_duginroomonright";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_corr_nosignofkoslov" ] = "hos_bak_corr_nosignofkoslov";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_outro_securedkoslov" ] = "hos_bak_outro_securedkoslov";
	level._scr_radio[ "hos_ovl_intro_noonehasleft" ] = "hos_ovl_intro_noonehasleft";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_intro_getourguyandgetout" ] = "hos_bak_intro_getourguyandgetout";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_intro_getkoslovandgetout" ] = "hos_bak_intro_getkoslovandgetout";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_2ndflr_needhvibeforeevac" ] = "hos_bak_2ndflr_needhvibeforeevac";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_outro_needalive" ] = "hos_bak_outro_needalive";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_intro_snatchandgrab1" ] = "hos_bak_intro_snatchandgrab1";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_intro_snatchandgrab2" ] = "hos_bak_intro_snatchandgrab2";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_outro_donehere" ] = "hos_bak_outro_donehere";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_outro_negativecopy" ] = "hos_bak_outro_negativecopy";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_outro_understood" ] = "hos_bak_outro_understood";
	level._scr_sound[ "ally_alpha" ][ "hos_bak_outro_cantmovehim" ] = "hos_bak_outro_cantmovehim";


}



















 


	




