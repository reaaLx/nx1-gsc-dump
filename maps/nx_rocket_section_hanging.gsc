
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
#include maps\_hud_util;


start()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_hanging" );

	// Turn off AA turret section smoke
	maps\nx_rocket_util::pre_turret_event();

	teleport_info = [];
	teleport_info[ "ALLY_BAKER" ]		= "start_default_ally_00";
	teleport_info[ "ALLY_JENKINS" ]		= "start_default_ally_01";
	teleport_info[ "ALLY_WILLIAMS" ]	= "start_default_ally_02";
	maps\nx_rocket_util::squad_teleport( teleport_info );
}

main()
{
	level thread player_hanging();

	// Return to standard FOV now that we're out of the helicopter turret.
	SetSavedDvar( "cg_fov", 65.0 );
	
	flag_set("hanging_player_start_before_fadein");

	// Stop the low frequency chopper rumble
	thread maps\nx_rocket_util::slightly_vibrate_camera_end();

	//ambient fx
	thread maps\nx_rocket_fx::hanging_amb_fx();
	thread maps\_utility::set_ambient( "nx_rocket_ext" );

//  hanging_intro();
	black_overlay = create_client_overlay( "black", 1 );

	enemies_setup();
	allies_setup();
	player_setup();

	level thread section_dialogue();

	// SAVE POINT
	level thread autosave_now();

	wait 7.0;
	flag_set( "vo_hanging_wake_up_01" );
	black_overlay Destroy();
	maps\nx_rocket_anim::hanging_setup();
	thread hanging_fade_in();

	flag_set( "vo_hanging_wake_up_02" );

	flag_set( "hanging_player_start" );
	level thread interrogation_start();

	level waittill( "hanging_player_free" );

//  level.squad[ "ALLY_JENKINS" ].ignoreAll = false;
//  level.squad[ "ALLY_WILLIAMS" ].ignoreAll = false;
//
//  teleport_info = [];
//  teleport_info[ "ALLY_WILLIAMS" ]	= "start_hanging_ally_02";
//  maps\nx_rocket_util::squad_teleport( teleport_info );
//

//  // SAVE POINT
//  level thread autosave_now();

//  ally_chopper_reveal();

	foreach( ally in level.squad )
	{
		ally.ignoreAll = false;
		ally.ignoreMe = false;
	}
}

//*******************************************************************
//    ALLIES                                                        *
//                                                                  *
//*******************************************************************
allies_setup()
{
	foreach( ally in level.squad )
	{
		ally.ignoreAll = true;
		ally.ignoreMe = true;
	}

//  level.squad[ "ALLY_JENKINS" ].ignoreAll = true;
//  level.squad[ "ALLY_WILLIAMS" ].ignoreAll = true;

	teleport_info = [];
	teleport_info[ "ALLY_BAKER" ]		= "start_default_ally_00";
	teleport_info[ "ALLY_JENKINS" ]		= "start_hanging_ally_01";
	teleport_info[ "ALLY_WILLIAMS" ]	= "start_default_ally_02";
	maps\nx_rocket_util::squad_teleport( teleport_info );


	level.squad[ "ALLY_JENKINS" ] ally_drop_weapon();
	level.squad[ "ALLY_WILLIAMS" ] ally_drop_weapon();
}

ally_drop_weapon()
{
	self DropWeapon( self.weapon, "right", 1 );
}

ally_chopper_reveal()
{
	maps\nx_rocket_anim::woods_chopper_fly_over( level.squad[ "ALLY_WILLIAMS" ] );
	maps\nx_rocket_util::squad_color_reset();
}

//*******************************************************************
//    ENEMIES                                                       *
//                                                                  *
//*******************************************************************
enemies_setup()
{
	level.hanging_enemies = [];
	foreach( spawner in GetEntArray( "hanging_enemy", "script_noteworthy" ) )
	{
		enemy = spawner spawn_ai( true );
		enemy.health = 5;
		enemy.disableLongDeath = true;
		enemy.animname = spawner.targetname;
		enemy.ignoreAll = true;
		enemy maps\nx_rocket_util::attach_flashlight_gun( true );
		level.hanging_enemies[ spawner.targetname ] = enemy;
		wait( 0.05 );
	}
}

