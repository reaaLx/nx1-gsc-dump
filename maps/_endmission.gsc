#include maps\_utility;
#include common_scripts\utility;

emptyMissionDifficultyStr 	= "00000000000000000000000000000000000000000000000000";

SOTABLE_COL_INDEX			= 0;
SOTABLE_COL_REF				= 1;
SOTABLE_COL_NAME 			= 2;
SOTABLE_COL_GROUP			= 13;
SOTABLE_COL_UNLOCK			= 5;

main()
{
	missionSettings = [];

	// levels and missions are listed in order
	missionIndex = 0;// only one missionindex( vignettes in CoD2, no longer exist but I'm going to use this script anyway because it's got good stuff in it. - Nate

	//				addLevel( levelName, 		keepWeapons,achievement, 					skipsSuccess, 	veteran_achievement )
	missionSettings = createMission( "THE_PRICE_OF_WAR" );
	//missionSettings addLevel( "nx_repel",		false,		undefined,						true,			undefined );
	missionSettings addLevel( "nx_hithard",		false,		undefined,						true,			undefined );
	missionSettings addLevel( "nx_hithard_b",		false,		undefined,						true,			undefined );
	//missionSettings addLevel( "nx_norad",		false,		undefined,						true,			undefined );
	missionSettings addLevel( "nx_lunar",		false,		undefined,						true,			undefined );
	//missionSettings addLevel( "nx_cyber",		false,		undefined,						true,			undefined );
	//missionSettings addLevel( "nx_launch",		false,		undefined,						true,			undefined );
	//missionSettings addLevel( "nx_prep",		false,		undefined,						true,			undefined );
	//missionSettings addLevel( "nx_subpen",		false,		undefined,						true,			undefined );

	// need to add SO maps differently, need to save script vars
	//--------
	/*
	TO DO:
	*/

	level._specOpsGroups = [];

	setupSoGroup( "so_alpha" );
	setupSoGroup( "so_bravo" );
	setupSoGroup( "so_charlie" );
	setupSoGroup( "so_delta" );
	setupSoGroup( "so_echo" );

    if( is_specialop() )
    {
		specOpsSettings = createMission( "SPECIAL_OPS" );
		//addSpecOpLevel( levelName, achievement, veteran_achievement )
		specOpsSettings addSpecOpLevel( "so_showers_gulag"			, false, false ); 	// offset: 0
		specOpsSettings addSpecOpLevel( "so_killspree_invasion"		, false, false ); 	// offset: 1
		specOpsSettings addSpecOpLevel( "so_ac130_co_hunted"		, false, false ); 	// offset: 2
		specOpsSettings addSpecOpLevel( "so_killspree_favela"		, false, false ); 	// offset: 3
		specOpsSettings addSpecOpLevel( "so_assault_oilrig"			, false, false ); 	// offset: 4
		specOpsSettings addSpecOpLevel( "so_defense_invasion"		, false, false ); 	// offset: 5
		specOpsSettings addSpecOpLevel( "so_escape_airport"			, false, false ); 	// offset: 6
		specOpsSettings addSpecOpLevel( "so_forest_contingency"		, false, false ); 	// offset: 7
		specOpsSettings addSpecOpLevel( "so_download_arcadia"		, false, false ); 	// offset: 8
		specOpsSettings addSpecOpLevel( "so_demo_so_bridge"			, false, false ); 	// offset: 9
		specOpsSettings addSpecOpLevel( "so_crossing_so_bridge"		, false, false ); 	// offset: 10
		specOpsSettings addSpecOpLevel( "so_snowrace1_cliffhanger"	, false, false ); 	// offset: 11
		specOpsSettings addSpecOpLevel( "so_snowrace2_cliffhanger"	, false, false ); 	// offset: 12
		specOpsSettings addSpecOpLevel( "so_rooftop_contingency"	, false, false ); 	// offset: 13
		specOpsSettings addSpecOpLevel( "so_sabotage_cliffhanger"	, false, false ); 	// offset: 14
		specOpsSettings addSpecOpLevel( "so_defuse_favela_escape"	, false, false ); 	// offset: 15
		specOpsSettings addSpecOpLevel( "so_takeover_estate"		, false, false ); 	// offset: 16
		specOpsSettings addSpecOpLevel( "so_takeover_oilrig"		, false, false ); 	// offset: 17
		specOpsSettings addSpecOpLevel( "so_intel_boneyard"			, false, false ); 	// offset: 18
		specOpsSettings addSpecOpLevel( "so_juggernauts_favela"		, false, false ); 	// offset: 19
		specOpsSettings addSpecOpLevel( "so_hidden_so_ghillies"		, false, false ); 	// offset: 20
		specOpsSettings addSpecOpLevel( "so_chopper_invasion"		, false, false ); 	// offset: 21
		specOpsSettings addSpecOpLevel( "so_killspree_trainer"		, false, false ); 	// offset: 22

		level._specOpsSettings = specOpsSettings;
	}

//--------

/*
	missionSettings addLevel( "cargoship", false, "MAKE_THE_JUMP", true, "THE_PACKAGE" );
	missionSettings addLevel( "coup", false, undefined, true );
	missionSettings addLevel( "blackout", false, "COMPLETE_BLACKOUT", true, "THE_RESCUE" );
	missionSettings addLevel( "armada", false, undefined, true, "THE_SEARCH" );
	missionSettings addLevel( "bog_a", false, "SAVE_THE_BACON", true, "THE_BOG" );
	missionSettings addLevel( "hunted", false, undefined, true, "THE_ESCAPE" );
	missionSettings addLevel( "ac130", false, "BRING_EM_HOME", true, "THE_ESCAPE" );
	missionSettings addLevel( "bog_b", false, undefined, true, "THE_BOG" );
	missionSettings addLevel( "airlift", false, undefined, true, "THE_FIRST_HORSEMAN" );
	missionSettings addLevel( "aftermath", false, undefined, true );
	missionSettings addLevel( "village_assault", false, "COMPLETE_VILLAGE_ASSAULT", true, "THE_SECOND_HORSEMAN" );
	missionSettings addLevel( "scoutsniper", true, undefined, true, "THE_SHOT" );
	missionSettings addLevel( "sniperescape", false, "PIGGYBACK_RIDE", true, "THE_SHOT" );
	missionSettings addLevel( "village_defend", false, undefined, true, "THE_THIRD_HORSEMAN" );
	missionSettings addLevel( "ambush", false, "DESPERATE_MEASURES", true, "THE_THIRD_HORSEMAN" );
	missionSettings addLevel( "icbm", true, undefined, true, "THE_ULTIMATUM" );
	missionSettings addLevel( "launchfacility_a", true, undefined, true, "THE_ULTIMATUM" );
	missionSettings addLevel( "launchfacility_b", true, undefined, true, "THE_ULTIMATUM" );
	missionSettings addLevel( "jeepride", false, "WIN_THE_WAR", true, "THE_FOURTH_HORSEMAN" );
	missionSettings addLevel( "airplane", false, undefined, undefined, "MILE_HIGH_CLUB" );
*/

	level._missionSettings = missionSettings;

	/#
	thread ui_debug_clearall();
	#/
}

