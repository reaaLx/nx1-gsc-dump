//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  nx_hithard_parachutee.gsc					   				**
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

CONST_MPHCONVERSION = 17.6;

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
	// "Parachute"		
	flag_init( "flag_vnode_parasecure_parachute_player_start" );	
	flag_init( "flag_parasecure_parachute_landed_player" );	
	flag_init( "flag_parasecure_parachute_oob" );
	flag_init( "flag_hint_parachute_falling_behind" );
	flag_init( "flag_node_hint_right" );	
	flag_init( "flag_node_hint_avoid_smoke" );	
	flag_init( "flag_node_hint_left" );	
	flag_init( "flag_parasecure_library_enemies_spawn" );	
	flag_init( "flag_origin_anim_parachute_land_ally_01" );
	flag_init( "flag_origin_anim_parachute_land_ally_02" );			
	flag_init( "flag_parachute_landed_ally_01" );
	flag_init( "flag_parachute_landed_ally_02" );
	flag_init( "flag_parachute_hurt_smoke" );		
	flag_init( "flag_parachute_objective_failed" );
	flag_init( "flag_building2_slow_fall" );
	flag_init( "flag_creating_enemy_UGVs" );
	
	// Parachute buffeting / explosion (building 3)
	flag_init( "flag_parachute_building3_explosion_left" );	
	flag_init( "flag_parachute_building3_explosion_right" );
	
	// Allow rubber banding checks
	flag_init( "flag_parachute_player_rb_fail_allow" );	

	// LZ display Control
	flag_init( "flag_turn_on_lz" );

	// Skybridge
	flag_init( "flag_skybridge_exp_1" );
	flag_init( "flag_skybridge_exp_2" );

	// Enemy VTOL plane for rooftop section
	flag_init( "flag_vtol_flyin_go" );

	thread audionodesparachute();
}

audionodesparachute()
{

	
	siren4 = spawn( "sound_emitter", ( 11966, -10786, -76 ) );
	siren3 = spawn( "sound_emitter", ( 6677, -17073, -76 ) );
	siren2 = spawn( "sound_emitter", ( 17000, -19036, 113 ) );
	siren2 PlaySound( "hithard_moving_siren2" ); //play sound on ent
	siren3 PlayloopSound( "hithard_moving_siren3" ); //play sound on ent
	siren4 PlayloopSound( "hithard_moving_siren4" ); //play sound on ent
	siren2 moveto( ( 16982, -10960, 113 ), 3.0, .5, .5 ); 
	streetfight = spawn( "sound_emitter", ( 6764, -14800, -34 ) );
	streetfight PlayloopSound( "hithard_street_battle" ); //play sound on ent
	wait 5;
	bomber = spawn( "sound_emitter", ( 17010, -19066, 66 ) ); //spawn ent
	bomber PlaySound( "hithard_moving_siren" ); //play sound on ent
	wait 15;
	siren2 stopsounds();
	bomber stopsounds();
	wait 0.1;
	siren2 delete();
	bomber delete();
        wait 15;
        streetfight stopsounds();
	siren4 stopsounds();
	siren3 stopsounds();
        wait 0.1;
        streetfight delete();
	siren3 delete();
	siren4 delete();

}

// Objective specific add_hint_string() calls
hint_string_inits()
{	
	// Parachute hints		
	add_hint_string( "hint_parachute_smoke", &"NX_HITHARD_PARACHUTE_HINT_SMOKE", ::hint_parachute_smoke );
	if( level._ps3 || level._xenon )
	{
		add_hint_string( "hint_parachute_left", &"NX_HITHARD_PARACHUTE_HINT_TURN_LEFT", ::hint_will_timeout );
		add_hint_string( "hint_parachute_flare", &"NX_HITHARD_PARACHUTE_HINT_FLARE", ::hint_will_timeout );
	}
	else
	{
		add_hint_string( "hint_parachute_left", &"NX_HITHARD_PARACHUTE_HINT_TURN_LEFT_PC", ::hint_will_timeout );
		add_hint_string( "hint_parachute_flare", &"NX_HITHARD_PARACHUTE_HINT_FLARE_PC", ::hint_will_timeout );
	}
	add_hint_string( "hint_parachute_right", &"NX_HITHARD_PARACHUTE_HINT_TURN_RIGHT", ::hint_will_timeout );
	add_hint_string( "hint_parachute_falling_behind", &"NX_HITHARD_PARACHUTE_HINT_FALLING_BEHIND", ::hint_parachute_falling_behind );
}

hint_will_timeout()
{
	return false;
}

//*******************************************************************
//                                                                  *
// 	HINT FUNCTIONS			                                    	*
//                                                                  *
//*******************************************************************
 
// PARACHUTE: Turn left instruction --> LT
hint_parachute_smoke()
{		
	return !flag( "flag_parachute_hurt_smoke" );
}

// PARACHUTE: Turn left instruction --> LT
hint_parachute_left()
{		
	return flag( "_chute.gsc_flag_LT_pressed" ) || flag( "_chute.gsc_flag_RT_pressed") || flag( "flag_parachute_objective_failed" );
}

// PARACHUTE: Turn right instruction --> RT
hint_parachute_right()
{		
	return flag( "_chute.gsc_flag_RT_pressed" ) || flag( "flag_parachute_objective_failed" );
}

// PARACHUTE: Flare (slow down) instruction --> LT & RT
hint_parachute_flare()
{			
	return (flag( "_chute.gsc_flag_LT_pressed" ) && flag( "_chute.gsc_flag_RT_pressed" )) || flag( "flag_parachute_objective_failed" );
}

// PARACHUTE: Player is too far from squad
hint_parachute_falling_behind()
{		
	return !flag( "flag_hint_parachute_falling_behind" ) || flag( "flag_parachute_objective_failed" );	
}

//***************************************************************************************************************************************************************
//                                                                  																							*
// 	MAINS				                                               																							*
//                                                                  																							*
//***************************************************************************************************************************************************************

// Main parachute objective
main_osprey()
{																
	//playing ambient
	level._player setchannelvolumes( "snd_channelvolprio_pain", "nx_hh_osprey_intro", 0.01 );

	//music cue for intro - set a flag
	flag_set( "music_osprey_intro" );
	
	// Intro Dialog
	level thread maps\nx_hithard_util::intro_dialog();

	level waittill( "introscreen_complete" );

	thread audio_play_osprey_intro();
	hide_intro_ai_names();	

	// set vision and fog
	thread maps\nx_hithard_fx::apply_vision_and_fog_osprey();
	
	// Disable all parachute section triggers
	// The osprey flys through them
	thread maps\nx_hithard_util::all_triggers_off( "parachute_trigger" );

	// Create the initial AA UGVs that bring down the VTOL
	thread spawn_vtol_ride_enemy_UGVs();

	//trigger ambient cloud fx
	exploder("osprey_clouds");

	// Lock elements to osprey
	squad_osprey = GetEnt( "squad_osprey", "script_noteworthy" );
	squad_osprey thread magic_bullet_shield();

	player_jump_node = GetEnt( "vehicle_node_anim_player_jump", "script_noteworthy" );
	player_jump_node LinkTo( squad_osprey );

	thread parachute_hud_logic();

	// Start the parachute ride billboard binks
	thread parachute_billboard_binks();

	level Osprey_Intro();

	//level._player SetOrigin( player_jump_node.origin );
	//level._player SetPlayerAngles( player_jump_node.angles );

	// Ambient UGV spawn and logic
	thread parachute_enemy_UGVs();

	level notify( "notify_parachute_start" );

	squad_osprey stop_magic_bullet_shield();
	squad_osprey delete();
}

audio_play_osprey_intro()
{
	thread parachute_audio_settings();
	wait 3;
	mynodeEntity4 = spawn( "sound_emitter", ( 4380, -283, -1566 ) );
	mynodeEntity4 PlaySound( "scn_hh_osprey_intro", "scn_hh_osprey_intro", true );
	mynodeEntity4 waittill( "scn_hh_osprey_intro" );
	mynodeEntity4 delete();
}

// Don't show the friendly name popups for the Osprey AI
hide_intro_ai_names()
{
	intro_ai_noteworthies = [];

	// List of all ai used in intro
	intro_ai_noteworthies = 
	[
		"hithard_intro_pilot1",
		"hithard_intro_pilot2",
		"hithard_intro_ally1",
		"hithard_intro_ally2",
		"hithard_intro_ally3",
		"hithard_intro_ally4",
		"hithard_intro_ally5"
	];

	foreach( ainoteworthy in intro_ai_noteworthies )
	{
		ai = getent( ainoteworthy, "script_noteworthy");
		ai.name = "";
	}	
}

