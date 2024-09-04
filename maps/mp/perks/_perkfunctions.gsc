/******************************************************************* 
//						_perkfunctions.gsc  
//	
//	Holds all the perk set/unset and listening functions 
//	
//	Jordan Hirsh	Sept. 11th 	2008
********************************************************************/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\perks\_perks;

setMarksman()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	
	self setRecoilScale( 10 );
	self.recoilScale = 10;
	self _setperk( "specialty_holdbreath" );
	self _setperk( "specialty_fastsnipe" ); 
	self _setperk( "specialty_bulletflinch" );
}

unsetMarksman()
{	
	self setRecoilScale( 0 );
	self.recoilScale = 0;
	self _unsetperk( "specialty_holdbreath" );
	self _unsetperk( "specialty_fastsnipe" ); 
	self _unsetperk( "specialty_bulletflinch" );
}

useRechargeTest()
{
	println( "Test Perk Activated!" );	
}

unUseRechargeTest()
{
	println( "Test Perk Activation End!" );
}

useGrapplingHook()
{
	
}

unUseGrapplingHook()
{
	
}

//A mobility based rechargeable perk
useAgileAvenger()
{
	println( "Agile Avenger Activated!" );
	
	self.moveSpeedScaler += .10;
	self SetMoveSpeedScale( self.moveSpeedScaler );
	self SetMoonGravity( true );
	//self _setPerk( "specialty_agiSuit" );
	self _setperk( "specialty_falldamage", "rperk1" );
	self _setperk( "specialty_marathon", "rperk2" );
	self _setperk( "specialty_fastmantle", "rperk3" );
	self _setperk( "specialty_automantle", "rperk4" );
	
	//TagZP<TODO> we still want something in here that makes this player easier to detect by the enemy,
	//most likley we will use louder footsteps, or have him make some kind of sound when he moves.
	//maybe this will be detectable by the radar???
	
	//put on the gaszelle goggles
	//self visionsetnakedforplayer( "mp_perk_gazelle", 0.5 );
}

unUseAgileAvenger()
{
	println( "Agile Avenger Activation End!" );
	
	//restore movespeed
	self.moveSpeedScaler -= .10;
	self SetMoveSpeedScale( self.moveSpeedScaler );
	self SetMoonGravity( false );
	self _unsetperk( "specialty_falldamage", "rperk1"  );
	self _unsetperk( "specialty_marathon", "rperk2" );
	self _unsetperk( "specialty_fastmantle", "rperk3");
	self _unsetperk( "specialty_automantle", "rperk4");
	//self _unsetperk( "specialty_agiSuit" );
	
	//go back to the normal map vision set
	//self visionSetNaked( getDvar( "mapname" ), 1.0 );
	self visionsetnakedforplayer( getDvar( "mapname" ), 1.0 );
}

//A stealth based rechargeable perk
useStealthAssasin()
{
	if ( isLevelBlockingRechargeablePerk())
		return;

	println( "Stealth Assasin Activated!" );
	
//	self _setperk( "specialty_coldblooded", "rperk2" );			//coldbloded, codeperk
//	self _setperk( "specialty_blindeye", "rperk3" );		//ninja, codeperk
	
	//TagZP<todo> make this extendable
	duration = level._defaultPerkDuration;
	if( isDefined( level._perkDurations["specialty_Steathexpert"] ))
	{
		duration = level._perkDurations["specialty_Steathexpert"];
	}
	
	//probably going to use a vision set here
	//self thread maps\mp\killstreaks\_emp::EMPGrenade_JamPlayer( duration );
	
	//may want to use a vision set insted of emp overlay
	//VisionSetNaked( "mp_perk_chameleon", 3.0 );
	
	//TagZP<TODO> turn on active camo here
	//self _setperk( "specialty_stealthsuit" );
	self PlayerSetActiveCamoIntensity( 1.0 );
	
}

unUseStealthAssasin()
{
	println( "Stealth Assasin Activation End!" );
	
//	self _unsetperk( "specialty_coldblooded", "rperk2" );			//coldbloded, codeperk
//	self _unsetperk( "specialty_blindeye", "rperk3" );			//ninja, codeperk
	
	//may want to use a vision set insted of emp overlay
	//visionSetNaked( getDvar( "mapname" ), 1.0 );
	
	
	//TagZP<TODO> turn off active camo here
	//self _unsetPerk( "specialty_stealthsuit" );
	self PlayerSetActiveCamoIntensity( 0.0 );
}

//A enemy awareness based rechargeable perk
useAwarenessExpert()
{
	if ( isLevelBlockingRechargeablePerk())
		return;

	println( "Awareness Expert Activated!" );
	//self _setperk( "specialty_selectivehearing", "rperk4" );
	//self _setperk( "specialty_detectexplosive", "rperk2" );			//this is tricky, because it will need to update visibility of sit rep models
	//self _setperk( "specialty_localjammer", "rperk3" );               //Turn the jammer off for the Smart suit
	
	//VisionSetNaked( "mp_perk_motion_sensor", 1.0 );
	
	portable_radar = spawn( "script_model", self.origin );
	portable_radar.team = self.team;
	portable_radar.owner = self;
	//portable_radar setModel( "weapon_c4" );
	
	portable_radar makePortableRadar( self );
	
	portable_radar thread portableRadarWatchForDelete( self );
	portable_radar thread portableRadarUpdatePos();
	//portable_radar thread portableRadarUpdateBeep();
	
	self.awarenessRadar = portable_radar;
}


portableRadarUpdatePos()
{
	self endon( "death" );
	level endon ( "game_ended" );

	for ( ;; )
	{
		wait ( 0.05 );
		self moveTo( self.owner.origin, 0.05, 0.025, 0.025 );
	}
}

portableRadarUpdateBeep()
{
	self endon( "death" );
	level endon ( "game_ended" );

	for ( ;; )
	{
		wait ( 2.00 );
		self playSound( "sentry_gun_beep" );
	}
}


portableRadarWatchForDelete( owner )
{
	//self endon( "death" );
	level endon ( "game_ended" );
	
	owner waittill_any( "disconnect", "joined_team", "joined_spectators", "death", "awareness_perk_off" );
	println( "delete portable radar1" );
	
	self Delete();
	if( isDefined( owner.awarenessRadar ))
	{
		owner.awarenessRadar = undefined;
	}
	
	/*
	if( isDefined( self.awarenessRadar ))
	{
		println( "delete portable radar2" );
		self.awarenessRadar notify( "death" );
		self.awarenessRadar Delete();
		self.awarenessRadar = undefined;
	}
	*/
}

