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
		
	model = "hanging_short_sleeve";
	if ( SP )
		level._anim_prop_models[ model ][ "wind_medium" ] = %hanging_clothes_short_sleeve_wind_medium;
	else
		level._anim_prop_models[ model ][ "wind_medium" ] = "hanging_clothes_short_sleeve_wind_medium";
}
