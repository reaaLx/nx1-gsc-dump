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
//  DRIVE UP                                                        *
//                                                                  *
//*******************************************************************

drive_up_start()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_drive_up" );
	
	thread intro_text();

	// Setup civvies
	// thread civilian_control();
	thread nonmoving_civilians_spawn();
	thread lobby_guards_spawn();
	thread lobby_uav_spawn();
	thread traffic_control();
	thread maps\nx_skyscraper_fx::set_vision_and_fog("exterior_ground_level", 0); // set appropriate vision and fog
	
	// drive_up_sequence();

	// Make elevator transparent at start.
	thread fx_elevator_glass_cycle( 0, 999, "player_elevator" );

	// Hide cloud ring.
	thread fx_hide_cloud_ring();

	thread lobby_elevator_behavior();
}

// Player starts in car, drives up and gets out, car drives away
drive_up_sequence()
{

	enablePlayerWeapons( false );

	// thread maps\nx_skyscraper_util::spawn_business_baker();
	
	MAX_ROTATE_ANG = 80;

	// This delay is here to allow traffic to propogate, adjust as necessary.
	wait 2;
	// level.baker = spawn_targetname ("ally_suit_spawner", true);
	level.taxi = spawn_vehicle_from_targetname_and_drive( "script_vehicle_player" );
	thread drive_up_dialog( level.taxi );	

	// Set up Baker
	level.baker = level.taxi.riders[0];
	level.baker ForceUseWeapon( "lancer_silencer_xray", "primary" );
	level.baker ForceUseWeapon( "lancer", "secondary" );
	level.baker gun_remove();
	level.baker maps\nx_skyscraper_anim::enable_casual_lobby_anims();
	level.baker SetIsVisibleInXray ( true );
	level.baker thread magic_bullet_shield();
	level.baker.animname = "ally_01";

	level.driver = level.taxi.riders[1];

	// Attach player to vehicle
	player_rig = spawn_anim_model( "player_rig" );
	player_rig.angles = level.taxi getTagAngles( "tag_driver" );

	// Offset from passenger seat due to weird player rig location
	player_rig.origin = level.taxi getTagOrigin( "tag_driver" ) - (0,0,90) + vector_multiply( (-1) * AnglesToForward( level.taxi.angles ), 35 );	
	player_rig linkTo( level.taxi, "tag_driver" );
	player_rig hide();
	
	// Orient the player's view to up at the skyscraper
	initial_angles = GetEnt( "origin_player_initial_angles", "targetname" );
	level._player SetPlayerAngles( initial_angles.angles );
	level._player playerLinkToDelta( player_rig, "tag_player", 1.0, MAX_ROTATE_ANG, MAX_ROTATE_ANG, 60, 20 );
	level._player allowCrouch( false );
	
	thread drive_up_vignette_sfx();

	// Other vehicles
	thread drive_up_vtol_spawn();
	thread walk_up_vtol_spawn();
	thread drive_up_departing_taxi( "departing_taxi_2", "departing_taxi_path_start_2", "taxi_passenger_spawner_2" );
	thread drive_up_departing_taxi( "departing_taxi_1", "departing_taxi_path_start_1", "taxi_passenger_spawner_1" );
	thread walk_up_argument();
	// thread slum_dwellers();
	thread drive_up_monorail_motion();

	// Start drive-in vignette
	flag_set ("flag_intro_ride");

	thread player_elevator_setup();
	thread maps\nx_skyscraper_elevator::elevator_vertical_teleport( "player_elevator", 15 );

	// Once car has stopped, have player get out
	thread drive_up_player_taxi_behavior();	
}

drive_up_vignette_sfx()
{
	wait 0.1;
	level._player playsound("scn_skyscraper_drive_up");
}

drive_up_player_taxi_behavior()
{
	nearing_building = getVehicleNode("nearing_building", "script_noteworthy");
	nearing_building waittill ( "trigger" );

	thread traffic_short_loop();

	level.taxi waittill( "reached_end_node" );
	level notify ("taxi_parked");

	wait 1.2;
	level.taxi thread play_sound_on_entity( "scn_favela_npc_door_open" );
	thread maps\_utility::set_ambient( "amb_skyscraper_city_ext" );

	level notify( "exiting_vehicle" );
	
	level.taxi notify( "door_open" );

	// Fudge the player out of the cab until we get a proper exit animation 
	exit_point = getent( "player_vehicle_exit_point", "targetname" );
	
	dummy = spawn( "script_model", level._player.origin );
	dummy.angles = level._player.angles;
	dummy setmodel( "tag_origin" );
	level._player playerLinkTo( dummy, "tag_player", 1.0, 45, 45, 45, 20 );
	
	MOVETIME = 1.5;
	ACCEL = 0.3;
	DECEL = 0.3;
	dummy moveTo( exit_point.origin, MOVETIME, ACCEL, DECEL );
	dummy rotateTo( exit_point.angles, MOVETIME, ACCEL, DECEL );
	
	wait MOVETIME;

	level._player unlink();

	// Set up player for walking section
	enablePlayerWeapons( true );
	
	level._player allowCrouch( true );
	level._player allowStand( true );
	level._player setStance( "stand" );	

	// level._player TakeAllWeapons();

	maps\nx_skyscraper_util::player_remove_abilities();

	// Ally gets out of car
	level.taxi thread play_sound_on_entity( "scn_favela_npc_door_open" );
	level.taxi vehicle_unload();
	wait 6.0;

	// lobby_enter_sequence();

	// Car drives away

	exit_node = GetVehicleNode( "departing_taxi_path_start_player", "targetname" );
	level.taxi StartPath( exit_node );	
	level.taxi waittill ("reached_end_node");
	level.taxi delete();
	level.driver delete();
}