unUseAwarenessExpert()
{
	println( "Awareness Expert Activation End!" );
	
	//self _unsetperk( "specialty_selectivehearing", "rperk4" );
	//self _unsetperk( "specialty_detectexplosive", "rperk2" );		//this is tricky, because it will need to update visibility of sit rep models
	self _unsetperk( "specialty_localjammer", "rperk3" );
	
	//visionSetNaked( getDvar( "mapname" ), 1.0 );
	
	self notify( "awareness_perk_off" );
}

usexrayvision()
{
	/#
	println( "start using xray vision" );
	#/
	
	self setxrayvision( 1 );
	self thread xrayUpdateBeep();
}

unUsexrayvision()
{
	/#
	println( "finish using xray vision" );
	#/
	
	self setxrayvision( 0 );
	self notify( "xray_off" );
}

xrayUpdateBeep()
{
	self endon( "death" );
	self endon( "xray_off" );
	level endon ( "game_ended" );

	for ( ;; )
	{
		//exit condition
		//if( self.toggleRechargablePerk != true )
		//{
		//	return;
		//}
		
		wait ( 0.50 );
		
		if( level._multiteambased )
		{
			/*  Todo make PlaySoundToTeam support MTDM teams
			team = self.pers[ "team" ];
			foreach( name in level._teamNameList )
			{
				if( name != team )
				{
					self PlaySoundToTeam( "xray_tracking_beep", team );
				}
			}
			*/
		}
		else if( level._teambased )
		{
			team = self.pers[ "team" ];
			if( team == "axis" )
			{
				self PlaySoundToTeam( "xray_tracking_beep", "allies" );
			}
			else
			{
				self PlaySoundToTeam( "xray_tracking_beep", "axis" );
			}
		}
		else
		{
			foreach( player in level._players )
			{
				if( player != self )
				{
					self PlaySoundToPlayer( "xray_tracking_beep", player );
				}
			}
		}
	}
}

useDisrputor()
{
	println( "using disruptor" );
}

unUseDisruptor()
{
	println( "end using disruptor" );
}

blastshieldUseTracker( perkName, useFunc )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "end_perkUseTracker" );
	level endon ( "game_ended" );

	for ( ;; )
	{
		self waittill ( "empty_offhand" );

		if ( !isOffhandWeaponEnabled() )
			continue;
			
		self [[useFunc]]( self _hasPerk( "_specialty_blastshield" ) );
	}
}

perkUseDeathTracker()
{
	self endon ( "disconnect" );
	
	self waittill("death");
	self._usePerkEnabled = undefined;
}

setRearView()
{
	//self thread perkUseTracker( "specialty_rearview", ::toggleRearView );
}

unsetRearView()
{
	self notify ( "end_perkUseTracker" );
}

toggleRearView( isEnabled )
{
	if ( isEnabled )
	{
		self _setPerk( "_specialty_rearview" );
		self SetRearViewRenderEnabled(true);
	}
	else
	{
		self _unsetPerk( "_specialty_rearview" );
		self SetRearViewRenderEnabled(false);
	}
}


setEndGame()
{
	if ( isdefined( self.endGame ) )
		return;
		
	self.maxhealth = ( maps\mp\gametypes\_tweakables::getTweakableValue( "player", "maxhealth" ) * 4 );
	self.health = self.maxhealth;
	self.endGame = true;
	self.attackerTable[0] = "";
	self visionSetNakedForPlayer("end_game", 5 );
	self thread endGameDeath( 7 );
	self.hasDoneCombat = true;
}


unsetEndGame()
{
	self notify( "stopEndGame" );
	self.endGame = undefined;
	revertVisionSet();
	
	if (! isDefined( self.endGameTimer ) )
		return;
	
	self.endGameTimer destroyElem();
	self.endGameIcon destroyElem();		
}


revertVisionSet()
{
	self VisionSetNakedForPlayer( getDvar( "mapname" ), 1 );	
}

endGameDeath( duration )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "joined_team" );
	level endon( "game_ended" );
	self endon( "stopEndGame" );
		
	wait( duration + 1 );
	//self visionSetNakedForPlayer("end_game2", 1 );
	//wait(1);
	self _suicide();			
}

setCombatHigh()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "unset_combathigh" );
	level endon( "end_game" );
	
	self.damageBlockedTotal = 0;
	//self visionSetNakedForPlayer( "end_game", 1 );

	if ( level._splitscreen )
	{
		yOffset = 56;
		iconSize = 21; // 32/1.5
	}
	else
	{
		yOffset = 112;
		iconSize = 32;
	}

	self.combatHighOverlay = newClientHudElem( self );
	self.combatHighOverlay.x = 0;
	self.combatHighOverlay.y = 0;
	self.combatHighOverlay.alignX = "left";
	self.combatHighOverlay.alignY = "top";
	self.combatHighOverlay.horzAlign = "fullscreen";
	self.combatHighOverlay.vertAlign = "fullscreen";
	self.combatHighOverlay setshader ( "combathigh_overlay", 640, 480 );
	self.combatHighOverlay.sort = -10;
	self.combatHighOverlay.archived = true;
	
	self.combatHighTimer = createTimer( "hudsmall", 1.0 );
	self.combatHighTimer setPoint( "CENTER", "CENTER", 0, yOffset );
	self.combatHighTimer setTimer( 10.0 );
	self.combatHighTimer.color = (.8,.8,0);
	self.combatHighTimer.archived = false;
	self.combatHighTimer.foreground = true;

	self.combatHighIcon = self createIcon( "specialty_painkiller", iconSize, iconSize );
	self.combatHighIcon.alpha = 0;
	self.combatHighIcon setParent( self.combatHighTimer );
	self.combatHighIcon setPoint( "BOTTOM", "TOP" );
	self.combatHighIcon.archived = true;
	self.combatHighIcon.sort = 1;
	self.combatHighIcon.foreground = true;

	self.combatHighOverlay.alpha = 0.0;	
	self.combatHighOverlay fadeOverTime( 1.0 );
	self.combatHighIcon fadeOverTime( 1.0 );
	self.combatHighOverlay.alpha = 1.0;
	self.combatHighIcon.alpha = 0.85;
	
	self thread unsetCombatHighOnDeath();
	
	wait( 8 );

	self.combatHighIcon	fadeOverTime( 2.0 );
	self.combatHighIcon.alpha = 0.0;
	
	self.combatHighOverlay fadeOverTime( 2.0 );
	self.combatHighOverlay.alpha = 0.0;
	
	self.combatHighTimer fadeOverTime( 2.0 );
	self.combatHighTimer.alpha = 0.0;

	wait( 2 );
	self.damageBlockedTotal = undefined;

	self _unsetPerk( "specialty_combathigh" );
}

