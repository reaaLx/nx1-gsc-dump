//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module: Lava Station 2												**
//                                                                          **
//    Created: 07/25/10 - Travis Chen (trchen x 4143)						**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_nx_vignette_util;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
	// Dead crew member logic
	thread maps\nx_lava_anim::dead_crew();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
}

section_flag_inits()
{
	flag_init( "station_2_elevator_moving" );
	flag_init( "station_2_elevator_ready_keene" );
	flag_init( "station_2_elevator_ready_tillman" );
	
	flag_init( "vignette_keene_standoff_done" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_objectives( objective_num )
{
	flag_wait( "player_off_train_1" );

	// Go to bridge
	waypoint = getEnt( "station_2_elevator_waypoint", "targetname" );
	objective_add( objective_num, "current", &"NX_LAVA_OBJECTIVE_STATION_2_ELEVATOR", waypoint.origin );
	objective_current( objective_num );

	flag_wait( "station_2_elevator_moving" );
		
	objective_complete( objective_num );
	objective_num++;
	
	flag_wait( "vignette_keene_standoff_done" );
		
	// Go to bridge
	waypoint = getEnt( "station_2_train_waypoint", "targetname" );
	objective_add( objective_num, "current", &"NX_LAVA_OBJECTIVE_STATION_2_TRAIN", waypoint.origin );
	objective_current( objective_num );

	flag_wait( "vignette_bridge_to_train_jump" );
		
	objective_complete( objective_num );
	objective_num++;

	return objective_num;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

station_2_VO()
{
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

station_2_start( start_point )
{
	station_2_start_shared( "train_1_station_2_start" );
}

station_2_start_shared( start_point )
{
	thread maps\nx_lava_fx::set_vision_and_fog("station1", 0);

	level._player TakeAllWeapons();
	level._player GiveWeapon( "lunarrifle" );
	level._player GiveWeapon( "spas12" );
	level._player SwitchToWeapon( "lunarrifle" );

	// Setup train 1 and do move
	level thread maps\nx_lava_train_1::train_1_setup();
	level thread station_2_start_train_1_move( start_point );

	flag_set( "train_1_moving" );

	// Spawn the allies
	maps\nx_lava_util::lava_ally_spawn( "train_1" );

	wait( 0.05 );

	// Ally thread
	maps\nx_lava_train_1::train_1_setup_locked_combat_nodes();
	level.keene maps\_locked_combat::init_locked_combat( "train_1_keene_fixed_node" );
	level.tilman maps\_locked_combat::init_locked_combat( "train_1_tillman_fixed_node" );
	
	// Link player to train
	level.train_1[0] maps\_nx_moving_platform::init_player_start();
}

station_2_start_train_1_move( start_point )
{
	// Move front vehicle
	vehicle_node = GetVehicleNode( start_point, "targetname" );
	level.train_1[0].vehicle AttachPath( vehicle_node );
	level.train_1[0].vehicle Vehicle_SetSpeed( 55, 10000, 10 );
	level.train_1[0].vehicle GoPath();

	if( start_point == "train_1_station_2_start" )
	{
		trigger_wait( "train_1_decel_2", "targetname" );
	}

	maps\nx_lava_util::set_train_speed( level.train_1, 6, 15, 2 );

	level thread maps\nx_lava_train_1::train_1_open_doors();
	
	// Wait till stop
	level.train_1[0].vehicle waittill( "reached_end_node" );
	flag_set( "train_1_stop" );
}

station_2()
{
	// VO
	level thread station_2_VO();

	// Enemy thread
	level thread station_2_enemy_thread();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

station_2_keene_thread()
{
	self endon( "death" );
	
	flag_wait( "train_1_stop" );

	// Stop locked combat
	self.locked_combat = undefined;
	self notify( "killanimscript" );
	self unlink();

	node = GetNode( "station_2_arrive_keene", "targetname" );
	self SetGoalNode( node );

	self set_force_color( "c" );
}

station_2_tilman_thread()
{
	self endon( "death" );
	
	flag_wait( "train_1_stop" );

	// Stop locked combat
	self.locked_combat = undefined;
	self notify( "killanimscript" );	
	self unlink();

	node = GetNode( "station_2_arrive_tilman", "targetname" );
	self SetGoalNode( node );

	self set_force_color( "b" );	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

station_2_enemy_thread()
{
	// DECEL
	enemy_station_2_decel_spawners = GetEntArray( "enemy_station_2_decel_wave_0", "targetname" );
	array_thread( enemy_station_2_decel_spawners, ::add_spawn_function, ::enemy_station_2_decel_spawn_func );

	enemy_station_2_decel_spawners = GetEntArray( "enemy_station_2_decel_wave_1", "targetname" );
	array_thread( enemy_station_2_decel_spawners, ::add_spawn_function, ::enemy_station_2_decel_spawn_func );

	enemy_station_2_decel_spawners = GetEntArray( "enemy_station_2_decel_wave_2", "targetname" );
	array_thread( enemy_station_2_decel_spawners, ::add_spawn_function, ::enemy_station_2_decel_spawn_func );

	enemy_station_2_decel_spawners = GetEntArray( "enemy_station_2_decel_wave_3", "targetname" );
	array_thread( enemy_station_2_decel_spawners, ::add_spawn_function, ::enemy_station_2_decel_spawn_func );

	enemy_station_2_decel_spawners = GetEntArray( "enemy_station_2_decel_wave_4", "targetname" );
	array_thread( enemy_station_2_decel_spawners, ::add_spawn_function, ::enemy_station_2_decel_spawn_func );
}

enemy_station_2_decel_spawn_func()
{
	self endon( "death" );

	self.script_forcegoal = 1;
	
	self enable_cqbwalk();

	self.dontmelee = true;
	self.no_gib = true;
	
	flag_wait( "enemy_station_2_decel_delete" );
	
	self delete();
}

enemy_train_decel_ambush()
{
	self endon( "death" );

	flag_wait( "train_1_stop" );

	// Ambush player
	self clear_force_color();
	self.maxsightdistsqrd = 4000 * 4000;
	self.favoriteenemy = level._player;
	self.pathrandompercent = 200;
	self SetGoalEntity( level._player );
	self.goalradius = 400;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

station_2_arrive_VO()
{
	flag_wait( "train_1_stop" );
	//thread add_dialogue_line( "Baker", "Move into the building.", "w" );
	radio_dialogue( "lava_bak_st2_moveintobuilding" );
	
	flag_wait( "player_off_train_1" );
	wait( 1.0 );
	
	//thread add_dialogue_line( "Baker", "Bodies haven't iced yet. Ten minutes. Maybe less.", "w" );
	radio_dialogue( "lava_bak_st2_bodiesiced" );
	wait( 1.0 );

	// Serrano - "I recognize this blade work. (beat) Keene killed these mean."
	radio_dialogue( "lava_ser_st2_bladework" );

	//thread add_dialogue_line( "Baker", "Move out.", "w" );
	radio_dialogue( "lava_bak_st2_moveout" );
	
	flag_wait( "station_2_elevator_moving" );
	wait( 3.0 );
	
	// Serrano - "Why hasn't he handed that nuke over to the Snakes? What's he waiting for?"
	radio_dialogue( "lava_ser_st2_handovernuke" );

	flag_wait( "vignette_keene_standoff" );
	wait( 2.5 );
	
	//thread add_dialogue_line( "Keene", "Walker?", "r" );
	radio_dialogue( "lava_kee_st2_walker" );
	//wait( 1.0 );
	//thread add_dialogue_line( "Baker", "We finally caught up with you… traitor!", "w" );
	radio_dialogue( "lava_bak_st2_traitor" );
	//wait( 1.5 );
	//thread add_dialogue_line( "Keene", "I'm no fuckin' Snake!", "r" );
	radio_dialogue( "lava_kee_st2_nosnake" );
	//wait( 2.0 );
	//thread add_dialogue_line( "Baker", "You wasted Griff. You betrayed your brokers, your country… everything.", "w" );
	radio_dialogue( "lava_bak_st2_betrayed" );
	//wait( 3.0 );
	//thread add_dialogue_line( "Keene", "You don't believe that, Baker. (beat) If you did, I'd already be dead.", "w" );
	//radio_dialogue( "lava_kee_st2_dontbelievethat" );
	//wait( 2.0 );
	//thread add_dialogue_line( "Baker", "Then why don't you explain what the fuck you're doing with my warhead!", "w" );
	//wait( 2.0 );
	//thread add_dialogue_line( "Keene", "Griff was dead when I found him. He was there too…", "w" );
	//wait( 1.0 );
	//thread add_dialogue_line( "Baker", "Who?", "w" );
	//wait( 0.5 );
	//thread add_dialogue_line( "Keene", "The traitor! He was stealing the warhead. I shot first. Winged him. He dropped it and ran.", "w" );
	//wait( 1.5 );
	//thread add_dialogue_line( "Keene", "I thought I was the only one left. I didn't know what else to do.", "r" );
	//radio_dialogue( "lava_kee_st2_onlyoneleft" );
	//wait( 1.5 );
	//thread add_dialogue_line( "Baker", "You came all the way out here to finish the mission alone?", "w" );
	//radio_dialogue( "lava_bak_st2_finishmission" );
	//wait( 1.0 );
	//thread add_dialogue_line( "Keene", "What would you do?", "r" );
	//radio_dialogue( "lava_kee_st2_whatwouldyoudo" );
	//wait( 0.5 );
	
	// Serrano - "Hate to interupt but we've got hostile technicals approaching fast!"
	radio_dialogue( "lava_ser_st2_hostiles" );

	//thread add_dialogue_line( "Keene", "Button up! ", "r" );
	//radio_dialogue( "lava_kee_st2_buttonup" );
	wait( 0.5 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

station_2_arrive_start()
{
	station_2_start_shared( "train_1_station_2_arrive_start" );
}

station_2_arrive()
{
	// VO
	level thread station_2_arrive_VO();
	
	// Enemy thread
	level thread station_2_enemy_arrive_thread();
	
	// Ally thread
	level.keene thread station_2_keene_thread();
	level.tilman thread station_2_tilman_thread();
	
	// Elevator
	level thread station_2_elevator_thread();
	
	// Keene Standoff Vignette
	level thread station_2_keene_standoff_vignette();
	
	flag_wait( "train_1_stop" );
	
	level thread autosave_now();

	level.keene maps\nx_lava_util::ally_protect();
	level.tilman maps\nx_lava_util::ally_protect();
	
	flag_wait( "vignette_keene_standoff_done" );
}

station_2_enemy_arrive_thread()
{
	// ARRIVE
	enemy_station_2_arrive_spawners = GetEntArray( "enemy_station_2_arrive_wave_0", "targetname" );
	array_thread( enemy_station_2_arrive_spawners, ::add_spawn_function, ::enemy_station_2_arrive_spawn_func );

	enemy_station_2_arrive_spawners = GetEntArray( "enemy_station_2_arrive_wave_1", "targetname" );
	array_thread( enemy_station_2_arrive_spawners, ::add_spawn_function, ::enemy_station_2_arrive_spawn_func );

	enemy_station_2_arrive_spawners = GetEntArray( "enemy_station_2_arrive_wave_2", "targetname" );
	array_thread( enemy_station_2_arrive_spawners, ::add_spawn_function, ::enemy_station_2_arrive_spawn_func );
}

enemy_station_2_arrive_spawn_func()
{
	self endon( "death" );

	self.script_forcegoal = 1;
	
	self enable_cqbwalk();

	self.dontmelee = true;
	self.no_gib = true;
	self.ignoresuppression = true;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

station_2_elevator_thread()
{
	station_2_move_allies_to_elevator();
	
	// Wait for player to use lev
	use = GetEnt( "station_2_elevator_use", "targetname" );
	use sethintstring( &"NX_LAVA_STATION_2_ELEVATOR_CONTROLS" );		

	use waittill( "trigger" );
	use trigger_off();

	flag_set( "station_2_elevator_moving" );
	
	// Front	
	door_front_r = link_elevator_door( "station_2_elevator_door_front_r", "station_2_elevator_door_front_r_link" );
	door_front_l = link_elevator_door( "station_2_elevator_door_front_l", "station_2_elevator_door_front_l_link" );

	// Rear
	door_rear_r = link_elevator_door( "station_2_elevator_door_rear_r", "station_2_elevator_door_rear_r_link" );
	door_rear_l = link_elevator_door( "station_2_elevator_door_rear_l", "station_2_elevator_door_rear_l_link" );

	// Close Front
	door_front_r MoveY( 44, 3, .05, .5 );
	door_front_l MoveY( -44, 3, .05, .5 );
	
	wait( 3 );
	
	// Command Center elevator ents
	station_2_elevator = GetEnt( "station_2_elevator", "targetname" );
	station_2_elevator_link = GetEntArray( "station_2_elevator_link", "targetname" );

	// Link elevator parts
	foreach( linker in station_2_elevator_link )
	{
		linker LinkTo( station_2_elevator );
	}

	// Move the elevator
	level.keene linkTo( station_2_elevator );
	level.tilman linkTo( station_2_elevator );

	// actually move the elevator
	station_2_elevator MoveZ( 204, 8, .05, 1 );
	
	thread audio_station2_pressurize();

	wait( 8 + 1 );

	// Open rear
	door_rear_r Unlink();
	door_rear_l Unlink();
	door_rear_r MoveY( -44, 3, .05, .5 );
	door_rear_l MoveY( 44, 3, .05, .5 );
	
	wait( 3 );
}

audio_station2_pressurize()
{

	level._player playsound( "nx_lunar_pressurize" );
	
	wait 1.5;	

	thread maps\_utility::set_ambient( "nx_lava_pressurized" );

	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_lava_pressurized", 5.5 );

	wait 3;

	level._player_helmet_loop = "amb_space_suit_null";

}

station_2_move_allies_to_elevator()
{
	flag_wait( "station_2_move_allies_to_elevator" );
	
	// Enable CQB
	level.keene enable_cqbwalk();
	level.tilman enable_cqbwalk();
	
	// move allies to elevator
	level.keene disable_ai_color();
	node = getNode( "station_2_elevator_keene_goal", "targetname" );
	level.keene SetGoalNode( node );
	
	wait( 2.0 );
	
	level.tilman disable_ai_color();
	node = getNode( "station_2_elevator_tillman_goal", "targetname" );
	level.tilman SetGoalNode( node );

	level.keene thread station_2_elevator_ready_check( "keene" );
	level.tilman thread station_2_elevator_ready_check( "tillman" );
	
	flag_wait( "station_2_elevator_ready_keene" );
	flag_wait( "station_2_elevator_ready_tillman" );
}

station_2_elevator_ready_check( name )
{
	self waittill( "goal" );
	flag_set( "station_2_elevator_ready_" + name );
}

link_elevator_door( link_to_name, link_name )
{
	link_array = GetEntArray( link_name, "targetname" );
	link_to = GetEnt( link_to_name, "script_noteworthy" );
	foreach( link in link_array )
	{
		link LinkTo( link_to );
	}
	
	return link_to;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

station_2_keene_standoff_vignette()
{
	flag_wait( "vignette_keene_standoff" );

	// tagTC<temp> - delete old allies until we get the character swap correct
	level.keene stop_magic_bullet_shield();
	level.tilman stop_magic_bullet_shield();
	level.keene delete();
	level.tilman delete();
	
	// Spawn actors for scene
	station_2_keene_standoff_spawn();
	
	skimmer = vignette_vehicle_spawn("keene_standoff_skimmer", "skimmer");

	// Station 2 glass
	level thread station_2_control_room_glass();
	
	// Play vignette
	maps\nx_lava_anim::keene_standoff( level.keene, level.baker, level.redshirt, skimmer );

	flag_set( "vignette_keene_standoff_done" );
	level thread autosave_now();
	
	skimmer vignette_vehicle_delete();
}

station_2_control_room_glass()
{
	wait( 17.5 );
	
	fx_origin = GetEnt( "station_2_depressurize_fx", "targetname" );
	PlayFX( getfx( "station_2_depressurize_fx" ), fx_origin.origin );
	
	glass_array = GetGlassArray( "station_2_control_room_glass" );

	thread audio_station2_depressurize();

	foreach( glass in glass_array )
	{
		DestroyGlass( glass );
	}
}

audio_station2_depressurize()
{

	level._player playsound("nx_lunar_depressurize");

	wait 0.5;

	thread maps\_utility::set_ambient( "nx_lunar_exterior_depress" );

	level._player deactivatechannelvolumes( "snd_channelvolprio_pain", 5.5 );
	
	wait 0.5;

	level._player_helmet_loop = "amb_space_suit_amb";	

}

station_2_keene_standoff_spawn()
{
	spawner = GetEnt( "keene_control_room_breach", "targetname" );
	spawner add_spawn_function( ::station_2_keene_standoff_spawn_func );
	level.keene = spawner spawn_ai();
	level.keene.animname = "keene";
	
	spawner = GetEnt( "baker_control_room_breach", "targetname" );
	spawner add_spawn_function( ::station_2_keene_standoff_spawn_func );
	level.baker = spawner spawn_ai();
	level.baker.animname = "baker";

	spawner = GetEnt( "redshirt_control_room_breach", "targetname" );
	spawner add_spawn_function( ::station_2_keene_standoff_spawn_func );
	level.redshirt = spawner spawn_ai();
	level.redshirt.animname = "redshirt";
}

station_2_keene_standoff_spawn_func()
{
	self endon( "death" );

	self maps\nx_lava_util::ally_protect();

	self thread magic_bullet_shield();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

bridge_to_train_VO()
{
	flag_wait( "vignette_keene_standoff_done" );
	
	//thread add_dialogue_line( "Keene", "Listen up! I know a way out of here but I don't got time to spell it out. You wanna keep breathin' long enough to finish this job?", "g" );
	radio_dialogue( "lava_kee_bridge_listenup" );
	wait( 1.0 );
	
	//thread add_dialogue_line( "Keene", "Follow me! We have to get on that train passing below!", "g" );
	radio_dialogue( "lava_kee_bridge_followme" );
	wait( 1.0 );
	
	//thread add_dialogue_line( "Baker", "You heard the man.", "w" );
	radio_dialogue( "lava_bak_bridge_heardtheman" );
	
	flag_wait( "vignette_bridge_to_train_jump" );
	
	wait( 4.0 );
	
	//thread add_dialogue_line( "Baker", "This is our ride, jump down!", "w" );
	radio_dialogue( "lava_kee_bridge_jumpdown" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

bridge_to_train_start()
{
	level._player TakeAllWeapons();
	level._player GiveWeapon( "lunarrifle" );
	level._player GiveWeapon( "spas12" );
	level._player SwitchToWeapon( "lunarrifle" );

	// Spawn the allies
	maps\nx_lava_util::lava_ally_spawn( "bridge_to_train" );

	// setup and teleport player
	maps\nx_lava_util::player_start( "bridge_to_train_player_start" );
}

bridge_to_train()
{
	level thread bridge_to_train_VO();
	level thread bridge_to_train_ally_protect();
	
	level.keene bridge_to_train_keene_thread();
	level.baker bridge_to_train_baker_thread();	

	level thread bridge_to_train_skimmers();
	level thread bridge_to_train_vignette();
	level thread bridge_to_trian_explosions();
	
	level thread bridge_to_train_player_kill();
	
	// Init infinte tunnel
	maps\nx_lava_train_interior::infinite_tunnel_init();
	
	// Wait for transport train start trigger
	trigger_wait( "lava_train_transport_trigger", "targetname" );
}

bridge_to_train_ally_protect()
{
	level.keene maps\nx_lava_util::ally_protect();
	level.baker maps\nx_lava_util::ally_protect();
}

bridge_to_train_vignette()
{
	flag_wait( "vignette_bridge_to_train_jump" );
	
	skimmer_01 = vignette_vehicle_spawn("bridge_to_train_skimmer_01", "skimmer_01");
	skimmer_02 = vignette_vehicle_spawn("bridge_to_train_skimmer_02", "skimmer_02");

	level.keene.animname = "keene";
	level.baker.animname = "baker";	
	maps\nx_lava_anim::bridge_to_train_jump( level.keene, level.baker, skimmer_01, skimmer_02 );
	
	level.keene stop_magic_bullet_shield();
	level.baker stop_magic_bullet_shield();
	level.keene delete();
	level.baker delete();
}

bridge_to_train_player_kill()
{
	while( 1 )
	{
		// Check distance from keene to player
		if( Distance( level.keene.origin, level._player.origin ) > 1000 )
		{
			PlayFX( getfx( "bridge_to_train_explosion" ), level._player.origin );
			Earthquake( 1, 1, level._player.origin, 100 );
			SetDvar( "ui_deadquote", &"NX_LAVA_BRIDGE_TO_TRAIN_FAIL" );
			level notify( "mission failed" );
			maps\_utility::missionFailedWrapper();
			level._player kill();
			break;
		}
		
		if( flag( "vignette_bridge_to_train_jump" ) )
		{
			break;
		}
		
		wait( 0.05 );
	}
}

bridge_to_train_skimmers()
{
	// Wait for skimmer spawn
	spawn_trigger = GetEnt( "spawn_bridge_to_train_skimmer", "targetname" );
	spawn_trigger waittill( "trigger" );

	skimmers = GetEntArray( spawn_trigger.target, "targetname" );
	foreach( skimmer_spawner in skimmers )
	{
		skimmer = skimmer_spawner maps\_attack_heli::SAV_setup( "pathing_shooting" );
		skimmer thread bridge_to_train_skimmers_spawn_func();
	}

	// Wait for skimmer spawn
	spawn_trigger = GetEnt( "spawn_bridge_to_train_skimmer_2", "targetname" );
	spawn_trigger waittill( "trigger" );

	skimmers = GetEntArray( spawn_trigger.target, "targetname" );
	foreach( skimmer_spawner in skimmers )
	{
		skimmer = skimmer_spawner maps\_attack_heli::SAV_setup( "pathing" );
		skimmer thread bridge_to_train_skimmers_2_spawn_func();
	}
}

bridge_to_trian_explosions()
{
	explosion_points = GetEntArray( "bridge_to_train_explosion", "targetname" );
	foreach( explosion_point in explosion_points )
	{
		explosion_point thread bridge_to_train_explosion_thread();
	}
}

bridge_to_train_explosion_thread()
{
	while( 1 )
	{
		if( Distance( self.origin, level._player.origin ) < self.radius )
		{
			// Do explosion
			Earthquake( 0.3, 2, level._player.origin, 10000 );
			playfx( getfx( "bridge_to_train_explosion" ), self.origin );
			break;
		}
		wait( 0.05 );
	}
}

bridge_to_train_skimmers_spawn_func()
{
	self endon( "death" );

	self Vehicle_SetSpeed( 18, 50, 50 );

	self.baseaccuracy = 0.0;
	
	flag_wait( "vignette_bridge_to_train_jump" );

	wait( 10.0 );
	
	self delete();
}

bridge_to_train_skimmers_2_spawn_func()
{
	self endon( "death" );

	self Vehicle_SetSpeed( 40, 50, 50 );

	self.baseaccuracy = 0.0;
	
	flag_wait( "vignette_bridge_to_train_jump" );

	wait( 10.0 );
	
	self delete();
}

bridge_to_train_keene_thread()
{
	self disable_cqbwalk();
	
	self set_force_color( "c" );	
}

bridge_to_train_baker_thread()
{
	self disable_cqbwalk();

	self set_force_color( "b" );	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

