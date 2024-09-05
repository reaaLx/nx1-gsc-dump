#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#using_animtree( "generic_human" );

main( painter_spmp )
{
	if ( !getdvarint( "noder" ) )
	{
		return;
	}
	level._scr_anim[ "generic" ] = anim.noderAnims;

	level._node_offset = [];
	level._node_offset[ "node_cover_left" ] = ( 0, 90, 0 );
	level._node_offset[ "node_cover_right" ] = ( 0, -90, 0 );
	level._node_offset[ "node_pathnode" ] = ( 0, 0, 0 );
	level._node_offset[ "node_cover_crouch" ] = ( 0, 0, 0 );
	level._node_offset[ "node_cover_crouch_window" ] = ( 0, 0, 0 );
	level._node_offset[ "node_cover_prone" ] = ( 0, 0, 0 );
	level._node_offset[ "node_cover_stand" ] = ( 0, 0, 0 );
	level._node_offset[ "node_concealment_crouch" ] = ( 0, 0, 0 );
	level._node_offset[ "node_concealment_prone" ] = ( 0, 0, 0 );
	level._node_offset[ "node_concealment_stand" ] = ( 0, 0, 0 );
	level._noder_node_delete = false;

	//make a drone spawn work in this _load halting function..
	level._dronestruct = [];
	spawners = getspawnerarray();
	level._dummyguy_index_max = 0;
	level._dummyguy = [];



	if ( spawners.size )
	{
		spawner = spawners[ 0 ];
		spawner maps\_spawner::dronespawner_init();
		for ( i = 0;i < 20;i++ )
		{
			level._dummyguy[ i ] = maps\_spawner::spawner_dronespawn( spawner );
			level._dummyguy[ i ] notsolid();
			level._dummyguy[ i ] hide();
			level._dummyguy[ i ].dontdonotetracks = true;
			level._dummyguy[ i ].dummyguyindex = i;
			level._dummynode[ i ] = spawn( "script_origin", ( 0, 0, 0 ) );
			level._dummynode[ i ].dummynode = true;
			level._dummyguy_index_max++;

		}
	}
	level._dummyguy_index = 0;
	init();// _anim

	ents = getentarray();
	foreach ( ent in ents )
	{
		if ( isdefined( ent.classname ) && ent.classname == "player" || isdefined( ent.dontdonotetracks ) || isdefined( ent.dummynode ) )
			continue;

		if ( isdefined( ent ) )
			ent delete();
	}
	ents = undefined;

	level._place_node_radius = 64;
	level._place_node_group = [];
	level._painter_startgroup = "node_pathnode";
	level._placed_nodes = [];
	level._noder_heightoffset = ( 0, 0, 32 );
	level._wall_look = false;
	level._node_grid = 256;
	level._coliding_node = undefined;
	level._node_select_locked = false;
	level._node_animation_preview = true;

	add_node_type( "node_pathnode", undefined );
	add_node_type( "node_cover_crouch" );
	add_node_type( "node_cover_crouch_window" );
	add_node_type( "node_cover_left", -1 );
	add_node_type( "node_cover_right", 1 );
	add_node_type( "node_cover_prone" );
	add_node_type( "node_cover_stand" );
	add_node_type( "node_concealment_crouch" );
	add_node_type( "node_concealment_prone" );
	add_node_type( "node_concealment_stand" );

	thread hack_start();
	thread hud_init();
	thread noder_init();

	flag_wait( "user_hud_active" );
	thread draw_selected_node_name();
	thread manage_nearnodes();
	while ( 1 )
	{
		wait .05;
		level._player_view_trace = player_view_trace();
		//draw_placement_circle();
		place_node_place( true );// preview placement
	}
}

hack_start()
{
	//copied from _painter probably doesn't need all of this		
	flag_init( "user_alive" );
	while ( !isdefined( get_mp_player() ) )
		wait .05;

	wait .05;

	level._noder_player = get_mp_player();

	level._noder_player takeallweapons();
	level._noder_player allowcrouch( false );
	level._noder_player allowjump( false );
	level._noder_player allowprone( false );

	flag_set( "user_alive" );
}

noder_init()
{

	level._preview_node = spawn( "script_model", ( 0, 0, 0 ) );
	precachemodel( "node_preview" );
	level._preview_node setmodel( "node_preview" );
	level._preview_node notsolid();
	level._selector_model = spawn( "script_model", ( 0, 0, 0 ) );
	level._selector_model setmodel( "node_select" );
	level._selector_model notsolid();
	level._selector_model hide();
	level._selected_node = undefined;



	setcurrentgroup( level._painter_startgroup );
	level._painter_startgroup = undefined;
	playerInit();
}

hud_update_placed_model_count()
{
	level._hud_noder[ "helppm" ].description setvalue( level._placed_nodes.size );

	whitecap = 256;

	if ( level._placed_nodes.size < whitecap )
	{
		level._hud_noder[ "helppm" ].description.color = ( 1, 1, 1 );
		return;
	}

	r = 1;
	g = 1 - ( ( level._placed_nodes.size - whitecap ) / whitecap );
	b = g;

	level._hud_noder[ "helppm" ].description.color = ( r, g, b );
}

