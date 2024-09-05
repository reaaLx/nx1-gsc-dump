//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Utility file for helicopter support 							**
//                                                                          **
//    Created: 11.15.2011 - Feldman & Chen								    **
//                                                                          **
//****************************************************************************

#include common_scripts\utility;
#include maps\_hud_util;
#include maps\_utility;
#include maps\_vehicle;
#include maps\_nx_utility;
#include maps\_anim;

AIRDROP_MARKER_WEAPON = "airdrop_marker";   //This weapon need to be added to the helicopter_support.csv
VEHICLE_TARGETNAME = "intro_chopper_formation_2";
ACTOR_TARGETNAME = "heli_support_guys";
DPAD_ICON = "hud_us_smokegrenade";
MESSAGE_TIME = 3.0;  //The amount of time (in second) helicopter support related messages will remain on player's screen 
HINT_STRING_TIMEOUT = 5.0;
TRIGGER_ON_TARGETNAME = "helicopter_support_on";
TRIGGER_OFF_TARGETNAME = "helicopter_support_off";
DEFAULT_PATH_TARGETNAME = "path3_1";
PLAYER_NOTIFY_HELI_SUPPORT_ACTIVE = "heli_support_active";
PLAYER_NOTIFY_HELI_SUPPORT_INACTIVE = "heli_support_inactive";

// tagTC<temp> - height until we get anim adjusted
//FAST_ROPE_HEIGHT = 465; 

// tagTC<temp> - desired height
FAST_ROPE_HEIGHT = 564;

