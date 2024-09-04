#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

ADRENALINE_UPDATE_TIME_SEC = 0.3;
ADRENALINE_MIN_HUD_ALPHA = 0.5;
ADRENALINE_FLASH_REMAINING_TIME_SEC = 5;
ADRENALINE_MIN_ALPHA_VALUE = 0.5;
ADRENALINE_FLASH_TIME_LEFT_SEC = 5.0;
ADRENALINE_ICON_PULSE_SCALE = 1.1;

//*******************************************************************
//																	*
//																	*
//*******************************************************************

init()
{
	if( getDvarInt( "prototype_adrenaline_enabled" ) == 1 )
	{
		println( "Adrenaline enabled" );
		initAdrenaline();

		level thread onPlayerConnect();
	}
	else
	{
		println( "Adrenaline disabled" );
	}
}


adrenalineDebugging()
{
	return getDvarInt( "set adrenaline_debugging" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

initAdrenaline()
{
	// setup the models and stuff we need for intel
	precacheShader("combathigh_overlay");
	level._adrenalineIconAsset = "hud_adrenaline";
	precacheShader( level._adrenalineIconAsset );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );

		player thread onPlayerSpawned();
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

onPlayerSpawned()
{
	for(;;)
	{
		if( adrenalineDebugging())
			println( "Adrenaline: onPlayerSpawned" );

		self waittill( "spawned_player" );
	
		self setupAdrenaline();

		// update adrenaline value
		self thread adrenalineThink();

		// clean up the hud at death
		self thread adrenalineWaitTillDeath();

		// update the hud
		self thread adrenalineUpdate();
	
		// cleanup when ready
		self thread adrenalineWaitCleanup();
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

adrenalineThink()
{
	self endon( "disconnect" );
	self endon( "death" );

	oldSPM = 0;
	for(;;)
	{
		// cull out old scores
		self adrenalineCleanScores();

		newSPM = self adrenalineScorePerMin();

		oldTime = self._adrenalineTimeSec;

		if( adrenalineDebugging() && newSPM > 0 )
		{
			println( "old spm " + oldSPM + " new spm " + newSPM + " thres " + addrenalineGetSPMThreshold() + " adren time " + self._adrenalineTimeSec + " dvar " + getDvarInt( "adrenaline_winddown_time_sec" ) );
		}

		// calculate if we are in adrenaline mode
		if( oldSPM < newSPM && addrenalineGetSPMThreshold() <= newSPM )
		{
			self._adrenalineTimeSec = getDvarInt( "adrenaline_winddown_time_sec" );
			self notify( "adrenaline_update" );
		}

		oldSPM = newSPM;

		// wait for another update run
		wait ADRENALINE_UPDATE_TIME_SEC;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

adrenalineGetAlphaValue()
{
	alpha =  ( self._adrenalineTimeSec - ADRENALINE_FLASH_TIME_LEFT_SEC )/( getDvarFloat( "adrenaline_winddown_time_sec" ) - ADRENALINE_FLASH_TIME_LEFT_SEC ) * (1 - ADRENALINE_MIN_ALPHA_VALUE);

	alpha += ADRENALINE_MIN_ALPHA_VALUE;
	if( alpha > 1.0 )
	{
		alpha = 1.0;
	}
	//println( "alpha value calc ", alpha );
	return alpha;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

adrenalineCleanScores()
{
	for ( i = 0; i < self._adrenScoreTimes.size; i++ )
	{
		if( gettime() - self._adrenScoreTimes[i] > getDvarFloat( "adrenaline_history_mins" ) * 60 * 1000 )
		{
			self._adrenScoreTimes[i] = undefined;
			self._adrenScores[i] = undefined; 
		}
	}

	self._adrenScoreTimes = array_removeUndefined( self._adrenScoreTimes );
	self._adrenScores = array_removeUndefined( self._adrenScores );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

adrenalineScorePerMin()
{
	totalScore = 0;
	foreach( score in self._adrenScores )
	{
		totalScore += score;
	}

	return totalScore / ( getDvarFloat( "adrenaline_history_mins" ) * 1.0 );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

addrenalineGetSPMThreshold()
{
	deaths = self GetPlayerData( "deaths" );
	kills = self GetPlayerData( "kills" );
	ratio = 1;
	if( deaths > 0 )
	{
		ratio = kills / ( deaths * 1.0 );
	}
	if( ratio < 1 )
	{
		ratio = 1;
	}

	if( adrenalineDebugging())
	{
		println( "Adrenaline: " + self.name + "kdratio " + ratio );
	}
	return getDvarInt( "adrenaline_spm_threshold" ) * ratio;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

adrenalineAddScore( score )
{
	if( adrenalineDebugging())
	{
		println( "Adrenaline: " + self.name + " added score " + score );
	}
	if( isDefined( self._adrenalineOverlayOn ))
	{
		self._adrenScoreTimes[self._adrenScoreTimes.size] = gettime();
		self._adrenScores[self._adrenScores.size] = score;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

adrenalineGetXPMultiplier()
{
	mult = 1;
	if( isDefined( self._adrenalineOverlayOn ) && self._adrenalineOverlayOn )
	{
		mult = getDvarInt( "adrenaline_xp_multiplier" );
	}
	return mult;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

setupAdrenaline()
{
	self._adrenalineTimeSec = 0;

	self._adrenScoreTimes = [];
	self._adrenScores = [];
	self._adrenalineOverlayOn = false;
	self._adrenalineXPEarned = false;

	self.adrenalineOverlay = undefined;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

adrenalineSetXPEarned()
{
	self._adrenalineXPEarned = true;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

adrenalineDidEarnXP()
{
	ret = false;

	if( getDvarInt( "prototype_adrenaline_enabled" ) == 1 )
	{
		ret = self._adrenalineXPEarned;
	}
	return ret;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

adrenalineInAdrenalineMode()
{
	ret = false;

	if( getDvarInt( "prototype_adrenaline_enabled" ) == 1 && isDefined( self._adrenalineOverlayOn ))
	{
		ret = self._adrenalineOverlayOn;
	}
	return ret;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

adrenalineTrySplash( killedPlayer )
{
	if( killedPlayer adrenalineInAdrenalineMode())
	{
		if( killedPlayer adrenalineDidEarnXP())
		{
			self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "adrenaline_mood_killer", 0 );
		}
		else
		{
			self thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "adrenaline_iced", 0 );
		}
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

enterAdrenaline()
{
	if( !self._adrenalineOverlayOn )
	{
		self.adrenalineOverlay = newClientHudElem( self );
		self.adrenalineOverlay.x = 0;
		self.adrenalineOverlay.y = 0;
		self.adrenalineOverlay.alignX = "left";
		self.adrenalineOverlay.alignY = "top";
		self.adrenalineOverlay.horzAlign = "fullscreen";
		self.adrenalineOverlay.vertAlign = "fullscreen";
		self.adrenalineOverlay setshader ( "combathigh_overlay", 640, 480 );
		self.adrenalineOverlay.sort = -10;
		self.adrenalineOverlay.archived = true;
		self.adrenalineOverlay.alpha = 0;
		self._adrenalineOverlayOn = true;

		self.adrenalineIcon = createIcon( level._adrenalineIconAsset, 40, 40 );
		self.adrenalineIcon.horzAlign		= "left";
		self.adrenalineIcon.alignX 			= "left";
		self.adrenalineIcon.y				= 0;
		self.adrenalineIcon.x				= 110;
		self.adrenalineIcon.sort			= -10;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

adrenalineUpdate()
{
	self endon( "death" );
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "adrenaline_update" );
		if( !self._adrenalineOverlayOn )
		{
			wait 0.05;
			if( adrenalineDebugging())
			{
				println(  "Adrenaline: " + self.name + " enterAdrenaline" );
			}
			self enterAdrenaline();
			self thread maps\mp\gametypes\_hud_message::SplashNotify( "adrenaline_enter", 0 );
		}
		self.adrenalineOverlay fadeOverTime( 0.3 );
		self.adrenalineOverlay.alpha = 1;
		wait 0.3;
		self thread adrenalineThreadWinddown();
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

adrenalineThreadWinddown()
{
	self endon( "adrenaline_update" );
	self endon( "death" );
	self endon( "disconnect" );
	// the normal fade down
	while( self._adrenalineTimeSec > ADRENALINE_FLASH_TIME_LEFT_SEC )
	{
		alpha = self adrenalineGetAlphaValue();
		if( adrenalineDebugging())
		{
			println( "Adrenaline: " + self.name + " update alpha " + alpha );
		}
		self.adrenalineOverlay fadeOverTime( ADRENALINE_UPDATE_TIME_SEC );
		self.adrenalineOverlay.alpha = alpha;
		wait ADRENALINE_UPDATE_TIME_SEC;
		self._adrenalineTimeSec -= ADRENALINE_UPDATE_TIME_SEC;
	}
	origWidth = 40;
	origHeight = 40;
	while( self._adrenalineTimeSec > 0 )
	{
		if( adrenalineDebugging())
		{
			println( "Adrenaline: " + self.name + " update alpha " + ADRENALINE_MIN_ALPHA_VALUE );
		}

		self.AdrenalineOverlay fadeOverTime( 0.1 );
		self.adrenalineOverlay.alpha = ADRENALINE_MIN_ALPHA_VALUE * 1.3;
		self.adrenalineIcon scaleOverTime( 0.05, int( origWidth * ADRENALINE_ICON_PULSE_SCALE ), int( origHeight * ADRENALINE_ICON_PULSE_SCALE ) );
		wait 0.05;
		self.adrenalineIcon scaleOverTime( 0.3, origWidth, origHeight );
		self.AdrenalineOverlay fadeOverTime( 0.1 );
		self.adrenalineOverlay.alpha = ADRENALINE_MIN_ALPHA_VALUE;
		wait 0.9;
		self._adrenalineTimeSec -= 1;
	}
	self.AdrenalineOverlay fadeOverTime( 0.3 );
	self.adrenalineOverlay.alpha = 0;
	wait 0.3;
	self notify( "adrenaline_cleanup" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

adrenalineWaitCleanup()
{
	for(;;)
	{
		self waittill_any_return( "adrenaline_cleanup", "death", "disconnect" );
		if( adrenalineDebugging())
		{
			println( "Adrenaline: " + self.name + "adrenalineWaitCleanup()" );
		}
		if( self._adrenalineOverlayOn )
		{
			self._adrenalineOverlayOn = false;
			self.adrenalineOverlay destroy();
			self.adrenalineOverlay = undefined;

			self.adrenalineIcon destroy();
			self.adrenalineIcon = undefined;
		}
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

adrenalineWaitTillDeath()
{
	self waittill( "death" );
	self notify( "adrenaline_cleanup" );
}