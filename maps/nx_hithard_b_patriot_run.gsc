
//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  nx_hithard_charge.gsc					   					**
//				NOTE: called from nx_hithard.gsc							**
//                                                                          **
//    Created: 1/13/2011 - Brian Marvin										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\nx_hithard_b_util;
//#include maps\_nx_objective_util;


//***********************************************************************
//																		*
//		INITIALIZATION: The following are called from nx_hithard.gsc	*
//                                                                  	*
//***********************************************************************

// Objective specific flag_init() calls
flag_inits()
{
		flag_init( "ch_events_start" );
		flag_init( "intro_sequence_complete" );
		flag_init( "intro_street_complete" );
		flag_init( "uav_reveal" );
		flag_init( "city_hall_briefing_end" );
		flag_init( "city_hall_cleanup" );
		flag_init( "skybridge_seen" );
		flag_init( "stairway_dialogue" );
		flag_init( "stairway_shake" );
		flag_init( "hallway_shake" );
		flag_init( "close_ch_east" );
		flag_init( "obj_east_done" );
		flag_init( "fx_intro_door_opening" );
		flag_init( "magicgrenade_teargas_hall_exit" );
		flag_init( "magicgrenade_monorail_start" );
		flag_init( "left_path_begin" );
		flag_init( "left_path_complete" );
		flag_init( "left_path_cleanup" );
		flag_init( "right_path_commit" );
		flag_init( "boundary_breach" );
		flag_init( "uav_scene_end" );
		flag_init( "vp_protect_moment" );
		flag_init( "jungle_enc_moveup_mid" );
		flag_init( "last_stand_setup" );
		flag_init( "jungle_plaza_enc_complete" );
		flag_init( "tunnel_door_setup" );
		flag_init( "exit_plaza" );
		flag_init( "plaza_dialogue_complete" );
		flag_init( "player_interruption" );
		flag_init( "slowmotion_done" );
		flag_init( "entered_store" );
		flag_init( "civ_moment_in_position" );
		flag_init( "civ_moment_dialogue_complete" );
		flag_init( "civ_moment_interrogation_dialogue_complete" );
		flag_init( "civilian_enc_start" );
		flag_init( "tunnel_enc_complete" );
		flag_init( "flag_mall_door_open" );
		flag_init( "civilian_escape" );
		flag_init( "gypsy_lockdown_ramp" );
		flag_init( "plaza_enc_complete" );
		flag_init( "monorail_station_start" );
		flag_init( "monorail_dialogue_start" );
		flag_init( "monorail_station_enc_complete" );
		flag_init( "last_airdrop" );

		// VP movement
		flag_init( "vp_move_3" );
		flag_init( "vp_move_31" );
		flag_init( "vp_move_32" );
		flag_init( "vp_move_33" );
		flag_init( "vp_move_34" );
		flag_init( "vp_move_7" );
		flag_init( "vp_move_110" ); // PLAZA 2 ENCOUNTER
		flag_init( "vp_move_115" ); // PLAZA 2 ENCOUNTER
		flag_init( "vp_move_116" ); // PLAZA 2 ENCOUNTER
		flag_init( "vp_move_120" ); // PLAZA 2 ENCOUNTER
}

// Objective specific add_hint_string() calls
hint_string_inits()
{	
	//add_hint_string( "hint_parachute_smoke", &"NX_HITHARD_PARACHUTE_HINT_SMOKE", ::hint_parachute_smoke );	
}

//*******************************************************************
//  Jungle Plaza (Plaza 1)  Intro                          *
//                                                                  *
//*******************************************************************

// Setting up escort start point section
escort_main()
{
	playerstart_escort_start();

	flag_wait( "jungle_plaza_enc_complete" );
}

// Main function that runs the encounters through the underground mall sections
playerstart_escort_start()
{
	level._start_point = "escort";

	city_hall_east_exit();

	// Objective saving and handling
	setSavedDvar( "ObjectiveFadeTooFar", 1 );
	objective_number = 21;
	Objective_Add( objective_number, "current", "Get Patriot to the Monorail Station." );
//	Objective_OnEntity( objective_number, level.squad[2], ( 0, 0, 70 ) ); 
//	Objective_SetPointerTextOverride( objective_number, "Protect" );

	autosave_now();
	
	waittill_aigroupcleared( "plaza_last_stand" );

//	flag_wait( "tunnel_door_setup" );

	flag_wait( "jungle_plaza_enc_complete" );

	flag_set( "vp_move_7" );
}

city_hall_east_exit()
{
	level thread hallway_shake();
	level thread intro_door_scene();
	level thread city_hall_baker_move_to_door();	// Setting Baker up to open the door while spooling up the encounter ahead
	level thread jungle_plaza_enc();

	// Set initial visionset
	set_vision_set( "nx_hithard_b_opening", 0.1 );

	// Baker: <whispered>We'll meet Bravo just north of here - stay low and out of sight... 
//	radio_dialogue( "hithard_bak_plaza_02" );
	level.squad[0] dialogue_queue( "hithard_bak_plaza_02" );

	flag_set( "intro_sequence_complete" );

	level.squad ignore_me_on();
	level.squad ignore_all_on();
	level._player.ignoreme = true;

	cqb_handling( level.squad, "on" );
	level.squad[2] disable_cqbwalk();

	intro_street_sequence();

}

intro_door_scene()
{
	self endon( "intro_sequence_complete" );

	flag_set( "hallway_shake" );
	flag_set( "fx_back_half_turn_off" ); 

	level.squad[2].animname = "vp_price";
	level.squad[3].animname = "ss_williams";
	level.squad[4].animname = "ss_hayes";

//	level.squad[2] thread anim_loop_solo( level.squad[2], "cargoship_ch46_rescue_load_1_idle", "stop_idle" );
	level.squad[3] thread anim_single_solo( level.squad[3], "exposed_reload" );
	level.squad[4] thread anim_single_solo( level.squad[4], "exposed_reloadb" );

	flag_wait( "intro_sequence_complete" );
//	level.squad[2] notify( "stop_idle" );

}

intro_street_sequence()
{
	level thread uav_loop();
	level thread VTOL_loop();

	a_ugv = GetEntArray( "intro_ugv", "targetname" );
	a_uav = GetEntArray( "intro_uav", "targetname" );

	foreach( guy in a_ugv )
	{
		guy gopath();
		guy set_cheap_turret();
	}

	foreach( guy in a_uav )
	{
		guy maps\_attack_heli::SAV_setup( "pathing" );
	}

	ugv = GetEnt( "intro_ugv_firing", "script_noteworthy" );
	level thread ugv_firing_sequence( ugv, "firing_stop" );

}

ugv_plaza_guard()
{
	self endon( "plaza_enc_complete" );

	flag_wait( "left_path_complete" );

	ugv_spawner = GetEnt( "ugv_plaza_guard", "targetname" );

	ugv_spawner spawn_vehicle_and_gopath();

	ugv = Get_Vehicle( "ugv_plaza_guard", "targetname" );
	ugv Vehicle_TurnEngineOff();
//	turret = ugv.mgturret[0];

//	turret TurretFireDisable();

	flag_wait( "jungle_enc_moveup_mid" );

	ugv Delete(); // Delete first ugv that is no longer being used
/*
	ugv_border_patrol = GetEnt( "border_patrol", "targetname" );
	ugv_border_patrol spawn_vehicle_and_gopath();

	ugv_patrol = Get_Vehicle( "border_patrol", "targetname" );
	ugv_patrol Vehicle_TurnEngineOff();
*/
}

