
#include animscripts\init_common;

main()
{
	prof_begin( "animscript_init" );
	
	pre_first_init();
	firstInit();	
	post_first_init();

	prof_end( "animscript_init" );
}

firstInit()
{
	// Initialization that should happen once per level
	if ( isDefined( anim.NotFirstTime ) )// Use this to trigger the first init
	{
		return false;
	}
		
	pre_anim_init();

	animscripts\lunar\animset::init_anim_sets();//lunar version
	animscripts\lunar\init_move_transitions::initMoveStartStopTransitions();

	anim.lastGibTime 	= 0;
	anim.gibDelay 		= 3 * 1000; // 3 seconds
	anim.minGibs		= 2;
	anim.maxGibs		= 4;
	anim.totalGibs		= RandomIntRange( anim.minGibs, anim.maxGibs );
	
	post_anim_init();
}