drive_up_monorail_motion()
{
	distance = 10000;
	reference = GetEnt ("monorail_direction", "targetname");
	direction = AnglesToForward ( reference.angles );
	normalized_direction = VectorNormalize ( direction );
	monorail = GetEntArray ("monorail", "targetname");
	foreach ( car in monorail)
	{
		car MoveTo ( car.origin + (normalized_direction * distance), 20 );
	}
	monorail [ 0 ] waittill ("movedone");
	foreach ( car in monorail )
	{
		car delete();
	}
}

drive_up_dialog( vehicle )
{
	
	wait 8;
	//add_dialogue_line( "Lam", "This the place. Hard to miss it.", "green", 2 );
	level.driver dialogue_queue( "sky_lam_driveup_thistheplace" );
	//thread add_dialogue_line( "Baker", "These retinal masks had better work the first time.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_driveup_retinalmasks" );

	nearing_building = getVehicleNode("nearing_building", "script_noteworthy");
	nearing_building waittill ( "trigger" );

	flag_set ("spawn_taxi_passengers");

	//add_dialogue_line( "Baker", "Alright. It's go time.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_driveup_gotime" );

	//add_dialogue_line( "Lam", "Team B should be in position shortly. Wait on their mark before going through security.", "green", 4 );
	level.driver dialogue_queue( "sky_lam_driveup_teambinposition" );

	vehicle waittill ("reached_end_node");

	//add_dialogue_line( "Lam", "Okay, guys. Signal when you need an exfil. I'll stay within range.", "green", 3 );
	level.driver dialogue_queue( "sky_lam_driveup_signalforexfil" );
	//add_dialogue_line( "Lam", "Good luck.", "green", 2 );
	level.driver dialogue_queue( "sky_lam_driveup_goodluck" );
	//add_dialogue_line( "Baker", "Thanks, Lam. See you on the other side.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_driveup_thanksotherside" );

	// spawn the baker nag function
	thread drive_up_baker_nag();
}

intro_text()
{
	wait 3;

	lines = [];
	// "Mission"
	lines[ lines.size ] = &"NX_SKYSCRAPER_INTROSCREEN_LINE1";
	// Time
	lines[ "date" ]     = &"NX_SKYSCRAPER_INTROSCREEN_LINE2";
	// Character
	lines[ lines.size ] = &"NX_SKYSCRAPER_INTROSCREEN_LINE3";
	// Faction
	lines[ lines.size ] = &"NX_SKYSCRAPER_INTROSCREEN_LINE4";
	// Location
	lines[ lines.size ] = &"NX_SKYSCRAPER_INTROSCREEN_LINE5";

	maps\_introscreen::introscreen_feed_lines( lines );
}

civilian_control()
{

	array_thread( GetEntArray( "civilian_spawner", "script_noteworthy" ), ::spawn_ai );
	kill_volume = GetEnt("civilian_kill_volume", "targetname");
	kill_volume2 = GetEnt("civilian_kill_volume2", "targetname");
	spawner1_toggle = 1;
	spawner2_toggle = 1;
	while(1)
	{
		ai = GetAIArray();
		foreach( guy in ai )
		{
			if(guy IsTouching(kill_volume) && !guy is_hero() )
			{
				//kill the dude and then spawn his replacement
				guy Delete();
				if (spawner1_toggle ==1)
				{
					replacement = spawn_targetname("replacement_spawner_coffee", true);
					spawner1_toggle = 0;
				}
				else
				{
					replacement = spawn_targetname("replacement_spawner_pda", true);
					spawner1_toggle = 1;
				}
			}
			else if(guy IsTouching(kill_volume2) && !guy is_hero() )
			{
				//kill the dude and then spawn his replacement
				guy Delete();
				if (spawner2_toggle ==1)
				{
					replacement = spawn_targetname("replacement_spawner2_coffee", true);
					spawner2_toggle = 0;
				}
				else
				{
					replacement = spawn_targetname("replacement_spawner2_pda", true);
					spawner2_toggle = 1;
				}
			}
		}
		wait 1.0;
	}


}

