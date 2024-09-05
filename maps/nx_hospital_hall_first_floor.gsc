//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Nx_Hospital - Hallway First Floor							**
//                                                                          **
//    Created: 11/11/11 - 													**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;


//*******************************************************************
//																	*
// Hallway First Floor - Summary goes here							*
//																	*
//*******************************************************************

//*******************************************************************
//    STARTS	                                                    *
//                                                                  *
//*******************************************************************

// Checkpoint Intro
start_intro()
{
	maps\nx_hospital_util::actor_teleport( level.squad[ "ALLY_ALPHA" ], "corridor_01_start_01_alpha" );
	maps\nx_hospital_util::actor_teleport( level.squad[ "ALLY_BRAVO" ], "corridor_01_start_01_bravo" );
	maps\nx_hospital_util::actor_teleport( level._player, "corridor_01_start_01_player" );
	section_init();
}

// Checkpoint Floor 01
start_floor_01()
{
	maps\nx_hospital_util::actor_teleport( level.squad[ "ALLY_ALPHA" ], "corridor_01_start_01_alpha" );
	maps\nx_hospital_util::actor_teleport( level.squad[ "ALLY_BRAVO" ], "corridor_01_start_01_bravo" );
	maps\nx_hospital_util::actor_teleport( level._player, "corridor_01_start_01_player" );
	section_init();
}

// Checkpoint Floor 02
start_floor_02()
{
	maps\nx_hospital_util::actor_teleport( level.squad[ "ALLY_ALPHA" ], "corridor_01_start_02_alpha" );
	maps\nx_hospital_util::actor_teleport( level.squad[ "ALLY_BRAVO" ], "corridor_01_start_02_bravo" );
	maps\nx_hospital_util::actor_teleport( level._player, "corridor_01_start_02_player" );
	section_init();
	
	issue_color_orders( "b7 g7", "allies" );
}


//*******************************************************************
//    MAIN THREADS                                                  *
//                                                                  *
//*******************************************************************

intro()
{
	maps\nx_hospital_util::actor_teleport( level.squad[ "ALLY_ALPHA" ], "corridor_01_start_01_alpha" );
	maps\nx_hospital_util::actor_teleport( level.squad[ "ALLY_BRAVO" ], "corridor_01_start_01_bravo" );
	maps\nx_hospital_util::actor_teleport( level._player, "corridor_01_start_01_player" );
	
	issue_color_orders( "b0 g0", "allies" );

	level._player thread intro_player_init();
	
	black_overlay = create_client_overlay( "black", 1 );
	thread intro_vo();
	thread intro_vignette();
	wait 10.0;
	black_overlay thread fade_over_time( 0, 1.0 );

	
	level._player thread intro_player_exit();
}

intro_dead_guys()
{
//	thread dead_guy("intro_dead_body_01", "anim_fresh_dead", "dead_01");	
}

intro_vo()
{
	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_intro_athospital", 0.6 );
	level thread play_dialogue( "hos_ovl_intro_hviconfirmedinside", 2.5 );
	flag_set( "music_intro" );
	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_intro_copyoverlord", 8.5  );
}

intro_vignette()
{	
	thread intro_vignette_alpha();
	thread intro_vignette_bravo();	
}

intro_vignette_alpha()
{
//	wait 5.0;
	wait 7.0;
	maps\nx_hospital_anim::intro(
		level.squad[ "ALLY_ALPHA" ]
	);

	flag_set( "intro_alpha_done" );
}

intro_vignette_bravo()
{
	addNotetrack_customFunction( "ally_bravo", "knife_on", ::vignette_knife_on );
	addNotetrack_customFunction( "ally_bravo", "knife_off", ::vignette_knife_off );
	
//	wait 7.0;
	wait 9.0;
	spawner = GetEnt( "intro_dead_body_01", "targetname" );
	intro_enemy = spawner spawn_ai( true );
	maps\nx_hospital_anim::intro_keene(
		level.squad[ "ALLY_BRAVO" ],
		intro_enemy
	);

	flag_set( "intro_bravo_done" );
}

intro_player_init()
{
	// Link player and hide weapon

	level._player SetStance( "crouch" );
	level._player AllowStand( false );
	level._player AllowProne( false );

	player_node = GetEnt( "corridor_01_start_01_player", "targetname" );
	player_tag = spawn_tag_origin();
	player_tag.origin = player_node.origin;
	player_tag.angles = player_node.angles;
	self PlayerLinkToDelta( player_tag, "tag_origin", 1, 10, 10, 6, 15 );
	self DisableWeaponSwitch();
	self TakeWeapon( level._main_gun );
}

intro_player_exit()
{
	// Unlink the player and raise weapon
	self EnableWeaponSwitch();
	self GiveWeapon( level._main_gun );
	self GiveMaxAmmo( level._main_gun );
	self SwitchToWeapon( level._main_gun );	
	wait 0.55;
	self Unlink();
	
//	level._player SetStance( "stand" );
	level._player AllowStand( true );
	level._player AllowProne( true );	
}

main_floor_01()
{		
	// Two patrollers
	thread enc_patrol_main();
	
	// Reloading table guy
	thread enc_guard_room_01();
	
	// Corner Kill
	thread corner_kill();
	flag_wait( "corner_kill_done" );	
	thread corner_kill_advance();
		
	// Go up stairs
	flag_wait( "corridor_01_first_floor_exit" );	
}

main_floor_02()
{	
	// TV guy
	thread enc_guard_desk();
	
	// Fake flashlights
//	thread moment_flashlight();
	
	// Flashlight patrol and radio
	thread enc_guard_flashlight();

	thread enc_guard_hall();
	
	thread moment_radio_kill();
		
	// End
	flag_wait( "corridor_01_second_floor_exit" );

	issue_color_orders( "b12", "allies" );
	wait 1.0;
	issue_color_orders( "g12", "allies" );
	
	section_exit();
}


