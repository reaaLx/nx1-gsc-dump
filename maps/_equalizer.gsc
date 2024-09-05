#include maps\_utility;

loadPresets()
{
	// add your own preset eq filters here
	// should be used for commonly used, generic filters
	// see _ambient.gsc for defining specialized filters

	// sample test eq filters
	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	// up to three bands( 0, 1, 2 ) for a filter
	// filter types are: lowshelf, highshelf, bell, lowpass, highpass
	// freq ranges from 20 Hz to 20 kHz
	// gain has no code restricted range, but should probably be between + / - 18 dB
	// q must be > 0 and has no code restricted max

	// example of a three band filter
	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	// defineFilter( "test", 0, "lowshelf", 3000, 6, 2 );
	// defineFilter( "test", 1, "highshelf", 3000, -12, 2 );
	// defineFilter( "test", 2, "bell", 1500, 6, 3 );

	// example of a single band filter
	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	// defineFilter( "single", 0, "highpass", 10000, 1, 1 );

// ***********************************************************

	level._eq_defs = [];
	level._ambient_reverb = [];

// ***********************************************************
//				nx1 reverbs
// ***********************************************************

	define_reverb( "nx_repel_ext" );
	set_reverb_roomtype( "nx_repel_ext", 			"city" );
	set_reverb_drylevel( "nx_repel_ext", 			0.9 );
	set_reverb_wetlevel( "nx_repel_ext", 			0.2 );
	set_reverb_fadetime( "nx_repel_ext", 			5 );
	set_reverb_priority( "nx_repel_ext", 			"snd_enveffectsprio_level" );

	define_reverb( "nx_repel_int" );
	set_reverb_roomtype( "nx_repel_int", 			"stoneroom" );
	set_reverb_drylevel( "nx_repel_int", 			0.8 );
	set_reverb_wetlevel( "nx_repel_int", 			0.5 );
	set_reverb_fadetime( "nx_repel_int", 			5 );
	set_reverb_priority( "nx_repel_int", 			"snd_enveffectsprio_level" );

	//define_reverb( "nx_repel_osp" );
	//set_reverb_roomtype( "nx_repel_osp", 		"livingroom" );
	//set_reverb_drylevel( "nx_repel_osp", 		0.8 );
	//set_reverb_wetlevel( "nx_repel_osp", 		0.5 );
	//set_reverb_fadetime( "nx_repel_osp", 		5 );
	//set_reverb_priority( "nx_repel_osp", 		"snd_enveffectsprio_level" );



	define_reverb( "nx_norad_ext" );
	set_reverb_roomtype( "nx_norad_ext", 		"mountains" );
	set_reverb_drylevel( "nx_norad_ext", 		0.8 );
	set_reverb_wetlevel( "nx_norad_ext", 		0.4 );
	set_reverb_fadetime( "nx_norad_ext", 		4 );
	set_reverb_priority( "nx_norad_ext", 		"snd_enveffectsprio_level" );
	
	define_reverb( "nx_norad_int" );
	set_reverb_roomtype( "nx_norad_int", 			"cave" );
	set_reverb_drylevel( "nx_norad_int", 			0.7 );
	set_reverb_wetlevel( "nx_norad_int", 			0.8 );
	set_reverb_fadetime( "nx_norad_int", 			4 );
	set_reverb_priority( "nx_norad_int", 			"snd_enveffectsprio_level" );

	define_reverb( "nx_lunar_hydro" );
	set_reverb_roomtype( "nx_lunar_hydro", 			"carpetedhallway" );
	set_reverb_drylevel( "nx_lunar_hydro", 			0.9 );
	set_reverb_wetlevel( "nx_lunar_hydro", 			0.25 );
	set_reverb_fadetime( "nx_lunar_hydro", 			6 );
	set_reverb_priority( "nx_lunar_hydro", 			"snd_enveffectsprio_level" );

	define_reverb( "nx_hithard_basement" );
	set_reverb_roomtype( "nx_hithard_basement", 	 	"stoneroom" );
	set_reverb_drylevel( "nx_hithard_basement", 		0.8 );
	set_reverb_wetlevel( "nx_hithard_basement", 		0.5 );
	set_reverb_fadetime( "nx_hithard_basement", 		2 );
	set_reverb_priority( "nx_hithard_basement", 		"snd_enveffectsprio_level" );


	define_reverb( "nx_hithard_stairs" );
	set_reverb_roomtype( "nx_hithard_stairs", 	 	"stoneroom" );
	set_reverb_drylevel( "nx_hithard_stairs", 		0.1 );
	set_reverb_wetlevel( "nx_hithard_stairs", 		0.9 );
	set_reverb_fadetime( "nx_hithard_stairs", 		2 );
	set_reverb_priority( "nx_hithard_stairs", 		"snd_enveffectsprio_level" );


// ***********************************************************
//				old iw4 reverbs
// ***********************************************************

	define_reverb( "deathsdoor" );
	set_reverb_roomtype( "deathsdoor", 		"underwater" );
	set_reverb_drylevel( "deathsdoor", 		0.5 );
	set_reverb_wetlevel( "deathsdoor", 		0.4 );
	set_reverb_fadetime( "deathsdoor", 		2 );
	set_reverb_priority( "deathsdoor", 		"snd_enveffectsprio_level" );

        define_reverb( "space" );
	set_reverb_roomtype( "space", 		"underwater" );
	set_reverb_drylevel( "space", 		1.0 );
	set_reverb_wetlevel( "space", 		0.0 );
	set_reverb_fadetime( "space", 		0.1 );
	set_reverb_priority( "space", 		"snd_enveffectsprio_level" );

	define_reverb( "ac130" );
	set_reverb_roomtype( "ac130", 		"sewerpipe" );
	set_reverb_drylevel( "ac130", 		0.9 );
	set_reverb_wetlevel( "ac130", 		0.05 );
	set_reverb_fadetime( "ac130", 		2 );
	set_reverb_priority( "ac130", 		"snd_enveffectsprio_level" );
	
	define_reverb( "af_caves_ext" );
	set_reverb_roomtype( "af_caves_ext", 		"mountains" );
	set_reverb_drylevel( "af_caves_ext", 		0.8 );
	set_reverb_wetlevel( "af_caves_ext", 		0.4 );
	set_reverb_fadetime( "af_caves_ext", 		2 );
	set_reverb_priority( "af_caves_ext", 		"snd_enveffectsprio_level" );
	
	define_reverb( "af_caves_int" );
	set_reverb_roomtype( "af_caves_int", 			"cave" );
	set_reverb_drylevel( "af_caves_int", 			0.85 );
	set_reverb_wetlevel( "af_caves_int", 			0.3 );
	set_reverb_fadetime( "af_caves_int", 			6 );
	set_reverb_priority( "af_caves_int", 			"snd_enveffectsprio_level" );
	
	define_reverb( "af_chase_caves" );
	set_reverb_roomtype( "af_chase_caves", 			"cave" );
	set_reverb_drylevel( "af_chase_caves", 			0.85 );
	set_reverb_wetlevel( "af_chase_caves", 			0.35 );
	set_reverb_fadetime( "af_chase_caves", 			6 );
	set_reverb_priority( "af_chase_caves", 			"snd_enveffectsprio_level" );
	
	define_reverb( "af_chase_exit" );
	set_reverb_roomtype( "af_chase_exit", 		"mountains" );
	set_reverb_drylevel( "af_chase_exit", 		0.95 );
	set_reverb_wetlevel( "af_chase_exit", 		0.2 );
	set_reverb_fadetime( "af_chase_exit", 		2 );
	set_reverb_priority( "af_chase_exit", 		"snd_enveffectsprio_level" );
	
	define_reverb( "af_chase_rapids" );
	set_reverb_roomtype( "af_chase_rapids", 		"mountains" );
	set_reverb_drylevel( "af_chase_rapids", 		0.95 );
	set_reverb_wetlevel( "af_chase_rapids", 		0.2 );
	set_reverb_fadetime( "af_chase_rapids", 		2 );
	set_reverb_priority( "af_chase_rapids", 		"snd_enveffectsprio_level" );
	
	define_reverb( "af_chase_river" );
	set_reverb_roomtype( "af_chase_river", 		"mountains" );
	set_reverb_drylevel( "af_chase_river", 		0.95 );
	set_reverb_wetlevel( "af_chase_river", 		0.2 );
	set_reverb_fadetime( "af_chase_river", 		2 );
	set_reverb_priority( "af_chase_river", 		"snd_enveffectsprio_level" );
	
	define_reverb( "af_chase_ext" );
	set_reverb_roomtype( "af_chase_ext", 		"mountains" );
	set_reverb_drylevel( "af_chase_ext", 		0.95 );
	set_reverb_wetlevel( "af_chase_ext", 		0.2 );
	set_reverb_fadetime( "af_chase_ext", 		2 );
	set_reverb_priority( "af_chase_ext", 		"snd_enveffectsprio_level" );

	define_reverb( "airport_basement0" );
	set_reverb_roomtype( "airport_basement0", 	 	"stoneroom" );
	set_reverb_drylevel( "airport_basement0", 		0.8 );
	set_reverb_wetlevel( "airport_basement0", 		0.4 );
	set_reverb_fadetime( "airport_basement0", 		2 );
	set_reverb_priority( "airport_basement0", 		"snd_enveffectsprio_level" );

	define_reverb( "airport_ext0" );
	set_reverb_roomtype( "airport_ext0", 		"city" );
	set_reverb_drylevel( "airport_ext0", 		0.9 );
	set_reverb_wetlevel( "airport_ext0", 		0.15 );
	set_reverb_fadetime( "airport_ext0", 		2 );
	set_reverb_priority( "airport_ext0", 		"snd_enveffectsprio_level" );

	define_reverb( "airport_terminal0" );
	set_reverb_roomtype( "airport_terminal0", 		"stonecorridor" );
	set_reverb_drylevel( "airport_terminal0", 		0.9 );
	set_reverb_wetlevel( "airport_terminal0", 		0.09 );
	set_reverb_fadetime( "airport_terminal0", 		0.9 );
	set_reverb_priority( "airport_terminal0", 		"snd_enveffectsprio_level" );

	define_reverb( "alley" );
	set_reverb_roomtype( "alley", 		"alley" );
	set_reverb_drylevel( "alley", 		0.9 );
	set_reverb_wetlevel( "alley", 		0.1 );
	set_reverb_fadetime( "alley", 		2 );
	set_reverb_priority( "alley", 		"snd_enveffectsprio_level" );

	define_reverb( "arcadia_ext1" );
	set_reverb_roomtype( "arcadia_ext1", 			"parkinglot" );
	set_reverb_drylevel( "arcadia_ext1", 			0.95 );
	set_reverb_wetlevel( "arcadia_ext1", 			0.2 );
	set_reverb_fadetime( "arcadia_ext1", 			3 );
	set_reverb_priority( "arcadia_ext1", 			"snd_enveffectsprio_level" );

	define_reverb( "arcadia_ext3" );
	set_reverb_roomtype( "arcadia_ext3", 			"parkinglot" );
	set_reverb_drylevel( "arcadia_ext3", 			0.95 );
	set_reverb_wetlevel( "arcadia_ext3", 			0.2 );
	set_reverb_fadetime( "arcadia_ext3", 			3 );
	set_reverb_priority( "arcadia_ext3", 			"snd_enveffectsprio_level" );

	define_reverb( "boneyard_ext0" );
	set_reverb_roomtype( "boneyard_ext0", 		"mountains" );
	set_reverb_drylevel( "boneyard_ext0", 		0.8 );
	set_reverb_wetlevel( "boneyard_ext0", 		0.3 );
	set_reverb_fadetime( "boneyard_ext0", 		2 );
	set_reverb_priority( "boneyard_ext0", 		"snd_enveffectsprio_level" );

	define_reverb( "bridge_ext0" );
	set_reverb_roomtype( "bridge_ext0", 			"city" );
	set_reverb_drylevel( "bridge_ext0", 			0.9 );
	set_reverb_wetlevel( "bridge_ext0", 			0.15 );
	set_reverb_fadetime( "bridge_ext0", 			6 );
	set_reverb_priority( "bridge_ext0", 			"snd_enveffectsprio_level" );

	define_reverb( "bunker" );
	set_reverb_roomtype( "bunker", 	 	"stoneroom" );
	set_reverb_drylevel( "bunker", 		0.8 );
	set_reverb_wetlevel( "bunker", 		0.4 );
	set_reverb_fadetime( "bunker", 		2 );
	set_reverb_priority( "bunker", 		"snd_enveffectsprio_level" );

	define_reverb( "city" );
	set_reverb_roomtype( "city", 			"city" );
	set_reverb_drylevel( "city", 			0.8 );
	set_reverb_wetlevel( "city", 			0.3 );
	set_reverb_fadetime( "city", 			2 );
	set_reverb_priority( "city", 			"snd_enveffectsprio_level" );

	define_reverb( "container" );
	set_reverb_roomtype( "container", 		"sewerpipe" );
	set_reverb_drylevel( "container", 		0.9 );
	set_reverb_wetlevel( "container", 		0.4 );
	set_reverb_fadetime( "container", 		2 );
	set_reverb_priority( "container", 		"snd_enveffectsprio_level" );

	define_reverb( "dcburning_bunker1" );
	set_reverb_roomtype( "dcburning_bunker1", 			"stoneroom" );
	set_reverb_drylevel( "dcburning_bunker1", 			0.8 );
	set_reverb_wetlevel( "dcburning_bunker1", 			0.35 );
	set_reverb_fadetime( "dcburning_bunker1", 			6 );
	set_reverb_priority( "dcburning_bunker1", 			"snd_enveffectsprio_level" );

	define_reverb( "dcburning_ext1" );
	set_reverb_roomtype( "dcburning_ext1", 			"city" );
	set_reverb_drylevel( "dcburning_ext1", 			0.95 );
	set_reverb_wetlevel( "dcburning_ext1", 			0.15 );
	set_reverb_fadetime( "dcburning_ext1", 			6 );
	set_reverb_priority( "dcburning_ext1", 			"snd_enveffectsprio_level" );

	define_reverb( "dcburning_building1" );
	set_reverb_roomtype( "dcburning_building1", 			"city" );
	set_reverb_drylevel( "dcburning_building1", 			0.85 );
	set_reverb_wetlevel( "dcburning_building1", 			0.25 );
	set_reverb_fadetime( "dcburning_building1", 			6 );
	set_reverb_priority( "dcburning_building1", 			"snd_enveffectsprio_level" );
		
	define_reverb( "dcemp_iss" );
	set_reverb_roomtype( "dcemp_iss", 			"city" );
	set_reverb_drylevel( "dcemp_iss", 			0.9 );
	set_reverb_wetlevel( "dcemp_iss", 			0.15 );
	set_reverb_fadetime( "dcemp_iss", 			6 );
	set_reverb_priority( "dcemp_iss", 			"snd_enveffectsprio_level" );
	
	define_reverb( "dcemp_dry" );
	set_reverb_roomtype( "dcemp_dry", 			"stonecorridor" );
	set_reverb_drylevel( "dcemp_dry", 			0.95 );
	set_reverb_wetlevel( "dcemp_dry", 			0.15 );
	set_reverb_fadetime( "dcemp_dry", 			2 );
	set_reverb_priority( "dcemp_dry", 			"snd_enveffectsprio_level" );
	
	define_reverb( "dcemp_dry_int" );
	set_reverb_roomtype( "dcemp_dry_int", 			"carpetedhallway" );
	set_reverb_drylevel( "dcemp_dry_int", 			0.9 );
	set_reverb_wetlevel( "dcemp_dry_int", 			0.25 );
	set_reverb_fadetime( "dcemp_dry_int", 			3 );
	set_reverb_priority( "dcemp_dry_int", 			"snd_enveffectsprio_level" );
	
	define_reverb( "dcemp_light_rain" );
	set_reverb_roomtype( "dcemp_light_rain", 			"stonecorridor" );
	set_reverb_drylevel( "dcemp_light_rain", 			0.9 );
	set_reverb_wetlevel( "dcemp_light_rain", 			0.15 );
	set_reverb_fadetime( "dcemp_light_rain", 			2 );
	set_reverb_priority( "dcemp_light_rain", 			"snd_enveffectsprio_level" );
	
	define_reverb( "dcemp_light_rain_int" );
	set_reverb_roomtype( "dcemp_light_rain_int", 			"carpetedhallway" );
	set_reverb_drylevel( "dcemp_light_rain_int", 			0.9 );
	set_reverb_wetlevel( "dcemp_light_rain_int", 			0.25 );
	set_reverb_fadetime( "dcemp_light_rain_int", 			6 );
	set_reverb_priority( "dcemp_light_rain_int", 			"snd_enveffectsprio_level" );
	
	define_reverb( "dcemp_heavy_rain" );
	set_reverb_roomtype( "dcemp_heavy_rain", 			"city" );
	set_reverb_drylevel( "dcemp_heavy_rain", 			0.9 );
	set_reverb_wetlevel( "dcemp_heavy_rain", 			0.15 );
	set_reverb_fadetime( "dcemp_heavy_rain", 			6 );
	set_reverb_priority( "dcemp_heavy_rain", 			"snd_enveffectsprio_level" );
	
	define_reverb( "dcemp_heavy_rain_int" );
	set_reverb_roomtype( "dcemp_heavy_rain_int", 			"carpetedhallway" );
	set_reverb_drylevel( "dcemp_heavy_rain_int", 			0.9 );
	set_reverb_wetlevel( "dcemp_heavy_rain_int", 			0.25 );
	set_reverb_fadetime( "dcemp_heavy_rain_int", 			6 );
	set_reverb_priority( "dcemp_heavy_rain_int", 			"snd_enveffectsprio_level" );
	
	define_reverb( "dcemp_heavy_rain_tunnel" );
	set_reverb_roomtype( "dcemp_heavy_rain_tunnel", 			"cave" );
	set_reverb_drylevel( "dcemp_heavy_rain_tunnel", 			0.8 );
	set_reverb_wetlevel( "dcemp_heavy_rain_tunnel", 			0.3 );
	set_reverb_fadetime( "dcemp_heavy_rain_tunnel", 			6 );
	set_reverb_priority( "dcemp_heavy_rain_tunnel", 			"snd_enveffectsprio_level" );

	define_reverb( "estate_ext0" );
	set_reverb_roomtype( "estate_ext0", 		"mountains" );
	set_reverb_drylevel( "estate_ext0", 		0.8 );
	set_reverb_wetlevel( "estate_ext0", 		0.4 );
	set_reverb_fadetime( "estate_ext0", 		2 );
	set_reverb_priority( "estate_ext0", 		"snd_enveffectsprio_level" );

	define_reverb( "exterior" );
	set_reverb_roomtype( "exterior", 		"city" );
	set_reverb_drylevel( "exterior", 		0.9 );
	set_reverb_wetlevel( "exterior", 		0.15 );
	set_reverb_fadetime( "exterior", 		6 );
	set_reverb_priority( "exterior", 		"snd_enveffectsprio_level" );

	define_reverb( "exterior1" );
	set_reverb_roomtype( "exterior1", 		"alley" );
	set_reverb_drylevel( "exterior1", 		0.9 );
	set_reverb_wetlevel( "exterior1", 		0.2 );
	set_reverb_fadetime( "exterior1", 		2 );
	set_reverb_priority( "exterior1", 		"snd_enveffectsprio_level" );

	define_reverb( "exterior2" );
	set_reverb_roomtype( "exterior2", 		"alley" );
	set_reverb_drylevel( "exterior2", 		0.9 );
	set_reverb_wetlevel( "exterior2", 		0.2 );
	set_reverb_fadetime( "exterior2", 		2 );
	set_reverb_priority( "exterior2", 		"snd_enveffectsprio_level" );

	define_reverb( "exterior3" );
	set_reverb_roomtype( "exterior3", 		"alley" );
	set_reverb_drylevel( "exterior3", 		0.9 );
	set_reverb_wetlevel( "exterior3", 		0.2 );
	set_reverb_fadetime( "exterior3", 		2 );
	set_reverb_priority( "exterior3", 		"snd_enveffectsprio_level" );

	define_reverb( "exterior4" );
	set_reverb_roomtype( "exterior4", 		"alley" );
	set_reverb_drylevel( "exterior4", 		0.9 );
	set_reverb_wetlevel( "exterior4", 		0.2 );
	set_reverb_fadetime( "exterior4", 		2 );
	set_reverb_priority( "exterior4", 		"snd_enveffectsprio_level" );

	define_reverb( "exterior5" );
	set_reverb_roomtype( "exterior5", 		"alley" );
	set_reverb_drylevel( "exterior5", 		0.9 );
	set_reverb_wetlevel( "exterior5", 		0.2 );
	set_reverb_fadetime( "exterior5", 		2 );
	set_reverb_priority( "exterior5", 		"snd_enveffectsprio_level" );

	define_reverb( "exterior_level2" );
	set_reverb_roomtype( "exterior_level2", 			"city" );
	set_reverb_drylevel( "exterior_level2", 			0.95 );
	set_reverb_wetlevel( "exterior_level2", 			0.15 );
	set_reverb_fadetime( "exterior_level2", 			2 );
	set_reverb_priority( "exterior_level2", 			"snd_enveffectsprio_level" );

	define_reverb( "favela_ext0" );
	set_reverb_roomtype( "favela_ext0", 			"city" );
	set_reverb_drylevel( "favela_ext0", 			0.9 );
	set_reverb_wetlevel( "favela_ext0", 			0.15 );
	set_reverb_fadetime( "favela_ext0", 			6 );
	set_reverb_priority( "favela_ext0", 			"snd_enveffectsprio_level" );

	define_reverb( "favela_takedown_ext" );
	set_reverb_roomtype( "favela_takedown_ext", 			"city" );
	set_reverb_drylevel( "favela_takedown_ext", 			0.9 );
	set_reverb_wetlevel( "favela_takedown_ext", 			0.15 );
	set_reverb_fadetime( "favela_takedown_ext", 			6 );
	set_reverb_priority( "favela_takedown_ext", 			"snd_enveffectsprio_level" );

	define_reverb( "favela_int0" );
	set_reverb_roomtype( "favela_int0", 	"livingroom" );
	set_reverb_drylevel( "favela_int0", 	0.9 );
	set_reverb_wetlevel( "favela_int0", 	0.1 );
	set_reverb_fadetime( "favela_int0", 	2 );
	set_reverb_priority( "favela_int0", 	"snd_enveffectsprio_level" );

	define_reverb( "favela_takedown_int" );
	set_reverb_roomtype( "favela_takedown_int", 	"hallway" );
	set_reverb_drylevel( "favela_takedown_int", 	1.0 );
	set_reverb_wetlevel( "favela_takedown_int", 	0.0 );
	set_reverb_fadetime( "favela_takedown_int", 	2 );
	set_reverb_priority( "favela_takedown_int", 	"snd_enveffectsprio_level" );

	define_reverb( "favela_int_shanty0" );
	set_reverb_roomtype( "favela_int_shanty0", 	"livingroom" );
	set_reverb_drylevel( "favela_int_shanty0", 	0.9 );
	set_reverb_wetlevel( "favela_int_shanty0", 	0.1 );
	set_reverb_fadetime( "favela_int_shanty0", 	2 );
	set_reverb_priority( "favela_int_shanty0", 	"snd_enveffectsprio_level" );

	define_reverb( "favela_escape_ext0" );
	set_reverb_roomtype( "favela_escape_ext0", 			"city" );
	set_reverb_drylevel( "favela_escape_ext0", 			0.9 );
	set_reverb_wetlevel( "favela_escape_ext0", 			0.15 );
	set_reverb_fadetime( "favela_escape_ext0", 			6 );
	set_reverb_priority( "favela_escape_ext0", 			"snd_enveffectsprio_level" );

	define_reverb( "forrest" );
	set_reverb_roomtype( "forrest", 		"forest" );
	set_reverb_drylevel( "forrest", 		0.9 );
	set_reverb_wetlevel( "forrest", 		0.1 );
	set_reverb_fadetime( "forrest", 		2 );
	set_reverb_priority( "forrest", 		"snd_enveffectsprio_level" );

	define_reverb( "ambient_gulag_ext0" );
	set_reverb_roomtype( "ambient_gulag_ext0", 		"city" );
	set_reverb_drylevel( "ambient_gulag_ext0", 		0.95 );
	set_reverb_wetlevel( "ambient_gulag_ext0", 		0.15 );
	set_reverb_fadetime( "ambient_gulag_ext0", 		2 );
	set_reverb_priority( "ambient_gulag_ext0", 		"snd_enveffectsprio_level" );

	define_reverb( "gulag_hall_int0" );
	set_reverb_roomtype( "gulag_hall_int0", 		"sewerpipe" );
	set_reverb_drylevel( "gulag_hall_int0", 		0.95 );
	set_reverb_wetlevel( "gulag_hall_int0", 		0.15 );
	set_reverb_fadetime( "gulag_hall_int0", 		2 );
	set_reverb_priority( "gulag_hall_int0", 		"snd_enveffectsprio_level" );

	define_reverb( "gulag_shower_int0" );
	set_reverb_roomtype( "gulag_shower_int0", 		"bathroom" );
	set_reverb_drylevel( "gulag_shower_int0", 		0.9 );
	set_reverb_wetlevel( "gulag_shower_int0", 		0.2 );
	set_reverb_fadetime( "gulag_shower_int0", 		2 );
	set_reverb_priority( "gulag_shower_int0", 		"snd_enveffectsprio_level" );

	define_reverb( "gulag_exit" );
	set_reverb_roomtype( "gulag_exit", 		"sewerpipe" );
	set_reverb_drylevel( "gulag_exit", 		0.95 );
	set_reverb_wetlevel( "gulag_exit", 		0.15 );
	set_reverb_fadetime( "gulag_exit", 		2 );
	set_reverb_priority( "gulag_exit", 		"snd_enveffectsprio_level" );

	define_reverb( "hangar" );
	set_reverb_roomtype( "hangar", 	 	"hangar" );
	set_reverb_drylevel( "hangar", 		0.6 );
	set_reverb_wetlevel( "hangar", 		0.5 );
	set_reverb_fadetime( "hangar", 		4 );
	set_reverb_priority( "hangar", 		"snd_enveffectsprio_level" );

	define_reverb( "interior" );
	set_reverb_roomtype( "interior", 	 	"stonecorridor" );
	set_reverb_drylevel( "interior", 		0.9 );
	set_reverb_wetlevel( "interior", 		0.3 );
	set_reverb_fadetime( "interior", 		2 );
	set_reverb_priority( "interior", 		"snd_enveffectsprio_level" );

	define_reverb( "interior_metal" );
	set_reverb_roomtype( "interior_metal", 	"sewerpipe" );
	set_reverb_drylevel( "interior_metal", 	0.8 );
	set_reverb_wetlevel( "interior_metal", 	0.3 );
	set_reverb_fadetime( "interior_metal", 	2 );
	set_reverb_priority( "interior_metal", 	"snd_enveffectsprio_level" );

	define_reverb( "interior_stone" );
	set_reverb_roomtype( "interior_stone", 	"stoneroom" );
	set_reverb_drylevel( "interior_stone", 	0.9 );
	set_reverb_wetlevel( "interior_stone", 	0.2 );
	set_reverb_fadetime( "interior_stone", 	2 );
	set_reverb_priority( "interior_stone", 	"snd_enveffectsprio_level" );

	define_reverb( "interior_vehicle" );
	set_reverb_roomtype( "interior_vehicle", 	"carpetedhallway" );
	set_reverb_drylevel( "interior_vehicle", 	0.9 );
	set_reverb_wetlevel( "interior_vehicle", 	0.1 );
	set_reverb_fadetime( "interior_vehicle", 	2 );
	set_reverb_priority( "interior_vehicle", 	"snd_enveffectsprio_level" );

	define_reverb( "interior_wood" );
	set_reverb_roomtype( "interior_wood", 	"livingroom" );
	set_reverb_drylevel( "interior_wood", 	0.9 );
	set_reverb_wetlevel( "interior_wood", 	0.2 );
	set_reverb_fadetime( "interior_wood", 	2 );
	set_reverb_priority( "interior_wood", 	"snd_enveffectsprio_level" );

	define_reverb( "invasion_ext1" );
	set_reverb_roomtype( "invasion_ext1", 			"parkinglot" );
	set_reverb_drylevel( "invasion_ext1", 			0.9 );
	set_reverb_wetlevel( "invasion_ext1", 			0.2 );
	set_reverb_fadetime( "invasion_ext1", 			3 );
	set_reverb_priority( "invasion_ext1", 			"snd_enveffectsprio_level" );

	define_reverb( "invasion_ext3" );
	set_reverb_roomtype( "invasion_ext3", 			"parkinglot" );
	set_reverb_drylevel( "invasion_ext3", 			0.9 );
	set_reverb_wetlevel( "invasion_ext3", 			0.2 );
	set_reverb_fadetime( "invasion_ext3", 			3 );
	set_reverb_priority( "invasion_ext3", 			"snd_enveffectsprio_level" );

	define_reverb( "mountains" );
	set_reverb_roomtype( "mountains", 		"mountains" );
	set_reverb_drylevel( "mountains", 		0.8 );
	set_reverb_wetlevel( "mountains", 		0.3 );
	set_reverb_fadetime( "mountains", 		2 );
	set_reverb_priority( "mountains", 		"snd_enveffectsprio_level" );

	define_reverb( "amb_underwater_test1v1" );
	set_reverb_roomtype( "amb_underwater_test1v1", 			"underwater" );
	set_reverb_drylevel( "amb_underwater_test1v1", 			0.5 );
	set_reverb_wetlevel( "amb_underwater_test1v1", 			0.6 );
	set_reverb_fadetime( "amb_underwater_test1v1", 			2 );
	set_reverb_priority( "amb_underwater_test1v1", 			"snd_enveffectsprio_level" );


	define_reverb( "underwater" );
	set_reverb_roomtype( "underwater", 			"underwater" );
	set_reverb_drylevel( "underwater", 			0.5 );
	set_reverb_wetlevel( "underwater", 			0.6 );
	set_reverb_fadetime( "underwater", 			2 );
	set_reverb_priority( "underwater", 			"snd_enveffectsprio_level" );
	
	define_reverb( "ambient_oilrig_test_ext1" );
	set_reverb_roomtype( "ambient_oilrig_test_ext1", 			"city" );
	set_reverb_drylevel( "ambient_oilrig_test_ext1", 			0.9 );
	set_reverb_wetlevel( "ambient_oilrig_test_ext1", 			0.15 );
	set_reverb_fadetime( "ambient_oilrig_test_ext1", 			6 );
	set_reverb_priority( "ambient_oilrig_test_ext1", 			"snd_enveffectsprio_level" );
	
	define_reverb( "ambient_oilrig_int1" );
	set_reverb_roomtype( "ambient_oilrig_int1", 			"city" );
	set_reverb_drylevel( "ambient_oilrig_int1", 			0.9 );
	set_reverb_wetlevel( "ambient_oilrig_int1", 			0.15 );
	set_reverb_fadetime( "ambient_oilrig_int1", 			6 );
	set_reverb_priority( "ambient_oilrig_int1", 			"snd_enveffectsprio_level" );

	define_reverb( "pipe" );
	set_reverb_roomtype( "pipe", 			"sewerpipe" );
	set_reverb_drylevel( "pipe", 			0.9 );
	set_reverb_wetlevel( "pipe", 			0.4 );
	set_reverb_fadetime( "pipe", 			2 );
	set_reverb_priority( "pipe", 			"snd_enveffectsprio_level" );

	define_reverb( "shanty" );
	set_reverb_roomtype( "shanty", 		"livingroom" );
	set_reverb_drylevel( "shanty", 		0.9 );
	set_reverb_wetlevel( "shanty", 		0.1 );
	set_reverb_fadetime( "shanty", 		2 );
	set_reverb_priority( "shanty", 		"snd_enveffectsprio_level" );

	define_reverb( "snow_base" );
	set_reverb_roomtype( "snow_base", 		"mountains" );
	set_reverb_drylevel( "snow_base", 		0.7 );
	set_reverb_wetlevel( "snow_base", 		0.4 );
	set_reverb_fadetime( "snow_base", 		5 );
	set_reverb_priority( "snow_base", 		"snd_enveffectsprio_level" );

	define_reverb( "snow_base_white" );
	set_reverb_roomtype( "snow_base_white", 		"mountains" );
	set_reverb_drylevel( "snow_base_white", 		0.7 );
	set_reverb_wetlevel( "snow_base_white", 		0.4 );
	set_reverb_fadetime( "snow_base_white", 		5 );
	set_reverb_priority( "snow_base_white", 		"snd_enveffectsprio_level" );

	define_reverb( "snow_cliff" );
	set_reverb_roomtype( "snow_cliff", 		"mountains" );
	set_reverb_drylevel( "snow_cliff", 		0.7 );
	set_reverb_wetlevel( "snow_cliff", 		0.4 );
	set_reverb_fadetime( "snow_cliff", 		5 );
	set_reverb_priority( "snow_cliff", 		"snd_enveffectsprio_level" );

	define_reverb( "underpass" );
	set_reverb_roomtype( "underpass", 		"stonecorridor" );
	set_reverb_drylevel( "underpass", 		0.9 );
	set_reverb_wetlevel( "underpass", 		0.3 );
	set_reverb_fadetime( "underpass", 		2 );
	set_reverb_priority( "underpass", 		"snd_enveffectsprio_level" );

	define_reverb( "tunnel" );
	set_reverb_roomtype( "tunnel", 		"cave" );
	set_reverb_drylevel( "tunnel", 		0.85 );
	set_reverb_wetlevel( "tunnel", 		0.35 );
	set_reverb_fadetime( "tunnel", 		2 );
	set_reverb_priority( "tunnel", 		"snd_enveffectsprio_level" );

        define_reverb( "alldrynowet" );
	set_reverb_roomtype( "alldrynowet", 		"plain" );
	set_reverb_drylevel( "alldrynowet", 		1.0 );
	set_reverb_wetlevel( "alldrynowet", 		0.0 );
	set_reverb_fadetime( "alldrynowet", 		4 );
	set_reverb_priority( "alldrynowet", 		"snd_enveffectsprio_level" );

    define_reverb( "wh1" );
	set_reverb_roomtype( "wh1", 		"warehouse1" );
	set_reverb_drylevel( "wh1", 		0.0 );  //0.9
	set_reverb_wetlevel( "wh1", 		1.0 ); //0.65
	set_reverb_fadetime( "wh1", 		0.0 );
	set_reverb_priority( "wh1", 		"snd_enveffectsprio_level" );


	define_reverb( "smroom" );
	set_reverb_roomtype( "smroom", 		"smallroom1" );
	set_reverb_drylevel( "smroom", 		0.9 );
	set_reverb_wetlevel( "smroom", 		0.2 );
	set_reverb_fadetime( "smroom", 		0.0 );
	set_reverb_priority( "smroom", 		"snd_enveffectsprio_level" );



// ***********************************************************


	define_filter( "deathsdoor" );
	set_filter_type( "deathsdoor", 0, 			"highshelf" );
	set_filter_freq( "deathsdoor", 0, 			2800 );
	set_filter_gain( "deathsdoor", 0, 			 - 12 );
	set_filter_q( "deathsdoor", 0, 			1 );
	set_filter_type( "deathsdoor", 1, 			"lowshelf" );
	set_filter_freq( "deathsdoor", 1, 			1000 );
	set_filter_gain( "deathsdoor", 1, 			 - 6 );
	set_filter_q( "deathsdoor", 1, 			1 );
	add_channel_to_filter( "deathsdoor", 		"physics" );
	add_channel_to_filter( "deathsdoor", 		"ambdist1" );
	add_channel_to_filter( "deathsdoor", 		"ambdist2" );
	add_channel_to_filter( "deathsdoor", 		"auto" );
	add_channel_to_filter( "deathsdoor", 		"auto2" );
	add_channel_to_filter( "deathsdoor", 		"element" );
	add_channel_to_filter( "deathsdoor", 		"vehicle" );
	add_channel_to_filter( "deathsdoor", 		"vehiclelimited" );
	add_channel_to_filter( "deathsdoor", 		"body" );
	add_channel_to_filter( "deathsdoor", 		"reload" );
	add_channel_to_filter( "deathsdoor", 		"effects1" );
	add_channel_to_filter( "deathsdoor", 		"effects2" );
	add_channel_to_filter( "deathsdoor", 		"weapon" );
	add_channel_to_filter( "deathsdoor", 		"voice" );

	define_filter( "miniuav" );
	set_filter_type( "miniuav", 0, 			"highshelf" );
	set_filter_freq( "miniuav", 0, 			2500 );
	set_filter_gain( "miniuav", 0, 			 - 18 );
	set_filter_q( "miniuav", 0, 			1 );
	set_filter_type( "miniuav", 1, 			"lowshelf" );
	set_filter_freq( "miniuav", 1, 			500 );
	set_filter_gain( "miniuav", 1, 			 - 6 );
	set_filter_q( "miniuav", 1, 			1 );
	add_all_channels_but_music_and_ambient( "miniuav" );

	define_filter( "underwater" );
	set_filter_type( "underwater", 1, 			"lowpass" );
	set_filter_freq( "underwater", 1, 			350 );
	set_filter_gain( "underwater", 1, 			 - 6 );
	set_filter_q( "underwater", 1, 			1 );
	add_all_channels_but_music_and_ambient( "underwater" );

	define_filter( "none" );
	set_filter_type( "none", 1, 			"lowshelf" );
	set_filter_freq( "none", 1, 			500 );
	set_filter_gain( "none", 1, 			 0 );
	set_filter_q( "none", 1, 			1 );
	add_all_channels_but_music_and_ambient( "none" );

	define_filter( "ac130" );
	set_filter_type( "ac130", 0, 			"highshelf" );
	set_filter_freq( "ac130", 0, 			2800 );
	set_filter_gain( "ac130", 0, 			 - 12 );
	set_filter_q( "ac130", 0, 			1 );
	set_filter_type( "ac130", 1, 			"lowshelf" );
	set_filter_freq( "ac130", 1, 			1000 );
	set_filter_gain( "ac130", 1, 			 - 6 );
	set_filter_q( "ac130", 1, 			1 );
	add_channel_to_filter( "ac130", 		"auto" );
	add_channel_to_filter( "ac130", 		 "auto2" );
//	add_channel_to_filter( "ac130", 		"effects1" );
	add_channel_to_filter( "ac130", 		 "effects2" );
	add_channel_to_filter( "ac130", 		 "vehicle" );
	add_channel_to_filter( "ac130", 		"weapon" );
		
	define_filter( "space" );
	set_filter_type( "space", 0, 			"highpass" );
	set_filter_freq( "space", 0, 			80 );
	set_filter_gain( "space", 0, 			 1.0 );
	set_filter_q( "space", 0, 			1.0 );
	set_filter_type( "space", 1, 			"lowpass" );
	set_filter_freq( "space", 1, 			250 );
	set_filter_gain( "space", 1, 			 1 );
	set_filter_q( "space", 1, 			1 );
	add_channel_to_filter( "space", 		"auto" );
	add_channel_to_filter( "space", 		 "auto2" );
        add_channel_to_filter( "space",                 "auto2d" );
        add_channel_to_filter( "space",                 "item" );
	add_channel_to_filter( "space", 		"effects1" );
	add_channel_to_filter( "space", 		 "effects2" );
	add_channel_to_filter( "space", 		 "vehicle" );
        add_channel_to_filter( "space",                 "vehiclelimited" );
	add_channel_to_filter( "space", 		"weapon" );
	add_channel_to_filter( "space", 		"local" );
	add_channel_to_filter( "space", 		"local2" );
        add_channel_to_filter( "space", 		"physics" );
        add_channel_to_filter( "space", 		"ambdist1" );
        add_channel_to_filter( "space", 		"ambdist2" );
        add_channel_to_filter( "space", 		"element" );
        add_channel_to_filter( "space", 		"reload" );
        add_channel_to_filter( "space", 		"body" );
        add_channel_to_filter( "space", 		"voice" );
        add_channel_to_filter( "space", 		"ambient" );
        add_channel_to_filter( "space", 	        "bulletwhizby" );
        add_channel_to_filter( "space", 		"bulletimpact" );
        add_channel_to_filter( "space", 		"vehiclelimited" );
        add_channel_to_filter( "space", 		"menu" );
        add_channel_to_filter( "space", 		"body2d" );
        add_channel_to_filter( "space", 		"reload2d" );
        add_channel_to_filter( "space", 		"weapon2d" );
        add_channel_to_filter( "space", 		"nonshock" );
        add_channel_to_filter( "space", 		"local3" );
        add_channel_to_filter( "space", 		"hurt" );
        add_channel_to_filter( "space", 		"player1" );
        add_channel_to_filter( "space", 		"player2" );
        add_channel_to_filter( "space", 		"mission" );
        add_channel_to_filter( "space", 		"announcer" );
        add_channel_to_filter( "space", 		"shellshock" );
	
	define_filter( "nx_repel_osp" );
	set_filter_type( "nx_repel_osp", 0, 		"lowpass" );
	set_filter_freq( "nx_repel_osp", 0, 		0 );
	set_filter_gain( "nx_repel_osp", 0, 		 0 );
	set_filter_q( "nx_repel_osp", 0, 			1 );
	add_channel_to_filter( "nx_repel_osp", 		"physics" );
	add_channel_to_filter( "nx_repel_osp", 		"ambdist1" );
	add_channel_to_filter( "nx_repel_osp", 		"ambdist2" );
	add_channel_to_filter( "nx_repel_osp", 		"auto" );
	add_channel_to_filter( "nx_repel_osp", 		"auto2" );
	add_channel_to_filter( "nx_repel_osp", 		"bulletimpact" );
	add_channel_to_filter( "nx_repel_osp", 		"bulletwhizby" );
	add_channel_to_filter( "nx_repel_osp", 		"element" );
	add_channel_to_filter( "nx_repel_osp", 		"vehicle" );
	add_channel_to_filter( "nx_repel_osp", 		"vehiclelimited" );
	add_channel_to_filter( "nx_repel_osp", 		"body" );
	add_channel_to_filter( "nx_repel_osp", 		"body2d" );
	add_channel_to_filter( "nx_repel_osp", 		"reload" );
	add_channel_to_filter( "nx_repel_osp", 		"reload2d" );
	add_channel_to_filter( "nx_repel_osp", 		"item" );
	add_channel_to_filter( "nx_repel_osp", 		"effects1" );
	add_channel_to_filter( "nx_repel_osp", 		"effects2" );
	add_channel_to_filter( "nx_repel_osp", 		"weapon" );
	add_channel_to_filter( "nx_repel_osp", 		"weapon2d" );
	add_channel_to_filter( "nx_repel_osp", 		"nonshock" );
	add_channel_to_filter( "nx_repel_osp", 		"local" );
	add_channel_to_filter( "nx_repel_osp", 		"local2" );
	add_channel_to_filter( "nx_repel_osp", 		"local3" );
	add_channel_to_filter( "nx_repel_osp", 		"ambient" );
	add_channel_to_filter( "nx_repel_osp", 		"hurt" );
	add_channel_to_filter( "nx_repel_osp", 		"player1" );
	add_channel_to_filter( "nx_repel_osp", 		"player2" );
	add_channel_to_filter( "nx_repel_osp", 		"musicnopause" );
	add_channel_to_filter( "nx_repel_osp", 		"mission" );
	add_channel_to_filter( "nx_repel_osp", 		"shellshock" );
	add_channel_to_filter( "nx_repel_osp", 		"nx_localR" );
	add_channel_to_filter( "nx_repel_osp", 		"nx_local2R" );
	add_channel_to_filter( "nx_repel_osp", 		"nx_localverb" );
	add_channel_to_filter( "nx_repel_osp", 		"nx_localverbR" );
	add_channel_to_filter( "nx_repel_osp", 		"nx_verb3d" );

	define_filter( "nx_repel_ext" );
	set_filter_type( "nx_repel_ext", 0, 		"highshelf" );
	set_filter_freq( "nx_repel_ext", 0, 		200 );
	set_filter_gain( "nx_repel_ext", 0, 		 0 );
	set_filter_q( "nx_repel_ext", 0, 			1 );
	add_channel_to_filter( "nx_repel_ext", 		"physics" );
	add_channel_to_filter( "nx_repel_ext", 		"ambdist1" );
	add_channel_to_filter( "nx_repel_ext", 		"ambdist2" );
	add_channel_to_filter( "nx_repel_ext", 		"auto" );
	add_channel_to_filter( "nx_repel_ext", 		"auto2" );
	add_channel_to_filter( "nx_repel_ext", 		"bulletimpact" );
	add_channel_to_filter( "nx_repel_ext", 		"bulletwhizby" );
	add_channel_to_filter( "nx_repel_ext", 		"element" );
	add_channel_to_filter( "nx_repel_ext", 		"auto2d" );
	add_channel_to_filter( "nx_repel_ext", 		"vehicle" );
	add_channel_to_filter( "nx_repel_ext", 		"vehiclelimited" );
	add_channel_to_filter( "nx_repel_ext", 		"body" );
	add_channel_to_filter( "nx_repel_ext", 		"body2d" );
	add_channel_to_filter( "nx_repel_ext", 		"reload" );
	add_channel_to_filter( "nx_repel_ext", 		"reload2d" );
	add_channel_to_filter( "nx_repel_ext", 		"item" );
	add_channel_to_filter( "nx_repel_ext", 		"effects1" );
	add_channel_to_filter( "nx_repel_ext", 		"effects2" );
	add_channel_to_filter( "nx_repel_ext", 		"weapon" );
	add_channel_to_filter( "nx_repel_ext", 		"weapon2d" );
	add_channel_to_filter( "nx_repel_ext", 		"nonshock" );
	add_channel_to_filter( "nx_repel_ext", 		"local" );
	add_channel_to_filter( "nx_repel_ext", 		"local2" );
	add_channel_to_filter( "nx_repel_ext", 		"local3" );
	add_channel_to_filter( "nx_repel_ext", 		"ambient" );
	add_channel_to_filter( "nx_repel_ext", 		"hurt" );
	add_channel_to_filter( "nx_repel_ext", 		"player1" );
	add_channel_to_filter( "nx_repel_ext", 		"player2" );
	add_channel_to_filter( "nx_repel_ext", 		"musicnopause" );
	add_channel_to_filter( "nx_repel_ext", 		"mission" );
	add_channel_to_filter( "nx_repel_ext", 		"shellshock" );
	add_channel_to_filter( "nx_repel_ext", 		"nx_localR" );
	add_channel_to_filter( "nx_repel_ext", 		"nx_local2R" );
	add_channel_to_filter( "nx_repel_ext", 		"nx_localverb" );
	add_channel_to_filter( "nx_repel_ext", 		"nx_localverbR" );
	add_channel_to_filter( "nx_repel_ext", 		"nx_verb3d" );

	define_filter( "nx_subpen_int" );
	set_filter_type( "nx_subpen_int", 0, 			"lowpass" );
	set_filter_freq( "nx_subpen_int", 0, 			3000 );
	set_filter_gain( "nx_subpen_int", 0, 			 - 12 );
	set_filter_q( "nx_subpen_int", 0, 			1 );
	add_channel_to_filter( "nx_subpen_int", 		"ambient" );
	add_channel_to_filter( "nx_subpen_int", 		 "element" );

	define_filter( "af_caves_int" );
	set_filter_type( "af_caves_int", 0, 			"highshelf" );
	set_filter_freq( "af_caves_int", 0, 			5500 );
	set_filter_gain( "af_caves_int", 0, 			 - 12 );
	set_filter_q( "af_caves_int", 0, 			1 );
	add_channel_to_filter( "af_caves_int", 		"ambient" );
	add_channel_to_filter( "af_caves_int", 		"element" );
	add_channel_to_filter( "af_caves_int", 		 "vehicle" );
	add_channel_to_filter( "af_caves_int", 		"weapon" );
	add_channel_to_filter( "af_caves_int", 		"voice" );

	define_filter( "nx_harbor_train_tunnel_int" );
	set_filter_type( "nx_harbor_train_tunnel_int", 0, 			"highshelf" );
	set_filter_freq( "nx_harbor_train_tunnel_int", 0, 			8500 );
	set_filter_gain( "nx_harbor_train_tunnel_int", 0, 			 - 12 );
	set_filter_q( "nx_harbor_train_tunnel_int", 0, 			1 );
	add_channel_to_filter( "nx_harbor_train_tunnel_int", 		 "vehicle" );
	add_channel_to_filter( "nx_harbor_train_tunnel_int", 		"weapon" );
	add_channel_to_filter( "nx_harbor_train_tunnel_int", 		"voice" );


	define_filter( "amb_skyscraper_city_drive_up_ext" );
	set_filter_type( "amb_skyscraper_city_drive_up_ext", 0, 			"lowpass" );
	set_filter_freq( "amb_skyscraper_city_drive_up_ext", 0, 			1600 );
	set_filter_gain( "amb_skyscraper_city_drive_up_ext", 0, 			 - 0 );
	set_filter_q( "amb_skyscraper_city_drive_up_ext", 0, 			1 );
	add_channel_to_filter( "amb_skyscraper_city_drive_up_ext", 		 "vehicle" );

	define_filter( "lunar_depressurized" );
	set_filter_type( "lunar_depressurized", 0, 	"lowpass" );
	set_filter_freq( "lunar_depressurized", 0, 	1900 );
	set_filter_gain( "lunar_depressurized", 0, 	0 );
	set_filter_q( "lunar_depressurized", 0, 		1 );
	add_channel_to_filter( "lunar_depressurized", "physics" );
	add_channel_to_filter( "lunar_depressurized", "ambdist1" );
	add_channel_to_filter( "lunar_depressurized", "ambdist2" );
	add_channel_to_filter( "lunar_depressurized", "auto" );
	add_channel_to_filter( "lunar_depressurized", 		"auto2" );
	add_channel_to_filter( "lunar_depressurized", "bulletimpact" );
	add_channel_to_filter( "lunar_depressurized", "bulletwhizby" );
	add_channel_to_filter( "lunar_depressurized", "element" );
	add_channel_to_filter( "lunar_depressurized", 		"vehicle" );
	add_channel_to_filter( "lunar_depressurized", "vehiclelimited" );
	add_channel_to_filter( "lunar_depressurized", "body" );
	add_channel_to_filter( "lunar_depressurized", "reload" );
	add_channel_to_filter( "lunar_depressurized", 		"reload2d" );
	add_channel_to_filter( "lunar_depressurized", "item" );
	add_channel_to_filter( "lunar_depressurized", "effects1" );
	add_channel_to_filter( "lunar_depressurized", "effects2" );
	add_channel_to_filter( "lunar_depressurized", "weapon" );
	add_channel_to_filter( "lunar_depressurized", "nonshock" );
	add_channel_to_filter( "lunar_depressurized", 		"ambient" );
	add_channel_to_filter( "lunar_depressurized", 		"hurt" );
	add_channel_to_filter( "lunar_depressurized", 		"player1" );
	add_channel_to_filter( "lunar_depressurized", 		"player2" );

	define_filter( "lunar_pressurized" );
	set_filter_type( "lunar_pressurized", 0, 		"lowpass" );
	set_filter_freq( "lunar_pressurized", 0, 		20000 );
	set_filter_gain( "lunar_pressurized", 0, 		0 );
	set_filter_q( "lunar_pressurized", 0, 			0.2 );
	add_channel_to_filter( "lunar_pressurized", 		"physics" );
	add_channel_to_filter( "lunar_pressurized", 		"ambdist1" );
	add_channel_to_filter( "lunar_pressurized", 		"ambdist2" );
	add_channel_to_filter( "lunar_pressurized", 		"auto" );
	add_channel_to_filter( "lunar_pressurized", 		"auto2" );
	add_channel_to_filter( "lunar_pressurized", 		"bulletimpact" );
	add_channel_to_filter( "lunar_pressurized", 		"bulletwhizby" );
	add_channel_to_filter( "lunar_pressurized", 		"element" );
	add_channel_to_filter( "lunar_pressurized", 		"auto2d" );
	add_channel_to_filter( "lunar_pressurized", 		"vehicle" );
	add_channel_to_filter( "lunar_pressurized", 		"vehiclelimited" );
	add_channel_to_filter( "lunar_pressurized", 		"body" );
	add_channel_to_filter( "lunar_pressurized", 		"body2d" );
	add_channel_to_filter( "lunar_pressurized", 		"reload" );
	add_channel_to_filter( "lunar_pressurized", 		"reload2d" );
	add_channel_to_filter( "lunar_pressurized", 		"item" );
	add_channel_to_filter( "lunar_pressurized", 		"effects1" );
	add_channel_to_filter( "lunar_pressurized", 		"effects2" );
	add_channel_to_filter( "lunar_pressurized", 		"weapon" );
	add_channel_to_filter( "lunar_pressurized", 		"weapon2d" );
	add_channel_to_filter( "lunar_pressurized", 		"nonshock" );
	add_channel_to_filter( "lunar_pressurized", 		"local" );
	add_channel_to_filter( "lunar_pressurized", 		"local2" );
	add_channel_to_filter( "lunar_pressurized", 		"local3" );
	add_channel_to_filter( "lunar_pressurized", 		"ambient" );
	add_channel_to_filter( "lunar_pressurized", 		"hurt" );
	add_channel_to_filter( "lunar_pressurized", 		"player1" );
	add_channel_to_filter( "lunar_pressurized", 		"player2" );
	add_channel_to_filter( "lunar_pressurized", 		"musicnopause" );
	add_channel_to_filter( "lunar_pressurized", 		"mission" );
	add_channel_to_filter( "lunar_pressurized", 		"announcer" );
	add_channel_to_filter( "lunar_pressurized", 		"shellshock" );
	add_channel_to_filter( "lunar_pressurized", 		"nx_localR" );
	add_channel_to_filter( "lunar_pressurized", 		"nx_local2R" );
	add_channel_to_filter( "lunar_pressurized", 			"nx_localverb" );
	add_channel_to_filter( "lunar_pressurized", 		"nx_localverbR" );
	add_channel_to_filter( "lunar_pressurized", 			"nx_verb3d" );
	add_channel_to_filter( "lunar_pressurized", 		"voice" );


	define_filter( "airport_basement0" );
	set_filter_type( "airport_basement0", 0, 			"highshelf" );
	set_filter_freq( "airport_basement0", 0, 			7500 );
	set_filter_gain( "airport_basement0", 0, 			 - 12 );
	set_filter_q( "airport_basement0", 0, 			1 );
	add_channel_to_filter( "airport_basement0", 		"ambient" );
	add_channel_to_filter( "airport_basement0", 		"element" );
	add_channel_to_filter( "airport_basement0", 		 "vehicle" );
	add_channel_to_filter( "airport_basement0", 		"weapon" );
	add_channel_to_filter( "airport_basement0", 		"voice" );

	define_filter( "airport_terminal0" );
	set_filter_type( "airport_terminal0", 0, 			"highshelf" );
	set_filter_freq( "airport_terminal0", 0, 			7500 );
	set_filter_gain( "airport_terminal0", 0, 			 - 8 );
	set_filter_q( "airport_terminal0", 0, 			1 );
	add_channel_to_filter( "airport_terminal0", 		"ambient" );
	add_channel_to_filter( "airport_terminal0", 		"element" );
	add_channel_to_filter( "airport_terminal0", 		 "vehicle" );
	add_channel_to_filter( "aairport_terminal0", 		"weapon" );
	add_channel_to_filter( "airport_terminal0", 		"voice" );

	define_filter( "nx_ss_shaft_elevator_int" );
	set_filter_type( "nx_ss_shaft_elevator_int", 0, 			"lowpass" );
	set_filter_freq( "nx_ss_shaft_elevator_int", 0, 			20 );
	set_filter_gain( "nx_ss_shaft_elevator_int", 0, 			 - 12 );
	set_filter_q( "nx_ss_shaft_elevator_int", 0, 			1 );
	add_channel_to_filter( "nx_ss_shaft_elevator_int", 		"auto" );
	add_channel_to_filter( "nx_ss_shaft_elevator_int", 		"effects2" );

	define_filter( "nx_ss_shaft_elevator_freight_shaft" );
	set_filter_type( "nx_ss_shaft_elevator_freight_shaft", 0, 			"highshelf" );
	set_filter_freq( "nx_ss_shaft_elevator_freight_shaft", 0, 			8000 );
	set_filter_gain( "nx_ss_shaft_elevator_freight_shaft", 0, 			 - 9 );
	set_filter_q( "nx_ss_shaft_elevator_freight_shaft", 0, 			1 );
	add_channel_to_filter( "nx_ss_shaft_elevator_freight_shaft", 		"auto" );
	add_channel_to_filter( "nx_ss_shaft_elevator_freight_shaft", 		"effects2" );

	define_filter( "alley" );
	set_filter_type( "alley", 0, 			"highshelf" );
	set_filter_freq( "alley", 0, 			3500 );
	set_filter_gain( "alley", 0, 			 - 2 );
	set_filter_q( "alley", 0, 			1 );
	add_channel_to_filter( "alley", 		"ambient" );
	add_channel_to_filter( "alley", 		"element" );
	add_channel_to_filter( "alley", 		"vehicle" );
	add_channel_to_filter( "alley", 		 "weapon" );
	add_channel_to_filter( "alley", 		"voice" );

	define_filter( "bunker" );
	set_filter_type( "bunker", 0, 		"highshelf" );
	set_filter_freq( "bunker", 0, 		3500 );
	set_filter_gain( "bunker", 0, 		 - 2 );
	set_filter_q( "bunker", 0, 			1 );
	add_channel_to_filter( "bunker", 		"ambient" );
	add_channel_to_filter( "bunker", 		"element" );
	add_channel_to_filter( "bunker", 		"vehicle" );
	add_channel_to_filter( "bunker", 		"weapon" );
	add_channel_to_filter( "bunker", 		"voice" );

	define_filter( "container" );
	set_filter_type( "container", 0, 		"highshelf" );
	set_filter_freq( "container", 0, 		3500 );
	set_filter_gain( "container", 0, 		 - 6 );
	set_filter_q( "container", 0, 		1 );
	add_channel_to_filter( "container", 		"ambient" );
	add_channel_to_filter( "container", 	"element" );
	add_channel_to_filter( "container", 		 "vehicle" );
	add_channel_to_filter( "container", 	"weapon" );
	add_channel_to_filter( "container", 	"voice" );
	
	define_filter( "dcemp_dry_int" );
	set_filter_type( "dcemp_dry_int", 0, 			"highshelf" );
	set_filter_freq( "dcemp_dry_int", 0, 			6500 );
	set_filter_gain( "dcemp_dry_int", 0, 			 - 15 );
	set_filter_q( "dcemp_dry_int", 0, 			1 );
	add_channel_to_filter( "dcemp_dry_int", 		"ambient" );
	add_channel_to_filter( "dcemp_dry_int", 		"element" );
	add_channel_to_filter( "dcemp_dry_int", 		 "vehicle" );
	//add_channel_to_filter( "dcemp_dry_int", 		"weapon" );
	add_channel_to_filter( "dcemp_dry_int", 		"voice" );
	
	define_filter( "dcemp_light_rain_int" );
	set_filter_type( "dcemp_light_rain_int", 0, 			"highshelf" );
	set_filter_freq( "dcemp_light_rain_int", 0, 			5200 );
	set_filter_gain( "dcemp_light_rain_int", 0, 			 - 21 );
	set_filter_q( "dcemp_light_rain_int", 0, 			1 );
	add_channel_to_filter( "dcemp_light_rain_int", 		"ambient" );
	add_channel_to_filter( "dcemp_light_rain_int", 		"element" );
	add_channel_to_filter( "dcemp_light_rain_int", 		 "vehicle" );
	//add_channel_to_filter( "dcemp_light_rain_int", 		"weapon" );
	add_channel_to_filter( "dcemp_light_rain_int", 		"voice" );
	
	define_filter( "dcemp_heavy_rain_int" );
	set_filter_type( "dcemp_heavy_rain_int", 0, 			"highshelf" );
	set_filter_freq( "dcemp_heavy_rain_int", 0, 			4800 );
	set_filter_gain( "dcemp_heavy_rain_int", 0, 			 - 21 );
	set_filter_q( "dcemp_heavy_rain_int", 0, 			1 );
	set_filter_type( "dcemp_heavy_rain_int", 1, 			"lowshelf" );
	set_filter_freq( "dcemp_heavy_rain_int", 1, 			80 );
	set_filter_gain( "dcemp_heavy_rain_int", 1, 			 - 6 );
	set_filter_q( "dcemp_heavy_rain_int", 1, 			1 );
	add_channel_to_filter( "dcemp_heavy_rain_int", 		"ambient" );
	add_channel_to_filter( "dcemp_heavy_rain_int", 		"element" );
	add_channel_to_filter( "dcemp_heavy_rain_int", 		 "vehicle" );
	add_channel_to_filter( "dcemp_heavy_rain_int", 		"weapon" );
	add_channel_to_filter( "dcemp_heavy_rain_int", 		"voice" );
	
	define_filter( "dcemp_heavy_rain_tunnel" );
	set_filter_type( "dcemp_heavy_rain_tunnel", 0, 			"highshelf" );
	set_filter_freq( "dcemp_heavy_rain_tunnel", 0, 			3500 );
	set_filter_gain( "dcemp_heavy_rain_tunnel", 0, 			 - 21 );
	set_filter_q( "dcemp_heavy_rain_tunnel", 0, 			1 );
	set_filter_type( "dcemp_heavy_rain_tunnel", 1, 			"lowshelf" );
	set_filter_freq( "dcemp_heavy_rain_tunnel", 1, 			110 );
	set_filter_gain( "dcemp_heavy_rain_tunnel", 1, 			 - 6 );
	set_filter_q( "dcemp_heavy_rain_tunnel", 1, 			1 );
	add_channel_to_filter( "dcemp_heavy_rain_tunnel", 		"ambient" );
	add_channel_to_filter( "dcemp_heavy_rain_tunnel", 		"element" );
	add_channel_to_filter( "dcemp_heavy_rain_tunnel", 		"vehicle" );
	add_channel_to_filter( "dcemp_heavy_rain_tunnel", 		"weapon" );
	add_channel_to_filter( "dcemp_heavy_rain_tunnel", 		"voice" );

	define_filter( "favela_int0" );
	set_filter_type( "favela_int0", 0, 	"highshelf" );
	set_filter_freq( "favela_int0", 0, 	3500 );
	set_filter_gain( "favela_int0", 0, 	 - 10 );
	set_filter_q( "favela_int0", 0, 		1 );
	add_channel_to_filter( "favela_int0", 	"ambient" );
	add_channel_to_filter( "favela_int0", 	"element" );
	add_channel_to_filter( "favela_int0", 	"auto" );
	add_channel_to_filter( "favela_int0", 	"auto2" );
	add_channel_to_filter( "favela_int0", 	"vehicle" );
	add_channel_to_filter( "favela_int0", 	"weapon" );
	add_channel_to_filter( "favela_int0", 	"voice" );

        define_filter( "favela_takedown_int" );
	set_filter_type( "favela_takedown_int", 0, 	"lowpass" );
	set_filter_freq( "favela_takedown_int", 0, 	1300 );
	set_filter_gain( "favela_takedown_int", 0, 	 6.0 );
	set_filter_q( "favela_takedown_int", 0, 		1 );
//	add_channel_to_filter( "favela_takedown_int", 	"ambient" );
//	add_channel_to_filter( "favela_takedown_int", 	"element" );
	add_channel_to_filter( "favela_takedown_int", 	"vehicle" );
	add_channel_to_filter( "favela_takedown_int", 	"weapon" );
	add_channel_to_filter( "favela_takedown_int", 	"voice" );
	add_channel_to_filter( "favela_takedown_int", 	"body" );
//	add_channel_to_filter( "favela_takedown_int", 	"local" );
//	add_channel_to_filter( "favela_takedown_int", 	"local2" );
	add_channel_to_filter( "favela_takedown_int", 	"physics" );
	add_channel_to_filter( "favela_takedown_int", 	"effects1" );
	add_channel_to_filter( "favela_takedown_int", 	"effects2" );
	add_channel_to_filter( "favela_takedown_int", 	"bulletwhizby" );
	
	
        define_filter( "test_not_occluded" );
	set_filter_type( "test_not_occluded", 0, 	"lowpass" );
	set_filter_freq( "test_not_occluded", 0, 	20000 );
	set_filter_gain( "test_not_occluded", 0, 	 0.0 );
	set_filter_q( "test_not_occluded", 0, 		1 );
//	add_channel_to_filter( "test_not_occluded", 	"ambient" );
//	add_channel_to_filter( "test_not_occluded", 	"element" );
	add_channel_to_filter( "test_not_occluded", 	"vehicle" );
	add_channel_to_filter( "test_not_occluded", 	"weapon" );
	add_channel_to_filter( "test_not_occluded", 	"voice" );
	add_channel_to_filter( "test_not_occluded", 	"body" );
//	add_channel_to_filter( "test_not_occluded", 	"local" );
	add_channel_to_filter( "test_not_occluded", 	"item" );
	add_channel_to_filter( "test_not_occluded", 	"physics" );
	add_channel_to_filter( "test_not_occluded", 	"effects1" );
	add_channel_to_filter( "test_not_occluded", 	"effects2" );
	add_channel_to_filter( "test_not_occluded", 	"bulletwhizby" );
	
	
	
        define_filter( "test_partially_occluded" );
	set_filter_type( "test_partially_occluded", 0, 	"lowpass" );
	set_filter_freq( "test_partially_occluded", 0, 	2000 );
	set_filter_gain( "test_partially_occluded", 0, 	 0.0 );
	set_filter_q( "test_partially_occluded", 0, 		1 );
//	add_channel_to_filter( "test_partially_occluded", 	"ambient" );
//	add_channel_to_filter( "test_partially_occluded", 	"element" );
	add_channel_to_filter( "test_partially_occluded", 	"vehicle" );
	add_channel_to_filter( "test_partially_occluded", 	"weapon" );
	add_channel_to_filter( "test_partially_occluded", 	"voice" );
	add_channel_to_filter( "test_partially_occluded", 	"body" );
//	add_channel_to_filter( "test_partially_occluded", 	"local" );
	add_channel_to_filter( "test_partially_occluded", 	"item" );
	add_channel_to_filter( "test_partially_occluded", 	"physics" );
	add_channel_to_filter( "test_partially_occluded", 	"effects1" );
	add_channel_to_filter( "test_partially_occluded", 	"effects2" );
	add_channel_to_filter( "test_partially_occluded", 	"bulletwhizby" );
	
	
	
        define_filter( "test_fully_occluded" );
	set_filter_type( "test_fully_occluded", 0, 	"lowpass" );
	set_filter_freq( "test_fully_occluded", 0, 	500 );
	set_filter_gain( "test_fully_occluded", 0, 	 0.0 );
	set_filter_q( "test_fully_occluded", 0, 		1 );
//	add_channel_to_filter( "test_fully_occluded", 	"ambient" );
//	add_channel_to_filter( "test_fully_occluded", 	"element" );
	add_channel_to_filter( "test_fully_occluded", 	"vehicle" );
	add_channel_to_filter( "test_fully_occluded", 	"weapon" );
	add_channel_to_filter( "test_fully_occluded", 	"voice" );
	add_channel_to_filter( "test_fully_occluded", 	"body" );
//	add_channel_to_filter( "test_fully_occluded", 	"local" );
	add_channel_to_filter( "test_fully_occluded", 	"item" );
	add_channel_to_filter( "test_fully_occluded", 	"physics" );
	add_channel_to_filter( "test_fully_occluded", 	"effects1" );
	add_channel_to_filter( "test_fully_occluded", 	"effects2" );
	add_channel_to_filter( "test_fully_occluded", 	"bulletwhizby" );
	
	
	
	define_filter( "favela_int_shanty0" );
	set_filter_type( "favela_int_shanty0", 0, 	"highshelf" );
	set_filter_freq( "favela_int_shanty0", 0, 	3500 );
	set_filter_gain( "favela_int_shanty0", 0, 	 - 10 );
	set_filter_q( "favela_int_shanty0", 0, 		1 );
	add_channel_to_filter( "favela_int_shanty0", 	"ambient" );
	add_channel_to_filter( "favela_int_shanty0", 	"element" );
	add_channel_to_filter( "favela_int_shanty0", 	"auto" );
	add_channel_to_filter( "favela_int_shanty0", 	"auto2" );
	add_channel_to_filter( "favela_int_shanty0", 	"vehicle" );
	add_channel_to_filter( "favela_int_shanty0", 	"weapon" );
	add_channel_to_filter( "favela_int_shanty0", 	"voice" );

	define_filter( "gulag_hall_int0" );
	set_filter_type( "gulag_hall_int0", 0, 			"highshelf" );
	set_filter_freq( "gulag_hall_int0", 0, 			7500 );
	set_filter_gain( "gulag_hall_int0", 0, 			 - 12 );
	set_filter_q( "gulag_hall_int0", 0, 			1 );
	add_channel_to_filter( "gulag_hall_int0", 		"ambient" );
	add_channel_to_filter( "gulag_hall_int0", 		"element" );
	add_channel_to_filter( "gulag_hall_int0", 		 "vehicle" );
	add_channel_to_filter( "gulag_hall_int0", 		"weapon" );
	add_channel_to_filter( "gulag_hall_int0", 		"voice" );

	define_filter( "gulag_shower_int0" );
	set_filter_type( "gulag_shower_int0", 0, 			"highshelf" );
	set_filter_freq( "gulag_shower_int0", 0, 			8500 );
	set_filter_gain( "gulag_shower_int0", 0, 			 - 8 );
	set_filter_q( "gulag_shower_int0", 0, 			1 );
	add_channel_to_filter( "gulag_shower_int0", 		"ambient" );
	add_channel_to_filter( "gulag_shower_int0", 		"element" );
	add_channel_to_filter( "gulag_shower_int0", 		 "vehicle" );
	add_channel_to_filter( "gulag_shower_int0", 		"weapon" );
	add_channel_to_filter( "gulag_shower_int0", 		"voice" );

	define_filter( "gulag_exit" );
	set_filter_type( "gulag_exit", 0, 		"highshelf" );
	set_filter_freq( "gulag_exit", 0, 		7500 );
	set_filter_gain( "gulag_exit", 0, 		 - 12 );
	set_filter_q( "gulag_exit", 0, 				1 );
	add_channel_to_filter( "gulag_exit", 		"ambient" );
	add_channel_to_filter( "gulag_exit", 		"element" );
	add_channel_to_filter( "gulag_exit", 		 "vehicle" );
	add_channel_to_filter( "gulag_exit", 		"weapon" );
	add_channel_to_filter( "gulag_exit", 		"voice" );

	define_filter( "nx_subpen_intro" );
	set_filter_type( "nx_subpen_intro", 0, 		"lowpass" );
	set_filter_freq( "nx_subpen_intro", 0, 		0 );
	set_filter_gain( "nx_subpen_intro", 0, 		 0 );
	set_filter_q( "nx_subpen_intro", 0, 			1 );
	add_channel_to_filter( "nx_subpen_intro", 		"physics" );
	add_channel_to_filter( "nx_subpen_intro", 		"ambdist1" );
	add_channel_to_filter( "nx_subpen_intro", 		"ambdist2" );
	add_channel_to_filter( "nx_subpen_intro", 		"auto" );
	add_channel_to_filter( "nx_subpen_intro", 		"auto2" );
	add_channel_to_filter( "nx_subpen_intro", 		"bulletimpact" );
	add_channel_to_filter( "nx_subpen_intro", 		"bulletwhizby" );
	add_channel_to_filter( "nx_subpen_intro", 		"element" );
	add_channel_to_filter( "nx_subpen_intro", 		"auto2d" );
	add_channel_to_filter( "nx_subpen_intro", 		"vehicle" );
	add_channel_to_filter( "nx_subpen_intro", 		"vehiclelimited" );
	add_channel_to_filter( "nx_subpen_intro", 		"body" );
	add_channel_to_filter( "nx_subpen_intro", 		"body2d" );
	add_channel_to_filter( "nx_subpen_intro", 		"reload" );
	add_channel_to_filter( "nx_subpen_intro", 		"reload2d" );
	add_channel_to_filter( "nx_subpen_intro", 		"item" );
	add_channel_to_filter( "nx_subpen_intro", 		"effects1" );
	add_channel_to_filter( "nx_subpen_intro", 		"effects2" );
	add_channel_to_filter( "nx_subpen_intro", 		"weapon" );
	add_channel_to_filter( "nx_subpen_intro", 		"weapon2d" );
	add_channel_to_filter( "nx_subpen_intro", 		"nonshock" );
	add_channel_to_filter( "nx_subpen_intro", 		"local" );
	add_channel_to_filter( "nx_subpen_intro", 		"local2" );
	add_channel_to_filter( "nx_subpen_intro", 		"local3" );
	add_channel_to_filter( "nx_subpen_intro", 		"ambient" );
	add_channel_to_filter( "nx_subpen_intro", 		"hurt" );
	add_channel_to_filter( "nx_subpen_intro", 		"player1" );
	add_channel_to_filter( "nx_subpen_intro", 		"player2" );
	add_channel_to_filter( "nx_subpen_intro", 		"musicnopause" );
	add_channel_to_filter( "nx_subpen_intro", 		"mission" );
	add_channel_to_filter( "nx_subpen_intro", 		"announcer" );
	add_channel_to_filter( "nx_subpen_intro", 		"shellshock" );
	add_channel_to_filter( "nx_subpen_intro", 		"nx_localR" );
	add_channel_to_filter( "nx_subpen_intro", 		"nx_local2R" );
	add_channel_to_filter( "nx_subpen_intro", 		"nx_localverb" );
	add_channel_to_filter( "nx_subpen_intro", 		"nx_localverbR" );
	add_channel_to_filter( "nx_subpen_intro", 		"nx_verb3d" );
	add_channel_to_filter( "nx_subpen_intro", 		"voice" );

	define_filter( "nx_subpen_lowpass" );
	set_filter_type( "nx_subpen_lowpass", 0, 		"lowpass" );
	set_filter_freq( "nx_subpen_lowpass", 0, 		200 );
	set_filter_gain( "nx_subpen_lowpass", 0, 		 0 );
	set_filter_q( "nx_subpen_lowpass", 0, 			1 );
	add_channel_to_filter( "nx_subpen_lowpass", 		"physics" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"ambdist1" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"ambdist2" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"auto" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"auto2" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"bulletimpact" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"bulletwhizby" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"element" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"auto2d" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"vehicle" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"vehiclelimited" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"body" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"body2d" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"reload" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"reload2d" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"item" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"effects1" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"effects2" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"weapon" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"weapon2d" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"nonshock" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"local" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"local2" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"local3" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"ambient" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"hurt" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"player1" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"player2" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"musicnopause" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"mission" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"announcer" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"shellshock" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"nx_localR" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"nx_local2R" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"nx_localverb" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"nx_localverbR" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"nx_verb3d" );
	add_channel_to_filter( "nx_subpen_lowpass", 		"voice" );

	define_filter( "nx_subpen_ext" );
	set_filter_type( "nx_subpen_ext", 0, 		"highshelf" );
	set_filter_freq( "nx_subpen_ext", 0, 		200 );
	set_filter_gain( "nx_subpen_ext", 0, 		 0 );
	set_filter_q( "nx_subpen_ext", 0, 			1 );
	add_channel_to_filter( "nx_subpen_ext", 		"physics" );
	add_channel_to_filter( "nx_subpen_ext", 		"ambdist1" );
	add_channel_to_filter( "nx_subpen_ext", 		"ambdist2" );
	add_channel_to_filter( "nx_subpen_ext", 		"auto" );
	add_channel_to_filter( "nx_subpen_ext", 		"auto2" );
	add_channel_to_filter( "nx_subpen_ext", 		"bulletimpact" );
	add_channel_to_filter( "nx_subpen_ext", 		"bulletwhizby" );
	add_channel_to_filter( "nx_subpen_ext", 		"element" );
	add_channel_to_filter( "nx_subpen_ext", 		"auto2d" );
	add_channel_to_filter( "nx_subpen_ext", 		"vehicle" );
	add_channel_to_filter( "nx_subpen_ext", 		"vehiclelimited" );
	add_channel_to_filter( "nx_subpen_ext", 		"body" );
	add_channel_to_filter( "nx_subpen_ext", 		"body2d" );
	add_channel_to_filter( "nx_subpen_ext", 		"reload" );
	add_channel_to_filter( "nx_subpen_ext", 		"reload2d" );
	add_channel_to_filter( "nx_subpen_ext", 		"item" );
	add_channel_to_filter( "nx_subpen_ext", 		"effects1" );
	add_channel_to_filter( "nx_subpen_ext", 		"effects2" );
	add_channel_to_filter( "nx_subpen_ext", 		"weapon" );
	add_channel_to_filter( "nx_subpen_ext", 		"weapon2d" );
	add_channel_to_filter( "nx_subpen_ext", 		"nonshock" );
	add_channel_to_filter( "nx_subpen_ext", 		"local" );
	add_channel_to_filter( "nx_subpen_ext", 		"local2" );
	add_channel_to_filter( "nx_subpen_ext", 		"local3" );
	add_channel_to_filter( "nx_subpen_ext", 		"ambient" );
	add_channel_to_filter( "nx_subpen_ext", 		"hurt" );
	add_channel_to_filter( "nx_subpen_ext", 		"player1" );
	add_channel_to_filter( "nx_subpen_ext", 		"player2" );
	add_channel_to_filter( "nx_subpen_ext", 		"musicnopause" );
	add_channel_to_filter( "nx_subpen_ext", 		"mission" );
	add_channel_to_filter( "nx_subpen_ext", 		"announcer" );
	add_channel_to_filter( "nx_subpen_ext", 		"shellshock" );
	add_channel_to_filter( "nx_subpen_ext", 		"nx_localR" );
	add_channel_to_filter( "nx_subpen_ext", 		"nx_local2R" );
	add_channel_to_filter( "nx_subpen_ext", 		"nx_localverb" );
	add_channel_to_filter( "nx_subpen_ext", 		"nx_localverbR" );
	add_channel_to_filter( "nx_subpen_ext", 		"nx_verb3d" );
	add_channel_to_filter( "nx_subpen_ext", 		"voice" );

	define_filter( "hangar" );
	set_filter_type( "hangar", 0, 		"highshelf" );
	set_filter_freq( "hangar", 0, 		3500 );
	set_filter_gain( "hangar", 0, 		 -9 );
	set_filter_q( "hangar", 0, 			1 );
	add_channel_to_filter( "hangar", 		"ambient" );
	add_channel_to_filter( "hangar", 		"element" );
	add_channel_to_filter( "hangar", 		"vehicle" );
	add_channel_to_filter( "hangar", 		"weapon" );
	add_channel_to_filter( "hangar", 		"voice" );

	define_filter( "interior_metal" );
	set_filter_type( "interior_metal", 0, 	"highshelf" );
	set_filter_freq( "interior_metal", 0, 	3500 );
	set_filter_gain( "interior_metal", 0, 	 - 18 );
	set_filter_q( "interior_metal", 0, 		1 );
	add_channel_to_filter( "interior_metal", "ambient" );
	add_channel_to_filter( "interior_metal", "element" );
	add_channel_to_filter( "interior_metal", "vehicle" );
	add_channel_to_filter( "interior_metal", "weapon" );
	add_channel_to_filter( "interior_metal", "voice" );

	define_filter( "interior_stone" );
	set_filter_type( "interior_stone", 0, 	"highshelf" );
	set_filter_freq( "interior_stone", 0, 	3500 );
	set_filter_gain( "interior_stone", 0, 	 - 6 );
	set_filter_q( "interior_stone", 0, 		1 );
	add_channel_to_filter( "interior_stone", "ambient" );
	add_channel_to_filter( "interior_stone", "element" );
	add_channel_to_filter( "interior_stone", "vehicle" );
	add_channel_to_filter( "interior_stone", "weapon" );
	add_channel_to_filter( "interior_stone", "voice" );

	define_filter( "interior_vehicle" );
	set_filter_type( "interior_vehicle", 0, 	"highshelf" );
	set_filter_freq( "interior_vehicle", 0, 	2700 );
	set_filter_gain( "interior_vehicle", 0, 	 - 12 );
	set_filter_q( "interior_vehicle", 0, 		1 );
	add_channel_to_filter( "interior_vehicle", "ambient" );
	add_channel_to_filter( "interior_vehicle", "auto" );
	add_channel_to_filter( "interior_vehicle", "auto2" );
	add_channel_to_filter( "interior_vehicle", "body" );
	add_channel_to_filter( "interior_vehicle", "element" );
	add_channel_to_filter( "interior_vehicle", "vehicle" );
	add_channel_to_filter( "interior_vehicle", "weapon" );
	add_channel_to_filter( "interior_vehicle", "voice" );

	define_filter( "interior_wood" );
	set_filter_type( "interior_wood", 0, 	"highshelf" );
	set_filter_freq( "interior_wood", 0, 	3500 );
	set_filter_gain( "interior_wood", 0, 	 - 6 );
	set_filter_q( "interior_wood", 0, 		1 );
	add_channel_to_filter( "interior_wood", 	"ambient" );
	add_channel_to_filter( "interior_wood", 	"element" );
	add_channel_to_filter( "interior_wood", 	 "vehicle" );
	add_channel_to_filter( "interior_wood", 	"weapon" );
	add_channel_to_filter( "interior_wood", 	"voice" );
	
	define_filter( "ambient_oilrig_int1" );
	set_filter_type( "ambient_oilrig_int1", 0, 	"highshelf" );
	set_filter_freq( "ambient_oilrig_int1", 0, 	3500 );
	set_filter_gain( "ambient_oilrig_int1", 0, 	 - 10 );
	set_filter_q( "ambient_oilrig_int1", 0, 		1 );
	add_channel_to_filter( "ambient_oilrig_int1", 	"ambient" );
	add_channel_to_filter( "ambient_oilrig_int1", 	"element" );
	add_channel_to_filter( "ambient_oilrig_int1", 	"auto" );
	add_channel_to_filter( "ambient_oilrig_int1", 	"auto2" );
	add_channel_to_filter( "ambient_oilrig_int1", 	"vehicle" );
	add_channel_to_filter( "ambient_oilrig_int1", 	"weapon" );
	add_channel_to_filter( "ambient_oilrig_int1", 	"voice" );

	define_filter( "pipe" );
	set_filter_type( "pipe", 0, 			"highshelf" );
	set_filter_freq( "pipe", 0, 			3500 );
	set_filter_gain( "pipe", 0, 			 - 6 );
	set_filter_q( "pipe", 0, 			1 );
	add_channel_to_filter( "pipe", 		"ambient" );
	add_channel_to_filter( "pipe", 		"element" );
	add_channel_to_filter( "pipe", 		 "vehicle" );
	add_channel_to_filter( "pipe", 		"weapon" );
	add_channel_to_filter( "pipe", 		"voice" );

	define_filter( "shanty" );
	set_filter_type( "shanty", 0, 		"highshelf" );
	set_filter_freq( "shanty", 0, 		3500 );
	set_filter_gain( "shanty", 0, 		 - 2 );
	set_filter_q( "shanty", 0, 			1 );
	add_channel_to_filter( "shanty", 		"ambient" );
	add_channel_to_filter( "shanty", 		"element" );
	add_channel_to_filter( "shanty", 		"vehicle" );
	add_channel_to_filter( "shanty", 		"weapon" );
	add_channel_to_filter( "shanty", 		"voice" );

	define_filter( "tunnel" );
	set_filter_type( "tunnel", 0, 		"highshelf" );
	set_filter_freq( "tunnel", 0, 		3500 );
	set_filter_gain( "tunnel", 0, 		 - 2 );
	set_filter_q( "tunnel", 0, 			1 );
	add_channel_to_filter( "tunnel", 		"ambient" );
	add_channel_to_filter( "tunnel", 		"element" );
	add_channel_to_filter( "tunnel", 		"vehicle" );
	add_channel_to_filter( "tunnel", 		"weapon" );
	add_channel_to_filter( "tunnel", 		"voice" );

	define_filter( "underpass" );
	set_filter_type( "underpass", 0, 		"highshelf" );
	set_filter_freq( "underpass", 0, 		3500 );
	set_filter_gain( "underpass", 0, 		 - 2 );
	set_filter_q( "underpass", 0, 		1 );
	add_channel_to_filter( "underpass", 	"ambient" );
	add_channel_to_filter( "underpass", 	"element" );
	add_channel_to_filter( "underpass", 	"vehicle" );
	add_channel_to_filter( "underpass", 	"weapon" );
	add_channel_to_filter( "underpass", 	"voice" );


	define_filter( "gulag_cavein" );
	set_filter_type( "gulag_cavein", 0, 		"highshelf" );
	set_filter_freq( "gulag_cavein", 0, 		1000 );
	set_filter_gain( "gulag_cavein", 0, 		 - 25 );
	set_filter_q( "gulag_cavein", 0, 				1 );
	set_filter_type( "gulag_cavein", 1, 		"lowshelf" );
	set_filter_freq( "gulag_cavein", 1, 		1200 );
	set_filter_gain( "gulag_cavein", 1, 		 -4 );
	set_filter_q( "gulag_cavein", 1, 				1 );
	add_all_channels_to_filter( "gulag_cavein" );


	define_filter( "gulag_ending_fadeout" );
	set_filter_type( "gulag_ending_fadeout", 0, 		"lowpass" );
	set_filter_freq( "gulag_ending_fadeout", 0, 		0 );
	set_filter_gain( "gulag_ending_fadeout", 0, 		0 );
	set_filter_q( "gulag_ending_fadeout", 0, 			1 );
	add_all_channels_to_filter( "gulag_ending_fadeout" );

	
	define_filter( "sound_fadeout" );
	set_filter_type( "sound_fadeout", 0, 		"lowpass" );
	set_filter_freq( "sound_fadeout", 0, 		0 );
	set_filter_gain( "sound_fadeout", 0, 		0 );
	set_filter_q( "sound_fadeout", 0, 			1 );
	add_all_channels_to_filter( "sound_fadeout" );


	
	
	define_filter( "fadeout_noncritical" );
	set_filter_type( "fadeout_noncritical", 0, 		"lowpass" );
	set_filter_freq( "fadeout_noncritical", 0, 		0 );
	set_filter_gain( "fadeout_noncritical", 0, 		0 );
	set_filter_q( "fadeout_noncritical", 0, 			1 );
	add_all_channels_but_music_and_mission( "fadeout_noncritical" );
	
	define_filter( "fadeall_but_music" );
	set_filter_type( "fadeall_but_music", 0, 		"lowpass" );
	set_filter_freq( "fadeall_but_music", 0, 		0 );
	set_filter_gain( "fadeall_but_music", 0, 		0 );
	set_filter_q( "fadeall_but_music", 0, 			1 );
	add_all_channels_but_music( "fadeall_but_music" );
	
	define_filter( "nx_hithard_no_ugv" );
	set_filter_type( "nx_hithard_no_ugv", 0, 	"lowpass" );
	set_filter_freq( "nx_hithard_no_ugv", 0, 	0 );
	set_filter_gain( "nx_hithard_no_ugv", 0, 	0 );
	set_filter_q( "nx_hithard_no_ugv", 0, 		0.1 );
	add_channel_to_filter( "nx_hithard_no_ugv", 		"vehicle" );
	
	//define_filter( "nx_hithard_basement" );
	//set_filter_type( "nx_hithard_basement", 0, "lowpass" );
	//set_filter_freq( "nx_hithard_basement", 0, 	1000 );
	//set_filter_gain( "nx_hithard_basement", 0, 	0 );
	//add_channel_to_filter( "nx_hithard_basement", "vehicle" );
	//set_filter_q( "nx_hithard_basement", 0, 		1 );

	//define_filter( "nx_hithard_basement_open" );
	//set_filter_type( "nx_hithard_basement_open", 0, "lowpass" );
	//set_filter_freq( "nx_hithard_basement_open", 0, 	1000 );
	//set_filter_gain( "nx_hithard_basement_open", 0, 	0 );
	//add_channel_to_filter( "nx_hithard_basement_open", "vehicle" );
	//set_filter_q( "nx_hithard_basement_open", 0, 		1 ); 
	
	
	define_reverb( "nx_lunar" );
	set_reverb_roomtype( "nx_lunar", 			"default" );
	set_reverb_drylevel( "nx_lunar", 			1.0 );
	set_reverb_wetlevel( "nx_lunar", 			0.0 );
	set_reverb_fadetime( "nx_lunar", 			2 );
	set_reverb_priority( "nx_lunar", 			"snd_enveffectsprio_level" );
	
	define_volume( "nx_lunar_drive_in" );
	set_volume_shock_file( "nx_lunar_drive_in",			"nx_lunar_drive_in" );	
	set_volume_fade_time( "nx_lunar_drive_in",			0.1 );
	set_volume_priority( "nx_lunar_drive_in",			"snd_channelvolprio_level");	
	
	define_volume( "lunar_depressurized" );
	set_volume_shock_file( "lunar_depressurized",		"lunar_depressurized" );	
	set_volume_fade_time( "lunar_depressurized",		0.2 );
	set_volume_priority( "lunar_depressurized",		"snd_channelvolprio_level");	
		
	define_volume( "lunar_pressurized" );
	set_volume_shock_file( "lunar_pressurized",		"lunar_pressurized" );	
	set_volume_fade_time( "lunar_pressurized",		0.2 );
	set_volume_priority( "lunar_pressurized",		"snd_channelvolprio_level");	
	//==================================
	
	
	if ( is_specialop() )
	{
		define_filter( "specialop_fadeout" );
		set_filter_type( "specialop_fadeout", 	0, 	"highshelf" );
		set_filter_freq( "specialop_fadeout", 	0, 	800 );
		set_filter_gain( "specialop_fadeout", 	0, 	-25 );
		set_filter_q( "specialop_fadeout", 		0, 	1 );
		set_filter_type( "specialop_fadeout", 	1, 	"lowshelf" );
		set_filter_freq( "specialop_fadeout", 	1, 	3000 );
		set_filter_gain( "specialop_fadeout", 	1, 	-6 );
		set_filter_q( "specialop_fadeout", 		1, 	1 );
		add_channel_to_filter( "specialop_fadeout", "ambdist1" );
		add_channel_to_filter( "specialop_fadeout", "ambdist2" );
		add_channel_to_filter( "specialop_fadeout", "auto" );
		add_channel_to_filter( "specialop_fadeout", "auto2" );
		add_channel_to_filter( "specialop_fadeout", "auto2d" );
		add_channel_to_filter( "specialop_fadeout", "body" );
		add_channel_to_filter( "specialop_fadeout", "effects1" );
		add_channel_to_filter( "specialop_fadeout", "effects2" );
		add_channel_to_filter( "specialop_fadeout", "element" );
		add_channel_to_filter( "specialop_fadeout", "item" );
		add_channel_to_filter( "specialop_fadeout", "local" );
		add_channel_to_filter( "specialop_fadeout", "physics" );
		add_channel_to_filter( "specialop_fadeout", "reload" );
		add_channel_to_filter( "specialop_fadeout", "vehicle" );
		add_channel_to_filter( "specialop_fadeout", "vehiclelimited" );
		add_channel_to_filter( "specialop_fadeout", "voice" );
		add_channel_to_filter( "specialop_fadeout", "weapon" );
	}
}

