//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  FX Support													**
//                                                                          **
//    Created: DATE - CREATOR												**
//                                                                          **
//****************************************************************************

#include common_scripts\utility;

main()
{
	// Ambient
	level._effect[ "amb_smoke_blend" ]												= loadfx( "smoke/amb_smoke_blend" );
	level._effect[ "firelp_small_dl" ]												= loadfx( "fire/firelp_small_dl" );
	level._effect[ "nx_ash_ceiling_100_mp" ]										= loadfx( "nx/misc/nx_ash_ceiling_100_mp" );
	level._effect[ "nx_dust_mote_80" ]												= loadfx( "nx/dust/nx_dust_mote_80" );
	level._effect[ "nx_dust_spiral_runner_mp" ]										= loadfx( "nx/dust/nx_dust_spiral_runner_mp" );
	level._effect[ "nx_dust_wind_canyon_mp" ]										= loadfx( "nx/dust/nx_dust_wind_canyon_mp" );
	level._effect[ "nx_godray_150_soft" ]											= loadfx( "nx/misc/nx_godray_150_soft" );
	level._effect[ "nx_godray_225_soft" ]											= loadfx( "nx/misc/nx_godray_225_soft" );
	level._effect[ "nx_godray_75_soft" ]											= loadfx( "nx/misc/nx_godray_75_soft" );
	level._effect[ "nx_hawks_mp" ]													= loadfx( "nx/misc/nx_hawks_mp" );
	level._effect[ "nx_sand_mp" ]													= loadfx( "nx/dust/nx_sand_mp" );
	level._effect[ "nx_smoke_trashfire_mp" ]										= loadfx( "nx/smoke/nx_smoke_trashfire_mp" );
	level._effect[ "nx_smoke_trashfire_small" ]										= loadfx( "nx/smoke/nx_smoke_trashfire_small" );
	level._effect[ "nx_trash_runner_256" ]											= loadfx( "nx/misc/nx_trash_runner_256" );
	level._effect[ "nx_fire_barrel" ]												= loadfx( "nx/fire/nx_fire_barrel" );

	level._effect[ "nx_fire_wall_flat_01" ]											= loadfx( "nx/fire/nx_fire_wall_flat_01" );
	level._effect[ "nx_fire_wall_flat_02" ]											= loadfx( "nx/fire/nx_fire_wall_flat_02" );
	level._effect[ "nx_fire_tree_small_01_short" ]									= loadfx( "nx/fire/nx_fire_tree_small_01_short" );
	level._effect[ "nx_fire_tree_small_01" ]										= loadfx( "nx/fire/nx_fire_tree_small_01" );
	level._effect[ "nx_fire_tree_medium_01" ]										= loadfx( "nx/fire/nx_fire_tree_medium_01" );
	level._effect[ "nx_fire_wall_small_01_short" ]									= loadfx( "nx/fire/nx_fire_wall_small_01_short" );
    level._effect[ "nx_blast_mark_small" ]											= loadfx( "nx/misc/nx_blast_mark_small" );
    level._effect[ "nx_blast_mark_small_filler" ]									= loadfx( "nx/misc/nx_blast_mark_small_filler" );


	if ( getdvar( "clientSideEffects" ) != "1" )
	{
		maps\createfx\mp_nx_pitstop_fx::main();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

fx_mack_truck_explosion()
{
	level._effect[ "nx_fire_wall_small_01_short" ]						= loadfx( "nx/fire/nx_fire_wall_small_01_short" );
    level._effect[ "nx_blast_mark_small" ]								= loadfx( "nx/misc/nx_blast_mark_small" );
    level._effect[ "nx_blast_mark_small_filler" ]						= loadfx( "nx/misc/nx_blast_mark_small_filler" );
	level._effect[ "nx_fire_wall_flat_01" ]								= loadfx( "nx/fire/nx_fire_wall_flat_01" );
	level._effect[ "nx_fire_tree_small_01_short" ]						= loadfx( "nx/fire/nx_fire_tree_small_01_short" );
	level._effect[ "nx_fire_tree_small_01" ]							= loadfx( "nx/fire/nx_fire_tree_small_01" );

	ent = createExploder( "nx_blast_mark_small" );
	ent.v[ "origin" ] = ( 305.547, -359.429, 97.7903 );
	ent.v[ "angles" ] = ( 0, 28, 0 );
	ent.v[ "fxid" ] = "nx_blast_mark_small";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small_filler" );
	ent.v[ "origin" ] = ( 287.684, -316.018, 98.3358 );
	ent.v[ "angles" ] = ( 0, 28, 0 );
	ent.v[ "fxid" ] = "nx_blast_mark_small_filler";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small_filler" );
	ent.v[ "origin" ] = ( 349.278, -226.693, 100.441 );
	ent.v[ "angles" ] = ( 0, 300, 0 );
	ent.v[ "fxid" ] = "nx_blast_mark_small_filler";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small_filler" );
	ent.v[ "origin" ] = ( 425.565, -179.629, 101.692 );
	ent.v[ "angles" ] = ( 0, 302, 0 );
	ent.v[ "fxid" ] = "nx_blast_mark_small_filler";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small_filler" );
	ent.v[ "origin" ] = ( 505.658, -134.716, 101.179 );
	ent.v[ "angles" ] = ( 0, 298, 0 );
	ent.v[ "fxid" ] = "nx_blast_mark_small_filler";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small" );
	ent.v[ "origin" ] = ( 285.562, -335.739, 28.1288 );
	ent.v[ "angles" ] = ( 0, 28, 0 );
	ent.v[ "fxid" ] = "nx_blast_mark_small";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_fire_tree_small_01_short" );
	ent.v[ "origin" ] = ( 1086.33, 226.781, 123.934 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "nx_fire_tree_small_01_short";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_fire_tree_small_01_short" );
	ent.v[ "origin" ] = ( 868.093, 233.505, 82.3977 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "nx_fire_tree_small_01_short";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "firelp_small_dl" );
	ent.v[ "origin" ] = ( 1106.04, 201.239, -14.7342 );
	ent.v[ "angles" ] = ( 270, 355.914, 86.0856 );
	ent.v[ "fxid" ] = "firelp_small_dl";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_fire_wall_small_01_short" );
	ent.v[ "origin" ] = ( 956.246, -91.1313, -2.18124 );
	ent.v[ "angles" ] = ( 270, 0, -32 );
	ent.v[ "fxid" ] = "nx_fire_wall_small_01_short";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "firelp_small_dl" );
	ent.v[ "origin" ] = ( 482.131, -481.392, -53.729 );
	ent.v[ "angles" ] = ( 270, 355.914, 86.0856 );
	ent.v[ "fxid" ] = "firelp_small_dl";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_fire_tree_small_01" );
	ent.v[ "origin" ] = ( 479.634, -121.08, -69.149 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "nx_fire_tree_small_01";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_fire_tree_small_01" );
	ent.v[ "origin" ] = ( 391.465, 52.2238, -58.778 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "nx_fire_tree_small_01";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_fire_wall_flat_01" );
	ent.v[ "origin" ] = ( 151.298, -90.5329, -10.6418 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "nx_fire_wall_flat_01";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_fire_wall_flat_01" );
	ent.v[ "origin" ] = ( 223.403, -247.527, -6.41518 );
	ent.v[ "angles" ] = ( 270, 0, 0 );
	ent.v[ "fxid" ] = "nx_fire_wall_flat_01";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_fire_wall_small_01_short" );
	ent.v[ "origin" ] = ( 1037.42, 233.124, -38.0359 );
	ent.v[ "angles" ] = ( 270, 0, -26 );
	ent.v[ "fxid" ] = "nx_fire_wall_small_01_short";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small_filler" );
	ent.v[ "origin" ] = ( 527.172, -49.4645, 98.77 );
	ent.v[ "angles" ] = ( 0.76693, 29.8873, 1.36083 );
	ent.v[ "fxid" ] = "nx_blast_mark_small_filler";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small" );
	ent.v[ "origin" ] = ( 503.99, -10.1409, 97.5559 );
	ent.v[ "angles" ] = ( 0.76693, 29.8873, 1.36083 );
	ent.v[ "fxid" ] = "nx_blast_mark_small";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small_filler" );
	ent.v[ "origin" ] = ( 485.145, 24.0679, 99.1998 );
	ent.v[ "angles" ] = ( 0.76693, 29.8873, 1.36083 );
	ent.v[ "fxid" ] = "nx_blast_mark_small_filler";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small" );
	ent.v[ "origin" ] = ( 482.199, 30.3277, 100.108 );
	ent.v[ "angles" ] = ( 0.76693, 29.8873, 1.36083 );
	ent.v[ "fxid" ] = "nx_blast_mark_small";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small_filler" );
	ent.v[ "origin" ] = ( 394.377, 55.0714, 99.8742 );
	ent.v[ "angles" ] = ( 358.667, 117.868, 0.814161 );
	ent.v[ "fxid" ] = "nx_blast_mark_small_filler";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small_filler" );
	ent.v[ "origin" ] = ( 338.677, 24.7442, 100.771 );
	ent.v[ "angles" ] = ( 358.667, 117.868, 0.814161 );
	ent.v[ "fxid" ] = "nx_blast_mark_small_filler";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small_filler" );
	ent.v[ "origin" ] = ( 277.14, -8.54866, 99.0849 );
	ent.v[ "angles" ] = ( 358.667, 117.868, 0.814161 );
	ent.v[ "fxid" ] = "nx_blast_mark_small_filler";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small" );
	ent.v[ "origin" ] = ( 231.614, -35.3379, 101.524 );
	ent.v[ "angles" ] = ( 358.667, 117.868, 0.814161 );
	ent.v[ "fxid" ] = "nx_blast_mark_small";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small" );
	ent.v[ "origin" ] = ( 103.116, 1.30407, 100.491 );
	ent.v[ "angles" ] = ( 0.76693, 29.8873, 1.36083 );
	ent.v[ "fxid" ] = "nx_blast_mark_small";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small_filler" );
	ent.v[ "origin" ] = ( 85.0573, 37.571, 101.993 );
	ent.v[ "angles" ] = ( 0.76693, 29.8873, 1.36083 );
	ent.v[ "fxid" ] = "nx_blast_mark_small_filler";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small_filler" );
	ent.v[ "origin" ] = ( 53.7366, 89.3578, 99.8175 );
	ent.v[ "angles" ] = ( 0.76693, 29.8873, 1.36083 );
	ent.v[ "fxid" ] = "nx_blast_mark_small_filler";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small" );
	ent.v[ "origin" ] = ( 40.1042, 117.406, 99.9162 );
	ent.v[ "angles" ] = ( 0.76693, 29.8873, 1.36083 );
	ent.v[ "fxid" ] = "nx_blast_mark_small";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small" );
	ent.v[ "origin" ] = ( 457.725, -38.1464, 66 );
	ent.v[ "angles" ] = ( 83.0141, 241.284, -148.599 );
	ent.v[ "fxid" ] = "nx_blast_mark_small";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small_filler" );
	ent.v[ "origin" ] = ( 416.84, 10.4274, 64 );
	ent.v[ "angles" ] = ( 89.0016, 249.718, -170.173 );
	ent.v[ "fxid" ] = "nx_blast_mark_small_filler";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small_filler" );
	ent.v[ "origin" ] = ( 434.682, -80.0311, 70 );
	ent.v[ "angles" ] = ( 89.0016, 249.718, -170.173 );
	ent.v[ "fxid" ] = "nx_blast_mark_small_filler";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";

	ent = createExploder( "nx_blast_mark_small" );
	ent.v[ "origin" ] = ( 369.586, -8.21131, 66 );
	ent.v[ "angles" ] = ( 89.0016, 249.718, -170.173 );
	ent.v[ "fxid" ] = "nx_blast_mark_small";
	ent.v[ "delay" ] = 0;
	ent.v[ "exploder" ] = "fx_truck_explosion";
	
	vehArray = GetEntArray( "destructible_vehicle", "targetname" );

	foreach( ent in vehArray ) {
		if( ent.destructible_type == "vehicle_mack_truck_short_white" )
		{
			ent waittill( "exploded" );
			Exploder( "fx_truck_explosion" );
			Earthquake( .5, 1.0, ent.origin, 5000 );
			break;
		}
	}
}