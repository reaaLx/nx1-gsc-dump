#include maps\_utility;
#include maps\_vehicle;
#include common_scripts\utility;

preLoad()
{
	//generic turrets and missiles for all attack helis
	PreCacheItem( "turret_attackheli" );
	PreCacheItem( "missile_attackheli" );

	//spotlight effect for _attack_hei vehicles with script_spotlight set to "1"
	attack_heli_fx();
	thread init();
	//maps\_mi28::main( "vehicle_mi-28_flying" );		//why is this here?
}

attack_heli_fx()
{
	if ( GetDvarInt( "sm_enable" ) && GetDvar( "r_zfeather" ) != "0" )
		level._effect[ "_attack_heli_spotlight" ]	 = LoadFX( "misc/hunted_spotlight_model" );
	else
		level._effect[ "_attack_heli_spotlight" ]	 = LoadFX( "misc/spotlight_large" );

}

init()
{
	// already ran elsewhere
	if ( IsDefined( level._attackHeliAIburstSize ) )
		return;

	while ( !isdefined( level._gameskill ) )
		wait( 0.05 );
	/*-----------------------
	ATTACK HELI PARAMETERS
	-------------------------*/		
	if ( !isdefined( level._cosine ) )
		level._cosine = [];

	if ( !isdefined( level._cosine[ "25" ] ) )
		level._cosine[ "25" ] = Cos( 25 );

	if ( !isdefined( level._cosine[ "35" ] ) )
		level._cosine[ "35" ] = Cos( 35 );

	if ( !isdefined( level._cosine[ "45" ] ) )
		level._cosine[ "45" ] = Cos( 45 );

	if ( !isdefined( level._cosine[ "180" ] ) )
		level._cosine[ "180" ] = Cos( 180 );

	if ( !isdefined( level._attackheliRange ) )		// Heli shoots at target within this distance
		level._attackheliRange = 3500;

	// Set up threat consts
	if ( !IsDefined( level._ai_threat_dist_rate ) )
	{
		AI_THREAT_DISTANCE_MAXTHREAT = 5000; // maximum threat added based on distance
		level._ai_threat_dist_rate = AI_THREAT_DISTANCE_MAXTHREAT * ( 1.0 / ( level._attackheliRange * level._attackheliRange ) );

		level._ai_threat_current_enemy = 500;
	}

	if ( !isdefined( level._attackHeliKillsAI ) )	// Heli shoots at AI, but misses
		level._attackHeliKillsAI = false;

	if ( !isdefined( level._attackHeliFOV ) )		// FOV where the heli can detect targets
		level._attackHeliFOV = Cos( 30 );

	level._attackHeliAIburstSize = 1; 		// how long to fire miniguns at AI
	level._attackHeliMemory = 3;					// how long heli remember who it was that shot at him
	level._attackHeliTargetReaquire = 6;// how long before a heli checks for new targets
	level._attackHeliMoveTime = 3; 			// how long the heli waits before looking for a new node

	// Default refire delay times
	level._attackHeliRefire_min = 0.8;
	level._attackHeliRefire_max = 1.3;

	switch( level._gameSkill )
	{
		case 0:// easy
			level._attackHeliPlayerBreak = 9;		// if heli has been beating on the player, pick on someone else for this amt of time or until player attacks
			level._attackHeliTimeout = 1; 				// how long the target is out of sight before heli stops shooting it
			break;
		case 1:// regular
			level._attackHeliPlayerBreak = 7;	// if heli has been beating on the player, pick on someone else for this amt of time or until player attacks
			level._attackHeliTimeout = 2; 			// how long the target is out of sight before heli stops shooting it
			break;
		case 2:// hardened
			level._attackHeliPlayerBreak = 5;	// if heli has been beating on the player, pick on someone else for this amt of time or until player attacks
			level._attackHeliTimeout = 3; 			// how long the target is out of sight before heli stops shooting it
			break;
		case 3:// veteran
			level._attackHeliPlayerBreak = 3;	// if heli has been beating on the player, pick on someone else for this amt of time or until player attacks
			level._attackHeliTimeout = 5; 			// how long the target is out of sight before heli stops shooting it
			break;
	}
}

/*
=============
///ScriptDocBegin
"Name: start_attack_heli( <sTargetname> )"
"Summary: Spawns an attack helicopter in PMC or singleplayer that will go to the closest path of helicopter nodes and harass the player. See wiki or PMC maps for details on setting up the heli and a network of nodes."
"Module: Vehicle"
"OptionalArg: <sTargetname>: Targetname value of the helicopter that will spawn. PMC does not require a targetname (uses 'kill_heli')"
"Example: attack_heli = thread maps\_attack_heli::start_attack_heli();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
start_attack_heli( sTargetname )
{
	if ( !isdefined( sTargetname ) )
		sTargetname = "kill_heli";
	eHeli = maps\_vehicle::spawn_vehicle_from_targetname_and_drive( sTargetname );
	eHeli = begin_attack_heli_behavior( eHeli );
	return eHeli;
}
/*
=============
///ScriptDocBegin
"Name: begin_attack_heli_behavior( <eHeli> )"
"Summary: Makesa regularly spawned helicopter start using the AI logic in _attack_heli.gsc script (stalking the player and firing at him)"
"Module: Vehicle"
"MandatoryArg: <eHeli>: The helicopter entity"
"OptionalArg: <heli_points>: Points for the Heli to use when checking for player proximity."
"Example: eHeli = maps\_attack_heli::begin_attack_heli_behavior( eHeli );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
begin_attack_heli_behavior( eHeli, heli_points, shoot_func )
{
	/*-----------------------
	HELI SETUP
	-------------------------*/	
	eHeli endon( "death" );
	eHeli endon( "heli_players_dead" );

	if ( ( level._gameskill == 0 )  || ( level._gameskill == 1 ) )
	{
		//create an attractor if this is easy or normal
		org = Spawn( "script_origin", eHeli.origin + ( 0, 0, -20 ) );
		org LinkTo( eHeli );
		eHeli thread delete_on_death( org );
		strength = undefined;
		if ( level._gameskill == 0 )
			strength = 2800;
		else
			strength = 2200;
		
		if( !isdefined( eHeli.no_attractor ) )
		{
			eHeli.attractor = Missile_CreateAttractorEnt( org, strength, 10000, level._player );
			
			if ( is_coop() )
			{
				eHeli.attractor2 = Missile_CreateAttractorEnt( org, strength, 10000, level._player2 );
			}
		}
		//thread debug_message( "attractor", undefined, 9999, org );
	}
	eHeli EnableAimAssist();
	eHeli.startingOrigin = Spawn( "script_origin", eHeli.origin );
	eHeli thread delete_on_death( eHeli.startingOrigin );
	if ( !isdefined( eHeli.circling ) )
		eHeli.circling = false;
	eHeli.allowShoot = true;
	eHeli.firingMissiles = false;
	eHeli.moving = true;
	eHeli.isTakingDamage = false;
	eHeli.heli_lastattacker = undefined;
	eHeli thread notify_disable();
	eHeli thread notify_enable();
	thread kill_heli_logic( eHeli, heli_points, shoot_func );

	eHeli.turrettype = undefined;
	eHeli heli_default_target_setup();

	eheli thread detect_player_death();
	
	/*-----------------------
	SETUP ATTACK HELI BASED ON VEHICLETYPE
	-------------------------*/		
	switch( eHeli.vehicletype )
	{
		case "hind":
			eHeli.turrettype = "default";
			break;
		case "mi28":
			eHeli.turrettype = "default";
			break;
		case "cobra":
			eHeli.turrettype = "default";
			break;
		case "littlebird":
			eHeli SetYawSpeed( 90, 30, 20 );	// 90 degree / s, 30 degree / s^2, 20 degree / s^2
			eHeli SetMaxPitchRoll( 40, 40 );
			eHeli SetHoverParams( 100, 20, 5 );
			eHeli setup_miniguns();
			break;
		case "nx_miniuav":
			eheli.turrettype = "nx_miniuav_rifle";
			break;
		case "nx_chinese_skimmer":
			eheli.turrettype = "nx_chinese_skimmer_weap";
			break;
		case "nx_proto_arcade_vtol":
		case "nx_chinese_vtol_troop_cabin_low":
			eHeli.turrettype = "default";
			break;
		default:
			AssertMsg( "Need to set up this heli type in the _attack_heli.gsc script begin_attack_heli_behavior(): " + self.vehicletype );
			break;
	}

	/*-----------------------
	SPOTLIGHT, AIMING, ETC.
	-------------------------*/		
	eHeli.eTarget = eHeli.targetdefault;
	if ( ( IsDefined( eHeli.script_spotlight ) ) && ( eHeli.script_spotlight == 1 ) && ( !isdefined( eHeli.spotlight ) ) )
		eHeli thread heli_spotlight_on( undefined, true );

	eHeli thread attack_heli_cleanup();
	return eHeli;
}

detect_player_death()
{
	foreach( player in level._players )
		player add_wait( ::waittill_msg, "death" );
	do_wait_any();
	
	self notify( "heli_players_dead" );
}

heli_default_target_setup()
{
	up_offset = undefined;
	forward_offset = undefined;
	switch( self.vehicletype )
	{
		case "hind":
			forward_offset = 600;
			up_offset = -100;
			break;
		case "mi28":
			forward_offset = 600;
			up_offset = -100;
			break;
		case "cobra":
			forward_offset = 550;
			up_offset = -120;
			break;
		case "littlebird":
			forward_offset = 600;
			up_offset = -204;
			break;
		case "nx_miniuav":
			forward_offset = 100;
			up_offset = -10;
			break;
		case "nx_proto_arcade_vtol":
			forward_offset = 600;
			up_offset = -100;
			break;
		case "nx_chinese_skimmer":
			forward_offset = 100;
			up_offset = -10;
			break;
		case "nx_chinese_vtol":
		case "nx_chinese_vtol_troop_cabin":
		case "nx_chinese_vtol_troop_cabin_low":
			forward_offset = 600;
			up_offset = -204;
			break;		
		default:
			AssertMsg( "Need to set up this heli type in the _attack_heli.gsc script heli_default_target_setup(): " + self.vehicletype );
			break;
	}
	self.targetdefault = Spawn( "script_origin", self.origin );
	self.targetdefault.angles = self.angles;
	self.targetdefault.origin = self.origin;

	ent = SpawnStruct();
	ent.entity = self.targetdefault;
	ent.forward = forward_offset;
	ent.up = up_offset;
	ent translate_local();
	self.targetdefault LinkTo( self );
	self.targetdefault thread heli_default_target_cleanup( self );
}

get_turrets()
{
	if ( IsDefined( self.turrets ) )
		return self.turrets;

	setup_miniguns();
	return self.turrets;
}

setup_miniguns()
{
	AssertEx( !isdefined( self.turrets ), ".turrets are already defined" );

	self.turrettype = "miniguns";
	self.minigunsspinning = false;
	self.firingguns = false;
	if ( !isdefined( self.mgturret ) )	//in case the heli is taken out before has a chance to setup turrets
		return;
	
	self.turrets = self.mgturret;
	array_thread( self.turrets, ::littlebird_turrets_think, self );
}

heli_default_target_cleanup( eHeli )
{
	eHeli waittill_either( "death", "crash_done" );
	if ( IsDefined( self ) )
		self Delete();
}

