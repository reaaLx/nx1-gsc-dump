//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module: Lava Outpost													**
//                                                                          **
//    Created: 07/25/10 - Travis Chen (trchen x 4143)						**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
	// setup station 1 spawners
	self thread setup_spawners();

	// reduce ammo
	level._player setWeaponAmmoStock( "lunar_sniper_l3", 8 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
	PrecacheItem( "lunarrifle_l3" );
	PrecacheItem( "lunar_sniper_l3" );
}

section_flag_inits()
{
	// Surface Approach
	flag_init( "op_surface_start_walk" );
	flag_init( "op_surface_found_outpost" );
	flag_init( "op_surface_vehicle_start" );

	// Surface Battle
	flag_init( "op_surface_start_battle" );
	flag_init( "op_surface_secured_outpost" );
	flag_init( "op_surface_get_O2" );

	// Surface Explore
	flag_init( "op_surface_action_o2" );
	flag_init( "op_surface_found_o2" );
	flag_init( "op_surface_got_weapons" );
	flag_init( "op_surface_used_lift" );

	flag_init( "op_garage_lift_baker" );
	flag_init( "op_garage_lift_tilman" );
	flag_init( "op_garage_lift_franklin" );
	
	// Garage
	flag_init( "op_garage_lift_almost_down" );
	flag_init( "op_garage_lift_down" );

	// Garage Battle
	flag_init( "op_garage_secured" );

	// Vehicle Sneak Around
	flag_init( "op_sub_vehicle_sneak" );
	flag_init( "op_sub_move_vehicle" );
	flag_init( "op_sub_vehicle_passed" );

	flag_init( "op_s1_lift_baker" );
	flag_init( "op_s1_lift_tilman" );
	flag_init( "op_s1_lift_franklin" );

	// Pre-Platform
	flag_init( "s1p_lift_used" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

outpost_objectives( objective_num )
{
	flag_wait( "op_surface_start_walk" );	

	// Find enemy outpost
	objective_add( objective_num, "current", &"NX_LAVA_OBJECTIVE_OP_FIND_OUTPOST" );
	objective_onEntity( objective_num, level.baker, (0, 0, 74) );
	objective_current( objective_num );

	flag_wait( "op_surface_found_outpost" );
	objective_complete( objective_num );
	objective_num++;

	// Secure outpost
	objective_add( objective_num, "current", &"NX_LAVA_OBJECTIVE_OP_FIND_O2" );
	objective_onEntity( objective_num, level.baker, (0, 0, 74) );
	objective_current( objective_num );

	// find o2
	flag_wait( "op_surface_get_O2" );
	objective_clearAdditionalPositions( objective_num );
	waypoint = getStruct( "op_surface_o2_org", "targetname" );
	objective_position( objective_num, waypoint.origin );

	flag_wait( "op_surface_found_o2" );
	objective_complete( objective_num );
	objective_num++;
	
	// get weapons
	objective_add( objective_num, "current", &"NX_LAVA_OBJECTIVE_OP_GET_WEAPONS" );
	waypoint = getStruct( "op_surface_weapons_org", "targetname" );
	objective_position( objective_num, waypoint.origin );
	objective_current( objective_num );
	
	flag_wait( "op_surface_got_weapons" );
	objective_complete( objective_num );
	objective_num++;

	return objective_num;
}

garage_objectives( objective_num )
{
	// explore outpost
	waypoint = getStruct( "op_surface_elevator_org", "targetname" );
	objective_add( objective_num, "current", &"NX_LAVA_OBJECTIVE_OP_EXPLORE_OUTPOST", waypoint.origin );
	objective_current( objective_num );

	// in garage
	flag_wait( "op_surface_used_lift" );
	objective_clearAdditionalPositions( objective_num );
	objective_onEntity( objective_num, level.baker, (0, 0, 74) );

	// go to lift
	flag_wait( "op_sub_vehicle_passed" );
	waypoint = getStruct( "op_sub_to_s1_lift_org", "targetname" );
	objective_clearAdditionalPositions( objective_num );
	objective_position( objective_num, waypoint.origin );

	// taking lift to s1
	flag_wait( "s1p_lift_used" );
	objective_clearAdditionalPositions( objective_num );
	objective_onEntity( objective_num, level.baker, (0, 0, 74) );

	return objective_num;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

outpost_start()
{
	// spawn and teleport allies
	maps\nx_lava_util::lava_ally_spawn( "outpost_start" );

	// setup and teleport player
	maps\nx_lava_util::player_start( "outpost_player_start" );
	thread maps\nx_lava_fx::set_vision_and_fog("outpost", 0); // set initial vision and fog for this checkpoint.
}

outpost()
{
	//**********************************************
	// Surface Approach
	flag_set( "op_surface_start_walk" );

	// get vehicle ready
	thread op_surface_vehicle();

	// look for outpost
	thread op_surface_approach();

	// outpost found
	flag_wait( "op_surface_found_outpost" );
	thread op_surface_outpost_found();
	
	//**********************************************
	// Surface Battle
	flag_wait( "op_surface_start_battle" );
	autosave_by_name( "outpost_battle" );

	// start the battle
	thread op_surface_battle();

	//**********************************************
	// Surface Explore Base

	// look for o2
	flag_wait( "op_surface_secured_outpost" );
	thread op_surface_find_o2();

	// find lift
	flag_wait( "op_surface_found_o2" );
	thread op_surface_find_lift();
	
	// use lift
	flag_wait( "op_surface_used_lift" );
}

garage_start()
{
	// spawn and teleport allies
	maps\nx_lava_util::lava_ally_spawn( "outpost_subsection_start" );

	// put allies in CQB
	level.baker enable_cqbwalk();
	level.tilman enable_cqbwalk();
	level.franklin enable_cqbwalk();

	// setup and teleport player
	maps\nx_lava_util::player_start( "outpost_subsection_player_start" );

	// step objective forward
	flag_set( "op_surface_used_lift" );
}

garage()
{
	autosave_by_name( "garage" );

	//**********************************************
	// Going down to garage
	thread op_move_surface_lift();

	//**********************************************
	// Garage Setup
	flag_wait( "op_garage_lift_almost_down" );
	thread op_garage_setup();


	//**********************************************
	// Garage Battle
	flag_wait( "op_garage_lift_down" );
	op_garage_cleanup();
	thread op_garage_battle();

	//**********************************************
	// Vehicle Sneak Around
	flag_wait( "op_sub_vehicle_sneak" );
	thread op_sub_vehicle_sneak();
	
	//**********************************************
	// Vehicle Sneak Around
	flag_wait( "op_sub_vehicle_passed" );
	thread op_sub_goto_s1();
	//apm: fire off the dusty tunnel fx
	exploder ( "lgv_tunnel_dustfx01" );

	//**********************************************
	// Pre-Platform
	thread s1_plat_lift_use();

	flag_wait( "s1p_lift_used" );
}

//*******************************************************************
//	Outpost Approach Surface Base                                   *
//                                                                  *
//*******************************************************************

op_surface_approach()
{
	// set up allies & player
	level.baker set_ignoreall( true );
	level.tilman set_ignoreall( true );
	level.franklin set_ignoreall( true );

	// play opening walk vignette
	// maps\nx_lava_anim::opening_walk(); // TEMP TEMP - Remove vignette

	// starting dialog
	// wait( 1 );
	// level.franklin radio_dialogue( "lava_fra_surface_headtobase" );				// dialog: "(breathing in short breaths) Sir… shouldn’t we… head to base?... I’m almost bingo O2…."
	// level.baker thread radio_dialogue( "lava_kee_surface_keepmoving" );			// dialog: "Keep moving, Franklin."

	// move to ledge
	node = getNode( "outpost_ledge_tilman", "targetname" ); // TEMP TEMP - Remove vignette - REMOVE
	level.tilman thread follow_path( node ); // TEMP TEMP - Remove vignette - REMOVE
	wait( 0.5 );
	node = getNode( "outpost_ledge_baker", "targetname" ); // TEMP TEMP - Remove vignette - REMOVE
	level.baker thread follow_path( node ); // TEMP TEMP - Remove vignette - REMOVE
	node = getNode( "outpost_ledge_franklin", "targetname" ); // TEMP TEMP - Remove vignette - REMOVE
	level.franklin thread follow_path( node ); // TEMP TEMP - Remove vignette - REMOVE
	// level.baker radio_dialogue( "lava_kee_surface_wontmatter" );				// dialog: "We don’t find out what’s going on, not havin’ air won’t matter anymore."

	// dialog: see anything?
	wait( 3 ); // ( 1 )
	level.baker radio_dialogue( "lava_kee_surface_seeanything" );				// dialog: "Carson – you see anything up there?"

	flag_set( "op_surface_found_outpost" );
}

op_surface_outpost_found()
{
	// dialog: found a base
	level.tilman radio_dialogue( "lava_car_surface_nosirohshit" );				// dialog: "No sir, not a fucking… oh shit!"
	level.tilman radio_dialogue( "lava_car_surface_upheresomething" ); 			// dialog: "Sir – up here – we definitely have something?!"
	level.baker thread radio_dialogue( "lava_kee_surface_doubletime" ); 		// dialog: "Everyone – double-time it up there, but keep it low when you get to the top!"
	
	// allies slide down hill to sniper spot
	wait( 0.25 );
	thread maps\nx_lava_anim::hillslide_tilman();
	thread maps\nx_lava_anim::hillslide_franklin();
	maps\nx_lava_anim::hillslide_baker();

	if( !flag( "op_surface_start_battle" ) )
	{
		// baker hold position
		thread maps\nx_lava_anim::hold_motion();
		wait( 1 );
		level.baker radio_dialogue( "lava_kee_surface_threetangos" );			// dialog: "Ready your rifles… we've got three Tangos on that rover."
		level.baker thread radio_dialogue( "lava_kee_surface_assigntargets" ); 	// dialog: "Walker, you take the gunner, Carson, the one on the left. I have the one on the right. Franklin, you cover our slop."
		
		// wait for player to initiate surface battle
		level._player waittill( "weapon_fired" );
		flag_set( "op_surface_start_battle" );
	}
}

op_surface_vehicle()
{
	// spawn surface vehicle
	level.op_sur_vehicle = maps\_vehicle::spawn_vehicle_from_targetname( "op_surface_vehicle" );
	level.op_sur_vehicle.dontunloadonend = true;
	level.op_sur_vehicle maps\_vehicle::vehicle_lights_on( "running" );

	flag_wait( "op_surface_vehicle_start" );

	// move vehicle
	// level.op_sur_vehicle Vehicle_SetSpeed( 27.0, 100.0 ); 
	level.op_sur_vehicle thread maps\_vehicle::goPath();

	level.op_sur_vehicle playsound("scn_lava_rover_entrance");

	// vehicle reaches surface garage
	level.op_sur_vehicle waittill( "reached_end_node" );

	if( !flag( "op_surface_start_battle" ) )
	{
		// baker talks
		level.baker radio_dialogue( "lava_kee_surface_holdon321" );			// dialog: "Hold on 3… 2… 1…"
	}
	
		// unload vehicle and start battle
		wait( 1 );
		unloaded_guys = level.op_sur_vehicle maps\_vehicle::vehicle_unload( "all" );
		flag_set( "op_surface_start_battle" );
}


//*******************************************************************
//	Outpost Surface Battle                                          *
//                                                                  *
//*******************************************************************

op_surface_battle()
{
	wait( 0.2 );	

	// shoot two of the vehicle riders
	thread kill_deathflag( "op_surface_vehicle_enemies", 2 );

	// set allies and enemies to no ignore
	level.baker set_ignoreall( false );
	level.tilman set_ignoreall( false );
	level.franklin set_ignoreall( false );

	wait( 1 );
	// spawn & ready enemies
	thread maps\nx_lava_util::spawn_group_by_name( "op_surface_bad_spawn" );

	vehicle_enemies = get_ai_group_ai( "op_surface_vehicle_bad" );
	foreach( enemy in vehicle_enemies )
	{
		enemy set_ignoreall( false );
	}
	
	// setup a hassle-free auto-end
	thread hassle_free_battle_end( "op_surface_secured_outpost", [ "op_surface_bad", "op_surface_vehicle_bad" ] );

	// jump down crater
	level.baker radio_dialogue_stop();
	level.baker thread radio_dialogue_interupt( "lava_kee_station1_letsmove" );			// dialog: "Let's move"
	maps\nx_lava_anim::ledgejump();

	// wait to reach the bottom and go to cover
	level.baker set_force_color( "c" );
	level.tilman set_force_color( "b" );
	level.franklin set_force_color( "o" );
}


//*******************************************************************
//	Outpost Explore Base                                            *
//                                                                  *
//*******************************************************************

op_surface_find_o2()
{
	level.baker thread radio_dialogue( "lava_kee_surface_stackup" );			// dialog: "Stack up at the entrance! – let’s find out what this place is."

	// prep allies
	level.baker disable_ai_color();
	level.tilman disable_ai_color();
	level.franklin disable_ai_color();

	// go to O2 vignette
	maps\nx_lava_anim::air_resupply_reach();
	flag_set( "op_surface_get_O2" );

	// activate useable o2 tank
	thread o2_tank_use();

	// play Tilman & Franklin O2 vignette
	thread maps\nx_lava_anim::air_resupply_play();

	// play O2 vignette
	flag_wait( "op_surface_action_o2" );
	maps\nx_lava_anim::air_resupply_baker_faint();

	// go to garage lift
	flag_set( "op_surface_found_o2" );
}

o2_tank_use()
{
	// Wait for player to use o2 tank
	use = GetEnt( "op_use_o2_tank", "targetname" );
	use sethintstring( &"NX_LAVA_OP_USE_O2_TANK" );		

	use waittill( "trigger" );
	use trigger_off();

	// put allies in CQB
	level.baker enable_cqbwalk();
	level.tilman enable_cqbwalk();
	level.franklin enable_cqbwalk();

	flag_set( "op_surface_action_o2" );
}

op_surface_find_lift()
{
	// activate lift
	thread op_garage_lift_use();

	// dialog: look for weapons
	level.baker thread radio_dialogue( "lava_kee_outpost_goodforo2" );			// dialog: "OK – we are good for O2 now, let’s find out what this place is…"


	// move allies to elevator
	level.tilman disable_ai_color();
	t_path = getNode( "op_tilman_explore_lift", "targetname" );
	level.tilman thread follow_path( t_path );
	level.tilman thread op_garage_lift_ready_check( "tilman" );

	level.franklin disable_ai_color();
	f_path = getNode( "op_franklin_explore_lift", "targetname" );
	level.franklin thread follow_path( f_path );
	level.franklin thread op_garage_lift_ready_check( "franklin" );

	// move baker to shotguns
	level.baker disable_ai_color();
	b_path = getNode( "op_baker_get_weapons", "targetname" );
	level.baker thread follow_path( b_path );

	// dialog: get guns
	trig = getEnt( "outpost_trig_get_weapons", "targetname" );
	trig waittill( "trigger" );
	level.baker radio_dialogue( "lava_kee_outpost_pickupshotgun" );				// dialog: "Walker, pick up that shotgun – we may need it."
	wait( 1.5 );
	level.baker radio_dialogue( "lava_kee_outpost_wtfbasehere" ); 				// dialog: "We’re Charlie Mike – find out what the fuck this is base doing here…"
	
	// baker: go to elevator
	wait( 1 );
	level.baker thread radio_dialogue( "lava_kee_outpost_figureoutcontrols" );	// dialog: "Walker, can you figure out the controls over there?"
	wait( 1 );
	
	flag_set( "op_surface_got_weapons" );
	b_path = getNode( "op_baker_explore_lift", "targetname" );
	level.baker thread follow_path( b_path );
	level.baker thread op_garage_lift_ready_check( "baker" );
}

op_garage_lift_ready_check( name )
{
	self waittill( "reached_path_end" );
	flag_set( "op_garage_lift_" + name );
}

op_garage_lift_use()
{
	// Wait for player to use garage lift
	use = GetEnt( "op_use_surface_lift", "targetname" );
	use sethintstring( &"NX_LAVA_OP_USE_SURFACE_LIFT" );

	use waittill( "trigger" );
	use trigger_off();

	flag_wait( "op_garage_lift_baker" );
	flag_wait( "op_garage_lift_tilman" );
	flag_wait( "op_garage_lift_franklin" );

	flag_set( "op_surface_used_lift" );
}

op_move_surface_lift()
{
	// spawn garage mechanics
	thread maps\nx_lava_anim::rover_maintance_spawn();

	// set allies to stun
	level.baker set_ignoreall( true );
	level.tilman set_ignoreall( true );
	level.franklin set_ignoreall( true );
	battlechatter_off();
	
	// move elevator
	storage_elevator_trigger = GetEnt( "storage_elevator_trigger", "targetname" );
	storage_elevator_target_01 = GetEnt( "storage_elevator_target_01", "targetname" );
	storage_elevator_target_02 = GetEnt( "storage_elevator_target_02", "targetname" );
	storage_elevator = GetEnt( "storage_elevator", "targetname" );
	storage_elevator_linkers = GetEntArray( "storage_elevator_link", "targetname" );

	foreach( linker in storage_elevator_linkers )
	{
		linker LinkTo( storage_elevator );
	}
	
	level.baker linkTo( storage_elevator );
	level.tilman linkTo( storage_elevator );
	level.franklin linkTo( storage_elevator );

	wait( 1.0 );
	
	// Initial elevator drop
	storage_elevator MoveTo( storage_elevator_target_01.origin, 3.0, 0.5, 0.2 );
	thread maps\nx_lava_fx::set_vision_and_fog("garage", 3.0); // transition to new vision
	wait( 4 );

	// dialog: Christ?!
	level.franklin thread radio_dialogue( "lava_fra_outpost_christ" );			// dialog: "Christ?!"

	// Main elevator movement
	storage_elevator MoveTo( storage_elevator_target_02.origin, 21.0, 2.0, 1.0 );
	storage_elevator PlaySound( "scn_lava_lift01" );

	// dialog for 10 seconds
	wait( 1 );
	level.baker thread radio_dialogue( "lava_kee_outpost_elevatorsystem" );			// dialog: "Keene to Base – the remote EC base is an elevator system to something below –continuing to investigate."

	// allies notice enemies!
	wait( 8 );
	level.baker set_ignoreall( false );
	level.tilman set_ignoreall( false );
	level.franklin set_ignoreall( false );
	level.tilman thread radio_dialogue( "lava_car_garage_tangosahead" );			// dialog: "Tangos ahead!"
	battlechatter_on( "allies" );
	
	wait( 12 );
	level.baker unlink();
	level.tilman unlink();
	level.franklin unlink();
	flag_set( "op_garage_lift_down" );
}


//*******************************************************************
//	Subsection Garage Setup                                         *
//                                                                  *
//*******************************************************************

op_garage_setup()
{
	// spawn enemies
	thread maps\nx_lava_util::spawn_group_by_name( "op_garage_bad_spawner" );

	wait( 0.5 );
	level.baker radio_dialogue( "lava_kee_garage_takethemdown" );			// dialog: "Take 'em down"
}

op_garage_cleanup()
{
	// clean up surface vehicle
	if( IsDefined( level.op_sur_vehicle ) )
		level.op_sur_vehicle delete();
}


//*******************************************************************
//	Subsection Garage Battle                                        *
//                                                                  *
//*******************************************************************

op_garage_battle()
{
	// color allies
	level.baker set_force_color( "c" );
	level.tilman set_force_color( "b" );
	level.franklin set_force_color( "o" );

	// double check enemy spawn
	if( !flag( "op_garage_lift_almost_down" ) )
		thread maps\nx_lava_util::spawn_group_by_name( "op_garage_bad_spawner" );
	
	flag_wait( "op_garage_secured" );
	if( !flag( "op_sub_vehicle_sneak" ) )
	{
		// move allies
		level.baker disable_ai_color();
		b_path = getNode( "op_vehicle_start_baker", "targetname" );
		level.baker thread follow_path( b_path );
	
		level.tilman disable_ai_color();
		t_path = getNode( "op_vehicle_start_tilman", "targetname" );
		level.tilman thread follow_path( t_path );
	
		level.franklin disable_ai_color();
		f_path = getNode( "op_vehicle_start_franklin", "targetname" );
		level.franklin thread follow_path( f_path );

		wait( 3 );
		level.tilman radio_dialogue( "lava_car_garage_technicalsandtroops" );			// dialog: "So, this is how they are getting technical and troops moved around?!"
		wait( 0.5 );
		level.baker radio_dialogue( "lava_kee_garage_notlookinggood" );					//dialog: "If it is – they would need hundreds of these… either way this is not looking good…"
	}
}

op_sub_vehicle_sneak()
{
	// spawn vehicle
	level.op_sub_vehicle = maps\_vehicle::spawn_vehicle_from_targetname( "op_sub_vehicle" );
	level.op_sub_vehicle maps\_vehicle::vehicle_lights_on( "running" );
	
	// turn off battlechatter
	battlechatter_off();
	

	// move allies
	level.baker disable_ai_color();
	b_path = getNode( "op_vehicle_hide_baker", "targetname" );
	level.baker thread follow_path( b_path );

	level.tilman disable_ai_color();
	t_path = getNode( "op_vehicle_hide_tilman", "targetname" );
	level.tilman thread follow_path( t_path );
	
	level.franklin disable_ai_color();
	f_path = getNode( "op_vehicle_hide_franklin", "targetname" );
	level.franklin thread follow_path( f_path );

	// dialog: vehicle.. get to cover
	wait( 4 );
	level.baker thread radio_dialogue( "lava_kee_garage_technicalincoming" );			// dialog: "Technical incoming! Get to cover!"

	// move vehicle
	thread op_vehicle_ready_check();

	flag_wait( "op_sub_move_vehicle" );
	level.op_sub_vehicle.mgturret[0] SetRightArc( 10 );
	level.op_sub_vehicle.mgturret[0] SetLeftArc( 10 );
	level.op_sub_vehicle Vehicle_SetSpeed( 7.5, 100.0 ); 
	level.op_sub_vehicle thread maps\_vehicle::goPath();

	// dialog: stay down!
	level.baker thread radio_dialogue( "lava_kee_garage_staydown" );			// dialog: "Stay down and don’t move."

	//wait till vehicle is passed
	wait( 15 );
	flag_set( "op_sub_vehicle_passed" );
}

op_vehicle_ready_check()
{
	level.franklin waittill( "reached_path_end" );

	flag_set( "op_sub_move_vehicle" );
}

op_sub_goto_s1()
{
	b_path = getNode( "op_to_s1_baker", "targetname" );
	level.baker thread follow_path( b_path );
	level.baker thread op_s1_lift_ready_check( "baker" );

	wait( randomFloat( .5 ) );
	level.baker thread radio_dialogue( "lava_kee_garage_deadfriends" );			// dialog: "Let’s keep it moving –they’re about to have some dead friends to find back there."

	// move tilman and franklin
	wait( randomFloatRange( .5, 1.5 ) );
	t_path = getNode( "op_to_s1_tilman", "targetname" );
	level.tilman thread follow_path( t_path );
	level.tilman thread op_s1_lift_ready_check( "tilman" );
	
	wait( randomFloatRange( 1.0, 1.75 ) );
	f_path = getNode( "op_to_s1_franklin", "targetname" );
	level.franklin thread follow_path( f_path );
	level.franklin thread op_s1_lift_ready_check( "franklin" );

	// dialog: another lift
	trig = getEnt( "op_to_s1_nearby", "targetname" );
	trig waittill( "trigger" );

	level.tilman radio_dialogue( "lava_car_garage_anotherlift" );				// dialog: "Another lift."
	wait( 0.5 );
	level.baker radio_dialogue( "lava_kee_garage_theconsole" );					// dialog: "Walker – the console…"
}

op_s1_lift_ready_check( name )
{
	self waittill( "reached_path_end" );
	flag_set( "op_s1_lift_" + name );
}

//*******************************************************************
//	Lava Tube Elevator                                              *
//                                                                  *
//*******************************************************************

s1_plat_lift_use()
{
	// Wait for player to use o2 tank
	use = GetEnt( "s1_use_plat_lift", "targetname" );
	use sethintstring( &"NX_LAVA_S1_USE_PLAT_LIFT" );		

	use waittill( "trigger" );
	use trigger_off();

	flag_wait( "op_s1_lift_baker" );
	flag_wait( "op_s1_lift_tilman" );
	flag_wait( "op_s1_lift_franklin" );

	flag_set( "s1p_lift_used" );
}

//*******************************************************************
//	ALLIES & ENEMIES                                                *
//                                                                  *
//*******************************************************************

setup_spawners()
{
	spawners = GetEntArray( "outpost_enemy_spawner", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, maps\nx_lava_util::l3_enemy_common );
	
	spawners = GetEntArray( "outpost_surface_enemy_spawner", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, ::outpost_surface_bad_logic );
	
	spawners = GetEntArray( "outpost_garage_enemy_spawner", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, maps\nx_lava_util::l3_enemy_common, true );
	
	spawners = GetEntArray( "outpost_garage_mech_spawner", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, ::outpost_garage_mech_bad_logic );
	
	spawners = GetEntArray( "outpost_vehicle_enemy", "script_noteworthy" );
	array_thread( spawners, ::add_spawn_function, ::outpost_vehicle_bad_logic );
}

outpost_surface_bad_logic()
{
	self endon( "death" );
	
	self.a.nodeath = false;
	self.allowdeath = true;
	self set_ignoreall( true );
	self disable_ai_color();
	self enable_cqbwalk();
}

outpost_garage_mech_bad_logic()
{
	self endon( "death" );
	
	self set_ignoreall( true );
	self enable_cqbwalk();

	self waittill( "fleeing" );

	self waittill( "goal" );
	self kill();
}

outpost_vehicle_bad_logic()
{
	self endon( "death" );
	self set_ignoreall( true );

	sightCheck = false;

	while( self.ignoreall )
	{
		can_see = self can_see_char( level._player );
		if( can_see )
		{
			if( sightCheck )
			{
					// make enemies attack
					baddies = get_ai_group_ai( "op_sub_vehicle_bad" );
					foreach( baddie in baddies )
						baddie set_ignoreall( false );
					
					// unlock turret
					level.op_sub_vehicle.mgturret[0] SetRightArc( 180 );
					level.op_sub_vehicle.mgturret[0] SetLeftArc( 180 );
					level.op_sub_vehicle.mgturret[0].wait_duration_after_aiming_before_firing = 0.5;
					
					// setup battlechatter
					battlechatter_on( "allies" );
			}
			else
			{
				sightCheck = true;
			}
		}
		else
		{
			sightCheck = false;
		}
		wait( 1.0 );
	}
}

can_see_char( target )
{
	AssertEx( IsPlayer( self ) || IsAI( self ), "can_see_char() can only be called on a player or AI." );
	
	// check to see if I can see head or feet of my target
	myEyes = self getEye() + ( cos(self.angles[1])*72, sin(self.angles[1])*72, 0);
	targetEyes = target getEye();
	
	// check minimum neccesities (all needed )
		// within 1536 units
		// within 180 degrees FoV
		// has LoS
	if(	!(distance(myEyes, targetEyes) < 1536 && within_fov( self.origin, self.angles, targetEyes, Cos( 180 ) ) && SightTracePassed( myEyes, targetEyes, false, self ) ) )
	{
			return false;
	}
	
	// check details (any one needed)
		// within 100 FoV
		// within 540 units && player is standing
	if( within_fov( self.origin, self.angles, targetEyes, Cos( 100 ) ) )
	{
		return true;
	}
	else if( distance(myEyes, targetEyes) < 540 && level._player GetStance() == "stand" )
	{
		return true;
	}

	// cannot see
	return false;
}


//*******************************************************************
//	LOCAL UTILITIES			                                        *
//                                                                  *
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: hassle_free_battle_end( <death_flag>, <groups_array>, <kill_time>, <num_left_target>, <loop_time> )"
"Summary: Kill everything associated with a deathflag after only a certain number of enemies are left"
"Module: Utility"
"MandatoryArg: <death_flag>: The flag to kill on "
"MandatoryArg: <groups_array>: An array of AIgroup names to track numbers "
"OptionalArg: <kill_time>: random amount of time to wait before death (default - 2 seconds) "
"OptionalArg: <num_left_target>: nubmer of targets left before you auto-kill (default - 1) "
"OptionalArg: <loop_time>: amount of time to wait between checks (default - 1 second) "
"Example: kill_deathflag( "tower_cleared" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
hassle_free_battle_end( death_flag, groups_array, kill_time, num_left_target, loop_time )
{
	// init vars
	if( !IsDefined( num_left_target ) )
		num_left_target = 1;
	if( !IsDefined( kill_time ) )
		kill_time = 2;
	if( !IsDefined( loop_time ) )
		loop_time = 1;
	
	num_left = num_left_target + 1;


	if( IsArray( groups_array ) )
	{
		while( num_left > num_left_target )
		{
			wait( loop_time );
			
			// init count
			num_left = 0;
			
			// count enemies
			for( i=0; i < groups_array.size; i++ )
			{
				num_left += get_ai_group_count( groups_array[i] );
			}
		}
	}
	else
	{
		while( num_left > num_left_target )
		{
			wait( loop_time );
			
			// count enemies
			num_left = get_ai_group_count( groups_array );
		}
	}
	
	// once there are only num_left_target left
	kill_deathflag( death_flag, kill_time );
}