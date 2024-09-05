#include maps\_utility;
#include common_scripts\utility;
/#
mainDebug()
{
	level._animsound_hudlimit = 14;
	thread lastSightPosWatch();

	if ( level._script != "background" )
		thread camera();

	if ( GetDebugDvar( "debug_corner" ) == "" )
		SetDvar( "debug_corner", "off" );
	else
	if ( GetDebugDvar( "debug_corner" ) == "on" )
		debug_corner();

	if ( GetDvar( "chain" ) == "1" )
		thread debugchains();

	thread debugDvars();
	PreCacheShader( "white" );
	thread debugColorFriendlies();

	thread watchMinimap();

	if ( GetDvar( "level_transition_test" ) != "off" )
		thread complete_me();

	if ( GetDvar( "level_completeall" ) != "off" )
		maps\_endmission::force_all_complete();

	if ( GetDvar( "level_clear_all" ) != "off" )
		maps\_endmission::clearall();

//	thread playerNode();
//	thread colordebug();
//	thread debuggoalpos();
}
#/



debugchains()
{
	nodes = GetAllNodes();
	fnodenum = 0;

	fnodes = [];
	for ( i = 0; i < nodes.size; i++ )
	{
		if ( ( !( nodes[ i ].spawnflags & 2 ) ) &&
		(
		( ( IsDefined( nodes[ i ].target ) ) && ( ( GetNodeArray( nodes[ i ].target, "targetname" ) ).size > 0 ) ) ||
		( ( IsDefined( nodes[ i ].targetname ) ) && ( ( GetNodeArray( nodes[ i ].targetname, "target" ) ).size > 0 ) )
		 )
		 )
		{
			fnodes[ fnodenum ] = nodes[ i ];
			fnodenum++;
		}
	}

	count = 0;

	while ( 1 )
	{
		if ( GetDvar( "chain" ) == "1" )
		{
			for ( i = 0; i < fnodes.size; i++ )
			{
				if ( Distance( level._player GetOrigin(), fnodes[ i ].origin ) < 1500 )
				{
					Print3d( fnodes[ i ].origin, "yo", ( 0.2, 0.8, 0.5 ), 0.45 );
					/*
					count++;
					if( count > 25 )
					{
						count = 0;
						waitframe();
					}
					*/
				}
			}

			friends = GetAIArray( "allies" );
			for ( i = 0; i < friends.size; i++ )
			{
				node = friends[ i ] animscripts\utility::GetClaimedNode();
				if ( IsDefined( node ) )
					Line( friends[ i ].origin + ( 0, 0, 35 ), node.origin, ( 0.2, 0.5, 0.8 ), 0.5 );
			}

		}
		waitframe();
	}
}

debug_enemyPos( num )
{
	ai = GetAIArray();

	for ( i = 0; i < ai.size; i++ )
	{
		if ( ai[ i ] GetEntityNumber() != num )
			continue;

		ai[ i ] thread debug_enemyPosProc();
		break;
	}
}

debug_stopEnemyPos( num )
{
	ai = GetAIArray();

	for ( i = 0; i < ai.size; i++ )
	{
		if ( ai[ i ] GetEntityNumber() != num )
			continue;

		ai[ i ] notify( "stop_drawing_enemy_pos" );
		break;
	}
}

debug_enemyPosProc()
{
	self endon( "death" );
	self endon( "stop_drawing_enemy_pos" );
	for ( ;; )
	{
		wait( 0.05 );

		if ( IsAlive( self.enemy ) )
			Line( self.origin + ( 0, 0, 70 ), self.enemy.origin + ( 0, 0, 70 ), ( 0.8, 0.2, 0.0 ), 0.5 );

		if ( !self animscripts\utility::hasEnemySightPos() )
			continue;

		pos = animscripts\utility::getEnemySightPos();
		Line( self.origin + ( 0, 0, 70 ), pos, ( 0.9, 0.5, 0.3 ), 0.5 );
	}
}

debug_enemyPosReplay()
{
	ai = GetAIArray();
	guy = undefined;

	for ( i = 0; i < ai.size; i++ )
	{
//		if( ai[ i ] GetEntityNumber() != num )
//			continue;

		guy = ai[ i ];
		if ( !isalive( guy ) )
			continue;


		if ( IsDefined( guy.lastEnemySightPos ) )
			Line( guy.origin + ( 0, 0, 65 ), guy.lastEnemySightPos, ( 1, 0, 1 ), 0.5 );

		if ( IsDefined( guy.goodShootPos ) )
		{
			if ( guy IsBadGuy() )
				color = ( 1, 0, 0 );
			else
				color = ( 0, 0, 1 );

//			nodeOffset = guy GetEye();
			nodeOffset = guy.origin + ( 0, 0, 54 );
			if ( IsDefined( guy.node ) )
			{
				if ( guy.node.type == "Cover Left" )
				{
					cornerNode = true;
					nodeOffset = AnglesToRight( guy.node.angles );
					nodeOffset = vector_multiply( nodeOffset, -32 );
					nodeOffset = ( nodeOffset[ 0 ], nodeOffset[ 1 ], 64 );
					nodeOffset = guy.node.origin + nodeOffset;
				}
				else
				if ( guy.node.type == "Cover Right" )
				{
					cornerNode = true;
					nodeOffset = AnglesToRight( guy.node.angles );
					nodeOffset = vector_multiply( nodeOffset, 32 );
					nodeOffset = ( nodeOffset[ 0 ], nodeOffset[ 1 ], 64 );
					nodeOffset = guy.node.origin + nodeOffset;
				}
			}
			draw_arrow( nodeOffset, guy.goodShootPos, color );
		}
//		break;	
	}
	if ( 1 ) return;

	if ( !isalive( guy ) )
		return;

	if ( IsAlive( guy.enemy ) )
		Line( guy.origin + ( 0, 0, 70 ), guy.enemy.origin + ( 0, 0, 70 ), ( 0.6, 0.2, 0.2 ), 0.5 );

	if ( IsDefined( guy.lastEnemySightPos ) )
		Line( guy.origin + ( 0, 0, 65 ), guy.lastEnemySightPos, ( 0, 0, 1 ), 0.5 );

	if ( IsAlive( guy.goodEnemy ) )
		Line( guy.origin + ( 0, 0, 50 ), guy.goodEnemy.origin, ( 1, 0, 0 ), 0.5 );


	if ( !guy animscripts\utility::hasEnemySightPos() )
		return;

	pos = guy animscripts\utility::getEnemySightPos();
	Line( guy.origin + ( 0, 0, 55 ), pos, ( 0.2, 0.2, 0.6 ), 0.5 );

	if ( IsDefined( guy.goodShootPos ) )
		Line( guy.origin + ( 0, 0, 45 ), guy.goodShootPos, ( 0.2, 0.6, 0.2 ), 0.5 );
}

drawEntTag( num )
{
	/#
	ai = GetAIArray();
	for ( i = 0; i < ai.size; i++ )
	{
		if ( ai[ i ] GetEntNum() != num )
			continue;
		ai[ i ] thread dragTagUntilDeath( GetDebugDvar( "debug_tag" ) );
	}
	SetDvar( "debug_enttag", "" );
	#/
}

drawTag( tag, opcolor, drawtime )
{
	org = self GetTagOrigin( tag );
	ang = self GetTagAngles( tag );
	drawArrow( org, ang, opcolor, drawtime );
}

drawOrgForever( opcolor )
{
	org = undefined;
	ang = undefined;
	for ( ;; )
	{
		if ( IsDefined( self ) )
		{
			org = self.origin;
			ang = self.angles;
		}
		drawArrow( org, ang, opcolor );
		wait( 0.05 );
	}
}


