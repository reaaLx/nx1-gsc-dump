
//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  MISSION DESCRIPTION											**
//                                                                          **
//    Created: 8/25/2011 - Brian Marvin										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_utility_code;
#include maps\_nx_objective_util;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_nx_utility;
#include common_scripts\_nx_fx;
#include maps\nx_skyscraper_util;

//*******************************************************************
// Halon 			                                                *
//                                                                  *
//*******************************************************************

// Halon playerstart function
start_halon()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_halon" );
	thread maps\nx_skyscraper_fx::set_vision_and_fog("interior", 0); // set appropriate vision and fog
	maps\nx_skyscraper_util::player_weapon_init( true );
	level._player SwitchToWeapon( "lancer_xray" );	

	thread maps\_utility::set_ambient( "amb_skyscraper_robotics_int" );	

	maps\nx_skyscraper_util::spawn_baker();
	baker_teleport = GetEnt( "baker_halon_teleport", "targetname" );

	Assert( IsDefined( baker_teleport ));

	level.baker ForceTeleport( baker_teleport.origin, baker_teleport.angles);	
	issue_color_orders( "r70", "allies" );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

// Main halon section threads
sequence_halon()
{	
	trigger_wait_targetname( "trig_halon_button" );

	battlechatter_on( "axis" );
	
	thread autosave_now();

	level._player.ignoreme = true;

	thread exit_lights();
	
	// Spawn halon
	thread spawn_halon_gas();
	
	thread halon_transport_cover();	
	 
	// Clean up stragglers (debug)	
	/*
	aAI = getaiarray();	
	foreach( ai in aAI )
	{ 
		ai maps\_nx_utility::delete_ai_not_bullet_shielded();	
	}
	*/

	if( !flag( "flag_halon_robot_arms_moving" ))
	{
		thread maps\nx_skyscraper_lab_to_vault::robot_arm_move( "model_robot_arm_3", "origin_robot_arm_3_pos_2" );	
		thread maps\nx_skyscraper_lab_to_vault::robot_arm_move_slide( "model_robot_arm_slide_1", ( 1, 0, 0 ) );
		thread maps\nx_skyscraper_lab_to_vault::robot_arm_move_slide( "model_robot_arm_slide_2", ( -1, 0, 0 ) );
	}
	
	thread halon_enemies();
	level.baker thread baker_move_halon();	
	
	// Wait for player to turn on halon
	level waittill( "notify_halon_on" );

	iprintlnbold( "[ BAKER OPENS DOOR ]" );

	wait 1;

	// Dialogue - Baker: "Get down into the gas."
	level.baker dialogue_queue( "sky_bak_halon_getdownintogas" );
	//thread add_dialogue_line( "Baker", "Get down into the gas.", "g" );	

	// Player jumps over railing
	trigger_wait_targetname( "trig_baker_halon_1" );

	// Player must crouch for cover
	thread low_cover_on( 64, true, level.enemies[ "halon_uav" ], 400 );
	thread fx_player_fog();

	wait 1;

	level._player.ignoreme = false;		

	// Wait for floor enemies to die	
	flag_wait( "flag_halon_floor2_enemies_dead" );	

 	// Wait for catwalk enemies to die
	flag_wait( "flag_halon_catwalk_enemies_dead" );
	
 	// Player reaches office
	flag_set( "flag_halon_finished" );
	level notify( "notify_stop_halon" );
	low_cover_off();
}		

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

baker_uav_kill()
{
	if( IsAlive( level.enemies[ "halon_uav" ][ 0 ] ))
	{
		self.favoriteenemy =	level.enemies[ "halon_uav" ][ 0 ];
		self.baseaccuracy = 1000;
		level.enemies[ "halon_uav" ][ 0 ] waittill( "death" );
		self.baseaccuracy = 1;
	}
}
									   
//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************
									   
halon_transport_cover()
{
	// show halon encounter transports
	transports = GetEntArray( "halon_transports", "script_noteworthy" );
	Assert( IsDefined( transports ));

	foreach( thing in transports )
	{
		thing show();
	}
	
}									   

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

