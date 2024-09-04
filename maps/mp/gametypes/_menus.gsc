#include maps\mp\_utility;

init()
{
	if ( !isDefined( game["gamestarted"] ) )
	{
		game["menu_team"] = "team_marinesopfor";
		
		if( level._multiTeamBased )
		{
			game["menu_team"] = "team_mtdm_options";
		}
		
		game["menu_class_allies"] = "class_marines";
		game["menu_changeclass_allies"] = "changeclass_marines";
		game["menu_initteam_allies"] = "initteam_marines";
		game["menu_class_axis"] = "class_opfor";
		game["menu_changeclass_axis"] = "changeclass_opfor";
		game["menu_initteam_axis"] = "initteam_opfor";
		game["menu_class"] = "class";
		game["menu_changeclass"] = "changeclass";
		game["menu_onemanarmy"] = "onemanarmy";
		game["menu_exosuit"] = "exosuit";
		
		if( level._multiTeamBased )
		{
			for( i = 0; i < level._teamNameList.size; i++ )
			{
				str_menu_class = "menu_class_" + level._teamNameList[i];
				str_menu_changeclass = "menu_changeclass_" + level._teamNameList[i];
				str_menu_initteam = "menu_initteam_" + level._teamNameList[i];
				game[str_menu_class] = "class_marines";
				game[str_menu_changeclass] = "changeclass_marines";
				game[str_menu_initteam] = "initteam_marines";
			}
		}
	
		if ( !level._console )
		{
			game["menu_callvote"] = "callvote";
			game["menu_muteplayer"] = "muteplayer";
			precacheMenu(game["menu_callvote"]);
			precacheMenu(game["menu_muteplayer"]);			
		}
		else
		{
			game["menu_controls"] = "ingame_controls";
			//game["menu_options"] = "ingame_options";
			game["menu_leavegame"] = "popup_leavegame";
	
			if(level._splitscreen)
			{
				if( level._multiTeamBased )
				{
					for( i = 0; i < level._teamNameList.size; i++ )
					{
						str_menu_class = "menu_class_" + level._teamNameList[i];
						str_menu_changeclass = "menu_changeclass_" + level._teamNameList[i];
						game[str_menu_class] += "_splitscreen";
						game[str_menu_changeclass] += "_splitscreen";
					}
				}
				
				game["menu_team"] += "_splitscreen";
				game["menu_class_allies"] += "_splitscreen";
				game["menu_changeclass_allies"] += "_splitscreen";
				game["menu_class_axis"] += "_splitscreen";
				game["menu_changeclass_axis"] += "_splitscreen";
				game["menu_class"] += "_splitscreen";
				game["menu_controls"] += "_splitscreen";
				//game["menu_options"] += "_splitscreen";
				game["menu_leavegame"] += "_splitscreen";
				game["menu_onemanarmy"] += "_splitscreen";

				game["menu_changeclass_defaults_splitscreen"] = "changeclass_defaults_splitscreen";
				game["menu_changeclass_custom_splitscreen"] = "changeclass_custom_splitscreen";
				game["menu_onemanarmy_defaults_splitscreen"] = "onemanarmy_defaults_splitscreen";
				game["menu_onemanarmy_custom_splitscreen"] = "onemanarmy_custom_splitscreen";
				
				precacheMenu(game["menu_changeclass_defaults_splitscreen"]);
				precacheMenu(game["menu_changeclass_custom_splitscreen"]);
				precacheMenu(game["menu_onemanarmy_defaults_splitscreen"]);
				precacheMenu(game["menu_onemanarmy_custom_splitscreen"]);
			}
	
			precacheMenu(game["menu_controls"]);
			//precacheMenu(game["menu_options"]);
			precacheMenu(game["menu_leavegame"]);
			
			//precacheMenu("status_update");
		}
	
		precacheMenu("scoreboard");
		precacheMenu(game["menu_team"]);
		precacheMenu(game["menu_class_allies"]);
		precacheMenu(game["menu_changeclass_allies"]);
		precacheMenu(game["menu_initteam_allies"]);
		precacheMenu(game["menu_class_axis"]);
		precacheMenu(game["menu_changeclass_axis"]);
		precacheMenu(game["menu_class"]);
		precacheMenu(game["menu_changeclass"]);
		precacheMenu(game["menu_initteam_axis"]);
		precacheMenu(game["menu_onemanarmy"]);
		precacheMenu(game["menu_exosuit"]);
		
		precacheString( &"MP_HOST_ENDED_GAME" );
		precacheString( &"MP_HOST_ENDGAME_RESPONSE" );
	}

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);

		player thread onMenuResponse();
	}
}

