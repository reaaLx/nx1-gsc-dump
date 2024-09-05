//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  MISSION DESCRIPTION											**
//                                                                          **
//    Created: DATE - CREATOR												**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main()
{
	// TEST HELI RIDE
	// This is temp for concept geo scale testing
	precachemodel( "tag_turret" );

	// Load the vehicle ride
	//maps\_blackhawk::main( "vehicle_blackhawk" );
	maps\_minigun::main();
	maps\_c4::main();
	maps\_attack_heli::preLoad();
	//maps\_btr80::main( "vehicle_btr80" );

	// Add start points
	default_start(::intro_start );
	add_start( "intro",					::intro_start,				"Intro",				::intro );
	add_start( "base_alpha",			::base_alpha_start,			"Base Alpha",			::base_alpha );
	add_start( "bridge",				::bridge_start,				"Bridge",				::bridge );
	add_start( "base_delta",			::base_delta_start,			"Base Delta",			::base_delta );
	add_start( "crash",					::crash_start,				"Crash",				::crash );
	add_start( "hanging",				::hanging_start,			"Hanging",				::hanging );

	// NX_ROCKET_GREENLIGHT: Removing unnecessary sections
//  add_start( "base_echo",				::base_echo_start,			"Base Echo",			::base_echo );
//  add_start( "turret_base",			::turret_base_start,		"Turret Base",			::turret_base );
//  add_start( "turret_control",		::turret_control_start,		"Turret Control",		::turret_control );
//  add_start( "rescue",				::rescue_start,				"Rescue",				::rescue );
//  add_start( "littlebird",			::littlebird_start,			"Littlebird",			::littlebird );
//  add_start( "gantry",				::gantry_start,				"Gantry",				::gantry );
//  add_start( "escape",				::escape_start,				"Escape",				::escape );
//
//  add_start( "debug_turret_escape",	::debug_turret_escape_start,"Turret Escape (DEBUG ONLY)",		::debug_turret_escape );	// DEBUG ONLY
//  add_start( "no_game_gantry",		::no_game_gantry_start,		"Gantry (NO GAME, DEBUG ONLY)",		::no_game_gantry );			// DEBUG ONLY

	add_start( "no_game_base_alpha",	::no_game_base_alpha_start,	"Base Alpha (NO GAME, DEBUG ONLY)",	::no_game_base_alpha );		// DEBUG ONLY
	add_start( "no_game_base_delta",	::no_game_base_delta_start,	"Base Delta (NO GAME, DEBUG ONLY)",	::no_game_base_delta );		// DEBUG ONLY

	// External Initialization
	maps\nx_rocket_precache::main();
	maps\nx_rocket_fx::main();
	maps\_drone_ai::init();
	huds = [];
	huds[huds.size] = "hud_railgun";
	huds[huds.size] = "hud_chute";
	maps\_load::main( huds );
	maps\nx_rocket_amb::main();
	maps\nx_rocket_anim::main();

	// tagBK<NOTE> This is a test for the lookat vtol tool. I am leaving this in because the 
	// situation in Rocket is unique and needs a local test. 
//	level._player thread test_look_at_camera();

	// Internal Initialization
	mission_flag_inits();
	mission_precache();

	//set timescale factors
	SoundSetTimeScaleFactor( "Music", 0 );

	// Mission threads
	level thread maps\nx_rocket_audio::mission_music();
	thread mission_objective_logic();

	maps\nx_rocket_fx::fx_vision_fog_init();

	// Setup entity cleanup triggers for the whole level
	// This can stay here
	array_thread( GetEntArray( "trigger_cleanup", "targetname" ), ::trigger_cleanup );
	
	// Dan: Spawning threads on triggers which control the player's transition between cinmatic and gameplay camera behavior while on the helicopter.
	array_thread( GetEntArray( "trigger_use_cinematic_turret_camera", "script_noteworthy" ), maps\nx_rocket_util::lerp_link_view_fraction_cinematic_trigger );
	array_thread( GetEntArray( "trigger_use_gameplay_turret_camera", "script_noteworthy" ), maps\nx_rocket_util::lerp_link_view_fraction_gameplay_trigger );

	mission_objectives();
	mission_squad();

	setup_target_vehicles();

	//so the drones use valid sounds
	level._drone_weaponsound[ "axis" ] = [ "weap_asmk27_fire_npc" , "weap_asmk27_fire_npc", "weap_asmk27_fire_npc" ];
}

