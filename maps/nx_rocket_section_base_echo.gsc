
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


//*******************************************************************
//                                                                  *
//*******************************************************************
start()
{
	// Turn off AA turret section smoke
	maps\nx_rocket_util::pre_turret_event();

	teleport_info = [];
	teleport_info[ "ALLY_BAKER" ]		= "start_default_ally_00";
	teleport_info[ "ALLY_JENKINS" ]		= "start_base_echo_ally_01";
	teleport_info[ "ALLY_WILLIAMS" ]	= "start_base_echo_ally_02";
	maps\nx_rocket_util::squad_teleport( teleport_info );
	level._player maps\_nx_utility::move_player_to_start_point( "start_base_echo_player" );
}

main()
{
	level thread objective_follow( true );

	level thread section_dialogue();

	// Ambient FX for Fallen Rocket
	thread maps\nx_rocket_fx::fallenrocket_fx();
	thread maps\nx_rocket_fx::fallenrocket_fx_cleanup();
	thread maps\_utility::set_ambient( "nx_rocket_ext" );
	thread ec_turret_sfx();

	flag_set( "regrouped_with_squad" );

//  level._player thread maps\nx_rocket_util::player_ledge_walk( GetEnt( "base_echo_ledge_trigger", "targetname" ) );
	level._player thread player_ledge_walk();

//  level thread chopper_crash();

	level.squad[ "ALLY_WILLIAMS" ] enable_cqbwalk();
	level.squad[ "ALLY_JENKINS" ] enable_cqbwalk();

	issue_color_orders( "b0 p0", "allies" );

	waittill_aigroupcleared( "enemy_base_echo_01" );

	// SAVE POINT
	level thread autosave_now();

	issue_color_orders( "b2 p2", "allies" );
	level.squad[ "ALLY_WILLIAMS" ] ally_wave_through_pass();
//  ally_woods_traversal();

	issue_color_orders( "b10 p10", "allies" );
	waittill_aigroupcleared( "enemy_base_echo_02" );

	// SAVE POINT
	level thread autosave_now();

//  ally_woods_mantle();
	issue_color_orders( "b11 p11", "allies" );

	flag_wait( "base_echo_team_ledge_walk" );
	level.squad[ "ALLY_WILLIAMS" ] ally_woods_ledge( "p13" );
	wait 2.0;
	level.squad[ "ALLY_JENKINS" ] ally_woods_ledge( "b13" );
	issue_color_orders( "b13 p13", "allies" );

	// SAVE POINT
	level thread autosave_now();

//  ally_point_to_destroyed_rocket();
	flag_wait( "base_echo_rocket_reveal" );
	wait 5.0;
	flag_wait( "base_echo_pipe_jump" );

	// SPACING OUT THEIR ORDERS TO AVOID SYNCHRONIZATION.
	issue_color_orders( "b14", "allies" );
	wait 2.0;
	issue_color_orders( "p14", "allies" );

	flag_wait( "base_echo_pipe_start" );
	issue_color_orders( "b30 p30", "allies" );

	flag_wait( "base_echo_exit" );

	level.squad[ "ALLY_WILLIAMS" ] disable_cqbwalk();
	level.squad[ "ALLY_JENKINS" ] disable_cqbwalk();

	level._player notify( "end_ledge" );

	level thread objective_follow( false );
}

ally_woods_traversal()
{
	maps\nx_rocket_anim::woods_traversal_01( level.squad[ "ALLY_WILLIAMS" ] );
	maps\nx_rocket_anim::woods_traversal_02( level.squad[ "ALLY_WILLIAMS" ] );
	maps\nx_rocket_util::squad_color_reset();
}

ally_woods_mantle()
{
	maps\nx_rocket_anim::woods_mantle( level.squad[ "ALLY_WILLIAMS" ], level.squad[ "ALLY_JENKINS" ] );
	maps\nx_rocket_util::squad_color_reset();
}

ally_woods_ledge( order_on_end )
{
	maps\nx_rocket_anim::woods_ledge( self );
	maps\nx_rocket_util::squad_color_reset();
	issue_color_orders( order_on_end, "allies" );
}

ally_pipe_traversal()
{
	maps\nx_rocket_anim::pipe_traversal_01( level.squad[ "ALLY_WILLIAMS" ] );
	maps\nx_rocket_anim::pipe_traversal_02( level.squad[ "ALLY_WILLIAMS" ] );
	maps\nx_rocket_util::squad_color_reset();
}

ally_wave_through_pass()
{
	node = GetEnt( "anim_base_echo_direct", "targetname" );
	node anim_reach_solo( self, "cqb_wave_on_me" );
	flag_wait( "base_echo_wave_player" );
	node anim_single_solo( self, "cqb_wave_on_me" );

	maps\nx_rocket_util::squad_color_reset();
	issue_color_orders( "b10 p10", "allies" );
}

ally_point_to_destroyed_rocket()
{

	chopper = vehicle_spawn( GetEnt( "base_echo_chopper", "targetname" ) );
	node = GetEnt( "anim_base_echo_rocket_reveal", "targetname" );
	node anim_reach_solo( level.squad[ "ALLY_WILLIAMS" ], "rocket_reveal_point" );

	flag_wait( "vignette_base_echo_rocket_reveal" );
	chopper GoPath();
	node anim_single_solo( level.squad[ "ALLY_WILLIAMS" ], "rocket_reveal_point" );
	chopper Kill();
	maps\nx_rocket_util::squad_color_reset();
}