onMenuResponse()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("menuresponse", menu, response);
		
		if ( response == "back" )
		{
			self closepopupMenu();
			self closeInGameMenu();

			if ( level._console )
			{
				if ( menu == game["menu_changeclass"] ||
				     menu == game["menu_team"] ||
					 menu == game["menu_controls"] ||
					 ( isDefined( game["menu_changeclass_defaults_splitscreen"] ) && menu == game["menu_changeclass_defaults_splitscreen"] ) ||
					 ( isDefined( game["menu_changeclass_custom_splitscreen"] ) && menu == game["menu_changeclass_custom_splitscreen"] ) )
				{
					if( self.pers["team"] == "allies" )
						self openpopupMenu( game["menu_class_allies"] );
					if( self.pers["team"] == "axis" )
						self openpopupMenu( game["menu_class_axis"] );
				}
			}
			continue;
		}
		
		if(response == "changeteam")
		{
			self closepopupMenu();
			self closeInGameMenu();
			self openpopupMenu(game["menu_team"]);
		}
	
		if(response == "changeclass_marines" )
		{
			self closepopupMenu();
			self closeInGameMenu();
			self openpopupMenu( game["menu_changeclass_allies"] );
			continue;
		}

		if(response == "changeclass_opfor" )
		{
			self closepopupMenu();
			self closeInGameMenu();
			self openpopupMenu( game["menu_changeclass_axis"] );
			continue;
		}

		if(response == "changeclass_marines_splitscreen" )
			self openpopupMenu( "changeclass_marines_splitscreen" );

		if(response == "changeclass_opfor_splitscreen" )
			self openpopupMenu( "changeclass_opfor_splitscreen" );
		
		if(response == "endgame")
		{
			if(level._splitscreen)
			{
				endparty();

				if ( !level._gameEnded )
				{
					level thread maps\mp\gametypes\_gamelogic::forceEnd();
				}
			}
				
			continue;
		}

		if ( response == "endround" )
		{
			if ( !level._gameEnded )
			{
				level thread maps\mp\gametypes\_gamelogic::forceEnd();
			}
			else
			{
				self closepopupMenu();
				self closeInGameMenu();
				self iprintln( &"MP_HOST_ENDGAME_RESPONSE" );
			}			
			continue;
		}

		if ( menu == game["menu_team"] )
		{
			switch( response )
			{			
			case "autoassign":
				self [[level._autoassign]]();
				break;

			case "spectator":
				self [[level._spectator]]();
				break;
			
			default:
				self [[level._onTeamSelection]]( response );
			}
		}	// the only responses remain are change class events
		else if ( menu == game["menu_changeclass"] ||
				( isDefined( game["menu_changeclass_defaults_splitscreen"] ) && menu == game["menu_changeclass_defaults_splitscreen"] ) ||
				( isDefined( game["menu_changeclass_custom_splitscreen"] ) && menu == game["menu_changeclass_custom_splitscreen"] ) )
		{
			self closepopupMenu();
			self closeInGameMenu();

			self.selectedClass = true;
			self [[level._class]](response);
		}
		else if ( !level._console )
		{
			if(menu == game["menu_quickcommands"])
				maps\mp\gametypes\_quickmessages::quickcommands(response);
			else if(menu == game["menu_quickstatements"])
				maps\mp\gametypes\_quickmessages::quickstatements(response);
			else if(menu == game["menu_quickresponses"])
				maps\mp\gametypes\_quickmessages::quickresponses(response);
		}
	}
}

