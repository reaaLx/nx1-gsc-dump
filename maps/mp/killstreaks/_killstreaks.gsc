#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

KILLSTREAK_STRING_TABLE = "mp/killstreakTable.csv";

init()
{
	// &&1 Kill Streak!
	precacheString( &"MP_KILLSTREAK_N" );
	precacheString( &"MP_NUKE_ALREADY_INBOUND" );
	precacheString( &"MP_UNAVILABLE_IN_LASTSTAND" );
	precacheString( &"MP_UNAVAILABLE_WHEN_EMP" );
	precacheString( &"MP_UNAVAILABLE_USING_TURRET" );
	precacheString( &"MP_UNAVAILABLE_WHEN_INCAP" );
	precacheString( &"MP_HELI_IN_QUEUE" );

	level._killstreakWeapons = [];

	initKillstreakData();

	level._killstreakFuncs = [];
	level._killstreakSetupFuncs = [];
	
	level._killStreakMod = 0;

	thread maps\mp\killstreaks\_ac130::init();
	thread maps\mp\killstreaks\_remotemissile::init();
	thread maps\mp\killstreaks\_uav::init();
	thread maps\mp\killstreaks\_airstrike::init();
	thread maps\mp\killstreaks\_airdrop::init();
	thread maps\mp\killstreaks\_helicopter::init();
	thread maps\mp\killstreaks\_autosentry::init();
	thread maps\mp\killstreaks\_emp::init();
	thread maps\mp\killstreaks\_nuke::init();
	thread maps\mp\killstreaks\_exosuit::init();
	thread maps\mp\killstreaks\_rodsofgod::init();
	thread maps\mp\killstreaks\_weapdrop::init();
	thread maps\mp\killstreaks\_jet::init();
	thread maps\mp\killstreaks\_blueshell::init();
	thread maps\mp\killstreaks\_reaper::init();
	thread maps\mp\killstreaks\_lockseekdie::init();
	
	thread maps\mp\_remotedog::init();
	
	//thread maps\mp\killstreaks\_eagle_eye::init();
	thread maps\mp\killstreaks\_spider::init();

	//thread maps\mp\_atbr::atbr_init();

	//	all killstreak weapons that:
	//		- the player actually weilds
	level._killstreakWeildWeapons["uav_strike_marker_mp"] = true;		// uav strike

	level._killstreakRoundDelay = getIntProperty( "scr_game_killstreakdelay", 8 );

	level thread onPlayerConnect();
}


initKillstreakData()
{
	for ( i = 1; true; i++ )
	{
		retVal = tableLookup( KILLSTREAK_STRING_TABLE, 0, i, 1 );
		if ( !isDefined( retVal ) || retVal == "" )
			break;

		streakRef = tableLookup( KILLSTREAK_STRING_TABLE, 0, i, 1 );
		assert( streakRef != "" );

		streakUseHint = tableLookupIString( KILLSTREAK_STRING_TABLE, 0, i, 6 );
		assert( streakUseHint != &"" );
		precacheString( streakUseHint );

		streakEarnDialog = tableLookup( KILLSTREAK_STRING_TABLE, 0, i, 8 );
		assert( streakEarnDialog != "" );
		game[ "dialog" ][ streakRef ] = streakEarnDialog;

		streakAlliesUseDialog = tableLookup( KILLSTREAK_STRING_TABLE, 0, i, 9 );
		assert( streakAlliesUseDialog != "" );
		game[ "dialog" ][ "allies_friendly_" + streakRef + "_inbound" ] = "use_" + streakAlliesUseDialog;
		game[ "dialog" ][ "allies_enemy_" + streakRef + "_inbound" ] = "enemy_" + streakAlliesUseDialog;

		streakAxisUseDialog = tableLookup( KILLSTREAK_STRING_TABLE, 0, i, 10 );
		assert( streakAxisUseDialog != "" );
		game[ "dialog" ][ "axis_friendly_" + streakRef + "_inbound" ] = "use_" + streakAxisUseDialog;
		game[ "dialog" ][ "axis_enemy_" + streakRef + "_inbound" ] = "enemy_" + streakAxisUseDialog;

		streakWeapon = tableLookup( KILLSTREAK_STRING_TABLE, 0, i, 12 );
		precacheItem( streakWeapon );

		streakPoints = int( tableLookup( KILLSTREAK_STRING_TABLE, 0, i, 13 ) );
		assert( streakPoints != 0 );
		maps\mp\gametypes\_rank::registerScoreInfo( "killstreak_" + streakRef, streakPoints );

		streakShader = tableLookup( KILLSTREAK_STRING_TABLE, 0, i, 14 );
		precacheShader( streakShader );

		streakShader = tableLookup( KILLSTREAK_STRING_TABLE, 0, i, 15 );
		if ( streakShader != "" )
			precacheShader( streakShader );

		for ( j = 18; j < 23; j++ )
		{
			streakWeapon = tableLookup( KILLSTREAK_STRING_TABLE, 0, i, j );
			if ( isDefined ( streakWeapon ))
			{
				if ( streakWeapon == "null" )
				{
					break;
				}
				else
				{
					level._killstreakWeapons[streakWeapon] = true;
				}
			}
		}
	}
}


onPlayerConnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );

		reset_killstreaks = 0;
		if ( isDefined( level._alwaysResetKillstreaks ) && ( level._alwaysResetKillstreaks == 1 ) )
		{
			reset_killstreaks = 1;
			player.pers["lastEarnedStreak"] = undefined;		// Should maybe be in the 'reset_killstreaks' if check, but in the name of changing as little as possible, it's here.
			player.pers["cur_kill_streak"] = 0;
		}
		else
		{
			if( !isDefined ( player.pers[ "killstreaks" ] ) )
			{
				reset_killstreaks = 1;
			}
		}
		
		if ( reset_killstreaks == 1 )
			player.pers[ "killstreaks" ] = [];

		if( !isDefined ( player.pers[ "kID" ] ) )
			player.pers[ "kID" ] = 10;

		if( !isDefined ( player.pers[ "kIDs_valid" ] ) )
			player.pers[ "kIDs_valid" ] = [];
		
		player.lifeId = 0;
			
		if ( isDefined( player.pers["deaths"] ) )
			player.lifeId = player.pers["deaths"];

		killstreak_stats_init( player );
		
		player VisionSetMissilecamForPlayer( game["thermal_vision"] );	
	
		player thread onPlayerSpawned();
		player thread onPlayerChangeKit();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill( "spawned_player" );
		self thread killstreakUseWaiter();
		self thread waitForChangeTeam();
		
		self giveOwnedKillstreakItem( true );
	}
}

onPlayerChangeKit()
{
	self endon( "disconnect" );
	
	for ( ;; )
	{
		self waittill( "changed_kit" );
		self giveOwnedKillstreakItem();
	}
}


waitForChangeTeam()
{
	self endon ( "disconnect" );
	
	self notify ( "waitForChangeTeam" );
	self endon ( "waitForChangeTeam" );
	
	for ( ;; )
	{
		self waittill ( "joined_team" );
		clearKillstreaks();
	}
}


isRideKillstreak( streakName )
{
	switch( streakName )
	{
		case "helicopter_minigun":
		case "helicopter_mk19":
		case "ac130":
		case "predator_missile":
		case "remote_mortar":
		case "reaper":
		case "lockseekdie":
			return true;

		default:
			return false;
	}
}

isCarryKillstreak( streakName )
{
	switch( streakName )
	{
		case "sentry":
		case "sentry_gl":
			return true;

		default:
			return false;
	}
}


deadlyKillstreak( streakName )
{
	switch ( streakName )
	{
		case "predator_missile":
		case "precision_airstrike":
		case "harrier_airstrike":
		//case "helicopter":
		//case "helicopter_flares":
		case "stealth_airstrike":
		//case "helicopter_minigun":
		case "ac130":
			return true;
	}
	
	return false;
}


