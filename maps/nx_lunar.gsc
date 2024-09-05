//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_LUNAR Base Mission Script									**
//                                                                          **
//    Created: 10/14/2010 - Travis Chen										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_utility_code;
#include maps\_nx_objective_util;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main()
{
	// Add starts
	default_start( ::intro_start );	
	set_default_start( "get_to_the_armory" );

	add_start( "intro", ::intro_start, "Intro", ::intro );
	add_start( "rover_chase", ::rover_chase_start, "Rover Chase", ::rover_chase );
	add_start( "get_to_the_armory", ::get_to_the_armory_start, "Get to the Armory", ::get_to_the_armory );
	add_start( "armory_module", ::armory_module_start, "Armory Module", ::armory_module );
	add_start( "life_support_module", ::life_support_module_start, "Life Support Module", ::life_support_module );
	add_start( "living_module", ::living_module_start, "Living Module", ::living_module );

	// tagTC<note> - vista to exterior
	add_start( "exterior_vista", ::exterior_vista_start, "Exterior Vista", ::exterior_vista );

	// tagTC<note> - crew hub removed for the greenlight :(
	// add_start( "crew_module", ::crew_module_start, "Crew Module", ::crew_module );

	add_start( "airlock_exterior", ::airlock_exterior_start, "Airlock To Exterior", ::airlock_exterior );
	add_start( "mining_valley", ::mining_valley_start, "Mining Valley", ::mining_valley );
	add_start( "rough_terrain", ::rough_terrain_start, "Undiscovered Country", ::rough_terrain );
	add_start( "rover_battle", ::rover_battle_start, "Rover Battle", ::rover_battle );
	add_start( "into_shadows", ::into_shadows_start, "Into the Shadows", ::into_shadows );
	add_start( "vehicle_bay_return", ::vehicle_bay_return_start, "Return to the Vehicle Bay", ::vehicle_bay_return );
	add_start( "take_back_control", ::take_back_control_start, "Take Back Control", ::take_back_control );
	add_start( "take_back_control_ending", ::take_back_control_ending_start, "Take Back Control Ending", ::take_back_control_ending );
	
	add_start( "no_game_moon", ::intro_start, "no_game: moon physics", ::no_game_moon );

	maps\nx_lunar_precache::main();
	maps\nx_lunar_fx::main(); 
	maps\_moon_actor::main();
	// tagDK<note> - removing for milestone, not enough time
//  maps\_stealth::main();
	huds = [];
	huds[huds.size] = "hud_lunar";
	maps\_load::main( huds );
	maps\_moon::main();
	maps\nx_lunar_escape_exterior::main();
	maps\_drone_civilian_lunar::init();
	
	// tagTC<note> - Don't call breach if breach triggers don't exist
	// This is to account for compiling out the breach for quick compiles
	breach_lookat_triggers = GetEntArray( "trigger_multiple_breachIcon", "classname" );
	if( breach_lookat_triggers.size > 0 )
	{
		maps\nx_lunar_control_room_breach::main();
	}
	maps\nx_lunar_escape_interior::main();

	// Internal Initialization
	mission_flag_inits();
	mission_precache();	
	maps\nx_lunar_anim::main();

	// Mission objectives
	level thread mission_objective_logic();

	// Init doorway status lighting
	level thread nx_lunar_door_status_init();

	// Mission threads
	level thread maps\nx_lunar_audio::mission_music();	
	//set the music flags for whichever part of the mission we're debugging to
	level thread mission_music_debug_to_checkpoint_set_flags();
	//call the script to handle sfx helmet and sound states
	level thread mission_sfx_helmet_states();

	// Turn off specified triggers
	maps\nx_lunar_util::all_triggers_off( "armory_triggers" );
	maps\nx_lunar_util::all_triggers_off( "life_support_triggers" );
	maps\nx_lunar_util::all_triggers_off( "medical_triggers" );
	maps\nx_lunar_util::all_triggers_off( "medical_to_living_triggers" );
	maps\nx_lunar_util::all_triggers_off( "living_triggers" );
	maps\nx_lunar_util::all_triggers_off( "exterior_vista_triggers" );
	maps\nx_lunar_util::all_triggers_off( "crew_triggers" );
	maps\nx_lunar_util::all_triggers_off( "crew_airlock_triggers" );
	maps\nx_lunar_util::all_triggers_off( "exterior_airlock_triggers" );
	maps\nx_lunar_util::all_triggers_off( "into_shadows_triggers" );
	maps\nx_lunar_util::all_triggers_off( "vehicle_bay_return_left_route" );
	maps\nx_lunar_util::all_triggers_off( "vehicle_bay_return_right_route" );

	// Turn off specified mantles
	maps\nx_lunar_util::all_mantles_off( "into_shadows_mantles" );

	// Hide Dynamic Geo
	maps\nx_lunar_util::hide_scriptmodels_by_targetname( "into_shadows_supplies" );
	maps\nx_lunar_util::hide_scriptmodels_by_targetname( "valley_traversal_blocker" );
	maps\nx_lunar_util::hide_scriptmodels_by_targetname( "valley_traversal_blocker_ally" );

	// Compass
	maps\_compass::setupMiniMap( "compass_map_nx_lunar" );

	// Life pass
	level thread maps\nx_lunar_util::flickering_lights();

	// Hints
	level._player thread maps\nx_lunar_util::suit_patch_hint();

	// Lunar taser main
	maps\nx_taser::main();

	level thread maps\_suitshield::init_suit_shield();

	// NX_LUNAR Vision set
	VisionSetNaked( "nx_lunar" );

	// Lunar helmet
	//lunar_player_helmet();
	
	// Viewmodel
	level._player setViewmodel( "viewhands_us_lunar" );

	// Dead crew member logic
	thread maps\nx_lunar_anim::dead_crew();

	// Damage that spraying pipes deal
	level._pipesDamage = 10;

	// Start the ambience track
	thread maps\nx_lunar_amb::main();

	// Setup mission threats
	level thread mission_threat_setup();

	//turn off battlechatter
	battlechatter_off( "axis" );
	battlechatter_off( "allies" );

	//dont want all sounds affected by timescale
	SoundSetTimeScaleFactor( "Music", 0 );
	SoundSetTimeScaleFactor( "Menu", 0 );
	SoundSetTimeScaleFactor( "Voice", 0 );
	SoundSetTimeScaleFactor( "Announcer", 0 );
	SoundSetTimeScaleFactor( "effects1", 0 );
	SoundSetTimeScaleFactor( "Vignette3d", 0 );
	SoundSetTimeScaleFactor( "Vignette2d", 0 );
	SoundSetTimeScaleFactor( "nx_localverb", 0 );
	SoundSetTimeScaleFactor( "ambient", 0 );
	SoundSetTimeScaleFactor( "local", 0 );
	SoundSetTimeScaleFactor( "auto2d", 0 );

	thread playnodesound1();
    
}

