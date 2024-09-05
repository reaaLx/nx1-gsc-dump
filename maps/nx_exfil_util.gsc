//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Skyscraper Exfil Utils										**
//                                                                          **
//    Created: 11/10/2011 - John Webb										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_nx_utility;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

exfil_setup_allies( start_name )
{
	level.baker = setup_ally( start_name, "ally1" );
	//setup_ally( start_name, "ally2" );
	level.baker.countryID = "us";
	level.baker set_battlechatter_id( "bar" );
}

setup_ally( start_name, ally_name )
{
	ally_start = getStruct( start_name + "_" + ally_name, "targetname" );
	assert( isDefined( ally_start ) );

	ally_spawner = GetEnt( ally_name, "targetname" );
	ally_spawner add_spawn_function( ::ally_common );
	level.allies[ ally_name ] = ally_spawner spawn_ai();
	assert( isDefined( level.allies[ ally_name ] ) );


	level.allies[ ally_name ] ForceTeleport( ally_start.origin, ally_start.angles );
	if ( isDefined( ally_start.target ) )
	{
		node = GetNode( ally_start.target, "targetname" );
		assert( isDefined( node ) );
		level.allies[ ally_name ] follow_path( node );
	}
	return level.allies[ ally_name ];
}

ally_common()
{
	self thread magic_bullet_shield();
	self.threatbias = 200;
}

player_start( player_start_origin_name )
{
	// Move player to start
	player_start_origin = GetEnt( player_start_origin_name, "targetname" );
	level._player setOrigin( player_start_origin.origin );
	level._player setPlayerAngles( player_start_origin.angles );
}

ignore_everything()
{
	self.ignoreall = true;
	self.grenadeawareness = 0;
	self.ignoreexplosionevents = true;
	self.ignorerandombulletdamage = true;
	self.ignoresuppression = true;
	self.disableBulletWhizbyReaction = true;
	self disable_pain();
	
	self.og_newEnemyReactionDistSq = self.newEnemyReactionDistSq;
	self.newEnemyReactionDistSq = 0;
}

clear_ignore_everything()
{
	self.ignoreall = false;
	self.grenadeawareness = 1;
	self.ignoreexplosionevents = false;
	self.ignorerandombulletdamage = false;
	self.ignoresuppression = false;
	self.disableBulletWhizbyReaction = false;
	self enable_pain();
	
	if( IsDefined( self.og_newEnemyReactionDistSq ) )
	{
		self.newEnemyReactionDistSq = self.og_newEnemyReactionDistSq;
	}
}

stumble_walk( move_speed, decay_time, blur_intensity, stumble_intensity, skip_stumble, speed_no_decay )
{
	//tricky shit to make just one run at a time.
	level notify( "start_stumble_walk" );
	level endon( "start_stumble_walk");

	time = 1;

	if( IsDefined(speed_no_decay) && speed_no_decay )
	{
		player_stumble_movement_speed_do_not_decay( move_speed );
	}
	else
	{
		level thread player_stumble_movement_speed( move_speed, decay_time );
	}
	
	level._player thread player_random_blur( decay_time, blur_intensity );

	
	if ( !IsDefined( skip_stumble ) || !skip_stumble )
	{
		//if we've interupted an existing one, use the existing ground plane and bring it back towards neutral before
		//letting the second one come into effect.
		if( !IsDefined( level._ground_ref_ent ) )
		{
			level._ground_ref_ent = spawn( "script_model", ( 0, 0, 0 ) );
			level._player PlayerSetGroundReferenceEnt( level._ground_ref_ent );
		}
		else
		{
			level._ground_ref_ent RotateTo( (0,0,0), time, time * 0.5, time * 0.5 );
			wait time;
		}	

		self stumble_walk_internal( decay_time, stumble_intensity );

		if( IsDefined( level._ground_ref_ent ) )
		{ 
			level._ground_ref_ent RotateTo( (0,0,0), time, time * 0.5, time * 0.5 );
			wait time;
			level._ground_ref_ent delete();
		}
		level._player PlayerSetGroundReferenceEnt( undefined );
	}
	else
	{
		if( IsDefined( level._ground_ref_ent ))
		{ 
			time = 1.0;
			level._ground_ref_ent RotateTo(( 0, 0, 0 ), time, time * 0.5, time * 0.5 );
			wait time;
			level._ground_ref_ent delete();
		}
		level._player PlayerSetGroundReferenceEnt( undefined );
		wait decay_time - time;
	}
	
	if( !( IsDefined(speed_no_decay) && speed_no_decay ) )
	{
		player_stumble_restore_movement_speed();
	}

	setblur( 0, time );
}

