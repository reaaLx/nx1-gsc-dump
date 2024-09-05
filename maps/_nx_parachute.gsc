#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );


main( model, type, no_death )
{
	build_template( "nx_parachute", model, type );
	build_localinit( ::init_local );
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	build_drive ( %nx_vh_hhh_parachute_idle, undefined, 10 );
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_treadfx();
}

init_local()
{
	self.script_badplace = false;// All helicopters dont need to create bad places
}

#using_animtree( "vehicles" );
set_vehicle_anims( positions )
{ 	
	for ( i = 0;i < positions.size;i++ )
		positions[ i ].vehicle_getoutanim = %nx_vh_hhh_parachute_idle;
	return positions;
}

#using_animtree( "generic_human" );

setanims()
{
	positions = [];
	for ( i = 0;i < 1;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].idle = %nx_tp_hhh_parachute_idle;
	positions[ 0 ].sittag = "tag_driver";

	return positions;
}




/*QUAKED script_vehicle_nx_parachute (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_parachute::main( "vehicle_parachute" );


include,nx_vehicle_parachute

defaultmdl="vehicle_parachute"
default:"vehicletype" "nx_parachute"
default:"script_team" "allies"
*/

