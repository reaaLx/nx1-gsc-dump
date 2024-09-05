#include maps\_ambient;
#include maps\_utility;
#include common_scripts\utility;

main()
{
	// Set the underlying ambient track

	level._ambient_track [ "amb_border_ext" ] = "amb_border_ext";
	level._ambient_track [ "amb_border_ext_intro" ] = "amb_border_ext_intro";
	level._ambient_track [ "amb_border_int" ] = "amb_border_int";

	event = create_ambient_event( "amb_border_ext", 3.0, 6.0 ); // Trackname, min and max delay between ambient events
	event add_to_ambient_event( "null", 1.0 );
	event add_to_ambient_event( "elm_border_metal_squeak", 4.0 );
	event add_to_ambient_event( "elm_border_wind_gust", 4.0 );
	event add_to_ambient_event( "elm_border_sand_wind", 4.0 );

	event = create_ambient_event( "amb_border_ext_intro", 3.0, 6.0 ); // Trackname, min and max delay between ambient events
	event add_to_ambient_event( "null", 1.0 );
	//event add_to_ambient_event( "elm_border_metal_squeak", 4.0 );
	//event add_to_ambient_event( "elm_border_wind_gust", 4.0 );
	//event add_to_ambient_event( "elm_border_sand_wind", 4.0 );

	event = create_ambient_event( "amb_border_int", 3.0, 6.0 ); // Trackname, min and max delay between ambient events
	event add_to_ambient_event( "null", 1.0 );
	event add_to_ambient_event( "elm_border_ceiling_cracks", 5.0 );
	event add_to_ambient_event( "elm_border_int_debris", 3.0 );
	event add_to_ambient_event( "elm_border_wood_creak", 5.0 );


	thread maps\_utility::set_ambient( "amb_border_ext_intro" );
}