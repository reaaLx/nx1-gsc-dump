#include maps\_ambient;
#include maps\_utility;
#include common_scripts\utility;

main()
{
	// Set the underlying ambient track

	level._ambient_track [ "nx_exfil_amb01" ] = "amb_exfil_01";
	level._ambient_track [ "nx_exfil_amb02" ] = "amb_exfil_02";
	level._ambient_track [ "nx_exfil_amb03" ] = "amb_exfil_03";
	level._ambient_track [ "nx_exfil_amb_alley" ] = "amb_exfil_alley";
	level._ambient_track [ "nx_exfil_amb_building" ] = "amb_exfil_building";

	event = create_ambient_event( "nx_exfil_amb01", 1.0, 3.0 ); // Trackname, min and max delay between ambient events
	event add_to_ambient_event( "null", 1.0 );

	event = create_ambient_event( "nx_exfil_amb02", 1.0, 3.0 ); // Trackname, min and max delay between ambient events
	event add_to_ambient_event( "null", 1.0 );

	event = create_ambient_event( "nx_exfil_amb03", 1.0, 3.0 ); // Trackname, min and max delay between ambient events
	event add_to_ambient_event( "null", 1.0 );

	event = create_ambient_event( "nx_exfil_amb_alley", 1.0, 3.0 ); // Trackname, min and max delay between ambient events
	event add_to_ambient_event( "null", 1.0 );

	event = create_ambient_event( "nx_exfil_amb_building", 1.0, 3.0 ); // Trackname, min and max delay between ambient events
	event add_to_ambient_event( "null", 1.0 );
        
	//thread maps\_utility::set_ambient( "nx_exfil_amb01" );
}
