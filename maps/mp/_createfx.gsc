#include common_scripts\utility;
#include maps\mp\_utility;
#include common_scripts\_createFxMenu;
#include common_scripts\_createfx;
#include common_scripts\_fx;

createfx()
{
	// tagPP<NOTE> by the time createfx is called, player position is already updated so those 2 functions don't work anymore.
	level._func_position_player = ::void;
	level._func_position_player_get = ::func_position_player_get;

	level._func_loopfxthread = ::loopfxthread;
	level._func_oneshotfxthread = ::oneshotfxthread;
	level._func_create_loopsound = ::create_loopsound;
	level._func_updatefx = ::restart_fx_looper;
	level._func_process_fx_rotater = ::process_fx_rotater;
	level._mp_createfx = true;

	// tagPP<NOTE> what do they do?
	// level.func_exploder_preload = ::exploder_before_load;
	// level.func_exploder_postload = ::exploder_after_load;


	// MP only stuff
	// level._callbackStartGameType = ::void; // Take it out because it broke server/client message.
	level._callbackPlayerConnect = ::void;
	level._callbackPlayerDisconnect = ::void;
	level._callbackPlayerDamage = ::void;
	level._callbackPlayerKilled = ::void;
	level._callbackCodeEndGame = ::void;
	level._callbackPlayerLastStand = ::void;
	level._callbackPlayerConnect = ::Callback_PlayerConnect;
	level._callbackPlayerMigrated = ::void;

	// build _effect_keys array
	func_get_level_fx(); 

	// remove triggers, turn on painter.
	createfx_common();

	level waittill( "eternity" );
}

func_position_player_get( lastPlayerOrigin )
{
	return level._player.origin;
}

Callback_PlayerConnect()
{
	self waittill( "begin" );

	if ( !isdefined( level._player ) )
	{
		spawnpoints = getentarray( "mp_global_intermission", "classname" );

		self spawn( spawnpoints[0].origin, spawnpoints[0].angles );
		self maps\mp\gametypes\_playerlogic::updateSessionState( "playing", "" );
		self.maxhealth = 10000000;
		self.health = 10000000;
		
		level._player = self;
		
		// createFX thread
		thread createFxLogic();

		// hack
		thread ufo_mode();
	}
	else
	{
		kick( self GetEntityNumber() );
	}
}

ufo_mode()
{
	// painter.menu execs some console commands( ufo mode ).. sneaky hacks.
	level._player openpopupmenu( "painter_mp" );
	level._player closepopupmenu( "painter_mp" );
}