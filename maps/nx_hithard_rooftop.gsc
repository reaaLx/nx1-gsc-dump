//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  nx_hithard_rooftop.gsc					   					**
//				NOTE: called from nx_hithard.gsc							**
//                                                                          **
//    Created: 1/13/2011 - Brian Marvin										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_nx_objective_util;
#include maps\_hud_util;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Objective-specific PreCache calls
// NOTE: for any assets other than strings that require precaching, please place them in "nx_hithard::mission_precache()"
precache_strings()
{

}

// Objective specific flag_init() calls
flag_inits()
{
	// Rooftop encounter is defeated
	flag_init( "flag_rooftop_guys_cleared" );

	// Perch guys defeated
	flag_init( "flag_rooftop_perch_guys_cleared" );
}

// Objective specific add_hint_string() calls
hint_string_inits()
{	
	
}

//*******************************************************************
//                                                                  *
// 	HINT FUNCTIONS			                                    	*
//                                                                  *
//*******************************************************************
 

//***************************************************************************************************************************************************************
//                                                                  																							*
// 	MAINS				                                               																							*
//                                                                  																							*
//***************************************************************************************************************************************************************

main_rooftop()
{
	// Kill off all ai spawners from parachute section
	maps\_spawner::kill_spawnerNum( 1 );

	// Autosave
	thread autosave_now();

	// Baker contacts patriot
	thread dialog_baker_patriot();

	thread audio_nodes_rooftop();
	
	// Set new vision and fog for walking about the level vs parachuting
	thread maps\nx_hithard_fx::sequence_vision_and_fog_parachute_land();

	// Set ambient sounds
	thread maps\_utility::set_ambient( "nx_hithard_ext" );

	// Prepare the main intersection
	thread maps\nx_hithard_secure::prep_secure_intersection( true );

	// Handle rooftop civilians
	//thread rooftop_civilians();

	// Turn off ally hop up trigger
	thread maps\nx_hithard_util::all_triggers_off( "rooftop_hop_up_trigger" );

	// start the vfx sequencing
	thread maps\nx_hithard_fx::fx_rooftop_init();

	// Wave logic
	// JR 5/4/11 - The first 3 guys were removed
	//thread rooftop_wave_1_logic();
	thread rooftop_wave_2_logic();
	thread rooftop_snipers_watcher();

	thread ally_mover();
	thread climb_up_logic();
	thread objective_logic();


	// COMBAT HAPPENS HERE

	// Wait for enemy kill group then move up allies
	flag_wait( "flag_rooftop_guys_cleared" );

	// Kill all rooftop encounter triggers since the encounter is over
	thread maps\nx_hithard_util::all_triggers_off( "rooftop_trigger" );

	// Random delay to feel a little more natural
	wait( RandomFloatRange( 0.5, 1.75 ));

	// Captain Baker: "Get to the roof!"
	level.squad[0] thread radio_dialogue( "hithard_bak_para_23" );

	wait( 0.5 );

	// Move up
	//issue_color_orders( "b130", "allies" );
	// Added waits to make sure the color system is nice and happy before moving on
	//wait( 0.5 );

	rooftop_climbup_node_left = getnode( "rooftop_climbup_node_left", "script_noteworthy" );
	rooftop_climbup_node_right = getnode( "rooftop_climbup_node_right", "script_noteworthy" );

	// Make them go to the nodes
	level.squad[1].script_forcegoal = 1;
	level.squad[1] PushPlayer( true );
	level.squad[1] SetGoalNode( rooftop_climbup_node_left );

	level.squad[0].script_forcegoal = 1;
	level.squad[0] PushPlayer( true );
	level.squad[0] SetGoalNode( rooftop_climbup_node_right );

	flag_wait( "flag_rooftop_perch_guys_cleared" );

	// Turn on rooftop hop up trigger
	// This causes the allies to hop up to the sniper perch
	thread maps\nx_hithard_util::all_triggers_on( "rooftop_hop_up_trigger" );

	wait( 0.5 );

	// Objective Complete
	maps\nx_hithard_util::objective_end( "obj_secure_roof" );

	wait( 0.25 );

	// Trigger climb up anim
	level.squad[1] maps\nx_hithard_anim::nx_tp_hithard_sniper_climbing_a();
	level.squad[0] maps\nx_hithard_anim::nx_tp_hithard_sniper_climbing_b();	

	// Get ally nodes for the sniper section
	sniper_section_node_01 = getnode( "node_secure_ally_02_cover", "script_noteworthy" );
	sniper_section_node_02 = getnode( "node_secure_ally_01_cover", "script_noteworthy" );

	// Make them go to the nodes
	level.squad[0].script_forcegoal = 1;
	level.squad[1].script_forcegoal = 1;

	level.squad[0] SetGoalNode( sniper_section_node_01 );
	level.squad[1] SetGoalNode( sniper_section_node_02 );

	level.squad[0] waittill( "goal" );
	level.squad[1] waittill( "goal" );
}

