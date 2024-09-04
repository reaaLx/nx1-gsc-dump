#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

exploder_sound()
{
	if ( isdefined( self.script_delay ) )
		wait self.script_delay;

	self playSound( level._scr_sound[ self.script_sound ] );
}

/*
saveModel()
{
	info["model"] = self.model;
	info["viewmodel"] = self getViewModel();
	attachSize = self getAttachSize();
	info["attach"] = [];
	
	assert(info["viewmodel"] != ""); // No viewmodel was associated with the player's model
	
	for(i = 0; i < attachSize; i++)
	{
		info["attach"][i]["model"] = self getAttachModelName(i);
		info["attach"][i]["tag"] = self getAttachTagName(i);
		info["attach"][i]["ignoreCollision"] = self getAttachIgnoreCollision(i);
	}
	
	return info;
}

loadModel(info)
{
	self detachAll();
	self setModel(info["model"]);
	self setViewModel(info["viewmodel"]);

	attachInfo = info["attach"];
	attachSize = attachInfo.size;
    
	for(i = 0; i < attachSize; i++)
		self attach(attachInfo[i]["model"], attachInfo[i]["tag"], attachInfo[i]["ignoreCollision"]);
}
*/

/* 
============= 
///ScriptDocBegin
"Name: delayThread( <delay>, <function>, <arg1>, <arg2>, <arg3>, <arg4> )"
"Summary: Delaythread is cool! It saves you from having to write extra script for once off commands. Note you don�t have to thread it off. Delaythread is that smart!"
"Module: Utility"
"MandatoryArg: <delay> : The delay before the function occurs"
"MandatoryArg: <delay> : The function to run."
"OptionalArg: <arg1> : parameter 1 to pass to the process"
"OptionalArg: <arg2> : parameter 2 to pass to the process"
"OptionalArg: <arg3> : parameter 3 to pass to the process"
"OptionalArg: <arg4> : parameter 4 to pass to the process"
"OptionalArg: <arg5> : parameter 5 to pass to the process"
"Example: delayThread( 3, ::flag_set, "player_can_rappel" );
"SPMP: both"
///ScriptDocEnd
============= 
*/ 
delayThread( timer, func, param1, param2, param3, param4, param5 )
{
	// to thread it off
	thread delayThread_proc( func, timer, param1, param2, param3, param4, param5 );
}


delayThread_proc( func, timer, param1, param2, param3, param4, param5 )
{
	wait( timer );
	if ( !IsDefined( param1 ) )
	{
		assertex( !isdefined( param2 ), "Delaythread does not support vars after undefined." );
		assertex( !isdefined( param3 ), "Delaythread does not support vars after undefined." );
		assertex( !isdefined( param4 ), "Delaythread does not support vars after undefined." );
		assertex( !isdefined( param5 ), "Delaythread does not support vars after undefined." );
		thread [[ func ]]();
	}
	else
	if ( !IsDefined( param2 ) )
	{
		assertex( !isdefined( param3 ), "Delaythread does not support vars after undefined." );
		assertex( !isdefined( param4 ), "Delaythread does not support vars after undefined." );
		assertex( !isdefined( param5 ), "Delaythread does not support vars after undefined." );
		thread [[ func ]]( param1 );
	}
	else
	if ( !IsDefined( param3 ) )
	{
		assertex( !isdefined( param4 ), "Delaythread does not support vars after undefined." );
		assertex( !isdefined( param5 ), "Delaythread does not support vars after undefined." );
		thread [[ func ]]( param1, param2 );
	}
	else
	if ( !IsDefined( param4 ) )	
	{
		assertex( !isdefined( param5 ), "Delaythread does not support vars after undefined." );
		thread [[ func ]]( param1, param2, param3 );
	}
	else
	if ( !IsDefined( param5 ) )	
	{
		thread [[ func ]]( param1, param2, param3, param4 );
	}
	else
	{
		thread [[ func ]]( param1, param2, param3, param4, param5 );
	}
}

getPlant()
{
	start = self.origin + ( 0, 0, 10 );

	range = 11;
	forward = anglesToForward( self.angles );
	forward = vector_multiply( forward, range );

	traceorigins[ 0 ] = start + forward;
	traceorigins[ 1 ] = start;

	trace = bulletTrace( traceorigins[ 0 ], ( traceorigins[ 0 ] + ( 0, 0, -18 ) ), false, undefined );
	if ( trace[ "fraction" ] < 1 )
	{
		//println("^6Using traceorigins[0], tracefraction is", trace["fraction"]);

		temp = spawnstruct();
		temp.origin = trace[ "position" ];
		temp.angles = orientToNormal( trace[ "normal" ] );
		return temp;
	}

	trace = bulletTrace( traceorigins[ 1 ], ( traceorigins[ 1 ] + ( 0, 0, -18 ) ), false, undefined );
	if ( trace[ "fraction" ] < 1 )
	{
		//println("^6Using traceorigins[1], tracefraction is", trace["fraction"]);

		temp = spawnstruct();
		temp.origin = trace[ "position" ];
		temp.angles = orientToNormal( trace[ "normal" ] );
		return temp;
	}

	traceorigins[ 2 ] = start + ( 16, 16, 0 );
	traceorigins[ 3 ] = start + ( 16, -16, 0 );
	traceorigins[ 4 ] = start + ( -16, -16, 0 );
	traceorigins[ 5 ] = start + ( -16, 16, 0 );

	besttracefraction = undefined;
	besttraceposition = undefined;
	for ( i = 0; i < traceorigins.size; i++ )
	{
		trace = bulletTrace( traceorigins[ i ], ( traceorigins[ i ] + ( 0, 0, -1000 ) ), false, undefined );

		//ent[i] = spawn("script_model",(traceorigins[i]+(0, 0, -2)));
		//ent[i].angles = (0, 180, 180);
		//ent[i] setmodel("105");

		//println("^6trace ", i ," fraction is ", trace["fraction"]);

		if ( !isdefined( besttracefraction ) || ( trace[ "fraction" ] < besttracefraction ) )
		{
			besttracefraction = trace[ "fraction" ];
			besttraceposition = trace[ "position" ];

			//println("^6besttracefraction set to ", besttracefraction, " which is traceorigin[", i, "]");
		}
	}

	if ( besttracefraction == 1 )
		besttraceposition = self.origin;

	temp = spawnstruct();
	temp.origin = besttraceposition;
	temp.angles = orientToNormal( trace[ "normal" ] );
	return temp;
}

orientToNormal( normal )
{
	hor_normal = ( normal[ 0 ], normal[ 1 ], 0 );
	hor_length = length( hor_normal );

	if ( !hor_length )
		return( 0, 0, 0 );

	hor_dir = vectornormalize( hor_normal );
	neg_height = normal[ 2 ] * - 1;
	tangent = ( hor_dir[ 0 ] * neg_height, hor_dir[ 1 ] * neg_height, hor_length );
	plant_angle = vectortoangles( tangent );

	//println("^6hor_normal is ", hor_normal);
	//println("^6hor_length is ", hor_length);
	//println("^6hor_dir is ", hor_dir);
	//println("^6neg_height is ", neg_height);
	//println("^6tangent is ", tangent);
	//println("^6plant_angle is ", plant_angle);

	return plant_angle;
}

deletePlacedEntity( entity )
{
	entities = getentarray( entity, "classname" );
	for ( i = 0; i < entities.size; i++ )
	{
		//println("DELETED: ", entities[i].classname);
		entities[ i ] delete();
	}
}

playSoundOnPlayers( sound, team, excludeList )
{
	assert( isdefined( level._players ) );

	if ( level._splitscreen )
	{
		if ( isdefined( level._players[ 0 ] ) )
			level._players[ 0 ] playLocalSound( sound );
	}
	else
	{
		if ( isDefined( team ) )
		{
			if ( isdefined( excludeList ) )
			{
				for ( i = 0; i < level._players.size; i++ )
				{
					player = level._players[ i ];
					if ( isdefined( player.pers[ "team" ] ) && ( player.pers[ "team" ] == team ) && !isExcluded( player, excludeList ) )
						player playLocalSound( sound );
				}
			}
			else
			{
				for ( i = 0; i < level._players.size; i++ )
				{
					player = level._players[ i ];
					if ( isdefined( player.pers[ "team" ] ) && ( player.pers[ "team" ] == team ) )
						player playLocalSound( sound );
				}
			}
		}
		else
		{
			if ( isdefined( excludeList ) )
			{
				for ( i = 0; i < level._players.size; i++ )
				{
					if ( !isExcluded( level._players[ i ], excludeList ) )
						level._players[ i ] playLocalSound( sound );
				}
			}
			else
			{
				for ( i = 0; i < level._players.size; i++ )
					level._players[ i ] playLocalSound( sound );
			}
		}
	}
}


sortLowerMessages()
{
	for ( i = 1; i < self.lowerMessages.size; i++ )
	{
		message = self.lowerMessages[ i ];
		priority = message.priority;
		for ( j = i - 1; j >= 0 && priority > self.lowerMessages[ j ].priority; j -- )
			self.lowerMessages[ j + 1 ] = self.lowerMessages[ j ];
		self.lowerMessages[ j + 1 ] = message;
	}
}


