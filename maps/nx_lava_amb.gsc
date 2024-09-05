#include maps\_ambient;
#include maps\_utility;
#include common_scripts\utility;

main()
{
	// Set the underlying ambient track

	level._ambient_track [ "nx_lunar_exterior_depress" ] = "ambient_null_lava";

	level._ambient_track [ "nx_lava_train_int" ] = "amb_lava_train_int";

	level._ambient_track [ "nx_lava_train_ext" ] = "amb_lava_train_ext";

	level._ambient_track [ "nx_lava_pressurized" ] = "amb_lava_pressurized";

	level._ambient_track [ "nx_lunar_int_nohelmet" ] = "amb_lunar_press_nohelmet";

	event = create_ambient_event( "nx_lunar_exterior_depress", 1.0, 3.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq_vol( "lunar_depressurized" );
	event add_to_ambient_event( "null", 1.0 );
	//event add_to_ambient_event( "lunar_explosions", 1.0 );

	event = create_ambient_event( "nx_lava_train_int", 1.0, 3.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq_vol( "lunar_depressurized" );
	event add_to_ambient_event( "null", 1.0 );
	//event add_to_ambient_event( "lunar_explosions", 1.0 );

	event = create_ambient_event( "nx_lava_train_ext", 1.0, 3.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq_vol( "lunar_depressurized" );
	event add_to_ambient_event( "null", 1.0 );
	//event add_to_ambient_event( "lunar_explosions", 1.0 );

	event = create_ambient_event( "nx_lunar_int_nohelmet", 5.0, 10.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq_vol( "lunar_pressurized" );
	event add_to_ambient_event( "null", 1.0 );
	//event add_to_ambient_event( "lunar_stress", 1.0 );
	//event add_to_ambient_event( "lunar_explosions", 10.0 );
	//event add_to_ambient_event( "lunar_dist_fire", 1.0 );

	event = create_ambient_event( "nx_lava_pressurized", 0.1, 0.4 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq_vol( "lunar_pressurized" );
	event add_to_ambient_event( "null", 1.0 );
	
	// wait 0.1; // TagBM<note>: wait not needed
	
	level._player_helmet_loop = "amb_space_suit_amb";
	thread maps\_utility::set_ambient( "nx_lunar_exterior_depress" );

	level.amb_train_int = spawn( "sound_emitter", ( 49000, 40000, -4132 ) );
	level.amb_train_ext = spawn( "sound_emitter", ( 49000, 40000, -4133 ) );
	level.amb_train_int PlayloopSound( "amb_lava_train_int" );
	level.amb_train_ext PlayloopSound( "amb_lava_train_ext" );
	

}