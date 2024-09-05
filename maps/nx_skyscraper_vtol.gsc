//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  MISSION DESCRIPTION											**
//                                                                          **
//    Created: 7/15/2011 - Ken Moodie										**
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
// VTOL                                                             *
//                                                                  *
//*******************************************************************

vtol_start()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_vtol_new" );

	thread maps\nx_skyscraper_fx::set_vision_and_fog("vtol", 0); // set appropriate vision and fog

	maps\nx_skyscraper_util::player_weapon_init( true );
	
	thread maps\_utility::set_ambient( "amb_skyscraper_office_int" );

	maps\nx_skyscraper_util::spawn_baker();
	baker_teleport = GetEnt ("baker_vtol_teleport", "targetname");
	level.baker disable_pain();
	//issue_color_orders ("r80", "allies");
	level.baker ForceTeleport( baker_teleport.origin, baker_teleport.angles);

	// Show cloud ring.
	thread fx_show_cloud_ring();	
}

vtol_sequence()
{
	/* // Gameplay removed to accomodate animatic
	// allow player to kill more civilians before failing the mission
	level._friendlyfire[ "friend_kill_points" ] 	 = -100;

	thread autosave_now();
	thread vtol_player_fire_blockers();
	thread vtol_attack_spawn_closet();
	thread vtol_scientists();
	thread lab_vtol_setup();
	// thread vtol_dialog();
	thread vtol_temp_timing();
	thread vtol_enemies_logic();
	thread cover_health_watcher( "vtol_cover_c" );
	thread cover_health_watcher( "vtol_cover_d" );
	thread cover_health_watcher( "vtol_cover_e" );
	thread cover_health_watcher( "vtol_cover_f" );
	*/
	thread maps\_utility::set_ambient( "amb_skyscraper_office_int" );
	thread autosave_now();
	thread vtol_control();
//	thread vtol_fire_hurt_volumes();
	thread vtol_squad_control();
	thread vtol_enemy_control();
	thread vtol_player_fire_blockers();
	thread vtol_collapse_temp_dialogue();
	// thread laser_setup();
	level.baker thread baker_office_movement();

	thread office_enemies_logic();

	// Prepare for sat view pip
	thread maps\nx_skyscraper_util::play_pip_bink( "skyscraper_view_pip1", undefined, "play_orbital_pip_1" );
	exploder( "fx_vtol_ambient" );

	flag_wait( "flag_vtol_floor_collapse_done" );
	thread autosave_now();
	thread fx_kill_vtol_fx();
	Exploder( "fx_office_inferno" );
	level waittill ("office_enemies_dead");
	// maps\nx_skyscraper_rappel::rappel_sequence();
}

// new vtol encounter stuff