setupSoGroup( so_ref )
{
	level._specOpsGroups[ so_ref ] 				= spawnStruct();
	level._specOpsGroups[ so_ref ].ref		 	= so_ref;
	level._specOpsGroups[ so_ref ].num			= int( tablelookup( "sp/specopstable.csv", SOTABLE_COL_REF, so_ref, SOTABLE_COL_INDEX ) ) - 1000;
	//level.specOpsGroups[ so_ref ].string_name = tablelookup( "sp/specopstable.csv", SOTABLE_COL_REF, so_ref, SOTABLE_COL_NAME );
	level._specOpsGroups[ so_ref ].unlock		= int( tablelookup( "sp/specopstable.csv", SOTABLE_COL_REF, so_ref, SOTABLE_COL_UNLOCK ) );
}


_nextmission( endgame )
{
	/#
	if ( getdvarint( "nextmission_disable" ) )
	{
		iprintlnbold( "Nextmission Here, but disabled!" );
		return;
	}
	#/

	//are we watching credits?
	if ( level._script == "ending" && level._level_mode != "credits_1" )
	{
		setsaveddvar( "ui_nextMission", "0" );
		missionSuccess( "trainer" );
		return;
	}

	if ( !isdefined( endgame ) )
	{
		endgame = false;
	}

	level notify( "nextmission" );
	level._nextmission = true;
	level._player enableinvulnerability();

	levelIndex = undefined;

	setsaveddvar( "ui_nextMission", "1" );
	setdvar( "ui_showPopup", "0" );
	setdvar( "ui_popupString", "" );

	if ( level._script == "ending" )
	{
		level._script = "af_chase";
		_nextmission( true );
		level._script = "ending";
	}

	levelIndex = level._missionSettings getLevelIndex( level._script );

	maps\_gameskill::auto_adust_zone_complete( "aa_main_" + level._script );
	
	if ( !isDefined( levelIndex ) )
	{
		// run the same mission again if the nextmission is not defiend.
		MissionSuccess( level._script );
		return;
	}

	if ( level._script != "ending" && !( level._script == "af_chase" && endgame ) )
	{
		maps\_utility::level_end_save();
	}

	if ( level._script != "af_chase" || endgame )
	{
		// update mission difficulty and highest completed profile values
		level._missionSettings setLevelCompleted( levelIndex );

		if ( ( level._player GetLocalPlayerProfileData( "highestMission" ) ) < levelindex + 1 && ( level._script == "ending" ) && getdvarint( "mis_cheat" ) == 0 )
		{
	        setdvar( "ui_sp_unlock", "0" );// set reset value to 0
	        setdvar( "ui_sp_unlock", "1" );
	    }

	    /#
	    PrintLn( ">> SP PERCENT UPDATE - _nextmission()" );
	    #/
	    completion_percentage = updateSpPercent();

		/#
		if ( getdvarint( "ui_debug_setlevel" ) != 0 )
		{
			_setHighestMissionIfNotCheating( getdvarint( "ui_debug_clearlevel" ) );
			level._missionSettings setLevelCompleted( max( 0, getdvarint( "ui_debug_clearlevel" ) - 1 ) );

			setdvar( "ui_debug_setlevel", "" );
		}

		// Debug prints
		if ( completion_percentage < level._player GetLocalPlayerProfileData( "percentCompleteSP" ) )
		{
			PrintLn( ">> SP DEBUG: 					[ WARNING! NEW:" + completion_percentage + "% < OLD:" + level._player GetLocalPlayerProfileData( "percentCompleteSP" ) + "% ]\n" );
		}

		PrintLn( ">> SP DEBUG: 				[ setlevel:" + getdvarint( "ui_debug_setlevel" ) + " clearall:" + getdvarint( "ui_debug_clearall" ) + " ]" );
		PrintLn( ">> SP PLAYER DIFFICULTY: 		[" + (level._player GetLocalPlayerProfileData( "missionHighestDifficulty" )) + "]" );
		PrintLn( ">> SP PERCENTAGE COMPLETED:		[" + completion_percentage/100 + "%]" );
		PrintLn( ">> SP LEVEL INDEX: 			[" + levelIndex + "]" );
		PrintLn( ">> SP LEVEL NAME: 			[" + level._script + "]" );
		PrintLn( ">> SP LEVELS COMPLETED: 		[" + (level._player GetLocalPlayerProfileData( "highestMission" )) + "]" );
		PrintLn( ">> SP MAX LEVELS: 			[" + level._missionSettings.levels.size + "]" );
		#/

		UpdateGamerProfile();

		if ( level._missionSettings hasAchievement( levelIndex ) )
		{
			maps\_utility::giveachievement_wrapper( level._missionSettings getAchievement( levelIndex ) );
		}

		if ( level._missionSettings hasLevelVeteranAward( levelIndex ) && getLevelCompleted( levelIndex ) == 4
			 && level._missionSettings check_other_hasLevelVeteranAchievement( levelIndex ) )
		{
			maps\_utility::giveachievement_wrapper( level._missionSettings getLevelVeteranAward( levelIndex ) );
		}

		if ( level._missionSettings hasMissionHardenedAward()
			 && level._missionSettings getLowestSkill() > 2 )
		{
			giveachievement_wrapper( level._missionSettings getHardenedAward() );
		}

		nextLevelIndex = level._missionSettings.levels.size;
	}
	if ( level._script == "af_chase" && endgame )
	{
		return;
	}

	if ( level._script == "ending" && level._level_mode == "credits_1" )
	{
		flag_wait( "af_chase_nextmission" );
	}

	if ( level._script == "airplane" || level._script == "ending" )
	{
		setsaveddvar( "ui_nextMission", "0" );
		//setdvar( "ui_victoryquote", "@VICTORYQUOTE_IW_THANKS_FOR_PLAYING" );
		missionSuccess( "trainer" );
		return;
	}
	else
	{
		nextLevelIndex = levelIndex + 1;
		if ( nextLevelIndex >= level._missionSettings.levels.size )
		{
			missionSuccess( level._missionSettings getLevelName( levelIndex ) );
			return;
		}
	}

	if ( arcadeMode() )
	{
		if ( !getdvarint( "arcademode_full" ) )
		{
			setsaveddvar( "ui_nextMission", "0" );
			missionSuccess( level._script );
			return;
		}

		if ( level._script == "cargoship" )
		{
			changelevel( "blackout", level._missionSettings getKeepWeapons( levelIndex ) );
			return;
		}
		else if ( level._script == "airlift" )
		{
			changelevel( "village_assault", level._missionSettings getKeepWeapons( levelIndex ) );
			return;
		}
		else if ( level._script == "jeepride" )
		{
			changelevel( "airplane", level._missionSettings getKeepWeapons( levelIndex ) );
			return;
		}
	}

	if ( level._missionSettings skipssuccess( levelIndex ) )
	{
		changelevel( level._missionSettings getLevelName( nextLevelIndex ), level._missionSettings getKeepWeapons( levelIndex ) );
	}
	else
	{
		missionSuccess( level._missionSettings getLevelName( nextLevelIndex ), level._missionSettings getKeepWeapons( levelIndex ) );
	}

	// DEMO BUILD
	// */
}

