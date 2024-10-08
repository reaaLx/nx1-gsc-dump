#include maps\_utility;

/*
path_editmode = ""; //toggles value, edit or view default to view.
path_select_next = ""; // selects next psourceposition;
path_select_prev = ""; // selects prev psourceposition
path_setview = "";  // sets the view of the currently selected position.
path_help ""; //prints to console some help text
path_dump ""; //dumps view list to the console to be cut and pasted into script somewhere
*/

init()
{
	flag_init( "path_Notviewing" );
	flag_init( "path_refresh" );
}

main()
{
	 /#

	if ( !isdefined( level._flag ) || !isdefined( level._flag[ "path_refresh" ] ) )
	{
		flag_init( "path_refresh" );
		flag_init( "path_Notviewing" );
	}

	level._path_selectrad = 128;
	precacheshader( "psourcecreate" );
	precacheshader( "psourcemodify" );

	setdvar( "path_delete", "" );
	setdvar( "path_editmode", "" );
	setdvar( "path_select_next", "" );
	setdvar( "path_select_prev", "" );
	setdvar( "path_setview", "" );
	setdvar( "path_help", "" );
	setdvar( "path_dump", "" );
	setdvar( "path_select_new", "" );
	setdvar( "path_enable", "0" );
	setdvar( "path_setid", "0" );
	level._pathmodsize = 35;
	level._pathmod = newhudelem();
	level._pathmod.alignX = "center";
	level._pathmod.alignY = "top";
	level._pathmod.horzAlign = "center";
	level._pathmod.vertAlign = "top";
	level._pathmod.x = 0;
	level._pathmod.y = 0;
	level._pathmod.alpha = .5;
	level._pathmod setshader( "psourcemodify", level._pathmodsize * 2, level._pathmodsize );

	level._path_editmode = false;
	if ( !isdefined( level._path_views ) )
		level._path_views = [];
	if ( !isdefined( level._path_views[ level._path_selectid ] ) )
		level._path_views[ level._path_selectid ] = [];

	if ( !isdefined( level._path_selectid ) )
		level._path_selectid = path_createid( "default" );

	if ( !isdefined( level._path_selectindex ) )
		level._path_selectindex = level._path_views.size;
	level._path_viewindex = undefined;
	thread path_viewmode();

	// this handles all of the dvar settings
	while ( 1 )
	{
		path_enable(); // pauses if not enabled.
		path_editmode_update();
		path_select_next();
		path_select_prev();
		path_select_new();
		path_setid();
		path_setview();
		path_delete();
		path_dump();
		path_help();
		wait .05;
	}
	#/
}

path_enable()
{
	if ( getdvar( "path_enable" ) != "1" )
	{
		flag_set( "path_refresh" ); // makes everything stop drawing.
		level._pathmod.alpha = 0;
	}
	path_waittill_enable();
	level._pathmod.alpha = 1;
}

path_waittill_enable()
{
	while ( getdvar( "path_enable" ) != "1" )
		wait .1;
}

path_viewmode()
{
	wait .1;

	while ( 1 )
	{
		path_waittill_enable();
		flag_set( "path_Notviewing" );
		flag_clear( "path_refresh" );
		thread path_connectlines();
		for ( i = 0;i < level._path_views[ level._path_selectid ].size;i++ )
			level._path_views[ level._path_selectid ][ i ] thread path_viewwait( i );
		thread path_activatebutton();
		thread path_handleselectindex();
		flag_wait( "path_refresh" );
		flag_wait( "path_Notviewing" );
	}
}

path_connectlines()
{
	level endon( "path_refresh" );
	dots = [];
	for ( i = 0;i < level._path_views[ level._path_selectid ].size;i++ )
	{
		dots[ i ] = level._path_views[ level._path_selectid ][ i ].origin;
	}
	while ( 1 )
	{
		plot_points( dots, 1, 0, 0, .05 );
		wait .05;
	}
}

path_activatebutton()
{
	level endon( "path_refresh" );
	while ( 1 )
	{
		while ( !level._player usebuttonpressed() )
			wait .05;
		pick = path_getvisible();
		if ( isdefined( pick.index ) )
		{
			level._path_selectindex = pick.index;
			level._path_selectid = path_createid( pick.ident );
		}
		while ( level._player usebuttonpressed() )
			wait .05;
	}
}

path_handleselectindex()
{
	level endon( "path_refresh" );
	lastselect = level._path_selectindex;
	while ( 1 )
	{
		if ( !isdefined( level._path_views[ level._path_selectid ][ lastselect ] ) )
			level._pathmod setshader( "psourcecreate", level._pathmodsize * 2, level._pathmodsize );

		if ( lastselect == level._path_selectindex )
		{
			wait .05;
			continue;
		}
		lastselect = level._path_selectindex;
		if ( isdefined( level._path_views[ level._path_selectid ][ lastselect ] ) )
			level._path_views[ level._path_selectid ][ lastselect ] thread path_hudshow();
	}
}

