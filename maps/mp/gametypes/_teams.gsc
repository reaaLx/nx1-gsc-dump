#include maps\mp\_utility;

FACTION_REF_COL 					= 0;
FACTION_NAME_COL 					= 1;
FACTION_SHORT_NAME_COL 				= 2;
FACTION_ELIMINATED_COL 				= 3;
FACTION_FORFEITED_COL 				= 4;
FACTION_ICON_COL 					= 5;
FACTION_HUD_ICON_COL 				= 6;
FACTION_VOICE_PREFIX_COL 			= 7;
FACTION_SPAWN_MUSIC_COL 			= 8;
FACTION_WIN_MUSIC_COL 				= 9;
FACTION_FLAG_MODEL_COL 				= 10;
FACTION_FLAG_CARRY_MODEL_COL 		= 11;
FACTION_FLAG_ICON_COL 				= 12;
FACTION_FLAG_FX_COL 				= 13;
FACTION_COLOR_R_COL 				= 14;
FACTION_COLOR_G_COL 				= 15;
FACTION_COLOR_B_COL 				= 16;
FACTION_HEAD_ICON_COL 				= 17;
FACTION_CRATE_MODEL_COL 			= 18;

MTDM_REF_COL						= 0;
MTDM_NAME_COL						= 1;
MTDM_ICON_COL						= 2;
MTDM_HEAD_ICON_COL					= 3;

init()
{
	initScoreBoard();

	if ( !level._console )
	{
		game["strings"]["autobalance"] = &"MP_AUTOBALANCE_NOW";
		precacheString( &"MP_AUTOBALANCE_NOW" );
		precacheString( &"MP_AUTOBALANCE_NEXT_ROUND" );
		precacheString( &"MP_AUTOBALANCE_SECONDS" );
	}

	level._teamBalance = getDvarInt("scr_teambalance");
	level._maxClients = getDvarInt( "sv_maxclients" );

	level._effect["thermal_beacon"] = loadFx("misc/thermal_beacon_inverted");	
	effect = level._effect["thermal_beacon"];
	PrecacheFxTeamThermal( effect, "J_Spine4" );

	setPlayerModels();

	level._freeplayers = [];

	if( level._teamBased )
	{
		level thread onPlayerConnect();
		level thread updateTeamBalance();

		wait .15;
		level thread updatePlayerTimes();
	}
	else
	{
		level thread onFreePlayerConnect();

		wait .15;
		level thread updateFreePlayerTimes();
	}
}


initScoreBoard()
{
	
	//TagZP<NOTE> this is going to need some work for MTDM
	setDvar("g_TeamName_Allies", getTeamShortName( "allies" ));
	setDvar("g_TeamIcon_Allies", getTeamIcon( "allies" ));
	setDvar("g_TeamIcon_MyAllies", getTeamIcon( "allies" ));
	setDvar("g_TeamIcon_EnemyAllies", getTeamIcon( "allies" ));
	scoreColor = getTeamColor( "allies" );	
	setDvar("g_ScoresColor_Allies", scoreColor[0] + " " + scoreColor[1] + " " + scoreColor[2] );

	setDvar("g_TeamName_Axis", getTeamShortName( "axis" ));
	setDvar("g_TeamIcon_Axis", getTeamIcon( "axis" ));
	setDvar("g_TeamIcon_MyAxis", getTeamIcon( "axis" ));
	setDvar("g_TeamIcon_EnemyAxis", getTeamIcon( "axis" ));
	scoreColor = getTeamColor( "axis" );	
	setDvar("g_ScoresColor_Axis", scoreColor[0] + " " + scoreColor[1] + " " + scoreColor[2] );

	setdvar("g_ScoresColor_Spectator", ".25 .25 .25");
	setdvar("g_ScoresColor_Free", ".76 .78 .10");
	setdvar("g_teamColor_MyTeam", ".6 .8 .6" );
	setdvar("g_teamColor_EnemyTeam", "1 .45 .5" );
	setdvar("g_teamTitleColor_MyTeam", ".6 .8 .6" );
	setdvar("g_teamTitleColor_EnemyTeam", "1 .45 .5" );	
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );

		player thread onJoinedTeam();
		player thread onJoinedSpectators();
		player thread onPlayerSpawned();

		player thread trackPlayedTime();
	}
}


onFreePlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );

		player thread trackFreePlayedTime();
	}
}


onJoinedTeam()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill( "joined_team" );
		//self logString( "joined team: " + self.pers["team"] );
		self updateTeamTime();
	}
}


onJoinedSpectators()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_spectators");
		self.pers["teamTime"] = undefined;
	}
}


trackPlayedTime()
{	
	self endon( "disconnect" );

	self.timePlayed["allies"] = 0;
	self.timePlayed["axis"] = 0;
	self.timePlayed["free"] = 0;
	self.timePlayed["other"] = 0;
	self.timePlayed["total"] = 0;

	gameFlagWait( "prematch_done" );

	for ( ;; )
	{
		if ( game["state"] == "playing" )
		{
			if ( self.sessionteam == "allies" )
			{
				self.timePlayed["allies"]++;
				self.timePlayed["total"]++;
			}
			else if ( self.sessionteam == "axis" )
			{
				self.timePlayed["axis"]++;
				self.timePlayed["total"]++;
			}
			else if ( self.sessionteam == "spectator" )
			{
				self.timePlayed["other"]++;
			}

		}

		wait ( 1.0 );
	}
}


updatePlayerTimes()
{
	if ( !level._rankedmatch )
		return;
	
	level endon( "game_ended" );
	
	for ( ;; )
	{
		foreach ( player in level._players )
			player updatePlayedTime();

		wait( 1.0 );
	}
}


updatePlayedTime()
{
	if ( !self rankingEnabled() )
		return;

	if ( self.timePlayed["allies"] )
	{
		self maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedAllies", self.timePlayed["allies"] );
		self maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedTotal", self.timePlayed["allies"] );
		self maps\mp\gametypes\_persistence::statAddChildBuffered( "round", "timePlayed", self.timePlayed["allies"] );
	}

	if ( self.timePlayed["axis"] )
	{
		self maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedOpfor", self.timePlayed["axis"] );
		self maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedTotal", self.timePlayed["axis"] );
		self maps\mp\gametypes\_persistence::statAddChildBuffered( "round", "timePlayed", self.timePlayed["axis"] );
	}

	if ( self.timePlayed["other"] )
	{
		self maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedOther", self.timePlayed["other"] );
		self maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedTotal", self.timePlayed["other"] );
		self maps\mp\gametypes\_persistence::statAddChildBuffered( "round", "timePlayed", self.timePlayed["other"] );
	}

	if ( game["state"] == "postgame" )
		return;

	self.timePlayed["allies"] = 0;
	self.timePlayed["axis"] = 0;
	self.timePlayed["other"] = 0;
}


updateTeamTime()
{
	if ( game["state"] != "playing" )
		return;

	self.pers["teamTime"] = getTime();
}


updateTeamBalanceDvar()
{
	for(;;)
	{
		teambalance = getdvarInt("scr_teambalance");
		if(level._teambalance != teambalance)
			level._teambalance = getdvarInt("scr_teambalance");

		wait 1;
	}
}


updateTeamBalance()
{
	level._teamLimit = level._maxclients / 2;

	level thread updateTeamBalanceDvar();

	wait .15;

	if ( level._teamBalance && isRoundBased() )
	{
    	if( isDefined( game["BalanceTeamsNextRound"] ) )
    		iPrintLnbold( &"MP_AUTOBALANCE_NEXT_ROUND" );

		// TODO: add or change
		level waittill( "restarting" );

		if( isDefined( game["BalanceTeamsNextRound"] ) )
		{
			level balanceTeams();
			game["BalanceTeamsNextRound"] = undefined;
		}
		else if( !getTeamBalance() )
		{
			game["BalanceTeamsNextRound"] = true;
		}
	}
	else
	{
		level endon ( "game_ended" );
		for( ;; )
		{
			if( level._teamBalance )
			{
				if( !getTeamBalance() )
				{
					iPrintLnBold( &"MP_AUTOBALANCE_SECONDS", 15 );
				    wait 15.0;

					if( !getTeamBalance() )
						level balanceTeams();
				}

				wait 59.0;
			}

			wait 1.0;
		}
	}

}


getTeamBalance()
{
	level._team["allies"] = 0;
	level._team["axis"] = 0;

	players = level._players;
	for(i = 0; i < players.size; i++)
	{
		if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
			level._team["allies"]++;
		else if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "axis"))
			level._team["axis"]++;
	}

	if((level._team["allies"] > (level._team["axis"] + level._teamBalance)) || (level._team["axis"] > (level._team["allies"] + level._teamBalance)))
		return false;
	else
		return true;
}


balanceTeams()
{
	iPrintLnBold( game["strings"]["autobalance"] );
	//Create/Clear the team arrays
	AlliedPlayers = [];
	AxisPlayers = [];

	// Populate the team arrays
	players = level._players;
	for(i = 0; i < players.size; i++)
	{
		if(!isdefined(players[i].pers["teamTime"]))
			continue;

		if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
			AlliedPlayers[AlliedPlayers.size] = players[i];
		else if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "axis"))
			AxisPlayers[AxisPlayers.size] = players[i];
	}

	MostRecent = undefined;

	while((AlliedPlayers.size > (AxisPlayers.size + 1)) || (AxisPlayers.size > (AlliedPlayers.size + 1)))
	{
		if(AlliedPlayers.size > (AxisPlayers.size + 1))
		{
			// Move the player that's been on the team the shortest ammount of time (highest teamTime value)
			for(j = 0; j < AlliedPlayers.size; j++)
			{
				if(isdefined(AlliedPlayers[j].dont_auto_balance))
					continue;

				if(!isdefined(MostRecent))
					MostRecent = AlliedPlayers[j];
				else if(AlliedPlayers[j].pers["teamTime"] > MostRecent.pers["teamTime"])
					MostRecent = AlliedPlayers[j];
			}

			MostRecent [[level._onTeamSelection]]( "axis" );
		}
		else if(AxisPlayers.size > (AlliedPlayers.size + 1))
		{
			// Move the player that's been on the team the shortest ammount of time (highest teamTime value)
			for(j = 0; j < AxisPlayers.size; j++)
			{
				if(isdefined(AxisPlayers[j].dont_auto_balance))
					continue;

				if(!isdefined(MostRecent))
					MostRecent = AxisPlayers[j];
				else if(AxisPlayers[j].pers["teamTime"] > MostRecent.pers["teamTime"])
					MostRecent = AxisPlayers[j];
			}

			MostRecent [[level._onTeamSelection]]( "allies" );
		}

		MostRecent = undefined;
		AlliedPlayers = [];
		AxisPlayers = [];

		players = level._players;
		for(i = 0; i < players.size; i++)
		{
			if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
				AlliedPlayers[AlliedPlayers.size] = players[i];
			else if((isdefined(players[i].pers["team"])) &&(players[i].pers["team"] == "axis"))
				AxisPlayers[AxisPlayers.size] = players[i];
		}
	}
}


setGhillieModels( env )
{
	level._environment = env;
	switch ( env )
	{
		case "desert":
			mptype\mptype_ally_ghillie_desert::precache();
			mptype\mptype_opforce_ghillie_desert::precache();
			game["allies_model"]["GHILLIE"] = mptype\mptype_ally_ghillie_desert::main;
			game["axis_model"]["GHILLIE"] = mptype\mptype_opforce_ghillie_desert::main;
			if( level._multiTeamBased == true )
			{
				for( i = 0; i < level._teamNameList.size; i++ )
				{
					string_ref = level._teamNameList[i] + "_model";
					game[string_ref]["GHILLIE"] = mptype\mptype_ally_ghillie_desert::main;
				}
			}
			break;
		case "arctic":
			mptype\mptype_ally_ghillie_arctic::precache();
			mptype\mptype_opforce_ghillie_arctic::precache();
			game["allies_model"]["GHILLIE"] = mptype\mptype_ally_ghillie_arctic::main;
			game["axis_model"]["GHILLIE"] = mptype\mptype_opforce_ghillie_arctic::main;
			if( level._multiTeamBased == true )
			{
				for( i = 0; i < level._teamNameList.size; i++ )
				{
					string_ref = level._teamNameList[i] + "_model";
					game[string_ref]["GHILLIE"] = mptype\mptype_ally_ghillie_arctic::main;
				}
			}
			break;
		case "urban":
			mptype\mptype_ally_ghillie_urban::precache();
			mptype\mptype_opforce_ghillie_urban::precache();
			game["allies_model"]["GHILLIE"] = mptype\mptype_ally_ghillie_urban::main;
			game["axis_model"]["GHILLIE"] = mptype\mptype_opforce_ghillie_urban::main;
			if( level._multiTeamBased == true )
			{
				for( i = 0; i < level._teamNameList.size; i++ )
				{
					string_ref = level._teamNameList[i] + "_model";
					game[string_ref]["GHILLIE"] = mptype\mptype_ally_ghillie_urban::main;
				}
			}
			break;
		case "forest":
			mptype\mptype_ally_ghillie_forest::precache();
			mptype\mptype_opforce_ghillie_forest::precache();
			game["allies_model"]["GHILLIE"] = mptype\mptype_ally_ghillie_forest::main;
			game["axis_model"]["GHILLIE"] = mptype\mptype_opforce_ghillie_forest::main;
			if( level._multiTeamBased == true )
			{
				for( i = 0; i < level._teamNameList.size; i++ )
				{
					string_ref = level._teamNameList[i] + "_model";
					game[string_ref]["GHILLIE"] = mptype\mptype_ally_ghillie_forest::main;
				}
			}
			break;
		case "space":
			mptype\mptype_nx_us_space_assault::precache();
			mptype\mptype_nx_ec_space_assault::precache();
			game["allies_model"]["GHILLIE"] =	mptype\mptype_nx_us_space_assault::main;
			game["axis_model"]["GHILLIE"] =		mptype\mptype_nx_ec_space_assault::main;
			if( level._multiTeamBased == true )
			{
				for( i = 0; i < level._teamNameList.size; i++ )
				{
					string_ref = level._teamNameList[i] + "_model";
					game[string_ref]["GHILLIE"] = mptype\mptype_nx_us_space_assault::main;
				}
			}
			break;
		default:
			break;			
	}
}