controler_hud_add( identifier, inc, initial_text, initial_description_text, initial_value )
{
	startx = 520;
	starty = 120;
	space = 18;
	basealpha = .8;
	denradoffset = 20;
	descriptionscale = 1.4;

	if ( !isdefined( level._hud_noder ) || !isdefined( level._hud_noder[ identifier ] ) )
	{
		level._hud_noder[ identifier ] = _newhudelem();
		description = _newhudelem();
	}
	else
		description = level._hud_noder[ identifier ].description;

	level._hud_noder[ identifier ].location = 0;
	level._hud_noder[ identifier ].alignX = "right";
	level._hud_noder[ identifier ].alignY = "middle";
	level._hud_noder[ identifier ].foreground = 1;
	level._hud_noder[ identifier ].fontscale = 1.5;
	level._hud_noder[ identifier ].sort = 20;
	level._hud_noder[ identifier ].alpha = basealpha;
	level._hud_noder[ identifier ].x = startx + denradoffset;
	level._hud_noder[ identifier ].y = starty + ( inc * space );
	level._hud_noder[ identifier ] _settext( initial_text );

	description.location = 0;
	description.alignX = "left";
	description.alignY = "middle";
	description.foreground = 1;
	description.fontscale = descriptionscale;
	description.sort = 20;
	description.alpha = basealpha;
	description.x = startx + denradoffset;
	description.y = starty + ( inc * space );
	if ( isdefined( initial_value ) )
		description setvalue( initial_value );
	if ( isdefined( initial_description_text ) )
		description _settext( initial_description_text );
	level._hud_noder[ identifier ].description = description;

}

hud_init()
{
	flag_init( "user_hud_active" );
	flag_wait( "user_alive" );

	listsize = 17;

	hudelems = [];
	spacer = 15;
	div = int( listsize / 2 );
	org = 240 + div * spacer;
	alphainc = .7 / div;
	alpha = alphainc;

	for ( i = 0;i < listsize;i++ )
	{
		hudelems[ i ] = _newhudelem();
		hudelems[ i ].location = 0;
		hudelems[ i ].alignX = "left";
		hudelems[ i ].alignY = "middle";
		hudelems[ i ].foreground = 1;
		hudelems[ i ].fontScale = 2;
		hudelems[ i ].sort = 20;
		if ( i == div )
			hudelems[ i ].alpha = 1;
		else
			hudelems[ i ].alpha = alpha;

		hudelems[ i ].x = 0;
		hudelems[ i ].y = org;
		// .
		hudelems[ i ] _settext( "." );

		if ( i == div )
			alphainc *= -1;

		alpha += alphainc;

		org -= spacer;
	}

	level._group_hudelems = hudelems;

	crossHair = _newhudelem();
	crossHair.location = 0;
	crossHair.alignX = "left";
	crossHair.alignY = "bottom";
	crossHair.foreground = 1;
	crossHair.fontScale = 2;
	crossHair.sort = 20;
	crossHair.alpha = 1;
	crossHair.x = 320;
	crossHair.y = 244;
	// .
	crossHair _settext( "." );
	level._crosshair = crossHair;

	crossHair = _newhudelem();
	crossHair.location = 0;
	crossHair.alignX = "center";
	crossHair.alignY = "bottom";
	crossHair.foreground = 1;
	crossHair.fontScale = 2;
	crossHair.sort = 20;
	crossHair.alpha = 0;
	crossHair.x = 320;
	crossHair.y = 244;
	crossHair setvalue( 0 );
	level._crosshair_value = crossHair;

	selection_lock_indicator = _newhudelem();
	selection_lock_indicator.location = 0;
	selection_lock_indicator.alignX = "center";
	selection_lock_indicator.alignY = "bottom";
	selection_lock_indicator.foreground = 1;
	selection_lock_indicator.fontScale = 2;
	selection_lock_indicator.sort = 20;
	selection_lock_indicator.alpha = 1;
	selection_lock_indicator.x = 320;
	selection_lock_indicator.y = 300;
	// .
	selection_lock_indicator _settext( "" );
	level._selection_lock_indicator = selection_lock_indicator;

	node_animation_preview_indicator = _newhudelem();
	node_animation_preview_indicator.location = 0;
	node_animation_preview_indicator.alignX = "center";
	node_animation_preview_indicator.alignY = "bottom";
	node_animation_preview_indicator.foreground = 1;
	node_animation_preview_indicator.fontScale = 2;
	node_animation_preview_indicator.sort = 20;
	node_animation_preview_indicator.alpha = 1;
	node_animation_preview_indicator.x = 320;
	node_animation_preview_indicator.y = 300;
	// .
	node_animation_preview_indicator _settext( "" );
	level._node_animation_preview_indicator = node_animation_preview_indicator;

	startx = 550;
	starty = 120;
	space = 18;
	inc = 1;
	basealpha = .8;
	denradoffset = 20;

	descriptionscale = 1.4;

	controler_hud_add( "helppm", 1, "^5Placed Nodes: ", undefined, level._placed_nodes.size );
	controler_hud_add( "gridsize", 2, "^5Grid Size: ", undefined, level._node_grid );
	controler_hud_add( "helpxy", 6, "^4X/^3Y: ", undefined, level._place_node_radius );
	controler_hud_add( "helpab", 7, "^2A/^1B^7: ", "-" );
	controler_hud_add( "helplsrs", 8, "^8L^7/R Stick: ", "-" );
	controler_hud_add( "helplbrb", 9, "^8L^7/R Shoulder: ", "-" );
	controler_hud_add( "helpdpu", 10, "^8DPad U/^7D: ", "-" );
	controler_hud_add( "helpdpl", 11, "^8DPad L/^7R: ", "-" );
	controler_hud_add( "helpF", 17, "^8W: ", "-" );
	level._hud_noder[ "helpF" ].x = startx - 450;
	level._hud_noder[ "helpF" ].description.x = startx - 450;

	hint_buttons_main();

	flag_set( "user_hud_active" );
}