path_hudshow()
{
	flag_clear( "path_Notviewing" );
	level._pathmod setshader( "psourcemodify", level._pathmodsize * 2, level._pathmodsize );
	level._player freezecontrols( true );
	level._player setorigin( self.origin + ( level._player.origin - level._player geteye() ) - vector_multiply( anglestoforward( self.angles ), 3 ) );
	level._player setplayerangles( self.angles );
	flag_set( "path_refresh" );
	while ( level._player islookingorg( self ) && level._player usebuttonpressed() )
		wait .05;
	level._player freezecontrols( false );
	flag_set( "path_Notviewing" );
}


path_getvisible()
{
	outident = undefined;
	index = undefined;
	dist = 1000000;
	for ( j = 0;j < level._paths_selectid_list.size;j++ )
	{
		ident = level._paths_selectid_list[ j ];
		for ( i = 0;i < level._path_views[ ident ].size;i++ )
		{
			if ( level._player islookingorg( level._path_views[ ident ][ i ] ) )
			{
				newdist = distance( level._player geteye(), level._path_views[ ident ][ i ].origin );
				if ( newdist < dist )
				{
					dist = newdist;
					index  = i;
					outident = ident;
				}
			}
		}
	}

	outvar = spawnstruct();
	outvar.index = index;
	outvar.ident = outident;
	return outvar;
}

path_viewwait( index )
{
	level endon( "path_refresh" );
	arrowlength = 55;
	viewradexpandmax = 8;
	viewradexpandcount = 0;
	viewraddir = 1;
	frametime = .05;
	while ( 1 )
	{
		if ( distance( flat_origin( self.origin ), flat_origin( level._player.origin ) ) < 32 )
		{
			wait .05;
			continue;
		}
		thread draw_arrow_time( self.origin, self.origin + vector_multiply( anglestoforward( self.angles ), arrowlength ), ( 0, 1, 1 ), frametime );

		if ( level._path_selectindex == index )
			thread plot_circle_star_fortime( level._path_selectrad, frametime, ( 1, 1, 0 ) );
		else
			thread plot_circle_fortime( level._path_selectrad, frametime, ( 0, 1, 0 ) );
		if ( isdefined( level._path_viewindex ) && level._path_viewindex == index )
		{
			if ( viewradexpandcount > viewradexpandmax )
				viewraddir = -1;
			else if ( viewradexpandcount < 0 )
				viewraddir = 1;
			viewradexpandcount += viewraddir;
			viewrad = level._path_selectrad + 3 + viewradexpandcount;
			viewcolor = ( 0, 1, 1 );
		}
		else
		{
			viewrad = level._path_selectrad + 3;
			viewcolor = ( 0, 1, 0 );
		}
		thread plot_circle_fortime( viewrad, frametime, viewcolor );
		wait .05;
	}
}

plot_circle_star_fortime( radius, time, color )
{
	if ( !isdefined( color ) )
		color = ( 0, 1, 0 );
	hangtime = .05;
	circleres = 16;
	hemires = circleres / 2;
	circleinc = 360 / circleres;
	circleres++ ;
	plotpoints = [];
	rad = 0;
	plotpoints = [];
	rad = 0.000;
	timer = gettime() + ( time * 1000 );

	while ( gettime() < timer )
	{
		angletoplayer = vectortoangles( self.origin - level._player geteye() );
		for ( i = 0;i < circleres;i++ )
		{
			plotpoints[ plotpoints.size ] = self.origin + vector_multiply( anglestoforward( ( angletoplayer + ( rad, 90, 0 ) ) ), radius );
			rad += circleinc;
		}
		for ( i = 0;i < plotpoints.size;i++ )
			line( plotpoints[ i ], self.origin, color, 1 );
		plotpoints = [];
		wait hangtime;
	}
}

plot_circle_fortime( radius, time, color )
{
	if ( !isdefined( color ) )
		color = ( 0, 1, 0 );
	hangtime = .05;
	circleres = 16;
	hemires = circleres / 2;
	circleinc = 360 / circleres;
	circleres++ ;
	plotpoints = [];
	rad = 0;

	plotpoints = [];
	rad = 0.000;
	timer = gettime() + ( time * 1000 );
	while ( gettime() < timer )
	{
		angletoplayer = vectortoangles( self.origin - level._player geteye() );
		for ( i = 0;i < circleres;i++ )
		{
			plotpoints[ plotpoints.size ] = self.origin + vector_multiply( anglestoforward( ( angletoplayer + ( rad, 90, 0 ) ) ), radius );
			rad += circleinc;
		}
		plot_points( plotpoints, color[ 0 ], color[ 1 ], color[ 2 ], hangtime );
		plotpoints = [];
		wait hangtime;
	}
}


