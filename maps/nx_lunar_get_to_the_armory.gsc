//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_LUNAR, Get to the Armory Mission Script					**
//                                                                          **
//    Created: 11/25/2010 - Travis Chen										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_hud_util;
#include maps\_utility_code;
#include maps\_nx_objective_util;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
DEBUG_DISPLAY_INTENSITY = false;

//*******************************************************************
//																	*
//																	*
//*******************************************************************
mission_precache()
{
	//PreCacheShellShock( "nx_lunar_get_to_armory" );
}

mission_flag_inits()
{
	flag_init( "vehicle_airlock_open" );
	flag_init( "start_stumble_walk" );
	flag_init( "stumble_walk_allies_dead" );
	flag_init( "hallway_taser_hit" );
	flag_init( "falcon_taser_vignette");
	flag_init( "falcon_taser_handoff");
	flag_init( "vehicle_airlock_breached" );
	flag_init( "ready_for_armory_breach");
	flag_init( "vignette_armory_breach");
	flag_init( "vo_base_compromise_bc");
	flag_init ("airlock_animation_done");
	flag_init ("disable_random_distant_breach");
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

get_to_the_armory_door_status_init()
{
	level thread maps\nx_lunar_util::lunar_door_status( "vehicle_airlock_door_01", "status_green" );
	level thread maps\nx_lunar_util::lunar_door_status( "vehicle_airlock_door_02", "status_red" );
	level thread maps\nx_lunar_util::lunar_door_status( "vehicle_hatch_breach", "status_green" );
	level thread maps\nx_lunar_util::lunar_door_status( "vehicle_door_01", "status_green" );
	level thread maps\nx_lunar_util::lunar_door_status( "vehicle_door_02", "status_green" );
	level thread maps\nx_lunar_util::lunar_door_status( "vehicle_door_03", "status_green" );
	level thread maps\nx_lunar_util::lunar_door_status( "vehicle_door_04", "status_green" );
	level thread maps\nx_lunar_util::lunar_door_status( "vehicle_airlock_breach_01", "status_green" );
	level thread maps\nx_lunar_util::lunar_door_status( "hub_01_door_01", "status_red" );
}

open_all_vehicle_bay_doors()
{
	level thread maps\nx_lunar_util::open_lunar_door( "vehicle_airlock_breach_01", 0.2 );
	level thread maps\nx_lunar_util::open_lunar_door( "vehicle_airlock_door_02", 0.2 );
	level thread maps\nx_lunar_util::open_lunar_door( "vehicle_door_01", 0.2 );
	level thread maps\nx_lunar_util::open_lunar_door( "vehicle_door_02", 0.2 );
	level thread maps\nx_lunar_util::open_lunar_door( "vehicle_door_03", 0.2 );
	level thread maps\nx_lunar_util::open_lunar_door( "vehicle_door_04", 0.2 );

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

get_to_the_armory_start()
{
	thread maps\_introscreen::nx_lunar_intro();

	level thread maps\nx_lunar_util::open_lunar_door( "vehicle_door_03", 0.2 );

	level._player takeallweapons();
	level._player GiveWeapon( "freerunner_lunar" );
	level._player SwitchToWeapon( "freerunner_lunar" );
	setSavedDvar( "player_sprintUnlimited", "1" );
	setSavedDvar( "player_sprintSpeedScale", 1 );

	// Start the player and allies
	maps\nx_lunar_util::lunar_start( "get_to_the_armory_player_start" );

	// Player is invulnerable
	level._player EnableInvulnerability();

	// Give the player the broken helmet overlay
	level thread maps\nx_lunar_intro::rover_broken_visor_overlay();
	level notify( "break_visor" );

	// Start dialog chain
	level thread get_to_the_armory_dialog();

	// Play lunar screen binks
	thread maps\nx_lunar_util::lunar_screen_binks();
}

get_to_the_armory()
{
	// Room status logic, kills player if in depressurized room
	level thread room_status_init();

	//set the sfx helmet state to semi-depressurized
	flag_set( "sfx_ext_surface_engsuit_semipress" );  //(walking from rover to airlock in a semi-busted engineering suit)

	// Airlock sequence, moves into breach through base logic 
	level thread airlock_and_breach();

	// Wakeup the player
	wakeup_after_rover_crash();
	
	// Open the armory door
	level thread maps\nx_lunar_util::open_lunar_door( "armory_door", 1.0 );

	// Create props for armory
	level thread maps\nx_lunar_anim::armory_breach_create_props();

	// Breach explosion clip
	level thread maps\nx_lunar_escape_interior::breach_explosion_clip_before();

	// Spawn allies
	if( ( !isDefined( level.eagle ) ) && ( !isDefined ( level.falcon ) ) )
	{
		level thread maps\nx_lunar_util::lunar_ally_spawn();
	}

	// We can't have Falcon already be at the armory when Falcon leads you there. Sorry, real Falcon.
	level.falcon stop_magic_bullet_shield();
	level.falcon delete();

	// Prevent Eagle from trying to path to Take Back Control nodes. His color is re-enabled after entering the armory.
	level.eagle disable_ai_color();

	// Armory enter vignette
	armory_enter_vignette();
	
	// Play lunar screen binks
	thread maps\nx_lunar_util::lunar_screen_binks();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
DEBUG_GET_TO_THE_ARMORY = false;
wakeup_after_rover_crash()
{
	
	thread breach_group_01_spawn();
	thread vehicle_bay_upstairs_civilians();
	level thread maps\nx_lunar_util::lunar_door_keypad_cycle ( "vehicle_airlock_breach_01" );

	level._player FreezeControls( true );

	// KenM - This is a workaround for the time being. FreezeControls should also disable crouching, but is not presently.
	level._player AllowCrouch( false ); 

	// Thread stumble walk
	level thread player_wakeup();	

	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_lunar_get_to_armory_vol", 0.1 );
	//level._player ShellShock( "nx_lunar_get_to_armory", 10000 );
	thread fade_in_from_crash();
 
	thread sound_intro_sfx();

	SetBlur( 20, 0 );
	SetBlur( 0, 8 );

	//scene = "wakeup";
	scene = "vehiclebay_wakeup";
	//anim_node = GetEnt( "player_wakeup", "targetname" );
	anim_node = GetEnt("vignette_player_wakeup_vh_bay", "targetname");
	player_rig = spawn_anim_model( "player_rig" );

	ally_01 = maps\_nx_vignette_util::vignette_actor_spawn("vignette_wakeup_vh_bay_ally01", "ally_01"); //"value" (kvp), "anim_name"
	ally_02 = maps\_nx_vignette_util::vignette_actor_spawn("vignette_wakeup_vh_bay_ally02", "ally_02"); //"value" (kvp), "anim_name"

	guys = [];
	guys["ally_01"] = ally_01;
	guys["ally_02"] = ally_02;
	//guys["player_rig"] = player_rig;

	thread start_opening_battle();

	thread fx_helmet_sequencing();
	// thread fx_dust_hands(player_rig);

	thread fx_hhh_intro_vision_fade_to_lunar_view();

	ally_02 thread rover_shoots_wakeup_ally();

	waittillframeend;
	// KenM Moving this here so it overwrites the full health granted by a restart
	level._player SetSuitShieldHealth( 5 );
	SetSavedDvar( "lunar_hud_suit_shield_fake_health", 1 ); //fake the UI so that if the player actually dies it will still show low health.
	SetSavedDvar( "lunar_hud_suit_shield_fake_health_level", 0.5 );
	level._player maps\_moon::set_suit_hud_type( "civilian" );
	level._player PutOnHelmet( true );

	// When DEBUG_GET_TO_THE_ARMORY is true, skip the intro wakeup animation
	if( !DEBUG_GET_TO_THE_ARMORY )
	{
		anim_node anim_first_frame( guys, scene );
		anim_node anim_first_frame_solo( player_rig, scene );

		level._player PlayerLinkToDelta( player_rig, "tag_player", 1, 0, 0, 0, 0, true );
		
		// have to place this so we can see the vignette temp. - Rob
		wait 6;		
		
		thread fx_wakeup_after_rover_crash(player_rig, ally_01, ally_02);

		anim_node thread anim_single( guys, scene );  
		anim_node anim_single_solo( player_rig, scene );

		player_rig Delete();
		flag_set( "start_stumble_walk" );
		level._player FreezeControls( false );

		wait 3.0;
		// iPrintLnBold( "FX - Start Killing dudes" );
		ally_01 maps\_nx_vignette_util::vignette_actor_kill();
		//wait 5.0;
		//StopFXOnTag( level._effect[ "nx_lunar_intro_blood_squirt" ], ally_02, "tag_eye" );
		ally_02 maps\_nx_vignette_util::vignette_actor_kill();

	}

	
	battlechatter_off( "allies" );
}

rover_shoots_wakeup_ally()
{
	level waittill ("wakeup_ally_shot"); 
	magicBullet( "lunarrifle", level.breach_rover.mgturret[0] getTagOrigin( "tag_flash" ), self getTagOrigin( "tag_eye" ) );
}

// NoteTrack calls
fx_lunar_vehiclebay_wakeup_ally_01_hit_ground(ally_01)
{
	wait 2.5;
// 	iPrintLnBold( "FX - Ally 01 Hit Ground" );
	tagPos = ally_01 getTagOrigin( "J_Shoulder_LE" );
	playFX( level._effect[ "nx_regolith_bodyfall" ], tagPos, ( 0, 0, 1 ) );
	//tagPos = ally_01 getTagOrigin( "J_Mouth_LE" );
	//playFX( level._effect[ "nx_regolith_bodyfall" ], tagPos, ( 0, 0, 1 ) );
}

fx_lunar_vehiclebay_wakeup_ally_02_shot(ally_02)
{
	//iPrintLnBold( "FX - Ally 02 SHOT" );

	playfxontag( level._effect[ "nx_lunar_intro_blood_squirt" ], ally_02, "tag_eye" );
	playfxontag( level._effect[ "nx_lunar_falcon_death_blood_hit" ], ally_02, "tag_eye" );
	playfxontag( level._effect[ "nx_lunar_intro_glass_hit" ], ally_02, "tag_eye" );

	new_head = "nx_us_space_assault_head_crack";
	ally_02 Detach( ally_02.headmodel );  // remove the head model
	ally_02.headmodel = new_head;  // record the name of the new head
	ally_02 Attach( new_head );  // attach a new head on the guy

	wait 0.35;

	thread fx_lunar_vehiclebay_wakeup_ally_02_hit_ground(ally_02);

	// foot sliding across the ground
	for (i=0; i<5; i++)
	{
		tagPos = ally_02 getTagOrigin( "J_Ball_RI" );
		playFX( level._effect[ "nx_regolith_footfall" ], tagPos, (0, 0, 1) );
		wait 0.2;
	}
}

/*
crew_module_airlock_death_vignette_fx()
{
	// Footsteps.
	wait 5.5;
	tagPos = self getTagOrigin( "J_Ball_RI" );
	playFX( level._effect[ "footdust_small" ], tagPos + ( 4, 10, 0 ), ( 0, 0, 1 ) );

	wait 0.9;
	tagPos = self getTagOrigin( "J_Ball_LE" );
	playFX( level._effect[ "footdust_small" ], tagPos + ( 4, 10, 0 ), ( 0, 0, 1 ) );

	wait 0.9;
	tagPos = self getTagOrigin( "J_Ball_RI" );
	playFX( level._effect[ "footdust_small" ], tagPos + ( 4, 10, 0 ), ( 0, 0, 1 ) );

	// Hit.
	wait 0.9;
	tagPos = self getTagOrigin( "tag_eye" );
	playFX( level._effect[ "nx_lunar_falcon_death_blood_hit" ], tagPos, ( -1, 0, 0) );
	playFXOnTag( level._effect[ "nx_lunar_crew_airlock_blood_squirt"], self, "tag_eye" );

	// Collapse dust.
	wait 2.1;
	tagPos = self getTagOrigin( "J_SpineUpper" );
	playFX( level._effect[ "nx_lunar_crew_airlock_impact_large" ], tagPos + ( 0, 14, -10) );

	stopFXOnTag( level._effect[ "nx_lunar_crew_airlock_blood_squirt"], self, "tag_eye" );
}
*/

fx_lunar_vehiclebay_wakeup_ally_02_hit_ground( ally_02 )
{
	// wait 1.633;
	wait 1.0;
// 	iPrintLnBold( "FX - Ally 02 Hit Ground" );
	tagPos = ally_02 getTagOrigin( "TAG_STOWED_HIP_REAR" );
	playFX( level._effect[ "nx_regolith_bodyfall" ], tagPos, ( 0, 0, 1 ) );
	
	wait 0.5;

	tagPos = ally_02 getTagOrigin( "TAG_SHIELD_BACK" );
	playFX( level._effect[ "nx_regolith_bodyfall" ], tagPos, ( 0, 0, 1 ) );

}

fx_wakeup_after_rover_crash(player_rig, ally_01, ally_02)
{
//	iPrintLnBold( "FX - Start_Sequence ..." );

	thread fx_lunar_vehiclebay_wakeup_ally_01_hit_ground(ally_01);
	
	wait 9.46;

	handfall_offset = (0,0,1);
	footfall_offset = (0,0,1);

	// Hands ----------------------------------
	tagPos = player_rig getTagOrigin( "J_Mid_LE_1" );
	playFX( level._effect[ "nx_regolith_footfall" ], (tagPos + handfall_offset), ( 0, 0, 1 ) );
	wait 1.1;
	tagPos = player_rig getTagOrigin( "J_Mid_RI_1" );
	playFX( level._effect[ "nx_regolith_footfall" ], (tagPos + handfall_offset), ( 0, 0, 1 ) );

	wait 0.5;
	tagPos = player_rig getTagOrigin( "J_Mid_LE_1" );
	playFX( level._effect[ "nx_regolith_footfall" ], (tagPos + footfall_offset), ( 0, 0, 1 ) );
	// playfxontag( level._effect[ "nx_lunar_regolith_haze" ], player_rig, "tag_player");

	// Feet ----------------------------------
	wait 2.56;
	tagPos = ally_02 getTagOrigin( "J_Ball_RI" );
	playFX( level._effect[ "nx_regolith_footfall" ], (tagPos + footfall_offset), ( 0, 0, 1 ) );

	wait 0.66;
	tagPos = ally_02 getTagOrigin( "J_Ball_LE" );
	playFX( level._effect[ "nx_regolith_footfall" ], (tagPos + footfall_offset), ( 0, 0, 1 ) );

	wait 0.60;
	tagPos = ally_02 getTagOrigin( "J_Ball_RI" );
	playFX( level._effect[ "nx_regolith_footfall" ], (tagPos + footfall_offset), ( 0, 0, 1 ) );
}

opening_battle_enemy_spawn()
{
	ob_enemy = self spawn_ai( true );
	ob_enemy thread magic_bullet_shield();
	ob_enemy.goalradius = 16;
	ob_enemy.baseAccuracy = .5;
	ob_enemy enable_cqbwalk(); 
	//move to the destination node described in the script_noteworthy
	//wait a little bit since the screen is black - randomizing also helps break up the unity
	wait( randomfloatrange( 3.0, 5.0 ) ); 
	println( self.script_noteworthy );
	ob_enemy_dest = getnode( self.script_noteworthy, "targetname" );
	ob_enemy SetGoalNode( ob_enemy_dest );
	flag_wait( "stumble_walk_allies_dead" );
	//switch from completely ignoring the player to just one or two guys up front ignoring the player
	level._player.ignoreme = false;

	if( ob_enemy.script_noteworthy == "intro_battle_enemy3_destination" ) 
		{
			ob_enemy.baseAccuracy = 0;
		}
		else if( ob_enemy.script_noteworthy == "intro_battle_enemy4_destination" )
		{
			ob_enemy.baseAccuracy = 0;
		}
		else
		{
			ob_enemy.ignoreall = true;
		}
	

	//flag_wait( "player_in_vehicle_airlock" );
	flag_wait( "vignette_vh_bay_breach" );
	//flag_wait( "stumble_walk_allies_dead" );
	//wait ( 8 );
	//move some ai guys towards the door
	if ( isdefined ( ob_enemy_dest.script_noteworthy ) )
	{
		//println( "moving" );
		//println ( ob_enemy.script_noteworthy );
		//println ( ob_enemy_dest.script_noteworthy );
		//stop firing at the player
		ob_enemy.ignoreall = true;
		ob_enemy disable_cqbwalk();
		ob_enemy_dest2 = getnode( ob_enemy_dest.script_noteworthy, "targetname" );
		ob_enemy SetGoalNode( ob_enemy_dest2 );
	}

	flag_wait( "vehicle_airlock_breached" );
	ob_enemy forceUseWeapon( "lunarrifle_silent", "primary" );
	ob_enemy stop_magic_bullet_shield();
	ob_enemy kill(); 
}

start_opening_battle()
{
	//an ai battle to enhance the mood
	level._player.ignoreme = true;
	ob_ally01_actor = getent( "opening_battle_ally_01", "script_noteworthy" );
	ob_ally02_actor = getent( "opening_battle_ally_02", "script_noteworthy" );
	ob_ally03_actor = getent( "opening_battle_ally_03", "script_noteworthy" );
	//Spawn the enemies and run through their actions
	array_thread( getentarray( "intro_battle_enemy", "targetname" ), ::opening_battle_enemy_spawn );

	ob_ally01 = ob_ally01_actor spawn_ai( true );
	ob_ally01 thread magic_bullet_shield();
	ob_ally01.baseAccuracy = 0;
	ob_ally02 = ob_ally02_actor spawn_ai( true );
	ob_ally02 thread magic_bullet_shield();
	ob_ally02.baseAccuracy = 0;
	ob_ally03 = ob_ally03_actor spawn_ai( true );
	ob_ally03 thread magic_bullet_shield();
	ob_ally03.baseAccuracy = 0;
	
	//make the ally's move towards the door
	wait( 27 );
	ob_ally01_dest = getnode( "intro_battle_ally1_destination", "targetname" );
	ob_ally01 SetGoalNode( ob_ally01_dest );
	wait( 1 );
	ob_ally02_dest = getnode( "intro_battle_ally2_destination", "targetname" );
	ob_ally02 SetGoalNode( ob_ally02_dest );
	wait( .5 );
	ob_ally03_dest = getnode( "intro_battle_ally3_destination", "targetname" );
	ob_ally03 SetGoalNode( ob_ally03_dest );

	//allow allies to be killed
	wait( 2.5 );
	ob_ally01 stop_magic_bullet_shield();
	ob_ally02 stop_magic_bullet_shield();
	ob_ally03 stop_magic_bullet_shield();
	//Force allies to be killed by enemy bullets
	bad_guys = GetAIArray( "axis" );
	//magicBullet( "lunarrifle", bad_guys[1] getTagOrigin( "tag_flash" ), ob_ally01 getTagOrigin( "tag_eye" )  );
	ob_special_1 = get_ai_group_ai( "ob_special_1" )[0];
	magicBullet( "lunarrifle", ob_special_1 getTagOrigin( "tag_flash" ), ob_ally01 getTagOrigin( "J_head" )  );
	ob_ally01 kill();
	wait ( 2.1 );
	ob_special_2 = get_ai_group_ai( "ob_special_2" )[0];
	magicBullet( "lunarrifle", ob_special_2.origin + (0,0,48), ob_ally03 getTagOrigin( "TAG_STOWED_BACK" )  );
	ob_ally03 kill();
	wait ( 1.55 );
	magicBullet( "lunarrifle", ob_special_1 getTagOrigin( "tag_flash" ), ob_ally02 getTagOrigin( "J_spine4" )  );
	ob_ally02 kill();

	flag_set( "stumble_walk_allies_dead" );
}

fx_hhh_intro_vision_fade_to_lunar_view()
{
	//iPrintLnBold("--- fx_hhh_intro_vision_fade_to_lunar_view ---");
	wait 5.0;
	//iPrintLnBold("--- starting vision set change ---");
	set_vision_set("nx_lunar_surface_intro", 6.0);
}

sound_intro_sfx()
{

	wait 2.9;
	mynodeEntity = spawn( "sound_emitter", ( 4391, -283, -1566 ) );
	mynodeEntity PlaySound( "scn_get_to_armory_1_lr" );
	mynodeEntity3 = spawn( "sound_emitter", ( 4390, -283, -1566 ) );
	mynodeEntity3 PlaySound( "scn_get_to_armory_1_lsrs" );
	wait 3.1;
	//mynodeEntity4 = spawn( "sound_emitter", ( 4380, -283, -1566 ) );
	//mynodeEntity4 PlaySound( "scn_intro_hand_mvmt", "scn_intro_hand_mvmt", true );
	//mynodeEntity4 waittill( "scn_intro_hand_mvmt" );
	//mynodeEntity4 delete();
	//org waittill( "scn_get_to_armory_1_lr" );
	//org delete();
	mynode8 = spawn( "sound_emitter", ( 5728, -192, -1488 ) );
	mynode8 PlayloopSound( "emt_red_alert_vo" );
	mynode9 = spawn( "sound_emitter", ( 6832, -112, -1488 ) );
	mynode9 PlayloopSound( "emt_red_alert_vo" );

	flag_wait ( "player_in_vehicle_airlock" ); 
	wait 4.5;
	//mynodeEntity2 = spawn( "sound_emitter", ( 4391, -283, -1566 ) );
	//mynodeEntity2 PlaySound( "scn_get_to_armory_2", "scn_get_to_armory_2", true );
	wait 3;
	SetSavedDvar( "cg_minBreathingLevel", "4" );
	mynode10 = spawn( "sound_emitter", ( 4548, 196, -1480 ) );
	mynode10 PlaySound( "emt_red_alert_intro" );
	mynodeEntity stopsounds();
	wait 0.1;
	mynodeEntity delete();
	mynodeEntity3 stopsounds();
	wait 0.1;
	mynodeEntity3 delete();
	//mynodeEntity2 waittill( "scn_get_to_armory_2" );
	//mynodeEntity2 delete();

	flag_wait( "vignette_armory_enter" );
	mynode8 stopsounds();
	mynode9 stopsounds();
	wait 0.1;
	mynode8 delete();
	mynode9 delete();
	mynode10 delete();

	flag_wait( "player_has_helmet" );
	SetSavedDvar( "cg_minBreathingLevel", "0" );

}

fade_in_from_crash()
{
	black_overlay = get_black_overlay();
	black_overlay.alpha = 1;
	fade_in_time = 15;
	wait( 3 );
	black_overlay FadeOverTime( fade_in_time );
	black_overlay.alpha = 0;
}

get_black_overlay()
{
	if ( !isdefined( level._black_overlay ) )
		level._black_overlay = create_client_overlay( "black", 0, level._player );
	level._black_overlay.sort = -1;
	return level._black_overlay;
}

fx_dust_hands(player_rig)
{
// J_Mid_RI_1
// J_Mid_LE_1

	playfxontag( level._effect[ "nx_lunar_regolith_haze" ], player_rig, "tag_player", true );

	for (i=0; i<20; i++)
	{
		playfxontag( level._effect[ "nx_regolith_hands" ], player_rig, "J_Mid_RI_1", true );
		playfxontag( level._effect[ "nx_regolith_hands" ], player_rig, "J_Mid_LE_1", true );
		wait 0.5;
	}
}

fx_helmet_sequencing()
{
	self endon( "stop_player_visor_glass_cracking" );

	// need the hook to the viewmodel hands rig
	wait 6.0; // wait until we can see
	while (1)
	{
		if (randomfloat(1.0) > 0.5)
		{
			playfxontag( level._effect[ "nx_lunar_helmet_leak_vapor_left" ], level._player, "tag_vfx_left", true );
		} else {
			playfxontag( level._effect[ "nx_lunar_helmet_leak_vapor_right" ], level._player, "tag_vfx_right", true );
		}
		wait ( 0.5 + randomfloat( 1.5 ) );
	}
}

player_wakeup()
{
	thread maps\nx_lunar_anim::dead_crew_wakeup();

	level._player_heartrate = 1.4;
	level thread player_heartbeat();

	set_vision_set ("nx_lunar_get_to_the_armory", 0.0);

	flag_wait( "start_stumble_walk" );
	level thread player_wakeup_movement_speed( 0.6 );
	waittillframeend;
	flag_clear ("start_stumble_walk");
	
	//level._player FadeOutShellShock();
	thread stumble_walk( 0, 20.0, true, true, 0.0, true, 6.0 );

	//DR: hack: currently this is not in a good place.  I need a script call where
	//the player has stood up and is now moving forward.  Right now I have a big long wait
	//since this flag is being set too early.
	flag_set( "music_player_wakes_up" );
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

stop_stumble_walk( stop_wait )
{
	
	level notify( "stop_stumble_walk" );

	level._player blend_movespeedscale( 1.0, stop_wait );

	// Wait a bit to stop
	wait( stop_wait );

	level._player AllowCrouch( true );
	level._player AllowProne( true );
	level._player AllowJump( true );
	level._player AllowSprint( true );

	// Turn the stance HUD indicator back on
	SetSavedDvar( "ammoCounterHide", "0" );


	SetBlur( 0, stop_wait );
}

player_stumble_walk_intensity_update( starting_walk_intensity, ramp_time )
{
	level endon( "stop_stumble_walk" );

	Assert( ramp_time > 0 );
 	Assert( starting_walk_intensity <= 1.0 && starting_walk_intensity >= 0 );

	// Starting intensity. 
	self.walk_intensity = starting_walk_intensity;

	// Update intensity. 
	start_time = GetTime() - (( ramp_time * starting_walk_intensity ) * 1000.0 );
	last_display_time = start_time;
	while ( 1 )
	{
		// Update. 
		current_time = GetTime() - start_time;
		self.walk_intensity = ( current_time / 1000.0 ) / ramp_time;
		if ( self.walk_intensity > 1.0 )
		{
			self.walk_intensity = 1.0;
		}

		// Debug draw intensity. 
		if ( DEBUG_DISPLAY_INTENSITY )
		{
			if ( GetTime() - last_display_time > 1.0 )
			{
				last_display_time = GetTime();
				iprintlndebug( self.walk_intensity );
			}
		}

		wait( 0.001 );
	}
}

player_visor_glass_cracking()
{
	level endon( "stop_player_visor_glass_cracking" );
	SetSavedDvar( "lunar_hud_suit_shield_fake_health_level", 0.5 );
	
	wait 5.5;
	level.broken_visor setshader( "nx_lunar_helm_crack_002", 640, 480 );
	level._player player_fake_health_level_lerp( 0.3, 0.05 );
	wait 4.3;
	level.broken_visor setshader( "nx_lunar_helm_crack_003", 640, 480 );
	level._player player_fake_health_level_lerp( 0.2, 0.05 );
	wait 3;
	level notify( "stop_helmet_light_anim" );
	thread maps\nx_lunar_intro::animate_helmet_lights_critical();
	level.broken_visor setshader( "nx_lunar_helm_crack_004", 640, 480 );
	level._player player_fake_health_level_lerp( 0.075, 0.05 );
	wait 1.9;
	level.broken_visor setshader( "nx_lunar_helm_crack_005", 640, 480 );
	level._player player_fake_health_level_lerp( 0.03, 0.05 );
}



player_fake_health_level_lerp( end, time )
{
	self thread player_fake_health_level_lerp_worker( end, time );
}

//kindof stolen from suit_shield_smooth_give_health
player_fake_health_level_lerp_worker( end, time )
{
	self endon("death");
	self endon("remove_nx_suitshield");
	
	num_steps = time / 0.05;
	health = GetDvarFloat( "lunar_hud_suit_shield_fake_health_level" );
	health_increments = (end - health ) / Float(num_steps);
	
	for( i = 0; i < num_steps; i++ )
	{
		health += health_increments;
		
		if ( health > Int(GetDvar("player_suitshield_max_health")) || health <= 0 )
		{
			break;
		}
		
		SetSavedDvar( "lunar_hud_suit_shield_fake_health_level", health  );
		self FlashSuitShieldHealthMeter();	
		
		wait 0.05;
	}
}

player_stumble_walk_intensity( starting_walk_intensity, ramp_time )
{
	self player_stumble_walk_intensity_update( starting_walk_intensity, ramp_time );

	// Exit logic. 
	self.walk_intensity = 0;
}

player_random_blackout_next_time()
{
	max_time_between_blackouts = 10.0;
	random_chance_time = self.walk_intensity * 0.5 + randomfloat( 0.5 );
	return max_time_between_blackouts * ( 1.0 - random_chance_time );
}

player_random_blackout_update( black_overlay, delay )
{
	level endon ( "stop_stumble_walk" );

	self.stop_blackout = false;

	next_time = delay;

	while ( 1 )
	{
		wait( next_time );

		fade_in_time = 1.5;
		black_overlay FadeOverTime( fade_in_time );
		black_overlay.alpha = 0.3 + ( 0.7 * self.walk_intensity );
		wait( fade_in_time + 0.2 );
		fade_out_time = 1.0;
		black_overlay FadeOverTime( fade_out_time );
		black_overlay.alpha = 0;
		wait( fade_out_time );

		next_time = player_random_blackout_next_time();

		if ( self.stop_blackout )
		{
			break;
		}
	}
}

player_random_blackout( delay )
{
	black_overlay = get_black_overlay();
	self player_random_blackout_update( black_overlay, delay );

	// Make sure blackout turned off. 
	black_overlay FadeOverTime( 1.0 );
	black_overlay.alpha = 0;
}

player_random_blur( ramp )
{
	level endon ( "stop_stumble_walk" );

	if( !IsDefined( ramp ) )
	{
		ramp = 0;
	}

	curr_ramp = 0.0;
	while ( true )
	{
		wait 0.05;
		if ( randomint( 100 ) > 10 )
			continue;

		blur = randomint( 3 ) + 2;
		blur_time = randomfloatrange( 0.3, 0.7 );
		blur_time = ( blur_time + curr_ramp );

		recovery_time = randomfloatrange( 0.3, 1 );
		setblur( blur * 1.2, blur_time );
		wait blur_time;
		setblur( 0, recovery_time );

		blur_wait_time = randomfloatrange( 2.0, 3.0 ); 
		wait blur_wait_time;

		curr_ramp = ( curr_ramp + ramp );
	}
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
add_heartbeat_pattern_sound( type, beat_time, delay_time )
{
	next_key = SpawnStruct();

	if ( type == "slow" )
	{
		next_key.sound01 = "lunar_slow_heartbeat_01";
		next_key.sound02 = "lunar_slow_heartbeat_02";
	}
	else if ( type == "med" )
	{
		next_key.sound01 = "lunar_med_heartbeat_01";
		next_key.sound02 = "lunar_med_heartbeat_02";
	}
	else 
	{
		next_key.sound01 = "lunar_fast_heartbeat_01";
		next_key.sound02 = "lunar_fast_heartbeat_02";
	}

	next_key.beat_time = beat_time;
	next_key.delay_time = delay_time;
	return next_key;
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
player_heartbeat( ramp )
{
	level endon ( "stop_stumble_walk" );
	level._player endon ( "death" );

	wait 2.9;

	// Build pattern. 
	pattern = [];

	// Speed, Beat time, Delay until next heartbeat. 
	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "slow", .4, 2 );
	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "slow", .4, 2 );

	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "slow", .27, 1 );
	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "slow", .27, 1 );

	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "slow", .22, .67 );
	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "slow", .22, .67 );
	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "slow", .22, .67 );
	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "slow", .22, .67 );
	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "slow", .22, .67 );
	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "slow", .22, .67 );
	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "slow", .22, .67 );
	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "slow", .22, .67 );
	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "slow", .22, .67 );
																	   
	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "med",  .15, .49 );
	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "med",  .15, .49 );
																	  
	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "med",  .12, .39 );
	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "med",  .12, .39 );

	pattern[ pattern.size ] = add_heartbeat_pattern_sound( "fast", 0.08, 0.25 );

	// Play the pattern. 
	index = 0;
	while ( 1 )
	{
		next = pattern[ index ];

		level._player playsound( next.sound01 );
		level._player PlayRumbleOnEntity( "damage_light" );
		wait( next.beat_time );

		level._player playsound( next.sound02 );
		level._player PlayRumbleOnEntity( "damage_light" );
		wait( next.delay_time );

		// Next. 
		index++;

		// Keep looping the last item. 
		if ( index >= pattern.size )
		{
			index = pattern.size - 1;
		}
	}
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
stumble_walk_ends()
{
	level._player endon( "death" );
	level waittill( "stop_stumble_walk" );

	time = 0.8;
	if( IsDefined( level._ground_ref_ent ) )
	{ 
		level._ground_ref_ent rotateto( (0,0,0), time, time * 0.5, time * 0.5 );
		wait time;
		level._ground_ref_ent delete();
	}
	level._player playerSetGroundReferenceEnt( undefined );
	SetSlowMotion( 0.95, 1, 0.5 );
}