addLowerMessage( name, text, time, priority, showTimer, shouldFade, fadeToAlpha, fadeToAlphaTime )
{
	newMessage = undefined;
	foreach ( message in self.lowerMessages )
	{
		if ( message.name == name )
		{
			if ( message.text == text && message.priority == priority )
				return;

			newMessage = message;
			break;
		}
	}

	if ( !isDefined( newMessage ) )
	{
		newMessage = spawnStruct();
		self.lowerMessages[ self.lowerMessages.size ] = newMessage;
	}

	newMessage.name = name;
	newMessage.text = text;
	newMessage.time = time;
	newMessage.addTime = getTime();
	newMessage.priority = priority;
	newMessage.showTimer = showTimer;
	newMessage.shouldFade = shouldFade;
	newMessage.fadeToAlpha = fadeToAlpha;
	newMessage.fadeToAlphaTime = fadeToAlphaTime;

	sortLowerMessages();
}


removeLowerMessage( name )
{
	if( IsDefined( self.lowerMessages ) )
	{
		for ( i = 0; i < self.lowerMessages.size; i++ )
		{
			if ( self.lowerMessages[ i ].name != name )
				continue;
	
			message = self.lowerMessages[ i ];
			if ( i < self.lowerMessages.size - 1 )
				self.lowerMessages[ i ] = self.lowerMessages[ self.lowerMessages.size - 1 ];
	
			self.lowerMessages[ self.lowerMessages.size - 1 ] = undefined;
		}
	
		sortLowerMessages();
	}
}


getLowerMessage()
{
	return self.lowerMessages[ 0 ];
}

/*
============= 
///ScriptDocBegin
"Name: setLowerMessage( <name>, <text>, <time>, <priority>, <showTimer>, <shouldFade>, <fadeToAlpha>, <fadeToAlphaTime> )"
"Summary: Creates a message to show on the lower half of the screen."
"Module: HUD"
"CallOn: A player"
"MandatoryArg: <name> The name of the message."
"MandatoryArg: <text> The text of the message to display."
"OptionalArg: <time> How long the message will display (default 0 - infinite)."
"OptionalArg: <priority> The priority of the message to display (default 1)."
"OptionalArg: <showTimer> If you pass in time do you want the timer text to show, if not then lower message will fade over time (default false)."
"OptionalArg: <shouldFade> If you want the message to fade to an alpha after coming up the first time (default false)."
"OptionalArg: <fadeToAlpha> If you want the message to fade to an alpha after coming up the first time, pass in the value (default 0.85)."
"OptionalArg: <fadeToAlphaTime> The time that this message will fade to the alpha value passed in before this (default 3.0)."
"Example: self setLowerMessage( "last_stand", &"PLATFORM_COWARDS_WAY_OUT", undefined, 50 );
"SPMP: multiplayer"
///ScriptDocEnd
============= 
*/
setLowerMessage( name, text, time, priority, showTimer, shouldFade, fadeToAlpha, fadeToAlphaTime )
{
	if ( !isDefined( priority ) )
		priority = 1;

	if ( !isDefined( time ) )
		time = 0;

	if ( !isDefined( showTimer ) )
		showTimer = false;

	if ( !isDefined( shouldFade ) )
		shouldFade = false;

	if ( !isDefined( fadeToAlpha ) )
		fadeToAlpha = 0.85;

	if ( !isDefined( fadeToAlphaTime ) )
		fadeToAlphaTime = 3.0;

	self addLowerMessage( name, text, time, priority, showTimer, shouldFade, fadeToAlpha, fadeToAlphaTime );
	self updateLowerMessage();
	//self notify( "lower_message_set" );
}


updateLowerMessage()
{
	message = self getLowerMessage();

	if ( !isDefined( message ) )
	{
		if ( isDefined( self.lowerMessage ) )
		{
			self.lowerMessage.alpha = 0;
		}
		if ( isDefined( self.lowerTimer ) )
		{
			self.lowerTimer.alpha = 0;
		}
		return;
	}

	self.lowerMessage setText( message.text );
	self.lowerMessage.alpha = 0.85;
	self.lowerTimer.alpha = 1;

	if( message.shouldFade )
	{
		self.lowerMessage FadeOverTime( message.fadeToAlphaTime );
		self.lowerMessage.alpha = message.fadeToAlpha;
	}

	if ( message.time > 0 && message.showTimer )
	{
		self.lowerTimer setTimer( max( message.time - ( ( getTime() - message.addTime ) / 1000 ), 0.1 ) );
	}
	else if( message.time > 0 && !message.showTimer )
	{
		self.lowerTimer setText( "" );
		self.lowerMessage FadeOverTime( message.time );
		self.lowerMessage.alpha = 0;
		self thread clearOnDeath( message );
		self thread clearAfterFade( message );
	}
	else
	{
		self.lowerTimer setText( "" );
	}
}

