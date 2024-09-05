//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  nx_hithard_secure.gsc					   					**
//				NOTE: called from nx_hithard.gsc							**
//                                                                          **
//    Created: 1/13/2011 - Brian Marvin										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_nx_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_nx_objective_util;
#include maps\_hud_util;
#include maps\nx_hithard_util; 
		 
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Objective-specific PreCache calls
// NOTE: for any assets other than strings that require precaching, please place them in "nx_hithard::mission_precache()"
precache_strings()
{

}

// Objective specific flag_init() calls
flag_inits()
{
	// "Secure The Motorcade"
	flag_init( "flag_vtol_flyover" ); 						// When VTOL flies over player, triggers effects
	flag_init( "flag_prep_secure" );					  	// Player runs through flag and triggers prep_secure_intersection
	flag_init( "flag_secure_rooftop_prep_complete" ); 		// Once the prep_secure_intersection finishes
	flag_init( "flag_script_vip_guard_almost_dead" );		// Almost all of the vip guard is dead
	flag_init( "flag_script_vip_guard_dead" );				// All vip guard forces are dead
	flag_init( "flag_secure_objective_failed" );			// Secure objective failed
	flag_init( "flag_secure_objective_complete" );			// Main secure objective complete
	flag_init( "flag_secure_vip_vulnerable" );				// In nx_hithard_script_secure.  Defines enemy range where vip guard becomes vulnerable to attack.
	flag_init( "flag_secure_objective_active" );			// Secure objective active - main objective
	flag_init( "flag_script_uav_dropped_smoke" );  		   	// Detect that UAV has dropped smoke
	flag_init( "flag_cortel_window_destroy_01" );			// Guy in cortel building blows out windows
	flag_init( "flag_cortel_window_destroy_02" );			// Guy in cortel building blows out windows	
	flag_init( "flag_secure_rooftop_aware" );
	flag_init( "flag_secure_intro_dialogue_complete" );		// Intro dialogue completes
	
	flag_init( "flag_script_uav_attack_roof" );				// UAVs attacking player
	flag_init( "flag_script_spawnpool_allow" );				// Allow continuous ground spawners
	flag_init( "flag_script_objective_wave_1_active" );		// Wave 1 objective active	
	flag_init( "flag_script_objective_wave_2_active" );		// Wave 2 objective active
	flag_init( "flag_script_ground_threat_id_allow" );		// Allow threat ID on ground troops	
	flag_init( "flag_script_vip_guard_vulnerable_override" );	// Turns on when EnableHurt is on
	flag_init( "flag_script_low_priority_dialogue_allow" );	// Will allow / disallow lower priority dialogue
	flag_init( "flag_script_high_priority_dialogue_allow" );	// Will allow / disallow lower priority dialogue
	flag_init( "flag_script_ground_rush" );					// Have guys on ground rush the motorcade

	flag_init( "_flag_script_attention_pointer_active" );	// Flag for attention pointer

	flag_init( "flag_secure_dpad_pressed" );  				// Waits for player to press dpad left for zoom

	flag_init( "flag_secure_vtol_uav_drop_in_position" );  
	
	// Don't slomo sounds
	SoundSetTimeScaleFactor( "Mission", 0 );
	SoundSetTimeScaleFactor( "Shellshock", 0 );
	SoundSetTimeScaleFactor( "Voice", 0 );
	SoundSetTimeScaleFactor( "Menu", 0 );
	SoundSetTimeScaleFactor( "Effects1", 0 );
	SoundSetTimeScaleFactor( "Effects2", 0 );
	SoundSetTimeScaleFactor( "Announcer", 0 );
	SoundSetTimeScaleFactor( "Music", 0 );
	SoundSetTimeScaleFactor( "ambient", 0 );
	SoundSetTimeScaleFactor( "weapon", 0 );
	SoundSetTimeScaleFactor( "weapon2d", 0 );
	SoundSetTimeScaleFactor( "auto2d", 0 );
	SoundSetTimeScaleFactor( "auto", 0 );
	SoundSetTimeScaleFactor( "element", 0 );	
}

