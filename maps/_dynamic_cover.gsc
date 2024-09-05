#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;

//A semi-generic dynamic cover system. Each of the different types of dynamic cover have their own behavior, 
//but share some scripts so they're being all wrapped up in here.

//Each unique instance needs it's own script_noteworthy.
main()
{
	dynamic_cover_precache();

	setup_player_anims();
	setup_script_model_anims();
	setup_generic_human_anims();

	table_triggers = GetEntArray( "dynamic_cover_table_flip", "targetname" );
	array_thread( table_triggers, ::monitor_table_flip );

	table_triggers = GetEntArray( "dynamic_cover_small_table_flip", "targetname" );
	array_thread( table_triggers, ::monitor_small_table_flip );

	table_triggers = GetEntArray( "dynamic_cover_slide_exam_table_right", "targetname" );
	array_thread( table_triggers, ::monitor_exam_table_slide, "right" );

	table_triggers = GetEntArray( "dynamic_cover_slide_exam_table_left", "targetname" );
	array_thread( table_triggers, ::monitor_exam_table_slide, "left" );

	table_triggers = GetEntArray( "dynamic_cover_vending_machine_tip_right", "targetname" );
	array_thread( table_triggers, ::monitor_vending_machine_tip, "right" );

	table_triggers = GetEntArray( "dynamic_cover_vending_machine_tip_left", "targetname" );
	array_thread( table_triggers, ::monitor_vending_machine_tip, "left" );
}

dynamic_cover_precache()
{
	precacheModel( "viewhands_player_us_army" );
}

#using_animtree( "player" );
setup_player_anims()
{
	level._scr_animtree[ "player_hands" ]										= #animtree;
	level._scr_model[ "player_hands" ]											= "viewhands_player_us_army";
	level._scr_anim[ "player_hands" ][ "player_table_flip" ]					= %nx_fp_dynamic_cover_table;
	level._scr_anim[ "player_hands" ][ "player_small_table_flip" ]				= %nx_fp_dynamic_cover_table_small;
	level._scr_anim[ "player_hands" ][ "player_table_slide_right" ]				= %nx_fp_dynamic_cover_examtable_2R;
	level._scr_anim[ "player_hands" ][ "player_table_slide_left" ]				= %nx_fp_dynamic_cover_examtable_2L;
	level._scr_anim[ "player_hands" ][ "player_vend_mach_right" ]				= %nx_fp_dynamic_cover_soda_machine_S_2R;
	level._scr_anim[ "player_hands" ][ "player_vend_mach_left" ]				= %nx_fp_dynamic_cover_soda_machine_S_2L;

	// Crouch versions. 
 	level._scr_player_anim_crouch = [];
	level._scr_player_anim_crouch[ "player_vend_mach_right" ]		= true;
	level._scr_player_anim_crouch[ "player_vend_mach_left" ]		= true;
	level._scr_player_anim_crouch[ "player_table_flip" ]		    = true;
	level._scr_player_anim_crouch[ "player_small_table_flip" ]		= true;
	level._scr_player_anim_crouch[ "player_table_slide_left" ]		= true;
	level._scr_player_anim_crouch[ "player_table_slide_right" ]		= true;

	addNotetrack_customFunction( "player_hands", "rumble_heavy", ::DynamicCover_rumble_heavy ); 
	addNotetrack_customFunction( "player_hands", "rumble_medium", ::DynamicCover_rumble_medium );
	addNotetrack_customFunction( "player_hands", "rumble_light", ::DynamicCover_rumble_light );
	
}

