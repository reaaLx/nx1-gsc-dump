#include maps\mp\_utility;
#include common_scripts\utility;


// Each Killstreak has its own initialization function.  This Script has two main purposes.
// (1). All global data and assets used by this killstreak should be initialized here.
// (2). The callback that executes when a player activates this killstreak should be set here.
// TODO: A call to this script must be added to the script init() in the file c:\trees\nx1\game\share\raw\maps\mp\killstreaks\_killstreaks.gsc, 
// this is were each individual killstreak is initialized.
init()
{
	//This is a good place to precache assets, load up fx, or setup any global data that might be needed, NOTE: Everything defined in killstreakTable.csv
	//will be precached automatically ( see initKillstreakData() in _killstreaks.gsc if interested ) so you do not need to worry about initializing the
	//strings/weapons/materials/sounds defined there.  If, for example, you were going to manually script up a plane flyiing over when this killstreak was 
	//activated you would want to precache that model here.
	
	
	//load the fx 
	level._effect[ "blueshell" ] = loadfx( "nx/misc/prototype_saul" );
	
	
	//This is were the killstreak activation callback is set
	//TODO: Replace "killstreak_template" with the name of the new killstreak as defined in killstreakTable.csv
	//Most killstreaks use a try fuction ( which i recommend, even if it is not necessary for this particualr killstreak it is nice to have a consistent model )
	//the try script will make sure it is ok to fire the killstreak before the actual killstreak script is called.
	level._killstreakFuncs["blueshell"] = ::try_use_killstreak;
	
	
	//Use this script to update/initialize players as they connect to the game
	level thread onPlayerConnect();
}


// This script is running on the global level object, it monitors players connecting to the game.
// Its main purpose is to apply the onPlayerSpawned script to each player as they connect to the game.
onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
	}
}


// This script is running on each player in the game, it recieves a notification each time the player it is running on spawns in the game
// Its main purpose is to initialize any per player data, as well as update the player subject to any global killstreak data when that player spawns.
onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill( "spawned_player" );
		println( "player spwaned" );
		
		// init/manage any per player killstreak data here
	}
}

//Many of the killstreaks have a try block that will test level conditions to make sure it is ok to fire the killstreak now.  A good example of this is for the air killstreaks.
//Only a certain number of vehicles are allowed in the air at any given time, so if the airspace is full and the killstreak cannot be fired this try should return false.
//If there are any preconditions that must be met in order to fire this killstreak they should be checked in this script.
//NOTE:  If this script returns true the killstreak system will consider this killstreak usage complete and the dpad icon will be removed, if this script returns false nothing will
//change and the system will just continue to wait for the the player to activate the killstreak by pressing right on the dpad.
try_use_killstreak( lifeId )
{
	is_ok_to_use_killstreak = true;
	
	if( is_ok_to_use_killstreak )
	{
		if( killstreak_template_use( lifeId ))
		{
			return true;
		}
	}

	return false;
}


// This is the callback that executes when the killstreak is activated by a player pressing on the dpad.  This is called from the script killstreakUsePressed()
// located in the file _killstreaks.gsc
killstreak_template_use( lifeId )
{
	assert( isDefined( self ) );
	println( "Killstreak Template Fired!!" );
	
	player = self getHighestKillstreakPlayerNotOnMyTeam();
	
	//if we couldnt find a target bail out.
	if( !isDefined( player )) 
	{
		return false;
	}
	
	fxObj = player createFxObj();
	
	wait( 0.10 );  //wait two server frames before playing fx
	
	fxobj thread doTheFx();
	fxobj thread waitAndDelete( 10.0 );
	
	wait( 1.6 );
	player playSound( "prototype_missile_incoming" );

	//  This works
	/*
	PlayFX( level._effect["blueshell"], player.origin );
	wait( 1.7 );
	player playSound( "prototype_missile_incoming" );
	*/
	
	wait( 3.4 );
	RadiusDamage( fxobj.origin, 100, 300, 25, self );

	return true;
}

waitAndDelete( time )
{
	wait( time );
	self delete();
}

doTheFx()
{
	PlayFXOnTagForClients( level._effect["blueshell"], self, "TAG_ORIGIN", level._players );
}

createFxObj()
{
	tag_origin = spawn( "script_model", self.origin );
	tag_origin setmodel( "tag_origin" );
	
	//tag_origin hide();
	
	if ( isdefined( self.origin ) )
		tag_origin.origin = self.origin;
	if ( isdefined( self.angles ) )
		tag_origin.angles = self.angles;

	return tag_origin;
}

getHighestKillstreakPlayerNotOnMyTeam()
{
	team = self.pers["team"];
	curr_highest_killstreak = -1;
	curr_player = undefined;
	
	//TagZP<TODO> add los checks from above to make sure the player is outside.
	
	//possibly return a list of random targets for fun.
	
	//possibly use player score insted of killstreak to select a target.
	
	//this implies that we are in a team based game mode such as TDM or DOM
	if( level._teamBased )
	{
		foreach( player in level._players )
		{
			//if the player is not on my team check if they have the highest killstreak!!!!!
			if( player.pers["team"] != team )
			{
				if( player.pers["cur_kill_streak"] > curr_highest_killstreak )
				{
					curr_highest_killstreak = player.pers["cur_kill_streak"];
					curr_player = player;
				}
			}
		}
	}
	else
	{
		//If we are not in a team based game we must be in a FFA game
		foreach( player in level._players )
		{
			//if the player is not on my team kill them!!!!!
			if( player != self )
			{
				if( player.pers["cur_kill_streak"] > curr_highest_killstreak )
				{
					curr_highest_killstreak = player.pers["cur_kill_streak"];
					curr_player = player;
				}
			}
		}
	}
	
	assert( isDefined( curr_player ));
	return curr_player;
}


// A helper script that will kill a player.  Used by the example killstreak.
killPlayer( player )
{
	player thread [[level._callbackPlayerDamage]](
		self, // eInflictor The entity that causes the damage.(e.g. a turret)
		self, // eAttacker The entity that is attacking.
		500, // iDamage Integer specifying the amount of damage done
		0, // iDFlags Integer specifying flags that are to be applied to the damage
		"MOD_SUICIDE", // sMeansOfDeath Integer specifying the method of death  MOD_RIFLE_BULLET
		player.primaryweapon, // sWeapon The weapon number of the weapon used to inflict the damage
		player.origin, // vPoint The point the damage is from?
		(0, 0, 0), // vDir The direction of the damage
		"none", // sHitLoc The location of the hit
		0 // psOffsetTime The time offset for the damage
	);
}