setTeamModels( team, charSet )
{
	switch ( charSet )
	{
		case "seals_udt":
			mptype\mptype_nx_us_ares::precache();
			mptype\mptype_seal_udt_sniper::precache();
			mptype\mptype_seal_udt_lmg::precache();
			mptype\mptype_seal_udt_assault::precache();
			mptype\mptype_seal_udt_shotgun::precache();
			mptype\mptype_seal_udt_smg::precache();
			mptype\mptype_seal_udt_riot::precache();

			game[team + "_model"]["ARES"] = mptype\mptype_nx_us_ares::main;
			game[team + "_model"]["SNIPER"] = mptype\mptype_seal_udt_sniper::main;
			game[team + "_model"]["LMG"] = mptype\mptype_seal_udt_lmg::main;
			game[team + "_model"]["ASSAULT"] = mptype\mptype_seal_udt_assault::main;
			game[team + "_model"]["SHOTGUN"] = mptype\mptype_seal_udt_shotgun::main;
			game[team + "_model"]["SMG"] = mptype\mptype_seal_udt_smg::main;
			game[team + "_model"]["RIOT"] = mptype\mptype_seal_udt_riot::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_seal_udt_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_seal_udt_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_seal_udt_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_seal_udt_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_seal_udt_sniper::main;

			break;
		case "us_army":
			mptype\mptype_nx_us_ares::precache();
			mptype\mptype_us_army_sniper::precache();
			mptype\mptype_us_army_lmg::precache();
			mptype\mptype_us_army_assault::precache();
			mptype\mptype_us_army_shotgun::precache();
			mptype\mptype_us_army_smg::precache();
			mptype\mptype_us_army_riot::precache();

			game[team + "_model"]["ARES"] = mptype\mptype_nx_us_ares::main;
			game[team + "_model"]["SNIPER"] = mptype\mptype_us_army_sniper::main;
			game[team + "_model"]["LMG"] = mptype\mptype_us_army_lmg::main;
			game[team + "_model"]["ASSAULT"] = mptype\mptype_us_army_assault::main;
			game[team + "_model"]["SHOTGUN"] = mptype\mptype_us_army_shotgun::main;
			game[team + "_model"]["SMG"] = mptype\mptype_us_army_smg::main;
			game[team + "_model"]["RIOT"] = mptype\mptype_us_army_riot::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_us_army_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_us_army_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_us_army_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_us_army_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_us_army_sniper::main;

			break;
		case "opforce_composite":
			mptype\mptype_nx_ec_ares::precache();
			mptype\mptype_opforce_comp_assault::precache();
			mptype\mptype_opforce_comp_lmg::precache();
			mptype\mptype_opforce_comp_shotgun::precache();
			mptype\mptype_opforce_comp_smg::precache();
			mptype\mptype_opforce_comp_sniper::precache();
			mptype\mptype_opforce_comp_riot::precache();

			game[team + "_model"]["ARES"] =		mptype\mptype_nx_ec_ares::main;
			game[team + "_model"]["SNIPER"] =	mptype\mptype_opforce_comp_sniper::main;
			game[team + "_model"]["LMG"] =		mptype\mptype_opforce_comp_lmg::main;
			game[team + "_model"]["ASSAULT"] =	mptype\mptype_opforce_comp_assault::main;
			game[team + "_model"]["SHOTGUN"] =	mptype\mptype_opforce_comp_shotgun::main;
			game[team + "_model"]["SMG"] =		mptype\mptype_opforce_comp_smg::main;
			game[team + "_model"]["RIOT"] =		mptype\mptype_opforce_comp_riot::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_opforce_comp_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_opforce_comp_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_opforce_comp_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_opforce_comp_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_opforce_comp_sniper::main;

			break;
		case "opforce_arctic":
			mptype\mptype_nx_ec_ares::precache();
			mptype\mptype_opforce_arctic_assault::precache();
			mptype\mptype_opforce_arctic_lmg::precache();
			mptype\mptype_opforce_arctic_shotgun::precache();
			mptype\mptype_opforce_arctic_smg::precache();
			mptype\mptype_opforce_arctic_sniper::precache();
			mptype\mptype_opforce_arctic_riot::precache();

			game[team + "_model"]["ARES"] = mptype\mptype_nx_ec_ares::main;
			game[team + "_model"]["SNIPER"] = mptype\mptype_opforce_arctic_sniper::main;
			game[team + "_model"]["LMG"] = mptype\mptype_opforce_arctic_lmg::main;
			game[team + "_model"]["ASSAULT"] = mptype\mptype_opforce_arctic_assault::main;
			game[team + "_model"]["SHOTGUN"] = mptype\mptype_opforce_arctic_shotgun::main;
			game[team + "_model"]["SMG"] = mptype\mptype_opforce_arctic_smg::main;
			game[team + "_model"]["RIOT"] = mptype\mptype_opforce_arctic_riot::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_opforce_arctic_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_opforce_arctic_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_opforce_arctic_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_opforce_arctic_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_opforce_arctic_sniper::main;

			break;
		case "opforce_airborne":
			mptype\mptype_nx_ec_ares::precache();
			mptype\mptype_opforce_airborne_assault::precache();
			mptype\mptype_opforce_airborne_lmg::precache();
			mptype\mptype_opforce_airborne_shotgun::precache();
			mptype\mptype_opforce_airborne_smg::precache();
			mptype\mptype_opforce_airborne_sniper::precache();
			mptype\mptype_opforce_airborne_riot::precache();

			game[team + "_model"]["ARES"] = mptype\mptype_nx_ec_ares::main;
			game[team + "_model"]["SNIPER"] = mptype\mptype_opforce_airborne_sniper::main;
			game[team + "_model"]["LMG"] = mptype\mptype_opforce_airborne_lmg::main;
			game[team + "_model"]["ASSAULT"] = mptype\mptype_opforce_airborne_assault::main;
			game[team + "_model"]["SHOTGUN"] = mptype\mptype_opforce_airborne_shotgun::main;
			game[team + "_model"]["SMG"] = mptype\mptype_opforce_airborne_smg::main;
			game[team + "_model"]["RIOT"] = mptype\mptype_opforce_airborne_riot::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_opforce_airborne_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_opforce_airborne_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_opforce_airborne_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_opforce_airborne_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_opforce_airborne_sniper::main;

			break;
		case "militia":
			mptype\mptype_nx_ec_ares::precache();
			mptype\mptype_opforce_militia_assault::precache();
			mptype\mptype_opforce_militia_lmg::precache();
			mptype\mptype_opforce_militia_shotgun::precache();
			mptype\mptype_opforce_militia_smg::precache();
			mptype\mptype_opforce_militia_sniper::precache();
			mptype\mptype_opforce_militia_riot::precache();

			game[team + "_model"]["ARES"] = mptype\mptype_nx_ec_ares::main;
			game[team + "_model"]["SNIPER"] = mptype\mptype_opforce_militia_sniper::main;
			game[team + "_model"]["LMG"] = mptype\mptype_opforce_militia_lmg::main;
			game[team + "_model"]["ASSAULT"] = mptype\mptype_opforce_militia_assault::main;
			game[team + "_model"]["SHOTGUN"] = mptype\mptype_opforce_militia_shotgun::main;
			game[team + "_model"]["SMG"] = mptype\mptype_opforce_militia_smg::main;
			game[team + "_model"]["RIOT"] = mptype\mptype_opforce_militia_riot::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_opforce_militia_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_opforce_militia_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_opforce_militia_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_opforce_militia_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_opforce_militia_sniper::main;

			break;
		case "socom_141":
			mptype\mptype_nx_us_ares::precache();
			mptype\mptype_socom_assault::precache();
			mptype\mptype_socom_lmg::precache();
			mptype\mptype_socom_shotgun::precache();
			mptype\mptype_socom_smg::precache();
			mptype\mptype_socom_sniper::precache();

			game[team + "_model"]["ARES"] = mptype\mptype_nx_us_ares::main;
			game[team + "_model"]["SNIPER"] = mptype\mptype_socom_sniper::main;
			game[team + "_model"]["LMG"] = mptype\mptype_socom_lmg::main;
			game[team + "_model"]["ASSAULT"] = mptype\mptype_socom_assault::main;
			game[team + "_model"]["SHOTGUN"] = mptype\mptype_socom_shotgun::main;
			game[team + "_model"]["SMG"] = mptype\mptype_socom_smg::main;
			game[team + "_model"]["RIOT"] = mptype\mptype_socom_smg::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_socom_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_socom_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_socom_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_socom_shotgun::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_socom_sniper::main;

			break;
		case "socom_141_desert":
			mptype\mptype_nx_us_ares::precache();
			mptype\mptype_tf141_desert_assault::precache();
			mptype\mptype_tf141_desert_lmg::precache();
			mptype\mptype_tf141_desert_smg::precache();
			mptype\mptype_tf141_desert_shotgun::precache();
			mptype\mptype_tf141_desert_sniper::precache();
			mptype\mptype_tf141_desert_riot::precache();

			game[team + "_model"]["ARES"] = mptype\mptype_nx_us_ares::main;
			game[team + "_model"]["SNIPER"] = mptype\mptype_tf141_desert_sniper::main;
			game[team + "_model"]["LMG"] = mptype\mptype_tf141_desert_lmg::main;
			game[team + "_model"]["ASSAULT"] = mptype\mptype_tf141_desert_assault::main;
			game[team + "_model"]["SHOTGUN"] = mptype\mptype_tf141_desert_shotgun::main;
			game[team + "_model"]["SMG"] = mptype\mptype_tf141_desert_smg::main;
			game[team + "_model"]["RIOT"] = mptype\mptype_tf141_desert_riot::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_tf141_desert_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_tf141_desert_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_tf141_desert_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_tf141_desert_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_tf141_desert_sniper::main;

			break;
		case "socom_141_forest":
			mptype\mptype_nx_us_ares::precache();
			mptype\mptype_tf141_forest_assault::precache();
			mptype\mptype_tf141_forest_lmg::precache();
			mptype\mptype_tf141_forest_smg::precache();
			mptype\mptype_tf141_forest_shotgun::precache();
			mptype\mptype_tf141_forest_sniper::precache();
			mptype\mptype_tf141_forest_riot::precache();

			game[team + "_model"]["ARES"] = mptype\mptype_nx_us_ares::main;
			game[team + "_model"]["SNIPER"] = mptype\mptype_tf141_forest_sniper::main;
			game[team + "_model"]["LMG"] = mptype\mptype_tf141_forest_lmg::main;
			game[team + "_model"]["ASSAULT"] = mptype\mptype_tf141_forest_assault::main;
			game[team + "_model"]["SHOTGUN"] = mptype\mptype_tf141_forest_shotgun::main;
			game[team + "_model"]["SMG"] = mptype\mptype_tf141_forest_smg::main;
			game[team + "_model"]["RIOT"] = mptype\mptype_tf141_forest_riot::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_tf141_forest_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_tf141_forest_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_tf141_forest_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_tf141_forest_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_tf141_forest_sniper::main;

			break;
		case "socom_141_arctic":
			mptype\mptype_nx_us_ares::precache();
			mptype\mptype_tf141_arctic_assault::precache();
			mptype\mptype_tf141_arctic_lmg::precache();
			mptype\mptype_tf141_arctic_smg::precache();
			mptype\mptype_tf141_arctic_shotgun::precache();
		    mptype\mptype_tf141_arctic_sniper::precache();
			mptype\mptype_tf141_arctic_riot::precache();

			game[team + "_model"]["ARES"] = mptype\mptype_nx_us_ares::main;
			game[team + "_model"]["SNIPER"] = mptype\mptype_tf141_arctic_sniper::main;
			game[team + "_model"]["LMG"] = mptype\mptype_tf141_arctic_lmg::main;
			game[team + "_model"]["ASSAULT"] = mptype\mptype_tf141_arctic_assault::main;
			game[team + "_model"]["SHOTGUN"] = mptype\mptype_tf141_arctic_shotgun::main;
			game[team + "_model"]["SMG"] = mptype\mptype_tf141_arctic_smg::main;
			game[team + "_model"]["RIOT"] = mptype\mptype_tf141_arctic_riot::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_tf141_arctic_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_tf141_arctic_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_tf141_arctic_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_tf141_arctic_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_tf141_arctic_sniper::main;

			break;
		case "nx_us_space":
			mptype\mptype_nx_us_ares::precache();
			mptype\mptype_nx_us_space_assault::precache();
			mptype\mptype_nx_us_space_lmg::precache();
			mptype\mptype_nx_us_space_riot::precache();
			mptype\mptype_nx_us_space_shotgun::precache();
			mptype\mptype_nx_us_space_smg::precache();
			mptype\mptype_nx_us_space_sniper::precache();

			game[team + "_model"]["ARES"] =			mptype\mptype_nx_us_ares::main;
			game[team + "_model"]["ASSAULT"] =		mptype\mptype_nx_us_space_assault::main;
			game[team + "_model"]["LMG"] =			mptype\mptype_nx_us_space_lmg::main;
			game[team + "_model"]["RIOT"] =			mptype\mptype_nx_us_space_riot::main;
			game[team + "_model"]["SHOTGUN"] =		mptype\mptype_nx_us_space_shotgun::main;
			game[team + "_model"]["SMG"] =			mptype\mptype_nx_us_space_smg::main;
			game[team + "_model"]["SNIPER"] =		mptype\mptype_nx_us_space_sniper::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_nx_us_space_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_nx_us_space_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_nx_us_space_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_nx_us_space_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_nx_us_space_sniper::main;

			break;
		case "nx_ec_space":
			mptype\mptype_nx_ec_ares::precache();
			mptype\mptype_nx_ec_space_assault::precache();
			mptype\mptype_nx_ec_space_lmg::precache();
			mptype\mptype_nx_ec_space_riot::precache();
			mptype\mptype_nx_ec_space_shotgun::precache();
			mptype\mptype_nx_ec_space_smg::precache();
			mptype\mptype_nx_ec_space_sniper::precache();

			game[team + "_model"]["ARES"] =			mptype\mptype_nx_ec_ares::main;
			game[team + "_model"]["ASSAULT"] =		mptype\mptype_nx_ec_space_assault::main;
			game[team + "_model"]["LMG"] =			mptype\mptype_nx_ec_space_lmg::main;
			game[team + "_model"]["RIOT"] =			mptype\mptype_nx_ec_space_riot::main;
			game[team + "_model"]["SHOTGUN"] =		mptype\mptype_nx_ec_space_shotgun::main;
			game[team + "_model"]["SMG"] =			mptype\mptype_nx_ec_space_smg::main;
			game[team + "_model"]["SNIPER"] =		mptype\mptype_nx_ec_space_sniper::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_nx_ec_space_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_nx_ec_space_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_nx_ec_space_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_nx_ec_space_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_nx_ec_space_sniper::main;

			break;
		case "nx_us_pres":
			mptype\mptype_nx_us_ares::precache();
			mptype\mptype_nx_us_pres_assault::precache();
			mptype\mptype_nx_us_pres_lmg::precache();
			mptype\mptype_nx_us_pres_riot::precache();
			mptype\mptype_nx_us_pres_shotgun::precache();
			mptype\mptype_nx_us_pres_smg::precache();
			mptype\mptype_nx_us_pres_sniper::precache();
			mptype\mptype_nx_us_pres_stealth::precache();

			game[team + "_model"]["ARES"] =			mptype\mptype_nx_us_ares::main;
			game[team + "_model"]["ASSAULT"] =		mptype\mptype_nx_us_pres_assault::main;
			game[team + "_model"]["LMG"] =			mptype\mptype_nx_us_pres_lmg::main;
			game[team + "_model"]["RIOT"] =			mptype\mptype_nx_us_pres_riot::main;
			game[team + "_model"]["SHOTGUN"] =		mptype\mptype_nx_us_pres_shotgun::main;
			game[team + "_model"]["SMG"] =			mptype\mptype_nx_us_pres_smg::main;
			game[team + "_model"]["SNIPER"] =		mptype\mptype_nx_us_pres_sniper::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_nx_us_pres_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_nx_us_pres_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_nx_us_pres_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_nx_us_pres_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_nx_us_pres_sniper::main;

			break;
		case "nx_ec_pres":
			mptype\mptype_nx_ec_ares::precache();
			mptype\mptype_nx_ec_pres_assault::precache();
			mptype\mptype_nx_ec_pres_lmg::precache();
			mptype\mptype_nx_ec_pres_riot::precache();
			mptype\mptype_nx_ec_pres_shotgun::precache();
			mptype\mptype_nx_ec_pres_smg::precache();
			mptype\mptype_nx_ec_pres_sniper::precache();
			mptype\mptype_nx_ec_pres_stealth::precache();

			game[team + "_model"]["ARES"] =			mptype\mptype_nx_ec_ares::main;
			game[team + "_model"]["ASSAULT"] =		mptype\mptype_nx_ec_pres_assault::main;
			game[team + "_model"]["LMG"] =			mptype\mptype_nx_ec_pres_lmg::main;
			game[team + "_model"]["RIOT"] =			mptype\mptype_nx_ec_pres_riot::main;
			game[team + "_model"]["SHOTGUN"] =		mptype\mptype_nx_ec_pres_shotgun::main;
			game[team + "_model"]["SMG"] =			mptype\mptype_nx_ec_pres_smg::main;
			game[team + "_model"]["SNIPER"] =		mptype\mptype_nx_ec_pres_sniper::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_nx_ec_pres_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_nx_ec_pres_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_nx_ec_pres_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_nx_ec_pres_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_nx_ec_pres_sniper::main;

			break;
		case "nx_us_specops":
			mptype\mptype_nx_us_ares::precache();
			mptype\mptype_nx_us_specops_assault::precache();
			mptype\mptype_nx_us_specops_lmg::precache();
			mptype\mptype_nx_us_specops_riot::precache();
			mptype\mptype_nx_us_specops_shotgun::precache();
			mptype\mptype_nx_us_specops_smg::precache();
			mptype\mptype_nx_us_specops_sniper::precache();
			mptype\mptype_nx_us_specops_stealth::precache();

			game[team + "_model"]["ARES"] =			mptype\mptype_nx_us_ares::main;
			game[team + "_model"]["ASSAULT"] =		mptype\mptype_nx_us_specops_assault::main;
			game[team + "_model"]["LMG"] =			mptype\mptype_nx_us_specops_lmg::main;
			game[team + "_model"]["RIOT"] =			mptype\mptype_nx_us_specops_riot::main;
			game[team + "_model"]["SHOTGUN"] =		mptype\mptype_nx_us_specops_shotgun::main;
			game[team + "_model"]["SMG"] =			mptype\mptype_nx_us_specops_smg::main;
			game[team + "_model"]["SNIPER"] =		mptype\mptype_nx_us_specops_sniper::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_nx_us_specops_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_nx_us_specops_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_nx_us_specops_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_nx_us_specops_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_nx_us_specops_sniper::main;

			break;
		case "nx_ec_specops":
			mptype\mptype_nx_ec_ares::precache();
			mptype\mptype_nx_ec_specops_assault::precache();
			mptype\mptype_nx_ec_specops_lmg::precache();
			mptype\mptype_nx_ec_specops_riot::precache();
			mptype\mptype_nx_ec_specops_shotgun::precache();
			mptype\mptype_nx_ec_specops_smg::precache();
			mptype\mptype_nx_ec_specops_sniper::precache();
			mptype\mptype_nx_ec_specops_stealth::precache();

			game[team + "_model"]["ARES"] =			mptype\mptype_nx_ec_ares::main;
			game[team + "_model"]["ASSAULT"] =		mptype\mptype_nx_ec_specops_assault::main;
			game[team + "_model"]["LMG"] =			mptype\mptype_nx_ec_specops_lmg::main;
			game[team + "_model"]["RIOT"] =			mptype\mptype_nx_ec_specops_riot::main;
			game[team + "_model"]["SHOTGUN"] =		mptype\mptype_nx_ec_specops_shotgun::main;
			game[team + "_model"]["SMG"] =			mptype\mptype_nx_ec_specops_smg::main;
			game[team + "_model"]["SNIPER"] =		mptype\mptype_nx_ec_specops_sniper::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_nx_ec_specops_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_nx_ec_specops_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_nx_ec_specops_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_nx_ec_specops_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_nx_ec_specops_sniper::main;

			break;
		case "nx_us_army":
			mptype\mptype_nx_us_ares::precache();
			mptype\mptype_nx_us_army_assault::precache();
			mptype\mptype_nx_us_army_lmg::precache();
			mptype\mptype_nx_us_army_riot::precache();
			mptype\mptype_nx_us_army_shotgun::precache();
			mptype\mptype_nx_us_army_smg::precache();
			mptype\mptype_nx_us_army_sniper::precache();
			mptype\mptype_nx_us_army_stealth::precache();

			game[team + "_model"]["ARES"] =			mptype\mptype_nx_us_ares::main;
			game[team + "_model"]["ASSAULT"] =		mptype\mptype_nx_us_army_assault::main;
			game[team + "_model"]["LMG"] =			mptype\mptype_nx_us_army_lmg::main;
			game[team + "_model"]["RIOT"] =			mptype\mptype_nx_us_army_riot::main;
			game[team + "_model"]["SHOTGUN"] =		mptype\mptype_nx_us_army_shotgun::main;
			game[team + "_model"]["SMG"] =			mptype\mptype_nx_us_army_smg::main;
			game[team + "_model"]["SNIPER"] =		mptype\mptype_nx_us_army_sniper::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_nx_us_army_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_nx_us_army_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_nx_us_army_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_nx_us_army_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_nx_us_army_sniper::main;

			break;
		case "nx_ec_army":
			mptype\mptype_nx_ec_ares::precache();
			mptype\mptype_nx_ec_army_assault::precache();
			mptype\mptype_nx_ec_army_lmg::precache();
			mptype\mptype_nx_ec_army_riot::precache();
			mptype\mptype_nx_ec_army_shotgun::precache();
			mptype\mptype_nx_ec_army_smg::precache();
			mptype\mptype_nx_ec_army_sniper::precache();
			mptype\mptype_nx_ec_army_stealth::precache();

			game[team + "_model"]["ARES"] =			mptype\mptype_nx_ec_ares::main;
			game[team + "_model"]["ASSAULT"] =		mptype\mptype_nx_ec_army_assault::main;
			game[team + "_model"]["LMG"] =			mptype\mptype_nx_ec_army_lmg::main;
			game[team + "_model"]["RIOT"] =			mptype\mptype_nx_ec_army_riot::main;
			game[team + "_model"]["SHOTGUN"] =		mptype\mptype_nx_ec_army_shotgun::main;
			game[team + "_model"]["SMG"] =			mptype\mptype_nx_ec_army_smg::main;
			game[team + "_model"]["SNIPER"] =		mptype\mptype_nx_ec_army_sniper::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_nx_ec_army_smg::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_nx_ec_army_assault::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_nx_ec_army_lmg::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_nx_ec_army_riot::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_nx_ec_army_sniper::main;

			break;
		case "nx_us_ss":
			mptype\mptype_nx_us_ares::precache();
			mptype\mptype_nx_us_ss::precache();

			game[team + "_model"]["ARES"] =			mptype\mptype_nx_us_ares::main;
			game[team + "_model"]["ASSAULT"] =		mptype\mptype_nx_us_ss::main;
			game[team + "_model"]["LMG"] =			mptype\mptype_nx_us_ss::main;
			game[team + "_model"]["RIOT"] =			mptype\mptype_nx_us_ss::main;
			game[team + "_model"]["SHOTGUN"] =		mptype\mptype_nx_us_ss::main;
			game[team + "_model"]["SMG"] =			mptype\mptype_nx_us_ss::main;
			game[team + "_model"]["SNIPER"] =		mptype\mptype_nx_us_ss::main;

			game[team + "_model"]["GAZELLE"] =		mptype\mptype_nx_us_ss::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_nx_us_ss::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_nx_us_ss::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_nx_us_ss::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_nx_us_ss::main;

			break;
		case "nx_ec":
			mptype\mptype_nx_ec_ares::precache();
			mptype\mptype_nx_ec_gazelle::precache();
			mptype\mptype_nx_ec_hulc::precache();
			mptype\mptype_nx_ec_juggernaut::precache();
			mptype\mptype_nx_ec_smart::precache();
			mptype\mptype_nx_ec_spectre::precache();

			game[team + "_model"]["SNIPER"] =	mptype\mptype_nx_ec_spectre::main;
			game[team + "_model"]["LMG"] =		mptype\mptype_nx_ec_juggernaut::main;
			game[team + "_model"]["ASSAULT"] =	mptype\mptype_nx_ec_hulc::main;
			game[team + "_model"]["SHOTGUN"] =	mptype\mptype_nx_ec_smart::main;
			game[team + "_model"]["SMG"] =		mptype\mptype_nx_ec_gazelle::main;
			game[team + "_model"]["RIOT"] =		mptype\mptype_nx_ec_juggernaut::main;

			game[team + "_model"]["ARES"] =			mptype\mptype_nx_ec_ares::main;
			game[team + "_model"]["GAZELLE"] =		mptype\mptype_nx_ec_gazelle::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_nx_ec_hulc::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_nx_ec_juggernaut::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_nx_ec_smart::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_nx_ec_spectre::main;

			break;
		case "nx_us":
			mptype\mptype_nx_us_ares::precache();
			mptype\mptype_nx_us_gazelle::precache();
			mptype\mptype_nx_us_hulc::precache();
			mptype\mptype_nx_us_juggernaut::precache();
			mptype\mptype_nx_us_smart::precache();
			mptype\mptype_nx_us_spectre::precache();

			game[team + "_model"]["SNIPER"] =	mptype\mptype_nx_us_spectre::main;
			game[team + "_model"]["LMG"] =		mptype\mptype_nx_us_juggernaut::main;
			game[team + "_model"]["ASSAULT"] =	mptype\mptype_nx_us_hulc::main;
			game[team + "_model"]["SHOTGUN"] =	mptype\mptype_nx_us_smart::main;
			game[team + "_model"]["SMG"] =		mptype\mptype_nx_us_gazelle::main;
			game[team + "_model"]["RIOT"] =		mptype\mptype_nx_us_juggernaut::main;

			game[team + "_model"]["ARES"] =			mptype\mptype_nx_us_ares::main;
			game[team + "_model"]["GAZELLE"] =		mptype\mptype_nx_us_gazelle::main;
			game[team + "_model"]["HULC"] =			mptype\mptype_nx_us_hulc::main;
			game[team + "_model"]["JUGGERNAUT"] =	mptype\mptype_nx_us_juggernaut::main;
			game[team + "_model"]["SMART"] =		mptype\mptype_nx_us_smart::main;
			game[team + "_model"]["SPECTRE"] =		mptype\mptype_nx_us_spectre::main;

			break;
	}
}