killstreakUsePressed()
{
	streakName = self.pers["killstreaks"][0].streakName;
	lifeId = self.pers["killstreaks"][0].lifeId;
	isEarned = self.pers["killstreaks"][0].earned;
	awardXp = self.pers["killstreaks"][0].awardXp;
	kID = self.pers["killstreaks"][0].kID;
	//tagJC<NOTE>: This strikePoints data is specifically for the upgrade system.  It can be removed if the upgrade system is 
	//             undesirable.
	strikePoints = self.pers["killstreaks"][0].strikePoints;

	assert( isDefined( streakName ) );
	assert( isDefined( level._killstreakFuncs[ streakName ] ) );

	if ( !self isOnGround() && ( isRideKillstreak( streakName ) || isCarryKillstreak( streakName ) ) )
		return ( false );

	if ( self isUsingRemote() )
		return ( false );

	if ( isDefined( self.selectingLocation ) )
		return ( false );
		
	if( IsDefined( level._gceeffect ) )
	{
		if( level._gceeffect )
		{
			return false;	// can't use killstreaks while this effect is activate
		}
	}
		
	if ( deadlyKillstreak( streakName ) && level._killstreakRoundDelay && getGametypeNumLives() )
	{
		if ( level._gracePeriod - level._inGracePeriod < level._killstreakRoundDelay )
		{
			self iPrintLnBold( &"MP_UNAVAILABLE_FOR_N", (level._killstreakRoundDelay - (level._gracePeriod - level._inGracePeriod)) );
			return ( false );
		}
	}

	if ( (level._teamBased && level._teamEMPed[self.team]) || (!level._teamBased && isDefined( level._empPlayer ) && level._empPlayer != self) )
	{
		self iPrintLnBold( &"MP_UNAVAILABLE_WHEN_EMP" );
		return ( false );
	}

	if ( self IsUsingTurret() && ( isRideKillstreak( streakName ) || isCarryKillstreak( streakName ) ) )
	{
		self iPrintLnBold( &"MP_UNAVAILABLE_USING_TURRET" );
		return ( false );
	}
	
	if ( isDefined( self.lastStand )  && isRideKillstreak( streakName ) )
	{
		self iPrintLnBold( &"MP_UNAVILABLE_IN_LASTSTAND" );
		return ( false );
	}
	
	if ( !self isWeaponEnabled() )
		return ( false );

	if ( streakName == "airdrop" || streakName == "airdrop_sentry_minigun" || streakName == "airdrop_mega" )
	{
		if ( !self [[ level._killstreakFuncs[ streakName ] ]]( lifeId, kID ) )
			return ( false );
	}

	else
	{
		if ( !self [[ level._killstreakFuncs[ streakName ] ]]( lifeId ) )
			return ( false );
	}
	
	self usedKillstreak( streakName, awardXp );
	self shuffleKillStreaksFILO( streakName, kID );	
	self giveOwnedKillstreakItem();	
	
	if ( getDvarInt( "upgradeEnabling" ) == 1 )
	{
		self.earnedStrikePoints -= strikePoints;
		self maps\mp\_upgrade::updateESPNumber();
	}

	return ( true );
}


//this overwrites killstreak at index 0 and decrements all other killstreaks (FCLS style)
shuffleKillStreaksFILO( streakName, kID )
{
	self _setActionSlot( 4, "" );

	arraySize = self.pers["killstreaks"].size;

	streakIndex = -1;
	for ( i = 0; i < arraySize; i++ )
	{
		if ( self.pers["killstreaks"][i].streakName != streakName )
			continue;
			
		if ( isDefined( kID ) && self.pers["killstreaks"][i].kID != kID )
			continue;
			
		streakIndex = i;
		break;
	}
	assert( streakIndex >= 0 );

	self.pers["killstreaks"][streakIndex] = undefined;

	for( i = streakIndex + 1; i < arraySize; i++ )	
	{
		if ( i == arraySize - 1 ) 
		{	
			self.pers["killstreaks"][i-1] = self.pers["killstreaks"][i];
			self.pers["killstreaks"][i] = undefined;
		}	
		else
		{
			self.pers["killstreaks"][i-1] = self.pers["killstreaks"][i];
		}	
	}
}


