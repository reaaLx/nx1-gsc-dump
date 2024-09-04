#include common_scripts\utility;
// check if below includes are removable
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

HULC_GRENADE_COUNT = 2;  //The number of HULC grenades that will be given to the players per life
CONST_TROPHY_MAX_TRACK_DISTANCE = 100;
CONST_TROPHY_LOCK_DISTANCE = 500;
HULC_SHOULDER_TAG = "TAG_SHOULDER_LAUNCHER";
TROPHY_COOLDOWN_TIME_SECONDS = 5.0;
TROPHY_WAIT_TIME_AFTER_FIRING = 2.0;
TROPHY_SOUND_AFTER_COOLDOWN = "weap_recharge_stop";
TROPHY_SYSTEM_TAG = "TAG_TROPHY";
TROPHY_SYSTEM_FX_TAG = "TAG_FLASH";
TROPHY_SYSTEM_TURRET_INFO = "ugv_robo_turret_mp";                           
TROPHY_SYSTEM_TURRET_MODEL = "mp_nx_us_trophy_turret";      
FX_TROPHY_SYSTEM_EXPLOSION = "code/trophy_explosion_mp";
FX_TROPHY_SYSTEM_FIRING = "explosions/sparks_a";                 

init()
{
	level._classMap["class0"] = 0;
	level._classMap["class1"] = 1;
	level._classMap["class2"] = 2;
	level._classMap["class3"] = 3;
	level._classMap["class4"] = 4;
	level._classMap["class5"] = 5;
	level._classMap["class6"] = 6;
	level._classMap["class7"] = 7;
	level._classMap["class8"] = 8;
	level._classMap["class9"] = 9;
	level._classMap["class10"] = 10;
	level._classMap["class11"] = 11;
	level._classMap["class12"] = 12;
	level._classMap["class13"] = 13;
	level._classMap["class14"] = 14;
	
	level._classMap["custom1"] = 0;
	level._classMap["custom2"] = 1;
	level._classMap["custom3"] = 2;
	level._classMap["custom4"] = 3;
	level._classMap["custom5"] = 4;
	level._classMap["custom6"] = 5;
	level._classMap["custom7"] = 6;
	level._classMap["custom8"] = 7;
	level._classMap["custom9"] = 8;
	level._classMap["custom10"] = 9;
	
	level._classMap["copycat"] = -1;
	
	/#
	// classes testclients may choose from.
	level._botClasses = [];
	level._botClasses[0] = "class0";
	level._botClasses[1] = "class0";
	level._botClasses[2] = "class0";
	level._botClasses[3] = "class0";
	level._botClasses[4] = "class0";
	#/
	
	level._defaultClass = "CLASS_ASSAULT";
	
	level._classTableName = "mp/classTable.csv";
	
	precacheItem( "grapplinghook_mp" );
	PrecacheShader( "hud_hulc" );
	//precacheShader( "waypoint_bombsquad" );
	precacheShader( "specialty_pistoldeath" );
	precacheShader( "specialty_finalstand" );
	precacheShader( "waypoint_escort" );
	precacheShader( "objpoint_default" );
	precacheShader( "compassping_revenge" );
	precacheShader( "compassping_lidar" );
	precacheShader( "waypoint_bomb_headicon" );
	precacheShader( "grappling_hook_indicator" );

	level._effect[ "riotshieldcover_destroyed_mp" ]	= loadfx( "explosions/sentry_gun_explosion" );
	precacheModel( "weapon_riot_shield_cover_dep" );
	precacheModel( "weapon_riot_shield_cover_des" );
	precacheString ( &"MP_HOLD_USERELOAD_TO_PLACE_RIOTSHIELD" );
	precacheString ( &"MP_HOLD_USERELOAD_TO_PICKUP_RIOTSHIELD" );
	precacheString ( &"MP_GRAPPLE_FAILED" );
	precacheString ( &"MP_GRAPPLE_RETICLE" );
	precacheString ( &"MP_2" );
	precacheString ( &"MP_1" );
	precacheString ( &"MP_0" );

	precacheTurret( TROPHY_SYSTEM_TURRET_INFO );
	precacheModel( TROPHY_SYSTEM_TURRET_MODEL );

	level._effect[ "trophy_explosion" ] = loadfx( FX_TROPHY_SYSTEM_EXPLOSION );
	level._effect[ "trophy_firing" ] = loadfx( FX_TROPHY_SYSTEM_FIRING );

	level thread onPlayerConnecting();
}


getClassChoice( response )
{
	assert( isDefined( level._classMap[response] ) );
	
	return response;
}

getWeaponChoice( response )
{
	tokens = strtok( response, "," );
	if ( tokens.size > 1 )
		return int(tokens[1]);
	else
		return 0;
}


logClassChoice( class, primaryWeapon, specialType, perks )
{
	if ( class == self.lastClass )
		return;

	self logstring( "choseclass: " + class + " weapon: " + primaryWeapon + " special: " + specialType );		
	for( i=0; i<perks.size; i++ )
		self logstring( "perk" + i + ": " + perks[i] );
	
	self.lastClass = class;
}


cac_getWeapon( classIndex, weaponIndex )
{
	return self getPlayerData( "customClasses", classIndex, "weaponSetups", weaponIndex, "weapon" );
}

cac_getWeaponAttachment( classIndex, weaponIndex )
{
	return self getPlayerData( "customClasses", classIndex, "weaponSetups", weaponIndex, "attachment", 0 );
}

cac_getWeaponAttachmentTwo( classIndex, weaponIndex )
{
	return self getPlayerData( "customClasses", classIndex, "weaponSetups", weaponIndex, "attachment", 1 );
}

cac_getWeaponCamo( classIndex, weaponIndex )
{
	return self getPlayerData( "customClasses", classIndex, "weaponSetups", weaponIndex, "camo" );
}

cac_getPerk( classIndex, perkIndex )
{
	return self getPlayerData( "customClasses", classIndex, "perks", perkIndex );
}

cac_getKillstreak( classIndex, streakIndex )
{
	return self getPlayerData( "killstreaks", streakIndex );
}

cac_getDeathstreak( classIndex )
{
	return self getPlayerData( "customClasses", classIndex, "perks", 4 );
}

cac_getSuit( classIndex )
{
	return self getPlayerData( "customClasses", classIndex, "perks", 5 );
}

cac_getOffhand( classIndex )
{
	return self getPlayerData( "customClasses", classIndex, "specialGrenade" );
}



table_getWeapon( tableName, classIndex, weaponIndex )
{
	if ( weaponIndex == 0 )
		return tableLookup( tableName, 0, "loadoutPrimary", classIndex + 1 );
	else
		return tableLookup( tableName, 0, "loadoutSecondary", classIndex + 1 );
}

table_getWeaponAttachment( tableName, classIndex, weaponIndex, attachmentIndex )
{
	tempName = "none";
	
	if ( weaponIndex == 0 )
	{
		if ( !isDefined( attachmentIndex ) || attachmentIndex == 0 )
			tempName = tableLookup( tableName, 0, "loadoutPrimaryAttachment", classIndex + 1 );
		else
			tempName = tableLookup( tableName, 0, "loadoutPrimaryAttachment2", classIndex + 1 );
	}
	else
	{
		if ( !isDefined( attachmentIndex ) || attachmentIndex == 0 )
			tempName = tableLookup( tableName, 0, "loadoutSecondaryAttachment", classIndex + 1 );
		else
			tempName = tableLookup( tableName, 0, "loadoutSecondaryAttachment2", classIndex + 1 );
	}
	
	if ( tempName == "" || tempName == "none" )
		return "none";
	else
		return tempName;
	
	
}

table_getWeaponCamo( tableName, classIndex, weaponIndex )
{
	if ( weaponIndex == 0 )
		return tableLookup( tableName, 0, "loadoutPrimaryCamo", classIndex + 1 );
	else
		return tableLookup( tableName, 0, "loadoutSecondaryCamo", classIndex + 1 );
}

table_getLethal( tableName, classIndex, perkIndex )
{
	assert( perkIndex < 5 );
	return tableLookup( tableName, 0, "loadoutLethal", classIndex + 1 );
}

table_getEquipment( tableName, classIndex, perkIndex )
{
	assert( perkIndex < 8 );
	return tableLookup( tableName, 0, "loadoutEquipment", classIndex + 1 );
}

table_getPerk( tableName, classIndex, perkIndex )
{
	assert( perkIndex < 5 );
	return tableLookup( tableName, 0, "loadoutPerk" + perkIndex, classIndex + 1 );
}

table_getRechargeablePerk( tableName, classIndex )
{
	return tableLookup( tableName, 0, "loadoutRechargeablePerk", classIndex + 1 );
}

table_getOffhand( tableName, classIndex )
{
	return tableLookup( tableName, 0, "loadoutOffhand", classIndex + 1 );
}

table_getKillstreak( tableName, classIndex, streakIndex )
{
//	return tableLookup( tableName, 0, "loadoutStreak" + streakIndex, classIndex + 1 );
	return ( "none" );
}

table_getDeathstreak( tableName, classIndex )
{
	return tableLookup( tableName, 0, "loadoutDeathstreak", classIndex + 1 );
}