// ***********************************************************

 /* 
 ============= 
///ScriptDocBegin
"Name: define_filter( <name> )"
"Summary: Creates a new filter"
"Module: Ambience"
"MandatoryArg: <name> : The name of the filter."
"Example: define_filter( "interior_stone" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
define_filter( name )
{
	assertex( !isdefined( level._eq_defs[ name ] ), "Filter " + name + " is already defined" );
	level._eq_defs[ name ] = [];
}

 /* 
 ============= 
///ScriptDocBegin
"Name: set_filter_type( <name> , <band> , <type> )"
"Summary: Sets the type for a filter"
"Module: Ambience"
"MandatoryArg: <name> : The name of the filter."
"MandatoryArg: <band> : The band( 0 to 2 ) "
"MandatoryArg: <type> : The filter type "
"Example: set_filter_type( "underpass", 0, "highshelf" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
set_filter_type( name, band, type )
{
	assertex( isdefined( level._eq_defs[ name ] ), "Filter " + name + " is not defined" );
	assert( band >= 0 && band < 3 );
	level._eq_defs[ name ][ "type" ][ band ] = type;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: set_filter_freq( <name> , <band> , <freq> )"
"Summary: Sets the freq for a filter"
"Module: Ambience"
"MandatoryArg: <name> : The name of the filter."
"MandatoryArg: <band> : The band( 0 to 2 ) "
"MandatoryArg: <freq> : The filter freq "
"Example: set_filter_freq( "underpass", 0, 3500 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
set_filter_freq( name, band, freq )
{
	assertex( isdefined( level._eq_defs[ name ] ), "Filter " + name + " is not defined" );
	assert( band >= 0 && band < 3 );
	level._eq_defs[ name ][ "freq" ][ band ] = freq;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: set_filter_gain( <name> , <band> , <gain> )"
"Summary: Sets the gain for a filter"
"Module: Ambience"
"MandatoryArg: <name> : The name of the filter."
"MandatoryArg: <band> : The band( 0 to 2 ) "
"MandatoryArg: <gain> : The filter gain "
"Example: set_filter_gain( "underpass", 0, -2 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
set_filter_gain( name, band, gain )
{
	assertex( isdefined( level._eq_defs[ name ] ), "Filter " + name + " is not defined" );
	assert( band >= 0 && band < 3 );
	level._eq_defs[ name ][ "gain" ][ band ] = gain;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: set_filter_q( <name> , <band> , <q> )"
"Summary: Sets the q for a filter"
"Module: Ambience"
"MandatoryArg: <name> : The name of the filter."
"MandatoryArg: <band> : The band( 0 to 2 ) "
"MandatoryArg: <q> : The filter q "
"Example: set_filter_q( "underpass", 0, 1 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
set_filter_q( name, band, q )
{
	assertex( isdefined( level._eq_defs[ name ] ), "Filter " + name + " is not defined" );
	assert( band >= 0 && band < 3 );
	level._eq_defs[ name ][ "q" ][ band ] = q;
}


 /* 
 ============= 
///ScriptDocBegin
"Name: define_reverb( <name> )"
"Summary: Creates a new reverb setting"
"Module: Ambience"
"MandatoryArg: <name> : The name of the reverb."
"Example: define_reverb( "interior_stone" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
define_reverb( name )
{
	assertex( !isdefined( level._ambient_reverb[ name ] ), "Reverb " + name + " is already defined" );
	level._ambient_reverb[ name ] = [];
}

 /* 
 ============= 
///ScriptDocBegin
"Name: set_reverb_roomtype( <name> , <roomtype> )"
"Summary: Sets the roomtype for a reverb setting."
"Module: Ambience"
"MandatoryArg: <name> : The reverb setting."
"MandatoryArg: <name> : The roomtype."
"Example: set_reverb_roomtype( "interior_stone", "stoneroom" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
set_reverb_roomtype( name, roomtype )
{
	assertex( isdefined( level._ambient_reverb[ name ] ), "Reverb " + name + " is not defined" );
	level._ambient_reverb[ name ][ "roomtype" ] = roomtype;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: set_reverb_drylevel( <name> , <drylevel> )"
"Summary: Sets the drylevel for a reverb setting."
"Module: Ambience"
"MandatoryArg: <name> : The reverb setting."
"MandatoryArg: <name> : The drylevel."
"Example: set_reverb_drylevel( "interior_stone", 0.6 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
set_reverb_drylevel( name, drylevel )
{
	assertex( isdefined( level._ambient_reverb[ name ] ), "Reverb " + name + " is not defined" );
	level._ambient_reverb[ name ][ "drylevel" ] = drylevel;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: set_reverb_wetlevel( <name> , <wetlevel> )"
"Summary: Sets the roomtype for a reverb setting."
"Module: Ambience"
"MandatoryArg: <name> : The reverb setting."
"MandatoryArg: <name> : The wetlevel."
"Example: set_reverb_wetlevel( "interior_stone", 0.3 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
set_reverb_wetlevel( name, wetlevel )
{
	assertex( isdefined( level._ambient_reverb[ name ] ), "Reverb " + name + " is not defined" );
	level._ambient_reverb[ name ][ "wetlevel" ] = wetlevel;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: set_reverb_fadetime( <name> , <fadetime> )"
"Summary: Sets the fadetime for a reverb setting."
"Module: Ambience"
"MandatoryArg: <name> : The reverb setting."
"MandatoryArg: <name> : The fadetime."
"Example: set_reverb_fadetime( "interior_stone", 2 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
set_reverb_fadetime( name, fadetime )
{
	assertex( isdefined( level._ambient_reverb[ name ] ), "Reverb " + name + " is not defined" );
	level._ambient_reverb[ name ][ "fadetime" ] = fadetime;
}

 /* 
 ============= 
///ScriptDocBegin
"Name: set_reverb_priority( <name> , <priority> )"
"Summary: Sets the priority for a reverb setting."
"Module: Ambience"
"MandatoryArg: <name> : The reverb setting."
"MandatoryArg: <name> : The priority."
"Example: set_reverb_priority( "interior_stone", "snd_enveffectsprio_level" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
set_reverb_priority( name, priority )
{
	assertex( isdefined( level._ambient_reverb[ name ] ), "Reverb " + name + " is not defined" );
	level._ambient_reverb[ name ][ "priority" ] = priority;
}

getFilter( name )
{
	assert( isdefined( name ) );
	if ( !isDefined( level._eq_defs ) )
		return undefined;
	if ( !isDefined( level._eq_defs[ name ] ) )
		return undefined;

	return level._eq_defs[ name ];
}

/*
=============
///ScriptDocBegin
"Name: add_channel_to_filter( <track> , <channel> )"
"Summary: Makes a filter effect a sound channel."
"Module: Ambience"
"MandatoryArg: <track>: The filter. "
"MandatoryArg: <channel>: The channel to add. "
"Example: add_channel_to_filter( "interior_stone", "ambient" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
add_channel_to_filter( track, channel )
{
	if ( !isDefined( level._ambient_eq[ track ] ) )
		level._ambient_eq[ track ] = [];

	level._ambient_eq[ track ][ channel ] = true;
}

/*
=============
///ScriptDocBegin
"Name: add_all_channels_to_filter( <track> )"
"Summary: Adds all known channels to a filter"
"Module: Ambience"
"MandatoryArg: <track>: The name of the filter"
"Example: add_all_channels_to_filter( "gulag_cavein" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
add_all_channels_to_filter( track )
{
	if ( !isDefined( level._ambient_eq[ track ] ) )
		level._ambient_eq[ track ] = [];

	channels = get_all_channels();

	foreach ( channel, _ in channels )
	{
		level._ambient_eq[ track ][ channel ] = true;
	}
}

/*
=============
///ScriptDocBegin
"Name: add_all_channels_but_music_and_mission( <track> )"
"Summary: Adds all known channels to a filter but music and mission"
"Module: Ambience"
"MandatoryArg: <track>: The name of the filter"
"Example: add_all_channels_but_music_and_mission( "gulag_cavein" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
add_all_channels_but_music_and_mission( track )
{
	if ( !isDefined( level._ambient_eq[ track ] ) )
		level._ambient_eq[ track ] = [];

	channels = get_all_channels();
	channels[ "music" ] = undefined;
	channels[ "mission" ] = undefined;
	
	foreach ( channel, _ in channels )
	{
		level._ambient_eq[ track ][ channel ] = true;
	}
}

/*
=============
///ScriptDocBegin
"Name: add_all_channels_but_music_and_ambient( <track> )"
"Summary: Adds all known channels to a filter but music and ambient"
"Module: Ambience"
"MandatoryArg: <track>: The name of the filter"
"Example: add_all_channels_but_music_and_ambient( "nx_repel_office" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
add_all_channels_but_music_and_ambient( track )
{
	if ( !isDefined( level._ambient_eq[ track ] ) )
		level._ambient_eq[ track ] = [];

	channels = get_all_channels();
	channels[ "music" ] = undefined;
	channels[ "ambient" ] = undefined;
	
	foreach ( channel, _ in channels )
	{
		level._ambient_eq[ track ][ channel ] = true;
	}
}

add_all_channels_but_music( track )
{
	if ( !isDefined( level._ambient_eq[ track ] ) )
		level._ambient_eq[ track ] = [];

	channels = get_all_channels();
	channels[ "music" ] = undefined;
				
	foreach ( channel, _ in channels )
	{
		level._ambient_eq[ track ][ channel ] = true;
	}
}

/* 
============= 
///ScriptDocBegin
"Name: define_volume( <name> )"
"Summary: Creates a new volume setting"
"Module: Ambience"
"MandatoryArg: <name> : The name of the volume set."
"Example: define_volume( "interior_stone" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
define_volume( name )
{
	assertex( !isdefined( level._ambient_volume[ name ] ), "Volume " + name + " is already defined" );
	level._ambient_volume[ name ] = [];
}

/* 
============= 
///ScriptDocBegin
"Name: set_volume_shock_file( <name> , <shock_file> )"
"Summary: Sets the shock file of the volume setting."
"Module: Ambience"
"MandatoryArg: <name> : The volume setting."
"MandatoryArg: <shock_file> : The shockfile."
"Example: set_volume_shock_file( "interior_stone", "some_shock_file" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
set_volume_shock_file( name, shock_file )
{
	assertex( isdefined( level._ambient_volume[ name ] ), "Volume " + name + " is not defined" );
	level._ambient_volume[ name ][ "shock_file" ] = shock_file;
}

/* 
============= 
///ScriptDocBegin
"Name: set_volume_fade_time( <name> , <fade> )"
"Summary: Sets the fade time of the volume setting."
"Module: Ambience"
"MandatoryArg: <name> : The volume setting."
"MandatoryArg: <fade> : The time in seconds to fade over."
"Example: set_volume_fade_time( "interior_stone", 2 );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
set_volume_fade_time( name, fade )
{
	assertex( isdefined( level._ambient_volume[ name ] ), "Volume " + name + " is not defined" );
	level._ambient_volume[ name ][ "fade" ] = fade;
}

/* 
============= 
///ScriptDocBegin
"Name: set_volume_priority( <name> , <priority> )"
"Summary: Sets the priority of the volume setting."
"Module: Ambience"
"MandatoryArg: <name> : The volume setting."
"MandatoryArg: <priority> : The time in seconds to fade over."
"Example: set_volume_priority( "interior_stone", "snd_channelvolprio_level" );"
"SPMP: singleplayer"
///ScriptDocEnd
 ============= 
 */ 
