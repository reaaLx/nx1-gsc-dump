
//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_ROCKET_SECTION_											**
//                                                                          **
//    Created: 7/13/2011 - 													**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

NX_ROCKET_TURRET_FOV_NORMAL		= 60;
NX_ROCKET_TURRET_FOV_ZOOM_01	= 40;
NX_ROCKET_TURRET_FOV_ZOOM_02	= 20;

NX_ROCKET_TURRET_STATIC_ALPHA	= 0.15;

NX_ROCKET_TURRET_TURN_RATE				= 0.35;
NX_ROCKET_TURRET_FIRE_RATE		= 5; // ROUNDS PER SECOND


//*******************************************************************
//                                                                  *
//*******************************************************************
start()
{
	teleport_info = [];
	teleport_info[ "ALLY_BAKER" ]		= "start_default_ally_00";
	teleport_info[ "ALLY_JENKINS" ]		= "start_turret_control_ally_01";
	teleport_info[ "ALLY_WILLIAMS" ]	= "start_turret_control_ally_02";
	maps\nx_rocket_util::squad_teleport( teleport_info );
	level._player maps\_nx_utility::move_player_to_start_point( "start_turret_control_player" );

	// Turn off AA turret section smoke
	maps\nx_rocket_util::pre_turret_event();
	issue_color_orders( "b102 p102", "allies" );
}

main()
{
	level thread section_dialogue();

	level thread objective_breach();

	level thread console_pip_setup();

//  thread maps\_utility::set_ambient( "rocket_int_underground" );
	level.aa_control_breach_doors = maps\nx_rocket_anim::aa_control_breach_door_setup();
	level.aa_exit_doors = maps\nx_rocket_anim::aa_exit_door_setup();

	blocker_01 = GetEnt( "turret_control_door_block_01", "targetname" );
	blocker_02 = GetEnt( "turret_control_door_block_02", "targetname" );
	blocker_03 = GetEnt( "turret_control_door_block_03", "targetname" );

	blocker_01 thread blocker_movement();
	blocker_02 Hide();

	thread maps\nx_rocket_fx::forest_fire_fx(); 

	thread maps\_utility::set_ambient( "nx_rocket_turret_int" );

	// SAVE POINT
	level thread autosave_now();

	flag_set( "discovered_turret_control" );

	flag_wait( "turret_control_entered" );

	level thread breach_attacker();

	enemies = enemy_setup();
	maps\nx_rocket_anim::aa_control_breach( 
		enemies[ 0 ], 
		enemies[ 1 ], 
		level.aa_control_breach_doors[ 0 ], 
		level.aa_control_breach_doors[ 1 ], 
		level.squad[ "ALLY_JENKINS" ], 
		level.squad[ "ALLY_WILLIAMS" ] );

	flag_set( "turret_control_turret_ready" );
	wait 3.0;

//  waittill_turret_trigger();
	turret_trigger = GetEnt( "turret_trigger_command", "script_noteworthy" );
	turret_trigger maps\nx_rocket_util::trigger_waittill_use( "Hold [{+usereload}] to take hijack AA turret.");

	turret_enter();
	thread rockets_init();
	thread chopper_init();

	flag_wait( "turret_control_complete" );

	setSavedDvar ("alternateSceneEnable", "0" );
	level._player AlternateSceneCameraUnlink();

	// SAVE POINT
	level thread autosave_now();

	blocker_02 Show();
	blocker_02 Solid();
	blocker_03 Delete();

	escape();

}

breach_attacker()
{
	level._player waittill( "breaching" );

	spawner = GetEnt( "enemy_turret_attacker", "targetname" );	
	attacker = spawner spawn_ai();

	attacker.ignoreAll = true;

//  level._player waittill( "breached" );
	wait 5.0;

	attacker.ignoreAll = false;

	level._player waittill( "breached" );

	slow_scale = 0.15;
	SetSlowMotion( 1.0, slow_scale, 0.5 );

	attacker breach_attacker_wait();

	SetSlowMotion( slow_scale, 1.0, 0.5 );	
}

breach_attacker_wait()
{
	self endon( "death" );

	wait 4.0;

	level._player DoDamage( 30.0, self.origin );
}

blocker_movement()
{
	flag_wait( "turret_control_player_breached" );
	// TEMP REMOVE ENTRY BLOCK
//  self Delete();
	self.origin_old = self.origin;
	self.origin = (0,0,0);

	flag_wait( "turret_control_complete" );
	self.origin = self.origin_old;
}

