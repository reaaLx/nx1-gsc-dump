//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  MISSION DESCRIPTION											**
//                                                                          **
//    Created: 7/15/2011 - Ken Moodie										**
//                                                                          **
//****************************************************************************


#include maps\_utility;
#include maps\_utility_code;
#include maps\_nx_objective_util;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_nx_utility;
#include maps\nx_skyscraper_util;

//*******************************************************************
// RAPPEL                                                           *
//                                                                  *
//*******************************************************************

rappel_start()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_rappel" );
	thread maps\nx_skyscraper_fx::set_vision_and_fog("exterior_up_high", 0); // set appropriate vision and fog
	maps\nx_skyscraper_util::player_weapon_init( true );

	thread maps\_utility::set_ambient( "amb_skyscraper_office_int" );

	maps\nx_skyscraper_util::spawn_baker();
	baker_teleport = GetEnt ("baker_rappel_teleport", "targetname");
	level.baker ForceTeleport( baker_teleport.origin, baker_teleport.angles);

	Exploder( "fx_office_inferno" );

	// Show cloud ring.
	thread fx_show_cloud_ring();
	
	flag_set( "flag_vtol_floor_collapse_done" );
	wait .1;
	level notify ("office_enemies_dead");
	wait .1;
	
	// tagBR< HACK >: Uncomment these to teleport to just before the jump-out point
	//wait 1; 
	//IPrintLnBold( "teleporting..." );
	//level._player SetOrigin( ( -448, -877, 29576 ) );
}

rappel_sequence()
{

	level thread uav_reveal_sequence();
	level thread retether_sequence();
	level thread debris_control();
	level thread falling_landing_pad();
	level thread baker_rappel_control();

	level thread rappel_fx();

	//trigger = GetEnt ("rappel_hook_up_point", "targetname");
	//trigger = GetEnt ("rappel_start", "targetname");
	//trigger waittill ("trigger");
	flag_wait("flag_rappel_jump_start");
	thread autosave_now();

	level thread decoy_heli();
	level thread break_jump_glass();
	Stop_Exploder( "fx_office_inferno" );

	rappel_jumpout_start();

	level thread boss_heli_sequence();
	level thread washerbot_control();
	level thread rappel_slide_slowmo();
	level thread rappel_laser_start();

	// radial blur - uncomment this line to turn it on.
	thread maps\nx_skyscraper_fx::player_rappel_blur();

	level._player maps\_rappel::rappel_setup( "rappel_tether_pos_and_angles", 1500, 1.5 );

	flag_wait ("flag_rappel_swing_done");

}

baker_rappel_control()
{	guys = [];
	guys["ally_01"] = level.baker;
	node = getstruct("rappel_bakersign", "script_noteworthy");
	flag_wait( "flag_baker_section_01" );
	node anim_single(guys, "rappel_baker_section_01");
	//flag_wait( "flag_bakersign" );
	node anim_single(guys, "rappel_bakersign");
	//flag_wait( "flag_baker_section_02" );
	node anim_single(guys, "rappel_baker_section_02");
	//flag_wait( "flag_bakerwindow" );
	node anim_single(guys, "rappel_bakerwindow");
	//flag_wait( "flag_baker_section_03" );
	node anim_single(guys, "rappel_baker_section_03");
}

retether_sequence()
{
	flag_wait("flag_retether2");
	retether_position = getstruct("retether_pos2", "targetname");
	level._tether_pos = retether_position.origin;
}

