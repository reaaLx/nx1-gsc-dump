#include animscripts\Utility;
#include common_scripts\Utility;

#using_animtree( "generic_human" );


////////////////////////////////////////////
// Initialize anim sets
//
// anim.initAnimSet is used as a temporary buffer, because variables, including arrays, can't be passed by reference
// Set it up in each init_animset_* function and then store it in anim.animset.*
// This allows using helpers such as "set_animarray_stance_change" for different sets
////////////////////////////////////////////

init_anim_sets()
{
	anim.animsets = spawnstruct();
	anim.animsets.move = [];
	anim.animSetLoaded = "earth";
	
	// combat stand
	init_animset_default_stand();
	init_animset_cqb_stand();
	init_animset_pistol_stand();
	init_animset_rpg_stand();
	init_animset_shotgun_stand();
	init_animset_heat_stand();
	
	// combat crouch
	init_animset_default_crouch();
	init_animset_rpg_crouch();
	init_animset_shotgun_crouch();	
	
	// combat prone
	init_animset_default_prone();
	
	// move
	init_animset_run_move();
	init_animset_walk_move();
	init_animset_cqb_move();
	init_animset_heat_run_move();

	// move aim
	init_animset_run_aim_tracking();
	
	init_moving_turn_animations();
	
	//death
	init_animset_death();
	
	//pain
	init_animset_pain();
	
	//wall cover anims
	init_animset_crouch_wall();
	init_animset_stand_wall();

	// Melee
	init_animset_melee();
	
	//gib
	init_animset_gib();

	init_animset_run_n_gun();

	init_ambush_sidestep_anims();

	init_heat_reload_function();

	//left cover anims
	init_animarray_standing_left();
	init_animarray_crouching_left();

	//right cover anims
	init_animarray_standing_right();
	init_animarray_crouching_right();

	initGrenades();

	init_noder_anims();

	//aim anims
	init_standing_animarray_aiming();
	init_crouching_animarray_aiming();

	//reactions
	init_reaction_anims();
}

initGrenades()
{
	for ( i = 0; i < level._players.size; i++ )
	{
		player = level._players[ i ];
		player.grenadeTimers[ "fraggrenade" ] = randomIntRange( 1000, 20000 );
		player.grenadeTimers[ "moon_grenade" ] = randomIntRange( 1000, 20000 );
		player.grenadeTimers[ "flash_grenade" ] = randomIntRange( 1000, 20000 );
		player.grenadeTimers[ "double_grenade" ] = randomIntRange( 1000, 60000 );
		player.numGrenadesInProgressTowardsPlayer = 0;
		player.lastGrenadeLandedNearPlayerTime = -1000000;
		player.lastFragGrenadeToPlayerStart    = -1000000;
		player thread animscripts\init_common::setNextPlayerGrenadeTime();
	}
	anim.grenadeTimers[ "AI_fraggrenade" ] = randomIntRange( 0, 20000 );
	anim.grenadeTimers[ "AI_moon_grenade" ] = randomIntRange( 0, 20000 );
	anim.grenadeTimers[ "AI_flash_grenade" ] = randomIntRange( 0, 20000 );
	anim.grenadeTimers[ "AI_smoke_grenade_american" ] = randomIntRange( 0, 20000 );

	/#
	thread animscripts\combat_utility::grenadeTimerDebug();
	#/
	
	initGrenadeThrowAnims();
}

init_animset_run_aim_tracking()
{
	anim.initAnimSet = [];
	anim.initAnimSet[ "add_aim_down" ] = %walk_aim_2;
	anim.initAnimSet[ "add_aim_left" ] = %walk_aim_4;
	anim.initAnimSet[ "add_aim_right" ] = %walk_aim_6;
	anim.initAnimSet[ "add_aim_up" ] = %walk_aim_8;

	assert( !isdefined( anim.animsets.runAimTracking ) );
	anim.animsets.runAimTracking = anim.initAnimSet;
}

init_animset_melee()
{
	anim.initAnimSet = [];
	anim.initAnimSet[ "attack" ] = %melee_1;
	anim.initAnimSet[ "charge" ] = %run_2_melee_charge;
	anim.initAnimSet[ "run" ] = %run_lowready_F;
	anim.initAnimSet[ "stand_to_melee" ] = %stand_2_melee_1;

	assert( !isdefined( anim.animsets.melee ) );
	anim.animsets.melee = anim.initAnimSet;
}


init_animset_run_move()
{
	anim.initAnimSet = [];
	anim.initAnimSet[ "sprint" ] = %sprint_loop_distant;
	anim.initAnimSet[ "sprint_short" ] = %sprint1_loop;
	anim.initAnimSet[ "prone" ] = %prone_crawl;

	anim.initAnimSet[ "straight" ] = %run_lowready_F;
	
	anim.initAnimSet[ "move_f" ] = %walk_forward;
	anim.initAnimSet[ "move_l" ] = %walk_left;
	anim.initAnimSet[ "move_r" ] = %walk_right;
	anim.initAnimSet[ "move_b" ] = %walk_backward; //this looks too fast to be natural
	
	anim.initAnimSet[ "crouch" ] = %crouch_fastwalk_F;
	anim.initAnimSet[ "crouch_l" ] = %crouch_fastwalk_L;
	anim.initAnimSet[ "crouch_r" ] = %crouch_fastwalk_R;
	anim.initAnimSet[ "crouch_b" ] = %crouch_fastwalk_B;
	
	anim.initAnimSet[ "stairs_up" ] = %traverse_stair_run_01;
	anim.initAnimSet[ "stairs_down" ] = %traverse_stair_run_down;
	
	assert( !isdefined( anim.animsets.move[ "run" ] ) );
	anim.animsets.move[ "run" ] = anim.initAnimSet;	
}


init_animset_heat_run_move()
{
	assert( isdefined( anim.animsets.move[ "run" ] ) );
	anim.initAnimSet = anim.animsets.move[ "run" ];

	anim.initAnimSet[ "straight" ] = %heat_run_loop;
	
	assert( !isdefined( anim.animsets.move[ "heat_run" ] ) );
	anim.animsets.move[ "heat_run" ] = anim.initAnimSet;	
}


init_animset_walk_move()
{
	anim.initAnimSet = [];
	anim.initAnimSet[ "sprint" ] = %sprint_loop_distant;
	anim.initAnimSet[ "sprint_short" ] = %sprint1_loop;
	anim.initAnimSet[ "prone" ] = %prone_crawl;

	anim.initAnimSet[ "straight" ] = %walk_CQB_F;
	
	anim.initAnimSet[ "move_f" ] = %walk_CQB_F;
	anim.initAnimSet[ "move_l" ] = %walk_left;
	anim.initAnimSet[ "move_r" ] = %walk_right;
	anim.initAnimSet[ "move_b" ] = %walk_backward;
	
	anim.initAnimSet[ "crouch" ] = %crouch_fastwalk_F;
	anim.initAnimSet[ "crouch_l" ] = %crouch_fastwalk_L;
	anim.initAnimSet[ "crouch_r" ] = %crouch_fastwalk_R;
	anim.initAnimSet[ "crouch_b" ] = %crouch_fastwalk_B;	
	
	anim.initAnimSet[ "stairs_up" ] = %traverse_stair_run;
	anim.initAnimSet[ "stairs_down" ] = %traverse_stair_run_down_01;

	assert( !isdefined( anim.animsets.move[ "walk" ] ) );
	anim.animsets.move[ "walk" ] = anim.initAnimSet;	
}


init_animset_cqb_move()
{
	anim.initAnimSet = [];
	anim.initAnimSet[ "sprint" ] = %sprint_loop_distant;
	anim.initAnimSet[ "sprint_short" ] = %sprint1_loop;
	anim.initAnimSet[ "straight" ] = %run_CQB_F_search_v1;	// %run_CQB_F_search_v2
	anim.initAnimSet[ "straight_variation" ] = %run_CQB_F_search_v2;
	
	anim.initAnimSet[ "move_f" ] = %walk_CQB_F;
	anim.initAnimSet[ "move_l" ] = %walk_left;
	anim.initAnimSet[ "move_r" ] = %walk_right;
	anim.initAnimSet[ "move_b" ] = %walk_backward;

	anim.initAnimSet[ "stairs_up" ] = %traverse_stair_run;
	anim.initAnimSet[ "stairs_down" ] = %traverse_stair_run_down_01;

	assert( !isdefined( anim.animsets.move[ "cqb" ] ) );
	anim.animsets.move[ "cqb" ] = anim.initAnimSet;	
}


init_animset_pistol_stand()
{
	anim.initAnimSet = [];
	anim.initAnimSet[ "add_aim_up" ] = %pistol_stand_aim_8_add;
	anim.initAnimSet[ "add_aim_down" ] = %pistol_stand_aim_2_add;
	anim.initAnimSet[ "add_aim_left" ] = %pistol_stand_aim_4_add;
	anim.initAnimSet[ "add_aim_right" ] = %pistol_stand_aim_6_add;
	anim.initAnimSet[ "straight_level" ] = %pistol_stand_aim_5;

	anim.initAnimSet[ "fire" ] = %pistol_stand_fire_A;
	anim.initAnimSet[ "single" ] = array( %pistol_stand_fire_A );

	anim.initAnimSet[ "reload" ] = array( %pistol_stand_reload_A );
	anim.initAnimSet[ "reload_crouchhide" ] = array();

	anim.initAnimSet[ "exposed_idle" ] = array( %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 );

	set_animarray_standing_turns_pistol();

	anim.initAnimSet[ "add_turn_aim_up" ] = %pistol_stand_aim_8_alt;
	anim.initAnimSet[ "add_turn_aim_down" ] = %pistol_stand_aim_2_alt;
	anim.initAnimSet[ "add_turn_aim_left" ] = %pistol_stand_aim_4_alt;
	anim.initAnimSet[ "add_turn_aim_right" ] = %pistol_stand_aim_6_alt;
	
	assert( !isdefined( anim.animsets.pistolStand ) );
	anim.animsets.pistolStand = anim.initAnimSet;
}

init_animset_rpg_stand()
{
	anim.initAnimSet = [];
	anim.initAnimSet[ "add_aim_up" ] = %RPG_stand_aim_8;
	anim.initAnimSet[ "add_aim_down" ] = %RPG_stand_aim_2;
	anim.initAnimSet[ "add_aim_left" ] = %RPG_stand_aim_4;
	anim.initAnimSet[ "add_aim_right" ] = %RPG_stand_aim_6;
	anim.initAnimSet[ "straight_level" ] = %RPG_stand_aim_5;

	anim.initAnimSet[ "fire" ] = %RPG_stand_fire;
	anim.initAnimSet[ "single" ] = array( %exposed_shoot_semi1 );

	anim.initAnimSet[ "reload" ] = array( %RPG_stand_reload );
	anim.initAnimSet[ "reload_crouchhide" ] = array();

	anim.initAnimSet[ "exposed_idle" ] = array( %RPG_stand_idle );

	set_animarray_stance_change();
	set_animarray_standing_turns();
	set_animarray_add_turn_aims_stand();
	
	assert( !isdefined( anim.animsets.rpgStand ) );
	anim.animsets.rpgStand = anim.initAnimSet;
}