enemy_flashlights_off()
{

	foreach( enemy in level.hanging_enemies )
	{
		enemy maps\nx_rocket_util::attach_flashlight_gun( false );
	}
}

//*******************************************************************
//    PLAYER                                                        *
//                                                                  *
//*******************************************************************
player_setup()
{
}

player_remove_all_weapons()
{
	self.weapons_stored = [];
	self.weapons_stored[ "primary" ] = self GetWeaponsList("primary");
	self.weapons_stored[ "offhand" ] = self GetWeaponsList("offhand");
//  self.weapons_stored[ "altmode" ] = self GetWeaponsList("altmode");

	foreach(weapon_type in self.weapons_stored)
	{
		foreach( weapon in weapon_type )
		{
			self TakeWeapon(weapon);
		}		
	}
}

player_restore_all_weapons()
{
	if( !IsDefined( self.weapons_stored ) )
		return;

	foreach(weapon_type in self.weapons_stored)
	{
		foreach( weapon in weapon_type )
		{
			self GiveWeapon( weapon );
			self GiveStartAmmo( weapon );
		}
	}
}

player_hanging()
{
	level._player SwitchToWeapon( level._gunSidearm );
	wait 0.25;
	level._player DisableWeaponSwitch();
	level._player DisableOffhandWeapons();

	cut_trigger = GetEnt( "hanging_trigger_cut", "targetname" );
	cut_trigger SetHintString( "Hold [{+usereload}] to cut straps" );	// TODO: Localize
	cut_trigger trigger_off();

//  level._player player_remove_all_weapons();
//  level._player store_players_weapons( "hanging" );

//  level._player GiveWeapon( level._gunSidearm );

	player_state_hanging( true );
	player_state_vignette( true );

	start = GetEnt( "origin_hanging_start", "script_noteworthy" );
	start_lookat = GetEnt( start.target, "targetname" );
	start.angles = VectorToAngles( start_lookat.origin - start.origin );
	start.angles = ( 0, start.angles[1], 0 );

	player_rig = spawn_anim_model( "player_rig" );
//  player_rig.origin = start.origin;
//  player_rig.angles = start.angles;
	
	player_ground_origin = Spawn( "script_origin", ( 0, 0, 0 ) );
	player_ground_origin LinkTo( player_rig, "tag_player" );
	level._player PlayerSetGroundReferenceEnt( player_ground_origin );
	level._player SetOrigin( player_rig.origin );
	level._player SetPlayerAngles( player_rig.angles );
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, 0, 0, 0, 0 );

	flag_wait( "hanging_player_start" );
	// VIGNETTE: Wake up
//  start anim_single_solo( player_rig, "hanging_wakeup" );
	maps\nx_rocket_anim::hanging_wakeup( player_rig, level.squad[ "ALLY_WILLIAMS" ] );

	// SAVE POINT
	level thread autosave_now();

	player_rig Hide();
//  player_rig thread hanging_camera_turn( "end_camera_turn" );
	
	player_state_vignette( false );
//  level._player SwitchToWeapon( level._gunSidearm );

	level._player thread notify_on_fire();
	level._player thread fail_on_fire();
//  level._player thread slowmo_on_fire();

	waittill_aigroupcleared( "hanging_enemy" );
	wait 1.0;

	////////////////
	// GREENLIGHT: End the mission here
	wait 6.0;
	nextmission();
	wait 7.0;
	////////////////

	cut_trigger trigger_on();
	cut_trigger waittill( "trigger" );
	cut_trigger trigger_off();

	// VIGNETTE: Cut and fall
	player_state_vignette( true );
	knife = spawn( "script_model", (0,0,0) );
	knife SetModel( "viewmodel_knife" );
	knife LinkTo( player_rig, "tag_knife_attach", (0,0,0), (0,-180,-180) );
	player_rig Show();

	knife thread wait_then_hide( 9.0 );
	maps\nx_rocket_anim::hanging_cutdown( player_rig, level.squad[ "ALLY_WILLIAMS" ] );
