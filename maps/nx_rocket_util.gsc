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

// Use more
// AssertEx( IsDefined( object ), "Assert message" );

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pre_turret_event()
{
	smoke_plumes_hide();
	pre_turret_destruction_event();
}

post_turret_event()
{
	smoke_plumes_show();
	post_turret_destruction_event();
}

// Hide all the plumes
smoke_plumes_hide()
{
	smoke_plumes = GetEntArray( "rocket_fuel_smoke", "targetname" );
	foreach( plume in smoke_plumes )
	{
		//iprintln( "hiding plume" );
		plume hide();
	}
}

// Show all the plumes
smoke_plumes_show()
{
	smoke_plumes = GetEntArray( "rocket_fuel_smoke", "targetname" );
	foreach( plume in smoke_plumes )
	{
		//iprintln( "showing plume" );
		plume show();
	}
}

// SHOW/HIDE VARIOUS OBJECTS BEFORE TURRET DESTRUCTION.
pre_turret_destruction_event()
{
	pre_destruction_objects = GetEntArray( "pre_turret_destruction_event", "targetname" );
	foreach( object in pre_destruction_objects )
	{
		object show();
	}

	post_destruction_objects = GetEntArray( "post_turret_destruction_event", "targetname" );
	foreach( object in post_destruction_objects )
	{
		object hide();
	}
}

// SHOW/HIDE VARIOUS OBJECTS AFTER TURRET DESTRUCTION.
post_turret_destruction_event()
{
	pre_destruction_objects = GetEntArray( "pre_turret_destruction_event", "targetname" );
	foreach( object in pre_destruction_objects )
	{
		object hide();
	}

	post_destruction_objects = GetEntArray( "post_turret_destruction_event", "targetname" );
	foreach( object in post_destruction_objects )
	{
		object show();
	}
}

// Causes an APC's turret to fire at target
// JR - Add a distance check
apc_turret_logic( main_target, other_targets  )
{
	self endon( "death" );
	self thread apc_chooses_target( main_target, other_targets );

	for(;;)
	{
		shots = randomintrange( 5, 10 );
		for( i = 0 ; i < shots ; i++ )
		{
			self fireWeapon();
			wait 0.1;
		}
		wait randomfloatrange( 1.0, 3.0 );
	}
}

apc_chooses_target( main_target, other_targets )
{
	self endon( "death" );
	main_target endon( "death" );

	self.dummy_target = spawn( "script_origin", self.origin + ( 0, 0, 70 ) );
	self thread delete_on_death( self.dummy_target );
	self SetTurretTargetEnt( self.dummy_target );
	self.accuracy = 0.1; // Default

	if ( !isDefined( self.kill_player_max_dist_sqr ) )
	{
		self.kill_player_max_dist_sqr = 3500 * 3500;
	}

	if ( !isDefined( self.kill_player_time ) )
	{
		self.kill_player_time = 2.0;
	}

	if ( !isDefined( self.kill_player_fov_cos ) )
	{
		self.kill_player_fov_cos = 0.3;
	}

	time_in_kill_player_range = 0.0;
	killing_player = false;

	while ( 1 )
	{
		dist_sqr_to_main = DistanceSquared( main_target.origin, self.origin );
		//println( "APC dist to player: " + Distance( main_target.origin, self.origin ) );
		if ( dist_sqr_to_main < self.kill_player_max_dist_sqr )
		{
			player_copter_right = AnglesToRight( main_target.angles );
			player_to_apc = VectorNormalize( self.origin - main_target.origin );
			dot = VectorDot( player_copter_right, player_to_apc );
			//println( "APC dot: " + dot );
			if ( dot > self.kill_player_fov_cos )
			{
				tag_flash = self GetTagOrigin( "tag_flash" );
				bullet_trace = BulletTracePassed( tag_flash, level._player GetEye(), false, self );
				if ( bullet_trace )
				{
					// Player should see APC, start counting time_in_kill_player_range
					time_in_kill_player_range += 0.5;
					//Println( "APC KILL COUNTDOWN: " + time_in_kill_player_range );
				}
				else
				{
					//println( "Bullet Trace FAILED" );
				}
			}
			else
			{
				time_in_kill_player_range = 0.0;
			}
		}
		else
		{
			time_in_kill_player_range = 0.0;
			if ( killing_player )
			{
				killing_player = false;
				self SetVehWeapon( "nx_btr80_rocket_turret" );
				//iPrintLn( "APC Killing player CLEARED" );
			}
		}

		if ( time_in_kill_player_range >= self.kill_player_time )
		{
			// Kill the player
			//iPrintLn( "APC Killing player SET" );
			//self SetVehWeapon( "btr80_turret" );
			self SetTurretTargetEnt( level._player );
			killing_player = true;
			self.accuracy = self.accuracy + 0.2;
			if ( isdefined ( self.mgturret [ 0 ] ))
			{
				self.mgturret [ 0 ] SetAISpread ( 0.1 );
			}
		}
		else
		{
			// Don't kill the player
			dist_sqr_to_best_other = dist_sqr_to_main;
			
			best_other = undefined;
			foreach( other_target in other_targets )
			{
				if ( !isAlive( other_target ) )
				{
					continue;
				}
	
				dist_sqr_to_other = DistanceSquared( other_target.origin, self.origin );
				if ( dist_sqr_to_other < dist_sqr_to_best_other )
				{
					best_other = other_target;
					dist_sqr_to_best_other = dist_sqr_to_other;
				}
			}
	
			// Fire at the other target if it is closer than the player and in front of the player
			target = level._player;
			if ( isDefined( best_other ) && dist_sqr_to_best_other < dist_sqr_to_main && within_fov( level._player GetEye(), level._player.angles, best_other.origin, 90 ) )
			{
				target = best_other;
			}
	
			self SetTurretTargetEnt( target );
	
			// Show target debug
			//line( self.origin, target.origin, (1,0,0) );
		}

		wait 0.5;
	}
}

