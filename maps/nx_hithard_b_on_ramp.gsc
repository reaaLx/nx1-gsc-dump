

//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  nx_hithard_b_on_ramp.gsc					   					**
//				NOTE: called from nx_hithard_b.gsc							**
//                                                                          **
//    Created: 3/17/2011 - Pedram Javidpour 								**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\nx_hithard_b_util;

AI_BAKER			= 0;
AI_DUKE				= 1;
AI_VP				= 2;
AI_SS1				= 3;
AI_SS2				= 4;

OBJ_PROTECT_PATRIOT		= 24;
OBJ_ADVANCE				= 25;
OBJ_PROVIDE_OVERWATCH	= 26;
OBJ_MOVE_PATRIOT		= 27;
OBJ_MEET_BRAVO			= 28;

onramp_setup()
{
	triggers_enable( "trigger_encounter_01", false );
	triggers_enable( "trigger_encounter_02", false );
	triggers_enable( "trigger_encounter_03", false );
	triggers_enable( "trigger_moment_bravo", false );

	player_zone_enable( "player_zone_street", false );
	player_zone_enable( "player_zone_onramp", false );


//  triggers_enable( "onramp_enc_02_begin", false );

	maps\nx_hithard_b_util::vtol_setup( "vtol_onramp_enc_secure_troops", "vtol_onramp_enc_secure_troops", "onramp_vtol_enter_01", "onramp_vtol_exit_01" );
	maps\nx_hithard_b_util::vtol_setup( "vtol_onramp_enc_final_01", "vtol_onramp_enc_final", "onramp_vtol_enter_02", "onramp_vtol_exit_02" );
	maps\nx_hithard_b_util::vtol_setup( "vtol_onramp_enc_final_02", "vtol_onramp_enc_final", "onramp_vtol_enter_03", "onramp_vtol_exit_03" );
//  maps\nx_hithard_b_util::vtol_setup( "vtol_onramp_enc_final_02", "vtol_onramp_enc_final", "onramp_vtol_enter_04", "onramp_vtol_exit_04" );

	if( !IsDefined( level.onramp_enemies ) )
		level.onramp_enemies = [];
	enemy_group_init( "onramp_enc_final_freeway" );
	enemy_group_init( "onramp_enc_final_street" );
	enemy_group_init( "onramp_enc_final_bus" );
	enemy_group_init( "onramp_enc_final_vtol" );
	enemy_group_init( "onramp_enc_final_rpg" );
	enemy_group_init( "onramp_enc_final_ugv" );	

	level thread maps\nx_hithard_b_anim::tank_lapes_setup( );

	level.onramp_vp_rescued = false;
}

onramp_section_started()
{
	trigger_off( "trigger_encounter_00", "script_noteworthy" );
}

onramp_main()
{
	onramp_setup();

	level thread onramp_enter_trigger();

	onramp_encounter_street();
	onramp_encounter_secure();
	onramp_encounter_overwatch();
}


onramp_enter_trigger()
{
	trigger_wait( "trigger_encounter_00", "script_noteworthy" );

	onramp_section_started();

	iPrintLnBold( "Head to the onramp" );
	level.squad[ AI_BAKER ] SetGoalNode( GetNode( "node_onramp_ally_01", "script_noteworthy" ) );
	level.squad[ AI_DUKE ] 	SetGoalNode( GetNode( "node_onramp_ally_02", "script_noteworthy" ) );
	level.squad[ AI_VP ] 	SetGoalNode( GetNode( "node_onramp_ally_vp_price", "script_noteworthy" ) );
	level.squad[ AI_SS1 ] 	SetGoalNode( GetNode( "node_onramp_ally_ss_walker", "script_noteworthy" ) );
	level.squad[ AI_SS2 ] 	SetGoalNode( GetNode( "node_onramp_ally_ss_hayes", "script_noteworthy" ) );
}

onramp_encounter_street()
{
	Objective_Add( OBJ_PROTECT_PATRIOT, "current", "Escort Patriot to the highway." );
	Objective_OnEntity( OBJ_PROTECT_PATRIOT, level.squad[ AI_VP ], ( 0, 0, 70 ) );
	Objective_SetPointerTextOverride( OBJ_PROTECT_PATRIOT, "Protect" );

	// Enable triggers for this encounter
	triggers_enable( "trigger_encounter_01", true );
	player_zone_enable( "player_zone_street", true );

	// Start dialogue for this encounter
	level thread onramp_encounter_street_dialogue();

	// Wait for first wave to spawn
	trigger_wait( "onramp_enc_01_wave_01", "targetname" );
	issue_color_orders( "c0", "axis" );

	level.squad[ AI_SS1 ] thread ss1_kill();

	vp_protect_node = GetNode( "onramp_enc_01_vp_protect", "targetname" );
	vp_protect_node thread vp_protect_at_node( level.squad[ AI_VP ], level.squad[ AI_SS2 ] );

	waittill_aigroupcount( "onramp_enc_01_wave_01", 3 );
	enemy_wave_spawn( "onramp_enc_01_wave_02" );
	issue_color_orders( "c1", "axis" );
	issue_color_orders( "y0", "axis" );

	waittill_aigroupcleared( "onramp_enc_01_wave_01" );
	waittill_aigroupcleared( "onramp_enc_01_wave_02" );

	autosave_now();

	triggers_enable( "trigger_encounter_01", false );

	vp_protect_node vp_protect_end( );
	wait 0.1;
	level.squad[ AI_VP ] set_force_color("p");
	level.squad[ AI_SS2 ] set_force_color("r");
	level.squad[ AI_BAKER ] SetGoalNode( GetNode( "onramp_advance_ally01", "targetname" ) );
	level.squad[ AI_DUKE ]	SetGoalNode( GetNode( "onramp_advance_ally02", "targetname" ) );

	player_zone_enable( "player_zone_street", false );
}

