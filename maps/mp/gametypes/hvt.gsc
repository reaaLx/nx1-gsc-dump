#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
/*
	HVT
	Objective: 	Score points by eliminating your bounties. Get players to lose points by preventing them from taking your bounty.
	Map ends:	When one player reaches the score limit, or time limit is reached
	Respawning:	No wait / Away from other players

	Level requirements
	------------------
		Spawnpoints:
			classname		mp_dm_spawn
			All players spawn from these. The spawnpoint chosen is dependent on the current locations of enemies at the time of spawn.
			Players generally spawn away from enemies.

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.
*/

main()
{
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	registerTimeLimitDvar( level._gameType, 10, 0, 1440 );
	registerScoreLimitDvar( level._gameType, 1000, 0, 5000 );
	registerWinLimitDvar( level._gameType, 1, 0, 5000 );
	registerRoundLimitDvar( level._gameType, 1, 0, 10 );
	registerNumLivesDvar( level._gameType, 0, 0, 10 );
	registerHalfTimeDvar( level._gameType, 0, 0, 1 );

	level._onStartGameType = ::onStartGameType;
	level._getSpawnPoint = ::getSpawnPoint;
	level._onSpawnPlayer = ::onSpawnPlayer;
	level._onPlayerKilled = ::onPlayerKilled;

	game["dialog"]["gametype"] = "hvt";

	if ( getDvarInt( "g_hardcore" ) )
		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "camera_thirdPerson" ) )
		game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "scr_diehard" ) )
		game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
	else if (getDvarInt( "scr_" + level._gameType + "_promode" ) )
		game["dialog"]["gametype"] = game["dialog"]["gametype"] + "_pro";

	level._give_up_value = 3.0;

	/*
	//I do not seem to be able to get Justin's boxes to work
	//required to make Justin's stolen HUD functionality work.
	precacheshader( "nx_hud_merc_frame" );
	*/

	preCacheShader( "compassping_bounty" );
	PreCacheModel( "nx_pr_lunar_helm_scripted" );

	level thread on_new_player_connect();
}


onStartGameType()
{
	setClientNameMode("auto_change");

	setObjectiveText( "allies", &"OBJECTIVES_DM" );
	setObjectiveText( "axis", &"OBJECTIVES_DM" );

	if ( level._splitscreen )
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_DM" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_DM" );
	}
	else
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_DM_SCORE" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_DM_SCORE" );
	}
	setObjectiveHintText( "allies", &"OBJECTIVES_DM_HINT" );
	setObjectiveHintText( "axis", &"OBJECTIVES_DM_HINT" );

	level._spawnMins = ( 0, 0, 0 );
	level._spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dm_spawn" );
	level._mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level._spawnMins, level._spawnMaxs );
	setMapCenter( level._mapCenter );
	
	allowed[0] = "dm";
	maps\mp\gametypes\_gameobjects::main(allowed);

	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 5 );
	maps\mp\gametypes\_rank::registerScoreInfo( "suicide", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "bounty_killed", 200 );
	maps\mp\gametypes\_rank::registerScoreInfo( "standard_kill", 10 );
	maps\mp\gametypes\_rank::registerScoreInfo( "bounty_blocked", -100 );
	
	level._QuickMessageToAll = true;

	hvt_init();
}