unsetCombatHighOnDeath()
{
	self endon ( "disconnect" );
	self endon ( "unset_combathigh" );
	
	self waittill ( "death" );
	
	self thread _unsetPerk( "specialty_combathigh" );
}

unsetCombatHigh()
{
	self notify ( "unset_combathigh" );
	self.combatHighOverlay destroy();
	self.combatHighIcon destroy();
	self.combatHighTimer destroy();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
setNetPainkiller()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "end_game" );

	self.damageBlockedTotal = 0;

	if ( level._splitscreen )
	{
		yOffset = 56;
		iconSize = 21; // 32/1.5
	}
	else
	{
		yOffset = 112;
		iconSize = 32;
	}

	self.netPainkillerIcon = self createIcon( level._netPerkMaterials[ "netbuff_painkiller" ], iconSize, iconSize );
	self.netPainkillerIcon.alpha = 0;
	self.netPainkillerIcon setPoint( "CENTER", "CENTER", 0, yOffset );
	self.netPainkillerIcon.archived = true;
	self.netPainkillerIcon.sort = 1;
	self.netPainkillerIcon.foreground = true;


	self.netPainkillerIcon.alpha = 0.85; 
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
unsetNetPainkiller()
{
//	self.netPainkillerIcon fadeOverTime( 1.0 );
//	self.netPainkillerIcon.alpha = 0.0;
	self.netPainkillerIcon destroy();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
setDishClip()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "end_game" );

	if ( level._splitscreen )
	{
		yOffset = 56;
		iconSize = 21; // 32/1.5
	}
	else
	{
		yOffset = 112;
		iconSize = 32;
	}

	self.dishClipIcon = self createIcon( level._netPerkMaterials[ "netbuff_dishclip" ], iconSize, iconSize );
	self.dishClipIcon.alpha = 0.85;
	self.dishClipIcon setPoint( "CENTER", "CENTER", iconSize, yOffset );
	self.dishClipIcon.archived = true;
	self.dishClipIcon.sort = 1;
	self.dishClipIcon.foreground = true;

	self thread dishClipThink();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
unsetDishClip()
{
	self.dishClipIcon destroy();
	self notify ( "end_dishclip" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
dishClipThink()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "end_dishclip" );

	while ( 1 )
	{
		self waittill ( "killed_enemy" );
		
		foreach( player in level._players )
		{
			// dish a clip to all players on my team (need some UI feedback still)
			if (( player.team == self.team ) && ( self != player ))
			{
				if ( distance( self.origin, player.origin ) < getDvarFloat( "perk_netSoldierEffectiveRadius" ))
				{
					player dishClip();
				}
			}
		}
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
dishClip()
{
	self endon( "death" );
	level endon ( "game_ended" );

	//offhandWeapons = self getWeaponsListOffhands();
	//foreach ( offhand in offhandWeapons )
	//{		
	//	currentClipAmmo = self GetWeaponAmmoClip( offhand );
	//	self SetWeaponAmmoClip( offhand, currentClipAmmo + 1);
	//}

	primaryWeapons = self getWeaponsListPrimaries();	
	foreach ( primary in primaryWeapons )
	{
		if ( !isCACPrimaryWeapon( primary ) )
		{
			continue;
		}
			
		currentStockAmmo = self GetWeaponAmmoStock( primary );
		addStockAmmo = weaponClipSize( primary );
		
		self setWeaponAmmoStock( primary, currentStockAmmo + addStockAmmo );

		altWeapon = weaponAltWeaponName( primary );

		if ( !isDefined( altWeapon ) || (altWeapon == "none") )
			continue;

		currentStockAmmo = self GetWeaponAmmoStock( altWeapon );
		addStockAmmo = weaponClipSize( altWeapon );

		self setWeaponAmmoStock( altWeapon, currentStockAmmo + addStockAmmo );
	}

	self maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "scavenger" );
}

setSiege()
{
	self thread trackSiegeEnable();
	self thread trackSiegeDissable();
}

trackSiegeEnable()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "stop_trackSiege" );
	
	for ( ;; )
	{
		self waittill ( "gambit_on" );
		
		//self setStance( "crouch" );
		//self thread stanceStateListener();
		//self thread jumpStateListener();  
		self.moveSpeedScaler = 0;
		self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );
		class = weaponClass( self getCurrentWeapon() );
		
		if ( class == "pistol" || class == "smg" ) 
			self setSpreadOverride( 1 );
		else
			self setSpreadOverride( 2 );
		
		self player_recoilScaleOn( 0 );
		self allowJump(false);	
	}	
}

trackSiegeDissable()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "stop_trackSiege" );
	
	for ( ;; )
	{
		self waittill ( "gambit_off" );
		
		unsetSiege();
	}	
}

stanceStateListener()
{
	self endon ( "death" );
	self endon ( "disconnect" );	
	
	self notifyOnPlayerCommand( "adjustedStance", "+stance" );

	for ( ;; )
	{
		self waittill( "adjustedStance" );
		if ( self.moveSPeedScaler != 0 )
			continue;
			
		unsetSiege();
	}
}

jumpStateListener()
{
	self endon ( "death" );
	self endon ( "disconnect" );	
	
	self notifyOnPlayerCommand( "jumped", "+goStand" );

	for ( ;; )
	{
		self waittill( "jumped" );
		if ( self.moveSPeedScaler != 0 )
			continue;
				
		unsetSiege();
	}
}

unsetSiege()
{
	self.moveSpeedScaler = 1;
	//if siege is not cut add check to see if
	//using lightweight and siege for movespeed scaler
	self resetSpreadOverride();
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );
	self player_recoilScaleOff();
	self allowJump(true);
}


setFinalStand()
{
	self _setperk( "specialty_pistoldeath");
}

unsetFinalStand()
{
	self _unsetperk( "specialty_pistoldeath" );
}


setChallenger()
{
	if ( !level._hardcoreMode )
	{
		self.maxhealth = maps\mp\gametypes\_tweakables::getTweakableValue( "player", "maxhealth" );
		
		if ( isDefined( self.xpScaler ) && self.xpScaler == 1 && self.maxhealth > 30 )
		{		
			self.xpScaler = 2;
		}	
	}
}

unsetChallenger()
{
	self.xpScaler = 1;
}


setSaboteur()
{
	self.objectiveScaler = 1.2;
}

unsetSaboteur()
{
	self.objectiveScaler = 1;
}

setFastHealthRegen()
{
	self.healthRegenDelay = level._playerHealth_RegularRegenDelay * 0.5 ;
	self.healthRegenRate = level._playerHealth_RegenRate * 3.0;
}

