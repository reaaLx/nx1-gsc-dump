//****************************************************************************
 //                                                                          **
 //           Confidential - (C) Activision Publishing, Inc. 2011            **
 //                                                                          **
 //****************************************************************************
 //                                                                          **
 //    Module:  _doorbreach.gsc												**
 //                                                                          **
 //    Created: 5/24/2011 - Eric Milota                                      **
 //                                                                          **
 //****************************************************************************
 
 #include maps\mp\_utility;
 #include common_scripts\utility;
 #include maps\mp\gametypes\_hud_util;
 
 //****************************************************************************
 // How to add door breaching tech to your levels.
 //
 // (1) Drop down one or more \\DEPOT\TREES\NX1\GAME\MAP_SOURCE\PREFABS\MP\DOORBREACH_DOOR1.MAP
 //     throughout your level in doorways.
 // (2) Drop one and only one "\\DEPOT\TREES\NX1\GAME\MAP_SOURCE\PREFABS\MP\DOORBREACH_GRAVEYARD.MAP" 
 //     somewhere outside the working area of your map.
 // (3) Add "rawfile,maps/mp/_doorbreach.gsc" to your level CSV file.
 // (4) Add the following to your level main() function:
 //	   (a) If you want to start the level with doors installed, add
 //                    maps\mp\_doorbreach::doorbreach_setup( 1, 1 );	// 0=start with no doors/walls, 1=start with doors/walls, -1=default (no doors, yes walls)
 //	   (b) If you want to start the level with doors absent, add
 //                    maps\mp\_doorbreach::doorbreach_setup( 0, 1 );	// 0=start with no doors/walls, 1=start with doors/walls, -1=default (no doors, yes walls)
 //     NOTE:  Use can use -1 for "default", which currently is NO DOORS.
 //
 // Compile your map and build and run your level.  That should be it!
 //
 // --------------------------------------------------------------------
 // Known bugs/issues:
 //         
 // * Timings are currently hard coded.  See doorbreach_setup() for info.
 // * If doorbreach_setup() is passes a 0, currently doors/walls are
 //   not placed, but you can't immediately install....there's a bug
 //   that is currently preventing me from starting them in 
 //   the "no_door_ready" state, so instead I'm using "no_door_wait" state,
 //   which appears to work.
 //         
 // --------------------------------------------------------------------
 // What's in those prefabs?
 //         
 // Door prefabs:
 //
 //		* Script origin with "targetname" equal to "doorbreachorigin".
 //		  This object should be at the center of your doorway.
 //		* Script brush with "targetname" equal to "doorbreachmodel".
 //		  This object should be your door model.
 //		* Script model with "targetname" equal to "doorbreachnogo".
 //		  This object should be the brush that will block you from going 
 //        through the doorway.
 //		* Script origin with "targetname" equal to "doorbreachtriggerfront".
 //		  This object will be the centerpoint of where you need to stand to
 //        trigger the front bomb placement.
 //		* Script model with "targetname" equal to "doorbreachbombfront".
 //		  This object should be your front bomb model.
 //		* Script origin with "targetname" equal to "doorbreachtriggerback".
 //		  This object will be the centerpoint of where you need to stand to
 //        trigger the back bomb placement.
 //		* Script model with "targetname" equal to "doorbreachbombback".
 //		  This object should be your back bomb model.
 //
 // Graveyard prefabs:
 //
 //		* Script origin with "targetname" equal to "doorbreachnogograveyard"
 //        If a script origin with this name exists on the map, this is where
 ///       NOGO objects are moved when the door has been breached.
 //         
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_setup( start_with_doors, start_with_walls )	// 0=start with no doors/walls, 1=start with doors/walls, -1=default (no doors, yes walls)
 {
 	originarray = GetEntArray( "doorbreachorigin", "targetname" );
 	if( !IsDefined( originarray[0] ) )
 	{
 		return;	// no door breach origin objects, therefore there is nothing to do
 	}
 
 	if( !IsDefined( start_with_doors ) )
 	{
 		start_with_doors = -1;	// set to "default"
 	}
 
 	if( !IsDefined( start_with_walls ) )
 	{
 		start_with_walls = -1;	// set to "default"
 	}
 
 	// setup constants...
 	level._doorbreach_time_door_plant_bomb				= 2.0 * 1000;	// 2 seconds
 	level._doorbreach_time_door_build					= 2.0 * 1000;	// 2 seconds
 	level._doorbreach_time_door_rebuild					= 2.0 * 1000;	// 2 seconds
 	level._doorbreach_time_wall_plant_bomb				= 6.0 * 1000;	// 6 seconds
 	level._doorbreach_time_wall_build					= 10.0 * 1000;	// 10 seconds
 	level._doorbreach_time_wall_rebuild					= 12.0 * 1000;	// 12 seconds
 	level._doorbreach_wait_time_before_breachable		= 0.0;			// must wait this long after building door/wall before it becomes breachable
 	level._doorbreach_wait_time_bomb_fuse				= 5.0;			// bombs take this long before they blow up
 	level._doorbreach_wait_time_before_can_rebuild		= 0.0;			// door/wall must have been exploded for this long before you can rebuild it again
 	level._doorbreach_move_delta_x						= 0.0;
 	level._doorbreach_move_delta_y						= 0.0;
 	level._doorbreach_move_delta_z						= -3000.0;
 	level._doorbreach_blocked_door_distance				= 30.0;
 	level._doorbreach_blocked_wall_distance				= 80.0;
 	level._doorbreach_explosion_flashbang_distance		= 250.0;
 	level._doorbreach_explosion_shake_radius			= 2000.0;
 	level._doorbreach_collecting_objects_max_distance	= 200.0;		// 200.0/12.0 --> 16.6 feet.  All items pertaining to this door must be within this radius!
 
 	level._doorbreach_soundfx_explosion					= "prototype_door_explode";	//sentry_explode";	//mortar_explosion1";	//"sentry_explode"
 	level._doorbreach_soundfx_bomb_placed				= "prototype_door_activate";
 	level._doorbreach_soundfx_bomb_beep					= "prototype_door_beep";	//elevator_pass_floor_beep";	//"sentry_gun_beep"
 	level._doorbreach_soundfx_door_blocked				= "prototype_door_blocked";
 	level._doorbreach_soundfx_door_created				= "prototype_door_create";
 	level._doorbreach_soundfx_wall_blocked				= "prototype_door_blocked";
 	level._doorbreach_soundfx_wall_created				= "prototype_door_create";
 
 	level._doorbreach_text_planting_bomb					= &"MP_DOORBREACH_PLANTING_BOMB";	// "Planting bomb.  Stand by...";
 	level._doorbreach_text_countdown_5						= &"MP_DOORBREACH_COUNTDOWN_5";		// "5 seconds...";
 	level._doorbreach_text_countdown_4						= &"MP_DOORBREACH_COUNTDOWN_4";		// "4 seconds...";
 	level._doorbreach_text_countdown_3						= &"MP_DOORBREACH_COUNTDOWN_3";		// "3 seconds...";
 	level._doorbreach_text_countdown_2						= &"MP_DOORBREACH_COUNTDOWN_2";		// "2 seconds...";
 	level._doorbreach_text_countdown_1						= &"MP_DOORBREACH_COUNTDOWN_1";		// "1 seconds...";
 
 	level._doorbreach_text_door_press_and_hold_to_breach	= &"MP_DOORBREACH_DOOR_BREACH";		// "Press and hold^3 &&1 ^7to breach door";
 	level._doorbreach_text_door_press_and_hold_to_install	= &"MP_DOORBREACH_DOOR_INSTALL";	// "Press and hold^3 &&1 ^7to install door";
 	level._doorbreach_text_door_press_and_hold_to_rebuild	= &"MP_DOORBREACH_DOOR_REBUILD";	// "Press and hold^3 &&1 ^7to repair door";
 	level._doorbreach_text_door_blocked						= &"MP_DOORBREACH_DOOR_BLOCKED";	// "Clear the doorway first!";
 	level._doorbreach_text_door_installing					= &"MP_DOORBREACH_DOOR_INSTALLING";	// "Installing door.  Stand by...";
 	level._doorbreach_text_door_repairing					= &"MP_DOORBREACH_DOOR_REPAIRING";	// "Repairing door.  Stand by...";
 	level._doorbreach_text_door_installed					= &"MP_DOORBREACH_DOOR_INSTALLED";	// "Door installed";
 	level._doorbreach_text_door_repaired					= &"MP_DOORBREACH_DOOR_REPAIRED";	// "Door repaired";
 	level._doorbreach_text_door_breached					= &"MP_DOORBREACH_DOOR_BREACHED";	// "Door breached!";
 
 	level._doorbreach_text_wall_press_and_hold_to_breach	= &"MP_DOORBREACH_WALL_BREACH";		// "Press and hold^3 &&1 ^7to breach wall";
 	level._doorbreach_text_wall_press_and_hold_to_install	= &"MP_DOORBREACH_WALL_INSTALL";	// "Press and hold^3 &&1 ^7to install wall";
 	level._doorbreach_text_wall_press_and_hold_to_rebuild	= &"MP_DOORBREACH_WALL_REBUILD";	// "Press and hold^3 &&1 ^7to repair wall";
 	level._doorbreach_text_wall_blocked						= &"MP_DOORBREACH_WALL_BLOCKED";	// "Clear the pathway first!";
 	level._doorbreach_text_wall_installing					= &"MP_DOORBREACH_WALL_INSTALLING";	// "Installing wall.  Stand by...";
 	level._doorbreach_text_wall_repairing					= &"MP_DOORBREACH_WALL_REPAIRING";	// "Repairing wall.  Stand by...";
 	level._doorbreach_text_wall_installed					= &"MP_DOORBREACH_WALL_INSTALLED";	// "Wall installed";
 	level._doorbreach_text_wall_repaired					= &"MP_DOORBREACH_WALL_REPAIRED";	// "Wall repaired";
 	level._doorbreach_text_wall_breached					= &"MP_DOORBREACH_WALL_BREACHED";	// "Wall breached!";
 
 	level._effect["doorbreach_explosion"]				= loadfx( "explosions/tanker_explosion" );
 
 	level._doorbreach_origins							= [];	// let's default to empty list
 	
 	
 	precacheString( level._doorbreach_text_planting_bomb );	//					= &"MP_DOORBREACH_PLANTING_BOMB";	// "Planting bomb.  Stand by...";
 	precacheString( level._doorbreach_text_countdown_5 );	//						= &"MP_DOORBREACH_COUNTDOWN_5";		// "5 seconds...";
 	precacheString( level._doorbreach_text_countdown_4 );	//						= &"MP_DOORBREACH_COUNTDOWN_4";		// "4 seconds...";
 	precacheString( level._doorbreach_text_countdown_3 );	//						= &"MP_DOORBREACH_COUNTDOWN_3";		// "3 seconds...";
 	precacheString( level._doorbreach_text_countdown_2 );	//						= &"MP_DOORBREACH_COUNTDOWN_2";		// "2 seconds...";
 	precacheString( level._doorbreach_text_countdown_1 );	//						= &"MP_DOORBREACH_COUNTDOWN_1";		// "1 seconds...";
 
 	precacheString( level._doorbreach_text_door_press_and_hold_to_breach );		//	= &"MP_DOORBREACH_DOOR_BREACH";		// "Press and hold^3 &&1 ^7to breach door";
 	precacheString( level._doorbreach_text_door_press_and_hold_to_install );	//	= &"MP_DOORBREACH_DOOR_INSTALL";	// "Press and hold^3 &&1 ^7to install door";
 	precacheString( level._doorbreach_text_door_press_and_hold_to_rebuild );	//	= &"MP_DOORBREACH_DOOR_REBUILD";	// "Press and hold^3 &&1 ^7to repair door";
 	precacheString( level._doorbreach_text_door_blocked );	//						= &"MP_DOORBREACH_DOOR_BLOCKED";	// "Clear the doorway first!";
 	precacheString( level._doorbreach_text_door_installing );	//					= &"MP_DOORBREACH_DOOR_INSTALLING";	// "Installing door.  Stand by...";
 	precacheString( level._doorbreach_text_door_repairing );	//					= &"MP_DOORBREACH_DOOR_REPAIRING";	// "Repairing door.  Stand by...";
 	precacheString( level._doorbreach_text_door_installed );	//					= &"MP_DOORBREACH_DOOR_INSTALLED";	// "Door installed";
 	precacheString( level._doorbreach_text_door_repaired );	//					= &"MP_DOORBREACH_DOOR_REPAIRED";	// "Door repaired";
 	precacheString( level._doorbreach_text_door_breached );	//					= &"MP_DOORBREACH_DOOR_BREACHED";	// "Door breached!";
 
 	precacheString( level._doorbreach_text_wall_press_and_hold_to_breach );	//	= &"MP_DOORBREACH_WALL_BREACH";		// "Press and hold^3 &&1 ^7to breach wall";
 	precacheString( level._doorbreach_text_wall_press_and_hold_to_install );	//	= &"MP_DOORBREACH_WALL_INSTALL";	// "Press and hold^3 &&1 ^7to install wall";
 	precacheString( level._doorbreach_text_wall_press_and_hold_to_rebuild );	//	= &"MP_DOORBREACH_WALL_REBUILD";	// "Press and hold^3 &&1 ^7to repair wall";
 	precacheString( level._doorbreach_text_wall_blocked );	//						= &"MP_DOORBREACH_WALL_BLOCKED";	// "Clear the pathway first!";
 	precacheString( level._doorbreach_text_wall_installing );	//					= &"MP_DOORBREACH_WALL_INSTALLING";	// "Installing wall.  Stand by...";
 	precacheString( level._doorbreach_text_wall_repairing );	//					= &"MP_DOORBREACH_WALL_REPAIRING";	// "Repairing wall.  Stand by...";
 	precacheString( level._doorbreach_text_wall_installed );	//					= &"MP_DOORBREACH_WALL_INSTALLED";	// "Wall installed";
 	precacheString( level._doorbreach_text_wall_repaired );	//					= &"MP_DOORBREACH_WALL_REPAIRED";	// "Wall repaired";
 	precacheString( level._doorbreach_text_wall_breached );	//					= &"MP_DOORBREACH_WALL_BREACHED";	// "Wall breached!";
 	
 	// we've got some breaching doors!
 
 	level._doorbreach_origins							= originarray;
 	
 	modelarray			= GetEntArray( "doorbreachmodel",		 "targetname" );
 	nogoarray			= GetEntArray( "doorbreachnogo",		 "targetname" );
 	triggerfrontarray	= GetEntArray( "doorbreachtriggerfront", "targetname" );
 	bombfrontarray		= GetEntArray( "doorbreachbombfront",	 "targetname" );
 	triggerbackarray	= GetEntArray( "doorbreachtriggerback",  "targetname" );
 	bombbackarray		= GetEntArray( "doorbreachbombback",	 "targetname" );
 	model2array			= GetEntArray( "doorbreachmodel2",		 "targetname" );
 	model3array			= GetEntArray( "doorbreachmodel3",		 "targetname" );
 
 	level._doorbreach_nogo_graveyard_object = undefined;
 	nogograveyardarray = GetEntArray( "doorbreachnogograveyard", "targetname" );
 	if( IsDefined( nogograveyardarray[0] ) )
 	{
 		level._doorbreach_nogo_graveyard_object = nogograveyardarray[0];
 	}
 
 	for( i = 0; i < level._doorbreach_origins.size; i++ )
 	{
 		originobject = level._doorbreach_origins[ i ];
 		
 		// find models
 		modelobject = doorbreach_find_best_object( modelarray, originobject );
 		if( IsDefined( modelobject ) )
 		{
 			modelarray = doorbreach_remove_object_from_list( modelarray, modelobject );
 		}
 		nogoobject = doorbreach_find_best_object( nogoarray, originobject );
 		if( IsDefined( nogoobject ) )
 		{
 			nogoarray = doorbreach_remove_object_from_list( nogoarray, nogoobject );
 		}
 		triggerfrontobject = doorbreach_find_best_object( triggerfrontarray, originobject );
 		if( IsDefined( triggerfrontobject ) )
 		{
 			triggerfrontarray = doorbreach_remove_object_from_list( triggerfrontarray, triggerfrontobject );
 		}
 		bombfrontobject = doorbreach_find_best_object( bombfrontarray, originobject );
 		if( IsDefined( bombfrontobject ) )
 		{
 			bombfrontarray = doorbreach_remove_object_from_list( bombfrontarray, bombfrontobject );
 		}
 		triggerbackobject = doorbreach_find_best_object( triggerbackarray, originobject );
 		if( IsDefined( triggerbackobject ) )
 		{
 			triggerbackarray = doorbreach_remove_object_from_list( triggerbackarray, triggerbackobject );
 		}	
 		bombbackobject = doorbreach_find_best_object( bombbackarray, originobject );
 		if( IsDefined( bombbackobject ) )
 		{
 			bombbackarray = doorbreach_remove_object_from_list( bombbackarray, bombbackobject );
 		}	
 		model2object = doorbreach_find_best_object( model2array, originobject );
 		if( IsDefined( model2object ) )
 		{
 			model2array = doorbreach_remove_object_from_list( model2array, model2object );
 		}
 		model3object = doorbreach_find_best_object( model3array, originobject );
 		if( IsDefined( model3object ) )
 		{
 			model3array = doorbreach_remove_object_from_list( model3array, model3object );
 		}
 		
 		doortype = "door";
 		if( IsDefined( model2object ) || IsDefined( model3object ) )
 		{
 			doortype = "wall";
 		}
 		
 		// start this guy
 		originobject thread doorbreach_DoorMainThread( doortype, start_with_doors, start_with_walls, modelobject, nogoobject, triggerfrontobject, bombfrontobject, triggerbackobject, bombbackobject, model2object, model3object );
 	}
 	
 	// start!
 	level thread onPlayerConnect();
 	//thread doorbreach_DebugPump();
 }
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_find_best_object( list, node )
 {
 	if( !IsDefined( node ) )
 	{
 		return undefined;
 	}
 	if( !IsDefined( list[0] ) )
 	{
 		return undefined;
 	}
 	
 	best_dist = -1;
 	best_item = undefined;
 	
 	for( x = 0; x < list.size; x++ )
 	{
 		item = list[ x ];	
 		if( IsDefined( item ) )
 		{
 			dist = distance( node.origin, item.origin );
 			if( dist < level._doorbreach_collecting_objects_max_distance )
 			{
 				if( !IsDefined( best_item ) )
 				{
 					best_item = item;
 					best_dist = dist;
 				}
 				else if ( dist < best_dist )
 				{
 					best_item = item;
 					best_dist = dist;
 				}
 			}
 		}
 	}
 	
 	return best_item;
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_remove_object_from_list( list, node )
 {
 	if( !IsDefined( node ) )
 	{
 		return list;
 	}
 	if( !IsDefined( list[0] ) )
 	{
 		return list;
 	}
 	
 	best_dist = -1;
 	best_item = undefined;
 	
 	newlist = [];
 	found = false;
 	
 	for( x = 0; x < list.size; x++ )
 	{
 		item = list[ x ];	
 		if( IsDefined( item ) )
 		{
 			if( item == node )
 			{
 				// found match!
 				found = true;
 			}
 			else
 			{
 				newlist[ newlist.size ] = item;
 			}		
 		}
 	}
 	
 	if( !found )
 	{
 		return list;	// item not in list
 	}
 	
 	return newlist;
 }
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 onPlayerConnect()
 {
 	for(;;)
 	{
 		level waittill( "connected", player );
 		player thread onPlayerSpawned();
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 onPlayerSpawned()
 {
 	self endon( "disconnect" );
 
 	for(;;)
 	{
 		self waittill( "spawned_player" );
 		doorbreach_setup_player( self );		
 	}
 }
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_setup_player( player )
 {
 	for( i = 0; i < level._doorbreach_origins.size; i++ )
 	{
 		originobject = level._doorbreach_origins[ i ];
 
 		if( IsDefined( originobject._doorbreach_action ) )
 		{
 			if( originobject._doorbreach_action == "ActionBreach" )
 			{
 				if( IsDefined( originobject._doorbreach_triggerfrontobject ) )
 				{
 					triggerobject = originobject._doorbreach_triggerfrontobject;					
 					triggerobject enablePlayerUse( player );
 				}
 				if( IsDefined( originobject._doorbreach_triggerbackobject ) )
 				{
 					triggerobject = originobject._doorbreach_triggerbackobject;					
 					triggerobject enablePlayerUse( player );
 				}
 				//originobject disablePlayerUse( player );
 			}
 			else if ( originobject._doorbreach_action == "ActionRebuild" )
 			{
 				//originobject enablePlayerUse( player );
 				if( IsDefined( originobject._doorbreach_triggerfrontobject ) )
 				{
 					triggerobject = originobject._doorbreach_triggerfrontobject;					
 					triggerobject enablePlayerUse( player );
 				}
 				if( IsDefined( originobject._doorbreach_triggerbackobject ) )
 				{
 					triggerobject = originobject._doorbreach_triggerbackobject;					
 					triggerobject enablePlayerUse( player );
 				}
 				//originobject disablePlayerUse( player );
 			}
 			else
 			{
 				if( IsDefined( originobject._doorbreach_triggerfrontobject ) )
 				{
 					triggerobject = originobject._doorbreach_triggerfrontobject;					
 					triggerobject disablePlayerUse( player );
 				}
 				if( IsDefined( originobject._doorbreach_triggerbackobject ) )
 				{
 					triggerobject = originobject._doorbreach_triggerbackobject;					
 					triggerobject disablePlayerUse( player );
 				}
 				//originobject disablePlayerUse( player );
 			}
 		}
 	}
 }
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_draw_circle( radius )
 {
 	x = self.origin[0];
 	y = self.origin[1];
 	z = self.origin[2];
 	
 	radius2 = radius * 0.707;
 	Print3d( ( x + radius, y, z ),		      "'",  (1,0,0), 1, 1, 10 );	// 0
 	Print3d( ( x + radius2, y + radius2, z ), "'",  (1,0,0), 1, 1, 10 );	// 45
 	Print3d( ( x, y + radius, z ),			  "'",  (1,0,0), 1, 1, 10 );	// 90
 	Print3d( ( x - radius2, y + radius2, z ), "'",  (1,0,0), 1, 1, 10 );	// 135
 	Print3d( ( x - radius, y, z ),		      "'",  (1,0,0), 1, 1, 10 );	// 180
 	Print3d( ( x - radius2, y - radius2, z ), "'",  (1,0,0), 1, 1, 10 );	// 225
 	Print3d( ( x, y - radius, z ),			  "'",  (1,0,0), 1, 1, 10 );	// 270
 	Print3d( ( x + radius2, y - radius2, z ), "'",  (1,0,0), 1, 1, 10 );	// 315
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_draw_circles( radius )
 {
 	for( i = 0; i < level._doorbreach_origins.size; i++ )
 	{
 		originobject = level._doorbreach_origins[ i ];
 		
 		originobject doorbreach_draw_circle( radius );	
 		//if( IsDefined( originobject._doorbreach_triggerfrontobject ) )
 		//{
 		//	originobject._doorbreach_triggerfrontobject doorbreach_draw_circle( radius * 4.0 );	
 		//}
 		//if( IsDefined( originobject._doorbreach_triggerbackobject ) )
 		//{
 		//	originobject._doorbreach_triggerbackobject doorbreach_draw_circle( radius * 4.0 );					
 		//}
 	}
 }
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_gameHasStarted()
 {
 	if ( level._teamBased )
 		return( level._hasSpawned[ "axis" ] || level._hasSpawned[ "allies" ] );
 	else
 		return( level._maxPlayerCount > 0 );
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_gameHasEnded()
 {
 	return level._gameEnded;
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_DebugPump()
 {
 	showing = false;
 	timestarted = GetTime();
 	
 	while( 1 )
 	{
 		timenow = GetTime();
 		if( ( doorbreach_gameHasStarted() ) && ( !doorbreach_gameHasEnded() ) )
 		{
 			if( showing )
 			{
 				doorbreach_draw_circles( 25.0 );
 				if( timenow > ( timestarted + ( 1.0 * 1000 ) ) )
 				{
 					showing = false;
 					timestarted = timenow;			
 				}
 			}
 			else
 			{
 				if( timenow > ( timestarted + ( 0.5 * 1000 ) ) )
 				{
 					showing = true;
 					timestarted = timenow;				
 				}
 			}
 		}
 	
 		wait 0.25;
 	}
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_TriggerEnableForAllPlayers()
 {
 	playerlist = GetEntArray( "player", "classname" );	
 	if( IsDefined( playerlist[0] ) )
 	{
 		foreach ( player in playerlist )
 		{
 			self enablePlayerUse( player );
 		}
 	}
 }
 
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_TriggerDisableForAllPlayers()
 {
 	playerlist = GetEntArray( "player", "classname" );	
 	if( IsDefined( playerlist[0] ) )
 	{
 		foreach ( player in playerlist )
 		{
 			self disablePlayerUse( player );
 		}
 	}
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_ActionDisable()
 {
 	if( IsDefined( self._doorbreach_triggerfrontobject ) )
 	{
 		triggerobject = self._doorbreach_triggerfrontobject;
 		triggerobject makeUnusable();
 		triggerobject doorbreach_TriggerDisableForAllPlayers();
 		triggerobject notify( "doorbreachremovetrigger" );
 	}
 	if( IsDefined( self._doorbreach_triggerbackobject ) )
 	{
 		triggerobject = self._doorbreach_triggerbackobject;
 		triggerobject makeUnusable();
 		triggerobject doorbreach_TriggerDisableForAllPlayers();	
 		triggerobject notify( "doorbreachremovetrigger" );
 	}	
 
 	self._doorbreach_action = "";
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_ActionBreach()
 {
 	if( IsDefined( self._doorbreach_triggerfrontobject ) )
 	{
 		triggerobject = self._doorbreach_triggerfrontobject;
 		
 		triggerobject SetCursorHint( "HINT_ACTIVATE" );
 		if( self._doorbreach_doortype == "wall" )
 		{
 			triggerobject setHintString( level._doorbreach_text_wall_press_and_hold_to_breach );
 		}
 		else
 		{
 			triggerobject setHintString( level._doorbreach_text_door_press_and_hold_to_breach );
 		}
 		triggerobject makeUsable();
 		triggerobject doorbreach_TriggerEnableForAllPlayers();
 		if( self._doorbreach_doortype == "wall" )
 		{
 			triggerobject thread doorbreach_TriggerThread( self, "doorbreachtriggerfront", level._doorbreach_time_wall_plant_bomb, level._doorbreach_text_planting_bomb, undefined );
 		}
 		else
 		{
 			triggerobject thread doorbreach_TriggerThread( self, "doorbreachtriggerfront", level._doorbreach_time_door_plant_bomb, level._doorbreach_text_planting_bomb, undefined );
 		}
 	}
 
 	if( IsDefined( self._doorbreach_triggerbackobject ) )
 	{
 		triggerobject = self._doorbreach_triggerbackobject;
 		
 		triggerobject SetCursorHint( "HINT_ACTIVATE" );
 		if( self._doorbreach_doortype == "wall" )
 		{
 			triggerobject setHintString( level._doorbreach_text_wall_press_and_hold_to_breach );
 		}
 		else
 		{
 			triggerobject setHintString( level._doorbreach_text_door_press_and_hold_to_breach );
 		}
 		triggerobject makeUsable();
 		triggerobject doorbreach_TriggerEnableForAllPlayers();	
 		if( self._doorbreach_doortype == "wall" )
 		{
 			triggerobject thread doorbreach_TriggerThread( self, "doorbreachtriggerback", level._doorbreach_time_wall_plant_bomb, level._doorbreach_text_planting_bomb, undefined );
 		}
 		else
 		{
 			triggerobject thread doorbreach_TriggerThread( self, "doorbreachtriggerback", level._doorbreach_time_door_plant_bomb, level._doorbreach_text_planting_bomb, undefined );
 		}
 	}
 
 	self._doorbreach_action = "ActionBreach";
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_ActionRebuild( )
 {
 	if( IsDefined( self._doorbreach_triggerfrontobject ) )
 	{
 		triggerobject = self._doorbreach_triggerfrontobject;
 		
 		triggerobject SetCursorHint( "HINT_ACTIVATE" );
 		if( self._doorbreach_doortype == "wall" )
 		{
 			if( self._doorbreach_count == 0 )
 			{
 				triggerobject setHintString( level._doorbreach_text_wall_press_and_hold_to_install );
 			}
 			else
 			{
 				triggerobject setHintString( level._doorbreach_text_wall_press_and_hold_to_rebuild );
 			}
 		}
 		else
 		{
 			if( self._doorbreach_count == 0 )
 			{
 				triggerobject setHintString( level._doorbreach_text_door_press_and_hold_to_install );
 			}
 			else
 			{
 				triggerobject setHintString( level._doorbreach_text_door_press_and_hold_to_rebuild );
 			}
 		}
 		triggerobject makeUsable();
 		triggerobject doorbreach_TriggerEnableForAllPlayers();
 		if( self._doorbreach_doortype == "wall" )
 		{
 			if( self._doorbreach_count == 0 )
 			{
 				triggerobject thread doorbreach_TriggerThread( self, "doorbreachinstall", level._doorbreach_time_wall_build, level._doorbreach_text_wall_installing, self  );
 			}
 			else
 			{
 				triggerobject thread doorbreach_TriggerThread( self, "doorbreachinstall", level._doorbreach_time_wall_rebuild, level._doorbreach_text_wall_repairing, self );
 			}
 		}
 		else
 		{
 			if( self._doorbreach_count == 0 )
 			{
 				triggerobject thread doorbreach_TriggerThread( self, "doorbreachinstall", level._doorbreach_time_door_build, level._doorbreach_text_door_installing, self  );
 			}
 			else
 			{
 				triggerobject thread doorbreach_TriggerThread( self, "doorbreachinstall", level._doorbreach_time_door_rebuild, level._doorbreach_text_door_repairing, self );
 			}
 		}
 	}
 
 	if( IsDefined( self._doorbreach_triggerbackobject ) )
 	{
 		triggerobject = self._doorbreach_triggerbackobject;
 		
 		triggerobject SetCursorHint( "HINT_ACTIVATE" );
 		if( self._doorbreach_doortype == "wall" )
 		{
 			if( self._doorbreach_count == 0 )
 			{
 				triggerobject setHintString( level._doorbreach_text_wall_press_and_hold_to_install );
 			}
 			else
 			{
 				triggerobject setHintString( level._doorbreach_text_wall_press_and_hold_to_rebuild );
 			}
 		}
 		else
 		{
 			if( self._doorbreach_count == 0 )
 			{
 				triggerobject setHintString( level._doorbreach_text_door_press_and_hold_to_install );
 			}
 			else
 			{
 				triggerobject setHintString( level._doorbreach_text_door_press_and_hold_to_rebuild );
 			}
 		}
 		triggerobject makeUsable();
 		triggerobject doorbreach_TriggerEnableForAllPlayers();	
 		if( self._doorbreach_doortype == "wall" )
 		{
 			if( self._doorbreach_count == 0 )
 			{
 				triggerobject thread doorbreach_TriggerThread( self, "doorbreachinstall", level._doorbreach_time_door_build, level._doorbreach_text_wall_installing, self );		
 			}
 			else
 			{
 				triggerobject thread doorbreach_TriggerThread( self, "doorbreachinstall", level._doorbreach_time_door_rebuild, level._doorbreach_text_wall_repairing, self );		
 			}
 		}
 		else
 		{
 			if( self._doorbreach_count == 0 )
 			{
 				triggerobject thread doorbreach_TriggerThread( self, "doorbreachinstall", level._doorbreach_time_door_build, level._doorbreach_text_door_installing, self );		
 			}
 			else
 			{
 				triggerobject thread doorbreach_TriggerThread( self, "doorbreachinstall", level._doorbreach_time_door_rebuild, level._doorbreach_text_door_repairing, self );		
 			}
 		}
 	}
 	
 	self._doorbreach_action = "ActionRebuild";
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_DisplayDoor()
 {
 	if( IsDefined( self._doorbreach_modelobject ) )
 	{
 		self._doorbreach_modelobject doorbreach_Move( 1 );	
 		self._doorbreach_modelobject show();
 	}
 	if( IsDefined( self._doorbreach_nogoobject ) )
 	{
 		self._doorbreach_nogoobject doorbreach_Move( 1 );
 		self._doorbreach_nogoobject show();
 	}
 	if( IsDefined( self._doorbreach_bombfrontobject ) )
 	{
 		self._doorbreach_bombfrontobject doorbreach_Move( 0 );
 		self._doorbreach_bombfrontobject show();
 	}
 	if( IsDefined( self._doorbreach_bombbackobject ) )
 	{
 		self._doorbreach_bombbackobject doorbreach_Move( 0 );
 		self._doorbreach_bombbackobject show();
 	}
 	if( IsDefined( self._doorbreach_model2object ) )
 	{
 		self._doorbreach_model2object doorbreach_Move( 0 );	
 		self._doorbreach_model2object show();
 	}
 	if( IsDefined( self._doorbreach_model3object ) )
 	{
 		self._doorbreach_model3object doorbreach_Move( 0 );	
 		self._doorbreach_model3object show();
 	}
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_DisplayBombFront()
 {
 	if( IsDefined( self._doorbreach_modelobject ) )
 	{
 		self._doorbreach_modelobject doorbreach_Move( 1 );	
 		self._doorbreach_modelobject show();
 	}
 	if( IsDefined( self._doorbreach_nogoobject ) )
 	{
 		self._doorbreach_nogoobject doorbreach_Move( 1 );	
 		self._doorbreach_nogoobject show();
 	}
 	if( IsDefined( self._doorbreach_bombfrontobject ) )
 	{
 		self._doorbreach_bombfrontobject doorbreach_Move( 1 );	
 		self._doorbreach_bombfrontobject show();
 	}
 	if( IsDefined( self._doorbreach_bombbackobject ) )
 	{
 		self._doorbreach_bombbackobject doorbreach_Move( 0 );	
 		self._doorbreach_bombbackobject show();
 	}		
 	if( IsDefined( self._doorbreach_model2object ) )
 	{
 		self._doorbreach_model2object doorbreach_Move( 0 );	
 		self._doorbreach_model2object show();
 	}
 	if( IsDefined( self._doorbreach_model3object ) )
 	{
 		self._doorbreach_model3object doorbreach_Move( 0 );	
 		self._doorbreach_model3object show();
 	}
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_DisplayBombBack()
 {
 	if( IsDefined( self._doorbreach_modelobject ) )
 	{
 		self._doorbreach_modelobject doorbreach_Move( 1 );	
 		self._doorbreach_modelobject show();
 	}
 	if( IsDefined( self._doorbreach_nogoobject ) )
 	{
 		self._doorbreach_nogoobject doorbreach_Move( 1 );	
 		self._doorbreach_nogoobject show();
 	}
 	if( IsDefined( self._doorbreach_bombfrontobject ) )
 	{
 		self._doorbreach_bombfrontobject doorbreach_Move( 0 );	
 		self._doorbreach_bombfrontobject show();
 	}
 	if( IsDefined( self._doorbreach_bombbackobject ) )
 	{
 		self._doorbreach_bombbackobject doorbreach_Move( 1 );	
 		self._doorbreach_bombbackobject show();
 	}		
 	if( IsDefined( self._doorbreach_model2object ) )
 	{
 		self._doorbreach_model2object doorbreach_Move( 0 );	
 		self._doorbreach_model2object show();
 	}
 	if( IsDefined( self._doorbreach_model3object ) )
 	{
 		self._doorbreach_model3object doorbreach_Move( 0 );	
 		self._doorbreach_model3object show();
 	}
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_DisplayNoDoor()
 {
 	if( IsDefined( self._doorbreach_modelobject ) )
 	{
 		self._doorbreach_modelobject doorbreach_Move( 0 );	
 		self._doorbreach_modelobject show();
 	}
 	if( IsDefined( self._doorbreach_nogoobject ) )
 	{
 		self._doorbreach_nogoobject doorbreach_Move( 0 );	
 		self._doorbreach_nogoobject show();
 	}
 	if( IsDefined( self._doorbreach_bombfrontobject ) )
 	{
 		self._doorbreach_bombfrontobject doorbreach_Move( 0 );	
 		self._doorbreach_bombfrontobject show();
 	}
 	if( IsDefined( self._doorbreach_bombbackobject ) )
 	{
 		self._doorbreach_bombbackobject doorbreach_Move( 0 );	
 		self._doorbreach_bombbackobject show();
 	}
 	if( self._doorbreach_count == 0 )
 	{
 		// hide it all
 		if( IsDefined( self._doorbreach_model2object ) )
 		{
 			self._doorbreach_model2object doorbreach_Move( 0 );	
 			self._doorbreach_model2object show();
 		}
 		if( IsDefined( self._doorbreach_model3object ) )
 		{
 			self._doorbreach_model3object doorbreach_Move( 0 );	
 			self._doorbreach_model3object show();
 		}
 	}
 	else
 	{
 		if( IsDefined( self._doorbreach_model2object ) )
 		{
 			self._doorbreach_model2object doorbreach_Move( 1 );	
 			self._doorbreach_model2object show();
 		}
 		if( IsDefined( self._doorbreach_model3object ) )
 		{
 			self._doorbreach_model3object doorbreach_Move( 1 );	
 			self._doorbreach_model3object show();
 		}
 	}
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_Explosion()
 {
 	playerlist = GetEntArray( "player", "classname" );	
 	if( IsDefined( playerlist[0] ) )
 	{
 		foreach ( player in playerlist )
 		{
 			dist = distance( self.origin, player.origin );
 			if ( dist < level._doorbreach_explosion_flashbang_distance )
 			{
 				player thread maps\mp\_flashgrenades::applyFlash( 2.5, 1 );
 				//player maps\mp\_utility::flashBangStart( 5.00 );
 			}		
 		}
 	}
 
 	playfx( level._effect[ "doorbreach_explosion" ], self.origin );
 	self PlaySound( level._doorbreach_soundfx_explosion );
 
 	Earthquake( 0.5, 1, self.origin, level._doorbreach_explosion_shake_radius );
 
 	//iPrintLnBold( "BOOM!! DOOR BREACHED!!!" );
 }
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_GotoState( state )
 {
 	if( self._doorbreach_state == state )
 	{
 		return;	// we're already in this state!
 	}
 
 	// leaving current state
 	switch( self._doorbreach_state )
 	{
 		case "no_door_ready":		// Door doesn't exist, but you can build/rebuild it if you want
 			self doorbreach_ActionDisable();
 			break;
 		case "new_door_wait":		// Door exist and is NOT breachable (yet)
 			break;
 		case "new_door_ready":		// Door exist and is breachable
 			self doorbreach_ActionDisable();
 			break;
 		case "bomb_planted":		// Door exist and bomb has been planted...waiting for it to explode!
 			break;
 		case "no_door_wait":		// Door exploded!
 			break;
 		default:
 			break;
 	}
 
 	// enter this state!	
 	self._doorbreach_state = state;
 	
 	// entering new state
 	switch( self._doorbreach_state )
 	{
 		case "no_door_ready":	// Door doesn't exist, but you can build/rebuild it if you want
 			self doorbreach_DisplayNoDoor();
 			self doorbreach_ActionRebuild();
 			break;
 		case "new_door_wait":	// Door exist and is NOT breachable (yet)
 			self doorbreach_DisplayDoor();
 			break;
 		case "new_door_ready":	// Door exist and is breachable
 			self doorbreach_DisplayDoor();
 			self doorbreach_ActionBreach();
 			break;
 		case "bomb_planted":	// Door exist and bomb has been planted...waiting for it to explode!
 			if( self._doorbreach_bombside == "back" )
 			{
 				self doorbreach_DisplayBombBack();
 			}
 			else
 			{
 				self doorbreach_DisplayBombFront();
 			}
 			break;
 		case "no_door_wait":	// Door exploded!
 			self doorbreach_DisplayNoDoor();
 			break;
 		default:
 			self doorbreach_GotoState( "no_door_ready" );
 			break;
 	}
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_TriggerThread( originnode, notification, usetime, usemessage, doorwayblockingnode )
 {
 	level endon ( "game_ended" );
 	self endon( "doorbreachremovetrigger" );
 	
 	while ( true )
 	{
 		self waittill ( "trigger", player );
 	
 		if( ( originnode._doorbreach_state != "no_door_ready" ) &&
 			( originnode._doorbreach_state != "new_door_ready" ) )
 		{
 			break;
 		}
 
 		blocked = false;
 		if( IsDefined( doorwayblockingnode ) )
 		{
 			blocked = doorwayblockingnode doorbreach_IsDoorwayBlocked( originnode._doorbreach_doortype );
 		}
 		if( blocked )
 		{
 			if( originnode._doorbreach_doortype == "wall" )
 			{
 				player iPrintLnBold( level._doorbreach_text_wall_blocked );
 				player PlaySound( level._doorbreach_soundfx_wall_blocked );					
 			}
 			else
 			{
 				player iPrintLnBold( level._doorbreach_text_door_blocked );
 				player PlaySound( level._doorbreach_soundfx_door_blocked );					
 			}
 		}
 		else
 		{
 			self doorbreach_TriggerManageHold( originnode, notification, player, usetime, usemessage );			
 		}
 
 	}
 	
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_personalUseBar( object, usemessage, originnode )
 {
 	self endon("disconnect");
 	
 	useBar = createPrimaryProgressBar();
 	useBarText = createPrimaryProgressBarText();
 	useBarText setText( usemessage );
 
 	lastRate = -1;
 	lastHostMigrationState = isDefined( level._hostMigrationTimer );
 	while ( isReallyAlive( self ) && object.inUse && !level._gameEnded )
 	{
 		if( ( originnode._doorbreach_state != "no_door_ready" ) &&
 			( originnode._doorbreach_state != "new_door_ready" ) )
 		{
 			break;
 		}
 		if ( lastRate != object.useRate || lastHostMigrationState != isDefined( level._hostMigrationTimer ) )
 		{
 			if( object.curProgress > object.useTime)
 				object.curProgress = object.useTime;
 			
 			progress = object.curProgress / object.useTime;
 			rate = (1000 / object.useTime) * object.useRate;
 			if ( isDefined( level._hostMigrationTimer ) )
 				rate = 0;
 			
 			useBar updateBar( progress, rate );
 
 			if ( !object.useRate )
 			{
 				useBar hideElem();
 				useBarText hideElem();
 			}
 			else
 			{
 				useBar showElem();
 				useBarText showElem();
 			}
 		}	
 		lastRate = object.useRate;
 		lastHostMigrationState = isDefined( level._hostMigrationTimer );
 		wait ( 0.05 );
 	}
 	
 	useBar destroyElem();
 	useBarText destroyElem();
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_TriggerManageHold( originnode, notification, player, usetime, usemessage )
 {
 	level endon ( "game_ended" );
 	self endon( "doorbreachremovetrigger" );
 	self endon( "disabled" );
 
 	if ( !isReallyAlive( player ) )
 	{
 		return;		
 	}
 		
 	if ( !player isOnGround() )
 	{
 		return;
 	}
 
 	player notify ( "use_hold" );
 	
 	player playerLinkTo( self );
 	player PlayerLinkedOffsetEnable();
 //	player clientClaimTrigger( self );
 //	player.claimTrigger = self;
 
 	self.curProgress = 0;
 	self.inUse = true;
 	self.useRate = 1;
 	self.useTime = usetime;
 	
 	player thread doorbreach_personalUseBar( self, usemessage, originnode );
 	
 	holdcompleted = false;
 	while ( true )
 	{
 		if( !isReallyAlive( player ) )
 		{
 			break;
 		}
 		
 //		if( !player isTouching( self ) )
 //		{
 //			break;
 //		}
 		if( !player useButtonPressed() )
 		{
 			break;
 		}
 		
 		if( ( originnode._doorbreach_state != "no_door_ready" ) &&
 			( originnode._doorbreach_state != "new_door_ready" ) )
 		{
 			break;
 		}
 		
 		self.curProgress += (50.0);
 		if ( self.curProgress >= self.useTime )
 		{
 			// done!
 			holdcompleted = true;
 			break;
 		}
 
 		wait 0.05;
 		maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
 	}
 	
 	self.inUse = false;
 //	player clientReleaseTrigger( self );
 //	player.claimTrigger = undefined;	
 	player unlink();
 
 	player notify( "done_using" );
 	
 	self notify ( "finished_use" );
 	
 	if ( !holdcompleted )
 	{
 		return;
 	}
 	
 	// done!
 	originnode._doorbreach_player = player;
 		
 	originnode notify( notification );
 }
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_SetupCoords()
 {
 	self._doorbreach_origin_normal_position = self.origin;
 	if( IsDefined( level._doorbreach_nogo_graveyard_object ) )
 	{
 		self._doorbreach_origin_graveyard_position = level._doorbreach_nogo_graveyard_object.origin;
 	}
 	else
 	{
 		self._doorbreach_origin_graveyard_position = self._doorbreach_origin_normal_position + ( level._doorbreach_move_delta_x, level._doorbreach_move_delta_y, level._doorbreach_move_delta_z );
 	}
 }
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_Move( move_position )
 {
 	if( move_position == 0 )	// 0=graveyard position , 1=normal position
 	{
 		if( !IsDefined( self._doorbreach_origin_graveyard_position ) )
 		{
 			return;
 		}
 		dest_origin = self._doorbreach_origin_graveyard_position;
 	}
 	else
 	{
 		if( !IsDefined( self._doorbreach_origin_normal_position ) )
 		{
 			return;
 		}
 		dest_origin = self._doorbreach_origin_normal_position;
 	}
 	
 	move_distance = distance( self.origin, dest_origin );
 	if ( move_distance > 0.0 )
 	{
 		self moveto( dest_origin, 0.05, 0.0, 0.0 );
 	}
 }
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_IsDoorwayBlocked( doortype )
 {
 	blocked = false;
 	playerlist = GetEntArray( "player", "classname" );	
 	if( IsDefined( playerlist[0] ) )
 	{
 		if( doortype == "wall" )
 		{
 			distvalue = level._doorbreach_blocked_wall_distance;
 		}
 		else
 		{
 			distvalue = level._doorbreach_blocked_door_distance;
 		}
 		
 		foreach ( tempplayer in playerlist )
 		{
 			dist = distance( self.origin, tempplayer.origin );
 			if ( dist < distvalue )
 			{
 				blocked = true;
 			}
 		}
 	}
 	return blocked;
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_CountdownMessage( counter )
 {
 	if( IsDefined( self._doorbreach_player ) )
 	{
 		numsecs = int( counter );
 		if( numsecs == 5 )
 		{
 			self._doorbreach_player iPrintLnBold( level._doorbreach_text_countdown_5 );
 		}
 		else if( numsecs == 4 )
 		{
 			self._doorbreach_player iPrintLnBold( level._doorbreach_text_countdown_4 );
 		}
 		else if( numsecs == 3 )
 		{
 			self._doorbreach_player iPrintLnBold( level._doorbreach_text_countdown_3 );
 		}
 		else if( numsecs == 2 )
 		{
 			self._doorbreach_player iPrintLnBold( level._doorbreach_text_countdown_2 );
 		}
 		else if( numsecs == 1 )
 		{
 			self._doorbreach_player iPrintLnBold( level._doorbreach_text_countdown_1 );
 		}
 	}
 }
 
 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 doorbreach_DoorMainThread( doortype, start_with_doors, start_with_walls, modelobject, nogoobject, triggerfrontobject, bombfrontobject, triggerbackobject, bombbackobject, model2object, model3object )
 {
 	// init
 	self._doorbreach_doortype				= doortype;
 	self._doorbreach_modelobject			= modelobject;
 	self._doorbreach_nogoobject				= nogoobject;
 	self._doorbreach_triggerfrontobject		= triggerfrontobject;
 	self._doorbreach_bombfrontobject		= bombfrontobject;
 	self._doorbreach_triggerbackobject		= triggerbackobject;
 	self._doorbreach_bombbackobject			= bombbackobject;
 	self._doorbreach_model2object			= model2object;
 	self._doorbreach_model3object			= model3object;
 
 	// setup coords
 	if( IsDefined( self._doorbreach_modelobject ) )
 	{
 		self._doorbreach_modelobject doorbreach_SetupCoords();		
 	}
 	if( IsDefined( self._doorbreach_nogoobject ) )
 	{
 		self._doorbreach_nogoobject doorbreach_SetupCoords();		
 	}
 	if( IsDefined( self._doorbreach_bombfrontobject ) )
 	{
 		self._doorbreach_bombfrontobject doorbreach_SetupCoords();		
 	}
 	if( IsDefined( self._doorbreach_bombbackobject ) )
 	{
 		self._doorbreach_bombbackobject doorbreach_SetupCoords();		
 	}
 	if( IsDefined( self._doorbreach_model2object ) )
 	{
 		self._doorbreach_model2object doorbreach_SetupCoords();		
 	}
 	if( IsDefined( self._doorbreach_model3object ) )
 	{
 		self._doorbreach_model3object doorbreach_SetupCoords();		
 	}
 	
 	self._doorbreach_action = "";
 	self._doorbreach_bombside = "back";
 	self._doorbreach_count = 0;
 
 	self._doorbreach_state = "";	// none right now
 	
 	// make sure our "origin", "triggerfront" and "triggerback" objects are in SHOW() mode, so that triggers will work.
 	self show();
 	if( IsDefined( self._doorbreach_triggerfrontobject ) )
 	{
 		self._doorbreach_triggerfrontobject Show();
 	}
 	if( IsDefined( self._doorbreach_triggerbackobject ) )
 	{
 		self._doorbreach_triggerbackobject Show();
 	}
 
 	if( self._doorbreach_doortype == "wall" )
 	{
 		if( !IsDefined( start_with_walls ) )
 		{
 			start_with_walls = -1;	// default
 		}
 		if( start_with_walls == -1 )	// default
 		{
 			start_with_walls = 1;	// start with walls
 		}
 		if( start_with_walls == 0 )
 		{
 			// start with no walls
 			// TagEM<INFO> : For some reason, starting out in "no_door_ready" won't setup the triggers!
 			// So for now I'll use "no_door_wait", which appears to work just fine.
 			self doorbreach_GotoState( "no_door_wait" );	//"no_door_ready" );	
 		}
 		else
 		{
 			// start with walls in place
 			self doorbreach_GotoState( "new_door_ready" );
 		}
 	}
 	else
 	{
 		if( !IsDefined( start_with_doors ) )
 		{
 			start_with_doors = -1;	// default
 		}
 		if( start_with_doors == -1 )	// default
 		{
 			start_with_doors = 0;	// start with no doors
 		}
 		if( start_with_doors == 0 )
 		{
 			// start with no doors
 			// TagEM<INFO> : For some reason, starting out in "no_door_ready" won't setup the triggers!
 			// So for now I'll use "no_door_wait", which appears to work just fine.
 			self doorbreach_GotoState( "no_door_wait" );	//"no_door_ready" );	
 		}
 		else
 		{
 			// start with doors in place
 			self doorbreach_GotoState( "new_door_ready" );
 		}
 	}
 	
 	
 	while( 1 )
 	{
 		switch( self._doorbreach_state )
 		{
 			case "no_door_ready":	// Door doesn't exist, but you can build/rebuild it if you want
 				//wait for a player to activate the trigger
 				//self waittill ( "doorbreachinstall", player );
 				msg = self waittill_any_return( "doorbreachinstall" );
 				
 				self doorbreach_GotoState( "new_door_wait" );	// Door exist and is NOT breachable (yet)
 				if( self._doorbreach_doortype == "wall" )
 				{
 					self PlaySound( level._doorbreach_soundfx_wall_created );
 				}
 				else
 				{
 					self PlaySound( level._doorbreach_soundfx_door_created );
 				}
 				
 				if( IsDefined( self._doorbreach_player ) )
 				{
 					if( self._doorbreach_doortype == "wall" )
 					{
 						if( self._doorbreach_count == 0 )
 						{
 							self._doorbreach_player iPrintLnBold( level._doorbreach_text_wall_installed );
 						}
 						else
 						{
 							self._doorbreach_player iPrintLnBold( level._doorbreach_text_wall_repaired );
 						}
 					}
 					else
 					{
 						if( self._doorbreach_count == 0 )
 						{
 							self._doorbreach_player iPrintLnBold( level._doorbreach_text_door_installed );
 						}
 						else
 						{
 							self._doorbreach_player iPrintLnBold( level._doorbreach_text_door_repaired );
 						}
 					}
 				}				
 				break;
 
 			case "new_door_wait":	// Door exist and is NOT breachable (yet)
 				wait level._doorbreach_wait_time_before_breachable;
 				self doorbreach_GotoState( "new_door_ready" );	// Door exist and is breachable
 				break;
 
 			case "new_door_ready":	// Door exist and is breachable
 			
 				//wait for a player to activate the trigger
 				//self waittill ( "trigger", player );
 				//self._doorbreach_bombside = "back";
 					
 				msg = self waittill_any_return( "doorbreachtriggerfront", "doorbreachtriggerback" );
 				if( msg == "doorbreachtriggerback" )
 				{
 					self._doorbreach_bombside = "back";
 				}
 				else
 				{
 					self._doorbreach_bombside = "front";
 				}
 				
 				self doorbreach_GotoState( "bomb_planted" );	// Door exist and bomb has been planted...waiting for it to explode!
 				self PlaySound( level._doorbreach_soundfx_bomb_placed );
 				break;
 
 			case "bomb_planted":	// Door exist and bomb has been planted...waiting for it to explode!
 
 				//wait level._doorbreach_wait_time_bomb_fuse;
 				counter = level._doorbreach_wait_time_bomb_fuse;
 				
 				while( counter > 0.0 )
 				{
 					self doorbreach_CountdownMessage( counter );
 
 					self PlaySound( level._doorbreach_soundfx_bomb_beep );
 					wait ( 1.0 );
 					counter -= 1.0;
 				}
 
 				self._doorbreach_count++;	// increment this (so future messages will say "rebuild door", etc)
 
 				self doorbreach_GotoState( "no_door_wait" );	// Door exploded!
 				
 				if( IsDefined( self._doorbreach_player ) )
 				{
 					if( self._doorbreach_doortype == "wall" )
 					{
 						self._doorbreach_player iPrintLnBold( level._doorbreach_text_wall_breached );
 					}
 					else
 					{
 						self._doorbreach_player iPrintLnBold( level._doorbreach_text_door_breached );
 					}
 				}
 	
 				self doorbreach_Explosion();	// Door exploded!
 				
 			
 				break;
 
 			case "no_door_wait":	// Door exploded!
 				wait level._doorbreach_wait_time_before_can_rebuild;
 				self doorbreach_GotoState( "no_door_ready" );	// Door doesn't exist, but you can build/rebuild it if you want
 				break;
 
 			default:
 				self doorbreach_GotoState( "no_door_ready" );	// Door doesn't exist, but you can build/rebuild it if you want
 				break;
 		}
 	}
 }