init_animset_shotgun_stand()
{
	anim.initAnimSet = [];
	anim.initAnimSet[ "add_aim_up" ] = %shotgun_aim_8;
	anim.initAnimSet[ "add_aim_down" ] = %shotgun_aim_2;
	anim.initAnimSet[ "add_aim_left" ] = %shotgun_aim_4;
	anim.initAnimSet[ "add_aim_right" ] = %shotgun_aim_6;
	anim.initAnimSet[ "straight_level" ] = %shotgun_aim_5;
	
	anim.initAnimSet[ "fire" ] = %exposed_shoot_auto_v3;
	anim.initAnimSet[ "single" ] = array( %shotgun_stand_fire_1A, %shotgun_stand_fire_1B );

	set_animarray_burst_and_semi_fire_stand();
	
	anim.initAnimSet[ "exposed_idle" ] = array( %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 );

	anim.initAnimSet[ "reload" ] = array( %shotgun_stand_reload_A, %shotgun_stand_reload_B, %shotgun_stand_reload_C, %shotgun_stand_reload_C, %shotgun_stand_reload_C );// ( C is standing, want it more often )
	anim.initAnimSet[ "reload_crouchhide" ] = array( %shotgun_stand_reload_A, %shotgun_stand_reload_B );
	
	set_animarray_stance_change();
	set_animarray_standing_turns();
	set_animarray_add_turn_aims_stand();
	
	assert( !isdefined( anim.animsets.shotgunStand ) );
	anim.animsets.shotgunStand = anim.initAnimSet;
}

init_animset_cqb_stand()
{
	anim.initAnimSet = [];
	anim.initAnimSet[ "add_aim_up" ] = %CQB_stand_aim8;
	anim.initAnimSet[ "add_aim_down" ] = %CQB_stand_aim2;
	anim.initAnimSet[ "add_aim_left" ] = %CQB_stand_aim4;
	anim.initAnimSet[ "add_aim_right" ] = %CQB_stand_aim6;

	anim.initAnimSet[ "straight_level" ] = %CQB_stand_aim5;

	anim.initAnimSet[ "fire" ] = %exposed_shoot_auto_v3;
	anim.initAnimSet[ "single" ] = array( %exposed_shoot_semi1 );
	set_animarray_burst_and_semi_fire_stand();

	anim.initAnimSet[ "exposed_idle" ] = array( %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 );

	anim.initAnimSet[ "reload" ] = array( %CQB_stand_reload_steady );
	anim.initAnimSet[ "reload_crouchhide" ] = array( %CQB_stand_reload_knee );
	
	set_animarray_stance_change();
	set_animarray_standing_turns();
	set_animarray_add_turn_aims_stand();
	
	assert( !isdefined( anim.animsets.cqbStand ) );
	anim.animsets.cqbStand = anim.initAnimSet;
}

init_animset_heat_stand()
{
	anim.initAnimSet = [];
	anim.initAnimSet[ "add_aim_up" ] = %heat_stand_aim_8;
	anim.initAnimSet[ "add_aim_down" ] = %heat_stand_aim_2;
	anim.initAnimSet[ "add_aim_left" ] = %heat_stand_aim_4;
	anim.initAnimSet[ "add_aim_right" ] = %heat_stand_aim_6;

	anim.initAnimSet[ "straight_level" ] = %heat_stand_aim_5;

	anim.initAnimSet[ "fire" ] = %heat_stand_fire_auto;
	anim.initAnimSet[ "single" ] = array( %heat_stand_fire_single );
	animscripts\init_common::set_animarray_custom_burst_and_semi_fire_stand( %heat_stand_fire_burst );

	anim.initAnimSet[ "continuous" ] = array( %nx_tp_stand_exposed_stream_01 );

	anim.initAnimSet[ "exposed_idle" ] = array( %heat_stand_idle, /*%heat_stand_twitchA, %heat_stand_twitchB, %heat_stand_twitchC,*/ %heat_stand_scanA, %heat_stand_scanB );
	//heat_stand_scanA
	//heat_stand_scanB
	
	anim.initAnimSet[ "reload" ] = array( %heat_exposed_reload );
	anim.initAnimSet[ "reload_crouchhide" ] = array();
	
	set_animarray_stance_change();

	anim.initAnimSet[ "turn_left_45" ] = %heat_stand_turn_L;
	anim.initAnimSet[ "turn_left_90" ] = %heat_stand_turn_L;
	anim.initAnimSet[ "turn_left_135" ] = %heat_stand_turn_180;
	anim.initAnimSet[ "turn_left_180" ] = %heat_stand_turn_180;
	anim.initAnimSet[ "turn_right_45" ] = %heat_stand_turn_R;
	anim.initAnimSet[ "turn_right_90" ] = %heat_stand_turn_R;
	anim.initAnimSet[ "turn_right_135" ] = %heat_stand_turn_180;
	anim.initAnimSet[ "turn_right_180" ] = %heat_stand_turn_180;

	set_animarray_add_turn_aims_stand();
	
	assert( !isdefined( anim.animsets.heatStand ) );
	anim.animsets.heatStand = anim.initAnimSet;
}

init_animset_default_stand()
{
	anim.initAnimSet = [];
	anim.initAnimSet[ "add_aim_up" ] = %exposed_aim_8;
	anim.initAnimSet[ "add_aim_down" ] = %exposed_aim_2;
	anim.initAnimSet[ "add_aim_left" ] = %exposed_aim_4;
	anim.initAnimSet[ "add_aim_right" ] = %exposed_aim_6;

	anim.initAnimSet[ "straight_level" ] = %exposed_aim_5;

	anim.initAnimSet[ "fire" ] = %exposed_shoot_auto_v3;
	anim.initAnimSet[ "single" ] = array( %exposed_shoot_semi1 );
	set_animarray_burst_and_semi_fire_stand();

	anim.initAnimSet[ "exposed_idle" ] = array( %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 );
	anim.initAnimSet[ "exposed_grenade" ] = array( %exposed_grenadeThrowB, %exposed_grenadeThrowC );

	anim.initAnimSet[ "reload" ] = array( %exposed_reload );// %exposed_reloadb, %exposed_reloadc
	anim.initAnimSet[ "reload_crouchhide" ] = array( %exposed_reloadb );
	
	set_animarray_stance_change();
	set_animarray_standing_turns();
	set_animarray_add_turn_aims_stand();
	
	assert( !isdefined( anim.animsets.defaultStand ) );
	anim.animsets.defaultStand = anim.initAnimSet;
}


init_animset_default_crouch()
{
	anim.initAnimSet = [];
	anim.initAnimSet[ "add_aim_up" ] = %exposed_crouch_aim_8;
	anim.initAnimSet[ "add_aim_down" ] = %exposed_crouch_aim_2;
	anim.initAnimSet[ "add_aim_left" ] = %exposed_crouch_aim_4;
	anim.initAnimSet[ "add_aim_right" ] = %exposed_crouch_aim_6;
	anim.initAnimSet[ "straight_level" ] = %exposed_crouch_aim_5;

	anim.initAnimSet[ "fire" ] = %exposed_crouch_shoot_auto_v2;
	anim.initAnimSet[ "single" ] = array( %exposed_crouch_shoot_semi1 );
	set_animarray_burst_and_semi_fire_crouch();

	anim.initAnimSet[ "reload" ] = array( %exposed_crouch_reload );

	anim.initAnimSet[ "exposed_idle" ] = array( %exposed_crouch_idle_alert_v1, %exposed_crouch_idle_alert_v2, %exposed_crouch_idle_alert_v3 );
	
	set_animarray_stance_change();
	set_animarray_crouching_turns();
	set_animarray_add_turn_aims_crouch();	
	
	assert( !isdefined( anim.animsets.defaultCrouch ) );
	anim.animsets.defaultCrouch = anim.initAnimSet;
}	

init_animset_rpg_crouch()
{
	anim.initAnimSet = [];
	anim.initAnimSet[ "add_aim_up" ] = %RPG_crouch_aim_8;
	anim.initAnimSet[ "add_aim_down" ] = %RPG_crouch_aim_2;
	anim.initAnimSet[ "add_aim_left" ] = %RPG_crouch_aim_4;
	anim.initAnimSet[ "add_aim_right" ] = %RPG_crouch_aim_6;
	anim.initAnimSet[ "straight_level" ] = %RPG_crouch_aim_5;

	anim.initAnimSet[ "fire" ] = %RPG_crouch_fire;
	anim.initAnimSet[ "single" ] = array( %RPG_crouch_fire );

	anim.initAnimSet[ "reload" ] = array( %RPG_crouch_reload );

	anim.initAnimSet[ "exposed_idle" ] = array( %RPG_crouch_idle );
	
	set_animarray_stance_change();
	set_animarray_crouching_turns();
	set_animarray_add_turn_aims_crouch();	
	
	assert( !isdefined( anim.animsets.rpgCrouch ) );
	anim.animsets.rpgCrouch = anim.initAnimSet;
}	


init_animset_shotgun_crouch()
{
	anim.initAnimSet = [];
	anim.initAnimSet[ "add_aim_up" ] = %exposed_crouch_aim_8;
	anim.initAnimSet[ "add_aim_down" ] = %exposed_crouch_aim_2;
	anim.initAnimSet[ "add_aim_left" ] = %exposed_crouch_aim_4;
	anim.initAnimSet[ "add_aim_right" ] = %exposed_crouch_aim_6;
	anim.initAnimSet[ "straight_level" ] = %exposed_crouch_aim_5;

	anim.initAnimSet[ "fire" ] = %exposed_crouch_shoot_auto_v2;
	anim.initAnimSet[ "single" ] = array( %shotgun_crouch_fire );
	set_animarray_burst_and_semi_fire_crouch();

	anim.initAnimSet[ "reload" ] = array( %shotgun_crouch_reload );
	anim.initAnimSet[ "exposed_idle" ] = array( %exposed_crouch_idle_alert_v1, %exposed_crouch_idle_alert_v2, %exposed_crouch_idle_alert_v3 );

	set_animarray_stance_change();
	set_animarray_crouching_turns();
	set_animarray_add_turn_aims_crouch();	
	
	assert( !isdefined( anim.animsets.shotgunCrouch ) );
	anim.animsets.shotgunCrouch = anim.initAnimSet;
}	


