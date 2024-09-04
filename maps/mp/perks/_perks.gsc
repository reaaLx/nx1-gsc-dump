#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\perks\_perkfunctions;
#include common_scripts\_portable_radar;

colorPerkReady = ( 0.568, 0.902, 0.568 );
colorPerkUsing = ( 0.568, 0.902, 0.568 );
colorPerkRecharging = ( 0.902, 0.251, 0.098 );

init()
{
	level._perkFuncs = [];

	precacheShader( "combathigh_overlay" );	
	precacheShader( "specialty_painkiller" );
	precacheShader( "compassping_revenge" );
	precacheShader( "compassping_lidar" );
	precacheShader( "compassping_enemy" );

	precacheModel( "weapon_riot_shield_mp" );	
	precacheModel( "viewmodel_riot_shield_mp" );
	precacheString( &"MPUI_CHANGING_KIT" );

	//level.spawnGlowSplat = loadfx( "misc/flare_ambient_destroy" );

	level._spawnGlowModel["enemy"] = "mil_emergency_flare_mp";
	level._spawnGlowModel["friendly"] = "mil_emergency_flare_mp";
	level._spawnGlow["enemy"] = loadfx( "misc/flare_ambient" );
	level._spawnGlow["friendly"] = loadfx( "misc/flare_ambient_green" );
	level._c4Death = loadfx( "explosions/oxygen_tank_explosion" );

	level._spawnFire = loadfx( "props/barrelexp" );
	
	precacheModel( level._spawnGlowModel["friendly"] );
	precacheModel( level._spawnGlowModel["enemy"] );
	
	precacheString( &"MP_DESTROY_TI" );
	
	precacheShaders();

	level._effect["ricochet"] = loadfx( "impacts/large_metalhit_1" );

	// perks that currently only exist in script: these will error if passed to "setPerk", etc... CASE SENSITIVE! must be lower
	level._scriptPerks = [];
	level._perkSetFuncs = [];
	level._perkUnsetFuncs = [];
	level._fauxPerks = [];

	level._scriptPerks["specialty_blastshield"] = true;
	level._scriptPerks["_specialty_blastshield"] = true;
	level._scriptPerks["specialty_akimbo"] = true;
	level._scriptPerks["specialty_siege"] = true;
	level._scriptPerks["specialty_falldamage"] = true;
	level._scriptPerks["specialty_fmj"] = true;
	level._scriptPerks["specialty_shield"] = true;
	level._scriptPerks["specialty_feigndeath"] = true;
	level._scriptPerks["specialty_shellshock"] = true;
	level._scriptPerks["specialty_delaymine"] = true;
	level._scriptPerks["specialty_localjammer"] = true;
	level._scriptPerks["specialty_thermal"] = true;
	level._scriptPerks["specialty_finalstand"] = true;
	level._scriptPerks["specialty_blackbox"] = true;
	level._scriptPerks["specialty_steelnerves"] = true;
	level._scriptPerks["specialty_flashgrenade"] = true;
	level._scriptPerks["specialty_smokegrenade"] = true;
	level._scriptPerks["specialty_concussiongrenade"] = true;
	level._scriptPerks["specialty_challenger"] = true;
	level._scriptPerks["specialty_tacticalinsertion"] = true;
	level._scriptPerks["specialty_saboteur"] = true;
	level._scriptPerks["specialty_endgame"] = true;
	level._scriptPerks["specialty_rearview"] = true;
	level._scriptPerks["specialty_hardline"] = true;
	level._scriptPerks["specialty_ac130"] = true;
	level._scriptPerks["specialty_sentry_minigun"] = true;
	level._scriptPerks["specialty_predator_missile"] = true;
	level._scriptPerks["specialty_helicopter_minigun"] = true;
	level._scriptPerks["specialty_tank"] = true;
	level._scriptPerks["specialty_precision_airstrike"] = true;
	level._scriptPerks["specialty_bling"] = true;
	level._scriptPerks["specialty_carepackage"] = true;
	level._scriptPerks["specialty_onemanarmy"] = true;
	level._scriptPerks["specialty_littlebird_support"] = true;
	level._scriptPerks["specialty_primarydeath"] = true;
	level._scriptPerks["specialty_secondarybling"] = true;	
	level._scriptPerks["specialty_combathigh"] = true;
	level._scriptPerks["specialty_c4death"] = true;
	level._scriptPerks["specialty_explosivedamage"] = true;
	level._scriptPerks["specialty_copycat"] = true;
	level._scriptPerks["specialty_laststandoffhand"] = true;
	level._scriptPerks["specialty_dangerclose"] = true;
	level._scriptPerks["specialty_bulletpenetration"] = true;

	level._scriptPerks["specialty_extraspecialduration"] = true;
	level._scriptPerks["specialty_rollover"] = true;
	level._scriptPerks["specialty_armorpiercing"] = true;
	level._scriptPerks["specialty_omaquickchange"] = true;

	level._scriptPerks["specialty_equipmenthack"] = true;

	level._scriptPerks["specialty_fasthealthregen"] = true;
	level._scriptPerks["specialty_flakjacket"] = true;

	level._scriptPerks["specialty_spectre"] = true;
	level._scriptPerks["specialty_spectrepro"] = true;
	
	level._scriptPerks["_specialty_rearview"] = true;
	level._scriptPerks["_specialty_onemanarmy"] = true;
	
	level._fauxPerks["specialty_tacticalinsertion"] = true;
	level._fauxPerks["specialty_shield"] = true;

	level._scriptPerks["specialty_netpainkiller"] = true;
	level._scriptPerks["specialty_dishclip"] = true;

	level._scriptPerks["specialty_revenge"] = true;
	level._scriptPerks["specialty_uav"] = true;
	
	level._scriptPerks["specialty_rechargetest"] = true;
	
	level._scriptPerks["specialty_portable_radar"] = true;
	

	level._scriptPerks["specialty_loaded"] = true;

	level._scriptPerks["specialty_fasterlockon"] = true;
	level._scriptPerks["specialty_twoprimaries"] = true;
	level._scriptPerks["specialty_twoprimariesoffhand"] = true;
	level._scriptPerks["specialty_twoprimarieslethal"] = true;
	level._scriptPerks["specialty_twoprimariesholder"] = true;
	level._scriptPerks["specialty_marksman"] = true;

	level._scriptPerks["specialty_ninjaholder"] = true;
	level._scriptPerks["specialty_marathonholder"] = true;

	level._scriptPerks["specialty_explosivedamage"] = true;

	level._scriptPerks["specialty_quickdrawholder"] = true;

	level._scriptPerks["specialty_gasmask"] = true;
	level._scriptPerks["specialty_fastcarepackagerecovery"] = true;

	level._scriptPerks["specialty_paint"] = true;
	level._scriptPerks["specialty_paint_pro"] = true;

	level._scriptPerks["specialty_juiced"] = true;
	

	/*
	level.perkSetFuncs[""] = ::;
	level.perkUnsetFuncs[""] = ::;
	*/
	
	level._perkSetFuncs["specialty_bling"] = ::setBling;
	level._perkUnsetFuncs["specialty_bling"] = ::unsetBling;

	level._perkSetFuncs["specialty_twoprimaries"] = ::setTwoPrimaries;
	level._perkUnsetFuncs["specialty_twoprimaries"] = ::unsetTwoPrimaries;
	
	level._perkSetFuncs["specialty_twoprimariesholder"] = ::setTwoPrimariesHolder;
	level._perkUnsetFuncs["specialty_twoprimariesholder"] = ::unsetTwoPrimariesHolder;

	level._perkSetFuncs["specialty_equipmenthack"] = ::setEquipmentHack;
	level._perkUnsetFuncs["specialty_equipmenthack"] = ::unsetEquipmentHack;

	level._perkSetFuncs["specialty_fasterlockon"] = ::setFasterLockOn;
	level._perkUnsetFuncs["specialty_fasterlockon"] = ::unsetFasterLockOn;
	
	level._perkSetFuncs["specialty_rechargetest"] = ::setRechargeTest;
	level._perkUnsetFuncs["specialty_rechargetest"] = ::unsetRechargeTest;

	level._perkSetFuncs["specialty_blastshield"] = ::setBlastShield;
	level._perkUnsetFuncs["specialty_blastshield"] = ::unsetBlastShield;

	level._perkSetFuncs["specialty_siege"] = ::setSiege;
	level._perkUnsetFuncs["specialty_siege"] = ::unsetSiege;
	
	level._perkSetFuncs["specialty_falldamage"] = ::setFreefall;
	level._perkUnsetFuncs["specialty_falldamage"] = ::unsetFreefall;
	
	level._perkSetFuncs["specialty_localjammer"] = ::setLocalJammer;
	level._perkUnsetFuncs["specialty_localjammer"] = ::unsetLocalJammer;

	level._perkSetFuncs["specialty_thermal"] = ::setThermal;
	level._perkUnsetFuncs["specialty_thermal"] = ::unsetThermal;
	
	level._perkSetFuncs["specialty_blackbox"] = ::setBlackBox;
	level._perkUnsetFuncs["specialty_blackbox"] = ::unsetBlackBox;
	
	level._perkSetFuncs["specialty_lightweight"] = ::setLightWeight;
	level._perkUnsetFuncs["specialty_lightweight"] = ::unsetLightWeight;
	
	level._perkSetFuncs["specialty_steelnerves"] = ::setSteelNerves;
	level._perkUnsetFuncs["specialty_steelnerves"] = ::unsetSteelNerves;
	
	level._perkSetFuncs["specialty_delaymine"] = ::setDelayMine;
	level._perkUnsetFuncs["specialty_delaymine"] = ::unsetDelayMine;
			
	level._perkSetFuncs["specialty_finalstand"] = ::setFinalStand;
	level._perkUnsetFuncs["specialty_finalstand"] = ::unsetFinalStand;
	
	level._perkSetFuncs["specialty_combathigh"] = ::setCombatHigh;
	level._perkUnsetFuncs["specialty_combathigh"] = ::unsetCombatHigh;
	
	level._perkSetFuncs["specialty_challenger"] = ::setChallenger;
	level._perkUnsetFuncs["specialty_challenger"] = ::unsetChallenger;
	
	level._perkSetFuncs["specialty_saboteur"] = ::setSaboteur;
	level._perkUnsetFuncs["specialty_saboteur"] = ::unsetSaboteur;
	
	level._perkSetFuncs["specialty_endgame"] = ::setEndGame;
	level._perkUnsetFuncs["specialty_endgame"] = ::unsetEndGame;

	level._perkSetFuncs["specialty_rearview"] = ::setRearView;
	level._perkUnsetFuncs["specialty_rearview"] = ::unsetRearView;

	level._perkSetFuncs["specialty_ac130"] = ::setAC130;
	level._perkUnsetFuncs["specialty_ac130"] = ::unsetAC130;

	level._perkSetFuncs["specialty_sentry_minigun"] = ::setSentryMinigun;
	level._perkUnsetFuncs["specialty_sentry_minigun"] = ::unsetSentryMinigun;

	level._perkSetFuncs["specialty_predator_missile"] = ::setPredatorMissile;
	level._perkUnsetFuncs["specialty_predator_missile"] = ::unsetPredatorMissile;
	
	level._perkSetFuncs["specialty_tank"] = ::setTank;
	level._perkUnsetFuncs["specialty_tank"] = ::unsetTank;

	level._perkSetFuncs["specialty_precision_airstrike"] = ::setPrecision_airstrike;
	level._perkUnsetFuncs["specialty_precision_airstrike"] = ::unsetPrecision_airstrike;
	
	level._perkSetFuncs["specialty_helicopter_minigun"] = ::setHelicopterMinigun;
	level._perkUnsetFuncs["specialty_helicopter_minigun"] = ::unsetHelicopterMinigun;
	
	level._perkSetFuncs["specialty_carepackage"] = ::setCarePackage;
	level._perkUnsetFuncs["specialty_carepackage"] = ::unsetCarePackage;	

	level._perkSetFuncs["specialty_onemanarmy"] = ::setOneManArmy;
	level._perkUnsetFuncs["specialty_onemanarmy"] = ::unsetOneManArmy;	
	
	level._perkSetFuncs["specialty_littlebird_support"] = ::setLittlebirdSupport;
	level._perkUnsetFuncs["specialty_littlebird_support"] = ::unsetLittlebirdSupport;
	
	level._perkSetFuncs["specialty_c4death"] = ::setC4Death;
	level._perkUnsetFuncs["specialty_c4death"] = ::unsetC4Death;
	
	level._perkSetFuncs["specialty_tacticalinsertion"] = ::setTacticalInsertion;
	level._perkUnsetFuncs["specialty_tacticalinsertion"] = ::unsetTacticalInsertion;

	level._perkSetFuncs["specialty_juggersuit"] = ::setJuggersuit;
	level._perkUnsetFuncs["specialty_juggersuit"] = ::unsetJuggersuit;

	level._perkSetFuncs["specialty_stealthsuit"] = ::setStealthSuit;
	level._perkUnsetFuncs["specialty_stealthsuit"] = ::unsetStealthsuit;

	level._perkSetFuncs["specialty_tacsuit"] = ::setTacsuit;
	level._perkUnsetFuncs["specialty_tacsuit"] = ::unsetTacsuit;

	level._perkSetFuncs["specialty_agisuit"] = ::setAgisuit;
	level._perkUnsetFuncs["specialty_agisuit"] = ::unsetAgisuit;

	level._perkSetFuncs["specialty_jetsuit"] = ::setJetsuit;
	level._perkUnsetFuncs["specialty_jetsuit"] = ::unsetJetsuit;

	level._perkSetFuncs["specialty_fasthealthregen"] = ::setFastHealthRegen;
	level._perkUnsetFuncs["specialty_fasthealthregen"] = ::unsetFastHealthRegen;
	
	level._perkSetFuncs["specialty_flakjacket"] = ::setFlakJacket;
	level._perkUnsetFuncs["specialty_flakjacket"] = ::unsetFlakJacket;

	level._perkSetFuncs["specialty_spectre"] = ::setSpectre;
	level._perkUnsetFuncs["specialty_spectre"] = ::unsetSpectre;

	level._perkSetFuncs["specialty_spectrepro"] = ::setSpectrePro;
	level._perkUnsetFuncs["specialty_spectrepro"] = ::unsetSpectrePro;

	level._perkSetFuncs["specialty_netpainkiller"] = ::setNetPainkiller;
	level._perkUnsetFuncs["specialty_netpainkiller"] = ::unsetNetPainkiller;

	level._perkSetFuncs["specialty_dishclip"] = ::setDishClip;
	level._perkUnsetFuncs["specialty_dishclip"] = ::unsetDishClip;

	level._perkSetFuncs["specialty_revenge"] = ::setRevenge;
	level._perkUnsetFuncs["specialty_revenge"] = ::unsetRevenge;

	level._perkSetFuncs["specialty_uav"] = ::setUAV;
	level._perkUnsetFuncs["specialty_uav"] = ::unsetUAV;
	
	level._perkSetFuncs["specialty_portable_radar"] = ::setPortableRadar;
	level._perkUnsetFuncs["specialty_portable_radar"] = ::unsetPortableRadar;

	level._perkSetFuncs["specialty_quieter"] = ::setQuieter;
	level._perkUnsetFuncs["specialty_quieter"] = ::unsetQuieter;

	level._perkSetFuncs["specialty_hardline"] = ::setHardline;
	level._perkUnsetFuncs["specialty_hardline"] = ::unsetHardline;

	level._perkSetFuncs["specialty_marksman"] = ::setMarksman;
	level._perkUnsetFuncs["specialty_marksman"] = ::unsetMarksman;

	level._perkSetFuncs["specialty_ninjaholder"] = ::setNinjaholder;
	level._perkUnsetFuncs["specialty_ninjaholder"] = ::unsetNinjaholder;

	level._perkSetFuncs["specialty_explosivedamage"] = ::setExplosivedamage;
	level._perkUnsetFuncs["specialty_explosivedamage"] = ::unsetExplosivedamage;

	level._perkSetFuncs["specialty_marathonholder"] = ::setMarathonholder;
	level._perkUnsetFuncs["specialty_marathonholder"] = ::unsetMarathonholder;

	level._perkSetFuncs["specialty_quickdrawholder"] = ::setQuickdrawholder;
	level._perkUnsetFuncs["specialty_quickdrawholder"] = ::unsetQuickdrawholder;

	level._perkUseFuncs["specialty_fastcarepackagerecovery"] = ::useFastCarePackage;
	level._perkUnUseFuncs["specialty_fastcarepackagerecovery"] = ::unUseFastCarePackage;	

	level._perkUseFuncs["specialty_rollover"] = ::useRollover;
	level._perkUnUseFuncs["specialty_rollover"] = ::unUseRollover;

	level._perkSetFuncs["specialty_gasmask"] = ::setGasMask;
	level._perkUnsetFuncs["specialty_gasmask"] = ::unsetGasMask;

	level._perkSetFuncs["specialty_juiced"] = ::setJuiced;
	level._perkUnsetFuncs["specialty_juiced"] = ::unsetJuiced;

	initRechargeablePerks();
	
	initPerkDvars();

	level thread onPlayerConnect();
}

