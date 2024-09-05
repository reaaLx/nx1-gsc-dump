#include maps\_utility;
#include common_scripts\utility;
#using_animtree( "ac130" );

init( player )
{
	// init all context sensative dialog
	maps\_ac130_snd::main();
	
	// co-op: player not used anymore
	//assert( isdefined( player ) );
	//assert( player.classname == "player" );

	setDvarIfUninitialized( "ac130_enabled", "1" );
	setDvarIfUninitialized( "ac130_post_effects_enabled", "1" );
	setDvarIfUninitialized( "ac130_debug_weapons", "0" );
	setDvarIfUninitialized( "ac130_debug_context_sensative_dialog", "0" );
	setDvarIfUninitialized( "ac130_debug_friendly_count", "0" );
	setDvarIfUninitialized( "ac130_hud_text_misc", "1" );
	setDvarIfUninitialized( "ac130_hud_text_thermal", "1" );
	setDvarIfUninitialized( "ac130_hud_text_weapons", "1" );
	setDvarIfUninitialized( "ac130_target_markers", "0" );
	setDvarIfUninitialized( "ac130_thermal_enabled", "1" );

	//0 - player can freely engage targets before being authorized
	//1 - player fails the mission for engage targets before being authorized
	//2 - player gets red X over crosshairs when trying to fire before being authorized
	setDvarIfUninitialized( "ac130_pre_engagement_mode", "2" );
	setDvarIfUninitialized( "ac130_alternate_controls", "0" );
	setDvarIfUninitialized( "ac130_ragdoll_deaths", "1" );

	precacheShader( "ac130_overlay_25mm" );
	precacheShader( "ac130_overlay_40mm" );
	precacheShader( "ac130_overlay_105mm" );
	precacheShader( "ac130_overlay_grain" );
	precacheShader( "ac130_overlay_nofire" );
	precacheShader( "ac130_hud_target" );
	precacheShader( "ac130_hud_target_flash" );
	precacheShader( "ac130_hud_target_offscreen" );
	precacheShader( "ac130_friendly_fire_icon" );
	precacheShader( "black" );

	// \n0         A-G        MAN    NARO
	precacheString( &"AC130_HUD_TOP_BAR" );
	// RAY\nFF 30\nLIR\n\nBORE
	precacheString( &"AC130_HUD_LEFT_BLOCK" );
	// N\nT\n\nS\nF\n\nQ\nZ\n\nT\nG\nT
	precacheString( &"AC130_HUD_RIGHT_BLOCK" );
	precacheString( &"AC130_HUD_RIGHT_BLOCK_SHORT" );
	// L1514    RDY
	precacheString( &"AC130_HUD_BOTTOM_BLOCK" );
	// WHOT
	precacheString( &"AC130_HUD_THERMAL_WHOT" );
	// BHOT
	precacheString( &"AC130_HUD_THERMAL_BHOT" );
	// 105 mm
	precacheString( &"AC130_HUD_WEAPON_105MM" );
	// 40 mm
	precacheString( &"AC130_HUD_WEAPON_40MM" );
	// 25 mm
	precacheString( &"AC130_HUD_WEAPON_25MM" );
	// &&1 AGL
	precacheString( &"AC130_HUD_AGL" );
	// Press ^3[{weapnext}]^7 to cycle through weapons.
	precachestring( &"AC130_HINT_CYCLE_WEAPONS" );
	// Friendlies: &&1
	precachestring( &"AC130_DEBUG_FRIENDLY_COUNT" );
	// Too many friendlies have been KIA. Mission failed.
	precachestring( &"AC130_FRIENDLIES_DEAD" );
	// Friendly fire will not be tolerated!\nWatch for blinking IR strobes on friendly units!
	precachestring( &"AC130_FRIENDLY_FIRE" );
	// Provide AC-130 air support for friendly SAS ground units.
	

	// Pull [{+speed}] to control zoom and  pull [{+attack}] to fire.
	precachestring( &"SCRIPT_PLATFORM_AC130_HINT_ZOOM_AND_FIRE" );
	// Press [{+usereload}] to toggle thermal vision\nbetween white hot and black hot.
	precachestring( &"SCRIPT_PLATFORM_AC130_HINT_TOGGLE_THERMAL" );

	// Provide AC-130 air support for friendly ground units.
	precachestring( &"CO_AC130_OBJECTIVE_COOP_AC130_GUNNER" );
	// Regroup with any survivors from Bravo Team at the crash site.
	precachestring( &"CO_AC130_OBJECTIVE_COOP_GROUND_PLAYER" );
	
	precacheShader( "popmenu_bg" );
	
	if ( is_coop() )
		precacheModel( "vehicle_ac130_coop" );

	if ( getdvar( "ac130_alternate_controls", "0" ) == "0" )
	{
		precacheItem( "ac130_25mm" );
		precacheItem( "ac130_40mm" );
		precacheItem( "ac130_105mm" );
	}
	else
	{
		precacheItem( "ac130_25mm_alt" );
		precacheItem( "ac130_40mm_alt" );
		precacheItem( "ac130_105mm_alt" );
	}

	precacheShellShock( "ac130" );

	level._effect[ "cloud" ] = loadfx( "misc/ac130_cloud" );

	//if ( is_coop() )
		level._effect[ "beacon" ] = loadfx( "misc/ir_beacon_coop" );
	//else
		//level._effect[ "beacon" ] = loadfx( "misc/ir_beacon" );

	// ac130 muzzleflash effects for player on ground to see
	level._effect[ "coop_muzzleflash_105mm" ] = loadfx( "muzzleflashes/ac130_105mm" );
	level._effect[ "coop_muzzleflash_40mm" ] = loadfx( "muzzleflashes/ac130_40mm" );

	level._custom_friendly_fire_message = "@AC130_FRIENDLY_FIRE";
	level._custom_friendly_fire_shader = "ac130_friendly_fire_icon";

	level._spawnerCallbackThread = ::spawn_callback_thread;
	level._vehicleSpawnCallbackThread = ::context_Sensative_Dialog_VehicleSpawn;

	level._enemiesKilledInTimeWindow = 0;

	level._radioForcedTransmissionQueue = [];

	level._lastRadioTransmission = getTime();

	level._color[ "white" ] = ( 1, 1, 1 );
	level._color[ "red" ] = ( 1, 0, 0 );
	level._color[ "blue" ] = ( .1, .3, 1 );

	level._cosine = [];
	level._cosine[ "45" ] = cos( 45 );
	level._cosine[ "5" ] = cos( 5 );

	level._badplaceCount = 0;
	level._badplaceMax = 15;

	level._badplaceRadius[ "ac130_25mm" ] = 800;
	level._badplaceRadius[ "ac130_40mm" ] = 1000;
	level._badplaceRadius[ "ac130_105mm" ] = 1600;
	level._badplaceRadius[ "ac130_25mm_alt" ] = level._badplaceRadius[ "ac130_25mm" ];
	level._badplaceRadius[ "ac130_40mm_alt" ] = level._badplaceRadius[ "ac130_40mm" ];
	level._badplaceRadius[ "ac130_105mm_alt" ] = level._badplaceRadius[ "ac130_105mm" ];

	level._badplaceDuration[ "ac130_25mm" ] = 2.0;
	level._badplaceDuration[ "ac130_40mm" ] = 9.0;
	level._badplaceDuration[ "ac130_105mm" ] = 12.0;
	level._badplaceDuration[ "ac130_25mm_alt" ] = level._badplaceDuration[ "ac130_25mm" ];
	level._badplaceDuration[ "ac130_40mm_alt" ] = level._badplaceDuration[ "ac130_40mm" ];
	level._badplaceDuration[ "ac130_105mm_alt" ] = level._badplaceDuration[ "ac130_105mm" ];

	level._physicsSphereRadius[ "ac130_25mm" ] = 60;
	level._physicsSphereRadius[ "ac130_40mm" ] = 600;
	level._physicsSphereRadius[ "ac130_105mm" ] = 1000;
	level._physicsSphereRadius[ "ac130_25mm_alt" ] = level._physicsSphereRadius[ "ac130_25mm" ];
	level._physicsSphereRadius[ "ac130_40mm_alt" ] = level._physicsSphereRadius[ "ac130_40mm" ];
	level._physicsSphereRadius[ "ac130_105mm_alt" ] = level._physicsSphereRadius[ "ac130_105mm" ];

	level._physicsSphereForce[ "ac130_25mm" ] = 0;
	level._physicsSphereForce[ "ac130_40mm" ] = 3.0;
	level._physicsSphereForce[ "ac130_105mm" ] = 6.0;
	level._physicsSphereForce[ "ac130_25mm_alt" ] = level._physicsSphereForce[ "ac130_25mm" ];
	level._physicsSphereForce[ "ac130_40mm_alt" ] = level._physicsSphereForce[ "ac130_40mm" ];
	level._physicsSphereForce[ "ac130_105mm_alt" ] = level._physicsSphereForce[ "ac130_105mm" ];

	level._weaponReloadTime[ "ac130_25mm" ] = 0.05;
	level._weaponReloadTime[ "ac130_40mm" ] = 0.5;
	level._weaponReloadTime[ "ac130_105mm" ] = 6.0;
	level._weaponReloadTime[ "ac130_25mm_alt" ] = level._weaponReloadTime[ "ac130_25mm" ];
	level._weaponReloadTime[ "ac130_40mm_alt" ] = level._weaponReloadTime[ "ac130_40mm" ];
	level._weaponReloadTime[ "ac130_105mm_alt" ] = level._weaponReloadTime[ "ac130_105mm" ];

	level._weaponFriendlyCloseDistance[ "ac130_25mm" ] = 150;
	level._weaponFriendlyCloseDistance[ "ac130_40mm" ] = 500;
	level._weaponFriendlyCloseDistance[ "ac130_105mm" ] = 1000;
	level._weaponFriendlyCloseDistance[ "ac130_25mm_alt" ] = level._weaponFriendlyCloseDistance[ "ac130_25mm" ];
	level._weaponFriendlyCloseDistance[ "ac130_40mm_alt" ] = level._weaponFriendlyCloseDistance[ "ac130_40mm" ];
	level._weaponFriendlyCloseDistance[ "ac130_105mm_alt" ] = level._weaponFriendlyCloseDistance[ "ac130_105mm" ];

	level._weaponReadyToFire[ "ac130_25mm" ] = true;
	level._weaponReadyToFire[ "ac130_40mm" ] = true;
	level._weaponReadyToFire[ "ac130_105mm" ] = true;
	level._weaponReadyToFire[ "ac130_25mm_alt" ] = level._weaponReadyToFire[ "ac130_25mm" ];
	level._weaponReadyToFire[ "ac130_40mm_alt" ] = level._weaponReadyToFire[ "ac130_40mm" ];
	level._weaponReadyToFire[ "ac130_105mm_alt" ] = level._weaponReadyToFire[ "ac130_105mm" ];

	level._ac130_Speed[ "move" ] = 250;
	level._ac130_Speed[ "rotate" ] = 70;

	level._enemiesKilledByPlayer = 0;

	//flag_init( "ir_beakons_on" );
	flag_init( "allow_context_sensative_dialog" );
	flag_init( "clear_to_engage" );
	flag_init( "player_changed_weapons" );

	level._ac130 = spawn( "script_model", level._player getOrigin() );
	level._ac130 setModel( "c130_zoomrig" );
	level._ac130.angles = ( 0, level._player.angles[ 1 ], 0 );

	// preaching done
	// first wait command called below
	// no more coop ac130 - just assume level.player is the gunner
	if ( !isdefined( player ) )
	{
		flag_wait( "character_selected" );	
		level._ac130player = maps\_loadout::coop_gamesetup_ac130();// coop_gamesetup();
	}
	else
	{
		level._ac130player = player;
	}
	
	level._ac130gunner = level._ac130player;

	level._ac130player takeallweapons();
	level._ac130player.ignoreme = true;

	level._ac130player ThermalVisionOn();
	level._ac130player ThermalVisionFOFOverlayOn();
	level._ac130player LaserAltViewOn();

	level._ac130_fontscale = 2.5;
	level._ac130_crosshair_size_x = 640;
	level._ac130_crosshair_size_y = 480;
	level._ac130_right_hud_offset = 0;
	level._ac130_left_hud_offset = 0;

	if ( IsSplitscreen() )
	{
		level._ac130_fontscale = 1.5;
		level._ac130_crosshair_size_x = int( 640 * 0.8 );
		level._ac130_crosshair_size_y = int( 480 * 0.8 );

		if ( level._ac130player == level._player )
		{
			level._ac130_left_hud_offset = 0;
			level._ac130_right_hud_offset = -20;
		}
		else
		{
			level._ac130_left_hud_offset = 20;
			level._ac130_right_hud_offset = 0;
		}
	}

	if ( is_coop() )
	{
		level._ac130player hide();
		level._ac130player.has_no_ir = true;
	}

	setsaveddvar( "scr_dof_enable", "0" );
	// reset ac130 position after character switch
	level._ac130.origin = level._ac130player getOrigin();
	level._ac130 hide();

	if ( getdvar( "ac130_alternate_controls", "0" ) == "0" )
	{
		level._ac130player giveweapon( "ac130_105mm" );
		level._ac130player switchtoweapon( "ac130_105mm" );
	}
	else
	{
		level._ac130player giveweapon( "ac130_105mm_alt" );
		level._ac130player switchtoweapon( "ac130_105mm_alt" );
	}
	level._ac130player SetActionSlot( 1, "" );
	Setammo();
	
	if ( getdvar( "ac130_enabled", "1" ) == "1" )
	{
		thread overlay();
		thread HUDItemsOff();
		thread attachPlayer();
		thread changeWeapons();
		thread weaponFiredThread();
		thread thermalVision();
		if ( getdvar( "ac130_pre_engagement_mode", "2" ) == "1" )
			thread failMissionForEngaging();
		if ( getdvar( "ac130_pre_engagement_mode", "2" ) == "2" )
			thread nofireCrossHair();
		thread context_Sensative_Dialog();
		thread shotFired();
		thread clouds();
		thread maps\_ac130_amb::main();
		thread rotatePlane( "on" );
		thread hud_target_blink_timer();
		thread ac130_spawn();
	}
}

