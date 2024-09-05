#include animscripts\Utility;
#include maps\_utility;
#include animscripts\Combat_utility;
#include common_scripts\Utility;
#using_animtree( "generic_human" );

//The LUNAR version.

init_move_transition_arrays()
{
	if ( isdefined( anim.move_transition_arrays ) )
		return;
		
	anim.move_transition_arrays = 1;
		
	anim.coverTrans = [];
	anim.coverExit = [];
	anim.maxDirections = [];	
	anim.excludeDir = [];
	
	anim.traverseInfo = [];

	anim.coverTransLongestDist = [];
	anim.coverTransDist = [];
	anim.coverExitDist = [];

	// this is the distance moved to get around corner for 7, 8, 9 directions
	anim.coverExitPostDist = [];

	// this is the distance moved to get around corner for 7, 8, 9 directions
	anim.coverTransPreDist = [];

	anim.coverTransAngles = [];
	anim.coverExitAngles = [];

	anim.coverExitSplit = [];
	anim.coverTransSplit = [];

	anim.arrivalEndStance = [];
}


initMoveStartStopTransitions()
{
	init_move_transition_arrays();

	// Move transition points	
	init_moon_transition_points();

	// TEMP, remove this flag
	level._newArrivals = true;

	transTypes = [];
	transTypes[ 0 ] = "left";
	transTypes[ 1 ] = "right";
	transTypes[ 2 ] = "left_crouch";
	transTypes[ 3 ] = "right_crouch";
	transTypes[ 4 ] = "crouch";
	transTypes[ 5 ] = "stand";
	transTypes[ 6 ] = "exposed";
	transTypes[ 7 ] = "exposed_crouch";
	transTypes[ 8 ] = "stand_saw";
	transTypes[ 9 ] = "prone_saw";
	transTypes[ 10 ] = "crouch_saw";
	transTypes[ 11 ] = "wall_over_40";
	transTypes[ 12 ] = "right_cqb";
	transTypes[ 13 ] = "right_crouch_cqb";
	transTypes[ 14 ] = "left_cqb";
	transTypes[ 15 ] = "left_crouch_cqb";
	transTypes[ 16 ] = "exposed_cqb";
	transTypes[ 17 ] = "exposed_crouch_cqb";
	transTypes[ 18 ] = "heat";
	transTypes[ 19 ] = "heat_left";
	transTypes[ 20 ] = "heat_right";


	lastCoverTrans = 6;

	// tagJW<NOTE>: Non-lunar movements do not use move transition notes
	// Moon_actor's main is called before load, so don't override these if they exist
	if ( !isdefined( anim.run_transition_notes ) )
	{
		anim.cqb_transition_notes = [];
		anim.cqb_transition_points = [];
	
		anim.run_transition_notes = [];
		anim.run_transition_points = [];
	}

	anim.approach_types = [];

	anim.approach_types[ "Cover Left" ] = [];
	anim.approach_types[ "Cover Left" ][ "stand" ] = "left";
	anim.approach_types[ "Cover Left" ][ "crouch" ] = "left_crouch";
	anim.maxDirections[ "Cover Left" ] = 9;
	anim.excludeDir[ "Cover Left" ] = 9;	
	
	anim.approach_types[ "Cover Right" ] = [];
	anim.approach_types[ "Cover Right" ][ "stand" ] = "right";
	anim.approach_types[ "Cover Right" ][ "crouch" ] = "right_crouch";
	anim.maxDirections[ "Cover Right" ] = 9;
	anim.excludeDir[ "Cover Right" ] = 7;	

	anim.approach_types[ "Cover Crouch" ] = [];
	anim.approach_types[ "Cover Crouch" ][ "stand" ] = "crouch";
	anim.approach_types[ "Cover Crouch" ][ "crouch" ] = "crouch";
	anim.approach_types[ "Conceal Crouch" ] = anim.approach_types[ "Cover Crouch" ];
	anim.approach_types[ "Cover Crouch Window" ] = anim.approach_types[ "Cover Crouch" ];
	anim.maxDirections[ "Cover Crouch" ] = 6;
	anim.excludeDir[ "Cover Crouch" ] = -1;	
	anim.maxDirections[ "Conceal Crouch" ] = 6;
	anim.excludeDir[ "Conceal Crouch" ] = -1;	
	
	anim.approach_types[ "Cover Stand" ] = [];
	anim.approach_types[ "Cover Stand" ][ "stand" ] = "stand";
	anim.approach_types[ "Cover Stand" ][ "crouch" ] = "stand";
	anim.approach_types[ "Conceal Stand" ] = anim.approach_types[ "Cover Stand" ];
	anim.maxDirections[ "Cover Stand" ] = 6;
	anim.excludeDir[ "Cover Stand" ] = -1;	
	anim.maxDirections[ "Conceal Stand" ] = 6;
	anim.excludeDir[ "Conceal Stand" ] = -1;		

	anim.approach_types[ "Cover Prone" ] = [];
	anim.approach_types[ "Cover Prone" ][ "stand" ] = "exposed";
	anim.approach_types[ "Cover Prone" ][ "crouch" ] = "exposed";
	anim.approach_types[ "Conceal Prone" ] = anim.approach_types[ "Cover Prone" ];
	anim.excludeDir[ "Conceal Prone" ] = -1;
	
	anim.approach_types[ "Path" ] = [];
	anim.approach_types[ "Path" ][ "stand" ] = "exposed";
	anim.approach_types[ "Path" ][ "crouch" ] = "exposed_crouch";
	anim.approach_types[ "Guard" ] = anim.approach_types[ "Path" ];
	anim.approach_types[ "Ambush" ] = anim.approach_types[ "Path" ];
	anim.approach_types[ "Scripted" ] = anim.approach_types[ "Path" ];
	anim.approach_types[ "Custom" ] = anim.approach_types[ "Path" ];
	anim.approach_types[ "Exposed" ] = anim.approach_types[ "Path" ];

	anim.isCombatPathNode[ "Guard" ] = true;
	anim.isCombatPathNode[ "Ambush" ] = true;
	anim.isCombatPathNode[ "Exposed" ] = true;

	// used by level script to orient AI in certain ways at a node
	anim.isCombatScriptNode[ "Guard" ] = true;
	anim.isCombatScriptNode[ "Exposed" ] = true;
	
	// CORNER TRANSITIONS ANIMS
	// indicies indicate the keyboard numpad directions (8 is forward)
	// 7  8  9
	// 4     6	 <- 5 is invalid
	// 1  2  3

	/*************************************************
	*    Entrance Animations
	*************************************************/

	anim.coverTrans[ "right" ][ 1 ] = %tp_moon_coverR_run_2_stand_BL;
	anim.coverTrans[ "right" ][ 2 ] = %tp_moon_coverR_run_2_stand_B;
	anim.coverTrans[ "right" ][ 3 ] = %tp_moon_coverR_run_2_stand_BR;
	anim.coverTrans[ "right" ][ 4 ] = %tp_moon_coverR_run_2_stand_L;
	anim.coverTrans[ "right" ][ 6 ] = %tp_moon_coverR_run_2_stand_R;
	//im.coverTrans[ "right" ][ 7 ] = can't approach from this direction;
	anim.coverTrans[ "right" ][ 8 ] = %tp_moon_coverR_run_2_stand_F;
	anim.coverTrans[ "right" ][ 9 ] = %tp_moon_coverR_run_2_stand_FR;

	anim.coverTrans[ "right_crouch" ][ 1 ] = %tp_moon_coverR_run_2_crouch_BL;
	anim.coverTrans[ "right_crouch" ][ 2 ] = %tp_moon_coverR_run_2_crouch_B;
	anim.coverTrans[ "right_crouch" ][ 3 ] = %tp_moon_coverR_run_2_crouch_BR;
	anim.coverTrans[ "right_crouch" ][ 4 ] = %tp_moon_coverR_run_2_crouch_L;
	anim.coverTrans[ "right_crouch" ][ 6 ] = %tp_moon_coverR_run_2_crouch_R;
	//im.coverTrans[ "right_crouch" ][ 7 ] = can't approach from this direction;
	anim.coverTrans[ "right_crouch" ][ 8 ] = %tp_moon_coverR_run_2_crouch_F;
	anim.coverTrans[ "right_crouch" ][ 9 ] = %tp_moon_coverR_run_2_crouch_FR;

	anim.coverTrans[ "right_cqb" ][ 1 ] = %tp_moon_coverR_run_2_stand_BL;
	anim.coverTrans[ "right_cqb" ][ 2 ] = %tp_moon_coverR_run_2_stand_B;
	anim.coverTrans[ "right_cqb" ][ 3 ] = %tp_moon_coverR_run_2_stand_BR;
	anim.coverTrans[ "right_cqb" ][ 4 ] = %tp_moon_coverR_run_2_stand_L;
	anim.coverTrans[ "right_cqb" ][ 6 ] = %tp_moon_coverR_run_2_stand_R;
	//im.coverTrans[ "right_cqb" ][ 7 ] = can't approach from this direction;
	anim.coverTrans[ "right_cqb" ][ 8 ] = %tp_moon_coverR_run_2_stand_F;
	anim.coverTrans[ "right_cqb" ][ 9 ] = %tp_moon_coverR_run_2_stand_FR;

	anim.coverTrans[ "right_crouch_cqb" ][ 1 ] = %tp_moon_cqb_coverR_run_2_crouch_BL;
	anim.coverTrans[ "right_crouch_cqb" ][ 2 ] = %tp_moon_cqb_coverR_run_2_crouch_B;
	anim.coverTrans[ "right_crouch_cqb" ][ 3 ] = %tp_moon_cqb_coverR_run_2_crouch_BR;
	anim.coverTrans[ "right_crouch_cqb" ][ 4 ] = %tp_moon_cqb_coverR_run_2_crouch_L;
	anim.coverTrans[ "right_crouch_cqb" ][ 6 ] = %tp_moon_cqb_coverR_run_2_crouch_R;
	//im.coverTrans[ "right_crouch_cqb" ][ 7 ] = can't approach from this direction;
	anim.coverTrans[ "right_crouch_cqb" ][ 8 ] = %tp_moon_cqb_coverR_run_2_crouch_F;
	anim.coverTrans[ "right_crouch_cqb" ][ 9 ] = %tp_moon_cqb_coverR_run_2_crouch_FR;
	
	anim.coverTrans[ "left" ][ 1 ] = %tp_moon_coverL_run_2_stand_BL;
	anim.coverTrans[ "left" ][ 2 ] = %tp_moon_coverL_run_2_stand_B;
	anim.coverTrans[ "left" ][ 3 ] = %tp_moon_coverL_run_2_stand_BR;
	anim.coverTrans[ "left" ][ 4 ] = %tp_moon_coverL_run_2_stand_L;
	anim.coverTrans[ "left" ][ 6 ] = %tp_moon_coverL_run_2_stand_R;
	anim.coverTrans[ "left" ][ 7 ] = %tp_moon_coverL_run_2_stand_FL;
	anim.coverTrans[ "left" ][ 8 ] = %tp_moon_coverL_run_2_stand_F;
	//im.coverTrans[ "left" ][ 9 ] = can't approach from this direction;

	anim.coverTrans[ "left_crouch" ][ 1 ] = %tp_moon_coverL_run_2_crouch_BL;
	anim.coverTrans[ "left_crouch" ][ 2 ] = %tp_moon_coverL_run_2_crouch_B;
	anim.coverTrans[ "left_crouch" ][ 3 ] = %tp_moon_coverL_run_2_crouch_BR;
	anim.coverTrans[ "left_crouch" ][ 4 ] = %tp_moon_coverL_run_2_crouch_L;
	anim.coverTrans[ "left_crouch" ][ 6 ] = %tp_moon_coverL_run_2_crouch_R;
	anim.coverTrans[ "left_crouch" ][ 7 ] = %tp_moon_coverL_run_2_crouch_FL;
	anim.coverTrans[ "left_crouch" ][ 8 ] = %tp_moon_coverL_run_2_crouch_F;
	//im.coverTrans[ "left_crouch" ][ 9 ] = can't approach from this direction;

	anim.coverTrans[ "left_cqb" ][ 1 ] = %tp_moon_coverL_run_2_stand_BL;
	anim.coverTrans[ "left_cqb" ][ 2 ] = %tp_moon_coverL_run_2_stand_B;
	anim.coverTrans[ "left_cqb" ][ 3 ] = %tp_moon_coverL_run_2_stand_BR;
	anim.coverTrans[ "left_cqb" ][ 4 ] = %tp_moon_coverL_run_2_stand_L;
	anim.coverTrans[ "left_cqb" ][ 6 ] = %tp_moon_coverL_run_2_stand_R;
	anim.coverTrans[ "left_cqb" ][ 7 ] = %tp_moon_coverL_run_2_stand_FL;
	anim.coverTrans[ "left_cqb" ][ 8 ] = %tp_moon_coverL_run_2_stand_F;
	//im.coverTrans[ "left_cqb" ][ 9 ] = can't approach from this direction;
	
	anim.coverTrans[ "left_crouch_cqb" ][ 1 ] = %tp_moon_cqb_coverL_run_2_crouch_BL;
	anim.coverTrans[ "left_crouch_cqb" ][ 2 ] = %tp_moon_cqb_coverL_run_2_crouch_B;
	anim.coverTrans[ "left_crouch_cqb" ][ 3 ] = %tp_moon_cqb_coverL_run_2_crouch_BR;
	anim.coverTrans[ "left_crouch_cqb" ][ 4 ] = %tp_moon_cqb_coverL_run_2_crouch_L;
	anim.coverTrans[ "left_crouch_cqb" ][ 6 ] = %tp_moon_cqb_coverL_run_2_crouch_R;
	anim.coverTrans[ "left_crouch_cqb" ][ 7 ] = %tp_moon_cqb_coverL_run_2_crouch_FL;
	anim.coverTrans[ "left_crouch_cqb" ][ 8 ] = %tp_moon_cqb_coverL_run_2_crouch_F;
	//im.coverTrans[ "left_crouch_cqb" ][ 9 ] = can't approach from this direction;	
	
	anim.coverTrans[ "crouch" ][ 1 ] = %tp_moon_coverF_run_2_crouch_BL;
	anim.coverTrans[ "crouch" ][ 2 ] = %tp_moon_coverF_run_2_crouch_B;
	anim.coverTrans[ "crouch" ][ 3 ] = %tp_moon_coverF_run_2_crouch_BR;
	anim.coverTrans[ "crouch" ][ 4 ] = %tp_moon_coverF_run_2_crouch_L;
	anim.coverTrans[ "crouch" ][ 6 ] = %tp_moon_coverF_run_2_crouch_R;
	//im.coverTrans[ "crouch" ][ 7 ] = can't approach from this direction;
	//im.coverTrans[ "crouch" ][ 8 ] = can't approach from this direction;
	//im.coverTrans[ "crouch" ][ 9 ] = can't approach from this direction;

	anim.coverTrans[ "stand" ][ 1 ] = %tp_moon_coverF_run_2_stand_BL;
	anim.coverTrans[ "stand" ][ 2 ] = %tp_moon_coverF_run_2_stand_B;
	anim.coverTrans[ "stand" ][ 3 ] = %tp_moon_coverF_run_2_stand_BR;
	anim.coverTrans[ "stand" ][ 4 ] = %tp_moon_coverF_run_2_stand_L;
	anim.coverTrans[ "stand" ][ 6 ] = %tp_moon_coverF_run_2_stand_R;
	//im.coverTrans[ "stand" ][ 7 ] = can't approach from this direction;
	//im.coverTrans[ "stand" ][ 8 ] = can't approach from this direction;
	//im.coverTrans[ "stand" ][ 9 ] = can't approach from this direction;

	anim.coverTrans[ "stand_saw" ][ 1 ] = %saw_gunner_runin_ML;
	anim.coverTrans[ "stand_saw" ][ 2 ] = %saw_gunner_runin_M;
	anim.coverTrans[ "stand_saw" ][ 3 ] = %saw_gunner_runin_MR;
	anim.coverTrans[ "stand_saw" ][ 4 ] = %saw_gunner_runin_L;
	anim.coverTrans[ "stand_saw" ][ 6 ] = %saw_gunner_runin_R;

	anim.coverTrans[ "crouch_saw" ][ 1 ] = %saw_gunner_lowwall_runin_ML;
	anim.coverTrans[ "crouch_saw" ][ 2 ] = %saw_gunner_lowwall_runin_M;
	anim.coverTrans[ "crouch_saw" ][ 3 ] = %saw_gunner_lowwall_runin_MR;
	anim.coverTrans[ "crouch_saw" ][ 4 ] = %saw_gunner_lowwall_runin_L;
	anim.coverTrans[ "crouch_saw" ][ 6 ] = %saw_gunner_lowwall_runin_R;

	anim.coverTrans[ "prone_saw" ][ 1 ] = %saw_gunner_prone_runin_ML;
	anim.coverTrans[ "prone_saw" ][ 2 ] = %saw_gunner_prone_runin_M;
	anim.coverTrans[ "prone_saw" ][ 3 ] = %saw_gunner_prone_runin_MR;

	// we need 45 degree angle approaches for exposed...
	anim.coverTrans[ "exposed" ] = [];// need this or it chokes on the next line due to assigning undefined...
	anim.coverTrans[ "exposed" ][ 1 ] = %tp_moon_exposed_run_2_stand_BL;
	anim.coverTrans[ "exposed" ][ 2 ] = %tp_moon_exposed_run_2_stand_B;
	anim.coverTrans[ "exposed" ][ 3 ] = %tp_moon_exposed_run_2_stand_BR;
	anim.coverTrans[ "exposed" ][ 4 ] = %tp_moon_exposed_run_2_stand_L;
	anim.coverTrans[ "exposed" ][ 6 ] = %tp_moon_exposed_run_2_stand_R;
	anim.coverTrans[ "exposed" ][ 7 ] = %tp_moon_exposed_run_2_stand_FL;
	anim.coverTrans[ "exposed" ][ 8 ] = %tp_moon_exposed_run_2_stand_F;
	anim.coverTrans[ "exposed" ][ 9 ] = %tp_moon_exposed_run_2_stand_FR;

	anim.coverTrans[ "exposed_crouch" ] = [];// need this or it chokes on the next line due to assigning undefined...
	anim.coverTrans[ "exposed_crouch" ][ 1 ] = %tp_moon_exposed_run_2_crouch_BL;
	anim.coverTrans[ "exposed_crouch" ][ 2 ] = %tp_moon_exposed_run_2_crouch_B;
	anim.coverTrans[ "exposed_crouch" ][ 3 ] = %tp_moon_exposed_run_2_crouch_BR;
	anim.coverTrans[ "exposed_crouch" ][ 4 ] = %tp_moon_exposed_run_2_crouch_L;
	anim.coverTrans[ "exposed_crouch" ][ 6 ] = %tp_moon_exposed_run_2_crouch_R;
	anim.coverTrans[ "exposed_crouch" ][ 7 ] = %tp_moon_exposed_run_2_crouch_FL;
	anim.coverTrans[ "exposed_crouch" ][ 8 ] = %tp_moon_exposed_run_2_crouch_F;
	anim.coverTrans[ "exposed_crouch" ][ 9 ] = %tp_moon_exposed_run_2_crouch_FR;

	anim.coverTrans[ "exposed_cqb" ] = [];// need this or it chokes on the next line due to assigning undefined...
	anim.coverTrans[ "exposed_cqb" ][ 1 ] = %tp_moon_cqb_exposed_run_2_stand_BL;
	anim.coverTrans[ "exposed_cqb" ][ 2 ] = %tp_moon_cqb_exposed_run_2_stand_B;
	anim.coverTrans[ "exposed_cqb" ][ 3 ] = %tp_moon_cqb_exposed_run_2_stand_BR;
	anim.coverTrans[ "exposed_cqb" ][ 4 ] = %tp_moon_cqb_exposed_run_2_stand_L;
	anim.coverTrans[ "exposed_cqb" ][ 6 ] = %tp_moon_cqb_exposed_run_2_stand_R;
	anim.coverTrans[ "exposed_cqb" ][ 7 ] = %tp_moon_cqb_exposed_run_2_stand_FL;
	anim.coverTrans[ "exposed_cqb" ][ 8 ] = %tp_moon_cqb_exposed_run_2_stand_F;
	anim.coverTrans[ "exposed_cqb" ][ 9 ] = %tp_moon_cqb_exposed_run_2_stand_FR;

	anim.coverTrans[ "exposed_crouch_cqb" ] = [];// need this or it chokes on the next line due to assigning undefined...
	anim.coverTrans[ "exposed_crouch_cqb" ][ 1 ] = %tp_moon_exposed_run_2_crouch_BL;
	anim.coverTrans[ "exposed_crouch_cqb" ][ 2 ] = %tp_moon_exposed_run_2_crouch_B;
	anim.coverTrans[ "exposed_crouch_cqb" ][ 3 ] = %tp_moon_exposed_run_2_crouch_BR;
	anim.coverTrans[ "exposed_crouch_cqb" ][ 4 ] = %tp_moon_exposed_run_2_crouch_L;
	anim.coverTrans[ "exposed_crouch_cqb" ][ 6 ] = %tp_moon_exposed_run_2_crouch_R;
	anim.coverTrans[ "exposed_crouch_cqb" ][ 7 ] = %tp_moon_exposed_run_2_crouch_FL;
	anim.coverTrans[ "exposed_crouch_cqb" ][ 8 ] = %tp_moon_exposed_run_2_crouch_F;
	anim.coverTrans[ "exposed_crouch_cqb" ][ 9 ] = %tp_moon_exposed_run_2_crouch_FR;
	
	anim.coverTrans[ "heat" ] = [];// need this or it chokes on the next line due to assigning undefined...
	anim.coverTrans[ "heat" ][ 1 ] = %heat_approach_1;
	anim.coverTrans[ "heat" ][ 2 ] = %heat_approach_2;
	anim.coverTrans[ "heat" ][ 3 ] = %heat_approach_3;
	anim.coverTrans[ "heat" ][ 4 ] = %heat_approach_4;
	anim.coverTrans[ "heat" ][ 6 ] = %heat_approach_6;
	//anim.coverTrans[ "heat" ][ 7 ] = %heat_approach_8;
	anim.coverTrans[ "heat" ][ 8 ] = %heat_approach_8;
	//anim.coverTrans[ "heat" ][ 9 ] = %heat_approach_8;
	
	anim.coverTrans[ "heat_left" ] = [];
	anim.coverTrans[ "heat_right" ] = [];
	
	/*************************************************
	*    Step in position Animations
	*************************************************/
	
	anim.coverStepInAnim = [];
	anim.coverStepInAnim[ "right" ] = %corner_standR_trans_B_2_alert;
	anim.coverStepInAnim[ "right_crouch" ] = %CornerCrR_trans_B_2_alert;
	anim.coverStepInAnim[ "left" ] = %corner_standL_trans_B_2_alert_v2;
	anim.coverStepInAnim[ "left_crouch" ] = %CornerCrL_trans_B_2_alert;
	anim.coverStepInAnim[ "crouch" ] = %covercrouch_aim_2_hide;
	anim.coverStepInAnim[ "stand" ] = %coverstand_aim_2_hide;

	anim.coverStepInOffsets = [];
	anim.coverStepInAngles = []; 
	
	for( i = 0; i < lastCoverTrans; i++ )
	{
		trans = transTypes[i];
		anim.coverStepInOffsets[ trans ] = getMoveDelta( anim.coverStepInAnim[ trans ], 0, 1 );
		anim.coverStepInAngles[ trans ] = getAngleDelta( anim.coverStepInAnim[ trans ], 0, 1 );
	}
	
	anim.coverStepInAngles[ "right" ] += 90;
	anim.coverStepInAngles[ "right_crouch" ] += 90;
	anim.coverStepInAngles[ "left" ] -= 90;
	anim.coverStepInAngles[ "left_crouch" ] -= 90;

	/*************************************************
	*    Traverse Animations
	*************************************************/

	anim.coverTrans[ "wall_over_96" ][ 1 ] = %traverse90_IN_ML;
	anim.coverTrans[ "wall_over_96" ][ 2 ] = %traverse90_IN_M;
	anim.coverTrans[ "wall_over_96" ][ 3 ] = %traverse90_IN_MR;
	anim.traverseInfo[ "wall_over_96" ][ "height" ] = 96;

	anim.coverTrans[ "wall_over_40" ][ 1 ] = %traverse_window_M_2_run;
	anim.coverTrans[ "wall_over_40" ][ 2 ] = %traverse_window_M_2_run;
	anim.coverTrans[ "wall_over_40" ][ 3 ] = %traverse_window_M_2_run;

	/*
	anim.coverTrans["wall_over_40"][1] = %traverse40_IN_ML;
	anim.coverTrans["wall_over_40"][2] = %traverse40_IN_M;
	anim.coverTrans["wall_over_40"][3] = %traverse40_IN_MR;
	*/




	/*************************************************
	*    Exit Animations
	*************************************************/

	anim.coverExit[ "right" ][ 1 ] = %tp_moon_coverR_stand_2_run_BL;
	anim.coverExit[ "right" ][ 2 ] = %tp_moon_coverR_stand_2_run_B;
	anim.coverExit[ "right" ][ 3 ] = %tp_moon_coverR_stand_2_run_BR;
	anim.coverExit[ "right" ][ 4 ] = %tp_moon_coverR_stand_2_run_L;
	anim.coverExit[ "right" ][ 6 ] = %tp_moon_coverR_stand_2_run_R;
	//im.coverExit[ "right" ][ 7 ] = can't approach from this direction;
	anim.coverExit[ "right" ][ 8 ] = %tp_moon_coverR_stand_2_run_F;
	anim.coverExit[ "right" ][ 9 ] = %tp_moon_coverR_stand_2_run_FR;

	anim.coverExit[ "right_crouch" ][ 1 ] = %tp_moon_coverR_crouch_2_run_BL;
	anim.coverExit[ "right_crouch" ][ 2 ] = %tp_moon_coverR_crouch_2_run_B;
	anim.coverExit[ "right_crouch" ][ 3 ] = %tp_moon_coverR_crouch_2_run_BR;
	anim.coverExit[ "right_crouch" ][ 4 ] = %tp_moon_coverR_crouch_2_run_L;
	anim.coverExit[ "right_crouch" ][ 6 ] = %tp_moon_coverR_crouch_2_run_R;
	//im.coverExit[ "right_crouch" ][ 7 ] = can't approach from this direction;
	anim.coverExit[ "right_crouch" ][ 8 ] = %tp_moon_coverR_crouch_2_run_F;
	anim.coverExit[ "right_crouch" ][ 9 ] = %tp_moon_coverR_crouch_2_run_FR;
	
	anim.coverExit[ "right_cqb" ][ 1 ] = %tp_moon_coverR_stand_2_run_BL;
	anim.coverExit[ "right_cqb" ][ 2 ] = %tp_moon_coverR_stand_2_run_B;
	anim.coverExit[ "right_cqb" ][ 3 ] = %tp_moon_coverR_stand_2_run_BR;
	anim.coverExit[ "right_cqb" ][ 4 ] = %tp_moon_coverR_stand_2_run_L;
	anim.coverExit[ "right_cqb" ][ 6 ] = %tp_moon_coverR_stand_2_run_R;
	//im.coverExit[ "right_cqb" ][ 7 ] = can't approach from this direction;
	anim.coverExit[ "right_cqb" ][ 8 ] = %tp_moon_coverR_stand_2_run_F;
	anim.coverExit[ "right_cqb" ][ 9 ] = %tp_moon_coverR_stand_2_run_FR;

	anim.coverExit[ "right_crouch_cqb" ][ 1 ] = %tp_moon_cqb_coverR_crouch_2_run_BL;
	anim.coverExit[ "right_crouch_cqb" ][ 2 ] = %tp_moon_cqb_coverR_crouch_2_run_B;
	anim.coverExit[ "right_crouch_cqb" ][ 3 ] = %tp_moon_cqb_coverR_crouch_2_run_BR;
	anim.coverExit[ "right_crouch_cqb" ][ 4 ] = %tp_moon_cqb_coverR_crouch_2_run_L;
	anim.coverExit[ "right_crouch_cqb" ][ 6 ] = %tp_moon_cqb_coverR_crouch_2_run_R;
	//im.coverExit[ "right_crouch_cqb" ][ 7 ] = can't approach from this direction;
	anim.coverExit[ "right_crouch_cqb" ][ 8 ] = %tp_moon_cqb_coverR_crouch_2_run_F;
	anim.coverExit[ "right_crouch_cqb" ][ 9 ] = %tp_moon_cqb_coverR_crouch_2_run_FR;


	anim.coverExit[ "left" ][ 1 ] = %tp_moon_coverL_stand_2_run_BL;
	anim.coverExit[ "left" ][ 2 ] = %tp_moon_coverL_stand_2_run_B;
	anim.coverExit[ "left" ][ 3 ] = %tp_moon_coverL_stand_2_run_BR;
	anim.coverExit[ "left" ][ 4 ] = %tp_moon_coverL_stand_2_run_L;
	anim.coverExit[ "left" ][ 6 ] = %tp_moon_coverL_stand_2_run_R;
	anim.coverExit[ "left" ][ 7 ] = %tp_moon_coverL_stand_2_run_FL;
	anim.coverExit[ "left" ][ 8 ] = %tp_moon_coverL_stand_2_run_F;
	//im.coverExit[ "left" ][ 9 ] = can't approach from this direction;

	anim.coverExit[ "left_crouch" ][ 1 ] = %tp_moon_coverL_crouch_2_run_BL;
	anim.coverExit[ "left_crouch" ][ 2 ] = %tp_moon_coverL_crouch_2_run_B;
	anim.coverExit[ "left_crouch" ][ 3 ] = %tp_moon_coverL_crouch_2_run_BR;
	anim.coverExit[ "left_crouch" ][ 4 ] = %tp_moon_coverL_crouch_2_run_L;
	anim.coverExit[ "left_crouch" ][ 6 ] = %tp_moon_coverL_crouch_2_run_R;
	anim.coverExit[ "left_crouch" ][ 7 ] = %tp_moon_coverL_crouch_2_run_FL;
	anim.coverExit[ "left_crouch" ][ 8 ] = %tp_moon_coverL_crouch_2_run_F;
	//im.coverExit[ "left_crouch" ][ 9 ] = can't approach from this direction;

	anim.coverExit[ "left_cqb" ][ 1 ] = %tp_moon_coverL_stand_2_run_BL;
	anim.coverExit[ "left_cqb" ][ 2 ] = %tp_moon_coverL_stand_2_run_B;
	anim.coverExit[ "left_cqb" ][ 3 ] = %tp_moon_coverL_stand_2_run_BR;
	anim.coverExit[ "left_cqb" ][ 4 ] = %tp_moon_coverL_stand_2_run_L;
	anim.coverExit[ "left_cqb" ][ 6 ] = %tp_moon_coverL_stand_2_run_R;
	anim.coverExit[ "left_cqb" ][ 7 ] = %tp_moon_coverL_stand_2_run_FL;
	anim.coverExit[ "left_cqb" ][ 8 ] = %tp_moon_coverL_stand_2_run_F;
	//im.coverExit[ "left_cqb" ][ 9 ] = can't approach from this direction;

	anim.coverExit[ "left_crouch_cqb" ][ 1 ] = %tp_moon_cqb_coverL_crouch_2_run_BL;
	anim.coverExit[ "left_crouch_cqb" ][ 2 ] = %tp_moon_cqb_coverL_crouch_2_run_B;
	anim.coverExit[ "left_crouch_cqb" ][ 3 ] = %tp_moon_cqb_coverL_crouch_2_run_BR;
	anim.coverExit[ "left_crouch_cqb" ][ 4 ] = %tp_moon_cqb_coverL_crouch_2_run_L;
	anim.coverExit[ "left_crouch_cqb" ][ 6 ] = %tp_moon_cqb_coverL_crouch_2_run_R;
	anim.coverExit[ "left_crouch_cqb" ][ 7 ] = %tp_moon_cqb_coverL_crouch_2_run_FL;
	anim.coverExit[ "left_crouch_cqb" ][ 8 ] = %tp_moon_cqb_coverL_crouch_2_run_F;
	//im.coverExit[ "left_crouch_cqb" ][ 9 ] = can't approach from this direction;
	
	anim.coverExit[ "crouch" ][ 1 ] = %tp_moon_coverF_crouch_2_run_BL;
	anim.coverExit[ "crouch" ][ 2 ] = %tp_moon_coverF_crouch_2_run_B;
	anim.coverExit[ "crouch" ][ 3 ] = %tp_moon_coverF_crouch_2_run_BR;
	anim.coverExit[ "crouch" ][ 4 ] = %tp_moon_coverF_crouch_2_run_L;
	anim.coverExit[ "crouch" ][ 6 ] = %tp_moon_coverF_crouch_2_run_R;
	//im.coverExit[ "crouch" ][ 7 ] = can't approach from this direction;
	//im.coverExit[ "crouch" ][ 8 ] = can't approach from this direction;
	//im.coverExit[ "crouch" ][ 9 ] = can't approach from this direction;

	anim.coverExit[ "stand" ][ 1 ] = %tp_moon_coverF_stand_2_run_BL;
	anim.coverExit[ "stand" ][ 2 ] = %tp_moon_coverF_stand_2_run_B;
	anim.coverExit[ "stand" ][ 3 ] = %tp_moon_coverF_stand_2_run_BR;
	anim.coverExit[ "stand" ][ 4 ] = %tp_moon_coverF_stand_2_run_L;
	anim.coverExit[ "stand" ][ 6 ] = %tp_moon_coverF_stand_2_run_R;
	//im.coverExit[ "stand" ][ 7 ] = can't approach from this direction;
	//im.coverExit[ "stand" ][ 8 ] = can't approach from this direction;
	//im.coverExit[ "stand" ][ 9 ] = can't approach from this direction;

	anim.coverExit[ "stand_saw" ][ 1 ] = %saw_gunner_runout_ML;
	anim.coverExit[ "stand_saw" ][ 2 ] = %saw_gunner_runout_M;
	anim.coverExit[ "stand_saw" ][ 3 ] = %saw_gunner_runout_MR;
	anim.coverExit[ "stand_saw" ][ 4 ] = %saw_gunner_runout_L;
	anim.coverExit[ "stand_saw" ][ 6 ] = %saw_gunner_runout_R;

//	anim.coverExit["prone_saw"	 ][1] = %saw_gunner_prone_runout_ML;
	anim.coverExit[ "prone_saw"	 ][ 2 ] = %saw_gunner_prone_runout_M;
//	anim.coverExit["prone_saw"	 ][3] = %saw_gunner_prone_runout_MR;
	anim.coverExit[ "prone_saw"	 ][ 4 ] = %saw_gunner_prone_runout_L;
	anim.coverExit[ "prone_saw"	 ][ 6 ] = %saw_gunner_prone_runout_R;
//	anim.coverExit["prone_saw"	 ][7] = %saw_gunner_prone_runout_F; // need this anim or a way to exclude it
	anim.coverExit[ "prone_saw"	 ][ 8 ] = %saw_gunner_prone_runout_F;

	anim.coverExit[ "crouch_saw"	 ][ 1 ] = %saw_gunner_lowwall_runout_ML;
	anim.coverExit[ "crouch_saw"	 ][ 2 ] = %saw_gunner_lowwall_runout_M;
	anim.coverExit[ "crouch_saw"	 ][ 3 ] = %saw_gunner_lowwall_runout_MR;
	anim.coverExit[ "crouch_saw"	 ][ 4 ] = %saw_gunner_lowwall_runout_L;
	anim.coverExit[ "crouch_saw"	 ][ 6 ] = %saw_gunner_lowwall_runout_R;

	// we need 45 degree angle exits for exposed...
	anim.coverExit[ "exposed" ] = [];// need this or it chokes on the next line due to assigning undefined...
	anim.coverExit[ "exposed" ][ 1 ] = %tp_moon_exposed_stand_2_run_BL;
	anim.coverExit[ "exposed" ][ 2 ] = %tp_moon_exposed_stand_2_run_B;
	anim.coverExit[ "exposed" ][ 3 ] = %tp_moon_exposed_stand_2_run_BR;
	anim.coverExit[ "exposed" ][ 4 ] = %tp_moon_exposed_stand_2_run_L;
	anim.coverExit[ "exposed" ][ 6 ] = %tp_moon_exposed_stand_2_run_R;
	anim.coverExit[ "exposed" ][ 7 ] = %tp_moon_exposed_stand_2_run_FL;
	anim.coverExit[ "exposed" ][ 8 ] = %tp_moon_exposed_stand_2_run_F; // %stand_2_run_F_2;
	anim.coverExit[ "exposed" ][ 9 ] = %tp_moon_exposed_stand_2_run_FR;

	anim.coverExit[ "exposed_crouch" ] = [];// need this or it chokes on the next line due to assigning undefined...
	anim.coverExit[ "exposed_crouch" ][ 1 ] = %tp_moon_exposed_crouch_2_run_BL;
	anim.coverExit[ "exposed_crouch" ][ 2 ] = %tp_moon_exposed_crouch_2_run_B;
	anim.coverExit[ "exposed_crouch" ][ 3 ] = %tp_moon_exposed_crouch_2_run_BR;
	anim.coverExit[ "exposed_crouch" ][ 4 ] = %tp_moon_exposed_crouch_2_run_L;
	anim.coverExit[ "exposed_crouch" ][ 6 ] = %tp_moon_exposed_crouch_2_run_R;
	anim.coverExit[ "exposed_crouch" ][ 7 ] = %tp_moon_exposed_crouch_2_run_FL;
	anim.coverExit[ "exposed_crouch" ][ 8 ] = %tp_moon_exposed_crouch_2_run_F;
	anim.coverExit[ "exposed_crouch" ][ 9 ] = %tp_moon_exposed_crouch_2_run_FR;
	
	anim.coverExit[ "exposed_cqb" ] = [];// need this or it chokes on the next line due to assigning undefined...
	anim.coverExit[ "exposed_cqb" ][ 1 ] = %tp_moon_cqb_exposed_stand_2_run_BL;
	anim.coverExit[ "exposed_cqb" ][ 2 ] = %tp_moon_cqb_exposed_stand_2_run_B;
	anim.coverExit[ "exposed_cqb" ][ 3 ] = %tp_moon_cqb_exposed_stand_2_run_BR;
	anim.coverExit[ "exposed_cqb" ][ 4 ] = %tp_moon_cqb_exposed_stand_2_run_L;
	anim.coverExit[ "exposed_cqb" ][ 6 ] = %tp_moon_cqb_exposed_stand_2_run_R;
	anim.coverExit[ "exposed_cqb" ][ 7 ] = %tp_moon_cqb_exposed_stand_2_run_FL;
	anim.coverExit[ "exposed_cqb" ][ 8 ] = %tp_moon_cqb_exposed_stand_2_run_F;
	anim.coverExit[ "exposed_cqb" ][ 9 ] = %tp_moon_cqb_exposed_stand_2_run_FR;

	anim.coverExit[ "exposed_crouch_cqb" ] = [];// need this or it chokes on the next line due to assigning undefined...
	anim.coverExit[ "exposed_crouch_cqb" ][ 1 ] = %tp_moon_exposed_crouch_2_run_BL;
	anim.coverExit[ "exposed_crouch_cqb" ][ 2 ] = %tp_moon_exposed_crouch_2_run_B;
	anim.coverExit[ "exposed_crouch_cqb" ][ 3 ] = %tp_moon_exposed_crouch_2_run_BR;
	anim.coverExit[ "exposed_crouch_cqb" ][ 4 ] = %tp_moon_exposed_crouch_2_run_L;
	anim.coverExit[ "exposed_crouch_cqb" ][ 6 ] = %tp_moon_exposed_crouch_2_run_R;
	anim.coverExit[ "exposed_crouch_cqb" ][ 7 ] = %tp_moon_exposed_crouch_2_run_FL;
	anim.coverExit[ "exposed_crouch_cqb" ][ 8 ] = %tp_moon_exposed_crouch_2_run_F;
	anim.coverExit[ "exposed_crouch_cqb" ][ 9 ] = %tp_moon_exposed_crouch_2_run_FR;
	
	anim.coverExit[ "heat" ] = [];
	anim.coverExit[ "heat" ][ 1 ] = %heat_exit_1;
	anim.coverExit[ "heat" ][ 2 ] = %heat_exit_2;
	anim.coverExit[ "heat" ][ 3 ] = %heat_exit_3;
	anim.coverExit[ "heat" ][ 4 ] = %heat_exit_4;
	anim.coverExit[ "heat" ][ 6 ] = %heat_exit_6;	//%heat_exit_6a
	anim.coverExit[ "heat" ][ 7 ] = %heat_exit_7;
	anim.coverExit[ "heat" ][ 8 ] = %heat_exit_8;	//%heat_exit_8a
	anim.coverExit[ "heat" ][ 9 ] = %heat_exit_9;
		
	anim.coverExit[ "heat_left" ] = [];
	anim.coverExit[ "heat_left" ][ 1 ] = %heat_exit_1;
	anim.coverExit[ "heat_left" ][ 2 ] = %heat_exit_2;
	anim.coverExit[ "heat_left" ][ 3 ] = %heat_exit_3;
	anim.coverExit[ "heat_left" ][ 4 ] = %heat_exit_4;
	anim.coverExit[ "heat_left" ][ 6 ] = %heat_exit_6;
	anim.coverExit[ "heat_left" ][ 7 ] = %heat_exit_8L;
	anim.coverExit[ "heat_left" ][ 8 ] = %heat_exit_8L;
	anim.coverExit[ "heat_left" ][ 9 ] = %heat_exit_8R;
	
	anim.coverExit[ "heat_right" ] = [];
	anim.coverExit[ "heat_right" ][ 1 ] = %heat_exit_1;
	anim.coverExit[ "heat_right" ][ 2 ] = %heat_exit_2;
	anim.coverExit[ "heat_right" ][ 3 ] = %heat_exit_3;
	anim.coverExit[ "heat_right" ][ 4 ] = %heat_exit_4;
	anim.coverExit[ "heat_right" ][ 6 ] = %heat_exit_6;
	anim.coverExit[ "heat_right" ][ 7 ] = %heat_exit_8L;
	anim.coverExit[ "heat_right" ][ 8 ] = %heat_exit_8R;
	anim.coverExit[ "heat_right" ][ 9 ] = %heat_exit_8R;


	for ( i = 1; i <= 6; i++ )
	{
		if ( i == 5 )
			continue;

		for ( j = 0; j < transTypes.size; j++ )
		{
			trans = transTypes[ j ];

			if ( isdefined( anim.coverTrans[ trans ][ i ] ) )
			{
				anim.coverTransDist  [ trans ][ i ] = getMoveDelta( anim.coverTrans[ trans ][ i ], 0, 1 );
				anim.coverTransAngles[ trans ][ i ] = getAngleDelta( anim.coverTrans[ trans ][ i ], 0, 1 );
			}

			if ( isdefined( anim.coverExit [ trans ] ) && isdefined( anim.coverExit [ trans ][ i ] ) )
			{
				// get exit dist only to code_move
				if ( animHasNotetrack( anim.coverExit[ trans ][ i ], "code_move" ) )
					codeMoveTime = getNotetrackTimes( anim.coverExit[ trans ][ i ], "code_move" )[ 0 ];
				else
					codeMoveTime = 1;

				anim.coverExitDist   [ trans ][ i ] = getMoveDelta( anim.coverExit [ trans ][ i ], 0, codeMoveTime );
				anim.coverExitAngles [ trans ][ i ] = getAngleDelta( anim.coverExit [ trans ][ i ], 0, 1 );
			}
		}
	}
	
	for ( j = 0; j < transTypes.size; j++ )
	{
		trans = transTypes[ j ];
		
		anim.coverTransLongestDist[ trans ] = 0;

		for ( i = 1; i <= 6; i++ )
		{
			if ( i == 5 || !isdefined( anim.coverTrans[ trans ][ i ] ) )
				continue;
		
			lengthSq = lengthSquared( anim.coverTransDist[ trans ][ i ] );
			if ( anim.coverTransLongestDist[ trans ] < lengthSq )
				anim.coverTransLongestDist[ trans ] = lengthSq;
		}

		anim.coverTransLongestDist[ trans ] = sqrt( anim.coverTransLongestDist[ trans ] );
	}

	anim.exposedTransition[ "exposed" ] = true;
	anim.exposedTransition[ "exposed_crouch" ] = true;
	anim.exposedTransition[ "exposed_cqb" ] = true;
	anim.exposedTransition[ "exposed_crouch_cqb" ] = true;
	anim.exposedTransition[ "heat" ] = true;
	
	anim.longestExposedApproachDist = 0;

	foreach ( trans, transType in anim.exposedTransition )
	{
		for ( i = 7; i <= 9; i++ )
		{
			if ( isdefined( anim.coverTrans[ trans ][ i ] ) )
			{
				anim.coverTransDist  [ trans ][ i ] = getMoveDelta( anim.coverTrans[ trans ][ i ], 0, 1 );
				anim.coverTransAngles[ trans ][ i ] = getAngleDelta( anim.coverTrans[ trans ][ i ], 0, 1 );
			}

			if ( isdefined( anim.coverExit [ trans ][ i ] ) )
			{
				// get exit dist only to code_move
				assert( animHasNotetrack( anim.coverExit[ trans ][ i ], "code_move" ) );
				codeMoveTime = getNotetrackTimes( anim.coverExit[ trans ][ i ], "code_move" )[ 0 ];

				anim.coverExitDist   [ trans ][ i ] = getMoveDelta( anim.coverExit [ trans ][ i ], 0, codeMoveTime );
				anim.coverExitAngles [ trans ][ i ] = getAngleDelta( anim.coverExit [ trans ][ i ], 0, 1 );
			}
		}

		for ( i = 1; i <= 9; i++ )
		{
			if ( !isdefined( anim.coverTrans[ trans ][ i ] ) )
				continue;

			len = length( anim.coverTransDist[ trans ][ i ] );
			if ( len > anim.longestExposedApproachDist )
				anim.longestExposedApproachDist = len;
		}
	}


 	// the FindBestSplitTime calls below are used to find these values.
	// all of this is for corner nodes.

	anim.coverTransSplit[ "left" ][ 7 ] = 0.5;// delta of( 35.5356, 3.27114, 0 )
	anim.coverTransSplit[ "left_crouch" ][ 7 ] = 0.448; // delta of (32.2281, 0.356673, 0)
	anim.coverTransSplit[ "left_cqb" ][ 7 ] = 0.5; // delta of (33.1115, 1.05645, 0)
	anim.coverTransSplit[ "left_crouch_cqb" ][ 7 ] = 0.448; // delta of (34.2986, 2.32586, 0)
	anim.coverExitSplit[ "left" ][ 7 ] = 0.52;// delta of( 37.5652, 5.61999, 0 )
	anim.coverExitSplit[ "left_crouch" ][ 7 ] = 0.55;// delta of( 35.9166, 3.88091, 0 )
	anim.coverExitSplit[ "left_cqb" ][ 7 ] = 0.52; // delta of (32.9692, 0.881301, 0)
	anim.coverExitSplit[ "left_crouch_cqb" ][ 7 ] = 0.55; // delta of (33.6642, 1.70904, 0)
	anim.coverExitSplit[ "heat_left" ][ 7 ] = 0.42;
	
	anim.coverTransSplit[ "left" ][ 8 ] = 0.38;// delta of( 32.9863, 0.925748, 0 )
	anim.coverTransSplit[ "left_crouch" ][ 8 ] = 0.5;// delta of( 38.4125, 6.445, 0 )
	anim.coverTransSplit[ "left_cqb" ][ 8 ] = 0.38; // delta of (33.892, 1.86121, 0)
	anim.coverTransSplit[ "left_crouch_cqb" ][ 8 ] = 0.5; // delta of (35.8107, 3.70985, 0)
	anim.coverExitSplit[ "left" ][ 8 ] = 0.442;// delta of( 34.298, 2.26239, 0 )
	anim.coverExitSplit[ "left_crouch" ][ 8 ] = 0.6; // delta of (33.0388, 0.964628, 0)
	anim.coverExitSplit[ "left_cqb" ][ 8 ] = 0.442; // delta of (35.6563, 3.64754, 0))
	anim.coverExitSplit[ "left_crouch_cqb" ][ 8 ] = 0.6; // delta of (33.0797, 1.14774, 0)
	anim.coverExitSplit[ "heat_left" ][ 8 ] = 0.42;

	anim.coverTransSplit[ "right" ][ 8 ] = 0.561562;// delta of( 35.6571, 3.63511, 0 )
 	anim.coverTransSplit[ "right_crouch" ][ 8 ] = 0.521522; // delta of (34.6368, 2.67554, 0)
 	anim.coverTransSplit[ "right_cqb" ][ 8 ] = 0.561562; // delta of (35.6571, 3.63511, 0)
 	anim.coverTransSplit[ "right_crouch_cqb" ][ 8 ] = 0.521522; // delta of (34.2736, 2.32471, 0)
	anim.coverExitSplit[ "right" ][ 8 ] = 0.316316;// delta of( 36.3085, 4.34586, 0 )
	anim.coverExitSplit[ "right_crouch" ][ 8 ] = 0.386386; // delta of (33.1181, 1.14301, -0.0001)
	anim.coverExitSplit[ "right_cqb" ][ 8 ] = 0.316316; // delta of (33.0089, 1.0005, 0)
	anim.coverExitSplit[ "right_crouch_cqb" ][ 8 ] = 0.386386; // delta of (34.7739, 2.41176, 0)
	anim.coverExitSplit[ "heat_right" ][ 8 ] = 0.4;

	anim.coverTransSplit[ "right" ][ 9 ] = 0.41041;// delta of( 37.7732, 5.76641, 0 )
	anim.coverTransSplit[ "right_crouch" ][ 9 ] = 0.518519; // delta of (36.3871, 4.39434, 0)
	anim.coverTransSplit[ "right_cqb" ][ 9 ] = 0.41041;// delta of( 37.7732, 5.76641, 0 )
	anim.coverTransSplit[ "right_crouch_cqb" ][ 9 ] = 0.232232518519; // delta of (35.8102, 3.81592, 0)
	anim.coverExitSplit[ "right" ][ 9 ] = 0.365365; // delta of (35.251, 3.31115, 0)
	anim.coverExitSplit[ "right_crouch" ][ 9 ] = 0.376376; // delta of (34.4959, 2.45688, -0.0001)
	anim.coverExitSplit[ "right_cqb" ][ 9 ] = 0.365365; // delta of (35.4487, 3.42926, 0)
	anim.coverExitSplit[ "right_crouch_cqb" ][ 9 ] = 0.376376; // delta of (35.4592, 1.47273, 0)
	anim.coverExitSplit[ "heat_right" ][ 9 ] = 0.4;

	/#
	setDvarIfUninitialized( "scr_findsplittimes", "0" );
	#/
	
	splitArrivals = [];
	splitArrivals[ "left" ] = 1;
	splitArrivals[ "left_crouch" ] = 1;
	splitArrivals[ "left_crouch_cqb" ] = 1;
	splitArrivals[ "left_cqb" ] = 1;
	
	splitExits = [];
	splitExits[ "left" ] = 1;
	splitExits[ "left_crouch" ] = 1;
	splitExits[ "left_crouch_cqb" ] = 1;
	splitExits[ "left_cqb" ] = 1;
	splitExits[ "heat_left" ] = 1;

	GetSplitTimes( 7, 8, false, splitArrivals, splitExits );

	
	splitArrivals = [];
	splitArrivals[ "right" ] = 1;
	splitArrivals[ "right_crouch" ] = 1;
	splitArrivals[ "right_cqb" ] = 1;
	splitArrivals[ "right_crouch_cqb" ] = 1;
	
	splitExits = [];
	splitExits[ "right" ] = 1;
	splitExits[ "right_crouch" ] = 1;
	splitExits[ "right_cqb" ] = 1;
	splitExits[ "right_crouch_cqb" ] = 1;
	splitExits[ "heat_right" ] = 1;
	
	GetSplitTimes( 8, 9, true, splitArrivals, splitExits );


	 /#
	//thread checkApproachAngles( transTypes );
	#/
	
	anim.arrivalEndStance["left"]			= "stand";
	anim.arrivalEndStance["left_cqb"]		= "stand";
	anim.arrivalEndStance["right"]			= "stand";
	anim.arrivalEndStance["right_cqb"]		= "stand";
	anim.arrivalEndStance["stand"]			= "stand";
	anim.arrivalEndStance["stand_saw"]		= "stand";
	anim.arrivalEndStance["exposed"]		= "stand";
	anim.arrivalEndStance["exposed_cqb"]	= "stand";
	anim.arrivalEndStance["heat"]			= "stand";
	anim.arrivalEndStance["left_crouch"]	= "crouch";
	anim.arrivalEndStance["left_crouch_cqb"] = "crouch";
	anim.arrivalEndStance["right_crouch"]	= "crouch";
	anim.arrivalEndStance["right_crouch_cqb"] = "crouch";
	anim.arrivalEndStance["crouch_saw"]		= "crouch";
	anim.arrivalEndStance["crouch"]			= "crouch";
	anim.arrivalEndStance["exposed_crouch"] = "crouch";
	anim.arrivalEndStance["exposed_crouch_cqb"] = "crouch";
	anim.arrivalEndStance["prone_saw"]		= "prone";

	anim.requiredExitStance[ "Cover Stand" ] = "stand";
	anim.requiredExitStance[ "Conceal Stand" ] = "stand";
	anim.requiredExitStance[ "Cover Crouch" ] = "crouch";
	anim.requiredExitStance[ "Conceal Crouch" ] = "crouch";
}


