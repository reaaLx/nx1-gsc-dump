//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module: NX_LUNAR, Control Room Breach Mission Script					**
//			: A workspace for creating the control room breach without		**
//			: disruption of the rest of the mission							**
//                                                                          **
//    Created: 03/29/2011 - Colin Crenshaw									**
//                                                                          **
//****************************************************************************
#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

// All mission specific PreCache calls
mission_precache()
{
}

// All mission specific flag_init() calls
mission_flag_inits()
{
	AddNotetrack_flag( "generic" , "wedge_top" , "breaching_wedge_top" , "breach_friend_enter_01" );
	AddNotetrack_flag( "generic" , "wedge_bot" , "breaching_wedge_bottom" , "breach_friend_enter_01" );
}

//putting these here instead of nx_lunar_end_anim so it's easy to see in the test level.
#using_animtree( "generic_human" );
mission_actor_anims()
{
	level._scr_anim[ "generic" ][ "breach_friend_idle_01" ][ 0 ]		= %breach_flash_R1_idle;
	level._scr_anim[ "generic" ][ "breach_friend_enter_01" ]			= %nx_tp_lunar_endbreach_hawk;

	level._scr_anim[ "generic" ][ "breach_friend_idle_02" ][ 0 ]		= %breach_flash_R2_idle;
	level._scr_anim[ "generic" ][ "breach_friend_enter_02" ]			= %nx_tp_lunar_endbreach_ally1;
	
	level._scr_anim[ "generic" ][ "breach_scientist_react" ]			= %nx_tp_lunar_endbreach_body_pre;
	level._scr_anim[ "generic" ][ "nx_tp_lunar_endbreach_body" ]		= %nx_tp_lunar_endbreach_body;
	level._scr_anim[ "generic" ][ "nx_tp_lunar_endbreach_guard1" ]			= %nx_tp_lunar_endbreach_guard1;
	level._scr_anim[ "generic" ][ "nx_tp_lunar_endbreach_guard2" ]			= %nx_tp_lunar_endbreach_guard2;
	level._scr_anim[ "generic" ][ "nx_tp_lunar_endbreach_guard3" ]			= %nx_tp_lunar_endbreach_guard3;
	level._scr_anim[ "generic" ][ "nx_tp_lunar_endbreach_guard4" ]			= %nx_tp_lunar_endbreach_guard4;
	level._scr_anim[ "generic" ][ "nx_tp_lunar_endbreach_scientist_1" ]			= %nx_tp_lunar_endbreach_scientist_1;
	
	maps\_slowmo_breach::add_slowmo_breach_custom_function( "nx_tp_lunar_endbreach_body", ::breach_violent_decompres_handle_death );
	maps\_slowmo_breach::add_slowmo_breach_custom_function( "nx_tp_lunar_endbreach_scientist_1", ::breach_violent_decompres_handle_death );


	level._scr_anim[ "generic" ][ "scientist_sit_idle" ][0]			= %nx_tp_lunar_endbreach_scientist_sit_idle;
	level._scr_anim[ "generic" ][ "scientist_stand_idle" ][0]			= %nx_tp_lunar_endbreach_scientist_stand_idle;


	level._scr_anim[ "generic" ][ "casual_stand_idle" ][0]	 			= %casual_stand_idle;
	level._scr_anim[ "generic" ][ "casual_stand_idle" ][1]	 			= %casual_stand_idle_twitch;
	level._scr_anim[ "generic" ][ "casual_stand_idle" ][2]	 			= %casual_stand_idle_twitchB;

	level._scr_anim[ "generic" ][ "surprise1" ]	 			= %exposed_idle_reactA;
	level._scr_anim[ "generic" ][ "surprise2" ]	 			= %exposed_idle_reactB;
}
#using_animtree( "script_model" );
mission_scriptmodel_anims()
{

	//breacher wedge
	level._scr_animtree[ "breacher_wedge" ]				= #animtree;
	level._scr_anim[ "breacher_wedge" ][ "wedgetop" ]   = %nx_pr_lunar_endbreach_wedgetop;
	level._scr_anim[ "breacher_wedge" ][ "wedgebot" ]   = %nx_pr_lunar_endbreach_wedgebot;
	level._scr_anim[ "breacher_wedge" ][ "breach_friend_enter_01" ]   = %nx_pr_lunar_endbreach_hawk_wedge;
	level._scr_model[ "breacher_wedge" ]					= "nx_pr_lunar_breach_wedge";

	//breacher detonator
	level._scr_animtree[ "breacher_detonator" ]				= #animtree;
	level._scr_anim[ "breacher_detonator" ][ "breach_friend_enter_01" ]   = %nx_pr_lunar_endbreach_hawk_detonator;
	level._scr_model[ "breacher_detonator" ]					= "nx_pr_lunar_breach_detonator";

	//swivelchair
	level._scr_animtree[ "swivelchair" ]				= #animtree;
	level._scr_anim[ "swivelchair" ][ "breach_scientist_react" ]   = %nx_pr_lunar_endbreach_swivelchair_pre;
	level._scr_anim[ "swivelchair1" ][ "end_breach_explosion" ]   = %nx_pr_lunar_endbreach_chair1;
	level._scr_anim[ "swivelchair2" ][ "end_breach_explosion" ]   = %nx_pr_lunar_endbreach_chair2;
	level._scr_anim[ "swivelchair3" ][ "end_breach_explosion" ]   = %nx_pr_lunar_endbreach_chair3;
	level._scr_model[ "swivelchair" ]					= "nx_pr_lunar_swivel_chair";

	//breach Weapon
	level._scr_animtree[ "breacher" ]				= #animtree;
	level._scr_anim[ "breacher" ][ "breach_friend_enter_01" ]   = %nx_pr_lunar_endbreach_hawk_breachgun;
	level._scr_model[ "breacher" ]					= "weapon_breacher";

	//breach explosion ammo
	level._scr_animtree[ "nx_ammobox_01" ]				= #animtree;
	level._scr_anim[ "nx_ammobox_01" ][ "end_breach_explosion" ]   = %nx_pr_lunar_endbreach_ammo_01;
	level._scr_anim[ "nx_ammobox_02" ][ "end_breach_explosion" ]   = %nx_pr_lunar_endbreach_ammo_02;
	level._scr_anim[ "nx_ammobox_03" ][ "end_breach_explosion" ]   = %nx_pr_lunar_endbreach_ammo_03;
	level._scr_anim[ "nx_ammobox_04" ][ "end_breach_explosion" ]   = %nx_pr_lunar_endbreach_ammo_04;
	level._scr_anim[ "nx_ammobox_05" ][ "end_breach_explosion" ]   = %nx_pr_lunar_endbreach_ammo_05;
	level._scr_anim[ "nx_ammobox_06" ][ "end_breach_explosion" ]   = %nx_pr_lunar_endbreach_ammo_06;
	level._scr_anim[ "nx_ammobox_07" ][ "end_breach_explosion" ]   = %nx_pr_lunar_endbreach_ammo_07;
	level._scr_anim[ "nx_ammobox_08" ][ "end_breach_explosion" ]   = %nx_pr_lunar_endbreach_ammo_08;
	level._scr_anim[ "nx_ammobox_09" ][ "end_breach_explosion" ]   = %nx_pr_lunar_endbreach_ammo_09;
	level._scr_anim[ "nx_ammobox_10" ][ "end_breach_explosion" ]   = %nx_pr_lunar_endbreach_ammo_10;
	level._scr_model[ "nx_ammobox_01" ]					= "nx_ammobox_01";
	
	//breach explosion helmet
	level._scr_animtree[ "nx_pr_lunar_helmet_ec" ]				= #animtree;
	level._scr_anim[ "nx_pr_lunar_helmet_ec01" ][ "end_breach_explosion" ]   = %nx_pr_lunar_endbreach_ammo_01;
	level._scr_anim[ "nx_pr_lunar_helmet_ec02" ][ "end_breach_explosion" ]   = %nx_pr_lunar_endbreach_ammo_02;
	level._scr_anim[ "nx_pr_lunar_helmet_ec03" ][ "end_breach_explosion" ]   = %nx_pr_lunar_endbreach_ammo_03;
	level._scr_model[ "nx_pr_lunar_helmet_ec" ]					= "nx_pr_lunar_helmet_ec";

	//breach explosion crates
	level._scr_animtree[ "nx_pr_crate01" ] = #animtree;
	level._scr_anim[ "nx_pr_crate01" ][ "end_breach_explosion" ] = %nx_pr_lunar_endbreach_crate_01;
	level._scr_anim[ "nx_pr_crate02" ][ "end_breach_explosion" ] = %nx_pr_lunar_endbreach_crate_02;
	level._scr_anim[ "nx_pr_crate03" ][ "end_breach_explosion" ] = %nx_pr_lunar_endbreach_crate_03;
	level._scr_anim[ "nx_pr_crate04" ][ "end_breach_explosion" ] = %nx_pr_lunar_endbreach_crate_04;
	level._scr_anim[ "nx_pr_crate05" ][ "end_breach_explosion" ] = %nx_pr_lunar_endbreach_crate_05;
	level._scr_anim[ "nx_pr_crate06" ][ "end_breach_explosion" ] = %nx_pr_lunar_endbreach_crate_06;
	level._scr_anim[ "nx_pr_crate07" ][ "end_breach_explosion" ] = %nx_pr_lunar_endbreach_crate_07;
	level._scr_anim[ "nx_pr_crate08" ][ "end_breach_explosion" ] = %nx_pr_lunar_endbreach_crate_08;
	level._scr_anim[ "nx_pr_crate09" ][ "end_breach_explosion" ] = %nx_pr_lunar_endbreach_crate_09;
	level._scr_anim[ "nx_pr_crate10" ][ "end_breach_explosion" ] = %nx_pr_lunar_endbreach_crate_10;
	level._scr_anim[ "nx_pr_crate11" ][ "end_breach_explosion" ] = %nx_pr_lunar_endbreach_crate_11;
	level._scr_anim[ "nx_pr_crate12" ][ "end_breach_explosion" ] = %nx_pr_lunar_endbreach_crate_12;
	level._scr_anim[ "nx_pr_crate13" ][ "end_breach_explosion" ] = %nx_pr_lunar_endbreach_crate_13;
	level._scr_anim[ "nx_pr_crate14" ][ "end_breach_explosion" ] = %nx_pr_lunar_endbreach_crate_14;
	level._scr_anim[ "nx_pr_crate15" ][ "end_breach_explosion" ] = %nx_pr_lunar_endbreach_crate_15;
	level._scr_model[ "nx_pr_crate01" ] = "nx_moonbase_plastic_crate_04";

	maps\_slowmo_breach::set_slowmo_door_breach_function( ::breach_door_callback );
}

