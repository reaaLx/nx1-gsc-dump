//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_LUNAR Intro/Rover Script									**
//                                                                          **
//    Created: 2/24/2010 - Ken Moodie										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_utility_code;
#include maps\_nx_objective_util;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


// All mission specific flag_init() calls
mission_flag_inits()
{
	// Intro Flags
	flag_init ("ec_rover_fires");
	flag_init ("exited_rover");
	flag_init ("entered_rover");
	flag_init ("rover_crashed");
}

//*******************************************************************
//  Intro Checkpoint - KenM      		                            *
//                                                                  *
//*******************************************************************

intro()
{	
	level._player takeallweapons();
	intro_drive();
	// intro_leaving_rover();

}

intro_start()
{
	level._player maps\_moon::set_suit_hud_type( "none" );
	level._player TakeOffHelmet( true );
}

intro_drive()
{
	
	// Spawn the Charlie who drives
	charlie_driver = spawn_targetname("charlie_driver", true);
	charlie_driver gun_remove();
	// Attach the player to the Rover's passenger seat
	rover_charlie = spawn_vehicle_from_targetname( "rover_charlie_spawner" );

	setsaveddvar( "r_spotlightbrightness", "4" );
	setsaveddvar( "r_spotlightstartradius", "60" );
	setsaveddvar( "r_spotlightendradius", "900" );
	rover_charlie vehicle_lights_on( "spot" );
	rover_charlie vehicle_lights_on( "interior" );
	rover_charlie vehicle_lights_on( "running" );

	// Stick Charlie in the driver's seat and animate him
	charlie_driver.animname = "charlie";
	charlie_driver LinkTo( rover_charlie, "tag_driver" );
	
	// Spawn the Player Model
	player_rig = spawn_anim_model( "player_rig" );  
	
	// Start the Rover driving
	rover_charlie StartPath();

	// Stick the player to the passenger seat and limit their look arc
	VArc = 30;
	HArc = 90;
	player_rig LinkTo( rover_charlie, "tag_passenger", (0,0,0), (0,0,0));
	rover_charlie anim_first_frame_solo (player_rig, "rover_intro_drive"); 
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, HArc, HArc, VArc, VArc, true, false ); 
	level._player allowcrouch( false );
	level._player setPlayerAngles( player_rig.angles );

	// fire off localized music
	// level.radio_sound_org = Spawn( "script_origin", ( level._player.origin ) );
	// level.radio_sound_org LinkTo( rover_charlie, "tag_driver" );

	flag_set( "music_intro_rover_drive_starts" );

	thread sound_calls_at_beginning();
	rover_charlie thread stop_rover_music();
	
	// Spawn Some Helmets
	player_helmet = spawn_anim_model( "helmet_player" );
	player_helmet.animname = "helmet_player";
	player_helmet LinkTo( rover_charlie, "tag_passenger" );	

	// Charlie might not need a helmet, he could use the one attached to the character model but it isn't set up to have one.
	charlie_helmet = spawn_anim_model( "helmet_charlie" );
	charlie_helmet.animname = "helmet_charlie";
	charlie_helmet LinkTo( rover_charlie, "tag_driver" );

	//Start Animation on the rover
	rover_charlie.animname = "rover";
	rover_charlie maps\nx_lunar_anim::rover_intro_drive_anim();
	//rover_charlie thread anim_single_solo ( rover_charlie, "rover_intro_drive" );

	// Start Player's Animation for driving Sequence
	rover_charlie thread anim_single_solo( player_rig, "rover_intro_drive" );
	rover_charlie thread anim_single_solo( player_helmet, "rover_intro_drive" );	
	
	// Play Charlie's Driving Sequence Animation 
	rover_charlie thread anim_single_solo( charlie_helmet, "rover_intro_drive" );
	rover_charlie anim_single_solo( charlie_driver, "rover_intro_drive" );

	// This is a temp section
	// For now this just plays a single animation
	// But it should be replaced by randomly choosing from some looping animations
	// While we wait for the player to cross some kind of trigger.
	// Play Charlie's idle animation
	rover_charlie thread anim_single_solo( charlie_helmet, "rover_intro_idle" );
	rover_charlie anim_single_solo( charlie_driver, "rover_intro_idle" );

	// This is a temp section
	// For now we force the player to move into the airlocks using an animation
	// Play the player's animation for the cycle airlocks sequence
	rover_charlie thread anim_single_solo( player_rig, "rover_intro_jump" );

	// Play Charlie's animation to cycle the airlocks and then jump out
	rover_charlie maps\nx_lunar_anim::rover_intro_jump_anim();
	rover_charlie thread anim_single_solo( rover_charlie, "rover_intro_jump" );
	rover_charlie thread anim_single_solo( charlie_helmet, "rover_intro_jump" );
	rover_charlie anim_single_solo( charlie_driver, "rover_intro_jump" );

	// Wait till the animation has finished, then get everyone out
	level._player unlink();

	rover_charlie notify ("rover_parked");
	thread intro_leaving_rover();

	// Clean up
	self vehicle_lights_off( "spot", true );
	self vehicle_lights_off( "interior", true );
	self vehicle_lights_off( "running", true );
	rover_charlie delete();
	charlie_driver delete();
	player_rig delete();
	player_helmet delete();
	charlie_helmet delete();
}