hint_crouch_for_cover()
{
	return false;
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

exit_lights()
{
	exit_lights_origins = GetEntArray( "origin_spinning_emergency_light", "script_noteworthy" );
	Assert( IsDefined( exit_lights_origins ));

	exit_lights = undefined; 

	for( i = 0; i < exit_lights_origins.size; i++ )
	{
		new_model = spawn_tag_origin();
		new_model.origin = exit_lights_origins[ i ].origin; 
		PlayFXOnTag( level._effect[ "spotlight_red" ], new_model, "tag_origin" );	
		new_model thread exit_lights_rotate_solo();
		exit_lights[i] = new_model;
	}
}	

exit_lights_rotate_solo()
{
	while( 1 )
	{
		self RotateYaw( 360, 1 );
		wait 1;
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

// Setup initial button states
halon_initial_state()
{
	// Hide active button
	button_active = GetEnt( "trig_halon_button_use", "targetname" );

	Assert( IsDefined( button_active ));

	button_active hide();
}									

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

baker_move_halon()
{	
	// Dialogue: Baker - "Fuck, looks like we've got company on the other side.  Pull the halon, we'll use it for cover."
	level.baker dialogue_queue( "sky_bak_halon_pullhalon" );
	//thread add_dialogue_line( "Baker", "Fuck, looks like we've got company on the other side.  Pull the halon, we'll use it for cover.", "g" );

	level notify( "notify_pull_halon" );

	// dialogue: Baker - "Use X-Ray to see the tangos"
	level.baker dialogue_queue( "sky_bak_halon_usexray" );
	//thread add_dialogue_line( "Baker", "Use X-Ray to see the tangos.", "g" );

	// Baker won't go down
	self disable_pain();

	// Spawn second guy to die on the floor
	rambo_spawner = GetEnt( "actor_baker_elite_kill", "targetname" );
	Assert( IsDefined( rambo_spawner ));
	
	// Baker waits for player to press the button	
	self.goalradius = 8;		
	self.maxvisibledist = 128;	
	self.ignoreme = true;	
	
	baker_wait_node = GetNode( "node_baker_halon_wait", "targetname" );
	self SetGoalNode( baker_wait_node );
	
	// Baker moves
	self waittill( "notify_smoke_start" );

	wait 4;
	
	// spawn melee guy, play melee anime
	melee_node = GetEnt( "origin_halon_melee_guy", "targetname" );
	Assert( IsDefined( melee_node ));
	
	bad_guy_spawner = GetEnt( "actor_halon_guy", "script_noteworthy" );
	Assert( IsDefined( bad_guy_spawner ));

	bad_guy = bad_guy_spawner spawn_ai();
	bad_guy.animname = "halon_guy";

	guys = [ self, bad_guy ];
	melee_node anim_reach_solo( self, "halon_melee_guy" );	
	self notify( "notify_baker_melee_position" );
	melee_node anim_single( guys, "halon_melee_guy" );
	bad_guy.allowdeath = true;	
	bad_guy kill();		

	//self.baseaccuracy = 1;
	self.ignoreall = true;
		
	// Baker heads into the room
	self enable_ai_color();
	issue_color_orders( "r71", "allies" );	
	self enable_cqbwalk();	
	
	// Set Baker's melee distance for halon room guys	
	self SetEngagementMaxDist( 128, 129 );	

	self waittill( "goal" );
	self.ignoreall = false;	

	wait 1;	

	self AllowedStances( "crouch" );	

	// Dialogue: Baker - "Stay low, they can't see us if we're ducking under the smoke." 
	level.baker dialogue_queue( "sky_bak_halon_staylow" );
	//thread add_dialogue_line( "Baker", "Stay low, they can't see us if we're ducking under the smoke.", "g" );

	// Show crouch hint (stay below smoke)
	display_hint_timeout( "hint_crouch_for_cover", 4 );

	// Wait for initial guys to be dead
	flag_wait( "flag_halon_floor1_enemies_dead" );

	issue_color_orders( "r72", "allies" );

	self.ignoreall = true;
	self.ignoreme = true;
	
	self waittill( "goal" );

	self set_fixednode_true();
	
	self.baseaccuracy = 10;
	self.ignoreme = false;	

	flag_wait( "flag_halon_main_encounter_start" );	

	// Dialogue: Baker - "We've gotta make it to that door."
	level.baker dialogue_queue( "sky_bak_halon_makeittodoor" );
	//thread add_dialogue_line( "Baker", "We've gotta make it to that door.", "g" );

	self.ignoreall = false;
	self.baseaccuracy = 1;

	wait 1;	

	issue_color_orders( "r73", "allies" );

	// Wait for floor enemies to be dead
	flag_wait( "flag_halon_floor2_enemies_dead" );	

	// Baker kills UAV (if alive)
	self baker_uav_kill();

	issue_color_orders( "r74", "allies" );

	self.ignoreall = true;

	self waittill( "goal" );	

	// Baker tells player to kill snipers
	if( !flag( "flag_halon_catwalk_enemies_dead" ))
	{
		// Dialogue - Baker: "Snipers near the exit.  Take them out."
		level.baker dialogue_queue( "sky_bak_halon_snipers" );
		self.ignoreall = false;
		//thread add_dialogue_line( "Baker", "Snipers near the exit.  Take them out.", "green" );
		self thread baker_kills_snipers();
	}

	flag_wait( "flag_halon_finished" );

	// Dialogue - Baker: "This way."
	level.baker dialogue_queue( "sky_bak_halon_thisway" );
	//thread add_dialogue_line( "Baker", "This way.", "g" );

	door = GetEnt( "brushmodel_halon_office_door", "targetname" ); //hinge brush model object for door.
	node_door = getent( "node_halon_office_door", "targetname" ); //called on script_origin node, grabs KVP, and assigns to variable.
	attachments = GetEntArray( door.target, "targetname" );  	
	
	Assert( IsDefined( door ));
	Assert( IsDefined( node_door ));	
	Assert( IsDefined( attachments ));

	for ( i = 0; i < attachments.size; i++ )
	{
		attachments[ i ] LinkTo( door );
	}
	
	node_door anim_reach_solo( self, "hunted_open_barndoor" ); //blends into first frame of open door anim based off cover right anim pose.  Also ends anim in cover right position.		
	door thread hunted_style_door_open(); //function to open door that is based off door open anim.  Not sure where this is defined.
	node_door anim_single_solo( self, "hunted_open_barndoor" ); //play anim to open door.
		 
	// Fix paths on other side of door and send baker into room
	door ConnectPaths();

	self enable_ai_color();
	issue_color_orders( "r76", "allies" );

	// Once baker gets to the office
	//trigger_wait_targetname( "trig_halon_office_door" );
	
	self.maxvisibledist = 8192;
	self.ignoreall = false;
	self AllowedStances( "crouch", "stand", "prone" );
	self disable_cqbwalk();	
									
	self waittill( "goal" );

	// Baker gets knocked by bullets again
	self enable_pain();

	radio_dialogue( "sky_teama_halon_problem" );
	//thread add_dialogue_line( "Team A", "Hold up Team B.  We've got a problem.", "r" );
	level.baker dialogue_queue( "sky_bak_halon_situation" );
	//thread add_dialogue_line( "Baker", "Roger Team A.  What is the situation?", "g" );
	radio_dialogue( "sky_teama_halon_gunship" );
	//thread add_dialogue_line( "Team A", "We are tracking heavy enemy air support close to your location.  Looks like a A2212 gunship.", "r" );
	level.baker dialogue_queue( "sky_bak_halon_bigdaddy" );
	//thread add_dialogue_line( "Baker", "So, they're sending in the big guns." , "g" );  
	//thread add_dialogue_line( "Baker", "Alright, we have no choice." , "g" );   
	//thread add_dialogue_line( "Baker", "Get in touch with SATCOM and request permission for Big Daddy, SH60151." , "g" );   
	//thread add_dialogue_line( "Baker", "Clearance code 5-Alpha-Charley-2-3-Bravo.  Over.", "g" );
	radio_dialogue( "sky_teama_halon_becareful" );
	//thread add_dialogue_line( "Team A", "Roger team B, we'll get back to you.  Be careful.  Team A out.", "r" );
	level.baker dialogue_queue( "sky_bak_halon_letsgo" );
	//thread add_dialogue_line( "Baker", "Alright, we can't stay here forever, hopefully we can sneak by undetected.  Spectre, let's go.", "g" );
	issue_color_orders( "r77", "allies" );

}

baker_kills_snipers()
{
	self.baseaccuracy = 1000;
	level.enemies[ "halon_catwalk1" ] = remove_dead_from_array( level.enemies[ "halon_catwalk1" ] ); 

	while( level.enemies[ "halon_catwalk1" ].size > 0 )
	{
		guy = random( level.enemies[ "halon_catwalk1" ] );
		self cqb_aim( guy );
		self shoot();
		guy kill();
		wait 2;
		level.enemies[ "halon_catwalk1" ] = remove_dead_from_array( level.enemies[ "halon_catwalk1" ] ); 
	}
	self.baseaccuracy = 1;
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************
											 
// Spawn enemies in halon room
halon_enemies()
{
	CreateThreatbiasGroup( "catwalk" );
	CreateThreatbiasGroup( "baker" );
	SetIgnoreMeGroup( "baker", "catwalk" );

	level.baker SetThreatBiasGroup( "baker" );
	
	trigger_wait_targetname( "trig_halon_button" );	

	floor1_spawners = GetEntArray( "halon_floor_1", "script_noteworthy" );
	floor2_spawners = GetEntArray( "halon_floor_2", "script_noteworthy" );
	floor3_spawners = GetEntArray( "halon_floor_3", "script_noteworthy" );
	office_spawners = GetEntArray( "halon_office", "script_noteworthy" );
	catwalk1_spawners = GetEntArray( "halon_catwalk_1", "script_noteworthy" );

	Assert( IsDefined( floor1_spawners ));
	Assert( IsDefined( floor2_spawners ));
	Assert( IsDefined( floor3_spawners ));
	Assert( IsDefined( office_spawners ));
	Assert( IsDefined( catwalk1_spawners ));

	array_thread( floor1_spawners, ::add_spawn_function, ::spawnfunc_halon_floor );
	array_thread( floor2_spawners, ::add_spawn_function, ::spawnfunc_halon_floor_2 );
	array_thread( floor3_spawners, ::add_spawn_function, ::spawnfunc_halon_floor );
	array_thread( office_spawners, ::add_spawn_function, ::spawnfunc_halon_floor );
	array_thread( catwalk1_spawners, ::add_spawn_function, ::spawnfunc_halon_catwalk );

	level.enemies[ "halon_floor1" ] = array_spawn( floor1_spawners ); 
	wait 0.05;
	level.enemies[ "halon_floor2" ] = array_spawn( floor2_spawners ); 	
	wait 0.05;
	floor3_guys = array_spawn( floor3_spawners );
	wait 0.05;
	level.enemies[ "halon_office" ] = array_spawn( office_spawners ); 
	wait 0.05;
	level.enemies[ "halon_catwalk1" ] = array_spawn( catwalk1_spawners ); 
	wait 0.05;		

	uav_spawner = GetEnt( "vehicle_uav_halon_patrol_1", "targetname" );
	Assert( IsDefined( uav_spawner ));

	level.enemies[ "halon_uav" ][ 0 ] = uav_spawner maps\_attack_heli::SAV_setup( "searching", "node_halon_uav_attack_1", "origin_uav_halon_search_1", 400, maps\_stealth_utility::miniuav_stealth_default );
	//level.enemies[ "halon_uav" ][ 0 ] = uav_spawner maps\_attack_heli::SAV_setup( "pathing", "node_halon_uav_attack_1" );
	PlayFXOnTag( level._effect[ "spotlight_dynamic" ], level.enemies[ "halon_uav" ][ 0 ], "tag_barrel" );

	// Add guys who stay behind cover to "floor2" group so one flag is set when everyone is dead
	foreach( guy in floor3_guys )
	{
		level.enemies[ "halon_floor2" ] = add_to_array( level.enemies[ "halon_floor2" ], guy ); 
	}

	// Wait until all dead, then set a flag
	thread halon_enemies_dead( level.enemies[ "halon_catwalk1" ], "flag_halon_catwalk_enemies_dead" );
	thread halon_enemies_dead( level.enemies[ "halon_floor1" ], "flag_halon_floor1_enemies_dead" );
	thread halon_enemies_dead( level.enemies[ "halon_floor2" ], "flag_halon_floor2_enemies_dead" );	 

	// Wait until the player is in position
	flag_wait( "flag_halon_main_encounter_start" );
	
	foreach( guy in level.enemies[ "halon_floor2" ] )
	{
		if( isalive( guy ))
		{
			guy set_fixednode_false();
		}
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

halon_enemies_dead( enemies, flag )
{
	while( enemies.size > 0 )
	{
		enemies = remove_dead_from_array( enemies ); 
		wait 0.05;
	}

	flag_set( flag );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

player_approach()
{	
	self endon( "death" );

	center = GetEnt( "vol_halon_center_room", "targetname" );
	Assert( IsDefined( center ));

	// Wait until the player is in position
	flag_wait( "flag_halon_main_encounter_start" );

	self set_fixednode_false();

	level.halon_charge = [];
	
	while( 1 )
	{
		level.halon_charge = remove_dead_from_array( level.halon_charge );

		if( level._player ButtonPressed( "BUTTON_RTRIG" ))
		{
			if( ( Distance( level._player.origin, self.origin ) < 256 ) && ( level.halon_charge.size < 2 ))
			{
				level.halon_charge = add_to_array( level.halon_charge, self );
				wait_random( 0, 1 );
				self set_fixednode_false();
				self.goalradius = 256;
				self SetGoalPos( level._player.origin );
				self.aggressivemode = true;
				self waittill( "goal" );
			}
			else
			{
	   			self SetGoalVolumeAuto( center );
			}			
		}
		else if( flag( "flag_halon_floor_enemies_rush" ))
		{
			wait_random( 0, 1 );
			self SetGoalPos( level._player.origin );
		}

		wait 0.05;
	}	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

// Spawnfunc for starting halon room guys (with lasers)
spawnfunc_halon_floor()
{	
	self.goalradius = 256;
	self enable_cqbwalk();
	self.grenadeammo = 0;
	self.a.disableLongDeath = true;
	self set_fixednode_true();
	self.countryId = "SP";
	self.npcID = 0;	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

// Spawnfunc for starting halon room guys (with lasers)
spawnfunc_halon_floor_2()
{	
	self.goalradius = 256;
	self enable_cqbwalk();
	self.grenadeammo = 0;
	self.a.disableLongDeath = true;
	self set_fixednode_true();
	self.countryId = "SP";
	self.npcID = 0;	

	self thread player_approach();
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

// Spawnfunc for starting halon room guys (with lasers)
spawnfunc_halon_catwalk()
{	
	self.goalradius = 256;
	self.ignoreme = true;
	self.a.disableLongDeath = true;
	 
	self enable_cqbwalk();	   
	
	self thread laser_scan();	
	self LaserForceOn();	

	self SetThreatbiasGroup( "catwalk" );
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

laser_scan()
{
	level endon( "notify_stop_halon" );
	self endon( "death" );
	
	// range of aim point
	aim_point_amt = 128;
	
	spot = spawn_tag_origin();

	while( 1 )
	{
		offset_x = RandomIntRange( (-1) * aim_point_amt, aim_point_amt );
		offset_y = RandomIntRange( (-1) * aim_point_amt, aim_point_amt );
		offset_z = RandomIntRange( (-1) * aim_point_amt, aim_point_amt );
		
		spot.origin = (level._player.origin[0] + offset_x, level._player.origin[1] + offset_y, level._player.origin[2] + offset_z);			

		self cqb_aim( spot );

 		time = RandomFloatRange( 2, 4 );
		self shoot();
		wait time;
	}	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

// Waits for trigger, then waits for player to press button to start halon
spawn_halon_gas()
{
	// Get buttons and door
	button = GetEnt( "brushmodel_halon_button", "targetname" );
	button_active = GetEnt( "brushmodel_halon_button_active", "targetname" );
	button_trigger = GetEnt( "trig_halon_button_use", "targetname" );
	door = GetEnt( "model_halon_door", "targetname" );
	player_blocker = GetEnt( "brush_halon_door", "targetname" );	

	Assert( IsDefined( button ));
	Assert( IsDefined( button_active ));
	Assert( IsDefined( button_trigger ));
	Assert( IsDefined( door ));
	Assert( IsDefined( player_blocker ));

	// Enable button objective
	//trigger_wait_targetname( "trig_halon_button" );
	level waittill( "notify_pull_halon" );

	button hide();
	button_active show();

	button_trigger sethintstring( &"NX_SKYSCRAPER_OBJ_HALON_BUTTON" );
	button_trigger waittill( "trigger" );
	button_trigger trigger_off();
	level._player playsound("scn_skyscraper_pull_halon");
	thread maps\_utility::set_ambient( "amb_skyscraper_robotics_int_mask" );
	flag_set( "flag_script_halon_gas_mask" );

	wait 5;

	// Send notify (to tell enemies and baker what to do)
	level notify( "notify_halon_on" );
		
	button show();
	button_active hide();

	// Start smoke
	smoke_emitters = GetEntArray( "halon_gas_emitter", "targetname" );	
	Assert( IsDefined( smoke_emitters ));

	SetSavedDVar ("r_fog_height_blend", 1);
	SetSavedDVar ("r_fog_height_start", 0);
	SetSavedDVar ("r_fog_height_end", 0);
	thread halon_gas_fog();	

	smoke_emitters thread start_smoke();

	level.baker notify( "notify_smoke_start" );	
	
	// Remove door
	door delete();
	player_blocker ConnectPaths();
	player_blocker delete();	
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

start_smoke()
{
	// Ambient gas.
	Exploder( "fx_halon_gas" );

	// Create jets.
	foreach( smoke_emitter in self )
	{
		smoke_emitter thread spawn_smoke_solo_watcher();	
		time = RandomFloatRange(0, 1);
		wait time;
	}
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

// Individual smoke fx loops
spawn_smoke_solo_watcher()												
{
	level endon( "notify_stop_halon" );
	//level endon( "notify_secure_objective_wave_2_complete" );

	self playsound("skyscraper_halon_jet");
	wait 0.856;
	PlayFx( level._effect[ "nx_halon_gas_jet" ], ( self.origin[ 0 ], self.origin[ 1 ], self.origin[ 2 ] + 256 ));
/*
	// Keep smoke active while wave_2 is active
	while( 1 )
	{		
		wait 1;
		PlayFx( level._effect[ "nx_halon_gas_cloud" ], ( self.origin[ 0 ], self.origin[ 1 ], self.origin[ 2 ] - 24 ));	

		if( level._player GetStance() == "stand" )
		{
			PlayFx( level._effect[ "nx_halon_gas_cloud_standing" ], ( self.origin[ 0 ], self.origin[ 1 ], self.origin[ 2 ] - 24 ));
		}
	}
*/
}

//*******************************************************************
// 																	*
//                                                                  *
//*******************************************************************

// Setup fog vision
halon_gas_fog()
{
	wait 2.0;

	for( i = 1; i <= 50; i++ )
	{
		setExpFog( 0, 200, 0.854902, 0.8470588, 0.8392157, 0.004*i, 0, 0, 0, 0.4980392, 0.4980392, 0.4980392, 0.4980392, 0.4980392, 0.4980392 );
		wait 0.1;
	}

	level waittill( "notify_stop_halon" );

	for( i = 50; i >= 0; i-- )
	{
		setExpFog( 0, 200, 0.854902, 0.8470588, 0.8392157, 0.01*i, 0, 0, 0, 0.4980392, 0.4980392, 0.4980392, 0.4980392, 0.4980392, 0.4980392 );
		wait 0.1;
	}

	fx_delete_createFXEnt_by_fxID( "nx_halon_gas_cloud_far", true );
}

// Create fog in front of player.
fx_player_fog()
{
	flag_wait( "flag_fx_halon" );
	level endon( "notify_stop_halon" );

	player = level._player;

	while( 1 )
	{
		len = Max( 36, Length( player GetVelocity() ) );

		if ( len < 50 )
			wait 0.15;
		else if ( len  < 100 )
			wait 0.1;
		else if ( len < 160 )
			wait 0.05;
		else
			wait 0.0333;

		offset = len * AnglesToForward( player GetPlayerViewAngles() );

		if( level._player GetStance() == "stand" )
			PlayFx( level._effect[ "nx_halon_gas_cloud_standing" ], ( player.origin[ 0 ] + offset[ 0 ], player.origin[ 1 ] + offset[ 1 ], player.origin[ 2 ] + 36 ));
		else
			PlayFx( level._effect[ "nx_halon_gas_cloud" ], ( player.origin[ 0 ] + offset[ 0 ], player.origin[ 1 ] + offset[ 1 ], player.origin[ 2 ] + 24 ));
	}
}