#using_animtree( "multiplayer" );
mission_breach_player_anims()
{
	level._slowmo_viewhands												= "viewhands_us_lunar_scripted";
	
	level._scr_animtree[ "active_breacher_rig" ]						= #animtree;
	level._scr_model[ "active_breacher_rig" ]							= level._slowmo_viewhands;
	level._scr_anim[ "active_breacher_rig" ][ "breach_player_anim" ]	= %nx_fp_lunar_endbreach_player;
	
	AddNotetrack_CustomFunction( "active_breacher_rig", "disable_viewmodel_hacks", ::breaching_disable_viewmodel_hack, "breach_player_anim" );
	
	//hacky ass shit. We should use note tracks at some point.
	level.custom_slowmo_breach = true;
	level.custom_slowmo_breach_start_delay = 2.25;	
	level.custom_slowmo_breach_sound_delay = 0.5;//lame lame lame. How far into the animation the explosion is. Should use note tracks..
}

#using_animtree( "player" );
mission_player_anims()
{
	level._scr_animtree[ "player_rig" ]									= #animtree;
	level._scr_model[ "player_rig" ]									= level._slowmo_viewhands;
}




//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main()
{
	level._player setViewmodel( "viewhands_us_lunar" );
	
	maps\_slowmo_breach::slowmo_breach_init();
	
	mission_precache();
	mission_flag_inits();
	
	mission_actor_anims();
	mission_scriptmodel_anims();
	mission_breach_player_anims();
	mission_player_anims();

	level._effect[ "nx_lunar_armory_depressurization" ]							= loadfx( "nx/lunar/nx_lunar_armory_depressurization" );
	level._effect[ "nx_lunar_breach_charge_insertion" ]							= loadfx( "nx/lunar/nx_lunar_breach_charge_insertion" );
	level._effect[ "nx_lunar_steam_jet_blow" ]									= loadfx( "nx/lunar/nx_lunar_steam_jet_blow" );
	
	maps\_slowmo_breach::add_breach_func( ::breaching_explode_glass );
}

