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
// ELEVATOR                                                         *
//                                                                  *
//*******************************************************************

elevator_start()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_elevator" );
	thread maps\nx_skyscraper_fx::set_vision_and_fog("interior_elevator_shaft", 0); // set appropriate vision and fog

	thread maps\_utility::set_ambient( "amb_skyscraper_lobby_int" );

	maps\nx_skyscraper_util::spawn_business_baker();
	level.baker maps\nx_skyscraper_anim::enable_casual_lobby_anims();
	level.baker gun_remove();
	baker_teleport = GetEnt ("baker_elevator_teleport", "targetname");
	level.baker ForceTeleport( baker_teleport.origin, baker_teleport.angles);

	maps\nx_skyscraper_util::player_remove_abilities();

	// Make elevator transparent at start.
	thread fx_elevator_glass_cycle( 0, 999, "player_elevator" );

	// Hide cloud ring.
	thread fx_hide_cloud_ring();

	thread maps\nx_skyscraper_drive_up::lobby_elevator_behavior();

	maps\nx_skyscraper_drive_up::player_elevator_setup();
	maps\nx_skyscraper_elevator::elevator_vertical_teleport( "player_elevator", 15 );
	wait 1;
	thread maps\nx_skyscraper_drive_up::lobby_player_elevator_descent(  );

	trigger = GetEnt ("obj_enter_elevator", "targetname");
	trigger notify ( "trigger" );
}

elevator_sequence()
{
	issue_color_orders( "r5", "allies" );
	// Make elevator transparent at start.
	thread fx_elevator_glass_cycle( 0, 999, "player_elevator" );

	// elevator_door_move ( "player_elevator", "open");
	flag_wait ("player_elevator_ready");
	// Baker moves into elevator
	issue_color_orders( "r6", "allies" );

	path_mesh_helper_delete();

	trigger = GetEnt ("obj_reach_freight_shaft", "targetname");

	thread baker_enters_elevator();

	// Wait until the player is in the elevator
	trigger waittill ("trigger");

	thread maps\nx_skyscraper_fx::set_vision_and_fog("interior_elevator_shaft", 1); // set appropriate vision and fog

	// Wait for Baker to enter the elevator
	while ( !level.baker isTouching ( trigger ))
	{
		wait .5;
	}

	//play the vignette of baker kicking out the civ
	maps\nx_skyscraper_anim::elevator_push_spawn();

	while ( 1 )
	{
		
		trigger waittill ("trigger");
		thread elevator_door_move ( "player_elevator", "close");
		elevator_door_move ( "player_elevator_facade", "close");
		// Ensure the player is still in the elevator
		if ( level._player isTouching ( trigger ))
			break;
		//thread add_dialogue_line( "Baker", "Get in here, Spectre.", "green", 2 );
		level.baker dialogue_queue( "sky_bak_lobby_getinhere" );
		thread elevator_door_move ( "player_elevator", "open");
		elevator_door_move ( "player_elevator_facade", "open");
	}
	thread elevator_ceiling_light();
	thread maps\_utility::set_ambient( "amb_skyscraper_elevator_int" );

	thread shaft_fall_watcher_1();

	// Checkpoint!
	thread autosave_now();



	wait .1;

	// Elevator ascends
	thread elevator_vertical_move( "player_elevator", 161, 40 );
	flag_set ("elevator_in_motion");

	wait 2;

	// Make elevator opaque.
	thread fx_elevator_glass_cycle( 1, -0.25, "player_elevator" );
	
	// thread elevator_mascot_monolog();
	thread elevator_dialog();
	// thread elevator_security_feed(); // Re-enable this line to see the security feed PIP sequence

	wait 7;
	level notify ("clean_up_lobby");
	flag_set ("outelevator_fg");
	level.baker maps\nx_skyscraper_anim::disable_casual_lobby_anims();
	level waittill ("floor_reached");

	flag_wait ("player_in_shaft");
	// thread elevator_other_movement();
	// shaft_sequence();
}