start_circling_heli( heli_targetname, heli_points, heli, shoot_func, node_func, get_goal_pos_func )
{
	if ( !isdefined( shoot_func ) )
	{
		shoot_func = ::heli_shoot_think;
	}

	if ( !isdefined( node_func ) )
	{
		node_func = ::heli_circle_node_choice;
	}

	if ( !( heli maps\_vehicle::isSAV() ) )
	{
		if ( !isdefined( heli_targetname ) )
			heli_targetname = "kill_heli";

		// If the heli hasn't been defined, we spawn it
		if ( !IsDefined( heli ) )
		{
			heli = maps\_vehicle::spawn_vehicle_from_targetname_and_drive( heli_targetname );
		}
		else // Otherwise, we just send it on the path
		{
			thread GoPath( heli );
		}
	}

	heli.current_node = undefined;
	heli.startingOrigin = Spawn( "script_origin", heli.origin );
	heli thread delete_on_death( heli.startingOrigin );

	heli start_circling_heli_logic( heli_points, shoot_func, node_func, get_goal_pos_func );

	return heli;
}

start_circling_heli_logic( heli_points, shoot_func, node_func, get_goal_pos_func )
{
	heli = self;

	heli SetHoverParams( 0, 0, 0.0 );

	heli.circling = true;
	heli.allowShoot = true;
	heli.firingMissiles = false;
	heli thread notify_disable();
	heli thread notify_enable();
	thread kill_heli_logic( heli, heli_points, shoot_func, node_func, get_goal_pos_func );	
}

kill_heli_logic( heli, heli_points, shoot_func, node_func, get_goal_pos_func )
{
	if ( !isdefined( shoot_func ) )
	{
		shoot_func = ::heli_shoot_think;
	}

	if ( !isdefined( node_func ) )
	{
		node_func = ::heli_circle_node_choice;
	}

	if ( !isdefined( heli ) )
	{
		heli = maps\_vehicle::spawn_vehicle_from_targetname_and_drive( "kill_heli" );
		Assert( IsDefined( heli ) );
		heli.allowShoot = true;
		heli.firingMissiles = false;
		heli thread notify_disable();
		heli thread notify_enable();
	}

	baseSpeed = undefined;
	if ( !isdefined( heli.script_airspeed ) )
		baseSpeed = 40;
	else
		baseSpeed = heli.script_airspeed;

	if ( !isdefined( level._enemy_heli_killed ) )
		level._enemy_heli_killed = false;

	if ( !isdefined( level._commander_speaking ) )
		level._commander_speaking = false;

	if ( !isdefined( level._enemy_heli_attacking ) )
		level._enemy_heli_attacking = false;

	//players who have not hit the heli in the last 5 seconds
	//are invisible to the attack heli while in this volume
	level._attack_heli_safe_volumes = undefined;
	volumes = GetEntArray( "attack_heli_safe_volume", "script_noteworthy" );
	if ( volumes.size > 0 )
		level._attack_heli_safe_volumes = volumes;

	if ( ! level._enemy_heli_killed )
		thread dialog_nags_heli( heli );


	if( !isdefined( heli.helicopter_predator_target_shader ) )
	{
		switch( heli.vehicletype )
		{
			case "cobra":
			case "mi28":
				Target_Set( heli, ( 0, 0, -80 ) );
				Target_SetJavelinOnly( heli, true );
				heli SetVehWeapon( "turret_attackheli" );
				break;
			case "hind":
				Target_Set( heli, ( 0, 0, -96 ) );
				Target_SetJavelinOnly( heli, true );
				heli SetVehWeapon( "turret_attackheli" );
				break;
			case "littlebird":
				Target_Set( heli, ( 0, 0, -80 ) );
				Target_SetJavelinOnly( heli, true );
				heli SetVehWeapon( "turret_attackheli" );
				break;
			case "nx_miniuav":
				Target_Set( heli, ( 0, 0, -80 ) );
				Target_SetJavelinOnly( heli, true );
				heli SetVehWeapon( "nx_miniuav_rifle" );
				break;
			case "nx_chinese_skimmer":
				Target_Set( heli, ( 0, 0, -80 ) );
				Target_SetJavelinOnly( heli, true );
				heli SetVehWeapon( "nx_chinese_skimmer_weap" );
				break;
			case "nx_proto_arcade_vtol":
			case "nx_chinese_vtol_troop_cabin_low":
				Target_Set( heli, ( 0, 0, -80 ) );
				heli SetVehWeapon( "turret_attackheli" );
				break;
			default:
				AssertMsg( "Need to set up this heli type in the _attack_heli.gsc script kill_heli_logic(): " + self.vehicletype );
				break;
		}
		//Target_SetJavelinOnly( heli, true );
	}

	heli thread heli_damage_monitor();
	heli thread heli_death_monitor();

	heli endon( "death" );
	heli endon( "heli_players_dead" );
	heli endon( "returning_home" );

	if ( !isdefined( heli.circling ) )
		heli.circling = false;

	if ( !heli.circling )
	{
		heli SetNearGoalNotifyDist( 100 );
		if ( !isdefined( heli.dontWaitForPathEnd ) )
			heli waittill( "reached_dynamic_path_end" );
	}
	else
	{
		// tagBR< note >: This next line actually gets overwritten in the call to heli_circling_think below...
		if ( !isdefined( heli.dontWaitForPathEnd ) )
		{
			heli SetNearGoalNotifyDist( 500 );
			heli waittill( "near_goal" );
		}
	}

	heli thread [[shoot_func]]();
	
	// JR - Added this so attack heli AI works without circling or goal based navigation
	if( isDefined( heli.no_navigation ) && heli.no_navigation == true )
	{
		return;
	}

	if ( heli.circling )
		heli thread heli_circling_think( heli_points, baseSpeed, node_func, get_goal_pos_func );
	else
		heli thread heli_goal_think( baseSpeed );
}

heli_circling_think( heli_points, baseSpeed, node_func, get_goal_pos_func )
{
	//create origins with "attack_heli_circle_node" targetname
	//each one targets 2 (or more) other origins
	//the heli randomly moves between the 2 (or more) points targeted by the closest node

	if ( !isdefined( heli_points ) )
		heli_points = "attack_heli_circle_node";

	points = GetEntArray( heli_points, "targetname" );
	if ( !isdefined( points ) || ( points.size < 1 ) )
	{
		points = getstructarray( heli_points, "targetname" );
	}

	if ( !isdefined( points ) || ( points.size < 1 ) )
	{
		points = GetNodeArray( heli_points, "targetname" );
	}

	Assert( IsDefined( points ) );

	heli = self;

	heli endon( "stop_circling" );
	heli endon( "death" );
	heli endon( "returning_home" );
	heli endon( "heli_players_dead" );

	for ( ;; )
	{
		heli SetNearGoalNotifyDist( 100 );

		// For SAVs, we need to consider nodes the vehicle can see

		heli_locations = heli [[node_func]]( baseSpeed, points );

		Assert( IsDefined( heli_locations ) );

		if ( !heli_locations.size )
		{
			wait( RandomFloatRange( 1.8, 2.3 ) );
			continue;
		}

		// Now grab a random heli point
		goal = heli_locations[ RandomInt( heli_locations.size ) ];

		goal_pos = goal.origin;
		if ( isdefined( get_goal_pos_func ) )
		{
			goal_pos = heli [[get_goal_pos_func]]( goal );
		}

		heli SetVehGoalPos( goal_pos, 1 );

		heli waittill( "near_goal" );

		if ( !isdefined( level._player.is_controlling_UAV ) )
		{
			if ( self maps\_vehicle::isSAV() )
			{
				wait( RandomFloatRange( 0.9, 1.2 ) );

				if ( IsDefined( self.eTarget ) )
				{
					if ( IsAlive( self.eTarget ) && can_see_player( self.eTarget ) && ( !self.eTarget is_hidden_from_heli( self ) ) )
					{
						wait( RandomFloatRange( 1.9, 3.1 ) );
					}
				}

				while ( IsDefined( self.firingguns ) && self.firingguns == true )
				{
					wait 0.05;
				}
			}
			else
			{
				wait( RandomFloatRange( 1.8, 2.3 ) );
			}
		}
	}
}