onramp_encounter_secure()
{
	Objective_Add( OBJ_ADVANCE, "current", "Advance to the onramp" );
	Objective_Position( OBJ_ADVANCE, GetEnt( "onramp_objective_advance", "targetname" ).origin );

//  autosave_now();
	// Enable triggers for this encounter
	triggers_enable( "trigger_encounter_02", true );
	// Start dialogue for this encounter
	level thread onramp_encounter_secure_dialogue();

	// Wait for player to enter encounter space
	activate_trigger( "onramp_enc_02_allies_trigger", "targetname" );

	vp_protect_node = GetEnt( "onramp_enc_02_vp_protect", "targetname" );
	vp_protect_node thread vp_protect_at_node( level.squad[ AI_VP ], level.squad[ AI_SS2 ] );

	trigger_wait( "onramp_enc_secure_begin", "targetname" );
//  waittill_aigroupcount( "onramp_enc_02_wave_02", 1 );

	vtol_01 = maps\nx_hithard_b_util::vtol_spawn( "vtol_onramp_enc_secure_troops" );
	vtol_01 thread maps\nx_hithard_b_util::vtol_move( false, 0.2 );
	vtol_01.ignoreMe = true;

	wait 8.0;

	Objective_State( OBJ_ADVANCE , "done" );
	autosave_now();

	triggers_enable( "trigger_encounter_02", false );
	level notify( "overwatch_command" );
}

onramp_encounter_overwatch()
{
	Objective_Add( OBJ_PROVIDE_OVERWATCH, "current", "Provide overwatch." );
	Objective_Position( OBJ_PROVIDE_OVERWATCH, GetEnt( "onramp_objective_overwatch", "targetname" ).origin );

	// Enable triggers for this encounter
	triggers_enable( "trigger_encounter_03", true );
	// Start dialogue for this encounter
	level thread onramp_encounter_overwatch_dialogue();

	// Send Duke to his cover
	level.squad[ AI_DUKE ] thread duke_provide_overwatch();

	// Wait for player to enter encounter space
	trigger_wait( "onramp_overwatch_begin", "targetname" );
	level notify( "end_overwatch_reminder" );
	autosave_now();	
}

onramp_moment_vphit()
{
	triggers_enable( "trigger_encounter_03", true );
	player_zone_enable( "player_zone_onramp", true );

	level thread onramp_cover_pieces();

	// VP cross and hit
	level notify( "overwatch_provided" );
	vp_protect_node = GetEnt( "onramp_enc_02_vp_protect", "targetname" );
	vp_protect_node vp_protect_end();
	level thread vignette_vp_hit();
	level waittill( "vp_hit_moment" );
	level thread vp_rpg_attack();
	
	wait 2.0;

	level thread uav_spawn( "onramp_freeway_uav", "onramp_uav_circle_path" );
	level thread smoke_spawn( "onramp_smoke_freeway" );
	level thread smoke_spawn( "onramp_smoke_street" );
	wait 0.5;

//	MAIN WAVE
	enemy_wave_spawn( "onramp_enc_final_freeway" );
	wait 3.0;
	enemy_wave_spawn( "onramp_enc_final_street" );
	level thread enemy_group_watch( "onramp_enc_final_freeway", 3, 1, "onramp_battle_end" );
	level thread enemy_group_watch( "onramp_enc_final_street", 3, 1, "onramp_battle_end" );
	autosave_now();

//	VTOL WAVE
	wait 20.0;
	level notify( "onramp_cover_destruct_01" );
	autosave_now();
	iPrintlnBold("Incoming VTOL!!!");
	vtol_01 = vtol_deploy( "vtol_onramp_enc_final_02" );
	vtol_01 waittill( "exiting" );
	issue_color_orders( "o200", "axis" );
	waittill_enemy_group_count( "onramp_enc_final_vtol", 2 );

//  RPGer
	wait 15.0;
	level notify( "onramp_cover_destruct_02" );
	autosave_now();
	iPrintlnBold("RPG!");
	enemy_wave_spawn( "onramp_enc_final_rpg" );
	autosave_now();

//  UAV Wave
	wait 8.0;
	level notify( "onramp_cover_destruct_03" );
	autosave_now();
	iPrintlnBold("UAVs!!!");
	level thread uav_spawn( "onramp_swarm_uav", "onramp_uav_circle_path" );
	level thread uav_spawn( "onramp_street_uav", "onramp_uav_circle_path" );

// UGV Enter
	level thread ugv_encounter();

//	VTOL WAVE
	iPrintlnBold("Another VTOL!");
	vtol_02 = vtol_deploy( "vtol_onramp_enc_final_01" );
	vtol_02 waittill( "exiting" );
	issue_color_orders( "o200", "axis" );
	waittill_enemy_group_count( "onramp_enc_final_vtol", 2 );
	smoke_end( "onramp_smoke_street" );
	smoke_end( "onramp_smoke_freeway" );

//	UGV IS CLOSING IN. WE NEED TO GET OUT
	flag_wait( "onramp_ugv_critical" );
	level notify( "onramp_cover_destruct_04" );
	autosave_now();

	Objective_State( OBJ_PROVIDE_OVERWATCH , "done" );
	autosave_now();
	level thread vp_drag_interactive();

	bravo_vehicle_spawn();

	level.onramp_bravo[ 0 ] godOn();
	level.onramp_bravo[ 1 ] godOn();
	level.onramp_bravo[ 0 ] GoPath();
	level.onramp_bravo[ 1 ] GoPath();
	level.onramp_bravo[ 0 ] waittill( "reached_end_node" );
	level.onramp_bravo[ 1 ] waittill( "reached_end_node" );

	level waittill( "bravo_rescue" );
	player_zone_enable( "player_zone_onramp", false );

	level notify( "onramp_battle_end" );
	all_enemies = GetAIArray( "axis" );
	bravo_hit_nodes = GetEntArray( "ugv_target", "targetname" );
	foreach( enemy in all_enemies )
	{
		if( !IsDefined( enemy ) )
			continue;

		MagicBullet( "rpg_straight", enemy.origin, level.onramp_bravo[ 0 ].origin + (0, 0, 100) );
		enemy Kill();
		PlayFX( level._effect["vehicle_explosion_hummer"], random( bravo_hit_nodes ).origin );
		wait 0.2;
	}

	autosave_now();
}

