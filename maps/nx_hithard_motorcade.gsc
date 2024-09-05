//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  nx_hithard_motorcade.gsc					   					**
//				NOTE: called from nx_hithard.gsc							**
//                                                                          **
//    Created: 1/13/2011 - Brian Marvin										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

//***********************************************************************
//																		*
//		INITIALIZATION: The following are called from nx_hithard.gsc	*
//                                                                  	*
//***********************************************************************

// Objective specific flag_init() calls
flag_inits()
{
	flag_init ("flag_motorcade_end");
	flag_init ("player_speed_burst");
	flag_init ("AI_speed_burst_vp");
	flag_init ("AI_speed_burst_sheep");
	flag_init ("flag_VP_Meet_Greet_Start");
	flag_init ("flag_vp_meet_vignette_start");
	flag_init ("flag_VP_Meet_Greet_Done");
	flag_init ("flag_vp_meet_greet_anim_reached");
	flag_init ("flag_osprey_fly_in");
	flag_init ("flag_transition_squad_move0");
	flag_init ("flag_transition_squad_move1");
	flag_init ("flag_transition_squad_move2");
	flag_init ("flag_transition_squad_move3");
	flag_init ("flag_vp_enter_doorway");
	flag_init ("flag_stairway_shake");
	flag_init ("flag_stairway_shake2");
	flag_init ("flag_osprey_ugv_drop" );
	flag_init ("flag_ugv_stop");
	flag_init ("flag_ugv_shoot_door");
	flag_init ("flag_spawn_squad" );
	flag_init ("flag_hallway_vignette");
	flag_init ("flag_hallway_blocked");
	flag_init ("flag_end_mission");
	flag_init("flag_vignette_vtol_ugv_drop_done");
	flag_init("flag_get_off_the_street");
	flag_init("flag_rooftop_door_open");
	flag_init("flag_spawn_cortel_squad");
	flag_init("flag_player_out_of_bounds");
	flag_init("flag_kill_player");
	flag_init("fx_cortel_enter");
	flag_init("fx_cortel_side_street");
	flag_init("fx_cortel_stairwell_enter");
	flag_init("flag_blow_cortel_door");
	flag_init("flag_fodder3_moveit");
	flag_init("flag_ss_playing_hallway_loop");
	flag_init("flag_vp_playing_hallway_loop");
	flag_init("flag_ugv_shove1");
	flag_init("flag_ugv_shove2");
	flag_init("flag_ugv_shove3");
	flag_init("flag_doorsmash_anim_reached");
}

// Objective specific add_hint_string() calls
hint_string_inits()
{	
	//add_hint_string( "hint_parachute_smoke", &"NX_HITHARD_PARACHUTE_HINT_SMOKE", ::hint_parachute_smoke );	
}

//*******************************************************************
//                                                                  *
//	MAIN: The following "main()" is called from nx_hithard.gsc		*
//                                                                  *
//*******************************************************************

main()
{
	// Kill off all ai spawners from parachute section
	maps\_spawner::kill_spawnerNum( 3 );

	thread autosave_now();

	level thread transition_objectives();

	// initialize vehicles
	//level.allied_osprey1 = GetEnt( "allied_osprey1", "targetname" );
	//level.allied_osprey1 = GetEnt( "ospreycrashvp", "targetname");

	//level thread squadmate_control();
	level thread squadmate_control_new();
	//level thread vp_ss_control();
	level thread vp_ss_control_new();
	//level thread cqb_volume();
	level thread prone_volume();
	level thread UGV1_drive_kill();
	level thread UGV1_kill_cars();
	level thread ugv_shoot_player();
	level thread ugv_kill_player();
	level thread staircase_rumble();
	level thread staircase_rumble2();
	level thread Osprey_VP_Vignette();
	level thread Osprey_UGV_drop_Vignette();
	level thread targetcar_death_reaction();
	//level thread dropped_ugv_firing();
	level._player DisableThreatVisualization();

	level thread hallway_enemy_clip();

	// vfx
	thread maps\nx_hithard_fx::fx_motorcade_init();

	thread audio_nodes();


}



audio_nodes()
{

	level waittill( "notify_osprey_hit" );

	thread maps\_utility::set_ambient( "nx_hithard_ext" );

	mynodedebris = spawn( "sound_emitter", ( 9149, -3694, 429 ) );
	mynodedebris PlayloopSound( "elm_hh_building_dust" );
	flag_wait ("flag_stairway_shake");
	level._player playsound ( "elm_hh_building_shake" );
	mynodedebris stopsounds();
	wait 0.1;
	mynodedebris delete();


}

// Jump Starts
motorcade_end()
{
	thread maps\nx_hithard_fx::fx_apply_cortel_bldg_vision_fog(); // set vision and fog
	// This is ugly.  clean this up later.
	// position the player and his squadmates
	player_start = GetNode( "motorcade_end_player", "targetname");
	level._player SetOrigin( player_start.origin);
	level._player SetPlayerAngles( player_start.angles);
	baker_start = GetNode( "node_baker_dooranim_start", "script_noteworthy");
	level.squad[0] ForceTeleport( baker_start.origin, baker_start.angles);
	gypsy_start = GetNode( "node_gypsy_dooranim_start", "script_noteworthy");
	level.squad[1] ForceTeleport( gypsy_start.origin, gypsy_start.angles);
	// spawn the vp and ss guys
	spawners = getentarray( "vp_ss", "targetname" );
	array_thread( spawners, ::spawn_ai );
	level.vp_transition = get_living_ai ( "vp_transition", "script_noteworthy");
	level.ss_fodder1 = get_living_ai ( "ss_fodder1", "script_noteworthy");
	level.ss_fodder2 = get_living_ai ( "ss_fodder2", "script_noteworthy");
	level.vp_transition set_force_color("y");
	level.ss_fodder1 set_force_color("r");
	level.ss_fodder2 set_force_color("r");
	// position the vp and ss guys
	vp_start = GetNode( "motorcade_end_vp", "targetname");
	level.vp_transition ForceTeleport( vp_start.origin, vp_start.angles);
	ss1_start = GetNode( "motorcade_end_ss1", "targetname");
	level.ss_fodder1 ForceTeleport( ss1_start.origin, ss1_start.angles);
	ss2_start = GetNode( "motorcade_end_ss2", "targetname");
	level.ss_fodder2 ForceTeleport( ss2_start.origin, ss2_start.angles);
	issue_color_orders( "r2 y2", "allies" );
	// trigger the doorsmash vignette
	baker_doorsmash = level.squad[0];
	baker_doorsmash.animname = "baker_doorsmash";
	smashable_door = GetEnt("smashable_door", "targetname");
	smashable_door delete();
	maps\nx_hithard_anim::nx_tp_hithard_doorsmash_ally_01(baker_doorsmash);
	node_baker = getnode ("node_baker_transition5", "script_noteworthy");
	level.squad[0] SetGoalNode( node_baker );
	level.squad[0].goalradius = 8;
	wait 1.0;
	flag_set("flag_transition_squad_move3");
	//issue_color_orders( "y3", "allies" );
	level thread vp_hallway_vignette();
	wait 1.5;
	issue_color_orders( "r3", "allies" );
	wait 1.5;
	node_gypsy = getnode ("node_gypsy_transition5", "script_noteworthy");
	level.squad[1] SetGoalNode( node_gypsy );
	level.squad[0] waittill( "goal" );
	level.squad[1] waittill( "goal" );
	level thread staircase_rumble2();
	level thread hallway_vignette();
	level thread wait_and_end();
}
//

transition_objectives()
{	Objective_Add( 4, "current", &"NX_HITHARD_TRANSITION_OBJ_FOLLOW" );
	Objective_OnEntity( 4, level.squad[0] );
	flag_wait("flag_vp_meet_vignette_start");
	Objective_State( 4, "done" );
	flag_wait("flag_transition_squad_move0");
	Objective_Add( 5, "current", &"NX_HITHARD_TRANSITION_OBJ_END" );
	//Objective_OnEntity( 5, level.squad[0] );
	//Objective_OnEntity(5, level.vp_transition);
	Objective_OnEntity(5,  level.squad[0]);
	//wait 0.5;
	//Objective_Add( 6, "empty", &"NX_HITHARD_TRANSITION_OBJ_END" );
	//objective_setpointertextoverride( 6, &"NX_HITHARD_TRANSITION_OBJ_TEXT_PROTECT" );    //Create the pointer text for objective
	//Objective_onadditionalentity( 5, 1, level.squad[0] );
	//Objective_OnEntity( 6, level.squad[0] );
	flag_wait("flag_end_mission");
	Objective_State( 5, "done" );
}


