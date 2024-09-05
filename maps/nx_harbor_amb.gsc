#include maps\_ambient;

main()
{
	// Set the underlying ambient track
	level._ambient_track [ "nx_harbor_train_int" ] = "ambient_harbor_train_int";
	level._ambient_track [ "nx_harbor_train_tunnel_int" ] = "ambient_harbor_train_tunnel_int";

	event = create_ambient_event( "nx_harbor_train_int", 2.0, 5.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "nx_harbor_train_int", "null", 1.0);
	ambientEvent( "nx_harbor_train_int", "elm_subway_air_hiss", 1.0);
	ambientEvent( "nx_harbor_train_int", "elm_subway_clank", 3.0);
	ambientEvent( "nx_harbor_train_int", "elm_subway_break_squeak", 6.0);

	event = create_ambient_event( "nx_harbor_train_tunnel_int", 3.0, 8.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "nx_harbor_train_tunnel_int", "null", 1.0);

	thread maps\_utility::set_ambient( "nx_harbor_train_int" );
}