onramp_moment_bravo()
{
	triggers_enable( "trigger_moment_bravo", true );
	level thread bravo_meetup( );
}

onramp_moment_bravo_debug()
{
	level.squad[ AI_SS1 ] thread ss1_kill();
	level.squad[ AI_SS2 ] thread ss1_kill();
	level thread maps\nx_hithard_b_anim::vpdrag_end_vp( level.squad[ AI_VP ] );

	bravo_vehicle_spawn();
	bravo_01_end = GetVehicleNode( "bravo_01_end", "targetname" );
	bravo_02_end = GetVehicleNode( "bravo_02_end", "targetname" );
	level.onramp_bravo[ 0 ] Vehicle_Teleport( bravo_01_end.origin, bravo_01_end.angles );
	level.onramp_bravo[ 1 ] Vehicle_Teleport( bravo_02_end.origin, bravo_02_end.angles );
}


onramp_cover_pieces()
{
	self thread onramp_cover_piece_force( "onramp_cover_destruct_00", false );
	self thread onramp_cover_piece_force( "onramp_cover_destruct_01" );
	self thread onramp_cover_piece_force( "onramp_cover_destruct_02" );
	self thread onramp_cover_piece_force( "onramp_cover_destruct_03" );
	self thread onramp_cover_piece_force( "onramp_cover_destruct_04" );
}

onramp_cover_piece_force( script_noteworthy, shot, force_entity )
{
	level waittill( script_noteworthy );

	if( !IsDefined( shot ) )
		shot = true;

	pieces = GetEntArray( script_noteworthy, "script_noteworthy" );

	foreach( piece in pieces )
	{
//  	mag = ( RandomFloatRange( 1000, 2000 ), RandomFloatRange( 1000, 2000 ), RandomFloatRange( 5000, 10000 ) );
		mag = RandomFloatRange( 5000, 7000 );

		if( shot )
			MagicBullet( "xm108_asco", piece.origin, piece.origin );

		if( IsDefined( force_entity ) )
			force = VectorNormalize( force_entity.origin - piece.origin );
		else
			force = ( cos( piece.angles[1] ), sin( piece.angles[1] ), 1 );

		force *= mag;//( mag[0] * cos( piece.angles[1] ), mag[1] * sin( piece.angles[1] ), mag[2] );

		piece PhysicsLaunchClient( piece.origin, force );

		if( shot )
			wait RandomFloatRange( 0.5, 1.5 );
	}
}


// BRAVO STUFF
bravo_vehicle_spawn()
{
	if( !IsDefined( level.onramp_bravo ) )
	{
		level.onramp_bravo[ 0 ]  = vehicle_spawn( GetEnt( "bravo_01", "script_noteworthy" ) );
		level.onramp_bravo[ 1 ]  = vehicle_spawn( GetEnt( "bravo_02", "script_noteworthy" ) );
	}
}

