//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  The Lock-Seek-Die killstreak                                 **
//             (1) Activated by pressing right on D-Pad.                    **
//             (2) In the air, player can use the reticle to target enemy   **
//                 players.                                                 **
//             (3) Once the enemy player is locked, there will be an        **
//                 animated lock box around that player.                    **
//             (4) Once the player pulls RT, two large groups of missiles   **
//                 will be fired.                                           **
//             (5) From these two large groups, 32 smaller missiles will    **
//                 be released.                                             **
//             (6) Some of those missiles will be guided toward the locked  **
//                 enemy while other will shoot straight to the ground.     **
//                                                                          **
//    This script is organized into six major components:                   **
//                                                                          ** 
//    Components                                                            **
//    -------------------------------------------------------------------   **
//    Main logic for the killstreak                                         **    
//    FX functions for LSD missiles                                         **
//    LSD specific HUD element functions                                    **
//    Pathing logic                                                         **
//    House-keeping and miscelaneous functions                              **
//    Debug functions                                                       **
//                                                                          **
//    Created: June 9th, 2011 - James Chen                                  **
//                                                                          **
//***************************************************************************/

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

LSD_ANIM_LENGTH = 4.0;   //The length for the LSD missile animation
BEGINNING_TAG_NUMBER_MISSILE_FIRING = 33;   //Beginning tag index for the LSD missile firing 
ENDING_TAG_NUMBER_MISSILE_FIRING = 45;    //Ending tag index for the LSD missile firing
RADIUS_FOR_LSD_TARGETING = 500;    //Distance from player's eye trace within which the enemy should be locked
BEGINNING_TAG_NUMBER_LOCK_BOX = 0;   //Beginning tag index for the LSD lock box headicon 
ENDING_TAG_NUMBER_LOCK_BOX = 21;    //Ending tag index for the LSD lock box headicon

init()
{	
	path_start = getentarray( "LSD_start", "targetname" ); 		// start pointers, point to the actual start node on path
	loop_start = getentarray( "LSD_Loop_start", "targetname" ); 

	level._killstreakFuncs["lockseekdie"] = ::noLockSeekDieAvailable;

	if ( !path_start.size && !loop_start.size)
		return;

	level._LSD_types = [];

	PrecacheShader("mp_lsd_target_anim_000");
	PrecacheShader("mp_lsd_target_anim_001");
	PrecacheShader("mp_lsd_target_anim_002");
	PrecacheShader("mp_lsd_target_anim_003");
	PrecacheShader("mp_lsd_target_anim_004");
	PrecacheShader("mp_lsd_target_anim_005");
	PrecacheShader("mp_lsd_target_anim_006");
	PrecacheShader("mp_lsd_target_anim_007");
	PrecacheShader("mp_lsd_target_anim_008");
	PrecacheShader("mp_lsd_target_anim_009");
	PrecacheShader("mp_lsd_target_anim_010");
	PrecacheShader("mp_lsd_target_anim_011");
	PrecacheShader("mp_lsd_target_anim_012");
	PrecacheShader("mp_lsd_target_anim_013");
	PrecacheShader("mp_lsd_target_anim_014");
	PrecacheShader("mp_lsd_target_anim_015");
	PrecacheShader("mp_lsd_target_anim_016");
	PrecacheShader("mp_lsd_target_anim_017");
	PrecacheShader("mp_lsd_target_anim_018");
	PrecacheShader("mp_lsd_target_anim_019");
	PrecacheShader("mp_lsd_target_anim_020");
	PrecacheShader("mp_lsd_target_anim_021");
	PrecacheShader("proto_nx_target_cursor");
	precacheShader("mp_lsd_target_idle");
	PrecacheItem( "LSDNightRavenMissile_mp" );
	PrecacheItem( "LSDGuidedMissile_mp" );
	precacheModel( "proto_vehicle_night_raven_missiles" );
	precacheMpAnim( "proto_nx_vh_night_raven_missiles_fire" );

	level._effect[ "afterburner_ignite" ]							= loadfx( "nx/fire/nx_jet_afterburner_ignite_pod" );
	level._effect[ "nx_smoke_nightraven_missile_eject" ]			= loadfx( "nx/smoke/nx_smoke_nightraven_missile_eject" );
	level._effect[ "nx_smoke_nightraven_panels_off" ]				= loadfx( "nx/smoke/nx_smoke_nightraven_panels_off" );
	level._effect[ "nx_smoke_geotrail_nightraven" ]					= loadfx( "nx/smoke/nx_smoke_geotrail_nightraven" );

	precacheNightRaven( "proto_vehicle_night_raven", "nightraven" );
	precacheitem( "lock_seek_die_mp" );
	precacheVehicle( "LSD_nightraven_mp" );
	precacheString( &"MP_CIVILIAN_AIR_TRAFFIC" );
	precacheString( &"MP_LSD_WARNING" ); 
	
	level._raven = undefined;
	
	level._LSD_start_nodes = getEntArray( "LSD_start", "targetname" );
	assertEx( level._LSD_start_nodes.size, "No \"LSD_start\" nodes found in map!" );

	level._LSD_loop_nodes = getEntArray( "LSD_Loop_start", "targetname" );
	assertEx( level._LSD_loop_nodes.size, "No \"LSD_Loop_start\" nodes found in map!" );

	level._LSD_leave_nodes = getEntArray( "LSD_leave", "targetname" );
	assertEx( level._LSD_leave_nodes.size, "No \"LSD_leave\" nodes found in map!" );

	level._LSD_crash_nodes = getEntArray( "LSD_crash_start", "targetname" );
	assertEx( level._LSD_crash_nodes.size, "No \"LSD_crash_start\" nodes found in map!" );

	level._LSD_maxhealth 	= 1500;	// max health of the NightRaven
	level._LSD_debug 		= 0;	// debug mode, draws debugging info on screen
	
	level._LSD_targeting_delay 	= 0.5;	// targeting delay

	level._LSD_visual_range 	= 3500;	// distance radius NightRaven will acquire targets (see)
			
	level._LSD_target_recognition 		= 0.5;		// percentage of the player's body the NightRaven sees before it labels him as a target

	level._LSD_armor_bulletdamage 		= 0.3;		// damage multiplier to bullets onto NightRaven's armor
	
	level._LSD_attract_strength 		= 1000;
	level._LSD_attract_range 			= 4096;	
	
	level._LSD_angle_offset 			= 90;
	level._LSD_forced_wait 				= 0;

	// NightRaven fx
	level._raven_fx["explode"]["death"] = [];
	level._raven_fx["explode"]["large"] = loadfx ("explosions/helicopter_explosion_secondary_small");
	level._raven_fx["explode"]["medium"] = loadfx ("explosions/aerial_explosion");
	level._raven_fx["smoke"]["trail"] = loadfx ("smoke/smoke_trail_white_heli");
	level._raven_fx["fire"]["trail"]["medium"] = loadfx ("fire/fire_smoke_trail_L_emitter");
	level._raven_fx["fire"]["trail"]["large"] = loadfx ("fire/fire_smoke_trail_L");

	level._raven_fx["damage"]["light_smoke"] = loadfx ("smoke/smoke_trail_white_heli_emitter");
	level._raven_fx["damage"]["heavy_smoke"] = loadfx ("smoke/smoke_trail_black_heli_emitter");
	level._raven_fx["damage"]["on_fire"] = loadfx ("fire/fire_smoke_trail_L_emitter");

	level._raven_fx["light"]["left"] = loadfx( "misc/aircraft_light_wingtip_green" );
	level._raven_fx["light"]["right"] = loadfx( "misc/aircraft_light_wingtip_red" );
	level._raven_fx["light"]["belly"] = loadfx( "misc/aircraft_light_red_blink" );
	level._raven_fx["light"]["tail"] = loadfx( "misc/aircraft_light_white_blink" );

	level._fx_LSD_dust = loadfx ("treadfx/heli_dust_default");
	level._fx_LSD_water = loadfx ("treadfx/heli_water");

	makeLSDType( "nightraven", "explosions/helicopter_explosion_mi28_flying", ::RavendefaultLightFX );
	addAirExplosion( "nightraven", "explosions/aerial_explosion_mi28_flying_mp" );

	level._killstreakFuncs["lockseekdie"] = ::useLockSeekDie;
	
	level._LSDDialog["tracking"][0] = "ac130_fco_moreenemy";
	level._LSDDialog["tracking"][1] = "ac130_fco_getthatguy";
	level._LSDDialog["tracking"][2] = "ac130_fco_guyrunnin";
	level._LSDDialog["tracking"][3] = "ac130_fco_gotarunner";
	level._LSDDialog["tracking"][4] = "ac130_fco_personnelthere";
	level._LSDDialog["tracking"][5] = "ac130_fco_rightthere";
	level._LSDDialog["tracking"][6] = "ac130_fco_tracking";

	level._LSDDialog["locked"][0] = "ac130_fco_lightemup";
	level._LSDDialog["locked"][1] = "ac130_fco_takehimout";
	level._LSDDialog["locked"][2] = "ac130_fco_nailthoseguys";

	level._lastLSDDialogTime = 0;	
	
	//queueCreate( "NightRaven" );
	level._queues[ "NightRaven" ] = [];
}