// rover_charlie
stop_rover_music()
{
	// Turn off the radio when the rover stops moving
	self waittill( "reached_end_node" );
	flag_set( "music_intro_rover_drive_stops" );
}

sound_calls_at_beginning()
{
	//iprintln ("this is working");
	//wait 4;
	// iprintln ("now this should work");
	//level._player shellshock( "nx_lunar_drive_in", 6 );
	flag_set( "sfx_int_rover_engsuit_nohelmet_press" );  //(in rover in engineering suit)
	level thread maps\_ambient::setup_new_volume_settings( "nx_lunar_drive_in" );
	wait 0.1;
	thread maps\_utility::set_ambient( "nx_lunar_rover_amb" );
	level._player playsound ( "lunar_rover_drive_in" );
    wait 32;        
    flag_set( "music_intro_rover_drive_stops" );        
	//temporary wait to change the helmet ambience and 
	//sound when he puts on helmet with new anims...
	//should this be in the notetrack, eventually? maybe leave it in 
	//script for timing flexibility, and not have to wait for animation to re-export 
	//in order to move it up a frame or two?
	wait 18;	
	flag_set( "sfx_int_rover_engsuit_helmet_press" );  //(in rover after helmet on)
	level thread maps\_ambient::setup_new_volume_settings( "nx_lunar" );
	thread maps\_utility::set_ambient( "nx_lunar_int" );
	//wait a little bit longer for the airlock animation sequence
	//hack - needs to be timed with animation eventually
	wait 29;   //you walk to the airlock get in, and then charlie hits the depresurize switch
	flag_set( "sfx_int_rover_engsuit_helmet_depress" );  //(in rover after helmet on and airlock depressurized)


	//rover_charlie Vehicle_TurnEngineOff();	

}


intro_leaving_rover()
{

	// Spawn the Charlie with a helmet and set his first goal
	level.charlie_path = spawn_targetname("charlie_path_spawner", "targetname");
	charlie_pause = getnode("charlie_pause", "targetname");
	level.charlie_path cqb_walk( "on" );
	level.charlie_path gun_remove();
	level.charlie_path set_goal_radius( 128);
	level.charlie_path setgoalnode(charlie_pause);
	level.charlie_path thread intro_charlie_waits_for_player();
	flag_set ("exited_rover");
	flag_set ("music_exited_rover");
	flag_set ("sfx_ext_surface_engsuit_depress");  //(on moon surface in engineering suit)

	// Set up first objective marker
	// Align the radio telescope to receive signals from Earth.
	objective_add( 0, "current", &"NX_LUNAR_OBJECTIVE_REALIGN_TELESCOPE" );
	Objective_OnEntity( 0, level.charlie_path );

	// Move the player to the rover rear
	intro_start = GetStruct("intro_start", "targetname"); 
	level._player setOrigin( intro_start.origin );
	level._player setPlayerAngles( intro_start.angles );
	level._player allowcrouch( true );

	// Give the player the freerunning hands
	level._player GiveWeapon( "freerunner_lunar" );
	level._player SwitchToWeapon( "freerunner_lunar" );
	
	thread rover_player_rover_setup();
	// thread rover_fall_death();

	// Save the game
	level thread autosave_now();

	// Charlie - Just up here.
	thread radio_dialogue( "moon_char_intro_43" );

	wait 5;

	// Charlie - Nice view, huh?
	thread radio_dialogue( "moon_char_intro_53" );
}

// Self = Charlie
intro_charlie_waits_for_player()
{
	// Wait until both Charlie and the player have ascended the path
	flag_wait ("reach_tower");
	self waittill ("goal");
	flag_set( "music_charlie_reaches_tower_goal" );

	// Add the panel sub-objective
	objective_marker_use_panel = GetStruct("objective_marker_use_panel", "targetname");
	// Disengage the dish's servo lock.
	objective_Add( 1, "current", &"NX_LUNAR_OBJECTIVE_TOWER_LOCK" );
	objective_AdditionalCurrent( 1 );
	Objective_Position( 0, objective_marker_use_panel.origin );

	thread intro_use_panel();

	// Charlie - I need you to go up this ladder and remove the bolts from the main access panel.
	thread radio_dialogue( "moon_char_intro_51" );

}