#using_animtree( "script_model" );
setup_script_model_anims()
{
	level._scr_animtree[ "dynamic_cover_table" ]								= #animtree;
	level._scr_model[ "dynamic_cover_table" ]									= "dynamic_cover_table";
	level._scr_anim[ "dynamic_cover_table" ][ "player_table_flip" ]				= %nx_pr_dynamic_cover_table;	
	level._scr_anim[ "dynamic_cover_table" ][ "actor_table_flip" ]				= %tp_hospital_flip_over_front_table;	

	level._scr_animtree[ "dynamic_cover_small_table" ]							= #animtree;
	level._scr_model[ "dynamic_cover_small_table" ]								= "nx_dynamic_cover_table_02";
	level._scr_anim[ "dynamic_cover_small_table" ][ "player_small_table_flip" ]	= %nx_pr_dynamic_cover_table_small;	
	level._scr_anim[ "dynamic_cover_small_table" ][ "actor_small_table_flip" ]	= %nx_pr_dynamic_cover_table_small;	

	level._scr_animtree[ "dynamic_cover_exam_table" ]							= #animtree;
	level._scr_model[ "dynamic_cover_exam_table" ]								= "nx_exam_table";
	level._scr_anim[ "dynamic_cover_exam_table" ][ "player_table_slide_right" ]	= %nx_pr_dynamic_cover_examtable_2R;	
	level._scr_anim[ "dynamic_cover_exam_table" ][ "actor_table_slide_right" ]	= %tp_hospital_slide_examtable_R_props;	
	level._scr_anim[ "dynamic_cover_exam_table" ][ "player_table_slide_left" ]	= %nx_pr_dynamic_cover_examtable_2L;	
	level._scr_anim[ "dynamic_cover_exam_table" ][ "actor_table_slide_left" ]	= %tp_hospital_slide_examtable_L_props;	

	level._scr_animtree[ "dynamic_cover_vend_mach" ]							= #animtree;
	level._scr_model[ "dynamic_cover_vend_mach" ]								= "dynamic_cover_soda_machine";
	level._scr_anim[ "dynamic_cover_vend_mach" ][ "player_vend_mach_right" ]	= %nx_pr_dynamic_cover_soda_machine_S_2R;	
	level._scr_anim[ "dynamic_cover_vend_mach" ][ "actor_vend_mach_right" ]		= %pr_hospital_soda_fall_R;	
	level._scr_anim[ "dynamic_cover_vend_mach" ][ "player_vend_mach_left" ]		= %nx_pr_dynamic_cover_soda_machine_S_2L;	
	level._scr_anim[ "dynamic_cover_vend_mach" ][ "actor_vend_mach_left" ]		= %pr_hospital_soda_fall_L;	
}

#using_animtree( "generic_human" );
setup_generic_human_anims()
{
	//these names should match the targetname for script simplicity.
	level._scr_animtree[ "actor_dynamic_cover_table" ]							= #animtree;
	level._scr_anim[ "actor_dynamic_cover_table" ][ "actor_table_flip" ]		= %tp_hospital_flip_over_front;
	level._scr_anim[ "actor_dynamic_cover_table" ][ "actor_table_slide_right" ] = %tp_hospital_slide_examtable_R;
	level._scr_anim[ "actor_dynamic_cover_table" ][ "actor_table_slide_left" ]	= %tp_hospital_slide_examtable_L;
	level._scr_anim[ "actor_dynamic_cover_table" ][ "actor_small_table_flip" ]	= %tp_hospital_flip_over_front;
	level._scr_anim[ "actor_dynamic_cover_table" ][ "actor_vend_mach_right" ]	= %tp_hospital_soda_fall_R;
	level._scr_anim[ "actor_dynamic_cover_table" ][ "actor_vend_mach_left" ]	= %tp_hospital_soda_fall_L;

}

monitor_table_flip()
{
	self endon( "abort" );
	assertEx( IsDefined( self.script_noteworthy ), "dynamic_cover prefab at position " + vector_string( self.origin ) + " is missing a unique script_noteworthy" );
	
	self table_flip_params();

	/#
	self check_for_duplicated_unique_name(); //do a test to verify that each dynamic_cover has been given a unique script_noteworthy.
	#/
	
	//disconnected by default. Reconnect and then move the geo out of the way so the player or actors dont collide.
	self reconnect_paths( self.collision_block ); 
	self hide_blocking_geo( self.collision_block );
	self hide_blocking_geo( self.traversal_block );

	self thread monitor_table_flip_triggers();
	self thread monitor_actor_table_flip();

	//wait until the player or an actor flips the table.
	self waittill( "table_flip" );

	self.dynamic_cover_activated = true;

	//now enable the traversal

	self reconnect_paths( self.init_collision_block );
	self hide_blocking_geo( self.init_collision_block );
	self unhide_blocking_geo( self.traversal_block );
	self reconnect_paths( self.traversal_block );	
	//self hide_blocking_geo( self.traversal_block );
	self unhide_blocking_geo( self.collision_block );
	self disconnect_paths( self.collision_block ); 

}