update_fake_spread( target )
{
	self endon( "death" );
	target endon( "death" );

	self notify( "stop_update_fake_spread" );
	self endon( "stop_update_fake_spread" );

	dummy_target = self.dummy_target;
	dummy_target Unlink();
	min_miss_dist_sqr = 512 * 512;
	
	while ( 1 )
	{
		accuracy_test = RandomFloat( 1.0 );
		dist_sqr = DistanceSquared( target.origin, self.origin );

		// This looks bad at short distances, so never miss if we're close.
		if ( dist_sqr < min_miss_dist_sqr || accuracy_test < self.accuracy )
		{
			// Hit
			self SetTurretTargetEnt( target );
		}
		else
		{
			// Miss!
			offset = ( RandomFloatRange( 100, 200 ), RandomFloatRange( 100, 200 ), RandomFloatRange( 100, 200 ) );
			dummy_target LinkTo( target, undefined, offset, target.angles );
			//box( target.origin + offset, 16, target.angles[1], (1,0,0), 1, 1, 5 );
			self SetTurretTargetEnt( dummy_target );
		}
		wait .3;
	}
}

// Blockout spawning script for groups of enemies
spawn_guys_from_targetname( targetname )
{
	new_guys = [];
	guys = getentarray( targetname, "targetname" );
	foreach ( guy in guys )
	{
		if( IsDefined( guy.script_drone ) && guy.script_drone == 1 )
		{
			new_guy = dronespawn( guy );
			new_guys[ new_guys.size ] = new_guy;
		}
		else
		{
			new_guy = guy stalingradSpawn();
			if ( spawn_failed( new_guy ) )
			{
				//iprintlnbold( "force_spawn_guys failed" );
				continue;
			}
			new_guys[ new_guys.size ] = new_guy;
		}
	}
	return new_guys;
}


// Safely delete an object
safe_delete( object )
{
	if( isDefined( object ))
	{
		object delete();
	}	
}

// Safely deletes a bunch of objects
safe_delete_array( array )
{
	foreach( object in array )
	{
		safe_delete( object );
	}
}

spawn_ai_group( spawner_value, spawner_key )
{
	ai_array = [];
	foreach( spawner in GetEntArray( spawner_value, spawner_key ) )
	{
		ai = spawner spawn_ai();
		ai_array[ ai_array.size ] = ai;
		wait 0.25;
	}

	return ai_array;
}


// Copied from dcburning.gsc
// Spawns and endless stream of drones a random interval apart
// Be sure to set "script_noteworthy = delete_on_goal" on the spawners
drone_flood_start( aSpawners, groupName, r1, r2, immediate )
{
	level endon( "stop_drone_flood" + groupName );

	if( isDefined( immediate ))
	{
		foreach( spawner in aSpawners )
		{
			dronespawn( spawner );
		}
	}

	while( true )
	{
		foreach( spawner in aSpawners )
		{
			delaythread( randomfloatrange( r1, r2 ), ::dronespawn, spawner );
		}
		wait( randomfloatrange( r1, r2 ) );
	}
}

drone_flood_stop( groupName )
{
	level notify( "stop_drone_flood" + groupName );
}

// Delays a thread untill a specific notify occurs
delayThreadNotify( event, func, param1, param2, param3 )
{
	self waittill( event );
	if ( !IsDefined( param1 ) )
	{
		assertex( !isdefined( param2 ), "delayThreadNotify does not support vars after undefined." );
		assertex( !isdefined( param3 ), "delayThreadNotify does not support vars after undefined." );
		thread [[ func ]]();
	}
	else
	if ( !IsDefined( param2 ) )
	{
		assertex( !isdefined( param3 ), "delayThreadNotify does not support vars after undefined." );
		thread [[ func ]]( param1 );
	}
	else
	if ( !IsDefined( param3 ) )	
	{
		thread [[ func ]]( param1, param2 );
	}
	else
	{
		thread [[ func ]]( param1, param2, param3 );
	}
}