GetSplitTimes( begin, end, isRightSide, splitArrivals, splitExits )
{
	for ( i = begin; i <= end; i++ )
	{
		foreach ( type, val in splitArrivals )
		{
			anim.coverTransPreDist[ type ][ i ] = getMoveDelta( anim.coverTrans[ type ][ i ], 0, getTransSplitTime( type, i ) );
			anim.coverTransDist   [ type ][ i ] = getMoveDelta( anim.coverTrans[ type ][ i ], 0, 1 ) - anim.coverTransPreDist[ type ][ i ];
			anim.coverTransAngles [ type ][ i ] = getAngleDelta( anim.coverTrans[ type ][ i ], 0, 1 );
		}

		foreach ( type, val in splitExits )
		{
			anim.coverExitDist    [ type ][ i ] = getMoveDelta( anim.coverExit [ type ][ i ], 0, getExitSplitTime( type, i ) );
			anim.coverExitPostDist[ type ][ i ] = getMoveDelta( anim.coverExit [ type ][ i ], 0, 1 ) - anim.coverExitDist[ type ][ i ];
			anim.coverExitAngles  [ type ][ i ] = getAngleDelta( anim.coverExit [ type ][ i ], 0, 1 );
		}

		/#
		if ( getdebugdvar( "scr_findsplittimes" ) != "0" )
		{
			foreach ( type, val in splitArrivals )
			{
				if ( isSubStr( type, "heat" ) )
					continue;
					
				FindBestSplitTime( anim.coverTrans[ type ][ i ], true, isRightSide, "anim.coverTransSplit[ \"" + type + "\" ][ " + i + " ]", type + " arrival in dir " + i );
				AssertIsValidSplitDelta( DeltaRotate( anim.coverTransDist[ type ][ i ], 180 - anim.coverTransAngles[ type ][ i ] ), isRightSide, type + " arrival in dir " + i );
			}

			foreach ( type, val in splitExits )
			{
				if ( isSubStr( type, "heat" ) )
					continue;

				FindBestSplitTime( anim.coverExit [ type ][ i ], false, isRightSide, "anim.coverExitSplit[ \"" + type + "\" ][ " + i + " ]", type + " exit in dir " + i );
				AssertIsValidSplitDelta( anim.coverExitDist[ type ][ i ], isRightSide, type + " exit in dir " + i );
			}
		}
		#/
	}
}