//  start anim_single_solo( player_rig, "hanging_player_fall" );
	player_state_hanging( false );
	knife Delete();
	player_rig Delete();

	level._player SetPlayerAngles( start.angles );

	wait 0.5;

//  level._player player_restore_all_weapons();
//  level._player restore_players_weapons( "hanging" );
	level._player EnableWeaponSwitch();
	level._player EnableOffhandWeapons();

	level._player SwitchToWeapon( level._main_gun );

	player_state_vignette( false );

	level notify( "hanging_player_free" );
}

player_state_hanging( enable )
{
	level._player AllowCrouch( !enable );
	level._player AllowProne( !enable );		

	if( enable )
	{
	}
	else
	{
		level._player Unlink();
		level._player PlayerSetGroundReferenceEnt( undefined );
	}
}

player_state_vignette( enable )
{
	if( enable )
	{
		level._player HideViewModel();
		level._player DisableWeapons();
		level._player LerpViewAngleClamp( 0.5, 0.25, 0.25, 0, 0, 0, 0 );
	}
	else
	{
		level._player ShowViewModel();
		level._player EnableWeapons();
		level._player LerpViewAngleClamp( 1, 0.25, 0.25, 40, 40, 180, 180 );
	}
}

//*******************************************************************
//    INTERROGATION                                                 *
//                                                                  *
//*******************************************************************
interrogation_start()
{
	flag_set( "interrogation_started" );
	level thread vignette_interrogation();
	interrogation_update();
}

vignette_interrogation()
{
	level endon( "hanging_interrogation_success" );
	level endon( "hanging_interrogation_failure" );

	maps\nx_rocket_anim::hanging_interrogation(
		level.squad[ "ALLY_JENKINS" ], 
		level.hanging_enemies[ "hanging_enemy_01" ],
		level.hanging_enemies[ "hanging_enemy_02" ],
		level.hanging_enemies[ "hanging_enemy_03" ] 
		);

	// WAIT LOOP
	if( !flag( "hanging_player_fired" ) )
	{
		INTERROGATION_LOOP_TIME = 7.0;

		node = getstruct("vignette_crash_site_wakeup_allyshot", "script_noteworthy");
		guys = [ level.squad["ALLY_JENKINS"] ];
		guys = array_combine( guys, level.hanging_enemies );
	
		node thread anim_loop( guys, "hanging_loop", "player_fired" );
		node thread end_loop_on_player_fire();
	
		wait INTERROGATION_LOOP_TIME;
	}

	level thread interrogation_fail();
}

end_loop_on_player_fire()
{
	flag_wait( "hanging_player_fired" );
	self notify( "player_fired" );
}

interrogation_update()
{
	foreach( name, enemy in level.hanging_enemies )
	{
		enemy thread enemy_interrogation_update( name );
	}
}

interrogation_fail()
{
	interrogation_end( false );

	// FAIL

	level._player DisableWeapons();

	maps\nx_rocket_anim::hanging_execution( 
		level.squad[ "ALLY_JENKINS" ],
		level.hanging_enemies[ "hanging_enemy_03" ]
		);	

	SetDvar( "ui_deadquote", "You failed to rescue Cameron!" );
	level notify( "mission_failed" );
	maps\_utility::missionFailedWrapper();
}

interrogation_success()
{
	interrogation_end( true );

	// STRUGGLE
	flag_set( "jenkins_rescued" );
	flag_set( "vo_hanging_jenkins_rescued" );

	struggle_enemy = level.hanging_enemies[ "hanging_enemy_01" ];
	// SWAP THE ENEMIES WHEN WE GET THE COOL NEW ANIM
//  if( !IsAlive( level.hanging_enemies[ "hanging_enemy_01" ] ) )
//  	struggle_enemy = level.hanging_enemies[ "hanging_enemy_03" ];

	struggle_enemy.ignoreAll = true;
	maps\nx_rocket_anim::hanging_struggle(
		level.squad[ "ALLY_JENKINS" ],
		struggle_enemy
		);

//  struggle_enemy enemy_exit_vignette();

	level.squad[ "ALLY_JENKINS" ].ignoreAll = false;
	level.squad[ "ALLY_JENKINS" ].ignoreMe = false;

	level.squad[ "ALLY_JENKINS" ] Melee();
}

