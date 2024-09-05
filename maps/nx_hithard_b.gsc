//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Hit Hard at Home on foot and Tank Drive Section											**
//                                                                          **
//    Created: 2-7-11  Alan Flores												**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\nx_hithard_b_util;
#include maps\_nx_utility;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main()
{
	// Player Starts
//	default_start( ::playerstart_default );
//	add_start( "city_hall_escape_start", ::playerstart_patriot_run, "Run Through City Hall", maps\nx_hithard_b_patriot_run::city_hall_escape_main );
	add_start( "escort_start", ::playerstart_escort, "Patriot Escort", maps\nx_hithard_b_patriot_run::escort_main );
	add_start( "mall_tunnel_start", ::playerstart_mall_tunnel, "Civilian Rescue", maps\nx_hithard_b_patriot_run::mall_tunnel_main );
	add_start( "plaza_2_start", ::playerstart_plaza_2, "Plaza 2", maps\nx_hithard_b_patriot_run::plaza_enc_main );
	add_start( "monorail_start", ::playerstart_monorail_station, "Monorail Station", maps\nx_hithard_b_monorail_station::monorail_station_main );
	add_start( "onramp_start",	::playerstart_onramp,	"Onramp", 			maps\nx_hithard_b_on_ramp::onramp_main );
	add_start( "vphit_start",	::playerstart_vphit,	"VP Hit", 			maps\nx_hithard_b_on_ramp::onramp_moment_vphit );
	add_start( "bravo_start",	::playerstart_bravo,	"Bravo Company",	maps\nx_hithard_b_on_ramp::onramp_moment_bravo );
	add_start( "tank_start", ::playerstart_tank, "Tank Rage" ); 

	// Internal Initialization
	mission_flag_inits();
	mission_precache();
	mission_globals();
	init_doors();

	// External Initialization
	maps\nx_hithard_b_precache::main();
	maps\nx_hithard_b_fx::main();
	maps\_threatid::main();

	maps\_load::main();

	maps\nx_hithard_b_anim::main();
	thread maps\nx_hithard_b_amb::main();

	// Init for using UGVs as boundary guards
	maps\_nx_utility::boundry_trigger_planes_init();

	// Main load / introscreen		
	maps\_compass::setupMiniMap( "compass_map_nx_hithard" );

	// Dead civilian logic
	thread maps\nx_hithard_b_anim::dead_men_setup();

	// Squad setup	
 	level.squad = spawn_squad();

	maps\_drone_civilian::init();
	maps\nx_crowd_controller::main();

	maps\_threatid::threat_id_enable_toggling();
}

// All mission specific PreCache calls
mission_precache()
{
	// HIND WEAPONS
	precacheItem( "hind_turret" );

	// chad note- adding test of motorized zoom scope weapon
	PreCacheItem( "xm108_asco" );	// Main Weapon	
	PrecacheItem( "smoke_grenade_american" );
	PreCacheItem( "flash_grenade" );
	PreCacheItem( "rpg_straight" );
	PreCacheItem( "rpg_straight_no_impact" );

	// stand in for aerial troop delivery vehicle
//	maps\_nx_chinese_vtol::main( "nx_vehicle_chinese_vtol", "ugv_cabin" );

	add_hint_string( "hint_tank_fire", &"NX_HITHARD_B_HINT_TANK_FIRE", ::hint_instructions);
	add_hint_string( "hint_tank_guns", &"NX_HITHARD_B_HINT_TANK_GUNS", ::hint_instructions);

	//Rumble precache
	PreCacheRumble( "c130_flyby" );
	PreCacheRumble( "artillery_rumble" );	

	level._effect[ "vehicle_explosion_hummer" ] = LoadFX( "explosions/vehicle_explosion_hummer" );

	PreCacheString( &"NX_HITHARD_B_HINT_MOVE_PATRIOT" );

	// Temp UGV explosion
}

// All mission specific flag_init() calls
mission_flag_inits()
{
	maps\nx_hithard_b_patriot_run::flag_inits();	
	maps\nx_hithard_b_monorail_station::flag_inits();
	maps\nx_hithard_b_on_ramp::flag_inits();	

	flag_init( "flag_ugv1_go" );
	flag_init( "flag_ugv2_go" );
	flag_init( "flag_building1" );
	flag_init( "flag_chopper1_go" );
	flag_init( "flag_chopper2_go" );
	flag_init( "flag_freeway_explosion" );
	flag_init( "flag_tank_slow1" );
	flag_init( "flag_tank_stop1" );
	flag_init( "flag_end_mission" );
}

