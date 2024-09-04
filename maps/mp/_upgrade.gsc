//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  The Combat Awareness Upgrade System                          **
//             (1) Players are displayed with Earned Strike Points (ESP)    ** 
//                 while alive.                                             **
//             (2) The ESP will increment when a new killstreak is earned.  **
//             (3) If enough ESP is earned, players will be presented with  **
//                 options that they can spend the earned ESP.              **
//             (4) If spending occurs, the ESP counters as well as players' **
//                 killstreak queue will be adjusted accordingly.           ** 
//                                                                          **
//    This script is organized into four major components:                  **
//                                                                          ** 
//    Components                                                            **
//    -------------------------------------------------------------------   **
//    initialization functions                                              **    
//    major logic functions                                                 **
//    HUD element functions                                                 **
//    helper functions                                                      **
//                                                                          **
//    Created: September 21st, 2011 - James Chen                            **
//                                                                          **
//***************************************************************************/

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

//*******************************************************************
//              Beginning of initialization functions               *
//                                                                  *
//*******************************************************************
KILLSTREAK_STRING_TABLE = "mp/killstreakTable.csv";

//tagJC<NOTE>: The beginning branching function.  Use the dvar "upgradeEnabling" to decide whether the upgrade is enabled for the level
init()
{
	if ( getDvarInt( "upgradeEnabling" ) == 1 )
	{
		println( "Upgrade: Enabled" );
		initUpgrade();
		level thread onPlayerConnect();
	}
	else
	{
		println ( "Upgrade: Disabled" ); 
		level thread onPlayerConnectNoUpGrade();
	}
}

//tagJC<NOTE>: Initialize the award types and precache all the necessary assets
initUpgrade()
{
	level._upgrade = undefined;

	//tagJC<NOTE>: Initialize the award types
	//addUpgradeType ( "threatID", 15, ::activateThreatID, false );
	addUpgradeType ( "attackHelicopter", 9, ::giveAttackHelicopter, false );
	addUpgradeType ( "lightWeight", 12, ::activateExtraLightWeight, true );
	addUpgradeType ( "chopperGunner", 15, ::giveChopperGunner, false );

	precacheString ( &"MP_A_BUTTON" );
	precacheString ( &"MP_B_BUTTON" );
	precacheString ( &"MP_Y_BUTTON" );
	precacheString ( &"MP_ESP" );
	for ( i = 1; true; i++ )
	{
		retVal = tableLookup( KILLSTREAK_STRING_TABLE, 0, i, 1 );
		if ( !isDefined( retVal ) || retVal == "" )
			break;

		streakRef = tableLookupIString( KILLSTREAK_STRING_TABLE, 0, i, 2 );
		assert( streakRef != &"" );
		precacheString( streakRef );
	}
}

//tagJC<NOTE>: Build and add the upgrade types
addUpgradeType( name, requiredPoints, activationFunc, reactivateWhenSpawn )
{
	level._upgradeDefs[name]["requiredPoints"] = requiredPoints;
	level._upgradeDefs[name]["activationFunc"] = activationFunc;
	level._upgradeDefs[name]["reactivateWhenSpawn"] = reactivateWhenSpawn;
}

//tagJC<NOTE>: The call-back function for the threadID
//tagJC<NOTE>: Self is the player
activateThreatID()
{	
	self ThermalVisionFOFOverlayOn();
}

//tagJC<NOTE>: The call-back function for the extra light weight
//tagJC<NOTE>: Self is the player
activateExtraLightWeight()
{
	self.moveSpeedScaler = 1.30;	
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );
}

//tagJC<NOTE>: The call-back function for giving the attacker helicopter.  Since the killstreak is given on the button press during killcam, no action is necessary when player spawns
giveAttackHelicopter()
{
}

//tagJC<NOTE>: The call-back function for giving the chopper gunner.  Since the killstreak is given on the button press during killcam, no action is necessary when player spawns
giveChopperGunner()
{
}

