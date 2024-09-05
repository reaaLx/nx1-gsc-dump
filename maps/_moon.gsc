#include maps\_hud_util;

main()
{
	gravity_scale = common_scripts\_moon::getMoonGlobalGravityScale();
	turn_scale = common_scripts\_moon::getMoonGlobalTurnRateScale();
	ads_yaw = common_scripts\_moon::getMoonGlobalADSYaw();
	ads_pitch = common_scripts\_moon::getMoonGlobalADSPitch();

	SetSavedDvar( "phys_global_gravity_scale", gravity_scale );
	SetSavedDvar( "aim_scale_turn_rate", turn_scale );
	SetSavedDvar( "aim_turnrate_pitch_ads", ads_pitch);
	SetSavedDvar( "aim_turnrate_yaw_ads", ads_yaw);
	SetSavedDvar( "environment_pressurized", "0" );
	SetSavedDvar( "environment_moon", "1" );
	
	SetSavedDvar( "cg_minBreathingLevel", "0" );
	SetSavedDvar( "player_breathingLevel2Cutoff", "10000" );
	SetSavedDvar( "player_breathingLevel3Cutoff", "6500" );
	SetSavedDvar( "player_breathingLevel4Cutoff", "3000" );
	SetSavedDvar( "player_breathingLevel5Cutoff", "1000" );

	//these values can be changed to effect the way in which the player behaves in gravity.
	//Setting values to 1.0 will make them behave like on earth. I've given them values here
	//of their defaults, ones that seemed correct for me. They will have no effect without
	//the below call to SetMoonGravity as they are only used in the player movement code.
	//These shouldn't stay dvars, but become #define once we're happy with them.
	//SetSavedDvar( "player_moon_grav_stop_scalar", "0.20");
	//SetSavedDvar( "player_moon_grav_start_scalar", "0.20");
	//SetSavedDvar( "player_moon_grav_speed_scalar", "0.65");

	//These values effect the way in which the player rig behaves in moon gravity.
	//Larger vertical bob amplitude will cause the player to bob higher in their steps.
	//Larger horizontal bob amplitude will give the impression of more sway in the walk.
	//Smaller bob speeds will decrease how quickly the player rig bob cycles, not the actual movement speed.
	//They will have no effect without the below call to SetMoonGravity as they are
	//only used in the player movement code.
	//These shouldn't stay dvars, but become #define once we're happy with them.
	//SetSavedDvar( "weapon_view_moon_vertical_bob_amp", "4.0" );
	//SetSavedDvar( "weapon_view_moon_horizontal_bob_amp", "1.5" );
	//SetSavedDvar( "weapon_view_moon_bob_speed", "0.5" );

	//This value effects the overall height of the jump. Adding in variable jump height, I had to suppress some of
	//jump height because it was getting too high.
	//SetSavedDvar( "player_moon_grav_variable_jump_scalar", "0.5" );

	//These values effect the top speed and the accelleration when in the air specifically in moon gravity.
	//I'd shy away from speed scalars greater than 1.0 since that means that moving while in the air is quicker than on the ground
	//which is the opposite of physically true and feels really obvious. Plus it will result in bunny hopping behavior out of the players.
	//The feeling of control really comes from how quickly can you change directions, which is the accelleration value.
	//SetSavedDvar( "player_moon_grav_air_control_speed_scalar", "1.0");
	//SetSavedDvar( "player_moon_grav_air_control_accel_scalar", "1.0");

	//To add a bit of play when in moon grav, allow a jump when falling. The value set here is the period of time
	//after freefall is detected before no longer allowing jump.
	//SetSavedDvar( "player_moon_grav_late_jump_period", "200");

	// SP MOON PLAYER CONTROL TUNING
	// MOVEMENT
	SetSavedDvar( "player_moon_grav_stop_scalar", "0.25" );		// 0.2 on 1/28
	SetSavedDvar( "player_moon_grav_start_scalar", "0.25" ); 	// 0.2 on 1/28
	SetSavedDvar( "player_moon_grav_speed_scalar", "0.80" );	// 0.7 on 9/14 // 0.65 on 1/28

	// JUMPING 
	SetSavedDvar( "player_moon_grav_variable_jump_scalar", "0.5" );
	SetSavedDvar( "player_moon_grav_variable_jump_period", "500" );
	SetSavedDvar( "player_moon_grav_late_jump_period", "200" );
	SetSavedDvar( "player_moon_grav_jump_boost_scalar", "1.05" ); // 1.2 on 9/15 (player hitting head in nx_lava platforming section - BMcD)

	// WHAT ABOUT BOB?
	SetSavedDvar( "weapon_view_moon_vertical_bob_amp", "5.0" );
	SetSavedDvar( "weapon_view_moon_horizontal_bob_amp", "1.5" );
	SetSavedDvar( "weapon_view_moon_bob_speed", "0.5" );

	// RAGDOLL TWEAKS FOR LUNAR GRAVITY
	SetSavedDvar( "ragdoll_max_life", 10000 );	// allow ragdolls to live for twice as long as normal

   	//precaches needed for volume control down below.... Name should match the shock file named in the volume setting
	//defined in _equalizer.gsc. The "_moon" extension is based off the suit type supported.
	PreCacheShellShock( "lunar_depressurized" );
	PreCacheShellShock( "lunar_pressurized" );
	
	PreCacheItem( "moon_grenade" );

	//PreCacheShellShock( "moon_engsuit_depres_helmet_off" );
	//PreCacheShellShock( "moon_engsuit_depres_helmet_on" );
	//PreCacheShellShock( "moon_engsuit_pres_helmet_off" );
	//PreCacheShellShock( "moon_engsuit_pres_helmet_on" );

	//PreCacheShellShock( "moon_milsuit_depres_helmet_off" );
	//PreCacheShellShock( "moon_milsuit_depres_helmet_on" );
	//PreCacheShellShock( "moon_milsuit_pres_helmet_off" );
	//PreCacheShellShock( "moon_milsuit_pres_helmet_on" );

	level._player SetMoonGravity( true );
	
	level._player maps\_utility::set_suit( "moon" );

	level._player set_suit_hud_type( "military" );
	SetSavedDvar( "r_warp_enable_bob", true );
	
	//tagCC<TODO>: Currently leaving the moon sounds out because it won't work well with the current aliases in nx_lunar, 
	//and I'd like to get the per channel volume in before turning this on so aliases can be removed all at once and have
	//everything sound right.
	level thread set_moon_sounds();
		
	level._effect[ "blood_pool_vacuum" ] = loadFX( "nx/impacts/nx_deathfx_bloodpool_vacuum" );
	
}