/*
=============
///ScriptDocBegin
"Name: drawArrowForever( <org> , <ang> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
drawArrowForever( org, ang )
{
	for ( ;; )
	{
		drawArrow( org, ang );
		wait( 0.05 );
	}
}

drawOriginForever()
{
	while ( IsDefined( self ) )
	{
		drawArrow( self.origin, self.angles );
		wait( 0.05 );
	}
}

/*
=============
///ScriptDocBegin
"Name: drawArrow( <org> , <ang> , <opcolor> , <drawtime> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
drawArrow( org, ang, opcolor, drawtime )
{
	scale = 10;
	forward = AnglesToForward( ang );
	forwardFar = vector_multiply( forward, scale );
	forwardClose = vector_multiply( forward, ( scale * 0.8 ) );
	right = AnglesToRight( ang );
	leftdraw = vector_multiply( right, ( scale * -0.2 ) );
	rightdraw = vector_multiply( right, ( scale * 0.2 ) );

	up = AnglesToUp( ang );
	right = vector_multiply( right, scale );
	up = vector_multiply( up, scale );

	red = ( 0.9, 0.2, 0.2 );
	green = ( 0.2, 0.9, 0.2 );
	blue = ( 0.2, 0.2, 0.9 );
	if ( IsDefined( opcolor ) )
	{
		red = opcolor;
		green = opcolor;
		blue = opcolor;
	}

	if ( !isdefined( drawtime ) )
		drawtime = 1;

	Line( org, org + forwardFar, red, 0.9, 0, drawtime );
	Line( org + forwardFar, org + forwardClose + rightdraw, red, 0.9, 0, drawtime );
	Line( org + forwardFar, org + forwardClose + leftdraw, red, 0.9, 0, drawtime );

	Line( org, org + right, blue, 0.9, 0, drawtime );
	Line( org, org + up, green, 0.9, 0, drawtime );
}

/*
=============
///ScriptDocBegin
"Name: drawForwardForever( <scale> , <color> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
drawForwardForever( scale, color )
{
	if ( !isdefined( scale ) )
		scale = 100;
	if ( !isdefined( color ) )
		color = ( 0, 1, 0 );
	for ( ;; )
	{
		if ( !isdefined( self ) )
			return;
		forward = AnglesToForward( self.angles );
		Line( self.origin, self.origin + forward * scale, color );
		wait( 0.05 );
	}
}

drawPlayerViewForever()
{
	for ( ;; )
	{
		drawArrow( level._player.origin, level._player GetPlayerAngles(), ( 1, 1, 1 ) );
		wait( 0.05 );
	}
}



/*
=============
///ScriptDocBegin
"Name: drawTagForever( <tag> , <opcolor> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
drawTagForever( tag, opcolor )
{
	for ( ;; )
	{
		if ( !isdefined( self ) )
			return;
		drawTag( tag, opcolor );
		wait( 0.05 );
	}
}

drawTagTrails( tag, opcolor )
{
	for ( ;; )
	{
		if ( !isdefined( self.origin ) )
			break;
		drawTag( tag, opcolor, 1000 );
		wait( 0.05 );
	}
}

dragTagUntilDeath( tag, opcolor )
{
	self endon( "death" );
	for ( ;; )
	{
		if ( !isdefined( self ) )
			break;
		if ( !isdefined( self.origin ) )
			break;
		drawTag( tag, opcolor );
		wait( 0.05 );
	}
}

viewTag( type, tag )
{
	if ( type == "ai" )
	{
		ai = GetAIArray();
		for ( i = 0; i < ai.size; i++ )
			ai[ i ] drawTag( tag );
	}
}


debug_corner()
{
	level._player.ignoreme = true;
	nodes = GetAllNodes();
	corners = [];
	for ( i = 0; i < nodes.size; i++ )
	{
		if ( nodes[ i ].type == "Cover Left" )
			corners[ corners.size ] = nodes[ i ];
		if ( nodes[ i ].type == "Cover Right" )
			corners[ corners.size ] = nodes[ i ];
	}

	ai = GetAIArray();
	for ( i = 0; i < ai.size; i++ )
		ai[ i ] Delete();

	level._debugspawners = GetSpawnerArray();
	level._activeNodes = [];
	level._completedNodes = [];
	for ( i = 0; i < level._debugspawners.size; i++ )
		level._debugspawners[ i ].targetname = "blah";

	covered = 0;
	for ( i = 0; i < 30; i++ )
	{
		if ( i >= corners.size )
			break;

		corners[ i ] thread coverTest();
		covered++;
	}

	if ( corners.size <= 30 )
		return;

	for ( ;; )
	{
		level waittill( "debug_next_corner" );
		if ( covered >= corners.size )
			covered = 0;
		corners[ covered ] thread coverTest();
		covered++;
	}
}

coverTest()
{
	coverSetupAnim();
}

#using_animtree( "generic_human" );
coverSetupAnim()
{
	spawn = undefined;
	spawner = undefined;
	for ( ;; )
	{
		for ( i = 0; i < level._debugspawners.size; i++ )
		{
			wait( 0.05 );
			spawner = level._debugspawners[ i ];
			nearActive = false;
			for ( p = 0; p < level._activeNodes.size; p++ )
			{
				if ( Distance( level._activeNodes[ p ].origin, self.origin ) > 250 )
					continue;
				nearActive = true;
				break;
			}
			if ( nearActive )
				continue;

			completed = false;
			for ( p = 0; p < level._completedNodes.size; p++ )
			{
				if ( level._completedNodes[ p ] != self )
					continue;
				completed = true;
				break;
			}
			if ( completed )
				continue;

			level._activeNodes[ level._activeNodes.size ] = self;
			spawner.origin = self.origin;
			spawner.angles = self.angles;
			spawner.count = 1;
			spawn = spawner StalingradSpawn();
			if ( spawn_failed( spawn ) )
			{
				removeActiveSpawner( self );
				continue;
			}

			break;
		}
		if ( IsAlive( spawn ) )
			break;
	}

	wait( 1 );
	if ( IsAlive( spawn ) )
	{
		spawn.ignoreme = true;
		spawn.team = "neutral";
		spawn SetGoalPos( spawn.origin );
		thread createLine( self.origin );
		spawn thread debugorigin();
		thread createLineConstantly( spawn );
		spawn waittill( "death" );
	}
	removeActiveSpawner( self );
	level._completedNodes[ level._completedNodes.size ] = self;
}

removeActiveSpawner( spawner )
{
	newSpawners = [];
	for ( p = 0; p < level._activeNodes.size; p++ )
	{
		if ( level._activeNodes[ p ] == spawner )
			continue;
		newSpawners[ newSpawners.size ] = level._activeNodes[ p ];
	}
	level._activeNodes = newSpawners;
}


createLine( org )
{
	for ( ;; )
	{
		Line( org + ( 0, 0, 35 ), org, ( 0.2, 0.5, 0.8 ), 0.5 );
		wait( 0.05 );
	}
}

createLineConstantly( ent )
{
	org = undefined;
	while ( IsAlive( ent ) )
	{
		org = ent.origin;
		wait( 0.05 );
	}

	for ( ;; )
	{
		Line( org + ( 0, 0, 35 ), org, ( 1.0, 0.2, 0.1 ), 0.5 );
		wait( 0.05 );
	}
}

debugMisstime()
{
	self notify( "stopdebugmisstime" );
	self endon( "stopdebugmisstime" );
	self endon( "death" );
	for ( ;; )
	{
		if ( self.a.misstime <= 0 )
			Print3d( self GetTagOrigin( "TAG_EYE" ) + ( 0, 0, 15 ), "hit", ( 0.3, 1, 1 ), 1 );
		else
			Print3d( self GetTagOrigin( "TAG_EYE" ) + ( 0, 0, 15 ), self.a.misstime / 20, ( 0.3, 1, 1 ), 1 );
		wait( 0.05 );
	}
}

debugMisstimeOff()
{
	self notify( "stopdebugmisstime" );
}

setEmptyDvar( dvar, setting )
{
	/#
	if ( GetDebugDvar( dvar ) == "" )
		SetDvar( dvar, setting );
	#/
}

debugJump( num )
{
	/#
	ai = GetAIArray();
	for ( i = 0; i < ai.size; i++ )
	{
		if ( ai[ i ] GetEntNum() != num )
			continue;

		Line( level._player.origin, ai[ i ].origin, ( 0.2, 0.3, 1.0 ) );
		return;
	}
	#/
}

debugDvars()
{
	/#

	create_dvar( "chasecam", "0" );
	create_dvar( "viewfx", "" );
	create_dvar( "debug_badpath_time", 5000 );
	create_dvar( "debug_hud", 0 );

	create_dvar( "vehicle_info", 0 );
	create_dvar( "getdot", 0 );


	if ( GetDvar( "level_transition_test" ) == "" )
		SetDvar( "level_transition_test", "off" );

	if ( GetDvar( "level_completeall" ) == "" )
		SetDvar( "level_completeall", "off" );

	if ( GetDvar( "level_clear_all" ) == "" )
		SetDvar( "level_clear_all", "off" );

	waittillframeend;// for vars to get init'd elsewhere
	setEmptyDvar( "debug_accuracypreview", "off" );

	if ( GetDebugDvar( "debug_lookangle" ) == "" )
		SetDvar( "debug_lookangle", "off" );

	if ( GetDebugDvar( "debug_grenademiss" ) == "" )
		SetDvar( "debug_grenademiss", "off" );

	if ( GetDebugDvar( "debug_enemypos" ) == "" )
		SetDvar( "debug_enemypos", "-1" );

	if ( GetDebugDvar( "debug_dotshow" ) == "" )
		SetDvar( "debug_dotshow", "-1" );

	if ( GetDebugDvar( "debug_stopenemypos" ) == "" )
		SetDvar( "debug_stopenemypos", "-1" );

	if ( GetDebugDvar( "debug_replayenemypos" ) == "" )
		SetDvar( "debug_replayenemypos", "-1" );

	if ( GetDebugDvar( "debug_tag" ) == "" )
		SetDvar( "debug_tag", "" );

	if ( GetDebugDvar( "debug_arrivals" ) == "" )
		SetDvar( "debug_arrivals", "" );

	if ( GetDebugDvar( "debug_chatlook" ) == "" )
		SetDvar( "debug_chatlook", "" );

	if ( GetDebugDvar( "debug_vehicletag" ) == "" )
		SetDvar( "debug_vehicletag", "" );


	if ( GetDebugDvar( "debug_colorfriendlies" ) == "" )
		SetDvar( "debug_colorfriendlies", "off" );

	if ( GetDebugDvar( "debug_animreach" ) ==  "" )
		SetDvar( "debug_animreach", "off" );

	if ( GetDebugDvar( "debug_hatmodel" ) == "" )
		SetDvar( "debug_hatmodel", "on" );

	if ( GetDebugDvar( "debug_trace" ) == "" )
		SetDvar( "debug_trace", "off" );

	level._debug_badpath = false;
	if ( GetDebugDvar( "debug_badpath" ) == "" )
		SetDvar( "debug_badpath", "off" );

	if ( GetDebugDvar( "anim_lastsightpos" ) == "" )
		SetDvar( "debug_lastsightpos", "off" );

	if ( GetDebugDvar( "debug_dog_sound" ) == "" )
		SetDvar( "debug_dog_sound", "" );

	if ( GetDvar( "debug_nuke" ) == "" )
		SetDvar( "debug_nuke", "off" );

	if ( GetDebugDvar( "debug_deathents" ) == "on" )
		SetDvar( "debug_deathents", "off" );

	if ( GetDvar( "debug_jump" ) == "" )
		SetDvar( "debug_jump", "" );

	if ( GetDvar( "debug_hurt" ) == "" )
		SetDvar( "debug_hurt", "" );

	if ( GetDebugDvar( "animsound" ) == "" )
		SetDvar( "animsound", "off" );
	if ( GetDvar( "tag" ) == "" )
		SetDvar( "tag", "" );

	for ( i = 1; i <= level._animsound_hudlimit; i++ )
	{
		if ( GetDvar( "tag" + i ) == "" )
			SetDvar( "tag" + i, "" );
	}

	if ( GetDebugDvar( "animsound_save" ) == "" )
		SetDvar( "animsound_save", "" );

	if ( GetDebugDvar( "debug_depth" ) == "" )
		SetDvar( "debug_depth", "" );

	if ( GetDebugDvar( "debug_colornodes" ) == "" )
		SetDvar( "debug_colornodes", "" );

	if ( GetDebugDvar( "debug_reflection" ) == "" )
		SetDvar( "debug_reflection", "0" );

	if ( GetDebugDvar( "debug_fxlighting" ) == "" )
		SetDvar( "debug_fxlighting", "0" );


	level._last_threat_debug = -23430;
	if ( GetDebugDvar( "debug_threat" ) == "" )
		SetDvar( "debug_threat", "-1" );

	PreCacheModel( "test_sphere_silver" );

	level._effect[ "lighting_fraction" ]  = LoadFX( "test/lighting_fraction" );


	red = ( 1, 0, 0 );
	blue = ( 0, 0, 1 );
	yellow = ( 1, 1, 0 );
	cyan = ( 0, 1, 1 );
	green = ( 0, 1, 0 );
	purple = ( 1, 0, 1 );
	orange = ( 1, 0.5, 0 );

	level._color_debug[ "r" ] = red;
	level._color_debug[ "b" ] = blue;
	level._color_debug[ "y" ] = yellow;
	level._color_debug[ "c" ] = cyan;
	level._color_debug[ "g" ] = green;
	level._color_debug[ "p" ] = purple;
	level._color_debug[ "o" ] = orange;

	level._debug_reflection = 0;

	level._debug_fxlighting = 0;

	//if( GetDvar( "debug_character_count" ) == "" )
	//	SetDvar( "debug_character_count", "off" );

//	thread hatmodel();	
	//thread debug_character_count();

	noAnimscripts = GetDvar( "debug_noanimscripts" ) == "on";
	for ( ;; )
	{
		if ( GetDebugDvarInt( "getdot" ) > 0 )
		{
			draw_dot_for_ent( GetDebugDvarInt( "getdot" ) );
		}

		if ( GetDvarInt( "viewfx" ) )
		{
			viewfx();
			SetDvar( "viewfx", "" );
		}

		if ( GetDvarInt( "debug_hud" ) != 1 )
		{
			if ( IsDefined( level._amb_hud ) )
			{
				foreach ( hud_array in level._amb_hud )
				{
					foreach ( hud in hud_array )
					{
						hud Destroy();
					}
				}
				level._amb_hud = undefined;
			}

			if ( IsDefined( level._bcs_hud ) )
			{
				level._bcs_hud Destroy();
				level._bcs_hud = undefined;
			}
		}

		if ( GetDebugDvar( "debug_jump" ) != "" )
			debugJump( GetDebugDvarInt( "debug_jump" ) );

		if ( GetDvarInt( "chasecam" ) )
			chaseCam( GetDvarInt( "chasecam" ) );

		if ( GetDebugDvar( "debug_tag" ) != "" )
		{
			thread viewTag( "ai", GetDebugDvar( "debug_tag" ) );
			if ( GetDebugDvarInt( "debug_enttag" ) > 0 )
				thread drawEntTag( GetDebugDvarInt( "debug_enttag" ) );
		}

		if ( GetDebugDvar( "debug_colornodes" ) == "on" )
			thread debug_colornodes();

		if ( GetDebugDvar( "debug_replayenemypos" ) == "on" )
			thread debug_enemyPosReplay();

		thread debug_animSound();

		if ( GetDvar( "tag" ) != "" )
			thread debug_animSoundTagSelected();

		for ( i = 1; i <= level._animsound_hudlimit; i++ )
		{
			if ( GetDvar( "tag" + i ) != "" )
				thread debug_animSoundTag( i );
		}

		if ( GetDebugDvar( "animsound_save" ) != "" )
			thread debug_animSoundSave();

		if ( GetDvar( "debug_nuke" ) != "off" )
		{
			thread debug_nuke();
		}

		if ( GetDvarInt( "ai_debugCoverArrivalsTool" ) != 0 )
		{
			thread animscripts\cover_arrival::coverArrivalDebugTool();
		}

		if ( GetDebugDvar( "debug_misstime" ) == "on" )
		{
			SetDvar( "debug_misstime", "start" );
			array_thread( GetAIArray(), ::debugMisstime );
		}
		else
		if ( GetDebugDvar( "debug_misstime" ) == "off" )
		{
			SetDvar( "debug_misstime", "start" );
			array_thread( GetAIArray(), ::debugMisstimeOff );
		}

		if ( GetDebugDvar( "debug_deathents" ) == "on" )
			thread deathspawnerPreview();

		if ( GetDvar( "debug_hurt" ) == "on" )
		{
			SetDvar( "debug_hurt", "off" );
			level._player DoDamage( 50, ( 324234, 3423423, 2323 ) );
		}

		if ( GetDvar( "debug_hurt" ) == "on" )
		{
			SetDvar( "debug_hurt", "off" );
			level._player DoDamage( 50, ( 324234, 3423423, 2323 ) );
		}

		if ( GetDvar( "debug_depth" ) == "on" )
		{
			thread fogcheck();
		}

		if ( GetDebugDvarInt( "vehicle_info" ) )
		{
			random_noteworthy = RandomInt( 34234 ) + "_" + RandomInt( 23423 );
			SetDvar( "vehicle_info", 0 );
			vehicles = GetEntArray( "script_vehicle", "code_classname" );
			foreach ( vehicle in vehicles )
			{
				if ( !isdefined( vehicle ) )
					continue;
				if ( IsSpawner( vehicle ) )
					continue;

				vehicle print_vehicle_info( random_noteworthy );
			}
		}

		if ( GetDebugDvar( "debug_threat" ) != "-1" )
		{
			debugThreat();
		}

		level._debug_badpath = GetDebugDvar( "debug_badpath" ) == "on";

		if ( GetDebugDvarInt( "debug_enemypos" ) != -1 )
		{
			thread debug_enemypos( GetDebugDvarInt( "debug_enemypos" ) );
			SetDvar( "debug_enemypos", "-1" );
		}
		if ( GetDebugDvarInt( "debug_stopenemypos" ) != -1 )
		{
			thread debug_stopenemypos( GetDebugDvarInt( "debug_stopenemypos" ) );
			SetDvar( "debug_stopenemypos", "-1" );
		}

		if ( !noAnimscripts && GetDvar( "debug_noanimscripts" ) == "on" )
		{
			anim.defaultException = animscripts\init_common::infiniteLoop;
			noAnimscripts = true;
		}

		if ( noAnimscripts && GetDvar( "debug_noanimscripts" ) == "off" )
		{
			anim.defaultException = animscripts\init_common::empty;
			anim notify( "new exceptions" );
			noAnimscripts = false;
		}

		if ( GetDebugDvar( "debug_trace" ) == "on" )
		{
			if ( !isdefined( level._traceStart ) )
				thread showDebugTrace();
			level._traceStart = level._player GetEye();
			SetDvar( "debug_trace", "off" );
		}


		// logic to turn on or off our dynamic spawner. 
		if( ( GetDvar( "g_debugDynamicSpawnAI" ) == "1" ) && ( !isdefined( level.spawn_anywhere_active ) || level.spawn_anywhere_active == false ) )
		{
			level.spawn_anywhere_active = true;
			thread dynamic_ai_spawner();
		}
		else if( ( GetDvar( "g_debugDynamicSpawnAI" ) == "0" ) && isdefined( level.spawn_anywhere_active ) && level.spawn_anywhere_active == true )
		{
			level.spawn_anywhere_active = false;
			level notify( "kill dynamic spawning" );
		}


		debug_reflection();

		debug_fxlighting();

		wait( 0.05 );
	}
	#/
}

remove_reflection_objects()
{
/#
	if ( ( level._debug_reflection == 2 || level._debug_reflection == 3 ) && IsDefined( level._debug_reflection_objects ) )
	{
		for ( i = 0; i < level._debug_reflection_objects.size; i++ )
		{
			level._debug_reflection_objects[ i ] Delete();
		}
		level._debug_reflection_objects = undefined;
	}

	if ( level._debug_reflection == 1 || level._debug_reflection == 3 )
	{
		level._debug_reflectionobject Delete();
	}
#/
}

create_reflection_objects()
{
/#
	reflection_locs = GetReflectionLocs();
	for ( i = 0; i < reflection_locs.size; i++ )
	{
		level._debug_reflection_objects[ i ] = Spawn( "script_model", reflection_locs[ i ] );
		level._debug_reflection_objects[ i ] SetModel( "test_sphere_silver" );
	}
#/
}

create_reflection_object()
{
/#
	level._debug_reflectionobject = Spawn( "script_model", level._player GetEye() + ( vector_multiply( AnglesToForward( level._player.angles ), 100 ) ) );
	level._debug_reflectionobject SetModel( "test_sphere_silver" );
	level._debug_reflectionobject.origin = level._player GetEye() + ( vector_multiply( AnglesToForward( level._player GetPlayerAngles() ), 100 ) );
	level._debug_reflectionobject LinkTo( level._player );
	thread 	debug_reflection_buttons();
#/
}

debug_reflection()
{
	/#
		if ( ( GetDebugDvar( "debug_reflection" ) == "2"  && level._debug_reflection != 2 ) || ( GetDebugDvar( "debug_reflection" ) == "3"  && level._debug_reflection != 3 ) )
		{
				remove_reflection_objects();
				if ( GetDebugDvar( "debug_reflection" ) == "2" )
				{
					create_reflection_objects();
					level._debug_reflection = 2;
				}
				else
				{
					create_reflection_objects();
					create_reflection_object();
					level._debug_reflection = 3;
				}
		}
		else if ( GetDebugDvar( "debug_reflection" ) == "1"  && level._debug_reflection != 1 )
		{
				remove_reflection_objects();
				create_reflection_object();
				level._debug_reflection = 1;
		}
		else if ( GetDebugDvar( "debug_reflection" ) == "0" && level._debug_reflection != 0 )
		{
				remove_reflection_objects();
				level._debug_reflection = 0;
		}
		#/
}

debug_reflection_buttons()
{
	/#
	offset = 100;
	lastoffset = offset;
	offsetinc = 50;
	while ( GetDebugDvar( "debug_reflection" ) == "1" || GetDebugDvar( "debug_reflection" ) == "3" )
	{
		if ( level._player ButtonPressed( "BUTTON_X" ) )
			offset += offsetinc;
		if ( level._player ButtonPressed( "BUTTON_Y" ) )
			offset -= offsetinc;
		if ( offset > 1000 )
			offset = 1000;
		if ( offset < 64 )
			offset = 64;
//		if( offset!=lastoffset )
//		{
			level._debug_reflectionobject Unlink();
			level._debug_reflectionobject.origin = level._player GetEye() + ( vector_multiply( AnglesToForward( level._player GetPlayerAngles() ), offset ) );
			lastoffset = offset;
		level._debug_reflectionobject LinkTo( level._player );
//			}
		wait .05;
	}
	#/
}

remove_fxlighting_object()
{
	/#
		if ( level._debug_fxlighting == 1 )
		{
			level._debug_fxlightingobject Delete();
		}
	#/
}

create_fxlighting_object()
{
	/#
		level._debug_fxlightingobject = Spawn( "script_model", level._player GetEye() + ( vector_multiply( AnglesToForward( level._player.angles ), 100 ) ) );
		level._debug_fxlightingobject SetModel( "tag_origin" );
		level._debug_fxlightingobject.origin = level._player GetEye() + ( vector_multiply( AnglesToForward( level._player GetPlayerAngles() ), 100 ) );
		level._debug_fxlightingobject LinkTo( level._player );
		level._debug_fxlightingobject thread play_fxlighting_fx();
		thread 	debug_fxlighting_buttons();
	#/
}

play_fxlighting_fx()
{
	self endon( "death" );
	while ( true )
	{
		PlayFXOnTag( getfx( "lighting_fraction" ), self, "tag_origin" );
		wait( 0.1 );
	}

}

debug_fxlighting()
{
	/#
		if ( GetDebugDvar( "debug_fxlighting" ) == "1"  && level._debug_fxlighting != 1 )
		{
				create_fxlighting_object();
				level._debug_fxlighting = 1;
		}
		else if ( GetDebugDvar( "debug_fxlighting" ) == "0" && level._debug_fxlighting != 0 )
		{
				remove_fxlighting_object();
				level._debug_fxlighting = 0;
		}
	#/
}

debug_fxlighting_buttons()
{
	/#
	offset = 100;
	lastoffset = offset;
	offsetinc = 50;
	while ( GetDebugDvar( "debug_fxlighting" ) == "1" || GetDebugDvar( "debug_fxlighting" ) == "3" )
	{
		if ( level._player ButtonPressed( "BUTTON_X" ) )
			offset += offsetinc;
		if ( level._player ButtonPressed( "BUTTON_Y" ) )
			offset -= offsetinc;
		if ( offset > 1000 )
			offset = 1000;
		if ( offset < 64 )
			offset = 64;

		level._debug_fxlightingobject Unlink();
		level._debug_fxlightingobject.origin = level._player GetEye() + ( vector_multiply( AnglesToForward( level._player GetPlayerAngles() ), offset ) );
		lastoffset = offset;
		level._debug_fxlightingobject LinkTo( level._player );
		wait .05;
	}
	#/
}

showDebugTrace()
{
	startOverride = undefined;
	endOverride = undefined;
	startOverride = ( 15.1859, -12.2822, 4.071 );
	endOverride = ( 947.2, -10918, 64.9514 );

	Assert( !isdefined( level._traceEnd ) );
	for ( ;; )
	{
		wait( 0.05 );
		start = startOverride;
		end = endOverride;
		if ( !isdefined( startOverride ) )
			start = level._traceStart;
		if ( !isdefined( endOverride ) )
			end = level._player GetEye();

		trace = BulletTrace( start, end, false, undefined );
		Line( start, trace[ "position" ], ( 0.9, 0.5, 0.8 ), 0.5 );
	}
}

hatmodel()
{
	/#
	for ( ;; )
	{
		if ( GetDebugDvar( "debug_hatmodel" ) == "off" )
			return;
		noHat = [];
		ai = GetAIArray();

		for ( i = 0; i < ai.size; i++ )
		{
			if ( IsDefined( ai[ i ].hatmodel ) )
				continue;

			alreadyKnown = false;
			for ( p = 0; p < noHat.size; p++ )
			{
				if ( noHat[ p ] != ai[ i ].classname )
					continue;
				alreadyKnown = true;
				break;
			}
			if ( !alreadyKnown )
				noHat[ noHat.size ] = ai[ i ].classname;
		}

		if ( noHat.size )
		{
			PrintLn( " " );
			PrintLn( "The following AI have no Hatmodel, so helmets can not pop off on head-shot death:" );
			for ( i = 0; i < noHat.size; i++ )
				PrintLn( "Classname: ", noHat[ i ] );
			PrintLn( "To disable hatModel spam, type debug_hatmodel off" );
		}
		wait( 15 );
	}
	#/
}

debug_character_count()
{
	//drones
	drones = NewHudElem();
	drones.alignX = "left";
	drones.alignY = "middle";
	drones.x = 10;
	drones.y = 100;
	// drones: [&&1]
	drones.label = &"DEBUG_DRONES";
	drones.alpha = 0;

	//allies
	allies = NewHudElem();
	allies.alignX = "left";
	allies.alignY = "middle";
	allies.x = 10;
	allies.y = 115;
	// allies: [&&1]
	allies.label = &"DEBUG_ALLIES";
	allies.alpha = 0;

	//allies
	axis = NewHudElem();
	axis.alignX = "left";
	axis.alignY = "middle";
	axis.x = 10;
	axis.y = 130;
	// axis: [&&1]
	axis.label = &"DEBUG_AXIS";
	axis.alpha = 0;


	//vehicles
	vehicles = NewHudElem();
	vehicles.alignX = "left";
	vehicles.alignY = "middle";
	vehicles.x = 10;
	vehicles.y = 145;
	// drones: [&&1]
	vehicles.label = &"DEBUG_VEHICLES";
	vehicles.alpha = 0;

	//total
	total = NewHudElem();
	total.alignX = "left";
	total.alignY = "middle";
	total.x = 10;
	total.y = 160;
	// total: [&&1]
	total.label = &"DEBUG_TOTAL";
	total.alpha = 0;

	lastdvar = "off";
	for ( ;; )
	{
		dvar = GetDvar( "debug_character_count" );
		if ( dvar == "off" )
		{
			if ( dvar != lastdvar )
			{
				drones.alpha = 0;
				allies.alpha = 0;
				axis.alpha = 0;
				vehicles.alpha = 0;
				total.alpha = 0;
				lastdvar = dvar;
			}
			wait .25;
			continue;
		}
		else
		{
			if ( dvar != lastdvar )
			{
				drones.alpha = 1;
				allies.alpha = 1;
				axis.alpha = 1;
				vehicles.alpha = 1;
				total.alpha = 1;
				lastdvar = dvar;

			}
		}
		//drones
		count_drones = GetEntArray( "drone", "targetname" ).size;
		drones SetValue( count_drones );

		//allies
		count_allies = GetAIArray( "allies" ).size;
		allies SetValue( count_allies );

		//axis
		count_axis = GetAIArray( "bad_guys" ).size;
		axis SetValue( count_axis );

		vehicles SetValue( GetEntArray( "script_vehicle", "classname" ).size );

		//total
		total SetValue( count_drones + count_allies + count_axis );

		wait 0.25;
	}
}

nuke()
{
	if ( !self.damageshield )
		self Kill( ( 0, 0, -500 ), level._player, level._player );
}

debug_nuke()
{
/#
	dvar = GetDvar( "debug_nuke" );
	if ( dvar == "on" )
	{
		ai = GetAISpeciesArray( "bad_guys", "all" );
		for ( i = 0; i < ai.size; i++ )
			ai[ i ] nuke();
	}
	else
	if ( dvar == "ai" )
	{
		ai = GetAIArray( "bad_guys" );
		for ( i = 0; i < ai.size; i++ )
			ai[ i ] nuke();
	}
	else
	if ( dvar == "dogs" )
	{
		ai = GetAISpeciesArray( "bad_guys", "dog" );
		for ( i = 0; i < ai.size; i++ )
			ai[ i ] nuke();
	}
	SetDvar( "debug_nuke", "off" );
#/
}

debug_missTime()
{

}

camera()
{
	wait( 0.05 );
	cameras = GetEntArray( "camera", "targetname" );
	for ( i = 0; i < cameras.size; i++ )
	{
		ent = GetEnt( cameras[ i ].target, "targetname" );
		cameras[ i ].origin2 = ent.origin;
		cameras[ i ].angles = VectorToAngles( ent.origin - cameras[ i ].origin );
	}
	for ( ;; )
	{
		/#
		if ( GetDebugDvar( "camera" ) != "on" )
		{
			if ( GetDebugDvar( "camera" ) != "off" )
				SetDvar( "camera", "off" );
			wait( 1 );
			continue;
		}
		#/

		ai = GetAIArray( "axis" );
		if ( !ai.size )
		{
			freePlayer();
			wait( 0.5 );
			continue;
		}
		cameraWithEnemy = [];
		for ( i = 0; i < cameras.size; i++ )
		{
			for ( p = 0; p < ai.size; p++ )
			{
				if ( Distance( cameras[ i ].origin, ai[ p ].origin ) > 256 )
					continue;
				cameraWithEnemy[ cameraWithEnemy.size ] = cameras[ i ];
				break;
			}
		}
		if ( !cameraWithEnemy.size )
		{
			freePlayer();
			wait( 0.5 );
			continue;
		}

		cameraWithPlayer = [];
		for ( i = 0; i < cameraWithEnemy.size; i++ )
		{
			camera = cameraWithEnemy[ i ];

			start = camera.origin2;
			end = camera.origin;
			difference = VectorToAngles( ( end[ 0 ], end[ 1 ], end[ 2 ] ) - ( start[ 0 ], start[ 1 ], start[ 2 ] ) );
			angles = ( 0, difference[ 1 ], 0 );
		    forward = AnglesToForward( angles );

			difference = VectorNormalize( end - level._player.origin );
			dot = VectorDot( forward, difference );
			if ( dot < 0.85 )
				continue;

			cameraWithPlayer[ cameraWithPlayer.size ] = camera;
		}

		if ( !cameraWithPlayer.size )
		{
			freePlayer();
			wait( 0.5 );
			continue;
		}

		dist = Distance( level._player.origin, cameraWithPlayer[ 0 ].origin );
		newcam = cameraWithPlayer[ 0 ];
		for ( i = 1; i < cameraWithPlayer.size; i++ )
		{
			newdist = Distance( level._player.origin, cameraWithPlayer[ i ].origin );
			if ( newdist > dist )
				continue;

			newcam = cameraWithPlayer[ i ];
			dist = newdist;
		}

		setPlayerToCamera( newcam );
		wait( 3 );
	}
}

freePlayer()
{
	SetDvar( "cl_freemove", "0" );
}

setPlayerToCamera( camera )
{
	SetDvar( "cl_freemove", "2" );
	SetDebugAngles( camera.angles );
	SetDebugOrigin( camera.origin + ( 0, 0, -60 ) );
}
/*
	waitframe();
	thread anglescheck();

	if( !isdefined( level.camera ) )
		return;

//	wait( 1 );
	mintime = 0;
	linker = false;
	while( GetDvar( "camera" ) == "on" )
	{
		for( i=0;i<level.camera.size;i++ )
		{
			if( GetDvar( "camera" ) != "on" )
				break;

			SetDvar( "nextcamera", "on" );
			SetDvar( "lastcamera", "on" );

			level.player SetOrigin( level.camera[ i ].origin );
			level.player LinkTo( level.camera[ i ] );

			level.player SetPlayerAngles( level.camera[ i ].angles );

			timer = GetTime() + 10000;
			if( timer < mintime )
				timer = mintime;

			oldorigin = level.player GetOrigin();
			while( GetTime() < timer )
			{
				if( GetTime() > timer - 8000 )
				if(( GetTime() > mintime ) &&( Distance( level.player GetOrigin(), oldorigin ) > 128 ) )
				{
					mintime = GetTime() + 500000;
					timer = mintime;
				}

				if( GetDvar( "camera" ) != "on" )
					break;

				if( GetDvar( "nextcamera" ) == "1" )
					break;

				if( GetDvar( "lastcamera" ) == "1" )
				{
					i-=2;
					if( i < 0 )
						i+=level.camera.size;
					break;
				}

				waitframe();
			}

			if(( GetDvar( "nextcamera" ) == "1" ) ||( GetDvar( "lastcamera" ) == "1" ) )
				mintime = GetTime() + 500000;
		}
	}

	if( linker )
		level.player Unlink();
}
*/

