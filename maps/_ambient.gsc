#include maps\_utility;
#include maps\_equalizer;
#include common_scripts\utility;

/* 			Example map_amb.gsc file:
main()
{
	// Set the underlying ambient track
	level.ambient_track [ "exterior" ] = "ambient_test";
	thread maps\_utility::set_ambient( "exterior" );

	// Set the eq filter for the ambient channels
	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- - 	
	//   define a filter and give it a name
	//   or use one of the presets( see _equalizer.gsc )
	//   arguments are: name, band, type, freq, gain, q
	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- - 
	// maps\_equalizer::defineFilter( "test", 0, "lowshelf", 3000, 6, 2 );
	// maps\_equalizer::defineFilter( "test", 1, "highshelf", 3000, -12, 2 );
	// maps\_equalizer::defineFilter( "test", 2, "bell", 1500, 6, 3 );
	
	// attach the filter to a region and channel
	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	add_channel_to_filter( track, channel )	

		
	ambientDelay( "exterior", 1.3, 3.4 );// Trackname, min and max delay between ambient events
	ambientEvent( "exterior", "burnville_foley_13b", 			 0.3 );
	ambientEvent( "exterior", "boat_sink", 					 0.6 );
	ambientEvent( "exterior", "bullet_large_canvas", 			 0.3 );
	ambientEvent( "exterior", "explo_boat", 					 1.3 );
	ambientEvent( "exterior", "Stuka_hit", 					 0.1 );
	
	ambientEventStart( "exterior" );
}
*/ 

init()
{
	level._ambient_zones = [];

	
	// this function can be overwritten to do custom stuff when an ambience trigger is hit
	if ( !isdefined( level._global_ambience_blend_func ) )
		level._global_ambience_blend_func = ::empty_amb;

	add_zone( "ac130" );
	add_zone( "alley" );
	add_zone( "bunker" );
	add_zone( "city" );
	add_zone( "container" );
	add_zone( "exterior" );
	add_zone( "exterior1" );
	add_zone( "exterior2" );
	add_zone( "exterior3" );
	add_zone( "exterior4" );
	add_zone( "exterior5" );
	add_zone( "forrest" );
	add_zone( "hangar" );
	add_zone( "interior" );
	add_zone( "interior_metal" );
	add_zone( "interior_stone" );
	add_zone( "interior_vehicle" );
	add_zone( "interior_wood" );
	add_zone( "mountains" );
	add_zone( "pipe" );
	add_zone( "shanty" );
	add_zone( "snow_base" );
	add_zone( "snow_cliff" );
	add_zone( "tunnel" );
	add_zone( "underpass" );
	
	/#
	create_ambience_hud();
	#/

	if ( !isdefined( level._ambientEventEnt ) )
		level._ambientEventEnt = [];

	if ( !isDefined( level._ambient_reverb ) )
		level._ambient_reverb = [];

	if ( !isDefined( level._ambient_eq ) )
		level._ambient_eq = [];
		
	if ( !isDefined( level._ambient_volume ) )
	{
		level._ambient_volume = [];
	}

	if ( !isDefined( level._fxfireloopmod ) )
		level._fxfireloopmod = 1;

	level._reverb_track = "";
	level._eq_main_track = 0;
	level._eq_mix_track = 1;
	level._volume_track = "";
	level._eq_track[ level._eq_main_track ] = "";
	level._eq_track[ level._eq_mix_track ] = "";

	// used to change the meaning of interior / exterior / rain ambience midlevel.
	level._ambient_modifier[ "interior" ] = "";
	level._ambient_modifier[ "exterior" ] = "";
	level._ambient_modifier[ "rain" ] = "";

	// loads any predefined filters in _equalizer.gsc
	loadPresets();
	
	thread hud_hide_with_cg_draw_hud();
}

empty_amb( p, i, o )
{
}


// starts this ambient track
activateAmbient( ambient )
{
	thread set_ambience_single( ambient );
}


ambientVolume()
{
	for ( ;; )
	{
		self waittill( "trigger" );
		activateAmbient( "interior" );
		while ( level._player isTouching( self ) )
			wait 0.1;
		activateAmbient( "exterior" );
	}
}