heli_circle_node_choice( baseSpeed, nodes )
{

	self Vehicle_SetSpeed( baseSpeed, baseSpeed / 4, baseSpeed / 4 );

	preferred_target = get_closest_player_healthy( self.origin );
	self SetLookAtEnt( preferred_target );

	// This gets the closest "attack_heli_circle_node" point to the target
	closest_point = getClosest( preferred_target.origin, nodes );

	// Grab the array of heli points targeted by closest point
	heli_locations = GetEntArray( closest_point.target, "targetname" );

	if ( !isdefined( heli_locations ) || ( heli_locations.size < 1 ) )
	{
		heli_locations = getstructarray( closest_point.target, "targetname" );
	}

	return heli_locations;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
process_heli_sight_nodes( nodes )
{
	// tagBR< note > Because the heli will fly straight through walls, we need to:
	// Find all nodes within sight of heli initially
	search_nodes = GetEntArray( nodes, "targetname" );

	if ( !isdefined( search_nodes ) || ( search_nodes.size < 1 ) )
	{
		search_nodes = GetNodeArray( nodes, "targetname" );
	}

	tag_flash_loc = self GetTagOrigin( "tag_flash" );
	self.sight_nodes = [];

	for( i = 0; i < search_nodes.size; i++ )
	{
		node0 = search_nodes[i];

		// If the heli can see the node
		if( BulletTracePassed( tag_flash_loc, node0.origin, false, self ) )
		{
			// Add it to the array
			self.sight_nodes[self.sight_nodes.size] = node0;
		}
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
process_sight_nodes( nodes )
{
	// The processing of each set of sight nodes only needs to be done once
	if ( IsDefined( level._sight_nodes_defined ) && IsDefined( level._sight_nodes_defined[nodes] ) )
	{
		return;
	}

	search_nodes = GetEntArray( nodes, "targetname" );

	if ( !isdefined( search_nodes ) || ( search_nodes.size < 1 ) )
	{
		search_nodes = GetNodeArray( nodes, "targetname" );
	}
	
	// tagBR< note > Because the heli will fly straight through walls, we need to:
	// Find all nodes within sight of each node
	for( i = 0; i < search_nodes.size; i++ )
	{
		node0 = search_nodes[i];
		node0.sight_nodes = [];

		for( j = 0; j < search_nodes.size; j++ )
		{
			if( j == i )
				continue;

			node1 = search_nodes[j];

			// If the node can see the other node
			if( BulletTracePassed( node0.origin, node1.origin, false, undefined ) )
			{
				// Add it to the array
				node0.sight_nodes[node0.sight_nodes.size] = node1;
			}
		}
	}

	level._sight_nodes_defined[nodes] = 1;
}

heli_goal_think( baseSpeed )
{
	self endon( "death" );
	points = GetEntArray( "kill_heli_spot", "targetname" );
	Assert( IsDefined( points ) );

	heli = self;
	goal = getClosest( heli.origin, points );
	current_node = goal;
	Assert( IsDefined( goal ) );
	heli endon( "death" );
	heli endon( "returning_home" );
	heli endon( "heli_players_dead" );
	eLookAtEnt = undefined;
	for ( ;; )
	{
		wait( 0.05 );
		/*-----------------------
		MOVE HELI TO CURRENT GOAL
		-------------------------*/	
		heli Vehicle_SetSpeed( baseSpeed, baseSpeed / 2, baseSpeed / 10 );
		heli SetNearGoalNotifyDist( 100 );
		player = get_closest_player_healthy( heli.origin );
		playerOrigin = player.origin;

		/*-----------------------
		DONT HOVER AT SAME NODE IF TAKING DAMAGE
		-------------------------*/	
		if ( ( goal == current_node ) && ( heli.isTakingDamage ) )
		{
			//if goal is current node and taking damage, choose another
			linked = get_linked_points( heli, goal, points, player, playerOrigin );
			goal = getClosest( playerOrigin, linked );
		}


		heli SetVehGoalPos( goal.origin, 1 );
		heli.moving = true;

		/*-----------------------
		HELI IS LOOKING AT CURRENT TARGET
		-------------------------*/	

		player = get_closest_player_healthy( heli.origin );


		if ( ( IsDefined( self.eTarget ) ) && ( IsDefined( self.eTarget.classname ) ) && ( self.eTarget.classname == "script_origin" ) )
			eLookAtEnt = player;
		else if ( isdefined( self.eTarget ) )
			eLookAtEnt = self.eTarget;
		else
			eLookAtEnt = self.targetdefault;
		
		heli SetLookAtEnt( eLookAtEnt );

		/*-----------------------
		HELI ARRIVES AT GOAL
		-------------------------*/	
		heli waittill( "near_goal" );
		heli.moving = false;

		/*-----------------------
		DONT MOVE IF PLAYER IS CURRENTLY AIMING WITH ROCKET (ON EASY AND NORMAL)
		-------------------------*/	
		if( !is_coop() )
		{
			if ( ( level._gameSkill == 0 ) || ( level._gameSkill == 1 ) )
			{
				while ( player_is_aiming_with_rocket( heli ) )
					wait( .5 );
				wait( 3 );
			}
		}
	
		/*-----------------------
		CHOOSE THE BEST NODE TO GO TO NEXT
		-------------------------*/	
		player = get_closest_player_healthy( heli.origin );
		playerOrigin = player.origin;

		linked = get_linked_points( heli, goal, points, player, playerOrigin );
		linked[ linked.size ] = goal;// add current node to possible points
		current_node = goal;

		//even if it's targeting another entity, always try to track down closest player
		player_location = getClosest( playerOrigin, points );
		closest_linked_point = getClosest( playerOrigin, linked );

		/*-----------------------
		CULL INVALID POINTS
		-------------------------*/	
		foreach ( point in linked )
		{
			//remove potential hover point if it cannot see any part of the player
			if ( player SightConeTrace( point.origin, heli ) != 1 )
			{
				linked = array_remove( linked, point );
				continue;
			}
		}

		//find the closest_neighbor with the culled linked points
		closest_neighbor = getClosest( playerOrigin, linked );

		//Only less than 2 points available, go to the last known closest linked point
		if ( linked.size < 2 )
			goal = closest_linked_point;

		//There is a point near the player but not right next to him
		else if ( closest_neighbor != player_location )
			goal = closest_neighbor;

		//the closest linked point IS the player position point, so pick either 2nd or 3rd best spot
		else
		{
			excluders = [];
			excluders[ 0 ] = closest_neighbor;
			//make "linked" array only contain the 2 closest points
			linked = get_array_of_closest( playerOrigin, linked, excluders, 2 );

			//randomly go to one of the two closest points or the player location
			iRand = RandomInt( linked.size );

			if ( RandomInt( 100 ) > 50 )
				goal = linked[ iRand ];
			else
				goal = player_location;
		}

		/*-----------------------
		WAIT TO MOVE, UNLESS BEING SHOT AT
		-------------------------*/
		fRand = RandomFloatRange( level._attackHeliMoveTime - 0.5, level._attackHeliMoveTime + 0.5 );
		self waittill_notify_or_timeout( "damage_by_player", fRand );
	}
}

player_is_aiming_with_rocket( eHeli )
{
	if ( !level._player usingAntiAirWeapon() )
		return false;
	if ( !level._player AdsButtonPressed() )
		return false;
	playerEye = level._player GetEye();
	if ( SightTracePassed( playerEye, eHeli.origin, false, level._player ) )
	{
		//thread debug_message( "AIMING", undefined, 1, eHeli );
		return true;
	}

	return false;
}

heli_shoot_think()
{
	self endon( "stop_shooting" );
	self endon( "death" );
	self endon( "heli_players_dead" );

	self thread heli_missiles_think();
	attackRangeSquared = level._attackheliRange * level._attackheliRange;
	level._attackHeliGracePeriod = false;

	while ( IsDefined( self ) )
	{

		wait( RandomFloatRange( level._attackHeliRefire_min, level._attackHeliRefire_max ) );

		/*-----------------------
		TRY TO GET A PLAYER AS A TARGET FIRST
		-------------------------*/	
		//Heli has no target at all	or has a target but it's not the player		
		if ( ( !heli_has_target() ) || ( !heli_has_player_target() ) )
		{
			eTarget = self heli_get_target_player_only();
			if ( IsPlayer( eTarget ) )
			{
				self.eTarget = eTarget;

			}
		}

		/*-----------------------
		IF TARGET IS PLAYER MAKE SURE ITS THE CLOSEST PLAYER
		-------------------------*/		
		if ( ( heli_has_player_target() ) && ( level._players.size > 1 ) )
		{
			closest_player = get_closest_player_healthy( self.origin );
			if ( self.eTarget != closest_player )
			{
				eTarget = self heli_get_target_player_only();
				if ( IsPlayer( eTarget ) )
					self.eTarget = eTarget;
			}

		}
		/*-----------------------
		IF TARGET IS PLAYER MAKE SURE CAN STILL SEE
		-------------------------*/		
		if ( heli_has_player_target() )
		{
			if ( ( !heli_can_see_target() ) || ( level._attackHeliGracePeriod == true ) )
			{
				/*-----------------------
				IF CANT SEE PLAYER, GET A NEW NON-PLAYER TARGET
				-------------------------*/		
				eTarget = self heli_get_target_ai_only();
				self.eTarget = eTarget;
			}

		}

		/*-----------------------
		IF THE LAST GUY THAT ATTACKED IS A PLAYER, TARGET HIM NO MATTER WHERE HE IS
		-------------------------*/		
		if ( ( IsDefined( self.heli_lastattacker ) ) && ( IsPlayer( self.heli_lastattacker ) ) )
			self.eTarget = self.heli_lastattacker;


		/*-----------------------
		IF STILL NO VALID TARGET, GET AN ALTERNATE
		-------------------------*/		
		else if ( !heli_has_target() )
		{
			eTarget = self heli_get_target_ai_only();
			self.eTarget = eTarget;
		}

		/*-----------------------
		DON'T SHOOT IF IT'S NOT A VALID TARGET
		-------------------------*/	
		if ( !heli_has_target() )
			continue;

		/*-----------------------
		DON'T TRY TO SHOOT IF TARGET IN SAFE VOLUME
		-------------------------*/	
		if ( self.eTarget is_hidden_from_heli( self ) )
			continue;


		/*-----------------------
		DON'T TRY TO SHOOT IF TARGET OUT OF RANGE
		-------------------------*/	
		if ( ( heli_has_target() ) && ( DistanceSquared( self.eTarget.origin, self.origin ) > attackRangeSquared ) )
			continue;

		/*-----------------------
		MISS PLAYER INTENTIONALLY AT FIRST IF USING REGULAR TURRETS
		-------------------------*/	
		if ( ( self.turrettype == "default" ) && ( heli_has_player_target() ) )
		{
			//saw player, now miss for 2 bursts
			miss_player( self.eTarget );
			wait( RandomFloatRange( level._attackHeliRefire_min, level._attackHeliRefire_max ) );

			miss_player( self.eTarget );
			wait( RandomFloatRange( level._attackHeliRefire_min, level._attackHeliRefire_max ) );
			
			while ( can_see_player( self.eTarget ) && ( !self.eTarget is_hidden_from_heli( self ) ) )
			{
				fire_guns();
				wait( RandomFloatRange( 2.0, 4.0 ) );
			}
		}
		else
		{
			/*-----------------------
			FIRE AT TARGET
			-------------------------*/	
			//thread debug_message( "TARGET", undefined, 1, self.eTarget );
			if ( ( IsPlayer( self.eTarget ) ) || IsAI( self.eTarget ) )
				fire_guns();

			if ( IsPlayer( self.eTarget ) )
				thread player_grace_period( self );

			/*-----------------------
			WAIT A FEW MOMENTS TO REAQUIRE TARGETS (OR IMMEDIATELY IF BEING SHOT AT)
			-------------------------*/		
			//fRand = RandomFloatRange( 3, 5 );
			self waittill_notify_or_timeout( "damage_by_player", level._attackHeliTargetReaquire );
		}
	}
}

player_grace_period( eHeli )
{
	//if heli has been beating on the player, pick on someone else for this amt of time or until player attacks heli

	level notify( "player_is_heli_target" );
	level endon( "player_is_heli_target" );

	level._attackHeliGracePeriod = true;
	eHeli waittill_notify_or_timeout( "damage_by_player", level._attackHeliPlayerBreak );
	level._attackHeliGracePeriod = false;
}


heli_can_see_target()
{
	if ( !isdefined( self.eTarget ) )
		return false;
	org = self.eTarget.origin + ( 0, 0, 32 );
	if ( IsPlayer( self.eTarget ) )
		org = self.eTarget GetEye();

	tag_flash_loc = self GetTagOrigin( "tag_flash" );

	can_sight = SightTracePassed( tag_flash_loc, org, false, self );
	//can_see = BulletTracePassed( tag_flash_loc, org, false, self );
	//if( !can_see )
	//	thread draw_line_for_time( org, tag_flash_loc, 1, 0, 0, 1 );
	//if( !can_sight )
	//	thread draw_line_for_time( org, tag_flash_loc, 0, 1, 0, 1 );
	return can_sight;
}

heli_has_player_target()
{
	if ( !isdefined( self.eTarget ) )
		return false;
	if ( IsPlayer( self.eTarget ) )
		return true;
	else
		return false;
}

heli_has_target()
{
	if ( !isdefined( self.eTarget ) )
		return false;
	if ( !isalive( self.eTarget ) )
		return false;
	if ( self.eTarget == self.targetdefault )
		return false;
	else
		return true;
}

heli_get_target()
{

										//  getEnemyTarget( fRadius, iFOVcos, getAITargets, doSightTrace, getVehicleTargets, randomizeTargetArray, aExcluders )
	eTarget = maps\_helicopter_globals::getEnemyTarget( level._attackheliRange, level._attackHeliFOV, true, true, false, true, level._attackHeliExcluders );

	if ( ( IsDefined( eTarget ) ) && ( IsPlayer( eTarget ) ) )
		eTarget = self.targetdefault;
	if ( !isdefined( eTarget ) )
		eTarget = self.targetdefault;

	return eTarget;
}

heli_get_target_player_only()
{
	aExcluders = GetAIArray( "allies" );
									//  getEnemyTarget( fRadius, 			iFOVcos, 				getAITargets, doSightTrace, getVehicleTargets, randomizeTargetArray, aExcluders )
	eTarget = maps\_helicopter_globals::getEnemyTarget( level._attackheliRange, level._attackHeliFOV, true, false, false, false, aExcluders );


	if ( !isdefined( eTarget ) )
		eTarget = self.targetdefault;


	return eTarget;
}


heli_get_target_ai_only()
{

										//  getEnemyTarget( fRadius, iFOVcos, getAITargets, doSightTrace, getVehicleTargets, randomizeTargetArray, aExcluders )
	eTarget = maps\_helicopter_globals::getEnemyTarget( level._attackheliRange, level._attackHeliFOV, true, true, false, true, level._players );

	if ( !isdefined( eTarget ) )
		eTarget = self.targetdefault;

	return eTarget;
}



//heli_turret_think_old()
//{
//	self endon( "stop_shooting" );
//	self endon( "death" );
//	while ( true )
//	{
//		//choose our target based on distance and visibility
//		player = get_closest_player( self.origin );
//		if ( ! can_see_player( player ) )
//		{
//			dif_player = get_different_player( player );
//			if ( can_see_player( dif_player ) )
//				player = dif_player;
//		}
//		wait( RandomFloatRange( level._attackHeliRefire_min, level._attackHeliRefire_max ) );
//
//		// don't try to shoot a player with an RPG or Stinger
//		if ( player usingAntiAirWeapon() )
//			continue;
//
//		//dont try to shoot a player who is hiding a safe volume
//		if ( player is_hidden_from_heli( self ) )
//			continue;
//
//		//wait for player to be visible
//		while ( !can_see_player( player ) )
//			wait( RandomFloatRange( level._attackHeliRefire_min, level._attackHeliRefire_max ) );
//
//		/*-----------------------
//		MISS PLAYER INTENTIONALLY IF USING REGULAR TURRETS
//		-------------------------*/	
//		if ( self.turrettype == "default" )
//		{
//			//saw player, now miss for 2 bursts
//			miss_player( player );
//			wait( RandomFloatRange( level._attackHeliRefire_min, level._attackHeliRefire_max ) );
//	
//			miss_player( player );
//			wait( RandomFloatRange( level._attackHeliRefire_min, level._attackHeliRefire_max ) );
//		}
//
//		/*-----------------------
//		HIT PLAYER IF STILL EXPOSED
//		-------------------------*/	
//		while ( can_see_player( player ) && !player usingAntiAirWeapon() && !player is_hidden_from_heli( self ) )
//		{
//			fire_at_player( player );
//			wait( RandomFloatRange( 1.0, 2.0 ) );
//		}
//		
//		//player is hidden, now will suppress/hit him for 2 bursts if he tries to peek out
//		if ( !player usingAntiAirWeapon() && !player is_hidden_from_heli( self ) )
//			fire_at_player( player );
//		wait( RandomFloatRange( 1.0, 2.0 ) );
//
//		if ( !player usingAntiAirWeapon() && !player is_hidden_from_heli( self ) )
//			fire_at_player( player );
//	}
//}

heli_missiles_think()
{
	if ( !isdefined( self.script_missiles ) )
		return;

	self endon( "death" );
	self endon( "heli_players_dead" );
	self endon( "stop_shooting" );

	iShots = undefined;
	defaultWeapon = "turret_attackheli";
	weaponName = "missile_attackheli";
	weaponShootDelay  = undefined;
	loseTargetDelay  = undefined;
	tags = [];

	switch( self.vehicletype )
	{
		case "mi28":
			iShots = 1;
			weaponShootDelay = 1;
			loseTargetDelay  = 0.5;
			tags[ 0 ] = "tag_store_L_2_a";
			tags[ 1 ] = "tag_store_R_2_a";
			tags[ 2 ] = "tag_store_L_2_b";
			tags[ 3 ] = "tag_store_R_2_b";
			tags[ 4 ] = "tag_store_L_2_c";
			tags[ 5 ] = "tag_store_R_2_c";
			tags[ 6 ] = "tag_store_L_2_d";
			tags[ 7 ] = "tag_store_R_2_d";
			break;
		case "littlebird":
			iShots = 1;
			weaponShootDelay = 1;
			loseTargetDelay  = 0.5;
			tags[ 0 ] = "tag_missile_left";
			tags[ 1 ] = "tag_missile_right";
			break;
		default:
			AssertMsg( "Missiles have not been setup for helicoper model: " + self.vehicletype );
			break;
	}
	nextMissileTag = -1;

	while ( true )
	{
		wait( 0.05 );
		self waittill( "fire_missiles", other );
		if ( !isplayer( other ) )
			continue;

		player = other;
		if ( !player_is_good_missile_target( player ) )
			continue;
		for ( i = 0 ; i < iShots ; i++ )
		{
			nextMissileTag++;
			if ( nextMissileTag >= tags.size )
				nextMissileTag = 0;

			self SetVehWeapon( weaponName );
			self.firingMissiles = true;
			eMissile = self FireWeapon( tags[ nextMissileTag ], player );
			eMissile thread missileLoseTarget( loseTargetDelay );
			eMissile thread missile_earthquake();
			if ( i < iShots - 1 )
				wait weaponShootDelay;
		}
		self.firingMissiles = false;
		self SetVehWeapon( defaultWeapon );
		wait( 10 );
	}
}

player_is_good_missile_target( player )
{
	if ( self.moving )
		return false;
	else
		return true;
}

missile_earthquake()
{
	//does an earthquake when a missile hits and explodes
	if ( DistanceSquared( self.origin, level._player.origin ) > 9000000 )
		return;
	org = self.origin;
	while ( IsDefined( self ) )
	{
		org = self.origin;
		wait( 0.1 );
	}
	Earthquake( 0.7, 1.5, org, 1600 );
}

missileLoseTarget( fDelay )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	wait fDelay;
	if ( IsDefined( self ) )
		self Missile_ClearTarget();
}

get_different_player( player )
{
	for ( i = 0; i < level._players.size; i++ )
	{
		if ( player != level._players[ i ] )
			return level._players[ i ];
	}
	return level._players[ 0 ];
}

notify_disable()
{
	self notify( "notify_disable_thread" );
	self endon( "notify_disable_thread" );
	self endon( "death" );
	self endon( "heli_players_dead" );
	for ( ;; )
	{
		self waittill( "disable_turret" );
		self.allowShoot = false;
	}
}

notify_enable()
{
	self notify( "notify_enable_thread" );
	self endon( "notify_enable_thread" );
	self endon( "death" );
	self endon( "heli_players_dead" );
	for ( ;; )
	{
		self waittill( "enable_turret" );
		self.allowShoot = true;
	}
}

fire_guns()
{
	/*-----------------------
	FIRE MAIN TURRET OR MINIGUNS
	-------------------------*/	
	switch( self.turrettype )
	{
		//regular default turret
		case "default":
			burstsize = RandomIntRange( 5, 10 );
			fireTime = WeaponFireTime( "turret_attackheli" );
			self turret_default_fire( self.eTarget, burstsize, fireTime );
			break;
		case "miniguns":
			burstsize = getburstsize( self.eTarget );
			if ( ( self.allowShoot ) && ( !self.firingMissiles ) )
				self turret_minigun_fire( self.eTarget, burstsize );
			break;
		default:
			AssertMsg( "Gun firing logic has not been set up in the _attack_heli.gsc script for helicopter type: " + self.turrettype );
			break;
	}
}

getburstsize( eTarget )
{
	burstsize = undefined;
	if ( !isplayer( eTarget ) )
	{
		burstsize = level._attackHeliAIburstSize;
		return burstsize;
	}

	switch( level._gameSkill )
	{
		case 0:// easy
		case 1:// regular
		case 2:// hardened
		case 3:// veteran
			burstsize = RandomIntRange( 2, 3 );
			break;
	}
	return burstsize;
}

fire_missiles( fDelay )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	wait( fDelay );
	if ( !isplayer( self.eTarget ) )
		return;
	self notify( "fire_missiles", self.eTarget );
}

turret_default_fire( eTarget, burstsize, fireTime )
{
	self thread fire_missiles( RandomFloatRange( .2, 2 ) );

	if ( isdefined( self._attack_heli_custom_firing_func ) )
	{
		[[ self._attack_heli_custom_firing_func ]]( eTarget, burstsize, fireTime );
		return;
	}

	/*-----------------------
	DEFAULT MAIN TURRET OF MOST CHOPPERS
	-------------------------*/	
	for ( i = 0; i < burstsize; i++ )
	{
		if ( !IsAlive( eTarget ) )
		{
			return;
		}

		self SetTurretTargetEnt( eTarget, randomvector( 50 ) + ( 0, 0, 32 ) );
		//self SetTurretTargetEnt( eTarget, ( 0, 0, 32 ) );
		if ( ( self.allowShoot ) && ( !self.firingMissiles ) )
		{
			self FireWeapon();
		}
		wait fireTime;
	}
}

/*
=============
///ScriptDocBegin
"Name: turret_minigun_fire( <eTarget>, <burstsize>, <max_warmup_time> )"
"Summary: Fires minigun turrets mounted on a vehicle (such as dual miniguns of the Littlebird). Will play appropriate spin up and spin down sounds"
"Module: Vehicle"
"MandatoryArg: <eTarget>: Target entity to fire at"
"OptionalArg: <burstsize>: Length of time to fire the guns"
"OptionalArg: <delay>: Delay between multiple missiles fired. Defaults to one second"
"OptionalArg: <max_warmup_time>: Max random delay before it begins firing"
"Example: eHeli thread maps\_attack_heli::turret_minigun_fire( eTarget, 10 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
turret_minigun_fire( eTarget, burstsize, max_warmup_time )
{
	/*-----------------------
	DUAL MINIGUNS (FOR LITTLEBIRDS)
	-------------------------*/	
	self endon( "death" );
	self endon( "heli_players_dead" );
	self notify( "firing_miniguns" );
	self endon( "firing_miniguns" );

	turrets = self get_turrets();
	array_thread( turrets, ::turret_minigun_target_track, eTarget, self );
	if ( !self.minigunsspinning )
	{
		self.firingguns = true;
		self thread play_sound_on_tag( "littlebird_gatling_spinup", "tag_flash" );
		wait( 2.1 );
		self thread play_loop_sound_on_tag( "littlebird_minigun_spinloop", "tag_flash" );
	}

	self.minigunsspinning = true;

	if ( !isdefined( max_warmup_time ) )
		max_warmup_time = 3;

	min_warmup_time = 0.5;
	if ( min_warmup_time > max_warmup_time )
	{
		min_warmup_time = max_warmup_time;
	}

	if ( min_warmup_time > 0 )
	{
		wait( RandomFloatRange( min_warmup_time, max_warmup_time ) );
	}


	minigun_fire( eTarget, burstsize );
	turrets = self get_turrets();
	array_call( turrets, ::StopFiring );
//	array_thread( turrets, ::send_notify, "turretstatechange" );

	self thread minigun_spindown( eTarget );
	self notify( "stopping_firing" );
}