//*******************************************************************
//    ENCOUNTERS                                                    *
//                                                                  *
//*******************************************************************
enc_patrol_main()
{
	squad_cqb( true );
	squad_sprint( false );
	
	thread enc_patrol_main_ally_move();


	flag_wait( "patrol_main" );

	enemy_01 = level.stealth_enemies["patrol_main"];	
	enemy_02 = level.stealth_enemies["patrol_main_01"];

	// Animation
//	thread enc_patrol_main_anim( enemy_01, enemy_02 );
	enemy_01 start_patrol( "patrol_main_01_start" );
	enemy_02 start_patrol( "patrol_main_02_start" );
	
	// Logic
	
	enemy_01 thread ai_alert_range( level._player, 520, true );
	enemy_01 thread ai_alert_friend( enemy_02 );
	enemy_01 thread ai_alert_bullet( );

	enemy_02 thread ai_alert_range( level._player, 520, true );
	enemy_02 thread ai_alert_friend( enemy_01 );
	enemy_02 thread ai_alert_bullet( );
		
	enemy_01 thread ai_cleanup_alert( RandomFloatrange( 0.4, 0.8 ) );
	enemy_02 thread ai_cleanup_alert( RandomFloatrange( 0.4, 0.8 ) );
	
	thread encounter_cleanup( enemy_01, 15.0, "patrol_main_cleanup" );
	thread encounter_cleanup( enemy_02, 14.5, "patrol_main_cleanup" );
	
	enemy_01 thread anim_on_death();
	enemy_02 thread anim_on_death();
			
	flag_01 = enemy_01.script_deathflag;
	flag_02 = enemy_02.script_deathflag;
	
	enemy_01 thread hallway_guard_walla_sfx();
	
	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_1stflr_twoupahead", 3.0, [flag_01, flag_02, "patrol_main_cleanup"] );
	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_1stflr_getoneonleft", 5.0, [flag_01, flag_02, "patrol_main_cleanup"] );
	
	flag_wait( flag_01 );
	flag_wait( flag_02 );
	
	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_1stflr_clearletsmove", 1.2, "guard_room_01" );
	
	if( !flag( "guard_room_01" ) )
		wait 2.0;
	
	player_speed_scale( 0.64, 3 );

//	issue_color_orders( "b2 g2", "allies" );
	issue_color_orders( "b2", "allies" );
	wait 2.0;
	issue_color_orders( "g2", "allies" );
	
	flag_wait( "ally_office_guard_move" );
	
	issue_color_orders( "g3", "allies" );
	wait 2.5;
	issue_color_orders( "b3", "allies" );
}

enc_patrol_main_ally_move()
{
	flag_wait( "intro_alpha_done" );
	maps\nx_hospital_util::squad_color_reset();
	issue_color_orders( "b40", "allies" );

	flag_wait( "intro_bravo_done" );
	maps\nx_hospital_util::squad_color_reset();
	issue_color_orders( "g0", "allies" );
	
	nag_lines = [
		"hos_bak_1stflr_getuphere",
		"hos_bak_1stflr_getmoving",
		"hos_bak_1stflr_letsmove"		
	];
	
	level.squad[ "ALLY_ALPHA" ] thread play_dialogue_nag( nag_lines, 17.0, 23.0, "patrol_main" );
	
	maps\nx_hospital_util::waittill_flag_timeout( "patrol_main", 4.5 );
	
	issue_color_orders( "g1", "allies" );
	
	flag_wait( "patrol_main" );
		
	issue_color_orders( "b1 g1", "allies" );
}

enc_patrol_main_anim( enemy_01, enemy_02 )
{
	enemy_01.animname = "talking_guard_01";
	enemy_02.animname = "talking_guard_02";
	
	anim_node = GetEnt( "patrol_main_conversation", "targetname" );
	anim_node anim_reach_and_approach( [enemy_01, enemy_02], "talking" );
//	anim_node thread anim_first_frame( [enemy_01, enemy_02], "talking" );	
	anim_node thread anim_single( [enemy_01, enemy_02], "talking" );

//	while( !IsDefined( level.stealth_enemies["patrol_main"] ) &&
//			!IsDefined( level.stealth_enemies["patrol_main_01"] ))
//	{
//		wait 0.05;
//	}
//	
//	enemy_01 = level.stealth_enemies["patrol_main"];
//	
//	enemy_02 = level.stealth_enemies["patrol_main_01"];
//
//	enemy_01.animname = "talking_guard_01";
//	enemy_02.animname = "talking_guard_02";
//	
//	anim_node = GetEnt( "patrol_main_conversation", "targetname" );
//	anim_node thread anim_first_frame( [enemy_01, enemy_02], "talking" );	
}

enc_guard_room_01()
{	
	radio = GetEnt( "sound_stealth_radio", "targetname" );
	radio thread radio_sound();
	
	flag_wait( "guard_room_01" );
		
	enemy = level.stealth_enemies["guard_room_01"];
//	enemy thread ai_alert_bullet();
//	enemy thread ai_alert_range( level._player, 300, true );
	enemy thread ai_cleanup_alert( 0 );
	enemy thread ai_cleanup_bullet( 0 );
	enemy.health = 1;
	
	enemy anim_on_death( "stealth_kill_reloading_death" );
	
	thread encounter_cleanup( enemy, 7.0, "guard_room_01_cleanup" );

	flag_01 = enemy.script_deathflag;
	
	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_1stflr_onemoreinside", 0, [flag_01, "guard_room_01_cleanup"] );
	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_1stflr_taketheshot", 3.0, [flag_01, "guard_room_01_cleanup"] );
	
	flag_wait( flag_01 );

	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_1stflr_hesdown", 1.4, ["guard_room_01_cleanup"] );
	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_1stflr_moveup", 2.5 );
	
	if( !flag( "guard_room_01_cleanup" ) )
		wait 1.8;
	
	player_speed_scale( 0.67, 3 );

//	issue_color_orders( "b4 g4", "allies" );	
	issue_color_orders( "b4", "allies" );
	wait 1.25;
	issue_color_orders( "g4", "allies" );
}
	