table_getSuit( tableName, classIndex )
{
	return tableLookup( tableName, 0, "loadoutSuit", classIndex + 1);
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
table_getBuff( tableName, classIndex )
{
	return tableLookup( tableName, 0, "loadoutBuff", classIndex + 1);
}

getClassIndex( className )
{
	assert( isDefined( level._classMap[className] ) );
	
	return level._classMap[className];
}

/*
getPerk( perkIndex )
{
	if( isSubstr( self.pers["class"], "CLASS_CUSTOM" ) )
		return cac_getPerk( self.class_num, perkIndex );
	else
		return table_getPerk( level.classTableName, self.class_num, perkIndex );	
}

getWeaponCamo( weaponIndex )
{
	if( isSubstr( self.pers["class"], "CLASS_CUSTOM" ) )
		return cac_getWeaponCamo( self.class_num, weaponIndex );
	else
		return table_getWeaponCamo( level.classTableName, self.class_num, weaponIndex );	
}
*/

cloneLoadout()
{
	clonedLoadout = [];
	
	class = self.curClass;
	
	if ( class == "copycat" )
		return ( undefined );
	
	if( isSubstr( class, "custom" ) )
	{
		class_num = getClassIndex( class );

		loadoutPrimaryAttachment2 = "none";
		loadoutSecondaryAttachment2 = "none";

		loadoutPrimary = cac_getWeapon( class_num, 0 );
		loadoutPrimaryAttachment = cac_getWeaponAttachment( class_num, 0 );
		loadoutPrimaryAttachment2 = cac_getWeaponAttachmentTwo( class_num, 0 );
		loadoutPrimaryCamo = cac_getWeaponCamo( class_num, 0 );
		loadoutSecondaryCamo = cac_getWeaponCamo( class_num, 1 );
		loadoutSecondary = cac_getWeapon( class_num, 1 );
		loadoutSecondaryAttachment = cac_getWeaponAttachment( class_num, 1 );
		loadoutSecondaryAttachment2 = cac_getWeaponAttachmentTwo( class_num, 1 );
		loadoutSecondaryCamo = cac_getWeaponCamo( class_num, 1 );
		loadoutLethal = cac_getPerk( class_num, 0 );
		loadoutEquipment = cac_getPerk( class_num, 7 );
		loadoutPerk1 = cac_getPerk( class_num, 1 );
		loadoutPerk2 = cac_getPerk( class_num, 2 );
		loadoutPerk3 = cac_getPerk( class_num, 3 );
		loadoutOffhand = cac_getOffhand( class_num );
		loadoutDeathStreak = cac_getDeathstreak( class_num );
		loadoutSuit = cac_getSuit( class_num );
		loadoutRechargeablePerk = cac_getPerk( class_num, 6 );
	}
	else
	{
		class_num = getClassIndex( class );
		
		loadoutPrimary = table_getWeapon( level._classTableName, class_num, 0 );
		loadoutPrimaryAttachment = table_getWeaponAttachment( level._classTableName, class_num, 0 , 0);
		loadoutPrimaryAttachment2 = table_getWeaponAttachment( level._classTableName, class_num, 0, 1 );
		loadoutPrimaryCamo = table_getWeaponCamo( level._classTableName, class_num, 0 );
		loadoutSecondary = table_getWeapon( level._classTableName, class_num, 1 );
		loadoutSecondaryAttachment = table_getWeaponAttachment( level._classTableName, class_num, 1 , 0);
		loadoutSecondaryAttachment2 = table_getWeaponAttachment( level._classTableName, class_num, 1, 1 );;
		loadoutSecondaryCamo = table_getWeaponCamo( level._classTableName, class_num, 1 );
		loadoutLethal = table_getLethal( level._classTableName, class_num, 0 );
		loadoutEquipment = table_getEquipment( level._classTableName, class_num, 0 );
		loadoutPerk1 = table_getPerk( level._classTableName, class_num, 1 );
		loadoutPerk2 = table_getPerk( level._classTableName, class_num, 2 );
		loadoutPerk3 = table_getPerk( level._classTableName, class_num, 3 );
		loadoutOffhand = table_getOffhand( level._classTableName, class_num );
		loadoutDeathstreak = table_getDeathstreak( level._classTableName, class_num );
		loadoutSuit = table_getSuit( level._classTableName, class_num );
		loadoutRechargeablePerk = table_getRechargeablePerk( level._classTableName, class_num );
	}
	
	clonedLoadout["inUse"] = false;
	clonedLoadout["loadoutPrimary"] = loadoutPrimary;
	clonedLoadout["loadoutPrimaryAttachment"] = loadoutPrimaryAttachment;
	clonedLoadout["loadoutPrimaryAttachment2"] = loadoutPrimaryAttachment2;
	clonedLoadout["loadoutPrimaryCamo"] = loadoutPrimaryCamo;
	clonedLoadout["loadoutSecondary"] = loadoutSecondary;
	clonedLoadout["loadoutSecondaryAttachment"] = loadoutSecondaryAttachment;
	clonedLoadout["loadoutSecondaryAttachment2"] = loadoutSecondaryAttachment2;
	clonedLoadout["loadoutSecondaryCamo"] = loadoutSecondaryCamo;
	clonedLoadout["loadoutLethal"] = loadoutLethal;
	clonedLoadout["loadoutEquipment"] = loadoutEquipment;
	clonedLoadout["loadoutPerk1"] = loadoutPerk1;
	clonedLoadout["loadoutPerk2"] = loadoutPerk2;
	clonedLoadout["loadoutPerk3"] = loadoutPerk3;
	clonedLoadout["loadoutOffhand"] = loadoutOffhand;
	clonedLoadout["loadoutSuit"] = loadoutSuit;
	clonedLoadout["loadoutRechargeablePerk"] = loadoutRechargeablePerk;
	
	return ( clonedLoadout );
}

giveLoadout( team, class, allowCopycat )
{
	self takeAllWeapons();
	
	primaryIndex = 0;
	
	// initialize specialty array
	self.specialty = [];

	if ( !isDefined( allowCopycat ) )
		allowCopycat = true;

	primaryWeapon = undefined;
	loadoutBuff = undefined;
	loadoutRechargeablePerk = undefined;

	if ( isDefined( self.pers["copyCatLoadout"] ) && self.pers["copyCatLoadout"]["inUse"] && allowCopycat )
	{
		self maps\mp\gametypes\_class::setClass( "copycat" );
		self.class_num = getClassIndex( "copycat" );

		clonedLoadout = self.pers["copyCatLoadout"];

		loadoutPrimary = clonedLoadout["loadoutPrimary"];
		loadoutPrimaryAttachment = clonedLoadout["loadoutPrimaryAttachment"];
		loadoutPrimaryAttachment2 = clonedLoadout["loadoutPrimaryAttachment2"] ;
		loadoutPrimaryCamo = clonedLoadout["loadoutPrimaryCamo"];
		loadoutSecondary = clonedLoadout["loadoutSecondary"];
		loadoutSecondaryAttachment = clonedLoadout["loadoutSecondaryAttachment"];
		loadoutSecondaryAttachment2 = clonedLoadout["loadoutSecondaryAttachment2"];
		loadoutSecondaryCamo = clonedLoadout["loadoutSecondaryCamo"];
		loadoutLethal = clonedLoadout["loadoutLethal"];
		loadoutEquipment = clonedLoadout["loadoutEquipment"];
		loadoutPerk1 = clonedLoadout["loadoutPerk1"];
		loadoutPerk2 = clonedLoadout["loadoutPerk2"];
		loadoutPerk3 = clonedLoadout["loadoutPerk3"];
		loadoutOffhand = clonedLoadout["loadoutOffhand"];
		loadoutDeathStreak = "specialty_copycat";
		//loadoutSuit = clonedLoadout["loadoutSuit"];
		loadoutRechargeablePerk = clonedLoadout["loadoutSuit"];
	}
	else if ( isSubstr( class, "custom" ) )
	{
		class_num = getClassIndex( class );
		self.class_num = class_num;

		loadoutPrimary = cac_getWeapon( class_num, 0 );
		loadoutPrimaryAttachment = cac_getWeaponAttachment( class_num, 0 );
		loadoutPrimaryAttachment2 = cac_getWeaponAttachmentTwo( class_num, 0 );
		loadoutPrimaryCamo = cac_getWeaponCamo( class_num, 0 );
		loadoutSecondaryCamo = cac_getWeaponCamo( class_num, 1 );
		loadoutSecondary = cac_getWeapon( class_num, 1 );
		loadoutSecondaryAttachment = cac_getWeaponAttachment( class_num, 1 );
		loadoutSecondaryAttachment2 = cac_getWeaponAttachmentTwo( class_num, 1 );
		loadoutSecondaryCamo = cac_getWeaponCamo( class_num, 1 );
		loadoutLethal = cac_getPerk( class_num, 0 );
		loadoutEquipment = cac_getPerk( class_num, 7 );
		loadoutPerk1 = cac_getPerk( class_num, 1 );
		loadoutPerk2 = cac_getPerk( class_num, 2 );
		loadoutPerk3 = cac_getPerk( class_num, 3 );
		loadoutOffhand = cac_getOffhand( class_num );
		loadoutDeathStreak = cac_getDeathstreak( class_num );
		//loadoutSuit = cac_getSuit( class_num );
		loadoutBuff = cac_getPerk( class_num, 5 ); 
		loadoutRechargeablePerk = cac_getPerk( class_num, 6 );
		println( "rechargeable perk is " + loadoutRechargeablePerk );
	}
	else
	{
		class_num = getClassIndex( class );
		self.class_num = class_num;
		
		loadoutPrimary = table_getWeapon( level._classTableName, class_num, 0 );
		loadoutPrimaryAttachment = table_getWeaponAttachment( level._classTableName, class_num, 0 , 0);
		loadoutPrimaryAttachment2 = table_getWeaponAttachment( level._classTableName, class_num, 0, 1 );
		loadoutPrimaryCamo = table_getWeaponCamo( level._classTableName, class_num, 0 );
		loadoutSecondaryCamo = table_getWeaponCamo( level._classTableName, class_num, 1 );
		loadoutSecondary = table_getWeapon( level._classTableName, class_num, 1 );
		loadoutSecondaryAttachment = table_getWeaponAttachment( level._classTableName, class_num, 1 , 0);
		loadoutSecondaryAttachment2 = table_getWeaponAttachment( level._classTableName, class_num, 1, 1 );;
		loadoutSecondaryCamo = table_getWeaponCamo( level._classTableName, class_num, 1 );
		loadoutLethal = table_getLethal( level._classTableName, class_num, 0 );
		loadoutEquipment = table_getEquipment( level._classTableName, class_num, 0 );
		loadoutPerk1 = table_getPerk( level._classTableName, class_num, 1 );
		loadoutPerk2 = table_getPerk( level._classTableName, class_num, 2 );
		loadoutPerk3 = table_getPerk( level._classTableName, class_num, 3 );
		loadoutOffhand = table_getOffhand( level._classTableName, class_num );
		loadoutDeathstreak = table_getDeathstreak( level._classTableName, class_num );
		//loadoutSuit = table_getSuit( level._classTableName, class_num );
		loadoutBuff = table_getBuff( level._classTableName, class_num );
		loadoutRechargeablePerk = table_getRechargeablePerk( level._classTableName, class_num );
		println( "recharegable perk is " + loadoutRechargeablePerk );
	}

	if ( !(isDefined( self.pers["copyCatLoadout"] ) && self.pers["copyCatLoadout"]["inUse"] && allowCopycat) )
	{
		isCustomClass = isSubstr( class, "custom" );
		
		if ( !isValidPrimary( loadoutPrimary ) || (isCustomClass && !self isItemUnlocked( loadoutPrimary )) )
			loadoutPrimary = table_getWeapon( level._classTableName, 10, 0 );
		
		if ( !isValidAttachment( loadoutPrimaryAttachment ) || (isCustomClass && !self isItemUnlocked( loadoutPrimary + " " + loadoutPrimaryAttachment )) )
			loadoutPrimaryAttachment = table_getWeaponAttachment( level._classTableName, 10, 0 , 0);
		
		if ( !isValidAttachment( loadoutPrimaryAttachment2 ) || (isCustomClass && !self isItemUnlocked( loadoutPrimary + " " + loadoutPrimaryAttachment2 )) )
			loadoutPrimaryAttachment2 = table_getWeaponAttachment( level._classTableName, 10, 0, 1 );
		
		if ( !isValidCamo( loadoutPrimaryCamo ) || (isCustomClass && !self isItemUnlocked( loadoutPrimary + " " + loadoutPrimaryCamo )) )
			loadoutPrimaryCamo = table_getWeaponCamo( level._classTableName, 10, 0 );
		
		if ( !isValidSecondary( loadoutSecondary, loadoutPerk2 ) || (isCustomClass && !self isItemUnlocked( loadoutSecondary )) )
			loadoutSecondary = table_getWeapon( level._classTableName, 10, 1 );
		
		if ( !isValidAttachment( loadoutSecondaryAttachment ) || (isCustomClass && !self isItemUnlocked( loadoutSecondary + " " + loadoutSecondaryAttachment )) )
			loadoutSecondaryAttachment = table_getWeaponAttachment( level._classTableName, 10, 1 , 0);
		
		if ( !isValidAttachment( loadoutSecondaryAttachment2 ) || (isCustomClass && !self isItemUnlocked( loadoutSecondary + " " + loadoutSecondaryAttachment2 )) )
			loadoutSecondaryAttachment2 = table_getWeaponAttachment( level._classTableName, 10, 1, 1 );;
		
		if ( !isValidCamo( loadoutSecondaryCamo ) || (isCustomClass && !self isItemUnlocked( loadoutSecondary + " " + loadoutSecondaryCamo )) )
			loadoutSecondaryCamo = table_getWeaponCamo( level._classTableName, 10, 1 );
		
		if ( !isValidLethal( loadoutLethal ) || (isCustomClass && !self isItemUnlocked( loadoutLethal )) )
			loadoutLethal = table_getLethal( level._classTableName, 10, 0 );
		
		if ( !isValidEquipment( loadoutEquipment ) || (isCustomClass && !self isItemUnlocked( loadoutEquipment )) )
			loadoutEquipment = table_getEquipment( level._classTableName, 10, 0 );

		if ( !isValidPerk1( loadoutPerk1 ) || (isCustomClass && !self isItemUnlocked( loadoutPerk1 )) )
			loadoutPerk1 = table_getPerk( level._classTableName, 10, 1 );
		
		if ( !isValidPerk2( loadoutPerk2 ) || (isCustomClass && !self isItemUnlocked( loadoutPerk2 )) )
			loadoutPerk2 = table_getPerk( level._classTableName, 10, 2 );
		
		if ( !isValidPerk3( loadoutPerk3 ) || (isCustomClass && !self isItemUnlocked( loadoutPerk3 )) )
			loadoutPerk3 = table_getPerk( level._classTableName, 10, 3 );
		
		if ( !isValidOffhand( loadoutOffhand ) )
			loadoutOffhand = table_getOffhand( level._classTableName, 10 );
		
		if ( !isValidDeathstreak( loadoutDeathstreak ) || (isCustomClass && !self isItemUnlocked( loadoutDeathstreak )) )
			loadoutDeathstreak = table_getDeathstreak( level._classTableName, 10 );
	}

    // changed by JKU to unlock bling by default
	/*
	if ( loadoutPerk3 != "specialty_bling" )
	{
		loadoutPrimaryAttachment2 = "none";
		loadoutSecondaryAttachment2 = "none";
	}
	*/
	
	if ( loadoutPerk2 != "specialty_onemanarmy" && loadoutSecondary == "onemanarmy" )
		loadoutSecondary = table_getWeapon( level._classTableName, 10, 1 );

	self.currentSuit = loadoutPerk1;

	loadoutSecondaryCamo = "none";

	if ( level._killstreakRewards )
	{
		loadoutKillstreak1 = self getPlayerData( "killstreaks", 0 );
		loadoutKillstreak2 = self getPlayerData( "killstreaks", 1 );
		loadoutKillstreak3 = self getPlayerData( "killstreaks", 2 );
	}
	else
	{
		loadoutKillstreak1 = "none";
		loadoutKillstreak2 = "none";
		loadoutKillstreak3 = "none";
	}
	
	secondaryName = buildWeaponName( loadoutSecondary, loadoutSecondaryAttachment, loadoutSecondaryAttachment2 );
	self _giveWeapon( secondaryName, int(tableLookup( "mp/camoTable.csv", 1, loadoutSecondaryCamo, 0 ) ) );

	self.loadoutPrimaryCamo = int(tableLookup( "mp/camoTable.csv", 1, loadoutPrimaryCamo, 0 ));
	self.loadoutPrimary = loadoutPrimary;
	self.loadoutSecondary = loadoutSecondary;
	self.loadoutSecondaryCamo = int(tableLookup( "mp/camoTable.csv", 1, loadoutSecondaryCamo, 0 ));
	self.rechargeablePerk = undefined;
	
	self SetOffhandPrimaryClass( "other" );
	
	// Action Slots

	//Giving the equipment weapon, ammo, and assign it to be the Up on D-Pad to activate
	self _giveWeapon( loadoutEquipment, 0 );
	if ( loadoutEquipment == "flare_mp" )
	{
		self thread maps\mp\perks\_perkfunctions::monitorTIUse();
	}
 
	self _SetActionSlot( 1, "weapon", loadoutEquipment );
	self SetWeaponAmmoStock( loadoutEquipment, WeaponStartAmmo ( loadoutEquipment ));

	self _SetActionSlot( 3, "altMode" );
	self _SetActionSlot( 4, "" );

	// Perks
	self _clearPerks();
	self _detachAll();
	
	// these special case giving pistol death have to come before
	// perk loadout to ensure player perk icons arent overwritten
	if ( level._dieHardMode )
		self maps\mp\perks\_perks::givePerk( "specialty_pistoldeath" );
	
	// only give the deathstreak for the initial spawn for this life.
	if ( loadoutDeathStreak != "specialty_null" && getTime() == self.spawnTime )
	{
		deathVal = int( tableLookup( "mp/perkTable.csv", 1, loadoutDeathStreak, 6 ) );
		
		if ( self getPerkUpgrade( loadoutPerk1 ) == "specialty_rollover" || self getPerkUpgrade( loadoutPerk2 ) == "specialty_rollover" || self getPerkUpgrade( loadoutPerk3 ) == "specialty_rollover" )
			deathVal -= 1;
		
		if ( self.pers["cur_death_streak"] == deathVal )
		{
			self thread maps\mp\perks\_perks::givePerk( loadoutDeathStreak );
			self thread maps\mp\gametypes\_hud_message::splashNotify( loadoutDeathStreak );
		}
		else if ( self.pers["cur_death_streak"] > deathVal && loadoutDeathStreak != "specialty_uav" )
		{
			self thread maps\mp\perks\_perks::givePerk( loadoutDeathStreak );
		}
	}
	
	self loadoutAllPerks( loadoutLethal, loadoutPerk1, loadoutPerk2, loadoutPerk3, loadoutRechargeablePerk );

	// Network perk isn't stored in the typical perk array because calls to hasPerk and givePerk
	// are for the teammates who RECEIVE the benefits of this network perk's owner
	//  - this is just a field in the "player" script struct
	if ( isDefined( loadoutBuff ))
	{
		self._netBuff = loadoutBuff;
	}
	
	//if ( loadoutSuit != "specialty_null" )
	//{
	//	self thread maps\mp\perks\_perks::givePerk( loadoutSuit );
	//}

	self setKillstreaks( loadoutKillstreak1, loadoutKillstreak2, loadoutKillstreak3 );
		
	if ( self hasPerk( "specialty_extraammo", true ) && getWeaponClass( secondaryName ) != "weapon_projectile" )
		self giveMaxAmmo( secondaryName );

	// Primary Weapon
	primaryName = buildWeaponName( loadoutPrimary, loadoutPrimaryAttachment, loadoutPrimaryAttachment2 );
	self _giveWeapon( primaryName, self.loadoutPrimaryCamo );
	
	// fix changing from a riotshield class to a riotshield class during grace period not giving a shield
	if ( primaryName == "riotshield_mp" && level._inGracePeriod )
		self notify ( "weapon_change", "riotshield_mp" );

	if ( primaryName == "riotshieldcloak_mp" && level._inGracePeriod )
		self notify ( "weapon_change", "riotshieldcloak_mp" );

	if ( primaryName == "riotshieldcover_mp" && level._inGracePeriod )
		self notify ( "weapon_change", "riotshieldcover_mp" );

	if ( primaryName == "riotshieldxray_mp" && level._inGracePeriod )
		self notify ( "weapon_change", "riotshieldxray_mp" );

	if ( self hasPerk( "specialty_extraammo", true ) )
		self giveMaxAmmo( primaryName );

	self setSpawnWeapon( primaryName );
	
	primaryTokens = strtok( primaryName, "_" );
	self.pers["primaryWeapon"] = primaryTokens[0];
	
	// Primary Offhand was given by givePerk (it's your perk1)
	
	//tagJC<NOTE>: Make sure all the grappling hook related threads are killed after player spawns
	self notify ( "clear_grapple_reticle" );
	if ( isDefined ( self.GrappleReticle ) )
	{
		self.GrappleReticle Destroy();
	}

	if ( isDefined ( level._GrappleObjective ) )
	{
		for ( i = 0; i < level._GrappleObjective.size; i++)
		{
			if ( isDefined( level._GrappleObjective[i].entityHeadIcons ))
			{
				foreach( key, headIcon in level._GrappleObjective[i].entityHeadIcons )
				{	
					if( !isDefined( headIcon ) )
					{
						continue;
					}
					if ( key == self.guid )
					{
						headIcon destroy();
					}
				}
			}
		}
	}

	// Secondary Offhand
	offhandSecondaryWeapon = loadoutOffhand + "_mp";
	if ( loadoutOffhand == "emp_grenade" )
	{
		self SetOffhandSecondaryClass( "emp" );
	}
	else if( loadoutOffhand == "gas_grenade" )
	{
		self SetOffhandSecondaryClass( "gas" );
	}
	else if( loadoutOffhand == "lidar_grenade" )
	{
		self SetOffhandSecondaryClass( "lidar" );
	}
	else if ( loadoutOffhand == "flash_grenade" )
	{
		self SetOffhandSecondaryClass( "flash" );
	}
	else
	{
		self SetOffhandSecondaryClass( "smoke" );
	}
	
	//Give the weapon and ammo ( if the offhand classes are set up correcly the weapon will go into the correct hand ).
	if  ( loadoutPerk1 != "specialty_twoprimariesoffhand" )
	{	
		if( loadOutOffhand == "emp_grenade" )
		{
			self giveWeapon( offhandSecondaryWeapon );
			self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
		}
		else if( loadOutOffhand == "smoke_grenade" )
		{
			self giveWeapon( offhandSecondaryWeapon );
			self setWeaponAmmoClip( offhandSecondaryWeapon, 1 );
		}
		else if( loadOutOffhand == "flash_grenade" )
		{
			self giveWeapon( offhandSecondaryWeapon );
			self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
		}
		else if( loadOutOffhand == "concussion_grenade" )
		{
			self giveWeapon( offhandSecondaryWeapon );
			self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
		}
		else if ( loadOutOffhand == "lidar_grenade" )
		{
			self giveWeapon( offhandSecondaryWeapon );
			self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
		}
		else if ( loadOutOffhand == "gas_grenade" )
		{
			self giveWeapon( offhandSecondaryWeapon );
			self setWeaponAmmoClip( offhandSecondaryWeapon, 1 );
		}
	}
	if (( loadOutPerk1 == "specialty_twoprimariesoffhand" ) && !( isDefined ( level._disableWarSuit) && level._disableWarSuit == true )) 
	{
		self.HULCGrenadeCount = HULC_GRENADE_COUNT;
		self createHULCGrenadeCounter();
		self refreshHULCCount();
		self thread waitForHULCGrenadeActivationTactical( loadoutoffhand );
	}

	if ( ( loadOutPerk1 != "specialty_twoprimarieslethal" ) && ( loadOutPerk1 != "specialty_twoprimariesoffhand" ) )
	{
		self cleanHULChud();
	}

	// Check for grappling hook perk and equip the grappling hook weapon to offhandsecondary
	if( _hasPerk( "specialty_grapplinghook" ))
	{
		println ( "has perk grappling hook" );
		self SetOffhandSecondaryClass( "throwingknife" );
		self giveWeapon( "grapplinghook_mp" );
		self setWeaponAmmoClip( "grapplinghook_mp", 20 );
		self thread waitForGrapplingHookActivation();
	}

	primaryWeapon = primaryName;
	self.primaryWeapon = primaryWeapon;
	self.secondaryWeapon = secondaryName;

	self maps\mp\gametypes\_teams::playerModelForWeapon( self.pers["primaryWeapon"], getBaseWeaponName( secondaryName ) );
		
	self.isSniper = (weaponClass( self.primaryWeapon ) == "sniper");
	
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );

	// added for JKU PROTOTYPE for riot shields
	//self SetXRayVision ( true );

	// cac specialties that require loop threads
	self maps\mp\perks\_perks::cac_selector();
	
	if ( isSubstr( class, "custom" ) )
	{
		self thread blackboxClassChoice( self.class_num, primaryName, secondaryName, offhandSecondaryWeapon, loadoutEquipment );
	}
	
	self notify ( "changed_kit" );
	self notify ( "giveLoadout" );

	// To give the trophy suit the trophy system
	/*
	if (( loadoutPerk1 == "specialty_flakjacket" ) && !( isDefined ( level._disableWarSuit) && level._disableWarSuit == true ))
	{
		 self thread activateTrophySystem();
	}
	if (( loadOutPerk1 == "specialty_twoprimarieslethal" ) && ( loadoutlethal != "throwingknife_mp" ) && ( loadoutlethal != "frag_grenade_mp" ) && ( loadoutlethal != "semtex_mp" ) && !( isDefined ( level._disableWarSuit) && level._disableWarSuit == true ))
	{
		self.HULCGrenadeCount = HULC_GRENADE_COUNT;
		self createHULCGrenadeCounter();
		self refreshHULCCount();
		if (( loadoutlethal != "hulc_semtex_mp" ) && ( loadoutlethal != "hulc_frag_mp" ) && ( loadoutlethal != "hulc_n00b_mp" ))
		{
			self thread ProjectileWeap_waitForHULCGrenadeActivationLethal( loadoutlethal );
		}
		else
		{
			self thread Grenade_waitForHULCGrenadeActivationLethal( loadoutlethal );
		}
	}
	*/
}

