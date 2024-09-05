//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Hit Hard at Home  											**
//                                                                          **
//    Created: 10/4/2010 - Brian Marvin										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;			  
#include maps\_vehicle;
#include maps\_nx_utility;
#include maps\nx_hithard_util;

//*******************************************************************
//					                                              	*
//*******************************************************************

main()
{
	// Inits
	maps\nx_hithard_fx::main();	
	maps\nx_hithard_precache::main();
	maps\_threatid::main();
	// maps\createart\nx_hithard_art::main();	
													   
	// Parachute
	maps\_chute::main();

	// Vehicles	
	//maps\_luxurysedan::main( "vehicle_luxurysedan" );
	//maps\_suburban::main( "vehicle_suburban" );	
	//maps\_truck::main( "vehicle_pickup_4door" );		

	// Setup cevilians
	maps\_drone_civilian::init();
	maps\nx_crowd_controller::main();
	
	// Player Starts
	//		NOTE: This mission's objetcives are split across multiple scripts:
	//			1) nx_hithard.gsc - Main script file (this file).  contains player starts and references to objective script files.
	//			2) nx_hithard_parachute.gsc - Osprey intro, parachute, 
	//			3) nx_hithard_rooftop.gsc - Library parking lot through rooftop
	//			4) nx_hithard_secure.gsc - secure the motorcade objectives
	//			5) nx_hithard_motorcade.gsc - Motorcade travel to ambush outside city hall
	//			6) nx_hithard_charge.gsc - Traversal through city hall up to tank drop
 
	default_start( ::playerstart_osprey );
	add_start( "osprey", ::playerstart_osprey, "Osprey Intro", maps\nx_hithard_parachute::main_osprey );
	add_start( "parachute", ::playerstart_parachute_jump, "Parachute", maps\nx_hithard_parachute::main_parachute_jump );

	// JR - Temp start for debugging skybridge explosion
	//add_start( "skybridge_debug", maps\nx_hithard_parachute::playerstart_skybridge_debug, "Skybridge Debug", maps\nx_hithard_parachute::skybridge_debug );

	add_start( "rooftop", ::playerstart_rooftop, "Rooftop", maps\nx_hithard_rooftop::main_rooftop );
	add_start( "secure_start", ::playerstart_secure, "Secure The Motorcade: Snipe", maps\nx_hithard_secure::main_secure );	
	add_start( "secure_rappel", ::playerstart_secure_rappel, "Secure The Motorcade: Rappel", maps\nx_hithard_secure::main_rappel );	
	add_start( "secure_ground", ::playerstart_secure_ground, "Secure The Motorcade: Ground", maps\nx_hithard_secure::main_secure_ground );	
	add_start( "motorcade_start", ::playerstart_motorcade, "Motorcade Drive", maps\nx_hithard_motorcade::main );
	add_start( "motorcade_end", maps\nx_hithard_motorcade::motorcade_end, "Motorcade End - Debug!!!" );

	// Main load / introscreen		
	huds = [];
	huds[huds.size] = "hud_chute";
	maps\_load::main( huds );
	maps\nx_hithard_anim::main();
	thread maps\nx_hithard_amb::main();
	maps\_compass::setupMiniMap( "compass_map_nx_hithard" );
	PreCacheRumble( "artillery_rumble" );	

	// Internal Initialization
	mission_precache();
	mission_flag_inits();
	mission_hint_string_inits();

	//set timescale factors
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

	// Objective Array
	level.objective = [];

	// Current Objective
	level.current_objective = "none";

	// Squad setup	
 	level.squad = spawn_squad();

	// Setup Threatbias groups
	setup_threatbias_groups();

	// Setup cleanup triggers
	array_thread( getentarray( "trigger_delete_parachute_all_ai", "targetname" ), maps\nx_hithard_util::delete_ai_volume_trigger_wait );
	
	// Grab all entities on spawn (for debug purposes)
	level.ai_at_start = getaiarray();
	
	// hide the landing zone
	maps\nx_hithard_fx::hide_lz();

	// Mission threads		
	//thread the music script
	level thread maps\nx_hithard_audio::mission_music();	

	thread maps\nx_hithard_anim::building_2_fall(); // Building 2
	thread maps\nx_hithard_anim::building_4_fall(); // Building 4
//  thread maps\nx_hithard_anim::hanging(); // Hanging Civs
	//fx triggering and cleanup
	thread maps\nx_hithard_anim::trigger_building03_04_fx_cleanup_building01(); // Building 5

	thread maps\nx_hithard_fx::sequence_vision_and_fog_parachute_land(); /// parachute landing vision & fog  

	// init the parachute lz icon
	thread maps\nx_hithard_parachute::parachute_lz_init();

	// init rappel
	maps\_rappel_util::rappel_setup(); 	
}


