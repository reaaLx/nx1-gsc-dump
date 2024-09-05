//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  MISSION DESCRIPTION											**
//                                                                          **
//    Created: 8/30/2011 Brian Marvin										**
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
// 																	*
//                                                                  *
//*******************************************************************

start_lab_to_vault()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_lab_to_vault" );
	thread maps\nx_skyscraper_fx::set_vision_and_fog("robotics_01", 0); // set appropriate vision and fog
	maps\nx_skyscraper_util::player_weapon_init( false );

	thread maps\_utility::set_ambient( "amb_skyscraper_robotics_int" );

	maps\nx_skyscraper_util::spawn_baker();
	baker_teleport = GetEnt ("origin_baker_lab_to_vault_teleport", "targetname");

	Assert( IsDefined( baker_teleport ));

	level.baker ForceTeleport( baker_teleport.origin, baker_teleport.angles);
	
	// Stealth stuff	
	stealth_settings();
}

sequence_lab_to_vault()
{
	// Global
	level.enemies[ "patrol" ] = [];	

	// Set up low cover
	//thread low_cover_on( 64, false );

	// Prep UAV flyby
	thread event_uav_catwalk_flyby_1();

	// Halon anims
	thread vista_setup();

	// Lab life
	thread event_lab_life();
	
	// Wait for melee to finish or player to make it to hallway
	flag = "flag_script_lab_to_vault_start";
	thread set_flag_on_trigger_targetname( "entering_lab_hallway", flag );
	level thread set_flag_on_notify( "notify_synced_melee_complete", flag );
	
	flag_wait( flag );

	thread autosave_now();
												  
	// Baker
	level.baker thread baker_movement_lab_to_vault();	

	// Stealth blown
	thread event_lab_to_vault_stealth_blown();

	// Patrol in room
	sequence_lab_to_vault_patrol();

	//low_cover_off();								  

	// Catwalk
	//event_lab_to_vault_uav_catwalk();	

	trigger_wait_targetname( "trig_crawlspace_player_drops" );
	thread autosave_now();	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

sequence_lab_to_vault_patrol()
{
	trigger_wait_targetname( "entering_lab_hallway" );

	// spawn patrol sequence	
	level.enemies[ "patrol" ] = spawn_patrol_enemies();

	level._player.maxvisibledist = 128;
	PlayFXOnTag( level._effect[ "spotlight_dynamic" ], level.enemies[ "patrol" ][ 0 ], "TAG_WEAPON_RIGHT" );	
		
	// Wait until player kills or player waits
	notify_name = "notify_patrol_dead";
	time = 40;
	//thread sequence_lab_to_vault_patrol_kill( notify_name );
	//thread sequence_lab_to_vault_patrol_wait( time, notify_name );
	
	//level waittill( "notify_patrol_dead" );

	trigger_wait_targetname( "trig_crawlspace_player_in" );

	StopFXonTag( level._effect[ "spotlight_dynamic" ], level.enemies[ "patrol" ][ 0 ], "TAG_WEAPON_RIGHT" );

	level notify( "notify_stopped_spotlight" );
	
	level._player.maxvisibledist = 8192;
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

sequence_lab_to_vault_patrol_kill( notify_name )
{
	level endon( notify_name );

 	// Wait for player to kill one of the patrol
	while( level.enemies[ "patrol" ].size > 1 )
	{
		level.enemies[ "patrol" ] = remove_dead_from_array( level.enemies[ "patrol" ] );
		wait 0.05;
	}
	
	// Have baker kill other guy
	if( isalive( level.enemies[ "patrol" ][ 0 ] ))
	{
		level.baker SetLookAtEntity( level.enemies[ "patrol" ][ 0 ] );
		level.baker Shoot();
		MagicBullet( "lancer_silencer_xray", level.baker.origin, level.enemies[ "patrol" ][ 0 ].origin );		
		level.enemies[ "patrol" ][ 0 ] kill();
	}

	level.enemies[ "patrol" ] = [];

	level notify( notify_name );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

sequence_lab_to_vault_patrol_wait( time, notify_name )
{
	level endon( notify_name );
	wait time;

	foreach( guy in level.enemies[ "patrol" ] )
	{
		if( isalive( guy ))
		{
			guy delete();
		}
	}

	level.enemies[ "patrol" ] = [];

	level notify( notify_name );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

event_lab_to_vault_uav_catwalk()
{
	level.baker waittill( "goal" );

	uav_spawner = GetEnt( "vehicle_uav_catwalk_1", "targetname" );
	uav = uav_spawner maps\_attack_heli::SAV_setup( "pathing" );
	uav Vehicle_SetSpeedImmediate( 5, 5, 1 );

	PlayFXOnTag( level._effect[ "spotlight_dynamic" ], uav, "tag_origin" );
	
	uav waittill( "reached_dynamic_path_end" );
	uav delete();
	level notify( "notify_uav_catwalk_encounter_finished" );	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

event_lab_to_vault_stealth_blown()
{	
	level endon( "macguffin_obtained" );

	flag_clear( "flag_stealth_off" );

	trigger_wait_targetname( "entering_lab_hallway" );

	murder_squad_spawner = GetEnt( "vehicle_uav_murder_squad", "script_noteworthy" );
	Assert( IsDefined( murder_squad_spawner ));

	thread event_lab_to_vault_stealth_blown_noticed();

	while( 1 )
	{
		if( level._player ButtonPressed( "BUTTON_RTRIG" ))
			break;
 		if( flag( "flag_stealth_off" ))
			break;

 		wait 0.05;
	}

	SetDvar( "ui_deadquote", "You broke stealth (placeholder)" );
	maps\_utility::missionFailedWrapper();

	/*
	iprintlnbold( "You broke stealth.  A gaggle of UAVs arrives to murder you." );

	// Send in the murder squad UAV
	murder_squad = undefined;
	position = undefined;

	while( 1 )
	{
		if( !IsDefined( murder_squad ))
		{
			murder_squad_spawner.count = 1;
			murder_squad = murder_squad_spawner maps\_attack_heli::SAV_setup( "pathing" );
			murder_squad.baseaccuracy = 1000;
			position = level._player GetEye() + vector_multiply( AnglesToForward( level._player.angles ), 128 );
			murder_squad Vehicle_Teleport( position, (-1) * level._player.angles );			
			murder_squad SetLookAtEnt( level._player );
		}
		else
		{
			trace = BulletTrace( level._player GetEye(), murder_squad.origin, false );

			if( IsDefined( trace ))
			{
				position = level._player GetEye() + vector_multiply( AnglesToForward( level._player.angles ), 128 );
			}
			else
			{
				position = level._player GetEye() + vector_multiply( (-1) * AnglesToForward( level._player.angles ), 128 );
			}

			murder_squad SetVehGoalPos( position ); 
			murder_squad SetLookAtEnt( level._player ); 
			murder_squad FireWeapon( "TAG_FLASH" );
			murder_squad FireWeapon( "TAG_FLASH2" );			
		}
		wait 0.05;
	}
	*/
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

event_lab_to_vault_stealth_blown_noticed()
{
	level endon( "macguffin_obtained" );

	level waittill( "_stealth_spotted" );
	flag_set( "flag_stealth_off" );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

set_flag_on_trigger_targetname( tTrigger, flag )
{
	trigger_wait_targetname( tTrigger );
	flag_set( flag );	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

set_flag_on_notify( notify_msg, flag )
{
	self waittill( notify_msg );
	flag_set( flag );	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

spawn_patrol_enemies()
{
	patrol_spawners = GetEntArray( "actor_patrol", "script_noteworthy" );
	uav_spawner = GetEnt( "vehicle_uav_patrol_walkway", "targetname" ); 

	Assert( IsDefined( patrol_spawners ));
	Assert( IsDefined( uav_spawner ));

	enemies = [];

	array_thread( patrol_spawners, ::add_spawn_function, ::spawnfunc_patrol_enemies );
	uav_spawner add_spawn_function( ::spawnfunc_patrol_enemies );
	foreach( spawner in patrol_spawners )
	{
		guy = spawner spawn_ai();
		enemies = add_to_array( enemies, guy );
		wait 0.5;
	}	

	uav = uav_spawner maps\_attack_heli::SAV_setup( "pathing" );;	

	PlayFXOnTag( level._effect[ "spotlight_white" ], uav, "tag_origin" );
	uav Vehicle_SetSpeed( 1.2 );

	return enemies;	
}

spawnfunc_patrol_enemies()
{
	self endon( "death" );
	self waittill( "reached_path_end" );
	self delete();

	
}

spawnfunc_patrol_uav()
{
	self endon( "death" );
	self waittill( "reached_dynamic_path_end" );
	self delete();
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

baker_movement_lab_to_vault()
{
	self.ignoreme = true;
	self.ignoreall = true;
	self.goalradius = 8;
	self enable_cqbwalk();
	
	// Dialogue - Baker: "<whispers> Alright, follow me.  Hold your fire and stay frosty.  We've gotta stay absolutely quiet from here on out."
	level.baker dialogue_queue( "sky_bak_lab2vault_stayfrosty" );	
	//thread add_dialogue_line( "Baker", "<whispers> Alright, follow me.  Hold your fire and stay frosty.", "g" );	
	//thread add_dialogue_line( "Baker", "<whispers> We've gotta stay absolutely quiet from here on out.", "g" );

	wait 1;

	// Baker goes up and opens door
	self enable_ai_color();
	issue_color_orders( "r303", "allies" );

	self waittill( "goal" );

	// Dialogue: Baker - "What the fuck is all of this?"
	level.baker dialogue_queue( "sky_bak_labent_wtf" );			
	
	trigger_wait_targetname( "trig_lab_to_vault_vista" );

	wait 4;

	issue_color_orders( "r44", "allies" );

	trigger_wait_targetname( "trig_baker_opens_door" );

	// Patrol sequence, baker enters door

	// Dialogue: Baker - "Patrol coming.  In here" 		
	level.baker dialogue_queue( "sky_bak_labent_patrolcoming" );
	//thread add_dialogue_line( "Baker", "Patrol coming.  In here.", "g" );

	door = GetEnt( "door", "targetname" ); //hinge brush model object for door.
	node_door = getent( "node_door", "targetname" ); //called on script_origin node, grabs KVP, and assigns to variable.
	attachments = GetEntArray( door.target, "targetname" );  
	main_door = GetEnt( "brushmodel_main_door", "targetname" );
	
	Assert( IsDefined( door ));
	Assert( IsDefined( node_door ));	
	Assert( IsDefined( main_door ));

	for ( i = 0; i < attachments.size; i++ )
	{
		attachments[ i ] LinkTo( door );
	}

	main_door LinkTo( door );

	// self.animname = "baker";
	node_door anim_reach_solo( self, "hunted_open_barndoor" ); //blends into first frame of open door anim based off cover right anim pose.  Also ends anim in cover right position.		
	door thread hunted_style_door_open(); //function to open door that is based off door open anim.  Not sure where this is defined.
	node_door anim_single_solo( self, "hunted_open_barndoor" ); //play anim to open door.
		 
	// Fix paths on other side of door and send baker into room
	main_door ConnectPaths();

	// Door closes when player passes through
	door thread door_close();

	// Dialogue - Baker: "Stay low."
	level.baker dialogue_queue( "sky_bak_lab2vault_staylow" );
	//thread add_dialogue_line( "Baker", "Stay low.", "g" );

	self enable_ai_color();
	issue_color_orders( "r46", "allies" );
	
	self disable_cqbwalk();
	self AllowedStances( "crouch" );

	level.baker dialogue_queue( "sky_bak_lab2vault_highroad" );
	//thread add_dialogue_line( "Baker", "The vault is on the other side of the factory.  We're taking the high road.", "g" );

	wait 10;

	trigger_wait_targetname( "trig_crawlspace_player_in" );

	self waittill( "goal" );	

	issue_color_orders( "r48", "allies" );

	// Dialogue - Baker: "Team A, we're about 30 meters to the target.  What is your status?"
	level.baker dialogue_queue( "sky_bak_lab2vault_teamastatus" );
	//thread add_dialogue_line( "Baker", "Team A, we're about 30 meters to the target.  What is your status?", "g" );
	
	// Dialogue - Team A: "Team A is in position and ready.  Over." 
	radio_dialogue( "sky_teama_lab2vault_inposition" );
	//thread add_dialogue_line( "Team A", "Team A is in position and ready.", "r" );
	
   	// Dialogue - Baker: "Roger Team A.  Maintain radio silence while we secure the control room.  Team B out."
	level.baker dialogue_queue( "sky_bak_lab2vault_radiosilence" );
	//thread add_dialogue_line( "Baker", "Roger Team A.  Maintain radio silence while we secure the control room.  Team B out.", "g" );		
	/*
	node = GetNode( "node_baker_drop_down", "targetname" );
	Assert( IsDefined( node ));

	self ForceTeleport( node.origin, node.angles );
	*/

	//self waittill( "goal" );
	//thread add_dialogue_line( "Baker", "We need these scientists to gain access to the vault.  Subdue the one below, I'll take care of his buddy.", "g" );
	// Baker waits for player to drop down
	trigger_wait_targetname( "trig_crawlspace_player_arrived" );
	issue_color_orders( "r302", "allies" );
	trigger_wait_targetname( "trig_crawlspace_player_drops" );

	thread cleanup_halon_life();
	self AllowedStances( "stand", "crouch", "prone" );	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

door_close()
{
	trigger_wait_targetname( "trig_lab_to_vault_player_in_room" );
	self RotateTo( self.angles - ( 0, 100, 0 ), 1 );	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

event_uav_catwalk_flyby_1()
{
	trigger_wait_targetname( "trig_crawlspace_player_in" );

	uav_spawner = GetEnt( "vehicle_uav_catwalk_flyby_1", "targetname" );
	Assert( IsDefined( uav_spawner ));

	uav = uav_spawner maps\_attack_heli::SAV_setup( "pathing" );
	
	PlayFXOnTag( level._effect[ "spotlight_white" ], uav, "tag_origin" );

	uav Vehicle_SetSpeedImmediate( 5, 5, 1 );

	uav waittill( "reached_dynamic_path_end" );
	uav delete();
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

cleanup_halon_life()
{
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

vista_setup()
{
	trigger_wait_targetname( "entering_lab_hallway" );

	thread robot_arm_move( "model_robot_arm_3", "origin_robot_arm_3_pos_2" );	
	thread robot_arm_move_slide( "model_robot_arm_slide_1", ( 1, 0, 0 ) );
	thread robot_arm_move_slide( "model_robot_arm_slide_2", ( -1, 0, 0 ) );

	flag_set( "flag_halon_robot_arms_moving" );

	// Hide halon encounter transports
	transports = GetEntArray( "halon_transports", "script_noteworthy" );
	Assert( IsDefined( transports ));

	foreach( thing in transports )
	{
		thing hide();
	}

	thread vista_transport();
	thread vista_scientist();
	thread vista_uavs();
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

vista_transport()
{
	level.transport_movers = 
	[
		"model_mover_vista",
		"model_mover_vista2",
		"model_mover_vista3"
	];	

	thread vista_transport_straight( level.transport_movers[ 0 ] );	
	thread vista_transport_dropoff(  level.transport_movers[ 1 ], 4 );
	thread vista_transport_straight( level.transport_movers[ 2 ], 8 );
	thread vista_transport_cleanup();	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

vista_transport_cleanup()
{
	trigger_wait_targetname( "trig_crawlspace_player_drops" );
	level notify( "notify_lab_to_vault_vista_stop" );

	foreach( thing in level.transport_movers )
	{
		thing_ent = GetEnt( thing, "targetname" );
		thing_ent_items = GetEntArray( thing_ent.target, "targetname" );
		foreach( item in thing_ent_items )
		{
			item delete();
		}
		thing_ent delete();
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

vista_uavs()
{
	uav_spawners = GetEntArray( "vehicle_uav_patrol", "script_noteworthy" );
	Assert( IsDefined( uav_spawners ));

	level.enemies[ "vista_uavs" ] = array_spawn( uav_spawners );	

	foreach( uav in level.enemies[ "vista_uavs" ] )
	{
		PlayFXOnTag( level._effect[ "spotlight_white" ], uav, "tag_origin" );
		uav Vehicle_SetSpeed( 6 );
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

vista_uavs_cleanup()
{
	trigger_wait_targetname( "trig_crawlspace_player_drops" );

	foreach( uav in level.enemies[ "vista_uavs" ] )
	{
		StopFXOnTag( level._effect[ "spotlight_white" ], uav, "tag_origin" );
		uav delete();
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

vista_scientist()
{
	level.enemies[ "scientists" ][ 0 ] = vista_scientist_anim( "actor_halon_scientist_1", "scientist", "escalator_up_generic_guy_idle", "origin_halon_conveyor_1", 0 );
	level.enemies[ "scientists" ][ 1 ] = vista_scientist_anim( "actor_halon_scientist_2", "scientist", "escalator_up_generic_guy_idle", "origin_halon_conveyor_2", 0 );
	level.enemies[ "scientists" ][ 2 ] = vista_scientist_anim( "actor_halon_scientist_3", "scientist", "civilian_directions_2_A_idle", "origin_halon_conveyor_3", 0 );
	level.enemies[ "scientists" ][ 3 ] = vista_scientist_anim( "actor_halon_scientist_4", "scientist", "escalator_up_generic_guy_idle", "origin_halon_conveyor_4", 0 );
	level.enemies[ "scientists" ][ 4 ] = vista_scientist_anim( "actor_halon_scientist_5", "scientist", "cliff_guardB_idle", "origin_halon_floor_1", 0 );
	level.enemies[ "scientists" ][ 5 ] = vista_scientist_anim( "actor_halon_scientist_6", "scientist", "escalator_up_generic_guy_idle", "origin_halon_conveyor_5", 0 );
	level.enemies[ "scientists" ][ 6 ] = vista_scientist_anim( "actor_halon_scientist_7", "scientist", "civilian_directions_2_A_idle", "origin_halon_conveyor_6", 0 );
	thread vista_scientist_anim( "actor_halon_scientist_8", "ally_01", "lobby_walk", "origin_halon_floor_2", 2, true );
	thread vista_scientist_cleanup();	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

vista_scientist_anim( tSpawner, animname1, anim1, tOrigin, delay, single_anim )
{
	spawner = GetEnt( tSpawner, "targetname" );
	origin = GetEnt( tOrigin, "targetname" );
	//spawner add_spawn_function( ::spawnfunc_melee_enemy, origin );

	Assert( IsDefined( spawner ));
	Assert( IsDefined( origin ));
	
	wait( delay );	

	enemy = spawner spawn_ai();

	Assert( IsDefined( enemy ));

	enemy gun_remove();

	enemy.animname = animname1;
	if( IsDefined( single_anim ))
	{
		if( single_anim )
		{
			guys[ 0 ] = enemy;
			origin anim_single( guys, anim1 );
			enemy delete();
			return;
		}
	}
	else
		origin thread anim_loop_solo( enemy, anim1 );

	return enemy;
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

vista_scientist_cleanup()
{
	trigger_wait_targetname( "trig_crawlspace_player_drops" );	

	foreach( thing in level.enemies[ "scientists" ] )
	{
		thing delete();
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

vista_transport_straight( tMover, delay )
{
	level endon( "notify_lab_to_vault_vista_stop" );

	start_point = GetEnt( "origin_mover_vista_1", "targetname" );	
	Assert( IsDefined( start_point ));

	mover = GetEnt( tMover, "targetname" );
	
  	Assert( IsDefined( mover ));
	Assert( IsDefined( mover.target ));	

	mover_load = GetEntArray( mover.target, "targetname" );

	foreach( thing in mover_load )
	{
		thing LinkTo( mover );
	}

	CONST_INITIAL_ANGLES = mover.angles;

	current_goal = undefined;

	if( IsDefined( delay ))
		wait( delay );

	while( 1 )
	{
		mover.origin = start_point.origin;		
		mover.angles = CONST_INITIAL_ANGLES;
		current_goal = GetEnt( start_point.target, "targetname" );
		mover MoveTo( current_goal.origin, 2 );
		wait( 2 );
		mover RotateYaw( 90, 2 );
		wait( 2 );
		current_goal = GetEnt( current_goal.target, "targetname" );
		mover MoveTo( current_goal.origin, 8 );
		wait( 8 );
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

vista_transport_dropoff( tMover, delay )
{
	level endon( "notify_lab_to_vault_vista_stop" );

	start_point = GetEnt( "origin_mover_vista_3", "targetname" );	
	Assert( IsDefined( start_point ));
	
	mover = GetEnt( tMover, "targetname" );
	
  	Assert( IsDefined( mover ));
	Assert( IsDefined( mover.target ));	

	mover_load = GetEntArray( mover.target, "targetname" );

	foreach( thing in mover_load )
	{
		thing LinkTo( mover );
	}	

	CONST_INITIAL_ANGLES = mover.angles;

	current_goal = undefined;
	loaded = true;

	if( IsDefined( delay ))
		wait( delay );

	while( 1 )
	{
		mover.origin = start_point.origin;		
		mover.angles = CONST_INITIAL_ANGLES;
		current_goal = GetEnt( start_point.target, "targetname" );
		mover MoveTo( current_goal.origin, 2 );
		wait( 2 );
		mover RotateYaw( 90, 2 );
		wait( 2 );
		current_goal = GetEnt( "origin_mover_vista_dropoff1", "targetname" );
		mover MoveTo( current_goal.origin, 4 );
		wait 4;
		mover RotateYaw( -90, 2 );		
		current_goal2 = GetEnt( "origin_mover_vista_dropoff2", "targetname" );
		mover MoveTo( current_goal2.origin, 4 );
		wait 4;
		if( loaded )
		{
			foreach( thing in mover_load )
			{
				thing Unlink();
			}
			loaded = false;
		}
		else
		{
			foreach( thing in mover_load )
			{
				thing LinkTo( mover );
			}
			loaded = true;
		}
		wait( 4 );
		mover MoveTo( current_goal.origin, 4 );
		wait( 2 );
		mover RotateYaw( 90, 2 );
		wait( 2 );
		current_goal = GetEnt( "origin_mover_vista_end2", "targetname" );
		mover MoveTo( current_goal.origin, 4 );
		wait( 4 );
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

event_lab_life()
{
	trigger_wait_targetname( "trig_lab_to_vault_lab_life" );

	walker_spawn = GetEnt( "actor_lab_walk_1", "targetname" );
	Assert( IsDefined( walker_spawn ));

	walker_origin = GetEnt( "origin_lab_walk_1", "targetname" );
	Assert( IsDefined( walker_origin ));

	walker = walker_spawn spawn_ai();
	walker.animname = "ally_01";
	walker_array[0] = walker;
	walker_origin anim_single( walker_array, "lobby_walk" );

	walker delete();
	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

robot_arm_move( tArm, tPos )
{
	level endon( "notify_stop_robot_anims" );

	arm = GetEnt( tArm, "targetname" );
	Assert( IsDefined( arm ));

	arm SetIsVisibleInXray();

	down_dist = 128;
	over_dist = 256;

	time = 4;
	
	while( 1 )
	{
		pos1 = arm.origin;

		/*
		pos = pos1 - (0,0,down_dist);
		arm MoveTo( pos, time ); 
		wait time;

		arm MoveTo( pos1, time ); 
		wait time;
		*/

		arm RotateYaw( 180, time );
		wait time;
		/*
		pos1 = arm.origin;

		pos = pos1 - (0,0,down_dist);
		arm MoveTo( pos, time ); 
		wait time;

		arm MoveTo( pos1, time ); 
		wait time;
		*/
		arm RotateYaw( -180, time );
		wait time;
		
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

robot_arm_move_slide( tArm, move_vector )
{
	level endon( "notify_stop_robot_anims" );

	arm = GetEnt( tArm, "targetname" );
	Assert( IsDefined( arm ));

	arm SetIsVisibleInXray();

	down_dist = 128;
	over_dist = 256;

	time = RandomFloatRange( 1, 2 );

	pos1 = arm.origin;
	pos2 = pos1 + vector_multiply( move_vector, over_dist );
	
	while( 1 )
	{
		pos = pos1 - (0,0,down_dist);
		arm MoveTo( pos, time ); 
		wait time;

		arm MoveTo( pos1, time ); 
		wait time;

		arm MoveTo( pos2, time );		 
		wait time;		

		pos = pos2 - (0,0,down_dist);
		arm MoveTo( pos, time ); 
		wait time;

		arm MoveTo( pos2, time ); 
		wait time;

		arm MoveTo( pos1, time );
		wait time;
	}
}
