
//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_ROCKET_SECTION_											**
//                                                                          **
//    Created: 7/13/2011 - 													**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


ORDER_AXIS_WAREHOUSE				= "o220";
ORDER_AXIS_FRONT 					= "p220";	// PURPLE
ORDER_AXIS_LEFT_GROUND				= "g220";	// GREEN
ORDER_AXIS_LEFT_CATWALK				= "y220";	// YELLOW
ORDER_AXIS_RIGHT_GROUND				= "r220";	// RED
ORDER_AXIS_RIGHT_CATWALK			= "b220";	// BLUE

ORDER_AXIS_ALL	 		= ORDER_AXIS_WAREHOUSE + " " 
						+ ORDER_AXIS_FRONT + " " 
						+ ORDER_AXIS_LEFT_GROUND + " " 
						+ ORDER_AXIS_LEFT_CATWALK + " " 
						+ ORDER_AXIS_RIGHT_GROUND + " "
						+ ORDER_AXIS_RIGHT_CATWALK;

DEBUG_WAVE_INFO = false;

//*******************************************************************
//                                                                  *
//*******************************************************************
start()
{
	teleport_info = [];
	teleport_info[ "ALLY_BAKER" ]		= "start_default_ally_00";
	teleport_info[ "ALLY_JENKINS" ]		= "start_rescue_ally_01";
	teleport_info[ "ALLY_WILLIAMS" ]	= "start_rescue_ally_02";
	maps\nx_rocket_util::squad_teleport( teleport_info );
	level._player maps\_nx_utility::move_player_to_start_point( "start_rescue_player" );

	// Turn on post AA turret smoke and destruction
	maps\nx_rocket_util::post_turret_event();

	flag_set( "turret_control_complete" );
	maps\nx_rocket_fx::forest_fire_fx();


	// This is here as a fall through untill this section is created
}

main()
{
	level thread section_dialogue();

	level thread objective_defend();

	//ambience
	thread maps\_utility::set_ambient( "nx_rocket_ext" );

	// SAVE POINT
	level thread autosave_now();
	
	issue_color_orders( "b200 p200", "allies" );

	// Begin safe-zone checking
//  level._player thread player_safe_zone();

	// WAREHOUSE ENEMIES
	wave_warehouse();

	flag_set( "defend_start" );

	// WAVE 01
	wave_01();

	// WAVE 02
	wave_02();

	// WAVE 03
	wave_03();

	// WAVE 04
	wave_04();

	// WAVE 05
	wave_05();

	flag_wait( "rescue_chopper_allies_loaded" );

	// Rescue!!!
//  chopper_rescue();

//  flag_set( "rescue_arrived" );
}

// Warehouse enemies pre-wave /////////////////////////////////////////

wave_warehouse()
{
	debug_wave_info( "Wave 00", "Warehouse Ground Troops" );

	// Set allies to ignore all enemies until we reach the warehouse
//  ignore_everything_array( level.squad, true);
//  wait 0.05;

	warehouse_enemies = maps\nx_rocket_util::spawn_ai_group( "enemy_group_rescue_warehouse_01", "script_noteworthy" );
	array_thread( warehouse_enemies, maps\nx_rocket_util::ignore_until_damage_group, warehouse_enemies );
	array_thread( warehouse_enemies, maps\nx_rocket_util::ignore_until_flag, "rescue_encounter_start" );

//  ignore_everything_array( warehouse_enemies_01, true );
//  issue_color_orders( "o220", "axis" );


//  flag_wait( "rescue_encounter_start" );
//  flag_wait( "rescue_encounter_start" );


	//SAVE POINT
	level thread autosave_now();

//  ignore_everything_array( level.squad, false );
//  ignore_everything_array( warehouse_enemies_01, false );
//  issue_color_orders( "o220", "axis" );
	waittill_aigroupcount( "enemy_group_rescue_warehouse_01", 2 );

//  warehouse_enemies_02 = maps\nx_rocket_util::spawn_ai_group( "enemy_group_rescue_warehouse_02", "script_noteworthy" );
//  issue_color_orders( "o220", "axis" );
//  waittill_aigroupcount( "enemy_group_rescue_warehouse_01", 1 );
//  waittill_aigroupcount( "enemy_group_rescue_warehouse_02", 1 );
}