/*
=============
///ScriptDocBegin
"Name: create_ambient_event( <track> , <min_time> , <max_time> )"
"Summary: Create an ambient event system. It plays random ambient sounds."
"Module: Ambient"
"MandatoryArg: <track>: What to name it"
"MandatoryArg: <min_time>: The minimum time between sounds"
"MandatoryArg: <track>: The max time between sounds"
"Example: event = create_ambient_event( "dcburning_bunker1", 5.0, 15.0 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
create_ambient_event( track, min_time, max_time )
{
	assertex( isdefined( level._eq_defs ), "_load must run before loading the _amb file for a map." );
	assertex( !isdefined( level._ambientEventEnt[ track ] ), "Already created ambient event " + track );
	assertEX( max_time > min_time, "Ambient max must be greater than min for track " + track );

	event = spawnstruct();
	event.min = min_time;
	event.range = max_time - min_time;
	event.event_alias = [];
	event.event_alias_no_block = [];
	event.track = track;
	
	level._ambientEventEnt[ track ] = event;
	/#
	event thread assert_event_has_aliases();
	#/
	return event;
}

assert_event_has_aliases()
{
	waittillframeend;
	assertex( self.event_alias.size > 0 || self.event_alias_no_block.size > 0, "Added ambient event system " + self.track + " with no aliases." );
}

/*
=============
///ScriptDocBegin
"Name: add_to_ambient_event( <name> , <weight> )"
"Summary: Add a sound alias to an ambient event system."
"Module: Ambient"
"CallOn: An ambient event system (spawnstruct)"
"MandatoryArg: <name>: The sound alias"
"MandatoryArg: <weight>: How often to play relative to other aliases in the system"
"Example: event add_to_ambient_event( "elm_quake_sub_rumble", 1.0 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
add_to_ambient_event( name, weight )
{
	assertex( !isdefined( self.event_alias[ name ] ), "Cant change an ambient event weight for an alias (track " + self.track + ", alias " + name + ")" );
	self.event_alias[ name ] = weight;
}

/*
=============
///ScriptDocBegin
"Name: add_to_ambient_event_no_block( <name> , <weight> )"
"Summary: Add a sound alias to an ambient event system. This sound will not block other ambiences from playing after it."
"Module: Ambient"
"CallOn: An ambient event system (spawnstruct)"
"MandatoryArg: <name>: The sound alias"
"MandatoryArg: <weight>: How often to play relative to other aliases in the system"
"Example: event add_to_ambient_event( "elm_quake_sub_rumble", 1.0 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
add_to_ambient_event_no_block( name, weight )
{
	assertex( !isdefined( self.event_alias_no_block[ name ] ), "Cant change an ambient event weight for an alias (track " + self.track + ", alias " + name + ")" );
	self.event_alias_no_block[ name ] = weight;
}

/*
=============
///ScriptDocBegin
"Name: map_to_reverb_eq( <eqReverb> )"
"Summary: Map an ambient event system to reverb or eq tracks. So when the ambient event is activated, appropriate reverb and eq get activated too."
"Module: Ambient"
"CallOn: An ambient event system (spawnstruct)"
"MandatoryArg: <eqReverb>: The eq/reverb type to map to. For example exterior, bunker, alley, etc."
"Example: event map_to_reverb_eq( "bunker" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
map_to_reverb_eq( eqReverb )
{
//	assertex( !isdefined( self.remap ), "Tried to remap reverb/eq mapping " + self.track );
//	self.remap = eqReverb;
	
	// copy the reverb/eq settings over the specified settings
	level._eq_defs[ self.track ] = level._eq_defs[ eqReverb ];
	level._ambient_eq[ self.track ] = level._ambient_eq[ eqReverb ];
	level._ambient_reverb[ self.track ] = level._ambient_reverb[ eqReverb ];
}

map_to_reverb_eq_vol( eqReverbVol )
{	
	// copy the reverb/eq settings over the specified settings
	level._eq_defs[ self.track ] = level._eq_defs[ eqReverbVol ];
	level._ambient_eq[ self.track ] = level._ambient_eq[ eqReverbVol ];
	level._ambient_reverb[ self.track ] = level._ambient_reverb[ eqReverbVol ];
	level._ambient_volume[ self.track ] = level._ambient_volume[ eqReverbVol ];
}

ambientDelay( track, min, max )
{
	create_ambient_event( track, min, max );
}

ambientEvent( track, name, weight )
{
	assertEX( isdefined( level._ambientEventEnt ), "ambientDelay has not been run" );
	assertEX( isdefined( level._ambientEventEnt[ track ] ), "ambientDelay has not been run" );

	level._ambientEventEnt[ track ] add_to_ambient_event( name, weight );
}

ambientEvent_no_block( track, name, weight )
{
	assertEX( isdefined( level._ambientEventEnt ), "ambientDelay has not been run" );
	assertEX( isdefined( level._ambientEventEnt[ track ] ), "ambientDelay has not been run" );

	level._ambientEventEnt[ track ] add_to_ambient_event_no_block( name, weight );
}



getRemap( track )
{
//	if ( isdefined( self.remap ) )
//		return self.remap;
	if ( track == "exterior" && isdefined( level._remap_exterior ) )
		return level._remap_exterior;
		
	return track;
}

deactivate_reverb()
{
	level._reverb_track = "";
	level._player deactivatereverb( "snd_enveffectsprio_level", 2 );
	clear_hud( "reverb" );
}

//ambientReverb( track )
//{
//	level notify( "reverb_overwrite" );
//	level endon( "reverb_overwrite" );
//	
//	// first check if this track is remapped to a specific reverb
//	track = getRemap( track );
//	
//	reverb = level._ambient_reverb[ track ];
//	
//	if ( !isdefined( reverb ) )
//	{
//		deactivate_reverb();
//		return;
//	}
//	
//	if ( level._reverb_track == track )
//	{
//		// already doing this one
//		return;
//	}
//		
//	level._reverb_track = track;
//	
//	use_reverb_settings( track );
//}

setup_new_reverb_settings( track )
{	
	if ( !isdefined( track ) || !isdefined( level._ambient_reverb[ track ] ) )
	{
		deactivate_reverb();
		return false;
	}

	if ( level._reverb_track == track )
	{
		// already doing this one
		return false;
	}
	
	level._reverb_track = track;

	use_reverb_settings( track );
	return true;
}

refresh_reverb_settings()
{
	if ( IsDefined(level._reverb_track) && IsDefined( level._ambient_reverb[ level._reverb_track ] ) )
	{
		use_reverb_settings( level._reverb_track );
	}
}

refresh_reverb_settings_fade( time )
{
	if ( IsDefined(level._reverb_track) && IsDefined( level._ambient_reverb[ level._reverb_track ] ) )
	{
		use_reverb_settings_fade( level._reverb_track, time );
	}	
}

use_reverb_settings( track )
{
	// red flashing overwrites reverb
	if ( level._player ent_flag( "player_has_red_flashing_overlay" ) )
	{
		return;
	}
	
	//get the new track name with the suit extension, and check if it exists. Change the track if it does exist.
	suit = level._player GetSuitType();	
	suit_track = track + "_" + suit;	
	if ( IsDefined( level._ambient_reverb[ suit_track ] ) )
	{
		track = suit_track;
	}

	if ( !IsDefined( level._ambient_reverb[ track ] ) )
	{
		return;
	}

	reverb = level._ambient_reverb[ track ];
	level._player setReverb( reverb[ "priority" ], reverb[ "roomtype" ], reverb[ "drylevel" ], reverb[ "wetlevel" ], reverb[ "fadetime" ] );
	
	/#
	set_hud_track( "reverb", track );
	#/
}

use_reverb_settings_fade( track, time )
{
	// red flashing overwrites reverb
	if ( level._player ent_flag( "player_has_red_flashing_overlay" ) )
	{
		return;
	}
	
	//get the new track name with the suit extension, and check if it exists. Change the track if it does exist.
	//Ripping this out for DT3273
	//suit = level._player GetSuitType();	
	//suit_track = track + "_" + suit;	
	//if ( IsDefined( level._ambient_reverb[ suit_track ] ) )
	//{
	//	track = suit_track;
	//}

	if ( !IsDefined( level._ambient_reverb[ track ] ) )
	{
		return;
	}

	reverb = level._ambient_reverb[ track ];
	level._player setReverb( reverb[ "priority" ], reverb[ "roomtype" ], reverb[ "drylevel" ], reverb[ "wetlevel" ], time );
	
	/#
	set_hud_track( "reverb", track );
	#/
}

/*
=============
///ScriptDocBegin
"Name: map_exterior_to_reverb_eq( <reverb_eq> )"
"Summary: Reverb and EQ will use this setting when "exterior" ambience is triggered."
"Module: Ambient"
"MandatoryArg: <reverb_eq>: The reverb/eq that exterior gets mapped to."
"Example: map_exterior_to_reverb_eq( "snow_base" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
map_exterior_to_reverb_eq( reverb_eq )
{
	level._remap_exterior = reverb_eq;
}

ambientMapTo( track, eqReverb )
{
	assertEX( isdefined( level._ambientEventEnt ), "ambientDelay has not been run" );
	assertEX( isdefined( level._ambientEventEnt[ track ] ), "ambientDelay has not been run" );
	level._ambientEventEnt[ track ] map_to_reverb_eq( eqReverb );
}

setup_new_eq_settings( track, eqIndex )
{
	// this track may be a remapped from an ambient event track.
	track = getRemap( track );
	
	if ( !isdefined( track ) || !isdefined( level._ambient_eq[ track ] ) )
	{
		deactivate_index( eqIndex );
		return false;
	}

	if ( level._eq_track[ eqIndex ] == track )
	{
		// already doing this one
		return false;
	}
	
	level._eq_track[ eqIndex ] = track;

	use_eq_settings( track, eqIndex );
	return true;
}

refresh_eq_settings( eqIndex )
{
	refresh_eq_settings_fade( eqIndex, 1.0 );
}

refresh_eq_settings_fade( eqIndex, fade )
{
	if ( IsDefined( level._eq_track ) && IsDefined(level._eq_track[ eqIndex ]) && IsDefined( level._ambient_eq[ level._eq_track[ eqIndex ] ] )  )
	{	
		use_eq_settings_fade( level._eq_track[ eqIndex ], eqIndex, fade );
	}
}

/*
=============
///ScriptDocBegin
"Name: blend_to_eq_track( <eqIndex> , <time> )"
"Summary: Blends from one EQ track to another. NOTE that when you play this command, it will blend from zero to 100% on the track you select. If you were already on this track, this may sound weird."
"Module: Ambience"
"MandatoryArg: <eqIndex>: Which of the two EQ tracks to blend to, main or mix (level.eq_main_track, level.eq_mix_track)"
"OptionalArg: <time>: How much time to blend over."
"Example: thread maps\_ambient::blend_to_eq_track( level.eq_mix_track, 2 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
blend_to_eq_track( eqIndex, time )
{
	interval = .05;
	count = time / interval;
	fraction = 1 / count;
	
	for ( i = 0; i <= 1; i += fraction )
	{
		level._player SetEqLerp( i, eqIndex );
		wait( interval );
	}
	
	level._player SetEqLerp( 1, eqIndex );
}

/*
=============
///ScriptDocBegin
"Name: use_eq_settings( <track> , <eqIndex> )"
"Summary: Enable EQ track settings on one of the two EQ channels."
"Module: Ambience"
"MandatoryArg: <track>: The EQ tracks ettings from _equilizer.gsc"
"MandatoryArg: <eqIndex>: You must select either the main track or the mix track, preferably using level.eq_main_track or level.eq_mix_track. See ::blend_to_eq_track."
"Example: thread maps\_ambient::use_eq_settings( "gulag_cavein", level.eq_mix_track );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
use_eq_settings( track, eqIndex )
{
	use_eq_settings_fade( track, eqIndex, 2.0 );
}

/*
=============
///ScriptDocBegin
"Name: use_eq_settings_fade( <track> , <eqIndex> )"
"Summary: Enable EQ track settings on one of the two EQ channels."
"Module: Ambience"
"MandatoryArg: <track>: The EQ tracks ettings from _equilizer.gsc"
"MandatoryArg: <eqIndex>: You must select either the main track or the mix track, preferably using level.eq_main_track or level.eq_mix_track. See ::blend_to_eq_track."
"MandatoryArg: <time>: The time in seconds to fade to the new setting."
"Example: thread maps\_ambient::use_eq_settings( "gulag_cavein", level.eq_mix_track );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
use_eq_settings_fade( track, eqIndex, time )
{
	// red flashing overwrites eq
	if ( level._player ent_flag( "player_has_red_flashing_overlay" ) )
	{
		return;
	}
	
	//get the new track name with the suit extension, and check if it exists. Change the track if it does exist.
	//Ripping this out for DT3273
	//suit = level._player GetSuitType();	
	//suit_track = track + "_" + suit;	
	//if( IsDefined( level._ambient_eq[ suit_track ] ) )
	//{
	//	track = suit_track;
                //iPrintLn( "EQ = " + track );
	//}
	
	//check if the base track is not defined either.
	if( !IsDefined( level._ambient_eq[ track ] ) )
	{
		return;
	}
	
	foreach ( channel, _ in level._ambient_eq[ track ] )
	{
		filter = getFilter( track );
		if ( !isdefined( filter ) )
			continue;

		if ( isdefined( filter[ "type" ][ 0 ] ) && isdefined( filter[ "type" ][ 1 ] ) && isdefined( filter[ "type" ][ 2 ] ) )
		{
		    level._player seteqbands( channel,
		    						  time,
		    						  eqIndex,
		    						  filter[ "type" ][ 0 ],
		    						  filter[ "gain" ][ 0 ],
		    						  filter[ "freq" ][ 0 ],
		    						  filter[ "q" ][ 0 ],
		    						  filter[ "type" ][ 1 ],
		    						  filter[ "gain" ][ 1 ],
		    						  filter[ "freq" ][ 1 ],
		    						  filter[ "q" ][ 1 ],
		    						  filter[ "type" ][ 2 ],
		    						  filter[ "gain" ][ 2 ],
		    						  filter[ "freq" ][ 2 ],
		    						  filter[ "q" ][ 2 ] );
		}
		else if ( isdefined( filter[ "type" ][ 0 ] ) && isdefined( filter[ "type" ][ 1 ] ) && !isdefined( filter[ "type" ][ 2 ] ) )
		{
			level._player seteqbands( channel,
									  time,
									  eqIndex,
									  filter[ "type" ][ 0 ],
									  filter[ "gain" ][ 0 ],
									  filter[ "freq" ][ 0 ],
									  filter[ "q" ][ 0 ],
									  filter[ "type" ][ 1 ],
									  filter[ "gain" ][ 1 ],
									  filter[ "freq" ][ 1 ],
									  filter[ "q" ][ 1 ] );
		}
		else if ( isdefined( filter[ "type" ][ 0 ] ) && !isdefined( filter[ "type" ][ 1 ] ) && !isdefined( filter[ "type" ][ 2 ] ) )
		{
			level._player seteqbands( channel,
									  time,
									  eqIndex,
									  filter[ "type" ][ 0 ],
									  filter[ "gain" ][ 0 ],
									  filter[ "freq" ][ 0 ],
									  filter[ "q" ][ 0 ] );
		}
		else if ( isdefined( filter[ "type" ][ 0 ] ) && !isdefined( filter[ "type" ][ 1 ] ) && !isdefined( filter[ "type" ][ 2 ] ) )
		{
			level._player deactivateeq( time, eqIndex, channel );
		}		
		else
		{
			// fallback for odd band combination...should probably be an assert in future games.
			for ( band = 0; band < 2; band++ )
			{
				if ( isdefined( filter[ "type" ][ band ] ) )
				{
					level._player seteq( channel,
										 time,
										 eqIndex,
										 band,
										 filter[ "type" ][ band ],
										 filter[ "gain" ][ band ],
										 filter[ "freq" ][ band ],
										 filter[ "q" ][ band ] );
				}
				else
				{
					level._player deactivateeq( time, eqIndex, channel, band );
				}
			}
		}
	}
	
	/#	
	set_hud_track( "eq_" + eqIndex, track );
	#/
}

deactivate_index( eqIndex )
{
	level._eq_track[ eqIndex ] = "";
	level._player deactivateeq( 0.5, eqIndex );
	clear_hud( "eq_" + eqIndex );
}

setup_new_volume_settings( track )
{	
	if ( !IsDefined( track ) || !IsDefined( level._ambient_volume[ track ] ) )
	{
		deactivate_volume();
		return false;
	}

	if ( level._volume_track == track )
	{
		// already doing this one
		return false;
	}
	
	level._volume_track = track;

	use_volume_settings( track );
	return true;
}

refresh_volume_settings()
{
	if ( IsDefined(level._volume_track) && IsDefined( level._ambient_volume[ level._volume_track ] ) )
	{
		use_volume_settings( level._volume_track);
	}
}

refresh_volume_settings_fade( time )
{
	if ( IsDefined(level._volume_track) && IsDefined( level._ambient_volume[ level._volume_track ] ) )
	{
		use_volume_settings_fade( level._volume_track, time );
	}	
}

use_volume_settings( track )
{
	// red flashing overwrites reverb
	if ( level._player ent_flag( "player_has_red_flashing_overlay" ) )
	{
		return;
	}
	
	//get the new track name with the suit extension, and check if it exists. Change the track if it does exist.
	//Ripping this out for DT3273
	//suit = level._player GetSuitType();	
	//suit_track = track + "_" + suit;	
	//if ( IsDefined( level._ambient_volume[ suit_track ] ) )
	//{
	//	track = suit_track;
	//}

	if ( !IsDefined( level._ambient_volume[ track ] ) )
	{
		return;
	}

	volume = level._ambient_volume[ track ];
	
        //iPrintLn( " shock = " + track );
	level._player SetChannelVolumes( volume[ "priority" ], volume[ "shock_file" ], volume[ "fade" ] );
}

use_volume_settings_fade( track, time )
{
	// red flashing overwrites reverb
	if ( level._player ent_flag( "player_has_red_flashing_overlay" ) )
	{
		return;
	}
	
	//get the new track name with the suit extension, and check if it exists. Change the track if it does exist.
	//suit = level._player GetSuitType();	
	//suit_track = track + "_" + suit;	
	//if ( IsDefined( level._ambient_volume[ suit_track ] ) )
	//{
	//	track = suit_track;
	//}

	if ( !IsDefined( level._ambient_volume[ track ] ) )
	{
		return;
	}

	volume = level._ambient_volume[ track ];
	
        //iPrintLn( " shock = " + track );
	level._player SetChannelVolumes( volume[ "priority" ], volume[ "shock_file" ], time );
	
}

deactivate_volume()
{
	level._volume_track = "";
	level._player DeactivateChannelVolumes("snd_channelvolprio_level");
}


ambientEventStart( track )
{
	set_ambience_single( track );
}

start_ambient_event( track )
{
	level notify( "new_ambient_event_track", track );
	level endon( "new_ambient_event_track" );
	
	assertEX( isdefined( level._ambientEventEnt ), "ambientDelay has not been run" );
	assertEX( isdefined( level._ambientEventEnt[ track ] ), "ambientDelay has not been run" );
	/#
	set_hud_track( "event_system", track );
	#/

	if ( !isdefined( level._player.soundEnt ) )
	{
		level._player.soundEnt = spawn( "sound_emitter", ( 0, 0, 0 ) );
		level._player.soundEnt.playingSound = false;
	}
	else
	{
		if ( level._player.soundEnt.playingSound )
			level._player.soundEnt waittill( "sounddone" );
	}

	event = level._ambientEventEnt[ track ];

	ent = level._player.soundEnt;
	min = event.min;
	range = event.range;

	total_aliases = event.event_alias.size + event.event_alias_no_block.size;
	assertEX( total_aliases > 0, "Need more than one ambient event for track " + track );
	
	lastalias = "";
	alias = "";
	
	
	sound_array = [];
	foreach ( soundalias, weight in event.event_alias )
	{
		array = [];
		array[ "stop" ] = true;
		array[ "alias" ] = soundalias;
		array[ "weight" ] = weight;
		sound_array[ sound_array.size ] = array;
	}
	
	foreach ( soundalias, weight in event.event_alias_no_block )
	{
		array = [];
		array[ "stop" ] = false;
		array[ "alias" ] = soundalias;
		array[ "weight" ] = weight;
		sound_array[ sound_array.size ] = array;
	}

	total_weights = get_total_weight_from_array( event.event_alias );
	total_weights += get_total_weight_from_array( event.event_alias_no_block );

	for ( ;; )
	{
		wait( min + randomfloat( range ) );
		item = undefined;
		while ( alias == lastalias )
		{
			item = ambientWeight( sound_array, total_weights );
			alias = item[ "alias" ];
			if ( total_aliases == 1 )
				break;
		}

		lastalias = alias;
		ent.origin = level._player.origin;
		ent MoveTo( level._player.origin + ( randomintrange( -1200, 1200 ), randomintrange( -1200, 1200 ), 0 ), 0.01 );
		wait 0.1;

		timer = gettime();
		if ( item[ "stop" ] )
		{
			ent playsound( alias, "sounddone" );
			ent.playingSound = true;
			ent waittill( "sounddone" );
		}
		else
		{
			ent playsound( alias );
		}
			
		if ( timer == gettime() )
			wait( 0.05 ); // so no infinite loop possibilities
		ent.playingSound = false;
	}
}

get_total_weight_from_array( array )
{
	weight = 0;
	foreach ( index, amt in array )
	{
		weight += amt;
	}	
	return weight;
}

ambientWeight( array, total_weights )
{
	assert( array.size > 0 );

	random_weight = randomfloat( total_weights );
	current_total = 0;
	
	for ( i = 0; i < array.size; i++ )
	{
		item = array[ i ];
		current_total += item[ "weight" ];
		if ( random_weight <= current_total )
			return item;
	}	
	assertmsg( "Impossible!" );
}


add_zone( zone )
{
	level._ambient_zones[ zone ] = true;
}

check_ambience( type )
{
// 	assertEx( isdefined( level.ambient_zones[ type ] ), "Ambience " + type + " is not a defined ambience zone" );
}

ambient_trigger()
{

	// get the ambience zones on this trigger
	tokens = strtok( self.ambient, " " );
	if ( tokens.size == 1 )
	{
		// if this trigger only has one ambience then there is no lerping done
		ambience = tokens[ 0 ];
		for ( ;; )
		{
			self waittill( "trigger", other );
			assertEx( isplayer( other ), "Non - player entity touched an ambient trigger." );
			set_ambience_single( ambience );
		}
	}

	assertEx( isdefined( self.target ), "Ambience trigger at " + self.origin + " has multiple ambient tracks but doesn't target a script origin." );
	ent = get_target_ent();

	start = ent.origin;
	end = undefined;

	if ( isdefined( ent.target ) )
	{
		// if the origin targets a second origin, use it as the end point
		target_ent = ent get_target_ent();
		end = target_ent.origin;
	}
	else
	{
		// otherwise double the difference between the target origin and start to get the endpoint
		end = start + vector_multiply( self.origin - start, 2 );
	}

	dist = distance( start, end );

	assertEx( tokens.size == 2, "Ambience trigger at " + self.origin + " doesn't have 2 ambient zones set. Usage is \"ambient\" \"zone1 zone2\"" );

	inner_ambience = tokens[ 0 ];
	outer_ambience = tokens[ 1 ];

	/#
	check_ambience( inner_ambience );
	check_ambience( outer_ambience );
	#/

	cap = 0.5;
	if ( isdefined( self.targetname ) && self.targetname == "ambient_exit" )
		cap = 0;


	for ( ;; )
	{
		self waittill( "trigger", other );
		//assertEx( isplayer( other ), "Non - player entity touched an ambient trigger." );
		if ( isplayer( other ) )
		{
			progress = undefined;
			while ( other istouching( self ) )
			{
				progress = get_progress( start, end, dist, other.origin );
	
				if ( progress < 0 )
					progress = 0;
	
				if ( progress > 1 )
					progress = 1;
	
				set_ambience_blend( progress, inner_ambience, outer_ambience );
				wait( 0.05 );
			}


		// when you leave the trigger set it to whichever point it was closest too
		// or to the inner_ambience( usually "exterior" ) if self.targetname == "ambient_exit"

		if ( progress > cap )
			progress = 1;
		else
			progress = 0;

		set_ambience_blend( progress, inner_ambience, outer_ambience );
		}
		else
		{
			//do nothing
		}
	}
}

get_progress( start, end, dist, org )
{
	normal = vectorNormalize( end - start );
	vec = org - start;
	progress = vectorDot( vec, normal );
	progress = progress / dist;
	return progress;
}

ambient_end_trigger_think( start, end, dist, inner_ambience, outer_ambience )
{
	self endon( "death" );
	for ( ;; )
	{
		self waittill( "trigger", other );
		assertEx( isplayer( other ), "Non - player entity touched an ambient trigger." );
		ambient_trigger_sets_ambience_levels( start, end, dist, inner_ambience, outer_ambience );
	}
}

ambient_trigger_sets_ambience_levels( start, end, dist, inner_ambience, outer_ambience )
{
	level notify( "trigger_ambience_touched" );
	level endon( "trigger_ambience_touched" );

	for ( ;; )
	{
		progress = get_progress( start, end, dist, level._player.origin );

		if ( progress < 0 )
		{
			progress = 0;

			set_ambience_single( inner_ambience );
			break;
		}

		if ( progress >= 1 )
		{
			set_ambience_single( outer_ambience );
			break;
		}

		set_ambience_blend( progress, inner_ambience, outer_ambience );
		wait( 0.05 );
	}
}

play_ambience( ambience )
{
	if ( !isdefined( level._ambient_track ) )
		return;
	if ( !isDefined( level._ambient_track[ ambience /*+ level.ambient_modifier[ "rain" ]*/ ] ) )
		return;
		
	if ( !isdefined( level._ambience_timescale ) )
		level._ambience_timescale = 2;
		
	ambientPlay( level._ambient_track[ ambience /*+ level.ambient_modifier[ "rain" ]*/ ], 1, level._ambience_timescale );
	/#
	set_hud_track( "ambient", ambience );
	#/
}