squadmate_control()
{
	wait 0.5;
	//node_baker = getnode ("node_baker_transition0", "script_noteworthy");
	node_baker = getnode ("node_baker_door_kick", "script_noteworthy");
	//level.squad[0] ForceTeleport( node_baker.origin, node_baker.angles );
	level.squad[0] SetGoalNode( node_baker );
	level.squad[0].goalradius = 8;
	node_gypsy = getnode ("node_gypsy_transition0", "script_noteworthy");
	//level.squad[1] ForceTeleport( node_gypsy.origin, node_gypsy.angles );
	level.squad[1] SetGoalNode( node_gypsy );
	level.squad[1].goalradius = 8;
	level.squad[0] waittill( "goal" );
	// Dialogue: Baker: "We're moving.  Duke, you're on six."
    //level.squad[0] thread radio_dialogue( "hithard_bak_snipe_35" );
	level.squad[0].animname = "baker";
    level.squad[0] thread dialogue_queue( "hithard_bak_snipe_35" );
	//wait 0.5;
	// delete the door TEMP
	level thread play_door_open_vignette();
	flag_wait("flag_rooftop_door_open");
	// Dialogue: Baker: "Duke! Specter! We're movin - down the stairwell…"
    //level.squad[0] thread radio_dialogue( "hithard_bak_snipe_23" );
    level.squad[0] thread dialogue_queue( "hithard_bak_snipe_23" );
	// Dialogue: Baker: "Patriot we are coming down to you."
    //level.squad[0] thread radio_dialogue( "hithard_bak_snipe_22" );
    level.squad[0] thread dialogue_queue( "hithard_bak_snipe_22" );
	// position your squad
	node_baker = getnode ("node_baker_transition1", "script_noteworthy");
	node_gypsy = getnode ("node_gypsy_transition1", "script_noteworthy");
	level.squad[0] SetGoalNode( node_baker );
	level.squad[0].goalradius = 8;
	wait 1.75;
	level.squad[1] SetGoalNode( node_gypsy );
	level.squad[1].goalradius = 8;
	// spawn the swat and ss fodder dudes but wait until you are halfway down the stairwell
	flag_wait( "flag_stairway_shake" );
	wait 1.0;
	spawners = getentarray( "fodder", "targetname" );
	array_thread( spawners, ::spawn_ai );
	level.swat_fodder1 = get_living_ai ( "swat_fodder1", "script_noteworthy");
	level.swat_fodder2 = get_living_ai ( "swat_fodder2", "script_noteworthy");
	// Bullet shield them just in case
	level.swat_fodder1 magic_bullet_shield();
	level.swat_fodder2 magic_bullet_shield();
	//
	// Dialogue: SS1: "Copy, Convoy - we need to get moving, now!"
    level.swat_fodder1 thread radio_dialogue( "hithard_sslead_snipe_03" );
	// Wait till player and your squad are in position and then play the meet the vp vignette
	level.squad[0] waittill( "goal" );

	level.squad[1] waittill( "goal" );
	flag_wait("flag_VP_Meet_Greet_Start");
	level thread play_vp_meet_vignette();
	// Dialogue: Baker: "We meet up with Patriot - get him loaded onto Sparrow and we're out of here…"
    //level.squad[0] thread radio_dialogue( "hithard_bak_snipe_24" );
    level.squad[0] thread dialogue_queue( "hithard_bak_snipe_24" );
	//
	level thread osprey_fly_in();
	// temporary shit.  See if you can break your squad out of their anims and shoot at the UGV
	//wait 23.5;
	//level.squad[0] anim_stopanimscripted();
	//level.squad[1] anim_stopanimscripted();
	flag_wait ("flag_VP_Meet_Greet_Done");

	//node_baker = getnode ("node_baker_vignette_end", "script_noteworthy");
	//level.squad[0] SetGoalNode( node_baker );
	//node_gypsy = getnode ("node_gypsy_vignette_end", "script_noteworthy");
	//level.squad[1] SetGoalNode( node_gypsy );
	//wait 1.5;

	// Gypsy and Baker shoot at the UGV.  Baker stops first and Gypsy keeps shooting
	//for( i=0; i<15; i++)
	//{
	//	level.squad[0] OrientMode( "face point", level.ugv1.origin );
	//	level.squad[0] Shoot( 1, level.ugv1.origin);
	//	wait 0.075;
	//	level.squad[1] OrientMode( "face point", level.ugv1.origin );
	//	level.squad[1] Shoot( 1, level.ugv1.origin);
	//	wait 0.075;
	//}
	//level thread gypsy_keep_shooting();
	//
	//level.vp_transition anim_stopanimscripted();
	//level.ss_fodder1 anim_stopanimscripted();
	//flag_wait( "flag_VP_Meet_Greet_Done" );
	// end temporary shit
	//thread add_dialogue_line( "Baker", "UGV!  Let's get the fuck outta here!", "g" );
	// Baker - "UGV!  Let's get the fuck outta here!"
	level.squad[0] thread radio_dialogue("hithard_bak_vp2_04");
	//set the flag for music to start
	flag_set( "music_run_from_ugv" );
	// delete the player blocker
	player_blocker = GetEnt( "player_blocker_intersection", "targetname" );
	player_blocker Delete(); 
	player_blocker2 = GetEnt( "player_blocker_intersection2", "targetname" );
	player_blocker2 Delete();
	player_blocker3 = GetEnt( "player_blocker_intersection3", "targetname" );
	player_blocker3 Delete();
	// Move squad 
	// Baker moves before everyone so that he can lead
	//flag_set("flag_transition_squad_move0");
	level.squad[0] enable_sprint();
	//node_baker = getnode ("node_baker_lead", "script_noteworthy");
	//level.squad[0] SetGoalNode( node_baker );
	//level.squad[0] waittill( "goal" );
	//
	flag_set("flag_transition_squad_move0");
	node_baker = getnode ("node_baker_transition2", "script_noteworthy");
	level.squad[0] SetGoalNode( node_baker );
	node_gypsy = getnode ("node_gypsy_transition2", "script_noteworthy");
	level.squad[1] SetGoalNode( node_gypsy );
	// Remove bullet shield from fodder dudes
	level.swat_fodder1 stop_magic_bullet_shield();
	level.swat_fodder2 stop_magic_bullet_shield();
	//
	// send the fodder guys to nodes
	level.swat_fodder1.goalradius = 8;
	level.swat_fodder2.goalradius = 8;
	fodder1_node = getnode ("fodder1_cover", "script_noteworthy");
	level.swat_fodder1 SetGoalNode( fodder1_node );
	fodder2_node = getnode ("fodder2_cover", "script_noteworthy");
	level.swat_fodder2 SetGoalNode( fodder2_node );
	// Don't target the fodder guys directly
	level.swat_fodder1.ignoreme = true;
	level.swat_fodder2.ignoreme = true;
	//
	flag_wait("flag_transition_squad_move1");
	level.squad[0] disable_sprint();
	node_baker = getnode ("node_baker_transition3", "script_noteworthy");
	level.squad[0] SetGoalNode( node_baker );
	node_gypsy = getnode ("node_gypsy_transition3", "script_noteworthy");
	level.squad[1] SetGoalNode( node_gypsy );
	flag_wait("flag_transition_squad_move2");
	// set your squadmates to be ignored by enemies so they won't get stuck
	level.squad[0] ignore_almost_everything();
	level.squad[1] ignore_almost_everything();
	//
	//thread add_dialogue_line( "Baker", "Move, move, move!", "g" );
	// Baker - "Move, move, move!"
	level.squad[0] radio_dialogue("hithard_bak_vp2_05");
	node_baker = getnode ("node_baker_transition4", "script_noteworthy");
	level.squad[0] SetGoalNode( node_baker );
	node_gypsy = getnode ("node_gypsy_transition4", "script_noteworthy");
	level.squad[1] SetGoalNode( node_gypsy );
	level.squad[0] waittill( "goal" );
	// switching to new encounter
	flag_wait("flag_osprey_ugv_drop");
	//flag_wait("flag_vignette_vtol_ugv_drop_done");
	wait 2.0;
	thread add_dialogue_line( "Baker", "Incoming enemy gunship!", "g" );
	// Wait until the UGV is dropped to start running.
	wait 5.0;
	// Baker - "Get off the street. Now!"
	level.squad[0]  thread radio_dialogue("hithard_bak_vp2_06");
	//level thread everybody_sprint();
	// try reconnecting paths here
	cortel_blocker = GetEnt("blocker_cortel_entrance", "targetname");
	//cortel_blocker ConnectPaths();
	cortel_blocker Delete();
	// Try making the UGV ignore the player here so he doesn't get hit as much and can get in the door
	level._player.ignoreme = true;
	flag_set("flag_get_off_the_street");
	// Baker - "Move, move, move!"
	level.squad[0] radio_dialogue("hithard_bak_vp2_05");
	// Get the guys in place for Doorsmash
	node_baker = getnode ("node_baker_dooranim_start", "script_noteworthy");
	level.squad[0] SetGoalNode( node_baker );
	node_gypsy = getnode ("node_gypsy_dooranim_start", "script_noteworthy");
	level.squad[1] SetGoalNode( node_gypsy );
	level.squad[0] waittill( "goal" );
	// Baker - "Inside!  Everyone move!"
	level.squad[0]  thread radio_dialogue("hithard_bak_vp2_08");
	// Allow the UGV to target the player here
	level._player.ignoreme = false;
	//flag_wait("flag_doorsmash_start");
	// Play Doorsmash!!!
	//node = GetEnt( "node_vignette_doorsmash", "script_noteworthy");
	//baker = level.squad[0];
	level.squad[0].ignoreall = true;
	baker_doorsmash = level.squad[0];
	baker_doorsmash.animname = "baker_doorsmash";
	smashable_door = GetEnt("smashable_door", "targetname");
	smashable_door delete();
	maps\nx_hithard_anim::nx_tp_hithard_doorsmash_ally_01(baker_doorsmash);
	smashable_player_clip = GetEnt("smashable_player_clip", "targetname");
	smashable_player_clip delete();
	node_baker = getnode ("node_baker_transition5", "script_noteworthy");
	level.squad[0] SetGoalNode( node_baker );
	level.squad[0].goalradius = 8;
	wait 1.0;
	flag_set("flag_transition_squad_move3");
	level.squad[1].ignoreall = true;
	wait 1.5;
	node_gypsy = getnode ("node_gypsy_transition5", "script_noteworthy");
	level.squad[1] SetGoalNode( node_gypsy );
	level.squad[0] waittill( "goal" );
	level.squad[1] waittill( "goal" );
	flag_wait("flag_stairway_shake2");
	flag_wait("flag_hallway_blocked");
	wait 1.0;
	// Duke - "Holy shit..."
	level.squad[1] thread radio_dialogue("hithard_gyp_trans_01");
	wait 3.0;
	thread add_dialogue_line( "Baker", "Spectre, Duke, status report!", "g" );
	// move gypsy to end position casually
	//level.squad[1] maps\_casual_killer::enable_casual_killer();
	node_gypsy = getnode ("node_gypsy_end", "script_noteworthy");
	level.squad[1] SetGoalNode( node_gypsy );
	wait 4.0;
	thread add_dialogue_line( "Duke", "That was too fucking close!", "g" );
	// !!! make Duke move down toward Baker after he says this line !!!
	wait 4.5;
	level thread hallway_vignette();
	level thread wait_and_end();
}

greenlight_sfx_fadeout_hithard()
{
	level._player setchannelvolumes( "snd_channelvolprio_level", "fadetoblack", 1.0 );
	//JL: Not needed. The game resets the channels when it going back to the main menu or when starting a new level.
	//wait 1.5;
	//level._player deactivatechannelvolumes( "snd_channelvolprio_level", 0.2 );
}