parachute_hud_logic()
{
	level._player waittill("intro_aa_start");

	wait 1.75;

	maps\_chute::parachute_hud_bootup();
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

main_parachute_jump()
{
	// apply the vision set for being outside parachuting
	if ( level._start_point == "default" || level._start_point == "osprey" )
	{
		// regular play through 
		// thread maps\nx_hithard_fx::apply_vision_and_fog_parachute_jump(2.0);
	} else {
		// we're jumping to this point ("parachute")
		thread maps\nx_hithard_fx::apply_vision_and_fog_parachute_jump(0.0);		

		level.squad[0] thread parachute_ally_start( level.parachute_landing_zone, 1 );
		level.squad[1] thread parachute_ally_start( level.parachute_landing_zone, 1 );
	}

	// Make sure allies dont die
	//level.squad[0] magic_bullet_shield();
	//level.squad[1] magic_bullet_shield();


	// blinking lights on your parachuting buddies
	PlayFXOnTag(level._effect[ "aircraft_light_white_blink" ], level.squad[0], "tag_effect");
	PlayFXOnTag(level._effect[ "aircraft_light_white_blink" ], level.squad[1], "tag_effect");

	// PlayFXOnTag(level.squad[0])
	// Add objectives	
	maps\nx_hithard_util::objective_start( "obj_parachute_follow_ally", &"NX_HITHARD_PARACHUTE_OBJ_FOLLOW" );
	Objective_onentity( level.objective["obj_parachute_follow_ally"], level.squad[0] );						  
	Objective_onadditionalentity( level.objective["obj_parachute_follow_ally"], 1, level.squad[1] );

	// Re-enable all the triggers - They needed to be turned off
	// because the osprey flies through them
	thread para_clear_flags();
	thread maps\nx_hithard_util::all_triggers_on( "parachute_trigger" );

	// Start parachute sequence dialogue and helper tips
	thread parachute_dialogue();

	// JR - Temp: Teleport player to correct position
	// This is temporary.  The animation controls where the player
	// gets spawned, so the anim needs to be modified
	// Untill then, the player is teleported to the correct spot
	//level._player maps\_nx_utility::move_player_to_start_point( "playerstart_parachute_jump" );
        
	thread maps\nx_hithard_anim::bomber_flyby_sfx();

	//IPrintLnBold( "setting springy cam" );
	//thread maps\_nx_utility::set_springy_cam_pitch_offset( 30, 4 );

	// Trigger building 1 explosion
	thread maps\nx_hithard_anim::building01_missile_exp_fx();

	/**** Parachute ride start ****/

	//set the flag for music to start after the first line is said and the missle hits the building
	flag_set( "music_parachute_start" );

	// Start parachute
	maps\_chute::chute_start();

	level._player notify( "notify_player_jump_anim_complete" );

	// We need to wait until the relink is complete before saving
	level waittill( "player_relink_complete" );
	thread autosave_now();

	// Changes the players fall speed depending on where he is
	thread player_descent_watcher();

	//Spawn civilian panic
	thread parachute_civilian_panic();

	// Spawns vtols that can be seen while parachuting
	thread parachute_periph_vtols();

	// Sky bridge explosion
	thread parachute_bridge_explosion_01();
	thread parachute_bridge_explosion_02();
	thread skybridge_magic_bullets_01();
	thread skybridge_magic_bullets_02();

	//level thread skybridge_civies_panic();
	//level thread skybridge2_civies_panic();
	level thread maps\nx_hithard_rooftop::vtol_flyin_logic();

	// Enable smoke kill planes
	level._player thread parachute_hurt_smoke();	
	//level._player thread parachute_deserter_killplanes();

	level.squad maps\nx_hithard_util::ignore_all_on();

	// Buffeting Explosion force
	level._explosion_force = 25;
	thread parachute_buffeting( "flag_parachute_building3_explosion_left", "origin_parachute_building3_explosion_left" );
	thread parachute_buffeting( "flag_parachute_building3_explosion_right", "origin_parachute_building3_explosion_right" ); 	

	// Thread wait function for parachute landing objective / library rooftop preparation
	thread watcher_parachute_land_objective();

	// Parachute landing bink
	thread maps\nx_hithard_rooftop::rooftop_landing_bink();

	// Thread out of bounds watcher it until player hinds landing flag
	thread watcher_parachute_outofbounds();
	flag_wait( "flag_parasecure_parachute_landed_player" );
	level._player playsound( "scn_hithard_para_land" );
	thread audio_jetpass();


	/**** Parachute ride end ****/

	flag_set( "music_parachute_ends" );

	// tagBR< note >: This is just a failsafe, but for some reason it was not getting killed off sometimes
	maps\nx_hithard_fx::hide_lz();

	// Kill the parachute
	maps\_chute::chute_end();


	// Undo all the invulnerability that was applied during the ride
	thread squad_prepare_for_fire( 1 );

	maps\nx_hithard_util::objective_end( "obj_parachute_land" );
	thread maps\_utility::set_ambient( "nx_hithard_ext" );

	level notify( "notify_parachute_objective_complete" );

	// Give the player weapons		
	level._player GiveWeapon( level._main_gun );
	foreach( weapon in level.weapons )
	{
		level._player giveWeapon( weapon );
	}		
			
	level._player SwitchToWeapon( level._main_gun );	

	// stop the blinking lights on your squadmates
	StopFXOnTag(level._effect[ "aircraft_light_white_blink" ], level.squad[0], "tag_effect");
	StopFXOnTag(level._effect[ "aircraft_light_white_blink" ], level.squad[1], "tag_effect");

	// This teleport should be removed when the parachute outro anims work			
	ally_start_noteworthies = [ "origin_parachute_land_ally_01_start", "origin_parachute_land_ally_02_start" ];
	level.squad maps\nx_hithard_util::moveAlliesToStartPoint( ally_start_noteworthies );
	level.squad maps\nx_hithard_util::ignore_all_off();

	maps\_threatid::threat_id_enable_toggling();
}

audio_jetpass()
{

	wait 2;
	level._player playsound( "elm_hh_jet_pass" );

}


// Makes double extra certain all the flags are cleared
// at the start of the rooftop section
para_clear_flags()
{
	flag_clear ( "flag_parachute_hurt_smoke" );
	
	flag_clear ( "flag_parachute_section_02" );
	flag_clear ( "flag_building2_slow_fall" );
	flag_clear ( "hanging_guys_delete" );

	flag_clear ( "flag_parachute_section_03" );
	flag_clear ( "flag_building3_slow_fall" );

	flag_clear ( "flag_parachute_section_04" );

	flag_clear ( "flag_vtol_flyin_go" );
	flag_clear ( "flag_parasecure_library_enemies_spawn" );
	flag_clear ( "flag_prepare_for_landing" );
	flag_clear ( "flag_parasecure_parachute_landed_player" );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

watcher_parachute_outofbounds()
{
	level endon( "notify_parachute_objective_complete" );

	while ( 1 )
	{		
		if (( level._player.origin[2] <= 156 ) && ( !flag( "flag_parachute_objective_failed" )))
		{						
			maps\nx_hithard_util::objective_failed( "parachute",  &"NX_HITHARD_PARACHUTE_FAIL_LOW" );
		}
		if( flag( "flag_parasecure_parachute_oob" ) && ( !flag( "flag_parachute_objective_failed" )))
		{
			maps\nx_hithard_util::objective_failed( "parachute",  &"NX_HITHARD_PARACHUTE_FAIL_LOW" );
		}
						  
		wait 0.01;
	}	
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Controls player fall speed at certain points along the chute path
player_descent_watcher()
{
	default_descent_acceleration = 0.0;
	default_descent_velocity = 77;
	default_forward_brake_deceleration = 0.0;

	starting_target_height = 2900; 
	building_2_target_height = 2200;
	building_3_target_height = 650;
	building_4_target_height = 600;

	// JR TODO - Swoop turned off for now
	//default_forward_velocity = 890;
	//swoop_forward_velocity = 950;

	// Fall faster at very start of sequence
	// to counter starting higher in the air
	level._descent_acceleration = 175.0;
	level._max_descent_velocity = 225;

	//level._player SetSpringyCamPitchOffset( 25 );
	//wait( 1.5 );
	//level._player SetSpringyCamPitchOffset( 0 );

	// Until target height
	while( level._player.origin[2] > starting_target_height )
	{
		wait( 1.0 );
	}

	// Reset normal descent params
	level._descent_acceleration = default_descent_acceleration;
	level._max_descent_velocity = 55;
	level._min_descent_velocity = 55;

	// Building 2
	// Force the player down a bit to see the moment
	flag_wait( "flag_building2_slow_fall" );

	// Fall faster
	level._descent_acceleration = 90.0;
	level._max_descent_velocity = 150;
	level._forward_acceleration = 300.0;
	//level._max_forward_velocity = swoop_forward_velocity;

	// Until target height
	while( level._player.origin[2] > building_2_target_height )
	{
		wait( 1.0 );
	}

	// Reset normal descent params
	level._descent_acceleration = default_descent_acceleration;
	level._max_descent_velocity = default_descent_velocity;
	level._forward_acceleration = 200.0;
	//level._max_forward_velocity = default_forward_velocity;


	// Building 3
	// Force the player down a bit to see the moment
	flag_wait( "flag_building3_slow_fall" );

	level._descent_acceleration = 65.0;
	level._max_descent_velocity = 185;
	//level._max_forward_velocity = swoop_forward_velocity;

	// Until target height
	while( level._player.origin[2] > building_3_target_height && !flag( "flag_parasecure_library_enemies_spawn" ))
	{
		wait( 0.25 );
	}


	// Building 4
	// Force the player down a bit to see the moment
	flag_wait( "flag_parasecure_library_enemies_spawn" );

	thread parachute_display_flare();

	level._descent_acceleration = 90.0;
	level._max_descent_velocity = 400;
	//level._max_forward_velocity = swoop_forward_velocity;

	// Until target height
	while( level._player.origin[2] > building_4_target_height )
	{
		wait( 0.25 );
	}


	// Straight away towards landing zone
	// Dont let the player fall much anymore
	level._descent_acceleration = 0.0;
	level._min_descent_velocity = 0;
	level._max_descent_velocity = 25.0;
	//level._max_forward_velocity = default_forward_velocity;


	// Landing sequence
	// Increase the players braking power,
	// and make the player fall faster
	flag_wait( "flag_prepare_for_landing" );

	level._descent_acceleration = 2.0;
	level._max_forward_velocity = 800.0;
	level._min_forward_velocity = 15.0;
	level._forward_acceleration = 12.0;

	//level._player display_hint_timeout( "hint_parachute_flare", 4.0 );
	//	self thread parachute_display_flare();

	// This loop makes the players brake more powerful while the brake is pressed
	// Stops when the player lands
	while( !flag( "flag_parasecure_parachute_landed_player" ))
	{
		// While brake is on, slow down much faster
		if( flag( "_chute.gsc_flag_LT_pressed" ) && flag( "_chute.gsc_flag_RT_pressed" ))
		{
			level._forward_brake_deceleration = -150.0;
			level._descent_acceleration = 128.0;
			level._max_descent_velocity = 2100;
			level._min_descent_velocity = 200;
		}
		else
		{
			level._forward_brake_deceleration = -10.0;
		}
		wait 1.0;
	}

	// Reset just in case
	level._forward_brake_deceleration = 0.0;
}


//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Player flies on side of building 3 (explosion causes buffeting to player)
parachute_buffeting( flag_explosion, origin_explosion )
{
	level endon( "notify_parachute_objective_complete");

	explosion_trigger = GetEnt( flag_explosion, "targetname" );

	//flag_wait( flag_explosion );
	while ( 1 )
	{
		if ( level._player IsTouching( explosion_trigger ) )
		{	 
			// Stop player from falling too much during buffet
			level._min_descent_velocity = 0;
			level._max_descent_velocity = 25.0;

			explosion_point = getent( origin_explosion, "script_noteworthy" );
			thread maps\_chute::parachute_buffeting( explosion_point.origin, explosion_trigger.animation );

			Earthquake( .7, 1.2, level._player.origin, 5000 );
			quakeobj = spawn( "script_origin", level._player.origin );
			quakeobj PlayRumbleOnEntity( "artillery_rumble" );

			return;
		}

		wait 0.05;
	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Waits for player to hit a flag in order to prepare the library rooftops and change to parachute landing objective
watcher_parachute_land_objective()
{
	flag_wait( "flag_parasecure_library_enemies_spawn" );

	// Prepare rooftop section
	//thread maps\nx_hithard_rooftop::prep_parachute_library_rooftop();	

	// Update Objective			
	maps\nx_hithard_util::objective_end( "obj_parachute_follow_ally" );
	maps\nx_hithard_util::objective_start( "obj_parachute_land", &"NX_HITHARD_PARACHUTE_OBJ_LAND" );

	landing_node = GetEnt( "rooftop_landing_node", "script_noteworthy" );
	Objective_Position( level.objective["obj_parachute_land"], landing_node.origin );
	Objective_Icon( level.objective["obj_parachute_land"], "chute_landing_marker" );

	waittillframeend;

	originalWidth = getdvarfloat( "waypointIconWidth" );
	originalHeight = getdvarfloat( "waypointIconHeight" );
	originalScaleSmallest = getdvarfloat( "waypointDistScaleSmallest" );
	SetSavedDvar( "waypointIconWidth", 32.0 );
	SetSavedDvar( "waypointIconHeight", 16.0 );
	SetSavedDvar( "waypointDistScaleSmallest", 1.0 );

	level waittill( "notify_parachute_objective_complete" );

	SetSavedDvar( "waypointIconWidth", originalWidth );
	SetSavedDvar( "waypointIconHeight", originalHeight );
	SetSavedDvar( "waypointDistScaleSmallest", originalScaleSmallest );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//******************************************************************* 

Osprey_Intro()
{
    node = getstruct("hithard_intro_cinematic", "script_noteworthy");

    hithard_osprey_01 = get_vehicle("hithard_osprey_01","targetname");
    hithard_osprey_01.animname = "hithard_osprey_01";
	hithard_osprey_01 StartUsingHeroOnlyLighting();
	level.hithard_osprey_01 = hithard_osprey_01;

    hithard_osprey_02 = get_vehicle("hithard_osprey_02","targetname");
    hithard_osprey_02.animname = "hithard_osprey_02";
	level.hithard_osprey_02 = hithard_osprey_02;

    hithard_osprey_03 = get_vehicle("hithard_osprey_03","targetname");
    hithard_osprey_03.animname = "hithard_osprey_03";
	level.hithard_osprey_03 = hithard_osprey_03;

    hithard_osprey_04 = get_vehicle("hithard_osprey_04","targetname");
    hithard_osprey_04.animname = "hithard_osprey_04";
	level.hithard_osprey_04 = hithard_osprey_04;

	osprey_damaged = spawn_anim_model("osprey_damaged");
	osprey_damaged StartUsingHeroOnlyLighting();
	level.osprey_damaged = osprey_damaged;

	vehicle_osprey_door_intro = spawn_anim_model("vehicle_osprey_door_intro");
	level.vehicle_osprey_door_intro = vehicle_osprey_door_intro;

    player_body = getent("hithard_intro_player_body", "script_noteworthy");
	player_body vehicle_guy_attach( hithard_osprey_01, "tag_guy2" );
    player_body.animname = "player_body";
	level.player_body = player_body;

    ally01 = getent("hithard_intro_ally1", "script_noteworthy");
	ally01 vehicle_guy_attach( hithard_osprey_01, "tag_guy2" );
    ally01.animname = "ally01";
	level.ally01 = ally01;

    ally02 = getent("hithard_intro_ally2", "script_noteworthy");
	ally02 vehicle_guy_attach( hithard_osprey_01, "tag_guy3" );
    ally02.animname = "ally02";
	level.ally02 = ally02;

    ally03 = getent("hithard_intro_ally3", "script_noteworthy");
	ally03 vehicle_guy_attach( hithard_osprey_01, "tag_guy4" );
    ally03.animname = "ally03";
	level.ally03 = ally03;

    ally04 = getent("hithard_intro_ally4", "script_noteworthy");
	ally04 vehicle_guy_attach( hithard_osprey_01, "tag_guy5" );
    ally04.animname = "ally04";
	level.ally04 = ally04;

    ally05 = getent("hithard_intro_ally5", "script_noteworthy");
	ally05 vehicle_guy_attach( hithard_osprey_01, "tag_guy6" );
    ally05.animname = "ally05";
	level.ally05 = ally05;

    pilot01 = getent("hithard_intro_pilot1", "script_noteworthy");
	pilot01 vehicle_guy_attach( hithard_osprey_01, "tag_passenger" );
    pilot01.animname = "pilot01";
	level.pilot01 = pilot01;

    pilot02 = getent("hithard_intro_pilot2", "script_noteworthy");
	pilot02 vehicle_guy_attach( hithard_osprey_01, "tag_driver" );
    pilot02.animname = "pilot02";
	level.pilot02 = pilot02;

	// set up the rig
	player_rig = spawn_anim_model( "player_rig" );
	player_rig StartUsingHeroOnlyLighting();

	player_rig LinkTo( hithard_osprey_01, "tag_guy5" );
	//arc = 15;
	//level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	// animate the rig
	player_rig Show();

	hithard_osprey_01 suspend_drive_anims_for_vignette();
	hithard_osprey_02 suspend_drive_anims_for_vignette();
	hithard_osprey_03 suspend_drive_anims_for_vignette();
	hithard_osprey_04 suspend_drive_anims_for_vignette();
	
	passengers = [ ally01, ally02, ally03, ally04, ally05, pilot01, pilot02, player_rig, player_body, osprey_damaged, vehicle_osprey_door_intro ];
	passengers_org = spawn_tag_origin();
	osprey_rot = hithard_osprey_01.angles[ 1 ];
	passengers_org.origin = hithard_osprey_01.origin + ( cos( osprey_rot ) * 112, sin( osprey_rot ) * 112, -120 );
	passengers_org LinkTo( hithard_osprey_01 );
	osprey_damaged LinkTo( hithard_osprey_01, "tag_origin", (0,0,0), (0,0,0) );
	vehicle_osprey_door_intro LinkTo( hithard_osprey_01, "tag_origin", (0,0,0), (0,0,0) );

    planes = [];
    planes["hithard_osprey_01"] = hithard_osprey_01;
    planes["hithard_osprey_02"] = hithard_osprey_02;
    planes["hithard_osprey_03"] = hithard_osprey_03;
    planes["hithard_osprey_04"] = hithard_osprey_04;


	osprey_damaged Hide();

	// Wait for bink.
	//level waittill( "osprey_intro_bink_01_complete" );

	//thread autosave_now();

	//start osprey missile, AA, and flak FX
	thread osprey_missilehits_periph();

	horizontal_arc = 0;
	vertical_arc = 0;
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, horizontal_arc, horizontal_arc, vertical_arc, vertical_arc, 1);

	// This starts the ally logic...they will spawn at the appropriate time
	level.squad[0] thread parachute_ally_start( level.parachute_landing_zone );
	level.squad[1] thread parachute_ally_start( level.parachute_landing_zone );

	// iPrintLnBold("--- windshield light on ---");
	playFXOnTag(level._effect[ "nx_light_hhh_osprey_intro_windshield" ], hithard_osprey_01, "tag_osprey_windshield"); // light from the outside coming into the osprey

	level._player AllowCrouch( false );

	passengers_org thread anim_single( passengers, "Osprey_Intro" );
	player_rig thread player_rig_on_intro_end( passengers_org, "Osprey_Intro" );

	// light blinking on the dudes
	thread maps\nx_hithard_fx::parachute_guys_blink_lights(ally01, ally05);

	// light on the back door opening in the osprey
	thread maps\nx_hithard_fx::fx_ospreyintro_backdoor_open_light_on(osprey_damaged);

	thread wait_and_cleanup_intro();

	node anim_single( planes, "Osprey_Intro" );

	// Remove intro entities
	level.osprey_damaged thread safe_delete();
	level.ally01 thread safe_delete();
    level.ally02 thread safe_delete();
    level.ally03 thread safe_delete();
    level.ally04 thread safe_delete();
    level.ally05 thread safe_delete();
	level.player_body thread safe_delete();
    level.pilot01 thread safe_delete();
    level.pilot02 thread safe_delete();

	level._player AllowCrouch( true );
}

osprey_damaged_unhide( osprey_damaged )
{
	osprey_damaged Show();
	// playFXOnTag(level._effect[ "nx_light_hhh_osprey_intro_windshield" ], osprey_damaged, "tag_osprey_windshield"); // light from the outside coming into the osprey
	stop_exploder( "osprey_clouds" );

}

intro_explosion_hide( hithard_osprey_01 )
{
	hithard_osprey_01 Hide();
}

wait_and_cleanup_intro()
{
	// Wait for the intro AA notetrack
	level._player waittill( "intro_aa_start" );

	// Anim is done
    level.hithard_osprey_02 thread safe_delete();
    level.hithard_osprey_03 thread safe_delete();
    level.hithard_osprey_04 thread safe_delete();
}

safe_delete()
{
	if( isDefined( self ))
	{
		self delete();
	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//******************************************************************* 
osprey_missilehits_periph()
{
	//iPrintLnBold("--- got fx osprey start ---");
	wait 18.5;
	exploder("osprey_missiles");
} 

player_rig_on_intro_end( node, scene_name )
{
	node waittill( scene_name );
	self Hide();
	//self unlink();
	level._player Unlink();
	self delete();
}

//*******************************************************************
//					                                              	*
//					                                              	*
//******************************************************************* 

vehicle_guy_attach( vehicle, tag_name )
{
	tag_org = vehicle GetTagOrigin( tag_name );
	tag_angles = vehicle GetTagAngles( tag_name );

	self ForceTeleport( tag_org, tag_angles );

	self LinkTo( vehicle, tag_name );
}																		  

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Removes the "brush" door on the osprey (debug / placeholder until we have a real osprey door and anims)
osprey_door_remove()
{
	// Wait for when allies are ready to jump
	//wait 12.5;
	wait 114;

	// different vision set when the door opens on the osprey
	thread maps\nx_hithard_fx::apply_vision_and_fog_osprey_door_open();

	self delete();	
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Animations for player's squad jumping out of plane
parachute_ally_jump_MAJOR_CHANGE( jump_anim_group, squad_osprey )
{
	level endon( "notify_parachute_start" );
			
	// Variables		   
	jump_anim_node_name = "node_anim_parachute_jump_" + self.script_noteworthy;
	rubber_banding_object = "";
	jump_anim_node = GetEnt( jump_anim_node_name, "script_noteworthy" );

	// PJ: Plane setup	
	jump_anim_node LinkTo( squad_osprey );

	// Perform jump animation	 
	self.animname = "anim_parachute_jump_" + self.script_noteworthy;
	guys[0] = self;

	level waittill( "osprey_intro_bink_01_complete" );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Rubber-banding for squad mates parachuting in with player
parachute_rubber_banding( guy_1, guy_2 )
{
	level endon( "notify_parachute_objective_complete" );
	level endon( "parachute_path_complete" );
	level endon( "parachute_approach_start" );

	falling_behind_vo_timeout = false;

	// Distance between allies
	distance_between_allies = 0;		

	if( self == level.squad[ 0 ] )
	{
		self vehicle_SetSpeedImmediate( 30 );
	}
	else
	{
		self vehicle_SetSpeedImmediate( 30 );  
	}	

	while ( 1 )
	{
		distance_between_allies = Distance( self.origin, guy_2.origin );
		
		// Adjust speed of vehicle based on distance from rubber bander
		if ( distance_between_allies < 1200 ) // 1400 
		{
			self Vehicle_SetSpeed( 70, 60 );  
		}
		else if( distance_between_allies > 2750 ) // 3500
		{
			self Vehicle_SetSpeed( 30, 29);
		}
		else
		{
			self Vehicle_SetSpeed( 50, 40 );
		}
		
		// Check for player fail (too far from squad mates)
		if ( ( guy_2 == level._player ) && flag( "flag_parachute_player_rb_fail_allow" ))
		{
			// Maximum follow distance in units before "too far" message displayed
			warning_distance = undefined;

			// Distance at which player will fail
			fail_distance = undefined;

 			//iprintlnbold( distance_between_allies );

			// If the player is at the start, allow for a larger follow distance
			if( flag( "flag_parachute_section_01b" ))
			{
				warning_distance = 3000;
				fail_distance = 4000;	
			}
			else
			{
				warning_distance = 3000;
				fail_distance = 4000;
			}

			if ( distance_between_allies < warning_distance )
			{
				flag_clear( "flag_hint_parachute_falling_behind" );
			}
			else if ( distance_between_allies >= fail_distance )
			{				
				// Failed
				maps\nx_hithard_util::objective_failed( "parachute",  &"NX_HITHARD_PARACHUTE_FAIL_FOLLOW" );
				break;				
			}
			else
			{
				if ( !flag( "flag_hint_parachute_falling_behind" ))
				{
					// Captain Baker: "Spectre, you're falling behind!"
					thread radio_dialogue( "hithard_bak_para_01" );
					
					//falling_behind_vo_timeout = true;
					//falling_behind_vo_timeout = thread falling_behind_vo_timeout();
				}

				flag_set( "flag_hint_parachute_falling_behind" );
				display_hint( "hint_parachute_falling_behind" );
			}
		}

		wait 0.05;
	}							
}


//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************
// Controls crowds of civilians
// JR TODO - Add start/stop flag functionality
parachute_civilian_panic()
{
	thread parachute_civilian_panic_logic( "civies_01a", "flag_parachute_section_01b" );
	thread parachute_civilian_panic_logic( "civies_01b", "flag_parachute_section_01b" );

	thread parachute_civilian_panic_logic( "civies_03a", "flag_parachute_section_01b" );
	thread parachute_civilian_panic_logic( "civies_03b", "flag_parachute_section_01b" );

	flag_wait( "flag_parachute_section_01b" );

	flag_wait( "flag_parachute_section_02" );

	// Skybridge civilians
	skybridge_civilians = GetEntArray( "parachute_civies_04_spawner", "script_noteworthy" );
	array_spawn_function( skybridge_civilians, ::skybridge_civilian_logic, "flag_skybridge_exp_1" );
	thread parachute_civilian_panic_logic( "civies_04", "flag_skybridge_exp_1" );

	skybridge_civilians = GetEntArray( "parachute_civies_04b_spawner", "script_noteworthy" );
	array_spawn_function( skybridge_civilians, ::skybridge_civilian_logic, "flag_skybridge_exp_2" );
	thread parachute_civilian_panic_logic( "civies_04b", "flag_skybridge_exp_2" );

	// Office park civvies
	thread parachute_civilian_panic_logic( "civies_5", "flag_parachute_section_04" );

	// Spawn final civilian panic
	thread parachute_civilian_panic_logic( "civies_10a", "flag_prepare_for_landing" );
	thread parachute_civilian_panic_logic( "civies_10b", "flag_prepare_for_landing" );
	thread parachute_civilian_panic_logic( "civies_10c", "flag_prepare_for_landing" );

	flag_wait( "flag_parachute_section_03" );
	//iprintln( "flag_parachute_section_03" );

	// tagJW<NOTE>: Clean up animated wind turbines to free up animinfos
	wind_turbines = GetEntArray( "wind_turbine", "script_noteworthy" );
	foreach ( wind_turbine in wind_turbines )
	{
		wind_turbine delete();
	}

	// Cleanup

	flag_wait( "flag_parachute_section_04" );
	//iprintln( "flag_parachute_section_04" );

	flag_wait( "flag_prepare_for_landing" );
	//iprintln( "flag_prepare_for_landing" );

}


// Wrapper to make infinite streaming civies
// JR - The crowd system should have this functionality built-in
parachute_civilian_panic_logic( group, kill_flag )
{
	spawner = "parachute_" + group + "_spawner";
	solo_spawner = "parachute_" + group + "_solo_spawner";
	start = "parachute_" + group + "_start";
	end = "parachute_" + group + "_end";

	// Create the crowd
	crowd = maps\nx_crowd_controller::new_crowd( group, 8, 
		GetEntArray( spawner, "script_noteworthy"), 
		GetEntArray( start, "script_noteworthy"), 
		GetEntArray( end, "script_noteworthy"), 
		0.3, 0.7 );

	// Spawn the solo guys	
	solo_spawned_array = spawn_noteworthy_and_return_array( solo_spawner );

	// Keep spawning untill player lands
	while( !flag( "flag_parasecure_parachute_landed_player" ) )
	{
		if ( isdefined( kill_flag ) && flag( kill_flag ) )
		{
			level notify( kill_flag );
			break;
		}

		maps\nx_crowd_controller::spawn_crowd( group, kill_flag );
		level waittill( group );
		//wait( 4.0 );
	}

	// Kill the solo guys
	foreach ( solo_drone in solo_spawned_array )
	{
		solo_drone delete();
	}
	
	// No need to kill crowd controller guys, they should expire at end of their path	
}

// tagJW<NOTE>: Keeping this out of nx_utility since I don't want it to set count - using to spawn drones
spawn_noteworthy_and_return_array( noteworthy )
{
	spawners = GetEntArray( noteworthy, "script_noteworthy" );
	guys = [];
	foreach ( spawner in spawners )
	{
		guy = spawner spawn_ai();
		if ( IsDefined( guy ) && IsAlive( guy ) )
		{
			guys[ guys.size ] = guy;
		}
	}
	return guys;
}


// JR - I think this might be run on level load
// Should delay it to start with a trigger,
// and make sure it cleans itself up
skybridge_civies_panic()
{
	crowd = maps\nx_crowd_controller::new_crowd( "skybridge_civies", 
	10, 
	GetEntArray( "skybridge_civies_spawner", "script_noteworthy" ), 
	GetEntArray( "skybridge_civies_start", "script_noteworthy"), 
	GetEntArray( "skybridge_civies_end", "script_noteworthy"));

	wait 4.0;
	//while( 1 )
	while( !flag( "flag_parasecure_parachute_landed_player" ))
	{
		maps\nx_crowd_controller::spawn_crowd( "skybridge_civies" );
		wait 10.0;
	}
}

// JR - I think this might be run on level load
// Should delay it to start with a trigger,
// and make sure it cleans itself up
skybridge2_civies_panic()
{
	crowd = maps\nx_crowd_controller::new_crowd( "skybridge2_civies", 
	10, 
	GetEntArray( "skybridge2_civies_spawner", "script_noteworthy" ), 
	GetEntArray( "skybridge2_civies_start", "script_noteworthy"), 
	GetEntArray( "skybridge2_civies_end", "script_noteworthy"));

	wait 4.0;
	//while( 1 )
	while( !flag( "flag_parasecure_parachute_landed_player" ))
	{
		maps\nx_crowd_controller::spawn_crowd( "skybridge2_civies" );
		wait 10.0;
	}
}


//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************
// Controls enemy UGV during parachute ride
// JR TODO - Remove actual vehicles and use static models firing magic bullets
// rocket = MagicBullet( "rpg_straight", rocket_source.origin, rocket_target.origin );
parachute_enemy_UGVs()
{
	flag_set( "flag_creating_enemy_UGVs" );
	wait( .10 );

	// Prepare squad mates to be fired at
	squad_prepare_for_fire();

	// These two die after building 1
	thread parachute_enemy_UGV_logic( "parachute_ugv_01a", "flag_parachute_section_01b", level.squad[1] );
	thread parachute_enemy_UGV_logic( "parachute_ugv_01b", "flag_parachute_section_01b", level.squad[0] );

	waittillframeend;

	// JR - The target node GetEnt could be baked down into the parachute_enemy_ugv_logic() script
	target_node = GetEnt( "parachute_ugv_02a_target_node", "script_noteworthy" );
	thread parachute_enemy_UGV_logic( "parachute_ugv_02a", "flag_building2_slow_fall", target_node ); // Old target: level.squad[0]
	//thread parachute_enemy_UGV_logic( "parachute_ugv_02b", "flag_building2_slow_fall", level.squad[1] );

	waittillframeend;

	target_node = GetEnt( "parachute_ugv_03a_target_node", "script_noteworthy" );
	thread parachute_enemy_UGV_logic( "parachute_ugv_03a", "flag_building2_slow_fall", target_node ); // Old target: level.squad[0]
	//thread parachute_enemy_UGV_logic( "parachute_ugv_03b", "flag_building2_slow_fall", level.squad[0] );

	flag_wait( "flag_parachute_section_01b" );

	target_node = GetEnt( "parachute_ugv_03c_target_node", "script_noteworthy" );
	thread parachute_enemy_UGV_logic( "parachute_ugv_03c", "flag_parachute_section_03", target_node ); // Old target: level.squad[1]

	flag_wait( "flag_parachute_section_02" );

	target_node = GetEnt( "parachute_ugv_04a_target_node", "script_noteworthy" );
	thread parachute_enemy_UGV_logic( "parachute_ugv_04a", "flag_building3_slow_fall", target_node ); // Old target: level.squad[0]

	target_node = GetEnt( "parachute_ugv_04b_target_node", "script_noteworthy" );
	thread parachute_enemy_UGV_logic( "parachute_ugv_04b", "flag_building3_slow_fall", target_node ); // Old target: level.squad[0]

	//flag_wait( "flag_parachute_drones_03" );

	target_node = GetEnt( "parachute_ugv_05a_target_node", "script_noteworthy" );
	thread parachute_enemy_UGV_logic( "parachute_ugv_05a", "flag_parachute_section_04", target_node ); // Old target: level.squad[0]

	target_node = GetEnt( "parachute_ugv_05b_target_node", "script_noteworthy" );
	thread parachute_enemy_UGV_logic( "parachute_ugv_05b", "flag_parachute_section_04", target_node ); // Old target: level.squad[0]
}


//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************
// These should fire during the intro and deploy anims
spawn_vtol_ride_enemy_UGVs()
{
	level._player waittill( "intro_aa_start" );

	// Get the target nodes to fire at
	node_00a = GetEnt( "vtol_aa_target_node_00a", "script_noteworthy" );
	node_00b = GetEnt( "vtol_aa_target_node_00b", "script_noteworthy" );
	node_00c = GetEnt( "vtol_aa_target_node_00c", "script_noteworthy" );

	// Spawn the UGVs, and start firing
	thread parachute_enemy_UGV_logic( "parachute_ugv_00a", "flag_creating_enemy_UGVs", node_00a );
	thread parachute_enemy_UGV_logic( "parachute_ugv_00b", "flag_creating_enemy_UGVs", node_00b );
	thread parachute_enemy_UGV_logic( "parachute_ugv_00c", "flag_creating_enemy_UGVs", node_00c );
}


// Spawn and control each UGV
parachute_enemy_UGV_logic( targetname, delete_flag, fire_target, wide )
{
	ugv_spawner = GetEnt( targetname, "targetname" );
	ugv = vehicle_spawn( ugv_spawner );
	ugv set_cheap_turret();

	ugv endon( "death" );

	//ugv mgoff();
	//ugv.mgturret[0] SetMode( "manual" );
	ugv.mgturret[1] SetMode( "manual" );
	ugv.mgturret[2] SetMode( "manual" );

	thread gopath( ugv );
	

	if( isDefined( fire_target ))
	{
		ugv thread vehicle_fire_around_entity( fire_target, RandomFloatRange( 1, 2 ), wide );
	}

	ugv flag_wait( delete_flag );
	ugv Delete();

	//IPrintLnBold( "UGV deleted" );
}

squad_prepare_for_fire( undo )
{
	if( !isDefined( undo ))
	{
		// Create the player_lead dummy object
		level._player EnableInvulnerability();

		// Squad shouldnt get hit or take pain
		level.squad[0] godon();
		level.squad[1] godon();

		level.squad[0].disableBulletWhizByReactions = true;
		level.squad[1].disableBulletWhizByReactions = true;
	
		level.squad[0] disable_pain();
		level.squad[1] disable_pain();
	
		level.squad[0].ignoreall = true;
		level.squad[1].ignoreall = true;
	
		level.squad[0].ignoresuppresion = true;
		level.squad[1].ignoresuppresion = true;
	}
	else
	{
		level._player DisableInvulnerability();

		level.squad[0].disableBulletWhizByReactions = false;
		level.squad[1].disableBulletWhizByReactions = false;
	
		level.squad[0] enable_pain();
		level.squad[1] enable_pain();
	
		level.squad[0].ignoreall = false;
		level.squad[1].ignoreall = false;
	
		level.squad[0].ignoresuppresion = false;
		level.squad[1].ignoresuppresion = false;
	}
}

// taken from hit hard b
vehicle_fire_around_entity( e, interval, wide )
{
	self endon( "death" );
	if( !IsDefined( self.mgturret ) )
		return;

	turret = self.mgturret[0];

	turret StartBarrelSpin();

	while( 1 )
	{
		r = RandomFloat( 360 );
		s = RandomFloatRange( 120.0, 240.0 );

		// Wider cone of fire
		if( isDefined( wide ))
		{
			s = RandomFloatRange( 210.0, 340.0 );
		}


		targetPos = e.origin + ( cos(r)*s, sin(r)*s, 0);
		turret SetTurretTargetPosition( targetPos );

		// Although technically the turret needs a frame to move, 
		// it feels better if it fires before moving.
		// It makes the shots lag behind a bit and get in the players face
		//waittillframeend;

		turret ShootTurret();

		wait interval;
	}
}


//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Spawn ally parachute vehicles, start path, and rubber band
parachute_lz_init()
{	
	// hidden to start with
	thread maps\nx_hithard_fx::hide_lz();
	parachute_lz_sequence();
}

parachute_lz_sequence()
{	
	// wait to hit the first trigger
	flag_wait( "flag_turn_on_lz" );
	thread maps\nx_hithard_fx::lz_flicker_on();

	// wait to land, then turn it off
	flag_wait("flag_parasecure_parachute_landed_player");
	// wait 1.0;
	thread maps\nx_hithard_fx::lz_flicker_off();

	thread disable_ride_effects();
}


// JR TODO
// Cleanup for effects, drones, and vehicles shown during the ride
disable_ride_effects()
{
	// kill smoke
	//delete_exploder();
	// kill AA
	//delete_exploder();

	// kill UGVs
	//GetEntArray( "parachute_scenary_ugvs", "script_noteworthy" );

	// kill drones
	//GetEntArray( "parachute_scenary_drones", "script_noteworthy" );

	// kill drone cars
	//GetEntArray( "parachute_scenary_cars", "script_noteworthy" );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

parachute_audio_settings()
{
	wait 45;
	level._player deactivatechannelvolumes( "snd_channelvolprio_pain", 1 );
}

// Spawn ally parachute vehicles, start path, and rubber band
parachute_ally_start( node_landing_location, immediate )
{	
	if ( !IsDefined( immediate ) )
	{
		level._player waittill( "ally_parachute_spawn" );
	}

	level._player PlaySound( "hithard_para_jump" );
	level._player PlaySound( "hithard_para_ospfade" );
	thread maps\_utility::set_ambient( "nx_hithard_chute" );
	// Variables	
	vehicle_targetname = "parachute_" + self.script_noteworthy;			

	// Choose who to have the ally rubber band with
	if ( self.script_noteworthy == "ally_01" )
	{			
		rubber_banding_object = level.squad[1];
							
	}
	else 
	{			
		rubber_banding_object = level._player;
	}		
	
	self.ignoreall = true;

	self Hide();

	parachute_vehicle = spawn_vehicle_from_targetname_and_drive( vehicle_targetname );	
	parachute_vehicle godon();

	if ( !IsDefined( immediate ) )
	{
		parachute_vehicle Vehicle_SetSpeedImmediate( 20, 1, 1 );

		level._player waittill( "notify_player_jump_anim_complete" );
	}

	parachute_vehicle Vehicle_SetSpeedImmediate( 70, 10000, 10000 );//really high accell and decell
	
	parachute_vehicle set_heli_move( "faster" );
	parachute_vehicle SetTurningAbility( 1.0 );

	self forceteleport(	parachute_vehicle.origin, parachute_vehicle.angles );

	if ( !isdefined( parachute_vehicle ))
	{
		AssertMsg( vehicle_targetname + " did not spawn correctly!" );
	}

	//parachute_vehicle Vehicle_Teleport( self.origin, parachute_vehicle.angles );
	wait 0.033;
	self linkto( parachute_vehicle, "tag_driver", (0,0,0), (0,0,0) );
	self Show();
	parachute_vehicle guy_enter_vehicle( self );

	// Start rubber banding	
	parachute_vehicle thread parachute_rubber_banding( self, rubber_banding_object );
	
	// Run landing sequence
	self thread parachute_ally_landing( parachute_vehicle, node_landing_location );
}


//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************
// Controls dialogue and tutorial hint text
parachute_dialogue()
{
	waittillframeend;

	//=================================================================
	// From start to building 2
	//=================================================================
	flag_wait( "flag_parachute_section_01" );

	// Captain Baker: "Plotted a route to Patriot. On me."
	wait_play_dialogue_wait( 0.1, "hithard_bak_para_05" );

	//level._player display_hint( "hint_parachute_left" );
	thread display_hint_timeout( "hint_parachute_left", 4 );	

	// Captain Baker: "Shit! Swinging left!"
	wait_play_dialogue_wait( 2.8, "hithard_bak_para_08", undefined, undefined, "flag_parachute_player_rb_fail_allow" );	

	// Captain Baker: "Follow me."
	//wait_play_dialogue_wait( 4.5, "hithard_bak_para_10" );

	// Duke: "Fuck me!"
	wait_play_dialogue_wait( 4.5, "hithard_gyp_para_01" );

	// Captain Baker: "Left! Left!"
	//wait_play_dialogue_wait( 1.0, "hithard_bak_para_03" );

	// Captain Baker: "Steer clear of the smoke!"
	//wait_play_dialogue_wait( 3.0, "hithard_bak_para_02" );

	//level._player display_hint( "hint_parachute_smoke" );
	//display_hint_timeout( "hint_parachute_smoke", 3 );

	//=================================================================
	// Building 2
	//=================================================================
	flag_wait( "flag_building2_slow_fall" ); 

	// Captain Baker: "Damn - going through!"
	wait_play_dialogue_wait( 0.5, "hithard_bak_para_03" );

	// Duke: "Holy shit..."
	wait_play_dialogue_wait( 3.5, "hithard_gyp_para_02" );


	//level._player display_hint( "hint_parachute_right" );


	//=================================================================
	// Y intersection
	//=================================================================

	flag_wait( "flag_parachute_section_03" ); 

	// Captain Baker: "They're everywhere!"
	wait_play_dialogue_wait( 5.2, "hithard_bak_para_11" );

	// Captain Baker: "Go around!"
	//wait_play_dialogue_wait( 4.5, "hithard_bak_para_14" );


	//=================================================================
	// Building 3 explosion
	//=================================================================
	flag_wait_any( "flag_parachute_building3_explosion_left", "flag_parachute_building3_explosion_right" );

	// Captain Baker: "Watch out!"
	wait_play_dialogue_wait( 0.35, "hithard_bak_para_13" );


	//=================================================================
	// From building 4 to landing
	//=================================================================
	flag_wait( "flag_parachute_section_04" );

	// Captain Baker: "LZ. Eleven o'clock!"
	wait_play_dialogue_wait( 1.1, "hithard_bak_para_16" );


	// Captain Baker: "Contacts, top of the parking structure."
	wait_play_dialogue_wait( 4.0, "hithard_bak_snipe_02" );

	// Captain Baker: "Theres the LZ. Prep for hard landing."
	//wait_play_dialogue_wait( 4.0, "hithard_bak_para_16" );

	// Captain Baker: "We have tangos at the LZ.  Cut your chutes and engage."
	//wait_play_dialogue_wait( 4.0, "hithard_bak_para_20" );
}


// Helper script for timing dialogue
wait_play_dialogue_wait( wait_in, dialogue1, dialogue2, wait_out, flag )
{
	wait( wait_in );
	
	if( cointoss() || !isDefined( dialogue2 ))
	{
		thread radio_dialogue( dialogue1 );
	}
	else
	{
		thread radio_dialogue_flag_set( dialogue2, flag );
	}

	if( isDefined( flag ))
	{
		flag_set( flag );		
	}

	if( isDefined( wait_out ))
	{
		wait( wait_out );
	}
}
//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// plays a radio dialogue and then sets a flag 
radio_dialogue_flag_set( dialogue, flag )
{
	radio_dialogue( dialogue );
	flag_set( flag );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Tell player to flare ( brake ) for landing
parachute_display_flare()
{
	level endon( "flag_parasecure_parachute_landed_player" );
	level endon( "notify_parachute_objective_complete" );
	//while( level._player.origin[2] > 350 )
	//{
	//	level._player display_hint( "hint_parachute_flare" );
	//	wait 0.01;
	//}

	// Small delay so the tip doesnt come up too early.
	wait( 2.0 );

	display_hint_timeout( "hint_parachute_flare", 3 );
}


//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Player gets hurt while in smoke
parachute_hurt_smoke()
{
	// Stop this script when the chute section is done
	level endon( "notify_parachute_objective_complete" );

	// While in Parachute sequence
	while( !flag( "flag_parasecure_parachute_landed_player" ))
	{
		// Wait for player to be in smoke
		flag_wait( "flag_parachute_hurt_smoke" );

		// While in the smoke
		while ( flag( "flag_parachute_hurt_smoke" ) )
		{
			// Slow them down and prevent dropping
			// This gives the player some time to get out of the smoke
			level._forward_brake_deceleration = -150.0;
			level._descent_acceleration = 0.0;
			level._max_descent_velocity = 15;
			level._min_descent_velocity = 0;
			level._max_forward_velocity = 400;

			level._player display_hint( "hint_parachute_smoke" );

			//if( cointoss())
			//{
			//	radio_dialogue( "hithard_bak_para_02" ); // JR - Line was cut
			//}
			//else
			//{
				//radio_dialogue( "hithard_bak_para_13" );
			//}

			//PlayFX( LoadFX( "smoke/thick_dark_smoke_giant_dcburning" ), self.origin );
			self PlayRumbleOnEntity( "grenade_rumble" );
			self StunPlayer( 1.5 );
			self thread play_sound_on_entity( "breathing_hurt" );
			if ( self.health <= 45 )
			{
				if ( !flag( "flag_parachute_objective_failed" ))
				{
					maps\nx_hithard_util::objective_failed( "parachute",  &"NX_HITHARD_PARACHUTE_FAIL_SMOKE" );
				}
			}
			else
			{
				self.health = self.health - 30;
			}

			wait 1.25;
		}

		level._forward_brake_deceleration = 0.0;
		level._descent_acceleration = 0.0;
		level._max_descent_velocity = 1200;
		level._min_descent_velocity = 77;
		level._max_forward_velocity = 890;

		// Not in smoke anymore
	}	
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Ally landing sequence
parachute_ally_landing( parachute_vehicle, node_landing_location )
{		
	flag_wait( "flag_node_parachute_approach_" + self.script_noteworthy );
	
	parachute_vehicle set_heli_move( "approach" );//make the pitch and roll less, also make the yaw tighter. needed to get things to line up.
	
	level notify ( "parachute_approach_start" );

	flag_wait( "flag_origin_path_parachute_land_" + self.script_noteworthy );
	level notify ( "parachute_path_complete" );

	// Vars
	flag_node_anim_name = "origin_begin_land_" + self.script_noteworthy;
							   
	// Get the node that will initiate the landing anim
	flag_node_ally_land = GetStruct( flag_node_anim_name, "script_noteworthy" );	
	
//  flag_wait( flag_node_anim_name );

	// Squad leader only
//  if ( self.script_noteworthy == level.squad_noteworthies[0] )
//  {
//  	// Dialogue: "Snipers on the roof.  Northwest corner.  Take 'em out."
//  	thread radio_dialogue( "hithard_bak_secure_01" );
//  	//objective_setpointertextoverride( 1, &"" );	//Clear the pointer text
//  	//objective_onentity( 1, node_landing_location );
//  }

	//now we need to move the parachute and the actor together to the node for animation lerping their angles
	//and position.
	

	level notify( "notify_ally_parachute_complete" );
	
	//reached the end of the path sort of. Where we want to end is right before the last node so there is no speed drop.
	parachute_vehicle vehicle_stoppath();
	
	parachute_vehicle suspend_drive_anims_for_vignette();
	
	//... but that means were not gauranteed to be on the node, so instead lets use a mover to lerp our orientation
	// and position at the same speed as the vehicle was moving to the correct location.
	dist = Distance( flag_node_ally_land.origin, parachute_vehicle.origin );
	time = dist / ( parachute_vehicle.veh_speed * CONST_MPHCONVERSION );
	
	actor_anim_name = "anim_parachute_land_" + self.script_noteworthy;	//anim_parachute_land_ally_02
	vehicle_anim_name = "anim_parachute_" + self.script_noteworthy;	//anim_parachute_ally_02
	
	self unlink();
	parachute_vehicle guy_exit_vehicle( self );
	parachute_vehicle hide();
	
	parachute = spawn( "script_model", parachute_vehicle.origin );
	parachute.angles = parachute_vehicle.angles;
	parachute SetModel( level._scr_model[ vehicle_anim_name ] );
	parachute UseAnimTree( level._scr_animtree[ vehicle_anim_name ] );
	self LinkTo( parachute, "tag_driver" );
	
	//also need to play the idle anim in the same spot as the vehicle.
	parachute_anim = level._vehicle_DriveIdle[ "vehicle_parachute" ];
	idle_time = parachute_vehicle GetAnimTime( parachute_anim );
	parachute SetAnim( parachute_anim, 1, 0 );
	parachute SetAnimTime( parachute_anim, idle_time );
	
	parachute MoveTo( flag_node_ally_land.origin, time, 0, 0 );//do not accelerate.
	parachute RotateTo( flag_node_ally_land.angles, time );
	
	wait time;
	
	self unlink();

	//now that we're at the right location, play the animation for the landing.
	land_group = [];
	land_group["parachute" + self.script_noteworthy] = parachute;
	land_group["ally" + self.script_noteworthy] = self;

	parachute.animname = vehicle_anim_name;
	self.animname = actor_anim_name;
	parachute UseAnimTree( level._scr_animtree[ vehicle_anim_name ] );

	flag_node_ally_land anim_single( land_group, "anim_parachute_land" );

	self.ignoreall = false;
}

// Loads and plays the animated billboard binks
parachute_billboard_binks( from_playerstart )
{
	// Only wait for this flag when playing natural progression
	if( !isDefined( from_playerstart ))
	{
		level._player waittill("intro_aa_start");
	}

	// preload the movie
	SetSavedDvar( "cg_cinematicFullScreen", "0" );
	CinematicInGameLoopResident( "HHAH_Ads" );
	
	level waittill( "flag_prepare_for_landing" );

	StopCinematicInGame();
}



//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Triggers the 2 vtols that fly in after building 2
parachute_periph_vtols()
{
	flag_wait( "flag_parachute_section_02" );
	wait( 0.3 );
	vtol = spawn_vehicles_from_targetname_and_drive ( "periph_vtols" );
}

parachute_bridge_explo_sfx()
{
	level._player setchannelvolumes( "snd_channelvolprio_pain", "nx_hithard_skybridge_explo", 1.7 );
	wait( 1.71 );
	skybridge_explo = getent("parachute_bridge_exp1_01", "targetname");
	skybridge_explo playsound("hithard_skybridge_destroy");

	wait 4.0;
	level._player deactivatechannelvolumes( "snd_channelvolprio_pain", 1 );

}

// Triggers a series of explosions across skybridge	1
parachute_bridge_explosion_01()
{
	flag_wait( "flag_parachute_section_03" );
	thread parachute_bridge_explo_sfx();

	wait( 2.25 );

	// Stop spawning civilians
	flag_set( "flag_skybridge_exp_1" );

	skybridge_single_explosion( getEnt( "parachute_bridge_exp1_01", "targetname" ));
   	wait( 0.16 );
	skybridge_single_explosion( getEnt( "parachute_bridge_exp1_02", "targetname" ));
	wait( 0.11 );
	skybridge_single_explosion( getEnt( "parachute_bridge_exp1_03", "targetname" ));
	wait( 0.22 );
	skybridge_single_explosion( getEnt( "parachute_bridge_exp1_04", "targetname" ));
	wait( 0.35 );
	skybridge_single_explosion( getEnt( "parachute_bridge_exp1_05", "targetname" ));
}

// Triggers a series of explosions across skybridge 2
parachute_bridge_explosion_02()
{
	flag_wait( "flag_parachute_section_03" );
	wait( 2.8 );

	// Stop spawning civilians
	flag_set( "flag_skybridge_exp_2" );

	skybridge_single_explosion( getEnt( "parachute_bridge_exp2_01", "targetname" ));
   	wait( 0.50 );
	skybridge_single_explosion( getEnt( "parachute_bridge_exp2_02", "targetname" ));
	wait( 0.15 );
	skybridge_single_explosion( getEnt( "parachute_bridge_exp2_03", "targetname" ));
	wait( 0.18 );
	skybridge_single_explosion( getEnt( "parachute_bridge_exp2_04", "targetname" ));
	wait( 0.12 );
}

// Causes 1 skybridge explosion with physics force
skybridge_single_explosion( origin )
{
	forward = AnglesToForward( origin.angles );
	up = AnglesToUp( origin.angles );
	playFX( level._effect[ "nx_explosion_skybridge" ], origin.origin, forward, up );
	//playFX( level._effect[ "osprey_missle_hit_explosion_l" ], origin.origin, forward, up );
	radiusDamage( origin.origin, origin.radius, 9000, 9000 );
	wait( 0.05 );
	PhysicsExplosionSphere( origin.origin, origin.radius * 2, ( origin.radius * 2 ), 5 );
}

// Skybridge civilians ragdoll when dead
skybridge_civilian_logic( stop_flag )
{
	level endon( stop_flag );
	self.skipDeathAnim = true;

	self waittill( "death" );
	if( isDefined( self ))
	{
		self StartRagdoll();
	}
}


// JR - Playerstart debug point for testing the skybridge explosion
playerstart_skybridge_debug()
{
	maps\nx_crowd_controller::main();

	// teleport player
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_skybridge_debug" );
	thread maps\nx_hithard_fx::apply_vision_and_fog_parachute_jump(0.0);

	// Start civilians
	skybridge_civilians = GetEntArray( "parachute_civies_04_spawner", "script_noteworthy" );
	array_spawn_function( skybridge_civilians, ::skybridge_civilian_logic, "flag_skybridge_exp_1" );
	thread parachute_civilian_panic_logic( "civies_04", "flag_skybridge_exp_1" );

	skybridge_civilians = GetEntArray( "parachute_civies_04b_spawner", "script_noteworthy" );
	array_spawn_function( skybridge_civilians, ::skybridge_civilian_logic, "flag_skybridge_exp_2" );
	thread parachute_civilian_panic_logic( "civies_04b", "flag_skybridge_exp_2" );

	thread parachute_bridge_explosion_01();
	thread parachute_bridge_explosion_02();
	thread skybridge_magic_bullets_01();
	thread skybridge_magic_bullets_02();

	// Wait here forever
	flag_wait( "flag_parachute_section_04" );
}

// JR - This is only used with the skybridge debug start
skybridge_debug()
{
	// wait here forever
	flag_wait( "flag_parachute_section_04" );
}


// JR - This needs to be timed up in synch with the bridge explosions
skybridge_magic_bullets_01()
{
	flag_wait( "flag_parachute_section_03" );

	wait( 0.4 );

	// Get the origin node
	magic_bullet_node = GetEnt( "skybridge_magic_bullet", "targetname" );

	magicbullet( "rpgx_straight", magic_bullet_node.origin, getEnt( "parachute_bridge_exp1_01", "targetname" ).origin );
	wait 0.4;
	magicbullet( "rpgx_straight", magic_bullet_node.origin, getEnt( "parachute_bridge_exp1_02", "targetname" ).origin );
	wait 0.65;
	//magicbullet( "rpgx_straight", magic_bullet_node.origin, getEnt( "parachute_bridge_exp1_03", "targetname" ).origin );
	//wait 0.5;
	//magicbullet( "rpgx_straight", magic_bullet_node.origin, getEnt( "parachute_bridge_exp1_04", "targetname" ).origin );
	wait 0.45;
	magicbullet( "rpgx_straight", magic_bullet_node.origin, getEnt( "parachute_bridge_exp1_05", "targetname" ).origin );
}

// Upper skybridge bullets
skybridge_magic_bullets_02()
{
	flag_wait( "flag_parachute_section_03" );
	wait( 0.25 );

	// Get the origin node
	magic_bullet_node = GetEnt( "skybridge_magic_bullet", "targetname" );

	magicbullet( "rpgx_straight", magic_bullet_node.origin, getEnt( "parachute_bridge_exp2_02", "targetname" ).origin );
	wait( 0.75 );
	magicbullet( "rpgx_straight", magic_bullet_node.origin, getEnt( "parachute_bridge_exp2_03", "targetname" ).origin );
	wait( 0.45 );
	magicbullet( "rpgx_straight", magic_bullet_node.origin, getEnt( "parachute_bridge_exp2_04", "targetname" ).origin );
}
