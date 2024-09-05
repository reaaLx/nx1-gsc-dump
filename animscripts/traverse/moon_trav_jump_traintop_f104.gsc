#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %tp_moon_lava_jump_traintop_f104;
	traverseData[ "traverseToCoverAnim" ]	 = %tp_moon_lava_jump_traintop_f104;
	traverseData[ "coverType" ]				 = "Cover Right";
	traverseData[ "forceTeleport" ]			 = true;

	DoTraverse( traverseData );
}

