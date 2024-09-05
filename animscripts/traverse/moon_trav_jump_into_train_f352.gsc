#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %tp_moon_lava_jump_into_train_f352;
	traverseData[ "traverseToCoverAnim" ]	 = %tp_moon_lava_jump_into_train_f352;
	traverseData[ "coverType" ]				 = "Cover Crouch";
	
	DoTraverse( traverseData );
}