delete_objects_on_notify( event, objects )
{
	//iprintln( "waiting" );
	self waittill( event );
	//iprintln( "delete objects on notify" );
	safe_delete_array( objects );
}

set_goal_volume_array( actors, volume_targetname )
{
	foreach( actor in actors )
	{
		actor thread set_goal_volume( volume_targetname );
	}
}

set_goal_volume( volume_targetname )
{
	goal_volume = GetEnt( volume_targetname, "targetname" );

	self.goalheight = 80;
	self.fixednode = false;

	self ClearGoalVolume();
	self SetGoalPos( goal_volume.origin );
	self waittill( "goal" );
	self SetGoalVolume( goal_volume );
	self.goalradius = 2000;
}


// Helper script for timing dialogue
wait_play_dialogue_wait( wait_in, dialogue1, wait_out, flag )
{
	wait( wait_in );

	radio_dialogue( dialogue1 );

	if( isDefined( flag ))
	{
		flag_set( flag );
	}

	if( isDefined( wait_out ))
	{
		wait( wait_out );
	}
}


// Nags the player to fire the railgun
nag_for_fire_railgun( event )
{
	level endon( event );
	while( 1 )
	{
		wait RandomIntRange( 8, 12  );

		if( cointoss() )
		{
			maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_bak_alpha_paintrocket" );
		}
		else
		{
			maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_bak_alpha_painttargetnow" );
		}
	}
}





//*******************************************************************
//      OBJECTIVES		                                            *
//                                                                  *
//*******************************************************************
add_objective( objective_name )
{
	if( !IsDefined( level._mission_objective ) )
		level._mission_objective = [];

	level._mission_objective[ objective_name ] = level._mission_objective.size;
}

get_objective( objective_name )
{
	return level._mission_objective[ objective_name ];
}

//*******************************************************************
//      SQUAD			                                            *
//                                                                  *
//*******************************************************************
squad_teleport( teleport_info )
{
	// teleport_info should be an array with entries that follow the form:
	// teleport_info[ "ALLY_NAME" ] = "SCRIPT_ORIGIN_NOTEWORTHY";
	// ALLY_NAME should match one of the keys in level.squad (see nx_rocket.gsc)

	foreach( ally_name, origin_noteworthy in teleport_info )
	{
		ally = level.squad[ ally_name ];

		origin = GetEnt( origin_noteworthy, "script_noteworthy" );

		ally ForceTeleport( origin.origin, origin.angles );
	}
}

squad_ally( spawner_script_noteworthy, animname, color )
{
	spawner = GetEnt( spawner_script_noteworthy, "script_noteworthy" );
	ai = spawner spawn_ai( true );

	ai thread magic_bullet_shield();
	ai.animname = animname;
	ai.ai_color = color;
	ai ai_color_reset();

	return ai;
}

squad_color_reset()
{
	ai_array_color_reset( level.squad );
}

//*******************************************************************
//      AI				                                            *
//                                                                  *
//*******************************************************************
ai_color_reset( color )
{
	if( !IsDefined( color ) )
	{
		if( IsDefined( self.ai_color ) )
			color = self.ai_color;
	}

	if( IsDefined( color ) )
		self set_force_color( color );
}

ai_array_color_reset( ai_array, color )
{
	foreach( ai in ai_array )
	{
		ai ai_color_reset( color );
	}
}

// The AI will run to their goal node, then become aggresive
// Do this:
// array_spawn_function_targetname( "base_alpha_roof_runners_1", ::run_to_goal_then_aggro );
run_to_goal_then_aggro()
{
	//self.script_forcegoal = true;
	//self.ignoreall = true;

	self waittill( "goal" );
	self.ignoreall = false;
}


//*******************************************************************
//      HELICOPTER		                                            *
//                                                                  *
//*******************************************************************
heli_shoots_rockets_at_ent( target )
{
    attractor = missile_createAttractorEnt( target, 100000, 60000 );
    self maps\_helicopter_globals::fire_missile( "mi28_seeker", 3, target, .75 );
    wait( 5 );
    missile_deleteAttractor( attractor );
}

// Changes the spread on allied choppers turrets
// This effects their accuracy
// Default 2
set_ally_chopper_spread( spread )
{
	foreach ( turret in self.mgturret )
    {
        turret SetAISpread( spread ); // Default is 2
    }
}

heli_start_path( path_value, path_key )
{
	// Get rid of old path
	self thread vehicle_detachfrompath();

	// Get the new path
	transition_node = getstruct( path_value, path_key );

	// Use new patch
	self.currentnode = transition_node;

	//iprintln( "new path go" );

	// Continue on new path
	self thread vehicle_resumepath();
	self GoPath();
}