debug_turret_escape()
{
	teleport_info = [];
	teleport_info[ "ALLY_BAKER" ]		= "start_default_ally_00";
	teleport_info[ "ALLY_JENKINS" ]		= "start_turret_escape_ally_01";
	teleport_info[ "ALLY_WILLIAMS" ]	= "start_turret_escape_ally_02";
	maps\nx_rocket_util::squad_teleport( teleport_info );

	level._player maps\_nx_utility::move_player_to_start_point( "start_turret_escape_player" );

	escape();
}

escape()
{
	thread turret_earthquake();

	maps\nx_rocket_anim::aa_exit_melee( level.aa_exit_doors[0], level.aa_exit_doors[1], level.squad[ "ALLY_WILLIAMS" ] );
	maps\nx_rocket_util::squad_color_reset();

	// SAVE POINT
	level thread autosave_now();

	Objective_State( obj( "OBJ_ESCAPE_AA_BASE" ), "current" );
	Objective_SetPointerTextOverride( obj("OBJ_ESCAPE_AA_BASE"), &"NX_ROCKET_FOLLOW_MARKER" );
	Objective_OnEntity( obj( "OBJ_ESCAPE_AA_BASE" ), level.squad[ "ALLY_WILLIAMS" ], (0, 0, 90) );

	maps\nx_rocket_util::squad_color_reset();
	issue_color_orders( "b151 p151", "allies" );

//  level.squad[ "ALLY_WILLIAMS" ] thread escape_vignettes_williams();

	flag_wait( "vignette_aa_control_exit" );
//  maps\nx_rocket_anim::aa_exitdoors( level.squad[ "ALLY_WILLIAMS" ] );
//  maps\nx_rocket_util::squad_color_reset();
}

console_pip_setup()
{
	self endon( "turret_control_complete" );

	camera_org = GetEnt( "turret_control_pip_camera", "script_noteworthy" );
	camera = spawn_tag_origin();
	camera.origin = camera_org.origin;
	camera.angles = camera_org.angles;

	setSavedDvar ("alternateSceneEnable", "1" );
	level._player AlternateSceneCameraLinkTo( camera, "tag_origin", NX_ROCKET_TURRET_FOV_NORMAL );

	interval = 0;

	while( 1 )
	{
		rate = RandomFloatRange( 10, 30 ); //deg per sec
		theta = RandomFloatRange( -100, 100 );
		rotate_time = abs( theta )/rate;

		pitch = RandomFloatRange( -35, 0 );
		yaw = theta + camera.angles[ 1 ];

		camera RotateTo( ( pitch, yaw, 0), rotate_time );
		camera waittill( "rotatedone" );

		wait RandomFloatRange( 0.5, 2.0 );
	}	
}

///////////////////////////
//		BREACH			 //
///////////////////////////

escape_vignettes_williams()
{
	maps\nx_rocket_anim::aa_corridor_run_out_01_ally( self );
	maps\nx_rocket_anim::aa_corridor_run_out_02_ally( self );

	maps\nx_rocket_util::squad_color_reset();
	issue_color_orders( "b151 p151", "allies" );
}

enemy_setup()
{
	enemies = [];
	spawners = GetEntArray( "turret_enemy", "script_noteworthy" );
	foreach( spawner in spawners )
	{
		enemy = spawner spawn_ai();
		enemy.animname = "enemy_opfor";
		enemy.ignoreme = true;
		enemy.ignoreall = true;

		enemies[ enemies.size ] = enemy;
	}

	return enemies;
//  enemy_guard_node =  GetEnt( "vignette_turret_guard_takedown", "targetname" );
//  enemy_guard_node anim_first_frame_solo( level.turret_enemies[ "enemy_turret_guard" ], "turret_guard_takedown" );
//
//  enemy_operator_node = GetEnt( "turret_controls_seat", "script_noteworthy" );
//  enemy_operator_node thread anim_loop_solo( level.turret_enemies[ "enemy_turret_operator" ], "turret_enemy_turret_idle", "end_turret_idle" );
}

turret_enemy_operator_idle()
{
	spawner = GetEnt( "turret_enemy", "script_noteworthy" );
	enemy_operator = spawner spawn_ai();
	enemy_operator_node = GetEnt( "turret_controls_seat", "script_noteworthy" );
	enemy_operator.animname = "enemy_opfor";
	enemy_operator.ignoreme = true;

	enemy_operator_node thread anim_loop_solo( enemy_operator, "turret_enemy_turret_idle", "end_turret_idle" );

	level.enemy_turret_operator = enemy_operator;
}



waittill_turret_trigger()
{
	trigger = GetEnt( "turret_trigger_command", "script_noteworthy" );

	trigger trigger_on();
	trigger SetHintString( "Hold [{+usereload}] to take hijack AA turret." );
	trigger waittill( "trigger" );
	trigger trigger_off();
}

