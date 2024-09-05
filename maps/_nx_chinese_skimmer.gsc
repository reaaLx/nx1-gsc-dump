/*QUAKED script_vehicle_nx_ec_chinese_skimmer (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

maps\_nx_chinese_skimmer::main( "nx_vehicle_chinese_skimmer" );

include,_attack_heli
include,nx_vehicle_chinese_skimmer
sound,vehicle_blackhawk,vehicle_standard,all_sp

defaultmdl="nx_vehicle_chinese_skimmer"
default:"vehicletype" "nx_chinese_skimmer"
default:"script_team" "axis"
*/
#include maps\_anim;
#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_vehicle_aianim;

MIN_DELAY = 0.0;
MAX_DELAY = 2.0;

#using_animtree( "vehicles" );

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
main( model, type, no_death )
{
	build_template( "nx_chinese_skimmer", model, type );
	build_localinit( ::init_local );

	build_drive( %nx_vh_chinese_skimmer_movement, undefined, 0 );

	if ( !isdefined( no_death ) )
	{
		// tagBR< note >: A simple setup, initial death explode...then one after a delay & physics kick
		//build_deathfx( "explosions/helicopter_explosion_secondary_small", undefined, "blackhawk_helicopter_hit" );
		//build_deathfx( "nx/explosions/nx_moon_grenade_explosion_default", undefined, "blackhawk_helicopter_hit" );
		build_deathfx( "nx/explosions/nx_aerial_explosion_skimmer", undefined, "skimmer_primary_exp" );
		build_crashfx( "nx/nx_lava/nx_lava_skimmer_crash_fx" , "tag_engine_left", "skimmer_secondary_exp" );

		// This must be called for all SAV's after all build_deathfx calls
		build_SAV_death_delay(MIN_DELAY, MAX_DELAY );

		// tagBR< note >: Commenting all these out (OVERKILL!)
		//blackhawk_death_fx = [];
		//blackhawk_death_fx[ "nx_vehicle_chinese_skimmer" ] 					 = "explosions/helicopter_explosion";

		//build_deathfx( "explosions/helicopter_explosion_secondary_small", 		"tag_engine_left", 		"blackhawk_helicopter_hit", 			undefined, 			undefined, 		undefined, 		0.2, 		true );
		//build_deathfx( "explosions/helicopter_explosion_secondary_small", 		"elevator_jnt", 		"blackhawk_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		0.5, 		true );
		//build_deathfx( "fire/fire_smoke_trail_L", 								"elevator_jnt", 		"blackhawk_helicopter_dying_loop", 		true, 				0.05, 			true, 			0.5, 		true );
		//build_deathfx( "explosions/helicopter_explosion_secondary_small", 		"tag_engine_right", 	"blackhawk_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		2.5, 		true );
		//build_deathfx( "explosions/helicopter_explosion_secondary_small", 		"tag_deathfx", 			"blackhawk_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		4.0 );
		//build_deathfx( blackhawk_death_fx[ model ], 								undefined, 			"blackhawk_helicopter_crash", 			undefined, 			undefined, 		undefined, 		 - 1, 		undefined, 	"stop_crash_loop_sound" );

		//build_rocket_deathfx( "explosions/aerial_explosion_heli_large", 	"tag_deathfx", 	"blackhawk_helicopter_crash",undefined, 			undefined, 		undefined, 		 undefined, true, 	undefined, 0  );
	}

	build_life( 300 );
	build_treadfx();
	build_rumble( "stryker_rumble", 0.15, 4.5, 500, 1, 1 );
	build_team( "axis" );

    //special for ec_skimmer/////
	level._effect[ "engineeffect_quicker_large" ]	= loadfx( "nx/misc/nx_lunar_skimmer_thruster_quicker_large" );
	level._effect[ "engineeffect_large" ]			= loadfx( "nx/misc/nx_lunar_skimmer_thruster_large" );
    level._effect[ "engineeffect_med" ]			    = loadfx( "nx/misc/nx_lunar_skimmer_thruster_med" );
    level._effect[ "engineeffect_small" ]			= loadfx( "nx/misc/nx_lunar_skimmer_thruster_small" );

	//circumventing broke? buildlight function
	level._effect[ "red_light_01" ]					= loadfx( "nx/misc/nx_lunar_skimmer_red_light_01" );

	PreCacheItem( "nx_chinese_skimmer_weap" );

	maps\_attack_heli::preLoad();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
init_local()
{
	self.originheightoffset = distance( self gettagorigin( "tag_origin" ), self gettagorigin( "tag_ground" ) );
	self.script_badplace = false;// All helicopters dont need to create bad places

	level._SAV_setup_script = maps\_attack_heli::SAV_setup;

	level._SAV_circling_func = maps\_attack_heli::SAV_switch_to_circling;

	self._attack_heli_custom_miss_func = ::skimmer_fire;
	self._attack_heli_custom_firing_func = ::skimmer_fire;

	self._SAV_turret_type = "nx_chinese_skimmer_weap";
	self._last_turret_fired = RandomInt( 2 );

	// To keep track of which thrusters are on
	self._thrusters["back"] = 0;
	self._thrusters["front"] = 0;
	self._thrusters["left"] = 0;
	self._thrusters["right"] = 0;

	self set_heli_move( "instant" ); // <-- This sets yaw speed very high
	self SetTurningAbility( 1.0 ); // <-- This makes turning sharper
	self SetJitterParams( ( 0, 0, 0 ), 0, 0 );
	self SetMaxPitchRoll( 0, 0 );
	self SetYawSpeed( 60, 60 );

	// Set up accuracy.
	self set_baseaccuracy( 0.8 );

	// Have to put this here so that the above line and SetVehGoalPos() below will work nicely together...<sigh>
	wait 0.05;

	self thread skimmer_engine_fx_think();

	self thread skimmer_stabilizer_fx();

	self skimmer_wait_and_kill_all_fx();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
skimmer_fire( target, burstsize, fireTime, miss_vec )
{
	self endon( "death" );

	for ( i = 0; i < burstsize; i++ )
	{
		if ( ( self.allowShoot ) && ( !self.firingMissiles ) )
		{
			if ( !isAlive( target ) )
			{
				return;
			}

			if ( !IsDefined( miss_vec ) )
			{
				miss_vec = ( 0, 0, 0 );
			}

			self SetTurretTargetEnt( target, miss_vec );

			if ( self._last_turret_fired == 1 )
			{
				self FireWeapon( "TAG_FLASH" );
				self._last_turret_fired = 0;
			}
			else
			{
				self FireWeapon( "TAG_FLASH2" );
				self._last_turret_fired = 1;
			}
		}

		wait fireTime;		
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
skimmer_engine_fx_think()
{
	self endon( "death" );
	self endon( "stop_engineeffects" );

	//turning off for now, breaks game upon death
	//maps\_vehicle::lights_on( "running" ); 
	self skimmer_light_fx();

	wait 0.01;

	engineeffects_quicker_large = GetFX( "engineeffect_quicker_large" );
	engineeffects_med = GetFX( "engineeffect_med" );
    engineeffects_large = GetFX( "engineeffect_large" );

	// Bottom (gravity-defying) thruster is always on
	PlayFXOnTag( engineeffects_quicker_large, self, "tag_fx_bottom_thruster" );

	// These help to make the thrusters not fire until the skimmer is moving at an acceptable rate
	LEFT_RIGHT_CLAMP = 25.0;
	FRONT_BACK_CLAMP = 25.0;

	while ( 1 )
	{
		forward = AnglesToForward( self.angles );
		velocity = self Vehicle_GetVelocity();
		dot = VectorDot( velocity, forward );
		//theta = acos( VectorDot( velocity_dir, forward ) );
		cross = VectorCross( velocity, forward );
		//if ( cross[2] < 0 )
		//{
		//	theta = 0 - theta;
		//}

		// Back/Front
		if ( ( dot > 0 ) && !self._thrusters["back"] )
		{
			if ( dot > FRONT_BACK_CLAMP )
			{
				PlayFXOnTag( engineeffects_large, self, "tag_fx_back_thruster" );
				self._thrusters["back"] = 1;
			}

			if ( self._thrusters["front"] )
			{
				StopFXOnTag( engineeffects_large, self, "tag_fx_front_thruster" );
				self._thrusters["front"] = 0;
			}
		}
		else if ( ( dot < 0 ) && !self._thrusters["front"] )
		{
			if ( dot < ( FRONT_BACK_CLAMP * -1 ) )
			{
				PlayFXOnTag( engineeffects_large, self, "tag_fx_front_thruster" );
				self._thrusters["front"] = 1;
			}

			if ( self._thrusters["back"] )
			{
				StopFXOnTag( engineeffects_large, self, "tag_fx_back_thruster" );
				self._thrusters["back"] = 0;
			}
		}
		else
		{
			if ( self._thrusters["front"] )
			{
				StopFXOnTag( engineeffects_large, self, "tag_fx_front_thruster" );
				self._thrusters["front"] = 0;
			}

			if ( self._thrusters["back"] )
			{
				StopFXOnTag( engineeffects_large, self, "tag_fx_back_thruster" );
				self._thrusters["back"] = 0;
			}
		}

		// Left/Right
		if ( ( cross[2] > 0 ) && !self._thrusters["left"] )
		{
			if ( cross[2] > LEFT_RIGHT_CLAMP )
			{
				PlayFXOnTag( engineeffects_large, self, "tag_fx_left_thruster" );
				self._thrusters["left"] = 1;
			}

			if ( self._thrusters["right"] )
			{
				StopFXOnTag( engineeffects_large, self, "tag_fx_right_thruster" );
				self._thrusters["right"] = 0;
			}
		}
		else if ( ( cross[2] < 0 ) && !self._thrusters["right"] )
		{
			if ( cross[2] < ( LEFT_RIGHT_CLAMP * -1 ) )
			{
				PlayFXOnTag( engineeffects_large, self, "tag_fx_right_thruster" );
				self._thrusters["right"] = 1;
			}

			if ( self._thrusters["left"] )
			{
				StopFXOnTag( engineeffects_large, self, "tag_fx_left_thruster" );
				self._thrusters["left"] = 0;
			}
		}
		else
		{
			if ( self._thrusters["right"] )
			{
				StopFXOnTag( engineeffects_large, self, "tag_fx_right_thruster" );
				self._thrusters["right"] = 0;
			}

			if ( self._thrusters["left"] )
			{
				StopFXOnTag( engineeffects_large, self, "tag_fx_left_thruster" );
				self._thrusters["left"] = 0;
			}
		}

		wait 0.05;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
skimmer_stabilizer_fx()
{
	self endon( "death" );
	self endon( "stop_engineeffects" );

	self ent_flag_init( "engineeffects" );
	self ent_flag_set( "engineeffects" );
	//engineeffects_quicker_large = GetFX( "engineeffect_quicker_large" );
	engineeffects_large = getfx( "engineeffect_large" );
    engineeffects_med = getfx( "engineeffect_med" );
    engineeffects_small = getfx( "engineeffect_small" );
	
	for ( ;; )
	{
		self ent_flag_wait( "engineeffects" );

		playfxontag( engineeffects_small, self, "tag_fx_top_thruster" );
		//playfxontag( engineeffects_quicker_large, self, "tag_fx_bottom_thruster" );
		wait 0.01;

		if ( !self._thrusters["left"] )
		{
			playfxontag( engineeffects_med, self, "tag_fx_left_thruster" );
		}
		if ( !self._thrusters["right"] )
		{
			playfxontag( engineeffects_med, self, "tag_fx_right_thruster" );
		}
		wait 0.01;

		if ( !self._thrusters["front"] )
		{
			playfxontag( engineeffects_med, self, "tag_fx_front_thruster" );
		}
		if ( !self._thrusters["back"] )
		{
			playfxontag( engineeffects_med, self, "tag_fx_back_thruster" );
		}
        
		self ent_flag_waitopen( "engineeffects" );

		StopFXOnTag( engineeffects_small, self, "tag_fx_top_thruster" );
		//StopFXOnTag( engineeffects_quicker_large, self, "tag_fx_bottom_thruster" );
        wait 0.01;
        Stopfxontag( engineeffects_med, self, "tag_fx_left_thruster" );
		Stopfxontag( engineeffects_med, self, "tag_fx_right_thruster" );
		wait 0.01;
        Stopfxontag( engineeffects_med, self, "tag_fx_front_thruster" );
		Stopfxontag( engineeffects_med, self, "tag_fx_back_thruster" );
        
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
skimmer_light_fx()
{
	self endon( "death" );
	self endon( "lights_off" );
	Light01 = GetFX( "red_light_01" );

	PlayFXOnTag( Light01, self, "TAG_FX_REDLIGHT_F_R_01" );
	PlayFXOnTag( Light01, self, "TAG_FX_REDLIGHT_F_R_02" );
	wait 0.01;
	PlayFXOnTag( Light01, self, "TAG_FX_REDLIGHT_F_L_01" );
	PlayFXOnTag( Light01, self, "TAG_FX_REDLIGHT_F_L_02" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
skimmer_wait_and_kill_all_fx()
{
	self waittill( "stop_engineeffects" );

	engineeffects_quicker_large = GetFX( "engineeffect_quicker_large" );
	engineeffects_med = GetFX( "engineeffect_med" );
    engineeffects_large = GetFX( "engineeffect_large" );
	engineeffects_small = getfx( "engineeffect_small" );
	Light01 = GetFX( "red_light_01" );

	StopFXOnTag( engineeffects_quicker_large, self, "tag_fx_bottom_thruster", true );
	wait 0.01;
	StopFXOnTag( engineeffects_large, self, "tag_fx_back_thruster", true );
	StopFXOnTag( engineeffects_large, self, "tag_fx_front_thruster", true );
	wait 0.01;
	StopFXOnTag( engineeffects_large, self, "tag_fx_left_thruster", true );
	StopFXOnTag( engineeffects_large, self, "tag_fx_right_thruster", true );
	wait 0.01;
	StopFXOnTag( engineeffects_small, self, "tag_fx_top_thruster", true );
	wait 0.01;
	StopFXOnTag( engineeffects_med, self, "tag_fx_left_thruster", true );
	StopFXOnTag( engineeffects_med, self, "tag_fx_right_thruster", true );
	wait 0.01;
	StopFXOnTag( engineeffects_med, self, "tag_fx_front_thruster", true );
	StopFXOnTag( engineeffects_med, self, "tag_fx_back_thruster", true );
	wait 0.01;
	StopFXOnTag( Light01, self, "TAG_FX_REDLIGHT_F_R_01", true );
	StopFXOnTag( Light01, self, "TAG_FX_REDLIGHT_F_R_02", true );
	wait 0.01;
	StopFXOnTag( Light01, self, "TAG_FX_REDLIGHT_F_L_01", true );
	StopFXOnTag( Light01, self, "TAG_FX_REDLIGHT_F_L_02", true );
}

