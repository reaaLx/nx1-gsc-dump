//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Skyscraper Exfil Market Section								**
//                                                                          **
//    Created: 11/10/2011 - John Webb										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


//*******************************************************************
//                                                                  *
//	STREET - Market to hotel										*
//                                                                  *
//*******************************************************************
start()
{
	maps\nx_exfil_util::exfil_setup_allies( "market" );
	maps\nx_exfil_util::player_start( "market_player" );

	flag_set( "intro_dialogue_complete" );
	flag_set( "flag_exfil_intro_player_door" );
	flag_set( "intro_ended" );

	battlechatter_off( "allies" );
}

// Called from nx_exfil.gsc
flag_inits()
{
	// Iniitialize all market variables here
	flag_init( "radio_exfil_begin" );
	flag_init( "exit_ambulance" );
	flag_init( "cop_dialogue_complete" );
	flag_init( "heli_intro_dialogue_complete" );
	flag_init( "raptor_vo" );
	flag_init( "raptor_vo_complete" );

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
main()
{
	flag_wait( "intro_ended" );

	// Thread off some trigger waiters
	level thread ammo_check();
	level thread cop_encounter_start();
	level thread cleanup_side_street();
	level thread market_retreat();
	level thread swat_encounter_start();
	level thread entered_streets();
	level thread market_police();

	// set Baker on his way
	level.allies[ "ally1" ] enable_cqbwalk();
//	level.allies[ "ally1" ] issue_color_orders( "r0", "allies" );

	level thread market_baker_dialogue();
	level thread market_baker_dialogue_heli_inc();

	//flag_wait( "exit_ambulance" );
	//spawn_vehicle_from_targetname_and_drive( "cop_car_1" );
	//spawn_vehicle_from_targetname_and_drive( "cop_car_2" );

	flood_lights_off = GetEntArray( "flood_lights_off", "script_noteworthy" );
	if( IsDefined( flood_lights_off ) )
	{
		for( index = 0; index < flood_lights_off.size; index++ )
		{
			flood_lights_off[index] Show();
		}
	}

	flood_lights_on = GetEntArray( "flood_lights_on", "script_noteworthy" );
	if( IsDefined( flood_lights_on ) )
	{
		for( index = 0; index < flood_lights_on.size; index++ )
		{
			flood_lights_on[index] Hide();
		}
	}

	flag_wait( "exit_ambulance" );

	//level thread autosave_by_name( "exit_ambulance" );
}

ammo_check()
{
	flag_wait( "ammo_check" );
	flag_wait( "heli_intro_dialogue_complete" );
	wait 3.0;
	ammo_dialogue();

	thread raptor_vo_during_lull();

	wait 5.0;
	raptor_dialogue();

}

raptor_vo_during_lull()
{
	level endon( "entered_streets" );
	market_volume = GetEnt( "market_far", "script_noteworthy" );
	while ( 1 )
	{
		market_ai = market_volume get_ai_touching_volume( "axis" );
		if ( market_ai.size <= 2 )
		{
			break;
		}
		wait 1;
	}
	flag_set( "raptor_vo" );
}

market_baker_dialogue()
{
	level endon( "swat_encounter_start" );
}

market_baker_dialogue_heli_inc()
{
	flag_wait_any( "start_spotlight_heli_intro_path", "start_spotlight_heli_market_path" );
	wait 5.0;
	level.baker radio_dialogue( "exf_bak_helo_watchit" ); // Watch it!  Eyes up top!
	level.baker radio_dialogue( "exf_bak_helo_spotlightpinyou" ); // Don't let that spotlight pin you!
	flag_set( "heli_intro_dialogue_complete" );
}

cop_encounter_start()
{
	flag_wait( "exit_ambulance" );

	//level notify( "stop_stumble_walk" );

	//cop_car_1 = spawn_vehicle_from_targetname_and_drive( "cop_car_1" );
	//cop_car_2 = spawn_vehicle_from_targetname_and_drive( "cop_car_2" );	
	autosave_by_name( "cops" );

	level thread cop_encounter_logic();
	level.allies[ "ally1" ] thread baker_holds_fire();
	level thread cop_encounter_dialogue();
	wait 1.5;
	level.allies[ "ally1" ] disable_cqbwalk();
	
	level endon( "swat_player_moving_up" );

	wait 5;
	while ( get_ai_group_sentient_count( "cops" ) > 1 )
	{
		wait 0.1;
	}

	flag_set( "swat_encounter_start" );
}

baker_holds_fire()
{
	self.dontevershoot = 1;
	flag_wait( "cops_engaged" );
	self.dontevershoot = undefined;
}


cop_encounter_logic()
{
	level endon( "cops_engaged" );
	level._player waittill( "weapon_fired" );
	level.allies[ "ally1" ] issue_color_orders( "r30", "allies" );
	flag_set( "cops_engaged" );
}

cop_encounter_dialogue()
{
	wait 1.5;
	flag_wait( "intro_dialogue_complete" );

	level thread cop_encounter_baker_dialogue();

	//level.baker radio_dialogue( "exf_bak_van_takecover" ); // Take cover, hold your fire
	level.baker radio_dialogue( "exf_bak_intro_shitcops" ); // Shit, cops…take cover, hold your fire Walker
	flag_set( "cop_dialogue_complete" );

	/*
	if ( flag( "cops_engaged" ) )
	{
		return;
	}
	level endon( "cops_engaged" );

	// Thread these add_dialogue_line calls since this script now has an endon().
	// Otherwise, the dialogue lines will never fade
	wait 2.0;
	radio_dialogue( "exf_cop_alley_freeze" );
	wait .5;
	radio_dialogue( "exf_cop_alley_dropweapons" );
	wait .4;
	radio_dialogue( "exf_cop_alley_dontmove" );
	wait .3;
	flag_set( "cops_engaged" );
	*/
}


cop_encounter_baker_dialogue()
{
	wait 3.0;
//	level.allies[ "ally1" ] thread anim_single_solo( level.allies[ "ally1" ], "roadkill_cover_radio_soldier1_idle" ); //play radio anim while on the radio
	radio_dialogue( "exf_bak_cops_localpolice" );
//	thread add_dialogue_line( "OVERLORD:", "ROE is wide open", "orange", 2 );  // stub until we get audio line
	radio_dialogue( "exf_ovl_cops_roewideopen" );
	if ( !flag( "cops_engaged" ) )
	{
		thread radio_dialogue( "exf_bak_cops_lightemup" );
	}
	wait 1.5;
	flag_set( "cops_engaged" ); 
}

swat_encounter_start()
{
	flag_wait( "swat_encounter_start" );

	thread audio_switch_ambience();
	thread swat_encounter_dialogue();

	swat1 = spawn_vehicle_from_targetname_and_drive( "swat1" );
	swat1 playsound("scn_exfil_swat_van");
	PlayFxOnTag( getfx( "swat_headlight_l" ), swat1, "TAG_HEADLIGHT_LEFT" );
	PlayFxOnTag( getfx( "swat_headlight_r" ), swat1, "TAG_HEADLIGHT_RIGHT" );  
	thread swatvan_spawn_backup( 2, "swatvan1", "swatvan1_backup" );

	flag_set( "music_market_start" );

	level endon( "entered_streets" );
	wait 5;

	if ( !flag( "swat_player_moving_up" ) )
	{
		level.allies[ "ally1" ] issue_color_orders( "r31", "allies" );
	}
	wait 5;
	battlechatter_on( "allies" );
}

swat_encounter_dialogue()
{
	wait 3.0;
	flag_wait( "cop_dialogue_complete" );

	level.baker radio_dialogue_queue( "exf_bak_cops_wegotinbound" );	// We got more inbound.  Let's move, Walker.
	////level.baker radio_dialogue_queue( "exf_bak_swat_moreinbound" );	// Shit!  More of'em inbound!
	//level.baker radio_dialogue_queue( "exf_bak_swat_swatshere" );	// SWATs here!
	//wait 0.7;
	//level.baker radio_dialogue_queue( "exf_bak_pu_letsmove" );	// c’mon walker, let’s move.
	//level.baker radio_dialogue_queue( "exf_bak_swat_morecopsonhill" ); // More cops on the hill!

}

audio_switch_ambience()
{
	
	wait 3;
	thread maps\_utility::set_ambient( "nx_exfil_amb03" );

}

cleanup_side_street()
{
	self endon( "entered_streets" ); // Don't do this if player is in next checkpoint
	self waittill( "market_fallback" );

	// Move side street ai to market_far
	ai_group = get_ai_group_ai( "swatvan1" );
	foreach ( actor in ai_group )
	{
			market_vol = GetEnt( "market_far", "script_noteworthy" );
			actor SetGoalVolumeAuto( market_vol );
	}

	// Delete remaining cops
	ai_group = get_ai_group_ai( "cops" );
	foreach ( actor in ai_group )
	{
		AI_delete_when_out_of_sight( ai_group, 312 );
	}
}

swatvan_spawn_backup( num_left, ai_group, backup_targetname )
{
	self endon( "entered_market" );
	self endon( "took_alley_route" );
	self endon( "entered_streets" );
	wait 5; // Initial wait
	while ( get_ai_group_sentient_count( ai_group ) > num_left )
	{
		wait .1;
	}

	// Spawn backup
	backup = GetEntArray( backup_targetname, "targetname" );
	foreach ( guy in backup )
	{
		guy spawn_ai();
	}
	
}

market_retreat()
{
	self endon( "entered_streets" );
	self waittill( "entered_market" );
	level thread autosave_by_name( "market_retreat" );
}

ammo_dialogue()
{
	level.baker radio_dialogue( "exf_bak_swat_myammoslow" ); // My ammo's low….you?
	wait 0.3;
	level.baker radio_dialogue( "exf_bak_swat_keeptoppedonammo" ); // Keep topped up on ammo!?
	//level.baker radio_dialogue( "exf_bak_van_ammolight" ); // your ammo's light.
	//level.baker radio_dialogue( "exf_bak_van_grabkit" ); // Grab whatever kit you can.
	//add_dialogue_line( "BAKER", "Watch your ammo!  Grab another weapon!", "blue", 1.5);
}

raptor_dialogue()
{
	flag_wait( "raptor_vo" );
	level.baker radio_dialogue( "exf_rap_swat_whatsyourgrid" ); // Kilo-four, this is raptor…we are 4 mikes out, what's your grid?
	level.baker radio_dialogue( "exf_bak_swat_mapgrid779" ); // Map grid seven-seven-niner.  See you soon, over.
	level.baker radio_dialogue( "exf_rap_swat_rogerthat" ); // Roger that, hotel alpha.
	flag_set( "raptor_vo_complete" );
}

give_aigroup_new_goal( goal_name, ai_name, new_accuracy )
{
	if( !get_ai_group_sentient_count( ai_name ) )
		return false;
	
	guys = get_ai_group_ai( ai_name );
	goal_nodes = getNodeArray( goal_name + "_node", "targetname" );
	goal_volume = getent( goal_name + "_vol", "targetname" );

	//iprintln( "nodes: " + goal_nodes.size );

	if( guys.size > goal_nodes.size )
		num_runners = goal_nodes.size;
	else
		num_runners = guys.size;

	for( i = 0 ; i < num_runners ; i++ )
	{
		guy = guys[i];

		guy ClearGoalVolume();
		guy setGoalNode( goal_nodes[i] );
		guy setGoalVolume( goal_volume );

		if( isdefined( new_accuracy ) )
			guy set_baseaccuracy( new_accuracy );
	}
}

entered_streets()
{
	level waittill( "entered_streets" );

	battlechatter_off( "allies" ); // Disable battlechatter for streets moment
}

market_police()
{
	level endon( "entered_market" );
	level waittill( "market_police" );
	market_police_car = spawn_vehicle_from_targetname_and_drive( "market_police_car" );
	market_police_car playsound("scn_exfil_police_car_street");
	market_police_car thread maps\nx_exfil_audio::police_car_radio_chatter();

}