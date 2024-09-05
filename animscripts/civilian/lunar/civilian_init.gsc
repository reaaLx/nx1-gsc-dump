#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include animscripts\shared;


#using_animtree( "generic_human" );

main()
{
	animscripts\lunar\init::main();

	if ( !isdefined( level._initialized_civilian_animations ) )
	{
		initCivilianAnims();
	}
	
	animscripts\civilian\civilian_init_common::civilian_init();
	
}

initCivilianAnims()
{
	level._initialized_civilian_animations = true;

	
	level._scr_anim[ "default_civilian" ][ "run_combat" ]				= [ %tp_moon_civ_run_combat ];	
	level._scr_anim[ "default_civilian" ][ "run_weights" ]				= common_scripts\utility::get_cumulative_weights( [ 1 ] ); 
	
	level._scr_anim[ "default_civilian" ][ "run_noncombat" ]			= [ %tp_moon_civ_run_noncombat ];
	
	level._scr_anim[ "default_civilian" ][ "run_hunched_combat" ]		= [ %tp_moon_civ_run_hunched_combat_A, %tp_moon_civ_run_hunched_combat_B, %tp_moon_civ_run_hunched_combat_C ];	
	level._scr_anim[ "default_civilian" ][ "run_hunched_weights" ]		= common_scripts\utility::get_cumulative_weights( [ 1, 1, 1 ] ); 	
	
	level._scr_anim[ "default_civilian" ][ "idle_noncombat" ]		 	= [ %tp_moon_civ_idle_noncombat ];
	level._scr_anim[ "default_civilian" ][ "idle_combat" ]		 		= [ %tp_moon_civ_idle_combat_A, %tp_moon_civ_idle_combat_B ];	
	level._scr_anim[ "default_civilian" ][ "dodge_left" ]				= %tp_moon_civ_dodge_L;
	level._scr_anim[ "default_civilian" ][ "dodge_right" ]				= %tp_moon_civ_dodge_R;
	level._scr_anim[ "default_civilian" ][ "react_stumble" ]			= [ %tp_moon_civ_react_stumble ];
	
	level._scr_anim[ "default_civilian"  ][ "turn_left_90" ]			= %tp_moon_civ_run_noncombat_turn_L90;
	level._scr_anim[ "default_civilian"  ][ "turn_right_90" ]			= %tp_moon_civ_run_noncombat_turn_R90;
	
	//7     9    <- 8 is invalid, it's straight.
	//4     6	 <- 5 is invalid, it's not a turn.
	//1  2  3
	level._scr_anim[ "default_civilian"]["run_combat_turn"][1] = %tp_moon_civ_run_combat_turn_L135;
	level._scr_anim[ "default_civilian"]["run_combat_turn"][2] = %tp_moon_civ_run_combat_turn_180;
	level._scr_anim[ "default_civilian"]["run_combat_turn"][3] = %tp_moon_civ_run_combat_turn_R135;
	level._scr_anim[ "default_civilian"]["run_combat_turn"][4] = %tp_moon_civ_run_combat_turn_L90;
	level._scr_anim[ "default_civilian"]["run_combat_turn"][6] = %tp_moon_civ_run_combat_turn_R90;
	level._scr_anim[ "default_civilian"]["run_combat_turn"][7] = %tp_moon_civ_run_combat_turn_L45;
	level._scr_anim[ "default_civilian"]["run_combat_turn"][9] = %tp_moon_civ_run_combat_turn_R45;
	
	
	
	//define these if we want hunched turns, they aren't required though.
	level._scr_anim[ "default_civilian"]["run_combat_hunched_turn"][1] = %tp_moon_civ_run_combat_turn_L135;
	level._scr_anim[ "default_civilian"]["run_combat_hunched_turn"][2] = %tp_moon_civ_run_combat_turn_180;
	level._scr_anim[ "default_civilian"]["run_combat_hunched_turn"][3] = %tp_moon_civ_run_combat_turn_R135;
	level._scr_anim[ "default_civilian"]["run_combat_hunched_turn"][4] = %tp_moon_civ_run_combat_hunched_turnL90;
	level._scr_anim[ "default_civilian"]["run_combat_hunched_turn"][6] = %tp_moon_civ_run_combat_hunched_turnR90;
	level._scr_anim[ "default_civilian"]["run_combat_hunched_turn"][7] = %tp_moon_civ_run_combat_hunched_turnL45;
	level._scr_anim[ "default_civilian"]["run_combat_hunched_turn"][9] = %tp_moon_civ_run_combat_hunched_turnR45;
	/*
	level._scr_anim[ "default_civilian"]["run_combat_hunched_large_turn"][1] = undefined;
	level._scr_anim[ "default_civilian"]["run_combat_hunched_large_turn"][2] = undefined;
	level._scr_anim[ "default_civilian"]["run_combat_hunched_large_turn"][3] = undefined;

	level._scr_anim[ "default_civilian"]["run_combat_hunched_large_turn"][4] = [ %tp_moon_civ_run_combat_hunched_large_turnL90_slide, %tp_moon_civ_run_combat_hunched_large_turnL90_stumble ];
	level._scr_anim[ "default_civilian"]["run_combat_hunched_large_turn"][6] = [ %tp_moon_civ_run_combat_hunched_large_turnR90_slide, %tp_moon_civ_run_combat_hunched_large_turnR90_stumble ];
	level._scr_anim[ "default_civilian"]["run_combat_hunched_large_turn"][7] = undefined;
	level._scr_anim[ "default_civilian"]["run_combat_hunched_large_turn"][9] = undefined;
	*/
}