precacheNightRaven( model, LSDType )
{
	//println ( "precacheNightRaven" );
	deathfx = loadfx ("explosions/tanker_explosion");

	precacheModel( model );
	
	level._LSD_types[model] = LSDType;
	
	/******************************************************/
	/*					SETUP WEAPON TAGS				  */
	/******************************************************/
	
	level._cobra_missile_models = [];
	level._cobra_missile_models["cobra_Hellfire"] = "projectile_hellfire_missile";

	precachemodel( level._cobra_missile_models["cobra_Hellfire"] );
	
	// NightRaven sounds:
	level._LSD_sound["allies"]["hit"] = "cobra_helicopter_hit";
	level._LSD_sound["allies"]["hitsecondary"] = "cobra_helicopter_secondary_exp";
	level._LSD_sound["allies"]["damaged"] = "cobra_helicopter_damaged";
	level._LSD_sound["allies"]["spinloop"] = "cobra_helicopter_dying_loop";
	level._LSD_sound["allies"]["spinstart"] = "cobra_helicopter_dying_layer";
	level._LSD_sound["allies"]["crash"] = "cobra_helicopter_crash";
	level._LSD_sound["allies"]["missilefire"] = "weap_cobra_missile_fire";
	level._LSD_sound["axis"]["hit"] = "cobra_helicopter_hit";
	level._LSD_sound["axis"]["hitsecondary"] = "cobra_helicopter_secondary_exp";
	level._LSD_sound["axis"]["damaged"] = "cobra_helicopter_damaged";
	level._LSD_sound["axis"]["spinloop"] = "cobra_helicopter_dying_loop";
	level._LSD_sound["axis"]["spinstart"] = "cobra_helicopter_dying_layer";
	level._LSD_sound["axis"]["crash"] = "cobra_helicopter_crash";
	level._LSD_sound["axis"]["missilefire"] = "weap_cobra_missile_fire";
}

//*******************************************************************
//           Beginning of main logic for the killstreak             *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: The callback function for the killstreak.  The killstreak should not be available if the player is in last stand.
//tagJC<NOTE>: Self is the user of the killstreak.
useLockSeekDie( lifeId )
{
	//println ( "useLockSeekDie" );
	if ( isDefined( self.lastStand ) && !self _hasPerk( "specialty_finalstand" ) )
	{
		self iPrintLnBold( &"MP_UNAVILABLE_IN_LASTSTAND" );
		return false;
	}

	return tryUseLockSeekDie( lifeId, "minigun" );
}

//tagJC<NOTE>: This is the call back function for when the level is not properly setup for the Night Raven nodes.  Return true
//             so Night Raven is removed from the killstreak queue.
//tagJC<NOTE>: Self is the user of the killstreak.
noLockSeekDieAvailable( lifeId )
{
	self iPrintLnBold ( "Night Raven is not set up for this level" );
	kID = self.pers["killstreaks"][0].kID;
	self maps\mp\killstreaks\_killstreaks::shuffleKillStreaksFILO( "lockseekdie", kID );	
	self maps\mp\killstreaks\_killstreaks::giveOwnedKillstreakItem();
	return false;
}

//tagJC<NOTE>: Performing various other tests (such as whether there is already another air-killstreak present) to determine 
//             whether the killstreak can be deployed.
//tagJC<NOTE>: Self is the user of the killstreak.
tryUseLockSeekDie( lifeId, LSDType )
{
	//println ( "tryUseLockSeekDie" );
	if ( isDefined( level._civilianJetFlyBy ) )
	{
		self iPrintLnBold( &"MP_CIVILIAN_AIR_TRAFFIC" );
		return false;
	}
	
	if ( (!isDefined( LSDType ) || LSDType == "flares") && isDefined( level._raven ) )
	{
		self iPrintLnBold( &"MP_HELI_IN_QUEUE" );
		
		if ( isDefined( LSDType ) )
			streakName = "helicopter_" + LSDType;
		else
			streakName = "helicopter";
		
		self maps\mp\killstreaks\_killstreaks::shuffleKillStreaksFILO( streakName );
		self maps\mp\killstreaks\_killstreaks::giveOwnedKillstreakItem();		
		
		queueEnt = spawn( "script_origin", (0,0,0) );
		queueEnt hide();
		queueEnt thread deleteOnEntNotify( self, "disconnect" );
		queueEnt.player = self;
		queueEnt.lifeId = lifeId;
		queueEnt.LSDType = LSDType;
		queueEnt.streakName = streakName;
		
		queueAdd( "NightRaven", queueEnt );
		
		return false;
	}
	else if ( isDefined( level._raven ) )
	{
		self iPrintLnBold( &"MP_AIR_SPACE_TOO_CROWDED" );
		return false;
	}		

	if ( isDefined( LSDType ) && LSDType == "minigun" )
	{
		self setUsingRemote( "helicopter_" + LSDType );
		result = self maps\mp\killstreaks\_killstreaks::initRideKillstreak();
		self.alreadyClearUsingRemote = false;

		if ( result != "success" )
		{
			if ( result != "disconnect" )
				self clearUsingRemote();
	
			return false;
		}

		if ( isDefined( level._raven ) )
		{
			self clearUsingRemote();
			self iPrintLnBold( &"MP_AIR_SPACE_TOO_CROWDED" );
			return false;
		}
	}


	self startNightRaven( lifeId, LSDType );
	return true;
}

//tagJC<NOTE>: Start the Lock-Seek-Die killstreak.
//tagJC<NOTE>: Self is the user of the killstreak.
startNightRaven( lifeId, LSDType )
{
	//println ( "startNightRaven" );
	if ( !isDefined( LSDType ) )
		LSDType = "";

	self _SetActionSlot( 1, "");

	eventType = "helicopter_minigun";
	
	team = self.pers["team"];
	
	startNode = level._LSD_start_nodes[ randomInt( level._LSD_start_nodes.size ) ];

	self maps\mp\_matchdata::logKillstreakEvent( eventType, self.origin );
	
	thread LSD_think( lifeId, self, startnode, self.pers["team"], LSDType );
}

//tagJC<NOTE>: spawn night raven at a start node and monitors it
LSD_think( lifeId, owner, startnode, LSD_team, LSDType )
{
	//println ( "LSD_think" );
	LSDOrigin = startnode.origin;
	LSDAngles = startnode.angles;

	vehicleType = "LSD_nightraven_mp";

	//tagJC<NOTE>: Differentiate the xmodel if eventually a different model is made based on faction
	if ( owner.team == "allies" )
		vehicleModel = "proto_vehicle_night_raven";
	else
		vehicleModel = "proto_vehicle_night_raven";

	raven = spawn_NightRaven( owner, LSDOrigin, LSDAngles, vehicleType, vehicleModel );

	if ( !isDefined( raven ) )
		return;
		
	level._raven = raven;
	raven.LSDType = LSDType;
	raven.lifeId = lifeId;
	raven.team = LSD_team;
	raven.pers["team"] = LSD_team;	
	raven.owner = owner;

	raven.maxhealth = level._LSD_maxhealth;			// max health

	raven.targeting_delay = level._LSD_targeting_delay;		// delay between per targeting scan - in seconds
	raven.primaryTarget = undefined;					// primary target ( player )
	raven.secondaryTarget = undefined;				// secondary target ( player )
	raven.attacker = undefined;						// last player that shot the NightRaven
	raven.currentstate = "ok";						// health state
	raven.hasBeenDestroyed = false;                   // new member data to prevent multiple players getting killstreak destroyed by shooting at destroyed night raven
	
	if ( LSDType == "flares" || LSDType == "minigun" )
		raven thread LSD_flares_monitor();
	
	//tagJC<NOTE>: Various loop monitoring threads running the raven
	raven thread LSD_leave_on_disconnect( owner );
	raven thread LSD_leave_on_changeTeams( owner );
	raven thread LSD_leave_on_gameended( owner );
	raven thread LSD_damage_monitor();				// monitors damage
	raven thread LSD_health();						// display NightRaven's health through smoke/fire
	raven thread LSD_existance();

	raven endon ( "NightRaven_done" );
	raven endon ( "crashing" );
	raven endon ( "leaving" );
	raven endon ( "death" );

	//tagJC<NOTE>: Initial fight into play space	

	owner thread LSDRide( lifeId, raven );
	//tagJC<NOTE>: The following thread (ported from chopper gunner) caused problem when the owner of the killstreak is killed during the deployment.  It caused the killstreak to end
	//             prematurally thus not cleaning up temp models, HUD element etc.  Leave the function in just in case.
	//raven thread LSD_leave_on_spawned( owner );

	loopNode = level._LSD_loop_nodes[ randomInt( level._LSD_loop_nodes.size ) ];	

	//raven thread LSD_targeting();
	raven LSD_fly_simple_path( startNode );
	raven thread LSD_leave_on_timeout( 40.0 );
	raven thread LSD_fly_loop_path( loopNode );
}