vtol_control()
{
	level endon ("destroy_all_vtols");
	level.lab_vtol2 = spawn_vehicle_from_targetname_and_drive( "lab_vtol_spawner2" );
	level.lab_vtol2.ignoreAll = true;
	level.lab_vtol2 godon();
	setsaveddvar( "r_spotlightbrightness", "2.5" );
	level.lab_vtol2 thread maps\_attack_heli::heli_spotlight_on( undefined, true );
	level.lab_vtol2 SetLookAtEnt( level._player );
	level.lab_vtol2 maps\_nx_chinese_vtol::vtol_enable_turrets();
	foreach ( turret in level.lab_vtol2.mgturret )
	{
		turret SetAISpread( 40 );
	}
	flag_wait( "flag_uav_blow_shutters" );
	level.lab_vtol2 thread maps\_attack_heli::heli_spotlight_off();
	Exploder( "fx_vtol_dust" );
	//thread add_dialogue_line( "Baker", "Keep VTOL incoming!", "g" );
	level.baker dialogue_queue( "sky_bak_vtol_vtolincoming" );
	wait 0.5;
	uav_target = GetEnt( "stair_target00", "targetname" );
	thread heli_target_missile_with_fire( level.lab_vtol2, uav_target, 1.0, -100 );

	wait 0.35;
	// slomo
	//
	uav_target = GetEnt( "stair_target01", "targetname" );
	thread heli_target_missile_with_fire( level.lab_vtol2, uav_target, 1.0, -100 );
	// physics push 
	explo_base = GetEnt( "stair_base01", "targetname");
	PhysicsExplosionSphere( explo_base.origin, 300, 299, 3 );
	wait 0.2;	
	explo_base = GetEnt( "stair_base02", "targetname");
	PhysicsExplosionSphere( explo_base.origin, 300, 299, 3 );
	wait 0.15;
	vtol_column = GetEnt( "vtol_column", "targetname" );
	vtol_column delete();
	explo_base = GetEnt( "stair_base03", "targetname");
	PhysicsExplosionSphere( explo_base.origin, 300, 299, 3 );
	//thread vtol_slow_mo();
	uav_target = GetEnt( "stair_target02", "targetname" );
	thread heli_target_missile_with_fire( level.lab_vtol2, uav_target, 1.0, -100 );
	wait 0.35;
	uav_target = GetEnt( "stair_target03", "targetname" );
	thread heli_target_missile_with_fire( level.lab_vtol2, uav_target, 1.0, -100 );
	shutters = GetEnt( "shutters01", "targetname" );
	shutters delete();
	exploder( "fx_vtol_exp_dust_01" );
	wait 0.1;
	shutters = GetEnt( "shutters01b", "targetname" );
	shutters delete();
	wait 0.9;
	flag_set( "flag_baker_move1" );
	//flag_wait( "flag_baker_pos1" );
	// shoot rockets near the player until he moves on
	//wait 5.0;
	//walltarget = GetEnt( "vtol_walltarget01", "targetname" );
	//while( !flag( "flag_baker_pos1" ))
	/* while( !flag( "flag_spawn_wave2" ))
	{
		MagicBullet( "rpgx_straight", level.lab_vtol2.origin + (0, 100, -100), level._player.origin + (0, RandomIntRange(-175, 175), RandomIntRange(200, 250)));
		wait 1.5;
	} */
	flag_wait( "flag_spawn_wave2" );
	//level.lab_vtol2 thread maps\_attack_heli::heli_spotlight_off();
	wait 0.1;
	level.lab_vtol2 delete();
	level.lab_vtol3 = spawn_vehicle_from_targetname_and_drive( "lab_vtol_spawner3" );
	level.lab_vtol3.ignoreAll = true;
	level.lab_vtol3 godon();
	setsaveddvar( "r_spotlightbrightness", "2.5" );
	//level.lab_vtol3 thread maps\_attack_heli::heli_spotlight_on( undefined, true );
	level.lab_vtol3 SetLookAtEnt( level._player );
	level.lab_vtol3 maps\_nx_chinese_vtol::vtol_enable_turrets();
	foreach ( turret in level.lab_vtol3.mgturret )
	{
		turret SetAISpread( 40 );
	}
	wait 3.5;
	//wait 0.5;
	uav_target = GetEnt( "pos1_target01", "targetname" );
	thread heli_target_missile_with_fire( level.lab_vtol3, uav_target, 1.0, -100 );
	wait 0.35;
	shutters = GetEnt( "shutters02", "targetname" );
	shutters delete();
	exploder( "fx_vtol_exp_dust_02" );

	uav_target = GetEnt( "pos1_target02", "targetname" );
	thread heli_target_missile_with_fire( level.lab_vtol3, uav_target, 1.0, -100 );
	wait 0.35;
	uav_target = GetEnt( "pos1_target03", "targetname" );
	thread heli_target_missile_with_fire( level.lab_vtol3, uav_target, 1.0, -100 );
	//
	explo_base = GetEnt( "explo_base03", "targetname");
	PhysicsExplosionSphere( explo_base.origin, 300, 299, 3 );
	wait 0.35;
	// physics push the blocks and kill any nearby dudes
	explo_base = GetEnt( "explo_base01", "targetname");
	PhysicsExplosionSphere( explo_base.origin, 20, 19, 3 );
	volume = GetEnt( "enemy_kill_volume", "targetname" );
	ai = GetAIArray();
	foreach( guy in ai )
	{	
		if( guy IsTouching( volume) && !guy is_hero() )
			guy kill();
	}
	//
	coverbox = GetEnt( "coverbox01", "targetname" );
	coverbox delete();
	shutters = GetEnt( "shutters03", "targetname" );
	shutters delete();
	coverbox = GetEnt( "coverbox02", "targetname" );
	coverbox delete();
	wait 1.0;
	flag_set( "flag_baker_move2" );

	// shoot rockets near the player until he moves on
	//flag_wait( "flag_spawn_wave3" );
	/* while( !flag( "flag_spawn_wave3" ))
	{
		MagicBullet( "rpgx_straight", level.lab_vtol3.origin + (0, 100, -100), level._player.origin + (0, RandomIntRange(-175, 175), RandomIntRange(225, 275)));
		wait 1.5;
	} */
	flag_wait( "flag_spawn_wave3" );
	flag_wait( "flag_baker_explo_pos" );
	// physics push the blocks
	explo_base = GetEnt( "explo_base02", "targetname");
	thread heli_target_missile_with_fire( level.lab_vtol3, explo_base, 0.0, -100 );
	wait 0.1;
	flag_set( "flag_baker_blown_up" );
	PhysicsExplosionSphere( explo_base.origin, 200, 199, 3 );
	/* volume = GetEnt( "enemy_kill_volume2", "targetname" );
	ai = GetAIArray();
	foreach( guy in ai )
	{	
		if( guy IsTouching( volume) && !guy is_hero() && !guy.magic_bullet_shield )
			guy kill();
	} */
	//flag_wait( "flag_baker_pos2" );
	wait 5.0;
	//
	//level.lab_vtol3 thread maps\_attack_heli::heli_spotlight_off();
	wait 0.1;
	level.lab_vtol3 delete();
	level.lab_vtol4 = spawn_vehicle_from_targetname_and_drive( "lab_vtol_spawner4" );
	level.lab_vtol4.ignoreAll = true;
	level.lab_vtol4 godon();
	setsaveddvar( "r_spotlightbrightness", "2.5" );
	//level.lab_vtol4 thread maps\_attack_heli::heli_spotlight_on( undefined, true );
	level.lab_vtol4 SetLookAtEnt( level._player );
	level.lab_vtol4 maps\_nx_chinese_vtol::vtol_enable_turrets();
	foreach ( turret in level.lab_vtol4.mgturret )
	{
		turret SetAISpread( 20 );
	}
	wait 1.5;
	uav_target = GetEnt( "pos2_target01", "targetname" );
	thread heli_target_missile_with_fire( level.lab_vtol4, uav_target, 1.0, -100 );
	wait 0.35;
	uav_target = GetEnt( "pos2_target02", "targetname" );
	thread heli_target_missile_with_fire( level.lab_vtol4, uav_target, 1.0, -100 );
	wait 0.35;
	uav_target = GetEnt( "pos2_target03", "targetname" );
	thread heli_target_missile_with_fire( level.lab_vtol4, uav_target, 1.0, -100 );
	coverbox = GetEnt( "coverbox03", "targetname" );
	coverbox delete();
	//
	vtol_column = GetEnt( "vtol_column02", "targetname" );
	vtol_column delete();
	wait 0.5;
	coverbox = GetEnt( "coverbox04", "targetname" );
	coverbox delete();
	//
	vtol_column = GetEnt( "vtol_column03", "targetname" );
	vtol_column delete();

	// check if player is in volume and shellshock him if he is
	//volume = GetEnt( "shellshock_volume", "targetname" );
	//if( level._player IsTouching( volume ))
	//	level._player shellshock("default", 3);
	wait 1.0;
	flag_set( "flag_baker_move3" );
	flag_wait( "flag_baker_end_pos" );
	flag_wait( "flag_player_move_end" );
	uav_target = GetEnt( "pos3_target01", "targetname" );
	thread heli_target_missile_with_fire( level.lab_vtol4, uav_target, 1.0, -100 );
	wait 0.35;
	uav_target = GetEnt( "pos3_target02", "targetname" );
	thread heli_target_missile_with_fire( level.lab_vtol4, uav_target, 1.0, -100 );
	//coverbox = GetEnt( "coverbox07", "targetname" );
	//coverbox delete();
	//coverbox = GetEnt( "coverbox08", "targetname" );
	//coverbox delete();
	wait 0.75;
	coverbox = GetEnt( "coverbox05", "targetname" );
	coverbox delete();
	coverbox = GetEnt( "coverbox06", "targetname" );
	coverbox delete();
	wait 2.0;
	uav_target = GetEnt( "pos3_target03", "targetname" );
	thread heli_target_missile_with_fire( level.lab_vtol4, uav_target, 1.0, -100 );
	wait 0.75;
	coverbox = GetEnt( "coverbox09", "targetname" );
	coverbox delete();
	coverbox = GetEnt( "coverbox10", "targetname" );
	coverbox delete();
	coverbox = GetEnt( "coverbox11", "targetname" );
	coverbox delete();
	flag_wait( "flag_vtol_delete" );
	level.lab_vtol4 delete();

}

heli_target_missile_with_fire(heli, target, delay, fire_offset2)
{
	fire_offset = 100;
	MagicBullet( "rpgx_straight", heli.origin + (0, fire_offset, fire_offset2), target.origin);
	wait( delay );
	PlayFX( level._effect["explosion_type_1"], target.origin );
//	wait 0.2;
//	PlayFX( level._effect["nx_smoke_n_fire_plume_preseed"], target.origin );
}