set_volume_priority( name, priority )
{
	assertex( isdefined( level._ambient_volume[ name ] ), "Volume " + name + " is not defined" );
	level._ambient_volume[ name ][ "priority" ] = priority;
}

get_all_channels()
{
	channels = [];
	channels[ "announcer"      		 ] = true;	
	channels[ "ambient"              ] = true;	
	channels[ "ambdist1"         	 ] = true;
	channels[ "ambdist2"			 ] = true;	
	channels[ "auto"           		 ] = true;	
	channels[ "auto2"                ] = true;	
	channels[ "auto2d"               ] = true;	
	channels[ "body"           		 ] = true;	
	channels[ "body2d"         		 ] = true;	
	channels[ "bulletimpact"   		 ] = true;	
	channels[ "bulletwhizby"   		 ] = true;	
	channels[ "effects1"             ] = true;	
	channels[ "effects2"             ] = true;	
	channels[ "element"              ] = true;	
	channels[ "hurt"      			 ] = true;	
	channels[ "item"      			 ] = true;
	channels[ "local"          		 ] = true;	
	channels[ "local2"         		 ] = true;	
	channels[ "local3"         		 ] = true;	
	channels[ "menu"      			 ] = true;
	channels[ "mission"              ] = true;	
	channels[ "music"          		 ] = true;	
	channels[ "nonshock"       		 ] = true;	
	channels[ "player1"        		 ] = true;	
	channels[ "player2"        		 ] = true;	
	channels[ "physics"        		 ] = true;	
	channels[ "reload"               ] = true;	
	channels[ "reload2d"			 ] = true;	
	//channels[ "shellshock"			 ] = true;	
	channels[ "vehicle"              ] = true;	
	channels[ "vehiclelimited"       ] = true;	
	channels[ "voice"     			 ] = true;	
	channels[ "weapon"      		 ] = true;
	return channels;
}