usedKillstreak( streakName, awardXp )
{
	self playLocalSound( "weap_c4detpack_trigger_plr" );

	if ( awardXp )
		self thread [[ level._onXPEvent ]]( "killstreak_" + streakName );

	self thread maps\mp\gametypes\_missions::useHardpoint( streakName );
	
	awardref = maps\mp\_awards::getKillstreakAwardRef( streakName );
	if ( isDefined( awardref ) && !( streakName == "uav" && self.pers["killstreaks"][0].earned == 0 ))
	{
		self thread incPlayerStat( awardref, 1 );
	}

	team = self.team;

	if( level._multiTeamBased )
	{
		for( i = 0; i < level._teamNameList.size; i++ )
		{
			if( team == level._teamNameList[i] )
			{
				thread leaderDialog( "allies_friendly_" + streakName + "_inbound", level._teamNameList[i] );	
			}
			else
			{
				if ( getKillstreakInformEnemy( streakName ))
				{
					thread leaderDialog( "allies_enemy_" + streakName + "_inbound", level._teamNameList[i] );
				}
			}
		}
	}
	else if ( level._teamBased )
	{
		thread leaderDialog( team + "_friendly_" + streakName + "_inbound", team );
		
		if ( getKillstreakInformEnemy( streakName ))
			thread leaderDialog( team + "_enemy_" + streakName + "_inbound", level._otherTeam[ team ] );
	}
	else
	{
		self thread leaderDialogOnPlayer( team + "_friendly_" + streakName + "_inbound" );
		
		if ( getKillstreakInformEnemy( streakName ))
		{
			excludeList[0] = self;
			thread leaderDialog( team + "_enemy_" + streakName + "_inbound", undefined, undefined, excludeList );
		}
	}
}


clearKillstreaks()
{
	foreach ( index, streakStruct in self.pers["killstreaks"] )
		self.pers["killstreaks"][index] = undefined;
}

getFirstPrimaryWeapon()
{
	weaponsList = self getWeaponsListPrimaries();
	index = 0;
	
	//remove any one man army and atbr primaries from the list, we do not want to return those as first primary.
	for( i = 0; i < weaponsList.size; i++ )
	{
		if( weaponsList[i] != "onemanarmy_mp" && weaponsList[i] != "atbr_detonate_mp" )
		{
			index = i;
			break;
		}
	}
	
	assert ( isDefined( weaponsList[index] ));
	assert ( !isKillstreakWeapon( weaponsList[index] ));
	return weaponsList[index];
}


killstreakUseWaiter()
{
	self endon( "disconnect" );
	self endon( "finish_death" );
	level endon( "game_ended" );

	self.lastKillStreak = 0;
	if ( !isDefined( self.pers["lastEarnedStreak"] ) )
		self.pers["lastEarnedStreak"] = undefined;
		
	self thread finishDeathWaiter();

	for ( ;; )
	{
		self waittill ( "weapon_change", newWeapon );
		
		if ( !isAlive( self ) )
			continue;

		if ( !isDefined( self.pers["killstreaks"][0] ) )
			continue;

		if ( newWeapon != getKillstreakWeapon( self.pers["killstreaks"][0].streakName ) )
			continue;

		waittillframeend;

		streakName = self.pers["killstreaks"][0].streakName;
		result = self killstreakUsePressed();
		
		if( result )
		{
			killstreak_stats_record_use( self, streakName );
		}

		//no force switching weapon for ridable killstreaks
		if ( ( !isRideKillstreak( streakName ) || !result ) && ( streakName != "weapdrop" ) )
		{
			if ( !self hasWeapon( self getLastWeapon() ) )
			{
				if ( streakName == "exosuit" )
				{
					self switchToWeapon( self.primaryWeapon );
				}
				else
				{
					self switchToWeapon( self getFirstPrimaryWeapon() );	
				}
			}
			else
			{
				self switchToWeapon( self getLastWeapon() );
			}
		}

		// give time to switch to the near weapon; when the weapon is none (such as during a "disableWeapon()" period
		// re-enabling the weapon immediately does a "weapon_change" to the killstreak weapon we just used.  In the case that 
		// we have two of that killstreak, it immediately uses the second one
		if ( self getCurrentWeapon() == "none" )
		{
			while ( self getCurrentWeapon() == "none" )
				wait ( 0.05 );

			waittillframeend;
		}
	}
}


finishDeathWaiter()
{
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	
	self waittill ( "death" );
	wait ( 0.05 );
	self notify ( "finish_death" );
	self.pers["lastEarnedStreak"] = undefined;
}


