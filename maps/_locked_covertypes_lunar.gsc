//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Locked combat covertypes	for lunar			                **
//    Created: 6/14/11 - John Webb		                                    **
//                                                                          **
//****************************************************************************

#include common_scripts\utility;
#include animscripts\combat_utility;
#include animscripts\utility;

#using_animtree( "generic_human" );

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
init_default_covertypes()
{
	AssertEx( isdefined( level._locked_combat ), "maps\_locked_combat::main() must be called before init_default_covertypes()" );
	level._locked_combat.default_covertype = "crouch";
	maps\_locked_combat::add_covertype( "crouch", ::init_covertype_crouch, maps\_locked_combat::run_covertype_custom, ::crouch_get_valid_cover_modes );
	maps\_locked_combat::add_covertype( "stand", ::init_covertype_stand, maps\_locked_combat::run_covertype_custom, ::stand_get_valid_cover_modes );
	maps\_locked_combat::add_covertype( "left", ::init_covertype_left, maps\_locked_combat::run_covertype_custom, ::corner_get_valid_cover_modes );
	maps\_locked_combat::add_covertype( "right", ::init_covertype_right, maps\_locked_combat::run_covertype_custom, ::corner_get_valid_cover_modes );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
init_covertype_stand()
{
	animset = [];

	// Idles
	animset[ "hide_idle" ] = %coverstand_hide_idle;
	animset[ "hide_idle_twitch" ] = array(
		%coverstand_hide_idle_twitch01,
		%coverstand_hide_idle_twitch02,
		%coverstand_hide_idle_twitch03,
		%coverstand_hide_idle_twitch04,
		%coverstand_hide_idle_twitch05
	 );
	animset[ "hide_idle_flinch" ] = array(
		%coverstand_react01,
		%coverstand_react02,
		%coverstand_react03,
		%coverstand_react04
	);

	// Pop up
	animset[ "hide_2_stand" ] = %coverstand_hide_2_aim;
	animset[ "stand_2_hide" ] = %coverstand_aim_2_hide;
	animset[ "stand_aim" ] = %exposed_aim_5;
	animset[ "stand_aim2" ] = %exposed_aim_2;
	animset[ "stand_aim4" ] = %exposed_aim_4;
	animset[ "stand_aim6" ] = %exposed_aim_6;
	animset[ "stand_aim8" ] = %exposed_aim_8;

	// Looking
	animset[ "look" ] = array( %covercrouch_hide_look );

	// Reload
	animset[ "reload" ] = %covercrouch_reload_hide;

	// Firing anims
	animset[ "fire" ] = %exposed_shoot_auto_v2;
	animset[ "semi2" ] = %exposed_shoot_semi2;
	animset[ "semi3" ] = %exposed_shoot_semi3;
	animset[ "semi4" ] = %exposed_shoot_semi4;
	animset[ "semi5" ] = %exposed_shoot_semi5;
	animset[ "burst2" ] = %exposed_shoot_burst3;// ( will be limited to 2 shots )
	animset[ "burst3" ] = %exposed_shoot_burst3;
	animset[ "burst4" ] = %exposed_shoot_burst4;
	animset[ "burst5" ] = %exposed_shoot_burst5;
	animset[ "burst6" ] = %exposed_shoot_burst6;
	animset[ "continuous" ] = array( %nx_tp_stand_exposed_stream_01 );
	animset[ "blind_fire" ] = array( %covercrouch_blindfire_1, %covercrouch_blindfire_2, %covercrouch_blindfire_3, %covercrouch_blindfire_4 );
	animset[ "single" ] = array( %exposed_shoot_semi1 );
	animset[ "exposed_idle" ] = array( %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 );

	animset[ "grenade_exposed" ] = array( %exposed_grenadeThrowB );
	animset[ "grenade_safe" ] = array( %exposed_grenadeThrowC );

	self.a.array = animset;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
run_covertype_stand()
{
	behaviorCallbacks = spawnstruct();
	behaviorCallbacks.moveToNearByCover		 = animscripts\locked_combat::return_false;
	behaviorCallbacks.reload				 = animscripts\cover_wall::coverReload;
	behaviorCallbacks.leaveCoverAndShoot	 = animscripts\locked_combat::locked_popUpAndShoot;
	behaviorCallbacks.look					 = animscripts\cover_wall::look;
	behaviorCallbacks.fastlook				 = animscripts\cover_wall::fastLook;
	behaviorCallbacks.idle					 = animscripts\cover_wall::idle;
	behaviorCallbacks.flinch				 = animscripts\cover_wall::flinch;
	behaviorCallbacks.grenade				 = animscripts\locked_combat::return_false;
	behaviorCallbacks.grenadehidden			 = animscripts\locked_combat::return_false;
	behaviorCallbacks.blindfire				 = animscripts\cover_wall::blindfire;
	
	self animscripts\cover_behavior::main( behaviorCallbacks );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
init_covertype_left()
{	
	self.cornerDirection = "left";
	animset = [];

	self.hideYawOffset = 90;
	self.a.leanAim = true;

	// Idles
	animset[ "hide_idle" ] = %tp_moon_coverL_stand_alert_idle;
	animset[ "hide_idle_twitch" ] = array(
		%tp_moon_coverL_stand_alert_twitch_01
	 );
	animset[ "hide_idle_flinch" ] = array( %tp_moon_coverL_stand_alert_flinch_01 );

	// Lean
	animset[ "hide_2_lean" ] = %tp_moon_coverL_stand_alert_2_lean_01;
	animset[ "lean_2_hide" ] = %tp_moon_coverL_stand_lean_2_alert_01;
	animset[ "lean_aim" ] = %tp_moon_coverL_stand_lean_aim_straight;
	animset[ "lean_aim2" ] = %tp_moon_coverL_stand_lean_aim_down;
	animset[ "lean_aim4" ] = %tp_moon_coverL_stand_lean_aim_left;
	animset[ "lean_aim6" ] = %tp_moon_coverL_stand_lean_aim_right;
	animset[ "lean_aim8" ] = %tp_moon_coverL_stand_lean_aim_up;
	animset[ "lean_idle" ] = [ %tp_moon_coverL_stand_lean_idle_01 ];

	// A
	animset[ "hide_2_A" ] = %tp_moon_coverL_stand_alert_2_A_01;
	animset[ "A_2_hide" ] = %tp_moon_coverL_stand_A_2_alert_01;
	animset[ "A_aim" ] = %exposed_aim_5;
	animset[ "A_aim2" ] = %exposed_aim_2;
	animset[ "A_aim4" ] = %exposed_aim_4;
	animset[ "A_aim6" ] = %exposed_aim_6;
	animset[ "A_aim8" ] = %exposed_aim_8;

	// B
	animset[ "hide_2_B" ] = %tp_moon_coverL_stand_alert_2_B_01;
	animset[ "B_2_hide" ] = %tp_moon_coverL_stand_B_2_alert_01;
	animset[ "B_aim" ] = %exposed_aim_5;
	animset[ "B_aim2" ] = %exposed_aim_2;
	animset[ "B_aim4" ] = %exposed_aim_4;
	animset[ "B_aim6" ] = %exposed_aim_6;
	animset[ "B_aim8" ] = %exposed_aim_8;

	// A/B transitions
	//animset[ "A_to_B" ] = [ %corner_standL_trans_A_2_B_v2 ];
	//animset[ "B_to_A" ] = [ %corner_standL_trans_B_2_A_v2 ];

	// Looking
	animset[ "hide_to_look" ] = %corner_standL_alert_2_look;
	animset[ "look_to_hide" ] = %corner_standL_look_2_alert;
	animset[ "look_to_hide_fast" ] = %corner_standl_look_2_alert_fast_v1;
	animset[ "look_idle" ] = %corner_standL_look_idle;
	animset[ "look" ] = array( %corner_standL_look );


	// Reload
	animset[ "reload" ] = %tp_moon_coverL_stand_reload_01;// , %corner_standL_reload_v2 );

	// Firing anims
	animset[ "fire" ] = %tp_moon_coverL_stand_lean_fire_auto;
	animset[ "semi2" ] = %exposed_shoot_semi2;
	animset[ "semi3" ] = %exposed_shoot_semi3;
	animset[ "semi4" ] = %exposed_shoot_semi4;
	animset[ "semi5" ] = %exposed_shoot_semi5;
	animset[ "burst2" ] = %exposed_shoot_burst3;// ( will be limited to 2 shots )
	animset[ "burst3" ] = %exposed_shoot_burst3;
	animset[ "burst4" ] = %exposed_shoot_burst4;
	animset[ "burst5" ] = %exposed_shoot_burst5;
	animset[ "burst6" ] = %exposed_shoot_burst6;
	animset[ "continuous" ] = array( %nx_tp_stand_exposed_stream_01 );
	animset[ "blind_fire" ] = array( %tp_moon_coverL_stand_blindfire_01 );
	animset[ "single" ] = array( %tp_moon_coverL_stand_lean_fire_single );
	animset[ "exposed_idle" ] = array( %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 );

	animset[ "grenade_exposed" ] = array( %tp_moon_coverL_stand_grenade_exposed );
	animset[ "grenade_safe" ] = array( %tp_moon_coverL_stand_grenade_safe );

	self.a.array = animset;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
init_covertype_right()
{	
	self.cornerDirection = "right";
	animset = [];

	self.hideYawOffset = 90;
	self.a.leanAim = true;

	// Idles
	animset[ "hide_idle" ] = %tp_moon_coverR_stand_alert_idle;
	animset[ "hide_idle_twitch" ] = array(
		%tp_moon_coverR_stand_alert_twitch_01
	 );
	animset[ "hide_idle_flinch" ] = array( %tp_moon_coverR_stand_alert_flinch_01 );

	// Lean
	animset[ "hide_2_lean" ] = %tp_moon_coverR_stand_alert_2_lean_01;
	animset[ "lean_2_hide" ] = %tp_moon_coverR_stand_lean_2_alert_01;
	animset[ "lean_aim" ] = %tp_moon_coverR_stand_lean_aim_straight;
	animset[ "lean_aim2" ] = %tp_moon_coverR_stand_lean_aim_down;
	animset[ "lean_aim4" ] = %tp_moon_coverR_stand_lean_aim_left;
	animset[ "lean_aim6" ] = %tp_moon_coverR_stand_lean_aim_right;
	animset[ "lean_aim8" ] = %tp_moon_coverR_stand_lean_aim_up;
	animset[ "lean_idle" ] = [ %tp_moon_coverR_stand_lean_idle_01 ];

	// A
	animset[ "hide_2_A" ] = %tp_moon_coverR_stand_alert_2_A_01;
	animset[ "A_2_hide" ] = %tp_moon_coverR_stand_A_2_alert_01;
	animset[ "A_aim" ] = %exposed_aim_5;
	animset[ "A_aim2" ] = %exposed_aim_2;
	animset[ "A_aim4" ] = %exposed_aim_4;
	animset[ "A_aim6" ] = %exposed_aim_6;
	animset[ "A_aim8" ] = %exposed_aim_8;

	// B
	animset[ "hide_2_B" ] = %tp_moon_coverR_stand_alert_2_B_01;
	animset[ "B_2_hide" ] = %tp_moon_coverR_stand_B_2_alert_01;
	animset[ "B_aim" ] = %exposed_aim_5;
	animset[ "B_aim2" ] = %exposed_aim_2;
	animset[ "B_aim4" ] = %exposed_aim_4;
	animset[ "B_aim6" ] = %exposed_aim_6;
	animset[ "B_aim8" ] = %exposed_aim_8;

	// A/B transitions
	//animset[ "A_to_B" ] = [ %corner_standL_trans_A_2_B_v2 ];
	//animset[ "B_to_A" ] = [ %corner_standL_trans_B_2_A_v2 ];

	// Looking
	animset[ "hide_to_look" ] = %tp_moon_coverR_stand_alert_2_look;
	animset[ "look_to_hide" ] = %tp_moon_coverR_stand_look_2_alert;
	animset[ "look_to_hide_fast" ] = %tp_moon_coverR_stand_look_2_alert_fast;
	animset[ "look_idle" ] = %tp_moon_coverR_stand_look_idle;
	animset[ "look" ] = array( %tp_moon_coverR_stand_stand_2_alert );


	// Reload
	animset[ "reload" ] = %tp_moon_coverR_stand_reload_01;// , %corner_standL_reload_v2 );

	// Firing anims
	animset[ "fire" ] = %tp_moon_coverR_stand_lean_fire_auto;
	animset[ "semi2" ] = %exposed_shoot_semi2;
	animset[ "semi3" ] = %exposed_shoot_semi3;
	animset[ "semi4" ] = %exposed_shoot_semi4;
	animset[ "semi5" ] = %exposed_shoot_semi5;
	animset[ "burst2" ] = %exposed_shoot_burst3;// ( will be limited to 2 shots )
	animset[ "burst3" ] = %exposed_shoot_burst3;
	animset[ "burst4" ] = %exposed_shoot_burst4;
	animset[ "burst5" ] = %exposed_shoot_burst5;
	animset[ "burst6" ] = %exposed_shoot_burst6;
	animset[ "continuous" ] = array( %nx_tp_stand_exposed_stream_01 );
	animset[ "blind_fire" ] = array( %tp_moon_coverR_stand_blindfire_01 );
	animset[ "single" ] = array( %tp_moon_coverR_stand_lean_fire_single );
	animset[ "exposed_idle" ] = array( %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 );

	animset[ "grenade_exposed" ] = array( %tp_moon_coverR_stand_grenade_exposed );
	animset[ "grenade_safe" ] = array( %tp_moon_coverR_stand_grenade_safe );

	self.a.array = animset;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
init_covertype_crouch()
{
	animset = [];

	// Idles
	animset[ "hide_idle" ] = %covercrouch_hide_idle;
	animset[ "hide_idle_twitch" ] = array(
		%covercrouch_twitch_1,
		%covercrouch_twitch_2,
		%covercrouch_twitch_3,
		%covercrouch_twitch_4
	 );
	animset[ "hide_idle_flinch" ] = array();

	// Pop up
	animset[ "hide_2_crouch" ] = %covercrouch_hide_2_aim;
	animset[ "crouch_2_hide" ] = %covercrouch_aim_2_hide;
	animset[ "crouch_aim" ] = %covercrouch_aim5;
	animset[ "crouch_aim2" ] = %covercrouch_aim2_add;
	animset[ "crouch_aim4" ] = %covercrouch_aim4_add;
	animset[ "crouch_aim6" ] = %covercrouch_aim6_add;
	animset[ "crouch_aim8" ] = %covercrouch_aim8_add;

	// Looking
	animset[ "look" ] = array( %covercrouch_hide_look );

	// Reload
	animset[ "reload" ] = %covercrouch_reload_hide;

	// Firing anims
	animset[ "fire" ] = %exposed_shoot_auto_v2;
	animset[ "semi2" ] = %exposed_shoot_semi2;
	animset[ "semi3" ] = %exposed_shoot_semi3;
	animset[ "semi4" ] = %exposed_shoot_semi4;
	animset[ "semi5" ] = %exposed_shoot_semi5;
	animset[ "burst2" ] = %exposed_shoot_burst3;// ( will be limited to 2 shots )
	animset[ "burst3" ] = %exposed_shoot_burst3;
	animset[ "burst4" ] = %exposed_shoot_burst4;
	animset[ "burst5" ] = %exposed_shoot_burst5;
	animset[ "burst6" ] = %exposed_shoot_burst6;
	animset[ "continuous" ] = array( %nx_tp_stand_exposed_stream_01 );
	animset[ "blind_fire" ] = array( %covercrouch_blindfire_1, %covercrouch_blindfire_2, %covercrouch_blindfire_3, %covercrouch_blindfire_4 );
	animset[ "single" ] = array( %exposed_shoot_semi1 );
	animset[ "exposed_idle" ] = array( %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 );

	animset[ "grenade_exposed" ] = array( %covercrouch_grenadeA, %covercrouch_grenadeB );
	animset[ "grenade_safe" ] = array( %covercrouch_grenadeA, %covercrouch_grenadeB );

	self.a.array = animset;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
crouch_get_valid_cover_modes()
{
	modes = [];

	// If multiple peekout types to shoot at various angles, decide here which to use
	modes[ modes.size ] = "crouch";
	return getRandomCoverMode( modes );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
stand_get_valid_cover_modes()
{
	modes = [];

	// If multiple peekout types to shoot at various angles, decide here which to use
	modes[ modes.size ] = "stand";
	return getRandomCoverMode( modes );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
corner_get_valid_cover_modes()
{
	point = undefined;
	if ( hasEnemySightPos() )
	{
		point = getEnemySightPos();
	}

	node = self.coverNode;

	 /#
	dvarval = getdvar( "scr_cornerforcestance" );
	if ( dvarval == "lean" || dvarval == "A" || dvarval == "B" || dvarval == "over" )
		return dvarval;
	#/
	
	noStepOut = false;
	yaw = 0;
	
	if ( isdefined( point ) )
		yaw = node GetYawToOrigin( point );

	modes = [];

	if ( self.a.pose == "stand" )
	{
		self.ABangleCutoff = 38;
	}
	else
	{
		assert( self.a.pose == "crouch" );
		self.ABangleCutoff = 31;
	}

	if ( self.cornerDirection == "left" )
	{
		if ( animscripts\corner::canLean( yaw, -40, 0 ) )
		{
			noStepOut = animscripts\corner::shouldLean();
			modes[ modes.size ] = "lean";
		}
					
		if ( !noStepOut && yaw < 14 )
		{
			if ( yaw < 0 - self.ABangleCutoff )
				modes[ modes.size ] = "A";
			else
				modes[ modes.size ] = "B";
		}
	}
	else
	{
		assert( self.cornerDirection == "right" );
		
		if ( animscripts\corner::canLean( yaw, 0, 40 ) )
		{
			noStepOut = animscripts\corner::shouldLean();
			modes[ modes.size ] = "lean";
		}
		
		if ( !noStepOut && yaw > -12 )
		{
			if ( yaw > self.ABangleCutoff )
				modes[ modes.size ] = "A";
			else
				modes[ modes.size ] = "B";
		}
	}

	//assert( modes.size > 0 );
	return getRandomCoverMode( modes );
}