ac130_spawn()
{
	wait 0.05;
	if ( !is_coop() )
		return;

	ac130model = spawn( "script_model", level._ac130 getTagOrigin( "tag_player" ) );
	ac130model setModel( "vehicle_ac130_coop" );

	ac130model playLoopSound( "veh_ac130_ext_dist" );
	
	ac130model linkTo( level._ac130, "tag_player", ( 0, 0, 100 ), ( -25, 0, 0 ) );
}

overlay()
{
	wait 0.05;
	if ( isdefined( level._doing_cinematic ) )
		level waittill( "introscreen_black" );

	level._HUDItem = [];

	level._HUDItem[ "crosshairs" ] = newClientHudElem( level._ac130player );
	level._HUDItem[ "crosshairs" ].x = 0;
	level._HUDItem[ "crosshairs" ].y = 0;
	level._HUDItem[ "crosshairs" ].alignX = "center";
	level._HUDItem[ "crosshairs" ].alignY = "middle";
	level._HUDItem[ "crosshairs" ].horzAlign = "center";
	level._HUDItem[ "crosshairs" ].vertAlign = "middle";
	level._HUDItem[ "crosshairs" ] setshader( "ac130_overlay_105mm", level._ac130_crosshair_size_x, level._ac130_crosshair_size_y );
	level._HUDItem[ "crosshairs" ].sort = -2;

	if ( getdvar( "ac130_hud_text_misc", "1" ) == "1" )
	{
		level._HUDItem[ "hud_text_top" ] = newClientHudElem( level._ac130player );
		level._HUDItem[ "hud_text_top" ].x = 0 + level._ac130_left_hud_offset;
		level._HUDItem[ "hud_text_top" ].y = 0;
		level._HUDItem[ "hud_text_top" ].alignX = "left";
		level._HUDItem[ "hud_text_top" ].alignY = "top";
		level._HUDItem[ "hud_text_top" ].horzAlign = "left";
		level._HUDItem[ "hud_text_top" ].vertAlign = "top";
		level._HUDItem[ "hud_text_top" ].fontScale = level._ac130_fontscale;
		// \n0         A-G        MAN    NARO
		level._HUDItem[ "hud_text_top" ] settext( &"AC130_HUD_TOP_BAR" );
		level._HUDItem[ "hud_text_top" ].alpha = 1.0;

		level._HUDItem[ "hud_text_left" ] = newClientHudElem( level._ac130player );
		level._HUDItem[ "hud_text_left" ].x = 0 + level._ac130_left_hud_offset;
		level._HUDItem[ "hud_text_left" ].y = 60;
		level._HUDItem[ "hud_text_left" ].alignX = "left";
		level._HUDItem[ "hud_text_left" ].alignY = "top";
		level._HUDItem[ "hud_text_left" ].horzAlign = "left";
		level._HUDItem[ "hud_text_left" ].vertAlign = "top";
		level._HUDItem[ "hud_text_left" ].fontScale = level._ac130_fontscale;
		// RAY\nFF 30\nLIR\n\nBORE
		level._HUDItem[ "hud_text_left" ] settext( &"AC130_HUD_LEFT_BLOCK" );
		level._HUDItem[ "hud_text_left" ].alpha = 1.0;

		level._HUDItem[ "hud_text_right" ] = newClientHudElem( level._ac130player );
		level._HUDItem[ "hud_text_right" ].x = 0 + level._ac130_right_hud_offset;
		level._HUDItem[ "hud_text_right" ].y = 50;
		level._HUDItem[ "hud_text_right" ].alignX = "right";
		level._HUDItem[ "hud_text_right" ].alignY = "top";
		level._HUDItem[ "hud_text_right" ].horzAlign = "right";
		level._HUDItem[ "hud_text_right" ].vertAlign = "top";
		level._HUDItem[ "hud_text_right" ].fontScale = level._ac130_fontscale;

		// N\nT\n\nS\nF\n\nQ\nZ\n\nT\nG\nT
		if ( IsSplitscreen() )
		{
			level._HUDItem[ "hud_text_right" ] settext( &"AC130_HUD_RIGHT_BLOCK_SHORT" );
		}
		else
		{
			level._HUDItem[ "hud_text_right" ] settext( &"AC130_HUD_RIGHT_BLOCK" );
		}

		level._HUDItem[ "hud_text_right" ].alpha = 1.0;

		level._HUDItem[ "hud_text_bottom" ] = newClientHudElem( level._ac130player );
		level._HUDItem[ "hud_text_bottom" ].x = 0;
		level._HUDItem[ "hud_text_bottom" ].y = 0;
		level._HUDItem[ "hud_text_bottom" ].alignX = "center";
		level._HUDItem[ "hud_text_bottom" ].alignY = "bottom";
		level._HUDItem[ "hud_text_bottom" ].horzAlign = "center";
		level._HUDItem[ "hud_text_bottom" ].vertAlign = "bottom";
		level._HUDItem[ "hud_text_bottom" ].fontScale = level._ac130_fontscale;
		// L1514    RDY
		level._HUDItem[ "hud_text_bottom" ] settext( &"AC130_HUD_BOTTOM_BLOCK" );
		level._HUDItem[ "hud_text_bottom" ].alpha = 1.0;
	}

	if ( getdvar( "ac130_hud_text_thermal", "1" ) == "1" )
	{
		level._HUDItem[ "thermal_mode" ] = newClientHudElem( level._ac130player );
		level._HUDItem[ "thermal_mode" ].x = -80 + level._ac130_right_hud_offset;
		level._HUDItem[ "thermal_mode" ].y = 50;
		level._HUDItem[ "thermal_mode" ].alignX = "right";
		level._HUDItem[ "thermal_mode" ].alignY = "top";
		level._HUDItem[ "thermal_mode" ].horzAlign = "right";
		level._HUDItem[ "thermal_mode" ].vertAlign = "top";
		level._HUDItem[ "thermal_mode" ].fontScale = level._ac130_fontscale;
		// WHOT
		level._HUDItem[ "thermal_mode" ] settext( &"AC130_HUD_THERMAL_WHOT" );
		level._HUDItem[ "thermal_mode" ].alpha = 1.0;
	}

	if ( getdvar( "ac130_hud_text_weapons", "1" ) == "1" )
	{
		level._HUDItem[ "weapon_text" ][ 0 ] = newClientHudElem( level._ac130player );
		level._HUDItem[ "weapon_text" ][ 0 ].x = 0 + level._ac130_left_hud_offset;
		level._HUDItem[ "weapon_text" ][ 0 ].y = 0;
		level._HUDItem[ "weapon_text" ][ 0 ].alignX = "left";
		level._HUDItem[ "weapon_text" ][ 0 ].alignY = "bottom";
		level._HUDItem[ "weapon_text" ][ 0 ].horzAlign = "left";
		level._HUDItem[ "weapon_text" ][ 0 ].vertAlign = "bottom";
		level._HUDItem[ "weapon_text" ][ 0 ].fontScale = level._ac130_fontscale;
		// 105 mm
		level._HUDItem[ "weapon_text" ][ 0 ] settext( &"AC130_HUD_WEAPON_105MM" );
		level._HUDItem[ "weapon_text" ][ 0 ].alpha = 1.0;

		level._HUDItem[ "weapon_text" ][ 1 ] = newClientHudElem( level._ac130player );
		level._HUDItem[ "weapon_text" ][ 1 ].x = 0 + level._ac130_left_hud_offset;
		level._HUDItem[ "weapon_text" ][ 1 ].y = -30;
		level._HUDItem[ "weapon_text" ][ 1 ].alignX = "left";
		level._HUDItem[ "weapon_text" ][ 1 ].alignY = "bottom";
		level._HUDItem[ "weapon_text" ][ 1 ].horzAlign = "left";
		level._HUDItem[ "weapon_text" ][ 1 ].vertAlign = "bottom";
		level._HUDItem[ "weapon_text" ][ 1 ].fontScale = level._ac130_fontscale;
		// 40 mm
		level._HUDItem[ "weapon_text" ][ 1 ] settext( &"AC130_HUD_WEAPON_40MM" );
		level._HUDItem[ "weapon_text" ][ 1 ].alpha = 1.0;

		level._HUDItem[ "weapon_text" ][ 2 ] = newClientHudElem( level._ac130player );
		level._HUDItem[ "weapon_text" ][ 2 ].x = 0 + level._ac130_left_hud_offset;
		level._HUDItem[ "weapon_text" ][ 2 ].y = -60;
		level._HUDItem[ "weapon_text" ][ 2 ].alignX = "left";
		level._HUDItem[ "weapon_text" ][ 2 ].alignY = "bottom";
		level._HUDItem[ "weapon_text" ][ 2 ].horzAlign = "left";
		level._HUDItem[ "weapon_text" ][ 2 ].vertAlign = "bottom";
		level._HUDItem[ "weapon_text" ][ 2 ].fontScale = level._ac130_fontscale;
		// 25 mm
		level._HUDItem[ "weapon_text" ][ 2 ] settext( &"AC130_HUD_WEAPON_25MM" );
		level._HUDItem[ "weapon_text" ][ 2 ].alpha = 1.0;
	}

	thread hud_timer();
	thread overlay_coords();
	thread blink_hud_elem( 0 );

	if ( getdvar( "ac130_thermal_enabled", "1" ) == "1" )
	{
		level._HUDItem[ "grain" ] = newClientHudElem( level._ac130player );
		level._HUDItem[ "grain" ].x = 0;
		level._HUDItem[ "grain" ].y = 0;
		level._HUDItem[ "grain" ].alignX = "left";
		level._HUDItem[ "grain" ].alignY = "top";
		level._HUDItem[ "grain" ].horzAlign = "fullscreen";
		level._HUDItem[ "grain" ].vertAlign = "fullscreen";
		level._HUDItem[ "grain" ] setshader( "ac130_overlay_grain", 640, 480 );
		level._HUDItem[ "grain" ].alpha = 0.4;
		level._HUDItem[ "grain" ].sort = -3;
	}

	if ( getdvar( "ac130_thermal_enabled", "1" ) == "1" )
		thread ac130ShellShock();

	wait 0.05;


	if ( !is_coop() )
		setsaveddvar( "g_friendlynamedist", 0 );
	else
		setsaveddvar( "g_friendlynamedist", 2000 );

	// sets dvar for ac130 player number for menu to hide the correct HUD components
	setdvar( "ac130_player_num", 1 );
	if ( level._ac130player == level._player )
		setdvar( "ac130_player_num", 0 );

	if ( !is_coop() )
		setsaveddvar( "compass", 0 );

	if ( getdvar( "ac130_thermal_enabled", "1" ) == "1" )
	{
		level._ac130player SetBlurForPlayer( 1.2, 0 );
	}
}

