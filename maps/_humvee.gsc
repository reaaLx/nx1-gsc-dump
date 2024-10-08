#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );

main( model, type )
{
	//SNDFILE=vehicle_hummer

	build_template( "humvee", model, type );
	build_localinit( ::init_local );

	build_deathmodel( "vehicle_hummer", "vehicle_hummer_destroyed" );
	build_deathmodel( "vehicle_hummer_no_doors", "vehicle_hummer_destroyed" );
	build_deathmodel( "vehicle_hummer_viewmodel", "vehicle_hummer_opentop_destroyed" );
	build_deathmodel( "vehicle_hummer_opentop", "vehicle_hummer_opentop_destroyed"  );
	build_deathmodel( "vehicle_humvee_camo" ); //old humvee
	build_deathmodel( "vehicle_humvee_camo_50cal_doors" ); //old humvee
	build_deathmodel( "vehicle_humvee_camo_50cal_nodoors" ); //old humvee

	build_deathmodel( "vehicle_hummer_mexico_destructible","vehicle_hummer_mexico_destroyed" );
	build_deathmodel( "vehicle_hummer_mexico_opentop", "vehicle_hummer_mexico_opentop_destroyed"  );
	build_deathmodel( "vehicle_hummer_doors_open", "vehicle_hummer_destroyed" );	

	hummer_death_fx = [];
	hummer_death_fx[ "vehicle_hummer" ] = "explosions/vehicle_explosion_hummer";
	hummer_death_fx[ "vehicle_hummer_no_doors" ] = "explosions/vehicle_explosion_hummer_nodoors";
	hummer_death_fx[ "vehicle_hummer_viewmodel" ] = "explosions/vehicle_explosion_hummer_nodoors";
	hummer_death_fx[ "vehicle_hummer_opentop" ] = "explosions/vehicle_explosion_hummer_nodoors";
	hummer_death_fx[ "vehicle_humvee_camo" ] = "explosions/vehicle_explosion_medium";
	hummer_death_fx[ "vehicle_humvee_camo_50cal_doors" ] = "explosions/vehicle_explosion_medium";
	hummer_death_fx[ "vehicle_humvee_camo_50cal_nodoors" ] = "explosions/vehicle_explosion_medium";
	hummer_death_fx[ "vehicle_hummer_mexico_destructible" ] = "explosions/vehicle_explosion_hummer";
	hummer_death_fx[ "vehicle_hummer_mexico_opentop" ] = "explosions/vehicle_explosion_hummer_nodoors";
	hummer_death_fx[ "vehicle_hummer_doors_open" ] = "explosions/vehicle_explosion_hummer";

	build_unload_groups( ::Unload_Groups );

	build_deathfx( "fire/firelp_med_pm", "TAG_CAB_FIRE", "fire_metal_medium", undefined, undefined, true, 0 );
	build_deathfx( hummer_death_fx[ model ], "tag_deathfx", "car_explode" );

	build_light( model, "headlight_L", 	"tag_headlight_left", 		"nx/misc/nx_car_headlight_beam_far", 		"running", 	0.0 );
	build_light( model, "headlight_R", 	"tag_headlight_right", 		"nx/misc/nx_car_headlight_beam_far", 		"running", 	0.0 );
	build_light( model, "brakelight_R", "tag_brakelight_right", 	"misc/car_brakelight_btr80", 				"brakes", 	0.0 );
	build_light( model, "brakelight_L", "tag_brakelight_left", 		"misc/car_brakelight_btr80", 				"brakes", 	0.0 );

	build_drive( %humvee_50cal_driving_idle_forward, %humvee_50cal_driving_idle_backward, 10 );
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	anim_func = ::setanims;
	anim_vehicle_func = ::set_vehicle_anims;

	if ( isdefined( model ) && model == "vehicle_hummer_mexico_destructible" )
	{
		anim_func = ::setanims_humvee_dismount;
		anim_vehicle_func = ::set_vehicle_anims_doors_open;
	}
	if ( isdefined( model ) && model == "vehicle_hummer_doors_open" )
	{
		anim_func = ::setanims_humvee_dismount;
		anim_vehicle_func = ::set_vehicle_anims_doors_open;
	}

	if ( isdefined( type ) && issubstr( type, "open" ) )
		anim_func = ::opentop_anims;
			
	build_aianims( anim_func, anim_vehicle_func );
	
	build_compassicon( "automobile", false );

}