//*******************************************************************
//                   Section for HULC Grenade                       *
//                                                                  *
//*******************************************************************
waitForHULCGrenadeActivationTactical( grenadename )
{
	self endon ( "death" );
	self endon ( "changed_kit" );

	self notifyOnPlayerCommand( "use_hulc_grenade_tactical", "+smoke" );

	hulc_weapon_name = "hulc_" + grenadename + "_mp";
	
	while ( 1 )
	{
		if ( self.HULCGrenadeCount == 0 )
		{
			break;
		}
		self waittill ( "use_hulc_grenade_tactical" );
		if ( isDefined ( self GetTagOrigin (HULC_SHOULDER_TAG)))
		{
			StartLocation = (self GetTagOrigin (HULC_SHOULDER_TAG));
		}
		else
		{
			StartLocation = (self GetTagOrigin ( "TAG_WEAPON_CHEST" ));
		}
		EndLocation = StartLocation + ( anglesToForward( self getPlayerAngles() ) * 100 );

		self notify ( "grenade_pullback", HULC_weapon_name );
		waitframe();
		hulc_grenade = MagicBullet( hulc_weapon_name, StartLocation , EndLocation, self );
		self notify ( "grenade_fire", hulc_grenade, HULC_weapon_name );
		self.HULCGrenadeCount = self.HULCGrenadeCount - 1;
		self refreshHULCCount();
	}
}

ProjectileWeap_waitForHULCGrenadeActivationLethal( rocketname )
{
	self endon ( "death" );
	self endon ( "changed_kit" );

	self notifyOnPlayerCommand( "use_hulc_grenade_lethal", "+frag" );

	hulc_weapon_name = rocketname;

	while ( 1 )
	{
		if ( self.HULCGrenadeCount == 0 )
		{
			break;
		}
		self waittill ( "use_hulc_grenade_lethal" );
		if ( isDefined ( self GetTagOrigin (HULC_SHOULDER_TAG)))
		{
			StartLocation = (self GetTagOrigin (HULC_SHOULDER_TAG));
		}
		else
		{
			StartLocation = (self GetTagOrigin ( "TAG_WEAPON_CHEST" ));
		}
		EndLocation = StartLocation + ( anglesToForward( self getPlayerAngles() ) * 100 );
		self notify ( "grenade_pullback", HULC_weapon_name );
		waitframe();
		hulc_grenade = MagicBullet( hulc_weapon_name, StartLocation , EndLocation, self );
		self notify ( "grenade_fire", hulc_grenade, HULC_weapon_name );
		self.HULCGrenadeCount = self.HULCGrenadeCount - 1;
		self refreshHULCCount();
		wait 1.0;
	}
}

Grenade_waitForHULCGrenadeActivationLethal( grenadename )
{
	self endon ( "death" );
	self endon ( "changed_kit" );
	self notifyOnPlayerCommand( "use_hulc_grenade_lethal", "+frag" );

	init_velocity = GetDvarInt( "hulc_projectile_velocity", 1500 );
	up_offset = GetDvarInt( "hulc_projectile_up_offset", 10 );

	up_offset = up_offset * -1;

	while ( 1 )
	{
		if ( self.HULCGrenadeCount == 0 )
		{
			break;
		}
		
		self waittill ( "use_hulc_grenade_lethal" );
		
		if ( isDefined ( self GetTagOrigin (HULC_SHOULDER_TAG)))
		{
			StartLocation = (self GetTagOrigin (HULC_SHOULDER_TAG));
		}
		else
		{
			StartLocation = (self GetTagOrigin ("TAG_WEAPON_CHEST"));
		}
		angles = self getPlayerAngles();
		angles += (up_offset, 0, 0);
		dir = anglesToForward( angles );
		vel = init_velocity;

		//manually force the "grenade_pullback" notification since hulc grenades do not pullback
		self notify ( "grenade_pullback", grenadename );
		waitframe();

		hulc_grenade = launchgrenade( grenadename, StartLocation , dir, vel, self );
		
		//decrement grenade count
		self.HULCGrenadeCount = self.HULCGrenadeCount - 1;
		self refreshHULCCount();
		wait 1.0;
	}
}