checkKillstreakReward( streakCount )
{
	self notify( "got_killstreak", streakCount );

	maxVal = 0;
	killStreaks = [];
	foreach ( streakVal, streakName in self.killStreaks )
	{
		killStreaks[streakName] = streakVal;
		if ( streakVal > maxVal )
			maxVal = streakVal;
	}

	foreach ( streakVal, streakName in self.killStreaks )
	{
		actualVal = streakVal + level._killStreakMod;
		
		if ( actualVal > streakCount )
			break;
		
		if ( isDefined( self.pers["lastEarnedStreak"] ) && killStreaks[streakName] <= killStreaks[self.pers["lastEarnedStreak"]] )
			continue;

		if ( isSubStr( streakName, "-rollover" ) )
		{
			continue;
			/*
			if ( game["defcon"] > 2 )
			{
				self.pers["lastEarnedStreak"] = streakName;
				continue;
			}
			
			useStreakName = strTok( streakName, "-" )[0];
			*/
		}
		else
		{
			useStreakName = streakName;
		}
		
		if ( self tryGiveKillstreak( useStreakName, int(max( actualVal, streakCount )) ) )
		{
			self thread killstreakEarned( useStreakName );
			self.pers["lastEarnedStreak"] = streakName;
		}
	}
}


killstreakEarned( streakName )
{
	if ( self getPlayerData( "killstreaks", 0 ) == streakName )
	{
		self.firstKillstreakEarned = getTime();
	}	
	else if ( self getPlayerData( "killstreaks", 2 ) == streakName && isDefined( self.firstKillstreakEarned ) )
	{
		if ( getTime() - self.firstKillstreakEarned < 20000 )
			self thread maps\mp\gametypes\_missions::genericChallenge( "wargasm" );
	}
}


rewardNotify( streakName, streakVal )
{
	self endon( "disconnect" );

	self maps\mp\gametypes\_hud_message::killstreakSplashNotify( streakName, streakVal );
}


tryGiveKillstreak( streakName, streakVal )
{
	level notify ( "gave_killstreak", streakName );

	if ( !level._gameEnded )
		self thread rewardNotify( streakName, streakVal );

	self giveKillstreak( streakName, streakVal, true );
	return true;
}


giveKillstreak( streakName, isEarned, awardXp, owner, from_crate )
{
	self endon ( "disconnect" );
	
	if ( getDvarInt( "upgradeEnabling" ) == 1 )
	{
		self.earnedStrikePoints += isEarned;
		self maps\mp\_upgrade::updateESPNumber();
	}

	if( !isDefined( from_crate ))
	{
		from_crate = 0;
	}
	
	force_drop = "none";
	if( getKillstreakIsDropStreak( streakName ) == true && from_crate == 0 )
	{
		force_drop = streakName;
		streakName = "airdrop";
	}

	weapon = getKillstreakWeapon( streakName );

	self._pre_killstreak_weapon_name = self getCurrentWeapon();
	self._post_killstreak_weapon_name = weapon;

	self giveKillstreakWeapon( weapon );
	
	// shuffle existing killstreaks up a notch
	for( i = self.pers["killstreaks"].size; i >= 0; i-- )	
		self.pers["killstreaks"][i + 1] = self.pers["killstreaks"][i]; 	
	
	self.pers["killstreaks"][0] = spawnStruct();
	self.pers["killstreaks"][0].streakName = streakName;
	self.pers["killstreaks"][0].earned = isDefined( isEarned ) && isEarned;
	self.pers["killstreaks"][0].awardxp = isDefined( awardXp ) && awardXp;
	self.pers["killstreaks"][0].owner = owner;
	self.pers["killstreaks"][0].force_drop = force_drop;

	self.pers["killstreaks"][0].kID = self.pers["kID"];
	//tagJC<NOTE>: This strikePoints data is specifically for the upgrade system.  It can be removed if the upgrade system is 
	//             undesirable.
	self.pers["killstreaks"][0].strikePoints = isEarned;
	self.pers["kIDs_valid"][self.pers["kID"]] = true;

	self.pers["kID"]++;

	if ( !self.pers["killstreaks"][0].earned )
		self.pers["killstreaks"][0].lifeId = -1;
	else
		self.pers["killstreaks"][0].lifeId = self.pers["deaths"];
	
	// probably obsolete unless we bring back the autoshotty	
	if ( isdefined( level._killstreakSetupFuncs[ streakName ] ) )
		self [[ level._killstreakSetupFuncs[ streakName ] ]]();
		
	if ( isDefined( isEarned ) && isEarned && isDefined( awardXp ) && awardXp )
		self notify( "received_earned_killstreak" );
}