controler_hud_update_text( hudid, text )
{
	level._hud_noder[ hudid ].description _settext( text );
}

controler_hud_update_button( hudid, text )
{
	level._hud_noder[ hudid ] _settext( text );
}


setcurrentgroup( group )
{
	flag_wait( "user_hud_active" );
	level._place_node_current_group = group;

	keys = getarraykeys( level._place_node_group );

	index = 0;
	div = int( level._group_hudelems.size / 2 );
	for ( i = 0;i < keys.size;i++ )
		if ( keys[ i ] == group )
		{
			index = i;
			break;
		}

	for ( i = 0; i < level._group_hudelems.size; i++ )
		level._group_hudelems[ i ] clearalltextafterhudelem();

	level._group_hudelems[ div ] _settext( "^3" + gettext_nonode( keys[ index ] ) );

	for ( i = 1;i < level._group_hudelems.size - div;i++ )
	{
			if ( index - i < 0 )
			{
				//  -- -- 
				level._group_hudelems[ div + i ] _settext( "-- --" );
				continue;
			}
			level._group_hudelems[ div + i ] _settext( gettext_nonode( keys[ index - i ] ) );
	}

	for ( i = 1;i < level._group_hudelems.size - div;i++ )
	{
			if ( index + i > keys.size - 1 )
			{
				//  -- -- 
				level._group_hudelems[ div - i ] _settext( "-- --" );
				continue;
			}
			level._group_hudelems[ div - i ] _settext( gettext_nonode( keys[ index + i ] ) );

	}
	group = getcurrent_groupstruct();
	level._node_grid = group.grid_size;
	hud_update_gridsize();

}

setgroup_up()
{
		index = undefined;
		keys = getarraykeys( level._place_node_group );
		for ( i = 0;i < keys.size;i++ )
			if ( keys[ i ] == level._place_node_current_group )
			{
				index = i + 1;
				break;
			}
		if ( index == keys.size )
			index = 0;
		setcurrentgroup( keys[ index ] );
}

setgroup_down()
{
		index = undefined;
		keys = getarraykeys( level._place_node_group );
		for ( i = 0;i < keys.size;i++ )
			if ( keys[ i ] == level._place_node_current_group )
			{
				index = i - 1;
				break;
			}
		if ( index < 0 )
			index = keys.size - 1;
		setcurrentgroup( keys[ index ] );
}

add_node_type( type, wall_snap_direction, grid_size )
{
	//may farther complicate with corner nodes using different 
	if ( !isdefined( wall_snap_direction ) )
		wall_snap_direction = 0;

	if ( !isdefined( grid_size ) )
		grid_size = 0;

	precachemodel( type );// assumes model is same name as type
	if ( !isdefined( level._place_node_group[ type ] ) )
	{
		struct = spawnstruct();
		struct.wall_snap_direction = wall_snap_direction;
		struct.grid_size = grid_size;
		level._place_node_group[ type ] = struct;
	}
	level._place_node_group[ type ].model = type;
}

playerInit()
{
	level._noder_max = 950;

	flag_wait( "user_hud_active" );
 	level._noder_player takeAllWeapons();

	level._button_modifier_func = [];
	level._button_func = [];
	level._noder_player thread button_monitor();
	level._noder_player thread button_modifier();

	set_button_funcs_main();
	add_button_modifier_func( ::set_button_funcs_quick_select, ::set_button_funcs_quick_select_release, "BUTTON_LSTICK" );

}

button_modifier()
{
	while ( 1 )
	{
		foreach ( button, blah in level._button_modifier_func )
		if ( self buttonpressed( button ) )
		{
			[[ level._button_modifier_func[ button ] ]]();
			while ( self buttonpressed( button ) )
				wait .05;
			assert( isdefined( level._button_modifier_release_func ) );
			[[ level._button_modifier_release_func[ button ] ]]();
			wait .05;

		}
		wait .05;
	}
}

button_monitor()
{
	while ( 1 )
	{
		foreach ( button, lalala in level._button_func )
		{
			if ( self buttonpressed( button ) )
			{
				[[ level._button_func[ button ] ]]();

				if ( !level._button_func_isflow[ button ] )
					while ( self buttonpressed( button ) )
						wait .05;
				break;
			}
		}
		wait .05;
	}
}