setPlayerModels()
{
	//mptype\mptype_us_army_riot::precache();
	//game["allies_model"]["riotshield"] = mptype\mptype_us_army_riot::main;
	//game["axis_model"]["riotshield"] = mptype\mptype_us_army_riot::main;

	setTeamModels( "allies", game["allies"] );
	setTeamModels( "axis", game["axis"] );
	
	if( level._multiTeamBased == true )
	{
		for( i = 0; i < level._teamNameList.size; i++ )
		{
			assert( isDefined( game[level._teamNameList[i]] ));	
			setTeamModels( level._teamNameList[i], game[level._teamNameList[i]] );
		}
	}
	
	setGhillieModels( getMapCustom( "environment" ));
}

setOverridePlayerModel()
{
	team = self.team;
	
	if ( self _hasPerk( "specialty_juggersuit" ) )
	{
		[[game[team+"_model"]["ARES"]]]();
		return true;
	}

	/*
	if ( self _hasPerk( "specialty_marathon" ) )
	{
		[[game[team+"_model"]["GAZELLE"]]]();
		return true;
	}
	
	if ( self _hasPerk( "specialty_twoprimaries" ) )
	{
		[[game[team+"_model"]["HULC"]]]();
		return true;
	}

	if ( self _hasPerk( "specialty_twoprimarieslethal" ) )
	{
		[[game[team+"_model"]["HULC"]]]();
		return true;
	}

	if ( self _hasPerk( "specialty_twoprimariesoffhand" ) )
	{
		[[game[team+"_model"]["HULC"]]]();
		return true;
	}

	if ( self _hasPerk( "specialty_flakjacket" ) )
	{
		[[game[team+"_model"]["JUGGERNAUT"]]]();
		return true;
	}

	if ( self _hasPerk( "specialty_hardline" ) )
	{
		[[game[team+"_model"]["SMART"]]]();
		return true;
	}

	if ( self _hasPerk( "specialty_spectre" ) )
	{
		[[game[team+"_model"]["SPECTRE"]]]();
		return true;
	}

	if ( isDefined ( level._overridePlayerModel) && level._overridePlayerModel == true )
	{
		[[game[team+"_model"]["GAZELLE"]]]();
		return true;
	}
	*/
	return false;
}


playerModelForWeapon( weapon, secondary )
{
	if ( setOverridePlayerModel() )
	{
		return;
	}

	team = self.team;

	if ( isDefined( game[team + "_model"][weapon] ) )
	{
		[[game[team+"_model"][weapon]]]();
		return;
	}
	
	weaponClass = tablelookup( "mp/statstable.csv", 4, weapon, 2 );

	switch ( weaponClass )
	{
		case "weapon_smg":
			[[game[team+"_model"]["SMG"]]]();
			break;
		case "weapon_assault":
			[[game[team+"_model"]["ASSAULT"]]]();
			break;
		case "weapon_sniper":
			if ( level._environment != "" && self isItemUnlocked( "ghillie_" + level._environment ) )
				[[game[team+"_model"]["GHILLIE"]]]();
			else
				[[game[team+"_model"]["SNIPER"]]]();
			break;
		case "weapon_lmg":
			[[game[team+"_model"]["LMG"]]]();
			break;
		case "weapon_riot":
			[[game[team+"_model"]["RIOT"]]]();
			break;
		case "weapon_shotgun":
			[[game[team+"_model"]["SHOTGUN"]]]();
			break;
		default:
			[[game[team+"_model"]["ASSAULT"]]]();
			break;
	}
}


CountPlayers()
{
	//chad
	players = level._players;
	allies = 0;
	axis = 0;
	for(i = 0; i < players.size; i++)
	{
		if ( players[i] == self )
			continue;

		if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "allies"))
			allies++;
		else if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == "axis"))
			axis++;
	}
	players["allies"] = allies;
	players["axis"] = axis;
	return players;
}


trackFreePlayedTime()
{
	self endon( "disconnect" );

	self.timePlayed["allies"] = 0;
	self.timePlayed["axis"] = 0;
	self.timePlayed["other"] = 0;
	self.timePlayed["total"] = 0;

	for ( ;; )
	{
		if ( game["state"] == "playing" )
		{
			if ( isDefined( self.pers["team"] ) && self.pers["team"] == "allies" && self.sessionteam != "spectator" )
			{
				self.timePlayed["allies"]++;
				self.timePlayed["total"]++;
			}
			else if ( isDefined( self.pers["team"] ) && self.pers["team"] == "axis" && self.sessionteam != "spectator" )
			{
				self.timePlayed["axis"]++;
				self.timePlayed["total"]++;
			}
			else
			{
				self.timePlayed["other"]++;
			}
		}

		wait ( 1.0 );
	}
}


/#
playerConnectedTest()
{
	if ( getdvarint( "scr_runlevelandquit" ) == 1 )
		return;
	
	level endon( "exitLevel_called" );
	
	// every frame, do a getPlayerData on each player in level.players.
	// this will force a script error if a player in level.players isn't connected.
	for ( ;; )
	{
		foreach ( player in level._players )
		{
			player getPlayerData( "experience" );
		}
		wait .05;
	}
}
#/


updateFreePlayerTimes()
{
	if ( !level._rankedmatch )
		return;
	
	/#
	thread playerConnectedTest();
	#/
	
	nextToUpdate = 0;
	for ( ;; )
	{
		nextToUpdate++;
		if ( nextToUpdate >= level._players.size )
			nextToUpdate = 0;

		if ( isDefined( level._players[nextToUpdate] ) )
			level._players[nextToUpdate] updateFreePlayedTime();

		wait ( 1.0 );
	}
}


updateFreePlayedTime()
{
	if ( !self rankingEnabled() )
		return;

	if ( self.timePlayed["allies"] )
	{
		self maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedAllies", self.timePlayed["allies"] );
		self maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedTotal", self.timePlayed["allies"] );
	}

	if ( self.timePlayed["axis"] )
	{
		self maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedOpfor", self.timePlayed["axis"] );
		self maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedTotal", self.timePlayed["axis"] );
	}

	if ( self.timePlayed["other"] )
	{
		self maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedOther", self.timePlayed["other"] );
		self maps\mp\gametypes\_persistence::statAddBuffered( "timePlayedTotal", self.timePlayed["other"] );
	}

	if ( game["state"] == "postgame" )
		return;

	self.timePlayed["allies"] = 0;
	self.timePlayed["axis"] = 0;
	self.timePlayed["other"] = 0;
}


getJoinTeamPermissions( team )
{
	teamcount = 0;

	players = level._players;
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if((isdefined(player.pers["team"])) && (player.pers["team"] == team))
			teamcount++;
	}

	if( teamCount < level._teamLimit )
		return true;
	else
		return false;
}


onPlayerSpawned()
{
	level endon ( "game_ended" );

	for ( ;; )
	{
		self waittill ( "spawned_player" );
	}
}

MTDM_getTeamName( teamRef )
{
	return ( tableLookupIString( "mp/MTDMTable.csv", MTDM_REF_COL, teamRef, MTDM_NAME_COL ));
}

MTDM_getTeamIcon( teamRef )
{
	return ( tableLookup( "mp/MTDMTable.csv", MTDM_REF_COL, teamRef, MTDM_ICON_COL ));	
}

MTDM_getTeamHeadIcon( teamRef )
{
	return ( tableLookup( "mp/MTDMTable.csv", MTDM_REF_COL, teamRef, MTDM_HEAD_ICON_COL ));	
}

getTeamName( teamRef )
{
	return ( tableLookupIString( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_NAME_COL ) );
}

getTeamShortName( teamRef )
{
	return ( tableLookupIString( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_SHORT_NAME_COL ) );
}

getTeamForfeitedString( teamRef )
{
	return ( tableLookupIString( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_FORFEITED_COL ) );
}

getTeamEliminatedString( teamRef )
{
	return ( tableLookupIString( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_ELIMINATED_COL ) );
}

getTeamIcon( teamRef )
{
	return ( tableLookup( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_ICON_COL ) );
}

getTeamHudIcon( teamRef )
{
	return ( tableLookup( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_HUD_ICON_COL ) );
}

getTeamHeadIcon( teamRef )
{
	return ( tableLookup( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_HEAD_ICON_COL ) );
}

getTeamVoicePrefix( teamRef )
{
	return ( tableLookup( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_VOICE_PREFIX_COL ) );
}

getTeamSpawnMusic( teamRef )
{
	return ( tableLookup( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_SPAWN_MUSIC_COL ) );
}

getTeamWinMusic( teamRef )
{
	return ( tableLookup( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_WIN_MUSIC_COL ) );
}

getTeamFlagModel( teamRef )
{
	return ( tableLookup( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_FLAG_MODEL_COL ) );
}

getTeamFlagCarryModel( teamRef )
{
	return ( tableLookup( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_FLAG_CARRY_MODEL_COL ) );
}

getTeamFlagIcon( teamRef )
{
	return ( tableLookup( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_FLAG_ICON_COL ) );
}

getTeamFlagFX( teamRef )
{
	return ( tableLookup( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_FLAG_FX_COL ) );
}

getTeamColor( teamRef )
{
	return ( (stringToFloat( tableLookup( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_COLOR_R_COL ) ),
				stringToFloat( tableLookup( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_COLOR_G_COL ) ),
				stringToFloat( tableLookup( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_COLOR_B_COL ) ))
			);
}

getTeamCrateModel( teamRef )
{
	return ( tableLookup( "mp/factionTable.csv", FACTION_REF_COL, game[teamRef], FACTION_CRATE_MODEL_COL ) );	
}
�&mptype/mptype_ally_ghillie_desert.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_ally_ghillie_desert::main();}precache(){	character\mp_character_ally_ghillie_desert::precache();}/character/mp_character_ally_ghillie_desert.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_ally_sniper_ghillie_desert");	self attach("head_allies_sniper_ghillie_desert", "", true);	self.headModel = "head_allies_sniper_ghillie_desert";	self setViewmodel("viewhands_ghillie_desert");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_ally_sniper_ghillie_desert");	precacheModel("head_allies_sniper_ghillie_desert");	precacheModel("viewhands_ghillie_desert");}�)mptype/mptype_opforce_ghillie_desert.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_op_ghillie_desert::main();}precache(){	character\mp_character_op_ghillie_desert::precache();}�-character/mp_character_op_ghillie_desert.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_op_sniper_ghillie_desert");	self attach("head_op_sniper_ghillie_desert", "", true);	self.headModel = "head_op_sniper_ghillie_desert";	self setViewmodel("viewhands_ghillie_desert");	self.voice = "arab";}precache(){	precacheModel("mp_body_op_sniper_ghillie_desert");	precacheModel("head_op_sniper_ghillie_desert");	precacheModel("viewhands_ghillie_desert");}�&mptype/mptype_ally_ghillie_arctic.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_ally_ghillie_arctic::main();}precache(){	character\mp_character_ally_ghillie_arctic::precache();}/character/mp_character_ally_ghillie_arctic.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_ally_sniper_ghillie_arctic");	self attach("head_allies_sniper_ghillie_arctic", "", true);	self.headModel = "head_allies_sniper_ghillie_arctic";	self setViewmodel("viewhands_ghillie_arctic");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_ally_sniper_ghillie_arctic");	precacheModel("head_allies_sniper_ghillie_arctic");	precacheModel("viewhands_ghillie_arctic");}�)mptype/mptype_opforce_ghillie_arctic.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_op_ghillie_arctic::main();}precache(){	character\mp_character_op_ghillie_arctic::precache();}�-character/mp_character_op_ghillie_arctic.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_op_sniper_ghillie_arctic");	self attach("head_op_sniper_ghillie_arctic", "", true);	self.headModel = "head_op_sniper_ghillie_arctic";	self setViewmodel("viewhands_ghillie_arctic");	self.voice = "russian";}precache(){	precacheModel("mp_body_op_sniper_ghillie_arctic");	precacheModel("head_op_sniper_ghillie_arctic");	precacheModel("viewhands_ghillie_arctic");}�%mptype/mptype_ally_ghillie_urban.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_ally_ghillie_urban::main();}precache(){	character\mp_character_ally_ghillie_urban::precache();}�.character/mp_character_ally_ghillie_urban.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_ally_sniper_ghillie_urban");	self attach("head_allies_sniper_ghillie_urban", "", true);	self.headModel = "head_allies_sniper_ghillie_urban";	self setViewmodel("viewhands_ghillie_urban");	self.voice = "seal";}precache(){	precacheModel("mp_body_ally_sniper_ghillie_urban");	precacheModel("head_allies_sniper_ghillie_urban");	precacheModel("viewhands_ghillie_urban");}�(mptype/mptype_opforce_ghillie_urban.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_op_ghillie_urban::main();}precache(){	character\mp_character_op_ghillie_urban::precache();}�,character/mp_character_op_ghillie_urban.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_op_sniper_ghillie_urban");	self attach("head_op_sniper_ghillie_urban", "", true);	self.headModel = "head_op_sniper_ghillie_urban";	self setViewmodel("viewhands_ghillie_urban");	self.voice = "russian";}precache(){	precacheModel("mp_body_op_sniper_ghillie_urban");	precacheModel("head_op_sniper_ghillie_urban");	precacheModel("viewhands_ghillie_urban");}�&mptype/mptype_ally_ghillie_forest.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_ally_ghillie_forest::main();}precache(){	character\mp_character_ally_ghillie_forest::precache();}/character/mp_character_ally_ghillie_forest.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_ally_sniper_ghillie_forest");	self attach("head_allies_sniper_ghillie_forest", "", true);	self.headModel = "head_allies_sniper_ghillie_forest";	self setViewmodel("viewhands_ghillie_forest");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_ally_sniper_ghillie_forest");	precacheModel("head_allies_sniper_ghillie_forest");	precacheModel("viewhands_ghillie_forest");}�)mptype/mptype_opforce_ghillie_forest.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_op_ghillie_forest::main();}precache(){	character\mp_character_op_ghillie_forest::precache();}�-character/mp_character_op_ghillie_forest.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_op_sniper_ghillie_forest");	self attach("head_op_sniper_ghillie_forest", "", true);	self.headModel = "head_op_sniper_ghillie_forest";	self setViewmodel("viewhands_ghillie_forest");	self.voice = "russian";}precache(){	precacheModel("mp_body_op_sniper_ghillie_forest");	precacheModel("head_op_sniper_ghillie_forest");	precacheModel("viewhands_ghillie_forest");}�&mptype/mptype_nx_us_space_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_space_assault_a::main();}precache(){	character\mp_nx_character_us_space_assault_a::precache();}�1character/mp_nx_character_us_space_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_nx_us_space_assault_body");	self attach("mp_nx_us_space_assault_head", "", true);	self.headModel = "mp_nx_us_space_assault_head";	self setViewmodel("viewhands_us_lunar");	self.voice = "american";}precache(){	precacheModel("mp_nx_us_space_assault_body");	precacheModel("mp_nx_us_space_assault_head");	precacheModel("viewhands_us_lunar");}�&mptype/mptype_nx_ec_space_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_space_assault_a::main();}precache(){	character\mp_nx_character_china_space_assault_a::precache();}�4character/mp_nx_character_china_space_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_nx_china_space_assault_body");	self attach("mp_nx_china_space_assault_head", "", true);	self.headModel = "mp_nx_china_space_assault_head";	self setViewmodel("viewhands_chinese_lunar");	self.voice = "american";}precache(){	precacheModel("mp_nx_china_space_assault_body");	precacheModel("mp_nx_china_space_assault_head");	precacheModel("viewhands_chinese_lunar");}�mptype/mptype_nx_us_ares.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_nx_ally_juggernaut::main();}precache(){	character\mp_character_nx_ally_juggernaut::precache();}�.character/mp_character_nx_ally_juggernaut.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("body_complete_mp_pmc_ai_temp");	self attach("head_complete_mp_pmc_ai_temp", "", true);	self.headModel = "head_complete_mp_pmc_ai_temp";	self setViewmodel("viewhands_usmc");	self.voice = "american";}precache(){	precacheModel("body_complete_mp_pmc_ai_temp");	precacheModel("head_complete_mp_pmc_ai_temp");	precacheModel("viewhands_usmc");}�"mptype/mptype_seal_udt_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_seal_udt_sniper::main();}precache(){	character\mp_character_seal_udt_sniper::precache();}�+character/mp_character_seal_udt_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_seal_udt_sniper");	self attach("head_allies_seal_udt_sniper", "", true);	self.headModel = "head_allies_seal_udt_sniper";	self setViewmodel("viewhands_sniper_udt");	self.voice = "seal";}precache(){	precacheModel("mp_body_seal_udt_sniper");	precacheModel("head_allies_seal_udt_sniper");	precacheModel("viewhands_sniper_udt");}�mptype/mptype_seal_udt_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_seal_udt_lmg::main();}precache(){	character\mp_character_seal_udt_lmg::precache();}�(character/mp_character_seal_udt_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_seal_udt_lmg");	codescripts\character::attachHead( "alias_seal_udt_heads", xmodelalias\alias_seal_udt_heads::main() );	self setViewmodel("viewhands_udt");	self.voice = "seal";}precache(){	precacheModel("mp_body_seal_udt_lmg");	codescripts\character::precacheModelArray(xmodelalias\alias_seal_udt_heads::main());	precacheModel("viewhands_udt");}�%xmodelalias/alias_seal_udt_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "head_seal_udt_a";	a[1] = "head_seal_udt_c";	a[2] = "head_seal_udt_d";	a[3] = "head_seal_udt_e";	return a;}�codescripts/character.gscsetModelFromArray( a )
{
	self setModel( a[ randomint( a.size ) ] );
}

precacheModelArray( a )
{
	for ( i = 0; i < a.size; i++ )
		precacheModel( a[ i ] );
}

