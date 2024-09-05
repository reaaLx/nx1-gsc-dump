//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Anim Support													**
//                                                                          **
//    Created: 11/11/11 - Travis Chen (trchen x 4143)						**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_nx_vignette_util;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main()
{
	player_anims();
	generic_human();
	script_models();
	vehicle_anims();
	level thread vignettes();
	dialogue();
	
	// Thread vignettes
	level thread vignette_streetlight();
	level thread vignette_curtain_pull();
	//level thread vignette_register();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_flag_inits()
{
	flag_init( "streets_rooftop_rpg_1" );
	flag_init( "vignette_barhop" );
	flag_init( "vignette_razorwire_pullout" );
	flag_init( "vignette_razorwire_pullback" );	
	flag_init( "vignette_streetlight_fall" );
}

vignettes()
{
    //level thread vignette_register( ::bar_hop_spawn, "vignette_barhop" );
	//level thread vignette_register( ::razorwire_pullout_spawn, "vignette_razorwire_pullout" );
	//level thread vignette_register( ::razorwire_pullback_spawn, "vignette_razorwire_pullback" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "player" );
player_anims()
{
	// Player rig
	level._scr_animtree[ "player_rig" ] = #animtree;
	level._scr_model[ "player_rig" ] = "viewhands_player_us_army";

	// Intro convoy ride anim
	level._scr_anim[ "player_rig" ][ "intro_ride" ] = %nx_fp_border_intro_player;																								
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree("generic_human");
generic_human() 
{
	// Intro convoy ride anims
	level._scr_anim[ "driver" ][ "intro_ride" ] = %nx_tp_border_intro_driver;
	level._scr_anim[ "driver" ][ "idle" ][0] = %humvee_idle_frontL;
	level._scr_anim[ "passengerfront" ][ "intro_ride" ] = %nx_tp_border_intro_passengerfront;
	addNotetrack_customFunction( "passengerfront", "intro_ride", ::border_intro_player_loses_control);
	level._scr_anim[ "passengerrear" ][ "intro_ride" ] = %nx_tp_border_intro_passengerrear;
	level._scr_anim[ "player_legs" ][ "intro_ride" ] = %nx_tp_border_intro_playerlegs;
								  
	// opening walk
	level._scr_anim[ "generic" ][ "curtain_pull" ] = %favela_curtain_pull;

	// bar hop
	level._scr_anim[ "generic" ][ "bar_hop" ] = %nx_tp_border_barhop_opfor;
	//addNotetrack_customFunction( "generic", "immortal", ::immortal, "bar_hop" );
	//addNotetrack_customFunction( "generic", "mortal", ::mortal, "bar_hop" );


	// Razorwire Pullout/Pushback
	level._scr_anim[ "enemy_pullout_wire" ][ "razorwire_pullout" ] = %nx_tp_border_wire_pullout;
	level._scr_anim[ "ally_pullback_wire" ][ "razorwire_pullback" ] = %nx_tp_border_wire_pullback;

}

dialogue()
{
	level._scr_radio[ "bor_ancr_intro_warning" ] = "bor_ancr_intro_warning";
	level._scr_radio[ "bor_chf_intro_proceed" ] = "bor_chf_intro_proceed";
	level._scr_radio[ "bor_bak_intro_mightgethairy" ] = "bor_bak_intro_mightgethairy";
	level._scr_radio[ "bor_hum_intro_hooah" ] = "bor_hum_intro_hooah";
	level._scr_radio[ "bor_gon_intro_hooah" ] = "bor_gon_intro_hooah";
	level._scr_radio[ "bor_chf_intro_incoming" ] = "bor_chf_intro_incoming";
	level._scr_radio[ "bor_hum_intro_everyonegood" ] = "bor_hum_intro_everyonegood";
	level._scr_radio[ "bor_hum_intro_everybodyok" ] = "bor_hum_intro_everybodyok";
	level._scr_radio[ "bor_hum_intro_everyoneok" ] = "bor_hum_intro_everyoneok";
	level._scr_radio[ "bor_bak_intro_exitvehicle" ] = "bor_bak_intro_exitvehicle";
	level._scr_radio[ "bor_gon_intro_grunts" ] = "bor_gon_intro_grunts";
	level._scr_radio[ "bor_hum_intro_gowithbaker" ] = "bor_hum_intro_gowithbaker";
	level._scr_radio[ "bor_hum_intro_getoutgogogo" ] = "bor_hum_intro_getoutgogogo";
	level._scr_radio[ "bor_bak_intro_cmonletsgo" ] = "bor_bak_intro_cmonletsgo";
	level._scr_radio[ "bor_hum_hit_pardonme" ] = "bor_hum_hit_pardonme";
	level._scr_radio[ "bor_bak_barricade_moveup" ] = "bor_bak_barricade_moveup";
	level._scr_radio[ "bor_bak_barricade_razorwire" ] = "bor_bak_barricade_razorwire";
	level._scr_radio[ "bor_bak_battle_olympuscomein" ] = "bor_bak_battle_olympuscomein";
	level._scr_radio[ "bor_oly_battle_sitrep" ] = "bor_oly_battle_sitrep";
	level._scr_radio[ "bor_bak_barricade_ambushed" ] = "bor_bak_barricade_ambushed";
	level._scr_radio[ "bor_oly_barricade_hawkswitheggs" ] = "bor_oly_barricade_hawkswitheggs";
	level._scr_radio[ "bor_bak_barricade_letsmove" ] = "bor_bak_barricade_letsmove";
	level._scr_radio[ "bor_eag_barricade_inairspace" ] = "bor_eag_barricade_inairspace";
	level._scr_radio[ "bor_eag_airdrop_rainhell" ] = "bor_eag_airdrop_rainhell";
	level._scr_radio[ "bor_eag_airdrop_incoming" ] = "bor_eag_airdrop_incoming";
	level._scr_radio[ "bor_eag_airdrop_supportinboundmark" ] = "bor_eag_airdrop_supportinboundmark";
	level._scr_radio[ "bor_eag_airdrop_snipersupportonway" ] = "bor_eag_airdrop_snipersupportonway";
	level._scr_radio[ "bor_eag_airdrop_returning" ] = "bor_eag_airdrop_returning";
	level._scr_radio[ "bor_bak_airdrop_throwsmoke" ] = "bor_bak_airdrop_throwsmoke";
	level._scr_radio[ "bor_bak_airdrop_markdrop" ] = "bor_bak_airdrop_markdrop";
	level._scr_radio[ "bor_eag_airdrop_dropconfirmed" ] = "bor_eag_airdrop_dropconfirmed";
	level._scr_radio[ "bor_eag_airdrop_seethesmoke" ] = "bor_eag_airdrop_seethesmoke";
	level._scr_radio[ "bor_eag_airdrop_unabletodrop" ] = "bor_eag_airdrop_unabletodrop";
	level._scr_radio[ "bor_eag_airdrop_hellfireinbound" ] = "bor_eag_airdrop_hellfireinbound";
	level._scr_radio[ "bor_eag_airdrop_eggshatched" ] = "bor_eag_airdrop_eggshatched";
	level._scr_radio[ "bor_eag_airdrop_returningtobase" ] = "bor_eag_airdrop_returningtobase";
	level._scr_radio[ "bor_eag_airdrop_resupply" ] = "bor_eag_airdrop_resupply";
	level._scr_radio[ "bor_eag_airdrop_backonline" ] = "bor_eag_airdrop_backonline";
	level._scr_radio[ "bor_bak_airdrop_throwsmokefurther" ] = "bor_bak_airdrop_throwsmokefurther";
	level._scr_radio[ "bor_eag_airdrop_helisfromsouth" ] = "bor_eag_airdrop_helisfromsouth";
	level._scr_radio[ "bor_bak_streets_rpgsgetoffstreets" ] = "bor_bak_streets_rpgsgetoffstreets";
	level._scr_radio[ "bor_bak_streets_rpgsgetcover" ] = "bor_bak_streets_rpgsgetcover";
	level._scr_radio[ "bor_bak_streets_takeouttechnical" ] = "bor_bak_streets_takeouttechnical";
	level._scr_radio[ "bor_bak_streets_enemiesonbalcony" ] = "bor_bak_streets_enemiesonbalcony";
	level._scr_radio[ "bor_bak_streets_securerestaurant" ] = "bor_bak_streets_securerestaurant";
	level._scr_radio[ "bor_bak_streets_team2backalley" ] = "bor_bak_streets_team2backalley";
	level._scr_radio[ "bor_bak_streets_enemy2ndflrwindow" ] = "bor_bak_streets_enemy2ndflrwindow";
	level._scr_radio[ "bor_bak_border_rpgs12oclock" ] = "bor_bak_border_rpgs12oclock";
	level._scr_radio[ "bor_bak_market_enemyhumvee" ] = "bor_bak_market_enemyhumvee";
	level._scr_radio[ "bor_bak_market_gettomarket" ] = "bor_bak_market_gettomarket";
	level._scr_radio[ "bor_bak_market_rpgsonwalkway" ] = "bor_bak_market_rpgsonwalkway";
	level._scr_radio[ "bor_bak_market_moveup" ] = "bor_bak_market_moveup";
	level._scr_radio[ "bor_bak_market_ontherunpushforward" ] = "bor_bak_market_ontherunpushforward";
	level._scr_radio[ "bor_bak_market_pushforward" ] = "bor_bak_market_pushforward";
	level._scr_radio[ "bor_bak_market_technicalonstreet" ] = "bor_bak_market_technicalonstreet";
	level._scr_radio[ "bor_bak_market_techtakeitout" ] = "bor_bak_market_techtakeitout";
	level._scr_radio[ "bor_bak_market_retreatingupstairs" ] = "bor_bak_market_retreatingupstairs";
	level._scr_radio[ "bor_bak_market_helideadahead" ] = "bor_bak_market_helideadahead";
	level._scr_radio[ "bor_bak_market_pickuprpg" ] = "bor_bak_market_pickuprpg";
	level._scr_radio[ "bor_bak_market_rpgordead" ] = "bor_bak_market_rpgordead";
	level._scr_radio[ "bor_bak_market_niceshot" ] = "bor_bak_market_niceshot";
	level._scr_radio[ "bor_gon_market_thoughtwewerefucked" ] = "bor_gon_market_thoughtwewerefucked";
	level._scr_radio[ "bor_bak_intro_eyesopenguys" ] = "bor_bak_intro_eyesopenguys";
	level._scr_radio[ "bor_hum_intro_getoutthere" ] = "bor_hum_intro_getoutthere";
	level._scr_radio[ "bor_hum_intro_go" ] = "bor_hum_intro_go";
	level._scr_radio[ "bor_oly_intro_cartelproceed" ] = "bor_oly_intro_cartelproceed";
	level._scr_radio[ "bor_oly_intro_cartelpushthru" ] = "bor_oly_intro_cartelpushthru";
	level._scr_radio[ "bor_bak_battle_heavyfire" ] = "bor_bak_battle_heavyfire";
	level._scr_radio[ "bor_oly_battle_hawksinbound" ] = "bor_oly_battle_hawksinbound";
	level._scr_radio[ "bor_bak_barr_heavyresistance" ] = "bor_bak_barr_heavyresistance";
	level._scr_radio[ "bor_bak_barr_thrucheckpoint" ] = "bor_bak_barr_thrucheckpoint";
	level._scr_radio[ "bor_oly_barr_proceedtochurch" ] = "bor_oly_barr_proceedtochurch";
	level._scr_radio[ "bor_oly_barr_blackhawksready" ] = "bor_oly_barr_blackhawksready";
	level._scr_radio[ "bor_bak_streets_veh12marktarget" ] = "bor_bak_streets_veh12marktarget";
	level._scr_radio[ "bor_bak_streets_vehupstreet" ] = "bor_bak_streets_vehupstreet";
	level._scr_radio[ "bor_bak_streets_veh12markhotzone" ] = "bor_bak_streets_veh12markhotzone";
	level._scr_radio[ "bor_bak_streets_veh12markit" ] = "bor_bak_streets_veh12markit";
	level._scr_radio[ "bor_bak_streets_team1takestreet" ] = "bor_bak_streets_team1takestreet";
	level._scr_radio[ "bor_bak_streets_clearbldng" ] = "bor_bak_streets_clearbldng";
	level._scr_radio[ "bor_bak_streets_churchendofstreet" ] = "bor_bak_streets_churchendofstreet";
	level._scr_radio[ "bor_bak_streets_blckdheadtomarket" ] = "bor_bak_streets_blckdheadtomarket";
	level._scr_radio[ "bor_bak_streets_blckdcutthrumarket" ] = "bor_bak_streets_blckdcutthrumarket";
	level._scr_radio[ "bor_bak_streets_getdooropen" ] = "bor_bak_streets_getdooropen";
	level._scr_radio[ "bor_bak_streets_cutthrumarket" ] = "bor_bak_streets_cutthrumarket";
	level._scr_radio[ "bor_bak_streets_reroutingmarket" ] = "bor_bak_streets_reroutingmarket";
	level._scr_radio[ "bor_oly_streets_rogerthat" ] = "bor_oly_streets_rogerthat";
	level._scr_radio[ "bor_bak_market_enemiesinmarket" ] = "bor_bak_market_enemiesinmarket";
	level._scr_radio[ "bor_oly_market_cartelleaving" ] = "bor_oly_market_cartelleaving";
	level._scr_radio[ "bor_oly_market_cartelmovingnewloc" ] = "bor_oly_market_cartelmovingnewloc";
	level._scr_radio[ "bor_oly_market_cartelchopper" ] = "bor_oly_market_cartelchopper";
	level._scr_radio[ "bor_bak_market_1mikeout" ] = "bor_bak_market_1mikeout";
	level._scr_radio[ "bor_bak_market_smokeonchopper" ] = "bor_bak_market_smokeonchopper";
	level._scr_radio[ "bor_bak_market_getsmokeonem" ] = "bor_bak_market_getsmokeonem";
	level._scr_radio[ "bor_bak_market_callinsupport" ] = "bor_bak_market_callinsupport";
	level._scr_radio[ "bor_bak_market_takingoffmarkem" ] = "bor_bak_market_takingoffmarkem";
	level._scr_radio[ "bor_bak_market_markthetargets" ] = "bor_bak_market_markthetargets";
	level._scr_radio[ "bor_bak_market_idthetargets" ] = "bor_bak_market_idthetargets";
	level._scr_radio[ "bor_bak_market_putsmokeonthetarget" ] = "bor_bak_market_putsmokeonthetarget";
	level._scr_radio[ "bor_bak_market_getsmokeontargets" ] = "bor_bak_market_getsmokeontargets";
	level._scr_radio[ "bor_oly_market_heatsignatures" ] = "bor_oly_market_heatsignatures";
	level._scr_radio[ "bor_bak_market_notdoneyet" ] = "bor_bak_market_notdoneyet";
	level._scr_radio[ "bor_bak_market_letsgo" ] = "bor_bak_market_letsgo";
	level._scr_radio[ "bor_eag_airdrop_targetseliminated" ] = "bor_eag_airdrop_targetseliminated";
	level._scr_radio[ "bor_eag_market_helibackonline" ] = "bor_eag_market_helibackonline";
	level._scr_radio[ "bor_eag_market_airsupportonline" ] = "bor_eag_market_airsupportonline";
	level._scr_radio[ "bor_eag_market_readyfortasking" ] = "bor_eag_market_readyfortasking";
	level._scr_radio[ "bor_eag_market_inbound" ] = "bor_eag_market_inbound";
	level._scr_radio[ "bor_eag_market_readyfortargets" ] = "bor_eag_market_readyfortargets";
	level._scr_radio[ "bor_eag_market_weaponsfree" ] = "bor_eag_market_weaponsfree";
	level._scr_radio[ "bor_eag_market_engaging" ] = "bor_eag_market_engaging";
	level._scr_radio[ "bor_eag_market_roundsondeck" ] = "bor_eag_market_roundsondeck";
	level._scr_radio[ "bor_eag_market_goinghot" ] = "bor_eag_market_goinghot";
	level._scr_radio[ "bor_eag_market_rtbonyourown" ] = "bor_eag_market_rtbonyourown";
	level._scr_radio[ "bor_eag_market_bingofuelrtb" ] = "bor_eag_market_bingofuelrtb";
	
	//locational panned dialog, not radio'ed
	level._scr_sound[ "passengerfront" ][ "bor_bak_border_rpgs12oclock" ] = "bor_bak_border_rpgs12oclock";
	level._scr_sound[ "passengerfront" ][ "bor_bak_battle_olympuscomein" ] = "bor_bak_battle_olympuscomein";
	level._scr_sound[ "passengerfront" ][ "bor_bak_battle_heavyfire" ] = "bor_bak_battle_heavyfire";
	level._scr_sound[ "passengerfront" ][ "bor_bak_barricade_moveup" ] = "bor_bak_barricade_moveup";
	level._scr_sound[ "passengerfront" ][ "bor_bak_streets_veh12markit" ] = "bor_bak_streets_veh12markit";
	level._scr_sound[ "passengerfront" ][ "bor_bak_streets_goleftintersection" ] = "bor_bak_streets_goleftintersection";
	level._scr_sound[ "passengerfront" ][ "bor_bak_streets_team1takestreet" ] = "bor_bak_streets_team1takestreet";
	level._scr_sound[ "passengerfront" ][ "bor_bak_streets_team2backalley" ] = "bor_bak_streets_team2backalley";
	level._scr_sound[ "passengerfront" ][ "bor_bak_market_enemyhumvee" ] = "bor_bak_market_enemyhumvee";
	level._scr_sound[ "passengerfront" ][ "bor_bak_streets_enemy2ndflrwindow" ] = "bor_bak_streets_enemy2ndflrwindow";
	level._scr_sound[ "passengerfront" ][ "bor_bak_streets_clearbldng" ] = "bor_bak_streets_clearbldng";
	level._scr_sound[ "passengerfront" ][ "bor_bak_streets_churchendofstreet" ] = "bor_bak_streets_churchendofstreet";
	level._scr_sound[ "passengerfront" ][ "bor_bak_streets_reroutingmarket" ] = "bor_bak_streets_reroutingmarket";	
	level._scr_sound[ "passengerfront" ][ "bor_bak_streets_rpgsgetcover" ] = "bor_bak_streets_rpgsgetcover";	
	level._scr_sound[ "passengerfront" ][ "bor_bak_nag_market" ] = "bor_bak_nag_market";
	level._scr_sound[ "passengerfront" ][ "bor_bak_market_enemiesinmarket" ] = "bor_bak_market_enemiesinmarket";
	level._scr_sound[ "passengerfront" ][ "bor_bak_market_moveup" ] = "bor_bak_market_moveup";
	level._scr_sound[ "passengerfront" ][ "bor_bak_market_rpgsonwalkway" ] = "bor_bak_market_rpgsonwalkway";
	level._scr_sound[ "passengerfront" ][ "bor_bak_market_pushforward" ] = "bor_bak_market_pushforward";
	level._scr_sound[ "passengerfront" ][ "bor_bak_market_retreatingupstairs" ] = "bor_bak_market_retreatingupstairs";
	level._scr_sound[ "passengerfront" ][ "bor_bak_market_ontherunpushforward" ] = "bor_bak_market_ontherunpushforward";	
	level._scr_sound[ "passengerfront" ][ "bor_bak_church_carteldiggingin3" ] = "bor_bak_church_carteldiggingin3";	
	level._scr_sound[ "passengerfront" ][ "bor_bak_market_letsgo" ] = "bor_bak_market_letsgo";	
	level._scr_sound[ "passengerfront" ][ "bor_bak_nag_pushchurch" ] = "bor_bak_nag_pushchurch";	


	

	

	


	//NEW VO DROP 12.14.11
	level._scr_radio[ "bor_bak_streets_routingleft" ] = "bor_bak_streets_routingleft";
	level._scr_radio[ "bor_bak_streets_goleft" ] = "bor_bak_streets_goleft";
	level._scr_radio[ "bor_bak_streets_goleftintersection" ] = "bor_bak_streets_goleftintersection";
	level._scr_radio[ "bor_bak_streets_streetsoralley" ] = "bor_bak_streets_streetsoralley";
	level._scr_radio[ "bor_bak_streets_followorgoteam2" ] = "bor_bak_streets_followorgoteam2";
	level._scr_radio[ "bor_bak_streets_followorgoteam1" ] = "bor_bak_streets_followorgoteam1";
	level._scr_radio[ "bor_bak_streets_followme" ] = "bor_bak_streets_followme";
	level._scr_radio[ "bor_bak_streets_onme" ] = "bor_bak_streets_onme";
	level._scr_radio[ "bor_bak_church_carteldiggingin1" ] = "bor_bak_church_carteldiggingin1";
	level._scr_radio[ "bor_bak_church_findcovermarktangos" ] = "bor_bak_church_findcovermarktangos";
	level._scr_radio[ "bor_bak_church_carteldiggingin2" ] = "bor_bak_church_carteldiggingin2";
	level._scr_radio[ "bor_bak_church_carteldiggingin3" ] = "bor_bak_church_carteldiggingin3";
	level._scr_radio[ "bor_bak_church_contact" ] = "bor_bak_church_contact";
	level._scr_radio[ "bor_bak_intro_targetsholedup" ] = "bor_bak_intro_targetsholedup";
	level._scr_radio[ "bor_bak_intro_targetsatchurch" ] = "bor_bak_intro_targetsatchurch";

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "script_model" );
script_models()
{
	// Intro Hummer
	level._scr_animtree[ "player_humvee" ] = #animtree;
	level._scr_model[ "player_humvee" ] = "nx_vehicle_border_hummer2";	
	level._scr_anim[ "player_humvee" ][ "intro_ride" ] = %nx_vh_border_intro_humvee;
	// Attack point
	addNotetrack_customFunction( "player_humvee", "loose_control", ::border_intro_player_loses_control);
	addNotetrack_customFunction( "player_humvee", "hummer_explosion", ::border_intro_hummer_explosion);

	level._scr_animtree[ "curtain" ] = #animtree;
	level._scr_anim[ "curtain" ][ "curtain_pull" ] = %favela_curtain_model_pull;
	level._scr_model[ "curtain" ] = "curtain_torn01_animated";

	level._scr_animtree[ "streetlight" ] = #animtree;
	level._scr_anim[ "streetlight" ][ "streetlight_fall" ] = %nx_pr_border_streetlight_fall;
	level._scr_model[ "streetlight" ] = "nx_border_streetlight";	
	
	//Razorwire anims
	level._scr_animtree[ "razorwire_pullback" ] = #animtree;
	level._scr_anim[ "razorwire_pullback" ][ "razorwire_pullback" ] = %nx_pr_border_wire_pullback;
	level._scr_model[ "razorwire_pullback" ] = "mil_razorwire_long";

	level._scr_animtree[ "razorwire_pullback_02" ] = #animtree;
	level._scr_anim[ "razorwire_pullback_02" ][ "razorwire_pullback" ] = %nx_pr_border_wire02_pullback;
	level._scr_model[ "razorwire_pullback_02" ] = "mil_razorwire_long";

	level._scr_animtree[ "razorwire_pullout" ] = #animtree;
	level._scr_anim[ "razorwire_pullout" ][ "razorwire_pullout" ] = %nx_pr_border_wire_pullout;
	level._scr_model[ "razorwire_pullout" ] = "mil_razorwire_long";

	level._scr_animtree[ "razorwire_pullout_02" ] = #animtree;
	level._scr_anim[ "razorwire_pullout_02" ][ "razorwire_pullout" ] = %nx_pr_border_wire02_pullout;
	level._scr_model[ "razorwire_pullout_02" ] = "mil_razorwire_long";
	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "vehicles" );
vehicle_anims()
{
	level._scr_animtree[ "humvee" ] = #animtree;	
	level._scr_anim[ "humvee" ][ "frontL_door" ] = %humvee_mount_frontL_door;
	level._scr_anim[ "humvee" ][ "frontR_door" ] = %humvee_mount_frontR_door;
	level._scr_anim[ "humvee" ][ "backL_door" ] = %humvee_mount_backL_door;
	level._scr_anim[ "humvee" ][ "backR_door" ] = %humvee_mount_backR_door;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_streetlight()
{
	node = getstruct( "vignette_streetlight", "targetname" );

	streetlight = spawn_anim_model( "streetlight" );

	guys = [];
	guys["streetlight"] = streetlight;

	node anim_first_frame( guys, "streetlight_fall" );
	
	impact_origin = node.origin + (0, 0, 200);
	
	//level thread vignette_streetlight_start();
	level thread vignette_streetlight_start_alt();
	flag_wait( "vignette_streetlight_fall" );

	node thread maps\nx_border_fx::fx_street_light_explosion();
	streetlight playsound("scn_border_stoplight_destruction");
	node anim_single( guys, "streetlight_fall" );
}

vignette_streetlight_start()
{
	flag_wait( "player_through_intro_funnel" );
	flag_set( "vignette_streetlight_fall" );
}

vignette_streetlight_start_alt()
{
	flag_wait( "player_used_helicopter_support" );
	wait( 2.0 );
	flag_set( "vignette_streetlight_fall" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_curtain_pull()
{
	node = getstruct( "vignette_curtain_pull", "targetname" );

	curtain = spawn_anim_model( "curtain" );

	guys = [];
	guys["curtain"] = curtain;

	node anim_first_frame( guys, "curtain_pull" );
	
	flag_wait( "vignette_curtain_pull" );
	
	spawner = GetEnt( "vignette_curtain_pull_enemy", "targetname" );
	opfor = spawner spawn_ai();
	opfor.animname = "generic";
	opfor.goalradius = 32;
	opfor.allowdeath = true;
	opfor.health = 5;

	guys["generic"] = opfor;
	
	node thread anim_single(guys, "curtain_pull");
	
	wait( 2.0 );
	
	allies = GetAIArray( "allies" );
	foreach( i, ally in allies )
	{
		if( IsDefined( ally.script_forcecolor ) && ally.script_forcecolor == "r" )
		{
			ally.favoriteenemy = opfor;
		}
	}
	
	opfor vignette_curtain_pull_death_thread();
	opfor waittill( "death" );

	foreach( ally in level.street_red_allies )
	{
		ally.favoriteenemy = undefined;
	}	
}

vignette_curtain_pull_death_thread()
{
	self endon( "death" );
	flag_wait( "vignette_curtain_pull_cleanup" );
	self Kill();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


bar_hop_spawn()
{
	vignette_barhop = vignette_actor_spawn("vignette_barhop", "vignette_barhop"); //"value" (kvp), "anim_name"

	bar_hop(vignette_barhop);

	vignette_barhop vignette_actor_delete();
}

bar_hop( vignette_barhop_enemy )
{
	node = getstruct("vignette_barhop", "script_noteworthy");

	guys = [];
	guys["vignette_barhop"] = vignette_barhop_enemy;

	//vignette_barhop_enemy magic_bullet_shield();

	vignette_barhop_enemy.allowdeath = true;
	vignette_barhop_enemy clear_deathanim();

	
	node thread anim_single(guys, "bar_hop");
	
	flag_wait( "vignette_barhop_cleanup" );
	
	if( IsAlive( vignette_barhop_enemy ) )
	{
		if( IsDefined( vignette_barhop_enemy.magic_bullet_shield ) )
		{
			vignette_barhop_enemy stop_magic_bullet_shield();
		}
		vignette_barhop_enemy Kill();
	}
}
/*
immortal( guy )
{
	guy magic_bullet_shield();
}

mortal( guy )
{
	guy stop_magic_bullet_shield();
}
*/

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

border_intro_player_loses_control( guy )
{
	level notify( "notify_border_intro_player_loses_control" );
}

border_intro_hummer_explosion( guy )
{
	level notify( "notify_border_intro_hummer_explosion" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
razorwire_pullout_spawn()
{
	enemy_pullout_wire = vignette_actor_spawn("vignette_razorwire_enemy", "enemy_pullout_wire"); //"value" (kvp), "anim_name"

	razorwire_pullout(enemy_pullout_wire);

	enemy_pullout_wire vignette_actor_delete();
}

razorwire_pullout(enemy_pullout_wire)
{

	node = getstruct("vignette_razorwire", "script_noteworthy");

	razorwire_pullout = spawn_anim_model("razorwire_pullout");
	razorwire_pullout_02 = spawn_anim_model("razorwire_pullout_02");

	guys = [];
	guys["enemy_pullout_wire"] = enemy_pullout_wire;
	guys["razorwire_pullout"] = razorwire_pullout;
	guys["razorwire_pullout_02"] = razorwire_pullout_02;

	node anim_single(guys, "razorwire_pullout");
	razorwire_pullout delete();
	razorwire_pullout_02 delete();

}
razorwire_pullback_spawn()
{
	ally_pullback_wire = vignette_actor_spawn("vignette_razorwire_ally", "ally_pullback_wire"); //"value" (kvp), "anim_name"

	razorwire_pullback(ally_pullback_wire);

	ally_pullback_wire vignette_actor_delete();
}

razorwire_pullback(ally_pullback_wire)
{

	node = getstruct("vignette_razorwire", "script_noteworthy");

	razorwire_pullback = spawn_anim_model("razorwire_pullback");
	razorwire_pullback_02 = spawn_anim_model("razorwire_pullback_02");

	guys = [];
	guys["ally_pullback_wire"] = ally_pullback_wire;
	guys["razorwire_pullback"] = razorwire_pullback;
	guys["razorwire_pullback_02"] = razorwire_pullback_02;

	node anim_single(guys, "razorwire_pullback");
	razorwire_pullback delete();
	razorwire_pullback_02 delete();

}