player_stumble_movement_speed( speed, decay_time )
{
	level._player AllowJump( false );
	level._player AllowSprint( false );

	// Turn off the stance HUD indicator while the player cannot crouch
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar ( "weapon_view_bob_speed_modifier", 0.7);

	level._player blend_movespeedscale( speed, 0.05 );
	//level._player delayThread( 1, ::blend_movespeedscale, speed, 5 );

	wait 0.05;

	level._player blend_movespeedscale( 1.0, decay_time );
}

player_stumble_movement_speed_do_not_decay( speed )
{
	level._player AllowCrouch( false );
	level._player AllowProne( false );
	level._player AllowJump( false );
	level._player AllowSprint( false );

	// Turn off the stance HUD indicator while the player cannot crouch
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar ( "weapon_view_bob_speed_modifier", 0.7);

	level._player maps\_utility_code::movespeed_set_func( speed );
}

player_stumble_restore_movement_speed()
{
	level._player AllowCrouch( true );
	level._player AllowProne( true );
	level._player AllowJump( true );
	level._player AllowSprint( true );

	SetSavedDvar( "ammoCounterHide", "0" );

	SetSavedDvar ( "weapon_view_bob_speed_modifier", 1);

	level._player blend_movespeedscale( 1.0, 0.1 );
}



player_random_blur( decay_length, blur_intensity )
{
	level._player endon( "death" );
	level endon( "stop_stumble_walk" );

	decay_length_ms = decay_length * 1000;

	start_time = GetTime();

	while ( true )
	{
		wait 0.05;
		if ( randomint( 100 ) > 10 )
			continue;

		time = GetTime();
		if( time > start_time + decay_length_ms )
			return;

		blur = randomint( 3 ) + 2;
		blur = blur * ( 1 - ( ( time - start_time ) / decay_length_ms ) );
		blur_time = randomfloatrange( 0.3, 0.7 );
		recovery_time = randomfloatrange( 0.3, 1 );
		setblur( blur * blur_intensity, blur_time );
		wait blur_time;
		setblur( 0, recovery_time );		

		//blur_wait_time = randomfloatrange( 0.5, 1.5 ); 
		//wait blur_wait_time;
	}
}

stumble_walk_internal( decay_length, stumble_intensity )
{
	level._player endon( "death" );
	level endon( "stop_stumble_walk" );

	start_time = GetTime();

	wait_length = decay_length;

	while ( true )
	{
		velocity = level._player GetVelocity();
		player_speed = abs( velocity [ 0 ] ) + abs( velocity[ 1 ] );

		if ( player_speed < 10 )
		{
			wait 0.05;
			continue;
		}

		time = GetTime();
		if( time > start_time + ( decay_length * 1000 ) )
		{
			return;
		}

		speed_multiplier = player_speed * stumble_intensity * ( 1 - ( ( time - start_time ) / ( decay_length * 1000 ) ) );

		p = randomfloatrange( 3, 5 );
		if ( randomint( 100 ) < 20 )
			p *= 3;
		r = randomfloatrange( 3, 7 );
		y = randomfloatrange( -8, -2 );

		stumble_angles = ( p, y, r );
		stumble_angles = vector_multiply( stumble_angles, speed_multiplier );

		stumble_time = randomfloatrange( .35, .45 );
		recover_time = randomfloatrange( .65, .8 );

		stumble( stumble_angles, stumble_time, recover_time );
	}
}

stumble( stumble_angles, stumble_time, recover_time )
{
	level endon( "stop_stumble_walk" );

	stumble_angles = adjust_angles_to_player( stumble_angles );

	level._ground_ref_ent rotateto( stumble_angles, stumble_time, ( stumble_time / 4 * 3 ), ( stumble_time / 4 ) );
	level._ground_ref_ent waittill( "rotatedone" );

	base_angles = ( randomfloat( 4 ) - 4, randomfloat( 5 ), 0 );
	base_angles = adjust_angles_to_player( base_angles );

	level._ground_ref_ent rotateto( base_angles, recover_time, 0, recover_time / 2 );
	level._ground_ref_ent waittill( "rotatedone" );
}