drive_up_vtol_spawn()
{
	drive_up_vtol = spawn_vehicle_from_targetname_and_drive ("drive_up_vtol_spawner");
	end = Getstruct ("drive_up_vtol_end", "targetname");
	end waittill ("trigger");
	drive_up_vtol delete();
}

walk_up_vtol_spawn()
{
	walk_up_vtol = spawn_vehicle_from_targetname_and_drive ("walk_up_vtol_spawner");
	end = Getstruct ("walk_up_vtol_end", "targetname");
	end waittill ("trigger");
	walk_up_vtol delete();
}

drive_up_baker_nag()
{
	wait 10.0;
	nag_volume = GetEnt( "volume_baker_nag1", "targetname" );
	nag_number = 0;
	while(1)
	{
	if( level._player IsTouching(nag_volume))
		wait 1.0;
	else
		{	
			nag_number++;
			if( nag_number > 4 )
				break;
			dialogue_index = randomintrange( 0, 2 );
			switch( dialogue_index )
			{
				case 0:
					//add_dialogue_line( "Baker", "Spectre!  Stop sightseeing.  We've got a mission to do.", "green", 2 );
					level.baker dialogue_queue( "sky_bak_lobby_stopsightseeing" );
					break;
				case 1:
					//add_dialogue_line( "Baker", "Spectre!  Get back over here!", "green", 2 );
					level.baker dialogue_queue( "sky_bak_lobby_getbackhere" );
					break;
				case 2:
					//add_dialogue_line( "Baker", "Spectre!  Where the hell are you going!", "green", 2 );
					level.baker dialogue_queue( "sky_bak_lobby_whereyougoing" );
					break;
			}
		wait 3.0; 
		}
	if( flag( "flag_baker_nag1" ))
		break;
	}
	if( nag_number > 4 )
		{
		//add_dialogue_line( "Baker", "Team A has been compromised! Mission failure!", "green", 2 );
		level.baker dialogue_queue( "sky_bak_lobby_compromised" );
		// maps\_utility::missionFailedWrapper();
		}
// set up second nag box inside the lobby
	nag_volume = GetEnt( "volume_baker_nag2", "targetname" );
	nag_number = 0;
	while(1)
	{
	if( level._player IsTouching(nag_volume))
		wait 1.0;
	else
		{	
			nag_number++;
			if( nag_number > 4 )
				break;
			dialogue_index = randomintrange( 0, 2 );
			switch( dialogue_index )
			{
				case 0:
					//add_dialogue_line( "Baker", "Spectre!  Stop sightseeing.  We've got a mission to do.", "green", 2 );
					level.baker dialogue_queue( "sky_bak_lobby_stopsightseeing" );
					break;
				case 1:
					//add_dialogue_line( "Baker", "Spectre!  Get back over here!", "green", 2 );
					level.baker dialogue_queue( "sky_bak_lobby_getbackhere" );
					break;
				case 2:
					//add_dialogue_line( "Baker", "Spectre!  Where the hell are you going!", "green", 2 );
					level.baker dialogue_queue( "sky_bak_lobby_whereyougoing" );
					break;
			}
		wait 3.0;
		}
	if( flag( "flag_baker_nag2" ))
		break;
	}
	if( nag_number > 4 )
		{
		//add_dialogue_line( "Baker", "Team A has been compromised! Mission failure!", "green", 2 );
		level.baker dialogue_queue( "sky_bak_lobby_compromised" );
		// maps\_utility::missionFailedWrapper();
		}
// set up third nag box leading to the elevator
	nag_volume = GetEnt( "volume_baker_nag3", "targetname" );
	nag_number = 0;
	while(1)
	{
	if( level._player IsTouching(nag_volume))
		wait 1.0;
	else
		{	
			nag_number++;
			if( nag_number > 4 )
				break;
			dialogue_index = randomintrange( 0, 2 );
			switch( dialogue_index )
			{
				case 0:
					//add_dialogue_line( "Baker", "Spectre!  Stop sightseeing.  We've got a mission to do.", "green", 2 );
					level.baker dialogue_queue( "sky_bak_lobby_stopsightseeing" );
					break;
				case 1:
					//add_dialogue_line( "Baker", "Spectre!  Get back over here!", "green", 2 );
					level.baker dialogue_queue( "sky_bak_lobby_getbackhere" );
					break;
				case 2:
					//add_dialogue_line( "Baker", "Spectre!  Where the hell are you going!", "green", 2 );
					level.baker dialogue_queue( "sky_bak_lobby_whereyougoing" );
					break;
			}
		wait 3.0;
		}
	if( flag( "flag_baker_nag3" ))
		break;
	}
	if( nag_number > 4 )
		{
		//add_dialogue_line( "Baker", "Team A has been compromised! Mission failure!", "green", 2 );
		level.baker dialogue_queue( "sky_bak_lobby_compromised" );
		// maps\_utility::missionFailedWrapper();
		}
}

