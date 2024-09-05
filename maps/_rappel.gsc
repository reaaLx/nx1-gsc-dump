
//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  _rappel														**
//                                                                          **
//    Created: 06.22.2011 - Riggs											**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_nx_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main()
{
	// Internal Initialization
	init_rappel_variables();

	// Precaches
	PrecacheModel( "nx_us_specops_body_assault_a" );

	// Anims
	player_animations();
	legs_animations();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
init_rappel_variables()
{
	level._TIMESTEP = 0.05;	

	// Rate for "lerping" the anims, i.e the percentage of weight change per frame.
	// Valid Range: 0.05 - 1.0
	level._anim_rate_in = 0.4;
	level._anim_rate_out = 0.6;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
#using_animtree( "player" );
player_animations()
{
	level._scr_animtree[ "player_rig" ] 						= #animtree;
	level._scr_model[ "player_rig" ] 							= "viewhands_player_us_army";

	level._scr_anim[ "player_rig" ][ "sprint" ]					= %nx_fp_ss_rappel_ground;
	level._scr_anim[ "player_rig" ][ "sprint_forward" ]			= %nx_fp_ss_rappel_sprint;
	level._scr_anim[ "player_rig" ][ "sprint_left" ]			= %nx_fp_ss_rappel_sprint_L;
	level._scr_anim[ "player_rig" ][ "sprint_right" ]			= %nx_fp_ss_rappel_sprint_R;
	level._scr_anim[ "player_rig" ][ "jump_in" ]				= %nx_fp_ss_rappel_jump_in;
	level._scr_anim[ "player_rig" ][ "jump_loop" ]				= %nx_fp_ss_rappel_jump_loop;
	level._scr_anim[ "player_rig" ][ "jump_out" ]				= %nx_fp_ss_rappel_jump_out;
	level._scr_anim[ "player_rig" ][ "slide_in" ]				= %nx_fp_ss_rappel_slide_in;
	level._scr_anim[ "player_rig" ][ "slide_loop" ]				= %nx_fp_ss_rappel_slide_loop;
	level._scr_anim[ "player_rig" ][ "slide_out" ]				= %nx_fp_ss_rappel_slide_out;
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

	level._scr_anim[ "legs" ][ "idle" ]						= %fp_body_default;
	level._scr_anim[ "legs" ][ "slide_in" ]					= %nx_tp_ss_rappel_slide_in;
	level._scr_anim[ "legs" ][ "slide_loop" ]				= %nx_tp_ss_rappel_slide_loop;
	level._scr_anim[ "legs" ][ "slide_out" ]				= %nx_tp_ss_rappel_slide_out;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Sets up a rappel sequence with named trigger and objects
//rappel_start( rappel_type, rappel_objects_targetname, rappel_object_objective_targetname, tether_pos_and_angles, rope_length, physics_speed )
//{
//	rappel_object = undefined;	// The script_brushmodel "pole" to rappel on
//	objective_ent = undefined; 	// The glowing script_brushmodel pole (for the objective)
//	rappel_trigger = undefined;	// The trigger to prompt the player to rappel (trigger_use) 
//	animent_object = undefined; // The script_origin for the rappel animation	
//
//	// Grab the objects (except glowing objective pole)
//	rappel_objects = GetEntArray( rappel_objects_targetname, "targetname" );
//
//	// Parse objects, make sure we have everything we need
//	foreach( object in rappel_objects )
//	{
//		switch( object.classname )
//		{
//			case "script_origin":
//				animent_object = object;
//				break;
//			case "trigger_use":
//				rappel_trigger = object;
//				break;
//  			case "script_brushmodel":
//				rappel_object = object;
//				break;
//  			default:
//				AssertMsg( "Unneeded obj with classname '" + object.classname + "' with targetname '" + rappel_objects_targetname + "... Please remove from radiant" );
//		}
//	}
//	
//	// Glowing objective pole entity (this is separate because there are two script_brushmodels for the regular pole and glowing pole and no way to tell them apart)
//	objective_ent = GetEnt( rappel_object_objective_targetname, "targetname" );
//
//	// Hide normal object
//	AssertEx( isdefined( rappel_object ), "_rappel script_brushmodel for rappel object pole is not defined!" );
//	AssertEx( isdefined( rappel_trigger ), "_rappel trigger_use trigger is not defined!" );
//	AssertEx( isdefined( animent_object ), "_rappel script_origin for animation entity is not defined!" );
//	AssertEx( isdefined( objective_ent ), "_rappel objective entity glowing pole is not defined!" ); 
//
//	// Hide rappel pole, show glowing pole and hint string
//	rappel_object Hide();
//	rappel_trigger SetHintString( &"NX_SS_RAPPEL_START" );	
//	objective_ent Show();	
//
//	// Wait for player to interact
//	for ( ;; )
//	{
//		rappel_trigger waittill( "trigger" );
//		
//		if ( self isthrowinggrenade())
//		{
//			continue;
//		}
//		
//		if ( self isswitchingweapon())
//		{
//			continue;
//		}
//		
//		break;
//	}
//
//	level._player notify( "notify_rappel_start" );	
//
//	switch( rappel_type )
//	{
//		case "rappel_standard":
//			level._player rappel_setup( tether_pos_and_angles, rope_length, physics_speed );
//			break;		
//   		default:
//			Assert( "rappel_start(): Unknown rappel_type '" + rappel_type + "'" );
//	}
//}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
rappel_setup( tether_pos_and_angles, rope_length, physics_speed )
{
	// Dvars. 
	SetSavedDvar( "compass", 0 );
	SetSavedDvar( "ammoCounterHide", 1 );
	SetSavedDvar( "actionSlotsHide", 1 );
	SetSavedDvar( "hud_showStance", 0 );
	SetSavedDvar( "hud_drawhud", 0 );

	// Constraints
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

	tether_pos_and_angles = GetEnt( tether_pos_and_angles, "targetname" );

	// tagBR< HACK >
	level._tether_pos = tether_pos_and_angles.origin;// + ( 0, 100, 0 );
	
	// tagBR< HACK >
	level._player SetOrigin( tether_pos_and_angles.origin + ( 0, -100, -100 ) );

	// Player Rig ---
	level._player_rig = spawn_anim_model( "player_rig", level._player.origin );
	level._player_rig.angles = tether_pos_and_angles.angles;

	// Cannot animate & move via script the player rig at the same time, so spawn a tag_origin
	level._player_mover = spawn_tag_origin();
	level._player_mover.origin = level._player.origin;
	level._player_mover.angles = tether_pos_and_angles.angles;
	level._player.angles = tether_pos_and_angles.angles;
	level._player_rig LinkTo( level._player_mover );

	level._player PlayerSetGroundReferenceEnt( level._player_mover );

	// This call constrains camera movement as well as linking
	level._player PlayerLinkToDelta( level._player_rig, "tag_player", 1, 40, 40, 15, 20, true, true );
	//level._player SetRelinkPlayerFlag( 1 );
	//thread wait_and_reset_relink_player_flag();

	// Legs ---
	level._legs = spawn_anim_model( "legs", level._player.origin );
	//level._legs hide();
	level._legs.angles = level._player.angles;
	level._legs LinkTo( level._player_rig, "tag_origin", ( -5, 0, -5 ), ( 0, 0, 0 ) );
	//level._legs show();

	level._player_rig SetAnimKnob( level._scr_anim[ "player_rig" ][ "sprint" ], 1, 0 );
	level._legs SetAnimKnob( level._scr_anim[ "legs" ][ "idle" ], 1, 0 );

	level._max_rope_length = rope_length;

	level._player_rig._anim_state = "sprint";

	level._player_rig._slide = false;
	level._player_rig._force_jump = false;
	
	level._player_rig.sprint_weight_curr = 1;
	level._player_rig.sprint_weight_target = level._player_rig.sprint_weight_curr;
	
	level._player_rig.jump_in_weight_curr = 0;
	level._player_rig.jump_in_weight_target = level._player_rig.jump_in_weight_curr;
	
	level._player_rig.jump_loop_weight_curr = 0;
	level._player_rig.jump_loop_weight_target = level._player_rig.jump_loop_weight_curr;
	
	level._player_rig.jump_out_weight_curr = 0;
	level._player_rig.jump_out_weight_target = level._player_rig.jump_out_weight_curr;
	
	level._player_rig.slide_in_weight_curr = 0;
	level._player_rig.slide_in_weight_target = level._player_rig.slide_in_weight_curr;
	
	level._player_rig.slide_loop_weight_curr = 0;
	level._player_rig.slide_loop_weight_target = level._player_rig.slide_loop_weight_curr;
	
	level._player_rig.slide_out_weight_curr = 0;
	level._player_rig.slide_out_weight_target = level._player_rig.slide_out_weight_curr;
	
	level._player_rig.lateral_weight_curr = 0;
	level._player_rig.lateral_weight_target = level._player_rig.lateral_weight_curr;
	
	level._legs.idle_weight_curr = 0;
	level._legs.idle_weight_target = level._legs.idle_weight_curr;
	
	level._legs.slide_in_weight_curr = 0;
	level._legs.slide_in_weight_target = level._legs.slide_in_weight_curr;
	
	level._legs.slide_loop_weight_curr = 0;
	level._legs.slide_loop_weight_target = level._legs.slide_loop_weight_curr;
	
	level._legs.slide_out_weight_curr = 0;
	level._legs.slide_out_weight_target = level._legs.slide_out_weight_curr;

	//player_rig.incline_slide_weight_curr = 0;

	// TagBR< todo > Need anim, and actually hook up it up, but just notify for now...
	level._player notify( "notify_rappel_anim_done" );	

	thread rappel_anim_state_machine();

	// setup slide triggers
	triggers = GetEntArray( "rappel_slide", "script_noteworthy" );
	array_thread( triggers, ::slide_trigger );

	level._physics_speed = physics_speed;
	thread rappel_physics();

	//thread maps\_nx_rappel::flag_rappel_end_watcher();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
slide_trigger()
{
	self waittill( "trigger", ent );
	assert( IsPlayer( ent ) );

	level._player_rig._slide = true;

	while ( true )
	{
		wait 0.05;

		if ( !ent IsTouching( self ) )
		{
			break;
		}
	};

	level._player_rig._slide = false;

	// each trigger only works once
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
update_tether_pos( position )
{	
	level._tether_pos = position;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
update_tether_length( length_scalar )
{	
	level._max_rope_length = length_scalar;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Ends rappel sequence
rappel_end()
{
	level._player notify( "notify_rappel_end" );

	wait 0.05;

	level._player PlayerSetGroundReferenceEnt( undefined );
	level._player unlink();
	level._player_mover = undefined;
	level._tether_pos = undefined;
	level._damping_factor = undefined;
	level._rappel = undefined;

	level._player AllowCrouch( true );
	level._player AllowProne( true );
	level._player AllowJump( true );
	level._player AllowMelee( true );
	level._player AllowSprint( true );

 	SetSavedDvar( "compass", 1 );
 	SetSavedDvar( "ammoCounterHide", 0 );
 	SetSavedDvar( "actionSlotsHide", 0 );
 	SetSavedDvar( "hud_showStance", 1 );
 	SetSavedDvar( "hud_drawhud", 1 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
update_damping_factor( factor_scalar )
{
	level._damping_factor = factor_scalar;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
rappel_pause()
{
	// This stops physics & anim state machine
	level._player notify( "rappel_pause" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//rappel_resume()
//{
//	thread rappel_anim_state_machine();
//	thread rappel_physics();
//}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
rappel_physics()
{
	level._player endon( "notify_rappel_end" );
	level._player endon( "notify_rappel_physics_end" );
	level._player endon( "rappel_pause" );

	// Physics variables ---
	absolute_pos = level._player_mover.origin;
	absolute_angles = level._player_mover.angles;
	total_velocity = ( 0, 0, 0 );

	// Lateral movement
	analog_acceleration = ( 0, 0, 0 );
	analog_scalar = 256;
	analog_scalar_air = 64;
	analog_scalar_slide = 128;

	// Jump height
	standard_jump_scalar = 425;  // 500
	forced_jump_scalar = 700;

	// Duration that a jump command is buffered, allowing player to press jump early.
	jump_button_buffer_time = 300; // ms

	// Starting speed of descent and current downward velocity (increase per frame up to max ) -BMarv
	//auto_forward_increase_scalar = 0.5;
	//current_forward_speed_scalar = 0;
	auto_forward_increase_scalar = 3.5;
	current_forward_speed_scalar = 3.5;
	
	// Max speed of descent (per frame)
	auto_forward_scalar = 50;
	//auto_forward_scalar = 0.1;

	// Rope tension force 
	tension_acceleration = ( 0, 0, 0 );
	tension_scalar = 1200;

	// Air resistance 
	level._damping_factor = -0.35;
	//level._damping_factor = -2;

	up_vector = VectorNormalize( AnglesToUp( level._player_mover.angles ) );
	down_vector = -1 * up_vector;
	right_vector = VectorNormalize( AnglesToRight( level._player_mover.angles ) );
	forward_vector = VectorNormalize( AnglesToForward( level._player_mover.angles ) );
	back_vector = -1 * forward_vector;

	jump_held = false;
	last_time_jump_pressed = 0;

	level._surface_normal = undefined;

	level._TIMESTEP *= level._physics_speed;
	// ----------------------

	while ( 1 )
	{
		//IPrintLn( level._player_rig._anim_state + " : " + total_velocity[ 1 ] );

		// track jump button state so taht we only respond to presses
		if ( level._player JumpButtonPressed() )
		{
			if ( jump_held == false )
			{
				jump_held = true;
				last_time_jump_pressed = GetTime();
			}
		}
		else
		{
			if ( jump_held == true )
			{
				jump_held = false;
			}
		}

		// Check Rope Length -------
		//IPrintLnBold( abs( level._player.origin[2] - level._tether_pos[2] ) );
		if ( abs( level._player.origin[2] - level._tether_pos[2] ) > level._max_rope_length )
		{
			level._tether_pos = ( level._tether_pos[0], level._tether_pos[1], level._player.origin[2] + level._max_rope_length );
		}

		tether_to_player = level._player.origin - level._tether_pos;
		// END Check Rope Length ---

		// Analog Movement -------
		normalized_move = level._player GetNormalizedMovement();
		if ( level._player_rig._slide == true )
		{
			// adjust analog speed when sliding
			normalized_move *= analog_scalar_slide / analog_scalar;
		}

		// maybe switch to lateral anims
		level._player_rig.lateral_weight_target = normalized_move[ 1 ];
		//if ( normalized_move[ 1 ] > 0.2 )
		//{
		//	level._player_rig.lateral_weight_target = 1;
		//}
		//else if ( normalized_move[ 1 ] < -0.2 )
		//{
		//	level._player_rig.lateral_weight_target = -1;
		//}
		//else
		//{
		//	level._player_rig.lateral_weight_target = 0;
		//}

		if ( normalized_move[1] == 0 )
		{
			analog_acceleration = ( 0, 0, 0 );
		}
		else
		{
			if ( IsDefined( level._surface_normal ) )
			{
				normal_minus_z = ( level._surface_normal[0], level._surface_normal[1], 0 );
				left_vect = VectorCross( normal_minus_z, forward_vector );
				analog_acceleration = left_vect * ( normalized_move[1] * -1 ) * analog_scalar;
			}
			else // we are in air
			{
				analog_acceleration = ( right_vector * -1 ) * ( normalized_move[1] * -1 ) * analog_scalar_air;
			}
		}

		total_velocity += analog_acceleration * level._TIMESTEP;
		// END Analog Movement ---

		// Jump -------
		/*if ( IsDefined( level._surface_normal ) )
		{
			if ( level._player JumpButtonPressed() )
			{
				normal_minus_z = ( level._surface_normal[0], level._surface_normal[1], 0 );
				total_velocity += ( standard_jump_scalar * normal_minus_z );

				level._player_rig._anim_state = "jump_in";
			}
		}*/
		
		// can only jump on the ground
		if ( IsDefined( level._surface_normal ) )
		{
			jump = false;
			jump_scalar = standard_jump_scalar;
			if ( level._player_rig._force_jump == true )
			{
				// whoever set force-jump already set the anim-state
				jump = true;
				jump_scalar = forced_jump_scalar; // use a higher jump coming out of slides
			}
			else if ( level._player_rig._slide == false ) // can't jump while sliding
			{
				// if latest jump command is within the buffer time.
				if ( GetTime() - last_time_jump_pressed < jump_button_buffer_time )
				{
					last_time_jump_pressed = 0; // consume the jump command

					level._player_rig._anim_state = "jump_in";
					jump = true;
				}
			}
	
			if ( jump )
			{
				normal_minus_z = ( level._surface_normal[0], level._surface_normal[1], 0 );
				normal_minus_z = VectorNormalize( normal_minus_z );
				total_velocity += ( jump_scalar * normal_minus_z );
			}
		}
		level._player_rig._force_jump = false;
		// END Jump ---

		// Auto Movement -------
		if( current_forward_speed_scalar < auto_forward_scalar )
		{
			// Rappelling just started, slowly increase velocity up to max
			forward_scalar = current_forward_speed_scalar + auto_forward_increase_scalar;			
			if( forward_scalar > auto_forward_scalar )
			{
				forward_scalar = auto_forward_scalar;
			} 
			current_forward_speed_scalar = forward_scalar;
			auto_offset = ( forward_vector * forward_scalar );
		}
		else
		{
			auto_offset = ( forward_vector * auto_forward_scalar );
		}
		forward_trace = BulletTrace( level._player GetEye(), ( level._player GetEye() + auto_offset ), false, level._player_mover );

		if ( forward_trace["surfacetype"] != "none" )
		{
			theta = acos( VectorDot( forward_trace["normal"], forward_vector ) );
			
			// Flat wall will be 180;
			if ( theta > 150 )
			{
				auto_offset = ( 0, 0, 0 );
			}
		}
		// END Auto Movement ---

		// Tension -------
		theta = acos( VectorDot( VectorNormalize( tether_to_player ), forward_vector ) );
		tens_vect = VectorNormalize( ( tether_to_player[0], tether_to_player[1], 0 ) * -1 );
		tension_acceleration = tension_scalar * tan( theta ) * tens_vect;
		total_velocity += tension_acceleration * level._TIMESTEP;
		// END Tension ---

		// Damping -------
		total_velocity += ( level._damping_factor * total_velocity * level._TIMESTEP );
		// END Damping ---

		// Update Angles -------
		ground_trace = BulletTrace( level._player_mover.origin, level._player_mover.origin + 1000 * down_vector, false, level._player_mover );
		
		if ( ground_trace["surfacetype"] != "none" )
		{
			// This is a little hack that allows the player to jump even when slightly off the surface
			if ( Length( level._player_mover.origin - ground_trace["position"] ) < 40 )
			{
				level._surface_normal = ground_trace["normal"];
			}

			angles = VectorToAngles( ground_trace["normal"] );		
			angle_lerp_speed = 0.2;
			//level._player_mover RotateTo( ( level._player_mover.angles[0], angles[1] - 270, level._player_mover.angles[2] ), angle_lerp_speed, angle_lerp_speed / 2, angle_lerp_speed / 2 );
			level._player_mover RotateTo( ( level._player_mover.angles[0], angles[1] - 180, level._player_mover.angles[2] ), angle_lerp_speed, angle_lerp_speed / 2, angle_lerp_speed / 2 );
		}
		else
		{
			// This code runs when we're hanging out over the side of the building and helps give a little extra push back
			tens_vect = VectorNormalize( ( tether_to_player[0], 0, 0 ) * -1 );
			tension_acceleration = tension_scalar * tan( theta ) * tens_vect;
			total_velocity += tension_acceleration * level._TIMESTEP;
		}
		// END Update Angles ---

		// Update Pos -------
		old_pos = level._player_mover.origin;
		absolute_pos += ( total_velocity * level._TIMESTEP ) + auto_offset;
		new_pos = absolute_pos;
		// END Update Pos ---

		// Need to check for colliding with things (fail condition)
		coll_info = PlayerPhysicsTraceExtraInfo( old_pos, new_pos );
		collide_pos = coll_info["position"];

		if ( !f3D_vectors_equal( collide_pos, new_pos ) )
		{
			// total hack
			//if ( coll_info["surfacetype"] == "glass" /*|| coll_info["surfacetype"] == "metal"*/ )
			{
				level._surface_normal = coll_info["normal"];

				// zero out velocity in dir of normal
				total_velocity = ( total_velocity - ( VectorDot( total_velocity, level._surface_normal ) * level._surface_normal ) );
			}

			// Calculate the offset to not allow interpenetration
			dot_result = VectorDot( collide_pos - new_pos, coll_info["normal"] );

			ip_offset = dot_result * coll_info["normal"];

			resolved_pos = new_pos + ip_offset + coll_info["normal"];

			// Iterate a 2nd time
			coll_info_2 = PlayerPhysicsTraceExtraInfo( collide_pos, resolved_pos );
			collide_pos_2 = coll_info_2["position"];

			if ( !f3D_vectors_equal( collide_pos_2, resolved_pos ) )
			{
				level._surface_normal = coll_info_2["normal"];

				dot_result_2 = VectorDot( collide_pos_2 - resolved_pos, coll_info_2["normal"] );
	
				ip_offset_2 = dot_result_2 * coll_info_2["normal"];
				
				resolved_pos_2 = resolved_pos + ip_offset_2 + coll_info_2["normal"];
	
				// Iterate a 3rd time
				collide_pos_3 = PlayerPhysicsTrace( collide_pos_2, resolved_pos_2 );
	
				if ( !f3D_vectors_equal( collide_pos_3, resolved_pos_2 ) )
				{
					// Apply offsets
					absolute_pos += ( collide_pos_3 - new_pos );
					level._player_mover.origin = collide_pos_3;

					// This was required by BMarv's logic in nx_ss_rappel.gsc
					level._rappel[ "current_player_vector" ] = collide_pos_3 - old_pos;	
					
				}
				else
				{
					// Apply offsets
					absolute_pos += ip_offset_2;
					level._player_mover.origin = resolved_pos_2;

					// This was required by BMarv's logic in nx_ss_rappel.gsc
					level._rappel[ "current_player_vector" ] = resolved_pos_2 - old_pos;
				}
			}
			else
			{
				// Apply offsets
				absolute_pos += ip_offset;
				level._player_mover.origin = resolved_pos;

				// This was required by BMarv's logic in nx_ss_rappel.gsc
				level._rappel[ "current_player_vector" ] = resolved_pos - old_pos;
			}
		}
		else
		{
			level._surface_normal = undefined;

			level._player_mover.origin = new_pos;

			// This was required by BMarv's logic in nx_ss_rappel.gsc
			level._rappel[ "current_player_vector" ] = new_pos - old_pos;
		}

		rappel_lerp_anims();

		wait 0.05;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
rappel_anim_state_machine()
{
	level._player endon( "notify_rappel_end" );
	level._player endon( "rappel_pause" );

	while ( 1 )
	{
		switch( level._player_rig._anim_state )
		{
			case "sprint":
				level._player_rig rappel_sprint_state();
				break;
	
			case "jump_in":
				level._player_rig rappel_jump_in_state();
				break;
	
			case "jump_loop":
				level._player_rig rappel_jump_loop_state();
				break;
	
			case "jump_out":
				level._player_rig rappel_jump_out_state();
				break;
	
			case "slide_in":
				level._player_rig rappel_slide_in_state();
				break;
	
			case "slide_loop":
				level._player_rig rappel_slide_loop_state();
				break;
	
			case "slide_out":
				level._player_rig rappel_slide_out_state();
				break;
	
			default:
				Assert( "rappel does not have an appropriate state defined." );
				break;
		}

		wait 0.05;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
set_leg_anims_to_idle()
{
	level._legs.idle_weight_target = 1;
	level._legs.slide_in_weight_target = 0;
	level._legs.slide_loop_weight_target = 0;
	level._legs.slide_out_weight_target = 0;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
rappel_sprint_state()
{
	level._player_rig.anim_rate = level._anim_rate_in;
	level._player_rig.sprint_weight_target = 1;
	level._player_rig.jump_in_weight_target = 0;
	level._player_rig.jump_loop_weight_target = 0;
	level._player_rig.jump_out_weight_target = 0;
	level._player_rig.slide_in_weight_target = 0;
	level._player_rig.slide_loop_weight_target = 0;
	level._player_rig.slide_out_weight_target = 0;

	set_leg_anims_to_idle();

	if ( level._player_rig._slide == true )
	{
		level._player_rig._anim_state = "slide_in";
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
rappel_jump_in_state()
{
	level._player_rig.anim_rate = level._anim_rate_out;
	level._player_rig.jump_in_weight_target = 1;
	level._player_rig.sprint_weight_target = 0;
	level._player_rig.jump_loop_weight_target = 0;
	level._player_rig.jump_out_weight_target = 0;
	level._player_rig.slide_in_weight_target = 0;
	level._player_rig.slide_loop_weight_target = 0;
	level._player_rig.slide_out_weight_target = 0;

	set_leg_anims_to_idle();

	// if anim complete, then transition to jump_loop
	if ( rappel_check_anim_time( "jump_in", 0.98 ) )
	{
		level._player_rig._anim_state = "jump_loop";
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
rappel_jump_loop_state()
{
	level._player_rig.anim_rate = level._anim_rate_out;
	level._player_rig.jump_loop_weight_target = 1;
	level._player_rig.sprint_weight_target = 0;
	level._player_rig.jump_in_weight_target = 0;
	level._player_rig.jump_out_weight_target = 0;
	level._player_rig.slide_in_weight_target = 0;
	level._player_rig.slide_loop_weight_target = 0;
	level._player_rig.slide_out_weight_target = 0;

	set_leg_anims_to_idle();

	// if we are back on 'ground', transition to jump_out
	if ( IsDefined( level._surface_normal ) )
	{
		level._player_rig._anim_state = "jump_out";
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
rappel_jump_out_state()
{
	level._player_rig.anim_rate = level._anim_rate_out;
	level._player_rig.jump_out_weight_target = 1;
	level._player_rig.sprint_weight_target = 0;
	level._player_rig.jump_in_weight_target = 0;
	level._player_rig.jump_loop_weight_target = 0;
	level._player_rig.slide_in_weight_target = 0;
	level._player_rig.slide_loop_weight_target = 0;
	level._player_rig.slide_out_weight_target = 0;

	set_leg_anims_to_idle();

	// if anim complete, then transition to sprint
	if ( rappel_check_anim_time( "jump_out", 0.8 ) )
	{
		level._player_rig._anim_state = "sprint";
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
rappel_slide_in_state()
{
	level._player_rig.anim_rate = level._anim_rate_in;
	level._player_rig.slide_in_weight_target = 1;
	level._player_rig.sprint_weight_target = 0;
	level._player_rig.jump_in_weight_target = 0;
	level._player_rig.jump_loop_weight_target = 0;
	level._player_rig.jump_out_weight_target = 0;
	level._player_rig.slide_loop_weight_target = 0;
	level._player_rig.slide_out_weight_target = 0;

	level._legs.slide_in_weight_target = 1;
	level._legs.idle_weight_target = 0;
	level._legs.slide_loop_weight_target = 0;
	level._legs.slide_out_weight_target = 0;


	// if anim complete, then transition to slide_loop
	if ( rappel_check_anim_time( "slide_in", 0.98 ) )
	{
		level._player_rig._anim_state = "slide_loop";
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
rappel_slide_loop_state()
{
	level._player_rig.anim_rate = level._anim_rate_out;
	level._player_rig.slide_loop_weight_target = 1;
	level._player_rig.sprint_weight_target = 0;
	level._player_rig.jump_in_weight_target = 0;
	level._player_rig.jump_loop_weight_target = 0;
	level._player_rig.jump_out_weight_target = 0;
	level._player_rig.slide_in_weight_target = 0;
	level._player_rig.slide_out_weight_target = 0;

	level._legs.slide_loop_weight_target = 1;
	level._legs.idle_weight_target = 0;
	level._legs.slide_in_weight_target = 0;
	level._legs.slide_out_weight_target = 0;

	if ( level._player_rig._slide == false )
	{
		level._player_rig._anim_state = "slide_out";
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
rappel_slide_out_state()
{
	level._player_rig.anim_rate = level._anim_rate_out;
	level._player_rig.slide_out_weight_target = 1;
	level._player_rig.sprint_weight_target = 0;
	level._player_rig.jump_in_weight_target = 0;
	level._player_rig.jump_loop_weight_target = 0;
	level._player_rig.jump_out_weight_target = 0;
	level._player_rig.slide_in_weight_target = 0;
	level._player_rig.slide_loop_weight_target = 0;

	level._legs.slide_out_weight_target = 1;
	level._legs.idle_weight_target = 0;
	level._legs.slide_in_weight_target = 0;
	level._legs.slide_loop_weight_target = 0;

	anime = level._scr_anim[ "player_rig" ][ "slide_out" ];

	force_jump_times = GetNoteTrackTimes( anime, "slide_out_jump" );
	assert ( force_jump_times.size > 0 );

	anim_time = level._player_rig GetAnimTime( anime );
	if ( anim_time > force_jump_times[ 0 ] )
	{
		level._player_rig._force_jump = true;
	}

	// if anim complete, then transition to jump_loop
	if ( rappel_check_anim_time( "slide_out", 0.9 ) )
	{
		level._player_rig._anim_state = "jump_loop";
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
rappel_lerp_anims()
{
	//IPrintLnBold( level._player_rig GetEntNum() );

	//===
	// state anim blends

	level._player_rig.sprint_weight_curr += ( level._player_rig.sprint_weight_target - level._player_rig.sprint_weight_curr ) * level._player_rig.anim_rate;
	level._player_rig.jump_in_weight_curr += ( level._player_rig.jump_in_weight_target - level._player_rig.jump_in_weight_curr ) * level._player_rig.anim_rate;
	level._player_rig.jump_loop_weight_curr += ( level._player_rig.jump_loop_weight_target - level._player_rig.jump_loop_weight_curr ) * level._player_rig.anim_rate;
	level._player_rig.jump_out_weight_curr += ( level._player_rig.jump_out_weight_target - level._player_rig.jump_out_weight_curr ) * level._player_rig.anim_rate;
	level._player_rig.slide_in_weight_curr += ( level._player_rig.slide_in_weight_target - level._player_rig.slide_in_weight_curr ) * level._player_rig.anim_rate;
	level._player_rig.slide_loop_weight_curr += ( level._player_rig.slide_loop_weight_target - level._player_rig.slide_loop_weight_curr ) * level._player_rig.anim_rate;
	level._player_rig.slide_out_weight_curr += ( level._player_rig.slide_out_weight_target - level._player_rig.slide_out_weight_curr ) * level._player_rig.anim_rate;

	level._player_rig SetAnimLimited( level._scr_anim[ "player_rig" ][ "sprint" ], level._player_rig.sprint_weight_curr, 0 );
	level._player_rig SetAnimLimited( level._scr_anim[ "player_rig" ][ "jump_in" ], level._player_rig.jump_in_weight_curr, 0 );
	level._player_rig SetAnimLimited( level._scr_anim[ "player_rig" ][ "jump_loop" ], level._player_rig.jump_loop_weight_curr, 0 );
	level._player_rig SetAnimLimited( level._scr_anim[ "player_rig" ][ "jump_out" ], level._player_rig.jump_out_weight_curr, 0 );
	level._player_rig SetAnimLimited( level._scr_anim[ "player_rig" ][ "slide_in" ], level._player_rig.slide_in_weight_curr, 0 );
	level._player_rig SetAnimLimited( level._scr_anim[ "player_rig" ][ "slide_loop" ], level._player_rig.slide_loop_weight_curr, 0 );
	level._player_rig SetAnimLimited( level._scr_anim[ "player_rig" ][ "slide_out" ], level._player_rig.slide_out_weight_curr, 0 );

	//===
	// leg anim blends

	level._legs.idle_weight_curr += ( level._legs.idle_weight_target - level._legs.idle_weight_curr ) * level._player_rig.anim_rate;
	level._legs.slide_in_weight_curr += ( level._legs.slide_in_weight_target - level._legs.slide_in_weight_curr ) * level._player_rig.anim_rate;
	level._legs.slide_loop_weight_curr += ( level._legs.slide_loop_weight_target - level._legs.slide_loop_weight_curr ) * level._player_rig.anim_rate;
	level._legs.slide_out_weight_curr += ( level._legs.slide_out_weight_target - level._legs.slide_out_weight_curr ) * level._player_rig.anim_rate;

	level._legs SetAnimLimited( level._scr_anim[ "legs" ][ "idle" ], level._legs.idle_weight_curr, 0 );
	level._legs SetAnimLimited( level._scr_anim[ "legs" ][ "slide_in" ], level._legs.slide_in_weight_curr, 0 );
	level._legs SetAnimLimited( level._scr_anim[ "legs" ][ "slide_loop" ], level._legs.slide_loop_weight_curr, 0 );
	level._legs SetAnimLimited( level._scr_anim[ "legs" ][ "slide_out" ], level._legs.slide_out_weight_curr, 0 );

	//===
	// lateral anim blends

	level._player_rig.lateral_weight_curr += ( level._player_rig.lateral_weight_target - level._player_rig.lateral_weight_curr ) * 0.15;

	lateral_weight = Abs( level._player_rig.lateral_weight_curr );
	level._player_rig SetAnimLimited( level._scr_anim[ "player_rig" ][ "sprint_forward" ], 1 - lateral_weight, 0 );
	if ( level._player_rig.lateral_weight_curr > 0 )
	{
		level._player_rig SetAnimLimited( level._scr_anim[ "player_rig" ][ "sprint_left" ], 0, 0 );
		level._player_rig SetAnimLimited( level._scr_anim[ "player_rig" ][ "sprint_right" ], lateral_weight, 0 );
	}
	else
	{
		level._player_rig SetAnimLimited( level._scr_anim[ "player_rig" ][ "sprint_left" ], lateral_weight, 0 );
		level._player_rig SetAnimLimited( level._scr_anim[ "player_rig" ][ "sprint_right" ], 0, 0 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
rappel_check_anim_time( anime, time )
{
	curr_time = level._player_rig GetAnimTime( level._scr_anim[ "player_rig" ][ anime ] );
	if ( curr_time >= time )
	{
		return true;
	}

	return false;
}