#using_animtree( "vehicles" );
init_local()
{
	//maps\_vehicle::lights_on( "running" );
	if ( issubstr( self.vehicletype, "physics" ) )
	{
		anims = [];
		anims[ "idle" ] = %humvee_antennas_idle_movement;
		anims[ "rot_l" ] = %humvee_antenna_L_rotate_360;
		anims[ "rot_r" ] = %humvee_antenna_R_rotate_360;
		thread humvee_antenna_animates( anims );
		
		//thread maps\_debug::drawTagForever( "tag_antenna" );
		//thread maps\_debug::drawTagForever( "tag_antenna2" );
	}
	
	if ( !issubstr( self.model, "opentop" ))
		self hidepart( "tag_blood" );

}


unload_groups()
{
	unload_groups = [];

	group = "passengers";
	unload_groups[ group ] = [];
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;

	group = "rear_driver_side";
	unload_groups[ group ] = [];
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;

	group = "all";
	unload_groups[ group ] = [];
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;

	unload_groups[ "default" ] = unload_groups[ "all" ];

	return unload_groups;
}


#using_animtree( "vehicles" );
set_vehicle_anims( positions )
{
	for ( i = 0;i < positions.size;i++ )

	positions[ 0 ].vehicle_getoutanim = %uaz_driver_exit_into_run_door;
	positions[ 1 ].vehicle_getoutanim = %uaz_rear_driver_exit_into_run_door;
	positions[ 2 ].vehicle_getoutanim = %uaz_passenger_exit_into_run_door;
	positions[ 3 ].vehicle_getoutanim = %uaz_passenger2_exit_into_run_door;

	positions[ 0 ].vehicle_getinanim = %humvee_mount_frontL_door;
	positions[ 1 ].vehicle_getinanim = %humvee_mount_frontR_door;
	positions[ 2 ].vehicle_getinanim = %humvee_mount_backL_door;
	positions[ 3 ].vehicle_getinanim = %humvee_mount_backR_door;

	positions[ 0 ].vehicle_getoutsound = "hummer_door_open";
	positions[ 1 ].vehicle_getoutsound = "hummer_door_open";
	positions[ 2 ].vehicle_getoutsound = "hummer_door_open";
	positions[ 3 ].vehicle_getoutsound = "hummer_door_open";

	positions[ 0 ].vehicle_getinsound = "hummer_door_close";
	positions[ 1 ].vehicle_getinsound = "hummer_door_close";
	positions[ 2 ].vehicle_getinsound = "hummer_door_close";
	positions[ 3 ].vehicle_getinsound = "hummer_door_close";

	return positions;
}


set_vehicle_anims_doors_open( positions )
{
	for ( i = 0;i < positions.size;i++ )

	positions[ 0 ].vehicle_getoutanim = %suburban_dismount_frontL_door;
	positions[ 1 ].vehicle_getoutanim = %humvee_dismount_frontR_door;
	positions[ 2 ].vehicle_getoutanim = %humvee_dismount_backL_door;
	positions[ 3 ].vehicle_getoutanim = %humvee_dismount_backR_door;

	positions[ 0 ].vehicle_getoutsound = "hummer_door_open";
	positions[ 1 ].vehicle_getoutsound = "hummer_door_open";
	positions[ 2 ].vehicle_getoutsound = "hummer_door_open";
	positions[ 3 ].vehicle_getoutsound = "hummer_door_open";


	return positions;
}


#using_animtree( "generic_human" );