vtol_fire_hurt_volumes()
{
	flag_wait( "flag_baker_move1" );
	hurt_volume = GetEnt( "hurt_volume1", "targetname" );
	//while(1)
	while( !flag( "flag_baker_move2" ) )
	{
		if( level._player IsTouching( hurt_volume ))
			{
			level._player StunPlayer( 1.5 );
			level._player thread play_sound_on_entity( "breathing_hurt" );
			if( level._player.health > 34 )
				level._player.health = level._player.health - 34;
			else
				//level._player.health = 0;
				level._player kill();
			}
		wait 1.5;
	}
	hurt_volume = GetEnt( "hurt_volume2", "targetname" );
	while( !flag( "flag_baker_move3" ) )
	{
		if( level._player IsTouching( hurt_volume ))
			{
			level._player StunPlayer( 1.5 );
			level._player thread play_sound_on_entity( "breathing_hurt" );
			if( level._player.health > 34 )
				level._player.health = level._player.health - 34;
			else
				//level._player.health = 0;
				level._player kill();
			}
		wait 1.5;
	}
	hurt_volume = GetEnt( "hurt_volume3", "targetname" );
	while( 1 )
	{
		if( level._player IsTouching( hurt_volume ))
			{
			level._player StunPlayer( 1.5 );
			level._player thread play_sound_on_entity( "breathing_hurt" );
			if( level._player.health > 34 )
				level._player.health = level._player.health - 34;
			else
				//level._player.health = 0;
				level._player kill();
			}
		wait 1.5;
	}
}

vtol_squad_control()
{
	level endon ("destroy_all_vtols");
	//level.baker = spawn_targetname( "baker_uav", true);
	//level.baker magic_bullet_shield();
	level.baker.ignoreme = true;
	level.baker.ignorerandombulletdamage = true;
	level.baker.ignoresupression = true;
	level.baker.disableBulletWhizbyReaction = true;
	level.baker disable_pain();
	level.baker.dontavoidplayer = true;
	level.baker.goalradius = 8;
	// Add objective marker on Baker
	//Objective_Add( 1, "current", "Follow Baker to the exfil point" );
	//Objective_OnEntity( 1, level.baker );

	flag_wait( "flag_baker_move" );
	thread add_dialogue_line( "Baker", "Tangos up ahead!", "g" );
	node_baker = getnode( "node_baker_cover", "targetname" );
	level.baker SetGoalNode( node_baker );
	level.baker waittill( "goal" );

	flag_wait( "flag_baker_move0" );
	node_baker = getnode( "node_baker_cover00", "targetname" );
	level.baker SetGoalNode( node_baker );
	level.baker waittill( "goal" );

	flag_wait( "flag_baker_move1" );
	// first delete the ai blocker
	ai_blocker = GetEnt( "brush_ai_blocker", "targetname" );
	ai_blocker delete();
	//thread add_dialogue_line( "Baker", "It's targetting us.  Get to hard cover", "g" );
	level.baker dialogue_queue( "sky_bak_vtol_targetingusgetcover" );
	// Baker Melee anim stuff
	node_baker = getnode( "node_baker_melee_start", "targetname" );
	level.baker SetGoalNode( node_baker );
	level.baker waittill( "goal" );
	anim_node = GetEnt( "node_baker_melee", "targetname" );
	melee_victim = spawn_targetname( "baker_melee_victim", true );
	melee_victim.animname = "victim";
	guys = []; 
	guys["ally_01"] = level.baker;
	guys["victim"] = melee_victim;

	anim_node anim_single( guys, "baker_vtol_melee" );
	melee_victim kill();
	

	// End Baker Melee anim stuff
	node_baker = getnode( "node_baker_cover01", "targetname" );
	level.baker SetGoalNode( node_baker );
	level.baker waittill( "goal" );
	flag_wait( "flag_spawn_wave2" );
	//thread add_dialogue_line( "Baker", "Team A, we can't handle this VTOL! Get us KillSat clearance now!", "g" );
	level.baker dialogue_queue( "sky_bak_vtol_needkillsatclearance" );
	flag_set( "flag_baker_pos1" );
	flag_wait( "flag_baker_move2" );
	//thread add_dialogue_line( "Baker", "Keep moving up !", "g" );
	level.baker dialogue_queue( "sky_bak_vtol_keepmovingup" );
	// Baker getting blown up anim
	// first delete the ai blocker
	ai_blocker = GetEnt( "brush_ai_blocker2", "targetname" );
	ai_blocker delete();
	wait 0.1;
	// then send baker to his node
	/* node_baker = getnode( "node_baker_blownup", "targetname" );
	level.baker SetGoalNode( node_baker );
	level.baker.ignoreall = true;
	level.baker waittill( "goal" );
	anim_node = GetEnt( "node_anim_baker_thrown", "targetname" );
	anim_node anim_reach_solo( level.baker, "corner_standR_explosion_divedown" ); */
	flag_set( "flag_baker_explo_pos" );
	//flag_wait( "flag_spawn_wave3" );
	//flag_wait( "flag_baker_blown_up" );
	//thread vtol_slow_mo();

	// check if player is in volume and shellshock him if he is
	/* volume = GetEnt( "shellshock_volume", "targetname" );
	if( level._player IsTouching( volume ))
		{
		level._player AllowStand( false );
		level._player AllowCrouch( false );
		level._player shellshock("default", 4);
		earthquake( 3, 0.2, level._player.origin, 2000 );
		}
	anim_node anim_single_solo( level.baker, "corner_standR_explosion_divedown" ); */
	// baker getup anim
	/* anim_node = GetEnt( "node_anim_baker_getup", "targetname" );
	anim_node anim_single_solo( level.baker, "hunted_pronehide_2_stand_v2" );
	level.baker.ignoreall = false; */
	//if( level._player IsTouching( volume ))
		//{
		/* level._player AllowStand( true );
		level._player AllowCrouch( true );
		if( level._player IsTouching( volume ))
			level._player Allowprone( false );
		wait 0.1;
		level._player Allowprone( true ); */
		//}
	// first delete the ai blocker
	ai_blocker = GetEnt( "brush_ai_blocker3", "targetname" );
	ai_blocker delete();
	// End Baker getting blown up anim
	node_baker = getnode( "node_baker_cover02", "targetname" );
	level.baker SetGoalNode( node_baker );
	level.baker waittill( "goal" );
	//add_dialogue_line( "Team A", "We're on the horn with C&C now, but this is a tall order. We'll need time.", "purple", 4 );
	radio_dialogue( "sky_teama_vtol_onthehorn" );
	//add_dialogue_line( "Baker", "The sooner the better!", "green", 2 );
	level.baker dialogue_queue( "sky_bak_vtol_soonerthebetter" );
	flag_set( "flag_baker_pos2" );
	flag_wait( "flag_baker_move3" );
	wait 1.5;
	//thread add_dialogue_line( "Baker", "Behind the pillar.  Go!", "g" );
	level.baker dialogue_queue( "sky_bak_vtol_getbehindpillar" );
	//add_dialogue_line( "Team A", "Any time is good, Team A!", "green", 2 );
	level.baker dialogue_queue( "sky_bak_vtol_anytimeisgood" );
	node_baker = getnode( "node_baker_cover03", "targetname" );
	level.baker SetGoalNode( node_baker );
	level.baker waittill( "goal" );
	flag_set( "flag_baker_end_pos" );
	//add_dialogue_line( "Baker", "We've got an uplink to C&C, patching you through now.", "green", 2 );
	radio_dialogue( "sky_teama_vtol_uplink" );
}

