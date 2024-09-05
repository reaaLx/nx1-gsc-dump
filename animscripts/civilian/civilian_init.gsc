#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include animscripts\shared;


#using_animtree( "generic_human" );

main()
{
	animscripts\init::main();

	if ( !isdefined( level._initialized_civilian_animations ) )
	{
		initCivilianAnims();
	}
	
	animscripts\civilian\civilian_init_common::civilian_init();
}

initCivilianAnims()
{
	level._initialized_civilian_animations = true;

	
	//put the default ones here:
	level._scr_anim[ "default_civilian" ][ "run_combat" ]			= [ %civilian_run_upright ];	
	level._scr_anim[ "default_civilian" ][ "run_hunched_combat" ]	= [ %civilian_run_hunched_A, %civilian_run_hunched_C, %civilian_run_hunched_flinch ];
	
	level._scr_anim[ "default_civilian" ][ "run_noncombat" ]		= [ %civilian_walk_cool ];
			
	level._scr_anim[ "default_civilian" ][ "run_hunched_weights" ]	= get_cumulative_weights( [3, 3, 1] ); 
	
	level._scr_anim[ "default_civilian" ][ "run_weights" ]			= get_cumulative_weights( [ 1 ] ); 
	level._scr_anim[ "default_civilian" ][ "idle_noncombat" ] 		= [ %unarmed_cowerstand_idle ];
	level._scr_anim[ "default_civilian" ][ "idle_combat" ]			= [ %casual_crouch_v2_idle, %unarmed_cowercrouch_idle_duck ];	
	
	level._scr_anim[ "default_civilian" ][ "dodge_left" ]			= %civilian_briefcase_walk_dodge_L;
	level._scr_anim[ "default_civilian" ][ "dodge_right" ]			= %civilian_briefcase_walk_dodge_R;
	
	level._scr_anim[ "default_civilian" ][ "react_stumble" ]		= [ %run_react_stumble ];
	
	//7     9    <- 8 is invalid, it's straight.
	//4     6	 <- 5 is invalid, it's not a turn.
	//1  2  3
	level._scr_anim[ "default_civilian"]["run_combat_turn"][1] = %civilian_run_upright_turnL135;
	level._scr_anim[ "default_civilian"]["run_combat_turn"][2] = %civilian_run_upright_turn180;
	level._scr_anim[ "default_civilian"]["run_combat_turn"][3] = %civilian_run_upright_turnR135;
	level._scr_anim[ "default_civilian"]["run_combat_turn"][4] = %civilian_run_upright_turnL90;
	level._scr_anim[ "default_civilian"]["run_combat_turn"][6] = %civilian_run_upright_turnR90;
	level._scr_anim[ "default_civilian"]["run_combat_turn"][7] = %civilian_run_upright_turnL45;
	level._scr_anim[ "default_civilian"]["run_combat_turn"][9] = %civilian_run_upright_turnR45;
	
	level._scr_anim[ "default_civilian"]["run_combat_hunched_turn"][1] = %civilian_run_upright_turnL135;
	level._scr_anim[ "default_civilian"]["run_combat_hunched_turn"][2] = %civilian_run_upright_turn180;
	level._scr_anim[ "default_civilian"]["run_combat_hunched_turn"][3] = %civilian_run_upright_turnR135;
	level._scr_anim[ "default_civilian"]["run_combat_hunched_turn"][4] = %civilian_run_hunched_turnL90;
	level._scr_anim[ "default_civilian"]["run_combat_hunched_turn"][6] = %civilian_run_hunched_turnR90;
	level._scr_anim[ "default_civilian"]["run_combat_hunched_turn"][7] = %civilian_run_hunched_turnL45;
	level._scr_anim[ "default_civilian"]["run_combat_hunched_turn"][9] = %civilian_run_hunched_turnR45;
	
	//a more dramatic version. Randomly chosen from.
	level._scr_anim[ "default_civilian"]["run_combat_hunched_large_turn"][1] = [];
	level._scr_anim[ "default_civilian"]["run_combat_hunched_large_turn"][2] = [];
	level._scr_anim[ "default_civilian"]["run_combat_hunched_large_turn"][3] = [];
	level._scr_anim[ "default_civilian"]["run_combat_hunched_large_turn"][4] = [ %civilian_run_hunched_turnL90_slide, %civilian_run_hunched_turnL90_stumble ];
	level._scr_anim[ "default_civilian"]["run_combat_hunched_large_turn"][6] = [ %civilian_run_hunched_turnR90_slide, %civilian_run_hunched_turnR90_stumble ];
	level._scr_anim[ "default_civilian"]["run_combat_hunched_large_turn"][7] = [];
	level._scr_anim[ "default_civilian"]["run_combat_hunched_large_turn"][9] = [];
	
	//TagCC<NOTE>: not happy with this, but we don't have flashes around civilians on the moon, 
	//so I'm hesistent to mess with this just yet.
	anim.civilianFlashedArray = [ %unarmed_cowerstand_react, %unarmed_cowercrouch_react_A, %unarmed_cowercrouch_react_B ];	
}