city_hall_baker_move_to_door()
{
	self endon( "last_stand_setup" );

	door_opener = level.squad[ 0 ];  // Baker
	door_opener.goalradius = 8;
	door_opener.animname = "baker";  //assign animname to AI so we can later call animation on.
	ready_node = GetNode( "baker_city_hall_exit", "targetname" );
	door_opener SetGoalNode( ready_node );

	node_door = GetEnt( "baker_door_origin", "targetname" ); //called on script_origin node, grabs KVP, and assigns to variable.
	node_door anim_reach_and_approach_solo( door_opener, "hunted_open_barndoor_stop", undefined, "Cover Right" ); //blends into first frame of open door anim based off cover right anim pose.  Also ends anim in cover right position.
	node_door thread anim_loop_solo( door_opener, "hunted_open_barndoor_idle", "stop_idle" ); // Holds Opener in place until we're ready for them to open the door

	flag_wait( "intro_sequence_complete" );
	
	node_door notify( "stop_idle" );  // Notifies the idle animation called earlier to release its hold on the Opener (keeps them from going back into the idle anim)	

	node_door thread anim_single_solo( door_opener, "hunted_open_barndoor" ); //play anim to open door.

	door = getent( "ch_exit", "targetname" );
	attachments = GetEntArray( door.target, "targetname" );  //looks at the door entity "target" KVP, then finds every other entity that has the same KVP defined as a targetname.  In this case "door_attachments".

	//Cycle through entities with "door_attachment" KVP and links them to the door entity.
	for ( i = 0; i < attachments.size; i++ )
	{
		attachments[ i ] LinkTo( door );
	}

	old_angles = door.angles;
	thread maps\nx_hithard_b_amb::ext_door_open();
//	flag_set( "fx_intro_door_opening" );  //sets off dust effect as the door opens
	door hunted_style_door_open();

	// Set initial visionset
	set_vision_set( "nx_hithard_b_outdoor_default", 1.0 );

	for ( i = 0; i < attachments.size; i++ )
	{
		if ( attachments[ i ].classname == "script_brushmodel" )
		{
			attachments[ i ] ConnectPaths();
		}
	}

	// Move baker and gypsy out of the way
	level.squad[0] doorClearing( GetNode( "baker_door_clear", "targetname" ) );
	level.squad[1] doorClearing( GetNode( "gypsy_door_clear", "script_noteworthy" ) );

	door_opener waittill( "goal" );

	foreach( guy in level.squad )
	{
		guy enable_ai_color();
	}

	level.squad[2] issue_color_orders( "p2", "allies" );
	level.squad[3] issue_color_orders( "r2", "allies" );
	level.squad[4] issue_color_orders( "r2", "allies" );

//	door_opener enable_ai_color();

	flag_wait( "intro_street_complete" );

	door rotateto( old_angles, 1 );
}

doorClearing( clear_node )
{
	self SetGoalNode( clear_node );
	self.goalradius = 8;
}

jungle_plaza_enc()
{
	flag_wait( "magicgrenade_teargas_hall_exit" ); // wait for the player to get out of the door

	level thread uav_reveal();
	level thread left_path_setup();
	level thread ugv_plaza_guard();
	level thread left_path_detail();
	level thread right_path_detail();
	level thread vp_movement();
	level thread last_stand_enc();
//	level thread boundary_breach_kill_triggers();

	level.squad[1] set_force_color( "c" );	// Gypsy - setting him up to follow player based on which path they take through this section
	wait 3.5;
	level notify( "firing_stop" );

	// Triggered when the player has "beaten" half of the encounter
	flag_wait( "jungle_enc_moveup_mid" );

	// Shift AI to fill the hall and not flank behind the player
	patio_volume = GetEnt( "vol_plaza1_patio", "script_noteworthy" );
	hall_volume = GetEnt( "left_to_right_switch", "script_noteworthy" );
	a_remaining = GetAiArray( "axis" );

	foreach( guy in a_remaining )
	{
		if ( guy IsTouching( patio_volume ) )
		{
			guy SetGoalVolumeAuto( hall_volume );
		}
	}

	flag_set( "vp_move_33" ); // vp_movement()
	flag_wait( "last_stand_setup" );
	waittill_aigroupcleared( "plaza_last_stand" );

	trigger_off( "crater_soldiers", "script_noteworthy" );
	trigger_off( "uav_last_stand_spawner", "script_noteworthy" );
	flag_set( "vp_move_7" );

	// Cleaning up stragglers
	enemies = GetAiArray( "axis" );
	foreach ( guy in enemies )
	{
		guy kill();
	}

	UAVs = GetVehicleArray();
	foreach ( vehicle in UAVs )
	{
		vehicle kill( vehicle.origin, level.squad[1] );
	}

	flag_set( "jungle_plaza_enc_complete" );

	// Baker: Clear!  Move forward!
//	radio_dialogue( "hithard_bak_move_07" );
	level.squad[0] thread dialogue_queue( "hithard_bak_move_07" );

	autosave_now();

	level notify( "plaza_1_end" );

	// Setting up vehicle at exit door to explode for flavor
	exploding_car = GetEnt( "exploding_car", "script_noteworthy" );
	exploding_car kill();

}

uav_reveal()
{
	uav = GetEnt( "uav_spotter", "targetname" );
	uav waittill( "spawned" );

	cqb_handling( level.squad, "off" );
	level.squad ignore_me_off();
	level._player.ignoreme = false;

	// Let Baker and Duke handle the next couple segments without too many interruptions
	level.squad[0] disable_pain();
	level.squad[1] disable_pain();

	// Send Baker and Duke to blocking nodes for the UAV moment
	level.squad[0].goalradius = 8;
	level.squad[1].goalradius = 8;
	level.squad[0] SetGoalNode( GetNode( "baker_uav", "script_noteworthy" ) );
	level.squad[1] SetGoalNode( GetNode( "gypsy_uav", "script_noteworthy" ) );

	level notify( "intro_done" );

	flag_set( "vp_move_3" ); // vp_movement()

	uav_ent = Get_Vehicle( "uav_spotter", "targetname" );
	PlayFXOnTag( level._effect[ "flashlight" ], uav_ent, "tag_origin" );

	level thread uav_baker_dialogue( uav_ent );

	// Make squad react to the UAV a little slower than the player
	wait 1.0; 
	level.squad ignore_all_off();

	uav_ent waittill( "death" );

	level.squad[0].goalradius = 8;
	level.squad[1].goalradius = 8;
	level.squad[0] SetGoalNode( GetNode( "baker_left_path_start", "script_noteworthy" ) );
	level.squad[1] SetGoalNode( GetNode( "gypsy_left_path_start", "script_noteworthy" ) );
	level.squad[0].ignoreme = true; // Allow Baker some leeway during this next segment

//	baker_node = GetEnt( "baker_uav_talk", "targetname" );
//	baker_node thread uav_scene_baker();
	level thread uav_scene_baker();

/*
	//level.squad[4].animname = "ss";
	ss_node = GetNode( "ss_williams_postup", "script_noteworthy" );

	ss_node anim_reach_solo( level.squad[4], "hunted_open_barndoor_idle" );
	ss_node thread anim_loop_solo( level.squad[4], "hunted_open_barndoor_idle", "stop_idle" );	
	ss_node notify( "stop_idle" );
*/


	autosave_now();

	flag_wait( "uav_scene_end" );

	flag_set( "left_path_begin" );

	level.squad[4] enable_ai_color();

	level.squad[0] waittill( "goal" );

	//  Turn battle back on for all allies
	level.squad ignore_me_off();
	level.squad ignore_all_off();
	level._player.ignoreme = false;

	battlechatter_on( "allies" );
	battlechatter_off( "axis" );
}

// Threading dialogue so scripts aren't held up
uav_baker_dialogue( uav )
{
	level endon( "baker_stop_prodding" );

	// Baker: UAV!  Take it down!
	level.squad[0].animname = "baker";
	level.squad[0] dialogue_queue( "hithard_bak_plaza_01" );

	uav waittill( "death" );

	// Baker: They know we're here!
	level.squad[0] thread dialogue_queue( "hithard_bak_plaza_05" );

	flag_wait( "left_path_complete" );

	add_dialogue_line( "BAKER", "Specter, let's get this hall cleared!", "blue", 2.0 );

	// Nag player until they move up and engage the right path
	nag = [];
	nag [0] = "hithard_bak_plaza2_03";
	nag [1] = "hithard_bak_plaza_07";
	nag [2] = "hithard_bak_plaza_08";

	while( 1 )
	{
		wait 9.0;

		line = random( nag );
		level.squad[0] dialogue_queue( line );
//		radio_dialogue( line, 2.0 );
	}
}

uav_scene_baker()
{
	level.squad[0].animname = "baker";

//	self anim_reach_and_approach_solo( level.squad[0], "casual_crouch_V2_idle_in" );
//	self anim_single_solo( level.squad[0], "stand_exposed_wave_move_out" );

	level.squad[0] disable_cqbwalk();
	level.squad[0] disable_ai_color();

	flag_set( "uav_scene_end" );
}