//called on a trigger_use entity.
monitor_table_flip_triggers()
{
	self endon( "table_flip" );
	self endon( "dynamic_cover_ai_activate" );

	self SetHintString( &"SCRIPT_HINT_FLIP_TABLE" );
	self UseTriggerRequireLookAt();
	self thread monitor_trigger_view_direction( "table_flip" );
	
	//wait until the player selects to use the table.
	self waittill( "trigger" );

	self MakeUnusable();

	//lets flip the table!
	self player_animate_dynamic_cover( "player_table_flip", "dynamic_cover_table" );
	
	level notify( "table_flip" );
	self notify( "table_flip" ); //must be the last line in the script because the script ends on the same endon.
}

monitor_actor_table_flip()
{
	self endon( "table_flip" );
	self endon( "dynamic_cover_player_activate" );

	self waittill( "actor_activate", actor ); //wait until

	self MakeUnusable();

	//play the vignette.
	self actor_animate_dynamic_cover( actor, "actor_table_flip", "actor_dynamic_cover_table", "dynamic_cover_table" );

	actor set_closest_node_as_goal( self.end_cover_nodes );

	level notify( "table_flip" );
	self notify( "table_flip" ); //must be the last line in the script because the script ends on the same endon.
}

monitor_small_table_flip()
{
	self endon( "abort" );
	assertEx( IsDefined( self.script_noteworthy ), "dynamic_cover prefab at position " + vector_string(self.origin) + " is missing a unique script_noteworthy" );
	
	self table_flip_params();

	/#
	self check_for_duplicated_unique_name(); //do a test to verify that each dynamic_cover has been given a unique script_noteworthy.
	#/
	
	//disconnected by default. Reconnect and then move the geo out of the way so the player or actors dont collide.
	self reconnect_paths( self.collision_block ); 
	self hide_blocking_geo( self.collision_block );
	self hide_blocking_geo( self.traversal_block );

	self thread monitor_small_table_flip_triggers();
	self thread monitor_actor_small_table_flip();

	//wait until the player or an actor flips the table.
	self waittill( "table_flip" );

	self.dynamic_cover_activated = true;

	//now enable the traversal

	self reconnect_paths( self.init_collision_block );
	self hide_blocking_geo( self.init_collision_block );
	self unhide_blocking_geo( self.traversal_block );
	self reconnect_paths( self.traversal_block );	
	//self hide_blocking_geo( self.traversal_block );
	self unhide_blocking_geo( self.collision_block );
	self disconnect_paths( self.collision_block ); 

}

//called on a trigger_use entity.
monitor_small_table_flip_triggers()
{
	self endon( "table_flip" );
	self endon( "dynamic_cover_ai_activate" );

	self SetHintString( &"SCRIPT_HINT_FLIP_TABLE" );
	self UseTriggerRequireLookAt();
	self thread monitor_trigger_view_direction( "table_flip" );
	
	//wait until the player selects to use the table.
	self waittill( "trigger" );

	self MakeUnusable();

	//lets flip the table!
	self player_animate_dynamic_cover( "player_small_table_flip", "dynamic_cover_small_table" );
	
	level notify( "table_flip" );
	self notify( "table_flip" ); //must be the last line in the script because the script ends on the same endon.
}

monitor_actor_small_table_flip()
{
	self endon( "table_flip" );
	self endon( "dynamic_cover_player_activate" );

	self waittill( "actor_activate", actor ); //wait until

	self MakeUnusable();

	//play the vignette.
	self actor_animate_dynamic_cover( actor, "actor_small_table_flip", "actor_dynamic_cover_table", "dynamic_cover_small_table" );

	actor set_closest_node_as_goal( self.end_cover_nodes );

	level notify( "table_flip" );
	self notify( "table_flip" ); //must be the last line in the script because the script ends on the same endon.
}

table_flip_params()
{
	self.dynamic_cover_root = true;
	self.dynamic_cover_activated = false;
	self.script_models = find_entity_by_targetname( "dynamic_cover_table" );
	self.collision_block = find_entity_by_targetname( "collision_block" );
	self.init_collision_block = find_entity_by_targetname( "init_collision_block" );
	self.traversal_block = find_entity_by_targetname( "traversal_block" ); 
	self.anim_start = find_first_ent_by_targetname( "anim_start" );
	self.player_avoid_volume = find_first_ent_by_targetname( "player_avoid_volume" );
	self.end_cover_nodes = find_nodes_by_targetname( "end_cover" );
}