init_animset_default_prone()
{
	anim.initAnimSet = [];
	anim.initAnimSet[ "add_aim_up" ] = %prone_aim_8_add;
	anim.initAnimSet[ "add_aim_down" ] = %prone_aim_2_add;
	anim.initAnimSet[ "add_aim_left" ] = %prone_aim_4_add;
	anim.initAnimSet[ "add_aim_right" ] = %prone_aim_6_add;

	anim.initAnimSet[ "straight_level" ] = %prone_aim_5;
	anim.initAnimSet[ "fire" ] = %prone_fire_1;

	anim.initAnimSet[ "single" ] = array( %prone_fire_1 );
	anim.initAnimSet[ "reload" ] = array( %prone_reload );

	anim.initAnimSet[ "continuous" ] = array( %nx_tp_stand_exposed_stream_01 );

	anim.initAnimSet[ "burst2" ] = %prone_fire_burst;
	anim.initAnimSet[ "burst3" ] = %prone_fire_burst;
	anim.initAnimSet[ "burst4" ] = %prone_fire_burst;
	anim.initAnimSet[ "burst5" ] = %prone_fire_burst;
	anim.initAnimSet[ "burst6" ] = %prone_fire_burst;

	anim.initAnimSet[ "semi2" ] = %prone_fire_burst;
	anim.initAnimSet[ "semi3" ] = %prone_fire_burst;
	anim.initAnimSet[ "semi4" ] = %prone_fire_burst;
	anim.initAnimSet[ "semi5" ] = %prone_fire_burst;

	anim.initAnimSet[ "exposed_idle" ] = array( %exposed_crouch_idle_alert_v1, %exposed_crouch_idle_alert_v2, %exposed_crouch_idle_alert_v3 );

	set_animarray_stance_change();

	assert( !isdefined( anim.animsets.defaultProne ) );
	anim.animsets.defaultProne = anim.initAnimSet;
}

init_animset_death()
{
	anim.initAnimSet = [];
	
	//special deaths
	anim.initAnimSet[ "cover_right_stand" ] = array( %corner_standr_deathA, %corner_standr_deathB );
	anim.initAnimSet[ "cover_right_crouch_head_neck" ] = array( %CornerCrR_alert_death_slideout );
	anim.initAnimSet[ "cover_right_crouch" ] = array( %CornerCrR_alert_death_slideout, %CornerCrR_alert_death_back );
	anim.initAnimSet[ "cover_left_stand" ] = array( %corner_standl_deathA, %corner_standl_deathB );
	anim.initAnimSet[ "cover_left_crouch" ] = array( %CornerCrL_death_side, %CornerCrL_death_back );
	anim.initAnimSet[ "cover_stand" ] = array( %coverstand_death_left, %coverstand_death_right );
	anim.initAnimSet[ "cover_crouch_head" ] = array( %covercrouch_death_1, %covercrouch_death_2 );
	anim.initAnimSet[ "cover_crouch_back" ] = array( %covercrouch_death_3, %covercrouch_death_2 );
	anim.initAnimSet[ "cover_crouch" ] = array( %covercrouch_death_2 );
	anim.initAnimSet[ "saw_stand" ] = array( %saw_gunner_death );
	anim.initAnimSet[ "saw_crouch" ] = array( %saw_gunner_lowwall_death );
	anim.initAnimSet[ "saw_prone" ] = array( %saw_gunner_prone_death );
	anim.initAnimSet[ "crawl_crouch" ] = array( %dying_back_death_v2, %dying_back_death_v3, %dying_back_death_v4);
	anim.initAnimSet[ "crawl_prone" ] = array( %dying_crawl_death_v1, %dying_crawl_death_v2 );
	
	//stong bullet deaths
	anim.initAnimSet[ "strong_leg_front" ] = array( %death_shotgun_legs, %death_stand_sniper_leg );
	anim.initAnimSet[ "strong_lower_torso_front" ] = array( %dying_crawl_death_v1, %dying_crawl_death_v2, %death_shotgun_back_v1, %exposed_death_blowback, %death_stand_sniper_chest1, %death_stand_sniper_chest2, %death_stand_sniper_spin1 );
	anim.initAnimSet[ "strong_torso_front" ] = array( %death_shotgun_back_v1, %exposed_death_blowback, %death_stand_sniper_chest1, %death_stand_sniper_chest2, %death_stand_sniper_spin1 );
	anim.initAnimSet[ "strong_left" ] = array( %death_shotgun_spinL, %death_stand_sniper_spin1, %death_stand_sniper_chest1, %death_stand_sniper_chest2 );
	anim.initAnimSet[ "strong_right" ] = array( %death_shotgun_spinR, %death_stand_sniper_spin2, %death_stand_sniper_chest1, %death_stand_sniper_chest2 );
	
	//running forward deaths
	anim.initAnimSet[ "running_forward" ] = array( %run_death_facedown, %run_death_roll, %run_death_fallonback, %run_death_flop );
	
	//stand pistol deaths
	anim.initAnimSet[ "stand_pistol_back" ] = %pistol_death_2;
	anim.initAnimSet[ "stand_pistol_legs" ] = %pistol_death_3;
	anim.initAnimSet[ "stand_pistol_chest" ] = %pistol_death_4;
	anim.initAnimSet[ "stand_pistol_head" ] = %pistol_death_1;
	
	//stand deaths
	anim.initAnimSet[ "stand_legs" ] = array( %exposed_death_groin, %stand_death_leg );
	anim.initAnimSet[ "stand_legs_extended" ] = array( %stand_death_crotch, %stand_death_guts );
	anim.initAnimSet[ "stand_head" ] = array( %exposed_death_headshot, %exposed_death_flop );
	anim.initAnimSet[ "stand_neck" ] = array( %exposed_death_neckgrab );
	anim.initAnimSet[ "stand_upper_torso" ] = array( %exposed_death_twist, %stand_death_shoulder_spin, %stand_death_shoulderback, %stand_death_tumbleforward, %stand_death_stumbleforward );
	anim.initAnimSet[ "stand_upper_torso_extended" ] = array( %stand_death_fallside );
	anim.initAnimSet[ "stand_upper_left" ] = array( %exposed_death_twist, %stand_death_shoulder_spin, %stand_death_shoulderback );
	anim.initAnimSet[ "stand_front_head" ] = array( %stand_death_face, %stand_death_headshot_slowfall );
	anim.initAnimSet[ "stand_front_head_extended" ] = array( %stand_death_head_straight_back );
	anim.initAnimSet[ "stand_front_torso" ] = array( %stand_death_tumbleback );
	anim.initAnimSet[ "stand_front_torso_extended" ] = array( %stand_death_chest_stunned );
	anim.initAnimSet[ "stand_back" ] = array( %exposed_death_falltoknees, %exposed_death_falltoknees_02 );
	anim.initAnimSet[ "stand_firing" ] = array( %exposed_death_firing_02, %exposed_death_firing );
	anim.initAnimSet[ "stand_generic" ] = array( %exposed_death_02, %exposed_death_nerve );
	anim.initAnimSet[ "stand_exposed" ] = array( %exposed_death );
		
	//crouch deaths
	anim.initAnimSet[ "crouch_head" ] = %exposed_crouch_death_fetal;
	anim.initAnimSet[ "crouch_torso" ] = %exposed_crouch_death_flip;
	anim.initAnimSet[ "crouch_twist" ] = %exposed_crouch_death_twist;
	anim.initAnimSet[ "crouch_generic" ] = %exposed_crouch_death_flip;
	
	//prone
	anim.initAnimSet[ "prone_aiming" ] = %prone_death_quickdeath;
	anim.initAnimSet[ "prone" ] = %dying_crawl_death_v1;
	
	//back
	anim.initAnimSet[ "back" ] = array( %dying_back_death_v1, %dying_back_death_v2, %dying_back_death_v3, %dying_back_death_v4 );
	
	//explosions!
	anim.initAnimSet[ "explode_stand_front" ] = array(%death_explosion_stand_B_v1, %death_explosion_stand_B_v2, %death_explosion_stand_B_v3, %death_explosion_stand_B_v4 ); 
	anim.initAnimSet[ "explode_stand_right" ] = array(%death_explosion_stand_L_v1, %death_explosion_stand_L_v2, %death_explosion_stand_L_v3 ); 
	anim.initAnimSet[ "explode_stand_left" ] = array(%death_explosion_stand_R_v1, %death_explosion_stand_R_v2 ); 
	anim.initAnimSet[ "explode_stand_back" ] = array(%death_explosion_stand_F_v1, %death_explosion_stand_F_v2, %death_explosion_stand_F_v3, %death_explosion_stand_F_v4 ); 
	anim.initAnimSet[ "explode_run_front" ] = array(%death_explosion_run_B_v1, %death_explosion_run_B_v2 ); 
	anim.initAnimSet[ "explode_run_right" ] = array(%death_explosion_run_L_v1, %death_explosion_run_L_v2 ); 
	anim.initAnimSet[ "explode_run_left" ] = array(%death_explosion_run_R_v1, %death_explosion_run_R_v2 ); 
	anim.initAnimSet[ "explode_run_back" ] = array(%death_explosion_run_F_v1, %death_explosion_run_F_v2, %death_explosion_run_F_v3, %death_explosion_run_F_v4 ); 
	
	
	assert( !isdefined( anim.animsets.deathAnimSet ) );
	anim.animsets.deathAnimSet = anim.initAnimSet;
}

