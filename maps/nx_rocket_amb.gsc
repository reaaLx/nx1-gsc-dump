#include maps\_ambient;
#include maps\_utility;
#include common_scripts\utility;

main()
{
	// Set the underlying ambient track

	level._ambient_track [ "nx_rocket_ext" ] = "amb_rocket_ext";
	level._ambient_track [ "nx_rocket_heli_intro" ] = "amb_rocket_heli_intro";
	level._ambient_track [ "nx_rocket_heli_intro_silent" ] = "amb_rocket_heli_intro_silent";
	level._ambient_track [ "nx_rocket_intro_new" ] = "amb_rocket_heli_intro_new";
	level._ambient_track [ "nx_rocket_turret_int" ] = "amb_rocket_turret_int";

	event = create_ambient_event( "nx_rocket_ext", 1.0, 3.0 ); // Trackname, min and max delay between ambient events
	event add_to_ambient_event( "null", 1.0 );
        
	thread maps\_utility::set_ambient( "nx_rocket_heli_intro" );
}