// Moves a chopper from one path to another
transition_chopper_to_new_path( new_path_start )
{
	AssertEx( maps\_vehicle::ishelicopter(), "Called transition_chopper_to_new_path, but self isnt a chopper" );

	self thread vehicle_detachfrompath();
	self notify( "newpath" );
	transition_node = getstruct( new_path_start, "targetname" );

	self.currentnode = transition_node;
	self thread vehicle_resumepath();
	self thread GoPath();
}

// Moves a chopper from one path to another
transition_chopper_to_new_path_noteworthy( new_path_start )
{
	AssertEx( maps\_vehicle::ishelicopter(), "Called transition_chopper_to_new_path, but self isnt a chopper" );

	self thread vehicle_detachfrompath();
	self notify( "newpath" );
	transition_node = getstruct( new_path_start, "script_noteworthy" );

	self.currentnode = transition_node;
	self thread vehicle_resumepath();
	self thread GoPath();
}


// Low powered earthquake used to simulate chopper rumble
slightly_vibrate_camera()
{
	level endon( "end_camera_vibrate" );
	for( ;; )
	{
		Earthquake( 0.05, 60, level._player.origin, 0 );
		wait 5;
	}
}


slightly_vibrate_camera_end()
{
       level notify( "end_camera_vibrate" );

       // HACK!
       // In order to clear out the long duration earthquakes in slightly_vibrate_camera(),
       // use four short duration earthquakes that are slightly stronger.
       // This works because the game only remembers the four largest earthquakes (MAX_CAMERA_SHAKE == 4).
       Earthquake( 0.06, 0.05, level._player.origin, 0 );
       Earthquake( 0.06, 0.05, level._player.origin, 0 );
       Earthquake( 0.06, 0.05, level._player.origin, 0 );
       Earthquake( 0.06, 0.05, level._player.origin, 0 );
}

/#
// Debug helper
draw_chopper_name( text )
{
	self endon( "death" );
	while ( true )
	{
		Print3D( self.origin, text );
		//println( self GetEntNum() );
		wait 0.05;
	}
}
#/

// Displays a 3d hint text untill the specified notify is hit
display_hint_until_notify( text, location, event )
{
	level endon( event );

	for( ;; )
	{
		Print3d( location.origin, text, (1,1,1), 1, 1, 1 );
		wait(0.05);
	}
}

dialogue_nag_temp( actor, line, display_time, wait_min, wait_max, end_on )
{
	level endon( end_on );

	while( 1 )
	{
		if( flag(end_on) )
			return;

		level thread add_dialogue_line( actor, line, undefined, display_time );
		wait display_time;
		wait RandomFloatRange( wait_min, wait_max );
	}
}

dialogue_nag( line, wait_min, wait_max, end_on )
{
	level endon( end_on );

	while( 1 )
	{
		if( flag(end_on) )
			return;

		wait_play_dialogue_wait(0, line );
		wait RandomFloatRange( wait_min, wait_max );
	}
}

aa_turret_fire( target, hit_offset )
{
	if( !IsDefined( hit_offset ) )
		hit_offset = (0, 0, 0);

	MagicBullet( "nx_rocket_aa_turret", self.origin, target.origin + hit_offset );

	angles_to_target = VectorToAngles( target.origin - self.origin );

	fx_forward = AnglesToForward( angles_to_target );
	fx_up = AnglesToUp( angles_to_target );
	fx_org = self.origin;
	playfx( level._effect[ "nx_rocket_aa_flash_view" ], fx_org, fx_forward, fx_up );
	self stopsounds();
}

track_anim_speed()
{
	self endon( "death" );
	self endon( "end_track_anim_velocity" );
	
	speed = 0;
	while ( true )
	{
		prev_origin = self.origin;
		wait 0.05;
		self.anim_speed = speed; // track previous frame's speed, as all anims seem to have one frame of reduced velocity at their end
		speed = Length( ( self.origin - prev_origin ) / 0.05 );
	}
}

rescue_chopper_setup( chopper_value, chopper_key )
{
	chopper = vehicle_spawn( GetEnt( chopper_value, chopper_key ) );

	chopper rescue_chopper_player_setup();
	chopper rescue_chopper_allies_setup();

	chopper thread godon();
	chopper SetMaxPitchRoll( 10, 10 );

	chopper GoPath();

	return chopper;
}

rescue_chopper_allies_setup()
{
	level.squad[ "ALLY_WILLIAMS" ].script_startingposition = 7;
	level.squad[ "ALLY_JENKINS" ].script_startingposition = 2;
	level.squad[ "ALLY_BAKER" ].script_startingposition = 3;

	foreach( guy in level.squad )
	{
		self guy_enter_vehicle( guy );
	}
}