wave_01()
{
	flag_set( "wave_01_start" );

	debug_wave_info( "Wave 01", "Ground Troops" );

	//SAVE POINT
	level thread autosave_now();

	// Wave 01 /////////////////////////////////////////
	issue_color_orders( "b230 p230", "allies" );

	wave_01_enemies = maps\nx_rocket_util::spawn_ai_group( "enemy_group_rescue_01_01", "script_noteworthy" );
	issue_color_orders( ORDER_AXIS_ALL, "axis" );
	waittill_aigroupcount( "enemy_group_rescue_01_01", 4 );

	//SAVE POINT
	level thread autosave_now();

	jeep_01 = vehicle_spawn( GetEnt( "rescue_jeep_01", "targetname" ) );
	jeep_01 thread jeep_update();

	waittill_aigroupcount( "enemy_group_rescue_01_01", 3 );
	waittill_aigroupcount( "enemy_group_rescue_01_02", 3 );

}

wave_02()
{
	flag_set( "wave_02_start" );

	debug_wave_info( "Wave 02", "Ground Troops" );

	//SAVE POINT
	level thread autosave_now();

	enemies_right = maps\nx_rocket_util::spawn_ai_group( "enemy_group_rescue_02_01", "script_noteworthy" );
	waittill_aigroupcount( "enemy_group_rescue_02_01", 4 );
	
	enemies_left = maps\nx_rocket_util::spawn_ai_group( "enemy_group_rescue_02_02", "script_noteworthy" );
	waittill_aigroupcount( "enemy_group_rescue_02_01", 3 );
	waittill_aigroupcount( "enemy_group_rescue_02_02", 3 );
}

wave_03()
{
	flag_set( "wave_03_start" );

	debug_wave_info( "Wave 03", "Two Jeeps, 4 Ground Troops Each" );

	//SAVE POINT
	level thread autosave_now();

	jeep_02 = vehicle_spawn( GetEnt( "rescue_jeep_02", "targetname" ) );
	jeep_02 thread jeep_update();

	wait 3.0;
	
	jeep_01 = vehicle_spawn( GetEnt( "rescue_jeep_03", "targetname" ) );
	jeep_01 thread jeep_update();

	waittill_aigroupcount( "enemy_group_rescue_03_01", 3 );
	waittill_aigroupcount( "enemy_group_rescue_03_02", 3 );	
}

wave_04()
{
	flag_set( "wave_04_start" );

	debug_wave_info( "Wave 04", "VTOL and Hummer" );

	//SAVE POINT
	level thread autosave_now();
	
	vtol = vehicle_spawn( GetEnt( "rescue_vtol_01", "targetname" ) );
	vtol GodOn();
	vtol thread vtol_update();
	vtol waittill( "reached_dynamic_path_end" );
	flag_set( "vtol_enter" );


	//SAVE POINT
	level thread autosave_now();

	hummer = vehicle_spawn( GetEnt( "rescue_hummer_01", "targetname" ) );
	level.rescue_hummer = hummer;
	hummer godon();
	hummer thread hummer_update();
	flag_wait( "hummer_enter" );


	flag_wait( "hummer_mounted" );
	vtol GodOff();
	vtol waittill( "death" );

	// Blow up the hummer!!!
	level._player EnableInvulnerability();

	expl_origin = vtol.origin;
	for( i = 0; i < 12; i++ )
	{
		MagicBullet( "rpg", expl_origin, expl_origin + ( RandomFloatRange( -1000, 1000 ), RandomFloatRange( -1000, 1000 ), RandomFloatRange( -1000, 1000 ) ) );
		wait RandomFloatRange( 0.1, 0.3 );
	}

	hummer GodOff();
	hummer.health = 100;

	MagicBullet( "rpg_straight", expl_origin, level._player.origin );
	MagicBullet( "rpg_straight", expl_origin, hummer.origin );
	
	hummer thread hummer_wait_then_die();// TEMP KILL HUMMER
	hummer waittill( "death" );

	level._player DisableInvulnerability();
//  hummer_player_dismount();
	level._player Unlink();
	level._player SetOrigin( Getent( "rescue_vtol_destroy_player_origin", "targetname" ).origin );
}

