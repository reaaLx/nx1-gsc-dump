#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

INTEL_OFFSET = (0, 0, 24);
INTEL_OFFSET_TOP = (0, 0, 36);
INTEL_ICON_PULSE_SCALE = 1.2;
INTEL_ICON_PULSE_WAIT_SEC = 5;
INTEL_ICON_COLOR = (1,1,1);

//*******************************************************************
//																	*
//																	*
//*******************************************************************

init()
{
	if( getDvarInt( "prototype_intel_enabled" ) == 1 )
	{
		println( "Intel enabled" );

		intelGamePercentage = getDvarInt( "prototype_intel_percentage" );

		if( intelGamePercentage >= randomInt( 100 ))
		{
			println( "Intel: This will be an intel game" );
			initIntel();
			level thread onPlayerConnect();

			level thread addIntelToGame();

			//tempGetStarted();
		}
		else
		{
			println( "Intel: This is not going to be an intel game" );
		}
	}
	else
	{
		println( "Intel not inited ", getDvarInt( "prototype_intel_enabled" ));
	}
}

tempGetStarted()
{
	level waittill("connected", player);
	
	player thread tempGetStartedSpawned();
}

tempGetStartedSpawned()
{
	wait 3;
	// setup the team, close the menu, then set our class and wait for our player to spawn
	self [[level._onTeamSelection]]( "allies" );
	self closepopupMenu();
	self closeInGameMenu();
	self.selectedClass = true;
	self [[level._class]]("class0");
	players = getentarray("player", "classname");
	while( players.size == 0 )
	{
		wait 1;
		players = getentarray("player", "classname");
	}
}