uav_reveal_sequence()
{

	// trigger_wait_targetname( "trigger_rappel_location" );

	// spawn Baker and send him to the node by the pillar
	// rappel_hookup_baker = spawn_targetname( "rappel_hookup_baker", true);
	level.baker.goalradius = 8;
	baker_node = GetNode("node_baker_rappel_hookup", "targetname");
	wait 0.25;
	level.baker SetGoalNode( baker_node );
	
	//thread add_dialogue_line( "Baker", "Let's find a place to hook up for our descent.", "g" );
	level.baker dialogue_queue( "sky_bak_rappel_findplacehookup" );

	// glowing button objective stuff
	button = GetEnt( "brushmodel_rappel_hookup", "targetname" );
	button_active = GetEnt( "brushmodel_rappel_hookup_active", "targetname" );
	button_trigger = GetEnt( "trigger_rappel_button_use", "targetname" );


	// Enable button objective
	//trigger_wait_targetname( "trigger_rappel_location" );
	
	level.baker waittill("goal");
	//thread add_dialogue_line( "Baker", "All right.  Let's hook up here.", "g" );
	level.baker dialogue_queue( "sky_bak_rappel_hookuphere" );

	button_trigger trigger_on();

	button hide();
	button_active show();

	//button_trigger sethintstring( &"NX_SKYSCRAPER_OBJ_HALON_BUTTON" );
	button_trigger sethintstring( "Press X to hook up for rappel" );
	button_trigger waittill( "trigger" );
	button_trigger trigger_off();
	button show();
	button_active hide();
	level notify ("rappel_hook_up_start");

	// Baker play the hookup anim
	node = GetEnt( "node_baker_hookup_vignette", "script_noteworthy");
	baker = level.baker;
	// baker.animname = "baker";
	node anim_reach_solo (baker, "rappel_setup");
	node thread anim_single_solo (baker, "rappel_setup" );
	// Play the player hookup anim
	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player DisableWeapons( true );
	player_rig = spawn_anim_model( "player_rig" );
	arc = 15;
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	player_node = GetEnt( "node_player_hookup_vignette", "script_noteworthy" );

	player_node anim_single_solo( player_rig, "hookup" );
	// reveal the uav
	wait 1.0;
	/* level._player.ignoreme = true;
	level.heli1 = spawn_vehicle_from_targetname_and_drive( "reveal_uav" );
	level.heli1 Vehicle_SetSpeed( 15 );
	level.heli1 godon();
	level.heli1 SetLookAtEnt( level._player );
	wait 1.0;
	thread add_dialogue_line( "Baker", "Shit! UAV!  Let's move!", "g" );
	wait 3.75; */

	thread maps\_utility::set_ambient( "amb_skyscraper_windy_ext" );
	flag_set("flag_rappel_jump_start");
}


break_jump_glass()
{
	wait 1.5;
	//glass_triggers = GetEntArray( "jump_glass", "script_noteworthy");
	glass_triggers = GetGlassArray( "jump_glass" );
	foreach( glass_trigger in glass_triggers )
		{
			DestroyGlass( glass_trigger, (0, 1, 0) );
			wait 0.1;
			//DestroyGlass( glass_trigger );
		}
}

rappel_fx()
{
	PlayFx( level._effect[ "cloud_bank_gulag" ], (-256, -2432, 29440 ));
	wait 0.25;
	PlayFx( level._effect[ "cloud_bank_gulag" ], (384, -2560, 28800 ));
	wait 0.25;
	PlayFx( level._effect[ "cloud_bank_gulag" ], (-384, -2400, 27840 ));
	wait 0.25;
	PlayFx( level._effect[ "cloud_bank_gulag" ], (-48, -2464, 22320 ));
}

rappel_jumpout_start()
{
	
	level thread rappel_fov();	

	//node = getstruct("rappel_jump", "script_noteworthy");
	node = getstruct("rappel_jump_new", "script_noteworthy");
	// rappel_jump_baker = spawn_targetname( "rappel_jump_baker", true);
	// rappel_jump_baker.animname = "rappel_jump_baker";

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["player_rig"] = player_rig;
	guys["ally_01"] = level.baker;

	arc = 5;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "rappel_jump");

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
}

rappel_fov()
{
	wait 3.5;
	lerp_fov_overtime( 1, 70 );
}

decoy_heli()
{
	level._player.ignoreme = true;
	heli = spawn_vehicle_from_targetname_and_drive( "decoy_heli" );
	heli Vehicle_SetSpeed( 20 );
	heli SetLookAtEnt( level._player );
	end_heli = spawn_vehicle_from_targetname("end_heli");
}