_endmission_goto_frontend()
{
	MissionSuccess( level._script );
	return;
}

updateSpPercent()
{
	completion_percentage = int( getTotalpercentCompleteSP()*100 );

	if( getdvarint( "mis_cheat" ) == 0 )
	{
		assertex( ( completion_percentage >= 0 && completion_percentage <= 10000 ), "SP's Completion percentage [ " + completion_percentage + "% ] is outside of 0 to 100 range!" );
		level._player SetLocalPlayerProfileData( "percentCompleteSP", completion_percentage );
	}

	return completion_percentage;
}

getTotalpercentCompleteSP()
{
	/*
	SP STATS:

	Game Progression  	60%    	-50
	Hardened Progress  	60%   	-25
	Veteran Progress  	60%    	-10
	Intel Items  		21/45   -15
	--------------------------------
	Total    			x%		-100
	Play Time			##:##:##
	*/

	stat_progression = max( getStat_easy(), getStat_regular() ); // easy is always higher than regular anyways...
	stat_progression_ratio = 0.5/1;
	/#
		PrintLn( ">> SP STAT REGULAR: " + stat_progression + "%" + "(" + stat_progression_ratio*100 + "%)" );
	#/

	stat_hardened = getStat_hardened();
	stat_hardened_ratio = 0.25/1;
	/#
		PrintLn( ">> SP STAT HARDENED: " + stat_hardened + "%" + "(" + stat_hardened_ratio*100 + "%)" );
	#/

	stat_veteran = getStat_veteran();
	stat_veteran_ratio = 0.1/1;
	/#
		PrintLn( ">> SP STAT VETERAN: " + stat_veteran + "%" + "(" + stat_veteran_ratio*100 + "%)" );
	#/

	stat_intel = getStat_intel();
	stat_intel_ratio = 0.15/1;
	/#
		PrintLn( ">> SP STAT INTEL: " + stat_intel + "%" + "(" + stat_intel_ratio*100 + "%)" );
	#/

	assertex( ( stat_progression_ratio + stat_hardened_ratio + stat_veteran_ratio + stat_intel_ratio ) <= 1.0, "Total sum of SP progress breakdown contributes to more than 100%!" );

	total_progress = 0.0;
	total_progress += stat_progression_ratio*stat_progression;
	total_progress += stat_hardened_ratio*stat_hardened;
	total_progress += stat_veteran_ratio*stat_veteran;
	total_progress += stat_intel_ratio*stat_intel;

	assertex( total_progress <= 100.0, "Total Percentage calculation is out of bound, larger then 100%" );
	/#
		PrintLn( ">> SP STAT TOTAL: " + total_progress + "%" );
	#/

	return total_progress;
}