vtol_enemy_control()
{
	flag_wait( "flag_baker_move" ); 
	spawners = getentarray( "uav_enemies_wave1", "targetname" );
	//array_thread( spawners, ::spawn_ai );
	foreach( spawner in spawners )
	{
		// spawn and then add a wait to offset animations
		spawner spawn_ai();
		wait 0.2;
	}
	flag_wait( "flag_spawn_wave2" );
	spawners = getentarray( "uav_enemies_wave2", "targetname" );
	//array_thread( spawners, ::spawn_ai );
	foreach( spawner in spawners )
	{
		// spawn and then add a wait to offset animations
		spawner spawn_ai();
		wait 0.2;
	}
	flag_wait( "flag_spawn_wave3" );
	// spawn dudes
	spawners = getentarray( "uav_enemies_wave3", "targetname" );
	//array_thread( spawners, ::spawn_ai );
	foreach( spawner in spawners )
	{
		// spawn and then add a wait to offset animations
		spawner spawn_ai();
		wait 0.2;
	}
}

vtol_slow_mo()
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
	//slomoSpeed = 0.225;
	//slomoDuration = 10;
	slomoSpeed = 0.2;
	slomoDuration = 8;

	//music_stop();
	
	// Start slo motion
	slowmo_start();
	slowmo_setspeed_slow( slomoSpeed );
	slowmo_setlerptime_in( slomoLerpTime_in );
	slowmo_lerp_in();
	
	level._player SetMoveSpeedScale( slomobreachplayerspeed );
	 
	// Wait slo mo duration
	wait slomoDuration * slomoSpeed;
	
	// Stop slo motion
	slowmo_setlerptime_out( slomoLerpTime_out );
	slowmo_lerp_out();
	slowmo_end();
	level._player SetMoveSpeedScale( 1.0 );
}

vtol_collapse_temp_dialogue()
{
	flag_wait( "flag_uav_crash" );

	// Play sat view pip
	flag_set ("play_orbital_pip_1");
	// timed out to match the currently blocked in vtol crash scene
	wait 1.5;
	//thread add_dialogue_line( "Baker", "Finally. Specter, lase the VTOL while I get its attention.", "g" );
	level.baker dialogue_queue( "sky_bak_vtol_lasevtol" );
	wait 4.0;
	//thread add_dialogue_line( "Baker", "Ready? 1.. 2.. 3...", "g" );
	level.baker dialogue_queue( "sky_bak_vtol_readyon3" );
	//wait 0.5;
	//thread add_dialogue_line( "Baker", "Now! Over here, you bucket of bolts!", "g" );
	level.baker dialogue_queue( "sky_bak_vtol_now" );
	wait 1.75;
	//thread add_dialogue_line( "Baker", "Way to go! Now we just need to figure out a new way out of here.", "g" );
	level.baker dialogue_queue( "sky_bak_vtol_waytogo" );
	//thread add_dialogue_line( "Baker", "Fffffuuuuuuuuu.....!", "g" );
	level.baker dialogue_queue( "sky_bak_vtol_fuuu" );
}

vtol_collapse_reposition_player()
{
	flag_wait( "flag_vtol_floor_collapse_done" );
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_vtol_floor_collapse" );
}

// end new vtol encounter stuff
//
//
//