minigun_fire( eTarget, burstsize )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	if ( IsPlayer( eTarget ) )
		self endon( "cant_see_player" );

	turrets = self get_turrets();
	array_call( turrets, ::StartFiring );
//	array_thread( turrets, ::send_notify, "turretstatechange" );

	wait( RandomFloatRange( 1, 2 ) );

	if ( IsPlayer( eTarget ) )
		self thread target_track( eTarget );

	if ( IsPlayer( eTarget ) )
	{
		fRand = RandomFloatRange( .5, 3 );
		self thread fire_missiles( fRand );
	}

	wait( burstsize );
}



target_track( eTarget )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	self endon( "stopping_firing" );
	self notify( "tracking_player" );
	self endon( "tracking_player" );
	while ( true )
	{
		if ( !can_see_player( eTarget ) )
			break;
		wait( .5 );
	}
	wait level._attackHeliTimeout;
	self notify( "cant_see_player" );
}

turret_minigun_target_track( eTarget, eHeli )
{
	//self ==> individual minigun turret
	eHeli endon( "death" );
	eHeli endon( "heli_players_dead" );
	self notify( "miniguns_have_new_target" );
	self endon( "miniguns_have_new_target" );

	//If it's an AI, shoot 100 units above his origin unless scripted wants otherwise
	if ( ( !isPlayer( eTarget ) ) && ( IsAI( eTarget ) ) && ( level._attackHeliKillsAI == false ) )
	{
		eFake_AI_Target = Spawn( "script_origin", eTarget.origin + ( 0, 0, 100 ) );
		eFake_AI_Target LinkTo( eTarget );
		self thread minigun_AI_target_cleanup( eFake_AI_Target );
		eTarget = eFake_AI_Target;
	}
	while ( true )
	{
		wait( .5 );
		self SetTargetEntity( eTarget );
	}
}