HUDItemsOff()
{
	for ( ;; )
	{
		if ( getdvarint( "ac130_post_effects_enabled", 1 ) == 0 )
			break;
		wait 1.0;
	}

	level notify( "post_effects_disabled" );

	level._ac130player SetBlurForPlayer( 0, 0 );

	hud_items = [];
	hud_items[ hud_items.size ] = "hud_text_top";
	hud_items[ hud_items.size ] = "hud_text_left";
	hud_items[ hud_items.size ] = "hud_text_right";
	hud_items[ hud_items.size ] = "hud_text_bottom";
	hud_items[ hud_items.size ] = "thermal_mode";
	hud_items[ hud_items.size ] = "grain";
	hud_items[ hud_items.size ] = "timer";
	hud_items[ hud_items.size ] = "coordinate_long";
	hud_items[ hud_items.size ] = "coordinate_lat";
	hud_items[ hud_items.size ] = "coordinate_agl";

	for ( i = 0 ; i < hud_items.size ; i++ )
	{
		if ( isdefined( level._HUDItem[ hud_items[ i ] ] ) )
			level._HUDItem[ hud_items[ i ] ] destroy();
	}
}

hud_timer()
{
	if ( is_specialop() )
	{
		return;
	}

	if ( getdvar( "ac130_hud_text_misc", "1" ) == "0" )
		return;

	level endon( "post_effects_disabled" );

	level._HUDItem[ "timer" ] = newClientHudElem( level._ac130player );
	level._HUDItem[ "timer" ].x = -100;
	level._HUDItem[ "timer" ].y = 0;
	level._HUDItem[ "timer" ].alignX = "right";
	level._HUDItem[ "timer" ].alignY = "bottom";
	level._HUDItem[ "timer" ].horzAlign = "right";
	level._HUDItem[ "timer" ].vertAlign = "bottom";
	level._HUDItem[ "timer" ].fontScale = level._ac130_fontscale;
	level._HUDItem[ "timer" ] setTimer( 1.0 );
	level._HUDItem[ "timer" ].alpha = 1.0;

	level waittill( "start_clock" );

	level._HUDItem[ "timer" ] setTimerUp( 1.0 );
}

overlay_coords()
{
	if ( getdvar( "ac130_hud_text_misc", "1" ) == "0" )
		return;

	level._HUDItem[ "coordinate_long" ] = newClientHudElem( level._ac130player );
	level._HUDItem[ "coordinate_long" ].x = -100 + level._ac130_right_hud_offset;
	level._HUDItem[ "coordinate_long" ].y = 0;
	level._HUDItem[ "coordinate_long" ].alignX = "right";
	level._HUDItem[ "coordinate_long" ].alignY = "top";
	level._HUDItem[ "coordinate_long" ].horzAlign = "right";
	level._HUDItem[ "coordinate_long" ].vertAlign = "top";
	level._HUDItem[ "coordinate_long" ].fontScale = level._ac130_fontscale;
	level._HUDItem[ "coordinate_long" ].alpha = 1.0;

	level._HUDItem[ "coordinate_lat" ] = newClientHudElem( level._ac130player );
	level._HUDItem[ "coordinate_lat" ].x = 0 + level._ac130_right_hud_offset;
	level._HUDItem[ "coordinate_lat" ].y = 0;
	level._HUDItem[ "coordinate_lat" ].alignX = "right";
	level._HUDItem[ "coordinate_lat" ].alignY = "top";
	level._HUDItem[ "coordinate_lat" ].horzAlign = "right";
	level._HUDItem[ "coordinate_lat" ].vertAlign = "top";
	level._HUDItem[ "coordinate_lat" ].fontScale = level._ac130_fontscale;
	level._HUDItem[ "coordinate_lat" ].alpha = 1.0;

	level._HUDItem[ "coordinate_agl" ] = newClientHudElem( level._ac130player );
	level._HUDItem[ "coordinate_agl" ].x = 0 + level._ac130_right_hud_offset;
	level._HUDItem[ "coordinate_agl" ].y = 20;
	level._HUDItem[ "coordinate_agl" ].alignX = "right";
	level._HUDItem[ "coordinate_agl" ].alignY = "top";
	level._HUDItem[ "coordinate_agl" ].horzAlign = "right";
	level._HUDItem[ "coordinate_agl" ].vertAlign = "top";
	level._HUDItem[ "coordinate_agl" ].fontScale = level._ac130_fontscale;
	// &&1 AGL
	level._HUDItem[ "coordinate_agl" ].label = ( &"AC130_HUD_AGL" );
	level._HUDItem[ "coordinate_agl" ].alpha = 1.0;

	level endon( "post_effects_disabled" );

	wait 0.05;
	for ( ;; )
	{
		level._HUDItem[ "coordinate_long" ] setValue( abs( int( level._ac130player.origin[ 0 ] ) ) );
		level._HUDItem[ "coordinate_lat" ] setValue( abs( int( level._ac130player.origin[ 1 ] ) ) );

		pos = physicstrace( level._ac130player.origin, level._ac130player.origin - ( 0, 0, 100000 ) );
		if ( ( isdefined( pos ) ) && ( isdefined( pos[ 2 ] ) ) )
		{
			alt = ( ( level._ac130player.origin[ 2 ] - pos[ 2 ] ) * 1.5 );
			level._HUDItem[ "coordinate_agl" ] setValue( abs( int( alt ) ) );
		}

		wait( 0.75 + randomfloat( 2 ) );
	}
}

