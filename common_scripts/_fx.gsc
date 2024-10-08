#include common_scripts\utility;
#include common_scripts\_createfx;

initFX()
{
	if ( !isdefined( level._func ) )
	{
		// this array will be filled with code commands that SP or MP may use but doesn't exist in the other.
		level._func = [];
	}
	if( !isdefined( level._func[ "create_triggerfx" ] ) )
		 level._func[ "create_triggerfx" ] = ::create_triggerfx;
		 
	// wrapper for the exploder function so we dont have to use flags and do ifs/waittills on every exploder call
	level._exploderFunction = ::exploder_before_load;
	waittillframeend;// Wait one frame so the effects get setup by the maps fx thread
	waittillframeend;// Wait another frame so effects can be loaded based on start functions. Without this FX are initialiazed before they are defined by start functions.
	level._exploderFunction = ::exploder_after_load;
	
	/# setDevDvarIfUninitialized( "scr_map_exploder_dump", 0 ); #/

	for ( i = 0; i < level._createFXent.size; i++ )
	{
		ent = level._createFXent[ i ];
		ent set_forward_and_up_vectors();

		if ( ent.v[ "type" ] == "loopfx" )
			ent thread loopfxthread();
		if ( ent.v[ "type" ] == "oneshotfx" )
			ent thread oneshotfxthread();
		if ( ent.v[ "type" ] == "soundfx" )
			ent thread create_loopsound();
	}
}

print_org( fxcommand, fxId, fxPos, waittime )
{
	if ( GetDvar( "debug" ) == "1" )
	{
		println( "{" );
		println( "\"origin\" \"" + fxPos[ 0 ] + " " + fxPos[ 1 ] + " " + fxPos[ 2 ] + "\"" );
		println( "\"classname\" \"script_model\"" );
		println( "\"model\" \"fx\"" );
		println( "\"script_fxcommand\" \"" + fxcommand + "\"" );
		println( "\"script_fxid\" \"" + fxId + "\"" );
		println( "\"script_delay\" \"" + waittime + "\"" );
		println( "}" );
	}
}

OneShotfx( fxId, fxPos, waittime, fxPos2 )
{
//	level thread print_org ("OneShotfx", fxId, fxPos, waittime);
//    level thread OneShotfxthread (fxId, fxPos, waittime, fxPos2);
}

exploderfx( num, fxId, fxPos, waittime, fxPos2, fireFx, fireFxDelay, fireFxSound, fxSound, fxQuake, fxDamage, soundalias, repeat, delay_min, delay_max, damage_radius, fireFxTimeout, exploder_group )
{
	if ( 1 )
	{
		ent = createExploder( fxId );
		ent.v[ "origin" ] = fxPos;
		ent.v[ "angles" ] = ( 0, 0, 0 );
		if ( isdefined( fxPos2 ) )
			ent.v[ "angles" ] = vectortoangles( fxPos2 - fxPos );
		ent.v[ "delay" ] = waittime;
		ent.v[ "exploder" ] = num;
		// deprecated
		return;
	}
	fx = spawn( "script_origin", ( 0, 0, 0 ) );
//	println ("total ", getentarray ("script_origin","classname").size);
	fx.origin = fxPos;
	fx.angles = vectortoangles( fxPos2 - fxPos );
//	fx.targetname = "exploder";
	fx.script_exploder = num;
	fx.script_fxid = fxId;
	fx.script_delay = waittime;

	fx.script_firefx = fireFx;
	fx.script_firefxdelay = ( fireFxDelay );// for awhile the script exported strings for this value so we cast it to float
	fx.script_firefxsound = fireFxSound;

	fx.script_sound = fxSound;
	fx.script_earthquake = fxQuake;
	fx.script_damage = ( fxDamage );
	fx.script_radius = ( damage_radius );
	fx.script_soundalias = soundalias;
	fx.script_firefxtimeout = ( fireFxTimeout );
	fx.script_repeat = ( repeat );
	fx.script_delay_min = ( delay_min );
	fx.script_delay_max = ( delay_max );
	fx.script_exploder_group = exploder_group;

	forward = anglestoforward( fx.angles );
	forward = vector_multiply( forward, 150 );
	fx.targetPos = fxPos + forward;

	if ( !isdefined( level._script_exploders ) )
		level._script_exploders = [];
	level._script_exploders[ level._script_exploders.size ] = fx;

	createfx_showOrigin( fxid, fxPos, waittime, fxpos2, "exploderfx", fx, undefined, fireFx, fireFxDelay,
	fireFxSound, fxSound, fxQuake, fxDamage, soundalias, repeat, delay_min, delay_max, damage_radius, fireFxTimeout );
}


