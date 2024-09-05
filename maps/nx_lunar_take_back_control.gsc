//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_LUNAR Take Back Control Mission Script					**
//                                                                          **
//    Created: 2/24/2010 - Daryl Kimoto										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_utility_code;
#include maps\_nx_vignette_util;
#include maps\_nx_objective_util;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_art;
#include maps\_vehicle;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

mission_flag_inits()
{
	flag_init( "vehicle_bay_return" );
	flag_init( "take_back_control" );
	flag_init( "control_room_door_open" );
	flag_init( "control_door_breached" );
	flag_init( "control_door_breaching" );
	flag_init( "control_lsp_activated" );
	flag_init( "control_objective_hawk_meetup" );
	flag_init( "control_objective_breach" );
	flag_init( "c_and_c_doors_open" );

	flag_init( "c_and_c_enemies_cleared" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vehicle_bay_return_start()
{
	// Start the player and allies
	maps\nx_lunar_util::lunar_start( "vehicle_bay_return_start", "vehicle_bay_return_eagle_start" );

	// Init combat
	maps\nx_lunar_util::lunar_combat_init();

	// Make sure all vehicle bay doors are open
	maps\nx_lunar_get_to_the_armory::open_all_vehicle_bay_doors();

	// FX
	level thread start_lsp_fx();
	
	// Initial Vision
	thread maps\nx_lunar_fx::fx_init_vision_surface();

	// Remove vehicle bay blocking crates
	// maps\nx_lunar_get_to_the_armory::remove_vehicle_bay_blockers();
}

vehicle_bay_return()
{
	flag_set( "vehicle_bay_return" );

	// Dialogue
	level thread vehicle_bay_return_VO();

	// Save the game
	level thread autosave_now();

	// Setup triggers
	maps\nx_lunar_util::all_triggers_on( "vehicle_bay_return_triggers" );
	maps\nx_lunar_util::all_triggers_on( "vehicle_bay_return_left_route" );
	maps\nx_lunar_util::all_triggers_on( "vehicle_bay_return_right_route" );
	trigger_off( "move_allies_to_hub", "targetname" );

	// Enemy
	level thread vehicle_bay_enemy_spawn();

	// Player
	level._player thread vehicle_bay_player_thread();

	// Eagle thread
	level.eagle thread vehicle_bay_eagle_thread();

	// Spawn allies
	level thread take_back_control_ally_spawn();

	// Open door 
	flag_wait( "open_vehicle_hub_door" );
	wait( 1.0 );
	level thread maps\nx_lunar_util::open_lunar_door( "vehicle_bay_hub_entrance", 1.0, true );

	// Wait for enemies dead
	waittill_aigroupcleared( "enemy_vehicle_bay" );
	wait( 1.5 );
	trigger_on( "move_allies_to_hub", "targetname" );
}

//*******************************************************************
//                                                                  *
//*******************************************************************

vehicle_bay_return_VO()
{
	flag_wait( "vo_jesus_what_a_mess" );

	// Jesus... what a mess…
	radio_dialogue( "moon_eag_ext_37" );

	// C&C is ahead – be ready…
	radio_dialogue( "moon_eag_ext_36" );

	flag_wait( "vo_vehicle_tangos_right" );

	// Tangos right!
	radio_dialogue( "moon_eag_int_14" );
}

//*******************************************************************
//                                                                  *
//*******************************************************************

vehicle_bay_player_thread()
{
}

//*******************************************************************
//                                                                  *
//*******************************************************************
					 
vehicle_bay_enemy_spawn()
{
	CreateThreatBiasGroup( "vehicle_bay" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_vehicle_bay" );
}

enemy_vehicle_bay_spawn_func()
{
	self endon( "death" );
	self thread maps\nx_lunar_util::lunar_enemy_interior_common();

	self thread disable_surprise();

	self SetThreatBiasGroup( "vehicle_bay" );
	setthreatbias( "vehicle_bay", "player", 10000 );
}

//*******************************************************************
//                                                                  *
//*******************************************************************
				 
vehicle_bay_eagle_thread()
{
	flag_wait( "vehicle_bay_return_ignore_on" );
	self.ignoreall = true;
	thread maps\nx_lunar_fx::fx_lunar_take_back_control_vision_change();

	flag_wait( "vehicle_bay_return_ignore_off" );
	self.ignoreall = false;

	old_accuracy = self.baseaccuracy;
	self.baseaccuracy = 0.1;

	flag_wait( "take_back_control" );
	self.baseaccuracy = old_accuracy;
}
				 
//*******************************************************************
//                                                                  *
//*******************************************************************				 

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

DEBUG_TAKE_BACK_CONTROL = false;

take_back_control_start()
{
	// Start the player and allies
	maps\nx_lunar_util::lunar_start( "take_back_control_start", "take_back_control_eagle_start" );
	level thread take_back_control_ally_spawn();

	// Init combat
	maps\nx_lunar_util::lunar_combat_init();

	// Open doors
	level thread maps\nx_lunar_get_to_the_armory::open_all_vehicle_bay_doors();
	level thread maps\nx_lunar_util::open_lunar_door( "vehicle_bay_hub_entrance", 0.2 );

	// FX
	level thread start_lsp_fx();

	// Vision
	thread maps\nx_lunar_fx::fx_init_vision_breached_helmet();

	// Remove vehicle bay blocking crates
	// maps\nx_lunar_get_to_the_armory::remove_vehicle_bay_blockers();

	thread play_bink_on_c_and_c_screens();
}

take_back_control()
{
	flag_set( "take_back_control" );

	// Save the game
	level thread autosave_now();

	// VO
	level thread take_back_control_VO();

	// Triggers
	trigger_on( "move_allies_to_hub", "targetname" );
	maps\nx_lunar_util::all_triggers_on( "control_triggers" );
	maps\nx_lunar_util::all_triggers_off( "control_breach_triggers" );
	maps\nx_lunar_util::all_triggers_off( "c_and_c_triggers" );
	maps\nx_lunar_util::all_triggers_off( "take_back_control_ending_triggers" );
	trigger_off( "take_back_control_open_door", "targetname" );
	trigger_off( "take_back_control_open_door_move", "targetname" );

	// Player
	level._player thread take_back_control_player_thread();
	level._player thread take_back_control_danger_zone();

	// Enemies
	level thread take_back_control_enemy_spawn();
	
	// Breach Actors
	level thread maps\nx_lunar_control_room_breach::casual_placeholder_enemy_animations();
	level thread maps\nx_lunar_control_room_breach::friendly_actor_breach_start();
	level thread maps\nx_lunar_control_room_breach::enemy_actor_breach_start();

	// Vignette
	level thread take_back_control_greeting_vignette();

	// Open doors
	level thread maps\nx_lunar_util::open_lunar_door( "c_and_c_door_1", 0.2 );
	level thread maps\nx_lunar_util::open_lunar_door( "c_and_c_door_2", 0.2 );

	// Wait for breached
	flag_wait( "control_door_breached" );

	// Enemy counter
	level thread c_and_c_enemy_counter();

	flag_wait( "close_c_and_c_doors" );

	level thread maps\nx_lunar_util::close_lunar_door( "c_and_c_door_1" );
	level thread maps\nx_lunar_util::close_lunar_door( "c_and_c_door_2" );

	// Wait for all enemies cleared
	flag_wait( "c_and_c_enemies_cleared" );
}

play_bink_on_c_and_c_screens()
{
	for ( ;; )
	{
		maps\_hud_util::load_cinematic( "nx_lunar_screen1_big" );
		maps\_hud_util::play_cinematic();

		while ( IsCinematicPlaying() )
		{
			wait 0.05;
		}
	}
}

c_and_c_enemy_counter()
{
	init_c_and_c_enemy_down_VO();

	prev_total = -1;
	while( 1 )
	{
		total_enemies = get_ai_group_sentient_count( "enemy_control_floor_1_side" );
		total_enemies += get_ai_group_sentient_count( "enemy_control_floor_1_main" );
		total_enemies += get_ai_group_sentient_count( "enemy_control_floor_1_main_scripted" );
		total_enemies += get_ai_group_sentient_count( "enemy_control_floor_1_resupply" );
		total_enemies += get_ai_group_sentient_count( "enemy_control_floor_2" );

		// Enemy killed, play audio
		if( total_enemies < prev_total && prev_total > -1 )
		{
			level thread c_and_c_enemy_down_VO();
		}

		// Break out when enemies are killed
		if( total_enemies <= 1 && flag( "close_c_and_c_doors" ) )
		{
			break;
		}

		// Set prev
		prev_total = total_enemies;

		//IPrintln( "C and C enemies: " + total_enemies );
		wait( 1 );
	}

	// No more enemies, set all clear flag
	flag_set( "c_and_c_enemies_cleared" );

	// All clear. Move forward.
	radio_dialogue( "moon_hawk_ext_cncclear" );
}

init_c_and_c_enemy_down_VO()
{
	level.enemy_down_vo_hawk = [];
	level.enemy_down_vo_hawk[ level.enemy_down_vo_hawk.size ] = "moon_hawk_kill_yell_01";
	level.enemy_down_vo_hawk[ level.enemy_down_vo_hawk.size ] = "moon_hawk_kill_yell_02";
	level.enemy_down_vo_hawk[ level.enemy_down_vo_hawk.size ] = "moon_hawk_kill_yell_04";
	level.enemy_down_vo_hawk[ level.enemy_down_vo_hawk.size ] = "moon_hawk_kill_yell_05";
	level.enemy_down_vo_hawk[ level.enemy_down_vo_hawk.size ] = "moon_hawk_kill_yell_06";

	level.enemy_down_vo_eagle = [];
	level.enemy_down_vo_eagle[ level.enemy_down_vo_eagle.size ] = "moon_eag_kill_yell_01";
	level.enemy_down_vo_eagle[ level.enemy_down_vo_eagle.size ] = "moon_eag_kill_yell_02";
	level.enemy_down_vo_eagle[ level.enemy_down_vo_eagle.size ] = "moon_eag_kill_yell_04";
	level.enemy_down_vo_eagle[ level.enemy_down_vo_eagle.size ] = "moon_eag_kill_yell_05";
	level.enemy_down_vo_eagle[ level.enemy_down_vo_eagle.size ] = "moon_eag_kill_yell_06";

	level.unused_enemy_down_vo_hawk = level.enemy_down_vo_hawk;
	level.unused_enemy_down_vo_eagle = level.enemy_down_vo_eagle;
}

c_and_c_enemy_down_VO()
{
	level._player endon( "death" );   
   
	// Who is closer, hawk or eagle
	hawk = true;
	hawk_dist = Distance( level._player.origin, level.hawk.origin );
	eagle_dist = Distance( level._player.origin, level.eagle.origin );
	if( hawk_dist > eagle_dist )
	{
		hawk = false;
	}

	// Only play line sometimes
	percent = RandomFloat( 1.0 );
	if(	percent < 0.2 )
	{
		// Reset unused
		if( hawk )
		{
			if ( level.unused_enemy_down_vo_hawk.size == 0 )
				level.unused_enemy_down_vo_hawk = level.enemy_down_vo_hawk;

			// Choose a line randomly
			line = random( level.unused_enemy_down_vo_hawk );

			// Play the line
			radio_dialogue( line );
 
			// remove the line just played from the array
			level.unused_enemy_down_vo_hawk = array_remove( level.unused_enemy_down_vo_hawk, line );
			level.unused_enemy_down_vo_hawk = array_removeUndefined( level.unused_enemy_down_vo_hawk );
		}
		else
		{
			if ( level.unused_enemy_down_vo_eagle.size == 0 )
				level.unused_enemy_down_vo_eagle = level.enemy_down_vo_eagle;

			// Choose a line randomly
			line = random( level.unused_enemy_down_vo_eagle );

			// Play the line
			radio_dialogue( line );
 
			// remove the line just played from the array
			level.unused_enemy_down_vo_hawk = array_remove( level.unused_enemy_down_vo_hawk, line );
			level.unused_enemy_down_vo_hawk = array_removeUndefined( level.unused_enemy_down_vo_hawk );
		}
	}
}

take_back_control_VO()
{
	flag_wait( "vo_take_back_hub_enter" );

	// Vandenberg.
	//radio_dialogue( "moon_eag_ext_39" );

	// tagTC<note> - I'm adding these lines back in until the've been 
	// integrated into the vignette.

	// Crow!… Walker!… you everyone?
	//radio_dialogue( "moon_hawk_vanrv_01" );

	// Riggs didn't make it. We're it.
	//radio_dialogue( "moon_eag_vanrv_01" );
	
	// tagTC<note> - Hack wait till vo is implemented in vignette
	//wait( 5.0 );	

	// tagTC<note> - It's weird this and below are the same basic line.
	// <grunts acknowledgment>. The EC  have Command and Control locked down. 
	// radio_dialogue( "moon_hawk_vanrv_02" );

	// The EC have Command and Control sealed up. They're overheatin' our power systems.
	//radio_dialogue( "moon_hawk_vanrv_06" );

	// <grunts while pulling breacher from dead enemy> It's time for a little payback. 
	//radio_dialogue( "moon_hawk_vanrv_03" );

	// <brandishes breach gun> We're breaching the control room.
	//radio_dialogue( "moon_hawk_ext_breaching" );

	flag_wait( "control_room_door_open" );

	// Let's move.
	//radio_dialogue( "moon_hawk_ext_letsmove" );

	// Room’s dark and they’re blind. Stay quiet
	radio_dialogue( "moon_hawk_ext_blind" );

	flag_wait( "vo_take_back_breach" );

	// Ready to breach. Walker, grab onto something.
	level thread radio_dialogue( "moon_hawk_ext_readytobreach" );

	// Target anyone with a helmet on.
	//level thread radio_dialogue( "moon_hawk_ext_targethelmet" );

	// Wait till breach
	flag_wait( "control_door_breached" );

	radio_dialogue( "moon_eag_int_26" );

	// Tangos on both floors, engage!
	battlechatter_on( "allies" );

	flag_wait( "vo_work_your_way_around" );

	// Work your way around.
	radio_dialogue( "moon_eag_ext_workaround" );

	// We need to get to the Override Control.
	radio_dialogue( "moon_hawk_ext_override" );

	// Crow, second level! I'll take ground floor.
	radio_dialogue( "moon_hawk_ext_secondlvl" );
	
	wait( 4.0 );

	// Move forward 
	radio_dialogue( "moon_hawk_move_03" );

	level thread vo_upper_route_thread();
	level thread vo_lower_route_thread();

	flag_wait( "close_c_and_c_doors" );

	// Go! Go! Go!
	radio_dialogue( "moon_hawk_move_04" );
}

vo_upper_route_thread()
{
	flag_wait( "vo_upper_route" );

	// Enemies headed your way. (If player takes upper route)
	radio_dialogue( "moon_hawk_ext_headedup" );
}

vo_lower_route_thread()
{
	flag_wait( "vo_lower_route" );

	// Reinforcements headed your way. (If player takes lower route)
	radio_dialogue( "moon_eag_ext_reinheaded" );
}

//*******************************************************************
//                                                                  *
//*******************************************************************

take_back_control_player_thread()
{
	self EnableUsability();

//	tagTC<note> - commenting out to ready for Colin's breach
// 	Wait for player to trigger breach
//	control_breach = GetEnt( "control_breach", "targetname" );
//	control_breach trigger_on();
//	control_breach sethintstring( &"NX_LUNAR_CONTROL_BREACH_HINT" );		
//	control_breach waittill( "trigger" );
//	control_breach trigger_off();

	// tagTC<NOTE> - COLIN, this flag should be set when the player is breaching but the door hasn't been breached
	flag_set( "control_door_breaching" );

	// Breach done, player kiling people now
	level waittill( "slomo_breach_over" );

	// 	Open door and player FX
//	level thread maps\nx_lunar_util::open_lunar_door( "control_door_breach", 0.2, true );
//	level thread maps\nx_lunar_util::lunar_door_breach_fx( "control_door_breach" );
//	level thread remove_door_player_clip( "control_door_breach_player_clip", 2.0 );

	// tagTC<NOTE> - COLIN, this flag and triggers should be set when the breach is complete
	maps\nx_lunar_util::all_triggers_on( "control_breach_triggers" );	
	flag_set( "control_door_breached" );

	// Save the game
	level thread autosave_now();

	// Danger zone
	level._player thread maps\nx_lunar_util::player_danger_zone();
}

take_back_control_danger_zone()
{
	// Turn on danger zone
	self thread maps\nx_lunar_util::player_danger_zone();
	
	// Wait for off danger zone
	self thread maps\nx_lunar_util::end_danger_zone();	
}

//*******************************************************************
//                                                                  *
//*******************************************************************

take_back_control_greeting_vignette()
{
	flag_set( "control_objective_hawk_meetup" );
	
	if( !DEBUG_TAKE_BACK_CONTROL )
	{
		end_greet_body = vignette_actor_spawn( "end_greet_body", "end_greet_body" );

		maps\nx_lunar_anim::end_greet( end_greet_body, level.hawk, level.pigeon );

		end_greet_body vignette_actor_kill();
	}

	trigger_on( "take_back_control_open_door", "targetname" );
}

//*******************************************************************
//                                                                  *
//*******************************************************************

take_back_control_ally_spawn()
{
	// Make sure falcon is dead
	if( IsAlive( level.falcon ) )
	{
		level.falcon stop_magic_bullet_shield();
		level.falcon kill();
	}

	level.hawk = take_back_control_ally_spawn_shared( "hawk" );
	level.hawk thread control_hawk_thread();

	level.pigeon = take_back_control_ally_spawn_shared( "pigeon" );
	level.pigeon thread control_pigeon_thread();

	level.seagull = take_back_control_ally_spawn_shared( "seagull" );
	level.seagull thread control_seagull_thread();

	level.eagle thread control_eagle_thread();
}

control_eagle_thread()
{
	// CQB Eagle
	self enable_cqbwalk();
	self thread disable_surprise();
	self thread ally_protect();
}

remove_door_player_clip( door_name, wait_for_remove )
{
	wait( wait_for_remove );
	player_clip = GetEnt( door_name, "targetname" );
	
	player_clip Delete();
}

control_hawk_thread()
{
	self endon( "death" );

	// Open control door
	flag_wait( "control_open_door" );

	// Hawk, open door
	maps\nx_lunar_util::open_lunar_door_vignette( "control_door_1", true, 0, true );
	level thread remove_door_player_clip( "control_door_player_clip", 2.0 );
	level thread maps\nx_lunar_util::open_lunar_door( "control_door_1", 1.0 );
	flag_set( "control_room_door_open" );	

	// Breach objective
	flag_set( "control_objective_breach" );

	// Turn on color trigger to move allies through door
	trigger_on( "take_back_control_open_door_move", "targetname" );

 	// Wait till breach
	flag_wait( "control_door_breached" );
	self forceUseWeapon( "lunarrifle", "primary" );
}

control_pigeon_thread()
{
	self endon( "death" );
}

control_seagull_thread()
{
	self endon( "death" );
}

take_back_control_ally_spawn_shared( ally_name )
{
	spawner = GetEnt( ally_name, "targetname" );
	spawner thread add_spawn_function( ::take_back_control_ally_spawn_func );
	ai = spawner spawn_ai();
	ai.animname = ally_name;

	return ai;
}

take_back_control_ally_spawn_func()
{
	self endon( "death" );
	self thread maps\nx_lunar_util::lunar_ally_interior_common();

	self thread disable_surprise();
	self thread ally_protect();
}

ally_protect()
{
	/*while( 1 )
	{
		guy = trigger_wait_targetname( "ally_protect" );	
	
		if( guy == self )
		{
			break;
		}
	}*/

	self.ignorerandombulletdamage = true;
	self.ignoresuppression = true;
	self.disableBulletWhizbyReaction = true;
	self disable_pain();
	self.dontavoidplayer = true;
	self pushplayer( true );
}

//*******************************************************************
//                                                                  *
//*******************************************************************

take_back_control_enemy_spawn()
{
	CreateThreatBiasGroup( "control_floor_1_side" );
	CreateThreatBiasGroup( "control_floor_1_main" );
	CreateThreatBiasGroup( "control_floor_1_resupply" );
	// CreateThreatBiasGroup( "control_floor_2" );

	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_control_floor_1" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_control_floor_1_2" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_control_floor_1_3" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_control_floor_1_resupply" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_control_floor_2" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_control_floor_2_resupply" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_control_floor_2_resupply_2" );

	SetThreatBiasAgainstAll( "control_floor_1_main", -3000 );
}

enemy_control_floor_1_side_spawn_func()
{
	self endon( "death" );
	self SetThreatBiasGroup( "control_floor_1_side" );

	self.baseaccuracy = 0.5;

	self thread maps\nx_lunar_util::lunar_enemy_interior_common();

	// Give grenades
	self.grenadeammo = 3;
	self.force_grenade_drop = true;

	self thread c_and_c_ambusher();
}

enemy_control_floor_1_main_spawn_func()
{
	self endon( "death" );
	self SetThreatBiasGroup( "control_floor_1_main" );

	self.baseaccuracy = 0.25;

	self thread maps\nx_lunar_util::lunar_enemy_interior_common( false );

	// Give grenades
	self.grenadeammo = 3;
	self.force_grenade_drop = true;

	self thread c_and_c_ambusher();
}

enemy_control_floor_1_main_scripted_spawn_func()
{
	self endon( "death" );
	self SetThreatBiasGroup( "control_floor_1_main" );

	self.baseaccuracy = 0.25;

	self thread maps\nx_lunar_util::lunar_enemy_interior_common( true );

	// Give grenades
	self.grenadeammo = 3;
	self.force_grenade_drop = true;

	self thread c_and_c_ambusher();
}

enemy_control_floor_1_resupply_spawn_func()
{
	self endon( "death" );
	self SetThreatBiasGroup( "control_floor_1_resupply" );

	self thread maps\nx_lunar_util::lunar_enemy_interior_common( false );

	// Give grenades
	self.grenadeammo = 3;
	self.force_grenade_drop = true;

	self thread c_and_c_ambusher();
}

enemy_control_floor_2_spawn_func()
{
	self endon( "death" );
	// self SetThreatBiasGroup( "control_floor_2" );

	self thread maps\nx_lunar_util::lunar_enemy_interior_common();

	self.goalheight = 64;
	flag_wait( "floor_2_jumping_enabled" );
	self.goalheight = 1024;

	self thread c_and_c_ambusher();
}

c_and_c_ambusher()
{
	self endon( "death" );

	flag_wait( "start_c_and_c_ambush" );

	// Disperse ambushing
	// wait RandomInt( 3 );

	// Pick a random guy
	guys = [];
	guys[0] = level._player;
	//guys[1] = level.hawk;
	//guys[2] = level.eagle;
	//guys[3] = level.pigeon;
	//guys[4] = level.seagull;
	random_guy = random( guys );

	// Get Ai Super Aggressive and Deadly
	self clear_force_color();
	self.maxsightdistsqrd = 4000 * 4000;
	self.favoriteenemy = random_guy;
	self.baseaccuracy = 1.0;
	self.pathrandompercent = 200;
	self SetGoalEntity( random_guy );
	self.goalradius = 400;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

take_back_control_ending_start()
{
	// Start the player and allies
	level.hawk = take_back_control_ally_spawn_shared( "hawk" );
	level.pigeon = take_back_control_ally_spawn_shared( "pigeon" );
	level.seagull = take_back_control_ally_spawn_shared( "seagull" );

	// Teleport starts
	maps\nx_lunar_util::lunar_start( "take_back_control_ending_start", 
									 "take_back_control_ending_eagle_start", 
									 undefined, 
									 "take_back_control_ending_hawk_start", 
									 "take_back_control_ending_pigeon_start", 
									 "take_back_control_ending_seagull_start" );
	
	// Kill falcon
	if( IsAlive( level.falcon ) )
	{
		level.falcon stop_magic_bullet_shield();
		level.falcon kill();
	}

	// Init combat
	maps\nx_lunar_util::lunar_combat_init();

	// FX
	level thread start_lsp_fx();

	// Vision
	thread maps\nx_lunar_fx::fx_init_vision_breached_helmet();

	// Flags
	flag_set( "close_c_and_c_doors" );
}

take_back_control_ending()
{
	// VO
	level thread take_back_control_ending_VO();

	maps\nx_lunar_util::all_triggers_on( "take_back_control_ending_triggers" );

	// Make sure ally protect is on eagle and hawk
	level.eagle thread ally_protect();
	level.eagle thread disable_surprise();
	level.hawk thread ally_protect();
	level.hawk thread disable_surprise();

	// tagTC<hack> - animname is being changed by the breach vignette
	level.eagle.animname = "eagle";
	level.hawk.animname = "hawk";

	// Hawk should never go back to color
	level.hawk thread disable_ai_color();
	level.hawk.old_forceColor = undefined;

	// Open door vignette
	maps\nx_lunar_util::open_lunar_door_vignette( "c_and_c_door_1", true, 0.0, true );

	// Hawk should never go back to color
	level.hawk thread disable_ai_color();
	level.hawk.old_forceColor = undefined;

	level thread maps\nx_lunar_util::open_lunar_door( "c_and_c_door_1", 1.0 );
	level thread maps\nx_lunar_util::open_lunar_door( "c_and_c_door_2", 0.2 );

	// Play the end vignette
	level thread take_back_control_enter_vignette();
	level thread take_back_control_end_vignette();

	flag_set( "c_and_c_doors_open" );
	maps\nx_lunar_util::all_triggers_on( "c_and_c_triggers" );

	// Wait for player to trigger lsp
	control_lsp = GetEnt( "control_lsp", "targetname" );
	control_lsp trigger_on();
	control_lsp sethintstring( &"NX_LUNAR_CONTROL_LSP_HINT" );		
	control_lsp waittill( "trigger" );
	control_lsp trigger_off();

	flag_set( "control_lsp_activated" );

	level thread maps\nx_lunar_util::close_lunar_door( "c_and_c_door_1" );
	level thread maps\nx_lunar_util::close_lunar_door( "c_and_c_door_2" );

	// Clean up on aisle six
	level thread maps\nx_lunar_util::clean_all_enemies();
}

take_back_control_enter_vignette()
{
	flag_wait( "c_and_c_doors_open" );

	wait( 1.0 );

	maps\nx_lunar_anim::end_controls_enter( level.hawk, level.eagle );
}

take_back_control_end_vignette()
{
	flag_wait( "c_and_c_doors_open" );

	// Spawn C and C enemy
    spawner = GetEnt( "end_controls_enemy_body", "targetname" );
	spawner.script_forcespawn = 1;
    spawner thread add_spawn_function( ::c_and_c_enemy_spawn_func );
    enemy_body = spawner spawn_ai();
    enemy_body.animname = "enemy_body";

	// Spawn support guys
    spawner = GetEnt( "end_controls_enemy_body_support", "targetname" );
	spawner.script_forcespawn = 1;
    spawner thread add_spawn_function( ::c_and_c_enemy_support_func );
    enemy_body_support = spawner spawn_ai();

	//Spawn Control Panel model
	end_control_node = getstruct("vignette_lunar_end_controls", "script_noteworthy");
	end_controls_panel = spawn_anim_model("end_controls_panel");
	end_control_node thread anim_loop_solo( end_controls_panel, "end_controls_idle", "stop_idle");
	//end_control_node anim_first_frame_solo( end_controls_panel, "end_controls" );

	// Tell ally to shoot the enemy body
	shoot_enemy_body( enemy_body );

	// Body hit, play kill anim
	maps\nx_lunar_anim::end_controls_enemy_kill( enemy_body );
	enemy_body vignette_actor_kill();
	enemy_body delete();

	// Spawn dead body
	enemy_body = vignette_actor_spawn("end_controls_enemy_body_dead", "enemy_body"); //"value" (kvp), "anim_name"
	maps\nx_lunar_anim::end_controls_enemy_first_frame( enemy_body );

	flag_wait( "control_lsp_activated" );
	//stop the panel idle
	end_control_node notify ("stop_idle");
	// Play end control animations
	maps\nx_lunar_anim::end_controls( enemy_body, level.hawk, level.eagle, end_controls_panel );

	enemy_body vignette_actor_delete();

	// End of level
	nextmission();
}

shoot_enemy_body( enemy_body )
{
	wait( 2.0 );

	MagicBullet( "lunarrifle", level.hawk.origin, enemy_body.origin );
	level.hawk Shoot( 1, enemy_body.origin);
	level.eagle Shoot( 1, enemy_body.origin);
	PlayFX( level._effect[ "charlie_impact" ], enemy_body.origin );
}

c_and_c_enemy_support_func()
{
	self endon( "death" );
}

c_and_c_enemy_spawn_func()
{
	self endon( "death" );
	self thread disable_surprise();
	self thread magic_bullet_shield();
	self.ignoreme = true;
}

take_back_control_ending_VO()
{
	// Turn off battle chatter
	battlechatter_off( "allies" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//*******************************************************************
//                                                                  *
//*******************************************************************

start_lsp_fx()
{
	wait( 5.0 );
	level thread lsp_explosion_1();
	level thread lsp_explosion_2();
}

lsp_explosion_1()
{
	lsp_explosion_1 = GetEnt( "lsp_explosion_1", "targetname" );
	lsp_smoke_1 = GetEnt( "lsp_smoke_1", "targetname" );

	playFX( level._effect[ "lsp_explosion" ], lsp_explosion_1.origin, ( 0, 0, 1 ) );

//	sunIntensity = getDVarFloat ( "r_lightTweakSunLight" );
//	thread darken( 0.5, 0.5, 0.05 );

	wait 1.5;
//	thread brighten( sunIntensity, 1.5, 0.05 );

	wait 1.15;
	playFX( level._effect[ "lsp_ground_dust_200" ], level._player.origin, ( 0, 0, 1 ) );
	playFX( level._effect[ "nx_lunar_falcon_death_dust" ], ( 2334, -3016, -1260 ), ( 0, 0, 1 ) );
	playFX( level._effect[ "nx_lunar_falcon_death_dust" ], ( 2584, -3225, -1270 ), ( 0, 0, 1 ) );
	playFX( level._effect[ "nx_lunar_falcon_death_dust" ], ( 1984, -3182, -1264 ), ( 0, 0, 1 ) );
	playFX( level._effect[ "nx_lunar_falcon_death_dust" ], ( 2014, -3423, -1260 ), ( 0, 0, 1 ) );
	playFX( level._effect[ "nx_lunar_falcon_death_dust" ], ( 2207, -3497, -1275 ), ( 0, 0, 1 ) );
	playFX( level._effect[ "nx_lunar_falcon_death_dust" ], ( 2284, -3423, -1275 ), ( 0, 0, 1 ) );
}

lsp_explosion_2()
{
	lsp_explosion_2 = GetEnt( "lsp_explosion_2", "targetname" );
	lsp_smoke_2 = GetEnt( "lsp_smoke_2", "targetname" );

	PlayFX( level._effect[ "lsp_explosion" ], lsp_explosion_2.origin );
}

//*******************************************************************
//                                                                  *
//*******************************************************************

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

