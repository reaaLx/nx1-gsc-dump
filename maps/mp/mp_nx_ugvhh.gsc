
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
 	maps\mp_nx_ugvhh_precache::main();
 	//maps\mp_nx_ugvhh_anim::main();
 	maps\mp_nx_ugvhh_fx::main();
 	maps\_load::main();
 
 	// Internal Initialization
 	mission_flag_inits();
 	mission_precache();
 }
 */
 
 main()
 {
 	maps\mp\mp_nx_ugvhh_precache::main();
 	maps\createart\mp_nx_ugvhh_art::main();
 	maps\mp\mp_nx_ugvhh_fx::main();
 
 	maps\mp\_load::main();
 
 	maps\mp\_compass::setupMiniMap("compass_map_mp_nx_ugvhh");
 
 	ambientPlay( "ambient_mp_dist_big_battle" );
 	
 	game["attackers"] = "allies";
 	game["defenders"] = "axis";
 
 	maps\mp\_doorbreach::doorbreach_setup( 0 );
 	level.KillingDoorControllingLogic = maps\mp\gametypes\escortplus::escortPlusKillingDoorLogic;
 
 	precacheModel( "vehicle_osprey" );
 	precacheMpAnim( "nx_vh_escort_ugv_dropoff_osprey" );
 
 	precacheMpAnim( "nx_vh_escort_ugv_dropoff_ugv" );
 
 	precacheModel( "nx_vehicle_escort_ugv_cargo_holder" );
 	precacheMpAnim( "nx_vh_escort_ugv_dropoff_cargo_holder" );
 
 	if( isDefined( level._mode_escortplus ))
 	{
 		level._missionScript = ::missionScriptEscort;
 		level._missionType = ::missionTypeEscort;
 	}
 	else if( isDefined( level._mode_convoy ))
 	{
 		level._missionScript = ::missionScriptConvoy;
 		level._missionType = ::missionTypeConvoy;
 	}
 
 	//These are the Hit Hard intros, they contain instructions about capturing the L.Z.
 	//over writing the generic ones, since this map has specific intro instructions.
 	
 	game["dialog"]["offense_obj"] = "off_startmatch";
 	game["dialog"]["defense_obj"] = "def_startmatch";
 }
 
 // All mission specific PreCache calls
 mission_precache()
 {
 }
 
 // All mission specific flag_init() calls
 mission_flag_inits()
 {
 }
 
 //defines the mission types
 missionTypeEscort( objective )
 {
 	rv = "null";
 	switch( objective )
 	{
 		case 1:
 			rv = "capture";
 			break; 
 		case 2:
 			rv = "escort";
 			break; 
 		case 3:
 			rv = "open";
 			break; 
 		case 4:
 			rv = "escort";
 			break; 
 		case 5:
 			rv = "escort";
 			break; 
 		default:
 			rv = "null";
 			break; 
 	}
 	return rv;
 }
 
 missionScriptEscort( objective )
 {
 	rv = true;
 	switch( objective )
 	{
 		case 0:
 			maps\mp\gametypes\escortplus::objectiveSetText( 1, &"OBJECTIVES_UGVHH_A_OBJECTIVE01", &"OBJECTIVES_UGVHH_D_OBJECTIVE01" );
 			maps\mp\gametypes\escortplus::objectiveSetText( 2, &"OBJECTIVES_UGVHH_A_OBJECTIVE02", &"OBJECTIVES_UGVHH_D_OBJECTIVE02" );
 			maps\mp\gametypes\escortplus::objectiveSetText( 3, &"OBJECTIVES_UGVHH_A_OBJECTIVE03", &"OBJECTIVES_UGVHH_D_OBJECTIVE03" );
 			maps\mp\gametypes\escortplus::objectiveSetText( 4, &"OBJECTIVES_UGVHH_A_OBJECTIVE04", &"OBJECTIVES_UGVHH_D_OBJECTIVE04" );
 			maps\mp\gametypes\escortplus::objectiveSetText( 5, &"OBJECTIVES_UGVHH_A_OBJECTIVE05", &"OBJECTIVES_UGVHH_D_OBJECTIVE05" );
 
 			//brief texts, set these for the objective text in the upper right hand corner
 			maps\mp\gametypes\escortplus::objectiveSetBriefText( 1, &"OBJECTIVES_ESC_A_VIRUS", &"OBJECTIVES_ESC_D_VIRUS" );
 			maps\mp\gametypes\escortplus::objectiveSetBriefText( 2, &"OBJECTIVES_ESC_A_PUSH", &"OBJECTIVES_ESC_D_PUSH" );
 			maps\mp\gametypes\escortplus::objectiveSetBriefText( 3, &"OBJECTIVES_ESC_A_OPEN", &"OBJECTIVES_ESC_D_OPEN" );
 			maps\mp\gametypes\escortplus::objectiveSetBriefText( 4, &"OBJECTIVES_ESC_A_PUSH", &"OBJECTIVES_ESC_D_PUSH" );
 			maps\mp\gametypes\escortplus::objectiveSetBriefText( 5, &"OBJECTIVES_ESC_A_PUSH", &"OBJECTIVES_ESC_D_PUSH" );
 			break; 
 		case 1:
 			maps\mp\gametypes\escortplus::objectiveSwitch( "escort_switch", "escort_trigger", 15.0, 0.0 );
 			break; 
 		case 2:
 			FlyInDropOffUGV();
 			maps\mp\gametypes\escortplus::objectiveCreateEscortVehicle();
 			maps\mp\gametypes\escortplus::objectiveEscortToCheckPoint();
 			break; 
 		case 3:
 			maps\mp\gametypes\escortplus::objectiveDoorFullyOpened( 0 );
 			break; 
 		case 4:
 			maps\mp\gametypes\escortplus::objectiveEscortToCheckPoint( "pushToTheElevator" );
 			break; 
 		case 5:
 			maps\mp\_killingDoor::main();
 			while ( 1 )
 			{
 				if ( level.escortPlusKillingDoorClosed == 2 )
 				{
 					break;
 				}
 				wait ( 0.05 );
 			}
 			maps\mp\gametypes\escortplus::PlayDialog( "UGVOnElevator" );
 			MoveElevatorUp();
 			maps\mp\gametypes\escortplus::objectiveEscortToCheckPoint();
 			break; 
 		default:
 			rv = false;
 			break; 
 	}
 	return rv;
 }
 
 //defines the mission types
 missionTypeConvoy( objective )
 {
 	rv = "null";
 	switch( objective )
 	{
 		case 1:
 			rv = "capture";
 			break; 
 		case 2:
 			rv = "escort";
 			break; 
 		case 3:
 			rv = "open";
 			break; 
 		case 4:
 			rv = "escort";
 			break; 
 		case 5:
 			rv = "escort";
 			break; 
 		default:
 			rv = "null";
 			break; 
 	}
 	return rv;
 }
 
 missionScriptConvoy( objective )
 {
 	rv = true;
 	switch( objective )
 	{
 		case 0:
 			maps\mp\gametypes\convoy::objectiveSetText( 1, &"OBJECTIVES_UGVHH_A_OBJECTIVE01", &"OBJECTIVES_UGVHH_D_OBJECTIVE01" );
 			maps\mp\gametypes\convoy::objectiveSetText( 2, &"OBJECTIVES_UGVHH_A_OBJECTIVE02", &"OBJECTIVES_UGVHH_D_OBJECTIVE02" );
 			maps\mp\gametypes\convoy::objectiveSetText( 3, &"OBJECTIVES_UGVHH_A_OBJECTIVE03", &"OBJECTIVES_UGVHH_D_OBJECTIVE03" );
 			maps\mp\gametypes\convoy::objectiveSetText( 4, &"OBJECTIVES_UGVHH_A_OBJECTIVE04", &"OBJECTIVES_UGVHH_D_OBJECTIVE04" );
 			maps\mp\gametypes\convoy::objectiveSetText( 5, &"OBJECTIVES_UGVHH_A_OBJECTIVE05", &"OBJECTIVES_UGVHH_D_OBJECTIVE05" );
 
 			//brief texts, set these for the objective text in the upper right hand corner
 			maps\mp\gametypes\convoy::objectiveSetBriefText( 1, &"OBJECTIVES_ESC_A_VIRUS", &"OBJECTIVES_ESC_D_VIRUS" );
 			maps\mp\gametypes\convoy::objectiveSetBriefText( 2, &"OBJECTIVES_ESC_A_PUSH", &"OBJECTIVES_ESC_D_PUSH" );
 			maps\mp\gametypes\convoy::objectiveSetBriefText( 3, &"OBJECTIVES_ESC_A_OPEN", &"OBJECTIVES_ESC_D_OPEN" );
 			maps\mp\gametypes\convoy::objectiveSetBriefText( 4, &"OBJECTIVES_ESC_A_PUSH", &"OBJECTIVES_ESC_D_PUSH" );
 			maps\mp\gametypes\convoy::objectiveSetBriefText( 5, &"OBJECTIVES_ESC_A_PUSH", &"OBJECTIVES_ESC_D_PUSH" );
 			break; 
 		case 1:
 			//maps\mp\gametypes\convoy::objectiveSwitch( "escort_switch", "escort_trigger", 15.0, 0.0 );
 			break; 
 		case 2:
 			FlyInDropOffUGV();
 			//maps\mp\gametypes\convoy::objectiveCreateEscortVehicle();
 			//maps\mp\gametypes\convoy::objectiveEscortToCheckPoint();
 			break; 
 		case 3:
 			//maps\mp\gametypes\convoy::objectiveDoorFullyOpened( 0 );
 			break; 
 		case 4:
 			//maps\mp\gametypes\convoy::objectiveEscortToCheckPoint( "pushToTheElevator" );
 			break; 
 		case 5:
 			/*maps\mp\_killingDoor::main();
 			while ( 1 )
 			{
 				if ( level.escortPlusKillingDoorClosed == 2 )
 				{
 					break;
 				}
 				wait ( 0.05 );
 			}
 			maps\mp\gametypes\convoy::PlayDialog( "UGVOnElevator" );
 			MoveElevatorUp();
 			maps\mp\gametypes\convoy::objectiveEscortToCheckPoint();*/
 			break; 
 		default:
 			rv = false;
 			break; 
 	}
 	return rv;
 }
 
 //****************************************************************************
 //* CREATION DATE:  7/28/2011 5:00pm
 //* DESCRIPTION:    Play the initial UGV drop off animation.
 //****************************************************************************
 FlyInDropOffUGV()
 {
 	//tagZP<NOTE> set these values here for the onscreen message players see to let them know what the status is of the UGV drop off.
 	level._escortInboundCountDown = true;
 	level._escortInboundStartTime = getTime();
 	level._escortInboundDuration = 18;
 
 	maps\mp\gametypes\escortplus::updateUGVInboundMessageForAll();
 	
 	//tagJC<NOTE>: This is phase 1 check-in.  In the next iteration, we want to remove all the hard-coded value below 
 	//             and move the information into the data side.  It will be achieved by
 	//             (1) Adding a new tag on the osprey to attach the cargo holder.
 	//             (2) Adding a new tag on the cargo holder to attach the ugv.
 	//             (3) For the cargo holder and ugv respective animation, remove the movement specific reference.  
 	//                 Basically animating them stationary with respect to their model space.
 	//             (4) At the actual drop off sequence, delete the model used by the animation and spawn an actual UGV that
 	//                 can be dropped.
 	DropOffStartLocation = getEnt ( "ugv_dropoff", "targetname" );
 	vehicle_osprey = spawn ( "script_model", DropOffStartLocation.origin  );
 	vehicle_osprey setModel ( "vehicle_osprey" );
 	vehicle_osprey RotateTo ( DropOffStartLocation.angles , 0.1 );
 	nx_vehicle_escort_ugv = spawn ( "script_model", DropOffStartLocation.origin + ( 0, 0, -299.484) );
 	nx_vehicle_escort_ugv setModel ( level._escortUGVModel );
 	nx_vehicle_escort_ugv RotateTo ( ( 0, 171.604, 0 ), 0.1 );
 	nx_vehicle_escort_ugv_cargo_holder = spawn ( "script_model", DropOffStartLocation.origin + ( 0, 0, -303.032) );
 	nx_vehicle_escort_ugv_cargo_holder setModel ( "nx_vehicle_escort_ugv_cargo_holder" );
 	nx_vehicle_escort_ugv_cargo_holder RotateTo ( ( 0, 171.604, 0 ), 0.1 );
 	vehicle_osprey ScriptModelPlayAnim ( "nx_vh_escort_ugv_dropoff_osprey" );
 	nx_vehicle_escort_ugv ScriptModelPlayAnim ( "nx_vh_escort_ugv_dropoff_ugv" );
 	nx_vehicle_escort_ugv_cargo_holder ScriptModelPlayAnim ( "nx_vh_escort_ugv_dropoff_cargo_holder" );
 	vehicle_osprey playsound("mp_ugv_mode_ugv_flyin");
 	wait ( 18.5 );
 	vehicle_osprey delete();
 	nx_vehicle_escort_ugv delete();
 
 	level._escortInboundCountDown = false;
 	level._escortInboundStartTime = -1;
 	level._escortInboundDuration = -1;
 
 	maps\mp\gametypes\escortplus::updateUGVInboundMessageForAll();
 }
 
 //****************************************************************************
 //* CREATION DATE:  7/28/2011 5:00pm
 //* DESCRIPTION:    This function is to move the elevator up before the final check point.
 //****************************************************************************
 MoveElevatorUp()
 {
 	elevator = GetEnt ( "ugv_elevator" , "targetname" );
 	elevator_top_trigger = GetEnt ( "ugv_elevator_top" , "targetname" );
 	elevator_bottom_trigger = GetEnt ( "ugv_elevator_bottom" , "targetname" );
 	move_distance = distance ( elevator_top_trigger.origin, elevator_bottom_trigger.origin );
 	move_time = 15;
 	level thread maps\mp\gametypes\escortplus::waitAndPlayDialog( 13, "UGVTopOfElevator" );
 	elevator MoveZ ( move_distance, move_time, move_time * 0.5, move_time * 0.5 ); 
 	elevator waittill ( "movedone" );
 }