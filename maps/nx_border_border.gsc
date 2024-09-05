//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module: Border, Border												**
//                                                                          **
//    Created: 11/11/11 - Travis Chen (trchen x 4143)						**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_nx_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_anim;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

border_start()
{
	maps\nx_border_util::player_start( "player_start_border" );
}																				 

border()
{
	// Global variables	
	level.vehicle_convoy 		= [];
	level.convoy_player_vehicle_allies = [];	
	level.allies 				= [];
	level.border_enemies 		= [];
	level.enemy_vehicles 		= [];
	level.convoy_intro_speed = undefined;

	// Threat bias groups
	CreateThreatBiasGroup( "player" );
	CreateThreatBiasGroup( "enemies" ); 
	level._player SetThreatBiasGroup( "player" );

  	// Spawn convoy with allies and player and set on path
	thread convoy_driveup();
	
	// Dialogue for section
	thread border_dialogue();
	
	// Sets flag for when player is at border
	thread player_at_border();	
	
	// Setup the vehicle path disconnector
	//run_thread_on_targetname( "vehicle_path_disconnector", maps\nx_border_util::vehicle_path_disconnector );

	// Spawn initial baddies	
	level.border_enemies[ "wave_1" ] = 
		spawn_enemy_ground_wave( 
			"actor_axis_wave_1", 
			"notify_unloading_convoy",
			::spawnfunc_enemy_initial_ground_wave, 
			"flag_wave_1_half_dead", 
			"flag_wave_1_almost_dead", 
			"flag_wave_1_dead" 
		);		
	 
	level.border_enemies[ "roof_1" ] = [];
	level.border_enemies[ "bridge" ] = [];
	thread spawn_enemy_rooftops( "bridge", "actor_axis_wave_roof_1", "notify_unloading_convoy", ::spawnfunc_enemy_rooftops_bridge );	
	thread spawn_enemy_rooftops( "roof_1", "actor_axis_wave_roof_2", "notify_unloading_convoy", ::spawnfunc_enemy_rooftops_rpg );
	thread spawn_enemy_rooftops( "border_rpg", "actor_border_rocket", "notify_spawn_border_rpgs", ::spawnfunc_enemy_border_bridge_rpg );

	// Setup spawn functions for baddies that will be spawned during gameplay
	level.border_enemies[ "border_bridge_rpg" ] = [];
	level.border_enemies[ "border_buildings" ] = [];	
	//array_spawn_function_noteworthy( "actor_border_rocket", ::spawnfunc_enemy_border_bridge_rpg, "border_bridge_rpg" );
	//array_spawn_function_noteworthy( "actor_border_left_buildings", ::spawnfunc_enemy_building_side_spawn, "border_buildings" );
	array_spawn_function_noteworthy( "actor_border_right_buildings", ::spawnfunc_enemy_building_side_spawn, "border_buildings" );

	// Enemy vehicles drop off wave 2
	thread spawn_enemy_vehicle( "veh_1", "vehicle_enemy_1", "node_enemy_drive_in_1", "node_enemy_pickup_cover_1" );	
	thread spawn_enemy_vehicle( "veh_2", "vehicle_enemy_2", "node_enemy_drive_in_2", "node_enemy_pickup_cover_2" );	

	// Send enemies to border
	thread enemy_movement();

	// Razor Wire
	//thread razor_wire();

	// Kills snipers once player is in intersection
	thread advance_2_cleanup();

	// Cleans up rest of border
	thread border_cleanup();

	// Shut off building triggers once allies advance
	thread turn_off_spawners();																	

	// AUtosaves
	thread autosaves();		
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
	PreCacheShellShock( "nx_border_intro" );
	PreCacheModel( "nx_vehicle_border_hummer2" );	
}