squadmate_control_new()
{
	// Remove this once your squad gets moved down for real
	node_baker = getnode ("node_baker_transition1", "script_noteworthy");
	//level.squad[0] ForceTeleport( node_baker.origin, node_baker.angles );
	//node_gypsy = getnode ("node_gypsy_transition0", "script_noteworthy");
	node_gypsy = getnode ("node_gypsy_transition1", "script_noteworthy");
	//level.squad[1] ForceTeleport( node_gypsy.origin, node_gypsy.angles );
	wait 0.5;
	level.squad[0].animname = "baker";
	level.squad[1].animname = "duke";
	// position your squad
	node_baker = getnode ("node_baker_transition1", "script_noteworthy");
	node_gypsy = getnode ("node_gypsy_transition1", "script_noteworthy");
	level.squad[0] SetGoalNode( node_baker );
	level.squad[0].goalradius = 8;
	wait 1.75;
	level.squad[1] SetGoalNode( node_gypsy );
	level.squad[1].goalradius = 8;
	// spawn the swat and ss fodder dudes but wait until you are halfway down the stairwell
	wait 1.0;
	spawners = getentarray( "fodder", "targetname" );
	array_thread( spawners, ::spawn_ai );
	level.swat_fodder1 = get_living_ai ( "swat_fodder1", "script_noteworthy");
	level.swat_fodder2 = get_living_ai ( "swat_fodder2", "script_noteworthy");
	// Bullet shield them just in case
	level.swat_fodder1 magic_bullet_shield();
	level.swat_fodder2 magic_bullet_shield();
	// Wait till player and your squad are in position and then play the meet the vp vignette
	level.squad[0] waittill( "goal" );
	level.squad[1] waittill( "goal" );
	//flag_wait("flag_VP_Meet_Greet_Start");
	level thread osprey_fly_in();

	thread maps\_utility::set_ambient( "nx_hithard_vicepres" );

	// Play the VP meet and greet and send actors to their new goals
	level thread play_vp_meet_vignette();

	//flag_wait ("flag_VP_Meet_Greet_Done");
	flag_wait ("flag_vp_meet_greet_anim_reached");
	wait 25.5;
	// Make sure this flag is clear for the new positioning of the trigger plane
	flag_clear("flag_transition_squad_move1");
	// Baker - "UGV!  Let's get the fuck outta here!"
	level.squad[0] thread radio_dialogue("hithard_bak_vp2_04");
	//set the flag for music to start
	flag_set( "music_run_from_ugv" );
	// set your squadmates to be ignored by enemies so they won't get stuck
	level.squad[0] ignore_almost_everything();
	level.squad[1] ignore_almost_everything();
	// delete the player blocker
	player_blocker = GetEnt( "player_blocker_intersection", "targetname" );
	player_blocker Delete(); 
	player_blocker2 = GetEnt( "player_blocker_intersection2", "targetname" );
	player_blocker2 Delete();
	player_blocker3 = GetEnt( "player_blocker_intersection3", "targetname" );
	player_blocker3 Delete();

	flag_wait("flag_transition_squad_move1");
	level.squad[0] disable_sprint();
	node_baker = getnode ("node_baker_transition3", "script_noteworthy");
	level.squad[0] SetGoalNode( node_baker );
	node_gypsy = getnode ("node_gypsy_transition3", "script_noteworthy");
	level.squad[1] SetGoalNode( node_gypsy );
	flag_wait("flag_transition_squad_move2");
	//thread add_dialogue_line( "Baker", "Move, move, move!", "g" );
	// Baker - "Move, move, move!"
	level.squad[0] radio_dialogue("hithard_bak_vp2_05");
	node_baker = getnode ("node_baker_transition4", "script_noteworthy");
	level.squad[0] SetGoalNode( node_baker );
	node_gypsy = getnode ("node_gypsy_transition4", "script_noteworthy");
	level.squad[1] SetGoalNode( node_gypsy );
	level.squad[0] waittill( "goal" );
	// switching to new encounter
	flag_wait("flag_osprey_ugv_drop");
	//flag_wait("flag_vignette_vtol_ugv_drop_done");
	wait 1.0;
	//thread add_dialogue_line( "Baker", "Incoming enemy gunship!", "g" );
	thread radio_dialogue( "hithard_sslead_snipe_gunship" );
	// Wait until the UGV is dropped to start running.
	wait 4.0;
	// Baker - "Get off the street. Now!"
	level.squad[0]  thread radio_dialogue("hithard_bak_vp2_06");
	//level thread everybody_sprint();


	level thread delete_cortel_door();

	// Try making the UGV ignore the player here so he doesn't get hit as much and can get in the door
	level._player.ignoreme = true;
	flag_set("flag_get_off_the_street");
	level.squad[0].ignoreall = true;
	level.squad[0].ignoreme = true;
	// Baker - "Move, move, move!"
	level.squad[0] radio_dialogue("hithard_bak_vp2_05");
	// SS leader - To the right!
	thread radio_dialogue( "hithard_sslead_snipe_totheright" );
	// Get the guys in place for Doorsmash
	node_baker = getnode ("node_baker_dooranim_start", "script_noteworthy");
	level.squad[0] SetGoalNode( node_baker );
	node_gypsy = getnode ("node_gypsy_dooranim_start", "script_noteworthy");
	level.squad[1] SetGoalNode( node_gypsy );
	level.squad[0] waittill( "goal" );
	// Baker - "Inside!  Everyone move!"
	level.squad[0]  thread radio_dialogue("hithard_bak_vp2_08");
	// Allow the UGV to target the player here
	level._player.ignoreme = false;
	//flag_wait("flag_doorsmash_start");
	// Play Doorsmash!!!
	baker_doorsmash = level.squad[0];
	baker_doorsmash.animname = "baker_doorsmash";

	level thread smashable_door_delete();

	maps\nx_hithard_anim::nx_tp_hithard_doorsmash_ally_01(baker_doorsmash);

	smashable_player_clip = GetEnt("smashable_player_clip", "targetname");
	smashable_player_clip delete();
	node_baker = getnode ("node_baker_transition5", "script_noteworthy");
	level.squad[0] SetGoalNode( node_baker );
	level.squad[0].goalradius = 8;
	flag_set("flag_transition_squad_move3");
	level.squad[1].ignoreall = true;
	wait 1.5;
	node_gypsy = getnode ("node_gypsy_transition5", "script_noteworthy");
	level.squad[1] SetGoalNode( node_gypsy );
	level.squad[0] waittill( "goal" );
	level.squad[1] waittill( "goal" );
	flag_wait("flag_stairway_shake2");
	// temp end the mission here
	//wait 1.0;
	// Duke - "Holy shit..."
	//level.squad[1] thread radio_dialogue("hithard_gyp_trans_01");
	//wait 2.0;
	//nextmission();
	//thread greenlight_sfx_fadeout_hithard();
	//endmission_goto_frontend();
	//
	flag_wait("flag_hallway_blocked");
	wait 2.5;
	// Duke - "Holy shit..."
	level.squad[1] thread radio_dialogue("hithard_gyp_trans_01");
    //level.squad[1] thread dialogue_queue( "hithard_gyp_trans_01" );
	wait 2.0;
	//thread add_dialogue_line( "Baker", "Spectre, Duke, status report!", "g" );
	// move gypsy to end position casually
	//level.squad[1] maps\_casual_killer::enable_casual_killer();
	node_gypsy = getnode ("node_gypsy_end", "script_noteworthy");
	level.squad[1] SetGoalNode( node_gypsy );
	wait 3.0;
	//thread add_dialogue_line( "Duke", "That was too fucking close!", "g" );
	// !!! make Duke move down toward Baker after he says this line !!!
	wait 1.5;
	level thread hallway_vignette();
	level thread wait_and_end();
}

smashable_door_delete()
{
	flag_wait("flag_doorsmash_anim_reached");
	wait 0.25;
	smashable_door = GetEnt("smashable_door", "targetname");
	smashable_door delete();

}

gypsy_keep_shooting()
{
	while(1)
	{
		level.squad[1] OrientMode( "face point", level.ugv1.origin );
		level.squad[1] Shoot( 1, level.ugv1.origin);
		wait 0.30;
		if (flag( "flag_transition_squad_move0"))
			break;
	}
}

everybody_sprint()
{
	level.squad[0] enable_sprint();
	level.squad[1] enable_sprint();
	level.vp_transition enable_sprint();
	level.ss_fodder1 enable_sprint();
	level.ss_fodder2 enable_sprint();
	level.ss_fodder3 enable_sprint();
}

ugv_shoot_player()
{
	flag_wait("flag_player_out_of_bounds");
	level._player.ignoreme = false;
	level.ugv1 thread vehicle_fire_around_entity( level._player, 0.25);
}

ugv_kill_player()
{
	flag_wait("flag_kill_player");
	level._player Kill();
}

targetcar_death_reaction()
{
	targetcar=GetEnt("ugv_targetcar3", "targetname");
	while(1)
		{
			if (!isalive(targetcar))
				break;
			wait 0.1;
		}
	// Duke - "Jesus fucking christ."
	level.squad[1] thread radio_dialogue("hithard_gyp_vpmeet2_02");
}

play_door_open_vignette()
{
	baker = level.squad[0];
	baker.animname = "baker";
	while(1)
	{
		if( player_looking_at(baker.origin))
			break;
		wait 0.1;
	}
	node = GetEnt("node_door_kick", "targetname");
	node thread anim_single_solo(baker, "door_kick_in");

	door = getent( "hh_rooftop_door", "targetname" );
	attachments = GetEntArray( door.target, "targetname" );  //looks at the door entity "target" KVP, then finds every other entity that has the same KVP defined as a targetname.  In this case "door_attachments".

	//Cycle through entities with "door_attachment" KVP and links them to the door entity.
	for ( i = 0; i < attachments.size; i++ )
	{
		attachments[ i ] LinkTo( door );
	}

	door hithard_style_door_kick("scn_hithard_ally_door_smash_hit");

	for ( i = 0; i < attachments.size; i++ )
	{
		if ( attachments[ i ].classname == "script_brushmodel" )
		{
			attachments[ i ] ConnectPaths();
		}
	}
	flag_set("flag_rooftop_door_open");
}

delete_cortel_door()
{
	//doors = GetEntArray( "blocker_cortel_entrance", "targetname" );  //looks at the door entity "target" KVP, then finds every other entity that has the same KVP defined as a targetname.  In this case "door_attachments".

	//doors = GetNodeArray( "blocker_cortel_entrance", "targetname" );  //looks at the door entity "target" KVP, then finds every other entity that has the same KVP defined as a targetname.  In this case "door_attachments".
	//Cycle through entities with "door_attachment" KVP and links them to the door entity.
	//for ( i = 0; i < doors.size; i++ )
	//{
	//	doors[ i ] delete();
	//	doors[ i ] ConnectPaths();
	//}

	cortel_blocker = GetEnt("blocker_cortel_entrance", "targetname");
	cortel_blocker Delete();
	cortel_blocker2 = GetEnt("blocker_cortel_entrance2", "targetname");
	cortel_blocker2 Delete();
	cortel_blocker3 = GetEnt("blocker_cortel_entrance3", "targetname");
	cortel_blocker3 Delete();
	cortel_blocker4 = GetEnt("blocker_cortel_entrance4", "targetname");
	cortel_blocker4 Delete();
	cortel_blocker5 = GetEnt("blocker_cortel_entrance5", "targetname");
	cortel_blocker5 Delete();
	cortel_blocker6 = GetEnt("blocker_cortel_entrance6", "targetname");
	cortel_blocker6 Delete();
	cortel_blocker7 = GetEnt("blocker_cortel_entrance7", "targetname");
	cortel_blocker7 Delete();
	cortel_blocker8 = GetEnt("blocker_cortel_entrance8", "targetname");
	cortel_blocker8 Delete();

}

ad_rotate()
{
	ad = GetEnt("spinning_ad", "targetname");
	ad_decal = GetEnt("spinning_ad_decal", "targetname");
	while ( 1 )
	{
		ad RotateYaw( 360, 5 );
		ad_decal RotateYaw( 360, 5 );
		ad waittill( "rotatedone" );
	}
}

hallway_enemy_clip()
{
	brush = GetEnt( "hallway_enemy_clip", "targetname" );
	brush NotSolid();
	brush ConnectPaths();
	flag_wait("flag_hallway_blocked");
	brush Solid();
	brush DisconnectPaths();
}

hithard_style_door_kick( soundalias )
{
	wait( 2.0 );

	if ( IsDefined( soundalias ) )
		self PlaySound( soundalias );
	else
		self PlaySound( "door_wood_slow_open" );

	//self RotateTo( self.angles + ( 0, 70, 0 ), .4, .1, 0 );
	self RotateTo( self.angles + ( 0, 100, 0 ), .4, .1, 0 );
	self ConnectPaths();
	self waittill( "rotatedone" );
	//self RotateTo( self.angles + ( 0, 70, 0 ), .4, .1, 0 );
	self RotateTo( self.angles + ( 0, -15, 0 ), 1, .1, .1 );
}