lab_vtol_setup()
{
	//trigger = GetEnt ("vtol_attack", "targetname");
	//trigger waittill ("trigger");
	level waittill ("spawn_vtol");

	level.lab_vtol = spawn_vehicle_from_targetname_and_drive( "lab_vtol_spawner" );

	level.lab_vtol.targetname = "lab_vtol";
	level.lab_vtol godon();
	
	foreach ( turret in level.lab_vtol.mgturret )
	{
		turret SetAISpread( 15 );
	}
	

	// Start it out generally looking towrds where the player came from
	//target = GetEnt( "vtol_rocket_target_a" , "targetname");
	//level.lab_vtol SetLookAtEnt( target );

	level.lab_vtol SetVehicleTeam( "allies" );
	//level.lab_vtol vtol_behavior();
	floor_collapse();
}
/*
vtol_scientists()
{
	vtol_scientists = [];
	vtol_scientists [ vtol_scientists.size ] = spawn_targetname ( "vtol_scientist_runner_1" );
	vtol_scientists [ vtol_scientists.size ] = spawn_targetname ( "vtol_scientist_runner_2" );
	vtol_scientists [ vtol_scientists.size ] = spawn_targetname ( "vtol_scientist_runner_3" );
	foreach ( scientist in vtol_scientists)
	{
		scientist.ignoreall = true;
		scientist.goalradius = 64;
		// scientist waittill ( "goal" );
		// scientist delete();
	}
}

vtol_behavior()
{
	self endon ("death");

	// Destroy the path back to the staircase
	fire_rocket_1 = GetStruct( "fire_rocket_1", "script_noteworthy" );
	fire_rocket_1 waittill ( "trigger" );
	self thread vtol_rocket_attack ( "vtol_rocket_target_a" );

	// Wait until the end of the first path is reached
	done_with_intro = GetStruct( "vtol_done_with_intro", "script_noteworthy" );
	done_with_intro waittill ( "trigger" );

	// Start trying to kill Player and Baker
	self SetVehicleTeam( "axis" );
	self thread maps\_attack_heli::heli_spotlight_on( undefined, true );
	self vehicle_detachfrompath();

	// Destroy the second target.
	self vtol_rocket_attack ( "vtol_rocket_target_c" );

	self vtol_move_to( "vtol_position_c" );

	iprintln( "Moving to position c" );

	// Wait until the player moves forward, or the conversation indicates they should move forward
	flag_wait_any ( "vtol_target_area_d", "force_vtol_move_d" );

	self vtol_move_to( "vtol_position_d" );

	iprintln( "Moving to position d" );

	// Wait until the player moves forward, or the conversation indicates they should move forward
	flag_wait_any ( "vtol_target_area_e", "force_vtol_move_e" );
	// Destroy the cover piece
	self thread vtol_rocket_attack ( "vtol_cover_d" );

	self vtol_move_to( "vtol_position_e" );

	iprintln( "Moving to position e" );

	// Wait until the player moves forward, or the conversation indicates they should move forward
	flag_wait_any ( "vtol_target_area_f", "force_vtol_move_f" );
	// Destroy the cover piece
	self thread vtol_rocket_attack ( "vtol_cover_e" );
	
	self vtol_move_to( "vtol_position_f" );
	iprintln( "Moving to position f" );

	self vehicle_resumepath();

	level waittill ( "baker_distracts_vtol" );
	self SetLookAtEnt( level.baker );
	
	foreach ( turret in level.lab_vtol.mgturret)
	{
		// Make it miss Baker at least sometimes while he's distracting it.
		turret SetTurretTargetPosition( level.baker.origin );
		turret SetAISpread( 2 );
	}
	self vehicle_detachfrompath();
	heli_goal = GetStruct( "vtol_position_final", "script_noteworthy" );	
	// self AttachPath ( heli_goal);
	iprintln( "Moving to final position" );
	self.currentnode = heli_goal;
}

vtol_move_to( goal )
{
	heli_goal = GetStruct( goal , "script_noteworthy" );
	self SetVehGoalPos( heli_goal.origin, true );	
}
*/
vtol_player_fire_blockers()
{
	// First make sure they have no collision initially.
	blocker_a = GetEnt ( "fire_block_a", "targetname" );
	blocker_c = GetEnt ( "fire_block_c", "targetname" );
	blocker_a NotSolid();
	blocker_c NotSolid();
	
}
/*
vtol_kill_zone ( targetname )
{
	level endon ( "floor_collapsed" );
	kill_zone = GetEnt ( targetname, "targetname" );
	kill_zone waittill ( "trigger" );
	level.lab_vtol SetLookAtEnt ( level._player );
	add_dialogue_line( "Baker", "You're gonna get killed out there! Get to hard cover!", "green", 2 );
	wait 2;
	if ( level._player isTouching ( kill_zone ))
		foreach ( turret in level.lab_vtol.mgturret)
		{
			turret SetTurretTargetPosition( level._player.origin );
			turret SetAISpread( 2 );
			level._player kill();
		}
	vtol_kill_zone ( targetname );
}

vtol_attack_spawn_closet()
{
	level endon ( "floor_collapsed" );
	// To prevent the player from making a dash for the spawn closet.
	flag_wait ( "vtol_target_area_g" );
	level.lab_vtol thread vtol_rocket_attack ( "vtol_rocket_target_g" );
	vtol_kill_zone ( "vtol_target_area_g" );
}

vtol_baker_distraction_timeout()
{
	// Eventually, there should be a time limit on how long Baker can survive in the open.
}

vtol_enemies_logic()
{
	// Baker will advance when the cover is destroyed, even if there are enemies nearby. He's running for his life, after all.
	level.baker.fixednode = true;
	
	level.vtol_enemies = [];

	// Wave 1
	vtol_enemies_spawn_function ( "vtol_wave_1_enemy_spawner_1" );
	vtol_enemies_spawn_function ( "vtol_wave_1_enemy_spawner_2" );

	flag_wait_any ( "vtol_target_area_e", "force_vtol_move_e", "vtol_spawn_wave_2" );

	// Wave 2
	vtol_enemies_spawn_function ( "vtol_wave_2_enemy_spawner_1" );
	vtol_enemies_spawn_function ( "vtol_wave_2_enemy_spawner_2" );

	flag_wait_any ( "vtol_target_area_f", "force_vtol_move_f", "vtol_spawn_wave_3" );

	// Wave 3
	vtol_enemies_spawn_function ( "vtol_wave_3_enemy_spawner_1" );
	vtol_enemies_spawn_function ( "vtol_wave_3_enemy_spawner_2" );

	waittill_dead_or_dying ( level.vtol_enemies );
	// iprintln ( "Everybody dead!" );
	flag_set ( "vtol_enemies_dead" );

	// Back to regular behavior
	level.baker.fixednode = false;

}

vtol_enemies_spawn_function( targetname )
{
	enemy = spawn_targetname ( targetname);
	level.vtol_enemies[level.vtol_enemies.size] = enemy;
	enemy SetIsVisibleInXray();
	// These guys shouldn't pose much of an actual threat
	enemy.accuracy = 0.5;
	//enemy.health = 25;
	// Make sure they don't ragdoll through the floor (which is a script_brushmodel), or bleed all over it
	enemy.skipBloodPool = true;
	enemy.noragdoll = true;
	// And they know where Baker is right away.
	enemy getEnemyInfo( level.baker );
}


vtol_rocket_attack ( targetname  )
{
	self endon ( "death" );
	target = GetEnt( targetname , "targetname" );
	destination = target.origin;
	self SetLookAtEnt( target);
	// Can't seem to get proper rockets to aim precisely
	// self thread maps\_attack_heli::heli_fire_missiles( target, 2, .5 );
	// MagicBullet( "rpgx_straight", (self GetTagOrigin("tag_missile_left")), (target.origin + randomvectorrange ( 1, 3)) );
	// wait .3;
	rocket = MagicBullet( "rpgx_straight", (self GetTagOrigin( "tag_missile_right" )), (destination + randomvectorrange ( 1, 3)) );
	rocket waittill ( "death" );

	// Start a fire at the target location. Should set up a way to turn these all off later.
	PlayLoopedFX( level._effect[ "firelp_large_pm_bh1" ] , 2, destination );	

	self ClearLookAtEnt();
	self SetLookAtEnt( level.baker );
}

vtol_baker_behavior()
{
	
}

cover_health_watcher( cover_targetname )
{
	cover = GetEnt ( cover_targetname, "targetname");
	cover SetCanDamage( true );
	while ( 1 )
	{
		// Wait until hit by the VTOL's rocket
		cover waittill ("damage", damage, attacker, direction_vec, point, type );
		if ( type == "MOD_PROJECTILE")
			break;
		wait .1;
	}
	PlayFX( level._effect[ "concrete_pillar_explosion"], cover.origin, (-1,0,0) );
	cover delete();

	cover = GetEnt ( cover_targetname + "_2", "targetname");
	cover SetCanDamage( true );
	
	while ( 1 )
	{
		// Wait until hit by the VTOL's second rocket
		cover waittill ("damage", damage, attacker, direction_vec, point, type );
		if ( type == "MOD_PROJECTILE")
			break;
		wait .1;
	}

	PlayFX( level._effect[ "concrete_pillar_explosion"], cover.origin, (-1,0,0) );
	cover delete();

}

vtol_temp_timing()
{
	flag_wait ("vtol_target_area_a");
	level notify ("spawn_vtol");
	// wait for first rocket
	fire_rocket_1 = GetStruct( "fire_rocket_1", "script_noteworthy" );
	fire_rocket_1 waittill ( "trigger" );
	level.lab_vtol thread vtol_rocket_attack ( "vtol_rocket_target_a" );

	// Baker takes cover
	issue_color_orders ("r81", "allies");

	done_with_intro = GetStruct( "vtol_done_with_intro", "script_noteworthy" );
	done_with_intro waittill ( "trigger" );

	wait 1;

	level.lab_vtol thread vtol_rocket_attack ( "vtol_rocket_target_c" );

	flag_set ("vtol_spawn_wave_2");
	// Baker takes cover
	level.lab_vtol vtol_move_to( "vtol_position_d" );
	// wait for enemies dead, dialog done
	wait 1;

	issue_color_orders ("r82", "allies");

	// level.lab_vtol thread vtol_rocket_attack ( "vtol_cover_c" );
	wait 2;
	// level.lab_vtol thread vtol_rocket_attack ( "vtol_cover_c_2" );
	wait 4;

	issue_color_orders ("r83", "allies");
	// level.lab_vtol thread vtol_rocket_attack ( "vtol_cover_d" );
	wait 2;

	flag_set ("vtol_spawn_wave_3");
	// level.lab_vtol thread vtol_rocket_attack ( "vtol_cover_d_2" );
	wait 6;
	// wait for enemies dead, dialog done
	level.lab_vtol vtol_move_to( "vtol_position_e" );
	wait 6;
	issue_color_orders ("r85", "allies");
	// level.lab_vtol thread vtol_rocket_attack ( "vtol_cover_e" );
	wait 2;
	// level.lab_vtol thread vtol_rocket_attack ( "vtol_cover_e_2" );
	level.lab_vtol vtol_move_to( "vtol_position_f" );
	wait 1;
	// level.lab_vtol thread vtol_rocket_attack ( "vtol_cover_f" );
	wait 0.2;
	// level.lab_vtol thread vtol_rocket_attack ( "vtol_cover_f_2" );

	flag_wait ("vtol_enemies_dead");

	thread laser_setup();
}

vtol_dialog()
{
	level notify ("spawn_vtol");
	add_dialogue_line( "Baker", "We're at the exfil location.", "green", 2 );
	add_dialogue_line( "Baker", "Specter, cover me while I make an exit.", "green", 3 );

	// Wait until player approaches
	// flag_wait ("vtol_target_area_c");
	add_dialogue_line( "Baker", "VTOL incoming!", "green", 2 );
	issue_color_orders ("r82", "allies");

	add_dialogue_line( "Baker", "It's targeting us! Get to hard cover!", "green", 2 );
	add_dialogue_line( "Baker (To Team A) ", "Team A, we can't handle this VTOL! Get us KillSat clearance now!", "green", 4 );
	add_dialogue_line( "Team A", "We're on the horn with C&C now, but this is a tall order. We'll need time.", "purple", 4 );
	add_dialogue_line( "Baker", "The sooner the better!", "green", 2 );

	// Baker advances to next cover piece
	issue_color_orders ("r83", "allies");
	thread add_dialogue_line( "Baker (To Player)", "Keep moving up. We've got to find new cover!", "green", 3 );

	// Time to move forward.
	flag_set ("force_vtol_move_e");
	add_dialogue_line( "Baker (To Team A)", "Any time is good, Team A!", "green", 2 );
	add_dialogue_line( "Team A", "Still clearing confirmation. Just hang on a bit longer.", "purple", 3 );

	// Baker advances to next cover piece
	issue_color_orders ("r85", "allies");
	add_dialogue_line( "Baker (To Player)", "This cover isn't gonna last, get behind that pillar!", "green", 4 );
	add_dialogue_line( "Baker ", "Keep the pillar between you and the VTOL!", "green", 3 );

	// Time to move forward.
	flag_set ("force_vtol_move_f");

	flag_wait ("vtol_enemies_dead");

	add_dialogue_line( "Team A", "We've got an uplink to C&C, patching you through now.", "purple", 3 );
	thread add_dialogue_line( "Mission Control", "Confirmed. KillSat SH6-0151 is clear of your horizon. Designate your target.", "blue", 4 );
	level notify ("laser_ready");

	add_dialogue_line( "Baker (To Player)", "Finally. Specter, lase the VTOL while I get its attention.", "green", 3 );
	add_dialogue_line( "Baker (To Player)", "Ready? 1.. 2.. 3...", "green", 3 );

	// Baker runs out to the left.
	issue_color_orders ("r83", "allies");
	thread add_dialogue_line( "Baker", "Now! Over here, you bucket of bolts!", "green", 2 );


	level notify ("baker_distracts_vtol");
	thread laser_setup();
	level.baker SetEntityTarget( level.lab_vtol );
	level.lab_vtol waittill ("death");
	thread add_dialogue_line( "Baker", "Way to go! Now we just need to figure out a new way out of here.", "green", 3 );
	level.lab_vtol waittill ("crash_done");
	add_dialogue_line( "Baker", "Fffffuuuuuuuuu.....!", "green", 3 );

}
*/
floor_collapse()
{
	// Wait until the VTOL actually impacts and explodes.
	// level.lab_vtol waittill ("crash_done");
	flag_wait ("flag_getup");
	thread office_enemies_logic();
	thread  fx_kill_vtol_fx();
	Exploder( "fx_office_inferno" );

	// Show cloud ring.
	thread fx_show_cloud_ring();

	// Get rid of the floor.
	floor = GetEnt ("collapsing_floor", "targetname");
	floor_ai = GetEnt ("collapsing_floor_ai", "targetname");
	floor delete();
	floor_ai delete();
	thread maps\nx_skyscraper_fx::set_vision_and_fog("exterior_up_high", 1); // set appropriate vision and fog
	ClearAllCorpses();
	
	level notify ("floor_collapsed");
}