unsetFastHealthRegen()
{
	self.healthRegenDelay = level._playerHealth_RegularRegenDelay;
	self.healthRegenRate = level._playerHealth_RegenRate;
}

setLightWeight()
{
	self.moveSpeedScaler = 1.07;	
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );
}

unsetLightWeight()
{
	self.moveSpeedScaler = 1;
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );
}

setNinjaholder()
{
	self _setperk( "specialty_spygame");
	self _setperk( "specialty_selectivehearing");
}

unsetNinjaholder()
{
	self _unsetperk( "specialty_spygame");
	self _unsetperk( "specialty_selectivehearing");
}

setEquipmentHack()
{
}

unsetEquipmentHack()
{
}

setJuggersuit()
{
	self.moveSpeedScaler = .75;
	//self.healthRegenDelay = level._playerHealth_RegularRegenDelay * 1000.0 ;
	//self.healthRegenRate = level._playerHealth_RegenRate * 0.001;

	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );

	//self _setperk( "specialty_pistoldeath");
}

unsetJuggersuit()
{
	self.moveSpeedScaler = 1;
	//self.healthRegenDelay = level._playerHealth_RegularRegenDelay;
	//self.healthRegenRate = level._playerHealth_RegenRate;

	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );

	//self _unsetperk( "specialty_pistoldeath");
}

setStealthsuit()
{
}

unsetStealthsuit()
{
}

setTacsuit()
{
	if ( !self isEMPed() )
		self RadarJamOn();

	self.objectiveScaler = 2;
	self _setperk( "specialty_detectexplosive" );
	self _setperk( "specialty_thermal" ); 
}

unsetTacsuit()
{
	self RadarJamOff();
	self.objectiveScaler = 1;
	self _unsetperk( "specialty_detectexplosive" );
	self _unsetperk( "specialty_thermal" );
}

setAgisuit()
{
	/*
	self.moveSpeedScaler = 1.4;
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );

	self _setperk( "specialty_marathon" );
	self _setperk( "specialty_fastmantle" );
	self _setperk( "specialty_falldamage" );
	self _setperk( "specialty_automantle" );
	*/
	
}

unsetAgisuit()
{
	/*
	self.moveSpeedScaler = 1;
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );
	
	self _unsetperk( "specialty_marathon" );
	self _unsetperk( "specialty_fastmantle" );
	self _unsetperk( "specialty_falldamage" );
	self _unsetperk( "specialty_automantle" );
	*/
}

setJetsuit()
{
self _setperk( "specialty_falldamage" );
}

unsetJetsuit()
{
self _unsetperk( "specialty_falldamage" );
}

setBlackBox()
{
	self.killStreakScaler = 1.5;
}

unsetBlackBox()
{
	self.killStreakScaler = 1;
}

setSteelNerves()
{
}

unsetSteelNerves()
{
}

setDelayMine()
{
}

unsetDelayMine()
{
}

setExplosivedamage()
{
}

unsetExplosivedamage()
{
}

setMarathonholder()
{
	self _setperk( "specialty_fastmantle" ); 
	self _setperk( "specialty_automantle" );
	self _setperk( "specialty_lightweight" );
	self _setperk( "specialty_falldamage" );
	self _setperk( "specialty_sprintreload" );
}

unsetMarathonholder()
{
	self _unsetperk( "specialty_fastmantle" );
	self _unsetperk( "specialty_automantle" );
	self _unsetperk( "specialty_lightweight" );
	self _unsetperk( "specialty_falldamage" );
	self _unsetperk( "specialty_sprintreload" );
}

setFasterLockOn()
{
	self _setperk( "specialty_armorpiercing" );
}

unsetFasterLockOn()
{
	self _unsetperk( "specialty_armorpiercing" );
}

setQuickdrawholder()
{
	self _setperk( "specialty_fastmeleerecovery" );
	self _setperk( "specialty_fastoffhand" );  
}

unsetQuickdrawholder()
{
	self _unsetperk( "specialty_fastmeleerecovery" );
	self _unsetperk( "specialty_fastoffhand" );
}

setBling()
{
	self _setperk( "specialty_bulletpenetration" );
}

unsetBling()
{
	self _unsetperk( "specialty_bulletpenetration" );
}

setBulletAccuracy()
{
	//BB This is a code perk, duplicated here for the time being until we get the slot stuff sorted
}

unsetBulletAccuracy()
{
}

setFlakJacket()
{
	self.stunScaler = .5;
	self.flashScaler = .5;
}

unsetFlakJacket()
{
	self.stunScaler = 1;
	self.flashScaler = 1;
}

setGasMask()
{
}

unsetGasMask()
{

}

setQuieter()
{
}

unsetQuieter()
{
}

setHardline()
{
}

unsetHardline()
{	
}

useRollover()
{
}

unUseRollover()
{
}

setBackShield()
{
	self AttachShieldModel( "weapon_riot_shield_mp", "tag_shield_back" );	
}