// All mission specific PreCache calls
mission_precache()
{
	maps\nx_rocket_section_intro::section_precache();
	maps\nx_rocket_section_base_alpha::section_precache();
	maps\nx_rocket_section_bridge::section_precache();
	maps\nx_rocket_section_base_delta::section_precache();
	maps\nx_rocket_section_crash::section_precache();
	maps\nx_rocket_section_hanging::section_precache();

	// NX_ROCKET_GREENLIGHT: Removing unnecessary sections
//  maps\nx_rocket_section_base_echo::section_precache();
//  maps\nx_rocket_section_turret_base::section_precache();
//  maps\nx_rocket_section_turret_control::section_precache();
//  maps\nx_rocket_section_rescue::section_precache();
//  maps\nx_rocket_section_littlebird::section_precache();
//  maps\nx_rocket_section_gantry::section_precache();
//  maps\nx_rocket_section_escape::section_precache();

// UNKNOWN ASSETS - Please claim and move to correct section_precache
	precachemodel( "me_electricbox4_door" );
	precachemodel( "me_electricbox4_dest" );
}


// All mission specific flag_init() calls
mission_flag_inits()
{
	maps\nx_rocket_section_intro::section_flag_inits();
	maps\nx_rocket_section_base_alpha::section_flag_inits();
	maps\nx_rocket_section_bridge::section_flag_inits();
	maps\nx_rocket_section_base_delta::section_flag_inits();
	maps\nx_rocket_section_crash::section_flag_inits();
	maps\nx_rocket_section_hanging::section_flag_inits();
	// NX_ROCKET_GREENLIGHT: Removing unnecessary sections
//  maps\nx_rocket_section_base_echo::section_flag_inits();
//  maps\nx_rocket_section_turret_base::section_flag_inits();
//  maps\nx_rocket_section_turret_control::section_flag_inits();
//  maps\nx_rocket_section_rescue::section_flag_inits();
//  maps\nx_rocket_section_littlebird::section_flag_inits();
//  maps\nx_rocket_section_gantry::section_flag_inits();
//  maps\nx_rocket_section_escape::section_flag_inits();

	// AUDIO: Example music flag inits
	maps\nx_rocket_audio::flag_inits();

	// dvar needed to enable railgun visor anim
	SetSavedDvar( "railgun_HUD_motion_enable", true );
}