//used to delete the fake target the AI has over his head when heli miniguns find a new target
minigun_AI_target_cleanup( eFake_AI_Target )
{
	self waittill_either( "death", "miniguns_have_new_target" );
	eFake_AI_Target Delete();
}

minigun_spindown( eTarget )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	self endon( "firing_miniguns" );
	if ( IsPlayer( eTarget ) )
		wait( RandomFloatRange( 3, 4 ) );		// if player is the target, wait a few seconds before giving up
	else
		wait( RandomFloatRange( 1, 2 ) );
	self thread minigun_spindown_sound();
	self.firingguns = false;
}

minigun_spindown_sound()
{
	self notify( "stop sound" + "littlebird_minigun_spinloop" );
	self.minigunsspinning = false;
	self play_sound_on_tag( "littlebird_gatling_cooldown", "tag_flash" );
}

miss_player( player )
{
	//for default turret types to allow the player to hide before getting owned

	PrintLn( "_attack_heli.gsc           missing player" );

	//right = AnglesToRight( self.angles );
	//miss_vec = vector_multiply( right, RandomIntRange( 128, 256 ) );
	//miss_vec = vector_multiply( right, RandomIntRange( 64, 128 ) );
	//if ( RandomInt( 2 ) == 0 )
	//	miss_vec *= -1;

	//point between player and heli
	//vec = VectorNormalize( self.origin - level.player.origin );
	//forward = vector_multiply( vec, 400 );
	//miss_vec = forward + ( 0, 0, -128 ) + randomvector( 50 );

	// Safety checks
	if ( !IsAlive( player ) || !IsDefined( player ) )
	{
		return;
	}

	if ( self.turrettype == "nx_miniuav_rifle" )
	{
		burstsize = RandomIntRange( 10, 20 );
		fireTime = WeaponFireTime( "nx_miniuav_rifle" );

		forward_mult = Distance( self.origin, player.origin ) / 2.0;

		if ( forward_mult > 400 )
		{
			forward_mult = 400;
		}
	}
	else if ( self.turrettype == "nx_chinese_skimmer_weap" )
	{
		burstsize = RandomIntRange( 1, 4 );
		fireTime = WeaponFireTime( "nx_chinese_skimmer_weap" );

		forward_mult = Distance( self.origin, player.origin ) / 2.0;

		if ( forward_mult > 400 )
		{
			forward_mult = 400;
		}
	}
	else
	{
		burstsize = RandomIntRange( 10, 20 );
		fireTime = WeaponFireTime( "turret_attackheli" );

		forward_mult = 400;
	}

	//point in front of player
	forward = AnglesToForward( player.angles );
	forwardfar = vector_multiply( forward, forward_mult );

	if ( isdefined( self._attack_heli_custom_miss_func ) )
	{
		[[ self._attack_heli_custom_miss_func ]]( player, burstsize, fireTime, forwardfar );
		return;
	}

	for ( i = 0; i < burstsize; i++ )
	{
		//debug_org = ( player.origin + miss_vec );
		//thread draw_line_for_time( debug_org, debug_org + ( 0, 0, 10 ), 1, 0, 0, 5.0 );

		if ( !IsAlive( player ) )
		{
			return;
		}

		miss_vec = forwardfar + randomvector( 50 );

		self SetTurretTargetEnt( player, miss_vec );

		if ( self.allowShoot )
		{
			if ( self.vehicletype == "nx_miniuav" || self.vehicletype == "nx_chinese_skimmer" )
			{
				self FireWeapon( "TAG_FLASH" );
				self FireWeapon( "TAG_FLASH2" );
			}
			else
			{
				self FireWeapon();
			}
		}

		wait fireTime;
	}
}

can_see_player( player )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	tag_flash_loc = self GetTagOrigin( "tag_flash" );
	//BulletTracePassed( <start>, <end>, <hit characters>, <ignore entity> );

	pos = ( 0, 0, 0 );
	if ( IsPlayer( player ) )
	{
		pos = player GetEye();
	}
	else
	{
		pos = player.origin;
	}

	if ( SightTracePassed( tag_flash_loc, pos, false, self ) )
		return true;
	else
	{
		PrintLn( "_attack_heli.gsc        ---trace failed" );
		return false;
	}
}

get_linked_points( heli, goal, points, player, playerOrigin )
{
	/*-----------------------
	GET ALL LINKED POINTS FROM GURRENT GOAL
	-------------------------*/	
	linked = [];
	tokens = StrTok( goal.script_linkto, " " );
	for ( i = 0; i < points.size; i++ )
	{
		for ( j = 0; j < tokens.size; j++ )
		{
			if ( points[ i ].script_linkName == tokens[ j ] )
				linked[ linked.size ] = points[ i ];
		}
	}

	/*-----------------------
	REMOVE ANY POINTS THAT ARE INVALID
	-------------------------*/	
	foreach ( point in linked )
	{
		//remove potential hover point if it is physically below the player
		if ( point.origin[ 2 ] < playerOrigin[ 2 ] )
		{
			linked = array_remove( linked, point );
			continue;
		}

	}

	return linked;
}

heli_damage_monitor()
{
	if ( !getDvarInt( "scr_damagefeedback", 0 ) )
		damage_feedback = false;
	else
		damage_feedback = true;

	self endon( "death" );
	self endon( "heli_players_dead" );
	self endon( "crashing" );
	self endon( "leaving" );

	self.damagetaken = 0;
	self.seen_attacker = undefined;

	for ( ;; )
	{
		// this damage is done to self.health which isnt used to determine the helicopter's health, damageTaken is.
		self waittill( "damage", damage, attacker, direction_vec, P, type );

		if ( !isdefined( attacker ) || !isplayer( attacker ) )
			continue;

		self notify( "damage_by_player" );
		self thread heli_damage_update();
		self thread can_see_attacker_for_a_bit( attacker );
		if ( damage_feedback )
			attacker thread updateDamageFeedback();
	}
}

heli_damage_update()
{
	self notify( "taking damage" );
	self endon( "taking damage" );
	self endon( "death" );
	self endon( "heli_players_dead" );
	self.isTakingDamage = true;
	wait( 1 );
	self.isTakingDamage = false;
}


can_see_attacker_for_a_bit( attacker )
{
	self notify( "attacker_seen" );
	self endon( "attacker_seen" );
	self.seen_attacker = attacker;

	/*-----------------------
	HELI REMEMBERS THE PLAYER WHO DAMAGED HIM FOR A FEW SECONDS
	-------------------------*/	
	self.heli_lastattacker = attacker;
	wait level._attackHeliMemory;
	self.heli_lastattacker = undefined;

	self.seen_attacker = undefined;
}

is_hidden_from_heli( heli )
{
	if ( IsDefined( heli.seen_attacker ) )
		if ( heli.seen_attacker == self )
			return false;
	if ( IsDefined( level._attack_heli_safe_volumes ) )
	{
		foreach ( volume in level._attack_heli_safe_volumes )
			if ( self IsTouching( volume ) )
				return true;
	}
	return false;
}

updateDamageFeedback()
{
	if ( !isPlayer( self ) )
		return;

	self.hud_damagefeedback SetShader( "damage_feedback", 24, 48 );
	self PlayLocalSound( "player_feedback_hit_alert" );

	self.hud_damagefeedback.alpha = 1;
	self.hud_damagefeedback FadeOverTime( 1 );
	self.hud_damagefeedback.alpha = 0;
}

damage_feedback_setup()
{
	for ( i = 0; i < level._players.size; i++ )
	{
		player = level._players[ i ];
		player.hud_damagefeedback = NewClientHudElem( player );
		player.hud_damagefeedback.horzAlign = "center";
		player.hud_damagefeedback.vertAlign = "middle";
		player.hud_damagefeedback.x = -12;
		player.hud_damagefeedback.y = -12;
		player.hud_damagefeedback.alpha = 0;
		player.hud_damagefeedback.archived = true;
		player.hud_damagefeedback SetShader( "damage_feedback", 24, 48 );
	}
}

heli_death_monitor()
{
	self waittill( "death" );
	level notify( "attack_heli_destroyed" );
	level._enemy_heli_killed = true;
	wait 15;
	level._enemy_heli_attacking = false;
}

dialog_nags_heli( heli )
{
	heli endon( "death" );
	heli endon( "heli_players_dead" );
	wait 30;

	if ( ! level._enemy_heli_attacking )
		return;

	commander_dialog( "co_cf_cmd_heli_small_fire" );
	//"That heli is vulnerable to small arms fire." 

	if ( ! level._enemy_heli_attacking )
		return;

	commander_dialog( "co_cf_cmd_rpg_stinger" );
	//"Otherwise look for an RPG or Stinger." 

	wait 30;

	if ( ! level._enemy_heli_attacking )
		return;
	commander_dialog( "co_cf_cmd_heli_wonders" );
	//"Charlie Four, an RPG or Stinger would do wonders against that heli." 
}

commander_dialog( dialog_line )
{
	while ( level._commander_speaking )
		wait 1;

	level._commander_speaking = true;
	level._player PlaySound( dialog_line, "sounddone" );
	level._player waittill( "sounddone" );
	wait .5;
	level._commander_speaking = false;
}

usingAntiAirWeapon()
{
	weapon = self GetCurrentWeapon();

	if ( !isdefined( weapon ) )
		return false;

	if ( IsSubStr( ToLower( weapon ), "rpg" ) )
		return true;

	if ( IsSubStr( ToLower( weapon ), "stinger" ) )
		return true;

	if ( IsSubStr( ToLower( weapon ), "at4" ) )
		return true;

	return false;
}


heli_spotlight_cleanup( sTag )
{
	self waittill_any( "death", "crash_done", "turn_off_spotlight" );
	self.spotlight = undefined;

	if ( IsDefined( self ) )
	{
		if ( IsDefined( level._spotlight_fx_stop_script ) )
		{
			[[level._spotlight_fx_stop_script]]();
		}
		else
		{
			StopFXOnTag( getfx( "_attack_heli_spotlight" ), self, sTag );
		}
	}
}