unsetBackShield()
{
	self DetachShieldModel( "weapon_riot_shield_mp", "tag_shield_back" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
setLocalJammer()
{
	if ( !self isEMPed() )
		self RadarJamOn();

/*		culling out the old net buff stuff
	if ( level._splitscreen )
	{
		yOffset = 56;
		iconSize = 21; // 32/1.5
	}s
	else
	{
		yOffset = 112;
		iconSize = 32;
	}

	self.scramblerIcon = self createIcon( level._netPerkMaterials[ "netbuff_scrambler" ], iconSize, iconSize );
	self.scramblerIcon.alpha = 0.85;
	self.scramblerIcon setPoint( "CENTER", "CENTER", iconSize*2, yOffset );
	self.scramblerIcon.archived = true;
	self.scramblerIcon.sort = 1;
	self.scramblerIcon.foreground = true;
*/
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
unsetLocalJammer()
{
	//self.scramblerIcon destroy();
	self RadarJamOff();
}


setAC130()
{
	self thread killstreakThink( "ac130", 7, "end_ac130Think" );
}

unsetAC130()
{
	self notify ( "end_ac130Think" );
}


setSentryMinigun()
{
	self thread killstreakThink( "airdrop_sentry_minigun", 2, "end_sentry_minigunThink" );
}

unsetSentryMinigun()
{
	self notify ( "end_sentry_minigunThink" );
}

setCarePackage()
{
	self thread killstreakThink( "airdrop", 2, "endCarePackageThink" );
}

unsetCarePackage()
{
	self notify ( "endCarePackageThink" );
}

setTank()
{
	self thread killstreakThink( "tank", 6, "end_tankThink" );
}

unsetTank()
{
	self notify ( "end_tankThink" );
}

setPrecision_airstrike()
{
	println( "!precision airstrike!" );
	self thread killstreakThink( "precision_airstrike", 6, "end_precision_airstrike" );
}

unsetPrecision_airstrike()
{
	self notify ( "end_precision_airstrike" );
}

setPredatorMissile()
{
	self thread killstreakThink( "predator_missile", 4, "end_predator_missileThink" );
}

unsetPredatorMissile()
{
	self notify ( "end_predator_missileThink" );
}


setHelicopterMinigun()
{
	self thread killstreakThink( "helicopter_minigun", 5, "end_helicopter_minigunThink" );
}

unsetHelicopterMinigun()
{
	self notify ( "end_helicopter_minigunThink" );
}



killstreakThink( streakName, streakVal, endonString )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( endonString );
	
	for ( ;; )
	{
		self waittill ( "killed_enemy" );
		
		if ( self.pers["cur_kill_streak"] != streakVal )
			continue;

		self thread maps\mp\killstreaks\_killstreaks::giveKillstreak( streakName );
		self thread maps\mp\gametypes\_hud_message::killstreakSplashNotify( streakName, streakVal );
		return;
	}
}


setThermal()
{
	self ThermalVisionOn();
}


unsetThermal()
{
	self ThermalVisionOff();
}


setOneManArmy()
{
	self thread oneManArmyWeaponChangeTracker();
}


unsetOneManArmy()
{
	self notify ( "stop_oneManArmyTracker" );
}


oneManArmyWeaponChangeTracker()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	self endon ( "stop_oneManArmyTracker" );
	
	for ( ;; )
	{
		self waittill( "weapon_change", newWeapon );

		if ( newWeapon != "onemanarmy_mp" )	
			continue;
	
		//if ( self isUsingRemote() )
		//	continue;
		
		self thread selectOneManArmyClass();	
	}
}


isOneManArmyMenu( menu )
{
	if ( menu == game["menu_onemanarmy"] )
		return true;

	if ( isDefined( game["menu_onemanarmy_defaults_splitscreen"] ) && menu == game["menu_onemanarmy_defaults_splitscreen"] )
		return true;

	if ( isDefined( game["menu_onemanarmy_custom_splitscreen"] ) && menu == game["menu_onemanarmy_custom_splitscreen"] )
		return true;

	return false;
}


selectOneManArmyClass()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	
	self _disableWeaponSwitch();
	self _disableOffhandWeapons();
	self _disableUsability();
	
	self openPopupMenu( game["menu_onemanarmy"] );
	
	self thread closeOMAMenuOnDeath();
	
	self waittill ( "menuresponse", menu, className );

	self _enableWeaponSwitch();
	self _enableOffhandWeapons();
	self _enableUsability();
	
	if ( className == "back" || !isOneManArmyMenu( menu ) || self isUsingRemote() )
	{
		if ( self getCurrentWeapon() == "onemanarmy_mp" )
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
		return;
	}	
	
	self thread giveOneManArmyClass( className );	
}

closeOMAMenuOnDeath()
{
	self endon ( "menuresponse" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	
	self waittill ( "death" );

	self _enableWeaponSwitch();
	self _enableOffhandWeapons();
	self _enableUsability();

	self closePopupMenu();
}

giveOneManArmyClass( className )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );

	if ( self _hasPerk( "specialty_omaquickchange" ) )
	{
		changeDuration = 3.0;
		self playLocalSound( "foly_onemanarmy_bag3_plr" );
		self playSoundToTeam( "foly_onemanarmy_bag3_npc", "allies", self );
		self playSoundToTeam( "foly_onemanarmy_bag3_npc", "axis", self );
	}
	else
	{
		changeDuration = 6.0;
		self playLocalSound( "foly_onemanarmy_bag6_plr" );
		self playSoundToTeam( "foly_onemanarmy_bag6_npc", "allies", self );
		self playSoundToTeam( "foly_onemanarmy_bag6_npc", "axis", self );
	}
		
	self thread omaUseBar( changeDuration );
		
	self _disableWeapon();
	self _disableOffhandWeapons();
	self _disableUsability();
	
	wait ( changeDuration );

	self _enableWeapon();
	self _enableOffhandWeapons();
	self _enableUsability();
	
	self.OMAClassChanged = true;

	self maps\mp\gametypes\_class::giveLoadout( self.pers["team"], className, false );
	
	// handle the fact that detachAll in giveLoadout removed the CTF flag from our back
	// it would probably be better to handle this in _detachAll itself, but this is a safety fix
	if ( isDefined( self.carryFlag ) )
		self attach( self.carryFlag, "J_spine4", true );
	
	self notify ( "changed_kit" );
	level notify ( "changed_kit" );
}


omaUseBar( duration )
{
	self endon( "disconnect" );
	
	useBar = createPrimaryProgressBar( 25 );
	useBarText = createPrimaryProgressBarText( 25 );
	useBarText setText( &"MPUI_CHANGING_KIT" );

	useBar updateBar( 0, 1 / duration );
	for ( waitedTime = 0; waitedTime < duration && isAlive( self ) && !level._gameEnded; waitedTime += 0.05 )
		wait ( 0.05 );
	
	useBar destroyElem();
	useBarText destroyElem();
}


setBlastShield()
{
	//self thread blastshieldUseTracker( "specialty_blastshield", ::toggleBlastShield );
	self SetWeaponHudIconOverride( "primaryoffhand", "specialty_blastshield" );
}


unsetBlastShield()
{
	//self notify ( "end_perkUseTracker" );
	self SetWeaponHudIconOverride( "primaryoffhand", "none" );
}

setRechargeTest()
{
	println( "setting recharge test" );
}

unsetRechargeTest()
{
	println( "unsetting recharge test" );
}

toggleBlastShield( isEnabled )
{
	if ( !isEnabled )
	{
		self VisionSetNakedForPlayer( "black_bw", 0.15 );
		wait ( 0.15 );
		self _setPerk( "_specialty_blastshield" );
		self VisionSetNakedForPlayer( getDvar( "mapname" ), 0 );
		self playSoundToPlayer( "item_blast_shield_on", self );
	}
	else
	{
		self VisionSetNakedForPlayer( "black_bw", 0.15 );
		wait ( 0.15 );	
		self _unsetPerk( "_specialty_blastshield" );
		self VisionSetNakedForPlayer( getDvar( "mapname" ), 0 );
		self playSoundToPlayer( "item_blast_shield_off", self );
	}
}


setFreefall()
{

}

unsetFreefall()
{

}

setTwoPrimaries()
{
}

unsetTwoPrimaries()
{
}

setTwoPrimariesHolder()
{
}