enc_guard_room_01_anim()
{
	while( !IsDefined( level.stealth_enemies["guard_room_01"] ) )
	{
		wait 0.05;
	}
	
	enemy = level.stealth_enemies["guard_room_01"];
	reloading_airport = spawn_anim_model("reloading_airport");
	reload_clip_01 = spawn_anim_model("reload_clip_01");
	reload_clip_02 = spawn_anim_model("reload_clip_02");

	guys = [];
	guys["reloading_guard"] = enemy;
	guys["reloading_airport"] = reloading_airport;
	guys["reload_clip_01"] = reload_clip_01;
	guys["reload_clip_02"] = reload_clip_02;

	props = [reloading_airport, reload_clip_01, reload_clip_02];	
	
	enemy.animname = "reloading_guard";
//	anim_node = getstruct( "vignette_stealth_kill_reloading", "script_noteworthy" );
	anim_node = GetEnt( "anim_guard_reloading", "targetname" );	
	anim_node thread anim_loop( guys, "stealth_kill_reloading", "loop_end");

	enemy endon( "alert" );
	enemy waittill( "death" );
	anim_node notify( "loop_end" );
	
	anim_node playsound("scn_hospital_guy_reloading_death");
	anim_node thread anim_single( props, "stealth_kill_reloading_death" );
}

corner_kill()
{	
	flag_wait( "moment_corner_kill" );
	
	level.squad[ "ALLY_BRAVO" ] ai_node_animation( "signal_enemy_coverR", "generic", "corner_kill_play" );
	maps\nx_hospital_util::squad_color_reset();

//	squad_cqb( false );
	issue_color_orders( "b5 g5", "allies" );

	enemy	= level.stealth_enemies[ "corner_kill" ];
	enemy.moveplaybackrate = 1.15;
//	enemy clear_run_anim();
	
	thread corner_kill_on_cancel( enemy );	
	thread corner_kill_reach( enemy );

	thread encounter_cleanup( enemy, -1, "corner_kill_cleanup" );		
}

corner_kill_reach( enemy )
{
	level endon( "corner_kill_cancel" );

	ally	= level.squad[ "ALLY_ALPHA" ];
	anim_node = GetEnt( "node_ally_corner_kill", "targetname" );

	guys	= [];
	guys["ally"] = ally;
	guys["enemy"] = enemy;

	addNotetrack_customFunction( "ally_alpha", "knife_on", ::vignette_knife_on );
	addNotetrack_customFunction( "ally_alpha", "knife_off", ::vignette_knife_off );

	anim_node anim_reach( [ally], "corner_kill_intro" );
	anim_node anim_single( [ally], "corner_kill_intro" );
	anim_node thread anim_loop( [ally], "corner_kill_loop", "loop_end" );

	flag_wait( "corner_kill_play" );
	
	
	level thread corner_kill_play( anim_node, enemy, guys );
}

corner_kill_play( anim_node, enemy, guys )
{	
	flag_set( "corner_kill_playing" );
	
	thread corner_kill_play_interrupt( anim_node, guys );
	
	anim_node anim_reach( [enemy], "corner_kill" );
	anim_node notify( "loop_end" );
	
	if( IsAlive( enemy ) )
		anim_node anim_single( guys, "corner_kill" );

	if( IsAlive( enemy ) )
		enemy maps\_nx_vignette_util::vignette_actor_kill();
	
	flag_set( "corner_kill_done" );
}

corner_kill_on_cancel( enemy )
{
//	level endon( "corner_kill_done" );
	level endon( "corner_kill_playing" );
	
	flag_set( "corner_kill_done" );
	
	flag_wait( "corner_kill_cancel" );
//	enemy start_patrol( "corner_kill_path" );
//	enemy.ignoreall = false;
//	enemy.ignoreme = false;
//	enemy thread ai_alert_range( level._player, 500, true, true);
	enemy thread ai_alert();
	maps\nx_hospital_util::squad_color_reset();
	
	issue_color_orders( "b5 g5", "allies" );	

	thread encounter_cleanup( enemy, 4.1, "corner_kill_cleanup" );
}

corner_kill_play_interrupt( anim_node, guys )
{
	addNotetrack_customFunction( "stealth_enemy", "opfor_dead", ::corner_kill_opfor_stabbed );	

	enemy = guys[ "enemy" ];
	ally = guys[ "ally" ];

	anim_node endon( "corner_kill" );
	
	enemy endon( "stabbed" );
		
	enemy.allowdeath = true;
	enemy waittill( "death" );
	
	ally StopAnimScripted();	
}

corner_kill_opfor_stabbed( actor )
{
	actor.allowdeath = false;
	actor notify( "stabbed" );
//	actor maps\_nx_vignette_util::vignette_actor_kill();
}

corner_kill_advance()
{
	flag_wait( "corner_kill_death" );
	squad_cqb( true );
	maps\nx_hospital_util::squad_color_reset();
//	issue_color_orders( "b6 g6", "allies" );
	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_2ndflr_clearupstairs", 0.5, ["guard_desk"]  );	
	
	issue_color_orders( "g6", "allies" );
//	wait 0.5;
	issue_color_orders( "b6", "allies" );
	
	flag_wait( "ally_stairs_guard_move" );

	issue_color_orders( "b7", "allies" );
	wait 3.3;
	issue_color_orders( "g7", "allies" );
}

vignette_knife_on( actor )
{
	knife = spawn( "script_model", (0,0,0) );
	knife SetModel( "weapon_parabolic_knife" );
//	knife.origin = actor GetTagOrigin( "tag_weapon_left" );
	knife LinkTo( actor, "tag_inhand", (0,0,0), (0, 0, 0) );
	actor.vignette_knife = knife;
}

vignette_knife_off( actor )
{
	if( IsDefined( actor.vignette_knife ) )
		actor.vignette_knife Delete();
}