chopper_crash()
{
	flag_wait( "base_echo_chopper" );

	chopper = vehicle_spawn( GetEnt( "base_echo_chopper", "targetname" ) );
	chopper GodOn();
	chopper GoPath();
	chopper thread chopper_turret_fire();
//  chopper waittill( "reached_dynamic_path_end" );

	flag_wait( "base_echo_chopper_kill" );
	chopper thread chopper_passengers_eject();

	chopper GodOff();
	chopper Kill();
}

chopper_turret_fire()
{
	self endon( "death" );

	turret_org = GetEnt( "base_echo_aa_turret", "targetname" );
	fire_rate = 5; // SHOTS PER SECOND
	hit_radius = 1000;

	wait 5.0;

	while( IsAlive( self ) )
	{
		hit_radius *= 0.99;
		hit_offset = random_vector( hit_radius );
		turret_org thread maps\nx_rocket_util::aa_turret_fire( self, hit_offset );
		wait 1/(fire_rate);
	}
}

chopper_passengers_eject()
{
	while( self.riders.size > 1 )
	{
		rider = self.riders[ self.riders.size - 1 ];
		rider Unlink();
		rider StopAnimScripted();
		rider Kill();
		wait RandomFloatRange( 1.5, 3.0 );
	}
}

player_ledge_walk()
{
	self endon( "end_ledge" );

	while( 1 )
	{
		flag_wait( "base_echo_ledge" );
		self SetMoveSpeedScale( 0.3 );
		self HideViewModel();
		self DisableWeapons();
	
		flag_waitopen( "base_echo_ledge" );
		self SetMoveSpeedScale( 1.0 );
		self ShowViewModel();
		self Enableweapons();

		wait 0.05;
	}
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
section_dialogue()
{
	wait 3.0;
	maps\nx_rocket_util::wait_play_dialogue_wait( 1, "roc_jen_hang_baker" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_wil_hang_bettergetmoving" );

//  flag_wait( "base_echo_wave_player" );
//  level thread add_dialogue_line( "Williams", "They're gonna be looking for us. Stay sharp and keep quiet.", undefined, 3.0 );

	flag_wait( "base_echo_rocket_reveal" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 1, "roc_wil_echo_objecho" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_jen_echo_flightdelayed" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_wil_echo_stfujenkins" );
//  level thread add_dialogue_line( "Williams", "Woo! Well, look at that!", undefined, 3.0 );
//  wait 2.0;
//  level thread add_dialogue_line( "Jenkins", "Toasty!", undefined, 3.0 );

	flag_wait( "base_echo_pipe_jump" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 1, "roc_jen_echo_pipe" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 1, "roc_wil_echo_worthashot" );
//  level thread add_dialogue_line( "Jenkins", "This pipe might lead us out of here.", undefined, 3.0 );
//  wait 2.0;
//  level thread add_dialogue_line( "Williams", "Hell, it's worth a shot.", undefined, 3.0 );

//  wait 3.0;
//  level thread maps\nx_rocket_util::dialogue_nag_temp( "Williams", "Lockwood! Down here!", 3.0, 2.0, 4.0, "base_echo_pipe_start" );

	flag_wait( "base_echo_pipe_start" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_wil_echo_moveout" );
//  wait 1.0;
//  level thread add_dialogue_line( "Williams", "Alright, let's move out. Watch your step...", undefined, 2.0 );

	flag_wait( "base_echo_chopper" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 1, "roc_jen_echo_flagdownbird" );

//  wait 1.0;
//  level thread add_dialogue_line( "Jenkins", "Hey, that's one of our birds!", undefined, 3.0 );
//  wait 1.0;
//  level thread add_dialogue_line( "Williams", "Alright! Let's flag them down!", undefined, 3.0 );

	flag_wait( "base_echo_chopper_kill" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_wil_echo_shit" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_wil_echo_cantdoanythingforthem" );

	flag_wait( "base_echo_exit" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_wil_trbase_structureahead" );
	wait 4.0;
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_wil_trbase_getdropontangos" );


//  level thread add_dialogue_line( "Jenkins", "Holy shit...", undefined, 3.0 );
//  wait 2.0;
//  level thread add_dialogue_line( "Williams", "Let's keep moving. We can't help them...", undefined, 3.0 );
}

section_precache()
{
	PreCacheItem( "nx_rocket_aa_turret" );
}

section_flag_inits()
{
	flag_init( "regrouped_with_squad" );
	flag_init( "base_echo_wave_player" );
	flag_init( "vignette_base_echo_rocket_reveal" );
}

//ec_turret sfx
ec_turret_sfx()
{
	soundorg = Spawn( "sound_emitter", ( 55996, 81590, 3106 ) );
	level endon( "stop_turret_outdoor_sfx" ); 
	while(1)
	{
	soundorg PlaySound( "emt_rocket_turret_outdoor" );
	wait( RandomFloatRange( 2.0, 6.0 ));
	}
}

objective_follow( enable )
{
	wait 2.0;
	if( enable )
	{
		Objective_State( obj( "OBJ_FIND_BAKER" ), "current" );
		Objective_SetPointerTextOverride( obj( "OBJ_FIND_BAKER" ), &"NX_ROCKET_FOLLOW_MARKER" );
		Objective_OnEntity( obj( "OBJ_FIND_BAKER" ), level.squad[ "ALLY_WILLIAMS" ], (0, 0, 90) );
	}
	else
	{
		Objective_State( obj( "OBJ_FIND_BAKER" ), "invisible" );
	}
}

