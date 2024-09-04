#include maps\mp\_utility;
#include common_scripts\utility;

setPortableRadar()
{
	println( "called setPortableRadar" );
	
	self _giveWeapon( "portable_radar_mp", 0 );
	self giveStartAmmo( "portable_radar_mp" );
	
	self thread monitorPortableRadarUse();
}

unsetPortableRadar()
{
	self notify( "end_monitorPortableRadarUse" );
}

deletePortableRadar( portable_radar )
{
	if ( !isDefined( portable_radar ) )
		return;
	
	portable_radar notify( "death" );
	portable_radar Delete();
	
	self.deployedPortableRadar = undefined;
}

monitorPortableRadarUse()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );

	for ( ;; )
	{
		// grenade is the entity spawned by the G_FireGrenade() since we want this to be
		// script controlled, we won't actually use this entity
		self waittill( "grenade_fire", grenade, weapName );
		
		if ( weapName != "portable_radar_mp" )
			continue;
			
		println( "A portable radar has been fired" );

		if( isDefined( self.deployedPortableRadar ) )
		{
			println( "Deleting the other portable radar you have deployed" );
			deletePortableRadar( self.deployedPortableRadar );
		}
		
		grenade waittill( "missile_stuck" );
		println( "Portable radar is has missile_stuck" );
		
		GroundPosition = grenade.origin;
		
		grenade Delete();
		
		portable_radar = spawn( "script_model", GroundPosition );
		portable_radar.health = 100;
		portable_radar.team = self.team;
		portable_radar.owner = self;
		
		portable_radar setCanDamage( true );
		
		portable_radar makePortableRadar( self );
		portable_radar portableRadarSetup( self );
		portable_radar thread maps\mp\gametypes\_weapons::createBombSquadModel( "weapon_c4_bombsquad", "tag_origin", self );
	
		self.deployedPortableRadar = portable_radar;
		return;
	}
}

portableRadarSetup( owner )
{
	// JCC temp until we get our model
	self setModel( "weapon_c4" );
	
	// setup icons for item so friendlies see it
	if ( level._teamBased )
		self maps\mp\_entityheadIcons::setTeamHeadIcon( self.team , (0,0,20) );
	else
		self maps\mp\_entityheadicons::setPlayerHeadIcon( owner, (0,0,20) );

	self thread portableRadarDamageListener( owner );
	self thread portableRadarUseListener( owner );
	owner thread portableRadarWatchOwner( self );
	self thread portableRadarBeepSounds();
}

portableRadarWatchOwner( portable_radar )
{
	portable_radar endon( "death" );
	level endon ( "game_ended" );
	
	self waittill_any( "disconnect", "joined_team", "joined_spectators", "death" );
	
	level thread deletePortableRadar( portable_radar );
}

portableRadarBeepSounds()
{
	self endon( "death" );
	level endon ( "game_ended" );

	for ( ;; )
	{
		wait ( 2.0 );
		self playSound( "sentry_gun_beep" );
	}
}

portableRadarDamageListener( owner )
{
	self endon ( "death" );
	
	// use a health buffer to prevent dying to friendly fire
	healthBuffer = 20000;
	self.health += healthbuffer;

	for ( ;; )
	{
		self waittill ( "damage", amount, attacker );

		if ( level._teambased && isDefined( attacker.team ) && attacker.team == self.team )
		{
			self.health += amount;
			continue;
		}
		
		if ( self.health - healthbuffer < 0 )
		{
			if ( isDefined( owner ) && attacker != owner )
			{
				// JCC commented out
				//attacker notify ( "destroyed_insertion", owner );
				attacker notify( "destroyed_explosive" ); // count towards SitRep Pro challenge
				
				// JCC commented out
				//owner thread leaderDialogOnPlayer( "ti_destroyed" );
			}
			
			// JCC temp playing sounds and effects from other weapons until we have the right ones
			self playsound( "sentry_explode" );
			self.c4DeathEffect = playFX( level.c4Death, self.origin );
			attacker thread deletePortableRadar( self );
		}
	}
}

portableRadarUseListener( owner )
{
	self endon ( "death" );
	level endon ( "game_ended" );
	owner endon ( "disconnect" );
	
	self setCursorHint( "HINT_NOICON" );
	self setHintString( &"MP_PICKUP_PORTABLE_RADAR" );
	self setSelfUsable( owner );

	for ( ;; )
	{
		self waittill ( "trigger", player );
		
		player playLocalSound( "scavenger_pack_pickup" );
		
		// give item to user (only if they haven't restocked from scavenger pickup since dropping)		
		if ( player getAmmoCount( "portable_radar_mp" ) == 0 )
			player setPortableRadar();
	
		player thread deletePortableRadar( self );
	}
}