add_button_func( func, flow, button )
{
	buttons = [];
	assert( isdefined( button ) );
	level._button_func[ button ] = func;
	level._button_func_isflow[ button ] = flow;
}

add_button_modifier_func( func, releasefunc, button )
{
	assert( isdefined( button ) );
	level._button_modifier_func[ button ] = func;
	level._button_modifier_release_func[ button ] = releasefunc;
}

deleteme()
{
	self delete();
}

getcurrent_groupstruct()
{
	return level._place_node_group[ level._place_node_current_group ];
}

get_wall_offset( angles )
{
	trace = level._player_view_trace;
	point = trace[ "position" ];
	offset = 16 * vectornormalize( trace[ "normal" ] );

	dest_point = point + offset;

	corner_snap_origin = find_corner_snap( dest_point, angles );
	if ( isdefined( corner_snap_origin ) )
		dest_point = corner_snap_origin;
	return groundpos_loc( dest_point ) + level._noder_heightoffset;
}

find_corner_snap( dest_point, angles )
{
	group = getcurrent_groupstruct();
		dir = group.wall_snap_direction;

	if ( dir == 0 )
		return;

	start_dest = dest_point;
	org_start_dest = start_dest;

	// to the direction

	sidevecinc = 32;

	half_right_vec = 16 * dir * vectornormalize( anglestoright( angles ) );

	for ( i = 1;i < 15;i++ )
	{
		start_dest = org_start_dest;
		dest_point = start_dest;
		rightvec = i * sidevecinc * dir * vectornormalize( anglestoright( angles ) );
		trace = bullettrace_but_not_nodes( dest_point, dest_point + ( rightvec ), 0 );
		dest_point = dest_point + ( trace[ "fraction" ] * rightvec );
		if ( trace[ "fraction" ] < 1 )
		{
			line( start_dest, dest_point, ( 1, 0, 0 ) );
			continue;
		}
		else
			line( start_dest, dest_point, ( 0, 1, 0 ) );

		start_dest = dest_point;
		forwardvec = 32 * vectornormalize( anglestoforward( angles ) );
		trace = bullettrace_but_not_nodes( dest_point, dest_point + ( forwardvec ), 0 );

		back_frac = trace[ "fraction" ];
		if ( trace[ "fraction" ] == 1 )
			back_frac = .51;
		dest_point = dest_point + ( back_frac * forwardvec );

		if ( trace[ "fraction" ] < back_frac )
		{
			line( start_dest, dest_point, ( 1, 0, 0 ) );
			continue;
		}
		else
			line( start_dest, dest_point, ( 0, 1, 0 ) );

		start_dest = dest_point;

		leftvec = ( rightvec * - 1 ) - half_right_vec ;

		trace = bullettrace_but_not_nodes( dest_point, dest_point + ( leftvec ), 0 );
		dest_point = dest_point + ( trace[ "fraction" ] * leftvec );
		if ( trace[ "fraction" ] > .99 )
		{
			line( start_dest, dest_point, ( 1, 0, 0 ) );
			line( start_dest, start_dest + ( 0, 0, 15 ), ( 0, 0, 1 ) );
			continue;
		}
		else
		{
			line( start_dest, dest_point, ( 0, 1, 0 ) );
			line( dest_point, dest_point + ( 0, 0, 15 ), ( 0, 0, 1 ) );
			line( start_dest, start_dest + ( 0, 0, -15 ), ( 1, 0, 1 ) );
		}
		cornerpos = dest_point;
		position = cornerpos + ( half_right_vec * - 1 ) + ( forwardvec * back_frac * - 1 );

		righttraceorg1 = position + ( half_right_vec * .9 );
		trace = bullettrace_but_not_nodes( righttraceorg1, righttraceorg1 + ( forwardvec * .5 ), 0 );

		if ( trace[ "fraction" ] < 1 )
			position = trace[ "position" ] - ( forwardvec * .5 ) + ( half_right_vec * - .9 );

		return position;
	}
	return undefined;

}

place_node_place( bpreview )
{
	if ( !isdefined( bpreview ) )
		bpreview = false;
	trace = level._player_view_trace;
	angles = flat_angle( level._player getplayerangles() );
	origin = trace[ "position" ] + level._noder_heightoffset;

	if ( trace[ "fraction" ] == 1 || level._placed_nodes.size > level._noder_max )
	{
		level._preview_node hide();
		return;
	}


	if ( is_player_looking_at_a_wall() )
	{
		level._preview_node dontinterpolate();
		angles = vectortoangles( -1 * trace[ "normal" ] );
		origin = get_wall_offset( angles );
	}
	else if ( level._node_grid )
	{
		level._preview_node dontinterpolate();
		origin = get_snapped_origin( origin );
		draw_grid( origin, bpreview );
		angles = ( 0, 0, 0 );
	}

	if ( node_is_invalid( origin ) )
	{
		level._preview_node hide();
		select_coliding_node();
		return;
	}
	else if ( node_is_touching( origin ) )
	{
		select_coliding_node();
	}
	else
	{
		unselect_node();
		level._preview_node show();
	}
	draw_lines_to_connectible_nodes( origin );

	place_node_here( origin, angles, bpreview );

}

