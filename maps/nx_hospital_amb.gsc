#include maps\_ambient;
#include maps\_utility;
#include common_scripts\utility;

main()
{
	// Set the underlying ambient track

	level._ambient_track [ "nx_hospital_int" ] = "amb_hospital_int";
	level._ambient_track [ "nx_hospital_int_deep" ] = "amb_hospital_int_deep";
	level._ambient_track [ "nx_hospital_ext" ] = "amb_hospital_ext";

	event = create_ambient_event( "nx_hospital_int", 1.0, 3.0 ); // Trackname, min and max delay between ambient events
	event add_to_ambient_event( "null", 1.0 );

	event = create_ambient_event( "nx_hospital_int_deep", 1.0, 3.0 ); // Trackname, min and max delay between ambient events
	event add_to_ambient_event( "null", 1.0 );

	event = create_ambient_event( "nx_hospital_ext", 1.0, 2.0 ); // Trackname, min and max delay between ambient events
	event add_to_ambient_event( "elm_windgust1", 3.0 );
	event add_to_ambient_event( "elm_windgust2", 3.0 );
	event add_to_ambient_event( "elm_windgust3", 3.0 );
	event add_to_ambient_event( "elm_windgust4", 3.0 );
	event add_to_ambient_event( "elm_explosions_dist", 3.0 );
	event add_to_ambient_event( "elm_jet_flyover_dist", 10.0 );
	event add_to_ambient_event( "elm_gunfire_50cal_dist", 1.0 );
	event add_to_ambient_event( "elm_gunfire_ak47_dist", 1.0 );
	event add_to_ambient_event( "elm_gunfire_miniuzi_dist", 1.0 );
	event add_to_ambient_event( "elm_gunfire_m16_dist", 1.0 );
	event add_to_ambient_event( "elm_gunfire_m240_dist", 1.0 );
	event add_to_ambient_event( "elm_gunfire_mp5_dist", 1.0 );
        
	thread maps\_utility::set_ambient( "nx_hospital_int" );
}