enc_guard_desk()
{
	squad_cqb( true );
	squad_sprint( false );
	
	flag_wait( "guard_desk" );

	player_speed_scale( 0.72, 6 );

//	issue_color_orders( "b8 g8", "allies" );
	issue_color_orders( "g8", "allies" );
	wait 1.6;
	issue_color_orders( "b8", "allies" );
	
	tv = GetEnt( "sound_stealth_tv", "targetname" );
	tv thread tv_sound();
	
	enemy_01 = level.stealth_enemies[ "guard_desk_01" ];
	enemy_01 thread ai_cleanup_bullet();

	thread encounter_cleanup( enemy_01, 7.0, "guard_desk_01_cleanup" );
	
	flag_01 = enemy_01.script_deathflag;
	
	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_atrium_behindthedesk", 0.4, [flag_01, "guard_desk_01_cleanup"] );

	flag_wait( flag_01 );

	enemy_02 = GetEnt( "guard_desk_02", "targetname" ) spawn_ai(true);
	enemy_02.animname = "surprised_guard";
//	node = getstruct("vignette_stealth_kill_sleeping_surprised", "script_noteworthy");
	node = GetEnt("anim_guard_surprised", "targetname");	
	node thread anim_single( [enemy_02], "stealth_kill_sleeping_surprised" );
	enemy_02.health = 1;
	enemy_02 thread anim_on_death();
	
	thread encounter_cleanup( enemy_02, 3.5 );
	
	flag_02 = enemy_02.script_deathflag;
	
	flag_wait( flag_02 );

	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_2ndflr_goodkill", 0.3, [ "guard_hall_lights" ] );
	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_1stflr_letsmove", 1.5, ["guard_hall_lights_off", "guard_hall_lights"]  );

	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_2ndflr_nosignofhim", 3.2 );
	level thread play_dialogue( "hos_ovl_2ndflr_proceedwestwing", 6.0 );
	
	wait 1.0;
	
	player_speed_scale( 0.8, 6 );
		
	issue_color_orders( "g9", "allies" );
	wait 1.6;
	issue_color_orders( "b9", "allies" );
	
	flag_wait( "ally_hall_guard_move" );
	
	wait 0.8;
	
	issue_color_orders( "g20", "allies" );	
	wait 1.4;
	issue_color_orders( "b20", "allies" );
}

enc_guard_desk_anim()
{
	while( !IsDefined( level.stealth_enemies["guard_desk_01"] ) )
	{
		wait 0.05;
	}
	
	enemy_01 = level.stealth_enemies[ "guard_desk_01" ];	
	enemy_01.animname = "sleeping_guard";
	anim_node = getstruct( "vignette_stealth_kill_sleeping", "script_noteworthy" );
	anim_node thread anim_loop( [enemy_01], "stealth_kill_sleeping" );
	enemy_01 thread anim_on_death( "stealth_kill_sleeping_death" );
	enemy_01.health = 1;
}

enc_guard_flashlight()
{		
	flag_wait("guard_flashlight");

	setsaveddvar( "r_spotlightstartradius", "5" );
    setsaveddvar( "r_spotlightEndradius", "200" );
    setsaveddvar( "r_spotlightfovinnerfraction", ".5" );
    setsaveddvar( "r_spotlightexponent", "2" );
    setsaveddvar( "r_spotlightBrightness", "5" );	
	
	player_speed_scale( 1.0, 6 );
	
	issue_color_orders( "b10 g10", "allies" );
	
	enemy_01 = level.stealth_enemies[ "guard_flashlight" ];
	enemy_01 start_patrol( "guard_flashlight_path" );
	
	enemy_01 delayThread(0.5, maps\nx_hospital_util::attach_flashlight, true );
//	enemy_01 maps\nx_hospital_util::attach_flashlight( true );
	enemy_01 thread hallway_guard_walla_sfx();

	// Patroller
	enemy_01 thread ai_alert_bullet( );
	enemy_01 thread ai_alert_range( level._player, 512, true, true );
	enemy_01 thread ai_cleanup_alert( RandomFloatRange( 3.0, 4.0 ) );
	enemy_01.fovcosine = 0.65;
		
	flag_01 = enemy_01.script_deathflag;

	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_atrium_holdit", 0.35 );
	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_2ndflr_mvmntahead", 1.8, [flag_01, "guard_flashlight_cleanup"] );
	thread encounter_cleanup( enemy_01, 9.0, "guard_flashlight_cleanup" );
	
	flag_wait( flag_01 );
	
	thread radio_alert_sfx();
//	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_2ndflr_calledusin", 2.0 );
	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_2ndflr_knowwherehere", 2.0 );
	
	flag_set( "guard_hall" );
}

enc_guard_hall()
{
	flag_wait( "guard_hall" );

	flag_set( "music_stealth02" );

	spawners = GetEntArray( "guard_hall_enemy", "script_noteworthy" );
	
	enemies = [];
	
	foreach( spawner in spawners )
	{
		enemy = spawner spawn_ai( true );
		enemy.attackeraccuracy = 0.5;
		enemies[ enemies.size ] = enemy;
	}
	
	//Make allies normal again
	ally_cleanup();
	
	//Make player normal again
	player_cleanup();
	
	waittill_dead( enemies, 2 );
	
	issue_color_orders( "b11 g11", "allies" );	
	
	enemies = remove_dead_from_array( enemies );
	
	waittill_dead( enemies, enemies.size );
	
	flag_set( "radio_kill" );
	
	wait 2.0;
	
	flag_set( "corridor_01_second_floor_exit" );	

	level.squad[ "ALLY_ALPHA" ] thread play_dialogue( "hos_bak_2ndflr_needhvibeforeevac", 0.0 );
}

radio_alert_sfx()
{
	soundorg = Spawn( "sound_emitter", ( 276, 173, 236 ) );
	soundorg playsound( "RU_4_stealth_alert_r", "sounddone" );
	soundorg waittill( "sounddone" );
	soundorg playsound( "RU_3_stealth_alert_r", "sounddone" );
	soundorg waittill( "sounddone" );
	soundorg playsound( "RU_4_stealth_alert_r", "sounddone" );
	soundorg waittill( "sounddone" );
	soundorg playsound( "RU_2_stealth_alert_r", "sounddone" );
	soundorg waittill( "sounddone" );
	soundorg playsound( "RU_1_stealth_alert_r", "sounddone" );
	soundorg waittill( "sounddone" );
	soundorg playsound( "RU_4_stealth_alert_r", "sounddone" );
	soundorg waittill( "sounddone" );
	soundorg playsound( "RU_3_stealth_alert_r", "sounddone" );
	soundorg waittill( "sounddone" );
	soundorg playsound( "RU_2_stealth_alert_r", "sounddone" );
	soundorg waittill( "sounddone" );
	soundorg delete();
}

radio_sound()
{
//	self playsound( "RADIO_SOUND" );
}