anglescheck()
{
	while ( 1 )
	{
		if ( GetDvar( "angles", "0" ) == "1" )
		{
			PrintLn( "origin " + level._player GetOrigin() );
			PrintLn( "angles " + level._player.angles );
			SetDvar( "angles", "0" );
		}
		wait( 1 );
	}
}

dolly()
{
	if ( !isdefined( level._dollyTime ) )
		level._dollyTime = 5;
	SetDvar( "dolly", "" );
	thread dollyStart();
	thread dollyEnd();
	thread dollyGo();
}

dollyStart()
{
	while ( 1 )
	{
		if ( GetDvar( "dolly" ) == "start" )
		{
			level._dollystart = level._player.origin;
			SetDvar( "dolly", "" );
		}
		wait( 1 );
	}
}

dollyEnd()
{
	while ( 1 )
	{
		if ( GetDvar( "dolly" ) == "end" )
		{
			level._dollyend = level._player.origin;
			SetDvar( "dolly", "" );
		}
		wait( 1 );
	}
}

dollyGo()
{
	while ( 1 )
	{
		wait( 1 );
		if ( GetDvar( "dolly" ) == "go" )
		{
			SetDvar( "dolly", "" );
			if ( !isdefined( level._dollystart ) )
			{
				PrintLn( "NO Dolly Start!" );
				continue;
			}
			if ( !isdefined( level._dollyend ) )
			{
				PrintLn( "NO Dolly End!" );
				continue;
			}

			org = Spawn( "script_origin", ( 0, 0, 0 ) );
			org.origin = level._dollystart;
			level._player SetOrigin( org.origin );
			level._player LinkTo( org );

			org MoveTo( level._dollyend, level._dollyTime );
			wait( level._dollyTime );
			org Delete();
		}
	}
}

