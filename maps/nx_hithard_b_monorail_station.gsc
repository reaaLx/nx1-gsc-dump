
//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  nx_hithard_b_monorail_station.gsc					   		**
//				NOTE: called from nx_hithard_b.gsc							**
//                                                                          **
//    Created: 4/4/2011 - TJ Stamm											**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\nx_hithard_b_util;
//#include maps\_hud_util;


//***********************************************************************
//																		*
//		INITIALIZATION: The following are called from nx_hithard_b.gsc	*
//                                                                  	*
//***********************************************************************

// Objective specific flag_init() calls
flag_inits()
{
	flag_init( "monorail_wave_1_clear" );

	flag_init( "monorail_wave_2_spawned" );
	flag_init( "monorail_wave_2_clear" );
}

// Objective specific add_hint_string() calls
hint_string_inits()
{	
	//add_hint_string( "hint_parachute_smoke", &"NX_HITHARD_PARACHUTE_HINT_SMOKE", ::hint_parachute_smoke );	
}

//*******************************************************************
//           Monorail Station Encounter                   			*
//                                                                  *
//*******************************************************************

monorail_station_main()
{
	// Create the station entrance doors
	//left_door = monorail_make_sliding_door( "monorail_auto_door_left" );
	//right_door = monorail_make_sliding_door( "monorail_auto_door_right" );

	//left_door thread monorail_automatic_door();
	//right_door thread monorail_automatic_door();

	// JR - I hooked this up to do a looping open/close anim
	// as if the door was jammed, but it just doesnt look cool. Disabled.
	//left_door thread monorail_door_stuck_loop( 18.75, -18.75, 19, -0.25 );
	//right_door thread monorail_door_stuck_loop( -18.75, 18.75, -19, 0.25 );


	flag_set( "plaza_enc_complete" );

	objective_number = 23;
	obj_position = GetEnt( "on_ramp_lapse", "targetname" );
	Objective_Add( objective_number, "current", "Clear the monorail station." );
	Objective_Position( objective_number, GetStruct( "on_ramp_lapse", "targetname" ).origin );
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
	// Kick off dialogue
	level thread monorail_dialogue();
	level thread threat_id_logic();
	level thread vp_movement();

	// Handles extra logic for taking the upstairs route
	//level thread monorail_upstairs_logic();

	// Makes sure the player doesnt cheese by running ahead
	level thread monorail_sprint_watcher();

	level thread monorail_trigger_logic();

	// Change baker and duke to CQB
	//level.squad[0] enable_cqbwalk();
	//level.squad[1] enable_cqbwalk();

	// Spawn the behavior script on the 1st wave
	monorail_wave_1 = GetEntArray( "monorail_wave_1_guys", "script_noteworthy" );
	array_spawn_function( monorail_wave_1, ::monorail_wave_1_logic );

	// Spawn the behavior script on the 2nd wave
	monorail_wave_2 = GetEntArray( "monorail_wave_2_guys", "script_noteworthy" );
	array_spawn_function( monorail_wave_2, ::monorail_wave_2_logic );

	flag_wait( "magicgrenade_monorail_start" );

	// Triggers events when groups of enemies die
	thread monorail_enemy_wave_watcher();

	//MagicGrenade( "smoke_grenade_american", GetStruct( "teargas_monorail_start_01_origin", "targetname" ).origin, GetStruct( "teargas_monorail_start_01_target", "targetname" ).origin, 1.0 );
	//MagicGrenade( "smoke_grenade_american", GetStruct( "teargas_monorail_start_02_origin", "targetname" ).origin, GetStruct( "teargas_monorail_start_02_target", "targetname" ).origin, 4.0 );

	thread magic_pain_grenade( "smoke_grenade_american", GetStruct( "teargas_monorail_start_01_origin", "targetname" ).origin, GetStruct( "teargas_monorail_start_01_target", "targetname" ).origin, 0.0 );
	thread magic_pain_grenade( "smoke_grenade_american", GetStruct( "teargas_monorail_start_02_origin", "targetname" ).origin, GetStruct( "teargas_monorail_start_02_target", "targetname" ).origin, 3.0 );
	thread magic_pain_grenade( "smoke_grenade_american", GetStruct( "teargas_monorail_start_03_origin", "targetname" ).origin, GetStruct( "teargas_monorail_start_03_target", "targetname" ).origin, 0.0 );
	thread magic_pain_grenade( "smoke_grenade_american", GetStruct( "teargas_monorail_start_04_origin", "targetname" ).origin, GetStruct( "teargas_monorail_start_04_target", "targetname" ).origin, 3.0 );
	//thread magic_pain_grenade( "smoke_grenade_american", GetStruct( "teargas_monorail_start_05_origin", "targetname" ).origin, GetStruct( "teargas_monorail_start_05_target", "targetname" ).origin, 0.0 );

	flag_wait( "monorail_station_enc_complete" );

	// Turn off CQB walk
	//level.squad[0] disable_cqbwalk();
	//level.squad[1] disable_cqbwalk();

	// Cleanup any remaining enemies
	monorail_enemy_cleanup();

	post_monorail_regroup();
}