clearOnDeath( message )
{
	self notify( "message_cleared" );
	self endon( "message_cleared" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	self waittill( "death" );
	self clearLowerMessage( message.name );
}

clearAfterFade( message )
{
	wait( message.time );
	self clearLowerMessage( message.name );
	self notify( "message_cleared" );
}
/*
============= 
///ScriptDocBegin
"Name: clearLowerMessage( <name> )"
"Summary: Clears the message on the lower portion of the screen."
"Module: HUD"
"CallOn: A player"
"MandatoryArg: <name> The name of the message."
"Example: self clearLowerMessage( "last_stand" );
"SPMP: multiplayer"
///ScriptDocEnd
============= 
*/
clearLowerMessage( name, fadetime )
{
	self removeLowerMessage( name );
	self updateLowerMessage();
}

clearLowerMessages()
{
	for ( i = 0; i < self.lowerMessages.size; i++ )
		self.lowerMessages[ i ] = undefined;

	if ( !isDefined( self.lowerMessage ) )
		return;

	self updateLowerMessage();
}

printOnTeam( printString, team )
{
	foreach ( player in level._players )
	{
		if ( player.team != team )
			continue;

		player iPrintLn( printString );
	}
}

printBoldOnTeam( text, team )
{
	assert( isdefined( level._players ) );
	for ( i = 0; i < level._players.size; i++ )
	{
		player = level._players[ i ];
		if ( ( isdefined( player.pers[ "team" ] ) ) && ( player.pers[ "team" ] == team ) )
			player iprintlnbold( text );
	}
}

printBoldOnTeamArg( text, team, arg )
{
	assert( isdefined( level._players ) );
	for ( i = 0; i < level._players.size; i++ )
	{
		player = level._players[ i ];
		if ( ( isdefined( player.pers[ "team" ] ) ) && ( player.pers[ "team" ] == team ) )
			player iprintlnbold( text, arg );
	}
}

printOnTeamArg( text, team, arg )
{
	assert( isdefined( level._players ) );
	for ( i = 0; i < level._players.size; i++ )
	{
		player = level._players[ i ];
		if ( ( isdefined( player.pers[ "team" ] ) ) && ( player.pers[ "team" ] == team ) )
			player iprintln( text, arg );
	}
}

printOnPlayers( text, team )
{
	players = level._players;
	for ( i = 0; i < players.size; i++ )
	{
		if ( isDefined( team ) )
		{
			if ( ( isdefined( players[ i ].pers[ "team" ] ) ) && ( players[ i ].pers[ "team" ] == team ) )
				players[ i ] iprintln( text );
		}
		else
		{
			players[ i ] iprintln( text );
		}
	}
}

printAndSoundOnEveryone( team, otherteam, printFriendly, printEnemy, soundFriendly, soundEnemy, printarg )
{
	shouldDoSounds = isDefined( soundFriendly );

	shouldDoEnemySounds = false;
	if ( isDefined( soundEnemy ) )
	{
		assert( shouldDoSounds );// can't have an enemy sound without a friendly sound
		shouldDoEnemySounds = true;
	}

	if ( level._splitscreen || !shouldDoSounds )
	{
		for ( i = 0; i < level._players.size; i++ )
		{
			player = level._players[ i ];
			playerteam = player.pers[ "team" ];
			if ( isdefined( playerteam ) )
			{
				if ( playerteam == team && isdefined( printFriendly ) )
					player iprintln( printFriendly, printarg );
				else if ( playerteam == otherteam && isdefined( printEnemy )  )
					player iprintln( printEnemy, printarg );
			}
		}
		if ( shouldDoSounds )
		{
			assert( level._splitscreen );
			level._players[ 0 ] playLocalSound( soundFriendly );
		}
	}
	else
	{
		assert( shouldDoSounds );
		if ( shouldDoEnemySounds )
		{
			for ( i = 0; i < level._players.size; i++ )
			{
				player = level._players[ i ];
				playerteam = player.pers[ "team" ];
				if ( isdefined( playerteam ) )
				{
					if ( playerteam == team )
					{
						if ( isdefined( printFriendly ) )
							player iprintln( printFriendly, printarg );
						player playLocalSound( soundFriendly );
					}
					else if ( playerteam == otherteam )
					{
						if ( isdefined( printEnemy ) )
							player iprintln( printEnemy, printarg );
						player playLocalSound( soundEnemy );
					}
				}
			}
		}
		else
		{
			for ( i = 0; i < level._players.size; i++ )
			{
				player = level._players[ i ];
				playerteam = player.pers[ "team" ];
				if ( isdefined( playerteam ) )
				{
					if ( playerteam == team )
					{
						if ( isdefined( printFriendly ) )
							player iprintln( printFriendly, printarg );
						player playLocalSound( soundFriendly );
					}
					else if ( playerteam == otherteam )
					{
						if ( isdefined( printEnemy ) )
							player iprintln( printEnemy, printarg );
					}
				}
			}
		}
	}
}

printAndSoundOnTeam( team, printString, soundAlias )
{
	foreach ( player in level._players )
	{
		if ( player.team != team )
			continue;

		player printAndSoundOnPlayer( printString, soundAlias );
	}
}

printAndSoundOnPlayer( printString, soundAlias )
{
	self iPrintLn( printString );
	self playLocalSound( soundAlias );
}

_playLocalSound( soundAlias )
{
	if ( level._splitscreen && self getEntityNumber() != 0 )
		return;

	self playLocalSound( soundAlias );
}

dvarIntValue( dVar, defVal, minVal, maxVal )
{
	dVar = "scr_" + level._gameType + "_" + dVar;
	if ( getDvar( dVar ) == "" )
	{
		setDvar( dVar, defVal );
		return defVal;
	}

	value = getDvarInt( dVar );

	if ( value > maxVal )
		value = maxVal;
	else if ( value < minVal )
		value = minVal;
	else
		return value;

	setDvar( dVar, value );
	return value;
}

dvarFloatValue( dVar, defVal, minVal, maxVal )
{
	dVar = "scr_" + level._gameType + "_" + dVar;
	if ( getDvar( dVar ) == "" )
	{
		setDvar( dVar, defVal );
		return defVal;
	}

	value = getDvarFloat( dVar );

	if ( value > maxVal )
		value = maxVal;
	else if ( value < minVal )
		value = minVal;
	else
		return value;

	setDvar( dVar, value );
	return value;
}

play_sound_on_tag( alias, tag )
{
	if ( isdefined( tag ) )
	{
		playsoundatpos( self getTagOrigin( tag ), alias );
	}
	else
	{
		playsoundatpos( self.origin, alias );
	}
}

getOtherTeam( team )
{
	if( level._multiTeamBased )
	{
		assertMsg( "getOtherTeam() should not be called in Multi Team Based gametypes" );
	}
	
	if ( team == "allies" )
		return "axis";
	else if ( team == "axis" )
		return "allies";

	assertMsg( "getOtherTeam: invalid team " + team );
}

wait_endon( waitTime, endOnString, endonString2, endonString3 )
{
	self endon( endOnString );
	if ( isDefined( endonString2 ) )
		self endon( endonString2 );
	if ( isDefined( endonString3 ) )
		self endon( endonString3 );

	wait( waitTime );
}

isMG( weapon )
{
	return ( isSubStr( weapon, "_bipod_" ) || weapon == "turret_minigun_mp" );
}

initPersStat( dataName )
{
	if ( !isDefined( self.pers[ dataName ] ) )
		self.pers[ dataName ] = 0;
}

getPersStat( dataName )
{
	return self.pers[ dataName ];
}

incPersStat( dataName, increment )
{
	self.pers[ dataName ] += increment;
	self maps\mp\gametypes\_persistence::statAdd( dataName, increment );
}

setPersStat( dataName, value )
{
	assertEx( isDefined( dataName ), "Called setPersStat with no dataName defined." );
	assertEx( isDefined( value ), "Called setPersStat for " + dataName + " with no value defined." );
	
	self.pers[ dataName ] = value;
}

initPlayerStat( ref, defaultvalue )
{
	if ( !isDefined( self.stats["stats_" + ref ] ) )
	{
		if ( !isDefined( defaultvalue ) )
			defaultvalue = 0;
		
		self.stats["stats_" + ref ] = spawnstruct();
		self.stats["stats_" + ref ].value = defaultvalue;
	}
}

incPlayerStat( ref, increment )
{
	stat = self.stats["stats_" + ref ];
	stat.value += increment;
}

setPlayerStat( ref, value )
{
	stat = self.stats["stats_" + ref ];
	stat.value = value;
	stat.time = getTime();
}

getPlayerStat( ref )
{
		return self.stats["stats_" + ref ].value;
}

doesPlayerStatExist ( ref )
{
	if ( isDefined ( self.stats["stats_" + ref ] ))
		return true;
	else
		return false;
}

getPlayerStatTime( ref )
{
	return self.stats["stats_" + ref ].time;
}

setPlayerStatIfGreater( ref, newvalue )
{
	currentvalue = self getPlayerStat( ref );

	if ( newvalue > currentvalue )
		self setPlayerStat( ref, newvalue );
}

setPlayerStatIfLower( ref, newvalue )
{
	currentvalue = self getPlayerStat( ref );

	if ( newvalue < currentvalue )
		self setPlayerStat( ref, newvalue );
}

updatePersRatio( ratio, num, denom )
{
	numValue = self maps\mp\gametypes\_persistence::statGet( num );
	denomValue = self maps\mp\gametypes\_persistence::statGet( denom );
	if ( denomValue == 0 )
		denomValue = 1;

	self maps\mp\gametypes\_persistence::statSet( ratio, int( ( numValue * 1000 ) / denomValue ) );
}

updatePersRatioBuffered( ratio, num, denom )
{
	numValue = self maps\mp\gametypes\_persistence::statGetBuffered( num );
	denomValue = self maps\mp\gametypes\_persistence::statGetBuffered( denom );
	if ( denomValue == 0 )
		denomValue = 1;

	self maps\mp\gametypes\_persistence::statSetBuffered( ratio, int( ( numValue * 1000 ) / denomValue ) );
}


// to be used with things that are slow.
// unfortunately, it can only be used with things that aren't time critical.
WaitTillSlowProcessAllowed( allowLoop )
{
	// wait only a few frames if necessary
	// if we wait too long, we might get too many threads at once and run out of variables
	// i'm trying to avoid using a loop because i don't want any extra variables
	if ( level._lastSlowProcessFrame == gettime() )
	{
		if ( isDefined( allowLoop ) && allowLoop )
		{
			while ( level._lastSlowProcessFrame == getTime() )
				wait( 0.05 );
		}
		else
		{
			wait .05;
			if ( level._lastSlowProcessFrame == gettime() )
			{
				wait .05;
				if ( level._lastSlowProcessFrame == gettime() )
				{
					wait .05;
					if ( level._lastSlowProcessFrame == gettime() )
					{
						wait .05;
					}
				}
			}
		}
	}

	level._lastSlowProcessFrame = getTime();
}


waitForTimeOrNotify( time, notifyname )
{
	self endon( notifyname );
	wait time;
}


isExcluded( entity, entityList )
{
	for ( index = 0; index < entityList.size; index++ )
	{
		if ( entity == entityList[ index ] )
			return true;
	}
	return false;
}


leaderDialog( dialog, team, group, excludeList )
{
	assert( isdefined( level._players ) );

	if ( level._splitscreen )
		return;

	if ( dialog == "null" )
		return;

	if ( !isDefined( team ) )
	{
		leaderDialogBothTeams( dialog, "allies", dialog, "axis", group, excludeList );
		return;
	}

	if ( level._splitscreen )
	{
		if ( level._players.size )
			level._players[ 0 ] leaderDialogOnPlayer( dialog, group );
		return;
	}

	if ( isDefined( excludeList ) )
	{
		for ( i = 0; i < level._players.size; i++ )
		{
			player = level._players[ i ];
			if ( ( isDefined( player.pers[ "team" ] ) && ( player.pers[ "team" ] == team ) ) && !isExcluded( player, excludeList ) )
				player leaderDialogOnPlayer( dialog, group );
		}
	}
	else
	{
		for ( i = 0; i < level._players.size; i++ )
		{
			player = level._players[ i ];
			if ( isDefined( player.pers[ "team" ] ) && ( player.pers[ "team" ] == team ) )
				player leaderDialogOnPlayer( dialog, group );
		}
	}
}


leaderDialogBothTeams( dialog1, team1, dialog2, team2, group, excludeList )
{
	assert( isdefined( level._players ) );

	if ( level._splitscreen )
		return;

	if ( level._splitscreen )
	{
		if ( level._players.size )
			level._players[ 0 ] leaderDialogOnPlayer( dialog1, group );
		return;
	}

	if ( isDefined( excludeList ) )
	{
		for ( i = 0; i < level._players.size; i++ )
		{
			player = level._players[ i ];
			team = player.pers[ "team" ];

			if ( !isDefined( team ) )
				continue;

			if ( isExcluded( player, excludeList ) )
				continue;

			if ( team == team1 )
				player leaderDialogOnPlayer( dialog1, group );
			else if ( team == team2 )
				player leaderDialogOnPlayer( dialog2, group );
		}
	}
	else
	{
		for ( i = 0; i < level._players.size; i++ )
		{
			player = level._players[ i ];
			team = player.pers[ "team" ];

			if ( !isDefined( team ) )
				continue;

			if ( team == team1 )
				player leaderDialogOnPlayer( dialog1, group );
			else if ( team == team2 )
				player leaderDialogOnPlayer( dialog2, group );
		}
	}
}


leaderDialogOnPlayers( dialog, players, group )
{
	foreach ( player in players )
		player leaderDialogOnPlayer( dialog, group );
}


leaderDialogOnPlayer( dialog, group, groupOverride )
{
	if ( !isDefined( groupOverride ) )
		groupOverride = false;
	
	team = self.pers[ "team" ];

	if ( level._splitscreen )
		return;

	if ( !isDefined( team ) )
		return;

	if( !level._multiTeamBased )
	{
		if ( team != "allies" && team != "axis" )
			return;
	}

	if ( isDefined( group ) )
	{
		// ignore the message if one from the same group is already playing
		if ( self.leaderDialogGroup == group )
		{
			if ( groupOverride )
			{
				// possible to have an empty leaderDialogActive, in the case that the previous sound was defined to the string "null",
				// as is the convention in column 7 in killStreakTable.csv
				if ( self.leaderDialogActive != "" )
				{
					self stopLocalSound( self.leaderDialogActive );
				}

				self thread playLeaderDialogOnPlayer( dialog, team );
			}
			
			return;
		}

		hadGroupDialog = isDefined( self.leaderDialogGroups[ group ] );

		self.leaderDialogGroups[ group ] = dialog;
		dialog = group;

		// exit because the "group" dialog call is already in the queue
		if ( hadGroupDialog )
			return;
	}

	if ( self.leaderDialogActive == "" )
		self thread playLeaderDialogOnPlayer( dialog, team );
	else
		self.leaderDialogQueue[ self.leaderDialogQueue.size ] = dialog;		
}


playLeaderDialogOnPlayer( dialog, team )
{
	self endon( "disconnect" );

	self notify ( "playLeaderDialogOnPlayer" );
	self endon ( "playLeaderDialogOnPlayer" );

	if ( isDefined( self.leaderDialogGroups[ dialog ] ) )
	{
		group = dialog;
		dialog = self.leaderDialogGroups[ group ];
		self.leaderDialogGroups[ group ] = undefined;
		self.leaderDialogGroup = group;
	}
	
	assertEx( isDefined( game[ "dialog" ][ dialog ] ), "Dialog " + dialog + " was not defined in game[dialog] array." );

	if ( isSubStr( game[ "dialog" ][ dialog ], "null" ) )
	{
		/#
			self iprintln( "No dialog entry for '" + dialog + "' in playLeaderDialogOnPlayer" );
		#/
		return;
	}


	self.leaderDialogActive = game[ "voice" ][ team ] + game[ "dialog" ][ dialog ];
	self playLocalSound( game[ "voice" ][ team ] + game[ "dialog" ][ dialog ] );

	wait( 3.0 );
	self.leaderDialogLocalSound = "";
	
	self.leaderDialogActive = "";
	self.leaderDialogGroup = "";

	if ( self.leaderDialogQueue.size > 0 )
	{
		nextDialog = self.leaderDialogQueue[ 0 ];

		for ( i = 1; i < self.leaderDialogQueue.size; i++ )
			self.leaderDialogQueue[ i - 1 ] = self.leaderDialogQueue[ i ];
		self.leaderDialogQueue[ i - 1 ] = undefined;

		self thread playLeaderDialogOnPlayer( nextDialog, team );
	}
}


updateMainMenu()
{
	if (self.pers[ "team" ] == "spectator" )
	{
		self setClientDvar("g_scriptMainMenu", game["menu_team"]);
	}
	else
	{
		self setClientDvar( "g_scriptMainMenu", game[ "menu_class_" + self.pers["team"] ] );
	}
}


updateObjectiveText()
{
	if ( self.pers[ "team" ] == "spectator" )
	{
		self setClientDvar( "cg_objectiveText", "" );
		return;
	}

	if ( getWatchedDvar( "scorelimit" ) > 0 && !isObjectiveBased() )
	{
		if ( level._splitScreen )
			self setclientdvar( "cg_objectiveText", getObjectiveScoreText( self.pers[ "team" ] ) );
		else
			self setclientdvar( "cg_objectiveText", getObjectiveScoreText( self.pers[ "team" ] ), getWatchedDvar( "scorelimit" ) );
	}
	else
	{
		self setclientdvar( "cg_objectiveText", getObjectiveText( self.pers[ "team" ] ) );
	}
}


setObjectiveText( team, text )
{
	game[ "strings" ][ "objective_" + team ] = text;
	precacheString( text );
}

setObjectiveScoreText( team, text )
{
	game[ "strings" ][ "objective_score_" + team ] = text;
	precacheString( text );
}

setObjectiveHintText( team, text )
{
	game[ "strings" ][ "objective_hint_" + team ] = text;
	precacheString( text );
}

getObjectiveText( team )
{
	return game[ "strings" ][ "objective_" + team ];
}

getObjectiveScoreText( team )
{
	return game[ "strings" ][ "objective_score_" + team ];
}

getObjectiveHintText( team )
{
	return game[ "strings" ][ "objective_hint_" + team ];
}



getTimePassed()
{
	if ( !isDefined( level._startTime ) )
		return 0;
	
	if ( level._timerStopped )
		return( level._timerPauseTime - level._startTime ) - level._discardTime;
	else
		return( gettime() - level._startTime ) - level._discardTime;

}

getSecondsPassed()
{
	return (getTimePassed() / 1000);
}

getMinutesPassed()
{
	return (getSecondsPassed() / 60);
}

ClearKillcamState()
{
	self.forcespectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
}

isInKillcam()
{
	return ( self.forcespectatorclient != -1 || self.killcamentity != -1 );
}

isValidClass( class )
{
	return isDefined( class ) && class != "";
}



getValueInRange( value, minValue, maxValue )
{
	if ( value > maxValue )
		return maxValue;
	else if ( value < minValue )
		return minValue;
	else
		return value;
}




waitForTimeOrNotifies( desiredDelay )
{
	startedWaiting = getTime();

	waitedTime = ( getTime() - startedWaiting ) / 1000;

	if ( waitedTime < desiredDelay )
	{
		wait desiredDelay - waitedTime;
		return desiredDelay;
	}
	else
	{
		return waitedTime;
	}
}

closeMenus()
{
	self closepopupMenu();
	self closeInGameMenu();
}


logXPGains()
{
	if ( !isDefined( self.xpGains ) )
		return;

	xpTypes = getArrayKeys( self.xpGains );
	for ( index = 0; index < xpTypes.size; index++ )
	{
		gain = self.xpGains[ xpTypes[ index ] ];
		if ( !gain )
			continue;

		self logString( "xp " + xpTypes[ index ] + ": " + gain );
	}
}


registerRoundSwitchDvar( dvarString, defaultValue, minValue, maxValue )
{
	registerWatchDvarInt( "roundswitch", defaultValue );

	dvarString = ( "scr_" + dvarString + "_roundswitch" );

	level._roundswitchDvar = dvarString;
	level._roundswitchMin = minValue;
	level._roundswitchMax = maxValue;
	level._roundswitch = getDvarInt( dvarString, defaultValue );
	
	if ( level._roundswitch < minValue )
		level._roundswitch = minValue;
	else if ( level._roundswitch > maxValue )
		level._roundswitch = maxValue;
}


registerRoundLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	registerWatchDvarInt( "roundlimit", defaultValue );
}


registerWinLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	registerWatchDvarInt( "winlimit", defaultValue );
}


registerScoreLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	registerWatchDvarInt( "scorelimit", defaultValue );
}


registerTimeLimitDvar( dvarString, defaultValue, minValue, maxValue )
{
	registerWatchDvarFloat( "timelimit", defaultValue );
	makeDvarServerInfo( "ui_timelimit", getTimeLimit() );
}

registerHalfTimeDvar( dvarString, defaultValue, minValue, maxValue) 
{
	registerWatchDvarInt( "halftime", defaultValue );
	makeDvarServerInfo( "ui_halftime", getHalfTime() );
}

registerNumLivesDvar( dvarString, defaultValue, minValue, maxValue )
{
	registerWatchDvarInt( "numlives", defaultValue );
}

setOverTimeLimitDvar( value )
{
	makeDvarServerInfo( "overtimeTimeLimit", value );
}

get_damageable_player( player, playerpos )
{
	newent = spawnstruct();
	newent.isPlayer = true;
	newent.isADestructable = false;
	newent.entity = player;
	newent.damageCenter = playerpos;
	return newent;
}

get_damageable_sentry( sentry, sentryPos )
{
	newent = spawnstruct();
	newent.isPlayer = false;
	newent.isADestructable = false;
	newent.isSentry = true;
	newent.entity = sentry;
	newent.damageCenter = sentryPos;
	return newent;
}

get_damageable_grenade( grenade, entpos )
{
	newent = spawnstruct();
	newent.isPlayer = false;
	newent.isADestructable = false;
	newent.entity = grenade;
	newent.damageCenter = entpos;
	return newent;
}

get_damageable_player_pos( player )
{
	return player.origin + ( 0, 0, 32 );
}

get_damageable_grenade_pos( grenade )
{
	return grenade.origin;
}

// this should be a code function.
getDvarVec( dvarName )
{
	dvarString = getDvar( dvarName );

	if ( dvarString == "" )
		return( 0, 0, 0 );

	dvarTokens = strTok( dvarString, " " );

	if ( dvarTokens.size < 3 )
		return( 0, 0, 0 );

	setDvar( "tempR", dvarTokens[ 0 ] );
	setDvar( "tempG", dvarTokens[ 1 ] );
	setDvar( "tempB", dvarTokens[ 2 ] );

	return( ( getDvarFloat( "tempR" ), getDvarFloat( "tempG" ), getDvarFloat( "tempB" ) ) );
}

