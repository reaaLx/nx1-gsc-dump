//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  MISSION DESCRIPTION											**
//                                                                          **
//    Created: 7/15/2011 - Ken Moodie										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_utility_code;
#include maps\_nx_objective_util;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_nx_utility;
#include maps\nx_skyscraper_util;
#include common_scripts\_nx_fx;

//*******************************************************************
// WINDOW TO HANGAR                                                 *
//                                                                  *
//*******************************************************************

window_start()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_window" );
	thread maps\nx_skyscraper_fx::set_vision_and_fog("interior", 0); // set appropriate vision and fog
	maps\nx_skyscraper_util::player_weapon_init( false );

	thread maps\_utility::set_ambient( "amb_skyscraper_office_int" );

	maps\nx_skyscraper_util::spawn_baker();

	thread fx_explosive_circle_setup();

	// Show cloud ring.
	thread fx_show_cloud_ring();
}

window_sequence()
{
	baker_teleport = GetEnt ("baker_window_teleport", "targetname");
	level.baker ForceTeleport( baker_teleport.origin, baker_teleport.angles);
	
	level.baker enable_cqbwalk();

	issue_color_orders ("r20", "allies");

	// Take out enemies in room through wall
	hallway_encounter();

	thread window_dialog();

	// Baker opens door
	door = GetEnt( "model_window_room_door", "targetname" ); //hinge brush model object for door.
	node_door = getent( "node_window_room_door", "targetname" ); //called on script_origin node, grabs KVP, and assigns to variable.
	attachments = GetEntArray( door.target, "targetname" );  	
	
	Assert( IsDefined( door ));
	Assert( IsDefined( node_door ));	
	Assert( IsDefined( attachments ));

	for ( i = 0; i < attachments.size; i++ )
	{
		attachments[ i ] LinkTo( door );
	}
	
	node_door anim_reach_solo( level.baker, "hunted_open_barndoor" ); //blends into first frame of open door anim based off cover right anim pose.  Also ends anim in cover right position.		
	door thread hunted_style_door_open(); //function to open door that is based off door open anim.  Not sure where this is defined.
	maps\nx_skyscraper_anim::xray_kill_thru_door();
		 
	// Fix paths on other side of door and send baker into room
	door ConnectPaths();

	level.baker enable_ai_color();
	issue_color_orders ("r21", "allies");
	thread autosave_now();

	level waittill ("grid_displayed");
	thread window_cut();

	flag_wait ("landing_pad_window_open");

	thread landing_pad_kill();
	
	//thread maps\nx_skyscraper_fx::set_vision_and_fog("exterior_up_high", 2); // set appropriate vision and fog

	issue_color_orders ("r30", "allies");

	level waittill ("player_out_window");

	thread fx_delete_window_debris();
	thread hangar_fall_watcher();
	thread autosave_now();

	level.baker waittill ("goal");

	flag_wait ("flag_landing_pad_climbjump_ally");
	level waittill ("landing_pad_vignettes_done");
}

window_dialog()
{
	// add_dialogue_line( "Team A", "The office ahead should be just below the lab's landing pad.", "purple", 2 );

	radio_dialogue ("sky_teama_halltowindow_officebelow");
	// add_dialogue_line( "Team A", "Go through the window to access the landing pad's substructure.", "purple", 2 );
	radio_dialogue ("sky_teama_halltwowindow_thruwindow");
	// add_dialogue_line( "Baker", "Copy that. We're nearly there now.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_halltowindow_nearlythere" );
	// add_dialogue_line( "Team A", "I'm passing you the security frequency.", "purple", 2 );
	radio_dialogue ("sky_teama_halltowindow_securityfreq");
	// add_dialogue_line( "Team A", "The grid should be visible in your HUD.", "purple", 2 );
	radio_dialogue ("sky_teama_halltowindow_gridinhud");
	level notify ("grid_displayed");
	// add_dialogue_line( "Baker", "Roger, I see it. Making an exit now.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_halltowindow_makingexit" );
	flag_set ("flag_landing_pad_window");
	flag_wait ("landing_pad_window_open");
	// add_dialogue_line( "Baker", "And there we go.", "green", 2 );
	level.baker dialogue_queue( "sky_bak_halltowindow_therewego" );
	// flag_set ("flag_landing_pad_window_player");
}