playnodesound1()
{
            //mynodeEntity = getent( "lunarchaos1", "targetname" );
			mynodeEntity6 = spawn("sound_emitter", (6656, 432, -1744));
            mynodeEntity6 PlayLoopSound( "emt_lunar_computer_room" );
			flag_wait( "life_support_door_open" );
			mynodeEntity6 delete();

}

// All mission specific PreCache calls
mission_precache()
{
	maps\nx_lunar_get_to_the_armory::mission_precache();

	// PreCacheModel( "viewmodel_as_mk27" );
	PreCacheModel( "viewmodel_lunar_helm_int" );
	PreCacheModel( "viewhands_us_lunar_scripted" );
	PreCacheModel( "nx_pr_lunar_helm_scripted" );
	PrecacheModel( "nx_lunar_hatch_keypad_anim" );
	PrecacheModel( "nx_lunar_hatch_keypad_green" );
	PrecacheModel( "nx_lunar_door_alertsign_orange" );
	PreCacheModel( "nx_vehicle_ec_lgv_main_turret_obj" );

	// Doors
	PreCacheModel( "nx_lunar_doors_solid01_breached" );
	PreCacheModel( "nx_lunar_doors_window01_breached" );

	PrecacheItem( "freerunner_lunar");
	PrecacheItem( "lunarrifle_silent" );
	PrecacheItem( "lunarrifle_altsound" );
	PrecacheItem( "nx_suitshield" );

	// Shaders
	// PreCacheShader( "dpad_killstreak_hellfire_missile_inactive" );
	PreCacheShader( "ac130_overlay_grain" );
	PrecacheShader( "nx_lunar_helm_crack_001" );
	PrecacheShader( "nx_lunar_helm_crack_002" );
	PrecacheShader( "nx_lunar_helm_crack_003" );
	PrecacheShader( "nx_lunar_helm_crack_004" );
	PrecacheShader( "nx_lunar_helm_crack_005" );
	PrecacheShader( "lunar_crack_lights_l" );
	PrecacheShader( "lunar_crack_lights_m" );
	PrecacheShader( "lunar_crack_lights_r" );
	PrecacheShader( "waypoint_patchkit" );

	PreCacheShellShock( "nx_lunar_drive_in" );

	// Objectives
	PreCacheString( &"NX_LUNAR_SUIT_PATCH_HINT" );
	add_hint_string( "hint_rover_drive", &"NX_LUNAR_HINT_ROVER_DRIVE", ::mission_hint_instructions  );
	add_hint_string( "hint_rover_brake", &"NX_LUNAR_HINT_ROVER_BRAKE", ::mission_hint_instructions  );

	// Misc
	PreCacheModel( "nx_pr_lunar_halldebris0" );
	PreCacheModel( "nx_pr_lunar_halldebris1" );
	PreCacheShellShock( "estate_bouncingbetty" );
	PreCacheShellShock( "lunar_rover_battle" );
	PreCacheShellShock( "flashbang" );
	precachestring( &"NX_LUNAR_INTROSCREEN_1" );
	precachestring( &"NX_LUNAR_INTROSCREEN_2" );
	precachestring( &"NX_LUNAR_INTROSCREEN_3" );
	precachestring( &"NX_LUNAR_INTROSCREEN_4" );
	precachestring( &"NX_LUNAR_INTROSCREEN_5" );

	// Rumbles
	PreCacheRumble( "heavy_3s" );
	precacherumble( "tank_rumble" );
	precacherumble( "steady_rumble" );
}

