#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );


main( model, type, buildtread, no_death )
{
	build_template( "nx_osprey", model, type );
	build_localinit( ::init_local );
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	build_drive ( %nx_vh_osprey_movement,undefined, 150 );
	build_aianims( ::setanims, ::set_vehicle_anims );

	if ( IsDefined( buildtread ))
	{
		if ( buildtread == true )
		{
			build_treadfx();
		}
	}
	else
	{
		build_treadfx();
	}
}

init_local()
{
	self.originheightoffset = distance( self gettagorigin( "tag_origin" ), self gettagorigin( "tag_ground" ) );// TODO - FIXME: this is ugly. Derive from distance between tag_origin and tag_base or whatever that tag was.
	self.script_badplace = false;// All helicopters dont need to create bad places
}

#using_animtree( "vehicles" );
set_vehicle_anims( positions )
{ 	
	return positions;
}

#using_animtree( "generic_human" );

setanims()
{
	positions = [];
	for ( i = 0;i < 9;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].idle = %humvee_passenger_idle_R;
	positions[ 1 ].idle = %humvee_passenger_idle_R;

	positions[ 2 ].idle = %humvee_passenger_idle_R;
	positions[ 3 ].idle = %humvee_passenger_idle_R;
	positions[ 4 ].idle = %humvee_passenger_idle_R;
	positions[ 5 ].idle = %humvee_passenger_idle_R;
	positions[ 6 ].idle = %humvee_passenger_idle_R;
	positions[ 7 ].idle = %humvee_passenger_idle_R;
	positions[ 8 ].idle = %humvee_passenger_idle_R;

	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_passenger";
	positions[ 2 ].sittag = "tag_guy0";
	positions[ 3 ].sittag = "tag_guy1";
	positions[ 4 ].sittag = "tag_guy2";
	positions[ 5 ].sittag = "tag_guy3";
	positions[ 6 ].sittag = "tag_guy4";
	positions[ 7 ].sittag = "tag_guy5";
	positions[ 8 ].sittag = "tag_guy6";

	return positions;
}




/*QUAKED script_vehicle_nx_osprey (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_osprey::main( "vehicle_osprey", "nx_osprey" );


include,nx_vehicle_osprey

defaultmdl="vehicle_osprey"
default:"vehicletype" "nx_osprey"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_nx_osprey_vignette (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_osprey::main( "vehicle_osprey", "nx_osprey_vignette", false );


include,nx_vehicle_osprey

defaultmdl="vehicle_osprey"
default:"vehicletype" "nx_osprey_vignette"
default:"script_team" "allies"
*/

