#include maps\_ambient;

main()
{
	// Set the underlying ambient track
	level._ambient_track [ "amb_skyscraper_city_drive_up_ext" ] = "amb_skyscraper_city_drive_up_ext";
	level._ambient_track [ "amb_skyscraper_city_ext" ] = "amb_skyscraper_city_ext";
	level._ambient_track [ "amb_skyscraper_lobby_int" ] = "amb_skyscraper_lobby_int";
	level._ambient_track [ "amb_skyscraper_robotics_int" ] = "amb_skyscraper_robotics_int";
	level._ambient_track [ "amb_skyscraper_robotics_int_mask" ] = "amb_skyscraper_robotics_int_mask";
	level._ambient_track [ "amb_skyscraper_windy_ext" ] = "amb_skyscraper_windy_ext";
	level._ambient_track [ "amb_skyscraper_office_int" ] = "amb_skyscraper_robotics_int";

	level._ambient_track [ "amb_skyscraper_elevator_int" ] = "ambient_ss_elevator_int";
	level._ambient_track [ "amb_skyscraper_elevator_shaft" ] = "ambient_ss_elevator_shaft";
	level._ambient_track [ "amb_skyscraper_elevator_freight_shaft" ] = "ambient_ss_elevator_freight_shaft";


	event = create_ambient_event( "amb_skyscraper_city_drive_up_ext", 0.1, 5.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "amb_skyscraper_city_drive_up_ext", "null", 1.0);
	//ambientEvent( "amb_skyscraper_city_drive_up_ext", "elm_bicycle_bell", 7.0);
	//ambientEvent( "amb_skyscraper_city_drive_up_ext", "elm_car_drive_by", 4.0);
	//ambientEvent( "amb_skyscraper_city_drive_up_ext", "elm_dist_car_horn", 10.0);
	//ambientEvent( "amb_skyscraper_city_drive_up_ext", "elm_dist_construction", 5.0);

	event = create_ambient_event( "amb_skyscraper_city_ext", 2.0, 5.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "amb_skyscraper_city_ext", "null", 1.0);
	ambientEvent( "amb_skyscraper_city_ext", "elm_bicycle_bell", 4.0);
	ambientEvent( "amb_skyscraper_city_ext", "elm_car_drive_by", 7.0);
	ambientEvent( "amb_skyscraper_city_ext", "elm_dist_car_horn", 10.0);
	ambientEvent( "amb_skyscraper_city_ext", "elm_dist_construction", 5.0);

	event = create_ambient_event( "amb_skyscraper_lobby_int", 2.0, 5.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "amb_skyscraper_lobby_int", "null", 1.0);

	event = create_ambient_event( "amb_skyscraper_robotics_int", 2.0, 5.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "amb_skyscraper_robotics_int", "null", 1.0);

	event = create_ambient_event( "amb_skyscraper_robotics_int_mask", 2.0, 5.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "amb_skyscraper_robotics_int_mask", "null", 1.0);

	event = create_ambient_event( "amb_skyscraper_windy_ext", 2.0, 5.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "amb_skyscraper_windy_ext", "null", 1.0);

	event = create_ambient_event( "amb_skyscraper_office_int", 2.0, 5.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "amb_skyscraper_office_int", "null", 1.0);

	event = create_ambient_event( "amb_skyscraper_elevator_int", 2.0, 5.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "amb_skyscraper_elevator_int", "null", 1.0);

	event = create_ambient_event( "amb_skyscraper_elevator_shaft", 1.0, 4.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "amb_skyscraper_elevator_shaft", "elm_elevator_shaft", 9.0);

	event = create_ambient_event( "amb_skyscraper_elevator_freight_shaft", 1.0, 4.0 ); // Trackname, min and max delay between ambient events
	ambientEvent( "amb_skyscraper_elevator_freight_shaft", "elm_elevator_shaft", 9.0);
	
	thread maps\_utility::set_ambient( "amb_skyscraper_city_drive_up_ext" );
}