precacheShaders()
{
	precacheShader( "specialty_blastshield" );
	precacheShader( "scavenger_pickup" );
}

initRechargeablePerks()
{
	precacheItem( "xraydevice_mp" );
	
	level._scriptPerks["specialty_rechargetest"] = true;
	level._scriptPerks["specialty_Mobilityexpert"] = true;
	level._scriptPerks["specialty_Steathexpert"] = true;
	level._scriptPerks["specialty_Awarenessexpert"] = true;
	level._scriptPerks["specialty_xrayvision"] = true;
	level._scriptPerks["specialty_disruptor"] = true;
	level._scriptPerks["specialty_grapplinghook"] = true;

	level._rechargeablePerks["specialty_rechargetest"] = true;
	level._rechargeablePerks["specialty_Mobilityexpert"] = true;
	level._rechargeablePerks["specialty_Steathexpert"] = true;
	level._rechargeablePerks["specialty_Awarenessexpert"] = true;
	level._rechargeablePerks["specialty_xrayvision"] = true;
	level._rechargeablePerks["specialty_disruptor"] = true;
	level._rechargeablePerks["specialty_grapplinghook"] = true;	

	level._perkUseFuncs["specialty_rechargetest"] = ::useRechargeTest;
	level._perkUnUseFuncs["specialty_rechargetest"] = ::unUseRechargeTest;
	
	level._perkUseFuncs["specialty_grapplinghook"] = ::useGrapplingHook;
	level._perkUnUseFuncs["specialty_grapplinghook"] = ::unUseGrapplingHook;	

	level._perkUseFuncs["specialty_Mobilityexpert"] = ::useAgileAvenger;
	level._perkUnUseFuncs["specialty_Mobilityexpert"] = ::unUseAgileAvenger;

	level._perkUseFuncs["specialty_Steathexpert"] = ::useStealthAssasin;
	level._perkUnUseFuncs["specialty_Steathexpert"] = ::unUseStealthAssasin;

	level._perkUseFuncs["specialty_Awarenessexpert"] = ::useAwarenessExpert;
	level._perkUnUseFuncs["specialty_Awarenessexpert"] = ::unUseAwarenessExpert;
	
	level._perkUseFuncs["specialty_xrayvision"] = ::usexrayvision;
	level._perkUnUseFuncs["specialty_xrayvision"] = ::unUsexrayvision;
	
	level._perkUseFuncs["specialty_disruptor"] = ::useDisrputor;
	level._perkUnUseFuncs["specialty_disruptor"] = ::unUseDisruptor;

	level._defaultPerkCooldown = 20;	//a rechargeable perk can be used every perkCooldown seconds
	level._defaultPerkDuration = 5;		//a rechargeable perk will be active for PerkDuration seconds
										//the game will assert if perkDuration is > perkCooldown
	
	level._perkCooldowns["specialty_rechargetest"] = 20;
	level._perkDurations["specialty_rechargetest"] = 5;
	
	level._perkCooldowns["specialty_Mobilityexpert"] = 40;
	level._perkDurations["specialty_Mobilityexpert"] = 20;
	
	level._perkCooldowns["specialty_Steathexpert"] = 40;
	level._perkDurations["specialty_Steathexpert"] = 20;
	
	level._perkCooldowns["specialty_Awarenessexpert"] = 30;
	level._perkDurations["specialty_Awarenessexpert"] = 8;
	
	level._perkCooldowns["specialty_xrayvision"] = 50;
	level._perkDurations["specialty_xrayvision"] = 15;
	
	level._perkCooldowns["specialty_disruptor"] = 6;
	level._perkDurations["specialty_disruptor"] = 3;
	
}

