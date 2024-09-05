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
// LAB EXIT                                                         *
//                                                                  *
//*******************************************************************

start_lab_exit()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_lab_exit" );
	thread maps\nx_skyscraper_fx::set_vision_and_fog("interior", 0); // set appropriate vision and fog
	maps\nx_skyscraper_util::player_weapon_init( true );
	level._player SwitchToWeapon( "lancer_xray" );

	thread maps\_utility::set_ambient( "amb_skyscraper_office_int" );

	maps\nx_skyscraper_util::spawn_baker();
	baker_teleport = GetEnt ("baker_lab_exit_teleport", "targetname");
	level.baker ForceTeleport( baker_teleport.origin, baker_teleport.angles);	

	wait 0.05;
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

sequence_lab_exit()
{
	thread autosave_now();

	// Baker
	level.baker thread baker_movement_lab_exit();

	// Disable vault trigger
	trigger = GetEnt( "trig_baker_enter_vault", "targetname" );
	Assert( IsDefined( trigger ));
	trigger trigger_off();

	// turn on xray for motor and other objects
	thread xray_on_for_models();

	// Spawn enemies outside of vault
	thread spawn_it_lab_enemies();
	
	//audio alarms start
	thread audio_intruder_alarm();

	// Send in security enemies
	thread spawn_security_door_enemies( "actor_security_door_enemy" );

 	// Switch from silenced lancer to full-auto lancer
	thread weapons_hot();	

	// Main security doors close
	thread security_door_close();

	// Baker / Player stop doors
	thread security_door_stuck();

	// Remove motor xray models to conserve xray count
	thread remove_motor_parts();

	trigger_wait_targetname( "trig_halon_button" );
	
}

audio_intruder_alarm()
{
	alarms = audio_intruder_alarm_add();
	
	/*
	intruder_sound01 = spawn( "sound_emitter", ( -1067, 373, 30927 ) );
	intruder_sound01 PlayloopSound( "emt_ss_intruder_alarm" ); //play sound on ent
	intruder_sound02 = spawn( "sound_emitter", ( -1068, -344, 30927 ) );
	intruder_sound02 PlayloopSound( "emt_ss_intruder_alarm" ); //play sound on ent
	intruder_sound03 = spawn( "sound_emitter", ( 481, 463, 30927 ) );
	intruder_sound03 PlayloopSound( "emt_ss_intruder_alarm" ); //play sound on ent
	*/
		
	// Stop alarm sound
	flag_wait( "flag_halon_finished" );
	alarms audio_intruder_alarm_remove();
	
	/*
	intruder_sound01 stopsounds();
	intruder_sound02 stopsounds();
	intruder_sound03 stopsounds();
	wait 0.1;
	intruder_sound01 delete();
	intruder_sound02 delete();
	intruder_sound03 delete();	
	*/
}

audio_intruder_alarm_add()
{
	horns = GetEntArray( "model_alarm_horn", "script_noteworthy" );
	alarms = [];

	foreach( horn in horns )
	{
		intruder_sound = spawn( "sound_emitter", horn.origin );
		intruder_sound PlayloopSound( "emt_ss_intruder_alarm" ); //play sound on ent
		alarms = add_to_array( level.alarms, intruder_sound );
	}

	return alarms;
}

