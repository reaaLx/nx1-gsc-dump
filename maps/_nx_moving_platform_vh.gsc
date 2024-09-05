/*QUAKED script_vehicle_nx_moving_platform (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

maps\_nx_moving_platform_vh::main("nx_vehicle_moving_platform");

include,nx_vehicle_moving_platform

defaultmdl="nx_vehicle_moving_platform"
default:"vehicletype" "nx_moving_platform"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_nx_moving_platform_ai_turret (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

maps\_nx_moving_platform_vh::main("nx_vehicle_moving_platform", "nx_moving_platform_ai_turret");

include,nx_vehicle_moving_platform

defaultmdl="nx_vehicle_moving_platform"
default:"vehicletype" "nx_moving_platform_ai_turret"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_nx_moving_platform_enemy_ai_turret (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

maps\_nx_moving_platform_vh::main("nx_vehicle_moving_platform", "nx_moving_platform_enemy_ai_turret");

include,nx_vehicle_moving_platform

defaultmdl="nx_vehicle_moving_platform"
default:"vehicletype" "nx_moving_platform_enemy_ai_turret"
default:"script_team" "axis"
*/

#include common_scripts\utility;
#include maps\_utility;
#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );

main( model, type )
{
	build_template( "nx_moving_platform", model, type );
	build_localinit( ::init_local );
	build_life( 99999, 99998, 99999 );
	build_drive( %nx_vh_moving_platform_movement, undefined, 100 );	

	if ( IsDefined( type ) )
	{
		if( type == "nx_moving_platform_ai_turret" )
		{
			build_aianims( ::setanims, ::set_vehicle_anims );
			build_turret(	"nx_chinese_lgv_turret_skimmer",
							"tag_turret_ai",
							"nx_vehicle_chinese_lgv_main_turret",
							undefined,
							"auto_ai",
							0.2,
							15,
							-14 );

		}
		else if ( type == "nx_moving_platform_enemy_ai_turret" )
		{
			build_aianims( ::setanims_enemy, ::set_vehicle_anims );
			build_turret(	"nx_chinese_lgv_turret_skimmer",
							"tag_turret_ai_2",
							"nx_vehicle_chinese_lgv_main_turret",
							undefined,
							"auto_ai",
							0.2,
							15,
							-14 );
		}
	}

	//fx
	level._effect[ "maglevfx_normal" ] = loadfx( "nx/nx_lava/nx_lava_train_propulsion_distortion_01" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
init_local()
{
	// 'Vignette' vehicles should not run expensive entity-affecting code.
	self SetTouchEntities( 0 );

	//_lauch off the maglex train parks: apm
	self train_maglex_fx();	
}

train_maglex_fx()
{
	self endon( "death" );
	self endon( "engines_off" );
	maglevfx_normal = GetFX( "maglevfx_normal" );

	PlayFXOnTag( maglevfx_normal, self, "TAG_FX_WHEEL_BACK_RIGHT" );
	PlayFXOnTag( maglevfx_normal, self, "TAG_FX_WHEEL_BACK_LEFT" );
	wait 0.01;
	PlayFXOnTag( maglevfx_normal, self, "TAG_FX_WHEEL_FRONT_RIGHT" );
	PlayFXOnTag( maglevfx_normal, self, "TAG_FX_WHEEL_FRONT_LEFT" );
}	

stop_train_maglex_fx()
{
	maglevfx_normal = GetFX( "maglevfx_normal" );
	StopFXOnTag( maglevfx_normal, self, "TAG_FX_WHEEL_BACK_RIGHT" );
	StopFXOnTag( maglevfx_normal, self, "TAG_FX_WHEEL_BACK_LEFT" );
	StopFXOnTag( maglevfx_normal, self, "TAG_FX_WHEEL_FRONT_RIGHT" );
	StopFXOnTag( maglevfx_normal, self, "TAG_FX_WHEEL_FRONT_LEFT" );
}	

#using_animtree( "generic_human" );
setanims()
{
	positions = [];

	positions[ 0 ] = spawnstruct();
	positions[ 0 ].sittag = "tag_gunner";
	positions[ 0 ].idle = %nx_tp_chinese_lgv_gunner_idle;
	positions[ 0 ].getin = %nx_tp_chinese_lgv_gunner_mount;
	positions[ 0 ].getout = %nx_tp_chinese_lgv_gunner_getout;
	positions[ 0 ].death = %nx_tp_chinese_lgv_gunner_death;	
	positions[ 0 ].exit_allow_death = true;
	positions[ 0 ].exit_death_ragdoll_immediate = true;
	positions[ 0 ].death_no_ragdoll = true;
	positions[ 0 ].mgturret = 0;// which of the turrets is this guy going to use

	return positions;
}
setanims_enemy()
{
	positions = [];

	positions[ 0 ] = spawnstruct();
	positions[ 0 ].sittag = "tag_gunner_2";
	positions[ 0 ].idle = %nx_tp_chinese_lgv_gunner_idle;
	positions[ 0 ].getin = %nx_tp_chinese_lgv_gunner_mount;
	positions[ 0 ].getout = %nx_tp_chinese_lgv_gunner_getout;
	positions[ 0 ].death = %nx_tp_chinese_lgv_gunner_death;	
	positions[ 0 ].exit_allow_death = true;
	positions[ 0 ].exit_death_ragdoll_immediate = true;
	positions[ 0 ].death_no_ragdoll = true;
	positions[ 0 ].mgturret = 0;// which of the turrets is this guy going to use

	return positions;
}

set_vehicle_anims( positions )
{		
	//empty for now. 
	return positions;	
}