boss_heli_sequence()
{	

	//thread physobj_volume_control();
	level._player.ignoreme = true;
	fire_offset = 100;
	// heli rocket firing sequence
	flag_wait( "flag_spawn_heli1" );
	level.heli1 = spawn_vehicle_from_targetname_and_drive( "placement_heli1" );
	level.heli1 Vehicle_SetSpeed( 50 );
	level.heli1 godon();
	level.heli1 SetLookAtEnt( level._player );
	//
	wait 0.15;
	heli_target01 = GetEnt("heli_target01", "targetname");
	thread heli_target_missile( level.heli1, heli_target01, 0.7, 0 );
	wait 0.5;
	heli_target02 = GetEnt("heli_target02", "targetname");
	thread heli_target_missile( level.heli1, heli_target02, 0.7, 0 );
	wait 0.5;
	heli_target03 = GetEnt("heli_target03", "targetname");
	thread heli_target_missile_with_fire( level.heli1, heli_target03, 0.8, 0 );
	//flag_wait("flag_rappel_incline_end");
	wait 0.8;
	PhysicsExplosionSphere( heli_target03.origin , 2000, 1999, 1 );
	wait 0.8;
	heli_target04 = GetEnt("heli_target04", "targetname");
	thread heli_target_missile( level.heli1, heli_target04, 1.25, -100 );
	wait 0.20;
	heli_target05 = GetEnt("heli_target05", "targetname");
	heli_target05_debris = GetEnt( "heli_target05_debris", "script_noteworthy" );
	thread heli_target_missile_with_fire( level.heli1, heli_target05, 1.25, -100, heli_target05_debris );
	wait 0.20;
	incline_target = GetEnt("incline_target01", "targetname");
	incline_target_debris = GetEnt( "incline_target01_debris", "script_noteworthy" );
	thread heli_target_missile_with_fire( level.heli1, incline_target, 1.75, -100, incline_target_debris );
	wait 0.75;
	//physics explosions for desks hit by the above rockets.
	explosion_target = GetEnt("heli_target04", "targetname");
	PhysicsExplosionSphere( explosion_target.origin + (0, 60, 0), 2000, 1999, 1 );
	wait 0.2;
	explosion_target = GetEnt("heli_target05", "targetname");
	PhysicsExplosionSphere( explosion_target.origin + (0, 60, 0), 2000, 1999, 1 );

	// spawn the next helicopter
	flag_wait( "flag_spawn_heli2" );
	level.heli1 kill();
	level.heli2 = spawn_vehicle_from_targetname_and_drive( "placement_heli2" );
	level.heli2 Vehicle_SetSpeed( 10 );
	level.heli2 godon();
	level.heli2 SetLookAtEnt( level._player );
	wait 0.25;
	target = GetEnt("heli_target10", "targetname");
	MagicBullet( "rpgx_straight", level.heli2.origin+ (0, fire_offset, 0), target.origin);
	target = GetEnt("heli_target07", "targetname");
	MagicBullet( "rpgx_straight", level.heli2.origin+ (0, fire_offset, 0), target.origin);
	//wait 0.75;
	// physic push letters
	explosion_base = GetEnt("explosion_base02", "targetname");
	PhysicsExplosionSphere( explosion_base.origin, 2000, 1999, 1 );
	PlayFX( level._effect["nx_explosion_skybridge"], explosion_base.origin );
	wait 0.5;
	PlayFX( level._effect["nx_explosion_skybridge"], explosion_base.origin + (0, 0, -400));
	wait 0.5;
	PlayFX( level._effect["nx_explosion_skybridge"], explosion_base.origin + (0, 0, -800));
	//
	//wait 0.05;
	ledge_target01 = GetEnt( "ledge_target01", "targetname" );
	ledge_target01_debris = GetEnt( "ledge_target01_debris", "script_noteworthy" ); 
	thread heli_target_missile_with_fire( level.heli2, ledge_target01, 1.0, -100, ledge_target01_debris );
	wait 0.1;
	ledge_target02 = GetEnt( "ledge_target02", "targetname" );
	thread heli_target_missile_with_fire( level.heli2, ledge_target02, 1.25, -100 );
	// physics push the building supports
	wait 0.85;
	explosion_base = GetEnt("support_target1", "targetname");
	PhysicsExplosionSphere( explosion_base.origin, 200, 199, 1 );
	wait 0.1;
	explosion_base = GetEnt("support_target2", "targetname");
	PhysicsExplosionSphere( explosion_base.origin, 200, 199, 1 );
	//
	// Spawn the next 2 helicopters
	flag_wait( "flag_spawn_heli3" );
	thread spawn_and_kill_wreckage_chopper();

	level.heli2 kill();
	level.heli3 = spawn_vehicle_from_targetname_and_drive( "placement_heli3" );
	level.heli3 Vehicle_SetSpeed( 50 );
	level.heli3 godon();
	level.heli3 SetLookAtEnt( level._player );
	level.heli4 = spawn_vehicle_from_targetname_and_drive( "placement_heli4" );
	level.heli4 Vehicle_SetSpeed( 5 );
	level.heli4 godon();
	level.heli4 SetLookAtEnt( level._player );
	//
	wait 0.1;
	target = GetEnt("mid_target01", "targetname");
	target_debris = GetEnt( "mid_target01_debris", "script_noteworthy" );
	//MagicBullet( "rpgx_straight", level.heli3.origin+ (0, fire_offset, 0), target.origin);
	thread heli_target_missile_with_fire( level.heli3, target, 1.25, -100, target_debris );
	wait 0.7;
	target = GetEnt("cleanerbot_target01", "targetname");
	MagicBullet( "rpgx_straight", level.heli3.origin+ (0, fire_offset, 0), target.origin);
	wait 1.2;
	PlayFX( level._effect["nx_explosion_skybridge"], target.origin );
	PhysicsExplosionSphere( target.origin, 20, 19, 0.5 );
	//physics push the statue
	//wait 0.95;
	wait 0.20;
	// wait 0.5;
	target = GetEnt("statue_explo02", "targetname");
	MagicBullet( "rpgx_straight", level.heli3.origin+ (0, fire_offset, 0), target.origin);
	//wait 1.25;
	wait 0.65;
	PhysicsExplosionSphere( target.origin, 20, 19, 0.5 );
	PlayFX( level._effect["nx_explosion_skybridge"], target.origin );

	// Shoot at the player for a while
	//wait 0.1;
	//MagicBullet( "rpgx_straight", level.heli3.origin + (0, fire_offset, 0), level._player.origin + (0, 0, -1050));
	
	// shoot and make a damaging fire for the player to dodge
	facade_target = GetEnt("facade_target01", "targetname");
	facade_target_debris = GetEnt( "facade_target01_debris", "script_noteworthy" );
	thread heli_target_missile_with_fire( level.heli3, facade_target, 1.2, -100, facade_target_debris );
	
	//physics push the 2nd statue
	/* wait 0.5;
	target = GetEnt("statue_explo03", "targetname");
	MagicBullet( "rpgx_straight", level.heli4.origin+ (0, fire_offset, 0), target.origin);
	wait 1.25;
	PlayFX( level._effect["explosion_type_1"], target.origin );
	PhysicsExplosionSphere( target.origin, 20, 19, 0.5 ); */

	flag_wait( "flag_rappel_big_explosion" );
	// fire missiles for the big explosion
	targets = GetEntArray( "big_explo_target", "script_noteworthy" );
	foreach ( target in targets )
		{
			MagicBullet( "rpgx_straight", level.heli4.origin + (0, fire_offset, 0), target.origin);
			wait 0.25;
		}
	// Kick the objects
	items = GetEntArray("origin_floorexplode5", "targetname");
	foreach( item in items )
	{
		playFX( level._effect[ "nx_explosion_skybridge" ], item.origin );

		//playFX( level._effect[ "firelp_large_pm_bh1" ], item.origin + (0, -175, 0));
		playFX( level._effect[ "nx_smoke_n_fire_plume_preseed" ], item.origin + (0, -175, 0));

		PhysicsExplosionSphere( item.origin, 256, 256, 2 );			
	} 
	// Delete the building pieces
	pieces = GetEntArray( "building_pieces", "targetname" );
	foreach( piece in pieces )
	{
		piece Delete();
	}
	//
	level thread rappel_slowmo();
	// after the slomo sequence blow up the chopper
	//damage_target = GetEnt( "chopper_kill_spot", "targetname" );
	//radiusdamage( damage_target.origin, 500, 5000, 5000 );
	level.heli4 kill();	
	// Spawn the final heli
	flag_wait( "flag_spawn_heli5" );
	level.heli5 = spawn_vehicle_from_targetname_and_drive( "placement_heli5" );
	level.heli5 Vehicle_SetSpeed( 30 );
	level.heli5 godon();
	level.heli5 SetLookAtEnt( level._player );
	wait 0.1;
	// Shoot at the bridge and kick it
	explosion_base = GetEnt("bridge_explo_base01", "targetname");
	explosion_base2 = GetEnt("bridge_explo_base02", "targetname");
	explosion_base0 = GetEnt( "bridge_explo_base00", "targetname" );
	//MagicBullet( "rpgx_straight", level.heli5.origin + (0, fire_offset, 0), explosion_base.origin);
	thread heli_target_missile_with_fire( level.heli5, explosion_base0, 1.25, -100 );
	wait 1.0;
	PhysicsExplosionSphere( explosion_base.origin, 2000, 1999, 1 );
	PhysicsExplosionSphere( explosion_base2.origin, 2000, 1999, 1 );

	PlayFX( level._effect["nx_explosion_skybridge"], explosion_base.origin );
	wait 0.25;
	PlayFX( level._effect["nx_explosion_skybridge"], explosion_base2.origin );

	// Shoot at the player some more
	for (i=0; i < 2; i++)
		{
		wait 1.5;
		side_offset = RandomIntRange(-50, 50);
		MagicBullet( "rpgx_straight", level.heli5.origin + (0, fire_offset, 0), level._player.origin + (side_offset, 0, -1200));
		}
	// rapid fire rockets to get the player to swing
	end_target = GetEnt("end_target01", "targetname");
	thread heli_target_missile_with_fire( level.heli5, end_target, 1.0, -100 );
	wait 0.75;
	MagicBullet( "rpgx_straight", level.heli5.origin+ (0, fire_offset, 0), (64, -2608, 4176));
	wait 0.75;
	MagicBullet( "rpgx_straight", level.heli5.origin+ (0, fire_offset, 0), (-128, -2624, 4064));
	wait 0.75;
	//MagicBullet( "rpgx_straight", level.heli5.origin+ (0, fire_offset, 0), (-288, -2608, 3936));

	//wait 0.75;
	MagicBullet( "rpgx_straight", level.heli5.origin+ (0, fire_offset, 0), (-480, -2592, 3824));
	wait 0.75;
}