unsetTwoPrimariesHolder()
{
}

setTacticalInsertion()
{
	self _giveWeapon( "flare_mp", 0 );
	self giveStartAmmo( "flare_mp" );
	
	self thread monitorTIUse();
}

unsetTacticalInsertion()
{
	self notify( "end_monitorTIUse" );
}

clearPreviousTISpawnpoint()
{
	self waittill_any ( "disconnect", "joined_team", "joined_spectators" );
	
	if ( isDefined ( self.setSpawnpoint ) )
		self deleteTI( self.setSpawnpoint );
}

updateTISpawnPosition()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	self endon ( "end_monitorTIUse" );
	
	while ( isReallyAlive( self ) )
	{
		if ( self isValidTISpawnPosition() )
			self.TISpawnPosition = self.origin;

		wait ( 0.05 );
	}
}

isValidTISpawnPosition()
{
	if ( CanSpawn( self.origin ) && self IsOnGround() )
		return true;
	else
		return false;
}

monitorTIUse()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	self endon ( "end_monitorTIUse" );

	self thread updateTISpawnPosition();
	self thread clearPreviousTISpawnpoint();
	
	for ( ;; )
	{
		self waittill( "grenade_fire", lightstick, weapName );
				
		if ( weapName != "flare_mp" )
			continue;
		
		//lightstick delete();
		
		if ( isDefined( self.setSpawnPoint ) )
			self deleteTI( self.setSpawnPoint );

		if ( !isDefined( self.TISpawnPosition ) )
			continue;

		if ( self touchingBadTrigger() )
			continue;

		TIGroundPosition = playerPhysicsTrace( self.TISpawnPosition + (0,0,16), self.TISpawnPosition - (0,0,2048) ) + (0,0,1);
		
		glowStick = spawn( "script_model", TIGroundPosition );
		glowStick.angles = self.angles;
		glowStick.team = self.team;
		glowStick.enemyTrigger =  spawn( "script_origin", TIGroundPosition );
		glowStick thread GlowStickSetupAndWaitForDeath( self );
		glowStick.playerSpawnPos = self.TISpawnPosition;
		
		glowStick thread maps\mp\gametypes\_weapons::createBombSquadModel( "weapon_light_stick_tactical_bombsquad", "tag_fire_fx", self );
		
		self.setSpawnPoint = glowStick;		
		return;
	}
}


GlowStickSetupAndWaitForDeath( owner )
{
	self setModel( level._spawnGlowModel["enemy"] );
	if ( level._teamBased )
		self maps\mp\_entityheadIcons::setTeamHeadIcon( self.team , (0,0,20) );
	else
		self maps\mp\_entityheadicons::setPlayerHeadIcon( owner, (0,0,20) );

	self thread GlowStickDamageListener( owner );
	self thread GlowStickEnemyUseListener( owner );
	self thread GlowStickUseListener( owner );
	
	if( level._multiteamBased )
	{
		foreach ( team in level._teamNameList )
		{
			if( team != self.team )
			{
				self thread GlowStickTeamUpdater( team, level._spawnGlow["enemy"], owner );
			}
		}
	}
	else
	{
		self thread GlowStickTeamUpdater( level._otherTeam[self.team], level._spawnGlow["enemy"], owner );
	}

	dummyGlowStick = spawn( "script_model", self.origin+ (0,0,0) );
	dummyGlowStick.angles = self.angles;
	dummyGlowStick setModel( level._spawnGlowModel["friendly"] );
	dummyGlowStick setContents( 0 );
	dummyGlowStick thread GlowStickTeamUpdater( self.team, level._spawnGlow["friendly"], owner );
	
	dummyGlowStick playLoopSound( "emt_road_flare_burn" );

	self waittill ( "death" );
	
	dummyGlowStick stopLoopSound();
	dummyGlowStick delete();
}


GlowStickTeamUpdater( showForTeam, showEffect, owner )
{
	self endon ( "death" );
	
	// PlayFXOnTag fails if run on the same frame the parent entity was created
	wait ( 0.05 );
	
	//PlayFXOnTag( showEffect, self, "TAG_FX" );
	angles = self getTagAngles( "tag_fire_fx" );
	fxEnt = SpawnFx( showEffect, self getTagOrigin( "tag_fire_fx" ), anglesToForward( angles ), anglesToUp( angles ) );
	TriggerFx( fxEnt );
	
	self thread deleteOnDeath( fxEnt );
	
	for ( ;; )
	{
		self hide();
		fxEnt hide();
		foreach ( player in level._players )
		{
			if ( player.team == showForTeam && level._teamBased )
			{
				self showToPlayer( player );
				fxEnt showToPlayer( player );
			}
			else if ( !level._teamBased && player == owner && showEffect == level._spawnGlow["friendly"] )
			{
				self showToPlayer( player );
				fxEnt showToPlayer( player );
			}
			else if ( !level._teamBased && player != owner && showEffect == level._spawnGlow["enemy"] )
			{
				self showToPlayer( player );
				fxEnt showToPlayer( player );
			}
		}
		
		level waittill_either ( "joined_team", "player_spawned" );
	}
}

deleteOnDeath( ent )
{
	self waittill( "death" );
	if ( isdefined( ent ) )
		ent delete();
}

GlowStickDamageListener( owner )
{
	self endon ( "death" );

	self setCanDamage( true );
	// use large health to work around teamkilling issue
	self.health = 5000;

	for ( ;; )
	{
		self waittill ( "damage", amount, attacker );

		if ( level._teambased && isDefined( owner ) && attacker != owner && ( isDefined( attacker.team ) && attacker.team == self.team ) )
		{
			self.health += amount;
			continue;
		}
		
		if ( self.health < (5000-20) )
		{
			if ( isDefined( owner ) && attacker != owner )
			{
				attacker notify ( "destroyed_insertion", owner );
				attacker notify( "destroyed_explosive" ); // count towards SitRep Pro challenge
				owner thread leaderDialogOnPlayer( "ti_destroyed" );
			}
			
			attacker thread deleteTI( self );
		}
	}
}

GlowStickUseListener( owner )
{
	self endon ( "death" );
	level endon ( "game_ended" );
	owner endon ( "disconnect" );
	
	self setCursorHint( "HINT_NOICON" );
	self setHintString( &"MP_PICKUP_TI" );
	
	self thread updateEnemyUse( owner );

	for ( ;; )
	{
		self waittill ( "trigger", player );
		
		player playSound( "chemlight_pu" );
		player thread setTacticalInsertion();
		player thread deleteTI( self );
	}
}