heli_spotlight_aim( spotlight_think_script )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	/*-----------------------
	HELI SPOTLIGHT AIMING LOGIC
	-------------------------*/	

	if ( self.vehicletype != "littlebird" )// no need to aim...default gun turret will handle aiming at it's target
		return;

	self thread heli_spotlight_think( spotlight_think_script );

	eSpotlightTarget = undefined;
	while ( true )
	{
		wait( .05 );
		switch( self.vehicletype )
		{
			case "littlebird":	// littlebird doesn't use its turret to shoot...only to point spotlight
				eSpotlightTarget = self.spotTarget;// have it point at any of the default targets so it scans, or sometimes the player
				break;
			default:		// no choice for most other helis since the spotlight is attached to the actual turret
				eSpotlightTarget = self.eTarget;
				break;
		}
		if ( IsDefined( eSpotlightTarget ) )
			self SetTurretTargetEnt( eSpotlightTarget, ( 0, 0, 0 ) );
	}
}

heli_spotlight_create_default_targets( default_target )
{
	self endon( "death" );
	self endon( "heli_players_dead" );

	original_ent = self.targetdefault;
	if ( IsDefined( default_target ) )
	{
		original_ent = default_target;
	}

	original_ent.targetname = "original_ent";

	self.left_ent = Spawn( "script_origin", original_ent.origin );
	self.left_ent.origin = original_ent.origin;
	self.left_ent.angles = original_ent.angles;
	self.left_ent.targetname = "left_ent";

	self.right_ent = Spawn( "script_origin", original_ent.origin );
	self.right_ent.origin = original_ent.origin;
	self.right_ent.angles = original_ent.angles;
	self.right_ent.targetname = "right_ent";


	ent = SpawnStruct();
	ent.entity = self.left_ent;
	ent.right = 250;
	ent translate_local();
	self.left_ent LinkTo( self );

	ent2 = SpawnStruct();
	ent2.entity = self.right_ent;
	ent2.right = -250;
	ent2 translate_local();
	self.right_ent LinkTo( self );

	aim_ents = [];
	aim_ents[ 0 ] = original_ent;
	aim_ents[ 1 ] = self.left_ent;
	aim_ents[ 2 ] = self.right_ent;

	level._spotlight_aim_ents = aim_ents;

	//foreach ( ent in aim_ents )
		//thread debug_message( ent.targetname, undefined, 9999, ent );

	self.spotTarget = original_ent;
}

heli_spotlight_destroy_default_targets()
{
	foreach ( aim_ent in level._spotlight_aim_ents )
	{
		if ( IsDefined( aim_ent ) )
		{
			aim_ent delete();
		}
	}
}

heli_spotlight_think( spotlight_think_script )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	
	self heli_spotlight_create_default_targets();

	array_thread( level._spotlight_aim_ents, ::heli_spotlight_aim_ents_cleanup, self );

	if ( IsDefined( spotlight_think_script ) )
	{
		self thread [[spotlight_think_script]]();
	}
	else
	{
		while ( true )
		{
			wait( RandomFloatRange( 1, 3 ) );
	
			//shine on the player if the heli is currently targeting the player and player is not looking at the heli
			if	( ( heli_has_player_target() ) && ( !self within_player_fov() ) )
			{
				self.spotTarget = self.eTarget;
			}
			else// otherwise just aim at one of the default targets
			{
				iRand = RandomInt( level._spotlight_aim_ents.size );
				self.targetdefault = level._spotlight_aim_ents[ iRand ];
				self.spotTarget = self.targetdefault;
	
			}
		}
	}
}

within_player_fov()
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	if ( !isdefined( self.eTarget ) )
		return false;
	if ( !isPlayer( self.eTarget ) )
		return false;
	player = self.eTarget;
	bInFOV = within_fov( player GetEye(), player GetPlayerAngles(), self.origin, level._cosine[ "35" ] );
	return bInFOV;
}

heli_spotlight_aim_ents_cleanup( eHeli )
{
	eHeli waittill_either( "death", "crash_done" );
	if ( IsDefined( self ) )
		self Delete();
}

littlebird_turrets_think( eHeli )
{
	//"self ==> each of the attached minigun turrets
	eTurret = self;
	eTurret turret_set_default_on_mode( "manual" );
	if ( IsDefined( eHeli.targetdefault ) )
		eTurret SetTargetEntity( eHeli.targetdefault );

	eTurret SetMode( "manual" );

	//clean up minigun sound in case it was firing while getting killed
	eHeli waittill( "death" );
	if ( ( IsDefined( eHeli.firingguns ) ) && ( eHeli.firingguns == true ) )
		self thread minigun_spindown_sound();

}

attack_heli_cleanup()
{
	self waittill_either( "death", "crash_done" );
	if ( IsDefined( self.attractor ) )
		Missile_DeleteAttractor( self.attractor );

	if ( IsDefined( self.attractor2 ) )
		Missile_DeleteAttractor( self.attractor2 );
}

/*
=============
///ScriptDocBegin
"Name: heli_default_missiles_on()"
"Summary: Call this on a spawned heli to fire missiles at any nodes that are linked(with script_linkTo)"
"OptionalArg: <customMissiles>: Pass in a custom missile name to use. Otherwise will default to missile_attackheli"
"Module: Vehicle"
"Example: self thread maps\_attack_heli::heli_default_missiles_on();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
heli_default_missiles_on( customMissiles )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	self endon( "stop_default_heli_missiles" );
	self.preferredTarget = undefined;
	while ( IsDefined( self ) )
	{
		wait( 0.05 );
		eTarget = undefined;
		iShots = undefined;
		delay = undefined;
		self.preferredTarget = undefined;
		eNextNode = undefined;

		/*-----------------------
		SEE IF THERE IS A NEXT NODE IN CHAIN
		-------------------------*/				
		if ( ( IsDefined( self.currentnode ) ) && ( IsDefined( self.currentnode.target ) ) )
			eNextNode = getent_or_struct( self.currentnode.target, "targetname" );

		/*-----------------------
		CHECK IF NEXT NODE HAS ANY PREFERRED TARGETS
		-------------------------*/		
		if ( ( IsDefined( eNextNode ) ) && ( IsDefined( eNextNode.script_linkTo ) ) )
			self.preferredTarget = getent_or_struct( eNextNode.script_linkTo, "script_linkname" );

		if ( IsDefined( self.preferredTarget ) )
		{
			eTarget = self.preferredTarget;
			iShots = eTarget.script_shotcount;
			delay = eTarget.script_delay;
			eNextNode waittill( "trigger" );
		}
		else
			self waittill_any( "near_goal", "goal" );

		/*-----------------------
		FIRE MISSILES IF I HAVE A GOOD TARGET
		-------------------------*/		
		if ( IsDefined( eTarget ) )
		{
			self thread heli_fire_missiles( eTarget, iShots, delay, customMissiles );
		}

	}
}