heli_target_missile(heli, target, delay, fire_offset2 )
{
	fire_offset = 150;
	MagicBullet( "rpgx_straight", heli.origin + (0, fire_offset, fire_offset2), target.origin);
	wait( delay );
	//PlayFX( level._effect["explosion_type_1"], target.origin );
	PlayFX( level._effect["nx_explosion_skybridge"], target.origin );
}

heli_target_missile_with_fire(heli, target, delay, fire_offset2, debris)
{
	fire_offset = 150;
	MagicBullet( "rpgx_straight", heli.origin + (0, fire_offset, fire_offset2), target.origin);
	wait( delay );
	//PlayFX( level._effect["explosion_type_1"], target.origin );
	PlayFX( level._effect["nx_explosion_skybridge"], target.origin );
	wait 0.2;
	PlayFX( level._effect["nx_smoke_n_fire_plume_preseed"], target.origin );
	if( IsDefined( debris ))
	{
		debris show();
	}
}

spawn_and_kill_wreckage_chopper()
{

	wreckage_chopper = spawn_vehicle_from_targetname_and_drive( "wreckage_chopper" );
	wreckage_chopper Vehicle_SetSpeed( 5 );
	wreckage_chopper godon();
	wreckage_chopper SetLookAtEnt( level._player );
	wait 0.1;
	wreckage_chopper kill();

}