set_moon_sounds()
{
	level._player_helmet_loop = "null_loop";
	soundent = spawn( "sound_emitter", level._player.origin );
	soundent linkto( level._player );
	soundent set_suit_helmet_loop();

	//wait 0.1;//adding this lame wait because setting these immediately causes a server cmd overflow. Raise the buffer?
	//level thread maps\_ambient::setup_new_eq_settings( "lunar_depressurized", level._eq_main_track );
	//level thread maps\_ambient::setup_new_eq_settings( "nx_lunar_int", level._eq_mix_track ); //the muting effect happens by volume.
	//level thread maps\_ambient::setup_new_reverb_settings( "nx_lunar" );
	//level thread maps\_ambient::setup_new_volume_settings( "lunar_depressurized" );
}

set_suit_helmet_loop()
{
	current_player_helmet_loop = level._player_helmet_loop;

	if ( IsDefined( level._player_helmet_loop ) )	
	{
		new_helmet_loop = level._player_helmet_loop;	

		while( 1 )
		{
			if( new_helmet_loop != current_player_helmet_loop )
			{
				self StopLoopSound( current_player_helmet_loop );
				self playloopsound( level._player_helmet_loop );
			}	
					
			current_player_helmet_loop = level._player_helmet_loop;
	
			wait( 0.05 );
		}
	}
}

set_suit_hud_type( type )
{
	splatter_material = "splatter_alt_sp";

	switch ( type )
	{
		case "none":
			SetSavedDvar( "lunar_hud", type );
			break;

		case "civilian":
			SetSavedDvar( "lunar_hud", type );
			splatter_material = "blood_defocus_moon";
			break;

		case "military":
			SetSavedDvar( "lunar_hud", type );
			splatter_material = "blood_defocus_moon";
			break;

		default:
			IPrintLn( "Unknown suit overlay type" + type );
	}

	level._splatter_overlay SetShader( splatter_material, 640, 480 );
}