getSpawnPoint()
{
	//tagCT<NOTE> My attempt at optimizing, this logic used to be in OnSpawnPlayer()

	//Code to prevent player from spawning before connection logic
	while( !isDefined( self.connection_logic_completed ) )
	{
		wait .01;
	}

	//Code begin to prevent missing bounty problem
	while( self.arbitrating_kills )
	{
		wait .01;
	}
	//Code ends to prevent missing bounty problem

	if( isDefined( level._matchbegan ) )
	{
		//for debug purposes.
		//println( self.name + " has just spawned while the match is underway" );
		//tagCT<NOTE> Based on the way the level._players array works this check may not be aproppriate. However, 
		//I think I'm getting around this with the thread I spawn (hvt_player_bounty_watch).
		if( !isDefined( self.current_bounty ) && level._players.size > 2 )
		{
			//for debug purposes.
			//println( self.name + " spawned without a bounty and there should be enough players for a bounty to be assigned." );
			while( !isDefined( self.bounties_setup ) )
			{
				wait .1;
				//for debug purposes.
				//println( self.name + " spawned after the match began, but the initial setup logic to setup his bounties is still running." );
			}
			//for debug purposes.
			//println( self.name + " has had run the initial setup for the bounty game mode." );
			//Assign new target.
			self select_new_target();
			//for debug purposes.
			//println( self.name + " has just been assigned " + self.current_bounty.name + " as his bounty." );			
		}
		else if( !isDefined( self.current_bounty ) )
		{
			//for debug purposes.
			//println( self.name + " spawned without a bounty defined because there are not enough players in the match. He will now watch for the correct number of players to be in the match." );
			self thread hvt_player_bounty_watch();
		}
	}

	spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( spawnPoints );

	return spawnPoint;
}

onSpawnPlayer()
{
	if( isDefined( self.current_bounty ) )
	{
		//Making this function threaded to try to avoid the issue with the gun not appearing when the player spawns.
		//I'm not sure if this will introduce other errors.
		self thread give_revenge_deathstreak();
		//for debug purposes.
		//println( self.name + " should now have an icon showing where his bounty, " + self.current_bounty.name + ", is on the map." );
	}

	//Setup for hunter identifier
	self thread setup_hunting_id_on_spawn();

	//for debug purposes.
	//println( self.name + " is about to update the information in his HUD." );
	self thread hvt_create_HUD();
}

setup_hunting_id_on_spawn()
{
	wait .75;

	self.hunting_id LinkTo( self, "tag_eye", ( 0, 0 , 0 ), ( 0, 90, 0 ) );
	if( isDefined( self.current_bounty ) )
	{
		self.hunting_id ShowToPlayer( self.current_bounty );
	}
}

onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, killId )
{
	//Hunter Identifier Cleanup
	self.hunting_id Hide();
	self.hunting_id Unlink();	

	self thread hvt_destroy_HUD();

	//for debug purposes.
	//println( self.name + " is deleting the instance of his HUD in a thread, since he just died." );

	if( !isDefined( attacker ) )
	{
		return;
	}

	//Code begin to prevent missing bounty problem
	while( self.arbitrating_kills || attacker.arbitrating_kills )
	{
		wait .01;
	}
	self.arbitrating_kills = true;
	attacker.arbitrating_kills = true;
	//Code ends to prevent missing bounty problem

	//for debug purposes
	//println( attacker.name + " killed " + self.name );

	bounty_lost = false;
	if( isDefined( attacker.current_bounty ) && isDefined( self.current_bounty ) )
	{
		//for debug purposes.
		//println( self.name + " and " + attacker.name + " both have defined bounties." );
		if( attacker.current_bounty == self )
		{
			//for debug purposes.
			//println( self.name + " is the bounty for " + attacker.name );
			//Give attacker score bonus for killing bounty
			maps\mp\gametypes\_gamescore::givePlayerScore( "bounty_killed", attacker );
			attacker thread maps\mp\gametypes\_hud_message::SplashNotify( "bounty_killed", maps\mp\gametypes\_rank::getScoreInfoValue( "bounty_killed" ) );
	
			//Give attacker self's bounty if bounty is not attacker
			if( self.current_bounty == attacker )
			{
				//for debug purposes.
				//println( self.name + " had " + attacker.name + " as his bounty, so " + attacker.name + "cannot steal the bounty of " + self.name );
				attacker select_new_target();
				//for debug purposes.
				//println( attacker.name + " has a new bounty." );
			}
			else
			{
				attacker.current_bounty = self.current_bounty;
				//for debug purposes.
				//println( attacker.name + " took the bounty of " + self.name + " as his new bounty." );
			}

			//for debug purposes.
			//println( "A thread has been spawned to update the HUD for " + attacker.name );
			attacker thread hvt_update_HUD();
	
			attacker give_revenge_deathstreak();
			//for debug purposes.
			//println( attacker.name + " should now have an icon indicating where his new bounty is." );
	
			//Increment self's target list for current bounty
			//I just made this function call threaded.  It wasn't before, might help some of the optimization problems
			//for debug purposes.
			//println( "Spawning a thread to track that " + self.name + " was killed by " + attacker.name );
			self thread increment_target_list( attacker, .2 );
	
			//Increment attacker's target list for current bounty
			//I just made this function call threaded.  It wasn't before, might help some of the optimization problems
			//for debug purposes.
			//println( "Spawning a thread to track that " + attacker.name + " collected a bounty on " + self.name );
			attacker thread increment_target_list( self, level._give_up_value );
		
			bounty_lost = true;
			//for debug purposes.
			//println( "Set a boolean flag to denote that " + self.name + " need to pick a new bounty." );
		}
		else if( self != attacker && self.current_bounty != attacker )
		{
			//for debug purposes.
			//println( attacker.name + " killed " + self.name + ", but " + self.name + " was not his bounty." );
			//Give small score for a non-bounty kill.
			maps\mp\gametypes\_gamescore::givePlayerScore( "standard_kill", attacker );
			attacker thread maps\mp\gametypes\_hud_message::SplashNotify( "bounty_standard_kill", maps\mp\gametypes\_rank::getScoreInfoValue( "standard_kill" ) );
		}
		if( self.current_bounty == attacker )
		{
			//for debug purposes.
			//println( attacker.name + " prevented " + self.name + "from collecting a bounty on him." );
			//Deduct score from self for being bounty blocked
			maps\mp\gametypes\_gamescore::givePlayerScore( "bounty_blocked", self );
			//for debug purposes.
			//println( "100 points has been deducted from the score of " + self.name );
			self thread maps\mp\gametypes\_hud_message::SplashNotify( "bounty_blocked", maps\mp\gametypes\_rank::getScoreInfoValue( "bounty_blocked" ) );
	
			//Make sure self's score does not go below 0.
			if( maps\mp\gametypes\_gamescore::_getPlayerScore( self ) < 0 )
			{
				//for debug purposes.
				//println( "The score of " + self.name + " dropped below 0, so his score is being readjusted to be 0." );
				maps\mp\gametypes\_gamescore::_setPlayerScore( self, 0 );
			}
	
			//Increment self's target list for current bounty
			//I just made this function call threaded.  It wasn't before, might help some of the optimization problems
			//for debug purposes.
			//println( "Spawning a thread to track that " + attacker.name + " collected a bounty on " + self.name );
			self thread increment_target_list( attacker, 1 );
	
			//self loses current bounty target
			bounty_lost = true;
			//for debug purposes.
			//println( "Set a boolean flag to denote that " + self.name + " need to pick a new bounty." );
	
			//Provide attacker with positive feedback for blocking a bounty
			attacker thread maps\mp\gametypes\_hud_message::SplashNotify( "bounty_block" );
		}
	}
	else if( self != attacker )
	{
		//tagCT<NOTE>The below assert was not a valid assumption
		/*tagCT<NOTE>My initial instinct may have been wrong. I think this assert was valid. I think QA was 
		running into the bug Orion found where he did not have a bounty assigned.  For now, I'm afraid to 
		comment this assert back in.*/
		//assert( level._players.size <= 2 );
		//for debug purposes.
		//println( attacker.name + " killed " + self.name + " and at least one of these 2 did not have a bounty defined. This should only happen when there are not enough players to properly run the game mode." );

		//Give small score for a non-bounty kill.
		maps\mp\gametypes\_gamescore::givePlayerScore( "standard_kill", attacker );
		attacker thread maps\mp\gametypes\_hud_message::SplashNotify( "bounty_standard_kill", maps\mp\gametypes\_rank::getScoreInfoValue( "standard_kill" ) );
	}
	if( bounty_lost )
	{
		//tagCT<NOTE> I'm trying to have the HUD not use the hunters array
		/*while( self.current_bounty.accessing_hunters_array )
		{
			wait .01;
		}
		self.current_bounty.accessing_hunters_array = true;
		//for debug purposes.
		//println( self.name + " needs to lose his current bounty based on who killed him." );
		self.current_bounty.hunters = array_remove( self.current_bounty.hunters, self );
		self.current_bounty.accessing_hunters_array = false;
		*/
		old_bounty = self.current_bounty;
		//for debug purposes.
		//println( self.name + " should no longer appear in the HUD as hunting " + self.current_bounty.name );
		self.current_bounty = undefined;
		old_bounty thread hvt_update_HUD();
		//for debug purposes.
		//println( self.name + " now has an undefined bounty" );
	}

	//Code begin to prevent missing bounty problem
	self.arbitrating_kills = false;
	attacker.arbitrating_kills = false;
	//Code ends to prevent missing bounty problem
}