init_animset_pain()
{
	anim.initAnimSet = [];
	
	//special pain
	anim.initAnimSet[ "shield" ] = array( %stand_exposed_extendedpain_chest, %stand_exposed_extendedpain_head_2_crouch, %stand_exposed_extendedpain_hip_2_crouch );
	anim.initAnimSet[ "cover_left_stand" ] = array( %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE );
	anim.initAnimSet[ "cover_left_crouch" ] = array( %CornerCrL_painB );
	anim.initAnimSet[ "cover_right_stand" ] = array( %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE );
	anim.initAnimSet[ "cover_right_crouch" ] = array( %CornerCrR_alert_painA, %CornerCrR_alert_painC );
	anim.initAnimSet[ "cover_right_stand_B" ] = array( %corner_standR_pain_B_2_alert );
	anim.initAnimSet[ "cover_left_stand_A" ] = array( %corner_standL_pain_A_2_alert );
	anim.initAnimSet[ "cover_left_stand_B" ] = array( %corner_standL_pain_B_2_alert );
	anim.initAnimSet[ "cover_crouch" ] = array( %covercrouch_pain_right, %covercrouch_pain_front, %covercrouch_pain_left_3 );
	anim.initAnimSet[ "cover_stand" ] = array( %coverstand_pain_groin, %coverstand_pain_leg );
	anim.initAnimSet[ "cover_stand_aim" ] = array( %coverstand_pain_aim_2_hide_01, %coverstand_pain_aim_2_hide_02 );
	anim.initAnimSet[ "cover_crouch_aim" ] = array( %covercrouch_pain_aim_2_hide_01 );
	anim.initAnimSet[ "saw_stand" ] = %saw_gunner_pain;
	anim.initAnimSet[ "saw_crouch" ] = %saw_gunner_lowwall_pain_02;
	anim.initAnimSet[ "saw_prone" ] = %saw_gunner_prone_pain;


	//run pains
	anim.initAnimSet[ "long_run" ] = array( %run_pain_leg, %run_pain_shoulder, %run_pain_stomach_stumble, %run_pain_head );
	anim.initAnimSet[ "med_run" ] = array( %run_pain_fallonknee_02, %run_pain_stomach, %run_pain_stumble, %run_pain_stomach_fast, %run_pain_leg_fast, %run_pain_fall );
	anim.initAnimSet[ "short_run" ] = array( %run_pain_fallonknee, %run_pain_fallonknee_03 );
	
	//pistol pain
	anim.initAnimSet[ "pistol_torso" ] = %pistol_stand_pain_chest;
	anim.initAnimSet[ "pistol_legs" ] = %pistol_stand_pain_groin;
	anim.initAnimSet[ "pistol_head" ] = %pistol_stand_pain_head;
	anim.initAnimSet[ "pistol_left_arm" ] = %pistol_stand_pain_leftshoulder;
	anim.initAnimSet[ "pistol_right_arm" ] = %pistol_stand_pain_rightshoulder;
	
	//stand pain
	anim.initAnimSet[ "stand_torso_extended" ] = array( %stand_exposed_extendedpain_gut, %stand_exposed_extendedpain_stomach );
	anim.initAnimSet[ "stand_head" ] = array( %exposed_pain_face, %stand_exposed_extendedpain_neck );
	anim.initAnimSet[ "stand_head_extended" ] = array( %stand_exposed_extendedpain_head_2_crouch );
	anim.initAnimSet[ "stand_right_arm" ] = array( %exposed_pain_right_arm );
	anim.initAnimSet[ "stand_left_arm" ] = array( %stand_exposed_extendedpain_shoulderswing );
	anim.initAnimSet[ "stand_left_arm_extended" ] = array( %stand_exposed_extendedpain_shoulder_2_crouch );
	anim.initAnimSet[ "stand_legs" ] = array( %exposed_pain_groin, %stand_exposed_extendedpain_hip );
	anim.initAnimSet[ "stand_legs_extended" ] = array( %stand_exposed_extendedpain_hip_2_crouch, %stand_exposed_extendedpain_feet_2_crouch, %stand_exposed_extendedpain_stomach );
	anim.initAnimSet[ "stand_feet" ] = array( %stand_exposed_extendedpain_thigh );
	anim.initAnimSet[ "stand_feet_extended" ] = array( %stand_exposed_extendedpain_feet_2_crouch );
	anim.initAnimSet[ "stand_generic_long_death" ] = array( %exposed_pain_2_crouch, %stand_extendedpainB );
	anim.initAnimSet[ "stand_generic" ] = array( %exposed_pain_right_arm, %exposed_pain_face, %exposed_pain_groin );
	anim.initAnimSet[ "stand_generic_extended" ] = array( %stand_extendedpainC, %stand_exposed_extendedpain_chest );
	
	//crouch pain
	anim.initAnimSet[ "crouch_generic" ] = array( %exposed_crouch_extendedpainA );
	anim.initAnimSet[ "crouch_exposed" ] = array( %exposed_crouch_pain_chest, %exposed_crouch_pain_headsnap, %exposed_crouch_pain_flinch );
	anim.initAnimSet[ "crouch_left_arm" ] = array( %exposed_crouch_pain_left_arm );
	anim.initAnimSet[ "crouch_right_arm" ] = array( %exposed_crouch_pain_right_arm );
	
	//prone pain
	anim.initAnimSet[ "prone" ] = array( %prone_reaction_A, %prone_reaction_B );
	
	anim.initAnimSet[ "crawl_trans_stand" ] = array( %dying_stand_2_back_v1, %dying_stand_2_back_v2 );
	anim.initAnimSet[ "crawl_trans_crouch" ] = array( %dying_crouch_2_back );
	anim.initAnimSet[ "crawl_trans_prone" ] = array( %dying_crawl_2_back );
	
	//pistol crawl
	anim.initAnimSet[ "stand_2_crawl" ] = array( %dying_stand_2_crawl_v1, %dying_stand_2_crawl_v2, %dying_stand_2_crawl_v3 );
	anim.initAnimSet[ "crouch_2_crawl" ] = array( %dying_crouch_2_crawl );
	anim.initAnimSet[ "crawl" ] = %dying_crawl;
	anim.initAnimSet[ "death" ] = array( %dying_crawl_death_v1, %dying_crawl_death_v2 );
	anim.initAnimSet[ "back_idle" ] = %dying_back_idle;
	anim.initAnimSet[ "back_idle_twitch" ] = array( %dying_back_twitch_A, %dying_back_twitch_B );
	anim.initAnimSet[ "back_crawl" ] = %dying_crawl_back;
	anim.initAnimSet[ "back_fire" ] = %dying_back_fire;
	anim.initAnimSet[ "back_death" ] = array( %dying_back_death_v1, %dying_back_death_v2, %dying_back_death_v3 );
	
	//additive pain
	anim.initAnimSet[ "add_generic" ] = array( %pain_add_standing_belly, %pain_add_standing_left_arm, %pain_add_standing_right_arm );
	anim.initAnimSet[ "add_left_arm" ] = array( %pain_add_standing_left_arm );
	anim.initAnimSet[ "add_right_arm" ] = array( %pain_add_standing_right_arm );
	anim.initAnimSet[ "add_left_leg" ] = array( %pain_add_standing_left_leg );
	anim.initAnimSet[ "add_right_leg" ] = array( %pain_add_standing_right_leg );
	
	anim.initAnimSet[ "dying_back_aim_left" ] = %dying_back_aim_4;
	anim.initAnimSet[ "dying_back_aim_right" ] = %dying_back_aim_6;
	
	//anim.initAnimSet[ "taser_stand" ] = array( %tp_moon_react_tased_stand_opfor_01 );
	//anim.initAnimSet[ "taser_crouch" ] = array( %tp_moon_react_tased_crouch_opfor_01 );
	//anim.initAnimSet[ "taser_stand_ally" ] = array( %tp_moon_react_tased_stand_ally_01 );
	//anim.initAnimSet[ "taser_crouch_ally" ] = array( %tp_moon_react_tased_crouch_ally_01 );
	
	assert( !isdefined( anim.animsets.painAnimSet ) );
	anim.animsets.painAnimSet = anim.initAnimSet;
}

init_animset_gib()
{
	anim.initAnimSet = [];
	
	//TEMP
	anim.initAnimSet[ "gib_right_arm_front_start" ] = array( %stand_exposed_extendedpain_chest, %stand_exposed_extendedpain_head_2_crouch, %stand_exposed_extendedpain_hip_2_crouch );
	anim.initAnimSet[ "gib_right_arm_back_start" ] = array( %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE );
	anim.initAnimSet[ "gib_right_arm_front_loop" ] = array( %stand_exposed_extendedpain_chest, %stand_exposed_extendedpain_head_2_crouch, %stand_exposed_extendedpain_hip_2_crouch );
	anim.initAnimSet[ "gib_right_arm_back_loop" ] = array( %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE );
	anim.initAnimSet[ "gib_right_arm_front_end" ] = array( %stand_exposed_extendedpain_chest, %stand_exposed_extendedpain_head_2_crouch, %stand_exposed_extendedpain_hip_2_crouch );
	anim.initAnimSet[ "gib_right_arm_back_end" ] = array( %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE );
	
	anim.initAnimSet[ "gib_left_arm_front_start" ] = array( %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE );
	anim.initAnimSet[ "gib_left_arm_back_start" ] = array( %CornerCrR_alert_painA, %CornerCrR_alert_painC );
	anim.initAnimSet[ "gib_left_arm_front_loop" ] = array( %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE );
	anim.initAnimSet[ "gib_left_arm_back_loop" ] = array( %CornerCrR_alert_painA, %CornerCrR_alert_painC );
	anim.initAnimSet[ "gib_left_arm_front_end" ] = array( %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE );
	anim.initAnimSet[ "gib_left_arm_back_end" ] = array( %CornerCrR_alert_painA, %CornerCrR_alert_painC );
	
	anim.initAnimSet[ "gib_right_leg_front_start" ] = array( %stand_exposed_extendedpain_chest, %stand_exposed_extendedpain_head_2_crouch, %stand_exposed_extendedpain_hip_2_crouch );
	anim.initAnimSet[ "gib_right_leg_back_start" ] = array( %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE );
	anim.initAnimSet[ "gib_right_leg_front_loop" ] = array( %stand_exposed_extendedpain_chest, %stand_exposed_extendedpain_head_2_crouch, %stand_exposed_extendedpain_hip_2_crouch );
	anim.initAnimSet[ "gib_right_leg_back_loop" ] = array( %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE );
	anim.initAnimSet[ "gib_right_leg_front_end" ] = array( %stand_exposed_extendedpain_chest, %stand_exposed_extendedpain_head_2_crouch, %stand_exposed_extendedpain_hip_2_crouch );
	anim.initAnimSet[ "gib_right_leg_back_end" ] = array( %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE );
	
	anim.initAnimSet[ "gib_left_leg_front_start" ] = array( %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE );
	anim.initAnimSet[ "gib_left_leg_back_start" ] = array( %CornerCrR_alert_painA, %CornerCrR_alert_painC );
	anim.initAnimSet[ "gib_left_leg_front_loop" ] = array( %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE );
	anim.initAnimSet[ "gib_left_leg_back_loop" ] = array( %CornerCrR_alert_painA, %CornerCrR_alert_painC );
	anim.initAnimSet[ "gib_left_leg_front_end" ] = array( %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE );
	anim.initAnimSet[ "gib_left_leg_back_end" ] = array( %CornerCrR_alert_painA, %CornerCrR_alert_painC );
	
	anim.initAnimSet[ "gib_no_legs_start" ] = array( %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE );
	anim.initAnimSet[ "gib_no_legs_loop" ] = array( %CornerCrR_alert_painA, %CornerCrR_alert_painC );
	anim.initAnimSet[ "gib_no_legs_end" ] = array( %corner_standl_painB, %corner_standl_painC, %corner_standl_painD, %corner_standl_painE );

	anim.initAnimSet[ "gib_shoulder_back" ] = %stand_death_shoulderback;
	anim.initAnimSet[ "gib_shoulder_spin" ]  = %stand_death_shoulder_spin;
	anim.initAnimSet[ "gib_shoulder_twist" ]  = %exposed_death_twist;
	
	assert( !isdefined( anim.animsets.gibAnimSet ) );
	anim.animsets.gibAnimSet = anim.initAnimSet;
}