//tagJC<NOTE>: Initialize all the data necessary on player connect
onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );

		player.earnedStrikePoints = 0;	
		player createESPCounter();
		player.acquiredUpgrades = [];
		player thread onPlayerSpawned();
		player.upgradeList["switchWeap"] = "chopperGunner";
		player.killstreakToRemove["switchWeap"] = [];
		player.upgradeList["prone"] = "lightWeight";
		player.killstreakToRemove["prone"] = [];
		player.upgradeList["jump"] = "attackHelicopter";
		player.killstreakToRemove["jump"] = [];
	}
}

//tagJC<NOTE>: In order to wait for the button presses for Y and B during killcam, the following two member data is necessary.
onPlayerConnectNoUpGrade()
{
	for(;;)
	{
		level waittill( "connected", player );
		player.YbuttonPressedDuringKillCam = false;
		player.BbuttonPressedDuringKillCam = false;
	}
}

//tagJC<NOTE>: The call-back function for when player spawns
//tagJC<NOTE>: Self is the player
onPlayerSpawned()
{
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "spawned_player" );
		self thread waitForChangeTeam();

		self.YbuttonPressedDuringKillCam = false;
		self.BbuttonPressedDuringKillCam = false;

		if ( isDefined ( self.ESPCounter_a ))
		{
			self.ESPCounter_a.alpha = 1;
		}
	
		if ( isDefined ( self.ESPCounter_b ))
		{
			self.ESPCounter_b.alpha = 1;
		}

		//tagJC<NOTE>: If there is anything in the player's acquired upgrade list, reactivate the effects
		for ( i = 0; i < self.acquiredUpgrades.size; i++ )  
		{
			upgradeName = self.acquiredUpgrades[i];
			if (( isDefined (level._upgradeDefs[upgradeName]["reactivateWhenSpawn"])) && (level._upgradeDefs[upgradeName]["reactivateWhenSpawn"] == true ))
			{
				self [[level._upgradeDefs[upgradename]["activationFunc"]]]();
			}
		} 
	}
}

//tagJC<NOTE>: Thread running on players for team changes
//tagJC<NOTE>: Self is the player
waitForChangeTeam()
{
	self endon ( "disconnect" );
	
	self notify ( "waitForChangeTeam" );
	self endon ( "waitForChangeTeam" );
	
	for ( ;; )
	{
		self waittill ( "joined_team" );
		self.earnedStrikePoints = 0;
	}
}

//*******************************************************************
//                  End of initialization functions                 *
//                 Beginning of main logic functions                *
//*******************************************************************
//tagJC<NOTE>: Based on the point values passed in, this function remove earned killstreak from player's killstreak until enough points are cumulated.
//tagJC<NOTE>: Self is the player	
removeKillstreakToGetUpgrade ( earnedStrikePointLimit )
{
	earnedStrikePoints = 0;
	removeCounter = 0;
	size = self.pers["killstreaks"].size;
	foreach ( index, streakStruct in self.pers["killstreaks"] )
	{
		earnedStrikePoints += streakStruct.strikePoints;
		self.pers["killstreaks"][index] = undefined;
		removeCounter += 1;
		if ( earnedStrikePoints >= earnedStrikePointLimit )
		{
			break;
		}
	}
	streakRemain = size - removeCounter;
	for ( i = 0; i < size ; i++ )
	{
		if ( i <= ( streakRemain - 1 ))
		{
			self.pers["killstreaks"][i] = self.pers["killstreaks"][i + removeCounter];
		} 
		else
		{
			self.pers["killstreaks"][i] = undefined;
		}
	}
	self.earnedStrikePoints = 0;
	for ( i = 0; i < self.pers["killstreaks"].size; i++ )
	{
		self.earnedStrikePoints += self.pers["killstreaks"][i].strikePoints;
	}
	self updateESPNumber();
}	