useOptionalModels()
{
	return getdvarint( "g_useGear" );
}

attachHead( headAlias, headArray )
{
	if ( !isdefined( level._character_head_index ) )
		level._character_head_index = [];
		
	if ( !isdefined( level._character_head_index[ headAlias ] ) )
		level._character_head_index[ headAlias ] = randomint( headArray.size );
		
	assert( level._character_head_index[ headAlias ] < headArray.size );
	
	index = ( level._character_head_index[ headAlias ] + 1 ) % headArray.size;
	
	// the designer can overwrite the character
	if ( isdefined( self.script_char_index ) )
	{
		index = self.script_char_index % headArray.size;
	}
		
	level._character_head_index[ headAlias ] = index;
		
	self attach( headArray[ index ], "", true );
	self.headModel = headArray[ index ];
}

determineHeadshotModel( headAlias, headshotArray )
{
	index = level._character_head_index[ headAlias ];
	AssertEx( index < headshotArray.size, "A character asset's headAlias and headshotAlias XModelAliases are not the same size.  The name of the broken character asset can be found in the script callstack in the console output." );

	self.headshotModel = headshotArray[ index ];
}

new()
{
	self detachAll();
	oldGunHand = self.anim_gunHand;
	if ( !isdefined( oldGunHand ) )
		return;
	self.anim_gunHand = "none";
	self [[ anim.PutGunInHand ]]( oldGunHand );
}

save()
{
	info[ "gunHand" ] = self.anim_gunHand;
	info[ "gunInHand" ] = self.anim_gunInHand;
	info[ "model" ] = self.model;
	info[ "hatModel" ] = self.hatModel;
	info[ "headshotModel" ] = self.headshotModel;
	if ( isdefined( self.name ) )
	{
		info[ "name" ] = self.name;
		println( "Save: Guy has name ", self.name );
	}
	else
		println( "save: Guy had no name!" );
		
	attachSize = self getAttachSize();
	for ( i = 0; i < attachSize; i++ )
	{
		info[ "attach" ][ i ][ "model" ] = self getAttachModelName( i );
		info[ "attach" ][ i ][ "tag" ] = self getAttachTagName( i );
	}
	return info;
}

load( info )
{
	self detachAll();
	self.anim_gunHand = info[ "gunHand" ];
	self.anim_gunInHand = info[ "gunInHand" ];
	self setModel( info[ "model" ] );
	self.hatModel = info[ "hatModel" ];
	self.headshotModel = info[ "headshotModel" ];
	if ( isdefined( info[ "name" ] ) )
	{
		self.name = info[ "name" ];
		println( "Load: Guy has name ", self.name );
	}
	else
		println( "Load: Guy had no name!" );
		
	attachInfo = info[ "attach" ];
	attachSize = attachInfo.size;
	for ( i = 0; i < attachSize; i++ )
		self attach( attachInfo[ i ][ "model" ], attachInfo[ i ][ "tag" ] );
}

precache( info )
{
	if ( isdefined( info[ "name" ] ) )
		println( "Precache: Guy has name ", info[ "name" ] );
	else
		println( "Precache: Guy had no name!" );

	precacheModel( info[ "model" ] );

	attachInfo = info[ "attach" ];
	attachSize = attachInfo.size;
	for ( i = 0; i < attachSize; i++ )
		precacheModel( attachInfo[ i ][ "model" ] );
}

/* 
sample save / precache / load usage( precache is only required if there are any waits in the level script before load ):

save:
	info = foley codescripts\character::save();
	game[ "foley" ] = info;
	changelevel( "burnville", 0, true );

precache:
	codescripts\character::precache( game[ "foley" ] );

load:
	foley codescripts\character::load( game[ "foley" ] );

*/ 

get_random_character( amount )
{
	self_info = strtok( self.classname, "_" );
	if ( !common_scripts\utility::isSP() )
	{
		if ( isDefined( self.pers["modelIndex"] ) && self.pers["modelIndex"] < amount )
			return self.pers["modelIndex"];

		index = randomInt( amount );
		self.pers["modelIndex"] = index;
		
		return index;
	}
	else if ( self_info.size <= 2 )
	{
		// some custom guy that doesn't use standard naming convention
		return randomint( amount );
	}
	
	group = "auto"; // by default the type is an auto-selected character
	index = undefined;
	prefix = self_info[ 2 ]; // merc, marine, etc
	
	// the designer can overwrite the character
	if ( isdefined( self.script_char_index ) )
	{
		index = self.script_char_index;
	}

	// the designer can hint that this guy is a member of a group of like - spawned guys, so he should use a different index
	if ( isdefined( self.script_char_group ) )
	{
		type = "grouped";
		group = "group_" + self.script_char_group;
	}
	
	if ( !isdefined( level._character_index_cache ) )
	{
		// separately store script grouped guys and auto guys so that they dont influence each other
		level._character_index_cache = [];
	}
	
	if ( !isdefined( level._character_index_cache[ prefix ] ) )
	{
		// separately store script grouped guys and auto guys so that they dont influence each other
		level._character_index_cache[ prefix ] = [];
	}
	
	if ( !isdefined( level._character_index_cache[ prefix ][ group ] ) )
	{
		initialize_character_group( prefix, group, amount );
	}

	if ( !isdefined( index ) )
	{
		index = get_least_used_index( prefix, group );

		if ( !isdefined( index ) )
		{
			// fail safe
			index = randomint( 5000 );
		}
	}

		
	while ( index >= amount )
	{
		index -= amount;
	}

	level._character_index_cache[ prefix ][ group ][ index ]++;

	return index;
}

get_least_used_index( prefix, group )
{
	lowest_indices = [];
	lowest_use = level._character_index_cache[ prefix ][ group ][ 0 ];
	lowest_indices[ 0 ] = 0;
	
	for ( i = 1; i < level._character_index_cache[ prefix ][ group ].size; i++ )
	{
		if ( level._character_index_cache[ prefix ][ group ][ i ] > lowest_use )
		{
			continue;
		}
		
		if ( level._character_index_cache[ prefix ][ group ][ i ] < lowest_use )
		{
			// if its the new lowest, start over on the array
			lowest_indices = [];
			lowest_use = level._character_index_cache[ prefix ][ group ][ i ];
		}

		// the equal amounts end up in the array
		lowest_indices[ lowest_indices.size ] = i;
	}
	assertex( lowest_indices.size, "Tried to spawn a character but the lowest indices didn't exist" );
	return random( lowest_indices );
}

initialize_character_group( prefix, group, amount )
{
	for ( i = 0; i < amount; i++ )
	{
		level._character_index_cache[ prefix ][ group ][ i ] = 0;
	}
}

get_random_weapon( amount )
{
	return randomint( amount );
}