monitorRechargePerkUsage()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "clear_recharge_perks" );
	
	//self notifyOnPlayerCommand( "use_rechargeable_perk", "+frag" );
	self notifyOnPlayerCommand( "use_rechargeable_perk", "+smoke" );
	
	//taking this out, its causing a problem when switching classes at the start of the match
	//self waittill( "spawned_player" );
	
	self createRechargeablePerkHudInfo();
	self thread destroyRechargeablePerkHudInfoOnDeath();
	
	//get the rechargeable perk that is currently equipped ( this is really just a name used to identify callback scripts )
	//along with its cooldown/duration timers
	
	perk			= self.rechargeablePerk;
	cooldown		= level._defaultPerkCooldown;
	duration		= level._defaultPerkDuration;
	rechargeStep	= 0.05;
	
	if( isDefined( level._perkCooldowns[perk] ))
	{
		cooldown = level._perkCooldowns[perk];
	}
	
	if( isDefined( level._perkDurations[perk] ))
	{
		duration = level._perkDurations[perk];
	}
	
	//assert that callbacks for that perk exist
	assert( isDefined( level._scriptPerks[perk] ));
	assert( isDefined( level._perkUseFuncs[perk] ));
	assert( isDefined( level._perkUnUseFuncs[perk] ));
	assert( duration < cooldown );
	
	for( ;; )
	{
		self.rechargeablePerkProgressBar.bar.color = colorPerkReady;
		self.breakRechargablePerk = false;
		
		//wait until player activates rechargeable perk
		self waittill( "use_rechargeable_perk" );
		
		rechargeTimer = 0.0;
		dechargeTimer = 0.0;

		//launch use script ( this script should turn on any special abilities )
		self [[ level._perkUseFuncs[perk] ]]();
		
		//set the ui bar to show that we are using the rechargeable perk
		self.rechargeablePerkProgressBar.bar.color = colorPerkUsing;
		
		//TagZP<NOTE> test called this functionality a bug, we currently do not need it so i am disableing it for now.
		//self thread watchForPerkBreakout();
		
		//drain the bar during the usage
		while( dechargeTimer < duration && self.breakRechargablePerk == false )
		{
			frac = 1.0 - ( dechargeTimer / duration );
			updateRechargeablePerkHudInfo( frac );
			dechargeTimer += rechargeStep;
			wait( rechargeStep );
		}
		
		self notify( "rechargeable_perk_complete" );
		
		//launch un-use script ( this script should turn off any special abilities )
		self [[ level._perkUnUseFuncs[perk] ]](); 
		
		//now wait for the cooldown to finish, re-fill the progress bar for this duration
		self.rechargeablePerkProgressBar.bar.color = colorPerkRecharging;
		waitTime = cooldown - duration;
		while( rechargeTimer < waitTime )
		{
			updateRechargeablePerkHudInfo( rechargeTimer / waitTime );
			rechargeTimer += rechargeStep;
			wait( rechargeStep );
		}
		
		updateRechargeablePerkHudInfo( 1.0 );
	}
}

