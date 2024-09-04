 //****************************************************************************
 //                                                                          **
 //           Confidential - (C) Activision Publishing, Inc. 2010            **
 //                                                                          **
 //****************************************************************************
 //                                                                          **
 //    Module:  Phase 1 Check-In: The script is able to control multiple     **
 //             sets of door-switch pairs.  It will work with the following  **
 //             required setups in Radiant:                                  **
 //             2 models:                                                    **
 //                   script_model: "targetname" "door_switch"               **
 //                   script_model: "targetname" "door_for_door_switch"      **
 //             1 clips:                                                     **
 //                   script_brushmodel: "targetname" "clip_on_door"         **
 //             5 triggers:                                                  **
 //                   trigger_use: "targetname" "door_trigger"               **
 //                   trigger_multiple: "targetname" "trigger_on_door"       **                                            
 //                   trigger_multiple: "targetname" "trigger_under_door"    **
 //                   trigger_multiple: "targetname" "trigger_on_floor"      **
 //                   trigger_multiple: "targetname" "trigger_on_top"        **
 //                                                                          **
 //    Created: June 9th, 2011 - James Chen                                  **
 //                                                                          **
 //***************************************************************************/
 
 TARGETNAME_DOOR_SWITCH_MODEL = "door_switch";                  //model for the door switch 
 TARGETNAME_DOOR_SWITCH_TRIGGER = "door_trigger";               //trigger_use placed with the door switch
 TARGETNAME_DOOR_CLIP = "clip_on_door";                         //clip around the door
 TARGETNAME_DOOR = "door_for_door_switch";                      //model for the door
 TARGETNAME_TRIGGER_ON_DOOR = "trigger_on_door";                //trigger_multiple placed at the bottom of the door  
 TARGETNAME_TRIGGER_UNDER_DOOR = "trigger_under_door";          //trigger_multiple placed under the door to detect players passing by
 TARGETNAME_TRIGGER_ON_FLOOR = "trigger_on_floor";              //trigger_multiple to represent the lowest point the door can go
 TARGETNAME_TRIGGER_ON_TOP = "trigger_on_top";                  //trigger_multiple to represent the highest point the door can go
 TIME_OPEN_DOOR = 15;                                           //Based on the UGV design doc
 NOTIFY_MESSAGE_DOOR_OPENING = "door_opening";                  //the notify message when the door is opening
 NOTIFY_MESSAGE_DOOR_CLOSING = "door_closing";                  //the notify message when the door is closing
 NOTIFY_MESSAGE_DOOR_AT_TOP = "door_at_top";                    //the notify message when the door is at the top
 NOTIFY_MESSAGE_DOOR_AT_BOTTOM = "door_at_bottom";              //the notify message when the door is at the bottom
 NOTIFY_MESSAGE_DISABLE_DOOR_SWITCH = "disable_door_switch";    //the notify message to disable the door switch
 HINT_STRING_FOR_TRIGGER = &"MP_HINT_STRING_DOOR_SWITCH";       //the default hint string that will appear when players are close to the trigger
 DOOR_STATE_COMPLETELY_CLOSED = "completely_closed";            //the flag message when the door is completely closed
 DOOR_STATE_COMPLETELY_OPENED = "completely_opened";            //the flag message when the door is completely opened
 DOOR_STATE_OPENING = "door_opening";                           //the flag message when the door is opening
 DOOR_STATE_CLOSING = "door_closing";                           //the flag message when the door is closeing
 
 //tagJC<NOTE>: For demonstration, run mp_nx_switch
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 main()
 {
 	//tagJC<NOTE>: These two lines are to test the desired functionality for the UGV escort mode.  Disable the following lines will 
 	//             result in the default behavior for the door switch, unless the new controlling logic and (or) the is defined 
 	//             in the game mode.
 	//level._canPlayerUseDoor = ::gameModeLogic;	
 	//level._shouldTheObjectiveEnd = ::objectiveTerminationLogic;
 	//level._HintStringForDoorSwitch = "Testing string - Press ^3[{+activate}]^7 to use the door switch";
 
 	//tagJC<NOTE>: Getting all the entities into corresponding arrays	
 	level._DoorSwitch = getentArray_and_assert( TARGETNAME_DOOR_SWITCH_MODEL );
 	level._DoorSwitchTrigger = getentArray_and_assert( TARGETNAME_DOOR_SWITCH_TRIGGER );
 	level._ClipOnDoor = getentArray_and_assert( TARGETNAME_DOOR_CLIP );
 	level._DoorForDoorSwitch = getentArray_and_assert( TARGETNAME_DOOR );
 	level._TriggerOnDoor = getentArray_and_assert( TARGETNAME_TRIGGER_ON_DOOR );
 	level._TriggerUnderDoor = getentArray_and_assert( TARGETNAME_TRIGGER_UNDER_DOOR );
 	level._TriggerOnFloor = getentArray_and_assert( TARGETNAME_TRIGGER_ON_FLOOR );
 	level._TriggerOnTop = getentArray_and_assert( TARGETNAME_TRIGGER_ON_TOP );	
 
 	//tagJC<NOTE>: Checking for the correct numbers of models, clips and triggers in order to make sure that the script will function 
 	//             correctly.
 	checking_setup();
 	
 	//tagJC<NOTE>: Linking the door model and the trigger at the bottom of the door to the clip
 	linking( level._ClipOnDoor , level._DoorForDoorSwitch );
 	linking( level._ClipOnDoor , level._TriggerOnDoor );
 	
 	//tagJC<NOTE>: Based on proximity, pair up the trigger on the switch, the clip on the door and the 4 triggers around the door
 	pairing( level._DoorSwitchTrigger, level._ClipOnDoor, level._TriggerOnDoor, level._TriggerUnderDoor, level._TriggerOnFloor, level._TriggerOnTop );
 	
 	println ( "In the main of DoorSwitch" );
 	////tagJC<NOTE>: Activate all the switch triggers around the level
 	for ( i = 0; i < level._DoorSwitchTrigger.size; i++)
 	{
 		level._DoorSwitchTrigger[i] thread ActivateDoorTrigger();
 	} 
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 //tagJC<NOTE>: self is the trigger on top of the switch
 ActivateDoorTrigger()
 {
 	//tagJC<NOTE>: If the door reaches the highest point it can reach, disable the switch.  Move the following logic to game logic side
 	self endon ( NOTIFY_MESSAGE_DISABLE_DOOR_SWITCH );
 	
 	self usetriggerrequirelookat();
 	
 	//tagJC<NOTE>: Use level defined hint string (possibly defined for the game mode) if it is defined
 	if ( isDefined( level._HintStringForDoorSwitch ))
 	{
 		hint_string = level._HintStringForDoorSwitch;
 	}
 	else
 	{
 		//tagJC<NOTE>: Else, use the default hint string
 		hint_string = HINT_STRING_FOR_TRIGGER;
 	}
 
 	self SetHintString ( hint_string );
 
 	//tagJC<NOTE>: The door is at the initial completely closed state
 	self.state = DOOR_STATE_COMPLETELY_CLOSED;
 	self.isOpening = 0;
 
 	//tagJC<NOTE>: Based on the distance that the door is able to move, calculate its speed
 	door_opening = distance (self.pairedTriggerTop.origin, self.pairedTriggerFloor.origin );
 	door_speed = door_opening / TIME_OPEN_DOOR;
 
 	while (1)
 	{
 		self waittill( "trigger", player );
 		
 		if ( isDefined( level._canPlayerUseDoor ))
 		{
 			result = [[level._canPlayerUseDoor]]( player, self, self.state );
 		}
 		else 
 		{
 			result = defaultCanPlayerUseDoor( player, self, self.state );
 		}
 
 		if( result && isDefined( level._doorActivationSound ))
 		{
 			self [[level._doorActivationSound]]( player );
 		}
 
 		//println( "result is " + result);
 		//tagJC<NOTE>: If the door is currently not opening, open the door
 		if ( result && self.isOpening == 0)
 		{
 			//tagJC<NOTE>: Play the opening sound on the door if the desired sound is defined in the level
 			if ( isDefined ( level._doorOpeningSound ))
 			{
 				self [[level._doorOpeningSound]]();
 
 			}
 			self.state = DOOR_STATE_OPENING;
 			self.isOpening = 1;
 			self notify( NOTIFY_MESSAGE_DOOR_OPENING );
 			level notify( NOTIFY_MESSAGE_DOOR_OPENING );
 			//tagJC<NOTE>: Stop the script to kill players who are stuck since the door is opening
 			self notify( "stop_killing_player" );
 			//tagJC<NOTE>: Test whether the door is at the highest point that it can reach
 			if ( isDefined( level._shouldTheObjectiveEnd ))
 			{
 				self thread [[level._shouldTheObjectiveEnd]]();
 			}
 			else 
 			{
 				self thread IsDoorAtTop();
 			}
 			//tagJC<NOTE>: Move the door upward
 			distance_to_open = distance (self.pairedTriggerTop.origin, self.pairedTriggerOn.origin );
 			time_to_open = distance_to_open / door_speed;
 			self.pairedClip notify( "movedone" );
 			self.pairedClip MoveZ( distance_to_open, time_to_open, time_to_open * 0.5, time_to_open * 0.4);  
 		}
 		else if ( result && self.isOpening == 1)
 		{
 			//tagJC<NOTE>: Play the closing sound on the door if the desired sound is defined in the level
 			if ( isDefined ( level._doorClosingSound ))
 			{
 				self [[level._doorClosingSound]]();
 
 			}
 			self.state = DOOR_STATE_CLOSING;
 			self.isOpening = 0;
 			self notify( NOTIFY_MESSAGE_DOOR_CLOSING );
 			//tagJC<NOTE>: Test whether the door is at the lowest point that it can reach
 			self thread IsDoorAtBottom();
 			//tagJC<NOTE>: Kill any players who are stuck underneath the door
 			self thread KillPlayersUnder();
 			//tagJC<NOTE>: Move the door downward
 			distance_to_close = distance( self.pairedTriggerFloor.origin, self.pairedTriggerOn.origin );
 			time_to_close = distance_to_close / door_speed;
 			self.pairedClip notify( "movedone" );
 			self.pairedClip MoveZ( distance_to_close * -1, time_to_close, time_to_close * 0.5, time_to_close * 0.4);
 		}
 		wait ( 1 );
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 //tagJC<NOTE>: The default door behavior is that everyone (regardless of the team) can use the door 
 defaultCanPlayerUseDoor( player, trigger, door_state )
 {
 	return true;
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 //tagJC<NOTE>: self is the door switch
 IsDoorAtBottom()
 {
 	self endon ( NOTIFY_MESSAGE_DOOR_OPENING );
 	self endon ( NOTIFY_MESSAGE_DISABLE_DOOR_SWITCH );
 		
 	while ( 1 )
 	{
 		if ( self.pairedTriggerOn.origin[2] == self.pairedTriggerFloor.origin[2] )
 		{
 			if ( isDefined( level._doorCompletelyCloseSound ) && ( self.state != DOOR_STATE_COMPLETELY_CLOSED ))
 			{
 				self [[level._doorCompletelyCloseSound]]();
 			}
 			self notify ( NOTIFY_MESSAGE_DOOR_AT_BOTTOM );
 			self.state = DOOR_STATE_COMPLETELY_CLOSED;
 		}
 		wait 0.5;
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 //tagJC<NOTE>: self is the door switch
 IsDoorAtTop()
 {
 	self endon ( NOTIFY_MESSAGE_DOOR_CLOSING );
 	self endon ( NOTIFY_MESSAGE_DISABLE_DOOR_SWITCH );
 	
 	while ( 1 )
 	{
 		if ( self.pairedTriggerOn.origin[2] == self.pairedTriggerTop.origin[2] )
 		{
 			if ( isDefined( level._doorCompletelyOpenSound ) && ( self.state != DOOR_STATE_COMPLETELY_OPENED ))
 			{
 				self [[level._doorCompletelyOpenSound]]();
 			}
 			//tagJC<NOTE>: Once the door reaches the top, make the proper notify and change the state
 			self notify ( NOTIFY_MESSAGE_DOOR_AT_TOP );
 			self.state = DOOR_STATE_COMPLETELY_OPENED;
 		}
 		wait 0.5;
 	}
 }
 
 //*******************************************************************
 //                                                                  *
 //                                                                  *
 //*******************************************************************
 //tagJC<NOTE>: self is the trigger on top of the door switch
 KillPlayersUnder()
 {
 	self endon ( "stop_killing_player" );	
 
 	while ( 1 )
 	{
 		self.pairedTriggerUnder waittill( "trigger", player);
 
 		if (( player IsTouching( self.pairedTriggerOn ))) // && ( player IsTouching( Trigger2 )))
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
 pairing( trigger_list, clip_list, trigger_on_list, trigger_under_list, trigger_floor_list, trigger_top_list )
 {
 	for ( i = 0; i < trigger_list.size; i++ )
 	{
 		//tagJC<NOTE>: Determine the door clip, and the four triggers around the door that are the closest to the current 
 		//             switch trigger under examination
 		paired_clip = find_closest( trigger_list[i], clip_list );
 		paired_trigger_on = find_closest( trigger_list[i], trigger_on_list );
 		paired_trigger_under = find_closest( trigger_list[i], trigger_under_list );
 		paired_trigger_floor = find_closest( trigger_list[i], trigger_floor_list );
 		paired_trigger_top = find_closest( trigger_list[i], trigger_top_list );
 		
 		//tagJC<NOTE>: Putting those closest entities as the member data for the switch trigger
 		trigger_list[i].pairedClip = paired_clip;
 		trigger_list[i].pairedTriggerOn = paired_trigger_on;
 		trigger_list[i].pairedTriggerUnder = paired_trigger_under;
 		trigger_list[i].pairedTriggerFloor = paired_trigger_floor;
 		trigger_list[i].pairedTriggerTop = paired_trigger_top;
 
 		//tagJC<NOTE>: Useful debugging message
 		//IPrintLnBold( "clip at " + paired_clip.origin + " is paired with switch trigger at " + trigger_list[i].origin);
         //IPrintLnBold( "Trigger_on at " + paired_trigger_on.origin + " is paired with switch trigger at " + trigger_list[i].origin);		
 		//IPrintLnBold( "Trigger_under at " + paired_trigger_under.origin + " is paired with switch trigger at " + trigger_list[i].origin);
 		//IPrintLnBold( "Trigger_floor at " + paired_trigger_floor.origin + " is paired with switch trigger at " + trigger_list[i].origin);
 		//IPrintLnBold( "Trigger_top at " + paired_trigger_top.origin + " is paired with switch trigger at " + trigger_list[i].origin);
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
 //tagJC<NOTE>: Check for matching numbers of entities for door models, clips and triggers
 checking_setup ()
 {
 	set_count = level._DoorSwitch.size;
 	if ( level._DoorSwitchTrigger.size != set_count )
 	{
 		AssertEX( false , "The number of switch trigger needs to equal to the number of switch.  There are " + set_count + " switch in the level.  However, there are " + level._DoorSwitchTrigger.size + " switch trigger in the level." );
 	}
 	if ( level._ClipOnDoor.size != set_count )
 	{
 		AssertEX( false , "The number of door clip needs to equal to the number of switch.  There are " + set_count + " switch in the level.  However, there are " + level._ClipOnDoor.size + " door clips in the level." );
 	}
 	if ( level._DoorForDoorSwitch.size != set_count )
 	{
 		AssertEX( false , "The number of door models needs to equal to the number of switch.  There are " + set_count + " switch in the level.  However, there are " + level._DoorForDoorSwitch.size + " door models in the level." );
 	}
 	if ( level._TriggerOnDoor.size != set_count )
 	{
 		AssertEX( false , "The number of triggers on door needs to equal to the number of switch.  There are " + set_count + " switch in the level.  However, there are " + level._TriggerOnDoor.size + " triggers on door." );
 	}
 	if ( level._TriggerUnderDoor.size != set_count )
 	{
 		AssertEX( false , "The number of triggers under door needs to equal to the number of switch.  There are " + set_count + " switch in the level.  However, there are " + level._TriggerUnderDoor.size + " triggers under door." );
 	}
 	if ( level._TriggerOnFloor.size != set_count )
 	{
 		AssertEX( false , "The number of triggers on floor needs to equal to the number of switch.  There are " + set_count + " switch in the level.  However, there are " + level._TriggerOnFloor.size + " triggers on floor." );
 	}
 	if ( level._TriggerOnTop.size != set_count )
 	{
 		AssertEX( false , "The number of triggers on top of the door needs to equal to the number of switch.  There are " + set_count + " switch in the level.  However, there are " + level._TriggerOnTop.size + " triggers on top of the door." );
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


maps/mp/_compass.gsc setupMiniMap(material)
 {
 	// use 0 for no required map aspect ratio.
 	requiredMapAspectRatio = level._requiredMapAspectRatio;
 
 	corners = getentarray("minimap_corner", "targetname");
 	if (corners.size != 2)
 	{
 		println("^1Error: There are not exactly two \"minimap_corner\" entities in the map. Could not set up minimap.");
 		return;
 	}
 	
 	corner0 = (corners[0].origin[0], corners[0].origin[1], 0);
 	corner1 = (corners[1].origin[0], corners[1].origin[1], 0);
 	
 	cornerdiff = corner1 - corner0;
 	
 	north = (cos(getnorthyaw()), sin(getnorthyaw()), 0);
 	west = (0 - north[1], north[0], 0);
 	
 	// we need the northwest and southeast corners. all we know is that corner0 is opposite of corner1.
 	if (vectordot(cornerdiff, west) > 0) {
 		// corner1 is further west than corner0
 		if (vectordot(cornerdiff, north) > 0) {
 			// corner1 is northwest, corner0 is southeast
 			northwest = corner1;
 			southeast = corner0;
 		}
 		else {
 			// corner1 is southwest, corner0 is northeast
 			side = vecscale(north, vectordot(cornerdiff, north));
 			northwest = corner1 - side;
 			southeast = corner0 + side;
 		}
 	}
 	else {
 		// corner1 is further east than corner0
 		if (vectordot(cornerdiff, north) > 0) {
 			// corner1 is northeast, corner0 is southwest
 			side = vecscale(north, vectordot(cornerdiff, north));
 			northwest = corner0 + side;
 			southeast = corner1 - side;
 		}
 		else {
 			// corner1 is southeast, corner0 is northwest
 			northwest = corner0;
 			southeast = corner1;
 		}
 	}
 	
 	// expand map area to fit required aspect ratio
 	if ( requiredMapAspectRatio > 0 )
 	{
 		northportion = vectordot(northwest - southeast, north);
 		westportion = vectordot(northwest - southeast, west);
 		mapAspectRatio = westportion / northportion;
 		if ( mapAspectRatio < requiredMapAspectRatio )
 		{
 			incr = requiredMapAspectRatio / mapAspectRatio;
 			addvec = vecscale( west, westportion * (incr - 1) * 0.5 );
 		}
 		else
 		{
 			incr = mapAspectRatio / requiredMapAspectRatio;
 			addvec = vecscale( north, northportion * (incr - 1) * 0.5 );
 		}
 		northwest += addvec;
 		southeast -= addvec;
 	}
 	
 	level._mapSize = vectordot(northwest - southeast, north);
 	
 	setMiniMap(material, northwest[0], northwest[1], southeast[0], southeast[1]);
 }
 
 vecscale(vec, scalar)
 {
 	return (vec[0]*scalar, vec[1]*scalar, vec[2]*scalar);
 }