hvt_init()
{
	if( level._players.size > 2 )
	{
		for( i = 0; i < level._players.size; i++ )
		{
			level._players[i].current_bounty = level._players[(i + 1) % level._players.size];
			
			//Give Player Revenge Deathstreak for target.
			level._players[i] give_revenge_deathstreak();
	
			//Create an array of targets the player has killed. Set all targets to 0, except self.
			level._players[i] target_list_init( i );

			level._players[i] thread hvt_update_HUD();
		}
	}
	else
	{
		for( i = 0; i < level._players.size; i++ )
		{		
			//Create an array of targets the player has killed. Set all targets to 0, except self.
			level._players[i] target_list_init( i );
		}	
	}

	level._matchbegan = true;
	level thread on_player_disconnect();
}

//self = level
on_new_player_connect()
{
	//Let the thread run infinitely while the game is running.
	while(1)
	{
		//Wait until a new player has connected.
		self waittill( "connected", player );

		//Code begin to prevent missing bounty problem
		player.arbitrating_kills = false;
		//Code ends to prevent missing bounty problem

		//tagCT<NOTE> I'm trying to get the HUD working without the hunters array
		/*player.hunters = [];
		player.accessing_hunters_array = false;
		*/
		player.modifying_hud = false;

		//Setting up hunter identifier
		player.hunting_id = Spawn( "script_model", ( 0, 0, 0 ) );
		player.hunting_id SetModel( "nx_pr_lunar_helm_scripted" );
		player.hunting_id NotSolid();
		player.hunting_id Hide();

		if( isdefined( level._matchbegan ) )
		{
			//Setup New Players list of targets he has killed. Set all targets to 0, except himself.
			player target_list_init();

			//Update all players' target lists to include new player
			refresh_target_lists();

			if( level._players.size > 2 )
			{
				//Give New Player a Random Target that is not himself.
				i = RandomInt( level._players.size );
				player.current_bounty = level._players[i];
				if( player.current_bounty == player )
				{
					player.current_bounty = level._players[( i + 1 ) % level._players.size];
				}

				//Give Player Revenge Deathstreak Perk
				player give_revenge_deathstreak();
			}
		}
		player.connection_logic_completed = true;
	}
}

//self = level
on_player_disconnect()
{
	//Let the thread run infinitely while the game is running.
	while(1)
	{
		//Wait until a player has disconnected.
		self waittill( "disconnected", player );

		//Hunter Identifier Cleanup
		player.hunting_id Unlink();
		player.hunting_id Delete();

		//Removed disconnected player from player's targets list
		refresh_target_lists();

		if( level._players.size <= 2 )
		{
			for( i = 0; i < level._players.size; i++ )
			{
				level._players[i].current_bounty = undefined;
				/*self notify( "stopBounty" );
				wait .1;*/
				self unsetBounty();
				wait .5;

				level._players[i].hunting_id Hide();

				level._players[i] thread hvt_update_HUD();
			}
		}
		else
		{
			for( i = 0; i < level._players.size; i++ )
			{
				//If disconnected player, is player's target give new target and make appropriate updates.
				if( level._players[i].current_bounty == player )
				{
					level._players[i] select_new_target();

					level._players[i] give_revenge_deathstreak();

					level._players[i] thread hvt_update_HUD();
				}
			}
		}
	}
}