left_path_setup()
{
	flag_wait( "left_path_begin" );

	left_path_spawners = GetEntArray( "left_path_main_flood", "script_noteworthy" );
	foreach( guy in left_path_spawners )
	{
		guy spawn_ai();
	}

	level thread misc_dialogue();
}


left_path_detail()
{
	self endon( "last_stand_setup" );

	vtol_group_1 = get_ai_group_ai( "vtol_group_1" );
	foreach( guy in vtol_group_1 )
	{
		guy.ignoreall = true;
	}

	waittill_aigroupcount( "left_path_main_flood", 7 );
	// Duke: Fuck, there's a ton of them
//	radio_dialogue( "hithard_gyp_monorail_01" );
	level.squad[1] dialogue_queue( "hithard_gyp_monorail_01" );

	wait 0.5;
	// SS Lead: We'll take Patriot on the path to the right!
//	radio_dialogue( "hithard_sslead_plaza_02" );
	level.squad[3] dialogue_queue( "hithard_sslead_plaza_02" );

	flag_set( "vp_move_31" ); // vp_movement()

	// Baker: Suppressing Fire!
	level.squad[0] dialogue_queue( "hithard_bak_plaza2_05" );

	// Prod remaining troops to stop hiding come out of cover
	remaining_hallway_troops = get_ai_group_ai( "left_path_main_flood" );
	foreach( guy in remaining_hallway_troops )
	{
		guy set_ignoreSuppression( true );
	}

	waittill_aigroupcount( "left_path_main_flood", 4 );
	flag_set( "left_path_complete" );

	wait 1.5;

	// Baker: UGV, let's get the fuck outta here!
	level.squad[0] dialogue_queue( "hithard_bak_vp2_04" );
	// Duke: Gotch'yer back!
	add_dialogue_line( "DUKE", "I'll cover our six - you guys keep moving!", "orange", 2.0 );

	// Objective saving and handling
	objective_number = 22;
	Objective_Add( objective_number, "current", "Follow Captain Baker and help run point." );
	Objective_OnEntity( objective_number, level.squad[0], ( 0, 0, 70 ) ); 

	// Grab the fast ropers, wake them up, and tell them to stick around in the patio area
	vtol_group_1 = get_ai_group_ai( "vtol_group_1" );
	patio_vol = GetEnt( "vol_plaza1_patio", "script_noteworthy");
	foreach( guy in vtol_group_1 )
	{
		guy.ignoreall = false;
		guy SetGoalVolumeAuto( patio_vol );
	}

	level.squad[0].goalradius = 8;
	level.squad[0] SetGoalNode( GetNode( "baker_right_path_start", "script_noteworthy" ) );
//	level.squad[0] disable_pain();
	level.squad[1] disable_pain(); // Make Duke take his stand with fewer interruptions
	level.squad[4] disable_pain(); // Agent Hayes needs help getting out of the line of fire
	level.squad[0] waittill( "goal" ); // Wait until Baker posts up...
	flag_wait( "left_path_complete" );
	level.squad[0] enable_pain(); // ...and turn pain back on for Baker
	level.squad[1].goalradius = 8;
	level.squad[1] SetGoalNode( GetNode( "baker_left_path_start", "script_noteworthy" ) );  //Have Duke take over the better firing position

	waittill_aigroupcleared( "left_path_main_flood" );

}

misc_dialogue()
{
	self endon( "jungle_plaza_enc_complete" );

	flag_wait( "left_path_complete" );
	waittill_aigroupcleared( "right_path_first_wave"  );

	// Baker: Specter!  Keep moving!
//	radio_dialogue( "hithard_bak_plaza_07", 2.0 );
	level.squad[0] thread dialogue_queue( "hithard_bak_plaza_07" );

	flag_wait( "jungle_enc_moveup_mid" );

	add_dialogue_line( "BAKER", "<radio> How're we doing over there, Duke?", "blue", 2.0 );
	add_dialogue_line( "DUKE", "<radio> Almost cleared.  Flanking left; I'll meet you up ahead.", "orange", 2.0 );
	add_dialogue_line( "BAKER", "<radio> Roger that.", "blue", 1.0 );

	flag_wait( "left_path_cleanup" );

	// Baker: Specter, push the line!
	level.squad[0] thread dialogue_queue( "hithard_bak_plaza2_03" );
}

right_path_detail()
{
	self endon( "last_stand_setup" );

	flag_wait( "vp_move_31" );

	level notify( "baker_stop_prodding" );	

	waittill_aigroupcount( "right_path_first_wave", 2 );

	level.squad[0] enable_ai_color(); // Get Baker moving forward
	level.squad[0] issue_color_orders( "b31", "allies" );

	flag_wait( "right_path_commit" );	
	level.squad[1].attackeraccuracy = 0;  // Make Duke invulnerable while he holds down the rear

	left_path_cleaned = get_ai_group_ai( "left_path_main_flood" );
	foreach( fool in left_path_cleaned )
	{
		fool kill();
	}

	level thread flashbang_right_path();

	flag_wait( "vp_move_32" );

	// Baker: Get Patriot to cover!
	level.squad[0] thread dialogue_queue( "hithard_bak_plaza_16" );

	waittill_aigroupcount( "vtol_group_1", 4 );

	// Wait for the patio area to be cleared, force reminaing enemies from cover, and then push Baker and crew forward
	vol_plaza1_patio = GetEnt( "vol_plaza1_patio", "script_noteworthy" );

	// Prod remaining troops to stop hiding come out of cover
	patio_remnants = vol_plaza1_patio get_ai_touching_volume( "axis" );
	foreach( guy in patio_remnants )
	{
		guy set_ignoreSuppression( true );
	}

	vol_plaza1_patio waittill_volume_dead_or_dying();

	issue_color_orders( "b33", "allies" ); // Get Baker to move up
	issue_color_orders( "r33", "allies" ); // Move extra SS up

	level.squad[1].threatbias = -500; // Give Duke a chance at holding down the other side
	level.squad[0].threatbias = 10000; // Baker's getting a wake up call
	level._player.threatbias = 10000; // ...and so is the player

	flag_set( "vp_move_33" );

	autosave_now();

	flag_wait( "left_path_cleanup" );
	
	// Removing the stalemates at the end of the left path hall to allow Duke to rejoin the group
	a_left_path_stalemate = get_ai_group_ai( "left_path_stalemate" );
	foreach( fool in a_left_path_stalemate )
	{
		fool kill();
	}

}

flashbang_right_path()
{
	flag_wait( "flashbang_right_path" );
	MagicGrenade( "flash_grenade", GetStruct( "flashbang_right_path_origin", "targetname" ).origin, GetStruct( "flashbang_right_path_target", "targetname" ).origin, 1.0 );
}

vp_protect_moment()
{

}


last_stand_enc()
{
	flag_wait( "last_stand_setup" );

	// Moving Duke up to rejoin the squad
	teleport_node = GetNode( "duke_teleport_middle_path", "script_noteworthy" );
	level.squad[1] ForceTeleport( teleport_node.origin, teleport_node.angles );
	level.squad[1] SetGoalNode( GetNode( "duke_last_stand_setup", "script_noteworthy" ) );
	level.squad[1] enable_pain();
	level.squad[1].goalradius = 64;
	level.squad[1] waittill( "goal" );

	level.squad[1].animname = "gypsy";
	// Duke: Got 'em cornered now!
//	radio_dialogue( "hithard_gyp_plaza_01" );
	level.squad[1] dialogue_queue( "hithard_gyp_plaza_01" );
	// Baker: Finish them off!
//	radio_dialogue( "hithard_bak_plaza_17" );
	level.squad[0] dialogue_queue( "hithard_bak_plaza_17" );

	last_stand_volume = GetEnt( "last_stand_volume", "script_noteworthy" );

	a_remaining = GetAiArray( "axis" );

	foreach( guy in a_remaining )
	{
		guy SetGoalVolumeAuto( last_stand_volume );
	}

}