stumble_walk( starting_walk_intensity, ramp_time, cracking, blur, blur_ramp, blackout, blackout_delay )
{
	level._ground_ref_ent = spawn( "script_model", ( 0, 0, 0 ) );
	level._player playerSetGroundReferenceEnt( level._ground_ref_ent );

	thread stumble_walk_ends();

	level._player thread player_stumble_walk_intensity( starting_walk_intensity, ramp_time );

	if ( IsDefined( cracking ) && cracking )
	{
		level._player thread player_visor_glass_cracking();
	}

	if ( IsDefined( blur ) && blur )
	{
		if ( IsDefined( blur_ramp ) )
		{
			level._player thread player_random_blur( blur_ramp );
		}
		else
		{
			level._player thread player_random_blur();
		}
	}

	if ( IsDefined( blackout ) && blackout )
	{
		if ( IsDefined( blackout_delay ) )
		{
			level._player thread player_random_blackout( blackout_delay );
		}
		else
		{
			level._player thread player_random_blackout( 0.0 );
		}
	}

	// Stop stumble if it's already going, so no double stumle (like dying of vacuum in the intro).
	// level notify( "stop_stumble_walk" );
	// waittillframeend;
	level endon( "stop_stumble_walk" );
	level._unsteady_scale = 2.5;
	
	thread SetSlowMotion_overtime();
	ent = spawn_tag_origin();
	roll_ent = spawn_tag_origin();
	thread adjust_swivel_over_time( ent );

	pitch_sin = 0;
		
	time = 0.1;
	last_angles = level._player getplayerangles()[1];
	for ( ;; )
	{
		new_angles = level._player getplayerangles()[1];
		dif = new_angles - last_angles;
		yaw = dif;//ent.origin[0] + dif;
		last_angles = new_angles;

		player_speed = distance( (0,0,0), level._player getvelocity() );
		if ( player_speed <= 30)
		{
			player_speed = 30;
		}
		
		pitch_sin += player_speed * 0.06;
		
		if ( player_speed > 80 )
		{
			new_sin = sin( gettime() * -0.1 );
			pitch_sin += new_sin * 10;
		}
		
		pitch = sin( pitch_sin ) * 4 * level._unsteady_scale;
		wait 0.05;

		level._ground_ref_ent rotateto( ( pitch * 0.15, yaw * -1, pitch * 0.85 ), time, time * 0.5, time * 0.5 );
	}	
}