ac130ShellShock()
{
	level endon( "post_effects_disabled" );
	duration = 5;
	for ( ;; )
	{
		level._ac130player shellshock( "ac130", duration );
		wait duration;
	}
}

rotatePlane( toggle )
{
	level notify( "stop_rotatePlane_thread" );
	level endon( "stop_rotatePlane_thread" );

	if ( toggle == "on" )
	{
		rampupDegrees = 10;
		rotateTime = ( level._ac130_Speed[ "rotate" ] / 360 ) * rampupDegrees;
		level._ac130 rotateyaw( level._ac130.angles[ 2 ] + rampupDegrees, rotateTime, rotateTime, 0 );

		for ( ;; )
		{
			level._ac130 rotateyaw( 360, level._ac130_Speed[ "rotate" ] );
			wait level._ac130_Speed[ "rotate" ];
		}
	}
	else if ( toggle == "off" )
	{
		slowdownDegrees = 10;
		rotateTime = ( level._ac130_Speed[ "rotate" ] / 360 ) * slowdownDegrees;
		level._ac130 rotateyaw( level._ac130.angles[ 2 ] + slowdownDegrees, rotateTime, 0, rotateTime );
	}
}

attachPlayer()
{
	level._ac130player playerLinkToDelta( level._ac130, "tag_player", 1.0, 65, 65, 40, 40 );
	wait 0.05;
	level._ac130player allowProne( false );
	level._ac130player allowCrouch( false );
	level._ac130player setplayerangles( level._ac130 getTagAngles( "tag_player" ) );

	if ( !is_coop() )
	{
		SetSavedDvar( "ammoCounterHide", "1" );
		SetSavedDvar( "hud_showStance", 0 );
	}
}

getRealAC130Angles()
{
	angle = level._ac130.angles[ 1 ];
	while ( angle >= 360 )
		angle -= 360;
	while ( angle < 0 )
		angle += 360;
	return angle;
}

getFlyingAC130AnglesToPoint( vec )
{
	destAng = vectorToAngles( level._ac130.origin - vec );
	destAng = destAng[ 1 ] + 90;
	while ( destAng >= 360 )
		destAng -= 360;
	while ( destAng < 0 )
		destAng += 360;
	return destAng;
}

movePlaneToWaypoint( sWaypointTargetname, rotationWait )
{
	assert( isdefined( sWaypointTargetname ) );
	waypoint = getent( sWaypointTargetname, "targetname" );
	assert( isdefined( waypoint ) );
	assert( isdefined( waypoint.origin ) );
	movePlaneToPoint( waypoint.origin, rotationWait );
}

movePlaneToPoint( coordinate, rotationWait )
{
	level notify( "ac130_reposition" );
	level endon( "ac130_reposition" );

	if ( !isdefined( rotationWait ) )
		rotationWait = false;

	d = distance( level._ac130.origin, coordinate );
	moveTime = ( d / level._ac130_Speed[ "move" ] );
	if ( moveTime <= 0 )
		return;
	accel = moveTime / 2;
	decel = moveTime / 2;

	if ( rotationWait )
	{
		thread rotatePlane( "off" );

		// find how many more degrees the plane should turn before facing the right direction
		angDiff = getFlyingAC130AnglesToPoint( coordinate ) - getRealAC130Angles();
		if ( angDiff < 0 )
			angDiff = 360 - abs( angDiff );
		//iprintln( "angle differance: " + angDiff );

		// if the plane isn't close enough to the desired angles then rotate it until the plane is facing it's flying direction
		planeCanFly = false;
		angleTollerance = 20;
		if ( ( angDiff > 0 ) && ( angDiff <= angleTollerance ) )
			planeCanFly = true;
		if ( ( angDiff > 360 - angleTollerance ) && ( angDiff < 360 ) )
			planeCanFly = true;
		if ( !planeCanFly )
		{
			//iprintln( "waiting for plane to rotate " + angDiff + " degrees" );
			//assert( angDiff - 20 > 0 );
			rotateTime = ( level._ac130_Speed[ "rotate" ] / 360 ) * angDiff;
			decelTime = 0;
			if ( rotateTime > 3.0 )
				decelTime = 3.0;
			assert( rotateTime > 0 );
			level._ac130 rotateyaw( angDiff, rotateTime, 0, decelTime );
			wait rotateTime - decelTime;
			thread ac130_move_out();
		}
	}

	level._ac130 moveto( coordinate, moveTime, accel, decel );
	if ( moveTime > 2.0 )
	{
		wait( moveTime - 2.0 );
		level notify( "ac130_almost_at_destination" );
		if ( rotationWait )
			thread rotatePlane( "on" );
		wait 2.0;
	}
	else
	{
		wait moveTime;
		if ( rotationWait )
			thread rotatePlane( "on" );
	}
}