// Watching for the waves to be cleared
monorail_enemy_wave_watcher()
{
	// This will check num enemies alive
	// and trigger wave 2 early, so the waves overlap
	while( !flag( "monorail_wave_1_clear" ) && !flag( "monorail_spawn_wave_2" ) )
	{
		num_alive = get_ai_group_sentient_count( "monorail_station_enemies" );
		if( num_alive < 3 )
		{
			flag_set( "monorail_wave_1_clear" );

			// Remaining wave 1 guys should fall back
			alive_guys = get_ai_group_ai( "monorail_station_enemies" );
			foreach( guy in alive_guys )
			{
				retreat_vol = GetEnt( "monorail_retreat_volume", "targetname" );
				if( isDefined( retreat_vol ))
				{
					guy SetGoalVolumeAuto( retreat_vol );
				}
				else
				{
					AssertMsg( "Script monorail_enemy_wave_watcher couldn't find monorail_retreat_volume" );
				}
			}

			break;
		}
		wait( 0.25 );
	}

	// Move allies up
	if( !flag( "monorail_spawn_wave_2" ))
	{
		wait( RandomFloatRange( 1.5, 2.5 ));

		issue_color_orders( "b144", "allies" );

		// "Clear forward!"
		wait_play_dialogue_wait( 0.0, "hithard_gyp_move_06" );
	}

	// Short delay for the player to move up
	wait( RandomFloatRange( 1.5, 2.5 ));

	// Spawn second wave of enemies
	monorail_wave_2 = GetEntArray( "monorail_wave_2_guys", "script_noteworthy" );
    array_thread( monorail_wave_2, ::spawn_ai );
	flag_set( "monorail_wave_2_spawned" );

	// More smoke for the second wave
	//thread magic_pain_grenade( "smoke_grenade_american", GetStruct( "teargas_monorail_start_02_origin", "targetname" ).origin, GetStruct( "teargas_monorail_start_02_target", "targetname" ).origin, 4.0 );

	flag_wait( "monorail_wave_2_clear" );

	// Cleared the whole room
	flag_set( "monorail_station_enc_complete" );
}


// AI behavior for wave 1
monorail_wave_1_logic()
{
	self endon( "death" );

	if ( !isalive( self ) )
		return;

	self.aggressivemode = true;
}

// AI behavior for wave 2
monorail_wave_2_logic()
{
	self endon( "death" );

	if ( !isalive( self ) )
		return;

	self ai_actorseek( level._player ); //level.squad[2] );
	self.aggressivemode = true;
}

