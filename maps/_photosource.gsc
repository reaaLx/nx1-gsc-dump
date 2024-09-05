#include maps\_utility;

/*
psource_editmode = ""; //toggles value, edit or view default to view.
psource_image = ""; //sets image
psource_select_next = ""; // selects next psourceposition;
psource_select_prev = ""; // selects prev psourceposition
psource_setview = "";  // sets the view of the currently selected position.
psource_help ""; //prints to console some help text
psource_dump ""; //dumps view list to the console to be cut and pasted into script somewhere



*/

init()
{
	flag_init( "psource_Notviewing" );
	flag_init( "psource_refresh" );

}

main()
{
	 /#

	if ( !isdefined( level._flag ) || !isdefined( level._flag[ "psource_refresh" ] ) )
	{
		flag_init( "psource_refresh" );
		flag_init( "psource_Notviewing" );
	}

	level._psource_selectrad = 12;
	precacheshader( "case" );
	precacheshader( "psourcecreate" );
	precacheshader( "psourcemodify" );


	setdvar( "psource_image", "" );
	setdvar( "psource_delete", "" );

	setdvar( "psource_editmode", "" );
	setdvar( "psource_image", "" );
	setdvar( "psource_select_next", "" );
	setdvar( "psource_select_prev", "" );
	setdvar( "psource_setview", "" );
	setdvar( "psource_help", "" );
	setdvar( "psource_dump", "" );
	setdvar( "psource_select_new", "" );
	setdvar( "psource_enable", "0" );


	level._photosourcemodsize = 35;
	level._photosourcemod = newhudelem();
	level._photosourcemod.alignX = "center";
	level._photosourcemod.alignY = "top";
	level._photosourcemod.horzAlign = "center";
	level._photosourcemod.vertAlign = "top";
	level._photosourcemod.x = 0;
	level._photosourcemod.y = 0;
	level._photosourcemod.alpha = .5;
	level._photosourcemod setshader( "psourcemodify", level._photosourcemodsize * 2, level._photosourcemodsize );

	level._photosource = newhudelem();
	level._photosource.alignX = "left";
	level._photosource.alignY = "top";
	level._photosource.horzAlign = "left";
	level._photosource.vertAlign = "top";
	level._photosource.x = 0;
	level._photosource.y = 0;
	level._photosource.alpha = 0;
	level._photosource setshader( "case", 640, 480 );

	level._psource_editmode = false;


	if ( !isdefined( level._psource_views ) )
		level._psource_views = [];

	if ( !isdefined( level._psource_selectindex ) )
		level._psource_selectindex = level._psource_views.size;
	level._psource_viewindex = undefined;
	thread psource_viewmode();

	// this handles all of the dvar settings
	while ( 1 )
	{
		psource_enable(); // pauses if not enabled.
		psource_image_update();
		psource_editmode_update();
		psource_select_next();
		psource_select_prev();
		psource_select_new();
		psource_setview();
		psource_delete();
		psource_dump();
		psource_help();
		wait .05;
	}
	#/
}

psource_enable()
{
	if ( getdvar( "psource_enable" ) != "1" )
	{
		flag_set( "psource_refresh" ); // makes everything stop drawing.
		level._photosourcemod.alpha = 0;
		level._photosource.alpha = 0;
	}
	psource_waittill_enable();
	level._photosourcemod.alpha = 1;
}

psource_waittill_enable()
{
	while ( getdvar( "psource_enable" ) != "1" )
		wait .1;
}

psource_viewmode()
{
	wait .1;

	while ( 1 )
	{
		psource_waittill_enable();
		flag_set( "psource_Notviewing" );
		flag_clear( "psource_refresh" );
		for ( i = 0;i < level._psource_views.size;i++ )
			level._psource_views[ i ] thread psource_viewwait( i );
		thread psource_hud_preview();
		thread psource_activatebutton();
		thread psource_handleselectindex();
		flag_wait( "psource_refresh" );
		flag_wait( "psource_Notviewing" );
	}
}

psource_activatebutton()
{
	level endon( "psource_refresh" );
	while ( 1 )
	{
		while ( !level._player usebuttonpressed() )
			wait .05;
		pick = psource_getvisible();
		if ( isdefined( pick ) )
		{
			level._psource_selectindex = pick;
			level._psource_views[ pick ] thread psource_hudshow();

		}
		while ( level._player usebuttonpressed() )
			wait .05;
	}
}

psource_handleselectindex()
{
	level endon( "psource_refresh" );
	lastselect = level._psource_selectindex;
	while ( 1 )
	{
		if ( !isdefined( level._psource_views[ lastselect ] ) )
			level._photosourcemod setshader( "psourcecreate", level._photosourcemodsize * 2, level._photosourcemodsize );

		if ( lastselect == level._psource_selectindex )
		{
			wait .05;
			continue;
		}
		lastselect = level._psource_selectindex;
		if ( isdefined( level._psource_views[ lastselect ] ) )
			level._psource_views[ lastselect ] thread psource_hudshow();

	}
}