giveKillstreakWeapon( weapon )
{
	weaponList = self getWeaponsListItems();
	
	foreach ( item in weaponList )
	{
		if ( !isSubStr( item, "killstreak" ) )
			continue;
	
		if ( self getCurrentWeapon() == item )
			continue;
			
		self takeWeapon( item );
	}
	
	self _giveWeapon( weapon, 0 );
	self _setActionSlot( 4, "weapon", weapon );
}


getStreakCost( streakName )
{
	return int( tableLookup( KILLSTREAK_STRING_TABLE, 1, streakName, 4 ) );
}


getKillstreakHint( streakName )
{
	return tableLookupIString( KILLSTREAK_STRING_TABLE, 1, streakName, 6 );
}


getKillstreakInformEnemy( streakName )
{
	return int( tableLookup( KILLSTREAK_STRING_TABLE, 1, streakName, 11 ) );
}


getKillstreakSound( streakName )
{
	return tableLookup( KILLSTREAK_STRING_TABLE, 1, streakName, 7 );
}


getKillstreakDialog( streakName )
{
	return tableLookup( KILLSTREAK_STRING_TABLE, 1, streakName, 8 );
}


getKillstreakWeapon( streakName )
{
	return tableLookup( KILLSTREAK_STRING_TABLE, 1, streakName, 12 );
}

getKillstreakIcon( streakName )
{
	return tableLookup( KILLSTREAK_STRING_TABLE, 1, streakName, 14 );
}

getKillstreakCrateIcon( streakName )
{
	return tableLookup( KILLSTREAK_STRING_TABLE, 1, streakName, 15 );
}

getKillstreakIsDropStreak( streakName )
{
	val = tableLookup( KILLSTREAK_STRING_TABLE, 1, streakName, 17 );
	if( val == "drop" )
		return true;
	
	return false;
}

giveOwnedKillstreakItem( skipDialog )
{
	if ( !isDefined( self.pers["killstreaks"][0] ) )
		return;
		
	streakName = self.pers["killstreaks"][0].streakName;

	weapon = getKillstreakWeapon( streakName );
	self giveKillstreakWeapon( weapon );

	if ( !isDefined( skipDialog ) && !level._inGracePeriod )
		self leaderDialogOnPlayer( streakName, "killstreak_earned" );
}


initRideKillstreak( preFinishCallback )
{
	self _disableUsability();
	result = self initRideKillstreak_internal( preFinishCallback );

	if ( isDefined( self ) )
		self _enableUsability();
		
	return result;
}

initRideKillstreak_internal( preFinishCallback )
{
	laptopWait = self waittill_any_timeout( 1.0, "disconnect", "death", "weapon_switch_started" );
	
	if ( laptopWait == "weapon_switch_started" )
		return ( "fail" );

	if ( !isAlive( self ) )
		return "fail";

	if ( laptopWait == "disconnect" || laptopWait == "death" )
	{
		if ( laptopWait == "disconnect" )
			return ( "disconnect" );

		if ( self.team == "spectator" )
			return "fail";

		return ( "success" );		
	}
	
	if ( self isEMPed() || self isNuked() )
	{
		return ( "fail" );
	}
	
	self VisionSetNakedForPlayer( "black_bw", 0.75 );
	blackOutWait = self waittill_any_timeout( 0.80, "disconnect", "death" );

	if ( blackOutWait != "disconnect" ) 
	{
		if ( IsDefined( preFinishCallback ))
		{
			self [[preFinishCallback]]();
		}
		
		self thread clearRideIntro( 1.0 );
		
		if ( self.team == "spectator" )
			return "fail";
	}

	if ( !isAlive( self ) )
		return "fail";

	if ( self isEMPed() || self isNuked() )
		return "fail";
	
	if ( blackOutWait == "disconnect" )
		return ( "disconnect" );
	else
		return ( "success" );		
}