// recruit and regular difficulty
getStat_progression( difficulty )
{
	assert( isdefined( level._missionSettings ) );
	assert( isdefined( level._script ) );

	difficulty_string = (level._player GetLocalPlayerProfileData( "missionHighestDifficulty" ));

	levels = 0;
	notplayed = [];
	skipped = false;
	// level.missionSettings.levels.size - 1 : the minus one is to remove the credits level
	for ( i = 0; i < level._missionSettings.levels.size-1; i++ )
	{
		if ( int( difficulty_string[ i ] ) >= difficulty )
			levels++;
	}

	completion = ( levels/(level._missionsettings.levels.size-1) )*100;
	return completion; // 0->100
}

getStat_easy()
{
	easy = 1;
	return getStat_progression( easy ); // 0->100
}

getStat_regular()
{
	regular = 2;
	return getStat_progression( regular ); // 0->100
}

getStat_hardened()
{
	hardened = 3;
	return getStat_progression( hardened ); // 0->100
}

getStat_veteran()
{
	veteran = 4;
	return getStat_progression( veteran ); // 0->100
}

getStat_intel()
{
	total_intel_items = 45;
	intel_percentage = ( (level._player GetLocalPlayerProfileData( "cheatPoints" ) )/total_intel_items )*100;
	return intel_percentage; // 0->100
}

//allMissionsCompleted( difficulty )
//{
//	difficulty += 10;
//	for ( index = 0; index < level.missionSettings.size; index++ )
//	{
//		missionDvar = getMissionDvarString( index );
//		if ( getdvarInt( missionDvar ) < difficulty )
//			return( false );
//	}
//	return( true );
//}

getLevelCompleted( levelIndex )
{
	return int( (level._player GetLocalPlayerProfileData( "missionHighestDifficulty" ))[ levelIndex ] );
}

getSoLevelCompleted( levelIndex )
{
	return int( (level._player GetLocalPlayerProfileData( "missionSOHighestDifficulty" ))[ levelIndex ] );
}