monitorRechargePerkUsageNoRecharge()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "clear_recharge_perks" );
	
	//self notifyOnPlayerCommand( "toggle_rechargeable_perk", "+frag" );
	self notifyOnPlayerCommand( "toggle_rechargeable_perk", "+smoke" );
	
	//taking this out, its causing a problem when switching classes at the start of the match
	//self waittill( "spawned_player" );
	
	//setup the bar in the UI
	self createRechargeablePerkHudInfo();
	self.rechargeablePerkProgressBar.bar.color = colorPerkReady;
	self thread destroyRechargeablePerkHudInfoOnDeath();
	
	//get the rechargeable perk that is currently equipped ( this is really just a name used to identify callback scripts )
	//along with its cooldown/duration timers
	
	perk			= self.rechargeablePerk;
	duration		= level._defaultPerkDuration;
	rechargeStep	= 0.1;
	
	if( isDefined( level._perkDurations[perk] ))
	{
		duration = level._perkDurations[perk];
	}
	
	//assert that callbacks for that perk exist
	assert( isDefined( level._scriptPerks[perk] ));
	assert( isDefined( level._perkUseFuncs[perk] ));
	assert( isDefined( level._perkUnUseFuncs[perk] ));
	assert( duration > 0 );
	
	//monitors how long the perk has been on for
	self.usageTimer = 0.0;

	for( ;; )
	{	
		//wait until player activates rechargeable perk
		self waittill( "toggle_rechargeable_perk" );
		
		//use this variable know if the perk is toggled on/off
		self.toggleRechargablePerk = true;
		
		//spawn off a script to watch for the toggle off.
		self thread watchForPerkToggleOff();
		
		//if our meter is empty do not allow usage
		if( self.usageTimer >= duration )
		{
			continue;
		}
		
		//Activate the perk
		self [[ level._perkUseFuncs[perk] ]]();
		
		//wait for the bar to fully drain or for the player to toggle the perk off
		while( self.usageTimer <= duration && self.toggleRechargablePerk == true )
		{
			frac = 1.0 - ( self.usageTimer / duration );
			updateRechargeablePerkHudInfo( frac );
			self.usageTimer += rechargeStep;
			wait( rechargeStep );
		}
		
		//if we have exhausted the entire bar
		if( self.usageTimer >= duration )
		{
			self notify( "rechargeable_perk_complete" );
			self.rechargeablePerkProgressBar.bar.color = colorPerkRecharging;
		}

		//De-Activate the perk
		self [[ level._perkUnUseFuncs[perk] ]]();
		}
}