/*
loopfxRotate(fxId, fxPos, waittime, angle, fxStart, fxStop, timeout)
{
	level thread print_org ("loopfx", fxId, fxPos, waittime);
    level thread loopfxthread (fxId, fxPos, waittime, fxPos2, fxStart, fxStop, timeout);
}
*/


loopfx( fxId, fxPos, waittime, fxPos2, fxStart, fxStop, timeout )
{
	println( "Loopfx is deprecated!" );
	ent = createLoopEffect( fxId );
	ent.v[ "origin" ] = fxPos;
	ent.v[ "angles" ] = ( 0, 0, 0 );
	if ( isdefined( fxPos2 ) )
		ent.v[ "angles" ] = vectortoangles( fxPos2 - fxPos );
	ent.v[ "delay" ] = waittime;
}

/*
loopfx(fxId, fxPos, waittime, fxPos2, fxStart, fxStop, timeout)
{
	level thread print_org ("loopfx", fxId, fxPos, waittime);
    level thread loopfxthread (fxId, fxPos, waittime, fxPos2, fxStart, fxStop, timeout);
}
*/

create_looper()
{
	//assert (isdefined(self.looper));
	self.looper = playLoopedFx( level._effect[ self.v[ "fxid" ] ], self.v[ "delay" ], self.v[ "origin" ], 0, self.v[ "forward" ], self.v[ "up" ] );
	create_loopsound();
}

create_loopsound()
{
	self notify( "stop_loop" );
	if ( isdefined( self.v[ "soundalias" ] ) && ( self.v[ "soundalias" ] != "nil" ) )
	{
		// tagTP<INFO> - The createfx scripts don't appear to set the "stoppable" flag correctly after a node
		// tagTP<INFO> -  is created, so when the entity was moved, there would be a leftover entity that continued
		// tagTP<INFO> -  to play a copy of the looping sound.  So, if createfx is enabled, allow it to be stopped.
		if (( isdefined( self.v[ "stoppable" ] ) && self.v[ "stoppable" ] ) || level._createFX_enabled )
		{
			if ( isdefined( self.looper ) )
				self.looper thread loop_fx_sound( self.v[ "soundalias" ], self.v[ "origin" ], "death" );
			else
				thread loop_fx_sound( self.v[ "soundalias" ], self.v[ "origin" ], "stop_loop" );
		}
		else
		{
			if ( isdefined( self.looper ) )
				self.looper thread loop_fx_sound( self.v[ "soundalias" ], self.v[ "origin" ] );
			else
				thread loop_fx_sound( self.v[ "soundalias" ], self.v[ "origin" ] );
		}
	}
}

loopfxthread()
{
	waitframe();
//	println ( "fx testing running Id: ", fxId );
//    if ((isdefined (level.scr_sound)) && (isdefined (level.scr_sound[fxId])))
//	   loopSound(level.scr_sound[fxId], fxPos);

	if ( isdefined( self.fxStart ) )
		level waittill( "start fx" + self.fxStart );

	while ( 1 )
	{
		/*
		if (isdefined (ent.org2))
		{
			fxAngle = vectorNormalize (ent.org2 - ent.org);
			looper = playLoopedFx( level._effect[fxId], ent.delay, ent.org, 0, fxAngle );
		}
		else
			looper = playLoopedFx( level._effect[fxId], ent.delay, ent.org, 0 );
		*/
		create_looper();

		if ( isdefined( self.timeout ) )
			thread loopfxStop( self.timeout );

		if ( isdefined( self.fxStop ) )
			level waittill( "stop fx" + self.fxStop );
		else
			return;

		if ( isdefined( self.looper ) )
			self.looper delete();

		if ( isdefined( self.fxStart ) )
			level waittill( "start fx" + self.fxStart );
		else
			return;
	}
}

loopfxChangeID( ent )
{
	self endon( "death" );
	ent waittill( "effect id changed", change );
}

loopfxChangeOrg( ent )
{
	self endon( "death" );
	for ( ;; )
	{
		ent waittill( "effect org changed", change );
		self.origin = change;
	}
}

loopfxChangeDelay( ent )
{
	self endon( "death" );
	ent waittill( "effect delay changed", change );
}

loopfxDeletion( ent )
{
	self endon( "death" );
	ent waittill( "effect deleted" );
	self delete();
}