hangar_fall_watcher()
{
	trigger = GetEnt ("trig_lab_to_vault_player_in_room", "targetname");
	trigger endon ("trigger");
	trigger = GetEnt ("hangar_fall", "targetname");
	trigger waittill ("trigger");
	SetSlowMotion( 1.0, 0.5, 0.25 );
	SetDvar( "ui_deadquote", &"NX_SKYSCRAPER_FAIL_FALL" );
	missionFailedWrapper();
}
//*******************************************************************
//                                                            		*
//                                                                  *
//*******************************************************************

window_cut()
{

/*
	// Make the cuts
	cut_origins = 
	[
		"origin_window_cut1",
		"origin_window_cut2",
		"origin_window_cut3",
		"origin_window_cut4"
	];					  

	cuts = [];
	for( i = 0; i < cut_origins.size; i++ )
	{
		cuts[ i ] = GetEnt( cut_origins[ i ], "targetname" );
		Assert( IsDefined( cuts[ i ] ));
	}
	cutter = spawn_tag_origin();
	cutter.origin = cuts[ 0 ].origin;
	cutter thread window_cut_fx();
	foreach( cut in cuts )
	{
		cutter MoveTo( cut.origin, 1 );
		wait 1;
	}
	cutter notify( "notify_stop_cut" );
	StopFXOnTag( GetFX( "spark_fountain" ), cutter, "tag_origin" );	

	wait 5;
*/

	// Explosive circle.
	fx_explosive_circle_animate();

	// Break the glass
	window = GetGlass ("hangar_access_window");
	if ( !IsGlassDestroyed ( window ))
	{
		DestroyGlass ( window ); 
	}

	// Play wind
	Exploder( "fx_window_wind" );
}

/*
window_cut_fx()
{
	self endon( "notify_stop_cut" );

	while( 1 )
	{
		PlayFXOnTag( GetFX( "spark_fountain" ), self, "tag_origin" );
		wait 0.5;
		
	}
}
*/

//*******************************************************************
//                                                            		*
//                                                                  *
//*******************************************************************

hallway_encounter()
{

	level.baker.goalradius = 8;

	thread hallway_encounter_enemies();
	level.baker thread baker_scan();

	//wait 3;
	// add_dialogue_line( "Baker", "Scan the walls and look for threats.", "green", 2 );
	level.baker dialogue_queue ("sky_bak_halltowindow_stayalert");

	level.baker waittill( "goal" );	

	trigger = GetEnt ("trigger_hallway_kill", "targetname");
	trigger waittill ("trigger");

	// Start scanning the room
	level.baker notify( "notify_room_scan" );

	flag_wait( "guys_in_room_dead" );							 
}

baker_scan()
{
	self endon( "notify_room_scan" );

	baker_look = spawn_tag_origin();

	wait 1;
	
	while( 1 )
	{
		baker_look.origin = self.origin + vector_multiply( AnglesToForward( self.angles ), 1024 ) + vector_multiply( AnglesToRight( self.angles ), 800 );
		self cqb_aim( baker_look );

		wait_random( 2, 3 );

		// Look left
		baker_look.origin = self.origin + vector_multiply( AnglesToForward( self.angles ), 1024 ) + vector_multiply( (-1) * AnglesToRight( self.angles ), 800 );
		self cqb_aim( baker_look );
  		
		wait_random( 2, 3 );
	}
}

