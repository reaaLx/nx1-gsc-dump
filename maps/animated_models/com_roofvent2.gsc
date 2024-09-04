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
		
	model = "com_roofvent2_animated";
	if ( SP )
	{
		level._anim_prop_models[ model ][ "rotate" ] = %roofvent_rotate;
	}
	else
		level._anim_prop_models[ model ][ "rotate" ] = "roofvent_rotate";
}