init_animset_crouch_wall()
{
	anim.initAnimSet = [];
	
	anim.initAnimSet[ "hide_idle" ] = %covercrouch_hide_idle;
	anim.initAnimSet[ "hide_idle_twitch" ] = array(
		%covercrouch_twitch_1,
		%covercrouch_twitch_2,
		%covercrouch_twitch_3,
		%covercrouch_twitch_4
	 );

	anim.initAnimSet[ "hide_idle_flinch" ] = array();

	anim.initAnimSet[ "hide_2_crouch" ] = %covercrouch_hide_2_aim;
	anim.initAnimSet[ "hide_2_stand" ] = %covercrouch_hide_2_stand;
	anim.initAnimSet[ "hide_2_lean" ] = %covercrouch_hide_2_lean;
	anim.initAnimSet[ "hide_2_right" ] = %covercrouch_hide_2_right;
	anim.initAnimSet[ "hide_2_left" ] = %covercrouch_hide_2_left;

	anim.initAnimSet[ "crouch_2_hide" ] = %covercrouch_aim_2_hide;
	anim.initAnimSet[ "stand_2_hide" ] = %covercrouch_stand_2_hide;
	anim.initAnimSet[ "lean_2_hide" ] = %covercrouch_lean_2_hide;
	anim.initAnimSet[ "right_2_hide" ] = %covercrouch_right_2_hide;
	anim.initAnimSet[ "left_2_hide" ] = %covercrouch_left_2_hide;


	anim.initAnimSet[ "crouch_aim" ] = %covercrouch_aim5;
	anim.initAnimSet[ "stand_aim" ] = %exposed_aim_5;
	anim.initAnimSet[ "lean_aim" ] = %covercrouch_lean_aim5;

	anim.initAnimSet[ "fire" ] = %exposed_shoot_auto_v2;
	anim.initAnimSet[ "semi2" ] = %exposed_shoot_semi2;
	anim.initAnimSet[ "semi3" ] = %exposed_shoot_semi3;
	anim.initAnimSet[ "semi4" ] = %exposed_shoot_semi4;
	anim.initAnimSet[ "semi5" ] = %exposed_shoot_semi5;

	anim.initAnimSet[ "burst2" ] = %exposed_shoot_burst3;// ( will be limited to 2 shots )
	anim.initAnimSet[ "burst3" ] = %exposed_shoot_burst3;
	anim.initAnimSet[ "burst4" ] = %exposed_shoot_burst4;
	anim.initAnimSet[ "burst5" ] = %exposed_shoot_burst5;
	anim.initAnimSet[ "burst6" ] = %exposed_shoot_burst6;

	anim.initAnimSet[ "continuous" ] = array( %nx_tp_stand_exposed_stream_01 );

	anim.initAnimSet[ "blind_fire" ] = array( %covercrouch_blindfire_1, %covercrouch_blindfire_2, %covercrouch_blindfire_3, %covercrouch_blindfire_4 );

	anim.initAnimSet[ "reload" ] = %covercrouch_reload_hide;

	anim.initAnimSet[ "grenade_safe" ] = array( %covercrouch_grenadeA, %covercrouch_grenadeB );
	anim.initAnimSet[ "grenade_exposed" ] = array( %covercrouch_grenadeA, %covercrouch_grenadeB );

	anim.initAnimSet[ "exposed_idle" ] = array( %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 );

	anim.initAnimSet[ "look" ] = array( %covercrouch_hide_look );
	
	anim.initAnimSet[ "shotgun_lean_single" ] = array( %shotgun_stand_fire_1A );
	anim.initAnimSet[ "shotgun_over_single" ] = array( %shotgun_crouch_fire );
	anim.initAnimSet[ "normal_single" ] = array( %exposed_shoot_semi1 );

	assert( !isdefined( anim.animsets.crouchWallAnimSet ) );
	anim.animsets.crouchWallAnimSet = anim.initAnimSet;
}

init_animset_stand_wall()
{
	anim.initAnimSet = [];

	anim.initAnimSet[ "hide_idle" ] = %coverstand_hide_idle;
	anim.initAnimSet[ "hide_idle_twitch" ] = array(
		%coverstand_hide_idle_twitch01,
		%coverstand_hide_idle_twitch02,
		%coverstand_hide_idle_twitch03,
		%coverstand_hide_idle_twitch04,
		%coverstand_hide_idle_twitch05
	 );

	anim.initAnimSet[ "hide_idle_flinch" ] = array(
		%coverstand_react01,
		%coverstand_react02,
		%coverstand_react03,
		%coverstand_react04
	 );

	anim.initAnimSet[ "hide_2_stand" ] = %coverstand_hide_2_aim;
	anim.initAnimSet[ "stand_2_hide" ] = %coverstand_aim_2_hide;

	anim.initAnimSet[ "hide_2_over" ] = %coverstand_2_coverstandaim;
	anim.initAnimSet[ "over_2_hide" ] = %coverstandaim_2_coverstand;

	anim.initAnimSet[ "over_aim" ] = %coverstandaim_aim5;

	anim.initAnimSet[ "over_fire" ] = %coverstandaim_autofire;
	anim.initAnimSet[ "over_semi2" ] = %coverstandaim_fire;
	anim.initAnimSet[ "over_semi3" ] = %coverstandaim_fire;
	anim.initAnimSet[ "over_semi4" ] = %coverstandaim_fire;
	anim.initAnimSet[ "over_semi5" ] = %coverstandaim_fire;

	anim.initAnimSet[ "over_single" ] = array( %coverstandaim_fire );

	anim.initAnimSet[ "over_burst2" ] = %coverstandaim_autofire;// ( will be limited to 2 shots )
	anim.initAnimSet[ "over_burst3" ] = %coverstandaim_autofire;
	anim.initAnimSet[ "over_burst4" ] = %coverstandaim_autofire;
	anim.initAnimSet[ "over_burst5" ] = %coverstandaim_autofire;
	anim.initAnimSet[ "over_burst6" ] = %coverstandaim_autofire;

	anim.initAnimSet[ "over_continuous" ] = array( %nx_tp_stand_exposed_stream_01 );

	anim.initAnimSet[ "stand_aim" ] = %exposed_aim_5;

	anim.initAnimSet[ "stand_fire" ] = %exposed_shoot_auto_v2;
	anim.initAnimSet[ "stand_semi2" ] = %exposed_shoot_semi2;
	anim.initAnimSet[ "stand_semi3" ] = %exposed_shoot_semi3;
	anim.initAnimSet[ "stand_semi4" ] = %exposed_shoot_semi4;
	anim.initAnimSet[ "stand_semi5" ] = %exposed_shoot_semi5;

	anim.initAnimSet[ "stand_shotgun_single" ] = array( %shotgun_stand_fire_1A );
	anim.initAnimSet[ "stand_normal_single" ] = array( %exposed_shoot_semi1 );

	anim.initAnimSet[ "stand_burst2" ] = %exposed_shoot_burst3;// ( will be limited to 2 shots )
	anim.initAnimSet[ "stand_burst3" ] = %exposed_shoot_burst3;
	anim.initAnimSet[ "stand_burst4" ] = %exposed_shoot_burst4;
	anim.initAnimSet[ "stand_burst5" ] = %exposed_shoot_burst5;
	anim.initAnimSet[ "stand_burst6" ] = %exposed_shoot_burst6;

	anim.initAnimSet[ "stand_continuous" ] = array( %nx_tp_stand_exposed_stream_01 );

	anim.initAnimSet["blind_fire"] = array( %coverstand_blindfire_1, %coverstand_blindfire_2 ); // #3 looks silly

	anim.initAnimSet[ "reload" ] = %coverstand_reloadA;

	anim.initAnimSet[ "look" ] = array( %coverstand_look_quick, %coverstand_look_quick_v2 );

	anim.initAnimSet[ "grenade_safe" ] = array( %coverstand_grenadeA, %coverstand_grenadeB );
	anim.initAnimSet[ "grenade_exposed" ] = array( %coverstand_grenadeA, %coverstand_grenadeB );

	anim.initAnimSet[ "exposed_idle" ] = array( %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 );

	anim.initAnimSet[ "hide_to_look" ] = %coverstand_look_moveup;
	anim.initAnimSet[ "look_idle" ] = %coverstand_look_idle;
	anim.initAnimSet[ "look_to_hide" ] = %coverstand_look_movedown;
	anim.initAnimSet[ "look_to_hide_fast" ] = %coverstand_look_movedown_fast;
	
	assert( !isdefined( anim.animsets.standWallAnimSet ) );
	anim.animsets.standWallAnimSet = anim.initAnimSet;
}

init_animset_custom_crouch( fireAnim, idleAnim, reloadAnim )
{
	assert( isdefined( anim.animsets ) && isdefined( anim.animsets.defaultCrouch ) );
	
	anim.initAnimSet = anim.animsets.defaultCrouch;

	if ( isdefined( fireAnim ) )
	{
		anim.initAnimSet[ "fire" ] = fireAnim;
		anim.initAnimSet[ "single" ] = array( fireAnim );
		set_animarray_custom_burst_and_semi_fire_crouch( fireAnim );
	}

	if ( isdefined( idleAnim ) )
		anim.initAnimSet[ "exposed_idle" ] = array( idleAnim );

	if ( isdefined( reloadAnim ) )
		anim.initAnimSet[ "reload" ] = array( reloadAnim );

	self.combatCrouchAnims = anim.initAnimSet;
}	


////////////////////////////////////////////
// Helpers for the above init_*
////////////////////////////////////////////

set_animarray_standing_turns_pistol( animArray )
{
	anim.initAnimSet[ "turn_left_45" ] = %pistol_stand_turn45L;
	anim.initAnimSet[ "turn_left_90" ] = %pistol_stand_turn90L;
	anim.initAnimSet[ "turn_left_135" ] = %pistol_stand_turn90L;
	anim.initAnimSet[ "turn_left_180" ] = %pistol_stand_turn180L;
	anim.initAnimSet[ "turn_right_45" ] = %pistol_stand_turn45R;
	anim.initAnimSet[ "turn_right_90" ] = %pistol_stand_turn90R;
	anim.initAnimSet[ "turn_right_135" ] = %pistol_stand_turn90R;
	anim.initAnimSet[ "turn_right_180" ] = %pistol_stand_turn180L;
}

set_animarray_standing_turns()
{
	anim.initAnimSet[ "turn_left_45" ] = %exposed_tracking_turn45L;
	anim.initAnimSet[ "turn_left_90" ] = %exposed_tracking_turn90L;
	anim.initAnimSet[ "turn_left_135" ] = %exposed_tracking_turn135L;
	anim.initAnimSet[ "turn_left_180" ] = %exposed_tracking_turn180L;
	anim.initAnimSet[ "turn_right_45" ] = %exposed_tracking_turn45R;
	anim.initAnimSet[ "turn_right_90" ] = %exposed_tracking_turn90R;
	anim.initAnimSet[ "turn_right_135" ] = %exposed_tracking_turn135R;
	anim.initAnimSet[ "turn_right_180" ] = %exposed_tracking_turn180R;
}

set_animarray_crouching_turns()
{
	anim.initAnimSet[ "turn_left_45" ] = %exposed_crouch_turn_90_left;
	anim.initAnimSet[ "turn_left_90" ] = %exposed_crouch_turn_90_left;
	anim.initAnimSet[ "turn_left_135" ] = %exposed_crouch_turn_180_left;
	anim.initAnimSet[ "turn_left_180" ] = %exposed_crouch_turn_180_left;
	anim.initAnimSet[ "turn_right_45" ] = %exposed_crouch_turn_90_right;
	anim.initAnimSet[ "turn_right_90" ] = %exposed_crouch_turn_90_right;
	anim.initAnimSet[ "turn_right_135" ] = %exposed_crouch_turn_180_right;
	anim.initAnimSet[ "turn_right_180" ] = %exposed_crouch_turn_180_right;
}


set_animarray_stance_change()
{
	anim.initAnimSet[ "crouch_2_stand" ] = %exposed_crouch_2_stand;
	anim.initAnimSet[ "crouch_2_prone" ] = %crouch_2_prone;
	anim.initAnimSet[ "stand_2_crouch" ] = %exposed_stand_2_crouch;
	anim.initAnimSet[ "stand_2_prone" ] = %stand_2_prone;
	anim.initAnimSet[ "prone_2_crouch" ] = %prone_2_crouch;
	anim.initAnimSet[ "prone_2_stand" ] = %prone_2_stand;
}

