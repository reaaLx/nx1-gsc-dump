//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module: Border, Market												**
//                                                                          **
//    Created: 11/11/11 - Travis Chen (trchen x 4143)						**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_anim;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
	// turn off color triggers
	trigs = GetEntArray( "trig_off", "script_noteworthy" );
	array_thread( trigs, ::trigger_off );
	
	// setup enemy spawners
	w1_spawners = GetEntArray( "mkt_spawner", "script_noteworthy" );
	array_thread( w1_spawners, ::add_spawn_function, ::mkt_enemy_func );
	
	// setup flood trigs
	trigs = GetEntArray( "trig_spawn_flood", "script_noteworthy" );
	foreach( trig in trigs )
		thread maps\_spawner::flood_trigger_think( trig );
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
	flag_init( "flag_mkt_intro" );
	flag_init( "flag_vo_ai_intro_take_cover" );
	flag_init( "flag_mkt_killed_intro" );
	flag_init( "flag_mkt_center" );
	flag_init( "flag_mkt_center_backup" );
	flag_init( "flag_mkt_player_outside" );
	flag_init( "flag_mkt_center_retreat" );
	flag_init( "flag_mkt_side" );
	flag_init( "flag_mkt_side_retreat" );
	flag_init( "flag_mkt_high" );
	flag_init( "flag_mkt_high_retreat" );
	flag_init( "flag_mkt_player_to_stairs" );
	flag_init( "flag_mkt_run_to_finale" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_objectives( objective_num )
{
	return objective_num;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

market_start()
{
	maps\nx_border_util::player_start( "player_start_market" );
	
	ally_starts = getstructarray( "ally_start_market", "targetname" );
	maps\nx_border_util::spawn_allies( ally_starts );
	
	// Disable air drop
	level notify( "trigger_terminate_helicopter_support" );
}

market()
{
	flag_wait( "flag_mkt_intro" );
	autosave_by_name( "border_market_save_start" );
	// IPrintLnBold( "Market Intro start" );
	
	// Market Intro
	thread mkt_setup();
	thread mkt_intro();

	Exploder( "fx_market_smoke" );
	
	// Center or Backup
	thread mkt_center();
	thread mkt_center_backup();
	
	// Center Retreat
	flag_wait( "flag_mkt_center_retreat" );
	thread mkt_center_retreat();
	// IPrintLnBold( "center retreat" );
	
	// Side (player needs to be outside)
	flag_wait( "flag_mkt_side" );
	autosave_by_name( "border_market_save_side" );
	thread mkt_side();
	// IPrintLnBold( "side start" );
	
	// Side Retreat
	flag_wait( "flag_mkt_side_retreat" );
	thread mkt_side_retreat();
	// IPrintLnBold( "side retreat" );
	
	// High
	flag_wait( "flag_mkt_high" );
	thread mkt_high();
	// IPrintLnBold( "high start" );
	
	// High Retreat
	flag_wait( "flag_mkt_high_retreat" );
	thread mkt_high_retreat();
	// IPrintLnBold( "high retreat" );
	
	flag_wait( "flag_mkt_run_to_finale" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

mkt_setup()
{
	// Turn off Helicopter Support. Brian, we need to figure out if 
	// you want to use the support functionality for this encounter
	level._player notify( "terminate_helicopter_support" );
	
	// let 2 allies die
	allies = GetAIArray( "allies" );
	red = 2;
	yellow = 1;
	foreach( ally in allies )
	{
		if( ally != level.leader )
		{
			if( !IsDefined( ally.script_forcecolor ) )
			{
				ally disable_replace_on_death();
				ally.health = 1;
				ally.threatbias = 7500;
			}
			else if( yellow > 0 && ally.script_forcecolor == "y" )
			{
				yellow -= 1;
			}
			else if( red > 0 && ally.script_forcecolor == "r" )
			{
				red -= 1;
			}
			else
			{
				ally disable_replace_on_death();
				ally.health = 1;
				ally.threatbias = 10000;
			}
		}
	}
}

mkt_intro()
{
	level endon( "flag_mkt_center_backup" );
	
	// shoot into the window
	wait( 0.6 );
	enemies = get_ai_group_ai( "mkt_baddies" );
	targets = getstructarray( "mkt_building_shoot_targets", "targetname" );
	array_thread( enemies, ::mkt_ai_shoot_loop, targets );
	
	// yell warning
	wait( 0.3 );
	level.leader thread dialogue_queue( "bor_bak_market_enemiesinmarket" );	
	
	// break window
	wait( 0.1 );
	window = GetGlass( "mkt_window_1" );
	DestroyGlass( window, (-441, -284, 88) );
	
	wait_flag_or_time( "flag_mkt_killed_intro", 8 );
	flag_set( "flag_mkt_center" );
}

mkt_center()
{
	level endon( "flag_mkt_center_backup" );
	flag_wait( "flag_mkt_center" );
	
	// retreat enemies
	mkt_vol_retreat( "mkt_baddies", "vol_mkt_center" );
	
	// advance allies
	wait( 2 );
	trig = GetEnt( "color_mkt_center", "targetname" );
	if( IsDefined( trig ) )
		trig notify( "trigger" );
	
	thread wait_for_retreat( 3, "flag_mkt_center_backup" );
}

mkt_center_backup()
{
	level endon( "flag_mkt_center_retreat" );
	flag_wait( "flag_mkt_center_backup" );
	
	// retreat enemies
	mkt_vol_retreat( "mkt_baddies", "vol_mkt_center_backup" );
	
	spawners = GetEntArray( "mkt_bad_center", "targetname" );
	foreach( spawner in spawners )
		spawner.script_goalvolume = "vol_mkt_center_backup";
	
	// get retreat enemies ready
	thread mkt_center_spawn_retreat();
	
	wait( 2 );
	// advance allies
	trig = GetEnt( "color_mkt_center_backup", "targetname" );
	if( IsDefined( trig ) )
		trig notify( "trigger" );
	
	// nag - if inside
	if( flag( "flag_vo_player_inside" ) )
	level.leader dialogue_queue( "bor_bak_market_moveup" );
	
	// nag loop - go outside
	while( !flag( "flag_mkt_player_outside" ) )
	{
		//for now, to make the randomness better, just gonna use the randomness in a single alias
		level.leader dialogue_queue( "bor_bak_nag_market" );
		wait_flag_or_time( "flag_mkt_player_outside", 10, 15 );
	}
	
	// turn off center flood spawn
	trig = GetEnt( "trig_stop_center_flood", "targetname" );
	if( IsDefined( trig ) )
		trig notify( "trigger" );
}

mkt_center_spawn_retreat()
{
	wait_flag_or_time( "flag_mkt_player_outside", 7, 8 );
	spawn_targetname( "mkt_bad_center_retreat" );
}

mkt_center_retreat()
{
	// turn off center flood spawn
	trig = GetEnt( "trig_stop_center_flood", "targetname" );
	if( IsDefined( trig ) )
		trig notify( "trigger" );
	
	// retreat enemies and set health to 1
	mkt_vol_retreat( "mkt_baddies", "vol_mkt_center_retreat", true );
	
	// spawn retreating enemies
	trig = GetEnt( "trig_spawn_center_retreat_flood", "targetname" );
	trig notify( "trigger" );
	
	// get side fight ready
	// wait( 1 );
	// thread wait_for_retreat( 3, "flag_mkt_side" );
}

mkt_side()
{
	level endon( "flag_mkt_side_retreat" );
	level endon( "flag_mkt_run_to_finale" );
        radio_dialogue( "bor_oly_market_cartelchopper" );
	
	// retreat enemies and set health to 1
	mkt_vol_retreat( "mkt_baddies", "vol_mkt_side", true );
	
	// change goalvol of center retreat flood
	spawners = GetEntArray( "mkt_bad_center_retreat_flood", "targetname" );
	foreach( spawner in spawners )
		spawner.script_goalvolume = "vol_mkt_side";
	
	// spawn side enemies
	trig = GetEnt( "trig_spawn_side", "targetname" );
	trig notify( "trigger" );
	
	// spawn side rockets
	thread spawn_targetname( "mkt_bad_side_rockets" );
	
	wait( 2.5 );
	issue_color_orders( "y304  r304", "allies" );
	
	thread wait_for_retreat( 3, "flag_mkt_side_retreat" );
}

mkt_side_retreat()
{
	level endon( "flag_mkt_high" );
	level endon( "flag_mkt_run_to_finale" );
	
	// turn off side flood spawn
	trig = GetEnt( "trig_stop_side_flood", "targetname" );
	if( IsDefined( trig ) )
		trig notify( "trigger" );
	
	// retreat enemies
	mkt_vol_retreat( "mkt_baddies", "vol_mkt_side_retreat" );
	
	// spawn reinforcements
	spawn_targetname( "mkt_bad_side_retreat" );
	
	wait( 2.5 );
	issue_color_orders( "y305  r305", "allies" );
	
	thread wait_for_retreat( 4, "flag_mkt_high" );
}

mkt_high()
{
	level endon( "flag_mkt_high_retreat" );
	level endon( "flag_mkt_run_to_finale" );
	
	// retreat enemies
	mkt_vol_retreat( "mkt_baddies", "vol_mkt_high" );
	
	wait( 2 );
	issue_color_orders( "y306  r306", "allies" );
	
	thread wait_for_retreat( 2, "flag_mkt_high_retreat" );
}

mkt_high_retreat()
{
	// retreat enemies
	mkt_vol_retreat( "mkt_baddies", "vol_mkt_high_retreat", true );
	mkt_vol_retreat( "mkt_high_baddies", "vol_mkt_high_retreat" );
	
	// get ready to move allies
	flag_wait( "flag_mkt_player_to_stairs" );
	
	// turn off other color trigs
	trig = GetEnt( "color_mkt_center_retreat", "targetname" );
	trig trigger_off();
	trig = GetEnt( "color_mkt_center_retreat_alt", "targetname" );
	trig trigger_off();
	trig = GetEnt( "color_mkt_side", "targetname" );
	trig trigger_off();
	trig = GetEnt( "color_mkt_side_yellow", "targetname" );
	trig trigger_off();
	trig = GetEnt( "color_mkt_side_retreat", "targetname" );
	trig trigger_off();
	trig = GetEnt( "color_mkt_side_retreat_alt", "targetname" );
	trig trigger_off();
	trig = GetEnt( "color_mkt_high", "targetname" );
	trig trigger_off();
	trig = GetEnt( "color_mkt_high_retreat", "targetname" );
	trig trigger_off();
	
	// move on to final battle
	wait( 0.1 );
	flag_set( "flag_mkt_run_to_finale" );
	
	wait( 1 );

	level.leader thread dialogue_queue( "bor_bak_nag_pushchurch" );

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
wait_for_retreat( baddies, flag )
{
	// loop till target number is reached
	while( get_ai_group_sentient_count( "mkt_baddies" ) > baddies )
		level waittill( "mkt_death" );
	
	flag_set( flag );
}

mkt_vol_retreat( group_name, vol_name, is_weak, trig_name )
{
	level endon( "mkt_clear_retreats" );
	
	if( !IsDefined( is_weak ) )
		is_weak = false;
	
	if( IsDefined( trig_name ) )
	{
		trig = GetEnt( trig_name, "targetname" );
		trig waittill( "trigger" );
	}
	
	// retreat enemies
	ai_group = get_ai_group_ai( group_name );
	new_vol = GetEnt( vol_name, "targetname" );
	
	foreach( guy in ai_group )
	{
		guy SetGoalVolumeAuto( new_vol );
		if( is_weak )
			guy.health = 1;
	}
}

reinforce_group( spawn_name, group_name, num, is_flood_fill, color_order)
{
	// init vars
	if( !IsDefined( is_flood_fill ) )
		is_flood_fill = false;
	
	// get sapwners
	spawners = GetEntArray( spawn_name, "targetname" );
	
	if( is_flood_fill )
		array_thread( spawners, maps\_spawner::flood_spawner_think );
	
	// spawn enemies
	for( i = get_ai_group_sentient_count( group_name ); i < num; i++)
		spawners[i] spawn_ai();
	
	// issue color orders
	if( IsDefined( color_order ) )
		issue_color_orders( color_order, "axis" );
}

mkt_special_spawn( trig_name, clear_specials )
{
	if( !IsDefined( clear_specials ) )
		clear_specials = false;
	
	trig = GetEnt( trig_name, "targetname" );
	trig trigger_on();
	
	self thread mkt_special_spawn_proc( clear_specials );
	
	level waittill( "mkt_clear_specials" );
	trig trigger_off();
}

mkt_special_spawn_proc( clear_specials )
{
	self waittill( "trigger" );
	self trigger_off();
	
	if( clear_specials )
		level notify( "mkt_clear_specials" );
}

mkt_trig_notify( note )
{
	self waittill( "trigger" );
	
	// send notifications
	targets = getEntArray( self.target, "targetname" );
	foreach( target in targets )
		target notify( note );
	
	self Delete();
}

mkt_trig_retreat( group_name )
{
	self waittill( "trigger" );
	
	if( !IsDefined( group_name ) )
		group_name = "mkt_baddies";
	
	// retreat enemies
	ai_group = get_ai_group_ai( group_name );
	new_vol = GetEnt( self.target, "targetname" );
	
	foreach( guy in ai_group )
		guy SetGoalVolumeAuto( new_vol );
	
	self Delete();
}

wait_flag_or_time( flag_name, min_time, max_time )
{
	level endon( flag_name );
	
	if( !IsDefined( max_time ) )
		max_time = min_time + 0.1;
	
	wait( RandomFloatRange( min_time, max_time ) );
}

radio_rand_dialog( dialogs )
{
	num = RandomIntRange( 0, dialogs.size - 1 );
	radio_dialogue( dialogs[ num ] );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
mkt_enemy_func()
{
	self.goalradius = 512;
	self waittill ( "death" );
	
	level notify( "mkt_death" );
}

mkt_enemy_stop_ignoreall()
{
	if( self.ignoreall )
		self waittill( "reached_path_end" );
	
	self set_ignoreall( false );
}

mkt_ai_shoot_loop( targets )
{
	level endon( "mkt_ai_stop_shooting" );
	self endon( "death" );
	
	wait( RandomFloat( 0.3 ) );
	while( 1 )
	{
		rand = RandomIntRange( 0, targets.size - 1 );
		MagicBullet( "ak47", self.origin + (0, 0, 24), targets[ rand ].origin );
		
		wait( RandomFloatRange( 0.3, 0.7 ) );
	}
}

spawn_enemy_vehicle( veh_name, tVehicle, flag_name )
{
	// Grab vehicle spawner
	vehicle = GetEnt( tVehicle, "targetname" );
	Assert( IsDefined( vehicle ));
	Assert( IsDefined( vehicle.target ));

	// Grab rider spawners
	targets = GetEntArray( vehicle.target, "targetname" );
	Assert( IsDefined( targets ));

	// Spawn and drive
	level.enemy_vehicles[ veh_name ] = vehicle spawn_vehicle_and_gopath();
	level.enemy_vehicles[ veh_name ] waittill( "reached_end_node" );	
	
	if( IsDefined( flag_name ) )
		flag_set( flag_name );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************