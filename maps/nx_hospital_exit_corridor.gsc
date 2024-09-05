//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Nx_Hospital - Exit Corridor									**
//                                                                          **
//    Created: 11/15/11 - Ken Moodie										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


//*******************************************************************
//																	*
// EXIT CORRIDOR - Summary goes here								*
//																	*
//*******************************************************************
start()
{
	maps\nx_hospital_util::actor_teleport( level.squad[ "ALLY_ALPHA" ], "exit_corridor_start_alpha" );
	maps\nx_hospital_util::actor_teleport( level.squad[ "ALLY_BRAVO" ], "exit_corridor_start_bravo" );
	level._player maps\_nx_utility::move_player_to_start_point( "exit_corridor_start_player" );
}

main()
{
	thread exit_corridor_wave_logic();
	autosave_tactical();
	// level._player setOffhandPrimaryClass( "frag" );
	// level._player giveWeapon( "offensive_grenade" );
	// level._player setWeaponAmmoStock( "offensive_grenade", 20 );
	thread corridor_grenade_throw();
	thread generator_destruction( "dest_generator", "generator_light", "lamp_on");
	thread generator_destruction( "dest_generator_hallway", "generator_light_hallway", "lamp_on_hallway");
	thread lightbulb_destruction ( "light_hitbox_hallway", "generator_light_hallway", "lamp_on_hallway");
	thread lightbulb_destruction ( "light_hitbox_lobby", "generator_light", "lamp_on");
	thread final_corridor_events();
	thread lobby_badplace_setup();
	exit_corridor_dialog();
}

section_flag_inits()
{
	flag_init ("all_defenders_dead");
	flag_init ("kill_orders_received");
	flag_init ("hallway_light_destroyed");
	flag_init ("lobby_light_destroyed");
	flag_init ("mission_complete");
}

section_precache()
{
	PreCacheItem ("offensive_grenade");
	precacheString( &"NX_HOSPITAL_FAIL_OFFENSIVE_GRENADE" );
	precacheString( &"NX_HOSPITAL_HINT_USE_CAMERA" );
	PreCacheModel ("ch_industrial_lamp_off");
}

lobby_badplace_setup()
{
	volume = GetEnt ("enemy_badplace", "targetname");
	BadPlace_Brush( "enemy_badplace", -1, volume, "axis" );
}

mg_hallway_badplace_setup()
{
	volume = GetEnt ("mg_hallway_volume", "targetname");
	BadPlace_Brush( "mg_hallway_volume", -1, volume, "axis" );
}

exit_corridor_dialog()
{
	thread grenade_vo_hint();
	thread machine_gunner_vo();
	wait_for_targetname_trigger( "corridor_grenade_trigger");
	wait .3;
	level.squad[ "ALLY_BRAVO" ] dialogue_queue( "hos_kee_corr_grenaderun" );

	level waittill ("lobby_clear");
	// Keene - Lobby clear!
	wait .8;
	level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_lobbyclear" );
	// Baker - Move up!
	level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_moveup" );
	
	turret = GetEnt ("hallway_mg", "targetname");

	flag_wait ( "machine_gunner_detected");
	// If MG user is still alive
	wait 5;

	user = turret GetTurretOwner();
	if (isalive ( user ))
	{
		// If vending machine is still upright
		while ( maps\_dynamic_cover::dynamic_cover_activated( "hallway_vending_machine" ) != true)
		{
			// Keene - We need cover!
			level.squad[ "ALLY_BRAVO" ] dialogue_queue( "hos_kee_corr_needcover" );
			// Baker - Push over that vending machine!
			level.squad[ "ALLY_ALPHA" ] thread dialogue_queue( "hos_bak_corr_pushvendmach" );
			thread vending_machine_dynamic_cover( user );
			break;
		}
	}
	// Wait until the vending machine is tipped (by anyone)
	while ( isalive ( user ) && maps\_dynamic_cover::dynamic_cover_activated( "hallway_vending_machine" ) != true)
	{
		wait .1;
	}

	thread spotlight_hint_vo( turret );

	// level waittill ("turret_users_all_dead");
	flag_wait ("vignette_outro");
	// add_dialogue_line( "Baker", "Think that's the last of them.", "blue", 2 );
	wait 1.5;
	level.squad[ "ALLY_BRAVO" ] dialogue_queue( "hos_jenk_const_clear" );
	level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_watchforstragglers" );
	// flag_wait("squad_at_recovery_room");
	trigger = GetEnt ("squad_at_recovery_room", "targetname");
	while ( !level.squad[ "ALLY_BRAVO" ] isTouching ( trigger ))
	{
		wait .1;
	}
	// add_dialogue_line( "Baker", "Alright. Breaching, weapons tight.", "green", 2 );
	level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_breaching" );
}