baker_enters_elevator()
{
	flag_wait ("player_elevator_ready");
	level.baker waittill ("goal");
	node = GetEnt ("player_elevator_anim_node", "targetname");

	node anim_reach_solo (level.baker, "elevator_idle_loop");
	level.baker linkto (node);
	node thread anim_loop_solo (level.baker, "elevator_idle_loop", "stop_idle");
		
	flag_set ("baker_in_elevator");
	flag_wait ("outelevator_fg");
	node notify ("stop_idle"); 
	level waittill ("floor_reached");

	//level.baker unlink();
}

elevator_vertical_move( elevator, floors, time )
{
	// convert number of floors into height in units
	height = (128 * floors);

	elevator_sfx = level._player;

	// Get all the entities in the elevator
	elevator_parts = GetEntArray( elevator , "script_noteworthy" );

	// Move the elevator upwards
	foreach( part in elevator_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_origin" ||  part.classname == "script_model" ||  part.classname == "light_spot" )
		{
			if ( isdefined ( part.targetname) && ( part.targetname == "exterior_door_left" || part.targetname == "exterior_door_right") )
			{
				
			}
			else
			{
				part  MoveTo( part.origin + (0, 0, height), time, 2, 2 );
				if( elevator == "elevator_1" )
				{
					elevator_sfx = part;				
				}
			}
		}
	}

	if( elevator == "player_elevator" && floors != -15 )
	{
		//elevator_sfx playsound("skyscraper_elevator_startup");

		//Commenting out for Tom to test
		//elevator_sfx thread maps\nx_skyscraper_audio::player_elevator_ride_up_sfx();	
	}

	wait time;
	if( elevator == "player_elevator" )
	{
		level notify ("floor_reached");
	}
	
}

elevator_ceiling_light()
{
	light_location = GetEnt ("light_location", "targetname");
	PlayFXOnTag( level._effect[ "elevator_ceiling_light" ], light_location, "tag_origin" );
	flag_wait ("elevator_out_lift_done");
	StopFXOnTag ( level._effect[ "elevator_ceiling_light" ], light_location, "tag_origin", true );
}