play_vp_meet_vignette()
{
	// Play the meet and greet vignette
	baker = level.squad[0];
	baker.animname = "baker";
	gypsy = level.squad[1];
	gypsy.animname = "gypsy";
	secret_service1 = level.ss_fodder1;
	secret_service1.animname = "secret_service1";
	vp = level.vp_transition;
	vp.animname = "vp";

	vp.ignoreall = true;
	secret_service1.ignoreall = true;
	baker.ignoreall = true;
	gypsy.ignoreall = true;

	maps\nx_hithard_anim::vp_meet_and_greet( vp, secret_service1, baker, gypsy );
	level vp_meet_handle_actors( vp, secret_service1, baker, gypsy );

}

vp_meet_handle_actors( vp, secret_service1, baker, gypsy )
{	
	flag_clear("flag_transition_squad_move1");

	vp.ignoreall = true;
	secret_service1.ignoreall = true;
	baker.ignoreall = true;
	gypsy.ignoreall = true;

	baker enable_cqbwalk();
	secret_service1 enable_cqbwalk();
	gypsy enable_cqbwalk();


	//flag_wait ("flag_vp_meet_greet_anim_reached");
	//wait( 1 );
	
	// Move squad 
	// Baker moves before everyone so that he can lead
	//flag_set("flag_transition_squad_move0");
	//baker enable_sprint();
	
	//node_baker = getnode ("node_baker_transition2", "script_noteworthy");
	node_baker = getnode ("node_baker_transition1_2", "script_noteworthy");
	baker SetGoalNode( node_baker );
	//node_gypsy = getnode ("node_gypsy_transition2", "script_noteworthy");
	node_gypsy = getnode ("node_gypsy_transition1_2", "script_noteworthy");
	gypsy SetGoalNode( node_gypsy );
	// Remove bullet shield from fodder dudes
	level.swat_fodder1 stop_magic_bullet_shield();
	level.swat_fodder2 stop_magic_bullet_shield();

	// send the fodder guys to nodes
	level.swat_fodder1.goalradius = 8;
	level.swat_fodder2.goalradius = 8;
	fodder1_node = getnode ("fodder1_cover", "script_noteworthy");
	level.swat_fodder1 SetGoalNode( fodder1_node );
	fodder2_node = getnode ("fodder2_cover", "script_noteworthy");
	level.swat_fodder2 SetGoalNode( fodder2_node );
	// Don't target the fodder guys directly
	level.swat_fodder1.ignoreme = true;
	level.swat_fodder2.ignoreme = true;

	flag_wait( "flag_VP_Meet_Greet_Done" );
	flag_set("flag_transition_squad_move0");
	wait 5;

	vp.ignoreall = false;
	secret_service1.ignoreall = false;
	baker.ignoreall = false;
	gypsy.ignoreall = false;

	baker disable_cqbwalk();
	secret_service1 disable_cqbwalk();
	gypsy disable_cqbwalk();
}

cqb_volume()
{
	volume = GetEnt("squad_cqb_volume", "targetname");
	while(1)
	{
		ai = GetAIArray();
		foreach( guy in ai )
		{
			if( guy IsTouching( volume ) && !guy is_hero() )
				guy enable_cqbwalk();
			else
				guy disable_cqbwalk();
		}
		if (flag( "flag_VP_Meet_Greet_Start" ))
			break;
		wait 1.0;
	}
	level.squad[0] disable_cqbwalk();
	level.squad[1] disable_cqbwalk();
}

prone_volume()
{
	volume = GetEnt("squad_prone_volume", "targetname");
	flag_wait( "flag_stairway_shake" );
	while(1)
	{
		ai = GetAIArray();
		foreach( guy in ai )
		{
			if( guy IsTouching( volume ) && !guy is_hero() )
				guy allowedstances( "crouch" );
			else
				guy allowedstances( "stand", "crouch", "prone" );
		}
		wait 0.25;
	}
	level.squad[0] allowedstances( "stand", "crouch", "prone" );
	level.squad[1] allowedstances( "stand", "crouch", "prone" );
}

// !!!! This is the old one!!!!
vp_ss_control()
{
	flag_wait( "flag_stairway_shake" );
	// Kill AI on the street
	volume = GetEnt("intersection_kill_volume", "targetname");
	ai = GetAIArray();
	foreach( guy in ai )
		{
			//if( guy IsTouching( volume ) && !guy is_hero() )
			if( guy IsTouching( volume ) )
				{
					if(isdefined(guy.magic_bullet_shield))
						{
						guy stop_magic_bullet_shield();
						}
					//wait 0.1;
					if( isalive(guy))
						guy Delete();
				}
		}
	//
	
	spawners = getentarray( "vp_ss", "targetname" );
	array_thread( spawners, ::spawn_ai );
	level.vp_transition = get_living_ai ( "vp_transition", "script_noteworthy");
	level.ss_fodder1 = get_living_ai ( "ss_fodder1", "script_noteworthy");
	level.ss_fodder2 = get_living_ai ( "ss_fodder2", "script_noteworthy");
	level.ss_fodder3 = get_living_ai ( "ss_fodder3", "script_noteworthy");
	level thread vp_ss_loop();
	// Shields up
	level.vp_transition magic_bullet_shield();
	level.ss_fodder1 magic_bullet_shield();
	level.ss_fodder2 magic_bullet_shield();
	level.ss_fodder3 magic_bullet_shield();
	// Agent 2 and 3 go into CQB until the vignette is over
	//level.ss_fodder2 enable_cqbwalk();
	//level.ss_fodder2 cqb_aim();
	level thread agent_loops();
	//
	level.vp_transition ignore_almost_everything();
	level.vp_transition.IgnoreRandomBulletDamage = true;
	level.ss_fodder1.ignoreme = true;
	level.ss_fodder1.takedamage = false;
	level.ss_fodder1.IgnoreRandomBulletDamage = true;
	level.ss_fodder2.ignoreme = true;
	level.ss_fodder2.takedamage = false;
	level.ss_fodder2.IgnoreRandomBulletDamage = true;
	level.ss_fodder3.ignoreme = true;
	level.ss_fodder3.takedamage = false;
	wait 1.0;

	flag_wait("flag_transition_squad_move0");
	level.vp_transition.goalradius = 8;
	level.ss_fodder1.goalradius = 8;
	level.ss_fodder2.goalradius = 8;
	level.ss_fodder3.goalradius = 8;
	level.vp_transition set_force_color("y");
	level.ss_fodder1 set_force_color("r");
	level.ss_fodder2 set_force_color("r");
	level.ss_fodder3 set_force_color("r");
	// Take Agent 2 and 3 out of CQB
	level.ss_fodder2 disable_cqbwalk();
	// dynamic moving stuff
	ent_array = [];
	ent_array[0] = level.ss_fodder1;
	ent_array[0] = level.ss_fodder2;
	level.vp_transition thread use_dynamic_speed( ent_array, 0.75, 1.1, 64, 128);
	issue_color_orders( "r0 y0", "allies" );
	flag_wait("flag_transition_squad_move2");
	issue_color_orders( "r1 y1", "allies" );
	// Dialogue: SS: "Keep Patriot moving"
    thread radio_dialogue( "hithard_sslead_vp2_01" );
	//
	flag_wait("flag_get_off_the_street");
	issue_color_orders( "r2 y2", "allies" );
	level thread agent3_last_stand();
	//flag_wait("flag_vp_enter_doorway");
	flag_wait("flag_transition_squad_move3");
	//Move the VP first
	//issue_color_orders( "r3 y3", "allies" );
	//issue_color_orders( "y3", "allies" );
	//level.ss_fodder1.ignoreall = true;
	//level.ss_fodder2.ignoreall = true;
	level.ss_fodder1 ignore_almost_everything();
	level.ss_fodder2 ignore_almost_everything();

	level thread vp_hallway_vignette();
	level thread ss_hallway_vignette();
	//wait 1.5;
	//issue_color_orders( "r3", "allies" );
	level.ss_fodder1.goalradius = 8;
	node_ss1 = getnode("node_ss_hallway2", "targetname");
	level.ss_fodder1 SetGoalNode( node_ss1 );
}

vp_ss_control_new()
{
	/* BMarv
	//flag_wait( "flag_stairway_shake" );
	// Kill AI on the street
	volume = GetEnt("intersection_kill_volume", "targetname");
	ai = GetAIArray();	
	foreach( guy in ai )
		{
			//if( guy IsTouching( volume ) && !guy is_hero() )
			if( guy IsTouching( volume ) )
				{
					if(isdefined(guy.magic_bullet_shield))
						{
						guy stop_magic_bullet_shield();
						}
					// Don't delete the AI once the VP is moved properly!!! 
					if( isalive(guy))
						guy Delete();
				}
		}
	//
	wait 0.1;
	spawners = getentarray( "vp_ss", "targetname" );
	array_thread( spawners, ::spawn_ai );
	level.vp_transition = get_living_ai ( "vp_transition", "script_noteworthy");
	level.ss_fodder1 = get_living_ai ( "ss_fodder1", "script_noteworthy");
	level.ss_fodder2 = get_living_ai ( "ss_fodder2", "script_noteworthy");
	level.ss_fodder3 = get_living_ai ( "ss_fodder3", "script_noteworthy");
	level thread vp_ss_loop();	
	// Shields up
	wait 0.1;
	level.vp_transition magic_bullet_shield();	
	level.ss_fodder1 magic_bullet_shield();
	level.ss_fodder2 magic_bullet_shield();
	level.ss_fodder3 magic_bullet_shield();
	*/

	// Agent 2 and 3 go into CQB until the vignette is over
	//level.ss_fodder2 enable_cqbwalk();
	//level.ss_fodder2 cqb_aim();
	//level thread agent_loops();

	level.vp_transition = level.secure_vip; // BMarv
	level thread vp_ss_loop();
	level thread agent2_loop();
	level thread agent3_loop();
	//
	level.vp_transition ignore_almost_everything();
	level.vp_transition.IgnoreRandomBulletDamage = true;
	level.ss_fodder1.ignoreme = true;
	level.ss_fodder1.takedamage = false;
	level.ss_fodder1.IgnoreRandomBulletDamage = true;
	level.ss_fodder2.ignoreme = true;
	level.ss_fodder2.takedamage = false;
	level.ss_fodder2.IgnoreRandomBulletDamage = true;
	level.ss_fodder3.ignoreme = true;
	level.ss_fodder3.takedamage = false;
	wait 1.0;

	flag_wait("flag_transition_squad_move0");
	level.vp_transition.goalradius = 8;
	level.ss_fodder1.goalradius = 8;
	level.ss_fodder2.goalradius = 8;
	level.ss_fodder3.goalradius = 8;
	level.vp_transition set_force_color("y");
	level.ss_fodder1 set_force_color("r");
	level.ss_fodder2 set_force_color("r");
	level.ss_fodder3 set_force_color("r");
	// Take Agent 2 and 3 out of CQB
	level.ss_fodder2 disable_cqbwalk();
	// dynamic moving stuff
	ent_array = [];
	ent_array[0] = level.ss_fodder1;
	ent_array[0] = level.ss_fodder2;
	level.vp_transition thread use_dynamic_speed( ent_array, 0.75, 1.1, 64, 128);
	issue_color_orders( "r0 y0", "allies" );
	flag_wait("flag_transition_squad_move2");
	issue_color_orders( "r1 y1", "allies" );
	// Dialogue: SS: "Keep Patriot moving"
    thread radio_dialogue( "hithard_sslead_vp2_01" );
	//
	flag_wait("flag_get_off_the_street");
	issue_color_orders( "r2 y2", "allies" );
	level thread agent3_last_stand();
	//flag_wait("flag_vp_enter_doorway");
	flag_wait("flag_transition_squad_move3");
	//Move the VP first
	//issue_color_orders( "r3 y3", "allies" );
	//issue_color_orders( "y3", "allies" );
	//level.ss_fodder1.ignoreall = true;
	//level.ss_fodder2.ignoreall = true;
	level.ss_fodder1 ignore_almost_everything();
	level.ss_fodder2 ignore_almost_everything();

	level thread vp_hallway_vignette();
	level thread ss_hallway_vignette();
	//wait 1.5;
	//issue_color_orders( "r3", "allies" );
	level.ss_fodder1.goalradius = 8;
	node_ss1 = getnode("node_ss_hallway2", "targetname");
	level.ss_fodder1 SetGoalNode( node_ss1 );
}