random( array )
{
	return array [ randomint( array.size ) ];
}�#mptype/mptype_seal_udt_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_seal_udt_assault_a::main();}precache(){	character\mp_character_seal_udt_assault_a::precache();}�.character/mp_character_seal_udt_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_seal_udt_assault_a");	codescripts\character::attachHead( "alias_seal_udt_heads", xmodelalias\alias_seal_udt_heads::main() );	self setViewmodel("viewhands_udt");	self.voice = "seal";}precache(){	precacheModel("mp_body_seal_udt_assault_a");	codescripts\character::precacheModelArray(xmodelalias\alias_seal_udt_heads::main());	precacheModel("viewhands_udt");}�#mptype/mptype_seal_udt_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_seal_udt_assault_b::main();}precache(){	character\mp_character_seal_udt_assault_b::precache();}�.character/mp_character_seal_udt_assault_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_seal_udt_assault_b");	codescripts\character::attachHead( "alias_seal_udt_heads", xmodelalias\alias_seal_udt_heads::main() );	self setViewmodel("viewhands_udt");	self.voice = "seal";}precache(){	precacheModel("mp_body_seal_udt_assault_b");	codescripts\character::precacheModelArray(xmodelalias\alias_seal_udt_heads::main());	precacheModel("viewhands_udt");}�mptype/mptype_seal_udt_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_seal_udt_smg::main();}precache(){	character\mp_character_seal_udt_smg::precache();}�(character/mp_character_seal_udt_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_seal_udt_smg");	codescripts\character::attachHead( "alias_seal_udt_heads", xmodelalias\alias_seal_udt_heads::main() );	self setViewmodel("viewhands_udt");	self.voice = "seal";}precache(){	precacheModel("mp_body_seal_udt_smg");	codescripts\character::precacheModelArray(xmodelalias\alias_seal_udt_heads::main());	precacheModel("viewhands_udt");}� mptype/mptype_seal_udt_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_udt_riot::main();}precache(){	character\mp_character_udt_riot::precache();}}$character/mp_character_udt_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_riot_udt");	self attach("head_riot_udt", "", true);	self.headModel = "head_riot_udt";	self setViewmodel("viewhands_udt");	self.voice = "seal";}precache(){	precacheModel("mp_body_riot_udt");	precacheModel("head_riot_udt");	precacheModel("viewhands_udt");}�!mptype/mptype_us_army_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_us_army_sniper::main();}precache(){	character\mp_character_us_army_sniper::precache();}�*character/mp_character_us_army_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_army_sniper");	self attach("head_allies_us_army_sniper", "", true);	self.headModel = "head_allies_us_army_sniper";	self setViewmodel("viewhands_sniper_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_army_sniper");	precacheModel("head_allies_us_army_sniper");	precacheModel("viewhands_sniper_us_army");}mptype/mptype_us_army_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(3) )	{	case 0:		character\mp_character_us_army_lmg::main();		break;	case 1:		character\mp_character_us_army_lmg_b::main();		break;	case 2:		character\mp_character_us_army_lmg_c::main();		break;	}}precache(){	character\mp_character_us_army_lmg::precache();	character\mp_character_us_army_lmg_b::precache();	character\mp_character_us_army_lmg_c::precache();}�'character/mp_character_us_army_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_us_army_lmg");	codescripts\character::attachHead( "alias_us_army_heads", xmodelalias\alias_us_army_heads::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_us_army_lmg");	codescripts\character::precacheModelArray(xmodelalias\alias_us_army_heads::main());	precacheModel("viewhands_us_army");}�$xmodelalias/alias_us_army_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "head_us_army_a";	a[1] = "head_us_army_b";	a[2] = "head_us_army_c";	a[3] = "head_us_army_d";	a[4] = "head_us_army_f";	return a;}�)character/mp_character_us_army_lmg_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_us_army_lmg_b");	codescripts\character::attachHead( "alias_us_army_heads", xmodelalias\alias_us_army_heads::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_us_army_lmg_b");	codescripts\character::precacheModelArray(xmodelalias\alias_us_army_heads::main());	precacheModel("viewhands_us_army");}�)character/mp_character_us_army_lmg_c.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_us_army_lmg_c");	codescripts\character::attachHead( "alias_us_army_heads", xmodelalias\alias_us_army_heads::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_us_army_lmg_c");	codescripts\character::precacheModelArray(xmodelalias\alias_us_army_heads::main());	precacheModel("viewhands_us_army");}""mptype/mptype_us_army_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(3) )	{	case 0:		character\mp_character_us_army_assault_a::main();		break;	case 1:		character\mp_character_us_army_assault_b::main();		break;	case 2:		character\mp_character_us_army_assault_c::main();		break;	}}precache(){	character\mp_character_us_army_assault_a::precache();	character\mp_character_us_army_assault_b::precache();	character\mp_character_us_army_assault_c::precache();}�-character/mp_character_us_army_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_us_army_assault_a");	codescripts\character::attachHead( "alias_us_army_heads", xmodelalias\alias_us_army_heads::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_us_army_assault_a");	codescripts\character::precacheModelArray(xmodelalias\alias_us_army_heads::main());	precacheModel("viewhands_us_army");}�-character/mp_character_us_army_assault_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_us_army_assault_b");	codescripts\character::attachHead( "alias_us_army_heads", xmodelalias\alias_us_army_heads::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_us_army_assault_b");	codescripts\character::precacheModelArray(xmodelalias\alias_us_army_heads::main());	precacheModel("viewhands_us_army");}�-character/mp_character_us_army_assault_c.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_us_army_assault_c");	codescripts\character::attachHead( "alias_us_army_heads", xmodelalias\alias_us_army_heads::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_us_army_assault_c");	codescripts\character::precacheModelArray(xmodelalias\alias_us_army_heads::main());	precacheModel("viewhands_us_army");}"mptype/mptype_us_army_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(3) )	{	case 0:		character\mp_character_us_army_shotgun::main();		break;	case 1:		character\mp_character_us_army_shotgun_b::main();		break;	case 2:		character\mp_character_us_army_shotgun_c::main();		break;	}}precache(){	character\mp_character_us_army_shotgun::precache();	character\mp_character_us_army_shotgun_b::precache();	character\mp_character_us_army_shotgun_c::precache();}�+character/mp_character_us_army_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_us_army_shotgun");	codescripts\character::attachHead( "alias_us_army_heads", xmodelalias\alias_us_army_heads::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_us_army_shotgun");	codescripts\character::precacheModelArray(xmodelalias\alias_us_army_heads::main());	precacheModel("viewhands_us_army");}�-character/mp_character_us_army_shotgun_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_us_army_shotgun_b");	codescripts\character::attachHead( "alias_us_army_heads", xmodelalias\alias_us_army_heads::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_us_army_shotgun_b");	codescripts\character::precacheModelArray(xmodelalias\alias_us_army_heads::main());	precacheModel("viewhands_us_army");}�-character/mp_character_us_army_shotgun_c.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_us_army_shotgun_c");	codescripts\character::attachHead( "alias_us_army_heads", xmodelalias\alias_us_army_heads::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_us_army_shotgun_c");	codescripts\character::precacheModelArray(xmodelalias\alias_us_army_heads::main());	precacheModel("viewhands_us_army");}mptype/mptype_us_army_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(3) )	{	case 0:		character\mp_character_us_army_smg::main();		break;	case 1:		character\mp_character_us_army_smg_b::main();		break;	case 2:		character\mp_character_us_army_smg_c::main();		break;	}}precache(){	character\mp_character_us_army_smg::precache();	character\mp_character_us_army_smg_b::precache();	character\mp_character_us_army_smg_c::precache();}�'character/mp_character_us_army_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_us_army_smg");	codescripts\character::attachHead( "alias_us_army_heads", xmodelalias\alias_us_army_heads::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_us_army_smg");	codescripts\character::precacheModelArray(xmodelalias\alias_us_army_heads::main());	precacheModel("viewhands_us_army");}�)character/mp_character_us_army_smg_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_us_army_smg_b");	codescripts\character::attachHead( "alias_us_army_heads", xmodelalias\alias_us_army_heads::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_us_army_smg_b");	codescripts\character::precacheModelArray(xmodelalias\alias_us_army_heads::main());	precacheModel("viewhands_us_army");}�)character/mp_character_us_army_smg_c.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_us_army_smg_c");	codescripts\character::attachHead( "alias_us_army_heads", xmodelalias\alias_us_army_heads::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_us_army_smg_c");	codescripts\character::precacheModelArray(xmodelalias\alias_us_army_heads::main());	precacheModel("viewhands_us_army");}�mptype/mptype_us_army_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_us_army_riot::main();}precache(){	character\mp_character_us_army_riot::precache();}�(character/mp_character_us_army_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_us_army_riot");	codescripts\character::attachHead( "alias_us_army_riot", xmodelalias\alias_us_army_riot::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_us_army_riot");	codescripts\character::precacheModelArray(xmodelalias\alias_us_army_riot::main());	precacheModel("viewhands_us_army");}�#xmodelalias/alias_us_army_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "head_us_army_e";	return a;}�mptype/mptype_nx_ec_ares.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_nx_axis_juggernaut::main();}precache(){	character\mp_character_nx_axis_juggernaut::precache();}�.character/mp_character_nx_axis_juggernaut.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("body_complete_mp_pmc_ai_alt_temp");	self attach("head_complete_mp_pmc_ai_alt_temp", "", true);	self.headModel = "head_complete_mp_pmc_ai_alt_temp";	self setViewmodel("viewhands_op_force");	self.voice = "american";}precache(){	precacheModel("body_complete_mp_pmc_ai_alt_temp");	precacheModel("head_complete_mp_pmc_ai_alt_temp");	precacheModel("viewhands_op_force");}�'mptype/mptype_opforce_comp_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_composite_assault_a::main();}precache(){	character\mp_character_composite_assault_a::precache();}	/character/mp_character_composite_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_opforce_arab_assault_a");	codescripts\character::attachHead( "alias_opforce_arab_heads", xmodelalias\alias_opforce_arab_heads::main() );	self setViewmodel("viewhands_militia");	self.voice = "arab";}precache(){	precacheModel("mp_body_opforce_arab_assault_a");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arab_heads::main());	precacheModel("viewhands_militia");})xmodelalias/alias_opforce_arab_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "head_opforce_arab_a";	a[1] = "head_opforce_arab_b";	a[2] = "head_opforce_arab_c";	a[3] = "head_opforce_arab_d_hat";	a[4] = "head_opforce_arab_e";	return a;}�#mptype/mptype_opforce_comp_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_composite_lmg::main();}precache(){	character\mp_character_composite_lmg::precache();}�)character/mp_character_composite_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_opforce_arab_lmg_a");	codescripts\character::attachHead( "alias_opforce_arab_heads", xmodelalias\alias_opforce_arab_heads::main() );	self setViewmodel("viewhands_militia");	self.voice = "arab";}precache(){	precacheModel("mp_body_opforce_arab_lmg_a");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arab_heads::main());	precacheModel("viewhands_militia");}�'mptype/mptype_opforce_comp_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_composite_shotgun::main();}precache(){	character\mp_character_composite_shotgun::precache();}-character/mp_character_composite_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_opforce_arab_shotgun_a");	codescripts\character::attachHead( "alias_opforce_arab_heads", xmodelalias\alias_opforce_arab_heads::main() );	self setViewmodel("viewhands_militia");	self.voice = "arab";}precache(){	precacheModel("mp_body_opforce_arab_shotgun_a");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arab_heads::main());	precacheModel("viewhands_militia");}�#mptype/mptype_opforce_comp_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_composite_smg::main();}precache(){	character\mp_character_composite_smg::precache();}�)character/mp_character_composite_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_opforce_arab_smg_a");	codescripts\character::attachHead( "alias_opforce_arab_heads", xmodelalias\alias_opforce_arab_heads::main() );	self setViewmodel("viewhands_militia");	self.voice = "arab";}precache(){	precacheModel("mp_body_opforce_arab_smg_a");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arab_heads::main());	precacheModel("viewhands_militia");}�&mptype/mptype_opforce_comp_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_op_arab_sniper::main();}precache(){	character\mp_character_op_arab_sniper::precache();}�*character/mp_character_op_arab_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_op_arab_sniper");	self attach("head_op_arab_sniper", "", true);	self.headModel = "head_op_arab_sniper";	self setViewmodel("viewhands_sniper_op_arab");	self.voice = "arab";}precache(){	precacheModel("mp_body_op_arab_sniper");	precacheModel("head_op_arab_sniper");	precacheModel("viewhands_sniper_op_arab");}�$mptype/mptype_opforce_comp_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_op_arab_riot::main();}precache(){	character\mp_character_op_arab_riot::precache();}�(character/mp_character_op_arab_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_riot_op_arab");	self attach("head_riot_op_arab", "", true);	self.headModel = "head_riot_op_arab";	self setViewmodel("viewhands_militia");	self.voice = "arab";}precache(){	precacheModel("mp_body_riot_op_arab");	precacheModel("head_riot_op_arab");	precacheModel("viewhands_militia");}S)mptype/mptype_opforce_arctic_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(3) )	{	case 0:		character\mp_character_opforce_arctic_assault_a::main();		break;	case 1:		character\mp_character_opforce_arctic_assault_b::main();		break;	case 2:		character\mp_character_opforce_arctic_assault_c::main();		break;	}}precache(){	character\mp_character_opforce_arctic_assault_a::precache();	character\mp_character_opforce_arctic_assault_b::precache();	character\mp_character_opforce_arctic_assault_c::precache();})4character/mp_character_opforce_arctic_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_opforce_arctic_assault_a");	codescripts\character::attachHead( "alias_opforce_arctic_heads", xmodelalias\alias_opforce_arctic_heads::main() );	self setViewmodel("viewhands_arctic_opforce");	self.voice = "russian";}precache(){	precacheModel("mp_body_opforce_arctic_assault_a");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arctic_heads::main());	precacheModel("viewhands_arctic_opforce");}�+xmodelalias/alias_opforce_arctic_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "head_opforce_arctic_a";	a[1] = "head_opforce_arctic_b";	a[2] = "head_opforce_arctic_c";	a[3] = "head_opforce_arctic_d";	return a;})4character/mp_character_opforce_arctic_assault_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_opforce_arctic_assault_b");	codescripts\character::attachHead( "alias_opforce_arctic_heads", xmodelalias\alias_opforce_arctic_heads::main() );	self setViewmodel("viewhands_arctic_opforce");	self.voice = "russian";}precache(){	precacheModel("mp_body_opforce_arctic_assault_b");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arctic_heads::main());	precacheModel("viewhands_arctic_opforce");})4character/mp_character_opforce_arctic_assault_c.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_opforce_arctic_assault_c");	codescripts\character::attachHead( "alias_opforce_arctic_heads", xmodelalias\alias_opforce_arctic_heads::main() );	self setViewmodel("viewhands_arctic_opforce");	self.voice = "russian";}precache(){	precacheModel("mp_body_opforce_arctic_assault_c");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arctic_heads::main());	precacheModel("viewhands_arctic_opforce");}3%mptype/mptype_opforce_arctic_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(3) )	{	case 0:		character\mp_character_opforce_arctic_lmg::main();		break;	case 1:		character\mp_character_opforce_arctic_lmg_b::main();		break;	case 2:		character\mp_character_opforce_arctic_lmg_c::main();		break;	}}precache(){	character\mp_character_opforce_arctic_lmg::precache();	character\mp_character_opforce_arctic_lmg_b::precache();	character\mp_character_opforce_arctic_lmg_c::precache();}.character/mp_character_opforce_arctic_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_opforce_arctic_lmg");	codescripts\character::attachHead( "alias_opforce_arctic_heads", xmodelalias\alias_opforce_arctic_heads::main() );	self setViewmodel("viewhands_arctic_opforce");	self.voice = "russian";}precache(){	precacheModel("mp_body_opforce_arctic_lmg");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arctic_heads::main());	precacheModel("viewhands_arctic_opforce");}0character/mp_character_opforce_arctic_lmg_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_opforce_arctic_lmg_b");	codescripts\character::attachHead( "alias_opforce_arctic_heads", xmodelalias\alias_opforce_arctic_heads::main() );	self setViewmodel("viewhands_arctic_opforce");	self.voice = "russian";}precache(){	precacheModel("mp_body_opforce_arctic_lmg_b");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arctic_heads::main());	precacheModel("viewhands_arctic_opforce");}0character/mp_character_opforce_arctic_lmg_c.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_opforce_arctic_lmg_c");	codescripts\character::attachHead( "alias_opforce_arctic_heads", xmodelalias\alias_opforce_arctic_heads::main() );	self setViewmodel("viewhands_arctic_opforce");	self.voice = "russian";}precache(){	precacheModel("mp_body_opforce_arctic_lmg_c");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arctic_heads::main());	precacheModel("viewhands_arctic_opforce");}O)mptype/mptype_opforce_arctic_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(3) )	{	case 0:		character\mp_character_opforce_arctic_shotgun::main();		break;	case 1:		character\mp_character_opforce_arctic_shotgun_b::main();		break;	case 2:		character\mp_character_opforce_arctic_shotgun_c::main();		break;	}}precache(){	character\mp_character_opforce_arctic_shotgun::precache();	character\mp_character_opforce_arctic_shotgun_b::precache();	character\mp_character_opforce_arctic_shotgun_c::precache();}#2character/mp_character_opforce_arctic_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_opforce_arctic_shotgun");	codescripts\character::attachHead( "alias_opforce_arctic_heads", xmodelalias\alias_opforce_arctic_heads::main() );	self setViewmodel("viewhands_arctic_opforce");	self.voice = "russian";}precache(){	precacheModel("mp_body_opforce_arctic_shotgun");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arctic_heads::main());	precacheModel("viewhands_arctic_opforce");})4character/mp_character_opforce_arctic_shotgun_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_opforce_arctic_shotgun_b");	codescripts\character::attachHead( "alias_opforce_arctic_heads", xmodelalias\alias_opforce_arctic_heads::main() );	self setViewmodel("viewhands_arctic_opforce");	self.voice = "russian";}precache(){	precacheModel("mp_body_opforce_arctic_shotgun_b");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arctic_heads::main());	precacheModel("viewhands_arctic_opforce");})4character/mp_character_opforce_arctic_shotgun_c.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_opforce_arctic_shotgun_c");	codescripts\character::attachHead( "alias_opforce_arctic_heads", xmodelalias\alias_opforce_arctic_heads::main() );	self setViewmodel("viewhands_arctic_opforce");	self.voice = "russian";}precache(){	precacheModel("mp_body_opforce_arctic_shotgun_c");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arctic_heads::main());	precacheModel("viewhands_arctic_opforce");}3%mptype/mptype_opforce_arctic_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(3) )	{	case 0:		character\mp_character_opforce_arctic_smg::main();		break;	case 1:		character\mp_character_opforce_arctic_smg_b::main();		break;	case 2:		character\mp_character_opforce_arctic_smg_c::main();		break;	}}precache(){	character\mp_character_opforce_arctic_smg::precache();	character\mp_character_opforce_arctic_smg_b::precache();	character\mp_character_opforce_arctic_smg_c::precache();}.character/mp_character_opforce_arctic_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_opforce_arctic_smg");	codescripts\character::attachHead( "alias_opforce_arctic_heads", xmodelalias\alias_opforce_arctic_heads::main() );	self setViewmodel("viewhands_arctic_opforce");	self.voice = "russian";}precache(){	precacheModel("mp_body_opforce_arctic_smg");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arctic_heads::main());	precacheModel("viewhands_arctic_opforce");}0character/mp_character_opforce_arctic_smg_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_opforce_arctic_smg_b");	codescripts\character::attachHead( "alias_opforce_arctic_heads", xmodelalias\alias_opforce_arctic_heads::main() );	self setViewmodel("viewhands_arctic_opforce");	self.voice = "russian";}precache(){	precacheModel("mp_body_opforce_arctic_smg_b");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arctic_heads::main());	precacheModel("viewhands_arctic_opforce");}0character/mp_character_opforce_arctic_smg_c.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_opforce_arctic_smg_c");	codescripts\character::attachHead( "alias_opforce_arctic_heads", xmodelalias\alias_opforce_arctic_heads::main() );	self setViewmodel("viewhands_arctic_opforce");	self.voice = "russian";}precache(){	precacheModel("mp_body_opforce_arctic_smg_c");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arctic_heads::main());	precacheModel("viewhands_arctic_opforce");}�(mptype/mptype_opforce_arctic_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_op_arctic_sniper::main();}precache(){	character\mp_character_op_arctic_sniper::precache();}�,character/mp_character_op_arctic_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_op_arctic_sniper");	self attach("head_op_arctic_sniper", "", true);	self.headModel = "head_op_arctic_sniper";	self setViewmodel("viewhands_sniper_op_arctic");	self.voice = "russian";}precache(){	precacheModel("mp_body_op_arctic_sniper");	precacheModel("head_op_arctic_sniper");	precacheModel("viewhands_sniper_op_arctic");}�&mptype/mptype_opforce_arctic_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_op_arctic_riot::main();}precache(){	character\mp_character_op_arctic_riot::precache();}�*character/mp_character_op_arctic_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_riot_op_arctic");	self attach("head_riot_op_arctic", "", true);	self.headModel = "head_riot_op_arctic";	self setViewmodel("viewhands_arctic_opforce");	self.voice = "russian";}precache(){	precacheModel("mp_body_riot_op_arctic");	precacheModel("head_riot_op_arctic");	precacheModel("viewhands_arctic_opforce");}1+mptype/mptype_opforce_airborne_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(3) )	{	case 0:		character\mp_character_airborne_assault_a::main();		break;	case 1:		character\mp_character_airborne_assault_b::main();		break;	case 2:		character\mp_character_airborne_assault_c::main();		break;	}}precache(){	character\mp_character_airborne_assault_a::precache();	character\mp_character_airborne_assault_b::precache();	character\mp_character_airborne_assault_c::precache();}	.character/mp_character_airborne_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_airborne_assault_a");	codescripts\character::attachHead( "alias_airborne_heads", xmodelalias\alias_airborne_heads::main() );	self setViewmodel("viewhands_russian_airborne");	self.voice = "russian";}precache(){	precacheModel("mp_body_airborne_assault_a");	codescripts\character::precacheModelArray(xmodelalias\alias_airborne_heads::main());	precacheModel("viewhands_russian_airborne");}�%xmodelalias/alias_airborne_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "head_airborne_a";	a[1] = "head_airborne_b";	a[2] = "head_airborne_c";	a[3] = "head_airborne_d";	a[4] = "head_airborne_e";	return a;}	.character/mp_character_airborne_assault_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_airborne_assault_b");	codescripts\character::attachHead( "alias_airborne_heads", xmodelalias\alias_airborne_heads::main() );	self setViewmodel("viewhands_russian_airborne");	self.voice = "russian";}precache(){	precacheModel("mp_body_airborne_assault_b");	codescripts\character::precacheModelArray(xmodelalias\alias_airborne_heads::main());	precacheModel("viewhands_russian_airborne");}	.character/mp_character_airborne_assault_c.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_airborne_assault_c");	codescripts\character::attachHead( "alias_airborne_heads", xmodelalias\alias_airborne_heads::main() );	self setViewmodel("viewhands_russian_airborne");	self.voice = "russian";}precache(){	precacheModel("mp_body_airborne_assault_c");	codescripts\character::precacheModelArray(xmodelalias\alias_airborne_heads::main());	precacheModel("viewhands_russian_airborne");}'mptype/mptype_opforce_airborne_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(3) )	{	case 0:		character\mp_character_airborne_lmg::main();		break;	case 1:		character\mp_character_airborne_lmg_b::main();		break;	case 2:		character\mp_character_airborne_lmg_c::main();		break;	}}precache(){	character\mp_character_airborne_lmg::precache();	character\mp_character_airborne_lmg_b::precache();	character\mp_character_airborne_lmg_c::precache();}�(character/mp_character_airborne_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_airborne_lmg");	codescripts\character::attachHead( "alias_airborne_heads", xmodelalias\alias_airborne_heads::main() );	self setViewmodel("viewhands_russian_airborne");	self.voice = "russian";}precache(){	precacheModel("mp_body_airborne_lmg");	codescripts\character::precacheModelArray(xmodelalias\alias_airborne_heads::main());	precacheModel("viewhands_russian_airborne");}�*character/mp_character_airborne_lmg_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_airborne_lmg_b");	codescripts\character::attachHead( "alias_airborne_heads", xmodelalias\alias_airborne_heads::main() );	self setViewmodel("viewhands_russian_airborne");	self.voice = "russian";}precache(){	precacheModel("mp_body_airborne_lmg_b");	codescripts\character::precacheModelArray(xmodelalias\alias_airborne_heads::main());	precacheModel("viewhands_russian_airborne");}�*character/mp_character_airborne_lmg_c.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_airborne_lmg_c");	codescripts\character::attachHead( "alias_airborne_heads", xmodelalias\alias_airborne_heads::main() );	self setViewmodel("viewhands_russian_airborne");	self.voice = "russian";}precache(){	precacheModel("mp_body_airborne_lmg_c");	codescripts\character::precacheModelArray(xmodelalias\alias_airborne_heads::main());	precacheModel("viewhands_russian_airborne");}-+mptype/mptype_opforce_airborne_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(3) )	{	case 0:		character\mp_character_airborne_shotgun::main();		break;	case 1:		character\mp_character_airborne_shotgun_b::main();		break;	case 2:		character\mp_character_airborne_shotgun_c::main();		break;	}}precache(){	character\mp_character_airborne_shotgun::precache();	character\mp_character_airborne_shotgun_b::precache();	character\mp_character_airborne_shotgun_c::precache();},character/mp_character_airborne_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_airborne_shotgun");	codescripts\character::attachHead( "alias_airborne_heads", xmodelalias\alias_airborne_heads::main() );	self setViewmodel("viewhands_russian_airborne");	self.voice = "russian";}precache(){	precacheModel("mp_body_airborne_shotgun");	codescripts\character::precacheModelArray(xmodelalias\alias_airborne_heads::main());	precacheModel("viewhands_russian_airborne");}	.character/mp_character_airborne_shotgun_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_airborne_shotgun_b");	codescripts\character::attachHead( "alias_airborne_heads", xmodelalias\alias_airborne_heads::main() );	self setViewmodel("viewhands_russian_airborne");	self.voice = "russian";}precache(){	precacheModel("mp_body_airborne_shotgun_b");	codescripts\character::precacheModelArray(xmodelalias\alias_airborne_heads::main());	precacheModel("viewhands_russian_airborne");}	.character/mp_character_airborne_shotgun_c.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_airborne_shotgun_c");	codescripts\character::attachHead( "alias_airborne_heads", xmodelalias\alias_airborne_heads::main() );	self setViewmodel("viewhands_russian_airborne");	self.voice = "russian";}precache(){	precacheModel("mp_body_airborne_shotgun_c");	codescripts\character::precacheModelArray(xmodelalias\alias_airborne_heads::main());	precacheModel("viewhands_russian_airborne");}'mptype/mptype_opforce_airborne_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(3) )	{	case 0:		character\mp_character_airborne_smg::main();		break;	case 1:		character\mp_character_airborne_smg_b::main();		break;	case 2:		character\mp_character_airborne_smg_c::main();		break;	}}precache(){	character\mp_character_airborne_smg::precache();	character\mp_character_airborne_smg_b::precache();	character\mp_character_airborne_smg_c::precache();}�(character/mp_character_airborne_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_airborne_smg");	codescripts\character::attachHead( "alias_airborne_heads", xmodelalias\alias_airborne_heads::main() );	self setViewmodel("viewhands_russian_airborne");	self.voice = "russian";}precache(){	precacheModel("mp_body_airborne_smg");	codescripts\character::precacheModelArray(xmodelalias\alias_airborne_heads::main());	precacheModel("viewhands_russian_airborne");}�*character/mp_character_airborne_smg_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_airborne_smg_b");	codescripts\character::attachHead( "alias_airborne_heads", xmodelalias\alias_airborne_heads::main() );	self setViewmodel("viewhands_russian_airborne");	self.voice = "russian";}precache(){	precacheModel("mp_body_airborne_smg_b");	codescripts\character::precacheModelArray(xmodelalias\alias_airborne_heads::main());	precacheModel("viewhands_russian_airborne");}�*character/mp_character_airborne_smg_c.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_airborne_smg_c");	codescripts\character::attachHead( "alias_airborne_heads", xmodelalias\alias_airborne_heads::main() );	self setViewmodel("viewhands_russian_airborne");	self.voice = "russian";}precache(){	precacheModel("mp_body_airborne_smg_c");	codescripts\character::precacheModelArray(xmodelalias\alias_airborne_heads::main());	precacheModel("viewhands_russian_airborne");}�*mptype/mptype_opforce_airborne_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_op_airborne_sniper::main();}precache(){	character\mp_character_op_airborne_sniper::precache();}�.character/mp_character_op_airborne_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_op_airborne_sniper");	self attach("head_op_airborne_sniper", "", true);	self.headModel = "head_op_airborne_sniper";	self setViewmodel("viewhands_sniper_op_airborne");	self.voice = "russian";}precache(){	precacheModel("mp_body_op_airborne_sniper");	precacheModel("head_op_airborne_sniper");	precacheModel("viewhands_sniper_op_airborne");}�(mptype/mptype_opforce_airborne_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_op_airborne_riot::main();}precache(){	character\mp_character_op_airborne_riot::precache();}�,character/mp_character_op_airborne_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_riot_op_airborne");	self attach("head_riot_op_airborne", "", true);	self.headModel = "head_riot_op_airborne";	self setViewmodel("viewhands_russian_airborne");	self.voice = "seal";}precache(){	precacheModel("mp_body_riot_op_airborne");	precacheModel("head_riot_op_airborne");	precacheModel("viewhands_russian_airborne");}�*mptype/mptype_opforce_militia_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(4) )	{	case 0:		character\mp_character_militia_assault_aa_blk::main();		break;	case 1:		character\mp_character_militia_assault_aa_wht::main();		break;	case 2:		character\mp_character_militia_assault_ab_blk::main();		break;	case 3:		character\mp_character_militia_assault_ac_blk::main();		break;	}}precache(){	character\mp_character_militia_assault_aa_blk::precache();	character\mp_character_militia_assault_aa_wht::precache();	character\mp_character_militia_assault_ab_blk::precache();	character\mp_character_militia_assault_ac_blk::precache();}'2character/mp_character_militia_assault_aa_blk.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_militia_assault_aa_blk");	codescripts\character::attachHead( "alias_opforce_militia_heads_blk", xmodelalias\alias_opforce_militia_heads_blk::main() );	self setViewmodel("viewhands_militia");	self.voice = "portuguese";}precache(){	precacheModel("mp_body_militia_assault_aa_blk");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_militia_heads_blk::main());	precacheModel("viewhands_militia");}�0xmodelalias/alias_opforce_militia_heads_blk.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "head_militia_ba_blk";	a[1] = "head_militia_bb_blk_hat";	a[2] = "head_militia_bc_blk";	a[3] = "head_militia_bd_blk";	return a;}'2character/mp_character_militia_assault_aa_wht.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_militia_assault_aa_wht");	codescripts\character::attachHead( "alias_opforce_militia_heads_wht", xmodelalias\alias_opforce_militia_heads_wht::main() );	self setViewmodel("viewhands_militia");	self.voice = "portuguese";}precache(){	precacheModel("mp_body_militia_assault_aa_wht");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_militia_heads_wht::main());	precacheModel("viewhands_militia");}�0xmodelalias/alias_opforce_militia_heads_wht.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "head_militia_a_wht";	return a;}'2character/mp_character_militia_assault_ab_blk.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_militia_assault_ab_blk");	codescripts\character::attachHead( "alias_opforce_militia_heads_blk", xmodelalias\alias_opforce_militia_heads_blk::main() );	self setViewmodel("viewhands_militia");	self.voice = "portuguese";}precache(){	precacheModel("mp_body_militia_assault_ab_blk");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_militia_heads_blk::main());	precacheModel("viewhands_militia");}'2character/mp_character_militia_assault_ac_blk.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_militia_assault_ac_blk");	codescripts\character::attachHead( "alias_opforce_militia_heads_blk", xmodelalias\alias_opforce_militia_heads_blk::main() );	self setViewmodel("viewhands_militia");	self.voice = "portuguese";}precache(){	precacheModel("mp_body_militia_assault_ac_blk");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_militia_heads_blk::main());	precacheModel("viewhands_militia");},&mptype/mptype_opforce_militia_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(3) )	{	case 0:		character\mp_character_militia_lmg_aa_blk::main();		break;	case 1:		character\mp_character_militia_lmg_ab_blk::main();		break;	case 2:		character\mp_character_militia_lmg_ac_blk::main();		break;	}}precache(){	character\mp_character_militia_lmg_aa_blk::precache();	character\mp_character_militia_lmg_ab_blk::precache();	character\mp_character_militia_lmg_ac_blk::precache();}.character/mp_character_militia_lmg_aa_blk.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_militia_lmg_aa_blk");	codescripts\character::attachHead( "alias_opforce_militia_heads_blk", xmodelalias\alias_opforce_militia_heads_blk::main() );	self setViewmodel("viewhands_militia");	self.voice = "portuguese";}precache(){	precacheModel("mp_body_militia_lmg_aa_blk");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_militia_heads_blk::main());	precacheModel("viewhands_militia");}.character/mp_character_militia_lmg_ab_blk.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_militia_lmg_ab_blk");	codescripts\character::attachHead( "alias_opforce_militia_heads_blk", xmodelalias\alias_opforce_militia_heads_blk::main() );	self setViewmodel("viewhands_militia");	self.voice = "portuguese";}precache(){	precacheModel("mp_body_militia_lmg_ab_blk");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_militia_heads_blk::main());	precacheModel("viewhands_militia");}.character/mp_character_militia_lmg_ac_blk.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_militia_lmg_ac_blk");	codescripts\character::attachHead( "alias_opforce_militia_heads_blk", xmodelalias\alias_opforce_militia_heads_blk::main() );	self setViewmodel("viewhands_militia");	self.voice = "portuguese";}precache(){	precacheModel("mp_body_militia_lmg_ac_blk");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_militia_heads_blk::main());	precacheModel("viewhands_militia");}�*mptype/mptype_opforce_militia_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(2) )	{	case 0:		character\mp_character_militia_shotgun_aa_blk::main();		break;	case 1:		character\mp_character_militia_shotgun_aa_wht::main();		break;	}}precache(){	character\mp_character_militia_shotgun_aa_blk::precache();	character\mp_character_militia_shotgun_aa_wht::precache();}2character/mp_character_militia_shotgun_aa_blk.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_militia_smg_aa_blk");	codescripts\character::attachHead( "alias_opforce_militia_heads_blk", xmodelalias\alias_opforce_militia_heads_blk::main() );	self setViewmodel("viewhands_militia");	self.voice = "portuguese";}precache(){	precacheModel("mp_body_militia_smg_aa_blk");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_militia_heads_blk::main());	precacheModel("viewhands_militia");}2character/mp_character_militia_shotgun_aa_wht.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_militia_smg_aa_wht");	codescripts\character::attachHead( "alias_opforce_militia_heads_wht", xmodelalias\alias_opforce_militia_heads_wht::main() );	self setViewmodel("viewhands_militia");	self.voice = "portuguese";}precache(){	precacheModel("mp_body_militia_smg_aa_wht");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_militia_heads_wht::main());	precacheModel("viewhands_militia");}�&mptype/mptype_opforce_militia_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(4) )	{	case 0:		character\mp_character_militia_smg_aa_blk::main();		break;	case 1:		character\mp_character_militia_smg_aa_wht::main();		break;	case 2:		character\mp_character_militia_smg_ab_blk::main();		break;	case 3:		character\mp_character_militia_smg_ac_blk::main();		break;	}}precache(){	character\mp_character_militia_smg_aa_blk::precache();	character\mp_character_militia_smg_aa_wht::precache();	character\mp_character_militia_smg_ab_blk::precache();	character\mp_character_militia_smg_ac_blk::precache();}.character/mp_character_militia_smg_aa_blk.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_militia_smg_aa_blk");	codescripts\character::attachHead( "alias_opforce_militia_heads_blk", xmodelalias\alias_opforce_militia_heads_blk::main() );	self setViewmodel("viewhands_militia");	self.voice = "portuguese";}precache(){	precacheModel("mp_body_militia_smg_aa_blk");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_militia_heads_blk::main());	precacheModel("viewhands_militia");}.character/mp_character_militia_smg_aa_wht.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_militia_smg_aa_wht");	codescripts\character::attachHead( "alias_opforce_militia_heads_wht", xmodelalias\alias_opforce_militia_heads_wht::main() );	self setViewmodel("viewhands_militia");	self.voice = "portuguese";}precache(){	precacheModel("mp_body_militia_smg_aa_wht");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_militia_heads_wht::main());	precacheModel("viewhands_militia");}.character/mp_character_militia_smg_ab_blk.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_militia_smg_ab_blk");	codescripts\character::attachHead( "alias_opforce_militia_heads_blk", xmodelalias\alias_opforce_militia_heads_blk::main() );	self setViewmodel("viewhands_militia");	self.voice = "portuguese";}precache(){	precacheModel("mp_body_militia_smg_ab_blk");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_militia_heads_blk::main());	precacheModel("viewhands_militia");}.character/mp_character_militia_smg_ac_blk.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_militia_smg_ac_blk");	codescripts\character::attachHead( "alias_opforce_militia_heads_blk", xmodelalias\alias_opforce_militia_heads_blk::main() );	self setViewmodel("viewhands_militia");	self.voice = "portuguese";}precache(){	precacheModel("mp_body_militia_smg_ac_blk");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_militia_heads_blk::main());	precacheModel("viewhands_militia");}�)mptype/mptype_opforce_militia_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_op_militia_sniper::main();}precache(){	character\mp_character_op_militia_sniper::precache();}�-character/mp_character_op_militia_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_op_miltia_sniper");	self attach("head_op_militia_sniper", "", true);	self.headModel = "head_op_militia_sniper";	self setViewmodel("viewhands_militia");	self.voice = "portuguese";}precache(){	precacheModel("mp_body_op_miltia_sniper");	precacheModel("head_op_militia_sniper");	precacheModel("viewhands_militia");}�'mptype/mptype_opforce_militia_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_op_militia_riot::main();}precache(){	character\mp_character_op_militia_riot::precache();}�+character/mp_character_op_militia_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_riot_op_militia");	self attach("head_riot_op_militia", "", true);	self.headModel = "head_riot_op_militia";	self setViewmodel("viewhands_militia");	self.voice = "portuguese";}precache(){	precacheModel("mp_body_riot_op_militia");	precacheModel("head_riot_op_militia");	precacheModel("viewhands_militia");}@ mptype/mptype_socom_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(5) )	{	case 0:		character\mp_character_seal_socom_assault_a::main();		break;	case 1:		character\mp_character_seal_socom_assault_b::main();		break;	case 2:		character\mp_character_seal_socom_assault_b_blk::main();		break;	case 3:		character\mp_character_seal_socom_assault_c::main();		break;	case 4:		character\mp_character_seal_socom_assault_d::main();		break;	}}precache(){	character\mp_character_seal_socom_assault_a::precache();	character\mp_character_seal_socom_assault_b::precache();	character\mp_character_seal_socom_assault_b_blk::precache();	character\mp_character_seal_socom_assault_c::precache();	character\mp_character_seal_socom_assault_d::precache();}0character/mp_character_seal_socom_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_seal_soccom_assault_a");	codescripts\character::attachHead( "alias_seal_soccom_heads_mp", xmodelalias\alias_seal_soccom_heads_mp::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_seal_soccom_assault_a");	codescripts\character::precacheModelArray(xmodelalias\alias_seal_soccom_heads_mp::main());	precacheModel("viewhands_us_army");}�+xmodelalias/alias_seal_soccom_heads_mp.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "head_seal_soccom_a";	a[1] = "head_seal_soccom_ba";	a[2] = "head_seal_soccom_ca";	return a;}0character/mp_character_seal_socom_assault_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_seal_soccom_assault_b");	codescripts\character::attachHead( "alias_seal_soccom_heads_mp", xmodelalias\alias_seal_soccom_heads_mp::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_seal_soccom_assault_b");	codescripts\character::precacheModelArray(xmodelalias\alias_seal_soccom_heads_mp::main());	precacheModel("viewhands_us_army");}*4character/mp_character_seal_socom_assault_b_blk.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_seal_soccom_assault_b_blk");	codescripts\character::attachHead( "alias_seal_soccom_heads_mp_blk", xmodelalias\alias_seal_soccom_heads_mp_blk::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_seal_soccom_assault_b_blk");	codescripts\character::precacheModelArray(xmodelalias\alias_seal_soccom_heads_mp_blk::main());	precacheModel("viewhands_us_army");}�/xmodelalias/alias_seal_soccom_heads_mp_blk.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "head_seal_soccom_da";	return a;}0character/mp_character_seal_socom_assault_c.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_seal_soccom_assault_c");	codescripts\character::attachHead( "alias_seal_soccom_heads_mp", xmodelalias\alias_seal_soccom_heads_mp::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_seal_soccom_assault_c");	codescripts\character::precacheModelArray(xmodelalias\alias_seal_soccom_heads_mp::main());	precacheModel("viewhands_us_army");}0character/mp_character_seal_socom_assault_d.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_seal_soccom_assault_d");	codescripts\character::attachHead( "alias_seal_soccom_heads_mp", xmodelalias\alias_seal_soccom_heads_mp::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_seal_soccom_assault_d");	codescripts\character::precacheModelArray(xmodelalias\alias_seal_soccom_heads_mp::main());	precacheModel("viewhands_us_army");}�mptype/mptype_socom_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(6) )	{	case 0:		character\mp_character_seal_socom_assault_a::main();		break;	case 1:		character\mp_character_seal_socom_assault_b::main();		break;	case 2:		character\mp_character_seal_socom_assault_b_blk::main();		break;	case 3:		character\mp_character_seal_socom_assault_c::main();		break;	case 4:		character\mp_character_seal_socom_assault_c_blk::main();		break;	case 5:		character\mp_character_seal_socom_assault_d::main();		break;	}}precache(){	character\mp_character_seal_socom_assault_a::precache();	character\mp_character_seal_socom_assault_b::precache();	character\mp_character_seal_socom_assault_b_blk::precache();	character\mp_character_seal_socom_assault_c::precache();	character\mp_character_seal_socom_assault_c_blk::precache();	character\mp_character_seal_socom_assault_d::precache();}*4character/mp_character_seal_socom_assault_c_blk.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_seal_soccom_assault_c_blk");	codescripts\character::attachHead( "alias_seal_soccom_heads_mp_blk", xmodelalias\alias_seal_soccom_heads_mp_blk::main() );	self setViewmodel("viewhands_us_army");	self.voice = "american";}precache(){	precacheModel("mp_body_seal_soccom_assault_c_blk");	codescripts\character::precacheModelArray(xmodelalias\alias_seal_soccom_heads_mp_blk::main());	precacheModel("viewhands_us_army");}@ mptype/mptype_socom_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(5) )	{	case 0:		character\mp_character_seal_socom_assault_a::main();		break;	case 1:		character\mp_character_seal_socom_assault_b::main();		break;	case 2:		character\mp_character_seal_socom_assault_c::main();		break;	case 3:		character\mp_character_seal_socom_assault_c_blk::main();		break;	case 4:		character\mp_character_seal_socom_assault_d::main();		break;	}}precache(){	character\mp_character_seal_socom_assault_a::precache();	character\mp_character_seal_socom_assault_b::precache();	character\mp_character_seal_socom_assault_c::precache();	character\mp_character_seal_socom_assault_c_blk::precache();	character\mp_character_seal_socom_assault_d::precache();}�mptype/mptype_socom_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(6) )	{	case 0:		character\mp_character_seal_socom_assault_a::main();		break;	case 1:		character\mp_character_seal_socom_assault_b::main();		break;	case 2:		character\mp_character_seal_socom_assault_b_blk::main();		break;	case 3:		character\mp_character_seal_socom_assault_c::main();		break;	case 4:		character\mp_character_seal_socom_assault_c_blk::main();		break;	case 5:		character\mp_character_seal_socom_assault_d::main();		break;	}}precache(){	character\mp_character_seal_socom_assault_a::precache();	character\mp_character_seal_socom_assault_b::precache();	character\mp_character_seal_socom_assault_b_blk::precache();	character\mp_character_seal_socom_assault_c::precache();	character\mp_character_seal_socom_assault_c_blk::precache();	character\mp_character_seal_socom_assault_d::precache();}�mptype/mptype_socom_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(6) )	{	case 0:		character\mp_character_seal_socom_assault_a::main();		break;	case 1:		character\mp_character_seal_socom_assault_b::main();		break;	case 2:		character\mp_character_seal_socom_assault_b_blk::main();		break;	case 3:		character\mp_character_seal_socom_assault_c::main();		break;	case 4:		character\mp_character_seal_socom_assault_c_blk::main();		break;	case 5:		character\mp_character_seal_socom_assault_d::main();		break;	}}precache(){	character\mp_character_seal_socom_assault_a::precache();	character\mp_character_seal_socom_assault_b::precache();	character\mp_character_seal_socom_assault_b_blk::precache();	character\mp_character_seal_socom_assault_c::precache();	character\mp_character_seal_socom_assault_c_blk::precache();	character\mp_character_seal_socom_assault_d::precache();}�'mptype/mptype_tf141_desert_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(2) )	{	case 0:		character\mp_character_tf_141_desert_assault_a::main();		break;	case 1:		character\mp_character_tf_141_desert_assault_b::main();		break;	}}precache(){	character\mp_character_tf_141_desert_assault_a::precache();	character\mp_character_tf_141_desert_assault_b::precache();}3character/mp_character_tf_141_desert_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_desert_tf141_assault_a");	codescripts\character::attachHead( "alias_tf141_heads_desert", xmodelalias\alias_tf141_heads_desert::main() );	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_desert_tf141_assault_a");	codescripts\character::precacheModelArray(xmodelalias\alias_tf141_heads_desert::main());	precacheModel("viewhands_tf141");}�)xmodelalias/alias_tf141_heads_desert.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "head_tf141_desert_a";	a[1] = "head_tf141_desert_b";	a[2] = "head_tf141_desert_c";	a[3] = "head_tf141_desert_d";	return a;}3character/mp_character_tf_141_desert_assault_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_desert_tf141_assault_b");	codescripts\character::attachHead( "alias_tf141_heads_desert", xmodelalias\alias_tf141_heads_desert::main() );	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_desert_tf141_assault_b");	codescripts\character::precacheModelArray(xmodelalias\alias_tf141_heads_desert::main());	precacheModel("viewhands_tf141");}�#mptype/mptype_tf141_desert_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_tf_141_desert_lmg::main();}precache(){	character\mp_character_tf_141_desert_lmg::precache();}�-character/mp_character_tf_141_desert_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_desert_tf141_lmg");	codescripts\character::attachHead( "alias_tf141_heads_desert", xmodelalias\alias_tf141_heads_desert::main() );	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_desert_tf141_lmg");	codescripts\character::precacheModelArray(xmodelalias\alias_tf141_heads_desert::main());	precacheModel("viewhands_tf141");}�#mptype/mptype_tf141_desert_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_tf_141_desert_smg::main();}precache(){	character\mp_character_tf_141_desert_smg::precache();}�-character/mp_character_tf_141_desert_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_desert_tf141_smg");	codescripts\character::attachHead( "alias_tf141_heads_desert", xmodelalias\alias_tf141_heads_desert::main() );	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_desert_tf141_smg");	codescripts\character::precacheModelArray(xmodelalias\alias_tf141_heads_desert::main());	precacheModel("viewhands_tf141");}�'mptype/mptype_tf141_desert_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_tf_141_desert_shotgun::main();}precache(){	character\mp_character_tf_141_desert_shotgun::precache();}1character/mp_character_tf_141_desert_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_desert_tf141_shotgun");	codescripts\character::attachHead( "alias_tf141_heads_desert", xmodelalias\alias_tf141_heads_desert::main() );	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_desert_tf141_shotgun");	codescripts\character::precacheModelArray(xmodelalias\alias_tf141_heads_desert::main());	precacheModel("viewhands_tf141");}�&mptype/mptype_tf141_desert_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_tf141_desert_sniper::main();}precache(){	character\mp_character_tf141_desert_sniper::precache();}�/character/mp_character_tf141_desert_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_tf141_desert_sniper");	self attach("head_allies_tf141_desert_sniper", "", true);	self.headModel = "head_allies_tf141_desert_sniper";	self setViewmodel("viewhands_sniper_tf141_desert");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_tf141_desert_sniper");	precacheModel("head_allies_tf141_desert_sniper");	precacheModel("viewhands_sniper_tf141_desert");}�$mptype/mptype_tf141_desert_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_tf141_desert_riot::main();}precache(){	character\mp_character_tf141_desert_riot::precache();}�-character/mp_character_tf141_desert_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_riot_tf141_desert");	self attach("head_riot_tf141_desert", "", true);	self.headModel = "head_riot_tf141_desert";	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_riot_tf141_desert");	precacheModel("head_riot_tf141_desert");	precacheModel("viewhands_tf141");}�'mptype/mptype_tf141_forest_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(2) )	{	case 0:		character\mp_character_tf_141_forest_assault_a::main();		break;	case 1:		character\mp_character_tf_141_forest_assault_b::main();		break;	}}precache(){	character\mp_character_tf_141_forest_assault_a::precache();	character\mp_character_tf_141_forest_assault_b::precache();}3character/mp_character_tf_141_forest_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_forest_tf141_assault_a");	codescripts\character::attachHead( "alias_tf141_heads_forest", xmodelalias\alias_tf141_heads_forest::main() );	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_forest_tf141_assault_a");	codescripts\character::precacheModelArray(xmodelalias\alias_tf141_heads_forest::main());	precacheModel("viewhands_tf141");}�)xmodelalias/alias_tf141_heads_forest.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "head_tf141_forest_a";	a[1] = "head_tf141_forest_b";	a[2] = "head_tf141_forest_c";	a[3] = "head_tf141_forest_d";	return a;}3character/mp_character_tf_141_forest_assault_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_forest_tf141_assault_b");	codescripts\character::attachHead( "alias_tf141_heads_forest", xmodelalias\alias_tf141_heads_forest::main() );	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_forest_tf141_assault_b");	codescripts\character::precacheModelArray(xmodelalias\alias_tf141_heads_forest::main());	precacheModel("viewhands_tf141");}�#mptype/mptype_tf141_forest_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_tf_141_forest_lmg::main();}precache(){	character\mp_character_tf_141_forest_lmg::precache();}�-character/mp_character_tf_141_forest_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_forest_tf141_lmg");	codescripts\character::attachHead( "alias_tf141_heads_forest", xmodelalias\alias_tf141_heads_forest::main() );	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_forest_tf141_lmg");	codescripts\character::precacheModelArray(xmodelalias\alias_tf141_heads_forest::main());	precacheModel("viewhands_tf141");}�#mptype/mptype_tf141_forest_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_tf_141_forest_smg::main();}precache(){	character\mp_character_tf_141_forest_smg::precache();}�-character/mp_character_tf_141_forest_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_forest_tf141_smg");	codescripts\character::attachHead( "alias_tf141_heads_forest", xmodelalias\alias_tf141_heads_forest::main() );	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_forest_tf141_smg");	codescripts\character::precacheModelArray(xmodelalias\alias_tf141_heads_forest::main());	precacheModel("viewhands_tf141");}�'mptype/mptype_tf141_forest_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_tf_141_forest_shotgun::main();}precache(){	character\mp_character_tf_141_forest_shotgun::precache();}1character/mp_character_tf_141_forest_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_forest_tf141_shotgun");	codescripts\character::attachHead( "alias_tf141_heads_forest", xmodelalias\alias_tf141_heads_forest::main() );	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_forest_tf141_shotgun");	codescripts\character::precacheModelArray(xmodelalias\alias_tf141_heads_forest::main());	precacheModel("viewhands_tf141");}�&mptype/mptype_tf141_forest_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_tf141_forest_sniper::main();}precache(){	character\mp_character_tf141_forest_sniper::precache();}�/character/mp_character_tf141_forest_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_tf141_forest_sniper");	self attach("head_allies_tf141_forest_sniper", "", true);	self.headModel = "head_allies_tf141_forest_sniper";	self setViewmodel("viewhands_sniper_tf141_forest");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_tf141_forest_sniper");	precacheModel("head_allies_tf141_forest_sniper");	precacheModel("viewhands_sniper_tf141_forest");}�$mptype/mptype_tf141_forest_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_tf141_forest_riot::main();}precache(){	character\mp_character_tf141_forest_riot::precache();}�-character/mp_character_tf141_forest_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_riot_tf141_forest");	self attach("head_riot_tf141_forest", "", true);	self.headModel = "head_riot_tf141_forest";	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_riot_tf141_forest");	precacheModel("head_riot_tf141_forest");	precacheModel("viewhands_tf141");}�'mptype/mptype_tf141_arctic_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	switch( codescripts\character::get_random_character(2) )	{	case 0:		character\mp_character_tf_141_arctic_assault_a::main();		break;	case 1:		character\mp_character_tf_141_arctic_assault_b::main();		break;	}}precache(){	character\mp_character_tf_141_arctic_assault_a::precache();	character\mp_character_tf_141_arctic_assault_b::precache();}3character/mp_character_tf_141_arctic_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_tf141_assault_a");	codescripts\character::attachHead( "alias_tf141_heads_arctic", xmodelalias\alias_tf141_heads_arctic::main() );	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_tf141_assault_a");	codescripts\character::precacheModelArray(xmodelalias\alias_tf141_heads_arctic::main());	precacheModel("viewhands_tf141");}�)xmodelalias/alias_tf141_heads_arctic.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "head_tf141_arctic_a";	a[1] = "head_tf141_arctic_b";	a[2] = "head_tf141_arctic_c";	a[3] = "head_tf141_arctic_d";	return a;}3character/mp_character_tf_141_arctic_assault_b.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_tf141_assault_b");	codescripts\character::attachHead( "alias_tf141_heads_arctic", xmodelalias\alias_tf141_heads_arctic::main() );	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_tf141_assault_b");	codescripts\character::precacheModelArray(xmodelalias\alias_tf141_heads_arctic::main());	precacheModel("viewhands_tf141");}�#mptype/mptype_tf141_arctic_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_tf_141_arctic_lmg::main();}precache(){	character\mp_character_tf_141_arctic_lmg::precache();}�-character/mp_character_tf_141_arctic_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_tf141_lmg");	codescripts\character::attachHead( "alias_tf141_heads_arctic", xmodelalias\alias_tf141_heads_arctic::main() );	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_tf141_lmg");	codescripts\character::precacheModelArray(xmodelalias\alias_tf141_heads_arctic::main());	precacheModel("viewhands_tf141");}�#mptype/mptype_tf141_arctic_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_tf_141_arctic_smg::main();}precache(){	character\mp_character_tf_141_arctic_smg::precache();}�-character/mp_character_tf_141_arctic_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_tf141_smg");	codescripts\character::attachHead( "alias_tf141_heads_arctic", xmodelalias\alias_tf141_heads_arctic::main() );	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_tf141_smg");	codescripts\character::precacheModelArray(xmodelalias\alias_tf141_heads_arctic::main());	precacheModel("viewhands_tf141");}�'mptype/mptype_tf141_arctic_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_tf_141_arctic_shotgun::main();}precache(){	character\mp_character_tf_141_arctic_shotgun::precache();}�1character/mp_character_tf_141_arctic_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_tf141_shotgun");	codescripts\character::attachHead( "alias_tf141_heads_arctic", xmodelalias\alias_tf141_heads_arctic::main() );	self setViewmodel("viewhands_tf141");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_tf141_shotgun");	codescripts\character::precacheModelArray(xmodelalias\alias_tf141_heads_arctic::main());	precacheModel("viewhands_tf141");}�&mptype/mptype_tf141_arctic_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_tf141_arctic_sniper::main();}precache(){	character\mp_character_tf141_arctic_sniper::precache();}�/character/mp_character_tf141_arctic_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_tf141_arctic_sniper");	self attach("head_allies_tf141_arctic_sniper", "", true);	self.headModel = "head_allies_tf141_arctic_sniper";	self setViewmodel("viewhands_sniper_tf141_arctic");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_tf141_arctic_sniper");	precacheModel("head_allies_tf141_arctic_sniper");	precacheModel("viewhands_sniper_tf141_arctic");}�$mptype/mptype_tf141_arctic_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_character_tf141_arctic_riot::main();}precache(){	character\mp_character_tf141_arctic_riot::precache();}�-character/mp_character_tf141_arctic_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_body_riot_tf141_arctic");	self attach("head_riot_tf141_arctic", "", true);	self.headModel = "head_riot_tf141_arctic";	self setViewmodel("viewhands_arctic");	self.voice = "taskforce";}precache(){	precacheModel("mp_body_riot_tf141_arctic");	precacheModel("head_riot_tf141_arctic");	precacheModel("viewhands_arctic");}�"mptype/mptype_nx_us_space_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_space_assault_a::main();}precache(){	character\mp_nx_character_us_space_assault_a::precache();}�#mptype/mptype_nx_us_space_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_space_assault_a::main();}precache(){	character\mp_nx_character_us_space_assault_a::precache();}�&mptype/mptype_nx_us_space_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_space_assault_a::main();}precache(){	character\mp_nx_character_us_space_assault_a::precache();}�"mptype/mptype_nx_us_space_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_space_assault_a::main();}precache(){	character\mp_nx_character_us_space_assault_a::precache();}�%mptype/mptype_nx_us_space_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_space_assault_a::main();}precache(){	character\mp_nx_character_us_space_assault_a::precache();}�"mptype/mptype_nx_ec_space_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_space_assault_a::main();}precache(){	character\mp_nx_character_china_space_assault_a::precache();}�#mptype/mptype_nx_ec_space_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_space_assault_a::main();}precache(){	character\mp_nx_character_china_space_assault_a::precache();}�&mptype/mptype_nx_ec_space_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_space_assault_a::main();}precache(){	character\mp_nx_character_china_space_assault_a::precache();}�"mptype/mptype_nx_ec_space_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_space_assault_a::main();}precache(){	character\mp_nx_character_china_space_assault_a::precache();}�%mptype/mptype_nx_ec_space_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_space_assault_a::main();}precache(){	character\mp_nx_character_china_space_assault_a::precache();}�%mptype/mptype_nx_us_pres_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_pres_assault_a::main();}precache(){	character\mp_nx_character_us_pres_assault_a::precache();}0character/mp_nx_character_us_pres_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_nx_us_space_assault_body");	codescripts\character::attachHead( "alias_nx_us_pres_heads", xmodelalias\alias_nx_us_pres_heads::main() );	self setViewmodel("viewhands_us_lunar");	self.voice = "american";}precache(){	precacheModel("mp_nx_us_space_assault_body");	codescripts\character::precacheModelArray(xmodelalias\alias_nx_us_pres_heads::main());	precacheModel("viewhands_us_lunar");}='xmodelalias/alias_nx_us_pres_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "nx_us_space_assault_head_a";	a[1] = "nx_hero_charlie_head";	a[2] = "nx_us_secretservice_head_a";	a[3] = "nx_us_secretservice_head_b";	a[4] = "nx_us_secretservice_head_c";	a[5] = "nx_hero_vp_head";	return a;}�!mptype/mptype_nx_us_pres_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_pres_assault_a::main();}precache(){	character\mp_nx_character_us_pres_assault_a::precache();}�"mptype/mptype_nx_us_pres_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_pres_assault_a::main();}precache(){	character\mp_nx_character_us_pres_assault_a::precache();}�%mptype/mptype_nx_us_pres_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_pres_assault_a::main();}precache(){	character\mp_nx_character_us_pres_assault_a::precache();}�!mptype/mptype_nx_us_pres_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_pres_assault_a::main();}precache(){	character\mp_nx_character_us_pres_assault_a::precache();}�$mptype/mptype_nx_us_pres_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_pres_assault_a::main();}precache(){	character\mp_nx_character_us_pres_assault_a::precache();}�%mptype/mptype_nx_us_pres_stealth.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_pres_assault_a::main();}precache(){	character\mp_nx_character_us_pres_assault_a::precache();}�%mptype/mptype_nx_ec_pres_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_pres_assault_a::main();}precache(){	character\mp_nx_character_china_pres_assault_a::precache();} 3character/mp_nx_character_china_pres_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_nx_china_space_assault_body");	codescripts\character::attachHead( "alias_nx_china_pres_heads", xmodelalias\alias_nx_china_pres_heads::main() );	self setViewmodel("viewhands_chinese_lunar");	self.voice = "american";}precache(){	precacheModel("mp_nx_china_space_assault_body");	codescripts\character::precacheModelArray(xmodelalias\alias_nx_china_pres_heads::main());	precacheModel("viewhands_chinese_lunar");}!*xmodelalias/alias_nx_china_pres_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "nx_russian_head_a";	a[1] = "nx_russian_head_b";	a[2] = "nx_russian_head_c";	a[3] = "nx_russian_head_d";	a[4] = "nx_head_turks_army_a";	a[5] = "nx_head_turks_army_b";	return a;}�!mptype/mptype_nx_ec_pres_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_pres_assault_a::main();}precache(){	character\mp_nx_character_china_pres_assault_a::precache();}�"mptype/mptype_nx_ec_pres_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_pres_assault_a::main();}precache(){	character\mp_nx_character_china_pres_assault_a::precache();}�%mptype/mptype_nx_ec_pres_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_pres_assault_a::main();}precache(){	character\mp_nx_character_china_pres_assault_a::precache();}�!mptype/mptype_nx_ec_pres_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_pres_assault_a::main();}precache(){	character\mp_nx_character_china_pres_assault_a::precache();}�$mptype/mptype_nx_ec_pres_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_pres_assault_a::main();}precache(){	character\mp_nx_character_china_pres_assault_a::precache();}�%mptype/mptype_nx_ec_pres_stealth.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_pres_assault_a::main();}precache(){	character\mp_nx_character_china_pres_assault_a::precache();}�(mptype/mptype_nx_us_specops_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_specops_assault_a::main();}precache(){	character\mp_nx_character_us_specops_assault_a::precache();}3character/mp_nx_character_us_specops_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_nx_us_specops_body_assault_a");	codescripts\character::attachHead( "alias_nx_us_specops_heads", xmodelalias\alias_nx_us_specops_heads::main() );	self setViewmodel("viewhands_us_specops");	self.voice = "american";}precache(){	precacheModel("mp_nx_us_specops_body_assault_a");	codescripts\character::precacheModelArray(xmodelalias\alias_nx_us_specops_heads::main());	precacheModel("viewhands_us_specops");}�*xmodelalias/alias_nx_us_specops_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "nx_us_specops_head_a";	a[1] = "nx_us_specops_head_b";	a[2] = "nx_us_specops_head_c";	return a;}�$mptype/mptype_nx_us_specops_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_specops_assault_a::main();}precache(){	character\mp_nx_character_us_specops_assault_a::precache();}�%mptype/mptype_nx_us_specops_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_specops_assault_a::main();}precache(){	character\mp_nx_character_us_specops_assault_a::precache();}�(mptype/mptype_nx_us_specops_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_specops_assault_a::main();}precache(){	character\mp_nx_character_us_specops_assault_a::precache();}�$mptype/mptype_nx_us_specops_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_specops_assault_a::main();}precache(){	character\mp_nx_character_us_specops_assault_a::precache();}�'mptype/mptype_nx_us_specops_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_specops_assault_a::main();}precache(){	character\mp_nx_character_us_specops_assault_a::precache();}�(mptype/mptype_nx_us_specops_stealth.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_specops_assault_a::main();}precache(){	character\mp_nx_character_us_specops_assault_a::precache();}�(mptype/mptype_nx_ec_specops_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_spec_assault_a::main();}precache(){	character\mp_nx_character_china_spec_assault_a::precache();}+3character/mp_nx_character_china_spec_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_nx_china_specops_body_assault_a");	codescripts\character::attachHead( "alias_nx_china_specops_heads", xmodelalias\alias_nx_china_specops_heads::main() );	self setViewmodel("viewhands_us_specops");	self.voice = "american";}precache(){	precacheModel("mp_nx_china_specops_body_assault_a");	codescripts\character::precacheModelArray(xmodelalias\alias_nx_china_specops_heads::main());	precacheModel("viewhands_us_specops");}�-xmodelalias/alias_nx_china_specops_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "nx_china_specops_head_a";	a[1] = "nx_china_specops_head_b";	a[2] = "nx_china_specops_head_c";	a[3] = "nx_china_specops_head_d";	return a;}�$mptype/mptype_nx_ec_specops_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_spec_assault_a::main();}precache(){	character\mp_nx_character_china_spec_assault_a::precache();}�%mptype/mptype_nx_ec_specops_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_spec_assault_a::main();}precache(){	character\mp_nx_character_china_spec_assault_a::precache();}�(mptype/mptype_nx_ec_specops_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_spec_assault_a::main();}precache(){	character\mp_nx_character_china_spec_assault_a::precache();}�$mptype/mptype_nx_ec_specops_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_spec_assault_a::main();}precache(){	character\mp_nx_character_china_spec_assault_a::precache();}�'mptype/mptype_nx_ec_specops_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_spec_assault_a::main();}precache(){	character\mp_nx_character_china_spec_assault_a::precache();}�(mptype/mptype_nx_ec_specops_stealth.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_spec_assault_a::main();}precache(){	character\mp_nx_character_china_spec_assault_a::precache();}�%mptype/mptype_nx_us_army_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_army_assault_a::main();}precache(){	character\mp_nx_character_us_army_assault_a::precache();}a0character/mp_nx_character_us_army_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	codescripts\character::setModelFromArray(xmodelalias\alias_mp_nx_us_army_bodies::main());	codescripts\character::attachHead( "alias_nx_us_army_heads", xmodelalias\alias_nx_us_army_heads::main() );	self setViewmodel("viewhands_nx_us_army");	self.voice = "american";}precache(){	codescripts\character::precacheModelArray(xmodelalias\alias_mp_nx_us_army_bodies::main());	codescripts\character::precacheModelArray(xmodelalias\alias_nx_us_army_heads::main());	precacheModel("viewhands_nx_us_army");}�+xmodelalias/alias_mp_nx_us_army_bodies.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "mp_nx_us_army_body_assault_a";	return a;}�'xmodelalias/alias_nx_us_army_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "nx_hero_bravolead_head";	return a;}�!mptype/mptype_nx_us_army_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_army_assault_a::main();}precache(){	character\mp_nx_character_us_army_assault_a::precache();}�"mptype/mptype_nx_us_army_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_army_assault_a::main();}precache(){	character\mp_nx_character_us_army_assault_a::precache();}�%mptype/mptype_nx_us_army_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_army_assault_a::main();}precache(){	character\mp_nx_character_us_army_assault_a::precache();}�!mptype/mptype_nx_us_army_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_army_assault_a::main();}precache(){	character\mp_nx_character_us_army_assault_a::precache();}�$mptype/mptype_nx_us_army_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_army_assault_a::main();}precache(){	character\mp_nx_character_us_army_assault_a::precache();}�%mptype/mptype_nx_us_army_stealth.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_army_assault_a::main();}precache(){	character\mp_nx_character_us_army_assault_a::precache();}�%mptype/mptype_nx_ec_army_assault.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_assault_a::main();}precache(){	character\mp_nx_character_china_assault_a::precache();}
.character/mp_nx_character_china_assault_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_china_army_body_assault_a");	codescripts\character::attachHead( "alias_nx_china_army_heads", xmodelalias\alias_nx_china_army_heads::main() );	self setViewmodel("viewhands_us_specops");	self.voice = "arab";}precache(){	precacheModel("mp_china_army_body_assault_a");	codescripts\character::precacheModelArray(xmodelalias\alias_nx_china_army_heads::main());	precacheModel("viewhands_us_specops");}�*xmodelalias/alias_nx_china_army_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "nx_china_head_a";	a[1] = "nx_china_head_b";	a[2] = "nx_china_head_c";	a[3] = "nx_china_head_d";	return a;}�!mptype/mptype_nx_ec_army_lmg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_assault_a::main();}precache(){	character\mp_nx_character_china_assault_a::precache();}�"mptype/mptype_nx_ec_army_riot.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_assault_a::main();}precache(){	character\mp_nx_character_china_assault_a::precache();}�%mptype/mptype_nx_ec_army_shotgun.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_assault_a::main();}precache(){	character\mp_nx_character_china_assault_a::precache();}�!mptype/mptype_nx_ec_army_smg.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_assault_a::main();}precache(){	character\mp_nx_character_china_assault_a::precache();}�$mptype/mptype_nx_ec_army_sniper.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_assault_a::main();}precache(){	character\mp_nx_character_china_assault_a::precache();}�%mptype/mptype_nx_ec_army_stealth.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_china_assault_a::main();}precache(){	character\mp_nx_character_china_assault_a::precache();}�mptype/mptype_nx_us_ss.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_secretservice_a::main();}precache(){	character\mp_nx_character_us_secretservice_a::precache();}�1character/mp_nx_character_us_secretservice_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	codescripts\character::setModelFromArray(xmodelalias\alias_mp_nx_us_secretservice_bodies::main());	codescripts\character::attachHead( "alias_mp_nx_us_secretservice_heads", xmodelalias\alias_mp_nx_us_secretservice_heads::main() );	self setViewmodel("viewhands_airport");	self.voice = "american";}precache(){	codescripts\character::precacheModelArray(xmodelalias\alias_mp_nx_us_secretservice_bodies::main());	codescripts\character::precacheModelArray(xmodelalias\alias_mp_nx_us_secretservice_heads::main());	precacheModel("viewhands_airport");}�4xmodelalias/alias_mp_nx_us_secretservice_bodies.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "mp_nx_us_secretservice_body_a";	a[1] = "mp_nx_us_secretservice_body_b";	a[2] = "mp_nx_us_secretservice_body_c";	return a;}�3xmodelalias/alias_mp_nx_us_secretservice_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "mp_nx_us_secretservice_head_a";	a[1] = "mp_nx_us_secretservice_head_b";	a[2] = "mp_nx_us_secretservice_head_c";	return a;}� mptype/mptype_nx_ec_gazelle.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_ec_marathon_a::main();}precache(){	character\mp_nx_character_ec_marathon_a::precache();},character/mp_nx_character_ec_marathon_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_nx_ec_marathon_body");	codescripts\character::attachHead( "alias_mp_nx_ec_marathon_heads", xmodelalias\alias_mp_nx_ec_marathon_heads::main() );	self setViewmodel("viewhands_us_specops");	self.voice = "american";}precache(){	precacheModel("mp_nx_ec_marathon_body");	codescripts\character::precacheModelArray(xmodelalias\alias_mp_nx_ec_marathon_heads::main());	precacheModel("viewhands_us_specops");}�.xmodelalias/alias_mp_nx_ec_marathon_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "mp_nx_ec_marathon_head_a";	return a;}�mptype/mptype_nx_ec_hulc.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_ec_hulc_a::main();}precache(){	character\mp_nx_character_ec_hulc_a::precache();}�(character/mp_nx_character_ec_hulc_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_nx_ec_hulc_body");	codescripts\character::attachHead( "alias_mp_nx_ec_hulc_heads", xmodelalias\alias_mp_nx_ec_hulc_heads::main() );	self setViewmodel("viewhands_us_specops");	self.voice = "american";}precache(){	precacheModel("mp_nx_ec_hulc_body");	codescripts\character::precacheModelArray(xmodelalias\alias_mp_nx_ec_hulc_heads::main());	precacheModel("viewhands_us_specops");}�*xmodelalias/alias_mp_nx_ec_hulc_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "mp_nx_ec_hulc_head_a";	return a;}�#mptype/mptype_nx_ec_juggernaut.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_ec_trophy_a::main();}precache(){	character\mp_nx_character_ec_trophy_a::precache();}*character/mp_nx_character_ec_trophy_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_nx_ec_trophy_body");	codescripts\character::attachHead( "alias_mp_nx_ec_trophy_heads", xmodelalias\alias_mp_nx_ec_trophy_heads::main() );	self setViewmodel("viewhands_us_specops");	self.voice = "american";}precache(){	precacheModel("mp_nx_ec_trophy_body");	codescripts\character::precacheModelArray(xmodelalias\alias_mp_nx_ec_trophy_heads::main());	precacheModel("viewhands_us_specops");}�,xmodelalias/alias_mp_nx_ec_trophy_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "mp_nx_ec_trophy_head_a";	return a;}�mptype/mptype_nx_ec_smart.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_ec_hardline_a::main();}precache(){	character\mp_nx_character_ec_hardline_a::precache();},character/mp_nx_character_ec_hardline_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_nx_ec_hardline_body");	codescripts\character::attachHead( "alias_mp_nx_ec_hardline_heads", xmodelalias\alias_mp_nx_ec_hardline_heads::main() );	self setViewmodel("viewhands_us_specops");	self.voice = "american";}precache(){	precacheModel("mp_nx_ec_hardline_body");	codescripts\character::precacheModelArray(xmodelalias\alias_mp_nx_ec_hardline_heads::main());	precacheModel("viewhands_us_specops");}�.xmodelalias/alias_mp_nx_ec_hardline_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "mp_nx_ec_hardline_head_a";	return a;}� mptype/mptype_nx_ec_spectre.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_ec_ninja_a::main();}precache(){	character\mp_nx_character_ec_ninja_a::precache();}�)character/mp_nx_character_ec_ninja_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_nx_ec_ninja_body");	codescripts\character::attachHead( "alias_mp_nx_ec_ninja_heads", xmodelalias\alias_mp_nx_ec_ninja_heads::main() );	self setViewmodel("viewhands_us_specops");	self.voice = "american";}precache(){	precacheModel("mp_nx_ec_ninja_body");	codescripts\character::precacheModelArray(xmodelalias\alias_mp_nx_ec_ninja_heads::main());	precacheModel("viewhands_us_specops");}�+xmodelalias/alias_mp_nx_ec_ninja_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "mp_nx_ec_ninja_head_a";	a[1] = "mp_nx_ec_ninja_head_b";	return a;}� mptype/mptype_nx_us_gazelle.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_marathon_a::main();}precache(){	character\mp_nx_character_us_marathon_a::precache();},character/mp_nx_character_us_marathon_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_nx_us_marathon_body");	codescripts\character::attachHead( "alias_mp_nx_us_marathon_heads", xmodelalias\alias_mp_nx_us_marathon_heads::main() );	self setViewmodel("viewhands_us_specops");	self.voice = "american";}precache(){	precacheModel("mp_nx_us_marathon_body");	codescripts\character::precacheModelArray(xmodelalias\alias_mp_nx_us_marathon_heads::main());	precacheModel("viewhands_us_specops");}�.xmodelalias/alias_mp_nx_us_marathon_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "mp_nx_us_marathon_head_a";	return a;}�mptype/mptype_nx_us_hulc.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_hulc_a::main();}precache(){	character\mp_nx_character_us_hulc_a::precache();}�(character/mp_nx_character_us_hulc_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_nx_us_hulc_body");	codescripts\character::attachHead( "alias_mp_nx_us_hulc_heads", xmodelalias\alias_mp_nx_us_hulc_heads::main() );	self setViewmodel("viewhands_us_specops");	self.voice = "american";}precache(){	precacheModel("mp_nx_us_hulc_body");	codescripts\character::precacheModelArray(xmodelalias\alias_mp_nx_us_hulc_heads::main());	precacheModel("viewhands_us_specops");}�*xmodelalias/alias_mp_nx_us_hulc_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "mp_nx_us_hulc_head_a";	return a;}�#mptype/mptype_nx_us_juggernaut.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_trophy_a::main();}precache(){	character\mp_nx_character_us_trophy_a::precache();}*character/mp_nx_character_us_trophy_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_nx_us_trophy_body");	codescripts\character::attachHead( "alias_mp_nx_us_trophy_heads", xmodelalias\alias_mp_nx_us_trophy_heads::main() );	self setViewmodel("viewhands_us_specops");	self.voice = "american";}precache(){	precacheModel("mp_nx_us_trophy_body");	codescripts\character::precacheModelArray(xmodelalias\alias_mp_nx_us_trophy_heads::main());	precacheModel("viewhands_us_specops");}�,xmodelalias/alias_mp_nx_us_trophy_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "mp_nx_us_trophy_head_a";	return a;}�mptype/mptype_nx_us_smart.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_hardline_a::main();}precache(){	character\mp_nx_character_us_hardline_a::precache();},character/mp_nx_character_us_hardline_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_nx_us_hardline_body");	codescripts\character::attachHead( "alias_mp_nx_us_hardline_heads", xmodelalias\alias_mp_nx_us_hardline_heads::main() );	self setViewmodel("viewhands_us_specops");	self.voice = "american";}precache(){	precacheModel("mp_nx_us_hardline_body");	codescripts\character::precacheModelArray(xmodelalias\alias_mp_nx_us_hardline_heads::main());	precacheModel("viewhands_us_specops");}�.xmodelalias/alias_mp_nx_us_hardline_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "mp_nx_us_hardline_head_a";	return a;}� mptype/mptype_nx_us_spectre.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	character\mp_nx_character_us_ninja_a::main();}precache(){	character\mp_nx_character_us_ninja_a::precache();}�)character/mp_nx_character_us_ninja_a.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	self setModel("mp_nx_us_ninja_body");	codescripts\character::attachHead( "alias_mp_nx_us_ninja_heads", xmodelalias\alias_mp_nx_us_ninja_heads::main() );	self setViewmodel("viewhands_us_specops");	self.voice = "american";}precache(){	precacheModel("mp_nx_us_ninja_body");	codescripts\character::precacheModelArray(xmodelalias\alias_mp_nx_us_ninja_heads::main());	precacheModel("viewhands_us_specops");}�+xmodelalias/alias_mp_nx_us_ninja_heads.gsc// THIS FILE IS AUTOGENERATED, DO NOT MODIFYmain(){	a[0] = "mp_nx_us_ninja_head_a";	a[1] = "mp_nx_us_ninja_head_b";	return a;},�maps/mp/_gasgrenades.gsc
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
	
	level._empInitialBlastTime = getDvarInt( "scr_empInitialEffectDuration", "10");
	level._empCloudTickTime = getDvarInt( "scr_empTickEffectDuration", "3");

	level._gasCloudDuration = getDvarInt( "scr_gasCloudDuration", "9");
	level._gasCloudRadius = getDvarInt( "scr_gasCloudRadius", "185");
	level._gasCloudHeight = getDvarInt( "scr_gasCloudHeight", "20");
	level._gasCloudTickDamage = getDvarInt( "scr_gasCloudTickDamage", "13");
	level._gasCloudTickDamageHardcore = getDvarInt( "scr_gasCloudTickDamageHardcore", "5");

	level._empCloudDuration = getDvarInt( "scr_empCloudDuration", "9");
	level._empCloudRadius = getDvarInt( "scr_empCloudRadius", "185");
	level._empCloudHeight = getDvarInt( "scr_empCloudHeight", "20");
	level._empCloudTickDamage = getDvarInt( "scr_empCloudTickDamage", "1");

	level._gasCloudList = [];
	level._empCloudList = [];
}