//external script to trigger flipping of a specific table.
actor_table_flip( script_noteworthy )
{
	external_actor_activate( script_noteworthy, "dynamic_cover_table_flip" );
}

//external script to trigger flipping of a specific table.
actor_small_table_flip( script_noteworthy )
{
	external_actor_activate( script_noteworthy, "dynamic_cover_small_table_flip" );
}

//a placeholder until there is an animation. Just lerp it to the position we want.
placeholder_fake_table_flip()
{
	time = 0.5;

	foreach( table in self.script_models )
	{
		table MoveTo( table.origin + (0, -2, 40), time );
		table RotateTo( (270, 90, 0), time );
	}

	wait time;

	self notify( "anim_complete");
}

monitor_exam_table_slide( direction )
{
	self endon( "abort" );
	assertEx( IsDefined( self.script_noteworthy ), "dynamic_cover prefab at position " + vector_string(self.origin) + " is missing a unique script_noteworthy" );
	
	self complex_dynamic_cover_params();

	/#
	self check_for_duplicated_unique_name(); //do a test to verify that each dynamic_cover has been given a unique script_noteworthy.
	#/
	
	//disconnected by default. Reconnect and then move the geo out of the way so the player or actors dont collide.
	self reconnect_paths( self.end_collision ); 
	self hide_blocking_geo( self.end_collision );

	self thread monitor_exam_table_slide_triggers( direction );
	self thread monitor_actor_exam_table_slide( direction );

	//wait until the player or an actor flips the table.
	self waittill( "table_slide" );

	self.dynamic_cover_activated = true;

	//now enable the traversal and the cover nodes.
	self reconnect_paths( self.start_collision );
	self hide_blocking_geo( self.start_collision );
	self unhide_blocking_geo( self.end_collision );
	self disconnect_paths( self.end_collision ); 

}

monitor_exam_table_slide_triggers( direction )
{
	self endon( "table_slide" );
	self endon( "dynamic_cover_ai_activate" );

	self SetHintString( &"SCRIPT_HINT_SLIDE_TABLE" );
	self UseTriggerRequireLookAt();
	self thread monitor_trigger_view_direction( "table_slide" );
	
	//wait until the player selects to use the table.
	self waittill( "trigger" );

	self MakeUnusable();

	//lets slide the table!
	self player_animate_dynamic_cover( "player_table_slide_" + direction, "dynamic_cover_exam_table" );
	//self placeholder_fake_table_slide( );
	
	level notify( "table_slide" );
	self notify( "table_slide" ); //must be the last line in the script because the script ends on the same endon.
}

monitor_actor_exam_table_slide( direction )
{
	self endon( "table_slide" );
	self endon( "dynamic_cover_player_activate" );

	self waittill( "actor_activate", actor ); //wait until

	self MakeUnusable();

	//play the vignette.
	self actor_animate_dynamic_cover( actor, "actor_table_slide_" + direction, "actor_dynamic_cover_table", "dynamic_cover_exam_table" );

	actor set_closest_node_as_goal( self.end_cover_nodes );

	level notify( "table_slide" );
	self notify( "table_slide" ); //must be the last line in the script because the script ends on the same endon.
}

//external script to trigger flipping of a specific table.
actor_exam_table_slide( script_noteworthy )
{
	external_actor_activate( script_noteworthy, "dynamic_cover_slide_exam_table_left", "dynamic_cover_slide_exam_table_right" );
}

placeholder_fake_table_slide( )
{
	time = 0.5;

	foreach( table in self.script_models )
	{
		offset = -76 * VectorNormalize(AnglesToRight( table.angles ));
		table MoveTo( table.origin + offset, time );
	}

	wait time;

	self notify( "anim_complete");
}

