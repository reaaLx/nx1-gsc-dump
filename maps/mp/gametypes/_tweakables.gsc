#include maps\mp\_utility;

getTweakableDVarValue( category, name )
{
	switch( category )
	{
		case "rule":
			dVar = level._rules[name].dVar;
			break;
		case "game":
			dVar = level._gameTweaks[name].dVar;
			break;
		case "team":
			dVar = level._teamTweaks[name].dVar;
			break;
		case "player":
			dVar = level._playerTweaks[name].dVar;
			break;
		case "class":
			dVar = level._classTweaks[name].dVar;
			break;
		case "weapon":
			dVar = level._weaponTweaks[name].dVar;
			break;
		case "hardpoint":
			dVar = level._hardpointTweaks[name].dVar;
			break;
		case "hud":
			dVar = level._hudTweaks[name].dVar;
			break;
		default:
			dVar = undefined;
			break;
	}
	
	assert( isDefined( dVar ) );
	
	value = getDvarInt( dVar );
	
	return value;
}


getTweakableDVar( category, name )
{
	switch( category )
	{
		case "rule":
			value = level._rules[name].dVar;
			break;
		case "game":
			value = level._gameTweaks[name].dVar;
			break;
		case "team":
			value = level._teamTweaks[name].dVar;
			break;
		case "player":
			value = level._playerTweaks[name].dVar;
			break;
		case "class":
			value = level._classTweaks[name].dVar;
			break;
		case "weapon":
			value = level._weaponTweaks[name].dVar;
			break;
		case "hardpoint":
			value = level._hardpointTweaks[name].dVar;
			break;
		case "hud":
			value = level._hudTweaks[name].dVar;
			break;
		default:
			value = undefined;
			break;
	}
	
	assert( isDefined( value ) );
	return value;
}


getTweakableValue( category, name )
{
	switch( category )
	{
		case "rule":
			value = level._rules[name].value;
			break;
		case "game":
			value = level._gameTweaks[name].value;
			break;
		case "team":
			value = level._teamTweaks[name].value;
			break;
		case "player":
			value = level._playerTweaks[name].value;
			break;
		case "class":
			value = level._classTweaks[name].value;
			break;
		case "weapon":
			value = level._weaponTweaks[name].value;
			break;
		case "hardpoint":
			value = level._hardpointTweaks[name].value;
			break;
		case "hud":
			value = level._hudTweaks[name].value;
			break;
		default:
			value = undefined;
			break;
	}
	
	/#
	overrideDvar = "scr_" + level._gameType + "_" + category + "_" + name;	
	return getDvarInt( overrideDvar, value );
	#/
	
	assert( isDefined( value ) );
	return value;
}


getTweakableLastValue( category, name )
{
	switch( category )
	{
		case "rule":
			value = level._rules[name].lastValue;
			break;
		case "game":
			value = level._gameTweaks[name].lastValue;
			break;
		case "team":
			value = level._teamTweaks[name].lastValue;
			break;
		case "player":
			value = level._playerTweaks[name].lastValue;
			break;
		case "class":
			value = level._classTweaks[name].lastValue;
			break;
		case "weapon":
			value = level._weaponTweaks[name].lastValue;
			break;
		case "hardpoint":
			value = level._hardpointTweaks[name].lastValue;
			break;
		case "hud":
			value = level._hudTweaks[name].lastValue;
			break;
		default:
			value = undefined;
			break;
	}
	
	assert( isDefined( value ) );
	return value;
}


setTweakableValue( category, name, value )
{
	switch( category )
	{
		case "rule":
			dVar = level._rules[name].dVar;
			break;
		case "game":
			dVar = level._gameTweaks[name].dVar;
			break;
		case "team":
			dVar = level._teamTweaks[name].dVar;
			break;
		case "player":
			dVar = level._playerTweaks[name].dVar;
			break;
		case "class":
			dVar = level._classTweaks[name].dVar;
			break;
		case "weapon":
			dVar = level._weaponTweaks[name].dVar;
			break;
		case "hardpoint":
			dVar = level._hardpointTweaks[name].dVar;
			break;
		case "hud":
			dVar = level._hudTweaks[name].dVar;
			break;
		default:
			dVar = undefined;
			break;
	}
	
	setDvar( dVar, value );
}


setTweakableLastValue( category, name, value )
{
	switch( category )
	{
		case "rule":
			level._rules[name].lastValue = value;
			break;
		case "game":
			level._gameTweaks[name].lastValue = value;
			break;
		case "team":
			level._teamTweaks[name].lastValue = value;
			break;
		case "player":
			level._playerTweaks[name].lastValue = value;
			break;
		case "class":
			level._classTweaks[name].lastValue = value;
			break;
		case "weapon":
			level._weaponTweaks[name].lastValue = value;
			break;
		case "hardpoint":
			level._hardpointTweaks[name].lastValue = value;
			break;
		case "hud":
			level._hudTweaks[name].lastValue = value;
			break;
		default:
			break;
	}
}


