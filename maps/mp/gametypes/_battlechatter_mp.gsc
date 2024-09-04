#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	if( level._multiTeamBased == true )
	{
		for( i = 0; i < level._teamNameList.size; i++ )
		{
			level._isTeamSpeaking[level._teamNameList[i]] = false;
			level._speakers[level._teamNameList[i]] = [];
		}
	}
	
	level._isTeamSpeaking["allies"] = false;
	level._isTeamSpeaking["axis"] = false;
	
	level._speakers["allies"] = [];
	level._speakers["axis"] = [];
	
	level._bcSounds = [];
	level._bcSounds["reload"] = "inform_reloading_generic";
	level._bcSounds["frag_out"] = "inform_attack_grenade";
	level._bcSounds["flash_out"] = "inform_attack_flashbang";
	level._bcSounds["smoke_out"] = "inform_attack_smoke";
	level._bcSounds["conc_out"] = "inform_attack_stun";
	level._bcSounds["c4_plant"] = "inform_attack_thwc4";
	level._bcSounds["claymore_plant"] = "inform_plant_claymore";
	level._bcSounds["kill"] = "inform_killfirm_infantry";
	level._bcSounds["casualty"] = "inform_casualty_generic";

	level thread onPlayerConnect();	
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill ( "connected", player );

		player thread onPlayerSpawned();
	}
}


onPlayerSpawned()
{
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "spawned_player" );
		
		// help players be stealthy in splitscreen by not announcing their intentions
		if ( level._splitscreen )
			continue;
		
		self thread claymoreTracking();
		self thread reloadTracking();
		self thread grenadeTracking();
	}
}


claymoreTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	while(1)
	{
		self waittill( "begin_firing" );
		weaponName = self getCurrentWeapon();
		if ( weaponName == "claymore_mp" )
			level thread sayLocalSound( self, "claymore_plant" );
	}
}


reloadTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	for( ;; )
	{
		self waittill ( "reload_start" );
		level thread sayLocalSound( self, "reload" );
	}
}


grenadeTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	for( ;; )
	{
		self waittill ( "grenade_fire", grenade, weaponName );
		
		if ( weaponName == "frag_grenade_mp" )
			level thread sayLocalSound( self, "frag_out" );
		else if ( weaponName == "flash_grenade_mp" )
			level thread sayLocalSound( self, "flash_out" );
		else if ( weaponName == "concussion_grenade_mp" )
			level thread sayLocalSound( self, "conc_out" );
		else if ( weaponName == "smoke_grenade_mp" )
			level thread sayLocalSound( self, "smoke_out" );
		else if ( weaponName == "c4_mp" )
			level thread sayLocalSound( self, "c4_plant" );
	}
}


sayLocalSoundDelayed( player, soundType, delay )
{
	player endon ( "death" );
	player endon ( "disconnect" );
	
	wait ( delay );
	
	sayLocalSound( player, soundType );
}


sayLocalSound( player, soundType )
{
	player endon ( "death" );
	player endon ( "disconnect" );

	if ( isSpeakerInRange( player ) )
		return;
		
	if( player.team != "spectator" )
	{	
		prefix = maps\mp\gametypes\_teams::getTeamVoicePrefix( player.team ) + "1_";
		soundAlias = prefix + level._bcSounds[soundType];
		player thread doSound( soundAlias );
	}
}


doSound( soundAlias )
{
	team = self.pers["team"];
	level addSpeaker( self, team );
	self playSoundToTeam( soundAlias, team, self );
	self thread timeHack( soundAlias ); // workaround because soundalias notify isn't happening
	self waittill_any( soundAlias, "death", "disconnect" );
	level removeSpeaker( self, team );
}


timeHack( soundAlias )
{
	self endon ( "death" );
	self endon ( "disconnect" );

	wait ( 2.0 );
	self notify ( soundAlias );
}


isSpeakerInRange( player )
{
	player endon ( "death" );
	player endon ( "disconnect" );

	distSq = 1000 * 1000;

	// to prevent player switch to spectator after throwing a granade causing damage to someone and result in attacker.pers["team"] = "spectator"
	if( isdefined( player ) && isdefined( player.pers["team"] ) && player.pers["team"] != "spectator" )
	{
		for ( index = 0; index < level._speakers[player.pers["team"]].size; index++ )
		{
			teammate = level._speakers[player.pers["team"]][index];
			if ( teammate == player )
				return true;
				
			if ( distancesquared( teammate.origin, player.origin ) < distSq )
				return true;
		}
	}

	return false;
}


addSpeaker( player, team )
{
	level._speakers[team][level._speakers[team].size] = player;
}


// this is lazy... fix up later by tracking ID's and doing array slot swapping
removeSpeaker( player, team )
{
	newSpeakers = [];
	for ( index = 0; index < level._speakers[team].size; index++ )
	{
		if ( level._speakers[team][index] == player )
			continue;
			
		newSpeakers[newSpeakers.size] = level._speakers[team][index]; 
	}
	
	level._speakers[team] = newSpeakers;
}