//tagJC<NOTE>: This is the main function that describes the behavior for this killstreak.
//tagJC<NOTE>: Self is the user of the killstreak
LSDRide( lifeId, raven )
{
	//println ( "LSDRide" );
	self.LSDFired = 0;

	self endon ( "disconnect" );
	raven endon ( "NightRaven_done" );

	self ThermalVisionOn();

	thread teamPlayerCardSplash( "used_helicopter_minigun", self );
	//self VisionSetNakedForPlayer( "black_bw", 0.75 );
	self _giveWeapon("lock_seek_die_mp");
	self SwitchToWeapon("lock_seek_die_mp");
	//self thread createIdleLSDBoxOnEnemy();

	if ( getDvarInt( "camera_thirdPerson" ) )
		self setThirdPersonDOF( false );

	raven VehicleTurretControlOn( self );

	self PlayerLinkWeaponviewToDelta( raven, "tag_player", 1.0, 180, 180, 180, 180, true );	

	raven.gunner = self;	

	self.LSDRideLifeId = lifeId;

	self thread endRideOnNightRavenDone( raven );
	
	//tagJC<NOTE>: This thread is the "locking" logic that is used to determine which players should be locked by the killstreak.
	self thread weaponLockThink( raven );
	
	self setPlayerAngles ( raven GetTagAngles( "tag_player" ) );

	//tagJC<NOTE>: Waiting for player to pull the Right Trigger and fire the missiles.
	raven waittill( "turret_fire" );

	self ThermalVisionOff();
	
	self notify ( "LSD_fired" );
	self.LSDFired = 1;

	//tagJC<NOTE>: Creating a script_model for the missiles and set it up properly.
	missileScriptModel = spawn ( "script_model", raven GetTagOrigin( "tag_player" ) );
	missileScriptModel setModel ( "proto_vehicle_night_raven_missiles" );
	missileScriptModel.origin = raven GetTagOrigin( "tag_player" );
	missileScriptModel.angles = self getplayerangles();
	missileScriptModel.owner = self;
	self.LSDmissileScriptModel = missileScriptModel;

	//tagJC<NOTE>: The rig that the player is linked to.
	rig = spawn( "script_model", missileScriptModel GetTagOrigin( "tag_player" ));
	rig.angles = missileScriptModel GetTagAngles( "tag_player" );
	rig setmodel( "tag_origin" );
	rig LinkTo( missileScriptModel, "tag_player" );
	self.LSDrig = rig;

	//tagJC<NOTE>: Unlink the player from the raven and link the player to the rig that is just created.
	self Unlink();
	self PlayerLinkWeaponviewToDelta( rig, "tag_player", 1.0, 180, 180, 0, 180, true );

	//tagJC<NOTE>: Play the animation, sound, and FX accordingly.
	missileScriptModel ScriptModelPlayAnim ( "proto_nx_vh_night_raven_missiles_fire" );
	missileScriptModel PlaySound ( "mp_nightraven_fire" );
	missileScriptModel thread PlayLSDFX();

	//tagJC<NOTE>: Playing the warning sound and message to all locked enemy players.
	self thread sendWarningToAllTargets();

	//tagJC<NOTE>: Temporarily disable player's control while following the missiles.
	self FreezeControls ( true );

	//tagJC<TODO>: Investigate why LerpViewAngleClamp does not seem to be working in MP.  When used, the player is indeed linked
	//             to an entity which appears to satisfy the condition for using this function.
	self thread AdjustPlayerViewAngle ( missileScriptModel ); 
	self thread CreatePlayerViewFadeOut( raven );

	//tagJC<NOTE>: Wait for the animation to finish.
	wait ( LSD_ANIM_LENGTH );
	
	//tagJC<NOTE>: Fire all the magic bullets after the animation sequence is complete.
	missileScriptModel fireAllLSDMissiles();

	//tagJC<NOTE>: Clean up the associated entity for the next use.
	self.LSDMissileFired = undefined;
	self.LSDmissileScriptModel delete();
	self.LSDrig delete(); 

	//tagJC<NOTE>: Terminate the killstreak.
	raven thread LSD_leave_on_LSD_fired();
}

//tagJC<NOTE>: Sending warning messages and sound to all the locked enemy players.
//tagJC<NOTE>: Self is the killstreak user.
sendWarningToAllTargets()
{
	if ( isDefined ( self.LSDLockedTarget ) && self.LSDLockedTarget.size > 0 )
	{
		for ( i = 0 ; i < self.LSDLockedTarget.size ; i++)
		{
			self.LSDLockedTarget [ i ] thread CreateWarning ();
		}
	}
}

//tagJC<NOTE>: Lock player's view behind the missiles after firing.
//tagJC<NOTE>: Self is the killstreak user.
AdjustPlayerViewAngle ( rocket )
{
	for ( i = 0 ; i < 60 ; i ++ )
	{
		self SetPlayerAngles( rocket GetTagAngles( "tag_player" ) );
		wait ( 0.05 );
	}
	self FreezeControls ( false );
}

//tagJC<NOTE>: Firing 32 missiles from 32 stationary tags with index ranging from 33 to 64.
//tagJC<NOTE>: Self is the script model for the missiles.
fireAllLSDMissiles()
{
	for ( i = BEGINNING_TAG_NUMBER_MISSILE_FIRING ; i <= ENDING_TAG_NUMBER_MISSILE_FIRING ; i++ )
	{
		tag = "tag_missile_fx_0" + i;
		self FireLSDMissile ( tag );
	}
}

//tagJC<NOTE>: Firing each individual LSD missile from the given tag.
//tagJC<NOTE>: Self is the script model for the missiles.
FireLSDMissile( rocket_tag )
{
	stopFxOnTag ( level._effect[ "nx_smoke_geotrail_nightraven" ], self, rocket_tag );
	
	TagOrigin = self GetTagOrigin( rocket_tag );
	owner = self.owner;
	TagAngle = self GetTagAngles( rocket_tag );

	//tagJC<NOTE>: Initializing the number of missiles that have been fired.
	if ( ! isDefined ( owner.LSDMissileFired ) )
	{
		owner.LSDMissileFired = 0;
	}

	//tagJC<NOTE>: For each enemy in the locked target list, fire the guided missile on him.
	if ( isDefined ( owner.LSDLockedTarget ) && owner.LSDLockedTarget.size > 0 && owner.LSDMissileFired < owner.LSDLockedTarget.size )
	{
		//println ( "Firing LSD missile on enemy player." );
		counter = owner.LSDMissileFired;
		missile = MagicBullet( "LSDGuidedMissile_mp", TagOrigin , owner.LSDLockedTarget [ counter ].origin, owner );
		owner.LSDLockedTarget [ counter ] thread DestroyLSDWarningMessage ( missile );
		missile Missile_SetTargetEnt( owner.LSDLockedTarget [ counter ] );
		missile Missile_SetFlightmodeDirect();
		owner.LSDMissileFired = owner.LSDMissileFired + 1;
	}
	else
	{
		//tagJC<NOTE>: Else, firing missiles straight from the position and angle for the missiles at the end of the animation.
		target = TagOrigin + vector_multiply( anglestoforward ( TagAngle ), 5000 );
		MagicBullet( "LSDNightRavenMissile_mp", TagOrigin, target ,owner );
		owner.LSDMissileFired = owner.LSDMissileFired + 1;
	}  
}

//tagJC<NOTE>: This function performs the trace and determines whether an enemy player should be locked or not.
//tagJC<NOTE>: Self is the user of the killstreak
weaponLockThink( raven )
{
	//println ( "weaponLockThink" );
	self endon ( "disconnect" );
	raven endon ( "NightRaven_done" );

	if ( !isDefined( level._LSDTargetOrigin ) )
	{
		level._LSDTargetOrigin = spawn( "script_origin", (0,0,0) );
		level._LSDTargetOrigin hide();
	}

	self waittill ( "LSD_Target_System_Ready" );
	self thread DeleteLockBoxOnPlayers();

	for ( ;; )
	{
		trace = bulletTrace( self getEye(), self getEye() + (anglesToForward( self getPlayerAngles() ) * 100000 ), 1, self );
		level._LSDTargetOrigin.origin = trace["position"];

		targetListLOS = [];
		targetListNoLOS = [];
		foreach ( player in level._players )
		{
			if ( !isAlive( player ) )
				continue;

			if ( level._teamBased && player.team == self.team )
				continue;
				
			if ( player == self )
				continue;

			if ( player _hasPerk( "specialty_blindeye" ) )
				continue;

			if ( isDefined( player.spawntime ) && ( getTime() - player.spawntime )/1000 <= 5 )
				continue;

			player.remoteLSDLOS = true;
			if ( !bulletTracePassed( self getEye(), player.origin + (0,0,32), false, raven ) )
			{			
				targetListNoLOS[targetListNoLOS.size] = player;
			}
			else
			{
				targetListLOS[targetListLOS.size] = player;
			}
		}

		targetsInReticle = [];
		
		targetsInReticle = targetListLOS;
		foreach ( target in targetListNoLos )
		{
			targetListLOS[targetListLOS.size] = target;
		}
				
		if ( targetsInReticle.size != 0 )
		{
			sortedTargets = SortByDistance( targetsInReticle, trace["position"] );

			//tagJC<NOTE>: This is the condition determining whether an enemy player should be locked by the killstreak.
			if ( distance( sortedTargets[0].origin, trace["position"] ) < RADIUS_FOR_LSD_TARGETING && sortedTargets[0] DamageConeTrace( trace["position"] ) )
			{
				if ( !isDefined ( self.LSDLockedTarget ) )
					 self.LSDLockedTarget = [];
				if ( !isPlayerTargeted( self, sortedTargets[0] ))
				{
					self.LSDLockedTarget [ self.LSDLockedTarget.size ] = sortedTargets[0];
					sortedTargets[0] thread create_targeting_box ( self );
					raven.owner PlaySoundToPlayer ( "mp_nightraven_target", raven.owner );
					LSDDialog( "locked" );
				}
			}
		}
		wait ( 0.05 );
	}
}

