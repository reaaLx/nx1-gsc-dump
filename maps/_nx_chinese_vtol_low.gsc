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

//      build_rumble( "mig_rumble", 0.05, 0.2, 1500, 0.05, 0.05 );

	if ( !isdefined( no_death ) )
	{
		blackhawk_death_fx = [];
		blackhawk_death_fx[ "nx_vehicle_chinese_vtol" ] 					 = "explosions/helicopter_explosion";

		build_deathfx( "explosions/helicopter_explosion_secondary_small",		"tag_threat_id_1", 			"vtol_helicopter_primary_exp", 		undefined, 			undefined, 		undefined, 		0.2, 		true );
		build_deathfx( "explosions/helicopter_explosion_secondary_small",		"back_l_thruster", 			"vtol_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		0.5, 		true );
		build_deathfx( "nx/fire/nx_fire_smoke_trail_emitter_rocket", 			"back_l_thruster", 			"vtol_helicopter_dying_loop", 		undefined, 			undefined, 		true, 			0.5, 		true );
		build_deathfx( "nx/fire/nx_fire_smoke_trail_emitter_rocket", 			"tag_wing_l_missile_turret","vtol_helicopter_dying_loop", 		undefined,			undefined, 		true, 			0.5, 		true );
		build_deathfx( "explosions/helicopter_explosion", 						"tag_threat_id_2", 			"vtol_helicopter_tertiary_exp", 	undefined, 			undefined, 		undefined, 		0.0, 		true );
		build_deathfx( "explosions/helicopter_explosion", 						"tag_threat_id_2", 			"vtol_helicopter_tertiary_exp", 	undefined, 			undefined, 		undefined, 		2.5, 		true );
		build_deathfx( "nx/explosions/nx_rocket_vtol_explosion_bridge", 		"tag_deathfx", 				"vtol_helicopter_secondary_exp", 	undefined, 			undefined, 		undefined, 		4.0 );



		build_deathfx( blackhawk_death_fx[ model ], 								undefined, 			"vtol_helicopter_crash", 			undefined, 			undefined, 		undefined, 		 - 1, 		undefined, 	"stop_crash_loop_sound" );

		build_rocket_deathfx( "nx/explosions/nx_rocket_vtol_explosion_bridge", 	"tag_deathfx", 	undefined,undefined, 			undefined, 		undefined, 		 undefined, true, 	undefined, 0  );
	}

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
	if ( IsDefined( type ) && type == "nx_chinese_vtol_troop_cabin_low" )
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

init_local()
{
	self.originheightoffset = distance( self gettagorigin( "tag_origin" ), self gettagorigin( "tag_ground" ) );// TODO - FIXME: this is ugly. Derive from distance between tag_origin and tag_base or whatever that tag was.
	self.script_badplace = false;// All helicopters dont need to create bad places
	thread playEngineEffects();
	//thread test();

	self maps\_nx_chinese_vtol::vtol_disable_turrets();
}

#using_animtree( "vehicles" );
test()
{	
	level._scr_animtree[ "nx_chinese_vtol" ] = #animtree;
	level._scr_anim[ "nx_chinese_vtol" ][ "nx_vh_chinese_vtol_getout" ]	= %nx_vh_chinese_vtol_getout_low;
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
		positions[ i ].vehicle_getoutanim = %nx_vh_chinese_vtol_getout_low;

	return positions;
}

#using_animtree( "generic_human" );

setanims()
{
	positions = maps\_nx_chinese_vtol::setanims();

	// Overrides for low version. 
	positions[ 0 ].getout = %nx_tp_chinese_vtol_guy2_getout_low;
	positions[ 1 ].getout = %nx_tp_chinese_vtol_guy3_getout_low;
	positions[ 2 ].getout = %nx_tp_chinese_vtol_guy4_getout_low;
	positions[ 3 ].getout = %nx_tp_chinese_vtol_guy6_getout_low;

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
	array[ "TAG_FastRope_LE" ].idleanim = %nx_pr_chinese_vtol_rope_idle_low;
	array[ "TAG_FastRope_LE" ].dropanim = %nx_pr_chinese_vtol_rope_getout_low;

	array[ "TAG_FastRope_RI" ] = spawnstruct();
	array[ "TAG_FastRope_RI" ].model = "rope_test_ri";
	array[ "TAG_FastRope_RI" ].tag = "TAG_FastRope_RI";
	array[ "TAG_FastRope_RI" ].idleanim = %nx_pr_chinese_vtol_rope_idle_low;
	array[ "TAG_FastRope_RI" ].dropanim = %nx_pr_chinese_vtol_rope_getout_low;

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

playDamageEffects( health_threshold, efx_idx )
{
	// Dan:  Last minute HACK to get some pre-death damage effects on the VTOLs.
	// Coopting the loaded death effects.

	self endon( "death" );
	self endon( "stop_looping_death_fx" );

	for ( ;; )
	{
		//IPrintLn( self GetEntNum() + ": health = " + self.health );
		if ( self.health < health_threshold )
		{
			//IPrintLnBold( self GetEntNum() + ": SMOKE!" );

			typemodel = self.vehicletype + self.model;
			struct_fire = level._vehicle_death_fx[ typemodel ][ efx_idx ];
			struct_expl_big = level._vehicle_death_fx[ typemodel ][ 4 ];
			struct_expl_sml = level._vehicle_death_fx[ typemodel ][ 0 ];
		
			PlayFXOnTag( struct_expl_sml.effect, self, "tag_threat_id_1" );
			wait 0.05;
			PlayFXOnTag( struct_expl_sml.effect, self, "tag_wing_l_missile_turret" );
			wait 0.05;
			PlayFXOnTag( struct_expl_sml.effect, self, "tag_threat_id_1" );
			wait 0.1;
			PlayFXOnTag( struct_expl_sml.effect, self, "tag_wing_l_missile_turret" );
			wait 0.05;

			PlayFXOnTag( struct_expl_sml.effect, self, "back_l_thruster" );

			wait 0.2;
			PlayFXOnTag( struct_fire.effect, self, struct_fire.tag );

			return;
		}
		wait 0.05;
	}
}

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
		playfxontag( engineeffects_small, self, "tag_fx_back_r_thruster_exhst" );
		playfxontag( engineeffects_small, self, "tag_fx_back_l_thruster_exhst" );
		playfxontag( engineeffects_small, self, "tag_fx_front_r_thruster_exhst" );
		playfxontag( engineeffects_small, self, "tag_fx_front_l_thruster_exhst" );
        
		self ent_flag_waitopen( "engineeffects" );
		StopFXOnTag( engineeffects_small, self, "tag_fx_back_r_thruster_exhst" );
		StopFXOnTag( engineeffects_small, self, "tag_fx_back_l_thruster_exhst" );
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

/*QUAKED script_vehicle_nx_ec_chinese_vtoltroopcabin_closed_low (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_chinese_vtol_low::main( "nx_vehicle_chinese_vtol", "ignored", "nx_chinese_vtol_troop_cabin_low" );


include,nx_vehicle_chinese_vtol_low

defaultmdl="nx_vehicle_chinese_vtol"
default:"vehicletype" "nx_chinese_vtol_troop_cabin_low"
default:"script_team" "axis"
*/