strip_suffix( lookupString, stripString )
{
	if ( lookupString.size <= stripString.size )
		return lookupString;

	if ( getSubStr( lookupString, lookupString.size - stripString.size, lookupString.size ) == stripString )
		return getSubStr( lookupString, 0, lookupString.size - stripString.size );

	return lookupString;
}

_takeWeaponsExcept( saveWeapon )
{
	weaponsList = self GetWeaponsListAll();
	
	foreach ( weapon in weaponsList )
	{
		if ( weapon == saveWeapon )
		{
			continue;	
		}
		else
		{
			self takeWeapon( weapon );
		}
	}
}

saveData()
{
	saveData = spawnstruct();

	saveData.offhandClass = self getOffhandSecondaryClass();
	saveData.actionSlots = self.saved_actionSlotData;

	saveData.currentWeapon = self getCurrentWeapon();

	weaponsList = self GetWeaponsListAll();
	saveData.weapons = [];
	foreach ( weapon in weaponsList )
	{
		if ( weaponInventoryType( weapon ) == "exclusive" )
			continue;
			
		if ( weaponInventoryType( weapon ) == "altmode" )
			continue;

		saveWeapon = spawnStruct();
		saveWeapon.name = weapon;
		saveWeapon.clipAmmoR = self getWeaponAmmoClip( weapon, "right" );
		saveWeapon.clipAmmoL = self getWeaponAmmoClip( weapon, "left" );
		saveWeapon.stockAmmo = self getWeaponAmmoStock( weapon );		
		/* save camo? */
		
		if ( isDefined( self.throwingGrenade ) && self.throwingGrenade == weapon )
			saveWeapon.stockAmmo--;
		
		assert( saveWeapon.stockAmmo >= 0 );
		
		saveData.weapons[saveData.weapons.size] = saveWeapon;
	}
	
	self.script_saveData = saveData;
}


restoreData()
{
	saveData = self.script_saveData;

	self setOffhandSecondaryClass( saveData.offhandClass );

	foreach ( weapon in saveData.weapons )
	{		
		//if ( weapon.name == self.loadoutPrimary + "_mp" )
			self _giveWeapon( weapon.name, int(tableLookup( "mp/camoTable.csv", 1, self.loadoutPrimaryCamo, 0 )) );
		//else
		//self _giveWeapon( weapon.name );
			
		self setWeaponAmmoClip( weapon.name, weapon.clipAmmoR, "right" );
		if ( isSubStr( weapon.name, "akimbo" ) )
			self setWeaponAmmoClip( weapon.name, weapon.clipAmmoL, "left" );

		self setWeaponAmmoStock( weapon.name, weapon.stockAmmo );
	}

	foreach ( slotID, actionSlot in saveData.actionSlots )
		self _setActionSlot( slotID, actionSlot.type, actionSlot.item );

	if ( self getCurrentWeapon() == "none" )
	{
		weapon = saveData.currentWeapon;

		if ( weapon == "none" )
			weapon = self getLastWeapon();
		
		// Can remove this when "spawn" isn't used after final stand
		self setSpawnWeapon( weapon );
		self switchToWeapon( weapon );
	}
}


_setActionSlot( slotID, type, item )
{
	self.saved_actionSlotData[slotID].type = type;
	self.saved_actionSlotData[slotID].item = item;

	self setActionSlot( slotID, type, item );
}


isFloat( value )
{
	if ( int( value ) != value )
		return true;

	return false;
}

registerWatchDvarInt( nameString, defaultValue )
{
	dvarString = "scr_" + level._gameType + "_" + nameString;

	level._watchDvars[ dvarString ] = spawnStruct();
	level._watchDvars[ dvarString ].value = getDvarInt( dvarString, defaultValue );
	level._watchDvars[ dvarString ].type = "int";
	level._watchDvars[ dvarString ].notifyString = "update_" + nameString;
}


registerWatchDvarFloat( nameString, defaultValue )
{
	dvarString = "scr_" + level._gameType + "_" + nameString;

	level._watchDvars[ dvarString ] = spawnStruct();
	level._watchDvars[ dvarString ].value = getDvarFloat( dvarString, defaultValue );
	level._watchDvars[ dvarString ].type = "float";
	level._watchDvars[ dvarString ].notifyString = "update_" + nameString;
}


registerWatchDvar( nameString, defaultValue )
{
	dvarString = "scr_" + level._gameType + "_" + nameString;

	level._watchDvars[ dvarString ] = spawnStruct();
	level._watchDvars[ dvarString ].value = getDvar( dvarString, defaultValue );
	level._watchDvars[ dvarString ].type = "string";
	level._watchDvars[ dvarString ].notifyString = "update_" + nameString;
}


getWatchedDvar( dvarString )
{
	dvarString = "scr_" + level._gameType + "_" + dvarString;
	return( level._watchDvars[ dvarString ].value );
}


updateWatchedDvars()
{
	while ( game[ "state" ] == "playing" )
	{
		watchDvars = getArrayKeys( level._watchDvars );

		foreach ( dvarString in watchDvars )
		{
			if ( level._watchDvars[ dvarString ].type == "string" )
				dvarValue = getProperty( dvarString, level._watchDvars[ dvarString ].value );
			else if ( level._watchDvars[ dvarString ].type == "float" )
				dvarValue = getFloatProperty( dvarString, level._watchDvars[ dvarString ].value );
			else
				dvarValue = getIntProperty( dvarString, level._watchDvars[ dvarString ].value );

			if ( dvarValue != level._watchDvars[ dvarString ].value )
			{
				level._watchDvars[ dvarString ].value = dvarValue;
				level notify( level._watchDvars[ dvarString ].notifyString, dvarValue );
			}
		}

		wait( 1.0 );
	}
}


isRoundBased()
{
	if ( !level._teamBased )
		return false;

	if ( getWatchedDvar( "winlimit" ) != 1 && getWatchedDvar( "roundlimit" ) != 1 )
		return true;

	return false;
}


isLastRound()
{
	if ( !level._teamBased )
		return true;

	if ( getWatchedDvar( "roundlimit" ) > 1 && game[ "roundsPlayed" ] >= ( getWatchedDvar( "roundlimit" ) - 1 ) )
		return true;

	if ( getWatchedDvar( "winlimit" ) > 1 && game[ "roundsWon" ][ "allies" ] >= getWatchedDvar( "winlimit" ) - 1 && game[ "roundsWon" ][ "axis" ] >= getWatchedDvar( "winlimit" ) - 1 )
		return true;

	return false;
}


wasOnlyRound()
{
	if ( !level._teamBased )
		return true;

	if ( getWatchedDvar( "winlimit" ) == 1 && hitWinLimit() )
		return true;

	if ( getWatchedDvar( "roundlimit" ) == 1 )
		return true;

	return false;
}


wasLastRound()
{
	if ( level._forcedEnd )
		return true;

	if ( !level._teamBased )
		return true;

	if ( hitRoundLimit() || hitWinLimit() )
		return true;

	return false;
}


hitRoundLimit()
{
	if ( getWatchedDvar( "roundlimit" ) <= 0 )
		return false;

	return( game[ "roundsPlayed" ] >= getWatchedDvar( "roundlimit" ) );
}


hitScoreLimit()
{
	if ( isObjectiveBased()	 )
		return false;

	if ( getWatchedDvar( "scorelimit" ) <= 0 )
		return false;

	if ( level._teamBased )
	{
		if ( game[ "teamScores" ][ "allies" ] >= getWatchedDvar( "scorelimit" ) || game[ "teamScores" ][ "axis" ] >= getWatchedDvar( "scorelimit" ) )
			return true;
	}
	else
	{
		for ( i = 0; i < level._players.size; i++ )
		{
			player = level._players[ i ];
			if ( isDefined( player.score ) && player.score >= getWatchedDvar( "scorelimit" ) )
				return true;
		}
	}
	return false;
}


hitWinLimit()
{
	if ( getWatchedDvar( "winlimit" ) <= 0 )
		return false;

	if ( !level._teamBased )
		return true;

	if ( getRoundsWon( "allies" ) >= getWatchedDvar( "winlimit" ) || getRoundsWon( "axis" ) >= getWatchedDvar( "winlimit" ) )
		return true;

	return false;
}


getScoreLimit()
{
	if ( isRoundBased() )
	{
		if ( getWatchedDvar( "roundlimit" ) )
			return ( getWatchedDvar( "roundlimit" ) );			
		else
			return ( getWatchedDvar( "winlimit" ) );
	}
	else
	{
		return ( getWatchedDvar( "scorelimit" ) );
	}	
}


getRoundsWon( team )
{
	return game[ "roundsWon" ][ team ];
}


isObjectiveBased()
{
	return level._objectiveBased;
}


getTimeLimit()
{
	if ( inOvertime() && ( !isDefined(game[ "inNukeOvertime" ]) || !game[ "inNukeOvertime" ] ) )
	{
		timeLimit = int( getDvar( "overtimeTimeLimit" ) );
		
		if ( isDefined( timeLimit ) )
			return timeLimit;
		else
			return 1;
	}
	else if ( isDefined(level._dd) && level._dd && isDefined( level._bombexploded ) && level._bombexploded > 0 ) //to handle extra time added by dd bombs
	{
		return ( getWatchedDvar( "timelimit" ) + ( level._bombexploded * level._ddTimeToAdd ) );
	}
	else if ( isDefined(level._escortActiveCheckpointForTimer) && level._escortActiveCheckpointForTimer ) //to handle extra time added by checkpoints
	{
		return ( getWatchedDvar( "timelimit" ) + ( level._escortActiveCheckpointForTimer * getWatchedDvar( "checktime" ) ) + level._negativeTime );
	}
	else
	{
		return getWatchedDvar( "timelimit" );
	}
}