//self = player receiving deathstreak
give_revenge_deathstreak( player )
{
		/*self notify( "stopBounty" );
		wait .1;
		self unsetBounty();
		wait 3;*/

		//self.lastKilledBy = self.current_bounty;
		self setBounty();

		//assert( self _hasperk( "specialty_revenge" ) );
}

//self = player who need new target
select_new_target()
{
	self.hunting_id Hide();

	if( isDefined( self.current_bounty ) )
	{
		//tagCT<NOTE> I'm trying to get the HUD working without using the hunters array
		/*while( self.current_bounty.accessing_hunters_array )
		{
			wait .01;
		}
		self.current_bounty.accessing_hunters_array = true;
		self.current_bounty.hunters = array_remove( self.current_bounty.hunters, self );
		self.current_bounty.accessing_hunters_array = false;
		*/
	}

	valid_target_found = false;
	if( self.bounties["players"].size != level._players.size )
	{
		refresh_target_lists();
	}
	//select a random target in hopes that it is valid
	iterator_start = RandomInt( level._players.size );
	self.current_bounty = self.bounties["players"][iterator_start];

	//if target is not valid, try to find the first valid one in the array
	if( !isDefined( self.bounties["value"][iterator_start] ) )
	{
		self.bounties["value"][iterator_start] = 0.0;
		valid_target_found = true;
	}
	else if( self.bounties["value"][iterator_start] >= level._give_up_value )
	{
		for( i = ( iterator_start + 1 ) % level._players.size ; i != iterator_start; i = (i + 1) % level._players.size )
		{
			if( self.bounties["value"][i] < level._give_up_value )
			{
				self.current_bounty = self.bounties["players"][i];
				valid_target_found = true;
				break;
			}
		}
	}
	else
	{
		valid_target_found = true;
	}

	//if no valid targets, clear targets list and select a random target that is not self
	if( !valid_target_found )
	{
		self target_list_init();

		i = RandomInt( level._players.size );
		self.current_bounty = level._players[i];
		if( self.current_bounty == self )
		{
			self.current_bounty = level._players[( i + 1 ) % level._players.size];
		}
	}

	//tagCT<NOTE> I'm trying to get the HUD working without the hunters array
	/*while( self.current_bounty.accessing_hunters_array )
	{
		wait .01;
	}
	self.current_bounty.accessing_hunters_array = true;
	self.current_bounty.hunters = add_to_array( self.current_bounty.hunters, self );
	self.current_bounty.accessing_hunters_array = false;
	*/

	self.hunting_id ShowToPlayer( self.current_bounty );

	self.current_bounty thread hvt_update_HUD();
}

//self = player who's target list is being initialized.
target_list_init( player_iterator )
{
	self.bounties = [];
	self.bounties["players"] = [];
	self.bounties["players"] = level._players;
	self.bounties["value"] = [];

	if( isDefined( player_iterator ) )
	{
		for( i = 0; i < level._players.size; i++)
		{
			self.bounties["value"][i] = 0.0;
		}
		self.bounties["value"][player_iterator] = level._give_up_value;
	}
	else
	{
		for( i = 0; i < level._players.size; i++ )
		{
			if( self.bounties["players"][i] == self )
			{
				self.bounties["value"][i] = level._give_up_value;
			}
			else
			{
				self.bounties["value"][i] = 0.0;
			}
		}
	}

	self.bounties_setup = true;
}