spotlight_hint_vo( turret )
{
	level endon ("turret_users_all_dead");

	wait 4;
	// If light is still unbroken
	if ( IsTurretActive( turret ) && !flag ("hallway_light_destroyed") )
	{
		// add_dialogue_line( "Baker", "I can't see anything past that spotlight!", "green", 2 );
		level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_cantseeanything" );
	}

	wait 10;
	// If light is still unbroken
	if ( IsTurretActive( turret ) && !flag ("hallway_light_destroyed") )
	{
		// add_dialogue_line( "Baker", "The light's powered by that generator. Take it out!", "green", 2 );
		level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_takeoutgenerator" );
	}
}

machine_gunner_vo()
{
	level endon ("turret_users_all_dead");
	flag_wait ("machine_gunner_detected");

	// add_dialogue_line( "Keene", "Machine gunner! Get back! ", "blue", 2 );
	level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_machinegunner" );
}

vending_machine_cover_logic()
{
	level endon ("turret_users_all_dead");
	while ( maps\_dynamic_cover::dynamic_cover_activated( "hallway_vending_machine" ) != true)
	{
		wait .1;
	}
	issue_color_orders ("g346 b346", "allies");
}	

vending_machine_weapon_clear()
{
	
}

machine_gunner_logic( final_defenders )
{
	// wait for guys to spawn
	waittillframeend;
	foreach( actor in level.squad )
	{
		actor disable_pain();
		actor disable_bulletwhizbyreaction();
		actor.fixednode = true;
	}
	turret = GetEnt ("hallway_mg", "targetname");
	turret MakeTurretSolid();
	while ( !IsTurretActive( turret ) )
	{
		wait .2;
	}

	user = turret GetTurretOwner();
	user disable_pain();
	user.animname = "generic";
	user thread dialogue_queue( "est_ru4_attack" );
	thread vending_machine_cover_logic();

	if ( flag ( "machine_gunner_detected"))
	{
		issue_color_orders ( "b345 g345", "allies");
	}

	user waittill ("death");
	wait 2;
	replacement = get_closest_living( turret.origin, final_defenders );
	if ( isDefined ( replacement ))
	{
		node = GetNode ("mg_node", "targetname");
		replacement setGoalNode( node );
		replacement.goalradius = 16;
		replacement.fixednode = true;
		replacement waittill( "goal" );
		//node = GetNode ("mg_node", "targetname");
		//replacement setGoalNode( node );
		//replacement waittill( "goal" );
		replacement maps\_spawner::use_a_turret( turret );
		replacement disable_pain();
		level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_anotherguyonturret" );
		while ( isalive ( replacement ) )
		{
			wait .2;
		}
	}
	level notify ("turret_users_all_dead");	
	foreach( actor in level.squad )
	{
		actor.ignoreSuppression = true;
	}
	wait .2;
	if ( !flag ("vignette_outro"))
	{
		issue_color_orders( "g350 b350", "allies" );
	}
	// thread mg_hallway_badplace_setup();
}