// Makes the AI chase down a specific actor
ai_actorseek( actor )
{
	self endon( "death" );

	if ( isdefined( self.target ) )
		self waittill( "goal" );

	self setgoalentity( actor );
	self.goalradius = 2000;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

monorail_dialogue()
{
	self endon( "monorail_station_enc_complete" );

	flag_wait( "monorail_station_start" );

	// Captain Baker: "We're on point, stay on our 6"
	wait_play_dialogue_wait( 0.5, "hithard_bak_plaza2_08" );

	// Secret Service Leader: "Right behind you"
	wait_play_dialogue_wait( 0.0, "hithard_sslead_plaza2_01" );


	// DT# 4507 - These VO lines need to be triggered when the enemies appear
	// not when this trigger is hit
	flag_wait( "magicgrenade_monorail_start" );
	wait( 2.0 );

	// Duke: "Fuck me - tangos in the open!"
	wait_play_dialogue_wait( 0.0, "hithard_gyp_mono_02" );

	// Baker: "They're popping smoke. Use threat ID"
	wait_play_dialogue_wait( 1.5, "hithard_bak_mono_01", 1.0 );

	level notify( "turned_on_threatID" );

	// Baker: "Specter, get the angle on them!"
	wait_play_dialogue_wait( 9.0, "hithard_bak_mono_02" );


	// Trigger this VO when most of the room is cleared
	flag_wait( "monorail_wave_2_spawned" );

	while( !flag( "monorail_wave_2_clear" ))
	{
		num_alive = get_ai_group_sentient_count( "monorail_station_enemies" );
 
		if( flag( "monorail_wave_1_clear" ) && num_alive < 2 )
		{
			wait( RandomFloatRange( 1.5, 2.5 ));

			// Bravo Team Leader: "Convoy2 this is Bravo actual - just a few mikes out from rally point"
			wait_play_dialogue_wait( 0.0, "hithard_btl_mono_01" );
			break;
		}
		wait( 0.25 );
	}

}


// Helper script for timing dialogue
wait_play_dialogue_wait( wait_in, dialogue1, wait_out )
{
	wait( wait_in );

	radio_dialogue( dialogue1 );

	if( isDefined( wait_out ))
	{
		wait( wait_out );
	}
}

// JR - Moves the VP through the area
vp_movement()
{
	//level.squad[2].animname = "vp";
	//level.squad[3].animname = "ss";

	level.squad[2] disable_pain();
	level.squad[3] disable_pain();

	// Initial position in the monorail station
	flag_wait( "monorail_station_start" );
	wait( 3.0 );
	thread ss_vignette_move( GetNode( "monorail_vp_move_node_1", "script_noteworthy" ), level.squad[2], level.squad[3], false );
	issue_color_orders( "r14 p14", "allies" );

	// Wave 1 down - Move up
	flag_wait_any( "monorail_wave_1_clear", "monorail_wave_2_clear" );

	wait( RandomFloatRange( 2.6, 3.0 ));

	thread ss_vignette_move( GetNode( "monorail_vp_move_node_2", "script_noteworthy" ), level.squad[2], level.squad[3], false );
	issue_color_orders( "r150 p150", "allies" );

	// Secret Service Leader: "Moving Patriot under the platform"
	wait_play_dialogue_wait( 0.0, "hithard_sslead_monorail_01" );

	// Wave 2 down - Move to exit
	flag_wait( "monorail_wave_2_clear" );
	thread ss_vignette_move( GetNode( "monorail_vp_move_node_5", "script_noteworthy" ), level.squad[2], level.squad[3], false );
	issue_color_orders( "r155 p155", "allies" );

	// Transition into on-ramp section
	trigger_wait( "trigger_encounter_00", "script_noteworthy" );
	level.squad[2] notify( "stop_vignette" );
}


// Turns on Threat ID at the right time
threat_id_logic()
{
	level._player endon( "death" );

	level waittill( "turned_on_threatID" );

	thread maps\_threatid::threatid_bootup_and_enable();

	// Count number of enemies for threatID
	level thread threat_id_counter();

	// Wait to allow ThreatID to boot up
	wait( 4.0 );

	flag_wait( "monorail_station_enc_complete" );
	thread maps\_threatid::threatid_disable_overlay_and_effect();
}

// Updates the ThreatID counter based on number of enemies alive
threat_id_counter()
{
	level endon( "monorail_station_enc_complete" );
	num_alive = get_ai_group_sentient_count( "monorail_station_enemies" );
	while( num_alive > 0 )
	{
		num_alive = get_ai_group_sentient_count( "monorail_station_enemies" );
		level._player SetActiveThreatCount( num_alive );

		wait( 0.25 );
	}
}

post_monorail_regroup()
{
	//IPrintLnBold( "regroup" );
	Objective_State( 23, "done" );

	gypsy_node = GetNode( "gypsy_survey_homestretch", "script_noteworthy" );
	baker_node = GetNode( "baker_homestretch", "script_noteworthy" );

	level.squad[0].goalradius = 8;
	level.squad[1].goalradius = 8;

	level.squad[0] SetGoalNode( baker_node );
	level.squad[1] SetGoalNode( gypsy_node );

	// Short wait for the dialogue line
	wait( RandomFloatRange( 2.2, 2.8 ));

	// Bravo Team Leader: "Convoy2 this is Bravo actual - just a few mikes out from rally point"
	//wait_play_dialogue_wait( 0.0, "hithard_btl_mono_01" );

	// "Keep moving!"
	wait_play_dialogue_wait( 0.0, "hithard_bak_move_02" );

	level.squad[1] waittill( "goal" );
	level.squad[0] waittill( "goal" );

	wait_play_dialogue_wait( 1.8, "hithard_bak_mono_03" );

	// Duke: Home stretch, fellas.  I can see the highway...100 meters
	//wait_play_dialogue_wait( 0.0, "hithard_gyp_highway_01" );

	// Captain Baker: "Move quick."
	//wait_play_dialogue_wait( 1.0, "hithard_bak_highway_01" );

	// Secret Service Leader: "We're right behind you"
	//wait_play_dialogue_wait( 0.5, "hithard_sslead_highway_01" );

	// Captain Baker: "Let's punch it."
	//wait_play_dialogue_wait( 1.2, "hithard_bak_highway_02" );


	// Duke: Home stretch, fellas.  I can see the highway...100 meters
	//radio_dialogue( "hithard_gyp_highway_01" );
	// Baker: Let's punch it
	//radio_dialogue( "hithard_bak_highway_02" );
	// SSLead: We're right behind you
	//radio_dialogue( "hithard_sslead_highway_01" );

	level.squad[0] enable_ai_color();
	level.squad[1] enable_ai_color();

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
monorail_upstairs_logic()
{
	level endon( "monorail_station_enc_complete" );

	// Setup for the upstairs path
	monorail_upstairs_guys = GetEntArray( "monorail_upstairs_guys", "script_noteworthy" );
	array_spawn_function( monorail_upstairs_guys, ::monorail_upstairs_guys_logic );

	flag_wait( "went upstairs" );

	//change bakers color to green
	level.squad[1] set_force_color( "g" ); // Actor is now green
	issue_color_orders( "g143" ,"allies" );

	// Hit spawn triggers
	// ...
	// Combat
	// ...

	flag_wait( "monorail_upstairs_clear" );

	// Move baker back down and reset his color
	level.squad[1] set_force_color( "b" );
	issue_color_orders( "g143" ,"allies" );

}

monorail_upstairs_guys_logic()
{
	// ?
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// This script is meant to detect when the player sprints ahead of the area
monorail_sprint_watcher()
{
	flag_wait( "monorail_station_enc_complete" );

	num_alive = get_ai_group_sentient_count( "monorail_station_enemies" );

	// Player trying to bypass section
	if( num_alive >  3 )
	{
		wait( 0.5 );
		//level._player.health = 1;
		//level._player kill();
		SetDvar( "ui_deadquote", "@NX_HITHARD_B_FAILED_ABANDON" );
		level notify( "mission_failed" );
		maps\_utility::missionFailedWrapper();
	}
	// If the player runs through and only a few guys left, make sure they die
	else if( num_alive > 0 )
	{
		monorail_enemy_cleanup();
	}
}

// Kills any remaining actors
monorail_enemy_cleanup()
{
	// Downstairs guys
	alive_guys = get_ai_group_ai( "monorail_station_enemies" );
	foreach( guy in alive_guys )
	{
		guy.health = 1;
		guy thread monorail_wait_and_kill();
	}
}

// Kills straggling enemies if the player is finished with
// this section and leaves the area
monorail_wait_and_kill()
{
	self endon( "death" );
	wait( RandomFloatRange( 2.5, 3.5 ));
	self kill();
}


// Turns off triggers as the player moves through
// This is done to prevent allies from backtracking if
// the player hits old triggers
monorail_trigger_logic()
{
	flag_wait( "monorail_wave_1_clear" );
	thread maps\nx_hithard_b_util::all_triggers_off( "monorail_triggers_wave_1" );

	flag_wait( "monorail_wave_2_clear" );
	thread maps\nx_hithard_b_util::all_triggers_off( "monorail_triggers_wave_2" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Makes a movable door object out of any prefab that has a script_origin
monorail_make_sliding_door( sTargetname )
{
	// Get all the entities inside sTargetname prefab object
	ents = getentarray( sTargetname, "targetname" );

	if( !ents.size )
	{
		AssertMsg( "No door ents found in monorail_make_sliding_door" );
		return;
	}

	door_org = undefined;	// Door origin, the hinge
	door_models = [];
	door_brushes = [];
	foreach( ent in ents )
	{
		// If the entity is a brushmodel
		if ( ent.code_classname == "script_brushmodel" )
		{
			door_brushes[ door_brushes.size ] = ent; // Add it to the list of brushes
			continue;
		}
		// If the entity is a script_origin
		if ( ent.code_classname == "script_origin" )
		{
			door_org = ent;	// Save it as the hinge
			continue;
		}
		// If the entity is a script_model
		if ( ent.code_classname == "script_model" )
		{
			door_models[ door_models.size ] = ent; // Add it to the list of models
			continue;
		}
	}
	
	// Link everything to the origin so it moves together as one object
	foreach( model in door_models )
		model linkto( door_org );
	foreach( brush in door_brushes )
		brush linkto( door_org );
	
	door = door_org;

	return door;
}

// closed: -62
// JR - Unused
monorail_right_door_open()
{
	// Door should be closed when the level starts
	self monorail_door_slide( -20, 0.25 );
}


// Continually opens and closes the door to make it look stuck
// Closed: 65
monorail_door_stuck_loop( v1, v2, v3, v4 )
{
	level endon( "monorail_station_enc_complete" );

	// Door should be closed when the level starts
	self monorail_door_slide( v1, 0.25 );

	while( !flag( "monorail_station_enc_complete" ))
	{
		// Close
		self monorail_door_slide( v2, 1.0 );

		wait( 6.0 );

		// Open
		self monorail_door_slide( v3, 1.0 );

		// Open
		self monorail_door_slide( v4, 0.2 );

		wait( 1 );
	}
}


// Open a door opject that was made with make_door_from_prefab() 
monorail_door_slide( x_movement, time )
{
	// Wait untill current move command is finished before starting a new one
	if ( isdefined( self.moving ) )
	{
		while( isdefined( self.moving ) )
			wait( 0.05 );
	}
	
	self.moving = true;
	//angles = distance;
	//if ( isdefined( self.openangles ) )
	//	angles = self.openangles;
	
	//iTime = 4;
	//self thread play_sound_on_entity( "nx_scn_training_fence_open" );
	self moveto( self.origin + ( x_movement, 0, 0 ), time, 0.1, 0.1 );

	//self thread play_sound_on_entity( "scn_training_fence_open" );
	//array_call( self.brushes,::notsolid );
	wait( time );	// Wait for the door to open
	self.moving = undefined; // No longer moving
}

monorail_automatic_door()
{
	/*
	while()
	{
		//door_trig = 
		if( level._player IsTouching( door_trig ))
		{
			if( self.open == false )
			{
				self.open = true;
				self monorail_door_open();
			}
		}
		else
		{
			self.open = false;
			self monorail_door_close();
		}

		if( flag( "monorail_station_end_complete" ))
		{
			// Close the door for good
			self monorail_door_close();
			return;
		}
	}
	*/
}