vp_movement()
{
	//level.squad[2].animname = "vp";
	//level.squad[3].animname = "ss";

	level.squad[2] disable_pain();
	level.squad[3] disable_pain();

	// UAV attack
	flag_wait( "vp_move_3" );
	ss_vignette_move( GetNode( "vp_vig_3", "script_noteworthy" ), level.squad[2], level.squad[3], false );

	// Plaza 1 start
	flag_wait( "vp_move_31" );
	ss_vignette_move( GetNode( "vp_vig_31", "script_noteworthy" ), level.squad[2], level.squad[3], false );

	// Sunglass shop
	flag_wait( "vp_move_32" );
	ss_vignette_move( GetNode( "vp_vig_32", "script_noteworthy" ), level.squad[2], level.squad[3], false );
	wait 2.5;
	// Baker: Specter!  We're pinned down over here!
//	radio_dialogue_safe( "hithard_bak_highway_12" );

	// Lower level shop start
	flag_wait( "vp_move_33" );
	// Baker: Specter!  Move up!
//	radio_dialogue_interupt( "hithard_bak_plaza_08" );
	level.squad[0] thread dialogue_queue( "hithard_bak_plaza_08" );
	wait 1.5;
	ss_vignette_move( GetNode( "vp_vig_33", "script_noteworthy" ), level.squad[2], level.squad[3], false );

	// Coffee shop harden point
	flag_wait( "vp_move_34" );
	ss_vignette_move( GetNode( "vp_vig_34", "script_noteworthy" ), level.squad[2], level.squad[3], false );
	flag_set( "vp_protect_moment" );

	// Plaza 1 final 
	flag_wait( "vp_move_7" );
	level.squad[ 2 ] notify( "stop_vignette" );
	level.squad[2] SetGoalNode( GetNode( "node_mall_tunnel_ally_vp_price", "script_noteworthy" ) );
	level.squad[3] SetGoalNode( GetNode( "node_mall_tunnel_ally_ss_walker", "script_noteworthy" ) );
	level.squad[4] SetGoalNode( GetNode( "node_mall_tunnel_ally_ss_hayes", "script_noteworthy" ) );

	flag_wait( "exit_plaza" );
	level.squad[2] enable_ai_color();
	level.squad[3] enable_ai_color();
	issue_color_orders( "p8", "allies" );
	issue_color_orders( "r8", "allies" );

}


//*******************************************************************
//           Plaza 1 periphery scripts              *
//                                                                  *
//*******************************************************************
ugv_firing_sequence( ugv, stop_command )
{
	self endon( "firing_stop" );

	target = getstruct( "ugv_targets", "targetname" );
	
	while ( 1 )
	{
		turret = ugv.mgturret[0];

		turret StartBarrelSpin();

		r = RandomFloat( 360 );
		s = RandomFloatRange( 120.0, 240.0 );
		targetPos = target.origin + ( cos(r)*s, sin(r)*s, 0);
		turret SetTurretTargetPosition( targetPos );

		turret ShootTurret();

		wait RandomFloatRange( 0.2, 2.0);
	}
}

uav_loop()
{
	self endon( "uav_scene_end" );

	while ( 1 )
	{
		a_uav = GetEntArray( "intro_uav_loop", "targetname" );
	
		foreach( guy in a_uav )
		{
			guy maps\_attack_heli::SAV_setup( "pathing" );
		}

		wait 4.0;
	}
}

VTOL_loop()
{
	self endon( "uav_scene_end" );

	while ( 1 )
	{
		a_VTOL = GetEntArray( "intro_street_VTOL_fill", "targetname" );
	
		foreach( guy in a_VTOL )
		{
			guy spawn_vehicle_and_gopath();
			wait 1.0; 
		}

		wait 5.0;
	}
}


//*******************************************************************
//           Underground Mall Tunnel                      *
//                                                                  *
//*******************************************************************

mall_tunnel_main()
{
	level._start_point = "mall_tunnel";

	flag_set( "jungle_plaza_enc_complete" );

	// Objective and saving handling
	objective_number = 21;
	thread maps\_utility::set_ambient( "nx_hithard_ext_b" );
//	Objective_Add( objective_number, "current", "Get Patriot to the Monorail Station." );

//	autosave_now();

	playerstart_mall_tunnel_start();

	flag_wait( "tunnel_enc_complete" );
//	flag_wait( "plaza_enc_complete" );
}

playerstart_mall_tunnel_start()
{
	flag_wait( "jungle_plaza_enc_complete" );

	plaza_exit_sequence();

	// Wait until civ moment is resolved one way or another
	waittill_aigroupcleared( "civ_moment_squad" );

	// Possible duke VO line if Civilians are alive
	thread mall_its_not_safe();

	autosave_now();

	flag_wait( "player_exited_restaurant" );
	
	// Move into the open
	issue_color_orders( "p11", "allies" );
	issue_color_orders( "r11", "allies" );
	issue_color_orders( "c10", "allies" );
	issue_color_orders( "b10", "allies" );
	level.squad[0] waittill( "goal" );

	flag_set( "tunnel_enc_complete" );

	objective_number = 23;
	Objective_Add( objective_number, "current", "Regroup with the squad." );
	Objective_OnEntity( objective_number, level.squad[0], ( 0, 0, 70 ) );

	level._player waittill_entity_in_range( level.squad[0], 250 );
	Objective_State( objective_number , "done" );
	
	objective_number = 21;
	Objective_State( objective_number, "current" );
	objective_loc = GetEnt( "monorail_entrance_loc", "targetname" );
	Objective_Position( objective_number, objective_loc.origin );

}

mall_its_not_safe()
{
	if ( !isdefined( level.mall_civilians ))
	{
		return;
	}

	flag_wait( "player_exited_restaurant" );

	foreach ( civilian in level.mall_civilians )
	{
		if ( isalive( civilian ) )
		{
			// Someone's alive!  Play the line
			level.squad[1].animname = "gypsy"; // Just in case

			wait 2.5;
			// Duke: It's not safe here, people - find cover!
			level.squad[1] dialogue_queue( "hithard_gyp_mall_07" );

			flag_set( "civilian_escape" );

			// Baker: Duke, let’s GO!
			level.squad[0] dialogue_queue( "hithard_bak_mall_11" );

			return;
		}
	}
}

plaza_exit_sequence()
{
	level thread plaza_exit_dialogue();

	tunnel_enc();
}

plaza_exit_dialogue()
{
	level thread plaza_door();

	flag_wait( "tunnel_door_setup" );

	// Baker: Duke, get the door
//	radio_dialogue( "hithard_bak_mall_03" );
	level.squad[0] dialogue_queue( "hithard_bak_mall_03" );

	flag_set( "exit_plaza" );
	wait 1.0;

	flag_wait( "entered_store" );
}

