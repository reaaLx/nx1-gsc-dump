#include common_scripts\utility;

#using_animtree( "animated_props" );
main()
{
	if( !isdefined ( level._anim_prop_models ) )
		level._anim_prop_models = [];
		
	// Would use isSP() but this runs before we can
	mapname = tolower( getdvar( "mapname" ) );
	SP = true;
	if ( string_starts_with( mapname, "mp_" ) )
		SP = false;
		
	model = "nx_pr_exfil_swinging_flag_04";
	if ( SP )
	{
		level._anim_prop_models[ model ][ "wind" ] = %nx_pr_exfil_swinging_flag_slow_04;
	}
	else
		level._anim_prop_models[ model ][ "wind" ] = "nx_pr_exfil_swinging_flag_slow_04";
}