// Dan - Dyn_model entities do not live server side, so this is not going to work.  Commenting out so no one copies it.
//physobj_volume_control()
//{
//	volume = GetEnt( "physobj_kill_volume", "targetname" );
//	while(1)
//	{
//		physobs = GetEntArray( "dyn_model", "classname");
//		foreach( physob in physobs )
//		{
//			if( physob IsTouching( volume ))
//				physob Delete();
//		}
//		wait 1.0;
//	}
//}

rappel_slowmo()
{
	// Don't slomo sounds
	SoundSetTimeScaleFactor( "Mission", 0 );
	SoundSetTimeScaleFactor( "Shellshock", 0 );
	SoundSetTimeScaleFactor( "Voice", 0 );
	SoundSetTimeScaleFactor( "Menu", 0 );
	SoundSetTimeScaleFactor( "Effects1", 0 );
	SoundSetTimeScaleFactor( "Effects2", 0 );
	SoundSetTimeScaleFactor( "Announcer", 0 );
	SoundSetTimeScaleFactor( "Music", 0 );
	SoundSetTimeScaleFactor( "vignette3d", 0 );
	SoundSetTimeScaleFactor( "vignette2d", 0 );
	SoundSetTimeScaleFactor( "ambient", 0 );
	SoundSetTimeScaleFactor( "weapon", 0 );
	SoundSetTimeScaleFactor( "weapon2d", 0 );
	SoundSetTimeScaleFactor( "auto2d", 0 );
	SoundSetTimeScaleFactor( "auto", 0 );
	SoundSetTimeScaleFactor( "element", 0 );
	
	// Start slo motion
	slowmo_speed = 0.20;
	slowmo_setspeed_slow( slowmo_speed );
	slowmo_setlerptime_in( 2.0 );
	slowmo_lerp_in();
	
	level._player SetMoveSpeedScale( 0.1 );

	// Wait slo mo duration
	real_time = 2.0;
	wait real_time;
	
	// Stop slo motion
	slowmo_setlerptime_out( 0.65 );
	slowmo_lerp_out();
	slowmo_end();
	level notify( "notify_slomo_end" );

}

