//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  MISSION DESCRIPTION											**
//                                                                          **
//    Created: 7/15/2011 - Ken Moodie										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_utility_code;
#include maps\_nx_objective_util;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_nx_utility;
#include maps\nx_skyscraper_util;


//*******************************************************************
// VAULT                                                            *
//                                                                  *
//*******************************************************************

vault_start()
{
	level._player maps\_nx_utility::move_player_to_start_point( "playerstart_vault" );
	thread maps\nx_skyscraper_fx::set_vision_and_fog("interior", 0); // set appropriate vision and fog
	maps\nx_skyscraper_util::player_weapon_init( false );
	level._player SwitchToWeapon( "lancer_silencer_xray" );

	thread maps\_utility::set_ambient( "amb_skyscraper_robotics_int" );

	maps\nx_skyscraper_util::spawn_baker();
	baker_teleport = GetEnt ("baker_vault_teleport", "targetname");
	level.baker ForceTeleport( baker_teleport.origin, baker_teleport.angles);
	issue_color_orders ("r50", "allies");

	// vault_sequence();
}

vault_sequence()
{
	//level.baker waittill ("goal");
	
	trigger_wait_targetname( "entering_vault" );

	vault_dialog();
	macguffin_init();
	level.baker disable_cqbwalk();
}

vault_dialog()
{
	// Dialogue: Team A - "Baker, do you see the objective?" 
	radio_dialogue( "sky_teama_vault_objective" );
	//add_dialogue_line( "Team A", "Baker, do you see the objective?", "purple", 2 );

	// Dialogue: Baker - "That's affirmative.  You wouldn't believe what they're up to"
	level.baker dialogue_queue( "sky_bak_vault_affirmative" );
	//add_dialogue_line( "Baker", "That's affirmative. You wouldn't believe what they're up to.", "green", 2 );

	// Dialogue: Team A - "Get in and get out ASAP.  You've got multiple hostiles inbound 
	radio_dialogue( "sky_teama_vault_hostilesinbound" );
	//add_dialogue_line( "Team A", "Get it and get out ASAP. You've got multiple hostiles inbound.", "purple", 3 );

	// Dialogue: Baker - "Copy that.  Spectre, grab that thing.
	level.baker dialogue_queue( "sky_bak_vault_grabthatthing" );
	//thread add_dialogue_line( "Baker", "Copy that. Spectre, grab that thing.", "green", 2 );
}

macguffin_init()
{
	macguffin = GetEnt( "macguffin", "targetname" );
	level.baker waittill ("goal");
	use_trigger =  GetEnt( "use_vault_console", "targetname" );
	use_trigger SetHintString ( "Press X to obtain Macguffin" );
	use_trigger waittill ( "trigger" );
	level notify ("macguffin_obtained");
	macguffin delete();
	use_trigger delete();
}