grenade_vo_hint()
{
	level endon ( "lobby_clear");
	wait_for_script_noteworthy_trigger( "player_entered_lobby");
	wait 6;
	right_office = GetEnt ("right_office", "targetname");
	left_office = GetEnt ("left_office", "targetname");
	while ( 1 )
	{
		right_guys = right_office get_ai_touching_volume( "axis" );
		left_guys = left_office get_ai_touching_volume( "axis" );
		if ( right_guys.size >= 3 &&  ( level._player GetWeaponAmmoStock( "offensive_grenade" ) >= 1) )
		{
			if(cointoss())
			{
				level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_grenaderoffice" );
			}
			else
			{
				level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_duginroomonright" );
				level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_putgrenadeinthere" );
			}
			break;
		}
		if ( left_guys.size >= 3 &&  ( level._player GetWeaponAmmoStock( "offensive_grenade" ) >= 1))
		{
			if(cointoss())
			{
				level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_grenadeloffice" );
			}
			else
			{
				level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_bunchedupinleftroom" );
				level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_putgrenadeinthere" );
			}
			break;
		}
		wait .2;
	}

}

corridor_grenade_throw()
{
	wait_for_targetname_trigger( "corridor_grenade_trigger");
	guy = spawn_targetname( "corridor_grenade_thrower" );
	maps\nx_hospital_util::squad_cqb( false );
	guy.animname = "generic";
	guy.allowdeath = true;
	guy thread anim_single_solo ( guy, "grenade_throw");
	level.squad[ "ALLY_ALPHA" ].noGrenadeReturnThrow = true;
	level.squad[ "ALLY_BRAVO" ].noGrenadeReturnThrow = true;
	battlechatter_off( "allies" );
	wait 0.05;
	guy SetAnimTime( getanim_generic( "grenade_throw" ), 0.4 );
	guy thread dialogue_queue( "est_ru2_attack" );

	wait .4;
	end = GetEnt ("corridor_grenade_end", "targetname");
	if ( isAlive ( guy ))
	{
		guy MagicGrenade( guy gettagorigin( "TAG_INHAND" ), end.origin, 4.0 );
	}
	
	wait 4.1;
	level.squad[ "ALLY_ALPHA" ].noGrenadeReturnThrow = false;
	level.squad[ "ALLY_BRAVO" ].noGrenadeReturnThrow = false;

	issue_color_orders( "g310 b310", "allies" );
	battlechatter_on( "allies" );

}

exit_corridor_wave_logic()
{
	level.lobby_guys = [];
	wave_counters = getentarray( "exit_corridor_wave_counter", "script_noteworthy" );
	array_thread( wave_counters, ::add_spawn_function, ::exit_corridor_wave_counter );
	level.exit_corridor_wave_count = 0;
}

exit_corridor_wave_counter()
{
	level.lobby_guys[level.lobby_guys.size] = self;
	self waittill( "death" );
	level.lobby_guys = array_remove( level.lobby_guys, self );
	level.exit_corridor_wave_count++;
	// iprintln ( "Guys Killed: " + level.exit_corridor_wave_count );
	if ( level.exit_corridor_wave_count == 4 )
	{
		wait 2;
		trigger = getent( "corridor_wave_2_trigger", "targetname" );
		if ( isdefined( trigger ) )
		{
			trigger notify( "trigger" );
		}
		issue_color_orders( "g330 b330", "allies" );
	}
	if ( level.exit_corridor_wave_count == 11 )
	{
		thread spawn_final_defenders();
		triggers = GetEntArray ( "lobby_color_trigger", "targetname");
		foreach ( trigger in triggers)
		{
			trigger trigger_off();
		}
		level notify ("lobby_clear");
		waittillframeend;
		thread lobby_enemy_cleanup();
		thread machine_gunner_ally_reactions();

		issue_color_orders( "b340", "allies" );
		wait .7;
		issue_color_orders( "g340", "allies" );
	}
	
}

