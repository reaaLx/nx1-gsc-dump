/*QUAKED script_vehicle_nx_blackhawk_minigun_hero (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

maps\_nx_blackhawk_minigun::main( "nx_vehicle_blackhawk_minigun_hero" );

include,nx_vehicle_blackhawk
sound,vehicle_blackhawk,vehicle_standard,all_sp

defaultmdl="nx_vehicle_blackhawk_minigun_hero"
default:"vehicletype" "nx_blackhawk_minigun"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_nx_blackhawk_minigun_ai_turret (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

maps\_nx_blackhawk_minigun::main( "nx_vehicle_blackhawk_minigun_hero","nx_blackhawk_minigun_ai_turret" );

include,nx_vehicle_blackhawk_turret
sound,vehicle_blackhawk,vehicle_standard,all_sp

defaultmdl="nx_vehicle_blackhawk_minigun_hero"
default:"vehicletype" "nx_blackhawk_minigun_ai_turret"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_nx_blackhawk_player (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

maps\_nx_blackhawk_minigun::main( "nx_vehicle_blackhawk_minigun_hero", "nx_blackhawk_player" );

include,nx_vehicle_blackhawk_turret
sound,vehicle_blackhawk,vehicle_standard,all_sp

defaultmdl="nx_vehicle_blackhawk_minigun_hero"
default:"vehicletype" "nx_blackhawk_player"
default:"script_team" "allies"
*/

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#include common_scripts\utility;
#include maps\_utility;
#include maps\_vehicle;
#include maps\_vehicle_aianim;
#include maps\_anim;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "vehicles" );
main( model, type, no_death )
{
	build_template( "nx_blackhawk_minigun", model, type );

	build_localinit( ::init_local );

	build_drive( %nx_vh_blackhawk_us_movement, undefined, 0 );

	if ( !isdefined( no_death ) )
	{
		blackhawk_death_fx = [];
		blackhawk_death_fx[ "nx_vehicle_blackhawk_minigun_hero" ] 					 = "explosions/helicopter_explosion";

		build_deathfx( "explosions/helicopter_explosion_secondary_small", 		"tag_engine_left", 		"blackhawk_helicopter_hit", 			undefined, 			undefined, 		undefined, 		0.2, 		true );
		build_deathfx( "explosions/helicopter_explosion_secondary_small", 		"elevator_jnt", 		"blackhawk_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		0.5, 		true );
		build_deathfx( "fire/fire_smoke_trail_L", 								"elevator_jnt", 		"blackhawk_helicopter_dying_loop", 		true, 				0.05, 			true, 			0.5, 		true );
		build_deathfx( "explosions/helicopter_explosion_secondary_small", 		"tag_engine_right", 	"blackhawk_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		2.5, 		true );
		build_deathfx( "explosions/helicopter_explosion_secondary_small", 		"tag_deathfx", 			"blackhawk_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		4.0 );
		build_deathfx( blackhawk_death_fx[ model ], 								undefined, 			"blackhawk_helicopter_crash", 			undefined, 			undefined, 		undefined, 		 - 1, 		undefined, 	"stop_crash_loop_sound" );

		build_rocket_deathfx( "explosions/aerial_explosion_heli_large", 	"tag_deathfx", 	"blackhawk_helicopter_crash",undefined, 			undefined, 		undefined, 		 undefined, true, 	undefined, 0  );
	}

	build_treadfx();
	build_wash();
	
	build_spawn_callback( ::setup_vehicle );

	build_life( 999, 500, 1500 );

	build_team( "allies" );

	build_aianims( ::setanims, ::set_vehicle_anims );

	build_attach_models( ::set_attached_models );

	build_unload_groups( ::Unload_Groups );
	build_compassicon( "helicopter", false );

	if ( IsDefined( type ) && type == "nx_blackhawk_player" )
	{
		build_turret( "nx_turret_blackhawk", "tag_ai_turret_mount_r", "weapon_blackhawk_minigun_turret", undefined, undefined, 0.2, 20, -14 );
		build_turret_fx();
	}

	if ( IsDefined( type ) && type == "nx_blackhawk_minigun_ai_turret" )
	{
		build_turret( "nx_turret_blackhawk_ai", "tag_ai_turret_mount_r", "weapon_blackhawk_minigun_turret", undefined, "auto_ai", 10, 20, -14 );
		build_turret( "nx_turret_blackhawk_ai", "tag_ai_turret_mount_l", "weapon_blackhawk_minigun_turret", undefined, "auto_ai", 10, 20, -14 );
		build_turret_fx();
	}
	

	randomStartDelay = randomfloatrange( 0, 1 );
	build_light( model, "cockpit_blue_cargo01", 	"tag_light_cargo01", 	"misc/aircraft_light_cockpit_red", 		"interior", 	0.0 );
	build_light( model, "cockpit_blue_cockpit01", 	"tag_light_cockpit01", 	"misc/aircraft_light_cockpit_blue", 	"interior", 	0.0 );
	build_light( model, "white_blink", 				"tag_light_belly", 		"misc/aircraft_light_white_blink", 		"running", 	randomStartDelay );
	build_light( model, "white_blink_tail", 		"tag_light_tail", 		"misc/aircraft_light_white_blink", 		"running", 	randomStartDelay );
	build_light( model, "wingtip_green", 			"tag_light_L_wing", 	"misc/aircraft_light_wingtip_green", 	"running", 	randomStartDelay );
	build_light( model, "wingtip_red", 				"tag_light_R_wing", 	"misc/aircraft_light_wingtip_red", 		"running", 	randomStartDelay );


	SetDvar( "bh_numbulletsbetweentracers", 0 );
	SetDvar( "bh_numtracersinburst", 1 );
}

init_local()
{
	self.originheightoffset = distance( self gettagorigin( "tag_origin" ), self gettagorigin( "tag_ground" ) );// TODO - FIXME: this is ugly. Derive from distance between tag_origin and tag_base or whatever that tag was.
	//self.originheightoffset = 256;
	self.fastropeoffset = 762;// TODO - FIXME: this is ugly. If only there were a getanimendorigin() command

	self.script_badplace = false;// All helicopters dont need to create bad places
	maps\_vehicle::lights_on( "running" );
	maps\_vehicle::lights_on( "interior" ); 

	self.troops_go_down_with_vehicle = true;
}

#using_animtree( "vehicles" );
set_vehicle_anims( positions )
{

	for ( i = 0; i < positions.size; i++ )
		positions[ i ].vehicle_getoutanim = %nx_vh_blackhawk_us_movement;

	return positions;
}


#using_animtree( "generic_human" );

setanims()
{
	positions = [];
	for ( i = 0;i < 10;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].idle = %nx_tp_blackhawk_us_pilot_idle;
	positions[ 1 ].idle = %nx_tp_blackhawk_us_copilot_idle;

	positions[ 2 ].idle = %nx_tp_blackhawk_us_guy0_idle;
	positions[ 3 ].idle = %nx_tp_blackhawk_us_guy1_idle;
	positions[ 4 ].idle = %nx_tp_blackhawk_us_guy2_idle;
	positions[ 5 ].idle = %nx_tp_blackhawk_us_guy3_idle;
	positions[ 6 ].idle = %nx_tp_blackhawk_us_guy4_idle;
	positions[ 7 ].idle = %nx_tp_blackhawk_us_guy5_idle;

	positions[ 0 ].sittag = "TAG_driver";
	positions[ 1 ].sittag = "TAG_passenger";
	positions[ 2 ].sittag = "TAG_GUY0";
	positions[ 3 ].sittag = "TAG_GUY1";
	positions[ 4 ].sittag = "TAG_GUY2";
	positions[ 5 ].sittag = "TAG_GUY3";
	positions[ 6 ].sittag = "TAG_GUY4";
	positions[ 7 ].sittag = "TAG_GUY5";
	positions[ 8 ].sittag = "TAG_GUY6";
	positions[ 9 ].sittag = "TAG_GUY7";


	// 1, 2, 4, 5, 8,  6
	positions[ 2 ].getout = %bh_1_drop;
	positions[ 3 ].getout = %bh_2_drop;
	positions[ 4 ].getout = %bh_4_drop;
	positions[ 5 ].getout = %bh_5_drop;
	positions[ 6 ].getout = %bh_8_drop;
	positions[ 7 ].getout = %bh_6_drop;

	positions[ 2 ].getoutstance = "crouch";
	positions[ 3 ].getoutstance = "crouch";
	positions[ 4 ].getoutstance = "crouch";
	positions[ 5 ].getoutstance = "crouch";
	positions[ 6 ].getoutstance = "crouch";
	positions[ 7 ].getoutstance = "crouch";


	positions[ 2 ].ragdoll_getout_death = true;
	positions[ 3 ].ragdoll_getout_death = true;
	positions[ 4 ].ragdoll_getout_death = true;
	positions[ 5 ].ragdoll_getout_death = true;
	positions[ 6 ].ragdoll_getout_death = true;
	positions[ 7 ].ragdoll_getout_death = true;

	positions[ 2 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 3 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 4 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 5 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 6 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 7 ].ragdoll_fall_anim = %fastrope_fall;

	positions[ 1 ].rappel_kill_achievement = 1;
	positions[ 2 ].rappel_kill_achievement = 1;
	positions[ 3 ].rappel_kill_achievement = 1;
	positions[ 4 ].rappel_kill_achievement = 1;
	positions[ 5 ].rappel_kill_achievement = 1;
	positions[ 6 ].rappel_kill_achievement = 1;
	positions[ 7 ].rappel_kill_achievement = 1;

	positions[ 2 ].getoutloopsnd = "fastrope_loop_npc";
	positions[ 3 ].getoutloopsnd = "fastrope_loop_npc";
	positions[ 4 ].getoutloopsnd = "fastrope_loop_npc";
	positions[ 5 ].getoutloopsnd = "fastrope_loop_npc";
	positions[ 6 ].getoutloopsnd = "fastrope_loop_npc";
	positions[ 7 ].getoutloopsnd = "fastrope_loop_npc";

	// 1, 2, 4, 5, 6, & 8
	positions[ 2 ].fastroperig = "TAG_FastRope_RI";// 1 %bh_1_drop
	positions[ 3 ].fastroperig = "TAG_FastRope_RI";	// 2 %bh_2_drop
	positions[ 4 ].fastroperig = "TAG_FastRope_LE";	// 4 %bh_4_drop
	positions[ 5 ].fastroperig = "TAG_FastRope_LE";	// 5 %bh_5_drop
	positions[ 6 ].fastroperig = "TAG_FastRope_RI";// 8 %bh_8_drop
	positions[ 7 ].fastroperig = "TAG_FastRope_LE";// 6 %bh_6_drop
	
	positions[ 8 ].mgturret = 0;// which of the turrets is this guy going to use
	positions[ 9 ].mgturret = 1;// which of the turrets is this guy going to use
	
	return positions;
	//return setplayer_anims( positions );
	//return set_coop_player_anims( positions );
}



//WIP.. posible to unload different sets of people wirh vehicle notify( "unload", set ); sets defined here.
unload_groups()
{
	unload_groups = [];
	unload_groups[ "left" ] = [];
	unload_groups[ "right" ] = [];
	unload_groups[ "both" ] = [];

	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 4;
	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 5;
	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 7;

	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 2;
	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 3;
	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 6;

	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 2;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 3;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 4;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 5;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 6;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 7;

	unload_groups[ "default" ] = unload_groups[ "both" ];

	return unload_groups;

}


set_attached_models()
{
	array = [];
	array[ "TAG_FastRope_LE" ] = spawnstruct();
	array[ "TAG_FastRope_LE" ].model = "rope_test";
	array[ "TAG_FastRope_LE" ].tag = "TAG_FastRope_LE";
	array[ "TAG_FastRope_LE" ].idleanim = %bh_rope_idle_le;
	array[ "TAG_FastRope_LE" ].dropanim = %bh_rope_drop_le;

	array[ "TAG_FastRope_RI" ] = spawnstruct();
	array[ "TAG_FastRope_RI" ].model = "rope_test_ri";
	array[ "TAG_FastRope_RI" ].tag = "TAG_FastRope_RI";
	array[ "TAG_FastRope_RI" ].idleanim = %bh_rope_idle_ri;
	array[ "TAG_FastRope_RI" ].dropanim = %bh_rope_drop_ri;

	strings = getarraykeys( array );

	for ( i = 0;i < strings.size;i++ )
	{
		precachemodel( array[ strings[ i ] ].model );
	}

	return array;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

build_turret_fx()
{
	level._effect[ "nx_turret_projectile_trail" ] 	= LoadFX( "nx/misc/nx_turret_projectile_trail" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_mount_blackhawk_gun( nolerp, player, hide_hud )
{
	if( !IsDefined( player ) )
	{
		player = level._player;
	}

	self.minigunUser = player;
	
	//self ==> the vehicle being used by the player
	if ( !isdefined( hide_hud ) )
		hide_hud = true;
	thread hud_hide( hide_hud );
   	player allowprone( false );
   	player allowcrouch( false );
    if ( !isdefined( nolerp ) )
    {
    	player disableWeapons();
    		//lerp_player_view_to_tag( player, tag, lerptime, fraction, right_arc, left_arc, top_arc, bottom_arc )
    	self lerp_player_view_to_tag( player, "tag_player", 1, 1, 30, 30, 30, 30 );

    }

	self useby( player );
	tagAngles = self gettagangles( "tag_player" );
	player setplayerangles( tagAngles + ( 0, 90, 0 ) );	
	flag_set( "player_on_minigun" );
	self thread maps\_minigun::minigun_think();
	//thread maps\_minigun::minigun_hints_on();
}

player_dismount_blackhawk_gun()
{
	//self ==> the vehicle being used by the player
	self useby( self.minigunUser );
	self.minigunUser unlink();
	level notify( "player_off_blackhawk_gun" );
	//level.player playerlinktodelta( self, "tag_player", 1, 50, 50, 30, 45 );
	//wait( .05 );
	//self turret_reset();
	//thread maps\_minigun::minigun_hints_off();
	//self lerp_player_view_to_tag( "tag_turret_exit", 1, 0.9, 25, 25, 45, 0 );
   // level.player unlink();
    //level.player enableWeapons();

	//level.player DisableInvulnerability();
   	//level.player allowprone( true );
   	//level.player allowcrouch( true );
	//flag_set( "player_off_minigun" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_mount_blackhawk_turret( nolerp, player, hide_hud )
{
	if( !IsDefined( player ) )
	{
		player = level._player;
	}

	self.minigunUser = player;
	
	//self ==> the vehicle being used by the player
	if ( !isdefined( hide_hud ) )
		hide_hud = true;
	thread hud_hide( hide_hud );
	player allowprone( false );
	player allowcrouch( false );
	if ( !isdefined( nolerp ) )
	{
		player disableWeapons();
		//lerp_player_view_to_tag( player, tag, lerptime, fraction, right_arc, left_arc, top_arc, bottom_arc )
		//self lerp_player_view_to_tag( player, "tag_player", 1, 1, 30, 30, 30, 30 );
		// tagMJS<TODO> there is an issue with linked players and a 180 degree range of motion along the yaw axis.
		// tagMJS<TODO> need to check into the predicted player state code
		player PlayerLinkTo( self, "tag_player", 0.25, 80, 85, 50, 55 );
	}

	// Give the player the turret.
	turret = self.mgturret[ 0 ];
	turret notify( "stop_burst_fire_unmanned" );
	turret SetModel( "weapon_blackhawk_minigun_turret" );
	turret MakeUsable();
	turret SetMode( "manual" );
	turret UseBy( level._player );
	turret MakeUnusable();
	level.player_turret = turret;
	player setplayerangles( ( 0, 180, 0 ) );
	player playerlinkedturretanglesenable();
	// Keep the player locked to the turret.
	level._player DisableTurretDismount();

	// Show special hand model for this turret.
	thread maps\_minigun_viewmodel::player_viewhands_minigun( turret );
	level.prev_turret_adsFOV = GetDvarFloat( "turret_adsFov" );
	setsaveddvar( "turret_adsFov", 25.0 );
	self thread blackhawk_turret_handle_tracers();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_dismount_blackhawk_turret()
{
	level._player EnableWeapons();
	level._player unlink();
	level.player_turret Delete();
	setsaveddvar( "turret_adsFov", level.prev_turret_adsFOV );
	level notify( "player_off_blackhawk_gun" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

hud_hide( state )
{
	wait 0.05;
	if ( state )
	{
		setsaveddvar( "ui_hidemap", 1 );
		SetSavedDvar( "hud_showStance", "0" );
		SetSavedDvar( "compass", "0" );
		SetDvar( "old_compass", "0" );
		SetSavedDvar( "ammoCounterHide", "1" );
	}
	else
	{
		setsaveddvar( "ui_hidemap", 0 );
		setSavedDvar( "hud_drawhud", "1" );
		SetSavedDvar( "hud_showStance", "1" );
		SetSavedDvar( "compass", "1" );
		SetDvar( "old_compass", "1" );
		SetSavedDvar( "ammoCounterHide", "0" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

blackhawk_turret_handle_tracers()
{
	// tagMJS<GOTCHA> may need to check that we specifically are dealling with nx_turret_blackhawk
	// there is extra logic here to add tracers to a projectile weapon

	//Only need this logic for vehicle mounted miniguns
	if ( !issubstr( self.classname, "script_vehicle" ) )
		return;

	self endon( "death" );
	level endon( "player_off_blackhawk_gun" );

	tracercount = 0;
	while( 1 )
	{
		level.player_turret waittill( "turretshoot" );
		// do tracer, since the weapon is a projectile
		tracercount = tracercount - 1;
		if ( tracercount <= 0 )
		{
			level.player_turret play_tracer_burst();
			tracercount = GetDvarInt( "bh_numbulletsbetweentracers" );
		}
		wait( 0.05 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

play_tracer_burst()
{
	self endon( "death" );
	//fire_time = WeaponFireTime( "nx_turret_blackhawk" );
	bust_size = GetDvarInt( "bh_numtracersinburst" );
	for( i = 0; i < bust_size; i++ )
	{
		if( level._player attackbuttonpressed() )
		{
			forward = anglestoforward( level._player getplayerangles() );
			org = self GetTagOrigin( "TAG_FLASH" ) + forward * 100;
			playfx( level._effect[ "nx_turret_projectile_trail" ], org, forward, ( 0, 0, 1 ) );
		}
		//wait( fire_time );
		wait( .05 );
	}
}

setup_vehicle( vehicle )
{
	vehicle._wash_fx = true;
	vehicle play_stealth_heli_sfx( vehicle );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
// tagMJS<NOTE> apparently IW is not using this at the moment...
hindgun_shells( end_on )
{
	self endon( "death" );
	level endon( end_on );
	level endon( "player_off_hindgun" );
	
	fx = getfx( "minigun_shell_eject" );
	tag = "tag_brass";
	timebtnshots = 0.1;

	while ( 1 )
	{
		while ( level.player AttackButtonPressed() )
		{
			PlayFXOnTag( fx, self, tag );
			wait( timebtnshots );	// tune this to match the fire rate of the weapon
		}

		wait( 0.05 );
	}
}
*/

//level.player PlayerLinkedTurretAnglesEnable();