set_ambience_blend( progress, inner_ambience, outer_ambience )
{
	current_ambient_event = outer_ambience;
	if ( progress < 0.5 )
	{
		current_ambient_event = inner_ambience;
	}

	old_ambient = level._ambient;
	level._ambient = current_ambient_event;

	modified_ambient = current_ambient_event;
	if ( level._ambient == "exterior" )
		modified_ambient += level._ambient_modifier[ "exterior" ];
	if ( level._ambient == "interior" )
		modified_ambient += level._ambient_modifier[ "interior" ];

	play_ambience( modified_ambient );
	
	if ( !isdefined( old_ambient ) || old_ambient != current_ambient_event )
	{
		if ( isdefined( level._ambientEventEnt[ modified_ambient ] ) )
		{
			thread start_ambient_event( modified_ambient );
		}
		else
		{
//			level notify( "new_ambient_event_track" );
//			clear_hud( "event_system" );
		}
		
//		thread ambientReverb( modified_ambient );
	}
	
//	thread ambientEventStart( ambient + level.ambient_modifier[ "rain" ] );

	/*
	if ( isdefined( level.ambient ) && current_ambient_event != level.ambient )
	{
		if ( isdefined( level.ambient_track[ current_ambient_event ] ) )
		{
			activateAmbient( current_ambient_event );
			level.ambient = current_ambient_event;
		}
	}
	*/
	
	if ( level._eq_track[ level._eq_main_track ] != outer_ambience )
	{
		setup_new_eq_settings( outer_ambience, level._eq_main_track );
	}

	if ( level._eq_track[ level._eq_mix_track ] != inner_ambience )
	{
		setup_new_eq_settings( inner_ambience, level._eq_mix_track );
	}

	setup_new_volume_settings( modified_ambient );

	level._player seteqlerp( progress, level._eq_main_track );
	[[ level._global_ambience_blend_func ]]( progress, inner_ambience, outer_ambience );
	
	/#
	ambience_hud( progress );
	#/

	if ( progress == 1 || progress == 0 )
		level._nextmsg = 0;

	if ( !isdefined( level._nextmsg ) )
		level._nextmsg = 0;

	if ( gettime() < level._nextmsg )
		return;

	level._nextmsg = gettime() + 200;
}