//*******************************************************************
//                End of main logic for the killstreak              *
//             Beginning of FX functions for LSD missiles           *
//*******************************************************************
//tagJC<NOTE>: The following functions are used to play the appropriate FX on the various tags in the missiles.
//tagJC<NOTE>: Self is the script model for the LSD missiles.
//tagJC<NOTE>: Highly hard-coded timing specific FX playing sequence.
PlayLSDFX()
{
	//tagJC<NOTE>: A slight delay is necessary in order for the first FX to play.	
	wait (0.01);
	self thread release_containers();
	wait (0.733);
	self thread Left_container_pannel_fx();
	wait (0.134);
	self thread right_container_pannel_fx();
	wait (0.5);
	self thread containers_missile_release_fx();
	wait (0.533);
	self thread missile_ignite_grp01_fx(); 
	wait (0.1);
	self thread missile_ignite_grp02_fx(); 
	wait (0.133);
	self thread missile_ignite_grp03_fx(); 
	wait (0.134);
	self thread missile_ignite_grp04_fx(); 
	wait (0.066);
	self thread missile_ignite_grp05_fx(); 
}

release_containers()
{
	PlayFXOnTag( level._effect[ "afterburner_ignite" ], self, "tag_fx_right_cargo_exhaust" );
	PlayFXOnTag( level._effect[ "afterburner_ignite" ], self, "tag_fx_left_cargo_exhaust" );
}

Left_container_pannel_fx()
{
	PlayFXOnTag( level._effect[ "nx_smoke_nightraven_panels_off" ], self, "tag_fx_left_missiles_pop" );
}

right_container_pannel_fx()
{
	PlayFXOnTag( level._effect[ "nx_smoke_nightraven_panels_off" ], self, "tag_fx_right_missiles_pop" );
}

containers_missile_release_fx()
{
	PlayFXOnTag( level._effect[ "nx_smoke_nightraven_missile_eject" ], self, "tag_fx_right_missiles_pop" );
}

missile_ignite_grp01_fx()
{
	rocket_array = [];
	rocket_array[ rocket_array.size ] = "tag_missile_fx_009";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_010";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_002";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_001";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_008";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_007";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_006";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_005";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_004";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_003";
	self thread ignite_rocket_effect_group( rocket_array );
}

missile_ignite_grp02_fx()
{
	rocket_array = [];
	rocket_array[ rocket_array.size ] = "tag_missile_fx_016";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_015";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_014";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_013";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_012";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_011";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_024";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_023";
	self thread ignite_rocket_effect_group( rocket_array );
}

missile_ignite_grp03_fx()
{
	rocket_array = [];
	rocket_array[ rocket_array.size ] = "tag_missile_fx_022";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_021";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_020";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_019";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_018";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_017";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_032";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_025";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_026";
	self thread ignite_rocket_effect_group( rocket_array );
}

missile_ignite_grp04_fx()
{
	rocket_array = [];
	rocket_array[ rocket_array.size ] = "tag_missile_fx_027";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_028";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_029";
	self thread ignite_rocket_effect_group( rocket_array );
}

missile_ignite_grp05_fx()
{
	rocket_array = [];
	rocket_array[ rocket_array.size ] = "tag_missile_fx_030";
	rocket_array[ rocket_array.size ] = "tag_missile_fx_031";
	self thread ignite_rocket_effect_group( rocket_array );
}

ignite_rocket_effect_group( rocket_array )
{
	//println ( "ignite_rocket_effect_group" );

	foreach( rocket_tag in rocket_array )
	{
		wait ( 0.05 );
		PlayFXOnTag( level._effect[ "nx_smoke_geotrail_nightraven" ], self, rocket_tag );
		//println ( GetTime()+ ":Playing FX for tag " + rocket_tag );
	}
}

//*******************************************************************
//               End of FX functions for LSD  missiles              *
//         Beginning of LSD specific HUD element functions          *
//*******************************************************************
//tagJC<NOTE>: Creating a center reticle for the killstreak.  It will appear once the vehicle starts the loop path.
//tagJC<TODO>: The size parameters are working with this setup.  Investigate why it works with this setup, but does not work with 
//             the setHeadIcon setup.
//tagJC<TODO>: Self is the user of the killstreak.
CreateLSDReticle()
{
	wait ( 0.5 );
	hudelem = newClientHudElem( self );
	hudelem setShader ( "proto_nx_target_cursor", 128, 128);
	hudelem.alignX = "center";
	hudelem.alignY = "middle";
	hudelem.horzAlign = "center";
	hudelem.vertAlign = "middle";
	hudelem.foreground = 1;
	hudelem.hidewheninmenu = true;
	hudelem.hidewhendead = true;
	return hudelem;
}

destroyLSDReticleAfterFiring()
{
	self endon ( "LSDPlayer_removed" );

	for ( ;; )
	{
		self waittill ( "LSD_fired" );
		if ( isDefined ( self.LSDReticle ))
		{
			//println ( "Destroying the LSD reticle" );
			self.LSDReticle destroy();
		}
	}
}

//tagJC<NOTE>: Creating the idle white target box on all enemy players showing their locations on the level.  They shows up one
//             after another with 0.2 second delay in order to create a more high tech feel for the locking system.
//tagJC<TODO>: Investigate why setting the width and height with setHeadIcon does not seem to be working.
//tagJC<TODO>: Self is the user of the killstreak.
createIdleLSDBoxOnEnemy()
{
	wait ( 0.2 );
	foreach ( player in level._players )
	{
		//if ( !isAlive( player ) )
		//	continue;

		if ( level._teamBased && player.team == self.team )
			continue;
			
		if ( player == self )
			continue;

		//if ( player _hasPerk( "specialty_blindeye" ) )
		//	continue;

		if ( isDefined( player.spawntime ) && ( getTime() - player.spawntime )/1000 <= 5 )
			continue;

		player maps\mp\_entityheadIcons::setHeadIcon( 
				self, 
				"mp_lsd_target_idle", 
				( 0, 0, 0 ), 
				500, 
				500, 
				false, 
				0.05, 
				true, 
				true, 
				true,
				false );
		wait ( 0.1 );
	} 
	self notify ( "LSD_Target_System_Ready" );
}

//tagJC<NOTE>: Once an enemy player is locked, play the locking animated sequence.
//tagJC<TODO>: Investigate why setting the width and height with setHeadIcon does not seem to be working.
//tagJC<TODO>: Self is the user of the killstreak.
create_targeting_box ( player )
{
	self endon ( "disconnect" );
	self endon ( "LSD_fired" );

	for( i = BEGINNING_TAG_NUMBER_LOCK_BOX ; i <= ENDING_TAG_NUMBER_LOCK_BOX ; i++ )
	{
		if( i < 10 )
		{
			shader = "mp_lsd_target_anim_00" + i;
		}
		else
		{
			shader = "mp_lsd_target_anim_0" + i;
		}
		
		self maps\mp\_entityheadIcons::setHeadIcon( 
				player, 
				shader, 
				( 0, 0, 0 ), 
				500, 
				500, 
				false, 
				0.05, 
				true, 
				true, 
				true,
				false );

		wait 0.05;
	} 
}

//tagJC<NOTE>: Creating a warning message so the locked enemy knows to find cover.
//tagJC<NOTE>: Self is the enemy player who is locked by the killstreak.  
CreateWarning ()
{
	self PlaySoundToPlayer ( "mp_nightraven_warning", self );
	hudelem = newClientHudElem( self );
	hudelem.label = &"MP_LSD_WARNING";
	hudelem.alignX = "center";
	hudelem.alignY = "top";
	hudelem.horzAlign = "center";
	hudelem.vertAlign = "top";
	hudelem.fontScale = 1;
	hudelem.color = ( 0, 1, 0 );
	hudelem.font = "objective";
	hudelem.foreground = 1;
	hudelem.hidewheninmenu = true;
	hudelem.hidewhendead = true;
	self.LSDWarningMessage = hudelem;
}

