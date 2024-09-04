#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

MIN_TIME_IN_GAME = 0.25;  //Min % of total match's length for which the player has to be in the match in order for his stats to be recorded
MIN_NUM_PLAYERS = 5;      //Minimum number of players that need to be at the end of the match in order for the fantasy stats to be tracked

processFantasyStats()
{
	if(    ( matchMakingGame() ) 
		&& ( level._players.size >= MIN_NUM_PLAYERS ) 
		&& ( getDvarInt( "fantasyStatTracking" ) == 1 ) )
	{
		topscore = 0;
		topPlayer = [];
		foreach ( player in level._players )
		{
			if ( player.score >= topscore )
			{
				topscore = player.score;
				topPlayer [ topPlayer.size ] = player; 
			}
		}
		
		foreach ( player in	topPlayer )
		{
			player incPlayerStat ( "topscore", 1 );
		}

		localPlayerStatsInt = [ 
							"kills",
							"deaths",
							"killstreak",
							"headshots",
							"grenadekills",
							"uavs",
							"mostmultikills",
							"multikill",
							"knifekills",
							"flankkills",
							"laststandkills",
							"assists",
							"c4kills",
							"claymorekills",
							"fragkills",
							"semtexkills",
							"explosionssurvived",
							"adskills",
							"hipfirekills",
							"revengekills",
							"longestlife",
							"throwbacks",
							"mostcamperkills",
							"fbhits",
							"stunhits",
							"scopedkills",
							"arkills",
							"arheadshots",
							"lmgkills",
							"lmgheadshots",
							"sniperkills",
							"sniperheadshots",
							"shieldblocks",
							"shieldkills",
							"smgkills",
							"smgheadshots",
							"shotgunkills",
							"shotgunheadshots",
							"pistolkills",
							"pistolheadshots",
							"rocketkills",
							"equipmentkills",
							"intelCompleted",
							"explosivehits",
							"machinepistolkills",
							"machinepistolheadshots",
							"rescues",
							"throwingknifekills",
							"killswhilepushingugv",
							"killsenemywhopushesugv",
							"crouchkills",
							"pronekills",
							"firstblood",
							"backstabber",
							"flagscaptured",
							"flagsreturned",
							"flagscarried",
							"bombsplanted",
							"bombsdefused",
							"bombsdefender",
							"targetsdestroyed",
							"pointscaptured",
							"bulletpenkills",
							"killstunnedenemy",
							"killcookedgrenade",
							"killwithstolenweapons",
							"gamewinningkill",
							"killwithkillstreaks",
							"checkpoints",
							"killstreakdestroyed",
							"killduringenemyairkillstreak",
							"topscore", 
							"dompointscapturedsingular",
							"domdefendwithequipment"
							];
		localPlayerStatsFloat = [ "kdratio" ];
	//	matchPlayerStatsInt = [
	//						"scoreXp",
	//						"matchXp" ];
	// 						"hits",
	// 						"misses",
	// 						"totalShots",
	// 						"accuracy" ];

		gameLength = getTimePassed() / 1000;  //getTimePassed returns the time in millisecond	
	
		foreach ( player in level._players )
		{
			if ( player.timePlayed["total"] > ( gameLength * MIN_TIME_IN_GAME ))
			{
				plat = "win";
				if( level._xenon )
				{
					plat = "xen";
				}
				if( level._ps3 )
				{
					plat = "ps3";
				}
				bbString = "fantasy_cod: username %s plat %s ";
				actualString = "fantasy_cod: username " + player.gamertag + " plat " + plat + " ";
				bbData = [ player.gamertag, plat ];
				println( "Fantasy Ints:" );
				foreach( stat in localPlayerStatsInt )
				{
					if( player doesPlayerStatExist ( stat ))
					{
						data = player getPlayerStat( stat );
					}
					else
					{
						data = "0";
					}
					bbString += stat + " %d ";
					actualString += stat + " " + data + " ";
					bbData[ bbData.size ] = data;
					println( stat + ": " + data );
				}
				println( "Fantasy floats:" );
				foreach( stat in localPlayerStatsFloat )
				{
					if( player doesPlayerStatExist ( stat ))
					{
						data = player getPlayerStat( stat );
					}
					else
					{
						data = "0";
					}
					bbString += stat + " %f ";
					actualString += stat + " " + data + " ";
					bbData[ bbData.size ] = data;
					println( stat + ": " + data );
				}
	// 			foreach( stat in matchPlayerStatsInt )
	// 			{
	// 				data = player getPlayerData( "round", stat );
	// 				bbString += stat + " %d ";
	// 				bbData[ bbData.size ] = data;
	// 			}
				println( bbString );
				println( actualString );
				bbprint( bbString, bbData, "uid" );
			}
		}
	}
}