wave_05()
{
	flag_set( "wave_05_start" );

	debug_wave_info( "Wave 05 (FINAL)", "APC, Ground Troops, Rescue" );

	//SAVE POINT
	level thread autosave_now();

	// APC
	apc = vehicle_spawn( GetEnt( "rescue_apc_01", "targetname" ) );
	apc thread apc_update();
	
	// JEEPS
	wait 0.75;
	jeep_01 =  vehicle_spawn( GetEnt( "rescue_jeep_04", "targetname" ) );
	jeep_01 thread jeep_update();
	wait 0.1;
	jeep_02 = vehicle_spawn( GetEnt( "rescue_jeep_05", "targetname" ) );
	jeep_02 thread jeep_update();
	wait 0.75;
	jeep_03 = vehicle_spawn( GetEnt( "rescue_jeep_06", "targetname" ) );
	jeep_03 thread jeep_update();
	wait 0.1;
	jeep_04 = vehicle_spawn( GetEnt( "rescue_jeep_07", "targetname" ) );
	jeep_04 thread jeep_update();

	wait 3.0;
	// CHOPPER
	level notify( "rescue_baker_landed" );
	flag_set( "rescue_chopper_arrived" );

	level.rescue_heli = vehicle_spawn( GetEnt( "rescue_heli", "targetname" ) );

	leader = level.squad[ "ALLY_BAKER" ];
	leader.script_startingposition = 3;

	level.rescue_heli guy_enter_vehicle( leader );
	level.rescue_heli godon();
	level.rescue_heli GoPath();

	convoy = [ jeep_03, jeep_04, jeep_01, jeep_02, apc ];
	level.rescue_heli thread chopper_waittill_destroy_convoy( convoy );

	level.rescue_heli chopper_load_allies();
}

chopper_waittill_destroy_convoy( convoy )
{
	foreach( turret in self.mgturret )
	{
		turret TurretFireDisable();
	}

	wait 5.0;

	foreach( turret in self.mgturret )
	{
		turret TurretFireEnable();
	}

	foreach( vehicle in convoy )
	{
//  	self SetTurretTargetEnt( vehicle );

		foreach( turret in self.mgturret )
		{
			turret SetMode( "manual" );
			turret SetTargetEntity( vehicle );
		}

//  	vehicle waittill( "death" );
//  	while( IsAlive( vehicle ) )
//  	{
//  		wait 0.05;
//  	}
		wait RandomFloatRange( 1.0, 2.5 );
		vehicle Kill();
	}

	foreach( turret in self.mgturret )
	{
		turret SetMode( "auto_ai" );
		turret ClearTargetEntity( );
	}
}

// TEMP
hummer_wait_then_die()
{
	self endon( "death" );
	wait 4.0;
	self Kill();
}

chopper_rescue()
{
	level notify( "rescue_baker_landed" );

	level.rescue_heli = vehicle_spawn( GetEnt( "rescue_heli", "targetname" ) );

	leader = level.squad[ "ALLY_BAKER" ];
	leader.script_startingposition = 3;

	level.rescue_heli guy_enter_vehicle( leader );
	level.rescue_heli godon();
	level.rescue_heli GoPath();

	level waittill( "apc_destroyed" );
	level.rescue_heli chopper_load_allies();
}