vp_ss_loop()
{
	vp_loop = level.vp_transition;
	secret_service1_loop = level.ss_fodder1;
	vp_loop.animname = "vp";
	secret_service1_loop.animname = "secret_service1";
	maps\nx_hithard_anim::vp_loop( secret_service1_loop, vp_loop );

}

agent2_loop()
{
	node2 = GetStruct("node_ss_agent2_loop", "script_noteworthy");
	agent2 = level.ss_fodder2;
	agent2.animname = "agent2";
	guys2 = [];
	guys2["agent2"] = agent2;
	level.ss_fodder2 enable_cqbwalk();
	fodder2_node = GetNode("node_ss2_guard", "script_noteworthy");
	level.ss_fodder2.goalradius = 8;
	level.ss_fodder2 SetGoalNode(fodder2_node);
	level.ss_fodder2 waittill("goal");
	node2 thread anim_loop(guys2, "hunted_tunnel_guy2_idle");
	flag_wait("flag_transition_squad_move0");
	level.ss_fodder2 disable_cqbwalk();
	node2 notify( "stop_loop" );
	agent2 anim_stopanimscripted();
}

agent3_loop()
{
	node3 = GetStruct("node_ss_agent3_loop", "script_noteworthy");
	agent3 = level.ss_fodder3;
	agent3.animname = "agent3";
	guys3 = [];
	guys3["agent3"] = agent3;
	level.ss_fodder3 enable_cqbwalk();
	fodder3_node = GetNode("node_ss3_guard", "script_noteworthy");
	level.ss_fodder3.goalradius = 8;
	level.ss_fodder3 SetGoalNode(fodder3_node);
	level.ss_fodder3 waittill("goal");
	node3 thread anim_loop(guys3, "hunted_tunnel_guy1_idle");
	flag_wait("flag_transition_squad_move0");
	level.ss_fodder3 disable_cqbwalk();
	node3 notify( "stop_loop" );
	agent3 anim_stopanimscripted();
}

agent_loops()
{
	node2 = GetStruct("node_ss_agent2_loop", "script_noteworthy");
	node3 = GetStruct("node_ss_agent3_loop", "script_noteworthy");
	agent2 = level.ss_fodder2;
	agent3 = level.ss_fodder3;
	agent2.animname = "agent2";
	agent3.animname = "agent3";
	guys2 = [];
	guys2["agent2"] = agent2;
	guys3 = [];
	guys3["agent3"] = agent3;
	//node thread anim_loop(guys, "casual_crouch_idle");
	//node2 thread anim_loop(guys2, "hunted_tunnel_guy2_idle");
	//
	level.ss_fodder3 enable_cqbwalk();
	//flag_wait("flag_stairway_shake");
	wait 1.0;
	//flag_wait("flag_fodder3_moveit");
	fodder2_node = GetNode("node_ss2_guard", "script_noteworthy");
	level.ss_fodder2.goalradius = 8;
	level.ss_fodder2 SetGoalNode(fodder2_node);

	fodder3_node = GetNode("node_ss3_guard", "script_noteworthy");
	level.ss_fodder3.goalradius = 8;
	level.ss_fodder3 SetGoalNode(fodder3_node);
	level.ss_fodder3 waittill("goal");
	//
	node2 thread anim_loop(guys2, "hunted_tunnel_guy2_idle");
	node3 thread anim_loop(guys3, "hunted_tunnel_guy1_idle");
	flag_wait("flag_transition_squad_move0");
	level.ss_fodder3 disable_cqbwalk();
	node2 notify( "stop_loop" );
	node3 notify( "stop_loop" );
	agent2 anim_stopanimscripted();
	agent3 anim_stopanimscripted();
}

agent3_last_stand()
{
	// Send Agent 3 to his last stand
	// set him to a non-existent color
	level.ss_fodder3 set_force_color("o");
	node_last_stand = GetNode( "node_ss_last_stand", "script_noteworthy");
	level.ss_fodder3 SetGoalNode( node_last_stand );
	level.ss_fodder3.goalradius = 8;
	level.ss_fodder3 waittill("goal");
	level.ss_fodder3 stop_magic_bullet_shield();
	level.ss_fodder3.ignoreme = false;
	level.ss_fodder3.takedamage = true;
}


use_dynamic_speed( ents, min_speed, max_speed, min_dist, max_dist )
{
	while ( 1 )
	{
		if ( isdefined( self.pathgoalpos ) )
		{
			pos = (0, 0, 0);
			count = 0;
			foreach ( ent in ents )
			{
				if ( isalive( ent ) )
				{
					pos += ent.origin;
					count++;
				}
			}
	
			if ( count > 0 )
			{	
				pos /= count;
				dot = VectorDot( pos - self.origin, self.pathgoalpos - self.origin );

				if ( dot < 0 )
				{
					self.moveplaybackrate = min_speed;
				}
				else
				{
					dist_sqr = DistanceSquared( self.origin, pos );
					moveplaybackrate = lerp( min_speed, max_speed, dist_sqr, -1 * min_dist * min_dist, max_dist*max_dist );
					self.moveplaybackrate = Clamp( moveplaybackrate, min_speed, max_speed );
				}
			}
		}

		wait 0.1;
	}
}

lerp( min_out, max_out, value, min_value, max_value )
{
	return (value - min_value) * (max_out - min_out) / (max_value-min_value) + min_out;
}

wait_and_end()
{
	flag_set("flag_end_mission");
	// Baker - "Convoy 2 requesting assistance, over."
	wait 0.5;
	level.squad[0] thread radio_dialogue("hithard_bak_trans_01");
	wait 3.0;
	//nextmission();
	thread greenlight_sfx_fadeout_hithard();
	endmission_goto_frontend();

}

hallway_vignette()
{
	level.squad[0].animname = "baker";
	node = GetEnt( "node_vignette_hallway", "targetname");
	guys = [];
	guys["baker"] = level.squad[0];
	node thread anim_single(guys, "bog_radio_dialogue");
}

vp_hallway_vignette()
{	
	level.vp_transition.goalradius = 8;
	node_vp = getnode("node_vp_hallway", "script_noteworthy");
	level.vp_transition SetGoalNode( node_vp );
	level.vp_transition waittill( "goal" );

	//node = GetEnt( "node_vp_hallway_vignette" , "targetname");
	node = GetEnt( "node_vp_hallway_vignette2" , "targetname");
	guy = level.vp_transition;
	guy.animname = "vp";
	//node thread anim_loop_solo (guy, "cargoship_ch46_rescue_load_1_idle"); 
	node anim_single_solo (guy, "nx_tp_hithard_vp_rest_VP"); 
	node thread anim_loop_solo (guy, "nx_tp_hithard_vp_rest_VP_idle"); 
	flag_set("flag_vp_playing_hallway_loop");
	flag_wait("flag_ss_playing_hallway_loop");
	// Don't start the tail end of the anim until you are sure the level is going to fade out
	flag_wait("flag_hallway_blocked");
	node notify( "stop_loop" );
	level.vp_transition anim_stopanimscripted();
	node anim_single_solo (guy, "nx_tp_hithard_vp_rest_VP_end"); 
}

ss_hallway_vignette()
{	
	level.ss_fodder2.goalradius = 8;
	node_ss = getnode("node_ss_hallway", "targetname");
	level.ss_fodder2 SetGoalNode( node_ss );
	level.ss_fodder2 waittill( "goal" );
	node = GetEnt( "node_ss_hallway_vignette" , "targetname");
	guy = level.ss_fodder2;
	guy.animname = "ss";
	//node anim_single_solo (guy, "nx_tp_hithard_vp_rest_VP"); 
	node thread anim_loop_solo (guy, "nx_tp_hithard_vp_rest_SS_idle"); 
	flag_set("flag_ss_playing_hallway_loop");
	flag_wait("flag_vp_playing_hallway_loop");
	// Don't start the tail end of the anim until you are sure the level is going to fade out
	flag_wait("flag_hallway_blocked");
	node notify( "stop_loop" );
	level.ss_fodder2 anim_stopanimscripted();
	node anim_single_solo (guy, "nx_tp_hithard_vp_rest_ss_end"); 
}

staircase_rumble()
{
	flag_wait( "flag_stairway_shake" );
	

	level._player maps\nx_hithard_util::missile_hit_rumble();
	//pulselights( "staircase_pulse_lights" );
	stairway_shake_fx = GetEnt( "stairway_shake_fx", "targetname" );
	forward = AnglesToForward( stairway_shake_fx.angles );
	up = AnglesToUp( stairway_shake_fx.angles );
	playFX( level._effect[ "ceiling_rock_collapse" ], stairway_shake_fx.origin, forward, up );
}

staircase_rumble2()
{
	flag_wait( "flag_stairway_shake2" );
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_hithard_2nd_stairs", 0.8 );
	
	//thread maps\_utility::set_ambient( "nx_hithard_no_ugv" );
	level._player playsound ( "elm_hh_building_shake_2" );
	thread sound_low_hit();
	level._player maps\nx_hithard_util::missile_hit_rumble();
}

stairwell_collapse()
{
	//flag_wait( "flag_stairway_shake" );
	wait 1.5;
	stairwell_collapse_fx = GetEnt( "stairwell_collapse_fx", "targetname" );
	playFX( level._effect[ "nx_explosion_cortel_stairwell" ], stairwell_collapse_fx.origin );
	wait 0.175;
	stairwell_collapse_fx2 = GetEnt( "stairwell_collapse_fx2", "targetname" );
	playFX( level._effect[ "nx_explosion_cortel_stairwell" ], stairwell_collapse_fx2.origin );
	wait 0.175;
	//stairwell_collapse_fx3 = GetEnt( "stairwell_collapse_fx3", "targetname" );
	//playFX( level._effect[ "nx_explosion_cortel_stairwell" ], stairwell_collapse_fx3.origin );
}

sound_low_hit()
{

	wait 3.4;
	//level._player playsound ( "elm_hh_building_low_hit" );
	entity01 = spawn( "sound_emitter", ( 9154, -3694, 429 ) );
	entity01 PlaySound( "elm_hh_building_low_hit", "elm_hh_building_low_hit", true );
	entity01 waittill( "elm_hh_building_low_hit" );
	entity01 delete();

}