machine_gunner_ally_reactions()
{

	level.squad[ "ALLY_ALPHA" ] enable_sprint();
	level endon ("turret_users_all_dead"); 
	turret = GetEnt ("hallway_mg", "targetname");
	flag_wait ( "machine_gunner_detected");

	// Allies tend to end the encounter too quickly with grenades by blowing up the generator.
	foreach( actor in level.squad )
	{
		actor.grenadeAmmo = 0;
	}

	// Baker does his best to look at the MG
	level.squad[ "ALLY_ALPHA" ] SetLookAtEntity ( turret );
	issue_color_orders ( "b345 g345", "allies");
	wait 2;
	level.squad[ "ALLY_ALPHA" ] SetLookAtEntity ( );

	level.squad[ "ALLY_ALPHA" ] disable_sprint();
	wait 30;

	// If we're still pinned down at this point, allies should start using nades again
	foreach( actor in level.squad )
	{
		actor.grenadeAmmo = 1;
	}

}

lightbulb_destruction( light_hitbox_targetname, light_script_noteworthy, model_script_noteworthy)
{
	
	lamp_on = getent( model_script_noteworthy, "script_noteworthy");

	hitbox = GetEnt (light_hitbox_targetname, "targetname");
	hitbox setcandamage ( true );
	while ( 1 )
	{
		hitbox waittill ( "damage", damage, attacker, direction_vec, point, type );
		// iprintln (" type: " + type);
		if ( (type == "MOD_RIFLE_BULLET") ||  (type == "MOD_PISTOL_BULLET") )
		{
			break;
		}
	}

	lamp_on SetModel ("ch_industrial_lamp_off");
	playfxontag( level._effect[ "light_blowout" ], lamp_on, "tag_origin" );

	// Turn off the actual lights, too
	lights = getentarray( light_script_noteworthy, "script_noteworthy");
	foreach ( light in lights )
	{
		light SetLightIntensity( 0 );
		light notify ( "light_off" );

	}
	if ( light_script_noteworthy == "generator_light_hallway" && !flag ("vignette_outro") )
	{
		hallway_spotlight_destroyed();
	}
	if ( light_script_noteworthy == "generator_light" )
	{
		flag_set ("lobby_light_destroyed");
	}


}

generator_destruction( generator_script_noteworthy, light_script_noteworthy, model_script_noteworthy )
{
	generator = getent( generator_script_noteworthy, "script_noteworthy");
	playfxontag( level._effect[ "generator_blink" ], generator, "tag_fx" );

	// Wait until the generator is no longer destructible, i.e. destroyed
	while (generator isDestructible())
		wait .1; 
	//iPrintln ("Generator blew up");
	// Change into the "off" floodlight
	lamp_on = getent( model_script_noteworthy, "script_noteworthy");
	lamp_on SetModel ("ch_industrial_lamp_off");

	// Turn off the actual lights, too
	lights = getentarray( light_script_noteworthy, "script_noteworthy");
	foreach ( light in lights )
	{
		light SetLightIntensity( 0 );
		stopfxontag( level._effect[ "generator_blink" ], generator, "tag_fx" );
		light notify ( "light_off" );

	}

	// If it's the generator in the last hallway, find the turret gunner and nerf his accuracy
	if ( light_script_noteworthy == "generator_light_hallway" && !flag ("vignette_outro") )
	{
		hallway_spotlight_destroyed();
	}
	if ( light_script_noteworthy == "generator_light" )
	{
		flag_set ("lobby_light_destroyed");
	}
}

hallway_spotlight_destroyed()
{	
	level endon ("turret_users_all_dead");
	disable_trigger_with_targetname( "hallway_kill_zone" );
	flag_clear ("player_in_kill_zone");
	turret = GetEnt ("hallway_mg", "targetname");
	turret ClearTargetEntity();
	turret SetAISpread( 3 );
	turret TurretFireDisable();
	turret SetConvergenceTime( 2.5, "yaw" );
	level._player set_player_attacker_accuracy( 0.3 );
	level._player.ignoreme = true;
	if ( IsTurretActive( turret ) )
	{
		user = turret GetTurretOwner();
		// user custom_battlechatter( "response_ack_callout_generic_neg" );
		if ( flag ("machine_gunner_detected") && !flag ("hallway_light_destroyed") )
		{
			level.squad[ "ALLY_ALPHA" ] thread dialogue_queue( "hos_bak_corr_theycantsee" );
			foreach( actor in level.squad )
			{
				actor.ignoreSuppression = true;
			}
			issue_color_orders( "g350 b350", "allies" );
			// thread mg_hallway_badplace_setup();
		}
	}
	flag_set ("hallway_light_destroyed");
	wait 7;
	turret TurretFireEnable();
	level._player.ignoreme = false;
}