/*
set_ambience_single( ambience )
{
	if ( isdefined( level.ambientEventEnt[ ambience ] ) )
	{
// 		thread ambientEventStart( ambience );
		thread start_ambient_event( ambience );
	}

	if ( level.eq_track[ level.eq_main_track ] != ambience )
	{
		setup_new_eq_settings( ambience, level.eq_main_track );
	}

	[[ level.global_ambience_blend_func ]]( 1, ambience, ambience );

	level.player seteqlerp( 1, level.eq_main_track );
	
	/#
	ambience_hud( 1 );
	#/
}
*/

set_ambience_single( ambience )
{
	set_ambience_blend( 0, ambience, ambience );
}

create_ambience_hud()
{
	level._amb_hud = [];
	if ( debug_hud_disabled() )
		return;
	
	x = 20;
	y = 460;
	x_offset = 22;
	x_label_offset = -70;
	color = ( 0.4, 0.9, 0.6 );
	array = [];

	hud_name = "ambient";
	array[ hud_name ] = [];

	hud = newHudElem();
	hud.x = x + x_label_offset;
	hud.y = y;
	hud settext( "Ambient track: " );
	array[ hud_name ][ "label" ] = hud;

	hud = newHudElem();
	hud.x = x;
	hud.y = y;
	array[ hud_name ][ "track" ] = hud;

	y -= 10;


	hud_name = "event_system";
	array[ hud_name ] = [];

	hud = newHudElem();
	hud.x = x + x_label_offset;
	hud.y = y;
	hud settext( "Event system: " );
	array[ hud_name ][ "label" ] = hud;

	hud = newHudElem();
	hud.x = x;
	hud.y = y;
	array[ hud_name ][ "track" ] = hud;

	y -= 10;
	

	hud_name = "eq_0";
	array[ hud_name ] = [];

	hud = newHudElem();
	hud.x = x + x_label_offset;
	hud.y = y;
	hud settext( "EQ main: " );
	array[ hud_name ][ "label" ] = hud;

	hud = newHudElem();
	hud.x = x + x_offset;
	hud.y = y;
	array[ hud_name ][ "track" ] = hud;

	hud = newHudElem();
	hud.x = x;
	hud.y = y;
	array[ hud_name ][ "fraction" ] = hud;

	y -= 10;


	hud_name = "eq_1";
	array[ hud_name ] = [];

	hud = newHudElem();
	hud.x = x + x_label_offset;
	hud.y = y;
	hud settext( "EQ mix: " );
	array[ hud_name ][ "label" ] = hud;

	hud = newHudElem();
	hud.x = x + x_offset;
	hud.y = y;
	array[ hud_name ][ "track" ] = hud;

	hud = newHudElem();
	hud.x = x;
	hud.y = y;
	array[ hud_name ][ "fraction" ] = hud;

	y -= 10;


	hud_name = "reverb";
	array[ hud_name ] = [];

	hud = newHudElem();
	hud.x = x + x_label_offset;
	hud.y = y;
	hud settext( "Reverb: " );
	array[ hud_name ][ "label" ] = hud;

	hud = newHudElem();
	hud.x = x;
	hud.y = y;
	array[ hud_name ][ "track" ] = hud;

	y -= 10;

	foreach ( index, hud_array in array )
	{
		foreach ( hud in hud_array )
		{
			hud.alignX = "left";
			hud.alignY = "bottom";
			hud.color = color;
			hud.alpha = 0;
		}
		
		array[ index ][ "track" ].enabled = false;
	}
	
	level._amb_hud = array;
}