place_node_here( origin, angles, bpreview )
{
	group = getcurrent_groupstruct();
	if ( bpreview )
	{
		node = level._preview_node;
		node.origin = origin;
	}
	else
		node = spawn( "script_model", origin );
	node notsolid();
	assert( isdefined( group.model ) );
	if ( !bpreview )
		node setmodel( group.model );
	node.angles = angles;
	if ( group.model == "node_pathnode" )
		node.angles = ( 0, 0, 0 );
	if ( !bpreview )
	{
		place_new_dummy_guy_and_animate_at_node( node );
		level._placed_nodes[ level._placed_nodes.size ] = node;
	}
	hud_update_placed_model_count();

}

place_node_place_at_feet()
{
	angles = flat_angle( level._noder_player getplayerangles() );
	origin = groundpos_loc( level._noder_player.origin + ( 0, 0, 16 ) ) + level._noder_heightoffset;

	if ( node_is_invalid( origin ) )
		return;

	place_node_here( origin, angles, false );
	hud_update_placed_model_count();
}

get_mp_player()
{
	return getentarray( "player", "classname" )[ 0 ];
}

place_node_erase()
{
	node = undefined;
	if ( isdefined( level._selected_node ) )
	{
		node = level._selected_node;
	}
	if ( isdefined( level._player_view_trace[ "entity" ] ) )
	{
		node = level._player_view_trace[ "entity" ];
		if ( ! issubstr( node.model, "node_" ) )
			node = undefined;
	}
	if ( !isdefined( node ) )
		return;

	level._near_nodes = array_remove( level._near_nodes, node );
	level._placed_nodes = array_remove( level._placed_nodes, node );
	if ( isdefined( node.has_dummy_guy ) )
	{
		node.has_dummy_guy hide();
		node.has_dummy_guy.is_hidden = true;

	}
	node delete();
	level._noder_node_delete = true; // tells thread that's got all the nodes to get all the nodes again.
	hud_update_placed_model_count();
}

dump_nodes()
{
 /#
	if ( ! level._placed_nodes.size )
		return;


	level notify( "dump_nodes" );
	level._near_nodes = [];

	fileprint_launcher_start_file();
	fileprint_map_start();

	for ( i = 0;i < level._placed_nodes.size;i++ )
	{
		origin = fileprint_radiant_vec( level._placed_nodes[ i ].origin );// convert these vectors to mapfile keypair format
		angles = fileprint_radiant_vec( level._placed_nodes[ i ].angles );

		fileprint_map_entity_start();
			fileprint_map_keypairprint( "classname", level._placed_nodes[ i ].model );
			fileprint_map_keypairprint( "origin", origin );
			fileprint_map_keypairprint( "angles", angles );
			fileprint_map_keypairprint( "spammed_model", level._place_node_current_group );
		fileprint_map_entity_end();
	}
	
	filepath = "/map_source/"+level._script+"_node_dump.map";
	fileprintsuccess = fileprint_launcher_end_file( filepath, false );
	
	if( fileprintsuccess )
	{
		launcher_write_clipboard( filepath );
		array_thread( level._placed_nodes, ::deleteme );
		level._placed_nodes = [];
		hud_update_placed_model_count();
	}
	thread manage_nearnodes();
#/

}

player_view_trace()
{
	maxdist = 2000;
	traceorg = level._noder_player geteye();
	return bullettrace( traceorg, traceorg + ( anglestoforward( level._noder_player getplayerangles() ) * maxdist ), 0, level._preview_node );
}

is_player_looking_at_a_wall()
{
	if ( !isdefined( level._player_view_trace[ "normal" ] ) )
		return false;

	if ( traces_hitting_node( level._player_view_trace ) )
		return false;
	normal_angle = 	vectortoangles( level._player_view_trace[ "normal" ] );
	flat_normal_angle = flat_angle( normal_angle );
	if ( VectorDot( anglestoforward( flat_normal_angle ), anglestoforward( normal_angle ) ) == 1 )
		return true;
	else
		return false;
}

gettext_nonode( txt )
{
	newtext = "";
	for ( i = 5;i < txt.size;i++ )
		newtext += txt[ i ];
	return newtext;

}

bullettrace_but_not_nodes( traceorg, traceorg2, other, ignoreent )
{
	trace =  bullettrace( traceorg, traceorg2, other, ignoreent );
	if ( traces_hitting_node( trace ) )
		trace = bullettrace( traceorg, traceorg2, other, trace[ "entity" ] );
	return trace;
}

traces_hitting_node( trace )
{
	return isdefined( trace[ "entity" ] ) && isdefined( trace[ "entity" ].model ) && IsSubStr( trace[ "entity" ].model, "node_" );
}

groundpos_loc( origin, maxtest )
{
	if ( !isdefined( maxtest ) )
		maxtest = -100000;
	return bullettrace_but_not_nodes( origin, ( origin + ( 0, 0, maxtest ) ), 0, self )[ "position" ];
}

