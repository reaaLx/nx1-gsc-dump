//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  US UGV new vehicle                                           **
//    Created: 10/21/2010 - mario sanchez                                   **
//                                                                          **
//****************************************************************************

#include maps\_vehicle;
#include maps\_utility;
#include maps\_hud_util;
#include maps\_vehicle_aianim;
#include maps\_nx_ugv;
#include common_scripts\utility;
#using_animtree( "vehicles" );



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main( model, type )
{
	build_template( "nx_ugv", model, type );
	build_localinit( maps\_nx_ugv::init_local );
	build_spawn_callback( ::spawn_callback );
	build_life( 99999, 99998, 99999 );
	build_drive( %nx_vh_ugv_movement, %nx_vh_ugv_movement_backwards, 5 );
//	build_drive_special_turning( %nx_vh_ugv_movement_l, %nx_vh_ugv_movement_r );
	build_team( "allies" );

	// Vehicle turret. 
	build_mainturret();

	PrecacheItem( "ugv_main_turret_player" );

	// Build turret hierarchy.
	build_turret(	"ugv_main_turret",
					"TAG_TURRET",
					"nx_ugv_main_turret",
					undefined,
					undefined,
					0.2,
					0,
					0 );

	build_trophy_turret(	"ugv_trophy_turret",
							"TAG_TROPHY",
							"nx_ugv_rangefinder",
							undefined,
							undefined,
							0.2,
							undefined,
							undefined,
							"player",
							"nx_ugv_laser_target",
							"nx_ugv_trophy_laser_track_glow",
							"ugv_main_turret"
							);

	build_vehicle_weapon_effects( "nx/dust/nx_ugv_deck_dust", "nx_ugv_main_turret" );
	build_vehicle_weapon_effects( "nx/dust/nx_ugv_deck_dust", "nx_ugv_rangefinder" );

	// tagBK<NOTE> This cannot be used for general level processing if this vehicle is included. 
	// We are not using build_localinit because the callback is called before the turrets are initialized. 
	//level._vehicleSpawnCallbackThread = ::spawn_callback;

	SetDevDvarIfUninitialized( "cg_setugvdebugdraw", 0 );

	// Fx
	level._effect[ "nx_grenade_explosion_dir" ]		= loadfx( "nx/explosions/nx_grenade_explosion_dir" );
	level._effect[ "nx_ugv_trophy_laser_track_glow" ]	= loadfx( "nx/misc/nx_ugv_trophy_laser_track_glow" );
	level._effect[ "nx_ugv_barrel_smoke" ]	= loadfx( "nx/smoke/nx_ugv_barrel_smoke" );

	// moved this into the player specific ugv section
	//level.ugv_vision_overlay = create_client_overlay( "ugv_vision_overlay", 0, level._player );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_callback( vehicle )
{
	if ( IsDefined( vehicle.script_cheap ) && 0 == vehicle.script_cheap )
	{
		AssertEx( vehicle.mgturret.size == 2, "UGV must have 2 turrets attached to it, a main turret (Turret 1) and a antiballistic (Turret 2)." );


		// Main turret.
		vehicle.main_turret = vehicle.mgturret[0];
		vehicle.main_turret SetSentryOwner( vehicle );
		vehicle.main_turret setmode( "auto_nonai" );
	}


	// here we add only the functionality we want for a player controlled vehicle
	if( IsDefined( vehicle.script_vehicle_player ) )
	{
		level.ugv_vision_overlay = create_client_overlay( "ugv_vision_overlay", 0, level._player );

		// player pertinant stuff here
		vehicle thread main_turret_update( level._player );				// this should call code from maps\_nx_ugv
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*QUAKED script_vehicle_nx_ugv (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_us_ugv::main( "nx_vehicle_ugv" );


include,nx_vehicle_ugv
sound,nx_ugv,,all_sp

defaultmdl="nx_vehicle_ugv"
default:"vehicletype" "nx_ugv"
default:"script_team" "allies"
*/


/*QUAKED script_vehicle_nx_ugv_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_us_ugv::main( "nx_vehicle_ugv","nx_ugv_physics" );


include,nx_vehicle_ugv
sound,nx_ugv,,all_sp

defaultmdl="nx_vehicle_ugv"
default:"vehicletype" "nx_ugv_physics"
default:"script_team" "allies"
*/