path_select_next()
{
	if ( getdvar( "path_select_next" ) == "" )
		return;
	if ( !( level._path_selectindex == level._path_views[ level._path_selectid ].size ) )
		level._path_selectindex++ ;

	setdvar( "path_select_next", "" );

}

path_select_prev()
{
	if ( getdvar( "path_select_prev" ) == "" )
		return;
	if ( !( level._path_selectindex == 0 ) )
		level._path_selectindex -- ;
	setdvar( "path_select_prev", "" );

}

path_select_new()
{
	if ( getdvar( "path_select_new" ) == "" )
		return;
	level._path_selectindex = level._path_views[ level._path_selectid ].size;
	setdvar( "path_select_new", "" );

}


path_setid()
{
	if ( getdvar( "path_setid" ) == "" )
		return;
	level._path_selectid = path_createid( getdvar( "path_setid" ) );
	level._path_selectindex = 0;// set current selection to first whenever it's changed
}

path_setview()
{
	if ( getdvar( "path_setview" ) == "" )
		return;
	view = path_getcurrentview();
		//add trigger stuff here
		//check for trigger
	path_setvieworgang( view );
	setdvar( "path_setview", "" );
	flag_set( "path_refresh" );
}

path_setvieworgang( view )
{
	view.origin = level._player geteye();
	view.angles = level._player getplayerangles();
}

path_trigger_setvieworgang( view )
{
	view.origin = level._player geteye();
	view.radius = 200;
}

path_dump()
{
	if ( getdvar( "path_dump" ) == "" )
		return;
	println( " " );
	println( " " );
	println( " " );
	println( "--------******--------" );
//	println ("   photo source dump  (paste these to your level script before maps\_load::main() ) ");
	println( "       path dump      " );
	println( "--------******--------" );
	println( " " );
	println( " " );
	for ( j = 0;j < level._paths_selectid_list.size;j++ )
	{
		ident = level._paths_selectid_list[ j ];
		println( "path ident: " + ident );
		for ( i = 0;i < level._path_views[ ident ].size;i++ )
				println( level._path_views[ ident ][ i ].origin + "," + level._path_views[ ident ][ i ].angles );
	}
	// todo: [level.path_selectid] list
//	println ("thread maps\\\_photosource::photosource_init();");
	for ( j = 0;j < level._paths_selectid_list.size;j++ )
	{
		ident = level._paths_selectid_list[ j ];
		for ( i = 0;i < level._path_views[ ident ].size;i++ )
		{
	    	println( "maps\\\_createpath::path_create(\"" + level._path_views[ ident ][ i ].origin + "," + level._path_views[ ident ][ i ].angles + ");" );
		}
	}
//	println ("thread maps\\\_photosource::photosource_main();");
	println( " " );
	println( " " );
	println( " " );
	setdvar( "path_dump", "" );

}


path_help()
{
	if ( getdvar( "path_help" ) == "" )
		return;
	println( " " );
	println( " " );
	println( "Photo refrenence - Help " );
	println( " " );
	println( " photo reference is a tool to help communicate art direction within the level " );
	println( " An artist or a level designer can run this tool to place images of photo " );
	println( " source like a gallery throughout the level." );
	println( " " );
	println( " before starting do /exec psource.cfg" );
	println( " " );
	println( "path_enable ( 7 Key ) - toggles psource on and off" );
	println( "path_setview ( 8 Key ) - sets the view of the currently selected position." );
	println( "path_select_prev ( [ Key ) - selects prev psourceposition" );
	println( "path_select_next ( ] Key ) - selects next psourceposition" );
	println( "path_select_new ( \\ Key ) - selects NEW psourceposition, used to create a new position on setview" );
	println( "path_help ( h Key ) - prints to console this help text" );
	println( "path_dump ( u Key ) - dumps view list to the console to be cut and pasted into script somewhere" );
	println( "path_delete ( del Key ) - deletes the currently selected view (yellow star in circle)" );
	println( " " );
	println( "Pressing the usebutton on a sphere will teleport you so that you can see " );
	println( "the desired angle of the piece of reference, this also selects the view" );
	println( "and highlights it yellow" );
	println( " " );
	println( "To change the image of the currently selected view go to the console and enter this dvar" );
	println( "path_image <materialname>" );
	println( " " );
	println( "Once you have all your views press the dump button, open your console.log and paste the script to your level script" );
	setdvar( "path_help", "" );
}