setSoLevelCompleted( levelIndex )
{
	levelOffset = levelIndex;

	foreach( player in level._players )
	{
		if ( isdefined( player.eog_noreward ) && player.eog_noreward )
			continue;

		specOpsString = player GetLocalPlayerProfileData( "missionSOHighestDifficulty" );

		if ( !isdefined( specOpsString ) )
			continue;

		if ( isdefined( player.award_no_stars ) )
			continue;

		pre_total_stars = 0;
		for ( i = 0; i < specOpsString.size; i++ )
			pre_total_stars += max( 0, int( specOpsString[ i ] ) - 1 );

		if ( specOpsString.size == 0 )
			specOpsString = emptyMissionDifficultyStr;

		// if profile has no zeros for unplayed levels, we need to populate it with zeros
		while( levelOffset >= specOpsString.size )
			specOpsString += "0";

		assertex( isdefined( level._specops_reward_gameskill ), "Game skill not setup correctly for coop." );
		gameskill = level._specops_reward_gameskill;

		if ( isdefined( player.forcedGameSkill ) )
			gameskill = player.forcedGameSkill;

		if ( int( specOpsString[ levelOffset ] ) > gameskill )
			continue;

		newString = "";
		for ( index = 0; index < specOpsString.size; index++ )
		{
			if ( index != levelOffset )
				newString += specOpsString[ index ];
			else
				newString += gameskill + 1;
		}

		post_total_stars = 0;
		for ( i = 0; i < newString.size; i++ )
			post_total_stars += max( 0, int( newString[ i ] ) - 1 );

		delta_total_stars = post_total_stars - pre_total_stars;
		if ( delta_total_stars > 0 )
		{
			player.eog_firststar = is_first_difficulty_star( newString );
			player.eog_newstar = true;
			player.eog_newstar_value = delta_total_stars;

			foreach ( group in level._specOpsGroups )
			{
				if ( group.unlock == 0 )
					continue;

				if ( level._ps3 && isSplitscreen() && isdefined( level._player2 ) && player == level._player2 )
					continue;

				if ( pre_total_stars < group.unlock && post_total_stars >= group.unlock )
				{
					player.eog_unlock = true;
					player.eog_unlock_value = group.ref;

					if ( getdvarint( "solo_play" ) && ( player == level._player ) )
						setdvar( "ui_last_opened_group", 0 );
				}
			}

			if ( post_total_stars >= 69 )
			{
				player.eog_unlock = true;
				player.eog_unlock_value = "so_completed";
				music_stop( 1 );
			}
		}

		if ( player maps\_specialops_code::can_save_to_profile() || ( isSplitscreen() && level._ps3 && isdefined( level._player2 ) && player == level._player2 ) )
			player SetLocalPlayerProfileData( "missionSOHighestDifficulty", newString );
	}
}

is_first_difficulty_star( specOpsString )
{
	string_size = specOpsString.size;
	if ( string_size > level._specOpsSettings.levels.size )
		string_size = level._specOpsSettings.levels.size;

	stars = 0;
	for ( i=0; i<string_size; i++ )
	{
		if ( int( tablelookup( "sp/specopstable.csv", 0, i, 14 ) ) )
			stars += max ( 0, int( specOpsString[i] ) - 1 );
	}

	// returns false if the current level does not require difficulty selection
	if( int( tablelookup( "sp/specOpsTable.csv", 1, level._script, 14 ) ) == 0 )
		return false;

	return stars == 1;
}

setLevelCompleted( levelIndex )
{
	missionString = ( level._player GetLocalPlayerProfileData( "missionHighestDifficulty" ) );

	newString = "";
	for ( index = 0; index < missionString.size; index++ )
	{
		if ( index != levelIndex )
		{
			newString += missionString[ index ];
		}
		else
		{
			if ( level._gameskill + 1 > int( missionString[ levelIndex ] ) )
				newString += level._gameskill + 1;
			else
				newString += missionString[ index ];
		}
	}

	// levels completed after skipping levels in order will not get its progress recorded, becuase player was hacking or doing devmap
	finalString = "";
	skip = false;
	highest = 0;
	for ( i = 0; i < newString.size; i++ )
	{
		if ( int( newString[ i ] ) == 0 || skip )
		{
			finalString += "0";
			skip = true;
		}
		else
		{
			finalString += newString[ i ];
			highest++;
		}
	}

	_setHighestMissionIfNotCheating( highest );
	_setMissionDiffStringIfNotCheating( finalString );
}


_setHighestMissionIfNotCheating( mission )
{
	//if ( maps\_cheat::is_cheating() || flag( "has_cheated" ) )
	//	return;
	if ( getdvar( "mis_cheat" ) == "1" )
		return;

	level._player SetLocalPlayerProfileData( "highestMission", mission );
}


_setMissionDiffStringIfNotCheating( missionsDifficultyString )
{
	if ( getdvar( "mis_cheat" ) == "1" )
		return;

	level._player SetLocalPlayerProfileData( "missionHighestDifficulty", missionsDifficultyString );
}


getLevelSkill( levelIndex )
{
	levelOffset = levelIndex;

	missionString = (level._player GetLocalPlayerProfileData( "missionHighestDifficulty" ));
	return( int( missionString[ levelOffset ] ) );
}