/#
FindBestSplitTime( exitanim, isapproach, isright, arrayname, debugname )
{
	angleDelta = getAngleDelta( exitanim, 0, 1 );
	fullDelta = getMoveDelta( exitanim, 0, 1 );
	numiter = 1000;

	bestsplit = -1;
	bestvalue = -100000000;
	bestdelta = ( 0, 0, 0 );

	for ( i = 0; i < numiter; i++ )
	{
		splitTime = 1.0 * i / ( numiter - 1 );

		delta = getMoveDelta( exitanim, 0, splitTime );
		if ( isapproach )
			delta = DeltaRotate( fullDelta - delta, 180 - angleDelta );
		if ( isright )
			delta = ( delta[ 0 ], 0 - delta[ 1 ], delta[ 2 ] );

		val = min( delta[ 0 ] - 32, delta[ 1 ] );

		if ( val > bestvalue || bestsplit < 0 )
		{
			bestvalue = val;
			bestsplit = splitTime;
			bestdelta = delta;
		}
	}

	if ( bestdelta[ 0 ] < 32 || bestdelta[ 1 ] < 0 )
	{
		println( "^0 ^1" + debugname + " has no valid split time available! Best was at " + bestsplit + ", delta of " + bestdelta );
		return;
	}
	//println("^0 ^2" + debugname + " has best split time at " + bestsplit + ", delta of " + bestdelta );
	println( "^0 ^2" + arrayname + " = " + bestsplit + "; // delta of " + bestdelta );
}