hallway_encounter_enemies()
{
	sitter_spawners = GetEntArray( "actor_sitting", "script_noteworthy" );
	Assert( IsDefined( sitter_spawners ));	
	timeout = 0.05;

	level.enemies[ "sitters" ] = [];
	origins = [];

	sitter_anime = 
	[
		"civilian_sitting_talking_B_1",
		"civilian_sitting_talking_A_1",
		"civilian_sitting_talking_A_2"
	];

	sitter_origin = 
	[
		"origin_sitting_1",
		"origin_sitting_2",
		"origin_sitting_3"
	];

	for( i = 0; i < sitter_origin.size; i++ )
	{
		origins[ i ] = GetEnt( sitter_origin[ i ], "targetname" );
		sitter_spawners[ i ] add_spawn_function( ::spawnfunc_hallway_enemy, origins[ i ] );

		Assert( IsDefined( origins ));		
		level.enemies[ "sitters" ][ i ] = sitter_spawners[ i ] spawn_ai();
		level.enemies[ "sitters" ][ i ].animname = "sitter";
		origins[ i ] thread anim_loop_solo( level.enemies[ "sitters" ][ i ], sitter_anime[ i ] );		
		wait 0.05;
	}

	thread hallway_encounter_enemies_watcher( sitter_origin );

	level.baker waittill( "notify_room_scan" );

	thread maps\nx_skyscraper_anim::xray_kill_intro();

	// Player has killed none of the enemies yet
	if ( level.enemies[ "sitters" ].size == sitter_origin.size )
	{
		// thread add_dialogue_line( "Baker", "We've got 3 tangos in this room. Take 'em out.", "g" );
		level.baker dialogue_queue ("sky_bak_halltowindow_3tangos");
		timeout = 10;
	}
	// Player has killed some but not all enemies
	if ( level.enemies[ "sitters" ].size < sitter_origin.size && level.enemies[ "sitters" ].size >= 1 )
	{
		// thread add_dialogue_line( "Baker", "Good start. I'll take care of the leftovers.", "g" );
		level.baker dialogue_queue ("sky_bak_halltowindow_goodstart");
		timeout = 0.05;
	}

	// Player asked to kill enemies with X-Ray.  Baker will kill all if player takes too long.

	while( ( timeout > 0 ) )
	{
		// level.enemies[ "sitters" ] = remove_dead_from_array( level.enemies[ "sitters" ] );
		wait 0.05;
		timeout = timeout - 0.05;
	}	

	level.baker.ignoreall = false;
	level.baker.baseaccuracy = 1000;
	enemies_alerted = false;

	// Baker kills
	while( level.enemies[ "sitters" ].size > 0 )
	{
		
		level.enemies[ "sitters" ] = remove_dead_from_array( level.enemies[ "sitters" ] );
		
		if( level.enemies[ "sitters" ].size > 0 )
		{
			unlucky_guy = random( level.enemies[ "sitters" ] ); 
	
			if( isalive( unlucky_guy ))
			{
				level.baker cqb_aim( unlucky_guy );
				wait .2;
				level.baker shoot();
				unlucky_guy kill();
				wait .8;
			}
		}

		wait 0.05;
	}

	level.baker.ignoreall = true;
	level.baker.baseaccuracy = 1;

	flag_set ( "guys_in_room_dead" );
	level notify ("guys_in_room_dead");
}

hallway_encounter_enemies_watcher( sitter_origin )
{
	level endon ("guys_in_room_dead");
	while( level.enemies[ "sitters" ].size >= 1 )
	{
		level.enemies[ "sitters" ] = remove_dead_from_array( level.enemies[ "sitters" ] );
		wait 0.05;
	}
}

//*******************************************************************
//                                                            		*
//                                                                  *
//*******************************************************************

spawnfunc_hallway_enemy( origin )
{
	thread death_watch( origin );
	thread breakloop( origin );

}

death_watch( origin )
{
	self waittill( "damage" );
	origin notify( "stop_loop" );
	self StopAnimScripted(); 
	self kill();

	level notify( "notify_hallway_enemy_dead" );
}

breakloop( origin )
{
	self endon( "death" );

	level waittill( "notify_hallway_enemy_dead" );
	origin notify( "stop_loop" );
	self StopAnimScripted(); 
}

//*******************************************************************
// HANGAR                                                           *
//                                                                  *
//*******************************************************************

hangar_start()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_hangar" );
	thread maps\nx_skyscraper_fx::set_vision_and_fog("ext_up_high", 0); // set appropriate vision and fog
	maps\nx_skyscraper_util::player_weapon_init( false );

	thread hangar_fall_watcher();

	maps\nx_skyscraper_util::spawn_baker();

	level.baker enable_cqbwalk();
	thread landing_pad_kill();
	waittillframeend;
	level notify ("landing_pad_vignettes_done");
}