sendingHULCNotification( HULC_weapon_entity, HULC_weapon_name )
{
	self notify ( "grenade_pullback", HULC_weapon_name );
	waitframe();
	self notify ( "grenade_fire", HULC_weapon_entity, HULC_weapon_name );
}

createHULCGrenadeCounter()
{
	if ( !isDefined( self.HULCImage ) )
	{
		self.HULCImage = newClientHudElem(self);
		self.HULCImage setShader ( "hud_hulc", 20, 20);
		self.HULCImage.archived = false;
		self.HULCImage.x = 294;
		self.HULCImage.alignX = "center";
		self.HULCImage.alignY = "middle";
		self.HULCImage.horzAlign = "center";
		self.HULCImage.vertAlign = "middle";
		self.HULCImage.sort = 1; // force to draw after the bars
		self.HULCImage.font = "default";
		self.HULCImage.foreground = true;
		self.HULCImage.hideWhenInMenu = true;
		self.HULCImage.alpha = 1.0;
		self.HULCImage.color = ( 0.6, 0.9, 0.6 );
		
		if ( level._splitscreen )
		{
			self.HULCImage.y = 20;
			self.HULCImage.fontscale = 2; // 1.8/1.5
		}
		else
		{
			self.HULCImage.y = 181;
			self.HULCImage.fontscale = 2;
		}
	}
	self createHULCCount();
}

refreshHULCCount()
{
	if ( isDefined( self.HULCCount ))
	{
		if ( self.HULCGrenadeCount == 2 )
		{
			self.HULCCount SetText( &"MP_2" );
		}
		else if ( self.HULCGrenadeCount == 1 )
		{
			self.HULCCount SetText( &"MP_1" );
		}
		else if ( self.HULCGrenadeCount == 0 )
		{
			self.HULCCount SetText( &"MP_0" );
		}
	}
}

createHULCCount()
{
	if ( !isDefined( self.HULCCount ) )
	{
		self.HULCCount = CreateFontString( "fwmed", 1 );;
		self.HULCCount SetText( &"MP_2" );
		self.HULCCount.archived = false;
		self.HULCCount.x = 312;
		self.HULCCount.alignX = "center";
		self.HULCCount.alignY = "middle";
		self.HULCCount.horzAlign = "center";
		self.HULCCount.vertAlign = "middle";
		self.HULCCount.sort = 1; // force to draw after the bars
		self.HULCCount.font = "fwmed";
		self.HULCCount.foreground = true;
		self.HULCCount.hideWhenInMenu = true;
		self.HULCCount.alpha = 1.0;
		self.HULCCount.color = ( 0.6, 0.9, 0.6 );
		
		if ( level._splitscreen )
		{
			self.HULCCount.y = 20;
			self.HULCCount.fontscale = 1.7; // 1.8/1.5
		}
		else
		{
			self.HULCCount.y = 181;
			self.HULCCount.fontscale = 1.7;
		}
	}
}