elevator_vertical_teleport( elevator, floors )
{
	// convert number of floors into height in units
	height = (128 * floors);

	// Get all the entities in the elevator
	elevator_parts = GetEntArray( elevator , "script_noteworthy" );

	// Teleport them up/down the number of floors
	foreach( part in elevator_parts )
	{
		if( part.classname == "script_brushmodel" || part.classname == "script_origin" ||  part.classname == "script_model" ||  part.classname == "light_spot")
		{
			if ( isdefined ( part.targetname) && (part.targetname == "exterior_door_left" || part.targetname == "exterior_door_right") )
			{
				
			}
			else
			{
				// part.origin = (part.origin + (0,0,height));
				part  MoveTo( part.origin + (0, 0, height), 0.1, 0, 0 );
			}
		}
	}
}
/*
elevator_horizontal_move( elevator, direction )
{
	normal = undefined;
	distance = undefined;
	time = 4;

	// "out" means towards the outside of the curve, "in" means towards the inside of the curve.
	if ( direction == "out" )
	{	
		distance = 180;
	}
	if ( direction == "in" )
	{
		distance = -180;
	}
	if ( direction == "freight" )
	{
		distance = 360;
	}

	elevator_parts = GetEntArray( elevator , "script_noteworthy" );

	foreach( part in elevator_parts )
	{
		if ( IsDefined ( part.targetname) && part.targetname == "elevator_bottom")
		{
			forward = AnglesToForward( part.angles ); 
			normal = VectorNormalize( forward );
			
		}
	}

	foreach( part in elevator_parts )
	{

		if( part.classname == "script_brushmodel" || part.classname == "script_origin" ||  part.classname == "script_model" ||  part.classname == "light_spot" )
		{
			part MoveTo( part.origin + (distance * normal), time, 1, 1 );
		}

	}

	wait time;
}

elevator_security_feed()
{
	level waittill ("show_security_feed");
	thread maps\nx_skyscraper_util::pip_setup();
	player_proxy = spawn ("script_model", level._player.origin + (0,0,32));
	player_proxy SetModel ("toy_alien");
	player_proxy linkto ( level._player);
	show_elevator_camera( "player_elevator" );
	level waittill ("show_masked_security_feed");
	show_elevator_camera( "fake_elevator" );
	player_proxy delete();
	wait 5;
	level notify ("remove_pip");
}
*/
elevator_dialog(  )
{
	wait 1;
	// add_dialogue_line( "Baker", "(Sigh) Team A, please tell me you've taken care of the security cameras.", "green", 3 );
	level.baker dialogue_queue( "sky_bak_elevator_securitycameras" );
	// add_dialogue_line( "Team A", "Just a minute. We're still decrypting the feed.", "purple", 2 );
	radio_dialogue ("sky_teama_elevator_decrypting");
	// level notify ("show_security_feed");
	// add_dialogue_line( "Baker", "I see it. Spectre's masked but I'm still here.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_elevator_iseeit" );
	// add_dialogue_line( "Team A", "Be patient.", "purple", 2 );
	radio_dialogue ("sky_teama_elevator_bepatient");
	wait 2;
	// level notify ("show_masked_security_feed");
	// add_dialogue_line( "Team A", "There it is. You are clear to continue.", "purple", 2 );
	radio_dialogue ("sky_teama_elevator_thereitis");
	// add_dialogue_line( "Baker", "Roger that. Time to suit up, Spectre.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_elevator_suitup" );
}

elevator_pattern_1( elevator, passenger1, passenger2, node )
{
	level endon ("freight_elevator_stop");
	
	
		thread elevator_vertical_move( elevator, 15, 8 );
		wait 2;
		thread fx_elevator_glass_cycle( 1, -0.25, elevator );
		wait 9;
		thread elevator_vertical_move( elevator, -15, 8 );
		wait 6;
		thread fx_elevator_glass_cycle( 0, 1, elevator );
		wait 2;
		elevator_door_move ( elevator, "open");
		level.passengers[ passenger1 ] thread maps\nx_skyscraper_drive_up::goal_node_target_pathing( node );
		wait .5;
		level.passengers[ passenger2 ] thread maps\nx_skyscraper_drive_up::goal_node_target_pathing( node );
		wait 3;
		elevator_door_move ( elevator, "close");
		wait 2;
		thread elevator_vertical_move( elevator, 15, 8 );
		wait 2;
		thread fx_elevator_glass_cycle( 1, -0.25, elevator );
		// elevator notify ("at_ground_floor");
	
}