walk_up_argument()
{
	civilian_argue = spawn_targetname( "civilian_argue", true );
	//civilian_argue = GetEnt( "civilian_argue_model", "targetname" );
	civilian_argue.animname = "civilian_argue";
	security_guard_argue = spawn_targetname( "security_guard_argue", true );
	security_guard_argue.animname = "security_guard_argue";
	security_guard_argue gun_remove();
	civilian_node = GetEnt( "node_anim_argument1", "script_noteworthy" );
	guard_node = GetEnt( "node_anim_argument2", "script_noteworthy" );
	civilian_node thread anim_loop_solo(civilian_argue, "civilian_directions_1_A", "stop_idle");
	guard_node thread anim_loop_solo(security_guard_argue, "civilian_directions_1_B", "stop_idle");
	level waittill ("clean_up_lobby");
	civilian_argue delete();
	security_guard_argue delete();

}
/*
slum_dwellers()
{
	slum_dweller = spawn_targetname( "slum_dweller", true );
	slum_dweller.animname = "slum_dweller";
	slum_node = GetEnt( "node_slum_wave", "script_noteworthy" );
	slum_dweller thread anim_loop_solo( slum_dweller, "unarmed_shout_window" );
}
*/
nonmoving_civilians_spawn()
{
	level.lobby_civilians = [];
	civilian_nodes = getnodearray( "civilian_animation", "targetname" );
	civilian_nodes = array_combine( civilian_nodes, getentarray( "civilian_animation", "targetname" ) );
	foreach( node in civilian_nodes )
	{
		assert( isdefined( node.script_noteworthy ) );
		civilian = spawn_anim_model( "civilian" );
		level.lobby_civilians [level.lobby_civilians.size] = civilian;

		assert( isdefined( level._scr_anim[ civilian.animname ] ) );
		assert( isdefined( level._scr_anim[ civilian.animname ][ node.script_noteworthy ] ) );
		node thread anim_loop_solo( civilian, node.script_noteworthy );
		//civilian animscripts\civilian\civilian_init_common::attachProps( node.script_noteworthy );

		
	}

	// clean up civs once player is in elevator.
	level waittill ("clean_up_lobby");
	foreach (civilian in level.lobby_civilians)
	{
		civilian delete();
	}
}

drive_up_departing_taxi( taxi, node, passenger )
{
	wait 1;
	departing_taxi = spawn_vehicle_from_targetname ( taxi);
	node = GetVehicleNode ( node , "targetname");
	departing_taxi AttachPath ( node );
	flag_wait ("spawn_taxi_passengers");
	passenger_1 = spawn_targetname ( passenger );
	passenger_1.disablearrivals = true;
	guy_runtovehicle_load( passenger_1, departing_taxi );
	// departing_taxi waittill ("vehicle_mount");
	departing_taxi StartPath();
	departing_taxi waittill ("reached_end_node");
	departing_taxi delete();
}

//*******************************************************************
// LOBBY ENTER                                                      *
//                                                                  *
//*******************************************************************

lobby_enter_start()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_lobby_enter" );

	thread maps\nx_skyscraper_fx::set_vision_and_fog("interior", 0); // set appropriate vision and fog

	maps\nx_skyscraper_util::player_remove_abilities();

	maps\nx_skyscraper_util::spawn_business_baker();

	issue_color_orders( "r0", "allies" );
	level.baker gun_remove();

	level.baker maps\nx_skyscraper_anim::enable_casual_lobby_anims();

	thread player_elevator_setup();
	thread maps\nx_skyscraper_elevator::elevator_vertical_teleport( "player_elevator", 15 );

	baker_teleport = GetEnt ("baker_lobby_teleport", "targetname");
	level.baker ForceTeleport( baker_teleport.origin, baker_teleport.angles);

	// thread civilian_control();
	thread nonmoving_civilians_spawn();
	thread lobby_guards_spawn();
	//lobby_enter_sequence();

	// Make elevator transparent at start.
	thread fx_elevator_glass_cycle( 0, 999, "player_elevator" );
	
	// Hide cloud ring.
	thread fx_hide_cloud_ring();

	thread lobby_elevator_behavior();
	thread lobby_uav_spawn();
}

lobby_enter_sequence()
{
	thread autosave_now();
	
	// thread lobby_baker_vignettes();
	thread maps\nx_skyscraper_util::play_pip_bink( "skyscraper_elevator_pip", undefined, "play_elevator_pip" );

	thread lobby_dialog();

	lobby_vision_transition();

	thread lobby_security_scan_baker();
	lobby_security_scan_player();
}