deathspawnerPreview()
{
	waittillframeend;
	for ( i = 0; i < 50; i++ )
	{
		if ( !isdefined( level._deathspawnerents[ i ] ) )
			continue;
		array = level._deathspawnerents[ i ];
		for ( p = 0; p < array.size; p++ )
		{
			ent = array[ p ];
			if ( IsDefined( ent.truecount ) )
				Print3d( ent.origin, i + ": " + ent.truecount, ( 0, 0.8, 0.6 ), 5 );
			else
				Print3d( ent.origin, i + ": " + ".", ( 0, 0.8, 0.6 ), 5 );
		}
	}
}


lastSightPosWatch()
{
	/#
	for ( ;; )
	{
		wait( 0.05 );
		num = GetDvarInt( "lastsightpos" );
		if ( !num )
			continue;

		guy = undefined;
		ai = GetAIArray();
		for ( i = 0; i < ai.size; i++ )
		{
			if ( ai[ i ] GetEntNum() != num )
				continue;

			guy = ai[ i ];
			break;
		}

		if ( !isalive( guy ) )
			continue;

		if ( guy animscripts\utility::hasEnemySightPos() )
			org = guy animscripts\utility::getEnemySightPos();
		else
			org = undefined;


		for ( ;; )
		{
			newnum = GetDvarInt( "lastsightpos" );
			if ( num != newnum )
				break;

			if ( ( IsAlive( guy ) ) && ( guy animscripts\utility::hasEnemySightPos() ) )
				org = guy animscripts\utility::getEnemySightPos();

			if ( !isdefined( org ) )
			{
				wait( 0.05 );
				continue;
			}

			range = 10;
			color = ( 0.2, 0.9, 0.8 );
			Line( org + ( 0, 0, range ), org + ( 0, 0, range * -1 ), color, 1.0 );
			Line( org + ( range, 0, 0 ), org + ( range * -1, 0, 0 ), color, 1.0 );
			Line( org + ( 0, range, 0 ), org + ( 0, range * -1, 0 ), color, 1.0 );
			wait( 0.05 );
		}
	}
	#/
}

watchMinimap()
{
	PreCacheItem( "defaultweapon" );
	level thread spawnBBOverheadAutoCreation();
	while ( 1 )
	{
		updateMinimapSetting();
		updateBBOverheadCreation();
		wait .25;
	}
}

updateMinimapSetting()
{
	minimapheight = GetDvarFloat( "scr_minimap_height" );
	if( !setupMiniMap( minimapheight ) )
	{
		PrintLn( "^1Error: There are not exactly 2 \"minimap_corner\" entities in the level." );
	}
}

