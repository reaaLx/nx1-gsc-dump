#include maps\_ambient;
#include common_scripts\utility;

main()
{
	// Set the underlying ambient track
	level._ambient_track [ "nx_hithard_ext" ] = "ambient_hithardb_ext";
	level._ambient_track [ "nx_hithard_ext_b" ] = "ambient_hithardb_ext";
	level._ambient_track [ "nx_hithard_basement" ] = "ambient_hithard_basement";

	event = create_ambient_event( "nx_hithard_ext", 4.0, 6.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "nx_hithard_ext", "elm_explosions_dist", 	1.0 );
	ambientEvent( "nx_hithard_ext", "elm_artillery_med", 	1.0 );
	ambientEvent( "nx_hithard_ext", "elm_jet_flyover_dist", 	1.0 );
	ambientEvent( "nx_hithard_ext", "elm_wind_leafy", 	1.0 );
	ambientEvent( "nx_hithard_ext", "elm_gunfire_usassault_med", 1.0 );
	ambientEvent( "nx_hithard_ext", "elm_gunfire_50cal_dist", 1.0 );

	event = create_ambient_event( "nx_hithard_ext_b", 3, 6.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "nx_hithard_ext_b", "elm_explosions_dist", 	1.0 );
	ambientEvent( "nx_hithard_ext_b", "elm_artillery_med", 	1.0 );
	ambientEvent( "nx_hithard_ext_b", "elm_jet_flyover_dist", 	1.0 );
	ambientEvent( "nx_hithard_ext_b", "elm_wind_leafy", 	1.0 );
	ambientEvent( "nx_hithard_ext_b", "elm_helicopter_flyover_int_med", 1.0 );
	ambientEvent( "nx_hithard_ext_b", "elm_hhh_sirens", 1.0 );

	event = create_ambient_event( "nx_hithard_basement", 4.0, 6.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq( "nx_hithard_basement" ); // use this eq and reverb (if it exists), for this ambient events
	ambientEvent( "nx_hithard_basement", "null", 	1.0 );
	ambientEvent( "nx_hithard_basement", "hithard_basement_exp", 	1.0 );


	thread maps\_utility::set_ambient( "nx_hithard_basement" );
}

ext_door_open()
{
	wait 2.1;
	soundorg = Spawn( "sound_emitter", ( 19883, 18110, -132 ) );
	soundorg PlaySound( "hithard_ext_door" );
	thread maps\_ambient::use_eq_settings( "nx_hithard_basement_open", level._eq_main_track );
	flag_wait( "magicgrenade_teargas_hall_exit" );
}

bomber_pass_sfx()
{
	soundorg = Spawn( "sound_emitter", ( 20106, 18652, 1000 ) );
	wait 2;
	soundorg PlaySound( "elm_hypersonic_bombers" );
	soundorg moveto( ( 19875, 23034, 1500 ), 1.5 );
	wait 6;
	soundorg Delete();

}