//call this on the player to add more energy into their energy pool
//do not pass in any amount to refil the bar to full
givePerkEnergy( amount )
{
	if( !isDefined( self.usageTimer ))
	{
		return;
	}
	
	if( !isDefined( amount ))
	{
		if( isDefined( self.usageTimer ))
		{
			//refill the bar, i.e. the player has used 0.0 time out of their energy pool
			self.usageTimer = 0.0;
		}
	}
	else
	{
		self.usageTimer -= amount;
		
		//clamp to 0.0
		if( self.usageTime < 0.0 )
		{
			self.usageTime = 0.0;
		}
	}
}

watchForPerkBreakout()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "clear_recharge_perks" );
	
	msg = self waittill_any_return( "use_rechargeable_perk", "rechargeable_perk_complete" );
	
	if( msg == "use_rechargeable_perk" )
	{
		self.breakRechargablePerk = true;
	}
}

watchForPerkToggleOff()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "rechargeable_perk_complete" );
	self endon( "clear_recharge_perks" );
	
	msg = self waittill_any_return( "toggle_rechargeable_perk" );
	if( msg == "toggle_rechargeable_perk" && self.toggleRechargablePerk == true )
	{
		self.toggleRechargablePerk = false;
	}
}

createRechargeablePerkHudInfo()  
{
	//	Recharge bar
	self.rechargeablePerkProgressBar = self createRechargeBar( colorPerkReady, 100, 6 );
	//self.rechargeablePerkProgressBar setPoint("CENTER", "BOTTOM", 290, -66 );
	self.rechargeablePerkProgressBar setPoint("LEFT", "TOP", -407, 123 );
	self.rechargeablePerkProgressBar.alpha = 0.65;
	self.rechargeablePerkProgressBar.bar.alpha = 0.65;
	//self.rechargeablePerkProgressBar.layer = "visor";
	
	self updateRechargeablePerkHudInfo( 1.0 );
}