setupMiniMap( minimapheight )
{
	// use 0 for no required map aspect ratio.
	requiredMapAspectRatio = GetDvarFloat( "scr_requiredMapAspectRatio", 1 );
	
	if ( !isdefined( level._minimapheight ) ) {
		SetDvar( "scr_minimap_height", "0" );
		level._minimapheight = 0;
	}

	ret = false;
	if ( minimapheight != level._minimapheight )
	{
		if ( IsDefined( level._minimaporigin ) ) {
			level._minimapplayer Unlink();
			level._minimaporigin Delete();
			level notify( "end_draw_map_bounds" );
		}

		if ( minimapheight > 0 )
		{
			level._minimapheight = minimapheight;

			player = level._player;

			corners = GetEntArray( "minimap_corner", "targetname" );
			if ( corners.size == 2 )
			{
				viewpos = ( corners[ 0 ].origin + corners[ 1 ].origin );
				viewpos = ( viewpos[ 0 ] * .5, viewpos[ 1 ] * .5, viewpos[ 2 ] * .5 );

				maxcorner = ( corners[ 0 ].origin[ 0 ], corners[ 0 ].origin[ 1 ], viewpos[ 2 ] );
				mincorner = ( corners[ 0 ].origin[ 0 ], corners[ 0 ].origin[ 1 ], viewpos[ 2 ] );
				if ( corners[ 1 ].origin[ 0 ] > corners[ 0 ].origin[ 0 ] )
					maxcorner = ( corners[ 1 ].origin[ 0 ], maxcorner[ 1 ], maxcorner[ 2 ] );
				else
					mincorner = ( corners[ 1 ].origin[ 0 ], mincorner[ 1 ], mincorner[ 2 ] );
				if ( corners[ 1 ].origin[ 1 ] > corners[ 0 ].origin[ 1 ] )
					maxcorner = ( maxcorner[ 0 ], corners[ 1 ].origin[ 1 ], maxcorner[ 2 ] );
				else
					mincorner = ( mincorner[ 0 ], corners[ 1 ].origin[ 1 ], mincorner[ 2 ] );

				viewpostocorner = maxcorner - viewpos;
				viewpos = ( viewpos[ 0 ], viewpos[ 1 ], viewpos[ 2 ] + minimapheight );

				origin = Spawn( "script_origin", player.origin );

				northvector = ( Cos( GetNorthYaw() ), Sin( GetNorthYaw() ), 0 );
				eastvector = ( northvector[ 1 ], 0 - northvector[ 0 ], 0 );
				disttotop = VectorDot( northvector, viewpostocorner );
				if ( disttotop < 0 )
					disttotop = 0 - disttotop;
				disttoside = VectorDot( eastvector, viewpostocorner );
				if ( disttoside < 0 )
					disttoside = 0 - disttoside;

				// extend map bounds to meet the required aspect ratio
				if ( requiredMapAspectRatio > 0 )
				{
					mapAspectRatio = disttoside / disttotop;
					if ( mapAspectRatio < requiredMapAspectRatio )
					{
						incr = requiredMapAspectRatio / mapAspectRatio;
						disttoside *= incr;
						addvec = vecscale( eastvector, VectorDot( eastvector, maxcorner - viewpos ) * ( incr - 1 ) );
						mincorner -= addvec;
						maxcorner += addvec;
					}
					else
					{
						incr = mapAspectRatio / requiredMapAspectRatio;
						disttotop *= incr;
						addvec = vecscale( northvector, VectorDot( northvector, maxcorner - viewpos ) * ( incr - 1 ) );
						mincorner -= addvec;
						maxcorner += addvec;
					}
				}

				if ( level._console )
				{
					aspectratioguess = 16.0 / 9.0;
					// .8 would be .75 but it needs to be bigger because of safe area
					angleside = 2 * ATan( disttoside * .8 / minimapheight );
					angletop = 2 * ATan( disttotop * aspectratioguess * .8 / minimapheight );
				}
				else
				{
					aspectratioguess = 4.0 / 3.0;
					// multiply by 1.05 to give some margin to work with
					angleside = 2 * ATan( disttoside * 1.05 / minimapheight );
					angletop = 2 * ATan( disttotop * aspectratioguess * 1.05 / minimapheight );
				}
				if ( angleside > angletop )
					angle = angleside;
				else
					angle = angletop;

				znear = minimapheight - 1000;
				if ( znear < 16 ) znear = 16;
				if ( znear > 10000 ) znear = 10000;

				player PlayerLinkToAbsolute( origin );
				origin.origin = viewpos + ( 0, 0, -62 );
				origin.angles = ( 90, GetNorthYaw(), 0 );

				// because some guns can mess up the field of view, require default weapon
				player GiveWeapon( "defaultweapon" );
				SetSavedDvar( "cg_fov", angle );

				// Internal Dvar set: cg_drawgun - Internal Dvars cannot be changed by script. Use 'setsaveddvar' to alter SAVED internal dvars
				// setsaveddvar can only be called on dvars with the SAVED flag set
				// Error: "cg_drawgun" is not a valid dvar to set using setclientdvar

				level._minimapplayer = player;
				level._minimaporigin = origin;
				
				thread drawMiniMapBounds( viewpos, mincorner, maxcorner );
				ret = true;
			}
		}
		else
		{
			ret = true;
		}
	}
	else
	{
		ret = true;
	}
	return ret;
}

spawnBBOverheadAutoCreation()
{	
	player = level._player; //level waittill("connected", player);
	
	player thread updateBBOverheadAutoCreation();
}

updateBBOverheadAutoCreation()
{
	self endon( "disconnect" );
	doAutoUpload = GetDvar( "scr_bbOverheadMapAutoUpload" );
	if( doAutoUpload == "1" )
	{
		wait 15;
		bbCreateOverhead( 10000 );
		bboverheadautouploadnext();
	}
}

updateBBOverheadCreation()
{
	shouldUpload = getdvarint( "scr_bbOverheadMapUpload" );
	if( shouldUpload >= 1 )
	{
		if( shouldUpload == 1 )
		{
			shouldUpload = 10000;
		}
		SetDvar( "scr_bbOverheadMapUpload", "0" );
		bbCreateOverhead( shouldUpload );
	}
}

bbCreateOverhead( minimapHeight )
{
	if( setupMiniMap( minimapHeight ) ) // taken from http://wiki2.neversoft.com/index.php/COD:Step_by_Step:_EricMs_Guide_To_Making_A_New_Multiplayer_Level#Notes_about_kill_streaks_and_mini_map_compass
	{
		bboverheadprepare();
		wait 0.5;
		bbuploadoverhead();
		PrintLn( "BlackBox: Finished uploading map to BlackBox backend" );
	}
	else
	{
		PrintLn( "^1BlackBox Error: There are not exactly 2 \"minimap_corner\" entities in the level." );
		PrintLn( "^1BlackBox Error: You need to add these to your map to create minimaps as well as upload maps to blackbox." );
	}
}

getchains()
{
	chainarray = [];
	chainarray = GetEntArray( "minimap_line", "script_noteworthy" );
	array = [];
	for ( i = 0; i < chainarray.size; i++ )
	{
		array[ i ] = chainarray[ i ] getchain();
	}
	return array;
}

getchain()
{
	array = [];
	ent = self;
	while ( IsDefined( ent ) )
	{
		array[ array.size ] = ent;
		if ( !isdefined( ent ) || !isdefined( ent.target ) )
			break;
		ent = GetEnt( ent.target, "targetname" );
		if ( IsDefined( ent ) && ent == array[ 0 ] )
		{
			array[ array.size ] = ent;
			break;
		}
	}
	originarray = [];
	for ( i = 0; i < array.size; i++ )
		originarray[ i ] = array[ i ].origin;
	return originarray;

}

vecscale( vec, scalar )
{
	return( vec[ 0 ] * scalar, vec[ 1 ] * scalar, vec[ 2 ] * scalar );
}

drawMiniMapBounds( viewpos, mincorner, maxcorner )
{
	level notify( "end_draw_map_bounds" );
	level endon( "end_draw_map_bounds" );

	viewheight = ( viewpos[ 2 ] - maxcorner[ 2 ] );

	diaglen = Length( mincorner - maxcorner );

	mincorneroffset = ( mincorner - viewpos );
	mincorneroffset = VectorNormalize( ( mincorneroffset[ 0 ], mincorneroffset[ 1 ], 0 ) );
	mincorner = mincorner + vecscale( mincorneroffset, diaglen * 1 / 800 * 0 );
	maxcorneroffset = ( maxcorner - viewpos );
	maxcorneroffset = VectorNormalize( ( maxcorneroffset[ 0 ], maxcorneroffset[ 1 ], 0 ) );
	maxcorner = maxcorner + vecscale( maxcorneroffset, diaglen * 1 / 800 * 0 );

	north = ( Cos( GetNorthYaw() ), Sin( GetNorthYaw() ), 0 );

	diagonal = maxcorner - mincorner;
	side = vecscale( north, VectorDot( diagonal, north ) );
	sidenorth = vecscale( north, abs( VectorDot( diagonal, north ) ) );

	corner0 = mincorner;
	corner1 = mincorner + side;
	corner2 = maxcorner;
	corner3 = maxcorner - side;

	toppos = vecscale( mincorner + maxcorner, .5 ) + vecscale( sidenorth, .51 );
	textscale = diaglen * .003;
	chains = getchains();


	while ( 1 )
	{
		Line( corner0, corner1 );
		Line( corner1, corner2 );
		Line( corner2, corner3 );
		Line( corner3, corner0 );

		array_levelthread( chains, ::plot_points );

		Print3d( toppos, "This Side Up", ( 1, 1, 1 ), 1, textscale );

		wait .05;
	}
}




islookingatorigin( origin )
{
	normalvec = VectorNormalize( origin - self GetShootAtPos() );
	veccomp = VectorNormalize( ( origin - ( 0, 0, 24 ) ) - self GetShootAtPos() );
	insidedot = VectorDot( normalvec, veccomp );

	anglevec = AnglesToForward( self GetPlayerAngles() );
	vectordot = VectorDot( anglevec, normalvec );
	if ( vectordot > insidedot )
		return true;
	else
		return false;
}

debug_colornodes()
{
	wait( 0.05 );
	ai = GetAIArray();

	array = [];
	array[ "axis" ] = [];
	array[ "allies" ] = [];
	array[ "neutral" ] = [];
	for ( i = 0; i < ai.size; i++ )
	{
		guy = ai[ i ];

		if ( !isdefined( guy.currentColorCode ) )
			continue;

		array[ guy.team ][ guy.currentColorCode ] = true;

		color = ( 1, 1, 1 );
		if ( IsDefined( guy.script_forcecolor ) )
			color = level._color_debug[ guy.script_forcecolor ];

		Print3d( guy.origin + ( 0, 0, 50 ), guy.currentColorCode, color, 1, 1 );

		// axis dont do forcecolor behavior, they do follow the leader for force color
		if ( guy.team == "axis" )
			continue;

		guy try_to_draw_line_to_node();
	}

	draw_colorNodes( array, "allies" );
	draw_colorNodes( array, "axis" );
}

draw_colorNodes( array, team )
{
	keys = GetArrayKeys( array[ team ] );
	for ( i = 0; i < keys.size; i++ )
	{
		color = ( 1, 1, 1 );
		// use the first letter of the key as the color
		color = level._color_debug[ GetSubStr( keys[ i ], 0, 1 ) ];

		if ( IsDefined( level._colorNodes_debug_array[ team ][ keys[ i ] ] ) )
		{
			teamArray = level._colorNodes_debug_array[ team ][ keys[ i ] ];
			for ( p = 0; p < teamArray.size; p++ )
			{
				Print3d( teamArray[ p ].origin, "N-" + keys[ i ], color, 1, 1 );
			}
		}
	}
}

get_team_substr()
{
	if ( self.team == "allies" )
	{
		if ( !isdefined( self.node.script_color_allies ) )
			return;

		return self.node.script_color_allies;
	}

	if ( self.team == "axis" )
	{
		if ( !isdefined( self.node.script_color_axis ) )
			return;

		return self.node.script_color_axis;
	}
}

try_to_draw_line_to_node()
{
	if ( !isdefined( self.node ) )
		return;

	if ( !isdefined( self.script_forcecolor ) )
		return;

	substr = get_team_substr();
	if ( !isdefined( substr ) )
		return;

	if ( !issubstr( substr, self.script_forcecolor ) )
		return;

	Line( self.origin + ( 0, 0, 64 ), self.node.origin, level._color_debug[ self.script_forcecolor ] );
}