get_snapped_origin( origin )
{
	snapsize = level._node_grid;
	xsnap = snap_number_to_nearest_grid( origin[ 0 ], snapsize );
	ysnap = snap_number_to_nearest_grid( origin[ 1 ], snapsize );
	return groundpos_loc( ( xsnap, ysnap, origin[ 2 ] + 32 ) ) + level._noder_heightoffset;
}

snap_number_to_nearest_grid( number, grid )
{
	snap = number / grid;
	snapped = int( snap );
	remainder = snap - snapped;
	if ( remainder < - .5 )
		snapped -- ;
	else if ( remainder > .5 )
		snapped++ ;
	return snapped * grid;
}

draw_grid( origin, bpreview )
{
	gridlines = 1;
	gridcolor = ( 0, 1, 0 );

	origin = groundpos_loc( origin );
	offsetorigin = origin + ( 0, 0, level._node_grid );
	for ( x = gridlines * - 1;x < gridlines + 1;x++ )
	{
		for ( y = gridlines * - 1;y < gridlines + 1;y++ )
		{
			if ( x!= gridlines )
			{
				Line( origin + ( x * level._node_grid, y * level._node_grid, 0 ), origin + ( ( x + 1 ) * level._node_grid, y * level._node_grid, 0 ), gridcolor, true );
//				groundpos_line( offsetorigin + ( x * level.node_grid, y * level.node_grid, 0 ), offsetorigin + ( ( x + 1 ) * level.node_grid, y * level.node_grid, 0 ), gridcolor, true );

			}
			if ( y!= gridlines )
			{
				Line( origin + ( x * level._node_grid, y * level._node_grid, 0 ), origin + ( x * level._node_grid, ( y + 1 ) * level._node_grid, 0 ), gridcolor, true );
//				groundpos_line( offsetorigin + ( x * level.node_grid, y * level.node_grid, 0 ), offsetorigin + ( x * level.node_grid, ( y + 1 ) * level.node_grid, 0 ), gridcolor, true );
			}
		}
	}
}

groundpos_line( start, end, color, depthtest )
{
	maxtest = level._node_grid * - 2;
	start = groundpos_loc( start, maxtest );
	end = groundpos_loc( end, maxtest );
	Line( start, end, color, depthTest );
}

node_is_invalid( origin )
{
	count = 0;
	shorterdist = 68;
	selector_node = undefined;
	foreach ( node in level._placed_nodes )
	{
		dist =  distance( origin, node.origin );
		if ( dist < 32 )
		{
			count++ ;
			if ( dist < 0.05 )
				count = 6;// invalid if on top of eachother.
			if ( dist < shorterdist )
				selector_node = node;
		}
	}
	if ( !isdefined( selector_node ) )
		return false;
	level._coliding_node = selector_node;
	if ( count >= 2 )
		return true;
	return false;
}

node_is_touching( origin )
{
	foreach ( node in level._placed_nodes )
		if ( distance( origin, node.origin ) < 32 )
		{
			level._coliding_node = node;
			return true;
		}
	return false;
}

hud_update_gridsize()
{
	colortext = "^7";
	if ( level._node_grid != 0 )
		colortext = "^1";
	level._hud_noder[ "gridsize" ].description _settext( colortext + level._node_grid );
}

grid_up()
{
	if ( !level._node_grid )
		level._node_grid = 64;
	level._node_grid *= 2;
	if ( level._node_grid > 256 )
		level._node_grid = 256;
	hud_update_gridsize();
}

grid_down()
{
	if ( !level._node_grid )
		return;
	level._node_grid *= .5;
	if ( level._node_grid < 64 )
		level._node_grid = 0;
	hud_update_gridsize();
}

grid_toggle()
{
	if ( level._node_grid == 256 )
		level._node_grid = 0;
	else
		level._node_grid = 256;
	hud_update_gridsize();
}

select_traced_node( trace )
{
	assert( isdefined( trace[ "entity" ] ) );
	assert( isdefined( trace[ "entity" ].model ) );
	select_node( trace[ "entity" ] );
}

select_node( node )
{
	if ( level._node_select_locked && isdefined( level._selected_node ) )
		return;
	place_new_dummy_guy_and_animate_at_node( node );

	level._selector_model dontinterpolate();
	level._selector_model.origin = node.origin;
	level._selector_model.angles = node.angles;
	level._selector_model show();
	level._selected_node = node;
}

place_new_dummy_guy_and_animate_at_node( node )
{
	if ( !level._dummyguy.size || isdefined( node.has_dummy_guy ) || !node_has_animations( node ) )
		return;
	dummyguy = fifo_dummyguy();
	if ( isdefined( dummyguy.lastnode ) )
		dummyguy.lastnode.has_dummy_guy = undefined;
	dummyguy thread animate_dummyguy_at_node( node );
}

select_coliding_node()
{
	select_node( level._coliding_node );
}

unselect_node()
{
	if ( level._node_select_locked && isdefined( level._selected_node ) )
		return;
	level._selector_model hide();
	level._selected_node = undefined;
}

