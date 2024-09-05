#include maps\_anim;
#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );


main( model, hideparts, type, no_death )
{
	build_template( "nx_chinese_vtol", model, type );
	build_localinit( ::init_local );
        
        //build_deathfx( "explosions/aerial_explosion_harrier", "tag_deathfx", "explo_metal_rand", undefined, undefined, undefined, undefined, undefined, undefined, 0 );

	build_life( 24000, 22000, 26000 );
	build_team( "axis" );
	build_drive ( %nx_vh_chinese_vtol_movement,undefined, 150 );

	if ( !isdefined( no_death ) )
	{
		blackhawk_death_fx = [];
		blackhawk_death_fx[ "nx_vehicle_chinese_vtol" ] 					 = "explosions/helicopter_explosion";

		build_deathfx( "explosions/helicopter_explosion_secondary_small", 		"tag_threat_id_1", 		"vtol_helicopter_secondary_exp", 			undefined, 			undefined, 		undefined, 		0.2, 		true );
		build_deathfx( "explosions/helicopter_explosion_secondary_small", 		"back_l_thruster", 		"vtol_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		0.5, 		true );
		build_deathfx( "fire/fire_smoke_trail_L", 								"back_l_thruster", 		"vtol_helicopter_dying_loop", 		true, 				0.05, 			true, 			0.5, 		true );
		build_deathfx( "explosions/helicopter_explosion_secondary_small", 		"tag_threat_id_2", 		"vtol_helicopter_tertiary_exp", 	undefined, 			undefined, 		undefined, 		2.5, 		true );
		build_deathfx( "explosions/helicopter_explosion_secondary_small", 		"tag_deathfx", 			"vtol_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		4.0 );
		build_deathfx( blackhawk_death_fx[ model ], 								undefined, 			"vtol_helicopter_crash", 			undefined, 			undefined, 		undefined, 		 - 1, 		undefined, 	"stop_crash_loop_sound" );

		build_rocket_deathfx( "explosions/aerial_explosion_heli_large", 	"tag_deathfx", 	undefined,undefined, 			undefined, 		undefined, 		 undefined, true, 	undefined, 0  );
	}


//      build_rumble( "mig_rumble", 0.05, 0.2, 1500, 0.05, 0.05 );

	build_treadfx();
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_attach_models( ::set_attached_models );
	build_unload_groups( ::Unload_Groups );
	build_mainturret();

	delete_delay = 10.0;
	build_turret( "nx_chinese_vtol_turret", "tag_wing_l_gun_turret", "nx_vehicle_chinese_vtol_gun_turret", undefined, undefined, delete_delay );
	build_turret( "nx_chinese_vtol_turret", "tag_wing_l_missle_turret", "nx_vehicle_chinese_vtol_missile_turret", undefined, undefined, delete_delay );
	build_turret( "nx_chinese_vtol_turret", "tag_wing_r_gun_turret", "nx_vehicle_chinese_vtol_gun_turret", undefined, undefined, delete_delay );
	build_turret( "nx_chinese_vtol_turret", "tag_wing_r_missle_turret", "nx_vehicle_chinese_vtol_missile_turret", undefined, undefined, delete_delay );
	build_flare( %nx_vh_chinese_vtol_stopflare, 0.2 );
	
        //special for ec_vtol/////
	level._effect[ "engineeffect_large" ]			= loadfx( "nx/misc/nx_ec_vtol_thruster_large" );
    level._effect[ "engineeffect_med" ]			= loadfx( "nx/misc/nx_ec_vtol_thruster_med" );
    level._effect[ "engineeffect_small" ]			= loadfx( "nx/misc/nx_ec_vtol_thruster_small" );
	level._effect[ "afterburner" ]				= loadfx( "fire/jet_afterburner_ignite" );
	level._effect[ "contrail" ]				= loadfx( "smoke/jet_contrail" );
	////////////////////////

	// Hide parts. 
	parts = [];
	if ( IsDefined( type ) && type == "nx_chinese_vtol_troop_cabin" )
	{
		parts[ parts.size ] = "tag_ec_ugv_cabin";
	}
	else 
	{
		parts[ parts.size ] = "tag_troop_cabin";
		parts[ parts.size ] = "tag_troop_cabin_btm_door_l";
		parts[ parts.size ] = "tag_troop_cabin_btm_door_r";
		parts[ parts.size ] = "tag_troop_cabin_top_door_l";
		parts[ parts.size ] = "tag_troop_cabin_top_door_r";
		parts[ parts.size ] = "tag_fast_rope_hook_arm";
	}
	build_hideparts( parts );

}

unload_callback( anim_pos )
{
	self endon( "death" );

	if ( IsAlive( self ))
	{
		self.block_ragdoll_fall = true;
		self.allowdeath = true;
	}

	// Wait for note track to fire. 
	while ( 1 )
	{
		notetrack = undefined;
		self waittill( "vehicle_getout", notetrack );
		if ( notetrack == "start_fastrope_fall" )
		{
			break;
		}
		wait( 0.01 );
	}

// 	line( self.origin, self.origin + ( 0, 0, -200 ) );

	if ( IsAlive( self ))
	{
		self.block_ragdoll_fall = false;
		self.allowdeath = false;
		anim_pos.ragdoll_getout_death = true;
	}
}

vtol_disable_turrets()
{
	self endon( "enable_turrets" );

	while( 1 )
	{
		if ( isdefined( self.mgturret ))
		{
			foreach ( turret in self.mgturret )
			{
				turret TurretFireDisable();
//				turret SetMode( "sentry_offline" );
			}
			break;
		}
		wait( 0.01 );
	}
}

vtol_enable_turrets()
{
	self notify( "enable_turrets" );

	if ( isdefined( self.mgturret ))
	{
		foreach ( turret in self.mgturret )
		{
			turret TurretFireEnable();
		}
	}
}

init_local()
{
	self.originheightoffset = distance( self gettagorigin( "tag_origin" ), self gettagorigin( "tag_ground" ) );// TODO - FIXME: this is ugly. Derive from distance between tag_origin and tag_base or whatever that tag was.
	self.script_badplace = false;// All helicopters dont need to create bad places
        thread playEngineEffects();
        //thread test();

	self thread vtol_disable_turrets();
}

#using_animtree( "vehicles" );
test()
{	
	level._scr_animtree[ "nx_chinese_vtol" ] = #animtree;
	level._scr_anim[ "nx_chinese_vtol" ][ "nx_vh_chinese_vtol_getout" ]	= %nx_vh_chinese_vtol_getout;
	level._scr_model[ "nx_chinese_vtol" ]			                = "nx_vehicle_chinese_vtol";	
        //iprintlnbold( "burn!" );
        //playAfterBurner();
        //playfxontag( level._effect[ "engineeffect_large" ], self, "tag_fx_back_r_thruster_exhst" );
        addNotetrack_customFunction( "nx_chinese_vtol", "fx_vtol_unflare_nt", ::playAfterBurner );

}

#using_animtree( "vehicles" );
set_vehicle_anims( positions )
{ 	
	for ( i = 0;i < positions.size;i++ )
		positions[ i ].vehicle_getoutanim = %nx_vh_chinese_vtol_getout;

	return positions;
}

#using_animtree( "generic_human" );

setanims()
{
	positions = [];
	for ( i = 0;i < 6;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].idle = %nx_tp_chinese_vtol_guy2_idle;
	positions[ 1 ].idle = %nx_tp_chinese_vtol_guy3_idle;
	positions[ 2 ].idle = %nx_tp_chinese_vtol_guy4_idle;
	positions[ 3 ].idle = %nx_tp_chinese_vtol_guy6_idle;

	positions[ 4 ].idle = %nx_tp_chinese_vtol_driver_idle;   
	positions[ 5 ].idle = %nx_tp_chinese_vtol_passenger_idle;
	
	positions[ 0 ].sittag = "tag_detach";
	positions[ 1 ].sittag = "tag_detach";
	positions[ 2 ].sittag = "tag_detach";
	positions[ 3 ].sittag = "tag_detach";
	positions[ 4 ].sittag = "tag_detach";
	positions[ 5 ].sittag = "tag_detach";
	
	positions[ 0 ].getout = %nx_tp_chinese_vtol_guy2_getout;;
	positions[ 1 ].getout = %nx_tp_chinese_vtol_guy3_getout;
	positions[ 2 ].getout = %nx_tp_chinese_vtol_guy4_getout;
	positions[ 3 ].getout = %nx_tp_chinese_vtol_guy6_getout;


	positions[ 0 ].getoutstance = "crouch";
	positions[ 1 ].getoutstance = "crouch";
	positions[ 2 ].getoutstance = "crouch";
	positions[ 3 ].getoutstance = "crouch";
	positions[ 4 ].getoutstance = "crouch";
	positions[ 5 ].getoutstance = "crouch";

	positions[ 0 ].unload_callback = ::unload_callback;
	positions[ 1 ].unload_callback = ::unload_callback;
	positions[ 2 ].unload_callback = ::unload_callback;
	positions[ 3 ].unload_callback = ::unload_callback;

	positions[ 0 ].death = %pistol_death_4;
	positions[ 1 ].death = %pistol_death_4;
	positions[ 2 ].death = %pistol_death_4;
	positions[ 3 ].death = %pistol_death_4;
	positions[ 4 ].death = %pistol_death_4;
	positions[ 5 ].death = %pistol_death_4;

	positions[ 0 ].death_no_ragdoll = true;
	positions[ 1 ].death_no_ragdoll = true;
	positions[ 2 ].death_no_ragdoll = true;
	positions[ 3 ].death_no_ragdoll = true;
	positions[ 4 ].death_no_ragdoll = true;
	positions[ 5 ].death_no_ragdoll = true;

	positions[ 0 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 1 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 2 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 3 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 4 ].ragdoll_fall_anim = %fastrope_fall;
	positions[ 5 ].ragdoll_fall_anim = %fastrope_fall;

	positions[ 0 ].rappel_kill_achievement = 1;
	positions[ 1 ].rappel_kill_achievement = 1;
	positions[ 2 ].rappel_kill_achievement = 1;
	positions[ 3 ].rappel_kill_achievement = 1;
	positions[ 4 ].rappel_kill_achievement = 1;
	positions[ 5 ].rappel_kill_achievement = 1;

	// 1, 2, 4, 5, 6, & 8
	positions[ 0 ].fastroperig = "TAG_FastRope_RI";// 1 %bh_1_drop
	positions[ 1 ].fastroperig = "TAG_FastRope_RI";	// 2 %bh_2_drop
	positions[ 2 ].fastroperig = "TAG_FastRope_RI";	// 4 %bh_4_drop
	positions[ 3 ].fastroperig = "TAG_FastRope_RI";	// 5 %bh_5_drop
	positions[ 4 ].fastroperig = "TAG_FastRope_RI";// 8 %bh_8_drop
	positions[ 5 ].fastroperig = "TAG_FastRope_RI";// 6 %bh_6_drop

//  return setplayer_anims( positions );

	return positions;
}


unload_groups()
{
	unload_groups = [];
	unload_groups[ "left" ] = [];
	unload_groups[ "right" ] = [];
	unload_groups[ "both" ] = [];

	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 0;
	unload_groups[ "left" ][ unload_groups[ "left" ].size ] = 1;

	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 0;
	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 1;
	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 2;
	unload_groups[ "right" ][ unload_groups[ "right" ].size ] = 3;

	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 0;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 1;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 2;
	unload_groups[ "both" ][ unload_groups[ "both" ].size ] = 3;

	unload_groups[ "default" ] = unload_groups[ "both" ];

	return unload_groups;
}

set_attached_models()
{
	array = [];
	array[ "TAG_FastRope_LE" ] = spawnstruct();
	array[ "TAG_FastRope_LE" ].model = "rope_test";
	array[ "TAG_FastRope_LE" ].tag = "TAG_FastRope_LE";
	array[ "TAG_FastRope_LE" ].idleanim = %nx_pr_chinese_vtol_rope_idle;
	array[ "TAG_FastRope_LE" ].dropanim = %nx_pr_chinese_vtol_rope_getout;

	array[ "TAG_FastRope_RI" ] = spawnstruct();
	array[ "TAG_FastRope_RI" ].model = "rope_test_ri";
	array[ "TAG_FastRope_RI" ].tag = "TAG_FastRope_RI";
	array[ "TAG_FastRope_RI" ].idleanim = %nx_pr_chinese_vtol_rope_idle;
	array[ "TAG_FastRope_RI" ].dropanim = %nx_pr_chinese_vtol_rope_getout;

	strings = getarraykeys( array );

	for ( i = 0;i < strings.size;i++ )
	{
		precachemodel( array[ strings[ i ] ].model );
	}

	return array;
}

/*
ec_vtol_get_vehicle_velocity()
{
	org1 = self.origin;
	wait 0.1;
	vec = ( self.origin - org1 );
	return vector_multiply( vec, 20 );
}

ec_vtol_am_i_hovering()

        //vel = ec_vtol_get_vehicle_velocity();
        vel = self.GetVelocity();
        if ( vel = 0 )
	continue;

        iprintlnbold( "i am hovering" );
}
*/

playEngineEffects()
{
	self endon( "death" );
	self endon( "stop_engineeffects" );

	self ent_flag_init( "engineeffects" );
	self ent_flag_set( "engineeffects" );
	engineeffects_large = getfx( "engineeffect_large" );
    engineeffects_med = getfx( "engineeffect_med" );
    engineeffects_small = getfx( "engineeffect_small" );

	for ( ;; )
	{
		self ent_flag_wait( "engineeffects" );
		wait 0.01;
		playfxontag( engineeffects_small, self, "tag_fx_back_r_thruster_exhst" );
		playfxontag( engineeffects_small, self, "tag_fx_back_l_thruster_exhst" );
        wait 0.01;
        playfxontag( engineeffects_small, self, "tag_fx_front_r_thruster_exhst" );
		playfxontag( engineeffects_small, self, "tag_fx_front_l_thruster_exhst" );
        
		self ent_flag_waitopen( "engineeffects" );
		StopFXOnTag( engineeffects_small, self, "tag_fx_back_r_thruster_exhst" );
		StopFXOnTag( engineeffects_small, self, "tag_fx_back_l_thruster_exhst" );
        //wait 0.01;
        Stopfxontag( engineeffects_small, self, "tag_fx_front_r_thruster_exhst" );
		Stopfxontag( engineeffects_small, self, "tag_fx_front_l_thruster_exhst" );
        
	}
}

////scripted_engine_transition_scripts

play_engine_hover()
{
   iprintlnbold( "burn!" );
    self endon( "death" );
	self endon( "stop_engineeffects" );
    engineeffects_large = getfx( "engineeffect_large" );
    engineeffects_med = getfx( "engineeffect_med" );
    engineeffects_small = getfx( "engineeffect_small" );

	playfxontag( level._effect[ "engineeffects_small" ], self, "tag_fx_back_l_thruster_exhst" );
	playfxontag( level._effect[ "engineeffects_small" ], self, "tag_fx_back_r_thruster_exhst" );
	wait 0.01;
    playfxontag( level._effect[ "engineeffects_small" ], self, "tag_fx_front_l_thruster_exhst" );
	playfxontag( level._effect[ "engineeffects_small" ], self, "tag_fx_front_r_thruster_exhst" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
playAfterBurner()
{
	//After Burners are pretty much like turbo boost. They don't use them all the time except when 
	//bursts of speed are needed. Needs a cool sound when they're triggered. Currently, they are set
	//to be on all the time, but it would be cool to see them engauge as they fly away.
        
        iprintlnbold( "burn!" );
	playfxontag( level._effect[ "afterburner" ], self, "tag_fx_back_l_thruster_exhst" );
	playfxontag( level._effect[ "afterburner" ], self, "tag_fx_back_r_thruster_exhst" );
}
  
//*******************************************************************
//																	*
//																	*
//*******************************************************************
vtol_thruster_unflare_fx () {
        
        iprintlnbold( "disengading hover mode" );
        playAfterBurner();
}


/*QUAKED script_vehicle_nx_ec_chinese_vtol (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_chinese_vtol::main( "nx_vehicle_chinese_vtol", "ignored" );


include,nx_vehicle_chinese_vtol

defaultmdl="nx_vehicle_chinese_vtol"
default:"vehicletype" "nx_chinese_vtol"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_nx_ec_chinese_vtoltroopcabin_closed (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_chinese_vtol::main( "nx_vehicle_chinese_vtol", "ignored", "nx_chinese_vtol_troop_cabin" );


include,nx_vehicle_chinese_vtol

defaultmdl="nx_vehicle_chinese_vtol"
default:"vehicletype" "nx_chinese_vtol_troop_cabin"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_nx_proto_arcade_vtol (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_chinese_vtol::main( "nx_vehicle_chinese_vtol", "ignored", "nx_proto_arcade_vtol" );


include,nx_vehicle_chinese_vtol

defaultmdl="nx_vehicle_chinese_vtol"
default:"vehicletype" "nx_proto_arcade_vtol"
default:"script_team" "axis"
*/