//***************************************************************************************************************************************************************
//                                                                  																							*
// 	INITIALIZATIONS		                                               																							*
//                                                                  																							*
//***************************************************************************************************************************************************************

// All PreCache calls
mission_precache()
{
	//Global	
	// chad note- adding test of motorized zoom scope weapon
	PreCacheItem( "xm108_asco" );	// Main Weapon	
	//precacheturret( "turret_minigun_sp" );	// Turrent - For Motorcade	
	precacheshader( "cinematic" );
	precacheshader( "cinematic_trans" );
	precacheshader( "chute_landing_marker" );
	precacheshader( "hint_mantle" );
	PrecacheItem( "smoke_grenade_american" );
	PreCacheItem( "rpg_straight" );

	maps\_mi17::main( "vehicle_mi17_woodland_fly_cheap" );
	PreCacheRumble( "c130_flyby" );	
	
	PreCacheString( &"NX_HITHARD_RAPPEL_HINT" );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// All mission specific flag_init() calls
mission_flag_inits()
{	
	flag_init( "flag_global_ltrig_pressed" );

	// Objective-specific flag initializations
	maps\nx_hithard_parachute::flag_inits();
	maps\nx_hithard_rooftop::flag_inits();
	maps\nx_hithard_secure::flag_inits();
	maps\nx_hithard_motorcade::flag_inits();	
	maps\nx_hithard_audio::flag_inits();	
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Initialize hints
mission_hint_string_inits()
{
	// Objective-specific hint-string initializations
	maps\nx_hithard_parachute::hint_string_inits();
	maps\nx_hithard_rooftop::hint_string_inits();
	maps\nx_hithard_secure::hint_string_inits();
	maps\nx_hithard_motorcade::hint_string_inits();	
}																		   

//***************************************************************************************************************************************************************
//                                                                  																							*
// 	PLAYER STARTS		                                               																							*
//                                                                  																							*
//***************************************************************************************************************************************************************

// Osprey intro
playerstart_osprey()
{
	//stopping osprey sounds?
	osprey1 = GetEnt( "hithard_osprey_01", "targetname" );
	osprey1 Vehicle_TurnEngineOff();
	osprey2 = GetEnt( "hithard_osprey_02", "targetname" );
	osprey2 Vehicle_TurnEngineOff();
	osprey3 = GetEnt( "hithard_osprey_03", "targetname" );
	osprey3 Vehicle_TurnEngineOff();
	osprey4 = GetEnt( "hithard_osprey_04", "targetname" );
	osprey4 Vehicle_TurnEngineOff();

	// Take weapons away
	level._player takeallweapons();
	
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_osprey" );		
	
	// Get Landing Zone Marker
	level.parachute_landing_zone = GetEnt( "playerstart_parachute_land", "targetname" );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Parachute jump
playerstart_parachute_jump()
{
	thread maps\nx_hithard_parachute::para_clear_flags();

	delete_intro_ai();
	// Take weapons away
	level._player takeallweapons();

	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_parachute_jump" );

	
	// Turn on billboards
	thread maps\nx_hithard_parachute::parachute_billboard_binks( true );

	// Get Landing Zone Marker
	level.parachute_landing_zone = GetEnt( "playerstart_parachute_land", "targetname" );		

	thread maps\nx_hithard_parachute::parachute_enemy_UGVs();

	flag_set( "flag_vnode_parasecure_parachute_player_start" );
	level notify( "notify_parachute_start" );
	level._player PlaySound( "hithard_para_jump" );
	thread maps\_utility::set_ambient( "nx_hithard_chute" );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Parachute landing
playerstart_rooftop()
{		
	maps\_threatid::threat_id_enable_toggling();

	// Remove intro AI
	maps\nx_hithard_util::delete_all_ai_immediately(); 

	// Remove any other straggling AI
	maps\_nx_utility::delete_ai_in_volume_not_bullet_shielded( "volume_parachute_all_ai", "axis" );

	// JR - Enemies no longer spawn before you land
	//thread maps\nx_hithard_rooftop::prep_parachute_library_rooftop();

	// Move squad to positions			
	ally_start_noteworthies = [ "origin_parachute_land_ally_01_start", "origin_parachute_land_ally_02_start" ];
	level.squad  maps\nx_hithard_util::moveAlliesToStartPoint( ally_start_noteworthies );
	level.squad maps\nx_hithard_util::ignore_all_off();

	// Move player to start position
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_parachute_land" );

	// Play the landing bink
	thread maps\nx_hithard_rooftop::rooftop_landing_bink( true );

	// Spawn VTOL and move it into position
	maps\nx_hithard_rooftop::vtol_flyin_logic( true ) ;

	// Prep the rooftop
	level waittill( "notify_prep_parachute_library_rooftop_complete" );	

	level notify( "notify_parachute_objective_complete" );
}

//*******************************************************************
//					                                              	*
//					                                              	*						   
//*******************************************************************																								

// Secure Motorcade
playerstart_secure()
{	
	maps\_threatid::threat_id_enable_toggling();

	// Remove intro AI
	maps\nx_hithard_util::delete_all_ai_immediately(); 

	// Remove any other straggling AI
	maps\_nx_utility::delete_ai_in_volume_not_bullet_shielded( "volume_parachute_all_ai", "axis" );

	// Prepare the main intersection
	flag_set( "flag_prep_secure" );
	thread maps\nx_hithard_secure::prep_secure_intersection( true );
	
	// Move squad to positions			
	ally_start_noteworthies = [ "origin_secure_ally_02_start", "origin_secure_ally_01_start" ];
	ally_set_goal_noteworthies = [ "node_secure_ally_02_cover", "node_secure_ally_01_cover" ];
	level.squad  maps\nx_hithard_util::moveAlliesToStartPoint( ally_start_noteworthies, ally_set_goal_noteworthies );		
	level.squad maps\nx_hithard_util::ignore_all_on();		
			
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_secure" );	
}

//*******************************************************************
//					                                              	*
//					                                              	*						   
//*******************************************************************																								

// Secure Motorcade: Rappel
playerstart_secure_rappel()
{
	// Remove intro AI
	maps\nx_hithard_util::delete_all_ai_immediately();
	
	// Remove any other straggling AI
	maps\_nx_utility::delete_ai_in_volume_not_bullet_shielded( "volume_parachute_all_ai", "axis" );

	// Get the numbers on the ground up
	level.secure_ground_num_guys_allowed = level.secure_wave_2_num_enemies;

	// Prepare the main intersection
	flag_set( "flag_prep_secure" );
	thread maps\nx_hithard_secure::prep_secure_intersection( false );

	// Get the numbers on the ground up again (reset by prep_secure_intersection
	level.secure_ground_num_guys_allowed = level.secure_wave_2_num_enemies;

	// Move squad to positions				
	ally_start_noteworthies = [ "origin_secure_ally_02_start", "origin_secure_ally_01_start" ];
	
	//level.squad maps\nx_hithard_util::moveAlliesToStartPoint( ally_set_goal_noteworthies, ally_set_goal_noteworthies, true );				
	for( i = 0; i < level.squad.size; i++ )
	{
		node = GetEnt( ally_start_noteworthies[ i ], "script_noteworthy" );
		level.squad[ i ] ForceTeleport( node.origin );  
	}

	// Warp player		
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_rappel" );
	
	// enable threat ID usage
	flag_set( "flag_script_ground_threat_id_allow" );
	thread maps\_threatid::threatid_bootup_and_enable();		

	// Start snipe objective
	objective_start( "obj_secure_snipe", &"NX_HITHARD_SECURE_OBJ_SNIPE" );
}

//*******************************************************************
//					                                              	*
//					                                              	*						   
//*******************************************************************																								

// Secure Motorcade: Ground
playerstart_secure_ground( alt_start_point, alt_ally_1_start, alt_ally_2_start )
{	
	// Remove intro AI
	maps\nx_hithard_util::delete_all_ai_immediately();
	
	// Remove any other straggling AI
	maps\_nx_utility::delete_ai_in_volume_not_bullet_shielded( "volume_parachute_all_ai", "axis" );

	// Get the numbers on the ground up
	level.secure_ground_num_guys_allowed = level.secure_wave_2_num_enemies;

	// Prepare the main intersection
	flag_set( "flag_prep_secure" );
	thread maps\nx_hithard_secure::prep_secure_intersection( false );

	// Get the numbers on the ground up again (reset by prep_secure_intersection
	level.secure_ground_num_guys_allowed = level.secure_wave_2_num_enemies;

	// Move squad to positions				
	ally_set_goal_noteworthies = [ "node_secure_ground_ally_02", "node_secure_ground_ally_01" ];	
	
	level.squad maps\nx_hithard_util::moveAlliesToStartPoint( ally_set_goal_noteworthies, ally_set_goal_noteworthies, true );			
	
	level.squad set_fixednode_true_array();

	// Warp player		
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_secure_ground" );

	// Send in spawners under cover of smoke
	// Turn on the spawn pool (as "wave_1" ground enemies die, new ones will spawn to keep the threat level at "awesomesauce")	
	thread maps\nx_hithard_secure::spawn_smoke();
	
	// enable threat ID usage
	flag_set( "flag_script_ground_threat_id_allow" );
	thread maps\_threatid::threatid_bootup_and_enable();		
	
	waittillframeend;

	// Send false notify to get smoke to spawn
	level._player notify( "notify_rappel_start" );
	
	// Start snipe objective
	objective_start( "obj_secure_snipe", &"NX_HITHARD_SECURE_OBJ_SNIPE" );	
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

playerstart_motorcade()
{
	// Remove intro AI
	maps\nx_hithard_util::delete_all_ai_immediately(); 

	// Remove any other straggling AI
	maps\_nx_utility::delete_ai_in_volume_not_bullet_shielded( "volume_parachute_all_ai", "axis" );

	// Remove placeholder noclip brushes (so motorcade doesn't try to run over them)
	maps\nx_hithard_util::delete_secure_barricade();

	// Move player
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_secure_ground" );

	// Move your squad
	//node_baker = getnode ("node_baker_door_kick", "script_noteworthy");
	node_baker = getnode ("node_baker_transition1", "script_noteworthy");
	level.squad[0] ForceTeleport( node_baker.origin, node_baker.angles );
	//node_gypsy = getnode ("node_gypsy_transition0", "script_noteworthy");
	node_gypsy = getnode ("node_gypsy_transition1", "script_noteworthy");
	level.squad[1] ForceTeleport( node_gypsy.origin, node_gypsy.angles );

	// Spawn VP and SS
	spawners = getentarray( "vp_ss", "targetname" );
	array_thread( spawners, ::spawn_ai );
	level.secure_vip = get_living_ai ( "vp_transition", "script_noteworthy");
	level.secure_vip magic_bullet_shield();	
	level.secure_vip maps\nx_hithard_anim::init_vp_anims();
	level.secure_vip.animname = "vp";
	level.secure_vip.dontmelee = true;

	level.ss_fodder1 = get_living_ai ( "ss_fodder1", "script_noteworthy");
	level.ss_fodder2 = get_living_ai ( "ss_fodder2", "script_noteworthy");
	level.ss_fodder3 = get_living_ai ( "ss_fodder3", "script_noteworthy");

	fodder_guys = [ level.ss_fodder1, level.ss_fodder2, level.ss_fodder3 ];
	fodder_guys prep_ss_motorcade_array();	
}



//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Initializae threat bias groups
setup_threatbias_groups()
{	
	// Global
	CreateThreatBiasGroup( "squad" );
	CreateThreatBiasGroup( "player" );

	// Rooftop
	CreateThreatBiasGroup( "rooftop_guards" );
	CreateThreatBiasGroup( "rooftop_fastropers" );

	// Secure
	CreateThreatBiasGroup( "secure_vip_guard" );		
	CreateThreatBiasGroup( "secure_wave_1" );
	CreateThreatBiasGroup( "secure_wave_1_front_0" );
	CreateThreatBiasGroup( "secure_vip" );
	CreateThreatBiasGroup( "secure_wave_cortel" );
	CreateThreatBiasGroup( "secure_wave_bon" );
	CreateThreatBiasGroup( "secure_wave_uavs" );	
	
	// Apply group to player and allies	
	level._player SetThreatBiasGroup( "player" );
	foreach( guy in level.squad )
	{
		guy SetThreatBiasGroup( "allies" );
		guy SetThreatBiasGroup( "squad" );
	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Spawn squad members
spawn_squad()
{
	// Script Noteworthies for main squad members used to create level.squad
	//
	//		Baker is "ally_01" (level.squad[0])
	//		Gypsy is "ally_02" (level.squad[1])	

	squad_noteworthies = ["ally_01", "ally_02"];

	squad_spawner = [];	

	for( i = 0; i < squad_noteworthies.size; i++ )
	{
		squad_spawner[ i ] = GetEnt( squad_noteworthies[ i ], "script_noteworthy" );					
	}

	squad = array_spawn_function( squad_spawner, ::vip_spawnfunc );
	
	if ( !isdefined( squad )) 
	{
		for( i = 0; i < squad_spawner.size; i++ )
		{
			squad[ i ] = squad_spawner[ i ]	spawn_ai();
		}
	}

	return squad;
}
												
//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Spawnfunc for squad members
vip_spawnfunc()
{	
	self thread magic_bullet_shield();
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Deletes intro AI
delete_intro_ai()
{
	level.intro_ai_noteworthies = [];

	// List of all ai and vehicles used in intro (to be deleted if jumping past intro sequence)
	level.intro_ai_noteworthies = 
	[
		"hithard_intro_pilot1",
		"hithard_intro_pilot2",
		"hithard_intro_ally1",
		"hithard_intro_ally2",
		"hithard_intro_ally3",
		"hithard_intro_ally4",
		"hithard_intro_ally5",
		"squad_ally_osprey",
		"squad_osprey"
	];

	maps\nx_hithard_util::delete_array_of_ai( level.intro_ai_noteworthies );	
}