intro_use_panel()
{
	// Wait until the player is on the platform
	flag_wait ( "reach_panel" );
	level._player AllowJump(false);

	// Charlie - Open the panel and complete the override.  Instructions will come up in your HUD.
	thread radio_dialogue( "moon_char_intro_56" );

	// Activate the trigger at the panel
	trigger_use_panel = GetEnt( "trigger_use_panel", "script_noteworthy" );
	trigger_use_panel trigger_on();

	// Press X to disengage the servo lock
	trigger_use_panel sethintstring( &"NX_LUNAR_HINT_TOWER_LOCK" );

	// Press X to use panel
	trigger_use_panel waittill( "trigger" );
	Objective_State( 0, "done" );
	Objective_State( 1, "done" );
		
	// Spawn the first EC Rover
	ec_rover_killer = spawn_vehicle_from_targetname_and_drive ( "ec_rover_killer_spawner" );
	ec_rover_killer vehicle_lights_on( "running" );
	ec_rover_killer thread intro_charlie_death_effects();	

	trigger_use_panel trigger_off();
	thread intro_dish_rotates();
	self thread intro_charlie_dies();

}

intro_dish_rotates()
{	
	// Get that dish and rotate it.
	dish = GetEnt("moon_tower_dish_intact", "targetname");
	dish RotateYaw( 180, 30, 5, 5);
}

// Self = Charlie
intro_charlie_dies()
{
	// Wait until the player looks at Charlie
	/*
	charlie_look_target = GetEnt( "charlie_look_target", "targetname");
	while( 1 )
	{
	if( player_looking_at( charlie_look_target.origin ) )
		break;
	wait .1;
	}
	*/
	level thread autosave_now();

	flag_set( "music_charlie_sees_lights" );
	self.animname = "charlie";
	charlie_death_anim_struct = GetStruct("charlie_death_anim_struct", "targetname"); 
	self forceteleport (charlie_death_anim_struct.origin, charlie_death_anim_struct.angles);
	self anim_single_solo( self, "nx_tp_lunar_charlie_death" );
	self kill();

	/*
		// Charlie - Nice Job, buddy. I'm retasking the scope now.
	 radio_dialogue( "moon_char_intro_58" );
	 wait 2;
	// Charlie - Base, are you getting signal? 
	 radio_dialogue( "moon_char_intro_62" );
	 wait 1;
	// Base - We are receiving a transmission on emergency band. Stand by for decrypted message.
	 radio_dialogue( "moon_bc_intro_04" );

	// Send Charlie to the place where he will get shot
	charlie_death_node = getnode( "charlie_death_node", "targetname");
	self setgoalnode (charlie_death_node);
	// Charlie - Good.  That's something.  What?  There's another team out here.  
	thread radio_dialogue( "moon_char_intro_61" );

	// Rover-One, say again.  Who's out there?
	thread radio_dialogue( "moon_bc_intro_05" );
	wait 10.5;

	// Charlie - It's not ours, must be a team from Shackleton.
	thread radio_dialogue( "moon_char_intro_65" );
	// Charlie - It's just one rover.  They're probably having the same issues as us.
	thread radio_dialogue( "moon_char_intro_66" );
	// Charlie - Hey guys! Over here!
	thread radio_dialogue( "moon_char_intro_68" );

	// Charlie does his waving anim
	flag_set( "music_charlie_sees_lights" );
	self.animname = "charlie";
	charlie_death_anim_struct = GetStruct("charlie_death_anim_struct", "targetname"); 
	self forceteleport (charlie_death_anim_struct.origin, charlie_death_anim_struct.angles);
	self anim_single_solo( self, "nx_tp_lunar_charlie_death" );
	self delete();
	*/

	// The rover firing is handled through a notetrack triggered script in nx_lunar_anim, charlie_death()
	
	thread intro_tower_fall();

	// Set up next objective
	// Return to the rover.
	objective_add( 2, "current", &"NX_LUNAR_OBJECTIVE_RETURN_ROVER" );
	objective_marker_rover_rear = GetStruct ("objective_marker_rover_rear", "targetname");
	Objective_Position( 2, objective_marker_rover_rear.origin );

}