//tagJC<NOTE>: This function is called during player's killcam and process the upgrade selection accordingly.  Currently, given 
//             the players killstreak is hard-coded.  In the future, if such selection is desirable, a more generic approach
//             will be implemented by then.
//tagJC<NOTE>: Self is the player
processUpgradeSelections()
{
	if (( self.killCamButtonPressed == "jump") && ( self.earnedStrikePoints >= level._upgradeDefs[self.upgradeList["jump"]]["requiredPoints"] ) && !(maps\mp\_upgrade::hasUpgrade(self, self.upgradeList["jump"] )))
	{
		self.acquiredUpgrades[self.acquiredUpgrades.size] = self.upgradeList["jump"];
		self removeKillstreakToGetUpgrade( level._upgradeDefs[self.upgradeList["jump"]]["requiredPoints"]);
		self thread maps\mp\killstreaks\_killstreaks::giveKillstreak( "helicopter", false, false, self, true );
	}
	else if (( self.killCamButtonPressed == "prone") && ( self.earnedStrikePoints >= level._upgradeDefs[self.upgradeList["prone"]]["requiredPoints"] ) && !(maps\mp\_upgrade::hasUpgrade(self, self.upgradeList["prone"] )))
	{
		self.acquiredUpgrades[self.acquiredUpgrades.size] = self.upgradeList["prone"];
		self removeKillstreakToGetUpgrade( level._upgradeDefs[self.upgradeList["prone"]]["requiredPoints"]);
	}
	else if (( self.killCamButtonPressed == "switchWeap") && ( self.earnedStrikePoints >= level._upgradeDefs[self.upgradeList["switchWeap"]]["requiredPoints"] ) && !(maps\mp\_upgrade::hasUpgrade(self, self.upgradeList["switchWeap"] )))
	{
		self.acquiredUpgrades[self.acquiredUpgrades.size] = self.upgradeList["switchWeap"];
		self removeKillstreakToGetUpgrade( level._upgradeDefs[self.upgradeList["switchWeap"]]["requiredPoints"]);
		self thread maps\mp\killstreaks\_killstreaks::giveKillstreak( "helicopter_minigun", false, false, self, true );
	}
}