DeltaRotate( delta, yaw )
{
	cosine = cos( yaw );
	sine = sin( yaw );
	return( delta[ 0 ] * cosine - delta[ 1 ] * sine, delta[ 1 ] * cosine + delta[ 0 ] * sine, 0 );
}

AssertIsValidSplitDelta( delta, isRightSide, debugname )
{
	if ( isRightSide )
		delta = ( delta[ 0 ], 0 - delta[ 1 ], delta[ 2 ] );

	// in a delta, x is forward and y is left

	// assert the delta goes out far enough from the node
	if ( delta[ 0 ] < 32 )
		println( "^0 ^1" + debugname + " doesn't go out from the node far enough in the given split time (delta = " + delta + ")" );

	// assert the delta doesn't go into the wall
	if ( delta[ 1 ] < 0 )
		println( "^0 ^1" + debugname + " goes into the wall during the given split time (delta = " + delta + ")" );
}

checkApproachAngles( transTypes )
{
	idealTransAngles[ 1 ] = 45;
	idealTransAngles[ 2 ] = 0;
	idealTransAngles[ 3 ] = -45;
	idealTransAngles[ 4 ] = 90;
	idealTransAngles[ 6 ] = -90;
	idealTransAngles[ 7 ] = 135;
	idealTransAngles[ 8 ] = 180;
	idealTransAngles[ 9 ] = -135;

	wait .05;

	for ( i = 1; i <= 9; i++ )
	{
		for ( j = 0; j < transTypes.size; j++ )
		{
			trans = transTypes[ j ];

			idealAdd = 0;
			if ( trans == "left" || trans == "left_crouch" )
				idealAdd = 90;
			else if ( trans == "right" || trans == "right_crouch" )
				idealAdd = -90;

			if ( isdefined( anim.coverTransAngles[ trans ][ i ] ) )
			{
				correctAngle = AngleClamp180( idealTransAngles[ i ] + idealAdd );
				actualAngle = AngleClamp180( anim.coverTransAngles[ trans ][ i ] );
				if ( AbsAngleClamp180( actualAngle - correctAngle ) > 7 )
				{
					println( "^1Cover approach animation has bad yaw delta: anim.coverTrans[\"" + trans + "\"][" + i + "]; is ^2" + actualAngle + "^1, should be closer to ^2" + correctAngle + "^1." );
				}
			}
		}
	}

	for ( i = 1; i <= 9; i++ )
	{
		for ( j = 0; j < transTypes.size; j++ )
		{
			trans = transTypes[ j ];

			idealAdd = 0;
			if ( trans == "left" || trans == "left_crouch" )
				idealAdd = 90;
			else if ( trans == "right" || trans == "right_crouch" )
				idealAdd = -90;

			if ( isdefined( anim.coverExitAngles[ trans ][ i ] ) )
			{
				correctAngle = AngleClamp180( -1 * ( idealTransAngles[ i ] + idealAdd + 180 ) );
				actualAngle = AngleClamp180( anim.coverExitAngles[ trans ][ i ] );
				if ( AbsAngleClamp180( actualAngle - correctAngle ) > 7 )
				{
					println( "^1Cover exit animation has bad yaw delta: anim.coverTrans[\"" + trans + "\"][" + i + "]; is ^2" + actualAngle + "^1, should be closer to ^2" + correctAngle + "^1." );
				}
			}
		}
	}
}
#/

