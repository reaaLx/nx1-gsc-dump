//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module: Lava Train Derail												**
//                                                                          **
//    Created: 07/25/10 - Travis Chen (trchen x 4143)						**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_anim;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
}

section_flag_inits()
{
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_objectives( objective_num )
{
	return objective_num;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

TRAIN_2_SPEED_DERAIL = 115;

train_derail_vo()
{
	flag_wait( "vignette_train_derailment" );
	thread audio_amb_changes();
	
	radio_dialogue( "lava_bak_derail_braceforimpact" );					// dialog: "They cut the tracks! Brace for impact!"
}

audio_amb_changes()
{
	level.amb_train_ext setsoundvolume( "amb_lava_train_ext", -100, 1.5 );
	level.amb_train_int setsoundvolume( "amb_lava_train_int", 0, 2 );
	wait 3;
	level.amb_train_ext setsoundvolume( "amb_lava_train_ext", -5, 1.5 );
	level.amb_train_int setsoundvolume( "amb_lava_train_int", -100, 1.5 );
	wait 3;
	level.amb_train_ext setsoundvolume( "amb_lava_train_ext", -100, 1 );

}

train_derail_start()
{
	// Setup Train 2 Turret vehicle and Init player start location
	maps\nx_lava_util::setup_train_vehicles( level.train_turret, false );
	maps\nx_lava_util::show_hide_train( level.train_turret, "show" );
		
	// Start the movement from debug position
	level thread train_derail_move_start();
	
	// Used for player_gets_on_turret
	level.train_2_jump_to = true;
	level thread maps\nx_lava_train_2::player_gets_on_turret( 240 );
	flag_set( "player_on_turret_anim_complete" );
	//level thread maps\nx_lava_train_2::train_2_ally_thread();
}

train_derail()
{
	// VO 
	level thread train_derail_vo();

	// Spawn skimmers
	level thread spawn_skimmers();
	
	flag_wait( "vignette_train_derailment" );

	level notify ("end_fake_train_movement");

	// Thread derailment FX
	level thread train_derail_fx();
	level thread train_derail_player_thread();

	// Hide the player vehicle
	maps\nx_lava_util::show_hide_train( level.train_turret, "hide", true );

	// Unlink player from turret
	player_gets_off_turret();
	
	// Delete train
	maps\nx_lava_util::delete_train( level.train_turret );

	// Do derail
	maps\nx_lava_anim::train_derailment_spawn();
}

train_derail_move_start()
{
	// Move front vehicle
	level.train_turret maps\nx_lava_util::train_switch_target( "train_2_front_derail");
	thread maps\nx_lava_util::move_train( level.train_turret, TRAIN_2_SPEED_DERAIL, 10000, 10 );
}

train_derail_player_thread()
{
	// tagTC<hack> - need to figure out why bullets aren't aiming correctly
	level._player magic_bullet_shield();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_skimmers()
{
	// Wait for skimmer spawn
	spawn_trigger = GetEnt( "spawn_derail_skimmer_rail_haters", "targetname" );
	spawn_trigger waittill( "trigger" );

	skimmers = GetEntArray( spawn_trigger.target, "targetname" );
	foreach( skimmer_spawner in skimmers )
	{
		skimmer = skimmer_spawner maps\_attack_heli::SAV_setup( "pathing_shooting" );
		skimmer thread skimmer_derail_spawn_func( 4608 );
	}

	// Wait for skimmer spawn
	spawn_trigger = GetEnt( "spawn_derail_skimmer_shooters", "targetname" );
	spawn_trigger waittill( "trigger" );

	skimmers = GetEntArray( spawn_trigger.target, "targetname" );
	foreach( skimmer_spawner in skimmers )
	{
		skimmer = skimmer_spawner maps\_attack_heli::SAV_setup( "pathing_shooting" );
		skimmer thread skimmer_derail_spawn_func( 3072 );
	}
}

skimmer_derail_spawn_func( my_dist )
{
	self Vehicle_SetSpeedImmediate( TRAIN_2_SPEED_DERAIL, TRAIN_2_SPEED_DERAIL, TRAIN_2_SPEED_DERAIL );

	if( self isHelicopter() )
	{
		self SetLookAtEnt( level._player );
		self SetMaxPitchRoll( 30, 30 );
	}

	self thread skimmer_follow_player( 0.5, 1, .25, TRAIN_2_SPEED_DERAIL, my_dist, 0.7 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

train_derail_fx()
{
	///apm: im sorry this is dirty and gross
	fx_point = GetEnt( "nx_rego_impact_huge", "targetname" );
	
	Earthquake( 0.2, 2, level._player.origin, 10000 );

	playfx( getfx( "derail_end_explosion" ), fx_point.origin + ( 0, -550, 0 ) );
	wait( 0.1 );
	playfx( getfx( "turret_explosion" ), fx_point.origin + ( 100, -550, 0 ) );
	wait( 0.1 );
	playfx( getfx( "derail_end_explosion" ), fx_point.origin + ( 123, -650, 0 ) );
	wait( 0.1 );
	playfx( getfx( "turret_explosion" ), fx_point.origin + ( -50, -750, 0 ) );

	wait( 1.5 );
	playfx( getfx( "turret_explosion" ), fx_point.origin + ( -50, -950, -500 ) );
	wait( 1.0);

	level thread train_derail_slowmo();

	playfx( getfx( "derail_end_dust_cloud" ), fx_point.origin + ( -900, -850, -500 ) );


	Earthquake( 0.2, 2, level._player.origin, 10000 );

	wait( 0.1 );
	
	playfx( getfx( "derail_end_dust_cloud" ), fx_point.origin + ( -900, -1050, -800 ) );


}

train_derail_slowmo()
{	
	// Slow motion
	SetSlowMotion( 1.0, 0.5, 0.2 );

	wait( 3.5 );
	
	// Slow motion
	SetSlowMotion( 0.5, 1.0, 0.2 );	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_gets_off_turret()
{
	turret = GetEnt( "turret_player", "targetname" );
	turret_origin = turret.origin;

	// Lock the player to the turret.
	level._player Unlink();
    turret Delete();
    level._player SetOrigin( turret_origin );
}


//*******************************************************************
//		SKIMMER UNTILS                                              *
//                                                                  *
//*******************************************************************

skimmer_follow_player( time_low, time_high, speed_percent, base_speed, max_dist, arc, isFollow )
{
	self endon( "death" );
	self endon( "stop_follow_player" );
	self endon( "reached_end_node" );

	if( !IsDefined( arc ) )
		arc = 0;
	if( !IsDefined( isFollow) )
		isFollow = false;

	while( 1 ) 
	{
		ra_seed = level._player.angles;
		if( IsDefined( level.train_turret[4].vehicle ) )
			ra_seed = level.train_turret[4].vehicle.angles;
			
		to_player = VectorNormalize( self.origin - level._player.origin );
		right_angles = AnglesToForward( ra_seed );
		dot = VectorDot( right_angles, to_player );
		dist = Distance( self.origin, level._player.origin );

		// check location and adjust speed
		if( dot < arc )
		{
			// IPrintlnBold( "BEHIND " + dist );
			skim_speed = base_speed * 1.33;
			self Vehicle_SetSpeed( skim_speed, skim_speed, skim_speed );
		}
		else if( dist < 2304 )
		{
			// IPrintlnBold( "BEHINDISH " + dist );
			skim_speed = base_speed + ( base_speed  * speed_percent );
			self Vehicle_SetSpeed( skim_speed, skim_speed, skim_speed );
		}
		else if( dist > max_dist ) 
		{
			// IPrintlnBold( "AHEAD " + dist );
			skim_speed = base_speed - ( base_speed  * speed_percent );
			self Vehicle_SetSpeed( skim_speed, skim_speed, skim_speed );
		}
		else if( isFollow )
		{
			self Vehicle_SetSpeed( base_speed, base_speed, base_speed );
		}

		wait( RandomFloatRange( time_low, time_high ) );
	}
}