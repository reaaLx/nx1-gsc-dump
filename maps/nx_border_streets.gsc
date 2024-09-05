//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module: Border, Streets												**
//                                                                          **
//    Created: 11/11/11 - Travis Chen (trchen x 4143)						**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_nx_utility;
#include maps\_vehicle;
#include maps\_anim;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
	// Helicopter support
	level._player thread streets_helicopter_support_thread();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
	PrecacheItem( "rpg_straight" );

	// Press^3 [{+actionslot 3}] ^7to use\nmark area for helicopter support.
	add_hint_string( "helicopter_support", &"NX_BORDER_LEARN_HELICOPTER_SUPPORT", ::remove_helicopter_support_hint_string );
}

section_flag_inits()
{
	flag_init( "intro_turret_destroyed" );
	flag_init( "street_hummer_end" );
	flag_init( "streets_intro_1_end" );
	flag_init( "streets_intro_2_end" );
	flag_init( "streets_intro_finished" );
	flag_init( "helicopter_support_streets_middle" );
	flag_init( "player_used_helicopter_support" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_objectives( objective_num )
{
	flag_wait( "player_through_border" );

	objective_add( objective_num, "current", &"NX_BORDER_OBJECTIVE_STREETS" );			

	flag_wait( "vo_reroutingmarket" );
	objective_complete( objective_num );
	objective_num++;
	
	objective_add( objective_num, "current", &"NX_BORDER_OBJECTIVE_MARKET" );			
	flag_wait( "flag_market_objective_complete" );	
	objective_complete( objective_num );

	objective_num++;
	
	return objective_num;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

streets_vo()
{
	level._player waittill( "heli_support_active" );
	flag_wait( "vo_border_section_done");
	level.leader dialogue_queue( "bor_bak_streets_veh12markit" );
	
	level thread team1_team2_vo();
	level thread back_alley_vo();
	
	flag_wait( "flag_streets_hummer_roll_in" );
	
	level.leader dialogue_queue( "bor_bak_market_enemyhumvee" );
	
	wait( 9 );
	
	level.leader dialogue_queue( "bor_bak_streets_churchendofstreet" );
	
	flag_wait( "vo_reroutingmarket" );	
	
	// Turn off helicopter support
	trigger = GetEnt( "helicopter_support_off_end_streets", "script_noteworthy" );
	trigger notify( "trigger" );
	
	radio_dialogue( "bor_oly_market_cartelleaving" );	
	level.leader dialogue_queue( "bor_bak_streets_reroutingmarket" );	
	radio_dialogue( "bor_oly_streets_rogerthat" );
}

team1_team2_vo()
{
	flag_wait( "vo_team1_team2" );
	
	level.leader dialogue_queue( "bor_bak_streets_goleftintersection" );
	level.leader dialogue_queue( "bor_bak_streets_team1takestreet" );
	level.leader dialogue_queue( "bor_bak_streets_team2backalley" );	
}

hummer_roll_in_vo()
{
}

back_alley_vo()
{
	flag_wait( "vignette_curtain_pull" );
	
	level.leader dialogue_queue( "bor_bak_streets_enemy2ndflrwindow" );	
	
	flag_wait( "vo_clearbldng" );
	
	level.leader dialogue_queue( "bor_bak_streets_clearbldng" );	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

streets_start()
{
	flag_set( "player_through_border" );
	maps\nx_border_util::player_start( "player_start_streets" );
	
	// Spawn the vehicles
	// maps\nx_border_border::spawn_convoy_vehicles_and_allies();
	
	// Border ally spawn
	ally_starts = GetStructArray( "ally_start_streets", "targetname" );
	maps\nx_border_util::spawn_allies( ally_starts );
	
	// Give initial color orders
	issue_color_orders( "r100", "allies" );
	issue_color_orders( "y100", "allies" );

	createthreatbiasgroup( "heli_support_axis_1" );
	createthreatbiasgroup( "heli_support_axis_2" );
}

// Clear razor wire from border border
clear_razor_wire()
{
	wires = GetEntArray( "model_razorwire", "script_noteworthy" );
	Assert( IsDefined( wires ));

	wire_brush = GetEnt( "brushmodel_razorwire", "targetname" );
	Assert( IsDefined( wire_brush ));

	foreach( wire in wires )
	{
		wire Delete();
	}
	
	wire_brush ConnectPaths();
	wire_brush Delete();
}


streets()
{
	// Wait for player to pass border
	flag_wait( "player_through_border" );
	
	level thread streets_vo();
	
	// Convoy push
	// level thread streets_convoy_push();
	
	// Streets hummer roll in
	level thread streets_intro_roll_in();
	level thread streets_hummer_roll_in();
	
	// Border ally spawn (extra enemy and setup)
	level thread border_ally_spawn();
	level thread border_ally_setup();
	
	// Clean up
	level thread street_ai_cleanup();
	
	// Vignettes 
	level thread streets_vignettes();
	
	// Enemy Spawn Func
	level thread streets_enemy_spawn_funcs();
	
	// Save thread
	level thread streets_save_thread();

	thread maps\nx_border_fx::fx_street_tumbleweed();
	Exploder( "fx_street_smoke" );

	// Ally battle chatter
	battlechatter_on( "allies" );
}

streets_save_thread()
{
	flag_wait( "intro_turret_destroyed" );
	autosave_by_name( "intro_turret_destroyed" );	
}

border_ally_setup()
{
	// Make sure allies are spawned and colors set up
	wait( 1.0 );
	
	allies = GetAIArray( "allies" );
	
	streets_red_allies = [];
	streets_yellow_allies = [];
	
	CreateThreatBiasGroup( "streets_yellow_allies" );
	CreateThreatBiasGroup( "streets_red_allies" );
	CreateThreatBiasGroup( "player" );
	level._player SetThreatBiasGroup( "player" );
	
	foreach( i, ally in allies )
	{
		if( IsDefined( ally.script_forcecolor ) && ally.script_forcecolor == "y" )
		{
			streets_red_allies[ streets_red_allies.size ] = ally;
			ally SetThreatBiasGroup( "streets_red_allies" );
		}
		else if( IsDefined( ally.script_forcecolor ) && ally.script_forcecolor == "r" )
		{
			streets_yellow_allies[ streets_yellow_allies.size ] = ally;
			ally SetThreatBiasGroup( "streets_yellow_allies" );
		}
	}

	level.street_red_allies = streets_red_allies;
	level.street_yellow_allies = streets_yellow_allies;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

streets_convoy_push()
{
	level.vehicle_convoy[ "vehicle_convoy_1" ] thread streets_convoy_push_shared( "streets_vehicle_convoy_1_start", true );
	level.vehicle_convoy[ "vehicle_convoy_2" ] thread streets_convoy_push_shared( "streets_vehicle_convoy_2_start" );
}

streets_convoy_push_shared( start_node_name, stop_nodes )
{
	vehicle_speed = 5;
		
	// tagBMarv Continue path if not default start, otherwise teleport
	if( ( level._start_point != "default" ) && ( level._start_point != "border" ))
	{
		// Setup start of path and move
		path = GetVehicleNode( start_node_name, "targetname" );

		// tagTC<temp> - for now, teleport vehicle to start point
		self vehicle_teleport( path.origin, path.angles );
	
		// Start path
		self AttachPath( path );
		self Vehicle_SetSpeed( vehicle_speed, 2 );	
		self StartPath();
	}
	else
	{
		self Vehicle_SetSpeed( vehicle_speed, 2 );
	}

	// Run stop node logic
	if( IsDefined( stop_nodes ) && stop_nodes )
	{		
		stop_node_array = [ "streets_convoy_stop_1", "streets_convoy_stop_2", "streets_convoy_stop_3", "streets_convoy_stop_4" ];
		self thread streets_convoy_stop_nodes( stop_node_array, vehicle_speed );
	}
}

streets_convoy_stop_nodes( stop_node_array, speed )
{
	level.vehicle_convoy[ "vehicle_convoy_1" ] thread maps\nx_border_util::actor_detection_movement_control( 300, 45 );
	level.vehicle_convoy[ "vehicle_convoy_2" ] thread maps\nx_border_util::actor_detection_movement_control( 300, 45 );

	foreach( stop_node_name in stop_node_array )
	{	
		stop_node = GetVehicleNode( stop_node_name, "targetname" );
		self vehicle_waittill_node( stop_node_name, "targetname" );

		level.vehicle_convoy[ "vehicle_convoy_1" ] notify ( "terminate_actor_detection" );
		level.vehicle_convoy[ "vehicle_convoy_2" ] notify ( "terminate_actor_detection" );
		
		// Stop both vehicles
		level.vehicle_convoy[ "vehicle_convoy_1" ] Vehicle_SetSpeed( 0, 10 );
		level.vehicle_convoy[ "vehicle_convoy_2" ] Vehicle_SetSpeed( 0, 10 );

		flag_wait( stop_node.script_flag );
		
		// Start both vehicles
		level.vehicle_convoy[ "vehicle_convoy_1" ] thread maps\nx_border_util::actor_detection_movement_control( 300, 45 );
		level.vehicle_convoy[ "vehicle_convoy_2" ] thread maps\nx_border_util::actor_detection_movement_control( 300, 45 );

		level.vehicle_convoy[ "vehicle_convoy_1" ] ResumeSpeed( speed );
		level.vehicle_convoy[ "vehicle_convoy_2" ] ResumeSpeed( speed );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

border_ally_spawn()
{
	spawn_starting_friendlies( "friendly_starting_spawner" );
}

spawn_starting_friendlies( sTargetname )
{
	spawners = getentarray( sTargetname, "targetname" );
	for ( i = 0 ; i < spawners.size ; i++ )
	{
		friend = spawners[ i ] stalingradSpawn();
		if ( spawn_failed( friend ) )
			assertMsg( "A friendly failed to spawn" );

		friend thread ally_bullet_shield();
		friend.goalradius = 32;
	}

	array_thread( getaiarray( "allies" ), ::replace_on_death );
}

ally_bullet_shield()
{
	self magic_bullet_shield();
	
	// tagTC<note> - Remove magic bullet shield when turret is destroyed 
	// or player has pushed through the intro blockade section
	flag_wait_either( "intro_turret_destroyed", "player_through_intro_funnel" );
	
	// Stop magic bullet shield except on baker
	if( self != level.leader )
	{
		self stop_magic_bullet_shield();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

street_ai_cleanup()
{
	level thread linked_spawn_triggers_cleanup();
	level thread balcony_cleanup();
	
	flag_wait( "streets_first_half_cleanup" );
	
	kill_deathflag( "streets_enemies_first_half_death_flag", 2 );
	kill_deathflag( "streets_enemy_01", 2 );
	kill_deathflag( "streets_enemy_balcony" );
	
	flag_wait( "streets_second_half_cleanup" );
	
	kill_deathflag( "streets_enemies_second_half_death_flag", 2 );	
}

balcony_cleanup()
{
	flag_wait( "helicopter_support_streets_middle" );
	kill_deathflag( "streets_enemy_balcony" );	
}

linked_spawn_triggers_cleanup()
{
	level thread linked_spawn_triggers( "linked_spawn_triggers_1" );
	level thread linked_spawn_triggers( "linked_spawn_triggers_2" );
}

linked_spawn_triggers( linked_name )
{
	trigger_array = GetEntArray( linked_name, "script_noteworthy" );
	foreach( trigger in trigger_array )
	{
		trigger thread linked_spawn_triggers_thread( linked_name );
	}
	
	level waittill( linked_name );

	foreach( trigger in trigger_array )
	{
		trigger trigger_off();
	}
}

linked_spawn_triggers_thread( linked_name )
{
	level endon( linked_name );
	self waittill( "trigger" );
	level notify( linked_name );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

streets_vignettes()
{
//	// tagTC<note> shit's broken with this guy..
//	level thread bar_hop_vignette();
}

bar_hop_vignette()
{
	flag_wait( "vignette_barhop" );

	spawner = GetEnt( "vignette_bar_hop_enemy", "targetname" );
	opfor = spawner spawn_ai();
	opfor.animname = "generic";
	opfor.goalradius = 32;
	
	maps\nx_border_anim::bar_hop( opfor );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

streets_enemy_spawn_funcs()
{	
	// Enemy retreat
	level thread streets_enemy_01();
	level thread streets_enemy_02();
	level thread streets_enemy_03();
	level thread streets_enemy_03_balcony();
	level thread streets_enemy_02_flank();
	level thread streets_enemy_restaurant_guy();
	
	// Hiding doors
	level thread streets_enemy_hiding_door();
	
	// RPG
	level thread streets_enemy_rpg();
}

streets_enemy_01()
{
	spawners = GetEntArray( "streets_enemy_01", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, ::streets_enemy_01_spawn_func );
}

streets_enemy_02()
{
	spawners = GetEntArray( "streets_enemy_02", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, ::streets_enemy_02_spawn_func );
}

streets_enemy_03()
{
	spawners = GetEntArray( "streets_enemy_03", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, ::streets_enemy_03_spawn_func );
}

streets_enemy_03_balcony()
{
	spawners = GetEntArray( "streets_enemy_03_balcony", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, ::streets_enemy_03_balcony_spawn_func );
}

streets_enemy_02_flank()
{
	CreateThreatBiasGroup( "street_enemy_02_flank" );
	spawners = GetEntArray( "streets_enemy_02_flank", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, ::street_enemy_02_flank_spawn_func );
}

streets_enemy_restaurant_guy()
{
	spawners = GetEntArray( "streets_enemy_restaurant_guy", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, ::streets_enemy_restaurant_guy_spawn_func );
}

streets_enemy_restaurant_guy_spawn_func()
{
	self endon( "death" );
	CreateThreatBiasGroup( "restaurant_guy" );
	self SetThreatBiasGroup( "restaurant_guy" );
	
	self.ignoreall = true;
	setThreatBias( "restaurant_guy", "player", -15000 );
	
	self waittill( "goal" );

	self.ignoreall = false;
}

streets_enemy_01_spawn_func()
{
	self endon( "death" );
	
	flag_wait( "streets_enemy_01_retreat" );
	
	vol = GetEnt( "streets_01_retreat_building", "targetname" );
	self SetGoalVolumeAuto( vol );
}

streets_enemy_02_spawn_func()
{
	self endon( "death" );
	
	flag_wait( "streets_enemy_02_retreat" );
	
	vol = GetEnt( "streets_02_retreat_building", "targetname" );
	self SetGoalVolumeAuto( vol );
	
	self thread streets_enemy_03_spawn_func();
}

streets_enemy_03_spawn_func()
{
	self endon( "death" );
	
	flag_wait( "streets_enemy_03_retreat" );
	
	vol = GetEnt( "courtyard_volume", "targetname" );
	self SetGoalVolumeAuto( vol );
}

streets_enemy_03_balcony_spawn_func()
{
	self endon( "death" );

	level thread radio_dialogue( "bor_bak_streets_enemiesonbalcony" );
	
	//self thread streets_enemy_03_spawn_func();
}

street_enemy_02_flank_spawn_func()
{
	self endon( "death" );
	self SetThreatBiasGroup( "street_enemy_02_flank" );
		
	setThreatBias( "street_enemy_02_flank", "streets_yellow_allies", -1000 );
	setThreatBias( "street_enemy_02_flank", "streets_red_allies", 100 );
	setThreatBias( "street_enemy_02_flank", "player", 1000 );

	self thread streets_enemy_02_spawn_func();
}

streets_enemy_hiding_door()
{
	spawner = GetEnt( "hiding_door_video_store", "targetname" );
	spawner add_spawn_function( ::hiding_door_video_store );

	spawner = GetEnt( "hiding_door_back_alley", "targetname" );
	spawner add_spawn_function( ::hiding_door_back_alley );

	spawner = GetEnt( "hiding_door_corner_building", "targetname" );
	spawner add_spawn_function( ::hiding_door_corner_building );
}

hiding_door_video_store()
{
	self endon( "death" );
	flag_wait( "hiding_door_video_store_kill" );
	self Kill();
}

hiding_door_back_alley()
{
	self endon( "death" );

	self waittill( "quit_door_behavior" );
	
	self.goalradius = 64;
	self.script_forcegoal = true;
		
	goal_node = GetNode( "hiding_door_back_alley_goal",  "targetname" );
	self SetGoalNode( goal_node );

	flag_wait( "hiding_door_back_alley_kill" );
	self Kill();
}

hiding_door_corner_building()
{
	self endon( "death" );
	flag_wait( "hiding_door_corner_building_kill" );
	self Kill();
}

streets_enemy_rpg()
{
	level endon( "kill_rooftop_rpg" );
	
	rpg_1 = GetEnt( "streets_rooftop_rpg_1", "script_noteworthy" );
	rpg_1 add_spawn_function( ::streets_rooftop_rpg_1_spawn_func );

	rpg_2 = GetEnt( "streets_rooftop_rpg_2", "script_noteworthy" );
	rpg_2 add_spawn_function( ::streets_rooftop_rpg_2_spawn_func );	
	
	flag_wait( "player_used_helicopter_support" );
	wait( 4.85 );

	if( IsDefined( rpg_2 ) )
	{
		rpg_2_enemy = rpg_2 spawn_ai();
		rpg_2_enemy waittill( "death" );
	}

	if( IsDefined( rpg_1 ) )
	{
		level thread streets_enemy_rpg_vo();
		rpg_1 spawn_ai();
	}
}

streets_enemy_rpg_vo()
{
	wait( 0.0 );	
	level.leader dialogue_queue( "bor_bak_streets_rpgsgetcover" );	
}

#using_animtree( "generic_human" );
streets_rooftop_rpg_1_spawn_func()
{
	self endon( "death" );
	self.health = 5;
	
	flag_wait( "kill_rooftop_rpg" );
	self Kill();
}

streets_rooftop_rpg_2_spawn_func()
{
	self endon( "death" );
	self.health = 5;
	
	self thread streets_rooftop_rpg_2_heli_unload();
	
	flag_wait( "kill_rooftop_rpg" );
	self Kill();
}

streets_rooftop_rpg_2_heli_unload()
{
	self endon( "death" );
	
	level waittill( "helicopter_support_unloaded" );
	self Kill();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

streets_intro_roll_in()
{
	// Put spawn func on spawners
	spawners = GetEntArray( "streets_intro_1_enemies", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, ::streets_intro_1_enemies_spawn_func );

	spawners = GetEntArray( "streets_intro_2_enemies", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, ::streets_intro_2_enemies_spawn_func );

	// Blocker
	blocker = GetEnt( "intro_funnel_block", "targetname" );
	blocker DisconnectPaths();
	
	// Wait till player is in area
	flag_wait( "flag_streets_intro_roll_in" );
	
	// Spawn streets hummer
	level thread maps\nx_border_market::spawn_enemy_vehicle( "streets_intro_1", "streets_intro_1", "streets_intro_1_end" );
	//putting hummer sfx here
	level.enemy_vehicles[ "streets_intro_1" ] playsound ("scn_border_enmy_hmve_rollin_01");	
	wait( 0.5 );
	level thread maps\nx_border_market::spawn_enemy_vehicle( "streets_intro_2", "streets_intro_2", "streets_intro_2_end" );
	
	level.enemy_vehicles[ "streets_intro_1" ].health = 10;
	level.enemy_vehicles[ "streets_intro_2" ].dontunloadonend = true;
	level.enemy_vehicles[ "streets_intro_2" ].health = 10;
	level.enemy_vehicles[ "streets_intro_2" ].mgturret[0].baseaccuracy = 0.05;
	
	level.enemy_vehicles[ "streets_intro_2" ] waittill( "death" );
	
	// Delete the ai full blocker
	blocker ConnectPaths();
	blocker Delete();

	intro_allies_move = GetEnt( "intro_allies_move", "targetname" );
	if( IsDefined( intro_allies_move ) )
	{
		intro_allies_move Delete();
	}
	
	flag_set( "intro_turret_destroyed" );
	if( !flag( "player_through_intro_funnel" ) )
	{
		// Color orders for squad
		issue_color_orders( "r101", "allies" );
		issue_color_orders( "y101", "allies" );
	}
}

streets_intro_1_enemies_spawn_func()
{
	self endon( "death" );
	
	self waittill( "unload" );
	
	self SetGoalVolumeAuto_targetname( "intro_volume" );
}

streets_intro_2_enemies_spawn_func()
{
	self endon( "death" );
	
	self SetGoalVolumeAuto_targetname( "intro_volume" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

streets_hummer_roll_in()
{
	// Put spawn func on spawners
	spawners = GetEntArray( "streets_hummer_spawners", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, ::streets_hummer_spawn_func );

	// Wait till player is in area
	flag_wait( "flag_streets_hummer_roll_in" );
	
	level thread streets_hummer_rollin_move_enemies();
	
	// Allow air support
	flag_set( "helicopter_support_hint" );
	flag_set( "streets_intro_finished" );
	
	// Spawn streets hummer
	level thread maps\nx_border_market::spawn_enemy_vehicle( "streets_hummer_1", "streets_hummer_1", "street_hummer_end" );
	//maps\nx_border_market::spawn_enemy_vehicle( "streets_hummer_2", "streets_hummer_2", "street_hummer_end" );
	//putting hummer sfx here
	
	level.enemy_vehicles[ "streets_hummer_1" ] playsound ("scn_border_enmy_hmve_rollin_02");	
}

streets_hummer_spawn_func()
{
	self endon( "death" );
	
	self waittill( "unload" );
	
	self SetGoalVolumeAuto_targetname( "courtyard_volume" );
}

streets_hummer_rollin_move_enemies()
{
	waittill_aigroupcleared( "hummer_rollin_enemies" );

	if( IsDefined( level.heli_support_turret_guy ) && IsAlive( level.heli_support_turret_guy ) )
	{
		// level waittill( "helicopter_support_unloaded" );
		wait( 1.0 );
	}
	
	flag_set( "vo_reroutingmarket" );

	triggers = GetEntArray( "hummer_rollin_done_triggers", "targetname" );
	foreach( trigger in triggers )
	{
		if( IsDefined( trigger ) ) 
		{
			trigger trigger_off();
		}
	}
	
	wait( 0.05 );
	
	// Give initial color orders
	issue_color_orders( "r110", "allies" );
	issue_color_orders( "y108", "allies" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

streets_helicopter_support_thread()
{
	self waittill( "heli_support_active" );
//	self endon( "heli_support_inactive" );
	
//	self thread streets_helicopter_support_inactive();
	
	flag_wait( "helicopter_support_hint" );
	flag_clear( "helicopter_support_hint" );
		
	nag_wait = true;
	while( 1 )
	{
		// Press^3 [{+actionslot 3}] ^7to use\nmark area for helicopter support.
		display_hint_timeout( "helicopter_support", 5 );
		RefreshHudAmmoCounter();
		
		self thread streets_helicopter_support_nag_thread( nag_wait );
		self thread streets_helicopter_support_incoming_thread();
		
		// Wait for hint trigger
		flag_wait( "helicopter_support_hint" );
		flag_clear( "helicopter_support_hint" );
		flag_clear( "player_used_helicopter_support" );
	
		// Activate helicopter again
		//level thread radio_dialogue( lines[ RandomInt( lines.size ) ] );
		level notify( "activate_helicopter_support" );
		level._player.remainingHeliSupportCount = 1;

//		// Wait random time before allowing air support again
//		random_wait = RandomIntRange( 20, 25 );
//		wait( random_wait );

//		// Activate helicopter again
//		level notify( "activate_helicopter_support" );
//		level._player.remainingHeliSupportCount = 1;
		nag_wait = false;
	}
}

remove_helicopter_support_hint_string()
{
	if ( isDefined ( self.airdropMarkerInHand ) && ( self.airdropMarkerInHand == true ))
	{
		return true;
	}
	else if( ! flag( "player_used_helicopter_support" ) )
	{
		return false;
	}
	return true;
}

streets_helicopter_support_inactive()
{
	self waittill( "heli_support_inactive" );
	
	//add_dialogue_line( "Eagle One", "Enemy attack helis are approaching from the south Pather One. You're on your own until the airspace is clear." );
	level thread radio_dialogue( "bor_eag_airdrop_helisfromsouth" );
}

streets_helicopter_support_nag_thread( nag_wait )
{
	self endon( "use air support grenade" );
	self endon( "heli_support_inactive" );
	
//	lines = [];
//	lines[ lines.size ] = "Jackson, throw some smoke!";
//	lines[ lines.size ] = "Jackson, we need support! Mark the drop point with smoke!";

	lines = [];
	lines[ lines.size ] = "bor_bak_airdrop_throwsmoke";
	lines[ lines.size ] = "bor_bak_airdrop_markdrop";
	
	while( 1 )
	{
		foreach( line in lines )
		{
			if( nag_wait )
			{
				wait( RandomIntRange( 15, 25 ) );
			}
			level thread radio_dialogue( line );
			nag_wait = true;
		}
	}
}

streets_helicopter_support_incoming_thread()
{
	self endon( "heli_support_inactive" );
	

	level waittill( "helicopter_support_inbound" );
	flag_set( "player_used_helicopter_support" );

    //tagJC<NOTE>: Shooting magic bullets at the corner building to trigger the exploder
	target = getent("heli_support_target_corner_building", "script_noteworthy");
	for ( i = 0; i < 10; i++)
	{
		randomX = RandomFloatRange ( -10, 10 );
		randomY = RandomFloatRange ( -10, 10 );
		randomZ = RandomFloatRange ( -10, 10 );

		MagicBullet( "nx_turret_blackhawk_ai", level.heli_support_turret.origin + (0, 0, 300), target.origin + (randomX, randomY, randomZ) );

		if ( i == 5 )
		{
			// Swap geo.
			Exploder( "corner_building_exploder" );
		}

		wait ( 0.2 );
	}

	if( IsDefined( level.enemy_vehicles ) && IsDefined( level.enemy_vehicles[ "streets_intro_2" ] ) && !flag( "streets_intro_finished" ) )
	{
		level.enemy_vehicles[ "streets_intro_2" ] thread target_streets_intro_humvee();
	}
	else if( flag( "flag_streets_hummer_roll_in" ) )
	{
		level thread target_streets_middle();
	}
		
	level waittill( "helicopter_support_unloaded" );

	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

humvee_explode_failsafe()
{
	wait( 3.5 );
	self force_kill();
}

target_streets_intro_humvee()
{
	// Start failsafe
	self thread humvee_explode_failsafe();
	
	vehicle_target = spawn( "script_origin", self.origin );
	level.heli_support_turret SetTargetEntity( vehicle_target );

	flag_wait( "intro_turret_destroyed" );
	
	target = getent("heli_support_target_2", "script_noteworthy");
	level.heli_support_turret SetTargetEntity( target );
	
	level waittill( "helicopter_support_unloaded" );
	flag_set( "streets_intro_finished" );

	wait( 1.0 );
	
	level.heli_support_turret ClearTargetEntity();
	level.heli_support_turret_guy.ignoreall = true;
}

target_streets_middle()
{
	flag_set( "helicopter_support_streets_middle" );
	
	target = getent( "heli_support_target_streets_middle", "script_noteworthy" );
	//level.heli_support_turret SetTargetEntity( target );

	level waittill( "helicopter_support_unloaded" );
	
	flag_clear( "helicopter_support_streets_middle" );
	
	level.heli_support_turret ClearTargetEntity();
	level.heli_support_turret_guy.ignoreall = true;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
