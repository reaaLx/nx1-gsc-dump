//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  MISSION DESCRIPTION											**
//                                                                          **
//    Created: 8/10/2011 - Alan Flores										**
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
// OUTRO                                                           *
//                                                                  *
//*******************************************************************

outro_start()
{
	//level._player maps\_nx_utility::move_player_to_start_point( "playerstart_outro" );
	flag_set( "flag_atrum_crash_done" );

	level._player.ignoreme = true;

	maps\nx_skyscraper_util::spawn_baker();

}

outro_sequence()
{
	flag_wait( "flag_atrum_crash_done" );
	level._player unlink();


	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

	flag_set( "flag_outro_start" );

	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_outro" );

	thread lobby_fire_fx();
	thread lobby_baker_control();
	thread lobby_squad_a_control();
	thread lobby_spawn_enemies();
	thread lobby_spawn_civilians();
	thread lobby_stumble_walk();
	thread outro_mission_end();
}

lobby_fire_fx()
{
	node_fire_fx01 = GetEnt( "node_fire_fx01", "targetname");
	PlayFx( level._effect[ "firelp_large_pm_bh1" ], node_fire_fx01.origin );
	node_fire_fx02 = GetEnt( "node_fire_fx02", "targetname");
	PlayFx( level._effect[ "firelp_large_pm_bh1" ], node_fire_fx02.origin );
	node_fire_fx03 = GetEnt( "node_fire_fx03", "targetname");
	PlayFx( level._effect[ "firelp_large_pm_bh1" ], node_fire_fx03.origin );	
	node_smoke_fx01 = GetEnt( "node_smoke_fx01", "targetname");
	PlayFx( level._effect[ "room_smoke_200" ], node_smoke_fx01.origin );
	// spawn the downed helicopter model
	node_crashed_heli = GetEnt( "node_crashed_heli", "targetname" );
	model = spawn( "script_model", node_crashed_heli.origin );
	model.angles = node_crashed_heli.angles;
	model setmodel( "vehicle_blackhawk_crash" );
	wait 0.25;
	explosion_base = GetEnt( "outro_explosion_base", "targetname");
	PlayFX( level._effect["nx_explosion_skybridge"], explosion_base.origin );
	wait 1.0;
	explosion_base = GetEnt( "outro_explosion_base2", "targetname");
	PlayFX( level._effect["nx_explosion_skybridge"], explosion_base.origin );
	fire_base1 = GetEnt( "fire_fallingdebris_base1", "targetname" );
	fire_base2 = GetEnt( "fire_fallingdebris_base2", "targetname" );
	fire_base3 = GetEnt( "fire_fallingdebris_base3", "targetname" );
	fire_base4 = GetEnt( "fire_fallingdebris_base4", "targetname" );
	fire_base5 = GetEnt( "fire_fallingdebris_base5", "targetname" );
	while(1)
	{
		PlayFX( level._effect["fire_fallingdebris"], fire_base1.origin );
		wait randomfloatrange(0.35, 1.0);
		PlayFX( level._effect["fire_fallingdebris"], fire_base4.origin );
		wait randomfloatrange(0.35, 1.0);
		PlayFX( level._effect["fire_fallingdebris"], fire_base3.origin );
		wait randomfloatrange(0.35, 1.0);
		PlayFX( level._effect["fire_fallingdebris"], fire_base2.origin );
		wait randomfloatrange(0.35, 1.0);
		PlayFX( level._effect["fire_fallingdebris"], fire_base5.origin );
		wait randomfloatrange(0.35, 1.0);
	}
}

lobby_baker_control()
{
	outro_vehicle = spawn_vehicle_from_targetname( "outro_vehicle" );
	baker_teleport = GetEnt ("baker_outro_teleport", "targetname");
	level.baker ForceTeleport( baker_teleport.origin, baker_teleport.angles);
	//wait 0.25;
	//
	baker_wounded_lobby();
	//level.baker.ignoreme = true;
	level.baker.ignorerandombulletdamage = true;
	level.baker.ignoresupression = true;
	level.baker.fixednode = false;
	level.baker.disableBulletWhizbyReaction = true;
	level.baker disable_pain();
	level.baker.dontavoidplayer = true;
	level.baker.goalradius = 8;
	baker_node = GetNode( "node_baker_outro1", "targetname" );
	level.baker SetGoalNode( baker_node );
	level.baker enable_cqbwalk(); 
}

