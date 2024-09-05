#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );

main( model, type )
{
	build_template( "nx_lapd", model, type );
	build_localinit( ::init_local );
	build_drive( %nx_vh_president_suburban_movement, %nx_vh_president_suburban_movement_backwards, 10 );
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_treadfx();
	build_life( 999, 500, 1500 );
        
    //special for lapd/////
	level._effect[ "police_light_red" ]			= loadfx( "nx/misc/nx_copcar_light_red_loop_01" );
    level._effect[ "police_light_blue" ]		= loadfx( "nx/misc/nx_copcar_light_blue_loop_01" );
	////////////////////////

        build_light( model, "coplight_blue_01",  "tag_fx_light_01", "nx/misc/nx_copcar_light_blue_loop_01",      "woo_woo_1",     0.0 );
        build_light( model, "coplight_red_02",  "tag_fx_light_02", "nx/misc/nx_copcar_light_red_loop_01",        "woo_woo_1",     0.1 );
        build_light( model, "coplight_blue_03",  "tag_fx_light_03", "nx/misc/nx_copcar_light_blue_loop_01",      "woo_woo_1",     0.2 );
        build_light( model, "coplight_red_04",  "tag_fx_light_04", "nx/misc/nx_copcar_light_red_loop_01",        "woo_woo_1",     0.3 );
        build_light( model, "coplight_blue_05",  "tag_fx_light_05", "nx/misc/nx_copcar_light_blue_loop_01",      "woo_woo_1",     0.4 );
        build_light( model, "coplight_red_06",  "tag_fx_light_06", "nx/misc/nx_copcar_light_red_loop_01",        "woo_woo_1",     0.5 );
        build_light( model, "coplight_blue_07",  "tag_fx_light_07", "nx/misc/nx_copcar_light_blue_loop_01",      "woo_woo_1",     0.6 );

        build_light( model, "coplight_blue_08",  "tag_fx_light_08", "nx/misc/nx_copcar_light_red_loop_01",       "woo_woo_1",     0.0 );
        build_light( model, "coplight_red_09",  "tag_fx_light_09", "nx/misc/nx_copcar_light_blue_loop_01",       "woo_woo_1",     0.1 );
        build_light( model, "coplight_blue_10",  "tag_fx_light_10", "nx/misc/nx_copcar_light_red_loop_01",       "woo_woo_1",     0.1 );
        build_light( model, "coplight_red_11",  "tag_fx_light_11", "nx/misc/nx_copcar_light_blue_loop_01",       "woo_woo_1",     0.0 );

		build_light( model, "coplight_headlight_l",  "TAG_LIGHT_LEFT_FRONT", "nx/lights/nx_exfil_car_headlight_01",       "headlight_l",     0.1 );
        build_light( model, "coplight_headlight_r",  "TAG_LIGHT_RIGHT_FRONT", "nx/lights/nx_exfil_car_headlight_01",       "headlight_r",     0.0 );
        
}

init_local()
{
        //maps\_vehicle::lights_on( "woo_woo_1" );
		//maps\_vehicle::lights_on( "headlight_l" );
}

set_vehicle_anims( positions )
{
		positions[ 0 ].vehicle_getoutanim = %nx_vh_lapd_driver_door_getout;
		positions[ 1 ].vehicle_getoutanim = %nx_vh_lapd_passenger_door_getout;

		positions[ 0 ].vehicle_getoutanim_clear = false;
		positions[ 1 ].vehicle_getoutanim_clear = false;

		return positions;
}

#using_animtree( "generic_human" );

setanims()
{
	positions = [];
	
	for ( i = 0;i < 2;i++ )
		positions[ i ] = spawnstruct();
	positions[ 0 ].sittag = "tag_driver";
	positions[ 0 ].idle = %nx_tp_lapd_driver_idle;
	positions[ 0 ].death = %nx_tp_lapd_driver_idle;
	
	positions[ 1 ].sittag = "tag_passenger";
	positions[ 1 ].idle = %nx_tp_lapd_passenger_idle;
	positions[ 1 ].death = %nx_tp_lapd_passenger_idle;
	
	positions[ 0 ].getout = %nx_tp_lapd_driver_getout;
	positions[ 1 ].getout = %nx_tp_lapd_passenger_getout;
	
	return positions;
}


/*QUAKED script_vehicle_nx_lapd (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_lapd::main("nx_vehicle_lapd");


include,nx_vehicle_lapd

defaultmdl="nx_vehicle_lapd"
default:"vehicletype" "nx_lapd"
default:"script_team" "allies"
*/