tv_sound()
{
//	self PlaySound( "TV_SOUND" );
}

moment_radio_kill( )
{	
	flag_wait( "radio_kill" );
	
	enemy = level.stealth_enemies[ "guard_hall_03" ];

	addNotetrack_customFunction( "radio_run_opfor", "dead", ::radio_kill_fire );

	if( !IsAlive( enemy ) )
		return;

	thread radio_kill_anim( enemy );
	
//	flag_01 = enemy.script_deathflag;
//		
//	flag_wait( flag_01 );
}

radio_kill_anim( enemy )
{
	enemy endon( "death" );
		
	enemy clear_run_anim();

	enemy.animname = "radio_run_opfor";
	deathflag = enemy.script_deathflag;
	
	anim_node = getstruct("vignette_radio_run", "script_noteworthy");
	anim_node anim_reach( [enemy], "radio_run" );
	anim_node thread anim_single( [enemy], "radio_run" );

	anim_node thread radio_kill_end( enemy, "radio_run" );
	enemy thread anim_on_death();
	enemy.health = 10;
}

radio_kill_fire( actor )
{
	if( !IsAlive( actor ) )
		return;
	
	actor.allowdeath = false;
	encounter_cleanup_kill( actor );
}

radio_kill_end( actor, animation )
{
	actor endon( "death" );
	
	self waittill( animation );
	
	actor maps\_nx_vignette_util::vignette_actor_kill();
}
//
//moment_flashlight()
//{
//	flag_wait("guard_hall_lights");
//
//	level.stealth_enemies[ "guard_hall_01" ] thread hallway_guard_walla_sfx();
//	level thread play_dialogue( "hos_bak_atrium_holdit", 0.35 );
//	level thread play_dialogue( "hos_bak_atrium_morearoundcorner", 1.8, "guard_hall" );
//	level thread play_dialogue( "hos_bak_atrium_onyou", 4.0 );
//	
//	org = GetEnt( "flashlight_dummy", "targetname" );
//	target = GetEnt( org.target, "targetname" );
//	
//	light = spawn_tag_origin();
//	light.origin = org.origin;
//	lookat_angles = VectorToAngles( target.origin - org.origin );
//	start_angles = lookat_angles + (0, -180, 0);
//	light.angles = start_angles;
//
//	setsaveddvar( "r_spotlightstartradius", "5" );
//    setsaveddvar( "r_spotlightEndradius", "200" );
//    setsaveddvar( "r_spotlightfovinnerfraction", ".5" );
//    setsaveddvar( "r_spotlightexponent", "2" );
//    setsaveddvar( "r_spotlightBrightness", "0.5" );
//    //setsaveddvar( "r_spotlightShadows", "1" );
//
//	PlayFXOnTag( level._effect[ "flashlight" ], light, "tag_origin" );
//
//	issue_color_orders( "b10 g10", "allies" );
//	
//	light RotateTo( lookat_angles, RandomFloatRange(0.25, 0.75) );
//	light waittill( "rotatedone" );
//	
//	light thread flashlight_movement();
//
//	maps\nx_hospital_util::waittill_flag_timeout( "guard_hall_lights_off", 6.4 );
//	
//	light notify( "light_stop" );
//	
//	light RotateTo( start_angles, RandomFloatRange(0.25, 0.5) );
//	light waittill( "rotatedone" );
//	
//	StopFXOnTag( level._effect[ "flashlight" ], light, "tag_origin" );
//	
//	light Delete();
//	org Delete();
//	target Delete();
//
////	issue_color_orders( "b11 g11", "allies" );
//	issue_color_orders( "g11", "allies" );
//	wait 2.0;
//	issue_color_orders( "b11", "allies" );
//}

hallway_guard_walla_sfx()
{
	self endon( "death" );
	
	self playsound( "emt_hospital_rus_walla" );
}

flashlight_movement()
{
	self endon( "light_stop" );
	
	self childthread flashlight_rotation();
	self childthread flashlight_bounce();
}

flashlight_rotation()
{
	old_angles = self.angles;

	while( 1 )
	{
		time = RandomFloatRange(1.0, 4.0);
		self RotateTo( old_angles + (RandomFloatRange(-15, 15), RandomFloatRange(-35, 35), 0), time );
		self waittill("rotatedone");
	}
}

flashlight_bounce()
{
	old_origin = self.origin;
	
	while( 1 )
	{
		time = RandomFloatRange(1.0, 1.5);
		self MoveTo( old_origin + random_vector( RandomFloatRange(-12, 12) ), time );
		self waittill("movedone");
	}
}

//*******************************************************************
//    ENCOUNTER HELPERS                                             *
//                                                                  *
//*******************************************************************

play_dialogue_nag( lines, min_wait, max_wait, cancel_events )	// SCRIPT_KEEP
{
	if( IsDefined( cancel_events ) && !IsArray( cancel_events ) )
	{
		cancel_events = [cancel_events];
	}
	
	if( IsDefined( lines ) && !IsArray( lines ) )
	{
		lines = [lines];
	}
		
	foreach( event in cancel_events )
	{
		if( flag_exist( event ) && flag( event ) )
			return;
		
		level endon( event );
		self endon( event );
	}
	
	if( !IsDefined( min_wait ) )
		min_wait = 1.0;
	if( !IsDefined( max_wait ) )
		max_wait = 2.0;
	
	curr_line = 0;
	
	while( 1 )
	{		
		wait( RandomFloatRange( min_wait, max_wait ) );
	
		line = lines[ curr_line ];
		
		self thread play_dialogue( line );
		
		curr_line++;
		curr_line %= lines.size;
	}
}

anim_on_death( reaction ) //SCRIPT_KEEP
{
	self.allowdeath = true;
	
	if( IsDefined( reaction ) )
	{
		self.deathAnim = self getanim( reaction );
	}
}

encounter_cleanup( enemy, timeout, flag )
{
	//enemy = the enemy to kill
	//timeout = optional, how long to wait before killing the enemy (undefined or negative means wait forever)
	//flag = optional, the flag that will trigger killing the enemy

	if( !IsDefined( enemy ) )
		return;
	
	enemy endon( "death" );
	
	encounter_cleanup_wait( enemy, timeout, flag );
	
	childthread encounter_cleanup_kill( enemy );	
}