plaza_door()
{
	door_opener = level.squad[ 1 ];  // Gypsy
	door_guard = level.squad[ 0 ];  // Baker
	door_opener.goalradius = 8;
	door_opener.animname = "gypsy";  //assign animname to AI so we can later call animation on.
	ready_node = GetNode( "gypsy_plaza_exit", "targetname" );
	door_opener SetGoalNode( ready_node );
	door_guard SetGoalNode( GetNode( "baker_plaza_exit", "targetname" ) );

	node_door = GetEnt( "gypsy_door_origin", "targetname" ); //called on script_origin node, grabs KVP, and assigns to variable.
	node_door anim_reach_and_approach_solo( door_opener, "hunted_open_barndoor_stop" ); //blends into first frame of open door anim based off cover right anim pose.  Also ends anim in cover right position.
	node_door thread anim_loop_solo( door_opener, "hunted_open_barndoor_idle", "stop_idle" ); // Holds Opener in place until we're ready for them to open the door

	// waiting for everyone to get into place
	door_guard waittill( "goal" );

	objective_number = 22;
	Objective_Add( objective_number, "current", "Regroup with the squad." );
//	Objective_OnEntity( objective_number, level.squad[0], ( 0, 0, 70 ) );
	door_origin = GetEnt( "obj_regroup_plaza1", "targetname" );
	Objective_Position( objective_number, door_origin.origin );

	level._player waittill_entity_in_range( level.squad[0], 225 );
	Objective_State( objective_number , "done" );
	objective_number = 21;
	Objective_State( objective_number, "current" );	

	// Baker: Hold here
//	radio_dialogue( "hithard_bak_mall_02" );
	level.squad[0] dialogue_queue( "hithard_bak_mall_02" );

	level.squad[ 2 ] waittill( "goal" );
	level.squad[ 3 ] waittill( "goal" );
	level.squad[ 4 ] waittill( "goal" );

	flag_set( "tunnel_door_setup" );	
	flag_wait( "exit_plaza" );

	node_door notify( "stop_idle" ); // Notifies the idle animation called earlier to release its hold on the Opener (keeps them from going back into the idle anim)	

	level endon( "civilian_enc_start" );

	node_door thread anim_single_solo( door_opener, "hunted_open_barndoor" ); //play anim to open door.

	door = getent( "plaza_exit_origin", "targetname" );
	attachments = GetEntArray( door.target, "targetname" );  //looks at the door entity "target" KVP, then finds every other entity that has the same KVP defined as a targetname.  In this case "door_attachments".

	//Cycle through entities with "door_attachment" KVP and links them to the door entity.
	for ( i = 0; i < attachments.size; i++ )
	{
		attachments[ i ] LinkTo( door );
	}

	old_angles = door.angles;
	door hunted_style_door_open( "metal_door_open" );

	for ( i = 0; i < attachments.size; i++ )
	{
		if ( attachments[ i ].classname == "script_brushmodel" )
		{
			attachments[ i ] ConnectPaths();
		}
	}

	// Gypsy cautions us all to be quiet
	quiet_node = GetNode( "gypsy_door_be_quiet", "targetname" );
	quiet_node anim_reach_and_approach_solo( door_opener, "CQB_stand_signal_stop" );

	level.squad[1] thread mall_duke_callout();
	level.squad[1] anim_single_solo( level.squad[1], "CQB_stand_signal_stop" );


	self.grenadeAmmo = 3; // Gives the actor 3 grenades of whatever type they currently have
	self.grenadeWeapon = "flash_grenade"; // Switches the actor's grenade type to flashbangs.  Use "fraggrenade" for frags.


	// Move gypsy out of the way
	clear_node = GetNode( "gypsy_door_clear", "targetname" );
	door_opener SetGoalNode( clear_node );
	door_opener.goalradius = 8;

	flag_set( "civilian_enc_start" ); // also ends script
}

mall_duke_callout()
{
	wait 0.5;
	// Duke: Two on the right...stay down
//	radio_dialogue( "hithard_gyp_mall_02" );
	level.squad[1] dialogue_queue( "hithard_gyp_mall_02" );
}

tunnel_enc()
{
	civilian_enc();
}

civilian_enc()
{
	flag_wait( "jungle_plaza_enc_complete" );

	civ_moment_noteworthies = [ "hall_shooter", "hall_guard", "hall_check_a", "hall_check_b", "civ_a", "civ_b" ];
	soldier_spawners = [];
	civilian_spawners = [];

	// Wait until Baker finishes his warning & player has entered store
	flag_wait( "entered_store" );	

	thread slomo_handling();

	// Set ignores
	thread mall_set_player_ignores( "player_interruption" );
	level.squad[0] thread mall_set_ai_ignores( "flag_mall_door_open" ); // Baker doesn't return to combat until he opens the door
	level.squad[1] thread mall_set_ai_ignores( "player_interruption" );	// Duke will return to combat immediately on player interruption

	// Spawn soldiers
	soldiers = [];
	soldiers[0] = mall_civ_moment_spawner( "hall_shooter", "hall_shooter", ::mall_civ_moment_shoot_civilians, ::mall_civ_moment_soldier_spawn_func );
	soldiers[1] = mall_civ_moment_spawner( "hall_guard", "hall_guard", ::mall_civ_moment_guard, ::mall_civ_moment_soldier_spawn_func );
	soldiers[2] = mall_civ_moment_spawner( "hall_check_a", "hall_check_a", ::soldier_survey_near, ::mall_civ_moment_soldier_spawn_func );
	soldiers[3] = mall_civ_moment_spawner( "hall_check_b", "hall_check_b", ::soldier_survey_far, ::mall_civ_moment_soldier_spawn_func );

//	PlayFXOnTag( level._effect[ "flashlight_spotlight" ], soldiers[2], "tag_flash" );
//	PlayFXOnTag( level._effect[ "flashlight" ], soldiers[2], "tag_flash" );

//	PlayFXOnTag( level._effect[ "flashlight" ], soldiers[3], "tag_flash" );
//	level thread attach_flashlight( soldiers[2], soldiers[3] );

	level.mall_civilians = [];
	level.mall_civilians[0] = mall_civ_moment_spawner( "civ_a", "civ1", ::mall_civ_moment_civ_spawn_func );
	level.mall_civilians[1] = mall_civ_moment_spawner( "civ_b", "civ2", ::mall_civ_moment_civ_spawn_func );

	// Civilian & enemy dialogue and animations
	level thread mall_civ_moment_soldiers( soldiers, level.mall_civilians );

	// Wait until Duke finishes his warning or player walks too far into the room
	flag_wait( "civilian_enc_start" );

	// Civ dialogue begins
	level thread mall_civ_dialogue( soldiers, level.mall_civilians );

	// If player does something bad from this point on, interrupt moment
	level thread set_flag_on_player_action( "player_interruption" );

	// Allies will attempt to go into into the room, ally dialogue fires off when in position
	level thread civ_moment_allies( soldiers[0], soldiers[2], soldiers[1] );

	wait 3;

	// Set color nodes for VP and SS to follow
	issue_color_orders( "b8", "allies" );

	wait 3; // Having VP hang back a moment
	issue_color_orders( "p85", "allies" );
	issue_color_orders( "r85", "allies" );

	flag_wait( "player_interruption" );

	// When interrupted, soldiers go into combat, civilians run
}

slomo_handling()
{
	level endon( "player_exited_restaurant" );

	flag_wait( "player_interruption" );

	set_vision_set( "nx_hithard_b_outdoor_default", 0.1 );
	SetSlowMotion( 1.0, 0.25, 0.5 );

	// Pull player out of slowmo
	wait 1.75;
	slowmo_setlerptime_out( .05 );
	slowmo_lerp_out();
	slowmo_end();
	set_vision_set( "nx_hithard_b_diner_entrance", 1 );

	flag_set( "slowmotion_done" );
}

attach_flashlight( soldier_near, soldier_far )
{
	PlayFXOnTag( level._effect[ "flashlight_spotlight" ], soldier_near, "tag_flash" );
	PlayFXOnTag( level._effect[ "flashlight" ], soldier_near, "tag_flash" );
//	PlayFXOnTag( level._effect[ "flashlight" ], soldier_far, "tag_flash" );
//	self.have_flashlight = true;
	flag_wait( "civ_moment_in_position" );

	StopFXOnTag( level._effect[ "flashlight_spotlight" ], soldier_near, "tag_flash", true );
	StopFXOnTag( level._effect[ "flashlight" ], soldier_near, "tag_flash", true );
}

mall_civ_moment_spawner( noteworthy, animname, spawn_func1, spawn_func2 )
{
	spawner = GetEnt( noteworthy, "script_noteworthy" );
	assert( isdefined( spawner ) );

	spawner add_spawn_function( ::set_animname, animname );

	if ( IsDefined( spawn_func1 ) )
	{
		spawner add_spawn_function( spawn_func1 );
	}

	if ( IsDefined( spawn_func2 ) )
	{
		spawner add_spawn_function( spawn_func2 );
	}

	actor = spawner spawn_ai();

	return actor;
}

set_animname( animname )
{
	self.animname = animname;
}

mall_civ_moment_soldier_spawn_func()
{
	self endon( "death" );
	self enable_cqbwalk();
	self.ignoreall = true;

	flag_wait( "player_interruption" );

	self notify( "end_sequence" ); // If we are in a vignette when this happens, cut it short
	self.goalradius = 512;
	self.ignoreall = false;
	self disable_cqbwalk();
}

mall_civ_moment_civ_spawn_func()
{
	thread mall_tunnel_escape();
}

mall_civ_moment_soldiers( soldiers, civilians )
{
	level endon( "player_interruption" );
	level endon( "civ_moment_dialogue_complete" );

	// Survey soldiers
	//level thread soldier_survey_near( soldiers[ 2 ] );
	//level thread soldier_survey_far( soldiers[ 3 ] );

   	hunted = [];
	hunted["hall_shooter"] = soldiers[0];
	hunted["hall_guard"] = soldiers[1];
	//hunted["civ1"] = civilians[0];

	hunted_origin = GetEnt( "hunted_cutscene", "script_noteworthy" );
	//hunted_origin anim_reach( hunted, "mall_civ_moment" );
	hunted_origin anim_single( hunted, "mall_civ_moment" );

	//soldiers[0] mall_civ_moment_shoot_civilians( civilians );
	
	//array_thread( soldiers, ::mall_tunnel_escape );
}