// self = an EC Rover
intro_charlie_death_effects()
{
	// Make the rover point its turret at Charlie
	// ec_rover_killer = get_vehicle( "ec_rover_killer_spawner", "targetname");
	self.mgturret[0] TurretFireDisable();
	self.mgturret[0] SetTargetEntity( self );
	self.mgturret[0] SetAISpread( 0 );
	
	// Triggered by animation
	level waittill ( "charlie_hit" );

	wait 27;

	// self.mgturret[0] TurretFireEnable();
	// self.mgturret[0] ShootTurret();

	// Shoot at Charlie
	charlie_target = GetEnt( "fake_impact_charlie", "targetname" );
	MagicBullet( "lunarrifle", self.origin, charlie_target.origin );

	// Charlie bleeds and stops talking
	wait.2;
	PlayFXOnTag( getfx( "charlie_impact" ), level.charlie_path, "J_SpineUpper" );
	radio_dialogue_stop();
	// self.mgturret[0] TurretFireDisable();

	wait 1;
	// Rover-One, what's happening?  Shit.  I've got no vitals from Charlie's suit.  
	thread radio_dialogue( "moon_bc_intro_08" );

	wait 2;
	self thread intro_ec_rover_targets_tower();

	// Damn it, Charlie's gone.  Samms, get out the hell of there!
	thread radio_dialogue( "moon_bc_intro_11" );
}

// Self = an EC Rover
intro_ec_rover_targets_tower()
{
	level._player EnableInvulnerability();
	self.mgturret[0] SetAISpread( 1 );
	self.mgturret[0] SetTargetEntity( level._player );
	self.mgturret[0] TurretFireEnable();

	// Let the impacts hurt the player if they screw around on the tower for too long
	// Omitting for the milestone, suit patch issues.
	// wait 5;
	// level._player DisableInvulnerability();

	/*
	// Cycle through the impact targets by number
	// When we have a new tower collapse anim, we can use this to make it shoot specifically designated points.
	for ( i = 1 ;; i++)
	{
		impact_target = GetEnt( "fake_impact_tower_" + i, "targetname");
		if ( !isdefined( impact_target ) )
			break;	
		wait .1;
		PlayFX( level._effect[ "tower_impact" ], impact_target.origin );
		wait .9;
	}
	*/

	// Rover cleanup
	flag_wait ("rover_trigger_ridge_enemy");
	self delete();
}

intro_tower_fall()
{
	// Activate the fake mantle trigger
	trigger_tower_mantle = GetEnt( "trigger_tower_mantle", "script_noteworthy" );
	trigger_tower_mantle trigger_on();

	// Press X to mantle.
	trigger_tower_mantle sethintstring( &"NX_LUNAR_HINT_MANTLE" );

	trigger_tower_mantle waittill( "trigger" );
	level._player DisableWeapons();

	node_tower_fall = GetStruct( "tower_fall", "script_noteworthy" );	
 
	twr_bottom = spawn_anim_model("twr_bottom");
	twr_top = spawn_anim_model("twr_top");

	moon_tower_base_intact = GetEnt("moon_tower_base_intact", "targetname");
	moon_tower_dish_intact = GetEnt("moon_tower_dish_intact", "targetname");
	moon_tower_base_intact hide();
	moon_tower_dish_intact hide();

    level._player allowcrouch( false );
	level._player EnableInvulnerability();

	player_rig = spawn_anim_model( "player_rig" ); 
	
	player_anim = [];
	player_anim[ "player_rig" ] = player_rig;
	player_anim["twr_bottom"] = twr_bottom;
	player_anim["twr_top"] = twr_top;

	node_tower_fall anim_first_frame(player_anim , "tower_fall");

	arc = 15; 
        
    level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1 ); 

	thread dish_sound_calls();

	node_tower_fall anim_single(player_anim, "tower_fall");

	//node_tower_fall waittill ("tower_fall");	
	
	level._player FreezeControls( false );
	level._player unlink();
	level._player allowcrouch( true );
	level._player AllowJump(true);

	// Clean up
	player_rig delete();
	level notify("tower_done_falling");
	level._player EnableWeapons();

}

dish_sound_calls()
{

	level._player playsound ( "lunar_dish_fall_lr" );
	level._player playsound ( "lunar_dish_fall_lfe" );
	//level thread maps\_ambient::setup_new_volume_settings( "nx_lunar_drive_in" );
	//thread maps\_utility::set_ambient( "nx_lunar_rover_amb" );
	//wait 18;
	//level thread maps\_ambient::setup_new_volume_settings( "nx_lunar" );
	//thread maps\_utility::set_ambient( "nx_lunar_int" );	

}

//*******************************************************************
//  Rover Chase Checkpoint - KenM                                   *
//                                                                  *
//*******************************************************************

rover_chase()
{	
	flag_wait("rover_crashed");
}

rover_chase_start()
{
	level._player GiveWeapon( "freerunner_lunar" );
	level._player SwitchToWeapon( "freerunner_lunar" );

	level._player maps\_moon::set_suit_hud_type( "civilian" );
	level._player PutOnHelmet( true );

	intro_start = GetStruct("intro_start", "targetname"); 
	level._player setOrigin( intro_start.origin );
	level._player setPlayerAngles( intro_start.angles );

	thread rover_player_rover_setup();
	// thread rover_fall_death();
	level notify ("tower_done_falling");
}

