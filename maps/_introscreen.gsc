#include common_scripts\utility;
#include maps\_utility;

main()
{
	flag_init( "pullup_weapon" );
	flag_init( "introscreen_complete" );
	flag_init( "safe_for_objectives" );
	flag_init( "introscreen_complete" );
	delayThread( 10, ::flag_set, "safe_for_objectives" );
	level._linefeed_delay = 16;

	PreCacheShader( "black" );
	PreCacheShader( "white" );

	if ( GetDvar( "introscreen" ) == "" )
		SetDvar( "introscreen", "1" );

	//String1 = Title of the level
	//String2 = Place, Country or just Country
	//String3 = Month Day, Year
	//String4 = Optional additional detailed information
	//Pausetime1 = length of pause in seconds after title of level
	//Pausetime2 = length of pause in seconds after Month Day, Year
	//Pausetime3 = length of pause in seconds before the level fades in 

	if ( IsDefined( level._credits_active ) )
		return;

	switch( level._script )
	{
	case "roadkill":
		// "Team Player"
		PreCacheString( &"ROADKILL_LINE_1" );
		// Day 1 - 16:08:[{FAKE_INTRO_SECONDS:32}]
		PreCacheString( &"ROADKILL_LINE_2" );
		// PFC Joseph Allen
		PreCacheString( &"ROADKILL_LINE_3" );
		// 1st Bn., 75th Ranger Regiment
		PreCacheString( &"ROADKILL_LINE_4" );
		// The Red Zone, Afghanistan
		PreCacheString( &"ROADKILL_LINE_5" );
		introscreen_delay();
		break;
	case "airport":
		// "No Russian"
		PreCacheString( &"AIRPORT_LINE1" );
		// Day 3, 08:40:[{FAKE_INTRO_SECONDS:32}]
		PreCacheString( &"AIRPORT_LINE2" );
		// PFC Joseph Allen a.k.a. Alexei Borodin
		PreCacheString( &"AIRPORT_LINE3" );
		// Zakhaev International Airport
		PreCacheString( &"AIRPORT_LINE4" );
		// Moscow, Russia
		PreCacheString( &"AIRPORT_LINE5" );
		introscreen_delay();
		break;
	case "invasion":
		// "Wolverines!"
		PreCacheString( &"INVASION_LINE1" );
		// Day 4 - 17:45:[{FAKE_INTRO_SECONDS:32}]
		PreCacheString( &"INVASION_LINE2" );
		// Pvt. James Ramirez
		PreCacheString( &"INVASION_LINE3" );
		// 1st Bn., 75th Ranger Regiment
		PreCacheString( &"INVASION_LINE4" );
		// Wolverines!""
		// Day 4 - 17:45:[{FAKE_INTRO_SECONDS:32}]
		// Pvt. James Ramirez
		// 1st Bn., 75th Ranger Regiment
		// Northeastern Virginia, U.S.A.
		//introscreen_delay(&"INVASION_LINE1", &"INVASION_LINE2", &"INVASION_LINE3", &"INVASION_LINE4", 2, 2, .5);
		break;
	case "oilrig":
		// "The Only Easy Day...Was Yesterday"
		PreCacheString( &"OILRIG_INTROSCREEN_LINE_1" );
		// Day 5 - 05:47:[{FAKE_INTRO_SECONDS:12}]
		PreCacheString( &"OILRIG_INTROSCREEN_LINE_2" );
		// Sgt. Gary 'Roach' Sanderson
		PreCacheString( &"OILRIG_INTROSCREEN_LINE_3" );
		// Task Force 141
		PreCacheString( &"OILRIG_INTROSCREEN_LINE_4" );
		// Vikhorevka 36 Oil Platform, Russia
		PreCacheString( &"OILRIG_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;
	case "gulag":
		// "The Gulag"
		PreCacheString( &"GULAG_INTROSCREEN_1" );
		// Day 5 - 07:42:[{FAKE_INTRO_SECONDS:17}]
		PreCacheString( &"GULAG_INTROSCREEN_2" );
		// Sgt. Gary 'Roach' Sanderson
		PreCacheString( &"GULAG_INTROSCREEN_3" );
		// Task Force 141
		PreCacheString( &"GULAG_INTROSCREEN_4" );
		// 40 miles east of Petropavlovsk, Russia
		PreCacheString( &"GULAG_INTROSCREEN_5" );
		introscreen_delay();
		break;
	case "dcburning":
		// "Of Their Own Accord"
		PreCacheString( &"DCBURNING_INTROSCREEN_1" );
		// Day 5 - 18:34:[{FAKE_INTRO_SECONDS:33}]
		PreCacheString( &"DCBURNING_INTROSCREEN_2" );
		// Pvt. James Ramirez
		PreCacheString( &"DCBURNING_INTROSCREEN_3" );
		// 1st Bn., 75th Ranger Regiment
		PreCacheString( &"DCBURNING_INTROSCREEN_4" );
		// Washington, D.C., U.S.A.
		PreCacheString( &"DCBURNING_INTROSCREEN_5" );
		introscreen_delay();
		break;
	case "trainer":
		// "S.S.D.D."
		PreCacheString( &"TRAINER_INTROSCREEN_LINE_1" );
		//Day 1 - 15:30:[{FAKE_INTRO_SECONDS:25}]
		PreCacheString( &"TRAINER_INTROSCREEN_LINE_2" );
		// PFC Joseph Allen
		PreCacheString( &"TRAINER_INTROSCREEN_LINE_3" );
		// 1st Bn., 75th Ranger Regiment
		PreCacheString( &"TRAINER_INTROSCREEN_LINE_4" );
		// Fire Base Phoenix, Afghanistan
		PreCacheString( &"TRAINER_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;
	case "nx_jr_testmap":
		// "The Pit"
		PreCacheString( &"NX_JR_TESTMAP_INTROSCREEN_1" );
		// Day 4 - 13:15:[{FAKE_INTRO_SECONDS:25}]
		PreCacheString( &"NX_JR_TESTMAP_INTROSCREEN_2" );
		// Pvt. Richard Dennett
		PreCacheString( &"NX_JR_TESTMAP_INTROSCREEN_3" );
		// Air Base Python, Afghanistan
		PreCacheString( &"NX_JR_TESTMAP_INTROSCREEN_4" );
		introscreen_delay();
		break;
	case "nx_eric_hud_test":
		// "Eric's HUD Test Level"
		PreCacheString( &"NX_ERIC_HUD_TEST_INTROSCREEN_1" );
		// [{FAKE_INTRO_TIME:19:02:09}] hrs
		PreCacheString( &"NX_ERIC_HUD_TEST_INTROSCREEN_2" );
		// Sgt. Joe Programmer
		PreCacheString( &"NX_ERIC_HUD_TEST_INTROSCREEN_3" );
		// Neversoft HQ
		PreCacheString( &"NX_ERIC_HUD_TEST_INTROSCREEN_4" );
		introscreen_delay();
		break;
	case "nx_how_to":
		// these strings haven't been precached yet
		PreCacheString( &"NX_HOW_TO_INTRO_EXAMPLE_0" );
		PreCacheString( &"NX_HOW_TO_INTRO_EXAMPLE_1" );
		PreCacheString( &"NX_HOW_TO_INTRO_EXAMPLE_2" );
		PreCacheString( &"NX_HOW_TO_INTRO_EXAMPLE_3" );
		println( "test 1" );
		introscreen_delay();
		break;
	case "dcemp":
		// "Second Sun"
		PreCacheString( &"DCEMP_INTROSCREEN_1" );
		// Day 5 - 18:57:[{FAKE_INTRO_SECONDS:17}]
		PreCacheString( &"DCEMP_INTROSCREEN_2" );
		// Pvt. James Ramirez
		PreCacheString( &"DCEMP_INTROSCREEN_3" );
		// 75th Ranger Regiment
		PreCacheString( &"DCEMP_INTROSCREEN_4" );
		// Washington, D.C.
		PreCacheString( &"DCEMP_INTROSCREEN_5" );
		introscreen_delay();
		break;
	case "dc_whitehouse":
		// 'Whiskey Hotel'
		PreCacheString( &"DC_WHITEHOUSE_INTROSCREEN_1" );
		// Day 5, 19:31:[{FAKE_INTRO_SECONDS:22}] hrs
		PreCacheString( &"DC_WHITEHOUSE_INTROSCREEN_2" );
		// Pvt. James Ramirez
		PreCacheString( &"DC_WHITEHOUSE_INTROSCREEN_3" );
		// 75th Ranger Regiment
		PreCacheString( &"DC_WHITEHOUSE_INTROSCREEN_4" );
		// Washington, D.C.
		PreCacheString( &"DC_WHITEHOUSE_INTROSCREEN_5" );
		introscreen_delay();
		break;
	case "killhouse":
		// string not found for KILLHOUSE_INTROSCREEN_LINE_1
		PreCacheString( &"KILLHOUSE_INTROSCREEN_LINE_1" );
		// string not found for KILLHOUSE_INTROSCREEN_LINE_2
		PreCacheString( &"KILLHOUSE_INTROSCREEN_LINE_2" );// not used
		// string not found for KILLHOUSE_INTROSCREEN_LINE_3
		PreCacheString( &"KILLHOUSE_INTROSCREEN_LINE_3" );
		// string not found for KILLHOUSE_INTROSCREEN_LINE_4
		PreCacheString( &"KILLHOUSE_INTROSCREEN_LINE_4" );
		// string not found for KILLHOUSE_INTROSCREEN_LINE_5
		PreCacheString( &"KILLHOUSE_INTROSCREEN_LINE_5" );
		// string not found for KILLHOUSE_INTROSCREEN_LINE_1
		// string not found for KILLHOUSE_INTROSCREEN_LINE_3
		// string not found for KILLHOUSE_INTROSCREEN_LINE_4
		// string not found for KILLHOUSE_INTROSCREEN_LINE_5
		introscreen_delay( &"KILLHOUSE_INTROSCREEN_LINE_1", &"KILLHOUSE_INTROSCREEN_LINE_3", &"KILLHOUSE_INTROSCREEN_LINE_4", &"KILLHOUSE_INTROSCREEN_LINE_5" );
		break;
	case "favela":
		// "Takedown"
		PreCacheString( &"FAVELA_INTROSCREEN_LINE_1" );
		// Day 4 - 15:08:[{FAKE_INTRO_SECONDS:16}]
		PreCacheString( &"FAVELA_INTROSCREEN_LINE_2" );
		// Sgt. Gary 'Roach' Sanderson
		PreCacheString( &"FAVELA_INTROSCREEN_LINE_3" );
		// Task Force 141
		PreCacheString( &"FAVELA_INTROSCREEN_LINE_4" );
		// Rio de Janeiro, Brazil
		PreCacheString( &"FAVELA_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;
	case "arcadia":
		// 'Exodus'
		PreCacheString( &"ARCADIA_INTROSCREEN_LINE_1" );
		// Day 04 - 17:36:[{FAKE_INTRO_SECONDS:28}]
		PreCacheString( &"ARCADIA_INTROSCREEN_LINE_2" );
		// Pvt. James Ramirez
		PreCacheString( &"ARCADIA_INTROSCREEN_LINE_3" );
		// 1st Bn., 75th Ranger Regiment
		PreCacheString( &"ARCADIA_INTROSCREEN_LINE_4" );
		// Northeastern Virginia, U.S.A.
		PreCacheString( &"ARCADIA_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;
	case "favela_escape":
		// 'The Hornet's Nest'
		PreCacheString( &"FAVELA_ESCAPE_INTROSCREEN_LINE_1" );
		// Day 4 - 04:19:[{FAKE_INTRO_SECONDS:40}]
		PreCacheString( &"FAVELA_ESCAPE_INTROSCREEN_LINE_2" );
		// Sgt. Gary 'Roach' Sanderson
		PreCacheString( &"FAVELA_ESCAPE_INTROSCREEN_LINE_3" );
		// Task Force 141
		PreCacheString( &"FAVELA_ESCAPE_INTROSCREEN_LINE_4" );
		// Rio de Janeiro, 1700 F.S.L.
		PreCacheString( &"FAVELA_ESCAPE_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;
	case "nx_test_allenf_favela_escape":
		// 'The Hornet's Nest'
		PreCacheString( &"NX_TEST_ALLENF_FAVELA_ESCAPE_INTROSCREEN_LINE_1" );
		// Day 4 - 04:19:[{FAKE_INTRO_SECONDS:40}]
		PreCacheString( &"NX_TEST_ALLENF_FAVELA_ESCAPE_INTROSCREEN_LINE_2" );
		// Sgt. Gary 'Roach' Sanderson
		PreCacheString( &"NX_TEST_ALLENF_FAVELA_ESCAPE_INTROSCREEN_LINE_3" );
		// Task Force 141
		PreCacheString( &"NX_TEST_ALLENF_FAVELA_ESCAPE_INTROSCREEN_LINE_4" );
		// Rio de Janeiro, 1700 F.S.L.
		PreCacheString( &"NX_TEST_ALLENF_FAVELA_ESCAPE_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;
	case "nx_teamplayer":
		// 'The Hornet's Nest'
		PreCacheString( &"NX_TEAMPLAYER_INTROSCREEN_LINE_1" );
		// Day 4 - 04:19:[{FAKE_INTRO_SECONDS:40}]
		PreCacheString( &"NX_TEAMPLAYER_INTROSCREEN_LINE_2" );
		// Sgt. Gary 'Roach' Sanderson
		PreCacheString( &"NX_TEAMPLAYER_INTROSCREEN_LINE_3" );
		// Task Force 141
		PreCacheString( &"NX_TEAMPLAYER_INTROSCREEN_LINE_4" );
		// Rio de Janeiro, 1700 F.S.L.
		PreCacheString( &"NX_TEAMPLAYER_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;
	case "estate":
		// "Loose Ends"
		PreCacheString( &"ESTATE_INTROSCREEN_LINE_1" );
		// Day 6 - [{FAKE_INTRO_TIME:15:36:07}]
		PreCacheString( &"ESTATE_INTROSCREEN_LINE_2" );
		// Sgt. Gary Roach" Sanderson"
		PreCacheString( &"ESTATE_INTROSCREEN_LINE_3" );
		// Task Force 141
		PreCacheString( &"ESTATE_INTROSCREEN_LINE_4" );
		// Georgian-Russian Border
		PreCacheString( &"ESTATE_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;
	case "nx_estate":
		PreCacheString( &"NX_ESTATE_INTROSCREEN_LINE_1" );
		PreCacheString( &"NX_ESTATE_INTROSCREEN_LINE_2" );
		PreCacheString( &"NX_ESTATE_INTROSCREEN_LINE_3" );
		PreCacheString( &"NX_ESTATE_INTROSCREEN_LINE_4" );
		PreCacheString( &"NX_ESTATE_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;
	case "boneyard":
		// "The Enemy of My Enemy"
		PreCacheString( &"BONEYARD_INTROSCREEN_LINE_1" );
		// Day 6 - [{FAKE_INTRO_TIME:16:03:21}]
		PreCacheString( &"BONEYARD_INTROSCREEN_LINE_2" );
		// Cpt. 'Soap' MacTavish
		PreCacheString( &"BONEYARD_INTROSCREEN_LINE_3" );
		// 160 miles SW of Kandahar, Afghanistan
		PreCacheString( &"BONEYARD_INTROSCREEN_LINE_4" );
		// U.S. Ordnance and Vehicle Disposal Yard 437
		PreCacheString( &"BONEYARD_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;

	case "nx_tj_boneyard":
		// "The Enemy of My Enemy"
		PreCacheString( &"BONEYARD_INTROSCREEN_LINE_1" );
		// Day 6 - [{FAKE_INTRO_TIME:16:03:21}]
		PreCacheString( &"BONEYARD_INTROSCREEN_LINE_2" );
		// Cpt. 'Soap' MacTavish
		PreCacheString( &"BONEYARD_INTROSCREEN_LINE_3" );
		// 160 miles SW of Kandahar, Afghanistan
		PreCacheString( &"BONEYARD_INTROSCREEN_LINE_4" );
		// U.S. Ordnance and Vehicle Disposal Yard 437
		PreCacheString( &"BONEYARD_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;

	case "af_caves":
		// "Just Like Old Times"
		PreCacheString( &"AF_CAVES_LINE1" ); // "Just Like Old Times"
		// Day 7 - 16:40:[{FAKE_INTRO_SECONDS:22}]
		PreCacheString( &"AF_CAVES_LINE2" ); // Day 7 – 16:40:xx
		// 'Soap' MacTavish
		PreCacheString( &"AF_CAVES_LINE3" ); // 'Soap' MacTavish
		// Site Hotel Bravo, Afghanistan
		PreCacheString( &"AF_CAVES_LINE4" ); // Site Hotel Bravo, Afghanistan
		introscreen_delay();
		break;
	
	case "af_chase":
		// "You Can't Win A War With A Bullet"
		PreCacheString( &"AF_CHASE_INTROSCREEN_LINE1" ); 
		// Day 7 - 18:10:[{FAKE_INTRO_SECONDS:22}]
		PreCacheString( &"AF_CHASE_INTROSCREEN_LINE2" ); 
		// 'Soap' MacTavish
		PreCacheString( &"AF_CHASE_INTROSCREEN_LINE3" ); 
		// Site Hotel Bravo, Afghanistan
		PreCacheString( &"AF_CHASE_INTROSCREEN_LINE4" ); 
		//introscreen_delay();
		break;	
	
	case "example":
		/*
		PreCacheString(&"INTROSCREEN_EXAMPLE_TITLE");
		PreCacheString(&"INTROSCREEN_EXAMPLE_PLACE");
		PreCacheString(&"INTROSCREEN_EXAMPLE_DATE");
		PreCacheString(&"INTROSCREEN_EXAMPLE_INFO");
		introscreen_delay(&"INTROSCREEN_EXAMPLE_TITLE", &"INTROSCREEN_EXAMPLE_PLACE", &"INTROSCREEN_EXAMPLE_DATE", &"INTROSCREEN_EXAMPLE_INFO");
		*/
		break;
	case "bridge":
		thread flying_intro();
		break;
	case "nx_cyber":
		PreCacheString( &"NX_CYBER_INTROSCREEN_1" );
		PreCacheString( &"NX_CYBER_INTROSCREEN_2" );
		PreCacheString( &"NX_CYBER_INTROSCREEN_3" );
		PreCacheString( &"NX_CYBER_INTROSCREEN_4" );
		PreCacheString( &"NX_CYBER_INTROSCREEN_5" );
		introscreen_delay();
		break;
	case "nx_hithard":
		PreCacheString( &"NX_HITHARD_INTROSCREEN_1" );
		PreCacheString( &"NX_HITHARD_INTROSCREEN_2" );
		PreCacheString( &"NX_HITHARD_INTROSCREEN_3" );
		PreCacheString( &"NX_HITHARD_INTROSCREEN_4" );
		PreCacheString( &"NX_HITHARD_INTROSCREEN_5" );
		introscreen_delay();
		break;
	case "nx_hithard_b":
		PreCacheString( &"NX_HITHARD_B_INTROSCREEN_1" );
		PreCacheString( &"NX_HITHARD_B_INTROSCREEN_2" );
		PreCacheString( &"NX_HITHARD_B_INTROSCREEN_3" );
		PreCacheString( &"NX_HITHARD_B_INTROSCREEN_4" );
		PreCacheString( &"NX_HITHARD_B_INTROSCREEN_5" );
		introscreen_delay();
		break;		 
	case "nx_launch":
		precachestring( &"NX_LAUNCH_INTROSCREEN_1" );
		precachestring( &"NX_LAUNCH_INTROSCREEN_2" );
		precachestring( &"NX_LAUNCH_INTROSCREEN_3" );
		precachestring( &"NX_LAUNCH_INTROSCREEN_4" );
		precachestring( &"NX_LAUNCH_INTROSCREEN_5" );
		introscreen_delay(); 
		break;
	case "nx_norad":
		PreCacheString( &"NX_NORAD_INTROSCREEN_1" );
		PreCacheString( &"NX_NORAD_INTROSCREEN_2" );
		PreCacheString( &"NX_NORAD_INTROSCREEN_3" );
		PreCacheString( &"NX_NORAD_INTROSCREEN_4" );
		PreCacheString( &"NX_NORAD_INTROSCREEN_5" );
		introscreen_delay();
		break;
	case "nx_repel":
		precachestring( &"NX_REPEL_INTROSCREEN_1" );
		precachestring( &"NX_REPEL_INTROSCREEN_2" );
		precachestring( &"NX_REPEL_INTROSCREEN_3" );
		precachestring( &"NX_REPEL_INTROSCREEN_4" );
		precachestring( &"NX_REPEL_INTROSCREEN_5" );
		introscreen_delay(); 
		break;
	case "nx_skyscraper":
		precachestring( &"NX_SKYSCRAPER_INTROSCREEN_1" );
		precachestring( &"NX_SKYSCRAPER_INTROSCREEN_2" );
		precachestring( &"NX_SKYSCRAPER_INTROSCREEN_3" );
		precachestring( &"NX_SKYSCRAPER_INTROSCREEN_4" );
		precachestring( &"NX_SKYSCRAPER_INTROSCREEN_5" );
		introscreen_delay();
		break;
	case "nx_subpen":
		precachestring( &"NX_SUBPEN_INTROSCREEN_1" );
		precachestring( &"NX_SUBPEN_INTROSCREEN_2" );
		precachestring( &"NX_SUBPEN_INTROSCREEN_3" );
		precachestring( &"NX_SUBPEN_INTROSCREEN_4" );
		introscreen_delay();
		break;
	case "nx_rocket":
		introscreen_delay();
		break;
	case "nx_ss_rappel":
		introscreen_delay();
		break;
	case "nx_lava":
		introscreen_delay();
		break;
	case "nx_border":
		introscreen_delay();
		break;
	case "nx_hospital":
		introscreen_delay();
		break;
	case "nx_harbor":
		precachestring( &"NX_HARBOR_INTROSCREEN_1" );
		precachestring( &"NX_HARBOR_INTROSCREEN_2" );
		precachestring( &"NX_HARBOR_INTROSCREEN_3" );
		precachestring( &"NX_HARBOR_INTROSCREEN_4" );
		introscreen_delay();
		break;
	case "nx_test_station":
		precachestring( &"NX_TEST_STATION_INTROSCREEN_1" );
		precachestring( &"NX_TEST_STATION_INTROSCREEN_2" );
		precachestring( &"NX_TEST_STATION_INTROSCREEN_3" );
		precachestring( &"NX_TEST_STATION_INTROSCREEN_4" );
		precachestring( &"NX_TEST_STATION_INTROSCREEN_5" );
		introscreen_delay();
		break;
	case "nx_test_solar":
		precachestring( &"NX_TEST_SOLAR_INTROSCREEN_LINE_1" );
		precachestring( &"NX_TEST_SOLAR_INTROSCREEN_LINE_2" );
		precachestring( &"NX_TEST_SOLAR_INTROSCREEN_LINE_3" );
		precachestring( &"NX_TEST_SOLAR_INTROSCREEN_LINE_4" );
		precachestring( &"NX_TEST_SOLAR_INTROSCREEN_LINE_5" );
		introscreen_delay();
		break;
	case "nx_exfil":
		precachestring( &"NX_EXFIL_INTROSCREEN" );
		precachestring( &"NX_EXFIL_INTROSCREEN_DATE" );
		precachestring( &"NX_EXFIL_INTROSCREEN_CHARACTER" );
		precachestring( &"NX_EXFIL_INTROSCREEN_TEAM" );
		precachestring( &"NX_EXFIL_INTROSCREEN_LOCATION" );
		introscreen_delay();
		break;
	default:
		// Shouldn't do a notify without a wait statement before it, or bad things can happen when loading a save game.
		wait 0.05;
		level notify( "finished final intro screen fadein" );
		wait 0.05;
		level notify( "starting final intro screen fadeout" );
		wait 0.05;
		level notify( "controls_active" );// Notify when player controls have been restored
		wait 0.05;
		flag_set( "introscreen_complete" );// Do final notify when player controls have been restored
		break;
	}
}


contingency_black_screen_intro()
{
	SetSavedDvar( "hud_drawhud", "0" );
	level._player FreezeControls( true );

	//thread maps\_introscreen::introscreen_generic_black_fade_in( 3.5, 1 );
	thread maps\_introscreen::introscreen_generic_black_fade_in( 5.3, 1 );

	lines = [];
	// Contingency""
	lines[ lines.size ] = &"CONTINGENCY_LINE1";
	// Day 4 - 16:35:[{FAKE_INTRO_SECONDS:32}]
	lines[ "date" ]     = &"CONTINGENCY_LINE2";
	// Sgt. Gary 'Roach' Sanderson
	lines[ lines.size ] = &"CONTINGENCY_LINE3";
	// Task Force 141
	lines[ lines.size ] = &"CONTINGENCY_LINE4";
	// Eastern Russia
	lines[ lines.size ] = &"CONTINGENCY_LINE5";

	maps\_introscreen::introscreen_feed_lines( lines );

	wait 5;

	level._player FreezeControls( false );
	setSavedDvar( "hud_drawhud", "1" );
}

contingency_intro_text()
{
	wait .2;

	lines = [];
	// Contingency""
	lines[ lines.size ] = &"CONTINGENCY_LINE1";
	// Day 4 - 16:35:[{FAKE_INTRO_SECONDS:32}]
	lines[ "date" ]     = &"CONTINGENCY_LINE2";
	// Sgt. Gary 'Roach' Sanderson
	lines[ lines.size ] = &"CONTINGENCY_LINE3";
	// Task Force 141
	lines[ lines.size ] = &"CONTINGENCY_LINE4";
	// Eastern Russia
	lines[ lines.size ] = &"CONTINGENCY_LINE5";

	maps\_introscreen::introscreen_feed_lines( lines );
}



cliffhanger_intro_text()
{
	wait 17;

	lines = [];
	// Cliffhanger""
	lines[ lines.size ] = &"CLIFFHANGER_LINE1";
	// Day 2 - 7:35:[{FAKE_INTRO_SECONDS:32}]
	lines[ "date" ]     = &"CLIFFHANGER_LINE2";
	// Sgt. Gary Roach" Sanderson"
	lines[ lines.size ] = &"CLIFFHANGER_LINE3";
	// Task Force 141
	lines[ lines.size ] = &"CLIFFHANGER_LINE4";
	// Tian Shan Range, Kazakhstan
	lines[ lines.size ] = &"CLIFFHANGER_LINE5";

	maps\_introscreen::introscreen_feed_lines( lines );
}



introscreen_feed_lines( lines )
{
	keys = GetArrayKeys( lines );

	for ( i = 0; i < keys.size; i++ )
	{
		key = keys[ i ];
		interval = 1;
		time = ( i * interval ) + 1;
		delayThread( time, ::introscreen_corner_line, lines[ key ], ( lines.size - i - 1 ), interval, key );
	}
}

introscreen_generic_black_fade_in( time, fade_time, fade_in_time )
{
	introscreen_generic_fade_in( "black", time, fade_time, fade_in_time );
}

introscreen_generic_white_fade_in( time, fade_time, fade_in_time )
{
	introscreen_generic_fade_in( "white", time, fade_time, fade_in_time );
}

introscreen_generic_fade_in( shader, pause_time, fade_out_time, fade_in_time )
{
	if ( !isdefined( fade_out_time ) )
		fade_out_time = 1.5;

	introblack = NewHudElem();
	introblack.x = 0;
	introblack.y = 0;
	introblack.horzAlign = "fullscreen";
	introblack.vertAlign = "fullscreen";
	introblack.foreground = true;
	introblack SetShader( shader, 640, 480 );

	if ( IsDefined( fade_in_time ) && fade_in_time > 0 )
	{
		introblack.alpha = 0;
		introblack FadeOverTime( fade_in_time );
		introblack.alpha = 1;
		wait( fade_in_time );
	}

	wait pause_time;

	// Fade out black
	if ( fade_out_time > 0 )
		introblack FadeOverTime( fade_out_time );

	introblack.alpha = 0;
	
	wait fade_out_time;
	SetSavedDvar( "com_cinematicEndInWhite", 0 );
}

introscreen_create_line( string )
{
	index = level._introstring.size;
	yPos = ( index * 30 );

	if ( level._console )
		yPos -= 60;

	level._introstring[ index ] = NewHudElem();
	level._introstring[ index ].x = 0;
	level._introstring[ index ].y = yPos;
	level._introstring[ index ].alignX = "center";
	level._introstring[ index ].alignY = "middle";
	level._introstring[ index ].horzAlign = "center";
	level._introstring[ index ].vertAlign = "middle";
	level._introstring[ index ].sort = 1;// force to draw after the background
	level._introstring[ index ].foreground = true;
	level._introstring[ index ].fontScale = 1.75;
	level._introstring[ index ] SetText( string );
	level._introstring[ index ].alpha = 0;
	level._introstring[ index ] FadeOverTime( 1.2 );
	level._introstring[ index ].alpha = 1;
}

introscreen_fadeOutText()
{
	for ( i = 0; i < level._introstring.size; i++ )
	{
		level._introstring[ i ] FadeOverTime( 1.5 );
		level._introstring[ i ].alpha = 0;
	}

	wait 1.5;

	for ( i = 0; i < level._introstring.size; i++ )
		level._introstring[ i ] Destroy();

}

introscreen_delay( string1, string2, string3, string4, pausetime1, pausetime2, timebeforefade )
{
	//Chaotically wait until the frame ends twice because handle_starts waits for one frame end so that script gets to init vars
	//and this needs to wait for handle_starts to finish so that the level.start_point gets set.
	waittillframeend;
	waittillframeend;

	// tagMJS<TODO> the ship build comments were removed since we added in chapter select debug functionality
	// tagMJS<TODO> these comments should be added back in when we remove that debug functionality though
	skipIntro = !is_default_start();
	/#
	if ( GetDebugDvar( "introscreen" ) == "0" )
		skipIntro = true;
	#/

	if ( skipIntro )
	{
		waittillframeend;
		level notify( "finished final intro screen fadein" );
		waittillframeend;
		level notify( "starting final intro screen fadeout" );
		waittillframeend;
		level notify( "controls_active" );// Notify when player controls have been restored
		waittillframeend;
		flag_set( "introscreen_complete" );// Do final notify when player controls have been restored
		flag_set( "pullup_weapon" );
		return;
	}

	if ( flying_intro() )
	{
		return;
	}
	
	println( "test 2" );
	println(level._script);

	switch ( level._script )
	{
		case "airport":
			airport_intro();
			return;
		case "favela":
			favela_intro();
			return;
		case "favela_escape":
			favela_escape_intro();
			return;
		case "nx_test_allenf_favela_escape":
			nx_test_allenf_favela_escape_intro();
			return;
 		case "nx_teamplayer":
			nx_teamplayer_intro();
			return;
		case "arcadia":
			arcadia_intro();
			return;
		case "oilrig":
			oilrig_intro();
			return;
		case "dcburning":
			dcburning_intro();
			return;
		case "trainer":
			trainer_intro();
			return;
		case "nx_jr_testmap":
			nx_jr_testmap_intro();
			return;
		case "nx_eric_hud_test":
			nx_eric_hud_test_intro();
			return;
		case "nx_how_to":
// 			maps\nx_how_to_intro::display_intro_text();
// 			break;
			nx_how_to_display_intro();
			return;
		case "dcemp":
			dcemp_intro();
			return;
		case "dc_whitehouse":
			dc_whitehouse_intro();
			return;
		case "gulag":
			flag_set( "introscreen_complete" );// Notify when complete
			return;
		case "af_caves":
			af_caves_intro();
			return;
		case "roadkill":
			return;
		case "nx_cyber":
			nx_cyber_intro();
			return;
		case "nx_hithard":
			nx_hithard_intro();
			flag_set( "introscreen_complete" );// Notify when complete
			return;
		case "nx_hithard_b":
			nx_hithard_b_intro();
			flag_set( "introscreen_complete" );// Notify when complete
			return;
		case "nx_lunar":
			nx_lunar_intro();
			return;
		case "nx_lava":
			nx_lava_intro();
			return;
		case "nx_border":
			nx_border_intro();
			return;
		case "nx_hospital":
			nx_hospital_intro();
			return;
 		case "nx_norad":
			nx_norad_intro();
			return;
 		case "nx_repel":
			nx_repel_intro();
			return;
		case "nx_subpen":
			nx_subpen_intro();
			return;
		case "nx_rocket":
			nx_rocket_intro();
			return;
		case "nx_ss_rappel":
			nx_ss_rappel_intro();
			return;
		case "nx_harbor":
			nx_harbor_intro();
			return;
		case "nx_test_station":
			nx_test_station_intro();
			return;
		case "nx_test_solar":
			nx_test_solar_intro();
			return;
		case "nx_exfil":
			nx_exfil_intro();
			return;
	} 

	level._introblack = NewHudElem();
	level._introblack.x = 0;
	level._introblack.y = 0;
	level._introblack.horzAlign = "fullscreen";
	level._introblack.vertAlign = "fullscreen";
	level._introblack.foreground = true;
	level._introblack SetShader( "black", 640, 480 );

	level._player FreezeControls( true );
	wait .05;

	level._introstring = [];

	//Title of level

	if ( IsDefined( string1 ) )
		introscreen_create_line( string1 );

	if ( IsDefined( pausetime1 ) )
	{
		wait pausetime1;
	}
	else
	{
		wait 2;
	}

	//City, Country, Date

	if ( IsDefined( string2 ) )
		introscreen_create_line( string2 );
	if ( IsDefined( string3 ) )
		introscreen_create_line( string3 );

	//Optional Detailed Statement

	if ( IsDefined( string4 ) )
	{
		if ( IsDefined( pausetime2 ) )
		{
			wait pausetime2;
		}
		else
		{
			wait 2;
		}
	}

	if ( IsDefined( string4 ) )
		introscreen_create_line( string4 );

	//if(isdefined(string5))
		//introscreen_create_line(string5);

	level notify( "finished final intro screen fadein" );

	if ( IsDefined( timebeforefade ) )
	{
		wait timebeforefade;
	}
	else
	{
		wait 3;
	}

	// Fade out black
	level._introblack FadeOverTime( 1.5 );
	level._introblack.alpha = 0;

	level notify( "starting final intro screen fadeout" );

	// Restore player controls part way through the fade in
	level._player FreezeControls( false );
	level notify( "controls_active" );// Notify when player controls have been restored

	// Fade out text
	introscreen_fadeOutText();

	flag_set( "introscreen_complete" );// Notify when complete
}

_CornerLineThread( string, size, interval, index_key )
{
	level notify( "new_introscreen_element" );

	if ( !isdefined( level._intro_offset ) )
		level._intro_offset = 0;
	else
		level._intro_offset++;

	y = _CornerLineThread_height();

	hudelem = NewHudElem();
	hudelem.x = 20;
	hudelem.y = y;
	hudelem.alignX = "left";
	hudelem.alignY = "bottom";
	hudelem.horzAlign = "left";
	hudelem.vertAlign = "bottom";
	hudelem.sort = 1;// force to draw after the background
	hudelem.foreground = true;
	hudelem SetText( string );
	hudelem.alpha = 0;
	hudelem FadeOverTime( 0.2 );
	hudelem.alpha = 1;

	hudelem.hidewheninmenu = true;
	hudelem.fontScale = 1.5;// was 1.6 and 2.4, larger font change
	hudelem.color = ( getdvarfloat( "color_neutral_r" ), getdvarfloat( "color_neutral_g" ), getdvarfloat( "color_neutral_b" ) );
	hudelem.font = "fwmed";
	//hudelem.glowColor = ( 0.3, 0.6, 0.3 );
	//hudelem.glowAlpha = 1;
	duration = Int( ( size * interval * 1000 ) + 4000 );
	hudelem SetPulseFX( 30, duration, 700 );// something, decay start, decay duration

	thread hudelem_destroy( hudelem );

	if ( !isdefined( index_key ) )
		return;
	if ( !isstring( index_key ) )
		return;
	if ( index_key != "date" )
		return;
}


_CornerLineThread_height()
{
	//return ( ( ( pos ) * 19 ) - 10 );
	return( ( ( level._intro_offset ) * 20 ) - 82 );// was 19 and 22 larger font change
}

introscreen_corner_line( string, size, interval, index_key )
{
	thread _CornerLineThread( string, size, interval, index_key );
}


hudelem_destroy( hudelem )
{
	wait( level._linefeed_delay );
	hudelem notify( "destroying" );
	level._intro_offset = undefined;

	time = .5;
	hudelem FadeOverTime( time );
	hudelem.alpha = 0;
	wait time;
	hudelem notify( "destroy" );
	hudelem Destroy();
}


cargoship_intro_dvars()
{
	wait( 0.05 );
	SetSavedDvar( "compass", 0 );
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "hud_showStance", 0 );
	SetSavedDvar( "hud_drawhud", "0" );
}

favela_intro()
{
	level._player FreezeControls( true );

	// string not found for AUTOSAVE_LEVELSTART
	SaveGame( "levelstart", &"AUTOSAVE_LEVELSTART", "whatever", true );

	thread introscreen_generic_black_fade_in( 5.0 );

	lines = [];
			// 'Takedown'
	lines[ lines.size ] = &"FAVELA_INTROSCREEN_LINE_1";		// 'Takedown'
			// Day 4 - 14:30:[{FAKE_INTRO_SECONDS:16}]
	lines[ "date" ]     = &"FAVELA_INTROSCREEN_LINE_2";		// Day 4 - 14:30:[ {FAKE_INTRO_SECONDS:16} ]
			// Sgt. Gary 'Roach' Sanderson
	lines[ lines.size ] = &"FAVELA_INTROSCREEN_LINE_3";		// Sgt. Gary 'Roach' Sanderson
			// Task Force 141
	lines[ lines.size ] = &"FAVELA_INTROSCREEN_LINE_4";		// Task Force 141
			// Rio de Janeiro, Brazil
	lines[ lines.size ] = &"FAVELA_INTROSCREEN_LINE_5";		// Rio de Janeiro, Brazil

	introscreen_feed_lines( lines );

	wait( 5.0 );
	level notify( "introscreen_complete" );

	level._player FreezeControls( false );
}

favela_escape_intro()
{
	level._player FreezeControls( true );

	// string not found for AUTOSAVE_LEVELSTART
	SaveGame( "levelstart", &"AUTOSAVE_LEVELSTART", "whatever", true );

	blacktime = 6;
	thread introscreen_generic_black_fade_in( blacktime );
	thread flag_set_delayed( "introscreen_start_dialogue", 1.0 );

	lines = [];
	// 'The Hornet's Nest'
	lines[ lines.size ] = &"FAVELA_ESCAPE_INTROSCREEN_LINE_1";// 'The Hornet's Nest'
			// Day 4 - 04:19:[{FAKE_INTRO_SECONDS:40}]
	lines[ "date" ]		 = &"FAVELA_ESCAPE_INTROSCREEN_LINE_2";// Day 4 - 04:19:[ {FAKE_INTRO_SECONDS:40} ]
	// Sgt. Gary 'Roach' Sanderson
	lines[ lines.size ] = &"FAVELA_ESCAPE_INTROSCREEN_LINE_3";// Sgt. Gary 'Roach' Sanderson
	// Task Force 141
	lines[ lines.size ] = &"FAVELA_ESCAPE_INTROSCREEN_LINE_4";// Task Force 141
	// Rio de Janeiro, 1700 F.S.L.
	lines[ lines.size ] = &"FAVELA_ESCAPE_INTROSCREEN_LINE_5";// Rio de Janeiro, 7000 F.S.L.

	introscreen_feed_lines( lines );

	wait( blacktime );
	level notify( "introscreen_complete" );

	level._player FreezeControls( false );
}

nx_test_allenf_favela_escape_intro()
{
	level._player FreezeControls( true );

	// string not found for AUTOSAVE_LEVELSTART
	SaveGame( "levelstart", &"AUTOSAVE_LEVELSTART", "whatever", true );

	blacktime = 6;
	thread introscreen_generic_black_fade_in( blacktime );
	//thread flag_set_delayed( "introscreen_start_dialogue", 1.0 ); // NOT NEEDED. -AEF

	lines = [];
	// 'The Hornet's Nest'
	lines[ lines.size ] = &"NX_TEST_ALLENF_FAVELA_ESCAPE_INTROSCREEN_LINE_1";// 'The Hornet's Nest'
	// Day 4 - 04:19:[{FAKE_INTRO_SECONDS:40}]
	lines[ "date" ]		 = &"NX_TEST_ALLENF_FAVELA_ESCAPE_INTROSCREEN_LINE_2";// Day 4 - 04:19:[ {FAKE_INTRO_SECONDS:40} ]
	// Sgt. Gary 'Roach' Sanderson
	lines[ lines.size ] = &"NX_TEST_ALLENF_FAVELA_ESCAPE_INTROSCREEN_LINE_3";// Sgt. Gary 'Roach' Sanderson
	// Task Force 141
	lines[ lines.size ] = &"NX_TEST_ALLENF_FAVELA_ESCAPE_INTROSCREEN_LINE_4";// Task Force 141
	// Rio de Janeiro, 1700 F.S.L.
	lines[ lines.size ] = &"NX_TEST_ALLENF_FAVELA_ESCAPE_INTROSCREEN_LINE_5";// Rio de Janeiro, 7000 F.S.L.

	introscreen_feed_lines( lines );

	wait( blacktime );
	level notify( "introscreen_complete" );

	level._player FreezeControls( false );
}

nx_teamplayer_intro()
{
	level._player FreezeControls( true );

	// string not found for AUTOSAVE_LEVELSTART
	SaveGame( "levelstart", &"AUTOSAVE_LEVELSTART", "whatever", true );

	blacktime = 6;
	thread introscreen_generic_black_fade_in( blacktime );
	//thread flag_set_delayed( "introscreen_start_dialogue", 1.0 ); // NOT NEEDED. -AEF

	lines = [];
	// 'The Hornet's Nest'
	lines[ lines.size ] = &"NX_TEAMPLAYER_INTROSCREEN_LINE_1";// 'The Hornet's Nest'
	// Day 4 - 04:19:[{FAKE_INTRO_SECONDS:40}]
	lines[ "date" ]		 = &"NX_TEAMPLAYER_INTROSCREEN_LINE_2";// Day 4 - 04:19:[ {FAKE_INTRO_SECONDS:40} ]
	// Sgt. Gary 'Roach' Sanderson
	lines[ lines.size ] = &"NX_TEAMPLAYER_INTROSCREEN_LINE_3";// Sgt. Gary 'Roach' Sanderson
	// Task Force 141
	lines[ lines.size ] = &"NX_TEAMPLAYER_INTROSCREEN_LINE_4";// Task Force 141
	// Rio de Janeiro, 1700 F.S.L.
	lines[ lines.size ] = &"NX_TEAMPLAYER_INTROSCREEN_LINE_5";// Rio de Janeiro, 7000 F.S.L.

	introscreen_feed_lines( lines );

	wait( blacktime );
	level notify( "introscreen_complete" );

	level._player FreezeControls( false );
}

arcadia_intro()
{
	level._player FreezeControls( true );

	// string not found for AUTOSAVE_LEVELSTART
	SaveGame( "levelstart", &"AUTOSAVE_LEVELSTART", "whatever", true );

	thread introscreen_generic_black_fade_in( 5.0 );

	lines = [];
		// 'Exodus'
	lines[ lines.size ] = &"ARCADIA_INTROSCREEN_LINE_1";	// 'Contraflow'
		// Day 04 - 17:36:[{FAKE_INTRO_SECONDS:28}]
	lines[ "date" ]     = &"ARCADIA_INTROSCREEN_LINE_2";	// DC Invasion D + 1 - 15:22:[ {FAKE_INTRO_SECONDS:02} ]
		// Pvt. James Ramirez
	lines[ lines.size ] = &"ARCADIA_INTROSCREEN_LINE_3";	// PFC James Patterson
		// 1st Bn., 75th Ranger Regiment
	lines[ lines.size ] = &"ARCADIA_INTROSCREEN_LINE_4";	// U.S. Army 3rd Infantry Regiment
		// Northeastern Virginia, U.S.A.
	lines[ lines.size ] = &"ARCADIA_INTROSCREEN_LINE_5";	// Washington DC Suburbs

	introscreen_feed_lines( lines );

	wait( 5.0 );
	level notify( "introscreen_complete" );

	level._player FreezeControls( false );
}

boneyard_intro()
{
	lines = [];
			// 'The Enemy of My Enemy'
	lines[ lines.size ] = &"BONEYARD_INTROSCREEN_LINE_1";		// "The Enemy Of My Enemy"
					// Day 6 - 17:30:[{FAKE_INTRO_SECONDS:21}]
	lines[ "date" ] 	 = 	 &"BONEYARD_INTROSCREEN_LINE_2";	// Day 6 - 17:30:[ {FAKE_INTRO_SECONDS:41} ]
			// Cpt. 'Soap' MacTavish
	lines[ lines.size ] = &"BONEYARD_INTROSCREEN_LINE_3";		// Cpt. 'Soap' MacTavish
			// 160 miles SW of Kandahar, Afghanistan
	lines[ lines.size ] = &"BONEYARD_INTROSCREEN_LINE_4";		// 160 miles SW of Kandahar, Afghanistan
			// U.S. Vehicle Disposal Yard 437
	lines[ lines.size ] = &"BONEYARD_INTROSCREEN_LINE_5";		// U.S. Vehicle Disposal Yard 437

	introscreen_feed_lines( lines );

	level notify( "introscreen_complete" );
}

estate_intro()
{
	lines = [];
			// 'Loose Ends'
	lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_1";		// 'Loose Ends'
				// Day 6 - 14:45:[{FAKE_INTRO_SECONDS:07}]
	lines[ "date" ] 	 = 	 &"ESTATE_INTROSCREEN_LINE_2";	// Day 6 - 14:30:[ {FAKE_INTRO_SECONDS:07} ]
			// Sgt. Gary Roach" Sanderson"
	lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_3";		// Sgt. Gary 'Roach' Sanderson
			// Task Force 141
	lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_4";		// Task Force 141
			// Georgian-Russian Border
	lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_5";		// Georgian - Russian Border

	introscreen_feed_lines( lines );

	level notify( "introscreen_complete" );
}

airport_intro()
{
	level._player FreezeControls( true );

	// string not found for AUTOSAVE_LEVELSTART
	SaveGame( "levelstart", &"AUTOSAVE_LEVELSTART", "whatever", true );
	
	time = 21 + 5.5;
//	thread introscreen_generic_black_fade_in( time );

	lines = [];

	// No Russian""
	lines[ lines.size ] = &"AIRPORT_LINE1";
		// Day 3, 08:40:[{FAKE_INTRO_SECONDS:32}]
	lines[ "date" ] 	 = &"AIRPORT_LINE2";
	// PFC Joseph Allen a.k.a. Alexei Borodin
	lines[ lines.size ] = &"AIRPORT_LINE3";
	// Terminal 3, Domodedovo Int'l Airport
	lines[ lines.size ] = &"AIRPORT_LINE4";
	// Moscow, Russia
	lines[ lines.size ] = &"AIRPORT_LINE5";

	delayThread( 10.25 + 5.5, ::introscreen_feed_lines, lines );

	wait( time );

	wait 1;

	if ( !flag( "do_not_save" ) )
		thread autosave_now_silent();

	level notify( "introscreen_complete" );

	level._player FreezeControls( false );
}

oilrig_intro_dvars()
{
	//wait( 0.05 );
	SetSavedDvar( "ui_hidemap", 1 );
	SetSavedDvar( "hud_showStance", "0" );
	SetSavedDvar( "compass", "0" );
	//SetDvar( "old_compass", "0" );
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "g_friendlyNameDist", 0 );
	//SetSavedDvar( "hud_showTextNoAmmo", "0" ); 
}

oilrig_intro()
{
	if ( !level._underwater )
		return;
	thread oilrig_intro_dvars();
	level._player FreezeControls( true );
	flag_wait( "open_dds_door" );
	wait( 2 );
	level._player FreezeControls( false );
}

oilrig_intro2()
{
	lines = [];

	// The Only Easy Day...Was Yesterday
	lines[ lines.size ] = &"OILRIG_INTROSCREEN_LINE_1";
	// LANG_ENGLISH         Day 3 - [{FAKE_INTRO_TIME:06:58:21}] hrs"
	lines[ lines.size ] = &"OILRIG_INTROSCREEN_LINE_2";
	// Sgt. Gary 'Roach' Sanderson
	lines[ lines.size ] = &"OILRIG_INTROSCREEN_LINE_3";
	// Task Force 141
	lines[ lines.size ] = &"OILRIG_INTROSCREEN_LINE_4";
	// Vikhorevka 36 Oil Platform
	lines[ lines.size ] = &"OILRIG_INTROSCREEN_LINE_5";

	introscreen_feed_lines( lines );
}

char_museum_intro()
{
	lines = [];
	
	lines[ lines.size ] = &"CHAR_MUSEUM_LINE1";
	
	lines[ lines.size ] = &"CHAR_MUSEUM_LINE3";
	
	lines[ lines.size ] = &"CHAR_MUSEUM_LINE4";
	
	introscreen_feed_lines( lines );
}

estate_intro2()
{
	lines = [];

		// 'Loose Ends'
	lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_1";	// "'Loose Ends'"
			// Day 6 - 14:45:[{FAKE_INTRO_SECONDS:07}]
	lines[ "date" ] 	 = &"ESTATE_INTROSCREEN_LINE_2";	// "Day 06 – 14:05:[{FAKE_INTRO_SECONDS:07}]"
		// Sgt. Gary Roach" Sanderson"
	lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_3";	// "Sgt. Gary 'Roach' Sanderson"
		// Task Force 141
	lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_4";	// "Task Force 141"
		// Georgian-Russian Border
	lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_5";	// "Georgian-Russian Border"

	introscreen_feed_lines( lines );
}

nx_estate_intro()
{
	lines = [];

	// 'Loose Ends'
	lines[ lines.size ] = &"NX_ESTATE_INTROSCREEN_LINE_1";	// "'Loose Ends'"
	lines[ "date" ] 	= &"NX_ESTATE_INTROSCREEN_LINE_2";	// "Day 06 – 14:05:[{FAKE_INTRO_SECONDS:07}]"
	lines[ lines.size ] = &"NX_ESTATE_INTROSCREEN_LINE_3";	// "Sgt. Gary 'Roach' Sanderson"
	lines[ lines.size ] = &"NX_ESTATE_INTROSCREEN_LINE_4";	// "Task Force 141"
	lines[ lines.size ] = &"NX_ESTATE_INTROSCREEN_LINE_5";	// "Georgian-Russian Border"

	introscreen_feed_lines( lines );
}


dcburning_intro()
{
	level._player DisableWeapons();
	thread dcburningIntroDvars();
	level._mortar_min_dist = 1;
	level._player FreezeControls( true );

	//cinematicingamesync( "scoutsniper_fade" );

	// Start
	introblack = NewHudElem();
	introblack.x = 0;
	introblack.y = 0;
	introblack.horzAlign = "fullscreen";
	introblack.vertAlign = "fullscreen";
	introblack.foreground = true;
	introblack SetShader( "black", 640, 480 );
	wait 4.25;

//	introtime = NewHudElem();
//	introtime.x = 0;
//	introtime.y = 0;
//	introtime.alignX = "center";
//	introtime.alignY = "middle";
//	introtime.horzAlign = "center";
//	introtime.vertAlign = "middle";
//	introtime.sort = 1;
//	introtime.foreground = true;
	// 
//	introtime SetText( &"DCBURNING_MAIN_TITLE" );
//	introtime.fontScale = 1.6;
//	introtime.color = ( 0.8, 1.0, 0.8 );
//	introtime.font = "objective";
//	introtime.glowColor = ( 0.3, 0.6, 0.3 );
//	introtime.glowAlpha = 1;
//	introtime SetPulseFX( 30, 2000, 700 );// something, decay start, decay duration

	wait 3;

	// Fade out black

	level notify( "black_fading" );
	level._mortar_min_dist = undefined;
	introblack FadeOverTime( 1.5 );
	introblack.alpha = 0;

	wait( 1.5 );
	flag_set( "introscreen_complete" );
	 // Do final notify when player controls have been restored	
	level notify( "introscreen_complete" );
	level._player FreezeControls( false );
	level._player EnableWeapons();
	wait( .5 );

	SetSavedDvar( "compass", 1 );
	SetSavedDvar( "ammoCounterHide", "0" );
	SetSavedDvar( "hud_showStance", 1 );

	flag_wait( "player_exiting_start_trench" );


	lines = [];
	// 'Of Their Own Accord'
	lines[ lines.size ] = &"DCBURNING_INTROSCREEN_1";
	// LANG_ENGLISH         Day 5 - [{FAKE_INTRO_TIME:18:12:09}] hrs"
	lines[ lines.size ] = &"DCBURNING_INTROSCREEN_2";
	// Pvt. James Ramirez
	lines[ lines.size ] = &"DCBURNING_INTROSCREEN_3";
	// 75th Ranger Regiment
	lines[ lines.size ] = &"DCBURNING_INTROSCREEN_4";
	// Washington, D.C.
	lines[ lines.size ] = &"DCBURNING_INTROSCREEN_5";

	introscreen_feed_lines( lines );
}

dcemp_intro()
{
	flag_wait( "player_crash_done" );

	lines = [];
	// 'Second Sun'
	lines[ lines.size ] = &"DCEMP_INTROSCREEN_1";
	// Day 5, 19:02:[{FAKE_INTRO_SECONDS:38}] hrs
	lines[ lines.size ] = &"DCEMP_INTROSCREEN_2";
	// Pvt. James Ramirez
	lines[ lines.size ] = &"DCEMP_INTROSCREEN_3";
	// 75th Ranger Regiment
	lines[ lines.size ] = &"DCEMP_INTROSCREEN_4";
	// Washington, D.C.
	lines[ lines.size ] = &"DCEMP_INTROSCREEN_5";

	wait 1;
	maps\_introscreen::introscreen_feed_lines( lines );

	flag_set( "introscreen_complete" );
}

dc_whitehouse_intro()
{
	level._player DisableWeapons();
	level._player FreezeControls( true );

	// string not found for AUTOSAVE_LEVELSTART
	SaveGame( "levelstart", &"AUTOSAVE_LEVELSTART", "whatever", true );

	thread introscreen_generic_black_fade_in( 5.0 );

	lines = [];
	// 'Whiskey Hotel'
	lines[ lines.size ] = &"DC_WHITEHOUSE_INTROSCREEN_1";
	// Day 5, 19:31:[{FAKE_INTRO_SECONDS:22}] hrs
	lines[ "date" ]     = &"DC_WHITEHOUSE_INTROSCREEN_2";
	// Pvt. James Ramirez
	lines[ lines.size ] = &"DC_WHITEHOUSE_INTROSCREEN_3";
	// 75th Ranger Regiment
	lines[ lines.size ] = &"DC_WHITEHOUSE_INTROSCREEN_4";
	// Washington, D.C.
	lines[ lines.size ] = &"DC_WHITEHOUSE_INTROSCREEN_5";

	introscreen_feed_lines( lines );

	wait( 5.0 );
	level notify( "introscreen_complete" );

	level._player FreezeControls( false );
	level._player EnableWeapons();
}

dcburningIntroDvars()
{
	wait( 0.05 );
	SetSavedDvar( "compass", 0 );
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "hud_showStance", 0 );
}



trainerIntroDvars()
{
	//wait( 0.05 );
	SetSavedDvar( "compass", 0 );
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "hud_showStance", 0 );
}

trainer_intro()
{
	thread trainerIntroDvars();
	level._player FreezeControls( true );
	// Start
	introblack = NewHudElem();
	introblack.x = 0;
	introblack.y = 0;
	introblack.horzAlign = "fullscreen";
	introblack.vertAlign = "fullscreen";
	introblack.foreground = true;
	introblack SetShader( "black", 640, 480 );
	lines = [];
	// "S.S.D.D."
	lines[ lines.size ] = &"TRAINER_INTROSCREEN_LINE_1";
	// Day 1 - 15:30:[{FAKE_INTRO_SECONDS:25}]
	lines[ lines.size ] = &"TRAINER_INTROSCREEN_LINE_2";
	// PFC Joseph Allen
	lines[ lines.size ] = &"TRAINER_INTROSCREEN_LINE_3";
	// 1st Bn., 75th Ranger Regiment
	lines[ lines.size ] = &"TRAINER_INTROSCREEN_LINE_4";
	// Fire Base Phoenix, Afghanistan
	lines[ lines.size ] = &"TRAINER_INTROSCREEN_LINE_5";

	introscreen_feed_lines( lines );

	wait( 10 );
	// Fade out black
	level notify( "black_fading" );
	introblack FadeOverTime( 2 );
	introblack.alpha = 0;
	flag_set( "start_anims" );
	wait( 2 );
	flag_set( "introscreen_complete" );
	 // Do final notify when player controls have been restored	
	level notify( "introscreen_complete" );
	level._player FreezeControls( false );
	wait( .5 );

	SetSavedDvar( "compass", 1 );
	SetSavedDvar( "ammoCounterHide", "0" );
	SetSavedDvar( "hud_showStance", 1 );

}

nx_jr_testmap_intro()
{
	// Player can't move will intro is happening
	level._player FreezeControls( true );

	// Create the black overlay
	introblack = NewHudElem();
	introblack.x = 0;
	introblack.y = 0;
	introblack.horzAlign = "fullscreen";
	introblack.vertAlign = "fullscreen";
	introblack.foreground = true;
	introblack SetShader( "black", 640, 480 );

	lines = [];
	// "The Pit"
	lines[ lines.size ] = &"NX_JR_TESTMAP_INTROSCREEN_1";
	// Day 4 - 13:15:[{FAKE_INTRO_SECONDS:25}]
	lines[ lines.size ] = &"NX_JR_TESTMAP_INTROSCREEN_2";
	// Pvt. Richard Dennett
	lines[ lines.size ] = &"NX_JR_TESTMAP_INTROSCREEN_3";
	// Air Base Python, Afghanistan
	lines[ lines.size ] = &"NX_JR_TESTMAP_INTROSCREEN_4";
	introscreen_feed_lines( lines );

	// Plenty of time for intro text - too much time?
	wait( 8 );
	level notify( "black_fading" );
	introblack FadeOverTime( 2 );
	introblack.alpha = 0;

	wait( 1 );
	// Tell the pitguy anim to start now
	flag_set( "start_anims" );
	level._player FreezeControls( false );
	
	flag_set( "introscreen_complete" );
	level notify( "introscreen_complete" );

	wait( .5 );

	SetSavedDvar( "compass", 1 );
	SetSavedDvar( "ammoCounterHide", "0" );
	SetSavedDvar( "hud_showStance", 1 );
}

nx_eric_hud_test_intro()
{
	trigger_wait( "timer_test_timer_start", "script_noteworthy" );

	lines = [];
	// "Eric's HUD Test Level"
	lines[ lines.size ] = &"NX_ERIC_HUD_TEST_INTROSCREEN_1";
	// [{FAKE_INTRO_TIME:19:02:09}] hrs
	lines[ lines.size ] = &"NX_ERIC_HUD_TEST_INTROSCREEN_2";
	// Sgt. Joe Programmer
	lines[ lines.size ] = &"NX_ERIC_HUD_TEST_INTROSCREEN_3";
	// Neversoft HQ
	lines[ lines.size ] = &"NX_ERIC_HUD_TEST_INTROSCREEN_4";
	introscreen_feed_lines( lines );
}

nx_how_to_display_intro()
{
	trigger_wait( "trigger_intro_start_0", "script_noteworthy" );

	lines = [];
	lines[ lines.size ] = &"NX_HOW_TO_INTRO_EXAMPLE_0";
	lines[ lines.size ] = &"NX_HOW_TO_INTRO_EXAMPLE_1";
	lines[ lines.size ] = &"NX_HOW_TO_INTRO_EXAMPLE_2";
	lines[ lines.size ] = &"NX_HOW_TO_INTRO_EXAMPLE_3";
	introscreen_feed_lines( lines );
}

af_caves_intro()
{
	SetSavedDvar( "compass", 0 );
	
	level._introblack = NewHudElem();
	level._introblack.x = 0;
	level._introblack.y = 0;
	level._introblack.horzAlign = "fullscreen";
	level._introblack.vertAlign = "fullscreen";
	level._introblack.foreground = false;
	level._introblack SetShader( "black", 640, 480 );

	wait( 0.05 );
	
	flag_set( "intro_dialogue_start" );

	flag_wait( "intro_fade_in" );

	fadeTime = 3;
	level._introblack FadeOverTime( fadeTime );
	level._introblack.alpha = 0;
	wait( fadeTime );
	level._introblack Destroy();
	
	SetSavedDvar( "compass", 1 );

	flag_set( "intro_faded_in" );

	thread autosave_by_name( "intro" );
	
	flag_wait( "introscreen_feed_lines" );
	
	lines = [];
	// Just Like Old Times""
	lines[ lines.size ] = &"AF_CAVES_LINE1";// "Just Like Old Times"
	// Day 7 - 16:40:[{FAKE_INTRO_SECONDS:22}]
	lines[ "date" ]     = &"AF_CAVES_LINE2";// Day 7 – 16:40:
	// 'Soap' MacTavish
	lines[ lines.size ] = &"AF_CAVES_LINE3";// 'Soap' MacTavish
	// Site Hotel Bravo, Afghanistan
	lines[ lines.size ] = &"AF_CAVES_LINE4";// Site Hotel Bravo, Afghanistan

	level thread maps\_introscreen::introscreen_feed_lines( lines );
}

af_chase_intro()
{
	lines = [];
	
	// "You Can't Win A War With A Bullet"
	lines[ lines.size ] = &"AF_CHASE_INTROSCREEN_LINE1";
	// Day 7 - 18:10:[{FAKE_INTRO_SECONDS:22}]
	lines[ "date" ]     = &"AF_CHASE_INTROSCREEN_LINE2";
	// 'Soap' MacTavish
	lines[ lines.size ] = &"AF_CHASE_INTROSCREEN_LINE3";
	// Site Hotel Bravo, Afghanistan
	lines[ lines.size ] = &"AF_CHASE_INTROSCREEN_LINE4";

	introscreen_feed_lines( lines );

	thread autosave_by_name( "intro" );
}

bog_intro_sound()
{
	wait( 0.05 );
	//level.player PlaySound( "ui_camera_whoosh_in" );
	SetSavedDvar( "compass", 0 );
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "hud_showstance", "0" );
	SetSavedDvar( "actionSlotsHide", "1" );
}

feedline_delay()
{
	wait( 2 );
}

flying_intro()
{
	flying_levels = [];
	flying_levels[ "killhouse" ] = true;
	flying_levels[ "cliffhanger" ] = true;
	//flying_levels[ "favela_escape" ] = true;
	flying_levels[ "estate" ] = true;
	flying_levels[ "nx_estate" ] = true;
	
	if ( !getdvarint( "newintro" ) )
		flying_levels[ "roadkill" ] = true;
		
	flying_levels[ "boneyard" ] = true;

	override_angles = IsDefined( level._customIntroAngles );

	if ( !isdefined( flying_levels[ level._script ] ) )
		return false;

	if ( !isdefined( level._dontReviveHud ) )
		thread revive_ammo_counter();


	thread bog_intro_sound();
	thread weapon_pullout();

	level._player FreezeControls( true );
	feedline_delay_func = ::feedline_delay;

	zoomHeight = 16000;
	slamzoom = true;
	/#
	if ( GetDvar( "slamzoom" ) != "" )
		slamzoom = false;
	#/

	extra_delay = 0;
	special_save = false;

	if ( slamzoom )
	{
		lines = [];
		switch( level._script )
		{
			case "killhouse":
				special_save = true;
				//thread introscreen_generic_black_fade_in( 0.7, 0.20 );
				CinematicInGameSync( "killhouse_fade" );
				lines = [];
				// string not found for KILLHOUSE_INTROSCREEN_LINE_1
				lines[ lines.size ] = &"KILLHOUSE_INTROSCREEN_LINE_1";
					// string not found for KILLHOUSE_INTROSCREEN_LINE_2
			//	lines[ "date" ] 	= &"KILLHOUSE_INTROSCREEN_LINE_2";
				// string not found for KILLHOUSE_INTROSCREEN_LINE_3
				lines[ lines.size ] = &"KILLHOUSE_INTROSCREEN_LINE_3";
				// string not found for KILLHOUSE_INTROSCREEN_LINE_4
				lines[ lines.size ] = &"KILLHOUSE_INTROSCREEN_LINE_4";
				// string not found for KILLHOUSE_INTROSCREEN_LINE_5
				lines[ lines.size ] = &"KILLHOUSE_INTROSCREEN_LINE_5";
				break;

			case "estate":
				//thread introscreen_generic_black_fade_in( 0.05 );
				cinematicingamesync( "estate_fade" );
				lines = [];
				// 'Loose Ends'
				//lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_1";
				// Day 6 - 14:45:[{FAKE_INTRO_SECONDS:07}]
				//lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_2";
				// Sgt. Gary Roach" Sanderson"
				//lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_3";
				// Task Force 141
				//lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_4";
				// Georgian-Russian Border
				//lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_5";
				zoomHeight = 3500;// 2632
				SetSavedDvar( "sm_sunSampleSizeNear", 0.6 );// air
				delayThread( 0.5, ::ramp_out_sunsample_over_time, 0.9 );
				break;

			case "nx_estate":
				//thread introscreen_generic_black_fade_in( 0.05 );
				cinematicingamesync( "estate_fade" );
				lines = [];
				// 'Loose Ends'
				//lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_1";
				// Day 6 - 14:45:[{FAKE_INTRO_SECONDS:07}]
				//lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_2";
				// Sgt. Gary Roach" Sanderson"
				//lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_3";
				// Task Force 141
				//lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_4";
				// Georgian-Russian Border
				//lines[ lines.size ] = &"ESTATE_INTROSCREEN_LINE_5";
				zoomHeight = 3500;// 2632
				SetSavedDvar( "sm_sunSampleSizeNear", 0.6 );// air
				delayThread( 0.5, ::ramp_out_sunsample_over_time, 0.9 );
				break;

			case "boneyard":
				// thread introscreen_generic_black_fade_in( 0.05 );
				cinematicingamesync( "boneyard_fade" );
				lines = [];
				SetSavedDvar( "sm_sunSampleSizeNear", 0.6 );// air
				delayThread( 0.5, ::ramp_out_sunsample_over_time, 0.9 );
				zoomHeight = 4000;
				break;

			case "nx_tj_boneyard":
				// thread introscreen_generic_black_fade_in( 0.05 );
				cinematicingamesync( "boneyard_fade" );
				lines = [];
				SetSavedDvar( "sm_sunSampleSizeNear", 0.6 );// air
				delayThread( 0.5, ::ramp_out_sunsample_over_time, 0.9 );
				zoomHeight = 4000;
				break;

			case "roadkill":
				thread introscreen_generic_black_fade_in( 0.05 );
				lines = [];
				// Team Player
				lines[ lines.size ] = &"ROADKILL_LINE_1";
				// Day 1 - 16:08:[{FAKE_INTRO_SECONDS:07}]
				lines[ lines.size ] = &"ROADKILL_LINE_2";
				// PFC Joseph Allen
				lines[ lines.size ] = &"ROADKILL_LINE_3";
				// 3rd Bn, 75th Ranger Regiment
				lines[ lines.size ] = &"ROADKILL_LINE_4";
				// The Red Zone, Afghanistan
				lines[ lines.size ] = &"ROADKILL_LINE_5";
				feedline_delay = 21;

				feedline_delay_func = level._roadkill_feedline_delay;
				SetSavedDvar( "sm_sunSampleSizeNear", 2.0 );// air
				delayThread( 0.6, ::ramp_out_sunsample_over_time, 1.4 );
				break;
		}

		add_func( feedline_delay_func );
		add_func( ::introscreen_feed_lines, lines );
		thread do_funcs();
	}

	origin = level._player.origin;

	level._player PlayerSetStreamOrigin( origin );

	level._player.origin = origin + ( 0, 0, zoomHeight );
	ent = Spawn( "script_model", ( 69, 69, 69 ) );
	ent.origin = level._player.origin;

	ent SetModel( "tag_origin" );

	if ( override_angles )
	{
		ent.angles = ( 0, level._customIntroAngles[ 1 ], 0 );
	}
	else
	{
		ent.angles = level._player.angles;
	}

	level._player PlayerLinkTo( ent, undefined, 1, 0, 0, 0, 0 );
	ent.angles = ( ent.angles[ 0 ] + 89, ent.angles[ 1 ], 0 );

	wait( extra_delay );
	ent MoveTo( origin + ( 0, 0, 0 ), 2, 0, 2 );

	wait( 1.00 );
	wait( 0.5 );

	if ( override_angles )
	{
		ent RotateTo( level._customIntroAngles, 0.5, 0.3, 0.2 );
	}
	else
	{
		ent RotateTo( ( ent.angles[ 0 ] - 89, ent.angles[ 1 ], 0 ), 0.5, 0.3, 0.2 );
	}

	if ( !special_save )
		// string not found for AUTOSAVE_LEVELSTART
		SaveGame( "levelstart", &"AUTOSAVE_LEVELSTART", "whatever", true );
	wait( 0.5 );
	flag_set( "pullup_weapon" );

	wait( 0.2 );
	level._player Unlink();
	level._player FreezeControls( false );

	level._player PlayerClearStreamOrigin();

	thread play_sound_in_space( "ui_screen_trans_in", level._player.origin );

	wait( 0.2 );

	thread play_sound_in_space( "ui_screen_trans_out", level._player.origin );

	wait( 0.2 );

	// Do final notify when player controls have been restored
	flag_set( "introscreen_complete" );

	wait( 2 );

	ent Delete();

	return true;
}

weapon_pullout()
{
	weap = level._player GetWeaponsListAll()[ 0 ];
    level._player DisableWeapons();
	flag_wait( "pullup_weapon" );
    level._player EnableWeapons();
//	level.player SwitchToWeapon( weap );
}

revive_ammo_counter()
{
	flag_wait( "safe_for_objectives" );
	if ( !isdefined( level._nocompass ) )
		SetSavedDvar( "compass", 1 );
	SetSavedDvar( "ammoCounterHide", "0" );
	SetSavedDvar( "actionSlotsHide", "0" );
	SetSavedDvar( "hud_showstance", "1" );
}

ramp_out_sunsample_over_time( time, base_sample_size )
{
	sample_size = GetDvarFloat( "sm_sunSampleSizeNear" );
	if ( !isdefined( base_sample_size ) )
		base_sample_size = 0.25;

	range = sample_size - base_sample_size;// min sample size is 0.25

	frames = time * 20;
	for ( i = 0; i <= frames; i++ )
	{
		dif = i / frames;
		dif = 1 - dif;
		current_range = dif * range;
		current_sample_size = base_sample_size + current_range;
		SetSavedDvar( "sm_sunSampleSizeNear", current_sample_size );
		wait( 0.05 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// nx_cyber introscreen, Alan Flores
nx_cyber_intro()
{
    // FREEZE CONTROLS FOR INTRO
	level._player FreezeControls( true );
	
	delay = 9.0;	
	thread introscreen_generic_black_fade_in( delay );

	lines = [];
	lines[ lines.size ] = &"NX_CYBER_INTROSCREEN_1";
	lines[ "date" ]     = &"NX_CYBER_INTROSCREEN_2";
	lines[ lines.size ] = &"NX_CYBER_INTROSCREEN_3";
	lines[ lines.size ] = &"NX_CYBER_INTROSCREEN_4";
	lines[ lines.size ] = &"NX_CYBER_INTROSCREEN_5";

    // FEED ARRAY OF DESIRED LINES
	introscreen_feed_lines( lines );

	wait( delay );
	flag_set( "introscreen_complete" );

	// UNFREEZE WHEN INTRO SCREEN IS DONE
	level._player FreezeControls( false );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// nx_hithard introscreen, Brian Marvin
nx_hithard_intro()
{
    // FREEZE CONTROLS FOR INTRO
	level._player FreezeControls( true );
	
	delay = 9.0;	
	thread introscreen_generic_black_fade_in( delay );

	lines = [];
	lines[ lines.size ] = &"NX_HITHARD_INTROSCREEN_1";
	lines[ "date" ]     = &"NX_HITHARD_INTROSCREEN_2";
	lines[ lines.size ] = &"NX_HITHARD_INTROSCREEN_3";
	lines[ lines.size ] = &"NX_HITHARD_INTROSCREEN_4";
	lines[ lines.size ] = &"NX_HITHARD_INTROSCREEN_5";

    // FEED ARRAY OF DESIRED LINES
	introscreen_feed_lines( lines );

	// tagBR< note >: The -3.0 here is to give certain textures time to load in (due to camera teleport)
	wait( delay - 3.0 );
	flag_set( "introscreen_complete" );

	// UNFREEZE WHEN INTRO SCREEN IS DONE
	level._player FreezeControls( false );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// nx_hithard_b introscreen, Alan Flores
nx_hithard_b_intro()
{
    // FREEZE CONTROLS FOR INTRO
	level._player FreezeControls( true );
	
	delay = 9.0;	
	thread introscreen_generic_black_fade_in( delay );

	lines = [];
	lines[ lines.size ] = &"NX_HITHARD_B_INTROSCREEN_1";
	lines[ "date" ]     = &"NX_HITHARD_B_INTROSCREEN_2";
	lines[ lines.size ] = &"NX_HITHARD_B_INTROSCREEN_3";
	lines[ lines.size ] = &"NX_HITHARD_B_INTROSCREEN_4";
	lines[ lines.size ] = &"NX_HITHARD_B_INTROSCREEN_5";

    // FEED ARRAY OF DESIRED LINES
	introscreen_feed_lines( lines );

	wait( delay );
	flag_set( "introscreen_complete" );

	// UNFREEZE WHEN INTRO SCREEN IS DONE
	level._player FreezeControls( false );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// nx_lunar introscreen, Travis Chen
nx_lunar_intro()
{
	// Debug, can change lower if intro is annoying
	wait_time_s = 1;
	// level waittill ("player_in_vehicle_airlock_notify");
	// Freeze controls for intro
	// level._player FreezeControls( true );

	// Black fade in with time param
	//thread introscreen_generic_black_fade_in( wait_time_s );

	lines = [];
	lines[ lines.size ] = &"NX_LUNAR_INTROSCREEN_1";
	lines[ lines.size ] = &"NX_LUNAR_INTROSCREEN_2";
	lines[ lines.size ] = &"NX_LUNAR_INTROSCREEN_3";
	lines[ lines.size ] = &"NX_LUNAR_INTROSCREEN_4";
	lines[ lines.size ] = &"NX_LUNAR_INTROSCREEN_5";

	wait( wait_time_s );
	// Feed array of desired lines
	introscreen_feed_lines( lines );
	//level thread nx_lunar_intro_dialogue();

	flag_set( "introscreen_complete" );

	// Unfreeze when intro screen is done
	// level._player FreezeControls( false );
}

nx_lunar_intro_dialogue()
{
	// Falcon, "Life support systems at under 10%."
	radio_dialogue( "moon_fal_esc_01" );

	wait( 0.5 );

	// Eagle, "They're breaking the seal."
	radio_dialogue( "moon_eag_esc_01" );

	// Eagle, "Brace for depressurization"
	radio_dialogue( "moon_eag_esc_03" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// nx_lava introscreen, Travis Chen
nx_lava_intro()
{
	// FREEZE CONTROLS FOR INTRO
	level._player FreezeControls( true );

	// Debug, can change lower if intro is annoying
	blacktime = 6;

	// Black fade in with time param
	thread introscreen_generic_black_fade_in( blacktime );

	lines = [];
	lines[ lines.size ] = &"NX_LAVA_INTROSCREEN_1";
	lines[ lines.size ] = &"NX_LAVA_INTROSCREEN_2";
	lines[ lines.size ] = &"NX_LAVA_INTROSCREEN_3";
	lines[ lines.size ] = &"NX_LAVA_INTROSCREEN_4";
	lines[ lines.size ] = &"NX_LAVA_INTROSCREEN_5";

	// Feed array of desired lines
	introscreen_feed_lines( lines );

	level._player FreezeControls( false );
	
	wait( blacktime - 0.1 );
	
	flag_set( "introscreen_complete" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// nx_border introscreen, Travis Chen
nx_border_intro()
{
	// FREEZE CONTROLS FOR INTRO
	level._player FreezeControls( true );

	// Debug, can change lower if intro is annoying
	blacktime = 6;

	// Black fade in with time param
	thread introscreen_generic_black_fade_in( blacktime );

	lines = [];
	lines[ lines.size ] = &"NX_BORDER_INTROSCREEN_1";
	lines[ lines.size ] = &"NX_BORDER_INTROSCREEN_2";
	lines[ lines.size ] = &"NX_BORDER_INTROSCREEN_3";
	lines[ lines.size ] = &"NX_BORDER_INTROSCREEN_4";
	lines[ lines.size ] = &"NX_BORDER_INTROSCREEN_5";

	// Feed array of desired lines
	introscreen_feed_lines( lines );

	level._player FreezeControls( false );
	
	wait( blacktime - 0.1 );
	
	flag_set( "introscreen_complete" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// nx_hospital introscreen
nx_hospital_intro()
{
	// FREEZE CONTROLS FOR INTRO
	level._player FreezeControls( true );

	// Debug, can change lower if intro is annoying
	blacktime = 1;

	// Black fade in with time param
	thread introscreen_generic_black_fade_in( blacktime );

	lines = [];
	lines[ lines.size ] = &"NX_HOSPITAL_INTROSCREEN_1";
	lines[ lines.size ] = &"NX_HOSPITAL_INTROSCREEN_2";
	lines[ lines.size ] = &"NX_HOSPITAL_INTROSCREEN_3";
	lines[ lines.size ] = &"NX_HOSPITAL_INTROSCREEN_4";
	lines[ lines.size ] = &"NX_HOSPITAL_INTROSCREEN_5";

	// Feed array of desired lines
	introscreen_feed_lines( lines );

	level._player FreezeControls( false );
	
	wait( blacktime - 0.1 );
	
	flag_set( "introscreen_complete" );
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// nx_norad introscreen, Allen Freese
nx_norad_intro()
{
    // FREEZE CONTROLS FOR INTRO
	level._player FreezeControls( true );

	blacktime = 6;
	thread introscreen_generic_black_fade_in( blacktime );

	lines = [];
	lines[ lines.size ] = &"NX_NORAD_INTROSCREEN_1";
	lines[ "date" ]     = &"NX_NORAD_INTROSCREEN_2";
	lines[ lines.size ] = &"NX_NORAD_INTROSCREEN_3";
	lines[ lines.size ] = &"NX_NORAD_INTROSCREEN_4";
	lines[ lines.size ] = &"NX_NORAD_INTROSCREEN_5";

    // FEED ARRAY OF DESIRED LINES
	introscreen_feed_lines( lines );

	wait( blacktime );
	flag_set( "introscreen_complete" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// nx_repel introscreen, Daryl Kimoto
nx_repel_intro()
{
    // Freeze controls for intro
	level._player FreezeControls( true );

    // Black fade in with time param
	thread introscreen_generic_black_fade_in( 2.0 );

	wait( 2.0 );
	level notify( "introscreen_complete" );

	// Unfreeze when intro screen is done
	level._player FreezeControls( false );

	flag_wait( "exiting_osprey" );

	wait( 3.0 );

	lines = [];
	lines[ lines.size ] = &"NX_REPEL_INTROSCREEN_1";
	lines[ "date" ]     = &"NX_REPEL_INTROSCREEN_2";
	lines[ lines.size ] = &"NX_REPEL_INTROSCREEN_3";
	lines[ lines.size ] = &"NX_REPEL_INTROSCREEN_4";

    // Feed array of desired lines
	introscreen_feed_lines( lines );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// nx_subpen introscreen, Justin Rote
nx_subpen_intro()
{
	// Commented out because its annoying and strings dont work yet
    // Freeze controls for intro
	level._player FreezeControls( true );

    // Black fade in with time param
	thread introscreen_generic_black_fade_in( 3.0 ); // 6.0

	lines = [];
	lines[ lines.size ] = &"NX_SUBPEN_INTROSCREEN_1";
	lines[ "date" ]     = &"NX_SUBPEN_INTROSCREEN_2";
	lines[ lines.size ] = &"NX_SUBPEN_INTROSCREEN_3";
	lines[ lines.size ] = &"NX_SUBPEN_INTROSCREEN_4";

    // Feed array of desired lines
	introscreen_feed_lines( lines );

	wait( 1.0 );
	level notify( "introscreen_complete" );

	// Unfreeze when intro screen is done
	level._player FreezeControls( false );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// nx_rocket introscreen, Justin Rote
nx_rocket_intro()
{
	// Commented out because its annoying and strings dont work yet
    // Freeze controls for intro
	level._player FreezeControls( true );

    // Black fade in with time param
	thread introscreen_generic_black_fade_in( 5.0 );

	lines = [];
	lines[ lines.size ] = &"NX_ROCKET_INTROSCREEN_1";
	lines[ "date" ]     = &"NX_ROCKET_INTROSCREEN_2";
	lines[ lines.size ] = &"NX_ROCKET_INTROSCREEN_3";
	lines[ lines.size ] = &"NX_ROCKET_INTROSCREEN_4";

    // Feed array of desired lines
	introscreen_feed_lines( lines );

	//wait( 6.0 );
	level notify( "introscreen_complete" );

	// Unfreeze when intro screen is done
	level._player FreezeControls( false );	
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// nx_ss_rappel introscreen
nx_ss_rappel_intro()
{
	// Commented out because its annoying and strings dont work yet
    // Freeze controls for intro
	level._player FreezeControls( true );

    // Black fade in with time param
	thread introscreen_generic_black_fade_in( 0.35, 0.2 );

	level notify( "introscreen_complete" );

	// Unfreeze when intro screen is done
	level._player FreezeControls( false );	
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// nx_harbor introscreen, Travis Chen
nx_harbor_intro()
{
	// Commented out because its annoying and strings dont work yet
    // Freeze controls for intro
	level._player FreezeControls( true );

    // Black fade in with time param
	thread introscreen_generic_black_fade_in( 3.0 ); // 6.0

	lines = [];
	lines[ lines.size ] = &"NX_HARBOR_INTROSCREEN_1";
	lines[ "date" ]     = &"NX_HARBOR_INTROSCREEN_2";
	lines[ lines.size ] = &"NX_HARBOR_INTROSCREEN_3";
	lines[ lines.size ] = &"NX_HARBOR_INTROSCREEN_4";

    // Feed array of desired lines
	introscreen_feed_lines( lines );

	wait( 1.0 );
	level notify( "introscreen_complete" );

	// Unfreeze when intro screen is done
	level._player FreezeControls( false );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

nx_exfil_intro()
{
	// Commented out because its annoying and strings dont work yet
	// Freeze controls for intro
	level._player FreezeControls( true );
	SetSavedDvar( "hud_showStance", 0 );
	SetSavedDvar( "ammoCounterHide", "1" );

	// Black fade in with time param
	thread introscreen_generic_black_fade_in( 1.3 );

	lines = [];
	lines[ lines.size ] = &"NX_EXFIL_INTROSCREEN";
	lines[ "date" ]     = &"NX_EXFIL_INTROSCREEN_DATE";
	lines[ lines.size ] = &"NX_EXFIL_INTROSCREEN_CHARACTER";
	lines[ lines.size ] = &"NX_EXFIL_INTROSCREEN_TEAM";
	lines[ lines.size ] = &"NX_EXFIL_INTROSCREEN_LOCATION";

	// Feed array of desired lines
	introscreen_feed_lines( lines );

	//wait( 6.0 );
	level notify( "introscreen_complete" );

	// Unfreeze when intro screen is done
	level._player FreezeControls( false );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

nx_test_station_intro()
{
	thread introscreen_generic_black_fade_in( 0.5 );

	lines = [];
	lines[ lines.size ] = &"NX_TEST_STATION_INTROSCREEN_1";
	lines[ lines.size ] = &"NX_TEST_STATION_INTROSCREEN_2";
	lines[ lines.size ] = &"NX_TEST_STATION_INTROSCREEN_3";
	lines[ lines.size ] = &"NX_TEST_STATION_INTROSCREEN_4";
	lines[ lines.size ] = &"NX_TEST_STATION_INTROSCREEN_5";
	introscreen_feed_lines( lines );

	wait( 0.5 );

	flag_set( "introscreen_complete" );
}

// nx_test_solar intro

nx_test_solar_intro()
{
	thread introscreen_generic_black_fade_in( 0.5 );

	lines = [];
	lines[ lines.size ] = &"NX_TEST_SOLAR_INTROSCREEN_LINE_1";
	lines[ lines.size ] = &"NX_TEST_SOLAR_INTROSCREEN_LINE_2";
	lines[ lines.size ] = &"NX_TEST_SOLAR_INTROSCREEN_LINE_3";
	lines[ lines.size ] = &"NX_TEST_SOLAR_INTROSCREEN_LINE_4";
	lines[ lines.size ] = &"NX_TEST_SOLAR_INTROSCREEN_LINE_5";
	introscreen_feed_lines( lines );

	wait( 0.5 );

	flag_set( "introscreen_complete" );
}