hangar_sequence()
{
	thread maps\_utility::set_ambient( "amb_skyscraper_windy_ext" );
	thread fx_show_cloud_ring();

	// Temp Baker traversal
	// baker_teleport = GetEnt ("baker_substructure_teleport", "targetname");
	// level.baker ForceTeleport( baker_teleport.origin, baker_teleport.angles);

	// trigger = GetEnt ("hangar_transition", "targetname");
	// trigger waittill ("trigger");
	baker_teleport = GetEnt ("baker_hangar_teleport", "targetname");
	level.baker ForceTeleport( baker_teleport.origin, baker_teleport.angles);
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_hangar" );
	thread autosave_now();
	issue_color_orders ("r33", "allies");
	//level.baker waittill ("goal");
	// maps\nx_skyscraper_lab_enter::sequence_lab_enter();
	//issue_color_orders ("r35", "allies");

}

landing_pad_kill()
{
	landing_pad_guard_1 = spawn_targetname ("landing_pad_enemy_spawner_1");
	landing_pad_guard_2 = spawn_targetname ("landing_pad_enemy_spawner_2");
	landing_pad_guard_1.animname = "target";
	landing_pad_guard_2.fixednode = true;
	landing_pad_guard_1.fixednode = true;
	landing_pad_guard_1.allow_death = true;
	level.baker.ignoreall = true;
	level waittill ("landing_pad_vignettes_done");
	landing_pad_guard_2 thread landing_pad_enemy_behavior_hack();
	landing_pad_guard_1 thread landing_pad_enemy_behavior_hack();
	landing_pad_guard_2 thread landing_pad_enemy_behavior_hack_part_2();
	landing_pad_guard_1 thread landing_pad_enemy_behavior_hack_part_2();

	guys = [];
	guys["ally_01"] = level.baker;
	guys["target"] = landing_pad_guard_1;

	node = GetNode ("landing_pad_kill_node", "targetname");
	
	node anim_reach_solo( level.baker, "landing_pad_melee_kill" );	
	
	if ( isAlive (landing_pad_guard_1))
	{
		node anim_single(guys, "landing_pad_melee_kill");
		landing_pad_guard_1 maps\_nx_vignette_util::vignette_actor_kill();
	}
	level.baker enable_ai_color();
	level.baker.ignoreall = false;

}

landing_pad_enemy_behavior_hack()
{
	self endon ("death");
	self waittill_any ("damage", "bulletwhizby", "enemy_visible");
	self.pacifist = false;
}


landing_pad_enemy_behavior_hack_part_2()
{
	self endon ("death");
	while ( isAlive (self))
	{
		if ( (level._player AttackButtonPressed() && level._player GetCurrentWeapon() != "lancer_silencer_xray") || level._player ButtonPressed( "BUTTON_LSTICK") || level._player ButtonPressed( "BUTTON_A" ))
		{
			self.pacifist = false;
			break;
		}
		wait .1;
	}
}


fx_explosive_circle_setup()
{
	circ01 = getEnt( "fx_explosive_circle", "script_noteworthy" );

	if ( isDefined( circ01 ) )
	{
		circ01 hide();
	}

	circ02 = getEnt( "fx_explosive_circle_2", "script_noteworthy" );

	if ( isDefined( circ02 ) )
	{
		circ02 hide();
	}
}

fx_explosive_circle_animate()
{
	circ01 = getEnt( "fx_explosive_circle", "script_noteworthy" );

	if ( !isDefined( circ01 ) )
	{
		return;
	}

	circ01 show();
	circ01 setAnimParamValue( 0, 999 );
	circ01 setAnimParamValue( 1, -0.2 );
	wait 2.65;
	wait 1.8;
	circ01 hide();
}

fx_delete_window_debris()
{
	// Delete lingering fx from window breach sequence.
	fx_delete_createFXEnt_by_fxID( "nx_ss_window_debris", true);
	fx_delete_createFXEnt_by_fxID( "nx_ss_window_debris_swirl", true);
}