//vignette idle actors which will be deleted once the breach starts and replaced by spawned in actors.
casual_placeholder_enemy_animations()
{
	breach_guard_1 = maps\_spawner::spawner_dronespawn( getent( "breach_guard_1", "script_noteworthy" ) );
	breach_guard_2 = maps\_spawner::spawner_dronespawn( getent( "breach_guard_2", "script_noteworthy" ) );
	breach_guard_3 = maps\_spawner::spawner_dronespawn( getent( "breach_guard_3", "script_noteworthy" ) );
	breach_guard_4 = maps\_spawner::spawner_dronespawn( getent( "breach_guard_4", "script_noteworthy" ) );
	breach_scientist_1 = maps\_spawner::spawner_dronespawn( getent( "breach_scientist_1", "script_noteworthy" ) );

	breach_guard_1.animname = "generic";
	breach_guard_1 thread anim_loop_solo( breach_guard_1, "casual_stand_idle" );
	breach_guard_2.animname = "generic";
	breach_guard_2 thread anim_loop_solo( breach_guard_2, "casual_stand_idle" );
	breach_guard_3.animname = "generic";
	breach_guard_3 thread anim_loop_solo( breach_guard_3, "casual_stand_idle" );
	breach_guard_4.animname = "generic";
	breach_guard_4 thread anim_loop_solo( breach_guard_4, "casual_stand_idle" );
	breach_scientist_1.animname = "generic";
	breach_scientist_1 thread anim_loop_solo( breach_scientist_1, "scientist_stand_idle" );

	//spawn the objects that get sucked out in the explosion
	thread breaching_explosion();

	//level waittill("breaching");
	//breach_guard_1 thread anim_single_solo( breach_guard_4, "surprise1" );
	//breach_scientist_1 thread anim_single_solo( breach_guard_4, "surprise2" );
	
	level waittill("breach_actors_spawned");
	
	breach_guard_1 delete();
	breach_guard_2 delete();
	breach_guard_3 delete();
	breach_guard_4 delete();
	breach_scientist_1 delete();
}