bravo_meetup( )
{
	// Send Bravo to meet 
	level.onramp_bravo[ 0 ] StartPath( GetVehicleNode( "bravo_01_end", "targetname" ) );
	level.onramp_bravo[ 1 ] StartPath( GetVehicleNode( "bravo_02_end", "targetname" ) );

	// Send Duke to meet
	level thread maps\nx_hithard_b_anim::bravomeetgreet_duke_reach( level.squad[ AI_DUKE ] );
	level.onramp_bravo[ 0 ] waittill( "reached_end_node" );
	autosave_now();
	bravo_co = GetEnt( "bravo_co", "targetname" ) spawn_ai( true );
	unlatcher_01 = GetEnt( "onramp_lapes_unlatcher_01", "targetname" ) spawn_ai( true );
	unlatcher_02 = GetEnt( "onramp_lapes_unlatcher_02", "targetname" ) spawn_ai( true );
	level thread maps\nx_hithard_b_anim::bravomeetgreet( bravo_co, level.squad[ AI_DUKE ] );

	// Wait for player to meet up
	end_trigger = GetEnt( "level_end", "targetname" );
	Objective_State( OBJ_PROTECT_PATRIOT , "done" );
	Objective_Add( OBJ_MEET_BRAVO, "current", "Meet Bravo Company at the top of the on-ramp." );
	Objective_Position( OBJ_MEET_BRAVO, GetEnt( "onramp_objective_bravo", "targetname" ).origin );
	trigger_wait( "level_end", "targetname" );
	Objective_State( OBJ_MEET_BRAVO , "done" );
	triggers_enable( "trigger_encounter_03", false );
//  level notify( "player_meet_bravo" );

	// Drop the tank
	wait 10.0;
	bravo_tank = vehicle_spawn( GetEnt( "bravo_tank", "targetname" ) );
	maps\nx_hithard_b_anim::new_tank_lapes( bravo_tank );
//  tank_climb( bravo_tank );

	maps\nx_hithard_b_anim::lapes_unlatch( unlatcher_01, unlatcher_02 );

	wait 3.0;
	nextmission();
}

ignore_all_triggers()
{
	self endon( "death" );
	self endon( "delete" );
	while( 1 )
	{
		self ignore_triggers();
		wait 0.05;
	}
}

onramp_enc_02_begin()
{
//  flag_wait( "onramp_enc_02_begin" );

//  trigger_wait( "onramp_enc_02_begin", "script_noteworthy" );

	// Wave 1
	
	wait 4.0;
	radio_dialogue( "hithard_bak_mall_09"); // Take ‘em down quick!
}

tank_climb( tank )
{
	tank.animname = "bravo_tank";

	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player disableweapons();
	level._player takeallweapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["bravo_tank"] = tank;
	guys["player_rig"] = player_rig;

	arc = 15;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	player_rig LinkTo( tank, "TAG_PLAYER_TANK_MOUNT" );
	tank anim_single( guys, "tank_climb", "TAG_PLAYER_TANK_MOUNT" );

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
}

onramp_encounter_street_dialogue()
{
	trigger_wait( "onramp_enc_street_vo", "targetname" );	
	radio_dialogue( "hithard_gyp_highway_01" );	// Home stretch, fellas.  I can see the highway…hundred meters
	radio_dialogue( "hithard_sslead_highway_01" );	// We’re right behind you.
	radio_dialogue( "hithard_gyp_highway_03" );	//Gotch’yer back!
	trigger_wait( "onramp_enc_01_wave_01", "targetname" );
	radio_dialogue( "hithard_bak_para_20" ); //Tangos ahead.
}

onramp_encounter_secure_dialogue()
{
	radio_dialogue( "hithard_bak_move_07"); //Clear! Move forward!


	// Provide overwatch
	level waittill( "overwatch_command" );
	//Duke and Specter - get to the onramp and cover us!
	//Specter - get to the onramp and cover us!
	overwatch_lines = [ "hithard_bak_highway_03", "hithard_bak_highway_04" ];
	radio_dialogue( random( overwatch_lines ) );
	radio_dialogue( "hithard_gyp_plaza2_02"); // On it

//  overwatch_lines[ overwatch_lines.size ] = "hithard_gyp_mall_01";
//  level dialogue_set_repeat( overwatch_lines, 3.0, 6.0, "end_overwatch_reminder" );
}

onramp_encounter_overwatch_dialogue()
{
	level waittill( "onramp_uav_spawn" );
	radio_dialogue( "hithard_bak_secure_37"); //UAVs incoming!

	// Send out the VP
	level waittill( "overwatch_provided" );
	radio_dialogue( "hithard_bak_vphit_06"); //Move Patriot now!
	radio_dialogue( "hithard_bak_vphit_07"); //Specter, cover us! 

	// RPG incoming
	//Incoming! (RPG zipping towards VP)
	//Get down! (RPG zipping towards VP)
	//Look out! (RPG zipping towards VP)
	wait 10.0; // Should be wait till RPG fired...
	rpg_warning_lines = [ "hithard_bak_vphit_09", "hithard_bak_vphit_10" ];
	radio_dialogue( random( rpg_warning_lines ) );

	wait 6.0;
	radio_dialogue( "hithard_gyp_monorail_01"); // Fuck, there’s a lot of ‘em.

	// Help the VP
	level waittill( "vp_critical_moment" );
	radio_dialogue( "hithard_bak_vphit_12"); //Shit! UGVs! Specter, help me get him up!
	wait 3.0;
	//Specter! We've got to move him now! Get over here!
	//Specter! Get over here!
	//He's critical! Get over here!
	vp_help_lines = [ "hithard_bak_vphit_08", "hithard_bak_vphit_13", "hithard_bak_vphit_14" ];
	level dialogue_set_repeat( vp_help_lines, 3.0, 6.0, "vp_drag_moment" );

	wait 2.0;
	radio_dialogue( "hithard_bak_vphit_15"); //Get him up that ramp! We'll cover you!
	wait 4.0;
	radio_dialogue( "hithard_bak_vphit_16"); //Get your ass up Specter - keep moving!
	radio_dialogue( "hithard_gyp_para_03"); //Bastards are everywhere!
	radio_dialogue( "hithard_bak_vphit_01"); //Shit! Where's the cav?

	// Bravo destroys the UGVs
	level waittill( "bravo_rescue" );
	radio_dialogue( "hithard_gyp_highway_02"); //About damn time!
	radio_dialogue( "hithard_bravoradioop_highway_01"); //Convoy 2 Bravo Actual, we’ve got eyes on. Providing support.
	radio_dialogue( "hithard_bak_bravo_01"); //Nice work Specter.
//  radio_dialogue( "hithard_btl_bravo_01"); //You gotta be shittin me. Roger that. We're loading Patriot now. Bravo out.
	radio_dialogue( "hithard_bak_bravo_02"); //I'll help them load the VP. Duke. Specter. Check in with Bravo's C.O.
//  radio_dialogue( "hithard_btl_bravo_02"); //We're on the move!

	// Tank LAPES
	trigger_wait( "level_end", "targetname" );
//  radio_dialogue( "hithard_gyp_bravo_01"); //we need more than APC's
//  radio_dialogue( "hithard_btl_bravo_03"); //No shit.  You'll get it.
	radio_dialogue( "hithard_sis_bravoco_01"); //This is Grizzly. Taking heavy fire. Countermeasure's overloading. We've got one shot at this...
	radio_dialogue( "hithard_sis_bravoco_02"); //This is Grizzly. Releasing package!
	radio_dialogue( "hithard_btl_bravo_06"); //Patriot's loaded up and ready to move.
	radio_dialogue( "hithard_btl_bravo_09"); //Get that armor ready!
	radio_dialogue( "hithard_btl_bravo_07"); //Bravo team, mount up!

}