rover_spawn_pursuit_ec_rover()
{

	ec_rover_pursuit = spawn_vehicle_from_targetname_and_drive ( "ec_rover_pursuit_spawner" );
	ec_rover_pursuit.mgturret[0] SetAISpread( 3 );
	ec_rover_pursuit vehicle_lights_on( "running" );

	// Rover cleanup
	flag_wait ("rover_trigger_blocker_enemy");
	foreach ( rider in ec_rover_pursuit.riders )
	{
		rider delete();
	}
	ec_rover_pursuit delete();

}

rover_player_rover_setup()
{
	// Spawn the drive-able rover
	rover_player = spawn_vehicle_from_targetname( "rover_player_spawner" );
	fake_impact_rover_front_1 = GetEnt("fake_impact_rover_front_1", "targetname");
	fake_impact_rover_front_1 linkto (rover_player);

	level waittill("tower_done_falling");

	// gravity adjust: 0.17 = regular moon grav
	SetSavedDvar( "phys_global_gravity_scale", 0.4 );

	// Activate the trigger at the Rover's airlock
	trigger_enter_rover = GetEnt( "trigger_enter_rover", "script_noteworthy" );
	trigger_enter_rover trigger_on();
	// Press X to Enter Rover
	trigger_enter_rover sethintstring( &"NX_LUNAR_HINT_ROVER_ENTER" );

	//trigger_wait ("trigger_enter_rover", "script_noteworthy");

	trigger_enter_rover waittill( "trigger" );

	//setting the helmet sfx state
	flag_set( "sfx_int_rover_engsuit_helmet_depress2" );  //(in rover after helmet on and airlock depressurized)
	thread maps\_utility::set_ambient( "nx_lunar_rover_player_amb" );

	// Stick the player inside the rover
	level._player DisableUsability();
	// maps\nx_lunar_anim::back_to_rover(rover_player);
	level._player MountVehicle( rover_player );
	level._player SetPlayerAngles( rover_player.angles );
	level._player EnableSpringyCam( rover_player.angles, 60, 60, 60, 30 );
	level._player allowcrouch( false );
	
	// Turn on the lights. No lights on/off for now.
	setsaveddvar( "r_spotlightbrightness", "4" );
	setsaveddvar( "r_spotlightstartradius", "60" );
	setsaveddvar( "r_spotlightendradius", "900" );
	rover_player vehicle_lights_on( "spot" );

	// Swap out vision set so we can see where we're going
	vision_set_changes( "af_caves_indoors", 0.2 );

	// Update Objectives
	// Drive the rover back to Malapert Station.
	Objective_State( 2, "done" );
	objective_add( 3, "current", &"NX_LUNAR_OBJECTIVE_RETURN_BASE" );
	thread rover_objective_system();

	// Save the game
	level thread autosave_now();

	// Start all the rover functions
	level.rock_hits = 0;
	
	rover_player thread rover_radio_messages();
	thread rover_ec_rover_ridge_sequence();
	//rover_player thread rover_breakable_rocks_setup();
	thread rover_ec_rover_shoots_boulders();
	thread rover_hints();
	rover_spawn_pursuit_ec_rover();
	// thread rover_impact_crater();

	// Cheat to instantly trigger the crash from go.
	// thread rover_crash_debug();
}

rover_hints()
{
	wait 1;
	// RT to drive
	display_hint_timeout( "hint_rover_drive", 5 );	
	// LT/B to brake
	display_hint_timeout( "hint_rover_brake", 5 );	

}

rover_radio_messages()
{
	// Base - Base is on full alert.  We have hostile contact at tower and incursions moving in from the south.
	thread radio_dialogue( "moon_bc_intro_13" );
	// Base - Samms, we'll leave one rover bay open for you.
	thread radio_dialogue( "moon_bc_rov_02" );
	// Base - Get back here, now!
	thread radio_dialogue( "moon_bc_intro_17" );

	flag_wait ("rover_trigger_ridge_enemy");
	// Base - Rover One! Targets on your 10.
	thread radio_dialogue( "moon_bc_rov_03" );
	flag_wait ("rover_trigger_blocker_enemy");
	// Base - We've got eyes on you, Rover One.  Stay on the path.
	thread radio_dialogue( "moon_bc_rov_04" );

	flag_wait ("radio_base_lookout");
	// Base - We'll see you in--damn it! Targets ahead.  Go right now!
	thread radio_dialogue( "moon_bc_rov_06" );
	flag_wait ("big_downhill_impacts");
	// Base - Take the jump!
	thread radio_dialogue( "moon_bc_rov_09" );

	flag_wait ("rover_crashed");
	// Base - Rover One?  What happened?  Are you okay?  Rover one?  Do you copy?
	thread radio_dialogue( "moon_bc_rov_11" );
	// Base - We see you!  We're cycling the nearest airlock. Get in here now!
	thread radio_dialogue( "moon_bc_rov_12" );
}