fogcheck()
{
	if ( GetDvar( "depth_close" ) == "" )
		SetDvar( "depth_close", "0" );

	if ( GetDvar( "depth_far" ) == "" )
		SetDvar( "depth_far", "1500" );

	close = GetDvarInt( "depth_close" );
	far = GetDvarInt( "depth_far" );
	SetExpFog( close, far, 1, 1, 1, 1, 0 );
}

debugThreat()
{
//	if( GetTime() > level.last_threat_debug + 1000 )
	{
		level._last_threat_debug = GetTime();
		thread debugThreatCalc();
	}
}

debugThreatCalc()
{
	// debug the threatbias from entities towards the specified ent
	/#
	ai = GetAIArray();
	entnum = GetDebugDvarInt( "debug_threat" );
	entity = undefined;
	if ( entnum == 0 )
	{
		entity = level._player;
	}
	else
	{
		for ( i = 0; i < ai.size; i++ )
		{
			if ( entnum != ai[ i ] GetEntNum() )
				continue;
			entity = ai[ i ];
			break;
		}
	}

	if ( !isalive( entity ) )
		return;

	entityGroup = entity GetThreatBiasGroup();
	array_thread( ai, ::displayThreat, entity, entityGroup );
	level._player thread displayThreat( entity, entityGroup );
	#/
}

displayThreat( entity, entityGroup )
{
	if ( self.team == entity.team )
		return;

	selfthreat = 0;
	selfthreat += self.threatBias;

	threat = 0;
	threat += entity.threatBias;
	myGroup = undefined;

	if ( IsDefined( entityGroup ) )
	{
		myGroup = self GetThreatBiasGroup();
		if ( IsDefined( myGroup ) )
		{
			threat += GetThreatBias( entityGroup, myGroup );
			selfThreat += GetThreatBias( myGroup, entityGroup );
		}
	}

	if ( entity.ignoreme || threat < -900000 )
		threat = "Ignore";

	if ( self.ignoreme || selfthreat < -900000 )
		selfthreat = "Ignore";

	timer = 1 * 20;
	col = ( 1, 0.5, 0.2 );
	col2 = ( 0.2, 0.5, 1 );
	pacifist = !isplayer( self ) && self.pacifist;

	for ( i = 0; i <= timer; i++ )
	{
		Print3d( self.origin + ( 0, 0, 65 ), "Him to Me:", col, 3 );
		Print3d( self.origin + ( 0, 0, 50 ), threat, col, 5 );
		if ( IsDefined( entityGroup ) )
		{
			Print3d( self.origin + ( 0, 0, 35 ), entityGroup, col, 2 );
		}

		Print3d( self.origin + ( 0, 0, 15 ), "Me to Him:", col2, 3 );
		Print3d( self.origin + ( 0, 0, 0 ), selfThreat, col2, 5 );
		if ( IsDefined( mygroup ) )
		{
			Print3d( self.origin + ( 0, 0, -15 ), mygroup, col2, 2 );
		}
		if ( pacifist )
		{
			Print3d( self.origin + ( 0, 0, 25 ), "( Pacifist )", col2, 5 );
		}

		wait( 0.05 );
	}
}

debugColorFriendlies()
{
	level._debug_color_friendlies = [];
	level._debug_color_huds = [];

	for ( ;; )
	{
		level waittill( "updated_color_friendlies" );
		draw_color_friendlies();
	}
}

draw_color_friendlies()
{
	level endon( "updated_color_friendlies" );
	keys = GetArrayKeys( level._debug_color_friendlies );

	colored_friendlies = [];
	colors = [];
	colors[ colors.size ] = "r";
	colors[ colors.size ] = "o";
	colors[ colors.size ] = "y";
	colors[ colors.size ] = "g";
	colors[ colors.size ] = "c";
	colors[ colors.size ] = "b";
	colors[ colors.size ] = "p";

	rgb = get_script_palette();


	for ( i = 0; i < colors.size; i++ )
	{
		colored_friendlies[ colors[ i ] ] = 0;
	}

	for ( i = 0; i < keys.size; i++ )
	{
		color = level._debug_color_friendlies[ keys[ i ] ];
		colored_friendlies[ color ]++;
	}

	for ( i = 0; i < level._debug_color_huds.size; i++ )
	{
		level._debug_color_huds[ i ] Destroy();
	}
	level._debug_color_huds = [];

/#
	if ( GetDebugDvar( "debug_colorfriendlies" ) != "on" )
		return;
#/

	x = 15;
	y = 365;
	offset_x = 25;
	offset_y = 25;
	for ( i = 0; i < colors.size; i++ )
	{
		if ( colored_friendlies[ colors[ i ] ] <= 0 )
			continue;
		for ( p = 0; p < colored_friendlies[ colors[ i ] ]; p++ )
		{
			overlay = NewHudElem();
			overlay.x = x + 25 * p;
			overlay.y = y;
			overlay SetShader( "white", 16, 16 );
			overlay.alignX = "left";
			overlay.alignY = "bottom";
			overlay.alpha = 1;
			overlay.color = rgb[ colors[ i ] ];
			level._debug_color_huds[ level._debug_color_huds.size ] = overlay;
		}

		y += offset_y;
	}
}

playerNode()
{
	for ( ;; )
	{
		if ( IsDefined( level._player.node ) )
			Print3d( level._player.node.origin + ( 0, 0, 25 ), "P-Node", ( 0.3, 1, 1 ), 1 );

		wait( 0.05 );
	}
}


drawUsers()
{
	if ( IsAlive( self.color_user ) )
	{
		Line( self.origin + ( 0, 0, 35 ), self.color_user.origin + ( 0, 0, 35 ), ( 1, 1, 1 ), 1.0 );

		Print3d( self.origin + ( 0, 0, -25 ), "in-use", ( 1, 1, 1 ), 1, 1 );
	}
}


debuggoalpos()
{
	for ( ;; )
	{
		ai = GetAIArray();
		array_thread( ai, ::view_goal_pos );
		wait( 0.05 );
	}
}

view_goal_pos()
{
	if ( !isdefined( self.goalpos ) )
		return;

	Line( self.origin + ( 0, 0, 35 ), self.goalpos + ( 0, 0, 35 ), ( 1, 1, 1 ), 1.0 );
}

colordebug()
{
	wait( 0.5 );
	col = [];
	col[ col.size ] = "r";
	col[ col.size ] = "g";
	col[ col.size ] = "b";
	col[ col.size ] = "y";
	col[ col.size ] = "o";
	col[ col.size ] = "p";
	col[ col.size ] = "c";

	for ( ;; )
	{
		for ( i = 0; i < col.size; i++ )
		{
			color = level._currentColorForced[ "allies" ][ col[ i ] ];
			if ( IsDefined( color ) )
				draw_colored_nodes( color );
		}
		wait( 0.05 );
	}
}

draw_colored_nodes( color )
{
	nodes = level._arrays_of_colorCoded_nodes[ "allies" ][ color ];
	array_thread( nodes, ::drawUsers );
}

init_animSounds()
{
	level._animSounds = [];
	level._animSound_aliases = [];
	waittillframeend;// now we know _load has run and the level.scr_notetracks have been defined
	waittillframeend;// wait one extra frameend because _audio.gso files waittillframeend and we have to start after them

	animnames = GetArrayKeys( level._scr_notetrack );
	for ( i = 0; i < animnames.size; i++ )
	{
		init_notetracks_for_animname( animnames[ i ] );
	}

	animnames = GetArrayKeys( level._scr_animSound );
	for ( i = 0; i < animnames.size; i++ )
	{
		init_animSounds_for_animname( animnames[ i ] );
	}
}

init_notetracks_for_animname( animname )
{
	// copy all the scr_notetracks into animsound_aliases so they show up properly
	// level.scr_notetrack[ animname ][ anime ][ notetrack ][ index ][ "dialog" ] = soundalias;
	foreach ( anime, anime_array in level._scr_notetrack[ animname ] )
	{
		foreach ( notetrack, notetrack_array in anime_array )
		{
			foreach ( scr_notetrack in notetrack_array )
			{
				soundAlias = scr_notetrack[ "sound" ];
				if ( !isdefined( soundAlias ) )
					continue;

				level._animSound_aliases[ animname ][ anime ][ notetrack ][ "soundalias" ] = soundalias;
				if ( IsDefined( scr_notetrack[ "created_by_animSound" ] ) )
				{
					level._animSound_aliases[ animname ][ anime ][ notetrack ][ "created_by_animSound" ] = true;
				}
			}
		}
	}
}

init_animSounds_for_animname( animname )
{
	// copy all the scr_animSounds into animsound_aliases so they show up properly
	animes = GetArrayKeys( level._scr_animSound[ animname ] );

	for ( i = 0; i < animes.size; i++ )
	{
		anime = animes[ i ];
		soundalias = level._scr_animSound[ animname ][ anime ];
		level._animSound_aliases[ animname ][ anime ][ "#" + anime ][ "soundalias" ] = soundalias;
		level._animSound_aliases[ animname ][ anime ][ "#" + anime ][ "created_by_animSound" ] = true;
	}
}

add_hud_line( x, y, msg )
{
	hudelm = NewHudElem();
	hudelm.alignX = "left";
	hudelm.alignY = "middle";
	hudelm.x = x;
	hudelm.y = y;
	hudelm.alpha = 1;
	hudelm.fontScale = 1;
	hudelm.label = msg;
	level._animsound_hud_extralines[ level._animsound_hud_extralines.size ] = hudelm;
	return hudelm;
}