updateEnemyUse( owner )
{
	self endon ( "death" );
	
	for ( ;; )
	{
		self setSelfUsable( owner );
		level waittill_either ( "joined_team", "player_spawned" );
	}
}

deleteTI( TI )
{
	if (isDefined( TI.enemyTrigger ) )
		TI.enemyTrigger Delete();
	
	spot = TI.origin;
	spotAngles = TI.angles;
	
	TI Delete();
	
	dummyGlowStick = spawn( "script_model", spot );
	dummyGlowStick.angles = spotAngles;
	dummyGlowStick setModel( level._spawnGlowModel["friendly"] );
	
	dummyGlowStick setContents( 0 );
	thread dummyGlowStickDelete( dummyGlowStick );
}

dummyGlowStickDelete( stick )
{
	wait(2.5);
	stick Delete();
}

GlowStickEnemyUseListener( owner )
{
	self endon ( "death" );
	level endon ( "game_ended" );
	owner endon ( "disconnect" );
	
	self.enemyTrigger setCursorHint( "HINT_NOICON" );
	self.enemyTrigger setHintString( &"MP_DESTROY_TI" );
	self.enemyTrigger makeEnemyUsable( owner );
	
	for ( ;; )
	{
		self.enemyTrigger waittill ( "trigger", player );
		
		player notify ( "destroyed_insertion", owner );
		player notify( "destroyed_explosive" ); // count towards SitRep Pro challenge

		//playFX( level.spawnGlowSplat, self.origin);		
		
		if ( isDefined( owner ) && player != owner )
			owner thread leaderDialogOnPlayer( "ti_destroyed" );

		player thread deleteTI( self );
	}	
}

setLittlebirdSupport()
{
	self thread killstreakThink( "littlebird_support", 2, "end_littlebird_support_think" );
}

unsetLittlebirdSupport()
{
	self notify ( "end_littlebird_support_think" );
}

setC4Death()
{
	if ( ! self _hasperk( "specialty_pistoldeath" ) )
		self _setperk( "specialty_pistoldeath");
}

unsetC4Death()
{

}

/////////////////////////////////////////////////////////////////
/////////Recon paint
setPainted( attacker_team ) // self == victim
{
	
	// this is called from cac_modified_damage, not the perk functions
	if( IsPlayer( self ) )
	{
		paintedTime = 10.0;
		// half the time if they have the anti-perk (whatever it may be)
		if( self _hasPerk( "specialty_quieter" ) )
			paintedTime *= 0.5;

		// first see if we are already marked, if so, reset the time
		if( IsDefined( self.objIdPainted ) )
		{
			self thread unsetPainted( paintedTime );
			return;
		}

		shaderName = "compassping_enemy";
		curObjID = maps\mp\gametypes\_gameobjects::getNextObjID();
		Objective_Add( curObjID, "invisible", (0,0,0) );
		Objective_OnEntity( curObjID, self );
		Objective_State( curObjID, "active" );
		Objective_Icon( curObjID, shaderName );

		if ( level._teamBased )
		{
			Objective_Team( curObjID, attacker_team );
		}

		self.objIdPainted = curObjID;
		self thread unsetPainted( paintedTime );
		self thread watchPaintedDeath();
		self thread watchPaintedDisconnect();
	}
}

watchPaintedDeath()
{
	self endon( "disconnect" );
	level endon( "game_ended" );

	self waittill( "death" );

	if( IsDefined( self.objIdPainted ) )
	{
		_objective_delete( self.objIdPainted );
		self.objIdPainted = undefined;
	}
}

watchPaintedDisconnect()
{
	self endon( "death" );
	level endon( "game_ended" );

	objIdPainted = self.objIdPainted;
	self waittill( "disconnect" );

	if( IsDefined( objIdPainted ) )
	{
		_objective_delete( objIdPainted );
	}
}

unsetPainted( time )
{
	self notify( "painted_again" );
	self endon( "painted_again" );

	self endon( "disconnect" );
	self endon( "death" );
	level endon( "game_ended" );

	wait( time );
	
	if( IsDefined( self.objIdPainted ) )
	{
		_objective_delete( self.objIdPainted );
		self.objIdPainted = undefined;
	}
}

/////////////////////////////////////////////////////////////////
// REVENGE: show the last player who killed you, on your mini-map or in the world with a head icon
setRevenge() // this version does the head icon
{
	self notify( "stopRevenge" );
	wait( 0.05 ); // let all of the already running threads stop and clean up

	//tagCT<NOTE> This check is to disable the Revenge Deathstreak in the Bounty Hunter Game Mode
	if( isDefined( self.current_bounty ) )
		return;

	if( !IsDefined( self.lastKilledBy ) )
		return;

	if( self.team == self.lastKilledBy.team )
		return;

	revengeParams = SpawnStruct();
	revengeParams.showTo = self;
	revengeParams.icon = "compassping_revenge";
	revengeParams.offset = ( 0, 0, 64 );
	revengeParams.width = 10;
	revengeParams.height = 10;
	revengeParams.archived = false;
	revengeParams.delay = 1.5;
	revengeParams.constantSize = false;
	revengeParams.pinToScreenEdge = true;
	revengeParams.fadeOutPinnedIcon = false;
	revengeParams.is3D = false;
	self.revengeParams = revengeParams;

	self.lastKilledBy maps\mp\_entityheadIcons::setHeadIcon( 
		revengeParams.showTo, 
		revengeParams.icon, 
		revengeParams.offset, 
		revengeParams.width, 
		revengeParams.height, 
		revengeParams.archived, 
		revengeParams.delay, 
		revengeParams.constantSize, 
		revengeParams.pinToScreenEdge, 
		revengeParams.fadeOutPinnedIcon,
		revengeParams.is3D );
	
	self thread watchRevengeDeath();
	self thread watchRevengeKill();
	self thread watchRevengeDisconnected();
	self thread watchRevengeVictimDisconnected();
	self thread watchStopRevenge();
}

//setRevenge() // this version does the mini-map objective
//{
//	self notify( "stopRevenge" );
//	wait( 0.05 ); // let all of the already running threads stop and clean up
//
//	if( !IsDefined( self.lastKilledBy ) )
//		return;
//
//	// show objective only to a single player, not the whole team
//	curObjID = maps\mp\gametypes\_gameobjects::getNextObjID();	
//	Objective_Add( curObjID, "invisible", (0,0,0) );
//	Objective_OnEntity( curObjID, self.lastKilledBy );
//	Objective_State( curObjID, "active" );
//	Objective_Icon( curObjID, "compassping_revenge" );
//	Objective_Player( curObjID, self GetEntityNumber() );
//	self.objIdFriendly = curObjID;
//
//	self thread watchRevengeKill();
//	self thread watchRevengeDisconnected();
//	self thread watchRevengeVictimDisconnected();
//	self thread watchStopRevenge();
//}