lobby_enemy_cleanup()
{
	foreach ( guy in level.lobby_guys)
	{
		maps\nx_hospital_hall_first_floor::encounter_cleanup_kill( guy );
		wait .2;
	}
}

/*
corridor_enemy_table_flip()
{
	wait_for_targetname_trigger( "table_flip_trigger");
	if (isalive (self))
	{
		self maps\_dynamic_cover::actor_table_flip("corridor_entrace_dynamic_cover");
		self.animname = "generic";
		self dialogue_queue ("est_ru_3_steady");
	}
}

corridor_enemy_door_kick()
{
	wait_for_targetname_trigger( "spray_and_pray_trigger");
	node = GetEnt ("door_kicker_node", "targetname");
	door_kicker = spawn_targetname ("door_kicker_spawner");
	door_kicker.animname = "generic";
	door_kicker.ignoreme = true;
	door_kicker thread dialogue_queue ("est_ru1_attack");
	node thread anim_single_solo ( door_kicker, "door_kick_in");
	wait .5;
	door = GetEnt ("lmg_guy_door", "targetname");
	door RotateTo ( (door.angles + (90, 0, 0)), .3, 0, 0.1 );
	door MoveTo ( (door.origin + (0, 12, 3)), .3, 0, 0.1 );
	door_kicker.ignoreme = false;
	door_kicker startcontinuousfire();
}
*/
//*******************************************************************
//                                                                  *
// Assassination                                                    *
//*******************************************************************

assassination_start()
{
	maps\nx_hospital_util::actor_teleport( level.squad[ "ALLY_ALPHA" ], "assassination_start_alpha" );
	maps\nx_hospital_util::actor_teleport( level.squad[ "ALLY_BRAVO" ], "assassination_start_bravo" );
	level._player maps\_nx_utility::move_player_to_start_point( "assassination_start_player" );
	thread maps\nx_hospital_anim::outro_spawn();
	flag_set ("vignette_outro");
}

assassination_main()
{
	level thread assassination_bink();
	level thread assassination_flatline_bink();

	// thread hand_cam_control();
	flag_wait ("mission_complete");
	// Uncomment this line and comment the line above to make the mission end before the outro vignette
	// flag_wait ("squad_at_recovery_room");
	nextmission();
}

assassination_catchup_nag()
{
	delay = 6;
	trigger = GetEnt ("player_near_outro", "targetname");
	trigger endon ("trigger");
	while ( 1 )
	{
		wait delay;
		// Over Here
		level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_overhere" );
		wait delay;
		// Walker, what's the holdup?
		level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_corr_whatsholdup" );
		wait delay;
		// Walker, now!
		level.squad[ "ALLY_ALPHA" ] dialogue_queue( "hos_bak_const_walkernow" );
		delay++;
	}
}

assassination_bink()
{
	level endon( "target_dead" );

	// preload the movie
	SetSavedDvar( "cg_cinematicFullScreen", "0" );			
	CinematicInGameLoopResident( "nx_hospital_ekg" );

	level waittill( "heart_beat_monitor_start" ); //delay so that this doesn't execute during level load.
	
	while( !IsCinematicLoaded() )
	{
		wait 0.05;
	}

	//ok it's loaded now, so lets start it over so it's timed up.
	SetSavedDvar( "cg_cinematicFullScreen", "0" );			
	CinematicInGameLoopResident( "nx_hospital_ekg" );

}