adjust_swivel_over_time( ent )
{
	level endon( "stop_stumble_walk" );
	next_switch = 1;	
	
	original_range = 7;
		
	for ( ;; )
	{
		range = original_range * level._unsteady_scale;
		yaw = randomfloatrange( range * 0.5, range );
		
		next_switch--;
		if ( next_switch <= 0 )
		{
			next_switch = randomint( 3 );
			yaw *= -1;
		}
			
		dif = yaw - ent.origin[0];
		dif = abs( dif );

		time = dif * 0.05;
		if ( time < 0.05 )
			time = 0.05;

		start_time = gettime();
		ent moveto( ( yaw, 0, 0 ), time, time * 0.5, time * 0.5 );
		wait time;
		
		wait_for_buffer_time_to_pass( start_time, 0.6 );
		for ( ;; )
		{
			player_speed = distance( (0,0,0), level._player getvelocity() );
			if ( player_speed >= 80 )
				break;
			wait 0.05;
		}

	}	
}

SetSlowMotion_overtime()
{
	level endon( "stop_stumble_walk" );
	timescale = 1;
	range = 0.15;
	time = 4;
	wait 3;
	for ( ;; )
	{
		SetSlowMotion( timescale, 0.89, time );
		wait time;
		SetSlowMotion( timescale, 1.06, time );
		wait time;
	}
}