audio_intruder_alarm_remove()
{
	foreach( alarm in self )
	{
		alarm stopsounds();
	} 

	wait 0.1;

	foreach( alarm in self )
	{
		alarm delete();
	}	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

weapons_hot()
{
	level waittill( "notify_switch_lancer" );

	level._player TakeWeapon( "lancer_silencer_xray" );
	level._player GiveWeapon( "lancer_xray" );
	level._player SwitchToWeapon( "lancer_xray" );
}

remove_motor_parts()
{
	motor_parts = GetEntArray( "model_xray_motor_parts", "script_noteworthy" );
	Assert( IsDefined( motor_parts ));

	trigger_wait_targetname( "trig_halon_button" );

	foreach( part in motor_parts )
	{
		part delete();
	}

}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

baker_movement_lab_exit()
{
	self disable_pain();
	// Dialogue - Baker: "Weapons hot!  Switch to full auto!"
	level.baker thread dialogue_queue( "sky_bak_labex_weaponshot" );
	//thread add_dialogue_line( "Baker", "Weapons hot!  Switch to full auto!", "green" );

	wait 1;
	level notify( "notify_switch_lancer" );

	issue_color_orders ("r51", "allies");

	trigger_wait_targetname( "trig_lab_exit_security_doors" );

	issue_color_orders( "r52", "allies" );

	// Dialogue - Baker: "Fuck!  Security doors!"
	level.baker dialogue_queue( "sky_bak_labex_securitydoors" );
	//thread add_dialogue_line( "Baker", "Fuck!  Security doors!", "green" );

	wait 3;

	issue_color_orders( "r53", "allies" );	
	self set_fixednode_false();
	
	// Dialogue - Baker: "Use Xray to find and shoot the door's motor."
	level.baker dialogue_queue( "sky_bak_labex_xrayshootmotor" );
	//thread add_dialogue_line( "Baker", "Use Xray to find and shoot the door's motor.", "green" );
		
	while( ( level.enemies[ "it_lab1a" ].size + level.enemies[ "it_lab1b" ].size ) > 3 )
	{
		level.enemies[ "it_lab1a" ] = remove_dead_from_array( level.enemies[ "it_lab1a" ] );
		level.enemies[ "it_lab1b" ] = remove_dead_from_array( level.enemies[ "it_lab1b" ] );
		wait 0.05;
	}

	issue_color_orders( "r54", "allies" );

	while( ( level.enemies[ "it_lab1a" ].size + level.enemies[ "it_lab1b" ].size ) > 0 )
	{
		level.enemies[ "it_lab1a" ] = remove_dead_from_array( level.enemies[ "it_lab1a" ] );
		level.enemies[ "it_lab1b" ] = remove_dead_from_array( level.enemies[ "it_lab1b" ] );
		wait 0.05;
	}

	issue_color_orders( "r61", "allies" );
	self waittill( "goal" );
	level notify( "notify_baker_at_goal" );

	level.baker dialogue_queue( "sky_bak_labex_takepoint" );
	//thread add_dialogue_line( "Baker", "Spectre, take point!  I'll watch your back.  Go! Go! Go!", "green" );

	trigger_wait_targetname( "trig_lab_exit_powercore" );
	self enable_cqbwalk();

}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

spawn_it_lab_enemies()
{
	thread spawn_it_lab_enemies_lab1a();
	thread spawn_it_lab_enemies_lab1b();
	//thread spawn_it_lab_enemies_lab2();
	thread lab1a_fixednode_off();
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

lab1a_fixednode_off()
{
	level waittill( "notify_security_doors_opening" );
	foreach( guy in level.enemies[ "it_lab1a" ] )
	{
		guy set_fixednode_false();
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

spawn_it_lab_enemies_lab1a()
{
	level.enemies[ "it_lab1a" ] = [];

	enemy_spawner = GetEnt( "actor_spawn_escape_enemies_1", "targetname" ); 
	
	Assert( IsDefined( enemy_spawner ));

	trigger_wait_targetname( "trig_lab_exit_security_doors" );

	issue_color_orders( "p1", "axis" );

	number_of_enemies = 5;

	for( i = 0; i < number_of_enemies; i++ )
	{ 		
		enemy_spawner.count = 1;

		enemy = enemy_spawner spawn_ai();		
		
		enemy SetIsVisibleInXray();
		enemy SetEngagementMinDist( 129, 128 );		

		level.enemies[ "it_lab1a" ] = add_to_array( level.enemies[ "it_lab1a" ], enemy );
		wait 2; 
	}

	level notify( "notify_it_lab1a_enemies_spawned" );

	// Keep them stocked if player starts killing them before destroying motor
	while( !flag( "flag_security_doors_opening" ))
	{
		level.enemies[ "it_lab1a" ] = remove_dead_from_array( level.enemies[ "it_lab1a" ] );

		if( level.enemies[ "it_lab1a" ].size < number_of_enemies )
		{
			enemy_spawner.count = 1;

			enemy = enemy_spawner spawn_ai();		
				
			enemy SetIsVisibleInXray();
			enemy SetEngagementMinDist( 129, 128 );			
	
			level.enemies[ "it_lab1a" ] = add_to_array( level.enemies[ "it_lab1a" ], enemy );
			wait 2;
		}
		wait 0.05;
	}

	level.enemies[ "it_lab1a" ] = remove_dead_from_array( level.enemies[ "it_lab1a" ] );
	waittill_dead( level.enemies[ "it_lab1a" ] );

	level notify( "notify_it_lab1a_enemies_dead" );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

spawn_it_lab_enemies_lab1b()
{
	level.enemies[ "it_lab1b" ] = [];

	level waittill( "notify_it_lab1a_enemies_spawned" );

	while( level.enemies[ "it_lab1a" ].size > 2 )
	{
		level.enemies[ "it_lab1a" ] = remove_dead_from_array( level.enemies[ "it_lab1a" ] );
		wait 0.05;
	}

	enemy_spawner = GetEnt( "actor_spawn_escape_enemies_1", "targetname" ); 	
	Assert( IsDefined( enemy_spawner ));

	issue_color_orders( "p1", "axis" );

	for( i = 0; i < 2; i++ )
	{ 		
		enemy_spawner.count = 1;

		enemy = enemy_spawner spawn_ai();		

		enemy set_fixednode_false();
		enemy SetIsVisibleInXray();
		enemy SetEngagementMinDist( 129, 128 );
		

		level.enemies[ "it_lab1b" ] = add_to_array( level.enemies[ "it_lab1b" ], enemy );
		wait 2; 
	}

	level notify( "notify_it_lab1b_enemies_spawned" );

	level.enemies[ "it_lab1b" ] = remove_dead_from_array( level.enemies[ "it_lab1b" ] );

	waittill_dead( level.enemies[ "it_lab1b" ] );

	level notify( "notify_it_lab1b_enemies_dead" );
}


//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

spawn_it_lab_enemies_lab2()
{
	level.enemies[ "it_lab2" ] = [];

	trigger_wait_targetname( "trig_lab_exit_spawn_lab2_enemies" );
	enemy_spawner = GetEnt( "actor_spawn_escape_enemies_2", "targetname" ); 
	
	Assert( IsDefined( enemy_spawner ));	

	issue_color_orders( "o1", "axis" );

	for( i = 0; i < 2; i++ )
	{ 		
		enemy_spawner.count = 1;
		enemy = enemy_spawner spawn_ai();
		enemy set_fixednode_false();
		enemy SetIsVisibleInXray();	
		enemy SetEngagementMinDist( 129, 128 );	

		level.enemies[ "it_lab2" ] = add_to_array( level.enemies[ "it_lab2" ], enemy );
		wait 1; 
	}

	level.enemies[ "it_lab2" ] = remove_dead_from_array( level.enemies[ "it_lab2" ] );

	waittill_dead( level.enemies[ "it_lab2" ] );

	level notify( "notify_it_lab2_enemies_dead" );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

spawn_it_lab_enemies_group( enemy_spawnername, group_name, number, color, trigger, aggressive_mode )
{
	enemy_spawner = GetEnt( enemy_spawnername, "targetname" ); 
	
	Assert( IsDefined( enemy_spawner ));

	trigger_wait_targetname( trigger );

	issue_color_orders( color, "axis" );

	level.enemies[ group_name ] = [];

	for( i = 0; i < number; i++ )
	{ 		
		enemy_spawner.count = 1;
		enemy = enemy_spawner spawn_ai();

		if( aggressive_mode )
			enemy.aggressivemode = true;

		enemy set_fixednode_false();

		level.enemies[ group_name ] = add_to_array( level.enemies[ group_name ], enemy );
		wait 0.5; 
	}

	waittill_dead( level.enemies[ group_name ] );

	level notify( "notify_" + group_name + "_enemies_dead" );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

security_door_close()
{
	top_doors = GetEntArray( "brushmodel_security_door_top", "targetname" );
	bottom_doors = GetEntArray( "brushmodel_security_door_bottom", "targetname" );

	trigger_wait_targetname( "trig_lab_exit_security_doors" );

	Assert( IsDefined( top_doors ));
	Assert( IsDefined( bottom_doors ));
	
	// Close security doors
	foreach( door in top_doors )
	{
		door MoveTo( ( door.origin[0], door.origin[1], door.origin[2] - 85 ), 5 );
	}

	foreach( door in bottom_doors )
	{
		door MoveTo( ( door.origin[0], door.origin[1], door.origin[2] + 85 ), 5 );
	}
	
	wait 5;

	level notify( "notify_security_door_closed" );	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

security_door_stuck()
{
	top_doors = GetEntArray( "brushmodel_security_door_2_top", "targetname" );
	bottom_door = GetEnt( "brushmodel_security_door_2_bottom", "script_noteworthy" );
	mantle = GetEnt( "model_lab_exit_mantle", "script_noteworthy" );
	blocker = GetEnt( "brushmodel_security_door_blocker", "targetname" );

	Assert( IsDefined( top_doors ));
	Assert( IsDefined( bottom_door ));	
	Assert( IsDefined( mantle ));
	Assert( IsDefined( blocker ));

	// Break baker's path
	mantle LinkTo( bottom_door );

	trigger_wait_targetname( "trig_lab_exit_security_doors" );

	// Close security doors
	time = 5;

	foreach( door in top_doors )
	{
		door MoveTo( ( door.origin[0], door.origin[1], door.origin[2] - 85 ), time );
	}

	bottom_door MoveTo( ( bottom_door.origin[0], bottom_door.origin[1], bottom_door.origin[2] + 85 ), time );

	wait time;	
	level notify( "notify_security_doors_closed" );
											   
	// Player shoots switch
	door_motor = GetEnt( "brushmodel_security_door_motor", "targetname" );
	Assert( IsDefined( door_motor ));

	door_motor SetCanDamage( true );
	door_motor SetCanRadiusDamage( false );
	
	level notify( "notify_lab_exit_motor_search_starting" );	

	while( 1 )
	{
		door_motor waittill( "damage", damage, attacker );
		if( attacker == level._player )
			break;
	}

	PlayFXOnTag( GetFX( "spark_fountain" ), door_motor, "tag_origin" );

	//StopFXOnTag( GetFX( "spark_fountain" ), door_motor, "tag_origin" );

	level notify( "notify_security_doors_opening" );
	flag_set( "flag_security_doors_opening" );

	// Doors open up
	time = 10;

	foreach( door in top_doors )
	{
		door MoveTo( ( door.origin[0], door.origin[1], door.origin[2] + 85 ), time );
	}

	bottom_door MoveTo( ( bottom_door.origin[0], bottom_door.origin[1], bottom_door.origin[2] - 85 ), time );

	wait time;
	blocker ConnectPaths();
	blocker delete();

	level notify( "notify_security_doors_opened" );
}

xray_on_for_models()
{
	objects = GetEntArray( "model_xray_motor_parts", "script_noteworthy" );

	foreach( obj in objects )
	{
		obj SetIsVisibleInXray( true );	
	}
}


//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

spawn_security_door_enemies( sEnemy )
{
	enemies = [];
	spawners = GetEntArray( sEnemy, "script_noteworthy" );

	Assert( IsDefined( spawners ));

	trigger_wait_targetname( "trig_lab_exit_security_doors" );

	array_thread( spawners, ::add_spawn_function, ::spawnfunc_spawn_security_door_enemies );
	
	for( i = 0; i < spawners.size; i++ )
	{ 		
		enemies[ i ] = spawners[ i ] spawn_ai();
		wait 0.5; 
	}

	level waittill( "notify_security_door_closed" );

	foreach( guy in enemies )
	{
		if( isalive( guy ))
		{
			guy delete();
		}
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

spawnfunc_spawn_security_door_enemies()
{
	self.ignoreall = true;
}