friendly_actor_breach_start()
{
	//wait till the player triggers the breach
	level waittill("breaching");

	//get the breach nodes.
	breaching_friendly_node1 = GetNode("breaching_friendly1", "targetname");
	breaching_friendly_node2 = GetNode("breaching_friendly2", "targetname");
	
	assert(IsDefined(breaching_friendly_node1));
	assert(IsDefined(breaching_friendly_node2));
	
	//now figure out the two closest to the friendly breaching nodes.
	breaching_friendly1 = level.hawk;
	breaching_friendly2 = level.eagle;
	
	//make sure the generic anim scene is chosen.
	breaching_friendly1.animname = "generic";
	breaching_friendly2.animname = "generic";
	

	//switch hawks weapon
	//breaching_friendly1 forceUseWeapon( "breacher", "primary" );
	//spawn a model for the breacher weapon
	//breaching_friendly1_breacher = spawn_anim_model("breacher");
	//breaching_friendly1_breacher.animname = "breacher";
	breaching_friendly1_detonator = spawn_anim_model("breacher_detonator");
	breaching_friendly1_detonator.animname = "breacher_detonator";
	breaching_friendly1_wedge = spawn_anim_model("breacher_wedge");
	breaching_friendly1_wedge.animname = "breacher_wedge";

	//play the breaching anims.
	breaching_friendly_node1 thread anim_single_solo(breaching_friendly1, "breach_friend_enter_01");
	breaching_friendly_node2 thread anim_single_solo(breaching_friendly2, "breach_friend_enter_02");	
	//breaching_friendly_node1 thread anim_single_solo(breaching_friendly1_breacher, "breach_friend_enter_01");
	breaching_friendly_node1 thread anim_single_solo(breaching_friendly1_detonator, "breach_friend_enter_01");
	breaching_friendly_node1 anim_single_solo(breaching_friendly1_wedge, "breach_friend_enter_01");	

	breaching_friendly1_wedge delete();
}