path_delete()
{
	if ( getdvar( "path_delete" ) == "" )
		return;
	newarray = [];
	for ( i = 0;i < level._path_views[ level._path_selectid ].size;i++ )
		if ( i != level._path_selectindex )
			newarray[ newarray.size ] = level._path_views[ level._path_selectid ][ i ];
	level._path_views = newarray;
	flag_set( "path_refresh" );
	setdvar( "path_delete", "" );
}

path_select_template()
{
	if ( getdvar( "path_select_template" ) == "" )
		return;
	setdvar( "path_select_template", "" );
}

path_editmode_update()
{
	if ( getdvar( "path_editmode" ) == "" )
		return;
	if ( !level._path_editmode )
		level._path_editmode = true;
	else
		level._path_editmode = false;
	setdvar( "path_editmode", "" );
}

path_image_update()
{
	if ( getdvar( "path_image" ) == "" )
		return;
	view = path_getcurrentview();
	setdvar( "path_image", "" );
}

path_getcurrentview()
{
	//add trigger stuff here
	view = undefined;
	if ( isdefined( level._path_views[ level._path_selectid ] ) && isdefined( level._path_views[ level._path_selectid ][ level._path_selectindex ] ) )
		view = level._path_views[ level._path_selectindex ][ level._path_selectid ];
	else
		view = path_newview( false );
	return view;
}

path_trigger_newview( bScriptAdded )
{
	view = spawnstruct();
	if ( !bScriptAdded )
		path_trigger_setvieworgang( view );
	if ( isdefined( level._path_triggers[ level._path_selectid ][ level._path_selectindex ] ) )
		level._path_triggers[ level._path_selectid ][ level._path_selectindex ] delete();
	level._path_triggers[ level._path_selectid ][ level._path_selectindex ] = view;
	if ( !bScriptAdded )
		flag_set( "path_refresh" );
	return view;
}


path_newview( bScriptAdded )
{
	view = spawnstruct();
	if ( !bScriptAdded )
	{
		path_setvieworgang( view );
	}
	if ( isdefined( level._path_views[ level._path_selectid ][ level._path_selectindex ] ) )
		level._path_views[ level._path_selectid ][ level._path_selectindex ] delete();
	level._path_views[ level._path_selectid ][ level._path_selectindex ] = view;
	if ( !bScriptAdded )
		flag_set( "path_refresh" );
	return view;
}

path_createid( ident )
{
	if ( !isdefined( level._paths_selectid_list ) )
		level._paths_selectid_list = [];
	for ( i = 0;i < level._paths_selectid_list.size;i++ )
	{
		if ( ident == level._paths_selectid_list[ i ] )
			return ident;
	}
	level._paths_selectid_list[ level._paths_selectid_list.size ] = ident;
	return ident;
}

//use this in level file to initialize all the stuff.
path_create( position, angle, ident )
{
	 /#
	if ( !isdefined( ident ) )
		ident = "default";
	level._path_selectid = path_createid( ident );
	if ( !isdefined( level._flag ) )
		level._flag = [];
	if ( !isdefined( level._flag[ "path_Notviewing" ] ) )
		init();
	if ( !isdefined( level._path_selectindex ) )
		level._path_selectindex = 0;
	if ( !isdefined( level._path_views ) )
		level._path_views = [];
	if ( !isdefined( level._path_views[ level._path_selectid ] ) )
		level._path_views[ level._path_selectid ] = [];
	view = path_newview( true );
	view.origin = position;
	view.angles = angle;
	level._path_selectindex++ ;
	#/
}

path_trigger_create( position, radius, ident )
{
	 /#
	if ( !isdefined( ident ) )
		ident = "default";
	level._path_selectid = path_createid( ident );
	if ( !isdefined( level._flag ) )
		level._flag = [];
	if ( !isdefined( level._flag[ "path_Notviewing" ] ) )
		init();
	if ( !isdefined( level._path_selectindex ) )
		level._path_selectindex = 0;
	if ( !isdefined( level._path_triggers ) )
		level._path_triggers = [];
	if ( !isdefined( level._path_triggers[ level._path_selectid ] ) )
		level._path_triggers[ level._path_selectid ] = [];
	view = path_trigger_newview( true );
	view.origin = position;
	view.angles = angle;
	level._path_selectindex++ ;
	#/
}

islookingorg( view )
{
	normalvec = vectorNormalize( view.origin - self geteye() );
	veccomp = vectorNormalize( ( view.origin - ( 0, 0, level._path_selectrad * 2 ) ) - self geteye() );
	insidedot = vectordot( normalvec, veccomp );

	anglevec = anglestoforward( self getplayerangles() );
	vectordot = vectordot( anglevec, normalvec );
	if ( vectordot > insidedot )
		return true;
	else
		return false;
}