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
	
	
	//generally any global data that is needed would be stored in the level object, here is an example
	//level._effect[ "emp_flash" ] = loadfx( "explosions/emp_flash_mp" );
	
	
	//This is were the killstreak activation callback is set
	//TODO: Replace "killstreak_template" with the name of the new killstreak as defined in killstreakTable.csv
	//Most killstreaks use a try fuction ( which i recommend, even if it is not necessary for this particualr killstreak it is nice to have a consistent model )
	//the try script will make sure it is ok to fire the killstreak before the actual killstreak script is called.

	precacheString ( &"MP_AIR_SPACE_TOO_CROWDED" );
	precacheString ( &"MP_HOLD_USERELOAD_TO_THROWAWAY" );

	level._killstreakFuncs["weapdrop"] = ::try_use_weapdrop;
	
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
try_use_weapdrop()
{
	is_ok_to_use_killstreak = true;
	
	if( is_ok_to_use_killstreak )
	{
		weapdrop_use();
		return true;
	}

	return false;
}


// This is the callback that executes when the killstreak is activated by a player pressing on the dpad.  This is called from the script killstreakUsePressed()
// located in the file _killstreaks.gsc
weapdrop_use()
{
	assert( isDefined( self ) );
	//println( "Killstreak Template Fired!!" );
	
	/*
	// don't allow use if theres 3 or more little birds up in the air already.  this is consistent with the care package drop ks.
	if ( level._littleBirds >= 3 )
	{
		self iPrintLnBold( &"MP_AIR_SPACE_TOO_CROWDED" );
		return false;
	} 
	*/
	
	weapdrop_weapon = undefined;

	// randomInt is confusing.  0 based and the number passed is how many ints it can return.  4 = 0-3.
	switch( randomInt( 4 ) )
	{
		case 0:
			weapdrop_weapon = "augks_mp";
			break;
		case 1:
			weapdrop_weapon = "xm25ks_mp";
			break;
		case 2:
			weapdrop_weapon = "aa12_akimbo_mp";
			break;
		case 3:
			weapdrop_weapon = "javelinks_mp";
			break;
	}

	// spawn a new script to give and switch to the weapdrop weapon
	// the drop ks's need to return true asap otherwise you're still holding the trigger in your hand
	self thread weapdrop_equip( weapdrop_weapon );
	return true;
}

weapdrop_equip( weapdrop_weapon )
{
	self endon( "death" );
	self endon( "disconnect" );

	assert( isDefined( weapdrop_weapon ) );

	// hack.  sometimes getCurrentWeapon will return none but getWeaponsListPrimaries wont...hmm...
	/*
	initial_weapon = self getCurrentWeapon();
	if ( initial_weapon == "none" )
	{
		weapList = self GetWeaponsListPrimaries();
		initial_weapon = weapList[0];
	}
	//printLn( initial_weapon );
	*/


	// make sure the script that spawned this one has returned true before I switch your weapon.  this is probably unnecessary.
	wait .1;

	// akimbo weapons must be given a specific way.
	if ( weapdrop_weapon == "aa12_akimbo_mp" )
	{
		self giveWeapon( weapdrop_weapon, 0 , true );
	}
	else
	{
		self giveWeapon( weapdrop_weapon );
	}

	self switchToWeapon( weapdrop_weapon );

	for( ;; )
	{
		// when you run out of ammo, switch back to your first primary and take the weapdrop weapon
		if ( self hasWeapon ( weapdrop_weapon ) )
		{
			if ( self getAmmoCount( weapdrop_weapon ) == 0 )
			{
				//self switchToWeapon( initial_weapon );
				self takeWeapon ( weapdrop_weapon );
				break;
			}
		}
		else
		{
			break;
		}
		wait 0.05;
	}
	//printLn( "NO LONGER HAS KS WEAPON" );
}

weapdrop_hud()
{
	hudelem = newClientHudElem( self );
	// put something on screen that tells you, you can throw away this weapon
	hudelem.x = -30;
	hudelem.y = -20;
	hudelem.alignX = "left";
	hudelem.alignY = "bottom";
	hudelem.horzAlign = "center";
	hudelem.vertAlign = "bottom";
	hudelem.sort = 1;// force to draw after the background
	hudelem.foreground = true;
	hudelem SetText( &"MP_HOLD_USERELOAD_TO_THROWAWAY" );
	hudelem.alpha = 0;
	hudelem FadeOverTime( 0.2 );
	hudelem.alpha = 1;
	hudelem.hidewheninmenu = true;
	hudelem.fontScale = 1.25;
	hudelem.font = "fwmed";
	//hudelem.color = ( getdvarfloat( "color_neutral_r" ), getdvarfloat( "color_neutral_g" ), getdvarfloat( "color_neutral_b" ) );
	//hudelem SetPulseFX( 30, duration, 700 );// something, decay start, decay duration

	self waittill_any( "death", "disconnect", "weapdrop_done" );

	hudelem Destroy();
}