baker_wounded_lobby()
{
	level.baker.ignoreall = true;
	level.baker.ignoreme = true;

	// level.baker.animname = "baker";
	node = GetEnt( "node_anim_wounded", "script_noteworthy" );
	node anim_reach_solo( level.baker, "hunted_dazed_walk_C_limp" );
	node anim_single_solo( level.baker, "hunted_dazed_walk_C_limp" );
	node2 = GetEnt( "node_anim_wounded2", "script_noteworthy" );
	node2 anim_single_solo( level.baker, "hunted_dazed_walk_C_limp" );
	node3 = GetEnt( "node_anim_wounded3", "script_noteworthy" );
	node3 anim_single_solo( level.baker, "hunted_dazed_walk_C_limp" );
	node4 = GetEnt( "node_anim_wounded4", "script_noteworthy" );
	//node4 anim_single_solo( level.baker, "hunted_dazed_walk_C_limp" );
	node4 anim_single_run_solo( level.baker, "hunted_dazed_walk_C_limp" );
}

lobby_squad_a_control()
{
	level.squad_a1 = spawn_targetname( "squad_A1", true );
	level.squad_a2 = spawn_targetname( "squad_A2", true );
	wait 0.25;

	level.squad_a1.goalradius = 8;
	level.squad_a2.goalradius = 8;
	squad_a1_node = GetNode( "node_guard_A1", "targetname" );
	squad_a2_node = GetNode( "node_guard_A2", "targetname" );
	level.squad_a1 SetGoalNode( squad_a1_node );
	level.squad_a2 SetGoalNode( squad_a2_node );
	level.squad_a1 magic_bullet_shield();
	level.squad_a2 magic_bullet_shield();
	//level.squad_a1 waittill( "goal" );
	wait 3.5;
	level.baker.ignoreme = true;
	//thread add_dialogue_line( "Squad A", "Baker!  Spectre!  We've got an exfil vehicle outside.  Move, move, move!", "g" );
	radio_dialogue( "sky_teama_outro_exfiloutside" );
	flag_wait( "flag_outro_start" );
	move_trigger = getent ( "squad_A_move_trigger", "targetname" );
	move_trigger waittill( "trigger" );
	squad_a1_node = GetNode( "node_guard_A1_1", "targetname" );
	squad_a2_node = GetNode( "node_guard_A2_1", "targetname" );
	level.squad_a1 SetGoalNode( squad_a1_node );
	level.squad_a2 SetGoalNode( squad_a2_node );

	//thread add_dialogue_line( "Squad A", "Let's go.  Now!", "g" );
	radio_dialogue( "sky_teama_outro_letsgonow" );
}

lobby_spawn_enemies()
{
	array_thread( GetEntArray( "outro_enemies", "script_noteworthy" ), ::spawn_ai );
	// if the player hasn't hit the exit yet flood the place with enemies and kill the player
	wait 20.0;
	level.squad_a1.ignoreme = true;
	level.squad_a2.ignoreme = true;
	level._player.ignoreme = false;
	array_thread( GetEntArray( "outro_enemy_flood", "script_noteworthy" ), ::spawn_ai );

}

lobby_spawn_civilians()
{
	array_thread( GetEntArray( "outro_civilian_spawner", "script_noteworthy" ), ::spawn_ai );

	//spawners = GetEntArray( "outro_civilian_spawner", "script_noteworthy" );
	//array_thread( spawners, ::spawn_ai );
	//wait 0.1;
	//spawners = get_living_ai_array( "outro_civilian_spawner", "script_noteworthy" );
	spawners = get_living_ai_array( "outro_civilian_no_death", "targetname" );
	foreach (spawner in spawners)
	{
		spawner magic_bullet_shield();
		spawner.a.nodeath = true;
		spawner setCanDamage( false );
	}
}

lobby_stumble_walk()
{

	level._player shellshock("default", 100);
	level thread player_wakeup_movement_speed( 0.8 );

	black_overlay = maps\_hud_util::create_client_overlay( "black", 1 );
	black_overlay maps\_hud_util::fade_over_time( 1, 0.5 );		// Fade Out
	wait 0.2;
	black_overlay maps\_hud_util::fade_over_time( 0, 1.0 );		// Fade In
	wait 0.4;
	black_overlay Destroy();

	level._ground_ref_ent = spawn( "script_model", ( 0, 0, 0 ) );
	level._player playerSetGroundReferenceEnt( level._ground_ref_ent );
}

player_wakeup_movement_speed( speed )
{
	level._player AllowCrouch( false );
	level._player AllowProne( false );
	level._player AllowJump( false );
	level._player AllowSprint( false );

	// Turn off the stance HUD indicator while the player cannot crouch
	SetSavedDvar( "ammoCounterHide", "1" );

	level._player blend_movespeedscale( 0.25, 0.1 );
	level._player delayThread( 1, ::blend_movespeedscale, speed, 5 );
}

outro_mission_end()
{
	flag_wait( "flag_outro_start" );
	end_mission_trigger = getent ( "end_mission_trigger", "targetname" );
	end_mission_trigger waittill( "trigger" );
	nextmission();
}

