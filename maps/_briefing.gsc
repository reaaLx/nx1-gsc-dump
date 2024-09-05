/*
MISSION BRIEFING
*/

main()
{
	setsaveddvar( "hud_drawhud", 0 );

	level._script = tolower( getdvar( "mapname" ) );
	if ( !isdefined( level._tmpmsg ) )
		level._tmpmsg = [];

	player = getentarray( "player", "classname" )[ 0 ];
	setsaveddvar( "g_speed", 0 );
	player setViewmodel( "viewmodel_hands_cloth" ); // hack

	precacheShader( "black" );

	movieDefined = 0;
	for ( index = 0; index < level._slide.size; index++ )
	{
		if ( isdefined( level._slide[ index ][ "movie" ] ) )
		{
			movieDefined = 1;
			break;
		}
	}

	if ( movieDefined )
	{
		// movie
		wait 0.05;
		player gotothelevel( false );
	}
	else
	{
		// Press &&BUTTON_SELECTCHOICE" to Skip."
		precacheString( &"SCRIPT_PLATFORM_FIRE_TO_SKIP" );
		for ( i = 0;i < level._slide.size;i++ )
			if ( isdefined( level._slide[ i ][ "image" ] ) )
				precacheshader( level._slide[ i ][ "image" ] );

		player thread skipthebriefing();
		player dothebriefing();
		player gotothelevel( false );
	}
}


// Does the initial startup for a mission briefing
// iFadeTime Is the length of time it will take to transition between images. Defaults to 500 (milliseconds) Set to 0 for instant change
start( fFadeTime )
{
	level._briefing_running = true;
	level._briefing_ending = false;
	level._PlaceNextImage = "A";

	if ( isdefined( level._imageA ) )
		level._imageA destroy();
	if ( isdefined( level._imageB ) )
		level._imageB destroy();
	if ( isdefined( level._blackscreen ) )
		level._blackscreen destroy();
	if ( isdefined( level._FiretoSkip ) )
		level._FiretoSkip destroy();

	if ( !isDefined( fFadeTime ) || !fFadeTime )
	{
		level._briefing_fadeInTime = 0.5;
		level._briefing_fadeOutTime = 0.5;
	}
	else
	{
		level._briefing_fadeInTime = fFadeTime;
		level._briefing_fadeOutTime = fFadeTime;
	}

	self endon( "briefingskip" );
	self thread skipCheck();

	// Make the screen black
	level._blackscreen = newHudElem();
	level._blackscreen.sort = -1;
	level._blackscreen.alignX = "left";
	level._blackscreen.alignY = "top";
	level._blackscreen.x = 0;
	level._blackscreen.y = 0;
	level._blackscreen.horzAlign = "fullscreen";
	level._blackscreen.vertAlign = "fullscreen";
	level._blackscreen.foreground = true;

	level._blackscreen.alpha = 1;
	level._blackscreen setShader( "black", 640, 480 );

	// Fire to skip text
	level._FiretoSkip = newHudElem();
	level._FiretoSkip.sort = 1;
	level._FiretoSkip.alignX = "center";
	level._FiretoSkip.alignY = "top";
	level._FiretoSkip.fontScale = 2;
	level._FiretoSkip.x = 0;
	level._FiretoSkip.y = 60;
	level._FiretoSkip.horzAlign = "center";
	level._FiretoSkip.vertAlign = "fullscreen";
	level._FiretoSkip.foreground = true;
	// Press &&BUTTON_SELECTCHOICE" to Skip."
	level._FiretoSkip settext( &"SCRIPT_PLATFORM_FIRE_TO_SKIP" );
	level._FiretoSkip.alpha = 0.0;

	thread fadeInFireToSkip();

	//Image A
	level._imageA = newHudElem();
	level._imageA.alignX = "center";
	level._imageA.alignY = "middle";
	level._imageA.x = 320;
	level._imageA.y = 240;
	level._imageA.alpha = 0;
	level._imageA.horzAlign = "fullscreen";
	level._imageA.vertAlign = "fullscreen";
	level._imageA setShader( "black", 640, 360 );
	level._imageA.foreground = true;

	//Image B
	level._imageB = newHudElem();
	level._imageB.alignX = "center";
	level._imageB.alignY = "middle";
	level._imageB.x = 320;
	level._imageB.y = 240;
	level._imageB.horzAlign = "fullscreen";
	level._imageB.vertAlign = "fullscreen";
	level._imageB.alpha = 0;
	level._imageB setShader( "black", 640, 360 );
	level._imageB.foreground = true;

	self freezeControls( true );

	wait .5;

	for ( i = 0;i < level._slide.size;i++ )
	{
		soundplaying = false;
		if ( isdefined( level._slide[ i ][ "image" ] ) )
		{
			if ( level._script[ 0 ] != "m" )// movie_ maps don't play the sound
				self soundplay( "slide_advance" );
			wait .5;
			self thread image( level._slide[ i ][ "image" ] );
		}
		if ( isdefined( level._slide[ i ][ "dialog_wait" ] ) && self.dialogplaying[ level._slide[ i ][ "dialog_wait" ] ] )
		{
			self waittill( level._slide[ i ][ "dialog_wait" ] + "sounddone" );
		}
		if ( isdefined( level._slide[ i ][ "dialog" ] ) )
		{
			self soundplay( level._slide[ i ][ "dialog" ], level._slide[ i ][ "dialog" ] + "sounddone" );
			soundplaying = true;
		}
		if ( isdefined( level._slide[ i ][ "delay" ] ) )
		{
			wait( level._slide[ i ][ "delay" ] );
		}
		else if ( soundplaying )
		{
			self waittill( level._slide[ i ][ "dialog" ] + "sounddone" );
		}

	}
}

