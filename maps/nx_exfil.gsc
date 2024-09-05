//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  SKYSCRAPER EXFIL												**
//                                                                          **
//    Created: 11/10/2011 - John Webb										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main()
{
	// External Initialization
	maps\nx_exfil_precache::main();
	maps\nx_exfil_fx::main();

	// Setup starts
	default_start( ::intro_seq );
	add_start( "intro",						::intro_seq,				"Intro",				::intro );
	add_start( "market",					::market_start,				"Market",				::market );
	add_start( "street",					::street_start,				"Street",				::street );
	add_start( "alley",						::alley_start,				"Alley",				::alley );
	add_start( "market_dev",				::market_start_dev,			"Market Dev",			::market );
	add_start( "street_dev",				::street_start_dev,			"Street Dev",			::street );

	maps\_riotshield::init_riotshield();

	maps\_load::main();
	maps\nx_exfil_amb::main();
	maps\_drone_ai::init();

	// Internal Initialization
	mission_flag_inits();
	mission_precache();

	thread maps\nx_exfil_fx::create_string_light_glows();

	maps\nx_exfil_anim::main();
	//set timescale factors
	SoundSetTimeScaleFactor( "Music", 0 );

	// Mission threads
	level thread maps\nx_exfil_audio::mission_music();
	level thread mission_objective_logic();

	// Spotlight heli
	level._default_player_threatbias = level._player.threatbias;
	thread wait_for_spotlight_heli_trigger();

	// Animated flags
	thread animated_flags_logic();

	lastroomtrigger = GetEnt( "lastroomtrigger", "targetname" );
	lastroomtrigger thread triggervolumetest();

	thread audio_outro_chaos();

	barricade_vo_warning = GetEnt( "barricade_vo_warning", "targetname" );
    barricade_vo_warning thread maps\nx_exfil_audio::police_barricade_warning_vo();

	init_spawn_funcs();
}

triggervolumetest()
{

	self waittill( "trigger" );
	
	helicopter_pass = spawn( "sound_emitter", ( 4968, -1616, 694 ) );
	helicopter_pass PlaySound( "emt_exfil_chaos_helicopter" );
	helicopter_pass moveto( ( 6000, 64, 694 ), 11.0, .5, .5 );
	
	indoor_steps = spawn( "sound_emitter", ( 4621, -870, 467 ) );
	indoor_steps PlaySound( "emt_exfil_chaos_indoor_steps" );
	indoor_steps moveto( ( 4549, -442, 467 ), 3.0, .5, .5 );

	wait 8;
	helicopter_pass2 = spawn( "sound_emitter", ( 6000, 64, 694 ) );
	helicopter_pass2 PlaySound( "emt_exfil_chaos_helicopter" );
	helicopter_pass2 moveto( ( 4968, -1616, 694 ), 11.0, .5, .5 );
	
	indoor_steps2 = spawn( "sound_emitter", ( 4549, -442, 467 ) );
	indoor_steps2 PlaySound( "emt_exfil_chaos_indoor_steps" );
	indoor_steps2 moveto( ( 4621, -870, 467 ), 3.0, .5, .5 );

}

audio_outro_chaos()
{

	level.audio_outro_emitter = spawn( "sound_emitter", ( 4945, -576, 380 ) );
	level.audio_outro_emitter PlayloopSound( "emt_exfil_chaos_01" );

}

// All mission specific PreCache calls
mission_precache()
{
	precachestring( &"NX_EXFIL_OBJ_GET_TO_EXFIL" );
}

// All mission specific flag_init() calls
mission_flag_inits()
{
	// Global inits here
	flag_init( "market_enc_end" );

	// Map specific inits here
	maps\nx_exfil_audio::flag_inits();
	maps\nx_exfil_anim::flag_inits();
	maps\nx_exfil_intro::flag_inits();
	maps\nx_exfil_market::flag_inits();
	maps\nx_exfil_street::flag_inits();
}


//*******************************************************************
//  OBJECTIVES                                                      *
//                                                                  *
//*******************************************************************