rover_objective_system()
{

	level endon ("rover_crashed");
	// Defines how close to the goal the rover needs to get for it to count
	// These will be replaced with trigger volumes eventually
	rover_goal_radius = 1000;
	
	// Cycle through the goals by number
	for ( i = 1 ;; i++)
	{
		rover_current_goal = GetStruct( "objective_marker_rover_path_" + i, "targetname");
		if ( !isdefined( rover_current_goal ) )
			break;
		Objective_Position( 3, rover_current_goal.origin );

		// increment to next when distance to goal is less than rover_goal_radius
		while (1)
		{	
			rover_player = get_vehicle("rover_player_spawner", "targetname");
			dist = Distance( rover_player.origin, rover_current_goal.origin);
			//iprintln ("Distance: " + dist);
			if ( dist < rover_goal_radius)
				break;
			wait .1;
		}

	} 
}


rover_breakable_rocks_setup()
{
	// Do this to every rock on the path.
	breakable_rocks = GetEntArray( "lunar_rock_breaker_scriptmodel", "targetname" );
	foreach( rock in breakable_rocks )
	{
		rock thread rover_breakable_rocks_breaker();	
	}
}

// Self = The player's rover (rover_player)
rover_breakable_rocks_breaker()
{
	level endon ("rover_crashed");
	// Wait for damage from shot or vehicle
	self setCanDamage( true );
	self waittill ( "damage", amount, attacker, direction_vec, point, type );		
	
	// Rock destruction FX
	// PlayFX( level._effect[ "rock_explosion" ], self.origin + (0,0,64) );
	level._player playsound ( "lunar_rover_explosions" );

	// Increment the amount of rocks that the player's run over
	level.rock_hits ++;

	// Bump the rover
	rover_player = get_vehicle("rover_player_spawner", "targetname");
	rover_player JoltBody( (self.origin + (0,0,64)), 10 );
	self delete();

}

rover_fall_death()
{
	level endon ("rover_crashed");
	// Wait until the Rover touches a death volume
	flag_wait ("rover_fall_death");

	// You fell off a cliff.
	setdvar( "ui_deadquote", "NX_LUNAR_FAIL_ROVER_CLIFF" );
	maps\_utility::missionFailedWrapper();
}

// Not hooked up yet
rover_shot_death()
{
	level endon ("rover_crashed");
	flag_wait ("rover_shot_death");
	iprintln( "Dead! (Shot to bits)");
}

// Not hooked up yet
rover_slow_death()
{
	level endon ("rover_crashed");
	flag_wait ("rover_shot_death");
	iprintln( "Dead! (Too slow)");
}

rover_ec_rover_ridge_sequence()
{
	flag_wait ("rover_trigger_ridge_enemy");

	// temp for crater demo
	level thread autosave_now();
	ec_rover_ridge = spawn_vehicle_from_targetname_and_drive ("ec_rover_ridge_spawner");
	ec_rover_ridge vehicle_lights_on( "running" );
	wait 2;
	ec_rover_ridge_2 = spawn_vehicle_from_targetname_and_drive ("ec_rover_ridge_spawner");
	ec_rover_ridge_2 vehicle_lights_on( "running" );
	wait 3;

	thread rover_ec_rover_slaughter_sequence();

	// Rover cleanup
	flag_wait ("rover_trigger_blocker_enemy");
	ec_rover_ridge delete();
	ec_rover_ridge_2 delete();
}

rover_ec_rover_slaughter_sequence()
{
	flag_wait ("rover_trigger_slaughter");
	ec_rover_slaughter = spawn_vehicle_from_targetname_and_drive ("ec_rover_slaughter_spawner");
	ec_rover_slaughter vehicle_lights_on( "running" );
	ec_rover_slaughter waittill ("reached_end_node");
	slaughter_guys = ec_rover_slaughter vehicle_unload ("passengers");
	slaughter_guys_target = GetEnt ("slaughter_guys_target", "targetname");
	foreach (guy in slaughter_guys)
	{
		guy.favoriteenemy = slaughter_guys_target;
	}
	thread rover_ec_rover_blocker_sequence();
}

rover_ec_rover_blocker_sequence()
{
	flag_wait ("rover_trigger_blocker_enemy");
	ec_rover_blocker = spawn_vehicle_from_targetname_and_drive ("ec_rover_blocker_spawner");
	ec_rover_blocker vehicle_lights_on( "running" );
	thread rover_crash();

	// Rover cleanup
	flag_wait ("rover_crashed");
	foreach ( rider in ec_rover_blocker.riders )
	{
		rider delete();
	}
	ec_rover_blocker delete();
}