interrogation_end( success )
{
	if( success )
		flag_set( "hanging_interrogation_success" );
	else
		flag_set( "hanging_interrogation_failure" );

	if( success )
	{
		foreach( enemy in level.hanging_enemies )
		{
			enemy thread enemy_interrogation_end();
		}
	}

	// FLASHLIGHTS OFF
	enemy_flashlights_off();

	level.squad[ "ALLY_JENKINS" ] StopAnimScripted();
}

notify_on_fire()
{
	self NotifyOnPlayerCommand( "player_fired", "+attack" );
	self waittill( "player_fired" );
	flag_set( "hanging_player_fired" );
}

fail_on_fire()
{
//  self waittill( "player_fired" );
	flag_wait( "hanging_player_fired" );
	wait 0.15;

	if( flag( "hanging_interrogation_success" ) )
		return;

	self.ignoreMe = false;
	level.hanging_enemies[ "hanging_enemy_01" ] StopAnimScripted();
	level.hanging_enemies[ "hanging_enemy_01" ].ignoreAll = false;
	level.hanging_enemies[ "hanging_enemy_02" ] StopAnimScripted();
	level.hanging_enemies[ "hanging_enemy_02" ].ignoreAll = false;
}

slowmo_on_fire()
{
//  self waittill( "player_fired" );
	flag_wait( "hanging_player_fired" );

	normal_scale = 1.0;
	slow_scale = 0.25;
	time_in = 0.25;
	time_out = 0.5;
	struggle_anim = level.squad[ "ALLY_JENKINS" ] getanim( "hanging_struggle" );
//  wait_time = GetAnimLength( struggle_anim );
	wait_time = 2.25;

	SetSlowMotion( normal_scale, slow_scale, time_in );
	wait wait_time;
	SetSlowMotion( slow_scale, normal_scale, time_out );
}

enemy_interrogation_end()
{
	if( !IsAlive( self ) )
		return;

	self StopAnimScripted();
	wait 0.35;
	self.ignoreAll = false;
}

enemy_interrogation_update( name )
{
	level endon( "hanging_interrogation_failure" );
	level endon( "hanging_interrogation_success" );

	self waittill( "damage" );
//  self thread maps\_nx_vignette_util::vignette_actor_kill();
	self thread enemy_exit_vignette();
	
	level thread interrogation_success();

//  if( name == "hanging_enemy_03" )
//  	level thread interrogation_success();
//  else
//  	level thread interrogation_fail();
}

enemy_exit_vignette()
{
	self StopAnimScripted();
	self.allowdeath = true;
	wait 0.05;
	self Kill();
}

//*******************************************************************
//    HELPERS                                                       *
//                                                                  *
//*******************************************************************
hanging_intro()
{
	black_overlay = create_client_overlay( "black", 1 );
	wait 4.0;
	black_overlay Destroy();
}

hanging_fade_in()
{
	thread hanging_blur_in();
	black_overlay = create_client_overlay( "black", 1 );
	wait 0.5;

	for( i = 0; i < 3; i ++ )
	{
		black_overlay fade_over_time( 1, 0.5 );		// Fade Out
		wait RandomFloatRange( 0.4, 0.8 );			// Hold
		black_overlay fade_over_time( 0, 1.0 );		// Fade In
		wait RandomFloatRange( 0.2, 0.4 );			// Hold
	}

	black_overlay Destroy();
	level notify( "hanging_fade_in" );
}

hanging_blur_in()
{
	SetBlur( 6, 0 );
	wait 1.0;
	SetBlur( 0, 6 );
}

hanging_camera_turn( end_on )
{
	self endon( end_on );
	self endon( "death" );

	interval = 0.05;

	yaw_range_min = 16.5;
	yaw_range_max = 20;
	yaw_range = yaw_range_max;

	speed_min	= 18.0; // deg/sec
	speed_max	= 45.0; // deg/sec
	speed 		= speed_max; // deg/sec
	
	theta = 0;
	original_yaw = self.angles[ 1 ];

	while( 1 )
	{
		rot = speed * interval;
		theta += rot;

		if( theta >= 360 )
			theta = 0;

		self.angles = ( self.angles[ 0 ], original_yaw + sin( theta ) * yaw_range, self.angles[ 2 ] );
		wait interval;


		if( speed <= speed_min )
			speed = speed_min;
		else
			speed -= 1 * interval;

		if( yaw_range <= yaw_range_min )
			yaw_range = yaw_range_min;
		else
			yaw_range -= 1 * interval;
	}	
}