rappel_slide_slowmo()
{
	flag_wait("flag_swing_slide");
	wait 8.0;
	// Don't slomo sounds
	SoundSetTimeScaleFactor( "Mission", 0 );
	SoundSetTimeScaleFactor( "Shellshock", 0 );
	SoundSetTimeScaleFactor( "Voice", 0 );
	SoundSetTimeScaleFactor( "Menu", 0 );
	SoundSetTimeScaleFactor( "Effects1", 0 );
	SoundSetTimeScaleFactor( "Effects2", 0 );
	SoundSetTimeScaleFactor( "Announcer", 0 );
	SoundSetTimeScaleFactor( "Music", 0 );
	SoundSetTimeScaleFactor( "vignette3d", 0 );
	SoundSetTimeScaleFactor( "vignette2d", 0 );
	SoundSetTimeScaleFactor( "ambient", 0 );
	SoundSetTimeScaleFactor( "weapon", 0 );
	SoundSetTimeScaleFactor( "weapon2d", 0 );
	SoundSetTimeScaleFactor( "auto2d", 0 );
	SoundSetTimeScaleFactor( "auto", 0 );
	SoundSetTimeScaleFactor( "element", 0 );
	
	// Start slo motion
	slowmo_speed = 0.20;
	slowmo_setspeed_slow( slowmo_speed );
	slowmo_setlerptime_in( 2.0 );
	slowmo_lerp_in();
	
	level._player SetMoveSpeedScale( 0.1 );
	 
	// Wait slo mo duration
	real_time = 4.0;
	wait real_time;
	
	// Stop slo motion
	slowmo_setlerptime_out( 0.65 );
	slowmo_lerp_out();
	slowmo_end();
}

washerbot_control()
{
	washerbot = GetEnt( "washerbot_mover", "targetname" );
	botlight = GetEnt( "washerbot_light", "targetname" );
	botlight.origin = ( botlight.origin[0] + 12, botlight.origin[1] + 6, botlight.origin[2] + 6);
	botlight linkto( washerbot );
	washerbot thread washerbot_move( 500, 0, 5 );
	wait 5.0;
	washerbot2 = GetEnt( "washerbot_mover2", "targetname" );
	botlight2 = GetEnt( "washerbot_light2", "targetname" );
	botlight2.origin = ( botlight2.origin[0] + 12, botlight2.origin[1] + 6, botlight2.origin[2] + 6);
	botlight2 linkto( washerbot2 );
	washerbot2 thread washerbot_move( 0, -5000, 50 );
}

washerbot_move(horiz, vert, time )
{
	//time = 5;
	while(1)
	{
		self MoveTo( self.origin + (horiz, 0, vert), time, 1, 1);
		wait time;
		self MoveTo( self.origin - (horiz, 0, vert), time, 1, 1);
		wait time;
	}
}

debris_control()
{
	pieces = GetEntArray( "debris_models", "targetname" );
	foreach( piece in pieces)
	{
		piece hide();
	} 
}

falling_landing_pad()
{
	//explo_base = GetEnt( "landing_pad_explo_base", "targetname" );
	landingpad = GetEnt( "falling_landing_pad", "targetname" );
	landingpad hide();
	chopper_wreckage = GetEnt( "chopper_wreckage", "targetname" );
	chopper_wreckage hide();
	pieces = GetEntArray( "falling_wreckage", "targetname" );
	foreach( piece in pieces)
		{
			piece hide();
		}
	flag_wait( "flag_rappel_big_explosion" );
	//wait 2.0;
	// add a huge wait to comment out the landing pad fall
	// wait 200;
	landingpad show();
	chopper_wreckage show();
	//PhysicsExplosionSphere( explo_base.origin, 2000, 1999, 1);
	landingpad MoveTo( landingpad.origin - ( 0, 0, 20000), 4.5, 0.5, 0.5);
	landingpad rotateRoll( 10000, 30, 5, 5); 

	chopper_wreckage MoveTo( chopper_wreckage.origin - ( 0, 0, 20000), 5.0, 0.5, 0.5);
	chopper_wreckage rotateRoll( 10000, 40, 5, 5); 

	foreach( piece in pieces)
		{
			piece show();
			piece MoveTo( piece.origin - ( 0, 0, 20000), 5.5, 0.5, 0.5);
			piece rotateRoll( 40000, 40, 5, 5); 

		}

	// wait and then play the fire FX when the heli hits it
	wait 1.35;
	target = GetEnt( "wreckage_fx", "targetname" );
	PlayFX( level._effect["nx_explosion_skybridge"], target.origin );
	wait 0.25;
	PlayFX( level._effect["nx_smoke_n_fire_plume_preseed"], target.origin );

}