duke_provide_overwatch()
{
	self thread duke_on_player_overwatch_provided();

	self enable_cqbwalk();
	level endon( "overwatch_provided" );

	self SetGoalNode( GetNode( "onramp_enc_final_duke_01", "targetname" ) );
	self waittill( "goal" );
	wait 4.0;
//  level.squad[ AI_DUKE ] SetGoalNode( GetNode( "onramp_enc_final_duke_02", "targetname" ) );
//  self waittill( "goal" );
//  wait 2.0;
	self duke_goto_overwatch();
}

duke_on_player_overwatch_provided()
{
	level waittill( "overwatch_provided" );
	self duke_goto_overwatch();
}

duke_goto_overwatch()
{
	self SetGoalNode( GetNode( "onramp_enc_final_duke", "targetname" ) );
	self disable_cqbwalk();
}

smoke_spawn( smoke_noteworthy )
{
	smoke_points = GetEntArray( smoke_noteworthy, "script_noteworthy" );
	
	foreach( point in smoke_points )
	{
//  	MagicGrenade( "smoke_grenade_miniuav", point.origin, point.origin + ( 0, 0, 1 ), 0.01 );
		point thread smoke_loop();
		wait RandomFloatRange( 0.25, 0.75 );
	}
}

smoke_end( smoke_noteworthy )
{
	smoke_points = GetEntArray( smoke_noteworthy, "script_noteworthy" );
	
	foreach( point in smoke_points )
	{
		point notify( "smoke_end" );	
	}
}

smoke_loop()
{
	self endon( "smoke_end" );
	while( 1 )
	{	
		PlayFx( level._effect[ "nx_grenade_smoke_5sec" ], self.origin );	
		wait 4.9;
	}
}

uav_spawn( uav_noteworthy, circle_noteworthy )
{
	level notify( "onramp_uav_spawn" );
	spawners = GetEntArray( uav_noteworthy, "script_noteworthy" );
	foreach( spawner in spawners )
	{
		miniuav = spawner maps\_attack_heli::SAV_setup( "pathing" );
		miniuav thread uav_circle( circle_noteworthy );
//  	miniuav thread uav_smoke( );
		miniuav.health = 100;
		wait 0.05;
	}
}

uav_circle( circle_noteworthy )
{
	self waittill( "reached_dynamic_path_end" );
	circles = GetNodeArray( circle_noteworthy, "script_noteworthy" );
	self thread maps\_attack_heli::SAV_switch_to_circling( random(circles).targetname );
}

uav_smoke( )
{
	self endon( "death" );

	numGrenades = 3;

	wait 2.0;
	for( i = 0; i < numGrenades; i++ )
	{
		PlayFx( level._effect[ "nx_grenade_smoke_5sec" ], self.origin );	
		wait RandomFloatRange( 0.25, 0.75 );
	}
}

// ENEMY WAVE FUNCTIONS //
enemy_group_watch( enemy_group, watch_count, spawn_count, watch_end_on )
{
	self endon( watch_end_on );

	while( 1 )
	{
//  	waittill_aigroupcount( enemy_group, watch_count );
		waittill_enemy_group_count( enemy_group, watch_count );
		enemy_wave_spawn( enemy_group, spawn_count );
	}
	
}

waittill_enemy_count( count )
{
	if( !IsDefined( level.onramp_enemies ) )
		return;

	while( get_enemies_alive() > count )
	{
		wait 0.05;
	}
}

waittill_enemy_group_count( group, count )
{
	if( !IsDefined( level.onramp_enemies[ group ] ) )
		return;

	while( get_enemies_alive( group ) > count )
	{
		wait 0.05;
	}
}