cleanHULChud()
{
	if ( isDefined( self.HULCImage ))
	{
		self.HULCImage destroy();
	}

	if ( isDefined( self.HULCCount ))
	{
		self.HULCCount destroy();
	}
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
waitForGrapplingHookActivation()
{
	self notify ( "clear_grapple_reticle" );
	self endon ( "clear_grapple_reticle" );
	self endon ( "death" );
	
	if ( isDefined ( level._GrappleObjective ) )
	{
		while ( 1 )
		{
			if ( self AnyAmmoForWeaponModes( "grapplinghook_mp" ))
			{
				self notifyOnPlayerCommand( "use_grapple", "+smoke" );
				self waittill ( "use_grapple" );
				self.GrappleReticle = CreateGrappleReticle( self, "white" );
				self.GrappleReticleColor = "white";
				self thread IsGrappleTargetDetected();
				self thread CreateGrappleObjective();
				self notifyOnPlayerCommand( "weapon_switch_during_grapple", "weapnext" );
				self waittill_either ( "grenade_fire" , "weapon_switch_during_grapple" );
				self.GrappleReticle Destroy();
				for ( i = 0; i < level._GrappleObjective.size; i++)
				{
					if ( isDefined( level._GrappleObjective[i].entityHeadIcons ))
					{
						foreach( key, headIcon in level._GrappleObjective[i].entityHeadIcons )
						{	
							if( !isDefined( headIcon ) )
							{
								continue;
							}
							if ( key == self.guid )
							{
								headIcon destroy();
							}
						}
					}
				}
				self notify ( "grapple_fired" );
			}
			wait ( 0.65 );
		}
	}
}

IsGrappleTargetDetected()
{
	LOOK_UP_ANGLE_LIMIT = 30;
	DISTANCE_BELOW_EYE = 35;

	self endon ( "weapon_switch_during_grapple" );
	self endon ( "grapple_fired" );
	self endon ( "death" );	
	self endon ( "clear_grapple_reticle" );

	self.GrappleTargetDetected = 0;
	while ( 1 )
	{
		eye = self geteye();
		angles = self getplayerangles();
		feet = eye - (0, 0, DISTANCE_BELOW_EYE);

		trace_from_eye = self get_grapple_designated_trace( eye, angles );
		viewpoint_eye = trace_from_eye[ "position" ];
		viewpoint_feet = viewpoint_eye - (0, 0, DISTANCE_BELOW_EYE);
		entity_eye = trace_from_eye [ "entity" ];

		player_to_target_vector = VectorNormalize( viewpoint_eye - self.origin );
		player_to_target_onGround = VectorNormalize( player_to_target_vector * (1, 1, 0));
		dot_product = VectorDot ( player_to_target_vector, player_to_target_onGround ); 
		
		if ( ( IsDefined( entity_eye ) ) && ( IsDefined( entity_eye.targetname ) ) && ( entity_eye.targetname == "grapple_target" ) && ( entity_eye.origin [2] > ( self.origin + (0 ,0 , 150)) [2] )) 
		//if ( ( dot_product > cos ( LOOK_UP_ANGLE_LIMIT )) && ( IsDefined( entity_eye ) ) && ( IsDefined( entity_eye.targetname ) ) && ( entity_eye.targetname == "grapple_target" ) && ( entity_eye.origin [2] > ( self.origin + (0 ,0 , 150)) [2] ))
		//if ( ( dot_product < cos ( LOOK_UP_ANGLE_LIMIT )) &&  ( SightTracePassed ( feet, viewpoint_feet, true, self) ) && ( IsDefined( entity_eye ) ) && ( IsDefined( entity_eye.targetname ) ) && ( entity_eye.targetname == "grapple_target" ) && ( entity_eye.origin [2] > ( self.origin + (0 ,0 , 150)) [2] ))
		{
			self.GrappleTargetDetected = 1;
			self.TargetedGrappleTarget = viewpoint_eye;
			self.TargetedGrappleEntity = entity_eye;
			if ( self.GrappleReticleColor == "white" )
			{
				self.GrappleReticle Destroy();
				self.GrappleReticle = CreateGrappleReticle( self, "red" );
				self.GrappleReticleColor = "red";
			}
		}
		else 
		{
			if ( self.GrappleReticleColor == "red" )
			{
				self.GrappleReticle Destroy();
				self.GrappleReticle = CreateGrappleReticle( self, "white" );
				self.GrappleReticleColor = "white";
			}
			self.GrappleTargetDetected = 0;
			self.TargetedGrappleTarget = undefined;
			self.TargetedGrappleEntity = undefined;
		}
		wait ( 0.05 );
	}
}

get_grapple_designated_trace( position, angles )
{
	GRAPPLE_DETECT_DISTANCE = 2000;

	forward = anglestoforward( angles );
	end = position + vector_multiply( forward, GRAPPLE_DETECT_DISTANCE );
	trace = bullettrace( position, end, true, self );
 
	return trace;
}

CreateGrappleReticle( player, color )
{
	hudelem = newClientHudElem( player );
	hudelem.label = &"MP_GRAPPLE_RETICLE";
	hudelem.alignX = "center";
	hudelem.alignY = "middle";
	hudelem.horzAlign = "center";
	hudelem.vertAlign = "middle";
	hudelem.fontScale = 1;
	if ( color == "white" )
	{
		hudelem.color = ( 1, 1, 1 );
	}
	else if ( color == "red" )
	{
		hudelem.color = ( 1, 0, 0);
	}
	hudelem.font = "objective";
	hudelem.foreground = 1;
	hudelem.hidewheninmenu = true;
	hudelem.hidewhendead = true;
	return hudelem;
}

CreateGrappleObjective ()
{	
	self endon ( "weapon_switch_during_grapple" );
	self endon ( "grapple_fired" );
	self endon ( "death" );	

	for ( i = 0; i < level._GrappleObjective.size ; i++)
	{
		if (( distance ( level._GrappleObjective[i].origin, self.origin) < 1000 ) && ( level._GrappleObjective[i].origin [2] > ( self.origin + (0 ,0 , 150)) [2] ))
		{
			level._GrappleObjective[i] maps\mp\_entityheadIcons::setHeadIcon( 
				self, 
				"grappling_hook_indicator", 
				( 0, 0, 0 ), 
				10, 
				10, 
				false, 
				60, 
				false, 
				true, 
				true,
				false );
			
		}
	}
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

blackboxClassChoice( class_index, primary, secondary, grenades, equipment )
{
	spawnid = 0; //getplayerspawnid( self );

	bbPrint( "mploadouts: spawnid %d body %s head %s primary %s secondary %s grenade %s special none equipment %s",
			spawnid,
			self.cac_body_type,
			self.cac_head_type,
			primary,
			secondary,
			grenades,
			equipment
		   );

	if( isDefined( self.killstreak ))
	{
		for ( i = 0; i < self.killstreak.size; i++ )
		{
			bbPrint( "mpkillstreaks: spawnid %d name %s", spawnid, self.killstreak[i] );
		}
	}

	// -1 is copycat class_num
	if ( class_index == -1 && isDefined( self.pers["copyCatLoadout"] ) && self.pers["copyCatLoadout"]["inUse"] )
	{
		bbPrint( "mpspecialties: spawnid %d name %s", spawnid, self.pers["copyCatLoadout"]["loadoutEquipment"] );
		bbPrint( "mpspecialties: spawnid %d name %s", spawnid, self.pers["copyCatLoadout"]["loadoutPerk1"] );
		bbPrint( "mpspecialties: spawnid %d name %s", spawnid, self.pers["copyCatLoadout"]["loadoutPerk2"] );
		bbPrint( "mpspecialties: spawnid %d name %s", spawnid, self.pers["copyCatLoadout"]["loadoutPerk3"] );
	}
	else
	{
		perk0 = cac_getPerk( class_index, 0 );
		bbPrint( "mpspecialties: spawnid %d name %s", spawnid, perk0 );
		perk1 = cac_getPerk( class_index, 1 );
		bbPrint( "mpspecialties: spawnid %d name %s", spawnid, perk1 );
		perk2 = cac_getPerk( class_index, 2 );
		bbPrint( "mpspecialties: spawnid %d name %s", spawnid, perk2 );
		perk3 = cac_getPerk( class_index, 3 );
		bbPrint( "mpspecialties: spawnid %d name %s", spawnid, perk3 );
	}
}

_detachAll()
{
	//printLn( "RIOT SHIELD TRACK LOCATION: DETACH ALL CALLED!!!" );
	if ( isDefined( self.hasRiotShield ) && self.hasRiotShield )
	{
		if ( self.hasRiotShieldEquipped )
		{
			//printLn( "RIOT SHIELD TRACK LOCATION: A" );
			self DetachShieldModel( self.riotShieldEquippedNameWorld, "tag_weapon_left" );

			if ( self.hasRiotShieldTwo )
			{
				//printLn( "RIOT SHIELD TRACK LOCATION: Aa" );
				self DetachShieldModel( self.riotShieldBackNameWorld, "tag_shield_back" );
			}
		}
		else
		{
			//printLn( "RIOT SHIELD TRACK LOCATION: B" );
			self DetachShieldModel( self.riotShieldBackNameWorld, "tag_shield_back" );
		}
		
		self initCheckHasRiotShield();
	}
	
	self detachAll();
}

isPerkUpgraded( perkName )
{
	perkUpgrade = tablelookup( "mp/perktable.csv", 1, perkName, 8 );
	
	if ( perkUpgrade == "" || perkUpgrade == "specialty_null" )
		return false;
		
	if ( !self isItemUnlocked( perkUpgrade ) )
		return false;
		
	return true;
}

getPerkUpgrade( perkName )
{
	perkUpgrade = tablelookup( "mp/perktable.csv", 1, perkName, 8 );
	
	if ( perkUpgrade == "" || perkUpgrade == "specialty_null" )
		return "specialty_null";
		
	if ( !self isItemUnlocked( perkUpgrade ) )
		return "specialty_null";
		
	return ( perkUpgrade );
}

loadoutAllPerks( loadoutLethal, loadoutPerk1, loadoutPerk2, loadoutPerk3, loadoutRechargeablePerk )
{

	loadoutPerk1 = maps\mp\perks\_perks::validatePerk( 1, loadoutPerk1 );
	loadoutPerk2 = maps\mp\perks\_perks::validatePerk( 2, loadoutPerk2 );
	loadoutPerk3 = maps\mp\perks\_perks::validatePerk( 3, loadoutPerk3 );

	
	self maps\mp\perks\_perks::givePerk( loadoutPerk1 );
	self maps\mp\perks\_perks::givePerk( loadoutPerk2 );
	self maps\mp\perks\_perks::givePerk( loadoutPerk3 );

	perkUpgrd[0] = tablelookup( "mp/perktable.csv", 1, loadoutPerk1, 8 );
	perkUpgrd[1] = tablelookup( "mp/perktable.csv", 1, loadoutPerk2, 8 );
	perkUpgrd[2] = tablelookup( "mp/perktable.csv", 1, loadoutPerk3, 8 );
	
	foreach( upgrade in perkUpgrd )
	{
		if ( upgrade == "" || upgrade == "specialty_null" )
			continue;
			
		if ( self isItemUnlocked( upgrade ) )
			self maps\mp\perks\_perks::givePerk( upgrade );
	}
	
	loadoutLethal = maps\mp\perks\_perks::validatePerk( 0, loadoutLethal );
	if ( ( loadoutLethal == "semtex_mp" ) || ( loadoutLethal == "frag_grenade_mp" ) || ( loadoutLethal == "throwingknife_mp" ))
	{
		self maps\mp\perks\_perks::givePerk( loadoutLethal );
	}

	//setup recharge if the perk in slot 6 is a rechargeable perk
	self.rechargeablePerk = undefined;
	if( isDefined( level._rechargeablePerks[loadoutRechargeablePerk] ) && loadoutRechargeablePerk == "specialty_xrayvision" )
	{
		self thread maps\mp\perks\_perks::givePerk( loadoutRechargeablePerk );
		self.rechargeablePerk = loadoutRechargeablePerk;
		
		self thread maps\mp\perks\_perks::monitorXrayTest();
	}
	else if( isDefined( level._rechargeablePerks[loadoutRechargeablePerk] ) && loadoutRechargeablePerk == "specialty_grapplinghook" )
	{
		self thread maps\mp\perks\_perks::givePerk( loadoutRechargeablePerk );
		self.rechargeablePerk = loadoutRechargeablePerk;
		
	}
	else if( isDefined( level._rechargeablePerks[loadoutRechargeablePerk] ) && loadoutRechargeablePerk != "specialty_null" )
	{
		self thread maps\mp\perks\_perks::givePerk( loadoutRechargeablePerk );
		self.rechargeablePerk = loadoutRechargeablePerk;
		
		if ( !maps\mp\perks\_perkfunctions::isLevelBlockingRechargeablePerk())
		{ 
			self thread maps\mp\perks\_perks::monitorRechargePerkUsage();
		}
		//self thread maps\mp\perks\_perks::monitorRechargePerkUsageNoRecharge();
	}
	else
	{
		self notify( "clear_recharge_perks" );
	}
}


// returns true if the weapopn you're holding is a riotshield.  this will need to be updated when shields are added or removed.
isARiotShield( name )
{
	switch( name )
	{
		case "riotshield_mp":
			return true;
		case "riotshieldcloak_mp":
			return true;
		case "riotshieldcover_mp":
			return true;
		case "riotshieldxray_mp":
			return true;
	}
	return false;
}


// reset all the riot shield flags as if they had never been set.
initCheckHasRiotShield()
{
	self.hasRiotShield = false;
	self.hasRiotShieldEquipped = false;
	self.hasRiotShieldTwo = false;

	self.riotShieldEquippedName = undefined;
	self.riotShieldEquippedNameWorld = undefined;
	self.riotShieldBackName = undefined;
	self.riotShieldBackNameWorld = undefined;

	self.riotShieldEquippedNameOld = undefined;
	self.riotShieldEquippedNameOldWorld = undefined;
	self.riotShieldBackNameOld = undefined;
	self.riotShieldBackNameOldWorld = undefined;
}


// call this to return wether you have a riot shield, have one equipped, set the name of the one you have and the name of the one you have equipped
checkHasRiotShield()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	// this is true if you have a riot shield, doesn't matter if it's equipped or not
	self.hasRiotShield = ( self hasWeapon( "riotshield_mp" ) || self hasWeapon( "riotshieldcloak_mp" ) || self hasWeapon( "riotshieldcover_mp" ) || self hasWeapon( "riotshieldxray_mp" ) );

	// this is true if you have two riot shields
	numRiotShields = ( self hasWeapon( "riotshield_mp" ) + self hasWeapon( "riotshieldcloak_mp" ) + self hasWeapon( "riotshieldcover_mp" ) + self hasWeapon( "riotshieldxray_mp" ) );
	if ( numRiotShields > 1 )
	{
		self.hasRiotShieldTwo = true;
	}
	else
	{
		self.hasRiotShieldTwo = false;
	}

	// this is true if your current weapon is a riot shield
	self.hasRiotShieldEquipped = ( isARiotShield( self getCurrentWeapon() ) );

	// what you had equipped
	if ( isDefined( self.riotShieldEquippedName ) )
	{
		self.riotShieldEquippedNameOld = self.riotShieldEquippedName;
		self.riotShieldEquippedNameOldWorld = self.riotShieldEquippedNameWorld;
		self.riotShieldEquippedName = undefined;
		self.riotShieldEquippedNameWorld = undefined;
	}
	else
	{
		self.riotShieldEquippedNameOld = undefined;
		self.riotShieldEquippedNameOldWorld = undefined;
	}

	// what you had on your back
	if ( isDefined( self.riotShieldBackName ) )
	{
		self.riotShieldBackNameOld = self.riotShieldBackName;
		self.riotShieldBackNameOldWorld = self.riotShieldBackNameWorld;
		self.riotShieldBackName = undefined;
		self.riotShieldBackNameWorld = undefined;
	}
	else
	{
		self.riotShieldBackNameOld = undefined;
		self.riotShieldBackNameOldWorld = undefined;
	}

	if ( self.hasRiotShield )
	{
		// if your current weapon is a riot shield, set vars that name what it is and what the world model is
		if ( self.hasRiotShieldEquipped )
		{
			self.riotShieldEquippedName = self getCurrentWeapon();
	
			// set the world model name
			switch( self.riotShieldEquippedName )
			{
				case "riotshield_mp":
					self.riotShieldEquippedNameWorld = "weapon_riot_shield_mp";
					break;
				case "riotshieldcloak_mp":
					self.riotShieldEquippedNameWorld = "weapon_riot_shield_cloak";
					break;
				case "riotshieldcover_mp":
					self.riotShieldEquippedNameWorld = "weapon_riot_shield_cover";
					break;
				case "riotshieldxray_mp":
					self.riotShieldEquippedNameWorld = "weapon_riot_shield_xray";
					break;
			}

			// if you have two shields and one of them is equipped
			if ( self hasWeapon( "riotshield_mp" ) && self.riotShieldEquippedName != "riotshield_mp" )
			{
				self.riotShieldBackName = "riotshield_mp";
				self.riotShieldBackNameWorld = "weapon_riot_shield_mp";
			}
			else if ( self hasWeapon( "riotshieldcloak_mp" ) && self.riotShieldEquippedName != "riotshieldcloak_mp" )
			{
				self.riotShieldBackName = "riotshieldcloak_mp";
				self.riotShieldBackNameWorld = "weapon_riot_shield_cloak";
			}
			else if ( self hasWeapon( "riotshieldcover_mp" ) && self.riotShieldEquippedName != "riotshieldcover_mp" )
			{
				self.riotShieldBackName = "riotshieldcover_mp";
				self.riotShieldBackNameWorld = "weapon_riot_shield_cover";
			}
			else if ( self hasWeapon( "riotshieldxray_mp" ) && self.riotShieldEquippedName != "riotshieldxray_mp" )
			{
				self.riotShieldBackName = "riotshieldxray_mp";
				self.riotShieldBackNameWorld = "weapon_riot_shield_xray";
			}
		}
		/*
		// if you have two shields and none of them are equipped
		else if ( self.hasRiotShieldTwo )
		{
			if ( self hasWeapon( "riotshield_mp" ) && self.riotShieldEquippedName != "riotshield_mp" )
			{
				self.riotShieldBackName = "riotshield_mp";
				self.riotShieldBackNameWorld = "weapon_riot_shield_mp";
			}
			else if ( self hasWeapon( "riotshieldcloak_mp" ) && self.riotShieldEquippedName != "riotshieldcloak_mp" )
			{
				self.riotShieldBackName = "riotshieldcloak_mp";
				self.riotShieldBackNameWorld = "weapon_riot_shield_cloak";
			}
			else if ( self hasWeapon( "riotshieldcover_mp" ) && self.riotShieldEquippedName != "riotshieldcover_mp" )
			{
				self.riotShieldBackName = "riotshieldcover_mp";
				self.riotShieldBackNameWorld = "weapon_riot_shield_cover";
			}
			else if ( self hasWeapon( "riotshieldxray_mp" ) && self.riotShieldEquippedName != "riotshieldxray_mp" )
			{
				self.riotShieldBackName = "riotshieldxray_mp";
				self.riotShieldBackNameWorld = "weapon_riot_shield_xray";
			}
		}
		*/
		// you have a shield but it's on your back
		else
		{
			if ( self hasWeapon( "riotshield_mp" ) )
			{
				self.riotShieldBackName = "riotshield_mp";
				self.riotShieldBackNameWorld = "weapon_riot_shield_mp";
			}
			else if ( self hasWeapon( "riotshieldcloak_mp" ) )
			{
				self.riotShieldBackName = "riotshieldcloak_mp";
				self.riotShieldBackNameWorld = "weapon_riot_shield_cloak";
			}
			else if ( self hasWeapon( "riotshieldcover_mp" ) )
			{
				self.riotShieldBackName = "riotshieldcover_mp";
				self.riotShieldBackNameWorld = "weapon_riot_shield_cover";
			}
			else if ( self hasWeapon( "riotshieldxray_mp" ) )
			{
				self.riotShieldBackName = "riotshieldxray_mp";
				self.riotShieldBackNameWorld = "weapon_riot_shield_xray";
			}
		}
	}

	/*
	printLn( "" ); 
	printLn( "riotShieldEquippedName: " ); 
	printLn( self.riotShieldEquippedName ); 
	printLn( "riotShieldEquippedNameWorld: " ); 
	printLn( self.riotShieldEquippedNameWorld ); 
	printLn( "riotShieldBackName: " ); 
	printLn( self.riotShieldBackName ); 
	printLn( "riotShieldBackNameWorld: " ); 
	printLn( self.riotShieldBackNameWorld ); 
	printLn( "riotShieldEquippedNameOld: " ); 
	printLn( self.riotShieldEquippedNameOld ); 
	printLn( "riotShieldEquippedNameOldWorld: " ); 
	printLn( self.riotShieldEquippedNameOldWorld ); 
	printLn( "riotShieldBackNameOld: " ); 
	printLn( self.riotShieldBackNameOld ); 
	printLn( "riotShieldBackNameOldWorld: " ); 
	printLn( self.riotShieldBackNameOldWorld ); 
	printLn( "hasRiotShield: " ); 
	printLn( self.hasRiotShield );
	printLn( "hasRiotShieldTwo: " ); 
	printLn( self.hasRiotShieldTwo );
	printLn( "hasRiotShieldEquipped: " ); 
	printLn( self.hasRiotShieldEquipped );
	printLn( "" ); 
	*/
}


trackRiotShield()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	self initCheckHasRiotShield();
	self checkHasRiotShield();

	// note this function must play nice with _detachAll().
	// SPAWNING LOGIC	
	if ( self.hasRiotShield )
	{
		//PROTOTYPE JKU setup a notify when you have a cover riot shield
		if ( self.currentWeaponAtSpawn == "riotshieldcover_mp" )
		{
			self notify( "riotshieldcover_equipped" );
			self thread riotShieldCover_current();
		}

		// you have 2 riot shields equipped at spawn
		if ( self.hasRiotShieldTwo )
		{
			self AttachShieldModel( self.riotShieldEquippedNameWorld, "tag_weapon_left" );
			self AttachShieldModel( self.riotShieldBackNameWorld, "tag_shield_back" );
		}
		// 1 shield at spawn and you're holding it
		else if ( self.hasRiotShieldEquipped )
		{
			self AttachShieldModel( self.riotShieldEquippedNameWorld, "tag_weapon_left" );
		}
		// 1 shield at spawn and it's on your back
		else
		{
			self AttachShieldModel( self.riotShieldBackNameWorld, "tag_shield_back" );
		}
	}
	
	//PICK UP LOGIC
	for ( ;; )
	{
		previousWeapon = ( self getCurrentWeapon() );
		self waittill ( "weapon_change", newWeapon );
		//printLn( "WEAPON CHANGE CALLED!!!!" );
		//printLn( previousWeapon );
		//printLn( newWeapon );

		// waittill weapon change is a little tricky.  It first sets your weapon as, "none" and then gives the new weapon if switching between.
		if ( newWeapon != "none" )
		{
			self checkHasRiotShield();

			//PROTOTYPE JKU setup a notify when you have a cover riot shield
			if ( newWeapon == "riotshieldcover_mp" )
			{
				self notify( "riotshieldcover_equipped" );
				self thread riotShieldCover_current();
			}

			if ( self.hasRiotShield )
			{
				// if you've got 2 riot shields
				if ( self.hasRiotShieldTwo )
				{
					// if your new shield is the one you had on your back, swap.  this is only when switching, not picking up
					// this will break if the pick up logic changes and lets you pick up 2 of the same weapon
					printLn( "RIOT SHIELD TRACK LOCATION: 2 shield state" );
					if ( isDefined ( self.riotShieldBackNameOld ) && self.riotShieldBackNameOld == newWeapon )
					{
						if ( previousWeapon != "riotshield_mp" && previousWeapon != "riotshieldcloak_mp" && previousWeapon != "riotshieldcover_mp" && previousWeapon != "riotshieldxray_mp" )
						{
							printLn( "RIOT SHIELD TRACK LOCATION: 2 shields, moving one from back because of C4" );
							self MoveShieldModel( self.riotShieldBackNameOldWorld, "tag_shield_back", "tag_weapon_left" );
						}
						else
						{
							printLn( "RIOT SHIELD TRACK LOCATION: 2 shields, moving from back" );
							self MoveShieldModel( self.riotShieldBackNameOldWorld, "tag_shield_back", "tag_weapon_left" );
							self MoveShieldModel( self.riotShieldEquippedNameOldWorld, "tag_weapon_left", "tag_shield_back" );
						}
					}
					// have 2 shields and picking a new one up
					else if ( isDefined( self.riotShieldEquippedNameOld ) && isDefined( self.riotShieldBackNameOld ) )
					{
						// have 2 shields and stowing both because of a KS or c4/claymore
						if ( self hasWeapon( self.riotShieldEquippedNameOld ) && self hasWeapon( self.riotShieldBackNameOld ) )
						{
							printLn( "RIOT SHIELD TRACK LOCATION: 2 shields, stowing both" );
							self MoveShieldModel( self.riotShieldEquippedNameOldWorld, "tag_weapon_left", "tag_shield_back" );
						}
						else
						{
							printLn( "RIOT SHIELD TRACK LOCATION: 2 shields, dropping the one you had and attaching a new one" );
							self DetachShieldModel( self.riotShieldEquippedNameOldWorld, "tag_weapon_left" );
							self AttachShieldModel( self.riotShieldEquippedNameWorld, "tag_weapon_left" );
						}
					}
					// have 2 shields because I had one equipped and no other weapon.  Possible only because of the deployable shield
					else if ( !isDefined( self.riotShieldBackNameOld ) )
					{
						printLn( "RIOT SHIELD TRACK LOCATION: 2 shields, because one is equipped and I have no other weapon" );
						self MoveShieldModel( self.riotShieldEquippedNameOldWorld, "tag_weapon_left", "tag_shield_back" );
						self AttachShieldModel( self.riotShieldEquippedNameWorld, "tag_weapon_left" );
					}
					// have 2 shields because I'm picking a new one up
					else
					{
						printLn( "RIOT SHIELD TRACK LOCATION: 2 shields, because one is stowed and i'm picking one up" );
						self AttachShieldModel( self.riotShieldEquippedNameWorld, "tag_weapon_left" );
					}
				}
				// you have 1 shield and its now equipped
				else if ( self.hasRiotShieldEquipped )
				{
					printLn( "RIOT SHIELD TRACK LOCATION: 1 shield equipped state" );
					// now have a shield equipped and it was on your back
					if ( isDefined( self.riotShieldBackNameOld ) && self.riotShieldBackNameOld == newWeapon )
					{
						//printLn( "RIOT SHIELD TRACK LOCATION: 1 shield, equipping from back" );
						self MoveShieldModel( self.riotShieldBackNameOldWorld, "tag_shield_back", "tag_weapon_left" );
						// deal with the unique case of having 2 shields, one being a cover and chosing to drop the cover which you can't do with any other type of shield.
						if ( isDefined( self.riotShieldEquippedNameOld ) && self.riotShieldEquippedNameOld == "riotshieldcover_mp" && !isDefined ( self.riotShieldBackName ) )
						{
							//printLn( "RIOT SHIELD TRACK LOCATION: 1 shield, special drop case for cover shield" );
							self DetachShieldModel( self.riotShieldEquippedNameOldWorld, "tag_weapon_left" );
						}
					}
					// picked up a shield and are dropping the one you had
					else if ( isDefined( self.riotShieldEquippedNameOld ) )
					{
						printLn( "RIOT SHIELD TRACK LOCATION: 1 shield, attaching new and dropping old" );
						self DetachShieldModel( self.riotShieldEquippedNameOldWorld, "tag_weapon_left" );
						self AttachShieldModel( self.riotShieldEquippedNameWorld, "tag_weapon_left" );
					}
					// otherwise you've picked up a new shield
					else
					{
						printLn( "RIOT SHIELD TRACK LOCATION: 1 shield, attaching as it's new" );
						self AttachShieldModel( self.riotShieldEquippedNameWorld, "tag_weapon_left" );
					}
				}
				// you've picked up a riot shield on your back??? or stowed one.
				else if ( isDefined( self.riotShieldEquippedNameOld ) )
				{
					printLn( "RIOT SHIELD TRACK LOCATION: 1 shield, unequipping moving to back" );
					self MoveShieldModel( self.riotShieldEquippedNameOldWorld, "tag_weapon_left", "tag_shield_back" );
				}
			}
			// you've dropped a riot shield
			else if ( isDefined( self.riotShieldEquippedNameOld ) )
			{
				printLn( "RIOT SHIELD TRACK LOCATION: 1 shield, dropping, now have none." );
				self DetachShieldModel( self.riotShieldEquippedNameOldWorld, "tag_weapon_left" );
				self.riotShieldEquippedNameOld = undefined;
				self.riotShieldEquippedNameOldWorld = undefined;
			}
		}
		else if ( self IsMantling() && newWeapon == "none" )
		{
			// Do nothing, we want to keep that weapon on their arm.
		}

		// if the cover riot shield isn't equipped or stowed, send a notify so any scripts running can stop
		if ( newWeapon != "riotshieldcover_mp" )
		{
			self notify( "riotshieldcover_not_equipped" );
		}
	}
}


