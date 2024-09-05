//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Nx_Hospital - Atrium / Construction area						**
//                                                                          **
//    Created: 11/11/11 - Justin Rote										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


//*******************************************************************
//																	*
// ATRIUM - Construction area										*
//																	*
//*******************************************************************
start()
{
	maps\nx_hospital_util::actor_teleport( level.squad[ "ALLY_ALPHA" ], "atrium_start_alpha" );
	maps\nx_hospital_util::actor_teleport( level.squad[ "ALLY_BRAVO" ], "atrium_start_bravo" );
	level._player maps\_nx_utility::move_player_to_start_point( "atrium_start_player" );
}

section_precache()
{
	PreCacheRumble( "artillery_rumble" );
}

section_flag_inits()
{
	flag_init( "allies_move_down" );
	flag_init( "atrium_clear" );

	// -=TEMPORARY HACK FIX=-
	// JR - This is a hack and should not be here.
	// I had to do this because the previous section
	// was not threaded correctly and will block
	// untill it is fully completed.
	level.atrium_spawn_funcs_assigned = false;
	thread atrium_wave_logic();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
main()
{
	// Allies go loud
	level.squad[ "ALLY_ALPHA" ].ignoreAll = false;
	level.squad[ "ALLY_BRAVO" ].ignoreAll = false;
	level.squad[ "ALLY_ALPHA" ].ignoreMe = false;
	level.squad[ "ALLY_BRAVO" ].ignoreMe = false;

	// Handle counting number of enemies killed
	thread atrium_wave_logic();

	// Main logic thread for the encounter
	thread atrium_logic();

	// Make it hard for the player to rush through the area
	thread atrium_exit_rush_logic();

	// Makes the last few enemies more aggressive
	thread atrium_straggler_cleanup();

	// Handle the exploding tank
	thread atrium_exploding_tank();

	// If they reach the exit, move on to Hospital section
	flag_wait( "atrium_exit" );

	// Cleanup remaining guys
	thread atrium_cleanup();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Main encounter thread
atrium_logic()
{
	// Move Baker up
	issue_color_orders( "b200", "allies" );

	wait 1.75;

	// Move Keene up
	issue_color_orders( "g200", "allies" );

	// Wait for X kills, and move up
	flag_wait( "player_at_perch" );
	issue_color_orders( "b205", "allies" );

	// Alters threatbias if the player stays up top for a long time
	delayThread( 20, ::atrium_handle_attacker_accuracy );

	// Tell player to move down if they stay up top too long
	thread atrium_perch_warning();

	wait 1.25;
	issue_color_orders( "g205", "allies" );

	wait 4;

	// Baker: "Move up!"
	level.squad[ "ALLY_ALPHA" ] play_dialogue( "hos_bak_const_moveup", 0 ); 

	wait 8;

	trigger = getent( "atrium_wave_2", "script_noteworthy" );
	if ( isdefined( trigger ) )
	{
		trigger notify( "trigger" );
	}

	// Wait for X kills, and move up
	//wait_for_num_kills( 6 );
	//remove_trigger( "trigger_construction_210" );
	//issue_color_orders( "b220 g220", "allies" );

	// Wait for X kills, and move up
	//wait_for_num_kills( 16 );
	//remove_trigger( "trigger_construction_220" );
	//issue_color_orders( "b230 g230", "allies" );

	trigger = getent( "atrium_wave_3", "script_noteworthy" );
	level notify( "atrium_wave_3_go" );
	if ( isdefined( trigger ) )
	{
		trigger notify( "trigger" );
	}

	//******************************************************************
	// Atrium Clear
	//******************************************************************
	// Wait for atrium to be clear, and player hits exit flag
	flag_wait( "atrium_clear" );

	// Cleanup AI trigs
	remove_trigger( "trigger_construction_allies" );

	// Natural pause after last kill
	wait 2.82;

	// Move allies up
	thread move_allies_into_exit_corridor();

	// Keene: "Clear!"
	level.squad[ "ALLY_BRAVO" ] play_dialogue( "hos_jenk_const_clear", 0 ); 


	wait 1.1;

	// Baker: "We're clear!"
	level.squad[ "ALLY_ALPHA" ] play_dialogue( "hos_bak_const_wereclear", 0 ); 

	wait 0.64;

	// Baker: "Let's go!"
	level.squad[ "ALLY_ALPHA" ] play_dialogue( "hos_bak_const_letsgo", 0 );
}


// Moves allies up into the exit corridor section
move_allies_into_exit_corridor()
{
	trigger = GetEnt ("corridor_grenade_trigger", "targetname");
	trigger endon ("trigger");

	if( !flag( "atrium_exit" ))
	{
		// Moves allies up to outter door
		issue_color_orders( "b298 g298", "allies" );

		// Wait for player to get close
		flag_wait( "player_at_atrium_exit" );

		// Enable CQB
		maps\nx_hospital_util::squad_cqb( true );

		// Keen moves up to K2
		issue_color_orders( "g299", "allies" );

		wait 2.5;

		// Baker moves up to b2
		issue_color_orders( "b300", "allies" );

		wait 1.5;
	
		// Baker: "It's too quiet"
		level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_tooquiet" );

		wait 2.5;

		// Keene moves up to k3
		issue_color_orders( "g300", "allies" );

		// Baker: "Take point"
		level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_takepoint" );
	}
	// Player rushed ahead, skip the VO and move allies up to 300
	else
	{
		issue_color_orders( "b300 g300", "allies" );
	}
}


// Init for the kill counter logic
atrium_wave_logic()
{
	if( !level.atrium_spawn_funcs_assigned )
	{
		wave_counters = getentarray( "atrium_wave_counter", "script_noteworthy" );
		array_thread( wave_counters, ::add_spawn_function, ::atrium_wave_counter );
		level.wave_count = 0;
		level.atrium_spawn_funcs_assigned = true;
	}
}


// Keeps track of number of kills
atrium_wave_counter()
{
	self waittill( "death" );
	level.wave_count++;
}


// If the player stays up top too long, they get called down
atrium_perch_warning()
{
	level endon( "atrium_clear" );

	// Baker: "Get down here!"
	// Baker: "Get down here now!"
	// Baker: "Get out of there!"
	warning_vo_array = [ "hos_bak_const_getdown", "hos_bak_const_getdownhere", "hos_bak_const_getoutofhere" ];

	wait 16;

	// Start rooftop warner
	while( flag( "flag_atrium_player_on_perch" ))
	{
		random_warner = Random( warning_vo_array );	
		level.squad[ "ALLY_ALPHA" ] play_dialogue( random_warner, 0 );

		wait( RandomFloatRange( 18.0, 28.0 ));
	}
}


// Cleans up remaining enemies after you leave the area
atrium_cleanup()
{
	flag_wait( "atrium_cleanup" );

	// Make sure no new guys spawn
	thread maps\_spawner::kill_spawnerNum( 210 );
	thread maps\_spawner::kill_spawnerNum( 220 );
	thread maps\_spawner::kill_spawnerNum( 240 );

	// Kill off any remaining guys
	remaining_guys = get_ai_group_ai( "atrium_guys" );
	foreach( guy in remaining_guys )
	{
		guy thread maps\nx_hospital_util::delete_after_time( randomFloatRange( 1.5, 2.5 ));
	}
}



// Make it hard for the player to rush the exit door
atrium_exit_rush_logic()
{
	level endon( "atrium_wave_3_go" );
	level endon( "atrium_clear" );

	flag_wait( "flag_atrium_player_at_exit" );

	// Spawn some very unhappy shotgunner guys blocking the exit
	array_spawn_targetname( "rush_stopper_guys" );

	// Die!!
	level._player.attackerAccuracy = 1000;
	level._player.threatbias = 1000;

	thread reset_rush_penalty_after_time( 8 );
}


// If the player somehow manages to live through this, fine, reset everything and let them continue.
reset_rush_penalty_after_time( time )
{
	wait time;
	level._player.attackerAccuracy = 1;
	level._player.threatbias = 0;	
}


// Increases enemy accuracy if the player hangs out up top
// JR - I don't think I like this...
atrium_handle_attacker_accuracy()
{
	level endon( "atrium_clear" );

	while( 1 )
	{
		// ON
		flag_wait( "flag_atrium_player_on_perch" );
		level._player.attackeraccuracy = 10.0;
		level._player.threatbias = 800;

		// OFF
		flag_waitopen( "flag_atrium_player_on_perch" );
		level._player.attackeraccuracy = 1.0;
		level._player.threatbias = 0;
	}
}



//*******************************************************************
// 	ATRIUM UTILS
//*******************************************************************

// Kills a trigger
remove_trigger( name )
{
	triggers = GetEntArray( name, "targetname" );
	foreach( trigger in triggers )
	{
		if( isDefined( trigger ))
		{
			trigger delete();
		}
	}
}


// Waits for a certain number of enemies to die
wait_for_num_kills( num_kills )
{
	level endon( "atrium_clear" );

	while( 1 )
	{
		if( level.wave_count >= num_kills )
		{
			return;
		}
		wait 1;
	}
}


// When encounter is almost over, kill all spawners and
// make enemies more aggresive
atrium_straggler_cleanup()
{
	//******************************************************************
	// Atrium Ending
	//******************************************************************
	// Wait for X number of guys left
	waittill_aigroupcount( "atrium_guys", 3 );

	// Make remaining guys more aggressive
	remaining_guys = get_ai_group_ai( "atrium_guys" );
	foreach( guy in remaining_guys )
	{
		guy.aggressivemode = true;
		guy thread ai_playerseek();
	}

	// Make sure no new guys spawn
	thread maps\_spawner::kill_spawnerNum( 210 );
	thread maps\_spawner::kill_spawnerNum( 220 );
	thread maps\_spawner::kill_spawnerNum( 240 );

	// Kill any guys stuck in the roof closet
	kill_volume = GetEnt( "atrium_roof_kill_volume", "targetname" );
	kill_volume thread kill_ai_in_volume();

	// Kill any guys in the stair case
	kill_volume = GetEnt( "atrium_stairs_kill_volume", "targetname" );
	kill_volume thread kill_ai_in_volume();

	// Kill any guys on the 2nd floor
	kill_volume = GetEnt( "atrium_2nd_story_kill_volume", "targetname" );
	kill_volume thread kill_ai_in_volume();
}


kill_ai_in_volume()
{
	ai = GetAIArray();

	foreach ( guy in ai )
	{
		if ( guy IsTouching( self ) && !guy is_hero() && !player_can_see_ai( guy ) )
		{
			guy Delete();
		}
	}
}



// Make an actor seek out the player
ai_playerseek()
{
	self endon( "death" );
	
	if ( isdefined( self.target ) )
		self waittill( "goal" );

	self ClearGoalVolume();

	//iprintlnbold( "PLAYER SEEK" );
	self setgoalentity( level._player );
	self.goalradius = 256;
	self.favoriteenemy = level._player;
}


// Handle the explodable gas tank
atrium_exploding_tank()
{
	gas_tank = GetEnt( "atrium_tank", "script_noteworthy" );

	gas_tank waittill( "exploded" );

	// Trigger the exploders
	exploder( "exploder_atrium_tank" );

	// Vibrate
	quakeobj = spawn( "script_origin", level._player.origin );
	quakeobj PlayRumbleOnEntity( "artillery_rumble" );

	// Kill the shootable_pipe object
	/*
	pipes = GetEntArray( "pipe_shootable", "targetname" );
	foreach( pipe in pipes )
	{
		if( isDefined( pipe ) && pipe.script_parameters == "atrium_pipe_shootable" )
		{
			iprintlnbold( "Got pipe" );
			pipe delete();
		}
	}
	*/

	wait 0.5;

	// Trigger wall swap
	exploder( "exploder_atrium_wall" );
	exploder( "exploder_atrium_exit" );


	// Turn on a badplace where the explosion happened
	badplace = getent( "atrium_tank_badplace", "targetname" );
	badplace_brush( "atrium_tank_badplace", 0, badplace, "axis" );

	wait 0.3;
	exploder( "exploder_atrium_tank_dust_01" );
	wait 0.4;
	exploder( "exploder_atrium_tank_dust_02" );
	wait 0.5;
	exploder( "exploder_atrium_tank_dust_03" );
	wait 0.4;
	exploder( "exploder_atrium_tank_dust_04" );
	wait 0.6;
	exploder( "exploder_atrium_tank_dust_05" );
	wait 0.5;
	exploder( "exploder_atrium_tank_dust_06" );
	wait 0.5;
	exploder( "exploder_atrium_tank_dust_07" );

	wait 2;
	exploder( "exploder_atrium_tank_wait" );
	// Kill the roof spawners
	//thread maps\_spawner::kill_spawnerNum( 215 );

	// Kill all enemies on the roof
	//kill_ai_in_volume = GetEnt( "atrium_roof_kill_volume", "targetname" );
	//kill_ai_in_volume thread kill_ai_in_volume();
}