rover_crash_debug()
{
	while ( !level._player buttonPressed( "BUTTON_LSHLDR") )
	{
		wait .1;
	}	
	thread rover_crash();
	wait .1;
	flag_set ("rover_jump");
}

rover_crash()
{
	// Wait for hitting the trigger near the jump
	flag_wait ("rover_jump");

	// restore regular moon gravity
	setsaveddvar( "phys_global_gravity_scale", 0.17 );


	rover = get_vehicle("rover_player_spawner","targetname");
	// rover crash removed for milestone
	/*

	// Start the function that waits to do the visor break overlay
	thread rover_broken_visor_overlay();

	node_rover_crash = GetStruct("rover_crash", "script_noteworthy");

	tent = GetEnt( "tent", "script_noteworthy" );
    tent.animname = "tent";
    tent assign_animtree("tent");

	rover = get_vehicle("rover_player_spawner","targetname");
	
	thread rover_crash_sounds();

	rover.animname = "rover";

	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["rover"] = rover;
	guys["player_rig"] = player_rig;
	guys["tent"] = tent;

	arc = 15; 

	player_rig LinkTo( rover, "TAG_PASSENGER", (0,0,0), (0,0,0) );
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1 );

	node_rover_crash anim_first_frame(guys, "rover_crash");
	node_rover_crash anim_single(guys, "rover_crash");

	// Clean up
	player_rig delete();

	*/
	// Objective Updates
	Objective_State( 3, "done" );
	level notify ("rover_crashed");
	flag_set("rover_crashed");
	flag_set ("music_rover_crashed");	

	// Get player out of rover
	level._player DismountVehicle();
	level._player DisableSpringyCam();
	level._player allowcrouch( true );
	rover delete();

	//restore normal vision set
	vision_set_changes( "nx_lunar", 0 );

	// skip to next checkpoint for milestone
	maps\nx_lunar_get_to_the_armory::get_to_the_armory_start();
	
}

rover_crash_sounds()
{

	//rover = GetEnt( "rover_player", "targetname" );
	//rover Vehicle_TurnEngineOff();
	thread maps\_utility::set_ambient( "nx_lunar_rover_amb" );
	level._player playsound ( "lunar_crash" );
	//level thread maps\_ambient::setup_new_volume_settings( "nx_lunar_drive_in" );
	wait 5;
	wait 15.5;
	level thread maps\_ambient::setup_new_volume_settings( "nx_lunar" );
	thread maps\_utility::set_ambient( "nx_lunar_int" );

}

rover_broken_visor_overlay()
{
	// Triggered by rover crash animation notetrack
	level waittill ("break_visor");

	// create and define the parameters of the overlay
	level.broken_visor = newClientHudElem( level._player );
	level.broken_visor.x = 0;
	level.broken_visor.y = 0;
	level.broken_visor setshader( "nx_lunar_helm_crack_001", 640, 480 );
	level.broken_visor.sort = 50;
	level.broken_visor.postfx = true;
	// level.broken_visor.lowresbackground = true;
	level.broken_visor.alignX = "left";
	level.broken_visor.alignY = "top";
	level.broken_visor.horzAlign = "fullscreen";
	level.broken_visor.vertAlign = "fullscreen";
	level.broken_visor.alpha = 1;
	level.broken_visor.layer = "visor_no_distort";

	// create and define the parameters of the overlay
	//visor_blood = newClientHudElem( level._player );
	//visor_blood.x = 0;
	//visor_blood.y = 0;
	//visor_blood setshader( "nx_lunar_helm_crack_blood", 640, 480 );
	//visor_blood.sort = 50;
	//visor_blood.lowresbackground = true;
	//visor_blood.alignX = "left";
	//visor_blood.alignY = "top";
	//visor_blood.horzAlign = "fullscreen";
	//visor_blood.vertAlign = "fullscreen";
	//visor_blood.alpha = 0;
	//visor_blood.layer = "visor_no_distort";
	
	level.light_l = newClientHudElem( level._player );
	level.light_l.x = 0;
	level.light_l.y = 343;
	level.light_l setshader( "lunar_crack_lights_l", 193, 128 );
	level.light_l.alignX = "left";
	level.light_l.alignY = "top";
	level.light_l.horzAlign = "fullscreen";
	level.light_l.vertAlign = "fullscreen";
	level.light_l.sort = -2;
	level.light_l.alpha = 0;
	level.light_l.layer = "visor_no_distort";
	level.light_l.foreground = true;
	
	level.light_m = newClientHudElem( level._player );
	level.light_m.x = -12;
	level.light_m.y = 185;
	level.light_m setshader( "lunar_crack_lights_m", 102, 135 );
	level.light_m.alignX = "left";
	level.light_m.alignY = "top";
	level.light_m.horzAlign = "fullscreen";
	level.light_m.vertAlign = "fullscreen";
	level.light_m.sort = -2;
	level.light_m.alpha = 0;
	level.light_m.layer = "visor_no_distort";
	level.light_m.foreground = true;
	
	level.light_r = newClientHudElem( level._player );
	level.light_r.x = 440;
	level.light_r.y = 365;
	level.light_r setshader( "lunar_crack_lights_r", 180, 112 );
	level.light_r.alignX = "left";
	level.light_r.alignY = "top";
	level.light_r.horzAlign = "fullscreen";
	level.light_r.vertAlign = "fullscreen";
	level.light_r.sort = -2;
	level.light_r.alpha = 0;
	level.light_r.layer = "visor_no_distort";
	level.light_r.foreground = true;
	
	thread animate_helmet_lights();

	// Remove the cracks once the player removes their helmet
	level waittill ("vehicle_airlock_open");
	level.broken_visor destroy(); 
	//visor_blood destroy(); 
	level.light_l destroy();
	level.light_m destroy();
	level.light_r destroy();
}