monitor_vending_machine_tip( direction )
{
	self endon( "abort" );
	assertEx( IsDefined( self.script_noteworthy ), "dynamic_cover prefab at position " + vector_string(self.origin) + " is missing a unique script_noteworthy" );
	
	self complex_dynamic_cover_params();

	/#
	self check_for_duplicated_unique_name(); //do a test to verify that each dynamic_cover has been given a unique script_noteworthy.
	#/
	
	//disconnected by default. Reconnect and then move the geo out of the way so the player or actors dont collide.
	self reconnect_paths( self.end_collision ); 
	self hide_blocking_geo( self.end_collision );
	self hide_blocking_geo( self.end_cover );
	self reconnect_paths( self.start_cover ); 
	self hide_blocking_geo( self.start_cover );

	self thread monitor_vending_machine_tip_triggers( direction );
	self thread monitor_vending_machine_tip_actor( direction );

	//wait until the player or an actor flips the table.
	self waittill( "dynamic_cover_activate" );

	self.dynamic_cover_activated = true;

	//now enable the traversal and the cover nodes.
	self reconnect_paths( self.start_collision );
	self hide_blocking_geo( self.start_collision );
	self unhide_blocking_geo( self.end_collision );
	self disconnect_paths( self.end_collision ); 
	
	//enable the nodes.
	self unhide_blocking_geo( self.end_cover );
	self reconnect_paths( self.end_cover );
	self hide_blocking_geo( self.end_cover );

	//disable the starting cover.
	self unhide_blocking_geo( self.start_cover );
	self disconnect_paths( self.start_cover );
	self hide_blocking_geo( self.start_cover );
}

monitor_vending_machine_tip_triggers( direction )
{
	self endon( "dynamic_cover_activate" );
	self endon( "dynamic_cover_ai_activate" );

	self SetHintString( &"SCRIPT_HINT_VENDING_MACHINE_TIP" );
	self UseTriggerRequireLookAt();
	self thread monitor_trigger_view_direction( "dynamic_cover_activate" );
	
	//wait until the player selects to use the table.
	self waittill( "trigger" );

	self MakeUnusable();

	//lets slide the table!
	level._player playsound( "scn_hospital_vending_push_plr" );
	self player_animate_dynamic_cover( "player_vend_mach_" + direction, "dynamic_cover_vend_mach" );
	//self placeholder_fake_vending_machine_tip( direction );
	
	level notify( "dynamic_cover_activate" );
	self notify( "dynamic_cover_activate" ); //must be the last line in the script because the script ends on the same endon.
}

monitor_vending_machine_tip_actor( direction )
{
	self endon( "dynamic_cover_activate" );
	self endon( "dynamic_cover_player_activate" );

	self waittill( "actor_activate", actor ); //wait until

	self MakeUnusable();

	//play the vignette.	
	self actor_animate_dynamic_cover( actor, "actor_vend_mach_" + direction, "actor_dynamic_cover_table", "dynamic_cover_vend_mach" );	
	//self placeholder_fake_vending_machine_tip( direction );

	actor set_closest_node_as_goal( self.end_cover_nodes );

	level notify( "dynamic_cover_activate" );
	self notify( "dynamic_cover_activate" ); //must be the last line in the script because the script ends on the same endon.
}

//external script to trigger flipping of a specific table.
actor_vending_machine_tip( script_noteworthy )
{
	external_actor_activate( script_noteworthy, "dynamic_cover_vending_machine_tip_left", "dynamic_cover_vending_machine_tip_right" );
}

placeholder_fake_vending_machine_tip( direction )
{
	time = 0.5;

	foreach( table in self.script_models )
	{
		offset = (-20 * VectorNormalize(AnglesToForward( table.angles ))) + ( 0, 0, 20 );
		pitch = 90;
		if( direction == "left" )
		{
			pitch = -1 * pitch;
		}
		table MoveTo( table.origin + offset, time );
		table RotatePitch( -90, time );
	}

	wait time;

	self notify( "anim_complete");
}

/////////////////////////////////////////////////////////////////
//Some Utility scripts.
/////////////////////////////////////////////////////////////////

complex_dynamic_cover_params()
{
	self.dynamic_cover_root = true;
	self.dynamic_cover_activated = false;
	self.script_models = find_entity_by_targetname( "dynamic_cover_model" );
	self.anim_start = find_first_ent_by_targetname( "anim_start" );
	self.end_cover_nodes = find_nodes_by_targetname( "end_cover" );
	self.start_collision = find_entity_by_targetname( "start_position" );
	self.end_collision = find_entity_by_targetname( "end_position" );
	self.end_cover = find_entity_by_targetname( "end_cover_brush" );
	self.start_cover = find_entity_by_targetname( "start_cover_brush" );
	self.player_avoid_volume = find_first_ent_by_targetname( "player_avoid_volume" );
}