//*******************************************************************
//                    End of main logic functions                   *
//                Beginning of HUD element functions                *
//*******************************************************************
//tagJC<NOTE>: Creating the A, B, and Y buttons that will be shown during the killcam
//tagJC<NOTE>: Self is the player	
initUpgradeElements()
{
	if ( !isDefined( self.kc_A_button ) )
	{
		self.kc_A_button = newClientHudElem(self);
		self.kc_A_button.label = &"MP_A_BUTTON";
		self.kc_A_button.archived = false;
		self.kc_A_button.x = 0;
		self.kc_A_button.alignX = "left";
		self.kc_A_button.alignY = "middle";
		self.kc_A_button.horzAlign = "left";
		self.kc_A_button.vertAlign = "middle";
		self.kc_A_button.sort = 1; // force to draw after the bars
		self.kc_A_button.font = "default";
		self.kc_A_button.foreground = true;
		self.kc_A_button.hideWhenInMenu = true;
		self.kc_A_button.alpha = 0;
		self.kc_A_button.color = ( 0, 1, 0 );
		
		if ( level._splitscreen )
		{
			self.kc_A_button.y = 20;
			self.kc_A_button.fontscale = 1.2; // 1.8/1.5
		}
		else
		{
			self.kc_A_button.y = 32;
			self.kc_A_button.fontscale = 1.8;
		}
	}

	if ( !isDefined( self.kc_B_button ) )
	{
		self.kc_B_button = newClientHudElem(self);
		self.kc_B_button.label = &"MP_B_BUTTON";
		self.kc_B_button.archived = false;
		self.kc_B_button.x = 160;
		self.kc_B_button.alignX = "left";
		self.kc_B_button.alignY = "top";
		self.kc_B_button.horzAlign = "left";
		self.kc_B_button.vertAlign = "top";
		self.kc_B_button.sort = 1; // force to draw after the bars
		self.kc_B_button.font = "default";
		self.kc_B_button.foreground = true;
		self.kc_B_button.hideWhenInMenu = true;
		self.kc_B_button.alpha = 0;
		self.kc_B_button.color = ( 0, 1, 0 );
		
		if ( level._splitscreen )
		{
			self.kc_B_button.y = 20;
			self.kc_B_button.fontscale = 1.2; // 1.8/1.5
		}
		else
		{
			self.kc_B_button.y = 128;
			self.kc_B_button.fontscale = 1.8;
		}
	}

	if ( !isDefined( self.kc_Y_button ) )
	{
		self.kc_Y_button = newClientHudElem(self);
		self.kc_Y_button.label = &"MP_Y_BUTTON";
		self.kc_Y_button.archived = false;
		self.kc_Y_button.x = 0;
		self.kc_Y_button.alignX = "left";
		self.kc_Y_button.alignY = "top";
		self.kc_Y_button.horzAlign = "left";
		self.kc_Y_button.vertAlign = "top";
		self.kc_Y_button.sort = 1; // force to draw after the bars
		self.kc_Y_button.font = "default";
		self.kc_Y_button.foreground = true;
		self.kc_Y_button.hideWhenInMenu = true;
		self.kc_Y_button.alpha = 0;
		self.kc_Y_button.color = ( 0, 1, 0 );
		
		if ( level._splitscreen )
		{
			self.kc_Y_button.y = 20;
			self.kc_Y_button.fontscale = 1.2; // 1.8/1.5
		}
		else
		{
			self.kc_Y_button.y = 0;
			self.kc_Y_button.fontscale = 1.8;
		}
	}
}

//tagJC<NOTE>: This function displays the killstreak icons and names that the player is about to lose when making the upgrade
//tagJC<NOTE>: Self is the player
showRemovedKillstreaks ( pointRequirement, buttonAssignment )
{
	earnedStrikePoints = 0;
	removeCounter = 0;
	foreach ( index, streakStruct in self.pers["killstreaks"] )
	{
		earnedStrikePoints += streakStruct.strikePoints;
		removeCounter += 1;
		if ( earnedStrikePoints >= pointRequirement )
		{
			break;
		}
	}
	if ( !(isDefined ( self.killstreakToRemove[buttonAssignment] )))
	{
		self.killstreakToRemove[buttonAssignment] = [];
	}
	for ( i = 0; i < removeCounter; i++)
	{
		self.killstreakToRemove[buttonAssignment][i] = showKillstreakIcon ( self.pers["killstreaks"][i].streakName, buttonAssignment, i * 0, i * 25 );
		self.killstreakToRemove[buttonAssignment][i+removeCounter] = showKillstreakName ( self.pers["killstreaks"][i].streakName, buttonAssignment, i * 0, i * 25 );
	}
}