office_enemies_logic()
{

	level.office_enemies = [];

	// Wave 1
	office_enemies_spawn_function ("office_wave_1_enemy_spawner_1");
	office_enemies_spawn_function ("office_wave_1_enemy_spawner_2");
	office_enemies_spawn_function ("office_wave_1_enemy_spawner_3");
	office_enemies_spawn_function ("office_wave_1_enemy_spawner_4");
	office_enemies_spawn_function ("office_wave_1_enemy_spawner_5");
	office_enemies_spawn_function ("office_wave_1_enemy_spawner_6");
	office_enemies_spawn_function ("office_wave_1_enemy_spawner_7");
	office_enemies_spawn_function ("office_wave_1_enemy_spawner_8");

	foreach (enemy in level.office_enemies)
	{
		enemy.ignoreall = true;
	}
	flag_wait( "flag_vtol_floor_collapse_done" );
	foreach (enemy in level.office_enemies)
	{
		enemy.ignoreall = false;
	}

	waittill_dead_or_dying ( level.office_enemies );
	level notify ("office_enemies_dead");
	// iprintln ("Everybody dead!");

}

office_enemies_spawn_function( targetname )
{
	enemy = spawn_targetname ( targetname);
	level.office_enemies[level.office_enemies.size] = enemy;
	enemy SetIsVisibleInXray();
	// These guys shouldn't pose much of an actual threat
	enemy getEnemyInfo( level.baker );
}
//*******************************************************************
//  Laser targeted Laser!                                           *
//                                                                  *
//*******************************************************************