init_doors()
{
	// city hall east exit door
//	level.door_ch_east_exit = make_door_from_prefab( "door_ch_east_exit", 95, -95 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Mission specific music thread
mission_music()
{
	// Here is an example of how to wait for a flag, and then change music
	// Reminder: These flags must be initialized in the mission_flag_inits() script
	// http://wiki2.neversoft.com/index.php/COD:_Step_By_Step_-_Adding_Music_To_A_Mission

// 	flag_wait( "music_nx_repel_intro_start_flag" );
// 	play_music_once( "nx_repel_intro" );
//	flag_wait( "music_nx_repel_battle_start_flag" );
//	play_music_num_times( "nx_repel_battle_1", 2 );
}

mission_globals()
{
	level.tank = GetEnt( "vehicle_rg_tank", "script_noteworthy");
	level.chopper1 = GetEnt( "chopper1", "script_noteworthy");
	level.chopper2 = GetEnt( "chopper2", "script_noteworthy");
	level.ugv1 = GetEnt( "ugv1", "script_noteworthy");
	level.ugv2 = GetEnt( "ugv2", "script_noteworthy");
	level.ugv3 = GetEnt( "ugv3", "script_noteworthy");
	level.ugv4 = GetEnt( "ugv4", "script_noteworthy");
}

set_squad_colors()
{
	level.squad[0] set_force_color( "b" );	// Baker
	level.squad[1] set_force_color( "b" );	// Gypsy
	level.squad[2] set_force_color( "p" );	// VP Price
	level.squad[3] set_force_color( "r" );	// SS Walker
	level.squad[4] set_force_color( "r" );	// SS Hayes
}

// Initializae threat bias groups
setup_threatbias_groups()
{	
	// Global
	CreateThreatBiasGroup( "allies" );
	CreateThreatBiasGroup( "player" );
	CreateThreatBiasGroup( "vp" );

	// Plaza 1
	CreateThreatBiasGroup( "upper_deck_threats" );
	CreateThreatBiasGroup( "vp_threats" );
	
	// Apply group to player and allies	
	level._player SetThreatBiasGroup( "player" );
	foreach( guy in level.squad )
	{
		guy SetThreatBiasGroup( "allies" );
	}

	// Set VP to a threatbias group
	level.squad[2] SetThreatBiasGroup( "vp" );
}

//*******************************************************************
//				PLAYER START SETUPS                     	*
//					                                              	*
//*******************************************************************

playerstart_default()
{	
	// Move squad to positions			
	ally_start_noteworthies = [ "origin_default_ally_01", "origin_default_ally_02", "origin_default_ally_vp_price", "origin_default_ally_ss_walker", "origin_default_ally_ss_hayes" ];
	ally_set_goal_noteworthies = [ "node_default_ally_01", "node_default_ally_02", "node_default_ally_vp_price", "node_default_ally_ss_walker", "node_default_ally_ss_hayes" ];

	set_squad_colors();
	level.squad  maps\nx_hithard_b_util::moveAlliesToStartPoint( ally_start_noteworthies, ally_set_goal_noteworthies );	

	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_default" );
	level.squad maps\nx_hithard_b_util::ignore_all_off();
	level.squad[2].ignoreall = true; // Setting the VP to not take part in the action
}

playerstart_patriot_run()
{	
	// Move squad to positions			
	ally_start_noteworthies = [ "origin_city_hall_escape_ally_01", "origin_city_hall_escape_ally_02", "origin_city_hall_escape_ally_vp_price", "origin_city_hall_escape_ally_ss_walker", "origin_city_hall_escape_ally_ss_hayes" ];
	ally_set_goal_noteworthies = [ "node_city_hall_escape_ally_01", "node_city_hall_escape_ally_02", "node_city_hall_escape_ally_vp_price", "node_city_hall_escape_ally_ss_walker", "node_city_hall_escape_ally_ss_hayes" ];

	set_squad_colors();
	level.squad  maps\nx_hithard_b_util::moveAlliesToStartPoint( ally_start_noteworthies, ally_set_goal_noteworthies );	

	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_city_hall_escape_start" );
	level.squad maps\nx_hithard_b_util::ignore_all_off();
	level.squad[2].ignoreall = true; // Setting the VP to not take part in the action
}

playerstart_escort()
{
	// Move squad to positions			
	ally_start_noteworthies = [ "origin_escort_patriot_ally_01", "origin_escort_patriot_ally_02", "origin_escort_patriot_ally_vp_price", "origin_escort_patriot_ally_ss_walker", "origin_escort_patriot_ally_ss_hayes" ];
	ally_set_goal_noteworthies = [ "node_escort_patriot_ally_01", "node_escort_patriot_ally_02", "node_escort_patriot_ally_vp_price", "node_escort_patriot_ally_ss_walker", "node_escort_patriot_ally_ss_hayes" ];

	set_squad_colors();
	level.squad  maps\nx_hithard_b_util::moveAlliesToStartPoint( ally_start_noteworthies, ally_set_goal_noteworthies );

	level._player maps\_nx_utility::move_player_to_start_point( "escort_start" );
	level.squad maps\nx_hithard_b_util::ignore_all_off();
	level.squad[2].ignoreall = true; // Setting the VP to not take part in the action
}

playerstart_mall_tunnel()
{
	// Move squad to positions			
	ally_start_noteworthies = [ "origin_mall_tunnel_ally_01", "origin_mall_tunnel_ally_02", "origin_mall_tunnel_ally_vp_price", "origin_mall_tunnel_ally_ss_walker", "origin_mall_tunnel_ally_ss_hayes" ];
	ally_set_goal_noteworthies = [ "node_mall_tunnel_ally_01", "node_mall_tunnel_ally_02", "node_mall_tunnel_ally_vp_price", "node_mall_tunnel_ally_ss_walker", "node_mall_tunnel_ally_ss_hayes" ];

	set_squad_colors();
	level.squad  maps\nx_hithard_b_util::moveAlliesToStartPoint( ally_start_noteworthies, ally_set_goal_noteworthies );	

	level._player maps\_nx_utility::move_player_to_start_point( "mall_tunnel_start" );
	level.squad maps\nx_hithard_b_util::ignore_all_off();
	level.squad[2].ignoreall = true; // Setting the VP to not take part in the action
}

playerstart_plaza_2()
{
	// Move squad to positions			
	ally_start_noteworthies = [ "origin_plaza_2_ally_01", "origin_plaza_2_ally_02", "origin_plaza_2_ally_vp_price", "origin_plaza_2_ally_ss_walker", "origin_plaza_2_ally_ss_hayes" ];
	ally_set_goal_noteworthies = [ "node_plaza_2_ally_01", "node_plaza_2_ally_02", "node_plaza_2_ally_vp_price", "node_plaza_2_ally_ss_walker", "node_plaza_2_ally_ss_hayes" ];

	set_squad_colors();
	level.squad  maps\nx_hithard_b_util::moveAlliesToStartPoint( ally_start_noteworthies, ally_set_goal_noteworthies );	

	level._player maps\_nx_utility::move_player_to_start_point( "plaza_2_start" );
	level.squad maps\nx_hithard_b_util::ignore_all_off();
	level.squad[2].ignoreall = true; // Setting the VP to not take part in the action
}

playerstart_monorail_station()
{
	// Move squad to positions			
	ally_start_noteworthies = [ "origin_monorail_ally_01", "origin_monorail_ally_02", "origin_monorail_ally_vp_price", "origin_monorail_ally_ss_walker", "origin_monorail_ally_ss_hayes" ];
	ally_set_goal_noteworthies = [ "node_monorail_ally_01", "node_monorail_ally_02", "node_monorail_ally_vp_price", "node_monorail_ally_ss_walker", "node_monorail_ally_ss_hayes" ];

	set_squad_colors();	
	level.squad  maps\nx_hithard_b_util::moveAlliesToStartPoint( ally_start_noteworthies, ally_set_goal_noteworthies );

	level._player maps\_nx_utility::move_player_to_start_point( "monorail_start" );
	level.squad maps\nx_hithard_b_util::ignore_all_off();
	level.squad[2].ignoreall = true; // Setting the VP to not take part in the action

	flag_wait( "plaza_enc_complete" );

	flag_wait( "flag_monorail_playerstart" );
	flag_set( "monorail_station_start" );

	// MOVE EVERYONE FORWARD.
	issue_color_orders( "b140", "allies" );

	// Make the VP and SS lag behind a bit
	wait( 1.4 );
	issue_color_orders( "r14 p14", "allies" );
}

playerstart_onramp()
{
//  maps\nx_hithard_b_on_ramp::onramp_setup();

	ally_start_noteworthies = [ "origin_onramp_ally_01", "origin_onramp_ally_02", "origin_onramp_ally_vp_price", "origin_onramp_ally_ss_walker", "origin_onramp_ally_ss_hayes" ];
	ally_set_goal_noteworthies = [ "node_onramp_ally_01", "node_onramp_ally_02", "node_onramp_ally_vp_price", "node_onramp_ally_ss_walker", "node_onramp_ally_ss_hayes" ];

	set_squad_colors();
	level.squad  maps\nx_hithard_b_util::moveAlliesToStartPoint( ally_start_noteworthies, ally_set_goal_noteworthies );

	level._player maps\_nx_utility::move_player_to_start_point( "onramp_start" );
	level.squad maps\nx_hithard_b_util::ignore_all_off();
	level.squad[2].ignoreall = true; // Setting the VP to not take part in the action

	maps\nx_hithard_b_on_ramp::onramp_section_started();
}

playerstart_vphit()
{
	maps\nx_hithard_b_on_ramp::onramp_setup();

	ally_start_noteworthies = [ "origin_vphit_ally_01", "origin_vphit_ally_02", "origin_vphit_ally_vp_price", "origin_vphit_ally_ss_walker", "origin_vphit_ally_ss_hayes" ];
	ally_set_goal_noteworthies = [ "node_vphit_ally_01", "node_vphit_ally_02", "node_vphit_ally_vp_price", "node_vphit_ally_ss_walker", "node_vphit_ally_ss_hayes" ];

	set_squad_colors();
	level.squad  maps\nx_hithard_b_util::moveAlliesToStartPoint( ally_start_noteworthies, ally_set_goal_noteworthies );

	level._player maps\_nx_utility::move_player_to_start_point( "vphit_start" );
	level.squad maps\nx_hithard_b_util::ignore_all_off();
	level.squad[2].ignoreall = true; // Setting the VP to not take part in the action

	level.squad[ 3 ] maps\nx_hithard_b_on_ramp::ss1_kill();

	maps\nx_hithard_b_on_ramp::onramp_section_started();
}

playerstart_bravo()
{
	maps\nx_hithard_b_on_ramp::onramp_setup();

	ally_start_noteworthies = [ "origin_bravo_ally_01", "origin_vphit_ally_02", "origin_bravo_ally_vp_price", "origin_vphit_ally_ss_walker", "origin_vphit_ally_ss_hayes" ];
	ally_set_goal_noteworthies = [ "node_bravo_ally_01", "node_vphit_ally_02", "node_bravo_ally_vp_price", "node_vphit_ally_ss_walker", "node_vphit_ally_ss_hayes" ];

	set_squad_colors();
	level.squad  maps\nx_hithard_b_util::moveAlliesToStartPoint( ally_start_noteworthies, ally_set_goal_noteworthies );

	level._player maps\_nx_utility::move_player_to_start_point( "player_bravo_start" );
	level.squad maps\nx_hithard_b_util::ignore_all_off();
	level.squad[2].ignoreall = true; // Setting the VP to not take part in the action

//  level.squad[ 3 ] maps\nx_hithard_b_on_ramp::ss1_kill();

	maps\nx_hithard_b_on_ramp::onramp_section_started();
	maps\nx_hithard_b_on_ramp::onramp_moment_bravo_debug();
}

playerstart_tank()
{
//  // Waiting for player to get to the top of the on ramp
//  Objective_State( objective_number, "done" );

	// Initialize Tank
	level thread initialize_vehicles();

	// Mission threads
	level thread mission_music();

	// Civilian panic
	level thread civilian_panic();

	level thread end_of_mission_flow();
}


// Tank stuff

initialize_vehicles()
{
	//level._player thread connect_player_to_tank_turret( level.tank );
	level thread tank_drive(level.tank);
	level thread chopper1_control();
	level thread chopper2_control();
	level thread ugv1_control();
	//level thread ugv2_control();
	level.ugv2 thread ugv2_control();

	level thread ugv3_control();
	level thread freeway_explo_trigger();
}

tank_drive( vehicle )
{
		self endon( "death" );
	
		// we will wait till the player enters the tank
		//vehicle waittill( "vehicle_mount" );
		
		level._player MountVehicle( vehicle );
		level._player DisableTurretDismount();
		vehicle MakeUnUsable();
		
		
		flag_wait( "introscreen_complete");

		// Tank HUD bootup sequence
		level._player FreezeControls( true );
		//level._player visionSetThermalForPlayer( "ac130", 0 );
		//level._player visionSetThermalForPlayer( "missilecam", 0.51 );
		level._player visionSetThermalForPlayer( "black_bw", 0.51 );
		level._player ThermalVisionOn();
		wait 0.5;
		level thread tank_hud_cycle();
		wait 1.0;
		level._player visionSetThermalForPlayer( "missilecam", 0.51 );
		wait 1.0;
		//level._player ThermalVisionOff();
		//wait 1.0;
		level._player visionSetThermalForPlayer( "black_bw", 0.51 );
		level._player ThermalVisionOn();
		wait 0.25;
		level._player visionSetThermalForPlayer( "missilecam", 0.51 );
		wait 0.25;
		level._player ThermalVisionOff();
		wait 0.1;
		level._player visionSetThermalForPlayer( "black_bw", 0.51 );
		level._player ThermalVisionOn();
		wait 0.1;
		level._player ThermalVisionOff();
					
		level._player FreezeControls( false );
		// End HUD bootup sequence

		level._player EnableInvulnerability();
		// player attaches to vehicle and has turret control, it doesn't look like new controls work though

		//display_hint( "hint_tank_fire" );
		wait 2.0;
		display_hint_timeout( "hint_tank_guns", 4 );
		wait 1.0;
		display_hint_timeout( "hint_tank_fire", 6 );

		flag_wait( "flag_building1" );

		spawners = getEntArray( "enemy_group1", "targetname");
		array_thread( spawners, ::spawn_ai );

		wait 3.0;

		vehicle Vehicle_SetSpeed( 45, 5.0 );
		//vehicle.health = 10000;
		vehicle GoPath();
		autosave_now();

		// slow down and stop stop 1
		flag_wait( "flag_tank_slow1" );
		vehicle Vehicle_SetSpeed( 5, 25.0 );
		flag_wait( "flag_tank_stop1" );
		vehicle Vehicle_SetSpeed( 0, 25.0 );

		wait 9;

		vehicle Vehicle_SetSpeed( 15, 5.0 );
		wait 8;
		vehicle Vehicle_SetSpeed( 45, 5.0 );

		// wait for the explosion and then slow down
		flag_wait( "flag_freeway_explosion");
		//vehicle Vehicle_SetSpeed( 15, 5.0 );
		//wait 5.0;
		vehicle Vehicle_SetSpeed( 10, 5.0 );
		wait 7.0;
		vehicle Vehicle_SetSpeed( 45, 5.0 );
}

hint_instructions()
{
	return false;
}

connect_player_to_tank_turret( vehicle )
{
	self endon( "death" );
	
		// we will wait till the player enters the tank
		vehicle waittill( "vehicle_mount" );

		// Delete the player blocker
		//blocker = GetEnt( "brush_blocker01", "targetname" );
		//blocker Delete();

		level._player EnableInvulnerability();
		// player attaches to vehicle and has turret control, it doesn't look like new controls work though

		flag_wait( "flag_building1" );
		spawners = getEntArray( "enemy_group1", "targetname");
		array_thread( spawners, ::spawn_ai );

		wait 3.0;

		vehicle Vehicle_SetSpeed( 45, 5.0 );
		//vehicle.health = 10000;
		vehicle GoPath();
		autosave_now();

		// slow down and stop stop 1
		flag_wait( "flag_tank_slow1" );
		vehicle Vehicle_SetSpeed( 5, 25.0 );
		flag_wait( "flag_tank_stop1" );
		vehicle Vehicle_SetSpeed( 0, 25.0 );

		wait 9;

		vehicle Vehicle_SetSpeed( 15, 5.0 );
		wait 8;
		vehicle Vehicle_SetSpeed( 45, 5.0 );

		// wait for the explosion and then slow down
		flag_wait( "flag_freeway_explosion");
		//vehicle Vehicle_SetSpeed( 15, 5.0 );
		//wait 5.0;
		vehicle Vehicle_SetSpeed( 10, 5.0 );
		wait 7.0;
		vehicle Vehicle_SetSpeed( 55, 5.0 );
}

chopper1_control()
{
		flag_wait( "flag_chopper1_go" );
		level.chopper1 Vehicle_SetSpeed( 80, 5.0);
		level.chopper1 GoPath();
		level.chopper1 setVehWeapon( "hind_turret" );
		level.chopper1 thread maps\_helicopter_globals::shootEnemyTarget_Bullets( level.tank );
}

chopper2_control()
{
		flag_wait( "flag_chopper2_go" );
		level.chopper2 Vehicle_SetSpeed( 80, 5.0);
		level.chopper2 GoPath();
		level.chopper2 setVehWeapon( "hind_turret" );
		level.chopper2 thread maps\_helicopter_globals::shootEnemyTarget_Bullets( level.tank );
}

// UGV stuff

ugv1_control()
{
	flag_wait( "flag_ugv1_go");
	level.ugv1 Vehicle_SetSpeed( 35, 7.9);
	//level.ugv1 Vehicle_SetSpeedImmediate( 60, 60, 60);
	level.ugv1 thread vehicle_fire_around_entity( level.tank, 0.75);
	level.ugv1 GoPath();

}

ugv2_control()
{
	flag_wait( "flag_ugv2_go");
	level.ugv2 Vehicle_SetSpeed( 56.15, 7.5);
	//level.ugv1 Vehicle_SetSpeedImmediate( 60, 60, 60);
	level.ugv2 thread vehicle_fire_around_entity( level.tank, 0.75);
	level.ugv2 GoPath();
}

ugv3_control()
{
	flag_wait( "flag_ugv1_go");
	level.ugv3 Vehicle_SetSpeed( 30, 3.9);
	//level.ugv1 Vehicle_SetSpeedImmediate( 60, 60, 60);
	level.ugv3 thread vehicle_fire_around_entity( level.tank, 0.75);
	level.ugv3 GoPath();
}

// FX

freeway_explo_trigger()
{
	flag_wait( "flag_freeway_explosion");
	level thread freeway_explosion();
	wait 0.75;
	trig = GetEnt( "bridge_explosion_trigger", "targetname" );
	trig notify( "trigger" );
	// spawn enemies
	spawners = getEntArray( "enemy_group2", "targetname");
	array_thread( spawners, ::spawn_ai );
}

freeway_explosion()
{
	// Play the FX
	freeway_explo1_fx = GetEnt( "freeway_explo1_fx", "targetname" );
	forward = AnglesToForward( freeway_explo1_fx.angles );
	up = AnglesToUp( freeway_explo1_fx.angles );
	playFX( level._effect[ "freeway_explosion" ], freeway_explo1_fx.origin, forward, up );
	wait 0.25;
	freeway_explo2_fx = GetEnt( "freeway_explo2_fx", "targetname" );
	forward = AnglesToForward( freeway_explo2_fx.angles );
	up = AnglesToUp( freeway_explo2_fx.angles );
	playFX( level._effect[ "freeway_explosion" ], freeway_explo2_fx.origin, forward, up );
	wait 0.25;
	freeway_explo3_fx = GetEnt( "freeway_explo3_fx", "targetname" );
	forward = AnglesToForward( freeway_explo3_fx.angles );
	up = AnglesToUp( freeway_explo3_fx.angles );
	playFX( level._effect[ "freeway_explosion" ], freeway_explo3_fx.origin, forward, up );
	wait 0.15;
	freeway_explo4_fx = GetEnt( "freeway_explo4_fx", "targetname" );
	forward = AnglesToForward( freeway_explo4_fx.angles );
	up = AnglesToUp( freeway_explo4_fx.angles );
	playFX( level._effect[ "nx_debri_explosion" ], freeway_explo4_fx.origin, forward, up );
	playFX( level._effect[ "building_explosion_gulag_bh1" ], freeway_explo4_fx.origin, forward, up );

}

end_of_mission_flow()
{
	flag_wait("flag_end_mission");
	nextmission();	
}

// UTILITIES //

vehicle_fire_around_entity( e, interval )
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

tank_hud_cycle()
{
	//quick_status_items = [ "Bypass Sequence", "Welcome back Travis" ];

	status_items = [ "Initializing Heads Up Display...", "!Engaged!", 
					 "Weapon Systems...", "!Online!",
					 "Drive Control...", "!Engaged!"
																 ];  

	//terminal_status_check( quick_status_items );
	terminal_status_check( status_items );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

terminal_status_check( status_items )
{
	pos_x = -265;
	pos_x_tab = -240;
	pos_y = 100;
	pos_y_add = 18;

	hud_elems = [];
	for ( i = 0; i < status_items.size; i=( i + 2 ) )
	{
		hud_elem = maps\_hud_util::get_countdown_hud( pos_x, pos_y );
		hud_elem SetPulseFX( 30, 900000, 700 );
		hud_elem.label = status_items[ i ];
		wait ( 0.3 + RandomFloat( 0.6 ) );

		hud_elems[ i ] = hud_elem;

		pos_y = ( pos_y + pos_y_add );

		hud_elem = maps\_hud_util::get_countdown_hud( pos_x_tab, pos_y );
		hud_elem SetPulseFX( 30, 900000, 700 );
		hud_elem.label = status_items[ i + 1 ];
		wait ( 0.65 + RandomFloat( 0.7 ) );

		hud_elems[ i + 1 ] = hud_elem;

		pos_y = ( pos_y + pos_y_add );
	}
	wait( 0.5 );
	
	foreach( hud_elem in hud_elems )
	{
		hud_elem destroy();
	}	
}

// Civilian panic

civilian_panic()
{
	crowd = maps\nx_crowd_controller::new_crowd( "test", 
	12, 
	GetEntArray( "test_spawner", "script_noteworthy" ), 
	GetEntArray( "test_start", "script_noteworthy"), 
	GetEntArray( "test_end", "script_noteworthy") );

	wait 4.0;

	while( 1 )
	{
		maps\nx_crowd_controller::spawn_crowd( "test" );
		wait 10.0;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn squad members
spawn_squad()
{
	// Script Noteworthies for main squad members 	
	//		note: this is an ordered list, so guys are referenced by the same index number.  
	//		For example: level.squad_noteworthies = ["Price", "Ghost", "Soap"]
	//				squad_noteworties[0] would always be "Price"
	//				squad_noteworthies[2] will always be "Soap"

	squad_noteworthies = ["ally_01", "ally_02", "ally_VP", "ally_ss_walker", "ally_ss_hayes" ];

	squad_spawner = [];	

	for( i = 0; i < squad_noteworthies.size; i++ )
	{
		squad_spawner[ i ] = GetEnt( squad_noteworthies[ i ], "script_noteworthy" );					
	}

	squad_spawner[2] add_spawn_function( ::vp_spawnfunc );
	squad = array_spawn_function( squad_spawner, ::vip_spawnfunc );
	
	
	if ( !isdefined( squad )) 
	{
		for( i = 0; i < squad_spawner.size; i++ )
		{
			squad[ i ] = squad_spawner[ i ]	spawn_ai();

			// Set country ID for battlechatter
			squad[i].countryID = "usop";
		}
	}

	level._player DisableThreatVisualization();

	squad[0].animname = "baker";
	squad[0].countryId = "usop";
	squad[0].battlechatter = true;

	squad[1].animname = "gypsy";
	squad[1].countryId = "usop";
	squad[1].battlechatter = true;

	squad[2].animname = "vp_price";
	squad[2].countryId = "usop";
	squad[2].battlechatter = false;
	squad[2].dontmelee = true;

	squad[3].animname = "ss_williams";
	squad[3].countryId = "ss";
	squad[3].battlechatter = true;
	squad[3] set_battlechatter_id( "1" );
	squad[3].bc_during_animscripted = true;
	squad[3] maps\nx_hithard_b_anim::init_ss_anims();
	
	squad[4].animname = "ss_hayes";
	squad[4].countryId = "ss";
	squad[4].battlechatter = false;
	squad[4] maps\nx_hithard_b_anim::init_ss_anims();

	return squad;
}

#using_animtree( "generic_human" );
vp_spawnfunc()
{
	//self.run_overrideanim = %civilian_walk_cool;
	//self.walk_overrideanim = %civilian_walk_cool;
	maps\nx_hithard_b_anim::init_vp_anims();
	self.run_overrideanim = undefined;
	self.walk_overrideanim = undefined;

}

vip_spawnfunc()
{	
	self thread magic_bullet_shield();
}


//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