getHalfTime()
{
	if ( inOvertime() )
		return false;
	else if ( isDefined( game[ "inNukeOvertime" ] ) && game[ "inNukeOvertime" ] )
		return false;
	else
		return getWatchedDvar( "halftime" );
}


inOvertime()
{
	return ( isDefined( game["status"] ) && game["status"] == "overtime" );
}


gameHasStarted()
{
	if ( level._teamBased )
		return( level._hasSpawned[ "axis" ] && level._hasSpawned[ "allies" ] );
	else
		return( level._maxPlayerCount > 1 );
}


getAverageOrigin( ent_array )
{
	avg_origin = ( 0, 0, 0 );

	if ( !ent_array.size )
		return undefined;

	foreach ( ent in ent_array )
		avg_origin += ent.origin;

	avg_x = int( avg_origin[ 0 ] / ent_array.size );
	avg_y = int( avg_origin[ 1 ] / ent_array.size );
	avg_z = int( avg_origin[ 2 ] / ent_array.size );

	avg_origin = ( avg_x, avg_y, avg_z );

	return avg_origin;
}


getLivingPlayers( team )
{
	player_array = [];

	foreach ( player in level._players )
	{
		if ( !isAlive( player ) )
			continue;

		if ( level._teambased && isdefined( team ) )
		{
			if ( team == player.pers[ "team" ] )
				player_array[ player_array.size ] = player;
		}
		else
		{
			player_array[ player_array.size ] = player;
		}
	}

	return player_array;
}


setUsingRemote( remoteName )
{
	if ( isDefined( self.carryIcon) )
		self.carryIcon.alpha = 0;
	
	assert( !self isUsingRemote() );
	self.usingRemote = remoteName;

	self _disableOffhandWeapons();
	self notify( "using_remote" );
}

getRemoteName()
{
	assert( self isUsingRemote() );
	
	return self.usingRemote;	
}

freezeControlsWrapper( frozen )
{
	if ( isDefined( level._hostMigrationTimer ) )
	{
		self freezeControls( true );
		return;
	}
	
	self freezeControls( frozen );
}


clearUsingRemote()
{
	//if ( !isWeaponEnabled() )
	//	self disableWeapons();

	if ( isDefined( self.carryIcon) )
		self.carryIcon.alpha = 1;

	self.usingRemote = undefined;
	self _enableOffhandWeapons();
	
	curWeapon = self getCurrentWeapon();
	
	if( curWeapon == "none" || isKillstreakWeapon( curWeapon ) )
		self switchToWeapon( self Getlastweapon() );
	
	self freezeControlsWrapper( false );
	
	self notify( "stopped_using_remote" );
}


isUsingRemote()
{
	return( isDefined( self.usingRemote ) );
}


queueCreate( queueName )
{
	if ( !isDefined( level._queues ) )
		level._queues = [];

	assert( !isDefined( level._queues[ queueName ] ) );

	level._queues[ queueName ] = [];
}


queueAdd( queueName, entity )
{
	assert( isDefined( level._queues[ queueName ] ) );
	level._queues[ queueName ][ level._queues[ queueName ].size ] = entity;
}


queueRemoveFirst( queueName )
{
	assert( isDefined( level._queues[ queueName ] ) );

	first = undefined;
	newQueue = [];
	foreach ( element in level._queues[ queueName ] )
	{
		if ( !isDefined( element ) )
			continue;

		if ( !isDefined( first ) )
			first = element;
		else
			newQueue[ newQueue.size ] = element;
	}

	level._queues[ queueName ] = newQueue;

	return first;
}


_giveWeapon( weapon, variant, dualWieldOverRide )
{
	if ( !isDefined(variant) )
		variant = 0;
	
	if ( isSubstr( weapon, "_akimbo" ) || isDefined(dualWieldOverRide) && dualWieldOverRide == true)
		self giveWeapon(weapon, variant, true);
	else
		self giveWeapon(weapon, variant, false);
}

_hasPerk( perkName )
{
	if ( isDefined( self.perks[perkName] ) )
		return true;
	
	return false;
}

_hasRechargeablePerk( perkName )
{
	if ( isDefined( self.rechargeablePerks[perkName] ) )
		return true;
	
	return false;
}

_setPerk( perkName, slotOverride )
{	
	if( _hasPerk( perkName ))
		return;
	
	self.perks[perkName] = true;

	if ( isDefined( level._perkSetFuncs[perkName] ) )
		self thread [[level._perkSetFuncs[perkName]]]();
	
	if( isDefined( slotOverride ))
	{
		assert( slotOverride == "rperk1" || slotOverride == "rperk2" || slotOverride == "rperk3" || slotOverride == "rperk4" );		
		self.rechargeablePerks[perkName] = true;
		self setPerk( perkName, !isDefined( level._scriptPerks[perkName] ), slotOverride );
	}
	else
	{
		self setPerk( perkName, !isDefined( level._scriptPerks[perkName] ));
	}
}


_unsetPerk( perkName, slotOverride )
{
	self.perks[perkName] = undefined;

	if ( isDefined( level._perkUnsetFuncs[perkName] ) )
		self thread [[level._perkUnsetFuncs[perkName]]]();
	
	if( isDefined( slotOverride ))
	{
		assert( slotOverride == "rperk1" || slotOverride == "rperk2" || slotOverride == "rperk3" || slotOverride == "rperk4" );
		if( isDefined( self.rechargeablePerks[perkName] ))
		{
			self.rechargeablePerks[perkName] = undefined;
			self unsetPerk( perkName, !isDefined( level._scriptPerks[perkName] ), slotOverride );
		}
	}
	else
	{
		self unsetPerk( perkName, !isDefined( level._scriptPerks[perkName] ) );
	}
}


_clearPerks()
{
	foreach ( perkName, perkValue in self.perks )
	{
		if ( isDefined( level._perkUnsetFuncs[perkName] ) )
			self [[level._perkUnsetFuncs[perkName]]]();
	}
	
	self.perks = [];
	self.rechargeablePerks = [];
	self._networkedPerks = [];
	self clearPerks();
}

// Quick Sort - pass it an array it will come back sorted
quickSort(array) 
{
	return quickSortMid(array, 0, array.size -1 );     
}

quickSortMid(array, start, end)
{
	i = start;
	k = end;

	if (end - start >= 1)
    {
        pivot = array[start];  

        while (k > i)         
        {
	        while (array[i] <= pivot && i <= end && k > i)  
	        	i++;                                 
	        while (array[k] > pivot && k >= start && k >= i) 
	            k--;                                      
	        if (k > i)                                 
	           array = swap(array, i, k);                    
        }
        array = swap(array, start, k);                                               
        array = quickSortMid(array, start, k - 1); 
        array = quickSortMid(array, k + 1, end);   
    }
	else
    	return array;
    
    return array;
}

swap(array, index1, index2) 
{
	temp = array[index1];          
	array[index1] = array[index2];     
	array[index2] = temp;   
	return array;         
}

_suicide()
{
	if ( self isUsingRemote() && !isDefined( self.fauxDead ) )
		self thread maps\mp\gametypes\_damage::PlayerKilled_internal( self, self, self, 10000, "MOD_SUICIDE", "frag_grenade_mp", (0,0,0), "none", 0, 1116, true );
	else if( !self isUsingRemote() && !isDefined( self.fauxDead ) )
		self suicide();	
}

isReallyAlive( player )
{
	if ( isAlive( player ) && !isDefined( player.fauxDead ) )
		return true;
		
	return false;
}

playDeathSound()
{
	rand = RandomIntRange( 1,8 );
	
	if ( self.team == "axis" )
		self PlaySound( "generic_death_russian_"+ rand );	
	else
		self PlaySound( "generic_death_american_"+ rand );
	
}


rankingEnabled()
{
	assert( isPlayer( self ) );
	return ( level._rankedMatch && !self.usingOnlineDataOffline );
}

// only true for private match
privateMatch()
{
	return ( level._onlineGame && getDvarInt( "xblive_privatematch" ) );
}

// only true for playlist based LIVE and PSN games
matchMakingGame()
{
	return ( level._onlineGame && !getDvarInt( "xblive_privatematch" ) );
}

setAltSceneObj( object, tagName, fov, forceLink )
{
	/*
	if ( !isDefined( forceLink ) )
		forceLink = false;

	if ( !getDvarInt( "scr_pipmode" ) && !forceLink )
		return;
	
	self endon ( "disconnect" );

	if ( !isReallyAlive( self ) )
		return;

	if ( !forceLink && isDefined( self.altSceneObject ) )
		return;

	self notify ( "altscene" );
	
	self.altSceneObject = object;

	self AlternateSceneCameraLinkTo( object, tagName, fov );
	self setClientDvar( "ui_altscene", 1 );
	
	self thread endSceneOnDeath( object );
	self thread endSceneOnDeath( self );
	
	self waittill ( "end_altScene" );
	
	self.altSceneObject = undefined;
	self AlternateSceneCameraUnlink();
	
	if ( !forceLink )
	{
		self setClientDvar( "ui_altscene", 2 );
	
		self endon ( "altscene" );
		wait ( 2.0 );
	}
	self setClientDvar( "ui_altscene", 0 );	
	*/
}