/*
=============
///ScriptDocBegin
"Name: heli_default_missiles_off()"
"Summary: Call this on a spawned heli to stop firing missiles at linked nodes"
"Module: Vehicle"
"Example: self thread maps\_attack_heli::heli_default_missiles_off();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
heli_default_missiles_off()
{
	self notify( "stop_default_heli_missiles" );
}



/*
=============
///ScriptDocBegin
"Name: heli_spotlight_on( <sTag>, <bUseAttackHeliBehavior> )"
"Summary: Turns on a spotlight on a helicopter. The spotlight is not aimed anywhere unless you are using the AI in the _attack_heli script and setting bUseAttackHeliBehavior to true"
"Module: Vehicle"
"OptionalArg: <sTag>: Specify the tag where the spotlight will attach to (tag_barrel is the default so that any turret aiming logic will aim the spotlight as well)"
"OptionalArg: <bUseAttackHeliBehavior>: Only set this to true if you are using the AI behavior in the _attack_heli script"
"OptionalArg: <geneicPlayerLock>: Simply locks onto the player."
"Example: attack_heli thread maps\_attack_heli::heli_spotlight_on();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
heli_spotlight_on( sTag, bUseAttackHeliBehavior, genericPlayerLock )
{
	if ( !isdefined( sTag ) )
		sTag = "tag_barrel";
	if ( !isdefined( bUseAttackHeliBehavior ) )
		bUseAttackHeliBehavior = false;

	if ( !isdefined( genericPlayerLock ))
	{
		genericPlayerLock = false;
	}
	
	if ( IsDefined( level._spotlight_fx_script ) )
	{
		[[level._spotlight_fx_script]]();
	}
	else
	{
		PlayFXOnTag( getfx( "_attack_heli_spotlight" ), self, sTag );
	}

	self.spotlight = 1;
	self thread heli_spotlight_cleanup( sTag );

	if ( genericPlayerLock )
	{
		self SetTurretTargetEnt( level._player );
	}
	else if ( bUseAttackHeliBehavior )
	{
		//give the turret/spotlight an initial target
		self endon( "death" );
		self endon( "heli_players_dead" );
		spawn_origin = self GetTagOrigin( "tag_origin" );

		if ( !isdefined( self.targetdefault ) )
			self heli_default_target_setup();
		self SetTurretTargetEnt( self.targetdefault );
		self thread heli_spotlight_aim();
	}
}

/*
=============
///ScriptDocBegin
"Name: heli_spotlight_off()"
"Summary: Turns off a spotlight on a helicopter that had it turned on with the heli_spotlight_on() function"
"Module: Vehicle"
"Example: eHeli thread maps\_attack_heli::heli_spotlight_off();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
heli_spotlight_off()
{
	self notify( "turn_off_spotlight" );
}


/*
=============
///ScriptDocBegin
"Name: heli_spotlight_random_targets_on()"
"Summary: Aims the helicopter turret randomly in a sweeping motion in front of the heli. Must first turn on the spotlight effect with heli_spotlight_on()"
"Module: Vehicle"
"Example: eHeli thread maps\_attack_heli::heli_spotlight_random_targets_on();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
heli_spotlight_random_targets_on()
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	self endon( "stop_spotlight_random_targets" );
	//setup default targets
	if ( !isdefined( self.targetdefault ) )
		self thread heli_default_target_setup();	// gives the heli an "self.targetdefault" right in front of its nose

	if ( !isdefined( self.left_ent ) )
		self thread heli_spotlight_think();			// spawns 2 more attached script_origins on the left and right and
												//and randomly makes one of the three the heli's "self.targetdefault"

	while ( IsDefined( self ) )
	{
		wait( .05 );
		self SetTurretTargetEnt( self.targetdefault, ( 0, 0, 0 ) );
	}
}

/*
=============
///ScriptDocBegin
"Name: heli_spotlight_random_targets_off()"
"Summary: Stopss the helicopter turret randomly aiming turret in a sweeping motion in front of the heli()"
"Module: Vehicle"
"Example: eHeli thread maps\_attack_heli::heli_spotlight_random_targets_off();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
heli_spotlight_random_targets_off()
{
	self notify( "stop_spotlight_random_targets" );
}


/*
=============
///ScriptDocBegin
"Name: heli_fire_missiles( <eTarget>, <iShots>, <delay> )"
"Summary: Fires missiles from a helicopter at a target"
"Module: Vehicle"
"MandatoryArg: <eTarget>: Target entity to fire at"
"OptionalArg: <iShots>: Number of missiles to fire 9default = 1)."
"OptionalArg: <delay>: Delay between multiple missiles fired. Defaults to one second"
"OptionalArg: <customMissiles>: Pass in a custom missile to use. Otherwise will default to missile_attackheli"
"Example: eHeli thread maps\_attack_heli::heli_fire_missiles( eTarget, 2, .5 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
heli_fire_missiles( eTarget, iShots, delay, customMissiles )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	if ( IsDefined( self.defaultWeapon ) )
		defaultWeapon = self.defaultWeapon;
	else
		defaultWeapon = "turret_attackheli";
	weaponName = "missile_attackheli";
	if ( isdefined( customMissiles ) )
		weaponName = customMissiles;
	loseTargetDelay  = undefined;
	tags = [];
	self SetVehWeapon( defaultWeapon );
	if ( !isdefined( iShots ) )
		iShots = 1;
	if ( !isdefined( delay ) )
		delay = 1;
	
	//if the target is a struct, need to spawn a dummy ent to fire at
	if ( !isdefined( eTarget.classname ) )
	{
		if ( !isdefined( self.dummyTarget) )
		{
			self.dummyTarget = Spawn( "script_origin", eTarget.origin );
			self thread delete_on_death( self.dummyTarget );
		}
		self.dummyTarget.origin = eTarget.origin;
		eTarget = self.dummyTarget;
	}
	
	switch( self.vehicletype )
	{
		case "mi28":
			loseTargetDelay  = 0.5;
			tags[ 0 ] = "tag_store_L_2_a";
			tags[ 1 ] = "tag_store_R_2_a";
			tags[ 2 ] = "tag_store_L_2_b";
			tags[ 3 ] = "tag_store_R_2_b";
			tags[ 4 ] = "tag_store_L_2_c";
			tags[ 5 ] = "tag_store_R_2_c";
			tags[ 6 ] = "tag_store_L_2_d";
			tags[ 7 ] = "tag_store_R_2_d";
			break;
		case "littlebird":
			loseTargetDelay  = 0.5;
			tags[ 0 ] = "tag_missile_left";
			tags[ 1 ] = "tag_missile_right";
			break;
		default:
			AssertMsg( "Missiles have not been setup for helicoper model: " + self.vehicletype );
			break;
	}
	nextMissileTag = -1;

	for ( i = 0 ; i < iShots ; i++ )
	{
		nextMissileTag++;
		if ( nextMissileTag >= tags.size )
			nextMissileTag = 0;

		self SetVehWeapon( weaponName );
		self.firingMissiles = true;
		eMissile = self FireWeapon( tags[ nextMissileTag ], eTarget );
		//eMissile thread missileLoseTarget( loseTargetDelay );
		eMissile thread missile_earthquake();
		if ( i < iShots - 1 )
			wait delay;
	}
	self.firingMissiles = false;
	self SetVehWeapon( defaultWeapon );

}

boneyard_style_heli_missile_attack()
{
	self waittill( "trigger", vehicle );
	struct_arr = getstructarray( self.target, "targetname" );
	struct_arr = array_index_by_script_index( struct_arr );
	
	boneyard_fire_at_targets( vehicle, struct_arr );
}

boneyard_style_heli_missile_attack_linked()
{
	self waittill( "trigger", vehicle );
	
	struct_arr = self get_linked_structs();
	struct_arr = array_index_by_script_index( struct_arr );
	
	boneyard_fire_at_targets( vehicle, struct_arr );
}

boneyard_fire_at_targets( vehicle, struct_arr )
{
	tags = [];
	tags[ 0 ] = "tag_missile_right";
	tags[ 1 ] = "tag_missile_left";
	
	if ( level._script == "roadkill" )
	{
		// apaches use insane tag names. It's like a weird form of binary.
		tags[ 0 ] = "tag_flash_2"; // 2 means right
		tags[ 1 ] = "tag_flash_11"; // 11 means left ><
	}

	if ( vehicle.vehicletype == "cobra" )
	{
		tags[ 0 ] = "tag_store_L_1_a";
		tags[ 1 ] = "tag_store_R_1_a";
	}

	ents = [];

	for ( i = 0; i < struct_arr.size; i++ )
	{
		AssertEx( IsDefined( struct_arr[ i ] ), "boneyard_style_heli_missile_attack requires script_index key/value to start at 0 and not have any gaps." );

		ents[ i ] = Spawn( "script_origin", struct_arr[ i ].origin );

		vehicle SetVehWeapon( "littlebird_FFAR" );
		vehicle SetTurretTargetEnt( ents[ i ] );
		missile = vehicle FireWeapon( tags[ i % tags.size ], ents[ i ], ( 0, 0, 0 ) );

		missile delayCall( 1, ::Missile_ClearTarget );

		wait RandomFloatRange( 0.2, 0.3 );
	}

	wait 2;
	foreach ( ent in ents )
	{
		ent Delete();
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
// If type is circling, then this function expects circle nodes as well
// If type is notifying/searching, then this function expects circling nodes & search nodes
SAV_setup( behavior_type, circle_nodes, search_nodes, sight_distance, spawn_func )
{
	// tagBR< note >: I'm not exactly sure why I needed to put this here, all I know is
	// that level.gameskill was not getting defined soon enough before _attack_heli::init() 
	// is called, and so the heli's were not getting inited before running logic below...
	while ( !isdefined( level._attackheliRange ) )
	{
		wait( 0.05 );
	}

	// If setup is being run on a spawner, then spawn the SAV vehicle
	if ( IsSpawner( self ) )
	{
		// Much like actors, SAV shouldn't spawn if the player can see the spawnpoint
		if ( !IsDefined( self.script_forcespawn ) )
		{
			if ( SightTracePassed( level._player GetEye(), self.origin, false, undefined ) )
			{
				println( "^3Warning: SAV spawn at " + self.origin + " failed because player can see spawnpoint.\n" );
				return undefined;
			}
		}

		heli = self spawn_vehicle();

		// These are variables that can be defined on the spawner in Radiant to automate spawning
		if ( IsDefined( self.script_behaviortype ) )
		{
			behavior_type = self.script_behaviortype;
		}

		if ( IsDefined( self.script_circlenodes ) )
		{
			circle_nodes = self.script_circlenodes;
		}
		else if ( IsDefined( self.target ) )
		{
			circle_nodes = self.target;
		}

		if ( IsDefined( self.script_searchnodes ) )
		{
			search_nodes = self.script_searchnodes;
		}

		if ( IsDefined( self.script_sightdist ) )
		{
			sight_distance = self.script_sightdist;
		}
		
		// set up aditional radiant variables
		if( IsDefined( self.script_baseaccuracy ) )
			heli.baseaccuracy = self.script_baseaccuracy;
		if( IsDefined( self.script_ignoreme ) )
			heli.ignoreme = self.script_ignoreme;
		if( IsDefined( self.script_startinghealth ) )
			heli.health = self.script_startinghealth;
		if( IsDefined( self.script_threatbias ) )
			heli.threatbias = self.script_threatbias;
	}
	else
	{
		heli = self;
	}

	heli thread makesentient( self.script_team );

	// Set up threatbias stuff
	heli setthreatbiasgroup( "axis" );

	// Turn on aim-assist
	heli EnableAimAssist();
	heli setCanDamage( true );

	heli thread heli_default_target_setup();
	heli.behavior_type = behavior_type;
	heli set_heli_move( "instant" ); // <-- This sets yaw speed very high

	// Set up turret type
	if ( IsDefined( heli._SAV_turret_type ) )
	{
		heli.turrettype = heli._SAV_turret_type;
	}
	else
	{
		heli.turrettype = "turret_attackheli";
	}

	// Call our custom spawn func
	if ( isdefined( spawn_func ) )
	{
		heli [[spawn_func]]();
	}

	switch( behavior_type )
	{
		case "pathing_shooting":
			heli.allowShoot = true;
			heli.firingMissiles = false;
			heli thread SAV_shoot_think();
			// Deliberate fall-through
		case "pathing":
			heli SetTurningAbility( 1.0 ); // <-- This makes turning sharper
			thread gopath( heli );
			break;
		case "attacking":
			thread gopath( heli );
			begin_attack_heli_behavior( heli, undefined, ::SAV_shoot_think );
			break;
		case "circling":
			if ( !IsDefined( circle_nodes ) )
			{
				AssertMsg( "'circle_nodes' parameter required for 'circling' SAV in _attack_heli/SAV_setup()" );
			}

			// This allows for not having to set node targets in Radiant
			if ( !IsDefined( self.target ) )
			{
				self.target = circle_nodes;
			}

			// tagJW< note >: SAV does not follow initial path since it is linked to uav_circle nodes
			heli.dontWaitForPathEnd = true;

			heli thread detect_player_death();

			heli = start_circling_SAV( self.targetname, circle_nodes, heli );
			break;
		case "searching":
		case "notifying":
			if ( !IsDefined( circle_nodes ) )
			{
				AssertMsg( "'circle_nodes' parameter required for 'searching' & 'notifying' SAV in _attack_heli/SAV_setup()" );
			}

			if ( !IsDefined( search_nodes ) )
			{
				AssertMsg( "'search_nodes' parameter required for 'searching' & 'notifying' SAV in _attack_heli/SAV_setup()" );
			}

			heli.state = "move";
			heli.circle_nodes = circle_nodes;
			heli.search_nodes = search_nodes;
			heli.SAV_using_search_pos = false;

			if( !IsDefined( sight_distance ) )
			{
				sight_distance = 500;
			}
			heli.sight_distance = sight_distance;

			heli process_heli_sight_nodes( search_nodes );
			heli process_sight_nodes( search_nodes );

			if ( IsDefined( heli._SAV_searching_script ) )
			{
				heli thread [[heli._SAV_searching_script]]();
			}			
			break;
		default:
			AssertMsg( "Need to specify a behavior type for _attack_heli/SAV_setup()" );
			break;
	}

	// This sets up the entire vehicle death system
	heli thread maps\_vehicle::vehicle_kill();

	if ( IsDefined( heli._SAV_damage_script ) )
	{
		heli thread [[heli._SAV_damage_script]]();
	}

	if ( ( IsDefined( heli.script_spotlight ) ) && ( heli.script_spotlight == 1 ) && ( !isdefined( heli.spotlight ) ) )
	{
		heli thread heli_spotlight_on( undefined, true );
	}

	return heli;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
makesentient( team )
{
	self MakeEntitySentient( team );
	self waittill( "death" );

	if ( isdefined( self ) )
		self FreeEntitySentient();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
start_circling_SAV( heli_targetname, heli_points, heli )
{
	start_circling_heli( heli_targetname, heli_points, heli, ::SAV_shoot_think, ::SAV_circle_node_choice, ::SAV_get_offset_node_pos );

	return heli;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
SAV_shoot_think()
{
	self endon( "stop_shooting" );
	self endon( "death" );
	self endon( "heli_players_dead" );

	//attackRangeSquared = level._attackheliRange * level._attackheliRange;
	level._attackHeliGracePeriod = false;

	while ( IsDefined( self ) )
	{
		wait( RandomFloatRange( level._attackHeliRefire_min, level._attackHeliRefire_max ) );

		// This takes into account proximity & los, but not fov
		potential_targets = self maps\_helicopter_globals::get_potential_enemy_targets( level._attackheliRange, level._cosine[ "180" ], true, true, false, false, level._attackHeliExcluders );

		switch ( potential_targets.size )
		{
			case 0:
				self.eTarget = undefined;
				break;

			case 1:
				self.eTarget = potential_targets[0];
				break;

			default:
				self SAV_find_greatest_threat( potential_targets );
				break;
		}

		// If we have a target, fire
		if ( IsDefined( self.eTarget ) )
		{
			// Wait until the target is within the SAV's fov
			while ( 1 )
			{
				if ( IsDefined( self.eTarget ) )
				{
					self SetLookAtEnt( self.eTarget );
	
					if( within_fov( self.origin, self.angles, self.eTarget.origin, level._cosine[ "25" ] ) )
					{
						break;
					}
			
					wait 0.05;
				}
				else
				{
					break;
				}
			}

			if ( IsDefined( self.eTarget ) )
			{
				// tagMJS<NOTE> new fire logic for SAV 6/15/11
				miss_player( self.eTarget );
				wait( RandomFloatRange( level._attackHeliRefire_min, level._attackHeliRefire_max ) );

				while ( IsAlive( self.eTarget ) && can_see_player( self.eTarget ) && ( !self.eTarget is_hidden_from_heli( self ) ) )
				{
					self.firingguns = true;
					self SAV_attacker_accuracy_fire();
					self.firingguns = false;

					wait( RandomFloatRange( 1.0, 3.0 ) );
				}
			}
		}
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
SAV_find_greatest_threat( potential_targets )
{
	greatest_threat = -1;
	greatest_target = undefined;
	current_target = self.eTarget;

	for ( i = 0; i < potential_targets.size; i++ )
	{
		potential_target = potential_targets[i];
		threat = 0;

		// Add the enemy's faction threatbias
		threat += GetThreatBias( potential_target GetThreatBiasGroup(), self GetThreatBiasGroup() );

		// Add the enemy's personal threatbias
		if ( IsDefined( potential_target.script_threatbias ) )
		{
			threat += potential_target.script_threatbias;
		}
		else
		{
			threat += potential_target.threatbias;
		}

		// Add a constant if the actor is aware of the enemy

		// Add a constant if the enemy is visible
		// tagBR<note>: Currently only considering potentials that the SAV can see

		// Add "Scariness": SAV accurracy against enemy - enemy's accuracy against SAV

		// Add a constant if enemy's node is visible from SAV's current node

		// Add threat depending on how close the enemy is
		closeness = ( level._attackheliRange - Distance( self.origin, potential_target.origin ) );
		dist_threat = ( closeness * closeness * level._ai_threat_dist_rate );
		threat += dist_threat;

		// Subtract threat for each other actor already attacking the enemy

		// Add a constant if the enemy is damaged

		// Add a constant if the enemy has been flashbanged

		// Add a constant if the enemy is already the actor's enemy (maintain threat)
		if ( IsDefined( current_target ) && potential_target == current_target )
		{
			threat += level._ai_threat_current_enemy;
		}

		if ( threat > greatest_threat )
		{
			greatest_threat = threat;
			greatest_target = potential_target;
		}
	}

	self.eTarget = greatest_target;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
SAV_attacker_accuracy_fire()
{
	// setup our bursts and loop
	if ( self.turrettype == "nx_miniuav_rifle" )
	{
		fireTime = WeaponFireTime( "nx_miniuav_rifle" );
		burstsize = RandomIntRange( 10, 20 );
		miss_factor = 50;
	}
	else if ( self.turrettype == "nx_chinese_skimmer_weap" )
	{
		fireTime = WeaponFireTime( "nx_chinese_skimmer_weap" );
		burstsize = RandomIntRange( 1, 4 );
		miss_factor = 150;
	}
	else
	{
		fireTime = WeaponFireTime( "turret_attackheli" );
		burstsize = RandomIntRange( 10, 20 );
		miss_factor = 50;
	}

	// now its time to fire on the poor SOB
	for ( index = 0; index < burstsize; index++ )
	{
		if ( !IsAlive( self.eTarget ) )
		{
			return;
		}

		// make sure our turrets are pointed at the target
		miss_vec = randomvector( miss_factor ) + ( 0, 0, 32 );
		self SetTurretTargetEnt( self.eTarget, miss_vec );
		accuracy = self GetFinalAccuracy( self.eTarget, self.turrettype );
		if ( accuracy > RandomFloat( 1.0 ) )
		{
			if ( IsDefined( self._attack_heli_custom_firing_func ) )
			{
				[[ self._attack_heli_custom_firing_func ]]( self.eTarget, 1, fireTime );
			}
			else
			{
				self SAV_fire_hit();
			}
		}
		else
		{
			if ( IsDefined( self._attack_heli_custom_miss_func ) )
			{
				[[ self._attack_heli_custom_miss_func ]]( self.eTarget, 1, fireTime, miss_vec );
			}
			else
			{
				self SAV_fire_miss();
			}
		}

		wait fireTime;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
SAV_fire_hit()
{
	if ( self.allowShoot )
	{
		target = ( self.eTarget GetEye() + RandomVectorRange( 3, 7 ) );
		start1 = self GetTagOrigin( "TAG_FLASH" );
		start2 = self GetTagOrigin( "TAG_FLASH2" );
		angles1 = self GetTagAngles( "TAG_FLASH" );
		angles2 = self GetTagAngles( "TAG_FLASH2" );

		if ( self.turrettype == "nx_miniuav_rifle" )
		{
			MagicBullet( "nx_miniuav_rifle", start1, target );
			PlayFX( getfx( "miniuav_muzzleflash" ), start1, angles1 );
			MagicBullet( "nx_miniuav_rifle", start2, target );
			PlayFX( getfx( "miniuav_muzzleflash" ), start2, angles2 );
		}
		else
		{
			MagicBullet( "turret_attackheli", start1, target );
			MagicBullet( "turret_attackheli", start2, target );
		}
	}
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************
SAV_fire_miss()
{
	if ( self.allowShoot )
	{
		// these values were taken from code side. Sorry for the magic numbers.
		player_width = 16;
		torso_adjust = 44;

		target = self.eTarget GetEye();
		forward = self.eTarget GetEye() - self GetTagOrigin( "TAG_FLASH" );
		right = ( forward[1], -1 * forward[0], 0.0 );
		offset = Vector_Multiply( VectorNormalize( right ), random_sign() );
		offset = Vector_Multiply( offset, player_width + RandomInt( player_width ) );
		offset = offset + ( 0, 0, ( random_sign() * RandomInt( torso_adjust ) ) );

		start1 = self GetTagOrigin( "TAG_FLASH" );
		start2 = self GetTagOrigin( "TAG_FLASH2" );
		angles1 = self GetTagAngles( "TAG_FLASH" );
		angles2 = self GetTagAngles( "TAG_FLASH2" );
		
		if ( self.turrettype == "nx_miniuav_rifle" )
		{
			MagicBullet( "nx_miniuav_rifle", start1, target + offset );
			PlayFX( getfx( "miniuav_muzzleflash" ), start1, angles1 );
			MagicBullet( "nx_miniuav_rifle", start2, target + offset );
			PlayFX( getfx( "miniuav_muzzleflash" ), start2, angles2 );
		}
		else
		{
			MagicBullet( "turret_attackheli", start1, target + offset );
			MagicBullet( "turret_attackheli", start2, target + offset );
		}
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
SAV_circle_node_choice( baseSpeed, circle_nodes )
{
	// SAV's need to be a bit more agile
	self Vehicle_SetSpeed( 40, 25, 20 );

	// Need to save of a copy of the points array
	temp_points = circle_nodes;

	// If this is true, then there isn't a node in sight, so we handle it below
	if( !temp_points.size )
	{
		return [];
	}

	assert( temp_points.size > 0 );

	//valid_locations = [];
	
	while( 1 )
	{
		// Out of circle nodes to process
		if ( !temp_points.size )
		{
			break;
		}

		if ( IsDefined( self.eTarget ) )
		{
			// This gets the closest "attack_heli_circle_node" point to the target
			closest_point = getClosest( self.eTarget.origin, temp_points );
		}
		else
		{
			// Since we don't have a target, just get a random point
			closest_point = temp_points[ RandomInt( temp_points.size ) ];
		}

		if ( isdefined( closest_point.type ) && closest_point.type == "Uav Circle" )
		{
			self.nearestNodeOverride = closest_point;
		}

		// Sanity check
		/#
		if ( !IsDefined( closest_point.target ) )
		{
			AssertMsg( "Your " + circle_nodes + " at " + closest_point.origin + " does not have KVP 'target'." );
		}
		#/

		// Remove this point from the array
		temp_points = array_remove( temp_points, closest_point );

		// Grab the array of heli points targeted by closest point
		self process_heli_sight_nodes( closest_point.target );
		satellite_nodes = self.sight_nodes;
		satellite_nodes = SAV_get_valid_nodes( satellite_nodes );

		// This circle node has no valid satellite nodes
		if ( !satellite_nodes.size )
		{
			continue;
		}

		// We are going to forcibly use the a random option first valid option for now
		return_array = [];
		return_array[0] = satellite_nodes[ RandomInt( satellite_nodes.size ) ];

		SAV_use_node( return_array[0] );

		return return_array;
	}

	empty_array = [];
	return empty_array;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
SAV_get_valid_nodes( points )
{
	new_points = [];
	foreach ( point in points )
	{
		if ( !isdefined( point.used ) )
		{
			point.used = 0;
			point.use_position = [];
		}

		if ( point.used < 2 )
		{
			new_points[ new_points.size ] = point;
			//println( "Adding valid node (used " + point.used + ") at " + point.origin );
		}
	}
	
	return new_points;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
SAV_use_node( node )
{
	if ( isdefined( self.current_node ) )
	{		
		self.current_node.used--;
		self.current_node.use_position[self.used_node_slot] = undefined;
		self.used_node_slot = undefined;
		
		//println( "UAV " + self.unique_id + " clearing use at " + self.current_node.origin + " : " + self.current_node.used );
		assert( self.current_node.used >= 0 );
	}

	self.current_node = node;
	self.current_node.used++;

	MAX_USE_POSITIONS = 2;

	for ( use_pos = 0; use_pos < MAX_USE_POSITIONS; use_pos++ )
	{
		if ( !isdefined( node.use_position[use_pos] ) )
		{
			break;
		}
	}

	assert( use_pos < MAX_USE_POSITIONS );

	self.used_node_slot = use_pos;
	node.use_position[ use_pos ] = use_pos;
	
	//println( "SAV " + self.unique_id + " using node at " + node.origin + " : " + node.used );

	assert( self.current_node.used <= 2 );
	assert( node.used == self.current_node.used );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
// Returns a node offset based on how many SAV are using the node
SAV_get_offset_node_pos( node )
{
	assert( node.used > 0 );

	new_origin = node.origin + ( ( 0, 0, 64 ) * self.used_node_slot );
	return new_origin;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
SAV_switch_to_circling( circle_nodes )
{
	self vehicle_pathdetach();

	AssertEx( IsDefined( circle_nodes ), "Switching to circling SAV requires a node_uav_circle target" );
 
	self start_circling_heli_logic( circle_nodes, ::SAV_shoot_think, ::SAV_circle_node_choice, ::SAV_get_offset_node_pos );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
SAV_switch_to_pathing()
{
	self notify( "stop_circling" );
	self notify( "stop_shooting" );
	self.circling = false;
	self ClearLookAtEnt(); // <-- Not required, but will otherwise continue to look at target when following the path
	self thread vehicle_resumepathvehicle();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
random_sign()
{
	foo = -1 + ( 2 * RandomInt( 2 ) );
	return foo;
}