refresh_target_lists()
{
	old_bounties_list = [];
	old_bounties_list["players"] = [];
	old_bounties_list["value"] = [];

	for( i = 0; i < level._players.size; i++ )
	{
		//Store off current target list in temporary array
		if( !isDefined( level._players[i].bounties ) )
		{
			level._players[i] target_list_init(i);
		}
		old_bounties_list["players"] = level._players[i].bounties["players"];

		old_bounties_list["value"] = level._players[i].bounties["value"];
		
		//Load current player list into bounties array
		level._players[i].bounties["players"] = level._players;
		
		//Zero out all values
		for( j = 0; j < level._players[i].bounties["players"].size; j++ )
		{
			level._players[i].bounties["value"][j] = 0.0;
		}
		level._players[i].bounties["value"][i] = level._give_up_value;
		
		//Find each entry in old target list and add its value to the value in the new targets list.
		for( j = 0; j < old_bounties_list["players"].size; j++ )
		{
			for( k = 0; k < level._players[i].bounties["players"].size; k++ )
			{
				if( old_bounties_list["players"][j] == level._players[i].bounties["players"][k] )
				{
					level._players[i].bounties["value"][k] += old_bounties_list["value"][j];
					break;
				}
			}
		}
	}
}

//self = player who owns target list
increment_target_list( target, amount )
{
	for( i = 0; i < level._players.size; i++)
	{
		if( self.bounties["players"][i] == target )
		{
			self.bounties["value"][i] += amount;
			break;
		}
	}
}

//self = player without a bounty
hvt_player_bounty_watch()
{
	if( !isDefined( self.current_bounty ) )
	{
		if( level._players.size > 2 )
		{
			self select_new_target();

			self give_revenge_deathstreak();
		}
		else
		{
			while( level._players.size < 3 )
			{
				wait .5;
			}
			//Check to see if any player is without a target because they were in the match before there was a valid number of players
			if( !isDefined( self.current_bounty ) )
			{
				self select_new_target();

				self give_revenge_deathstreak();
			}
		}
		self thread hvt_update_HUD();
	}
}

//Code stolen from Justin's Merc Game Mode
//=================================================================================================
// HUD Scripts
//=================================================================================================

// Creates our proto HUD
// self = player
hvt_create_HUD()
{
	while( self.modifying_hud )
	{
		wait .01;
	}
	self.modifying_hud = true;
	if( !isAlive( self ) )
	{
		self waittill( "spawned_player" );
	}


	/*
	//I do not seem to be able to get Justin's boxes to work
	// Horrible hacked HUD
	self.barOne		= hvt_hacky_hud_create_bar( -32, 108 );
	*/
	/*self.barTwo		= merc_hacky_hud_create_bar( -32, 126 );
	self.barThree	= merc_hacky_hud_create_bar( -32, 144 );
	self.barFour	= merc_hacky_hud_create_bar( -32, 162 );
	*/

	//=============================================================

	// Was - Targets Hit Counter
	// Now trying to use as a way to list the name of the player's current bounty.
	if( isDefined( self.counterElem ) )
	{
		self.counterElem destroyElem();
	}
	self.counterElem		= hvt_hacky_hud_create_text( 12, 154, "BOUNTY" );
	if( isDefined( self.counter_valueElem ) )
	{
		self.counter_valueElem destroyElem();
	}
	self.counter_valueElem	= hvt_hacky_hud_create_value( 127, 154 );

	
	// Targets remaining counter
	if( isDefined( self.remainingElem ) )
	{
		self.remainingElem destroyElem();
	}
	self.remainingElem		= hvt_hacky_hud_create_text( 12, 172, "HUNTED BY" );
	if( isDefined( self.remaining_valueElem ) )
	{
		self.remaining_valueElem destroyElem();
	}
	self.remaining_valueElem= hvt_hacky_hud_create_value( 127, 172 );

	/*
	// Combo counter
	self.multElem			= merc_hacky_hud_create_text( 12, 154, "COMBO" );
	self.mult_valueElem		= merc_hacky_hud_create_value( 127, 154 );

	// Score counter
	self.scoreElem			= merc_hacky_hud_create_text( 12, 172, "SCORE" );
	self.score_valueElem	= merc_hacky_hud_create_value( 127, 172 );
	*/
	
	self.modifying_hud = false;

	// Force an update now
	self thread hvt_update_HUD();
}