enemy_actor_breach_start()
{
	breach_scientist_2 = maps\_spawner::spawner_dronespawn( getent( "breach_scientist_2", "script_noteworthy" ) );
	breach_scientist_2_chair = spawn_anim_model("swivelchair");

	breach_scientist_2.animname = "generic";
	breach_scientist_2_chair.animname = "swivelchair";

	//breach_scientist_node = getent("vignette_control_breach_scientist2", "script_noteworthy");

	breach_scientist_2 thread anim_loop_solo( breach_scientist_2, "scientist_sit_idle" );
	breach_scientist_2 thread anim_first_frame_solo( breach_scientist_2_chair, "breach_scientist_react" );
		
	//wait till the player triggers the breach
	level waittill("breaching");
	
	//play the animation of him running for his helmet.
	breach_scientist_2 thread anim_single_solo( breach_scientist_2, "breach_scientist_react" );
	breach_scientist_2 thread anim_single_solo( breach_scientist_2_chair, "breach_scientist_react" );
	
	level waittill("breach_actors_spawned");
	//breach_scientist_2 thread anim_single_solo( breach_scientist_2_chair, "breach_explosion" );
	breach_scientist_2 delete();
	breach_scientist_2_chair delete();
}

//kill the actor once his animation finishes.
breach_violent_decompres_handle_death()
{
	self waittill("finished_breach_start_anim");
	self.a.nodeath = true;
	self Kill();
}

breach_door_callback( ent )
{
	self thread breaching_wedge_top( ent );
	self thread breaching_wedge_bottom( ent );
}

//Spawn the wedge models and start the fx and animation on the door
//Triggered by a notetrack on hawk's animation
breaching_wedge_top( breach_node ) 
{
	flag_wait( "breaching_wedge_top" );
	//do shiz here.
	//the breach_node is the entity that contains all of the information about the breach, including the 
	//left door post node breach_node.left_post
	
	//spawn a model for the breacher wedge
	breaching_friendly1_wedge2 = spawn_anim_model("breacher_wedge");
	breaching_friendly1_wedge2.animname = "breacher_wedge";

	//play the wedge anim.
	breach_node.left_post thread anim_single_solo(breach_node.left_post.door, "wedgetop");
	breach_node.left_post anim_single_solo(breaching_friendly1_wedge2, "wedgetop"); 
	playFXOnTag( level._effect[ "nx_lunar_breach_charge_insert_back_air" ], breaching_friendly1_wedge2, "tag_fx" );
	
	playfxontag( level._effect[ "nx_lunar_breach_charge_insertion" ], breaching_friendly1_wedge2, "tag_fx" );
	
	level waittill( "breach_explosion" );
	stopFXOnTag( level._effect[ "nx_lunar_breach_charge_insert_back_air" ], breaching_friendly1_wedge2, "tag_fx" );
	breaching_friendly1_wedge2 Hide();

	//Wait for the explosion
	level waittill("breach_actors_spawned");
	exploder( "fx_control_breach" );
	
	level waittill( "sp_slowmo_breachanim_done" );
	breaching_friendly1_wedge2 delete();
	
}