mission_objective_logic()
{
	// Wait for friendlies to spawn
	waittillframeend; 
	
	switch ( level._start_point )
	{
		case "default":
		case "intro":
		case "market":
		case "market_dev":
		case "street":		
		case "street_dev":
		case "alley":
			objective_add( obj( "obj_get_to_exfil" ), "current", &"NX_EXFIL_OBJ_GET_TO_EXFIL" );
			break;
		default:
			AssertMsg( "No objectives set for this start point" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

init_spawn_funcs()
{
	array_thread( GetEntArray( "alley_group1", "targetname" ), ::add_spawn_function, ::enable_cqbwalk );
	array_thread( GetEntArray( "alley_group2", "targetname" ), ::add_spawn_function, ::enable_cqbwalk );
	array_thread( GetEntArray( "arcade_dudes", "targetname" ), ::add_spawn_function, ::enable_cqbwalk );
	array_thread( GetEntArray( "swatvan1", "targetname" ), ::add_spawn_function, maps\nx_exfil_util::ignore_on_jumpedout );
	array_thread( GetEntArray( "cops", "script_noteworthy" ), ::add_spawn_function, maps\nx_exfil_util::cop_init );

	// SWAT teams with lasers
	array_thread( GetEntArray( "swatvan1", "targetname" ), ::add_spawn_function, maps\nx_exfil_util::enemy_lasers );
	array_thread( GetEntArray( "swatvan1_backup", "targetname" ), ::add_spawn_function, maps\nx_exfil_util::enemy_lasers );
	array_thread( GetEntArray( "market_group1", "targetname" ), ::add_spawn_function, maps\nx_exfil_util::enemy_lasers );
	array_thread( GetEntArray( "market_group2", "targetname" ), ::add_spawn_function, maps\nx_exfil_util::enemy_lasers );
	array_thread( GetEntArray( "market_side", "targetname" ), ::add_spawn_function, maps\nx_exfil_util::enemy_lasers );
	array_thread( GetEntArray( "market_interior_group1", "targetname" ), ::add_spawn_function, maps\nx_exfil_util::enemy_lasers );
	array_thread( GetEntArray( "streets_reinforcements", "targetname" ), ::add_spawn_function, maps\nx_exfil_util::enemy_lasers );
	array_thread( GetEntArray( "street_dudes", "script_noteworthy" ), ::add_spawn_function, maps\nx_exfil_util::enemy_lasers );

	array_thread( GetEntArray( "street_group1", "targetname" ), ::add_spawn_function, maps\nx_exfil_util::enemy_lasers );
	array_thread( GetEntArray( "swat_van_barricade_troops", "targetname" ), ::add_spawn_function, maps\nx_exfil_util::enemy_lasers );
	array_thread( GetEntArray( "barricade_troops_A", "targetname" ), ::add_spawn_function, maps\nx_exfil_util::enemy_lasers );
	array_thread( GetEntArray( "barricade_setup_troops_A", "targetname" ), ::add_spawn_function, maps\nx_exfil_util::enemy_lasers );
}

intro_seq()
{
	maps\nx_exfil_intro::start();
}

intro()
{

	maps\nx_exfil_intro::main();
}


//*******************************************************************
//	MARKET															*
//*******************************************************************
market_start()
{
	// First section of the mission
	maps\nx_exfil_market::start();

	// lets put our player and Baker into the correct places
	player_start = GetEnt( "postintro_player", "targetname" );
	level._player teleport_player( player_start );
	ally_start = GetStruct( "postintro_ally1", "targetname" );
	level.allies[ "ally1" ] forceTeleport( ally_start.origin, ally_start.angles );
}

market_start_dev()
{
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	market_start();
}

market()
{
	//temp music_chk flag
	//flag_set( "music_chk_market" );

	maps\nx_exfil_market::main();

	flag_wait( "market_enc_end" );
}

//*******************************************************************
//	STREET															*
//*******************************************************************
street_start()
{
	// First section of the mission
	maps\nx_exfil_street::start();
}

street_start_dev()
{
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	street_start();
}

street()
{
	//temp music_chk flag
	//flag_set( "music_chk_street" );

	maps\nx_exfil_street::main();
}


//*******************************************************************
//	ALLEY															*
//*******************************************************************
alley_start()
{
	// First section of the mission
	maps\nx_exfil_alley::start();
}

alley()
{
	maps\nx_exfil_alley::main();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
wait_for_spotlight_heli_trigger()
{
	// There are 2 paths the heli can start on
	thread setup_spotlight_heli_intro_path();

	thread setup_spotlight_heli_market_path();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
setup_spotlight_heli_intro_path()
{
	level endon( "start_spotlight_heli_market_path" );
	flag_wait( "start_spotlight_heli_intro_path" );

	thread setup_spotlight_heli( "heli_intro_path" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
setup_spotlight_heli_market_path()
{
	level endon( "start_spotlight_heli_intro_path" );
	flag_wait( "start_spotlight_heli_market_path" );

	thread setup_spotlight_heli( "heli_market_path" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
setup_spotlight_heli( start_path_node_targetname, first_heli )
{
	if ( !IsDefined( first_heli ) )
	{
		first_heli = true;
	}

	// Grab the heli
	//spotlight_heli = spawn_vehicle_from_targetname_and_drive( "littlebird_spotlight" );
	spotlight_heli = spawn_vehicle_from_targetname( "littlebird_spotlight" );
	level._spotlight_heli = spotlight_heli;
	node = GetStruct( start_path_node_targetname, "targetname" );
	spotlight_heli thread vehicle_paths( node );

	spotlight_heli thread maps\nx_exfil_audio::police_bullhorn_vo();

	spotlight_heli thread heli_target_dialogue();

	// Sanity check
	if ( !IsDefined( spotlight_heli ) )
	{
		return;
	}

	spotlight_heli endon( "death" );

	spotlight_heli maps\_vehicle::set_heli_move( "faster" );
	
	// Set up some vars
	spotlight_heli._state = "reveal";
	spotlight_heli._section = "market";
	spotlight_heli._spotTarget_last_known_pos = ( 0, 0, 0 );
	spotlight_heli._default_speed = 18;
	spotlight_heli._evade_health_threshold = 0.9;
	spotlight_heli._num_evasions = 2;
	spotlight_heli._reacquire_player_time = GetTime() + 9000;
	spotlight_heli._focus_ally = false;
	spotlight_heli._damage_fx = "none";

	// Play progressive damage fx
	//spotlight_heli thread spotlight_heli_damage_fx_process();

	// Heli runs away when the player attacks
	spotlight_heli thread spotlight_heli_evasive_think();

	spotlight_heli thread spotlight_heli_on_death();

	spotlight_heli thread spotlight_heli_trigger_death();

	// Initiate pathing
	//spotlight_heli thread maps\_attack_heli::heli_circling_think( "attack_heli_circle_node", 50, maps\_attack_heli::heli_circle_node_choice );
	spotlight_heli gopath();
	spotlight_heli Vehicle_SetSpeed( spotlight_heli._default_speed, 15, 15 );

	// Set up spotlight
	spotlight_heli.eTarget = level._player;
	spotlight_heli maps\_attack_heli::heli_default_target_setup();
	spotlight_heli thread maps\_attack_heli::heli_spotlight_on( "tag_barrel" , false, true );
	spotlight_heli thread maps\_attack_heli::heli_spotlight_aim( ::spotlight_heli_think );

	spotlight_heli thread spotlight_heli_check_vision_set();

	// Slow down the rotation
	spotlight_heli spotlight_heli_update_spotlight_speed( 0.33 );

	if ( first_heli )
	{
		// Point in front of player
		forward = AnglesToForward( level._player.angles );
		forwardfar = vector_multiply( forward, 500 );
		spot_vect = forwardfar + randomvector( 50 );
		spotlight_heli.spotTarget = Spawn( "script_origin", ( level._player.origin + forwardfar ) );
		spotlight_heli maps\_attack_heli::heli_spotlight_destroy_default_targets();
		spotlight_heli maps\_attack_heli::heli_spotlight_create_default_targets( spotlight_heli.spotTarget );
	
		// Path-swapping logic
		spotlight_heli thread spotlight_heli_street_path_1_think();
		//spotlight_heli thread spotlight_heli_street_path_2_think();
	
		// Logic to focus on ally after market section
		//spotlight_heli thread spotlight_heli_focus_ally_think();

		// Heli logic for final encounter
		spotlight_heli thread spotlight_heli_final_encounter_think();
	}

	return spotlight_heli;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_update_spotlight_speed( speed_mult )
{
	self SetTurretRotationSpeedMultiplier( speed_mult );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_street_path_1_think()
{
	self endon( "death" );

	flag_wait( "heli_street_path_1_swap" );

	self vehicle_pathdetach();
	node = GetStruct( "heli_street_path_1", "targetname" );
	self thread vehicle_paths( node );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_street_path_2_think()
{
	self endon( "death" );

	flag_wait( "heli_street_path_2_swap" );

	self vehicle_pathdetach();
	node = GetStruct( "heli_street_path_2", "targetname" );
	self thread vehicle_paths( node );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_check_vision_set()
{
	self endon( "death" );

	vision_swap_time = 0.25;

	while ( 1 )
	{
		if ( maps\_attack_heli::can_see_player( level._player ) )
		{
			pos = self GetTagOrigin( "TAG_FLASH" );
			angles = self GetTagAngles( "TAG_FLASH" );
			forward = AnglesToForward( angles );
	
			eye_vect = ( level._player GetEye() ) - pos;
			eye_vect = VectorNormalize( eye_vect );
	
			angle = acos( VectorDot( forward, eye_vect ) );

			if ( angle < 10 )
			{
				// In spotlight
				vision_set = "nx_exfil_spotlight";
				if ( self._section == "street" )
				{
					vision_set = "nx_exfil_spotlight_2";
				}

				VisionSetNaked( vision_set, vision_swap_time );
			}
			else
			{
				// Not in spotlight
				VisionSetNaked( "nx_exfil", vision_swap_time );
			}
		}
		else
		{
			// Not in spotlight
			VisionSetNaked( "nx_exfil", vision_swap_time );
		}

		wait vision_swap_time;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_final_encounter_think()
{
	flag_wait( "heli_street_path_2_swap" );

	// If previously killed, spawn another
	if ( !IsDefined( self ) )
	{
		spotlight_heli = setup_spotlight_heli( "heli_focus_player_pos", false );
	}
	else
	{
		spotlight_heli = self;
	}

	spotlight_heli._section = "street";

	spotlight_heli endon( "market_enc_end" );

	spotlight_heli thread spotlight_heli_final_reveal();

	spotlight_heli thread spotlight_heli_target_straight_down();

	// Go hide, to give the player a breather
	spotlight_heli vehicle_pathdetach();
	node = GetStruct( "heli_hide_pos", "targetname" );
	spotlight_heli SetVehGoalPos( node.origin, true );

	spotlight_heli waittill( "near_goal" );

	// Point toward player
	spotlight_heli maps\nx_exfil_fx::turn_off_heli_spotlight_fx();
	spotlight_heli SetLookAtEnt( level._player );
	spotlight_heli SetTurretTargetEnt( level._player );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_target_straight_down()
{
	self endon( "market_enc_end" );
	self endon( "near_goal" );
	self endon( "death" );

	self._state = "waiting";
	self spotlight_heli_update_spotlight_speed( 0.33 );
	self.spotTarget = Spawn( "script_origin", ( self.origin * ( 1, 1, 0 ) ) + ( 0, 0, 100 ) );

	while ( 1 )
	{
		wait 0.05;

		self.spotTarget.origin = ( self.origin * ( 1, 1, 0 ) ) + ( 0, 0, 100 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_final_reveal()
{
	self endon( "death" );

	// Wait for trigger
	flag_wait( "market_enc_end" );

	self notify( "market_enc_end" );

	// Point toward player
	self spotlight_heli_update_spotlight_speed( 5.0 );
	self SetLookAtEnt( level._player );
	self SetTurretTargetEnt( level._player );

	// Fly to middle of streen and turn on spotlight
	node = GetStruct( "heli_focus_player_pos", "targetname" );
	self SetVehGoalPos( node.origin, false );
	self thread vehicle_paths( node );


	self waittill( "near_goal" );
	self Vehicle_SetSpeed( self._default_speed, 15, 15 );
	
	self.spotTarget = level._player;
	self maps\nx_exfil_fx::turn_on_heli_spotlight_fx();

	//self._state = "waiting";

	wait 5;
	
	// Do a fly over the player
	self Vehicle_SetSpeed( 25, 15, 15 );
	node = GetStruct( "heli_flyover_pos", "targetname" );
	self SetVehGoalPos( node.origin, true );
	self waittill( "near_goal" );

	// Resume position above street
	self Vehicle_SetSpeed( 20, 15, 15 );
	self spotlight_heli_set_focus_ally();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*spotlight_heli_focus_ally_think()
{
	//self endon( "death" );

	//flag_wait( "market_enc_end" );
	flag_wait( "heli_street_path_2_swap" );

	if ( !IsDefined( self ) )
	{
		self = setup_spotlight_heli( "heli_focus_ally_pos", false );
	}
	
	self spotlight_heli_set_focus_ally();
	self._section = "street";
}*/

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_set_focus_ally()
{
	self endon( "death" );

	self._focus_ally = true;

	// Set up an array of things to look at
	ally = level.allies[ "ally1" ];
	heli_look_at[0] = ally;
	heli_look_at[1] = level._player;
	barricade_riot_spotlight = GetStruct( "barricade_riot_spotlight", "script_noteworthy" );
	heli_look_at[2] = Spawn( "script_origin", barricade_riot_spotlight.origin );
	heli_look_at[2].angles = barricade_riot_spotlight.angles;
	heli_look_at[3] = get_living_ai( "turret_gunner", "script_noteworthy" );

	self.spotTarget = ally;
	self._state = "targeting";

	// Speed up the rotation
	self delayThread( 1.0, ::spotlight_heli_update_spotlight_speed, 5.0 );

	spotlight_heli_set_threatbias( "none" );

	self vehicle_pathdetach();
	node = GetStruct( "heli_focus_ally_pos", "targetname" );
	self SetVehGoalPos( node.origin, false );
	self thread vehicle_paths( node );

	self waittill( "near_goal" );

	self Vehicle_SetSpeed( self._default_speed, 15, 15 );

	while ( 1 )
	{
		if ( self.spotTarget != heli_look_at[2] )
		{
			wait( RandomFloatRange( 3.5, 5.5 ) );
		}
		else
		{
			wait( RandomFloatRange( 1.5, 3.0 ) );
		}

		// First, ensure the turret gunner is still there
		if ( heli_look_at.size > 3 && !IsDefined( heli_look_at[3] ) )
		{
			heli_look_at = array_remove( heli_look_at, heli_look_at[3] );
		}

		// Choose a new target
		self.spotTarget = heli_look_at[ RandomInt( heli_look_at.size ) ];
		self SetLookAtEnt( self.spotTarget );

		if ( maps\_attack_heli::can_see_player( self.spotTarget ) )
		{
			self._spotTarget_last_known_pos = self.spotTarget.origin;
		}
		else if ( self.spotTarget == level._player )
		{
			// Point in front of player
			forward = AnglesToForward( self.spotTarget.angles );
			forwardfar = vector_multiply( forward, 500 );
			spot_vect = forwardfar + randomvector( 50 );

			self._spotTarget_last_known_pos = ( self.spotTarget.origin + spot_vect );
		}

		// Slow down the spotlight
		spotlight_heli_update_spotlight_speed( 0.33 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
heli_target_dialogue()
{
	self endon( "death" );
	flag_wait( "heli_intro_dialogue_complete" );
	
	wait 0.5;
	current_target = undefined;

	while ( 1 )
	{
		if ( isDefined( self.spottarget ) )
		{
			if ( !isDefined( current_target ) || current_target != self.spottarget )
			{
				current_target = self.spottarget;
				if ( isDefined( current_target ) && isPlayer( current_target ) )
				{
					level.baker radio_dialogue( "exf_bak_helo_outofsight" ); // Spotlight's drawing heat!  Get out of sight!
					return; // Only do this dialogue once
				}
			}
		}
		wait 1.0;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*spotlight_heli_damage_fx_process()
{
	self endon( "death" );
	self endon( "crashing" );

	while ( 1 )
	{
		self waittill( "damage", damage, attacker );//, direction_vec, P, type );
		
		curr_health = ( self.health - self.healthbuffer );
		assert( self.script_startinghealth > 0 );
		health_percent = ( curr_health / self.script_startinghealth );

		// Damage FX Checks
		if ( health_percent < 0.75 && health_percent > 0.5 && self._damage_fx == "none" )
		{
			self._damage_fx = "light";

			maps\nx_exfil_fx::spotlight_heli_damage_fx( "light" );
		}
		else if ( health_percent < 0.5 && health_percent > 0.25 && self._damage_fx == "light" )
		{
			self._damage_fx = "med";

			maps\nx_exfil_fx::spotlight_heli_damage_fx( "med" );
		}
		else if ( health_percent < 0.25 && health_percent > 0.0 && self._damage_fx == "med" )
		{
			self._damage_fx = "heavy";

			maps\nx_exfil_fx::spotlight_heli_damage_fx( "heavy" );

			return;
		}

		wait 0.05;
	}
}*/

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_evasive_think()
{
	self endon( "death" );
	self endon( "crashing" );

	while ( 1 )
	{
		// Wait until the player attacks
		self waittill( "damage", damage, attacker );//, direction_vec, P, type );
		
		if ( !IsDefined( attacker ) || !IsPlayer( attacker ) )
		{
			continue;
		}

		// Check evasion health threshold to see if the heli should run away
		curr_health = ( self.health - self.healthbuffer );
		assert( self.script_startinghealth > 0 );
		health_percent = ( curr_health / self.script_startinghealth );

		if ( health_percent < self._evade_health_threshold )
		{
			self._evade_health_threshold -= 0.1;
			self._num_evasions -= 1;

			// Damage FX Checks
			if ( self._damage_fx == "none" )
			{
				self._damage_fx = "light";
	
				maps\nx_exfil_fx::spotlight_heli_damage_fx( "light" );
			}
			else if ( self._damage_fx == "light" )
			{
				self._damage_fx = "med";
	
				maps\nx_exfil_fx::spotlight_heli_damage_fx( "med" );
			}
			else if ( self._damage_fx == "med" )
			{
				self._damage_fx = "heavy";
	
				maps\nx_exfil_fx::spotlight_heli_damage_fx( "heavy" );
			}
		}
		else
		{
			continue;
		}

		// Fly off to the outside (right)
		right = AnglesToRight( self.angles );

		// Magic #'s, 600 insures it goes to a lower position than the flight path
		new_pos = ( ( self.origin + ( right * 5000 ) ) * ( 1, 1, 0 ) ) + ( 0, 0, 600 );

		// Ensure the heli can see the evasion location
		while ( !BulletTracePassed( self.origin, new_pos, false, self ) )
		{
			// Can't see, so wait a bit
			wait 0.25;

			// Recalculate
			right = AnglesToRight( self.angles );
			new_pos = ( ( self.origin + ( right * 5000 ) ) * ( 1, 1, 0 ) ) + ( 0, 0, 600 );
		}
	
		self vehicle_pathdetach();
		self Vehicle_SetSpeed( 85, 30, 30 );
		self SetVehGoalPos( new_pos, true );
		//self SetNearGoalNotifyDist( 300 );
		
		wait RandomIntRange( 4, 8 );

		self Vehicle_SetSpeed( self._default_speed, 15, 15 );

		if ( self._focus_ally )
		{
			ally = level.allies[ "ally1" ];

			node = GetStruct( "heli_focus_ally_pos", "targetname" );
			self SetVehGoalPos( node.origin, false );
			self thread vehicle_paths( node );

			self waittill( "near_goal" );

			self SetLookAtEnt( ally );
		}
		else
		{
			self vehicle_resumepath();

			// Wait until it gets back on the path before starting the logic over again
			self waittill( "near_goal" );
		}

		if ( self._num_evasions <= 0 )
		{
			return;
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_on_death()
{
	self waittill( "death" );

	spotlight_heli_set_threatbias( "none" );

	VisionSetNaked( "nx_exfil", 0.25 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_trigger_death()
{
	self endon( "death" );

	flag_wait( "alley_begin" );

	if ( IsDefined( level._spotlight_heli ) )
	{
		// Fly off and die
		back = AnglesToForward( level._spotlight_heli.angles ) * -1;

		// Magic #'s, 600 insures it goes to a lower position than the flight path
		new_pos = ( ( level._spotlight_heli.origin + ( back * 10000 ) ) * ( 1, 1, 0 ) ) + ( 0, 0, 600 );
	
		level._spotlight_heli vehicle_pathdetach();
		level._spotlight_heli Vehicle_SetSpeed( 100, 40, 40 );
		level._spotlight_heli SetVehGoalPos( new_pos, true );

		level._spotlight_heli waittill( "near_goal" );

		level._spotlight_heli Delete();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_set_threatbias( target )
{
	ally = level.allies[ "ally1" ];

	// Force no threatbias during the last encounter (barricade)
	if ( IsDefined( level._spotlight_heli ) && level._spotlight_heli._focus_ally == true )
	{
		target = "none";
	}

	switch ( target )
	{
		case "player":
			// Set threatbias really high so enemies will target when they are in spotlight
			level._player.threatbias = 1000;
			level._player.attackeraccuracy = 1.3;
	
			if ( IsDefined( ally ) )
			{
				ally.threatbias = 0;
			}

			break;

		case "ally":
			// Set threatbias really high so enemies will target when they are in spotlight
			if ( IsDefined( ally ) )
			{
				ally.threatbias = 1000;
			}

			level._player.threatbias = 0;
			level._player.attackeraccuracy = 0.7;

			break;

		case "none":
			level._player.threatbias = level._default_player_threatbias;
			level._player.attackeraccuracy = 1.0;
			
			if ( IsDefined( ally ) )
			{
				ally.threatbias = 200;
			}

			break;

		default:
			assert( "need to pass in a target to spotlight_heli_set_threatbias" );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_default_targeting()
{
	self endon( "death" );

	iRand = RandomInt( level._spotlight_aim_ents.size );
	self.targetdefault = level._spotlight_aim_ents[ iRand ];
	self.spotTarget = self.targetdefault;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_stop_circling()
{
	self notify( "stop_circling" );
	self notify( "stop_shooting" );
	self.circling = false;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_resume_circling()
{
	self thread maps\_attack_heli::heli_circling_think( "attack_heli_circle_node", 50, maps\_attack_heli::heli_circle_node_choice );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_think()
{
	self endon( "death" );

	while ( 1 )
	{
		wait( RandomFloatRange( 1, 3 ) );

		switch ( self._state )
		{
			case "reveal":
				self thread spotlight_heli_reveal_state();
				break;

			case "searching":
				self thread spotlight_heli_searching_state();
				break;

			case "targeting":
				self thread spotlight_heli_targeting_state();
				break;

			case "reacquire":
				self thread spotlight_heli_reacquire_state();
				break;

			case "waiting":
				// Do nothing
				break;

			default:
				assert( "spotlight heli has invalid state" );
				break;
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_reveal_state()
{
	self endon( "death" );

	if ( GetTime() > self._reacquire_player_time )
	{
		self maps\_attack_heli::heli_spotlight_destroy_default_targets();

		self._state = "searching";
	}
	else
	{
		// Point in front of player
		self maps\_attack_heli::heli_spotlight_destroy_default_targets();
		forward = AnglesToForward( level._player.angles );
		forwardfar = vector_multiply( forward, 500 );
		spot_vect = forwardfar + randomvector( 50 );
		self.spotTarget = Spawn( "script_origin", ( level._player.origin + forwardfar ) );
		self maps\_attack_heli::heli_spotlight_create_default_targets( self.spotTarget );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_searching_state()
{
	self endon( "death" );

	ally = level.allies[ "ally1" ];

	can_see_player = ( ( self._focus_ally == false ) && maps\_attack_heli::can_see_player( level._player ) );
	can_see_ally = ( IsDefined( ally ) && maps\_attack_heli::can_see_player( ally ) );
	target_player = false;
	target_ally = false;

	// Both in line of sight
	if ( can_see_player && can_see_ally )
	{
		// Give player more chance to be targeted (66%)
		iRand = RandomInt( 3 );

		if ( iRand == 2 )
		{
			target_ally = true;
		}
		else
		{
			target_player = true;
		}
	}
	else if ( can_see_player )
	{
		target_player = true;
	}
	else if ( can_see_ally )
	{
		target_ally = true;
	}
	else// otherwise just aim at one of the default targets
	{
		self spotlight_heli_default_targeting();

		spotlight_heli_set_threatbias( "none" );
	}

	if ( target_player )
	{
		self.spotTarget = level._player;
		self._state = "targeting";

		// Speed up the rotation
		self delayThread( 1.0, ::spotlight_heli_update_spotlight_speed, 5.0 );

		spotlight_heli_set_threatbias( "player" );
	}
	else if ( target_ally )
	{
		self.spotTarget = ally;
		self._state = "targeting";

		// Speed up the rotation
		self delayThread( 1.0, ::spotlight_heli_update_spotlight_speed, 5.0 );

		spotlight_heli_set_threatbias( "ally" );
	}
	else
	{
		// Slow down the rotation
		self spotlight_heli_update_spotlight_speed( 0.33 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_targeting_state()
{
	self endon( "death" );
	
	ally = level.allies[ "ally1" ];

	// Stay in this state as long as the heli can still see the target
	if ( IsDefined( self.spotTarget ) && maps\_attack_heli::can_see_player( self.spotTarget ) )
	{
		self._spotTarget_last_known_pos = self.spotTarget.origin;
		//self spotlight_heli_stop_circling();

		// Chance to re-target player
		if ( self._focus_ally == false )
		{
			if ( self.spotTarget != level._player )
			{
				iRand = RandomInt( 4 );
				if ( iRand == 2 )
				{
					if ( maps\_attack_heli::can_see_player( level._player ) )
					{
						self.spotTarget = level._player;
						self._spotTarget_last_known_pos = level._player.origin;

	
						// Slow down the rotation, then delay speed it up
						self spotlight_heli_update_spotlight_speed( 0.75 );
						self delayThread( 0.75, ::spotlight_heli_update_spotlight_speed, 5.0 );
	
						spotlight_heli_set_threatbias( "player" );
					}
				}
			}
			else if ( self.spotTarget != ally ) // Chence to re-target ally
			{
				iRand = RandomInt( 7 );
				if ( iRand == 3 )
				{
					if ( maps\_attack_heli::can_see_player( ally ) )
					{
						self.spotTarget = ally;
						self._spotTarget_last_known_pos = ally.origin;

	
						// Slow down the rotation, then delay speed it up
						self spotlight_heli_update_spotlight_speed( 0.75 );
						self delayThread( 0.75, ::spotlight_heli_update_spotlight_speed, 5.0 );
	
						spotlight_heli_set_threatbias( "ally" );
					}
				}
			}
		}
	}
	else
	{
		self.prevSpotTarget = self.spotTarget;
		self.spotTarget = Spawn( "script_origin", self._spotTarget_last_known_pos );
		self.spotTarget.angles = level._player.angles;
		self._reacquire_player_time = GetTime() + 3000;

		if ( self._focus_ally == false )
		{
			self._reacquire_ally_time = GetTime() + 10000;
		}
		else
		{
			self._reacquire_ally_time = GetTime() + 2500;
		}

		self maps\_attack_heli::heli_spotlight_destroy_default_targets();
		self maps\_attack_heli::heli_spotlight_create_default_targets( self.spotTarget );

		//self spotlight_heli_resume_circling();

		spotlight_heli_set_threatbias( "none" );

		self._state = "reacquire";

		// Slow down the rotation
		self spotlight_heli_update_spotlight_speed( 0.33 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_heli_reacquire_state()
{
	self endon( "death" );

	ally = level.allies[ "ally1" ];

	// When heli loses sight of target, it will sweep the area of target's
	// "last known position", and continue to do so until the target goes beyond
	// a certain proximity.
	if ( IsDefined( self.prevSpotTarget ) && IsDefined( self._spotTarget_last_known_pos ) && Distance( self.prevSpotTarget.origin, self._spotTarget_last_known_pos ) > 500 )
	{
		self maps\_attack_heli::heli_spotlight_destroy_default_targets();

		self spotlight_heli_default_targeting();

		self._state = "searching";
	}
	else if ( ( GetTime() > self._reacquire_player_time ) && maps\_attack_heli::can_see_player( level._player ) )
	{
		self maps\_attack_heli::heli_spotlight_destroy_default_targets();

		self.spotTarget = level._player;
		self._state = "targeting";

		// Speed up the rotation
		self delayThread( 1.0, ::spotlight_heli_update_spotlight_speed, 5.0 );

		spotlight_heli_set_threatbias( "player" );
	}
	else if ( ( GetTime() > self._reacquire_ally_time ) && IsDefined( ally ) && maps\_attack_heli::can_see_player( ally ) )
	{
		self maps\_attack_heli::heli_spotlight_destroy_default_targets();

		self.spotTarget = ally;
		self._state = "targeting";

		// Speed up the rotation
		self delayThread( 1.0, ::spotlight_heli_update_spotlight_speed, 5.0 );

		spotlight_heli_set_threatbias( "ally" );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
#using_animtree( "animated_props" );
animated_flags_logic()
{
	waittillframeend;

	wind_radius = 550.0;

	flags = [];

	flags[0] = GetEnt( "swaying_flag01", "script_noteworthy" );
	origin_swaying_flag01 = GetEnt( "origin_swaying_flag01", "script_noteworthy" );
	flags[0].pos = origin_swaying_flag01.origin * ( 1, 1, 0 );
	flags[0].slow_anim = %nx_pr_exfil_swinging_flag_slow_01;
	flags[0].fast_anim = %nx_pr_exfil_swinging_flag_fast_01;
	flags[0] SetAnim( flags[0].slow_anim, 1, 0, 1 );
	flags[0] SetAnim( flags[0].fast_anim, 0, 0, 1 );

	flags[1] = GetEnt( "swaying_flag02", "script_noteworthy" );
	origin_swaying_flag02 = GetEnt( "origin_swaying_flag02", "script_noteworthy" );
	flags[1].pos = origin_swaying_flag02.origin * ( 1, 1, 0 );
	flags[1].slow_anim = %nx_pr_exfil_swinging_flag_slow_02;
	flags[1].fast_anim = %nx_pr_exfil_swinging_flag_fast_02;
	flags[1] SetAnim( flags[1].slow_anim, 1, 0, 1 );
	flags[1] SetAnim( flags[1].fast_anim, 0, 0, 1 );

	flags[2] = GetEnt( "swaying_flag03", "script_noteworthy" );
	origin_swaying_flag03 = GetEnt( "origin_swaying_flag03", "script_noteworthy" );
	flags[2].pos = origin_swaying_flag03.origin * ( 1, 1, 0 );
	flags[2].slow_anim = %nx_pr_exfil_swinging_flag_slow_03;
	flags[2].fast_anim = %nx_pr_exfil_swinging_flag_fast_03;
	flags[2] SetAnim( flags[2].slow_anim, 1, 0, 1 );
	flags[2] SetAnim( flags[2].fast_anim, 0, 0, 1 );

	flags[3] = GetEnt( "swaying_flag04", "script_noteworthy" );
	origin_swaying_flag04 = GetEnt( "origin_swaying_flag04", "script_noteworthy" );
	flags[3].pos = origin_swaying_flag04.origin * ( 1, 1, 0 );
	flags[3].slow_anim = %nx_pr_exfil_swinging_flag_slow_04;
	flags[3].fast_anim = %nx_pr_exfil_swinging_flag_fast_04;
	flags[3] SetAnim( flags[3].slow_anim, 1, 0, 1 );
	flags[3] SetAnim( flags[3].fast_anim, 0, 0, 1 );

	flags[4] = GetEnt( "swaying_flag06", "script_noteworthy" );
	origin_swaying_flag06 = GetEnt( "origin_swaying_flag06", "script_noteworthy" );
	flags[4].pos = origin_swaying_flag06.origin * ( 1, 1, 0 );
	flags[4].slow_anim = %nx_pr_exfil_swinging_flag_slow_06;
	flags[4].fast_anim = %nx_pr_exfil_swinging_flag_fast_06;
	flags[4] SetAnim( flags[4].slow_anim, 1, 0, 1 );
	flags[4] SetAnim( flags[4].fast_anim, 0, 0, 1 );

	flag_wait( "heli_street_path_2_swap" );

	while ( 1 )
	{
		if ( !IsDefined( level._spotlight_heli ) )
		{
			return;
		}

		wind_src_pos = level._spotlight_heli.origin * ( 1, 1, 0 );

		foreach ( flag in flags )
		{
			dist = Length( wind_src_pos - flag.pos );
			
			if ( dist < wind_radius )
			{
				flag notify( "aggressive" );
				flag thread animated_flag_aggressive();
			}
		}
	
		wait 0.05;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
#using_animtree( "animated_props" );
animated_flag_aggressive()
{
	self endon( "aggressive" );

	self SetAnimKnob( self.fast_anim, 1, 0.25, 1 );
	wait RandomFloatRange( 1.0, 1.2 );

	ramp_down = RandomFloatRange( 1.6, 2.0 );
	self SetAnimKnob( self.slow_anim, 1, ramp_down, 1 );
	wait ramp_down;
}

