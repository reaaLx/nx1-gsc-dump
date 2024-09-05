//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Mission Utils												**
//                                                                          **
//    Created: DATE - CREATOR												**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_anim;
 

// Move allies to start points
//		Note: all elements are processed in order.  (ex. element #0 of the array corresponds to squad member #0)
//		ARGUMENTS:
// 		(MANDATORY) "array_of_start_noteworthies" the "script_noteworthy" values for your start points (recommended to use script_origins)
//		(OPTIONAL) "array_of_goal_node_noteworthies" the "script_noteworthy" values for a node to send squadmate to 
moveAlliesToStartPoint( array_of_start_noteworthies, array_of_goal_node_noteworthies )
{
	if( self.size != array_of_start_noteworthies.size )
	{
		AssertMsg( "Number of allies ( " + self.size + ") does not equal number of start points (" + array_of_start_noteworthies.size + ")" );
	}
	else if( isdefined( array_of_goal_node_noteworthies )) 
	{
		if( self.size != array_of_goal_node_noteworthies.size )
		{
			AssertMsg( "Number of allies ( " + self.size + ") does not equal number of goal nodes (" + array_of_start_noteworthies.size + ")" );
		}
	}

	for( i = 0; i < self.size; i++ )
	{
		start_node = getEnt( array_of_start_noteworthies[i], "script_noteworthy" );
		self[i] ForceTeleport( start_node.origin, start_node.angles );

		if( isdefined( array_of_goal_node_noteworthies ))
		{
			node = getNode( array_of_goal_node_noteworthies[i], "script_noteworthy" );
			self[i] SetGoalNode( node );
		}
	}
} 
											   