increaseEmpCloudedTime( amount )
{
	self.empCloudedTime += amount;
}

watchEmpClouded()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	self.empCloudedTime = 0.0;
	empCloudDeltaTime = 0.5;
	
	for(;;)
	{
		self waittill( "emp_cloud_update" );

		self playLocalSound( "emp_activate" );

		if ( self _hasPerk( "specialty_localjammer" ))
			self RadarJamOff();

		self setEMPJammed( true );

		//wait for the decay to finish
		while( self.empCloudedTime > 0 )
		{
			wait( empCloudDeltaTime );
			self.empCloudedTime -= empCloudDeltaTime;
		}

		if( self.empCLoudedTime < 0 )
		{
			self.empCloudedTime = 0;
		}

		//tagZP<NOTE> this should probably make sure that my team is not emp'd so that i do not turn off fx from the killstreak.
		self setEMPJammed( false );
	
		if ( self _hasPerk( "specialty_localjammer" ))
			self RadarJamOn();
	}
}

AddCloudToGasList( cloud )
{	
	list = level._gasCloudList;
	list[ list.size ] = cloud;
	level._gasCloudList = list;
}

RemoveCloudFromGasList( cloud )
{	
	newArray = [];
	for( i = 0; i < level._gasCloudList.size; i++ )
	{
		if( level._gasCloudList[i] != cloud )
		{
			newArray[ newArray.size ] = level._gasCloudList[i];
		}
	}
	level._gasCloudList = newArray;
}