ac130_move_in()
{
	if ( isdefined( level._ac130_moving_in ) )
		return;
	level._ac130_moving_in = true;
	level._ac130_moving_out = undefined;
	
	thread context_Sensative_Dialog_Play_Random_Group_Sound( "plane", "rolling_in", true );

	level._ac130 useAnimTree( #animtree );
	level._ac130 setflaggedanim( "ac130_move_in", %ac130_move_in, 1.0, 0.2, 0.1 );
	level._ac130 waittillmatch( "ac130_move_in", "end" );

	level._ac130_moving_in = undefined;
}

ac130_move_out()
{
	if ( isdefined( level._ac130_moving_out ) )
		return;
	level._ac130_moving_out = true;
	level._ac130_moving_in = undefined;

	level._ac130 useAnimTree( #animtree );
	level._ac130 setflaggedanim( "ac130_move_out", %ac130_move_out, 1.0, 0.2, 0.3 );
	level._ac130 waittillmatch( "ac130_move_out", "end" );

	level._ac130_moving_out = undefined;
}

changeWeapons()
{
	level._ac130_weapon = [];

	level._ac130_weapon[ 0 ] = spawnstruct();
	level._ac130_weapon[ 0 ].overlay = "ac130_overlay_105mm";
	level._ac130_weapon[ 0 ].fov = "55";
	level._ac130_weapon[ 0 ].name = "105mm";
	// 105 mm
	level._ac130_weapon[ 0 ].string = ( &"AC130_HUD_WEAPON_105MM" );
	level._ac130_weapon[ 0 ].hudelem_y = -20;

	level._ac130_weapon[ 1 ] = spawnstruct();
	level._ac130_weapon[ 1 ].overlay = "ac130_overlay_40mm";
	level._ac130_weapon[ 1 ].fov = "25";
	level._ac130_weapon[ 1 ].name = "40mm";
	// 40 mm
	level._ac130_weapon[ 1 ].string = ( &"AC130_HUD_WEAPON_40MM" );
	level._ac130_weapon[ 1 ].hudelem_y = -40;

	level._ac130_weapon[ 2 ] = spawnstruct();
	level._ac130_weapon[ 2 ].overlay = "ac130_overlay_25mm";
	level._ac130_weapon[ 2 ].fov = "10";
	level._ac130_weapon[ 2 ].name = "25mm";
	// 25 mm
	level._ac130_weapon[ 2 ].string = ( &"AC130_HUD_WEAPON_25MM" );
	level._ac130_weapon[ 2 ].hudelem_y = -60;

	if ( getdvar( "ac130_alternate_controls", "0" ) == "0" )
	{
		level._ac130_weapon[ 0 ].weapon = "ac130_105mm";
		level._ac130_weapon[ 1 ].weapon = "ac130_40mm";
		level._ac130_weapon[ 2 ].weapon = "ac130_25mm";
	}
	else
	{
		level._ac130_weapon[ 0 ].weapon = "ac130_105mm_alt";
		level._ac130_weapon[ 1 ].weapon = "ac130_40mm_alt";
		level._ac130_weapon[ 2 ].weapon = "ac130_25mm_alt";
	}

	currentWeapon = 0;
	level._currentWeapon = level._ac130_weapon[ currentWeapon ].name;
	thread fire_screenShake();

	notifyOnCommand( "switch weapons", "weapnext" );

	wait 0.05;

	level._initialFOV = int( getdvar( "cg_fov" ) );
	assert( isdefined( level._initialFOV ) );
	assert( level._initialFOV > 0 );

	for ( ;; )
	{
		level._ac130player waittill( "switch weapons" );

		// no weapon changes allowed during cinematic
		if ( isdefined( level._doing_cinematic ) )
		{
			wait 0.05;
			continue;
		}

		level._ac130player notify( "shot weapon" );

		currentWeapon++ ;
		if ( currentWeapon >= level._ac130_weapon.size )
			currentWeapon = 0;
		level._currentWeapon = level._ac130_weapon[ currentWeapon ].name;

		level._HUDItem[ "crosshairs" ] setshader( level._ac130_weapon[ currentWeapon ].overlay, level._ac130_crosshair_size_x, level._ac130_crosshair_size_y );

		thread blink_crosshairs( level._ac130_weapon[ currentWeapon ].weapon );
		thread blink_hud_elem( currentWeapon );

		if ( getdvar( "ac130_alternate_controls", "0" ) == "0" )
		{
			//setsaveddvar( "cg_fov", level.ac130_weapon[currentWeapon].fov );

			targetFOV = int( level._ac130_weapon[ currentWeapon ].fov );
			fovFraction = targetFOV / level._initialFOV;
			fovFraction = cap_value( fovFraction, 0.2, 2.0 );

			if ( level._ac130player == level._player )
				setsaveddvar( "cg_playerFovScale0", fovFraction );
			else
				setsaveddvar( "cg_playerFovScale1", fovFraction );
		}

		level._ac130player takeallweapons();
		level._ac130player giveweapon( level._ac130_weapon[ currentWeapon ].weapon );
		level._playerWeapon = level._ac130_weapon[ currentWeapon ].weapon;
		level._ac130player switchtoweapon( level._ac130_weapon[ currentWeapon ].weapon );
		setAmmo();

		level._ac130player thread play_sound_on_entity( "ac130_weapon_switch" );

		flag_set( "player_changed_weapons" );
	}
}

blink_hud_elem( curentWeapon )
{

	level notify( "blinking_weapon_name_hud_elem" );
	level endon( "blinking_weapon_name_hud_elem" );

	if ( !isdefined( level._HUDItem[ "weapon_text" ] ) )
		return;

	for ( i = 0 ; i < level._HUDItem[ "weapon_text" ].size ; i++ )
		level._HUDItem[ "weapon_text" ][ i ].alpha = 0.5;

	level._HUDItem[ "weapon_text" ][ curentWeapon ].alpha = 1;
	for ( ;; )
	{
		level._HUDItem[ "weapon_text" ][ curentWeapon ] fadeOverTime( 0.2 );
		level._HUDItem[ "weapon_text" ][ curentWeapon ].alpha = 0;
		wait 0.2;

		level._HUDItem[ "weapon_text" ][ curentWeapon ] fadeOverTime( 0.2 );
		level._HUDItem[ "weapon_text" ][ curentWeapon ].alpha = 1;
		wait 0.2;
	}
}

blink_crosshairs( weaponName )
{
	level notify( "stop_blinking_crosshairs" );
	level endon( "stop_blinking_crosshairs" );

	level._HUDItem[ "crosshairs" ].alpha = 1;

	if ( !issubstr( tolower( weaponName ), "105" ) )
		return;

	waittillframeend;
	if ( level._weaponReadyToFire[ weaponName ] )
		return;

	for ( ;; )
	{
		level._HUDItem[ "crosshairs" ] fadeOverTime( 0.3 );
		level._HUDItem[ "crosshairs" ].alpha = 0;
		wait 0.3;

		level._HUDItem[ "crosshairs" ] fadeOverTime( 0.3 );
		level._HUDItem[ "crosshairs" ].alpha = 1;
		wait 0.3;
	}
}

blink_crosshairs_stop()
{
	level notify( "stop_blinking_crosshairs" );
	level._HUDItem[ "crosshairs" ].alpha = 1;
}

weaponFiredThread()
{
	for ( ;; )
	{
		level._ac130player waittill( "weapon_fired" );

		weaponList = level._ac130player GetWeaponsListPrimaries();
		assert( isdefined( weaponList[ 0 ] ) );

		if ( !level._weaponReadyToFire[ weaponList[ 0 ] ] )
			continue;

		if ( is_coop() )
			thread weaponFiredCoOpTracer( weaponList[ 0 ] );

		thread blink_crosshairs( weaponList[ 0 ] );

		thread weaponReload( weaponList[ 0 ] );
	}
}

weaponReload( weapon )
{
	level._weaponReadyToFire[ weapon ] = false;

	wait level._weaponReloadTime[ weapon ] - 0.05;

	level._weaponReadyToFire[ weapon ] = true;

	setAmmo();
}

weaponFiredCoOpTracer( weaponName )
{
	// Only play muzzle effects for 105mm and 40mm
	muzzleFX = undefined;
	if ( issubstr( tolower( weaponName ), "105" ) )
		muzzleFX = level._effect[ "coop_muzzleflash_105mm" ];
	else if ( issubstr( tolower( weaponName ), "40" ) )
		muzzleFX = level._effect[ "coop_muzzleflash_40mm" ];

	if ( !isdefined( muzzleFX ) )
		return;

	// Trace to where the player is looking
	direction = level._ac130player getPlayerAngles();
	direction_vec = anglesToForward( direction );
	eye = level._ac130player getEye();

	// Play muzzleflash effect
	playFX( muzzleFX, eye, direction_vec );
}

thermalVision()
{
	level._ac130player endon( "death" );

	if ( getdvar( "ac130_thermal_enabled", "1" ) != "1" )
		return;

	level._ac130player visionSetThermalForPlayer( "ac130", 0 );
	inverted = "0";

	notifyOnCommand( "switch thermal", "+usereload" );
	notifyOnCommand( "switch thermal", "+activate" );
	for ( ;; )
	{
		level._ac130player waittill( "switch thermal" );

		// no thermal changes allowed during cinematic
		if ( isdefined( level._doing_cinematic ) )
		{
			wait 0.05;
			continue;
		}

		if ( inverted == "0" )
		{
			level._ac130player visionSetThermalForPlayer( "missilecam", 0.62 );
			if ( isdefined( level._HUDItem[ "thermal_mode" ] ) )
				// BHOT
				level._HUDItem[ "thermal_mode" ] settext( &"AC130_HUD_THERMAL_BHOT" );
			inverted = "1";
		}
		else
		{
			level._ac130player visionSetThermalForPlayer( "ac130", 0.51 );
			if ( isdefined( level._HUDItem[ "thermal_mode" ] ) )
				// WHOT
				level._HUDItem[ "thermal_mode" ] settext( &"AC130_HUD_THERMAL_WHOT" );
			inverted = "0";
		}
	}
}

setAmmo()
{
	level notify( "setting_ammo" );
	level endon( "setting_ammo" );

	if ( flag( "clear_to_engage" ) )
		ammoCount = 1;
	else
		ammoCount = 0;

    weaponList = level._ac130player GetWeaponsListPrimaries();
    for ( i = 0 ; i < weaponList.size ; i++ )
    {
    	// only add the ammo if the gun is reloaded
		if ( level._weaponReadyToFire[ weaponList[ i ] ] )
			level._ac130player SetWeaponAmmoClip( weaponList[ i ], ammoCount );
    }
}

failMissionForEngaging()
{
	level endon( "clear_to_engage" );

	level._ac130player waittill( "weapon_fired" );

	wait 2;

	if ( !flag( "mission_failed" ) )
	{
		flag_set( "mission_failed" );
		setdvar( "ui_deadquote", "@AC130_DO_NOT_ENGAGE" );
		maps\_utility::missionFailedWrapper();
	}
}

nofireCrossHair()
{
	level endon( "clear_to_engage" );

	if ( flag( "clear_to_engage" ) )
		return;

	level._ac130_nofire = newClientHudElem( level._ac130player );
	level._ac130_nofire.x = 0;
	level._ac130_nofire.y = 0;
	level._ac130_nofire.alignX = "center";
	level._ac130_nofire.alignY = "middle";
	level._ac130_nofire.horzAlign = "center";
	level._ac130_nofire.vertAlign = "middle";
	level._ac130_nofire setshader( "ac130_overlay_nofire", 64, 64 );

	thread nofireCrossHair_Remove();

	level._ac130_nofire.alpha = 0;

	for ( ;; )
	{
		while ( level._ac130player attackButtonPressed() )
		{
			// no red x allowed during cinematic
			if ( isdefined( level._doing_cinematic ) )
			{
				wait 0.05;
				break;
			}

			level._ac130_nofire.alpha = 1;
			level._ac130_nofire fadeOverTime( 1.0 );
			level._ac130_nofire.alpha = 0;
			wait 1.0;
		}
		wait 0.05;
	}
}

nofireCrossHair_Remove()
{
	level waittill( "clear_to_engage" );
	level._ac130_nofire destroy();
	thread setAmmo();
}

fire_screenShake()
{
	for ( ;; )
	{
		level._ac130player waittill( "weapon_fired" );

		if ( level._currentWeapon == "105mm" )
		{
			if ( ( getdvar( "ac130_pre_engagement_mode", "2" ) == "2" ) && ( !flag( "clear_to_engage" ) ) )
				continue;

			thread gun_fired_and_ready_105mm();

			//earthquake(<scale>,<duration>,<source>,<radius>)
			earthquake( 0.2, 1, level._ac130player.origin, 1000 );
		}
		else
		if ( level._currentWeapon == "40mm" )
		{
			if ( ( getdvar( "ac130_pre_engagement_mode", "2" ) == "2" ) && ( !flag( "clear_to_engage" ) ) )
				continue;

			//earthquake(<scale>,<duration>,<source>,<radius>)
			earthquake( 0.1, 0.5, level._ac130player.origin, 1000 );
		}

		wait 0.05;
	}
}

clouds()
{
	level endon( "stop_clounds" );
	wait 6;
	clouds_create();
	for ( ;; )
	{
		wait( randomfloatrange( 40, 80 ) );
		clouds_create();
	}
}

clouds_create()
{
	if ( ( isdefined( level._playerWeapon ) ) && ( issubstr( tolower( level._playerWeapon ), "25" ) ) )
		return;
	playfxontag( level._effect[ "cloud" ], level._ac130, "tag_player" );
}

gun_fired_and_ready_105mm()
{
	level notify( "gun_fired_and_ready_105mm" );
	level endon( "gun_fired_and_ready_105mm" );

	wait 0.5;
	
	if ( randomint( 2 ) == 0 )
		thread context_Sensative_Dialog_Play_Random_Group_Sound( "weapons", "105mm_fired" );

	wait 5.0;

	thread blink_crosshairs_stop();
	thread context_Sensative_Dialog_Play_Random_Group_Sound( "weapons", "105mm_ready" );
}

getFriendlysCenter()
{
	//returns vector which is the center mass of all friendlies
	averageVec = undefined;
	friendlies = getaiarray( "allies" );
	if ( !isdefined( friendlies ) )
		return( 0, 0, 0 );
	if ( friendlies.size <= 0 )
		return( 0, 0, 0 );
	for ( i = 0 ; i < friendlies.size ; i++ )
	{
		if ( !isdefined( averageVec ) )
			averageVec = friendlies[ i ].origin;
		else
			averageVec += friendlies[ i ].origin;
	}
	averageVec = ( ( averageVec[ 0 ] / friendlies.size ), ( averageVec[ 1 ] / friendlies.size ), ( averageVec[ 2 ] / friendlies.size ) );
	return averageVec;
}

shotFired()
{
	for ( ;; )
	{
		level._ac130player waittill( "projectile_impact", weaponName, position, radius );

		thread shotFiredFriendlyProximity( weaponName, position );

		if ( issubstr( tolower( weaponName ), "105" ) )
		{
			earthquake( 0.4, 1.0, position, 3500 );
			thread shotFiredDarkScreenOverlay();
		}
		else if ( issubstr( tolower( weaponName ), "40" ) )
		{
			earthquake( 0.2, 0.5, position, 2000 );
		}

		thread shotFiredBadPlace( position, weaponName );

		if ( getdvar( "ac130_ragdoll_deaths", "1" ) == "1" )
			thread shotFiredPhysicsSphere( position, weaponName );
		wait 0.05;
	}
}

shotFiredFriendlyProximity( weaponName, position )
{
	if ( !isdefined( level._weaponFriendlyCloseDistance[ weaponName ] ) )
		return;

	trigger_origin = position - ( 0, 0, 50 );
	trigger_radius = level._weaponFriendlyCloseDistance[ weaponName ];
	trigger_height = 300;
	trigger_spawnflags = 2; // AI_ALLIES AND THE PLAYER // keept the ai if it ever get used with friendlies again.
	trigger_lifetime = 1.0;

	prof_begin( "ac130_friendly_proximity_check" );
	trigger = spawn( "trigger_radius", trigger_origin, trigger_spawnflags, trigger_radius, trigger_height );
	prof_end( "ac130_friendly_proximity_check" );
	level thread shotFiredFriendlyProximity_trigger( trigger, trigger_lifetime );

	if ( getdvar( "ac130_debug_weapons", "0" ) == "1" )
	{
		thread debug_circle( trigger_origin, trigger_radius, trigger_lifetime, level._color[ "white" ], undefined, true );
		thread debug_circle( trigger_origin + ( 0, 0, trigger_height ), trigger_radius, trigger_lifetime, level._color[ "white" ], undefined, true );
	}
}

shotFiredFriendlyProximity_trigger( trigger, trigger_lifetime )
{
	trigger endon( "timeout" );
	level thread shotFiredFriendlyProximity_trigger_timeout( trigger, trigger_lifetime );
	trigger waittill( "trigger" );

	// don't play warning dialog if one played within the last 5 seconds.
	prof_begin( "ac130_friendly_proximity_check" );
	if ( ( isdefined( level._lastFriendlyProximityWarningPlayed ) ) && ( gettime() - level._lastFriendlyProximityWarningPlayed < 7000 ) )
	{
		prof_end( "ac130_friendly_proximity_check" );
		return;
	}

	level._lastFriendlyProximityWarningPlayed = gettime();
	prof_end( "ac130_friendly_proximity_check" );

	thread playSoundOverRadio( level._scr_sound[ "fco" ][ "ac130_fco_firingtoclose" ], true, 5.0 );
}

shotFiredFriendlyProximity_trigger_timeout( trigger, trigger_lifetime )
{
	wait trigger_lifetime;
	trigger notify( "timeout" );
	trigger delete();
}

shotFiredBadPlace( center, weapon )
{
	// no new badplace if more then 20
	if ( level._badplaceCount >= level._badplaceMax )
		return;

	assert( isdefined( level._badplaceRadius[ weapon ] ) );
	badplace_cylinder( "", level._badplaceDuration[ weapon ], center, level._badplaceRadius[ weapon ], level._badplaceRadius[ weapon ], "axis" );
	thread shotFiredBadPlaceCount( level._badplaceDuration[ weapon ] );

	if ( getdvar( "ac130_debug_weapons", "0" ) == "1" )
		thread debug_circle( center, level._badplaceRadius[ weapon ], level._badplaceDuration[ weapon ], level._color[ "blue" ], undefined, true );
}

shotFiredBadPlaceCount( durration )
{
	assert( level._badplaceCount >= 0 );
	assert( level._badplaceCount < level._badplaceMax );

	level._badplaceCount++;
	wait durration;
	level._badplaceCount--;
}

shotFiredPhysicsSphere( center, weapon )
{
	wait 0.1;
	physicsExplosionSphere( center, level._physicsSphereRadius[ weapon ], level._physicsSphereRadius[ weapon ] / 2, level._physicsSphereForce[ weapon ] );
}

shotFiredDarkScreenOverlay()
{
	level notify( "darkScreenOverlay" );
	level endon( "darkScreenOverlay" );

	if ( !isdefined( level._darkScreenOverlay ) )
	{
		level._darkScreenOverlay = newClientHudElem( level._ac130player );
		level._darkScreenOverlay.x = 0;
		level._darkScreenOverlay.y = 0;
		level._darkScreenOverlay.alignX = "left";
		level._darkScreenOverlay.alignY = "top";
		level._darkScreenOverlay.horzAlign = "fullscreen";
		level._darkScreenOverlay.vertAlign = "fullscreen";
		level._darkScreenOverlay setshader( "black", 640, 480 );
		level._darkScreenOverlay.sort = -10;
		level._darkScreenOverlay.alpha = 0.0;
	}
	level._darkScreenOverlay.alpha = 0.0;
	level._darkScreenOverlay fadeOverTime( 0.2 );
	level._darkScreenOverlay.alpha = 0.6;
	wait 0.4;
	level._darkScreenOverlay fadeOverTime( 0.8 );
	level._darkScreenOverlay.alpha = 0.0;
}

add_beacon_effect()
{
	self endon( "death" );

	flashDelay = 0.75;

	wait randomfloat( 3.0 );
	for ( ;; )
	{
		if ( isdefined( level._ac130player ) )
			playfxontagforclients( level._effect[ "beacon" ], self, "j_spine4", level._ac130player );
		wait flashDelay;
	}
}

/*
breakable()
{
	self setcandamage( true );
	for (;;)
	{
		self waittill ( "damage", damage, attacker );
		if ( ( isplayer( attacker ) ) & ( damage >= 1000 ) )
			break;
	}
	self delete();
}
*/
/*
tree_fall()
{
	self setcandamage( true );
	for (;;)
	{
		self waittill( "damage", damage, attacker, direction_vec, point );
		if ( !isplayer( attacker ) )
			continue;
		if ( randomint( 2 ) == 0 )
			continue;
		break;
	}
	
	tree = self;
	
	treeorg = spawn( "script_origin", tree.origin );
	treeorg.origin = tree.origin;
	
	org = point;
	pos1 = (org[0],org[1],0);
	org = tree.origin;
	pos2 = (org[0],org[1],0);
	treeorg.angles = vectortoangles( pos1 - pos2 );
	
 	treeang = tree.angles;
	ang = treeorg.angles;
	org = point;
	pos1 = (org[0],org[1],0);
	org = tree.origin;
	pos2 = (org[0],org[1],0);
	treeorg.angles = vectortoangles( pos1 - pos2 );
	tree linkto( treeorg );
	
	treeorg rotatepitch( -90, 1.1, .05, .2 );
	treeorg waittill( "rotatedone" );
	treeorg rotatepitch( 5, .21, .05, .15 );
	treeorg waittill( "rotatedone" );
	treeorg rotatepitch( -5, .26, .15, .1 );
	treeorg waittill( "rotatedone" );
	tree unlink();
	treeorg delete();
}
*/

spawn_callback_thread( guy )
{
	if ( isdefined( level._LevelSpecificSpawnerCallbackThread ) )
		thread [[ level._LevelSpecificSpawnerCallbackThread ]]( guy );

	if ( !isdefined( guy ) )
		return;

	if ( !isdefined( guy.team ) )
		return;

	if ( guy.team == "axis" )
	{
		thread enemy_killed_thread( guy );
	}

	if ( getdvar( "ac130_target_markers", "0" ) == "1" )
	{
		target_set( guy, ( 0, 0, 32 ) );
		thread hud_target_blink( guy );
	}
}

hud_target_blink( guy )
{
	guy endon( "death" );
	while ( isdefined( guy ) )
	{
		target_setshader( guy, "ac130_hud_target" );
		target_setoffscreenshader( guy, "ac130_hud_target_offscreen" );
		level waittill( "hud_target_blink_off" );
		target_setshader( guy, "ac130_hud_target_flash" );
		target_setoffscreenshader( guy, "ac130_hud_target_flash" );
		level waittill( "hud_target_blink_on" );
	}
}

hud_target_blink_timer()
{
	for ( ;; )
	{
		level notify( "hud_target_blink_on" );
		wait 0.5;
		level notify( "hud_target_blink_off" );
		wait 0.2;
	}
}

enemy_killed_thread( guy )
{
	if ( guy.team != "axis" )
		return;

	if ( getdvar( "ac130_ragdoll_deaths", "1" ) == "1" )
		guy.skipDeathAnim = true;

	guy waittill( "death", attacker );

	if ( ( isdefined( attacker ) ) && ( isplayer( attacker ) ) )
		level._enemiesKilledByPlayer++ ;

	if ( getdvar( "ac130_ragdoll_deaths", "1" ) == "1" )
	{
		if ( ( isdefined( guy.damageweapon ) ) && ( issubstr( guy.damageweapon, "25mm" ) ) )
			guy.skipDeathAnim = undefined;
	}

	// context kill dialog
	thread context_Sensative_Dialog_Kill( guy, attacker );
}

context_Sensative_Dialog()
{
	thread context_Sensative_Dialog_Guy_In_Sight();
	thread context_Sensative_Dialog_Guy_Crawling();
	thread context_Sensative_Dialog_Guy_Pain();
	thread context_Sensative_Dialog_Guy_Pain_Falling();
	thread context_Sensative_Dialog_Secondary_Explosion_Vehicle();
	thread context_Sensative_Dialog_Kill_Thread();
	thread context_Sensative_Dialog_Locations();
	thread context_Sensative_Dialog_Filler();
}

context_Sensative_Dialog_Guy_In_Sight()
{
	for ( ;; )
	{
		if ( context_Sensative_Dialog_Guy_In_Sight_Check() )
			thread context_Sensative_Dialog_Play_Random_Group_Sound( "ai", "in_sight" );
		wait randomfloatrange( 1, 3 );
	}
}

context_Sensative_Dialog_Guy_In_Sight_Check()
{
	prof_begin( "AI_in_sight_check" );

	enemies = getaiarray( "axis" );
	for ( i = 0 ; i < enemies.size ; i++ )
	{
		if ( !isdefined( enemies[ i ] ) )
			continue;

		if ( !isalive( enemies[ i ] ) )
			continue;

		if ( within_fov( level._ac130player getEye(), level._ac130player getPlayerAngles(), enemies[ i ].origin, level._cosine[ "5" ] ) )
		{
			prof_end( "AI_in_sight_check" );
			return true;
		}
		wait 0.05;
	}

	prof_end( "AI_in_sight_check" );
	return false;
}

context_Sensative_Dialog_Guy_Crawling()
{
	for ( ;; )
	{
		level waittill( "ai_crawling", guy );

		if ( ( isdefined( guy ) ) && ( isdefined( guy.origin ) ) )
		{
			if ( getdvar( "ac130_debug_context_sensative_dialog", "0" ) == "1" )
				thread debug_line( level._ac130player.origin, guy.origin, 5.0, ( 0, 1, 0 ) );
		}

		thread context_Sensative_Dialog_Play_Random_Group_Sound( "ai", "wounded_crawl" );
	}
}

context_Sensative_Dialog_Guy_Pain_Falling()
{
	for ( ;; )
	{
		level waittill( "ai_pain_falling", guy );

		if ( ( isdefined( guy ) ) && ( isdefined( guy.origin ) ) )
		{
			if ( getdvar( "ac130_debug_context_sensative_dialog", "0" ) == "1" )
				thread debug_line( level._ac130player.origin, guy.origin, 5.0, ( 1, 0, 0 ) );
		}

		thread context_Sensative_Dialog_Play_Random_Group_Sound( "ai", "wounded_pain" );
	}
}

context_Sensative_Dialog_Guy_Pain()
{
	for ( ;; )
	{
		level waittill( "ai_pain", guy );

		if ( ( isdefined( guy ) ) && ( isdefined( guy.origin ) ) )
		{
			if ( getdvar( "ac130_debug_context_sensative_dialog", "0" ) == "1" )
				thread debug_line( level._ac130player.origin, guy.origin, 5.0, ( 1, 0, 0 ) );
		}

		thread context_Sensative_Dialog_Play_Random_Group_Sound( "ai", "wounded_pain" );
	}
}

context_Sensative_Dialog_Secondary_Explosion_Vehicle()
{
	for ( ;; )
	{
		level waittill( "vehicle_explosion", vehicle_origin );

		wait 1;

		if ( isdefined( vehicle_origin ) )
		{
			if ( getdvar( "ac130_debug_context_sensative_dialog", "0" ) == "1" )
				thread debug_line( level._ac130player.origin, vehicle_origin, 5.0, ( 0, 0, 1 ) );
		}

		thread context_Sensative_Dialog_Play_Random_Group_Sound( "explosion", "secondary" );
	}
}

context_Sensative_Dialog_Kill( guy, attacker )
{
	if ( !isdefined( attacker ) )
		return;

	if ( !isplayer( attacker ) )
		return;

	level._enemiesKilledInTimeWindow++ ;
	level notify( "enemy_killed" );

	if ( ( isdefined( guy ) ) && ( isdefined( guy.origin ) ) )
	{
		if ( getdvar( "ac130_debug_context_sensative_dialog", "0" ) == "1" )
			thread debug_line( level._ac130player.origin, guy.origin, 5.0, ( 1, 1, 0 ) );
	}
}

context_Sensative_Dialog_Kill_Thread()
{
	timeWindow = 1;
	for ( ;; )
	{
		level waittill( "enemy_killed" );
		wait timeWindow;
		println( "guys killed in time window: " );
		println( level._enemiesKilledInTimeWindow );

		soundAlias1 = "kill";
		soundAlias2 = undefined;

//		if ( level.enemiesKilledInTimeWindow >= 5 )
//			maps\_utility::giveachievement_wrapper( "STRAIGHT_FLUSH" );

		if ( level._enemiesKilledInTimeWindow >= 3 )
			soundAlias2 = "large_group";
		else if ( level._enemiesKilledInTimeWindow == 2 )
			soundAlias2 = "small_group";
		else
		{
			soundAlias2 = "single";
			if ( randomint( 3 ) != 1 )
			{
				level._enemiesKilledInTimeWindow = 0;
				continue;
			}
		}

		level._enemiesKilledInTimeWindow = 0;
		assert( isdefined( soundAlias2 ) );

		thread context_Sensative_Dialog_Play_Random_Group_Sound( soundAlias1, soundAlias2, true );
	}
}

context_Sensative_Dialog_Locations()
{
	array_thread( getentarray( "context_dialog_car", 		"targetname" ), 	::context_Sensative_Dialog_Locations_Add_Notify_Event, "car" );
	array_thread( getentarray( "context_dialog_truck", 		"targetname" ), 	::context_Sensative_Dialog_Locations_Add_Notify_Event, "truck" );
	array_thread( getentarray( "context_dialog_building", 	"targetname" ), 	::context_Sensative_Dialog_Locations_Add_Notify_Event, "building" );
	array_thread( getentarray( "context_dialog_wall", 		"targetname" ), 	::context_Sensative_Dialog_Locations_Add_Notify_Event, "wall" );
	array_thread( getentarray( "context_dialog_field", 		"targetname" ), 	::context_Sensative_Dialog_Locations_Add_Notify_Event, "field" );
	array_thread( getentarray( "context_dialog_road", 		"targetname" ), 	::context_Sensative_Dialog_Locations_Add_Notify_Event, "road" );
	array_thread( getentarray( "context_dialog_church", 		"targetname" ), 	::context_Sensative_Dialog_Locations_Add_Notify_Event, "church" );
	array_thread( getentarray( "context_dialog_ditch", 		"targetname" ), 	::context_Sensative_Dialog_Locations_Add_Notify_Event, "ditch" );

	thread context_Sensative_Dialog_Locations_Thread();
}

context_Sensative_Dialog_Locations_Thread()
{
	for ( ;; )
	{
		level waittill( "context_location", locationType );

		if ( !isdefined( locationType ) )
		{
			assertMsg( "LocationType " + locationType + " is not valid" );
			continue;
		}

		if ( !flag( "allow_context_sensative_dialog" ) )
			continue;

		thread context_Sensative_Dialog_Play_Random_Group_Sound( "location", locationType );

		wait( 5 + randomfloat( 10 ) );
	}
}

context_Sensative_Dialog_Locations_Add_Notify_Event( locationType )
{
	for ( ;; )
	{
		self waittill( "trigger", triggerer );

		if ( !isdefined( triggerer ) )
			continue;

		if ( ( !isdefined( triggerer.team ) ) || ( triggerer.team != "axis" ) )
			continue;

		level notify( "context_location", locationType );

		wait 5;
	}
}

context_Sensative_Dialog_VehicleSpawn( vehicle )
{
	if ( vehicle.script_team != "axis" )
		return;

	thread context_Sensative_Dialog_VehicleDeath( vehicle );

	vehicle endon( "death" );

	while ( !within_fov( level._ac130player getEye(), level._ac130player getPlayerAngles(), vehicle.origin, level._cosine[ "45" ] ) )
		wait 0.5;

	context_Sensative_Dialog_Play_Random_Group_Sound( "vehicle", "incoming" );
}

context_Sensative_Dialog_VehicleDeath( vehicle )
{
	vehicle waittill( "death" );
	thread context_Sensative_Dialog_Play_Random_Group_Sound( "vehicle", "death" );
}

context_Sensative_Dialog_Filler()
{
	for ( ;; )
	{
		if ( ( isdefined( level._radio_in_use ) ) && ( level._radio_in_use == true ) )
			level waittill( "radio_not_in_use" );

		// if 3 seconds has passed and nothing has been transmitted then play a sound
		currentTime = getTime();
		if ( ( currentTime - level._lastRadioTransmission ) >= 3000 )
		{
			level._lastRadioTransmission = currentTime;
			thread context_Sensative_Dialog_Play_Random_Group_Sound( "misc", "action" );
		}

		wait 0.25;
	}
}

context_Sensative_Dialog_Play_Random_Group_Sound( name1, name2, force_transmit_on_turn )
{
	assert( isdefined( level._scr_sound[ name1 ] ) );
	assert( isdefined( level._scr_sound[ name1 ][ name2 ] ) );

	if ( !isdefined( force_transmit_on_turn ) )
		force_transmit_on_turn = false;

	if ( !flag( "allow_context_sensative_dialog" ) )
	{
		if ( force_transmit_on_turn )
			flag_wait( "allow_context_sensative_dialog" );
		else
			return;
	}

	validGroupNum = undefined;

	randGroup = randomint( level._scr_sound[ name1 ][ name2 ].size );

	// if randGroup has already played
	if ( level._scr_sound[ name1 ][ name2 ][ randGroup ].played == true )
	{
		//loop through all groups and use the next one that hasn't played yet

		for ( i = 0 ; i < level._scr_sound[ name1 ][ name2 ].size ; i++ )
		{
			randGroup++ ;
			if ( randGroup >= level._scr_sound[ name1 ][ name2 ].size )
				randGroup = 0;
			if ( level._scr_sound[ name1 ][ name2 ][ randGroup ].played == true )
				continue;
			validGroupNum = randGroup;
			break;
		}

		// all groups have been played, reset all groups to false and pick a new random one
		if ( !isdefined( validGroupNum ) )
		{
			for ( i = 0 ; i < level._scr_sound[ name1 ][ name2 ].size ; i++ )
				level._scr_sound[ name1 ][ name2 ][ i ].played = false;
			validGroupNum = randomint( level._scr_sound[ name1 ][ name2 ].size );
		}
	}
	else
		validGroupNum = randGroup;

	assert( isdefined( validGroupNum ) );
	assert( validGroupNum >= 0 );

	if ( context_Sensative_Dialog_Timedout( name1, name2, validGroupNum ) )
		return;

	level._scr_sound[ name1 ][ name2 ][ validGroupNum ].played = true;
	randSound = randomint( level._scr_sound[ name1 ][ name2 ][ validGroupNum ].size );
	playSoundOverRadio( level._scr_sound[ name1 ][ name2 ][ validGroupNum ].sounds[ randSound ], force_transmit_on_turn );
}

context_Sensative_Dialog_Timedout( name1, name2, groupNum )
{
	// dont play this sound if it has a timeout specified and the timeout has not expired

	if ( !isdefined( level._context_sensative_dialog_timeouts ) )
		return false;

	if ( !isdefined( level._context_sensative_dialog_timeouts[ name1 ] ) )
		return false;

	if ( !isdefined( level._context_sensative_dialog_timeouts[ name1 ][ name2 ] ) )
		return false;

	if ( ( isdefined( level._context_sensative_dialog_timeouts[ name1 ][ name2 ].groups ) ) && ( isdefined( level._context_sensative_dialog_timeouts[ name1 ][ name2 ].groups[ string( groupNum ) ] ) ) )
	{
		assert( isdefined( level._context_sensative_dialog_timeouts[ name1 ][ name2 ].groups[ string( groupNum ) ].v[ "timeoutDuration" ] ) );
		assert( isdefined( level._context_sensative_dialog_timeouts[ name1 ][ name2 ].groups[ string( groupNum ) ].v[ "lastPlayed" ] ) );

		currentTime = getTime();
		if ( ( currentTime - level._context_sensative_dialog_timeouts[ name1 ][ name2 ].groups[ string( groupNum ) ].v[ "lastPlayed" ] ) < level._context_sensative_dialog_timeouts[ name1 ][ name2 ].groups[ string( groupNum ) ].v[ "timeoutDuration" ] )
			return true;

		level._context_sensative_dialog_timeouts[ name1 ][ name2 ].groups[ string( groupNum ) ].v[ "lastPlayed" ] = currentTime;
	}
	else if ( isdefined( level._context_sensative_dialog_timeouts[ name1 ][ name2 ].v ) )
	{
		assert( isdefined( level._context_sensative_dialog_timeouts[ name1 ][ name2 ].v[ "timeoutDuration" ] ) );
		assert( isdefined( level._context_sensative_dialog_timeouts[ name1 ][ name2 ].v[ "lastPlayed" ] ) );

		currentTime = getTime();
		if ( ( currentTime - level._context_sensative_dialog_timeouts[ name1 ][ name2 ].v[ "lastPlayed" ] ) < level._context_sensative_dialog_timeouts[ name1 ][ name2 ].v[ "timeoutDuration" ] )
			return true;

		level._context_sensative_dialog_timeouts[ name1 ][ name2 ].v[ "lastPlayed" ] = currentTime;
	}

	return false;
}

playSoundOverRadio( soundAlias, force_transmit_on_turn, timeout )
{
	if ( !isdefined( level._radio_in_use ) )
		level._radio_in_use = false;
	if ( !isdefined( force_transmit_on_turn ) )
		force_transmit_on_turn = false;
	if ( !isdefined( timeout ) )
		timeout = 0;
	timeout = timeout * 1000;
	soundQueueTime = gettime();

	soundPlayed = false;
	soundPlayed = playAliasOverRadio( soundAlias );
	if ( soundPlayed )
		return;

	// Dont make the sound wait to be played if force transmit wasn't set to true
	if ( !force_transmit_on_turn )
		return;

	level._radioForcedTransmissionQueue[ level._radioForcedTransmissionQueue.size ] = soundAlias;
	while ( !soundPlayed )
	{
		if ( level._radio_in_use )
			level waittill( "radio_not_in_use" );

		if ( ( timeout > 0 ) && ( getTime() - soundQueueTime > timeout ) )
			break;

		soundPlayed = playAliasOverRadio( level._radioForcedTransmissionQueue[ 0 ] );
		if ( !level._radio_in_use && !soundPlayed )
			assertMsg( "The radio wasn't in use but the sound still did not play. This should never happen." );
	}
	level._radioForcedTransmissionQueue = array_remove_index( level._radioForcedTransmissionQueue, 0 );
}

playAliasOverRadio( soundAlias )
{
	if ( level._radio_in_use )
		return false;

	level._radio_in_use = true;
	level._ac130player playLocalSound( soundAlias, "playSoundOverRadio_done", true );
	level._ac130player waittill( "playSoundOverRadio_done" );
	level._radio_in_use = false;
	level._lastRadioTransmission = getTime();
	level notify( "radio_not_in_use" );
	return true;
}

mission_fail_casualties()
{
	level endon( "stop_casualty_tracking" );

	if ( !isdefined( level._friendlyCount ) )
		level._friendlyCount = 0;
	level._friendlyCount++ ;

	self waittill( "death" );

	level._friendlyCount -- ;

	if ( level._friendlyCount < level._minimumFriendlyCount )
	{
		flag_set( "mission_failed" );
		setdvar( "ui_deadquote", "@AC130_FRIENDLIES_DEAD" );
		maps\_utility::missionFailedWrapper();
	}
}

debug_friendly_count()
{
	while ( getdvar( "ac130_debug_friendly_count", "0" ) != "1" )
		wait 1;

	assert( isdefined( level._friendlyCount ) );

	if ( !isdefined( level._friendlyCountHudElem ) )
	{
		level._friendlyCountHudElem = newHudElem();
		level._friendlyCountHudElem.x = 0;
		level._friendlyCountHudElem.y = 0;
		level._friendlyCountHudElem.fontScale = level._ac130_fontscale;
		level._friendlyCountHudElem.alignX = "left";
		level._friendlyCountHudElem.alignY = "bottom";
		level._friendlyCountHudElem.horzAlign = "left";
		level._friendlyCountHudElem.vertAlign = "bottom";
		// Friendlies: &&1
		level._friendlyCountHudElem.label = &"AC130_DEBUG_FRIENDLY_COUNT";
		level._friendlyCountHudElem.alpha = 1;
	}
	level._friendlyCountHudElem setValue( level._friendlyCount );

	self waittill( "death" );

	level._friendlyCountHudElem fadeOverTime( 0.3 );
	level._friendlyCountHudElem.alpha = 0;
	waittillframeend;
	level._friendlyCountHudElem setValue( level._friendlyCount );
	level._friendlyCountHudElem fadeOverTime( 0.3 );
	level._friendlyCountHudElem.alpha = 1;
}

debug_circle( center, radius, duration, color, startDelay, fillCenter )
{
	circle_sides = 16;

	angleFrac = 360 / circle_sides;
	circlepoints = [];
	for ( i = 0;i < circle_sides;i++ )
	{
		angle = ( angleFrac * i );
		xAdd = cos( angle ) * radius;
		yAdd = sin( angle ) * radius;
		x = center[ 0 ] + xAdd;
		y = center[ 1 ] + yAdd;
		z = center[ 2 ];
		circlepoints[ circlepoints.size ] = ( x, y, z );
	}

	if ( isdefined( startDelay ) )
		wait startDelay;

	thread debug_circle_drawlines( circlepoints, duration, color, fillCenter, center );
}

debug_circle_drawlines( circlepoints, duration, color, fillCenter, center )
{
	if ( !isdefined( fillCenter ) )
		fillCenter = false;
	if ( !isdefined( center ) )
		fillCenter = false;

	for ( i = 0 ; i < circlepoints.size ; i++ )
	{
		start = circlepoints[ i ];
		if ( i + 1 >= circlepoints.size )
			end = circlepoints[ 0 ];
		else
			end = circlepoints[ i + 1 ];

		thread debug_line( start, end, duration, color );

		if ( fillCenter )
			thread debug_line( center, start, duration, color );
	}
}

debug_line( start, end, duration, color )
{
	if ( !isdefined( color ) )
		color = ( 1, 1, 1 );

	for ( i = 0; i < ( duration * 20 );i++ )
	{
		line( start, end, color );
		wait 0.05;
	}
}