intelDebugging()
{
	return false;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

initIntel()
{
	// setup the models and stuff we need for intel
	//precacheShader("waypoint_bomb");
	precacheModel( "prop_suitcase_intel" );
	precacheString(&"MP_AQUIRING_INTEL");
	precacheString(&"MP_INTEL_HEADER");

	level._intelHUDIcon = "hud_suitcase_bomb";
	precacheShader( level._intelHUDIcon );

	level._intel = undefined;
	// we need to setup our array of intel types
	intelInitData = [];
	intelInitData["replenish"] = "ammo_primary";
	intelKillsEvalData = [];
	intelKillsEvalData["kills"]["count"] = 3;
	intelKillsEvalData["kills"]["string"] = &"MP_INTEL_KILLS_DESC";
	intelKillsAwardData = [];
	intelKillsAwardData["experience"] = 1000;
	addIntelType( "intel_kills", 0, 15, ::initLifeStats, intelInitData, ::evalLifeStats, intelKillsEvalData, ::intelAward, intelKillsAwardData );

	intelInitData = [];
	intelInitData["replenish"] = "ammo_primary";
	intelKillsEvalData = [];
	intelKillsEvalData["headshots"]["count"] = 1;
	intelKillsEvalData["headshots"]["string"] = &"MP_INTEL_HEADSHOT_DESC";
	intelKillsAwardData = [];
	intelKillsAwardData["experience"] = 1000;
	addIntelType( "intel_headshot", 0, 15, ::initLifeStats, intelInitData, ::evalLifeStats, intelKillsEvalData, ::intelAward, intelKillsAwardData );

	intelInitData = [];
	intelInitData["replenish"] = "ammo_primary";
	intelKillsEvalData = [];
	intelKillsEvalData["mostmultikills"]["count"] = 1;
	intelKillsEvalData["mostmultikills"]["string"] = &"MP_INTEL_MULTIKILL_DESC";
	intelKillsAwardData = [];
	intelKillsAwardData["experience"] = 1000;
	addIntelType( "intel_multikills", 0, 15, ::initLifeStats, intelInitData, ::evalLifeStats, intelKillsEvalData, ::intelAward, intelKillsAwardData );

	intelInitData = [];
	intelInitData["replenish"] = "equipment";
	intelKillsEvalData = [];
	intelKillsEvalData["equipmentkills"]["count"] = 1;
	intelKillsEvalData["equipmentkills"]["string"] = &"MP_INTEL_EQUIPMENT_DESC";
	intelKillsAwardData = [];
	intelKillsAwardData["experience"] = 1000;
	addIntelType( "intel_equipmentkills", 0, 15, ::initLifeStats, intelInitData, ::evalLifeStats, intelKillsEvalData, ::intelAward, intelKillsAwardData );

	// generate the max weighted value
	level._intelMaxWeight = 0;
	foreach ( intelName, intelDef in level._intelDefs )
	{	
		if ( intelDef["weight"] > 0 )
		{		
			level._intelMaxWeight += intelDef["weight"];
			level._intelDefs[intelName]["weight"] = level._intelMaxWeight;
//			println( "Adding intel " + intelName + " with weight value " + intelDef["weight"] + " max weight is " + level._intelMaxWeight );
		}
		else
		{
			println( "Warning: Intel def with 0 weight! name = ", intelName ); 
		}
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

addIntelType( name, intelLevel, weight, initFunc, initData, evalFunc, evalData, awardFunc, awardData )
{
	evalData["name"] = name;
	awardData["name"] = name;
	level._intelDefs[name]["weight"] = weight;
	level._intelDefs[name]["intelLevel"] = intelLevel;
	level._intelDefs[name]["initFunc"] = initFunc;
	level._intelDefs[name]["initData"] = initData;
	level._intelDefs[name]["evalFunc"] = evalFunc;
	level._intelDefs[name]["evalData"] = evalData;
	level._intelDefs[name]["awardFunc"] = awardFunc;
	level._intelDefs[name]["awardData"] = awardData;

	foreach( evalPiece, evalDataList in evalData )
	{
		println( evalPiece );
		if( evalPiece != "name" && isDefined( evalDataList["string"] ))
		{
			PreCacheString( evalDataList["string"] );
		}
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

getRandomIntel()
{
	value = randomInt( level._intelMaxWeight );

	selectedIntelName = undefined;
	foreach ( intelName, intelDef in level._intelDefs )
	{
		if( intelDef["weight"] > 0 )
		{
			selectedIntelName = intelName;
		
			if ( intelDef["weight"] > value )
			{
				break;
			}
		}			
	}
	
	return( selectedIntelName );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

initIntelOnPlayer( player )
{
	process = level._intelDefs[ level._intel ][ "initFunc" ];
	processInitData = level._intelDefs[ level._intel ][ "initData" ];
	processEvalData = level._intelDefs[ level._intel ][ "evalData" ];

	return [[ process ]]( player, processInitData, processEvalData );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

evalIntelOnPlayer( player )
{
	process = level._intelDefs[ level._intel ][ "evalFunc" ];
	processData = level._intelDefs[ level._intel ][ "evalData" ];

	return [[ process ]]( player, processData );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

awardIntelOnPlayer( player ) 
{
	process = level._intelDefs[ level._intel ][ "awardFunc" ];
	processData = level._intelDefs[ level._intel ][ "awardData" ];

	[[ process ]]( player, processData );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

addIntelToGame()
{
	level._intel = getRandomIntel();

	println( "Intel added to the game ", level._intel );

	// wait till we have some player connected
	level waittill( "connected", player );
	
	while( level._players.size == 0 )
	{
		wait 0.05;
	}

	// find a intel spawn location
	spawnPoint = findIntelSpawnLocation();

	assert( isDefined( spawnPoint ));
	
	// create the use objects
	level._intelEnt = createIntelBreifcase( spawnPoint );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

findIntelSpawnLocation()
{
	// for now, just grab a random dom point
//	randomPlayer = level._players[ randomInt( level._players.size ) ];

//	randomPlayer waittill( "spawned_player" );

//	return randomPlayer [[ level._getSpawnPoint ]]();

	while( 1 )
	{
		wait 0.5;
		if( isDefined( level._spawnpoints ))
		{
			if( level._spawnpoints.size > 0  )
			{
				break;
			}
		}
	}

	return level._spawnpoints[ randomInt( level._spawnpoints.size ) ];
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

createIntelBreifcase( entity )
{
	visuals[0] = spawn( "script_model", entity.origin );
	visuals[0].angles = entity.angles;
	visuals[0] setModel( "prop_suitcase_intel" );

	cloneTrigger = spawn( "trigger_radius", entity.origin, 0, 96, 60 );
	intelEnt = cloneTrigger;

	intelZone = maps\mp\gametypes\_gameobjects::createCarryObject( "friendly", intelEnt, visuals, INTEL_OFFSET );
	intelZone maps\mp\gametypes\_gameobjects::setUseTime( 0.5 );
	intelZone maps\mp\gametypes\_gameobjects::setUseText( &"MP_AQUIRING_INTEL" );
	intelZone maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
//	intelZone maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_bomb" );
//	intelZone maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_bomb" );
//	intelZone maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_bomb" );
//	intelZone maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_bomb" );
	intelZone maps\mp\gametypes\_gameobjects::allowCarry( "any" );
	intelZone maps\mp\gametypes\_gameobjects::setCarrierVisible( false );

	intelZone thread intelSpinAnimate();

	intelZone.onPickup = ::onPickupIntel;
	intelZone.onDrop = ::onDropIntel;
	intelZone.allowWeapons = true;
	intelZone.oldRadius = intelEnt.radius;

	return intelZone;	
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

intelSpinAnimate()
{
	level endon( "game_ended" );
	self endon( "reset" );
	self endon( "pickup_object" );	
	
	bottomPos = self.curOrigin + INTEL_OFFSET;
	topPos = self.curOrigin + INTEL_OFFSET_TOP;
	
	while( true )
	{
		self.visuals[0] moveTo( topPos, 0.5, 0.15, 0.15 );
		self.visuals[0] rotateYaw( 180, 0.5 );
		
		wait( 0.5 );
		
		self.visuals[0] moveTo( bottomPos, 0.5, 0.15, 0.15 );
		self.visuals[0] rotateYaw( 180, 0.5 );	
		
		wait( 0.5 );		
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

onPickupIntel( player )
{
//	level._intelEnt maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", undefined );
//	level._intelEnt maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", undefined );
//	level._intelEnt maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", undefined );
//	level._intelEnt maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", undefined );

	player thread onIntelAquired();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

onDropIntel( player )
{
//	level._intelEnt maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_bomb" );
//	level._intelEnt maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_bomb" );
//	level._intelEnt maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_bomb" );
//	level._intelEnt maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_bomb" );
	
	level._intelEnt thread intelSpinAnimate();
	intelCardSplashEveryone( "intel_dropped_callout", player );
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

		player thread notifyIntelGame();
		player thread onPlayerSpawned();
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

onPlayerSpawned()
{
	self endon( "disconnect" );

	if( intelDebugging())
		println( "Intel: onPlayerSpawned" );

	for(;;)
	{
		self waittill( "spawned_player" );
		if( intelDebugging())
			println( "Intel: Player spawned" );
		self._intelHasIntel = 0;
//		self thread intelWaitDeath();
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

intelWaitDeath()
{
	self endon( "intel_cleanup" );
	self waittill( "death" );
	self notify( "intel_cleanup" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

intelWaitCleanup()
{
	self waittill( "intel_cleanup" );
	wait 1;
	self destroyIntelHud();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

onIntelAquired()
{
	self endon( "disconnect" );
	self endon( "death" );

	//intelCardSplashEveryone( "intel_pickup_callout", self );

	self._intelHasIntel = 1;
	self createIntelHud();
	self thread intelWaitDeath();
	self thread intelWaitCleanup();

	println( "Intel: intel aquired by ", self.name );

	initIntelOnPlayer( self );

	while( 1 )
	{
		if( evalIntelOnPlayer( self ) == 1 )
		{
			println( "Intel: Awarding intel to player" );
			
			intelCardSplashEveryone( "intel_completed_callout", self );

			self incPlayerStat( "intelCompleted", 1 );

			awardIntelOnPlayer( self );
			// get rid of the intel, it's served it's purpose
			//level._intelEnt thread maps\mp\gametypes\_gameobjects::deleteUseObject();
			level._intelEnt maps\mp\gametypes\_gameobjects::disableObject();

			break;
		}
		wait 0.05;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

//				Evaluation and Award funcs

//*******************************************************************
//																	*
//																	*
//*******************************************************************

initLifeStats( player, initData, evalData )
{
	if( intelDebugging())
		println( "Initing Intel on ", player.name );
	i = 0;
	foreach( intelStat, intelStatValue in evalData )
	{
		if( intelStat != "name" )
		{
			player._intelInitValues[intelStat] = getPlayerStat( intelStat );
			player._intelHud["lines"][i]["item"] SetText( intelStatValue["string"] );
			i += 1;
		}
	}
	if( isDefined( initData["replenish"] ))
	{
		weaponList = player GetWeaponsListAll();
		switch( initData["replenish"] )
		{
		case "ammo_primary":
			foreach ( weaponName in weaponList )
			{
				if ( maps\mp\gametypes\_weapons::isPrimaryWeapon( weaponName ) )
				{
					player giveMaxAmmo( weaponName );
				} 
			}
			break;

		case "equipment":
			foreach ( weaponName in weaponList )
			{
				if ( maps\mp\gametypes\_weapons::isEquipment( weaponName ) )
				{
					player giveMaxAmmo( weaponName );
				} 
			}
			break;
		}
	}		
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

evalLifeStats( player, evalData )
{
	ret = 0;
	allStatsSatisfied = 1;
	if( intelDebugging())
		println( "Evaluating Intel on ", player.name );
	if( isDefined( evalData ))
	{
		i = 0;
		foreach( intelStat, intelDef in evalData )
		{
			if( intelStat != "name" )
			{
				intelStatValue = intelDef["count"];
				currStatValue = ( getPlayerStat( intelStat ) - player._intelInitValues[intelStat] );

				if( intelDebugging())
					println( "Checking ", intelStat, " value ", intelStatValue );
				if( currStatValue < intelStatValue )
				{
					allStatsSatisfied = 0;
				}
				else
				{
					currStatValue = intelStatValue;
				}

				// hud text
				hudText = currStatValue + "/" + intelStatValue;
				if( player._intelHud["lines"][i]["text"] != hudText )
				{
					player._intelHud["lines"][i]["text"] = hudText;
					player._intelHud["lines"][i]["status"] SetText( hudText );
				}

				i = i + 1;
			}
		}
		if( allStatsSatisfied == 1 )
		{
			ret = 1;
		}
	} 
	else
	{
		println( "Could not find evaluation data!\n" );
	}
	return ret;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

intelAward( player, awardData )
{
	println( "Giving Intel Award to ", player.name );
	if( isDefined( awardData ))
	{
		player thread maps\mp\gametypes\_hud_message::SplashNotify( "intel_completed", awardData["experience"] );

		foreach( award, value in awardData )
		{
			if( award != "name" )
			{
				println( award, " ", value );
				switch( award )
				{
				case "experience":
					self thread awardIntelXp( value, awardData );
					break;

				default:
					println( "Didn't understand how to deal with award type ", award );
				}
			}
		}
	}
	else
	{
		println( "No awards found!" );
	}

	player notify( "intel_cleanup" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

//				Hud Notificaiton Scripts

//*******************************************************************
//																	*
//																	*
//*******************************************************************

awardIntelXp( value, awardData )
{
	self endon ( "disconnect" );

	wait( 0.25 );
	self maps\mp\gametypes\_rank::giveRankXP( "challenge", value );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

notifyIntelGame()
{
	self waittill( "spawned_player" );
	if( intelDebugging())
		println( "We are playing a game with Intel!" );

	self thread maps\mp\gametypes\_hud_message::SplashNotify( "intel_ingame", 0 );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

intelCardSplashEveryone( splash, owner )
{
	if ( level._hardCoreMode )
		return;
		
	foreach ( player in level._players )
	{			
		player thread maps\mp\gametypes\_hud_message::playerCardSplashNotify( splash, owner );
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

hudIconPulse()
{
	self endon( "intel_cleanup" );
	origWidth = self._intelHud["icon"].width;
	origHeight = self._intelHud["icon"].height;
	for(;;)
	{
		self._intelHud["icon"] scaleOverTime( 0.05, int( origWidth * INTEL_ICON_PULSE_SCALE ), int( origHeight * INTEL_ICON_PULSE_SCALE ) );
		wait 0.05;
		self._intelHud["icon"] scaleOverTime( 0.3, origWidth, origHeight );
		wait 0.3;
		wait INTEL_ICON_PULSE_WAIT_SEC;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

createIntelHud()
{
	self._intelHud["icon"] = createIcon( level._intelHUDIcon, 40, 40 );
	self._intelHud["icon"].horzAlign		= "left";
	self._intelHud["icon"].alignX 			= "left";
	self._intelHud["icon"].y				= 110;
	self._intelHud["icon"].sort				= -10;
	self._intelHud["icon"].color			= INTEL_ICON_COLOR;
	self thread hudIconPulse();

	currY = 130;
	self._intelHud["header"] = CreateFontString( "objective", 1.3 );
	self._intelHud["header"].horzAlign		= "left";
	self._intelHud["header"].alignX 		= "left";
	self._intelHud["header"] SetText( &"MP_INTEL_HEADER" );
	self._intelHud["header"].y				= currY;
	self._intelHud["header"].x				= 42;
	currY += 20;

	xIndent = 20;
	xOffset = 40;

	self._intelHud["lines"][0]["item"] = CreateFontString( "objective", 1.25 );
	self._intelHud["lines"][0]["item"].horizAlign	= "left";
	self._intelHud["lines"][0]["item"].alignX		= "left";
	self._intelHud["lines"][0]["item"].y			= currY;
	self._intelHud["lines"][0]["item"].x			= xIndent + xOffset;
	self._intelHud["lines"][0]["status"] = CreateFontString( "objective", 1.25 );
	self._intelHud["lines"][0]["status"].horizAlign	= "left";
	self._intelHud["lines"][0]["status"].alignX		= "left";
	self._intelHud["lines"][0]["status"].y			= currY;
	self._intelHud["lines"][0]["status"].x			= xIndent;
	self._intelHud["lines"][0]["text"]				= "";
	currY += 20;

	self._intelHud["lines"][1]["item"] = CreateFontString( "objective", 1.25 );
	self._intelHud["lines"][1]["item"].horizAlign	= "left";
	self._intelHud["lines"][1]["item"].alignX		= "left";
	self._intelHud["lines"][1]["item"].y			= currY;
	self._intelHud["lines"][1]["item"].x			= xIndent + xOffset;
	self._intelHud["lines"][1]["status"] = CreateFontString( "objective", 1.25 );
	self._intelHud["lines"][1]["status"].horizAlign	= "left";
	self._intelHud["lines"][1]["status"].alignX		= "left";
	self._intelHud["lines"][1]["status"].y			= currY;
	self._intelHud["lines"][1]["status"].x			= xIndent;
	self._intelHud["lines"][1]["text"]				= "";
	currY += 20;

	self._intelHud["lines"][2]["item"] = CreateFontString( "objective", 1.25 );
	self._intelHud["lines"][2]["item"].horizAlign	= "left";
	self._intelHud["lines"][2]["item"].alignX		= "left";
	self._intelHud["lines"][2]["item"].y			= currY;
	self._intelHud["lines"][2]["item"].x			= xIndent + xOffset;
	self._intelHud["lines"][2]["status"] = CreateFontString( "objective", 1.25 );
	self._intelHud["lines"][2]["status"].horizAlign	= "left";
	self._intelHud["lines"][2]["status"].alignX		= "left";
	self._intelHud["lines"][2]["status"].y			= currY;
	self._intelHud["lines"][2]["status"].x			= xIndent;
	self._intelHud["lines"][2]["text"]				= "";
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

destroyIntelHud()
{
	self._intelHud["icon"] destroy();
	self._intelHud["header"] destroy();
	self._intelHud["lines"][0]["item"] destroy();
	self._intelHud["lines"][0]["status"] destroy();
	self._intelHud["lines"][1]["item"] destroy();
	self._intelHud["lines"][1]["status"] destroy();
	self._intelHud["lines"][2]["item"] destroy();
	self._intelHud["lines"][2]["status"] destroy();
}
