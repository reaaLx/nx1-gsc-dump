//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  MISSION DESCRIPTION											**
//                                                                          **
//    Created: DATE - CREATOR												**
//                                                                          **
//****************************************************************************

//#include maps\_utility;
//#include common_scripts\utility;
//#include maps\_anim;
//#include maps\_vehicle;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*
main()
{
	// External Initialization
	maps\mp_nx_meteor_precache::main();
	//maps\mp_nx_meteor_anim::main();
	maps\mp_nx_meteor_fx::main();
	maps\_load::main();

	// Internal Initialization
	mission_flag_inits();
	mission_precache();
}
*/

TIME_SMOKE_REMAIN_ON = 3.0;  //This is the time the smoke effect will remain on AFTER the door are completely opened.
TIME_DOOR_REMAIN_CLOSE = 5.0;  //After the doors are closed, this is the time the doors will remain closed.
TIME_DOOR_TO_CLOSE = 5.0;  //This is how long the doors take to close.  It determined the speed of the door closing.

main()
{
	maps\mp\mp_nx_meteor_precache::main();
	maps\createart\mp_nx_meteor_art::main();
	maps\mp\mp_nx_meteor_fx::main();

	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap("compass_map_mp_nx_meteor");

	ambientPlay( "ambient_mp_rural" );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";

	//decompressionRoom();
}

// All mission specific PreCache calls
mission_precache()
{
}

// All mission specific flag_init() calls
mission_flag_inits()
{
}