//tagJC<NOTE>: This function returns a HUD element for the killstreak icons
//tagJC<NOTE>: Self is the player
showKillstreakIcon ( streakName, buttonAssignment, xOffset, yOffset )
{
	iconName = getKillstreakIcon (streakName );
	real_yOffset = 32;
	if ( buttonAssignment == "prone" )
	{
		real_yOffset = 128;
	}
	else if ( buttonAssignment == "switchWeap" )
	{
		real_yOffset = 0;
	}
	real_yOffset += 30;
	real_yOffset += yOffset;
	
	xValue = 0;
	if ( buttonAssignment == "prone" )
	{
		xValue = 160;
	}
	xValue += xOffset;

	alignYValue = "top";
	if ( buttonAssignment == "jump" )
	{
		alignYValue = "middle";
	}

	vertAlignValue = "top";
	if ( buttonAssignment == "jump" )
	{
		vertAlignValue = "middle";
	}

	killstreakIcon = newClientHudElem(self);
	killstreakIcon setShader ( iconName );
	killstreakIcon.archived = false;
	killstreakIcon.x = xValue;
	killstreakIcon.alignX = "left";
	killstreakIcon.alignY = alignYValue;
	killstreakIcon.horzAlign = "left";
	killstreakIcon.vertAlign = vertAlignValue;
	killstreakIcon.sort = 1; // force to draw after the bars
	killstreakIcon.font = "default";
	killstreakIcon.foreground = true;
	killstreakIcon.hideWhenInMenu = true;
	killstreakIcon.alpha = 1;
	//killstreakIcon.color = ( 0, 1, 0 );
	
	if ( level._splitscreen )
	{
		killstreakIcon.y = real_yOffset + 20;
		killstreakIcon.fontscale = 1.2; // 1.8/1.5
	}
	else
	{
		killstreakIcon.y = real_yOffset;
		killstreakIcon.fontscale = 1.8;
	}
	return killstreakIcon;
}

//tagJC<NOTE>: This function returns a HUD element for the killstreak names
//tagJC<NOTE>: Self is the player
showKillstreakName ( streakName, buttonAssignment, xOffset, yOffset )
{
	iconName = getKillstreakIcon (streakName );
	real_yOffset = 32;
	if ( buttonAssignment == "prone" )
	{
		real_yOffset = 128;
	}
	else if ( buttonAssignment == "switchWeap" )
	{
		real_yOffset = 0;
	}
	real_yOffset += 30;
	real_yOffset += yOffset;
	
	xValue = 0;
	if ( buttonAssignment == "prone" )
	{
		xValue = 160;
	}
	xValue += xOffset;

	alignYValue = "top";
	if ( buttonAssignment == "jump" )
	{
		alignYValue = "middle";
	}

	vertAlignValue = "top";
	if ( buttonAssignment == "jump" )
	{
		vertAlignValue = "middle";
	}	

	killstreakIcon = CreateFontString( "objective", 1.25 );;
	killstreakIcon SetText( getKillstreakUserFriendlyName ( streakName ));
	killstreakIcon.archived = false;
	killstreakIcon.x = xValue + 20;
	killstreakIcon.alignX = "left";
	killstreakIcon.alignY = alignYValue;
	killstreakIcon.horzAlign = "left";
	killstreakIcon.vertAlign = vertAlignValue;
	killstreakIcon.sort = 1; // force to draw after the bars
	killstreakIcon.font = "default";
	killstreakIcon.foreground = true;
	killstreakIcon.hideWhenInMenu = true;
	killstreakIcon.alpha = 1;
	//killstreakIcon.color = ( 0, 1, 0 );
	
	if ( level._splitscreen )
	{
		killstreakIcon.y = real_yOffset + 20;
		killstreakIcon.fontscale = 1.5; // 1.8/1.5
	}
	else
	{
		killstreakIcon.y = real_yOffset;
		killstreakIcon.fontscale = 1.5;
	}
	return killstreakIcon;
}