/*
elevator_pattern_2( elevator )
{
	level endon ("freight_elevator_stop");
	while ( 1)
	{
		elevator_horizontal_move( elevator, "out" );
		elevator_vertical_move( elevator, 18, 13 );
		elevator_horizontal_move( elevator, "in" );
		elevator_vertical_move( elevator, -18, 13 );
	}
}

elevator_pattern_3( elevator )
{
	level endon ("freight_elevator_stop");
	while ( 1)
	{
		// wait 1;
		elevator_vertical_move( elevator, -4, 6 );
		wait 22;
		elevator_vertical_move( elevator, -14, 16 );
	}
}

elevator_pattern_4( elevator )
{
	level endon ("freight_elevator_stop");
	while ( 1)
	{
		elevator_horizontal_move( elevator, "in" );
		elevator_vertical_move( elevator, 6, 6 );
		elevator_horizontal_move( elevator, "out" );
		level notify ("hazard_elevator_clear");
		elevator_vertical_move( elevator, 16, 14 );

	}
}

elevator_pattern_5( elevator )
{
	level endon ("freight_elevator_stop");
	while ( 1)
	{
		elevator_vertical_move( elevator, -26, 12 );
		elevator_vertical_move( elevator, 26, 12 );
	}
}

elevator_pattern_6( elevator )
{
	level endon ("freight_elevator_stop");
	while ( 1)
	{
		elevator_vertical_move( elevator, 26, 12 );
		elevator_vertical_move( elevator, -26, 12 );
	}
}

elevator_pattern_7( elevator )
{
	level endon ("freight_elevator_stop");
	while ( 1)
	{
		elevator_vertical_move( elevator, 52, 24 );
		elevator_vertical_move( elevator, -52, 24 );
	}
}

elevator_pattern_8( elevator )
{
	elevator_vertical_move( elevator, 12, 20 );
	flag_set ("ally_elevator_in_position");
}

show_elevator_camera( elevator )
{

	elevator_parts = GetEntArray( elevator , "script_noteworthy" );

	foreach( part in elevator_parts )
	{
		if ( IsDefined ( part.targetname) && part.targetname == "elevator_camera")
		{
			level._player AlternateSceneCameraLinkTo( part , "tag_origin", 90  );
		}
	}
}
*/
elevator_door_move ( elevator, direction )
{
	normal = undefined;
	distance = undefined;
	time = 2.5;

	if ( direction == "open" )
	{	
		distance = 40;
	}
	if ( direction == "close" )
	{
		distance = -40;
	}
	if ( direction == "freight_open" )
	{	
		distance = 64;
	}


	elevator_parts = GetEntArray( elevator , "script_noteworthy" );

	foreach( part in elevator_parts )
	{
		if ( IsDefined ( part.targetname) && part.targetname == "elevator_bottom")
		{
			right_angle = (part.angles + (0,90,0));
			right = AnglesToRight( right_angle ); 
			normal = VectorNormalize( right );
			// iprintln ("normal: " + normal);
			
		}
	}

	foreach( part in elevator_parts )
	{
		if( IsDefined ( part.targetname) && ( part.targetname == "door_right" || part.targetname == "exterior_door_right"))
		{
			if ( direction == "open" )
			{
				part ConnectPaths();
				if ( elevator == "player_elevator" )
				{
					part playsound("skyscraper_elevator_door_open_r");
				}
			}
			if ( direction == "close" )
			{
				part DisconnectPaths();
				if ( elevator == "player_elevator" )
				{
					part playsound("skyscraper_elevator_door_close_r");
				}
			}
			part MoveTo( part.origin + (distance * normal), time, .5, .5 );
		}
		if( IsDefined ( part.targetname) && ( part.targetname == "door_left" || part.targetname == "exterior_door_left"))
		{
			if ( direction == "open" )
			{
				part ConnectPaths();
				if ( elevator == "player_elevator" )
				{
					part playsound("skyscraper_elevator_door_open_l");
				}

			}
			if ( direction == "close" )
			{
				part DisconnectPaths();

				if ( elevator == "player_elevator" )
				{
					part playsound("skyscraper_elevator_door_close_l");
				}
			}
			part MoveTo( part.origin + (distance * normal * -1), time, .5, .5 );
		}
	}
	wait time;
}

//*******************************************************************
// SHAFT                                                            *
//                                                                  *
//*******************************************************************

shaft_start()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_shaft" );
	thread maps\nx_skyscraper_fx::set_vision_and_fog("interior_elevator_shaft", 0); // set appropriate vision and fog
	flag_set ("elevator_out_lift_done");
	path_mesh_helper_delete();

	thread maps\_utility::set_ambient( "amb_skyscraper_elevator_shaft" );

	maps\nx_skyscraper_util::spawn_baker();
	baker_teleport = GetEnt ("baker_shaft_teleport", "targetname");
	level.baker ForceTeleport( baker_teleport.origin, baker_teleport.angles);
 
	thread elevator_vertical_teleport( "player_elevator", 161);

	maps\nx_skyscraper_util::player_remove_abilities();

}

