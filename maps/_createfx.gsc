#include common_scripts\utility;
#include maps\_utility;
#include common_scripts\_createFxMenu;
#include common_scripts\_createfx;
#include common_scripts\_fx;

createfx()
{
	// tagPP<NOTE> by the time createfx is called, player position is already updated so those 2 functions don't work anymore.
	level._func_position_player = ::func_position_player;
	level._func_position_player_get = ::func_position_player_get;
	
	level._func_loopfxthread = ::loopfxthread;
	level._func_oneshotfxthread = ::oneshotfxthread;
	level._func_create_loopsound = ::create_loopsound;
	level._func_updatefx = ::restart_fx_looper;
	level._func_process_fx_rotater = ::process_fx_rotater;
	level._mp_createfx = false;

	// tagPP<NOTE> what do they do?
	// level.func_exploder_preload = ::exploder_before_load;
	// level.func_exploder_postload = ::exploder_after_load;
	
	// SP only stuff
	ai = getaiarray();
	for ( i = 0;i < ai.size;i++ )
	{
		ai[ i ] delete();
	}
		
	// build _effect_keys array
	func_get_level_fx(); 
	
	// createFX thread
	thread createFxLogic();

	// remove triggers, turn on painter.
	createfx_common();

	level waittill( "eternity" );
}

func_position_player_get( lastPlayerOrigin )
{
	if ( distance( lastPlayerOrigin, level._player.origin ) > 64 )
	{
		// save the players position so we can go back here on a map restart
		setdvar( "createfx_playerpos_x", level._player.origin[ 0 ] );
		setdvar( "createfx_playerpos_y", level._player.origin[ 1 ] );
		setdvar( "createfx_playerpos_z", level._player.origin[ 2 ] );
	}

	return level._player.origin;
}

func_position_player()
{
	// if we're still on the same map then..
	// set the players position so map restart doesnt move your origin in createfx
	// ## this is not working anymore. maybe it was working before. Peter Pon ##

	playerPos = [];
	playerPos[ 0 ] = getdvarint( "createfx_playerpos_x" );
	playerPos[ 1 ] = getdvarint( "createfx_playerpos_y" );
	playerPos[ 2 ] = getdvarint( "createfx_playerpos_z" );
	level._player setOrigin( ( playerPos[ 0 ], playerPos[ 1 ], playerPos[ 2 ] ) );
	
	// level._player restore_for_createfx();
}