// Objective specific add_hint_string() calls
hint_string_inits()
{	
	// Secure Motorcade hints								            
	add_hint_string( "hint_motorcade_vip_guard_almost_dead", &"NX_HITHARD_SECURE_HINT_VIP_GUARD_ALMOST_DEAD", ::hint_motorcade_vip_guard_almost_dead );	
	add_hint_string( "hint_secure_vulnerable", &"NX_HITHARD_SECURE_HINT_VIP_GUARD_VULNERABLE", ::hint_secure_vulnerable );
	add_hint_string( "hint_secure_zoom", &"NX_HITHARD_SECURE_HINT_ZOOM", ::hint_secure_zoom );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// MOTORCADE: VP's guard is dead
hint_motorcade_vip_guard_almost_dead()
{																	
	return flag( "flag_secure_objective_failed");	
}

// MOTORCADE: VP's guard is vulnerable
hint_secure_vulnerable()
{																	
	return !flag( "flag_secure_vip_vulnerable" ) || flag( "flag_script_vip_guard_almost_dead" ) || flag( "flag_secure_objective_failed" );	
}

// Press D-Pad Left to switch zooms
hint_secure_zoom()
{																	
	return flag( "flag_secure_dpad_pressed" ) || ( level._main_gun_accessory == level._player GetCurrentWeapon() );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
 
// Setup global variables for sniper section
A_secure_globals()
{	
	thread audio_nodes_secure();
	thread sound_play_explosion();
	helivolume = GetEnt( "helicopter_trigger", "targetname" );
	helivolume thread triggerhelicopter();
	// First encounter to start with (0 is default)
	// ONLY CHANGE THIS FOR DEBUG PURPOSES!!!!
	level.encounter_start = 0;

	// enables front text to appear over enemies
	level.show_debug_fronts = false;
	
	// Print a warning message
	if( level.encounter_start != 0 )
	{
		iprintlnbold( "NX_HITHARD_SECURE.GSC WARNING:" );
		iprintlnbold( "Skip to encounter is enabled!" );		
		iprintlnbold( "level.encounter_start is set to '" + level.encounter_start + "'" );
	}

	// Print a warning message
	if( level.show_debug_fronts )
	{
		iprintlnbold( "NX_HITHARD_SECURE.GSC WARNING:" );
		iprintlnbold( "Battle front debug text is enabled!" );		
		iprintlnbold( "level.show_debug_fronts is set to '" + level.show_debug_fronts + "'" );
	}

	// List of encounter functions
	level.encounter_list = 
	[
		::encounter_wave_1,				
		::encounter_uav		
	];	

	// General Variables	
	level.secure_ground_num_guys_allowed = 16;					// # of enemies allowed on ground from spawners
	level.secure_civilian_ai_max = 10;							// Max number of civilian AI allowed
	level.secure_civilian_ai_buffer = 2;						// # of ai allowed near max (32 is max ai, setting this to "4" would make the max civilians in-game 28 ai)	

	level.secure_standard_goalradius = 512;					// Standard goal radius for enemies	
	level.secure_civilian_goalradius = 8;					// Goal radius for VP and other civilians
	level.secure_vip_guard_goalradius = 512;					// Goal radius for vip guard
	level.secure_special_goalradius = 128;						// Goal radius for speciality encounters (buildings)		

	level.secure_vip_vulnerable_grace_time = 5;					// Time (in seconds) before vip guard becomes vulnerable

	level.secure_dialogue_encouragement_time = 5;				// Minimum time requred between kills before baker encourages player

	level.secure_ss_accuracy_badass = 100.0;
	level.secure_ss_accuracy_weak = 0.7;
	level.secure_squad_accuracy_wave_1 = 5.0;
	level.secure_squad_accuracy_wave_2 = 5.0;
	level.secure_global_accuracy_cortel_start = 10.0;
	level.secure_global_accuracy_cortel_end = 100.0;
	level.secure_squad_accuracy_uav = 0.01;	
	level.secure_enemy_accuracy_bon = 30000.0;	

	// Encounter-specific variables									
	level.secure_wave_2_num_enemies = 16;						// # of enemies to proceed past wave_2

	// Non-Tweakable vars
	level.secure_vip_vulnerable_first_time = true;				// Keeps track of the first time vip guard becomes vulnerable
	level.secure_uav_duke_dialog_done = false;
	level.num_uav_smoke_dropped = 0;							// number of smokes dropped by uavs
	level.num_enemies_spawned = 0;								// Counts spawners
	level.secure_human_enemies_num_killed = 0;							// Counter for # of enemies killed during wave_1
	level.secure_vip_hunt_count = 0;
	level.secure_kill_tracker = [];
	level.secure_kill_tracker[ "player" ] = 0;
	level.secure_kill_tracker[ "baker" ] = 0;
	level.secure_kill_tracker[ "duke" ] = 0;
	level.secure_kill_tracker[ "ss" ] = 0;	
	level.secure_kill_tracker[ "other" ] = 0;
	level.secure_ss_cant_die = 0;

	// Player attention focus marker
	level.vip_focus_pointer = GetEnt( "secure_vip_focus", "targetname" );
	
	// Main dialogue array
	level.secure_dialogue = [];
		
	// Dialogue: Baker: "Patriot is being compromised!"
	// Dialogue: Baker: "Patriot needs support!"
	// Dialogue: Baker: "Specter, clear the threats!"	
	// Dialogue: Baker: "Eyes on Patriot!”							
	level.secure_dialogue[ "baker_vip_vulnerable" ] =
	[				
		"hithard_bak_secure_48",
		"hithard_bak_secure_49",
		"hithard_bak_snipe_threats",		
		"hithard_bak_secure_43"
	];

	// Dialogue: Baker: "Keep dropping 'em"	
	// Dialogue: Baker: "Confirmed kill"
	// Dialogue: Baker: "Drop an' pop em boys" 	
	level.secure_dialogue[ "baker_encouragement" ] = 
	[
		"hithard_bak_snipe_keepdrop",
		"hithard_bak_snipe_kill",
		"hithard_bak_snipe_dropem"
	];

	// Dialogue: Duke: "...fucking mess..."	
	// Dialogue: Duke: "Fuck, Fuck, Fuck!"
	// Dialogue: Duke: "Take that. Tin piece of shit!"
	level.secure_dialogue[ "duke_uav_random" ] =
	[		
		"hithard_gyp_secure_03",		
		"hithard_gyp_snipe_01",		
		"hithard_gyp_snipe_tin"
	];

	// Dialogue: SS: "Patriot needs support!"
	// Dialogue: SS: "Getting overrun!  We need more support!"
	// Dialogue: SS: "We're being overrun!"
	// Dialogue: SS: "They're getting too close!"
	// Dialogue: SS: "We need more support!"
	level.secure_dialogue[ "ss_need_help" ] = 
	[
		"hithard_sslead_snipe_support",
		"hithard_sslead_snipe_overrun",
		"hithard_sslead_snipe_05",
		"hithard_sslead_snipe_06",
		"hithard_sslead_snipe_07"
	];	

	// Names for good guys	
	level.secure_vip_guard_names = 
	[ 
		"Flores",
		"Guillote",
		"Hall", 
		"Hughes",
		"Inkel",
		"Johnson", 
		"K", 
		"Kadel",
		"Knutson",
		"Marvin", 
		"Stowater", 
		"Vance",
		"Winte"
	];

	// Set the # of enemies needed to be killed based on diff level
	Assert( IsDefined( level._gameskill ) );
	switch( level._gameSkill )
	{
		case 0:	// Easy
		{
			break;			
		}
		case 1:	// Regular 
		{
			break;	
 		}
		case 2: // Hardened	
		{
			break;	
  		}
		case 3:	// Veteran	
		{			
			break;	
  		}
	}

	//
	// Setup character arrays
	//

	// motorcade enemies array
	level.secure_enemies = [];		
	level.secure_enemies[ "ground" ] = [];
	level.secure_enemies[ "ground_front_0" ] = [];	
	level.secure_enemies[ "spawnpool" ] = [];
	level.secure_enemies[ "cortel_balcony" ] = [];
	level.secure_enemies[ "cortel_terrace" ] = [];
	level.secure_enemies[ "cortel_all" ] = [];
	level.secure_enemies[ "bon_01" ] = [];
	level.secure_enemies[ "bon_02" ] = [];
	level.secure_enemies[ "bon_all" ] = [];
	level.secure_enemies[ "uavs" ] = [];
	level.secure_enemies[ "uavs_attack" ] = [];
	
	// vip
	level.secure_vip= undefined;				
	
	// vip vehicle
	level.secure_vip_vehicle = undefined;

	// vip guard
	level.secure_vip_guard = [];
	level.secure_vip_guard[ "ss" ] = [];				// Secret Service
	level.secure_vip_guard[ "swat" ] = [];				// Swat
	level.secure_vip_guard[ "all" ] = []; 				// All good guys on the ground (minus vip)

	// VTOLs
	level.secure_vtols = [];
	level.secure_vtols[ "vtol_01" ] = [];
	level.secure_vtols[ "vtol_02" ] = [];
	level.secure_vtols[ "vtol_03" ] = [];
  
	// Vehicles
	level.vehicles = [];
	level.vehicles[ "lapd_backup" ] = [];

	// UAV nodes
	level.secure_uav_path = [];
	level.secure_uav_path[ "smoke" ] = [];
	level.secure_uav_path[ "circle1" ] = [];
	level.secure_uav_path[ "circle2" ] = [];

	// Global container for AI civvies
	level.secure_civilians = [];

	// Setup "front" volumes
	level.secure_front = prep_secure_fronts();
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

audio_nodes_secure()
{
	mynode = spawn( "sound_emitter", ( 6919, -1633, -23 ) );
	mynode PlayloopSound( "emt_hh_crowd_screams" );

	mynode2 = spawn( "sound_emitter", ( 7682, -1908, 403 ) );
	mynode2 PlayloopSound( "emt_hh_fire" );

	mynode stopsounds();
	//mynode2 stopsounds();

	wait 0.1;

	mynode delete();
	//mynode2 delete();

	//mynode stopsounds();
	//mynode2 stopsound();

	//wait 0.1;

	//mynode delete();
	//mynode2 delete();

	level waittill( "car_explosion_done" );

	thread set_ambient( "nx_hithard_vicepres" );
}

triggerhelicopter()
{

	self waittill( "trigger" );
	println( "i'm in my trigger volume" );
	level._player playsound( "elm_hh_helicopter_pass" );

}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// First sniping objective (wave_1)
encounter_wave_1()
{	
	flag_set( "flag_script_objective_wave_1_active" );
	flag_set( "flag_script_vip_guard_vulnerable_override" );	

	// Turn on vulnerability for allies
	level.secure_vip_guard[ "ss" ] enable_hurt();

	// Weaken SS guys
	level.secure_vip_guard[ "ss" ] set_ai_accuracy_array( level.secure_ss_accuracy_weak );

	// Set squad accuracy
	level.squad set_ai_accuracy_array( level.secure_squad_accuracy_wave_1 );

	// Turn on attention pointer
	thread enableAttentionPointer( level.vip_focus_pointer, level.secure_vip, level.objective[ "obj_secure_snipe" ] );

	// Reset kill counter
	level.secure_human_enemies_num_killed = 0;

	// Setup hatred			
	//SetThreatBias( "squad", "secure_wave_1", 1000 );		

	guys_unfixed = false;
	guys_rushing = false;
	send_in_uav_vtol = false;	
	position_uav_vtol = false;	

	// Wait for enough wave_1 enemies to be killed around the motorcade before proceeding
	while(  ( level.secure_enemies[ "ground" ].size > 0 ) || ( level.secure_enemies[ "ground_front_0" ].size > 0 ) || flag( "flag_secure_vip_vulnerable" ))
	{						
		// Clean arrays
		level.secure_enemies[ "ground" ] = remove_dead_from_array( level.secure_enemies[ "ground" ] );
		level.secure_enemies[ "ground_front_0" ] = remove_dead_from_array( level.secure_enemies[ "ground_front_0" ] );

		if( ( level.secure_enemies[ "ground" ].size <= 9 ) && !guys_unfixed )
		{
			// Unstick the enemies so they run around
			foreach( guy in level.secure_enemies[ "ground" ] )
			{
				if( isalive( guy ))
				{
					guy set_fixednode_false();
				}
			}

			guys_unfixed = true;
		} 
		else if( ( level.secure_enemies[ "ground" ].size <= 5 ) && !guys_rushing && flag( "flag_script_high_priority_dialogue_allow" ))
		{			
			// Tell enemies to ignore squad
			set_squad_ignore( true );									

			// Send enemies in for the kill			
			level.secure_enemies[ "ground" ] = go_forth_and_die( level.secure_enemies[ "ground" ] );

			guys_rushing = true;			
		}	

		wait 0.05;
	}

	//
	// END
	//	

	// Wait a frame to allow threat detect counter to catch up
	wait 0.05;

	// Turn off ally vulnerability
	level.secure_vip_guard[ "ss" ] disable_hurt();

	// Turn off attention pointer
	DisableAttentionPointer();

	// Turn off threat id for ground guys
	flag_clear( "flag_script_ground_threat_id_allow" );
	//level.secure_enemies[ "ground_front_0" ] thread SetThreatIDOverlay_array( "off" );

	// Kill threat id counter script
	level notify( "notify_secure_objective_wave_1_complete" );

	flag_clear( "flag_script_objective_wave_1_active" );
		
	// Make SS guys badass again
	level.secure_vip_guard[ "ss" ] set_ai_accuracy_array( level.secure_ss_accuracy_badass );
	
	set_squad_ignore( false );
	
	objective_end( "obj_secure_snipe" );	
} 

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Sets squad and player's ignoreme
set_ignore_array( ignore_bool )
{
	if( !isdefined( ignore_bool ))
	{
		AssertMsg( "'ignore_bool' is not defined for set_ignore_squad()" );
	}

	foreach( guy in self )
	{
		guy.ignoreme = ignore_bool;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Sets squad and player's ignoreme
set_squad_ignore( ignore_bool )
{
	if( !isdefined( ignore_bool ))
	{
		AssertMsg( "'ignore_bool' is not defined for set_ignore_squad()" );
	}

	foreach( guy in level.squad )
	{
		guy.ignoreme = ignore_bool;
	}
	
	level._player.ignoreme = ignore_bool;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Baker encourages the player when they make a kill
dialogue_baker_encouragement( end_notify )
{
	level endon( end_notify );

	baker_encouragement = [];
	baker_encouragement = level.secure_dialogue[ "baker_encouragement" ];	

	// Counts the time
	thread counter();

	while( 1 )
	{
		level waittill( "secure_enemy_killed" );

		if( baker_encouragement.size == 0 )
		{
			// Quit when out of dialogue
			return;
		}
		else if( flag( "flag_script_low_priority_dialogue_allow" ))
		{
			// Baker encourages the player
			if( level.time_between_enemy_deaths > level.secure_dialogue_encouragement_time )
			{
				baker_encouragement = play_random_dialogue_safe_and_remove( baker_encouragement );				
				level.time_between_enemy_deaths = 0;   
			}
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Keeps track of time
counter()
{
	level endon( "secure_kill_counter" );

	level.time_between_enemy_deaths = 0;

	while( 1 )
	{
		wait 0.05;
		level.time_between_enemy_deaths = level.time_between_enemy_deaths + 0.05;
	}	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Cortel building encounter
encounter_cortel()
{	
	// Setup hatred
	//SetThreatBias( "secure_wave_cortel", "player", 1000 );	

	// Squad accuracy
	level.squad set_ai_accuracy_array( level.secure_global_accuracy_cortel_start );	

	// Setup ignores
	SetIgnoreMeGroup( "secure_wave_cortel", "secure_vip_guard" );	
	SetIgnoreMeGroup( "secure_vip_guard", "secure_wave_cortel" );
	SetIgnoreMeGroup( "squad", "secure_wave_cortel" );		

	// Threat ID counter
	thread watcher_threat_counter( "cortel_all", "notify_secure_objective_cortel_complete" );

	// Send out UAV VTOL to circle
	thread event_vtol_uav_drop();	

	flag_clear( "flag_script_low_priority_dialogue_allow" );

	// Dialogue: Baker: "Eleven o'clock! Balcony! RPG!"
	dialogue_array = 
	[		
		"hithard_bak_secure_19"
	];
	
	// Player will fail if they don't kill the RPG guy before he blows up VP vehicle
	level.secure_enemies[ "cortel_balcony" ] = spawn_enemy_wave( "motorcade_enemies_rooftop_rpg_01", ::spawnfunc_enemy_cortel_balcony, "secure_wave_cortel", dialogue_array );	
	level.secure_enemies[ "cortel_all" ] = array_combine
		( remove_dead_from_array( level.secure_enemies[ "cortel_balcony" ] ), remove_dead_from_array( level.secure_enemies[ "cortel_all" ] ));

	waittill_dead( level.secure_enemies["cortel_balcony"], undefined, 3 ); 

	//
	//	Terrace enemies
	//

	// Dialogue: Baker: "One o'clock! Terrace! RPG!"
	dialogue_array = 
	[
		"hithard_bak_secure_22"
	];

	level.secure_enemies["cortel_terrace"] = spawn_enemy_wave( "motorcade_enemies_terrace_01", ::spawnfunc_enemy_cortel_terrace, "secure_wave_cortel", dialogue_array );	
	level.secure_enemies[ "cortel_all" ] = array_combine
		( remove_dead_from_array( level.secure_enemies[ "cortel_terrace" ] ), remove_dead_from_array( level.secure_enemies[ "cortel_all" ] ));

	//
	// Inside Cortel building
	//

	// Dialogue: Baker: "Twelve o'clock!  Inside the building!"
	 
	dialogue_array = 
	[
		"hithard_bak_secure_25"	
	];

	level.secure_enemies[ "inside_cortel" ] = spawn_enemy_wave( "motorcade_enemies_cortel_inside_01", ::spawnfunc_enemy_cortel_inside, "secure_wave_cortel", dialogue_array );						
	level.secure_enemies[ "cortel_all" ] = array_combine
		( remove_dead_from_array( level.secure_enemies[ "inside_cortel" ] ),  remove_dead_from_array( level.secure_enemies[ "cortel_all" ] ));	

	thread watcher_enemy_cortel_dead( level.secure_enemies[ "cortel_all" ] );	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Keeps count of threats on the screen
watcher_threat_counter( array_name, end_notify, array_name2 )
{
	level endon( end_notify );

	second_array = false;

 	if( isdefined( array_name2 ))
	{
		second_array = true;
	}	


	while( 1 )
	{
		level.secure_enemies[ array_name ] = remove_dead_from_array( level.secure_enemies[ array_name ] );

		if( second_array )
		{
			level.secure_enemies[ array_name2 ] = remove_dead_from_array( level.secure_enemies[ array_name2 ] );
			level._player SetActiveThreatCount( level.secure_enemies[ array_name ].size + level.secure_enemies[ array_name2 ].size );
		}
		else
		{
			level._player SetActiveThreatCount( level.secure_enemies[ array_name ].size );
		}
		wait 0.05;
	}
}
														
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Bonaventure encoutners
encounter_bon()
{
	radio_dialogue_stop();

	level.secure_vip_guard[ "ss" ] enable_hurt( "bon_01" );

	// Setup hatred
	//setthreatbias( "secure_wave_bon", "secure_vip_guard", 1000 );

	// Dialogue: Baker: "Ten o'clock!  Bridge!  Snipers!"

	dialogue_array = 
	[
		"hithard_bak_secure_27"	
	];

	level.secure_enemies["bon_01"] = spawn_enemy_wave( "bon_01", ::spawnfunc_enemy_bon, "secure_wave_bon", dialogue_array );		

	//
	// END
	//
	 	
	thread watcher_enemy_bon_dead( level.secure_enemies["bon_01"] );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Wait for bon guys to die before setting UAVs to attack sniper perch
watcher_enemy_bon_dead( guy_array )
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );

	living_guys = remove_dead_from_array( guy_array );
	waittill_dead( living_guys );
	
	// Turn off ally vulnerability
	level.secure_vip_guard[ "ss" ] disable_hurt();
  
	// Autosave
	thread autosave_by_name( "nx_hithard_secure_uav");

	level notify( "notify_secure_objective_bon_complete" );

} 

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Wait for bon guys to die before setting UAVs to attack sniper perch
watcher_enemy_cortel_dead( guy_array )
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );

	thread watcher_ally_cortel_focus();

	living_guys = remove_dead_from_array( guy_array );
	waittill_dead( living_guys );

	// Get the numbers on the ground up
	level.secure_ground_num_guys_allowed = level.secure_wave_2_num_enemies;			
  
	// Autosave
	thread autosave_by_name( "nx_hithard_secure_uav");

	// Wait a frame (to let threat counter catch up)
	waittillframeend;

	// Kill threat counter
	level notify( "notify_secure_objective_cortel_complete" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Wait a little bit of time, then sic squad on cortel guys
watcher_ally_cortel_focus()
{
	wait 15.0;

	// Squad accuracy
	level.squad set_ai_accuracy_array( level.secure_global_accuracy_cortel_end );

	// Setup ignores
	//SetIgnoreMeGroup( "secure_wave_1", "squad" );
	//SetIgnoreMeGroup( "secure_wave_1_front_0", "squad" );

	// Set hatred
	SetThreatBias( "squad", "secure_wave_cortel", 999999 );
	SetThreatBias( "secure_wave_cortel", "squad", 1000 );
	
	foreach( guy in level.secure_enemies[ "cortel_all" ] )
	{
		if( isalive( guy ))
		{
			guy.ignoreme = false;			
		}
	}		
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// UAV drop and smoke
encounter_uav()
{	
	// Autosave
	thread autosave_by_name( "nx_hithard_secure_uav");

	// Setup ignores
	SetIgnoreMeGroup( "secure_wave_uavs", "secure_vip_guard" );	
	SetIgnoreMeGroup( "secure_vip", "secure_wave_uavs" );	
	SetIgnoreMeGroup( "squad", "secure_wave_uavs" );
	SetIgnoreMeGroup( "secure_vip_guard", "secure_wave_uavs" );

	// Setup hatred
	SetThreatBias( "secure_wave_uavs", "player", 10000 );

	objective_setpointertextoverride( level.objective[ "obj_secure_snipe" ], "" );	//Clear the pointer text	

	foreach( guy in level.squad )
	{
		guy set_goal_radius( 1024 );
		guy set_ai_accuracy( level.secure_squad_accuracy_uav );
	}

	// Wait a frame (to let threat counter catch up)
	waittillframeend;

	// Drop UAVs 
	thread event_vtol_uav_drop();	

	// Dialogue: Baker: "VTOL Incoming"
	radio_dialogue( "hithard_bak_snipe_09" );

	// Wait until UAVs spawned
	while( level.secure_enemies[ "uavs" ].size == 0 )
	{
		wait 0.05;
	}	
	
	// Dialogue for UAVs
	thread dialogue_baker_uavs();

	// Objective
	objective_start( "obj_secure_uavs", &"NX_HITHARD_SECURE_OBJ_UAVS" );

	// Threat ID counter
	thread watcher_threat_counter( "uavs", "notify_secure_objective_uavs_complete" );				
	
 	// Break front_0 focus
	level notify( "notify_secure_squad_front_0_focus_off" );
		
	// Unstick allies	
	level.squad set_fixednode_false_array();		
	
	while( level.secure_enemies[ "uavs" ].size > 0 )
	{
		wait 0.05;
	}

	level notify( "notify_secure_objective_uavs_complete" );
	objective_end( "obj_secure_uavs" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Wait a little bit, then send spawners out
send_in_spawnpool( wait_time )
{
	if( isdefined( wait_time ))
	{
		wait wait_time;
	}

	// Send out spawners
	flag_set( "flag_script_spawnpool_allow" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

event_end_sequence()
{	
 	// Grab spawners
	spawner_vip_move = GetEnt( "vp_transition", "script_noteworthy" );
	spawner_ss_move = GetEnt( "ss_fodder1", "script_noteworthy" );

	// Make vip vehicle start smoking
	level.secure_vip_vehicle godoff();
	level.secure_vip_vehicle2 godoff();
	exploder( "fx_vip_vehicle_fire" );

	wait 1.0;

	radio_dialogue_stop();
	thread radio_dialogue( "hithard_sslead_snipe_gonnablow" );

	// Grab random SS guys for scene, rest will die
	level.secure_vip_guard[ "ss" ] = remove_dead_from_array( level.secure_vip_guard[ "ss" ] );
   
	level.ss_fodder1 = undefined;
	level.ss_fodder2 = undefined;
	level.ss_fodder3 = undefined;

	if( level.secure_vip_guard[ "ss" ].size >= 3 )
	{
		level.ss_fodder1 = level.secure_vip closest_guy_to();		 
		level.secure_vip_guard[ "ss" ] = array_remove( level.secure_vip_guard[ "ss" ], level.ss_fodder1 );
	
		level.ss_fodder2 = random( level.secure_vip_guard[ "ss" ] );
		level.secure_vip_guard[ "ss" ] = array_remove( level.secure_vip_guard[ "ss" ], level.ss_fodder2 );
	
		level.ss_fodder3 = random( level.secure_vip_guard[ "ss" ] );
		level.secure_vip_guard[ "ss" ] = array_remove( level.secure_vip_guard[ "ss" ], level.ss_fodder3 );
	}
	else
	{
		switch( level.secure_vip_guard[ "ss" ].size )
		{
			case 2:
			{
				level.ss_fodder1 = level.secure_vip closest_guy_to();
				level.secure_vip_guard[ "ss" ] = array_remove( level.secure_vip_guard[ "ss" ], level.ss_fodder1 );
			
				level.ss_fodder2 = random( level.secure_vip_guard[ "ss" ] );
				level.secure_vip_guard[ "ss" ] = array_remove( level.secure_vip_guard[ "ss" ], level.ss_fodder2 );
			
				level.ss_fodder3 = GetEnt( "ss_fodder3", "script_noteworthy" ) spawn_ai();
								
				break;
			}
			case 1:
			{
				level.ss_fodder1 = level.secure_vip closest_guy_to();
				level.secure_vip_guard[ "ss" ] = array_remove( level.secure_vip_guard[ "ss" ], level.ss_fodder1 );
			
				level.ss_fodder2 = GetEnt( "ss_fodder2", "script_noteworthy" ) spawn_ai();
				level.ss_fodder3 = GetEnt( "ss_fodder3", "script_noteworthy" ) spawn_ai();
				break;
			}
			case 0:
			{
				level.ss_fodder1 = GetEnt( "ss_fodder1", "script_noteworthy" ) spawn_ai();
				level.ss_fodder2 = GetEnt( "ss_fodder2", "script_noteworthy" ) spawn_ai();
				level.ss_fodder3 = GetEnt( "ss_fodder3", "script_noteworthy" ) spawn_ai();
				break;
			}
		}
	}

	//level.run_position = vector_multiply( AnglesToForward( AnglesToRight( level.secure_vip_vehicle.angles )), 256 );


	// fodder guy array
	fodder_guys = [ level.ss_fodder1, level.ss_fodder2, level.ss_fodder3 ];

	// Prep the SS guys for next scene
	fodder_guys prep_ss_motorcade_array();
	
	// SS and VP run for cover
	vp_ss_cover = GetEnt( "origin_secure_vp_ss_cover", "targetname" );
	vp_ss_cover thread vp_protect_at_node( level.secure_vip, level.ss_fodder1 );

	vp_ss_cover waittill( "reach_done" );

	fodder_guys run_to_vp();
	level.secure_vip_guard[ "ss" ] run_to_vp();

	flag_set( "music_smoke_battle_ends" );	

	wait 1.0;

	thread car_explode_slow_mo();	
	
	// Kill vehicle, civilians, and remaining SS guys
	stop_exploder( "fx_vip_vehicle_fire" );
	level.secure_vip_vehicle playsound( "scn_hithard_ugvcar03" );	
	level.secure_vip_vehicle kill();	
	foreach( guy in level.secure_vip_guard[ "ss" ] )
	{
		if( isalive( guy ))
		{
			guy kill();
		}
	}	
	
	foreach( guy in level.secure_vip_guard[ "ss" ] )
	{
		if( isalive( guy ))
		{
			guy kill();
		}
	}

	foreach( guy in fodder_guys )
	{
		if( isalive( guy ))
		{
			guy SetGoalPos( guy.origin );
		}
	}	

	// Send VP and SS guy to positions
	level waittill( "car_explosion_done" );
	vp_ss_cover vp_protect_end();
	level.ss_fodder1.script_forcegoal = 1;
	level.secure_vip.script_forcegoal = 1;
	level.ss_fodder1.goalradius = 8;
	level.secure_vip.goalradius = 8;

	vp_and_ss = [ level.secure_vip, level.ss_fodder1 ];
	level.secure_vip.animname = "vp";
	level.ss_fodder1.animname = "secret_service1";
	node = getstruct("node_vp_ss_loop2", "script_noteworthy");
	wait .5;
	node anim_reach_and_approach( vp_and_ss, "vp_loop" );

	radio_dialogue_stop();
	// Dialogue: Baker: "Ok. Looks Clear - powering down Threat Detection"
	thread radio_dialogue_interupt( "hithard_bak_snipe_21" );

	// Disable threat ID usage	
	thread maps\_threatid::threatid_disable_overlay_and_effect();
}

run_to_vp()
{
	foreach( guy in self )
	{
		if( isalive( guy ))
		{
			guy.goalradius = 8;
			guy.script_forcegoal = 1;
			guy SetGoalEntity( level.secure_vip );
		}
	}
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

closest_guy_to( vip )
{
	protect_vol = GetEnt( "volume_secure_vp_protect", "targetname" );	
	vp_right = protect_vol get_ai_touching_volume( "allies" );

	array_of_dudes = [];

	foreach( guy in vp_right )
	{
		if( guy.classname == "actor_nx_ally_us_secretservice" )
		{
			array_of_dudes = add_to_array( array_of_dudes, guy );
		}
	} 

	closest_dude = undefined;

	if( array_of_dudes.size > 0 )
	{
		closest_dude = self closest_to( array_of_dudes );
	}
	else
	{
		closest_dude = self closest_to( level.secure_vip_guard[ "ss" ] );
	}

	Assert( isdefined( closest_dude ));
	return closest_dude;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

closest_to( array_of_dudes )
{
	closest_dist = 999999999;
	closest_dude = undefined;

	for( i = 0; i < array_of_dudes.size; i++ )
	{
		distance_between = distance( array_of_dudes[ i ].origin, self.origin );

		if( distance_between < closest_dist )
		{
			closest_dist = distance_between;
			closest_dude = array_of_dudes[ i ];
		}
	}

	Assert( isdefined( closest_dude ));

	return closest_dude;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

car_explode_slow_mo()
{	
	// Don't slomo sounds
	SoundSetTimeScaleFactor( "Mission", 0 );
	SoundSetTimeScaleFactor( "Shellshock", 0 );
	SoundSetTimeScaleFactor( "Voice", 0 );
	SoundSetTimeScaleFactor( "Menu", 0 );
	SoundSetTimeScaleFactor( "Effects1", 0 );
	SoundSetTimeScaleFactor( "Effects2", 0 );
	SoundSetTimeScaleFactor( "Announcer", 0 );
	SoundSetTimeScaleFactor( "Music", 0 );
	SoundSetTimeScaleFactor( "vignette3d", 0 );
	SoundSetTimeScaleFactor( "vignette2d", 0 );
	SoundSetTimeScaleFactor( "ambient", 0 );
	SoundSetTimeScaleFactor( "weapon", 0 );
	SoundSetTimeScaleFactor( "weapon2d", 0 );
	SoundSetTimeScaleFactor( "auto2d", 0 );
	SoundSetTimeScaleFactor( "auto", 0 );
	SoundSetTimeScaleFactor( "element", 0 );
	
	level._player magic_bullet_shield();

	// Start slo motion
	slowmo_speed = 0.20;
	slowmo_setspeed_slow( slowmo_speed );
	slowmo_setlerptime_in( 0.5 );
	slowmo_lerp_in();
	
	level._player SetMoveSpeedScale( 0.1 );
	 
	// Wait slo mo duration
	real_time = 3.0;
	wait real_time * slowmo_speed ;
	
	// Stop slo motion
	slowmo_setlerptime_out( 0.65 );
	slowmo_lerp_out();
	slowmo_end();
	level._player SetMoveSpeedScale( 1.0 );
	wait 1.0;
	level._player stop_magic_bullet_shield();
	level notify( "car_explosion_done" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Waits for multiple notifies before continuing
waittill_multi( array_of_ai, msg )
{
	foreach( thing in array_of_ai )
	{
		thing thread waittill_multi_thread( msg );
	}

	msg_count = 0;

	while( msg_count < array_of_ai.size )
	{
		level waittill( "notify_waittill_complete" );
		msg_count++; 
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

waittill_multi_thread( msg )
{
	self waittill( msg );
	level notify( "notify_waittill_complete" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main_rappel()
{
	radio_dialogue_stop();

	// Dialogue: SS: "Convoy 2, we’re getting overrun!”
	//radio_dialogue( "hithard_sslead_snipe_08");
	
	// Dialogue: Baker: "They're going for Patriot!"
	//radio_dialogue( "hithard_bak_secure_45" );

	// Dialogue: Baker: "Latch up. We're roping down."
	// add_dialogue_line( "Baker", "Latch-up.  We're roping down.", "green", 2 );

	// Dialogue: Baker: "Duke, Specter, we're movin"  
	radio_dialogue( "hithard_bak_snipe_weremovin" );

	level.squad[ 0 ] thread ally_rappel( "baker", GetNode( "node_secure_ground_ally_02", "script_noteworthy" ));		
	level.squad[ 1 ] thread ally_rappel( "duke", GetNode( "node_secure_ground_ally_01", "script_noteworthy" ));						
	waittill_multi( level.squad, "notify_rappel_idle" );
	
	// Obj position for rappel	
	rappel_node = GetEnt( "player_rappel_animent", "targetname" );
	objective_start( "obj_secure_rappel", &"NX_HITHARD_SECURE_OBJ_RAPPEL", rappel_node );

 	// Summon player after a bit
	thread dialogue_rappel_summon_player();	
		
	// Ready to start smoke when player rappel starts
	thread spawn_smoke();

	// Player Rappel setup
	thread maps\_rappel_util::rappel_start();
	level._player waittill( "notify_rappel_start" );

	level._player playsound("hithard_rappel_scene");		

	// Apply vision and fog
	thread maps\nx_hithard_fx::apply_effects_sniper_wave4();

	radio_dialogue_stop();

	thread replenish_ss( level.secure_vip_guard[ "ss" ].size );

	level waittill( "notify_rappel_complete" );
	objective_setpointertextoverride( level.objective[ "obj_secure_snipe" ], &"NX_HITHARD_SECURE_OBJ_PROTECT" );
	objective_OnEntity( level.objective[ "obj_secure_snipe" ], level.secure_vip );

	objective_end( "obj_secure_rappel" );

	//debug_warp_ground();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

dialogue_rappel_summon_player()
{
	level._player endon( "notify_rappel_start" );

	wait 5;

	// Dialogue: Baker: "Specter, let's go"  
	radio_dialogue( "hithard_bak_snipe_letsgo" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

replenish_ss( count )
{
	while( count < 6 )
	{
		array = spawn_vip_guard( "motorcade_vip_guard_replenish", "ss", 1 );
		level.secure_vip_guard[ "ss" ] = add_to_array( level.secure_vip_guard[ "ss" ], array[0] );
		count++;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main_secure_ground()
{
	flag_wait( "flag_secure_rooftop_prep_complete" );	

	battlechatter_on( "allies" );
	battlechatter_on( "axis" );

	//setting ambient
	thread set_ambient( "nx_hithard_ext" );

	// Autosave
	thread autosave_by_name( "nx_hithard_secure_ground" );	
		
	// Start objective
	objective_start( "obj_secure_ground", &"NX_HITHARD_SECURE_OBJ_GROUND", level.secure_vip,  &"NX_HITHARD_SECURE_OBJ_PROTECT" );	
	
	// Send allies to back of car
	foreach( guy in level.secure_vip_guard[ "ss" ] )
	{
		guy set_force_color( "c" );
		guy set_fixednode_true();
	}

	issue_color_orders( "c1", "allies" );																		  

	// Setup ignores												 
	//set_squad_ignore( true );	
	//SetIgnoreMeGroup( "secure_wave_1", "player" );
	//SetIgnoreMeGroup( "secure_wave_1_front_0", "player" );

	flag_clear( "flag_script_low_priority_dialogue_allow" );
	flag_set( "flag_script_ground_threat_id_allow" );
	
	// Setup hatred	
	SetThreatBias( "squad", "secure_wave_1", 1000 );
	SetThreatBias( "squad", "secure_wave_1_front_0", 1000 );
	SetThreatBias( "secure_wave_1", "secure_vip_guard" , 2000 );
	SetThreatBias( "secure_wave_1_front_0", "secure_vip_guard" , 4000 );

	// Turn on threat ID for ground guys
	//level.secure_enemies[ "ground" ] SetThreatIDOverlay_array( "auto" );

	// Threat ID counter
	thread watcher_threat_counter( "ground", "notify_secure_objective_wave_2_complete", "ground_front_0" );

	// Baker encourages
	//thread dialogue_baker_encouragement( "notify_secure_objective_wave_2_complete" ); 

	// Make SS guys weak again
	level.secure_vip_guard[ "ss" ] set_ai_accuracy_array( level.secure_ss_accuracy_weak );	

	level.squad thread allies_to_start_nodes();		

	// Large group moving through the smoke!
	radio_dialogue( "hithard_bak_secure_51" );

	flag_set( "music_smoke_battle_starts" );

	flag_set( "flag_script_objective_wave_2_active" );
	flag_set( "flag_script_low_priority_dialogue_allow" );

	// Turn on threat ID for civvies
	foreach( guy in level.secure_civilians )
	{
		//guy SetThreatIDOverlay( "auto" );
	}
	
	// Turn on vulnerability for allies
	level.secure_vip_guard[ "ss" ] enable_hurt();
	
	// Turn on attention pointer
	//thread enableAttentionPointer( level.vip_focus_pointer, level.secure_vip, level.objective[ "obj_secure_snipe" ] );		

	level.secure_human_enemies_num_killed = 0;	
 		
	// Give allies back their mojo
	level.squad set_ai_accuracy_array( level.secure_squad_accuracy_wave_2 );		 

	while( level.secure_enemies[ "ground" ].size == 0 )
	{
		wait 0.05;
	}

	// Wait for enough wave_1 enemies to be killed before proceeding	
	while(( level.secure_enemies[ "ground" ].size > 0 ) || ( level.secure_enemies[ "ground_front_0" ].size > 0 ))
	{						
		//issue_color_orders( "p1", "axis" );

		// Clean arrays
		level.secure_enemies[ "ground" ] = remove_dead_from_array( level.secure_enemies[ "ground" ] );
		level.secure_enemies[ "ground_front_0" ] = remove_dead_from_array( level.secure_enemies[ "ground_front_0" ] );
			
		if(( level.secure_enemies[ "ground_front_0" ].size < 3 ) && ( level.secure_enemies[ "ground" ].size > 0 ))
		{
			// Send enemies in for the kill			
			guy = random( level.secure_enemies[ "ground" ] );
			guy go_forth_and_die_solo();
			level.secure_enemies[ "ground" ] = array_remove( level.secure_enemies[ "ground" ], guy );
		}
					
		wait 0.05;
	} 	
		
	//
	// END
	//
   
	// Turn off ally vulnerability script
	level.secure_vip_guard[ "ss" ] disable_hurt();
	waittillframeend;

	// Remove bullet shielding
	level.secure_vip_guard[ "ss" ] thread stop_magic_bullet_shield_array();

	// Turn off attention pointer
	thread DisableAttentionPointer();							   

	// Break front_0 focus
	level notify( "notify_secure_squad_front_0_focus_off" );
	level notify( "notify_secure_objective_wave_2_complete" );
	level notify( "notify_secure_objective_complete" );
	objective_end( "obj_secure_ground" );
	
	// Play final sequence leading into cutscene
	event_end_sequence();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Turns off the spawnpool during wave_2 when enough guys have spawned
watcher_enemy_spawnpool_off( num_guys_allowed )
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );

	// Set spawner counter to current number of guys on the ground
	level.num_enemies_spawned = isalive_array( level.secure_enemies[ "ground" ]);	
 
	while( level.num_enemies_spawned < num_guys_allowed )
	{		
		wait 0.05;
	}

	flag_clear( "flag_script_spawnpool_allow");
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Force an AI to a node
allies_to_start_nodes()
{
	node = [];
	node[ "ally_01" ] = GetNode( "node_secure_ally_01_cover", "script_noteworthy" );
	node[ "ally_02" ] = GetNode( "node_secure_ally_02_cover", "script_noteworthy" );		

	foreach( guy in self )
	{
		guy.script_forcegoal = 1;	
		guy SetGoalNode( node[ guy.script_noteworthy ] );	
	}	

	wait 3.0;
	level notify( "notify_script_secure_allies_in_position" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debug_warp_ground()
{
	// Warp player		
	//level._player maps\_nx_utility::move_player_to_start_point( "playerstart_secure_ground" );

	// Move squad to positions					
	ally_set_goal_noteworthies = [ "node_secure_ground_ally_02", "node_secure_ground_ally_01" ];
	level.squad maps\nx_hithard_util::moveAlliesToStartPoint( ally_set_goal_noteworthies, ally_set_goal_noteworthies, true );			
	
	level.squad set_fixednode_true_array();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Reinforcements drive in and get RPGed
event_lapd_backup()
{	
	/*
	lapd_spawner = GetEntArray( "motorcade_vip_guard_backup1", "script_noteworthy" );

	foreach( guy in lapd_spawner )
	{
		guy set_script_friendname( "Officer" );				
	}

	array_spawn_function( lapd_spawner, ::spawnfunc_ally_swat_backup, "secure_vip_guard" );
	*/
	 
	level.vehicles[ "lapd_backup" ] = spawn_vehicle_from_targetname_and_drive( "vehicle_lapd_assist_1" );	
	level.vehicles[ "lapd_backup" ] waittill( "reached_end_node" );
	//level.vehicles[ "lapd_backup" ] vehicle_unload();
	
	wait 1.0;

	rpg_guy_spawner = GetEnt( "secure_enemy_ground_rpg", "targetname" );
	rpg_guy_spawner add_spawn_function( ::spawnfunc_enemy_wave_1_lapd_rpg, "secure_wave_1_front_0", level.vehicles[ "lapd_backup" ] );
	rpg_guy_spawner spawn_ai();	
	
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Intro dialogue between baker and patriot
dialogue_baker_and_patriot()
{
	radio_dialogue_stop();		
		
	// Dialogue: Baker: "Patriot, this is convoy 2.  Engaging from Southwest roof."
	radio_dialogue( "hithard_bak_snipe_05" );

	// Dialgoue: Baker: "About time! We have no exit!"
	radio_dialogue( "hithard_sslead_snipe_01" );

	// Dialogue: Baker: "Roger, we're on it!"
	radio_dialogue( "hithard_bak_snipe_06" );			

	// Baker encourages
	thread dialogue_baker_encouragement( "notify_secure_objective_wave_1_complete" ); 

	flag_set( "flag_secure_intro_dialogue_complete" );

	level.squad ignore_all_off();

	thread fire_up_threat_detection();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

active_weapon()
{
	while( 1 )
	{
		iprintlnbold( level._player GetCurrentWeapon() );
		wait 1.0;
	}
}

// Main objective script
main_secure()
{		
	flag_wait( "flag_secure_rooftop_prep_complete" );	

	// Kill off all ai spawners from parachute section
	maps\_spawner::kill_spawnerNum( 2 );	
 
	// Wait until guys have spawned
	//flag_wait( "flag_secure_rooftop_prep_complete" );

	// Send in a VTOL with some ropers
	thread event_enemy_vtol_enemy_roper();

	battlechatter_off( "allies" );
	battlechatter_off( "axis" );		
		
	flag_wait( "flag_secure_rooftop_aware" );
					
	thread event_lapd_backup();

	// Baker talks with patriot
	thread dialogue_baker_and_patriot();	
	
	//setting ambient
	thread set_ambient( "nx_hithard_ext2" );

	// Lower the objective distance (so marker doesn't fade)
	setSavedDvar( "ObjectiveFadeTooFar", 15 );
		
	// Autosave
	thread autosave_by_name( "nx_hithard_secure_start" );

	flag_wait( "flag_secure_intro_dialogue_complete" ); 

	// Start snipe objective
	objective_start( "obj_secure_snipe", &"NX_HITHARD_SECURE_OBJ_SNIPE", level.secure_vip,  &"NX_HITHARD_SECURE_OBJ_PROTECT" );
	flag_set( "flag_secure_objective_active" );	

	// Watch the vip's security forces							
	thread watcher_vip_guard();

	// Watch for vehicle damage by specific enemies
	//level.secure_vip_vehicle thread watcher_vip_vehicle();		
																		  
	// Run through each encounter
	for( i = level.encounter_start; i < level.encounter_list.size; i++ )
	{
		[[level.encounter_list[ i ]]]();
	}
				
	// Lower the objective distance back to default
	setSavedDvar( "ObjectiveFadeTooFar", 25 );	

	// Objective Complete
	//objective_end( "obj_secure_snipe" );	
	flag_clear( "flag_secure_objective_active" );
	flag_clear( "flag_script_ground_threat_id_allow" );	
	flag_set( "flag_secure_objective_complete" );
	flag_set( "music_snipe_ends" );		
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Sets up ally for rappel
ally_rappel_latch_on_sfx( animname )
{
	wait 2.0;
	if( animname == "baker")
		level.squad[ 0 ] playsound("hithard_rappel_baker_latch_on");
	else
		level.squad[ 1 ] playsound("hithard_rappel_duke_latch_on");		

}
ally_rappel( animname, goal_node )
{
	rappel_node = GetEnt( "player_rappel_animent", "targetname" );
	self.animname = animname;
	
	rappel_node anim_reach_solo( self,  "rappel_intro" );
	thread ally_rappel_latch_on_sfx( animname );
	rappel_node anim_single_solo( self, "rappel_intro" );
	rappel_node thread anim_loop_solo( self, "rappel_idle" );
	waittillframeend;
	self notify( "notify_rappel_idle" );
	level._player waittill( "notify_rappel_start" );
	rappel_node notify( "stop_loop" );
	self anim_stopanimscripted();
	rappel_node anim_single_solo( self, "rappel_outro", undefined, 0.2 );
	wait 1;

	self set_fixednode_false();
	self.goalradius = 8;
	self.script_forcegoal = 1;
	self SetGoalNode( goal_node );
	//self waittill( "goal" );
	//self set_fixednode_true();
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Start threat detection
fire_up_threat_detection()
{
	// Dialogue: Baker: "firing up threat detection."
	radio_dialogue( "hithard_bak_secure_02" );	

	// enable threat ID usage
	flag_set( "flag_script_ground_threat_id_allow" );
	thread maps\_threatid::threatid_bootup_and_enable();	

	// Threat ID counter
	thread watcher_threat_counter( "ground", "notify_secure_objective_wave_1_complete", "ground_front_0" );		
	
	// Dialogue: Baker "Go to High Power Scopes"
	radio_dialogue( "hithard_bak_snipe_18" );

	flag_set( "flag_script_high_priority_dialogue_allow" );
	flag_set( "flag_script_low_priority_dialogue_allow" );

	// Display zoom hint	
	thread watcher_zoom_hint();
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Display zoom hint
watcher_zoom_hint()
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );

	cycles = 0;

	thread watcher_zoom_hint_switch();

	flag_clear( "flag_secure_dpad_pressed" );

	while( !flag( "flag_secure_dpad_pressed" ) && ( cycles < 3 ))
	{
		display_hint_timeout( "hint_secure_zoom", 3.0 );
		wait 10;
		cycles++;
	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Watches for player to press dpad left, then sends notify
watcher_zoom_hint_switch()
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );

	while( !level._player ButtonPressed( "DPAD_LEFT" ))
	{
		wait 0.05;
	}

	flag_set( "flag_secure_dpad_pressed" );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Logic for cortel inside RPG guys
spawnfunc_enemy_cortel_inside_watcher( destroy_node_targetname, node2_targetname )
{
	self endon( "death" );
	
	topfloor = false;

	if( self.target == "topfloor" )
	{
		topfloor = true;
	}
			
	go_node = GetNode( node2_targetname, "targetname" );

	window_target = GetEnt( destroy_node_targetname, "targetname" );
	billboard_nodes = GetEntArray( "origin_billboard_killer", "targetname" );

	self waittill( "reached_path_end" );	

	// Give him a moment so he doesn't blow himself up
	wait 1.0;

	// Blow out the windows
	weapon_origin = self GetTagOrigin( "TAG_WEAPON_LEFT" ) + vector_multiply( AnglesToForward( self.angles ), 10 );

	// Top guy shoots through window, bottom guy blows up window
	if( topfloor )
	{
		randomTarget = random( billboard_nodes );
		MagicBullet( "rpgx_straight", weapon_origin, randomTarget.origin );
	}
	else
	{
		MagicBullet( "rpgx_straight", weapon_origin, window_target.origin );
	}

	self SetGoalNode( go_node );
	self waittill( "goal" );	
	self.ignoreall = false;	
	level notify( "notify_" + self.script_noteworthy + "_at_goal" );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Order to squad allies to kill wave_1 baddies
watcher_squad_front_0_focus()
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );
	level endon( "notify_secure_squad_front_0_focus_off" );

	while( 1 )
	{
		flag_wait( "flag_secure_vip_vulnerable" );
		//SetThreatBias( "squad", "secure_wave_1_front_0", 10000 );			
		flag_waitopen( "flag_secure_vip_vulnerable" );			
		//SetThreatBias( "squad", "secure_wave_1_front_0", 0 );
 	}	
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// VTOL drops off wave_1 dudes
event_enemy_vtol_secure_intro()
{	
	// flyby vtol
	level.secure_vtols[ "vtol_03" ] = spawn_vtol_from_noteworthy( "secure_vtol_3", undefined, "secure_vtol_enter_03" );
	level.secure_vtols[ "vtol_03" ] thread vtol_exit();
} 
  
//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// VTOL flies in and drops reinforcements
event_enemy_vtol_enemy_roper()
{
	vtol_guys = getentarray( "motorcade_enemies_1_vtol", "script_noteworthy" );		
	array_thread( vtol_guys, ::add_spawn_function, ::spawnfunc_enemy_wave_1_vtol, "secure_wave_1_front_0" );

	thread watcher_enemy_vtol_shake_and_bake();

	// enemy roper vtol
	level.secure_vtols[ "vtol_01" ] = spawn_vtol_from_noteworthy( "secure_vtol_1", "secure_vtol4_1", "secure_vtol_exit2" );
	vtol1_sfx = Get_Vehicle( "secure_vtol_1", "targetname" );
	vtol1_sfx playsound( "scn_hhh_vtol_flyin02" );
	level.secure_vtols[ "vtol_01" ] vtol_enter( true );	
        //level.secure_vtols playsound("nx_npc_fastrope");
	wait 15.0;	
	level.secure_vtols[ "vtol_01" ] vtol_exit();
}  

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Flyover shakes player
watcher_enemy_vtol_shake_and_bake()
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );	


	while( !flag( "flag_secure_objective_active" ))
	{
		flag_wait( "flag_vtol_flyover" );		
	
		Earthquake( .3, 1.0 , level._player.origin, 5000 );
		level._player PlayRumbleOnEntity( "artillery_rumble" );	
		flag_clear( "flag_vtol_flyover" );		
	}
}

sound_play_explosion()
{
	flag_wait ("flag_intersection_first_fireball");
	thread maps\_utility::set_ambient( "nx_hithard_ext2" );
	mynodebomb = spawn( "sound_emitter", ( 8336, -2458, 7 ) );
	wait 0.2;
	mynodebomb PlaySound( "expl_hh_bomb", "expl_hh_bomb", true );
	mynodebomb waittill( "expl_hh_bomb" );
	mynodebomb delete();

}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Announce the wave once enemies in place
dialogue_baker_wave_callout( enemy_noteworthy_name, dialogue_array )
{	
  	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );
   
	first_time = true;

	allowed = true;

	if( isalive_array( self ))
	{
		//self SetThreatIDOverlay_array( "auto" );
	}
  
	// Wait until one of the enemies reaches his goal
	level waittill( "notify_" + enemy_noteworthy_name + "_at_goal" );	

	play_count = 0;

	// Play the dialogue	
	if( isalive_array( self ))
	{					
		if( first_time )
		{
			// First time callouts get priority
			radio_dialogue_stop();
			radio_dialogue_interupt( dialogue_array[ 0 ] );
			first_time = false;
		}
		else
		{
			radio_dialogue( dialogue_array[ 0 ] );
		}		
	}
}
																	 
//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************
																	  
// guy targetting VIP vehicle																	  
waittill_goal_notify( enemy_noteworthy_name )
{
	self endon( "death" );

	self waittill( "reached_path_end" );
	
	level notify( "notify_" + enemy_noteworthy_name + "_at_goal" );	
}
																	  

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Prepares all entities in "sniping" intersection
prep_secure_intersection( spawn_first_wave )
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );		

	// Wait to spawn dudes until player trips the below flag
	flag_wait( "flag_prep_secure" );

	// Setup global variables
	A_secure_globals();		
		
	// Kill lingering guys in rooftop section when they are out of sight
	delete_ai_volume_out_of_sight( "secure_rooftop_cleanup" );				  		

	// Grab VIP car
	level.secure_vip_vehicle = getent( "vip_busted", "targetname" );
	level.secure_vip_vehicle godon();
	level.secure_vip_vehicle2 = getent( "ugv_targetcar1", "targetname" );
	level.secure_vip_vehicle2 godon();	
	//level.secure_vip_vehicle kill();	// Kill

	// Spawn vip
	level.secure_vip = spawn_vip( "ultra_vp", ::spawnfunc_ally_vip, "secure_vip" );		   									 
	
	// Spawn vip guard
	level.secure_vip_guard[ "ss" ] = spawn_vip_guard( "motorcade_vip_guard_1", "secret_service" );
	roaming_secret_service = spawn_vip_guard( "motorcade_vip_guard_3", "secret_service" );

	foreach( guy in roaming_secret_service )
	{
		level.secure_vip_guard[ "ss" ] = add_to_array( level.secure_vip_guard[ "ss" ], guy );				
	}

	level.secure_vip_guard[ "swat" ] = spawn_vip_guard( "motorcade_vip_guard_2", "swat" ); 
 
	level.secure_vip_guard[ "all" ] = array_combine( level.secure_vip_guard[ "ss" ], level.secure_vip_guard[ "swat" ] ); 

	// Spawn and kill bodies for ground	
	deadguys_spawner = getEntArray( "motorcade_vip_guard_4", "script_noteworthy" );

	foreach( guy in deadguys_spawner )
	{
		deadguy = guy spawn_ai();
		deadguy kill();		
	}

	// Setup allies to color yellow
	issue_color_orders( "g1", "allies" );

	// Setup allies to color yellow
	issue_color_orders( "c1", "allies" );

	// Civilian drones running around intersection and streets	
	thread civilians_drones();	
	
	// AI civilians running around intersection and streets from cortel building
	thread civilians_ai();

	// start the vfx sequencing
	thread maps\nx_hithard_fx::fx_secure_init();

	//thread event_enemy_vtol_secure_intro();

	// Change Friendly Fire participation points (can accidentally kill more civvies / allies)  Default: -650
	level._friendlyfire[ "friend_kill_points" ] = 0;

	if( isdefined( spawn_first_wave ))
	{
		if( spawn_first_wave )
		{
			// Spawn enemies already attacking motorcade
			level.secure_enemies[ "ground" ] = spawn_enemy_wave( "motorcade_enemies_1", ::spawnfunc_enemy_ground_first, "secure_wave_1_front_0" );									
			level.secure_enemies[ "ground" ] thread watcher_enemy_wave_1_remove_bullet_shield();
		}
		else
		{
			// Watch the vip's security forces							
			thread maps\nx_hithard_secure::watcher_vip_guard();		
		}		
	}
	
	flag_set( "flag_secure_rooftop_prep_complete" );	
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Waits for player to get to rooftop, then removes bullet shielding on baddies
watcher_enemy_wave_1_remove_bullet_shield()
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" ); 

	// Wait for player to be on rooftop
	flag_wait( "flag_secure_rooftop_aware" );

	self stop_magic_bullet_shield_array();
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

civilians_drones()
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );
	level endon( "notify_kill_drone_spawn" );

	spawners_1 = GetEntArray( "secure_civilian_spawner", "script_noteworthy" );
	starts_1 = GetEntArray( "secure_civilians_ground_start_fig_1", "script_noteworthy" );
	ends_1 = GetEntArray( "secure_civilians_fig_1_end", "script_noteworthy" );

	spawners_2 = GetEntArray( "secure_civilian_spawner_2", "script_noteworthy" );
	starts_2 = GetEntArray( "secure_civilians_ground_start_fig_2", "script_noteworthy" );
	ends_2 = GetEntArray( "secure_civilians_fig_2_end", "script_noteworthy" );

	thread civilians_drone( "figueroa1", 1,spawners_1, starts_1, ends_1, 0.05, 2 );
	thread civilians_drone( "figueroa2", 1,spawners_2, starts_2, ends_2, 0.05, 2 );
	
	wait 60;

	level notify( "notify_kill_drone_spawn" );
	thread civilians_drone( "figueroa1", 1,spawners_1, starts_1, ends_1, 2, 4 );
	thread civilians_drone( "figueroa2", 1,spawners_2, starts_2, ends_2, 2, 4 );

	wait 60;

	level notify( "notify_kill_drone_spawn" );
	thread civilians_drone( "figueroa1", 1,spawners_1, starts_1, ends_1, 4, 6 );
	thread civilians_drone( "figueroa2", 1,spawners_2, starts_2, ends_2, 4, 6 );

	wait 60;
	level notify( "notify_kill_drone_spawn" );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Watches the main vip vehicle (where all SS and vp are hiding)
watcher_vip_vehicle()
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );

	vip_vehicle_attacker_list = [];

	while( 1 )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, idFlags );

		if( attacker == level._player )
		{
			self damage_vip_vehicle( damage );
		}
		else if( isdefined( attacker.script_parameters ))
		{
			// Attacker is allowed to hurt vip vehicle
			if( attacker.script_parameters == "secure_vip_hurt" )
			{
				if( isdefined( attacker.targetname ))
				{
					// If first attack, add targetname of attacker to list.  If not first time, allow damage.
					if( vip_vehicle_attacker_list[ attacker.targetname ] )
					{
						self damage_vip_vehicle( damage );
					}
					else
					{
						vip_vehicle_attacker_list[ attacker.targetname ] = 1;;
					}
				}
			}		
		}
  	}	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Send the entity to a goalvolume 
go_to_goal_volume( goalVolume )
{
	self SetGoalVolumeAuto( level.secure_front[ goalVolume ] );		
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Damage the VIP vehicle (or destroy it if enough damage is taken)
damage_vip_vehicle( damage )
{
	if( self.health <= damage )
	{
		self godoff();					

		// Take bulletshield off of vip crowd for effect
		level.secure_vip stop_magic_bullet_shield();
		foreach( guy in level.secure_vip_guard )
		{
			if( isalive( guy ))
			{
				guy stop_magic_bullet_shield();
			}
		}

		self kill();

		flag_set( "flag_secure_objective_failed" );
		SetDvar( "ui_deadquote", "You failed to protect the VP! (PLACEHOLDER)" );
		missionFailedWrapper();				
	}			
	else
	{
		self.health = self.health - damage;
	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// AI cvilian controller for secure motorcade
civilians_ai()
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" ); 	
	
	// Grab civilian spawners and "goal" nodes 
	spawners = getentarray( "secure_civilians_ground_male_ai_1", "script_noteworthy" );
	end_nodes = getnodearray( "secure_civ_ai_end", "script_noteworthy" );	

	while( 1 )
	{
		// Clean the undefined civvies for accurate numbers
		level.secure_civilians = remove_dead_from_array( level.secure_civilians );
 		
		// Make sure we don't have too many civvies, if we don't, spawn some more
		if
		( 
			(level.secure_civilians.size < level.secure_civilian_ai_max ) &&  
			( GetAICount() <= ( 32 - level.secure_civilian_ai_buffer ))
		)
		{
			while
			(
				( level.secure_civilians.size < level.secure_civilian_ai_max ) && 
				( GetAICount() <= ( 32 - level.secure_civilian_ai_buffer ))
  			)
			{
				// Clean the undefined civvies for accurate numbers
				level.secure_civilians = remove_dead_from_array( level.secure_civilians );

				// Grab a spawner and a node
				node = random( end_nodes ); 
				spawner = random( spawners ); 
	
				// spawn
				civilian = spawner spawn_ai();
				
				if( isdefined( civilian ))
				{
					civilian.goalradius = level.secure_civilian_goalradius;
					civilian setGoalNode( node );					
					civilian thread watcher_civilians_ai();
					level.secure_civilians = add_to_array( level.secure_civilians, civilian );
					if( !flag( "flag_script_objective_wave_2_active" ))
					{
						//civilian SetThreatIDOverlay( "auto" );
					} 
				}

				wait_random_time( 1, 3 );
  			}
		}
								
		wait 1;
  	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Remove civilians when they reach the end of their paths
watcher_civilians_ai()
{
	self endon( "death" );
	
	self waittill( "goal" );
	self delete();
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Grabs goal volumes and pathnode positions for "fronts"
prep_secure_fronts()
{
	// Grab goal volumes to use as "fronts"
 	fronts = [];

	// Enemy fronts
	fronts[ "front_3" ] = getEnt( "front_3", "script_noteworthy" );	
	fronts[ "front_2" ] = getEnt( "front_2", "script_noteworthy" );
	fronts[ "front_1" ] = getEnt( "front_1", "script_noteworthy" );
	fronts[ "front_0" ] = getEnt( "front_0", "script_noteworthy" );

	//Ally (vip guard) fronts 	
	fronts[ "allies_normal" ] = getEnt( "volume_front_motorcade", "script_noteworthy" );
	fronts[ "allies_last_stand" ] = getEnt( "volume_front_last_stand", "script_noteworthy" );
	
	return fronts;
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Spawn secure motorcade section civilians
civilians_drone( name, count, spawners, starts, ends, time_low, time_high )
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );
	level endon( "notify_kill_drone_spawn" );

	crowd = maps\nx_crowd_controller::new_crowd( name, count, spawners, starts, ends, time_low, time_high );

	while( 1 )
	{					  							  
		thread maps\nx_crowd_controller::spawn_crowd( name );		
		level waittill( name );
	}
}
																						
//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Spawns new ground enemies indefinitely
watcher_enemy_spawnpool()
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );
	number_of_spawnpools = 3;

	// Check and prep spawn pools
	spawnpools = getEntArray( "motorcade_enemies_spawnpool_1", "script_noteworthy" );
	array_thread( spawnpools, ::add_spawn_function, ::spawnfunc_enemy_wave_1_spawnpool, "secure_wave_1" );

	if( !isdefined( spawnpools ))
	{
		AssertMsg( "No spawnpools available at secure intersection!" );
	}

	if( spawnpools.size < number_of_spawnpools )
	{
		AssertMsg( spawnpools.size + " out of the expected " +  number_of_spawnpools + " spawnpools available" );
	}	

	while( 1 )
	{
		if( flag( "flag_script_spawnpool_allow" ))
		{
			level.secure_enemies[ "ground" ] = array_removeDead( level.secure_enemies[ "ground" ] ); 		
			
			if( ( level.secure_enemies[ "ground" ].size + level.secure_enemies[ "ground_front_0" ].size ) < level.secure_ground_num_guys_allowed )
			{
				// Choose a random spawnpool and spawn
				spawner = random( spawnpools );
				
				ent =  spawner spawn_ai();				
	
				if( isdefined( ent ))
				{
					level.secure_enemies[ "spawnpool" ] = add_to_array( level.secure_enemies[ "spawnpool" ], ent );			
					level.secure_enemies[ "ground" ] = add_to_array( level.secure_enemies[ "ground" ], ent );
				}
			}
		}

		wait 0.05;
	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Watches the whole vip_guard group
watcher_vip_guard()
{
	level endon( "notify_secure_objective_complete" );		
	
	// SS almost dead flag has been set once
	flag_ss_almost_dead = false;

	// First SS agent to die
	flag_ss_first_dead = true;
	
	// Time between SS deaths
	time_between_ss_deaths = 0; 

	// While SS guys are alive
	while ( 1 )
	{																
		level.secure_vip_guard[ "ss" ] = remove_dead_from_array( level.secure_vip_guard[ "ss" ] );		

		// Keep track of how many SS guys we used to have
		last_num_ss_guys = level.secure_vip_guard[ "ss" ].size;

		if( level.secure_vip_guard[ "ss" ].size == 0 )
		{
			// All SS dead
			break;
		}
		if( flag( "flag_script_vip_guard_vulnerable_override" ))
		{	
			// All SS almost dead!
			if (( level.secure_vip_guard[ "ss" ].size < 3 ) && !flag_ss_almost_dead )
			{			
				flag_set( "flag_script_vip_guard_almost_dead" );
				
				// vip guard pulls back to area close to VP
				foreach( guy in level.secure_vip_guard[ "ss" ] )
				{
					if( isalive( guy ))
					{
						guy set_force_color( "c" );
					}
				}
	
				//display_hint_timeout( "hint_motorcade_vip_guard_almost_dead", 5.0 );
			
				thread dialogue_vip_guard_almost_dead();
	
				// Reset flag, message will only display once
				flag_ss_almost_dead = true;
				flag_clear( "flag_script_vip_guard_almost_dead" );			
			}				
			else if( level.secure_vip_guard[ "ss" ].size < last_num_ss_guys )
			{				
				result = false;
 
				if( flag( "flag_script_high_priority_dialogue_allow" ))
				{
					if( flag_ss_first_dead )
					{					
						// First time an agent dies
						// Dialogue: SS: "Agent down! Cover Patriot!"
						result = radio_dialogue( "hithard_sslead_snipe_04" );
						flag_ss_first_dead = false;
					}
					else if( ( level.secure_vip_guard[ "ss" ].size < (last_num_ss_guys - 2 )) && ( time_between_ss_deaths > 7 )) 
					{					
						// Reoccurring messages while SS guys die
						line = random( level.secure_dialogue[ "ss_need_help" ] );
						result = radio_dialogue_safe( line );
					}
	
					if( isdefined( result ))
					{
						if( result )
						{
							time_between_ss_deaths = 0;
						}
					}
				}
			}
		}

		wait_time = 0.05;

		time_between_ss_deaths = time_between_ss_deaths + wait_time;		
		
		wait wait_time;
	}	
	
	flag_set( "flag_script_vip_guard_dead" );	

	// Sic the enemies on the vip
	level.secure_vip thread vip_hunt();
	
	level.secure_vip waittill( "death" );
	
	flag_set( "flag_secure_objective_failed" );
	level notify( "notify_secure_objective_failed" );
	objective_failed( "obj_secure_snipe", &"NX_HITHARD_SECURE_FAIL_VIP_GUARD_DEAD" );	
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Enemies hunt down vip
vip_hunt()
{
	self endon( "death" );

	// Unprotect the vip
	self stop_magic_bullet_shield();
	self.ignoreme = false;
	self.health = 1;
	self set_fixednode_false();
	self set_force_color( "g" );
	self setthreatbiasgroup( "secure_vip_guard" );			
	
	// Make sure enemies focus on vip
	set_squad_ignore( true );	 

	// Set ground enemies to attack vip
	foreach( guy in level.secure_enemies[ "ground" ] )
	{
		if( isalive( guy ))
		{
			self vip_hunt_setup();
		}
	}

	// Wait, if enemies don't kill, then magic bullet will
	wait 3.0;

	origin_kill = GetEnt( "secure_vp_kill", "targetname" );
	MagicBullet( "m9", origin_kill.origin, self.origin );
	self kill();
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Setup an enemy to hunt the vip
vip_hunt_setup()
{
	self ClearGoalVolume();
	self.favoriteenemy = level.secure_vip;
	self SetGoalEntity( level.secure_vip);
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Turn on vulnerability for a group of allies
enable_hurt( special_hurt )
{
	// Sets up a watcher func that waits for enemies to enter "danger zone" 
	thread watcher_enable_hurt_player_attention();

	// Setup damage watcher
	foreach( guy in self )
	{
		guy thread watcher_enable_hurt_solo( special_hurt );
	}

	// Have allies focus on closest enemies when necessary
	foreach( guy in level.squad)
	{
		//guy thread watcher_squad_front_0_focus();
	}	
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Turn off vulnerability for a group of allies 
disable_hurt()
{
	flag_clear( "flag_script_vip_guard_vulnerable_override" );

	// Kill vulnerability scripts	
	level notify( "notify_secure_vip_not_vulnerable" );	
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Dialogue for when all agents almost dead
dialogue_vip_guard_almost_dead()
{
	flag_clear( "flag_script_low_priority_dialogue_allow" );

	radio_dialogue_stop();

	// Dialogue: SS: "We are down to two agents.  We need support, NOW!”
	radio_dialogue( "hithard_sslead_snipe_02" );

	// Dialogue: Baker: "Cover Patriot!"
	radio_dialogue( "hithard_bak_snipe_patriot" );
   
	flag_set( "flag_script_low_priority_dialogue_allow" );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Baker lets the player know that enemies are close to the VIP
watcher_enable_hurt_player_attention()
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );
	level endon( "notify_secure_vip_not_vulnerable" );	
	
	while( 1 )
	{
		flag_wait( "flag_secure_vip_vulnerable" ); 

		thread dialogue_baker_vip_vulnerable_player_attention();			
		
		flag_waitopen( "flag_secure_vip_vulnerable" );			

		// Kill dialogue
		
		level notify( "notify_secure_vip_vulnerable_dialogue_stop" );			
	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

dialogue_baker_vip_vulnerable_player_attention()
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );
	level endon( "notify_secure_vip_vulnerable_dialogue_stop" );
	level endon( "notify_secure_vip_not_vulnerable" );	
   
	flag_wait( "flag_script_high_priority_dialogue_allow" );

	if( level.secure_vip_vulnerable_first_time )
	{
		level.secure_vip_vulnerable_first_time = false;

		radio_dialogue_stop();

		// Dialogue: Baker: "Tangos are close to Patriot!"
		radio_dialogue( "hithard_bak_secure_44" );		
	}

	while( 1 )
	{
		wait_random_time( 5, 10 );

		//level._player thread display_hint( "hint_secure_vulnerable" );
		play_random_dialogue( level.secure_dialogue[ "baker_vip_vulnerable" ] );				
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// enables attention pointer
enableAttentionPointer( pointer_object, target, objective_number )
{	
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );
	flag_set( "_flag_script_attention_pointer_active" );

	while( flag( "_flag_script_attention_pointer_active" ))
	{
		move_time = 0;

		if( !player_looking_at( target.origin, 0.95 ))
		{				
			// Move pointer to in front of player			
			pointer_object.origin = GetPlayerSightPosition( Distance( level._player.origin, target.origin ));			
		
			// Pointer to player
			Objective_OnEntity( objective_number, pointer_object );
			
			if( Distance( target.origin, pointer_object.origin ) < Distance( level._player.origin, target.origin ))
			{  
				move_time = 1.0;
   			}
			else
			{
				move_time = 2.0;
			}

			pointer_object Moveto( target.origin, move_time );
			wait move_time;

			Objective_OnEntity( objective_number, target );
		}

		wait 0.05;
	}
	
	Objective_OnEntity( objective_number, target );	
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Turns off player attention pointer
DisableAttentionPointer()
{
	flag_clear( "_flag_script_attention_pointer_active" );		
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

GetPlayerSightPosition( distance )
{
	return level._player GetEye() + vector_multiply( AnglesToForward( level._player GetPlayerAngles() ), distance );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Set accuracy of an array of guys
set_ai_accuracy_array( accuracy_num )
{
	foreach( guy in self )
	{
		if( isalive( guy ))
		{
			guy.baseaccuracy = accuracy_num;
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Set accuracy of an guy
set_ai_accuracy( accuracy_num )
{
	if( isalive( self ))
	{
		self.baseaccuracy = accuracy_num;
	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Spawn a wave of enemies
spawn_enemy_wave( enemy_noteworthy_name, spawnfunc, threatbias_group, dialogue_array )
{
	// Setup spawner with script_noteworthy of "enemy_noteworthy_name"
	secure_enemies_spawner = GetEntArray( enemy_noteworthy_name, "script_noteworthy" );	   
	
	array_thread( secure_enemies_spawner, ::add_spawn_function, spawnfunc, threatbias_group );
	
	secure_enemies = [];

	secure_enemies = array_spawn( secure_enemies_spawner );
	
	// Check spawns against spawners
	if ( IsDefined( secure_enemies ))		
	{
		if ( secure_enemies.size < secure_enemies_spawner.size )
		{
			AssertMsg( secure_enemies_spawner.script_noteworthy + ": Could not spawn ALL enemies: " + secure_enemies.size + "/" + secure_enemies_spawner.size );	   	 	
		}
	}
  	else
	{																					   
		AssertMsg( "Could not spawn enemies..." );
	} 
 	
	// If there is callout dialogue
	if( IsDefined( dialogue_array ))
	{
		// Set the hatred
		secure_enemies thread dialogue_baker_wave_callout( enemy_noteworthy_name, dialogue_array );
	}
	
	return secure_enemies;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn function for secure enemies
spawnfunc_enemy_cortel_terrace( threatbias_group )
{	
	self endon( "death" );

	self setthreatbiasgroup( threatbias_group );

	self.grenadeammo = 0;
	self.goalradius = level.secure_special_goalradius;
	self.a.disableLongDeath = true;	
	self.ignoreme = true;
	self set_ai_accuracy( 0.01 );

	self thread watcher_enemy_death_counter();
	self thread waittill_goal_notify( self.script_noteworthy );
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

spawnfunc_enemy_cortel_balcony( threatbias_group )
{	
	self endon( "death" );

	self setthreatbiasgroup( threatbias_group );

	self.grenadeammo = 0;
	self.goalradius = level.secure_special_goalradius;
	self.a.disableLongDeath = true;
	self.ignoreall = true;
	self.ignoreme = true;
	self set_ai_accuracy( 0.01 );

	self thread watcher_enemy_death_counter();
	self thread spawnfunc_enemy_cortel_watcher();
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

// Logic for cortel inside RPG guys
spawnfunc_enemy_cortel_watcher()
{
	self endon( "death" );
	
	billboard_nodes = GetEntArray( "origin_billboard_killer", "targetname" );

	self waittill( "reached_path_end" );	

	// Give him a moment so he doesn't blow himself up
	wait 1.0;

	// Blow out the windows
	weapon_origin = self GetTagOrigin( "TAG_WEAPON_LEFT" ) + vector_multiply( AnglesToForward( self.angles ), 10 );

	// Shoot billboard first
	randomTarget = random( billboard_nodes );
	MagicBullet( "rpgx_straight", weapon_origin, randomTarget.origin );
	
	self.ignoreall = false;	
	level notify( "notify_" + self.script_noteworthy + "_at_goal" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn function for secure enemies
spawnfunc_enemy_cortel_inside( threatbias_group )
{	
	self endon( "death" );

	self setthreatbiasgroup( threatbias_group );

	self.grenadeammo = 0;
	self.ignoreall = true;
	self.goalradius = level.secure_special_goalradius;
	self.a.disableLongDeath = true;
	self.ignoreme = true;
	self set_ai_accuracy( 0.01 );	

	destroyOriginTarget = "node_origin_cortel_window_" + self.target;
	goToNodeTarget = self.target + "2";	
	
	self thread watcher_enemy_death_counter();
	self thread spawnfunc_enemy_cortel_inside_watcher( destroyOriginTarget, goToNodeTarget);	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn function for secure enemies
spawnfunc_enemy_bon( threatbias_group )
{	
	self endon( "death" );

	self setthreatbiasgroup( threatbias_group );

	self.grenadeammo = 0;
	self.goalradius = level.secure_special_goalradius;
	self.a.disableLongDeath = true;
	self AllowedStances( "stand" );
	self set_ai_accuracy( level.secure_enemy_accuracy_bon );

	self thread watcher_enemy_bon();
	self thread watcher_enemy_death_counter();	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

watcher_enemy_bon()
{
	wait 2.0;
	level notify( "notify_" + self.script_noteworthy + "_at_goal" ); 	
}
	
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn function for wave_1 regular (first wave)
spawnfunc_enemy_ground_first( threatbias_group )
{	
	self endon( "death" );

	self setthreatbiasgroup( threatbias_group );

	self thread magic_bullet_shield();	

	self.a.disableLongDeath = true;
	self.script_parameters = "front_0";
	self.grenadeammo = 0;		
	//self SetThreatIDOverlay( "auto" );

	self set_ai_accuracy( 2.0 );

	self set_fixednode_true();
											  
	self thread watcher_enemy_death_counter();									
	self thread spawnfunc_enemy_ground_first_damage_watcher();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// If wave_1 guy is shot, make him move to a new position
spawnfunc_enemy_ground_first_damage_watcher()
{
	self endon( "death" );
	self endon( "notify_secure_go_forth_and_die" );
 
	self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, idFlags );
	self set_fixednode_false();												
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn function for wave_1 spawnpool (advancing on the ground)
spawnfunc_enemy_wave_1_spawnpool( threatbias_group )
{	
	self endon( "death" );

	self setthreatbiasgroup( threatbias_group );
	
	self.a.disableLongDeath = true;
	self.grenadeammo = 0;
	self.script_parameters = "front_0";
	self.goalradius = level.secure_standard_goalradius;	
	level.num_enemies_spawned++;	

	self thread watcher_enemy_death_counter();	
 
	self go_to_goal_volume( "front_1" );
}
 
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn function for wave_1 secure enemies from vtol (advancing on the ground)
spawnfunc_enemy_wave_1_vtol( threatbias_group )
{	
	self endon( "death" );

	self setthreatbiasgroup( threatbias_group );

	level.secure_enemies[ "ground" ] = add_to_array( level.secure_enemies[ "ground" ], self );	
	
	self.grenadeammo = 0;
	self.goalradius = level.secure_standard_goalradius;
	self.script_parameters = "front_0";
	//self SetThreatIDOverlay( "auto" );

	self thread watcher_enemy_death_counter();
	self thread spawnfunc_enemy_wave_1_vtol_watcher();	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// watcher function for rpg guy
spawnfunc_enemy_wave_1_vtol_watcher( target )
{	
	self endon( "death" );

	self waittill( "jumpedout" );
	
	self.a.disableLongDeath = true;

	self go_to_goal_volume( "front_1" );	
	
	if( self.classname == "actor_nx_opfor_china_specops_rpg" )
	{	   	
		self forceUseWeapon( "asmk27_reflex", "secondary" );
	}	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// spawn function for guy who comes in at start and fires RPG at lapd car
spawnfunc_enemy_wave_1_lapd_rpg( threatbias_group, target )
{	
	self endon( "death" );

	self setthreatbiasgroup( threatbias_group );

	self.a.disableLongDeath = true;
	self.grenadeammo = 0;
	self.goalradius = 128;		
	self.ignoreall = true;

	level.secure_enemies[ "ground" ] = add_to_array( level.secure_enemies[ "ground" ], self );	

	self thread spawnfunc_enemy_wave_1_lapd_rpg_watcher( target );
	self thread watcher_enemy_death_counter();						
} 

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// watcher function for rpg guy
spawnfunc_enemy_wave_1_lapd_rpg_watcher( target )
{	
	self endon( "death" );

	//weapon_origin = self GetTagOrigin( "TAG_WEAPON_LEFT" );		

	//MagicBullet( "rpgx_straight", weapon_origin, level.vehicles[ "lapd_backup" ].origin );	
	
	self set_fixednode_false();	
	   
	self.ignoreall = false;	

	self go_to_goal_volume( "front_1" );

	self waittill( "goal" );

	//self SetThreatIDOverlay( "auto" );
	self forceUseWeapon( "asmk27_reflex", "secondary" );   
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn function for lapd car riding guys
spawnfunc_ally_swat_backup( threatbias_group )
{		
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );
	
	self setthreatbiasgroup( threatbias_group );

	self.baseaccuracy = 0.01;
	self.grenadeammo = 0;
	self.health = 300;	
	self.goalradius = level.secure_vip_guard_goalradius;

	level.secure_vip_guard[ "swat" ] = add_to_array( level.secure_vip_guard[ "swat" ], self );
	level.secure_vip_guard[ "all" ] = add_to_array( level.secure_vip_guard[ "all" ], self );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn function for enemy UAVs
spawnfunc_enemy_uav( threatbias_group )
{	 		
	self endon( "death" );

	self setthreatbiasgroup( threatbias_group );

	level.secure_enemies[ "uavs" ] = add_to_array( level.secure_enemies[ "uavs" ], self );

	self thread magic_bullet_shield();	

	self thread watcher_enemy_uav_death_solo();

	self thread watcher_enemy_uav_solo();						
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

watcher_enemy_uav_death_solo()
{
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );
		
	self waittill( "death" );

	result = false;

	if( !level.secure_uav_duke_dialog_done )
	{
		if( flag( "flag_script_low_priority_dialogue_allow" ) )
		{
			play_random_dialogue_positional( level.secure_dialogue[ "duke_uav_random" ], "duke" ); 
			level.secure_uav_duke_dialog_done = true;
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// UAV logic for rooftop attack
watcher_enemy_uav_solo()
{	
	self endon( "death" );			

	wait 0.5;

	self stop_magic_bullet_shield();

	// Fly up to rooftop perch to wait
	self vehicle_detachfrompath();
	self.currentnode = random( level.secure_uav_path[ "circle2" ] );	
	level.secure_uav_path[ "circle2" ] = arraY_remove( level.secure_uav_path[ "circle2" ], self.currentnode );
	self thread vehicle_resumepath();
	self GoPath();

	wait 0.5;

	// Go up to player one at a time (unless two are left, then two will go)
	while(( isalive_array( level.secure_enemies[ "uavs_attack" ] ) > 0 ) && ( isalive_array( level.secure_enemies[ "uavs" ] ) > 2 ))
	{
		wait 0.05;
	}
	
	flag_set( "flag_script_uav_attack_roof" );	
	
	// Consider the uav an "attacking" uav
	level.secure_enemies[ "uavs_attack" ] = add_to_array( level.secure_enemies[ "uavs_attack" ], self );	
	
	// Choose circle node up by rooftop and go
	circle = random( level.secure_uav_path[ "circle1" ] );	
	self thread maps\_attack_heli::SAV_switch_to_circling( circle.targetname );
	wait_random_time( 5, 10 );		
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Dialogue for UAVs
dialogue_baker_uavs()
{
	flag_clear( "flag_script_low_priority_dialogue_allow" );
	radio_dialogue_stop();
	
	// Dialogue: Baker: " UAVs!"
	//radio_dialogue( "hithard_bak_secure_30" );

	// Dialogue: Baker: "UAVs incoming!  Take cover!"
	radio_dialogue( "hithard_bak_snipe_08" );

	flag_set( "flag_script_low_priority_dialogue_allow" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// UAVs drop smoke
watcher_enemy_uav_smoke_drop_solo()
{
	level endon( "notify_secure_objective_wave_2_complete" );

	// Drop the smoke
	origin = self.origin;
	MagicGrenade( "smoke_grenade_miniuav", self.origin, self.origin + ( 0, 0, -10 ), 0.01 );		
	
	level.num_uav_smoke_dropped++;
	
	flag_set( "flag_script_uav_dropped_smoke" );	

	wait 10;

	// Keep smoke active while wave_2 is active
	while( level.secure_enemies[ "ground" ].size > 3 )
	{
		wait 19;
		PlayFx( level._effect[ "nx_grenade_smoke_5sec" ], ( origin[ 0 ], origin[ 1 ], -128 ));	
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn smoke on ground
spawn_smoke()
{
	origins = GetEntArray( "secure_ground_smoke", "script_noteworthy" );

	level._player waittill( "notify_rappel_start" );
	thread watcher_enemy_spawnpool();
	thread watcher_enemy_spawnpool_off( level.secure_wave_2_num_enemies );
	thread send_in_spawnpool( 5 );
	
	// Dialogue: Baker: "They’re dropping smoke!”
	radio_dialogue( "hithard_bak_snipe_34" );			

	foreach( origin in origins )
	{
		thread spawn_smoke_solo_watcher( origin );	
		wait_random_time( 0, 2 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Individual smoke fx loops
spawn_smoke_solo_watcher( origin )
{
	level endon( "notify_secure_objective_wave_2_complete" );

	origin playsound("smokegrenade_explode_default");
	
	// Keep smoke active while wave_2 is active
	while( 1 )
	{		
		PlayFx( level._effect[ "nx_grenade_smoke_5sec" ], ( origin.origin[ 0 ], origin.origin[ 1 ], -128 ));	
		wait 8;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
  
go_forth_and_die_ground( array, num )
{			
	while( ( level.secure_enemies[ "ground_front_0" ].size < num ) && ( array.size > 0 ))
	{
		level.secure_enemies[ "ground_front_0" ] = remove_dead_from_array( level.secure_enemies[ "ground_front_0" ] );
		guy = random( array );
		guy go_forth_and_die_ground_solo();
		array = array_remove( array, guy );
	}

	return array;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************  
  
go_forth_and_die_ground_solo()
{
	self endon( "death" );
	
	self notify( "notify_secure_go_forth_and_die" );
		
	//self SetThreatIDOverlay( "auto" );
	level.secure_enemies[ "ground_front_0" ] = add_to_array( level.secure_enemies[ "ground_front_0" ], self );	
	self setthreatbiasgroup( "secure_wave_1_front_0" );
	self.script_parameters = "front_0";
	self ClearGoalVolume();
	self.goalradius = 512;
	self.aggressivemode = 1;
	self.baseaccuracy = 1000;	

	self set_fixednode_false();						  	
 	self.script_forcegoal = 1;
	self set_force_color( "p" );
	
	//self set_fixednode_true();

	//self enable_cqbwalk();									
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
  
go_forth_and_die( array )
{			
	foreach( guy in array )
	{
		if( isalive( guy ))
		{
			guy = random( array );
			guy go_forth_and_die_solo();
			array = array_remove( array, guy );
		}
		wait 0.05;
	}
	
	return array;		
}
  
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************  
  
go_forth_and_die_solo()
{
	self endon( "death" );
	
	self notify( "notify_secure_go_forth_and_die" );	

	level.secure_enemies[ "ground_front_0" ] = add_to_array( level.secure_enemies[ "ground_front_0" ], self );	
	self setthreatbiasgroup( "secure_wave_1_front_0" );
	self.script_parameters = "front_0";
	self.goalradius = 512;
	self.aggressivemode = 1;
	self.baseaccuracy = 1000;	

	self set_fixednode_false();						  	
 	self.script_forcegoal = 1;
	self go_to_goal_volume( "front_0" );

	//self set_fixednode_true();

	//self enable_cqbwalk();									
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Watches wave_1 enemies and adds to the death counter if the player kills them
watcher_enemy_death_counter()
{
	level endon( "notify_secure_objective_complete" );	

	attacker = undefined;
	partName = undefined;

	while( isalive( self ))
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, idFlags );
	}

	// Find out who killed the dude
	//iprintlnbold( self.script_noteworthy + ": " + attacker.classname );

	if( isdefined( attacker.classname ))
	{
		switch( attacker.classname )
		{
			case "player": 										
			{
				level.secure_kill_tracker[ "player" ]++;
				break;
			}
			case "actor_nx_ally_us_specops_leader_pchute": 		
			{
				level.secure_kill_tracker[ "baker" ]++;
				break;
			}
			case "actor_nx_ally_us_specops_squadmate_pchute": 	
			{
				level.secure_kill_tracker[ "duke" ]++;
				break;
			}
			case "actor_nx_ally_us_secretservice":				
			{
				level.secure_kill_tracker[ "ss" ]++;
				break;
			}
			default:
			{
				level.secure_kill_tracker[ "other" ]++;
				break;
			}
		}
	}
		
	// Wave_1 killing spree objective: Player delivers finishing blow, gets credit 
	if( IsPlayer( attacker ))
	{
		/*
		if( partName == "j_head" )
		{
			dialogue_baker_encouragement( "headshot" );
		}
		else
		{
			dialogue_baker_encouragement();
		}
		*/

		//dialogue_baker_encouragement();

		level.secure_human_enemies_num_killed++;
		level notify( "secure_enemy_killed" );
  	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn vip guy
spawn_vip( guy_noteworthy, spawnfunc, threatbias )
{
	vp_spawner = getent( guy_noteworthy, "script_noteworthy" );
	vp_spawner add_spawn_function( spawnfunc, threatbias );	
	vip = vp_spawner spawn_ai();

	return vip;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn vip protection guard
// group_noteworthy = the script_noteworthy of the vip spawners
// group_type = "swat" or "secret_service"
spawn_vip_guard( group_noteworthy, group_type, number )
{
	// Container for spawned guys
	secure_vip_guard = [];
	
	// Grab all of entities with the group's script_noteworthy
	secure_vip_guard_spawner = GetEntArray( group_noteworthy, "script_noteworthy" );		
	
	// Check to make sure there are enough names for spawned allies
	if ( secure_vip_guard_spawner.size > level.secure_vip_guard_names.size )
	{
		AssertMsg( "Not enough names for vip secure guard guys (spawners: " + secure_vip_guard_spawner + ", Names: " + level.secure_vip_guard_names.size );
	}
	
	foreach( guy in secure_vip_guard_spawner )
	{
		// Assign script_friendname to guard members
		if( group_type == "swat" )
		{
			guy set_script_friendname( "Officer" );				
			array_spawn_function( secure_vip_guard_spawner, ::spawnfunc_ally_swat, "secure_vip_guard" );
		}
		else if( group_type == "secret_service" )
		{
			guy set_script_friendname( "Agent" );
			array_spawn_function( secure_vip_guard_spawner, ::spawnfunc_ally_ss, "secure_vip_guard" );
		}
	
		wait 0.05;
	}
	
	secure_vip_guard = [];

	//Spawn
	if( isdefined( number ))
	{
		for( i = 0; i < number; i++ )
		{
			spawned = secure_vip_guard_spawner[0] spawn_ai();
			secure_vip_guard = add_to_array( secure_vip_guard, spawned );
		}
	}
	else
	{
		secure_vip_guard = array_spawn( secure_vip_guard_spawner );

		// Make sure secure vip guard guys spawned ok
		if ( IsDefined( secure_vip_guard ))		
		{
			if ( secure_vip_guard.size != secure_vip_guard_spawner.size )
			{
				AssertMsg( group_noteworthy + ": Could not spawn ALL vip guard: " + secure_vip_guard.size + "/" + secure_vip_guard_spawner.size );
			}		
		}
		else
		{
			AssertMsg( "Could not spawn secure allies..." );
		}
	}
	
	return secure_vip_guard;		
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Create name and return
set_script_friendname( guy_title )
{
	guy_name = random( level.secure_vip_guard_names );
	level.secure_vip_guard_names = array_remove( level.secure_vip_guard_names, guy_name );

	// Assign name
	self.script_friendname = guy_title + " " + guy_name;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn Function for vip guard guys
spawnfunc_ally_swat( threatbias_group )
{		
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );
	
	self setthreatbiasgroup( threatbias_group );

	self.baseaccuracy = 0.01;
	self.grenadeammo = 0;
	self.health = 300;	
	self.goalradius = level.secure_vip_guard_goalradius;

	self enable_cqbwalk();			
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn Function for vip 
spawnfunc_ally_vip( threatbias_group )
{		
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );

	self maps\nx_hithard_anim::init_vp_anims();
	self.dontmelee = true;
	self.animname = "vp";
	if( isdefined( threatbias_group ))
	{
		self setthreatbiasgroup( threatbias_group );
	}

	self.goalradius = level.secure_civilian_goalradius;		

	self set_fixednode_true();
	self thread magic_bullet_shield();								   
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Spawn Function for vip guard guys
spawnfunc_ally_ss( threatbias_group )
{		
	level endon( "notify_secure_objective_complete" );
	level endon( "notify_secure_objective_failed" );

	self setthreatbiasgroup( threatbias_group );

	self.baseaccuracy = 0.01;
	self.grenadeammo = 0;
	self.health = 300;
	self.goalradius = level.secure_vip_guard_goalradius;

	if( level.secure_ss_cant_die < 2 )
	{
		self.script_parameters = "debug_cant_die";
		level.secure_ss_cant_die++;
	}

	if( self.script_noteworthy == "motorcade_vip_guard_1" )
	{
		self set_fixednode_true();
	}
	else
	{
		self.aggressivemode = 1;
	}
	
	self enable_cqbwalk();
	self prep_ss_motorcade();							   		
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Tracks damage on individual vip guard guy
watcher_enable_hurt_solo( special_hurt )
{
	level endon( "notify_secure_vip_not_vulnerable" );
	level endon( "notify_secure_vip_not_vulnerable_solo" );
	self endon( "death" );

	if( isdefined( self.script_parameters ))
	{
		if( self.script_parameters == "debug_cant_die" )
		{
			return;
		}
	}

	// Wait grace period time
	wait level.secure_vip_vulnerable_grace_time;	

	// Wait until an enemy is in front of the vip guard, then make vip guard vulnerable to said enemy
	while( 1 )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, idFlags );

		if( attacker == level._player )
		{
			// The player shot
			self damage_vip_guard( damage );

			if( flag( "flag_script_high_priority_dialogue_allow" ))
			{
				// Dialogue: Baker: "Specter, check your fire!"
				radio_dialogue_stop();
				radio_dialogue_interupt( "hithard_bak_snipe_check" );
			}
		}
		else if( isdefined( attacker.script_noteworthy ))
		{		
			if( isdefined( special_hurt ))
			{				
				if( attacker.script_noteworthy == special_hurt )
				{
					// Bonaventure sniper's shot
					self damage_vip_guard( 99999 );										
				}
			} 
			else if( flag( "flag_secure_vip_vulnerable" ) || flag( "flag_script_vip_guard_vulnerable_override" ))
			{
				// Someone shot, is it an allowable "damager"?
				if( isdefined( attacker.script_parameters ))
				{
					if( attacker.script_parameters == "front_0" ) 
					{
						self damage_vip_guard( damage );
					}
				}		
			}
		}
  	}			
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Hurt a vip
damage_vip_guard( damage )
{
	// Attacker is within range, damage or kill SS agent (based on amount of damage)
	if( self.health <= damage )
	{
		self stop_magic_bullet_shield();
		//iprintlnbold( "A Secret Serviceman has died! (Placeholder)" );
		self kill();				
	}			
	else
	{
		self.health = self.health - damage;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

// VTOL flies in and drops UAVs
event_vtol_uav_drop()
{
	vtol_uav_spawners = GetEntArray( "vtol_miniuav", "targetname" );
	//level.secure_uav_path[ "smoke" ] = GetStructArray( "uav_smoke_path", "script_noteworthy" );			
	level.secure_uav_path[ "circle1" ] = GetNodeArray( "uav_circle_path", "script_noteworthy" );
	level.secure_uav_path[ "circle2" ] = GetStructArray( "uav_circle_path2", "script_noteworthy" );

	// Spawn and go
	array_thread( vtol_uav_spawners, ::add_spawn_function, ::spawnfunc_enemy_uav, "secure_wave_uavs" );	

	flag_set( "start_vtol_miniuav_unload" );

	waittillframeend;

	vtol2_sfx = Get_Vehicle( "ec_vtol_miniuav_deploy_vtol", "targetname" );
	vtol2_sfx playsound( "scn_hhh_vtol_flyin03" );

	
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************


