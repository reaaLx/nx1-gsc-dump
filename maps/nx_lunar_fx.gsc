//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  FX Support													**
//                                                                          **
//    Created: DATE - CREATOR												**
//                                                                          **
//****************************************************************************
#include maps\_utility;
#include common_scripts\utility;

main()
{
	maps\createfx\nx_lunar_fx::main();

	level._effect[ "paper" ]							= LoadFX( "props/news_stand_paper_spill_shatter" );
	level._effect[ "meteor_trail" ]						= LoadFX( "nx/misc/nx_chinese_lgv_turret_trail" );
	

	// Enemy breach
	level._effect[ "breach_charge" ]									= loadFX( "nx/lunar/nx_lunar_breach_charge_insertion" );
	level._effect[ "breach_explosion" ]									= loadFX( "nx/lunar/nx_lunar_allies_airlock_breach" );
	level._effect[ "nx_lunar_breach_charge_insert_back_air" ]			= loadFX( "nx/lunar/nx_lunar_breach_charge_insert_back_air" );
	
	// Ambient FX
	level._effect[ "nx_lunar_ash_linger_200" ]							= loadFX( "nx/lunar/nx_lunar_ash_linger_200" );
	level._effect[ "nx_lunar_glow_dust_50" ]							= loadFX( "nx/lunar/nx_lunar_glow_dust_50" );
	level._effect[ "nx_lunar_glow_dust_skylight_100" ]					= loadFX( "nx/lunar/nx_lunar_glow_dust_skylight_100" );

	// LSP Explosion
	level._effect[ "lsp_explosion" ]									= loadFX( "nx/lunar/nx_lunar_transformer_explosion" );
	level._effect[ "lsp_ground_dust_200" ]								= loadFX( "nx/lunar/nx_lunar_lsp_explosion_dust_200" );

	// Amory Breach
	level._effect[ "nx_lunar_armory_depressurization" ]					= LoadFX( "nx/lunar/nx_lunar_armory_depressurization" );
	level._effect[ "nx_lunar_armory_sparks_gaseous_runner" ]			= LoadFX( "nx/lunar/nx_lunar_armory_sparks_gaseous_runner" );
	level._effect[ "nx_lunar_armory_sparks_gaseous_runner_infinite" ]	= LoadFX( "nx/lunar/nx_lunar_armory_sparks_gaseous_runner_infinite" );
	level._effect[ "nx_lunar_armory_sparks_runner_infinite" ]			= LoadFX( "nx/lunar/nx_lunar_armory_sparks_runner_infinite" );

	level._effect[ "steam_jet_med_loop" ]				= LoadFX( "smoke/steam_jet_med_loop" );
	level._effect[ "pipe_flame" ]						= LoadFX( "nx/lunar/impacts/nx_lunar_pipe_fire" );

	// Airlock Cycle
	level._effect[ "nx_lunar_steam_jet_blow" ]			= LoadFX( "nx/lunar/nx_lunar_steam_jet_blow" );
	level._effect[ "nx_lunar_steam_jet_suck" ]			= LoadFX( "nx/lunar/nx_lunar_steam_jet_suck" );

	// Temp effects
	level._effect[ "railgun_impact_explosion" ] = loadfx( "explosions/artilleryExp_dirt_brown" );
	level._effect[ "hub_room_explosion" ] = loadfx( "explosions/wall_explosion_2_short_nosmoke" );
	level._effect[ "charlie_impact" ] = loadfx( "impacts/flesh_hit_body_fatal_exit" );
	level._effect[ "tower_impact" ] = loadfx( "impacts/20mm_metal_impact" );
	level._effect[ "rock_explosion" ] = loadfx( "misc/rock_break_explosion" );
	level._effect[ "boulder_dust_cloud" ] = loadfx( "test/nx_lunar_regolith_impact_large" );
	level._effect[ "exterior_vista_steam" ] = loadfx( "smoke/steam_large_vent" );

	// Crew Module Airlock Death
	level._effect[ "footdust_small" ]									= LoadFX( "nx/lunar/impacts/nx_footstep_moondust_small" );
	level._effect[ "nx_lunar_falcon_death_blood_hit" ]					= LoadFX( "nx/lunar/nx_lunar_falcon_death_blood_hit" );
	level._effect[ "nx_lunar_crew_airlock_blood_squirt" ]				= LoadFX( "nx/lunar/nx_lunar_crew_airlock_blood_squirt" );
	level._effect[ "nx_lunar_crew_airlock_impact_large" ]				= loadFX( "nx/lunar/nx_lunar_crew_airlock_impact_large" );

	// Falcon Death
	level._effect[ "nx_lunar_falcon_death_blood_exit" ]					= loadFX( "nx/lunar/nx_lunar_falcon_death_blood_exit" );
	level._effect[ "nx_lunar_falcon_death_blood_squirt" ]				= loadFX( "nx/lunar/nx_lunar_falcon_death_blood_squirt" );
	level._effect[ "nx_lunar_falcon_death_dust" ]						= loadFX( "nx/lunar/nx_lunar_falcon_death_dust" );
	level._effect[ "nx_lunar_falcon_death_dust_small" ]					= loadFX( "nx/lunar/nx_lunar_falcon_death_dust_small" );
	level._effect[ "nx_lunar_falcon_death_glass_hit" ]					= loadFX( "nx/lunar/nx_lunar_falcon_death_glass_hit" );
	level._effect[ "nx_chinese_lgv_turret_wv" ]							= loadFX( "nx/muzzleflashes/nx_chinese_lgv_turret_wv" );
	precacheItem( "nx_chinese_lgv_turret_magicbullet_big_dirt" );
	precacheItem( "nx_chinese_lgv_turret_magicbullet_dirt" );
	precacheItem( "nx_chinese_lgv_turret_magicbullet_dirt_linger" );
	precacheItem( "nx_chinese_lgv_turret_magicbullet_flesh" );

	// Intro
	level._effect[ "nx_lunar_helmet_leak_vapor_left" ] 					= loadfx( "nx/misc/nx_lunar_helmet_leak_vapor_left" );
	level._effect[ "nx_lunar_helmet_leak_vapor_right" ] 				= loadfx( "nx/misc/nx_lunar_helmet_leak_vapor_right" );
	level._effect[ "nx_regolith_hands" ] 								= loadfx( "nx/dust/nx_regolith_hands" );
	level._effect[ "nx_lunar_regolith_haze" ] 							= loadfx( "nx/dust/nx_lunar_regolith_haze" );
	level._effect[ "nx_lunar_intro_blood_squirt" ]						= LoadFX( "nx/lunar/nx_lunar_intro_blood_squirt" );
	level._effect[ "nx_regolith_bodyfall" ] 							= loadfx( "nx/dust/nx_regolith_bodyfall" );
	level._effect[ "nx_regolith_footfall" ] 							= loadfx( "nx/dust/nx_regolith_footfall" );
	level._effect[ "nx_lunar_intro_eye_blood" ] 						= loadfx( "nx/nx_lunar/nx_lunar_intro_eye_blood" );
	level._effect[ "nx_lunar_intro_glass_hit" ] 						= loadfx( "nx/lunar/nx_lunar_intro_glass_hit" );
	level._effect[ "nx_lunar_intro_glass_helmet_drop" ] 				= loadfx( "nx/lunar/nx_lunar_intro_glass_helmet_drop" );

	// Intro
	PreCacheModel( "nx_us_space_assault_head_crack" );

	// Top Floor Breach
	level._effect[ "nx_lunar_top_floor_breach_air" ]					= LoadFX( "nx/lunar/nx_lunar_top_floor_breach_air" );
	level._effect[ "nx_lunar_top_floor_breach_ash" ]					= LoadFX( "nx/lunar/nx_lunar_top_floor_breach_ash" );
	level._effect[ "nx_lunar_top_floor_breach_dust" ]					= LoadFX( "nx/lunar/nx_lunar_top_floor_breach_dust" );
	level._effect[ "nx_lunar_top_floor_breach_corridor" ]				= LoadFX( "nx/lunar/nx_lunar_top_floor_breach_corridor" );
	level._effect[ "nx_lunar_top_floor_breach_sparks_runner" ]			= LoadFX( "nx/lunar/nx_lunar_top_floor_breach_sparks_runner" );
	level._effect[ "nx_lunar_top_floor_breach_sparks_gaseous_runner" ]	= LoadFX( "nx/lunar/nx_lunar_top_floor_breach_sparks_gaseous_runner" );
	precacheItem( "nx_chinese_lgv_turret_magicbullet_metal" );

	// Allies Airlock Breach
	level._effect[ "nx_lunar_allies_airlock_dust_100" ]					= loadFX( "nx/lunar/nx_lunar_allies_airlock_dust_100" );
	level._effect[ "nx_lunar_allies_airlock_dust_200" ]					= loadFX( "nx/lunar/nx_lunar_allies_airlock_dust_200" );
	level._effect[ "nx_lunar_allies_airlock_dust_mote_100" ]			= loadFX( "nx/lunar/nx_lunar_allies_airlock_dust_mote_100" );
	level._effect[ "nx_lunar_allies_airlock_dust_mote_crazy_100" ]		= loadFX( "nx/lunar/nx_lunar_allies_airlock_dust_mote_crazy_100" );
	level._effect[ "nx_lunar_allies_airlock_dust_bomb" ]				= loadFX( "nx/lunar/nx_lunar_allies_airlock_dust_bomb" );
	level._effect[ "nx_lunar_allies_airlock_burst_flash" ]				= loadFX( "nx/lunar/nx_lunar_allies_airlock_burst_flash" );	

	// Take Back Control Room
	level._effect[ "nx_lunar_control_breach" ]							= loadFX( "nx/lunar/nx_lunar_control_breach" );

	footstep_effects();
	//treadfx_override();

	// default vision set for the map
	VisionSetNaked( "nx_lunar", 0.0 );

	set_glass_shatter_params();
	
	// get the card and hide it
	upstairs_breach_card = getent("fx_upstairs_breach_white_card", "script_noteworthy");
	upstairs_breach_card hide();

	// turn off the vehicle bay keylight to start off - it should only be on once you're inside.
	vehicle_bay_key_light = GetEnt( "vehiclebay_key", "targetname" );
	vehicle_bay_key_light SetLightIntensity(0.0);
}