//tagJC<NOTE>: Deleting the warning message once the guided missile explodes.
//tagJC<NOTE>: Self is the enemy player who is locked by the killstreak.  
DestroyLSDWarningMessage ( incoming_missile )
{
	//tagJC<NOTE>: Destroy the HUD element once the missile explodes.
	incoming_missile waittill ( "death" );
	if ( isDefined ( self.LSDWarningMessage ))
	{
		self.LSDWarningMessage destroy ();
	}
}

//tagJC<NOTE>: Creating the exit fade out for the player.  This is the transition for the player to go back into the battle field.
//tagJC<NOTE>: Self is the user of the killstreak.
CreatePlayerViewFadeOut( raven )
{
	self endon ( "disconnect" );
	level endon ( "game_ended" );

	wait ( 2.0 );
	if ( !isdefined( self.darkScreenOverlay ) )
	{
		self.darkScreenOverlay = newClientHudElem( self );
		self.darkScreenOverlay.x = 0;
		self.darkScreenOverlay.y = 0;
		self.darkScreenOverlay.alignX = "left";
		self.darkScreenOverlay.alignY = "top";
		self.darkScreenOverlay.horzAlign = "fullscreen";
		self.darkScreenOverlay.vertAlign = "fullscreen";
		self.darkScreenOverlay setshader ( "black", 640, 480 );
		self.darkScreenOverlay.foreground = true;
		self.darkScreenOverlay.alpha = 0.0;
	}
	
	self.darkScreenOverlay.alpha = 0.0;
	self.darkScreenOverlay fadeOverTime( 1.0 );
	self.darkScreenOverlay.alpha = 1;
	wait 1.0;
	self.darkScreenOverlay destroy();
	self RemoteCameraSoundscapeOff();

	self unlink();

	self switchToWeapon( self getLastWeapon() );
	if ( isDefined ( self.alreadyClearUsingRemote ) && self.alreadyClearUsingRemote == false )
	{
		self clearUsingRemote();
		self.alreadyClearUsingRemote = true;
	}

	if ( getDvarInt( "camera_thirdPerson" ) )
		self setThirdPersonDOF( true );

	self visionSetThermalForPlayer( game["thermal_vision"], 0 );

	weaponList = self GetWeaponsListExclusives();
	foreach ( weapon in weaponList )
		self takeWeapon( weapon );
	
	if ( isDefined( raven ) )
		raven VehicleTurretControlOff( self );
}

//tagJC<NOTE>: Once the LSD missiles are fired, delete all the head icons on enemy players.
//tagJC<NOTE>: Self is the user of the killstreak.
DeleteLockBoxOnPlayers()
{
	self endon ( "disconnect" );
	self endon ( "LSDPlayer_removed" );
	
	for ( ;; )
	{
		self waittill ( "LSD_fired" );
		foreach ( player in level._players )
		{
			if ( isDefined( player.entityHeadIcons ))
			{
				foreach( key, headIcon in player.entityHeadIcons )
				{	
					if( !isDefined( headIcon ) )
					{
						continue;
					}
					if ( key == self.guid )
					{
						headIcon destroy();
						player.entityHeadIcons [ self.guid ] = undefined;
					}
				}
			}
		}
	}
}

//*******************************************************************
//           End of LSD specific HUD element functions              *
//              Beginning of raven pathing logic                    *
//*******************************************************************
getOriginOffsets( goalNode )
{
	//println ( "getOriginOffsets" );
	startOrigin = self.origin;
	endOrigin = goalNode.origin;
	
	numTraces = 0;
	maxTraces = 40;
	
	traceOffset = (0,0,-196);
	
	traceOrigin = physicsTrace( startOrigin+traceOffset, endOrigin+traceOffset );

	while ( distance( traceOrigin, endOrigin+traceOffset ) > 10 && numTraces < maxTraces )
	{	
		//println( "trace failed: " + distance( physicsTrace( startOrigin+traceOffset, endOrigin+traceOffset ), endOrigin+traceOffset ) );
			
		if ( startOrigin[2] < endOrigin[2] )
		{
			startOrigin += (0,0,128);
		}
		else if ( startOrigin[2] > endOrigin[2] )
		{
			endOrigin += (0,0,128);
		}
		else
		{	
			startOrigin += (0,0,128);
			endOrigin += (0,0,128);
		}
		
		//thread draw_line( startOrigin+traceOffset, endOrigin+traceOffset, (0,1,9), 200 );
		numTraces++;

		traceOrigin = physicsTrace( startOrigin+traceOffset, endOrigin+traceOffset );
	}
	
	offsets = [];
	offsets["start"] = startOrigin;
	offsets["end"] = endOrigin;
	return offsets;
}

travelToNode( goalNode )
{
	//println ( "travelToNode" );
	originOffets = getOriginOffsets( goalNode );
	
	if ( originOffets["start"] != self.origin )
	{
		// motion change via node
		if( isdefined( goalNode.script_airspeed ) && isdefined( goalNode.script_accel ) )
		{
			LSD_speed = goalNode.script_airspeed;
			LSD_accel = goalNode.script_accel;
		}
		else
		{
			LSD_speed = 30+randomInt(20);
			LSD_accel = 15+randomInt(15);
		}
		
		self Vehicle_SetSpeed( LSD_speed, LSD_accel );
		self setvehgoalpos( originOffets["start"] + (0,0,30), 0 );
		// calculate ideal yaw
		self setgoalyaw( goalNode.angles[ 1 ] + level._LSD_angle_offset );
		
		//println( "setting goal to startOrigin" );
		
		self waittill ( "goal" );
	}
	
	if ( originOffets["end"] != goalNode.origin )
	{
		// motion change via node
		if( isdefined( goalNode.script_airspeed ) && isdefined( goalNode.script_accel ) )
		{
			LSD_speed = goalNode.script_airspeed;
			LSD_accel = goalNode.script_accel;
		}
		else
		{
			LSD_speed = 30+randomInt(20);
			LSD_accel = 15+randomInt(15);
		}
		
		self Vehicle_SetSpeed( LSD_speed, LSD_accel );
		self setvehgoalpos( originOffets["end"] + (0,0,30), 0 );
		// calculate ideal yaw
		self setgoalyaw( goalNode.angles[ 1 ] + level._LSD_angle_offset );

		//println( "setting goal to endOrigin" );
		
		self waittill ( "goal" );
	}
}

LSD_fly_simple_path( startNode )
{
	//println ( "LSD_fly_simple_path" );
	self endon ( "death" );
	self endon ( "leaving" );

	// only one thread instance allowed
	self notify( "flying");
	self endon( "flying" );
	
	LSD_reset();
	
	currentNode = startNode;
	while ( isDefined( currentNode.target ) )
	{
		nextNode = getEnt( currentNode.target, "targetname" );
		assertEx( isDefined( nextNode ), "Next node in path is undefined, but has targetname" );
		
		if( isDefined( currentNode.script_airspeed ) && isDefined( currentNode.script_accel ) )
		{
			LSD_speed = currentNode.script_airspeed;
			LSD_accel = currentNode.script_accel;
		}
		else
		{
			LSD_speed = 150 + randomInt(20);
			LSD_accel = 45 + randomInt(15);
		}

		self Vehicle_SetSpeed( LSD_speed, LSD_accel );
		
		// end of the path
		if ( !isDefined( nextNode.target ) )
		{
			self setVehGoalPos( nextNode.origin+(self.zOffset), true );
			self waittill( "near_goal" );
		}
		else
		{
			self setVehGoalPos( nextNode.origin+(self.zOffset), false );
			self waittill( "near_goal" );

			self setGoalYaw( nextNode.angles[ 1 ] );

			self waittillmatch( "goal" );
		}

		currentNode = nextNode;
	}
	
	//printLn( currentNode.origin );
	//printLn( self.origin );
}

LSD_fly_loop_path( startNode )
{
	//println ( "LSD_fly_loop_path" );
	self endon ( "death" );
	self endon ( "crashing" );
	self endon ( "leaving" );

	// only one thread instance allowed
	self notify( "flying");
	self endon( "flying" );
	
	LSD_reset();
	
	if ( isDefined ( self.owner.LSDFired ) && self.owner.LSDFired == 0 )
	{ 
	//	self.owner.LSDReticle = self.owner createLSDReticle();
	//	self.owner thread destroyLSDReticleAfterFiring();
	}
	
	if ( isDefined ( self.owner.LSDFired ) && self.owner.LSDFired == 0 )
	{ 
		self.owner thread createIdleLSDBoxOnEnemy();	
	}
	self thread LSD_loop_speed_control( startNode );
	
	currentNode = startNode;
	while ( isDefined( currentNode.target ) )
	{
		nextNode = getEnt( currentNode.target, "targetname" );
		assertEx( isDefined( nextNode ), "Next node in path is undefined, but has targetname" );
		
		if( isDefined( currentNode.script_airspeed ) && isDefined( currentNode.script_accel ) )
		{
			self.desired_speed = currentNode.script_airspeed;
			self.desired_accel = currentNode.script_accel;
		}
		else
		{
			self.desired_speed = 30 + randomInt( 20 );
			self.desired_accel = 15 + randomInt( 15 );
		}
		
		if ( self.LSDType == "flares" )
		{
			self.desired_speed *= 0.5;
			self.desired_accel *= 0.5;
		}
		
		if ( isDefined( nextNode.script_delay ) && isDefined( self.primaryTarget ) && !self LSD_is_threatened() )
		{
			self setVehGoalPos( nextNode.origin+(self.zOffset), true );
			self waittill( "near_goal" );

			wait ( nextNode.script_delay );
		}
		else
		{
			self setVehGoalPos( nextNode.origin+(self.zOffset), false );
			self waittill( "near_goal" );

			self setGoalYaw( nextNode.angles[ 1 ] );

			self waittillmatch( "goal" );
		}

		currentNode = nextNode;
	}
}