//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Run an autosave on the notify message "notify_message" sent to self
autosave_on_notify( notify_message )
{
	self waittill( notify_message );
	thread autosave_now();
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Fade to black at the end of the level
fade_out_level()
{
	fadeInTime = 1.0;
	
	//setSavedDvar( "compass", 0 );
	//setSavedDvar( "hud_showStance", 0 );
	
	overlay = newHudElem();
	overlay.x = 0;
	overlay.y = 0;
	overlay setshader( "black", 640, 480 );
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	
	overlay.alpha = 0;
	overlay fadeOverTime( fadeInTime );
	overlay.alpha = 1;
	
	wait fadeInTime;
	
	level._player freezeControls( true );
	enablePlayerWeapons( false );
}


boundary_breach_kill_triggers()
{
	// Wait for player to break boundary
	flag_wait( "boundary_breach" );

	// While in the smoke
	while ( flag( "boundary_breach" ) )
	{
//		level._player display_hint( "hint_parachute_smoke" );

		level._player PlayRumbleOnEntity( "grenade_rumble" );
		level._player StunPlayer( 1.5 );

		if ( level._player.health <= 65 )
		{
			SetDvar( "ui_deadquote", "The UGVs have these areas covered." );
			maps\_utility::missionFailedWrapper();
		}
		else
		{
			level._player.health = level._player.health - 35;
		}

		wait 0.5;
	}
	
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Turns on threat detect tech
set_threat_detect_on( type )
{
	if( !isdefined( type ))
	{
		type = "auto";
	}

	foreach( guy in self )
	{
		if( isalive( guy ))
		{
			guy SetThreatIDOverlay( type );
		}
	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Detects player intervention against AIs through nearly all means
set_flag_on_player_action( flag_str, flash, grenade )
{
	level notify( "kill_action_flag" );
	level endon( "kill_action_flag" );
	level endon( flag_str );

	if ( flag( flag_str ) )
		return;

	while ( true )
	{
		msg = level._player waittill_any_return( "weapon_fired", "fraggrenade", "flash_grenade" );
		if ( !isdefined( msg ) )
			break;
		if ( msg == "weapon_fired" )
			break;
		if ( msg == "fraggrenade" && isdefined( grenade ) )
			break;
		if ( msg == "flash_grenade" && isdefined( flash ) )
			break;
	}

	flag_set( flag_str );
}

//*******************************************************************
//		Secret Service and VP scripting                	*
//					                                              	*
//*******************************************************************

ss_vignette_move( target_node, vp, ss, pain )
{
    vp endon( "death" );
    vp notify( "stop_vignette" );
    vp endon( "stop_vignette" );
    
    actors = [];
    actors[ "vp_price" ] = vp;
    actors[ "ss_williams" ] = ss;

	if ( !pain )
	{
		vp disable_pain();
		ss disable_pain();
	}

    current_node = vp.current_vignette_node;
    if ( isdefined( vp.current_vignette_node ) )
    {
        vp.current_vignette_node anim_single( actors, "vp_arrival_out" );
        vp.current_vignette_node = undefined;
    }

    target_node anim_reach_together( actors, "vp_arrival_in" );
    target_node anim_single( actors, "vp_arrival_in" );
    vp.current_vignette_node = target_node;

    vp thread ss_vignette_idle( target_node, actors );
}

ss_vignette_idle( target_node, guys )
{
    self endon( "stop_vignette" );
    while ( 1 )
    {
        target_node anim_single( guys, "vp_arrival_idle" );
    }
}

ss_vignette_end( vp, ss )
{
    vp endon( "death" );
    vp notify( "stop_vignette" );
    
	if ( isdefined( vp.current_vignette_node ) )
    {
		actors = [];
		actors[ "vp_price" ] = vp;
		actors[ "ss_williams" ] = ss;
        vp.current_vignette_node anim_single( actors, "vp_arrival_out" );
        vp.current_vignette_node = undefined;
    }

	level notify( "vp_vignette_finished" );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Turns off threat detect tech
set_threat_detect_off()
{
	foreach( guy in self )
	{
		if( isalive( guy ))
		{
			guy SetThreatIDOverlay( "off" );		
		}
	}
}

SetThreatBiasGroup_array( groupname )
{
	foreach( guy in self)
	{
		guy SetThreatBiasGroup( groupname);
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Sets "ignoreme" variable for all actors in an array
ignore_me_on()
{
	foreach( guy in self)
	{
		if( isalive( guy ))
		{
			guy.ignoreme = true;
		}
	}
}

// Clears "ignoreme" variable for all actors in an array
ignore_me_off()
{
	foreach( guy in self)
	{
		if( isalive( guy ))
		{
			guy.ignoreme = false;
		}
	}
}

// Sets "ignoreall" variable for all actors in an array
ignore_all_on()
{
	foreach( guy in self)
	{
		if( isalive( guy ))
		{
			guy.ignoreall = true;
		}
	}
}

// Clears "ignoreall" variable for all actors in an array
ignore_all_off()
{
	foreach( guy in self)
	{
		if( isalive( guy ))
		{
			guy.ignoreall = false;
		}
	}
}

cqb_handling( a_guys, setting )
{
	if ( setting == "on" )
	{
		foreach( guy in a_guys )
		{
			guy enable_cqbwalk();
		}
	}
	else
	{
		foreach( guy in a_guys )
		{
			guy disable_cqbwalk();
		}
	}
}

//*******************************************************************
//				RUMBLES and SHAKES                          	*
//					                                              	*
//*******************************************************************

missile_hit_rumble()
{
	level._player PlayRumbleOnEntity( "artillery_rumble" );
	level thread screenshake( .2, 5, 1, 4 );

	wait 1.5;
	level._player thread blend_movespeedscale( 0.1, 1.5 );

	loops = int( 0.75 * 20 );
	up_target_angle = -8;
	for ( i = 0; i < loops; i++ )
	{
		player_angles = level._player getplayerangles();
		up_angle = player_angles[0];

		angle_step = ( up_target_angle - up_angle ) / ( loops - (i) ); 
		angle_step = cap_value( angle_step, -1.5, 1.5 );

		level._player setplayerangles( player_angles + ( angle_step, 0, 0 ) );
		wait 0.05;
	}

	level._player thread blend_movespeedscale( 1, 1 );
}

RUMBLE_FRAMES_PER_SEC = 10;
screenshake( scale, duration, fade_in, fade_out)
{
	if ( !isdefined( fade_in ) )
		fade_in = 0;
	if ( !isdefined( fade_out ) )
		fade_out = 0;

	assert( ( fade_in + fade_out ) <= duration );

	frame_count = duration * RUMBLE_FRAMES_PER_SEC;
	fade_in_frame_count = fade_in * RUMBLE_FRAMES_PER_SEC;
	if ( fade_in_frame_count > 0 )
		fade_in_scale_step = scale / fade_in_frame_count;
	else
		fade_in_scale_step = scale;

	fade_out_frame_count = fade_out * RUMBLE_FRAMES_PER_SEC;
	fade_out_start_frame = frame_count - fade_out_frame_count;
	if ( fade_out_frame_count > 0 )
		fade_out_scale_step = scale / fade_out_frame_count;
	else
		fade_out_scale_step = scale;

	delay = 1/RUMBLE_FRAMES_PER_SEC;
	scale = 0;
	for ( i = 0; i < frame_count; i++ )
	{
		if ( i <= fade_in_frame_count )
			scale += fade_in_scale_step;

		if ( i > fade_out_start_frame )
			scale -= fade_out_scale_step;

		earthquake( scale, delay, level._player.origin, 500 );
		wait delay;
	}
}

//*******************************************************************
//				DOORS                          	*
//			    via Justin's testmap utilities (possibly make these global)                	*
//*******************************************************************


// Makes a movable door object out of any prefab that has a script_origin
make_door_from_prefab( sTargetname, openangles, closeangles )
{
	// Get all the entities inside sTargetname prefab object
	ents = getentarray( sTargetname, "targetname" );
	door_org = undefined;	// Door origin, the hinge
	door_models = [];
	door_brushes = [];
	foreach( ent in ents )
	{
		// If the entity is a brushmodel
		if ( ent.code_classname == "script_brushmodel" )
		{
			door_brushes[ door_brushes.size ] = ent; // Add it to the list of brushes
			continue;
		}
		// If the entity is a script_origin
		if ( ent.code_classname == "script_origin" )
		{
			door_org = ent;	// Save it as the hinge
			continue;
		}
		// If the entity is a script_model
		if ( ent.code_classname == "script_model" )
		{
			door_models[ door_models.size ] = ent; // Add it to the list of models
			continue;
		}
	}
	
	// Link everything to the origin so it moves (rotates) together as one object
	foreach( model in door_models )
		model linkto( door_org );
	foreach( brush in door_brushes )
		brush linkto( door_org );
	
	door = door_org;
	//door.brushes = door_brushes; // Not used
	
	door.openangles = openangles;
	door.closeangles = closeangles;

	return door;
}

// Open a door opject that was made with make_door_from_prefab() 
door_open( bFast )
{
	// Wait untill current move command is finished before starting a new one
	if ( isdefined( self.moving ) )
	{
		while( isdefined( self.moving ) )
			wait( 0.05 );
	}
	
	self.moving = true;
	angles = 90;
	if ( isdefined( self.openangles ) )
		angles = self.openangles;
	
	iTime = 4;
	if ( isdefined( bFast ) )  // Open swiftly
	{
		iTime = 1.5;
//	        self thread play_sound_on_entity( "nx_scn_training_fence_open_fast" );
		self rotateto( self.angles + ( 0, angles, 0 ), 1.5, .25, .25 );
	}
	else
	{
//	        self thread play_sound_on_entity( "nx_scn_training_fence_open" );
		self rotateto( self.angles + ( 0, angles, 0 ), 4, 1.5, 1.5 );
	}

	//self thread play_sound_on_entity( "scn_training_fence_open" );
	//array_call( self.brushes,::notsolid );
	wait( iTime );	// Wait for the door to open
	self.moving = undefined; // No longer moving
}


// Close a door object that was made with make_door_from_prefab()
door_close( bFast )
{
	if ( isdefined( self.moving ) )
	{
		while( isdefined( self.moving ) )
			wait( 0.05 );
	}
	
	self.moving = true;
	angles = -90;
	if ( isdefined( self.closeangles ) )
		angles = self.closeangles;

	iTime = 2;
	if ( isdefined( bFast ) ) // Open swiftly
	{
		iTime = 1;
		self rotateto( self.angles + ( 0, angles, 0 ), 1, .25, .25 );
	}
	else
	{
		self rotateto( self.angles + ( 0, angles, 0 ), 2, .5, .5 );
	}
  
	//self thread play_sound_on_entity( "scn_training_fence_close" );
	//array_call( self.brushes,::solid );

	wait( iTime ); // Wait for the door to open
	self.moving = undefined; // No longer moving
}

//*******************************************************************
//                                                                  *
//                   VTOL Jazz                                      *
//                                                                  *
//*******************************************************************

vtol_setup( vtol_name, vtol_noteworthy, vtol_enter_targetname, vtol_exit_targetname )
{
	if( !IsDefined( level.vtols ) )
		level.vtols = [];

	level.vtols[ vtol_name ] = [];
	level.vtols[ vtol_name ][ "spawner" ]		= GetEnt( vtol_noteworthy, "script_noteworthy" );
	level.vtols[ vtol_name ][ "enter" ]			= GetEnt( vtol_enter_targetname, "targetname" );
	level.vtols[ vtol_name ][ "exit" ]			= GetEnt( vtol_exit_targetname, "targetname" );
}

vtol_spawn( vtol_name )
{
	vtol = level.vtols[ vtol_name ][ "spawner" ] spawn_vehicle();
	vtol.vtol_enter_path = level.vtols[ vtol_name ][ "enter" ];
	vtol.vtol_exit_path = level.vtols[ vtol_name ][ "exit" ];
	return vtol;
}

vtol_enter( do_unload )
{
	if( !IsDefined( self.vtol_enter_path ) )
		return;

	self.currentnode = self.vtol_enter_path;
	self Vehicle_Teleport( self.currentnode.origin, self.currentnode.angles );
	self thread vehicle_resumepath();
	self GoPath();
	self waittill( "reached_dynamic_path_end" );

	if( !IsDefined( do_unload ) )
		do_unload = true;

	if( do_unload )
	{
		self vehicle_unload();
		self playsound("nx_npc_fastrope");
	}
}

vtol_exit()
{
	if( !IsDefined( self.vtol_exit_path ) )
		return;

	self vehicle_detachfrompath();

	self.currentnode = self.vtol_exit_path;
	self thread vehicle_resumepath();
	self GoPath();
	self waittill( "reached_dynamic_path_end" );
	self Delete();
}

vtol_move( do_unload, exit_delay )
{
	if( !IsDefined( exit_delay ) )
		exit_delay = 15.0;

	if( !IsDefined( do_unload ) )
		do_unload = true;

	self vtol_enter( do_unload );
	wait exit_delay;
	self notify ( "exiting" );
	self vtol_exit();
}


// Turns a group of triggers off
all_triggers_off( trigger_name )
{
	triggers = GetEntArray( trigger_name, "script_noteworthy" );
	foreach( trigger in triggers )
	{
		trigger trigger_off();
	}
}

// Turns a group of triggers on
all_triggers_on( trigger_name )
{
	triggers = GetEntArray( trigger_name, "script_noteworthy" );
	foreach( trigger in triggers )
	{
		trigger trigger_on();
	}
}