debug_animSound()
{
	/#
	enabled = GetDebugDvar( "animsound" ) == "on";
	if ( !isdefined( level._animsound_hud ) )
	{
		if ( !enabled )
			return;

		// init the related variables
		level._animsound_selected = 0;
		level._animsound_input = "none";
		level._animsound_hud = [];
		level._animsound_hud_timer = [];
		level._animsound_hud_alias = [];
		level._animsound_hud_extralines = [];

		level._animsound_locked = false;
		level._animsound_locked_pressed = false;

		level._animsound_hud_animname = add_hud_line( -30, 180, "Actor: " );
		level._animsound_hud_anime = add_hud_line( 100, 180, "Anim: " );

		add_hud_line( 10, 190, "Notetrack or label" );
		add_hud_line( -30, 190, "Elapsed" );
		add_hud_line( -30, 160, "Del: Delete selected soundalias" );
		add_hud_line( -30, 150, "F12: Lock selection" );
		add_hud_line( -30, 140, "Add a soundalias with /tag alias or /tag# alias" );

		level._animsound_hud_locked = add_hud_line( -30, 170, "*LOCKED*" );
		level._animsound_hud_locked.alpha = 0;

		for ( i = 0; i < level._animsound_hudlimit; i++ )
		{
			hudelm = NewHudElem();
			hudelm.alignX = "left";
			hudelm.alignY = "middle";
			hudelm.x = 10;
			hudelm.y = 200 + i * 10;
			hudelm.alpha = 1;
			hudelm.fontScale = 1;
			hudelm.label = "";
			level._animsound_hud[ level._animsound_hud.size ] = hudelm;

			hudelm = NewHudElem();
			hudelm.alignX = "right";
			hudelm.alignY = "middle";
			hudelm.x = -10;
			hudelm.y = 200 + i * 10;
			hudelm.alpha = 1;
			hudelm.fontScale = 1;
			hudelm.label = "";
			level._animsound_hud_timer[ level._animsound_hud_timer.size ] = hudelm;

			hudelm = NewHudElem();
			hudelm.alignX = "right";
			hudelm.alignY = "middle";
			hudelm.x = 210;
			hudelm.y = 200 + i * 10;
			hudelm.alpha = 1;
			hudelm.fontScale = 1;
			hudelm.label = "";
			level._animsound_hud_alias[ level._animsound_hud_alias.size ] = hudelm;
		}

		// selected is yellow
		level._animsound_hud[ 0 ].color = ( 1, 1, 0 );
		level._animsound_hud_timer[ 0 ].color = ( 1, 1, 0 );
	}
	else
	if ( !enabled )
	{
		// animsound got turned off so delete the hud stuff
		for ( i = 0; i < level._animsound_hudlimit; i++ )
		{
			level._animsound_hud[ i ] Destroy();
			level._animsound_hud_timer[ i ] Destroy();
			level._animsound_hud_alias[ i ] Destroy();
		}

		for ( i = 0; i < level._animsound_hud_extralines.size; i++ )
		{
			level._animsound_hud_extralines[ i ] Destroy();
		}

		level._animsound_hud = undefined;
		level._animsound_hud_timer = undefined;
		level._animsound_hud_alias = undefined;
		level._animsound_hud_extralines = undefined;
		level._animSounds = undefined;
		return;
	}

	if ( !isdefined( level._animsound_tagged ) )
		level._animsound_locked = false;

	if ( level._animsound_locked )
		level._animsound_hud_locked.alpha = 1;
	else
		level._animsound_hud_locked.alpha = 0;

	if ( !isdefined( level._animSounds ) )
		init_animSounds();

	/*
	if( !isdefined( level.anim_sound_was_opened ) )
	{
		thread test_animsound_file();
	}
	*/

	level._animSounds_thisframe = [];
	level._animSounds = remove_undefined_from_array( level._animSounds );
	array_thread( level._animSounds, ::display_animSound );

	if ( level._animsound_locked )
	{
		for ( i = 0; i < level._animSounds_thisframe.size; i++ )
		{
			animSound = level._animSounds_thisframe[ i ];
			animSound.animsound_color = ( 0.5, 0.5, 0.5 );
		}
	}
	else
	{
		dot = 0.85;
		forward = AnglesToForward( level._player GetPlayerAngles() );
		for ( i = 0; i < level._animSounds_thisframe.size; i++ )
		{
			animSound = level._animSounds_thisframe[ i ];
			animSound.animsound_color = ( 0.25, 1.0, 0.5 );

			difference = VectorNormalize( ( animSound.origin + ( 0, 0, 40 ) ) - ( level._player.origin + ( 0, 0, 55 ) ) );
			newdot = VectorDot( forward, difference );
			if ( newdot < dot )
				continue;

			dot = newdot;
			level._animsound_tagged = animSound;
		}
	}

	if ( IsDefined( level._animsound_tagged ) )
	{
		level._animsound_tagged.animsound_color = ( 1.0, 1.0, 0.0 );
	}

	is_tagged = IsDefined( level._animsound_tagged );
	for ( i = 0; i < level._animSounds_thisframe.size; i++ )
	{
		animSound = level._animSounds_thisframe[ i ];
		scale = 1;
		/*
		soundalias = get_alias_from_stored( animSound );
		scale = 0.9;
		
		if( is_tagged && level.animsound_tagged == animSound )
			scale = 1;
			
		if( IsDefined( soundalias ) )
		{
			if( is_from_animsound( animSound.animname, animSound.anime, animSound.notetrack ) )
			{
				Print3d( animSound.origin, animSound.notetrack + " " + soundalias, animSound.color, 1, scale );
			}
			else
			{
				// put in a * so they know its unchangeable
				Print3d( animSound.origin, animSound.notetrack + " *" + soundalias, animSound.color, 1, scale );
			}
		}
		else
		{
			Print3d( animSound.origin, animSound.notetrack, animSound.color, 1, scale );
		}
		*/
		msg = "*";
		if ( level._animsound_locked )
			msg = "*LOCK";
		Print3d( animSound.origin + ( 0, 0, 40 ), msg + animSound.animsounds.size, animSound.animsound_color, 1, scale );
	}

	if ( is_tagged )
	{
		draw_animsounds_in_hud();
	}
	#/
}

draw_animsounds_in_hud()
{
	guy = level._animsound_tagged;
	animsounds = guy.animSounds;

	animname = "generic";
	if ( IsDefined( guy.animname ) )
		animname = guy.animname;
	level._animsound_hud_animname.label = "Actor: " + animname;


	if ( level._player ButtonPressed( "f12" ) )
	{
		if ( !level._animsound_locked_pressed )
		{
			level._animsound_locked = !level._animsound_locked;
			level._animsound_locked_pressed = true;
		}
	}
	else
	{
		level._animsound_locked_pressed = false;
	}

	if ( level._player ButtonPressed( "UPARROW" ) )
	{
		if ( level._animsound_input != "up" )
		{
			level._animsound_selected--;
		}

		level._animsound_input = "up";
	}
	else
	if ( level._player ButtonPressed( "DOWNARROW" ) )
	{
		if ( level._animsound_input != "down" )
		{
			level._animsound_selected++;
		}

		level._animsound_input = "down";
	}
	else
		level._animsound_input = "none";

	// clear out the hudelems	
	for ( i = 0; i < level._animsound_hudlimit; i++ )
	{
		hudelm = level._animsound_hud[ i ];
		hudelm.label = "";
		hudelm.color = ( 1, 1, 1 );
		hudelm = level._animsound_hud_timer[ i ];
		hudelm.label = "";
		hudelm.color = ( 1, 1, 1 );
		hudelm = level._animsound_hud_alias[ i ];
		hudelm.label = "";
		hudelm.color = ( 1, 1, 1 );
	}

	// get the highest existing animsound on the guy
	keys = GetArrayKeys( animsounds );
	highest = -1;
	for ( i = 0; i < keys.size; i++ )
	{
		if ( keys[ i ] > highest )
			highest = keys[ i ];
	}
	if ( highest == -1 )
		return;

	if ( level._animsound_selected > highest )
		level._animsound_selected = highest;
	if ( level._animsound_selected < 0 )
		level._animsound_selected = 0;

	// make sure the selected one exists
	for ( ;; )
	{
		if ( IsDefined( animsounds[ level._animsound_selected ] ) )
			break;

		level._animsound_selected--;
		if ( level._animsound_selected < 0 )
			level._animsound_selected = highest;
	}

	level._animsound_hud_anime.label = "Anim: " + animsounds[ level._animsound_selected ].anime;

	level._animsound_hud[ level._animsound_selected ].color = ( 1, 1, 0 );
	level._animsound_hud_timer[ level._animsound_selected ].color = ( 1, 1, 0 );
	level._animsound_hud_alias[ level._animsound_selected ].color = ( 1, 1, 0 );

	time = GetTime();
	for ( i = 0; i < keys.size; i++ )
	{
		key = keys[ i ];
		animsound = animsounds[ key ];
		hudelm = level._animsound_hud[ key ];
		soundalias = get_alias_from_stored( animSound );
		hudelm.label = ( key + 1 ) + ". " + animsound.notetrack;

		hudelm = level._animsound_hud_timer[ key ];
		hudelm.label = Int( ( time - ( animsound.end_time - 60000 ) ) * 0.001 );

		if ( IsDefined( soundalias ) )
		{
			hudelm = level._animsound_hud_alias[ key ];
			hudelm.label = soundalias;
			if ( !is_from_animsound( animSound.animname, animSound.anime, animSound.notetrack ) )
			{
				hudelm.color = ( 0.7, 0.7, 0.7 );
			}
		}
	}

	if ( level._player ButtonPressed( "del" ) )
	{
		// delete a sound on a guy
		animsound = animsounds[ level._animsound_selected ];
		soundalias = get_alias_from_stored( animsound );
		if ( !isdefined( soundalias ) )
			return;

		if ( !is_from_animsound( animSound.animname, animSound.anime, animSound.notetrack ) )
			return;

		level._animSound_aliases[ animSound.animname ][ animSound.anime ][ animSound.notetrack ] = undefined;
		debug_animSoundSave();
	}
}

get_alias_from_stored( animSound )
{
	if ( !isdefined( level._animSound_aliases[ animSound.animname ] ) )
		return;

	if ( !isdefined( level._animSound_aliases[ animSound.animname ][ animSound.anime ] ) )
		return;

	if ( !isdefined( level._animSound_aliases[ animSound.animname ][ animSound.anime ][ animSound.notetrack ] ) )
		return;
	return level._animSound_aliases[ animSound.animname ][ animSound.anime ][ animSound.notetrack ][ "soundalias" ];
}

is_from_animsound( animname, anime, notetrack )
{
	return IsDefined( level._animSound_aliases[ animname ][ anime ][ notetrack ][ "created_by_animSound" ] );
}

/*
test_animsound_file()
{
	level.anim_sound_was_opened = true;
	
	/#
	filename = "createfx/" + level.script + "_audio.gsc";
	for( ;; )
	{
		warning = NewHudElem();
		warning.alignX = "left";
		warning.alignY = "middle";
		warning.x = 10;
		warning.y = 150;
		warning.alpha = 0;
		warning.fontScale = 2;
		warning.label = filename + " is not open for edit, so you can not save your work. ";
		
		for( ;; )
		{
			file = OpenFile( filename, "write" );
			if( file != -1 )
				break;
			wait( 5 );
		}
	
		warning Destroy();
		break;
	}
	
	CloseFile( file );
	#/
}
*/

display_animSound()
{
	if ( Distance( level._player.origin, self.origin ) > 1500 )
		return;

	level._animSounds_thisframe[ level._animSounds_thisframe.size ] = self;

	/*
	timer = GetTime();
	keys = GetArrayKeys( self.animSounds );
	for( i=0; i < keys.size; i++ )
	{
		key = keys[ i ];
		animSound = self.animSounds[ key ];
		if( !isdefined( animSound ) )
			continue;
		
		if( timer > animSound.end_time )
		{
			self.animSounds[ key ] = undefined;
			continue;
		}
		
		animSound.origin = self.origin +( 0, 0, 50 + 10 * key );
		level.animSounds_thisframe[ level.animSounds_thisframe.size ] = animSound;
	}
	*/
}

debug_animSoundTag( tagnum )
{
	/#
	tag = GetDvar( "tag" + tagnum );
	if ( tag == "" )
	{
		IPrintLnBold( "Enter the soundalias with /tag# aliasname" );
		return;
	}

	tag_sound( tag, tagnum - 1 );

	SetDvar( "tag" + tagnum, "" );
	#/
}

debug_animSoundTagSelected()
{
	/#
	tag = GetDvar( "tag" );
	if ( tag == "" )
	{
		IPrintLnBold( "Enter the soundalias with /tag aliasname" );
		return;
	}

	tag_sound( tag, level._animsound_selected );

	SetDvar( "tag", "" );
	#/
}

tag_sound( tag, tagnum )
{
	if ( !isdefined( level._animsound_tagged ) )
		return;
	if ( !isdefined( level._animsound_tagged.animsounds[ tagnum ] ) )
		return;

	animSound = level._animsound_tagged.animsounds[ tagnum ];
	// store the alias to the array of aliases
	soundalias = get_alias_from_stored( animSound );
	if ( !isdefined( soundalias ) || is_from_animsound( animSound.animname, animSound.anime, animSound.notetrack ) )
	{
		level._animSound_aliases[ animSound.animname ][ animSound.anime ][ animSound.notetrack ][ "soundalias" ] = tag;
		level._animSound_aliases[ animSound.animname ][ animSound.anime ][ animSound.notetrack ][ "created_by_animSound" ] = true;
		debug_animSoundSave();
	}
}

debug_animSoundSave()
{
	/*
	tab = "     ";
	filename = "createfx/"+level.script+"_fx.gsc";
	file = OpenFile( filename, "write" );
	AssertEx( file != -1, "File not writeable( maybe you should check it out ): " + filename );
	cfxprintln( file, "//_createfx generated. Do not touch!!" );
	cfxprintln( file, "main()" );
	cfxprintln( file, "{" );
	*/

	/#
	filename = "createfx/" + level._script + "_audio.gsc";
	file = OpenFile( filename, "write" );
	if ( file == -1 )
	{
		IPrintLnBold( "Couldn't write to " + filename + ", make sure it is open for edit." );
		return;
	}

	IPrintLnBold( "Saved to " + filename );
	print_aliases_to_file( file );
	saved = CloseFile( file );
	SetDvar( "animsound_save", "" );
	#/
}