draw_selected_node_name()
{
	while ( 1 )
	{
		if ( !isdefined( level._selected_node ) )
		{
			wait .05;
			continue;
		}
		msg = level._selected_node.model;
		printRight = anglestoright( level._player getplayerangles() ) * msg.size * - 3;
		thread debug_message( msg, level._selected_node.origin + printRight, .05 );
		wait .05;
	}
}

toggle_select_lock()
{
	if ( level._node_select_locked )
	{
		level._selection_lock_indicator _settext( "" );
		level._node_select_locked = false;
	}
	else
	{
		level._selection_lock_indicator _settext( "^1Selection Lock On" );
		level._node_select_locked = true;
	}
}

set_button_funcs_main()
{
	clear_all_button_funcs();
	add_button_func( ::dump_nodes, false, "w" );
	add_button_func( ::place_node_erase, false, "BUTTON_LSHLDR" );
	add_button_func( ::place_node_place, false, "BUTTON_RSHLDR" );
	add_button_func( ::place_node_place_at_feet, false, "BUTTON_RSTICK" );
	add_button_func( ::setgroup_down, false, "BUTTON_X" );
	add_button_func( ::setgroup_up, false, "BUTTON_Y" );
	add_button_func( ::setgroup_down, false, "DPAD_UP" );
	add_button_func( ::setgroup_up, false, "DPAD_DOWN" );
	add_button_func( ::grid_toggle, false, "BUTTON_A" );
//	add_button_func( ::toggle_select_lock, false, "BUTTON_B" );
	add_button_func( ::toggle_animation_preview, false, "BUTTON_B" );
}

clear_all_button_funcs()
{
	level._button_func = [];
	level._button_func_isflow = [];
}

set_button_funcs_quickselect()
{
	clear_all_button_funcs();
	add_button_func( ::dump_nodes, false, "w" );
	add_button_func( ::select_node_cover_left, false, "BUTTON_LSHLDR" );
	add_button_func( ::select_node_cover_right, false, "BUTTON_RSHLDR" );
	add_button_func( ::select_node_pathnode, false, "BUTTON_LTRIG" );
	add_button_func( ::select_node_pathnode, false, "BUTTON_RTRIG" );
	add_button_func( ::select_node_pathnode, false, "BUTTON_RSTICK" );
	add_button_func( ::select_node_cover_crouch_window, false, "BUTTON_X" );
	add_button_func( ::select_node_cover_prone, false, "BUTTON_Y" );
	add_button_func( ::select_node_concealment_stand, false, "DPAD_UP" );
	add_button_func( ::select_node_concealment_prone, false, "DPAD_DOWN" );
//	add_button_func( ::select_node_concealment_prone, false, "DPAD_LEFT" );
	add_button_func( ::select_node_concealment_crouch, false, "DPAD_RGIHT" );
	add_button_func( ::select_node_cover_stand, false, "BUTTON_A" );
	add_button_func( ::select_node_cover_crouch, false, "BUTTON_B" );
}

hint_buttons_quick_modifier()
{
	controler_hud_update_text( "helpxy", "^4Cover Crouch Window ^7/ ^3Prone" );
	controler_hud_update_text( "helpab", "^2Cover Stand ^7/ ^1Crouch" );
	controler_hud_update_text( "helplsrs", "^8 - ^7/ Pathnode" );
	controler_hud_update_text( "helplbrb", "^8Cover Left ^7/ Right" );
	controler_hud_update_text( "helpdpl", "^8Conceal - ^7/ Crouch" );
	controler_hud_update_text( "helpdpu", "^8Conceal Stand ^7/ Prone" );
}

hint_buttons_main()
{
	controler_hud_update_text( "helpxy", "^4Node Type Up ^7/ ^3Down" );
	controler_hud_update_text( "helpab", "^2Toggle Grid ^7/ ^1Anim Preview " );
	controler_hud_update_text( "helplsrs", "^8Quick Pick ^7/ Place at Player" );
	controler_hud_update_text( "helplbrb", "^8Remove ^7/ Place" );
	controler_hud_update_text( "helpdpl", "^8- ^7/ -" );
	controler_hud_update_text( "helpdpu", "^8Node Type Up ^7/ Down" );
	text = "( dump ) ^3map_source / xenon_export/" + level._script + "_nodedump.map";
	controler_hud_update_text( "helpF", text );
}


select_node_cover_crouch()
{
	setcurrentgroup( "node_cover_crouch" );
}

select_node_pathnode()
{
	setcurrentgroup( "node_pathnode" );
}

select_node_cover_crouch_window()
{
	setcurrentgroup( "node_cover_crouch_window" );
}

select_node_cover_prone()
{
	setcurrentgroup( "node_cover_prone" );
}

select_node_cover_stand()
{
	setcurrentgroup( "node_cover_stand" );
}

select_node_concealment_crouch()
{
	setcurrentgroup( "node_concealment_crouch" );
}
select_node_concealment_prone()
{
	setcurrentgroup( "node_concealment_prone" );
}
select_node_concealment_stand()
{
	setcurrentgroup( "node_concealment_stand" );
}

select_node_cover_left()
{
	setcurrentgroup( "node_cover_left" );
}

select_node_cover_right()
{
	setcurrentgroup( "node_cover_right" );
}