//*******************************************************************
//  Laser targeted Laser!                                           *
//                                                                  *
//*******************************************************************

rappel_laser_start()
{
	// Prepare for sat view pip
	thread maps\nx_skyscraper_util::play_pip_bink( "skyscraper_view_pip2", undefined, "play_orbital_pip_2" );

	flag_wait("flag_swing_slide");
	// Play sat view pip
	flag_set ("play_orbital_pip_2");

	wait 9;

	SetSavedDvar( "compass", 1 );
 	SetSavedDvar( "ammoCounterHide", 0 );
 	SetSavedDvar( "actionSlotsHide", 0 );
 	SetSavedDvar( "hud_showStance", 1 );
 	SetSavedDvar( "hud_drawhud", 1 );

	//level waittill( "notify_start_laser" );

	level._player FreezeControls( false );
	level._player EnableWeapons();	

	// When the player presses the fire button, send this notify
	level._player notifyOnPlayerCommand( "fired_laser", "+attack" );
	//thread check_for_laser_targeting_device();
	thread force_laser_targeting_device();
	thread laser_targeting_device_logic();
	thread satellite_orbit();
	level waittill( "laser_off" );
	//level._player LaserForceOff();
	//level._player notify ("laser_off");

	level._player FreezeControls( true );
	level._player DisableWeapons();

}

force_laser_targeting_device()
{
	// Give the player the "laser designator"	
	level._player GiveWeapon( "m9" );
	level.player_weapon = level._player GetCurrentWeapon();

	// Force the player to use the designator
	level._player SwitchToWeapon( "m9" );
	level._player DisableWeaponSwitch();
	level._player DisableOffhandWeapons();
	//level.lab_vtol godoff();

	//level.lab_vtol waittill ("death");

	// Back to the regular weapons
	//level._player EnableOffhandWeapons();
	//level._player EnableWeaponSwitch();
	//level._player SwitchToWeapon( "lancer_xray" );
	//level._player allowFire( true );
}

laser_targeting_device_logic()
{
	level endon ("floor_collapsed");
	level._player allowFire( false );
	while ( 1 )
	{
		level._player waittill ( "fired_laser");
		thread laser_code_pattern();
		thread lock_on_meter();
		level._player laser_designate_target();
		//level._player LaserForceOn();
		// level notify ("laser_off");
		level._player LaserForceOff();
	}
}

laser_code_pattern()
{
	delay = 0.05;
	level endon ("laser_off");
	level endon ("floor_collapsed");
	while ( 1 )
	{
		level._player LaserForceOn();
		wait (delay + RandomFloat (0.2));
		level._player LaserForceOff();
		wait delay;
	}
}

laser_designate_target()
{
	lock_on_complete = 0.25;
	lock_on_timer = 0;
	level endon( "laser_off" );
	level endon ( "floor_collapsed" );

	trace = self get_laser_designated_trace();
	prior_entity = trace[ "entity" ];

	// While the player is holding the trigger
	while( level._player AttackButtonPressed() )
	{
		// Trace to the thing they're pointing at
		trace = self get_laser_designated_trace();
		position = trace[ "position" ];
		entity = trace[ "entity" ];

		// If an entity was hit, and an entity was hit last time a check was done
		if ( isdefined ( prior_entity ) && isdefined ( entity ) )
		{
			// and the target is a vehicle
			if ( entity.code_classname == "script_vehicle")
			{
				// and the currently targeted entity is the same one as the previously targeted one
				if ( prior_entity == entity )
				{
					// set the currently targeted entity as the entity to check against next time
					prior_entity = entity;
					level notify ( "lock_on_start" );
	
					// increment the lock-on timer
					lock_on_timer = (lock_on_timer + .05);
	
					// If the timer has exceeded the required amount before a lock is complete
					if ( lock_on_timer >= lock_on_complete)
					{
						iprintlnbold( "LASER COORDINATES RECEIVED" );
						thread draw_orbital_laser( entity );
						level notify( "laser_coordinates_received" );
						break;							
					}
					// iprintln ("lock-on: " + lock_on_timer);
				}
				// Had a target, but lost it.
				else
				{
					// iprintln ("lock-on dropped");
					level notify ("lock_on_dropped");
					// reset the timer
					lock_on_timer = 0;
				}
			}
			// Wait a bit and run another check
			wait .05;
		}
		// Have no target at all
		else
		{
			// iprintln ("no target");
			level notify ("lock_on_dropped");
			// reset the timer
			lock_on_timer = 0;
			wait .05;
			// Check for a new target to check against next time a check is done
			trace = self get_laser_designated_trace();
			prior_entity = trace[ "entity" ];
		}
	}
	
	// The player stopped holding the trigger
	level notify( "laser_off" );
}