player_elevator_setup()
{
	// Link use trigger to elevator
	use_trigger = GetEnt ("player_ready_for_elevator_lift", "targetname");
	link = GetEnt ("player_elevator_anim_node", "targetname");
	use_trigger EnableLinkTo();
	use_trigger LinkTo ( link );

}
/*
lobby_baker_vignettes()
{
	flag_wait ("flag_lobby_airlock");
	maps\nx_skyscraper_anim::lobby_airlock_spawn();
	flag_wait ("flag_lobby_walk");
	maps\nx_skyscraper_anim::lobby_walk_spawn();
	flag_wait ("flag_security_baker");
	maps\nx_skyscraper_anim::security_baker_spawn();
}
*/
lobby_vision_transition()
{
	trigger = GetEnt ("entering_lobby", "targetname");
	trigger waittill ("trigger");
	thread maps\nx_skyscraper_fx::set_vision_and_fog("interior", 2); // set appropriate vision and fog
}

lobby_security_scan_baker()
{
	trigger = GetEnt ("in_security_scan", "targetname");
	while ( !level.baker isTouching ( trigger ))
	{
		wait .5;
	}

	// iprintln ("baker passing through security");
}

lobby_security_scan_player()
{

	level notify ("player_scanner_ready");

	trigger = GetEnt ("in_security_scan", "targetname" );
	while ( !level._player isTouching ( trigger ))
	{
		wait .5;
	}	
	scanners = GetEntArray ("retinal_scanner", "targetname");
	array_thread ( scanners, ::lobby_retinal_scanner ); 

}

lobby_retinal_scanner( )
{
	level endon ("player_through_security");
	while (1)
	{
		dist = Distance ((level._player.origin + (0,0,32)), self.origin);
		if ( player_looking_at( self.origin ) && (dist < 32) )
			break;
		wait .1;
	}
	thread maps\_introscreen::introscreen_generic_white_fade_in( .25, .25 );
	level._player playsound("skyscraper_security_scanner");

	blocker = GetEnt ("security_player_blocker", "targetname");
	blocker delete();

	level notify ("player_through_security");	
}

lobby_dialog()
{
	// trigger = GetEnt ("entering_lobby", "targetname");
	// trigger waittill ("trigger");
	// set the flag to stop the first nagging trigger
	flag_wait ("flag_lobby_airlock");

	// add_dialogue_line( "Baker", "Just stay cool. Remember, we're here on business.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_lobby_staycool" );
	// add_dialogue_line( "Team A", "Team B, we're in position. You are clear to proceed.", "purple", 2 );
	radio_dialogue ( "sky_teama_lobby_inposition" );
	// add_dialogue_line( "Baker", "Copy. We're going through security now.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_lobby_security" );
	flag_set( "flag_baker_nag1" );

	//flag_set( "flag_baker_nag2" );
	/*
	trigger = GetEnt ("baker_approaches_security", "targetname");
	trigger waittill ("trigger");

	level.lobby_guard_2 SetLookAtEntity ( level.baker);

	issue_color_orders( "r2", "allies" );
	*/
	flag_wait ("flag_security_baker");
	// add_dialogue_line( "Guard", "Sir, you must look into the screen before entering.", "red", 2 );
	level.lobby_guard_1 dialogue_queue( "sky_grd_lobby_lookintoscreen" );
	// add_dialogue_line( "Baker (To Guard)", "I just look in here?", "green", 2 );
	level.baker dialogue_queue( "sky_bak_lobby_lookinhere" );

	// issue_color_orders( "r3", "allies" );

	// add_dialogue_line( "Guard", "Thank you, sir. Please step through.", "red", 2 );
	level.lobby_guard_1 dialogue_queue( "sky_grd_lobby_thankyou" );
	// add_dialogue_line( "Baker (To Guard)", "Heck, that was nothing compared the airport. You guys really run a tight ship.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_lobby_airport" );

	issue_color_orders( "r4", "allies" );

	level.lobby_guard_2 StopLookAt( 1 );

	//level waittill ("player_through_security");

	// add_dialogue_line( "Baker", "Okay, that was the easy part.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_lobby_easypart" );
	
	flag_set ("play_elevator_pip");
	flag_wait ("player_elevator_ready");
	issue_color_orders( "r6", "allies" );

	// add_dialogue_line( "Baker", "Team A, we're entering elevator number 5.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_lobby_enteringelevator" );
	// add_dialogue_line( "Team A", "Copy. We'll meet you above.", "purple", 2 );
	// radio_dialogue( "sky_teama_lobby_meetyouabove" );
	// No they won't.
}

lobby_player_nag()
{
	
}