get_enemies_alive( group_name )
{
	total = 0;
	if( IsDefined( group_name ) )
	{
		return get_group_enemies_alive( group_name );
	}
	else
	{
		foreach( index, group in level.onramp_enemies )
		{
			total += get_group_enemies_alive( index );
		}
	}
	return total;
}

get_group_enemies_alive( group_name )
{
	total = 0;
	foreach( enemy in level.onramp_enemies[ group_name ] )
	{
		if( IsAlive( enemy ) )
		{
			total++;
		}
	}
	return total;
}

enemy_group_init( spawner_script_noteworthy )
{
	spawners = GetEntArray( spawner_script_noteworthy, "script_noteworthy" );
	foreach( spawner in spawners )
	{
		level.onramp_enemies[ spawner_script_noteworthy ] = [];
		spawner add_spawn_function( ::enemy_on_spawn );
	}
}

enemy_on_spawn()
{
	group = level.onramp_enemies[ self.script_noteworthy ];
	group[ group.size ] = self;
	level.onramp_enemies[ self.script_noteworthy ] = group;

	self thread enemy_on_death( self.script_noteworthy );

	switch( self.script_noteworthy )
	{
		case "onramp_enc_final_rpg":
			self.ignoreMe = true;
			self thread rpg_attacker_target();
			self thread rpg_attacker_falling_death();
			break;
		case "onramp_enc_final_ugv":
			self.ignoreMe = true;
			self thread ugv_soldier_logic();
			break;
		default:
			break;
	}
}

enemy_on_death( script_noteworthy )
{
	self waittill( "death" );
	level.onramp_enemies[ script_noteworthy ] = array_remove( level.onramp_enemies[ script_noteworthy ], self );
//  iPrintln( script_noteworthy + " enemies: " + get_enemies_alive( script_noteworthy ) );
}

enemy_wave_spawn( enemy_noteworthy, count, delay_min, delay_max, debug )
{
	// KVP script_noteworthy must == KVP script_aigroup for each spawner in Radiant
	enemies_found = GetEntArray( enemy_noteworthy, "script_noteworthy" );
	enemy_spawners = enemies_found;
	enemies = [];
	foreach( spawner in enemies_found )
	{
		if( !IsSpawner( spawner ) )
		{
			enemy_spawners = array_remove( enemy_spawners, spawner );
		}
		else
		{
			spawner.count = -1;
		}
	}

	spawners_to_use = [];
	if( IsDefined( count ) && count < enemy_spawners.size )
	{
//  	for( i = 0; i < count; i++ )
//  	{
//  		enemy_spawners[ i ] spawn_ai( true );
//  		if( IsDefined( delay_min ) && IsDefined( delay_max ) )
//  		{
//  			if( delay_min < delay_max )
//  				wait RandomFloatRange( delay_min, delay_max );
//  			else
//  				wait delay_min;
//  		}
//  		else
//  		{
//  			wait 0.25;
//  		}
//  	}
		enemy_spawners = array_randomize( enemy_spawners );

		for( i = 0; i < count; i++ )
		{
			spawners_to_use[ i ] = enemy_spawners[ i ];
		}
	}
	else
	{
		spawners_to_use = enemy_spawners;
	}
	
	enemies = array_spawn( spawners_to_use, true );

	if( IsDefined( debug ) && debug )	
		iPrintLnBold( "Spawned group: " + enemy_noteworthy );

}



// UGV UTILITIES //

ugv_encounter()
{
	iPrintLnBold( "UGV!!" );
	enemy_wave_spawn( "onramp_enc_final_ugv" );

	level.ugv = vehicle_spawn( GetEnt( "onramp_ugv_01", "script_noteworthy" ) );
	level.ugv thread ugv_death_watch();
	level.ugv thread ugv_critical_watch();
//  level.ugv thread ugv_targets_fire();
	level.ugv thread ugv_player_fire();
	level.ugv thread ugv_explosions();
	level.ugv GoPath();


	level.ugv waittill( "reached_end_node" );

	level notify ( "ugv_stopped" );
}

ugv_soldier_logic()
{
	self endon( "death" );

	self.ignoreAll = true;
//  self enable_cqbwalk();

	while( 1 )
	{
		self waittill( "goal" );
		if( IsDefined( self ) )
		{
			curTarget = GetEnt( self.target, "targetname" );
			if( IsAI( self ) && IsDefined( curTarget.target ) && IsDefined( GetEnt( curTarget.target, "targetname" ) ) )
				self.target = curTarget.target;
			else
				break;
		}
	}

	self.ignoreAll = false;
//  self disable_cqbwalk();
	issue_color_orders( "o200", "axis" );
}

ugv_destroy_object( script_noteworthy, magnitude )
{
	objects = GetEntArray( script_noteworthy, "script_noteworthy" );
	foreach( object in objects )
	{
//  	if( IsDefined( object.target ) )
//  	{
//  		impulse = GetEnt( object.target, "targetname" );
//  		origin = impulse.origin;
//  		force = ( cos( impulse.angles[ 1 ] ), sin( impulse.angles[ 1 ] ), 1 );
//  	}
//  	else
//  	{
//  		origin = object.origin;
//  		force = ( cos( object.angles[1] ), sin( object.angles[1] ), 1 );
//  	}

		origin = object.origin;
		force = ( 0, 0, 1 );
		force *= magnitude;

		object PhysicsLaunchClient( origin, force );	
	}
}