loopfxStop( timeout )
{
	self endon( "death" );
	wait( timeout );
	self.looper delete();
}

loopSound( sound, Pos, waittime )
{
//	level thread print_org ("loopSound", sound, Pos, waittime);
	level thread loopSoundthread( sound, Pos, waittime );
}

loopSoundthread( sound, pos, waittime )
{
	org = spawn( "sound_emitter", ( pos ) );

	org.origin = pos;
//	println ("hello1 ", org.origin, sound);
	org playLoopSound( sound );
}

gunfireloopfx( fxId, fxPos, shotsMin, shotsMax, shotdelayMin, shotdelayMax, betweenSetsMin, betweenSetsMax )
{
    thread gunfireloopfxthread( fxId, fxPos, shotsMin, shotsMax, shotdelayMin, shotdelayMax, betweenSetsMin, betweenSetsMax );
}

gunfireloopfxthread( fxId, fxPos, shotsMin, shotsMax, shotdelayMin, shotdelayMax, betweenSetsMin, betweenSetsMax )
{
	level endon( "stop all gunfireloopfx" );
	waitframe();

	if ( betweenSetsMax < betweenSetsMin )
	{
		temp = betweenSetsMax;
		betweenSetsMax = betweenSetsMin;
		betweenSetsMin = temp;
	}

	betweenSetsBase = betweenSetsMin;
	betweenSetsRange = betweenSetsMax - betweenSetsMin;

	if ( shotdelayMax < shotdelayMin )
	{
		temp = shotdelayMax;
		shotdelayMax = shotdelayMin;
		shotdelayMin = temp;
	}

	shotdelayBase = shotdelayMin;
	shotdelayRange = shotdelayMax - shotdelayMin;

	if ( shotsMax < shotsMin )
	{
		temp = shotsMax;
		shotsMax = shotsMin;
		shotsMin = temp;
	}

	shotsBase = shotsMin;
	shotsRange = shotsMax - shotsMin;

	fxEnt = spawnFx( level._effect[ fxId ], fxPos );
	
	if ( !level._createFX_enabled )
		fxEnt willNeverChange();
		
    for ( ;; )
    {
		shotnum = shotsBase + randomint( shotsRange );
		for ( i = 0;i < shotnum;i++ )
		{
			triggerFx( fxEnt );

			wait( shotdelayBase + randomfloat( shotdelayRange ) );
		}
        wait( betweenSetsBase + randomfloat( betweenSetsRange ) );
    }
}

gunfireloopfxVec( fxId, fxPos, fxPos2, shotsMin, shotsMax, shotdelayMin, shotdelayMax, betweenSetsMin, betweenSetsMax )
{
    thread gunfireloopfxVecthread( fxId, fxPos, fxPos2, shotsMin, shotsMax, shotdelayMin, shotdelayMax, betweenSetsMin, betweenSetsMax );
}

gunfireloopfxVecthread( fxId, fxPos, fxPos2, shotsMin, shotsMax, shotdelayMin, shotdelayMax, betweenSetsMin, betweenSetsMax )
{
	level endon( "stop all gunfireloopfx" );
	waitframe();

	if ( betweenSetsMax < betweenSetsMin )
	{
		temp = betweenSetsMax;
		betweenSetsMax = betweenSetsMin;
		betweenSetsMin = temp;
	}

	betweenSetsBase = betweenSetsMin;
	betweenSetsRange = betweenSetsMax - betweenSetsMin;

	if ( shotdelayMax < shotdelayMin )
	{
		temp = shotdelayMax;
		shotdelayMax = shotdelayMin;
		shotdelayMin = temp;
	}

	shotdelayBase = shotdelayMin;
	shotdelayRange = shotdelayMax - shotdelayMin;

	if ( shotsMax < shotsMin )
	{
		temp = shotsMax;
		shotsMax = shotsMin;
		shotsMin = temp;
	}

	shotsBase = shotsMin;
	shotsRange = shotsMax - shotsMin;

	fxPos2 = vectornormalize( fxPos2 - fxPos );

	fxEnt = spawnFx( level._effect[ fxId ], fxPos, fxPos2 );

	if ( !level._createFX_enabled )
		fxEnt willNeverChange();

	for ( ;; )
	{
		shotnum = shotsBase + randomint( shotsRange );
		for ( i = 0;i < int( shotnum / level._fxfireloopmod );i++ )
		{
			triggerFx( fxEnt );
			delay = ( ( shotdelayBase + randomfloat( shotdelayRange ) ) * level._fxfireloopmod );
			if ( delay < .05 )
				delay = .05;
			wait delay;
		}
		wait( shotdelayBase + randomfloat( shotdelayRange ) );
		wait( betweenSetsBase + randomfloat( betweenSetsRange ) );
	}
}

