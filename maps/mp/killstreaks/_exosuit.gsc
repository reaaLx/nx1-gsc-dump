#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;


EXOSUIT_CHANGE_TIME_SECONDS = 3.0;
EXOSUIT_TABLE_FILE = "mp/exosuitTable.csv";

//*******************************************************************
//																	*
//																	*
//*******************************************************************
init()
{
	precacheString( &"MPUI_CHANGING_SUIT" );
	PrecacheItem( "aresminigun_mp" );

	level._killStreakFuncs[ "exosuit" ] = ::tryUseExosuit;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
tryUseExosuit( lifeId )
{
	self thread chooseExosuit();

	self waittill ( "suit_chosen" );

	// suit perk will be set if the function above is successful
	if ( self _hasPerk( "specialty_stealthsuit" ) || self _hasPerk( "specialty_agisuit" ) || 
		self _hasPerk( "specialty_tacsuit" ) || self _hasPerk( "specialty_juggersuit" ) ||
		self _hasPerk( "specialty_jetsuit" ))
	{
		return true;
	}
	else
	{
		return false;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
chooseExosuit()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );

	suitName = "specialty_juggersuit";

	if ( self isUsingRemote() )  
	{
		if ( self getCurrentWeapon() == "killstreak_uav_mp" )
		{
			self _disableWeaponSwitch();
			self _disableOffhandWeapons();
			self _disableUsability();
			self switchToWeapon( self getLastWeapon() );
			self waittill ( "weapon_change" );
			self _enableWeaponSwitch();
			self _enableOffhandWeapons();
			self _enableUsability();
		}

		self notify ( "suit_chosen" );

		return;
	}
	else
	{
		assert( suitName == "specialty_stealthsuit" || suitName == "specialty_agisuit" || 
				suitName == "specialty_tacsuit" || suitName == "specialty_juggersuit" ||
				suitName == "specialty_jetsuit" );
		self thread tryWearSuit( suitName );
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
closeExosuitMenuOnDeath()
{
	self endon ( "menuresponse" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );

	self waittill ( "death" );

	self closePopupMenu();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
tryWearSuit( suitName )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );

	// tagTMR<TODO>: Add playLocalSound and playTeamSound here

	if ( self _hasPerk( "specialty_twoprimaries" ))
	{
		self thread maps\mp\gametypes\_class::cleanHULChud();
		self notify ( "disable_HULC" );
	}

	self _disableWeapon();
	self _disableOffhandWeapons();
	self _disableUsability();


	// Don't want overpowered combinations so no perks will coexist with suits for now
	self _clearPerks();
	maps\mp\perks\_perks::givePerk( suitName );

	self _enableWeapon();
	self _enableOffhandWeapons();
	self _enableUsability();

	// tagSS<NOTE>: No attempt is made to save the previous model. This would be needed if the suit was able to be removed
	// before dying, in order to restore the proper randomized character. Note that this also sets the model.
	self detachAll();
	self giveSuitWeapons( suitName );

	// tagTMR<NOTE>: The detatchAll() above will remove the flag carried, reattached if the player's spoda have one
	if ( isDefined( self.carryFlag ))
	{
		self attach( self.carryFlag, "J_spine4", true );
	}

	waitframe();
	self notify ( "suit_chosen" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
exosuitUseBar()
{
	self endon ( "disconnect" );

	useBar = createPrimaryProgressBar( 25 );
	useBarText = createPrimaryProgressBarText( 25 );
	useBarText setText( &"MPUI_CHANGING_SUIT" );

	useBar updateBar( 0, 1 / EXOSUIT_CHANGE_TIME_SECONDS );
	for ( waitedTime = 0; waitedTime < EXOSUIT_CHANGE_TIME_SECONDS && isAlive( self ) && !level._gameEnded; waitedTime += 0.05 )
	{
		wait ( 0.05 );
	}
	
	useBar destroyElem();
	useBarText destroyElem();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
giveSuitWeapons( suitName )
{
	primaryWeapon = tablelookup( EXOSUIT_TABLE_FILE, 1, suitName, 2 );
	primaryAttachment = tablelookup( EXOSUIT_TABLE_FILE, 1, suitName, 3 );
	primaryAttachment2 = tablelookup( EXOSUIT_TABLE_FILE, 1, suitName, 4 );
	secondaryWeapon = tablelookup( EXOSUIT_TABLE_FILE, 1, suitName, 5 );
	secondaryAttachment = tablelookup( EXOSUIT_TABLE_FILE, 1, suitName, 6 );
	secondaryAttachment2 = tablelookup( EXOSUIT_TABLE_FILE, 1, suitName, 7 );
	equipment = tablelookup( EXOSUIT_TABLE_FILE, 1, suitName, 8 );
	loadoutOffhand = tablelookup( EXOSUIT_TABLE_FILE, 1, suitName, 9 );

	// tagTMR<NOTE>: if there is no primary weapon, this suit will not have a weapon loadout to sub
	if (primaryWeapon != "none")
	{
		self takeAllWeapons();

		self.loadoutPrimary = primaryWeapon;
		self.loadoutSecondary = secondaryWeapon;

		primaryName = maps\mp\gametypes\_class::buildWeaponName( primaryWeapon, primaryAttachment, primaryAttachment2 );
		self _giveWeapon( primaryName, self.loadoutPrimaryCamo );
		self SwitchToWeapon ( primaryWeapon + "_mp" );

		secondaryName = maps\mp\gametypes\_class::buildWeaponName( secondaryWeapon, secondaryAttachment, secondaryAttachment2 );
		self _giveWeapon( secondaryName, self.loadoutSecondaryCamo );

		self SetOffhandPrimaryClass( "other" );

		equipment = maps\mp\perks\_perks::validatePerk( 1, equipment );
		self maps\mp\perks\_perks::givePerk( equipment );

		// Secondary Offhand
		offhandSecondaryWeapon = loadoutOffhand + "_mp";
		if ( loadoutOffhand == "flash_grenade" )
			self SetOffhandSecondaryClass( "flash" );
		else
			self SetOffhandSecondaryClass( "smoke" );
		
		self giveWeapon( offhandSecondaryWeapon );
		if( loadOutOffhand == "smoke_grenade" )
			self setWeaponAmmoClip( offhandSecondaryWeapon, 1 );
		else if( loadOutOffhand == "flash_grenade" )
			self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
		else if( loadOutOffhand == "concussion_grenade" )
			self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
		else
			self setWeaponAmmoClip( offhandSecondaryWeapon, 1 );

		self.primaryWeapon = primaryName;
		self.secondaryWeapon = secondaryName;

		primaryTokens = strtok( primaryName, "_" );
		self.pers["primaryWeapon"] = primaryTokens[0];

		self.isSniper = (weaponClass( self.primaryWeapon ) == "sniper");
	}

	self maps\mp\gametypes\_teams::playerModelForWeapon( self.pers["primaryWeapon"], getBaseWeaponName( self.secondaryWeapon ) );
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );
}