//*******************************************************************
//  SQUAD                                                           *
//                                                                  *
//*******************************************************************
mission_squad()
{
	level.squad = [];
	level.squad[ "ALLY_BAKER" ]		= maps\nx_rocket_util::squad_ally( "ally_00", "ally_baker", "g" );
	level.squad[ "ALLY_JENKINS" ]	= maps\nx_rocket_util::squad_ally( "ally_01", "ally_jenkins", "b");
	level.squad[ "ALLY_WILLIAMS" ]	= maps\nx_rocket_util::squad_ally( "ally_02", "ally_williams", "p" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************



//*******************************************************************
//	INTRO															*
//*******************************************************************
intro_start()
{
	// First section of the mission
	maps\nx_rocket_section_intro::start();
}

intro()
{
	//temp music_chk flag
	flag_set( "music_chk_intro" );

	// Turn off AA turret section smoke
	maps\nx_rocket_util::pre_turret_event();

	maps\nx_rocket_section_intro::main();
}


//*******************************************************************
//	Base Alpha - First rocket areas									*
//*******************************************************************
base_alpha_start()
{
	// Turn off AA turret section smoke
	maps\nx_rocket_util::pre_turret_event();

	maps\nx_rocket_section_base_alpha::start();
}

base_alpha()
{
	//temp music_chk flag
	flag_set( "music_chk_base_alpha" );
	maps\nx_rocket_section_base_alpha::main();
}

//*******************************************************************
//	Bridge - Valley ride between rockets sections					*
//*******************************************************************
bridge_start()
{
	// Turn off AA turret section smoke
	maps\nx_rocket_util::pre_turret_event();

	maps\nx_rocket_section_bridge::start();
}

bridge()
{		
	maps\nx_rocket_section_bridge::main();
}


//*******************************************************************
//	Base Delta - Set of 3 rockets									*
//*******************************************************************
base_delta_start()
{
	// Turn off AA turret section smoke
	maps\nx_rocket_util::pre_turret_event();

	maps\nx_rocket_section_base_delta::start();
}

base_delta()
{
	//temp music_chk flag
	flag_set( "music_chk_base_delta" );
	maps\nx_rocket_section_base_delta::main();	
}


//*******************************************************************
//	NUKE & CRASH													*
//*******************************************************************
crash_start()
{
	// Turn off AA turret section smoke
	maps\nx_rocket_util::pre_turret_event();

	maps\nx_rocket_section_crash::start();
}

crash()
{	
	maps\nx_rocket_section_crash::main();
}

//*******************************************************************
//	HANGING															*
//*******************************************************************
hanging_start()
{
	maps\nx_rocket_section_hanging::start();
}

hanging()
{
	//temp music_chk flag
	flag_set( "music_chk_hanging" );
	maps\nx_rocket_section_hanging::main();
}


//*******************************************************************
//	CRASH SITE														*
//*******************************************************************
base_echo_start()
{
	maps\nx_rocket_section_base_echo::start();
}

base_echo()
{
	//temp music_chk flag
	flag_set( "music_chk_base_echo" );
	maps\nx_rocket_section_base_echo::main();
}


//*******************************************************************
//	TURRET BASE - Base interior										*
//*******************************************************************
turret_base_start()
{
	maps\nx_rocket_section_turret_base::start();
}

turret_base()
{
	//temp music_chk flag
	flag_set( "music_chk_turret_base" );
	maps\nx_rocket_section_turret_base::main();
}


//*******************************************************************
//	TURRET CONTROL													*
//*******************************************************************
turret_control_start()
{
	maps\nx_rocket_section_turret_control::start();
}

turret_control()
{
	//temp music_chk flag
	flag_set( "music_chk_turret_control" );
	maps\nx_rocket_section_turret_control::main();

	// Turn on post AA turret smoke and destruction
	maps\nx_rocket_util::post_turret_event();

}

//*******************************************************************
//	TURRET ESCAPE (Debug Only)										*
//*******************************************************************
debug_turret_escape_start()
{
	// Comment this back in IF you need it.
	// But dont check it in
	//maps\nx_rocket_section_turret_control::start();
}

debug_turret_escape()
{
	// Comment this back in IF you need it.
	// But dont check it in
	//maps\nx_rocket_section_turret_control::debug_turret_escape();
}

//*******************************************************************
//	RESCUE															*
//*******************************************************************
rescue_start()
{
	maps\nx_rocket_section_rescue::start();
}

rescue()
{
	//temp music_chk flag
	flag_set( "music_chk_rescue" );
	// Nothing yet
	maps\nx_rocket_section_rescue::main();
}


//*******************************************************************
//	LITTLEBIRD RIDE													*
//*******************************************************************
littlebird_start()
{					 
	// Turn on post AA turret smoke and destruction
	maps\nx_rocket_util::post_turret_event();

	maps\nx_rocket_section_littlebird::start();
}

littlebird()
{
	//temp music_chk flag
	flag_set( "music_chk_littlebird" );
	maps\nx_rocket_section_littlebird::main();
}


//*******************************************************************
//	GANTRY ATTACK													*
//*******************************************************************
gantry_start()
{
	// Turn on post AA turret smoke and destruction
	maps\nx_rocket_util::post_turret_event();

	maps\nx_rocket_section_gantry::start();
}

gantry()
{
	//temp music_chk flag
	flag_set( "music_chk_gantry" );
	maps\nx_rocket_section_gantry::main();
}


//*******************************************************************
//	GANTRY ESCAPE   												*
//*******************************************************************
escape_start()
{
	// Turn on post AA turret smoke and destruction
	maps\nx_rocket_util::post_turret_event();

	maps\nx_rocket_section_escape::start();
}

escape()
{	
	maps\nx_rocket_section_escape::main();
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// JR TODO - This should be moved to util
// Used to cleanup actors in a volume
// This should probably be a global util func
trigger_cleanup()
{
	assert( isdefined( self.target ) );
	areas = getentarray( self.target, "targetname" );
	assert( areas.size > 0 );
	
	self waittill( "trigger" );
	
	foreach( area in areas )
	{
		array_thread( area get_ai_touching_volume( "axis" ), ::delete_ai_not_bullet_shielded );
		array_thread( area get_ai_touching_volume( "allies" ), ::delete_ai_not_bullet_shielded );
	}
}

// Used all over - should be made a global util func
delete_ai_not_bullet_shielded()
{
	if ( isdefined( self.magic_bullet_shield ) )
		return;
	self delete();
}


//*******************************************************************
//																	*
//		OBJECTIVES													*
//																	*
//*******************************************************************
// Creates reference strings for all the mission objectives
// These are stored in level._obj_array
mission_objectives()
{
	obj( "OBJ_DESTROY_BASE_ALPHA" );
	obj( "OBJ_DESTROY_BASE_DELTA" );
	obj( "OBJ_DESTROY_LAUNCHING_ROCKETS" );
//  obj( "OBJ_RESCUE_JENKINS" );
	obj( "OBJ_FIND_BAKER" );
	obj( "OBJ_THROUGH_AA_BASE" );
	obj( "OBJ_DESTROY_ROCKETS_AA" );
	obj( "OBJ_ESCAPE_AA_BASE" );
	obj( "OBJ_DESTROY_FINAL_ROCKET" );
}


// Setup the objectives based on current start point
mission_objective_logic()
{
	waittillframeend; // Wait for friendlies to spawn

	switch ( level._start_point )
	{
		case "default":
		case "intro":
			// "Destroy launch site Alpha"
			Objective_Add( obj( "OBJ_DESTROY_BASE_ALPHA" ), "active", &"NX_ROCKET_OBJ_BASE_ALPHA" );

			// "Destroy launch site Delta"
			Objective_Add( obj( "OBJ_DESTROY_BASE_DELTA" ), "active", &"NX_ROCKET_OBJ_BASE_DELTA" );

			// "Destroy launch site November"
			Objective_Add( obj( "OBJ_DESTROY_LAUNCHING_ROCKETS" ), "active", &"NX_ROCKET_OBJ_LAUNCHING_ROCKETS" );

		case "base_alpha":
			flag_wait( "rocket_1_destroyed" );
			objective_complete( obj( "OBJ_DESTROY_BASE_ALPHA" ));

		case "bridge":
		case "base_delta":
			flag_wait( "base_delta_destroyed" );
			objective_complete( obj( "OBJ_DESTROY_BASE_DELTA" ));

		case "crash":
		case "hanging":
			flag_wait( "interrogation_started" );
//  		Objective_Add( obj( "OBJ_RESCUE_JENKINS" ), "active", &"NX_ROCKET_OBJ_RESCUE_JENKINS" );
//  		flag_wait( "jenkins_rescued" );
//  		objective_complete( obj( "OBJ_RESCUE_JENKINS" ));

	// NX_ROCKET_GREENLIGHT: Removing unnecessary sections
/*		case "base_echo":
			flag_wait( "regrouped_with_squad" );			
			// "Search for Baker"
			Objective_Add( obj( "OBJ_FIND_BAKER" ), "active", &"NX_ROCKET_OBJ_FIND_BAKER" );
		case "turret_base":
			flag_wait( "discovered_aa_base" );
			// "Find a way through the AA base"
			Objective_Add( obj( "OBJ_THROUGH_AA_BASE" ), "active", &"NX_ROCKET_OBJ_AA_BASE" );
		case "turret_control":
			//flag_wait( "done_with_AA_controls" )
			flag_wait( "discovered_turret_control" );
			flag_wait( "turret_control_controls_entered" );
//  		Objective_Add( obj( "OBJ_DESTROY_ROCKETS_AA" ), "active", &"NX_ROCKET_OBJ_AA_BASE" );

			flag_wait( "turret_control_turret_ready" );
			objective_complete( obj( "OBJ_THROUGH_AA_BASE" ));

			flag_wait( "turret_control_complete" );
			Objective_Add( obj( "OBJ_ESCAPE_AA_BASE" ), "active", &"NX_ROCKET_OBJ_AA_BASE" );

			flag_wait( "vignette_aa_control_exit" );
			objective_complete( obj( "OBJ_ESCAPE_AA_BASE" ));
//  		objective_complete( obj( "OBJ_DESTROY_ROCKETS_AA" ));
				
		case "rescue":
			flag_wait( "turret_destroyed" );
			// "Escape the AA base"
			objective_complete( obj( "OBJ_DESTROY_LAUNCHING_ROCKETS" ));

			flag_wait( "rescue_chopper_allies_loaded" );
			objective_complete( obj( "OBJ_FIND_BAKER" ));

		case "littlebird":
			flag_wait( "baker_updates_final_rocket" );
			wait 1.0;

		case "gantry":
		case "escape":
			// "Destroy launch site Omega"
			Objective_Add( obj( "OBJ_DESTROY_FINAL_ROCKET" ), "current", &"NX_ROCKET_OBJ_FINAL_ROCKET" );

			flag_wait( "final_rocket_destroyed" );
			objective_complete( obj( "OBJ_DESTROY_FINAL_ROCKET" ));
*/
	}
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************

setup_target_vehicles()
{
	if ( !IsDefined( level._vehicle_apply_target_list ))
	{
		level._vehicle_apply_target_list = [];
	}
	if ( !IsDefined( level._vehicle_apply_target_offset_list ))
	{
		level._vehicle_apply_target_offset_list = [];
	}

	level._vehicle_apply_target_list[ level._vehicle_apply_target_list.size ] = "vehicle_btr80";
	level._vehicle_apply_target_list[ level._vehicle_apply_target_list.size ] = "vehicle_little_bird_armed";
	level._vehicle_apply_target_list[ level._vehicle_apply_target_list.size ] = "nx_vehicle_chinese_vtol";
	level._vehicle_apply_target_list[ level._vehicle_apply_target_list.size ] = "vehicle_slamraam";

	level._vehicle_apply_target_offset_list[ level._vehicle_apply_target_offset_list.size ] = ( 0, 0, 80 );
	level._vehicle_apply_target_offset_list[ level._vehicle_apply_target_offset_list.size ] = ( 0, 0, -55 );
	level._vehicle_apply_target_offset_list[ level._vehicle_apply_target_offset_list.size ] = ( 0, 0, 0 );
	level._vehicle_apply_target_offset_list[ level._vehicle_apply_target_offset_list.size ] = ( 0, 0, 80 );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

test_look_at_camera()
{
	self NotifyOnPlayerCommand( "GoCam", "+usereload" );
	while( 1 )
	{
		self waittill( "GoCam" );
		angles = self GetPlayerViewAngles();
		forward = anglestoforward( angles ) * -1000.0;
		target = self.origin + forward;
		self TurnToFaceTarget( target, 3.0, 1.0 );
		wait( 0.01 );
	}
}

//*******************************************************************
//	DEBUG JUMP TOs  												*
//*******************************************************************

// DEBUG JUMP TO BASE ALPHA.
no_game_base_alpha_start()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_base_alpha" );
}

no_game_base_alpha()
{
	// NOTHING.
}

// DEBUG JUMP TO BASE DELTA.
no_game_base_delta_start()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_base_delta" );
}

no_game_base_delta()
{
	// NOTHING.
}

// DEBUG JUMP TO GANTRY.
no_game_gantry_start()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_gantry" );
}

no_game_gantry()
{
	// NOTHING.
}