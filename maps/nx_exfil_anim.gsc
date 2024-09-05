//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Skyscraper Exfil Anims										**
//                                                                          **
//    Created: 11/10/2011 - John Webb										**
//                                                                          **
//****************************************************************************
#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_nx_vignette_util;

main()
{
	vehicles();
	generic_human();
	player_anims();
	script_models();
	level thread vignettes();
	dialogue();

	// For the scripter:
	// move this call wherever you feel it's appropriate
	//Example: script_model_first_frame( node_name, model_name, anim_name );
	//script_model_first_frame("vignette_fast_ropes", "fast_ropes_door_model", "exfil_fast_ropes");
	script_model_first_frame("vignette_laundry_door", "laundry_door", "laundry_door");
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
flag_inits()
{
	flag_init( "vignette_police_cars1_flag" );
	flag_init( "vignette_alley_cook_grenade" );
	flag_init( "flag_exfil_intro_temp" );
	flag_init( "flag_exfil_intro_player_door" );
	flag_init( "radio_exfil_begin" );
	flag_init( "flag_exfil_outro_door_kick" );
	//flag_init( "melee_rail_01_flag" );
	//flag_init( "melee_rail_02_flag" );
	//rail01 melee flags
	flag_init( "rail01_baker_kill_done" );
	flag_init( "rail01_baker_kill_abort" );
	flag_init( "rail01_baker_kill_started" );
	flag_init( "rail01_baker_kill_committed" );
	flag_init( "rail01_baker_kill_walkup_abort" );
	flag_init( "vignette_light_swing" );
	flag_init( "trigger_civ" );

	flag_init( "rail02_baker_kill_done" );
	flag_init( "rail02_baker_kill_abort" );
	flag_init( "rail02_baker_kill_started" );
	flag_init( "rail02_baker_kill_committed" );
	flag_init( "rail02_baker_kill_walkup_abort" );

	flag_init( "soda_machine_01_opfor_flag" );
	flag_init( "final_objective" );

	flag_init( "hallway_start_walk" );
	flag_init( "hallway_cleanup" );

}
vignettes()
{
	level thread vignette_register( ::esfil_police_cars_01_spawn, "exit_ambulance" );
	level thread vignette_register( ::exfil_intro_spawn, "flag_exfil_intro_temp" );
	//level thread vignette_register( ::exfil_fast_ropes_spawn, "vignette_fast_ropes_flag" );
	level thread vignette_register( ::exfil_intro_player_door_spawn, "flag_exfil_intro_player_door" );
	//level thread vignette_register( ::outro_door_kick_spawn, "flag_exfil_outro_door_kick" );
	level thread vignette_register( ::exfil_alley_cook_grenade, "vignette_alley_cook_grenade" );
	//level thread vignette_register( ::light_swing_spawn, "vignette_light_swing" );
	//level thread vignette_register( ::civ_run_away_spawn, "trigger_civ" );
	//level thread vignette_register( ::rail_01_spawn, "melee_rail_01_flag" );
	//level thread vignette_register( ::ral_02_spawn, "melee_rail_02_flag" );
	level thread vignette_register( ::exfil_soda_machine_spawn, "soda_machine_01_opfor_flag" );
	
	// not a vignette, but this needs to be threaded off and will be activated just the same way
	level thread activate_final_objective();
}

dialogue()
{
	level._scr_radio[ "exf_bak_van_youok" ] = "exf_bak_van_youok";
	level._scr_radio[ "exf_bak_van_highonlist" ] = "exf_bak_van_highonlist";
	level._scr_radio[ "exf_bak_van_missthis" ] = "exf_bak_van_missthis";
	level._scr_radio[ "exf_bak_van_gottago" ] = "exf_bak_van_gottago";
	level._scr_radio[ "exf_bak_intro_letsgetoutofhere" ] = "exf_bak_intro_letsgetoutofhere";
	level._scr_radio[ "exf_bak_van_needexfil" ] = "exf_bak_van_needexfil";
	level._scr_radio[ "exf_bak_van_solidcopy" ] = "exf_bak_van_solidcopy";
	level._scr_radio[ "exf_bak_van_getaway" ] = "exf_bak_van_getaway";
	level._scr_radio[ "exf_bak_van_easyday" ] = "exf_bak_van_easyday";
	level._scr_radio[ "exf_bak_van_grabkit" ] = "exf_bak_van_grabkit";
	level._scr_radio[ "exf_bak_van_travelinglight" ] = "exf_bak_van_travelinglight";
	level._scr_radio[ "exf_bak_van_ammolight" ] = "exf_bak_van_ammolight";
	level._scr_radio[ "exf_bak_van_grabcover" ] = "exf_bak_van_grabcover";
	level._scr_radio[ "exf_bak_van_roewideopen" ] = "exf_bak_van_roewideopen";
	level._scr_radio[ "exf_ovl_cops_roewideopen" ] = "exf_ovl_cops_roewideopen";
	level._scr_radio[ "exf_bak_van_takecover" ] = "exf_bak_van_takecover";
	level._scr_radio[ "exf_bak_swat_swat" ] = "exf_bak_swat_swat";
	level._scr_radio[ "exf_bak_swat_swatpunks" ] = "exf_bak_swat_swatpunks";
	level._scr_radio[ "exf_bak_swat_swatshere" ] = "exf_bak_swat_swatshere";
	level._scr_radio[ "exf_bak_swat_lightemup" ] = "exf_bak_swat_lightemup";
	level._scr_radio[ "exf_bak_helo_onscene" ] = "exf_bak_helo_onscene";
	level._scr_radio[ "exf_bak_helo_eyeinsky" ] = "exf_bak_helo_eyeinsky";
	level._scr_radio[ "exf_bak_helo_eyesuphigh" ] = "exf_bak_helo_eyesuphigh";
	level._scr_radio[ "exf_bak_helo_watchit" ] = "exf_bak_helo_watchit";
	level._scr_radio[ "exf_bak_helo_pinneddown" ] = "exf_bak_helo_pinneddown";
	level._scr_radio[ "exf_bak_helo_stayawayspotlight" ] = "exf_bak_helo_stayawayspotlight";
	level._scr_radio[ "exf_bak_helo_spotlightpinyou" ] = "exf_bak_helo_spotlightpinyou";
	level._scr_radio[ "exf_bak_helo_outofsight" ] = "exf_bak_helo_outofsight";
	level._scr_radio[ "exf_bak_helo_gotabead" ] = "exf_bak_helo_gotabead";
	level._scr_radio[ "exf_bak_helo_stayoutoflight" ] = "exf_bak_helo_stayoutoflight";
	level._scr_radio[ "exf_bak_helo_avoidlight" ] = "exf_bak_helo_avoidlight";
	level._scr_radio[ "exf_bak_helo_outtathere" ] = "exf_bak_helo_outtathere";
	level._scr_radio[ "exf_bak_apc_heavygun" ] = "exf_bak_apc_heavygun";
	level._scr_radio[ "exf_bak_apc_takeoutturret" ] = "exf_bak_apc_takeoutturret";
	level._scr_radio[ "exf_bak_apc_gunsonthat" ] = "exf_bak_apc_gunsonthat";
	level._scr_radio[ "exf_bak_apc_knockturret" ] = "exf_bak_apc_knockturret";
	level._scr_radio[ "exf_bak_apc_apctearing" ] = "exf_bak_apc_apctearing";
	level._scr_radio[ "exf_bak_riot_arentgoing" ] = "exf_bak_riot_arentgoing";
	level._scr_radio[ "exf_bak_riot_usingshields" ] = "exf_bak_riot_usingshields";
	level._scr_radio[ "exf_bak_riot_onme" ] = "exf_bak_riot_onme";
	level._scr_radio[ "exf_bak_riot_fucked" ] = "exf_bak_riot_fucked";
	level._scr_radio[ "exf_bak_riot_throwfrag" ] = "exf_bak_riot_throwfrag";
	level._scr_radio[ "exf_bak_alley_moreofem" ] = "exf_bak_alley_moreofem";
	level._scr_radio[ "exf_bak_alley_dropem" ] = "exf_bak_alley_dropem";
	level._scr_radio[ "exf_bak_laundry_inhere" ] = "exf_bak_laundry_inhere";
	level._scr_radio[ "exf_bak_laundry_followme" ] = "exf_bak_laundry_followme";
	level._scr_radio[ "exf_bak_laundry_quiet" ] = "exf_bak_laundry_quiet";
	level._scr_radio[ "exf_bak_laundry_cmon" ] = "exf_bak_laundry_cmon";
	level._scr_radio[ "exf_bak_laundry_fuckers" ] = "exf_bak_laundry_fuckers";
	level._scr_radio[ "exf_bak_laundry_keeplow" ] = "exf_bak_laundry_keeplow";
	level._scr_radio[ "exf_bak_outro_letsdothis" ] = "exf_bak_outro_letsdothis";
	level._scr_radio[ "exf_bak_outro_fuckem" ] = "exf_bak_outro_fuckem";
	level._scr_radio[ "exf_bak_pu_birdsinbound" ] = "exf_bak_pu_birdsinbound";
	level._scr_radio[ "exf_bak_pu_exfilinbound" ] = "exf_bak_pu_exfilinbound";
	level._scr_radio[ "exf_bak_pu_gottogo" ] = "exf_bak_pu_gottogo";
	level._scr_radio[ "exf_bak_pu_letsdothis" ] = "exf_bak_pu_letsdothis";
	level._scr_radio[ "exf_bak_pu_letsmove" ] = "exf_bak_pu_letsmove";
	level._scr_radio[ "exf_bak_pu_pushtopz" ] = "exf_bak_pu_pushtopz";
	level._scr_radio[ "exf_bad_intro_happened" ] = "exf_bad_intro_happened";
	level._scr_radio[ "exf_bad_intro_getout" ] = "exf_bad_intro_getout";
	level._scr_radio[ "exf_cop_alley_freeze" ] = "exf_cop_alley_freeze";
	level._scr_radio[ "exf_cop_alley_dropweapons" ] = "exf_cop_alley_dropweapons";
	level._scr_radio[ "exf_cop_alley_getdownground" ] = "exf_cop_alley_getdownground";
	level._scr_radio[ "exf_cop_alley_groundnow" ] = "exf_cop_alley_groundnow";
	level._scr_radio[ "exf_cop_alley_onknees" ] = "exf_cop_alley_onknees";
	level._scr_radio[ "exf_cop_alley_getdown" ] = "exf_cop_alley_getdown";
	level._scr_radio[ "exf_cop_alley_dontmove" ] = "exf_cop_alley_dontmove";
	level._scr_radio[ "exf_cop_alley_allunits" ] = "exf_cop_alley_allunits";
	level._scr_radio[ "exf_cop_alley_armedsuspects" ] = "exf_cop_alley_armedsuspects";
	level._scr_radio[ "exf_cop_alley_swatinbound" ] = "exf_cop_alley_swatinbound";
	level._scr_radio[ "exf_cop_alley_suspectsarmed" ] = "exf_cop_alley_suspectsarmed";
	level._scr_radio[ "exf_cop_alley_openfire" ] = "exf_cop_alley_openfire";
	level._scr_radio[ "exf_helo_spotted_surrender" ] = "exf_helo_spotted_surrender";
	level._scr_radio[ "exf_helo_spotted_noescape" ] = "exf_helo_spotted_noescape";
	level._scr_radio[ "exf_helo_spotted_downground" ] = "exf_helo_spotted_downground";
	level._scr_radio[ "exf_helo_spotted_dropweapons" ] = "exf_helo_spotted_dropweapons";
	level._scr_radio[ "exf_helo_spotted_righthere" ] = "exf_helo_spotted_righthere";
	level._scr_radio[ "exf_helo_spotted_hereheis" ] = "exf_helo_spotted_hereheis";
	level._scr_radio[ "exf_cop_barri_surrender" ] = "exf_cop_barri_surrender";
	level._scr_radio[ "exf_cop_barri_shootyou" ] = "exf_cop_barri_shootyou";
	level._scr_radio[ "exf_cop_barri_dropweapon" ] = "exf_cop_barri_dropweapon";
	level._scr_radio[ "exf_ovl_van_zulubird" ] = "exf_ovl_van_zulubird";
	level._scr_radio[ "exf_bak_intro_requestingexfil" ] = "exf_bak_intro_requestingexfil";
	level._scr_radio[ "exf_bak_intro_shitcops" ] = "exf_bak_intro_shitcops";
	level._scr_radio[ "exf_bak_cops_localpolice" ] = "exf_bak_cops_localpolice";
	level._scr_radio[ "exf_bak_cops_lightemup" ] = "exf_bak_cops_lightemup";
	level._scr_radio[ "exf_bak_swat_reinforcements" ] = "exf_bak_swat_reinforcements";
	level._scr_radio[ "exf_bak_swat_morecopsonhill" ] = "exf_bak_swat_morecopsonhill";
	level._scr_radio[ "exf_bak_swat_moreinbound" ] = "exf_bak_swat_moreinbound";
	level._scr_radio[ "exf_bak_swat_shitmorecops" ] = "exf_bak_swat_shitmorecops";
	level._scr_radio[ "exf_bak_swat_keeptoppedonammo" ] = "exf_bak_swat_keeptoppedonammo";
	level._scr_radio[ "exf_bak_swat_myammoslow" ] = "exf_bak_swat_myammoslow";
	level._scr_radio[ "exf_bak_swat_lastmaggrabbing" ] = "exf_bak_swat_lastmaggrabbing";
	level._scr_radio[ "exf_bak_barr_clearuphigh" ] = "exf_bak_barr_clearuphigh";
	level._scr_radio[ "exf_bak_barr_takingright" ] = "exf_bak_barr_takingright";
	level._scr_radio[ "exf_bak_barr_goingright" ] = "exf_bak_barr_goingright";
	level._scr_radio[ "exf_bak_barr_clearingbalcony" ] = "exf_bak_barr_clearingbalcony";
	level._scr_radio[ "exf_bak_barr_coveryoufrombalcony" ] = "exf_bak_barr_coveryoufrombalcony";
	level._scr_radio[ "exf_bak_barr_balconyclear" ] = "exf_bak_barr_balconyclear";
	level._scr_radio[ "exf_bak_barr_eyesonyou" ] = "exf_bak_barr_eyesonyou";
	level._scr_radio[ "exf_bak_barr_overwatchonyou" ] = "exf_bak_barr_overwatchonyou";
	level._scr_radio[ "exf_bak_barr_clearmoveup" ] = "exf_bak_barr_clearmoveup";
	level._scr_radio[ "exf_bak_barr_coverhostilesinbound" ] = "exf_bak_barr_coverhostilesinbound";
	level._scr_radio[ "exf_bak_barr_floodingarea" ] = "exf_bak_barr_floodingarea";
	level._scr_radio[ "exf_bak_barr_gotinbound" ] = "exf_bak_barr_gotinbound";
	level._scr_radio[ "exf_bak_barr_contactsclosingin" ] = "exf_bak_barr_contactsclosingin";
	level._scr_radio[ "exf_bak_barr_hostilesyourway" ] = "exf_bak_barr_hostilesyourway";
	level._scr_radio[ "exf_bak_barr_hostilesinbound" ] = "exf_bak_barr_hostilesinbound";
	level._scr_radio[ "exf_bak_barr_streetsblocked" ] = "exf_bak_barr_streetsblocked";
	level._scr_radio[ "exf_bak_barr_streetsclosedoff" ] = "exf_bak_barr_streetsclosedoff";
	level._scr_radio[ "exf_bak_barr_theyblockedthestreet" ] = "exf_bak_barr_theyblockedthestreet";
	level._scr_radio[ "exf_bak_barr_uphigh11oclock" ] = "exf_bak_barr_uphigh11oclock";
	level._scr_radio[ "exf_bak_barr_balconyleft" ] = "exf_bak_barr_balconyleft";
	level._scr_radio[ "exf_bak_barr_onscaffolding" ] = "exf_bak_barr_onscaffolding";
	level._scr_radio[ "exf_bak_barr_theyjustkeepcoming" ] = "exf_bak_barr_theyjustkeepcoming";
	level._scr_radio[ "exf_bak_barr_movementarcade" ] = "exf_bak_barr_movementarcade";
	level._scr_radio[ "exf_bak_barr_getoffstreets" ] = "exf_bak_barr_getoffstreets";
	level._scr_radio[ "exf_bak_barr_streetsnogo" ] = "exf_bak_barr_streetsnogo";
	level._scr_radio[ "exf_bak_barr_takealley" ] = "exf_bak_barr_takealley";
	level._scr_radio[ "exf_bak_barr_followmetakingalley" ] = "exf_bak_barr_followmetakingalley";
	level._scr_radio[ "exf_bak_barr_throughalley" ] = "exf_bak_barr_throughalley";
	level._scr_radio[ "exf_bak_alley_exfilsnw" ] = "exf_bak_alley_exfilsnw";
	level._scr_radio[ "exf_bak_alley_ambush" ] = "exf_bak_alley_ambush";
	level._scr_radio[ "exf_bak_alley_theyreropingin" ] = "exf_bak_alley_theyreropingin";
	level._scr_radio[ "exf_bak_alley_droppingin" ] = "exf_bak_alley_droppingin";
	level._scr_radio[ "exf_bak_alley_theyredroppingin" ] = "exf_bak_alley_theyredroppingin";
	level._scr_radio[ "exf_bak_alley_rightthroughbldng" ] = "exf_bak_alley_rightthroughbldng";
	level._scr_radio[ "exf_bak_laundry_quiet" ] = "exf_bak_laundry_quiet";
	level._scr_radio[ "exf_bak_laundry_holdup" ] = "exf_bak_laundry_holdup";
	level._scr_radio[ "exf_bak_laundry_fireinthehole" ] = "exf_bak_laundry_fireinthehole";
	level._scr_radio[ "exf_bak_laundry_getready" ] = "exf_bak_laundry_getready";
	level._scr_radio[ "exf_bak_laundry_fragout" ] = "exf_bak_laundry_fragout";
	level._scr_radio[ "exf_bak_laundry_clearthehallway" ] = "exf_bak_laundry_clearthehallway";
	level._scr_radio[ "exf_bak_laundry_clearit" ] = "exf_bak_laundry_clearit";
	level._scr_radio[ "exf_bak_laundry_finishemoff" ] = "exf_bak_laundry_finishemoff";
	level._scr_radio[ "exf_bak_laundry_walkerfinishthem" ] = "exf_bak_laundry_walkerfinishthem";
	level._scr_radio[ "exf_bak_cops_disregardweapfree" ] = "exf_bak_cops_disregardweapfree";
	level._scr_radio[ "exf_bak_barr_moptheseguysup" ] = "exf_bak_barr_moptheseguysup";
	level._scr_radio[ "exf_bak_swat_lotsofmvmntdown" ] = "exf_bak_swat_lotsofmvmntdown";
	level._scr_radio[ "exf_bak_swat_wereclear" ] = "exf_bak_swat_wereclear";
	level._scr_radio[ "exf_bak_swat_raptorsinbound" ] = "exf_bak_swat_raptorsinbound";
	level._scr_radio[ "exf_bak_barr_barricadeoffstreets" ] = "exf_bak_barr_barricadeoffstreets";
	level._scr_radio[ "exf_bak_barr_illgoright" ] = "exf_bak_barr_illgoright";
	level._scr_radio[ "exf_bak_barr_lotsofmvmntacross" ] = "exf_bak_barr_lotsofmvmntacross";
	level._scr_radio[ "exf_bak_barr_poppingsmoke" ] = "exf_bak_barr_poppingsmoke";
	level._scr_radio[ "exf_bak_barr_riotshieldsthrowfrag" ] = "exf_bak_barr_riotshieldsthrowfrag";
	level._scr_radio[ "exf_bak_barr_armoredturret" ] = "exf_bak_barr_armoredturret";
	level._scr_radio[ "exf_bak_barr_theyvegotapc" ] = "exf_bak_barr_theyvegotapc";
	level._scr_radio[ "exf_bak_barr_turretspinningmedown" ] = "exf_bak_barr_turretspinningmedown";
	level._scr_radio[ "exf_bak_barr_turretsonyou" ] = "exf_bak_barr_turretsonyou";
	level._scr_radio[ "exf_bak_barr_exfilinbound" ] = "exf_bak_barr_exfilinbound";
	level._scr_radio[ "exf_bak_barr_letsmove" ] = "exf_bak_barr_letsmove";
	level._scr_radio[ "exf_bak_barr_downalley" ] = "exf_bak_barr_downalley";
	level._scr_radio[ "exf_bak_barr_letsgo" ] = "exf_bak_barr_letsgo";
	level._scr_radio[ "exf_bak_alley_exfilstorefront" ] = "exf_bak_alley_exfilstorefront";
	level._scr_radio[ "exf_bak_alley_cutthroughbldng" ] = "exf_bak_alley_cutthroughbldng";
	level._scr_radio[ "exf_bak_alley_buildinghot" ] = "exf_bak_alley_buildinghot";
	level._scr_radio[ "exf_bak_hall_giveus2mikes" ] = "exf_bak_hall_giveus2mikes";
	level._scr_radio[ "exf_bak_hall_breachpopsmokepz" ] = "exf_bak_hall_breachpopsmokepz";
	level._scr_radio[ "exf_bak_hall_onyourmark" ] = "exf_bak_hall_onyourmark";
	level._scr_radio[ "exf_ovl_hall_raptor2inpos" ] = "exf_ovl_hall_raptor2inpos";
	level._scr_radio[ "exf_cop1_hall_moaning" ] = "exf_cop1_hall_moaning";
	level._scr_radio[ "exf_cop2_hall_moaning" ] = "exf_cop2_hall_moaning";
	level._scr_radio[ "exf_cop3_hall_moaning" ] = "exf_cop3_hall_moaning";
	level._scr_radio[ "exf_cop4_hall_moaning" ] = "exf_cop4_hall_moaning";
	level._scr_radio[ "exf_cop5_hall_moaning" ] = "exf_cop5_hall_moaning";
	level._scr_radio[ "exf_bak_intro_micson" ] = "exf_bak_intro_micson";
	level._scr_radio[ "exf_bak_intro_switchingtomic" ] = "exf_bak_intro_switchingtomic";
	level._scr_radio[ "exf_bak_cops_wegotinbound" ] = "exf_bak_cops_wegotinbound";
	level._scr_radio[ "exf_bak_swat_illhugleft" ] = "exf_bak_swat_illhugleft";
	level._scr_radio[ "exf_bak_swat_clearplanter" ] = "exf_bak_swat_clearplanter";
	level._scr_radio[ "exf_bak_swat_droppingdown" ] = "exf_bak_swat_droppingdown";
	level._scr_radio[ "exf_bak_swat_goinghigh" ] = "exf_bak_swat_goinghigh";
	level._scr_radio[ "exf_bak_swat_illmoveleft" ] = "exf_bak_swat_illmoveleft";
	level._scr_radio[ "exf_rap_swat_whatsyourgrid" ] = "exf_rap_swat_whatsyourgrid";
	level._scr_radio[ "exf_bak_swat_mapgrid779" ] = "exf_bak_swat_mapgrid779";
	level._scr_radio[ "exf_rap_swat_rogerthat" ] = "exf_rap_swat_rogerthat";
	level._scr_radio[ "exf_bak_swat_broughtbird" ] = "exf_bak_swat_broughtbird";
	level._scr_radio[ "exf_bak_barr_illclearuphigh" ] = "exf_bak_barr_illclearuphigh";
	level._scr_radio[ "exf_bak_barr_riotshieldsforward" ] = "exf_bak_barr_riotshieldsforward";
	level._scr_radio[ "exf_bak_barr_riotshieldsadvancing" ] = "exf_bak_barr_riotshieldsadvancing";
	level._scr_radio[ "exf_bak_barr_pushingforward" ] = "exf_bak_barr_pushingforward";
	level._scr_radio[ "exf_bak_barr_movingup" ] = "exf_bak_barr_movingup";
	level._scr_radio[ "exf_bak_barr_fallingbackmovealley" ] = "exf_bak_barr_fallingbackmovealley";
	level._scr_radio[ "exf_bak_barr_thrualley" ] = "exf_bak_barr_thrualley";
	level._scr_radio[ "exf_bak_barr_needtomove" ] = "exf_bak_barr_needtomove";
	level._scr_radio[ "exf_bak_barr_letsgo" ] = "exf_bak_barr_letsgo";
	level._scr_radio[ "exf_bak_barr_followmewalker" ] = "exf_bak_barr_followmewalker";
	level._scr_radio[ "exf_bak_barr_turretcompromised" ] = "exf_bak_barr_turretcompromised";
	level._scr_radio[ "exf_ovl_hall_rogerthat" ] = "exf_ovl_hall_rogerthat";
	level._scr_radio[ "exf_rap_hall_heavyopp" ] = "exf_rap_hall_heavyopp";
	level._scr_radio[ "exf_bak_hall_giveus2mikesraptor" ] = "exf_bak_hall_giveus2mikesraptor";
	level._scr_radio[ "exf_bak_gen_clearit" ] = "exf_bak_gen_clearit";
	level._scr_radio[ "exf_bak_gen_letsmove" ] = "exf_bak_gen_letsmove";
	level._scr_radio[ "exf_bak_gen_clear" ] = "exf_bak_gen_clear";
	level._scr_radio[ "exf_bak_gen_gothim" ] = "exf_bak_gen_gothim";
	level._scr_radio[ "exf_bak_gen_tangodown" ] = "exf_bak_gen_tangodown";
	level._scr_radio[ "exf_bak_gen_tangosdown" ] = "exf_bak_gen_tangosdown";
	level._scr_radio[ "exf_bak_gen_movingforward" ] = "exf_bak_gen_movingforward";
	level._scr_radio[ "exf_bak_gen_advancing" ] = "exf_bak_gen_advancing";
	level._scr_radio[ "exf_bak_gen_movingup" ] = "exf_bak_gen_movingup";
	level._scr_radio[ "exf_bak_gen_goodkill" ] = "exf_bak_gen_goodkill";
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree("vehicles");
vehicles()
{
	//police cars 01
	level._scr_anim[ "exfil_police_01" ][ "esfil_police_cars_01" ] = %nx_vh_exfil_police_cars1_car_01;
	level._scr_anim[ "exfil_police_02" ][ "esfil_police_cars_01" ] = %nx_vh_exfil_police_cars1_car_02;
}

#using_animtree("player");
player_anims()
{
	//intro
	level._scr_animtree[ "player_rig" ] = #animtree;
	level._scr_anim[ "player_rig" ][ "exfil_intro" ] = %nx_fp_exfil_intro_player;
	level._scr_model[ "player_rig" ] = "viewhands_player_us_army";

	//intro door traversal
	level._scr_anim[ "player_rig" ][ "exfil_intro_player_door" ] = %nx_fp_exfil_intro_player_door;

	//outro player
	level._scr_animtree[ "player_rig" ] = #animtree;
	level._scr_anim[ "player_rig" ][ "outro_door_kick" ] = %nx_fp_exfil_door_kick_player;
	level._scr_model[ "player_rig" ] = "viewhands_player_us_army";
}

#using_animtree("generic_human");
generic_human()
{
	//police cars 01
	level._scr_anim[ "cop_cars1_opfor1" ][ "esfil_police_cars_01" ] = %nx_tp_exfil_police_cars1_opfor_01;
	level._scr_anim[ "cop_cars1_opfor2" ][ "esfil_police_cars_01" ] = %nx_tp_exfil_police_cars1_opfor_02;
	level._scr_anim[ "cop_cars1_opfor3" ][ "esfil_police_cars_01" ] = %nx_tp_exfil_police_cars1_opfor_03;

	//soda machine cover
	level._scr_anim[ "soda_machine_01_opfor" ][ "exfil_soda_machine" ] = %nx_tp_exfil_soda_machine_opfor_01;

	//intro
	level._scr_anim[ "ally_01" ][ "bog_radio_dialogue" ] = %nx_tp_exfil_baker_intro_radio;
	level._scr_anim[ "ally_01" ][ "roadkill_cover_radio_soldier1_idle" ] = %roadkill_cover_radio_soldier1_idle;
	level._scr_anim[ "ally_01" ][ "exfil_intro" ] = %nx_tp_exfil_intro_ally_01;
	level._scr_anim[ "opfor_01" ][ "exfil_intro" ] = %nx_tp_exfil_intro_enemy_01;
	addNotetrack_customFunction( "opfor_01", "fx_nt_suckonthis", ::blood_splatter_gutshot_fx, "exfil_intro" );
	addNotetrack_customFunction( "opfor_01", "fx_nt_opfor1_headshot", ::blood_splatter_headshot_fx_opfor1, "exfil_intro" );
	level._scr_anim[ "opfor_02" ][ "exfil_intro" ] = %nx_tp_exfil_intro_enemy_02;
	addNotetrack_customFunction( "opfor_02", "fx_nt_intheface", ::blood_splatter_headshot_fx_opfor2, "exfil_intro" );
	level._scr_anim[ "opfor_01" ][ "exfil_intro_idle" ] = [ %nx_tp_exfil_intro_enemy_01_idle ];
	level._scr_anim[ "opfor_02" ][ "exfil_intro_idle" ] = [ %nx_tp_exfil_intro_enemy_02_idle ];
	addNotetrack_customFunction( "ally_01", "headshot_01", ::blood_splatter_01_show, "exfil_intro" );
	addNotetrack_customFunction( "ally_01", "headshot_02", ::blood_splatter_02_show, "exfil_intro" );
	addNotetrack_customFunction( "ally_01", "blood_spat_01", ::blood_splatter_03_show, "exfil_intro" );
	addNotetrack_customFunction( "ally_01", "headshot_02", ::blood_spray_02_show, "exfil_intro" );
	addNotetrack_attach( "ally_01", "knife_pullout", "weapon_parabolic_knife", "TAG_INHAND", "exfil_intro" );
	addNotetrack_detach( "ally_01", "knife_putaway", "weapon_parabolic_knife", "TAG_INHAND", "exfil_intro" );

	//fast ropes
	level._scr_anim[ "fast_ropes_opfor1" ][ "exfil_fast_ropes" ] = %nx_tp_exfil_fastrope_opfor_01;
	level._scr_anim[ "fast_ropes_opfor2" ][ "exfil_fast_ropes" ] = %nx_tp_exfil_fastrope_opfor_02;
	level._scr_anim[ "fast_ropes_opfor3" ][ "exfil_fast_ropes" ] = %nx_tp_exfil_fastrope_opfor_03;

	//ending
	level._scr_anim[ "enemy_01" ][ "laundry_enemies" ] = %nx_tp_exfil_laundry_enemies_01;
	level._scr_anim[ "enemy_02" ][ "laundry_enemies" ] = %nx_tp_exfil_laundry_enemies_02;
	level._scr_anim[ "enemy_03" ][ "laundry_enemies" ] = %nx_tp_exfil_laundry_enemies_03;
	level._scr_anim[ "enemy_04" ][ "laundry_enemies" ] = %nx_tp_exfil_laundry_enemies_04;
	level._scr_anim[ "enemy_05" ][ "laundry_enemies" ] = %nx_tp_exfil_laundry_enemies_05;
	level._scr_anim[ "enemy_06" ][ "laundry_enemies" ] = %nx_tp_exfil_laundry_enemies_06;
	level._scr_anim[ "ally_01" ][ "laundry_door" ] = %nx_tp_exfil_laundry_door_ally_01;
	addNotetrack_customFunction( "ally_01", "grenade_explode", maps\nx_exfil_fx::fx_hall_grenade_explode );
	level._scr_anim[ "ally_01" ][ "outro_door_kick" ] = %nx_tp_exfil_door_kick_ally_01;
	//addNotetrack_customFunction( "ally_01", "grenade_toss", ::grenade_toss );
	addNotetrack_customFunction( "ally_01", "grenade_explode", ::grenade_toss );
	
	//rail 01
	level._scr_anim[ "rail_01_opfor" ][ "rail_01" ] = %nx_tp_exfil_melee_rail_01_opfor_01;
	level._scr_anim[ "rail_01_baker" ][ "rail_01" ] = %nx_tp_exfil_melee_rail_01_baker_01;

	//rail 02
	level._scr_anim[ "rail_02_baker" ][ "ral_02" ] = %nx_tp_exfil_melee_rail_02_baker_01;
	level._scr_anim[ "rail_02_opfor" ][ "ral_02" ] = %nx_tp_exfil_melee_rail_02_opfor_01;

	// alley cook grenade
	level._scr_anim[ "alley_cook_grenade" ][ "baker_cook" ] = %nx_tp_exfil_outro_p1_ally_01;
	level._scr_anim[ "alley_wounded_01" ][ "wounded_idle" ][ 0 ] = %nx_tp_exfil_outro_p2_opfor_idle_01;
	level._scr_anim[ "alley_wounded_02" ][ "wounded_idle" ][ 0 ] = %nx_tp_exfil_outro_p2_opfor_idle_02;
	level._scr_anim[ "alley_wounded_03" ][ "wounded_idle" ][ 0 ] = %nx_tp_exfil_outro_p2_opfor_idle_03;
	level._scr_anim[ "alley_wounded_04" ][ "wounded_idle" ][ 0 ] = %nx_tp_exfil_outro_p2_opfor_idle_04;
	level._scr_anim[ "alley_wounded_05" ][ "wounded_idle" ][ 0 ] = %nx_tp_exfil_outro_p2_opfor_idle_05;
	level._scr_anim[ "alley_wounded_06" ][ "wounded_idle" ][ 0 ] = %nx_tp_exfil_outro_p2_opfor_idle_06;

	// death anims for cook grenade alley
	level._scr_anim[ "alley_wounded_01" ][ "nx_tp_exfil_outro_p2_opfor_death_01" ] = %nx_tp_exfil_outro_p2_opfor_death_01;
	level._scr_anim[ "alley_wounded_02" ][ "nx_tp_exfil_outro_p2_opfor_death_02" ] = %nx_tp_exfil_outro_p2_opfor_death_02;
	level._scr_anim[ "alley_wounded_03" ][ "nx_tp_exfil_outro_p2_opfor_death_03" ] = %nx_tp_exfil_outro_p2_opfor_death_03;
	level._scr_anim[ "alley_wounded_04" ][ "nx_tp_exfil_outro_p2_opfor_death_04" ] = %nx_tp_exfil_outro_p2_opfor_death_04;
	level._scr_anim[ "alley_wounded_05" ][ "nx_tp_exfil_outro_p2_opfor_death_05" ] = %nx_tp_exfil_outro_p2_opfor_death_05;
	level._scr_anim[ "alley_wounded_06" ][ "nx_tp_exfil_outro_p2_opfor_death_06" ] = %nx_tp_exfil_outro_p2_opfor_death_06;


	// alley bust through the final door
	level._scr_anim[ "alley_exit" ][ "baker_kick" ] = %nx_tp_exfil_outro_p3_ally_01;
	
	// civ run away
	level._scr_anim[ "civ_a" ][ "civ_run_away" ] = %nx_tp_exfil_civ_run_away_a;
	level._scr_anim[ "civ_b" ][ "civ_run_away" ] = %nx_tp_exfil_civ_run_away_b;
	level._scr_anim[ "civ_c" ][ "civ_run_away" ] = %nx_tp_exfil_civ_run_away_c;
	level._scr_anim[ "civ_d" ][ "civ_run_away" ] = %nx_tp_exfil_civ_run_away_d;
	level._scr_anim[ "civ_e" ][ "civ_run_away" ] = %nx_tp_exfil_civ_run_away_e;
	level._scr_anim[ "civ_f" ][ "civ_run_away" ] = %nx_tp_exfil_civ_run_away_f;
	level._scr_anim[ "civ_g" ][ "civ_run_away" ] = %nx_tp_exfil_civ_run_away_g;
	level._scr_anim[ "civ_h" ][ "civ_run_away" ] = %nx_tp_exfil_civ_run_away_h;
	level._scr_anim[ "civ_j" ][ "civ_run_away" ] = %nx_tp_exfil_civ_run_away_j;
	level._scr_anim[ "civ_k" ][ "civ_run_away" ] = %nx_tp_exfil_civ_run_away_k;
}

#using_animtree("script_model");
script_models()
{
	//soda machine cover
	level._scr_animtree[ "exfil_soda_machin_01" ] = #animtree;
	level._scr_anim[ "exfil_soda_machin_01" ][ "exfil_soda_machine" ] = %nx_pr_exfil_soda_machine_01_anim;
	level._scr_model[ "exfil_soda_machin_01" ] = "nx_pr_exfil_soda_machine_01";

	//fast ropes
	level._scr_animtree[ "fast_ropes_door_model" ] = #animtree;
	level._scr_anim[ "fast_ropes_door_model" ][ "exfil_fast_ropes" ] = %nx_pr_exfil_door_01;
	level._scr_model[ "fast_ropes_door_model" ] = "nx_pr_exfil_door_model_01";

	level._scr_animtree[ "rope_01" ] = #animtree;
	level._scr_anim[ "rope_01" ][ "exfil_fast_ropes" ] = %nx_pr_exfil_rope_01;
	level._scr_model[ "rope_01" ] = "nx_pr_exfil_rope";

	level._scr_animtree[ "rope_02" ] = #animtree;
	level._scr_anim[ "rope_02" ][ "exfil_fast_ropes" ] = %nx_pr_exfil_rope_02;
	level._scr_model[ "rope_02" ] = "nx_pr_exfil_rope";

	//Intro 
	level._scr_animtree[ "delivery_truck" ] = #animtree;
	level._scr_anim[ "delivery_truck" ][ "exfil_intro" ] = %nx_pr_exfil_intro_van;
	level._scr_model[ "delivery_truck" ] = "nx_pr_exfil_copvan_destroy";

	level._scr_animtree[ "cuffs" ] = #animtree;
	level._scr_anim[ "cuffs" ][ "exfil_intro" ] = %nx_pr_exfil_intro_cuffs;
	level._scr_model[ "cuffs" ] = "viewmodel_plastic_handcuffs";

	level._scr_animtree[ "delivery_truck" ] = #animtree;
	level._scr_anim[ "delivery_truck" ][ "exfil_intro_player_door" ] = %nx_pr_exfil_intro_van_door;
	level._scr_model[ "delivery_truck" ] = "nx_pr_exfil_copvan_destroy";

	//Laundry Door
	level._scr_animtree[ "laundry_door" ] = #animtree;
	level._scr_anim[ "laundry_door" ][ "laundry_door" ] = %nx_pr_exfil_laundry_door;
	level._scr_model[ "laundry_door" ] = "nx_pr_exfil_laundry_door";

	level._scr_animtree[ "grenade_pin" ] = #animtree;
	level._scr_anim[ "grenade_pin" ][ "laundry_door" ] = %nx_pr_exfil_laundry_grenade_pin;
	level._scr_model[ "grenade_pin" ] = "nx_pr_exfil_grenade_pin";

	level._scr_animtree[ "laundry_door_grenade" ] = #animtree;
	level._scr_anim[ "laundry_door_grenade" ][ "laundry_door" ] = %nx_pr_exfil_laundry_door_grenade;
	level._scr_model[ "laundry_door_grenade" ] = "projectile_m67fraggrenade";

	//Light Swing
	level._scr_animtree[ "light_swing" ] = #animtree;
	level._scr_anim[ "light_swing" ][ "light_swing" ] = %nx_pr_exfil_swinging_light;
	level._scr_model[ "light_swing" ] = "nx_pr_exfil_swinging_light";

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// polic cars1
esfil_police_cars_01_spawn()
{
	exfil_police_01 = vignette_vehicle_spawn("exfil_police_01", "exfil_police_01"); //"value" (kvp), "anim_name"
	exfil_police_02 = vignette_vehicle_spawn("exfil_police_02", "exfil_police_02"); //"value" (kvp), "anim_name"
	cop_cars1_opfor1 = spawn_cop( "cop_cars1_opfor1", "cop_cars1_opfor1" );
	cop_cars1_opfor2 = spawn_cop( "cop_cars1_opfor2", "cop_cars1_opfor2" );
	cop_cars1_opfor3 = spawn_cop( "cop_cars1_opfor3", "cop_cars1_opfor3" );

	exfil_police_01 GodOn();
	exfil_police_02 GodOn();
	cop_cars1_opfor1 thread cop_watch_out_for_grenades();

	exfil_police_01 thread maps\nx_exfil_audio::police_car_radio_chatter();
	exfil_police_01 playsound("scn_exfil_police_car_intro");

	thread cop_dialog(cop_cars1_opfor1, cop_cars1_opfor2, cop_cars1_opfor3);
	cop_cars1_opfor1 thread cop_watch_out_for_grenades();

	esfil_police_cars_01(exfil_police_01, exfil_police_02, cop_cars1_opfor1, cop_cars1_opfor2, cop_cars1_opfor3);

	cop_cars1_opfor1 stop_magic_bullet_shield();
	cop_cars1_opfor2 stop_magic_bullet_shield();
	cop_cars1_opfor3 stop_magic_bullet_shield();

	exfil_police_01 DisconnectPaths();
	exfil_police_02 DisconnectPaths();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

esfil_police_cars_01(exfil_police_01, exfil_police_02, cop_cars1_opfor1, cop_cars1_opfor2, cop_cars1_opfor3)
{

	node = getstruct("cop_cars1_vignette", "script_noteworthy");

	guys = [];
	guys["exfil_police_01"] = exfil_police_01;
	guys["exfil_police_02"] = exfil_police_02;
	guys["cop_cars1_opfor1"] = cop_cars1_opfor1;
	guys["cop_cars1_opfor2"] = cop_cars1_opfor2;
	guys["cop_cars1_opfor3"] = cop_cars1_opfor3;

	exfil_police_01 suspend_drive_anims_for_vignette();
	exfil_police_02 suspend_drive_anims_for_vignette();

	node thread anim_single(guys, "esfil_police_cars_01");

	wait 7;
	exfil_police_01 GodOff();
	exfil_police_02 GodOff();

	flag_wait( "cops_engaged" );
	
	if ( IsAlive( cop_cars1_opfor1 ) )
	{
		cop_cars1_opfor1 anim_stopanimscripted();
	}

	if ( IsAlive( cop_cars1_opfor2 ) )
	{
		cop_cars1_opfor2 anim_stopanimscripted();
	}
	
	if ( IsAlive( cop_cars1_opfor3 ) )
	{
		cop_cars1_opfor3 anim_stopanimscripted();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

cop_watch_out_for_grenades()
{
	self endon( "death" );
	self endon( "cops_engaged" );

	self waittill( "grenade danger" );

	flag_set( "cops_engaged" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

cop_dialog(cop_cars1_opfor1, cop_cars1_opfor2, cop_cars1_opfor3)
{
	wait 5.2;
	cop_cars1_opfor2 playsound("exf_cop_alley_stream");	

	//thread cop_dialog_lines(cop_cars1_opfor1, "exf_cop_alley_groundnow", "exf_cop_alley_onknees", "exf_cop_alley_freeze", "exf_cop_alley_dropweapons", "exf_cop_alley_dontmove", "exf_cop_alley_groundnow", 0.5);
	//self thread cop_dialog_lines( cop_cars1_opfor1, "exf_bak_van_youok", "exf_bak_van_youok", "exf_bak_van_youok" );
	//wait 1.0;
	//thread cop_dialog_lines(cop_cars1_opfor2, "exf_cop_alley_getdown", "exf_cop_alley_dontmove", "exf_cop_alley_onknees", "exf_cop_alley_getdown", "exf_cop_alley_dontmove", "exf_cop_alley_onknees", 0.6);
	//self thread cop_dialog_lines( cop_cars1_opfor2, "exf_bak_van_gottago", "exf_bak_van_gottago", "exf_bak_van_gottago" );
	//wait 0.3;
	//thread cop_dialog_lines( cop_cars1_opfor3, "exf_cop_alley_getdownground", "exf_cop_alley_getdownground", "exf_cop_alley_getdownground", "exf_cop_alley_getdownground", "exf_cop_alley_getdownground", "exf_cop_alley_getdownground", 2.2);
	//self thread cop_dialog_lines( cop_cars1_opfor3, "exf_bak_van_solidcopy", "exf_bak_van_solidcopy", "exf_bak_van_solidcopy" );

}

cop_dialog_lines ( cop, line1, line2, line3, line4, line5, line6, waittime)
{
	cop endon( "death" );
	if ( flag( "cops_engaged" ) )
	{
		return;
	}

	level endon( "cops_engaged" );

	cop playsound(line1, "sounddone");
	cop waittill( "sounddone" ); 
	wait waittime;

	cop playsound(line2, "sounddone");
	cop waittill( "sounddone" );
	wait waittime;

	cop playsound(line3, "sounddone");
	cop waittill( "sounddone" );
	wait waittime;
	
	cop playsound(line4, "sounddone");
	cop waittill( "sounddone" );
	wait waittime;
	
	cop playsound(line5, "sounddone");
	cop waittill( "sounddone" );
	wait waittime;
	
	cop playsound(line6, "sounddone");
	cop waittill( "sounddone" );
}

spawn_cop( spawner_name, anim_name )
{
    spawner = GetEnt( spawner_name, "targetname" );
	//spawner.script_forcespawn = 1;
    //spawner thread add_spawn_function( ::vignette_actor_spawn_func );

    vignette_actor = spawner spawn_ai();
    vignette_actor.animname = anim_name;
	vignette_actor magic_bullet_shield();
	return vignette_actor;

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

exfil_intro_spawn()
{
	thread civ_run_away_spawn();

	// hide weapons
	level._player takeallweapons();

	// grab baker since he's already spawned
	ally_01 = level.allies[ "ally1" ];
	ally_01.animname = "ally_01";
	//ally_01 thread vignette_actor_ignore_everything();

	opfor_01 = vignette_actor_spawn("opfor_10", "opfor_01"); //"value" (kvp), "anim_name"
	//level.head_swap_guy = opfor_01;
	opfor_02 = vignette_actor_spawn("opfor_11", "opfor_02"); //"value" (kvp), "anim_name"

	level.head_swap_guy = [];
	level.head_swap_guy[ 0 ] = opfor_01;
	level.head_swap_guy[ 1 ] = opfor_02; 

	ally_01.oldprimary = ally_01.primaryweapon;
	ally_01 forceUseWeapon( ally_01.sidearm , "primary" );
	ally_01 place_weapon_on( ally_01.oldprimary, "chest" );

	exfil_intro(ally_01, opfor_01, opfor_02);

	ally_01 forceUseWeapon( ally_01.oldprimary, "primary" );
	ally_01.primaryweapon = ally_01.oldprimary;
	ally_01.lastWeapon = ally_01.oldprimary;

	node = getstruct("exfil_intro", "script_noteworthy");

	node thread anim_loop( [ opfor_01, opfor_02] , "exfil_intro_idle" );

	level notify( "exfil_intro_spawn_finished" );

	exfil_intro_part2( ally_01 );
}

exfil_intro(ally_01, opfor_01, opfor_02)
{
	ally_01 enable_cqbwalk();

	blood_splatter_1 = GetEnt( "intro_blood_01", "targetname" );
	blood_splatter_1 Hide();
	blood_splatter_2 = GetEnt( "intro_blood_02", "targetname" );
	blood_splatter_2 Hide();
	blood_splatter_3 = GetEnt( "intro_blood_03", "targetname" );
	blood_splatter_3 Hide();

	node = getstruct("exfil_intro", "script_noteworthy");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	level.delivery_truck = spawn_anim_model("delivery_truck");

	cuffs = spawn_anim_model("cuffs");

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["ally_01"] = ally_01;
	guys["opfor_01"] = opfor_01;
	guys["opfor_02"] = opfor_02;
	guys["player_rig"] = player_rig;
	guys["delivery_truck"] = level.delivery_truck;
	guys["cuffs"] = cuffs;

	arc = 7;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "exfil_intro");

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
}

exfil_intro_part2( ally_01 )
{
	flag_set( "radio_exfil_begin" ); // Triggers dialogue in nx_exfil_intro	

	// Get Baker into position 
	radio_node = GetNode( "baker_intro_radio_setup", "targetname" );
	radio_origin = GetEnt( "baker_intro_radio", "targetname" );
	ally_01.goalradius = 8;
//	ally_01 SetGoalNode( radio_node );
	radio_origin anim_reach_and_approach_solo( ally_01, "bog_radio_dialogue", undefined, "Exposed" );
	ally_01 waittill( "goal" );



	radio_origin anim_single_solo( ally_01, "bog_radio_dialogue" ); //play radio anim while getting exfil information
	
	// TJ - stub for where we should get Baker to look back at the player and see if they're alright

	ally_01 enable_cqbwalk();
	ally_01 SetGoalNode( GetNode( "baker_cop_sequence", "targetname" ) ); // Move Baker to cop encounter
	ally_01 waittill( "goal" );

	flag_wait( "intro_dialogue_complete" );

	// hand off control back to the system
	ally_01 enable_ai_color();
	ally_01 disable_cqbwalk();
	ally_01.ignoreall = false;
}

blood_splatter_gutshot_fx( opfor_01 )
{
		spinelower = opfor_01 getTagOrigin( "J_spinelower" );
		//spinelower_angles = opfor_01 getTagAngles( "J_spinelower" );
		playFX( level._effect[ "gutshot" ], spinelower );
}

blood_splatter_headshot_fx_opfor1( opfor_01 )
{
		head = opfor_01 getTagOrigin( "J_head" );
		//spinelower_angles = opfor_01 getTagAngles( "J_head" );
		playFX( level._effect[ "headshot" ], head );
}

blood_splatter_headshot_fx_opfor2( opfor_02 )
{
		head = opfor_02 getTagOrigin( "J_head" );
		//spinelower_angles = opfor_01 getTagAngles( "J_head" );
		playFX( level._effect[ "headshot" ], head );
		wait ( 0.2 );
		//thread maps\nx_exfil_fx::blood_grit_overlay();
		playFX( level._effect[ "headshot" ], head );
}

blood_splatter_01_show( ally_01 )
{
	blood_splatter_1 = GetEnt( "intro_blood_01", "targetname" );
	blood_splatter_1 Show();

	// Head Swap.
	guy = level.head_swap_guy[ 0 ];

	guy detach( guy.headmodel, "" );
	guy attach( "exfil_swat_head_a_shot", "", true );
}

blood_splatter_02_show( ally_01 )
{
	blood_splatter_2 = GetEnt( "intro_blood_02", "targetname" );
	blood_splatter_2 Show();

	// Head Swap.
	guy = level.head_swap_guy[ 1 ];

	guy detach( guy.headmodel, "" );
	guy attach( "exfil_swat_head_b_shot", "", true );
}

blood_splatter_03_show( ally_01 )
{
	blood_splatter_3 = GetEnt( "intro_blood_03", "targetname" );
	blood_splatter_3 Show();
}

blood_spray_02_show( guy )
{	
	time = 4.0;

	overlay = newHudElem();
	overlay.x = 0;
	overlay.y = 0;
	overlay setshader( "splatter_alt_sp", 640, 480 );
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha = 1;
	overlay FadeOverTime( time );
	overlay.alpha = 0.0;
	
	wait time;

	overlay destroy();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//Soda Machine Cover
exfil_soda_machine_spawn()
{
	soda_machine_01_opfor_spawner = GetEnt( "soda_guy", "script_noteworthy" );
	soda_machine_01_opfor = soda_machine_01_opfor_spawner spawn_ai( true ); //"value" (kvp), "anim_name"

	exfil_soda_machine(soda_machine_01_opfor);
}

exfil_soda_machine(soda_machine_01_opfor)
{

	node = getstruct("vignette_soda_machine_01", "script_noteworthy");

	exfil_soda_machin_01 = spawn_anim_model("exfil_soda_machin_01");
	soda_machine_01_opfor.animname = "soda_machine_01_opfor";

	guys = [];
	guys["soda_machine_01_opfor"] = soda_machine_01_opfor;
	guys["exfil_soda_machin_01"] = exfil_soda_machin_01;

	node anim_single(guys, "exfil_soda_machine");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// fast ropes
exfil_fast_ropes_spawn()
{
	fast_ropes_opfor1 = spawn_cop( "fast_ropes_opfor1", "fast_ropes_opfor1" ); //"value" (kvp), "anim_name"
	fast_ropes_opfor2 = spawn_cop( "fast_ropes_opfor2", "fast_ropes_opfor2" ); //"value" (kvp), "anim_name"
	fast_ropes_opfor3 = spawn_cop( "fast_ropes_opfor3", "fast_ropes_opfor3" ); //"value" (kvp), "anim_name"

	exfil_fast_ropes(fast_ropes_opfor1, fast_ropes_opfor2, fast_ropes_opfor3);

	fast_ropes_opfor1 stop_magic_bullet_shield();
	fast_ropes_opfor2 stop_magic_bullet_shield();
	fast_ropes_opfor3 stop_magic_bullet_shield();
}

exfil_fast_ropes(fast_ropes_opfor1, fast_ropes_opfor2, fast_ropes_opfor3)
{
	node = getstruct("vignette_fast_ropes", "script_noteworthy");
	fast_ropes_door_model = level.vignette_script_models["fast_ropes_door_model"];//spawn_anim_model("fast_ropes_door_model");

	rope_01 = spawn_anim_model("rope_01");
	rope_02 = spawn_anim_model("rope_02");

	guys = [];
	guys["fast_ropes_door_model"] = fast_ropes_door_model;
	guys["rope_01"] = rope_01;
	guys["rope_02"] = rope_02;
	guys["fast_ropes_opfor1"] = fast_ropes_opfor1;
	guys["fast_ropes_opfor2"] = fast_ropes_opfor2;
	guys["fast_ropes_opfor3"] = fast_ropes_opfor3;

	node anim_single(guys, "exfil_fast_ropes");
}

//Spawns in a model and sets it to first frame of the animation
//Stores it in a level array to be referenced later.
script_model_first_frame( node_noteworthy, model_name, anim_name  )
{
	if(!IsDefined(level.vignette_script_models))
		level.vignette_script_models = [];

	node = getstruct(node_noteworthy, "script_noteworthy");

	model = spawn_anim_model(model_name);

	level.vignette_script_models[model_name] = model;

	node anim_first_frame_solo( level.vignette_script_models[ model_name ], anim_name );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

outro_door_kick_spawn()
{
	thread audio_outro_logic();

	

	// make player drop and raise weapon.
	self thread drop_and_raise();

	// remove our objective entity
	Objective_ClearAdditionalEntity( obj( "obj_get_to_exfil" ), 1 );

	// get our important locations
	anim_node = getstruct( "vignette_outro_door_kick", "script_noteworthy");

	// setup Baker correctly
	ally_01 = level.allies[ "ally1" ];
	ally_01.animname = "ally_01";

	//thread fadeout and mission end
	//use notetrack in bakers animation to trigger fadeout
	//"continueaudio" is how many seconds the scene will allow audion before booting to the main menu;
	continueaudio = 9;
	fadeoutwait = 3.19; //tried notetrack, dont know how : (
	self thread end_blackout( fadeoutwait, continueaudio ); 

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	// gather all our pieces for anims
	guys = [];
	guys["ally_01"] = ally_01;
	guys["player_rig"] = player_rig;

	arc = 0;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	// Baker should already be in position and ready to animate
	anim_node anim_single( guys, "outro_door_kick" );

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
}

audio_outro_logic()
{
	//flag_set( "music_street_start" );
	play_music_once("mus_nx_exfil_outro");
	level._player playsound( "scn_exfil_outro_front" );
	wait 3;
	level.audio_outro_emitter setsoundvolume( "emt_exfil_chaos_01", -100, 1 );
	level._player setchannelvolumes( "snd_channelvolprio_level", "nx_exfil_outro", 1.0 );
}

drop_and_raise  ()
{

	level._player DisableWeapons();

	wait 2.3;

	level._player EnableWeapons();

}

end_blackout( fadeoutwait, continueaudio )
{

	wait fadeoutwait;
	
	//setSavedDvar( "compass", 0 );
	//setSavedDvar( "hud_showStance", 0 );
	
	overlay = newHudElem();
	overlay.x = 0;
	overlay.y = 0;
	overlay setshader( "black", 640, 480 );
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	
	overlay.alpha = 0;
	overlay fadeOverTime( 0.1 );
	overlay.alpha = 1;

	level._player freezeControls( true );
	enablePlayerWeapons( false );
	
	wait continueaudio;

	endmission_goto_frontend();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// cooked grenade plus injured enemies
exfil_alley_cook_grenade()
{
	// get our important locations
	anim_node = getstruct( "vignette_laundry_door", "script_noteworthy" );

	// setup all the neccesary pieces
	laundry_door = level.vignette_script_models["laundry_door"];//spawn_anim_model("laundry_door");

	//laundry_door = spawn_anim_model( "laundry_door" );
	grenade_pin = spawn_anim_model("grenade_pin");

	laundry_door_grenade = spawn_anim_model("laundry_door_grenade");


	// setup Baker correctly
	ally_01 = level.allies[ "ally1" ];
	ally_01.animname = "ally_01";
	ally_01.disableArrivals = true;
	ally_01.ignoreAll = true;

	ally_01 enable_cqbwalk();

	// gather all our pieces for anims
	guys = [];
	guys["ally_01"] = ally_01;
	guys["laundry_door"] = laundry_door;
	guys["grenade_pin"] = grenade_pin;
	guys["laundry_door_grenade"] = laundry_door_grenade;

	// lets get Baker to the correct location
	anim_node anim_reach_solo( ally_01, "laundry_door" );

	thread laundry_enemies_spawn();

	// run our anim
	ally_01 playsound( "scn_exfil_hallway_grenade" );
	anim_node anim_first_frame_solo( ally_01, "laundry_door" );
	anim_node anim_single( guys, "laundry_door" );

	// Set health on laundry guys and kill off a couple
	grenade_hallway_troops_dead = get_ai_group_ai_including_dying( "grenade_hallway_troops_dead" );
	foreach ( guy in grenade_hallway_troops_dead )
		guy kill();

	grenade_hallway_troops = get_ai_group_ai_including_dying( "grenade_hallway_troops" );
	foreach ( guy in grenade_hallway_troops )
			guy.health = 1;

	// set Baker back to how he was before
	ally_01.disableArrivals = false;

	// setup Baker with new logic
	ally_01.dontmelee = true;
	ally_01.moveplaybackrate = 0.55;

//	ally_01.forceSideArm = true;
//	ally_01 forceUseWeapon( ally_01.sidearm, "sidearm" );

	flag_wait( "hallway_cleanup" );

	ally_01.primaryweapon = "fal";
	ally_01 forceUseWeapon( ally_01.primaryweapon, "primary" );
	ally_01.accuracy = 10000.0;

	// get Baker to next node for final door kick
	ally_01.ignoreAll = true;
//	ally_01 follow_path( GetNode( "final_node", "targetname" ) );
	ally_01 SetGoalNode( GetNode( "final_node_end", "targetname" ) );

	ally_01 radio_dialogue( "exf_rap_hall_heavyopp" );
	ally_01 radio_dialogue( "exf_bak_hall_giveus2mikesraptor" );

	ally_01.moveplaybackrate = 0.75;

	wait 1.5;

	ally_01.goalradius = 100;
	ally_01 waittill( "goal" );

	ally_01.ignoreall = true;

	ally_01 radio_dialogue( "exf_bak_hall_breachpopsmokepz" );
	ally_01 thread radio_dialogue( "exf_bak_hall_onyourmark" );
	wait 0.2;
	flag_set( "final_objective" );

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

exfil_intro_player_door_spawn()
{

	exfil_intro_player_door();

}

exfil_intro_player_door()
{

	node = getstruct("exfil_intro", "script_noteworthy");

	level._player FreezeControls( true );
	level._player DisableWeapons();
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	if( !IsDefined( level.delivery_truck ) )
	{
		level.delivery_truck = spawn_anim_model("delivery_truck");
	}

	guys = [player_rig, level.delivery_truck];

	node anim_first_frame( guys, "exfil_intro_player_door" );

	level._player PlayerLinkToBlend( player_rig, "tag_player", 0.3, 0.15, 0.15 );

	node anim_single( guys, "exfil_intro_player_door");

	//guys["delivery_truck"] = delivery_truck;

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player EnableWeapons();
	level._player allowprone( true );
	level._player allowcrouch( true );
	SetSavedDvar( "hud_showStance", 1 );
	SetSavedDvar( "ammoCounterHide", "0" );

	// give back all our weapons
	maps\_loadout::init_loadout();

	// set baker on his way
//	level.allies[ "ally1" ] issue_color_orders( "r2", "allies" );
//	level.allies[ "ally1" ] thread enable_cqbwalk();

	level notify( "exfil_intro_player_door_finished" ) ;

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// rail 01
rail_01_spawn()
{
	rail_01_opfor = vignette_actor_spawn("rail_01_opfor", "rail_01_opfor"); //"value" (kvp), "anim_name"
	rail_01_baker = vignette_actor_spawn("rail_01_baker", "rail_01_baker"); //"value" (kvp), "anim_name"

	rail_01(rail_01_opfor, rail_01_baker);

	rail_01_opfor vignette_actor_delete();
	rail_01_baker vignette_actor_delete();
}

rail_01(rail_01_opfor, rail_01_baker)
{

	node = getstruct("melee_rail_01_vignette", "script_noteworthy");


	guys = [];
	guys["rail_01_opfor"] = rail_01_opfor;
	guys["rail_01_baker"] = rail_01_baker;

	node anim_single(guys, "rail_01");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// rail 02
ral_02_spawn()
{
	rail_02_baker = vignette_actor_spawn("rail_02_baker", "rail_02_baker"); //"value" (kvp), "anim_name"
	rail_02_opfor = vignette_actor_spawn("rail_02_opfor", "rail_02_opfor"); //"value" (kvp), "anim_name"

	ral_02(rail_02_baker, rail_02_opfor);

	rail_02_baker vignette_actor_delete();
	rail_02_opfor vignette_actor_delete();
}

ral_02(rail_02_baker, rail_02_opfor)
{

	node = getstruct("melee_rail_01_vignette", "script_noteworthy");


	guys = [];
	guys["rail_02_baker"] = rail_02_baker;
	guys["rail_02_opfor"] = rail_02_opfor;

	node anim_first_frame(guys, "ral_02");

	node anim_single(guys, "ral_02");

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

laundry_enemies_spawn()
{
	// setup our guys correctly
	guys = [];
	for( index = 1; index < 7; index++ )
	{
		spawner = GetEnt( "alley_final_room_opfor_0" + index, "targetname" );
		spawner.script_forcespawn = 1;

		string_ref = "enemy_0" + index;
		vignette_actor = spawner spawn_ai();
		vignette_actor.animname = string_ref;

		guys[ string_ref ] = vignette_actor;
	}

	// get our node and play our anim
	node = getstruct("vignette_laundry_enemies", "script_noteworthy");
	node anim_single(guys, "laundry_enemies");

	// now clean them up
	for( index = 1; index < 7; index++ )
	{
		string_ref = "enemy_0" + index;
		guys[ string_ref ] vignette_actor_delete();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

grenade_toss( ally_01 )
{
	// spawn magic grenade from struct pos, for it to kill enemies
	//start = getstruct( "grenade_toss_pos", "script_noteworthy" );
	//end = getstruct( "grenade_explode_pos", "script_noteworthy" );
	//MagicGrenade( "fraggrenade", start.origin, end.origin, 1.5 );

	//wait( 1.55 );

	// need to move our door
	move_door_clip();

	// need to put enemies into wounded idle
	guys = [];
	for( index = 1; index < 7; index++ )
	{
		spawner = GetEnt( "alley_final_room_opfor_0" + index, "targetname" );
		spawner.script_forcespawn = 1;
		//spawner.script_drone = 1;

		vignette_actor = spawner spawn_ai();
		vignette_actor.animname = "alley_wounded_0" + index;
		vignette_actor.noragdoll = 1;
		vignette_actor.health = 1;
		vignette_actor.allowdeath = true;
		vignette_actor.ignoreall = true;
		vignette_actor set_deathanim( "nx_tp_exfil_outro_p2_opfor_death_0" + index );

		guys[ guys.size ] = vignette_actor;

		if( 6 == index )
		{
			// special case that we will kill this actor after certain amount of time.
			// we don't want him crawling forever...
			vignette_actor thread delayed_kill();
		}
	}

	// spawn off our check on the Baker ent
	ally_01 thread check_for_room_secured( guys );

	// play our looping anim
	node = getstruct( "vignette_alley_wounded_idle", "script_noteworthy");
	for( index = 0; index < guys.size; index++ )
	{
		node thread anim_loop_solo( guys[index], "wounded_idle" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

delayed_kill()
{
	self endon( "death" );

	wait( 21 );

	self kill();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

move_door_clip()
{
	clip = GetEnt( "player_blocker", "script_noteworthy" );
	if( IsDefined( clip ) )
	{
		clip connectPaths();
		clip.origin = ( 4198, -560, 340 );
		clip disconnectPaths();
	}
}


//*******************************************************************
//          Rail Kill					                            *
//                                                                  *
//*******************************************************************

//baker needs to be sent somewhere near this start point, like a node by the stairs preferably. 
//Then when the player comes close to where baker is, set the flag Rail01_kill_start and everything will roll.

Rail01_kill_start()
{

	//going to assume there is a level.baker and level.rail_01_opfor, when this guy gets spawned he should get set.
	//he should be a normal actor that can be killed like any other.

	level waittill( "Rail01_kill_start" );

	//enemy = get_living_ai( "fall_guy", "script_noteworthy" );
	enemy_spawner = GetEnt( "balcony_fallguy", "targetname" );
	enemy = enemy_spawner spawn_ai();
	if ( !isDefined( enemy ) )
	{
		return; // Bail out
	}

	baker = level.baker;

	scene = "rail_01";
	enemy.animname = "rail_01_opfor";
	baker.animname = "rail_01_baker";
	enemy.ignoreall = true;
	baker.dontEverShoot = true;
	baker.ignoreall = true;
	baker setFlashbangImmunity( true );
	baker disable_surprise();

	if( !IsAlive( enemy ) )
	{
		flag_set( "rail01_baker_kill_done" );
		return;
	}

	//baker animscripts\utility::actor_goto_node_and_wait_for_notify( "rail01_baker_start", "rail_01_start" );

	//do an animreach to the starting point for the animation.
	animref = GetStruct("melee_rail_01_vignette", "script_noteworthy");
	animref anim_reach( [ baker, enemy ], scene );

	if( IsAlive( enemy ) )
	{
		if( !flag( "rail01_baker_kill_abort" ) ) //not aborted, go for it.
		{
			flag_set( "rail01_baker_kill_started" );
		
			baker thread rail01_baker_kill_enemy_handle_death_during_walkup( enemy, animref );
		
			baker thread rail01_baker_kill_point_of_no_return( scene, enemy );
		
			baker thread rail01_baker_kill_foley();
		
			baker delaycall( 0.1, ::PushPlayer, true );
			enemy delaycall( 0.1, ::PushPlayer, true );
		
			animref thread anim_single( [ baker, enemy ], scene );
		}
		else
		{
			baker SetGoalPos( baker.origin );
			enemy SetGoalPos( enemy.origin );
			enemy.fixednode = false;
		}
	}
	else
	{
		self thread rail01_baker_kill_aborted_dialogue();
	}

	baker.dontEverShoot = undefined;
	baker.ignoreall = false;
	baker setFlashbangImmunity( false );
	baker delaythread( 5, ::enable_surprise );
	baker PushPlayer( false );
	baker set_force_color( "r" );
	baker enable_ai_color(); 
	
	if( flag( "rail01_baker_kill_abort" ) && IsAlive( enemy ) )
	{
		baker.favoriteenemy = enemy;
		enemy waittill( "death" );
		baker.favoriteenemy = undefined;
	}
	
	flag_set( "rail01_baker_kill_done" );
}

rail01_baker_kill_enemy_handle_death_during_walkup( enemy, animref )
{
	level endon( "rail01_baker_kill_committed" );
	
	enemy waittill( "death" );
	
	flag_set( "rail01_baker_kill_walkup_abort" );

	self notify( "stop_animmode" );
	self anim_stopanimscripted();
	animref anim_stopanimscripted();
	
	self thread rail01_baker_kill_aborted_dialogue();
}

rail01_baker_kill_point_of_no_return( scene, enemy )
{
	animation = self GetAnim( scene );
	commit_time = GetNoteTrackTimes( animation, "commit" )[0]; //grab the time of the first note track
	animTime = GetAnimLength( animation );
	commit_wait = animTime * commit_time;
	
	wait( commit_wait );
	
	flag_set( "rail01_baker_kill_committed" );

	wait( animTime - commit_wait );

	if( IsAlive( enemy ) )
	{
		enemy.allowDeath = true;
		enemy.a.nodeath = true;
		enemy set_battlechatter( false );
		enemy kill();
	}
}

rail01_baker_kill_foley()
{
	ent = Spawn( "script_origin", self.origin );
	ent LinkTo( self );
	
	//ent PlaySound( "scn_afcaves_knife_kill_behind" );
	
	flag_wait_any( "rail01_baker_kill_abort", "rail01_baker_kill_walkup_abort", "rail01_baker_kill_done" );
	
	ent StopSounds();
	wait( 0.05 );  // or else the sound won't stop
	ent Delete();
}

rail01_baker_kill_aborted_dialogue()
{
	// "Never mind, then."
	//thread radio_dialogue( "afcaves_pri_nevermind" );
}


//*******************************************************************
//                 Rail02 melee vignette	                        *
//                                                                  *
//*******************************************************************

//baker needs to be sent somewhere near this start point, like a node by the stairs preferably. 
//Then when the player comes close to where baker is, set the flag Rail01_kill_start and everything will roll.

Rail02_kill_start()
{

	//going to assume there is a level.baker and level.rail_01_opfor, when this guy gets spawned he should get set.
	//he should be a normal actor that can be killed like any other.

	level waittill( "Rail02_kill_start" );

	enemy = get_living_ai( "fall_guy_2", "script_noteworthy" );
	baker = level.baker;

	scene = "rail_02";
	enemy.animname = "rail_02_opfor";
	baker.animname = "rail_02_baker";
	enemy.ignoreall = true;
	baker.dontEverShoot = true;
	baker.ignoreall = true;
	baker setFlashbangImmunity( true );
	baker disable_surprise();

	if( !IsAlive( enemy ) )
	{
		flag_set( "rail02_baker_kill_done" );
		return;
	}

	//baker animscripts\utility::actor_goto_node_and_wait_for_notify( "rail02_baker_start", "rail_02_start" );

	//do an animreach to the starting point for the animation.
	animref = GetStruct("melee_rail_01_vignette", "script_noteworthy");
	animref anim_reach( [ baker, enemy ], scene );

	if( IsAlive( enemy ) )
	{
		if( !flag( "rail02_baker_kill_abort" ) ) //not aborted, go for it.
		{
			flag_set( "rail02_baker_kill_started" );
		
			baker thread rail02_baker_kill_enemy_handle_death_during_walkup( enemy, animref );
		
			baker thread rail02_baker_kill_point_of_no_return( scene, enemy );
			baker thread rail02_baker_kill_handleknife( scene );
		
			baker thread rail02_baker_kill_foley();
		
			baker delaycall( 0.1, ::PushPlayer, true );
			enemy delaycall( 0.1, ::PushPlayer, true );
		
			animref thread anim_single( [ baker, enemy ], scene );
		}
		else
		{
			baker notify( "new_anim_reach" );  // cancel anim_reach movement
			baker SetGoalPos( baker.origin );
		}
	}
	else
	{
		self thread rail02_baker_kill_aborted_dialogue();
	}

	baker.dontEverShoot = undefined;
	baker.ignoreall = false;
	baker setFlashbangImmunity( false );
	baker delaythread( 5, ::enable_surprise );
	baker PushPlayer( false );
	
	if( flag( "rail02_baker_kill_abort" ) && IsAlive( enemy ) )
	{
		baker.favoriteenemy = enemy;
		enemy waittill( "death" );
		baker.favoriteenemy = undefined;
	}
	
	flag_set( "rail01_baker_kill_done" );
}

rail02_baker_kill_enemy_handle_death_during_walkup( enemy, animref )
{
	level endon( "rail02_baker_kill_committed" );
	
	enemy waittill( "death" );
	
	flag_set( "rail02_baker_kill_walkup_abort" );

	self notify( "stop_animmode" );
	self anim_stopanimscripted();
	animref anim_stopanimscripted();
	
	self thread rail02_baker_kill_aborted_dialogue();
}

rail02_baker_kill_point_of_no_return( scene, enemy )
{
	animation = self GetAnim( scene );
	commit_time = GetNoteTrackTimes( animation, "commit" )[0]; //grab the time of the first note track
	animTime = GetAnimLength( animation );
	commit_wait = animTime * commit_time;
	
	wait( commit_wait );
	
	flag_set( "rail02_baker_kill_committed" );

	wait( animTime - commit_wait );

	if( IsAlive( enemy ) )
	{
		enemy.allowDeath = true;
		enemy.a.nodeath = true;
		enemy set_battlechatter( false );
		enemy kill();
	}
}

rail02_baker_kill_handleknife( scene )
{
	knifemodel = "weapon_parabolic_knife";
	linktag = "tag_inhand";
	
	animation = self GetAnim( scene );
	animTime = GetAnimLength( animation );

	detachWait = animTime * GetNoteTrackTimes( animation, "detatch" )[0]; //not sure if we need this...
	stabWait = animTime * GetNoteTrackTimes( animation, "stab" )[0];
	
	startTime = GetTime();

	self thread rail02_baker_kill_bloodfx( stabWait );
	
	self waittillmatch( "custom_animmode", "knife pullout" );
	self Attach( knifemodel, linktag );
	
	waitTime = detachWait - ( GetTime() - startTime )/1000;
	flag_wait_or_timeout( "rail02_baker_kill_walkup_abort", waitTime );
	
	self Detach( knifemodel, linktag );
}

rail02_baker_kill_bloodfx( stabWaitTime )
{
	level endon( "rail02_baker_kill_walkup_abort" );
	
	bloodfx = getfx( "knife_stab" );
	fxTag = "tag_knife_fx";
	
	wait( stabWaitTime );
	PlayFX( bloodfx, level._price GetTagOrigin( fxTag ) );
}

rail02_baker_kill_foley()
{
	ent = Spawn( "script_origin", self.origin );
	ent LinkTo( self );
	
	//ent PlaySound( "scn_afcaves_knife_kill_behind" );
	
	flag_wait_any( "rail02_baker_kill_abort", "rail02_baker_kill_walkup_abort", "rail02_baker_kill_done" );
	
	ent StopSounds();
	wait( 0.05 );  // or else the sound won't stop
	ent Delete();
}

rail02_baker_kill_aborted_dialogue()
{
	// "Never mind, then."
	//thread radio_dialogue( "afcaves_pri_nevermind" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//Light_swing vignette
light_swing_spawn()
{

	light_swing();

}

light_swing()
{

	node = getstruct("vignette_light_swing", "script_noteworthy");

	light_swing = spawn_anim_model("light_swing");
	
	//apm: turn on the fx spotlight
	thread maps\nx_exfil_fx::turn_on_swinging_light_fx(	light_swing );

	guys = [];
	guys["light_swing"] = light_swing;

	node anim_single(guys, "light_swing");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


check_for_room_secured( guys )
{
	while( 1 )
	{
		count = 0;
		for( index = 0; index < guys.size; index++ )
		{
			if( IsAlive( guys[index] ) )
			{
				break;
			}
			count++;
		}

		if( count == guys.size )
		{
			break;
		}
		wait( 0.5 );
	}
	self notify( "room_secured" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// tagMJS<NOTE> looks like this func is deprecated...
ally_casual_kill_out()
{
	self.dontmelee = true;
	self.moveplaybackrate = 0.75;

	flag_wait( "hallway_start_walk" );

	// get Baker to next node for final door kick
	self set_goal_node_targetname( "final_node" );

	self thread radio_dialogue( "exf_ovl_hall_raptor2inpos" );

	grenade_hallway_troops = GetEntArray( "grenade_hallway_troops", "script_noteworthy" );
	foreach ( guy in grenade_hallway_troops )
	{
		if ( IsAlive( guy ) )
		{
			//self cqb_aim( guy );
			wait 0.3;
			magicbullet( self.weapon, self gettagorigin( "tag_flash" ), guy getShootAtPos() );
			guy kill( self.origin, self );
			wait 1.0;
		}
	} 

	self enable_cqbwalk();

	// need to wait till all hallway enemies are dead
	self waittill( "room_secured" );

/*
	// get our important locations
	anim_node = getstruct( "vignette_outro_door_kick", "script_noteworthy");

	// setup Baker correctly
	self.animname = "ally_01";
	self.disableArrivals = true;
	self.ignoreAll = true;

	// gather all our pieces for anims
	guys = [];
	guys["ally_01"] = self;

	// lets get Baker to the correct location
	anim_node anim_reach_solo( self, "outro_door_kick" );

	// get Baker ready for final trigger
	anim_node anim_first_frame_solo( self, "outro_door_kick" );
*/

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

activate_final_objective()
{
	flag_wait( "final_objective" );

	use_trigger = GetEnt( "trigger_use_target", "targetname" );
	if( IsDefined( use_trigger ) )
	{
		Objective_OnAdditionalEntity( obj( "obj_get_to_exfil" ), 1, use_trigger );
		Objective_SetPointerTextOverride( obj( "obj_get_to_exfil" ), &"NX_EXFIL_BREACH_OBJECTIVE" );
		use_trigger thread setup_use_trigger_final_anim();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

setup_use_trigger_final_anim()
{
	self SetHintString( &"NX_EXFIL_BREACH_PROMPT" );

	self waittill( "trigger" );

	self MakeUnusable();

	//lets play our anim
	outro_door_kick_spawn();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
civ_run_away_spawn()
{
	wait(9);
	civ_a = vignette_actor_spawn("civ_a", "civ_a"); //"value" (kvp), "anim_name"
	civ_b = vignette_actor_spawn("civ_b", "civ_b"); //"value" (kvp), "anim_name"
	civ_c = vignette_actor_spawn("civ_c", "civ_c"); //"value" (kvp), "anim_name"
	civ_d = vignette_actor_spawn("civ_d", "civ_d"); //"value" (kvp), "anim_name"
	civ_e = vignette_actor_spawn("civ_e", "civ_e"); //"value" (kvp), "anim_name"
	civ_f = vignette_actor_spawn("civ_f", "civ_f"); //"value" (kvp), "anim_name"
	civ_g = vignette_actor_spawn("civ_g", "civ_g"); //"value" (kvp), "anim_name"
	civ_h = vignette_actor_spawn("civ_h", "civ_h"); //"value" (kvp), "anim_name"
	civ_j = vignette_actor_spawn("civ_j", "civ_j"); //"value" (kvp), "anim_name"
	civ_k = vignette_actor_spawn("civ_k", "civ_k"); //"value" (kvp), "anim_name"

	civ_run_away(civ_a, civ_b, civ_c, civ_d, civ_e, civ_f, civ_g, civ_h, civ_j, civ_k);

	civ_a vignette_actor_delete();
	civ_b vignette_actor_delete();
	civ_c vignette_actor_delete();
	civ_d vignette_actor_delete();
	civ_e vignette_actor_delete();
	civ_f vignette_actor_delete();
	civ_g vignette_actor_delete();
	civ_h vignette_actor_delete();
	civ_j vignette_actor_delete();
	civ_k vignette_actor_delete();
}

civ_run_away(civ_a, civ_b, civ_c, civ_d, civ_e, civ_f, civ_g, civ_h, civ_j, civ_k)
{

	node = getstruct("civ_run_away", "script_noteworthy");


	guys = [];
	guys["civ_a"] = civ_a;
	guys["civ_b"] = civ_b;
	guys["civ_c"] = civ_c;
	guys["civ_d"] = civ_d;
	guys["civ_e"] = civ_e;
	guys["civ_f"] = civ_f;
	guys["civ_g"] = civ_g;
	guys["civ_h"] = civ_h;
	guys["civ_j"] = civ_j;
	guys["civ_k"] = civ_k;

	node anim_single(guys, "civ_run_away");

}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