onMenuTeamSelect( selection )
{
	self closeMenus();
	
	if(self.pers["team"] != selection)
	{
		if( level._teamBased && !maps\mp\gametypes\_teams::getJoinTeamPermissions( selection ) )
		{
			self openpopupMenu(game["menu_team"]);
			return;
		}
		
		// allow respawn when switching teams during grace period.
		if ( level._inGracePeriod && !self.hasDoneCombat )
			self.hasSpawned = false;
			
		if(self.sessionstate == "playing")
		{
			self.switching_teams = true;
			self.joining_team = selection;
			self.leaving_team = self.pers["team"];
			self suicide();
		}
		
		self addToTeam( selection );
		self.pers["class"] = undefined;
		self.class = undefined;

		self notify("end_respawn");
	}
	
	self beginClassChoice();
}

getTeamAssignment()
{
	teams[0] = "allies";
	teams[1] = "axis";
	
	if ( !level._teamBased )
		return teams[randomInt(2)];

	//If sessionteam is already set, it is probably because you are in a matchmaking game
	if ( self.sessionteam != "none" && self.sessionteam != "spectator" && self.sessionstate != "playing" && self.sessionstate != "dead" )
	{
		assignment = self.sessionteam;
	}
	else if( level._multiTeamBased )
	{	
		/#
		println( "" );
		println( "SETTING TEAM ASSIGNMENT" );
		println( "max num teams = " + level._teamNameList.size );
		#/
		
		numTeams = level._teamNameList.size;
		
		//scan for smallest team, assign new player to that team
		teamAssignment = level._teamNameList[0];
		for( i = 0; i < level._teamNameList.size; i++ )
		{
			/#
			println( level._teamNameList[i] + " has " + level._teamCount[level._teamNameList[i]] + " players on it." );
			#/
			
			if ( level._teamCount[level._teamNameList[i]] < level._teamCount[teamAssignment] )
			{
				teamAssignment = level._teamNameList[i];
			}
		}
		
		/#
		println( "Team assignment = " + teamAssignment );
		println( "" );
		#/
		
		return teamAssignment;
	}
	else
	{
		playerCounts = self maps\mp\gametypes\_teams::CountPlayers();
				
		// if teams are equal return the team with the lowest score
		if ( playerCounts["allies"] == playerCounts["axis"] )
		{
			if( getTeamScore( "allies" ) == getTeamScore( "axis" ) )
				assignment = teams[randomInt(2)];
			else if ( getTeamScore( "allies" ) < getTeamScore( "axis" ) )
				assignment = "allies";
			else
				assignment = "axis";
		}
		else if( playerCounts["allies"] < playerCounts["axis"] )
		{
			assignment = "allies";
		}
		else
		{
			assignment = "axis";
		}
	}
	
	return assignment;
}


menuAutoAssign()
{
	self closeMenus();

	assignment = getTeamAssignment();
		
	if ( isDefined( self.pers["team"] ) && (self.sessionstate == "playing" || self.sessionstate == "dead") )
	{
		if ( assignment == self.pers["team"] )
		{
			self beginClassChoice();
			return;
		}
		else
		{
			self.switching_teams = true;
			self.joining_team = assignment;
			self.leaving_team = self.pers["team"];
			self suicide();
		}
	}

	self addToTeam( assignment );
	self.pers["class"] = undefined;
	self.class = undefined;
	
	if ( !isAlive( self ) )
		self.statusicon = "hud_status_dead";
	
	self notify("end_respawn");
	
	self beginClassChoice();
}


beginClassChoice( forceNewChoice )
{
	if( !level._multiTeamBased )
	{
		assert( self.pers["team"] == "axis" || self.pers["team"] == "allies" );
	}
	
	team = self.pers["team"];

	// menu_changeclass_team is the one where you choose one of the n classes to play as.
	// menu_class_team is where you can choose to change your team, class, controls, or leave game.
	self openpopupMenu( game[ "menu_changeclass_" + team ] );
	
	if ( !isAlive( self ) )
		self thread maps\mp\gametypes\_playerlogic::predictAboutToSpawnPlayerOverTime( 0.1 );
}


beginTeamChoice()
{
	self openpopupMenu( game["menu_team"] );
}


showMainMenuForTeam()
{
	assert( self.pers["team"] == "axis" || self.pers["team"] == "allies" );
	
	team = self.pers["team"];
	
	// menu_changeclass_team is the one where you choose one of the n classes to play as.
	// menu_class_team is where you can choose to change your team, class, controls, or leave game.	
	self openpopupMenu( game[ "menu_class_" + team ] );
}