clearRideIntro( delay )
{
	self endon( "disconnect" );

	if ( isDefined( delay ) )
		wait( delay );

	//self freezeControlsWrapper( false );
	
	if ( !isDefined( level._nukeVisionInProgress ) )
		self VisionSetNakedForPlayer( getDvar( "mapname" ), 0 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
///ScriptDocBegin
"Name: killstreak_stats_init()"
"CallOn: Nothing"
"Summary: To init our killstreak stats system."
"Author: Eric Milota"
"Returns: None"
"Module: c:\trees\nx1\game\share\raw\maps\mp\killstreaks\_killstreaks.gsc"
"Example: killstreak_stats_init( player );"
"SPMP: both"
///ScriptDocEnd
*/
killstreak_stats_init( player )
{
	player._killstreak_stats_used_array = [];
	
	//println( "killstreak_stats_init() Called." );
	//bbPrint( "breakpoint: " );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
///ScriptDocBegin
"Name: killstreak_stats_find_item()"
"CallOn: Nothing"
"Summary: To find an item in our array."
"Author: Eric Milota"
"Returns: index 0...x of our entry, or -1 if not found"
"Module: C:\trees\nx1\game\share\raw\maps\mp\gametypes\_weapons.gsc"
"Example: index = killstreak_stats_find_item(player, streakname);"
"SPMP: both"
///ScriptDocEnd
*/
killstreak_stats_find_item(player, streakname)
{
	if( IsDefined( player._killstreak_stats_used_array ) )
	{
		for( index = 0; index < player._killstreak_stats_used_array.size; index++ )
		{
			item = player._killstreak_stats_used_array[ index ];
			
			if( item.streakname == streakname )
			{
				return index;
			}
		}
	}
	
	return -1;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
///ScriptDocBegin
"Name: killstreak_stats_add_item()"
"CallOn: Nothing"
"Summary: To add an item in our array."
"Author: Eric Milota"
"Returns: index 0...x of our entry, or -1 if error"
"Module: C:\trees\nx1\game\share\raw\maps\mp\gametypes\_weapons.gsc"
"Example: index = killstreak_stats_add_item(player, streakname);"
"SPMP: both"
///ScriptDocEnd
*/
killstreak_stats_add_item(player, streakname)
{
	if( IsDefined( player._killstreak_stats_used_array ) )
	{
		index = player._killstreak_stats_used_array.size;

		item = spawnstruct();
		item.streakname = streakname;
		item.usedcount = 0;
		
		player._killstreak_stats_used_array[ index ] = item;
		
		return index;
	}

	return -1;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
///ScriptDocBegin
"Name: killstreak_stats_dump()"
"CallOn: Nothing"
"Summary: To dump out killstreak stats."
"Author: Eric Milota"
"Returns: None"
"Module: c:\trees\nx1\game\share\raw\maps\mp\killstreaks\_killstreaks.gsc"
"Example: killstreak_stats_dump( player );"
"SPMP: both"
///ScriptDocEnd
*/
killstreak_stats_dump( player )
{
	if( IsDefined( player._killstreak_stats_used_array ) )
	{
		//println( "killstreak_stats_dump() Called.  There are " + player._killstreak_stats_used_array.size + " entries." );

		for( index = 0; index < player._killstreak_stats_used_array.size; index++ )
		{
			item = player._killstreak_stats_used_array[ index ];
			
			//println( "killstreak_stats_dump() : '" + item.streakname + "', usedcount = " +  item.usedcount );
		}

		//bbPrint( "breakpoint: " );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
///ScriptDocBegin
"Name: killstreak_stats_dump_stats_to_black_box()"
"CallOn: Nothing"
"Summary: To dump out killstreak usage stats to the black box."
"Author: Eric Milota"
"Returns: None"
"Module: c:\trees\nx1\game\share\raw\maps\mp\killstreaks\_killstreaks.gsc"
"Example: killstreak_stats_dump_stats_to_black_box( player );"
"SPMP: both"
///ScriptDocEnd
*/
killstreak_stats_dump_stats_to_black_box( player )
{
	if( IsDefined( player._killstreak_stats_used_array ) )
	{
		xuid = player GetXuid();
		
		//println( "killstreak_stats_dump_stats_to_black_box() Called.  There are " + player._killstreak_stats_used_array.size + " entries." );

		for( index = 0; index < player._killstreak_stats_used_array.size; index++ )
		{
			item = player._killstreak_stats_used_array[ index ];
			
			//println( "killstreak_stats_dump_stats_to_black_box() : xuid = " + xuid + ", streakname = '" + item.streakname + "', usedcount = " +  item.usedcount );
			bbPrint( "mpkillstreakusage: xuid %llu streakname %s uses %u ", xuid, item.streakname, item.usedcount );
			
			//println( "killstreak_stats_dump_stats_to_black_box() : '" + item.streakname + "', usedcount = " +  item.usedcount );
		}

		//bbPrint( "breakpoint: " );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
///ScriptDocBegin
"Name: killstreak_stats_record_use()"
"CallOn: Nothing"
"Summary: To record a killstreak use."
"Author: Eric Milota"
"Returns: None"
"Module: c:\trees\nx1\game\share\raw\maps\mp\killstreaks\_killstreaks.gsc"
"Example: killstreak_stats_record_use( player, streakname );"
"SPMP: both"
///ScriptDocEnd
*/
killstreak_stats_record_use( player, streakname )
{
	if( IsDefined( player._killstreak_stats_used_array ) )
	{
		//println( "killstreak_stats_record_use() Called with streakname = '" + streakname + "'." );
		//bbPrint( "breakpoint: " );

		index = killstreak_stats_find_item( player, streakname );
		if( index < 0 )
		{
			index = killstreak_stats_add_item( player, streakname );
		}
		
		player._killstreak_stats_used_array[ index ].usedcount++;

		//println( "killstreak_stats_record_use() Called with streakname = '" + streakname + "'.  usedcount = " +  player._killstreak_stats_used_array[ index ].usedcount);
		//bbPrint( "breakpoint: " );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
///ScriptDocBegin
"Name: killstreak_stats_get_use_count()"
"CallOn: Nothing"
"Summary: To get a count of killstreaks used by a given player."
"Author: Eric Milota"
"Returns: None"
"Module: c:\trees\nx1\game\share\raw\maps\mp\killstreaks\_killstreaks.gsc"
"Example: count = killstreak_stats_get_use_count( player );"
"SPMP: both"
///ScriptDocEnd
*/
killstreak_stats_get_use_count( player )
{
	if( IsDefined( player._killstreak_stats_used_array ) )
	{
		usedcount = 0;
		for( index = 0; index < player._killstreak_stats_used_array.size; index++ )
		{
			item = player._killstreak_stats_used_array[ index ];
			
			usedcount += item.usedcount;
		}
		
		//println( "killstreak_stats_get_use_count() returning " + usedcount );
		//bbPrint( "breakpoint: " );

		return usedcount;
	}
	
	return 0;
}

isEnemyAirKillstreakActive( player )
{
	foreach ( heli in level._helis )
	{
		if ( isEnemyKillStreak ( player, heli ) )
		{
			return true;
		}
	}
			
	foreach ( littleBird in level._littleBird )
	{
		if ( isEnemyKillStreak ( player, littleBird ) )
		{
			return true;
		}
	}
	
	if ( isDefined ( level._raven ) )
	{
		if ( isEnemyKillStreak ( player, level._raven ) )
		{
			return true;
		}
	}
	
	if ( level._teamBased )
	{
		foreach ( uav in level._uavModels["allies"] )
		{
			if ( isEnemyKillStreak ( player, uav ) )
			{
				return true;
			}
		}

		foreach ( uav in level._uavModels["axis"] )
		{
			if ( isEnemyKillStreak ( player, uav ) )
			{
				return true;
			}
		}
	}
	else
	{	
		foreach ( uav in level._uavModels )
		{
			if ( isEnemyKillStreak ( player, uav ) )
			{
				return true;
			}
		}
	}
	
	if ( isDefined( level._ac130player ) )
	{
		if ( isEnemyKillStreak ( player, level._ac130 ) )
		{
			return true;
		}
	}
	return false;
}

isEnemyKillStreak ( player, killstreak )
{
	if ( isDefined ( player.team ) && isDefined ( killstreak.owner.team ) && ( player.team != killstreak.owner.team ) )
		return true;
	else
		return false;
}