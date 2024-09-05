//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Skyscraper Exfil Anims										**
//                                                                          **
//    Created: 11/10/2011 - John Webb										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
main()
{
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\nx_exfil_fx::main();
	}

	//swat lasers
	level._effect[ "laser_aim" ]				 = LoadFX( "nx/muzzleflashes/nx_laser_glow_at_weapon" );
	
	///intro fx
	level._effect[ "gutshot" ]	    		    = LoadFX( "nx/impacts/nx_exfil_fleshhit_gutshot" );
	level._effect[ "headshot" ]	    		    = LoadFX( "nx/impacts/nx_exfil_fleshhit_headshot" );

	///heli spot
	level._effect[ "heli_spotlight" ]	        = LoadFX( "nx/lights/nx_exfil_heli_spotlight_01" );

	//heli_damage_fx
	level._effect[ "heli_smoke_trail_1" ]		= loadfx( "nx/smoke/nx_heli_damage_smk_emitter");

	//amb_fx
	level._effect[ "ground_steam_white" ]	    = LoadFX( "nx/weather/nx_ground_steam_white" );
	level._effect[ "car_fire_01" ]	            = LoadFX( "nx/fire/nx_car_fire_med_01" );
	level._effect[ "fire_smoke_01" ]	        = LoadFX( "nx/fire/nx_fire_smoke_med_01" );
	level._effect[ "red_light_small" ]	        = LoadFX( "nx/lights/nx_exfil_dynamic_light_red_small" );
	level._effect[ "brakelight_1" ]	            = LoadFX( "misc/car_brakelight_btr80" );
	level._effect[ "accent_fire_small" ]	    = LoadFX( "nx/fire/nx_small_fire" );
	level._effect[ "car_turn_blinker" ]	        = LoadFX( "nx/lights/nx_exfil_turn_indicator_blinking" );
	level._effect[ "transformer_sparks" ]	    = LoadFX( "nx/explosions/transformer_sparks_runner_loop" );
	level._effect[ "ground_sparks" ]	        = LoadFX( "nx/misc/nx_spark_small_runner_loop" );
	level._effect[ "smoke_amb_medium" ]	        = LoadFX( "nx/smoke/nx_smoke_medium_gray" );
	level._effect[ "distant_floodlight_glow" ]	= LoadFX( "nx/misc/nx_exfil_distant_glow" );

	//smokescreen
	level._effect[ "smokescreen" ]				= loadfx( "nx/smoke/nx_exfil_smoke_screen" );
	level._effect[ "smokescreen_glow" ]			= loadfx( "nx/smoke/nx_exfil_smoke_screen_light_glow" );

	//scooter_headlamp
	level._effect[ "scooter_headlight" ]		= loadfx( "nx/lights/nx_exfil_scooter_headlight" );

	//copcarlights
	level._effect[ "police_headlight_l" ]		= loadfx( "nx/lights/nx_exfil_car_headlight_l_01" );
	level._effect[ "police_headlight_r" ]		= loadfx( "nx/lights/nx_exfil_car_headlight_r_01" );
	level._effect[ "police_headlight_light" ]	= loadfx( "nx/lights/nx_exfil_car_headlight_02" );
	level._effect[ "police_light_blue" ]		= loadfx( "nx/misc/nx_copcar_light_blue_loop_01" );
	level._effect[ "police_headlight_perif" ]	= loadfx( "nx/lights/nx_exfil_car_headlight_perif_01" );
	level._effect[ "police_light_blue_perif" ]	= loadfx( "nx/misc/nx_copcar_light_blue_loop_perif_01" );
	
	//swatvan lights
	level._effect[ "swat_headlight_l" ]			= loadfx( "nx/lights/nx_exfil_swat_headlight_l_01" );
	level._effect[ "swat_headlight_r" ]			= loadfx( "nx/lights/nx_exfil_swat_headlight_r_01" );

	//Stryker lights
	level._effect[ "stryker_headlight_l" ]		= loadfx( "nx/lights/nx_exfil_stryker_headlight_l_01" );
	
	//hallway fx
	level._effect[ "fluorescent_spot_01" ]		= loadfx( "nx/lights/nx_exfil_fluorescent_spot");
	level._effect[ "fluorescent_spot_hall_01" ]	= loadfx( "nx/lights/nx_exfil_fluorescent_spot_hallway");
	level._effect[ "grenade_hall_smoke" ]	    = LoadFX( "nx/smoke/nx_exfil_grenade_hall_smoke" );
	level._effect[ "door_coplight_glow" ]	    = LoadFX( "nx/misc/nx_exfil_coplight_door" );
	level._effect[ "hall_grenade_fx" ]	        = LoadFX( "nx/explosions/nx_exfil_grenade_hall" );


	// string lights
	level._effect[ "light_glow_white_bulb" ]	        = LoadFX( "nx/misc/nx_exfil_bulb_glow" );
	level._effect[ "light_glow_white_bulb2" ]	        = LoadFX( "nx/misc/nx_exfil_bulb_glow2" );

	level._spotlight_fx_script = ::turn_on_heli_spotlight_fx;
	level._spotlight_fx_stop_script = ::turn_off_heli_spotlight_fx;
	
	// create_string_light_glows();
	//Apply Fog
	apply_nx_exfil_fog_();

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
create_string_light_glows()
{
	// targetname "string_lights"
	string_light_short_tags = ["tag_bulb019","tag_bulb018","tag_bulb017","tag_bulb020"];
	string_light_long_tags = ["tag_bulb008", "tag_bulb009","tag_bulb010","tag_bulb012","tag_bulb013","tag_bulb014","tag_bulb015","tag_bulb006"];
	string_light_corner_tags = ["tag_bulb005", "tag_bulb004", "tag_bulb003", "tag_bulb002", "tag_bulb00"];


	// the effect to place
	warm_glow_effect = level._effect[ "light_glow_white_bulb" ];
	cool_glow_effect = level._effect[ "light_glow_white_bulb2" ];

	effects_list = [warm_glow_effect, cool_glow_effect];

	lights = getentarray( "string_lights_long", "targetname" );
	
	wait_time = 0.016667;

	foreach (l in lights)
	{
		foreach (tag_name in string_light_long_tags)
		{
			glow_effect_name = effects_list[ RandomInt(2) ];
			if (RandomFloat( 1.0 ) > 0.15 )
			{
				PlayFXOnTag(glow_effect_name, l, tag_name);
				wait wait_time;
			}
		}
		// wait wait_time;
	}

	lights = getentarray( "string_lights_short", "targetname" );
	foreach (l in lights)
	{
		foreach (tag_name in string_light_short_tags)
		{
			glow_effect_name = effects_list[ RandomInt(2) ];
			if (RandomFloat( 1.0 ) > 0.250 )
			{
				PlayFXOnTag(glow_effect_name, l, tag_name);
			}
		}
		wait wait_time;
	}

	lights = getentarray( "string_lights_corner", "targetname" );
	foreach (l in lights)
	{
		foreach (tag_name in string_light_corner_tags)
		{
			glow_effect_name = effects_list[ RandomInt(2) ];
			PlayFXOnTag(glow_effect_name, l, tag_name);
		}
		wait wait_time;
	}

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
turn_on_heli_spotlight_fx()
{
	//set spotlight params: apm
	setsaveddvar( "r_spotlightstartradius", "10" );
	setsaveddvar( "r_spotlightEndradius", "500" );
	setsaveddvar( "r_spotlightfovinnerfraction", ".5" );
	setsaveddvar( "r_spotlightexponent", "1.5" );
	setsaveddvar( "r_spotlightBrightness", "2" );

	playFXontag( getfx( "heli_spotlight" ), self, "TAG_FLASH" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
turn_off_heli_spotlight_fx()
{
	StopFXOnTag( getfx( "heli_spotlight" ), level._spotlight_heli, "TAG_FLASH" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
turn_on_police_car_lights()
{
	//car = getent( "perif_copcar_01", "targetname" );

	//car2 = getent( "perif_copcar_02", "targetname" );
	//car3 = getent( "perif_copcar_03", "targetname" );
	
	copcar_headlight_tags = [ "TAG_light_left_front", "TAG_light_right_front" ];
	copcar_light_tags = [ "TAG_FX_LIGHT_01", "TAG_FX_LIGHT_02", "TAG_FX_LIGHT_03", "TAG_FX_LIGHT_04", "TAG_FX_LIGHT_05" ];
	car = getentarray( "perif_copcar", "targetname" );
	wait_time = (0.1);
	foreach (l in car)
	{
		foreach (tag_headlight in copcar_headlight_tags)
		{
			PlayFXOnTag( getfx( "police_headlight_perif" ), l, tag_headlight);
		}
		wait wait_time;
	}

	foreach (l in car)
	{
		//foreach (tag_coplight in copcar_light_tags)
		//{
			PlayFXOnTag( getfx( "police_light_blue_perif" ), l, "TAG_FX_LIGHT_01");
			wait ( 0.2 );
			PlayFXOnTag( getfx( "police_light_blue_perif" ), l, "TAG_FX_LIGHT_02");
			wait ( 0.2 );
			PlayFXOnTag( getfx( "police_light_blue_perif" ), l, "TAG_FX_LIGHT_03");
			wait ( 0.2 );
			PlayFXOnTag( getfx( "police_light_blue_perif" ), l, "TAG_FX_LIGHT_04");
			wait ( 0.2 );
			PlayFXOnTag( getfx( "police_light_blue_perif" ), l, "TAG_FX_LIGHT_05");
			wait ( 0.2 );
		//}
		wait wait_time;
	}
	 
	//iprintlnbold( "trigger" );
/*
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue_perif" ), car, "TAG_FX_LIGHT_01" );
	wait (0.2);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue_perif" ), car, "TAG_FX_LIGHT_02" );
	wait (0.2);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue_perif" ), car, "TAG_FX_LIGHT_03" );
	wait (0.2);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue_perif" ), car, "TAG_FX_LIGHT_04" );
	wait (0.2);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue_perif" ), car, "TAG_FX_LIGHT_05" );

	///car2
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_headlight_perif" ), car2, "TAG_light_left_front" );
 	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_headlight_perif" ), car2, "TAG_light_right_front" );
	wait (0.1);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue_perif" ), car2, "TAG_FX_LIGHT_01" );
	wait (0.2);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue_perif" ), car2, "TAG_FX_LIGHT_02" );
	wait (0.2);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue_perif" ), car2, "TAG_FX_LIGHT_03" );
	wait (0.2);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue_perif" ), car2, "TAG_FX_LIGHT_04" );
	wait (0.2);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue_perif" ), car2, "TAG_FX_LIGHT_05" );

	///car3
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_headlight_perif" ), car3, "TAG_light_left_front" );
 	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_headlight_perif" ), car3, "TAG_light_right_front" );
	wait (0.1);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue_perif" ), car3, "TAG_FX_LIGHT_01" );
	wait (0.2);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue_perif" ), car3, "TAG_FX_LIGHT_02" );
	wait (0.2);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue_perif" ), car3, "TAG_FX_LIGHT_03" );
	wait (0.2);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue_perif" ), car3, "TAG_FX_LIGHT_04" );
	wait (0.2);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue_perif" ), car3, "TAG_FX_LIGHT_05" );
*/
}

fx_set_hall_spot_params()
{
	setsaveddvar( "r_spotlightstartradius", "10" );
	setsaveddvar( "r_spotlightEndradius", "500" );
	setsaveddvar( "r_spotlightfovinnerfraction", ".5" );
	setsaveddvar( "r_spotlightexponent", "1.0" );
	setsaveddvar( "r_spotlightBrightness", "1.0" );
}

fx_hall_grenade_explode( ally_01 )
{
	//thread turn_on_swinging_light_fx();
	//iprintlnbold( "kaboosh" );
	
	
	exploder ( "hallway_post" );
	
	level._player PlayRumbleOnEntity( "grenade_rumble" );
	wait ( 0.25 );
	stop_exploder ( "hallway_pre" );
	thread maps\nx_exfil_anim::light_swing_spawn();

	thread turn_on_police_car_lights();
}

turn_on_swinging_light_fx( light_swing )
{
	playFXontag( getfx( "fluorescent_spot_01" ), light_swing, "tag_swing_center_fx" );
}

blood_grit_overlay()
{
	// Triggered by rover crash animation notetrack

	// create and define the parameters of the overlay
	blood_grit_overlay = newClientHudElem( level._player );
	blood_grit_overlay.x = 0;
	blood_grit_overlay.y = 0;
	blood_grit_overlay.postfx = true;
//	blood_grit_overlay setshader( "mtl_overlay_grit_default", 640, 480 );
	blood_grit_overlay setshader( "mtl_overlay_blood_default", 640, 480 );
	blood_grit_overlay.sort = 50;
	blood_grit_overlay.alignX = "left";
	blood_grit_overlay.alignY = "top";
	blood_grit_overlay.horzAlign = "fullscreen";
	blood_grit_overlay.vertAlign = "fullscreen";
	blood_grit_overlay fadeovertime( 1 );
	blood_grit_overlay.alpha = 1;
}

spotlight_heli_damage_fx( damage_level )
{
	// damage_level is either: "light", "med", "heavy"
	switch ( damage_level )
	{
		case "light":
			// Hook for light damage
			//Iprintlnbold ("heli:damage:light");
			playFXontag( getfx( "heli_smoke_trail_1" ), self, "origin_animate_joint" );
			break;

		case "med":
			// Hook for med damage
			//Iprintlnbold ("heli:damage:medium");
			playFXontag( getfx( "heli_smoke_trail_1" ), self, "origin_animate_joint" );
			break;

		case "heavy":
			// Hook for heavy damage
			//Iprintlnbold ("heli:damage:heavy");
			playFXontag( getfx( "heli_smoke_trail_1" ), self, "origin_animate_joint" );
			break;

		default:
			assert( "Unrecognized damage_level in maps\nx_exfil_fx::spotlight_heli_damage_fx()" );
			break;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
apply_nx_exfil_fog_()
{	
	VisionSetNaked( "nx_exfil", 0 );
	setExpFog( 0, 5000, 0.4980392, 0.4980392, 0.4980392, 1, 0, 0.953, 0, 0.9490196, 0.8470588, 0.7411765, 0.8666667, 0.9843137, 0.9568627, 1, 1, 1, ( 0, 0, -1 ), 81, 97, 5.48 );	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