endSceneOnDeath( object )
{
	self endon ( "altscene" );
	
	object waittill ( "death" );
	self notify ( "end_altScene" );
}


getGametypeNumLives()
{
	//commented out to allow diehardhard rules to support mulitiple life gametypes
	//if ( level.dieHardMode && !getWatchedDvar( "numlives" ) )
	//	return 1;
	//else
		return getWatchedDvar( "numlives" );
}


registerAdrenalineInfo( type, value )
{
	if ( !isDefined( level._adrenalineInfo ) )
		level._adrenalineInfo = [];
		
	level._adrenalineInfo[type] = value;
}


giveAdrenaline( type )
{	
	/*
	if ( self.adrenaline >= 1000 )
		return;

	assertEx( isDefined( level.adrenalineInfo[type] ), "Unknown adrenaline type: " + type );

	printLn( "setting: " + type + " " + level.adrenalineInfo[type] );

	self setAdrenaline( self.adrenaline + level.adrenalineInfo[type] );
	
	if ( self.adrenaline == 1000 )
	{

		giveCombatHigh( "specialty_endgame" );
	}
	*/
}


setAdrenaline( value )
{
	self.adrenaline = min( value, 1000 );
	self setClientDvar( "ui_adrenaline", self.adrenaline );
	
	if ( self.adrenaline < 1000 )
		self.combatHigh = undefined;
}


giveCombatHigh( combatHighName )
{
	self.combatHigh = combatHighName;
}


arrayInsertion( array, item, index )
{
	if ( array.size != 0 )
	{
		for ( i = array.size; i >= index; i-- )
		{
			array[i+1] = array[i];
		}
	}
	
	array[index] = item;
}


getProperty( dvar, defValue )
{
	value = defValue;
	/#
	setDevDvarIfUninitialized( dvar, defValue );
	#/

	value = getDvar( dvar, defValue );
	return value;
}


getIntProperty( dvar, defValue )
{
	value = defValue;

	/#
	setDevDvarIfUninitialized( dvar, defValue );
	#/

	value = getDvarInt( dvar, defValue );
	return value;
}


getFloatProperty( dvar, defValue )
{
	value = defValue;
	/#
	setDevDvarIfUninitialized( dvar, defValue );
	#/

	value = getDvarFloat( dvar, defValue );
	return value;
}



statusMenu( duration )
{
	self endon ( "disconnect" );
	
	if ( !isDefined( self._statusMenu ) )
		self.statusMenu = false;
		
	if ( self.statusMenu )
		return;

	self.statusMenu = true;

	self openpopupMenu( "status_update" );
	
	wait ( duration );

	self closepopupMenu( "status_update" );

	// debounce
	wait ( 10.0 );
	
	self.statusMenu = false;	
}

isChangingWeapon()
{
	return ( isDefined( self.changingWeapon ) );
}

isKillstreakWeapon( weapon )
{
	if ( weapon == "none" )
		return false;
	
	if ( weaponInventoryType( weapon ) == "exclusive" && weapon != "destructible_car" )
		return true;
	
	if ( isSubStr( weapon, "killstreak" ) )
		return true;
	
	if ( isDefined( level._killstreakWeapons[weapon] ) && level._killstreakWeapons[weapon] == true )
	{
		return true;
	}
	else
	{
		return false;
	}	
}


getWeaponClass( weapon )
{
	tokens = strTok( weapon, "_" );

	weaponClass = tablelookup( "mp/statstable.csv", 4, tokens[0], 2 );
	
	// handle special case weapons like grenades, airdrop markers, etc...
	if ( weaponClass == "" )
	{
		weaponName = strip_suffix( weapon, "_mp" );
		weaponClass = tablelookup( "mp/statstable.csv", 4, weaponName, 2 );
	}
	
	if ( isMG( weapon ) )
		weaponClass = "weapon_mg";
	else if ( isKillstreakWeapon( weapon ) )
		weaponClass = "killstreak"; 
	else if ( isDeathStreakWeapon( weapon ) )
		weaponClass = "deathstreak";
	else if ( weapon == "none" ) //airdrop crates
		weaponClass = "other";
	else if ( weaponClass == "" )
		weaponClass = "other";
	
	assertEx( weaponClass != "", "ERROR: invalid weapon class for weapon " + weapon );
	
	return weaponClass;
}

isDeathStreakWeapon( weapon )
{
	if( weapon == "c4death_mp" || weapon == "frag_grenade_short_mp" )
		return true;
	else
		return false;
}

getBaseWeaponName( weaponName )
{
	tokens = strTok( weaponName, "_" );
	return tokens[0];
}

playSoundinSpace( alias, origin )
{
	playSoundAtPos( origin, alias );
}

limitDecimalPlaces( value, places )
{
	modifier = 1;
	for ( i = 0; i < places; i++ )
		modifier *= 10;
	
	newvalue = value * modifier;
	newvalue = Int( newvalue );
	newvalue = newvalue / modifier;
	
	return newvalue;
}

roundDecimalPlaces( value, places, style )
{
	if ( !isdefined( style ) )
		style = "nearest";
	
	modifier = 1;
	for ( i = 0; i < places; i++ )
		modifier *= 10;
	
	newValue = value * modifier;
	
	if ( style == "up" )
		roundedValue = ceil( newValue );
	else if ( style == "down" )
		roundedValue = floor( newValue ); 	
	else
		roundedValue = newvalue + 0.5;	
		
	newvalue = Int( roundedValue );
	newvalue = newvalue / modifier;
	
	return newvalue;
}

playerForClientId( clientId )
{
	foreach ( player in level._players )
	{
		if ( player.clientId == clientId )
			return player;
	}
	
	return undefined;
}

isRested()
{
	if ( !self rankingEnabled() )
		return false;
		
	return ( self getPlayerData( "restXPGoal" ) > self getPlayerData( "experience" ) );
}

stringToFloat( stringVal )
{
	floatElements = strtok( stringVal, "." );
	
	floatVal = int( floatElements[0] );
	if ( isDefined( floatElements[1] ) )
	{
		modifier = 1;
		for ( i = 0; i < floatElements[1].size; i++ )
			modifier *= 0.1;
		
		floatVal += int ( floatElements[1] ) * modifier;
	}
	
	return floatVal;	
}

setSelfUsable(caller)
{
	self makeUsable();
	
	foreach (player in level._players)
	{
		if (player != caller )
			self disablePlayerUse( player );
		else
			self enablePlayerUse( player );
	}
}

makeTeamUsable( team )
{
	self makeUsable();
	self thread _updateTeamUsable( team );
}

_updateTeamUsable( team )
{
	self endon ( "death" );
	
	for ( ;; )
	{
		foreach (player in level._players)
		{
			if ( player.team == team )
				self enablePlayerUse( player );	
			else
				self disablePlayerUse( player );	
		}	

		level waittill ( "joined_team" );		
	}
}

// More general version of makeTeamUsable() which handles FFA
makeEnemyUsable( owner )
{
	self makeUsable();
	self thread _updateEnemyUsable( owner );
}

// Only used for Tactical Insertion for now
// If used for other things, handle owner disappearing or changing team
_updateEnemyUsable( owner )
{
	// check what happens if the owner leaves

	self endon ( "death" );

	team = owner.team;

	for ( ;; )
	{
		if ( level._teambased )
		{
			foreach (player in level._players)
			{
				if ( player.team != team )
					self enablePlayerUse( player );	
				else
					self disablePlayerUse( player );	
			}
		}
		else
		{
			foreach (player in level._players)
			{
				if ( player != owner )
					self enablePlayerUse( player );	
				else
					self disablePlayerUse( player );	
			}
		}

		level waittill ( "joined_team" );		
	}
}

getNextLifeId()
{
	lifeId = getMatchData( "lifeCount" );
	if ( lifeId < level._MaxLives )
		setMatchData( "lifeCount", lifeId+1 );
		
	return ( lifeId );
}

initGameFlags()
{
	if ( !isDefined( game["flags"] ) )
		game["flags"] = [];
}

gameFlagInit( flagName, isEnabled )
{
	assert( isDefined( game["flags"] ) );
	game["flags"][flagName] = isEnabled;
}

gameFlag( flagName )
{
	assertEx( isDefined( game["flags"][flagName] ), "gameFlag " + flagName + " referenced without being initialized; usegameFlagInit( <flagName>, <isEnabled> )" );
	return ( game["flags"][flagName] );
}

gameFlagSet( flagName )
{
	assertEx( isDefined( game["flags"][flagName] ), "gameFlag " + flagName + " referenced without being initialized; usegameFlagInit( <flagName>, <isEnabled> )" );
	game["flags"][flagName] = true;

	level notify ( flagName );
}

gameFlagClear( flagName )
{
	assertEx( isDefined( game["flags"][flagName] ), "gameFlag " + flagName + " referenced without being initialized; usegameFlagInit( <flagName>, <isEnabled> )" );
	game["flags"][flagName] = false;
}

gameFlagWait( flagName )
{
	assertEx( isDefined( game["flags"][flagName] ), "gameFlag " + flagName + " referenced without being initialized; usegameFlagInit( <flagName>, <isEnabled> )" );
	while ( !gameFlag( flagName ) )
		level waittill ( flagName );
}