ugv_critical_watch()
{
	self vehicle_waittill_node( "ugv_onramp_critical", "script_noteworthy" );
	flag_set( "onramp_ugv_critical" );
}

ugv_death_watch()
{
	level waittill( "bravo_rescue" );
	self ugv_kill();
	wait 5.0;
}

ugv_kill()
{
	explosion_dist = 50;
	theta = self.angles[1] + 90;
	explosion_center = self.origin + ( cos( theta ) * explosion_dist, sin( theta ) * explosion_dist, 0 );
//  PhysicsExplosionSphere( explosion_center, 100, 80, 100 );
	PlayFX( level._effect["vehicle_explosion_hummer"], explosion_center );
	self Kill();
}

ugv_player_fire()
{
	self.mgturret[0] SetMode( "manual" );
	self.mgturret[1] SetMode( "manual" );
	self.mgturret[2] SetMode( "manual" );

	flag_wait( "onramp_ugv_critical" );
	self thread ugv_targets_fire();
	wait 15.0;
	if( !level.onramp_vp_rescued )
	{
		MagicBullet( "rpgx_straight", self.mgturret[ 0 ].origin, level._player.origin + (0, 0, 52 ) );
		wait 0.1;
		level._player Kill();
	}
}

ugv_targets_fire()
{
	self endon( "death" );
	
	turret = self.mgturret[ 0 ];
	turret StartBarrelSpin();

	while( 1 )
	{
		valid_targets = [];

		targets = GetEntArray( "ugv_target", "targetname" );
		targets = get_within_range( self.origin, targets, 2000 );

		foreach( target in targets )
		{
			if( within_fov( self.origin, self.angles, target.origin, cos( 90 ) ) )
			{
				valid_targets[ valid_targets.size ] = target;
			}
		}

		if( valid_targets.size > 0 )
		{
			new_target = random( valid_targets );
			self.mgturret[ 0 ] SetTurretTargetPosition( new_target.origin );
			self.mgturret[ 1 ] SetTurretTargetPosition( new_target.origin );
			self.mgturret[ 0 ] ShootTurret();
			self.mgturret[ 1 ] ShootTurret();
		}

		wait RandomFloatRange( 0.5, 1.0 );
	}
}

ugv_explosions()
{
	onramp_ugv_explosion( "ugv_explosion_01" );
	onramp_ugv_explosion( "ugv_explosion_02" );
	onramp_ugv_explosion( "ugv_explosion_03" );
	onramp_ugv_explosion( "ugv_explosion_04" );
	onramp_ugv_explosion( "ugv_explosion_05" );
}

onramp_ugv_explosion( explosion_name )
{
	trigger_wait( explosion_name + "_trigger", "targetname" );
	explosion_nodes = GetEntArray( explosion_name, "targetname" );
	foreach( node in explosion_nodes )
	{
		force = RandomFloatRange( 7.5, 9.0 );
		PhysicsJolt( node.origin, node.radius, node.radius, ( RandomFloatRange( force*-1.0, force ), 0, 7.5 ) );
		PlayFX( level._effect["vehicle_explosion_hummer"], node.origin );
//  	PhysicsExplosionSphere( node.origin, node.radius, node.radius, 3 );
//  	RadiusDamage( node.origin, 500, 10000, 10000 );
	}
}

player_zone_enable( zone_script_noteworthy, enable )
{
	if( enable )
	{
		level thread player_zone_watch( zone_script_noteworthy );
	}
	else
	{
		level notify( "player_zone_watch_end" );
	}
}

player_zone_watch( zone_script_noteworthy )
{
	
	self endon( "player_zone_watch_end" );
	interval = 0.5;
	wait_time = 0.0;
	max_wait = 3.5;

	zones = GetEntArray( zone_script_noteworthy, "script_noteworthy" );

	while( 1 )
	{
		foreach( zone in zones )
		{
			if( !( level._player IsTouching( zone ) ) )
			{
				if( wait_time >= max_wait )
				{
					SetDvar( "ui_deadquote", "@NX_HITHARD_B_FAILED_ABANDON" );
					level notify( "mission_failed" );
					maps\_utility::missionFailedWrapper();
				}
				else if( wait_time >= 0.25 * max_wait )
				{
	//  			iPrintlnBold( "Turn around! You can not abandon Patriot!" );
				}
			}
			else
			{
				wait_time = 0.0;
			}
		}

		wait_time += interval;
		wait interval;
	}
}

ss1_kill()
{
	wait 7.0;

	self stop_magic_bullet_shield();

	for( i = 0; i < 4; i++ )
	{
		wait RandomFloatRange( 0.1, 0.2 );
		theta = self.angles[ 1 ];
		org_bullet_source = self.origin + ( cos( theta ) * 512, sin( theta ) * 512, 10 );
		org_bullet_dest = self.origin + ( RandomFloatRange( 4, 8 ), RandomFloatRange( 4, 8 ), 40 );
		MagicBullet( "xm108_asco", org_bullet_source, org_bullet_dest );
	}
	self Kill();
}

