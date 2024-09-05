#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );


/*QUAKED script_vehicle_nx_c102 (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

maps\_nx_c102::main( "nx_vehicle_c102" );

include,nx_vehicle_c102

defaultmdl="nx_vehicle_c102"
default:"vehicletype" "nx_c102"
default:"script_team" "allies"
*/

main( model, type )
{
	build_template( "nx_c102", model, type );
	build_localinit( ::init_local );
	build_life( 999, 500, 1500 );
	build_team( "allies" );

	build_light( model, "wingtip_green", 	"tag_fx_wing_l_green_steady", 	"misc/aircraft_light_wingtip_green", 	"running", 		0.0 );
	build_light( model, "wingtip_red", 		"tag_fx_wing_r_red_steady", 	"misc/aircraft_light_wingtip_red", 		"running", 		0.05 );
	build_light( model, "tail_red", 		"tag_fx_tail_white_blinking", 	"misc/aircraft_light_white_blink", 		"running", 		0.05);
	build_light( model, "white_blink", 		"tag_fx_belly_red_doubleblink", "misc/aircraft_light_red_blink", 		"running", 		1.0 );

}

init_local()
{
	maps\_vehicle::lights_on( "running" );
}

#using_animtree( "vehicles" );
set_vehicle_anims()
{
}

#using_animtree( "generic_human" );
setanims()
{
}