wait_then_hide( wait_time )
{
	wait wait_time;
	self Hide();
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
section_dialogue()
{
	enemy_01 = level.hanging_enemies[ "hanging_enemy_01" ];

	//Today must be your lucky day, asshole.
	enemy_01 thread play_dialogue( "roc_ec1_hang_luckyday", 25 );
	//Where are your friends?
	enemy_01 thread play_dialogue( "roc_ec1_hang_whereareyourfriends", 30 );
	//If you don't answer me, you're going to be a dead man!
	enemy_01 thread play_dialogue( "roc_ec1_hang_deadman", 34 );

	flag_wait("hanging_interrogation_success");
	//<grunts of pain>
	enemy_01 thread play_dialogue( "roc_ec2_hang_grunt_01", 1.0 );
	//<grunts of pain>
	enemy_01 thread play_dialogue( "roc_ec2_hang_grunt_02", 2.0 );

//    flag_wait( "vo_hanging_wake_up_01" );
//
////  add_dialogue_line( "Williams", "Lockwood!", undefined, 1.0 );
//    maps\nx_rocket_util::wait_play_dialogue_wait( 1, "roc_wil_hanging_lockwood1" );
//
//    flag_wait( "vo_hanging_wake_up_02" );
//    wait 6.0;
//
////  add_dialogue_line( "Williams", "Lockwood!", undefined, 1.0 );
//    maps\nx_rocket_util::wait_play_dialogue_wait( 0.5, "roc_wil_hanging_lockwood2" );
//
//////  add_dialogue_line( "Williams", "Lockwood! Wake up, man!", undefined, 1.0 );
////    maps\nx_rocket_util::wait_play_dialogue_wait( 0.5, "roc_wil_hanging_lockwoodwakeup" );
//
////  add_dialogue_line( "Williams", "You're alive! Is Jenkins okay?", undefined, 1.0 );
////  maps\nx_rocket_util::wait_play_dialogue_wait( 1.0, "roc_wil_hanging_isjenkinsok" );
//
////  add_dialogue_line( "Williams", "Let me see if I can cut you down from there. Hang on.", undefined, 2.0 );
//    maps\nx_rocket_util::wait_play_dialogue_wait( 6.0, "roc_wil_hanging_cutyoudown" );
//
////  add_dialogue_line( "Williams", "Oh shit, we've got company. Keep quiet and hang tight.", undefined, 2.0 );
//    maps\nx_rocket_util::wait_play_dialogue_wait( 4.0, "roc_wil_hanging_gotcompany" );
//
////  add_dialogue_line( "Williams", "They're going to kill Jenkins, man. Do something!", undefined, 3.0 );
////  maps\nx_rocket_util::wait_play_dialogue_wait( 3.0, "roc_wil_hanging_dosomething" );
//
//    level waittill( "hanging_player_free" );
//    maps\nx_rocket_util::wait_play_dialogue_wait( 3.0, "roc_jen_hang_thoughtiwasdead" );
}

section_precache()
{
	PrecacheItem( "nx_walther_p22" );
	PrecacheModel( "viewmodel_knife" );
	precacheModel( "com_flashlight_on" );
}


section_flag_inits()
{
	flag_init( "hanging_player_start_before_fadein" );
	flag_init( "hanging_player_start" );
	flag_init( "interrogation_started" );
	flag_init( "jenkins_rescued" );
	flag_init( "vo_hanging_wake_up_01" );
	flag_init( "vo_hanging_wake_up_02" );
	flag_init( "vo_hanging_jenkins_rescued" );
	flag_init( "hanging_player_fired" );

	flag_init( "hanging_interrogation_success" );
	flag_init( "hanging_interrogation_failure" );
}