createRechargeBar( color, width, height, flashFrac )
{
	barElem = newClientHudElem(	self );
	barElem.x = 0 ;
	barElem.y = 0;
	barElem.frac = 0;
	barElem.color = color;
	barElem.sort = -2;
	barElem.shader = "progress_bar_fill";
	barElem setShader( "progress_bar_fill", width, height );
	barElem.hidden = false;
	barElem.hidewheninmenu = true;
	if ( isDefined( flashFrac ) )
	{
		barElem.flashFrac = flashFrac;
	}
	//barElem.layer = "visor";
	
	barElemBG = newClientHudElem( self );
	barElemBG.elemType = "bar";
	barElemBG.width = width;
	barElemBG.height = height;
	barElemBG.xOffset = 0;
	barElemBG.yOffset = 0;
	barElemBG.bar = barElem;
	barElemBG.children = [];
	barElemBG.sort = -3;
	barElemBG.color = (0,0,0);
	barElemBG.alpha = 0.5;
	barElemBG setParent( level._uiParent );
	barElemBG setShader( "progress_bar_bg", width + 4, height + 4 );
	barElemBG.hidden = false;
	barElemBG.hidewheninmenu = true;
	
	return barElemBG;
}

destroyRechargeablePerkHudInfoOnDeath()
{
	msg = self waittill_any_return( "death", "clear_recharge_perks" );
	self destroyRechargeablePerkHudInfo();
}

destroyRechargeablePerkHudInfo()
{
	if( isDefined( self.rechargeablePerkProgressBar ))
	{
		self.rechargeablePerkProgressBar destroyElem();
	}
}

updateRechargeablePerkHudInfo( percent )
{	
	self.rechargeablePerkProgressBar updateBar( percent );
}

monitorXrayTest()
{
	self endon( "death" );
	self endon( "clear_recharge_perks" );
	self notifyOnPlayerCommand( "activate_xray", "+smoke" );
	
	println( "monitor xray test" );
	for( ;; )
	{
		self waittill( "activate_xray" );
		
		//dont activate if the player is using the mini-uav
/*		if( self hasWeapon( level._miniuav_player_weapons[ "view_model_weapon" ] ))
		{
			continue;
		}
*/
		self xraySequence();
	}
}

xraySequence()
{
	self endon( "death" );
	self endon( "clear_recharge_perks" );
	
	maxDuration = 1000.0;
	primary = self.primaryWeapon;
	
	//self takeWeapon( primary );

	self giveWeapon( "xraydevice_mp" );
	self switchToWeapon( "xraydevice_mp" );
	wait( 0.5 );
	
	self SetXRayVision ( true );
	self thread xrayUpdateBeep();
	
	wait( 0.5 );
	
	totalWait = 0.0;
	//hold out until the button is released
	for( ;; )
	{
		if( self SecondaryOffhandButtonPressed() && totalWait < maxDuration )
		{
			wait 0.05;
			totalWait += 0.05;
		}
		else
		{
			break;
		}
	}
	
	self notify( "xray_off" );
	self SetXRayVision ( false );
	self takeWeapon( "xraydevice_mp" );
	self switchToWeapon( primary );
}

