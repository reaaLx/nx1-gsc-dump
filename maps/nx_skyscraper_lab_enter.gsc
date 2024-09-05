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
// LAB ENTER                                                        *
//                                                                  *
//*******************************************************************

start_lab_enter()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_lab_enter" );
	thread maps\nx_skyscraper_fx::set_vision_and_fog("infiltration", 0); // set appropriate vision and fog	

	thread maps\_utility::set_ambient( "amb_skyscraper_robotics_int" );

	maps\nx_skyscraper_util::spawn_baker();
	baker_teleport = GetEnt ("baker_lab_enter_teleport", "targetname");

	Assert( IsDefined( baker_teleport ));

	level.baker ForceTeleport( baker_teleport.origin, baker_teleport.angles);

	// Player weapons
	maps\nx_skyscraper_util::player_weapon_init( false );
	level._player SwitchToWeapon( "lancer_silencer_xray" );

	issue_color_orders( "r35", "allies" );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

sequence_lab_enter()
{
	// Globals
	level.enemies[ "melee_enemies" ] = [];
	level.enemies[ "search_uavs" ] = [];	

	// Make hallway dangerous
	thread hallway_dangerous();

	trigger_wait_targetname( "entering_lab" );

	thread autosave_now();
	
	thread lab_vision_transition();

	// Setup xray on models
	xray_models();

	// Doors

	left_door_trigger = GetEnt( "trig_dooropen_left", "targetname" );
	right_door_trigger = GetEnt( "trig_dooropen_right", "targetname" );
	Assert( IsDefined( left_door_trigger ));
	Assert( IsDefined( right_door_trigger ));
	left_door_trigger sethintstring( "Press [{+usereload}] to open door" );
	right_door_trigger sethintstring( "Press [{+usereload}] to open door" );
	thread player_dooropen( "model_dooropen_left", "model_dooropen_right", "trig_left_doorway", "trig_dooropen_left", "trig_dooropen_right", "flag_dooropen_left", "melee_2", "melee_1", "trig_melee_kill_1", "flag_melee_kill_2" );	
	thread player_dooropen( "model_dooropen_right", "model_dooropen_left", "trig_right_doorway", "trig_dooropen_right", "trig_dooropen_left", "flag_dooropen_right", "melee_1", "melee_2", "trig_melee_kill_2", "flag_melee_kill_1" );

	// Stealth stuff
	stealth_settings();	

	// UAVs
	level.enemies[ "search_uavs" ][ 0 ] = spawn_uav_searching( "vehicle_miniuav_1", "node_attack_1", "origin_search_1" );
	level.enemies[ "search_uavs" ][ 1 ] = spawn_uav_searching( "vehicle_miniuav_2", "node_attack_1", "origin_search_2" );

	// Turn on spotlights
	level.enemies[ "search_uavs" ] thread uav_spotlight_sequence( "trig_lab_door_left", "trig_lab_door_right" );

	// Set up pathing for UAVs one for left path one for right path
	level.enemies[ "search_uavs" ] thread uav_search_path( "trig_lab_door_left", "origin_search_window_left", "origin_search_door_right", "origin_search_door_right", "model_cock_left" );
	level.enemies[ "search_uavs" ] thread uav_search_path( "trig_lab_door_right", "origin_search_window_right", "origin_search_door_left", "origin_search_door_left", "model_cock_right" );

	level.enemies[ "search_uavs" ][ 1 ] thread uav_hall_scan_remove();

	// Melee Guys for left path and right path
	level.enemies[ "melee_enemies" ][ "melee_1" ] = spawn_melee_enemy( "actor_melee_1", "origin_melee_1", "melee_1", "melee_guy_idle" );
	level.enemies[ "melee_enemies" ][ "melee_2" ] = spawn_melee_enemy( "actor_melee_2", "origin_melee_2", "melee_1", "melee_guy_idle" );

	// Doin business
	level.enemies[ "doinbusiness" ] = spawn_doinbusiness_enemy( "actor_doinbusiness", "origin_doinbusiness", "doinbusiness", "doinbusiness_idle" );

	// Baker
	level.baker thread baker_movement_lab_enter();

	// Events
	thread event_stealth_blown();			
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

player_dooropen( model, other_model, tDoorChooseTrigger, tEnterTrigger, tEnterTrigger_other, flag_to_set, baker_guy, player_guy, melee_trigger, melee_flag )
{
 	level._player endon( "notify_player_through_door" );	

	flashing_door = GetEntArray( model + "_flashing", "script_noteworthy" );
	flashing_door_other = GetEntArray( other_model + "_flashing", "script_noteworthy" );
	door = GetEnt( model, "targetname" );
	trigger_enter = GetEnt( tEnterTrigger, "targetname" );
	trigger_enter_other = GetEnt( tEnterTrigger_other, "targetname" );
	
	baker_door_trigger_left = GetEnt( "trig_left_doorway", "targetname" );
	baker_door_trigger_right = GetEnt( "trig_right_doorway", "targetname" );
	
	Assert( IsDefined( flashing_door ));
	Assert( IsDefined( flashing_door_other ));
	Assert( IsDefined( door ));
	Assert( IsDefined( trigger_enter ));
	Assert( IsDefined( baker_door_trigger_left ));
	Assert( IsDefined( baker_door_trigger_right ));
	Assert( IsDefined( trigger_enter_other ));
	
	trigger_enter trigger_off();

	foreach( thing in flashing_door )
	{
		thing hide();
	}

	level waittill( "notify_dooropen_enable" );
	trigger_enter trigger_on();

	door hide();

	foreach( thing in flashing_door )
	{
		thing show();
	}

	trigger_wait_targetname( tDoorChooseTrigger ); 

	// Turn off "other" door and send baker through
 	foreach( thing in flashing_door_other )
	{
		thing hide();	
	}

	trigger_enter_other trigger_off();

	baker_door_trigger_left trigger_off();
	baker_door_trigger_right trigger_off();
	
	level.baker thread baker_goes_through_door( "origin_" + other_model );
	
	trigger_enter waittill( "trigger" );
	
	door show();

	foreach( thing in flashing_door )
	{
		thing hide();
	}

	iprintln( "[Player moves through door, sees UAV approach through crack in door, closes door]" );	

	warp = undefined;

	if( model == "model_dooropen_left" )
	{
		warp = GetEnt( "origin_lab_enter_baker_warp_left", "targetname" );			
		flag_set( "flag_lab_enter_dooropen_left" );
	}
	else
	{
		warp = GetEnt( "origin_lab_enter_baker_warp_right", "targetname" );
		flag_set( "flag_lab_enter_dooropen_right" );
	}

	objective = GetEnt( "obj_player_" + model, "targetname" );
	Assert( IsDefined( warp ));
	Assert( IsDefined( objective ));
	
	teleport_player( warp );

 	// Add player position goal
	Objective_Position( obj( "obj_lab_enter" ), objective.origin );

	//door.origin = door_pos;

	flag_set( flag_to_set );

	thread event_synced_melee( baker_guy, player_guy, melee_trigger, melee_flag );	

	flag_set( "flag_lab_enter_player_through_door" );

	// This will kill second instance of uav_search_path and player_dooropen
	level._player notify( "notify_player_through_door" );	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

baker_goes_through_door( tOrigin )
{
	origin = GetEnt( tOrigin, "targetname" );
	Assert( IsDefined( origin ));

	origin anim_reach_solo( self, "hunted_open_barndoor" );	
	origin anim_single_solo( self, "hunted_open_barndoor" );	

	color_nodes = GetNodeArray( "node_baker_lab", "script_noteworthy" );
	Assert( IsDefined( color_nodes ));

	if( Distance( color_nodes[0].origin, level.baker.origin ) < Distance( color_nodes[1].origin, level.baker.origin ))
	{
		level.baker SetGoalNode( color_nodes[0] );
	}
	else
	{
		level.baker SetGoalNode( color_nodes[1] );
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

uav_spotlight_sequence( tTriggerLeft, tTriggerRight )
{
	// Initialize real spotlight on uav1 (fake spot on uav2)
	uav_fx = 1;
	PlayFXOnTag( level._effect[ "spotlight_white" ], self[ 0 ], "tag_origin" );
	PlayFXOnTag( level._effect[ "spotlight_dynamic" ], self[ 1 ], "tag_barrel" );

	level._player waittill( "notify_player_through_door" );
	wait 0.05;
	StopFXOnTag( level._effect[ "spotlight_white" ], self[ 0 ], "tag_origin" );
	PlayFXOnTag( level._effect[ "spotlight_dynamic" ], self[ 0 ], "tag_origin" );
	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

lab_vision_transition()
{
	trigger_wait_targetname( "obj_enter_vault" );
	thread maps\nx_skyscraper_fx::set_vision_and_fog("interior", 2); // set appropriate vision and fog
}																		  

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

lab_enter_dialog()
{

}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

baker_movement_lab_enter()
{
	level endon( "notify_synced_melee_complete" );	

	//self.ignoreme = true;
	self.ignoreall = true;
	self enable_cqbwalk();

	// Dialogue - Baker: "<whispers> I've got two tangos on X-Ray blocking the hallway."
	level.baker dialogue_queue( "sky_bak_labent_2tangosxray" );
	//thread add_dialogue_line( "Baker", "<whispers> I've got two tangos on X-Ray blocking the hallway.", "g" );	

	// Dialogue - Baker: "<whispers> Let's split up and take them out at the same time."
	level.baker dialogue_queue( "sky_bak_labent_splitup" );
	//thread add_dialogue_line( "Baker", "<whispers> Let's split up and take them out at the same time.", "g" );
  	
	level notify( "notify_dooropen_enable" );

	wait 2;

	level notify( "notify_send_hallway_uav" );

	if( !flag( "flag_lab_enter_player_through_door" ))
	{
		// Dialogue: Baker - "UAV coming, get out of the hallway!"
		level.baker dialogue_queue( "sky_bak_labent_uavcoming" );
		//thread add_dialogue_line( "Baker", "<whispers> UAV coming, get out of the hallway!", "g" );
	}

	// Wait for player to get through door
	//level._player waittill( "notify_player_through_door" );

	/*
	left_warp = GetEnt( "origin_lab_enter_baker_warp_left", "targetname" );
	right_warp = GetEnt( "origin_lab_enter_baker_warp_right", "targetname" );

	Assert( IsDefined( left_warp ));
	Assert( IsDefined( right_warp ));
	*/

	flag_wait( "flag_lab_enter_player_through_door" );

	// Dialogue: Baker - "Keep behind cover and move close to the ground!"
	//radio_dialogue( "sky_bak_labent_cover" );
	//thread add_dialogue_line( "Baker", "<whispers> Keep behind cover and move close to the ground!", "g" );

	//level waittill( "notify_uav_1_middle_hall" );

	//level._player waittill( "notify_player_through_door" );

	// Dialogue: Baker - "Another UAV.  Stay low."
	level.baker dialogue_queue( "sky_bak_labent_anotheruav" );
	//thread add_dialogue_line( "Baker", "<whispers> Another UAV.  Get down.", "g" );	
	
	thread player_uav_dodge();		

	level waittill( "notify_uav_1_passed" );	

	// Dialogue: Baker - "Ok, you're clear to move."
	level.baker dialogue_queue( "sky_bak_labent_cleartomove" );
	//thread add_dialogue_line( "Baker", "<whispers> Ok, you're clear to move.", "g" );

	self waittill( "goal" );
	flag_wait_any( "flag_melee_kill_1", "flag_melee_kill_2" );			

	// Dialogue: Baker - "Let's take out these guards at the same time.  Do it quietly.  I'll wait for your move."
	// radio_dialogue( "sky_bak_labent_takeoutguards" );
	// thread add_dialogue_line( "Baker", "<whispers> Let's take out these guards at the same time.  Do it quietly.  I'll wait for your move.", "g" );		

	baker_countdown();	

	level notify( "notify_baker_melee" );
	
	level waittill( "notify_synced_melee_complete" );	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

baker_countdown()
{
	level endon( "notify_stealth_off" );
	level endon( "notify_player_melee_complete" );

	// Dialogue - Baker: 
	//radio_dialogue( "sky_bak_labent_takeoutguards" );

	flag_set( "flag_baker_melee_in_progress" );

	level.baker dialogue_queue( "sky_bak_labent_takeoutguards" );
	//thread add_dialogue_line( "Baker", "<whispers> Let's take out these guards at the same time.  Do it quietly.", "g" );	
	level.baker dialogue_queue( "sky_bak_labent_mark321" );
	//thread add_dialogue_line( "Baker", "<whispers> On my mark.", "g" );		
	/*
	wait 1;
	thread add_dialogue_line( "Baker", "<whispers> 3...", "g" );		
	wait 1;
	thread add_dialogue_line( "Baker", "<whispers> 2...", "g" );		
	wait 1;
	thread add_dialogue_line( "Baker", "<whispers> 1...", "g" );		
	wait 1;
	thread add_dialogue_line( "Baker", "<whispers> Mark", "g" );
	*/
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

// Checks if anyone is alive in an array
isalive_array( entities )
{
	something_lives = 0;

	foreach( thing in entities )
	{
		if( isalive( thing ))
		{
			something_lives++;
		}
	}

	return something_lives;
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

xray_models()
{
	models = GetEntArray( "model_xray", "script_noteworthy" );
	foreach( model in models )
	{
		model SetIsVisibleInXray( true );   
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

uav_search_path( tDoorwayTrigger, tOrigin1_1, tOrigin1_2, tOrigin2, tScience )
{	
	level._player endon( "notify_player_through_door" );
	level endon( "notify_stealth_off" );

	// individual UAV search paths
	self[ 0 ] thread uav_search_path_solo_room_scan( tDoorwayTrigger, tOrigin1_1, tOrigin1_2, tScience ); 
	self[ 1 ] thread uav_search_path_solo_hall_scan( tOrigin2 );		
}



//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

hallway_dangerous()
{
	trig_flag_stealth_off = GetEntArray( "flag_door_kill_stealth", "script_noteworthy" );

	Assert( IsDefined( trig_flag_stealth_off ));

	foreach( flag in trig_flag_stealth_off ) 
	{
		flag trigger_off();
	}

	level._player waittill( "notify_player_through_door" );

	thread low_cover_on( 128, false );
	thread watcher_cover_off();

	wait 2;

	// Make hallway dangerous
	foreach( flag in trig_flag_stealth_off ) 
	{
		flag trigger_on();
	}

	level waittill( "notify_synced_melee_complete" );

	// Make it safe again
	foreach( flag in trig_flag_stealth_off ) 
	{
		flag trigger_off();
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

// UAV #1's path (second UAV seen)
uav_search_path_solo_room_scan( tDoorwayTrigger, tOrigin1, tOrigin2, tScience )
{
	self endon( "death" );
	level endon( "notify_stealth_off" );

	uav1_origin = GetEnt( "origin_search_1", "targetname" );
	uav1_goal1 = GetEnt( tOrigin1, "targetname" );
	uav1_goal2 = GetEnt( tOrigin2, "targetname" ); 
	science_experiment = GetEnt( tScience, "targetname" );
	end_node = GetEnt( "origin_search_end", "targetname" );
	
	Assert( IsDefined( uav1_origin ));
	Assert( IsDefined( uav1_goal1 ));
	Assert( IsDefined( uav1_goal2 ));	
	Assert( IsDefined( science_experiment ));
	Assert( IsDefined( end_node ));

	self Vehicle_SetSpeed( 5, 5, 1 );
	//self SetLookAtEnt( science_experiment );	

	// Player enters lab doorway
	trigger_wait_targetname( tDoorwayTrigger );
	level notify( "notify_uav_1_approaching" );	
	
	self thread uav_look( tDoorwayTrigger );

	wait 1;

	// Fly to middle, look at experiment	
	self SetVehGoalPos( uav1_goal1.origin );

	self waittill( "goal" );	
	level notify( "notify_uav_1_middle_hall" );	
	
	// Send UAV 1 to end of hallway
	self SetVehGoalPos( uav1_goal2.origin );		   		

	self waittill( "goal" );
	self notify( "notify_end_uav_look" );

	self SetVehGoalPos( end_node.origin );

	self waittill( "goal" );
	self delete();
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

player_uav_dodge()
{
	display_hint_timeout( "hint_prone_for_cover", 4 );

	// Wait for UAV to pass player
	while( 1 )
	{
		if( level.uav_lookat_origin.origin[ 1 ] <  level._player.origin[ 1 ] )
			break;
		wait 0.05;
	}

	// For baker to speak
	level notify( "notify_uav_1_passed" );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

hint_prone_for_cover()
{
	return false;
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

uav_look( tDoorwayTrigger )
{
	self endon( "notify_end_uav_look" );
	self endon( "death" );

	last_pos = undefined;
										
	level.uav_lookat_origin = spawn_tag_origin();

	right = GetEnt( "origin_search_window_right", "targetname" );
	left = GetEnt( "origin_search_window_left", "targetname" );

	Assert( IsDefined( right ));
	Assert( IsDefined( left ));

	while( 1 )
	{
		if( isdefined( last_pos ))
		{
			if( tDoorwayTrigger == "trig_lab_door_right" )
			{
				look_vector = AnglestoForward( right.angles);
			}
			else
			{
				look_vector = AnglestoForward( left.angles);
			}

			level.uav_lookat_origin.origin = self GroundPos( self.origin ) + vector_multiply( look_vector, 256 );	
			self SetLookAtEnt( level.uav_lookat_origin );
		}

		last_pos = self.origin;

		wait 0.05;
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

// UAV #2's path (first UAV seen)
uav_search_path_solo_hall_scan( tOrigin1 )
{
	self endon( "notify_hall_uav_warp" );
	self endon( "death" );
	level endon( "notify_stealth_off" );

	uav2_goal = GetEnt( tOrigin1, "targetname" );
	hallway_center = GetEnt( "origin_search_center", "targetname" );	
	end_node = GetEnt( "origin_search_end", "targetname" );

	Assert( IsDefined( uav2_goal ));
	Assert( IsDefined( hallway_center ));	
	Assert( IsDefined( end_node ));

	level waittill( "notify_send_hallway_uav" );

	self Vehicle_SetSpeed( 5, 5, 1 );	

	// UAV approaches player in hallway	
	self SetVehGoalPos( hallway_center.origin );
	self SetLookAtEnt( hallway_center );
	
	self waittill( "goal" );

	// UAV 2 goes to door positions
	self SetVehGoalPos( uav2_goal.origin );
	self SetLookAtEnt( uav2_goal );

	self waittill( "goal" );
	self ClearLookAtEnt();

	self SetVehGoalPos( end_node.origin );

	self waittill( "goal" );
	self delete();
}

uav_hall_scan_remove()
{
	self endon( "death" );
	level endon( "notify_stealth_off" );

	level._player waittill( "notify_player_through_door" );		
	self delete(); 	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

spawn_uav_searching( tSpawner, tAttack, tSearch )
{
	uav_spawner = GetEnt( tSpawner, "targetname" );
	Assert( IsDefined( uav_spawner ));

	uav = uav_spawner maps\_attack_heli::SAV_setup( "searching", tAttack, tSearch, 400, maps\_stealth_utility::miniuav_stealth_default );	

	uav thread spawn_uav_searching_player_spotted();
	uav thread spawn_uav_searching_aggressive_mode();
	uav thread spawn_uav_searching_damage();
	uav.goalradius = 8;

	return uav;
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

spawn_uav_searching_damage()
{
	self endon( "death" );

	self waittill( "damage" );
	flag_set( "flag_stealth_off" );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

spawn_uav_searching_player_spotted()
{
	self endon( "death" );

	self waittill( "player_spotted" );
	flag_set( "flag_stealth_off" );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

event_stealth_blown()
{
	level endon( "macguffin_obtained" );	

	//thread event_stealth_blown_player_shoots();	

	while( !flag( "flag_stealth_off" ))
	{
		wait 0.05;
	}

	// Make sure stealth flag is off so ents attack
	flag_set( "flag_stealth_off" );	
	level notify( "notify_stealth_off" );	

	SetDvar( "ui_deadquote", "You broke stealth (placeholder)" );
	maps\_utility::missionFailedWrapper();

	/*
	foreach( uav in level.enemies[ "search_uavs" ] )
	{
		if( isalive( uav ))
		{
			StopFXonTag( level._effect[ "spotlight_white" ], uav, "tag_origin");
			uav thread maps\_attack_heli::heli_spotlight_off();
	
			PlayFXOnTag( level._effect[ "spotlight_red" ], uav, "tag_origin" );

			uav ClearLookAtEnt();
			level.enemies[ "lab_enter_reinforcements" ] = add_to_array( level.enemies[ "lab_enter_reinforcements" ], uav );
		}
	}

	foreach( guy in level.enemies[ "melee_enemies" ] )
	{
		if( isalive( guy ))
		{
			level.enemies[ "lab_enter_reinforcements" ] = add_to_array( level.enemies[ "lab_enter_reinforcements" ], guy );
		}
	}

	people_reinforcements_spawner = GetEntArray( "actor_melee_reinforcements", "script_noteworthy" );
	uav_reinforcements_spawner = GetEntArray( "vehicle_melee_reinforcements", "script_noteworthy" );
	Assert( IsDefined( people_reinforcements_spawner ));
	Assert( IsDefined( uav_reinforcements_spawner ));

	thread add_dialogue_line( "Baker", "Shit!  We've been spotted!", "g" );	

	level.baker.ignoreall = false;
	level.baker.ignoreme = false;

	level.enemies[ "lab_enter_reinforcements" ] = [];

	foreach( spawner in people_reinforcements_spawner )
	{
		guy = spawner spawn_ai();
		level.enemies[ "lab_enter_reinforcements" ] = add_to_array( level.enemies[ "lab_enter_reinforcements" ], guy );
	}

	foreach( spawner in uav_reinforcements_spawner )
	{
		uav = spawner maps\_attack_heli::SAV_setup( "circling", "node_attack_1" );
		PlayFXOnTag( level._effect[ "spotlight_red" ], uav, "tag_origin" );
		level.enemies[ "lab_enter_reinforcements" ] = add_to_array( level.enemies[ "lab_enter_reinforcements" ], uav );
	}
	  
	while( level.enemies[ "lab_enter_reinforcements" ].size > 0 )
	{
		level.enemies[ "lab_enter_reinforcements" ] = remove_dead_from_array( level.enemies[ "lab_enter_reinforcements" ] );
		wait 0.05;
	}
	level notify( "notify_synced_melee_complete" );
	*/

}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

// Turn off cover
watcher_cover_off()
{
	level waittill_any( "notify_stealth_off", "notify_synced_melee_complete" );
	low_cover_off();
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

event_stealth_blown_player_shoots()
{
	level endon( "notify_synced_melee_complete" );
	level endon( "notify_stealth_off" );

	while( !level._player ButtonPressed( "BUTTON_RTRIG" ))
	{
		wait 0.05;
	} 

	flag_set( "flag_stealth_off" );

}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

event_synced_melee( baker_guy_name, player_guy_name, tTrigger, melee_flag )
{
	level endon( "notify_stealth_off" );
	level endon( "notify_synced_melee_complete" );

	trigger = GetEnt( tTrigger, "targetname" );   

	Assert( IsDefined( trigger ));

	trigger sethintstring( "Press [{+melee}] to perform melee kill (PLACEHOLDER)" );

	trigger trigger_off();

	flag_wait( "flag_baker_melee_in_progress" );

	trigger trigger_on();

	// Setup baker to attack the other guy
	level.baker thread event_synced_melee_solo_baker( baker_guy_name, level.enemies[ "melee_enemies" ][ baker_guy_name ], level.enemies[ "melee_enemies" ][ player_guy_name ], "target", "baker", "melee_kill" );	
	
	// Player melees
	level._player event_synced_melee_solo_player( player_guy_name, melee_flag );	
	
	trigger trigger_off();
	
	// Get Rid of UAVs
	foreach( uav in level.enemies[ "search_uavs" ] )
	{
		if( isalive( uav ))
		{
			uav delete();
		}
	}	

	level.enemies[ "melee_enemies" ] = remove_dead_from_array( level.enemies[ "melee_enemies" ] );
	waittill_dead( level.enemies[ "melee_enemies" ] ); 
	
	// <BM Note: This will end this function (since there are two threaded), so don't put anything after it!>
	level notify( "notify_synced_melee_complete" );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

event_synced_melee_solo_player( player_guy_name, melee_flag )
{
	level endon( "notify_player_melee_complete" );

	// Wait for player to melee guy
	while( 1 )
	{		
		if( self MeleeButtonPressed() && flag( melee_flag ))
			break;		 

		wait 0.05;
	}

	origin = GetEnt( "origin_" + player_guy_name, "targetname" );
	Assert( IsDefined( origin ));

	// Player kills guard (temp until we get actual anims
	origin notify( "stop_loop" );
	level.enemies[ "melee_enemies" ][ player_guy_name ] anim_stopanimscripted();
	level.enemies[ "melee_enemies" ][ player_guy_name ] kill();

	level notify( "notify_player_melee_complete" );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

// Melee kill anim event
event_synced_melee_solo_baker( guy_name, guy, player_guy, guy_animname, baker_animname, scene )
{
	level endon( "notify_stealth_off" );

	level waittill_any( "notify_player_melee_complete" , "notify_baker_melee" );

	if( IsAlive( guy ))
	{
		origin = GetEnt( "origin_" + guy_name, "targetname" );
		// self.animname = baker_animname;
		guy.animname = guy_animname;
		guys = [ self, guy ];
		
		origin notify( "stop_loop" );
		guy StopAnimScripted();
	
		guy_array[ 0 ] = guy;
		
		//origin thread anim_single( guy_array, "melee_react" );	
	
		//wait 1;

		level notify( "notify_baker_melee_in_progress" );		
	
		origin thread anim_single( guys, scene );
	
		wait 0.05;
		guy.a.nodeath = true;
		guy.allowdeath = true;
		guy.diequietly = true;
		guy kill();
	}
	else if( IsAlive( player_guy ))
	{
		self.ignoreall = false;
		self.favoriteenemy = player_guy;
		self.baseaccuracy = 1000;
		guys[0] = player_guy;
		waittill_dead( guys );
		self.baseaccuracy = 1; 
		self.ignoreall = true;
	} 	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

spawn_uav_searching_aggressive_mode()
{
	self endon( "death" );

	flag_wait( "flag_stealth_off" );
	self maps\_nx_miniuav::miniuav_player_spotted();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_melee_enemy( tSpawn, tOrigin, animname1, anim1 )
{
	spawner = GetEnt( tSpawn, "targetname" );
	origin = GetEnt( tOrigin, "targetname" );
	spawner add_spawn_function( ::spawnfunc_melee_enemy, origin );

	Assert( IsDefined( spawner ));
	Assert( IsDefined( origin ));	

	enemy = spawner spawn_ai();

	Assert( IsDefined( enemy ));

	enemy.animname = animname1;
	origin thread anim_loop_solo( enemy, anim1 );

	return enemy;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_doinbusiness_enemy( tSpawn, tOrigin, animname1, anim1 )
{
	spawner = GetEnt( tSpawn, "targetname" );
	origin = GetEnt( tOrigin, "targetname" );
	spawner add_spawn_function( ::spawnfunc_melee_enemy, origin );

	Assert( IsDefined( spawner ));
	Assert( IsDefined( origin ));	

	enemy = spawner spawn_ai();

	Assert( IsDefined( enemy ));

	enemy.animname = animname1;
	origin thread anim_loop_solo( enemy, anim1 );

	return enemy;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawnfunc_melee_enemy( origin )
{
	self endon( "death" );

	self.ignoreall = true;
	self thread spawnfunc_melee_enemy_end_loop_flag( origin );
	self thread spawnfunc_melee_enemy_damage( origin );
	
	self.aggressivemode = 1;

	level waittill( "notify_baker_melee_in_progress" );

	wait 3;

	level.enemies[ "melee_enemies" ] = remove_dead_from_array( level.enemies[ "melee_enemies" ] );

	if( level.enemies[ "melee_enemies" ].size > 0 )
		flag_set( "flag_stealth_off" ); 	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawnfunc_melee_enemy_damage( origin )
{
	level endon( "notify_synced_melee_complete" );

	while( 1 )
	{
		self waittill( "damage", dmg, attacker );
		if( attacker == level._player ) 
		{
			// If during dual melee, kill guy, if not, break stealth
			if( flag( "flag_baker_melee_in_progress" ))
			{
				origin notify( "stop_loop" );
				self anim_stopanimscripted();
				self.ignoreall = false;
				self kill();

				level notify( "notify_player_melee_complete" );
				break;
			}
			else
			{
				flag_set( "flag_stealth_off" );
			}
		}
		else
		{
			// Baker kills
			origin notify( "stop_loop" );
			self anim_stopanimscripted();
			self.ignoreall = false;
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawnfunc_melee_enemy_end_loop_flag( origin )
{
	self endon( "death" );

	flag_wait( "flag_stealth_off" ); 	
	origin notify( "stop_loop" );
	self anim_stopanimscripted();
	self.ignoreall = false;
}