// if you have the cover riot shield equipped and in focus, check to see if you want to place it down.
riotShieldCover_current()
{
	//println( "RIOT SHIELD COVER CURRENT CREATED" );

	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	self endon ( "riotshieldcover_stowed" );
	self endon ( "riotshieldcover_not_equipped" );

	self thread riotShieldCover_hudDeploy();

	//debounce
	while ( self useButtonPressed() )
	{
		wait 0.05;
	}

	//wait for x to be held then drop the shield
	for ( ;; )
	{
		//printLn( "riotshieldcover being tracked." );
		buttonTime = 0;
		while ( self useButtonPressed() && self IsOnGround() && IsAlive( self ) )
		{
			buttonTime += 0.05;
			wait ( 0.05 );
			if ( buttonTime >= 0.6 )
				break;
		}
		if ( buttonTime >= 0.6 )
			break;
		wait 0.05;
	}

	// hmm this probably isn't going to work correctly if you've got 2 cover riot shields equipped???
	// get a list of your primaries and switch
	weaponsList = self GetWeaponsListPrimaries();
	for ( i = 0; i < weaponsList.size; i++ )
	{
		if ( weaponsList[i] != "riotshieldcover_mp" )
		{
			self switchToWeapon ( weaponsList[i] );
			break;
		}
	}
	self takeWeapon ( "riotshieldcover_mp" );
	self thread riotShieldCover_deployed();
	self notify ( "riotshieldcover_deployed" );
}


riotShieldCover_deployed()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	self endon ( "riotshieldcover_equipped" );
	self endon ( "riotshieldcover_destroyed" );

	//get a point forward of you and on the ground to place the shield
	shield_infront = ( self getOrigin() + ( anglesToForward( self.angles ) * 36 ) );
	shield_infront = getGroundPosition( shield_infront, 0, 1000, 64, true );
	//get a point further forward for the head icon so it appears infront of the shield
	shield_infront_head = ( self getOrigin() + ( anglesToForward( self.angles ) * 12 ) );
	shield_infront_head = getGroundPosition( shield_infront_head, 0, 1000, 64, true );
	shield = Spawn ( "script_model", shield_infront );
	shield setModel ( "weapon_riot_shield_cover_dep" );
	shield.angles = self.angles;
	shield.trigger = Spawn ( "trigger_radius", shield_infront + ( 0, 0, 1 ), 0, 105, 64 );
	shield.health = 10000;
	shield setCanDamage( true );
	if ( level._teamBased )
	{
		shield maps\mp\_entityheadicons::setTeamHeadIcon( self.team, ( shield_infront_head - self getOrigin() + ( 0, 0, 36 ) ) );
		shield.entityHeadIcon scaleOverTime ( 0.5, 5, 5 );
	}
	else
	{
		//shield maps\mp\_entityheadicons::setPlayerHeadIcon( "none", ( shield_infront_head - self getOrigin() + ( 0, 0, 36 ) ) );
		//shield.entityHeadIcon scaleOverTime ( 0.5, 5, 5 );
	}

	//this is lame but I'm dumb and can't find a better solution.
	//create a second object to use as the collision so I can move and scale that collision independent of the visible object.
	shield_col = Spawn ( "script_model", shield_infront + ( 0, 0, 34 ) );
	//shield_col setModel ( "com_plasticcase_friendly" );
	shield_col cloneBrushmodelToScriptmodel ( level._airDropCrateCollision );
	shield_col.angles = ( self.angles + ( 0, 90, 0 ) );
	shield_col.health = 10000;
	//shield_col hide();
	//bike useAnimTree( level._scr_animtree[ "bike" ] );

	self thread riotShieldCover_checkHealth ( shield, shield_col );
	self thread riotShieldCover_checkPickup ( shield.trigger );
	self thread riotShieldCover_checkOwnerAlive ( shield, shield_col );

	//debounce
	while ( self useButtonPressed() )
	{
		wait 0.05;
	}

	//wait for pickup
	for ( ;; )
	{
		buttonTime = 0;
		while ( self useButtonPressed() && self IsTouching( shield.trigger ) && self IsOnGround() && IsAlive( self ) )
		{
			buttonTime += 0.05;
			wait ( 0.05 );
			if ( buttonTime >= 0.5 )
				break;
		}
		if ( buttonTime >= 0.5 )
			break;
		wait 0.05;
	}

	shield delete();
	shield_col delete();
	// if you have 2 weapons, take the one in your hand and give the shield
	if ( ( self GetWeaponsListPrimaries() ).size > 1 )
	{
		self takeWeapon ( self getCurrentWeapon() );
	}
	self giveWeapon( "riotshieldcover_mp" );
	self switchToWeapon( "riotshieldcover_mp" );
	self notify( "riotshieldcover_equipped" );
}


riotShieldCover_checkOwnerAlive( shield, shield_col )
{
	self endon ( "riotshieldcover_equipped" );
	self endon ( "riotshieldcover_deleted" );

	self waittill_any( "death", "disconnect" );
	//PSA, isAlive only works if the entity has .health
	if ( isAlive ( shield ) )
	{
		shield delete();
	}
	if ( isAlive ( shield_col ) )
	{
		shield_col delete();
	}
}