setfireloopmod( value )
{
	level._fxfireloopmod = 1 / value;
}

setup_fx()
{
	if ( ( !isdefined( self.script_fxid ) ) || ( !isdefined( self.script_fxcommand ) ) || ( !isdefined( self.script_delay ) ) )
	{
//		println (self.script_fxid);
//		println (self.script_fxcommand);
//		println (self.script_delay);
//		println ("Effect at origin ", self.origin," doesn't have script_fxid/script_fxcommand/script_delay");
//		self delete();
		return;
	}

//	println ("^a Command:", self.script_fxcommand, " Effect:", self.script_fxID, " Delay:", self.script_delay, " ", self.origin);
	if ( isdefined( self.model ) )
		if ( self.model == "toilet" )
		{
			self thread burnville_paratrooper_hack();
			return;
		}

	org = undefined;
	if ( isdefined( self.target ) )
	{
		ent = getent( self.target, "targetname" );
		if ( isdefined( ent ) )
			org = ent.origin;
	}

	fxStart = undefined;
	if ( isdefined( self.script_fxstart ) )
		fxStart = self.script_fxstart;

	fxStop = undefined;
	if ( isdefined( self.script_fxstop ) )
		fxStop = self.script_fxstop;

	if ( self.script_fxcommand == "OneShotfx" )
		OneShotfx( self.script_fxId, self.origin, self.script_delay, org );
	if ( self.script_fxcommand == "loopfx" )
		loopfx( self.script_fxId, self.origin, self.script_delay, org, fxStart, fxStop );
	if ( self.script_fxcommand == "loopsound" )
		loopsound( self.script_fxId, self.origin, self.script_delay );

	self delete();
}

burnville_paratrooper_hack()
{
	normal = ( 0, 0, self.angles[ 1 ] );
//	println ("z:       paratrooper fx hack: ", normal);
	id = level._effect[ self.script_fxId ];
	origin = self.origin;

//	if (isdefined (self.script_delay))
//		wait (self.script_delay);

	wait 1;
	level thread burnville_paratrooper_hack_loop( normal, origin, id );
	self delete();
}

burnville_paratrooper_hack_loop( normal, origin, id )
{
	while ( 1 )
	{
	//	iprintln ("z:        playing paratrooper fx", origin);

		playfx( id, origin );
		wait( 30 + randomfloat( 40 ) );
	}
}

create_triggerfx()
{
	//assert (isdefined(self.looper));
	if( ! verify_effects_assignment( self.v[ "fxid" ] ) )
		return;
		
	self.looper = spawnFx( level._effect[ self.v[ "fxid" ] ], self.v[ "origin" ], self.v[ "forward" ], self.v[ "up" ] );
	triggerFx( self.looper, self.v[ "delay" ] );

	if ( !level._createFX_enabled )
		self.looper willNeverChange();

	create_loopsound();
}

verify_effects_assignment( effectID )
{
	if( isdefined ( level._effect[ effectID ] ) )
		return true;
	if( ! isdefined( level._missing_FX ) )
		level._missing_FX = [];
	level._missing_FX[ self.v[ "fxid" ] ] = effectID;
	verify_effects_assignment_print( effectID );
	return false;
}

verify_effects_assignment_print( effectID )
{
	
	level notify ( "verify_effects_assignment_print" );
	level endon ( "verify_effects_assignment_print" );
	wait .05; //allow errors on the same frame to que up before printing
	
	println("Error:");
	println("Error:**********MISSING EFFECTS IDS**********");
	keys = getarraykeys( level._missing_FX );
	foreach( key in keys )
	{
		println( "Error: Missing Effects ID assignment for: "+ key  );
	}
	println("Error:");
	
	assertmsg( "Missing Effects ID assignments ( see console )" );
}

OneShotfxthread()
{
	waitframe();

	if ( self.v[ "delay" ] > 0 )
	    wait self.v[ "delay" ];

	/*  
	if ( isdefined( self.v[ "fire_range" ] ) )
	{
		thread fire_radius( self.v[ "origin" ], self.v[ "fire_range" ] );
	}
	*/

	[[ level._func[ "create_triggerfx" ] ]]();
}>