animate_helmet_lights()
{
	level endon ("vehicle_airlock_open");
	level endon ("stop_helmet_light_anim");
	
	while (true)
	{
		level.light_l.alpha = 1;
		level.light_r.alpha = 1;
		

		level.light_l fadeovertime( 0.5 );
		level.light_l.alpha = 0;
		//level.light_r fadeovertime( 0.5 );
		//level.light_r.alpha = 0;
		
		wait 0.5;
	}
}

animate_helmet_lights_critical()
{
	level endon ("vehicle_airlock_open");
	
	while (true)
	{
		level.light_l.alpha = 1;
		level.light_m.alpha = 1;
		level.light_r.alpha = 1;
		
		level.light_l fadeovertime( 0.25 );
		level.light_l.alpha = 0;
		level.light_m fadeovertime( 0.25 );
		level.light_m.alpha = 0;
		level.light_r fadeovertime( 0.25 );
		level.light_r.alpha = 0;
		
		wait 0.25;
	}
}

rover_fake_bullet_impacts()
{

	level endon ("turn_off_fake_impacts");

	// Get the origin that's attached to the front of the rover
	fake_impact_rover_front_1 = GetEnt("fake_impact_rover_front_1", "targetname");

	// Offset variables to determine how imprecise the EC Rovers are
	offsetMinX = 32;
	offsetMaxX = 256;
	offsetMinY = 32;
	offsetMaxY = 256;

	randX_offset = RandomIntRange( offsetMinX, offsetMaxX );
	randY_offset = RandomIntRange( offsetMinY, offsetMaxY );

	// Randomize left/right Y offset
	if( cointoss() )
	{
		randY_offset *= -1;
	}

	// Do an explosion
			level._player playsound ( "lunar_rover_explosions" );
			PlayFX( level._effect[ "railgun_impact_explosion" ], (fake_impact_rover_front_1.origin + (randX_offset,randY_offset,-10)) );
	PhysicsExplosionSphere( (fake_impact_rover_front_1.origin + (randX_offset,randY_offset,-10)), 600, 250, 10 );
	
	// Wait a random amount of time then do it again
	wait RandomFloatRange( 1, 2 );
	thread rover_fake_bullet_impacts();
}

rover_ec_rover_shoots_boulders()
{

	for ( i = 1 ;; i++)
	{
		boulder_fallen = GetEnt( "boulder_fallen_" + i, "targetname");
		if ( !isdefined( boulder_fallen ) )
			break;
		boulder_fallen Hide();
	}

	flag_wait ("ec_rover_shoots_boulders");

	falling_boulders_impact_target = GetEnt( "falling_boulders_impact_target", "targetname");
	PlayFX( level._effect[ "railgun_impact_explosion" ], falling_boulders_impact_target.origin );

	for ( i = 1 ;; i++)
	{
		boulder = GetEnt( "boulder_" + i, "targetname");
		if ( !isdefined( boulder ) )
			break;
		boulder_fallen = GetEnt( "boulder_fallen_" + i, "targetname");
		boulder MoveTo( boulder_fallen.origin, 4, .5, .05 );
		boulder RotateTo( boulder_fallen.angles, 4, .5, .05 );
	}

	boulder_1 = GetEnt( "boulder_1", "targetname");
	boulder_1 waittill ( "movedone" );
	boulder_dust = getent( "boulder_dust", "targetname" );
	PlayFX( level._effect[ "boulder_dust_cloud" ], boulder_dust.origin );
	Earthquake( 0.2, 3, boulder_dust.origin, 8500 );

}









