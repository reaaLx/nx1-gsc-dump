#include maps\_ambient;

main()
{
	// Set the underlying ambient track
	level._ambient_track [ "nx_hithard_ext" ] = "ambient_hithard_ext";
	level._ambient_track [ "nx_hithard_ext2" ] = "ambient_hithard_ext2";
	level._ambient_track [ "nx_hithard_vicepres" ] = "ambient_hithard_vicepres";
	level._ambient_track [ "nx_hithard_stairs" ] = "ambient_hithard_stairs";
	level._ambient_track [ "nx_hithard_no_ugv" ] = "ambient_hithard_stairs";
	level._ambient_track [ "nx_hithard_osp" ] = "ambient_hithard_osprey";
	level._ambient_track [ "nx_hithard_osp_open" ] = "ambient_hithard_osprey_open";
	level._ambient_track [ "nx_hithard_chute" ] = "ambient_hithard_chute";


	event = create_ambient_event( "nx_hithard_chute", 4.0, 8.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "nx_hithard_chute", "elm_wind_buffet", 	1.0 );
	ambientEvent( "nx_hithard_chute", "elm_explosions_dist", 	1.0 );
	ambientEvent( "nx_hithard_chute", "elm_gunfire_50cal_dist", 	1.0 );
	ambientEvent( "nx_hithard_chute", "elm_gunfire_miniuzi_dist", 	1.0 );
	ambientEvent( "nx_hithard_chute", "elm_gunfire_m16_dist", 	1.0 );
	ambientEvent( "nx_hithard_chute", "elm_gunfire_m240_dist", 	1.0 );
	ambientEvent( "nx_hithard_chute", "elm_gunfire_mp5_dist", 	1.0 );

	
	event = create_ambient_event( "nx_hithard_osp", 3.0, 8.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "nx_hithard_osp", "null", 1.0);

	event = create_ambient_event( "nx_hithard_vicepres", 3.0, 8.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "nx_hithard_vicepres", "null", 1.0);

	event = create_ambient_event( "nx_hithard_stairs", 3.0, 8.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "nx_hithard_stairs", "null", 1.0);
	
	event = create_ambient_event( "nx_hithard_no_ugv", 3.0, 8.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "nx_hithard_no_ugv", "null", 1.0);

	event = create_ambient_event( "nx_hithard_osp_open", 3.0, 8.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "nx_hithard_osp_open", "null", 1.0);

	event = create_ambient_event( "nx_hithard_ext", 4.0, 9.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "nx_hithard_ext", "elm_hypersonic_bombers", 0.7);
	//ambientEvent( "nx_hithard_ext", "elm_hh_debris", 1.0);
	//ambientEvent( "nx_hithard_ext", "elm_explosions_dist", 	1.0 );
	//ambientEvent( "nx_hithard_ext", "elm_gunfire_50cal_dist", 	1.0 );
	//ambientEvent( "nx_hithard_ext", "elm_gunfire_miniuzi_dist", 	1.0 );
	//ambientEvent( "nx_hithard_ext", "elm_gunfire_m16_dist", 	1.0 );
	//ambientEvent( "nx_hithard_ext", "elm_gunfire_m240_dist", 	1.0 );
	//ambientEvent( "nx_hithard_ext", "elm_gunfire_mp5_dist", 	1.0 );

	event = create_ambient_event( "nx_hithard_ext2", 4.0, 9.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "nx_hithard_ext2", "elm_hypersonic_bombers", 0.7);
	//ambientEvent( "nx_hithard_ext", "elm_hh_debris", 1.0);
	ambientEvent( "nx_hithard_ext", "elm_explosions_dist", 	1.0 );
	//ambientEvent( "nx_hithard_ext", "elm_gunfire_50cal_dist", 	1.0 );
	//ambientEvent( "nx_hithard_ext", "elm_gunfire_miniuzi_dist", 	1.0 );
	//ambientEvent( "nx_hithard_ext", "elm_gunfire_m16_dist", 	1.0 );
	//ambientEvent( "nx_hithard_ext", "elm_gunfire_m240_dist", 	1.0 );
	//ambientEvent( "nx_hithard_ext", "elm_gunfire_mp5_dist", 	1.0 );

	thread maps\_utility::set_ambient( "nx_hithard_ext" );
}