AddCloudToEMPList( cloud )
{	
	list = level._empCloudList;
	list[ list.size ] = cloud;
	level._empCloudList = list;
}

RemoveCloudFromEMPList( cloud )
{
	newArray = [];
	for( i = 0; i < level._empCloudList.size; i++ )
	{
		if( level._empCloudList[i] != cloud )
		{
			newArray[ newArray.size ] = level._empCLoudList[i];
		}
	}
	level._empCloudList = newArray;
}

//used by spawnlogic to determine the safty of this spawn point.
getCloudDanger( spawner )
{
	cloudCount = 0;
	
	triggers = level._gasCloudList;

	foreach( trigger in triggers )
	{
		if( spawner isTouching( trigger ))
		{
			cloudCount++;
		}
	}

	triggers = level._empCloudList;

	foreach( trigger in triggers )
	{
		if( spawner isTouching( trigger ))
		{
			cloudCount++;
		}
	}

	return cloudCount;
}

//returns true if the entity passed in is in any enemy clouds.  Team should be passed in as my team.  anyteam that doesnt match what is passed
//in is considered enemy.  If team is not passed in all clouds are checked.
checkIsInCloud( entity, list, team )
{	
	foreach( cloud in list )
	{
		if( entity isTouching( cloud ))
		{
			if( isDefined( team ))
			{
				assert( isDefined( cloud.owner ));
				assert( isplayer( cloud.owner ));
			
				if( cloud.owner.pers["team"] != team )
				{
					return true;
				}
			}
			else
			{
				return true;
			}
		}
	}

	return false;
}