chopper_load_allies()
{
	self waittill( "reached_dynamic_path_end" );

	self vehicle_detachfrompath();
	self vehicle_land();

	flag_set( "rescue_chopper_landed" );

	level.squad[ "ALLY_WILLIAMS" ].script_startingposition = 7;
	level.squad[ "ALLY_JENKINS" ].script_startingposition = 2;

	wait 2;

	guys = [ level.squad[ "ALLY_WILLIAMS" ], level.squad[ "ALLY_JENKINS" ] ];
	//iprintln( "load ai" );

	self thread vehicle_load_ai( guys );

	trigger = GetEnt( "rescue_chopper_start", "targetname" );
	trigger trigger_on();
	trigger SetHintString( "Hold [{+usereload}] to board Blackhawk." );
	trigger waittill( "trigger" );
	trigger trigger_off();

	self maps\nx_rocket_util::rescue_chopper_player_setup();

	flag_set( "rescue_chopper_allies_loaded" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ignore_everything_array( actors, enable )
{
	if( !IsDefined( actors ) )
		return;

	foreach( actor in actors )
	{
		actor ignore_everything( enable );
	}
}

ignore_everything( enable )
{
	if( !IsAlive( self ) )
		return;

	self.ignoreall = enable;
	self.ignoreexplosionevents = enable;
	self.ignorerandombulletdamage = enable;
	self.ignoresuppression = enable;
//  self.fixednode = !enable;
	self.disableBulletWhizbyReaction = enable;

	if( enable )
	{
		self disable_pain();
		self.grenadeawareness = 0;
		self.og_newEnemyReactionDistSq = self.newEnemyReactionDistSq;
		self.newEnemyReactionDistSq = 0;
	}
	else
	{
		self enable_pain();
		self.grenadeawareness = 1;
		if( IsDefined( self.og_newEnemyReactionDistSq ) )
		{
			self.newEnemyReactionDistSq = self.og_newEnemyReactionDistSq;
		}
	}
}

enemy_preview( )
{
	if( IsDefined( self.target ) )
		self SetgoalNode( GetNode( self.target, "targetname" ) );

	wait 1.0;
	self waittill( "goal" );

	if( IsDefined( self.script_animation ) )
	{
		goal = GetEnt( self.target, "targetname" );
		self.animname = "enemy_opfor";
		goal anim_single_solo( self, self.script_animation );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
apc_update()
{
	self endon( "death" );

	self vehicle_lights_on( "all" );

	self GoPath();

	foreach( turret in self.mgturret )
	{
		turret TurretFireDisable();
	}

}

hummer_player_dismount()
{
	level._player Unlink();
	level._player SetOrigin( level._player.origin_old );
}


hummer_update()
{
	self endon( "death" );

	self vehicle_lights_on( "all" );

	self thread hummer_turret_update();
	self thread maps\nx_rocket_util::vehicle_enable_fire( false );
	self GoPath();

	self vehicle_waittill_node( "rescue_01_hummer_node_warn", "targetname" );
	flag_set( "hummer_enter" );

	self thread maps\nx_rocket_util::vehicle_firing( 1.0, 2.0, 2.0, 5.0, "hummer_mounted" );

	self vehicle_waittill_node( "rescue_01_hummer_node_crash", "targetname" );
	self thread hummer_crash_bullets();
//  self VehPhys_Crash( );

	self waittill( "reached_end_node" );
	self Vehicle_Unload( "passengers" );

//  issue_color_orders( "o250", "axis" );

//    wait 6.0;
//    flag_wait( "rescue_warehouse_entered" );
//    wait 2.0;
//
////  self vehicle_pathdetach();
//    guard_path = GetVehicleNode( "rescue_hummer_01_path_guard", "targetname" );
//    self StartPath( guard_path );
////  self vehicle_resumepath();
}

hummer_crash_bullets()
{
	for( i = 0; i < 20; i++ )
	{
		MagicBullet( "mp5", self GetTagOrigin( "tag_driver" ) + random_vector( 500 ), self GetTagOrigin( "tag_driver" ) );
		wait randomfloatrange( 0.1, 0.2 );
	}
}

hummer_turret_update()
{
	self endon( "death" );
	
	gunner = self.riders[ 4 ];
	driver = self.riders[ 0 ];

	gunner.ignoreMe = true;

	self waittill( "reached_end_node" );

	if( IsAlive( gunner ) )
		gunner waittill( "death" );

	flag_set( "hummer_gunner_killed" );

	wait 0.5;
//  driver_forward = vector_multiply( AnglesToForward(driver.angles), 1000 );
//  bullet_src = driver.origin + driver_forward + (0, 0, 70 );
//  MagicBullet( "mp5", bullet_src, driver GetTagOrigin( "tag_eye" ) );
//  driver StopAnimScripted();
//  driver Kill();
	self Vehicle_Unload();

	turret = self.mgturret[ 0 ];

	turret SetMode( "manual" );
	turret MakeUsable();

	// Player turret mounting
	turret waittill( "trigger" );

	flag_set( "hummer_mounted" );

	self maps\nx_rocket_util::vehicle_enable_fire( true );

	level._player DisableTurretDismount();
	level._player.origin_old = level._player.origin;
	level._player SetOrigin( self GetTagOrigin( "tag_player" ) );
	level._player PlayerLinkToDelta( self, "tag_player", 0.35, 360, 360, 45, 30, true );

	self waittill( "death" );
	turret EnableTurretDismount();


//    while( 1 )
//    {
//        turret waittill( "trigger" );
//        level._player.origin_old = level._player.origin;
//        level._player SetOrigin( self GetTagOrigin( "tag_player" ) );
//        level._player PlayerLinkToDelta( self, "tag_player", 0.35, 360, 360, 45, 30, true );
//
////  	level._player waittill( "dismount_turret" );
//        wait 0.4;
//        player_waittill_turret_dismount();
//        level._player Unlink();
//        level._player SetOrigin( level._player.origin_old );
//    }
}

vehicle_turret_waittill_node( node_value, node_key )
{
	turret = self.mgturret[ 0 ];
	turret TurretFireDisable();
	self vehicle_waittill_node( node_value, node_key );
	turret TurretFireEnable();
}

jeep_update()
{
	self endon( "death" );

	self vehicle_lights_on( "all" );

	self GoPath();
	self waittill( "reached_end_node" );
	self Vehicle_Unload( "passengers" );

//  maps\nx_rocket_util::ai_array_color_reset( self.riders, "o" );

//  issue_color_orders( "o250", "axis" );
}

trucks_departing()
{
	foreach( spawner in GetEntArray( "rescue_truck", "script_noteworthy" ) )
	{
		truck = vehicle_spawn( spawner );
		truck thread truck_update();
	}
}

truck_update()
{
	self endon( "death" );

	self GoPath();
	self waittill( "reached_end_node" );
	self Delete();
}

vtol_update()
{
	self endon( "death" );
	
	self.ignoreme = true;
	
	self vtol_fire_enable( false );
	
	self GoPath();

	// Turn on spotlight
	self thread maps\_attack_heli::heli_spotlight_on( undefined, true );
	self thread maps\nx_rocket_util::vehicle_search_ents( 
		[ level.squad[ "ALLY_WILLIAMS" ], level.squad[ "ALLY_JENKINS" ], level._player ]
		);

	self waittill( "reached_dynamic_path_end" );

	// Point spotlight at drop-point
	unload_target = spawn( "script_origin", self.origin + (0,0,-10000) );
//  self SetTurretTargetEnt( unload_target );

	// Unload passengers
	self Vehicle_Unload();
	
	self waittill( "unloaded" );

	self thread vtol_strafe( );	
//  self thread vtol_firing();
	self thread maps\nx_rocket_util::vehicle_firing( 1.0, 2.0, 3.0, 5.0 );

	unload_target Delete();
}

vtol_fire_enable( enable )
{
	foreach( turret in self.mgturret )
	{
//  	turret SetMode( "manual" );

		if( enable )
			turret TurretFireEnable();
		else
			turret TurretFireDisable();
	}
}

vtol_update_target( target_ent )
{
	self endon( "death" );

	while( 1 )
	{
		foreach( turret in self.mgturret )
		{
			turret SetTargetEntity( target_ent );
		}

		wait 0.05;
	}
}

vtol_firing()
{	
	self endon( "death" );
	firing = false;

//  target_org = spawn( "script_origin", level._player.origin );

//  self SetTurretTargetEnt( level._player );
//  self thread vtol_update_target( target_org );

	while( 1 )
	{		
		firing = !firing;

		self vtol_fire_enable( firing );

		if( firing )
		{
			wait RandomFloatRange( 0.75, 1.5 );
		}
		else
		{
			wait RandomfloatRange( 5.0, 6.0 );
//  		target_org MoveTo( level._player.origin, 3.5 );
//  		target_org waittill( "movedone");
		}
	}
}

vtol_strafe( circle_targetname )
{
	self SetLookAtEnt( level._player );
	self Vehicle_SetSpeed( 5.0 );
	self maps\nx_rocket_util::heli_start_path( "rescue_vtol_strafe", "targetname" );
}

//*******************************************************************
//   PLAYER                                                         *
//*******************************************************************

player_safe_zone()
{
	self endon( "death" );
	level endon( "rescue_baker_landed" );

	flag_wait( "rescue_warehouse_entered" );

	safe_zone_trigger = GetEnt( "rescue_player_safe_zone", "targetname" );
	max_distance = safe_zone_trigger.radius + 500;
	interval = 0.0;

	level thread dialogue_player_safe_zone_warn( safe_zone_trigger, "rescue_baker_landed" );

	while( 1 )
	{
		if( !( self IsTouching( safe_zone_trigger ) ) )
		{
			bullet_src = self.origin + ( RandomFloatRange( -1000, 1000 ), RandomFloatRange( -1000, 1000 ), RandomFloatRange( 20, 50 ) );
			MagicBullet( "mp5", bullet_src, self.origin + ( 0, 0, 30 ) );
		}

		dist = DistanceSquared( level._player.origin, safe_zone_trigger.origin );
		distance_scale = ( 1.0 - dist/( max_distance * max_distance ) );
		if( distance_scale <= 0 )
			distance_scale = 0.25;

		interval = RandomFloatRange( 1.0, 1.25 ) * distance_scale;

		wait interval;
	}
}

player_waittill_turret_dismount()
{
	//HAAAACK
	while( 1 )
	{
		if( level._player UseButtonPressed() )
			break;

		wait 0.05;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
squad_to_warehouse()
{
	level waittill( "hummer_warn" );
	foreach( ally in level.squad )
	{
		ally thread ally_to_warehouse();
	}
//  level thread maps\nx_rocket_util::set_goal_volume_array( [ level.squad["ALLY_JENKINS"], level.squad["ALLY_WILLIAMS"] ], "rescue_goal_warehouse" );
//  issue_color_orders( "b211 p211", "allies" );
//  array_thread( level.squad, ::ally_to_warehouse );
//  flag_wait( "rescue_warehouse_entered" );
//  ignore_everything_array( level.squad, false );
}

ally_to_warehouse()
{
	self ignore_everything( true );
	self thread maps\nx_rocket_util::set_goal_volume( "rescue_goal_warehouse" );
	self waittill( "goal" );
	self ignore_everything( false );
}

objective_defend()
{
	flag_wait( "defend_start" );
	defend_marker = GetEnt( "rescue_defend_objective", "targetname" );
	Objective_State( obj( "OBJ_FIND_BAKER" ), "current" );
	Objective_SetPointerTextOverride( obj( "OBJ_FIND_BAKER" ), "Defend" );
	Objective_OnEntity( obj( "OBJ_FIND_BAKER" ), defend_marker );


	flag_wait( "hummer_gunner_killed" );
	hummer_marker = GetEnt( "rescue_hummer_objective", "targetname" );
	Objective_State( obj( "OBJ_FIND_BAKER" ), "current" );
	Objective_SetPointerTextOverride( obj( "OBJ_FIND_BAKER" ), "" );
	Objective_OnEntity( obj( "OBJ_FIND_BAKER" ), hummer_marker );


	flag_wait( "rescue_chopper_landed" );
	chopper_marker = GetEnt( "rescue_chopper_objective", "targetname" );
	Objective_State( obj( "OBJ_FIND_BAKER" ), "current" );
	Objective_SetPointerTextOverride( obj( "OBJ_FIND_BAKER" ), "" );
	Objective_OnEntity( obj( "OBJ_FIND_BAKER" ), chopper_marker );

}

//*******************************************************************
// Dialogue                                                         *
//*******************************************************************
section_dialogue()
{

	maps\nx_rocket_util::wait_play_dialogue_wait( 3, "roc_jen_rescue_holyshit" );

	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_jen_rescue_strongmsg" );

	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_wil_rescue_rollout" );

//  flag_wait( "rescue_encounter_start" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 3, "roc_wil_rescue_tangowarehouse" );

	flag_wait( "wave_01_start" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_wil_rescue_getoutofhere" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 1.5, "roc_jen_rescue_moretangosincoming" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 1, "roc_wil_echo_shit" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_wil_rescue_takecoverawhile" );

	flag_wait( "wave_02_start" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_wil_rescue_takethemout" );

	flag_wait( "wave_03_start" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_jen_rescue_tangosdrivingin" );

	flag_wait( "vtol_enter" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_jen_rescue_vtolbadnews" );
//  add_dialogue_line( "Williams", "That VTOL is bad news...", undefined, 3.0 );

	flag_wait( "hummer_enter" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_jen_rescue_humveetakecover" );
	maps\nx_rocket_util::dialogue_nag( "roc_wil_rescue_takeoutgunner", 4.0, 6.0, "hummer_gunner_killed" );
	//  level thread maps\nx_rocket_util::dialogue_nag_temp( "Williams", "Lockwood! Take out that gunner in the Humvee!", 3.0, 2.0, 4.0, "hummer_gunner_killed" );

	flag_wait( "hummer_gunner_killed" );
	maps\nx_rocket_util::dialogue_nag( "roc_wil_rescue_getongun", 4.0, 6.0, "hummer_mounted" );

	flag_wait( "wave_05_start" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_jen_rescue_apc" );

	flag_wait( "rescue_chopper_arrived" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 8, "roc_jen_rescue_baker" );

	flag_wait( "rescue_chopper_landed" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_wil_rescue_makearun" );

//  level thread maps\nx_rocket_util::dialogue_nag_temp( "Williams", "Lockwood! Get on that gun and take down that VTOL! I'll cover you!", 3.0, 2.0, 4.0, "hummer_mounted" );
}

dialogue_player_safe_zone_warn( trigger, end_on )
{
	level endon( end_on );

	while( 1 )
	{
		if( !( level._player IsTouching( trigger ) ) )
			add_dialogue_line( "Williams", "Lockwood! Get back here!", undefined, 3.0 );

		wait RandomFloatRange( 2.0, 4.0 );
	}	
}

//*******************************************************************
// Section                                                          *
//*******************************************************************

section_precache()
{
	PrecacheItem( "mp5" );
	PrecacheItem( "rpg" );
	PrecacheItem( "rpg_straight" );
}


section_flag_inits()
{
	flag_init( "turret_destroyed" );
	flag_init( "rescue_enemy_preview" );
	flag_init( "rescue_jumpdown" );
	flag_init( "rescue_encounter_start" );
	flag_init( "rescue_arrived" );
	flag_init( "rescue_warehouse_entered" );
	flag_init( "vignette_aa_control_exit" );

	flag_init( "defend_start" );
	flag_init( "wave_01_start" );
	flag_init( "wave_02_start" );
	flag_init( "wave_03_start" );
	flag_init( "wave_04_start" );
	flag_init( "wave_05_start" );

	flag_init( "rescue_chopper_arrived" );
	flag_init( "rescue_chopper_landed" );
	flag_init( "vtol_enter" );
	flag_init( "hummer_enter" );
	flag_init( "hummer_gunner_killed" );
	flag_init( "hummer_mounted" );

	flag_init( "rescue_chopper_allies_loaded" );
}

//*******************************************************************
// DEBUG                                                            *
//*******************************************************************
debug_wave_info( wave_name, wave_info )
{
	if( !DEBUG_WAVE_INFO )
		return;
	
	if( !IsArray( wave_info ) )
	{
		wave_info = [ wave_info ];
	}

	iPrintln( wave_name + ":" );
	foreach( line in wave_info )
	{
		iPrintln( line );
	}
}