lobby_guards_spawn()
{
	thread lobby_airlock_guard();
	level.lobby_guard_1 = spawn_targetname ("security_checkpoint_guard_spawner_3");
	level.lobby_guard_1.animname = "guard";
	level.lobby_guard_2 = spawn_targetname ("security_checkpoint_guard_spawner_4");
	level.lobby_guard_2.animname = "guard";
	
	wait 1;
	
	node_1 = GetEnt ("checkpoint_guard_node_3", "script_noteworthy");
	node_2 = GetEnt ("checkpoint_guard_node_4", "script_noteworthy");

	node_1 thread anim_loop_solo ( level.lobby_guard_1, "platform_idle_loop", "stop_idle");
	node_2 thread anim_loop_solo ( level.lobby_guard_2, "platform_idle_loop", "stop_idle");
	
	level waittill ("clean_up_lobby");

	level.lobby_guard_1 delete();
	level.lobby_guard_2 delete();
	
}

lobby_airlock_guard()
{
	guard = spawn_targetname ("airlock_guard_spawner");
	guard SetLookAtEntity ( level._player );
	level waittill ("clean_up_lobby");
	guard delete();
}

lobby_uav_spawn()
{
	lobby_uav_spawner = GetEnt("lobby_uav1", "targetname"); 
	lobby_uav1 = lobby_uav_spawner maps\_attack_heli::SAV_setup( "pathing" );
	lobby_uav1.ignoreme = true;
	lobby_uav1.ignoreall = true;
	lobby_uav1 Vehicle_SetSpeed( 8 );

	lobby_uav_spawner2 = GetEnt("lobby_uav2", "targetname"); 
	lobby_uav2 = lobby_uav_spawner2 maps\_attack_heli::SAV_setup( "pathing" );
	lobby_uav2.ignoreme = true;
	lobby_uav2.ignoreall = true;
	lobby_uav2 Vehicle_SetSpeed( 8 );

	spawners = GetEntArray( "driveup_uav", "script_noteworthy" );
	foreach( spawner in spawners )
	{
		driveup_uav = spawner maps\_attack_heli::SAV_setup( "pathing" );
		driveup_uav.ignoreme = true;
		driveup_uav.ignoreall = true;
		driveup_uav Vehicle_SetSpeed( 8 );
	}

	// UAV carrying sign


	driveup_uav_spawner = GetEnt("uav_with_ad", "targetname"); 
	driveup_uav = driveup_uav_spawner maps\_attack_heli::SAV_setup( "pathing" );
	driveup_uav.ignoreme = true;
	driveup_uav.ignoreall = true;
	driveup_uav Vehicle_SetSpeed( 8 );

	driveup_uav2_spawner = GetEnt("uav_with_ad2", "targetname"); 
	driveup_uav2 = driveup_uav2_spawner maps\_attack_heli::SAV_setup( "pathing" );
	driveup_uav2.ignoreme = true;
	driveup_uav2.ignoreall = true;
	driveup_uav2 Vehicle_SetSpeed( 8 );

	ad_on_uav = GetEnt( "ad_on_uav", "targetname" );
	//ad_on_uav linkto( driveup_uav, "tag_flash" );
	ad_on_uav hide();

	ad_on_uav2 = GetEnt( "ad_on_uav2", "targetname" );
	//ad_on_uav2 linkto( driveup_uav2, "tag_flash" );
	ad_on_uav2 hide();

	//ad_on_uav advert_flicker();
	//ad_on_uav2 advert_flicker(); 

	level waittill ("clean_up_lobby");
	lobby_uav1 delete();
	lobby_uav2 delete();
	driveup_uav delete();
	driveup_uav2 delete();

}
/*
advert_flicker()
{
	while(1)
	{
		wait 2.5;
		self hide();
		wait 0.1;
		self show();
		wait 0.1;
		self hide();
		wait 0.05;
		self show();
	}
}
*/
traffic_control()
{
	// Throw in a pattern of traffic here. Currently uses a for loop for easy scaling.
	for ( i = 0; i < 1; i++)
	{
		thread traffic_car_one_way( "traffic_car_1", "traffic_start_1" );
		wait .2;
		thread traffic_moto_one_way( "traffic_moto_1", "traffic_start_2" );
		thread traffic_car_one_way( "traffic_car_2", "player_taxi_path_other" );
		wait .2;
		thread traffic_moto_one_way( "traffic_moto_2",  "traffic_start_1" );
		wait .3;
		thread traffic_moto_one_way( "traffic_car_3", "traffic_start_2" );
		thread traffic_car_one_way( "traffic_moto_1", "player_taxi_path_other" );
		wait .1;
		thread traffic_car_one_way( "traffic_car_4", "traffic_start_1" );
		wait .3;
		thread traffic_moto_one_way( "traffic_moto_2",  "traffic_start_2" );
		wait .1;
		thread traffic_car_one_way( "traffic_car_1", "player_taxi_path_other" );
		wait .2;
		thread traffic_moto_one_way( "traffic_moto_1", "traffic_short_loop_start_1" );
		thread traffic_car_one_way( "traffic_car_2", "traffic_short_loop_start_2" );
		wait .2;
		thread traffic_moto_one_way( "traffic_moto_2",  "player_taxi_short_loop_start" );
		wait .3;
		thread traffic_moto_one_way( "traffic_car_3", "traffic_start_1" );
		thread traffic_car_one_way( "traffic_car_4", "traffic_start_2" );
		wait .1;
		thread traffic_car_one_way( "traffic_car_1", "player_taxi_short_loop_start" );
		wait .2;
		thread traffic_moto_one_way( "traffic_moto_1", "traffic_short_loop_start_1" );
		wait .3;
		thread traffic_car_one_way( "traffic_car_2", "traffic_short_loop_start_2" );
		wait .2;
		thread traffic_moto_one_way( "traffic_moto_2",  "player_taxi_short_loop_start" );
		wait .3;
		thread traffic_moto_one_way( "traffic_moto_1", "traffic_start_1" );
		thread traffic_car_one_way( "traffic_car_3", "traffic_start_2" );
		wait .1;
	}
}