vp_rpg_attack()
{
	wait 2.0;
	rpg_spawner =	GetEnt( "onramp_rpg_spawner", "targetname" );
	rpg_attacker =  rpg_spawner spawn_ai( );

	rpg_fire	=	GetEnt( "onramp_vp_rpg_fire", "targetname" );
	rpg_target	=	GetEnt( rpg_fire.target, "targetname" );

	//explosion slomo
	magicbullet( "rpg_straight_no_impact", rpg_fire.origin, rpg_target.origin );
	wait 0.5;
	exploder( "vphit_explosion" );
	thread maps\nx_hithard_b_fx::vphit_slomo();
	Earthquake( .4, 1.2, level._player.origin, 5000 );
	level._player thread maps\_gameskill::grenade_dirt_on_screen( "left" );
	wait 0.1;
	level._player thread maps\_gameskill::grenade_dirt_on_screen( "right" );

	// Player damage
	level._player DoDamage( 10, rpg_attacker.origin, rpg_attacker );

	level notify( "onramp_cover_destruct_00" );
}

#using_animtree( "generic_human" );
rpg_attacker_falling_death()
{
	self waittill( "goal" );
	death_anims = [	%death_rooftop_B, %death_rooftop_C, %death_rooftop_D ];
	self.deathanim = random( death_anims );

}

rpg_attacker_target()
{
	self endon( "death" );
//  self.favoriteenemy = level._player;
	while( 1 )
	{
		self.a.rockets = 3;
		self SetEntityTarget( random( GetEntArray( "ugv_target", "targetname" ) ) );
//  	self waittill( "firing" );
		self ClearEntityTarget( );
		wait 1.0;
	}
}

vignette_vp_drag()
{
	// VP Drag Scene
	Objective_State( OBJ_MOVE_PATRIOT , "done" );
	level thread maps\nx_hithard_b_anim::vpdrag( level.squad[ AI_BAKER ], level.squad[ AI_VP ] );

	wait 15.0;
	level notify( "bravo_rescue" );
}

vignette_vp_hit()
{
	// VP Hit Scene
	maps\nx_hithard_b_anim::vphit_ssrunup( 
		level.squad[ AI_SS2 ], 
		level.squad[ AI_VP ], 
		level.squad[ AI_BAKER ] );

	maps\nx_hithard_b_anim::vphit_start( 
		level.squad[ AI_BAKER ],
		level.squad[ AI_VP ],
		level.squad[ AI_SS2 ]
	);

	node = level thread maps\nx_hithard_b_anim::vphit_hurt_loop( 
		level.squad[ AI_BAKER ],
		level.squad[ AI_VP ]
	);

	autosave_now();

	level waittill( "vp_critical_moment" );
	node notify( "vp_critical_moment" );

}

vp_drag_interactive()
{
	Objective_Add( OBJ_MOVE_PATRIOT, "current", "Move injured Patriot to the freeway." );
	Objective_Position( OBJ_MOVE_PATRIOT, level.squad[ AI_VP ].origin + ( 0, 0, 48 ) );

	use_trigger = GetEnt( "vp_drag_trigger", "targetname" );
	use_trigger trigger_off();

	// Begin Assist Loop
	level notify( "vp_critical_moment" );
	node = level thread maps\nx_hithard_b_anim::vphit_assist_loop( 
		level.squad[ AI_BAKER ],
		level.squad[ AI_VP ]
	);

	// Enable Use Trigger
	use_trigger trigger_on();
	use_trigger SetHintString( &"NX_HITHARD_B_HINT_MOVE_PATRIOT" );
	use_trigger waittill( "trigger" );
	use_trigger trigger_off();

	level.onramp_vp_rescued = true;

	level notify( "vp_drag_moment" );
	node notify( "vp_drag_moment" );

//  level.squad[ AI_BAKER ] stop_anim();
//  level.squad[ AI_VP ] stop_anim();
	level thread vignette_vp_drag();
}

//*******************************************************************
//           Utilities			                   					*
//                                                                  *
//*******************************************************************
vp_protect_at_node( actor_vp, actor_ss )
{
	self.vp_protect = true;
	//actor_vp.animname = "vp";
	//actor_ss.animname = "ss";
	guys = [ actor_vp, actor_ss ];
	self anim_reach( guys, "vp_arrival_in" );
	self anim_single( guys, "vp_arrival_in" );
	self vp_protect_idle( guys );
	self anim_single( guys, "vp_arrival_out" );
}

vp_protect_idle( guys )
{
	self endon( "vp_protect_end" );
	while( 1 )
	{
		self anim_single( guys, "vp_arrival_idle" );
	}
}

vp_protect_end()
{
	if( !IsDefined( self.vp_protect ) || !self.vp_protect )
		return;
	self.vp_protect = false;
	self notify ( "vp_protect_end" );
	self waittill( "vp_arrival_out" );
}


vtol_deploy( vtol_name )
{
	vtol = maps\nx_hithard_b_util::vtol_spawn( vtol_name );
	vtol.ignoreMe = true;
	vtol thread ignore_all_triggers();
	vtol thread maps\nx_hithard_b_util::vtol_move( );
	return vtol;
}



triggers_enable( trigger_noteworthy, enable )
{
	if( !IsDefined( enable ) )
		enable = true;

	triggers = GetEntArray( trigger_noteworthy, "script_noteworthy" );
	foreach( trigger in triggers )
	{
		if( enable )
			trigger trigger_on();
		else
			trigger trigger_off();
	}
}

flag_inits()
{
	flag_init( "onramp_enc_01_wave_01" );
	flag_init( "onramp_enc_02_begin" );
	flag_init( "onramp_ugv_critical" );
	flag_init( "player_meet_bravo" );
}
