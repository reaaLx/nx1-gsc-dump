#include maps\_ambient;
#include maps\_utility;
#include common_scripts\utility;

main()
{
	// Set the underlying ambient track

	level._ambient_track [ "nx_lunar_crew" ] = "amb_lunar_crew_hub";

	level._ambient_track [ "nx_lunar_get_to_armory" ] = "amb_lunar_press_nohelmet";

	level._ambient_track [ "nx_lunar_cargo_bay" ] = "amb_lunar_press_nohelmet";

	level._ambient_track [ "nx_lunar_armory_depress" ] = "amb_lunar_armory_depress";

	level._ambient_track [ "nx_lunar_exterior_depress" ] = "amb_lunar_exterior_depress";

	level._ambient_track [ "nx_lunar_hydro" ] = "amb_lunar_crew_hub";

	level._ambient_track [ "nx_lunar_rover_amb" ] = "lunar_rover_ambience";

	level._ambient_track [ "nx_lunar_rover_player_amb" ] = "lunar_rover_ambience";

	level._ambient_track [ "nx_lunar_int_nohelmet" ] = "amb_lunar_press_nohelmet";

	event = create_ambient_event( "nx_lunar_rover_player_amb", 1.0, 5.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq_vol( "lunar_pressurized" );
	event add_to_ambient_event( "lunar_rover_amb_events", 0.1 );

	event = create_ambient_event( "nx_lunar_rover_amb", 1.0, 5.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq_vol( "lunar_pressurized" );
	event add_to_ambient_event( "null", 1.0 );

	event = create_ambient_event( "nx_lunar_armory", 1.0, 5.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq_vol( "lunar_pressurized" );
	event add_to_ambient_event( "null", 1.0 );

	event = create_ambient_event( "nx_lunar_hydro", 1.0, 2.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq_vol( "lunar_pressurized" );
	event add_to_ambient_event( "null", 1.0 );
	//event add_to_ambient_event( "lunar_stress_press", 6.0 );
	//event add_to_ambient_event( "lunar_beep_press", 4.0 );
	//event add_to_ambient_event( "lunar_explosions", 10.0 );
	event add_to_ambient_event( "lunar_explosions_shake", 10.0 );
	//event add_to_ambient_event( "lunar_dist_fire_press", 1.0 );

	event = create_ambient_event( "nx_lunar_crew", 1.0, 2.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq_vol( "lunar_pressurized" );
	event add_to_ambient_event( "null", 1.0 );
	//event add_to_ambient_event( "lunar_stress_press", 6.0 );
	//event add_to_ambient_event( "lunar_beep_press", 4.0 );
	event add_to_ambient_event( "lunar_explosions_press", 10.0 );
	event add_to_ambient_event( "lunar_explosions_shake", 10.0 );
	//event add_to_ambient_event( "lunar_dist_fire_press", 1.0 );

	event = create_ambient_event( "nx_lunar_get_to_armory", 0.1, 0.4 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq_vol( "lunar_pressurized" );
	//event add_to_ambient_event( "null", 1.0 );
	event add_to_ambient_event( "lunar_stress_press", 6.0 );
	//event add_to_ambient_event( "lunar_beep_press", 4.0 );
	event add_to_ambient_event( "lunar_explosions_press", 10.0 );
	event add_to_ambient_event( "lunar_explosions_press_close", 8.0 );
	event add_to_ambient_event( "lunar_explosions_shake", 6.0 );
	event add_to_ambient_event( "lunar_dist_fire_press", 1.0 );

	event = create_ambient_event( "nx_lunar_cargo_bay", 0.1, 0.4 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq_vol( "lunar_pressurized" );
	//event add_to_ambient_event( "null", 1.0 );
	//event add_to_ambient_event( "lunar_stress_press", 6.0 );
	//event add_to_ambient_event( "lunar_beep_press", 4.0 );
	event add_to_ambient_event( "lunar_explosions_press", 10.0 );
	event add_to_ambient_event( "lunar_explosions_press_close", 8.0 );
	event add_to_ambient_event( "lunar_explosions_shake", 6.0 );
	//event add_to_ambient_event( "lunar_dist_fire_press", 1.0 );

	event = create_ambient_event( "nx_lunar_armory_depress", 1.0, 3.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq_vol( "lunar_depressurized" );
	event add_to_ambient_event( "null", 1.0 );
	event add_to_ambient_event( "lunar_stress_depress", 6.0 );
	//event add_to_ambient_event( "lunar_beep_press", 4.0 );
	//event add_to_ambient_event( "lunar_explosions_press", 10.0 );
	//event add_to_ambient_event( "lunar_explosions_press_close", 8.0 );
	//event add_to_ambient_event( "lunar_explosions_shake", 6.0 );
	//event add_to_ambient_event( "lunar_dist_fire_press", 1.0 );

	event = create_ambient_event( "nx_lunar_exterior_depress", 1.0, 3.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq_vol( "lunar_depressurized" );
	event add_to_ambient_event( "null", 1.0 );
	//event add_to_ambient_event( "lunar_explosions", 1.0 );

	event = create_ambient_event( "nx_lunar_int_nohelmet", 5.0, 10.0 ); // Trackname, min and max delay between ambient events
	event map_to_reverb_eq_vol( "lunar_depressurized" );
	event add_to_ambient_event( "null", 1.0 );
	//event add_to_ambient_event( "lunar_stress", 1.0 );
	//event add_to_ambient_event( "lunar_explosions", 10.0 );
	//event add_to_ambient_event( "lunar_dist_fire", 1.0 );
        
        wait 0.1;

	//thread maps\_utility::set_ambient( "nx_lunar_int" );
}

lunar_alarm_occ_blend()
{
	wait 1.0;
	alarm_occ = "emt_lunar_alarm_occ";
	alarm_full = "emt_lunar_alarm_full";

	occblend = spawn( "sound_blend", ( 4657, 175, -1656 ) );

	fullblend = spawn( "sound_blend", ( 4657, 175, -1656) );

	occblend thread mix_up( alarm_occ );
	occblend thread mix_down( alarm_full );
	
	occblend SetSoundBlend( alarm_occ, alarm_occ + "_off", 0 );
	fullblend SetSoundBlend( alarm_full + "_off", alarm_full, 1 );

	flag_wait( "sfx_first_airlock_open" );

	occblend thread mix_down( alarm_occ );
	fullblend thread mix_up( alarm_full );
	
}