adjust_angles_to_player( stumble_angles )
{
	pa = stumble_angles[ 0 ];
	ra = stumble_angles[ 2 ];

	rv = anglestoright( level._player.angles );
	fv = anglestoforward( level._player.angles );

	rva = ( rv[ 0 ], 0, rv[ 1 ] * - 1 );
	fva = ( fv[ 0 ], 0, fv[ 1 ] * - 1 );
	angles = vector_multiply( rva, pa );
	angles = angles + vector_multiply( fva, ra );
	return angles + ( 0, stumble_angles[ 1 ], 0 );
}

enemy_lasers()
{
	//self.has_no_ir = undefined;
	self LaserForceOn();

	//we have to create a new entity for the laser flash because if an actor gets deleted we
	//need to be able to kill the fx.
	tag_flash = spawn_tag_origin();	
	tag_flash.origin = self GetTagOrigin( "tag_flash");
	//tag_flash.angles = self GetTagAngles( "tag_flash" );

	tag_flash LinkTo( self, "tag_flash" );

	if ( IsDefined( level._effect[ "laser_aim" ] ) )
	{
		StopFXOnTag( level._effect[ "laser_aim" ], tag_flash, "tag_origin" );
		PlayFxOnTag( level._effect[ "laser_aim" ], tag_flash, "tag_origin" );
	}
	
	self waittill_any( "death", "deleting", "deathanim" );

	if ( IsDefined( level._effect[ "laser_aim" ] ) )
	{
		StopFXOnTag( level._effect[ "laser_aim" ], tag_flash, "tag_origin", true );
	}

	//only try to turn off lasers if the ent hasnt been removed.
	if ( isDefined( self ) )
	{
		self LaserForceOff();
	}	
}

cop_init()
{
	self thread no_cover();
	self.no_pistol_switch = true;
	self.dontevershoot = 1;

	flag_wait( "cops_engaged" );
	//self SetGoalNode( GetNode( self.target, "targetname" ) );
	//self.goalradius = 32;
	self.dontevershoot = undefined;
}

no_cover()
{
	self endon( "death" );
	self.combatmode = "no_cover";
	//self.fixednode = true;
	flag_wait( "swat_encounter_start" );
	self.combatmode = "cover";
	//self.goalradius = 128;
	//self SetGoalNode( GetNode( self.target, "targetname" ) );
	//side_street_volume = GetEnt( "side_street_volume", "script_noteworthy" );
	//self SetGoalVolumeAuto( side_street_volume );
}

ignore_on_jumpedout()
{
	self endon( "death" );
	maps\nx_exfil_util::ignore_everything();
	// Swat van guys need to ignore everything for a few seconds after jumping out
	// So they can get out of the way of the van
	self waittill( "jumpedout" );
	wait 3.5;
	maps\nx_exfil_util::clear_ignore_everything();
}

// If from_flag has been set
// And enemy_noteworthy enemies are under enemy_count
// And to_flag has not been hit, move up and lead the player
ally_lead_player( from_flag, to_flag, enemy_aigroup, enemy_count, color_order )
{
	
	if ( flag( to_flag ) )
	{
		return;
	}

	level endon( to_flag );
	flag_wait( from_flag );
	
	while ( 1 )
	{
		wait 0.5;
		if ( get_ai_group_sentient_count( enemy_aigroup ) < enemy_count )
		{
			issue_color_orders( color_order, "allies" );
		}
	}
}

smoke_throw( aSmokeOrgs, sFlagToStop )
{
	level endon( sFlagToStop );
	exploder ( "smoke_screen" );
	while ( true )
	{
		smokeTarget = undefined;
		foreach ( org in aSmokeOrgs )
		{
			//MagicGrenade( "smoke_grenade_american_no_visblock", org.origin, org.origin + ( 0, 0, 1), RandomFloat( 1.1 ) );
			PlayFX( getfx( "smokescreen" ), org.origin );
			//org thread play_sound_in_space( "smokegrenade_explode_default" );
			wait( RandomFloatRange( .1, .3 ) );
		}
		wait( 28 );
		if ( flag( sFlagToStop ) )
			break;
	}

}