mall_civ_dialogue( soldiers, civilians )
{
	level endon( "player_interruption" );
	soldiers[0] endon( "death" );
	soldiers[1] endon( "death" );
	civilians[0] endon( "death" );
	civilians[1] endon( "death" );

	soldiers[0] dialogue_queue( "hithard_ecso_mall_01" );
	civilians[0] dialogue_queue( "hithard_civ1_mall_02" );
	wait 2;
	soldiers[0] dialogue_queue( "hithard_ecso_mall_02" );
	civilians[0] dialogue_queue( "hithard_civ1_mall_01" );
	wait 2;
	soldiers[0] dialogue_queue( "hithard_ecso_mall_03" );
	civilians[1] dialogue_queue( "hithard_civ2_mall_01" );
	wait 2;
	soldiers[0] dialogue_queue( "hithard_ecso_mall_04" );
	civilians[0] dialogue_queue( "hithard_civ1_mall_03" );
	wait 2;
	soldiers[0] dialogue_queue( "hithard_ecso_mall_05" );
	civilians[0] dialogue_queue( "hithard_civ1_mall_04" );

	flag_set( "civ_moment_interrogation_dialogue_complete" );
}												

mall_civ_moment_shoot_civilians()
{
	self endon( "death" );	
	level endon( "player_interruption" );

	flag_wait( "civ_moment_dialogue_complete" );
	flag_wait( "civ_moment_interrogation_dialogue_complete" );

	self StopAnimScripted();
	wait 2;

	civilians = level.mall_civilians;
	foreach( civilian in civilians )
	{
		if ( isalive( civilian ) )
		{
			cqb_aim( civilian );
			wait 0.7;
			magicbullet( self.weapon, self gettagorigin( "tag_flash" ), civilian getShootAtPos() );
			civilian kill();
		}
	}
}

mall_civ_moment_guard()
{
	//self endon( "death" );
	//level endon( "player_interruption" );
	//self.animname = "soldier_guard";
}

mall_tunnel_escape()
{
	// Civilian attempts to escape
	self endon( "death" );
	waittill_aigroupcleared( "civ_moment_squad" );

	flag_wait( "civilian_escape" );

	wait( RandomFloatRange( 1.5, 2.25 ) );
	self.goalradius = 32;
	self SetGoalNode( GetNode( "mall_tunnel_escape", "script_noteworthy" ) );
	self waittill( "goal" );
	self delete();
}

mall_set_player_ignores( wait_flag )
{
	level._player.ignoreme = true;
	flag_wait( wait_flag );
	level._player.ignoreme = false;
}

mall_set_ai_ignores( wait_flag )
{
	self.ignoreme = true;
	self.ignoreall = true;
	self disable_ai_color();
	self enable_cqbwalk();

	flag_wait( wait_flag );

	self.ignoreme = false;
	self.ignoreall = false;
	self enable_ai_color();
	self set_force_color( "b" );
	self disable_cqbwalk();
}

civ_moment_allies( leader, soldier, guard )
{	
	level endon( "player_interruption" );

	// Post up Duke and Baker at their positions
	level.squad[ 0 ].goalradius = 8;
	level.squad[ 1 ].goalradius = 8;
	level.squad[ 0 ].fixednode = true;
	level.squad[ 1 ].fixednode = true;
	level.squad[ 0 ] SetGoalNode( GetNode( "civ_moment_baker_watch", "script_noteworthy" ) );
	level.squad[ 1 ] SetGoalNode( GetNode( "civ_moment_gypsy_watch", "script_noteworthy" ) );
	level.squad[ 0 ] thread mall_baker_opens_door();

	// Wait for them to get to their positions before continuing the dialgoue
	level.squad[ 1 ] waittill( "goal" );

	flag_set( "civ_moment_in_position" );
	level thread mall_allies_dialogue();

	level.squad[1] thread mall_duke_shoots_leader( leader, guard );
	level.squad[0] thread mall_baker_shoots_soldier_far( soldier );

	flag_wait( "civ_moment_dialogue_complete" );
	wait 5;

	// If player has not fired yet, duke does the deed
	level.squad[1] thread dialogue_queue( "hithard_gyp_mall_06" );
	level.squad[1].ignoreall = false;
	wait 1;

	flag_set( "player_interruption" );

}

mall_baker_opens_door()
{
	
	self.animname = "baker";
	level.squad[ 0 ] SetGoalNode( GetNode( "civ_moment_baker_watch", "script_noteworthy" ) );
	level.squad[ 0 ] waittill( "goal" );
	flag_wait( "player_interruption" );

	flag_wait( "slowmotion_done" );

	// Play door kick anim	
	wait 1.0;
	node = GetEnt("node_door_kick", "targetname");
	level.squad[ 0 ] SetGoalNode( GetNode( "mall_baker_door_open", "script_noteworthy" ) );
	// Baker: We're moving!
	level.squad[ 0 ] dialogue_queue( "hithard_bak_plaza_14" );
	level.squad[ 0 ] waittill( "goal" );
	wait 0.5; // Arrival
		
	node thread anim_single_solo(self, "door_kick_in");

	// Animate the door
	door = getent( "mall_kick_door", "targetname" );
	attachments = GetEntArray( door.target, "targetname" );  //looks at the door entity "target" KVP, then finds every other entity that has the same KVP defined as a targetname.  In this case "door_attachments".

	//Cycle through entities with "door_attachment" KVP and links them to the door entity.
	for ( i = 0; i < attachments.size; i++ )
	{
		attachments[ i ] LinkTo( door );
	}

	door hithard_style_door_kick( "scn_hithard_ally_door_smash_hit" );

	for ( i = 0; i < attachments.size; i++ )
	{
		if ( attachments[ i ].classname == "script_brushmodel" )
		{
			attachments[ i ] ConnectPaths();
		}
	}

	clear_node = GetNode("mall_door_kick_finish", "targetname");
	self SetGoalNode( clear_node );
	self.goalradius = 8;
	self waittill("goal");
	flag_set("flag_mall_door_open");
	flag_set( "fx_back_half_turn_on" );

	// Set Duke up near the door
	duke_clear_node = GetNode( "duke_post_civ_moment", "script_noteworthy" );
	level.squad[1].goalradius = 8;
	level.squad[1] SetGoalNode( duke_clear_node );

	flag_wait( "player_exited_restaurant" );

}

hithard_style_door_kick( soundalias )
{
	wait( 2.0 );

	if ( IsDefined( soundalias ) )
		self PlaySound( soundalias );
	else
		self PlaySound( "door_wood_slow_open" );

	//self RotateTo( self.angles + ( 0, 70, 0 ), .4, .1, 0 );
	self RotateTo( self.angles + ( 0, 100, 0 ), .4, .1, 0 );
	self ConnectPaths();
	self waittill( "rotatedone" );
	//self RotateTo( self.angles + ( 0, 70, 0 ), .4, .1, 0 );
	self RotateTo( self.angles + ( 0, -15, 0 ), 1, .1, .1 );
}

mall_duke_shoots_leader( leader, guard )
{
	self endon( "death" );
	cqb_aim( guard );
	level waittill( "player_interruption" );
	if ( isalive( guard ) )
	{
		magicbullet( self.weapon, self gettagorigin( "tag_flash" ), guard getShootAtPos() );
	}	
	else
	{
		if ( isalive( leader ) )
		{
			magicbullet( self.weapon, self gettagorigin( "tag_flash" ), leader getShootAtPos() );
		}
	}
}

mall_baker_shoots_soldier_far( soldier )
{
	self endon( "death" );
	cqb_aim( soldier );
	level waittill( "player_interruption" );
	if ( isalive( soldier ) )
	{
		magicbullet( self.weapon, self gettagorigin( "tag_flash" ), soldier getShootAtPos() );
	}	
}

