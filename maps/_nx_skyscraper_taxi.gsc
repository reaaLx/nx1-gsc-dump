/*QUAKED script_vehicle_nx_skyscraper_taxi (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER
maps\_nx_skyscraper_taxi::main("nx_vehicle_skyscraper_taxi");

include,nx_vehicle_skyscraper_taxi

defaultmdl="nx_vehicle_skyscraper_taxi"
default:"vehicletype" "nx_skyscraper_taxi"
default:"script_team" "allies"
*/

#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );

main( model, type )
{
	build_template( "nx_skyscraper_taxi", model, type );
	build_localinit( ::init_local );
	build_drive( %nx_vh_president_suburban_movement, %nx_vh_president_suburban_movement_backwards, 10 );
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_unload_groups( ::Unload_Groups );
}

init_local()
{

}

#using_animtree( "vehicles" );
set_vehicle_anims( positions )
{

	positions[ 0 ].vehicle_getoutanim = %suburban_dismount_frontL_door;
	positions[ 1 ].vehicle_getoutanim = %suburban_dismount_frontR_door;
	positions[ 2 ].vehicle_getoutanim = %suburban_dismount_backL_door;
	positions[ 3 ].vehicle_getoutanim = %suburban_dismount_backR_door;

	return positions;
}


#using_animtree( "generic_human" );
setanims()
{
	positions = [];
	for ( i = 0;i < 4;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_passenger";
	positions[ 2 ].sittag = "tag_guy1";
	positions[ 3 ].sittag = "tag_guy2";

	positions[ 0 ].idle = %suburban_idle_frontL;
	positions[ 1 ].idle = %suburban_idle_frontR;
	positions[ 2 ].idle = %suburban_idle_backL;
	positions[ 3 ].idle = %suburban_idle_backR;

	positions[ 0 ].getout = %suburban_dismount_frontL;
	positions[ 1 ].getout = %suburban_dismount_frontR;
	positions[ 2 ].getout = %suburban_dismount_backL;
	positions[ 3 ].getout = %suburban_dismount_backR;

	// old get in anims
	positions[ 0 ].getin = %humvee_driver_climb_in;
	positions[ 1 ].getin = %humvee_passenger_in_L;
	positions[ 2 ].getin = %humvee_passenger_in_R;
	positions[ 3 ].getin = %humvee_passenger_in_R;

	return positions;
}

unload_groups()
{
	unload_groups = [];
	unload_groups[ "passengers" ] = [];
	unload_groups[ "all" ] = [];

	group = "passengers";
	unload_groups[ group ][ unload_groups[ "passengers" ].size ] = 1;
	unload_groups[ group ][ unload_groups[ "passengers" ].size ] = 2;
	unload_groups[ group ][ unload_groups[ "passengers" ].size ] = 3;

	group = "all";
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;

	unload_groups[ "default" ] = unload_groups[ "all" ];

	return unload_groups;
}