set_animarray_burst_and_semi_fire_stand()
{
	anim.initAnimSet[ "burst2" ] = %exposed_shoot_burst3;// ( will be stopped after second bullet )
	anim.initAnimSet[ "burst3" ] = %exposed_shoot_burst3;
	anim.initAnimSet[ "burst4" ] = %exposed_shoot_burst4;
	anim.initAnimSet[ "burst5" ] = %exposed_shoot_burst5;
	anim.initAnimSet[ "burst6" ] = %exposed_shoot_burst6;

	anim.initAnimSet[ "semi2" ] = %exposed_shoot_semi2;
	anim.initAnimSet[ "semi3" ] = %exposed_shoot_semi3;
	anim.initAnimSet[ "semi4" ] = %exposed_shoot_semi4;
	anim.initAnimSet[ "semi5" ] = %exposed_shoot_semi5;

	anim.initAnimSet[ "continuous" ] = array( %nx_tp_stand_exposed_stream_01 );
}


set_animarray_burst_and_semi_fire_crouch()
{
	anim.initAnimSet[ "burst2" ] = %exposed_crouch_shoot_burst3;
	anim.initAnimSet[ "burst3" ] = %exposed_crouch_shoot_burst3;
	anim.initAnimSet[ "burst4" ] = %exposed_crouch_shoot_burst4;
	anim.initAnimSet[ "burst5" ] = %exposed_crouch_shoot_burst5;
	anim.initAnimSet[ "burst6" ] = %exposed_crouch_shoot_burst6;

	anim.initAnimSet[ "semi2" ] = %exposed_crouch_shoot_semi2;
	anim.initAnimSet[ "semi3" ] = %exposed_crouch_shoot_semi3;
	anim.initAnimSet[ "semi4" ] = %exposed_crouch_shoot_semi4;
	anim.initAnimSet[ "semi5" ] = %exposed_crouch_shoot_semi5;

	anim.initAnimSet[ "continuous" ] = array( %nx_tp_stand_exposed_stream_01 );
}

set_animarray_custom_burst_and_semi_fire_crouch( fireAnim )
{
	anim.initAnimSet[ "burst2" ] = fireAnim;
	anim.initAnimSet[ "burst3" ] = fireAnim;
	anim.initAnimSet[ "burst4" ] = fireAnim;
	anim.initAnimSet[ "burst5" ] = fireAnim;
	anim.initAnimSet[ "burst6" ] = fireAnim;

	anim.initAnimSet[ "semi2" ] = fireAnim;
	anim.initAnimSet[ "semi3" ] = fireAnim;
	anim.initAnimSet[ "semi4" ] = fireAnim;
	anim.initAnimSet[ "semi5" ] = fireAnim;
}


set_animarray_add_turn_aims_stand()
{
	anim.initAnimSet[ "add_turn_aim_up" ] = %exposed_turn_aim_8;
	anim.initAnimSet[ "add_turn_aim_down" ] = %exposed_turn_aim_2;
	anim.initAnimSet[ "add_turn_aim_left" ] = %exposed_turn_aim_4;
	anim.initAnimSet[ "add_turn_aim_right" ] = %exposed_turn_aim_6;
}

set_animarray_add_turn_aims_crouch()
{
	anim.initAnimSet[ "add_turn_aim_up" ] = %exposed_crouch_turn_aim_8;
	anim.initAnimSet[ "add_turn_aim_down" ] = %exposed_crouch_turn_aim_2;
	anim.initAnimSet[ "add_turn_aim_left" ] = %exposed_crouch_turn_aim_4;
	anim.initAnimSet[ "add_turn_aim_right" ] = %exposed_crouch_turn_aim_6;
}


////////////////////////////////////////////
// Moving turn
////////////////////////////////////////////

init_moving_turn_animations()
{
	anim.runTurnAnims[ "L90" ] 	= %run_turn_L90;
	anim.runTurnAnims[ "R90" ] 	= %run_turn_R90;
	anim.runTurnAnims[ "L45" ] 	= %run_turn_L45;
	anim.runTurnAnims[ "R45" ] 	= %run_turn_R45;
	anim.runTurnAnims[ "L135" ] = %run_turn_L135;
	anim.runTurnAnims[ "R135" ] = %run_turn_R135;
	anim.runTurnAnims[ "180" ] 	= %run_turn_180;

	anim.cqbTurnAnims[ "L90" ] 	= %CQB_walk_turn_4;
	anim.cqbTurnAnims[ "R90" ] 	= %CQB_walk_turn_6;
	anim.cqbTurnAnims[ "L45" ] 	= %CQB_walk_turn_7;
	anim.cqbTurnAnims[ "R45" ] 	= %CQB_walk_turn_9;
	anim.cqbTurnAnims[ "L135" ] = %CQB_walk_turn_1;
	anim.cqbTurnAnims[ "R135" ] = %CQB_walk_turn_3;
	anim.cqbTurnAnims[ "180" ] 	= %CQB_walk_turn_2;
}


////////////////////////////////////////////
// Misc
////////////////////////////////////////////

init_animset_run_n_gun()
{
	anim.runNGunAnims[ "F" ] = %run_n_gun_F;
	anim.runNGunAnims[ "L" ] = %run_n_gun_L;
	anim.runNGunAnims[ "R" ] = %run_n_gun_R;
	anim.runNGunAnims[ "LB" ] = %run_n_gun_L_120;
	anim.runNGunAnims[ "RB" ] = %run_n_gun_R_120;
}


init_ambush_sidestep_anims()
{
	anim.moveAnimSet[ "move_l" ] = %combatwalk_L;
	anim.moveAnimSet[ "move_r" ] = %combatwalk_R;
	anim.moveAnimSet[ "move_b" ] = %combatwalk_B;
}

init_heat_reload_function()
{
	anim.heat_reload_anim_func = ::heat_reload_anim;
}

heat_reload_anim()
{
	if ( self.weapon != self.primaryweapon )
		return animArrayPickRandom( "reload" );
		
	if ( isdefined( self.node ) )
	{
		if ( self nearClaimNodeAndAngle() )
		{
			coverReloadAnim = undefined;
			if ( self.node.type == "Cover Left" )
				coverReloadAnim = %heat_cover_reload_R;
			else if ( self.node.type == "Cover Right" )
				coverReloadAnim = %heat_cover_reload_L;
				
			if ( isdefined( coverReloadAnim ) )
			{
				//self mayMoveToPoint( reloadAnimPos );
				return coverReloadAnim;
			}
		}
	}
	
	return %heat_exposed_reload;
}

init_animarray_standing_left() /* void */ 
{
	array = [];

	array[ "alert_idle" ] = %corner_standL_alert_idle;
	array[ "alert_idle_twitch" ] = [
		%corner_standL_alert_twitch01,
		%corner_standL_alert_twitch02,
		%corner_standL_alert_twitch03,
		%corner_standL_alert_twitch04,
		%corner_standL_alert_twitch05,
		%corner_standL_alert_twitch06,
		%corner_standL_alert_twitch07
	 ];
	array[ "alert_idle_flinch" ] = [ %corner_standL_flinch ];

	array[ "alert_to_A" ] = [ %corner_standL_trans_alert_2_A ];
	array[ "alert_to_B" ] = [ %corner_standL_trans_alert_2_B_v2 ];
	array[ "A_to_alert" ] = [ %corner_standL_trans_A_2_alert_v2 ];
	array[ "A_to_alert_reload" ] = [];
	array[ "A_to_B" ] = [ %corner_standL_trans_A_2_B_v2 ];
	array[ "B_to_alert" ] = [ %corner_standL_trans_B_2_alert_v2 ];
	array[ "B_to_alert_reload" ] = [ %corner_standL_reload_B_2_alert ];
 	array[ "B_to_A" ] = [ %corner_standL_trans_B_2_A_v2 ];
	array[ "lean_to_alert" ] = [ %CornerStndL_lean_2_alert ];
	array[ "alert_to_lean" ] = [ %CornerStndL_alert_2_lean ];
	array[ "look" ] = %corner_standL_look;
	array[ "reload" ] = [ %corner_standL_reload_v1 ];// , %corner_standL_reload_v2 );
	array[ "grenade_exposed" ] = %corner_standL_grenade_A;
	array[ "grenade_safe" ] = %corner_standL_grenade_B;

	array[ "blind_fire" ] = [ %corner_standL_blindfire_v1, %corner_standL_blindfire_v2 ];
	
	array[ "alert_to_look" ] = %corner_standL_alert_2_look;
	array[ "look_to_alert" ] = %corner_standL_look_2_alert;
	array[ "look_to_alert_fast" ] = %corner_standl_look_2_alert_fast_v1;
	array[ "look_idle" ] = %corner_standL_look_idle;
	array[ "stance_change" ] = %CornerCrL_stand_2_alert;

	array[ "lean_aim_down" ] = %CornerStndL_lean_aim_2;
	array[ "lean_aim_left" ] = %CornerStndL_lean_aim_4;
	array[ "lean_aim_straight" ] = %CornerStndL_lean_aim_5;
	array[ "lean_aim_right" ] = %CornerStndL_lean_aim_6;
	array[ "lean_aim_up" ] = %CornerStndL_lean_aim_8;
	array[ "lean_reload" ] = %CornerStndL_lean_reload;

	array[ "lean_idle" ] = [ %CornerStndL_lean_idle ];

	array[ "lean_single" ] = %CornerStndL_lean_fire;
	//array["lean_burst"] = %CornerStndL_lean_autoburst;
	array[ "lean_fire" ] = %CornerStndL_lean_auto;

	if ( isDefined( anim.ramboAnims ) )
	{
		//array[ "rambo" ] = [ %corner_standL_rambo_set, %corner_standL_rambo_jam ];
		array[ "rambo90" ] = anim.ramboAnims.coverleft90;
		array[ "rambo45" ] = anim.ramboAnims.coverleft45;
		array[ "grenade_rambo" ] = anim.ramboAnims.coverleftgrenade;
	}
	
	anim.coverLeftStand = array;
}