external_actor_activate( script_noteworthy, targetname_1, targetname_2 )
{
	if( IsDefined( targetname_1 ) )
	{
		target_1_triggers = GetEntArray( targetname_1, "targetname" );
		foreach ( trigger in target_1_triggers )
		{
			if( trigger.script_noteworthy == script_noteworthy ) //find the match.
			{
				trigger notify( "actor_activate", self );
				return;
			}
		}
	}

	if( IsDefined( targetname_2 ) )
	{
		//if it wasn't a left, check if its a right.
		target_2_triggers = GetEntArray( targetname_2, "targetname" );
		foreach ( trigger in target_2_triggers )
		{
			if( trigger.script_noteworthy == script_noteworthy ) //find the match.
			{
				trigger notify( "actor_activate", self );
				return;
			}
		}
	}

	assertex( false, "unable to match script_noteworthy" );
}

monitor_trigger_view_direction( endon_condition )
{
	self monitor_trigger_view_direction_internal( endon_condition ) ;
	self MakeUnusable();
} 

MIN_FOV_DOT = 0.90;
monitor_trigger_view_direction_internal( endon_condition )
{
	self endon( endon_condition );
	self endon( "trigger" );
	self endon( "dynamic_cover_player_activate" );
	self endon( "dynamic_cover_ai_activate" );

	if( IsDefined( self.target ) )
	{
		target = GetEnt( self.target, "targetname" );
		vector = target.origin - self.origin;
		while( true )
		{
			if( VectorDot( AnglesToForward( level._player.angles ), vector ) < MIN_FOV_DOT )
			{
				self MakeUnusable();
			}
			else
			{
				self MakeUsable();
			}

			wait 0.05;
		}
	}
}

#using_animtree( "script_model" );
player_animate_dynamic_cover( scene, prop_name )
{
	self notify( "dynamic_cover_player_activate" );

	player_rig = spawn_anim_model( "player_hands" );
	player_rig Hide();
	guys = [ player_rig ];
	
	foreach( model in self.script_models )
	{
		model.animname = prop_name;
		model UseAnimTree( level._scr_animtree[ model.animname ] );
		guys = array_add( guys, model);
	}

	//restrict player actions and disable the weapon.
	level._player DisableWeapons();

	// Check for crouch version. 
	if ( IsDefined( level._scr_player_anim_crouch[ scene ]) && level._scr_player_anim_crouch[ scene ] == true )
	{
		// tagBK<NOTE> Delay crouch transition until blend is started. 
		level._player thread set_dynamic_cover_crouch();
	}
	else 
	{
		level._player SetStance( "stand" );
		level._player AllowCrouch( false );
	}

	level._player AllowProne( false );
	level._player EnableInvulnerability();

	level._player PlayerLinkToBlend( player_rig, "tag_player", 0.2, 0.1, 0.1 );
	player_rig delayCall( 0.2, ::Show );

	self.anim_start anim_single( guys, scene );

	level._player Unlink();

	//get rid of the hands, we're done.
	player_rig delete( );

	//re-enable the weapon so the player can fire, and 
	level._player EnableWeapons();

	level._player AllowStand( true );
	level._player AllowCrouch( true );
	level._player AllowProne( true );
	level._player DisableInvulnerability();
}

set_dynamic_cover_crouch()
{
	wait( 0.1 );
	self SetStance( "crouch" );
	self AllowStand( false );
}

//called on the anim start node.
actor_animate_dynamic_cover( actor, scene, actor_anim, prop_name )
{
	old_animname = actor.animname;
	actor.animname = actor_anim;
	guys = [ actor ];

	foreach( model in self.script_models )
	{
		model.animname = prop_name;
		model UseAnimTree( level._scr_animtree[ model.animname ] );
		guys = array_add( guys, model);
	}

	self thread restore_actor_params( actor, actor get_force_color(), old_animname );

	self.anim_start anim_reach_solo( actor, scene );

	while( true )
	{	
		//don't flip the table if the actor is no longer alive.
		if( !IsAlive( actor ) )
		{
			self notify( "abort" );
			return;
		}

		if( !(IsDefined(self.player_avoid_volume) && level._player IsTouching(self.player_avoid_volume)) )
		{
			break;
		}
		wait 0.05;
	}


	self notify ( "dynamic_cover_ai_activate" );

	actor playsound( "scn_hospital_vending_push" );
	self.anim_start thread anim_single( guys, scene );

	self notify ( "dynamic_cover_ai_activate_anim_finished" );
}