mall_allies_dialogue()
{
	level endon( "player_interruption" );

	flag_wait( "civ_moment_in_position" );

	// Duke: Well what do we have here...
	level.squad[1] dialogue_queue( "hithard_gyp_mall_03" );
	// Baker: Must be about us
	level.squad[0] dialogue_queue( "hithard_bak_mall_05" );

	wait 2;

	// Duke: They don't like what they're hearing
	level.squad[1] dialogue_queue( "hithard_gyp_mall_04" );

	wait 1;
	// Baker: Their buddies are back
	level.squad[0] dialogue_queue( "hithard_bak_mall_06" );
	// Duke: I've got sights on the left one...
	level.squad[1] dialogue_queue( "hithard_gyp_mall_05" );
	// Baker: On you, Spectre
	level.squad[0] dialogue_queue( "hithard_bak_mall_08" );

	wait 3; // Give player time to shoot
	flag_set( "civ_moment_dialogue_complete" );
	
}

soldier_survey_near()
{
	level endon( "player_interruption" );
	self.goalradius = 8;

	self SetGoalNode( GetNode( "rubble_check_near", "targetname" ) );

    setsaveddvar( "r_spotlightstartradius", "50" );
    setsaveddvar( "r_spotlightendradius", "100" );
	setsaveddvar( "r_spotlightfovinnerfraction", "0" );
	setsaveddvar( "r_spotlightexponent", "0" );
	setsaveddvar( "r_spotlightBrightness", "16" );

	PlayFXOnTag( level._effect[ "flashlight_spotlight" ], self, "tag_flash" );
	PlayFXOnTag( level._effect[ "flashlight" ], self, "tag_flash" );

	self waittill( "goal" );

	flag_wait( "civ_moment_in_position" );
	wait 1;

	self.goalradius = 16;
	self SetGoalNode( GetNode( "survey_return_near", "targetname" ) );

	self waittill( "goal" );

	StopFXOnTag( level._effect[ "flashlight_spotlight" ], self, "tag_flash", true );
	StopFXOnTag( level._effect[ "flashlight" ], self, "tag_flash", true );
}

soldier_survey_far()
{
	level endon( "player_interruption" );
	self.goalradius = 8;

	self SetGoalNode( GetNode( "rubble_check_far", "targetname" ) );

	PlayFXOnTag( level._effect[ "flashlight" ], self, "tag_flash" );

	flag_wait( "civ_moment_in_position" );
	wait 1;

	self.goalradius = 24;
	self SetGoalNode( GetNode( "survey_return_far", "targetname" ) );

	self waittill( "goal" );

	StopFXOnTag( level._effect[ "flashlight" ], self, "tag_flash", true );
}

//*******************************************************************
//           Planter Plaza Encounter                        *
//                                                                  *
//*******************************************************************

plaza_enc_main()
{
	// STARTING UP THE MOVEMENT THREAD.
	level thread plaza_2_ally_movement();

	// TURNING ON FRIENDLY CHATTER DURING ENCOUNTER.
	level.squad ignore_me_off();
	level.squad ignore_all_off();
	level._player.ignoreme = false;
	battlechatter_on( "allies" );
	battlechatter_off( "axis" );

	// WAITING FOR TRIGGER AT THE END OF THE SECTION.
	flag_wait( "plaza_enc_complete" );

	// TURNING OFF FRIENDLY CHATTER AFTER ENCOUNTER.
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );

	// COMPLETING THE CURRENT OBJECTIVE.
	Objective_State( 21, "done" );

	// STOP VIGNETTE AND RE-ENABLING REGULAR COLOR CONTROL TO SS AND VP FOR NEXT SECTION.
	ss_vignette_end( level.squad[2], level.squad[3] );
	level.squad[2] enable_ai_color();
	level.squad[3] enable_ai_color();

	// HACK FOR ISSUES WITH ENABLING COLORS THEN SENDING COLOR COMMAND.
	waittillframeend;

	// MOVE EVERYONE FORWARD.
	issue_color_orders( "b140 r14 p14", "allies" );

	// STARTING UP MONORAIL ENCOUNTER.
	flag_set( "monorail_station_start" );

	autosave_now();
}

plaza_2_ally_movement() 
{
	// MAKING SURE THE ALLIES ARE SET TO MOVE ON COLORS.
	foreach( squadmate in level.squad )
    {
        squadmate enable_ai_color();
    }

	// HACK FOR ISSUES WITH ENABLING COLORS THEN SENDING COLOR COMMAND.
	waittillframeend;

	// WAITING UNTIL ALLIES MOVE THRU THE FIRST SECTION OF THE PLAZA.
	flag_wait( "vp_move_110" );
	
	// MOVE SQUAD FIRST, THEN SS ALONG WITH THE VP TO THE FIRST SAFE SPOT.
	plaza_2_issue_move("b110", "r110", "vp_vig_110", 0.5);

	// CAPTAIN BAKER: "Tangos! Second level!"
	radio_dialogue( "hithard_bak_plaza_12" );

	// WAITING UNTIL ALLIES MOVE THRU THE SECOND SECTION OF THE PLAZA.
	flag_wait( "vp_move_115" );

	// MOVE SQUAD FIRST, THEN SS ALONG WITH THE VP TO THE SECOND SAFE SPOT.
	plaza_2_issue_move("b115", "r115", "vp_vig_115", 0.5);

	// DUKE: "Move forward!"
	radio_dialogue( "hithard_gyp_move_03" );

	// WAITING UNTIL ALLIES MOVE THRU THE THIRD SECTION OF THE PLAZA.
	flag_wait( "vp_move_116" );

	// MOVE SQUAD FIRST, THEN SS ALONG WITH THE VP TO THE THIRD SAFE SPOT.
	plaza_2_issue_move("b116", "r116", "vp_vig_116", 0.5);

	// DUKE: "Keep moving!"
	radio_dialogue( "hithard_gyp_move_02" );

	// WAITING UNTIL ALLIES MOVE THRU THE FOURTH SECTION OF THE PLAZA.
	flag_wait( "vp_move_120" );

	// MOVE SQUAD FIRST, THEN SS ALONG WITH THE VP TO THE FOURTH SAFE SPOT.
	plaza_2_issue_move("b120", "r120", "vp_vig_120", 0.5);
}

plaza_2_issue_move(b_color_number, r_color_number, vp_node_number, wait_time)
{
	issue_color_orders( b_color_number, "allies" );

	wait wait_time;

	issue_color_orders( r_color_number, "allies" );
	ss_vignette_move( GetNode( vp_node_number, "script_noteworthy" ), level.squad[2], level.squad[3], false );
}

//*******************************************************************
//           Monorail Station Encounter                   *
//                                                                  *
//*******************************************************************

monorail_station_main()
{
	flag_set( "plaza_enc_complete" );

	objective_number = 24;
	obj_position = GetEnt( "on_ramp_lapse", "targetname" );
	Objective_Add( objective_number, "current", "Clear the monorail station." );
	Objective_Position( objective_number, GetEnt( "on_ramp_lapse", "targetname" ).origin );
	autosave_by_name( "plaza_enc_complete" );

	playerstart_monorail_start();
}

playerstart_monorail_start()
{
	level._start_point = "monorail";

	monorail_station_enc();

	flag_wait( "monorail_station_enc_complete" );

	autosave_now();
}

monorail_station_enc()
{
	level thread monorail_dialogue();

	flag_wait( "magicgrenade_monorail_start" );
	MagicGrenade( "smoke_grenade_american", GetStruct( "teargas_monorail_start_01_origin", "targetname" ).origin, GetStruct( "teargas_monorail_start_01_target", "targetname" ).origin, 1.0 );
	MagicGrenade( "smoke_grenade_american", GetStruct( "teargas_monorail_start_02_origin", "targetname" ).origin, GetStruct( "teargas_monorail_start_02_target", "targetname" ).origin, 3.0 );

	flag_wait( "monorail_station_enc_complete" );

	post_monorail_regroup();
}