breaching_wedge_bottom( breach_node )
{
	flag_wait( "breaching_wedge_bottom" );
	//also do shiz here.
	//spawn a model for the breacher wedge
	breaching_friendly1_wedge3 = spawn_anim_model("breacher_wedge");
	breaching_friendly1_wedge3.animname = "breacher_wedge";


	//play the wedge anim.
	breach_node.left_post thread anim_single_solo(breach_node.left_post.door, "wedgebot");
	breach_node.left_post thread anim_single_solo(breaching_friendly1_wedge3, "wedgebot"); 
	playfxontag( level._effect[ "nx_lunar_breach_charge_insertion" ], breaching_friendly1_wedge3, "tag_fx" );
	playFXOnTag( level._effect[ "nx_lunar_breach_charge_insert_back_air" ], breaching_friendly1_wedge3, "tag_fx" );

	//Wait for the explosion
	level waittill("breach_explosion");
	stopFXOnTag( level._effect[ "nx_lunar_breach_charge_insert_back_air" ], breaching_friendly1_wedge3, "tag_fx" );
	breaching_friendly1_wedge3 Hide();
	
	level waittill( "sp_slowmo_breachanim_done" );
	breaching_friendly1_wedge3 delete();
}

breaching_explode_glass( breach_rig )
{
	//get the panes of glass by targetname, and blow them in towards the breach location.
	window_right = GetGlass( "exploding_glass_right" );
	if( IsDefined( window_right ) )
	{
		window_right_origin = GetGlassOrigin( window_right );
		DestroyGlass( window_right, breach_rig.origin - window_right_origin );
	}
	
	window_left = GetGlass( "exploding_glass_left" );
	if( IsDefined( window_left ) )
	{
		window_left_origin = GetGlassOrigin( window_left );
		DestroyGlass( window_left, breach_rig.origin - window_left_origin  );
	}
}