audio_nodes_rooftop()
{

	nodefight = spawn( "sound_emitter", ( 8096, -2691, 47 ) );
	nodefight PlayloopSound( "emt_hh_gun_fight" );
	flag_wait( "flag_vtol_flyover" );
	wait 0.5;
	nodefight stopsounds();
	wait 0.1;
	nodefight delete();

}

// Spawns 2 enemies on the sniper perch
rooftop_snipers_watcher()
{
	flag_wait( "rooftop_main_staircase" );

	flag_set( "music_rooftop_battle_starts");

	// If the player took the flanking path, dont spawn the guys yet
	//if( flag( "rooftop_player_flanking" ))
	//{
	//	//IPrintLnBold( "debug: waiting for flank to finish" );
	//	flag_wait( "flag_rooftop_guys_cleared" );
	//}

	wait( 6.0 );
	level.rooftop_enemies["hopdown_guys"] = rooftop_spawn_enemy_wave( "rooftop_hopdown_enemies", undefined, true );
	//level.rooftop_enemies["hopdown_guys"] maps\nx_hithard_util::SetThreatBiasGroup_array( "hopdown_guys" );
	//SetThreatBias( "hopdown_guys", "allies", 500 );

	// Captain Baker: "Tangos up high!"
	level.squad[0] thread radio_dialogue( "hithard_bak_plaza_11" );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Spawns enemies on library rooftops
prep_parachute_library_rooftop()
{		
	level endon( "notify_motorcade_objective_complete" );

	// JR 5/4/11 - The first 3 guys were removed 

	// These guys do nothing special atm
	//rooftop_enemies_01 = GetEntArray( "library_enemies_01", "script_noteworthy" );
	//array_spawn_function( rooftop_enemies_01, ::rooftop_enemies_logic );

	// Spawn 2 guys already on the roof
	//level.rooftop_enemies["library"] = rooftop_spawn_enemy_wave( "library_enemies_01", undefined, true );			
	//level.rooftop_enemies["library"] maps\nx_hithard_util::SetThreatBiasGroup_array( "rooftop_guards" );
	//level.rooftop_enemies["library"] maps\nx_hithard_util::set_threat_detect_off();	
	//level.rooftop_enemies["library"] maps\nx_hithard_util::ignore_all_off();

	// Guards more likely to attack player,
	//SetThreatBias( "rooftop_guards", "player", 200 );
	//SetThreatBias( "rooftop_fastropers", "player", 150 );

	// Prep done
	level notify( "notify_prep_parachute_library_rooftop_complete" );

	// Wait for landing
	level waittill( "notify_parachute_objective_complete" );
	//rooftop_enemies_01 maps\nx_hithard_util::ignore_all_off();
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Spawn a wave of enemies
rooftop_spawn_enemy_wave( enemy_noteworthy_name, goal_radius, bForceSpawn )
{
	// Spawn enemies with script_noteworthy of "enemy_noteworthy_name"
	rooftop_enemies_spawner = GetEntArray( enemy_noteworthy_name, "script_noteworthy" );
	rooftop_enemies = array_spawn( rooftop_enemies_spawner, bForceSpawn );

	// Check spawns against spawners
	if ( IsDefined( rooftop_enemies ))
	{
		if ( rooftop_enemies.size < rooftop_enemies_spawner.size )
		{
			AssertMsg( rooftop_enemies_spawner.script_noteworthy + ": Could not spawn ALL enemies: " + rooftop_enemies.size + "/" + rooftop_enemies_spawner.size );
		}
	}
  	else
	{
		AssertMsg( "Could not spawn enemies..." );
	}
	
	// Set enemy's goalradius (if exists)
	if( IsDefined( goal_radius ))
	{
		self.goalradius = goal_radius;	
	}
	return rooftop_enemies;
}


// Spawns the first wave of enemies
rooftop_wave_1_logic()
{
	level endon( "rooftop_main_staircase" );

	// These guys do nothing special atm
	rooftop_enemies_01 = GetEntArray( "library_enemies_01", "script_noteworthy" );
	array_spawn_function( rooftop_enemies_01, ::rooftop_enemies_logic );

	// Setup corner guy
	corner_guy = GetEnt( "rooftop_stairs_corner_guy", "targetname" ); 
	corner_guy add_spawn_function( ::rooftop_corner_guy_logic );

	// Setup balcony guy
	balcony_guy = GetEnt( "rooftop_wave_1_balcony_guy", "targetname" );
	balcony_guy add_spawn_function( ::rooftop_balcony_guy_logic );

	flag_wait( "flag_rooftop_spawn_wave_1" );

	// Spawn 2 guys already on the roof
	level.rooftop_enemies["library"] = rooftop_spawn_enemy_wave( "library_enemies_01", undefined, true );
	level.rooftop_enemies["library"] maps\nx_hithard_util::SetThreatBiasGroup_array( "rooftop_guards" );
	level.rooftop_enemies["library"] maps\nx_hithard_util::set_threat_detect_off();	
	level.rooftop_enemies["library"] maps\nx_hithard_util::ignore_all_off();

	// Guards more likely to attack player,
	SetThreatBias( "rooftop_guards", "player", 200 );
	SetThreatBias( "rooftop_fastropers", "player", 150 );
}

// This guy is supposed to go to a specific spot
// This would normally be done by targeting the node in radiant,
// but the guy uses a goal volume, and you cant set spawn targets
// while using goal volumes
rooftop_corner_guy_logic()
{
	corner_node = getnode( "rooftop_corner_node", "script_noteworthy" );
	self.script_forcegoal = 1;
	self SetGoalNode( corner_node );
}


// Handles wave 2 - The VTOL guys
rooftop_wave_2_logic()
{
	// Setup perch guys
	perch_guys = GetEntArray( "rooftop_hopdown_enemies", "script_noteworthy" );
	array_thread( perch_guys, ::add_spawn_function, ::rooftop_perch_guys_logic );

	// This will check num enemies alive
	// Last 2 guys will go berserk rather than hide in a corner
	while( !flag( "flag_rooftop_guys_cleared" ))
	{
		num_alive = get_ai_group_sentient_count( "rooftop_vtol_guys" );
		if( num_alive < 4 )
		{
			//alive_guys = get_ai_group_ai( "rooftop_vtol_guys" );
			//foreach( guy in alive_guys )
			//{
			//	guy thread ai_playerseek();
			//	guy.aggressivemode = true;
			//}

			// Move duke up a little
			flag_wait( "rooftop_at_main_staircase" );
			node = getnode( "rooftop_middle_planter_node", "script_noteworthy" );
			level.squad[1] SetGoalNode( node );

			break;
		}
		wait( 0.25 );
	}
}


// Moves the allies through this section
ally_mover()
{
	// Set ally colors
	level.squad[0] set_force_color( "b" ); // Actor is now blue
	level.squad[1] set_force_color( "c" ); // Actor is now cyan

	// Give initial color orders
	issue_color_orders( "b100 c100", "allies" );

	flag_wait( "flag_rooftop_spawn_wave_1" );

	// Wait for them to spawn
	waittillframeend;	

	issue_color_orders( "b110 c110", "allies" );

	num_alive = get_ai_group_sentient_count( "wave_1_guys" );
	while( num_alive > 2 )
	{
		num_alive = get_ai_group_sentient_count( "wave_1_guys" );
		wait( 0.25 );
	}

	issue_color_orders( "c115", "allies" );
	wait( 2.0 );
	issue_color_orders( "b115", "allies" );

	// When the 2 stairs guys die, advance allies
	flag_wait_any( "stair_runners_cleared", "rooftop_at_main_staircase" );

	// Kill any landing zone triggers
	thread maps\nx_hithard_util::all_triggers_off( "landing_zone_trigger" );

	// If the player has not reached the staircase,
	// Have allies run to it
	if( !flag( "rooftop_at_main_staircase" ))
	{
		issue_color_orders( "b115 c115", "allies" );
	}
	// If player has reached the staircase,
	// Have allies run up it
	else if( flag( "rooftop_at_main_staircase" ))
	{
		issue_color_orders( "b120 c120", "allies" );
	}
	
	// If "rooftop_at_main_staircase" was hit above,
	// theyll still need to move to 120 when the mobs are dead
	// JR - There has to be a better way to do this
	flag_wait( "stair_runners_cleared" );
	issue_color_orders( "b120 c120", "allies" );
}


// Adds an extra mantle tooltip in the area,
// and tries to force mant
climb_up_logic()
{
	flag_wait( "rooftop_main_staircase" );

	while( !flag( "at_sniper_perch" ))
	{
		if( flag( "rooftop_force_mantle_hint" ))
		{
			SetSavedDvar( "hud_forceMantleHint", 1 );
			level._player forceMantle();
		}
		else
		{
			SetSavedDvar( "hud_forceMantleHint", 0 );
		}

		wait( 0.1 );
	}
	SetSavedDvar( "hud_forceMantleHint", 0 );
}


// Handles the objective markers for this section
objective_logic()
{
	// Add objectives
	//goal = getent( "playerstart_secure", "targetname" );
	goal = getent( "rooftop_objective_stairs", "targetname" );
	maps\nx_hithard_util::objective_start( "obj_secure_roof", &"NX_HITHARD_SECURE_OBJ_ROOF", goal );

	flag_wait( "rooftop_at_main_staircase" );

	obj_num = level.objective["obj_secure_roof"];
	objective_position( obj_num, getEnt( "rooftop_objective_perch", "targetname" ).origin );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************
// VTOL flys in and drops off guys
vtol_flyin_logic( from_playerstart )
{
	// Prepare spawnfunc before the vehicle ( and riders ) are spawned
	fastrope_enemies = GetEntArray( "library_fastrope_enemies", "script_noteworthy" );
	array_spawn_function( fastrope_enemies, ::fastrope_enemies_logic );

	if( !isDefined( from_playerstart ))
	{
		flag_wait( "flag_parachute_section_04" ); // flag_vtol_flyin_go
		// Spawn the vehicle and go.
		vtol = spawn_vehicle_from_targetname_and_drive ( "para_vtol" );
		vtol2 = spawn_vehicle_from_targetname_and_drive( "para_vtol_2" );
		vtol_sfx = Get_Vehicle( "para_vtol", "targetname" );
		vtol_sfx playsound( "scn_hhh_vtol_flyin01" );

		// Wait for end of path
		vtol waittill( "reached_dynamic_path_end" );
	}
	// Start closer to dropoff point if using debug starts
	else
	{
		vtol = spawn_vehicle_from_targetname( "para_vtol" );
		vtol2 = spawn_vehicle_from_targetname_and_drive( "para_vtol_2" );
		vtol_sfx = Get_Vehicle( "para_vtol", "targetname" );
		vtol_sfx playsound( "scn_hhh_vtol_flyin01" );

		// Stop the vehicle!
		vtol vehicle_stoppath();
		//vtol vehicle_setspeed( 1, 1 );
		vtol.currentnode = GetEnt( "rooftop_vtolstart", "script_noteworthy" );
		vtol vehicle_teleport( vtol.currentnode.origin, vtol.currentnode.angles );
		waittillframeend;
	}

	// No threat detection yet
	//vtol SetThreatIDOverlay( "off" );

	// Drop off troops
	rooftop_guys = vtol vehicle_unload();
	level.rooftop_guys = rooftop_guys;
        vtol playsound("nx_npc_fastrope");

	wait( 16.0 );
	level notify ( "rooftop_fastrope_done" );

	// Troops go to their nodes
	//issue_color_orders( "r100", "axis" );

	// Time to leave
	vtol thread vehicle_detachfrompath();
	vtol.currentnode = GetEnt( "para_vtol_path_exit", "script_noteworthy" );
	//vtol attachPath( vtol_start );
	vtol thread vehicle_resumepath();
	vtol vehicle_setspeed( 40, 10 );
	vtol GoPath();
	vtol waittill( "reached_dynamic_path_end" );
	vtol Delete();
}


//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************
// AI behavior for the enemies who fast rope in
fastrope_enemies_logic()
{
	self endon( "death" );
	if ( !isalive( self ) )
		return;

	// Give them a threat bias
	self SetThreatBiasGroup( "rooftop_fastropers" );

	// No overlay in the mission yet
	//self SetThreatIDOverlay( "off" );

	// Allies shouldnt shoot them while fast roping
	self set_ignoreme( true );
	self waittill( "jumpedout" );
	self set_ignoreme( false );

	wait( 2.0 );

	node_index = self.script_index;
	target_nodes = GetNodeArray( "rooftop_enemy_position_node", "script_noteworthy" );
	self SetGoalNode( target_nodes[ node_index ]);
	self.radius = 32;

}


//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************
// AI behavior for the enemies who dont fast rope in
rooftop_enemies_logic()
{
	self endon( "death" );

	if ( !isalive( self ) )
		return;

	// Turn on player seek
	//self thread ai_playerseek();
}

// When the stair runners die, balcony guy retreats and dies
rooftop_balcony_guy_logic()
{
	self endon( "death" );
	flag_wait_any( "stair_runners_cleared", "rooftop_at_main_staircase" );	

	retreat_vol = GetEnt( "rooftop_wave_2_guys_volume", "targetname" );
	if( isDefined( retreat_vol ))
	{
		self SetGoalVolumeAuto( retreat_vol );
		self waittill( "goal" );
		wait( RandomFloatRange( 1.5, 2.5 ));
		self kill();
	}
	else
	{
		AssertMsg( "Script rooftop_balcony_guy_logic couldn't find rooftop_wave_2_guys_volume" );
	}
}


// Perch guys need a physics jolt when they die
#using_animtree( "generic_human" );
rooftop_perch_guys_logic()
{
	
	// JR - These death anims are supposed to make the fall guy
	// fall off a ledge
	death_anims = [	%death_rooftop_B, %death_rooftop_C, %death_rooftop_D ];
	self.deathanim = random( death_anims );

    //org = self.origin;
    //vector = ( 0, 0, 1000 );
    //self waittill( "death" );
    //PhysicsJolt( org, 100, 100, vector );
	//PhysicsExplosionSphere( org, 100, 80, 1 );
}


//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************
rooftop_encounter_dialogue()
{
	level endon( "flag_secure_rooftop_aware" );

	//=================================================================
	// Rooftop cleared and climb up to next section
	//=================================================================
	level waittill( "notify_cleared_rooftop" );

	wait( RandomFloatRange( 0.5, 1.2 ));

	// Captain Baker: "Keep moving. Let's get to high ground."
	maps\nx_hithard_parachute::wait_play_dialogue_wait( 0.0, "hithard_bak_para_23" );

	warner_array = [ "hithard_bak_para_22", "hithard_bak_para_26", "hithard_bak_para_27", "hithard_bak_para_28" ];

	wait( 15.0 );

	// Start rooftop warner
	while( !flag( "flag_secure_rooftop_aware" ))
	{
		random_warner = Random( warner_array );	
		maps\nx_hithard_parachute::wait_play_dialogue_wait( 0.0, random_warner );

		wait( RandomFloatRange( 12.0, 18.0 ));
	}
}


// AI behavior for more deadly enemies
ai_playerseek()
{
	self endon( "death" );

	if ( isdefined( self.target ) )
		self waittill( "goal" );

	self setgoalentity( level._player );
	self.goalradius = 2000;
}



// Spawns and controls the civilians on the rooftop
rooftop_civilians()
{
	array_thread( GetEntArray( "gate_sliders", "script_noteworthy" ), ::add_spawn_function, ::gate_sliders );
	array_spawn_targetname( "gate_runners1" );
}


// From airport
gate_runners_setup()
{
	wait .05;

	self.allowdeath = 1;
	self thread anim_generic_loop( self, self.animation );

	self.useChokePoints 	= false;
	self.ignoreme 			= true;
	self.ignoreall 			= true;

	self.IgnoreRandomBulletDamage		= true;
	self.ignoreExplosionEvents 			= true;
	self.grenadeawareness 			 	= 0;
	self.ignoreSuppression 			 	= 1;
	self.disableBulletWhizbyReaction 	= true;
	self disable_surprise();
}

gate_sliders()
{
	self endon( "death" );

	gate_runners_setup();
	node = getstruct( self.target, "targetname" );

	anime = undefined;
	runanim = undefined;
	switch( node.targetname )
	{
		case "gate_civ_slide":
			self.moveplaybackrate = 1.0;
			anime = "civilian_run_hunched_turnR90_slide";							 
			runanim = "civilian_run_hunched_A";
			wait .25;
			break;
		case "gate_civ_slide2":
			anime = "airport_civilian_run_turnR_90";
			runanim = "civilian_run_hunched_C";
			self.moveplaybackrate = 1.15;
			break;
	}

	flag_wait( "flag_parasecure_parachute_landed_player" );
	wait 3.5;

	self notify( "stop_loop" );
	self StopAnimScripted();
	self.interval = 50;
	self.IgnoreRandomBulletDamage 	 = false;

	self set_generic_run_anim( runanim, true );
	node anim_generic_reach( self, anime );
	node anim_generic_run( self, anime );

	//self follow_path( GetNode( "gate_civ_node", "targetname" ) );
	wait .25;
	self Delete();
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Baker speaks with patriot after landing
dialog_baker_patriot()
{
	// Captain Baker: "Patriot, this is Convoy 2.  What is your status?"
	level.squad[0] radio_dialogue_queue( "hithard_bak_roof_whatstatus" );

	wait( 0.1 );

	// Secret Service: "Convoy 2, this is Patriot.  We've been ambushed and need backup."
	thread radio_dialogue( "hithard_sslead_roof_ambushed" );

	wait( 0.95 );

	// Captain Baker: "Roger that.  We'll head your way. Engaging from the southwest roof."
	level.squad[0] radio_dialogue_queue( "hithard_bak_roof_rogerthat" );
}

// Play the picture in picture secret service bink
rooftop_landing_bink( from_playerstart )
{
	if( isDefined( from_playerstart ))
	{
		// If using debug starts, just load it
		load_cinematic( "hhh_pip" );
		
		// Wait for Baker's first line
		wait( 1.25 );
	}
	// If playing naturally, preload bink during chute ride
	else
	{
		// Preload the bink a little early
		flag_wait( "flag_prepare_for_landing" );
		load_cinematic( "hhh_pip" );

		// Landed, play it
		flag_wait( "flag_parasecure_parachute_landed_player" );

		// Very short delay to allow for landing anim, pulling weapon up,
		// and Baker's first line
		wait( 3.75 );
	}

	cinema_overlay = create_cinematic_hud_overlay( 0, 0, 293, 192, true );

	//cinema_overlay.layer = "visor"; // JR - Disabled. Causes extra curvature
	cinema_overlay.horzAlign = "right_adjustable";
	cinema_overlay.alignX = "right";
	cinema_overlay.vertAlign = "top_adjustable";
	cinema_overlay.alignY = "top";

	level._player playsound ( "scn_hithard_vp_pip" );
	play_cinematic();
	while( IsCinematicPlaying())
	{
		wait 0.05;
	}
	destroy_cinematic_hud_overlay( cinema_overlay );
}