// Osprey Fly in stuff
osprey_fly_in()
{
	//wait 11;
	//wait 13.25;
	wait 12.3;
	flag_set( "flag_osprey_fly_in" );
	wait 5.0;
	// Osprey radio - "Convoy 2 this is Sparrow 3-6. On approach from the West. Prepare for dust-off, over."
	level.squad[0] radio_dialogue("hithard_rad_vp2_01");

}

Osprey_VP_Vignette()
{
	flag_wait("flag_osprey_fly_in");
	// These vehicles are in nx_hithard_script_anim.map
	level.osprey_vignette = spawn_vehicle_from_targetname( "ospreycrashvp");
	level.osprey_vignette Vehicle_TurnEngineOff();
	level.osprey_vignette.animname = "ospreycrashvp";
	level.osprey_vignette magic_bullet_shield();
    //level.osprey_vignette.ignorerandombulletdamage = true;
	level.osprey_vignette setCanDamage( false );
	level.osprey_vignette suspend_drive_anims_for_vignette();
	maps\nx_hithard_anim::nx_vh_ospreycrashvp_osprey_01(level.osprey_vignette);
}


UGV1_drive_kill()
{
	// Wait and then the UGV rolls up
	//flag_wait( "flag_osprey_fly_in" );
	special_car = GetEnt( "ugv_targetcar1", "targetname" );
	special_car setCanDamage(false);

	flag_clear("flag_ugv_stop");
	level._player.ignoreme = true;
	level.squad[0].ignoreme = true;
	level.squad[1].ignoreme = true;
	level.ugv1 = spawn_vehicle_from_targetname( "transition_ugv1" );
	level.ugv1 = Get_Vehicle( "transition_ugv1", "targetname" );
	level.ugv1 Vehicle_TurnEngineOff();
	flag_wait( "flag_osprey_fly_in" );
	level.ugv1 playsound ( "scn_hh_ugv_approach" );
	turret = level.ugv1.mgturret[0]; 
	//turret StartBarrelSpin();
	// turn off the machine gun until later
	turret_mg = level.ugv1.mgturret[2];
	turret_mg setmode( "manual" );
	// Moving 15 frames earlier.  
	//wait 11.75;
	wait 8.0;
	// Roll up slowly
	level.ugv1 GoPath();
	level.ugv1 Vehicle_TurnEngineOff();
	level.ugv1 Vehicle_SetSpeed( 17.0, 25.0);
	level.ugv1 Vehicle_TurnEngineOff();
	// start shootin'
	wait 1.3;
	targetPos = (6532, -2912, 260);
	turret aim_then_shoot_ce_ugv_turret_once_at_position( targetPos );
	//turret SetTurretTargetPosition(targetPos);
	//turret ShootTurret();

	level notify( "notify_osprey_hit" ); // cue for vfx

	spawners = getentarray( "ugv_squada", "targetname" );
	array_thread( spawners, ::spawn_ai );
	level.ugv1 Vehicle_SetSpeed( 0, 25.0);
	// Wait after killing Osprey and fire a shot moving the turret toward the player
	//wait 1.5;
	//targetPos = (7324, -2680, 20);
	wait 0.5;
	targetPos = (7228, -2680, 20);
	turret aim_then_shoot_ce_ugv_turret_once_at_position( targetPos );
	wait 0.5;
	targetPos = (7516, -2680, 20);
	turret aim_then_shoot_ce_ugv_turret_once_at_position( targetPos );

	//flag_wait("flag_transition_squad_move0");
	//flag_wait ("flag_vp_meet_greet_anim_reached");
	wait 0.3;
	//
	// spawn another squad of dudes
	spawners = getentarray( "ugv_squadb", "targetname" );
	array_thread( spawners, ::spawn_ai );
	//
	wait 0.25;
	special_car setCanDamage(true);
	level.ugv1 Vehicle_SetSpeed( 5.0, 15.0);
	level.ugv1 Vehicle_TurnEngineOn();
	wait 0.25;

	ugv_target = GetEnt( "ugv_targetcar1", "targetname" );
	targetPos = ugv_target.origin;
	//level.ugv1 thread vehicle_fire_around_entity( ugv_target, 2.5);
	turret aim_then_shoot_ce_ugv_turret_once_at_position( targetPos );
	level thread car_jolt();
	radiusdamage( ugv_target.origin, 100, 1000, 1000 );

	turret_mg setmode( "auto_nonai" );
	wait 1.25;
	// stop the UGV and have it target the player if he's not moving
	//level._player.ignoreme = false;
	//level.squad[0].ignoreme = false;
	if (!flag( "flag_transition_squad_move2"))
		{
			level.ugv1 Vehicle_SetSpeed( 0.0, 15.0);
			first_shot = true;
			while(1)
			{
				if (flag( "flag_transition_squad_move2"))
					break;

				targetPos = level._player.origin;
				//turret SetTurretTargetPosition(targetPos);
				//wait 1.0;
				//turret ShootTurret();
				if ( first_shot )
					turret aim_then_shoot_ce_ugv_turret_once_at_position( targetPos );
				else
					turret shoot_ce_ugv_turret_once_at_position( targetPos );
				first_shot = false;

				level._player.ignoreme = false;
			}
		}
	wait 1.0;
	level._player.ignoreme = false;
	level.squad[0].ignoreme = false;
	level.ugv1 Vehicle_SetSpeed( 5.0, 15.0);
	flag_set("flag_ugv_shove1");
	// end of extras
	ugv_target = GetEnt( "ugv_targetcar2", "targetname" );
	level.ugv1 thread vehicle_fire_around_entity( ugv_target, 2.5);
	wait_for_death( ugv_target );
	wait 0.5;
	// blowing the cortel door
	flag_wait("flag_blow_cortel_door");
	targetPos = (7993, -1075, 8);
	turret aim_then_shoot_ce_ugv_turret_once_at_position( targetPos );
	for ( i=0; i<3; i++)
	{
		//targetPos = (8029, -1075, -36);
		//turret SetTurretTargetPosition(targetPos);
		//wait 0.35;
		//turret ShootTurret();
		//wait 0.35;
		turret shoot_ce_ugv_turret_once_at_position( targetPos );
	}
	//
	ugv_target = GetEnt( "ugv_targetcar3", "targetname" );
	level.ugv1 thread vehicle_fire_around_entity( ugv_target, 2.5);
	wait_for_death( ugv_target );
	wait 0.5;
	ugv_target = GetEnt( "ugv_targetcar4", "targetname" );
	level.ugv1 thread vehicle_fire_around_entity( ugv_target, 2.5);
	wait_for_death( ugv_target );
	// Wait a while then advance into the cortel and kill the player
	//flag_wait("flag_get_off_the_street");
	//flag_wait("flag_osprey_ugv_drop");
	flag_wait("flag_ugv_stop");
	level.ugv1 Vehicle_SetSpeed( 0, 25.0);
	//flag_wait("flag_get_off_the_street");
	//level.ugv1 Vehicle_SetSpeed( 3.0, 15.0);
	level._player.ignoreme = false;
	flag_wait("flag_transition_squad_move3");
	//level.ugv1 Vehicle_SetSpeed(7.0, 15.0);
	level.ugv1 Vehicle_SetSpeed(11.5, 18.0);
	// target the player so he can be killed
	//level._player.ignoreme = false;
	flag_wait("flag_ugv_shoot_door");
	//targetPos = (8088, 344, -60);
	targetPos = (8088, 344, -35);
	turret aim_then_shoot_ce_ugv_turret_once_at_position( targetPos );
	wait 0.5;
	level thread stairwell_collapse();
	thread audio_collapse_sound();
	flag_set("flag_hallway_blocked");
	turret shoot_ce_ugv_turret_once_at_position( targetPos );
}

ugv1_kill_cars()
{

	flag_wait("flag_ugv_shove1");
	wait 4.0;
	radiusdamage( (7624,-2396, -144), 100, 1000, 1000 );
	org = (7624,-2396, -144);
	vector = ( 0, 5, 3 );
	PhysicsJolt( org, 50, 50, vector);

	//flag_wait("flag_ugv_shove2");
	//radiusdamage( (7584, -2516, -144), 100, 1000, 1000 );
	//org = (7584, -2516, -144);
	//vector = ( 0, -1, 4 );
	//PhysicsJolt( org, 50, 50, vector);
	//flag_wait("flag_ugv_shove3");
	//radiusdamage( (7748, -2236, -144), 100, 1000, 1000 );
	//org = (7748, -2236, -144);
	//vector = ( 0, -1, 4 );
	//PhysicsJolt( org, 50, 50, vector);
}

audio_collapse_sound()
{

	wait 1.5;
	collapsenode = spawn( "script_origin", ( 8157, 337, -68 ) );
	collapsenode PlaySound( "elm_hh_collapse", "elm_hh_collapse", true );
	collapsenode waittill( "elm_hh_collapse" );
	collapsenode delete();

}

car_jolt()
{
	ugv_target = GetEnt( "ugv_targetcar1", "targetname" );
	//vector = ( 0, 2, 6 );
	org = ugv_target.origin + (50, 50, 0);
	//vector = ( 4, -3, 6 );
	vector = ( 3, -5, 6 );
	wait_for_death( ugv_target );
	ugv_target playsound( "scn_hithard_ugvcar01" );
	// If the player is looking in the direction of the exploding car, play it in slomo
	look_spot1 = (7744, -2952, -64);
	look_spot2 = (7744, -2800, -64);
	look_spot3 = (7744, -2648, -64);
	if( (player_looking_at(look_spot1))||(player_looking_at(look_spot2))||(player_looking_at(look_spot3)))
	{
		level thread car_explode_slow_mo();
		wait 0.2;
	}
	//
	PhysicsJolt( org, 50, 50, vector);
	ugv_target = GetEnt( "ugv_targetcar2", "targetname" );
	org = ugv_target.origin + (50, -50, 0);
	vector = ( 0, 1, 4 );
	wait_for_death( ugv_target );
	ugv_target playsound( "scn_hithard_ugvcar02" );
	PhysicsJolt( org, 50, 50, vector);
	ugv_target = GetEnt( "ugv_targetcar3", "targetname" );
	org = ugv_target.origin + (-50, 50, 0);
	vector = ( 0, 1, 4 );
	wait_for_death( ugv_target );
	ugv_target playsound( "scn_hithard_ugvcar03" );
	PhysicsJolt( org, 50, 50, vector);
	ugv_target = GetEnt( "ugv_targetcar4", "targetname" );
	//org = ugv_target.origin + (50, 50, 0);
	//vector = ( 0, 1, 3 );
	wait_for_death( ugv_target );
	ugv_target playsound( "scn_hithard_ugvcar04" );
	//PhysicsJolt( org, 50, 50, vector);
}