assassination_flatline_bink()
{
	level waittill( "target_dead" );
	// preload the movie
	SetSavedDvar( "cg_cinematicFullScreen", "0" );
	flag_set ("hvt_killed");
	CinematicInGameLoopResident( "nx_hospital_ekg_flatline" );
}


spawn_final_defenders()
{
	trigger = GetEnt ( "corridor_final_defense_trigger", "targetname");
	if ( isdefined( trigger ) )
	{
		trigger notify( "trigger" );
	}
	turret = GetEnt ("hallway_mg", "targetname");
	turret SetAISpread( 0.3 );
	thread hallway_kill_zone();
}

vending_machine_dynamic_cover( user )
{
	wait 5;

	if (isalive ( user ) && ( maps\_dynamic_cover::dynamic_cover_activated( "hallway_vending_machine" ) != true) && !flag ("hallway_light_destroyed"))
	{
		level.squad[ "ALLY_BRAVO" ] maps\_dynamic_cover::actor_vending_machine_tip("hallway_vending_machine");
	}

}

final_corridor_events()
{
	wait_for_targetname_trigger( "corridor_final_defense_trigger");
	thread lobby_enemy_cleanup();
	autosave_tactical();
	thread hallway_kill_zone();
	final_spawners = getentarray( "corridor_final_defense_spawners", "targetname" );
	array_thread( final_spawners, ::add_spawn_function, ::final_defender_setup );

	final_defenders = spawn_targetname ("corridor_final_defense_spawners");
	table_flipper = spawn_targetname ("table_flip_spawner");

	thread machine_gunner_logic ( final_defenders );
	thread maps\nx_hospital_anim::outro_spawn();
	waittill_dead( final_defenders );
	flag_set ("vignette_outro");
	// maps\nx_hospital_util::squad_cqb( true );

}

final_defender_setup()
{
	self endon ("death");
	self.disableLongDeath = true;
	level waittill ("turret_users_all_dead");
	// in case the light shootout logic bailed with the turret disabled, so the player can use it.
	turret = GetEnt ("hallway_mg", "targetname");
	turret TurretFireEnable();
	self.fixednode = false;
	self.aggressivemode = true;
	self maps\nx_hospital_atrium::ai_playerseek();
	self.goalradius = 128;
	self.ignoresuppression = true;
}

hallway_kill_zone()
{
	createThreatBiasGroup( "player" );
	level._player setThreatBiasGroup( "player" );
	flag_wait ("player_in_kill_zone");

	level._player set_player_attacker_accuracy( 100 );
	SetThreatBias( "axis", "player", 999999 );

	flag_waitopen("player_in_kill_zone");

	SetThreatBias( "axis", "player", 1 );
	level._player set_player_attacker_accuracy( 1 );

	if ( !flag ("hallway_light_destroyed"))
	{
		thread hallway_kill_zone();
	}
}
/*
hand_cam_control()
{
	
	turret = getent( "handheld_camera", "targetname" );
	turret hide();
	trigger = GetEnt ("camera_trigger", "targetname");
	trigger SetHintString( &"NX_HOSPITAL_HINT_USE_CAMERA" );
	trigger waittill ("trigger");

		
	level._player setplayerangles( ( turret.angles[ 0 ], turret.angles[ 1 ], level._player.angles[ 2 ] ) ); 
	
	turret useby( level._player );
	turret TurretFireDisable();

	level._player allowFire( false );
	setsaveddvar( "ui_hideMap", "1" );
	setsaveddvar( "compass", 0 );
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "hud_showStance", 0 );
}
*/
check_for_premature_assassination()
{
	level endon ("kill_orders_received");
	while ( 1 )
	{
		self waittill ( "damage", damage, attacker );
		if ( attacker == level._player )
		{
			set_hvt_dead( undefined );
			SetDvar( "ui_deadquote", &"NX_HOSPITAL_FAIL_KILLED_LEADER" );
			flag_set( "hvt_killed" );
			missionFailedWrapper();
		}
	}
}

set_hvt_dead( guy )
{
	level notify( "target_dead" );
}