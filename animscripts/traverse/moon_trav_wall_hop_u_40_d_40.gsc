// moon_trav_wall_hop_u_40_d_40.gsc
// Makes the character climb a 40 unit fence, lunar

#include animscripts\traverse\shared;

main()
{
	wall_hop_human();
}

#using_animtree( "generic_human" );

wall_hop_human()
{
	if( !IsDefined( level.moon_trav_wall_hop_toggle ) )
	{
		level.moon_trav_wall_hop_toggle = 1;
	}

	if ( level.moon_trav_wall_hop_toggle == 1 )
	{
		level.moon_trav_wall_hop_toggle = 0;

		traverseData = [];
		traverseData[ "traverseAnim" ]			 = %tp_moon_trav_jump_u40_f_d40_a;
	
		DoTraverse( traverseData );

	}
	else
	{
		level.moon_trav_wall_hop_toggle = 1;

		traverseData = [];
		traverseData[ "traverseAnim" ]			 = %tp_moon_trav_jump_u40_f_d40_b;
	
		DoTraverse( traverseData );

	}
}