getMissionDvarString( missionIndex )
{
	if ( missionIndex < 9 )
		return( "mis_0" + ( missionIndex + 1 ) );
	else
		return( "mis_" + ( missionIndex + 1 ) );
}


getLowestSkill()
{
	missionString = (level._player GetLocalPlayerProfileData( "missionHighestDifficulty" ));
	lowestSkill = 4;

	//hack here.  excluding the last level, airplane. normally wouldn't have the -1 on the size.
	for ( index = 0; index < self.levels.size - 1; index++ )
	{
		if ( int( missionString[ index ] ) < lowestSkill )
			lowestSkill = int( missionString[ index ] );
	}
	return( lowestSkill );
}


createMission( HardenedAward )
{
	mission = spawnStruct();
	mission.levels = [];
	mission.prereqs = [];
// 	mission.slideShow = slideShow;
	mission.HardenedAward = HardenedAward;
	return( mission );
}

addLevel( levelName, keepWeapons, achievement, skipsSuccess, veteran_achievement )
{
	assert( isdefined( keepweapons ) );
	levelIndex = self.levels.size;
	self.levels[ levelIndex ] = spawnStruct();
	self.levels[ levelIndex ].name = levelName;
	self.levels[ levelIndex ].keepWeapons = keepWeapons;
	self.levels[ levelIndex ].achievement = achievement;
	self.levels[ levelIndex ].skipsSuccess = skipsSuccess;
	self.levels[ levelIndex ].veteran_achievement = veteran_achievement;
}

addSpecOpLevel( levelName, achievement, veteran_achievement )
{
	levelIndex = self.levels.size;
	self.levels[ levelIndex ] = spawnStruct();
	self.levels[ levelIndex ].name = levelName;
	self.levels[ levelIndex ].achievement = achievement;
	self.levels[ levelIndex ].veteran_achievement = veteran_achievement;

	level_group = tablelookup( "sp/specopstable.csv", SOTABLE_COL_REF, level._script, SOTABLE_COL_GROUP );
	if ( level_group == "" )
		return;

	if( !isdefined( level._specOpsGroups[ level_group ].group_members ) )
		level._specOpsGroups[ level_group ].group_members = [];

	member_size = level._specOpsGroups[ level_group ].group_members.size;
	level._specOpsGroups[ level_group ].group_members[ member_size ] = levelName;
}

addPreReq( missionIndex )
{
	preReqIndex = self.prereqs.size;
	self.prereqs[ preReqIndex ] = missionIndex;
}

getLevelIndex( levelName )
{
	for ( levelIndex = 0; levelIndex < self.levels.size; levelIndex++ )
	{
		if ( self.levels[ levelIndex ].name != levelName )
			continue;

		return( levelIndex );
	}
	return( undefined );
}

getLevelName( levelIndex )
{
	return( self.levels[ levelIndex ].name );
}

getKeepWeapons( levelIndex )
{
	return( self.levels[ levelIndex ].keepWeapons );
}

getAchievement( levelIndex )
{
	return( self.levels[ levelIndex ].achievement );
}

getLevelVeteranAward( levelIndex )
{
	return( self.levels[ levelIndex ].veteran_achievement );
}

hasLevelVeteranAward( levelIndex )
{
	if ( isDefined( self.levels[ levelIndex ].veteran_achievement ) )
		return( true );
	else
		return( false );
}

hasAchievement( levelIndex )
{
	if ( isDefined( self.levels[ levelIndex ].achievement ) )
		return( true );
	else
		return( false );
}

check_other_hasLevelVeteranAchievement( levelIndex )
{
	//check for other levels that have the same Hardened achievement.
	//If they have it and other level has been completed at a hardened level check passes.

	for ( i = 0; i < self.levels.size; i++ )
	{
		if ( i == levelIndex )
			continue;
		if ( ! hasLevelVeteranAward( i ) )
			continue;
		if ( self.levels[ i ].veteran_achievement == self.levels[ levelIndex ].veteran_achievement )
			if ( getLevelCompleted( i ) < 4 )
				return false;
	}
	return true;
}

skipsSuccess( levelIndex )
{
	if ( !isDefined( self.levels[ levelIndex ].skipsSuccess ) )
		return false;
	return true;
}


getHardenedAward()
{
	return( self.HardenedAward );
}


hasMissionHardenedAward()
{
	if ( isDefined( self.HardenedAward ) )
		return( true );
	else
		return( false );
}

getNextLevelIndex()
{
	for ( index = 0; index < self.levels.size; index++ )
	{
		if ( !self getLevelSkill( index ) )
			return( index );
	}
	return( 0 );
}

