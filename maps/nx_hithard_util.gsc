//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Hit Hard at Home (LA) Utility Scripts						**
//                                                                          **
//    Created: 10/11/2010 - Brian Marvin									**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_nx_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_anim;
#include maps\_hud_util;

//***************************************************************************************************************************************************************
//                                                                  																							*
// 	GENERAL				                                               																							*
//                                                                  																							*
//***************************************************************************************************************************************************************

// Add an objective start (associates a string name with the objective, puts in level.objective)
objective_start( obj_name, obj_string, obj_location, custom_tag )
{
	if( isdefined( level.objective[obj_name] ))
	{
		AssertMsg( "'" + obj_name + "' is already in use, please use a different objective name!" );
	}
	
	// Figure out what the objective number should be	
	obj_num = level.objective.size;

	// Add objective by string for reference, "actual" objective number is value
	level.objective[obj_name] = obj_num;

	// Set current objective number
	level.current_objective = obj_name;

	// If there is an object for the objective, place a marker on the object
	if( isdefined( obj_location ))
	{
		
		
		// If a custom text string is defined for the marker
		if( isdefined( custom_tag ))
		{
			Objective_Add( level.objective[obj_name], "current", obj_string );
			objective_setpointertextoverride( obj_num, custom_tag );	//Create the pointer text for objective
			objective_onentity( obj_num, obj_location );				//Put the pointer on object	
		}
		else
		{
			Objective_Add( level.objective[obj_name], "current", obj_string, obj_location.origin );
		}
	}
	else
	{
		// Add the objective
		Objective_Add( level.objective[obj_name], "current", obj_string );	
	}

	level notify( "notify_" + obj_name + "_start" );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Remove an objective (level.objective)
objective_end( obj_name )
{
	if( !isdefined( level.objective[obj_name] ))
	{
		AssertMsg( "'" + obj_name + "' is not a current objective name!" );
	}
				
	Objective_State( level.objective[obj_name], "done" );
	level.current_objective = "none";
	level notify( "notify_" + obj_name + "_end" );	
}
												   
// Move allies to start points
//		Note: all elements are processed in order.  (ex. element #0 of the array corresponds to squad member #0)
//		ARGUMENTS:
// 		(MANDATORY) "array_of_start_noteworthies" the "script_noteworthy" values for your start points (recommended to use script_origins)
//		(OPTIONAL) "array_of_goal_node_noteworthies" the "script_noteworthy" values for a node to send squadmate to 
moveAlliesToStartPoint( array_of_start_noteworthies, array_of_goal_node_noteworthies, start_is_node )
{
	if( !isdefined( start_is_node ))
	{
		start_is_node = false;
	}

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
		start_node = undefined;

		if( start_is_node )
		{
			start_node = getNode( array_of_start_noteworthies[i], "script_noteworthy" );
		}
		else
		{
			start_node = getEnt( array_of_start_noteworthies[i], "script_noteworthy" );
		}

		self[i] ForceTeleport( start_node.origin, start_node.angles );

		if( isdefined( array_of_goal_node_noteworthies ))
		{
			self[i].goalradius = 128;
			node = getNode( array_of_goal_node_noteworthies[i], "script_noteworthy" );
			self[i].script_forcegoal = 1;
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



//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Change state of threat id
SetThreatIDOverlay_array( type )
{
	if( !isdefined( type ))
	{
		AssertMsg( "SetThreatIDOverlay_array() needs to be passed a state: 'auto', 'off', 'axis', 'allies'" );
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

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Set Threat Bias group for an array of guys
SetThreatBiasGroup_array( groupname )
{
	foreach( guy in self)
	{
		if( isalive( self ))
		{
			guy SetThreatBiasGroup( groupname);
		}
	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Set an array of guys to aim at a non-AI target
SetEntityTarget_array( target )
{
	foreach( guy in self)
	{
		if( isalive( self ))
		{
			guy SetEntityTarget( target );
		}
	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Set goalradius for a group of dudes
SetGoalRadius_array( goal_radius )
{
	foreach( guy in self )
	{
		if( isalive( guy ))
		{
			guy.goalradius = goal_radius;	
		}
  	}
}

//***************************************************************************************************************************************************************
//                                                                  																							*
// 	DIALOG				                                               																							*
//                                                                  																							*
//***************************************************************************************************************************************************************

intro_dialog()
{	
	// Dialogue:  	Eagle-Two, this is Stadium-One Actual. We have a confirmed attack on LA...
	//radio_dialogue( "hithard_rad_intro_01" );

	// Dialogue: 	No shit...
	//radio_dialogue( "hithard_rev_intro_01" );

	//thread add_dialogue_line( "Rev", &"NX_HITHARD_INTRO_DIALOG_ALLY_03_NO_SHIT", "g" );
	//thread add_dialogue_line( "Rev", "No shit...", "g" );
	//wait 1;

	// Dialogue: 	...Eagle-One has been lost to enemy fire from the ground. 
	//				Troops are currently securing the stadium two clicks north of your position. 
	//				It is unsafe to extract via air. We need your team to parachute in and... 
	//				...signal failure... <bzzt> ...Transmitting coordinates… <bzzt>
	//radio_dialogue( "hithard_rad_intro_02" );

	// Dialogue: 	We've lost our SAT-COM link, 75% of the intel got through.
	//radio_dialogue( "hithard_rev_intro_02" );
	//thread add_dialogue_line( "Rev", &"NX_HITHARD_INTRO_DIALOG_ALLY_03_LOST_TRANSMISSION", "g" );
	//thread add_dialogue_line( "Rev", "We've lost our SAT-COM link, 75 percent of the intel got through.", "g" );
	//wait 1;

	// Dialogue: 	Alright.  Listen up, I'm taking point, Monk you've got six.  
	// 				The motorcade is pinned down and is under heavy fire.   
	//				After we jump, head Northwest and stay on my six.  
	//				We are landing on this parking garage here (HUD map zooms and marks).  
	//				Entry will be bumpy.  Stay close and don't fall behind!  Ready?	

	//radio_dialogue( "hithard_bak_intro_01" );

	// Dialogue: Hooah!
	//radio_dialogue_overlap( "hithard_rev_intro_03" );	

	//thread add_dialogue_line( "Squad", &"NX_HITHARD_INTRO_DIALOG_SQUAD_HOOAH", "g" );

	/*
	thread add_dialogue_line( "Gypsy", "Hooah!", "g" );	
	wait 0.25;
	thread add_dialogue_line( "Rev", "Hooah!", "g" );	
	wait 1;
	*/
	// Dialogue: Good hunting!
	//thread add_dialogue_line( "Stadium-One", &"NX_HITHARD_INTRO_DIALOG_LEADER_GOOD_HUNTING", "g" );
	//thread add_dialogue_line( "Baker", "Good hunting!", "r" );
	//radio_dialogue( "hithard_bak_intro_02" );
	
	level notify( "notify_intro_dialog_complete" );		
} 

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

falling_behind_vo_timeout()
{
	wait 10;
	return false;
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Display fail quote and fail wrapper when parachute objective failed
objective_failed( objective,  fail_message )
{	
	SetDvar( "ui_deadquote", fail_message );
	maps\_utility::missionFailedWrapper();

	// Old code for triggering "parachute fall" if currently parachuting
	/*  
	if ( flag( "_chute.gsc_flag_parachute_active" ))
	{
		maps\_chute::parachute_fail_sequence( fail_message );
	}
	else
	{
		SetDvar( "ui_deadquote", fail_message );
		maps\_utility::missionFailedWrapper();
	}
	*/
}

//*******************************************************************
//					                                              	*
//					                                              	*
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

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

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

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

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

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

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

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Turn off fixed node for an array of guys
set_fixednode_false_array()
{
	foreach( guy in self )
	{
		if( isalive( guy ))
		{
			guy set_fixednode_false();
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Turn on fixed node for an array of guys
set_fixednode_true_array()
{
	foreach( guy in self )
	{
		if( isalive( guy ))
		{
			guy set_fixednode_true();
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Deletes all enttities barricading the motorcade in between sniping and suv minigun parts of level
delete_secure_barricade()
{
	barricade_ents = getEntArray( "secure_car_barricade_1", "script_noteworthy" );
	foreach( entity in barricade_ents )
	{
		entity delete();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

delete_ai_volume_trigger_wait( targetname )
{	 
	assert( isdefined( self.target ) );
	areas = getentarray( self.target, "targetname" );
	assert( areas.size > 0 );
	
	self waittill( "trigger" );
	
	foreach( area in areas )
	{
		array_thread( area get_ai_touching_volume( "axis" ), ::delete_ai_not_bullet_shielded );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

delete_ai_volume_out_of_sight( targetname )
{	 	
	areas = getentarray( targetname, "targetname" );
	assert( areas.size > 0 );
	
	foreach( area in areas )
	{
		guys = area get_ai_touching_volume( "axis" );		
		thread AI_delete_when_out_of_sight( guys, 128 );
	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Removes all ai NOW (except bulletshielded) 
delete_all_ai_immediately()
{
	aAI = getaiarray();	
	array_thread( aAI, ::delete_ai_not_bullet_shielded );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

delete_array_of_ai( array_of_noteworthies )
{
	foreach( guy in array_of_noteworthies )
	{
		things = getentarray( guy, "script_noteworthy" );

		if( isdefined( things ))
		{
			foreach( thing in things )
			{	
				thing delete();
			}
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Randomly chooses an element of an array amd return
grab_random_array_element( array )
{
	random_num = undefined;
	random_num = randomIntRange( 0, array.size );

	return array[ random_num ]; 
}

//*******************************************************************
//				RUMBLES and SHAKES                          		*
//					                                              	*
//*******************************************************************

missile_hit_rumble()
{
	level._player PlayRumbleOnEntity( "c130_flyby" );
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
//                                                                  *
//                                                                  *
//*******************************************************************

all_triggers_off( trigger_name )
{
	triggers = GetEntArray( trigger_name, "script_noteworthy" );
	foreach( trigger in triggers )
	{
		trigger trigger_off();
	}
}

all_triggers_on( trigger_name )
{
	triggers = GetEntArray( trigger_name, "script_noteworthy" );
	foreach( trigger in triggers )
	{
		trigger trigger_on();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Checks if anyone is alive in an array
isalive_array( entities )
{
	something_lives = 0;

	foreach( thing in entities )
	{
		if( isalive( thing ))
		{
			something_lives++;
		}
	}

	return something_lives;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

// Spawn a VTOL 
spawn_vtol_from_noteworthy( vtol_noteworthy, vtol_enter_targetname, vtol_exit_targetname )
{
	spawner = GetEnt( vtol_noteworthy, "script_noteworthy" );

	if( isspawner( spawner ))
	{
		vtol = spawner spawn_vehicle();
	}
	else
	{
		vtol = spawner; 
	}

	vtol godon();

	if( IsDefined( vtol_enter_targetname ))
	{
		vtol.vtol_enter_path =  GetEnt( vtol_enter_targetname, "targetname" );
	}
	if( IsDefined( vtol_exit_targetname ))
	{ 
		vtol.vtol_exit_path = GetEnt( vtol_exit_targetname, "targetname" );
	}

	return vtol;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

// Tell VTOL to start on entry path
vtol_enter( unload )
{
	if( !IsDefined( self.vtol_enter_path ))
	{
		AssertMsg( "No enter path defined for VTOL" );
	}

	unload_vtol = true;

	if( isdefined( unload ))
	{
		unload_vtol = unload;
	}

	self.currentnode = self.vtol_enter_path;
	self Vehicle_Teleport( self.currentnode.origin, self.currentnode.angles );
	self thread vehicle_resumepath();
	self GoPath();

	if( unload_vtol )
	{
		self waittill( "reached_dynamic_path_end" );
		self SetHoverParams( 0, 10, 10 );
		self vehicle_unload();	
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

// Tell VTOL to exit 
vtol_exit()
{
	if( !IsDefined( self.vtol_exit_path ))
	{
		AssertMsg( "No exit path defined for VTOL" );
	}
	
	if( IsDefined( self.vtol_enter_path ))
	{
		self vehicle_detachfrompath();	
	}

	if( !IsDefined( self.vtol_enter_path ))	
	{
		self.currentnode = self.vtol_exit_path;
		self Vehicle_Teleport( self.currentnode.origin, self.currentnode.angles );
	}
	
	self.currentnode = self.vtol_exit_path;

	self thread vehicle_resumepath();
	self GoPath();
	self waittill( "reached_dynamic_path_end" );
	self Delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Wait a random amount of time
wait_random_time( time_low, time_high )
{
	time = RandomFloatRange( time_low, time_high );
	wait time;
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Play a random dialogue line from an array
play_random_dialogue_interupt( dialogue_array )
{
	line = grab_random_array_element( dialogue_array );
	result = radio_dialogue_interupt( line );
	return result;
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Play a random dialogue line from an array
play_random_dialogue_safe( dialogue_array )
{
	line = grab_random_array_element( dialogue_array );
	result = radio_dialogue_safe( line );
	return result;
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Play a random dialogue line from an array and remove it from the array
play_random_dialogue_safe_and_remove( dialogue_array )
{
	line = grab_random_array_element( dialogue_array );
	dialogue_array = array_remove( dialogue_array, line );
	result = radio_dialogue_safe( line );
	return dialogue_array;
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Play a random dialogue line from an array
play_random_dialogue( dialogue_array )
{
	line = grab_random_array_element( dialogue_array );
	result = radio_dialogue( line );
	return result;
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Play a random positional dialogue line from an array 
play_random_dialogue_positional( dialogue_array, animname )
{
	line = grab_random_array_element( dialogue_array );
	result = pos_dialogue( line, animname );
	return result;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Checks if anyone is alive in an array
stop_magic_bullet_shield_array()
{
	foreach( guy in self )
	{
		if( isalive( guy ))
		{
			if( isdefined( guy.magic_bullet_shield ))
			{
				guy stop_magic_bullet_shield();
			}
		}
	}	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Starts magic bullet shield
start_magic_bullet_shield_array()
{
	foreach( guy in self )
	{
		if( isalive( guy ))
		{
			if( isdefined( guy.magic_bullet_shield ))
			{
				guy thread magic_bullet_shield();
			}
		}
	}	
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Sets up SS guys for motorcade section
prep_ss_motorcade_array()
{
	foreach( guy in self )
	{
		guy prep_ss_motorcade();
		guy disable_cqbwalk();
	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Sets up SS guys for motorcade section
prep_ss_motorcade()
{
	self maps\nx_hithard_anim::init_ss_anims();
	self thread magic_bullet_shield_safe();
}


//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

magic_bullet_shield_safe()
{
	if( isdefined( self.Melee ))
	{
		while( isdefined( self.Melee ))
		{
			wait 0.05;
		}
	}
	self thread magic_bullet_shield();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vp_protect_at_node( actor_vp, actor_ss )
{
	self.vp_protect = true;
	actor_vp.animname = "vp";
	actor_ss.animname = "ss";
	actor_ss disable_cqbwalk();
	guys = [ actor_vp, actor_ss ];
	//self anim_reach_together( guys, "vp_arrival_in" );

	self thread anim_reach_solo( actor_vp, "vp_arrival_in" );
	wait 0.3;
	self anim_reach_solo( actor_ss, "vp_arrival_in" );

	waittillframeend;
	self notify( "reach_done" );
	self anim_single( guys, "vp_arrival_in" );	
	self anim_single( guys, "vp_arrival_out" );	
	self notify( "vp_arrival_out" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vp_protect_idle( guys )
{
	self endon( "vp_protect_end" );
	while( 1 )
	{
		self anim_single( guys, "vp_arrival_idle" );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vp_protect_end()
{
	if( !IsDefined( self.vp_protect ) || !self.vp_protect )
		return;
	self.vp_protect = false;
	waittillframeend;
	self notify ( "vp_protect_end" );
	self waittill( "vp_arrival_out" );
}