set_hud_track( msg, track )
{
	if ( debug_hud_disabled() )
		return;
	
	if ( !isdefined( level._amb_hud[ msg ] ) )
		return;

	level._amb_hud[ msg ][ "track" ].enabled = true;
	
	foreach ( hud in level._amb_hud[ msg ] )
	{
		hud.alpha = 1;
	}

	level._amb_hud[ msg ][ "track" ] settext( track );
}

set_hud_progress( msg, frac )
{
	if ( !level._amb_hud[ msg ][ "track" ].enabled )
	{
		clear_hud( msg );
		return;
	}
	
	level._amb_hud[ msg ][ "fraction" ] settext( int( frac * 100 ) );
	foreach ( hud in level._amb_hud[ msg ] )
	{
		hud.alpha = 1;
	}
}

clear_hud( msg )
{
	/#
	if ( debug_hud_disabled() )
		return;

	level._amb_hud[ msg ][ "track" ].enabled = false;
	
	foreach ( hud in level._amb_hud[ msg ] )
	{
		hud.alpha = 0;
	}
	#/
}

ambience_hud( progress )
{
	/#
	if ( debug_hud_disabled() )
		return;
		
	if ( level._amb_hud[ "eq_0" ][ "track" ].enabled )
		set_hud_progress( "eq_0", progress );

	progress = 1 - progress;
	if ( level._amb_hud[ "eq_1" ][ "track" ].enabled )
		set_hud_progress( "eq_1", progress );
	#/
}