traffic_short_loop()
{
	thread traffic_control_upper();

	// Does a shorter loop which encompasses the area visible from the front fo the building, to give the impression of higher traffic density
	 for ( i = 0; i < 3; i++)
	 {
		thread traffic_car_loop( "traffic_car_1", "traffic_short_loop_start_1" );
		wait 1.2;
		thread traffic_moto_loop( "traffic_moto_1", "traffic_short_loop_start_2" );
		wait .3;
		thread traffic_car_loop( "traffic_car_2", "player_taxi_short_loop_start" );
		wait 1.2;
		thread traffic_moto_loop( "traffic_moto_2",  "traffic_short_loop_start_1" );
		wait 1.3;
		thread traffic_moto_loop( "traffic_moto_1", "traffic_short_loop_start_2" );
		wait .4;
		thread traffic_car_loop( "traffic_car_3", "player_taxi_short_loop_start" );
		wait 1.1;
		thread traffic_car_loop( "traffic_car_4", "traffic_short_loop_start_1" );
		wait .3;
		thread traffic_moto_loop( "traffic_moto_2",  "traffic_short_loop_start_2" );
		wait 1.1;

	 }
}

traffic_control_upper()
{
	for ( i = 0; i < 3; i++)
	{
		thread traffic_car_loop( "traffic_car_5", "traffic_start_upper_1" );
		wait .5;
		thread traffic_car_loop( "traffic_car_6", "traffic_start_upper_2" );
		wait .4;
		thread traffic_car_loop( "traffic_car_7", "traffic_start_upper_2" );
		wait .6;
		thread traffic_car_loop( "traffic_car_8", "traffic_start_upper_1" );
		wait .4;
	}
}

traffic_car_one_way( car_spawner, path_start_targetname )
{
	// Spawn a car and set it on a path.
	path_start = GetVehicleNode ( path_start_targetname, "targetname");
	car = spawn_vehicle_from_targetname( car_spawner );
	car AttachPath ( path_start);
	car StartPath();

	// When the car reaches the end point
	car waittill ("reached_end_node");

	car delete();

}

traffic_moto_one_way( moto_spawner, path_start_targetname )
{
	// Spawn a motorcycle and set it on a path.
	path_start = GetVehicleNode ( path_start_targetname, "targetname");
	moto = spawn_vehicle_from_targetname( moto_spawner );
	moto AttachPath ( path_start);
	moto StartPath();

	// Create a rider, link him to the motorcycle, and put him in a "riding" position
	rider = spawn_anim_model ( "rider", ( moto.origin ));
	rider_node = spawn ("script_origin", moto.origin);
	rider_node linkto (moto, "tag_origin", ( 0, 0, 20), (0, 0, 0) );
	rider linkto (rider_node );
	rider_node thread anim_loop_solo(rider, "forward" );

	// When the car reaches the end point
	moto waittill ("reached_end_node");

	//... delete everything.
	moto delete();
	rider delete();
	rider_node delete();
	
}

traffic_car_loop( car_spawner, path_start_targetname )
{
	// Spawn a car and set it on a path.
	path_start = GetVehicleNode ( path_start_targetname, "targetname");
	car = spawn_vehicle_from_targetname( car_spawner );
	car AttachPath ( path_start);
	car StartPath();

	// While the player has not yet entered the elevator...
	while ( !flag ("elevator_in_motion") )
	{
		// When the car reaches the end point
		car waittill ("reached_end_node");
		// start it back at the beginning.
		car AttachPath ( path_start);
		car StartPath();
	}
	car delete();

}