rescue_chopper_player_setup()
{
	player_tag = spawn_tag_origin();
	tag_name = "tag_guy2";
	player_tag.angles = self GetTagAngles( tag_name );
	player_tag_forward = AnglesToForward( player_tag.angles );
	player_tag_offset = player_tag_forward * 30 + (0, 0, -25);
	player_tag.origin = self GetTagOrigin( tag_name ) + player_tag_offset;

	level thread draw_line_for_time( player_tag.origin, player_tag.origin + player_tag_offset, 1, 1, 1, 10 );

	level._player SetOrigin( player_tag.origin );
	level._player SetPlayerAngles( player_tag.angles );
	level._player PlayerLinkToDelta( player_tag, "tag_origin", 1, 90, 90, 35, 100, true );

	player_tag LinkTo( self, tag_name );
}

player_prevent_damage_from_behind_until_flag( flag_name )
{
	// Dan: While close to working, this script does not work
	// because previous_normal_health does not know about
	// any regeneration which may have occured since the last
	// damage event.  Disabling for now.  Justin has said it is
	// OK for this to be changed so that actors which are out of
	// view have very low accuracy.
	//
	// Also, Justin has said that he would like this to not be
	// based directly on the player's view, but rather the
	// general facing of the helicopter.  (So the player can not
	// look away from enemies to get them to miss.)
	

	/*
	self endon( "death" );
	self endon( flag_name );

	while ( 1 )
	{
		previous_normal_health = level._player GetNormalHealth();
		self waittill( "damage", damage, attacker, direction_vec );
		
		playerangles = level._player GetPlayerAngles();
		player_forward = AnglesToForward( playerangles );
		anglesFromPlayer = VectorToAngles( direction_vec );
		forward_to_self = AnglesToForward( anglesFromPlayer );
	
		dot = vectordot( player_forward, forward_to_self );
		//iPrintln( "Direction_vec: " + direction_vec + " dot: " + dot );

		// Heal health from behind
		if ( dot > 0.2 )
		{
			level._player SetNormalHealth( previous_normal_health );
		}
	}
	*/
}

// Let the player take damage but not die
heli_god_mode( end_notify )
{
	self endon( end_notify );

	while( true )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, damageType, modelName, tagName );

		//iprintln( "Dmg: " + damage + " from " + attacker.className );

		normal_health = level._player GetNormalHealth();
		if ( normal_health < 0.02 )
		{
			level._player SetNormalHealth( 0.02 );
		}

		// Dan: Note that this wait opens a window in which the player can die.
		//wait 0.05;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
