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
#include maps\nx_harbor_util;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main()
{
	// Add_starts
	default_start( ::nx_harbor_tram_ride_start );	
	add_start( "tram_ride", ::nx_harbor_tram_ride_start, "Tram Ride", ::nx_harbor_tram_ride );
	add_start( "station", ::nx_harbor_station_start, "Station", ::nx_harbor_station );
	add_start( "tunnel", ::nx_harbor_tunnel_start, "Tunnel", ::nx_harbor_tunnel );
	add_start( "derail", ::nx_harbor_derail_start, "Derail", ::nx_harbor_derail );
	add_start( "harbor_no_game", ::nx_harbor_no_game_start, "Harbor No Game", ::nx_harbor_no_game );

	// External Initialization
	maps\nx_harbor_precache::main();
	maps\nx_harbor_anim::main();
	maps\nx_harbor_fx::main();
	maps\_load::main();

	//start ambiences
	maps\nx_harbor_amb::main();

	// Internal Initialization
	mission_flag_inits();
	mission_precache();

	// Mission threads
	level thread mission_music();

	// Tunnel thread
	level thread tunnel_thread();
	level thread save_point_thread();
	level thread end_mission_thread();
	level thread hide_underwater_box();
	level thread setup_ambients();
}

// All mission specific PreCache calls
mission_precache()
{
	PrecacheItem( "hind_FFAR" );
	PrecacheModel( "nx_prototype_harbor_train" );
	PrecacheModel( "nx_prototype_harbor_window01" );
	PrecacheModel( "nx_prototype_harbor_window02" );
	PrecacheModel( "nx_prototype_harbor_floor01" );
	PrecacheModel( "nx_prototype_harbor_floor02" );
	PrecacheModel( "nx_prototype_harbor_glass_botb01" );
	PrecacheModel( "nx_prototype_harbor_glass_botb02" );
	PrecacheModel( "nx_prototype_harbor_glass_botf01" );
	PrecacheModel( "nx_prototype_harbor_glass_botf02" );
	PrecacheModel( "nx_prototype_harbor_glass_topb01" );
	PrecacheModel( "nx_prototype_harbor_glass_topb02" );
	PrecacheModel( "nx_prototype_harbor_glass_topfc01" );
	PrecacheModel( "nx_prototype_harbor_glass_topfc02" );
	PrecacheModel( "nx_prototype_harbor_glass_tops01" );
	PrecacheModel( "nx_prototype_harbor_glass_tops02" );
}

// All mission specific flag_init() calls
mission_flag_inits()
{
	flag_init( "tram_end_mission" );
}

//*******************************************************************
//                                                                  *
//*******************************************************************

setup_ambients()
{
	level._ambient_track [ "amb_underwater" ] = "amb_underwater";
}

// Put scripts for tunnel sound / fx
player_entered_tunnel()
{
	level notify( "player_entered_tunnel" );
	level._player playsound("train_enter_tunnel");
	thread maps\_utility::set_ambient( "nx_harbor_train_tunnel_int" );
	thread play_subway_announcer();	
	transition_time = 7.0;
	// iPrintLnBold( "--- ENTERING Tunnel ---" );
	set_vision_set("nx_harbor_tunnel", transition_time);
	setExpFog( 1083, 14802, 0.7960784, 0.7568628, 0.7137255, 1.0, transition_time );
}

// Put scripts for exterior sound / fx
player_left_tunnel()
{
	level notify( "player_left_tunnel" );
	level._player playsound("train_exit_tunnel");
	thread maps\_utility::set_ambient( "nx_harbor_train_int" );
	transition_time = 5.0;
// 	iPrintLnBold( "--- EXITING Tunnel ---" );
	set_vision_set("nx_harbor_outside", transition_time);
	setExpFog( 12635, 14802, 0.7215686, 0.7882353, 0.7803922, 0.4, transition_time );
}

play_subway_announcer()
{
	announcer = spawn( "sound_emitter", ( 2762, 31838, 300 ) );
	wait 2.7;
	announcer PlaySound( "emt_subway_announcer" );
	
	wait 12.0;
	announcer delete();
}

tunnel_thread()
{
	while( true )
	{
		flag_wait( "player_in_tunnel" );
		level thread player_entered_tunnel();

		while( true )
		{
			if( !flag( "player_in_tunnel" ) )
				break;

			wait( 0.05 );
		}

		level thread player_left_tunnel();
	}
}

//*******************************************************************
//                                                                  *
//*******************************************************************