restore_actor_params( actor, force_color, animname )
{
	//either the animation completed, or the whole thing was bailed on, either way restore the color and animname.
	self waittill_any( "dynamic_cover_ai_activate_anim_finished", "dynamic_cover_activate", "dynamic_cover_player_activate", "abort" );

	if( IsDefined( force_color ) )
	{
		actor set_force_color( force_color );
		actor enable_ai_color(); 
	}

	actor.animname = animname;
}

reconnect_paths( blocking_geo )
{
	foreach( block in blocking_geo )
	{
		block ConnectPaths();
	}
}

disconnect_paths( blocking_geo )
{
	foreach( block in blocking_geo )
	{
		block DisconnectPaths();
	}
}

hide_blocking_geo( blocking_geo )
{
	foreach( block in blocking_geo )
	{
		block.orig_origin = block.origin;
		block.origin = (0,0,-100000);
	}
}

unhide_blocking_geo( blocking_geo )
{
	foreach( block in blocking_geo )
	{
		block.origin = block.orig_origin;
	}
}

find_entity_by_targetname( targetname )
{
	ents = [];
	found_ents = GetEntArray( targetname, "targetname");
	foreach( ent in found_ents )
	{
		if( IsDefined( ent.script_noteworthy ) && ent.script_noteworthy == self.script_noteworthy )
		{
			ents = array_add( ents, ent );
		}
	}

	return ents;
}

find_nodes_by_targetname( targetname )
{
	nodes = [];
	found_nodes = GetNodeArray( targetname, "targetname");
	foreach( node in found_nodes )
	{
		if( IsDefined( node.script_noteworthy ) && node.script_noteworthy == self.script_noteworthy )
		{
			nodes = array_add( nodes, node );
		}
	}

	return nodes;
}

find_first_ent_by_targetname( targetname )
{
	found_ents = GetEntArray( targetname, "targetname");
	foreach( ent in found_ents )
	{
		if( IsDefined( ent.script_noteworthy ) && ent.script_noteworthy == self.script_noteworthy )
		{
			return ent;
		}
	}
}

dynamic_cover_activated( script_noteworthy )
{
	cover_parts = GetEntArray( script_noteworthy, "script_noteworthy" );
	foreach ( part in cover_parts )
	{
		if( IsDefined( part.dynamic_cover_root ) && part.dynamic_cover_root == true ) //find the dynamic cover root trigger.
		{
			assert( IsDefined( part.dynamic_cover_activated ) );
			return part.dynamic_cover_activated;
		}
	}
}

//called on actor.
set_closest_node_as_goal( nodes )
{
	Assert( IsDefined( nodes ) && nodes.size > 0 );
	closest_dist = 100000;
	closest_node = undefined;
	foreach ( node in nodes )
	{
		dist = Distance( node.origin, self.origin );
		if ( dist < closest_dist )
		{
			closest_dist = dist;
			closest_node = node;
		}
	}

	if( IsDefined( closest_node ) )
	{
		self SetGoalNode( closest_node );
	}
}

//it would to do a check to verify that each dynamic cover instance has a unique script_noteworthy. 
//this needs to be done so that only the items within this prefab are effected.
//called on this instance's trigger_use.
/#
check_for_duplicated_unique_name()
{
	ents = GetEntArray( self.script_noteworthy, "script_noteworthy" );

	num_use_triggers = 0;
	foreach( ent in ents )
	{
		if( ent.classname == "trigger_use" )
			num_use_triggers++;
	}

	assertEx( num_use_triggers <= 1, "script_noteworthy " + self.script_noteworthy + " used by more than one dynamic_cover prefab" );
}
#/

DynamicCover_rumble_heavy( player_rig )
{
	//iprintln("rumble");
	level._player PlayRumbleOnEntity( "viewmodel_large" );
}

DynamicCover_rumble_medium( player_rig )
{
	level._player PlayRumbleOnEntity( "viewmodel_medium" );
}

DynamicCover_rumble_light( player_rig )
{
	level._player PlayRumbleOnEntity( "viewmodel_small" );
}