print_aliases_to_file( file )
{
	tab = "    ";
	FPrintLn( file, "#include maps\\_anim;" );
	FPrintLn( file, "main()" );
	FPrintLn( file, "{" );
	FPrintLn( file, tab + "// Autogenerated by AnimSounds. Threaded off so that it can be placed before _load( has to create level.scr_notetrack first )." );
	FPrintLn( file, tab + "thread init_animsounds();" );
	FPrintLn( file, "}" );
	FPrintLn( file, "" );
	FPrintLn( file, "init_animsounds()" );
	FPrintLn( file, "{" );
	FPrintLn( file, tab + "waittillframeend;" );

	animnames = GetArrayKeys( level._animSound_aliases );
	for ( i = 0; i < animnames.size; i++ )
	{
		animes = GetArrayKeys( level._animSound_aliases[ animnames[ i ] ] );
		for ( p = 0; p < animes.size; p++ )
		{
			anime = animes[ p ];
			notetracks = GetArrayKeys( level._animSound_aliases[ animnames[ i ] ][ anime ] );
			for ( z = 0; z < notetracks.size; z++ )
			{
				notetrack = notetracks[ z ];
				if ( !is_from_animsound( animnames[ i ], anime, notetrack ) )
					continue;

				alias = level._animSound_aliases[ animnames[ i ] ][ anime ][ notetrack ][ "soundalias" ];

				if ( notetrack == "#" + anime )
				{
					// this isn't really a notetrack, its from the _anim call.
					FPrintLn( file, tab + "addOnStart_animSound( " + tostr( animnames[ i ] ) + ", " + tostr( anime ) + ", " + tostr( alias ) + " ); " );
				}
				else
				{
					// this is attached to a notetrack					
					FPrintLn( file, tab + "addNotetrack_animSound( " + tostr( animnames[ i ] ) + ", " + tostr( anime ) + ", " + tostr( notetrack ) + ", " + tostr( alias ) + " ); " );
				}
				PrintLn( "^1Saved alias ^4" + alias + "^1 to notetrack ^4" + notetrack );
			}
		}
	}
	FPrintLn( file, "}" );
}

tostr( str )
{
	newstr = "\"";
	for ( i = 0; i < str.size; i++ )
	{
		if ( str[ i ] == "\"" )
		{
			newstr += "\\";
			newstr += "\"";
			continue;
		}

		newstr += str[ i ];
	}
	newstr += "\"";
	return newstr;
}

linedraw( start, end, color, alpha, depth, timer )
{
	if ( !isdefined( color ) )
		color = ( 1, 1, 1 );

	if ( IsDefined( timer ) )
	{
		timer *= 20;
		for ( i = 0; i < timer; i++ )
		{
			Line( start, end, color, alpha, depth );
			wait( 0.05 );
		}
	}
	else
	{
		for ( ;; )
		{
			Line( start, end, color, alpha, depth );
			wait( 0.05 );
		}
	}
}

print3ddraw( org, text, color )
{
	for ( ;; )
	{
		Print3d( org, text, color );
		wait( 0.05 );
	}
}

complete_me()
{
	if ( GetDvar( "credits_active" ) == "1" )
	{
		wait 7;
		SetDvar( "credits_active", "0" );
		maps\_endmission::credits_end();
		return;
	}
	wait 7;
	nextmission();
}

find_new_chase_target( ent_num )
{
	/#
	ai = GetAIArray();
	foreach ( guy in ai )
	{
		if ( guy GetEntNum() == ent_num )
		{
			level._chase_cam_target = guy;
			return;
		}
	}

	vehicles = GetEntArray( "script_vehicle", "code_classname" );
	foreach ( vehicle in vehicles )
	{
		if ( vehicle GetEntNum() == ent_num )
		{
			level._chase_cam_target = vehicle;
			return;
		}
	}
	#/
}


chaseCam( ent_num )
{
	if ( !isdefined( level._chase_cam_last_num ) )
	{
		level._chase_cam_last_num = -1;
	}

	if ( level._chase_cam_last_num == ent_num )
		return;

	find_new_chase_target( ent_num );

	if ( !isdefined( level._chase_cam_target ) )
		return;

	level._chase_cam_last_num = ent_num;

	if ( !isdefined( level._chase_cam_ent ) )
	{
		level._chase_cam_ent = level._chase_cam_target spawn_tag_origin();
	}

	thread chaseCam_onEnt( level._chase_cam_target );
}

chaseCam_onEnt( ent )
{
	level notify( "new_chasecam" );
	level endon( "new_chasecam" );
	ent endon( "death" );

	level._player Unlink();
	level._player PlayerLinkToBlend( level._chase_cam_ent, "tag_origin", 2, 0.5, 0.5 );
	wait( 2 );
	level._player PlayerLinkToDelta( level._chase_cam_ent, "tag_origin", 1, 180, 180, 180, 180 );
	for ( ;; )
	{
		wait( 0.2 );

		if ( !isdefined( level._chase_cam_target ) )
			return;

		start = level._chase_cam_target.origin;
		angles = level._chase_cam_target.angles;
		forward = AnglesToForward( angles );
		forward *= 200;
		start += forward;

		angles = level._player GetPlayerAngles();
		forward = AnglesToForward( angles );
		forward *= -200;
		level._chase_cam_ent MoveTo( start + forward, 0.2 );
	}
}

viewfx()
{
	foreach ( fx in level._createfxent )
	{
		if ( IsDefined( fx.looper ) )
			Print3d( fx.v[ "origin" ], ".", ( 1, 1, 0 ), 1, 1.5, 200 );
	}
}

add_key( key, val )
{
	PrintLn( "	\"" + key + "\" \"" + val + "\"" );
}

print_vehicle_info( noteworthy )
{
	if ( !isdefined( level._vnum ) )
		level._vnum = 9500;

	level._vnum++;

	layer = "bridge_helpers";
	PrintLn( "entity " + level._vnum );
	PrintLn( "{" );
	add_key( "origin", self.origin[ 0 ] + " " + self.origin[ 1 ] + " " + self.origin[ 2 ] );
	add_key( "angles", self.angles[ 0 ] + " " + self.angles[ 1 ] + " " + self.angles[ 2 ] );
	add_key( "targetname", "helper_model" );
	add_key( "model", self.model );
	add_key( "classname", "script_model" );
	add_key( "spawnflags", "4" );
	add_key( "_color", "0.443137 0.443137 1.000000" );
	PrintLn( "	layer \"" + layer + "\"" );

	if ( IsDefined( noteworthy ) )
		add_key( "script_noteworthy", noteworthy );

	PrintLn( "}" );
}

draw_dot_for_ent( entnum )
{
	/#
	ai = GetAIArray();
	foreach ( guy in ai )
	{
		if ( guy GetEntNum() != entnum )
			continue;
		guy draw_dot_for_guy();
	}
	#/
}

draw_dot_for_guy()
{
	player_angles = level._player GetPlayerAngles();
	player_forward = AnglesToForward( player_angles );
	end = level._player GetEye();

	start = self GetEye();
	angles = VectorToAngles( start - end );
	forward = AnglesToForward( angles );

	dot = VectorDot( forward, player_forward );
	Print3d( start, dot, ( 1, 0.5, 0 ) );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// This allows guys to be spawned in whereever. Need an enemy spawner in the map,
// or a specially designated spawner.
dynamic_ai_spawner()
{
	if( !isdefined( level.debug_dynamic_ai_spawner ) )
	{
		if( self dynamic_ai_spawner_init() )
		{
			level.debug_dynamic_ai_spawner = true;
		}
	}

	if( isdefined( level.debug_dynamic_ai_spawner ) )
	{
		GetEntArray( "player", "classname" )[0] thread spawn_guy_placement( level.debug_spawner );

		// Cleanup hudelems, dummy models, etc.
		level waittill( "kill dynamic spawning" );
		
		if( isdefined( level.dynamic_spawn_hud ) )
		{
			level.dynamic_spawn_hud destroy();
		}
		
		if( isdefined( level.dynamic_spawn_dummy_model ) )
		{
			level.dynamic_spawn_dummy_model delete();
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

dynamic_ai_spawner_init()
{
	level.debug_spawner = dynamic_ai_spawner_create_enemy_spawner();

	if( !isdefined( level.debug_spawner ) )
	{
		return false;
	}
	return true;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// tagMJS<NOTE> currently this does not create a spawner, it grabs a specific debug spawner put in the level or some other enemy spawner
dynamic_ai_spawner_create_enemy_spawner()
{
	// tagMJS<TODO> this func should just create a spawner right off that bat.
	spawners = getspawnerarray();

	// check if we have a debug spawner in the level.
	for( index = 0; index < spawners.size; index++ )
	{
		if( isdefined( spawners[index].targetname ) && issubstr( spawners[index].targetname, "debug_spawner" ) )
		{
			enemy_spawner = spawners[index];
			enemy_spawner.script_forcespawn = 1;					// we want to make sure he will spawn in
			return enemy_spawner;
		}
	}

	// if we made it through, find any enemy spawner and use him
	// tagMJS<GOTCHA> i'm not too sure this will find any enemy spawner...
	for( index = 0; index < spawners.size; index++ )
	{
		if( issubstr( spawners[index].classname, "_e_" ) )
		{
			enemy_spawner = spawners[index];
			enemy_spawner.script_forcespawn = 1;					// we want to make sure he will spawn in
			return enemy_spawner;
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_guy_placement( spawner )
{
	println ( "--- spawn_guy_placement ---" );

	level endon( "kill dynamic spawning" );

	if( !isdefined( spawner ) )
	{
		assertEX( isDefined( spawner ) , "No spawners in the level!");
		return;
	}

	// lets add our elements to help show the player what to do
	dynamic_ai_spawner_add_hud_element();
	dynamic_ai_spawner_add_dummy_model();


	// lets keep on doing this till the endon call becomes satisfied
	while( true )
	{
		// Trace to where the player is looking
		direction = self getPlayerAngles();
		direction_vec = anglesToForward( direction );
		eye = self getEye();

		// offset 2 units on the Z to fix the bug where it would drop through the ground sometimes
		trace = bullettrace( eye, eye + ( direction_vec * 8000 ), 0, undefined );

		dist = distance( eye, trace["position"] );
		position = eye + ( direction_vec * ( dist - 64 ) );

		// debug
		//thread draw_line_for_time( eye - (1,1,1), position, 1, 0, 0, 0.05 );

		spawner.origin = position;
		spawner.angles = self.angles+ (0,180,0);

		level.dynamic_spawn_dummy_model.origin = position;
		level.dynamic_spawn_dummy_model.angles = self.angles+ (0,180,0);

		self spawn_anywhere( spawner );

		wait (0.05);
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

dynamic_ai_spawner_add_hud_element()
{
	level.dynamic_spawn_hud = NewClientHudElem( GetEntArray( "player", "classname" )[0] );
	level.dynamic_spawn_hud.alignX = "right";
	level.dynamic_spawn_hud.x = 110;
	level.dynamic_spawn_hud.y = 180;
	level.dynamic_spawn_hud.fontscale = 2;
	level.dynamic_spawn_hud settext("Press X to spawn AI");
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

dynamic_ai_spawner_add_dummy_model()
{
	level.dynamic_spawn_dummy_model = spawn( "script_model", ( 0,0,0 ) );
	level.dynamic_spawn_dummy_model setmodel( "defaultactor" );

	wait 0.1;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_anywhere( spawner )
{
	level endon ("kill dynamic spawning");

	if( self UseButtonPressed() )
	{
		spawn = spawner spawn_ai();

		if ( spawn_failed( spawn ) )
		{
			assertex( 0, "spawn failed from spawn anywhere guy" );
			return;
		}
		wait 0.4;
	}
	spawner.count = 50;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