/*
//I do not seem to be able to get Justin's boxes to work
// This creates a HUD bar background for the text.
// There must be a better way to do this.
hvt_hacky_hud_create_bar( xpos, ypos )
{
	hudBar = createFontString( "fwmed", 1.0 );
	hudBar setPoint( "TOPLEFT", undefined, xpos, ypos );
	hudBar setText( "blank" );
	hudBar.layer = "visor";
	hudBar.shader = "nx_hud_merc_frame"; 
	hudBar setShader( hudBar.shader, 200, 30 );

	return hudBar;
}
*/

hvt_hacky_hud_create_text( xpos, ypos, text )
{
	hudText = createFontString( "fwmed", 1.0 );
	hudText setPoint( "TOPLEFT", undefined, xpos, ypos );
	hudText setText( text );
	hudText.layer = "visor";
	return hudText;
}

hvt_hacky_hud_create_value( xpos, ypos )
{
	hudValue = createFontString( "fwmed", 1.0 );
	hudValue setPoint( "TOPLEFT", undefined, xpos, ypos );
	hudValue.alignX = "left";
	hudValue.layer = "visor";
	return hudValue;
}


// Updates the proto HUD
// self = player
hvt_update_HUD()
{
	while( self.modifying_hud )
	{
		wait .01;
	}
	self.modifying_hud = true;

	if ( isDefined( self.counter_valueElem ) )
	{
		if( isDefined( self.current_bounty ) )
		{
			self.counter_valueElem setText( self.current_bounty.name );
		}
		else
		{
			self.counter_valueElem setText( "" );
		}
	}


	// Update the remaining targets on everyones HUD
	if( isDefined( self.remaining_valueElem ) )
	{
		hunter_list = "";
		//tagCT<NOTE> Trying to get the HUD working without the hunters array
		/*
		while( self.accessing_hunters_array )
		{
			wait .01;
		}
		self.accessing_hunters_array = true;
		if( self.hunters.size > 0 )
		{
			hunter_list += self.hunters[0].name;
		}
		for( i = 1; i < self.hunters.size; i++ )
		{
			hunter_list += ", " + self.hunters[i].name;
		}
		self.accessing_hunters_array = false;
		*/

		i = 0;
		for( ; i < level._players.size; i++ )
		{
			if( isDefined( level._players[i].current_bounty ) )
			{
				if( level._players[i].current_bounty == self )
				{
					hunter_list = level._players[i].name;
					break;
				}
			}
		}
		for( i++; i < level._players.size; i++ )
		{
			if( isDefined( level._players[i].current_bounty ) )
			{
				if( level._players[i].current_bounty == self )
				{
					hunter_list += ", " + level._players[i].name;
				}
			}
		}
		self.remaining_valueElem setText( hunter_list );
	}

	/*
	if ( isDefined( self.mult_valueElem ) )
	{
		multiplier = merc_get_multiplier( self );
		self.mult_valueElem setText( "" + multiplier );
	}

	if ( isDefined( self.score_valueElem ) )
	{
		self.score_valueElem setText( "" + self.score );
	}
	*/

	self.modifying_hud = false;
}

// Cleans up our proto HUD
// self = player
hvt_destroy_HUD()
{
	while( self.modifying_hud )
	{
		wait .01;
	}
	self.modifying_hud = true;
	/*
	//I do not seem to be able to get Justin's boxes to work
	self.barOne destroyElem();
	*/
	/*self.barTwo destroyElem();
	self.barThree destroyElem();
	self.barFour destroyElem();
	*/
	
	if( isDefined( self.counterElem ) )
	{
		self.counterElem destroyElem();
	}
	if( isDefined( self.counter_valueElem ) )
	{
		self.counter_valueElem destroyElem();
	}

	if( isDefined( self.remainingElem ) )
	{
		self.remainingElem destroyElem();
	}
	if( isDefined( self.remaining_valueElem ) )
	{
		self.remaining_valueElem destroyElem();
	}

	/*self.multElem destroyElem();
	self.mult_valueElem destroyElem();

	self.scoreElem destroyElem();
	self.score_valueElem destroyElem();
	*/
	self.modifying_hud = false;
}

//=================================================================================================
// Code stolen from Revenge Deathstreak functionality
//=================================================================================================