section_flag_inits()
{
	flag_init( "flag_player_advance_1" );	
	flag_init( "flag_wave_1_half_dead" );
	flag_init( "flag_wave_1_almost_dead" );
	flag_init( "flag_wave_1_dead" );	
	flag_init( "flag_wave_2_half_dead" );
	flag_init( "flag_wave_2_almost_dead" );
	flag_init( "flag_wave_2_dead" );
	flag_init( "flag_advance_1_timeout" );
	flag_init( "flag_border_final_advance" );
	flag_init( "flag_border_done" );
	flag_init( "flag_advance_1" );	
	flag_init( "flag_advance_2" );
	flag_init( "flag_advance_3" );
	flag_init( "flag_border_intro_start" );
	flag_init( "flag_player_at_border" );
		
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_objectives( objective_num )
{
	level waittill( "notify_border_intro_player_anim_done" );

	objective_add( objective_num, "current", &"NX_BORDER_OBJECTIVE_BORDER" );			
	flag_wait( "flag_border_done" );	
	objective_complete( objective_num );

	objective_num++;

	return objective_num;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

autosaves()
{
	// Autosave after explosion
	//level waittill( "notify_border_explosion_done" );
	level waittill( "notify_border_intro_player_anim_done" );
	thread autosave_by_name( "border_intro_done" );

	// Autosave after all enemies dead
	flag_wait( "flag_border_done" );
	thread autosave_by_name( "border_done" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn convoy vehicles and allies
convoy_driveup()
{
	// Spawn vehicles and allies
	spawn_convoy_vehicles_and_allies();

	level.convoy_intro_speed = GetSpeedFromAnims();
	//level.convoy_intro_speed = 1;
	
	thread ally_movement();	

  	// Set vehicles on their paths
	level.vehicle_convoy[ "vehicle_convoy_1" ] 
	thread convoy_path_solo( 
		"node_convoy_start_1", 
		"node_convoy_1_stop_1", 
		"node_convoy_1_stop_2", 
		"node_convoy_1_stop_3", 
		"node_convoy_1_stop_4" 
	);

	level.vehicle_convoy[ "vehicle_convoy_2" ] 
	thread convoy_path_solo( 
		"node_convoy_start_2", 
		"node_convoy_2_stop_1", 
		"node_convoy_2_stop_2", 
		"node_convoy_2_stop_3", 
		"node_convoy_2_stop_4"  
	);	

	//tagJC<NOTE>: This section is for deleting the bad place brush.  Currently commented out until the convoy is moving again
	//delete_bad_place_node = GetVehicleNode ( "node_convoy_1_stop_1", "targetname" );
	//assert ( isDefined (delete_bad_place_node ));
	//delete_bad_place_node thread maps\nx_border_util::waitForVehicleToPass();
	//***********************************************************************************

	// Ally vehicle gets destroyed during intro
	level.vehicle_convoy[ "vehicle_convoy_kill" ] thread convoy_path_kill( "node_convoy_start_kill", "node_convoy_kill_1"  );		
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_convoy_vehicles_and_allies()
{
	// Get convoy vehicle spawners
	convoy_spawners = GetEntArray( "vehicle_convoy", "script_noteworthy" );
	Assert( IsDefined( convoy_spawners ));
	array_thread( convoy_spawners, ::add_spawn_function, ::spawnfunc_convoy_vehicle );

	// Setup ally spawners
	squad = GetEntArray( "actor_squad", "script_noteworthy" );
	Assert( IsDefined( squad ));	
	array_thread( squad, ::add_spawn_function, ::spawnfunc_allies );

	intro_hummer_allies = [];
	intro = false;
	
	// Spawn vehicles and allies
	foreach( vehicle in convoy_spawners )
	{		
		// Setup allies
		Assert( IsDefined( vehicle.targetname ));			
		Assert( IsDefined( vehicle.target ));

		// If it's the border checkpoint, add the other allies to the vehicle
		if(( level._start_point == "default" ) || ( level._start_point == "border" ))
		{
			intro = true;

			if( vehicle.targetname == "vehicle_convoy_1" )
			{
				allies = GetEntArray( vehicle.targetname + "_ally_group", "targetname" );
				Assert( IsDefined( allies ));
				foreach( spawner in allies )
				{
					// Allies with spawn with vehicle
					spawner.targetname = vehicle.target;						
				}				
			}
			else
			{
				allies = GetEntArray( vehicle.targetname + "_ally_group", "targetname" );
				Assert( IsDefined( allies ));
				foreach( spawner in allies )
				{
					// Spawn allies separate from hummer so we can apply intro anims
					ally = spawner spawn_ai();
					intro_hummer_allies = array_add( intro_hummer_allies, ally );
				}
			}
		}
		else
		{
			// Starting from another checkpoint (than border/default)
			allies = GetEntArray( vehicle.targetname + "_ally_group", "targetname" );
			Assert( IsDefined( allies ));
			foreach( ally in allies )
			{
				Assert( IsDefined( ally.script_startingposition ));

				// Attach drivers
				if( ally.script_startingposition == 0 )
					ally.targetname = vehicle.target;
			}
		}

		// Spawn vehicle
		level.vehicle_convoy[ vehicle.targetname ] = vehicle spawn_vehicle();
		level.vehicle_convoy[ vehicle.targetname ].script_parameters = vehicle.targetname;
	}	

	// Intro anims
	if( intro )
	{
		level.vehicle_convoy[ "vehicle_convoy_2" ] thread convoy_intro_anims( intro_hummer_allies );
	}
}

// spawnfunc for convoy vehicles
spawnfunc_convoy_vehicle()
{
	self godon();
}

// spawnfunc for allies
spawnfunc_allies()
{
	if( IsDefined( level.leader ))
	{
		if( self == level.leader )
		{
			return;
		}
	}

	self thread magic_bullet_shield();
	// tagTC<note> - Remove magic bullet shield when turret is destroyed 
	// or player has pushed through the intro blockade section
	flag_wait_either( "intro_turret_destroyed", "player_through_intro_funnel" );
	
	self stop_magic_bullet_shield();
}

// Wait for death, then report attacker
death_watch()
{
	self waittill( "death", attacker );
	iprintlnbold( attacker.classname );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Intro animations
convoy_intro_anims( riders )
{
	actors = [];

	//node = GetEnt( "intro_test", "targetname" );

	//anim_origin = spawn( "script_origin", self.origin );
	//anim_origin LinkTo( self, "tag_origin", (0, 0, 0), (0, 0, 0) );
	
	unload_guys = [];
	driver = undefined;
	
	// Setup guys
	Assert( IsDefined( riders ));
	foreach( guy in riders )
	{
		Assert( IsDefined( guy.script_startingposition ));
		
		switch( guy.script_startingposition )
		{
			case 0:
				guy.animname = "driver";
				driver = guy;				
				break;
			case 1:
				guy.animname = "passengerfront";
				unload_guys = array_add( unload_guys, guy );
				break;
			case 3:
				guy.animname = "passengerrear";
				unload_guys = array_add( unload_guys, guy ); 
				break;
			default:
				AssertMsg( "nx_border_border: Unknown ally vehicle starting position (" + guy.script_startingposition + ") for intro anim!" ); 
		}

		guy LinkTo( self );

		actors = array_add( actors, guy );		
	}	
	
	// Setup humvee, hide script vehicle, spawn in animated script model
	intro_hummer = spawn_anim_model( "player_humvee", ( self.origin ));

	// Windshield
	intro_hummer thread convoy_intro_anims_broken_windshield();
	intro_hummer thread maps\nx_border_fx::fx_hummer_interior_light();
	
	intro_hummer LinkTo( self );
	self Hide();
	actors = array_add( actors, intro_hummer );

	intro_hummer playsound("scn_border_intro_hummer_explo_lr");

	// Setup player to ride
	self thread player_driveup();
	
	// Start intro anims		
	flag_set( "flag_border_intro_start" );
	self anim_single( actors, "intro_ride", "tag_origin" ); 

	// End of animation 
	// unlink guys, show hummer
	level notify( "notify_border_intro_complete" );
	foreach( guy in unload_guys )
	{
		guy Unlink();
	}

	// Start driver idle	
	self thread anim_loop_solo( driver, "idle", undefined, "tag_driver" );
	
	// Put hummer back
	//self Show();
	//intro_hummer Delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

convoy_intro_anims_broken_windshield()
{
	// Hide broken windshield
	self HidePart( "TAG_GLASS_FRONT_D" );
	self HidePart( "TAG_GLASS_FRONT_FX" );

	level waittill( "notify_border_intro_player_loses_control" );		

	// Show broken windshield
	wait 0.5;
	self ShowPart( "TAG_GLASS_FRONT_FX" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Will return the mi/h to set vehicles at start of level based on anim times
GetSpeedFromAnims()
{
	humvee_anim_time = GetAnimLength( level._scr_anim[ "player_humvee" ][ "intro_ride" ] );
	player_anim_time = GetAnimLength( level._scr_anim[ "player_rig" ][ "intro_ride" ] );

	// Find time to explosion in hours	
	anim_time = (humvee_anim_time - player_anim_time) * ((1/60)/60);

	start = GetVehicleNode( "node_convoy_start_kill", "targetname" );
	end = GetVehicleNode( "node_convoy_kill_1", "targetname" );
	Assert( IsDefined( start ));
	Assert( IsDefined( end ));

	// Find distance from start node to explosion node (in miles).  Subtracting a bit since the vehicle hits the node is slightly out of alignment with the vehicle's origin.
	distance = ( Distance( start.origin, end.origin ) - 56 ) * 0.000015782828283;
	
	speed = distance / anim_time; 

	return speed;	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_enemy_vehicle( veh_name, tVehicle, sNodes_path, sNodes_cover )
{
	// Grab vehicle spawner
	vehicle = GetEnt( tVehicle, "targetname" );
	Assert( IsDefined( vehicle ));
	Assert( IsDefined( vehicle.target ));

	// Grab rider spawners
	targets = GetEntArray( vehicle.target, "targetname" );
	Assert( IsDefined( targets ));
	foreach( target in targets )
	{
		if( IsSubStr( target.classname, "actor" ))
		{
			target add_spawn_function( ::spawnfunc_enemy_vehicle );
		}
	}

	// Wait for first push
	flag_wait( "flag_advance_1" );	

	// Spawn and drive
	level.enemy_vehicles[ veh_name ] = vehicle spawn_vehicle_and_gopath();
	level.border_enemies[ veh_name ] = level.enemy_vehicles[ veh_name ].riders;	
	

	level.enemy_vehicles[ veh_name ] waittill( "reached_end_node" );	
	level.enemy_vehicles[ veh_name ] vehicle_unload();

	level notify( "notify_border_add_razor_wire" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Controls razor wire blocking border
razor_wire()
{
	wire_brush = GetEnt( "brushmodel_razorwire", "targetname" );
	Assert( IsDefined( wire_brush ));
	
	level waittill( "notify_border_add_razor_wire" );

	//
	// Razor wire pullout
	//
	enemy_pullout_wire = maps\_nx_vignette_util::vignette_actor_spawn("vignette_razorwire_enemy", "enemy_pullout_wire");	
	node = getstruct("vignette_razorwire", "script_noteworthy");
	razorwire = spawn_anim_model("razorwire_pullout");
	razorwire02 = spawn_anim_model("razorwire_pullout_02");
	Assert( IsDefined( enemy_pullout_wire ));
	Assert( IsDefined( node ));
	Assert( IsDefined( razorwire ));

	guys = [];
	guys["enemy_pullout_wire"] = enemy_pullout_wire;
	guys["razorwire_pullout"] = razorwire;
	guys["razorwire_pullout_02"] = razorwire02;

	node anim_single(guys, "razorwire_pullout");

	enemy_pullout_wire maps\_nx_vignette_util::vignette_actor_delete();

	//
	// Razor wire pullback
	//
	level waittill( "notify_border_outro_remove_wire" );	

	while( 1 )
	{
		ally = random( level.allies );
		if( ally.script_startingposition != 0 )
			break;
	}


	ally.animname = "ally_pullback_wire";
	razorwire.animname = "razorwire_pullback";
	razorwire02.animname = "razorwire_pullback_02";
	guys = [];
	guys["ally_pullback_wire"] = ally;
	guys["razorwire_pullback"] = razorwire;
	guys["razorwire_pullback_02"] = razorwire02;

	ally playsound("scn_border_barbed_wire_remove");

	node anim_reach_solo( guys["ally_pullback_wire"], "razorwire_pullback" );
	node anim_single( guys, "razorwire_pullback" );		

	level notify( "notify_border_razor_wire_done" );

	// Wait until last line, then put ally back on color grid
	level waittill( "notify_border_outro_dialogue_complete" );

	//
	// Connect paths and done!
	//
	wire_brush ConnectPaths();
	wire_brush Delete();

	ally enable_ai_color();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Ally hummer bumps enemy vehicle
convoy_vehicle_bump()
{
	// Wait until the specified "bump" vehicle node
	self vehicle_waittill_node( "node_border_vehicle_bump", "targetname" );
	level notify( "notify_border_hummer_bump" );	
	
	// Enemy vehicle
	enemy_veh = level.enemy_vehicles[ "veh_1" ];		
	
	// Ally vehicle speeds through and bumps enemy vehicle
	force_pos = enemy_veh.origin + (((-1) * AnglesToForward( enemy_veh.angles )) * 32 );
	force_vec = (((-1) * AnglesToRight( self.angles )) + AnglesToForward( self.angles )) * 100; 	
	self playsound( "scn_border_humvee_hit" );
	self Vehicle_SetSpeed( 15, 5 );
	
	wait 0.5;

	enemy_veh VehPhys_Launch( force_vec, undefined, force_pos );	
	//enemy_veh PlaySound( "scn_car_crash" );

	wait 1;

	self ResumeSpeed( 3 );	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Player's drive up sequence
player_driveup()
{
	// Set up player legs
	player_legs_spawner = GetEnt( "actor_border_intro_player_legs", "targetname" );
	Assert( IsDefined( player_legs_spawner ));
	//player_legs = player_legs_spawner spawn_ai();
	//Assert( IsDefined( player_legs ));
	//player_legs.animname = "player_legs";

	// Take weapons
	enablePlayerWeapons( false );

	level._player allowprone( false );
    level._player allowcrouch( false );

	// Bulletproof
	level._player magic_bullet_shield();
	level._player.ignoreme = true;

	// Setup the player's rig and attach to hummer
	player_rig = spawn_anim_model( "player_rig" );
	player_rig.angles = self getTagAngles( "tag_passenger" );

	// Adjust player position in car relative to the "tag_passenger"
	player_rig.origin = self getTagOrigin( "tag_passenger" ) 
		- (0,0,92)		 
		+ vector_multiply( (-1) * AnglesToForward( self.angles ), 45 ) 
		+ vector_multiply( (-1) * AnglesToRight( self.angles ), 57 );	

	player_rig linkTo( self, "tag_passenger" );
	//player_rig hide();
	level._player playerLinkToDelta( player_rig, "tag_player", 1.0, 80, 80, 60, 20 );
	
	// Wait for notetrack, then take player control away and play	
	level waittill( "notify_border_intro_player_loses_control" );
	//level._player playerLinkToDelta( player_rig, "tag_origin", 0, 0, 0, 0, 0 );
	level._player shellshock( "nx_border_intro", 8 );
	self thread maps\nx_border_fx::fx_border_cabin_smoke();

//	PlayFX( GetFx( "border_intro_smoke" ), self.origin );
	//self thread anim_single_solo( player_legs, "intro_ride" );
	self anim_single_solo( player_rig, "intro_ride" );

	/*
	// Wait for convoy unload
	self waittill( "notify_unloading_convoy" );

	// Unload player (Spawn an exit point location and move player to it)
	exit_point = spawn_tag_origin();
	exit_point.origin = GetGroundPosition( player_rig.origin + vector_multiply( (-1) * AnglesToRight( self.angles ), 40 ), 5 );
	exit_point.angles = self.angles;
	dummy = spawn( "script_model", level._player.origin );
	dummy.angles = level._player GetPlayerAngles();
	dummy setmodel( "tag_origin" );
	level._player playerLinkTo( dummy, "tag_player", 1.0, 45, 45, 45, 20 );	
	MOVETIME = 1.5;
	ACCEL = 0.3;
	DECEL = 0.3;
	dummy moveTo( exit_point.origin, MOVETIME, ACCEL, DECEL );
	dummy rotateTo( exit_point.angles, MOVETIME, ACCEL, DECEL );
	
	wait( MOVETIME );
	//level waittill( "notify_border_intro_complete" );
	*/
	
	level notify( "notify_border_intro_player_anim_done" );

	// UnBulletproof
	level._player stop_magic_bullet_shield();
	level._player.ignoreme = false;

	level._player unlink();			
	player_rig delete();
	//player_legs delete();
	flag_set( "music_battle_start" );	

	// Give player weapons
	enablePlayerWeapons( true );	
	level._player allowprone( true );
    level._player allowcrouch( true );
		
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Controls movement of convoy vehicles
convoy_path_solo( start_node, stop_node_1, stop_node_2, stop_node_3, stop_node_4 )
{
	flag_wait( "flag_border_intro_start" );

	// Setup start of path and move
	path = GetVehicleNode( start_node, "targetname" );
	Assert( IsDefined( path ));
	self AttachPath( path );	
	self Vehicle_SetSpeedImmediate( level.convoy_intro_speed, level.convoy_intro_speed );	
	self StartPath();
																								
	// First stopping point
	self vehicle_waittill_node( stop_node_1, "targetname" );
	self Vehicle_SetSpeed( 0, 10 );	

	// Unload
	self notify( "notify_unloading_convoy" );
	level notify( "notify_unloading_convoy" );		

	Assert( IsDefined( self.script_parameters ));
	if( self.script_parameters == "vehicle_convoy_1" )
		self vehicle_unload();

	/*
	flag_wait( "flag_advance_1" );

	// Wait for convoy_1 to move first
	Assert( IsDefined( self.script_parameters ));
	if( self.script_parameters == "vehicle_convoy_2" )
		wait( 1 );

	self Vehicle_SetSpeed( 3, 1 );

	self thread maps\nx_border_util::actor_detection_movement_control( 300, 45 );

	// Second stopping point
	self vehicle_waittill_node( stop_node_2, "targetname" );
	self notify ( "terminate_actor_detection" );
	self Vehicle_SetSpeed( 0, 10 );
	
	flag_wait( "flag_advance_2" );

	// Wait for convoy_1 to move first
	Assert( IsDefined( self.script_parameters ));
	if( self.script_parameters == "vehicle_convoy_2" )
		wait( 1 );

	self ResumeSpeed( 3 );

	self thread maps\nx_border_util::actor_detection_movement_control( 300, 45 );

	// Third stopping point
	self vehicle_waittill_node( stop_node_3, "targetname" );
	self notify ( "terminate_actor_detection" );
	self Vehicle_SetSpeed( 0, 10 );
	
	flag_wait( "flag_border_final_advance" );
	
	// Wait for convoy_1 to move first, if convoy 1, setup bump 
	Assert( IsDefined( self.script_parameters ));
	if( self.script_parameters == "vehicle_convoy_2" )
	{
		wait( 1 );
		self ResumeSpeed( 3 );
		self thread maps\nx_border_util::actor_detection_movement_control( 300, 45 );
	}
  	else
	{
		// Vehicle 1 convoy bump sequence
		self ResumeSpeed( 3 );
		self thread maps\nx_border_util::actor_detection_movement_control( 300, 45 );
		self convoy_vehicle_bump();
	}

	// Last stopping point
	self vehicle_waittill_node( stop_node_4, "targetname" );
	self notify ( "terminate_actor_detection" );
	self Vehicle_SetSpeed( 0, 10 );
	
	level notify( "notify_convoy_stopped" );	
	*/
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Convoy vehicle that gets killed
convoy_path_kill( start_node, stop_node_1 )
{
	// Setup start of path and move
	path = GetVehicleNode( start_node, "targetname" );
	Assert( IsDefined( path ));
	self AttachPath( path );
	self Vehicle_SetSpeed( level.convoy_intro_speed, 1 );							  
	self StartPath();
	self thread maps\nx_border_fx::fx_border_explosion();
																								
	self waittill( "reached_end_node" );
	
	// Flip vehicle and kill it
	self VehPhys_Launch( (AnglesToUp( self.angles ) + ((-1) * AnglesToRight( self.angles ))) * 40000, undefined, self.origin + vector_multiply( AnglesToRight( self.angles ), 32) );
	self kill();

	//slowmo();
	level notify( "notify_border_explosion_done" );
}

slowmo()
{
	// Don't slowmo sounds
	SoundSetTimeScaleFactor( "Mission", 0 );
	SoundSetTimeScaleFactor( "Shellshock", 0 );
	SoundSetTimeScaleFactor( "Voice", 0 );
	SoundSetTimeScaleFactor( "Menu", 0 );
	SoundSetTimeScaleFactor( "Effects1", 0 );
	SoundSetTimeScaleFactor( "Effects2", 0 );
	SoundSetTimeScaleFactor( "Announcer", 0 );
	SoundSetTimeScaleFactor( "Music", 0 );
	SoundSetTimeScaleFactor( "vignette3d", 0 );
	SoundSetTimeScaleFactor( "vignette2d", 0 );
	SoundSetTimeScaleFactor( "ambient", 0 );
	SoundSetTimeScaleFactor( "weapon", 0 );
	SoundSetTimeScaleFactor( "weapon2d", 0 );
	SoundSetTimeScaleFactor( "auto2d", 0 );
	SoundSetTimeScaleFactor( "auto", 0 );
	SoundSetTimeScaleFactor( "auto2d", 0 );
	SoundSetTimeScaleFactor( "element", 0 );
	SoundSetTimeScaleFactor( "local", 0 );
	SoundSetTimeScaleFactor( "local3", 0 );	
	SoundSetTimeScaleFactor( "physics", 0 );
	
	// Start slow motion
	slowmo_setspeed_slow( 0.5 );
	slowmo_setlerptime_in( 0 );
	slowmo_lerp_in();
	
	level._player SetMoveSpeedScale( 0.1 );
	 
	// Wait slow mo duration	
	wait( 2 );

	// Stop slo motion
	slowmo_setlerptime_out( 0 );
	slowmo_lerp_out();	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Controls movement of allies
ally_movement()
{
	badplace = GetEnt( "vol_border_badplace_1", "targetname" );
	Assert( IsDefined( badplace ));
	badplace DisconnectPaths();

	// Timer to force first advancement of allies
	//thread advance_1_timeout();
		
	level waittill( "notify_unloading_convoy" );
	issue_color_orders( "r1", "allies" );
	issue_color_orders( "y1", "allies" );

	flag_wait_any( "flag_wave_1_almost_dead", "flag_player_advance_1", "flag_advance_1_timeout" );

	flag_set( "flag_advance_1" );
	level notify( "notify_spawn_wave_2" );
	
	badplace ConnectPaths();
	badplace delete();	

	//issue_color_orders( "r2", "allies" );
	//issue_color_orders( "y2", "allies" );

	// Wait for two vehicles to spawn
	while( level.enemy_vehicles.size < 2 )
		wait 0.05;

	thread enemy_dead_flag_set( "all", 7, "flag_advance_2", "notify_spawn_border_rpgs" );
	flag_wait_any( "flag_advance_2", "flag_player_advance_2" );
	flag_set( "flag_advance_2" );	
	level notify( "notify_spawn_border_rpgs" );

	//issue_color_orders( "r3", "allies" );
	//issue_color_orders( "y3", "allies" );

	/*
	flag_wait( "flag_border_done" );
	
	issue_color_orders( "r4", "allies" );
	issue_color_orders( "y4", "allies" );
	
	level waittill( "notify_border_outro_dialogue_complete" );	
	*/
	
	// Up ally accuracy to take out stragglers in retreat
	level waittill( "notify_border_final_retreat" );
	
	foreach( guy in level.allies )
	{
		guy.baseaccuracy = 10000;
	}
	
	// Disable color triggers
	triggers = GetEntArray( "trig_border_colors", "script_noteworthy" );	
	Assert( IsDefined( triggers ));

	foreach( trigger in triggers )
		trigger trigger_off();

	wait( 0.05 );

	issue_color_orders( "r99", "allies" );
	issue_color_orders( "y99", "allies" );

	flag_wait( "flag_border_done" );

	// Return ally accuracy after all enemies dead
	foreach( guy in level.allies )
	{
		guy.baseaccuracy = 1;
	}

	issue_color_orders( "r100", "allies" );
	issue_color_orders( "y100", "allies" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Player reaches border
player_at_border()
{
	trigger_wait_targetname( "trig_border_player_at_border" );
	flag_set( "flag_player_at_border" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_in_side_building()
{
	level endon( "flag_border_done" );

	trigger_wait_targetname( "trig_border_player_in_right_building" );
	SetThreatBias( "enemies", "player", 1000 );
   
	// Have allies take out RPGs so they can progress
	foreach( guy in level.border_enemies[ "border_rpg" ] )
	{
		if( IsAlive( guy ))
	 	{
			foreach( ally in level.allies )
			{
				ally.favoriteenemy = guy;
				ally.baseaccuracy = 1000;
			}

			while( IsAlive( guy ))
				wait( 0.05 );
		}
	}

	while( IsAlive_array( level.border_enemies[ "border_rpg" ] ))
		wait 0.05;

	// Lower ally accuracy
	foreach( ally in level.allies )
	{
		ally.baseaccuracy = 1;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_on_rooftop()
{
	level endon( "flag_border_done" ); 

	while( 1 )
	{
		flag_wait( "flag_border_player_rooftop" );
		SetThreatBias( "enemies", "player", 1000 );
		flag_waitopen( "flag_border_player_rooftop" );
		SetThreatBias( "enemies", "player", 0 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

border_dialogue()
{
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
/*
	//
	// Intro
	//

	// Dialogue: Loudspeaker - "Mexico is a sovreign country and we will not submit to this unauthorized invasion of our border.  
	//						Proceed and you will be fired upon with the full resources of the Mexican Army.  Stop and stand down."
	thread radio_dialogue( "bor_ancr_intro_warning" );

	wait 3;

	// Dialogue: Chief - "Convoy 6-2, Battalion Chief, proceed with assault plan Alpha, 
	//				I repeat proceed with assault plan Alpha and push through the checkpoint into Mexico to establish our buffer zone."
	radio_dialogue_overlap( "bor_chf_intro_proceed" );

	// Dialogue: Leader - "Get ready fellas, this might get hairy quick."
	radio_dialogue_overlap( "bor_bak_intro_mightgethairy" );

	// Dialogue: Humvee Driver - "Hooah"
	thread radio_dialogue_overlap( "bor_hum_intro_hooah" );

	// Dialogue: Ally - "Hooah"
	thread radio_dialogue_overlap( "bor_gon_intro_hooah" );

	wait 7;

	// Dialogue: Chief - "Incoming R-P-!" (get's cutoff by the explosion)
	radio_dialogue_overlap( "bor_chf_intro_incoming" );
	
	wait 2;

	// Dialogue: Humvee Driver - "Shit, everybody ok?"
	radio_dialogue( "bor_hum_intro_everybodyok" );

	wait 1;

	// Dialogue: Leader - "Exit the vehicle!"
	radio_dialogue( "bor_bak_intro_exitvehicle" );

	// Dialogue: Ally - (Grunts, Groans, trying to free himself of his seatbelt)
	thread radio_dialogue( "bor_gon_intro_grunts" );

	wait 1;

	// Dialogue: Humvee Driver - "You, get out, go, go, go!"
	thread radio_dialogue_overlap( "bor_hum_intro_getoutgogogo" );

	wait 2;

	// Dialogue: Leader - "C'mon!  Let's go!"
	radio_dialogue_overlap( "bor_bak_intro_cmonletsgo" );
*/
	level waittill( "notify_border_intro_player_anim_done" );

	flag_wait( "flag_advance_1" );

	// Dialogue: Leader - "Panther One to Olympus, come in!"
	level.leader dialogue_queue( "bor_bak_battle_olympuscomein" );	

	// Dialogue: Command - "Panther One, this is Olympus, what is your sitrep?  Over."
	radio_dialogue( "bor_oly_battle_sitrep" );

	// Dialogue: Leader - "We're encountering heavy fire at the border checkpoint, over!"
	level.leader dialogue_queue( "bor_bak_battle_heavyfire" );	

	// Dialogue: Command - "Roger Panther One.  Hawks with eggs are inbound.  ETA 2 mikes."
	radio_dialogue( "bor_oly_battle_hawksinbound" );

	battlechatter_on( "allies" );
	battlechatter_on( "axis" );

	//
	// RPGs above border
	//
	thread border_dialogue_border_rpgs();

	//
	// Hummer bumps enemy vehicle
	//
	//thread border_dialogue_hummer_bump();

	//
	// End of border encounters
	//						
	flag_wait( "flag_border_done" );	

	wait (0.75);

	// Dialogue: Leader - "We're clear.  Move up!"
	level.leader dialogue_queue( "bor_bak_barricade_moveup" );	
	
	radio_dialogue( "bor_oly_barr_blackhawksready" );

	wait (0.6);

	radio_dialogue( "bor_eag_barricade_inairspace" );
	
	//need this flag so the next vo doesn't start too early.  this transition is complicated.
	flag_set( "vo_border_section_done");

	level notify( "notify_move_to_streets" );
	


	//
	// Calling in for support
	//

	//level notify( "notify_border_outro_dialogue_start" );	

	//
	// Blockade removal scene
	//
	//trigger_wait_targetname( "trig_border_blockade_dialogue" );
	//flag_wait( "flag_border_start_wire_cut" );
	
   	// dialogue: Leader - "Kimoto, Friedrich, get that razor wire off the road!"
	//radio_dialogue( "bor_bak_barricade_razorwire" );
	
	//level notify( "notify_border_outro_remove_wire"	);

	//level waittill( "notify_border_razor_wire_done" );

	// Dialogue: Leader - "Alright, let's move!"
	//radio_dialogue( "bor_bak_barricade_letsmove" );	

	//level notify( "notify_border_outro_dialogue_complete" );	
}

border_dialogue_border_rpgs()
{
	level endon( "flag_border_done" );

	level waittill( "notify_spawn_border_rpgs" );

	wait 4;

	// Dialogue: Leader - "RPGs.  12 o'clock.  Above the checkpoint.  Take 'em out!"
	level.leader dialogue_queue( "bor_bak_border_rpgs12oclock" );	
}

border_dialogue_hummer_bump()
{
	level endon( "notify_border_outro_dialogue_start" );

	level waittill( "notify_border_hummer_bump" );

	// Dialogue: Humvee Driver - "Pardon me, comin' through!"
	radio_dialogue( "bor_hum_hit_pardonme" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

enemy_dead_flag_set( enemy_group, number, flag, end_notify )
{
	level endon( end_notify );
																			  
	enemies = [];

	if( enemy_group == "all" )
	{
		enemies = GetAIArray( "axis" );
	}
	else
	{
		Assert( IsDefined( level.border_enemies[ enemy_group ] ));
		enemies = level.border_enemies[ enemy_group ];
	}	
	
	while( enemies.size > number )
	{
		enemies = remove_dead_from_array( enemies );
		wait 0.05;
	}

	flag_set( flag );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Force ally advance after a certain time period
advance_1_timeout()
{
	 level waittill( "notify_unloading_convoy" );

	 wait 30;

	 flag_set( "flag_advance_1_timeout" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

advance_2_cleanup()
{
	flag_wait( "flag_advance_2" );
	kill_deathflag( "flag_border_sniper_kill", 3 );
}

border_cleanup()
{
	flag_wait( "flag_player_at_border" );
	kill_deathflag( "flag_border_sniper_kill_2", 2 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn rooftop enemies
spawn_enemy_rooftops( wave_name, noteworthy, waittill_notify, spawnfunc )
{
	level waittill( waittill_notify );

	guys = GetEntArray( noteworthy, "script_noteworthy" );
	Assert( IsDefined( guys ));

	array_thread( guys, ::add_spawn_function, spawnfunc );
	level.border_enemies[ wave_name ] = array_spawn( guys );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn ground enemies
spawn_enemy_ground_wave( noteworthy, waittill_notify, spawnfunc, half_dead_flag, almost_dead_flag, full_dead_flag )
{
	level waittill( waittill_notify );

	spawners = GetentArray( noteworthy, "script_noteworthy" );
	Assert( IsDefined( spawners ));

	array_thread( spawners, ::add_spawn_function, spawnfunc );

 	enemies = [];

	foreach( spawner in spawners )
	{
		guy = spawner spawn_ai();
		enemies = array_add( enemies, guy );
	}

	if( isdefined( half_dead_flag ))
		thread spawnfunc_enemy_ground_wave_flags( enemies, spawners.size, half_dead_flag, almost_dead_flag, full_dead_flag );

	return enemies;
}

spawnfunc_enemy_ground_wave_flags( enemies, spawner_size,  half_dead_flag, almost_dead_flag, full_dead_flag )
{
	// Some enemies are dead
	while( enemies.size > int( (spawner_size / 3) * 2 ))
	{
		enemies = remove_dead_from_array( enemies );
		wait 0.05;
	}

	flag_set( half_dead_flag );

	// Almost all enemies are dead
	while( enemies.size > int( spawner_size / 3))
	{
		enemies = remove_dead_from_array( enemies );
		wait 0.05;
	}

	flag_set( almost_dead_flag );

	while( enemies.size > 0 )
	{
		enemies = remove_dead_from_array( enemies );
		wait 0.05;
	}

	flag_set( full_dead_flag );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawnfunc_enemy_rooftops_bridge()
{
	self endon( "death" );

	self.goalradius = 5;
	self.ignoreall = true;
	self.border_ground = true;
	self.maxfaceenemydist = 1024;

	self SetThreatBiasGroup( "enemies" );

	self waittill( "goal" );
	self.ignoreall = false;
}

spawnfunc_enemy_initial_ground_wave()
{
	self.goalradius = 256;
	self.border_ground = true;
	self.maxfaceenemydist = 1024;

	self SetThreatBiasGroup( "enemies" );

	self SetGoalVolumeAuto_targetname( "vol_enemy_initial" );
}

spawnfunc_enemy_murder_squad()
{
	self.goalradius = 256;
	self.border_ground = true;
	self.maxfaceenemydist = 1024;

	self.baseaccuracy = 10000;
	self.border_action = "player_seek";

	self SetThreatBiasGroup( "enemies" );
	self thread player_seek_enable();
}
								   
spawnfunc_enemy_initial_ground_wave_island()
{
	self.goalradius = 256;
	self.border_ground = true;
	self.maxfaceenemydist = 1024;

	self SetThreatBiasGroup( "enemies" );

	self SetGoalVolumeAuto_targetname( "vol_enemy_initial_island" );
}								   

spawnfunc_enemy_vehicle()
{
	self.goalradius = 256;
	self.border_ground = true;
	self.maxfaceenemydist = 1024;

	self SetThreatBiasGroup( "enemies" );

	pullback_volume = GetEnt( "vol_border_pullback_first", "targetname" );
	Assert( IsDefined( pullback_volume ));

	self SetGoalVolumeAuto( pullback_volume );
}

#using_animtree( "generic_human" );
spawnfunc_enemy_rooftops_rpg()
{
	self endon( "death" );

	//death_anims = [	%death_rooftop_B, %death_rooftop_C, %death_rooftop_D ];
	//self.deathanim = random( death_anims );
	//self set_allowdeath( true );
	self.health = 1;
	self.goalradius = 256;
	self.border_ground = false;	
	self.ignoreall = true;

	self SetThreatBiasGroup( "enemies" );
	
	level waittill( "notify_border_intro_player_anim_done" );
	self.ignoreall = false;
}

spawnfunc_enemy_building_side_spawn( wave_name )
{
	self.goalradius = 256;
	self.border_ground = true;
	self.maxfaceenemydist = 1024; 
	
	self SetThreatBiasGroup( "enemies" ); 																			 

	// Trigger spawned, add to array here
	Assert( IsDefined( wave_name ));
	level.border_enemies[ wave_name ] = array_add( level.border_enemies[ wave_name ], self );
}

spawnfunc_enemy_border_bridge_rpg()
{
	self endon( "death" );

	//death_anims = [	%death_rooftop_B, %death_rooftop_C, %death_rooftop_D ];
	//self.deathanim = random( death_anims );
	//self set_allowdeath( true );
	self.goalradius = 5;
	self.ignoreall = true;
	self.border_ground = false;
	self.health = 1;

	self SetThreatBiasGroup( "enemies" );

	self waittill( "goal" );
	self.ignoreall = false;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Turn off triggers after allies advance into checkpoint (to avoid backspawning)
turn_off_spawners()
{	
	flag_wait( "flag_advance_2" );

	triggers = GetEntArray( "trig_border_side_spawners", "script_noteworthy" );
	Assert( IsDefined( triggers ));

	foreach( trigger in triggers )
	{
		trigger trigger_off();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Main enemy control and cleanup func for border
enemy_movement()
{
	thread player_in_side_building();
	thread player_on_rooftop();

	// Prepare murder squad if player feels like going rambo
	thread enemy_movement_player_rambo();

	// If player doesn't initiate rambo, last enemies will retreat at end
	thread enemy_movement_final_retreat();

	flag_wait( "flag_advance_1" );

	// Enemies pull back on ally advance
	thread enemy_pullback( "vol_border_pullback_first" );

	flag_wait( "flag_advance_2" );

	// Pullback to border
	level notify( "notify_pullback_clear" );
	thread enemy_pullback( "vol_border" );				
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

enemy_movement_final_retreat()
{
	level endon( "notify_murder_squad_enabled" );

	flag_wait( "flag_advance_2" );

	// Build an array of the remaining ground enemies
	all_enemies = GetAIArray( "axis" );
	retreating_enemies = [];
	ground_enemies = [];

	foreach( guy in all_enemies )
	{
		if( IsAlive( guy ))
		{
			if( guy.border_ground )
				ground_enemies = array_add( ground_enemies, guy );
		}
	}

	// Wait until only a few enemies left
	while( 1 )
	{
		ground_enemies = remove_dead_from_array( ground_enemies );
		if( ground_enemies.size < 5 )
			break;

		wait( 0.05 );
	}

	// Kill deathsquad spawn
	level notify( "notify_border_stop_murder_squad" );

	// Enemies retreat
	foreach( enemy in ground_enemies )
	{
		if( IsAlive( enemy ))
		{
			enemy ClearGoalVolume();
			enemy SetGoalVolumeAuto_targetname( "vol_border_final_retreat" );
			enemy.goalradius = 2000;
			enemy.health = 20;
			enemy.ignoreall = true;
			enemy.border_action = "retreat";
			retreating_enemies = array_add( retreating_enemies, enemy );
		}
	}	

	thread AI_delete_when_out_of_sight( retreating_enemies, 2048 );

	// Give enemies a head start
	wait 1.5;																		

	level notify( "notify_border_final_retreat" );

	ground_enemies = remove_dead_from_array( ground_enemies );

	waittill_dead( ground_enemies, ground_enemies.size, 5 );
	
	flag_set( "flag_border_done" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// If the player tries to rambo through, make it very dangerous
enemy_movement_player_rambo()
{
	level endon( "flag_border_done" );
	level endon( "notify_border_stop_murder_squad" );

	flag_wait( "flag_player_at_border" );

	// Kill final retreat
	level notify( "notify_murder_squad_enabled" );

	num = GetAICount( "axis" );
	SetThreatBias( "enemies", "player", 1000 );

	array_spawn_function_targetname( "actor_border_murder_squad", ::spawnfunc_enemy_murder_squad );
	level.border_enemies[ "murder_squad" ] = array_spawn_targetname( "actor_border_murder_squad" ); 
	
	// Clear any volume advances
	level notify( "notify_pullback_clear" );

	// Enemies accurate and gunning for player
	foreach( group in level.border_enemies )
	{
		foreach( enemy in group )
		{
			if( IsAlive( enemy ))
			{
				enemy thread player_seek_enable();
				enemy.baseaccuracy = 10000;
				enemy.border_action = "player_seek";
			}
		}
	}

	enemies = GetAIArray( "axis" );

	waittill_dead( enemies );

	flag_set( "flag_border_done" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Ground enemies pull back to volume
enemy_pullback( tVol )
{
	level endon( "notify_pullback_clear" );

	guys = [];

	if( self == level )
	{
		foreach( group in level.border_enemies )
		{
			foreach( guy in group )
			{
				if( IsAlive( guy ))
					guys = array_add( guys, guy );
			}
		}
	}
	else
	{
		guys = self;
	}	

	foreach( enemy in guys )
	{
		if( IsAlive( enemy ))
		{
			if( enemy.border_ground )
			{
				wait_random( 0, 0.5 );
				enemy SetGoalVolumeAuto_targetname( "vol_border" );				
			}
		}
	}
}


retreat_check()
{
	while( 1 )
	{
		enemies = GetAIArray( "axis" );

		foreach( guy in enemies )
		{
			if( guy.border_ground )
			{
				if(( guy._goal_volume.targetname != "vol_border_final_retreat" ) || ( guy.border_action != "retreat" ))
					AssertMsg( "fail" );
			}

		}

		wait 0.05;
	}
}