fadeInFireToSkip()
{
	wait( 1 );
	thread fadeFireToSkip();
	level._FiretoSkip fadeOverTime( level._briefing_fadeOutTime );
	level._FiretoSkip.alpha = 1.0;
}

// fades fire to skip after 7 seconds
fadeFireToSkip()
{
	wait 7;
	level._FiretoSkip fadeOverTime( level._briefing_fadeOutTime );
	level._FiretoSkip.alpha = 0.0;
}

// waits till the briefing is done
waitTillBriefingDone()
{
	self waittill( "briefingend" );
}

// This ends the briefing if the player says he wants to
skipCheck()
{
	self endon( "briefingend" );

	player = getentarray( "player", "classname" )[ 0 ];

	wait( 0.05 );

	maps\_utility::set_console_status();

	for ( ;; )
	{
		// we want to check if the "A" button has been pressed on xenon
		// instead of FIRE. 
		if ( level._console )
		{
			if ( player buttonPressed( "BUTTON_A" ) )
			{
				self notify( "briefingskip" );
				end();
				return;
			}
			wait( 0.05 );
			continue;
		}

		if ( player attackButtonPressed() )
		{
			self notify( "briefingskip" );
			end();
			return;
		}
		wait( 0.05 );
	}
}

image( sImageShader )
{
	self endon( "briefingskip" );

	if ( level._PlaceNextImage == "A" )
	{
		level._PlaceNextImage = "B";
		level._imageA setShader( sImageShader, 640, 360 );
		thread imageFadeOut( "B" );
		level._imageA fadeOverTime( level._briefing_fadeInTime );
		level._imageA.alpha = 1;
	}
	else if ( level._PlaceNextImage == "B" )
	{
		level._PlaceNextImage = "A";
		level._imageB setShader( sImageShader, 640, 360 );
		thread imageFadeOut( "A" );
		level._imageB fadeOverTime( level._briefing_fadeInTime );
		level._imageB.alpha = 1;
	}
}

imageFadeOut( elem )
{
	if ( elem == "A" )
	{
		level._imageA fadeOverTime( level._briefing_fadeOutTime );
		level._imageA.alpha = 0;
	}
	else if ( elem == "B" )
	{
		level._imageB fadeOverTime( level._briefing_fadeOutTime );
		level._imageB.alpha = 0;
	}
}

endThread()
{
	// Check for the briefing already being ended
	if ( !level._briefing_running )
		return;
	if ( level._briefing_ending )
		return;

	self notify( "briefingend" );
	level._briefing_ending = true;

	// Make sure the briefing audio is ended on for slideshows
	if ( level._script[ 0 ] != "m" )
	{
		self playsound( "stop_voice" );
	}

	// Fade the screen in
	thread imageFadeOut( "A" );
	thread imageFadeOut( "B" );

	wait( 1.5 );
//	self freezeControls(false);

	level._briefing_ending = false;
}

end()
{
	self thread endThread();
}

soundplay( dialog, msg )
{
	if ( isdefined( level._tmpmsg[ dialog ] ) )
		iprintlnbold( level._tmpmsg[ dialog ] );
	if ( isdefined( msg ) )
	{
		thread soundplay_flag( dialog, msg );
		self playsound( dialog, msg );
	}
	else
		self playsound( dialog );
}

soundplay_flag( dialog, msg )
{
	self.dialogplaying[ dialog ] = true;
	self waittill( msg );
	self.dialogplaying[ dialog ] = false;
}

dothebriefing()
{
	self start( 0.5 );
	if ( level._script[ 0 ] != "m" )// movie_ maps don't play the sound
		self soundplay( "slide_advance" );
	wait( 0.5 );
	end();
}

skipthebriefing()
{
	self waittill( "briefingskip" );
	gotothelevel( true );
}

gotothelevel( skipMovie )
{
	if ( !skipMovie )
	{
		for ( i = 0;i < level._slide.size;i++ )
		{
			if ( isdefined( level._slide[ i ][ "movie" ] ) )
				cinematic( level._slide[ i ][ "movie" ] );
		}
	}

	changeLevel( level._levelToLoad, false );
}

