
//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_ROCKET_SECTION_ESCAPE										**
//                                                                          **
//    Created: 7/13/2011 - Justin Rote										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


//*******************************************************************
//                                                                  *
//	GANTRY ESCAPE - Placing the c4 to mission end					*
//                                                                  *
//*******************************************************************
start()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_gantry_escape" );

	teleport_info = [];
	teleport_info[ "ALLY_BAKER" ] = "gantry_baker_escape_start_node";
	maps\nx_rocket_util::squad_teleport( teleport_info );

	flag_set( "flag_at_gantry_jump_down" );
	thread maps\nx_rocket_section_gantry::final_gantry_objective_logic();

	// Hide the final gantry animated swing arm
	swing_arm_bits = GetEntArray( "final_gantry_arm_extended", "targetname" );
	foreach( bit in swing_arm_bits )
	{
		bit hide();
	}
}

main()
{
	thread maps\_utility::set_ambient( "nx_rocket_ext" );

	// Wait for player to jump down
	flag_wait( "flag_gantry_player_jumped_down" );
	
	// Get Baker down here
	teleport_info = [];
	teleport_info[ "ALLY_BAKER" ] = "gantry_baker_teleport_node";
	maps\nx_rocket_util::squad_teleport( teleport_info );
	wait 0.1;
	issue_color_orders( "g410", "allies" );

	// Spawn the outro chopper fly-in
	thread outro_chopper_flyin();

	c4_target = GetEnt( "c4_plant", "targetname" );
	c4_target.multiple_c4 = true;
	c4_charge = c4_target maps\_c4::c4_location( undefined, undefined, undefined, c4_target.origin );

	level._player.old_weapon = undefined;

	// Wait for c4 to be placed
	level waittill( "gantry_attack_c4_placed" );

	// Hide C4
	c4_charge delete();

	// Wait for gantry arm anim to finish
	flag_wait( "gantry_arm_anim_done" );

	// Move baker to new spot
	teleport_info = [];
	teleport_info[ "ALLY_BAKER" ] = "gantry_baker_teleport_node_2";
	maps\nx_rocket_util::squad_teleport( teleport_info );
	wait 0.1;
	issue_color_orders( "g411", "allies" );

	// Wait for player to hop into exit chopper
	trigger_wait("outro_ride_start", "targetname");	

	// Move Baker somewhere far away
	teleport_info = [];
	teleport_info[ "ALLY_BAKER" ] = "gantry_baker_final_node";
	maps\nx_rocket_util::squad_teleport( teleport_info );

	level._player ShowViewModel();
	level._player EnableWeapons();

	// Take away all weapons
	level._player TakeWeapon( level._gunPrimary );
	level._player TakeWeapon( level._gunSidearm );
	level._player TakeWeapon( "c4" );

	// Remove the fly-in chopper
	level.playerHeli delete();

	spawn_and_ride_outro_chopper();

	wait 4.0;

	// Watches for C4 explosion on the rocket
	// JR - Turning this off untill I do my second pass at it
	//thread rocket_damage_watcher();

	// Enable c4 so player can pop the rocket
	level._player giveWeapon( "c4" );
	level._player switchToWeapon( "c4" );
	level._player.old_weapon = undefined;

	level._player waittill( "detonate" );
	
	flag_set( "final_rocket_destroyed" );
	
	// Trigger the explosion
	exploder("rocketexplode_01");


	// Wait for end of path
	level.playerHeli waittill( "reached_dynamic_path_end" );

	nextmission();
}

// Spawns the escape chopper and flies it into position
// This should occur during the c4 placement / fall down vignette
outro_chopper_flyin()
{
	flag_wait( "vignette_rocket_gantry_escape_flag" );	

	level._player HideViewModel();
	level._player DisableWeapons();

	//temp music_chk flag
	flag_set( "music_chk_escape" );

	wait 6;

	//iprintln( "spawn chopper fly in" );

	level.playerHeli = spawn_vehicle_from_targetname_and_drive( "heli_outro_player_in" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
section_precache()
{
	precachemodel( "fastrope_arms" );
	precachemodel( "weapon_c4_obj" );
	precacheturret( "player_view_controller" );
	PreCacheitem( "c4" );
}


section_flag_inits()
{
	flag_init( "final_rocket_destroyed" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Jump onto the escape chopper
spawn_and_ride_outro_chopper()
{
	// looker guy rides next to you, he looks around
	looker_guy_outro = GetEnt( "looker_guy_outro", "script_noteworthy" );
	//looker_guy animscripts\combat_utility::startFireAndAimIdleThread();

	level._player.IgnoreRandomBulletDamage = true;
	player_cant_be_shot();
	level.playerHeli = spawn_vehicle_from_targetname_and_drive( "heli_outro_player" );
	level.playerHeli SetMaxPitchRoll( 10, 10 );

   	level._player AllowProne( false );
   	level._player AllowCrouch( false );
   	level._player AllowSprint( false );
   	level._player AllowJump( false );

	level.playerHeli thread godon();

	player_view_controller = get_player_view_controller( level.playerHeli, "tag_guy6", ( 0, 0, 0 ) );

	tag_origin = spawn_tag_origin();
	tag_origin LinkTo( level.playerHeli, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	level.ground_ref = tag_origin;

	level._player PlayerSetGroundReferenceEnt( tag_origin );

	level.player_view_controller = player_view_controller;

	wait( 0.1 );

	// JR - This is pissing me off hardcore
	level._player PlayerLinkToDelta( player_view_controller, "TAG_ORIGIN", 1, 180, 180, 20, 45, true );
	//angles = ( 0, 180, 0 );
	//level._player setPlayerAngles( angles );
}

// Checks for the C4 explosion on the final rocket
rocket_damage_watcher()
{
	rocket_exploder = GetEnt( "rocket_shootme", "targetname" );
	
	rocket_exploder setCanDamage( true );
	rocket_exploder SetCanRadiusDamage( true );

	while( true )
	{
		rocket_exploder waittill( "damage", damage, attacker, direction_vec, point, damageType, modelName, tagName );

		//if( damage > 100 )
		//{
		//	Exploder( self.script_parameters );
		//}

		wait 1.0;
	}
}
