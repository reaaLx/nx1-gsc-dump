//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_LUNAR, Escape Interior Mission Script						**
//                                                                          **
//    Created: 11/25/2010 - Travis Chen										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_hud_util;
#include maps\_utility_code;
#include maps\_nx_objective_util;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// main threaded from nx_lunar.gsc main
main()
{
	level thread turn_off_storage_module_damage();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

mission_flag_inits()
{
	flag_init( "armory_module" );
	flag_init( "life_support_module" );
	flag_init( "medical_module" );
	flag_init( "living_module" );
	flag_init( "crew_module" );
	flag_init( "crew_hub_ambush" );
	flag_init( "in_crew_airlock" );
	flag_init( "in_exterior_airlock" );
	flag_init( "exterior_vista" );
	flag_init( "medical_vo_complete" );

	flag_init( "ally_door_open_start" );

	flag_init( "introscreen_complete" );
	flag_init( "remove_patch_hint" );
	flag_init( "life_support_door_open" );
	flag_init( "living_door_open" );
	flag_init( "crew_airlock_open" );
	flag_init( "exterior_airlock_open" );
	flag_init( "player_has_weapon" );
	flag_init( "player_has_helmet" );
	flag_init( "player_at_the_armory" );
	flag_init( "vo_armory_done" );
}

escape_interior_door_status_init()
{
	// level thread maps\nx_lunar_util::lunar_door_status( "armory_door", "status_yellow" );
	level thread maps\nx_lunar_util::lunar_door_status( "life_support_door", "status_red" );
	level thread maps\nx_lunar_util::lunar_door_status( "living_door", "status_red" );
	level thread maps\nx_lunar_util::lunar_door_status( "crew_airlock_door_1", "status_green" );
	level thread maps\nx_lunar_util::lunar_door_status( "crew_airlock_door_2", "status_red" );
	level thread maps\nx_lunar_util::lunar_door_status( "crew_hub_door", "status_green" );
	level thread maps\nx_lunar_util::lunar_door_status( "exterior_airlock_door_1", "status_green" );
	level thread maps\nx_lunar_util::lunar_door_status( "exterior_airlock_door_2", "status_red" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

DEBUG_ARMORY_MODULE = false;

armory_module_start()
{
	// Start the player and allies
	maps\nx_lunar_util::lunar_start( "armory_player_start", "armory_eagle_start", "armory_falcon_start" );

	thread maps\nx_lunar_fx::fx_init_vision_alert();

	// Init combat
	maps\nx_lunar_util::lunar_combat_init();

	// Clip before explosion
	breach_explosion_clip_before();
	
	// Play lunar screen binks
	thread maps\nx_lunar_util::lunar_screen_binks();
}

armory_module()
{
	// Armory dialog
	level thread armory_module_VO();

	flag_set( "armory_module" );

   	// Turn on all triggers
	maps\nx_lunar_util::all_triggers_on( "armory_triggers" );

	// Turn on move out trigger
	level thread ally_armory_move_out();

	// Spawn allies
	if( ( !isDefined( level.eagle ) ) && ( !isDefined ( level.falcon ) ) )
	{
		level thread maps\nx_lunar_util::lunar_ally_spawn();
	}
	level thread armory_ally_thread();

	// Armory breach vignette, played at beginning of section
	if( !DEBUG_ARMORY_MODULE )
	{
		level thread ally_armory_breach_vignette();
	}
	else
	{
		level thread armory_breach_explosion();
	}

	// Player Thread
	level thread armory_player_thread();

	// Spawn enemies
	level thread armory_enemy_spawn();

	// Turn on storage module damage
	level thread turn_on_storage_module_damage();
	level thread get_to_the_armory_path_block_off();

	// Door thread
	level thread armory_door_thread();

	// Close the life support door as the player leaves
	flag_wait( "life_support_breach_reach" );
}

ally_armory_move_out()
{
	ally_armory_move_out = GetEnt( "ally_armory_move_out", "targetname" );
	ally_armory_move_out trigger_off();

	waittill_alive_aigroupcleared( "enemy_storage_breachers" );

	ally_armory_move_out trigger_on();
}

//*******************************************************************
//                                                                  *
//*******************************************************************

armory_door_thread()
{
	// Open life support door ( starts open )
	level thread maps\nx_lunar_util::open_lunar_door( "life_support_door", 0.2 );
	
	// Close the life support door as the player leaves
	flag_wait( "storage_close_life_support_door" );

	wait( 3.5 );
	level thread maps\nx_lunar_util::close_lunar_door( "life_support_door" );
}

//*******************************************************************
//                                                                  *
//*******************************************************************

armory_player_thread()
{
	// No unlimited sprint
	setSavedDvar( "player_sprintUnlimited", "0" );
}

//*******************************************************************
//                                                                  *
//*******************************************************************

armory_ally_thread()
{
	level.eagle thread ally_protect();
	level.falcon thread ally_protect();

	flag_wait( "life_support_module" );

	level.eagle thread ally_unprotect();
	level.falcon thread ally_unprotect();
}

ally_protect()
{
	if( IsDefined( self ) )
	{
		self.ignorerandombulletdamage = true;
		self.ignoresuppression = true;
		self.disableBulletWhizbyReaction = true;
		self thread disable_pain();
		self.dontavoidplayer = true;
		self thread disable_surprise();
	}
}

ally_unprotect()
{
	if( IsDefined( self ) )
	{
		self.ignorerandombulletdamage = false;
		self.ignoresuppression = false;
		self.disableBulletWhizbyReaction = false;
		self thread enable_pain();
		self.dontavoidplayer = false;
		self thread enable_surprise();
	}
}

//*******************************************************************
//                                                                  *
//*******************************************************************

armory_enemy_spawn()
{
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_armory_breach" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_armory_breach_2" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_armory_breach_3" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_lsp_hallway_defend" );
}

enemy_storage_spawn_func()
{
	self thread maps\nx_lunar_util::lunar_enemy_interior_common();
	self thread disable_surprise();
}

//*******************************************************************
//                                                                  *
//*******************************************************************

ally_armory_breach_vignette()
{
	// Save the game
	level thread autosave_now();

	// Thread vignette func
	level thread ally_armory_breach_vignette_thread();

	wait( 0.92 );

	// Explosion
	level thread armory_breach_explosion();

	// Slow mo
	level thread armory_breach_slow_motion();

	// Check if we should kill the player
	level thread armory_breach_kill_zone();

	// Jolt the player
	level thread armory_breach_player_jolt();

	// Allow player to go crouch
	//level._player DisableInvulnerability();
	//level._player allowcrouch( true );
}

ally_armory_breach_vignette_thread()
{
	// Play the vignette, create spider in the debug checkpoint case
	if( !IsDefined( level.spider) )
	{
		level.spider = maps\_nx_vignette_util::vignette_actor_spawn("armory_breach_spider", "spider"); //"value" (kvp), "anim_name"
	}

	maps\nx_lunar_anim::armory_breach( level.eagle, level.falcon, level.spider );
	level.spider maps\_nx_vignette_util::vignette_actor_kill();
}

armory_breach_player_jolt()
{
	wait( 0.15 );
	
	// Shell shock
	level thread armory_breach_player_shock();

	// Rumble
	level._player PlayRumbleOnEntity( "artillery_rumble" );

	// FREEZE
	level._player FreezeControls( true );	

	// Slide player	towards the door
	look_at = GetEnt( "armory_look_at", "targetname" );
	vector_out = ( ( level._player.origin + ( 0, 0, 40) ) - look_at.origin );
	vector_in = ( look_at.origin - ( level._player.origin + ( 0, 0, 40) ) );

	base_thrust_out = vectornormalize( vector_out );
	base_thrust_in = vectornormalize( vector_in );
	boost_out = 100;
	boost_in = 150;

	// Slide out
	was_in_armory_box_clip = false;
	if( !flag( "player_in_armory_box_clip" ) )
	{
		level._player thread BeginSliding( base_thrust_out * boost_out, 5, 0.25 );
		wait( 0.7 );
		level._player thread endsliding();
	}
	else
	{
		wait( 0.7 );
		was_in_armory_box_clip = true;
	}

	// Slide in
	if( !flag( "player_in_armory_box_clip" ) )
	{
		level._player thread BeginSliding( base_thrust_in * boost_in, 2, 0.1 );
	}
	else
	{
		// Push player out of clip
		level._player thread BeginSliding( base_thrust_in * boost_in, 5, 0.1 );
	}
	wait( 2.0 );
	level._player thread endsliding();

	// Turn on clip if player is in armory box
	if( was_in_armory_box_clip )
	{
		breach_explosion_clip_after();
	}

	// UNFREEZE
	level._player FreezeControls( false );

}
armory_breach_player_shock()
{
	//level._player shellshock( "estate_bouncingbetty", 3.5 );
	earthquake( 0.4, 0.6, level._player.origin, 2000 );
	wait( 0.6 );
	earthquake( 0.25, 1.0, level._player.origin, 2000 );
	
	level._player.ignoreme = true;
	wait 3.5;
	level._player.ignoreme = false;
}

armory_breach_kill_zone()
{
	// Kill the player if too close to door
	if( flag( "armory_breach_player_kill_zone" ) )
	{
		SetDvar( "ui_deadquote", "NX_LUNAR_FAIL_ARMORY_BREACH" );
		missionFailedWrapper();
	}
}
armory_breach_vol()
{

	level._player setchannelvolumes( "snd_channelvolprio_pain", "nx_lunar_armory_hatch_destroy", 0.4 );

	wait 5.1;

	level._player deactivatechannelvolumes( "snd_channelvolprio_pain", 2 );

}

armory_breach_explosion()
{
	// Play the FX
	exploder( "fx_armory_breach" );	
	level._player playsound ( "nx_lunar_hatch_destroy" );
	thread armory_breach_vol();

	// Change the door status
	level thread maps\nx_lunar_util::lunar_door_status( "armory_door", "status_green" );

	// Clip the explosion crate
	breach_explosion_clip_after();

	wait( 0.2 );

	// Destructable state change, both armory and storage hall
	exploder( 1 );
	exploder( 2 );

	// Open the armory door
	level thread maps\nx_lunar_util::open_lunar_door( "armory_door", 0.1, true );

	// Open storage door
	level thread maps\nx_lunar_util::open_lunar_door( "storage_door_01", 0.1, true );

	//set the new helmet sound type flag
	flag_set( "sfx_int_base_milsuit_depress" );
}

armory_breach_slow_motion()
{	
	// Slow motion
	SetSlowMotion( 1.0, 0.25, 0.2 );

	wait( 1.5 );
	
	// Slow motion
	SetSlowMotion( 0.4, 1.0, 0.2 );	
}


//*******************************************************************
//                                                                  *
//*******************************************************************

breach_explosion_clip_before()
{
	breach_explosion_clip_before = GetEnt( "breach_explosion_clip_before", "targetname" );
	breach_explosion_clip_after = GetEnt( "breach_explosion_clip_after", "targetname" );

	breach_explosion_clip_before Solid();
	breach_explosion_clip_before DisconnectPaths();
	breach_explosion_clip_after NotSolid();
	breach_explosion_clip_after ConnectPaths();
}

breach_explosion_clip_after()
{
	if( !flag( "player_in_armory_box_clip" ) )
	{
		breach_explosion_clip_before = GetEnt( "breach_explosion_clip_before", "targetname" );
		breach_explosion_clip_after = GetEnt( "breach_explosion_clip_after", "targetname" );
	
		breach_explosion_clip_after Solid();
		breach_explosion_clip_after DisconnectPaths();
		breach_explosion_clip_before NotSolid();
		breach_explosion_clip_before ConnectPaths();
	}
}

get_to_the_armory_path_block_off()
{
	path_blocks = GetEntArray( "get_to_the_armory_path_block", "targetname" );
	foreach( path_block in path_blocks )
	{
		path_block ConnectPaths();
		path_block NotSolid();
	}
}

turn_off_storage_module_damage()
{
	damages_clip = GetEntArray( "storage_module_damage_clip", "targetname" );
	foreach( damage_clip in damages_clip )
	{
		damage_clip ConnectPaths();
		damage_clip NotSolid();
	}

	damages = GetEntArray( "storage_module_damage", "targetname" );
	foreach( damage in damages )
	{
		damage hide();
	}
}

turn_on_storage_module_damage()
{
	damages_clip = GetEntArray( "storage_module_damage_clip", "targetname" );
	foreach( damage_clip in damages_clip )
	{
		damage_clip Solid();
		damage_clip DisconnectPaths();
	}

	damages = GetEntArray( "storage_module_damage", "targetname" );
	foreach( damage in damages )
	{
		damage show();
	}
}

//*******************************************************************
//                                                                  *
//*******************************************************************

armory_module_VO()
{
	battlechatter_on( "allies" );

	wait( 4.0 );	

	// We're moving!
	radio_dialogue( "moon_eag_move_06" );

	flag_wait( "player_left_armory" );

	// Tango up hight at our nine!
	radio_dialogue( "moon_eag_int_09" );

	flag_wait( "vo_keep_pushing_cnc" );

	// Keep pushing - we need to get to C&C. 
	radio_dialogue( "moon_eag_int_10" );

	flag_wait( "life_support_breach_reach" );

	battlechatter_off( "allies" );

	// Riggs: Dammit! This way's blocked.
	radio_dialogue( "moon_fal_ext_wayblocked" );

	// Riggs: We dont' have time to clear this debris.
	radio_dialogue( "moon_fal_ext_notime" );

	// Crow: We need to find another way around.
	radio_dialogue( "moon_eag_int_findwayaround" );

	// Crow: Head through life support.
	radio_dialogue( "moon_eag_int_13" );

	flag_wait( "life_support_breach_near" );

	// Crow: Emergency door is sealed
	radio_dialogue( "moon_eag_int_emergencydoor" ); 
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

life_support_module_start()
{
	// Start the player and allies
	maps\nx_lunar_util::lunar_start( "life_support_module_player_start", "life_support_module_eagle_start", "life_support_module_falcon_start" );

	// Init combat
	maps\nx_lunar_util::lunar_combat_init();

	// Turn on storage module damage
	level thread turn_on_storage_module_damage();
	
	// Unblock AI paths
	level thread get_to_the_armory_path_block_off();

	// set default vision set state for this area.
	thread maps\nx_lunar_fx::fx_init_vision_breached();

	// Flag set
	flag_set( "life_support_breach_reach" );
	
	// Play lunar screen binks
	thread maps\nx_lunar_util::lunar_screen_binks();
}

life_support_module()
{
	flag_set( "life_support_module" );

	// Allies don't push player
	level.eagle pushplayer( false );
	level.falcon pushplayer( false );

	// Dialog
	level thread life_support_module_VO();

	// Turn on life support triggers
	maps\nx_lunar_util::all_triggers_off( "armory_triggers" );

	// Open door
	maps\nx_lunar_util::open_lunar_door_vignette( "life_support_door", true, 3.0, undefined );
	level.eagle thread life_support_ignore();
	level thread maps\nx_lunar_util::open_lunar_door( "life_support_door" );
	flag_set( "life_support_door_open" );
	
	// Triggers on	
	maps\nx_lunar_util::all_triggers_on( "life_support_triggers" );
	
	// Start paper exploder
	level thread maps\nx_lunar_util::proximity_paper_exploder();

	// Spawn the enemies
	level thread life_support_enemy_spawn();

	// Start next mission event, medical module
	medical_module();
}

life_support_ignore()
{
	// Should ignore enemies until he has a goal
	self.ignoreall = true;
	self.ignoreme = true;
	self thread ally_protect();	

	wait( 5.25 );

	self.ignoreme = false;
	self.ignoreall = false;
	self thread ally_unprotect();	
}

//*******************************************************************
//                                                                  *
//*******************************************************************

life_support_enemy_spawn()
{
	// Choice spawn, two paths w/ two different spawn outcomes
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_life_support_jumpers" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_life_support" );

	level._cover_traverse_wait_min = 2.0;
    level._cover_traverse_wait_max = 3.0;
}

enemy_life_support_spawn_func()
{
	self thread maps\nx_lunar_util::lunar_enemy_interior_common();
}

//*******************************************************************
//                                                                  *
//*******************************************************************

life_support_module_VO()
{
	flag_wait( "ally_door_open_start" );

	// Overridein 3… 2… 1… 
	radio_dialogue( "moon_eag_int_override" );
	wait( 0.25 );

	flag_wait( "life_support_door_open" );

	battlechatter_on( "allies" );

	// Tangos right…
	radio_dialogue( "moon_eag_int_14" );
	wait( 0.25 );	

	flag_wait( "vo_hes_going_left" );

	// He's going left… Get to high ground Sams!
	//radio_dialogue( "moon_eag_int_15" );

	flag_wait( "vo_push_forward_into_medical" );

	// Push forward into Medical
	radio_dialogue( "moon_eag_int_16" );
}		

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

medical_module()
{
	flag_set( "medical_module" );

	// Save the game
	level thread autosave_now();

	// Triggers on
	maps\nx_lunar_util::all_triggers_on( "medical_triggers" );

	// Spawn the enemies
	level thread medical_enemy_spawn();

	// Wait for all dead
	waittill_aigroupcleared( "enemy_medical" );

	// Save the game
	level thread autosave_now();
}

//*******************************************************************
//                                                                  *
//*******************************************************************

medical_enemy_spawn()
{
	// Choice spawn
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_medical" );
}

enemy_medical_spawn_func()
{
	self thread maps\nx_lunar_util::lunar_enemy_interior_common();
	self.goalradius = 64;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

DEBUG_LIVING_MODULE = false;
living_module_start()
{
	// Start the player and allies
	maps\nx_lunar_util::lunar_start( "living_module_player_start", "living_module_eagle_start", "living_module_falcon_start" );

	// set default vision set state for this area.
	thread maps\nx_lunar_fx::fx_init_vision_breached();

	// Init combat
	maps\nx_lunar_util::lunar_combat_init();
	
	// Play lunar screen binks
	thread maps\nx_lunar_util::lunar_screen_binks();
}

living_module()
{
	flag_set( "living_module" );

	// VO
	level thread living_module_VO();

	// Triggers on
	maps\nx_lunar_util::all_triggers_on( "medical_to_living_triggers" );
  
	// Player
	level._player thread living_module_player_thread();

	// Open door, remove doorway player clip
	maps\nx_lunar_util::open_lunar_door_vignette( "living_door", true, 3.5, undefined, "medical_vo_complete" );
	level thread maps\nx_lunar_util::open_lunar_door( "living_door", 1.0 );
	flag_set( "living_door_open" );

	// Dead crew on floor vignette
	level thread living_hallway_vignette();

	// tagTC<note> - removed blocking clip, animation fixed guy going in first
	// Remove player clip blocking player from entering before AI
	// level thread remove_living_door_player_clip();

	// Triggers
	maps\nx_lunar_util::all_triggers_on( "living_triggers" );
	
	trigger_living_move_up = GetEntArray( "trigger_living_move_up", "targetname" );
	foreach( trigger in trigger_living_move_up )
	{ 
		trigger trigger_off();
	}	

	// Allies
	level.eagle thread living_module_ally_behaivior();
	level.falcon thread living_module_ally_behaivior();

	// Spawn enemies
	level thread living_enemy_spawn();

	// Move to next checkpoint
	flag_wait( "move_allies_to_airlock" );
}

remove_living_door_player_clip()
{
	wait( 3.0 );
	player_clip = GetEnt( "living_door_player_clip", "targetname" );
	
	player_clip Delete();
}

wait_for_living_enemies_cleared()
{
	waittill_aigroupcleared( "enemy_living_floor_1" );
	waittill_aigroupcleared( "enemy_living_floor_1_mover" );
	waittill_aigroupcleared( "enemy_living_floor_2" );	
}

//*******************************************************************
//                                                                  *
//*******************************************************************

living_hallway_vignette()
{
	level thread maps\nx_lunar_anim::scientist_dead1_spawn();
}

//*******************************************************************
//                                                                  *
//*******************************************************************

living_module_ally_behaivior()
{
	flag_wait( "allies_in_living" );	

	self thread disable_surprise();

	self.ignoreme = true;
	self.ignoreall = true;
	self pushplayer( true );

	self waittill( "goal" );

	wait( 2.0 );

	self pushplayer( false );
	self.ignoreme = false;
	self.ignoreall = false;
	self.baseaccuracy = 0.1;

	self thread living_module_ally_behaivior_reset();

	flag_wait( "player_in_flank" );

	self.baseaccuracy = 0.75;

}

living_module_ally_behaivior_reset()
{
	flag_wait( "exterior_vista" );

	self thread enable_surprise();
	self pushplayer( true );
	self.baseaccuracy = 1.0;
}

//*******************************************************************
//                                                                  *
//*******************************************************************

living_enemy_spawn()
{
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_living_floor_1" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_living_floor_1_support" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_living_floor_1_support_2" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_living_floor_1_support_3" );
}

enemy_living_floor_1_spawn_func()
{
	self endon( "death" );

	self thread maps\nx_lunar_util::lunar_enemy_interior_common();
	self thread disable_surprise();

	flag_wait( "player_in_flank" );
	
	self thread enable_surprise();

	// Don't let enemies go upstairs
	self thread check_jumper();

	// Give grenades
	self.grenadeammo = 3;
	self.force_grenade_drop = true;
}

enemy_living_floor_1_hidden_spawn_func()
{
	self.ignoreme = true;
	self thread enemy_living_floor_1_spawn_func();
}

enemy_living_floor_1_mover_spawn_func()
{
	self endon( "death" );

	self thread maps\nx_lunar_util::lunar_enemy_interior_common();
	self thread disable_surprise();
	self.goalradius = 128;

	flag_wait( "player_in_flank" );
	
	self thread enable_surprise();

	// Don't let enemies go upstairs
	self thread check_jumper();

	// Give grenades
	self.grenadeammo = 3;
	self.force_grenade_drop = true;
}

enemy_living_floor_2_spawn_func()
{
	self endon( "death" );

	self thread maps\nx_lunar_util::lunar_enemy_interior_common();

	// Don't let enemies go downstairs
	self thread check_jumper();

	// Give grenades
	self.grenadeammo = 3;
	self.force_grenade_drop = true;
}

//*******************************************************************
//                                                                  *
//*******************************************************************

living_module_player_thread()
{
	// Check danger zones
	self thread maps\nx_lunar_util::player_danger_zone();
	self thread maps\nx_lunar_util::player_flank_zone();
	
	flag_wait( "exterior_vista" );

	self notify( "end_danger_zone" );
	self notify( "end_flank_zone" );
}

//*******************************************************************
//                                                                  *
//*******************************************************************

living_module_VO()
{
	battlechatter_off( "allies" );

	// They're down 
	radio_dialogue( "moon_eag_kill_low_03" );

	wait( 1.0 );

	// Explosion occurs next door.
	level thread maps\nx_lunar_get_to_the_armory::distant_breach_effects( .4, 2);
	level thread maps\nx_lunar_util::lunar_door_status( "living_door", "status_green" );

	wait( 1.0 );

	// Rigg: That came from the living quarters!
	radio_dialogue( "moon_fal_ext_camefrom" );

	// Crow: That sounded bad. Let's get this door open.
	radio_dialogue( "moon_eag_int_soundbad" );

	flag_set( "medical_vo_complete" );
	flag_wait( "ally_door_open_start" );

	// On my mark. 3… 2… 1…
	radio_dialogue( "moon_eag_int_onmy" );

	level thread living_vo_keep_moving();

	// Look alert.
	// radio_dialogue( "moon_eag_livhal_01" );

	flag_wait( "vo_ambush_right" );

	// Ambush! Right!
	radio_dialogue( "moon_eag_livhal_02" );

	battlechatter_on( "allies" );

	// Down the hallway, take them out!
	radio_dialogue( "moon_eag_int_22" );

	wait( 3.0 );

	// Walker! Keep moving!
	radio_dialogue( "moon_eag_move_01" );

	// Wait for everybody dead
	wait_for_living_enemies_cleared();
	
	trigger_living_move_up = GetEntArray( "trigger_living_move_up", "targetname" );
	foreach( trigger in trigger_living_move_up )
	{ 
		trigger trigger_on();
	}		

	// That's it!
	radio_dialogue( "moon_eag_kill_yell_04" );
	
	wait( 0.5 );

	// Head upstairs!
	radio_dialogue( "moon_eag_int_21" );
}

living_vo_keep_moving()
{
 	wait( 0.5 );

	// Look at dead body
	look_target = GetEnt( "living_look_at_dead_crew", "targetname" );
	SetSavedDvar( "ai_lookatblendvalue", 0.2 );
	level.eagle SetLookAtEntity( look_target );

	wait( 1.0 );

	// Shit... Nothing we can do. Keep moving. 
	radio_dialogue( "moon_eag_int_shitnothing" );

	// Stop look at
	level.eagle StopLookAt( 120 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

exterior_vista_start()
{
	// Start the player and allies
	maps\nx_lunar_util::lunar_start( "exterior_vista_player_start", "exterior_vista_eagle_start", "exterior_vista_falcon_start" );

	// set default vision set state for this area.
	thread maps\nx_lunar_fx::fx_init_vision_breached();

	// Init combat
	maps\nx_lunar_util::lunar_combat_init();
	
	// Play lunar screen binks
	thread maps\nx_lunar_util::lunar_screen_binks();
}

exterior_vista()
{
	flag_set( "exterior_vista" );

	maps\nx_lunar_util::all_triggers_off( "living_triggers" );
	maps\nx_lunar_util::all_triggers_on( "exterior_vista_triggers" );

	exterior_vista_jump_down = GetEnt( "exterior_vista_jump_down", "targetname" );
	exterior_vista_jump_down trigger_off();
	
	// Remove the player block
	exterior_vista_player_block = GetEnt( "exterior_vista_player_block", "targetname" );
	exterior_vista_player_block delete();

	// VO
	level thread exterior_vista_VO();

	// Steam
	level thread exterior_vista_steam();

	flag_wait( "exterior_vista_complete" );
	
	// Stop the lunar screen bink playback
	StopCinematicInGame();

	// tagTC<note> - Change to exterior vision set, taken from crew hub
	thread maps\nx_lunar_fx::fx_crew_module_exit_vision_change();
}

exterior_vista_VO()
{
	//flag_wait( "vo_living_way_out" );

	// Crow: We need a way out.
	//radio_dialogue( "moon_eag_ext_needwayout" );

	flag_wait( "vo_living_come_on" );

	flag_set( "music_player_arrived_at_airlock" );

	// Crow: Come on. We can get outside through here.
	radio_dialogue( "moon_eag_ext_getouthere" );
}

exterior_vista_steam()
{
	exterior_vista_steam = GetEntArray( "exterior_vista_steam", "targetname" );
	foreach( script_origin in exterior_vista_steam )
	{
		forward = AnglesToForward( script_origin.angles );
		up = AnglesToUp( script_origin.angles );
		playFX( level._effect[ "exterior_vista_steam" ], script_origin.origin, forward, up );	
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

check_jumper()
{
	if( IsDefined( self.script_parameters ) && self.script_parameters == "jumper" )
	{
		self.goalradius = 0;
		self.goalheight = 512;
	}
	else
	{
		self.goalheight = 64;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*

DEBUG_CREW_MODULE = false;
crew_module_start()
{
	// Start the player and allies
	maps\nx_lunar_util::lunar_start( "crew_module_player_start", "crew_module_eagle_start", "crew_module_falcon_start" );

	// set default vision set state for this area.
	thread maps\nx_lunar_fx::fx_init_vision_breached();

	// Init combat
	maps\nx_lunar_util::lunar_combat_init();
	
	// Play lunar screen binks
	thread maps\nx_lunar_util::lunar_screen_binks();
}

crew_module()
{
	// VO
	level thread crew_module_VO();

	flag_set( "crew_module" );

	//DR: eventually, this needs to move to the point where you approach the
	//crew HUB airlock door (the first one).  For now, just putting here, since there
	//is no hook for the approaching of the door.
	//DR:3/4/2011 - I believe this is fixed now, gonna remove
	flag_set( "music_player_arrived_at_airlock" );	
	//DR: end comments	

	// Cycle airlock
	crew_airlock_cycle();

	// Crew triggers
	maps\nx_lunar_util::all_triggers_on( "crew_triggers" );

	// transition to the alert vision set in the crew_module
	thread maps\nx_lunar_fx::fx_crew_module_enter_vision_change();

	// Player thread
	level._player thread crew_module_player_thread();

	// Ally thread
	level thread crew_module_ally_behaivior();

	// Save the game
	level thread autosave_now();	

	// Get the move allies trigger, turn it off
	move_allies_trigger = GetEnt( "move_allies_to_exterior_airlock", "targetname" );
	move_allies_trigger trigger_off(); 

	// Crew module enemy spawn
	level thread crew_module_enemy_spawn();

	// Start glass break logic
	level thread maps\nx_lunar_util::proximity_glass_break( "hydro_break_glass" );

	// Airlock sequence
	worker = GetEnt( "airlock_door_worker", "targetname" );
	if( IsDefined( worker ) )
	{
		worker thread crew_module_airlock_death_vignette();
	}

	// Wait for bottom floor clear
	waittill_aigroupcount( "enemy_crew_floor_1", 2 );

	// Ambush remaining enemies
	flag_set( "crew_hub_ambush" );

	// Move to next checkpoint
	move_allies_trigger trigger_on();
	flag_wait( "move_allies_to_exterior_airlock" );

	// Cycle Exterior Airlock
	exterior_airlock_cycle();

	// transition to the exterior vision set
	thread maps\nx_lunar_fx::fx_crew_module_exit_vision_change();
}

//*******************************************************************
//                                                                  *
//*******************************************************************

crew_airlock_cycle()
{
	// Airlock sequence
	if( !DEBUG_CREW_MODULE )
	{
		// Open door first door
		maps\nx_lunar_util::open_lunar_door_vignette( "crew_airlock_door_1", true, 0, undefined );
		level thread maps\nx_lunar_util::open_lunar_door( "crew_airlock_door_1" );
	
		// Crew airlock triggers
		maps\nx_lunar_util::all_triggers_on( "crew_airlock_triggers" );

		// Wait till both allies enter
		wait_till_airlock_trigger( "all_in_crew_airlock" );

		// Close the first door
		maps\nx_lunar_util::close_lunar_door( "crew_airlock_door_1" );

		// In crew airlock
		flag_set( "in_crew_airlock" );

		level thread maps\nx_lunar_util::lunar_door_status( "crew_airlock_door_1", "status_yellow" );
		level thread maps\nx_lunar_util::lunar_door_status( "crew_airlock_door_2", "status_yellow" );

		thread audio_set_crew_amb();

		// Do the airlock cycle
		maps\nx_lunar_util::airlock_vignette( "crew_airlock_door_1", "crew_airlock_door_2", "moon_pres" );
	}
	else
	{
		level thread maps\nx_lunar_util::open_lunar_door( "crew_airlock_door_1", 0.5 );
		level thread maps\nx_lunar_util::open_lunar_door( "crew_airlock_door_2", 0.5 );
	}

	flag_set( "crew_airlock_open" );
	level thread maps\nx_lunar_util::lunar_door_status( "crew_airlock_door_1", "status_red" );
	level thread maps\nx_lunar_util::lunar_door_status( "crew_airlock_door_2", "status_green" );

	// Enable color on eagle / falcon
	level.eagle thread airlock_color_enable();
	level.falcon thread airlock_color_enable();

	//setting sfx helmet state flags to proper sounding state
	flag_set( "sfx_int_base_milsuit_press2" );  //(after going through airlock to repressurize)
}

audio_set_crew_amb()
{

	wait 2;
	SetSavedDvar( "cg_minBreathingLevel", "4" );
	thread maps\_utility::set_ambient( "nx_lunar_crew" );

}

exterior_airlock_cycle()
{
	// Open door first door
	maps\nx_lunar_util::open_lunar_door_vignette( "exterior_airlock_door_1", true, 3.2, undefined );
	level thread maps\nx_lunar_util::open_lunar_door( "exterior_airlock_door_1" );

	// Crew airlock triggers
	maps\nx_lunar_util::all_triggers_on( "exterior_airlock_triggers" );

	// Wait till both allies enter
	wait_till_airlock_trigger( "all_in_exterior_airlock" );

	// Close the first door
	maps\nx_lunar_util::close_lunar_door( "exterior_airlock_door_1" );

	// In exterior airlock
	flag_set( "in_exterior_airlock" );

	// Depressurization vapor FX
	level thread airlock_depressurize_vapor_effects();
	level thread maps\nx_lunar_util::lunar_door_status( "exterior_airlock_door_1", "status_yellow" );
	level thread maps\nx_lunar_util::lunar_door_status( "exterior_airlock_door_2", "status_yellow" );

	// Do the airlock cycle
	thread audio_exterior_amb();
	maps\nx_lunar_util::airlock_vignette( "exterior_airlock_door_1", "exterior_airlock_door_2", "moon" );
 	flag_set( "exterior_airlock_open" );
	level thread maps\nx_lunar_util::lunar_door_status( "exterior_airlock_door_1", "status_red" );
	level thread maps\nx_lunar_util::lunar_door_status( "exterior_airlock_door_2", "status_green" );

	// Enable color on eagle / falcon
	level.eagle thread airlock_color_enable();
	level.falcon thread airlock_color_enable();

	// transition to the exterior vision set
	thread maps\nx_lunar_fx::fx_crew_module_exit_vision_change();

}

audio_exterior_amb()
{

	wait 0.5;
	SetSavedDvar( "cg_minBreathingLevel", "0" );
	thread maps\_utility::set_ambient( "nx_lunar_int" );

}

//*******************************************************************
//                                                                  *
//*******************************************************************

wait_till_airlock_trigger( trigger_name )
{
	airlock_trigger = GetEnt( trigger_name, "targetname" );

	eagle = false;
	falcon = false;
	player = false;

	// Wait for eagle and falcon
	while( 1 )
	{
		airlock_trigger waittill( "trigger", other );
 
		if( other == level.eagle )
		{	
			eagle = true;
			level.eagle thread airlock_color_disable();
		}

		if( other == level.falcon )
		{
			falcon = true;
			level.falcon thread airlock_color_disable();
		}

		if( eagle && falcon )
		{
			break;
		}
	}
	
	// Wait for player
	while( 1 )
	{
		airlock_trigger waittill( "trigger", other );

		if( IsPlayer( other ) )
		{
			break;
		}
	}

	// transition to the exterior vision set
	thread maps\nx_lunar_fx::fx_crew_module_exit_vision_change();
}

airlock_color_disable()
{
	self waittill( "goal" );
	self disable_ai_color();
}

airlock_color_enable()
{
	self enable_ai_color();
}

//*******************************************************************
//                                                                  *
//*******************************************************************

crew_module_ally_behaivior()
{
	old_falcon_goalheight = level.falcon.goalheight;
	old_eagle_goalheight = level.eagle.goalheight;
	level.falcon.goalheight = 64;
	level.eagle.goalheight = 64;

	level.eagle thread ally_protect();
	level.falcon thread ally_protect();

	flag_wait( "exterior_airlock_open" );

	if ( IsDefined( old_falcon_goalheight ) )
	{
		level.falcon.goalheight = old_falcon_goalheight;
	}
	if ( IsDefined( old_eagle_goalheight ) )
	{
		level.eagle.goalheight = old_eagle_goalheight;
	}

	level.eagle thread ally_unprotect();
	level.falcon thread ally_unprotect();
}

//*******************************************************************
//                                                                  *
//*******************************************************************

crew_module_enemy_spawn()
{
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_crew" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_crew_2" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_crew_3" );
	maps\nx_lunar_util::trigger_choice_spawn( "choice_spawn_crew_4" );
}

enemy_hydro_spawn_func()
{
	self endon( "death" );

	self thread maps\nx_lunar_util::lunar_enemy_interior_common( false );

	self thread check_jumper();
	self thread disable_surprise();
}

enemy_crew_floor_1_spawn_func()
{
	self endon( "death" );

	self thread maps\nx_lunar_util::lunar_enemy_interior_common( false );

	// Don't let enemies go upstairs
	self thread check_jumper();

	// Lower enemy accuracy until player leaves hydroponics
	old_accuracy = self.baseaccuracy;
	self.baseaccuracy = 0.05;	

	// Give grenades
	self.grenadeammo = 3;
	self.force_grenade_drop = true;

	flag_wait( "player_left_hydroponics" );

	self.baseaccuracy = old_accuracy;

	flag_wait( "crew_hub_ambush" );

	self thread set_deadly_tracking_ai();
}

enemy_crew_floor_2_spawn_func()
{
	self endon( "death" );

	self thread maps\nx_lunar_util::lunar_enemy_interior_common( false );

	// Don't let enemies go downstairs
	self thread check_jumper();

	// Lower enemy accuracy until player leaves hydroponics
	old_accuracy = self.baseaccuracy;
	self.baseaccuracy = 0.05;

	// Give grenades
	self.grenadeammo = 3;
	self.force_grenade_drop = true;

	flag_wait( "player_left_hydroponics" );

	self.baseaccuracy = old_accuracy;

	flag_wait( "crew_hub_ambush" );

	self thread set_deadly_tracking_ai();
}

// tagTC<TEMP> - remove once daryl checks in the utility
set_deadly_tracking_ai()
{
    // Get Ai Super Aggressive and Deadly
    enemy = self;
    enemy clear_force_color();
    enemy.maxsightdistsqrd = 8192 * 8192;
    enemy.favoriteenemy = level._player;
    enemy.baseaccuracy = 1.0;
    enemy.pathrandompercent = 200;
    enemy SetGoalEntity( level._player );
    enemy.goalradius = 400;
}

//*******************************************************************
//                                                                  *
//*******************************************************************

crew_module_player_thread()
{
	CreateThreatBiasGroup( "player" );
	self thread maps\nx_lunar_util::player_danger_zone();
	self thread maps\nx_lunar_util::end_danger_zone();
}

//*******************************************************************
//                                                                  *
//*******************************************************************

crew_module_airlock_death_vignette()
{
	// Wait till both allies enter
	flag_wait( "player_entered_exterior_airlock" );
	worker_spawner = self;	
	
	// Spawn worker
	worker = worker_spawner spawn_ai();
	worker.animname = "worker";

	worker thread crew_module_airlock_death_vignette_bullets();
	worker thread crew_module_airlock_death_vignette_fx();

	// Get vignette origin and play anim
	airlock_death_start_node = GetStruct( "airlock_death_start_node", "targetname" );
	airlock_death_start_node anim_single_solo( worker, "airlock_door_death" );

	if( !IsAlive( worker ) )
	{
		return;
	}

	worker.allowDeath = true;
	worker.a.nodeath = true;
	worker animmode( "nophysics" );
	wait 0.05;

	if ( isalive( worker ) )
	{
		worker kill();	
	}
    
}

crew_module_airlock_death_vignette_fx()
{
	// Footsteps.
	wait 5.5;
	tagPos = self getTagOrigin( "J_Ball_RI" );
	playFX( level._effect[ "footdust_small" ], tagPos + ( 4, 10, 0 ), ( 0, 0, 1 ) );

	wait 0.9;
	tagPos = self getTagOrigin( "J_Ball_LE" );
	playFX( level._effect[ "footdust_small" ], tagPos + ( 4, 10, 0 ), ( 0, 0, 1 ) );

	wait 0.9;
	tagPos = self getTagOrigin( "J_Ball_RI" );
	playFX( level._effect[ "footdust_small" ], tagPos + ( 4, 10, 0 ), ( 0, 0, 1 ) );

	// Hit.
	wait 0.9;
	tagPos = self getTagOrigin( "tag_eye" );
	playFX( level._effect[ "nx_lunar_falcon_death_blood_hit" ], tagPos, ( -1, 0, 0) );
	playFXOnTag( level._effect[ "nx_lunar_crew_airlock_blood_squirt"], self, "tag_eye" );

	// Collapse dust.
	wait 2.1;
	tagPos = self getTagOrigin( "J_SpineUpper" );
	playFX( level._effect[ "nx_lunar_crew_airlock_impact_large" ], tagPos + ( 0, 14, -10) );

	stopFXOnTag( level._effect[ "nx_lunar_crew_airlock_blood_squirt"], self, "tag_eye" );
}

crew_module_airlock_death_vignette_bullets()
{
	worker = self;
	airlock_shot_source_one = GetEnt( "airlock_to_exterior_death_shot_one", "script_noteworthy" );
	airlock_shot_source_two = GetEnt( "airlock_to_exterior_death_shot_two", "script_noteworthy" );
	airlock_shot_source_one_target_1 = GetEnt( "airlock_to_exterior_death_shot_one_target_1", "script_noteworthy" );
	airlock_shot_source_one_target_2 = GetEnt( "airlock_to_exterior_death_shot_one_target_2", "script_noteworthy" );
	airlock_shot_source_one_target_3 = GetEnt( "airlock_to_exterior_death_shot_one_target_3", "script_noteworthy" );

	worker thread maps\nx_lunar_util::lunar_headshot_monitor();

	wait( 0.5 );
	MagicBullet( "lunarrifle_silent", airlock_shot_source_one.origin, airlock_shot_source_one_target_1.origin );
	wait( 0.25 );
	MagicBullet( "lunarrifle_silent", airlock_shot_source_one.origin, airlock_shot_source_one_target_1.origin );
	wait( 0.25 );
	MagicBullet( "lunarrifle_silent", airlock_shot_source_one.origin, airlock_shot_source_one_target_1.origin );
	wait( 1.0 );
	MagicBullet( "lunarrifle_silent", airlock_shot_source_one.origin, airlock_shot_source_one_target_2.origin );
	wait( 0.5 );
	MagicBullet( "lunarrifle_silent", airlock_shot_source_one.origin, airlock_shot_source_one_target_3.origin );
	wait( 1.0 );
	MagicBullet( "lunarrifle_silent", airlock_shot_source_one.origin, airlock_shot_source_one_target_1.origin );
	wait( 0.25 );
	MagicBullet( "lunarrifle_silent", airlock_shot_source_one.origin, airlock_shot_source_one_target_1.origin );
	wait( 0.25 );
	MagicBullet( "lunarrifle_silent", airlock_shot_source_one.origin, airlock_shot_source_one_target_3.origin );
	wait( 0.25 );
	MagicBullet( "lunarrifle_silent", airlock_shot_source_one.origin, airlock_shot_source_one_target_1.origin );
	wait( 0.25 );
	MagicBullet( "lunarrifle_silent", airlock_shot_source_one.origin, airlock_shot_source_one_target_2.origin );
	wait( 0.5 );
	MagicBullet( "lunarrifle_silent", airlock_shot_source_one.origin, airlock_shot_source_one_target_3.origin );
	wait( 1.0 );
	MagicBullet( "lunarrifle_silent", airlock_shot_source_one.origin, airlock_shot_source_one_target_1.origin );
	wait( 0.25 );
	MagicBullet( "lunarrifle_silent", airlock_shot_source_one.origin, airlock_shot_source_one_target_1.origin );
	wait( 0.25 );
	MagicBullet( "lunarrifle_silent", airlock_shot_source_one.origin, airlock_shot_source_one_target_2.origin );
	
	wait( 2.25 );

	// Dialog: Shit...
	level.eagle thread radio_dialogue( "moon_eag_ext_03" );

	wait( 2.0 );

	// 11.25 seconds to this point
	MagicBullet( "lunarrifle_silent", airlock_shot_source_two.origin, worker GetTagOrigin ("TAG_EYE") );
}

airlock_depressurize_vapor_effects()
{
	// Deressurization vapor FX
	exploder( "fx_airlock_exterior_depressurize" );
	
	wait 6;

	// Stop depressurization vapor FX
	stop_exploder( "fx_airlock_exterior_depressurize" );
}

crew_module_VO()
{
	battlechatter_off( "allies" );
	
	// Crew commons ahead… still has pressure. Riggs, cycle the airlock. 
	radio_dialogue( "moon_eag_int_24" );
	
	//wait( 2.0 );

	// This is Vandenberg - any Combat Group remaining?
	//radio_dialogue( "moon_hawk_int_01" );

	// Good to hear your voice, sir. It's just me, Walker and Riggs… what's the plan?
	//radio_dialogue( "moon_eag_int_29" );

	// We need to retake C&C. Rally point at the rover bay!
	//radio_dialogue( "moon_hawk_int_02" );

	// We're on our way.
	//radio_dialogue( "moon_eag_int_30" );

	// Copy that, make it quick.
	//radio_dialogue( "moon_hawk_int_07" );

	flag_wait( "crew_airlock_open" );
	wait( 1.0 );

	battlechatter_on( "allies" );

	// Heading through hydroponics…
	radio_dialogue( "moon_eag_int_25" );

	// Check if enemies are down in hydro
	level thread hydro_VO_thread();

	flag_wait( "vo_crew_death_trap" );

	// Walker get to cover!
	radio_dialogue( "moon_eag_hub_02" );

	// Tangos below, let’s work our way around
	radio_dialogue( "moon_eag_hub_03" );

	// Check if player is still in death trap
	level thread push_forward_VO_thread();
	level thread get_down_here_VO_thread();

	// Moving downstairs.
	//radio_dialogue( "moon_eag_hub_04" );

	// He's down!
	waittill_aigroupcount( "enemy_crew_floor_1", 4 );
	radio_dialogue( "moon_eag_kill_yell_01" );

	flag_wait( "move_allies_to_exterior_airlock" );

	// That's a kill!
	waittill_aigroupcount( "enemy_crew_floor_1", 3 );
	radio_dialogue( "moon_eag_kill_yell_02" );

	// They're down!
	waittill_aigroupcleared( "enemy_crew_floor_1" );
	radio_dialogue( "moon_eag_kill_yell_03" );

	// Push forward to the airlock.
	radio_dialogue( "moon_eag_hub_06" );

	flag_wait( "ally_door_open_start" );

	// Ok, we're headin outside. 
	radio_dialogue( "moon_eag_int_27" );	

	// Riggs, cycle it!
	radio_dialogue( "moon_eag_int_28" );
}

get_down_here_VO_thread()
{
	flag_wait( "vo_crew_moving_downstairs" );

	// Moving downstairs.
	radio_dialogue( "moon_eag_hub_04" );
	wait( 8.0 );

	flag_wait( "allies_downstairs_crew" );

	if( flag( "player_still_upstairs_crew" ) ) 
	{
		// Walker, get down here.
		radio_dialogue( "moon_eag_hub_05" );
	}
}

hydro_VO_thread()
{
	waittill_aigroupcleared( "enemy_hydro" );

	// OK - move forward…
	radio_dialogue( "moon_eag_move_08" );
}

push_forward_VO_thread()
{
	flag_wait( "vo_crew_push_forward" );

	if( flag( "player_still_in_crew_hall" ) )
	{
		// Walker! Keep moving!
		radio_dialogue( "moon_eag_move_01" );	
	}
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

*/