#using_animtree( "script_model" );
new_turret_enter()
{
	self endon( "turret_exit" );

	// get into turret. 
	turret = GetEnt( "aa_turret_player", "targetname" );
	turret UseBy( self );

	// Disable turret firing. 
	turret TurretFireDisable();
	level._player DisableTurretDismount();

	// Fire bullets. 
	fire_data_array = 
	[
		[ "tag_aim_special1", %nx_pr_rocket_aa_turret_fire_cannon01 ], 
		[ "tag_aim_special2", %nx_pr_rocket_aa_turret_fire_cannon02 ], 
		[ "tag_aim_special3", %nx_pr_rocket_aa_turret_fire_cannon03 ], 
		[ "tag_aim_special4", %nx_pr_rocket_aa_turret_fire_cannon04 ]
	];

	index = 0;

	level.aa_turret_player = turret;

//  self childthread turret_turn_shake();

	while ( 1 )
	{
		wait( 0.01 );

		if ( level._player isUsingTurret() == false )
		{
			continue;
		}

		// Look for attack button. Allows holding. 			
		if ( self AttackButtonPressed() == false )
		{
			continue;
		}

		// Firing HUD FX
		level.turret_hud[ "static" ].alpha	= RandomFloatRange( 0.5, 0.6 );
		level.turret_hud[ "black" ].alpha	= RandomFloatRange( 0.1, 0.2 );		
		level.turret_hud[ "static" ] thread hud_element_alpha( NX_ROCKET_TURRET_STATIC_ALPHA, 0.4 );
		level.turret_hud[ "black" ] thread hud_element_alpha( 0, 0.15 );

		// Play anim. 
 		turret UseAnimTree( #animtree );
 		turret SetAnimRestart( fire_data_array[ index ][ 1 ], 1, 0, 1 );

		// Fire magic bullet. 
		tag_origin = turret GetTagOrigin( fire_data_array[ index ][ 0 ] );
		tag_angles = turret GetTagAngles( fire_data_array[ index ][ 0 ] );
		forward = AnglesToForward( tag_angles ) * 30000;

		angles_to_target = level._player GetPlayerViewAngles();
		
		aim_forward	= AnglesToForward( angles_to_target );
		aim_up		= AnglesToUp( angles_to_target );
		
		bullet_start	= tag_origin;
		bullet_end		= bullet_start + ( aim_forward * 30000 );

		MagicBullet( "nx_rocket_aa_turret", bullet_start, bullet_end );
		//level thread draw_line_for_time( bullet_start, bullet_end, 1, 0, 0, interval );

		fx_org = bullet_start;
		fx_forward = aim_forward;
		fx_up = aim_up;
		playfx( level._effect[ "nx_rocket_aa_flash_view" ], fx_org, fx_forward, fx_up );

		Earthquake( 0.2, 0.3, turret GetTagOrigin( "tag_player" ), 300 );

		// Can be any weapon, turret or normal. 
//  	magicbullet( "ugv_main_turret", tag_origin, tag_origin + forward );

		index++;
		index %= 4;

		// Fire repeat delay time. 
		wait( 0.1 );
	}
}

turret_turn_shake()
{
	while( 1 )
	{
		aim_movement = self GetNormalizedAimMovement();
		aim_scale = length( ( aim_movement[0], aim_movement[1], 0 ) );
		shake_scale = aim_scale * 0.15;
		shake_time = 0.5 + aim_scale * 0.5;

		if( aim_scale > 0 )
			Earthquake( shake_scale, shake_time, level.aa_turret_player GetTagOrigin( "tag_player" ), 300 );

		wait 0.3;
	}
}

turret_enter()
{
	turret_mode( true );

	turret_controls_lookat();

	turret_hud( true );

	flag_set( "turret_control_controls_entered" );

	level._player thread new_turret_enter();
//  turret_view_build();

	thread maps\_ambient::use_eq_settings_fade( "nx_rocket_turret_fire", level._eq_mix_track, 0.5 );

	level._player thread turret_on_ads_press();
//  level._player thread turret_on_fire_press();
}

turret_exit()
{	
	turret_mode( false );
	turret_hud( false );

	level.aa_turret_player Delete();
//  level._player Unlink();
	flag_set( "turret_control_complete" );
}

turret_mode( enable )
{
	// MOVEMENT
	level._player AllowCrouch( !enable );
	level._player AllowProne( !enable );

	if( enable )
	{
		// View
		level._player HideViewModel();
		level._player DisableWeapons();

		// FOV
		level._player.prev_fov = int( getdvar( "cg_fov" ) );
		lerp_fov_overtime( 0.05, NX_ROCKET_TURRET_FOV_NORMAL );

		// TURN
		SetSavedDvar( "aim_scale_turn_rate", NX_ROCKET_TURRET_TURN_RATE );
	}
	else
	{
		// View
		level._player ShowViewModel();
		level._player EnableWeapons();
		
		// FOV
		lerp_fov_overtime( 0.05, level._player.prev_fov );

		// TURN
		SetSavedDvar( "aim_scale_turn_rate", 1.0 );
	}

}

turret_view_build()
{
	camera_org = GetEnt( "turret_view", "script_noteworthy" );
	camera_mover = spawn_tag_origin();
	camera_mover.origin = camera_org.origin;
	camera_mover.angles = camera_org.angles;

	barrel_mover = spawn_tag_origin();
	barrel_mover.origin = camera_mover.origin;
	barrel_mover.angles = camera_mover.angles;

//  camera_mover thread turret_move_by_stick( 2, 2, 180, 180, 90, 30 );

	level._player SetOrigin( camera_mover.origin );
	level._player SetPlayerAngles( camera_mover.angles );
	level._player PlayerLinkToDelta( camera_mover, "tag_origin", 0.0, 180, 180, 90, 25 );

	level.turret_barrels = GetEntArray( "turret_barrel", "script_noteworthy" );
	foreach( barrel in level.turret_barrels )
	{
		barrel_model		= spawn_anim_model( "turret_barrel", barrel.origin );
		barrel_model.angles = barrel.angles;
		barrel_model LinkTo( barrel );
		barrel.barrel_model = barrel_model;
		barrel LinkTo( barrel_mover );

		barrel.origin_o = barrel.origin;
	}

	barrel_mover thread link_to_player_view();
}

turret_controls_lookat()
{
	camera_lookat = GetEnt( "turret_controls_lookat", "script_noteworthy" );

	camera_org = spawn_tag_origin();
	camera_org.origin = level._player.origin;
	camera_org.angles = level._player.angles;

	level._player.prev_origin = level._player.origin;
	level._player.prev_angles = level._player.angles;

	level._player PlayerLinkToDelta( camera_org, "tag_origin", 1.0, 180, 180, 90, 25 );

	eye_pos = level._player GetEye();
	camera_mover = spawn( "script_origin", camera_org.origin + ( eye_pos - camera_org.origin ) );
	camera_mover.angles = camera_org.angles;
	camera_org LinkTo( camera_mover );

	camera_mover RotateTo( VectorToAngles( camera_lookat.origin - camera_mover.origin ), 0.8, 0.7 );
	camera_mover waittill( "rotatedone" );
	camera_mover MoveTo( camera_lookat.origin, 0.8, 0.2 );
	camera_mover waittill( "movedone" );

	camera_mover Delete();
}


link_to_player_view()
{
	self endon( "death" );
	self endon( "delete" );

	while( 1 )
	{
		self.angles = level._player GetPlayerViewAngles();
		wait 0.05;
	}
}

//////////////////////////
//     HUD              //
//////////////////////////

turret_hud( enable )
{
	if( enable )
		level._player thread turret_hud_create();
	else
		level._player turret_hud_destroy();
}

turret_hud_create()
{
	level.turret_hud = [];

	VisionSetThermal( "oilrig_underwater" );
	VisionSetNight( "oilrig_underwater" );
//  self ThermalVisionOn();
//  self NightVisionOn();

	static = NewClientHudElem( self );
	static.horzAlign = "fullscreen";
	static.vertAlign = "fullscreen";
	static SetShader( "ac130_overlay_grain", 640, 480 );
	static.alpha = 1.0;
	static thread hud_element_alpha( NX_ROCKET_TURRET_STATIC_ALPHA, 1.5 );
	level.turret_hud[ "static" ] = static;

	black_overlay = newClientHudElem( level._player );
	black_overlay.x = 0;
	black_overlay.y = 0;
	black_overlay.alignX = "left";
	black_overlay.alignY = "top";
	black_overlay.horzAlign = "fullscreen";
	black_overlay.vertAlign = "fullscreen";
	black_overlay setshader( "black", 640, 480 );
	black_overlay.sort = -10;
	black_overlay.alpha = 0.0;
	level.turret_hud[ "black" ] = black_overlay;

	turret_reticle = newClientHudElem( level._player );
	turret_reticle setshader( "nx_aa_turret_overlay", 640, 320 );
	turret_reticle.x = 0;
	turret_reticle.y = 0;
	turret_reticle.alignx 		= "center";
	turret_reticle.aligny		= "middle";
	turret_reticle.horzAlign	= "center";
	turret_reticle.vertAlign	= "middle";
	level.turret_hud[ "reticle" ] = turret_reticle;

	stripe = newClientHudElem( level._player );
	stripe.x = 0;
	stripe.y = 0;
	stripe.alignX = "left";
	stripe.alignY = "top";
	stripe.horzAlign = "fullscreen";
	stripe.vertAlign = "top";
	stripe setshader( "black", 640, 120 );
	stripe.alpha = 0.05;
	stripe thread hud_stripe_update();
	level.turret_hud[ "stripe" ] = stripe;
}

turret_hud_destroy()
{
	level.turret_hud[ "black" ].alpha = 1;
	level.turret_hud[ "static" ].alpha = 1;
	level.turret_hud[ "reticle" ].alpha = 0;

	wait 2.0;

	foreach( element in level.turret_hud )
	{
		element Destroy();
	}

	level._player ThermalVisionOff();
}

hud_stripe_update()
{
	self endon("death");
	
	speed = 50; //pixels per sec
	interval = 0.05;

	while( 1 )
	{
		if( self.y > 480 )
			self.y = -120;
		self.y += speed / ( 1/interval );
		wait interval;
	}
}

hud_element_alpha( alpha, time )
{
	self thread fade_over_time( alpha, time );
}

turret_on_ads_press()
{
	self endon( "turret_exit" );
	while( 1 )
	{
		self turret_waittill_ads_pressed();
		self turret_waittill_ads_released();
		level.turret_hud[ "static" ].alpha = 1.0;
		lerp_fov_overtime( 0.05, NX_ROCKET_TURRET_FOV_ZOOM_01 );
		level.turret_hud[ "static" ] hud_element_alpha( NX_ROCKET_TURRET_STATIC_ALPHA, 1.0 );
		wait 0.25;

		self turret_waittill_ads_pressed();
		self turret_waittill_ads_released();
		level.turret_hud[ "static" ].alpha = 1.0;
		lerp_fov_overtime( 0.05, NX_ROCKET_TURRET_FOV_ZOOM_02 );
		level.turret_hud[ "static" ] hud_element_alpha( NX_ROCKET_TURRET_STATIC_ALPHA, 1.0 );
		wait 0.25;

		self turret_waittill_ads_pressed();
		self turret_waittill_ads_released();
		level.turret_hud[ "static" ].alpha = 1.0;
		lerp_fov_overtime( 0.05, NX_ROCKET_TURRET_FOV_NORMAL );
		level.turret_hud[ "static" ] hud_element_alpha( NX_ROCKET_TURRET_STATIC_ALPHA, 1.0 );
		wait 0.25;
	}	
}

turret_on_fire_press()
{
	self endon( "turret_exit" );	
	while( 1 )
	{
		self turret_waittill_fire_pressed();

		self thread turret_fire_start();

		self turret_waittill_fire_released();

		self thread turret_fire_stop();
		
		wait 0.5;
	}
}

turret_fire_start()
{
	self endon( "turret_stop_fire" );
	self endon( "turret_exit" );
	
	interval = 1 / NX_ROCKET_TURRET_FIRE_RATE;

	curr_barrel = 0;

	while( 1 )
	{
		level.turret_hud[ "static" ].alpha	= RandomFloatRange( 0.5, 0.6 );
		level.turret_hud[ "black" ].alpha	= RandomFloatRange( 0.1, 0.2 );
		
		level.turret_hud[ "static" ] thread hud_element_alpha( NX_ROCKET_TURRET_STATIC_ALPHA, interval*2.0 );
		level.turret_hud[ "black" ] thread hud_element_alpha( 0, interval*0.5 );

		barrel = level.turret_barrels[ curr_barrel ];
	
		tag_origin	= barrel.barrel_model GetTagOrigin( "tag_flash" );
		tag_angles	= barrel.barrel_model GetTagAngles( "tag_flash" );

		angles_to_target = level._player GetPlayerViewAngles();
		
		aim_forward	= AnglesToForward( angles_to_target );
		aim_up		= AnglesToUp( angles_to_target );
		
		bullet_start	= tag_origin;
		bullet_end		= bullet_start + ( aim_forward * 30000 );

		MagicBullet( "nx_rocket_aa_turret", bullet_start, bullet_end );
		//level thread draw_line_for_time( bullet_start, bullet_end, 1, 0, 0, interval );

		fx_org = bullet_start;
		fx_forward = aim_forward;
		fx_up = aim_up;
		playfx( level._effect[ "nx_rocket_aa_flash_view" ], fx_org, fx_forward, fx_up );

		Earthquake( 0.2, 0.3, barrel.origin, 300 );

		curr_barrel++;
		if( curr_barrel >= level.turret_barrels.size )
			curr_barrel = 0;
		
		wait interval;
	}
}

#using_animtree( "vehicles" );
barrel_recoil()
{
	self endon( "death" );
	self endon( "delete" );

//  #using_animtree( "vehicles" );
	self UseAnimTree( #animtree );
	self SetAnimRestart( %nx_vh_ugv_main_turret_fire, 1, 0, 1 );

//  back_vec = vector_multiply( AnglesToForward( self.angles ), -100 );
//
//  dest = self.origin_o + back_vec;
//  self MoveTo( dest, 0.5 );
//  self waittill( "movedone" );
//  self MoveTo( self.origin_o, 0.75 );
}

turret_fire_stop()
{
	self notify( "turret_stop_fire" );
}

turret_waittill_ads_pressed()
{
	while( ( self AdsButtonPressed() ) )
	{
		wait 0.05;
	}
}

turret_waittill_ads_released()
{
	while( !( self AdsButtonPressed() ) )
	{
		wait 0.05;
	}
}

turret_waittill_fire_pressed()
{
	while( !( self AttackButtonPressed() ) )
	{
		wait 0.05;
	}
}

turret_waittill_fire_released()
{
	while( self AttackButtonPressed() )
	{
		wait 0.05;
	}
}

turret_camera_fire_static()
{
	self endon( "turret_stop_fire" );

	while( 1 )
	{
		transition_time = RandomFloatRange( 0.15, 0.25 );
		static_alpha = RandomFloatRange( 0.4, 0.8 );
		black_alpha = RandomFloatRange( 0.1, 0.25 );
		level.turret_hud[ "black" ].alpha = black_alpha;
		level.turret_hud[ "static" ].alpha = static_alpha;

		wait transition_time;
	}
}

turret_barrel_fire_stop( )
{
	self notify( "turret_stop_fire" );
}

//////////////////////////
//     ROCKETS          //
//////////////////////////

rockets_init()
{
	level.turret_rockets = [];
	level.rocket_number = 15;

	foreach( rocket in GetEntArray( "turret_rocket", "script_noteworthy" ) )
	{
	  	rocket rocket_init();
		level.turret_rockets[ rocket.targetname ] = rocket;		
	}

	level.turret_rockets[ "rocket_01" ] rocket_launch( 0.0, 60, 1200 );
	level.turret_rockets[ "rocket_03" ] rocket_launch( 0.0, 60, 1800 );
	level.turret_rockets[ "rocket_02" ] rocket_launch( 0.0, 60, 2000 );
	level.turret_rockets[ "rocket_04" ] rocket_launch( 0.0, 60, 2200 );

}

rocket_init()
{
	self.damage_collision = GetEnt( self.target, "targetname" );

	self.pieces = [];

	self.pieces[ self.pieces.size ] = spawn_anim_model( "rocket_shuttle_exp1_010" );
	self.pieces[ self.pieces.size ] = spawn_anim_model( "rocket_shuttle_exp1_011" );
	self.pieces[ self.pieces.size ] = spawn_anim_model( "rocket_shuttle_exp1_012" );
	
	foreach( piece in self.pieces )
	{
		piece.origin = self.origin;
		piece LinkTo( self );
	}
	
	self.damage_collision.health = 8000;
	self.damage_collision SetCanDamage( true );
	self.damage_collision thread rocket_piece_on_damage();
	self.damage_collision thread rocket_piece_on_death( self );

	self.damage_collision LinkTo( self );

	self thread anim_first_frame( self.pieces, "rocket_shuttle_exp1" );

	trail_tag = spawn_tag_origin();
	trail_tag.origin = self.origin;
	//  trail_tag.angles = ( 270, 0, 0 );
	trail_tag LinkTo( self );
	self.trail_tag = trail_tag;
	PlayFXOnTag( GetFX( "nx_smoke_rocket_afterburner_liftoff" ), self.trail_tag, "tag_origin" );
	
	self.angles = self.angles + (0, RandomFloatRange( 0, 360 ), 0);
}


rocket_piece_on_damage()
{
	self endon( "death" );
	while( 1 )
	{
		self waittill( "damage" );
		
		wait 0.05;
	}
}

rocket_piece_on_death( rocket )
{
	self waittill( "death" );
	
	rocket thread rocket_death();
}

rocket_death()
{
	self thread rocket_final();

	self thread rocket_death_static();

	thread maps\nx_rocket_fx::aa_rocket_hit_fx( self.pieces[0], self.pieces[1], self.pieces[2] );

	PlayFX( GetFX( "rocket_explosion" ), self.origin + (0, 0, 1000) );

	thread audio_rocket_explosion(self.origin);

	StopFXOnTag( GetFX( "nx_smoke_rocket_afterburner_liftoff" ), self.trail_tag, "tag_origin" );
	RadiusDamage( self.origin, 5000, 1000, 1000 );

//  Objective_state( self.rocket_number, "done" );

	self anim_single( self.pieces, "rocket_shuttle_exp1" );

	wait 0.05;

//  self Delete();
	self rocket_cleanup();
}

audio_rocket_explosion(placetoplay)
{

	explosionsoundemitter = spawn( "sound_emitter", placetoplay );
	explosionsoundemitter playsound ("rocket_explosion_big2");

}

rocket_death_static()
{
	level.turret_hud[ "static" ] thread hud_element_alpha( 1.0, 0.1 );

	wait 0.5;

	level.turret_hud[ "static" ] thread hud_element_alpha( 0.0, 2.0 );	
}

rocket_cleanup()
{
	foreach( piece in self.pieces )
	{
		piece Delete();
	}

	self.damage_collision Delete();

	self Delete();
}

rocket_on_damage()
{
	self endon( "death" );
	while( 1 )
	{
		self waittill( "damage" );
//  	iPrintlnBold( self.health );
		wait 0.05;
	}
}

rocket_launch( delay, travel_time, start_height )
{
	wait (delay);

//  self playsound("rocket_launch_alarm"); //play the alarm on that rocket

//  wait 2.0;

//  self playsound("rocket_launching_long"); //play the rocket launching sound

	self.origin += (0, 0, start_height );
	self MoveTo( self.origin + (0,0,24000), travel_time );
	self.rocket_number = level.rocket_number;
//  self thread rocket_on_death( level.rocket_number );

//  self thread rocket_on_damage();

//  Objective_Add( level.rocket_number, "current" );
//  Objective_OnEntity( level.rocket_number, self.pieces[0], (0,0, 2500) );
	level.rocket_number++;

	self thread rocket_on_flight_complete();

//  self Delete();
	// MISSION FAIL HERE
}

rocket_on_flight_complete()
{
//  self endon( "death" );
//  self endon( "delete" );
	self.damage_collision endon( "death" );
	self waittill( "movedone" );
//  self stopsounds();
//  self Kill();
	SetDvar( "ui_deadquote", "ROCKET ESCAPED" );
	level notify( "mission_failed" );
	maps\_utility::missionFailedWrapper();
}

rocket_final()
{
	foreach( rocket in level.turret_rockets )
	{
		if( IsAlive( rocket.damage_collision ) )
		{
			return;
		}
	}

	self notify( "turret_exit" );
	level._player notify( "turret_exit" );

	debris = spawn( "script_model", self.origin );

	debris Hide();
	wait 0.1;
	debris Show();
	debris SetModel( "nx_rocket_viz_lg_01_dmg" );

//  eye_origin = level.aa_turret_player GetTagOrigin( "tag_player" );
//  view_angles = VectorToAngles( debris.origin - eye_origin );
//  player_view_angles = level._player GetPlayerViewAngles();
//  level._player LerpViewAngleClamp( 0.5, 0.25, 0.25, player_view_angles[1], player_view_angles[1], player_view_angles[2], player_view_angles[2] );
//  level.aa_turret_player makeTurretInoperable();
//  level.aa_turret_player SetTargetEntity( debris );

	SetSavedDvar( "aim_scale_turn_rate", 0 );

	fall_time = 3.0;
	debris MoveTo( level.aa_turret_player.origin + (0, 0, -50), fall_time, fall_time );
	debris RotateTo( ( RandomFloatRange(0, 360), RandomFloatRange(0, 360), RandomFloatRange(0, 360) ), 4.0 );
	Earthquake( 0.5, fall_time, level.aa_turret_player GetTagOrigin( "tag_player" ), 300 );

//  debris waittill( "movedone" );
	wait( fall_time - 0.05 );

	turret_exit();
}

//////////////////////////
//     CHOPPERS         //
//////////////////////////

chopper_init()
{
//  ally_spawners = GetEntArray( "chopper_turret_control_ally", "script_noteworthy" );
//
//  foreach( spawner in ally_spawners )
//  {
//  	chopper = vehicle_spawn( spawner );
//  	chopper GoPath();
//  }

//  enemy_spawners = GetEntArray( "chopper_turret_control", "script_noteworthy" );
//
//  foreach( spawner in enemy_spawners )
//  {
//  	chopper = vehicle_spawn( spawner );
//  	chopper GoPath();
//  }
}

turret_exit_player()
{
	self SetOrigin( self.prev_origin );
	self SetPlayerAngles( self.prev_angles );

	flag_set( "turret_control_complete" );
}

turret_earthquake()
{
	self endon( "vignette_aa_control_exit" );
	earthquake_source = GetEnt( "turret_controls_lookat", "script_noteworthy" );
	earthquake_radius = 1000;

	while( 1 )
	{	
		wait RandomFloatRange( 0.0, 2.0 );
		earthquake_length = RandomFloatRange( 1.0, 4.0 );
		earthquake_scale = RandomFloatRange( 0.1, 0.2 );
		Earthquake( earthquake_scale, earthquake_length, earthquake_source.origin, earthquake_radius );
		
		theta = RandomFloatRange( 0, 360 );
		r = RandomFloatRange( 0, 64 );
		fx_offset = ( cos( level._player.angles[1] ) * r, sin( level._player.angles[1] ) * r, 50 );
		PlayFX( GetFX( "nx_hallway_collapsing_big" ), level._player.origin + fx_offset );
		exploder("hallway_fx");
		wait earthquake_length;
	}
}

objective_breach()
{
	// BREACH
	wait 2.0;
	breach_objective_marker = GetEnt( "turret_base_breach_objective", "targetname" );

	Objective_ClearAllAdditionalEntities( obj( "OBJ_THROUGH_AA_BASE" ) );
	Objective_State( obj( "OBJ_THROUGH_AA_BASE" ), "current" );
	Objective_SetPointerTextOverride( obj("OBJ_THROUGH_AA_BASE"), "" );
	Objective_OnEntity( obj( "OBJ_THROUGH_AA_BASE" ), breach_objective_marker );

	// TURRET
	level._player waittill( "breached" );
	turret_objective_marker = GetEnt( "turret_base_turret_objective", "targetname" );

	Objective_ClearAllAdditionalEntities( obj( "OBJ_THROUGH_AA_BASE" ) );
	Objective_State( obj( "OBJ_THROUGH_AA_BASE" ), "current" );
	Objective_SetPointerTextOverride( obj("OBJ_THROUGH_AA_BASE"), "" );
	Objective_OnEntity( obj( "OBJ_THROUGH_AA_BASE" ), turret_objective_marker );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
section_dialogue()
{
	flag_wait( "discovered_turret_control" );
//  maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_wil_tubase_leadtheway" );
//  level thread add_dialogue_line( "Williams", "Lockwood, you lead the way. We got your back.", undefined, 3.0 );

	flag_wait( "turret_control_turret_ready" );
//  level thread add_dialogue_line( "Williams", "Lockwood, take the controls. Let's take the rest of these bastards down.", undefined, 3.0 );
	maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_wil_trctrl_takethecontrols" );

	flag_wait( "turret_control_complete" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 3, "roc_wil_trctrl_needtomove" );
//  maps\nx_rocket_util::wait_play_dialogue_wait( 0, "roc_will_trctrl_jenkinsgetdoor" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 3, "roc_wil_trctrl_keepmoving" );
	maps\nx_rocket_util::wait_play_dialogue_wait( 3, "roc_wil_trctrl_gogogo" );

//  level thread add_dialogue_line( "Williams", "Jenkins! Get that door open!", undefined, 3.0 );
//  wait 1.0;
//  level thread add_dialogue_line( "Williams", "Move! Move! Move!", undefined, 3.0 );
//  wait 4.0;
//  level thread add_dialogue_line( "Williams", "Lockwood! Get out of here!", undefined, 3.0 );
//  wait 6.0;
//  level thread add_dialogue_line( "Williams", "Keep moving!", undefined, 3.0 );

}

section_precache()
{
	level._effect[ "rocket_explosion" ]		= LoadFX( "nx/explosions/nx_explosion_rocket_01" );
	level._effect[ "rocket_trail" ]			= LoadFX( "misc/dcemp_icbm_trail" );
	//level._effect[ "ceiling_dust" ]			= LoadFX( "dust/ceiling_dust_default" );
	PrecacheModel( "nx_rocket_viz_lg_01" );
	PrecacheModel( "nx_rocket_viz_lg_01_dmg" );
	PreCacheItem( "nx_rocket_aa_turret" );
//  PreCacheItem( "nx_rocket_aa_turret_player" );
	PreCacheShader( "nx_aa_turret_overlay" );
	PreCacheShader( "ac130_overlay_grain" );
}


section_flag_inits()
{
	flag_init( "discovered_turret_control" );
	flag_init( "turret_control_complete" );
	flag_init( "turret_control_entered" );
	flag_init( "vignette_aa_control_melee" );
	flag_init( "vignette_aa_control_exit" );
	flag_init( "turret_control_turret_ready" );
	flag_init( "turret_control_controls_entered" );
	flag_init( "turret_control_player_breached" );
}
