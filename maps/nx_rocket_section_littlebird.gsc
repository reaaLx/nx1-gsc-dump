
//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_ROCKET_SECTION_LITTLEBIRD									**
//                                                                          **
//    Created: 7/13/2011 - Justin Rote										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


//*******************************************************************
//																	*
// LITTLEBIRD - Littlebird ride from the rescue to the gantry		*
//																	*
//*******************************************************************
start()
{
	maps\nx_rocket_util::post_turret_event();

	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_littlebird_ride" );

	flag_set( "littlebird_from_start" );
}

main()
{
	thread maps\_utility::set_ambient( "nx_rocket_ext" );

	if( !IsDefined( level.rescue_heli ) )
		level.rescue_heli = maps\nx_rocket_util::rescue_chopper_setup( "littlebird_rescue_heli", "targetname" );

//  // Spawn the riders
//  rider_guys = [];
//  rider_guys[ "ALLY_WILLIAMS" ]	= level.squad[ "ALLY_WILLIAMS" ];
//  rider_guys[ "ALLY_JENKINS" ]	= level.squad[ "ALLY_JENKINS" ];
//
//  rider_guys[ "ALLY_WILLIAMS" ].script_startingposition = 3;
//  rider_guys[ "ALLY_JENKINS" ].script_startingposition = 6;

//  littlebird_riders = getentarray( "littlebird_riders", "targetname" );
//  foreach( spawner in littlebird_riders )
//  {
//  	guy = spawner stalingradSpawn();
//  	rider_guys[ rider_guys.size ] = guy;
//  }

	//iprintln( "spawning littlebird" );

	// Special littlebird for jump to start
//  if( flag( "littlebird_from_start" ))
//  {
//  	littlebird = spawn_vehicle_from_targetname_and_drive( "littlebird_from_start" );
//
//  	teleport_info = [];
//  	teleport_info[ "ALLY_JENKINS" ]		= "littlebird_start_jenkins";
//  	teleport_info[ "ALLY_WILLIAMS" ]	= "littlebird_start_williams";
//  	maps\nx_rocket_util::squad_teleport( teleport_info );
//  }
//  // Get the intro littlebird
//  else
//  {
//  	littlebird = spawn_vehicle_from_targetname_and_drive( "littlebird" );
//  }
//
//  level.playerHeli = littlebird;
//

	littlebird = level.rescue_heli;
	level.playerHeli = level.rescue_heli;

	// Dialogue thread
	thread littlebird_ride_dialogue( littlebird );

//    load_setup = getstruct( "load_setup", "targetname" );
//    return_path = getstruct( "return_path", "targetname" );
//    littlebird thread load_loop( rider_guys );
//
//    // Wait for player to get close to the chopper
//    //trigger_wait("littlebird_hop_in_trigger", "targetname");
//    trigger_wait("stage_chopper_ride_start", "targetname");
////
//  littlebird thread ride_little_chopper();
//
	// Heli takes off
	player_cant_be_shot();

	littlebird thread vehicle_liftoff();
	wait .1;

	littlebird.currentnode = GetStruct( "escape_path_start", "targetname" );
	littlebird vehicle_resumepath();
//

	// Hide the final gantry animated swing arm
	swing_arm_bits = GetEntArray( "final_gantry_arm_extended", "targetname" );
	foreach( bit in swing_arm_bits )
	{
		bit hide();
	}


	// DEBUG
	//tele_node = GetStruct( "littlebird_skip_node", "script_noteworthy" );
	//level.playerHeli vehicle_teleport( tele_node.origin, tele_node.angles );

	//level.playerHeli maps\nx_rocket_util::transition_chopper_to_new_path_noteworthy( "littlebird_resume_node" );
	//level.playerHeli vehicle_SetSpeedImmediate( 120, 15, 15 );
	// DEBUG


	//==========================
	// Entering base omega - Spawn some ground enemies
	//==========================
	flag_wait( "flag_entered_base_omega" );

	// Add an attractor to the chopper
	level.playerHeli.attractor = missile_createAttractorEnt( level.playerHeli, 25000, 25000 );

	// Spawn ground troops
	array_spawn_function_targetname( "base_omega_guys_1", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.base_omega_guys_1 = maps\nx_rocket_util::spawn_guys_from_targetname( "base_omega_guys_1" );

	//Spawn final rocket sfx
	level.final_rocket_sfx = Spawn( "sound_emitter", ( 89692, 60373, 1037 ) );
	level.final_rocket_sfx playloopsound( "rocket_launch_final" );

	// These waits are here to spread out the load across a few frames when entering this area
	wait 0.1;

	array_spawn_function_targetname( "base_omega_guys_2", maps\nx_rocket_util::protect_player_helicopter_rear );
	level.base_omega_guys_2 = maps\nx_rocket_util::spawn_guys_from_targetname( "base_omega_guys_2" );

	wait 0.1;

	// Spawn stationary ground vehicles
	level.base_omega_vehicles_static = spawn_vehicles_from_targetname( "base_omega_vehicles_static" );

	wait 0.1;

	// Spawn pathing ground vehicles
	level.base_omega_vehicles_pathing = spawn_vehicles_from_targetname_and_drive( "omega_path_vehicles" );
	maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( level.base_omega_vehicles_pathing );


	//==========================
	// Wait for the littlebird to reach the gantry
	//==========================
	littlebird waittill( "littlebird_at_gantry" );

	// Cleanup all the stuff we just flew over
	thread cleanup_base_omega_flyover();
	wait 0.1;

	// Spawn some enemies on the gantry for when you fly by
	//array_spawn_function_targetname( "base_omega_gantry_ride_guys", maps\nx_rocket_util::protect_player_helicopter_rear );
	//level.base_omega_gantry_ride_guys = maps\nx_rocket_util::spawn_guys_from_targetname( "base_omega_gantry_ride_guys" );

	// Cleanup the gantry fodder guys
	//littlebird waittill( "littlebird_start_jump_vo" );
	//maps\nx_rocket_util::safe_delete_array( level.base_omega_gantry_ride_guys );


	//==========================
	// Wait for end of path
	//==========================
	littlebird waittill( "littlebird_dropoff_point" );

	// Drop the player off
	// JR - This will be a vignette eventually
	player_exits_little_chopper();

	// Delete the littlebird after its done flying its path
	littlebird thread kill_littlebird_after_path();

	// Clean up the missile magnet
	missile_DeleteAttractor( level.playerHeli.attractor );
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
	flag_init( "baker_updates_final_rocket" );
	flag_init( "littlebird_from_start" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
rescue_heli_setup()
{

}

ride_little_chopper()
{
	level._player.IgnoreRandomBulletDamage = true;
	player_cant_be_shot();
	gopath( self );
	self SetMaxPitchRoll( 10, 10 );

   	level._player AllowProne( false );
   	level._player AllowCrouch( false );
   	level._player AllowSprint( false );
   	level._player AllowJump( false );

	self thread godon();

	player_view_controller = get_player_view_controller( self, "tag_guy2", ( 0, 0, -8 ) );

	tag_origin = spawn_tag_origin();
	tag_origin LinkTo( self, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	level.ground_ref = tag_origin;

	level._player PlayerSetGroundReferenceEnt( tag_origin );

	level.player_view_controller = player_view_controller;

	wait( 0.1 );

	level._player PlayerLinkToDelta( player_view_controller, "TAG_origin", 1, -10, 170, 20, 45, true );
}

// Riders wait for each other to get on
load_guys( side, guy_1, guy_2 )
{
	thread vehicle_load_ai_single( guy_1, undefined, side );
	//waittill he's just starting to play out his animation before sending the other guys to get in the way.
	guy_1 waittill( "boarding_vehicle" );
	// send the third guy off to jump in
	thread vehicle_load_ai_single( guy_2, undefined, side );
	guy_2 waittill( "boarding_vehicle" );
	ent_flag_set( "guy2_in_" + side );
}

load_loop( guys )
{
	self waittill( "reached_dynamic_path_end" );
	self vehicle_detachfrompath();
	self vehicle_land();

	wait 2;

	//iprintln( "load ai" );
	self vehicle_load_ai( guys );
}

// Boots the player out of the chopper
player_exits_little_chopper()
{
	level._player PlayerSetGroundReferenceEnt( undefined );
	level._player unlink();

	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_gantry_attack" );

	level._player AllowProne( true );
   	level._player AllowCrouch( true );
   	level._player AllowSprint( true );
   	level._player AllowJump( true );
}

//******************************************************************************************
//******************************************************************************************

// Spawns a group of enemies
spawn_gantry_guys( group_name )
{
	//iprintln( "spawn_gantry_guys" );
	guys = getentarray( group_name, "targetname" );
	foreach ( guy in guys )
	{
		new_guy = guy stalingradSpawn();
		if ( spawn_failed( new_guy ) )
		{
			iprintlnbold( "spawn failed" );
			continue;
		}
	}
}


//******************************************************************************************
//******************************************************************************************

// Cleanup the base omega ground fodder
cleanup_base_omega_flyover()
{
	maps\nx_rocket_util::safe_delete_array( level.base_omega_guys_1 );
	maps\nx_rocket_util::safe_delete_array( level.base_omega_guys_2 );

	// Not deleting these because they are visible from the gantry
	//maps\nx_rocket_util::safe_delete_array( level.base_omega_vehicles_static );
}


// Dialogue for this section
littlebird_ride_dialogue( littlebird )
{
//  trigger_wait("stage_chopper_ride_start", "targetname");

	// Baker: "Everyone in?  Lets roll"
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.6, "roc_bak_lbird_letsroll" );

	// Williams: "Damnit Baker am I glad to see you!"
	maps\nx_rocket_util::wait_play_dialogue_wait( 1, "roc_wil_lbird_gladtoseebaker" );

	// Jenkins: "We thought we lost you back there, and where did you get this heap of EC crap?"
	//maps\nx_rocket_util::wait_play_dialogue_wait( 0.8, "roc_jen_lbird_thoughtwelostyou" );

	// Baker: "No time for stories now boys, we gotta get moving."
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.4, "roc_bak_lbird_notimeforstories" );

	// Jenkins: "Damn right. Mission accomplished, let's get the hell outa here."
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.2, "roc_jen_lbird_missionaccomplished" );

	// Baker: "Not so fast, Objective site Omega is undamaged and ready for launch."
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.5, "roc_bak_lbird_omegaundmgd" );

	// Williams: "Isnt that Deadeye 2-8s objective?"
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.35, "roc_wil_lbrid_deadeyesobjective" );

	// Baker: "Deadeye 2-8 is MIA, were taking over for them."
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.3, "roc_bak_lbird_deadeyemia" );

	//littlebird waittill( "littlebird_start_jump_vo" );
	littlebird waittill( "littlebird_at_gantry" );
	// Baker: "Jenkins take the controls."
	//maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_bak_lbird_jenkinscontrols" );

	// Baker: "Lockwood, your with me.  We'll jump down and plant the charges"
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.2, "roc_bak_lbird_lockwoodwithme" );

	// Baker: "Williams, cover us from the chopper."
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.2, "roc_bak_lbird_coverusfromchopper" );
}


kill_littlebird_after_path()
{
	self waittill( "reached_dynamic_path_end" );
	
	foreach( rider in self.riders )
	{
		rider Unlink();
		self guy_exit_vehicle( rider );
//  	rider Unlink();
//  	rider StopAnimScripted();
//  	rider stop_magic_bullet_shield();
	}

//  teleport_info[ "ALLY_BAKER" ]		= "start_default_ally_00";
	teleport_info[ "ALLY_JENKINS" ]		= "start_default_ally_01";
	teleport_info[ "ALLY_WILLIAMS" ]	= "start_default_ally_02";
	maps\nx_rocket_util::squad_teleport( teleport_info );
//  self delete();
	self Hide();
}


