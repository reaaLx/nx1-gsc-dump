#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %tp_moon_trav_storage_jump;

	DoTraverse( traverseData );
}