car_explode_slow_mo()
{	
	// Don't slomo the mission critical speech
	SoundSetTimeScaleFactor( "Mission", 0 );
	SoundSetTimeScaleFactor( "Shellshock", 0 );
	SoundSetTimeScaleFactor( "Voice", 0 );
	SoundSetTimeScaleFactor( "Menu", 0 );
	SoundSetTimeScaleFactor( "Effects1", 0 );
	SoundSetTimeScaleFactor( "Effects2", 0 );
	SoundSetTimeScaleFactor( "Announcer", 0 );
	SoundSetTimeScaleFactor( "Music", 0 );
	SoundSetTimeScaleFactor( "vignette3d", 1 );
	SoundSetTimeScaleFactor( "vignette2d", 1 );
	
	slomoLerpTime_in = 2.5;
	slomoLerpTime_out = 0.65;
	slomobreachplayerspeed = 0.1;
	//slomoSpeed = 0.1;
	//slomoDuration = 24;	
	slomoSpeed = 0.20;
	slomoDuration = 7;

	//music_stop();
	
	level._player magic_bullet_shield();
	// Start slo motion
	level._player PlaySound( "scn_hithard_slowdown" );
	level._player setchannelvolumes( "snd_channelvolprio_pain", "hithard_slowmo", 0.5 );
	slowmo_start();
	slowmo_setspeed_slow( slomoSpeed );
	slowmo_setlerptime_in( slomoLerpTime_in );
	slowmo_lerp_in();
	
	level._player SetMoveSpeedScale( slomobreachplayerspeed );
	 
	// Wait slo mo duration
	wait slomoDuration * slomoSpeed;
	
	// Stop slo motion
	slowmo_setlerptime_out( slomoLerpTime_out );
	level._player PlaySound( "scn_hithard_speedup" );
	level._player deactivatechannelvolumes( "snd_channelvolprio_pain", 1 );
	slowmo_lerp_out();
	slowmo_end();
	level._player SetMoveSpeedScale( 1.0 );
	wait 1.0;
	level._player stop_magic_bullet_shield();
}

ugv_squad1()
{
	spawners = getentarray( "ugv_squad1", "targetname" );
	array_thread( spawners, ::spawn_ai );
	wait 1.0;
	while(1)
    {
        num_alive = get_ai_group_sentient_count( "ugv_squad1" );
        if( num_alive < 8 )
            break;
        wait( 0.25 );
    }
	flag_set("flag_osprey_ugv_drop");
}

cortel_squad()
{
	flag_wait("flag_spawn_cortel_squad");
	spawners = getentarray( "cortel_squad", "targetname" );
	array_thread( spawners, ::spawn_ai );
}

vehicle_fire_around_entity( e, interval )
{
	self endon( "death" );
	if( !IsDefined( self.mgturret ) )
		return;

	turret = self.mgturret[0];

	//turret StartBarrelSpin();

	first_shot = true;

	while( 1 )
	{
		r = RandomFloat( 360 );
		s = RandomFloatRange( 120.0, 240.0 );
		if (isalive(e))
			targetPos = e.origin + ( cos(r)*s, sin(r)*s, 0);
		else
			break;
		//turret SetTurretTargetPosition( targetPos );

		//turret ShootTurret();
		
		if ( first_shot )
			turret aim_then_shoot_ce_ugv_turret_once_at_position( targetPos );
		else
			turret shoot_ce_ugv_turret_once_at_position( targetPos );
		first_shot = false;

		wait interval;
	}
}

vehicle_fire_around_origin( e, interval )
{
	self endon( "death" );
	if( !IsDefined( self.mgturret ) )
		return;

	turret = self.mgturret[0];

	turret StartBarrelSpin();

	while( 1 )
	{
		r = RandomFloat( 360 );
		s = RandomFloatRange( 120.0, 240.0 );
		targetPos = e.origin + ( cos(r)*s, sin(r)*s, 0);
		turret SetTurretTargetPosition( targetPos );

		turret ShootTurret();

		wait interval;
	}
}

wait_for_death( guy )
{
	if ( !isalive( guy ) )
		return;
	guy waittill( "death" );
}

Osprey_UGV_drop_Vignette()
{
	// These vehicles are in nx_hithard_script_anim.map
	// Spawn the suv right away so you don't see it pop in
	dropoff_suv_01 = spawn_vehicle_from_targetname( "dropoff_suv_01");
	//dropoff_suv_01 = Get_Vehicle( "dropoff_suv_01", "targetname");
	flag_wait("flag_spawn_squad");
	//thread add_dialogue_line( "SS leader", "Behind the bus!  Take cover!", "g" );
	thread radio_dialogue( "hithard_sslead_snipe_behindbus" );
	//Spawn ugv guys
	level thread ugv_squad1();
	// add a temp wait until you put in a new flag
	flag_wait("flag_osprey_ugv_drop");
	// spawn vignette vehicles
	dropoff_chinese_vtol_01 = spawn_vehicle_from_targetname( "dropoff_chinese_vtol_01");
	dropoff_chinese_vtol_sfx = Get_Vehicle( "dropoff_chinese_vtol_01", "targetname" );
	dropoff_ugv_01 = spawn_vehicle_from_targetname( "dropoff_ugv_01");
	dropoff_ugv_sfx = Get_Vehicle( "dropoff_ugv_01", "targetname" );
	dropoff_ugv_sfx Vehicle_TurnEngineOff();
	// register animnames
	dropoff_chinese_vtol_01.animname = "dropoff_chinese_vtol_01";
	dropoff_chinese_vtol_sfx playsound( "scn_hhh_vtol_flyin04" );
	dropoff_suv_01.animname = "dropoff_suv_01";
	thread dropoff_ugv_sfx();
	dropoff_ugv_01.animname = "dropoff_ugv_01";
	dropoff_ugv_01 suspend_drive_anims_for_vignette();
	maps\nx_hithard_anim::nx_vh_chinese_vtol_ugv_drop(dropoff_suv_01, dropoff_ugv_01, dropoff_chinese_vtol_01);
	dropoff_ugv_sfx Vehicle_TurnEngineOn();
	dropoff_ugv_01 restore_drive_anims_for_vignette();
}

dropoff_ugv_sfx()
{

	dropoff_suv_01 = Get_Vehicle( "dropoff_suv_01", "targetname");
	wait 8.5;
	dropoff_suv_01 playsound( "scn_hhh_ugvcardrop" );
	wait 0.3;
	dropoff_suv_01 playloopsound( "suv_car_alarm" );

}

dropped_ugv_firing()
{
	//wait 5.0;
	flag_wait("flag_vignette_vtol_ugv_drop_done");
	dropoff_ugv = GetEnt("dropoff_ugv_01", "targetname");
	//dropoff_ugv_01 restore_drive_anims_for_vignette();
	dropoff_ugv_target = GetEnt( "ugv_targetcar5", "targetname");
	dropoff_ugv thread vehicle_fire_around_entity( dropoff_ugv_target, 0.75);
	wait_for_death( dropoff_ugv_target );
	//dropoff_ugv_target = GetEnt("ugv_target2", "targetname");
	//dropoff_ugv_01 thread vehicle_fire_around_entity( dropoff_ugv_target, 0.75);
	while(1)
	{
		dropoff_ugv_target = GetEnt("ugv_target1", "targetname");
		dropoff_ugv thread vehicle_fire_around_entity( dropoff_ugv_target, 0.75);
		wait (randomfloatrange( 1.0, 2.5) );
		dropoff_ugv_target = GetEnt("ugv_target2", "targetname");
		dropoff_ugv thread vehicle_fire_around_entity( dropoff_ugv_target, 0.75);
		wait (randomfloatrange( 1.0, 2.5) );
		dropoff_ugv_target = GetEnt("ugv_target2", "targetname");
		dropoff_ugv thread vehicle_fire_around_entity( dropoff_ugv_target, 0.75);
		wait (randomfloatrange( 1.0, 2.5) );
	}
}

ignore_almost_everything()
{
    //self.ignoreall = true;
    self.ignoreme = true;
    //self.grenadeawareness = 0;
    //self.ignoreexplosionevents = true;
    self.ignorerandombulletdamage = true;
    self.ignoresuppression = true;
    self.fixednode = false;
    self.disableBulletWhizbyReaction = true;
    self disable_pain();
    self.dontavoidplayer = true;
    //self.og_newEnemyReactionDistSq = self.newEnemyReactionDistSq;
    //self.newEnemyReactionDistSq = 0;
}


// Old vehicle drive stuff

//*******************************************************************
//MOUNT PLAYER TURRET                                            	*
//*******************************************************************

player_mount_humvee_and_use_turret()
{
	//Adjusted turret rotation from 360 to 45
	self PlayerLinkToDelta( level.convoy[ "player" ], "tag_player", 0.5 );
	turret = level.convoy[ "player" ].mgturret[ 0 ];
	turret MakeUsable();
	turret SetMode( "manual" );
	turret UseBy( self );
	turret MakeUnusable();
	level._player SetPlayerAngles( ( 0, level.convoy["player"].angles[ 1 ], 0 ) );
	self DisableTurretDismount();
	self.turret = turret;
}

//*******************************************************************
//UNMOUNT PLAYER TURRET                                            	*
//*******************************************************************

player_unmount_humvee()
{	
	//Player still linked to turret "model" at origin and will teleport 
	//back when unlinked. Must delete turret and teleport to temp node origin
	jump_node = GetEnt("teleport_point","script_noteworthy");
    org = jump_node.origin;
    level._player Unlink();
    level._player.turret Delete();
    level._player SetOrigin( org );
}


//*******************************************************************
//VEHICLE START PATH                                              	*
//*******************************************************************

vehicle_start_path( script_noteworthy, callback_on_end )
{
	node = GetVehicleNode( script_noteworthy, "script_noteworthy" );
	self StartPath( node );
	self waittill( "reached_end_node" );
	if( IsDefined( callback_on_end ) )
		self thread vehicle_on_path_end( callback_on_end );
}

//*******************************************************************
//PATH CALLBACKS	                                              	*
//*******************************************************************

vehicle_on_path_end( callback )
{
	self [[callback]]();
}

vehicle_on_node( script_noteworthy, callback )
{
	self waittill( script_noteworthy );
	self thread [[callback]]();
}

vehicle_forward()
{
	self.veh_transmission = "forward";
}

vehicle_reverse()
{
	self.veh_transmission = "reverse";
}

//*******************************************************************
//START PATH					                                   	*
//*******************************************************************