shaft_sequence()
{
	thread maps\_utility::set_ambient( "amb_skyscraper_elevator_shaft" );
	thread shaft_fall_watcher_2();
	thread autosave_now();

	flag_wait ("elevator_out_lift_done");

	// make second jump blocker not solid
	blocker = GetEnt ("player_second_jump_blocker", "targetname");
	blocker NotSolid();
	
	level._player AllowJump(true);

	setsaveddvar( "r_spotlightbrightness", "2" );
	PlayFXOnTag( level._effect[ "flashlight_spotlight" ], level.baker, "tag_flash" );
	PlayFXOnTag( level._effect[ "flashlight" ], level.baker, "tag_flash" );
	thread shaft_dialog();

	//Play Baker Vignette Walking accross the shaft - Baker shoudl end in idle
	thread maps\nx_skyscraper_anim::elevator_shaft1_baker();
	//Play a close encounter with an elevator
	//trigger = GetEnt ("player_enter_elevator_shaft_e2", "targetname");
	//trigger waittill ("trigger");
	//thread maps\nx_skyscraper_anim::elevator_shaft1_e2();
	//Play Player Vignette Going Around obstacle
	trigger = GetEnt ("player_enter_elevator_shaft_pole", "targetname");
	//trigger SetHintString( &"NX_SKYSCRAPER_HINT_POLE" );
	trigger waittill ("trigger");
	trigger trigger_off();
	maps\nx_skyscraper_anim::elevator_shaft1_player();
	
	//Play Player and Baker Vignette jumping onto the elevator - Baker should end in an idle
	// Playing this early to spawn the elevators. The anim wont' happen until the trigger is tripped.
	maps\nx_skyscraper_anim::elevator_shaftjump();
	
	//Play Player and Baker Vignette climbing off the elevator - Baker should end in an idle

	trigger3 = GetEnt ("player_ready_elevator_climb", "targetname");
	trigger3 SetHintString( &"NX_SKYSCRAPER_HINT_SHAFT_JUMP" );

	// thread maps\nx_skyscraper_anim::elevator_shaftclimb_ally();
	// trigger3 waittill ("trigger");
	// thread maps\nx_skyscraper_anim::elevator_shaftclimb();

	flag_wait  ("shaftclimb_player_done");
	flag_wait ("elevator_b_in_position");
	
	//Play Player and Baker Vignette hooking up	

	display_hint ("NX_SKYSCRAPER_HINT_HOOK_UP");
	thread maps\nx_skyscraper_anim::elevator_shafthookup();

	shaft_freight_hookup();

	// level waittill ("shaft_vignette_done");
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_window" );
	player_restore_abilities();
}

shaft_fall_watcher_1()
{
	// Checks to see if the player is not in the trigger (standing atop the elevator)

	level endon ("floor_reached");
	level waittill ("elevator_out_lift_done");

	while ( flag ("elevator_safe_zone"))
	{
		wait .1;
	}

	wait 0.5;
	SetSlowMotion( 1.0, 0.5, 0.25 );
	SetDvar( "ui_deadquote", &"NX_SKYSCRAPER_FAIL_FALL" );
	missionFailedWrapper();
}