SHOW_PATH_DEBUG_LINES = 0;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
precacheHeliSupport()
{
	precacheItem ( AIRDROP_MARKER_WEAPON );
	precacheShader( DPAD_ICON );
	precacheString( &"SCRIPT_HELISUPPORT_IN_PROGRESS" );
	precacheString( &"SCRIPT_HELISUPPORT_NO_DROP_AVAIL" );
	add_hint_string( "helicopter_support_pull_RT", &"SCRIPT_HELISUPPORT_PULL_RT_TO_THROW", ::remove_pull_RT_hint_string );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
startHeliSupport( start_ammo, allow_same_location_drop )
{
	//println ( "### StartingHeliSupport ###" );
	player = level._player;
	level._HeliSupportInUse = false;

	if ( isDefined ( allow_same_location_drop ))
	{
		level._allow_heli_support_drop_on_same_location = allow_same_location_drop;
	}

	level._heli_support_drop = GetEntArray ( "heli_support_drop_location" , "targetname" );
	assertEX ( level._heli_support_drop.size > 0, "No Helicopter Support drop locations are found in the level" );

	level._heli_support_leave = GetEntArray ( "heli_support_leave" , "targetname" );
	assertEX ( level._heli_support_leave.size > 0, "No Helicopter Support leave nodes are found in the level" );

	level._heli_support_on_triggers = GetEntArray ( TRIGGER_ON_TARGETNAME , "targetname" );
	//assertEX ( level._heli_support_on_triggers.size > 0, "No helicopter support ON triggers are found in the level" );
	array_thread( level._heli_support_on_triggers, ::activate_helicopter_support );

	level._heli_support_off_triggers = GetEntArray ( TRIGGER_OFF_TARGETNAME , "targetname" );
	//assertEX ( level._heli_support_off_triggers.size > 0, "No helicopter support OFF triggers are found in the level" );
	array_thread( level._heli_support_off_triggers, ::terminate_helicopter_support );

	heli_support_guys = getentarray( ACTOR_TARGETNAME, "script_noteworthy" );	
	array_thread( heli_support_guys, ::add_spawn_function, ::spawnfunc_add_actor_to_level_array );

	assertEX ( start_ammo > 0, "The start ammo count for the airdrop marker needs to be positive" );
	level._helicopter_support_start_ammo = start_ammo;

	createthreatbiasgroup( "heli_turret" );
	
	// Init base paths. 
	init_heli_support_paths();
}

//tagJC<NOTE>: self is the helicopter support ON trigger
activate_helicopter_support()
{
	level endon ( "level_stop_helicopter_support" );

	while (1)
	{
		self thread trigger_helicopter_support();
		level waittill( "activate_helicopter_support" );
			
		player = level._player;
			
		//println ( "##### helicopter_support_on_trigger touched" );
		if ( !( isDefined ( player.heliSupportStatus )) || ( isDefined ( player.heliSupportStatus ) && player.heliSupportStatus == "inactive" ))
		{
			//tagJC<NOTE>: For now, manually manage the ammo count for the airdrop marker
			if ( isDefined ( self.script_count ) && self.script_count > 0 )
			{
				player.airdropMarkerCount = self.script_count;
			}
			else if ( isDefined ( player.remainingHeliSupportCount ) && player.remainingHeliSupportCount > 0 )
			{
				player.airdropMarkerCount = player.remainingHeliSupportCount;
			}
			else if ( isDefined ( player.remainingHeliSupportCount ) && player.remainingHeliSupportCount == 0 )
			{
				continue;
			}
			else
			{
				player.airdropMarkerCount = level._helicopter_support_start_ammo;
			}

			player notify ( PLAYER_NOTIFY_HELI_SUPPORT_ACTIVE );
			player.heliSupportStatus = "active";
		
			player setWeaponHudIconOverride( "actionslot4", DPAD_ICON );

			player GiveWeapon( AIRDROP_MARKER_WEAPON, 0, false );
			//tagJC<TODO>: Need to investigate why the start ammo is not set correctly by the following calls
			//level._player GiveStartAmmo ( AIRDROP_MARKER_WEAPON );
			player SetWeaponAmmoStock( AIRDROP_MARKER_WEAPON, WeaponStartAmmo ( AIRDROP_MARKER_WEAPON ));
			//println ( "##### Airdrop marker ammo is: " + ( level._player GetAmmoCount ( AIRDROP_MARKER_WEAPON )));

			player thread waitForActivation();
			player thread waitForTerminateHeliSupport();
			player thread waitForLevelTerminateHeliSupport();
		}
		
		wait ( 0.05 );
	}
}

trigger_helicopter_support()
{
	level endon( "activate_helicopter_support" );
	self waittill( "trigger", player );
	
	if ( ! IsAI ( player ))
	{
		level notify( "activate_helicopter_support" );
	}
}

//tagJC<NOTE>: self is the helicopter support OFF trigger
terminate_helicopter_support()
{
	level endon ( "level_stop_helicopter_support" );
	
	while (1)
	{
		self thread trigger_terminate_helicopter_support();
		level waittill( "trigger_terminate_helicopter_support" );
		
		player = level._player;
		
		if ( ! IsAI ( player ))
		{
			//println ( "##### helicopter_support_off_trigger touched" );
			player.heliSupportStatus = "inactive";
			if ( isDefined ( player.airdropMarkerCount ))
			{
				player.remainingHeliSupportCount = player.airdropMarkerCount;
			}
			player notify ( PLAYER_NOTIFY_HELI_SUPPORT_INACTIVE );
			player notify ( "terminate_helicopter_support" );
		}
		wait ( 0.05 );
	}
}

trigger_terminate_helicopter_support()
{
	level endon( "trigger_terminate_helicopter_support" );
	self waittill( "trigger", player );
	
	if ( ! IsAI ( player ))
	{
		level notify( "trigger_terminate_helicopter_support" );
	}
}


//tagJC<NOTE>: self is the player
waitForActivation()
{
	self endon ( "death" );
	self endon ( "terminate_helicopter_support" );
	level endon ( "level_stop_helicopter_support" );

	self.airdropMarkerInHand = false;

	self notifyOnPlayerCommand( "use air support grenade", "+actionslot 4" );

	for ( ;; )
	{
		self waittill ( "use air support grenade" );
		//println ( "##### Air support grenade pressed #####" );

		if ( isDefined ( level._HeliSupportInUse ) && level._HeliSupportInUse == true )
		{
			self thread createHUDMessage( &"SCRIPT_HELISUPPORT_IN_PROGRESS" );
			continue;
		}

		if ( allDropLocationsTaken() )
		{
			self thread createHUDMessage( &"SCRIPT_HELISUPPORT_NO_DROP_AVAIL" );
			continue;
		}

		if ( isDefined ( self.airdropMarkerInHand ) && ( self.airdropMarkerInHand == false ))
		{
			self.weaponBeforeAirdropMarker = self GetCurrentWeapon();
			self SwitchToWeapon ( AIRDROP_MARKER_WEAPON );
			self.airdropMarkerInHand = true;
			self thread waitForMarkerFire();
			self thread waitForWeaponChange();
		}
		else if ( isDefined ( self.airdropMarkerInHand ) && ( self.airdropMarkerInHand == true ))
		{
			self SwitchToWeapon ( self.weaponBeforeAirdropMarker );
			self.airdropMarkerInHand = false;
			self notify ( "stopWaitForMarkerFire" );
		}
		wait ( 0.05 );
	}
}

//tagJC<NOTE>: self is the player
waitForMarkerFire()
{
	self endon ( "death" );
	self endon ( "stopWaitForMarkerFire" );
    self endon ( "terminate_helicopter_support" );
	level endon ( "level_stop_helicopter_support" );

	if ( !isDefined ( level._player.seenPullRTHint ))
	{
		display_hint_timeout ( "helicopter_support_pull_RT", HINT_STRING_TIMEOUT );
		level._player thread setHasSeenHintFlag();
	}
	
	while ( 1 )
	{
		self waittill ( "grenade_fire", airDropWeapon, weapname );
		//println ( "##### Grenade fired #####" );
		//println ( "##### weapname is: " + weapname );

		if ( weapname == "airdrop_marker" )
		{
			//flyby in sound

			if( flag( "helicopter_reveal" ))
			{
				thread sound_helicopter_wait_logic();
			}
			else
			{
				self playsound ("blackhawk_overhead_passby_fronts");	
			}
                        level thread radio_dialogue( "bor_eag_airdrop_incoming");			

                        self.seenPullRTHint = true;
			self SwitchToWeapon ( self.weaponBeforeAirdropMarker );
			self.airdropMarkerInHand = false;

			airDropWeapon thread waitForExplode( self );
			self.airdropMarkerCount -= 1;

			if ( self.airdropMarkerCount == 0 )
			{
				self.remainingHeliSupportCount = 0;
				self notify ( "terminate_helicopter_support" );
			}
			break;
		}
	}
}

sound_helicopter_wait_logic()
{

	level waittill( "helicopter_support_inbound" );
	level.heli_support_turret playsound ("scn_border_helicopter_reveal");

}

//tagJC<NOTE>: This function will handle the case when player switches the weapon (pressing Y) while having the airdrop marker in hand
waitForWeaponChange()
{
	self endon ( "death" );
	self endon ( "stopWaitForMarkerFire" );
	level endon ( "level_stop_helicopter_support" );

	self notifyOnPlayerCommand( "weapon_switch_during_heli_support", "weapnext" );
	self waittill ( "weapon_switch_during_heli_support" );
	self.airdropMarkerInHand = false;
	self notify ( "stopWaitForMarkerFire" );
}

//tagJC<NOTE>: self is the player
//tagJC<NOTE>: This function will terminate the helicopter support once a notification is sent to the player
waitForTerminateHeliSupport()
{
	self endon ( "death" );
	level endon ( "level_stop_helicopter_support" );

	self waittill ( "terminate_helicopter_support" );

	self.heliSupportStatus = "inactive";

	self TakeWeapon ( AIRDROP_MARKER_WEAPON );
	self setWeaponHudIconOverride( "actionslot4", "none" );

	if ( isDefined ( self.weaponBeforeAirdropMarker ) )
	{
		self SwitchToWeapon ( self.weaponBeforeAirdropMarker );
		self.airdropMarkerInHand = false;
	}

	if ( isDefined ( self.HeliSupportMessage ))
	{
		self.HeliSupportMessage destroy();
		self.HeliSupportMessage = undefined;
	}
}

//tagJC<NOTE>: self is the player
//tagJC<NOTE>: This function will terminate the helicopter support once a notification is sent to the level
waitForLevelTerminateHeliSupport()
{
	self endon ( "death" );

	level waittill ( "level_stop_helicopter_support" );

	self.heliSupportStatus = "inactive";

	self TakeWeapon ( AIRDROP_MARKER_WEAPON );
	self setWeaponHudIconOverride( "actionslot4", "none" );

	if ( isDefined ( self.weaponBeforeAirdropMarker ) )
	{
		self SwitchToWeapon ( self.weaponBeforeAirdropMarker );
		self.airdropMarkerInHand = false;
	}

	if ( isDefined ( self.HeliSupportMessage ))
	{
		self.HeliSupportMessage destroy();
		self.HeliSupportMessage = undefined;
	}
}

//tagJC<NOTE>: self is the airdrop marker grenade
waitForExplode( owner )
{
	self waittill ( "explode", position );

	level._HeliSupportInUse = true;

	//println ( "##### The position for the explosion is: " + position );
	//println ( "##### Airdrop marker ammo after explosion is: " + (level._player GetAmmoCount ( AIRDROP_MARKER_WEAPON )));

	target_name_vehicle = VEHICLE_TARGETNAME;

	target_drop_location = find_closest_drop_location ( position );
	
	if ( isDefined ( target_drop_location.script_parameters ))
	{
		//println ( "##### script_parameters is: " + target_drop_location.script_parameters );
		target_name_vehicle = target_name_vehicle + "_" + target_drop_location.script_parameters;
	}

	chopper = spawn_vehicle_from_targetname( target_name_vehicle );

	// Set the chopper to the angles of the first node in the path
	if( IsDefined( target_drop_location.script_noteworthy ))
	{
		first_node = GetStruct( target_drop_location.script_noteworthy, "targetname" );
		if( IsDefined( first_node ))
		{
			if( IsDefined( first_node.origin ) && IsDefined( first_node.angles ))
			{
				chopper Vehicle_Teleport( first_node.origin, first_node.angles );
			}
		}
	}

	turret = chopper.mgturret[ 0 ];
	turret SetMode( "manual" );
	level.heli_support_turret = turret;

	turret_guys = getentarray("turret_guy", "script_noteworthy");
	foreach ( turret_guy in turret_guys )
	{
		if ( !isSpawner( turret_guy ) )
		{
			turret_guy setthreatbiasgroup( "heli_turret" );
			turret_guy thread magic_bullet_shield();
			level.heli_support_turret_guy = turret_guy;
		}
	}

	chopper thread monitorMovement( target_drop_location );

	level.support_heli = chopper;
}

//tagJC<NOTE>: self is the helicopter
monitorMovement( target_node )
{
	//thread script to start loop self playsound loop
	

	self endon ( "death" );

	// Make invincible. 
	self GodOn();

	// tagTC<note> - notify to check when helicopter is inbound
	level notify( "helicopter_support_inbound" );

	// Spawn special enemies. 
	self special_enemy_spawn( target_node );

	// New Path System.
	self set_on_path( target_node );

	// tagBK<NOTE> We still need this, or the heli ends up in awkward orientations. 
// 	self Vehicle_SetSpeed( 50, 5 );
// 	self SetVehGoalPos( target_node.origin + ( 0, 0, FAST_ROPE_HEIGHT ), 1 );
// 	self SetNearGoalNotifyDist( 10 );
// 	self waittill( "goal" );

	// Removed. 
// 	self SetNearGoalNotifyDist( 50 );
// 	self setTurningAbility( 0.05 );
// 	self setYawSpeed(45,25,25,.5);

	// This locks the vehicle in place for the fast rope animation. 
//	self SetHoverParams( 0, 100, 100 );

	// Unload actors. 
//	heliSupport_actors = self vehicle_unload();	

	// Wait for actors spawn function to be called so that _heli_support_guys is valid. 
//	wait( 0.01 );

	// Setup goal transition for fast ropers. 
//	list_of_support_node = GetNodeArray ( target_node.target, "targetname" );
//	Assert( list_of_support_node.size >= level._heli_support_guys.size );
//	for ( ii = 0; ii < level._heli_support_guys.size; ii++ )
//	{
//		level._heli_support_guys[ ii ] thread move_to_goal_thread( list_of_support_node[ ii ], self, target_node );
//	}

	// Wait for vehicle to finish unload. 
//	self waittill( "unloaded" );

	// tagTC<note> - notify to check when helicopter is unloaded 
	level notify( "helicopter_support_unloaded" );
	
	if( !flag( "helicopter_support_streets_middle" ) )
	{
		level thread radio_dialogue( "bor_eag_airdrop_returning");
	}
	
	// Cleanup and exit. 
//	level._heli_support_guys = [];

	//thread the away sound now

	self Vehicle_SetSpeed( 50, 5 );
	self SetVehGoalPos ( level._heli_support_leave[0].origin, 1 );
	self SetNearGoalNotifyDist( 50 );

	self waittill ( "near_goal" );
	level._HeliSupportInUse = false;
	//script to fade out loop
	
	level.heli_support_turret_guy thread stop_magic_bullet_shield();
	self delete();
}

move_to_goal_thread( goal_node, vehicle, target_node )
{
	self endon( "death" );

	// If a color group has been assigned to the target node, set it on the spawned actors. 
	if ( IsDefined( target_node.script_forcecolor ))
	{
		self set_force_color( target_node.script_forcecolor );
	}

	// Wait until right before the fast rope ends. 
//	self waittill( "jumpedout" );
	animpos = maps\_vehicle_aianim::anim_pos( vehicle, self.script_startingposition );
	anim_length = GetAnimLength( animpos.getout );
	anim_length -= 0.1;
	wait( anim_length );

	self.ignoreme = false;

	// Set goal for actor. 
	self SetGoalNode( goal_node );
	self waittill( "goal" );
	self stop_magic_bullet_shield();
}

//tagJC<NOTE>: self is the AI helicopter support actor that will be dropped from the helicopter
spawnfunc_add_actor_to_level_array()
{	
	self endon( "death" );

	// tagTC<note> - protect the ally until he gets to the node
	// then remove shield, might remove this at a later point
	self magic_bullet_shield();
	self.ignoreme = true;
	
	level._heli_support_guys = add_to_array( level._heli_support_guys, self );	
}

//tagJC<NOTE>: This function finds the closest drop location based on the airdrop marker explosion location
find_closest_drop_location ( explosion_location )
{
	result = undefined;
	distance_square = 999999999999999.0;
	for ( i = 0; i < level._heli_support_drop.size; i++ )
	{
		if ( isDropLocationAvailable ( level._heli_support_drop[i] ))
		{
			curr_distance_square = distanceSquared ( explosion_location, level._heli_support_drop[i].origin );
			if ( !isDefined ( result ) || curr_distance_square < distance_square )
			{
				result = level._heli_support_drop[i];
				distance_square = curr_distance_square;
			}
		}
	}
	if ( isDefined ( result ))
	{
		result.taken = true;
	}
	return result;
}

//tagJC<NOTE>: This function returns whether a given drop location has already been used
isDropLocationAvailable( drop_location )
{
	result = true;
	if ( isDefined ( level._allow_heli_support_drop_on_same_location ) && level._allow_heli_support_drop_on_same_location == false )
	{
		if ( isDefined ( drop_location.taken ) && drop_location.taken == true )
		{
			result = false;
		}
	}	
	return result;
}

//tagJC<NOTE>: This function returns whether all the drop locations in the level have been used
allDropLocationsTaken()
{
	if ( !(isDefined ( level._allow_heli_support_drop_on_same_location ) && level._allow_heli_support_drop_on_same_location == false ))
	{
		return false;	
	}
	else
	{
		result = true;
		for ( i = 0; i < level._heli_support_drop.size; i++ )
		{
			if ( !isDefined ( level._heli_support_drop[i].taken ))
			{
				result = false;
				return result;
			}
		}
		return result;
	}
}

//tagJC<NOTE>: Create the helicopter support related HUD message
createHUDMessage( message )
{
	self endon ( "death" );
	self endon ( "terminate_helicopter_support" );
	level endon ( "level_stop_helicopter_support" );

	if ( !(isDefined ( self.HeliSupportMessage )))
	{
		hudelem = newHudElem( self );
		hudelem.label = message;
		hudelem.alignX = "center";
		hudelem.alignY = "middle";
		hudelem.horzAlign = "center";
		hudelem.vertAlign = "middle";
		hudelem.fontScale = 1.5;
		hudelem.color = ( 1, 1, 1 );
		hudelem.font = "objective";
		hudelem.foreground = 1;
		hudelem.hidewheninmenu = true;
		hudelem.hidewhendead = true;
		self.HeliSupportMessage = hudelem;
		wait ( MESSAGE_TIME );
		self.HeliSupportMessage destroy();
		self.HeliSupportMessage = undefined;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
debug_draw_path( base_path )
{
	self endon( "release_path" );

	// Draw the new path for a bit. 
	while ( 1 )
	{
		// Draw path every frame. 
		next_struct = base_path;
		prev_node = undefined;
		color = ( 1, 0, 0 );
		while ( 1 )
		{
			line( next_struct.origin, next_struct.origin + ( 0, 0, 100 ), color );
			if ( IsDefined( prev_node ))
			{
				line( prev_node.origin, next_struct.origin, ( 1, 1, 1 ));
			}

			if ( !IsDefined( next_struct.target ))
			{
				break;
			}
			prev_node = next_struct;
			next_struct = GetStruct( next_struct.target, "targetname" );
			color = ( 1, 1, 0 );
		}
		wait( 0.01 );
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
get_heli_path_from_target_node( target_node )
{
	// Get the main path. 
	if ( isDefined ( target_node.script_noteworthy ))
	{
		heli_path = GetStruct( target_node.script_noteworthy, "targetname" );
	}
	else
	{
		heli_path = GetStruct( DEFAULT_PATH_TARGETNAME, "targetname" );
	}

	return heli_path;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
init_heli_support_paths()
{
	level.helidrop_path_in_use = 0;
	level.helidrop_base_path_pos = [];

	for ( ii = 0; ii < level._heli_support_drop.size; ii++ )
	{
		// Grab the base path and setup a new global path array. 
		base_path = get_heli_path_from_target_node( level._heli_support_drop[ ii ] );
		new_base_path = [];

		// Get the end node to base the orientation off of. 
		end_path = base_path;
		while ( 1 )
		{
			if ( !IsDefined( end_path.target ))
			{
				break;
			}
			end_path = GetStruct( end_path.target, "targetname" );
		}

		// Store new info. 
		next_struct = base_path;
		while ( 1 )
		{
			// Build new item data. 
			new_struct = SpawnStruct();
			new_struct.height = ( next_struct.origin[ 2 ] - end_path.origin[ 2 ] );
			new_struct.local_origin = next_struct.origin - end_path.origin;
			new_struct.local_origin *= ( 1, 1, 0 );
			new_struct.distance = Length( new_struct.local_origin );
			angles = vectortoangles( new_struct.local_origin );
			new_struct.angle = angles[ 1 ];

			// Backup to global. 
			new_base_path[ new_base_path.size ] = new_struct;

			// Next node. 
			if ( !IsDefined( next_struct.target ))
			{
				break;
			}
			next_struct = GetStruct( next_struct.target, "targetname" );
		}

		// Store the new path into a global and backup the index. 
		base_path.global_index = level.helidrop_base_path_pos.size;
		level.helidrop_base_path_pos[ level.helidrop_base_path_pos.size ] = new_base_path;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
orient_path( vehicle, base_path, offset )
{
	worldaligned = 0;
	if ( isDefined ( self.script_worldaligned ) && self.script_worldaligned == 1 )
	{
		worldaligned = 1;
	}

	// Cannot use heli drop path in more than one place. 
	AssertEx( level.helidrop_path_in_use == 0, "Cannot use heli drop path in more than one place." );
	level.helidrop_path_in_use = 1;

	// Local aligned. 
	if( !worldaligned )
	{
		// Get the global base path.
		assert( base_path.global_index < level.helidrop_base_path_pos.size );
		global_base_path = level.helidrop_base_path_pos[ base_path.global_index ];

		// Move the path into position. 
		next_struct = base_path;
		for ( ii = 0; ii < global_base_path.size; ii++ )
		{
			// Set the new position.
			base_dist = global_base_path[ ii ].distance;
			base_angle = global_base_path[ ii ].angle;
			x = base_dist * Cos( base_angle + self.angles[ 1 ] );
			y = base_dist * Sin( base_angle + self.angles[ 1 ] );
			rotated_local = ( x, y, offset[ 2 ] + global_base_path[ ii ].height );
			next_struct.origin = self.origin + rotated_local;

			// Next link.
			if ( IsDefined( next_struct.target ))
			{
				next_struct = GetStruct( next_struct.target, "targetname" );
			}
		}
	}

	// Teleport the vehicle. 
	angles = self.angles + vehicle.angles;
	backward = AnglesToForward( angles ) * -100.0;
   	vehicle vehicle_teleport( base_path.origin + backward, angles );

	// Debug draw the path. 
	if ( SHOW_PATH_DEBUG_LINES )
	{
		self thread debug_draw_path( base_path );
	}

	// Wait until we are done with this path. 
	self waittill( "release_path" );
	level.helidrop_path_in_use = 0;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
set_on_path( target_node )
{
	// Get the main path. 
	heli_path = get_heli_path_from_target_node( target_node );
	Assert( IsDefined( heli_path ));

	// tagBK< NOTE > We offset the vehicle path down by 155 units. This is because when following a path, the vehicle 
	// bases its movement on a different tag than when targeting a goal position. 
	path_height = FAST_ROPE_HEIGHT;
	if( IsDefined( target_node.height ) )
	{
		path_height = target_node.height;
	}
	
	target_node thread orient_path( self, heli_path, ( 0, 0, path_height - 155 ));
	wait( 0.1 );

	self.script_vehicle_selfremove = undefined;
	self vehicle_paths( heli_path );
	target_node notify( "release_path" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
special_enemy_spawn( target_node )
{
	spawners = GetEntArray( target_node.target, "targetname" );
	ii = 0;
	foreach( spawner in spawners )
	{
		if ( IsSpawner( spawner ))
		{
			self thread spawn_guy_thread( spawner, ii );
			ii++;
		}
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
spawn_guy_thread( spawner, ii )
{
	// Spawn a guy and send him to a target node. 
	guy = spawner spawn_ai();
	if ( !IsDefined( guy ))
	{
		return;
	}
	
	guy endon( "death" );

	// We want these guys ignored and at low health until the fast ropers leave. 
	guy.fixednode = true;
	guy.ignoreme = true;
	guy.health = 1;

	// Target the helicopter. 
	guy SetEntityTarget( self );

	// Wait for the helicopter to unload. 
	self waittill( "unloaded" );
	guy ClearEntityTarget();
	guy.ignoreme = false;
	guy.fixednode = false;

	// Make guy vulnerable again and set target. 
	if ( level._heli_support_guys.size > ii )
	{
		if ( IsAlive( level._heli_support_guys[ ii ] ))
		{
			guy SetEntityTarget( level._heli_support_guys[ ii ]);
			level._heli_support_guys[ ii ] SetEntityTarget( guy );
		}
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
remove_pull_RT_hint_string()
{
	result = false;
	if( isDefined ( level._player.seenPullRTHint ) && level._player.seenPullRTHint == true )
	{
		result = true;
	}
	return result;
}

setHasSeenHintFlag()
{
	wait ( HINT_STRING_TIMEOUT );
	level._player.seenPullRTHint = true;
}