laser_setup()
{
	// level waittill ("laser_ready");
	//flag_wait( "flag_uav_crash" );
	//wait 14;
	// When the player presses the fire button, send this notify
	level._player notifyOnPlayerCommand( "fired_laser", "+attack" );
	//thread check_for_laser_targeting_device();
	thread force_laser_targeting_device();
	thread laser_targeting_device_logic();
	thread satellite_orbit();
	// level.lab_vtol waittill ("death");
	flag_wait( "flag_vtol_floor_collapse_done" );
	level._player LaserForceOff();
	level._player notify ("laser_off");
}

/*
check_for_laser_targeting_device()
{

	while ( level._player GetCurrentWeapon() != "m9")
	{
		wait .1;
	}
	
	iprintln ("ltd");
	waittillframeend;

	level._player thread laser_targeting_device_logic();

	level._player waittill ("weapon_change");
	/*
	while ( level._player GetCurrentWeapon() == "m9")
	{
		wait .0.05;
	}
	*/
	/*
	iprintln ("not ltd");
	level._player allowFire( true );
	waittillframeend;
	
	check_for_laser_targeting_device();
}
*/

force_laser_targeting_device()
{
	// Give the player the "laser designator"	
	level._player GiveWeapon( "m9" );
	level.player_weapon = level._player GetCurrentWeapon();
	level._player EnableWeapons();
	// Force the player to use the designator
	level._player SwitchToWeapon( "m9" );
	level._player DisableWeaponSwitch();
	level._player DisableOffhandWeapons();
	//level.lab_vtol godoff();

	// level.lab_vtol waittill ("death");
	flag_wait( "flag_vtol_floor_collapse_done" );

	// Back to the regular weapons
	level._player EnableOffhandWeapons();
	level._player EnableWeaponSwitch();
	level._player SwitchToWeapon( "lancer_xray" );
	level._player allowFire( true );
}

laser_targeting_device_logic()
{
	level endon ("floor_collapsed");
	// level._player endon ("weapon_change");
	level._player allowFire( false );
	lock_on_meter_init();
	thread lock_on_meter();

	level._player.lock_on_complete = 2;
	level._player.cool_down_complete = 3;

	level._player.lock_on_percent = 0;
	while ( 1 )
	{
		level._player waittill( "fired_laser" );
		thread laser_code_pattern();
		// thread draw_orbital_laser();
		level._player laser_designate_target();
		//level._player LaserForceOn();
		// level notify ("laser_off");
		level._player LaserForceOff();
		thread cool_down_meter();
	}
}

laser_code_pattern()
{
	delay = 0.05;
	level endon ("laser_off");
	level endon ("floor_collapsed");
	while ( 1 )
	{
		level._player LaserForceOn();
		wait (delay + RandomFloat (0.2));
		level._player LaserForceOff();
		wait delay;
	}
}

laser_designate_target()
{
	// level._player endon ("weapon_change"); 

	// self waittill( "fired_laser" );

	trace = self get_laser_designated_trace();
	prior_entity = trace[ "entity" ];

	while( level._player AttackButtonPressed() )
	{
		trace = self get_laser_designated_trace();
		position = trace[ "position" ];
		entity = trace[ "entity" ];
		if ( isdefined( prior_entity ) && isdefined( entity ) && entity.classname == "script_vehicle" )
		{
			if ( prior_entity == entity )
			{
				prior_entity = entity;
				level._player.lock_on_percent += ( .05 / level._player.lock_on_complete );
				iprintln("lock-on: " + level._player.lock_on_percent);
				if ( level._player.lock_on_percent >= 1 )
				{
					iprintln ("locked!!!");
					level._player.lock_on_percent = 0;
					level notify( "laser_coordinates_received" );
					thread draw_orbital_laser( entity );
					break;
				}
				level notify( "lock_on_start" );
				wait .05;
			}
			else
			{
				iprintln("lock-on dropped");
				level._player.lock_on_percent -= ( .05 / level._player.cool_down_complete );
				if( level._player.lock_on_percent < 0 )
				{
					level._player.lock_on_percent = 0;
				}
				iprintln("dropped: " + level._player.lock_on_percent);
				level notify("lock_on_dropped");
				wait .05;
			}
		}
		else
		{
			
			level._player.lock_on_percent -= ( .05 / level._player.cool_down_complete );
			if( level._player.lock_on_percent < 0 )
			{
				level._player.lock_on_percent = 0;
			}
			iprintln ("no target: " + level._player.lock_on_percent);
			level notify("lock_on_dropped");
			wait .05;
			trace = self get_laser_designated_trace();
			prior_entity = trace[ "entity" ];
		}
	}
	
	// take away laser
	level notify( "laser_off" );
}

lock_on_meter_init()
{
	level.lock_on_fill_max_height = 115;

	level._player.lock_on_frame = NewHudElem(  );
	level._player.lock_on_frame.alignX = "center";
	level._player.lock_on_frame.alignY = "bottom";
	level._player.lock_on_frame.horzAlign = "center";
	level._player.lock_on_frame.vertAlign = "bottom";
	level._player.lock_on_frame.x = 2;
	level._player.lock_on_frame.y = -120;
	level._player.lock_on_frame setShader( "hud_temperature_gauge", 35, 150 );
	level._player.lock_on_frame.alpha = 1;
	level._player.lock_on_frame.sort = 4;

	level._player.lock_on_fill = NewHudElem(  );
	level._player.lock_on_fill.alignX = "center";
	level._player.lock_on_fill.alignY = "bottom";
	level._player.lock_on_fill.horzAlign = "center";
	level._player.lock_on_fill.vertAlign = "bottom";
	level._player.lock_on_fill.x = 2;
	level._player.lock_on_fill.y = -152;
	level._player.lock_on_fill setShader( "white", 10, 1 );
	level._player.lock_on_fill.color = ( 1, .9, 0 );
	level._player.lock_on_fill.alpha = 1;
	level._player.lock_on_fill.sort = 1;

	thread lock_on_meter_wait_for_destroy();
}