givePerk( perkName )
{	
	if ( IsSubStr( perkName, "_mp" ) )
	{
		if ( perkName == "frag_grenade_mp" )
			self SetOffhandPrimaryClass( "frag" );
		if ( perkName == "throwingknife_mp" )
			self SetOffhandPrimaryClass( "throwingknife" );
		if ( perkName == "hulc_rocket_mp" )
			self SetOffhandPrimaryClass( "hulc_rocket" );
		if ( perkName == "hulc_lidar_mp" )
			self SetOffhandPrimaryClass( "hulc_lidar" );
		if ( perkName == "hulc_frag_mp" )
			self SetOffhandPrimaryClass( "hulc_frag" );
		if ( perkName == "hulc_semtex_mp" )
			self SetOffhandPrimaryClass( "hulc_semtex" );
		if ( perkName == "hulc_n00b_mp" )
			self SetOffhandPrimaryClass( "hulc_n00b" );

		self _giveWeapon( perkName, 0 );

		//Un-comment the following section to give the HULC suit one extra lethal gredane
		if ( self hasPerk ( "specialty_twoprimaries", false ))
		{
			self SetWeaponAmmoStock( perkName, (WeaponStartAmmo ( perkName ) + 1));
		}
		else
		{
			self giveStartAmmo( perkName );
		}
		
		self setPerk( perkName, false );
		return;
	}

	if ( isSubStr( perkName, "specialty_null" ) || isSubStr( perkName, "specialty_weapon_" ) )
	{
		self setPerk( perkName, false );
		return;
	}
		
	self _setPerk( perkName );

}


validatePerk( perkIndex, perkName )
{	
	if ( getDvarInt ( "scr_game_perks" ) == 0 )
	{
		if ( tableLookup( "mp/perkTable.csv", 1, perkName, 5 ) != "equipment" )
			return "specialty_null";
	}

	/* Validation disabled for now	
	if ( tableLookup( "mp/perkTable.csv", 1, perkName, 5 ) != ("perk"+perkIndex) )
	{
		println( "^1Warning: (" + self.name + ") Perk " + perkName + " is not allowed for perk slot index " + perkIndex + "; replacing with no perk" );
		return "specialty_null";
	}
	*/

	return perkName;
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		player thread onPlayerSpawned();		
	}
}


onPlayerSpawned()
{
	self endon( "disconnect" );

	self.perks = [];
	self.rechargeablePerks = [];
	self.weaponList = [];
	self.omaClassChanged = false;
	
	for( ;; )
	{
		self waittill( "spawned_player" );

		self.omaClassChanged = false;

		self thread gambitUseTracker();
	}
}


drawLine( start, end, timeSlice )
{
	drawTime = int(timeSlice * 20);
	for( time = 0; time < drawTime; time++ )
	{
		line( start, end, (1,0,0),false, 1 );
		wait ( 0.05 );
	}
}


cac_modified_damage( victim, attacker, damage, meansofdeath, weapon, impactPoint, impactDir, hitLoc )
{
	assert( isPlayer( victim ) );
	assert( isDefined( victim.team ) );
	
	damageAdd = 0;

	if ( isPrimaryDamage( meansOfDeath ) )
	{	
		assert( isDefined( attacker ) );

	// show the victim on the minimap for N seconds
		if( IsPlayer( attacker ) && attacker _hasPerk( "specialty_paint_pro" ) && !isKillstreakWeapon( weapon ) )
		{
			victim thread maps\mp\perks\_perkfunctions::setPainted( attacker.team );
		}

		if ( isPlayer( attacker ) && weaponInheritsPerks( weapon ) && attacker _hasPerk( "specialty_bulletdamage" ) && ( victim _hasPerk( "specialty_armorvest" ) || victim _hasPerk("specialty_juggersuit") || victim _hasPerk("specialty_netpainkiller") ))
			damageAdd += 0;
		else if ( isPlayer( attacker ) && weaponInheritsPerks( weapon ) && attacker _hasPerk( "specialty_bulletdamage" ) )
			damageAdd += damage*level._bulletDamageMod;
		else if ( isPlayer( attacker ) && weaponInheritsPerks( weapon ) && attacker _hasPerk( "specialty_armorpiercing" ) && (victim _hasPerk("specialty_armorvest" )) )
			damageAdd += 0;
		else if ( (victim _hasPerk("specialty_armorvest")) || (victim _hasPerk("specialty_netpainkiller")) )
			damageAdd -= damage*(1-level._armorVestMod);
		else if ( victim _hasPerk("specialty_juggersuit") )
		{
			damageAdd -= damage*(1-level._juggersuitMod);
		}

		if ( isPlayer( attacker ) && attacker _hasPerk( "specialty_fmj" ) && victim _hasPerk ( "specialty_armorvest" ) )
			damageAdd += damage*level._hollowPointDamageMod;	
	}
	else if ( isExplosiveDamage( meansOfDeath ) )
	{

		if( IsPlayer( attacker ) && attacker != victim && attacker _hasPerk( "specialty_paint" ) && !isKillstreakWeapon( weapon ) )
		{
			victim thread maps\mp\perks\_perkfunctions::setPainted( attacker.team );
		}

		if ( isPlayer( attacker ) && weaponInheritsPerks( weapon ) && attacker _hasPerk( "specialty_explosivedamage" ) && victim _hasPerk( "_specialty_blastshield" ) )
			damageAdd += 0;
		else if ( isPlayer( attacker ) && weaponInheritsPerks( weapon ) && attacker _hasPerk( "specialty_explosivedamage" ) )
			damageAdd += damage*level._explosiveDamageMod;
		else if( victim _hasPerk("specialty_juggersuit") )
		{
			damageAdd -= damage*(1-level._juggersuitExplosiveDamageMod);
		}
		else if( victim _hasPerk("specialty_flakjacket") )
		{
			damageAdd -= damage*(1-level._flakJacketMod);
		}
		else if ( victim _hasPerk( "_specialty_blastshield" ) )
			damageAdd -= damage*(1-level._blastShieldMod);
			
		if ( isKillstreakWeapon( weapon ) && isPlayer( attacker ) && attacker _hasPerk("specialty_dangerclose") )
			damageAdd += damage*level._dangerCloseMod;
	}
	else if (meansOfDeath == "MOD_FALLING")
	{
		if ( victim _hasPerk( "specialty_falldamage" ) )
		{	
			//eventually set a msg to do a roll
			damageAdd = 0;
			damage = 0;
		}	
	}
	else if (meansOfDeath == "MOD_MELEE" )
	{
		// modify melee damage
		if ( isPlayer( attacker ) && weaponInheritsPerks( weapon ) && attacker _hasPerk( "specialty_armorpiercing" ) && (victim _hasPerk("specialty_armorvest" )) )
		{
			damageAdd = 0;
		}
		else if ( victim _hasPerk( "specialty_armorvest" ) ) 
		{
			damageAdd -= damage*(1-level._armorvestMeleeDamageMod);
		}
		else if ( victim _hasPerk("specialty_juggersuit" ) )
		{
			damageAdd -= damage*(1-level._juggersuitMeleeDamageMod);
		}
	}
	else if (meansofDeath == "MOD_IMPACT" )
	{
		// modify throwing knife damage
		if ( victim _hasPerk("specialty_armorvest" ) )
		{
			damageAdd -= damage*(1-level._armorvestImpactDamageMod);
		}
		else if ( victim _hasPerk("specialty_juggersuit" ) )
		{
			damageAdd -= damage*(1-level._juggersuitImpactDamageMod);
		}
	}

	if ( ( victim.xpScaler == 2 && isDefined( attacker ) ) && ( isPlayer( attacker ) || attacker.classname == "scrip_vehicle" ) )
		damageAdd += 200;
	
	if ( victim _hasperk( "specialty_combathigh" ) )
	{
		if ( IsDefined( self.damageBlockedTotal ) && (!level._teamBased || (isDefined( attacker ) && isDefined( attacker.team ) && victim.team != attacker.team)) )
		{
			damageTotal = damage + damageAdd;
			damageBlocked = (damageTotal - ( damageTotal / 3 ));
			self.damageBlockedTotal += damageBlocked;
			
			if ( self.damageBlockedTotal >= 101 )
			{
				self notify( "combathigh_survived" );
				self.damageBlockedTotal = undefined;
			}
		}

		if ( weapon != "throwingknife_mp" )
		{
			switch ( meansOfDeath )
			{
				case "MOD_FALLING":
				case "MOD_MELEE":
					break;
				default:
					damage = damage/3;
					damageAdd = damageAdd/3;
					break;
			}
		}
	}	
	
	return int( damage + damageAdd );
}