init_animarray_crouching_left()
{
	array = [];

	array[ "alert_idle" ] = %CornerCrL_alert_idle;
	array[ "alert_idle_twitch" ] = [];
	array[ "alert_idle_flinch" ] = [];

	//array["alert_to_C"] = %CornerCrL_trans_alert_2_C;
	//array["B_to_C"] = %CornerCrL_trans_B_2_C;
	//array["C_to_alert"] = %CornerCrL_trans_C_2_alert;
	//array["C_to_B"] = %CornerCrL_trans_C_2_B;
	array[ "alert_to_A" ] = [ %CornerCrL_trans_alert_2_A ];
	array[ "alert_to_B" ] = [ %CornerCrL_trans_alert_2_B ];
	array[ "A_to_alert" ] = [ %CornerCrL_trans_A_2_alert ];
	array[ "A_to_alert_reload" ] = [];
	array[ "A_to_B" ] = [ %CornerCrL_trans_A_2_B ];
	array[ "B_to_alert" ] = [ %CornerCrL_trans_B_2_alert ];
 	array[ "B_to_alert_reload" ] = [];
	array[ "B_to_A" ] = [ %CornerCrL_trans_B_2_A ];
	array[ "lean_to_alert" ] = [ %CornerCrL_lean_2_alert ];
	array[ "alert_to_lean" ] = [ %CornerCrL_alert_2_lean ];
	
	array[ "look" ] = %CornerCrL_look_fast;
	array[ "reload" ] = [ %CornerCrL_reloadA, %CornerCrL_reloadB ];
	array[ "grenade_safe" ] = %CornerCrL_grenadeA;
	array[ "grenade_exposed" ] = %CornerCrL_grenadeB;

	array[ "alert_to_over" ] = [ %CornerCrL_alert_2_over ];
	array[ "over_to_alert" ] = [ %CornerCrL_over_2_alert ];
	array[ "over_to_alert_reload" ] = [];
	array[ "blind_fire" ] = [];

	array[ "rambo90" ] = [];
	array[ "rambo45" ] = [];

	//array["alert_to_look"] = %CornerCrL_alert_idle; // TODO
	//array["look_to_alert"] = %CornerCrL_alert_idle; // TODO
	//array["look_to_alert_fast"] = %CornerCrL_alert_idle; // TODO
	//array["look_idle"] = %CornerCrL_alert_idle; // TODO
	array[ "stance_change" ] = %CornerCrL_alert_2_stand;

	array[ "lean_aim_down" ] = %CornerCrL_lean_aim_2;
	array[ "lean_aim_left" ] = %CornerCrL_lean_aim_4;
	array[ "lean_aim_straight" ] = %CornerCrL_lean_aim_5;
	array[ "lean_aim_right" ] = %CornerCrL_lean_aim_6;
	array[ "lean_aim_up" ] = %CornerCrL_lean_aim_8;

	array[ "lean_idle" ] = [ %CornerCrL_lean_idle ];

	array[ "lean_single" ] = %CornerCrL_lean_fire;
	array[ "lean_fire" ] = %CornerCrL_lean_auto;

	anim.coverLeftCrouch = array;
}

init_animarray_standing_right() /* void */
{
	array = [];

	array[ "alert_idle" ] = %corner_standR_alert_idle;
	array[ "alert_idle_twitch" ] = [
		%corner_standR_alert_twitch01,
		%corner_standR_alert_twitch02,
		%corner_standR_alert_twitch04,
		%corner_standR_alert_twitch05,
		%corner_standR_alert_twitch06,
		%corner_standR_alert_twitch07
	 ];
	array[ "alert_idle_flinch" ] = [ %corner_standR_flinch, %corner_standR_flinchB ];

	array[ "alert_to_A" ] = [ %corner_standR_trans_alert_2_A, %corner_standR_trans_alert_2_A_v2 ];
	array[ "alert_to_B" ] = [ %corner_standR_trans_alert_2_B, %corner_standR_trans_alert_2_B_v2, %corner_standR_trans_alert_2_B_v3 ];
	array[ "A_to_alert" ] = [ %corner_standR_trans_A_2_alert_v2 ];
	array[ "A_to_alert_reload" ] = [];
	array[ "A_to_B" ] = [ %corner_standR_trans_A_2_B, %corner_standR_trans_A_2_B_v2 ];
	array[ "B_to_alert" ] = [ %corner_standR_trans_B_2_alert, %corner_standR_trans_B_2_alert_v2, %corner_standR_trans_B_2_alert_v3 ];
 	array[ "B_to_alert_reload" ] = [ %corner_standR_reload_B_2_alert ];
	array[ "B_to_A" ] = [ %corner_standR_trans_B_2_A, %corner_standR_trans_B_2_A_v2 ];
	array[ "lean_to_alert" ] = [ %CornerStndR_lean_2_alert ];
	array[ "alert_to_lean" ] = [ %CornerStndR_alert_2_lean ];
	array[ "look" ] = %corner_standR_look;
	array[ "reload" ] = [ %corner_standR_reload_v1 ];// , %corner_standR_reload_v2 );// v2 isn't finished, it seems
	array[ "grenade_exposed" ] = %corner_standR_grenade_A;
	array[ "grenade_safe" ] = %corner_standR_grenade_B;

	array[ "blind_fire" ] = [ %corner_standR_blindfire_v1, %corner_standR_blindfire_v2 ];

	array[ "alert_to_look" ] = %corner_standR_alert_2_look;
	array[ "look_to_alert" ] = %corner_standR_look_2_alert;
	array[ "look_to_alert_fast" ] = %corner_standR_look_2_alert_fast;
	array[ "look_idle" ] = %corner_standR_look_idle;
	array[ "stance_change" ] = %CornerCrR_stand_2_alert;

	array[ "lean_aim_down" ] = %CornerStndR_lean_aim_2;
	array[ "lean_aim_left" ] = %CornerStndR_lean_aim_4;
	array[ "lean_aim_straight" ] = %CornerStndR_lean_aim_5;
	array[ "lean_aim_right" ] = %CornerStndR_lean_aim_6;
	array[ "lean_aim_up" ] = %CornerStndR_lean_aim_8;
	array[ "lean_reload" ] = %CornerStndR_lean_reload;

	array[ "lean_idle" ] = [ %CornerStndR_lean_idle ];

	array[ "lean_single" ] = %CornerStndR_lean_fire;
	array[ "lean_fire" ] = %CornerStndR_lean_auto;

	if ( isDefined( anim.ramboAnims ) )
	{
		array[ "rambo90" ] = anim.ramboAnims.coverright90;
		array[ "rambo45" ] = anim.ramboAnims.coverright45;
		array[ "grenade_rambo" ] = anim.ramboAnims.coverrightgrenade;
	}
	
	anim.coverRightStand = array;
}

init_animarray_crouching_right()
{
	array = [];

	array[ "alert_idle" ] = %CornerCrR_alert_idle;
	array[ "alert_idle_twitch" ] = [
		%CornerCrR_alert_twitch_v1,
		%CornerCrR_alert_twitch_v2,
		%CornerCrR_alert_twitch_v3
	 ];
	array[ "alert_idle_flinch" ] = [];

	array[ "alert_to_A" ] = [ %CornerCrR_trans_alert_2_A ];
	array[ "alert_to_B" ] = [ %CornerCrR_trans_alert_2_B ];
	array[ "A_to_alert" ] = [ %CornerCrR_trans_A_2_alert ];
	array[ "A_to_alert_reload" ] = [];
	array[ "A_to_B" ] = [ %CornerCrR_trans_A_2_B ];
	array[ "B_to_alert" ] = [ %CornerCrR_trans_B_2_alert ];
 	array[ "B_to_alert_reload" ] = [];
	array[ "B_to_A" ] = [ %CornerCrR_trans_B_2_A ];
	array[ "lean_to_alert" ] = [ %CornerCrR_lean_2_alert ];
	array[ "alert_to_lean" ] = [ %CornerCrR_alert_2_lean ];
	array[ "reload" ] = [ %CornerCrR_reloadA, %CornerCrR_reloadB ];
	array[ "grenade_exposed" ] = %CornerCrR_grenadeA;
	array[ "grenade_safe" ] = %CornerCrR_grenadeA;// TODO: need a unique animation for this; use the exposed throw because not having it limits the options of the AI too much

	array[ "alert_to_over" ] = [ %CornerCrR_alert_2_over ];
	array[ "over_to_alert" ] = [ %CornerCrR_over_2_alert ];
	array[ "over_to_alert_reload" ] = [];

	array[ "blind_fire" ] = [];

	array[ "rambo90" ] = [];
	array[ "rambo45" ] = [];

	array[ "alert_to_look" ] = %CornerCrR_alert_2_look;
	array[ "look_to_alert" ] = %CornerCrR_look_2_alert;
	array[ "look_to_alert_fast" ] = %CornerCrR_look_2_alert_fast;// there's a v2 we could use for this also if we want
	array[ "look_idle" ] = %CornerCrR_look_idle;
	array[ "stance_change" ] = %CornerCrR_alert_2_stand;

	array[ "lean_aim_down" ] = %CornerCrR_lean_aim_2;
	array[ "lean_aim_left" ] = %CornerCrR_lean_aim_4;
	array[ "lean_aim_straight" ] = %CornerCrR_lean_aim_5;
	array[ "lean_aim_right" ] = %CornerCrR_lean_aim_6;
	array[ "lean_aim_up" ] = %CornerCrR_lean_aim_8;

	array[ "lean_idle" ] = [ %CornerCrR_lean_idle ];

	array[ "lean_single" ] = %CornerCrR_lean_fire;
	array[ "lean_fire" ] = %CornerCrR_lean_auto;

	anim.coverRightCrouch = array;
}

initGrenadeThrowAnims()
{
	// generated with scr_testgrenadethrows in combat.gsc	
	animscripts\init_common::addGrenadeThrowAnimOffset( %exposed_grenadethrowb, ( 41.5391, 7.28883, 72.2128 ) );
	animscripts\init_common::addGrenadeThrowAnimOffset( %exposed_grenadethrowc, ( 34.8849, -4.77048, 74.0488 ) );
	animscripts\init_common::addGrenadeThrowAnimOffset( %corner_standl_grenade_a, ( 41.605, 6.80107, 81.4785 ) );
	animscripts\init_common::addGrenadeThrowAnimOffset( %corner_standl_grenade_b, ( 24.1585, -14.7221, 29.2992 ) );
	animscripts\init_common::addGrenadeThrowAnimOffset( %cornercrl_grenadea, ( 25.8988, -10.2811, 30.4813 ) );
	animscripts\init_common::addGrenadeThrowAnimOffset( %cornercrl_grenadeb, ( 24.688, 45.0702, 64.377 ) );
	animscripts\init_common::addGrenadeThrowAnimOffset( %corner_standr_grenade_a, ( 37.1254, -32.7053, 76.5745 ) );
	animscripts\init_common::addGrenadeThrowAnimOffset( %corner_standr_grenade_b, ( 19.356, 15.5341, 16.5036 ) );
	animscripts\init_common::addGrenadeThrowAnimOffset( %cornercrr_grenadea, ( 39.8857, 5.92472, 24.5878 ) );
	animscripts\init_common::addGrenadeThrowAnimOffset( %covercrouch_grenadea, ( -1.6363, -0.693674, 60.1009 ) );
	animscripts\init_common::addGrenadeThrowAnimOffset( %covercrouch_grenadeb, ( -1.6363, -0.693674, 60.1009 ) );
	animscripts\init_common::addGrenadeThrowAnimOffset( %coverstand_grenadea, ( 10.8573, 7.12614, 77.2356 ) );
	animscripts\init_common::addGrenadeThrowAnimOffset( %coverstand_grenadeb, ( 19.1804, 5.68214, 73.2278 ) );
	animscripts\init_common::addGrenadeThrowAnimOffset( %prone_grenade_a, ( 12.2859, -1.3019, 33.4307 ) );
	animscripts\init_common::addGrenadeThrowAnimOffset( %CQB_stand_grenade_throw, ( 35.7494, 26.6052, 37.7086 ) );
}