force_all_complete()
{
	println( "tada!" );
	missionString = (level._player GetLocalPlayerProfileData( "missionHighestDifficulty" ));
	newString = "";
	for ( index = 0; index < missionString.size; index++ )
	{
		if ( index < 20 )
			newString += 2;
		else
			newstring += 0;
	}
	level._player SetLocalPlayerProfileData( "missionHighestDifficulty", newString );
	level._player SetLocalPlayerProfileData( "highestMission", 20 );
}
/#
ui_debug_clearall()
{
	for(;;)
	{
		if( getdvarint( "ui_debug_clearall" ) )
		{
			clearall();
			level._player SetLocalPlayerProfileData( "percentCompleteSP", 0 );

			foreach( player in level._players )
			{
				player SetLocalPlayerProfileData( "missionspecops", 0 );
				player SetLocalPlayerProfileData( "missionsohighestdifficulty", "00000000000000000000000000000000000000000000000000" );
				player SetLocalPlayerProfileData( "percentCompleteSO", 0 );

				best_time_name = tablelookup( "sp/specOpsTable.csv", 1, level._script, 9 );
				if ( isdefined( best_time_name ) && best_time_name != "" )
					player SetLocalPlayerProfileData( best_time_name, 0 );
			}

			setdvar( "ui_debug_clearall", "" );
		}

		wait 0.05;
	}
}
#/
clearall()
{
	level._player SetLocalPlayerProfileData( "missionHighestDifficulty", emptyMissionDifficultyStr );
	level._player SetLocalPlayerProfileData( "highestMission", 1 );
}

credits_end()
{
	changelevel( "airplane", false );
}

coop_eog_summary()
{
	playerNum = 1;
	accuracy = [];
	difficulty = [];
	diffString[ 0 ] = "@MENU_RECRUIT";
	diffString[ 1 ] = "@MENU_REGULAR";
	diffString[ 2 ] = "@MENU_HARDENED";
	diffString[ 3 ] = "@MENU_VETERAN";

	thread maps\_ambient::use_eq_settings( "specialop_fadeout", level._eq_mix_track );
	thread maps\_ambient::blend_to_eq_track( level._eq_mix_track, 10 );

	//----------------------------------------------
	// Set all stat dvars so menu can display stats
	//----------------------------------------------
	foreach ( player in level._players )
	{
		// Names
		setdvar( "player_" + playerNum + "_name", player.playername );

		// Kills
		setdvar( "player_" + playerNum + "_kills", player.stats[ "kills" ] );

		// Difficulty
		difficultyIndex = difficulty.size;
		difficulty[ difficultyIndex ] = player get_player_gameskill();

		assert( isdefined( diffString[ difficulty[ difficultyIndex ] ] ) );
		setdvar( "player_" + playerNum + "_difficulty", diffString[ difficulty[ difficultyIndex ] ] );

		playerNum++ ;
	}

	// Time
	if ( !isdefined( level._challenge_start_time ) )
	{
		// If the mission never started, force it to a time of 0.
		level._challenge_start_time = 0;
		level._challenge_end_time = 0;
	}

	assertex( isdefined( level._challenge_start_time ), "Special Ops missions need to ensure level.challenge_start_time is set before displaying stats." );
	assertex( isdefined( level._challenge_end_time ), "Special Ops missions need to ensure level.challenge_end_time is set before displaying stats." );

	seconds = ( level._challenge_end_time - level._challenge_start_time ) * 0.001;
	setdvar( "elapsed_mission_time", convert_to_time_string( seconds, true ) );

	// callback that sets custom data for eog summary
	if( isdefined( level._eog_summary_callback ) )
	{
		setdvar( "ui_eog_success_heading_player1", "" );
		setdvar( "ui_eog_success_heading_player2", "" );
		create_custom_eog_defaults();
		[[level._eog_summary_callback]]();
	}

	if( isdefined( level._custom_eog_summary ) && level._custom_eog_summary )
		setdvar( "ui_eog_custom", 1 );
	else
		setdvar( "ui_eog_custom", 0 );

	//----------------------------------------------
	// Open summary menus on all players
	//----------------------------------------------

	// opens up end-of-game summary menu for player gameplay performance
	if ( is_coop() )
	{
		reset_eog_popup_dvars();
		// setup eog popups that shows stars earned, unlocks, and new best time
		// player 1
		if( isdefined( level._player.eog_firststar ) && level._player.eog_firststar )
			setdvar( "ui_first_star_player1", level._player.eog_firststar );

		if( isdefined( level._player.eog_newstar ) && level._player.eog_newstar )
			setdvar( "ui_eog_player1_stars", level._player.eog_newstar_value );

		if( isdefined( level._player.eog_unlock ) && level._player.eog_unlock )
			setdvar( "ui_eog_player1_unlock", level._player.eog_unlock_value );

		if( isdefined( level._player.eog_besttime ) && level._player.eog_besttime )
			setdvar( "ui_eog_player1_besttime", level._player.eog_besttime_value );

		if( isdefined( level._player.eog_noreward ) && level._player.eog_noreward )
			setdvar( "ui_eog_player1_noreward", level._player.eog_noreward );

		// player 2
		if( isdefined( level._player2.eog_firststar ) && level._player2.eog_firststar )
			setdvar( "ui_first_star_player2", level._player2.eog_firststar );

		if( isdefined( level._player2.eog_newstar ) && level._player2.eog_newstar )
			setdvar( "ui_eog_player2_stars", level._player2.eog_newstar_value );

		if( isdefined( level._player2.eog_unlock ) && level._player2.eog_unlock )
			setdvar( "ui_eog_player2_unlock", level._player2.eog_unlock_value );

		if( isdefined( level._player2.eog_besttime ) && level._player2.eog_besttime )
			setdvar( "ui_eog_player2_besttime", level._player2.eog_besttime_value );

		if( isdefined( level._player2.eog_noreward ) && level._player2.eog_noreward )
			setdvar( "ui_eog_player2_noreward", level._player2.eog_noreward );

		wait 0.05;
		level._player openpopupmenu( "coop_eog_summary" );
		level._player2 openpopupmenu( "coop_eog_summary2" );
	}
	else
	{
		reset_eog_popup_dvars();

		// setup eog popups that shows stars earned, unlocks, and new best time
		if( isdefined( level._player.eog_firststar ) && level._player.eog_firststar )
			setdvar( "ui_first_star_player1", level._player.eog_firststar );

		if( isdefined( level._player.eog_newstar ) && level._player.eog_newstar )
			setdvar( "ui_eog_player1_stars", level._player.eog_newstar_value );

		if( isdefined( level._player.eog_unlock ) && level._player.eog_unlock )
			setdvar( "ui_eog_player1_unlock", level._player.eog_unlock_value );

		if( isdefined( level._player.eog_besttime ) && level._player.eog_besttime )
			setdvar( "ui_eog_player1_besttime", level._player.eog_besttime_value );

		wait 0.05;
		level._player openpopupmenu( "sp_eog_summary" );
	}
}