// including grenade launcher, grenade, RPG, C4, claymore
isExplosiveDamage( meansofdeath )
{
	explosivedamage = "MOD_GRENADE MOD_GRENADE_SPLASH MOD_PROJECTILE MOD_PROJECTILE_SPLASH MOD_EXPLOSIVE mod_explosive";
	if( isSubstr( explosivedamage, meansofdeath ) )
		return true;
	return false;
}

// if primary weapon damage
isPrimaryDamage( meansofdeath )
{
	// including pistols as well since sometimes they share ammo
	if( meansofdeath == "MOD_RIFLE_BULLET" || meansofdeath == "MOD_PISTOL_BULLET" || meansofdeath == "MOD_EXPLOSIVE_BULLET" )
		return true;
	return false;
}


initLevelFlags()
{
	if ( !isDefined( level._levelFlags ) )
		level._levelFlags = [];
}

levelFlagInit( flagName, isEnabled )
{
	assert( isDefined( level._levelFlags ) );
	level._levelFlags[flagName] = isEnabled;
}

levelFlag( flagName )
{
	assertEx( isDefined( level._levelFlags[flagName] ), "levelFlag " + flagName + " referenced without being initialized; use levelFlagInit( <flagName>, <isEnabled> )" );
	return ( level._levelFlags[flagName] );
}

levelFlagSet( flagName )
{
	assertEx( isDefined( level._levelFlags[flagName] ), "levelFlag " + flagName + " referenced without being initialized; use levelFlagInit( <flagName>, <isEnabled> )" );
	level._levelFlags[flagName] = true;

	level notify ( flagName );
}

levelFlagClear( flagName )
{
	assertEx( isDefined( level._levelFlags[flagName] ), "levelFlag " + flagName + " referenced without being initialized; use levelFlagInit( <flagName>, <isEnabled> )" );
	level._levelFlags[flagName] = false;

	level notify ( flagName );
}

levelFlagWait( flagName )
{
	assertEx( isDefined( level._levelFlags[flagName] ), "levelFlag " + flagName + " referenced without being initialized; use levelFlagInit( <flagName>, <isEnabled> )" );
	while ( !levelFlag( flagName ) )
		level waittill ( flagName );
}

levelFlagWaitOpen( flagName )
{
	assertEx( isDefined( level._levelFlags[flagName] ), "levelFlag " + flagName + " referenced without being initialized; use levelFlagInit( <flagName>, <isEnabled> )" );
	while ( levelFlag( flagName ) )
		level waittill ( flagName );
}

getWeaponAttachments( weapon ) 
{
	tokenizedWeapon = strTok( weapon, "_" );
	attachmentArray = [];
	
	if( tokenizedWeapon.size < 3 || tokenizedWeapon[1] == "_mp" )
	{
		attachmentArray[0] = "none";
	}
	else if( tokenizedWeapon.size > 3 )
	{
		attachmentArray[0] = tokenizedWeapon[1];
		attachmentArray[1] = tokenizedWeapon[2];
	}	
	else 		
	{
		attachmentArray[0] = tokenizedWeapon[1];
	}
	
	return attachmentArray;
}

isEMPed()
{
	if ( self.team == "spectator" )
		return false;
		
    if ( level._teamBased )
    	return ( level._teamEMPed[self.team] );
    else
    	return ( isDefined( level._empPlayer ) && level._empPlayer != self );
}

isNuked()
{
	if ( self.team == "spectator" )
		return false;
		
    return ( isDefined( self.nuked ) );
}

isBulletDamage( meansofdeath )
{
	bulletDamage = "MOD_RIFLE_BULLET MOD_PISTOL_BULLET MOD_HEADSHOT";
	if( isSubstr( bulletDamage, meansofdeath ) )
		return true;
	return false;
}


getPlayerForGuid( guid )
{
	foreach ( player in level._players )
	{
		if ( player.guid == guid )
			return player;
	}
	
	return undefined;
}

teamPlayerCardSplash( splash, owner, team )
{
	if ( level._hardCoreMode )
		return;
		
	foreach ( player in level._players )
	{
		if ( isDefined( team ) && player.team != team )
			continue;
			
		player thread maps\mp\gametypes\_hud_message::playerCardSplashNotify( splash, owner );
	}
}
	

isCACPrimaryWeapon( weapName )
{
	switch ( getWeaponClass( weapName ) )
	{
		case "weapon_smg":
		case "weapon_assault":
		case "weapon_riot":
		case "weapon_sniper":
		case "weapon_lmg":
		case "weapon_new":
			return true;
		default:
			return false;
	}
}


isCACSecondaryWeapon( weapName )
{
	switch ( getWeaponClass( weapName ) )
	{
		case "weapon_projectile":
		case "weapon_pistol":
		case "weapon_machine_pistol":
		case "weapon_shotgun":
		case "weapon_sec_new":
			return true;
		default:
			return false;
	}
}


getLastLivingPlayer( team )
{
	livePlayer = undefined;

	foreach ( player in level._players )
	{
		if ( isDefined( team ) && player.team != team )
			continue;

		if ( !isReallyAlive( player ) && !player maps\mp\gametypes\_playerlogic::maySpawn() )
			continue;
		
		assertEx( !isDefined( livePlayer ), "getLastLivingPlayer() found more than one live player on team." );
		
		livePlayer = player;				
	}

	return livePlayer;
}


getPotentialLivingPlayers()
{
	livePlayers = [];

	foreach ( player in level._players )
	{
		if ( !isReallyAlive( player ) && !player maps\mp\gametypes\_playerlogic::maySpawn() )
			continue;
		
		livePlayers[livePlayers.size] = player;
	}

	return livePlayers;
}


waitTillRecoveredHealth( time, interval )
{
	self endon("death");
	self endon("disconnect");

	fullHealthTime = 0;
	
	if( !isDefined( interval ) )
		interval = .05;

	if( !isDefined( time ) )
		time = 0;
	
	while(1)
	{
		if ( self.health != self.maxhealth )
			fullHealthTime = 0;
		else
			fullHealthTime += interval;
		
		wait interval;
		
		if ( self.health == self.maxhealth && fullHealthTime >= time )
			break;
	}

	return;
}

_objective_delete( objID )
{
	objective_delete( objID);
	
	if ( !isDefined( level._reclaimedReservedObjectives ) ) 
	{
		level._reclaimedReservedObjectives = [];
		level._reclaimedReservedObjectives[0] = objID;
	}
	else
	{
		level._reclaimedReservedObjectives[ level._reclaimedReservedObjectives.size ] = objID;		
	}
}


touchingBadTrigger()
{
	killTriggers = getEntArray( "trigger_hurt", "classname" );	
	foreach ( trigger in killTriggers )
	{
		if ( self isTouching( trigger ) )
			return true;
	}

	radTriggers = getEntArray( "radiation", "targetname" );	
	foreach ( trigger in radTriggers )
	{
		if ( self isTouching( trigger ) )
			return true;
	}
	
	return false;
}
	
setThirdPersonDOF( isEnabled )
{
	if ( isEnabled )
		self setDepthOfField( 0, 110, 512, 4096, 6, 1.8 );
	else
		self setDepthOfField( 0, 0, 512, 512, 4, 0 );
}



killTrigger( pos, radius, height )
{
	trig = spawn( "trigger_radius", pos, 0, radius, height );
	
	/#
	if ( getdvar( "scr_killtriggerdebug" ) == "1" )
		thread killTriggerDebug( pos, radius, height );
	#/
	
	for ( ;; )
	{
		/#
		if ( getdvar( "scr_killtriggerradius" ) != "" )
			radius = int(getdvar( "scr_killtriggerradius" ));
		#/
		
		trig waittill( "trigger", player );
		
		if ( !isPlayer( player ) )
			continue;
		
		player suicide();
	}
}

/*setRecoilScale sets a relative recoil scaler 
  if you pass 20 it will be a 20% reduction in recoil 
  passing it no values will reset scale override to whatever
  value already exists in self.recoilScale or no override.
*/
setRecoilScale( scaler, scaleOverride )
{	
	if ( !isDefined( scaler ) )
		scaler = 0;
	
	if ( !isDefined( self.recoilScale ) )
		self.recoilScale = scaler;
	else
		self.recoilScale += scaler;
	
	//for scale override
	if ( isDefined( scaleOverride ) )
	{		
		//will not override a lower value.
		if ( isDefined( self.recoilScale) && scaleOverride < self.recoilScale )
			scaleOverride = self.recoilScale;	
		
		scale = 100 - scaleOverride;
	}
	else
		scale = 100 - self.recoilScale;
	
	if ( scale < 0 )
		scale = 0;
	
	if ( scale > 100 )
		scale = 100;	
	
	if ( scale == 100 )
	{
		self player_recoilScaleOff();
		return;
	}
	
	self player_recoilScaleOn( scale );
}

/#
killTriggerDebug( pos, radius, height )
{
	for ( ;; )
	{
		for ( i = 0; i < 20; i++ )
		{
			angle = i / 20 * 360;
			nextangle = (i+1) / 20 * 360;
			
			linepos = pos + (cos(angle) * radius, sin(angle) * radius, 0);
			nextlinepos = pos + (cos(nextangle) * radius, sin(nextangle) * radius, 0);
			
			line( linepos, nextlinepos );
			line( linepos + (0,0,height), nextlinepos + (0,0,height) );
			line( linepos, linepos + (0,0,height) );
		}
		wait .05;
	}
}
#/