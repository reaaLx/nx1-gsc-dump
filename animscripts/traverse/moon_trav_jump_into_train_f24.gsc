#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %tp_moon_lava_jump_into_train_f24;
	traverseData[ "traverseToCoverAnim" ]	 = %tp_moon_lava_jump_into_train_f24;
	traverseData[ "coverType" ]				 = "Exposed";
	
	DoTraverse( traverseData );
}