psource_hud_preview()
{
	level endon( "psource_refresh" );
	while ( 1 )
	{
		pick = psource_getvisible();
		if ( !isdefined( pick ) )
		{
			level._photosource fadeovertime( 1 );
			level._photosource.alpha = 0;
			level._psource_viewindex = undefined;
			wait .05;
			continue;
		}
		level._psource_viewindex = pick;
		view = level._psource_views[ pick ];
		if ( isdefined( view.temp_image ) )
			level._photosource setshader( view.temp_image, 200, 150 );
		else
			level._photosource setshader( view.image, 200, 150 );
		level._photosource.alpha = 1;
		while ( isdefined( psource_getvisible() ) && psource_getvisible() == pick )
			wait .05;
		flag_set( "psource_refresh" );
	}
}

psource_getvisible()
{
	index = undefined;
	dist = 1000000;
	for ( i = 0;i < level._psource_views.size;i++ )
	{
		if ( level._player islookingorg( level._psource_views[ i ] ) )
		{
			newdist = distance( level._player geteye(), level._psource_views[ i ].origin );
			if ( newdist < dist )
			{
				dist = newdist;
				index  = i;

			}
		}
	}
	return index;
}

psource_viewwait( index )
{
	level endon( "psource_refresh" );
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

		if ( level._psource_selectindex == index )
			thread plot_circle_star_fortime( level._psource_selectrad, frametime, ( 1, 1, 0 ) );
		else
			thread plot_circle_fortime( level._psource_selectrad, frametime, ( 0, 1, 0 ) );
		if ( isdefined( level._psource_viewindex ) && level._psource_viewindex == index )
		{
			thread debug_message( "image: " + self.image, self.origin, frametime );
			if ( viewradexpandcount > viewradexpandmax )
				viewraddir = -1;
			else if ( viewradexpandcount < 0 )
				viewraddir = 1;
			viewradexpandcount += viewraddir;
			viewrad = level._psource_selectrad + 3 + viewradexpandcount;
			viewcolor = ( 0, 1, 1 );
		}
		else
		{
			viewrad = level._psource_selectrad + 3;
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

psource_hudshow()
{
	flag_clear( "psource_Notviewing" );
	level._photosourcemod setshader( "psourcemodify", level._photosourcemodsize * 2, level._photosourcemodsize );
	if ( isdefined( self.temp_image ) )
		level._photosource setshader( self.temp_image, 640, 480 );
	else
		level._photosource setshader( self.image, 640, 480 );
	level._player freezecontrols( true );
	level._player setorigin( self.origin + ( level._player.origin - level._player geteye() ) - vector_multiply( anglestoforward( self.angles ), 3 ) );
	level._player setplayerangles( self.angles );
	level._photosource.alpha = 1;
	flag_set( "psource_refresh" );
	while ( level._player islookingorg( self ) && level._player usebuttonpressed() )
		wait .05;
	level._player freezecontrols( false );

	level._photosource.alpha = 0;
	flag_set( "psource_Notviewing" );
}

psource_select_next()
{
	if ( getdvar( "psource_select_next" ) == "" )
		return;
	if ( !( level._psource_selectindex == level._psource_views.size ) )
		level._psource_selectindex++ ;

	setdvar( "psource_select_next", "" );

}

psource_select_prev()
{
	if ( getdvar( "psource_select_prev" ) == "" )
		return;
	if ( !( level._psource_selectindex == 0 ) )
		level._psource_selectindex -- ;
	setdvar( "psource_select_prev", "" );

}

psource_select_new()
{
	if ( getdvar( "psource_select_new" ) == "" )
		return;
	level._psource_selectindex = level._psource_views.size;
	setdvar( "psource_select_new", "" );

}

psource_setview()
{
	if ( getdvar( "psource_setview" ) == "" )
		return;
	view = psource_getcurrentview();
//	view.temp_image = "case";
	psource_setvieworgang( view );
	setdvar( "psource_setview", "" );
}

psource_setvieworgang( view )
{
	view.origin = level._player geteye();
	view.angles = level._player getplayerangles();
}

psource_dump()
{
	if ( getdvar( "psource_dump" ) == "" )
		return;
	println( " " );
	println( " " );
	println( " " );
	println( "--------******--------" );
	println( "   photo source dump  (paste these to your level script before maps\_load::main() ) " );
	println( "--------******--------" );
	println( " " );
	println( " " );
//	println ("thread maps\\\_photosource::photosource_init();");
	for ( i = 0;i < level._psource_views.size;i++ )
		println( "maps\\\_photosource::psource_create(\"" + level._psource_views[ i ].image + "\"," + level._psource_views[ i ].origin + "," + level._psource_views[ i ].angles + ");" );
//	println ("thread maps\\\_photosource::photosource_main();");
	println( " " );
	println( " " );
	println( " " );
	setdvar( "psource_dump", "" );

}

psource_help()
{
	if ( getdvar( "psource_help" ) == "" )
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
	println( "psource_enable ( 7 Key ) - toggles psource on and off" );
	println( "psource_setview ( 8 Key ) - sets the view of the currently selected position." );
	println( "psource_select_prev ( [ Key ) - selects prev psourceposition" );
	println( "psource_select_next ( ] Key ) - selects next psourceposition" );
	println( "psource_select_new ( \\ Key ) - selects NEW psourceposition, used to create a new position on setview" );
	println( "psource_help ( h Key ) - prints to console this help text" );
	println( "psource_dump ( u Key ) - dumps view list to the console to be cut and pasted into script somewhere" );
	println( "psource_delete ( del Key ) - deletes the currently selected view (yellow star in circle)" );
	println( " " );
	println( "Pressing the usebutton on a sphere will teleport you so that you can see " );
	println( "the desired angle of the piece of reference, this also selects the view" );
	println( "and highlights it yellow" );
	println( " " );
	println( "To change the image of the currently selected view go to the console and enter this dvar" );
	println( "psource_image <materialname>" );
	println( " " );
	println( "Once you have all your views press the dump button, open your console.log and paste the script to your level script" );
	setdvar( "psource_help", "" );
}



psource_delete()
{
	if ( getdvar( "psource_delete" ) == "" )
		return;
	newarray = [];
	for ( i = 0;i < level._psource_views.size;i++ )
		if ( i != level._psource_selectindex )
			newarray[ newarray.size ] = level._psource_views[ i ];
	level._psource_views = newarray;
	flag_set( "psource_refresh" );
	setdvar( "psource_delete", "" );
}

psource_select_template()
{
	if ( getdvar( "psource_select_template" ) == "" )
		return;
	setdvar( "psource_select_template", "" );
}

psource_editmode_update()
{
	if ( getdvar( "psource_editmode" ) == "" )
		return;
	if ( !level._psource_editmode )
		level._psource_editmode = true;
	else
		level._psource_editmode = false;
	setdvar( "psource_editmode", "" );
}

psource_image_update()
{
	if ( getdvar( "psource_image" ) == "" )
		return;
	view = psource_getcurrentview();
	view.image =  getdvar( "psource_image" );
	view.temp_image = "case";// this is what will show when a new material is created( can't load mid level )
	setdvar( "psource_image", "" );
}

psource_getcurrentview()
{
	view = undefined;
	if ( isdefined( level._psource_views[ level._psource_selectindex ] ) )
		view = level._psource_views[ level._psource_selectindex ];
	else
		view = psource_newview( false );
	return view;
}

psource_newview( bScriptAdded )
{
	if ( !bScriptAdded )
		level._photosourcemod setshader( "psourcemodify", level._photosourcemodsize * 2, level._photosourcemodsize );

	view = spawnstruct();
	view.image = "case";
	if ( !bScriptAdded )
	{
		view.temp_image = "case";
		psource_setvieworgang( view );

	}
	if ( isdefined( level._psource_views[ level._psource_selectindex ] ) )
		level._psource_views[ level._psource_selectindex ] delete();
	level._psource_views[ level._psource_selectindex ] = view;
	if ( !bScriptAdded )
		flag_set( "psource_refresh" );
	return view;
}

//use this in level file to initialize all the stuff.
psource_create( image, position, angle )
{
	 /#
	if ( !isdefined( level._flag ) )
		level._flag = [];
	if ( !isdefined( level._flag[ "psource_Notviewing" ] ) )
		init();
	if ( !isdefined( level._psource_selectindex ) )
		level._psource_selectindex = 0;
	if ( !isdefined( level._psource_views ) )
		level._psource_views = [];
	view = psource_newview( true );
	view.origin = position;
	view.angles = angle;
	precacheshader( image );
	view.image = image;
	level._psource_selectindex++ ;
	#/
}

islookingorg( view )
{
	normalvec = vectorNormalize( view.origin - self getShootAtPos() );
	veccomp = vectorNormalize( ( view.origin - ( 0, 0, level._psource_selectrad * 2 ) ) - self getShootAtPos() );
	insidedot = vectordot( normalvec, veccomp );

	anglevec = anglestoforward( self getplayerangles() );
	vectordot = vectordot( anglevec, normalvec );
	if ( vectordot > insidedot )
		return true;
	else
		return false;
}