// how galss shatters on the moon
set_glass_shatter_params()
{
/*
	glass_linear_vel = (200.0,400.0);
	glass_angular_vel = (5.0,35.0);
	glass_fall_delay = (0.6, 2.0);
*/

	setSavedDvar("glass_linear_vel", 190.0 );
	setSavedDvar("glass_angular_vel", 8.0 );
	setSavedDvar("glass_fall_delay", 2.0 );
	setSavedDvar("glass_fall_gravity", 350.0 );
	setSavedDvar("glass_fringe_maxsize", 100.0);
	setSavedDVar("glass_fringe_maxcoverage", 0.5);
	setSavedDvar("glass_shattered_scale", 48.0);
	// setSavedDvar("glass_shard_maxsize", 100.0);
}

// *******************************************************
// vision set inits
fx_init_vision_breached()
{
	set_vision_set("nx_lunar_breached", 0.0);
}

fx_init_vision_breached_helmet()
{
	set_vision_set("nx_lunar_breached_helmet", 0.0);
}

fx_init_vision_alert()
{
	set_vision_set("nx_lunar_alert", 0.0);
}

fx_init_vision_alert_helmet()
{
	set_vision_set("nx_lunar_alert_helmet", 0.0);
}

fx_init_vision_surface()
{
	set_vision_set("nx_lunar_surface_01", 0.0);
}