registerTweakable( category, name, dvar, value )
{
	if ( isString( value ) )
	{
		value = getDvar( dvar, value );
	}
	else
	{
		value = getDvarInt( dvar, value );
	}

	switch( category )
	{
		case "rule":
			if ( !isDefined( level._rules[name] ) )
				level._rules[name] = spawnStruct();				
			level._rules[name].value = value;
			level._rules[name].lastValue = value;
			level._rules[name].dVar = dvar;
			break;
		case "game":
			if ( !isDefined( level._gameTweaks[name] ) )
				level._gameTweaks[name] = spawnStruct();
			level._gameTweaks[name].value = value;
			level._gameTweaks[name].lastValue = value;			
			level._gameTweaks[name].dVar = dvar;
			break;
		case "team":
			if ( !isDefined( level._teamTweaks[name] ) )
				level._teamTweaks[name] = spawnStruct();
			level._teamTweaks[name].value = value;
			level._teamTweaks[name].lastValue = value;			
			level._teamTweaks[name].dVar = dvar;
			break;
		case "player":
			if ( !isDefined( level._playerTweaks[name] ) )
				level._playerTweaks[name] = spawnStruct();
			level._playerTweaks[name].value = value;
			level._playerTweaks[name].lastValue = value;			
			level._playerTweaks[name].dVar = dvar;
			break;
		case "class":
			if ( !isDefined( level._classTweaks[name] ) )
				level._classTweaks[name] = spawnStruct();
			level._classTweaks[name].value = value;
			level._classTweaks[name].lastValue = value;			
			level._classTweaks[name].dVar = dvar;
			break;
		case "weapon":
			if ( !isDefined( level._weaponTweaks[name] ) )
				level._weaponTweaks[name] = spawnStruct();
			level._weaponTweaks[name].value = value;
			level._weaponTweaks[name].lastValue = value;			
			level._weaponTweaks[name].dVar = dvar;
			break;
		case "hardpoint":
			if ( !isDefined( level._hardpointTweaks[name] ) )
				level._hardpointTweaks[name] = spawnStruct();
			level._hardpointTweaks[name].value = value;
			level._hardpointTweaks[name].lastValue = value;			
			level._hardpointTweaks[name].dVar = dvar;
			break;
		case "hud":
			if ( !isDefined( level._hudTweaks[name] ) )
				level._hudTweaks[name] = spawnStruct();
			level._hudTweaks[name].value = value;
			level._hudTweaks[name].lastValue = value;			
			level._hudTweaks[name].dVar = dvar;
			break;
	}
}


init()
{
	level._clientTweakables = [];
	level._tweakablesInitialized = true;

	level._rules = [];
	level._gameTweaks = [];
	level._teamTweaks = [];
	level._playerTweaks = [];
	level._classTweaks = [];
	level._weaponTweaks = [];
	level._hardpointTweaks = [];
	level._hudTweaks = [];
	// commented out tweaks have not yet been implemented
	
	if ( level._console )
	{
		registerTweakable( "game", 			"graceperiod", 			"scr_game_graceperiod", 			15 ); //*
	}
	else
	{
		registerTweakable( "game", 			"playerwaittime", 		"scr_game_playerwaittime", 			15 ); //*
		registerTweakable( "game", 			"matchstarttime", 		"scr_game_matchstarttime", 			5 ); //*
	}
	registerTweakable( "game", 			"onlyheadshots", 		"scr_game_onlyheadshots", 			0 ); //*
	registerTweakable( "game", 			"allowkillcam", 		"scr_game_allowkillcam", 			1 ); //*
	registerTweakable( "game", 			"spectatetype", 		"scr_game_spectatetype", 			2 ); //*

	registerTweakable( "game", 			"deathpointloss", 		"scr_game_deathpointloss", 			0 ); //*
	registerTweakable( "game", 			"suicidepointloss", 	"scr_game_suicidepointloss", 		0 ); //*
	registerTweakable( "team", 			"teamkillpointloss", 	"scr_team_teamkillpointloss", 		0 ); //*
	
//	registerTweakable( "team", 			"respawntime", 			"scr_team_respawntime", 			0 );
	registerTweakable( "team", 			"fftype", 				"scr_team_fftype", 					0 ); 
	registerTweakable( "team", 			"teamkillspawndelay", 	"scr_team_teamkillspawndelay", 		0 );
	
//	registerTweakable( "player", 		"respawndelay", 		"scr_player_respawndelay", 			0 ); //*
	registerTweakable( "player", 		"maxhealth", 			"scr_player_maxhealth", 			125 ); //*
	registerTweakable( "player", 		"healthregentime", 		"scr_player_healthregentime", 		5 ); //*
	registerTweakable( "player", 		"healthregenratepercent", "scr_player_healthregenratepercent", 		10 ); //*
	registerTweakable( "player", 		"forcerespawn", 		"scr_player_forcerespawn", 			1 ); //*

	registerTweakable( "weapon", 	"allowfrag", 		"scr_weapon_allowfrags", 1 );
	registerTweakable( "weapon", 	"allowsmoke", 		"scr_weapon_allowsmoke", 1 );
	registerTweakable( "weapon", 	"allowflash", 		"scr_weapon_allowflash", 1 );
	registerTweakable( "weapon", 	"allowc4", 			"scr_weapon_allowc4", 1 );
	registerTweakable( "weapon", 	"allowclaymores", 	"scr_weapon_allowclaymores", 1 );
	registerTweakable( "weapon", 	"allowrpgs", 		"scr_weapon_allowrpgs", 1 );
	registerTweakable( "weapon", 	"allowmines", 		"scr_weapon_allowmines", 1 );

	registerTweakable( "hardpoint", "allowartillery", 	"scr_hardpoint_allowartillery", 1 );
	registerTweakable( "hardpoint", "allowuav", 		"scr_hardpoint_allowuav", 1 );
	registerTweakable( "hardpoint", "allowsupply", 		"scr_hardpoint_allowsupply", 1 );
	registerTweakable( "hardpoint", "allowhelicopter", 	"scr_hardpoint_allowhelicopter", 1 );
    
	registerTweakable( "hud", 		"showobjicons", 	"ui_hud_showobjicons", 						1 ); //*
	makeDVarServerInfo( "ui_hud_showobjicons", 1 );
}