debug_hud_disabled()
{
	if ( getdvar( "loc_warnings", 0 ) == "1" )
		return true;
	if ( getdvarint( "debug_hud" ) == 0 )
	{
		return true;
	}
	return !isdefined( level._amb_hud );
}

set_ambience_blend_over_time( time, inner_ambience, outer_ambience )
{
	if ( time == 0 )
	{
		set_ambience_blend( 1, inner_ambience, outer_ambience );
		return;
	}

	progress = 0;
	update_freq = 0.05;
	update_amount = 1 / ( time / update_freq );

	// is progress 0 on the first iteration? it shouldn't be
	for ( ;; )
	// for ( progress = 0; progress < 1; progress += update_amount )
	{
		progress = progress + update_amount;

		if ( progress >= 1 )
		{
			set_ambience_single( outer_ambience );
			break;
		}

		set_ambience_blend( progress, inner_ambience, outer_ambience );
		wait update_freq;
	}
}

hud_hide_with_cg_draw_hud()
{
	/#
	for ( ;; )
	{
		for ( ;; )
		{
			if ( !getdvarint( "cg_draw2d", 1 ) )
				break;
			wait( 0.05 );
		}
		if ( isdefined( level._amb_hud ) )
		{
			foreach ( hud_array in level._amb_hud )
			{
				foreach ( hud in hud_array )
				{
					hud.alpha = 0;
				}
			}
		}
			
		for ( ;; )
		{
			if ( getdvarint( "cg_draw2d", 1 ) )
				break;
			wait( 0.05 );
		}

		if ( isdefined( level._amb_hud ) )
		{
			foreach ( index, hud_array in level._amb_hud )
			{
				if ( level._amb_hud[ index ][ "track" ].enabled )
				{
					foreach ( hud in hud_array )
					{
						hud.alpha = 1;
					}
				}
			}
		}
	}
	#/
}