LSD_loop_speed_control( currentNode )
{
	//println ( "LSD_loop_speed_control" );
	self endon ( "death" );
	self endon ( "crashing" );
	self endon ( "leaving" );

	if( isDefined( currentNode.script_airspeed ) && isDefined( currentNode.script_accel ) )
	{
		self.desired_speed = currentNode.script_airspeed;
		self.desired_accel = currentNode.script_accel;
	}
	else
	{
		self.desired_speed = 30 + randomInt( 20 );
		self.desired_accel = 15 + randomInt( 15 );
	}
	
	lastSpeed = 0;
	lastAccel = 0;
	
	while ( 1 )
	{
		goalSpeed = self.desired_speed;
		goalAccel = self.desired_accel;
		
		if ( self.LSDType != "flares" && isDefined( self.primaryTarget ) && !self LSD_is_threatened() )
			goalSpeed *= 0.25;
					
		if ( lastSpeed != goalSpeed || lastAccel != goalAccel )
		{
			self Vehicle_SetSpeed( goalSpeed, goalAccel );
			
			lastSpeed = goalSpeed;
			lastAccel = goalAccel;
		}
		
		wait ( 0.05 );
	}
}

LSD_is_threatened()
{
	//println ( "LSD_is_threatened" );
	if ( self.recentDamageAmount > 50 )
		return true;

	if ( self.currentState == "heavy smoke" )
		return true;
		
	return false;	
}

LSD_fly_well( destNodes )
{
	//println ( "LSD_fly_well" );
	self notify( "flying");
	self endon( "flying" );

	self endon ( "death" );
	self endon ( "crashing" );
	self endon ( "leaving" );

	for ( ;; )	
	{
		currentNode = self get_best_area_attack_node( destNodes );
	
		travelToNode( currentNode );
		
		// motion change via node
		if( isdefined( currentNode.script_airspeed ) && isdefined( currentNode.script_accel ) )
		{
			LSD_speed = currentNode.script_airspeed;
			LSD_accel = currentNode.script_accel;
		}
		else
		{
			LSD_speed = 30+randomInt(20);
			LSD_accel = 15+randomInt(15);
		}
		
		self Vehicle_SetSpeed( LSD_speed, LSD_accel );	
		self setvehgoalpos( currentNode.origin + self.zOffset, 1 );
		self setgoalyaw( currentNode.angles[ 1 ] + level._LSD_angle_offset );	

		if ( level._LSD_forced_wait != 0 )
		{
			self waittill( "near_goal" ); //self waittillmatch( "goal" );
			wait ( level._LSD_forced_wait );			
		}
		else if ( !isdefined( currentNode.script_delay ) )
		{
			self waittill( "near_goal" ); //self waittillmatch( "goal" );

			wait ( 5 + randomInt( 5 ) );
		}
		else
		{				
			self waittillmatch( "goal" );				
			wait ( currentNode.script_delay );
		}
	}
}

get_best_area_attack_node( destNodes )
{
	//println ( "get_best_area_attack_node" );
	return updateAreaNodes( destNodes );
}

// NightRaven leaving parameter, can not be damaged while leaving
LSD_leave()
{
	//println ( "LSD_leave" );
	self notify( "leaving" );

	leaveNode = level._LSD_leave_nodes[ randomInt( level._LSD_leave_nodes.size ) ];
	
	self LSD_reset();
	self Vehicle_SetSpeed( 100, 45 );	
	self setvehgoalpos( leaveNode.origin, 1 );
	self waittillmatch( "goal" );
	self notify( "death" );
	
	// give "death" notify time to process
	wait ( 0.05 );
	self delete();
}

//*******************************************************************
//                 End of raven pathing logic                       *
//       Beginning of house-keeping and miscelaneous functions      *
//*******************************************************************
makeLSDType( LSDType, deathFx, lightFXFunc )
{
	//println ( "makeLSDType" ); 
	level._raven_fx["explode"]["death"][ LSDType ] = loadFx( deathFX );
	level._RavenlightFxFunc[ LSDType ] = lightFXFunc;
}

addAirExplosion( LSDType, explodeFx )
{
	//println ( "addAirExplosion" );
	level._raven_fx["explode"]["air_death"][ LSDType ] = loadFx( explodeFx );
}

pavelowLightFX()
{
	//println ( "pavelowLightFX" );
	playFXOnTag( level._raven_fx["light"]["left"], self, "tag_light_L_wing1" );
	wait ( 0.05 );
	playFXOnTag( level._raven_fx["light"]["right"], self, "tag_light_R_wing1" );
	wait ( 0.05 );
	playFXOnTag( level._raven_fx["light"]["belly"], self, "tag_light_belly" );
	wait ( 0.05 );
	playFXOnTag( level._raven_fx["light"]["tail"], self, "tag_light_tail" );
	wait ( 0.05 );
	playFXOnTag( level._raven_fx["light"]["tail"], self, "tag_light_tail2" );
	wait ( 0.05 );
	playFXOnTag( level._raven_fx["light"]["belly"], self, "tag_light_cockpit01" );
}

RavendefaultLightFX()
{
	//println ( "RavendefaultLightFX" );
	playFXOnTag( level._raven_fx["light"]["left"], self, "tag_light_L_wing" );
	wait ( 0.05 );
	playFXOnTag( level._raven_fx["light"]["right"], self, "tag_light_R_wing" );
	wait ( 0.05 );
	playFXOnTag( level._raven_fx["light"]["belly"], self, "tag_light_belly" );
	wait ( 0.05 );
	playFXOnTag( level._raven_fx["light"]["tail"], self, "tag_light_tail" );
}

deleteOnEntNotify( ent, notifyString )
{
	//println ( "deleteOnEntNotify" );
	self endon ( "death" );
	ent waittill ( notifyString );
	
	self delete();
}

spawn_NightRaven( owner, origin, angles, vehicleType, modelName )
{
	//println ( "spawn_NightRaven" );
	raven = spawnHelicopter( owner, origin, angles, vehicleType, modelName );
	
	if ( !isDefined( raven ) )
		return undefined;

	raven.LSD_type = level._LSD_types[ modelName ];
	
	raven thread [[ level._RavenlightFxFunc[ raven.LSD_type ] ]]();
	
	raven addToLSDList();
	
	//raven.zOffset = (0,0,raven getTagOrigin( "tag_origin" )[2] - raven getTagOrigin( "tag_origin" )[2]);
	raven.zOffset = (0,0,raven getTagOrigin( "tag_origin" )[2] - raven getTagOrigin( "tag_ground" )[2]);
	raven.attractor = Missile_CreateAttractorEnt( raven, level._LSD_attract_strength, level._LSD_attract_range );
	
	raven.damageCallback = ::Callback_VehicleDamage;
	
	return raven;
}

isPlayerTargeted( owner, player )
{
	for ( i = 0; i < owner.LSDLockedTarget.size; i++)
	{
		if ( owner.LSDLockedTarget [i] == player )
		{
			return true;
		}
	}
	return false;
}

LSDDialog( dialogGroup )
{
	//println ( "LSDDialog" );
	if ( getTime() - level._lastLSDDialogTime < 6000 )
		return;
	
	level._lastLSDDialogTime = getTime();
	
	randomIndex = randomInt( level._LSDDialog[ dialogGroup ].size );
	soundAlias = level._LSDDialog[ dialogGroup ][ randomIndex ];
	
	fullSoundAlias = maps\mp\gametypes\_teams::getTeamVoicePrefix( self.team ) + soundAlias;
	
	self playLocalSound( fullSoundAlias );
}