encounter_cleanup_wait( enemy, timeout, flag )
{
	if( IsDefined( flag ) )
		level endon( flag );
//	enemy endon( "alert" );
	
	if( IsDefined( timeout) && timeout >= 0 )
		wait timeout;
	else
		level waittill( "never" );
}

encounter_cleanup_kill( enemy )
{
	if( !IsAlive( enemy ) )
		return;

	shooters = [];
	foreach( ally in level.squad )
	{
		shooters[ shooters.size ] = ally;
	}
	
	wait RandomFloatRange( 0.0, 0.3 );
	
	quick_kill( shooters, enemy );	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
section_init()
{
	ally_init();
	enemy_init();
	player_init();
	
	// Anims
	thread intro_dead_guys();
//	thread enc_patrol_main_anim();
	thread enc_guard_room_01_anim();
	thread enc_guard_desk_anim();
	
//	aim_triggers_init();
}

section_exit()
{
	level notify( "section_exit" );
	player_cleanup();
	ally_cleanup();
}

player_init()
{
	level._player DisableOffhandWeapons();

	// Take grenades
	level._player TakeWeapon( level._primary_grenade );
	level._player TakeWeapon( "flash_grenade" );

	player_speed_scale( 0.62, 0 );
}

player_cleanup()
{
	//Give grenades
	level._player setOffhandPrimaryClass( "frag" );
	level._player giveWeapon( level._primary_grenade );
	level._player setOffhandSecondaryClass( "flash" );
	level._player giveWeapon( "flash_grenade" );
	level._player EnableOffhandWeapons();	
	
	//Stop ignoring me! :'(
//	level._player.ignoreMe = false;
//	level._player.ignoreAll = false;
	
	//Normal speed
	player_speed_scale( 1.0, 3.25 );	
}

ally_init()
{
	battlechatter_off( "allies" );
	
	foreach( ally in level.squad )
	{
		ally.ignoreAll = true;
		
		ally.goalRadius_old = ally.goalRadius;
		ally.goalRadius = 8;

		ally thread ally_catch_up( true );
		
		ally.ignoresuppression = true;
		
		SetSavedDvar( "ai_friendlyFireBlockDuration", 0 );
		
		self cqb_aim();
	}

	maps\nx_hospital_util::squad_color_reset();

	squad_cqb( false );
	squad_sprint( false );
}

ally_cleanup()
{
	battlechatter_on( "allies" );
	
	//AI
	foreach( ally in level.squad )
	{
		if( IsDefined( ally.goalRadius_old ) )
			ally.goalRadius = ally.goalRadius_old;
		
		ally.ignoreMe = false;
		ally.ignoreAll = false;
		
		ally thread ally_catch_up( false );

		ally.ignoresuppression = false;
		SetSavedDvar( "ai_friendlyFireBlockDuration", 2000 );		
	}
	
	squad_cqb( false );
	squad_sprint( false );	
}

ally_catch_up( enable )
{
	if( !IsDefined( enable ) || !enable )
	{
		self.moveplaybackrate = 1.0;
		self notify( "end_catch_up" );
		return;
	}
		
	self endon( "end_catch_up" );
	
	min_dist = 100;
	max_dist = 500;
	
	min_speed = 1.0;
	max_speed = 1.175;
	
	speed_delta = max_speed - min_speed;
	
	while( 1 )
	{
		player_dist = Distance( self.origin, level._player.origin );
		
		if( player_dist < max_dist )
		{			
			new_speed = min_speed + speed_delta * abs(1 - player_dist/(max_dist - min_dist));
			
			self.moveplaybackrate = Clamp( new_speed, min_speed, max_speed );
		}
		
		wait 0.2;
	}
}

ally_node_animations( enable )
{
	if( !IsDefined( enable ) || !enable )
	{
		self notify( "end_ally_node_animations" );
		return;
	}
		
	self endon( "end_ally_node_animations" );
		
	while( 1 )
	{
		self waittill( "goal" );
		self waittill( "goal_changed" );
	}
}

ai_node_animation( anime, animname_override, cancel_events )
{
	if( IsDefined( cancel_events ) )
	{
		if( !IsArray( cancel_events ) )
		{
			cancel_events = [cancel_events];
		}
		foreach( event in cancel_events )
		{
			level endon( event );
		}
	}
	
	self waittill( "goal" );	
	
	anim_node = spawn( "script_origin", self.goalpos );
	
	anim_node anim_reach( [ self ], anime, undefined, animname_override );
	anim_node anim_single_solo( self, anime, undefined, 0, animname_override );
	
	anim_node Delete();
//	self anim_single_solo( self, anime, "tag_origin", 0, animname_override );	
}

enemy_init()
{
	stealth_spawners = GetEntArray( "corridor_01_enemy", "script_noteworthy" );
	guard_spawners = GetEntArray( "stealth_end_enemy", "script_noteworthy" );
	
	if( !IsDefined( level.stealth_enemies ) )
		level.stealth_enemies = [];
	
	foreach(spawner in stealth_spawners)
	{
		name = spawner.script_parameters;
		spawner add_spawn_function( ::enemy_stealth_setup, name, spawner.script_animation, spawner.script_looping );
	}

	foreach(spawner in guard_spawners)
	{
		name = spawner.script_parameters;
		spawner add_spawn_function( ::enemy_guard_setup, name );
	}	
}

enemy_stealth_setup( name, animation, looping )
{		
	self.combatmode = "no_cover";
//	self thread maps\nx_hospital_util::ai_ignore_until_damage();
	
	self set_battlechatter( false );
	self.animname = "stealth_enemy";
	
	self.patrol_walk = [ 
		"patrol_walk", 
		"patrol_walk_twitch"
	];
	
	self.patrol_walk_flashlight = [ 
		"patrol_walk_flashlight_01", 
		"patrol_walk_flashlight_02", 
		"patrol_walk_flashlight_03", 
		"patrol_walk_flashlight_04" 
	];
	
	self set_generic_run_anim( random( self.patrol_walk ), true );

	self.ignoreall = true;
	self.ignoreme = true;
	
	self.newEnemyReactionDistSq_old = self.newEnemyReactionDistSq;
	self.newEnemyReactionDistSq = 0;
	
	self.grenadeammo = 0;
	
	self AllowedStances( "stand", "crouch" );
	
	if( IsDefined( name ) )
		level.stealth_enemies[ name ] = self;
	else
		level.stealth_enemies[ level.stealth_enemies.size ] = self;
	
	self.surprise_anims = [
		"surprise_reaction_01",
		"surprise_reaction_02",
		"surprise_reaction_03",
		"surprise_reaction_04"
	];

	self.surprise_anims_patrol = [
		"surprise_reaction_patrol_01",
		"surprise_reaction_patrol_02"
	];
	
	self thread actor_animation( animation, looping );
}

actor_animation( animation, looping )	//SCRIPT_KEEP
{
	anime = "";
	anim_node = self;
	loop = false;
	props = [];
	
	if( !IsDefined( animation ) )
		return;
	else
	{
		anime = animation;
	}
		
	if( IsDefined( self.target ) )
	{
		anim_node = GetNode( self.target, "targetname" );
		if( !IsDefined( anim_node ) )
			anim_node = GetEnt( self.target, "targetname" );
	}
	
	if( IsDefined( looping ) )
	{
		loop = true;
	}
	
	if( IsDefined( level._anim_props ) && IsDefined( level._anim_props[ anime ] ) )
	{
		props = level._anim_props[ anime ];
	}
		
	guys = array_combine( [self], props );
	
	if( loop )
	{
		anim_node thread anim_loop( guys, anime );
	}
	else
	{
		anim_node thread anim_single( guys, anime );
	}
	
}

enemy_guard_setup( name )
{
	if( IsDefined( name ) )
		level.stealth_enemies[ name ] = self;
	else
		level.stealth_enemies[ level.stealth_enemies.size ] = self;	
}

player_speed_scale( speed_scale, time )
{
	// speed_scale = scale, from 0 to 1
	// time = seconds to transition
	
	if(time == 0 || !IsDefined(time))
		time = 0.1;
	
//	if( speed_scale == 1 )
//		thread player_speed_default( time );
//	else
	thread player_speed_percent( 100 * speed_scale, time );
}

squad_cqb( enable, delay )
{
	if(IsDefined( delay ))
		delayThread( delay,  maps\nx_hospital_util::squad_cqb, enable );
	else
		thread maps\nx_hospital_util::squad_cqb( enable );
}

squad_sprint( enable, delay )
{
	if(IsDefined( delay ))
		delayThread( delay,  maps\nx_hospital_util::squad_sprint, enable );
	else
		thread maps\nx_hospital_util::squad_sprint( enable );
}

ai_cleanup_bullet( delay )
{
	self waittill( "bulletwhizby" );
	
	if(IsDefined( delay ))
		wait delay;
	
	thread encounter_cleanup_kill( self );	
}

ai_cleanup_alert( delay )
{
	self waittill( "alert" );
	
	if(IsDefined( delay ))
		wait delay;
	
	thread encounter_cleanup_kill( self );
}

ai_alert_range( entity, radius, needs_sight, play_reaction )
{
	self endon( "death" );
	self endon( "alert" );

	radius_sq = radius * radius;
	
	while( 1 )
	{
		if( DistanceSquared( self.origin, entity.origin ) <= radius_sq )
		{
			if( IsDefined( needs_sight ) && needs_sight)
			{
				if( self CanSee( level._player ) )
					break;
			}
			else
				break;
		}
		wait 0.05;
	}
	
	if( !IsDefined( play_reaction ) )
		play_reaction = false;
	
	self thread ai_alert( play_reaction );
}

ai_alert_bullet( )
{
	self endon( "death" );
	self endon( "alert" );
	
	while( 1 )
	{
		self waittill( "bulletwhizby", shooter, distance );
		if( distance < 70.0 && shooter == level._player )
			break;
	}	
	
	self thread ai_alert( );
}

ai_alert_friend( entity, delay )
{
	self endon( "death" );

	self thread ai_alert_friend_on_damage( entity );
	self thread ai_alert_friend_on_alert( entity );
}

ai_alert_friend_on_damage(entity)
{
	self endon( "death" );
	self endon( "alert" );
	
	entity waittill( "damage" );

	self thread ai_alert( );
}

ai_alert_friend_on_alert(entity)
{
	self endon( "death" );
	self endon( "alert" );

	entity waittill( "alert" );

	self thread ai_alert( );
}

ai_alert( play_reaction )
{
	self endon( "death" );
	
	self notify( "alert" );
	
//	self anim_stopanimscripted();
	self StopAnimScripted();
	self enable_danger_react(10);
	self clear_run_anim();
	self clear_deathanim();
	
	if( Isdefined( self.newEnemyReactionDistSq ) )
	{
		self.newEnemyReactionDistSq = 1024;//self.newEnemyReactionDistSq_old;
	}

	self.favoriteenemy = level._player;
	
	if( !IsDefined( play_reaction ) )
		play_reaction = true;
	
	if( IsDefined( self.have_flashlight ) )
	{
		self maps\nx_hospital_util::detach_flashlight();
		self maps\nx_hospital_util::attach_flashlight_gun(true);
	}
	
	if( play_reaction )
	{
		self.animname = "generic";
		
		anims = self.surprise_anims;		
		if( IsDefined( self.script_patroller ) && self.script_patroller == 1 )
			anims = self.surprise_anims_patrol;
		
		self thread anim_single_solo( self, random( anims ) );
		self.allowdeath = true;
		wait( RandomFloatRange( 0.7, 1.0 ) );
		self StopAnimScripted();
	}

	self.ignoreAll = false;
	self.ignoreMe = false;	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
section_precache()
{
	maps\_patrol_anims::main();
	maps\_hand_signals::initHandSignals();
	PrecacheModel( "weapon_parabolic_knife" );
	PrecacheModel( "com_flashlight_on" );	
}


section_flag_inits()
{
	flag_init( "hall_first_floor_exit" );
	flag_init( "corner_kill_playing" );
	flag_init( "corner_kill_done" );
	flag_init( "music_stealth02" );
	flag_init( "intro_done" );
	flag_init( "intro_alpha_done" );
	flag_init( "intro_bravo_done" );
	
}

//*******************************************************************
//   HELPERS                                                        *
//                                                                  *
//*******************************************************************
#using_animtree( "generic_human" );
dead_guy( spawner_name, node_name, anime)
{
	spawner = GetEnt( spawner_name, "targetname" );
	guy = spawner spawn_ai(true);
	
	model = spawn( "script_model", guy.origin );
	model.angles = guy.angles;
	model setmodel( guy.model );

	numAttached = guy getattachsize();
	for ( i = 0; i < numAttached; i++ )
	{
		modelname 	 = guy getattachmodelname( i );
		tagname 	 = guy getattachtagname( i );
		model attach( modelname, tagname, true );
	}
	
	model.animname = guy.animname;
	model UseAnimTree( #animtree );
	
	guy delete();
	
//	return model;
	anim_node = GetEnt( node_name, "targetname" );
	anim_node thread anim_first_frame( [model], anime );	
}

aim_triggers_init()
{
	triggers = GetEntArray( "aim_trigger", "targetname" );
	
	foreach( trigger in triggers )
	{
		trigger thread aim_trigger_update();
	}
}

aim_trigger_update()
{
	level endon( "section_exit" );
	
	while( 1 )
	{
		self waittill( "trigger", actor );
		
		if( !IsAI( actor ) )
			return;
	
		targets = undefined;
		
		if( IsDefined( self.target ) )
			targets = GetEntArray( self.target, "targetname" );
		
		if( IsDefined( targets ) )
			actor cqb_aim( random( targets ) );
		else
			actor cqb_aim( undefined );

	}
}

start_patrol( targetname, delay )
{
	if( IsDefined( delay ) )
		wait delay;
	
	self thread maps\_patrol::patrol( targetname );
}

//quick_kill( shooters, enemy, shots, delay_func )
quick_kill( shooters, enemy )
{
	if ( !IsDefined( enemy ) || !IsAlive( enemy ) )
	{
		return;
	}

	array_thread( shooters, ::cqb_aim, enemy );

//	if ( IsDefined( delay_func ) )
//	{
//		[[ delay_func ]]( shooters, enemy );
//	}

	if ( !IsDefined( enemy ) || !IsAlive( enemy ) )
	{
		array_thread( shooters, ::cqb_aim, undefined );
		return;
	}

	enemy.dontattackme = undefined;

	shots = 1;
	
	if ( shots == 1 )
	{
		enemy.health = 1;
	}

	// TODO: use GetMuzzlePos instead of getting tag_flash
	start_pos = shooters[ 0 ] GetTagOrigin( "tag_flash" );
	end_pos = enemy GetEye();//GetTagOrigin( "j_head" );
	trace = BulletTrace( start_pos, end_pos, true );

	if ( shooters.size > 1 )
	{
		if ( IsDefined( trace[ "entity" ] ) && trace[ "entity" ] == level._player )
		{
			shooters = array_reverse( shooters );
		}
	}

	// Play Fire anim
	num = RandomInt( shooters[ 0 ].a.array[ "single" ].size );
	fireanim = shooters[ 0 ].a.array[ "single" ][ num ];
	rate = 0.1 / WeaponFireTime( shooters[ 0 ].weapon );

	if ( !IsAlive( enemy ) )
	{
		array_thread( shooters, ::cqb_aim, undefined );		
		return;
	}

	for ( i = 0; i < shots; i++ )
	{
		if ( IsAlive( enemy ) )
		{
			end_pos = enemy GetTagOrigin( "j_head" );

			// On the last shot, make sure we kill him.
			if ( shots - i == 1 )
			{
				enemy.health = 1;
			}
		}

		offset = ( 0, 0, 0 );
		if ( shots - i > 1 )
		{
			offset = ( 0, 0, RandomFloatRange( 5, 15 ) * -1 );
		}

		shooters[ 0 ] SetFlaggedAnimKnobRestart( "fire_notify", fireanim, 1, 0.2, rate );
		shooters[ 0 ] waittillmatch_or_timeout( "fire_notify", "fire", 0.2 );

		start_pos = shooters[ 0 ] GetTagOrigin( "tag_flash" );
		
		shooters[ 0 ] safe_magic_bullet( start_pos, end_pos + offset );
	
		if ( shots - i > 1 )
		{
			wait( 0.15 + RandomFloat( 0.1 ) );
		}
	}

	if ( IsAlive( enemy ) )
	{
		if ( IsDefined( enemy.magic_bullet_shield ) )
		{
			enemy stop_magic_bullet_shield();
		}

		enemy Kill();
	}

	array_thread( shooters, ::cqb_aim, undefined );
}

safe_magic_bullet( start_pos, end_pos )
{
	fake_it = false;

	trace = BulletTrace( start_pos, end_pos, true );

	if ( IsDefined( trace[ "entity" ] ) && trace[ "entity" ] == level._player )
	{
		fake_it = true;
	}

	if ( IsDefined( trace[ "fraction" ] ) < 0.8 )
	{
		fake_it = true;
	}

	PlayFxOnTag( getfx( "silencer_flash" ), self, "tag_flash" );

	if ( fake_it )
	{
		angles = VectorToAngles( end_pos - start_pos );
		forward = AnglesToForward( angles );
		start_pos = end_pos + ( forward * -10 );
	}

	MagicBullet( self.weapon, start_pos, end_pos );
}

Waittillmatch_Or_Timeout( note1, note2, time )
{
	self notify( "waittillmatch_timeout" );

	self thread waittillmatch_timeout( time );
	self endon( "waittillmatch_timeout" );
	self endon( "death" );
	self waittillmatch( note1, note2 );

	self notify( "waittillmatch_timeout" );
}

waittillmatch_timeout( time )
{
	self endon( "waittillmatch_timeout" );
	wait( time );
	self notify( "waittillmatch_timeout" );
}

waittill_flags( flags )
{
	if( !IsArray( flags ) )
	{
		flags = [flags];
	}
		
	foreach( flag in flags )
	{
		level endon( flag );
	}		

	level waittill( "never" );
}