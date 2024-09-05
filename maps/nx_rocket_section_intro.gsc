
//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX_ROCKET_SECTION_INTRO										**
//                                                                          **
//    Created: 7/13/2011 - Justin Rote										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


//*******************************************************************
//                                                                  *
//	INTRO - From the start of the mission to the first rocket		*
//                                                                  *
//*******************************************************************
start()
{
	// Nothing yet
	//start_railgun_ride( "heli_start_ride_intro_combat" );
	//flag_set( "started_intro_from_start" );

	// Black fade in with time param
	thread maps\_introscreen::introscreen_generic_black_fade_in( 5.0 );
	thread maps\nx_rocket_fx::intro_vision_sequencing();
}

main()
{

	thread level_fadein_sfx();

	// Make vignettes use the same FOV as the helicopter turret.
	SetSavedDvar( "cg_fov", 55.0 );

	// AI in this section shoot blanks
	anim.shootEnemyWrapper_func = maps\nx_rocket_util::ShootEnemyWrapper_blanks;
	
	// Wait for intro to finish
	level waittill( "introscreen_complete" );

	if( !flag( "started_intro_from_start" ))
	{
		start_railgun_ride( "heli_player", "cinematic" );
	}

	flag_set("intro_delete_ocean_b");
	flag_set("intro_delete_ocean_c");

	// Start the dialogue thread
	thread intro_dialogue();

	//AUDIO: Bombers flyover
	thread play_sfx_intro();

	// Connects to a new chopper path when entering base alpha
	thread chopper_transition_to_base_alpha();

	// Cleans up all the intro stuff later
	thread cleanup_intro_ents();

	// Main player chopper control script for this section
	level.playerHeli thread chopper_path_intro();

	// Start some low power rumble to simulate chopper bumps
	thread maps\nx_rocket_util::slightly_vibrate_camera();

	//thread maps\nx_rocket_fx::trigger_fog_intro();


	// Prevent the player from being dmaged from behind
	level._player thread maps\nx_rocket_util::player_prevent_damage_from_behind_until_flag( "base_delta_destroyed" );

	flag_wait( "chopper_ride_intro_done" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
section_precache()
{
	PreCacheModel( "vehicle_btr80_machine_gun" );

	// new blackhawk stuff
	PreCacheModel( "viewhands_player_us_army" );
	PreCacheModel( "vehicle_hummer_seat_rb_obj" );

	// targets on BTR, VTOLS, & little birds
	PreCacheShader( "javelin_hud_target_red" );

	precacheItem( "rpg_player" );
}


section_flag_inits()
{
	flag_init( "chopper_transition_one" );
	flag_init( "started_intro_from_start" );

	// tagMJS<NOTE> new blackhawk stuff
	flag_init( "player_gets_in" );
	flag_init( "started_intro_anim" );
	flag_init( "intro_anim_done" );

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Main script to get the vehicle and railgun set up
// JR TODO - This should be broken further. Seperate heli and railgun stuff
start_railgun_ride( sStartNode, sViewFraction )
{
	// Make vignettes use the same FOV as the helicopter turret.
	SetSavedDvar( "cg_fov", 55.0 );
	
	// Cant use railgun untill later
	maps\nx_rocket_railgun::disable_railgun();
	level thread maps\nx_rocket_railgun::RailgunUsage( level._player );

	// Setup the vehicle
	level.playerHeli = maps\_vehicle::spawn_vehicle_from_targetname( sStartNode );
	thread maps\_vehicle::gopath( level.playerHeli );
	level.playerHeli maps\_nx_blackhawk_minigun::player_mount_blackhawk_turret();
	level.playerHeli Vehicle_SetSpeed( 15 );
	level.playerHeli setmaxpitchroll( 5, 10 );
	level.playerHeli EnableLinkTo();
	
	switch ( sViewFraction )
	{
		case "cinematic":
			maps\nx_rocket_util::set_link_view_fraction_cinematic();
			break;
		case "gameplay":
			maps\nx_rocket_util::set_link_view_fraction_gameplay();
			break;
		default:
			assert( false );
			break;
	}		

	// Vehicle cannot die, but player can
	level.playerHeli maps\_vehicle::godon();

	// Debug - This prints out the chopper speed
	//level.playerHeli thread maps\nx_rocket_util::chopper_debug_speed();

	// Player damage shield
	//level._player thread maps\nx_rocket_util::heli_god_mode( "stop_god_mode" );
	//level._player enableinvulnerability();
}

// Watches for flags on the chopper path
chopper_path_intro()
{
	thread do_intro_anim();

	flag_wait( "started_intro_anim" );

	/#
	// Add names to choppers
	//level.intro_ally_1 thread maps\nx_rocket_util::draw_chopper_name( "chopper_1" );
	//level.intro_ally_2 thread maps\nx_rocket_util::draw_chopper_name( "chopper_2" ); 
	//level.intro_ally_3 thread maps\nx_rocket_util::draw_chopper_name( "chopper_3" ); 
	//level.intro_ally_4 thread maps\nx_rocket_util::draw_chopper_name( "chopper_4" ); 
	//level.intro_ally_5 thread maps\nx_rocket_util::draw_chopper_name( "chopper_5" ); 
	#/

	// Dan: Track the velocity of the helicopter during the animation.  Velocity placed in self.anim_speed. 
	level.intro_ally_1 thread maps\nx_rocket_util::track_anim_speed();
	level.intro_ally_2 thread maps\nx_rocket_util::track_anim_speed();
	level.intro_ally_3 thread maps\nx_rocket_util::track_anim_speed();
	level.intro_ally_4 thread maps\nx_rocket_util::track_anim_speed();
	//level.intro_ally_5 thread maps\nx_rocket_util::track_anim_speed();

	// FLAG: Wait for cliffside encounter
	flag_wait( "chopper_ride_approaching_cliffside" );

	thread cliffside_encounter();

	flag_wait( "intro_anim_done" );
	thread maps\_utility::set_ambient( "nx_rocket_heli_intro" );
	
	// Dan: Use the tracked velocity to set the helicopters to the velocity they shoudl have coming out of the animation.
	IPS_TO_MPH = 0.0568181818;
	level.intro_ally_1 Vehicle_SetSpeedImmediate( level.intro_ally_1.anim_speed * IPS_TO_MPH );
	level.intro_ally_2 Vehicle_SetSpeedImmediate( level.intro_ally_2.anim_speed * IPS_TO_MPH );
	level.intro_ally_3 Vehicle_SetSpeedImmediate( level.intro_ally_3.anim_speed * IPS_TO_MPH );
	level.intro_ally_4 Vehicle_SetSpeedImmediate( level.intro_ally_4.anim_speed * IPS_TO_MPH );
	//level.intro_ally_5 Vehicle_SetSpeedImmediate( level.intro_ally_5.anim_speed * IPS_TO_MPH );
	level.intro_ally_1 notify( "end_track_anim_speed" );
	level.intro_ally_2 notify( "end_track_anim_speed" );
	level.intro_ally_3 notify( "end_track_anim_speed" );
	level.intro_ally_4 notify( "end_track_anim_speed" );
	//level.intro_ally_5 notify( "end_track_anim_speed" );

	ally_1_offset = level.intro_ally_1 determine_heli_offset( level.playerHeli );
	ally_2_offset = level.intro_ally_2 determine_heli_offset( level.playerHeli );
	ally_3_offset = level.intro_ally_3 determine_heli_offset( level.playerHeli );
	ally_4_offset = level.intro_ally_4 determine_heli_offset( level.playerHeli );

	// Make allied choppers follow the pathed player
	level.intro_ally_1 thread maps\ny_hind::follow_enemy_vehicle( level.playerHeli, ally_1_offset, 0, 2.5 );
	level.intro_ally_2 thread maps\ny_hind::follow_enemy_vehicle( level.playerHeli, ally_2_offset, 0, 2.5 ); 
	level.intro_ally_3 thread maps\ny_hind::follow_enemy_vehicle( level.playerHeli, ally_3_offset, 0, 2.5 );
	level.intro_ally_4 thread maps\ny_hind::follow_enemy_vehicle( level.playerHeli, ally_4_offset, 0, 2.5 );
	//level.intro_ally_5 thread maps\ny_hind::follow_enemy_vehicle( level.playerHeli, ( 2500, 100, 300 ), 0, 2.5 );

	//retriggering amb just in case
	thread maps\_utility::set_ambient( "nx_rocket_heli_intro" );

	// FLAG: A chopper blows up during cliffside encounter
	flag_wait( "chopper_ride_cliffside_chopper_crash" );
	level.intro_ally_4 thread rpg_guy_fires_at_chopper();

	// Move chopper 3 behind the player
	level.intro_ally_3 maps\ny_hind::adjust_follow_offset_angoff( ( -1900, 0, 0 ), 0, 2.5 );

	//retriggering amb just in case
	thread maps\_utility::set_ambient( "nx_rocket_heli_intro" );

	// FLAG: An allied chopper will drop down and shoot rockets at enemies
	flag_wait( "chopper_ride_cliffside_chopper_shoot" );
	level.intro_ally_2 thread maps\ny_hind::follow_enemy_vehicle( level.playerHeli, ( 1500, -100, 145 ), 0, 3.5 );
	level.intro_ally_1 maps\ny_hind::adjust_follow_offset_angoff( ( 1200, -600, 150 ), 0, 1.5 );
	level.intro_ally_1 thread chopper_fires_at_ground(); 

	// Get chopper 3 out of view so it can despawn
	flag_wait( "chopper_ride_cliffside_final_turn" );
	wait 2.0;
	level.intro_ally_3 maps\ny_hind::adjust_follow_offset_angoff( ( -2100, 300, 0 ), 0, 2.5 );
	wait 2.5;
	level.intro_ally_3 maps\ny_hind::adjust_follow_offset_angoff( ( -2500, 1100, 0 ), 0, 2.5 );

	//retriggering amb just in case
	thread maps\_utility::set_ambient( "nx_rocket_heli_intro" );

	// Leaving this section
	flag_wait( "chopper_transition_one" );
}

determine_heli_offset( target )
{
	//reverse the logic from maps\ny_hind::follow_enemy_vehicle so that they don't have a starting error after the vignette.
	// s = p + m1v1 + m2v2 + m3v3, where v1, v2, v3 are orthonormal, and m1, m2, m3 are components of offset vector m.
	// m = ( (s-p).v1, (s-p).v2, (s-p).v3 )

	v1 = VectorNormalize( target Vehicle_GetVelocity() ); //forward velocity direction of target
	v2 = VectorNormalize( VectorCross((0, 0, 1), v1) ); // right vector of velocity direction
	v3 = VectorNormalize( VectorCross( v1, v2 ) ); 

	pos_diff = self.origin - target.origin;
	m = ( VectorDot( pos_diff, v1 ), VectorDot( pos_diff, v2 ), VectorDot( pos_diff, v3 ) );

	return m;
}


do_intro_anim()
{
	wait 5.0;
	flag_set( "started_intro_anim" );
	level._player playsound("scn_rocket_mount_turret");
	level thread maps\nx_rocket_anim::intro_allies_in_chopper_spawn();
	level maps\nx_rocket_anim::intro_choppers_spawn();
	flag_set( "intro_anim_done" );

	transition_node = getstruct( "cliffside_resume_node", "targetname" );
	level.playerHeli ClearAnimScripted();
	level.playerHeli.currentnode = transition_node;
	level.playerHeli thread vehicle_resumepath();
	level.playerHeli GoPath();
	level.playerHeli vehicle_SetSpeedImmediate(85,20,20);
}


// Guy on cliffside fires rpg at chopper, and shoots it down
rpg_guy_fires_at_chopper()
{
	self endon( "death" );
	attractor = missile_createAttractorEnt( self, 100000, 2000 );

	// RPG origin
	rpg_node = getent( "cliffside_rpg_attack_node", "targetname" );

	forward = anglesToForward( self.angles );
	up = anglesToUp( self.angles );

	// Shoot the rpg
	target = self.origin + ( 5500 * forward ) + ( 800 * up );
	magicBullet( "rpg_player", rpg_node.origin, target );
	//Line( rpg_node.origin, target, ( 0.3, 1.0, 0.3 ), 1, 1, 5000 );

	self thread kill_after_time(3.2);	

	while( 1 )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, damageType, modelName, tagName );

		if( damagetype == "MOD_EXPLOSIVE" )
		{
			break;
		}
		else
		{
		}
	}

	self kill();
	self notify( "newpath" );

	self waittill( "death" );
    missile_deleteAttractor( attractor );
}

// Kill the chopper after a bit
kill_after_time( time )
{
	self endon( "death" );
	wait time;
	//iprintln( "timer kill" );
	self kill();
}


// Allied chopper fires two missiles at ground enemies
chopper_fires_at_ground()
{
	wait 2.0;

	// Get the target
	//target = getent( "cliffside_chopper_attack_node", "targetname" );
	target = level.cliffside_target_btr;

	// Make a missile magnet
	attractor = missile_createattractorent( target, 100000, 60000 );

	// Fire the missile
	magicbullet( "sidewinder_straight", self.origin + (0,0,-120), target.origin + (0,0,24) );
	wait 0.25;
	magicbullet( "sidewinder_straight", self.origin + (0,0,-120), target.origin + (0,0,18));

	level.cliffside_target_btr godoff();

	wait 5;
	missile_deleteAttractor( attractor );
}


// Plays some AA fire effects, then stops it
play_aa_fx_for_time( fx, min_time, max_time )
{
	fxmodel = spawn_tag_origin();
	fxmodel.origin = self.origin;
	fxmodel.angles = self.angles;

	PlayFxOnTag( getfx( fx ), fxmodel, "tag_origin" );

	wait randomintrange( min_time, max_time );
	StopFXOnTag( getfx( fx ), fxmodel, "tag_origin" );
}


// Randomly blows up the friendly bombers
randomly_kill_bombers()
{
	if( randomintrange( 1, 10 ) == 1 ) 
	{
		return;
	}
	wait randomfloatrange( 4.5, 8.5 );
	PlayFXOnTag( level._effect[ "nx_explosion_rocket_intro_bombers" ],  self, "tag_origin");
	wait 1;
	self kill();
}


// Makes a chopper switch to a new path
switch_to_new_path( path_node )
{
	self notify( "newpath" );
	node = getstruct( path_node, "targetname" );
	
	self.currentnode = node;

	self thread vehicle_resumepath();
	self GoPath();	
}


// Handles enemy spawning and control for the cliffside encounter
cliffside_encounter()
{
	flag_set("intro_delete_ocean_a");

	// Make most of the allies invulnerable
	level.intro_ally_1 godon();
	level.intro_ally_2 godon();
	level.intro_ally_3 godon();
	//level.intro_ally_4 godon();  // Destined to die

	// All allied actors here have very high vision dist
	allies = GetAIArray( "allies" );
	foreach ( ally in allies )
	{
		maxsightdistsqrd = 17000;
	}

	// Add a spawnfunc to the APC that will turn on their turrets
	ally_copters[ 0 ] = level.intro_ally_1;
	ally_copters[ 1 ] = level.intro_ally_2;
	ally_copters[ 2 ] = level.intro_ally_3;
	ally_copters[ 3 ] = level.intro_ally_4;
	array_spawn_function_noteworthy( "intro_apc", maps\nx_rocket_util::apc_turret_logic, level.playerHeli, ally_copters );

	// Spawn them a few at a time to avoid a huge lag spike
	/*
	vehicles = spawn_vehicles_from_targetname_and_drive( "cliffside_vehicles_group1" );
	maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( vehicles );
	level thread maps\nx_rocket_util::handle_caravan_stopping( vehicles, "chopper_ride_intro_done" );
	*/
	vehicles = maps\nx_rocket_util::caravan_setup( "cliffside_vehicles_group1_", "chopper_ride_intro_done" );
	level.blackhawk_targets = vehicles;

	// Start the thread to let allied copter gunners choose targets
	thread allies_choose_targets( ally_copters );
	
	wait 0.1;
	/*
	vehicles = spawn_vehicles_from_targetname_and_drive( "cliffside_vehicles_group2" );
	maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( vehicles );
	level thread maps\nx_rocket_util::handle_caravan_stopping( vehicles, "chopper_ride_intro_done" );
	*/

	vehicles = maps\nx_rocket_util::caravan_setup( "cliffside_vehicles_group2_", "chopper_ride_intro_done" );
	level.blackhawk_targets = array_combine( level.blackhawk_targets, vehicles );	
	wait 0.1;

	/*
	vehicles = spawn_vehicles_from_targetname_and_drive( "cliffside_vehicles_group3" );
	maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( vehicles );
	level thread maps\nx_rocket_util::handle_caravan_stopping( vehicles, "chopper_ride_intro_done" );
	*/

	vehicles = maps\nx_rocket_util::caravan_setup( "cliffside_vehicles_group3_", "chopper_ride_intro_done" );
	level.blackhawk_targets = array_combine( level.blackhawk_targets, vehicles );	
	wait 0.1;
	
	// NOT A CONVOY
	vehicle = spawn_vehicle_from_targetname( "cliffside_vehicles_group4" );
	level.blackhawk_targets = array_add( level.blackhawk_targets, vehicle );

	// NOT A CONVOY
	vehicle = spawn_vehicle_from_targetname( "cliffside_btr_missile_target" );
	vehicle godon();
	level.cliffside_target_btr = vehicle;
	maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( vehicles );
	level.blackhawk_targets = array_add( level.blackhawk_targets, vehicle );


	/*
	vehicles = spawn_vehicles_from_targetname_and_drive( "cliffside_vehicles_group5" );
	maps\nx_rocket_util::protect_player_helicopter_rear_from_each_vehicle( vehicles );
	level thread maps\nx_rocket_util::handle_caravan_stopping( vehicles, "chopper_ride_intro_done" );
	*/

	vehicles = maps\nx_rocket_util::caravan_setup( "cliffside_vehicles_group5_", "chopper_ride_intro_done" );
	level.intro_cliffside_final_btrs = vehicles;
}

// Chopper transition from intro path to rocket one loop path
chopper_transition_to_base_alpha()
{
	// Wait untill it enters base alpha
	flag_wait( "chopper_transition_one" );

	flag_set("intro_delete_ocean_d");

	//AssertEx( IsDefined( level.playerHeli ), "Tried to transition chopper when level.playerHeli does not exist" );

	// Get rid of old path
	//level.playerHeli thread vehicle_detachfrompath();

	// Get the new path
	//transition_node = getstruct( "chopper_transition_node_one", "targetname" );

	// Use new patch
	//level.playerHeli.currentnode = transition_node;

	// Continue on new path
	//level.playerHeli thread vehicle_resumepath();
	//level.playerHeli GoPath();

	// Transition friendly choppers onto looped paths in base alpha
	level.intro_ally_1 thread maps\nx_rocket_util::transition_chopper_to_new_path( "alpha_chopper_loop_node_1" );
	level.intro_ally_2 thread maps\nx_rocket_util::transition_chopper_to_new_path( "alpha_chopper_loop_node_2" );
}

//Play Intro Bombers sfx
play_sfx_intro()
{
	wait(19.2);
	//Bombers flyover SFX
	//Iprintlnbold( "AUDIO: PLAYING BOMBERS" );
	level._player PlaySound( "scn_roc_intro_bombers_lr" );
	level._player PlaySound( "scn_roc_intro_bombers_lsrs" );
}

// Humvee AI talk about recent events
intro_dialogue()
{
	baker = level.squad[ "ALLY_BAKER" ];
	jenkins = level.squad[ "ALLY_JENKINS" ];
	williams = level.squad[ "ALLY_WILLIAMS" ];

	//Dragon to carrier group Lincoln.  Clear for kinetic strike on Chosun spaceport.  Commence operation Winter Anvil.  
	level thread play_dialogue( "roc_dra_intro_winteranvil", 0 );
	//Keene! Walker! Weapons ready! <turns to pilot> "Guns coming up"
	baker thread play_dialogue( "roc_bak_intro_mandoorguns", 6.5 );
	//All Strike packages set angels twelve and turn to IP Alpha. Execute strike mission bravo-one-zero. Weapons free, over.
	level thread play_dialogue( "roc_dra_intro_angels12ipalpha", 14.4 );
	
	//Roger that. Let's wake 'em up.  
	level thread play_dialogue( "roc_con_intro_letswakethemup", 23.2 );
	//Condor 1, approaching R-Max. 10 seconds. 
	level thread play_dialogue( "roc_con_intro_approachingrmax", 27.2 );
	//Shit! My RF scope just lit up like a fucking Christmas tree!
	level thread play_dialogue( "roc_ven_intro_rfscopelitup", 30.4 );
	//Strobes at 350. Confirm FC lock.  
	level thread play_dialogue( "roc_con_intro_strobesat350", 33 );
	//Taking heavy AAA fire. Condor 1, break right!
	level thread play_dialogue( "roc_ven_intro_condor1breakright", 34.3 );
	//Go evasive! Go evasive!!
	level thread play_dialogue( "roc_con_intro_goevasive", 36 );
	//Incoming, 3 o'clock. Pull up! <scream> <static>
	level thread play_dialogue( "roc_con_intro_incomingpullup", 37.1 );
	//DIVERT! DIVERT! Stay below the ridgeline!
	baker thread play_dialogue( "roc_bak_intro_hugthedeck", 37.4 );
	//Condor 1 report status. 
	level thread play_dialogue( "roc_dra_intro_condor1reportstatus", 41.2 );
	//Condor 1 acknowledge!
	level thread play_dialogue( "roc_dra_intro_condor1acknowledge", 44.1 );

	//Transponder squawks on all flights.  They're gone.
	level thread play_dialogue( "roc_ven_intro_squawkstheyregone", 45.3 );
	//Thunderhawk squadrons, this is fleet command. We cannot allow those rockets to reach orbit.  Close to minimum range and designate targets for rail gun batteries on the Lincoln. 
	level thread play_dialogue( "roc_dra_intro_cannotallowrockets", 50 );
	//Solid copy, Dragon. Deadeye proceeding to IP alpha
	level thread play_dialogue( "roc_ded1_intro_proceeding2ipalpha", 58.1 );
	//Clock in, Zulu.  Time to go to work.
	baker thread play_dialogue( "roc_bak_intro_clockinzulu", 61.2 );
	//We're taking fire!
	level thread play_dialogue( "roc_ded2_intro_takingfire", 70.3 );
	//We're hit!  Losing altitude..
	level thread play_dialogue( "roc_ded2_intro_hitlosingaltitude", 72.1 );
	//Circling back to check for survivors.
	level thread play_dialogue( "roc_ded1_intro_checkforsurvivors", 74.4 );
	//Negative, Deadeye.  We don't have time for search and rescue. Proceed to target point Alpha immediately.
	baker thread play_dialogue( "roc_bak_intro_nosearchandrescue", 76.3 );
	//They could still be alive!
	level thread play_dialogue( "roc_ded1_intro_theycouldbealive", 79.3 );
	//That's an order. 
	baker thread play_dialogue( "roc_bak_intro_thatsanorder", 80.1 );




/*
	wait 2;

	// START SECTION 1 ///////////////////
	// iprintlnbold( "START SECTION 1 DIALOG" );
	// Baker: "The objectives a few mikes from landfall, and were going in hot. Be ready."
//  maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_bak_intro_objective", 0.25 );
	level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_intro_objective", 0 );
	
	wait 1.5;

	// Squad: "Hooah"
//  maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_wil_intro_hooah", 0.25 );
	level.squad[ "ALLY_WILLIAMS" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_wil_intro_hooah", 0 );
	// END SECTION 1 ///////////////////
	
	wait 6;

	// START SECTION 2 ///////////////////
	// iprintlnbold( "START SECTION 2 DIALOG" );
	// Bomber Squad: "Approaching objective point alpha"
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_bom_intro_approachingalpha", 0.25 );

	wait 7;

	//Bombers flyover SFX
	Iprintlnbold( "AUDIO: PLAYING BOMBERS" );
	level._player PlaySound( "scn_roc_intro_bombers_lr" );
	level._player PlaySound( "scn_roc_intro_bombers_lsrs" );

	wait 5;

	// Bomber Squad: "Incoming AA!! Were taking fire!"
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_bom_intro_incomingaa", 0.25 );

	// Williams: "Fuck theyre pulling back!"
//  maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_wil_intro_pullingback", 0.25 );
	level.squad[ "ALLY_WILLIAMS" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_wil_intro_pullingback", 0 );
		
	// Baker: "Pilot drop below the ridgeline! Stay tight on the coast!"
//  maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_bak_intro_pilotdrop", 0.25 );
	level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_intro_pilotdrop", 0 );


	// Command: "Freebird actual do you copy? Freebird actual give me a sitrep. Over."
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_cmd_intro_freebirdcopy", 0.25 );

	wait 1;

	// Command: "We have 6 B-2s down, I repeat 6 B-2s showing KIA."
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_cmd_intro_6b2sdown" , 0.25 );
*/


	/*
	// Jenkins: "God damn, thats gonna be us."
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_jen_intro_goddamn", 0.25 );

	// Baker: "Hold your shit Jenkins!"
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_bak_intro_holdshit", 0.25 );

	// Baker: "Pilot drop below the ridgeline! Stay tight on the coast!"
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_bak_intro_pilotdrop", 0.25 );
	// END SECTION 2 ///////////////////

	wait 5;

	// START SECTION 3 ///////////////////
	// iprintlnbold( "START SECTION 3 DIALOG" ); 
	// Baker: "Deadeye 2-1 checking in, flight of 5 MV-60s holding south 5 miles at angles 2-4-0"
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_bak_intro_checkingin", 0.25 );

	// Command: "Dragon 1-5 copies all. Continue as planned. Push 4 klicks south west to contact."
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_cmd_intro_continuetocontact", 0.25 );
	// END SECTION 3 ///////////////////

	// flag_wait( "chopper_ride_approaching_cliffside" );
	*/

/*
	wait 5;

	// START SECTION 4 ///////////////////
	// iprintlnbold( "START SECTION 4 DIALOG" );
	// Baker: "Dragon 1-5, we have eyes on multiple enemy vehicles on MSR grid pappa victor 2-5-9"
//  maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_bak_intro_eyesonenemy", 0.25 );
	level.squad[ "ALLY_BAKER" ] maps\nx_rocket_util::actor_dialogue_queue( "roc_bak_intro_eyesonenemy", 0 );
*/


	/*
	// Baker: "Are we clear to engage? Over."
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_bak_intro_cleartoengage", 0.25 );
	*/

/*

	// Command: "Affirm, unrestricted ROE. Engage at will."
	maps\nx_rocket_util::wait_play_dialogue_wait( 0.0, "roc_cmd_intro_engageatwill", 0.25 );
	// END SECTION 4 ///////////////////
*/
}


// Delete cliffside enemies and objects when the player leaves the area
cleanup_intro_ents()
{
	flag_wait( "chopper_ride_intro_done" );

	maps\nx_rocket_util::safe_delete_array( level.blackhawk_targets );

	maps\nx_rocket_util::safe_delete( level.intro_ally_3 );
	maps\nx_rocket_util::safe_delete( level.intro_ally_5 );

	flag_wait( "chopper_path_after_reveal" );
	// These BTRs need to be cleaned up later than the rest
	maps\nx_rocket_util::safe_delete_array( level.intro_cliffside_final_btrs );
}

// Allied chopper turrets
allies_choose_targets( ally_copters )
{
	foreach( copter in ally_copters )
	{
		if( IsDefined(copter) && IsDefined(copter.mgturret) && IsDefined( copter.mgturret[0] ) )
			copter.mgturret[0] thread allied_blackhawk_gunner_chooses_targets( ); // Right turret

		if( IsDefined(copter) && IsDefined(copter.mgturret) && IsDefined( copter.mgturret[1] ) )
			copter.mgturret[1] thread allied_blackhawk_gunner_chooses_targets( ); // Left turret
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
get_angle( normal0, normal1 )
{
	adjacent = clamp( VectorDot( normal0, normal1 ), -1, 1 );
	return acos( adjacent );
}

allied_chopper_spray_target( closest, target_origin )
{
	self endon( "death" );
	self endon( "crashing" );
	closest endon( "death" );
	closest endon( "crashing" );

	// Get a script origin target to move around and set it as the target. 
	target = spawn( "script_origin", closest.origin );
	self SetTargetEntity( target );

	// Setup spray algorithm. 
	half_distance = 400;
	distance = half_distance * 2;
	offset = randomvectorrange( half_distance * -1, half_distance );
	start = closest.origin + offset;
	end = target.origin - offset;
	dir = VectorNormalize( end - start );

	// Break the spray into 10 iterations. Basically just move the target around. 
	count = 10;
	for ( ii = 0; ii < count; ii++ )
	{
		// Update the target. 
		start = closest.origin + offset;
		frac = ii / count;
		target.origin = start + ( dir * frac * distance );

		// Debug draw the spray pattern. 
  		//line( self.origin, target.origin, ( frac, 1, 1 ), 1, 1, 1000 );
  		//line( target.origin, target.origin + ( 50, 0, 0 ), ( 1, 0, 0 ), 1, 1, 1000 );

		// Check within target angle. 
		start_time = GetTime();
		while( 1 )
		{
			angle = get_angle( VectorNormalize( target.origin - self GetTagOrigin( "tag_flash" )), AnglesToForward( self GetTagAngles( "tag_flash" )));
			if ( angle < 10 )
			{
				break;
			}
			else if( GetTime() - start_time > 3000 )
			{
				break;
			}

			wait( 0.5 );
		}

		// If out of LOS, break.
		tag_origin = self GetTagOrigin( "tag_flash" );
		trace_passed = BulletTracePassed( tag_origin, closest.origin + ( 0, 0, 16 ), false, self );
		if ( trace_passed )
		{
			continue;
		}

		// Trace failed
		self ClearTargetEntity();
		return;
	}

	// Final cleanup. 
	self ClearTargetEntity();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
// Allied chopper turrets shoot at nearby vehicle targets in LOS
TARGET_FOV = 60;
allied_blackhawk_gunner_chooses_targets( )
{
	max_angle_for_player_view = 10;

	self endon( "death" );
	level endon( "chopper_ride_intro_done" );
	level endon( "base_delta_destroyed" );
	level endon( "chopper_path_leaving_base_alpha" );
	//self SetMode( "auto_nonai" );

	cos_fov = Cos( TARGET_FOV );

	while ( 1 )
	{
		// tagBK< NOTE > Don't shoot at the player. 
		angle_to_player = get_angle( VectorNormalize( level._player.origin - self.origin ), AnglesToForward( self.angles ));
		if ( angle_to_player < max_angle_for_player_view )
		{
			wait RandomFloatRange( 3.0, 5.0 );
			continue;
		}

		targets = level.blackhawk_targets;
		closest = undefined;
		closest_dist_sqr = 900000000;
		forward = AnglesToForward( self.angles );
		foreach ( target in targets )
		{
			if ( isAlive( target ) )
			{
				dist_sqr = DistanceSquared( self.origin, target.origin );
				randomize = RandomFloat( 768 );
				dist_sqr += randomize * randomize; // Add random amount
				if ( dist_sqr < closest_dist_sqr )
				{	
					//check if its behind and should be picked up by the other gunner. 
					valid = VectorDot( forward, target.origin - self.origin ) > cos_fov;
					if ( valid )
					{
						// Bullet trace!
						tag_origin = self GetTagOrigin( "tag_flash" );
						if ( BulletTracePassed( tag_origin, target.origin + ( 0, 0, 16 ), false, self ) )
						{
							closest = target;
							closest_dist_sqr = dist_sqr;
						}
						wait 0.05; // Only one bullettrace per frame
					}
				}
			}
		}

		// Target chosen
		if ( isAlive( closest ) )
		{
			self allied_chopper_spray_target( closest );

			//self SetTargetEntity( closest );
			//self allied_blackhawk_gunner_chose_target( closest );
			//self ClearTargetEntity();
		}
		else
		{
			wait RandomFloatRange( 3.0, 5.0 );
		}
	}
}

allied_blackhawk_gunner_chose_target( target )
{
	target endon( "death" );
	target endon( "crashing" );
	
	// Lose the target if two traces in a row fail
	trace_passed = false;
	while ( 1 )
	{
		/*healthbuffer = 0;
		if ( isDefined( target.healthbuffer ) )
		{
			healthbuffer = target.healthbuffer;
		}

		if ( !isAlive( target ) || target.health - healthbuffer <= 1 )
		{
			return;
		}*/

		tag_origin = self GetTagOrigin( "tag_flash" );
		//line( tag_origin, target.origin, ( 1, 1, 1 ), 1, 1, 40 );

		new_trace_passed = BulletTracePassed( tag_origin, target.origin + ( 0, 0, 16 ), false, self );
		if ( trace_passed || new_trace_passed )
		{
			trace_passed = new_trace_passed;
			wait 0.5;
			continue;
		}

		return;
	}

	wait RandomFloatRange( 3.0, 5.0 );
}

level_fadein_sfx()
{
	//set sound volumes down for intro
	/* iprintln( "setting sounds down!" ); */

	//ambience for intro
	thread maps\_utility::set_ambient( "nx_rocket_intro_new" );

	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 0.1 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 0.1 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 0.1 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 0.1 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 0.1 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 0.1 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 0.1 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 0.1 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 0.1 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 0.1 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 0.1 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 0.1 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 0.1 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 0.1 );
	wait 0.1;
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_rocket_fadein", 0.1 );
	wait 3.5;
	//fade sound in
	/* iprintln( "fading sounds in!" ); */
	level._player deactivatechannelvolumes( "snd_channelvolprio_level", 4.0 );
}