lock_on_meter_wait_for_destroy()
{
	level waittill("laser_coordinates_received");

	level._player.lock_on_frame destroy();
	level._player.lock_on_fill destroy();
}

cool_down_meter()
{
	level endon ("laser_coordinates_received");
	level endon( "fired_laser" );

	while( 1 )
	{
		level._player.lock_on_percent -= ( .05 / level._player.cool_down_complete );
		if( level._player.lock_on_percent < 0 )
		{
			level._player.lock_on_percent = 0;
			break;
		}
		iprintln ("cool down: " + level._player.lock_on_percent);
		wait .05;
	}
}

lock_on_meter()
{
	level endon ("laser_coordinates_received");

	while( 1 )
	{
		level waittill ( "lock_on_start" );

		if( level._player.lock_on_percent <= 1 )
		{
			level._player.lock_on_fill setShader( "white", 10, int(level.lock_on_fill_max_height * level._player.lock_on_percent) );
			if( level._player.lock_on_percent < 1 )
			{
				level._player.lock_on_fill scaleOverTime( level._player.lock_on_complete * (1 - level._player.lock_on_percent), 10, level.lock_on_fill_max_height ); 
			}
		}

		level waittill_any ("lock_on_dropped", "laser_coordinates_received", "laser_off");

		if( level._player.lock_on_percent >= 0 )
		{
			level._player.lock_on_fill setShader( "white", 10, int(level.lock_on_fill_max_height * level._player.lock_on_percent) );
			if( level._player.lock_on_percent > 0 )
			{
				level._player.lock_on_fill scaleOverTime( level._player.cool_down_complete * level._player.lock_on_percent, 10, 1 );
			}
		}
	}
}

get_laser_designated_trace()
{
	eye = self geteye();
	angles = self getplayerangles();
	
	forward = anglestoforward( angles );
	end = eye + vector_multiply( forward, 3000 );
	trace = bullettrace( eye, end, true, self );

	if ( trace ["fraction"] >= 1 )
	{
		trace[ "position" ] = undefined;
	}
	
	entity = trace[ "entity" ];
	if ( isdefined( entity ) )
	{

		if ( isdefined( entity.targetname ) && entity.targetname == "fake_uav")
		{
			entity = GetEnt ("real_uav", "targetname");
		}
		trace[ "position" ] = entity.origin;
	}

	return trace;
}

draw_orbital_laser( target )
{
	// level waittill ( "laser_coordinates_received" );

	wait 1;

	// satellite = GetEnt ("fake_satellite", "targetname");
	// time = 3;

	//trace = level._player get_laser_designated_trace();

	//if ( isdefined( trace[ "position" ]) )

	//{
		//target = trace[ "position" ];
		// normal = trace[ "normal" ];

		//xoffset = Randomfloat ( 1 );
		//yoffset = Randomfloat ( 1 );

		// direction = (satellite.origin - target.origin);
		// normalized_direction = VectorNormalize( direction );

		// thread draw_line_for_time( satellite.origin, (target + (xoffset,yoffset,0 )) , 1, 0, 0, 0.05 );
		// time -= 0.05;
//		PlayFX ( level._effect[ "nx_laser_orbital_strike" ], (target.origin + (xoffset,yoffset, 0)), normalized_direction );
		// PlayFX( level._effect[ "laser_impact" ], (target + (xoffset,yoffset, 0)), normal );
		laserPos = target GetTagOrigin( "tag_deathfx" );
		PlayFXOnTag( level._effect[ "nx_laser_orbital_strike" ], target, "tag_deathfx" );
		PlayFXOnTag( level._effect[ "nx_laser_orbital_runner" ], target, "tag_deathfx" );

		wait 1.4;

		PlayFX( level._effect[ "nx_laser_orbital_strike_short" ], laserPos );

		wait 0.1;

		StopFXOnTag( level._effect[ "nx_laser_orbital_strike" ], target, "tag_deathfx", true );
		RadiusDamage( target.origin, 100, 1000, 1000, level._player );
	//}

}

satellite_orbit()
{
	level endon ("floor_collapsed");
	satellite = GetEnt ("fake_satellite", "targetname");
	starting_point = satellite.origin;

	while ( 1 )
	{
		satellite MoveTo ( satellite.origin + (6000, 24064,0), 24);
		satellite waittill ("movedone");
		satellite.origin = starting_point;
	}	
}

baker_office_movement()
{
	flag_wait( "flag_vtol_floor_collapse_done" );
	level.baker enable_ai_color( );
	issue_color_orders( "r87", "allies" );
	trigger_wait_targetname( "trig_baker_enters_office" );

	thread vtol_enemies_to_hallway();
	issue_color_orders( "r88", "allies" );
	self.ignoreme = false;	
	self waittill( "goal" );

	self.ignoreall = true;

	baker_aim = GetEnt( "origin_baker_shoot_glass", "targetname" );
	Assert( IsDefined( baker_aim ));

	glass = GetGlass( "glass_exfiltration_office" );
	blocker = GetEnt( "brush_exfiltration_office", "targetname" );
	Assert( IsDefined( glass ));
	Assert( IsDefined( blocker ));
	
	wait 0.5;

	if( !IsGlassDestroyed( glass ))
	{
		self SetEntityTarget( baker_aim );
		self shoot();
		self shoot();
		self ClearEntityTarget();
		wait 0.05;
		DestroyGlass( glass );
	}

	wait 0.5;
	//DeleteGlass( glass );
	blocker ConnectPaths();
	blocker delete();

	issue_color_orders( "r89", "allies" );
	wait 4;
	self.ignoreall = false;
	
	level waittill( "office_enemies_dead" );	
	
	issue_color_orders( "r90", "allies" );	
}

vtol_enemies_to_hallway()
{
	level endon( "office_enemies_dead" );
	
 	hallway = GetEnt( "vol_exfil_hallway_attack", "targetname" );
	Assert( IsDefined( hallway ));

	trigger_wait_targetname( "trig_exfil_player_in_hallway" );

	foreach( guy in level.office_enemies )
	{
		if( IsAlive( guy ))
		{
			guy SetGoalVolumeAuto( hallway );
			wait 0.05;
		}
	}
}

fx_kill_vtol_fx()
{
	Stop_Exploder( "fx_vtol_ambient" );
	Stop_Exploder( "fx_vtol_dust" );
	Stop_Exploder( "fx_vtol_exp_dust_01" );
	Stop_Exploder( "fx_vtol_exp_dust_02" );
}
