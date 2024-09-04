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
 		
 	model = "foliage_tree_palm_tall_1";
 	if ( SP )
 	{
 		level._anim_prop_models[ model ][ "still" ] = %palmtree_tall1_still;
 		level._anim_prop_models[ model ][ "strong" ] = %palmtree_tall1_sway;
 	}
 	else
 		level._anim_prop_models[ model ][ "strong" ] = "palmtree_mp_tall1_sway";
 }