//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Skyscraper Exfil Street Section								**
//                                                                          **
//    Created: 11/10/2011 - John Webb										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_riotshield;


//*******************************************************************
//                                                                  *
//	STREET - After crash to rooftop									*
//                                                                  *
//*******************************************************************
start()
{
	maps\nx_exfil_util::exfil_setup_allies( "street" );
	maps\nx_exfil_util::player_start( "street_player" );

	// Spawn the heli
	spotlight_heli = maps\nx_exfil::setup_spotlight_heli( "heli_focus_player_pos" );
	spotlight_heli thread maps\nx_exfil::spotlight_heli_final_reveal();

	// Flagsa
	flag_set( "entered_streets" );
	flag_set( "raptor_vo_complete" );

	// Disable battlechatter
	battlechatter_off( "allies" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
main()
{
	level._arcade_dudes_count = 0;

	level thread street_encounter_start();
	level thread street_start_dialogue();
	level thread cleanup_market();
	level disconnect_arcade_path();
	level thread maps\nx_exfil_anim::Rail01_kill_start();
	level thread give_grenades_at_smoke_screen();

	flood_lights_off = GetEntArray( "flood_lights_off", "script_noteworthy" );
	if( IsDefined( flood_lights_off ) )
	{
		for( index = 0; index < flood_lights_off.size; index++ )
		{
			flood_lights_off[index] Hide();
		}
	}

	flood_lights_on = GetEntArray( "flood_lights_on", "script_noteworthy" );
	if( IsDefined( flood_lights_on ) )
	//apm: turn on floodlight glow
	exploder ( "distant_glow_on" );
	flood_lights_on[0] playsound( "scn_exfil_floodlight" );
	//iprintlnbold ( " distant glow on" );
	{
		for( index = 0; index < flood_lights_on.size; index++ )
		{
			flood_lights_on[index] Show();
		}
	}

	battlechatter_off( "allies" );

	flag_wait( "street_enc_end" );
}

flag_inits()
{
	flag_init( "arcade_midpoint" );
	flag_init( "arcade_finished" );
	flag_init( "balcony_threat" );
	flag_init( "swat_van_reverse" );
	flag_init( "barricade_spawn" );
	flag_init( "barricade_backup" );
	flag_init( "street_enc_end" );
	flag_init( "riot_shields_in_place" );
	flag_init( "street_start_dialogue_finished" );
	flag_init( "balcony_start_dialogue_finished" );
	flag_init( "apc_move_up" );
	flag_init( "smoke_out" );
	flag_init( "start_smokescreen" );
	flag_init( "apc_turret_on" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
street_encounter_start()
{
//	flag_wait( "street_encounter_start" );

	autosave_by_name( "streets" );

	level.allies[ "ally1" ] disable_pain();  // Making ally invulnerable to help him keep up and push harder

	// Disable turret gunner for the time being
	turret_gunner = get_living_ai( "turret_gunner", "script_noteworthy" );
	if ( isAlive( turret_gunner ) )
	{
		turret_gunner.ignoreall = true;
	}

//	spawners = GetEntArray( "street_dudes", "script_noteworthy" );
//	array_thread( spawners, ::spawn_ai );

	// Spawn first wave
	//first_wave_spawners = GetEntArray( "street_troops_first_wave", "targetname" );

	spawners = GetEntArray( "street_troops_first_wave", "targetname" );
	foreach ( spawner in spawners )
	{
		spawner spawn_ai();
	}

	thread arcade_logic();
	thread balcony_side_logic();
	thread fall_guy();
	thread barricade_logic();

	flag_wait( "arcade_finished" );

	autosave_by_name( "arcade_finished" );

	thread barricade_end();

	flag_wait( "street_enc_end" );
	
	//iprintln ("street_enc_end");
	///apm: turn on hallway light pre-geenade
	maps\nx_exfil_fx::fx_set_hall_spot_params();
	exploder ( "hallway_pre" );

}

street_start_dialogue()
{
	//level.baker radio_dialogue( "exf_bak_barr_barricadeoffstreets" ); //Barricade!  Off the streets!
	flag_wait( "raptor_vo_complete" );

	level.baker radio_dialogue( "exf_bak_barr_streetsblocked" ); //shit, the streets blocked!

	flag_set( "music_street_start" );

   	wait 1.5;

	delaythread( 1.0, ::issue_color_orders, "r200", "allies" );
	level.baker radio_dialogue( "exf_bak_barr_illclearuphigh" ); // Off the street!  I'll go right and clear up high.
	//level.baker radio_dialogue( "exf_bak_barr_goingright" ); // Going right!
	//issue_color_orders( "r200", "allies" ); // Baker moves right
	//level.baker radio_dialogue( "exf_bak_barr_clearuphigh" ); // I'm going to clear up high
	flag_set( "street_start_dialogue_finished" );

	//radio_dialogue( "exf_cop_barri_shootyou" ); // Stop it. Put your hands up, otherwise I'm gonna shoot you.
	//wait 4.0;
	//radio_dialogue( "exf_cop_barri_surrender" ); // YOU CAN NOT GO ANY FURTHER.  SURRENDER NOW.
}
	
cleanup_market()
{
	// Cleanup first half of market when you enter streets
	market_volume = GetEnt( "market_cleanup_1", "script_noteworthy" );
	ai_group = market_volume get_ai_touching_volume( "axis" );
	AI_delete_when_out_of_sight( ai_group, 400 );

	// Cleanup entire market when the player gets halfway through streets
	flag_wait( "barricade_spawn" );
	market_volume = GetEnt( "market_cleanup_2", "script_noteworthy" );
	ai_group = market_volume get_ai_touching_volume( "axis" );
	AI_delete_when_out_of_sight( ai_group, 400 );
}

disconnect_arcade_path()
{
	block_brush = GetEnt( "block_arcade_path", "targetname" );
	block_brush.origin = block_brush.origin + (0,0,120);
	block_brush DisconnectPaths();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
arcade_logic()
{
	self endon ( "arcade_finished" );
	self endon ( "balcony_taken" );

	thread balcony_threats();

	flag_wait( "arcade_midpoint" );  // Wait until player has committed to arcade
	/*right_squad_A = get_ai_group_ai( "right_squad_A" );
	foreach ( troop in right_squad_A )
	{
		if ( isAlive( troop )
		{
			troop.favoriteenemy = level.allies[ "ally1" ];
		}
	}*/

	level notify( "arcade_taken" );

	arcade_reinforce = get_ai_group_ai( "arcade_reinforce" );
	foreach ( troop in arcade_reinforce )
		troop enable_cqbwalk();

	// Cleaning up right side troops after player has commited to the arcade.  Keeps them from back filling on the player
	right_squad_A = get_ai_group_ai( "right_squad_A" );
	foreach ( guy in right_squad_A )
	{
		guy Kill();
	}
}

balcony_threats()
{
	flag_wait( "arcade_midpoint" );

	balcony_dudes = get_ai_group_ai( "balcony_dudes" );

	foreach ( dude in balcony_dudes )
	{
		dude Kill( level.allies[ "ally1" ].origin, level.allies[ "ally1" ] );
	}
}


fall_guy()
{
	flag_wait( "balcony_threat" );

	level.baker thread ally_handle_balcony();

	/*fall_guy = get_living_ai( "fall_guy", "script_noteworthy" );
	if ( isDefined( fall_guy ) )
	{
		fall_guy.fixednode = true;
	}

	flag_wait( "arcade_finished" );*/
}

ally_handle_balcony()
{
	level thread balcony_dialogue();
	
	self thread increase_accuracy_while_player_in_volume( 2, "vol_arcade" );

	volume = GetEnt( "vol_balcony", "script_noteworthy" );
	while ( 1 )
	{
		ai = volume get_ai_touching_volume( "axis" );
		if ( ai.size == 0 )
		{
			// All ai are dead
			break;
		}
		wait 0.2;
	}
	
	thread balcony_cleared();	
}

balcony_cleared()
{
	flag_wait( "street_start_dialogue_finished" );
	flag_wait( "balcony_start_dialogue_finished" );
	level.baker radio_dialogue( "exf_bak_barr_balconyclear" ); // Balcony cleared!
	wait 1.0;

	if ( player_on_left() )
	{
		level.baker radio_dialogue( "exf_bak_barr_eyesonyou" ); // I got eyes on you.
		//add_dialogue_line( "BAKER:", "They're all over the arcade, Walker!", "blue" );
	}
	else
	{
		level.baker radio_dialogue( "exf_bak_barr_movementarcade" ); // Movement in the arcade!
	}
}

increase_accuracy_while_player_in_volume( new_accuracy, vol_noteworthy )
{
	self endon( "death" );
	level endon( "arcade_finished" );
	volume = GetEnt( vol_noteworthy, "script_noteworthy" );
	if ( !isDefined( volume ) )
	{
		return;
	}

	previous_accuracy = self.baseaccuracy;
	self.baseaccuracy = new_accuracy;

	while ( level._player IsTouching( volume ) )
	{
		wait 0.2;
	}

	self.baseaccuracy = previous_accuracy;
}

balcony_dialogue()
{
	flag_wait( "street_start_dialogue_finished" );
	if (! player_on_right() )
	{
		level.baker radio_dialogue( "exf_bak_barr_coveryoufrombalcony" ); // I'll cover you from the balcony
	}

	flag_set( "balcony_start_dialogue_finished" );
}

balcony_side_logic()
{
	self endon( "balcony_taken" );
	self endon( "arcade_taken" );

	flag_wait( "barricade_spawn" );

	right_squad_B = get_ai_group_ai( "right_squad_B" );
	foreach ( troop in right_squad_B )
		troop enable_cqbwalk();

	flag_wait( "arcade_midpoint_right" );

	vol_barricade = GetEnt( "vol_barricade", "script_noteworthy");

	arcade_troops = get_ai_group_ai( "arcade_reinforce" );
	foreach ( troop in arcade_troops )
	{
		troop SetGoalVolumeAuto( vol_barricade );
	}

	level notify( "balcony_taken" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

barricade_logic()
{
	// Attaching logic to riotshield guys for when to move
	riotshield_troops = GetEntArray( "riot_troops_left", "targetname" );
	array_thread( riotshield_troops, ::add_spawn_function, ::riotshield_moveup );
	//array_thread( riotshield_troops, ::add_spawn_function, ::riotshield_wave );

	riotshield_troops = GetEntArray( "riot_troops_right", "targetname" );
	array_thread( riotshield_troops, ::add_spawn_function, ::riotshield_moveup );
	//array_thread( riotshield_troops, ::add_spawn_function, ::riotshield_wave );

	// Get first squad cars to backfill the gap	
	barricade_setup_A = spawn_vehicles_from_targetname_and_drive( "barricade_setup_A" );
	barricade_setup_A[0] thread maps\nx_exfil_audio::police_car_radio_chatter();
	wait 2;

	//array_spawn_function_targetname( "fake_barricade_group", ::goto_goal_then_despawn );
	//array_spawn_targetname( "fake_barricade_group" );

	// Start smokescreen
	flag_wait( "start_smokescreen" );
	thread smokescreen();

	// Start dialogue about riot shields and turret gunner
	turret_gunner = get_living_ai( "turret_gunner", "script_noteworthy" );
	level thread barricade_dialogue( turret_gunner );

	// Player leaves arcade
	flag_wait( "arcade_finished" );

	// Kill remaining arcade spawners
	arcade_spawners = GetEntArray( "arcade_dudes", "script_noteworthy" );
	foreach ( ent in arcade_spawners )
	{
		if ( IsSpawner( ent ) )
		{
			ent delete();
		}
	}

	// Grab the arcade troops, and tell them to falback to the barricade area
	vol_barricade = GetEnt( "vol_barricade", "script_noteworthy");
	vol_arcade = GetEnt( "vol_arcade", "script_noteworthy" );
	arcade_troops = vol_arcade get_ai_touching_volume( "axis" );
	foreach( guy in arcade_troops )
	{
		guy SetGoalVolumeAuto( vol_barricade );
	}

	right_side_troops = get_ai_group_ai( "right_squad_B" );
	foreach( guy in right_side_troops )
	{
		guy SetGoalVolumeAuto( vol_barricade );
	}

	// Delete faraway right_squad_A troops
	right_side_a_troops = get_ai_group_ai( "right_squad_A" );
	AI_delete_when_out_of_sight( right_side_a_troops, 312 );

	//apm turn on stryker headlights
	styker_barricade = get_vehicle( "barricade_stryker", "targetname" );
	PlayFxOnTag( getfx( "stryker_headlight_l" ), styker_barricade, "TAG_FRONT_LIGHT_LEFT" );
	PlayFxOnTag( getfx( "stryker_headlight_l" ), styker_barricade, "TAG_FRONT_LIGHT_RIGHT" );  

	// Swat van logic - unloads when actors thin out
	thread swat_van_backup();

	flag_wait( "smoke_out" ); // Wait until smoke has been going for 6 seconds before continuing

	// Spawn riot troops
	level.riot_troops_left = array_spawn_targetname( "riot_troops_left" );
	level.riot_troops_right = array_spawn_targetname( "riot_troops_right" );	

	// Baker should now lower his threatbias
	level.baker.threatbias = 50;

	// Wait on riot shields
	level thread riot_in_place_timeout();
	flag_wait( "riot_shields_in_place" );

	// Wait for the player
	//flag_wait( "barricade_backup" );
	wait 2.0;

	// Send riot shields after the player
	level thread riot_assault_player();

	tank = Get_Vehicle( "barricade_stryker", "targetname" );
	if ( isDefined( tank ) )
	{
		tank gopath();
	}

	tank thread tank_turret_on();

	wait 18;

	if ( IsAlive( turret_gunner ) )
	{
		// Setup apc badplace
		bad_vol = GetEnt( "apc_badplace", "script_noteworthy" );		
		BadPlace_Brush( "", 9, bad_vol, "axis" );
	}

	wait 2.0;

	if ( IsAlive( turret_gunner ) )
	{
		flag_set( "apc_move_up" );
		spawn_vehicles_from_targetname_and_drive( "barricade_blocker" );
	}

	// Bring in SWAT van
}

tank_turret_on()
{
	// Turn turret back on
	turret_gunner = get_living_ai( "turret_gunner", "script_noteworthy" );
	if ( !isAlive( turret_gunner ) )
	{
		return;
	}

	self endon( "death" );
	turret_gunner endon( "death" );

	flag_wait( "apc_turret_on" );
	turret_gunner.ignoreall = false;
	level endon( "street_enc_end" );
	turret_gunner waittill( "death" );
	level.baker radio_dialogue( "exf_bak_gen_goodkill" ); // Good kill.
}

smokescreen()
{
	// Smoke!
	smoke_points = GetStructArray( "smoke", "script_noteworthy" );
	level thread maps\nx_exfil_util::smoke_throw( smoke_points, "street_enc_end" );
	wait 6;
	flag_set( "smoke_out" );
}

riot_in_place_timeout()
{
	// Timeout if they take too long
	wait 10;
	flag_set( "riot_shields_in_place" );
}

riot_assault_player()
{
	level endon( "street_enc_end" );
	// Send 1 riot shield dude against player at a time
	wait 4;
	riot_shields = array_combine( level.riot_troops_left, level.riot_troops_right );
	level.baker radio_dialogue( "exf_bak_barr_pushingforward" ); // They're pushing forward!


	assaulter = undefined;
	while ( 1 )
	{
		foreach ( guy in riot_shields )
		{
			wait 1; // Some delay
			if ( isAlive( guy ) )
			{
				guy thread riot_hunt_player();
			}
	
			guy waittill( "death" );	
		}
	}
}

riot_hunt_player()
{
	self endon( "death" );
	self.favoriteenemy = level._player;

	//small goal at the player so they can close in aggressively
	while ( 1 )
	{
		wait .5;
		if ( isdefined( self.enemy ) )
		{
			self setgoalpos( self.enemy.origin );
			self.goalradius = 128;
			self.goalheight = 81;
		}
	}
}

barricade_end()
{
	//flag_wait( "barricade_backup" );

	// Baker should move up
	issue_color_orders( "r53", "allies" );

	flag_wait( "riot_shields_in_place" );

	// Wait until 2 or less enemies near barricade
	vol_barricade_entire = GetEnt( "vol_barricade_entire", "script_noteworthy" );
	ai_at_barricade = undefined;
	turret_gunner = get_living_ai( "turret_gunner", "script_noteworthy" );
	while ( 1 )
	{
		ai_at_barricade = vol_barricade_entire get_ai_touching_volume( "axis" );
		if ( ai_at_barricade.size <= 2 && !IsAlive( turret_gunner ) )
		{
			break;
		}
		wait .3;
	}

	flag_set( "street_enc_end" );

	// Make remaining AI retreat
	retreat_struct = GetStruct( "barricade_retreat", "script_noteworthy" );
	foreach ( guy in ai_at_barricade )
	{
		if ( isAlive( guy ) )
		{
			guy thread retreat_and_despawn( retreat_struct.origin );
		}
	}

	thread audio_stop_dog_barking();

	wait 2.0;


	// Get Baker posted up down the alley and beckoning the player
	level.baker.cqbwalking = undefined;
//	level.baker enable_sprint();	

	level.baker clear_force_color();
	level.baker.goalradius = 24;
	level.baker SetGoalNode( GetNode( "baker_alley_start", "targetname" ) );
	
	level.baker thread radio_dialogue( "exf_bak_barr_fallingbackmovealley" ); // They're falling back!  Let's move through the alley!

	//flag_set( "music_street_end" ); //stops music after the barricade encounter ends

	level.baker waittill( "goal" );
	level thread barricade_baker_nag();
//	level.baker disable_sprint();
	level.baker enable_cqbwalk();

	flag_wait( "near_alley" );
	//level.baker set_force_color( "r" );
	//level.baker issue_color_orders( "r60", "allies" );

	level.baker.ignoreall = true;
	level.baker.goalradius = 120;
	baker_alley_2nd_corner = GetNode( "baker_alley_2nd_corner", "targetname" );
	level.baker SetGoalNode( baker_alley_2nd_corner );

	level notify( "baker_stop_prodding" );

//	level.baker enable_cqbwalk();
	level.baker enable_sprint();

	wait 1;
	flag_set( "music_street_end" ); //stop music as Baker heads into the alley

	level.baker thread radio_dialogue( "exf_bak_alley_exfilstorefront" ); // Alright, exfil target is a brown, 3 story storefront half a click north.

	flag_wait( "alley_begin" );

	level.baker thread cut_through_dialogue();

	//level.baker waittill( "goal" );
	level.baker enable_cqbwalk();

	baker_alley_idle = GetNode( "baker_alley_idle", "targetname" );
	level.baker SetGoalNode( baker_alley_idle );

	level.baker.goalradius = 64;
	level.baker waittill( "goal" );

	level.baker enable_cqbwalk();

	alley_enc();
}

cut_through_dialogue()
{
	wait 1;
	level.baker thread radio_dialogue( "exf_bak_alley_cutthroughbldng" ); // We can cut through this building.
	//level.baker thread radio_dialogue( "exf_bak_alley_buildinghot" ); // Be careful, this building's hot.
}

alley_enc()
{
//	level.baker issue_color_orders( "r61", "allies" );

	level.allies[ "ally1" ] SetGoalNode( GetNode( "baker_grenade_door", "targetname" ) );
	level.allies[ "ally1" ].goalradius = 128;
	level.allies[ "ally1" ] waittill( "goal" );
}

barricade_baker_nag()
{
	level endon( "baker_stop_prodding" );

	wait 5;
	level.baker radio_dialogue( "exf_bak_barr_letsmove" ); //c'mon walker, lets move!
	wait 7;
	level.baker radio_dialogue( "exf_bak_barr_downalley" ); //down the alley walker!
	wait 10;
	level.baker radio_dialogue( "exf_bak_barr_letsgo" ); //walker, lets go!
}

audio_stop_dog_barking()
{
	if ( !isDefined( level.dogs_barking ) )
	{
		return;
	}

	level.dogs_barking setsoundvolume( "emt_exfil_dogs", -100, 5 );
	wait 5.1;
	level.dogs_barking stopsounds();
	level.dogs_barking delete();

}

barricade_dialogue( turret_gunner )
{
	level endon( "street_enc_end" ); // Stop dialogue if player leaves area
	wait 3.0; // 3 seconds after smokescreen starts
	level.baker radio_dialogue( "exf_bak_barr_poppingsmoke" ); //They're popping smoke!
	
	flag_wait( "smoke_out" );
	flag_wait( "arcade_finished" );

	wait 12.0;
	level.baker radio_dialogue( "exf_bak_barr_riotshieldsthrowfrag" ); // They're using shields!  Throw a frag!

	if ( !isAlive( turret_gunner ) )
	{
		return;
	}

	// Only do apc callouts if turret gunner is alive
	turret_gunner endon( "death" );

	//level.baker radio_dialogue( "exf_bak_barr_theyvegotapc" ); // They’ve got an APC!
	flag_wait( "apc_turret_on" );
	level.baker radio_dialogue( "exf_bak_barr_armoredturret" ); //Armored turret!
	wait 4;
	level.baker radio_dialogue( "exf_bak_apc_takeoutturret" ); // Take out that turret!
	wait 10;
	level.baker radio_dialogue( "exf_bak_apc_knockturret" ); // Knock that turret out!
}


tarmac_riotshield_group()
{
	flag_wait( "arcade_midpoint" );

	wait .05;
	dir = AnglesToForward( ( 0, 360, 0 ) );

	team = get_living_ai_array( "riot_troops_left", "targetname" );
	foreach ( member in team )
		member riotshield_lock_orientation( 180 );

	group = group_create( team );
	if ( group.ai_array.size > 3 )
		group.fleethreshold = 2;
	group group_sprint_off();
	group group_initialize_formation( dir );
	group endon( "break_group" );

	node = getstruct( "riot_shield_middle_02", "targetname" );
	group group_move( node.origin, dir );

	group waittill_notify_or_timeout( "goal", 20 );

}


riotshield_moveup()
{
	self endon( "death" );
	self SetGoalPos( self.origin );
	self.goalradius = 16;
	self disable_exits();

	//flag_wait( "arcade_midpoint" );
	wait 1.3;

	//node = GetNode( self.target, "targetname" );
	node = getstruct( self.target, "targetname" );

	while ( isDefined( node ) )
	{	
		goal_type = undefined;
		//only nodes and structs dont have classnames - ents do
		if ( !isdefined( node.classname ) )
		{
			//only structs don't have types, nodes do
			if ( !isdefined( node.type ) )
				goal_type = "struct";
			else
				goal_type = "node";
		}
		else
			goal_type = "origin";
	
		require_player_dist = 300;
	
		//calling this because i DO want the radius to explode	
		self thread maps\_spawner::go_to_node( node, goal_type, undefined, require_player_dist );
	
		wait 1;
		self enable_exits();
	
		self waittill( "goal" );

		//node = GetNode( node.target, "targetname" );
		if ( isDefined( node.target ) )
		{
			node = getstruct( node.target, "targetname" );
		}
		else
		{
			break;
		}
	}

	flag_set( "riot_shields_in_place" );
	//flag_wait( "riot_seek_player" );
}

riotshield_wave()
{
	self endon( "death" );

	self.dontEverShoot = true;
	self.targetname = "riot_troops_left";
	thread enable_teamflashbangImmunity();
	self enable_teamflashbangImmunity();

	self add_wait( ::waittill_msg, "damage" );
	self add_wait( ::waittill_msg, "bullet_hitshield" );
	do_wait_any();

	wait RandomFloatRange( .75, 1.25 );

	self.dontEverShoot = undefined;
/*
	if ( !isdefined( self.script_noteworthy ) || !issubstr( self.script_noteworthy, "riotshield_group" ) )
		self.goalradius = 1500;
	else
		return;// dont want riotshield guys going blue just yet

	trigger_wait_targetname( "tarmac_retreat1" );
	self set_force_color( "blue" );
*/
}


swat_van_backup()
{
	// Grab swat van and tell it to set up the barricade
	swat_van_barricade = spawn_vehicle_from_targetname( "swat_van_barricade" );
	swat_van_barricade.veh_transmission = "reverse";
	swat_van_barricade gopath();

	swat_van_barricade_troops = get_ai_group_ai( "swat_van_barricade_troops" );
	foreach ( troop in swat_van_barricade_troops )
	{
		troop LaserForceOff();
	}

	//flag_wait( "swat_van_reverse" );
	wait 15;

	// Now wait until we only have a few non-riot troops left
	volume = GetEnt( "vol_barricade_entire", "script_noteworthy" );
	while ( 1 )
	{
		ai_group = volume get_ai_touching_volume( "axis" );
		count = 0;
		foreach ( guy in ai_group )
		{
			if ( guy.subclass != "riotshield" )
			{
				count++;
			}
		}
		//iprintln( "Barricade: " + count );

		if ( count < 5 )
		{
			flag_set( "swat_drive_up" );
			return;
		}

		wait 1;
	}
	
//	swat_van_barricade gopath();

}

player_on_right()
{
	vol = GetEnt( "vol_right_side", "script_noteworthy" );
	return level._player IsTouching( vol );
}

player_on_left()
{
	vol = GetEnt( "vol_arcade", "script_noteworthy" );
	return level._player IsTouching( vol );
}

goto_goal_then_despawn()
{
	self.ignoreall = true;
	target_struct = GetStruct( self.target, "targetname" );
	self.goalradius = 128;
	self SetGoalPos( target_struct.origin );
	self waittill( "goal" );
	self delete();
}

retreat_and_despawn( origin )
{
	self.ignoreall = true;
	self disable_cqbwalk();
	self.goalradius = 128;
	self SetGoalPos( origin );
	self waittill( "goal" );
	self delete();
}

give_grenades_at_smoke_screen()
{
	level waittill ("start_smokescreen");

	level._player GiveMaxAmmo( "fraggrenade" );
}