getExitSplitTime( approachType, dir )
{
	exitAnim = anim.coverExit[ approachType ][ dir ];
	if ( animHasNotetrack( exitAnim, "split_time" ) )
	{
	   	exitAlignTimes = getNotetrackTimes( exitAnim, "split_time" );

		assert( exitAlignTimes.size == 1 );
		if ( exitAlignTimes.size == 0 )
		{
			return anim.coverExitSplit[ approachType ][ dir ];
		}
		
		return exitAlignTimes[0];
	}

	return anim.coverExitSplit[ approachType ][ dir ];
}

getTransSplitTime( approachType, dir )
{
	arrivalAnim = anim.coverTrans[ approachType ][ dir ];
	if ( animHasNotetrack( arrivalAnim, "split_time" ) )
	{
	   	arrivalSplitTimes = getNotetrackTimes( arrivalAnim, "split_time" );

		assert( arrivalSplitTimes.size == 1 );
		if ( arrivalSplitTimes.size == 0 )
		{
			return anim.coverTransSplit[ approachType ][ dir ];
		}
		
		return arrivalSplitTimes[0];
	}

	return anim.coverTransSplit[ approachType ][ dir ];
}

init_moon_transition_points()
{
	anim.run_transition_notes = [];
	anim.run_transition_points = [];

	anim.run_transition_notes[ anim.run_transition_notes.size ] = "move_transition_run_r_down";
	anim.run_transition_points[ anim.run_transition_points.size ] = 0.2537;

	anim.run_transition_notes[ anim.run_transition_notes.size ] = "move_transition_run_l_down";
	anim.run_transition_points[ anim.run_transition_points.size ] = 0.5074;

	anim.cqb_transition_notes = [];
	anim.cqb_transition_points = [];

	//entrance for starting the loop at a run with the right foot down
	anim.cqb_transition_notes[ anim.cqb_transition_notes.size ] = "move_transition_run_r_down";
	anim.cqb_transition_points[ anim.cqb_transition_points.size ] = 0.48;

	anim.cqb_transition_notes[ anim.cqb_transition_notes.size ] = "move_transition_run_l_down";
	anim.cqb_transition_points[ anim.cqb_transition_points.size ] = 0.24;

	anim.cqb_transition_notes[ anim.cqb_transition_notes.size ] = "move_transition_start 2";
	anim.cqb_transition_points[ anim.cqb_transition_points.size ] = 0.6;
}