riotShieldCover_checkHealth( shield, shield_col )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	self endon ( "riotshieldcover_equipped" );

	while ( shield.health > 0 )
	{
		shield waittill( "damage", amount, attacker, dir, point, type );

		// keep in mind that the shield has already taken damage when we get here, below is special case damage.  initial damage is really high so as only what happens below really matters.
		// damage should work as follows...
		// bullets do no damage...
		// owner does no damage...
		// teammates can destroy with 1 melee and do nothing else
		// enemies can melee in 1 and 1 solid explosion

		// not damageable by bullets so give back the damage and get the f out
		if ( type == "MOD_PISTOL_BULLET" || type == "MOD_RIFLE_BULLET" || type == "MOD_EXPLOSIVE_BULLET" )
		{
			//printLn( "bullet, giving health back" );
			shield.health += ( amount );
		}
		// enemies team
		else if ( level._teamBased && attacker.team != self.team )
		{
			//printLn( "team, enemies shooting" );
			if ( isExplosiveDamage( type ) )
			{
				shield.health -= ( amount * 100 );
			}
			else if ( type == "MOD_MELEE" )
			{
				shield.health -= ( amount * 9999 );
			}
		}
		// friendlies team
		else if ( level._teamBased && attacker getEntityNumber() != self getEntityNumber() )
		{
			//printLn( "team, friendlies shooting" );
			if ( type == "MOD_MELEE" )
			{
				shield.health -= ( amount * 9999 );
			}
			else
			{
				shield.health += ( amount );
			}
		}
		// everyone else not team
		else if ( attacker getEntityNumber() != self getEntityNumber() )
		{
			//printLn( "not team, enemies shooting" );
			if ( isExplosiveDamage( type ) )
			{
				shield.health -= ( amount * 100 );
			}
			else if ( type == "MOD_MELEE" )
			{
				shield.health -= ( amount * 9999 );
			}
		}
		// you!!!
		else
		{
			//printLn( "me shooting" );
			shield.health += ( amount );
		}

		//printLn( level._teamBased );
		//printLn( self.team );
		//printLn( amount );
		//printLn( type );
		//printLn( attacker.owner );
		//printLn( shield.health );
	}

	playFx( level._effect[ "riotshieldcover_destroyed_mp" ], shield.origin );
	self notify( "riotshieldcover_destroyed" );
	shield setModel ( "weapon_riot_shield_cover_des" );
	shield_col delete();
	wait 15;
	self notify( "riotshieldcover_deleted" );
	shield delete();
}


riotShieldCover_checkPickup( trigger )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	self endon ( "riotshieldcover_equipped" );
	self endon ( "riotshieldcover_destroyed" );

	self thread riotShieldCover_hudPickup();
	//wait for pickup
	for ( ;; )
	{
		if ( isDefined ( self.hudelem_pickup ) && self IsTouching( trigger ) && !self.hudelem_pickup )
		{
			self thread riotShieldCover_hudPickup();
			while ( self IsTouching( trigger ) )
			wait 0.05;
		}
		else
		{
			self notify( "riotshieldcover_nottouching" );
			while ( !( self IsTouching( trigger ) ) )
			wait 0.05;
		}
		wait 0.05;
	}

}


riotShieldCover_hudDeploy()
{
	// put something on screen that tells you, you can drop this riot shield
	hudelem_deploy = newClientHudElem( self );
	hudelem_deploy.x = -110;
	hudelem_deploy.y = -30;
	hudelem_deploy.alignX = "left";
	hudelem_deploy.alignY = "bottom";
	hudelem_deploy.horzAlign = "center";
	hudelem_deploy.vertAlign = "bottom";
	hudelem_deploy.sort = 1;// force to draw after the background
	hudelem_deploy.foreground = true;
	hudelem_deploy SetText( &"MP_HOLD_USERELOAD_TO_PLACE_RIOTSHIELD" );
	hudelem_deploy.alpha = 0;
	hudelem_deploy FadeOverTime( 0.2 );
	hudelem_deploy.alpha = 1;
	hudelem_deploy.hidewheninmenu = true;
	hudelem_deploy.fontScale = 1.25;
	hudelem_deploy.font = "fwmed";

	self waittill_any( "death", "riotshieldcover_stowed", "riotshieldcover_not_equipped", "riotshieldcover_deployed" );

	hudelem_deploy Destroy();
}


riotShieldCover_hudPickup()
{
	// put something on screen that tells you, you can drop this riot shield
	hudelem_pickup = newClientHudElem( self );
	hudelem_pickup.x = -140;
	hudelem_pickup.y = -30;
	hudelem_pickup.alignX = "left";
	hudelem_pickup.alignY = "bottom";
	hudelem_pickup.horzAlign = "center";
	hudelem_pickup.vertAlign = "bottom";
	hudelem_pickup.sort = 1;// force to draw after the background
	hudelem_pickup.foreground = true;
	hudelem_pickup SetText( &"MP_HOLD_USERELOAD_TO_PICKUP_RIOTSHIELD" );
	hudelem_pickup.alpha = 0;
	hudelem_pickup FadeOverTime( 0.2 );
	hudelem_pickup.alpha = 1;
	hudelem_pickup.hidewheninmenu = true;
	hudelem_pickup.fontScale = 1.25;
	hudelem_pickup.font = "fwmed";
	self.hudelem_pickup = true;

	self waittill_any( "death", "riotshieldcover_nottouching", "riotshieldcover_equipped", "riotshieldcover_destroyed" );
	self.hudelem_pickup = false;
	hudelem_pickup.alpha = 1;
	hudelem_pickup FadeOverTime( 0.2 );
	hudelem_pickup.alpha = 0;
	wait 0.2;

	hudelem_pickup Destroy();
}


tryAttach( placement ) // deprecated; hopefully we won't need to bring this defensive function back
{
	printLn( "TRY ATTACH CALLED, OH NO SHOULD BE DEP" );
	printLn( "TRY ATTACH CALLED, OH NO SHOULD BE DEP" );
	if ( !isDefined( placement ) || placement != "back" )
		tag = "tag_weapon_left";
	else
		tag = "tag_shield_back";
	
	attachSize = self getAttachSize();
	
	for ( i = 0; i < attachSize; i++ )
	{
		attachedTag = self getAttachTagName( i );
		if ( attachedTag == tag &&  self getAttachModelName( i ) == "weapon_riot_shield_mp" )
		{
			return;
		}
	}
	
	self AttachShieldModel( "weapon_riot_shield_mp", tag );
}

tryDetach( placement ) // deprecated; hopefully we won't need to bring this defensive function back
{
	printLn( "TRY DETACH CALLED, OH NO SHOULD BE DEP" );
	printLn( "TRY DETACH CALLED, OH NO SHOULD BE DEP" );
	if ( !isDefined( placement ) || placement != "back" )
		tag = "tag_weapon_left";
	else
		tag = "tag_shield_back";
	
	
	attachSize = self getAttachSize();
	
	for ( i = 0; i < attachSize; i++ )
	{
		attachedModel = self getAttachModelName( i );
		if ( attachedModel == "weapon_riot_shield_mp" )
		{
			self DetachShieldModel( attachedModel, tag); 
			return;
		}
	}
	return;
}



buildWeaponName( baseName, attachment1, attachment2 )
{
	if ( !isDefined( level._letterToNumber ) )
		level._letterToNumber = makeLettersToNumbers();

	// disable bling when perks are disabled
	if ( getDvarInt ( "scr_game_perks" ) == 0 )
	{
		attachment2 = "none";

		if ( baseName == "onemanarmy" )
			return ( "beretta_mp" );
	}

	weaponName = baseName;
	attachments = [];

	if ( attachment1 != "none" && attachment2 != "none" )
	{
		if ( level._letterToNumber[attachment1[0]] < level._letterToNumber[attachment2[0]] )
		{
			
			attachments[0] = attachment1;
			attachments[1] = attachment2;
			
		}
		else if ( level._letterToNumber[attachment1[0]] == level._letterToNumber[attachment2[0]] )
		{
			if ( level._letterToNumber[attachment1[1]] < level._letterToNumber[attachment2[1]] )
			{
				attachments[0] = attachment1;
				attachments[1] = attachment2;
			}
			else
			{
				attachments[0] = attachment2;
				attachments[1] = attachment1;
			}	
		}
		else
		{
			attachments[0] = attachment2;
			attachments[1] = attachment1;
		}		
	}
	else if ( attachment1 != "none" )
	{
		attachments[0] = attachment1;
	}
	else if ( attachment2 != "none" )
	{
		attachments[0] = attachment2;	
	}
	
	foreach ( attachment in attachments )
	{
		weaponName += "_" + attachment;
	}

	if ( !isValidWeapon( weaponName + "_mp" ) )
		return ( baseName + "_mp" );
	else
		return ( weaponName + "_mp" );
}


makeLettersToNumbers()
{
	array = [];
	
	array["a"] = 0;
	array["b"] = 1;
	array["c"] = 2;
	array["d"] = 3;
	array["e"] = 4;
	array["f"] = 5;
	array["g"] = 6;
	array["h"] = 7;
	array["i"] = 8;
	array["j"] = 9;
	array["k"] = 10;
	array["l"] = 11;
	array["m"] = 12;
	array["n"] = 13;
	array["o"] = 14;
	array["p"] = 15;
	array["q"] = 16;
	array["r"] = 17;
	array["s"] = 18;
	array["t"] = 19;
	array["u"] = 20;
	array["v"] = 21;
	array["w"] = 22;
	array["x"] = 23;
	array["y"] = 24;
	array["z"] = 25;
	
	return array;
}

setKillstreaks( streak1, streak2, streak3 )
{
	self.killStreaks = [];

	if ( self _hasPerk( "specialty_hardline" ) )
		modifier = -1;
	else
		modifier = 0;
	
	/*if ( streak1 == "none" && streak2 == "none" && streak3 == "none" )
	{
		streak1 = "uav";
		streak2 = "precision_airstrike";
		streak3 = "helicopter";
	}*/

	killStreaks = [];

	if ( streak1 != "none" )
	{
		//if ( !level.splitScreen )
			streakVal = int( tableLookup( "mp/killstreakTable.csv", 1, streak1, 4 ) );
		//else
		//	streakVal = int( tableLookup( "mp/killstreakTable.csv", 1, streak1, 5 ) );
		killStreaks[streakVal + modifier] = streak1;
	}

	if ( streak2 != "none" )
	{
		//if ( !level.splitScreen )
			streakVal = int( tableLookup( "mp/killstreakTable.csv", 1, streak2, 4 ) );
		//else
		//	streakVal = int( tableLookup( "mp/killstreakTable.csv", 1, streak2, 5 ) );
		killStreaks[streakVal + modifier] = streak2;
	}

	if ( streak3 != "none" )
	{
		//if ( !level.splitScreen )
			streakVal = int( tableLookup( "mp/killstreakTable.csv", 1, streak3, 4 ) );
		//else
		//	streakVal = int( tableLookup( "mp/killstreakTable.csv", 1, streak3, 5 ) );
		killStreaks[streakVal + modifier] = streak3;
	}

	// foreach doesn't loop through numbers arrays in number order; it loops through the elements in the order
	// they were added.  We'll use this to fix it for now.
	maxVal = 0;
	foreach ( streakVal, streakName in killStreaks )
	{
		if ( streakVal > maxVal )
			maxVal = streakVal;
	}

	for ( streakIndex = 0; streakIndex <= maxVal; streakIndex++ )
	{
		if ( !isDefined( killStreaks[streakIndex] ) )
			continue;
			
		streakName = killStreaks[streakIndex];
			
		self.killStreaks[ streakIndex ] = killStreaks[ streakIndex ];
	}
	// end lameness

	// defcon rollover
	maxRollOvers = 10;
	newKillstreaks = self.killstreaks;
	for ( rollOver = 1; rollOver <= maxRollOvers; rollOver++ )
	{
		foreach ( streakVal, streakName in self.killstreaks )
		{
			newKillstreaks[ streakVal + (maxVal*rollOver) ] = streakName + "-rollover" + rollOver;
		}
	}
	
	self.killstreaks = newKillstreaks;
}


replenishLoadout() // used by ammo hardpoint.
{
	team = self.pers["team"];
	class = self.pers["class"];

    weaponsList = self GetWeaponsListAll();
    for( idx = 0; idx < weaponsList.size; idx++ )
    {
		weapon = weaponsList[idx];

		self giveMaxAmmo( weapon );
		self SetWeaponAmmoClip( weapon, 9999 );

		if ( weapon == "claymore_mp" || weapon == "claymore_detonator_mp" )
			self setWeaponAmmoStock( weapon, 2 );
    }
	
	if ( self getAmmoCount( level._classGrenades[class]["primary"]["type"] ) < level._classGrenades[class]["primary"]["count"] )
 		self SetWeaponAmmoClip( level._classGrenades[class]["primary"]["type"], level._classGrenades[class]["primary"]["count"] );

	if ( self getAmmoCount( level._classGrenades[class]["secondary"]["type"] ) < level._classGrenades[class]["secondary"]["count"] )
 		self SetWeaponAmmoClip( level._classGrenades[class]["secondary"]["type"], level._classGrenades[class]["secondary"]["count"] );	
}


onPlayerConnecting()
{
	for(;;)
	{
		level waittill( "connected", player );

		if ( !isDefined( player.pers["class"] ) )
		{
			player.pers["class"] = "";
		}
		player.class = player.pers["class"];
		player.lastClass = "";
		player.detectExplosives = false;
		player.bombSquadIcons = [];
		player.bombSquadIds = [];
	}
}


fadeAway( waitDelay, fadeDelay )
{
	wait waitDelay;
	
	self fadeOverTime( fadeDelay );
	self.alpha = 0;
}


setClass( newClass )
{
	self.curClass = newClass;
}

getPerkForClass( perkSlot, className )
{
    class_num = getClassIndex( className );

    if( isSubstr( className, "custom" ) )
        return cac_getPerk( class_num, perkSlot );
    else
        return table_getPerk( level._classTableName, class_num, perkSlot );
}