breaching_disable_viewmodel_hack( guy )
{
	viewmodel_hacks = GetDvar( "viewModelHacks" );
	
	//turn off the viewmodel depth hack so that the player can grab the handhold in the weapon breach raise animation.
	SetSavedDvar( "viewModelHacks", 0 );
	
	//when it's done, reset to what the original value was
	level waittill( "sp_slowmo_breachanim_done" );	
	SetSavedDvar( "viewModelHacks", viewmodel_hacks );
}
breaching_explosion()
{
	//Spawn all the models
	swivelchair2 = spawn_anim_model("swivelchair");
	swivelchair3 = spawn_anim_model("swivelchair");
	swivelchair2.animname = "swivelchair2";
	swivelchair3.animname = "swivelchair3";
	helmetec1 = spawn_anim_model("nx_pr_lunar_helmet_ec");
	helmetec2 = spawn_anim_model("nx_pr_lunar_helmet_ec");
	helmetec3 = spawn_anim_model("nx_pr_lunar_helmet_ec");
	helmetec1.animname = "nx_pr_lunar_helmet_ec01";
	helmetec2.animname = "nx_pr_lunar_helmet_ec02";
	helmetec3.animname = "nx_pr_lunar_helmet_ec03";
	ammo01 = spawn_anim_model("nx_ammobox_01");
	ammo02 = spawn_anim_model("nx_ammobox_01");
	ammo03 = spawn_anim_model("nx_ammobox_01");
	ammo04 = spawn_anim_model("nx_ammobox_01");
	ammo05 = spawn_anim_model("nx_ammobox_01");
	ammo06 = spawn_anim_model("nx_ammobox_01");
	ammo07 = spawn_anim_model("nx_ammobox_01");
	ammo08 = spawn_anim_model("nx_ammobox_01");
	ammo09 = spawn_anim_model("nx_ammobox_01");
	ammo10 = spawn_anim_model("nx_ammobox_01");
	ammo01.animname = "nx_ammobox_01";
	ammo02.animname = "nx_ammobox_02";
	ammo03.animname = "nx_ammobox_03";
	ammo04.animname = "nx_ammobox_04";
	ammo05.animname = "nx_ammobox_05";
	ammo06.animname = "nx_ammobox_06";
	ammo07.animname = "nx_ammobox_07";
	ammo08.animname = "nx_ammobox_08";
	ammo09.animname = "nx_ammobox_09";
	ammo10.animname = "nx_ammobox_10";
	nx_pr_crate01 = spawn_anim_model("nx_pr_crate01");
	nx_pr_crate02 = spawn_anim_model("nx_pr_crate01");
	nx_pr_crate03 = spawn_anim_model("nx_pr_crate01");
	nx_pr_crate04 = spawn_anim_model("nx_pr_crate01");
	nx_pr_crate05 = spawn_anim_model("nx_pr_crate01");
	nx_pr_crate06 = spawn_anim_model("nx_pr_crate01");
	nx_pr_crate07 = spawn_anim_model("nx_pr_crate01");
	nx_pr_crate08 = spawn_anim_model("nx_pr_crate01");
	nx_pr_crate09 = spawn_anim_model("nx_pr_crate01");
	nx_pr_crate10 = spawn_anim_model("nx_pr_crate01");
	nx_pr_crate11 = spawn_anim_model("nx_pr_crate01");
	nx_pr_crate12 = spawn_anim_model("nx_pr_crate01");
	nx_pr_crate13 = spawn_anim_model("nx_pr_crate01");
	nx_pr_crate14 = spawn_anim_model("nx_pr_crate01");
	nx_pr_crate15 = spawn_anim_model("nx_pr_crate01");
	nx_pr_crate01.animname = "nx_pr_crate01";
	nx_pr_crate02.animname = "nx_pr_crate02";
	nx_pr_crate03.animname = "nx_pr_crate03";
	nx_pr_crate04.animname = "nx_pr_crate04";
	nx_pr_crate05.animname = "nx_pr_crate05";
	nx_pr_crate06.animname = "nx_pr_crate06";
	nx_pr_crate07.animname = "nx_pr_crate07";
	nx_pr_crate08.animname = "nx_pr_crate08";
	nx_pr_crate09.animname = "nx_pr_crate09";
	nx_pr_crate10.animname = "nx_pr_crate10";
	nx_pr_crate11.animname = "nx_pr_crate11";
	nx_pr_crate12.animname = "nx_pr_crate12";
	nx_pr_crate13.animname = "nx_pr_crate13";
	nx_pr_crate14.animname = "nx_pr_crate14";
	nx_pr_crate15.animname = "nx_pr_crate15";
	

	stuff = [];
	stuff[1] = swivelchair2;
	stuff[2] = swivelchair3;
	stuff[3] = helmetec1;
	stuff[4] = helmetec2;
	stuff[5] = helmetec3;
	stuff[6] = ammo01;
	stuff[7] = ammo02;
	stuff[8] = ammo03;
	stuff[9] = ammo04;
	stuff[10] = ammo05;
	stuff[11] = ammo06;
	stuff[12] = ammo07;
	stuff[13] = ammo08;
	stuff[14] = ammo09;
	stuff[15] = ammo10;
	stuff[16] = nx_pr_crate01;
	stuff[17] = nx_pr_crate02;
	stuff[18] = nx_pr_crate03;
	stuff[19] = nx_pr_crate04;
	stuff[20] = nx_pr_crate05;
	stuff[21] = nx_pr_crate06;
	stuff[22] = nx_pr_crate07;
	stuff[23] = nx_pr_crate08;
	stuff[24] = nx_pr_crate09;
	stuff[25] = nx_pr_crate10;
	stuff[26] = nx_pr_crate11;
	stuff[27] = nx_pr_crate12;
	stuff[28] = nx_pr_crate13;
	stuff[29] = nx_pr_crate14;
	stuff[30] = nx_pr_crate15;

	//first frame to get them into position
	explosion_node = getent("explosion_node", "script_noteworthy");
	explosion_node anim_first_frame( stuff, "end_breach_explosion" ); 

	//Wait for the explosion
	level waittill( "breach_explosion" );

	//The first chair is a special case since it is first spawned in the enemy scene
	swivelchair1 = spawn_anim_model("swivelchair");
	swivelchair1.animname = "swivelchair1";
	stuff[0] = swivelchair1;

	//Play the anims
	explosion_node anim_single( stuff, "end_breach_explosion" );
}