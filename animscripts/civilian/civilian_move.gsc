#include animscripts\Utility;

#using_animtree( "generic_human" );

main()
{
	animscripts\move::main();
}


civilian_nonCombatMoveTurn( angleDiff )
{
	assert( isdefined( level._scr_anim[ self.animname ][ "turn_left_90" ] ) );
	assert( isdefined( level._scr_anim[ self.animname ][ "turn_right_90" ] ) );

	turnAnim = undefined;

	if ( angleDiff < -60 && angleDiff > -120 )
		turnAnim = level._scr_anim[ self.animname ][ "turn_left_90" ];
		
	if ( angleDiff > 60 && angleDiff < 120 )
		turnAnim = level._scr_anim[ self.animname ][ "turn_right_90" ];
		
	if ( isdefined( turnAnim ) && animscripts\move::pathChange_canDoTurnAnim( turnAnim ) )
		return turnAnim;
	else
		return undefined;
}

//7     9    <- 8 is invalid, it's straight.
//4     6	 <- 5 is invalid, it's not a turn.
//1  2  3
civilian_combatMoveTurn( angleDiff )
{
	turnDir = -1;
	turnAnim = undefined;

	if ( angleDiff < -22.5 )
	{
		if ( angleDiff > -45 )
			turnDir = 7;
		else if ( angleDiff > -112.5 )
			turnDir = 4;
		else if ( angleDiff > -157.5 )
			turnDir = 1;
		else
			turnDir = 2;
	}
	else if ( angleDiff > 22.5 )
	{
		if ( angleDiff < 45 )
			turnDir = 9;
		else if ( angleDiff < 112.5 )
			turnDir = 6;
		else if ( angleDiff < 157.5 )
			turnDir = 3;
		else
			turnDir = 2;
	}
	
	if ( IsDefined(level._scr_anim[ self.animname ]) 
		&& IsDefined(level._scr_anim[ self.animname ][ "run_combat_turn" ]) 
		&& IsDefined(level._scr_anim[ self.animname ][ "run_combat_turn" ][turnDir]) )
	{
		turnAnim = level._scr_anim[ self.animname ][ "run_combat_turn" ][turnDir];
	}

	if ( IsDefined( turnAnim ) && animscripts\move::pathChange_canDoTurnAnim( turnAnim ) )
		return turnAnim;
	else
		return undefined;
}


civilian_combatHunchedMoveTurn( angleDiff )
{
	turnDir = -1;
	turnAnim = undefined;
	largeTurnAnim = undefined;

	if ( angleDiff < -22.5 )
	{
		if ( angleDiff > -45 )
			turnDir = 7;
		else if ( angleDiff > -112.5 )
			turnDir = 4;
		else if ( angleDiff > -157.5 )
			turnDir = 1;
		else
			turnDir = 2;
	}
	else if ( angleDiff > 22.5 )
	{
		if ( angleDiff < 45 )
			turnDir = 9;
		else if ( angleDiff < 112.5 )
			turnDir = 6;
		else if ( angleDiff < 157.5 )
			turnDir = 3;
		else
			turnDir = 2;
	}
	
	if ( IsDefined(level._scr_anim[ self.animname ]) 
		&& IsDefined(level._scr_anim[ self.animname ][ "run_combat_hunched_large_turn" ]) 
		&& IsDefined(level._scr_anim[ self.animname ][ "run_combat_hunched_large_turn" ][turnDir]) )
	{
		largeTurns = level._scr_anim[ self.animname ][ "run_combat_hunched_large_turn" ][turnDir];
		if ( largeTurns.size > 0 )
		{
			largeTurnAnim = largeTurns[RandomInt(largeTurns.size)];
		}
		else
		{
			largeTurnAnim = undefined;
		}	
	}

	if ( IsDefined( largeTurnAnim ) && ( RandomInt( 3 ) < 2 ) && animscripts\move::pathChange_canDoTurnAnim( largeTurnAnim ) )
		return largeTurnAnim;
		
	if ( IsDefined(level._scr_anim[ self.animname ]) 
		&& IsDefined(level._scr_anim[ self.animname ][ "run_combat_hunched_turn" ]) 
		&& IsDefined(level._scr_anim[ self.animname ][ "run_combat_hunched_turn" ][turnDir]) )
	{
		turnAnim = level._scr_anim[ self.animname ][ "run_combat_hunched_turn" ][turnDir];
	}

	if ( isdefined( turnAnim ) && animscripts\move::pathChange_canDoTurnAnim( turnAnim ) )
		return turnAnim;
	else
		return undefined;
}