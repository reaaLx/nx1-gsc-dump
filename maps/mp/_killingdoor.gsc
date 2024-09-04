//****************************************************************************
 //                                                                          **
 //           Confidential - (C) Activision Publishing, Inc. 2010            **
 //                                                                          **
 //****************************************************************************
 //                                                                          **
 //    Module:  Phase 3 Check-In: Script controlling multiple sets of two    **
 //             moving doors that will kill players who are stuck in between **
 //             This script works for the following setups for each door set **
 //             in Radiant:                                                  **
 //             2 door models:                                               **
 //                   script_model: "targetname" "killing_door_1"            **
 //                   script_model: "targetname" "killing_door_2"            **
 //             2 clips:                                                     **
 //                   script_brushmodel: "targetname" "killing_clip_1"       **
 //                   script_brushmodel: "targetname" "killing_clip_2"       **
 //             3 triggers:                                                  **
 //                   trigger_multiple: "targetname" "killing_trigger_1"     **
 //                   trigger_multiple: "targetname" "killing_trigger_2"     **                                            
 //                   trigger_multiple: "targetname" "killing_trigger_center"**
 //                                                                          **
 //    Created: May 17th, 2011 - James Chen                                  **
 //                                                                          **
 //***************************************************************************/
 
 
 //tagJC<NOTE>: For demonstration, please run mp_nx_killtest.
 //tagJC<TODO>: Custom key values are added into the Radiant key table.  Their impact on Radiant will need to be assessed over time  
 //tagJC<TODO>: Like in phase1, the doors will not kill if multiple players are stuck in between the doors.
 //             A potential solution will be to introduce a delay time before the trigger in the center start to conduct the killings.
 //             However, the delay-time solution needs to be assessed in terms of its impact on gameplay (delay etc.).  
 //tagJC<NOTE>: Because of the double doors setup, it is not practical nor realistic to move the doors vertically along the 'z' direction
 main()
 {
 	//tagJC<NOTE>: Getting all the entities into corresponding arrays and do basic error checking
 	level._killingDoor1 = getentArray_and_assert( "killing_door_1" );
 	level._killingDoor2 = getentArray_and_assert( "killing_door_2" );
 	level._killingClip1 = getentArray_and_assert( "killing_clip_1" );
 	level._killingClip2 = getentArray_and_assert( "killing_clip_2" );
 	level._killingTrigger1 = getentArray_and_assert( "killing_trigger_1" );
 	level._killingTrigger2 = getentArray_and_assert( "killing_trigger_2" );
 	level._killingTriggerCenter = getentArray_and_assert( "killing_trigger_center" );
 
 	//tagJC<NOTE>: Checking for the correct numbers of models, clips and triggers in order to make sure that the script will function 
 	//             correctly.
 	checking_setup();
 	
 	//tagJC<NOTE>: Linking the door models and triggers to the clips
 	linking( level._killingClip1 , level._killingDoor1 );
 	linking( level._killingClip1 , level._killingTrigger1 );
 	linking( level._killingClip2 , level._killingDoor2 );
 	linking( level._killingClip2 , level._killingTrigger2 );
 	
 	//tagJC<NOTE>: Based on proximity, pair up clip1, clip2, and all the three corresponding triggers into sets
 	pairing( level._killingClip1, level._killingClip2, level._killingTriggerCenter, level._killingTrigger1, level._killingTrigger2 );
 
 	//tagJC<NOTE>: Make the doors move
 	move_doors();
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 //tagJC<NOTE>: Linking entities in object_list_2 to that in object_list_1 based on proximity
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
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 //tagJC<NOTE>: This function pairs up the clips with each other as well as the corresponding triggers
 pairing( clip1_list , clip2_list, cTrigger_list, Trigger1_list, Trigger2_list )
 {
 	for ( i = 0; i < clip1_list.size; i++ )
 	{
 		//tagJC<NOTE>: Determine the clip2 that is the closest to the current clip1 under examination
 		paired_clip2 = find_closest( clip1_list[i], clip2_list );
 		//tagJC<NOTE>: Determine the center trigger that is the closest to the current clip1 under examination
 		paired_cTrigger = find_closest( clip1_list[i], cTrigger_list );
 		//tagJC<NOTE>: Determine the trigger1 that is the closest to the current clip1 under examination
 		paired_Trigger1 = find_closest( clip1_list[i], Trigger1_list );
 		//tagJC<NOTE>: Determine the trigger2 that is the closest to the current clip1 under examination
 		paired_Trigger2 = find_closest( clip1_list[i], Trigger2_list );
 		//tagJC<NOTE>: Putting the set into a level array
 		level._killingSet[i][ "clip1" ] = clip1_list[i];
 		level._killingSet[i][ "clip2" ] = paired_clip2;
 		level._killingSet[i][ "cTrigger" ] = paired_cTrigger;
 		level._killingSet[i][ "Trigger1" ] = paired_Trigger1;
 		level._killingSet[i][ "Trigger2" ] = paired_Trigger2;
 		//tagJC<NOTE>: Useful debugging message
 		//IPrintLnBold( "clip1 at " + level._killingSet[i][ "clip1" ].origin + " is paired with clip2 at " + level._killingSet[i][ "clip2" ].origin + " and Center Trigger at " + level._killingSet[i][ "cTrigger" ].origin + " and Trigger1 at " + level._killingSet[i][ "Trigger1" ].origin + " and Trigger2 at " + level._killingSet[i][ "Trigger2" ].origin);
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
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
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 move_doors()
 {
 	for ( i = 0; i < level._killingSet.size ; i++ )
 	{
 		//tagJC<NOTE>: Starting moving the clips
 		level thread moving_doors( level._killingSet[i][ "clip1" ], level._killingSet[i][ "clip2" ] );
 		//tagJC<NOTE>: Starting to spawn the triggers and detect players' contact 
 		level._killingSet[i][ "cTrigger" ] thread kill_stuck_players( level._killingSet[i][ "Trigger1" ], level._killingSet[i][ "Trigger2" ]);
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 moving_doors( clip1, clip2 )
 {
 	//tagJC<NOTE>: Determine the distance and the vector of which the doors will move
 	dis = distance( clip1.origin, clip2.origin );
 	moving_vector = clip1.origin - clip2.origin;
 	//tagJC<NOTE>: Start to move the two clips in opposite directions
 	if ( isDefined ( level.KillingDoorControllingLogic ))
 	{
 		if ( ! isDefined ( level.escortPlusKillingDoorClosed ) )
 		{
 			level.escortPlusKillingDoorClosed = 0;
 		}
 		clip1 thread [[level.KillingDoorControllingLogic]]( moving_vector * -1/3, ( dis/clip1.speed ), clip1.door_time_remain_open, clip1.door_time_remain_close );
 		clip2 thread [[level.KillingDoorControllingLogic]]( moving_vector * 1/3, ( dis/clip1.speed ), clip1.door_time_remain_open, clip1.door_time_remain_close );
 	}
 	else
 	{
 		clip1 thread move_one_door( moving_vector, ( dis/clip1.speed ), clip1.door_time_remain_open, clip1.door_time_remain_close ); 
 		clip2 thread move_one_door( moving_vector * -1, ( dis/clip1.speed ), clip1.door_time_remain_open, clip1.door_time_remain_close ); 
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 //tagJC<NOTE>: Moving one door back and forth according to the values sspecified by the designer
 move_one_door( moving_vector, moving_time, door_time_remain_open, door_time_remain_close ) 
 {
 	while ( 1 )
 	{
 		self moveTo( self.origin + moving_vector, moving_time, moving_time * 0.5, moving_time * 0.5 );
         self waittill( "movedone" );
         wait door_time_remain_open;
         
         self moveTo( self.origin - moving_vector, moving_time, moving_time * 0.5, moving_time * 0.5 );
         self waittill( "movedone" );
         wait door_time_remain_close;
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 kill_stuck_players( Trigger1, Trigger2 )
 {
 	while ( 1 )
 	{
 		//tagJC<NOTE>: Detecting whether death_trig has been touched
 		self waittill( "trigger", player);
 		//tagJC<NOTE>: Depending on how death_trig is setup in Radiant, this might be a useful debug message
 		//IPrintLnBold( "death_trig has been touched!" );
 
 
 		//tagJC<NOTE>: Depending on the setup in Radiant, the following two are useful debugging functions
 		//Trigger1 thread testing1();
 		//Trigger2 thread testing2();
 		
 		//tagJC<NOTE>: If a player is inside death_trig and is touching both death_trig1 and death_trig2 at the same time,
 		//             kill the player
 		if (( player IsTouching( Trigger1 )) && ( player IsTouching( Trigger2 )))
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
 		else
 		{
 			wait .05;
 		}
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 //tagJC<NOTE>: Check for matching numbers of entities for door models, clips and triggers
 checking_setup ()
 {
 	set_count = level._killingDoor1.size;
 	if ( level._killingDoor2.size != set_count )
 	{
 		AssertEX( false , "The number of door 2 needs to equal to the number of door 1" );
 	}
 	if ( level._killingClip1.size != set_count )
 	{
 		AssertEX( false , "The number of clip 1 needs to equal to the number of door 1" );
 	}
 	if ( level._killingClip2.size != set_count )
 	{
 		AssertEX( false , "The number of clip 2 needs to equal to the number of door 1" );
 	}
 	if ( level._killingTrigger1.size != set_count )
 	{
 		AssertEX( false , "The number of trigger 1 needs to equal to the number of door 1" );
 	}
 	if ( level._killingTrigger2.size != set_count )
 	{
 		AssertEX( false , "The number of trigger 2 needs to equal to the number of door 1" );
 	}
 	if ( level._killingTriggerCenter.size != set_count )
 	{
 		AssertEX( false , "The number of center trigger needs to equal to the number of door 1" );
 	}
 	for ( i = 0; i < level._killingClip1.size; i++ )
 	{
 		AssertEX( isDefined( level._killingClip1[i].speed ), "Clip1 located at " + level._killingClip1[i].origin + " does not have the speed specified." );
 	}
 	for ( i = 0; i < level._killingClip1.size; i++ )
 	{
 		AssertEX( isDefined( level._killingClip1[i].door_time_remain_open ), "Clip1 located at " + level._killingClip1[i].origin + " does not have the door_time_remain_open specified." );
 	}
 	for ( i = 0; i < level._killingClip1.size; i++ )
 	{
 		AssertEX( isDefined( level._killingClip1[i].door_time_remain_close ), "Clip1 located at " + level._killingClip1[i].origin + " does not have the door_time_remain_close specified." );
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 //tagJC<NOTE>: Useful helper function to get the requested entity and check for any errors
 getentArray_and_assert( ent_name )
 {
 	object = getEntArray( ent_name, "targetname" );
 	AssertEX( object.size > 0 , "There is no entity for " + ent_name );
 	return object;
 } 
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 //tagJC<NOTE>: Useful debugging function to test killing_trigger_1
 testing1()
 {
 	while ( 1 )
 	{
 		self waittill( "trigger", player);
 
 		IPrintLnBold( "killing_trigger_1 has been touched!" );
 
 		wait 0.05;
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 //tagJC<NOTE>: Useful debugging function to test killing_trigger_2
 testing2()
 {
 	while ( 1 )
 	{
 		self waittill( "trigger", player);
 
 		IPrintLnBold( "killing_trigger_2 has been touched!" );
 
 		wait 0.05;
 	}
 }