opentop_anims()
{
	positions = [];
	for ( i = 0;i < 4;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_passenger";
	positions[ 2 ].sittag = "tag_guy0";
	positions[ 3 ].sittag = "tag_guy1";

	positions[ 0 ].bHasGunWhileRiding = false;

	positions[ 0 ].idle = %humvee_idle_frontL;
	positions[ 1 ].idle = %humvee_idle_frontR;
	positions[ 2 ].idle = %humvee_idle_backL;
	positions[ 3 ].idle = %humvee_idle_backR;

	positions[ 0 ].getout = %humvee_driver_climb_out;
	positions[ 1 ].getout = %humvee_passenger_out_R;
	positions[ 2 ].getout = %humvee_passenger_out_L;
	positions[ 3 ].getout = %humvee_passenger_out_R;

	positions[ 0 ].getin = %humvee_mount_frontL_nodoor;
	positions[ 1 ].getin = %humvee_mount_frontR_nodoor;
	positions[ 2 ].getin = %humvee_mount_backL_nodoor;
	positions[ 3 ].getin = %humvee_mount_backR_nodoor;
	
	return positions;
}

setanims()
{
	positions = [];
	for ( i = 0;i < 4;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_passenger";
	positions[ 2 ].sittag = "tag_guy0";
	positions[ 3 ].sittag = "tag_guy1";

	positions[ 0 ].bHasGunWhileRiding = false;

	positions[ 0 ].idle = %humvee_idle_frontL;
	positions[ 1 ].idle = %humvee_idle_frontR;
	positions[ 2 ].idle = %humvee_idle_backL;
	positions[ 3 ].idle = %humvee_idle_backR;

	positions[ 0 ].getout = %humvee_driver_climb_out;
	positions[ 1 ].getout = %humvee_passenger_out_R;
	positions[ 2 ].getout = %humvee_passenger_out_L;
	positions[ 3 ].getout = %humvee_passenger_out_R;

	positions[ 0 ].getin = %humvee_mount_frontL;
	positions[ 1 ].getin = %humvee_mount_frontR;
	positions[ 2 ].getin = %humvee_mount_backL; 
	positions[ 3 ].getin = %humvee_mount_backR;
	
	return positions;
}

setanims_humvee_dismount()
{
	positions = [];
	for ( i = 0;i < 4;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_passenger";
	positions[ 2 ].sittag = "tag_guy0";
	positions[ 3 ].sittag = "tag_guy1";

	positions[ 0 ].bHasGunWhileRiding = false;

	positions[ 0 ].idle = %humvee_idle_frontL;
	positions[ 1 ].idle = %humvee_idle_frontR;
	positions[ 2 ].idle = %humvee_idle_backL;
	positions[ 3 ].idle = %humvee_idle_backR;

	positions[ 0 ].getout = %humvee_dismount_frontL;
	positions[ 1 ].getout = %humvee_dismount_frontR;
	positions[ 2 ].getout = %humvee_dismount_backL;
	positions[ 3 ].getout = %humvee_dismount_backR;

	
	return positions;
}



/*QUAKED script_vehicle_hummer (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_humvee::main( "vehicle_hummer" );


include,vehicle_hummer
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_hummer,vehicle_standard,all_sp


defaultmdl="vehicle_hummer"
default:"vehicletype" "humvee"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_hummer_nodoors (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_humvee::main( "vehicle_hummer_no_doors" );


include,vehicle_hummer_nodoors
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_hummer,vehicle_standard,all_sp


defaultmdl="vehicle_hummer_no_doors"
default:"vehicletype" "humvee"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_hummer_opentop (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_humvee::main( "vehicle_hummer_opentop" );


include,vehicle_hummer_opentop
sound,vehicle_hummer,vehicle_standard,all_sp


defaultmdl="vehicle_hummer_opentop"
default:"vehicletype" "humvee"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_hummer_viewmodel (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_humvee::main( "vehicle_hummer_viewmodel" );


include,vehicle_hummer_viewmodel
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_hummer,vehicle_standard,all_sp


defaultmdl="vehicle_hummer_viewmodel"
default:"vehicletype" "humvee"
default:"script_team" "allies"
*/


/*QUAKED script_vehicle_hummer_viewmodel_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_humvee::main( "vehicle_hummer_viewmodel", "hummer_physics" );


include,vehicle_hummer_viewmodel
sound,vehicle_hummer,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_hummer_viewmodel"
default:"vehicletype" "hummer_physics"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_hummer_opentop_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_humvee::main( "vehicle_hummer_opentop", "hummer_opentop_physics" );


include,vehicle_hummer_opentop
sound,vehicle_hummer,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_hummer_opentop"
default:"vehicletype" "hummer_opentop_physics"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_hummer_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_humvee::main( "vehicle_hummer", "hummer_physics" );


include,vehicle_hummer
sound,vehicle_hummer,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_hummer"
default:"vehicletype" "hummer_physics"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_nx_hummer_doors_open_US (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_humvee::main( "vehicle_hummer_doors_open", "hummer_physics" );


include,nx_vehicle_hummer_doors_open
sound,vehicle_hummer,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_hummer_doors_open"
default:"vehicletype" "hummer_physics"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_nx_hummer (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_humvee::main( "vehicle_hummer_mexico_destructible", "hummer_physics" );


include,nx_vehicle_hummer_mexico_destructible
sound,vehicle_hummer,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_hummer_mexico_destructible"
default:"vehicletype" "hummer_physics"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_nx_hummer_opentop_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_humvee::main( "vehicle_hummer_mexico_opentop", "hummer_opentop_physics" );


include,vehicle_hummer_opentop
sound,vehicle_hummer,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="vehicle_hummer_mexico_opentop"
default:"vehicletype" "hummer_opentop_physics"
default:"script_team" "axis"
*/

