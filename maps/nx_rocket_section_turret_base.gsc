
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
#include maps\_casual_killer;

//*******************************************************************
//                                                                  *
//*******************************************************************
start()
{
	// Turn off AA turret section smoke
	maps\nx_rocket_util::pre_turret_event();

	teleport_info = [];
	teleport_info[ "ALLY_BAKER" ]		= "start_default_ally_00";
	teleport_info[ "ALLY_JENKINS" ]		= "start_turret_base_ally_01";
	teleport_info[ "ALLY_WILLIAMS" ]	= "start_turret_base_ally_02";
	maps\nx_rocket_util::squad_teleport( teleport_info );
	level._player maps\_nx_utility::move_player_to_start_point( "start_turret_base_player" );
}

main()
{
	//ambience
	thread maps\_utility::set_ambient( "nx_rocket_ext" );

	// SAVE POINT
	level thread autosave_now();

	flag_set( "discovered_aa_base" );

	issue_color_orders( "p31 b31", "allies" );

	level thread objective_follow();

	flag_wait( "turret_base_discover" );

	// EXTERIOR ENEMIES
	enemies_exterior = maps\nx_rocket_util::spawn_ai_group( "turret_base_enemy_01", "script_noteworthy" );
	array_thread( enemies_exterior, maps\nx_rocket_util::ignore_until_damage_group, enemies_exterior );
	array_thread( enemies_exterior, maps\nx_rocket_util::ignore_until_flag, "turret_base_alert" );
	array_thread( enemies_exterior, ::on_damage_alert );
//  enemies_exterior = array_removedead( enemies_exterior );
//  array_thread( enemies_exterior, ::enable_casual_killer_until_damage );
//  waittill_dead( enemies_exterior, 2 );
//  waittill_aigroupcleared( "turret_base_enemy_01" );
	flag_wait( "turret_base_alert" );
	issue_color_orders( "b40 p40", "allies" );

	// RUSHING ENEMIES
	enemies_rushing = maps\nx_rocket_util::spawn_ai_group( "turret_base_enemy_02", "script_noteworthy" );

//  vtol = vehicle_spawn( GetEnt( "turret_base_vtol", "targetname" ) );
//  vtol thread vtol_update();

	enemies_rushing = array_removedead( enemies_rushing );
	waittill_dead( enemies_rushing, enemies_rushing.size - 2 );
	issue_color_orders( "b45 p45", "allies" );

	waittill_aigroupcleared( "turret_base_enemy_03" );
	issue_color_orders( "b60 p60", "allies" );

	waittill_aigroupcleared( "turret_base_enemy_04" );
	issue_color_orders( "b70 p70", "allies" );

	// SAVE POINT
	level thread autosave_now();

	thread ec_turret_indoor_sfx();


//  issue_color_orders( "b102 p102", "allies" );
	flag_wait( "turret_control_entered" );

}

objective_follow()
{
	wait 4.0;
	Objective_State( obj( "OBJ_THROUGH_AA_BASE" ), "current" );
	Objective_SetPointerTextOverride( obj("OBJ_THROUGH_AA_BASE"), &"NX_ROCKET_FOLLOW_MARKER" );
	Objective_OnEntity( obj( "OBJ_THROUGH_AA_BASE" ), level.squad[ "ALLY_WILLIAMS" ], (0, 0, 90) );
}

on_damage_alert()
{
	self endon( "death" );
	self waittill( "damage" );
	flag_set( "turret_base_alert" );
}

vtol_update()
{
	self GodOn();
	self GoPath();

	// Turn on spotlight
	self thread maps\_attack_heli::heli_spotlight_on( undefined, true );
	self maps\nx_rocket_util::vehicle_enable_fire( false );

	self waittill( "reached_dynamic_path_end" );
	self thread vtol_search_ents( [ level.squad[ "ALLY_WILLIAMS" ], level.squad[ "ALLY_JENKINS" ], level._player ], "search_done" );

//  self thread maps\nx_rocket_util::vehicle_random_target( false );
	wait 9.0;

	self thread vtol_firing();

	flag_wait( "turret_base_entered" );

	self notify( "search_done" );

	self SetTurretTargetEnt( GetEnt( "turret_base_vtol_target", "targetname" ) );

//  vtol_search_ents( level.squad );
//  self maps\nx_rocket_util::vehicle_enable_fire( true );

}

vtol_search( end_on )
{
	self endon( end_on );
	self endon( "death" );

	target = spawn( "script_origin", self.origin - 4000 );

	self SetTurretTargetEnt( target );

	while( 1 )
	{
		target MoveTo( level._player.origin + random_vector( 500 ), RandomFloatRange( 1.0, 3.0 ) );
		target waittill( "movedone" );
		wait 0.05;
	}
}

vtol_search_ents( ents, end_on )
{
	if( IsDefined( end_on ) )
		self endon( end_on );

	self endon( "death" );

	while( 1 )
	{
		self SetTurretTargetEnt( random( ents ) );
		wait  RandomFloatRange( 1.0, 3.0 );
	}
}

vtol_firing()
{
	self endon( "death" );

	enable = false;

	while( 1 )
	{
		enable = !enable;
		self maps\nx_rocket_util::vehicle_enable_fire( enable );
		if(enable)
			wait RandomFloatRange( 1.0, 2.0 );
		else
			wait RandomFloatRange( 3.0, 5.0 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

enable_casual_killer_until_damage()
{
	self endon( "death" );
	self enable_casual_killer( );
	self waittill( "damage" );
	self disable_casual_killer( );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


ec_turret_indoor_sfx()
{
	soundorg = Spawn( "sound_emitter", ( 56397, 82116, 163 ) );
	level notify( "stop_turret_outdoor_sfx" );
	level endon( "stop_turret_indoor_sfx" ); 
	while(1)
	{
	soundorg PlaySound( "emt_rocket_turret_indoor" );
	wait( RandomFloatRange( 2.0, 7.0 ));
	}
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
	flag_init( "discovered_aa_base" );
	flag_init( "turret_control_entered" );
}
