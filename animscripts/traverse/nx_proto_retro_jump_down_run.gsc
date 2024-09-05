#include animscripts\utility;
#include animscripts\traverse\shared;

main()
{
	if ( self.type == "dog" )
		dog_jump_down( 3, 1.0 );
	else
		retro_jump_down_human();
}

#using_animtree( "generic_human" );
retro_jump_down_human()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %nx_proto_retro_jump_down_run;

	DoTraverse( traverseData );
}