save_point_thread()
{
	while( true )
	{
		flag_wait( "tram_save_point" );

		level thread autosave_now();

		flag_clear( "tram_save_point" );
	}
}

end_mission_thread()
{
	flag_wait( "tram_end_mission" );
	endmission_goto_frontend();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

nx_harbor_setup()
{
	level.platform = maps\_nx_moving_platform::init( "platform_train" );
	waittillframeend;

	train_setup( level.platform );
	anim_create_paths();

	player_setup();
	ally_setup( "ally_01", "ally_01", "anim_window_mid_left" );
	ally_setup( "ally_02", "ally_02", "anim_window_mid_left_top" );

	level thread debug_print_train_speed();
}

debug_print_train_speed()
{
	//iPrintLn( level.platform train_get_speed() );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

nx_harbor_tram_ride_start()
{
}

nx_harbor_tram_ride()
{
	// Setup
	nx_harbor_setup();
	
	// Start the ambient vehicles
	level thread tram_ride_ambient_vehicles();

	// Start the train
	level.platform maps\_nx_moving_platform::init_player_start();
	level.platform maps\_nx_moving_platform::start_path( "train_path_start", "targetname" );

	// Thread the events
	level thread nx_harbor_tram_ride_choppers();
}

nx_harbor_tram_ride_choppers()
{
	///////////////////
	// EVENTS
	///////////////////

	//Chopper 01
	trigger_wait( "enemy_choppers_spawn", "targetname" );
	chopper_01 = maps\nx_harbor_util::vehicle_create( "enemy_chopper_01", ::bridge_chopper_01 );
	chopper_02 = maps\nx_harbor_util::vehicle_create( "enemy_chopper_02", ::bridge_chopper_02);
	chopper_boss = maps\nx_harbor_util::vehicle_create( "enemy_chopper_boss", ::bridge_chopper_boss );
}

bridge_chopper_01()
{
	self endon( "death" );
	self endon( "delete" );

	self godon();
	trigger_wait( "enemy_choppers_follow", "targetname" );
	self godoff();
	self thread vehicle_follow( level.platform, 15, 40, level._player );
	self chopper_attack( "gun", level._player );
	level.squad[ "ally_01" ] ally_attack( self );
	level waittill( "player_entered_tunnel" );
	self Delete();
}

bridge_chopper_02()
{
	self endon( "death" );
	self endon( "delete" );

	self godon();
	trigger_wait( "enemy_choppers_follow", "targetname" );
	self godoff();
	level.squad[ "ally_02" ] ally_attack( self );
	wait 4.0;
	self thread vehicle_follow( level.platform, 15, 40, level._player );
	self chopper_attack( "gun", level._player );
	level waittill( "player_entered_tunnel" );
	self Delete();
}

bridge_chopper_boss()
{
	self endon( "death" );
	self endon( "delete" );

	godon();
	trigger_wait( "enemy_choppers_follow", "targetname" );
	self thread vehicle_follow( level.platform, 15, 40 );
	trigger_wait( "chopper_boss_lead", "targetname" );
	self vehicle_jump_to_path( "enemy_chopper_boss_lead", "targetname" );
	self vehicle_end_follow();
	self thread vehicle_follow( level.platform, 45, 60, level._player );
	wait 6.0;
	self chopper_attack( "missile", level._player );
	level waittill( "player_entered_tunnel" );
	self Delete();
}

//*******************************************************************
//                                                                  *
//*******************************************************************

tram_ride_ambient_vehicles()
{
	level thread ambient_vehicles_bridge();
}

ambient_vehicles_bridge()
{
	level thread maps\nx_harbor_util::lane_logic( "lane_1_cars", 60, 1.0, 3000, "stop_ambient_vehicles_bridge" );
	wait( 1.0 );
	level thread maps\nx_harbor_util::lane_logic( "lane_2_cars", 60, 1.0, 3000, "stop_ambient_vehicles_bridge" );
	wait( 1.0 );
	level thread maps\nx_harbor_util::lane_logic( "lane_3_cars", 60, 1.0, 3000, "stop_ambient_vehicles_bridge" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

nx_harbor_station_start()
{
	// Setup
	nx_harbor_setup();

	// Start the train
	level.platform maps\_nx_moving_platform::start_path( "train_path_station_start", "targetname" );

	wait( 0.05 );

	level.platform maps\_nx_moving_platform::init_player_start();
}

nx_harbor_station()
{
	// Start the ambient vehicles
	level thread station_ambient_vehicles();

	level thread station_civilians();

	// Spawn funcs
	station_enemy_wave_1 = GetEntArray( "station_enemy_wave_1", "targetname" );
	array_thread( station_enemy_wave_1, ::add_spawn_function, ::station_enemy_wave_1_spawn_func );
	station_enemy_wave_2 = GetEntArray( "station_enemy_wave_2", "targetname" );
	array_thread( station_enemy_wave_2, ::add_spawn_function, ::station_enemy_wave_2_spawn_func );

	// First street encounter.
	level waittill( "player_left_tunnel" );
	autosave_now();

	trigger_wait( "enemy_car_01_spawn", "targetname" );
	car_01 = vehicle_create( "enemy_car_01", ::car_01_city );
	car_02 = vehicle_create( "enemy_car_02", ::car_02_city );

	trigger_wait( "enemy_boss_street_01", "targetname" );
	boss = vehicle_create( "enemy_chopper_boss", ::boss_city );
}

station_civilians()
{
	level endon( "player_left_tunnel" );

	trigger_wait( "station_civilian_spawn", "targetname" );

	crowd = maps\nx_crowd_controller::init_crowd( "station_civilians", 
	15, 
	GetEntArray( "station_civilian", "script_noteworthy" ), 
	GetEntArray( "civilian_path", "script_noteworthy"), 
	0.5,
	1.0
	 );

	 while( 1 )
	 {
		maps\nx_crowd_controller::spawn_crowd( "station_civilians" );
		level waittill( "station_civilians" );
	 }

//  civilian_spawners = GetEntArray( "station_civilian", "script_noteworthy" );
//  foreach( spawner in civilian_spawners )
//  {
//  	spawner spawn_ai( true );
//  	wait RandomFloatRange( 0.6, 1.0 );
//  }
}

station_enemy_wave_1_spawn_func()
{
	self.baseaccuracy = 0.4;
}

boss_city()
{
	self endon( "death" );
	self endon( "delete" );

	self vehicle_jump_to_path( "enemy_chopper_boss_street_01", "targetname" );
	self thread vehicle_follow( level.platform, 45, 70 );
	
	trigger_wait( "enemy_boss_face", "targetname" );
	self vehicle_end_follow();
	self thread vehicle_follow( level.platform, 30, 70, level._player );
	wait 10.0;
	self chopper_attack( "missile", level._player );

	level waittill( "player_entered_tunnel" );
	self Delete();
}


station_enemy_wave_2_spawn_func()
{
	self.baseaccuracy = 0.4;
}

car_01_city()
{
	self endon( "death" );
	self endon( "delete" );
	self.health = 1000;
	self thread vehicle_follow( level.platform, 35, 60 );
	self thread vehicle_kill_on_rider_death( 4 );
	level waittill( "player_entered_tunnel" );
	self Delete();
}

car_02_city()
{
	self endon( "death" );
	self endon( "delete" );
	self.health = 1000;
	self thread vehicle_follow( level.platform, 35, 60 );
	self thread vehicle_kill_on_rider_death( 4 );

	level waittill( "player_entered_tunnel" );
	self Delete();
}

//*******************************************************************
//                                                                  *
//*******************************************************************

station_ambient_vehicles()
{
	flag_wait( "start_ambient_vehicles_city" );
	level thread ambient_vehicles_city();
}

ambient_vehicles_city()
{
	level thread maps\nx_harbor_util::lane_logic( "lane_1_cars_city", 50, 2.0, 8000, "stop_ambient_vehicles_city" );
	wait( 1.0 );
	level thread maps\nx_harbor_util::lane_logic( "lane_2_cars_city", 50, 2.0, 8000, "stop_ambient_vehicles_city" );
	wait( 1.0 );
	level thread maps\nx_harbor_util::lane_logic( "lane_3_cars_city", 50, 2.0, 8000, "stop_ambient_vehicles_city" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

nx_harbor_tunnel_start()
{
	// Setup
	nx_harbor_setup();

	// Start the train
	level.platform maps\_nx_moving_platform::start_path( "train_path_tunnel_start", "targetname" );

	wait( 0.05 );

	level.platform maps\_nx_moving_platform::init_player_start();
}

nx_harbor_tunnel()
{
	// Start the ambient vehicles
	level thread tunnel_ambient_vehicles( );

	trigger_wait( "enemy_tunnel_01_spawn", "targetname" );
	car_01 = vehicle_create( "tunnel_car_01", ::car_01_tunnel );
	car_02 = vehicle_create( "tunnel_car_02", ::car_02_tunnel );

	trigger_wait( "enemy_tunnel_02_spawn", "targetname" );
	car_03 = vehicle_create( "tunnel_car_03", ::car_03_tunnel );
	car_04 = vehicle_create( "tunnel_car_04", ::car_04_tunnel );

	trigger_wait( "tunnel_semi_spawn", "targetname" );
	level.semi = vehicle_create( "tunnel_semi", ::semi_tunnel );

	car_03 thread car_truck_death( level.semi );
	car_04 thread car_truck_death( level.semi );
}

car_01_tunnel()
{
	self endon( "death" );
	self endon( "delete" );
	self thread vehicle_follow( level.platform, 35, 60 );
	self thread vehicle_kill_on_rider_death( 4 );
	self lights_on( "all" );

	self waittill( "reached_end_node" );
	self vehicle_crash();
}

car_02_tunnel()
{
	self endon( "death" );
	self endon( "delete" );

	self thread vehicle_follow( level.platform, 35, 60 );
	self thread vehicle_kill_on_rider_death( 4 );
	self lights_on( "all" );

	level waittill( "tunnel_combat_end" );
	self Delete();
}

car_03_tunnel()
{
	self endon( "death" );
	self endon( "delete" );
	self thread vehicle_follow( level.platform, 35, 60 );
	self lights_on( "all" );

	self.riders[ 2 ].health = 2000;	
	level waittill( "tunnel_combat_end" );
	self Delete();
}

car_04_tunnel()
{
	self endon( "death" );
	self endon( "delete" );
	self thread vehicle_follow( level.platform, 35, 60 );
	self lights_on( "all" );

	self.riders[ 2 ].health = 2000;
	level waittill( "tunnel_combat_end" );
	self Delete();
}

semi_tunnel()
{
	self endon( "death" );
	self endon( "delete" );
	self lights_on( "all" );
	level waittill( "tunnel_combat_end" );
	self Delete();
}

car_truck_death( truck )
{
	self endon( "death" );
	self endon( "delete" );

	while( 1 )
	{
		if( Distance( self.origin, truck.origin ) < truck.radius )
		{
			self vehicle_crash();
			break;
		}
		wait 0.05;
	}	
}

//*******************************************************************
//                                                                  *
//*******************************************************************

tunnel_ambient_vehicles( )
{
	flag_wait( "start_ambient_vehicles_tunnel" );
	level thread ambient_vehicles_tunnel();
}

ambient_vehicles_tunnel()
{
	level thread maps\nx_harbor_util::lane_logic( "lane_4_cars_tunnel", 40, 3.0, 5000, "stop_ambient_vehicles_tunnel", true );
	wait( 1.0 );
	level thread maps\nx_harbor_util::lane_logic( "lane_1_cars_tunnel", 40, 3.0, 5000, "stop_ambient_vehicles_tunnel", true  );
	wait( 1.0 );
	level thread maps\nx_harbor_util::lane_logic( "lane_5_cars_tunnel", 40, 3.0, 5000, "stop_ambient_vehicles_tunnel", true  );
	wait( 1.0 );
	level thread maps\nx_harbor_util::lane_logic( "lane_2_cars_tunnel", 40, 3.0, 5000, "stop_ambient_vehicles_tunnel", true  );
	wait( 1.0 );
	level thread maps\nx_harbor_util::lane_logic( "lane_6_cars_tunnel", 40, 3.0, 5000, "stop_ambient_vehicles_tunnel", true  );
	wait( 1.0 );
	level thread maps\nx_harbor_util::lane_logic( "lane_3_cars_tunnel", 40, 3.0, 5000, "stop_ambient_vehicles_tunnel", true  );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

nx_harbor_derail_start()
{
	// Setup
	nx_harbor_setup();

	// Start the train
	level.platform maps\_nx_moving_platform::start_path( "train_path_derail_start", "targetname" );

	wait( 0.05 );

	level.platform maps\_nx_moving_platform::init_player_start();
}

nx_harbor_derail()
{
	// Wait for exploder
//  level thread nx_harbor_derail_exploder();
	trigger_wait( "derail_boss_entrance", "targetname" );
	boss = vehicle_create( "enemy_chopper_boss", ::derail_boss );

	wait( 1.0 );

	// Set objective
	level thread derail_set_objective();
	level thread underwater();
}

derail_boss()
{
	self endon( "death" );
	self endon( "delete" );
	self godon();

	self vehicle_jump_to_path( "enemy_chopper_boss_derail", "targetname" );
	self thread vehicle_follow( train_get_object( "train_front" ), 70, 80, level._player );
//  self chopper_attack( "missile",  level._player);
	self waittill( "reached_dynamic_path_end" );
	self vehicle_end_follow();
	bridge_target = GetEnt( "chopper_bridge_target", "targetname" );
	self SetLookAtEnt( bridge_target );
//  self thread vehicle_follow( train_get_object( "train_front" ), 60, 70, bridge_target );

	self chopper_attack( "missile",  bridge_target);
	wait 1.5;
	nx_harbor_derail_exploder();
	wait 1.0;
	self chopper_end_missiles();

	self SetLookAtEnt( level._player );
}

derail_set_objective()
{
	objective_add( 1, "current", &"NX_HARBOR_OBJECTIVE_JUMP_OUT" );
	Objective_OnEntity( 1, level.platform, (-150, 300, -75) );

	derail_vignette();
}

derail_vignette()
{
	level.platform waittill( "platform_path_end" );

	// Sparks fx
	sparks_fx = GetEnt( "derail_sparks_fx", "targetname" );
	sparks_fx thread play_sound_in_space( "car_explode" );
	playFX( level._effect[ "derail_sparks_fx" ], sparks_fx.origin );
	Earthquake( 0.4, 4.0 , level._player.origin, 5000 );

	// Get node
	node = GetEnt( "derail_vignette", "targetname" );
	new_node = spawn( "script_origin", node.origin );
	new_node.angles = node.angles;

	// Delete the train
	level.platform train_delete();
	waittillframeend;

	// Play vignette
	tram = spawn_anim_model( "tram" );
	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["player_rig"] = player_rig;
	guys["tram"] = tram;

	// Play FX on tram
	tram thread tram_fx_thread();

	level._player playerLinkToBlend( player_rig, "tag_player", 0.75 );
	level._player disableweapons();

	new_node thread anim_first_frame( guys, "tram_derail" );
	wait( 0.25 );
	
	new_node thread anim_single( guys, "tram_derail" );

	wait( 11.0 );

	flag_set( "tram_end_mission" );
}

tram_fx_thread()
{
	wait( 9.5 );
	playFX( level._effect[ "tram_splash" ], self.origin );
}

underwater()
{
	flag_wait( "underwater" );

	// Underwater sound
	level._player playsound( "water_submerge" );
	thread maps\_utility::set_ambient( "amb_underwater" );
	thread maps\_ambient::setup_new_eq_settings( "underwater", level._eq_main_track );
	setsaveddvar( "g_enteqdist", 1 );

	playFX( level._effect[ "splash" ], level._player.origin );
	playFX( level._effect[ "underwater_splash" ], level._player.origin );

	maps\_utility::set_vision_set( "oilrig_underwater", 0 );
	setExpFog( 0, 482, 0.0461649, 0.25026, 0.221809, 1, 0, 0.0501764, 0.0501764, 0.0501764, (-0.0563281, 0.0228246, -1), 58.2299, 87.711, 1.48781 );

	level thread show_underwater_box();
	thread underwater_set_culldist( 0, 20000 );

	// Wait for not underwater
	while( true )
	{
		if( !flag( "underwater" ) )
		{
			break;
		}
		wait( 0.05 );
	}
	
	level thread hide_underwater_box();
}

show_underwater_box()
{
	underwater_box = getent( "underwater_box", "targetname" );
	underwater_box show();
}

hide_underwater_box()
{
	underwater_box = getent( "underwater_box", "targetname" );
	underwater_box hide();
}

underwater_set_culldist( time, range )
{
	wait time;
	SetCullDist( range );
}

nx_harbor_derail_exploder()
{
//  flag_wait( "derail_exploder" );
//  level waittill( "bridge_explode" );

	// Play fx
	derail_fx = GetEnt( "derail_fx", "targetname" );
	playFX( level._effect[ "derail_fx" ], derail_fx.origin );
	derail_fx thread play_sound_in_space( "car_explode" );

	// Trigger exploder
	exploder( 1 );

	// Rumble
	Earthquake( 0.4, 3.0 , level._player.origin, 5000 );
	level._player PlayRumbleOnEntity( "damage_light" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

nx_harbor_no_game_start()
{
}

nx_harbor_no_game()
{
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

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

