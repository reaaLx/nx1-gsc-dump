init()
{
	//tagZP<NOTE>  what is this, may or may not need to extend for MTDM
	level._spectateOverride["allies"] = spawnstruct();
	level._spectateOverride["axis"] = spawnstruct();

	level thread onPlayerConnect();
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
		player thread onSpectatingClient();
	}
}


onJoinedTeam()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill( "joined_team" );
		self setSpectatePermissions();
	}
}


onJoinedSpectators()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill( "joined_spectators" );
		self setSpectatePermissions();
	}
}


onSpectatingClient()
{
	self endon("disconnect");
	
	for( ;; )
	{
		self waittill( "spectating_cycle" );

		// show the card for the player we're viewing. Could be undefined if the cyling failed
		spectatedPlayer = self GetSpectatingPlayer();
		if ( isDefined( spectatedPlayer ) )
		{
			self SetCardDisplaySlot( spectatedPlayer, 6 );
		}
	}
}



updateSpectateSettings()
{
	level endon ( "game_ended" );
	
	for ( index = 0; index < level._players.size; index++ )
		level._players[index] setSpectatePermissions();
}


getOtherTeam( team )
{
	if( level._multiTeamBased )
	{
		assertMsg( "getOtherTeam() should not be called in Multi Team Based gametypes" );
	}
	
	if ( team == "axis" )
		return "allies";
	else if ( team == "allies" )
		return "axis";
	else
		return "none";
}


setSpectatePermissions()
{
	team = self.sessionteam;

	if ( level._gameEnded && gettime() - level._gameEndTime >= 2000 )
	{
		self allowSpectateTeam( "allies", false );
		self allowSpectateTeam( "axis", false );
		self allowSpectateTeam( "freelook", false );
		
		if( level._multiTeamBased )
		{
			for( i = 0; i < level._teamNameList.size; i++ )
			{
				self allowSpectateTeam( level._teamNameList[i], false );
			}
		}
		
		self allowSpectateTeam( "none", true );
		return;
	}
	
	spectateType = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "spectatetype" );

	switch( spectateType )
	{
		case 0: // disabled
			self allowSpectateTeam( "allies", false );
			self allowSpectateTeam( "axis", false );
			self allowSpectateTeam( "freelook", false );
			self allowSpectateTeam( "none", false );
			
			if( level._multiTeamBased )
			{
				for( i = 0; i < level._teamNameList.size; i++ )
				{
					self allowSpectateTeam( level._teamNameList[i], false );
				}
			}
			
			break;
		case 1: // team/player only
			if ( !level._teamBased )
			{
				self allowSpectateTeam( "allies", true );
				self allowSpectateTeam( "axis", true );
				self allowSpectateTeam( "none", true );
				self allowSpectateTeam( "freelook", false );
			}
			else if ( isDefined( team ) && (team == "allies" || team == "axis") && !level._multiTeamBased )
			{
				self allowSpectateTeam( team, true );
				self allowSpectateTeam( getOtherTeam( team ), false );
				self allowSpectateTeam( "freelook", false );
				self allowSpectateTeam( "none", false );
			}
			else if ( isDefined( team ) && level._multiTeamBased )
			{
				//the multi team case will drop in here
				
				self allowSpectateTeam( "allies", false );
				self allowSpectateTeam( "axis", false );
				
				for( i = 0; i < level._teamNameList.size; i++ )
				{
					if( team == level._teamNameList[i] )
					{
						self allowSpectateTeam( level._teamNameList[i], true );
					}
					else
					{
						self allowSpectateTeam( level._teamNameList[i], false );
					}
				}
				
				self allowSpectateTeam( "freelook", false );
				self allowSpectateTeam( "none", false );
			}
			else
			{
				self allowSpectateTeam( "allies", false );
				self allowSpectateTeam( "axis", false );
				self allowSpectateTeam( "freelook", false );
				self allowSpectateTeam( "none", false );
				if( level._multiTeamBased )
				{
					for( i = 0; i < level._teamNameList.size; i++ )
					{
						self allowSpectateTeam( level._teamNameList[i], false );
					}
				}
			}
			break;
		case 2: // free
			self allowSpectateTeam( "allies", true );
			self allowSpectateTeam( "axis", true );
			self allowSpectateTeam( "freelook", true );
			self allowSpectateTeam( "none", true );
			
			if( level._multiTeamBased )
			{
				for( i = 0; i < level._teamNameList.size; i++ )
				{
					self allowSpectateTeam( level._teamNameList[i], true );
				}
			}
			
			break;
	}
	
	if ( isDefined( team ) && (team == "axis" || team == "allies") && !level._multiTeamBased )
	{
		if ( isdefined( level._spectateOverride[team].allowFreeSpectate ))
			self allowSpectateTeam( "freelook", true );
		
		if ( isdefined( level._spectateOverride[team].allowEnemySpectate ))
			self allowSpectateTeam( getOtherTeam( team ), true );
	}
}