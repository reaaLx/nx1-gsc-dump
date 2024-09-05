//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  new future rail gun tank, based off abrams tank              **
//    Created: 10/21/2010 - mario sanchez                                   **
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_vehicle_aianim;
#include maps\_vehicle;
#include maps\_atbr;
#include common_scripts\_atbr;
#include common_scripts\utility;

#using_animtree( "vehicles" );

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

CONST_TANK_FOV = 80;
CONST_TURRET_UPDATE_INTERVAL_SEC = 0.001;
CONST_TURRET_PITCH_LIMIT = 12.50;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main( model, type )
{
	//SNDFILE=vehicle_abrams
	build_template( "nx_future_tank", model, type );
	build_localinit( ::init_local );
	build_spawn_callback( ::spawn_callback );
	build_deathmodel( "nx_vehicle_future_tank", "vehicle_m1a1_abrams_dmg" );
	build_shoot_shock( "nx_us_tank_blast" );
	build_drive( %nx_vh_future_tank_movement, %nx_vh_future_tank_movement_backwards, 10 );
	build_exhaust( "distortion/abrams_exhaust" );
	build_deathfx( "explosions/large_vehicle_explosion", undefined, "exp_armor_vehicle" );
	build_treadfx();
	build_rumble( "tank_rumble", 0.05, 4.5, 900, 1, 1 );
	build_team( "allies" );
	build_compassicon( "tank" );
	build_aianims( ::setanims, ::set_vehicle_anims );

	// weapon stuff
	build_mainturret();
	// tagMJS<NOTE> we're going follow what BenK did with the UGV and high jack the auto_nonai mode instead of using the manual mode
	build_turret(	"nx_us_tank_turret",
					"tag_turret_second",
					"nx_vehicle_us_tank_turret",
					undefined,
					"auto_nonai",
					0.0,
					0,
					0 );
					
	build_trophy_turret(	"ugv_trophy_turret",
							"tag_trophy",
							"nx_ugv_rangefinder",
							undefined,
							"trophy",
							0.2,
							undefined,
							undefined,
							"player",		// Trophy owner. 
							undefined,		// Trophy laser sound. 
							undefined
							);


	build_vehicle_weapon_effects( "dust/abrams_desk_dust" );
	build_vehicle_weapon_effects( "dust/abrams_desk_dust", "nx_ugv_rangefinder" );

	// health stuff
	//build_frontarmor( .33 );// regens this much of the damage from attacks to the front
	//build_life( 10000 );
	//build_vehicle_regen_health_system( 100, 5.0 );
	build_life( 15000 );
	build_vehicle_regen_health_system( 150, 3.0 );

	maps\_atbr::init_atbr();

	PreCacheItem( "nx_rail_gun_spread" );
	PreCacheItem( "atbr_missile" );
	PreCacheItem( "atbr_bullet" );

	VisionSetMissilecam( "missilecam" );
	PreCacheShader( "remotemissile_infantry_target" );
	PreCacheShader( "hud_fofbox_self_sp" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

init_local()
{
	//ent_flag_init("primary_turret_override");
	ent_flag_init("secondary_turret_override");
	//ent_flag_init("committed_action");
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

set_vehicle_anims( positions )
{
	return positions;
}


#using_animtree( "generic_human" );

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

setanims()
{
	positions = [];
	for ( i = 0;i < 5;i++ )
		positions[ i ] = spawnstruct();

	// tagJW<NOTE>: Position 0 is the "driver", and the player mount animations use "tag_mount_1"
	// So I swapped position 0 and 4 so that the player and a driver can both be mounted

	positions[ 4 ].sittag = "tag_mount_1";
	positions[ 1 ].sittag = "tag_mount_2";
	positions[ 2 ].sittag = "tag_mount_3";
	positions[ 3 ].sittag = "tag_mount_4";
	positions[ 0 ].sittag = "tag_mount_5";

	positions[ 0 ].bHasGunWhileRiding = false;

	positions[ 4 ].idle = %nx_tp_future_tank_desant_idle_1;
	positions[ 1 ].idle = %nx_tp_future_tank_desant_idle_2;
	positions[ 2 ].idle = %nx_tp_future_tank_desant_idle_3;
	positions[ 3 ].idle = %nx_tp_future_tank_desant_idle_4;
	positions[ 0 ].idle = %nx_tp_future_tank_desant_idle_5;

	positions[ 4 ].death = %exposed_crouch_death_flip;
	positions[ 1 ].death = %exposed_crouch_death_flip;
	positions[ 2 ].death = %exposed_crouch_death_flip;
	positions[ 3 ].death = %exposed_crouch_death_flip;
	positions[ 0 ].death = %exposed_crouch_death_flip;

	positions[ 4 ].getout = %nx_tp_future_tank_desant_dismount_1;
	positions[ 1 ].getout = %nx_tp_future_tank_desant_dismount_2;
	positions[ 2 ].getout = %nx_tp_future_tank_desant_dismount_3;
	positions[ 3 ].getout = %nx_tp_future_tank_desant_dismount_4;
	positions[ 0 ].getout = %nx_tp_future_tank_desant_dismount_5;

	positions[ 4 ].getin = %nx_tp_future_tank_desant_mount_1;
	positions[ 1 ].getin = %nx_tp_future_tank_desant_mount_2;
	positions[ 2 ].getin = %nx_tp_future_tank_desant_mount_3; 
	positions[ 3 ].getin = %nx_tp_future_tank_desant_mount_4;
	positions[ 0 ].getin = %nx_tp_future_tank_desant_mount_5;

	return positions;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_callback( vehicle )
{
	vehicle endon( "death" );

	// here we add only the functionality we want for a player controlled vehicle
	if( IsDefined( vehicle.script_vehicle_player ) )
	{
		level.rg_tank_cannon_spread = 1;
		level.rg_tank_cannon_disable = 0;

		// we need to do a turret update to stop it from going into full auto_nonai mode
		direction_vec = anglesToForward( vehicle.angles );
		trace = bullettrace( vehicle.origin, vehicle.origin + ( direction_vec * 128 ), 0, undefined );
		vehicle.mgturret[ 0 ] SetTurretTargetPosition( trace[ "position" ] );

		while( 1 )
		{
			// we will wait till the player enters the tank
			vehicle waittill( "vehicle_mount" );
			fov = GetDvarInt( "cg_fov" );
			SetSavedDvar( "cg_fov", CONST_TANK_FOV );
			vehicle.damageIsFromPlayer = true;
			vehicle.mgturret[ 0 ].damageIsFromPlayer = true;
			vehicle.rumbleon = false;

			vehicle childthread rg_tank_fire_main_cannon();
			vehicle childthread rg_tank_fire_atbr();
			//vehicle childthread rg_tank_change_main_cannon_fire_mode();
			vehicle childthread rg_tank_machine_gun_update();
			vehicle thread rg_kill_rider_on_death();

			vehicle waittill( "vehicle_dismount" );
			vehicle notify( "stop_death_cleanup" );
			SetSavedDvar( "cg_fov", fov );
			vehicle.damageIsFromPlayer = false;
			vehicle.mgturret[ 0 ].damageIsFromPlayer = false;
			level._player DisableInvulnerability();
			vehicle.rumbleon = true;
		}
	}

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rg_tank_fire_main_cannon()
{
	self endon( "vehicle_dismount" );

	level._player NotifyOnPlayerCommand( "rg_fire_main_gun", "+attack" );

	while( 1 )
	{
		level._player waittill( "rg_fire_main_gun" );

		if( 1 == level.rg_tank_cannon_disable )
		{
			self setVehWeapon( "none" );
		}
		else if( 1 == level.rg_tank_cannon_spread )
		{
			self setVehWeapon( "nx_rail_gun_spread" );
		}
		else
		{
			self setVehWeapon( "m1a1_turret_player" );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rg_tank_machine_gun_update()
{
	self endon( "vehicle_dismount" );

	fire_time = WeaponFireTime( "nx_us_tank_turret" );
	last_shot = GetTime();
	allow_fire = 1;

	while ( 1 )
	{
		trace = get_player_eye_trace();

		if ( isdefined( trace[ "position" ] ) )
		{
			if ( IsDefined( trace[ "entity" ] ) && IsDefined ( trace[ "entity" ].vehicletype ) && "nx_future_tank" == trace[ "entity" ].vehicletype )
			{
				allow_fire = 0;
			}
			else
			{
				allow_fire = 1;
			}

			self.mgturret[ 0 ] SetTurretTargetPosition( trace[ "position" ] );

			// check if player is trying to fire and then fire if we passed our time interval
			if ( 1 == allow_fire )
			{
				if ( level._player ButtonPressed( "BUTTON_RSHLDR" ) || level._player ButtonPressed( "MOUSE2" ) )		// tagMJS<note> this may change if we want the left trigger to do an ADS for the tank
				{
					last_shot_delta = ( GetTime() - last_shot );
					if( fire_time < last_shot_delta )
					{
						self.mgturret[ 0 ] ShootTurret();
						last_shot = GetTime();
					}
				}
			}
		}

		wait ( CONST_TURRET_UPDATE_INTERVAL_SEC );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

get_player_eye_trace()
{
	eye = level._player getEye();
	player_angles = level._player getPlayerAngles();
	if ( CONST_TURRET_PITCH_LIMIT < player_angles[0] )
	{
		player_angles = ( CONST_TURRET_PITCH_LIMIT, player_angles[1], player_angles[2] );
	}
	direction_vec = anglesToForward( player_angles );
	trace = bullettrace( eye, eye + ( direction_vec * 8000 ), 0, undefined );

	return trace;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// tagMJS<GOTCHA> most of the code in this func is a mirror of code in common_scripts/_atbr. If that file changes
// this will need to be updated as well.
rg_tank_fire_atbr()
{
	self endon( "vehicle_dismount" );

	level._player NotifyOnPlayerCommand( "rg_fire_atbr", "+smoke" );

	while( 1 )
	{
		level._player.attached = false;
		level._player waittill( "rg_fire_atbr" );

		// remove controls from tank
		level.rg_tank_cannon_disable = 1;

		atbr_launch_loc = self GetTagOrigin( "tag_atbr" );
		missile = MagicBullet( "atbr_missile", atbr_launch_loc, atbr_launch_loc + ( 0, 0, 2000 ), level._player );
		missile.angles = (-90, self.angles[1], 0);

		atbr_common_attach_to_bullet( level._player, missile );
		level.rg_tank_cannon_disable = 0;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rg_tank_change_main_cannon_fire_mode()
{
	self endon( "vehicle_dismount" );

	level._player NotifyOnPlayerCommand( "rg_change_fire_mode", "weapnext" );

	while( 1 )
	{
		level._player waittill( "rg_change_fire_mode" );

		if( 1 == level.rg_tank_cannon_spread )
		{
			level.rg_tank_cannon_spread = 0;
			self setVehWeapon( "m1a1_turret_player" );
		}
		else
		{
			level.rg_tank_cannon_spread = 1;
			self setVehWeapon( "nx_rail_gun_spread" );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rg_kill_rider_on_death()
{
	// we only want to kill the player if they are currently in the tank
	self endon( "stop_death_cleanup" );
	self waittill( "death" );

	setdvar( "ui_deadquote", "You failed the mission." );
	maps\_utility::missionFailedWrapper();

	level._player DisableInvulnerability();			// not too sure why this is needed. maybe from vehicles protect player flag
	level._player Kill();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

invincible()
{
	self.maxhealth = 100000;
	while ( 1 )
	{
		self waittill("damage");
		//wait( 0.05 );
		self.health = self.maxhealth;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*QUAKED script_vehicle_nx_future_tank (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_future_tank::main( "nx_vehicle_us_tank", "nx_future_tank" );
sound,vehicle_armor_exp,vehicle_standard,all_sp


include,nx_vehicle_us_tank
sound,vehicle_futuretank,,all_sp


defaultmdl="nx_vehicle_us_tank"
default:"vehicletype" "nx_future_tank"
default:"script_team" "allies"
*/