initPerkDvars()
{	
	level._bulletDamageMod = getIntProperty( "perk_bulletDamage", 40 )/100;			// increased bullet damage by this %
	level._hollowPointDamageMod = getIntProperty( "perk_hollowPointDamage", 65 )/100;	// increased bullet damage by this %
	level._armorVestMod = getIntProperty( "perk_armorVest", 100 )/100;					// percentage of damage you take in the Trophy Suit
	level._armorvestMeleeDamageMod = getIntProperty( "perk_armorvest_melee_damage", 50 )/100; // percentage of melee damage you take in the Trophy Suit
	level._armorvestImpactDamageMod = getIntProperty( "perk_armorvest_impact_damage", 50 )/100; // percentage of impact (throwing knife and others) damage you take in the Trophy suit
	level._juggersuitMod = getIntProperty( "perk_juggersuit", 8 )/100;					// percentage of bullet damage you take in the jugger suit
	level._juggersuitExplosiveDamageMod = getIntProperty( "perk_juggersuit_explosive_damage", 8 )/100;	// percentage of explosive damage you take in the jugger suit
	level._juggersuitMeleeDamageMod = getIntProperty( "perk_juggersuit_melee_damage", 20 )/100; // percentage of melee damage you take in the jugger suit
	level._juggersuitImpactDamageMod = getIntProperty( "perk_juggersuit_impact_damage", 20 )/100; // percentage of impact (throwing knife and others) damage you take in the jugger suit
	level._explosiveDamageMod = getIntProperty( "perk_explosiveDamage", 40 )/100;		// increased explosive damage by this %
	level._blastShieldMod = getIntProperty( "perk_blastShield", 45 )/100;					// percentage of damage you take
	level._riotShieldMod = getIntProperty( "perk_riotShield", 100 )/100;
	level._dangerCloseMod = getIntProperty( "perk_dangerClose", 100 )/100;
	level._armorPiercingMod = getIntProperty( "perk_armorPiercingDamage", 40 )/100;			// increased bullet damage by this %
	level._flakJacketMod = getIntProperty( "perk_flakjacket", 45 )/100;			// percentage of explosive damage you take with the flakjacket perk
}

// CAC: Selector function, calls the individual cac features according to player's class settings
// Info: Called every time player spawns during loadout stage
cac_selector()
{
	perks = self.specialty;

	/*
	self.detectExplosives = false;

	if ( self _hasPerk( "specialty_detectexplosive" ) )
		self.detectExplosives = true;
		
	maps\mp\gametypes\_weapons::setupBombSquad();
	*/
}


gambitUseTracker()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );

	if ( getDvarInt ( "scr_game_perks" ) != 1 )
		return;
		
	gameFlagWait( "prematch_done" );

	self notifyOnPlayerCommand( "gambit_on", "+frag" );
}