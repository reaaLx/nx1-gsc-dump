#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %tp_moon_trav_jump_d160_f244;

	DoTraverse( traverseData );
}