create_custom_eog_defaults()
{
	// Don't use any defaults.
	if ( isdefined( level._custom_eog_no_defaults ) && level._custom_eog_no_defaults )
		return;

	foreach ( player in level._players )
	{
		// Time
		if ( !isdefined( level._custom_eog_no_time ) || !level._custom_eog_no_time )
			player use_custom_eog_default_time();

		// Difficulty
		if ( !isdefined( level._custom_eog_no_skill ) || !level._custom_eog_no_skill )
			player use_custom_eog_default_difficulty();

		// Kills
		if ( !isdefined( level._custom_eog_no_kills ) || !level._custom_eog_no_kills )
			player use_custom_eog_default_kills();

		if ( is_coop_online() )
		{
			// Partner's stats
			if ( !isdefined( level._custom_eog_no_partner ) || !level._custom_eog_no_partner )
			{
				other_player = get_other_player( player );
				player use_custom_eog_default_difficulty( other_player );
				player use_custom_eog_default_kills( other_player );
			}
		}
	}
}

use_custom_eog_default_time()
{
	seconds = ( level._challenge_end_time - level._challenge_start_time ) * 0.001;
	time_string = convert_to_time_string( seconds, true );
	self add_custom_eog_summary_line( "@SPECIAL_OPS_UI_TIME", time_string );
}

use_custom_eog_default_difficulty( player )
{
	msg = "@SPECIAL_OPS_UI_DIFFICULTY_OTHER";
	if ( !isdefined( player ) )
	{
		player = self;
		msg = "@SPECIAL_OPS_UI_DIFFICULTY";
	}

	difficulty_string = undefined;
	switch( player.gameskill )
	{
		case 0:
		case 1:	difficulty_string = "@MENU_REGULAR"; break;
		case 2:	difficulty_string = "@MENU_HARDENED"; break;
		case 3:	difficulty_string = "@MENU_VETERAN"; break;
	}
	self add_custom_eog_summary_line( msg, difficulty_string );
}

use_custom_eog_default_kills( player )
{
	msg = "@SPECIAL_OPS_UI_KILLS_OTHER";
	if ( !isdefined( player ) )
	{
		player = self;
		msg = "@SPECIAL_OPS_UI_KILLS";
	}

	self add_custom_eog_summary_line( msg, player.stats[ "kills" ] );
}

reset_eog_popup_dvars()
{
	setdvar( "ui_eog_player1_stars", "" );
	setdvar( "ui_eog_player1_unlock", "" );
	setdvar( "ui_eog_player1_besttime", "" );
	setdvar( "ui_eog_player1_noreward", "" );

	setdvar( "ui_eog_player2_stars", "" );
	setdvar( "ui_eog_player2_unlock", "" );
	setdvar( "ui_eog_player2_besttime", "" );
	setdvar( "ui_eog_player2_noreward", "" );
}