// *******************************************************
// Vision set sequencing changes
fx_control_room_vision_sequence()
{

	wait 1.0;
	set_vision_set("nx_lunar_breached", 1.0);
	level._player PlayRumbleLoopOnEntity( "steady_rumble" );
	wait 1.5;

	// this is the white card we display outside the upstairs control room window during the breach sequence
	// we show it only temporarily during the sequence, then hide it again.
	upstairs_breach_card = getent("fx_upstairs_breach_white_card", "script_noteworthy");
	upstairs_breach_card show();

	set_vision_set("nx_lunar_upstairs_breach_windows_1", 1.0);
	wait 1.0;
	level._player StopRumble( "steady_rumble" );	
	level._player PlayRumbleLoopOnEntity( "tank_rumble" );
	set_vision_set("nx_lunar_upstairs_breach_windows_2", 1.0);
	wait 1.0;
	set_vision_set("nx_lunar_upstairs_breach_windows_3", 1.5);
	wait 1.0;
	level._player StopRumble( "tank_rumble" );
	wait 1.5;
	upstairs_breach_card hide();
	set_vision_set("nx_lunar_alert", 5.0);
	wait 0.6;
	level._player PlayRumbleOnEntity( "damage_heavy" );
}

fx_armory_breach_vision_change()
{
	wait 1.0;
	set_vision_set("nx_lunar_breached_helmet", 3.0);
}