traffic_moto_loop( moto_spawner, path_start_targetname )
{
	// Spawn a motorcycle and set it on a path.
	path_start = GetVehicleNode ( path_start_targetname, "targetname");
	moto = spawn_vehicle_from_targetname( moto_spawner );
	moto AttachPath ( path_start);
	moto StartPath();

	// Create a rider, link him to the motorcycle, and put him in a "riding" position
	rider = spawn_anim_model ( "rider", ( moto.origin ));
	rider_node = spawn ("script_origin", moto.origin);
	rider_node linkto (moto, "tag_origin", ( 0, 0, 20), (0, 0, 0) );
	rider linkto (rider_node );
	rider_node thread anim_loop_solo(rider, "forward" );

	// While the player has not yet entered the elevator...
	while ( !flag ("elevator_in_motion") )
	{
		// When the car reaches the end point
		moto waittill ("reached_end_node");
		// start it back at the beginning.
		moto AttachPath ( path_start);
		moto StartPath();
	}

	//... delete everything.
	moto delete();
	rider delete();
	rider_node delete();
	
}

lobby_elevator_behavior()
{

	thread fx_elevator_glass_cycle( 0, 999, "elevator_1" );
	thread fx_elevator_glass_cycle( 0, 999, "elevator_2" );
	thread fx_elevator_glass_cycle( 0, 999, "elevator_3" );
	thread fx_elevator_glass_cycle( 0, 999, "elevator_5" );

	level.passengers = [];

	lobby_elevator_passenger_spawn( "elevator_1" );
	lobby_elevator_passenger_spawn( "elevator_2" );
	lobby_elevator_passenger_spawn( "elevator_3" );
	lobby_elevator_passenger_spawn( "player_elevator" );
	lobby_elevator_passenger_spawn( "elevator_5" );

	trigger = GetEnt ("entering_lobby", "targetname");
	trigger waittill ("trigger");

	thread lobby_player_elevator_descent(  );

	thread maps\nx_skyscraper_elevator::elevator_pattern_1 ("elevator_5", 8, 9, "elevator_5_passenger_path_start");
	wait 2.6;
	thread maps\nx_skyscraper_elevator::elevator_pattern_1 ("elevator_2", 2, 3, "elevator_2_passenger_path_start");
	wait 3.4;
	thread maps\nx_skyscraper_elevator::elevator_pattern_1 ("elevator_3", 4, 5, "elevator_3_passenger_path_start");
	wait 4.7;
	thread maps\nx_skyscraper_elevator::elevator_pattern_1 ("elevator_1", 0, 1, "elevator_1_passenger_path_start");


}

lobby_elevator_passenger_spawn( elevator )
{
	node_1 = undefined;
	node_2 = undefined;
	// Get all the entities in the elevator
	elevator_parts = GetEntArray( elevator , "script_noteworthy" );

	// Find the spawners, spawn the passengers, and link them to their nodes
	foreach( part in elevator_parts )
	{
		if( isdefined (part.targetname) && part.targetname == "elevator_anim_node_1" )
		{
			node_1 = part;
		}				
		if( isdefined (part.targetname) && part.targetname == "elevator_anim_node_2" )
		{
			node_2 = part;
		}
	}

	// Wait until the nodes are defined before continuing.
	waittillframeend;

	foreach( part in elevator_parts )
	{
		if( isdefined (part.targetname) && part.targetname == "elevator_passenger_spawner_1" )
		{
			passenger_1 = part spawn_ai ();
			passenger_1 linkto ( node_1 );
			passenger_1.goalradius = 32;
			level.passengers [level.passengers.size] = passenger_1;
		}

		if( isdefined (part.targetname) && part.targetname == "elevator_passenger_spawner_2" )
		{
			passenger_2 = part spawn_ai ();
			passenger_2 linkto ( node_2 );
			passenger_2.goalradius = 32;
			level.passengers [level.passengers.size] = passenger_2;
		}
	}
}

lobby_player_elevator_descent(  )
{

	trigger = GetEnt ("obj_enter_elevator", "targetname");
	trigger waittill ( "trigger" );

	thread maps\nx_skyscraper_elevator::elevator_vertical_move( "player_elevator", -15, 8 );
	wait 6;
	thread fx_elevator_glass_cycle( 0, 1, "player_elevator" );
	wait 3;
	// elevator notify ("at_ground_floor");
	thread maps\nx_skyscraper_elevator::elevator_door_move ( "player_elevator", "open");
	maps\nx_skyscraper_elevator::elevator_door_move ( "player_elevator_facade", "open");
	level.passengers[6] thread goal_node_target_pathing( "elevator_4_passenger_path_start" );
	wait .5;
	level.passengers[7] thread goal_node_target_pathing( "elevator_4_passenger_path_start" );
	flag_set ("player_elevator_ready");
}

goal_node_target_pathing( node_targetname )
{
	level endon ("elevator_out_lift_done");
	self unlink();

	node = GetNode ( node_targetname, "targetname");

	self SetGoalNode ( node );

	while ( 1 )
	{
		self waittill ("goal");
		if ( !isdefined ( node.target))
			break;
		new_node = GetNode (node.target, "targetname");
		self SetGoalNode (new_node);
		node = new_node;
	}
	self delete();
}