menuSpectator()
{
	self closeMenus();
	
	if( isDefined( self.pers["team"] ) && self.pers["team"] == "spectator" )
		return;

	if( isAlive( self ) )
	{
		assert( isDefined( self.pers["team"] ) );
		self.switching_teams = true;
		self.joining_team = "spectator";
		self.leaving_team = self.pers["team"];
		self suicide();
	}

	self addToTeam( "spectator" );
	self.pers["class"] = undefined;
	self.class = undefined;

	self thread maps\mp\gametypes\_playerlogic::spawnSpectator();
}


menuClass( response )
{
	self closeMenus();
	
	// clear new status of unlocked classes
	if ( response == "demolitions_mp,0" && self getPlayerData( "featureNew", "demolitions" ) )
	{
		self setPlayerData( "featureNew", "demolitions", false );
	}
	if ( response == "sniper_mp,0" && self getPlayerData( "featureNew", "sniper" ) )
	{
		self setPlayerData( "featureNew", "sniper", false );
	}

	// this should probably be an assert
	if( !level._multiTeamBased )
	{
		if(!isDefined(self.pers["team"]) || (self.pers["team"] != "allies" && self.pers["team"] != "axis"))
			return;
	}

	class = self maps\mp\gametypes\_class::getClassChoice( response );
	primary = self maps\mp\gametypes\_class::getWeaponChoice( response );

	if ( class == "restricted" )
	{
		self beginClassChoice();
		return;
	}

	if( (isDefined( self.pers["class"] ) && self.pers["class"] == class) && 
		(isDefined( self.pers["primary"] ) && self.pers["primary"] == primary) )
		return;

	if ( self.sessionstate == "playing" )
	{
		self.pers["class"] = class;
		self.class = class;
		self.pers["primary"] = primary;

		if ( game["state"] == "postgame" )
			return;

		if ( level._inGracePeriod && !self.hasDoneCombat ) // used weapons check?
		{
			if ( !isGameModeBlockingClassChange())
			{
				self maps\mp\gametypes\_class::setClass( self.pers["class"] );
				self.tag_stowed_back = undefined;
				self.tag_stowed_hip = undefined;
				self maps\mp\gametypes\_class::giveLoadout( self.pers["team"], self.pers["class"] );
			}
		}
		else
		{
			if ( !isGameModeBlockingClassChange())
			{
				self iPrintLnBold( game["strings"]["change_class"] );
			}	
		}
	}
	else
	{
		self.pers["class"] = class;
		self.class = class;
		self.pers["primary"] = primary;

		if ( game["state"] == "postgame" )
			return;

		if ( game["state"] == "playing" && !isInKillcam() )
			self thread maps\mp\gametypes\_playerlogic::spawnClient();
		}

	self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
}



addToTeam( team, firstConnect )
{
	// UTS update playerCount remove from team
	if ( isDefined( self.team ) )
		self maps\mp\gametypes\_playerlogic::removeFromTeamCount();
		
	self.pers["team"] = team;
	// this is the only place self.team should ever be set
	self.team = team;
	
	// session team is readonly in ranked matches on console
	if ( !matchMakingGame() || isDefined( self.pers["isBot"] ) )
	{
		if ( level._teamBased )
		{
			self.sessionteam = team;
		}
		else
		{
			if ( team == "spectator" )
				self.sessionteam = "spectator";
			else
				self.sessionteam = "none";
		}
	}

	// UTS update playerCount add to team
	if ( game["state"] != "postgame" )
		self maps\mp\gametypes\_playerlogic::addToTeamCount();	

	self updateObjectiveText();

	// give "joined_team" and "joined_spectators" handlers a chance to start
	// these are generally triggered from the "connected" notify, which can happen on the same
	// frame as these notifies
	if ( isDefined( firstConnect ) && firstConnect )
		waittillframeend;

	self updateMainMenu();

	if ( team == "spectator" )
	{
		self notify( "joined_spectators" );
		level notify( "joined_team" );
	}
	else
	{	
		self notify( "joined_team" );
		level notify( "joined_team" );
	}
}

isGameModeBlockingClassChange()
{
	result = false;
	if ( isDefined( level._blockClassChange) && level._blockClassChange == true )
	{
		result = true;
	}
	return result; 
}