fx_armory_entry_helmet_on_vision_change()
{
	set_vision_set("nx_lunar_alert_helmet", 1.0);
}

fx_lunar_take_back_control_vision_change()
{
	set_vision_set("nx_lunar_breached_helmet", 4.0);
}


fx_crew_module_enter_vision_change()
{
	set_vision_set("nx_lunar_alert", 3.0);
}

fx_crew_module_exit_vision_change()
{
	set_vision_set("nx_lunar_surface_01", 3.0);
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

footstep_effects()
{

	//Regular footstep fx
	animscripts\utility::setFootstepEffect( "dirt",		loadfx ( "nx/lunar/impacts/nx_footstep_moondust_small" ) );
	animscripts\utility::setFootstepEffect( "concrete",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "asphalt",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "rock",		loadfx ( "impacts/footstep_dust" ) );
	
	//Small footstep fx
	animscripts\utility::setFootstepEffectSmall( "dirt",		loadfx ( "nx/lunar/impacts/nx_footstep_moondust_small" ) );
	animscripts\utility::setFootstepEffectSmall( "concrete",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffectSmall( "asphalt",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffectSmall( "rock",		loadfx ( "impacts/footstep_dust" ) );
	  
	//Other notetrack fx
	/*
	setNotetrackEffect( <notetrack>, <tag>, <surface>, <loadfx>, <sound_prefix>, <sound_suffix> )
		<notetrack>: name of the notetrack to do the fx/sound on
		<tag>: name of the tag on the AI to use when playing fx
		<surface>: the fx will only play when the AI is on this surface. Specify "all" to make it work for all surfaces.
		<loadfx>: load the fx to play here
		<sound_prefix>: when this notetrack hits a sound can be played. This is the prefix of the sound alias to play ( gets followed by surface type )
		<sound_suffix>: suffix of sound alias to play, follows the surface type. Example: prefix of "bodyfall_" and suffix of "_large" will play sound alias "bodyfall_dirt_large" when the notetrack happens on dirt.
	*/
	/*
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"dirt",		loadfx ( "impacts/bodyfall_dust_small_runner" ), "bodyfall_", "_small" );
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"concrete",	loadfx ( "impacts/bodyfall_default_small_runner" ), "bodyfall_", "_small" );
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"asphalt",	loadfx ( "impacts/bodyfall_default_small_runner" ), "bodyfall_", "_small" );
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"rock",		loadfx ( "impacts/bodyfall_default_small_runner" ), "bodyfall_", "_small" );
	
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"dirt",		loadfx ( "impacts/bodyfall_dust_large_runner" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"concrete",	loadfx ( "impacts/bodyfall_default_large_runner" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"asphalt",	loadfx ( "impacts/bodyfall_default_large_runner" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"rock",		loadfx ( "impacts/bodyfall_default_large_runner" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"mud",		loadfx ( "impacts/bodyfall_mud_large_runner" ), "bodyfall_", "_large" );
	*/
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"dirt",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"concrete",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"asphalt",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"rock",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"mud",		loadfx ( "impacts/footstep_mud" ) );
	
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"dirt",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"concrete",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"asphalt",	loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"rock",		loadfx ( "impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"mud",		loadfx ( "impacts/footstep_mud" ) );
	
}


treadfx_override()
{
}