endRide( raven )
{
	println ( "endRide" );

	self notify ( "LSD_fired" );
	waitframe();

	if ( self hasWeapon ( "lock_seek_die_mp" ) )
	{
		self RemoteCameraSoundscapeOff();
		
		self ThermalVisionOff();
		self ThermalVisionFOFOverlayOff();
		
		self unlink();
		if ( isDefined ( self.LSDReticle ))
		{
			//println ( "Destroying the LSD reticle" );
			self.LSDReticle destroy();
		}
		self thread DeleteLSDLockedTarget();
		self switchToWeapon( self getLastWeapon() );
		if ( isDefined ( self.alreadyClearUsingRemote ) && self.alreadyClearUsingRemote == false )
		{
			self clearUsingRemote();
			self.alreadyClearUsingRemote = true;
		}
		
		if ( getDvarInt( "camera_thirdPerson" ) )
			self setThirdPersonDOF( true );
		
		self visionSetThermalForPlayer( game["thermal_vision"], 0 );
		
		weaponList = self GetWeaponsListExclusives();
		foreach ( weapon in weaponList )
			self takeWeapon( weapon );
		
		if ( isDefined( raven ) )
			raven VehicleTurretControlOff( self ); 
	}
	
	self.LSDFired = undefined;
	self thread DeleteLSDLockedTarget();
	self notify ( "LSDPlayer_removed" );
}	

//tagJC<NOTE>: Erace the LSDLockedTarget array for the next use of the killstreak.
DeleteLSDLockedTarget()
{
	if ( isDefined ( self.LSDLockedTarget ))
	{
		self.LSDLockedTarget = undefined;
	}
}

endRideOnNightRavenDone( raven )
{
	//println ( "endRideOnNightRavenDone" );
	self endon ( "disconnect" );
	
	raven waittill ( "NightRaven_done" );

	wait ( 1.5 );

	self endRide( raven );
}

updateAreaNodes( areaNodes )
{
	//println ( "updateAreaNodes" );
	validEnemies = [];

	foreach ( node in areaNodes )
	{
		node.validPlayers = [];
		node.nodeScore = 0;
	}
	
	foreach ( player in level._players )
	{
		if ( !isAlive( player ) )
			continue;

		if ( player.team == self.team )
			continue;
			
		foreach ( node in areaNodes )
		{
			if ( distanceSquared( player.origin, node.origin ) > 1048576 )
				continue;
				
			node.validPlayers[node.validPlayers.size] = player;
		}
	}

	bestNode = areaNodes[0];
	foreach ( node in areaNodes )
	{
		LSDNode = getEnt( node.target, "targetname" );
		foreach ( player in node.validPlayers )
		{
			node.nodeScore += 1;
			
			if ( bulletTracePassed( player.origin + (0,0,32), LSDNode.origin, false, player ) )
				node.nodeScore += 3;
		}
		
		if ( node.nodeScore > bestNode.nodeScore )
			bestNode = node;
	}
	
	return ( getEnt( bestNode.target, "targetname" ) );
}

LSD_existance()
{
	//println ( "LSD_existance" );
	entityNumber = self getEntityNumber();
	
	self waittill_any( "death", "crashing", "leaving" );

	self removeFromLSDList( entityNumber );
	
	self notify( "NightRaven_done" );
	
	player = undefined;
	queueEnt = queueRemoveFirst( "NightRaven" );
	if ( !isDefined( queueEnt ) )
	{
		level._raven = undefined;
		return;
	}
	
	player = queueEnt.player;
	lifeId = queueEnt.lifeId;
	streakName = queueEnt.streakName;
	LSDType = queueEnt.LSDType;
	queueEnt delete();
	
	if ( isDefined( player ) && (player.sessionstate == "playing" || player.sessionstate == "dead") )
	{
		player maps\mp\killstreaks\_killstreaks::usedKillstreak( streakName, true );
		player startNightRaven( lifeId, LSDType );
	}
	else
	{
		level._raven = undefined;
	}
}

// resets NightRaven's motion values
LSD_reset()
{
	//println ( "LSD_reset" );
	self clearTargetYaw();
	self clearGoalYaw();
	self Vehicle_SetSpeed( 60, 25 );	
	self setyawspeed( 75, 45, 45 );
	//self setjitterparams( (30, 30, 30), 4, 6 );
	self setmaxpitchroll( 30, 30 );
	self setneargoalnotifydist( 256 );
	self setturningability(0.9);
}

Callback_VehicleDamage( inflictor, attacker, damage, dFlags, meansOfDeath, weapon, point, dir, hitLoc, timeOffset, modelIndex, partName )
{
	//println ( "Callback_VehicleDamage" );
	if ( !isDefined( attacker ) || attacker == self )
		return;
		
	if ( !maps\mp\gameTypes\_weapons::attackerCanDamageItem( attacker, self.owner ) )
		return;

	switch ( weapon )
	{
		case "ac130_105mm_mp":
		case "ac130_40mm_mp":
		case "stinger_mp":
		case "javelin_mp":
		case "remotemissile_projectile_mp":
		case "remote_mortar_missile_mp":
			self.largeProjectileDamage = true;
			damage = self.maxhealth + 1;
			break;
	}
	
	if( self.damageTaken+damage >= self.maxhealth )
	{
		validAttacker = undefined;

		if ( !isDefined(self.owner) || attacker != self.owner )
			validAttacker = attacker;

		if ( isDefined( validAttacker ) && ( self.hasBeenDestroyed == false))
		{
			validAttacker notify( "destroyed_killstreak", weapon );
			self.hasBeenDestroyed = false;
		}
	}

	self Vehicle_FinishDamage( inflictor, attacker, damage, dFlags, meansOfDeath, weapon, point, dir, hitLoc, timeOffset, modelIndex, partName );
}

addRecentDamage( damage )
{
	//println ( "addDecentDamage" );
	self endon( "death" );

	self.recentDamageAmount += damage;

	wait ( 4.0 );
	self.recentDamageAmount -= damage;
}


// accumulate damage and react
LSD_damage_monitor()
{
	//println ( "LSD_damage_monitor" );
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	
	self.damageTaken = 0;
	self.recentDamageAmount = 0;
	
	for( ;; )
	{
		// this damage is done to self.health which isnt used to determine the NightRaven's health, damageTaken is.
		self waittill( "damage", damage, attacker, direction_vec, P, type );
		
		assert( isDefined( attacker ) );

		self.attacker = attacker;

		if ( isPlayer( attacker ) )
		{
			attacker maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "" );

			if ( type == "MOD_RIFLE_BULLET" || type == "MOD_PISTOL_BULLET" )
			{
				damage *= level._LSD_armor_bulletdamage;
				
				if ( attacker _hasPerk( "specialty_armorpiercing" ) )
					damage += damage*level._armorPiercingMod;
			}
		}

		self.damageTaken += damage;

		self thread addRecentDamage( damage );

		if( self.damageTaken > self.maxhealth  && ((level._teamBased && self.team != attacker.team) || !level._teamBased) )
		{
			validAttacker = undefined;
			if ( isDefined( attacker.owner ) && (!isDefined(self.owner) || attacker.owner != self.owner) )
				validAttacker = attacker.owner;
			else if ( !isDefined(attacker.owner) && attacker.classname == "script_vehicle" )
				return;
			else if ( !isDefined(self.owner) || attacker != self.owner )
				validAttacker = attacker;

			if ( isDefined( validAttacker ) )
			{
				attacker notify( "destroyed_NightRaven" );

				thread teamPlayerCardSplash( "callout_destroyed_helicopter_minigun", validAttacker );
				xpVal = 300;
		
				validAttacker thread maps\mp\gametypes\_rank::giveRankXP( "kill", xpVal );
				thread maps\mp\gametypes\_missions::vehicleKilled( self.owner, self, undefined, validAttacker, damage, type );
				
			}
		}
	}
}

LSD_health()
{
	//println ( "hehi_health" );
	self endon( "death" );
	self endon( "leaving" );
	self endon( "crashing" );
	
	self.currentstate = "ok";
	self.laststate = "ok";
	self setdamagestage( 3 );
	
	damageState = 3;
	self setDamageStage( damageState );
	
	for ( ;; )
	{
		if ( self.damageTaken >= (self.maxhealth * 0.33) && damageState == 3 )
		{
			damageState = 2;
			self setDamageStage( damageState );
			self.currentstate = "light smoke";
			playFxOnTag( level._raven_fx["damage"]["light_smoke"], self, "tag_engine_left" );
		}
		else if ( self.damageTaken >= (self.maxhealth * 0.66) && damageState == 2 )
		{
			damageState = 1;
			self setDamageStage( damageState );
			self.currentstate = "heavy smoke";
			stopFxOnTag( level._raven_fx["damage"]["light_smoke"], self, "tag_engine_left" );
			playFxOnTag( level._raven_fx["damage"]["heavy_smoke"], self, "tag_engine_left" );
		}
		else if( self.damageTaken > self.maxhealth )
		{
			damageState = 0;
			self setDamageStage( damageState );

			stopFxOnTag( level._raven_fx["damage"]["heavy_smoke"], self, "tag_engine_left" );
			
			if ( IsDefined( self.largeProjectileDamage ) && self.largeProjectileDamage )
			{
				self thread LSD_explode( true );
			}
			else
			{
				playFxOnTag( level._raven_fx["damage"]["on_fire"], self, "tag_engine_left" );
				self thread LSD_crash();
			}
		}
		
		wait 0.05;
	}
}