set_button_funcs_quick_select()
{
	clear_all_button_funcs();
	set_button_funcs_quickselect();
	hint_buttons_quick_modifier();

}

set_button_funcs_quick_select_release()
{
	set_button_funcs_main();
	hint_buttons_main();
}

_newhudelem()
{
	if ( !isdefined( level._noder_elems ) )
	 	level._noder_elems = [];
	elem = newhudelem();
	level._noder_elems[ level._noder_elems.size ] = elem;
	return elem;
}

_settext( text )
{
	self.realtext = text;
	foreach ( elem in level._noder_elems )
	{
		if ( isdefined( elem.realtext ) )
			elem settext( elem.realtext );
	}
}

animate_dummyguy_at_node( node )
{

	origin = node.origin + ( 0, 0, -32 );
	angles = node.angles + level._node_offset[ node.model ];
	node.has_dummy_guy = self;
	self.lastnode = node;
	level._dummynode[ self.dummyguyindex ] notify( "stop_loop" );
	level._dummynode[ self.dummyguyindex ].origin = origin;
	level._dummynode[ self.dummyguyindex ].angles = angles;
	level._dummynode[ self.dummyguyindex ] dontinterpolate();
	self dontinterpolate();
	self show();
	self.is_hidden = false;
	level._dummynode[ self.dummyguyindex ] anim_generic_loop( self, node.model );
}

fifo_dummyguy()
{
	level._dummyguy_index++ ;
	if ( 	level._dummyguy_index == level._dummyguy_index_max )
		level._dummyguy_index = 0;

	dummyguy = level._dummyguy[ level._dummyguy_index ];
	return dummyguy;
}

node_has_animations( node )
{
	if ( isdefined( level._scr_anim[ "generic" ][ node.model ] ) )
		return true;
	return false;
}

toggle_animation_preview()
{
	if ( level._node_animation_preview )
	{
		level._node_animation_preview_indicator _settext( "^1Anim Preview Off" );
		level._node_animation_preview = false;
		hide_all_dummyguys();
	}
	else
	{
		level._node_animation_preview_indicator _settext( "" );
		level._node_animation_preview = true;
		show_all_dummyguys();
	}
}

hide_all_dummyguys()
{
	foreach ( guy in level._dummyguy )
	{
		if ( !isdefined( guy.is_hidden ) || !guy.is_hidden )
			guy hide();
	}
}

show_all_dummyguys()
{
	foreach ( guy in level._dummyguy )
	{
		if ( !isdefined( guy.is_hidden ) || !guy.is_hidden )
			guy show();
	}
}

draw_lines_to_connectible_nodes( org )
{
	foreach ( node in level._near_nodes )
	{
		if ( !isdefined( Node.classname ) )
			line( org, node.origin + ( 0, 0, 16 ), ( 0, .7, .7 ), true );
		else
			Line( org, node.origin, ( 0, 1, 0 ), true );
	}
}

manage_nearnodes()
{
	level endon( "dump_nodes" );
	level._near_nodes = [];
	nodes = getallnodes();
	count = 0;
	maxcount = 1000;
	array = [];
	level._nearnodes_time = 0;
	wait .05;

	//ledgibilty be damned. trying not to use a bazillion script calls to speed this up.

	while ( 1 )
	{
		//faster than array_combine
		all_nodes = nodes;
		foreach ( node in level._placed_nodes )
		{
			assert( isdefined( node ) );
			all_nodes[ all_nodes.size ] = node;
		}
		size = level._placed_nodes.size;
		
		foreach ( node in all_nodes )
		{
			assert( isdefined( node ) );
			array[ array.size ] = node;
			count++ ;

			if ( level._placed_nodes.size != size )
			{
				array = [];
				count = 0;
				break;
			}

			if ( count > maxcount )
			{
				// level.placed_nodes size change means the all_nodes array needs to be rebuilt and this loop needs to start over.

				near_nodes = [];

				//clear out the old near nodes that are no longer valid (.05 time wait may invalidate) since there generally so few this is a quick check)
				foreach ( obj in level._near_nodes )
					if ( distancesquared( ( level._preview_node.origin[ 0 ], level._preview_node.origin[ 1 ], 0 ), ( obj.origin[ 0 ], obj.origin[ 1 ], 0 ) ) <= 65536 )
						near_nodes[ near_nodes.size ] = obj;

				newArray = [];

				foreach ( obj2 in array )
					if ( distancesquared( ( level._preview_node.origin[ 0 ], level._preview_node.origin[ 1 ], 0 ), ( obj2.origin[ 0 ], obj2.origin[ 1 ], 0 ) ) <= 65536 )
						newArray[ newArray.size ] = obj2;


				// there are usually few to merge. not worried about this array_merge call.
				level._near_nodes =  array_merge( newArray, near_nodes );

				array = [];
				count = 0;
				wait .05;
				waittillframeend; // sometimes this gets tangled with the placed_nodes size assures reset happens after that thing.

			}

			if( level._noder_node_delete )
			{
				level._noder_node_delete = false;
				array = [];
				count = 0;
				break;
			}

		}
		wait .05;
	}
}