watchRevengeDeath() // self == player with the deathstreak
{
	self endon( "stopRevenge" );
	self endon( "disconnect" );

	lastKilledBy = self.lastKilledBy;
	// since head icons get deleted on death, we need to keep giving this player a head icon until stop revenge
	while( true )
	{
		lastKilledBy waittill( "spawned_player" );
		lastKilledBy maps\mp\_entityheadIcons::setHeadIcon( 
			self.revengeParams.showTo, 
			self.revengeParams.icon, 
			self.revengeParams.offset, 
			self.revengeParams.width, 
			self.revengeParams.height, 
			self.revengeParams.archived, 
			self.revengeParams.delay, 
			self.revengeParams.constantSize, 
			self.revengeParams.pinToScreenEdge, 
			self.revengeParams.fadeOutPinnedIcon,
			self.revengeParams.is3D );
	}
}

watchRevengeKill()
{
	self endon( "stopRevenge" );

	self waittill( "killed_enemy" );

	self notify( "stopRevenge" );
}

watchRevengeDisconnected()
{
	self endon( "stopRevenge" );

	self.lastKilledBy waittill( "disconnect" );

	self notify( "stopRevenge" );
}

watchStopRevenge() // self == player with the deathstreak
{
	lastKilledBy = self.lastKilledBy;	
	
	// if the player gets any kill, then stop the revenge on the last killed by player
	// if the player dies again without getting any kills, have the new killer show and the old not	
	self waittill( "stopRevenge" );

	if( !IsDefined( lastKilledBy ) )
		return;

	foreach( key, headIcon in lastKilledBy.entityHeadIcons )
	{	
		if( !isDefined( headIcon ) )
			continue;

		headIcon destroy();
	}

	//if( isDefined( self.objIdFriendly ) )
	//	_objective_delete( self.objIdFriendly );
}

watchRevengeVictimDisconnected()
{
	// if the player with revenge gets disconnected then clean up
	objID = self.objIdFriendly;
	lastKilledBy = self.lastKilledBy;
	lastKilledBy endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "stopRevenge" );

	self waittill( "disconnect" );

	if( !IsDefined( lastKilledBy ) )
		return;

	foreach( key, headIcon in lastKilledBy.entityHeadIcons )
	{	
		if( !isDefined( headIcon ) )
			continue;

		headIcon destroy();
	}

	//if( isDefined( objID ) )
	//	_objective_delete( objID );
}

unsetRevenge()
{	
	self notify( "stopRevenge" );
}
// END REVENGE
/////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////
// UAV: give the player a uav on spawn
setUAV()
{
	self thread maps\mp\killstreaks\_killstreaks::giveKillstreak( "uav", false, false, self, true );
}

unsetUAV()
{

}

isLevelBlockingRechargeablePerk()
{
	if ( isDefined( level._blockRechargeablePerk ) && level._blockRechargeablePerk == true )
	{
		return true;
	}
	else
	{
		return false;
	} 
}

useFastCarePackage()
{
}

unUseFastCarePackage()
{
}

setSpectre()
{
	self _setperk( "specialty_meleehack" );
	self _setperk( "specialty_coldblooded" );
	self _setperk( "specialty_spygame" ); 
	self _setperk( "specialty_blindeye" );
}

unsetSpectre()
{
	self _unsetperk( "specialty_meleehack" );
	self _unsetperk( "specialty_coldblooded" );
	self _unsetperk( "specialty_spygame" ); 
	self _unsetperk( "specialty_blindeye" );
}

setSpectrePro()
{
}

unsetSpectrePro()
{
}

// JUICED: give a speed boost for a set amount of time
setJuiced()
{
	self endon( "death" );
	self endon( "faux_spawn" );
	self endon( "disconnect" );
	self endon( "unset_juiced" );
	level endon( "end_game" );
	
	self.isJuiced = true;
	self.moveSpeedScaler = 1.25;
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );
	
	if ( level._splitscreen )
	{
		yOffset = 56;
		iconSize = 21; // 32/1.5
	}
	else
	{
		yOffset = 80;
		iconSize = 32;
	}

	self.juicedTimer = createTimer( "hudsmall", 1.0 );
	self.juicedTimer setPoint( "CENTER", "CENTER", 0, yOffset );
	self.juicedTimer setTimer( 7.0 );
	self.juicedTimer.color = (.8,.8,0);
	self.juicedTimer.archived = false;
	self.juicedTimer.foreground = true;

	self.juicedIcon = self createIcon( "specialty_painkiller", iconSize, iconSize );
	self.juicedIcon.alpha = 0;
	self.juicedIcon setParent( self.juicedTimer );
	self.juicedIcon setPoint( "BOTTOM", "TOP" );
	self.juicedIcon.archived = true;
	self.juicedIcon.sort = 1;
	self.juicedIcon.foreground = true;
	self.juicedIcon fadeOverTime( 1.0 );
	self.juicedIcon.alpha = 0.85;
	
	self thread unsetJuicedOnDeath();
	self thread unsetJuicedOnRide();
	
	wait 5;

	if( IsDefined( self.juicedIcon ) )
	{
		self.juicedIcon	fadeOverTime( 2.0 );
		self.juicedIcon.alpha = 0.0;
	}	
	if( IsDefined( self.juicedTimer ) )
	{
		self.juicedTimer fadeOverTime( 2.0 );
		self.juicedTimer.alpha = 0.0;
	}

	wait 2;

	self unsetJuiced();
}

unsetJuiced( death )
{	
	if ( !isDefined( death ) )
	{
		assert( isAlive(self) );
		
		self.moveSpeedScaler = 1;
				
		assert( isdefined(self.moveSpeedScaler) );
		self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );
	}

	if( IsDefined( self.juicedIcon ) )
	{
		self.juicedIcon	Destroy();
	}	
	if( IsDefined( self.juicedTimer ) )
	{
		self.juicedTimer Destroy();
	}
	
	self.isJuiced = undefined;
	
	self notify("unset_juiced");
}

unsetJuicedOnRide()
{
	self endon ( "disconnect" );
	self endon ( "unset_juiced" );
	
	for ( ;; )
	{
		wait( 0.05 );
		
		if ( self isUsingRemote() )
		{
			self thread unsetJuiced();
			break;
		}
	}
	
}

unsetJuicedOnDeath()
{
	self endon ( "disconnect" );
	self endon ( "unset_juiced" );
	
	self waittill_any ( "death", "faux_spawn" );
	
	self thread unsetJuiced( true );
}
// END JUICED