// 	EXAMPLE OVERWRITE
//	if ( mission( "bog_a" ) )
//	{
//		// bog_a aint as wet?
//		set_reverb_wetlevel( "interior_stone", 	0.3 );
//	}

/* JL: This is an example of a way to use one eq setting for multiple tracks. This could reduce that amount of duplicate filter settings entries in _equalizer.gsc
create_depressurized_eq( track )
{
	define_filter( track );
	set_filter_type( track, 0, 			"lowpass" );
	set_filter_freq( track, 0, 			150 );
	set_filter_gain( track, 0, 			0 );
	set_filter_q( track, 0, 			1 );
	add_channel_to_filter( track, 		"physics" );
	add_channel_to_filter( track, 		"ambdist1" );
	add_channel_to_filter( track, 		"ambdist2" );
	add_channel_to_filter( track, 		"auto" );
	add_channel_to_filter( track, 		"auto2" );
	add_channel_to_filter( track, 		"bulletimpact" );
	add_channel_to_filter( track, 		"bulletwhizby" );
	add_channel_to_filter( track, 		"element" );
	add_channel_to_filter( track, 		"vehicle" );
	add_channel_to_filter( track, 		"vehiclelimited" );
	add_channel_to_filter( track, 		"body" );
	add_channel_to_filter( track, 		"reload" );
	add_channel_to_filter( track, 		"reload2d" );
	add_channel_to_filter( track, 		"item" );
	add_channel_to_filter( track, 		"effects1" );
	add_channel_to_filter( track, 		"effects2" );
	add_channel_to_filter( track, 		"weapon" );
	add_channel_to_filter( track, 		"nonshock" );
	add_channel_to_filter( track, 		"ambient" );
	add_channel_to_filter( track, 		"hurt" );
	add_channel_to_filter( track, 		"player1" );
	add_channel_to_filter( track, 		"player2" );

}
*/