lock_on_meter()
{	
	// Begin when a lock is acquired
	level waittill ( "lock_on_start" );

	lock_on_complete = 0.25;

	// Create and display the frame for the meter
	lock_on_frame = NewHudElem(  );
	lock_on_frame.alignX = "center";
	lock_on_frame.alignY = "bottom";
	lock_on_frame.horzAlign = "center";
	lock_on_frame.vertAlign = "bottom";
	lock_on_frame.x = 25;
	lock_on_frame.y = -120;
	lock_on_frame setShader( "hud_temperature_gauge", 35, 150 );
	lock_on_frame.sort = 4;

	// Create and display the frame for the fill
	lock_on_fill = NewHudElem(  );
	lock_on_fill.alignX = "center";
	lock_on_fill.alignY = "bottom";
	lock_on_fill.horzAlign = "center";
	lock_on_fill.vertAlign = "bottom";
	lock_on_fill.x = 25;
	lock_on_fill.y = -152;
	lock_on_fill setShader( "white", 10, 1 );
	lock_on_fill.color = ( 1, .9, 0 );
	lock_on_fill.alpha = 1;
	lock_on_fill.sort = 1;

	// Scale the fill element over the 
	lock_on_fill scaleOverTime(  lock_on_complete , 10, 120 );

	// If the lock is lost, dropped, or complete, get rid of the hud elements
	level waittill_any  ("laser_coordinates_received", "laser_off");
	lock_on_frame destroy();
	lock_on_fill destroy();

	thread lock_on_meter();
	
}

get_laser_designated_trace()
{
	eye = self geteye();
	angles = self getplayerangles();
	
	forward = anglestoforward( angles );
	end = eye + vector_multiply( forward, 3000 );
	trace = bullettrace( eye, end, true, self );

	if ( trace ["fraction"] >= 1 )
	{
		trace[ "position" ] = undefined;
	}
	
	entity = trace[ "entity" ];
	if ( isdefined( entity ) )
	{

		if ( isdefined( entity.targetname ) && entity.targetname == "fake_uav")
		{
			entity = GetEnt ("real_uav", "targetname");
		}
		trace[ "position" ] = entity.origin;
	}

	return trace;
}

draw_orbital_laser( target )
{
	level waittill ( "laser_coordinates_received" );
	wait 1;

	satellite = GetEnt ("fake_satellite", "targetname");
	time = 3;

	//trace = level._player get_laser_designated_trace();

	//if ( isdefined( trace[ "position" ]) )

	//{
		//target = trace[ "position" ];
		// normal = trace[ "normal" ];

		xoffset = Randomfloat ( 1 );
		yoffset = Randomfloat ( 1 );

		direction = (satellite.origin - target.origin);
		normalized_direction = VectorNormalize( direction );

		// thread draw_line_for_time( satellite.origin, (target + (xoffset,yoffset,0 )) , 1, 0, 0, 0.05 );
		// time -= 0.05;
		//PlayFX ( level._effect[ "orbital_laser" ], (target.origin + (xoffset,yoffset, 0)), normalized_direction );
		PlayFX ( level._effect[ "nx_laser_orbital_strike" ], (target.origin + (xoffset,yoffset, 0)), normalized_direction );
		// PlayFX( level._effect[ "laser_impact" ], (target + (xoffset,yoffset, 0)), normal );
		RadiusDamage( target.origin, 100, 1000, 1000, level._player );
	//}

}


satellite_orbit()
{
	level endon ("floor_collapsed");
	satellite = GetEnt ("fake_satellite", "targetname");
	starting_point = satellite.origin;

	while ( 1 )
	{
		satellite MoveTo ( satellite.origin + (6000, 24064,0), 24);
		satellite waittill ("movedone");
		satellite.origin = starting_point;
	}	

}


/* Unused?
//*******************************************************************
// LOBBY CRASH                                                      *
//                                                                  *
//*******************************************************************

lobby_crash_start()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_lobby_crash" );

	thread maps\_utility::set_ambient( "amb_skyscraper_windy_ext" );

	thread maps\nx_skyscraper_fx::set_vision_and_fog("exterior_ground_level", 0); // set appropriate vision and fog
	
	lobby_crash_sequence();
}

lobby_crash()
{

}

lobby_crash_sequence()
{
	//thread maps\_utility::set_ambient( "amb_skyscraper_lobby_int" );

}
*/
