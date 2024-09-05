
//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  _chute.gsc -> 	Contains all the routines related with the	**
//								first-person parachuting experience			**
//                                                                          **
//		Use: 	chute_start() starts the parachute sequence					**
//				chute_end() ends the parachute sequence						**
//                                                                          **
//    Created: 10/20/2010													**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main()
{
	// Internal Initialization
	init_chute_variables();
	chute_flag_inits();	
	
        PreCacheShellShock( "parachute_buffeting" );
	
	// Anims
	player_animations();
	legs_animations();
	head_animations();

	//parachute bg sound
	level._ambient_track [ "nx_chute_amb" ] = "ambient_parachute";
}

//*******************************************************************
//                                                                  *
//	SETUP			                                                *
//                                                                  *
//*******************************************************************

// Setup global variables
init_chute_variables()
{
	// const, don't change
	level._TIMESTEP = 0.05;

	// Angular properties:
	level._ang_acceleration = 160.0; // deg/s^2
	level._max_ang_velocity = 150.0; // deg/s
	level._damping_coefficient = 2.0;

	// Linear descent props:
	level._descent_acceleration = 0.0; // in/s^2
	level._max_descent_velocity = 1200.0; // in/s
	level._min_descent_velocity = 77.0; // in/s

	// Linear forward props:
	level._forward_acceleration = 200.0; // in/s^2
	level._max_forward_velocity = 890.0; // in/s
	level._min_forward_velocity = 400.0; // in/s
	level._forward_velocity = level._max_forward_velocity;

	level._forward_brake_deceleration = -200.0; // in/s^2

	// External forces:
	level._explosion_force = 500;
	level._external_acceleration = ( 0, 0, 0 );
	level._external_velocity = ( 0, 0, 0 );

	// Pendular props:
	level._pend_speed_factor = 8.0;
	level._pend_length = 480.0; // 40 ft == 480 in
	level._pend_G = 1200; // 30 m/s^2 ~= 1200 in/s^2
	level._pend_accel_factor = ( level._pend_G / level._max_ang_velocity ); // accel = kw, this is k
	level._pend_damping = 0.15;

	level._pend_brake_accel_factor = ( level._pend_G / ( level._forward_acceleration * level._TIMESTEP * level._pend_speed_factor ) );

	// These should only be set to 0 for debugging purposes
	level._USE_ANIMS = 1;
	level._MOVE_PLAYER = 1;

	// Rate for "lerping" the anims, i.e the percentage of weight change per frame.
	// Valid Range: 0.05 - 1.0
	level._anim_rate_in = 0.15;
	level._anim_rate_out = 0.1;

	level._anim_state = "idle"; // <-- valid: idle, turn, stop, falling, landing
	level._idle_view_clamp = 50;
	level._turn_view_clamp = 40;
	level._stop_view_clamp = 40;
	level._falling_view_clamp = 40;
	level._landing_view_clamp = 2;
	level._view_lerp_time = 0.5;

	level._enable_chute_controls = 1;
	level._landing_sequence = 0;
	level._landing_interrupt = 0;
	level._fail_sequence = 0;

	level._allow_collision_death = 1;

	level._collision_forgiveness_angle = 30.0;

	// HUD
	level._hud_chute_alpha_fade_time_ms = 1000; // ms to fade in
	level._INCHES_PER_METER = 39.3700787;
	level._hud_chute_altimeter_max = ( 100 * level._INCHES_PER_METER ); // 100 m in inches

	// Sound variables, for turning on/off appropriate sounds
	level._audio_turn_lt = 0;
	level._audio_turn_rt = 0;
	level._audio_braking = 0;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// All flag_init() calls
chute_flag_inits()
{
	// These flags will be set when associated keys are pressed during gameplay (good for tutorials)
	flag_init( "_chute.gsc_flag_LT_pressed" );
	flag_init( "_chute.gsc_flag_RT_pressed" );
	flag_init( "_chute.gsc_flag_parachute_active" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "player" );
player_animations()
{
	level._scr_animtree[ "player_rig" ] 						= #animtree;
	level._scr_model[ "player_rig" ] 							= "nx_fp_viewmodel_parachute";

	level._scr_anim[ "player_rig" ][ "idle" ]					= %nx_fp_viewmodel_parachute_idle;
	level._scr_anim[ "player_rig" ][ "parachute_turn_r_idle" ]	= %nx_fp_viewmodel_parachute_turn_r_idle;
	level._scr_anim[ "player_rig" ][ "parachute_turn_l_idle" ]	= %nx_fp_viewmodel_parachute_turn_l_idle;
	level._scr_anim[ "player_rig" ][ "parachute_stop_idle" ]	= %nx_fp_viewmodel_parachute_stop_idle;
	level._scr_anim[ "player_rig" ][ "parachute_falling" ]		= %nx_fp_viewmodel_parachute_falling;
	level._scr_anim[ "player_rig" ][ "parachute_landing" ]		= %nx_fp_viewmodel_parachute_landing; 
	level._scr_anim[ "player_rig" ][ "parachute_buffeting" ]	= %nx_fp_viewmodel_parachute_buffeting;
	level._scr_anim[ "player_rig" ][ "parachute_buffeting_2" ]	= %nx_fp_viewmodel_parachute_buffeting_2;
	level._scr_anim[ "player_rig" ][ "parachute_bump" ]			= %nx_fp_viewmodel_parachute_bump;	   						
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "player" );
legs_animations()
{
	level._scr_animtree[ "legs" ] 							= #animtree;
	level._scr_model[ "legs" ] 								= "nx_us_specops_body_assault_a";

	level._scr_anim[ "legs" ][ "idle" ]						= %nx_tp_parachute_idle;
	level._scr_anim[ "legs" ][ "parachute_turn_r_idle" ]	= %nx_tp_parachute_turn_r_idle;
	level._scr_anim[ "legs" ][ "parachute_turn_l_idle" ]	= %nx_tp_parachute_turn_l_idle;
	level._scr_anim[ "legs" ][ "parachute_stop_idle" ]		= %nx_tp_parachute_stop_idle;
	level._scr_anim[ "legs" ][ "parachute_falling" ]		= %nx_tp_parachute_falling;
	level._scr_anim[ "legs" ][ "parachute_landing" ]		= %nx_tp_parachute_landing;
	level._scr_anim[ "legs" ][ "parachute_buffeting" ]		= %nx_tp_parachute_buffeting;
	level._scr_anim[ "legs" ][ "parachute_buffeting_2" ]	= %nx_tp_parachute_buffeting_2;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "player" );
head_animations()
{
	level._scr_animtree[ "head" ] 							= #animtree;
	level._scr_model[ "head" ]								= "nx_head_us_army_a";
}

//*******************************************************************
//                                                                  *
// MAIN FUNCTIONALITY SCRIPTS	                                    *
//                                                                  *
//*******************************************************************
chute_start()
{
	flag_set( "_chute.gsc_flag_parachute_active" );

	parachute_player_constraints();

	parachute_player_setup();

	thread parachute_input_and_motion();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_hud_bootup( skip_wait, chute_light )
{
	if ( !IsDefined( skip_wait ))
	{
		// wait the amount of time that was taken up by the bootup movie
		wait 6.0;
	}
	
	SetSavedDvar( "hud_chute_alpha_fade_time_ms", level._hud_chute_alpha_fade_time_ms );

	// Calculate the altimeter maximum with various levels of resolution depending on starting altitude
	player_y_in_meters = ( level._player.origin[2] / level._INCHES_PER_METER );
	resolution = 25.0;
	if ( player_y_in_meters < 500.0 && player_y_in_meters > 250.0 )
	{
		resolution = 50.0;
	}
	else if ( player_y_in_meters > 500.0 )
	{
		resolution = 100.0;
	}

	max_alt_meters = floor( ( player_y_in_meters + resolution ) / resolution ) * resolution;
	level._hud_chute_altimeter_max = ( max_alt_meters * level._INCHES_PER_METER ); // in inches

	SetSavedDvar( "hud_chute_altimeter_max", level._hud_chute_altimeter_max );

	if ( !IsDefined( chute_light ))
	{
		SetSavedDvar( "hud_chute_active", 1 );
	}
	else
	{
		SetSavedDvar( "hud_chute_altimeter_active", 1 );
		SetSavedDvar( "hud_chute_compass_active", 1 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_player_constraints()
{
	level._player.disableReload = true;
	level._player DisableWeapons();
	level._player DisableOffhandWeapons();
	level._player DisableWeaponSwitch();

	level._player AllowCrouch( false );
	level._player AllowJump( false );
	//level._player AllowLean( false );
	level._player AllowMelee( false );
	level._player AllowProne( false );
	level._player AllowSprint( false );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_player_setup()
{
	// Player Rig ---
	player_rig = spawn_anim_model( "player_rig", level._player.origin );
	level.player_rig = player_rig;
	player_rig.angles = level._player.angles;
	//player_rig hide();

	// Play sounds
	//thread maps\_utility::set_ambient( "nx_chute_amb" );
	//level._player PlaySound( "parachute_deploy" );
	//give player a node to play loop sounds on
	level._chute_sfx = Spawn( "script_origin", level._player.origin );
	level._chute_sfx LinkTo( level._player );

	// Cannot animate & move via script the player rig at the same time, so spawn a tag_origin
	player_mover = spawn_tag_origin();
	level.player_mover = player_mover;
	player_mover.origin = level._player.origin;
	player_mover.angles = level._player.angles;
	player_rig LinkTo( player_mover );

	// This call constrains camera movement as well as linking
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, level._idle_view_clamp, level._idle_view_clamp, level._idle_view_clamp, level._idle_view_clamp, true, true );
	level._player SetRelinkPlayerFlag( 1 );
	thread wait_and_reset_relink_player_flag();

	//player_rig show();

	// Legs ---
	legs = spawn_anim_model( "legs", level._player.origin );
	level.legs = legs;
	//legs hide();
	legs.angles = level._player.angles;
	legs LinkTo( player_rig, "tag_origin", ( -5, 0, -5 ), ( 0, 0, 0 ) );
	//legs show();

	// Head ---
	head = spawn_anim_model( "head", level._player GetEye() );
	level.head = head;
	//head hide();
	head.angles = level._player.angles;
	head LinkTo( player_rig, "tag_torso", ( -4, 0, -14 ), ( -90, 0, -90 ) );
	//head show();
/*	
	player_anim_node = GetEnt( "playerstart_parachute_jump", "targetname" );
	player_anim_node anim_single_solo( player_rig, "parachute_jump" );
	//player_rig ClearAnim( %root, 0 );
	player_rig SetAnim( level._scr_anim[ "player_rig" ][ "parachute_jump" ], 1, level._TIMESTEP, 1 );
	//level._player notify( "notify_player_jump_anim_complete" );
	player_rig DumpAnims();
*/

	if ( level._USE_ANIMS == 1 )
	{
		// Begin with idle anims
		level.player_rig SetAnimKnob( level._scr_anim[ "player_rig" ][ "idle" ], 1, 0, 1 );
		level.legs SetAnimKnob( level._scr_anim[ "legs" ][ "idle" ], 1, 0, 1 );
		
		// Init anim lerp vars
		level.player_rig.idle_weight_curr = 1;
		level.player_rig.turn_l_idle_weight_curr = 0;
		level.player_rig.turn_r_idle_weight_curr = 0;
		level.player_rig.stop_idle_weight_curr = 0;
		level.player_rig.buffeting_weight_curr = 0;
		level.player_rig.buffeting_2_weight_curr = 0;
	} 
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
wait_and_reset_relink_player_flag()
{
	// wait a frame
	wait 0.05;

	// reset
	level._player SetRelinkPlayerFlag( 0 );

	level notify( "player_relink_complete" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_input_and_motion()
{
	level.player_rig endon( "death" );

	// Physics variables
	absolute_pos = level.player_rig.origin;
	absolute_angles = level.player_rig.angles;
	angular_accel = 0.0;
	angular_velocity = 0.0;
	descent_velocity = level._min_descent_velocity;
	forward_accel = level._forward_acceleration;
	pendular_accel = 0.0;
	pendular_omega = 0.0;
	pendular_theta = 0.0;
	pendular_brake_accel = 0.0;
	pendular_brake_omega = 0.0;
	pendular_brake_theta = 0.0;

	delta_forward_velocity = 0;

	external_accel = level._external_acceleration;
	delta_external_velocity = ( 0, 0, 0 );

	// Player input (LT/RT) will affect not only yaw, but descent speed as well
	while ( 1 )
	{
		flag_clear( "_chute.gsc_flag_LT_pressed" );
		flag_clear( "_chute.gsc_flag_RT_pressed" );

		forward_accel = level._forward_acceleration;

		external_accel = level._external_acceleration;

		turning_left = 0;
		turning_right = 0;

		// Detect player button presses
		if ( level._enable_chute_controls )
		{
			if( level._ps3 || level._xenon )
			{
				if ( level._player AdsButtonPressed() )
				{
					turning_left = 1;
				}

				if ( level._player AttackButtonPressed() )
				{
					turning_right = 1;
				}
			}
			else // PC
			{
				if ( level._player ButtonPressed( "MOUSE1" ) )
				{
					turning_left = 1;
				}

				if ( level._player ButtonPressed( "MOUSE2" ) )
				{
					turning_right = 1;
				}
			}
		}

		if ( turning_left )
		{
			flag_set( "_chute.gsc_flag_LT_pressed" );

			if ( turning_right )
			{
				flag_set( "_chute.gsc_flag_RT_pressed" );

				angular_accel = 0.0;

				if ( level._landing_sequence == 0 )
				{
					forward_accel = level._forward_brake_deceleration;
				}

				thread parachute_stop_anims();

				if ( level._anim_state != "stop" && level._anim_state != "falling" && level._anim_state != "landing" )
				{
					// lerp
					level._player LerpViewAngleClamp( level._view_lerp_time, level._view_lerp_time, 0, level._stop_view_clamp, level._stop_view_clamp, level._stop_view_clamp, level._stop_view_clamp );
					level._anim_state = "stop";
				}

				if ( level._audio_turn_lt == 1 )
				{
					level._chute_sfx StopLoopSound( "parachute_turn_loop" );
					level._audio_turn_lt = 0;
				}
				if ( level._audio_turn_rt == 1 )
				{
					level._chute_sfx StopLoopSound( "parachute_turn_loop" );
					level._audio_turn_rt = 0;
				}
				if ( level._audio_braking == 0 )
				{
					level._player PlaySound( "parachute_brake" );
					level._chute_sfx PlayLoopSound( "parachute_brake_loop" );
					level._audio_braking = 1;
				}
			}
			else
			{
				angular_accel = level._ang_acceleration;

				thread parachute_L_anims();

				if ( level._anim_state != "turn" && level._anim_state != "falling" && level._anim_state != "landing" )
				{
					// lerp
					level._player LerpViewAngleClamp( level._view_lerp_time, level._view_lerp_time, 0, level._turn_view_clamp, level._turn_view_clamp, level._turn_view_clamp, level._turn_view_clamp );
					level._anim_state = "turn";
				}

				if ( level._audio_turn_lt == 0 )
				{
					level._player PlaySound( "parachute_turn_lt" );
					level._chute_sfx PlayLoopSound( "parachute_turn_loop" );
					level._audio_turn_lt = 1;
				
				}
				if ( level._audio_braking == 1 )
				{
					level._chute_sfx StopLoopSound( "parachute_brake_loop" );
					level._audio_braking = 0;
				
				}
			}
		}
		else if ( turning_right )
		{
			flag_set( "_chute.gsc_flag_RT_pressed" );

			angular_accel = ( -1 * level._ang_acceleration );

			thread parachute_R_anims();

			if ( level._anim_state != "turn" && level._anim_state != "falling" && level._anim_state != "landing" )
			{
				// lerp
				level._player LerpViewAngleClamp( level._view_lerp_time, level._view_lerp_time, 0, level._turn_view_clamp, level._turn_view_clamp, level._turn_view_clamp, level._turn_view_clamp );
				level._anim_state = "turn";
			}

			if ( level._audio_turn_rt == 0 )
			{
				level._player PlaySound( "parachute_turn_rt" );
				level._chute_sfx PlayLoopSound( "parachute_turn_loop" );
				level._audio_turn_rt = 1;
			
			}
			if ( level._audio_braking == 1 )
			{
				level._chute_sfx StopLoopSound( "parachute_brake_loop" );
				level._audio_braking = 0;
			
			}
		}
		else // Nothing pressed, blend back to idle
		{
			angular_accel = 0.0;

			thread parachute_idle_anims();

			if ( level._anim_state != "idle" && level._anim_state != "falling" && level._anim_state != "landing" )
			{
				// lerp
				level._player LerpViewAngleClamp( level._view_lerp_time, level._view_lerp_time, 0, level._idle_view_clamp, level._idle_view_clamp, level._idle_view_clamp, level._idle_view_clamp );
				level._anim_state = "idle";
			}

			if ( level._audio_turn_lt == 1 )
			{
				level._chute_sfx StopLoopSound( "parachute_turn_loop" );
				level._audio_turn_lt = 0;
			
			}
			if ( level._audio_turn_rt == 1 )
			{
				level._chute_sfx StopLoopSound( "parachute_turn_loop" );
				level._audio_turn_rt = 0;
			
			}
			if ( level._audio_braking == 1 )
			{
				level._chute_sfx StopLoopSound( "parachute_brake_loop" );
				level._audio_braking = 0;
			
			}
		}

		// Rotational aspects ---

		// w = w0 + at
		angular_velocity += angular_accel * level._TIMESTEP;

		// clamp angular velocity
		if ( angular_velocity > level._max_ang_velocity )
		{
			angular_velocity = level._max_ang_velocity;
		}
		else if ( angular_velocity < ( -1 * level._max_ang_velocity ) )
		{
			angular_velocity = ( -1 * level._max_ang_velocity );
		}

		// air resistance (damping)
		// dv = -kvdt
		angular_velocity += ( ( -1 * level._damping_coefficient ) * angular_velocity * level._TIMESTEP );

		// apply
		absolute_angles = ( absolute_angles + ( ( 0, 1, 0 ) * angular_velocity * level._TIMESTEP ) );
		// End Rotational aspects ---

		// Pendular ---
		// acceleration is comprised of 2 tangential components: one from linear acceleration, one from gravity
		cos_theta = Cos( pendular_theta );
		sin_theta = Sin( pendular_theta );
		lin_accel_tan = ( ( level._pend_accel_factor * angular_velocity ) * cos_theta );
		grav_tan = ( level._pend_G * sin_theta );

		pendular_accel = ( ( lin_accel_tan - grav_tan ) / level._pend_length );
		pendular_omega += pendular_accel * level._TIMESTEP * level._pend_speed_factor;

		// damping
		pendular_omega += ( ( -1 * level._pend_damping ) * pendular_omega * level._TIMESTEP * level._pend_speed_factor );
		pendular_theta += pendular_omega * level._TIMESTEP * level._pend_speed_factor;

		pend_offset_x = ( AnglesToRight( level.player_mover.angles ) * ( level._pend_length * ( sin_theta ) ) );
		pend_offset_y = ( ( 0, 0, 1 ) * ( level._pend_length * ( 1 - cos_theta ) ) );
		
		// pendular motion for braking
		cos_brake_theta = Cos( pendular_brake_theta );
		sin_brake_theta = Sin( pendular_brake_theta );
		lin_brake_accel_tan = ( ( level._pend_brake_accel_factor * delta_forward_velocity ) * cos_brake_theta );
		grav_brake_tan = ( level._pend_G * sin_brake_theta );

		pendular_brake_accel = ( ( lin_brake_accel_tan - grav_brake_tan ) / level._pend_length );
		pendular_brake_omega += pendular_brake_accel * level._TIMESTEP * level._pend_speed_factor;

		// damping
		pendular_brake_omega += ( ( -1 * level._pend_damping ) * pendular_brake_omega * level._TIMESTEP * level._pend_speed_factor );
		pendular_brake_theta += pendular_brake_omega * level._TIMESTEP * level._pend_speed_factor;

		pend_brake_offset_x = ( -1 * AnglesToForward( level.player_mover.angles ) * ( level._pend_length * ( sin_brake_theta ) ) );
		pend_brake_offset_y = ( ( 0, 0, 1 ) * ( level._pend_length * ( 1 - cos_brake_theta ) ) );
		// End Pendular ---

		// Descent ---
		
		// v = v0 + at
		descent_velocity += level._descent_acceleration * level._TIMESTEP;

		// clamp descent velocity
		if ( descent_velocity > level._max_descent_velocity )
		{
			descent_velocity = level._max_descent_velocity;
		}
		else if ( descent_velocity < level._min_descent_velocity )
		{
			descent_velocity = level._min_descent_velocity;
		}

		descent_offset = ( descent_velocity * level._TIMESTEP * ( 0, 0, -1 ) );
		// End Descent ---

		// Forward ---
		// v = v0 + at
		delta_forward_velocity = forward_accel * level._TIMESTEP;
		level._forward_velocity += delta_forward_velocity;

		// clamp forward velocity
		if ( level._forward_velocity > level._max_forward_velocity )
		{
			level._forward_velocity = level._max_forward_velocity;
			delta_forward_velocity = 0;
		}
		else if ( !level._landing_sequence && level._forward_velocity < level._min_forward_velocity )
		{
			level._forward_velocity = level._min_forward_velocity;
			delta_forward_velocity = 0;
		}
		else if ( level._landing_sequence && level._forward_velocity < 0 )
		{
			level._forward_velocity = 0.0;
			delta_forward_velocity = 0;
		}	

		forward_offset = ( AnglesToForward( absolute_angles ) * level._TIMESTEP * level._forward_velocity );
		// End Forward ---

		// External Forces ---
		delta_external_velocity = external_accel * level._TIMESTEP;
		level._external_velocity += delta_external_velocity;
		external_offset = ( level._external_velocity * level._TIMESTEP );
		// End External Forces ---

		// Now apply movement
		if ( level._MOVE_PLAYER )
		{
			old_pos = level.player_mover.origin;

			absolute_pos += ( descent_offset + forward_offset + external_offset );
			level.player_mover.angles = ( absolute_angles + ( ( 0, 0, -1 ) * pendular_theta ) + ( ( 1, 0, 0 ) * pendular_brake_theta ) );

			new_pos = absolute_pos + pend_offset_x + pend_offset_y + pend_brake_offset_x + pend_brake_offset_y;

			// Need to check for colliding with things (fail condition)
			coll_info = PlayerPhysicsTraceExtraInfo( old_pos, new_pos );
			collide_pos = coll_info["position"];

			if ( !f3D_vectors_equal( collide_pos, new_pos ) )
			{
				//pos_delta = collide_pos - new_pos;
				//absolute_pos += pos_delta;
				//level.player_mover.origin = collide_pos;
				
				//thread parachute_fail_sequence2();

				//return;

				// This gives collision info (normal, surface type, etc.)
				//coll_info = BulletTrace( old_pos, new_pos, false, level.player_mover );

				// We only want to collide with surfaces
				if ( coll_info["surfacetype"] != "none" )
				{
					death = 0;

					// Calculate the offset to not allow interpenetration
					dot_result = VectorDot( collide_pos - new_pos, coll_info["normal"] );

					if ( dot_result > level._collision_forgiveness_angle )
					{
						death = 1;
					}

					ip_offset = dot_result * coll_info["normal"];

					resolved_pos = new_pos + ip_offset + coll_info["normal"];
	
					// Iterate a 2nd time
					coll_info_2 = PlayerPhysicsTraceExtraInfo( collide_pos, resolved_pos );
					collide_pos_2 = coll_info_2["position"];

					if ( !f3D_vectors_equal( collide_pos_2, resolved_pos ) )
					{
						// Apply offsets
						//absolute_pos += ( collide_pos_2 - new_pos );
						//level.player_mover.origin = collide_pos_2;

						//coll_info_2 = BulletTrace( collide_pos, resolved_pos, false, level.player_mover );

						if ( coll_info_2["surfacetype"] != "none" )
						{
							dot_result_2 = VectorDot( collide_pos_2 - resolved_pos, coll_info_2["normal"] );

							ip_offset_2 = dot_result_2 * coll_info_2["normal"];
							
							resolved_pos_2 = resolved_pos + ip_offset_2 + coll_info_2["normal"];

							// Iterate a 3rd time
							collide_pos_3 = PlayerPhysicsTrace( collide_pos_2, resolved_pos_2 );
		
							if ( !f3D_vectors_equal( collide_pos_3, resolved_pos_2 ) )
							{
								// Apply offsets
								absolute_pos += ( collide_pos_3 - new_pos );
								level.player_mover.origin = collide_pos_3;
							}
							else
							{
								// Apply offsets
								absolute_pos += ip_offset_2;
								level.player_mover.origin = resolved_pos_2;
							}
						}
						else
						{
							// Apply offsets
							absolute_pos += ip_offset;
							level.player_mover.origin = resolved_pos;
						}
					}
					else
					{
						// Apply offsets
						absolute_pos += ip_offset;
						level.player_mover.origin = resolved_pos;
					}

					// Kick in gravity & start fail sequence
					if ( !level._landing_sequence && level._allow_collision_death && death )
					{
						level._descent_acceleration = level._pend_G;
						thread parachute_fail_sequence();
					}
					else if ( level._landing_sequence && death && !level._landing_interrupt )
					{
						thread parachute_landing_bump();
					}
				}
				else
				{
					level.player_mover.origin = new_pos;
				}
			}
			else
			{
				level.player_mover.origin = new_pos;
			}
		}

		thread parachute_lerp_anims();

		wait( level._TIMESTEP );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*parachute_fail_sequence2()
{
	if ( level._fail_sequence )
	{
		return;
	}

	level._fail_sequence = 1;

	level._anim_state = "falling";

	// Remove player control
	//level._enable_chute_controls = 0;
	
	// Death anims
	//level._player shellshock( "default", 3 );
	//level._USE_ANIMS = 0;
	//thread parachute_falling_anims();

	//level.player_rig Unlink();
	//level.player_mover Delete();
	level._player Unlink();

	//chute_destroy_assets();
	level._player SetViewmodel( "nx_fp_viewmodel_parachute" );
	level._player ShowViewModel();


	//thread parachute_link_to_player();
	//level.player_rig.origin = level._player.origin;
	//level.player_rig LinkTo( level._player );
	//level._player Attach( "nx_fp_viewmodel_parachute" );
	
	//level.player_rig thread manual_linkto( level._player );

	//wait 1.5;

	// Now Fail
	//level._player PlaySound( "parachute_impact" );
	//SetDvar( "ui_deadquote", "(PLACEHOLDER) It's Bad to Run Into Things!" );
	//level notify( "notify_parachute_failure" );
	//maps\_utility::missionFailedWrapper();
}

parachute_link_to_player()
{
	level._player endon( "death" );

	while ( 1 )
	{
		//thread parachute_idle_anims();
		//thread parachute_lerp_anims();

		wait 0.05;
	}
}*/

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_fail_sequence( fail_message )
{
	if ( level._fail_sequence )
	{
		return;
	}

	level._fail_sequence = 1;

	SetSavedDvar( "hud_chute_active", 0 );

	// lerp
	level._player LerpViewAngleClamp( level._view_lerp_time, level._view_lerp_time, 0, level._falling_view_clamp, level._falling_view_clamp, level._falling_view_clamp, level._falling_view_clamp );
	level._anim_state = "falling";

	// Remove player control
	level._enable_chute_controls = 0;
	
	// Death anims
	level._player shellshock( "default", 3 );
	level._USE_ANIMS = 0;
	thread parachute_falling_anims();
	
	thread parachute_check_for_ground_damage();

	wait 1.5;

	// Now Fail
	level._player PlaySound( "parachute_impact" );
	if( isdefined( fail_message))
	{
		SetDvar( "ui_deadquote", fail_message );   
	}
	else
	{
		SetDvar( "ui_deadquote", &"_CHUTE_FAIL_COLLISION" );
	}
	level notify( "notify_parachute_failure" );
	maps\_utility::missionFailedWrapper();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_check_for_ground_damage()
{
	GROUND_CHECK_OFFSET = 4;

	while ( 1 )
	{
		ground_pos = GetGroundPosition( level.player_mover.origin, 0, 1000.0, 64.0, true );

		if ( IsDefined( ground_pos ) )
		{
			if ( abs( ground_pos[2] - level.player_mover.origin[2] ) < GROUND_CHECK_OFFSET )
			//if ( level._player IsOnGround() ) <-- This doesn't work with player linked to object it seems
			{
				RadiusDamage( level._player.origin, 500, 500, 500 );
				
				chute_destroy_assets();
	
				return;
			}
		}

		wait 0.05;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_buffeting( explosion_origin, anim_name )
{
	level._player shellshock( "parachute_buffeting", 1 );

	level._USE_ANIMS = 0;

	parachute_buffeting_anims( anim_name );

	thread parachute_buffeting_anim_cleanup( anim_name );

	// Disable all the forward physics
	/*temp_forward_acceleration = level._forward_acceleration;
	temp_max_forward_velocity = level._max_forward_velocity;
	temp_min_forward_velocity = level._min_forward_velocity;
	temp_forward_velocity = level._forward_velocity;

	level._forward_acceleration = 0.0;
	level._max_forward_velocity = 0.0;
	level._min_forward_velocity = 0.0;
	level._forward_velocity = 0.0;*/

	// Disable collision death
	level._allow_collision_death = 0;

	// Apply push velocity
	explosion_vector = ( level._player.origin - explosion_origin );
	dist = Length( explosion_vector );
	explosion_vector_norm = VectorNormalize( explosion_vector );

	// The magic numbers here are just to get a "normalized" application force with the inverse of the distance
	level._external_velocity = explosion_vector_norm * ( 1000.0 / dist ) * level._explosion_force;

	// Apply damping force in opposite direction to push
	level._external_acceleration = ( level._external_velocity * -0.5 );

	// Wait until the push velocity is zero
	EPSILON = 0.01;
	while ( LengthSquared( level._external_velocity ) > EPSILON )
	{
		//println( Length( level._external_velocity ) );
		wait 0.05;
	}

	// Reset external forces
	level._external_velocity = ( 0, 0, 0 );
	level._external_acceleration = ( 0, 0, 0 );

	// Reset forward physics
	/*level._forward_acceleration = temp_forward_acceleration;
	level._max_forward_velocity = temp_max_forward_velocity;
	level._min_forward_velocity = temp_min_forward_velocity;
	//level._forward_velocity = temp_forward_velocity;*/

	// Reenable collision death
	level._allow_collision_death = 1;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_buffeting_anim_cleanup( anim_name )
{
	level.player_rig endon( "death" );

	anim_time = 0.0;

	// We need to let it play through until a certain point before turning all other anims on
	if ( !IsDefined( anim_name ) || anim_name == "parachute_buffeting" )
	{
		anim_time = level.player_rig GetAnimTime( %nx_fp_viewmodel_parachute_buffeting );
	}
	else
	{
		anim_time = level.player_rig GetAnimTime( %nx_fp_viewmodel_parachute_buffeting_2 );
	}

	while ( anim_time < 0.66 )
	{
		if ( !IsDefined( anim_name ) || anim_name == "parachute_buffeting" )
		{
			anim_time = level.player_rig GetAnimTime( %nx_fp_viewmodel_parachute_buffeting );
		}
		else
		{
			anim_time = level.player_rig GetAnimTime( %nx_fp_viewmodel_parachute_buffeting_2 );
		}

		wait 0.05;
	}

	level.player_rig.idle_weight_curr = 0;
	level.player_rig.turn_l_idle_weight_curr = 0;
	level.player_rig.turn_r_idle_weight_curr = 0;
	level.player_rig.stop_idle_weight_curr = 0;

	level._USE_ANIMS = 1;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_landing_bump()
{
	level notify( "chute_land_interrupt" );

	level._landing_interrupt = 1;

	level._forward_acceleration = 0.0;
	level._forward_velocity = 0.0;

	blend_time = 0.3; // 4 frames (0.05 per frame)

	level._player shellshock("parachute_buffeting", 1.25);
	quakeobj = spawn( "script_origin", level._player.origin );
	quakeobj PlayRumbleOnEntity( "artillery_rumble" );

	level.player_rig SetAnimKnob( level._scr_anim[ "player_rig" ][ "parachute_bump" ], 1, blend_time, 1 );

	while ( 1 )
	{
		// Finish the chute_end as soon as the anim is complete
		curr_time = level.player_rig GetAnimTime( level._scr_anim[ "player_rig" ][ "parachute_bump" ] );
		if ( curr_time >= 0.98 )
		{
			level._player notify( "landing_anim_complete" );
			break;
		}

		wait( 0.05 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_lerp_anims()
{
	if ( level._USE_ANIMS == 0 )
	{
		return;
	}

	level.player_rig SetAnim( level._scr_anim[ "player_rig" ][ "idle" ], level.player_rig.idle_weight_curr, level._TIMESTEP, 1 );
	level.legs SetAnim( level._scr_anim[ "legs" ][ "idle" ], level.player_rig.idle_weight_curr, level._TIMESTEP, 1 );

	level.player_rig SetAnim( level._scr_anim[ "player_rig" ][ "parachute_turn_l_idle" ], level.player_rig.turn_l_idle_weight_curr, level._TIMESTEP, 1 );
	level.legs SetAnim( level._scr_anim[ "legs" ][ "parachute_turn_l_idle" ], level.player_rig.turn_l_idle_weight_curr, level._TIMESTEP, 1 );

	level.player_rig SetAnim( level._scr_anim[ "player_rig" ][ "parachute_turn_r_idle" ], level.player_rig.turn_r_idle_weight_curr, level._TIMESTEP, 1 );
	level.legs SetAnim( level._scr_anim[ "legs" ][ "parachute_turn_r_idle" ], level.player_rig.turn_r_idle_weight_curr, level._TIMESTEP, 1 );

	level.player_rig SetAnim( level._scr_anim[ "player_rig" ][ "parachute_stop_idle" ], level.player_rig.stop_idle_weight_curr, level._TIMESTEP, 1 );
	level.legs SetAnim( level._scr_anim[ "legs" ][ "parachute_stop_idle" ], level.player_rig.stop_idle_weight_curr, level._TIMESTEP, 1 );

	level.player_rig SetAnim( level._scr_anim[ "player_rig" ][ "parachute_buffeting" ], level.player_rig.buffeting_weight_curr, level._TIMESTEP, 1 );
	level.legs SetAnim( level._scr_anim[ "legs" ][ "parachute_buffeting" ], level.player_rig.buffeting_weight_curr, level._TIMESTEP, 1 );

	level.player_rig SetAnim( level._scr_anim[ "player_rig" ][ "parachute_buffeting_2" ], level.player_rig.buffeting_2_weight_curr, level._TIMESTEP, 1 );
	level.legs SetAnim( level._scr_anim[ "legs" ][ "parachute_buffeting_2" ], level.player_rig.buffeting_2_weight_curr, level._TIMESTEP, 1 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_idle_anims( time )
{
	if ( level._USE_ANIMS == 0 )
	{
		return;
	}
	
	// curr = curr + ( target - curr ) * rate
	level.player_rig.idle_weight_curr += ( 1.0 - level.player_rig.idle_weight_curr ) * level._anim_rate_in;
	level.player_rig.turn_l_idle_weight_curr += ( 0.0 - level.player_rig.turn_l_idle_weight_curr ) * level._anim_rate_in;
	level.player_rig.turn_r_idle_weight_curr += ( 0.0 - level.player_rig.turn_r_idle_weight_curr ) * level._anim_rate_in;
	level.player_rig.stop_idle_weight_curr += ( 0.0 - level.player_rig.stop_idle_weight_curr ) * level._anim_rate_in; 
	level.player_rig.buffeting_weight_curr += ( 0.0 - level.player_rig.buffeting_weight_curr ) * level._anim_rate_in;
	level.player_rig.buffeting_2_weight_curr += ( 0.0 - level.player_rig.buffeting_2_weight_curr ) * level._anim_rate_in;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_L_anims()
{
	if ( level._USE_ANIMS == 0 )
	{
		return;
	}

	// curr = curr + ( target - curr ) * rate
	level.player_rig.turn_l_idle_weight_curr += ( 1.0 - level.player_rig.turn_l_idle_weight_curr ) * level._anim_rate_out;
	level.player_rig.idle_weight_curr += ( 0.0 - level.player_rig.idle_weight_curr ) * level._anim_rate_out;
	level.player_rig.turn_r_idle_weight_curr += ( 0.0 - level.player_rig.turn_r_idle_weight_curr ) * level._anim_rate_out;
	level.player_rig.stop_idle_weight_curr += ( 0.0 - level.player_rig.stop_idle_weight_curr ) * level._anim_rate_out;
	level.player_rig.buffeting_weight_curr += ( 0.0 - level.player_rig.buffeting_weight_curr ) * level._anim_rate_out;
	level.player_rig.buffeting_2_weight_curr += ( 0.0 - level.player_rig.buffeting_2_weight_curr ) * level._anim_rate_out;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_R_anims()
{
	if ( level._USE_ANIMS == 0 )
	{
		return;
	}

	// curr = curr + ( target - curr ) * rate
	level.player_rig.turn_r_idle_weight_curr += ( 1.0 - level.player_rig.turn_r_idle_weight_curr ) * level._anim_rate_out;
	level.player_rig.idle_weight_curr += ( 0.0 - level.player_rig.idle_weight_curr ) * level._anim_rate_out;
	level.player_rig.turn_l_idle_weight_curr += ( 0.0 - level.player_rig.turn_l_idle_weight_curr ) * level._anim_rate_out;
	level.player_rig.stop_idle_weight_curr += ( 0.0 - level.player_rig.stop_idle_weight_curr ) * level._anim_rate_out;
	level.player_rig.buffeting_weight_curr += ( 0.0 - level.player_rig.buffeting_weight_curr ) * level._anim_rate_out;
	level.player_rig.buffeting_2_weight_curr += ( 0.0 - level.player_rig.buffeting_2_weight_curr ) * level._anim_rate_out;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_falling_anims()
{
	level.player_rig SetAnimKnob( level._scr_anim[ "player_rig" ][ "parachute_falling" ], 1, 0.5, 1 );
	level.legs SetAnimKnob( level._scr_anim[ "legs" ][ "parachute_falling" ], 1, 0.5, 1 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_landing_anims()
{
	level.player_rig SetAnimKnob( level._scr_anim[ "player_rig" ][ "parachute_landing" ], 1, 0.5, 1 );
	level.legs SetAnimKnob( level._scr_anim[ "legs" ][ "parachute_landing" ], 1, 0.5, 1 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_buffeting_anims( anim_name )
{
	if ( !IsDefined( anim_name ) || anim_name == "parachute_buffeting" )
	{
		level.player_rig SetAnimKnob( level._scr_anim[ "player_rig" ][ "parachute_buffeting" ], 1, 0.5, 1 );
		level.legs SetAnimKnob( level._scr_anim[ "legs" ][ "parachute_buffeting" ], 1, 0.5, 1 );
	
		level.player_rig.buffeting_weight_curr = 1.0;
	}
	else
	{
		level.player_rig SetAnimKnob( level._scr_anim[ "player_rig" ][ "parachute_buffeting_2" ], 1, 0.5, 1 );
		level.legs SetAnimKnob( level._scr_anim[ "legs" ][ "parachute_buffeting_2" ], 1, 0.5, 1 );
	
		level.player_rig.buffeting_2_weight_curr = 1.0;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
parachute_stop_anims()
{
	if ( level._USE_ANIMS == 0 )
	{
		return;
	}

	// curr = curr + ( target - curr ) * rate
	level.player_rig.stop_idle_weight_curr += ( 1.0 - level.player_rig.stop_idle_weight_curr ) * level._anim_rate_out;
	level.player_rig.turn_r_idle_weight_curr += ( 0.0 - level.player_rig.turn_r_idle_weight_curr ) * level._anim_rate_out;
	level.player_rig.idle_weight_curr += ( 0.0 - level.player_rig.idle_weight_curr ) * level._anim_rate_out;
	level.player_rig.turn_l_idle_weight_curr += ( 0.0 - level.player_rig.turn_l_idle_weight_curr ) * level._anim_rate_out;
	level.player_rig.buffeting_weight_curr += ( 0.0 - level.player_rig.buffeting_weight_curr ) * level._anim_rate_out;
	level.player_rig.buffeting_2_weight_curr += ( 0.0 - level.player_rig.buffeting_2_weight_curr ) * level._anim_rate_out;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
chute_end()
{
	// If we're already failing...don't land
	if ( level._fail_sequence == 1 )
	{
		return;
	}

	level._enable_chute_controls = 0;
	level._landing_sequence = 1;
	level._USE_ANIMS = 0;

	// lerp
	level._player LerpViewAngleClamp( level._view_lerp_time, level._view_lerp_time, 0, level._landing_view_clamp, level._landing_view_clamp, level._landing_view_clamp, level._landing_view_clamp );
	level._anim_state = "landing";

	// Need to apply a deceleration for the landing
	anim_length = GetAnimLength( level._scr_anim[ "player_rig" ][ "parachute_landing" ] );
	level._forward_acceleration = ( -1.0 * ( level._forward_velocity / anim_length ) );

	parachute_landing_anims();

	thread chute_wait_for_landing_complete();

	level._player waittill( "landing_anim_complete" );

	level._player.disableReload = false;
	level._player EnableWeapons();
	level._player EnableOffhandWeapons();
	level._player EnableWeaponSwitch();

	level._player AllowCrouch( true );
	level._player AllowJump( true );
	//level._player AllowLean( true );
	level._player AllowMelee( true );
	level._player AllowProne( true );
	level._player AllowSprint( true );

	//kill sounds
	level._chute_sfx StopSounds();
	level._chute_sfx Delete();

	chute_destroy_assets();

	level notify( "maps\_chute::chute_end() complete" );

	// Need to snap the player to the ground
	level._player SetOrigin( drop_to_ground( level._player.origin, 100, -100 ) );

	flag_clear( "_chute.gsc_flag_parachute_active" );

	SetSavedDvar( "hud_chute_active", 0 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
chute_destroy_assets()
{
	level._player Unlink();
	level.player_mover Delete();
	level.legs Delete();
	level.head Delete();
	level.player_rig Delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
chute_wait_for_landing_complete()
{
	level endon( "chute_land_interrupt" );

	while ( 1 )
	{
		// Finish the chute_end as soon as the anim is complete
		curr_time = level.player_rig GetAnimTime( level._scr_anim[ "player_rig" ][ "parachute_landing" ] );
		if ( curr_time >= 0.98 )
		{
			level._player notify( "landing_anim_complete" );
			break;
		}

		wait( 0.05 );
	}
}