/*
convoy_start_path() 
{
	level.convoy[ "ally01" ] thread vehicle_path_ally01();
	level.convoy[ "ally02" ] thread vehicle_path_ally02();
	level.convoy[ "player" ] thread vehicle_path_player();

	//level.convoy[ "ally01" ] thread ride_speed_ai_sheep("AI_speed_burst_sheep");
	//level.convoy[ "ally02" ] thread ride_speed_ai_vp("AI_speed_burst_vp");
	//level.convoy[ "player" ] thread ride_speed_player("player_speed_burst");
	//level.ugv[ "a" ] thread vehicle_path_ugvA();
	//level.ugv[ "b" ] thread vehicle_path_ugvB();
}



//*******************************************************************
//ALLY01 EVENTS (SHEEP)					                           	*
//*******************************************************************

vehicle_path_ally01()
{
	wait 2.5;
	self vehicle_forward();
	self vehicle_start_path( "convoy_rollout_ally01" );

	self vehicle_start_path("encounter_underpass_ally01");
	self vehicle_start_path("speedup_ally01");
	
	self vehicle_waittill_stopped();
	wait 0.5;
	self vehicle_start_path( "building_fall_detour_ally01" );

	wait 1.0;
	self vehicle_start_path( "blocker_defend_ally01" );

	wait 8.0;
	self vehicle_start_path( "blocker_escape_ally01" );
}

//*******************************************************************
//ALLY02 EVENTS (VP)                                             	*
//*******************************************************************

vehicle_path_ally02()
{
	wait 3.5;
	self vehicle_forward();
	self vehicle_start_path( "convoy_rollout_ally02" );

	self vehicle_start_path("encounter_underpass_ally02");
	self vehicle_start_path("speedup_ally02");

	self vehicle_waittill_stopped();
	wait 1.5;
	self vehicle_reverse();
	self vehicle_start_path( "building_fall_backup_ally02" );

	self vehicle_waittill_stopped();
	self vehicle_forward();
	self vehicle_start_path( "vp_rollout_ally02" );

	wait 4.0;
	self vehicle_start_path( "blocker_defend_ally02" );

	wait 8.0;
	self vehicle_start_path( "blocker_escape_ally02" );

	wait 1.0;
	self vehicle_reverse();
	self vehicle_start_path( "ugv_detour_ally02" );

	wait 1.5;
	self vehicle_forward();
	self vehicle_start_path( "promenade_ally02" );

	wait 0.5;
	self vehicle_start_path( "convoy_cityhall_ally02" );

//  self vehicle_forward();
//  self vehicle_start_path( "slow_crawl_ally02" );
//
//  self vehicle_forward();
//  self vehicle_start_path( "blockade_ally02" );
//
//  //wait until all blockade EC are dead - flag sent from player fnc
//  level waittill("go");
//  self vehicle_forward();
//  self vehicle_start_path( "intersection_battle_ally02" );
//
//  wait 1.0;
//  self vehicle_reverse();
//  self vehicle_start_path( "ugv_detour_ally02" );
//
//  wait 1.5;
//  self vehicle_forward();
//  self vehicle_start_path( "promenade_ally02" );
//

}

//*******************************************************************
//PLAYER EVENT		                                              	*
//*******************************************************************

vehicle_path_player()
{
//  self thread path_flags_player();

	//Objective 0: Motorcade Start
	maps\nx_hithard_util::objective_start( "obj_motorcade_rollout", "SECURE THE VP MOTORCADE" );
	
	wait 7.0;
	self vehicle_forward();
	self vehicle_start_path( "convoy_rollout_player" );
		
	//Objective 0: Motorcade Complete	
	maps\nx_hithard_util::objective_end( "obj_motorcade_rollout" );

	self vehicle_start_path("encounter_underpass_player");
	self vehicle_start_path("speedup_player");
	
	self vehicle_waittill_stopped();
	wait 1.0;
	self vehicle_reverse();
	self vehicle_start_path( "building_fall_backup_player" );
	thread autosave_now();
		
	wait 0.5;
	self vehicle_forward();
	self vehicle_start_path( "building_fall_detour_player" );
	
	wait 7.0;
	self vehicle_start_path( "blocker_defend_player" );

//  self thread ram_objective( "ram_group_a", "blocker_encounter_end" );
//  wait 12.0;
//  level notify( "blocker_encounter_end" );

	wait 8.0;
	self vehicle_start_path( "blocker_escape_player" );
	
	wait 4.0;
	self vehicle_reverse();
	self vehicle_start_path( "ugv_detour_player" );
	
	wait 1.5;
	self vehicle_forward();
	self vehicle_start_path( "promenade_player" );
	
	wait 0.5;
	self vehicle_start_path( "convoy_cityhall_player" );
	
//    self vehicle_forward();
//    self vehicle_start_path( "slow_crawl_player" );
//
//    //Objective 1: Blockade Start
//    maps\nx_hithard_util::objective_start( "obj_motorcade_blockade", "CLEAR THE BLOCKADE" );
//    //currently blocking out north wave due to actor count
////  motorcade_enemies_spawn("OP4_North_Promanade");
//    self vehicle_forward();
//    self vehicle_start_path( "blockade_player" );
////  level.enemy_spawned["street_wave_02"] =  motorcade_enemies_gather("op4_blockade");
////  waittill_dead_or_dying( level.enemy_spawned["street_wave_02"] );
//    level notify("go");
//    //Objective 1: Blockade Complete
//    maps\nx_hithard_util::objective_end( "obj_motorcade_blockade" );
//    thread autosave_now();
//
//    self vehicle_forward();
//    self vehicle_start_path( "intersection_battle_player" );
//
//    wait 4.0;
//    self vehicle_reverse();
//    self vehicle_start_path( "ugv_detour_player" );
//
//    //Objective 2: Detour Begin
//    maps\nx_hithard_util::objective_start( "obj_motorcade_detour", "CHANGE OF PLANS" );
//    thread autosave_now();
//
//    wait 0.5;
//    self vehicle_forward();
//    self vehicle_start_path( "promenade_player" );
//
//    //Objective 2: Detour Complete
//    maps\nx_hithard_util::objective_end( "obj_motorcade_detour" );
//    //Clean OP4_North_Promanade
//    thread enemy_clean("OP4_North_Promanade");
//    spawn_vehicles_from_targetname( "ugvB" );
//
//

}

//*******************************************************************
//UGV EVENT   				                                       	*
//*******************************************************************

vehicle_path_ugvA()
{
	self.main_turret setmode("manual"); //( "auto_nonai" );
	self.secondary_turret setmode( "manual" );
	//self thread vehicle_fire_around_entity( level.convoy["ally02"], 0.75 );

	flag_wait( "start_ugvA" );

	self vehicle_start_path( "enter_ugvA" );

	wait 6.0;

	self vehicle_start_path( "detour_ugvA" );
	self vehicle_start_path ("pin_ugvA");

}

vehicle_path_ugvB()
{
	self.main_turret setmode("manual"); 
	self.secondary_turret setmode( "manual" );

	flag_wait( "start_ugvB" );

	self vehicle_start_path( "enter_ugvB" );
}


//*******************************************************************
//OBJECTIVES		                                              	*
//*******************************************************************

objectives()
{
	switch( level._start_point )
	{
		default:
				case "first_turn":
				case "building_fall":
				case "beyond_haze":
				case "intersection_attack":
				case "promenade_detour":
				case "sandwich_end":
	}
}

//*******************************************************************
//ENEMY CLEAN                                                    	*
//*******************************************************************
enemy_clean(enemy_group_delete)//(encounter_enemy)
{
	array_thread( getentarray(enemy_group_delete,"script_noteworthy"), ::living_dead);
}

living_dead()
{
	if( isalive( self ) )
		self delete();
}

//*******************************************************************
//ENEMY SPAWNER                                             	    *
//*******************************************************************


motorcade_enemies_spawn(enemy_script_noteworthy)
{
	road_enemies_spawner = GetEntArray(enemy_script_noteworthy,"script_noteworthy");
	road_enemies = array_spawn( road_enemies_spawner );	
	
	if ( IsDefined( road_enemies ))		
	{
		if ( road_enemies.size < road_enemies_spawner.size )
		{
			AssertMsg( road_enemies_spawner.script_noteworthy + ": Could not spawn ALL secure enemies: " + road_enemies.size + "/" + road_enemies_spawner.size );	   	 	
		}
	}
  	else
	{
		AssertMsg( "Could not spawn secure enemies..." );
	}
	return road_enemies;
}


//*******************************************************************
//ENEMY GATHER                                            	 	    *
//*******************************************************************

motorcade_enemies_gather(enemy_script_noteworthy)
{
	road_enemies_spawner = GetEntArray(enemy_script_noteworthy,"script_noteworthy");
	return road_enemies_spawner;
}



// UGV Auto Fire //
vehicle_fire_around_entity( e, interval )
{
	//vehicle.main_turret = vehicle.mgturret[0];
	if( !IsDefined( self.mgturret ) )
		iPrintLnBold ("xxx");
		return;
	self.main_turret = self.mgturret[0];
	//turret = self.mgturret[0];
	//turret StartBarrelSpin();
	while( 1 )
	{
		iprintLnBold ("IN");
		r = RandomFloat( 360 );
		s = RandomFloatRange( 120.0, 240.0 );
		targetPos = e.origin + ( cos(r)*s, sin(r)*s, 0);
		self.main_turret SetTurretTargetPosition( targetPos );
		self.main_turret ShootTurret();
		//turret SetTurretTargetPosition( targetPos );
		//turret ShootTurret();
	wait interval;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ride_speed_player(player_speed_flag)
{
	flag_wait (player_speed_flag);
	self Vehicle_SetSpeedImmediate ( 80, 10, 1 );
	//wait( 2 );
	self waittill( "reached_end_node" );
	self ResumeSpeed( 25 );	
}

ride_speed_ai_vp(ai_speed_flag_vp)
{
	flag_wait (ai_speed_flag_vp);
	self Vehicle_SetSpeedImmediate (80,10,1);
	//wait( 2 );
	self waittill( "reached_end_node" );
	self ResumeSpeed( 25 );
}

ride_speed_ai_sheep(ai_speed_flag_sheep)
{
	//flag_wait (ai_speed_flag_sheep);
	self Vehicle_SetSpeedImmediate (80,10,1);
	//wait( 2 );
	self waittill( "reached_end_node" );
	self ResumeSpeed( 25 );
}
*/

vehicle_skid(speed_go,accel,decel,sec,speed_return)
{
	self Vehicle_SetSpeedImmediate(speed_go,accel,decel);
	wait (sec);
	self ResumeSpeed(speed_return);
}

ram_objective( ram_nodes_script_noteworthy, end_event )
{

	level endon( end_event );

	ram_nodes = GetEntArray( ram_nodes_script_noteworthy, "script_noteworthy" );

	ram_target = GetEnt( ram_nodes[0].target, "targetname" );

	while( 1 )
	{
		node = ram_target;
		self vehicle_forward();
		self VehicleDriveTo( node.origin, 10.0 );
		while( Distance( self.origin, node.origin ) > node.radius )
		{
			wait 0.05;
		}			

		node = random( ram_nodes );
		self vehicle_reverse();
		self VehicleDriveTo( node.origin, 10.0 );
		while( Distance( self.origin, node.origin ) > node.radius )
		{
			wait 0.05;
		}			

		wait 0.05;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

aim_then_shoot_ce_ugv_turret_once_at_position( position )
{
	// self == turret
	self SetTurretTargetPosition( position );
	wait 1.7;
	self thread _shoot_ce_ugv_turret_once();
	self waittill( "turretshoot" );
	self StopBarrelSpin();
	wait 0.1;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

shoot_ce_ugv_turret_once_at_position( position )
{
	// self == turret
	self SetTurretTargetPosition( position );
	wait 0.5;
	self thread _shoot_ce_ugv_turret_once();
	self waittill( "turretshoot" );
	self StopBarrelSpin();
	wait 0.1;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

_shoot_ce_ugv_turret_once()
{
	self endon( "death" );
	self endon( "turretshoot" );

	self StartBarrelSpin();
	while ( true )
	{
		self ShootTurret();
		wait 0.05;
	}
}