// attach NightRaven on crash path
LSD_crash()
{
	//println ( "hehi_crash" );
	self notify( "crashing" );

	crashNode = level._LSD_crash_nodes[ randomInt( level._LSD_crash_nodes.size ) ];	

	self thread LSD_spin( 180 );
	self thread LSD_secondary_explosions();
	self LSD_fly_simple_path( crashNode );
	
	self thread LSD_explode();
}

LSD_secondary_explosions()
{
	//println ( "hehi_secondary_explosions" );
	teamname = self LSD_getTeamForSoundClip();
	
	playFxOnTag( level._raven_fx["explode"]["large"], self, "tag_engine_left" );
	self playSound ( level._LSD_sound[teamname]["hitsecondary"] );

	wait ( 3.0 );

	if ( !isDefined( self ) )
		return;
         
	playFxOnTag( level._raven_fx["explode"]["large"], self, "tag_engine_left" );
	self playSound ( level._LSD_sound[teamname]["hitsecondary"] );
}

// self spin at one rev per 2 sec
LSD_spin( speed )
{
	//println ( "hehi_spin" );
	self endon( "death" );
	
	teamname = self LSD_getTeamForSoundClip();
	
	// play hit sound immediately so players know they got it
	self playSound ( level._LSD_sound[teamname]["hit"] );
	
	// play heli crashing spinning sound
	self thread spinSoundShortly();
	
	// spins until death
	self setyawspeed( speed, speed, speed );
	while ( isdefined( self ) )
	{
		self settargetyaw( self.angles[1]+(speed*0.9) );
		wait ( 1 );
	}
}

spinSoundShortly()
{
	//println ( "spinSoundShortly" );
	self endon("death");
	
	teamname = self LSD_getTeamForSoundClip();
	
	wait .25;
	
	self stopLoopSound();
	wait .05;
	self playLoopSound( level._LSD_sound[teamname]["spinloop"] );
	wait .05;
	self playLoopSound( level._LSD_sound[teamname]["spinstart"] );
}


// crash explosion
LSD_explode( altStyle )
{
	//println ( "hehi_explode" );
	self notify( "death" );
	
	if ( isDefined( altStyle ) && isDefined( level._raven_fx["explode"]["air_death"][self.LSD_type] ) )
	{
		deathAngles = self getTagAngles( "tag_deathfx" );
		
		playFx( level._raven_fx["explode"]["air_death"][self.LSD_type], self getTagOrigin( "tag_deathfx" ), anglesToForward( deathAngles ), anglesToUp( deathAngles ) );
		//playFxOnTag( level.raven_fx["explode"]["air_death"][self.heli_type], self, "tag_deathfx" );	
	}
	else
	{
		org = self.origin;	
		forward = ( self.origin + ( 0, 0, 1 ) ) - self.origin;
		playFx( level._raven_fx["explode"]["death"][self.LSD_type], org, forward );
	}
	
	// play heli explosion sound
	teamname = self LSD_getTeamForSoundClip();
	self playSound( level._LSD_sound[teamname]["crash"] );

	// give "death" notify time to process
	wait ( 0.05 );
	self delete();
}

// checks if owner is valid, returns false if not valid
check_owner()
{
	//println ( "check_owner" );
	if ( !isdefined( self.owner ) || !isdefined( self.owner.pers["team"] ) || self.owner.pers["team"] != self.team )
	{
		self thread LSD_leave();
		
		return false;	
	}
	
	return true;
}

LSD_leave_on_disconnect( owner )
{
	//println ( "LSD_leave_on_disconnect" );
	self endon ( "death" );
	self endon ( "NightRaven_done" );

	owner waittill( "disconnect" );
	
	self thread LSD_leave();
}

LSD_leave_on_changeTeams( owner )
{
	//println ( "hehi_leave_on_changeTeams" );
	self endon ( "death" );
	self endon ( "NightRaven_done" );

	owner waittill_any( "joined_team", "joined_spectators" );
	
	self thread LSD_leave();
}

LSD_leave_on_spawned( owner )
{
	//println ( "hehi_leave_on_spawned" );
	self endon ( "death" );
	self endon ( "NightRaven_done" );

	owner waittill( "spawned" );
	
	self thread LSD_leave();
}

LSD_leave_on_gameended( owner )
{
	//println ( "hehi_leave_on_gameended" );
	self endon ( "death" );
	self endon ( "NightRaven_done" );

	level waittill ( "game_ended" );
	
	self thread LSD_leave();	
}

LSD_leave_on_timeout( timeOut )
{
	//println ( "hehi_leave_on_timeout" );
	self endon ( "death" );
	self endon ( "NightRaven_done" );
	
	maps\mp\gametypes\_hostmigration::waitLongDurationWithHostMigrationPause( timeOut );
	
	self thread LSD_leave();
}

LSD_leave_on_LSD_fired()
{
	//println ( "hehi_leave_on_LSD_fired" );
	self endon ( "death" );
	self endon ( "NightRaven_done" );
	
	self thread LSD_leave();
}

//*******************************************************************
//        End of house-keeping and miscelaneous functions           *
//                 Beginning of debug functions                     *
//*******************************************************************
debug_print3d( message, color, ent, origin_offset, frames )
{
	//println ( "debug_print3d" );
	if ( isdefined( level._LSD_debug ) && level._LSD_debug == 1.0 )
		self thread draw_text( message, color, ent, origin_offset, frames );
}

debug_print3d_simple( message, ent, offset, frames )
{
	//println ( "debug_print3d_simple" );
	if ( isdefined( level._LSD_debug ) && level._LSD_debug == 1.0 )
	{
		if( isdefined( frames ) )
			thread draw_text( message, ( 0.8, 0.8, 0.8 ), ent, offset, frames );
		else
			thread draw_text( message, ( 0.8, 0.8, 0.8 ), ent, offset, 0 );
	}
}

debug_line( from, to, color, frames )
{
	//println ( "debug_line" );
	if ( isdefined( level._LSD_debug ) && level._LSD_debug == 1.0 && !isdefined( frames ) )
	{
		thread draw_line( from, to, color );
	}
	else if ( isdefined( level._LSD_debug ) && level._LSD_debug == 1.0 )
		thread draw_line( from, to, color, frames);
}

draw_text( msg, color, ent, offset, frames )
{
	//println ( "debug_text" );
	//level endon( "NightRaven_done" );
	if( frames == 0 )
	{
		while ( isdefined( ent ) )
		{
			print3d( ent.origin+offset, msg , color, 0.5, 4 );
			wait 0.05;
		}
	}
	else
	{
		for( i=0; i < frames; i++ )
		{
			if( !isdefined( ent ) )
				break;
			print3d( ent.origin+offset, msg , color, 0.5, 4 );
			wait 0.05;
		}
	}
}

draw_line( from, to, color, frames )
{
	//println ( "draw_line" );
	//level endon( "NightRaven_done" );
	if( isdefined( frames ) )
	{
		for( i=0; i<frames; i++ )
		{
			line( from, to, color );
			wait 0.05;
		}		
	}
	else
	{
		for( ;; )
		{
			line( from, to, color );
			wait 0.05;
		}
	}
}

addToLSDList()
{
	//println ( "addToLSDList" );
	level._LSDs[self getEntityNumber()] = self;	
}

removeFromLSDList( entityNumber )
{
	//println ( "removeFromLSDList" );
	level._LSDs[entityNumber] = undefined;
}	

playFlareFx()
{
	//println ( "playFlareFx" );
	for ( i = 0; i < 10; i++ )
	{
		if ( !isDefined( self ) )
			return;
		PlayFXOnTag( level._effect[ "ac130_flare" ], self, "TAG_FLARE" );
		wait ( 0.15 );
	}
}


deployFlares()
{
	//println ( "deployFlares" );
	flareObject = spawn( "script_origin", level._ac130.planemodel.origin );
	flareObject.angles = level._ac130.planemodel.angles;

	flareObject moveGravity( (0, 0, 0), 5.0 );
	
	flareObject thread deleteAfterTime( 5.0 );

	return flareObject;
}


LSD_flares_monitor()
{
	//println ( "LSD_flares_monitor" );
	level endon ( "game_ended" );
	
	for ( ;; )
	{
		level waittill ( "stinger_fired", player, missile, lockTarget );
		
		if ( !IsDefined( lockTarget ) || (lockTarget != self) )
			continue;
		
		missile endon ( "death" );
		
		self thread playFlareFx();	
		newTarget = self deployFlares();
		missile Missile_SetTargetEnt( newTarget );
		return;
	}	
}

deleteAfterTime( delay )
{
	//println ( "deleteAfterTime" );
	wait ( delay );
	
	self delete();
}

LSD_getTeamForSoundClip()
{
	//println ( "LSD_getTeamForSoundClip" );
	teamname = self.team;
	if( level._multiTeamBased )
	{
		teamname = "allies";
	}
	return teamname;
}
//*******************************************************************
//                      End of debug functions                      *
//                                                                  *
//*******************************************************************