monorail_dialogue()
{
	self endon( "monorail_station_enc_complete" );

	flag_wait( "monorail_station_start" );

	// Duke: Won't be safe here for long.
	radio_dialogue( "hithard_gyp_plaza2_04" );
	// Baker: That's why we're on the move.  The LZ can't be far now.
	radio_dialogue( "hithard_bak_plaza2_06" );
	// Baker: Are you still good to go, sir?
	radio_dialogue( "hithard_bak_plaza2_07" );
	// VP: You bet
	radio_dialogue( "hithard_vp_plaza2_01" );
	// Baker: We're heading out up and out of the station.  Sound good, Williams?
	radio_dialogue( "hithard_bak_plaza2_08" );
	// SS Lead: Sounds like a plan.  Move it!
	radio_dialogue( "hithard_sslead_plaza2_01" );


	flag_wait( "monorail_dialogue_start" );

	// Duke: Fuck me, there's a ton of them
	radio_dialogue( "hithard_gyp_monorail_01" );
	// Baker: More smoke, too.  Use your threat ID if you can
	radio_dialogue( "hithard_bak_mono_01" );

	wait (5.0);
	// Baker: Specter, get the angle on them!
	radio_dialogue( "hithard_bak_mono_02" );

}

post_monorail_regroup()
{
	Objective_State( 23, "done" );

	gypsy_node = GetNode( "gypsy_survey_homestretch", "script_noteworthy" );
	baker_node = GetNode( "baker_homestretch", "script_noteworthy" );

	level.squad[0].goalradius = 8;
	level.squad[1].goalradius = 8;

	level.squad[0] SetGoalNode( baker_node );
	level.squad[1] SetGoalNode( gypsy_node );

	level.squad[1] waittill( "goal" );
	level.squad[0] waittill( "goal" );

	// Duke: Home stretch, fellas.  I can see the highway...100 meters
	radio_dialogue( "hithard_gyp_highway_01" );
	// Baker: Let's punch it
	radio_dialogue( "hithard_bak_highway_02" );
	// SSLead: We're right behind you
	radio_dialogue( "hithard_sslead_highway_01" );

	level.squad[0] enable_ai_color();
	level.squad[1] enable_ai_color();

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


//*******************************************************************
//                                                                  *
//	MAIN: The following "main()" is called from nx_hithard_b.gsc		*
//                                                                  *
//*******************************************************************

city_hall_escape_main()
{
	level._start_point = "default";

	level thread cityhall_swat_door();

	playerstart_city_hall_escape_start();
}

city_hall_entrance()
{
	flag_wait( "ch_events_start" );

	city_hall_events();
}

// Handles ambient civilians that populate the inside of City Hall
city_hall_events()
{
	static_civilians = GetEntArray( "ch_civilian_spawners", "script_noteworthy" );

	foreach( guy in static_civilians )
	{
		guy spawn_ai();
	}

	clean_civilians( "ch_civilian_spawners", "city_hall_cleanup" );

	crowd_01 = maps\nx_crowd_controller::new_crowd( "ch_hall_left_civilians", 
	2, 
	GetEntArray( "ch_hall_left_spawners", "script_noteworthy" ), 
	GetEntArray( "ch_left_hall_start_01", "script_noteworthy"), 
	GetEntArray( "ch_left_hall_end_01", "script_noteworthy") );

	wait 4.0;

	maps\nx_crowd_controller::spawn_crowd( "ch_hall_left_civilians" );

}

clean_civilians( spawner_name, flag_to_wait_for )
{
	flag_wait( flag_to_wait_for );

	array_civilians = GetEntArray( spawner_name, "script_noteworthy" );

	foreach( guy in array_civilians )
	{
		guy Delete();
	}
}

// Sequence of SWAT guys holding the door to City Hall open and guiding the player into the building
cityhall_swat_door()
{
    cityhall_door = getent( "com_door_01_handleleft", "targetname" );
    cityhall_door assign_animtree("cityhall_door");

    swat_ally01 = getent("cityhall_swat_door_ally01", "script_noteworthy");
    swat_ally01.animname = "swat_ally01";

    swat_ally02 = getent("cityhall_swat_door_ally02", "script_noteworthy");
    swat_ally02.animname = "swat_ally02";

    node_cityhall_swat_door = getstruct("vinette_cityhall_swat_door", "script_noteworthy");

    guys = [];
    guys["cityhall_door"] = cityhall_door;
    guys["swat_ally01"] = swat_ally01;
    guys["swat_ally02"] = swat_ally02;

    node_cityhall_swat_door anim_first_frame(guys, "cityhall_swat_door_start");

    flag_wait("triggerplane");

    node_cityhall_swat_door anim_single(guys, "cityhall_swat_door_start");

    node_cityhall_swat_door thread anim_loop(guys, "cityhall_swat_door_idle");

    flag_wait("triggerplane2");

    foreach (swat in guys)
    {
        swat StopAnimScripted();
    }

    node_cityhall_swat_door thread anim_single(guys, "cityhall_swat_door_end");
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//Beginning script for starting out the skybridge sequence
playerstart_city_hall_escape_start()
{			
	flag_wait( "city_hall_briefing_end" );
	
	objective_number = 20;
	obj_position = GetEnt( "city_hall_east_exit", "targetname" );
	Objective_Add( objective_number, "current", "Make your way out of City Hall" );
	Objective_Position( objective_number, GetStruct( "city_hall_east_exit", "targetname" ).origin );
	thread skybridge_glass_break();
	thread skybridge_crossing();

	trigger_wait( "obj_city_hall_east_exit", "script_noteworthy" );
	Objective_State( objective_number , "done" );

	flag_set( "obj_east_done" );
	playerstart_escort_start();
	level._start_point = "escort";
}



//*******************************************************************
//  Skybridge Sequence                                      *
//                                                                  *
//*******************************************************************

skybridge_crossing()
{
	add_dialogue_line( "BAKER", "Stay down!  Best if we aren't seen when crossing." );

	foreach( guy in level.squad )
	{
		guy enable_cqbwalk();
	}

	flag_wait( "skybridge_seen" );
	add_dialogue_line( "GYPSY", "Shit, they see us!", "green" );
	add_dialogue_line( "BAKER", "They must have infrared...get outta here, gogogo!", "blue" );

	foreach( guy in level.squad )
	{
		guy disable_cqbwalk();
	}
}

skybridge_glass_break()
{
	trigger_wait_targetname( "trig_skybridge_glass_01" );
	level notify( "glass_break", level._player );

	autosave_now();

	thread city_hall_east_exit();
}


// Handles ambient civilians that populate the inside of City Hall East
city_hall_east_civilians()
{
	crowd_01 = maps\nx_crowd_controller::new_crowd( "east_elevator_crowd", 
	3, 
	GetEntArray( "east_elevator_crowd_spawners", "script_noteworthy" ), 
	GetEntArray( "east_elevator_crowd_start", "script_noteworthy"), 
	GetEntArray( "east_elevator_crowd_end", "script_noteworthy") );

	wait 4.0;

	maps\nx_crowd_controller::spawn_crowd( "east_elevator_crowd" );
}

hallway_shake()
{
	self endon( "intro_done" );

	flag_wait( "hallway_shake" );

	while( 1 )
	{
		level._player PlayRumbleOnEntity( "artillery_rumble" );
		Exploder( "fx_ceiling_dust" );
		pulselights( "opening_emergency_lights" );
		wait RandomFloatRange( 0.8, 3.0 );
	}
}

staircase_rumble()
{
	flag_wait( "stairway_shake" );

	level._player thread missile_hit_rumble();
	pulselights( "staircase_pulse_lights" );
}

pulselights( a_lights )
{
	lights = getentarray( a_lights, "targetname" );

	for ( i = 0; i < lights.size; i++ )
	{
		lights[ i ] thread flicker(); //custom function
		//lights[ i ] thread maps\_lights::flickerLightIntensity( 0.2, 0.6 ); //default flicker function
	}
}

flicker()
{
	fullIntensity = self getLightIntensity();

	randomIntensity = [ 0.05, 0.1, 0.2, 0.25, 0.3, 0.35, 0.65, 0.8 ];
	randomWait = [ 0.01, 0.015, 0.02, 0.03, 0.05, 0.075, 0.1, 0.125, 0.13, 0.14, 0.145, 0.15 ];

//	duration = gettime() + 2000.0;

	for ( i = 0; i < 20; i++ ) //tagTJ: should replace the time with a variable controlled by the rumble script
	{
		self setLightIntensity( random( randomIntensity ) );
		wait random( randomWait );

		self setLightIntensity( fullIntensity );
		wait random( randomWait );
	}
}