CINEMATIC_LINK_VIEW_FRACTION = 0.9;
GAMEPLAY_LINK_VIEW_FRACTION = 0.1;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
set_link_view_fraction_cinematic( lerp_duration )
{
	if ( !IsDefined( lerp_duration ) )
	{
		lerp_duration = 0;
	}
	level._player LerpLinkViewFraction( CINEMATIC_LINK_VIEW_FRACTION, lerp_duration );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
set_link_view_fraction_gameplay( lerp_duration )
{
	if ( !IsDefined( lerp_duration ) )
	{
		lerp_duration = 0;
	}
	level._player LerpLinkViewFraction( GAMEPLAY_LINK_VIEW_FRACTION, lerp_duration );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
lerp_link_view_fraction_cinematic_trigger()
{
	lerp_link_view_fraction_trigger( CINEMATIC_LINK_VIEW_FRACTION );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
lerp_link_view_fraction_gameplay_trigger()
{
	lerp_link_view_fraction_trigger( GAMEPLAY_LINK_VIEW_FRACTION );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
lerp_link_view_fraction_trigger( view_fraction )
{
	self waittill( "trigger", ent );
	assert( IsPlayer( ent ) );

	level._player LerpLinkViewFraction( view_fraction, 3 );
	//IPrintLnBold( "level._player LerpLinkViewFraction( " + view_fraction + ", 3 );");

	// exit; trigger only works once
	
	count = 3 / 0.05;
	for ( i = 0; i < count; i++ )
	{
		//IPrintLn( "lerping to " + view_fraction );
		wait 0.05;
	}
	//IPrintLnBold( "Done!");
}

player_ledge_walk( trigger )
{
	self endon( "end_ledge" );

	curr_node = undefined;
	dest_node = undefined;

	if( IsDefined( trigger.target ) )
	{
		curr_node = GetEnt( trigger.target, "targetname" );
	}

	move_speed = 20.0; // units per second
	interval = 0.05;

	mover = spawn_tag_origin();
//  mover.origin = curr_node.origin;
//  mover.angles = curr_node.angles;

	while( 1 )
	{
		flag_wait( trigger.script_flag );
		self SetMoveSpeedScale( 0.3 );
		self HideViewModel();
		self DisableWeapons();

		mover.origin = self.origin;
		mover.angles = self.angles;
		self PlayerLinkToDelta( mover, "tag_origin", 1.0, 45, 45, 15, 60, true );

		mover RotateTo( curr_node.angles, 0.65 );
		mover waittill( "rotatedone" );

		while( flag( trigger.script_flag ) )
		{
			if( DistanceSquared( mover.origin, curr_node.origin ) <= curr_node.radius * curr_node.radius )
			{
				if( IsDefined( curr_node.target ) )
					curr_node = GetEnt( curr_node.target, "targetname" );
				else
					break;
			}

			dest_org = curr_node.origin - mover.origin;
			dest_angles = curr_node.angles - mover.angles;
	
			movement_scale = self GetNormalizedMovement();

			dir = VectorNormalize( dest_org);

			velocity = dir * movement_scale[ 1 ] * move_speed;
	
			mover.origin += velocity * interval;
//  		mover.angles += dest_angles * interval * movement_scale[ 1 ];

			wait interval;
		}
	
		self SetMoveSpeedScale( 1.0 );
		self ShowViewModel();
		self Enableweapons();
		self Unlink();

		wait 0.05;
	}
}

trigger_waittill_use( hint_text )
{
	self trigger_on();
	self SetHintString( hint_text );
	self waittill( "trigger" );
	self trigger_off();
}

ignore_until_damage()
{
	self endon( "death" );

	self.ignoreAll = true;
	self.ignoreMe = true;

	self waittill( "damage" );

	self.ignoreAll = false;
	self.ignoreMe = false;
}

ignore_until_damage_group( team )
{
	self.ignoreAll = true;
	self.ignoreMe = true;

	self waittill( "damage" );

	guys = array_removedead( team );

	foreach( guy in guys )
	{
		guy.ignoreAll = false;
		guy.ignoreMe = false;
	}
}

ignore_until_flag( flag_name )
{
	self endon( "death" );

	self.ignoreAll = true;
	self.ignoreMe = true;

	flag_wait( flag_name );

	self.ignoreAll = false;
	self.ignoreMe = false;
}

vehicle_enable_fire( enable )
{
	foreach( turret in self.mgturret )
	{
		if( enable )
			turret TurretFireEnable();
		else
			turret TurretFireDisable();
	}
}

vehicle_search_ents( ents, end_on )
{
	if( IsDefined( end_on ) )
	{
		self endon( end_on );
		level endon( end_on );
	}

	self endon( "death" );

	while( 1 )
	{
		self SetTurretTargetEnt( random( ents ) );
		wait  RandomFloatRange( 1.0, 3.0 );
	}
}

vehicle_firing( fire_min, fire_max, hold_min, hold_max, end_on )
{
	if( IsDefined( end_on ) )
	{
		self endon( end_on );
		level endon( end_on );
	}

	self endon( "death" );

	enable = false;

	while( 1 )
	{
		enable = !enable;
		self maps\nx_rocket_util::vehicle_enable_fire( enable );
		if(enable)
			wait RandomFloatRange( fire_min, fire_max );
		else
			wait RandomFloatRange( hold_min, hold_max );
	}
}

VIEW_DOT = 0.25; //Goes from 0-1, smaller numbers mean larger fov.
//called on an actor.
protect_player_helicopter_rear()
{
	self endon( "death" );

	self.oldbaseaccuracy = self.baseAccuracy;

	while( true )
	{
		if( !IsDefined( level.playerHeli ) )
		{
			return;
		}

		//The player is in the right bay door, so we use Angles to Right. Then see if the actor's position puts them too
		//far behind. If it does, then set the accuracy low.
		if( vectordot(self.origin - level.playerHeli.origin, AnglesToRight( level.playerHeli.angles )) > VIEW_DOT ) //actor "in view".
		{
			self.baseAccuracy = self.oldbaseaccuracy;
			///#debug_draw_origin( self.origin, true);#/
		}
		else
		{
			self.baseAccuracy = 0;
			///#debug_draw_origin( self.origin, false);#/
		}
		wait 0.05;
	}
}

//called on a vehicle.
protect_player_helicopter_rear_from_vehicle()
{
	self endon( "death" );

	//bail if the vehicle doesn't have a turret so we can call this on vehicles blindly. 
	if( !IsDefined( self.mgturret ) || self.mgturret.size < 1 )
	{
		return;
	}

	old_accuracy = [];

	//some have multiple turrets, so grab each one.
	for ( i = 0; i < self.mgturret.size; i++ )
	{
		old_accuracy[i] = self.mgturret[i].accuracy;
	}

	while( true )
	{
		if( !IsDefined( level.playerHeli ) )
		{
			return;
		}

		//The player is in the right bay door, so we use Angles to Right. Then see if the actor's position puts them too
		//far behind. If it does, then set the accuracy low.
		if( vectordot(self.origin - level.playerHeli.origin, AnglesToRight( level.playerHeli.angles )) > VIEW_DOT ) //actor "in view".
		{
			for ( i = 0; i < self.mgturret.size; i++ )
			{	
				self.mgturret[ i ].accuracy = old_accuracy[i];
			}
			///#debug_draw_origin( self.origin, true);#/
		}
		else
		{
			for ( i = 0; i < self.mgturret.size; i++ )
			{	
				self.mgturret[ i ].accuracy = 0;
			}
			///#debug_draw_origin( self.origin, false);#/
		}
		wait 0.05;
	}
}

protect_player_helicopter_rear_from_each_vehicle( vehicles )
{
	//to make this as unlikely to fail as possible, check for the case where what's returned is a single item and not an array.
	if( IsArray( vehicles ) )
	{
		foreach ( vehicle in vehicles )
		{
			vehicle thread protect_player_helicopter_rear_from_vehicle();
		}
	}
	else
	{
		vehicles thread protect_player_helicopter_rear_from_vehicle();
	}
}

/#
debug_draw_origin( origin, on )
{
	draw_color = ( 1, 0, 0 );
	if( on ) 
	{	
		draw_color = ( 0, 1, 0 );
	}

	Line( origin + ( 16, 0, 0 ), origin + ( -16, 0, 0 ), draw_color, 1, 0, 1 );
	Line( origin + ( 0, 16, 0 ), origin + ( 0, -16, 0 ), draw_color, 1, 0, 1 );
	Line( origin + ( 0, 0, 16 ), origin + ( 0, 0, -16 ), draw_color, 1, 0, 1 );
}
#/

// FLASHLIGHT ON GUN
attach_flashlight_gun( state )
{
	effect_id = level._effect[ "flashlight" ];
	effect_tag = "tag_flash";

	if( state )
	{
		PlayFXOnTag( effect_id, self, "tag_flash" );
		self thread detach_flashlight_gun_on_death();
	}
	else
	{
		StopFXOnTag( effect_id, self, "tag_flash" );
	}

	self.have_flashlight = state;
}

detach_flashlight_gun()
{
	self attach_flashlight_gun( false );
}

detach_flashlight_gun_on_death()
{
	self waittill( "death" );
	self detach_flashlight_gun();
}

// FLASHLIGHT IN HAND
attach_flashlight( state )
{
	self attach( "com_flashlight_on", "tag_inhand", true );
	self.have_flashlight = true;
	self flashlight_light( state );
	self thread detach_flashlight_on_death();
}

detach_flashlight_on_death()
{
	self waittill( "death" );
	if ( isdefined( self ) )
		self detach_flashlight();
}

detach_flashlight()
{
	if ( !isdefined( self.have_flashlight ) )
		return;
	self detach( "com_flashlight_on", "tag_inhand" );
	self flashlight_light( false );
	self.have_flashlight = undefined;
}

flashlight_light( state )
{
	flash_light_tag = "tag_light";

	if ( state )
	{
		flashlight_fx_ent = spawn( "script_model", ( 0, 0, 0 ) );
		flashlight_fx_ent setmodel( "tag_origin" );
		flashlight_fx_ent hide();
		flashlight_fx_ent linkto( self, flash_light_tag, ( 0, 0, 0 ), ( 0, 0, 0 ) );

		self thread flashlight_light_death( flashlight_fx_ent );
		playfxontag( level._effect[ "flashlight" ], flashlight_fx_ent, "tag_origin" );
	}
	else if ( isdefined( self.have_flashlight ) )
		self notify( "flashlight_off" );
}

flashlight_light_death( flashlight_fx_ent )
{
	self waittill_either( "death", "flashlight_off" );

	flashlight_fx_ent delete();
	self.have_flashlight = undefined;

}

caravan_setup( caravan_targetname, end_flag )
{
	caravan = [];
	for ( i = 1 ;; i++)
	{
		targetname_concatenated = caravan_targetname + i;
		vehicle_spawner = GetEnt( targetname_concatenated , "targetname");
		if ( !isdefined( vehicle_spawner ) )
			break;
		vehicle = spawn_vehicle_from_targetname_and_drive ( targetname_concatenated );
		caravan [caravan.size] = vehicle;
		// lag mitigator, so they don't all spawn on the same frame
		wait .1;
	}
	protect_player_helicopter_rear_from_each_vehicle( caravan );
	level thread handle_caravan_stopping_2( caravan, end_flag );
	return caravan;
}

get_my_index( caravan )
{
	foreach ( index, vehicle in caravan )
	{
		if ( vehicle == self )
			break;
	}
	return index;
}

handle_caravan_stopping_2( caravan, end_flag )
{
	level endon( end_flag );

	while ( 1 )
	{
		foreach( vehicle in caravan )
		{
			healthbuffer = 0;
			if ( isDefined( vehicle.healthbuffer ) )
			{
				healthbuffer = vehicle.healthbuffer;
			}

			if ( !isAlive( vehicle ) || vehicle.health - healthbuffer <= 1 )
			{
				
				if ( isdefined (vehicle) )
				{
					dead_index = vehicle get_my_index ( caravan );
					foreach ( remaining_vehicle in caravan )
					{
						living_index = remaining_vehicle get_my_index ( caravan );
						if ( living_index > dead_index )
						{
							remaining_vehicle thread stop_caravan_vehicle ( );
						}
					}
					if( vehicle Vehicle_IsPhysVeh())
					{
						vehicle VehPhys_Crash ();
					}
				}
				return;
			}
		}
		wait 0.05;
	}
}

handle_caravan_stopping( vehicles, end_flag )
{
	level endon( end_flag );
	while ( 1 )
	{
		foreach( vehicle in vehicles )
		{
			healthbuffer = 0;
			if ( isDefined( vehicle.healthbuffer ) )
			{
				healthbuffer = vehicle.healthbuffer;
			}

			if ( !isAlive( vehicle ) || vehicle.health - healthbuffer <= 1 )
			{
				
				if ( isdefined (vehicle) && vehicle Vehicle_IsPhysVeh() )
				{
					// speed = vehicle Vehicle_GetSpeed (  );
					// vehicle VehPhys_Launch( (0,4,4), 0.7 );
					vehicle VehPhys_Crash ();
				}
				
				// Stop caravan
				stop_caravan( vehicles );
				return;
			}
		}
		wait 0.05;
	}
}

stop_caravan( vehicles )
{
	foreach ( vehicle in vehicles )
	{
		if ( isAlive( vehicle ) )
		{
			vehicle delayThread( RandomFloatRange( 0.0, 0.2 ), ::stop_caravan_vehicle );
		}
	}
}

stop_caravan_vehicle()
{	
	self endon( "death" );
	self Vehicle_SetSpeed( 0.0, RandomFloatRange( 55.0, 75.0 ) );
	wait .3;
	self vehicle_unload();

}

vehicle_follow( target, dist, min_speed, max_speed, look_at )
{
	self endon( "death" );
	self endon( "reached_dynamic_path_end" );
	self endon( "reached_end_node" );
	self endon( "end_follow" );


	if( self isHelicopter() && IsDefined( look_at ) )
	{
		self SetLookAtEnt( look_at );
	}

	interval = 0.05;

	while( 1 )
	{
//  	if( DistanceSquared( target.origin, self.origin ) >= ( dist * dist ) )
		if( !within_fov( target.origin, target.angles, self.origin, cos( 90 ) ) )
		{
			if( self Vehicle_GetSpeed() <= max_speed )
				self Vehicle_SetSpeed( self Vehicle_GetSpeed() + 1.0, 15 );
		}
		else if( self Vehicle_GetSpeed() > min_speed )
			self Vehicle_SetSpeed( self Vehicle_GetSpeed() - 1.0, 10 );
	
		wait interval;
	}
}

ShootEnemyWrapper_blanks()
{
	// Shoot blanks if we're using a rifle like weapon
	if ( !animscripts\utility::usingRifleLikeWeapon() )
	{
		animscripts\utility::shootEnemyWrapper_shootNotify();
		return;
	}

	self.a.lastShootTime = gettime();

	// set accuracy at time of shoot rather than in a separate thread that is vulnerable to timing issues
	maps\_gameskill::set_accuracy_based_on_situation();

	self notify( "shooting" );
	self ShootBlank();
}

// DIALOGUE 
actor_dialogue_queue( dialogue_line, delay )
{
	if( IsDefined( delay ) )
		wait delay;

	self dialogue_queue( dialogue_line );
}

// ALLY CHOPPER
intro_chopper_allies_setup()
{
	level.squad[ "ALLY_WILLIAMS" ].script_startingposition = 4;
	level.squad[ "ALLY_JENKINS" ].script_startingposition = 3;
	level.squad[ "ALLY_BAKER" ].script_startingposition = 2;

	foreach( guy in level.squad )
	{
		guy notify( "newanim" );
		self guy_enter_vehicle( guy );
	}	
}

chopper_allies_remove()
{
	foreach( guy in level.squad )
	{
		guy notify( "newanim" );
		self guy_exit_vehicle( guy );
//  	guy notify( "animontagdone", "end" );
		self StopAnimScripted();
		self Unlink();
	}
}


// Sends a notify when a rocket is 10s from launching
launch_coutdown_logic( timer, id, cancel_flag )
{
	level endon( cancel_flag );
	AssertEx( timer > 10 , "launch_coutdown_logic only works with a LAUNCH_DELAY > 10" );
	wait (timer-10);

	// Safety check to make sure the rocket wasnt destroyed during this window
	if( flag( cancel_flag ))
	{
		return;
	}

	level notify( "rocket_" + id + "_10s_warning" );
}


chopper_debug_speed()
{
	while( isDefined( self ))
	{
		speed = self vehicle_getSpeed();
		iprintln( speed );
		wait 0.25;
	}
}