//tagJC<NOTE>: The ESP counter is displayed while the player is alive
//tagJC<NOTE>: Self is the player
createESPCounter()
{
	if ( !isDefined( self.ESPCounter_a ) )
	{
		self.ESPCounter_a = newClientHudElem(self);
		self.ESPCounter_a.label = &"MP_ESP";
		self.ESPCounter_a.archived = false;
		self.ESPCounter_a.x = 0;
		self.ESPCounter_a.alignX = "left";
		self.ESPCounter_a.alignY = "top";
		self.ESPCounter_a.horzAlign = "left";
		self.ESPCounter_a.vertAlign = "top";
		self.ESPCounter_a.sort = 1; // force to draw after the bars
		self.ESPCounter_a.font = "default";
		self.ESPCounter_a.foreground = true;
		self.ESPCounter_a.hideWhenInMenu = true;
		self.ESPCounter_a.alpha = 1;
		self.ESPCounter_a.color = ( 0, 1, 0 );
		
		if ( level._splitscreen )
		{
			self.ESPCounter_a.y = 20;
			self.ESPCounter_a.fontscale = 1.2; // 1.8/1.5
		}
		else
		{
			self.ESPCounter_a.y = 100;
			self.ESPCounter_a.fontscale = 1.8;
		}
	}

	if ( !isDefined( self.ESPCounter_b ) )
	{
		self.ESPCounter_b = CreateFontString( "objective", 1.25 );;
		self.ESPCounter_b SetText( "" + self.earnedStrikePoints );
		self.ESPCounter_b.archived = false;
		self.ESPCounter_b.x = 40;
		self.ESPCounter_b.alignX = "left";
		self.ESPCounter_b.alignY = "top";
		self.ESPCounter_b.horzAlign = "left";
		self.ESPCounter_b.vertAlign = "top";
		self.ESPCounter_b.sort = 1; // force to draw after the bars
		self.ESPCounter_b.font = "default";
		self.ESPCounter_b.foreground = true;
		self.ESPCounter_b.hideWhenInMenu = true;
		self.ESPCounter_b.alpha = 1;
		self.ESPCounter_b.color = ( 0, 1, 0 );
		
		if ( level._splitscreen )
		{
			self.ESPCounter_b.y = 20;
			self.ESPCounter_b.fontscale = 1.2; // 1.8/1.5
		}
		else
		{
			self.ESPCounter_b.y = 100;
			self.ESPCounter_b.fontscale = 1.8;
		}
	}
}

//tagJC<NOTE>: This function is called at the beginning of the killcam, it will display all the HUD elements depending on the 
//             ESP earning situation.
//tagJC<NOTE>: Self is the player
showUpgradeHUDElement()
{
	if ( isDefined ( self.ESPCounter_a ))
	{
		self.ESPCounter_a.alpha = 0;
	}

	if ( isDefined ( self.ESPCounter_b ))
	{
		self.ESPCounter_b.alpha = 0;
	}

	if (( self.earnedStrikePoints >= level._upgradeDefs[self.upgradeList["jump"]]["requiredPoints"] ) 
		&& !( hasUpgrade(self, self.upgradeList["jump"] )))
	{
		if ( isDefined( self.kc_A_button ))
		{
			self.kc_A_button.alpha = 1;
		}
		self showRemovedKillstreaks ( level._upgradeDefs[self.upgradeList["jump"]]["requiredPoints"], "jump" );
	}

	if (( self.earnedStrikePoints >= level._upgradeDefs[self.upgradeList["prone"]]["requiredPoints"] ) 
		&& !( hasUpgrade(self, self.upgradeList["prone"] )))
	{
		if ( isDefined( self.kc_B_button ))
		{
			self.kc_B_button.alpha = 1;
		}
		self showRemovedKillstreaks ( level._upgradeDefs[self.upgradeList["prone"]]["requiredPoints"], "prone" );
	}

	if (( self.earnedStrikePoints >= level._upgradeDefs[self.upgradeList["switchWeap"]]["requiredPoints"] ) 
		&& !( hasUpgrade(self, self.upgradeList["switchWeap"] )))
	{
		if ( isDefined( self.kc_Y_button ))
		{
			self.kc_Y_button.alpha = 1;
		}
		self showRemovedKillstreaks ( level._upgradeDefs[self.upgradeList["switchWeap"]]["requiredPoints"], "switchWeap" );
	}
}

//tagJC<NOTE>: Updating the numerical value for the ESP counter.
//tagJC<NOTE>: Self is the player
updateESPNumber()
{
	if ( isDefined( self.ESPCounter_b ) )
	{
		self.ESPCounter_b SetText( "" + self.earnedStrikePoints );
	}
}