vehicle_bay_upstairs_civilians()
{

	// top floor civilians
	civ_topfloor_01 = maps\_nx_vignette_util::vignette_actor_spawn("vehiclebay_breach_top_floor_civ01", "civ_01");
	civ_topfloor_02 = maps\_nx_vignette_util::vignette_actor_spawn("vehiclebay_breach_top_floor_civ02", "civ_02");
	civ_topfloor_03 = maps\_nx_vignette_util::vignette_actor_spawn("vehiclebay_breach_top_floor_civ03", "civ_01");
	// civ_topfloor_04 = maps\_nx_vignette_util::vignette_actor_spawn("vehiclebay_breach_top_floor_civ04", "civ_02");

	// node information
	node_topfloor_01 = getent("vignette_vh_bay_topfloor_civs", "script_noteworthy");
	node_topfloor_02 = getent("vignette_vh_bay_topfloor_civs_02", "script_noteworthy");

	guys_topfloor_01 = [];
	guys_topfloor_01["civ_01"] = civ_topfloor_01;
	guys_topfloor_01["civ_02"] = civ_topfloor_02;

	guys_topfloor_02 = [];
	guys_topfloor_02["civ_01"] = civ_topfloor_03;
	//guys_topfloor_02["civ_02"] = civ_topfloor_04;

	wait 1.5;

	node_topfloor_01 thread anim_loop ( guys_topfloor_01, "vehiclebay_breach_loop", "stop_loop");
	node_topfloor_02 thread anim_loop ( guys_topfloor_02, "vehiclebay_breach_loop", "stop_loop");

	flag_wait ( "player_in_vehicle_airlock" );

	node_topfloor_01 notify ("stop_loop");
	node_topfloor_02 notify ("stop_loop");

	civ_topfloor_01 maps\_nx_vignette_util::vignette_actor_delete();
	civ_topfloor_02 maps\_nx_vignette_util::vignette_actor_delete();
	civ_topfloor_03 maps\_nx_vignette_util::vignette_actor_delete();
	// civ_topfloor_04 delete();

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

airlock_and_breach()
{
	// Spawn the vehicle, unload and breach
	breach_rover = spawn_vehicle_from_targetname( "breach_rover" );
	level.breach_rover = breach_rover;
	level.breach_rover.dontunloadonend = true;
	level.breach_rover vehicle_lights_on( "running" );
	waittillframeend;
	level.breach_rover StartPath ();
	level._player thread fake_turret_fire();
	//JEG - Make riders invicible - the allies in the opening battle were killing them
	riders = level.breach_rover.riders;
	foreach( rider in riders )
	{
		if( IsDefined( rider ) )
		{
			rider enable_cqbwalk();
			rider thread magic_bullet_shield();
		}
	}

	// Start driving when the player is mobile
	flag_wait( "start_stumble_walk" );

	exploder( "fx_allies_breach_dust_exterior" );
	exploder( "fx_allies_breach_dust_interior" );
	exploder( "fx_allies_breach_dust_mote_interior" );

	path_start = getVehicleNode( "breach_rover_start", "targetname" );
	level.breach_rover AttachPath( path_start );
	level.breach_rover StartPath();
	level.breach_rover thread enemy_unload_and_breach();
	riders = level.breach_rover.riders;
	level.breach_rover.mgturret[0] SetAISpread ( 1 );
	level.breach_rover.mgturret[0].fireInterval = 1.0; // one shot per second
	level.breach_rover thread breach_rover_distance_check();

	// Player not directly targeted
	level._player.ignoreme = true;

	level.breach_rover.mgturret[0] TurretFireEnable();

	// Eventually kill player if they dawdle
	level.breach_rover thread kill_player_before_airlock( 22.0 );

	// Wait for player to enter airlock
	flag_wait( "player_in_vehicle_airlock" );
	exploder( "fx_allies_breach_dust_bomb" );
	thread airlock_dust_fx();

	// Turn off the blackout. 
	level._player.stop_blackout = true;

	// Close first airlock door
	// wait( 3.0 );
	//level._player playsound( "lunar_door_open" );

	// Stop rover from firing randomly
	// level.breach_rover notify( "stop_random_turret_fire" ); 
	level.breach_rover.mgturret[0] TurretFireDisable();

	// Wait a bit for door to close
	wait 2.0;

	level thread maps\nx_lunar_util::airlock_fx( "vehicle_airlock_breach_01" );
	//soundent2 = spawn( "sound_emitter", level._player.origin );
	//soundent2 linkto( level._player );
	//soundent2 playsound ( "nx_lunar_pressurize" );

	// change helmet sfx state
	//thread maps\_utility::set_ambient( "nx_lunar_get_to_armory" );
	
	flag_set( "sfx_int_base_engsuit_helmet_press" );  //(repressurized in the airlock with engineering suit - helmet visor still down).

	// Terminal prints
	//level thread vehicle_airlock_terminal();
	maps\nx_lunar_util::airlock_cycle();

	// Airlock FX
	thread airlock_vapor_effects();
	thread airlock_vision_effects();

	flag_set( "music_player_in_vehicle_airlock" );

	// Wait for airlock ready open
	flag_wait( "vehicle_airlock_open" );

	thread maps\_utility::set_ambient( "nx_lunar_get_to_armory" );
	//thread maps\_ambient::play_ambience( "nx_lunar_get_to_armory" );
	//thread maps\_ambient::start_ambient_event( "nx_lunar_get_to_armory" );

	// Checkpoint!
	level thread autosave_now();	

	// change the helmet sfx state to having no visor (tbd)
	flag_set( "sfx_int_base_engsuit_nohelmet_press" );  //(running with helmet up from airlock to armory through pressurized base)

	// Open the door
	level thread maps\nx_lunar_util::open_lunar_door( "vehicle_airlock_door_02", 1.0 );
	level thread maps\nx_lunar_util::lunar_door_status( "vehicle_airlock_door_02", "status_green" );
	level thread maps\nx_lunar_util::lunar_door_status( "vehicle_airlock_breach_01", "status_red" );

	// Player leaves airlock, thread breach player logic
	thread vehicle_bay_civilians_flee();
	level thread player_thread();
	level thread falcon_thread();

	// Randomly played unseen breaches
	thread distant_breach_randomizer();
	
	// Wait until the player has entered the storage room
	flag_wait( "vignette_armory_enter" );

	// Move Eagle to his start position for the helmet handoff
	node = getent("vignette_armory_breach", "script_noteworthy");
	node anim_teleport_solo( level.eagle, "armory_entrance_player");
	level.eagle SetLookAtEntity( level._player );

	// Reduce the player's suit's "health" to reflect damage and necessitate patching
	level._player SetSuitShieldHealth ( 20 );
	SetSavedDvar( "lunar_hud_suit_shield_fake_health", 0 ); //no longer fake the UI.

	level thread maps\nx_lunar_util::open_lunar_door( "vehicle_door_02", 1.0 );
	foreach( rider in riders )
	{
		if( IsDefined( rider ) )
		{
			rider stop_magic_bullet_shield();
			rider Delete();
		}
	}

	level.breach_rover vehicle_lights_off( "running", true );
	breach_rover Delete();
}

//self = the breach rover
breach_rover_distance_check()
{
	self endon ("death");
	while ( !flag ("player_in_vehicle_airlock") )
	{
		// If the player is ridiculously near the rover, remove invulnerability (so getting run over kills).
		dist = Distance( self.origin, level._player.origin);
		wait .1;
		if ( dist <= 300)
		{
			level._player DisableInvulnerability();
			SetDvar( "ui_deadquote", "NX_LUNAR_FAIL_RUN_OVER" );
		}
	}
}

airlock_vapor_effects()
{
	// Pressurization vapor FX
	exploder( "fx_armory_pressurize" );
	
	wait 10;

	// Stop pressurization vapor FX
	stop_exploder( "fx_armory_pressurize" );
}

airlock_vision_effects()
{
	// vision set fx
	set_vision_set("nx_lunar_in_the_breach", 3.0);
	wait 7.0;
	set_vision_set("nx_lunar_alert", 8.0);

	// turn on the exterior vehicle bay light now that we're inside
	vehicle_bay_key_light = GetEnt( "vehiclebay_key", "targetname" );
	vehicle_bay_key_light SetLightIntensity(3.25);

}

airlock_dust_fx()
{
	stop_exploder( "fx_allies_breach_dust_mote_interior" );
	exploder( "fx_allies_breach_dust_mote_crazy_interior" );

	wait 4.5;
	stop_exploder( "fx_allies_breach_dust_interior" );
	stop_exploder( "fx_allies_breach_dust_mote_crazy_interior" );

	wait 4.0;
	stop_exploder( "fx_allies_breach_dust_exterior" );
}

// self = enemy lgv
enemy_unload_and_breach()
{
	thread fake_breachers();
	
	self endon ( "death" );	

	// Wait till end of path, trigger unload
	riders = self.riders;
	self waittill( "reached_end_node" );
	self vehicle_unload( "all_but_gunner_and_driver" );
	self waittill( "unloaded" );

	// Give riders low goal radius
	foreach( rider in riders )
	{
		rider.goalradius = 0;
	}

	// Start breach threads
	// level thread breach_group_01_thread( riders[ 2 ], riders[ 3 ] );
	level thread breach_group_02_thread( riders[ 4 ], riders[ 5 ] );
	level thread breach_group_03_thread();
}

vehicle_bay_civilians_flee()
{
	flag_wait ("vehicle_bay_civ_flee");

	// Spawn the two civs and send them on their way.

	civ_01 = spawn_anim_model ("model_civ_03" );
	civ_02 = spawn_anim_model ("model_civ_04" );

	guys = [];

	guys["civ_01"] = civ_01;
	guys["civ_02"] = civ_02;

	// Placeholder until facial goes in.
	// They're breaching the base! 
	// Get out of the way!
	civ_01 playsound( "scn_lunar_scientist_run01" );

	node = getstruct ( "vignette_civs_up_stairs", "script_noteworthy");

	node anim_single ( guys , "civ_up_stairs");

	civ_01 delete();
	civ_02 delete();
}

hub_civilians_flee_spawn( )
{

	civ_01 = spawn_anim_model("model_civ_01");
	civ_02 = spawn_anim_model("model_civ_02");
	civ_03 = spawn_anim_model("model_civ_03");
	civ_04 = spawn_anim_model("model_civ_04");
	civ_05 = spawn_anim_model("model_civ_05");
	civ_06 = spawn_anim_model("model_civ_06");
	civ_07 = spawn_anim_model("model_civ_07");

	guys = [];
	guys["civ_01"] = civ_01;
	guys["civ_02"] = civ_02;
	guys["civ_03"] = civ_03;
	guys["civ_04"] = civ_04;
	guys["civ_05"] = civ_05;
	guys["civ_06"] = civ_06;
	guys["civ_07"] = civ_07;

	node = getstruct( "vignette_hub_room_civilians", "script_noteworthy" );

	node thread anim_first_frame ( guys, "civ_hub_room");

	flag_wait ( "bottom_hub_civ_flee" );

	civ_01 playsound( "scn_lunar_scientist_run02" );

	node anim_single ( guys, "civ_hub_room");

	foreach ( guy in guys )
	{
		guy delete();
	}
}

// self = a civilian
civilian_deleter( )
{
	self endon ("death");

	// When the civ gets to where he's going, delete him. Make sure goal entities are out of sight of the player.
	self waittill ( "goal" );
	self delete();
}

// This deletes the crates in the vehicle bay bottom floor, so they're gone when the player's squad returns there
remove_vehicle_bay_blockers()
{
	blockers = GetEntArray ("vehicle_bay_blocker", "targetname");
	foreach (thing in blockers)
	{
		thing delete();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_thread()
{	
	// Player is in vehicle bay airlock prep room
	close_lunar_door_behind_player( "room_status_vehicle_airlock_prep", "vehicle_airlock_door_02" );	
	level thread maps\nx_lunar_util::open_lunar_door( "vehicle_door_01", 1.0 );

	close_lunar_door_behind_player( "room_status_vehicle_main_lower", "vehicle_door_01" );
	
	// Player is upstairs
	flag_wait( "player_vehicle_upstairs" );
	// level thread maps\nx_lunar_util::open_lunar_door( "vehicle_door_03", 1.0 );
	level thread vehicle_upstairs_glass_check();
	level thread maps\nx_lunar_util::open_lunar_door( "control_door_1", 1.0 );
	level thread maps\nx_lunar_util::open_lunar_door( "control_door_2", 1.0 );
	thread hub_civilians_flee_spawn( );
	thread command_center_civilian_slaughter();

	// Player is in upstairs hallway
	close_lunar_door_behind_player( "room_status_vehicle_back_upstairs", "vehicle_door_03" );
	level thread maps\nx_lunar_util::open_lunar_door( "vehicle_door_04", 1.0 );

	// Player is in hub room
	close_lunar_door_behind_player( "room_status_hub_01", "vehicle_door_04" );
	level thread maps\nx_lunar_util::open_lunar_door( "hub_01_door_02", 1.0 );

	// Player is in control room upstairs
	close_lunar_door_behind_player( "room_status_control", "hub_01_door_02" );
	level thread maps\nx_lunar_util::open_lunar_door( "control_hall_door_01", 1.0 );
	level thread maps\nx_lunar_util::open_lunar_door( "control_hall_door_02", 1.0 );

	// Player is in Taser hallway
	close_lunar_door_behind_player( "room_status_control_hall", "control_hall_door_01" );

	// Player and Falcon are in hub room
	close_lunar_door_behind_player_and_falcon( "room_status_hub_02", "control_hall_door_02", "falcon_in_hub_02" );
	level thread maps\nx_lunar_util::open_lunar_door( "hub_02_door_01", 1.0 );

	//TagDK<NOTE>: Removed to smooth out transition into the lab
	// give the door time to open.
//  wait 1;
//  issue_color_orders( "b3", "allies" );

	get_to_armory_lab_wait();

	// give the door time to open.
	wait 1;
	issue_color_orders( "b4", "allies" );

	// Player and Falcon are in the "lab" (second taser hallway)
	close_lunar_door_behind_player_and_falcon( "room_status_lab", "hub_02_door_01", "falcon_in_lab" );
	
	thread close_lunar_door_behind_player_and_falcon( "room_status_storage", "storage_door_01", "falcon_in_storage" );

	// Player and Falcon are in the storage room
	maps\nx_lunar_util::open_lunar_door( "storage_door_01", 1.0 );
	issue_color_orders( "b5", "allies" );
	
	// Allow the player to fail by killing allies again.
	maps\_friendlyfire::TurnBackOn();
}

get_to_armory_lab_wait()
{
	level.taser_enemy endon( "death" );

	flag_wait( "vignette_armory_enter" );
}

vehicle_upstairs_glass_check()
{
	// Random turret fire on upstairs of vehicle bay
	level.breach_rover thread vehicle_upstairs_turret_fire();

	// Get glass references
	vehicle_bay_glass = GetGlassArray( "vehicle_bay_glass" );

	foreach( glass in vehicle_bay_glass )
	{
		level thread vehicle_upstairs_glass_thread( glass );
	}

	// Wait for glass destroyed and set room status
	// level waittill( "vehicle_upstairs_glass_destroyed" );
	level.breach_rover notify( "stop_random_turret_fire" ); 
	level.breach_rover.mgturret[0] TurretFireDisable();
	thread upstairs_glass_gravity();

	foreach( glass in vehicle_bay_glass )
	{
		DestroyGlass( glass, (0,1,0) );
	}

}

upstairs_glass_gravity()
{
	SetPhysicsGravityDir( (-10000000,0, 0) );
	wait 4;
	SetPhysicsGravityDir( (0,0,-1) );
}

vehicle_upstairs_glass_thread( glass )
{
	level endon( "vehicle_upstairs_glass_destroyed" );

	while( true ) 
	{
		if( IsGlassDestroyed( glass ) )
		{
			level notify( "vehicle_upstairs_glass_destroyed" );
			return;
		}
		wait( 0.05 );
	}
}

// self = a breacher
breacher_deleter()
{
	flag_wait ("vignette_armory_breach");
	if (isdefined ( self ))
	{
		self delete();
	}
}

fake_breachers()
{
	flag_wait ( "vignette_vh_bay_breach" ); 
	wait .3;
	// New first group of breachers to accomodate new vignette
	opfor_01 = spawn_targetname ("fake_breach_group_01", true );
	opfor_02 = spawn_targetname ("fake_breach_group_02", true );
	opfor_01.ignoreall = true;
	opfor_02.ignoreall = true;

	opfor_01.curr_breach_door = "fake";
	level thread enemy_door_breach( "vehicle_airlock_breach_01", opfor_01, opfor_02, "room_status_vehicle_airlock" );

	wait 14;

	opfor_01 delete();
	opfor_02 delete();
}


breach_group_01_spawn()
{

	// Spawn vbay airlock civilians	
	civ_01 = maps\_nx_vignette_util::vignette_actor_spawn("vehiclebay_breach_civ01", "civ_01");
	civ_02 = maps\_nx_vignette_util::vignette_actor_spawn("vehiclebay_breach_civ02", "civ_02");

	node = getent("vignette_vh_bay_breach", "script_noteworthy");
	node thread anim_loop_solo( civ_01, "vehiclebay_breach_loop", "stop_loop" );
	node thread anim_loop_solo( civ_02, "vehiclebay_breach_loop", "stop_loop");

	flag_wait ( "player_in_vehicle_airlock" );

	// New first group of breachers to accomodate new vignette
	opfor_01 = spawn_targetname ("breach_group_01_opfor_01", true );
	opfor_02 = spawn_targetname ("breach_group_01_opfor_02", true );

	opfor_01 thread breacher_deleter();
	opfor_02 thread breacher_deleter();

	level thread breach_group_01_thread( civ_01, civ_02, opfor_01, opfor_02 );

	node notify("stop_loop");
}

breach_group_01_thread( civ_01, civ_02, opfor_01, opfor_02 )
{
	opfor_01 endon ("death");
	opfor_02 endon ("death");
	opfor_01.fixednode = true;
	opfor_02.fixednode = true;

	level waittill ("start_vh_bay_breach");
	opfor_01 forceUseWeapon( "breacher", "primary" );
	opfor_01.ignoreall = true;
	opfor_02.ignoreall = true;
	
	// First breach
	opfor_01.curr_breach_door = "vehicle_hatch_breach";
	breach_group_teleport( opfor_01, opfor_02, "teleport_vehicle_lower_breach_01", "teleport_vehicle_lower_breach_02" );
	
	level thread maps\nx_lunar_anim::vignette_vehiclebay_breach( civ_01, civ_02, opfor_01, opfor_02 );

	// Wait until anim is completed before giving next order
	opfor_01 ent_flag_wait( "at_breach_door" );
	opfor_02 ent_flag_wait( "at_breach_door" );

	while( opfor_01._animActive > 0 )
	{
		wait( 0.05 );
	}

	opfor_01_goal = GetNode ( "opfor_1_after_breach_destination", "targetname" );
	opfor_01 SetGoalNode ( opfor_01_goal );
	opfor_01.goalradius = 10;

	opfor_02_goal = GetNode ( "opfor_2_after_breach_destination", "targetname" );
	opfor_02 SetGoalNode ( opfor_02_goal );
	opfor_02.goalradius = 10;

	flag_wait ( "vehicle_bay_breach_skip_to_charge" );

	// Wait for player in lower room, force breach on lower door
	// Note the anim script has a special wait in this case to jump them to the first charge so the player sees it
	opfor_01 ent_flag_set( "door_breached" );
	level thread enemy_door_breach( "vehicle_door_02", opfor_01, opfor_02, "room_status_vehicle_main_lower" );
	opfor_01 waittill("charged");
	
	/* 
	// Don't breach this door
	// If player is still in this room after this time, blow the charge
	wait 10;
	if ( flag ( "room_status_vehicle_main_lower"))
	{
		opfor_01 notify("detonate");
	}
	*/
	// KenM - Stop the breach when the player starts experiencing the top floor breach sequence.
	// Post-MS, we should put a door at the top or bottom of the staircase to gate the player
	flag_wait ("top_floor_breach");
	flag_set ("disable_random_distant_breach");

	// Checkpoint after the top_floor breach vignette
	level waittill ("top_floor_breach_done");
	flag_clear ("disable_random_distant_breach");
	level thread autosave_now();

	// Teleport the enemies
	wait_for_player_in_room( "room_status_vehicle_back_upstairs" ); 

	stop_enemy_door_breach( opfor_01, opfor_02 );
	opfor_01 notify("detonate");
	wait 4;
	breach_group_teleport( opfor_01, opfor_02, "teleport_vehicle_breach_01", "teleport_vehicle_breach_02" );
	breach_group_hidden_speed( opfor_01, opfor_02 );

	// Breach upper floor vehicle bay door 01

	level thread enemy_door_breach( "vehicle_door_03", opfor_01, opfor_02, "room_status_vehicle_back_upstairs" );
	opfor_01 waittill("charged");
	// KenM - Increase in time between final charge and detonation for GL.
	wait 4;
	opfor_01 notify("detonate");
	wait_for_enemies_door_breached( opfor_01, opfor_02 );
	
	// Breach upper floor vehicle bay door 01

	level thread enemy_door_breach( "vehicle_door_04", opfor_01, opfor_02, "room_status_hub_01" );
	opfor_01 waittill("charged");
		// KenM - Increase in time between final charge and detonation for GL.
	wait 4;
	opfor_01 notify("detonate");
}

breach_group_02_thread( opfor_01, opfor_02 )
{
	opfor_01 endon ("death");
	opfor_02 endon ("death");

	thread breach_rover_pulls_up();

	// Start second breach group
	breach_group_teleport( opfor_01, opfor_02, "teleport_airlock_breach_01", "teleport_airlock_breach_02" );

	opfor_01 forceUseWeapon( "breacher", "primary" );
	opfor_01.ignoreall = true;

	// Breach airlock entrance
	level thread enemy_door_breach( "vehicle_airlock_breach_01", opfor_01, opfor_02, "room_status_vehicle_airlock" );
	// wait_for_enemies_at_breach_door( opfor_01, undefined );
	flag_wait ("airlock_animation_done");

	// opfor_01 waittill ("charge_inserted");

	// Open airlock
	flag_set( "vehicle_airlock_open" );

	opfor_01 waittill("charged");
	// KenM - Increase in time between final charge and detonation for GL.
	wait 4;
	opfor_01 notify("detonate");
	wait .5;
	// level thread maps\nx_lunar_util::lunar_door_status( "vehicle_airlock_breach_01", "status_green" );
	level thread maps\nx_lunar_util::lunar_door_status( "vehicle_airlock_door_02", "status_red" );

	// wait_for_enemies_door_breached( opfor_01, undefined );
	flag_set ("vehicle_airlock_breached");

	// Breach second airlock entrance
	opfor_01 waittill ("breach_done");
	level thread enemy_door_breach( "vehicle_airlock_door_02", opfor_01, undefined, "room_status_vehicle_airlock_prep" );
	opfor_01 waittill("charged");
	// KenM - Increase in time between final charge and detonation for GL.
	wait 4;
	opfor_01 notify("detonate");
	wait .5;
	level thread maps\nx_lunar_util::lunar_door_status( "vehicle_airlock_door_02", "status_green" );
	level thread maps\nx_lunar_util::lunar_door_status( "vehicle_door_01", "status_red" );

	wait_for_enemies_door_breached( opfor_01 );

	// Breach main room entrance
	level thread enemy_door_breach( "vehicle_door_01", opfor_01, opfor_02, "room_status_vehicle_main_lower" );
	opfor_01 waittill("charged");
	// KenM - Increase in time between final charge and detonation for GL.
	wait 4;
	opfor_01 notify("detonate");
}

breach_rover_pulls_up()
{
	// wait 2;
	// Pull the rover into the vehicle bay.
	path_start = getVehicleNode( "breach_rover_into_bay_start", "targetname" );
	level.breach_rover AttachPath( path_start );
	level.breach_rover StartPath();

	level.breach_rover waittill ( "reached_end_node" );

	driver = level.breach_rover.riders[0];
	driver.ignoreall = true;

	// Pacing Pause
	wait( 1.0 );

	level.breach_rover vehicle_unload( "all" );

	level.breach_rover ent_flag_wait( "unloaded" );
	driver waittill( "goal" );

	goal = GetNode ( "driver_goal_node_1", "targetname" );
	driver SetGoalNode ( goal );
	driver.goalradius = 10;
	driver waittill( "goal" );

	wait( 3.0 );

	goal = GetNode ( "driver_goal_node_2", "targetname" );
	driver SetGoalNode ( goal );
	driver.goalradius = 10;
}

breach_group_03_thread()
{
	// Wait for player to enter HUB
	flag_wait( "room_status_hub_01" );	

	// Spawn the AI actors
	opfor_01_spawner = GetEnt( "hub_01_breach_opfor_01", "targetname" );
	opfor_01 = opfor_01_spawner spawn_ai();
	opfor_01.animname = "opfor_01";

	opfor_01 forceUseWeapon( "breacher", "primary" );
	opfor_01.ignoreall = true;
	
	opfor_02_spawner = GetEnt( "hub_01_breach_opfor_02", "targetname" );
	opfor_02 = opfor_02_spawner spawn_ai();
	opfor_02.animname = "opfor_02";
	opfor_02.ignoreall = true;	

	opfor_01 thread breacher_deleter();
	opfor_02 thread breacher_deleter();

	opfor_01 endon ("death");
	opfor_02 endon ("death");

	// Breach hub side door
	level thread enemy_door_breach( "hub_01_door_01", opfor_01, opfor_02, "room_status_hub_01" );
	opfor_01 waittill("charged");
	// KenM - Increase in time between final charge and detonation for GL.
	wait 4;
	opfor_01 notify("detonate");
	level thread maps\nx_lunar_util::lunar_door_status( "hub_01", "status_red" );
	level thread maps\nx_lunar_util::lunar_door_status( "hub_01_b", "status_green" );

	// Breach door into control room
	wait_for_player_in_room( "room_status_control" ); 
	stop_enemy_door_breach( opfor_01, opfor_02 );
	breach_group_teleport( opfor_01, opfor_02, "teleport_hub_01_breach_01", "teleport_hub_01_breach_02" );
	breach_group_hidden_speed( opfor_01, opfor_02 );

	// opfor_01.curr_breach_door = "hub_01_door_02";
	level thread enemy_door_breach( "hub_01_door_02", opfor_01, opfor_02, "room_status_control" );
	opfor_01 waittill("charged");
	// KenM - Increase in time between final charge and detonation for GL.
	wait 4;
	opfor_01 notify("detonate");
	level thread maps\nx_lunar_util::lunar_door_status( "control_hall_door_01", "status_red" );

	// Wait for falcon to hand off taser, begin breach on hallway
	flag_wait( "falcon_taser_handoff" );
	stop_enemy_door_breach( opfor_01, opfor_02 );
	breach_group_teleport( opfor_01, opfor_02, "teleport_control_breach_01", "teleport_control_breach_02" );
	breach_group_hidden_speed( opfor_01, opfor_02 );
	
	// opfor_01.curr_breach_door = "control_hall_door_01";
	level thread enemy_door_breach( "control_hall_door_01", opfor_01, opfor_02, "room_status_control_hall" );
	wait_for_enemies_at_breach_door( opfor_01, opfor_02 );

	// Falcon tells you to get out if you're still in that almost-breached room.
	if ( flag ("room_status_control_hall"))
	{
		// Breach from behind, get out of there!
		radio_dialogue ( "moon_fal_toarm_04" );
	}
	
	opfor_01 waittill("charged");
	// KenM - Increase in time between final charge and detonation for GL.
	wait 4;
	opfor_01 notify("detonate");
	level thread maps\nx_lunar_util::lunar_door_status( "control_hall_door_02", "status_red" );

	wait_for_enemies_door_breached( opfor_01, opfor_02 );

	// Breach door hub 02
	breach_group_hidden_speed( opfor_01, opfor_02 );

	// opfor_01.curr_breach_door = "control_hall_door_02";
	level thread enemy_door_breach( "control_hall_door_02", opfor_01, opfor_02, "room_status_hub_02" );
	wait_for_enemies_at_breach_door( opfor_01, opfor_02 );

	// Falcon tells you to get out if you're still in that almost-breached room.
	if ( flag ("room_status_hub_02"))
	{
		// They're breaching, keep moving forward!
		radio_dialogue ( "moon_fal_toarm_breachmove" );
	}
	
	opfor_01 waittill("charged");
	// KenM - Increase in time between final charge and detonation for GL.
	wait 4;
	opfor_01 notify("detonate");
	level thread maps\nx_lunar_util::lunar_door_status( "hub_02_door_01", "status_red" );

	wait_for_enemies_door_breached( opfor_01, opfor_02 );

	// Breach door into lab
	wait_for_player_in_room( "room_status_lab" ); 
	
	// Player can hang out and watch them, so let's let them progress more naturally.
	breach_group_hidden_speed( opfor_01, opfor_02 );

	// opfor_01.curr_breach_door = "hub_02_door_01";
	level thread enemy_door_breach( "hub_02_door_01", opfor_01, opfor_02, "room_status_lab" );

	wait_for_enemies_at_breach_door( opfor_01, opfor_02 );

	// Falcon tells you to get out if you're still in that almost-breached room.
	if ( flag ("room_status_lab"))
	{
		// They're about to pop the room! Keep moving!
		radio_dialogue ( "moon_fal_toarm_poproom" );
	}

	opfor_01 waittill("charged");
	// KenM - Increase in time between final charge and detonation for GL.
	wait 4;
	opfor_01 notify("detonate");
	level thread maps\nx_lunar_util::lunar_door_status( "storage_door_01", "status_red" );
}

breach_group_teleport( opfor_01, opfor_02, tele_01_name, tele_02_name )
{
	tele_01 = GetEnt( tele_01_name, "targetname" );
	tele_02 = GetEnt( tele_02_name, "targetname" );

	opfor_01 ForceTeleport( tele_01.origin, tele_01.angles );
	opfor_02 ForceTeleport( tele_02.origin, tele_02.angles );
}

distant_breach_randomizer()
{
	level endon ("player_in_armory");
	while (1)
	{
		if ( !flag ("disable_random_distant_breach"))
		{
			thread distant_breach_effects( (RandomFloatRange( 0.2, 0.3 )), (RandomFloatRange( 1.5, 3 )));
		}
		wait (RandomIntRange( 8, 17 ));
	}
}

distant_breach_effects( intensity, time)
{
	level._player playsound("lunar_explosions_dist_breach");
	Earthquake( intensity, time , level._player.origin, 5000 );
	level._player PlayRumbleOnEntity( "damage_light" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


command_center_civilian_slaughter()
{
	blood_splats = GetEntArray ("control_civ_blood_splat", "script_noteworthy");
	foreach ( splat in blood_splats)
	{
		splat hide();
	}

	flag_wait ("command_center_civ_flee");

	civ_01 = spawn_anim_model("model_civ_06");
	civ_02 = spawn_anim_model("model_civ_05");
	civ_03 = spawn_anim_model("model_civ_04");
	civ_04 = spawn_anim_model("model_civ_03");
	civ_05 = spawn_anim_model("model_civ_02");
	civ_06 = spawn_anim_model("model_civ_01");
	chair_01 = spawn_anim_model("chair_01");
	chair_02 = spawn_anim_model("chair_02");

	guys = [];
	guys["civ_01"] = civ_01;
	guys["civ_02"] = civ_02;
	guys["civ_03"] = civ_03;
	guys["civ_04"] = civ_04;
	guys["civ_05"] = civ_05;
	guys["civ_06"] = civ_06;
	guys["chair_01"] = chair_01;
	guys["chair_02"] = chair_02;

	thread command_center_civilian_slaughter_enemy( civ_01, civ_02);

	node = GetStruct ("vignette_control_room_civilians", "script_noteworthy");

	node anim_single ( guys , "cnc_civ_shot");

}

command_center_civilian_slaughter_enemy( target_1, target_2)
{
	
	killer = spawn_script_noteworthy( "command_center_killer_spawner" );
	fake_target_1 = GetEnt ("control_center_slaughter_target_1", "targetname");
	fake_target_2 = GetEnt ("control_center_slaughter_target_2", "targetname");
	fake_target_3 = GetEnt ("control_center_slaughter_target_3", "targetname");
	fake_target_4 = GetEnt ("control_center_slaughter_target_4", "targetname");
	fake_target_5 = GetEnt ("control_center_slaughter_target_5", "targetname");
	fake_target_6 = GetEnt ("control_center_slaughter_target_6", "targetname");
	killer enable_cqbwalk();
	killer.pacifist = true;
	killer.fixednode = true;

	killer thread command_center_civilian_slaughter_shoot( fake_target_1, "first_shot", "control_civ_blood_splat_01");
	killer thread command_center_civilian_slaughter_shoot( fake_target_2, "second_shot", "control_civ_blood_splat_02");
	killer thread command_center_civilian_slaughter_shoot( fake_target_3, "third_shot" );
	killer thread command_center_civilian_slaughter_shoot( fake_target_4, "fourth_shot" );
	killer thread command_center_civilian_slaughter_shoot( fake_target_5, "fifth_shot" );
	killer command_center_civilian_slaughter_shoot( fake_target_6, "sixth_shot" );
	
	flag_wait ("enemy_dies");

	killer.dontevershoot = true;
	killer SetLookAtEntity( level._player );
	killer cqb_aim ( level._player );
	// killer.fixednode = false;

	/* The enemy on the player's side of the glass dies
	flag_wait ("enemy_dies");
	killer SetLookAtEntity( level.falcon_taser );
	killer cqb_aim ( level.falcon_taser );
	wait 1;
	*/
	killer disable_cqbwalk();
	
	goal = GetEnt ("command_center_killer_flee_goal", "targetname");
	killer SetGoalEntity( goal );
	waittillframeend;
	killer waittill ("goal");
	flag_wait ("room_status_hub_02");

	killer delete();
}

command_center_civilian_slaughter_shoot( fake_target, notification, blood )
{
	self SetLookAtEntity( fake_target );
	self cqb_aim ( fake_target );

	level waittill ( notification );

	// self Shoot( 1, fake_target.origin);
	self startcontinuousfire();
	MagicBullet( "lunarrifle", self gettagorigin( "tag_flash"), fake_target.origin );
	PlayFX( level._effect[ "charlie_impact" ], fake_target.origin );
	if (isdefined ( blood ))
	{
		blood_splats = GetEntArray ( blood , "targetname");
		foreach ( splat in blood_splats)
		{
			splat show();
		}
	}
}

falcon_thread()
{
	// Wait for player to enter the control hall
	// flag_wait( "falcon_spawn" );

	flag_wait ("vignette_taser");
	level._player.ignoreme = false;

	// Excising this portion for new taser scene.

	// Spawn enemy
	enemy_spawner = GetEnt( "enemy_control_room_taser", "targetname" );
	enemy = enemy_spawner spawn_ai( true );
	enemy SetLookAtEntity( level._player );
	enemy.dontevershoot = true;
	//enemy.dontattackme = true;
	enemy.favoriteenemy = level._player;
	enemy.health = 1;

	flag_wait ("enemy_dies");

	// Spawn falcon
	falcon_spawner = GetEnt( "falcon_taser_spawner", "targetname" );
	falcon_spawner thread add_spawn_function( ::falcon_spawn_func );
	level.falcon_taser = falcon_spawner spawn_ai( true );
	level.falcon_taser.animname = "falcon";	

	// Fake-shoot the enemy
	MagicBullet( "lunarrifle", level.falcon_taser gettagorigin( "tag_flash"), (enemy.origin + (0,0,40)) );
	badguy = spawn( "sound_emitter", enemy.origin );
	badguy playsound("scn_lunar_meet_greet_enemy_shot");
	
	wait .1 ;
	MagicBullet( "lunarrifle", level.falcon_taser gettagorigin( "tag_flash"), (enemy.origin + (0,0,40)) );
	wait .1;
	MagicBullet( "lunarrifle", level.falcon_taser gettagorigin( "tag_flash"), (enemy.origin + (0,0,42)) );
	
	level thread maps\nx_lunar_anim::taser_spawn();

	// level.falcon_taser.ignoreall = true;
	level.falcon_taser SetLookAtEntity( level._player );

	wait_for_player_in_room( "room_status_control_hall" );

	level thread maps\nx_lunar_util::close_lunar_door( "control_hall_door_02", 1.0 );
	// wait 1;


	// Checkpoint!
	if ( flag ("room_status_control_hall"))
	{
		level thread autosave_now();
	}
	badguy delete();


	// Riggs: Walker! You're still alive! Let's get to the Armory.
	radio_dialogue ( "moon_fal_toarm_taser" );

	// Riggs: Take This.
	thread radio_dialogue ( "moon_fal_toarm_takethis" );

	flag_set( "falcon_taser_handoff" );
	level waittill ("taser_catch");
	level._player playsound("scn_lunar_meet_greet_plr_catch");
	thread player_gets_taser();
	issue_color_orders( "b1", "allies" );


	// Riggs: You look like shit. Where's your helmet?
	thread radio_dialogue ( "moon_fal_toarm_wherehelmet" );

	// Falcon moves
	level.falcon_taser StopLookAt(  );
	level.falcon_taser enable_ai_color();
	// *** TASER ENEMY 01 ***
	level thread taser_enemy_01_thread();

	// Remove blocker
	taser_player_blocker = GetEnt ("taser_player_blocker", "targetname");
	taser_player_blocker delete();

	// Player no longer ignored
	level._player.ignoreme = false;
	
	// Wait for player to hit enemy with taser, weapons free on Falcon
	flag_wait( "hallway_taser_hit" );
	
	flag_set ("falcon_taser_vignette");
	flag_clear( "hallway_taser_hit" );
	// falcon_weapons_halt();

	// Wait for next taser encounter

	// *** TASER ENEMY 02 ***
	level thread taser_enemy_02_thread();

	flag_wait( "falcon_in_lab" );
	// Behind the console!
	if ( isAlive (level.taser_enemy))
	{
		radio_dialogue ( "moon_fal_toarm_06" );
	}

	// Wait for player to hit enemy with taser, weapons free on Falcon
	flag_wait( "hallway_taser_hit" );
	waittillframeend;
	flag_clear( "hallway_taser_hit" );
	// falcon_weapons_free();
	
	//thread maps\_utility::set_ambient( "nx_lunar_cargo_bay" );
	thread maps\_ambient::play_ambience( "nx_lunar_cargo_bay" );
	thread maps\_ambient::start_ambient_event( "nx_lunar_cargo_bay" );

	flag_wait ( "vignette_armory_enter" );

	// Riggs: This way!
	radio_dialogue ( "moon_fal_toarm_thisway" );

	thread falcon_guide_vo();

	// Wait for armory scene
	falcon_weapons_halt();
}



player_gets_taser()
{
	// Give weapon
	level._player TakeAllWeapons();
	level._player GiveWeapon( "lunarabg" );
	level._player SwitchToWeapon( "lunarabg" );
}

taser_enemy_01_thread()
{
	wait 2;
	// level.falcon_taser waittill ("goal");

	// Spawn enemies
	taser_enemy_01_spawner = GetEnt( "enemy_hub_02_taser_01", "targetname" );
	taser_enemy_02_spawner = GetEnt( "enemy_hub_02_taser_02", "targetname" );
	taser_enemy_01_spawner thread add_spawn_function( maps\nx_lunar_util::lunar_enemy_interior_common );
	taser_enemy_02_spawner thread add_spawn_function( maps\nx_lunar_util::lunar_enemy_interior_common );
	level.taser_enemy = taser_enemy_01_spawner spawn_ai( true );
	level.taser_enemy_2 = taser_enemy_02_spawner spawn_ai( true );
	level.taser_enemy maps\nx_lunar_util::ignore_everything();
	level.taser_enemy_2 maps\nx_lunar_util::ignore_everything();

	level.taser_enemy waittill ( "goal" );

	level.falcon_taser SetLookAtEntity( level._player );

	// Riggs: Tangos ahead.
	radio_dialogue ( "moon_fal_toarm_tangosahead" );

	// Riggs: I got these guys.
	radio_dialogue ( "moon_fal_toarm_gotthese" );

	level.falcon_taser StopLookAt( 1.0 );

	wait( 1.0 );

	level thread maps\nx_lunar_util::open_lunar_door( "control_hall_door_02", 1.0 );

	if( IsAlive( level.taser_enemy_2 ) )
	{
		taser_enemy_2_movement_node = GetNode( "taser_enemy_01_stand", "targetname" );
		level.taser_enemy_2 SetGoalNode( taser_enemy_2_movement_node );
		level.taser_enemy_2.radius = 10;
	}

	level.falcon_taser.ignoreall = false;
	level.taser_enemy.ignoreall = false;

	level.taser_enemy.ignoreme = true;

	level.falcon_taser.baseaccuracy = 1000.0;
	level.falcon_taser.favoriteenemy = level.taser_enemy_2;

	level.taser_enemy maps\nx_lunar_util::clear_ignore_everything();
	level.taser_enemy_2 maps\nx_lunar_util::clear_ignore_everything();
	level.taser_enemy_2.health = 10;

	level.taser_enemy thread taser_enemy_01_kill_player();
	thread taser_enemy_01_kill_player_timer();
	level.taser_enemy.favoriteenemy = level._player;
	level._player DisableInvulnerability();

	if( IsAlive( level.taser_enemy ) )
	{
		level.taser_enemy.health = 10;
		taser_enemy_1_movement_node = GetNode( "taser_enemy_02_stand", "targetname" );
		level.taser_enemy SetGoalNode( taser_enemy_1_movement_node );
		level.taser_enemy.radius = 10;
	}
	
	level.taser_enemy_2 waittill( "death" );
	//TagDK<NOTE>: Knock enemy back over railing testing
//  enemy_2_eye_origin = level.taser_enemy_2 getTagOrigin( "tag_eye" );
//  angles = level.taser_enemy_2.angles;
//  forward = AnglesToForward( angles );
//  forward *= 1000;
//  level.taser_enemy_2 StartRagdollFromImpact( enemy_2_eye_origin, forward );
//  level.taser_enemy_2 StartRagdoll();

	if( IsAlive( level.taser_enemy ) )
	{
		level.taser_enemy.ignoreme = false;
		level.falcon_taser.favoriteenemy = level.taser_enemy;
		level.taser_enemy.script_threatbias = 100000;
		level.taser_enemy waittill( "death" );
	}

	flag_set( "hallway_taser_hit" );
 
	issue_color_orders( "b2", "allies" );

	level.falcon_taser.baseaccuracy = 50.0;
}

// self = the taser enemy
taser_enemy_01_kill_player()
{	
	self endon ( "death" );
	self.baseaccuracy = 0.0;
	flag_wait ( "taser_enemy_kills_player" );
	self.baseaccuracy = 5000.0;
}

taser_enemy_01_kill_player_timer()
{
	wait 5;
	flag_set ( "taser_enemy_kills_player" );
}

taser_enemy_02_thread()
{
	// Spawn enemy
	taser_enemy_spawner = GetEnt( "enemy_lab_taser", "targetname" );
	taser_enemy_spawner thread add_spawn_function( maps\nx_lunar_util::lunar_enemy_interior_common );
	level.taser_enemy = taser_enemy_spawner spawn_ai();
	
	level.taser_enemy waittill ( "death" );

	level.falcon_taser.baseaccuracy = 10.0;

	flag_set( "hallway_taser_hit" );
}

// self = Falcon_taser
falcon_spawn_func()
{
	self.baseaccuracy = 100;
	self.moveplaybackrate = 1.15;
	// self.fixednode = false;
	self.disableBulletWhizbyReaction = true;
	self disable_surprise();
	self.dontavoidplayer = true;
	self.disablepain = true;

	// To prevent the player blowing him up with the grenade launcher. This turns back on after the storage room is entered.
	maps\_friendlyfire::TurnOff();

	self thread maps\nx_lunar_util::lunar_ally_interior_common();

	flag_wait ("vignette_armory_breach");

	self.moveplaybackrate = 1;
	self.baseaccuracy = 1;
	// self.fixednode = true;
	self.disableBulletWhizbyReaction = false;
	self.dontavoidplayer = false;
	self enable_surprise();
	self.disablepain = false;
}

falcon_weapons_free()
{
	level.falcon_taser.ignoreall = false;
}

falcon_weapons_halt()
{
	level.falcon_taser.ignoreall = true;
}

falcon_guide_vo()
{
	level endon ("player_in_armory");
	wait 4;
	if ( flag ("room_status_lab"))
	// Riggs: Come on! Move it!
	radio_dialogue ( "moon_fal_toarm_moveit" );
	wait 3;
	if ( flag ("room_status_lab"))
	// Riggs: Where are you going? Come on!
	radio_dialogue ( "moon_fal_toarm_wheregoing" );
	wait 5;
	if ( flag ("room_status_lab"))
	// Riggs: Move, damn it!
	radio_dialogue ( "moon_fal_toarm_movedamn" );

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

wait_for_enemies_at_breach_door( opfor_01, opfor_02 )
{
	if( IsDefined( opfor_01 ) )
	{
		opfor_01 ent_flag_wait( "at_breach_door" );
	}

	if( IsDefined( opfor_02 ) )
	{
		opfor_02 ent_flag_wait( "at_breach_door" );	
	}
}

wait_for_enemies_door_breached( opfor_01, opfor_02 )
{
	if( IsDefined( opfor_01 ) )
	{
		opfor_01 waittill ( "breach_done" );
	}

	if( IsDefined( opfor_02 ) )
	{
		opfor_02 waittill ( "breach_done" );
	}

}

breach_group_hidden_speed( opfor_01, opfor_02 )
{
	opfor_01 thread maps\nx_lunar_util::hidden_dynamic_run_speed();
	opfor_02 thread maps\nx_lunar_util::hidden_dynamic_run_speed();
}

stop_enemy_door_breach( opfor_01, opfor_02 )
{
	
	opfor_01 StopAnimScripted();
	opfor_02 StopAnimScripted();
	opfor_01 notify( "detonate");
	opfor_01 waittill ("breach_done");
	opfor_01 notify( "stop_breach" );

}

enemy_door_breach( door_name, opfor_01, opfor_02, room )
{
	opfor_01 endon ( "stop_breach");
	if( !IsDefined( opfor_01.curr_breach_door ) )
	{ 
		opfor_01.curr_breach_door = door_name;
		opfor_01.curr_breach_room = room;
	}

	lunar_door_parts = GetEntArray( door_name, "script_noteworthy" );

	// Get the specific parts from the door breach prefab
	breach_origin = undefined;
	foreach ( door_part in lunar_door_parts )
	{
		if( door_part.code_classname == "script_origin" )
		{
			if( door_part.targetname == "breach_origin" )
			{
				breach_origin = door_part;
			}
		}
		
		// Reconnect the pathmesh that runs through the door
		if( door_part.code_classname == "script_brushmodel" )
		{
			if( door_part.targetname == "right" || door_part.targetname == "left")  
			{
				door_part ConnectPaths();
			}
		}
		
	}

	level thread maps\nx_lunar_anim::opfor_door_breach( breach_origin, opfor_01, opfor_02, "opfor_door_breach" );

	// Wait for both to be at the breach door
	if( IsDefined( opfor_01 ) )
	{ 
		opfor_01 ent_flag_wait( "at_breach_door" );
	}

	if( IsDefined( opfor_02 ) )
	{
		opfor_02 ent_flag_wait( "at_breach_door" );
	}

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


room_status_init()
{
	room_status_triggers = GetEntArray( "room_status", "script_noteworthy" );
	foreach( room_status_trigger in room_status_triggers )
	{
		// Logic script for each status trigger
		room_status_trigger thread room_status_logic();
	}	     
}

room_status_logic()
{
	level endon( "stop_depressurization" );
	level endon( "depressurization_death" );
	self ent_flag_init( "depressurize" );
	self ent_flag_wait( "depressurize" );

	flag_wait( self.script_flag );

	// Start to kill the player
	level._player thread player_depressurization_kill();

	// Player has left the room.
	flag_waitopen ( self.script_flag );

	// And the door has closed.
	level waittill ("door_closed");

	// The player gets to live, hooray! Their sinuses must feel terrible, though.
	level notify ("player_escaped_breached_room");
	
	// Reset everything the kill routine starts
	level thread stop_stumble_walk( 1.0 );

	black_overlay = get_black_overlay();
	black_overlay FadeOverTime( 1.0 );
	black_overlay.alpha = 0;

	level._player EnableWeapons();
	set_vision_set("nx_lunar_alert", 1.0);
	bad_guys = GetAIArray( "axis" );
	foreach ( guy in bad_guys)
	{
		guy.ignoreall = true;
	}

	level._player.ignoreme = true;

	// tagTC<note>: code for if we want to allow player to live through
	// the depressurization
	// Wait for player to touch depressurization
	/*while( true )
	{
		flag_wait( self.script_flag );
	
		// Kill the player
		level._player thread player_depressurization_kill();
	
		// Cleck for leaving pressurized
		while( true )
		{
			if( !flag( self.script_flag ) )
			{
				level._player notify( "pressurized" );
				break;
			} 
			wait( 0.05 );
		}
	}*/
}

close_lunar_door_behind_player( room_name, door_name )
{
	room_status_trigger = GetEnt( room_name, "targetname" );
	
	// Waits for player to enter room
	flag_wait( room_status_trigger.script_flag );

	level maps\nx_lunar_util::close_lunar_door( door_name, 1.0 );
	level notify ("door_closed");

}

close_lunar_door_behind_player_and_falcon( room_name, door_name, falcon_flag )
{
	room_status_trigger = GetEnt( room_name, "targetname" );
	
	// Waits for player to enter room
	flag_wait( room_status_trigger.script_flag );

	// Waits for Falcon
	flag_wait( falcon_flag );

	level maps\nx_lunar_util::close_lunar_door( door_name, 1.0 );
	level notify ("door_closed");

}

wait_for_player_in_room( room_name )
{
	room_status_trigger = GetEnt( room_name, "targetname" );

	// Waits for player to enter room
	flag_wait( room_status_trigger.script_flag );
}

room_status_depressurize( room_name )
{
	room_status_trigger = GetEnt( room_name, "targetname" );
	
	// Depressurize the room
	room_status_trigger ent_flag_set( "depressurize" );	
}

player_depressurization_kill_exterior()
{
	level endon ("player_in_vehicle_airlock_notify");
	//TagCC<NOTE>: Travis, you can use set_suit_fade( "moon", blend_time ); to blend this over a period of time if that helps the effect.
	level._player set_suit( "moon" );
	//level._player ShellShock( "nx_lunar_get_to_armory", 10000 );
	level._player_heartrate = 1.4;
	level thread player_heartbeat( 0.2 );

	wait( 1.0 );

	bad_guys = GetAIArray( "axis" );
	foreach ( guy in bad_guys)
	{
		if ( guy.weapon != "breacher")
			guy.ignoreall = false;
	}

	// Make player a target
	level._player.ignoreme = false;
	level._player DisableInvulnerability();	

	wait( 4.0 );
	level notify ( "depressurization_death" );

	level._player ShellShock( "default", 3 );
	level._player SetStance ("prone");
	level._player FreezeControls( true );
	SetDvar( "ui_deadquote", "NX_LUNAR_FAIL_DEPRESSURIZED_EXTERIOR" );
	missionFailedWrapper();
}

player_depressurization_kill()
{
	level._player playsound( "scn_lunar_breach_detonate_air" );
	level endon ("player_escaped_breached_room");
	level._player DisableWeapons();
	set_vision_set("nx_lunar_breached", 0.1);
	//TagCC<NOTE>: Travis, you can use set_suit_fade( "moon", blend_time ); to blend this over a period of time if that helps the effect.
	level._player set_suit( "moon" );
	//level._player ShellShock( "nx_lunar_get_to_armory", 10000 );
	level._player_heartrate = 1.4;
	level thread player_heartbeat( 0.2 );

	wait( 1.0 );

	bad_guys = GetAIArray( "axis" );
	foreach ( guy in bad_guys)
	{
		if ( guy.weapon != "breacher")
			guy.ignoreall = false;
	}

	// Make player a target
	level._player.ignoreme = false;
	
	player_wakeup_movement_speed( 0.4 );
	//level._player FadeOutShellShock();
	if ( !flag ("start_stumble_walk"))
	{
		thread stumble_walk( 0.9, 3.0, false, true, 0.2, true, 0.0 );
		flag_set( "start_stumble_walk" );
	}
	level._player DisableInvulnerability();	

	wait( 4.0 );
	level notify ( "depressurization_death" );

	level._player ShellShock( "default", 0.9 );
	level._player SetStance ("prone");
	level._player FreezeControls( true );
	SetDvar( "ui_deadquote", "NX_LUNAR_FAIL_DEPRESSURIZED" );
	missionFailedWrapper();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// self = the breach rover
kill_player_before_airlock( kill_time )
{

	self endon ( "death" );
	level._player endon ("death");
	level endon ("player_in_vehicle_airlock_notify");

	wait( kill_time );

	// Player has waited too long, kill the player with turret
	// if( !flag( "player_in_vehicle_airlock" ) )
	// { 
	
		self notify( "stop_random_turret_fire" );

		level._player.ignoreme = false;
		level._player DisableInvulnerability();
		self.mgturret[0] SetTurretWeapon( "nx_chinese_lgv_turret" );
		self.mgturret[0] SetAISpread( 1 );
		self.mgturret[0] SetTargetEntity( level._player );
		self.mgturret[0] TurretFireEnable();

		// self thread vehicle_random_turret_fire( "airlock_turret_target" ); 
		thread player_depressurization_kill_exterior();

		// Wait for player to be hit
		level._player waittill( "damage" );
		level._player waittill( "damage" );
		missionFailedWrapper();
		level._player kill();
		
	// }
}

vehicle_upstairs_turret_fire()
{
	self endon ( "death" );	
	self notify ( "stop_random_turret_fire" );
//	target = GetEnt ("airlock_turret_target_top_floor", "targetname");
//	level.breach_rover.mgturret[0] SetTargetEntity( target );

	// Pull the rover out of the vehicle bay.
	// Can't even see this. Teleporting instead.
	// path_start = getVehicleNode ("breach_rover_exit_bay_start", "targetname");

	// level.breach_rover AttachPath ( path_start );
	// level.breach_rover StartPath ( path_start );

	breach_rover_exit_bay_end = getVehicleNode("breach_rover_into_bay_start", "targetname");

	// teleport them trucks
	level.breach_rover Vehicle_Teleport (breach_rover_exit_bay_end.origin, breach_rover_exit_bay_end.angles);
	level.breach_rover Vehicle_SetSpeedImmediate( 0, 10000, 10000 );
	
//	level waittill ("rover_fires_notify");
	
/*	
	level.breach_rover.mgturret[0] TurretFireEnable();
	level.breach_rover.mgturret[0] ShootTurret();
	wait .1;
	level.breach_rover.mgturret[0] TurretFireDisable();
*/
}

airlock_random_turret_fire_restart()
{
	self endon ( "death" );	
	self notify ( "stop_random_turret_fire" );

	// Has player made it to the airlock
	flag_wait( "player_in_vehicle_airlock" );
	self thread vehicle_random_turret_fire( "airlock_turret_target" ); 
}

vehicle_random_turret_fire( targets )
{
	self endon ( "death" );	
	self endon ( "stop_random_turret_fire" );

	turret_target_array = GetEntArray( targets, "targetname" );
	while( true )
	{
		target = turret_target_array[ randomInt( turret_target_array.size ) ];
		self.mgturret[0] SetAISpread( 1 );
		self.mgturret[0] SetTargetEntity( target );
		self.mgturret[0] TurretFireEnable();

		// Turret explosion
		wait .2;
		//PlayFX( level._effect[ "turret_explosion" ], target.origin );

		wait( 2.0 );	
	}
	
}

fake_turret_fire()
{
	fake_turret_fire_targeting();
	level.breach_rover.mgturret[0] SetMode( "manual" );
	level.breach_rover.mgturret[0] TurretFireDisable();

	fake_player_turret_target = GetEnt( "fake_player_turret_target", "targetname" );
	if( IsDefined( fake_player_turret_target ) )
	{
		fake_player_turret_target delete();	
	}
}

fake_turret_fire_targeting()
{
	level endon( "player_in_vehicle_airlock_notify" );
	// level.breach_rover endon ( "stop_random_turret_fire" );

	// Min/Max offsets. 
	// Min should be far enough away to not actually hit player. 
	// Max should be close enough so that it looks like they're kinda trying.

	offsetMinX = 32;
	offsetMaxX = 256;
	offsetMinY = 32;
	offsetMaxY = 256;	
	offsetMinZ = 32;
	offsetMaxZ = 128;	

	level.breach_rover.mgturret[0] SetTurretWeapon( "nx_chinese_lgv_turret_fake" );

	fake_player_turret_target = GetEnt( "fake_player_turret_target", "targetname" );
	level.breach_rover.mgturret[0] SetTargetEntity( fake_player_turret_target);
	level.breach_rover.mgturret[0].fireInterval = 1.0; // one shot per second

	while ( !flag( "player_in_vehicle_airlock" ) )
	{

		// Re-roll the randoms
		randX_offset = RandomIntRange( offsetMinX, offsetMaxX );
		randY_offset = RandomIntRange( offsetMinY, offsetMaxY );
		randZ_offset = RandomIntRange( offsetMinZ, offsetMaxZ );

		// Randomize left/right Y offset
		if( cointoss() )
		{
			randY_offset *= -1;
		}

		// Move the target entity to the random position
		fake_player_turret_target.origin =  (self.origin + (randX_offset,randY_offset,randZ_offset));
		wait 1;
	}
	level.breach_rover.mgturret[0] SetMode( "manual" );
	level.breach_rover.mgturret[0] TurretFireDisable();
	fake_player_turret_target delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
armory_enter_vignette()
{
	spider_spawner = GetEnt( "spider_spawner", "targetname" );
	level.spider = spider_spawner spawn_ai();
	level.spider.animname = "spider";
	level.spider SetLookAtEntity( level._player );
	enter_ally_01 = GetEnt( "armory_enter_ally_01", "targetname" );
	enter_ally_02 = GetEnt( "armory_enter_ally_02", "targetname" );
	helmet_ally_01 = GetEnt( "armory_helmet_ally_01", "targetname" );

	//enter_ally_01 anim_first_frame_solo( level.eagle , "armory_enter" );
	//enter_ally_02 anim_first_frame_solo( level.spider , "armory_enter" );

	flag_wait( "vignette_armory_enter" );

	thread maps\_ambient::start_ambient_event( "nx_lunar_armory" );
	
	// flag_wait ("vignette_armory_entrance_player");	

	// Have spider move to breach position
	armory_ready_breach_spider();

	// Wait for player to pick up helmet
	armory_give_helmet();

	// Have falcon teleport to breach position
	// enter_ally_02 notify( "stop_enter" );
	// level thread armory_ready_breach_falcon();



	// Stop any running depressurization room status scripts
	level notify( "stop_depressurization" );

	flag_wait ("ready_for_armory_breach");

	thread armory_kill_zone_warning_vo();

	// Enemy breach
	thread enemy_armory_breach();

	//DR: start music
	flag_set( "music_breach_starting" );

	// tagTC<note> - Manual wait to better time the transition to the explosion
	// KenM - Adjusting timing, eventually the animation should start at the moment the explosion occurs.
	// flag_wait( "vignette_armory_breach" );	
	wait( 14.0 );

	armory_breach = GetEnt( "vignette_armory_breach", "script_noteworthy" );
	armory_breach notify ("stop_idle");

	level._player AllowSprint( true );

	//DR: start music
	flag_set( "music_start_battle_out_of_armory" );
}

armory_kill_zone_warning_vo()
{
	armory_breach = GetEnt( "vignette_armory_breach", "script_noteworthy" );
	armory_breach endon ("stop_idle");
	flag_wait ("armory_breach_kill_zone");

	// Crow: Stay away from the door!
	radio_dialogue ( "moon_eag_int_stayawaydoor" );
}

armory_ready_breach_spider()
{
	level waittill ("player_in_armory");
	node = getent("vignette_armory_breach_entrance", "script_noteworthy");
	node notify ("stop_idle");
	level.spider notify ("stop_idle");
	level.spider StopAnimScripted();
	armory_breach = GetEnt( "vignette_armory_breach", "script_noteworthy" );
	armory_breach anim_reach_and_approach_solo ( level.spider, "armory_breach_explosion" );
	armory_breach thread anim_loop_solo ( level.spider, "armory_breach_loop", "stop_idle" );
}

armory_ready_breach_falcon()
{
	// level waittill ("armory_helmet_on");

	// So the player's view is out of the way 
	// wait 2;

	// From this point on, falcon_taser is the real Falcon. If the player starts from armory_module, real Falcon is the real Falcon.
	level.falcon = level.falcon_taser;

	// Make sure he doesn't try to play his backing-up to the armory animation
	// level.falcon StopAnimScripted();
	// level.falcon ClearAnim( level._scr_anim[ "falcon" ][ "armory_entrance_falcon" ], 0);

	// Get him to his breach ready position and loop him
	armory_breach = GetEnt( "vignette_armory_breach", "script_noteworthy" );
	armory_breach anim_teleport_solo( level.falcon, "armory_breach_explosion" );
	armory_breach anim_loop_solo ( level.falcon, "armory_breach_loop", "stop_idle" );

	// Turn his color behavior on
	level.falcon enable_ai_color();
	level.falcon set_force_color( "r" );
}

armory_ready_breach_eagle()
{
	armory_breach = GetEnt( "vignette_armory_breach", "script_noteworthy" );
	// tagTC<note> - temp removing breach, currently he's not reaching for some reason
	//armory_breach anim_reach_and_approach_solo ( level.eagle, "armory_breach_explosion" );
	armory_breach anim_loop_solo ( level.eagle, "armory_breach_loop", "stop_idle" );
	level.eagle enable_ai_color();
}

armory_give_helmet()
{
	// Return regular player abilities
	level._player EnableUsability();
	setSavedDvar( "player_sprintSpeedScale", 1.5 );

	// triggered via anim script
	level waittill ("armory_helmet_on");
	maps\nx_lunar_util::lunar_combat_init( false ); // false means do not give the helmet.  The vignette will take care of that with the correct timing.
	level._player store_players_weapons( "armory_weapons" );
	level._player TakeAllWeapons();

	level thread armory_helmet_loop_sfx();

	//set the sfx helmet state to the correct state
	flag_set( "sfx_int_base_milsuit_press" );  //(after putting on military suit - this one has the laser mic)

	thread maps\nx_lunar_util::lunar_helmet_bootup_sequence();

	// If Falcon isn't at his spot already, put him there.
	level thread armory_ready_breach_falcon();

	wait( 1.0 );

	// Clear objective
	flag_set( "player_has_helmet" );

	// Close the armory door
	level thread maps\nx_lunar_util::close_lunar_door( "armory_door", 1.0 );

	wait 2;

	// Distant breach effects
	level._player playsound("lunar_explosions_storage_room");
	Earthquake( 0.3, 1, level._player.origin, 100 );
	level._player PlayRumbleOnEntity( "damage_light" );

	// Allow player to get the assault rifle
	thread armory_give_weapon();

	// Move eagle to breach position
	thread armory_ready_breach_eagle();
	wait 1;

	// Shit. They've breached the storage room.
	radio_dialogue( "moon_fal_toarm_storeroom" );
	level thread maps\nx_lunar_util::lunar_door_status( "armory_door", "status_red" );

}

armory_helmet_loop_sfx()
{
	soundent = spawn( "sound_emitter", level._player.origin );
	soundent linkto( level._player );
	soundent playloopsound("scn_lunar_armory_plr_helmet_loop");
		
	flag_wait( "vignette_armory_breach" );
	soundent StopLoopSound( "scn_lunar_armory_plr_helmet_loop" );
	soundent delete();
}

armory_alert_vo_01_sfx()
{
	soundent1 = spawn("sound_emitter", (8662, -273, -1623));
	soundent1 playsound("scn_lunar_armory_alert_vo_01");
		
	flag_wait( "ready_for_armory_breach" );
	soundent1 delete();
}

armory_alert_vo_02_sfx()
{	
	soundent2 = spawn("sound_emitter", (8662, -273, -1624));
	soundent2 playsound("scn_lunar_armory_alert_vo_02");
		
	wait 65.0;
	soundent2 delete();
}

armory_give_weapon()
{
		
	// Wait for player to pick up a rifle
	lunar_rifle = GetEnt ("lunar_rifle", "targetname");

	lunar_rifle MakeUsable();

	// Press and hold X to take Retrofitted Lunar Assault Rifle
	lunar_rifle SetHintString( &"NX_LUNAR_ARMORY_GIVE_WEAPON_HINT" );
	lunar_rifle waittill( "trigger" );
	
	level._player playsound("suit_inject_patchkit_pickup_press");

	thread armory_alert_vo_01_sfx();	

	//Play vignette
	maps\nx_lunar_anim::armory_entrance_grabrifle( lunar_rifle );
	
	// tagTC<note>: give the player's their loadout in _loadout
	// give the player their suit shield
	level._player restore_players_weapons( "armory_weapons" );
	level._player switchToWeapon( level._main_gun );
	wait .5;
	level._player EnableWeapons();

	// Clear objective
	flag_set( "player_has_weapon" );

	thread armory_patch_check();

	level._player waittill ("suit_repaired");

	flag_set ("ready_for_armory_breach");	
}

armory_door_breach_metal_stress_sfx()
{
	wait 0.4;
	level._player setchannelvolumes( "snd_channelvolprio_pain", "nx_lunar_armory_breach", 0.4 );
	thread armory_alert_vo_02_sfx();	
	level._player playsound("scn_lunar_breach_mtl_stress_1");
	
	wait 5.3;

	level._player playsound("scn_lunar_breach_mtl_stress_2");
	wait 3.0;
	level._player deactivatechannelvolumes( "snd_channelvolprio_pain", 1.0 );
}

enemy_armory_breach()
{
	// OPFOR_01 Spawn
	opfor_01 = enemy_armory_breach_spawn( "enemy_breach_opfor_01", "opfor_01" );
	opfor_01 forceUseWeapon( "breacher", "primary" );
 
	// OPFOR_02 Spawn
	opfor_02 = enemy_armory_breach_spawn( "enemy_breach_opfor_02", "opfor_02" );

	// Do breach
	level thread enemy_door_breach( "armory_door_breach", opfor_01, opfor_02 );

	// Wait for detonate
	opfor_01 waittill ("charge_inserted");
	
	level thread armory_door_breach_metal_stress_sfx();

	level thread maps\nx_lunar_util::lunar_door_status( "armory_door", "status_yellow" );
	opfor_01 waittill("charged");	
	opfor_01 notify("detonate");
	opfor_01 forceUseWeapon( "lunarrifle", "primary" );
	opfor_01.ignoreall = false;
	opfor_02.ignoreall = false;

	wait .5;
	level thread maps\nx_lunar_util::lunar_door_status( "armory_door", "status_green" );
	level thread maps\nx_lunar_util::lunar_door_keypad_error( "armory_door" );
}

enemy_armory_breach_spawn( spawner_name, animname )
{
	spawner = GetEnt( spawner_name, "targetname" );
	spawner thread add_spawn_function( ::enemy_armory_breach_spawn_func );
	enemy = spawner spawn_ai();

	enemy.animname = animname;
	enemy.ignoreall = true;
	enemy.allowdeath = true;
	enemy thread maps\nx_lunar_util::check_retreat_triggers();

	return enemy;
}

enemy_armory_breach_spawn_func()
{
	self thread maps\nx_lunar_util::lunar_enemy_interior_common();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

get_to_the_armory_dialog()
{
	wait 5;
	// Base: All personnel fall back to the base!
	// Base: Repeat, fall back to the base! Secure the LSP control center!
	//radio_dialogue ( "moon_bc_rov_11" );
	
	flag_wait( "start_stumble_walk" );

	// Open first airlock door
	level thread maps\nx_lunar_util::open_lunar_door( "vehicle_airlock_breach_01", 1 );
	
	// Base: We see you!  We're cycling the nearest airlock. Get in here now!
	// radio_dialogue ( "moon_bc_rov_12" );

	flag_wait( "vo_base_compromise_bc" );

	// Base Commander: Security alert. We have been compromised. Perimeter has been breached. Seal and secure all airlocks.
	radio_dialogue( "moon_bc_arm_01" );

	wait 3;
        //muting channels before big vignette on second floor
        level._player setchannelvolumes( "snd_channelvolprio_pain", "nx_lunar_2nd_floor_first_stop", 0.4 );
	// Crow: Walker, this is Crow.  We're at the armory.  Get your ass over here, now!	
	radio_dialogue( "moon_eag_arm_01" );

	// Message repeats
	// Base Commander: Security alert. We have been compromised. Perimeter has been breached. Seal and secure all airlocks.
	radio_dialogue( "moon_bc_arm_01" );

	// flag_wait ("top_floor_breach");

	// Base Commander: Security alert. We have been compromised. Perimeter has been argh!
        //JL: Removing this for now. We'll put it back in when audio does a pass on the vignette audio. DT4383
	//radio_dialogue( "moon_bc_arm_02" );
	
	flag_wait( "command_center_civ_flee" );
	
	// Crow: Walker, Riggs is on his way to meet up with you.
	radio_dialogue( "moon_eag_arm_02" );

	flag_wait ("falcon_in_storage");

	// Riggs: Armory's just ahead.
	radio_dialogue( "moon_fal_toarm_07" );

	wait 2;

	flag_wait ( "vo_armory_down_here" );

	// Spider: Down here!
	radio_dialogue( "moon_spid_int_downhere" );

	flag_wait( "vo_armory_enter" );

	//DR: stop the chase music
	flag_set( "music_player_at_the_armory" );

	// Spider: Welcome to what's left of the Combat Group, go grab a helmet.
	radio_dialogue( "moon_spid_int_welcome" );

	flag_wait ("ready_for_armory_breach");

	wait 2;

	// Crow: Ok, they're breaching! Hold on to something and be ready to engage. 	
	radio_dialogue( "moon_eag_int_08" );

	// Crow: Once the door's open, get out as fast as you can. We're sitting ducks in here.
	//JL: Removing for DT5065
	//radio_dialogue( "moon_eag_int_sittingducks" );
}

armory_patch_check()
{
	level._player endon ("suit_repaired");

	// Ensure they have no patch kits to begin with
	level._player SetWeaponAmmoClip( "nx_suitshield", 0);

	flag_wait( "player_has_weapon" );

	// Wait until they retrieve the rifle and patch kit
	level._player GiveStartAmmo( "nx_suitshield"  );
	self thread maps\_utility::display_hint( "patch" );	

	// Crow: Patch your suit, Walker, we need you 100%... Riggs, load up. 
	radio_dialogue( "moon_eag_int_03" );

	// Remind them if they haven't patched after this time
	wait 10;

	// Player waited too long, off we go
	flag_set ("ready_for_armory_breach");

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


