//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  MISSION DESCRIPTION											**
//                                                                          **
//    Created: DATE - bkutcher												**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_nx_vignette_util;

//*******************************************************************
//																	*
//																	*
//*******************************************************************
MELEE_BLEND_TO_RIG_TIME = 0.05;
MELEE_MOVE_TO_TIME = 0.1;
MELEE_ANIM_BREAKOUT_PERCENT = 0.5;
MELEE_ANIM_BLENDOUT_TIME = 0.2;

USE_RANDOM_MELEE = true;

VIEW_ATTACHED_MELEE = true;
SCRIPTED_MELEE = false;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
init_system()
{
	PrecacheModel( "viewmodel_knife" );
	generic_human();
	player_anims();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
activate_system( type )
{
	self.melee_vignette_type = type;
 	self SetMeleeVignetteSystemActive( 0 );
	self thread melee_vignette_thread();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
#using_animtree("generic_human");
generic_human()
{
	level._scr_animtree[ "melee_knife_target" ] = #animtree;
	level._scr_anim[ "melee_knife_target" ][ "front" ] = %nx_tp_knife_Interactive_melee_F;  
	level._scr_anim[ "melee_knife_target" ][ "left"  ] = %nx_tp_knife_Interactive_melee_L;  
	level._scr_anim[ "melee_knife_target" ][ "back"  ] = %nx_tp_knife_Interactive_melee_B;  
	level._scr_anim[ "melee_knife_target" ][ "right" ] = %nx_tp_knife_Interactive_melee_R;  

	level._scr_anim[ "melee_knife_target" ][ "front2" ] = %nx_tp_knife_Interactive_melee_02_F;  
	level._scr_anim[ "melee_knife_target" ][ "left2"  ] = %nx_tp_knife_Interactive_melee_02_L;  
	level._scr_anim[ "melee_knife_target" ][ "back2"  ] = %nx_tp_knife_Interactive_melee_02_B;  
	level._scr_anim[ "melee_knife_target" ][ "right2" ] = %nx_tp_knife_Interactive_melee_02_R;
	
	//level._scr_anim[ "melee_knife_target" ][ "front3" ] = %nx_tp_knife_Interactive_melee_03_F;   

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
#using_animtree("player");
player_anims()
{
	level._scr_animtree[ "melee_knife_player" ] = #animtree;
	level._scr_model[ "melee_knife_player" ] = "viewhands_player_us_army";

	// Front 
	level._scr_anim[ "melee_knife_player" ][ "front" ] = %nx_fp_knife_Interactive_melee_F;  
	level._scr_anim[ "melee_knife_player_view" ][ "front" ] = %fp_knife_Interactive_melee_F;  

	level._scr_anim[ "melee_knife_player" ][ "front2" ] = %nx_fp_knife_Interactive_melee_02_F;  
	level._scr_anim[ "melee_knife_player_view" ][ "front2" ] = %fp_knife_Interactive_melee_02_F; 
	
	//level._scr_anim[ "melee_knife_player" ][ "front3" ] = %nx_fp_knife_Interactive_melee_03_F;  
	//level._scr_anim[ "melee_knife_player_view" ][ "front3" ] = %fp_knife_Interactive_melee_03_F;   

	// Back
	level._scr_anim[ "melee_knife_player" ][ "back"  ] = %nx_fp_knife_Interactive_melee_B;  
	level._scr_anim[ "melee_knife_player_view" ][ "back"  ] = %fp_knife_Interactive_melee_B;  
	
	level._scr_anim[ "melee_knife_player" ][ "back2"  ] = %nx_fp_knife_Interactive_melee_02_B;  
	level._scr_anim[ "melee_knife_player_view" ][ "back2"  ] = %fp_knife_Interactive_melee_02_B;  

	// Left 
	level._scr_anim[ "melee_knife_player" ][ "left"  ] = %nx_fp_knife_Interactive_melee_L;  
	level._scr_anim[ "melee_knife_player_view" ][ "left"  ] = %fp_knife_Interactive_melee_L;  

	level._scr_anim[ "melee_knife_player" ][ "left2"  ] = %nx_fp_knife_Interactive_melee_02_L;  
	level._scr_anim[ "melee_knife_player_view" ][ "left2"  ] = %fp_knife_Interactive_melee_02_L;  

	// Right. 
	level._scr_anim[ "melee_knife_player" ][ "right" ] = %nx_fp_knife_Interactive_melee_R;  
	level._scr_anim[ "melee_knife_player_view" ][ "right" ] = %fp_knife_Interactive_melee_R;  

	level._scr_anim[ "melee_knife_player" ][ "right2" ] = %nx_fp_knife_Interactive_melee_02_R;  
	level._scr_anim[ "melee_knife_player_view" ][ "right2" ] = %fp_knife_Interactive_melee_02_R;  

	// Test. 
	level._scr_anim[ "melee_knife_player" ][ "test" ] = %fp_knife_Interactive_melee_F;//%nx_fp_knife_Interactive_melee_F;  

	addNotetrack_customFunction( "melee_knife_target", "rumble_heavy", ::knife_rumble_heavy );
	addNotetrack_customFunction( "melee_knife_target", "rumble_medium", ::knife_rumble_medium );
	addNotetrack_customFunction( "melee_knife_target", "rumble_light", ::knife_rumble_light );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
get_anim_names_from_type()
{
	anim_names = [];

	switch( self.melee_vignette_type )
	{
		case "melee_knife":
		{
			anim_names[ anim_names.size ] = "melee_knife_player";
			anim_names[ anim_names.size ] = "melee_knife_player_view";
			anim_names[ anim_names.size ] = "melee_knife_target";
		}
		break;

		default:
		{
			AssertEx( 0, "Could not find melee type %s.", self.melee_vignette_type );
		};
	}

	return anim_names;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
melee_vignette_extract_target_player_orientation( target, script_origin )
{
	// Get posed rig. 
	model = Spawn( "script_model", script_origin.origin );
	model UseAnimTree( level._scr_animtree[ target.animname ] );
	model SetModel( target.model );
	model.animname = target.animname;
	script_origin anim_first_frame_solo( model, self.melee_anim_quadrant );

	// Get tag sync data. 
 	self.melee_target_origin = model GetTagOrigin( "tag_sync" );
	self.melee_target_angles = model GetTagAngles( "tag_sync" );

// 	Line( self.melee_target_origin, self.melee_target_origin + ( 0, 0, 100 ), (0,0,1), 1, true, 5000 );
// 	Line( model.origin, model.origin + ( 0, 0, 100 ), (0,1,1), 1, true, 5000 );

	// Destroy the rig. 
	model Delete();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
debug_draw_axis( tag, color )
{
 	angles = self GetTagAngles( tag );
 	origin = self GetTagOrigin( tag );
	line( origin, origin + AnglesToForward( angles ) * 10, ( 1, 0, 0 ) );
	line( origin, origin + AnglesToUp( angles ) * 10, ( 0, 1, 0 ) );
	line( origin, origin + AnglesToRight( angles ) * 10, ( 0, 0, 1 ) );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
line_tests( player_rig )
{
	self endon( "end_lines" );
// 	toggle = 0;
	while( 1 )
	{
// 		toggle = 1 - toggle;
// 		if ( toggle == 0 ) 
// 		{
// 			player_rig hide();
// 		}
// 		else 
// 		{
// 			player_rig show();
// 		}
		player_rig debug_draw_axis( "tag_origin", ( 1, 0, 0 ));
		player_rig debug_draw_axis( "tag_player", ( 0, 1, 0 ));
		player_rig debug_draw_axis( "tag_camera", ( 0, 0, 1 ));
		wait( 0.01 );
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
play_viewmodel_melee_anim( wait_time )
{
	if ( IsDefined( self.melee_anim_name ))
	{
	 	anim_tree = level._scr_animtree[ self.melee_anim_name ];
		anim_name = level._scr_anim[ self.melee_anim_name_view ][ self.melee_anim_quadrant ];
	}
	else 
	{
	 	anim_tree = level._scr_animtree[ "melee_knife_player" ];
		anim_name = level._scr_anim[ "melee_knife_player" ][ "test" ];
	}

	// Spawn view rig. 
	rig = spawn( "script_model", ( 0, 0, 0 ));
	rig.angles = ( 0, 0, 0 );
	view_hands = self GetViewModel();
	rig SetModel( view_hands );
 	rig UseAnimTree( anim_tree );
	rig hide();

	// Knife. 
	rig Attach( "viewmodel_knife", "tag_weapon_left", true );

	// Match normal.
//	wait_time += 0.01;
	if (  wait_time > 0 ) 
	{
		wait( wait_time );
	}

	// Play anim. 
 	rig SetAnim( anim_name, 1, 0, 1 );

	// Link to player view. 
	self linktoplayerview( rig );

	// Hide glitch. 
	wait( 0.01 );
	rig show();

	// Cleanup.
	length = GetAnimLength( anim_name );
	wait( length - 0.01 );
	rig delete();

	self unlinkfromplayerview();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
melee_vignette_player( target, wait_time )
{
 	ground_pos_player = GetGroundPosition( self.origin, 0, 1000.0, 64.0, true );
 	if ( !IsDefined( ground_pos_player ))
	{
		wait( 0.01 );
		return false;
	}

	// Stop gameplay. 
	self FreezeControls( true );
	self disableweapons();
	self allowprone( false );
	self allowcrouch( false );
	self EnableInvulnerability();

	// Spawn anim base. 
	script_origin = Spawn( "script_origin", ground_pos_player );
	script_origin.angles = self.angles;

	// Rig starting at player orientation. 
	player_rig = spawn_anim_model( self.melee_anim_name );
	player_rig.origin = self.origin;
	player_rig.angles = self.angles;

	// Player's anim name. 
	anim_name = level._scr_anim[ self.melee_anim_name ][ self.melee_anim_quadrant ];

	// Link the player. 
	player_rig SetAnimKnob( anim_name, 1, 0, 0 );
	self PlayerLinkToBlend( player_rig, "tag_player", wait_time, 0, 0, 1 ); 

	// Link the knife. 
	if ( VIEW_ATTACHED_MELEE )
	{
		self thread play_viewmodel_melee_anim( wait_time );
//		self thread line_tests( player_rig );
	}

	knife = spawn( "script_model", ( 0, 0, 0 ));
	knife SetModel( "viewmodel_knife" );
	knife LinkTo( player_rig, "tag_weapon_left", ( 0, 0, 0 ), ( 0, 0, 0 )); 

	if ( !SCRIPTED_MELEE )
	{
		player_rig hide();
		knife hide();
	}

	// Wait the blend to rig time before we start the anim. 
	wait( wait_time );

	// Interpolate into position. 
 	player_rig moveto( self.melee_target_origin, MELEE_MOVE_TO_TIME );
	player_rig rotateto( self.melee_target_angles + ( 0, 180, 0 ), MELEE_MOVE_TO_TIME );

	// Play the anim. 
	player_rig SetAnimKnob( anim_name, 1, 0, 1 );
	length = GetAnimLength( anim_name );
	breakout_times = GetNotetrackTimes( anim_name, "melee_breakout_time" );

	// Wait until the valid breakout time. 
	if ( breakout_times.size > 0 )
	{
		pre_breakout_time = length * breakout_times[ 0 ];
	}
	else 
	{
		pre_breakout_time = length * MELEE_ANIM_BREAKOUT_PERCENT;
	}
	wait( pre_breakout_time );
	 
	// Wait for an input for breaking out of the animation. 
	post_breakout_time = length - pre_breakout_time;
	iteration_steps = post_breakout_time * 1000 / 50;
	for ( ii = 0; ii < iteration_steps; ii++ )
	{
  		if ( self IsControllerDirectionPressed() == 1 )
		{
			if ( SCRIPTED_MELEE )
			{
 				blend_out_time = MELEE_ANIM_BLENDOUT_TIME;
 				rate = post_breakout_time / blend_out_time;
 				player_rig SetAnimKnob( anim_name, 1, 0, rate );
			}
			break;
		}
		wait( 0.01 );
	}

	// Debug. 
	self notify( "end_lines" );

	// Unlink from scripted. 
	self unlink();
	player_rig delete();
	knife delete();

	// Hide glitches. 
	self FreezeControls( true );
	wait( 0.1 );
	self Setvelocity(( 0, 0, 0 ));
	self FreezeControls( false );

	// Final cleanup. 
	self ClearMeleeVignetteTarget();
	self allowprone( true );
	self allowcrouch( true );
	self DisableInvulnerability();
	self enableweapons();
	self ShowViewModel();

	return true;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
melee_vignette_actor_thread( script_origin, target )
{
	guys = [];
	guys[ target.animname  ] = target;
	script_origin anim_single( guys, self.melee_anim_quadrant );

	// Cleanup.
 	target vignette_actor_kill();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
melee_vignette_thread()
{
	anims = [ 
		[ "front", "front2" ],
		[ "right", "right2" ], 
		[ "back", "back2" ], 
		[ "left", "left2" ]
	];

	while ( 1 )
	{
		wait( 0.01 );
		self waittill( "melee_vignette", target );

		// Spawn anim origin. 
 		ground_pos = GetGroundPosition( target.origin, 0, 1000.0, 64.0, true );
 		if ( !IsDefined( ground_pos ))
		{
			continue;
		}

		// Setup the script_origin base. 
		script_origin = Spawn( "script_origin", ground_pos );
		script_origin.angles = VectorToAngles( target.origin - self.origin ) * ( 0, 1, 0 );

		// Get anim info. 
		anim_names = self get_anim_names_from_type();
		self.melee_anim_name = anim_names[ 0 ];
		self.melee_anim_name_view = anim_names[ 1 ];
		target.animname = anim_names[ 2 ];

		// Get the anim quadrant. 
		quadrant = self GetMeleeTargetQuadrant( target );
		if ( USE_RANDOM_MELEE )
		{
			rand_anim = RandomIntRange( 0, anims[ quadrant ].size );
		}
		else 
		{
			rand_anim = 0;
		}
//		IPrintLnBold( "Anim Type = " + rand_anim );
		self.melee_anim_quadrant = anims[ quadrant ][ rand_anim ];

		// Get the offset tag. 
		self melee_vignette_extract_target_player_orientation( target, script_origin );

		// Blend time into rig. 
		wait_time = MELEE_BLEND_TO_RIG_TIME;

		// Make sure the target is still alive!
		if ( !IsAlive( target ))
		{
			continue;
		}

		// Update player's animation. 
		thread melee_vignette_player( target, wait_time );
		wait( wait_time );

		// Make sure the target is still alive!
		if ( !IsAlive( target ))
		{
			continue;
		}

		// Play temp knife stab sound
		// tagBK< NOTE > Removed because asserting on nx_lava. 
//		level._player playsound("melee_knife_stab_only");

// 		Line( script_origin.origin, script_origin.origin + ( 0, 0, 100 ), (1,1,1), 1, true, 5000 );

		// Actor vignette anim. 		
		self thread melee_vignette_actor_thread( script_origin, target );
	}
}

knife_rumble_heavy( player_rig )
{
	level._player PlayRumbleOnEntity( "viewmodel_large" );
}

knife_rumble_medium( player_rig )
{
	level._player PlayRumbleOnEntity( "viewmodel_medium" );
}

knife_rumble_light( player_rig )
{
	level._player PlayRumbleOnEntity( "viewmodel_small" );
}