/* decompressionRoom()
{
	setUp();
	
	level._door_switch_trig1 thread door_switch_setup();
	level._door_switch_trig2 thread door_switch_setup();

	while ( true )
	{
		level waittill ( "Start decompression" );
		//println ( "##### The number of clips in the list is: " + level._ClipOnDoor.size );
		//println ( "##### The number of trigger on door list is: " + level._TriggerOnDoor.size );
		//println ( "##### The number of trigger beginning list is: " + level._TriggerBeginning.size );
		//println ( "##### The number of trigger end list is: " + level._TriggerEnd.size );
		//println ( "##### The number of trigger kill list is: " + level._TriggerKill.size );
		//println ( "##### The number of vent list is: " + level._decompressionVents.size );

		//tagJC<NOTE>: Disables the switch during the decompression process
		level._door_switch_trig1 trigger_off();
		level._door_switch_trig2 trigger_off();
		
		//tagJC<NOTE>: The 45 degree forward vector is created to let the light go through the opening
		forward_vector = ( -1, -1, 0); 

		//tagJC<NOTE>: Spawn the and play the light effect
		level._decompressionLightEffects = SpawnFX( level._effect[ "decompression_light" ], level._decompressionLight.origin, forward_vector );
		TriggerFX ( level._decompressionLightEffects ); 

		//tagJC<NOTE>: Move the doors
		for ( i = 0; i < level._ClipOnDoor.size; i++)
		{
			level._ClipOnDoor[i] thread moveTheDoor();
		} 		
		level waittill ( "doors_closed" );
	
		//tagJC<NOTE>: After the doors are completely closed, spawn and play the smoke effect near the two doors
		//tagJC<TODO>: It has been noticed that putting spawned effect into a level array will sometimes cause the game to 
		//             delete some of the effects from the array.  Need to look into the cause when time permits.
		forward_vector = ( 0, 0, -1 ); 
		level._decompressionEffects = SpawnFX( level._effect[ "decompression_vent" ], level._decompressionVents.origin, forward_vector );
		TriggerFX ( level._decompressionEffects );
		level._decompressionEffects1 = SpawnFX( level._effect[ "decompression_vent" ], level._decompressionVents1.origin, forward_vector );
		TriggerFX ( level._decompressionEffects1 );
		
		//tagJC<NOTE>: After the doors are completely closed, turn off the light effect
		level waittill ( "doors_opened" );
		level._decompressionLightEffects delete();
		level._decompressionLightEffects = undefined;
		
		//tagJC<NOTE>: Reactivate the two triggers
		level._door_switch_trig1 trigger_on();
		level._door_switch_trig2 trigger_on();

		//tagJC<NOTE>: Let the smoke remain present to continue blocking the sightlines
		wait ( TIME_SMOKE_REMAIN_ON );

		//tagJC<NOTE>: Turn off the smoke effect
		level._decompressionEffects delete();
		level._decompressionEffects = undefined;	
		level._decompressionEffects1 delete();
		level._decompressionEffects1 = undefined;		
	}
}

moveTheDoor()
{
	original_position = self.origin;
	move_to_position = ( self.pairedTriggerBeginning.origin + self.pairedTriggerEnd.origin ) / 2;

	//tagJC<NOTE>: During the door closing, we want to kill players who get stuck.
	self.pairedTriggerKill thread detectPlayerAndKill( self.pairedTriggerOn, self.pairedTriggerEnd );

	self MoveTo( move_to_position, TIME_DOOR_TO_CLOSE, TIME_DOOR_TO_CLOSE * 0.5, TIME_DOOR_TO_CLOSE * 0.4 );
	self waittill ( "movedone" );
	self.pairedTriggerKill notify ( "stop_killing_player" );
	level notify ( "doors_closed" );

	wait ( TIME_DOOR_REMAIN_CLOSE );

	//tagJC<NOTE>: Open the door by moving them back to their original position
	self MoveTo( original_position, TIME_DOOR_TO_CLOSE, TIME_DOOR_TO_CLOSE * 0.5, TIME_DOOR_TO_CLOSE * 0.4 );
	self waittill ( "movedone" );
	level notify ( "doors_opened" );
}

door_switch_setup()
{
	self usetriggerrequirelookat();
	self SetHintString( "Press ^3[{+activate}]^7 to start decompression" );
	
	while ( true )
	{
		self waittill("trigger", player);
		level notify ( "Start decompression" );
		wait (1);
	}	
}

trigger_off()
{
	foreach ( player in level._players )
	{
		self DisablePlayerUse ( player );
	}
}

trigger_on()
{
	foreach ( player in level._players )
	{
		self EnablePlayerUse ( player );
	}
}

detectPlayerAndKill ( trig1, trig2 )
{	
	self endon ( "stop_killing_player" );	

	while ( true )
	{
		self waittill( "trigger", player);

		if (( player IsTouching( trig1 )) && ( player IsTouching( trig1 ))) 
		{
			player thread [[level._callbackPlayerDamage]](
			player, // eInflictor The entity that causes the damage.(e.g. a turret)
			player, // eAttacker The entity that is attacking.
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
		wait .05;
	}
}

rotatingLight()
{
	level endon ( "doors_closed" );

	while ( true )
	{
		self RotateYaw( 360, 10);
		self waittill( "rotatedone" );
	}
}

setUp()
{
	level._effect[ "decompression_vent" ] = loadfx( "smoke/steam_large_vent" );
	level._effect[ "decompression_light" ] = loadfx( "misc/lighthaze_snow_spotlight" );

	level._door_switch_trig1 = getent_and_assert("switch_trigger1");
	level._door_switch_trig2 = getent_and_assert("switch_trigger2");

	level._DoorModel = getentArray_and_assert( "door_model" );
	level._ClipOnDoor = getentArray_and_assert( "door_collision" );
	level._TriggerOnDoor = getentArray_and_assert( "trigger_on" );
	level._TriggerBeginning = getentArray_and_assert( "trigger_beginning" );
	level._TriggerEnd = getentArray_and_assert( "trigger_end" );
	level._TriggerKill = getentArray_and_assert( "trigger_kill" );
	level._decompressionVents = getent_and_assert( "decompression_vent" );
	level._decompressionVents1 = getent_and_assert( "decompression_vent1" );
	level._decompressionLight = getent_and_assert( "decompression_light" );
	
	linking( level._ClipOnDoor , level._DoorModel );
	linking( level._ClipOnDoor , level._TriggerOnDoor );

	pairing( level._ClipOnDoor, level._TriggerOnDoor, level._TriggerBeginning, level._TriggerEnd, level._TriggerKill );
}

linking( object_list_1 , object_list_2 )
{	
	for ( i = 0; i < object_list_1.size; i++ )
	{
		//tagJC<NOTE>: Use an arbitrary distance as the base for comparision
		paired_object2 = find_closest( object_list_1[i], object_list_2 );		
		
		//tagJC<NOTE>: Link the paired objects to that in object_list_1
		paired_object2 LinkTo( object_list_1[i] );
	}
}

pairing( clip_list, trigger_on_list, trigger_beginning_list, trigger_end_list, trigger_kill_list )
{
	for ( i = 0; i < clip_list.size; i++ )
	{
		//tagJC<NOTE>: Determine the door clip, and the four triggers around the door that are the closest to the current 
		//             switch trigger under examination
		paired_trigger_on = find_closest( clip_list[i], trigger_on_list );
		paired_trigger_beginning = find_closest( clip_list[i], trigger_beginning_list );
		paired_trigger_end = find_closest( clip_list[i], trigger_end_list );
		paired_trigger_kill = find_closest( clip_list[i], trigger_kill_list );
		
		//tagJC<NOTE>: Putting those closest entities as the member data for the switch trigger
		clip_list[i].pairedTriggerOn = paired_trigger_on;
		clip_list[i].pairedTriggerBeginning = paired_trigger_beginning;
		clip_list[i].pairedTriggerEnd = paired_trigger_end;
		clip_list[i].pairedTriggerKill = paired_trigger_kill;

		//tagJC<NOTE>: Useful debugging message
		//IPrintLnBold( "clip at " + paired_clip.origin + " is paired with switch trigger at " + trigger_list[i].origin);
        //IPrintLnBold( "Trigger_on at " + paired_trigger_on.origin + " is paired with switch trigger at " + trigger_list[i].origin);		
		//IPrintLnBold( "Trigger_under at " + paired_trigger_under.origin + " is paired with switch trigger at " + trigger_list[i].origin);
		//IPrintLnBold( "Trigger_floor at " + paired_trigger_floor.origin + " is paired with switch trigger at " + trigger_list[i].origin);
		//IPrintLnBold( "Trigger_top at " + paired_trigger_top.origin + " is paired with switch trigger at " + trigger_list[i].origin);
	}
}

find_closest( entity, entity_list )
{
	//tagJC<NOTE>: Use an arbitrary distance as the base for comparision
	closest_distance = distance( entity.origin , entity_list[0].origin );
	closest_entity = entity_list[0];
	for ( i = 1; i < entity_list.size; i++ )
	{
		//tagJC<NOTE>: If another entity on the list results in a shorter distance, update the results accordingly
		if ( distance( entity.origin , entity_list[i].origin ) < closest_distance )
		{
			closest_distance = distance( entity.origin , entity_list[i].origin );
			closest_entity = entity_list[i];
		}
	}
	return closest_entity;
}

getentArray_and_assert( ent_name )
{
	object = getEntArray( ent_name, "targetname" );
	AssertEX( object.size > 0 , "There is no entity for " + ent_name );
	return object;
} 

getent_and_assert(ent_name)
{
	thing = GetEnt( ent_name, "targetname");
	AssertEx(IsDefined(thing), "Unable to find targetname " + ent_name);
	
	return thing;
}
*/

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************