init_noder_anims()
{
	array = [];
	array[ "node_cover_left" ][ 0 ]	 = %CornerCrL_reloadA;
	array[ "node_cover_left" ][ 1 ]	 = %CornerCrL_look_fast;
	array[ "node_cover_left" ][ 2 ]	 = %corner_standL_grenade_B;
	array[ "node_cover_left" ][ 3 ]	 = %corner_standL_flinch;
	array[ "node_cover_left" ][ 4 ]	 = %corner_standL_look_idle;
	array[ "node_cover_left" ][ 5 ]	 = %corner_standL_look_2_alert;

	array[ "node_cover_right" ][ 0 ]	 = %CornerCrR_reloadA;
	array[ "node_cover_right" ][ 1 ]	 = %corner_standR_grenade_B;
	array[ "node_cover_right" ][ 2 ]	 = %corner_standR_flinch;
	array[ "node_cover_right" ][ 3 ]	 = %corner_standR_look_idle;
	array[ "node_cover_right" ][ 4 ]	 = %corner_standR_look_2_alert;

	array[ "node_cover_crouch" ][ 0 ]	 = %covercrouch_hide_idle;
	array[ "node_cover_crouch" ][ 1 ]	 = %covercrouch_twitch_1;
	array[ "node_cover_crouch" ][ 2 ]	 = %covercrouch_hide_2_aim;
	array[ "node_cover_crouch" ][ 3 ]	 = %covercrouch_hide_2_aim;
	array[ "node_cover_crouch" ][ 4 ]	 = %covercrouch_hide_2_aim;
	array[ "node_cover_crouch" ][ 5 ]	 = %covercrouch_hide_look;

	array[ "node_cover_crouch_window" ][ 0 ]	 = %covercrouch_hide_idle;
	array[ "node_cover_crouch_window" ][ 1 ]	 = %covercrouch_twitch_1;
	array[ "node_cover_crouch_window" ][ 2 ]	 = %covercrouch_hide_2_aim;
	array[ "node_cover_crouch_window" ][ 3 ]	 = %covercrouch_hide_2_aim;
	array[ "node_cover_crouch_window" ][ 4 ]	 = %covercrouch_hide_2_aim;
	array[ "node_cover_crouch_window" ][ 5 ]	 = %covercrouch_hide_look;

	array[ "node_cover_prone" ][ 0 ]	 = %crouch_2_prone_firing;
	array[ "node_cover_prone" ][ 1 ]	 = %prone_2_crouch;
	array[ "node_cover_prone" ][ 2 ]	 = %prone_reload;

	array[ "node_cover_stand" ][ 0 ]	 = %coverstand_reloadA;

	array[ "node_concealment_crouch" ][ 0 ]	 = %covercrouch_hide_idle;
	array[ "node_concealment_crouch" ][ 1 ]	 = %covercrouch_twitch_1;
	array[ "node_concealment_crouch" ][ 2 ]	 = %covercrouch_hide_2_aim;
	array[ "node_concealment_crouch" ][ 3 ]	 = %covercrouch_hide_2_aim;
	array[ "node_concealment_crouch" ][ 4 ]	 = %covercrouch_hide_2_aim;
	array[ "node_concealment_crouch" ][ 5 ]	 = %covercrouch_hide_look;

	array[ "node_concealment_prone" ][ 0 ]	 = %crouch_2_prone_firing;
	array[ "node_concealment_prone" ][ 1 ]	 = %prone_2_crouch;
	array[ "node_concealment_prone" ][ 2 ]	 = %prone_reload;

	array[ "node_concealment_stand" ][ 0 ]	 = %coverstand_reloadA;

	anim.noderAnims = array;
}

init_standing_animarray_aiming()
{
	array = [];
	array[ "add_aim_up" ] = %exposed_aim_8;
	array[ "add_aim_down" ] = %exposed_aim_2;
	array[ "add_aim_left" ] = %exposed_aim_4;
	array[ "add_aim_right" ] = %exposed_aim_6;
	array[ "add_turn_aim_up" ] = %exposed_turn_aim_8;
	array[ "add_turn_aim_down" ] = %exposed_turn_aim_2;
	array[ "add_turn_aim_left" ] = %exposed_turn_aim_4;
	array[ "add_turn_aim_right" ] = %exposed_turn_aim_6;
	array[ "straight_level" ] = %exposed_aim_5;

	array[ "fire" ] = %exposed_shoot_auto_v2;
	array[ "semi2" ] = %exposed_shoot_semi2;
	array[ "semi3" ] = %exposed_shoot_semi3;
	array[ "semi4" ] = %exposed_shoot_semi4;
	array[ "semi5" ] = %exposed_shoot_semi5;

	array[ "shotgun_single" ] = [ %shotgun_stand_fire_1A ]; //used to replace single with this one when pump action.
	array[ "single" ] = [ %exposed_shoot_semi1 ];

	array[ "burst2" ] = %exposed_shoot_burst3;// ( will be limited to 2 shots )
	array[ "burst3" ] = %exposed_shoot_burst3;
	array[ "burst4" ] = %exposed_shoot_burst4;
	array[ "burst5" ] = %exposed_shoot_burst5;
	array[ "burst6" ] = %exposed_shoot_burst6;

	array[ "continuous" ] = [ %nx_tp_stand_exposed_stream_01 ];

	array[ "exposed_idle" ] = [ %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 ];

	anim.standingAiming = array;
}

init_crouching_animarray_aiming()
{
	array = [];
	array[ "add_aim_up" ] = %covercrouch_aim8_add;
	array[ "add_aim_down" ] = %covercrouch_aim2_add;
	array[ "add_aim_left" ] = %covercrouch_aim4_add;
	array[ "add_aim_right" ] = %covercrouch_aim6_add;
	array[ "straight_level" ] = %covercrouch_aim5;

	array[ "fire" ] = %exposed_shoot_auto_v2;
	array[ "semi2" ] = %exposed_shoot_semi2;
	array[ "semi3" ] = %exposed_shoot_semi3;
	array[ "semi4" ] = %exposed_shoot_semi4;
	array[ "semi5" ] = %exposed_shoot_semi5;

	array[ "burst2" ] = %exposed_shoot_burst3;// ( will be limited to 2 shots )
	array[ "burst3" ] = %exposed_shoot_burst3;
	array[ "burst4" ] = %exposed_shoot_burst4;
	array[ "burst5" ] = %exposed_shoot_burst5;
	array[ "burst6" ] = %exposed_shoot_burst6;

	array[ "continuous" ] = [ %nx_tp_stand_exposed_stream_01 ];

	array[ "shotgun_single" ] = [ %shotgun_crouch_fire ];
	array[ "single" ] = [ %exposed_shoot_semi1 ];
	array[ "exposed_idle" ] = [ %exposed_idle_alert_v1, %exposed_idle_alert_v2, %exposed_idle_alert_v3 ];
	
	anim.crouchingAimingOver = array;



	array = [];
	array[ "fire" ] = %exposed_crouch_shoot_auto_v2;
	array[ "semi2" ] = %exposed_crouch_shoot_semi2;
	array[ "semi3" ] = %exposed_crouch_shoot_semi3;
	array[ "semi4" ] = %exposed_crouch_shoot_semi4;
	array[ "semi5" ] = %exposed_crouch_shoot_semi5;

	array[ "continuous" ] = [ %nx_tp_stand_exposed_stream_01 ];

	array[ "shotgun_single" ] = [ %shotgun_crouch_fire ];
	array[ "single" ] = [ %exposed_crouch_shoot_semi1 ];

	array[ "burst2" ] = %exposed_crouch_shoot_burst3;// ( will be limited to 2 shots )
	array[ "burst3" ] = %exposed_crouch_shoot_burst3;
	array[ "burst4" ] = %exposed_crouch_shoot_burst4;
	array[ "burst5" ] = %exposed_crouch_shoot_burst5;
	array[ "burst6" ] = %exposed_crouch_shoot_burst6;

	array[ "add_aim_up" ] = %exposed_crouch_aim_8;
	array[ "add_aim_down" ] = %exposed_crouch_aim_2;
	array[ "add_aim_left" ] = %exposed_crouch_aim_4;
	array[ "add_aim_right" ] = %exposed_crouch_aim_6;
	array[ "add_turn_aim_up" ] = %exposed_crouch_turn_aim_8;
	array[ "add_turn_aim_down" ] = %exposed_crouch_turn_aim_2;
	array[ "add_turn_aim_left" ] = %exposed_crouch_turn_aim_4;
	array[ "add_turn_aim_right" ] = %exposed_crouch_turn_aim_6;
	array[ "straight_level" ] = %exposed_crouch_aim_5;

	array[ "exposed_idle" ] = [ %exposed_crouch_idle_alert_v1, %exposed_crouch_idle_alert_v2, %exposed_crouch_idle_alert_v3 ];

	anim.crouchingAiming = array;
}

init_reaction_anims()
{
	anim.runningReactToBullets = [];
	anim.runningReactToBullets = array( %run_react_duck, %run_react_flinch, %run_react_stumble );
	
	anim.lastRunningReactAnim = 0;

	anim.reactionAnimArray = [];
	anim.reactionAnimArray[ "cover_stand" ]		= array( %stand_cover_reaction_A, %stand_cover_reaction_B );
	anim.reactionAnimArray[ "cover_crouch" ]	= array( %crouch_cover_reaction_A, %crouch_cover_reaction_B );
	anim.reactionAnimArray[ "cover_left" ]		= array( %CornerStndL_react_A );
	anim.reactionAnimArray[ "cover_right" ]		= array( %CornerStndR_react_A );	
	anim.reactionAnimArray[ "wizby_idle" ]		= array( %exposed_idle_reactA, %exposed_idle_reactB, %exposed_idle_twitch, %exposed_idle_twitch_v4);
	anim.reactionAnimArray[ "wizby_dive" ]		= array( %exposed_dive_grenade_B, %exposed_dive_grenade_F );
	anim.reactionAnimArray[ "wizby_twitch" ]	= array( %exposed_crouch_idle_twitch_v2, %exposed_crouch_idle_twitch_v3 );
	anim.reactionAnimArray[ "wizby_crouch" ]	= %exposed_stand_2_crouch;
	anim.reactionAnimArray[ "wizby_turn" ]		= array( %exposed_crouch_turn_180_left, %exposed_crouch_turn_180_right );
	
	anim.reactionAnimArray[ "stand" ]				= array( %exposed_backpedal, %exposed_idle_reactB );
	anim.reactionAnimArray[ "crouch" ]				= array( %crouch_cover_reaction_A, %crouch_cover_reaction_B );
	anim.reactionAnimArray[ "stealth" ]				= %exposed_idle_reactB;
	anim.reactionAnimArray[ "stealth_backpedal" ]	= %exposed_backpedal;
	anim.reactionAnimArray[ "stealth_backpedal2" ]	= %exposed_backpedal_v2;
	anim.reactionAnimArray[ "surprise" ]			= %surprise_stop_v1;
}