//tagJC<NOTE>: Clean up all the upgrade related HUD elements once the killcam is complete.
//tagJC<NOTE>: Self is the player
upgradeHUDCleanUp()
{
	if ( isDefined( self.kc_A_button ))
		self.kc_A_button.alpha = 0;
	if ( isDefined( self.kc_B_button ))
		self.kc_B_button.alpha = 0;
	if ( isDefined( self.kc_Y_button ))
		self.kc_Y_button.alpha = 0;
	if ( isDefined( self.killstreakToRemove["jump"] ))
	{
		for ( i = 0; i < self.killstreakToRemove["jump"].size ; i++)
		{
			self.killstreakToRemove["jump"][i] Destroy();
		}
		self.killstreakToRemove["jump"] = undefined;
	}
	if ( isDefined( self.killstreakToRemove["prone"] ))
	{
		for ( i = 0; i < self.killstreakToRemove["prone"].size ; i++)
		{
			self.killstreakToRemove["prone"][i] Destroy();
		}
		self.killstreakToRemove["prone"] = undefined;
	}
	if ( isDefined( self.killstreakToRemove["switchWeap"] ))
	{
		for ( i = 0; i < self.killstreakToRemove["switchWeap"].size ; i++)
		{
			self.killstreakToRemove["switchWeap"][i] Destroy();
		}
		self.killstreakToRemove["switchWeap"] = undefined;
	}
}
//*******************************************************************
//                   End of HUD element functions                   *
//                  Beginning of helper functions                   *
//*******************************************************************
//tagJC<NOTE>: Check a specific upgrade is already acquired by the player.
//tagJC<NOTE>: player is the player that owns the killstreak.
hasUpgrade ( player, upgradeName )
{
	result = false;
	if ( isDefined ( player.acquiredUpgrades ))
	{
		for ( i = 0; i < player.acquiredUpgrades.size; i++ )
		{
			if (( isDefined (player.acquiredUpgrades[i] )) && ( player.acquiredUpgrades[i] == upgradeName ))
			{
				result = true;
				break;
			}
		}
	}
	return result;
}

//tagJC<NOTE>: Returning the name of the kill streak icons.
getKillstreakIcon ( killstreakName )
{
	return tableLookup( KILLSTREAK_STRING_TABLE, 1, killstreakName, 14 );
}

//tagJC<NOTE>: Waiting for the Y button press
//tagJC<NOTE>: Self is the player
waitForYButtonPress()
{
	self endon ("disconnect");
	self endon ("killcam_ended");

	self notifyOnPlayerCommand ( "Y button pressed" , "weapnext" );
	self waittill ( "Y button pressed" );

	self.YbuttonPressedDuringKillCam = true;
}

//tagJC<NOTE>: Waiting for the B button press
//tagJC<NOTE>: Self is the player
waitForBButtonPress()
{
	self endon ("disconnect");
	self endon ("killcam_ended");

	self notifyOnPlayerCommand ( "B button pressed" , "+stance" );
	self waittill ( "B button pressed" );

	self.BbuttonPressedDuringKillCam = true;
}

//tagJC<NOTE>: Returning the status for whether the Y button is pressed.
//tagJC<NOTE>: Self is the player
ReloadButtonPressed()
{
	return self.YbuttonPressedDuringKillCam;
}

//tagJC<NOTE>: Returning the status for whether the B button is pressed.
//tagJC<NOTE>: Self is the player
ProneButtonPressed()
{
	return self.BbuttonPressedDuringKillCam;
}

//tagJC<NOTE>: Returning the name of the kill streak reference.
getKillstreakUserFriendlyName ( killstreakName )
{
	return tableLookupIString( KILLSTREAK_STRING_TABLE, 1, killstreakName, 2 );
}
//*******************************************************************
//                      End of helper functions                     *
//                                                                  *
//*******************************************************************