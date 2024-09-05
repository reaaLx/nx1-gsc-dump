//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Chinese UGV new vehicle                                      **
//    Created: 01/01/2010 - Aaron Williams                                  **
//                                                                          **
//****************************************************************************

#include common_scripts\utility;
#include maps\_utility;
#include maps\_vehicle;
#include maps\_vehicle_aianim;
#include maps\_nx_ugv;
#using_animtree( "vehicles" );


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main( model, type, turret )
{
	build_template( "nx_chinese_ugv", model, type );
	build_localinit( maps\_nx_ugv::init_local );
	build_spawn_callback( ::spawn_callback );
	build_life( 99999, 99998, 99999 );
	build_drive( %nx_vh_chinese_ugv_movement,%nx_vh_chinese_ugv_movement_backwards, 5.45 );
	build_treadfx();
	build_team( "axis" );

	if ( !isdefined( turret ) )
	{
		turret = "ugv_chinese_main_turret";
	}
		
	// Vehicle turret. 
	build_mainturret();

	PrecacheItem( "ugv_main_turret_player" );


	// Build turret hierarchy.
	build_turret(	turret,
					"TAG_TURRET",
					"nx_vehicle_chinese_ugv_main_turret",
					undefined,
					undefined,
					0.2,
					0,
					0 );

	build_trophy_turret(	"ugv_trophy_turret",
							"TAG_TROPHY",
							"nx_vehicle_chinese_ugv_trophy",
							undefined,
							undefined,
							0.2,
							undefined,
							undefined,
							"vehicle",
							undefined,
							undefined,
							turret );

	build_turret(	"ugv_chinese_mg",
					"TAG_TURRET2",
					"nx_vehicle_chinese_ugv_turret2",
					undefined,
					undefined,
					0.0,
					0,
					0,
					turret );

	build_vehicle_weapon_effects( "nx/dust/nx_ugv_deck_dust", "nx_vehicle_chinese_ugv_main_turret" );

	//build_vehicle_weapon_effects( "nx/dust/nx_ugv_deck_dust", "nx_vehicle_chinese_ugv_trophy" );//we dont't want deck fx to fire off for this- too expensive

	SetDevDvarIfUninitialized( "cg_setugvdebugdraw", 0 );

	// Fx
	level._effect[ "nx_grenade_explosion_dir" ]		= loadfx( "nx/explosions/nx_grenade_explosion_dir" );
	level._effect[ "nx_ugv_trophy_laser_track_glow" ]	= loadfx( "nx/misc/nx_ugv_trophy_laser_track_glow" );
	level._effect[ "nx_ugv_barrel_smoke" ]	= loadfx( "nx/smoke/nx_ugv_barrel_smoke" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_callback( vehicle )
{
	if ( IsDefined( vehicle.script_cheap ) && 0 == vehicle.script_cheap )
	{
		AssertEx( vehicle.mgturret.size == 3, "cUGV must have 3 turrets attached to it." );

		// Main turret.
		vehicle.main_turret = vehicle.mgturret[0];
		vehicle.main_turret SetSentryOwner( vehicle );
		vehicle.main_turret setmode( "auto_nonai" );

		// Secondary turret
		vehicle.secondary_turret = vehicle.mgturret[2];
		vehicle.secondary_turret SetSentryOwner( vehicle );
		vehicle.secondary_turret setmode( "auto_nonai" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*QUAKED script_vehicle_nx_ec_chinese_ugv (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_chinese_ugv::main( "nx_vehicle_chinese_ugv" );


include,nx_vehicle_chinese_ugv
sound,nx_ugv,,all_sp


defaultmdl="nx_vehicle_chinese_ugv"
default:"vehicletype" "nx_chinese_ugv"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_nx_ec_chinese_ugv_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_chinese_ugv::main( "nx_vehicle_chinese_ugv","nx_chinese_ugv_physics" );


include,nx_vehicle_chinese_ugv
sound,nx_ugv,,all_sp


defaultmdl="nx_vehicle_chinese_ugv"
default:"vehicletype" "nx_chinese_ugv_physics"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_nx_ec_chinese_ugv_cheapfx (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_chinese_ugv::main( "nx_vehicle_chinese_ugv", "nx_chinese_ugv_cheapfx", "ugv_chinese_main_turret_cheapfx" );


include,nx_vehicle_chinese_ugv
sound,nx_ugv,,all_sp


defaultmdl="nx_vehicle_chinese_ugv"
default:"vehicletype" "nx_chinese_ugv_cheapfx"
default:"script_team" "axis"
*/