shaft_fall_watcher_2()
{
	// Stop checking once the jump to second elevator vignette plays
	//trigger = GetEnt ("player_ready_elevator_jump_blend", "targetname");
	//trigger endon ("trigger");
	level endon ("freight_elevator_stop");

	// If the player falls into the trigger
	fall_trigger = GetEnt ("shaft_fall", "targetname");
	fall_trigger waittill ("trigger");
	
	// Mission Fail
	SetSlowMotion( 1.0, 0.5, 0.25 );
	SetDvar( "ui_deadquote", &"NX_SKYSCRAPER_FAIL_FALL" );
	missionFailedWrapper();
}
/*
shaft_freight_movement()
{
	trigger = GetEnt ("player_atop_shaft", "targetname");
	trigger waittill ("trigger");
	iprintlnbold ("Go prone to avoid being squashed");
	iprintlnbold ("and wait a few seconds.");

	thread maps\_utility::set_ambient( "amb_skyscraper_elevator_freight_shaft" );

	elevator_vertical_move ( "freight_elevator", 13, 10);
	elevator_horizontal_move ( "freight_elevator", "freight" );
	flag_wait ("hooked_up");
	elevator_vertical_move ( "freight_elevator", 71.5 , 25);
	level notify ("freight_elevator_stop");
	
	level._player SwitchToWeapon ("lancer_silencer_xray");
}
*/
shaft_freight_hookup()
{
	/*
	use_trigger = GetEnt("use_freight_hook_up", "targetname");
	use_trigger trigger_off();

	detect_trigger = GetEnt("elevator_detector", "targetname");

	trigger = GetEnt ("player_atop_shaft", "targetname");
	
	elevator_parts = GetEntArray( "freight_elevator", "script_noteworthy" );
	foreach( part in elevator_parts )
	{

		if ( IsDefined ( part.targetname) && part.targetname == "elevator_bottom")
		{
		
			while ( !part IsTouching ( detect_trigger ))
			{
				wait .1;
			}

			wait 2;

			use_trigger trigger_on();
			use_trigger sethintstring( "[ PRESS (X) TO HOOK UP ]" );

			// Temp hack until I can figure out why the use trigger is not working.
			level notify ("freight_elevator_in_position");
			flag_set ("hooked_up");
			// use_trigger waittill ("trigger");

			wait 1;

			link = spawn ("script_model", level._player.origin );
			link linkto ( part );

			// Temp Baker script
			level._player PlayerLinkToDelta ( link );
			level.baker Linkto ( link );
			level.baker  AllowedStances( "crouch" );
		}
	}
	*/
	elevator_guard = spawn_targetname ("elevator_guard_spawner");
	elevator_guard SetIsVisibleInXray();
	elevator_guard.animname = "elevator_guard";
	elevator_guard thread anim_loop_solo ( elevator_guard, "elevator_guard_sleep", "stop_idle");
	// elevator_guard.health = 1;

	level waittill ("freight_elevator_stop");

	maps\nx_skyscraper_util::player_weapon_init( false );

	// Security cam pip cannot see the guard in his new position, so it's been disabled
	//thread maps\nx_skyscraper_util::pip_setup();
	//cam = GetEnt ("office_hall_camera", "targetname");
	//level._player AlternateSceneCameraLinkTo( cam , "tag_origin", 60  );
	
	thread freight_shaft_kill_timeout( elevator_guard );
	elevator_guard.allowdeath = true;
	elevator_guard waittill ("damage");
	elevator_guard notify ("stop_idle");
	elevator_guard kill();

	// Wait until the guard has finished playing the death animation
	while ( isdefined ( elevator_guard))
	{
		wait .1;
	}
	// then delete his corpses, to be replaced with the vignette corpse
	ClearAllCorpses();

	StopFXOnTag( level._effect[ "flashlight_spotlight" ], level.baker, "tag_flash", true );
	StopFXOnTag( level._effect[ "flashlight" ], level.baker, "tag_flash", true );

	//level notify ("remove_pip");
	level._player unlink();

	level.baker  AllowedStances( "crouch", "stand", "prone" );
	level.baker unlink();

	flag_set ("flag_elevator_red_disembark");
	shaft_open_freight_door();

	// Temporary Teleport
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_window" );
	player_restore_abilities();

	thread maps\_utility::set_ambient( "amb_skyscraper_office_int" );

}