gasGrenadeExplodeWaiter( type )
{
	self endon( "end_explode" );
	team = self.owner.team;
	
	self waittill( "explode", position );
	
	cloudObj = Spawn( "script_origin", position );
	
	cloudObj.owner = self.owner;
	cloudObj.team = team;
	
	if( type == "gas" )
	{
		cloudObj thread gasCloudMonitor( level._gasCloudDuration );
	}
	else if( type == "emp" )
	{
		cloudObj thread empCloudMonitor( level._empCloudDuration );
	}
}

gasCloudMonitor( duration )
{
	//self endon( "death" );
	position = self.origin;

	gasCloudRadius = level._gasCloudRadius;
	gasCloudHeight = level._gasCloudHeight;
	gasCloudTickDamage = level._gasCloudTickDamage;

	if ( level._hardcoreMode )
	{
		gasCloudTickDamage = level._gasCloudTickDamageHardcore;
	} 

	// spawn trigger radius for the effect areas
	gasEffectArea = spawn( "trigger_radius", position, 0, gasCloudRadius, gasCloudHeight );
	gasEffectArea.owner = self.owner;
	AddCloudToGasList( gasEffectArea );
	
	gasTotalTime = 0.0;		// keeps track of the total time the gas cloud has been "alive"
	gasTickTime = 1.0;		// gas cloud ticks damage every second
	gasInitialWait = 1.5;	// wait this long before the cloud starts ticking for damage
	gasTickCounter = 0;		// just an internal counter to count gas damage ticks
	
	wait( gasInitialWait );
	gasTotalTime += gasInitialWait;
	
	for( ;; )
	{
		if( gasTotalTime >= duration )
		{
			break;
		}
		
		//send out some radial damage
		//RadiusDamage( self.origin, gasCloudRadius, gasCloudTickDamageMax, gasCloudTickDamageMin, self.owner );
		
		//apply shellshock/damage fx to players in the gas cloud
		foreach( player in level._players )
		{	
			if( level._teamBased )
			{
				if( !isDefined( player.team ))
				{
					continue;
				}
				
				if( !isDefined( self.owner ))
				{
					continue;
				}
				
				if( player.team == self.team && player != self.owner )
				{
					continue;
				}
			}

			if( player istouching( gasEffectArea ) && player.sessionstate == "playing" )
			{
				if( ! ( player _hasPerk( "specialty_gasmask" )))
				{
					trace = bullettrace( position, player.origin, false, player );
					if ( trace["fraction"] == 1 )
					{
						// NOTE: DoDamage( <health>, <source position>, <attacker>, <inflictor>, <hit-on-head>, <mod>, <dflags>, <weapon> )
						//player DoDamgae( gasCloudTickDamageMin, position, self.owner, self, 0, "MOD_GAS", 0, "gas_grenade_mp" );

						player shellShock( "gas_grenade_mp", 2 );		// Long enough...
						RadiusDamage( player.origin, 16, gasCloudTickDamage, gasCloudTickDamage, self.owner); // "MOD_GAS", "gas_grenade_mp" );

						//play coughing noise
						player PlaySoundToPlayer( "breathing_gas_hurt", player );
					}
				}
			}
		}
		
		wait( gasTickTime );
		gasTotalTime += gasTickTime;
		gasTickCounter += 1;
	}

	//clean up
	RemoveCloudFromGasList( gasEffectArea );
	gasEffectArea delete();
	
	self delete();
}

empCloudMonitor( duration )
{
	//self endon( "death" );

	assert( isDefined( self.owner ));

	empEffectArea = spawn( "trigger_radius", self.origin, 0, level._empCloudRadius, level._empCloudHeight );
	empEffectArea.owner = self.owner;
	AddCloudToEMPList( empEffectArea );

	empCloudGrenadeInitialBlast( empEffectArea, self.owner );

	//println( "added emp cloud to list, size = " + level._empCloudList.size );
	
	empTotalTime = 0.0;		// keeps track of the total time the emp cloud has been "alive"
	empTickTime = 1.0;		// emp cloud ticks damage every second
	empInitialWait = 1.5;	// wait this long before the cloud starts ticking for damage
	empTickCounter = 0;		// just an internal counter to count gas damage ticks
	
	wait( empInitialWait );
	empTotalTime += empInitialWait;
	
	for( ;; )
	{
		if( empTotalTime >= duration )
		{
			break;
		}
		
		//apply emp fx to players in the emp cloud
		foreach( player in level._players )
		{	
			if( level._teamBased )
			{
				if( !isDefined( player.team ))
				{
					continue;
				}
				
				if( !isDefined( self.owner ))
				{
					continue;
				}
				
				if( player.team == self.team && player != self.owner )
				{
					continue;
				}
			}
			
			if( player istouching( empEffectArea ) && player.sessionstate == "playing" )
			{	
				//player thread maps\mp\killstreaks\_emp::EMPGrenade_JamPlayer( level._empCloudTickTime );
				player increaseEmpCloudedTime( level._empCloudTickTime );

				player notify( "emp_cloud_update" );

				if( level._empCloudTickDamage > 0 )
				{
					RadiusDamage( player.origin, 16, level._empCloudTickDamage, level._empCloudTickDamage, self.owner);
				}
			}
		}
		
		wait( empTickTime );
		empTotalTime += empTickTime;
		empTickCounter += 1;
	}
	
	//clean up
	RemoveCloudFromEMPList( empEffectArea );

	//println( "removed emp cloud from list, size = " + level._empCloudList.size );

	empEffectArea delete();

	self delete();
}

//Apply initial damage to world ents on explosion
empCloudGrenadeInitialBlast( trigger, attacker )
{
	assert( isDefined( trigger ));
	assert( isDefined( attacker ));

	//hit players with the initial blast
	foreach( player in level._players )
	{	
		if( level._teamBased )
		{
			if( !isDefined( player.pers["team"] ))
			{
				continue;
			}
				
			if( !isDefined( attacker ))
			{
				continue;
			}
				
			if( player.pers["team"] == attacker.pers["team"] && player != attacker )
			{
				continue;
			}
		}
			
		if( player istouching( trigger ) && player.sessionstate == "playing" )
		{
			//player thread maps\mp\killstreaks\_emp::EMPGrenade_JamPlayer( level._empInitialBlastTime );
			player increaseEmpCloudedTime( level._empInitialBlastTime );
			player notify( "emp_cloud_update" );
		}
	}

	//take out enemy c4 in the initial blast
	destroyEnemyC4( attacker, trigger );
	
	//take down any helis it hits
	foreach ( heli in level._helis )
	{
		if( heli isTouching( trigger ))
		{
			radiusDamage( heli.origin, 384, 5000, 5000, attacker );
		}
	}

	//take down any little birds 
	foreach ( littleBird in level._littleBird )
	{
		if( littleBird isTouching( trigger ))
		{
			radiusDamage( littleBird.origin, 384, 5000, 5000, attacker );
		}
	}

	/*
	foreach ( turret in level._turrets )
		radiusDamage( turret.origin, 16, 5000, 5000, attacker );
	
	foreach ( rocket in level._rockets )
		rocket notify ( "death" );
	*/
	
	//take down any uavs it hits	
	if ( level._teamBased )
	{
		foreach ( uav in level._uavModels["allies"] )
		{
			if( uav isTouching( trigger ))
			{
				radiusDamage( uav.origin, 384, 5000, 5000, attacker );
			}
		}
		
		foreach ( uav in level._uavModels["axis"] )
		{
			if( uav isTouching( trigger ))
			{
				radiusDamage( uav.origin, 384, 5000, 5000, attacker );
			}
		}	
	}
	else
	{	
		foreach ( uav in level._uavModels )
		{
			if( uav isTouching( trigger ))
			{
				radiusDamage( uav.origin, 384, 5000, 5000, attacker );
			}
		}
	}
	
	//take down any ac130's it hits
	if ( isDefined( level._ac130player ) )
	{
		if( level._ac130player isTouching( trigger ))
		{
			radiusDamage( level._ac130.planeModel.origin+(0,0,10), 1000, 5000, 5000, attacker );
		}
	}
}

destroyEnemyC4( attacker, trigger )
{
	foreach ( player in level._players )
	{
		if ( player.pers["team"] != attacker.pers["team"] || ! level._teambased )
		{
			if( isDefined( player.c4array ))
			{
				if ( player.c4Array.size > 0 )
				{
					for( i = 0; i < player.c4Array.size; i++ )
					{
						if( player.c4Array[i] isTouching( trigger ))
						{
							player notify( "alt_detonate" );
						}
					}
				}
			}
		}		
	}
}