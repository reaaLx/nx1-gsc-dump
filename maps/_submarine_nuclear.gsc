#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );

main( model, type )
{
	build_template( "submarine_nuclear", model, type );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_submarine_nuclear" );
	build_compassicon( "camera", false );
	build_life( 999, 500, 1500 );
	build_team( "allies" );
}

init_local()
{
}



/*QUAKED script_vehicle_submarine_nuclear (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_submarine_nuclear::main( "vehicle_submarine_nuclear" );


include,vehicle_submarine_nuclear_submarine_nuclear


defaultmdl="vehicle_submarine_nuclear"
default:"vehicletype" "submarine_nuclear"
default:"script_team" "allies"
*/