/////////////////////////////////////////////////////////////////
// REVENGE: show the last player who killed you, on your mini-map or in the world with a head icon
setBounty() // this version does the head icon
{
	self notify( "stopBounty" );
	wait( 1 ); // let all of the already running threads stop and clean up

	if( !IsDefined( self.current_bounty ) )
		return;

	bountyParams = SpawnStruct();
	bountyParams.showTo = self;
	bountyParams.icon = /*"compassping_bounty"*/ "compassping_revenge";
	bountyParams.offset = ( 0, 0, 64 );
	bountyParams.width = 10;
	bountyParams.height = 10;
	bountyParams.archived = false;
	bountyParams.delay = .1;
	bountyParams.constantSize = false;
	bountyParams.pinToScreenEdge = true;
	bountyParams.fadeOutPinnedIcon = false;
	bountyParams.is3D = true;
	self.bountyParams = bountyParams;

	self.current_bounty_head_icon = self.current_bounty maps\mp\_entityheadIcons::setHeadIcon( 
		bountyParams.showTo, 
		bountyParams.icon, 
		bountyParams.offset, 
		bountyParams.width, 
		bountyParams.height, 
		bountyParams.archived, 
		bountyParams.delay, 
		bountyParams.constantSize, 
		bountyParams.pinToScreenEdge, 
		bountyParams.fadeOutPinnedIcon,
		bountyParams.is3D );
	
	self thread watchBountyDeath();
	self thread watchBountyDisconnected();
	self thread watchBountyVictimDisconnected();
	self thread watchStopBounty();
}

watchBountyDeath() // self == player with the deathstreak
{
	self endon( "stopBounty" );
	self endon( "disconnect" );

	current_bounty = self.current_bounty;
	// since head icons get deleted on death, we need to keep giving this player a head icon until stop revenge
	while( true )
	{
		current_bounty waittill( "spawned_player" );
		self.current_bounty_head_icon = current_bounty maps\mp\_entityheadIcons::setHeadIcon( 
			self.bountyParams.showTo, 
			self.bountyParams.icon, 
			self.bountyParams.offset, 
			self.bountyParams.width, 
			self.bountyParams.height, 
			self.bountyParams.archived, 
			self.bountyParams.delay, 
			self.bountyParams.constantSize, 
			self.bountyParams.pinToScreenEdge, 
			self.bountyParams.fadeOutPinnedIcon,
			self.bountyParams.is3D );
	}
}

watchBountyDisconnected()
{
	self endon( "stopBounty" );

	self.current_bounty waittill( "disconnect" );

	self notify( "stopBounty" );
}

watchStopBounty() // self == player with the deathstreak
{
	current_bounty = self.current_bounty;	
	
	// if the player gets any kill, then stop the revenge on the last killed by player
	// if the player dies again without getting any kills, have the new killer show and the old not	
	self waittill( "stopBounty" );

	if( !IsDefined( current_bounty ) )
		return;

	foreach( key, headIcon in current_bounty.entityHeadIcons )
	{	
		if( !isDefined( headIcon ) )
			continue;

		if( self.current_bounty_head_icon == headIcon )
		{
			headIcon destroy();
		}
	}

	//if( isDefined( self.objIdFriendly ) )
	//	_objective_delete( self.objIdFriendly );
}

watchBountyVictimDisconnected()
{
	// if the player with revenge gets disconnected then clean up
	objID = self.objIdFriendly;
	current_bounty = self.current_bounty;
	current_bounty endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "stopBounty" );

	self waittill( "disconnect" );

	if( !IsDefined( current_bounty ) )
		return;

	foreach( key, headIcon in current_bounty.entityHeadIcons )
	{	
		if( !isDefined( headIcon ) )
			continue;

		if( self.current_bounty_head_icon == headIcon )
		{
			headIcon destroy();
		}
	}

	//if( isDefined( objID ) )
	//	_objective_delete( objID );
}

unsetBounty()
{	
	self notify( "stopBounty" );
}

// END REVENGE
/////////////////////////////////////////////////////////////////