freight_shaft_kill_timeout( elevator_guard )
{
	elevator_guard endon ("death");
	level.baker ForceTeleport ( level.baker.origin, (0,315,0));
	level.baker enable_cqbwalk();
	level.baker cqb_aim( elevator_guard);
	wait 4;
	display_hint_timeout ("NX_SKYSCRAPER_HINT_USE_XRAY", 10);
	wait 3;
	// thread add_dialogue_line( "Baker", "He's right there, on the other side of the door. Look through your scope.", "green", 3 );
	level.baker dialogue_queue( "sky_bak_shaft_lookthroughscope" );
	wait 7;
	// thread add_dialogue_line( "Baker", "Fine, I'll take care of him.", "green", 3 );
	level.baker dialogue_queue( "sky_bak_shaft_illtakecareofhim" );
	// level.baker SetLookAtEntity( elevator_guard );
	level.baker shoot();
	elevator_guard kill();
}

shaft_open_freight_door()
{
	distance = 64;
	normal = (0,0,0);
	elevator_parts = GetEntArray( "freight_elevator_doors", "script_noteworthy" );

	foreach( part in elevator_parts )
	{
		if ( IsDefined ( part.targetname) && part.targetname == "elevator_bottom")
		{
			forward = AnglesToRight( part.angles ); 
			normal = VectorNormalize( forward );
			// iprintln ("normal: " + normal);
			
		}
	}

	foreach( part in elevator_parts )
	{
		if( IsDefined ( part.targetname) && part.targetname == "door_left")
		{
			part MoveTo( part.origin + (distance * normal), 4, .5, .5 );
		}
		if( IsDefined ( part.targetname) && part.targetname == "door_right")
		{
			part MoveTo( part.origin + (distance * normal * -1), 4, .5, .5 );
		}
	}


	wait 4;

}

path_mesh_helper_delete()
{
	// The path mesh helper is a script_brushmodel to build a pathmesh upon. It's deleted so the player can move up through it later
	helper = GetEnt ("path_mesh_helper", "targetname");
	helper Delete();
}

shaft_dialog()
{
	// add_dialogue_line( "Baker", "Watch your step.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_shaft_watchstep" );
	// add_dialogue_line( "Team A", "There's an elevator coming up shaft 3 that will take you to the transfer point.", "purple", 4 );
	radio_dialogue ("sky_teama_shaft_elevatorshaft3");

	flag_wait("shaft_player_past_pole");
	// flag_wait ("ally_elevator_in_position");
	// add_dialogue_line( "Baker", "Roger. Here comes our ride, Spectre.", "green", 3 );
	level.baker dialogue_queue( "sky_bak_shaft_herecomesride" );
	trigger2 = GetEnt ("player_ready_elevator_jump", "targetname");
	trigger2 waittill ("trigger");
 

	// level waittill  ("freight_elevator_in_position");
	wait 5;

	// add_dialogue_line( "Baker", "Get ready to jump again.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_shaft_readytojumpagain" );

	// flag_wait ("hooked_up");
	wait 2;
	// add_dialogue_line( "Team A", "Security elevator is heading your way now.", "purple", 2 );
	radio_dialogue ("sky_teama_shaft_elevatoryourway");

	level waittill ("shaft_vignette_done");

	// add_dialogue_line( "Team A", "This is it, get ready to hook up.", "purple", 2 );
	level.baker dialogue_queue( "sky_bak_shaft_getreadytohookup" );

	flag_wait ("player_used_hook");
	wait 3;
	// add_dialogue_line( "Baker", "Team A, we're in the security shaft, ascending to the lab now.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_shaft_securityshaft" );

	// add_dialogue_line( "Team A", "Copy that. Nice work.", "purple", 2 );
	radio_dialogue ("sky_teama_shaft_nicework");

	level waittill ("freight_elevator_stop");

	// add_dialogue_line( "Team A", "Careful, there's a guard on the other side of the door.", "green", 2 );
	radio_dialogue ("sky_teama_shaft_guarddoor");
	// add_dialogue_line( "Baker", "Roger. Spectre, use your Lancer and take him out.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_shaft_uselancer" );

}