classHasPerk( className, perkName )
{
	return( getPerkForClass( 0, className ) == perkName || getPerkForClass( 1, className ) == perkName || getPerkForClass( 2, className ) == perkName );
}

isValidPrimary( refString )
{
	switch ( refString )
	{
		case "riotshield":
		case "riotshieldcloak":
		case "riotshieldcover":
		case "riotshieldxray":
		case "scar":
		case "fal":
		case "p90":
		case "ump45":
		case "barrett":
		case "m21":
		case "cheytac":
		case "rpd":
		case "m240":
		case "aa12":
		case "m1014":
		case "spas12":
		case "laserrifle":
		case "pulserifle":
		case "asmk27":
		case "aresminigun":
		case "lasersniper":
		case "srm1216":
		case "xm108":
		case "type104":
		case "glo":
		case "cd2b":
		case "augks":
		case "xm25ks":
		case "javelinks":
		case "aa12_akimbo":
		case "xraydevice":
		case "grapplinghook_mp":
		case "blockouta":
		case "blockoutb":
		case "blockoutc":
		case "ksg":
		case "ecr":
		case "scar2":

			return true;
		default:
			assertMsg( "Replacing invalid primary weapon: " + refString );
			return false;
	}
}

isValidSecondary( refString, perk2 )
{
	if ( !isDefined (perk2) )
		perk2 = self.perks[0];

	switch ( refString )
	{
		case "beretta":
		case "coltanaconda":
		case "glock":
		case "beretta393":
		case "rpg":
		case "ajax":
		case "stinger":
		case "javelin":
		case "onemanarmy":
		case "xm25":
		case "needler":
		case "m320":
			return true;
		case "riotshield":
		case "riotshieldcloak":
		case "riotshieldcover":
		case "riotshieldxray":
		case "scar":
		case "fal":
		case "p90":
		case "ump45":
		case "barrett":
		case "m21":
		case "cheytac":
		case "rpd":
		case "m240":
		case "aa12":
		case "m1014":
		case "spas12":
		case "laserrifle":
		case "pulserifle":
		case "asmk27":
		case "aresminigun":
		case "lasersniper":
		case "srm1216":
		case "xm108":
		case "type104":
		case "glo":
		case "augks":
		case "xm25ks":
		case "javelinks":
		case "aa12_akimbo":
		case "xraydevice":
		case "blockouta":
		case "blockoutb":
		case "blockoutc":
		case "ksg":
		case "ecr":
		case "scar2":
			if (( perk2 == "specialty_twoprimaries" ) || ( perk2 == "specialty_twoprimarieslethal" ) || (perk2 == "specialty_twoprimariesoffhand" ))
			{
				return true;
			}
			else
			{
				return false;
			}
		default:
			assertMsg( "Replacing invalid secondary weapon: " + refString );
			return false;
	}
}

isValidAttachment( refString )
{
	switch ( refString )
	{
		case "none":
		case "acog":
		case "reflex":
		case "silencer":
		case "grip":
		case "gl":
		case "akimbo":
		case "thermal":
		case "xray":
		case "shotgun":
		case "heartbeat":
		case "fmj":
		case "hrof":
		case "lrof":
		case "xmags":
		case "tactical":
		case "abg":
		case "flash":
		case "frag":
		case "smoke":
		case "stick":
		case "jhp":
		case "match":
		case "shellshock":
		case "boost":
		case "lbarrel":
		case "sbarrel":
		case "astock":
		case "plusone":
			return true;
		default:
			assertMsg( "Replacing invalid equipment weapon: " + refString );
			return false;
	}
}

isValidCamo( refString )
{
	switch ( refString )
	{
		case "none":
		case "woodland":
		case "desert":
		case "arctic":
		case "digital":
		case "red_urban":
		case "red_tiger":
		case "blue_tiger":
		case "orange_fall":
		case "ccamo":
			return true;
		default:
			assertMsg( "Replacing invalid camo: " + refString );
			return false;
	}
}

isValidLethal( refString )
{
	switch ( refString )
	{
		case "pred_grenade_mp":
		case "frag_grenade_mp":
		case "semtex_mp":
		case "throwingknife_mp":
		case "specialty_blastshield":
		case "lidarmine_mp":
		case "sonic_warden_mp":
		case "specialty_portable_radar":
		case "specialty_null":
		case "hulc_rocket_mp":
		case "hulc_lidar_mp":
		case "hulc_frag_mp":
		case "hulc_semtex_mp":
		case "hulc_n00b_mp":
			return true;
		default:
			assertMsg( "Replacing invalid lethal: " + refString );
			return false;
	}
}

isValidEquipment( refString )
{
	switch ( refString )
	{
		case "claymore_mp":
		case "c4_mp":
		case "flare_mp":
		case "specialty_null":
			return true;
		default:
			assertMsg( "Replacing invalid equipment: " + refString );
			return false;
	}
}


isValidOffhand( refString )
{
	switch ( refString )
	{
		case "emp_grenade":
		case "gas_grenade":
		case "lidar_grenade":
		case "flash_grenade":
		case "concussion_grenade":
		case "smoke_grenade":
		case "none":
		case "grapplinghook":
		case "hulc_grenade":
			return true;
		default:
			assertMsg( "Replacing invalid offhand: " + refString );
			return false;
	}
}

//removes any secondary offhand equipment
clearOffhandWeapon()
{
	if( self hasWeapon( "emp_grenade_mp" ))
	{
		self takeWeapon( "emp_grenade_mp" );
	}
	
	if( self hasWeapon( "gas_grenade_mp" ))
	{
		self takeWeapon( "gas_grenade_mp" );
	}
	
	if( self hasWeapon( "lidar_grenade_mp" ))
	{
		self takeWeapon( "lidar_grenade_mp" );
	}
	
	if( self hasWeapon( "flash_grenade_mp" ))
	{
		self takeWeapon( "flash_grenade_mp" );
	}
	
	if( self hasWeapon( "concussion_grenade_mp" ))
	{
		self takeWeapon( "concussion_grenade_mp" );
	}
	
	if( self hasWeapon( "smoke_grenade_mp" ))
	{
		self takeWeapon( "smoke_grenade_mp" );
	}
	
	if( self hasWeapon( "grapplinghook_mp" ))
	{
		self takeWeapon( "grapplinghook_mp" );
	}

	if( self hasWeapon( "hulc_rocket_mp" ))
	{
		self takeWeapon( "hulc_rocket_mp" );
	}

	if( self hasWeapon( "hulc_lidar_mp" ))
	{
		self takeWeapon( "hulc_lidar_mp" );
	}

	if( self hasWeapon( "hulc_frag_mp" ))
	{
		self takeWeapon( "hulc_frag_mp" );
	}

	if( self hasWeapon( "hulc_semtex_mp" ))
	{
		self takeWeapon( "hulc_semtex_mp" );
	}

	if( self hasWeapon( "hulc_n00b_mp" ))
	{
		self takeWeapon( "hulc_n00b_mp" );
	}
}

isValidPerk1( refString )
{
	switch ( refString )
	{
		case "specialty_longersprint":
		case "specialty_fastreload":
		case "specialty_scavenger":
		case "specialty_blindeye":
		case "specialty_paint":
			return true;
		default:
			assertMsg( "Replacing invalid perk1: " + refString );
			return false;
	}
}

isValidPerk2( refString )
{
	switch ( refString )
	{
		case "specialty_hardline":
		case "specialty_coldblooded":
		case "specialty_quickdraw":
		case "specialty_twoprimaries":
		case "specialty_flakjacket":
			return true;
		default:
			assertMsg( "Replacing invalid perk2: " + refString );
			return false;
	}
}


isValidPerk3( refString )
{
	switch ( refString )
	{
		case "specialty_detectexplosive":
		case "specialty_autospot":
		case "specialty_bulletaccuracy":
		case "specialty_quieter":
		case "specialty_fastadsmove":
			return true;
		default:
			assertMsg( "Replacing invalid perk3: " + refString );
			return false;
	}
}


isValidDeathStreak( refString )
{
	switch ( refString )
	{
		case "specialty_copycat":
		case "specialty_combathigh":
		case "specialty_grenadepulldeath":
		case "specialty_finalstand":
		case "specialty_revenge":
		case "specialty_juiced":
		case "specialty_uav":
			return true;
		default:
			assertMsg( "Replacing invalid death streak: " + refString );
			return false;
	}
}

isValidWeapon( refString )
{
	if ( !isDefined( level._weaponRefs ) )
	{
		level._weaponRefs = [];

		foreach ( weaponRef in level._weaponList )
			level._weaponRefs[ weaponRef ] = true;
	}

	if ( isDefined( level._weaponRefs[ refString ] ) )
		return true;

	assertMsg( "Replacing invalid weapon/attachment combo: " + refString );
	
	return false;
}

activateTrophySystem()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "changed_kit" );

	self spawnTrophySystem();
	self thread deleteTrophyAfterDeath();

	if ( (level._teamBased && level._teamEMPed[self.team]) || (!level._teamBased && isDefined( level._empPlayer ) && level._empPlayer != self) )
	{
		level waittill ( "enableTrophy" );
		if ( isDefined ( self.gotEMPGrenaded ) && self.gotEMPGrenaded == true )
		{
			self waittill ( "enableTrophy" );
		}
	}

	self.trophyStatus = "active";
	self thread waitForEMP();

	projectile = undefined;
	for( ;; )
	{
		friendlyTeam = self.team;
		projectile = maps\mp\_mp_trophy_turret::find_closest_projectile( self.origin, projectile, friendlyTeam );

		//println ( "##### Trophy System is active" );

		if ( isdefined( projectile ))
		{
			//println( "got projectile" );
			distance_squared = DistanceSquared( projectile.origin, self.origin );
			if (( distance_squared < ( CONST_TROPHY_LOCK_DISTANCE * CONST_TROPHY_LOCK_DISTANCE )))
			{
				if ( isDefined ( self.trophy_turret ))
				{
					if ( ! ( isDefined ( self.trophy_turret GetTurretTarget ( false ))))
					{
						self.trophy_turret thread aimAndShoot( self, projectile );
						projectile thread monitorExplode ( self, self.trophy_turret );
					}
					if (( distance_squared < ( CONST_TROPHY_MAX_TRACK_DISTANCE * CONST_TROPHY_MAX_TRACK_DISTANCE )))
					{
						weaponName = projectile getWeaponName();
				
						//println ( "Projectile weapon name is: " + weaponName );
						if ( !(maps\mp\_mp_trophy_turret::canGoThroughTrophy( weaponName, "suit" )) 
							&& BulletTracePassed( (self GetTagOrigin (TROPHY_SYSTEM_TAG)), projectile.origin, true, undefined) )
						{
							//println( "explode projectile" );
							PlayFX ( level._effect[ "trophy_explosion" ], projectile.origin );
							self.trophy_turret notify ( "projectile_delete" );
							projectile delete();
							projectile = undefined;
							wait ( TROPHY_COOLDOWN_TIME_SECONDS );
							self PlaySoundToPlayer ( TROPHY_SOUND_AFTER_COOLDOWN, self );
						}
					}
				}
			}
		}

		if ( isDefined ( self.trophyStatus ) && self.trophyStatus == "disable" )
		{
			self waittill ( "enableTrophy" );
			self.trophyStatus = "active";
		}
		waitframe();
	}
}

spawnTrophySystem()
{
	turretPoint = self GetTagOrigin (TROPHY_SYSTEM_TAG);  
	self.trophy_turret = spawnTurret( "misc_turret", turretPoint, TROPHY_SYSTEM_TURRET_INFO );
	self.trophy_turret.angles = self.angles; 
	self.trophy_turret linkTo( self, TROPHY_SYSTEM_TAG, (0,0,0), (0,0,0) );
	self.trophy_turret setModel( TROPHY_SYSTEM_TURRET_MODEL );
	self.trophy_turret.owner = self; 
	self.trophy_turret makeTurretInoperable(); 
	self.trophy_turret SetDefaultDropPitch( 0 );
}

deleteTrophyAfterDeath()
{
	self waittill_any( "death", "disconnect", "changed_kit" );

	if ( isDefined ( self.trophy_turret ))
	{
		self.trophy_turret delete();
	}
}

waitForEMP()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	for ( ;; )
	{
		self waittill ( "disableTrophy" );
		self.trophyStatus = "disable";
		self waittill ( "enableTrophy" );
	}
}

aimAndShoot( owner, target )
{
	self endon ( "clear_target" );
	owner endon ( "death" );
	owner endon ( "disconnect" );
	owner endon ( "changed_kit" );

	self SetTargetEntity( target );
	self waittill ( "projectile_delete" );
	playFxOnTag( level._effect[ "trophy_firing" ], self, TROPHY_SYSTEM_FX_TAG );
	wait ( TROPHY_WAIT_TIME_AFTER_FIRING );
	self ClearTargetEntity();
}

monitorExplode ( trophy_owner, trophySystem )
{
	trophy_owner endon ( "death" );
	trophy_owner endon ( "disconnect" );
	trophy_owner endon ( "changed_kit" );

	self waittill ( "explode" );
	trophySystem notify ( "clear_target" );
	trophySystem ClearTargetEntity();
}