/*
=============
///ScriptDocBegin
"Name: play_linear_sfx( <array> , <soundalias> )"
"Summary: Plays a given sound alias on a point within an array of points, imitating a linear emitter."
"Module: Ambient"
"MandatoryArg: <array>: the array of points amongst which the sound will move"
"MandatoryArg: <soundalias>: the sound alias to play"
"Example: play_linear_sfx( my_river_array, "river_sfx_1" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
play_linear_sfx( array, soundalias )
{
	soundorg = Spawn( "sound_emitter", ( 0,0,0 ) );
	line_ent1 = undefined;
	line_ent2 = undefined;
	soundplaying = 0;
	while(1)
	{
	line_ents = 0;
	closest_ents = get_array_of_closest( level._player.origin, array, undefined, 2 );
	foreach ( line_ent in closest_ents )
		{
		if ( line_ents == 0 )
			{
			line_ents = 1;
			line_ent1 = line_ent;
			}
		else
			{
			line_ent2 = line_ent;
			}

		}
		linepoint = PointOnSegmentNearestToPoint( line_ent1.origin, line_ent2.origin, level._player.origin );
		soundorg MoveTo( linepoint, 0.01 );
		if ( soundplaying == 0 )
		{
			soundorg PlayLoopSound( soundalias );
			soundplaying = 1;
		}
		wait 0.1;
	}
}

/*
=============
///ScriptDocBegin
"Name: playsound_ent( soundalias )"
"Summary: Plays a sound on an entity and then deletes the entity"
"Module: Ambient"
"MandatoryArg: <soundalias>: the sound alias to play"
"Example: playsound_ent( "river_sfx" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
playsound_ent( soundalias )
{
	self playsound( soundalias, soundalias, true );
	self waittill( soundalias );
	self delete();
}