mission_hint_instructions()
{
	return false;
}

// All mission specific flag_init() calls
mission_flag_inits()
{
	maps\nx_lunar_intro::mission_flag_inits();
	maps\nx_lunar_get_to_the_armory::mission_flag_inits();
	maps\nx_lunar_escape_interior::mission_flag_inits();
	maps\nx_lunar_escape_exterior::mission_flag_inits();
	maps\nx_lunar_take_back_control::mission_flag_inits();	

	// Determines if we're in the middle of a vignette.
	flag_init ("vignette_playing");

	maps\nx_lunar_audio::flag_inits();

	//DR: needed for sfx helmet sound states to fucntion properly
	flag_init( "sfx_int_rover_engsuit_nohelmet_press" );  //(in rover in engineering suit)
	flag_init( "sfx_int_rover_engsuit_helmet_press" );  //(in rover after helmet on)
	flag_init( "sfx_int_rover_engsuit_helmet_depress" );  //(in rover after helmet on and airlock depressurized)
	flag_init( "sfx_ext_surface_engsuit_depress" );  //(on moon surface in engineering suit)
	flag_init( "sfx_int_rover_engsuit_helmet_depress2" );  //(driving back in rover - not sure if decided rover is press or depress at this point)
	flag_init( "sfx_ext_surface_engsuit_semipress" );  //(walking from rover to airlock in a semi-busted engineering suit)
	flag_init( "sfx_int_base_engsuit_helmet_press" );  //(repressurized in the airlock with engineering suit - helmet visor still down)
	flag_init( "sfx_int_base_engsuit_nohelmet_press" );  //(running with helmet up from airlock to armory through pressurized base)
	flag_init( "sfx_int_base_milsuit_press" );  //(after putting on military suit)
	flag_init( "sfx_int_base_milsuit_depress" );  //(after rapid depressurization of armoy breach)
	flag_init( "sfx_int_base_milsuit_press2" );  //(after going through airlock to repressurize)
	flag_init( "sfx_ext_surface_milsuit_depress" );  //(after going through airloack to depresurize)
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Objective logic flow
mission_objective_logic()
{
	// Wait for friendlies to spawn
	waittillframeend; 
	
	// README: wait_for_objective
	// maps\_nx_objective_util::wait_for_objective( objective_num, objective_text, curr_trigger, next_trigger );
 	// curr_trigger - the start point trigger of the objective
	// next_trigger - the end point trigger of the objective 
	// Uses script_origin nodes for pathing ( be sure to have a radius on the nodes )	
	
	level.eagle_support_objective_added = false;
	level.eagle_follow_objective_added = false;
	switch ( level._start_point )
	{
		case "default":
		case "intro":			
			flag_wait( "tower_fall" );
		case "rover_chase":
			flag_wait( "rover_crashed" );
		case "get_to_the_armory":

			// Wait for the player to be mobile before giving objective
			flag_wait( "start_stumble_walk" );
			wait_for_objective( 6, &"NX_LUNAR_OBJECTIVE_REACH_AIRLOCK", "objective_reach_airlock", "objective_in_vehicle_airlock" ); 
			flag_wait ( "player_in_vehicle_airlock" );
			objective_complete( 6 );
			flag_wait( "vehicle_airlock_open" );
			thread wait_for_objective( 7, &"NX_LUNAR_OBJECTIVE_GET_TO_THE_ARMORY", "objective_get_to_armory", "objective_at_the_armory" ); 
			
			// Hide objective during breach vignette			
			flag_wait ("top_floor_breach");
			Objective_State( 7, "invisible" );
			level waittill ("top_floor_breach_done");
			Objective_State( 7, "current" );

			/*wait_for_objective( 7, &"NX_LUNAR_OBJECTIVE_GET_TO_THE_ARMORY", "player_in_vehicle_airlock", "room_status_storage" );
			flag_wait( "falcon_taser_handoff" );
			objective_onentity ( 7, level.falcon_taser, (0, 0, 90));
			Objective_SetPointerTextOverride( 7, &"NX_LUNAR_OBJECTIVE_FOLLOW_MARKER" );
			flag_wait( "vignette_armory_entrance_setup" );
			objective_onentity ( 7, level.eagle, (0, 0, 90));	
			*/

			flag_wait( "vignette_armory_entrance_player" );
			objective_complete( 7 );

			flag_wait ( "player_has_helmet" );

			wait_for_objective( 8, &"NX_LUNAR_OBJECTIVE_GET_WEAPON", "objective_at_the_armory", "objective_get_weapon" ); 	
			flag_wait( "player_has_weapon" );
			objective_complete( 8 );

		case "armory_module":
		case "life_support_module":
			
			// Wait for moving up ramp
			flag_wait( "vo_keep_pushing_cnc" );
			waypoint = getEnt( "objective_no_go_way_point", "targetname" );
			objective_add( 9, "current", &"NX_LUNAR_OBJECTIVE_NO_GO", waypoint.origin );
			objective_current( 9 );

			// Wait for allies to move to the breach
			flag_wait( "life_support_breach_reach" );

			wait( 3.0 );

			objective_delete( 9 );
			objective_add( 10, "current", &"NX_LUNAR_OBJECTIVE_ESCAPE_INTERIOR" );

			// Wait for allies to move to the breach
			flag_wait( "life_support_breach_near" );

			waypoint = getEnt( "objective_life_support_door_waypoint", "targetname" );
			objective_add( 11, "current", &"NX_LUNAR_OBJECTIVE_LIFE_SUPPORT_DOOR", waypoint.origin );
			objective_current( 11 );			

			// Life support open
			flag_wait( "life_support_door_open" );
			objective_complete( 11 );
			objective_current( 10 );

		case "living_module":

			// Wait for living module door open	ready
			flag_wait( "living_module" );

			waypoint = getEnt( "objective_living_door_waypoint", "targetname" );
			objective_add( 12, "current", &"NX_LUNAR_OBJECTIVE_LIVING_DOOR", waypoint.origin );
			objective_current( 12 );

			// Living door open
			flag_wait( "living_door_open" );
			objective_complete( 12 );
			objective_current( 10 );

		case "exterior_vista":

			flag_wait( "exterior_vista" );

			// Second waypoint
			waypoint_1 = getEnt( "objective_exterior_vista_waypoint_1", "targetname" );
			waypoint_2 = getEnt( "objective_exterior_vista_waypoint_2", "targetname" );
			objective_position( 10, waypoint_1.origin );
			wait_for_player_near_waypoint( waypoint_1 );
			objective_position( 10, waypoint_2.origin );
			wait_for_player_near_waypoint( waypoint_2 );
			objective_complete( 10 );

		/*
		case "crew_module":

			// Wait for crew module airlock ready
			flag_wait( "crew_module" );

			waypoint = getEnt( "objective_crew_airlock_waypoint", "targetname" );
			objective_add( 13, "current", &"NX_LUNAR_OBJECTIVE_CREW_AIRLOCK", waypoint.origin );
			objective_current( 13 );

			// Crew airlock open
			flag_wait( "in_crew_airlock" );
			objective_complete( 13 );
			objective_current( 10 );

			// Wait for exterior airlock ready
			flag_wait( "move_allies_to_exterior_airlock" );
			
			// Two waypoint chain to exterior airlock
			waypoint_1 = getEnt( "objective_exterior_airlock_waypoint_1", "targetname" );
			objective_add( 14, "current", &"NX_LUNAR_OBJECTIVE_EXTERIOR_AIRLOCK", waypoint_1.origin );
			objective_current( 14 );

			// Second waypoint
			waypoint_2 = getEnt( "objective_exterior_airlock_waypoint_2", "targetname" );
			wait_for_player_near_waypoint( waypoint_1 );
			objective_position( 14, waypoint_2.origin );

			flag_wait( "in_exterior_airlock" );
			objective_complete( 14 );
			objective_current( 10 );

			// Exterior airlock open
			flag_wait( "exterior_airlock_open" );

			// Clear the get to exterior objective
			objective_complete( 10 );
		*/

		case "airlock_exterior":

			self thread eagle_support_objective();

		case "mining_valley":		

			self thread eagle_support_objective();

		case "rough_terrain":		

			self thread eagle_support_objective();

		case "rover_battle":		
			
			flag_wait( "vignette_falcon_death" );

			// Delete support objective
			objective_delete( 18 );
			
			flag_wait( "rover_battle_start" );
			objective_add( 20, "current", &"NX_LUNAR_OBJECTIVE_ROVER_TROOPS" );
			level waittill( "rover_battle_threat_removed" );
			objective_complete( 20 );

			// Add follow objective back to eagle
			self thread eagle_follow_objective();

		case "into_shadows":

			// Eagle turns and heads to shadows
			level waittill( "eagle_heading_to_shadows" );

			if ( !flag( "vehicle_bay_shadow_enemies_aware" ) )
			{
				// Wait for player to move into the trigger
				wait_for_objective( 22, &"NX_LUNAR_OBJECTIVE_SHADOWS", "objective_at_shadows", "objective_in_shadows" );
				objective_complete( 22 );
			}

			flag_wait( "player_in_kill_position_rover" );

			// Delete follow objective
			objective_delete( 21 );
			level.eagle_follow_objective_added = false;

			flag_wait( "vehicle_bay_return" );

			// Add follow objective back to eagle
			self thread eagle_follow_objective();

		case "vehicle_bay_return":

			// Add follow objective back to eagle
			self thread eagle_follow_objective();

			// Wait for player in vehicle bay
			flag_wait( "objective_hawk_rendezvous" );
			objective_complete( 21 );

			// Add rendezvous objective
			objective_add( 23, "current", &"NX_LUNAR_OBJECTIVE_RENDEZVOUS" );

		case "take_back_control":
	
			// Clear meetup objective
			flag_wait( "control_objective_hawk_meetup" );
			objective_complete( 23 );

			// Add breach objective
			flag_wait( "control_objective_breach" );
			waypoint = getEnt( "objective_breach_waypoint", "targetname" );
			objective_add( 24, "current", &"NX_LUNAR_OBJECTIVE_BREACH", waypoint.origin );

			// Clear breach objective
			level waittill("breaching");
			objective_complete( 24 );

			// Support eagle and hawk in C&C
			level waittill( "slomo_breach_over" );
			self thread eagle_and_hawk_support_objective();
	
		case "take_back_control_ending":
	
			// Engage override
			flag_wait( "close_c_and_c_doors" );
			objective_complete( 25 );
			waypoint = getEnt( "objective_lsp_waitpoint", "targetname" );
			waypoint_door = getEnt( "objective_lsp_waitpoint_door", "targetname" );
			objective_add( 26, "current", &"NX_LUNAR_OBJECTIVE_LSP_OVERRIDE", waypoint_door.origin );
			
			flag_wait( "c_and_c_doors_open" );
			Objective_Position( 26, waypoint.origin );

			// End of level
			flag_wait( "control_lsp_activated" );
			objective_complete( 26 );
	
		case "no_game_moon":
			break;
		default:
			AssertMsg( "No objectives set for this start point" );
	}
}

eagle_support_objective()
{
	// Support objective attached to Eagle
	if( IsDefined( level.eagle ) && !level.eagle_support_objective_added )
	{
		objective_add( 18, "current", &"NX_LUNAR_OBJECTIVE_SUPPORT_EAGLE" );
		Objective_OnEntity( 18, level.eagle, (0, 0, 90) );
		Objective_SetPointerTextOverride( 18, &"NX_LUNAR_OBJECTIVE_SUPPORT_MARKER" );
		level.eagle_support_objective_added = true;
	}
}

eagle_follow_objective()
{
	if( IsDefined( level.eagle ) && !level.eagle_follow_objective_added )
	{
		objective_add( 21, "current", &"NX_LUNAR_OBJECTIVE_SUPPORT_EAGLE" );
		Objective_OnEntity( 21, level.eagle, (0, 0, 90) );
		Objective_SetPointerTextOverride( 21, &"NX_LUNAR_OBJECTIVE_FOLLOW_MARKER" );
		level.eagle_follow_objective_added = true;
	}
}

eagle_and_hawk_support_objective()
{
	// Support objective attached to Eagle
	if( IsDefined( level.eagle ) && IsDefined( level.hawk ) )
	{
		objective_add( 25, "current", &"NX_LUNAR_OBJECTIVE_SUPPORT_EAGLE_AND_HAWK" );
		Objective_OnEntity( 25, level.eagle, (0, 0, 90) );
		Objective_OnAdditionalEntity( 25, 1, level.hawk, (0, 0, 90) );
		Objective_SetPointerTextOverride( 25, &"NX_LUNAR_OBJECTIVE_SUPPORT_MARKER" );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

nx_lunar_door_status_init()
{
	// Init doors for get to the armory
	maps\nx_lunar_get_to_the_armory::get_to_the_armory_door_status_init();
	maps\nx_lunar_escape_interior::escape_interior_door_status_init();

	level thread maps\nx_lunar_util::lunar_door_status( "vehicle_bay_hub_entrance", "status_red" );
	level thread maps\nx_lunar_util::lunar_door_status( "command_center_entrance", "status_red" );
	level thread maps\nx_lunar_util::lunar_door_status( "command_center_exit", "status_red" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


mission_music_debug_to_checkpoint_set_flags ()
{
//this script will set the necessary flags needed for the music script to work when jumping to
//a new checkpoint in the debug menu.

	waittillframeend;

	//iprintln ( "MUSIC LEVEL STARTING FLAGS AT " + level._start_point);

	switch ( level._start_point )
	{
		case "default":						
			//iprintln ("not setting any music flags for default");
			break;

		case "intro":			
			//iprintln ("setting music flags for intro");
			//iprintln ("not setting any music flags for intro");			
			break;

		case "rover_chase":
			//iprintln ("setting music flags for rover chase");		

			//setting sfx helmet sound state flags
			flag_set( "sfx_int_rover_engsuit_nohelmet_press" );
			flag_set( "sfx_int_rover_engsuit_helmet_press" );
			flag_set( "sfx_int_rover_engsuit_helmet_depress" );
			flag_set( "sfx_ext_surface_engsuit_depress" );
			flag_set( "sfx_int_rover_engsuit_helmet_depress2" );						
			break;

		case "get_to_the_armory":
			//iprintln ("setting music flags for get to the armory");			

			//setting sfx helmet sound state flags
			flag_set( "sfx_int_rover_engsuit_nohelmet_press" );
			flag_set( "sfx_int_rover_engsuit_helmet_press" );
			flag_set( "sfx_int_rover_engsuit_helmet_depress" );
			flag_set( "sfx_ext_surface_engsuit_depress" );
			flag_set( "sfx_int_rover_engsuit_helmet_depress2" );
			flag_set( "sfx_ext_surface_engsuit_semipress" );			
			break;

		case "armory_module":
		case "life_support_module":
		case "living_module":
			//iprintln ("setting music flags for modules");		
			
			//setting sfx helmet sound state flags
			flag_set( "sfx_int_rover_engsuit_nohelmet_press" );
			flag_set( "sfx_int_rover_engsuit_helmet_press" );
			flag_set( "sfx_int_rover_engsuit_helmet_depress" );
			flag_set( "sfx_ext_surface_engsuit_depress" );
			flag_set( "sfx_int_rover_engsuit_helmet_depress2" );
			flag_set( "sfx_ext_surface_engsuit_semipress" );				
			flag_set( "sfx_int_base_engsuit_helmet_press" );				
			flag_set( "sfx_int_base_engsuit_nohelmet_press" );				
			flag_set( "sfx_int_base_milsuit_press" );				
			flag_set( "sfx_int_base_milsuit_depress" );										
			break;

		case "exterior_vista":
			//iprintln ("setting music flags for modules");		
			
			//setting sfx helmet sound state flags
			flag_set( "sfx_int_rover_engsuit_nohelmet_press" );
			flag_set( "sfx_int_rover_engsuit_helmet_press" );
			flag_set( "sfx_int_rover_engsuit_helmet_depress" );
			flag_set( "sfx_ext_surface_engsuit_depress" );
			flag_set( "sfx_int_rover_engsuit_helmet_depress2" );
			flag_set( "sfx_ext_surface_engsuit_semipress" );				
			flag_set( "sfx_int_base_engsuit_helmet_press" );				
			flag_set( "sfx_int_base_engsuit_nohelmet_press" );				
			flag_set( "sfx_int_base_milsuit_press" );				
			flag_set( "sfx_int_base_milsuit_depress" );										
			break;


		case "airlock_exterior":
		case "mining_valley":
		case "rough_terrain":
			//iprintln ("setting music and sfx flags for airlock to exterior");			
			break;

		case "rover_battle":
			//iprintln ("setting music and sfx flags for rover battle starting");
			//flag_set( "music_rover_battle_starts" );				
			break;

		case "into_shadows":
			//iprintln ("setting music and sfx flags for sneaking up behind rover");			
			break;

		case "vehicle_bay_return":
		case "take_back_control":
		case "take_back_control_ending":
		case "no_game_moon":
			//iprintln ("setting music and sfx flags for rover battle starting");			

			//setting sfx helmet sound state flags
			flag_set( "sfx_int_rover_engsuit_nohelmet_press" );
			flag_set( "sfx_int_rover_engsuit_helmet_press" );
			flag_set( "sfx_int_rover_engsuit_helmet_depress" );
			flag_set( "sfx_ext_surface_engsuit_depress" );
			flag_set( "sfx_int_rover_engsuit_helmet_depress2" );
			flag_set( "sfx_ext_surface_engsuit_semipress" );				
			flag_set( "sfx_int_base_engsuit_helmet_press" );				
			flag_set( "sfx_int_base_engsuit_nohelmet_press" );				
			flag_set( "sfx_int_base_milsuit_press" );				
			flag_set( "sfx_int_base_milsuit_depress" );							
			flag_set( "sfx_int_base_milsuit_press2" );
			flag_set( "sfx_ext_surface_milsuit_depress" );
			break;

		default:
			AssertMsg( "No music flag set defined for this start point" );
	}

}

mission_sfx_helmet_states()
{
	//DR: this script will wait for a flag to be set, and then set the EQ 
	//and volume for the correct suit/helemt state in that part of the mission.
	//It should also function correctly when you jump to checkpoint because
	//now we are using flags, and single linear script.  the flags for jumping 
	//to checkpoint get set in the script above, mission_music_debug_to_checkpoint_set_flags 

/*
//DR: commenting out flags from first part of mission, FOR NOW, since they may have unintended consequences, 
//like the music flags did (triggering events during the black screen intro


	flag_wait( "sfx_int_rover_engsuit_nohelmet_press" );  //(in rover in engineering suit)
	if( !flag( "sfx_int_rover_engsuit_helmet_press" ) )
	{
		level._player thread maps\nx_lunar_util::lunar_suit_state_settings( undefined, "moon_engsuit_pres_helmet_off", "null" );
	}

	

	flag_wait( "sfx_int_rover_engsuit_helmet_press" );  //(in rover after helmet on)
	if( !flag( "sfx_int_rover_engsuit_helmet_depress" ) )
	{
		level._player thread maps\nx_lunar_util::lunar_suit_state_settings( undefined, "moon_engsuit_pres_helmet_on", "amb_space_suit_amb", 1.5 );
	}	
	

	flag_wait( "sfx_int_rover_engsuit_helmet_depress" );  //(in rover after helmet on and airlock depressurized)
	//set eq and volume here
	//currently no change since there aren't any sounds that continue past the parking of the rover
	//however, if we had some hydraulics, and the music still going, then we could have those fade out
	//during the depressurization of the airlock
	if( !flag( "sfx_ext_surface_engsuit_depress" ) )
	{
		level._player thread maps\nx_lunar_util::lunar_suit_state_settings( undefined, "moon_engsuit_depres_helmet_on", "amb_space_suit_amb", 1.5 );
	}
	
	
		
	flag_wait( "sfx_ext_surface_engsuit_depress" );  //(on moon surface in engineering suit)
	//set eq and volume here
	//currently no change since there aren't any sounds that continue past the parking of the rover
	//this is most likely the same as the previous state, depressurized in the rover	
	if( !flag( "sfx_int_rover_engsuit_helmet_depress2" ) )
	{
		level._player thread maps\nx_lunar_util::lunar_suit_state_settings( undefined, "moon_engsuit_depres_helmet_on", "amb_space_suit_amb", 0.0 );
	}	



	flag_wait( "sfx_int_rover_engsuit_helmet_depress2" );  //(driving back in rover - not sure if decided rover is press or depress at this point)
	if( !flag( "sfx_ext_surface_engsuit_semipress" ) )
	{
		level._player thread maps\nx_lunar_util::lunar_suit_state_settings( undefined, "moon_engsuit_depres_helmet_on", "amb_space_suit_amb" );
	}
	
*/	


	flag_wait( "sfx_ext_surface_engsuit_semipress" );  //(walking from rover to airlock in a semi-busted engineering suit)
	//iprintlnbold("sfx_ext_surface_engsuit_semipress");
	if( !flag( "sfx_int_base_engsuit_helmet_press" ) )
	{
		level._player thread maps\nx_lunar_util::lunar_suit_state_settings( "moon", "moon_engsuit_depres_helmet_on", "amb_space_suit_amb" );
	}
		


	flag_wait( "sfx_int_base_engsuit_helmet_press" );  //(repressurized in the airlock with engineering suit - helmet visor still down).
	//iprintlnbold("sfx_int_base_engsuit_helmet_press");
	if( !flag( "sfx_int_base_engsuit_nohelmet_press" ) )
	{
		level._player thread maps\nx_lunar_util::lunar_suit_state_settings( "moon_pres", "moon_engsuit_pres_helmet_on", "amb_space_suit_amb", 1.5 );
	}
	
	

	flag_wait( "sfx_int_base_engsuit_nohelmet_press" );  //(running with helmet up from airlock to armory through pressurized base)
	//iprintlnbold("sfx_int_base_engsuit_nohelmet_press");
	if( !flag( "sfx_int_base_milsuit_press" ) )
	{
		level._player thread maps\nx_lunar_util::lunar_suit_state_settings( "", "moon_engsuit_pres_helmet_off", "null", 1.5 );					
	}	


	flag_wait( "sfx_int_base_milsuit_press" );  //(after putting on military suit - this one has the laser mic)
	//iprintlnbold("sfx_int_base_milsuit_press");
	if( !flag( "sfx_int_base_milsuit_depress" ) )
	{
		level._player thread maps\nx_lunar_util::lunar_suit_state_settings( "moon_pres", "moon_milsuit_pres_helmet_on", "null", 1.5 );
	}
	
	

	flag_wait( "sfx_int_base_milsuit_depress" );  //(after rapid depressurization of armoy breach - this one has the laser mic)
	//iprintlnbold("sfx_int_base_milsuit_depress");
	if( !flag( "sfx_int_base_milsuit_press2" ) )
	{
		level._player thread maps\nx_lunar_util::lunar_suit_state_settings( "moon", "moon_milsuit_depres_helmet_on", "null", 1.5 );

		//set ambience
		//thread maps\_ambient::play_ambience( "nx_lunar_armory_depress" );
		//thread maps\_ambient::start_ambient_event( "nx_lunar_armory_depress" );
		wait 2.0;
		thread maps\_utility::set_ambient( "nx_lunar_armory_depress" );

	}	

		

/* JL: This sequence has been removed for the GL
	flag_wait( "sfx_int_base_milsuit_press2" );  //(after going through airlock to repressurize)
	//iprintlnbold("sfx_int_base_milsuit_press2");
	if( !flag( "sfx_ext_surface_milsuit_depress" ) )
	{
		level._player thread maps\nx_lunar_util::lunar_suit_state_settings( "moon_pres", "moon_milsuit_pres_helmet_on", "amb_space_suit_amb", 2.1 );
	}
*/	
	

	flag_wait( "sfx_ext_surface_milsuit_depress" );  //(after going through airloack to depresurize)
	//iprintlnbold("sfx_ext_surface_milsuit_depress");
	level._player thread maps\nx_lunar_util::lunar_suit_state_settings( "moon", "moon_milsuit_depres_helmet_on", "amb_space_suit_amb", 2.1 );
	
	thread maps\_utility::set_ambient( "nx_lunar_exterior_depress" );
	//thread maps\_ambient::play_ambience( "nx_lunar_exterior_depress" );
	//thread maps\_ambient::start_ambient_event( "nx_lunar_exterior_depress" );
	
}

mission_threat_setup()
{
	CreateThreatBiasGroup( "enemy_troops" );
	CreateThreatBiasGroup( "enemy_in_shadows" );
	CreateThreatBiasGroup( "enemy_rover_backup" );
	CreateThreatBiasGroup( "road_runners" );
	CreateThreatBiasGroup( "player_squad" );
	CreateThreatBiasGroup( "player" );

	level._player SetThreatBiasGroup( "player" );

	IgnoreEachOther( "player_squad", "enemy_in_shadows" );
}

//*******************************************************************
//  Intro Checkpoint - KenM      		                            *
//                                                                  *
//*******************************************************************

intro()
{	
	maps\nx_lunar_intro::intro();
}

intro_start()
{
	maps\nx_lunar_intro::intro_start();
}


//*******************************************************************
//  Rover Chase Checkpoint - KenM                                   *
//                                                                  *
//*******************************************************************

rover_chase()
{	
	maps\nx_lunar_intro::rover_chase();
}

rover_chase_start()
{
	maps\nx_lunar_intro::rover_chase_start();
}

//*******************************************************************
//  Get to the Armory - Travis Chen                                 *
//                                                                  *
//*******************************************************************

get_to_the_armory_start()
{
	// tagTC<note>: moved to external nx_lunar_get_to_the_armory.gsc
	maps\nx_lunar_get_to_the_armory::get_to_the_armory_start();
}

get_to_the_armory()
{
	// tagTC<note>: moved to external nx_lunar_get_to_the_armory.gsc
	maps\nx_lunar_get_to_the_armory::get_to_the_armory();
}

//*******************************************************************
//  Escape Interior - Travis Chen                                 	*
//                                                                  *
//*******************************************************************

armory_module_start()
{
	maps\nx_lunar_escape_interior::armory_module_start();
}

armory_module()
{
	maps\nx_lunar_escape_interior::armory_module();
}

//*******************************************************************
//  Escape Interior - Travis Chen                                 	*
//                                                                  *
//*******************************************************************

life_support_module_start()
{
	maps\nx_lunar_escape_interior::life_support_module_start();
}

life_support_module()
{
	maps\nx_lunar_escape_interior::life_support_module();
}

//*******************************************************************
//  Escape Interior - Travis Chen                                 	*
//                                                                  *
//*******************************************************************

living_module_start()
{
	maps\nx_lunar_escape_interior::living_module_start();	
}

living_module()
{
	maps\nx_lunar_escape_interior::living_module();
}

//*******************************************************************
//  Escape Interior - Travis Chen                                 	*
//                                                                  *
//*******************************************************************

exterior_vista_start()
{
	maps\nx_lunar_escape_interior::exterior_vista_start();
}

exterior_vista()
{
	maps\nx_lunar_escape_interior::exterior_vista();
}

//*******************************************************************
//  Escape Interior - Travis Chen                                 	*
//                                                                  *
//*******************************************************************

/*
crew_module_start()
{
	maps\nx_lunar_escape_interior::crew_module_start();
}

crew_module()
{
	maps\nx_lunar_escape_interior::crew_module();
}
*/

//*******************************************************************
//  Escape Interior - Travis Chen                                 	*
//                                                                  *
//*******************************************************************

airlock_exterior_start()
{
	maps\nx_lunar_escape_exterior::airlock_exterior_start();
}

airlock_exterior()
{
	maps\nx_lunar_escape_exterior::airlock_exterior();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

mining_valley_start()
{
	maps\nx_lunar_escape_exterior::mining_valley_start();
}

mining_valley()
{	
	maps\nx_lunar_escape_exterior::mining_valley();

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rough_terrain_start()
{
	maps\nx_lunar_escape_exterior::rough_terrain_start();
}

rough_terrain()
{	
	maps\nx_lunar_escape_exterior::rough_terrain();

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rover_battle_start()
{
	maps\nx_lunar_escape_exterior::rover_battle_start();
}

rover_battle()
{
	maps\nx_lunar_escape_exterior::rover_battle();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

into_shadows_start()
{
	maps\nx_lunar_escape_exterior::into_shadows_start();
}

into_shadows()
{
	maps\nx_lunar_escape_exterior::into_shadows();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vehicle_bay_return_start()
{
	maps\nx_lunar_take_back_control::vehicle_bay_return_start();
}

vehicle_bay_return()
{
	maps\nx_lunar_take_back_control::vehicle_bay_return();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

take_back_control_start()
{
	maps\nx_lunar_take_back_control::take_back_control_start();
}

take_back_control()
{
	maps\nx_lunar_take_back_control::take_back_control();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

take_back_control_ending_start()
{
	maps\nx_lunar_take_back_control::take_back_control_ending_start();
}

take_back_control_ending()
{
	maps\nx_lunar_take_back_control::take_back_control_ending();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Empty logic for debug no_game point
no_game_moon()
{
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************










