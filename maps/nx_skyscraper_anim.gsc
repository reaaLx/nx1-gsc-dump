//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Anim Support													**
//                                                                          **
//    Created: DATE - CREATOR												**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_nx_vignette_util;

STOP_HEADER_SEC = .1;
HINT_TIME_SEC = 4;
HINT_TIME_INCREMENT_SEC = 4;

#using_animtree("generic_human"); 

main()
{

	level._scr_animtree[ "civilian" ] 								 		= #animtree;
	level._scr_model[ "civilian" ][ 0 ]								 		= "body_complete_civilian_suit_male_1";
	// level._scr_model[ "civilian" ][ 1 ]								 		= "body_complete_civilian_suit_female_1";

	generic_human();
	player_anims();
	script_models();
	vehicles();
	civilian_walk_loops();
	civilian_stand_loops();
	dialog();
	thread vignettes();
}

vignettes()
{
	level thread vignette_register( ::outelevator, "outelevator_fg" );
	// Commented out by design
	//level thread vignette_register( ::rappel_jump_spawn, "flag_rappel_jump" );
	level thread vignette_register( ::rappel_swing_jump_spawn, "flag_swing_slide" );
	//level thread vignette_register( ::rappel_bakersign_spawn, "flag_bakersign" );
	// Commented out by design
	//level thread vignette_register( ::rappel_baker_section_01_spawn, "flag_baker_section_01" );
	//level thread vignette_register( ::rappel_baker_section_02_spawn, "flag_baker_section_02" );
	//level thread vignette_register( ::rappel_baker_section_03_spawn, "flag_baker_section_03" );
	//level thread vignette_register( ::rappel_bakerwindow_spawn, "flag_bakerwindow" );
	level thread vignette_register( ::get_up, "flag_getup" );
	level thread vignette_register( ::halon_gas_mask_spawn, "flag_script_halon_gas_mask" );
	level thread vignette_register( ::lab_exit_stairs_spawn, "flag_lab_exit_stairs" );
	level thread vignette_register( ::lab_exit_stairs_corner_spawn, "flag_lab_exit_stairs_corner" );	
	//level thread vignette_register( ::elevator_shaft_part1_spawn, "flag_elevator_shaft" );
	level thread vignette_register( ::landing_pad_vtol_disembark_spawn, "flag_landing_pad_vtol_disembark" );
	level thread vignette_register( ::landing_pad_vtol_spawn, "flag_landing_pad_vtol" );
	//level thread vignette_register( ::xray_kill, "vignette_xraykill" );
	level thread vignette_register( ::landing_pad_window, "flag_landing_pad_window" );
	level thread vignette_register( ::landing_pad_climbjump_ally, "flag_landing_pad_climbjump_ally" );
	level thread vignette_register( ::landing_pad_climbjump_player, "flag_landing_pad_climbjump_player" );
	level thread vignette_register( ::landing_pad_window_player, "landing_pad_window_open" );
	level thread vignette_register( ::landing_pad_edgeclimb, "flag_landing_pad_edgeclimb" );
	level thread vignette_register( ::lab_stealth_kill_spawn, "vignette_lab_stealth_kill" );
	level thread vignette_register( ::red_disembark_spawn, "flag_elevator_red_disembark" );
	level thread vignette_register( ::uav_crash_spawn, "flag_uav_crash" );
	level thread vignette_register( ::atrium_crash_spawn, "flag_atriumcrash" );
	level thread vignette_register( ::intro_ride, "flag_intro_ride" );
	//level thread vignette_register( ::lobby_airlock_spawn, "flag_lobby_airlock" );
	//level thread vignette_register( ::lobby_walk_spawn, "flag_lobby_walk" );
	level thread vignette_register( ::security_baker_spawn, "flag_security_baker" );
	level thread vignette_register( ::securitypoint_civilian_spawn, "flag_security_baker" );
	level thread vignette_register( ::security_guard_talks_to_fp, "flag_security_talks_to_fp" );

	// **** Requested to disable vault anims for ATVI playday (BMarv 10/7) *****
	//level thread vignette_register( ::vault_holotable_spawn, "flag_vault_holo_p1" );
	//level thread vignette_register( ::vault_holotable_p2_spawn, "flag_vault_holo_p2" );
	//level thread vignette_register( ::vault_entrance_spawn, "flag_vault_entrance" );

	// level thread vignette_register( ::uav_crash_p2_spawn, "flag" );
	// level thread vignette_register( ::uav_crash_idle_spawn, "flag" );
	// level thread vignette_register( ::uav_crash_p2_idle_spawn, "flag" );
	// level thread vignette_register( ::uav_crash_p3_spawn, "flag" );

}

dialog()
{
	level._scr_sound[ "ally_01" ][ "sky_bak_driveup_retinalmasks" ] = "sky_bak_driveup_retinalmasks";
	level._scr_sound[ "ally_01" ][ "sky_bak_driveup_gotime" ] = "sky_bak_driveup_gotime";
	level._scr_sound[ "ally_01" ][ "sky_bak_driveup_thanksotherside" ] = "sky_bak_driveup_thanksotherside";
	level._scr_sound[ "ally_01" ][ "sky_bak_lobby_stopsightseeing" ] = "sky_bak_lobby_stopsightseeing";
	level._scr_sound[ "ally_01" ][ "sky_bak_lobby_getbackhere" ] = "sky_bak_lobby_getbackhere";
	level._scr_sound[ "ally_01" ][ "sky_bak_lobby_whereyougoing" ] = "sky_bak_lobby_whereyougoing";
	level._scr_sound[ "ally_01" ][ "sky_bak_lobby_compromised" ] = "sky_bak_lobby_compromised";
	level._scr_sound[ "ally_01" ][ "sky_bak_lobby_staycool" ] = "sky_bak_lobby_staycool";
	level._scr_sound[ "ally_01" ][ "sky_bak_lobby_security" ] = "sky_bak_lobby_security";
	level._scr_sound[ "ally_01" ][ "sky_bak_lobby_lookinhere" ] = "sky_bak_lobby_lookinhere";
	level._scr_sound[ "ally_01" ][ "sky_bak_lobby_airport" ] = "sky_bak_lobby_airport";
	level._scr_sound[ "ally_01" ][ "sky_bak_lobby_easypart" ] = "sky_bak_lobby_easypart";
	level._scr_sound[ "ally_01" ][ "sky_bak_lobby_enteringelevator" ] = "sky_bak_lobby_enteringelevator";
	level._scr_sound[ "ally_01" ][ "sky_bak_lobby_getinhere" ] = "sky_bak_lobby_getinhere";
	level._scr_sound[ "ally_01" ][ "sky_bak_elevator_securitycameras" ] = "sky_bak_elevator_securitycameras";
	level._scr_sound[ "ally_01" ][ "sky_bak_elevator_iseeit" ] = "sky_bak_elevator_iseeit";
	level._scr_sound[ "ally_01" ][ "sky_bak_elevator_suitup" ] = "sky_bak_elevator_suitup";
	level._scr_sound[ "ally_01" ][ "sky_bak_shaft_watchstep" ] = "sky_bak_shaft_watchstep";
	level._scr_sound[ "ally_01" ][ "sky_bak_shaft_herecomesride" ] = "sky_bak_shaft_herecomesride";
	level._scr_sound[ "ally_01" ][ "sky_bak_shaft_jumpnow" ] = "sky_bak_shaft_jumpnow";
	level._scr_sound[ "ally_01" ][ "sky_bak_shaft_readytojumpagain" ] = "sky_bak_shaft_readytojumpagain";
	level._scr_sound[ "ally_01" ][ "sky_bak_shaft_getreadytohookup" ] = "sky_bak_shaft_getreadytohookup";
	level._scr_sound[ "ally_01" ][ "sky_bak_shaft_securityshaft" ] = "sky_bak_shaft_securityshaft";
	level._scr_sound[ "ally_01" ][ "sky_bak_shaft_uselancer" ] = "sky_bak_shaft_uselancer";
	level._scr_sound[ "ally_01" ][ "sky_bak_halltowindow_nearlythere" ] = "sky_bak_halltowindow_nearlythere";
	level._scr_sound[ "ally_01" ][ "sky_bak_halltowindow_makingexit" ] = "sky_bak_halltowindow_makingexit";
	level._scr_sound[ "ally_01" ][ "sky_bak_halltowindow_therewego" ] = "sky_bak_halltowindow_therewego";
	level._scr_sound[ "ally_01" ][ "sky_bak_labent_uavcoming" ] = "sky_bak_labent_uavcoming";
	level._scr_sound[ "ally_01" ][ "sky_bak_labent_cover" ] = "sky_bak_labent_cover";
	level._scr_sound[ "ally_01" ][ "sky_bak_labent_anotheruav" ] = "sky_bak_labent_anotheruav";
	level._scr_sound[ "ally_01" ][ "sky_bak_labent_cleartomove" ] = "sky_bak_labent_cleartomove";
	level._scr_sound[ "ally_01" ][ "sky_bak_labent_takeoutguards" ] = "sky_bak_labent_takeoutguards";
	level._scr_sound[ "ally_01" ][ "sky_bak_labent_followme" ] = "sky_bak_labent_followme";
	level._scr_sound[ "ally_01" ][ "sky_bak_labent_patrolcoming" ] = "sky_bak_labent_patrolcoming";
	level._scr_sound[ "ally_01" ][ "sky_bak_labent_yourcall" ] = "sky_bak_labent_yourcall";
	level._scr_sound[ "ally_01" ][ "sky_bak_labent_letsroll" ] = "sky_bak_labent_letsroll";
	level._scr_sound[ "ally_01" ][ "sky_bak_labent_wtf" ] = "sky_bak_labent_wtf";
	level._scr_sound[ "ally_01" ][ "sky_bak_labent_monkeys" ] = "sky_bak_labent_monkeys";
	level._scr_sound[ "ally_01" ][ "sky_bak_labex_weaponshot" ] = "sky_bak_labex_weaponshot";
	level._scr_sound[ "ally_01" ][ "sky_bak_labex_securitydoors" ] = "sky_bak_labex_securitydoors";
	level._scr_sound[ "ally_01" ][ "sky_bak_labex_xrayshootmotor" ] = "sky_bak_labex_xrayshootmotor";
	level._scr_sound[ "ally_01" ][ "sky_bak_lab2vault_stayfrosty" ] = "sky_bak_lab2vault_stayfrosty";
	level._scr_sound[ "ally_01" ][ "sky_bak_lab2vault_inhere" ] = "sky_bak_lab2vault_inhere";
	level._scr_sound[ "ally_01" ][ "sky_bak_lab2vault_staylow" ] = "sky_bak_lab2vault_staylow";
	level._scr_sound[ "ally_01" ][ "sky_bak_lab2vault_teamastatus" ] = "sky_bak_lab2vault_teamastatus";
	level._scr_sound[ "ally_01" ][ "sky_bak_lab2vault_radiosilence" ] = "sky_bak_lab2vault_radiosilence";
	level._scr_sound[ "ally_01" ][ "sky_bak_vault_affirmative" ] = "sky_bak_vault_affirmative";
	level._scr_sound[ "ally_01" ][ "sky_bak_vault_grabthatthing" ] = "sky_bak_vault_grabthatthing";
	level._scr_sound[ "ally_01" ][ "sky_bak_halon_pullhalon" ] = "sky_bak_halon_pullhalon";
	level._scr_sound[ "ally_01" ][ "sky_bak_halon_getdownintogas" ] = "sky_bak_halon_getdownintogas";
	level._scr_sound[ "ally_01" ][ "sky_bak_halon_staylow" ] = "sky_bak_halon_staylow";
	level._scr_sound[ "ally_01" ][ "sky_bak_halon_makeittodoor" ] = "sky_bak_halon_makeittodoor";
	level._scr_sound[ "ally_01" ][ "sky_bak_halon_usexray" ] = "sky_bak_halon_usexray";
	level._scr_sound[ "ally_01" ][ "sky_bak_halon_snipers" ] = "sky_bak_halon_snipers";
	level._scr_sound[ "ally_01" ][ "sky_bak_halon_thisway" ] = "sky_bak_halon_thisway";
	level._scr_sound[ "ally_01" ][ "sky_bak_labent_2tangosxray" ] = "sky_bak_labent_2tangosxray";
	level._scr_sound[ "ally_01" ][ "sky_bak_labent_splitup" ] = "sky_bak_labent_splitup";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_gettocover" ] = "sky_bak_vtol_gettocover";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_atexfil" ] = "sky_bak_vtol_atexfil";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_coverme" ] = "sky_bak_vtol_coverme";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_vtolincoming" ] = "sky_bak_vtol_vtolincoming";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_targetingusgetcover" ] = "sky_bak_vtol_targetingusgetcover";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_needkillsatclearance" ] = "sky_bak_vtol_needkillsatclearance";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_soonerthebetter" ] = "sky_bak_vtol_soonerthebetter";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_keepmovingup" ] = "sky_bak_vtol_keepmovingup";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_anytimeisgood" ] = "sky_bak_vtol_anytimeisgood";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_getbehindpillar" ] = "sky_bak_vtol_getbehindpillar";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_keepthepillarbetween" ] = "sky_bak_vtol_keepthepillarbetween";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_lasevtol" ] = "sky_bak_vtol_lasevtol";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_readyon3" ] = "sky_bak_vtol_readyon3";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_now" ] = "sky_bak_vtol_now";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_waytogo" ] = "sky_bak_vtol_waytogo";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_fuuu" ] = "sky_bak_vtol_fuuu";
	level._scr_sound[ "ally_01" ][ "sky_bak_rappel_findplacehookup" ] = "sky_bak_rappel_findplacehookup";
	level._scr_sound[ "ally_01" ][ "sky_bak_rappel_hookuphere" ] = "sky_bak_rappel_hookuphere";
	level._scr_sound[ "ally_01" ][ "sky_bak_rappel_uav" ] = "sky_bak_rappel_uav";
	level._scr_sound[ "ally_01" ][ "sky_bak_elev_full" ] = "sky_bak_elev_full";
	level._scr_sound[ "ally_01" ][ "sky_bak_halltowindow_shaft" ] = "sky_bak_halltowindow_shaft";
	level._scr_sound[ "ally_01" ][ "sky_bak_halltowindow_grunt" ] = "sky_bak_halltowindow_grunt";
	level._scr_sound[ "ally_01" ][ "sky_bak_halltowindow_disappointing" ] = "sky_bak_halltowindow_disappointing";
	level._scr_sound[ "ally_01" ][ "sky_bak_halltowindow_stayalert" ] = "sky_bak_halltowindow_stayalert";
	level._scr_sound[ "ally_01" ][ "sky_bak_halltowindow_3tangos" ] = "sky_bak_halltowindow_3tangos";
	level._scr_sound[ "ally_01" ][ "sky_bak_halltowindow_goodstart" ] = "sky_bak_halltowindow_goodstart";
	level._scr_sound[ "ally_01" ][ "sky_bak_halon_situation" ] = "sky_bak_halon_situation";
	level._scr_sound[ "ally_01" ][ "sky_bak_halon_bigdaddy" ] = "sky_bak_halon_bigdaddy";
	level._scr_sound[ "ally_01" ][ "sky_bak_halon_letsgo" ] = "sky_bak_halon_letsgo";
	level._scr_sound[ "ally_01" ][ "sky_bak_labent_mark321" ] = "sky_bak_labent_mark321";
	level._scr_sound[ "ally_01" ][ "sky_bak_labex_takepoint" ] = "sky_bak_labex_takepoint";
	level._scr_sound[ "ally_01" ][ "sky_bak_lab2vault_toldyoutogo" ] = "sky_bak_lab2vault_toldyoutogo";
	level._scr_sound[ "ally_01" ][ "sky_bak_lab2vault_highroad" ] = "sky_bak_lab2vault_highroad";
	level._scr_sound[ "ally_01" ][ "sky_bak_lab2vault_subduescientist" ] = "sky_bak_lab2vault_subduescientist";
	level._scr_sound[ "ally_01" ][ "sky_bak_pad_jetwash" ] = "sky_bak_pad_jetwash";
	level._scr_sound[ "ally_01" ][ "sky_bak_pad_dontlookdown" ] = "sky_bak_pad_dontlookdown";
	level._scr_sound[ "ally_01" ][ "sky_bak_pad_climbupkillguards" ] = "sky_bak_pad_climbupkillguards";
	level._scr_sound[ "ally_01" ][ "sky_bak_pad_oneontheleft" ] = "sky_bak_pad_oneontheleft";
	level._scr_sound[ "ally_01" ][ "sky_bak_pad_ornot" ] = "sky_bak_pad_ornot";
	level._scr_sound[ "ally_01" ][ "sky_bak_pad_shapeup" ] = "sky_bak_pad_shapeup";
	level._scr_sound[ "ally_01" ][ "sky_bak_pad_cigarettes" ] = "sky_bak_pad_cigarettes";
	level._scr_sound[ "ally_01" ][ "sky_bak_pad_highwireacts" ] = "sky_bak_pad_highwireacts";
	level._scr_sound[ "ally_01" ][ "sky_bak_shaft_grunts" ] = "sky_bak_shaft_grunts";
	level._scr_sound[ "ally_01" ][ "sky_bak_shaft_overhere" ] = "sky_bak_shaft_overhere";
	level._scr_sound[ "ally_01" ][ "sky_bak_shaft_jumpdownonit" ] = "sky_bak_shaft_jumpdownonit";
	level._scr_sound[ "ally_01" ][ "sky_bak_shaft_followmylead" ] = "sky_bak_shaft_followmylead";
	level._scr_sound[ "ally_01" ][ "sky_bak_shaft_getdown" ] = "sky_bak_shaft_getdown";
	level._scr_sound[ "ally_01" ][ "sky_bak_shaft_jumptonextone" ] = "sky_bak_shaft_jumptonextone";
	level._scr_sound[ "ally_01" ][ "sky_bak_shaft_moreheadsup" ] = "sky_bak_shaft_moreheadsup";
	level._scr_sound[ "ally_01" ][ "sky_bak_shaft_lookthroughscope" ] = "sky_bak_shaft_lookthroughscope";
	level._scr_sound[ "ally_01" ][ "sky_bak_shaft_illtakecareofhim" ] = "sky_bak_shaft_illtakecareofhim";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_covermewhileitarget" ] = "sky_bak_vtol_covermewhileitarget";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_grabtargetdevice" ] = "sky_bak_vtol_grabtargetdevice";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_markthetarget" ] = "sky_bak_vtol_markthetarget";
	level._scr_sound[ "ally_01" ][ "sky_bak_vtol_wheresoursat" ] = "sky_bak_vtol_wheresoursat";
	level._scr_sound[ "ally_01" ][ "sky_bak_generic_holdup" ] = "sky_bak_generic_holdup";
	level._scr_sound[ "ally_01" ][ "sky_bak_generic_hangon" ] = "sky_bak_generic_hangon";
	level._scr_sound[ "ally_01" ][ "sky_bak_generic_waithere" ] = "sky_bak_generic_waithere";
	level._scr_sound[ "ally_01" ][ "sky_bak_generic_comeon" ] = "sky_bak_generic_comeon";
	level._scr_sound[ "ally_01" ][ "sky_bak_generic_letsmove" ] = "sky_bak_generic_letsmove";
	level._scr_sound[ "ally_01" ][ "sky_bak_generic_nice" ] = "sky_bak_generic_nice";
	level._scr_sound[ "ally_01" ][ "sky_bak_generic_perfect" ] = "sky_bak_generic_perfect";
	level._scr_sound[ "ally_01" ][ "sky_bak_generic_thisway" ] = "sky_bak_generic_thisway";
	level._scr_sound[ "ally_01" ][ "sky_bak_generic_gogogo" ] = "sky_bak_generic_gogogo";
	level._scr_sound[ "ally_01" ][ "sky_bak_generic_keepmoving" ] = "sky_bak_generic_keepmoving";
	level._scr_sound[ "ally_01" ][ "sky_bak_generic_hurryup" ] = "sky_bak_generic_hurryup";
	level._scr_sound[ "guard" ][ "sky_grd_lobby_lookintoscreen" ] = "sky_grd_lobby_lookintoscreen";
	level._scr_sound[ "guard" ][ "sky_grd_lobby_thankyou" ] = "sky_grd_lobby_thankyou";
	level._scr_sound[ "driver" ][ "sky_lam_driveup_thistheplace" ] = "sky_lam_driveup_thistheplace";
	level._scr_sound[ "driver" ][ "sky_lam_driveup_teambinposition" ] = "sky_lam_driveup_teambinposition";
	level._scr_sound[ "driver" ][ "sky_lam_driveup_signalforexfil" ] = "sky_lam_driveup_signalforexfil";
	level._scr_sound[ "driver" ][ "sky_lam_driveup_goodluck" ] = "sky_lam_driveup_goodluck";
	level._scr_radio[ "sky_mas_elevator_hello" ] = "sky_mas_elevator_hello";
	level._scr_radio[ "sky_mas_elevator_welcome" ] = "sky_mas_elevator_welcome";
	level._scr_radio[ "sky_mas_elevator_mynameis" ] = "sky_mas_elevator_mynameis";
	level._scr_radio[ "sky_mas_elevator_tallestbuilding" ] = "sky_mas_elevator_tallestbuilding";
	level._scr_radio[ "sky_mas_elevator_weighs" ] = "sky_mas_elevator_weighs";
	level._scr_radio[ "sky_mas_elevator_population" ] = "sky_mas_elevator_population";
	level._scr_radio[ "sky_mas_elevator_observationlounge" ] = "sky_mas_elevator_observationlounge";
	level._scr_radio[ "sky_mas_elevator_floorcomingup" ] = "sky_mas_elevator_floorcomingup";
	level._scr_radio[ "sky_mas_elevator_thanks" ] = "sky_mas_elevator_thanks";
	level._scr_radio[ "sky_mas_elevator_havelovelyday" ] = "sky_mas_elevator_havelovelyday";
	level._scr_radio[ "sky_satcom_vtol_designatetarget" ] = "sky_satcom_vtol_designatetarget";
	level._scr_radio[ "sky_teama_outro_exfiloutside" ] = "sky_teama_outro_exfiloutside";
	level._scr_radio[ "sky_teama_outro_letsgonow" ] = "sky_teama_outro_letsgonow";
	level._scr_radio[ "sky_teama_lobby_inposition" ] = "sky_teama_lobby_inposition";
	level._scr_radio[ "sky_teama_lobby_meetyouabove" ] = "sky_teama_lobby_meetyouabove";
	level._scr_radio[ "sky_teama_elevator_decrypting" ] = "sky_teama_elevator_decrypting";
	level._scr_radio[ "sky_teama_elevator_bepatient" ] = "sky_teama_elevator_bepatient";
	level._scr_radio[ "sky_teama_elevator_thereitis" ] = "sky_teama_elevator_thereitis";
	level._scr_radio[ "sky_teama_shaft_elevatorshaft3" ] = "sky_teama_shaft_elevatorshaft3";
	level._scr_radio[ "sky_teama_shaft_elevatoryourway" ] = "sky_teama_shaft_elevatoryourway";
	level._scr_radio[ "sky_teama_shaft_nicework" ] = "sky_teama_shaft_nicework";
	level._scr_radio[ "sky_teama_shaft_guarddoor" ] = "sky_teama_shaft_guarddoor";
	level._scr_radio[ "sky_teama_halltowindow_officebelow" ] = "sky_teama_halltowindow_officebelow";
	level._scr_radio[ "sky_teama_halltwowindow_thruwindow" ] = "sky_teama_halltwowindow_thruwindow";
	level._scr_radio[ "sky_teama_halltowindow_securityfreq" ] = "sky_teama_halltowindow_securityfreq";
	level._scr_radio[ "sky_teama_halltowindow_gridinhud" ] = "sky_teama_halltowindow_gridinhud";
	level._scr_radio[ "sky_teama_lab2vault_inposition" ] = "sky_teama_lab2vault_inposition";
	level._scr_radio[ "sky_teama_vault_objective" ] = "sky_teama_vault_objective";
	level._scr_radio[ "sky_teama_vault_hostilesinbound" ] = "sky_teama_vault_hostilesinbound";
	level._scr_radio[ "sky_teama_vtol_onthehorn" ] = "sky_teama_vtol_onthehorn";
	level._scr_radio[ "sky_teama_vtol_hangonabit" ] = "sky_teama_vtol_hangonabit";
	level._scr_radio[ "sky_teama_vtol_uplink" ] = "sky_teama_vtol_uplink";
	level._scr_radio[ "sky_teama_halon_problem" ] = "sky_teama_halon_problem";
	level._scr_radio[ "sky_teama_halon_gunship" ] = "sky_teama_halon_gunship";
	level._scr_radio[ "sky_teama_halon_becareful" ] = "sky_teama_halon_becareful";
	level._scr_radio[ "sky_teama_shaft_couldnthandle" ] = "sky_teama_shaft_couldnthandle";
	level._scr_radio[ "sky_teama_vtol_60seconds" ] = "sky_teama_vtol_60seconds";
	level._scr_radio[ "sky_bak_rappel_gogogo" ] = "sky_bak_rappel_gogogo";
	level._scr_radio[ "sky_bak_rappel_followme" ] = "sky_bak_rappel_followme";
	level._scr_radio[ "sky_bak_rappel_letsgo" ] = "sky_bak_rappel_letsgo";
	level._scr_radio[ "sky_bak_rappel_onmysix" ] = "sky_bak_rappel_onmysix";
	level._scr_radio[ "sky_bak_rappel_brake" ] = "sky_bak_rappel_brake";
	level._scr_radio[ "sky_bak_rappel_brakebrake" ] = "sky_bak_rappel_brakebrake";
	level._scr_radio[ "sky_bak_rappel_slowdown" ] = "sky_bak_rappel_slowdown";
	level._scr_radio[ "sky_bak_rappel_dropyourspeed" ] = "sky_bak_rappel_dropyourspeed";
	level._scr_radio[ "sky_bak_rappel_braking" ] = "sky_bak_rappel_braking";
	level._scr_radio[ "sky_bak_rappel_getthefuckoutofhere" ] = "sky_bak_rappel_getthefuckoutofhere";
	level._scr_radio[ "sky_bak_rappel_weremoving" ] = "sky_bak_rappel_weremoving";
	level._scr_radio[ "sky_bak_rappel_wereleaving" ] = "sky_bak_rappel_wereleaving";
	level._scr_radio[ "sky_bak_rappel_cmon" ] = "sky_bak_rappel_cmon";
	level._scr_radio[ "sky_bak_rappel_fuckingmove" ] = "sky_bak_rappel_fuckingmove";
}

generic_human()
{
	// Elevator Exit
	//level._scr_anim[ "ally_01" ][ "outelevator" ] = %nx_tp_ss_outelevator_baker_01;
	level._scr_anim[ "ally_01" ][ "elevator_out_intro" ] = %nx_tp_skyscraper_elevator_out_baker_01;
	level._scr_anim[ "ally_01" ][ "elevator_out_idle" ][0] = %nx_tp_skyscraper_elevator_out_baker_idle;
	level._scr_anim[ "ally_01" ][ "elevator_out_lift" ] = %nx_tp_skyscraper_elevator_out_baker_lift;
	level._scr_anim[ "ally_01" ][ "elevator_ontop_idle" ][0] = %nx_tp_skyscraper_elevator_ontop_baker_idle;

	//Player Body
	level._scr_animtree[ "player_body" ] 								 		= #animtree;
	level._scr_model[ "player_body" ][ 0 ]								 		= "nx_us_specops_body_assault_a";
	level._scr_anim[ "player_body" ][ "elevator_out_lift" ] 					= %nx_tp_skyscraper_elevator_out_player_lift;
	level._scr_anim[ "player_body" ][ "elevator_shaft1" ] = %nx_tp_skyscraper_elevator_shaft1_playerbody;
	level._scr_anim[ "player_body" ][ "elevator_shafthookup_init" ] = %nx_tp_skyscraper_elevator_shafthookup_init_playerbody;

	// Landing Pad window
	level._scr_anim[ "player_body" ][ "landing_pad_window_player" ] = %nx_tp_skyscraper_landing_pad_window_playerbody;

	// Elevator Shaft
	level._scr_anim[ "ally_01" ][ "elevator_shaft1" ] = %nx_tp_skyscraper_elevator_shaft1_ally;
	level._scr_anim[ "ally_01" ][ "elevator_shaft1_idle" ][0] = %nx_tp_skyscraper_elevator_shaft1_ally_idle;
	level._scr_anim[ "ally_01" ][ "elevator_shaftjump" ] = %nx_tp_skyscraper_elevator_shaftjump_ally;
	level._scr_anim[ "ally_01" ][ "elevator_shaftjump_idle" ][0] = %nx_tp_skyscraper_elevator_shaftjump_ally_idle;
	level._scr_anim[ "ally_01" ][ "elevator_shaftclimb" ] = %nx_tp_skyscraper_elevator_shaftclimb_ally;
	level._scr_anim[ "ally_01" ][ "elevator_shaftclimb_idle" ][0] = %nx_tp_skyscraper_elevator_shaftclimb_ally_idle;
	level._scr_anim[ "ally_01" ][ "elevator_shafthookup" ] = %nx_tp_skyscraper_elevator_shafthookup_ally;
	addNotetrack_customFunction( "ally_01", "player_elevator_dive", ::elevator_shaftdive_player );
	addNotetrack_customFunction( "ally_01", "player_elevator_dive_prompt", ::elevator_shaftdive_player_prompt );
	//addNotetrack_customFunction( "ally_01", "player_elevator_hookup_prompt", ::player_elevator_hookup_prompt );
	addNotetrack_customFunction( "ally_01", "player_elevator_hookup", ::player_elevator_hookup );

	// Temp elevator idle
	level._scr_anim[ "ally_01" ][ "elevator_idle_loop" ][ 0 ] = %nx_tp_skyscraper_elevator_wait_baker;
	level._scr_anim[ "guard" ][ "platform_idle_loop" ][ 0 ] = %casual_stand_idle;

	// Elevator Guard sleep loop
	level._scr_anim[ "elevator_guard" ][ "elevator_guard_sleep" ][ 0 ] = %training_sleeping_in_chair;

	//Lab Stealth Kill
	level._scr_anim[ "vignette_lab_stealth_kill_baker" ][ "lab_stealth_kill" ] = %nx_tp_ss_lab_stealth_kill_baker;
	level._scr_anim[ "vignette_lab_stealth_kill_opfor_02" ][ "lab_stealth_kill" ] = %nx_tp_ss_lab_stealth_kill_opfor_02;
	level._scr_anim[ "vignette_lab_stealth_kill_opfor_01" ][ "lab_stealth_kill" ] = %nx_tp_ss_lab_stealth_kill_opfor_01;
	
	// Rappel Jump
	level._scr_anim[ "ally_01" ][ "rappel_jump" ] = %nx_tp_skyscraper_rappeljump_ally_01;

	// Rappel Swing Slide
	level._scr_anim[ "ally_01" ][ "rappel_swing_jump" ] = %nx_tp_skyscraper_rappelswingslide_ally_01;

	// Halon room melee
	level._scr_animtree[ "halon_guy" ]			 		= #animtree;
	level._scr_model[ "halon_guy" ]						= "nx_ec_lab_body_hazmat_a";
	level._scr_anim[ "ally_01" ][ "halon_melee_guy" ]		= %cornerSdL_melee_winA_attacker;
	level._scr_anim[ "halon_guy" ][ "halon_melee_guy" ]	= %cornerSdL_melee_winA_defender;

	// Rappel Baker Sign
	level._scr_anim[ "ally_01" ][ "rappel_bakersign" ] = %nx_tp_skyscraper_rappel_BakerSign_ally_01;

	// Rappel Baker Section 01
	level._scr_anim[ "ally_01" ][ "rappel_baker_section_01" ] = %nx_tp_skyscraper_rappel_baker_section_01;

	// Rappel Baker Section 02
	level._scr_anim[ "ally_01" ][ "rappel_baker_section_02" ] = %nx_tp_skyscraper_rappel_baker_section_02;

	// Rappel Baker Section 03
	level._scr_anim[ "ally_01" ][ "rappel_baker_section_03" ] = %nx_tp_skyscraper_rappel_baker_section_03;

	// Rappel Baker Window
	level._scr_anim[ "ally_01" ][ "rappel_bakerwindow" ] = %nx_tp_skyscraper_rappel_BakerWindow_ally_01;

	// Get up after UAV floor collapse
	level._scr_anim[ "ally_01" ][ "get_up" ] = %nx_tp_skyscraper_get_up_ally_01;

	// Halon Gas Mask
	level._scr_anim[ "ally_01" ][ "halon_gas_mask" ] = %nx_tp_skyscraper_halon_mask_ally_01;

	// Lab exit stairs
	level._scr_anim[ "ally_01" ][ "lab_exit_stairs" ] = %nx_tp_skyscraper_exit_stairs_ally_01;
	level._scr_anim[ "ally_01" ][ "lab_exit_stairs_corner" ] = %nx_tp_skyscraper_exit_stairs_corner_ally_01;

	// Vault Entrance
	level._scr_anim[ "ally_01" ][ "vault_entrance" ] = %nx_tp_skyscraper_vault_entrance_ally_01;
	level._scr_anim[ "civ_01" ][ "vault_entrance" ] = %nx_tp_skyscraper_vault_entrance_civ_01;
	level._scr_anim[ "civ_02" ][ "vault_entrance" ] = %nx_tp_skyscraper_vault_entrance_civ_02;
	level._scr_anim[ "civ_03" ][ "vault_entrance" ] = %nx_tp_skyscraper_vault_entrance_civ_03;

	// Landing Pad VTOL Disembark
	level._scr_anim[ "civ_01" ][ "landing_pad_vtol_disembark" ] = %nx_tp_skyscraperlanding_pad_vtol_disembark_civ_01;
	level._scr_anim[ "civ_02" ][ "landing_pad_vtol_disembark" ] = %nx_tp_skyscraperlanding_pad_vtol_disembark_civ_02;
	level._scr_anim[ "civ_03" ][ "landing_pad_vtol_disembark" ] = %nx_tp_skyscraperlanding_pad_vtol_disembark_civ_03;

	// Landing Pad VTOL
	level._scr_anim[ "ally_01" ][ "landing_pad_vtol" ] = %nx_tp_skyscraper_landing_pad_vtol_ally_01;

	// xray kill
	level._scr_anim[ "ally_01" ][ "xray_kill_intro" ] = %nx_tp_skyscraper_xraykill_intro;
	level._scr_anim[ "ally_01" ][ "xray_kill_outro" ] = %nx_tp_skyscraper_xraykill_outro;

	// Landing Pad Window
	level._scr_anim[ "ally_01" ][ "landing_pad_window" ] = %nx_tp_skyscraper_landing_pad_window_ally01;
 
	// LandingPad ClimJump Ally
	level._scr_anim[ "ally_01" ][ "landing_pad_climbjump_ally" ] = %nx_tp_skyscraper_landing_pad_climbjump_ally01;

	// Landing Pad Climb Jump Player
	level._scr_anim[ "ally_01" ][ "landing_pad_climbjump_player" ] = %nx_tp_skyscraper_landing_pad_climbjump_player_ally01;

	// Landing Pad Edge Climb
	level._scr_anim[ "ally_01" ][ "landing_pad_edgeclimb" ] = %nx_tp_skyscraper_landing_pad_edgeclimb_ally_01;

	// melee kill scene
	level._scr_anim[ "melee_1" ][ "melee_guy_idle" ][0] 	= %coup_guard2_idle;	
	level._scr_anim[ "ally_01" ][ "melee_kill" ] 				= %ICBM_patrol_knifekill_winner;
	level._scr_anim[ "target" ][ "melee_kill" ] 			= %ICBM_patrol_knifekill_looser;
	level._scr_anim[ "target" ][ "melee_react" ] 			= %patrol_bored_react_look_retreat;

	level._scr_anim[ "ally_01" ][ "landing_pad_melee_kill" ] 				= %parabolic_knifekill_mark;
	level._scr_anim[ "target" ][ "landing_pad_melee_kill" ] 			= %parabolic_knifekill_phoneguy;

	// Doin Business
	level._scr_anim[ "doinbusiness" ][ "doinbusiness_idle" ][0] 	= %laptop_sit_idle_active;	

	// Baker opens door
	level._scr_anim[ "ally_01" ][ "hunted_open_barndoor" ] = 			%hunted_open_barndoor;

	// Elevator Shaft Sequence
	level._scr_anim[ "ally_01" ][ "elevator_wait_baker" ][0] = %nx_tp_skyscraper_elevator_wait_baker;
	level._scr_anim[ "ally_01" ][ "elevator_push" ] = %nx_tp_skyscraper_elevator_push_baker;
	level._scr_anim[ "civ_01" ][ "elevator_push" ] = %nx_tp_skyscraper_elevator_push_civ;

	//Elevator Red Disembark
	level._scr_anim[ "ally_01" ][ "red_disembark" ] = %nx_tp_skyscraper_red_disembark_ally_01;
	level._scr_anim[ "opfor" ][ "red_disembark" ] = %nx_tp_skyscraper_red_disembark_opfor_01;

	//UAV Crash
    level._scr_anim[ "ally_01" ][ "uav_crash" ] = %nx_tp_skyscraper_uav_crash_ally_01;
    level._scr_anim[ "ally_01" ][ "uav_crash_p2" ] = %nx_tp_skyscraper_uav_crash_ally_01_p2;
    level._scr_anim[ "ally_01" ][ "uav_crash_p3" ] = %nx_tp_skyscraper_uav_crash_ally_01_p3;
    level._scr_anim[ "ally_01" ][ "uav_crash_p2_idle" ][0] = %nx_tp_skyscraper_uav_crash_ally_01_p2_idle;
	level._scr_anim[ "ally_01" ][ "uav_crash_idle" ][0] = %nx_tp_skyscraper_uav_crash_ally_01_idle;

	//Atrium Crash
	level._scr_anim[ "ally_01" ][ "atrium_crash" ] = %nx_tp_skyscraper_atrium_crash_baker_01;	

	//Intro Ride
	level._scr_anim[ "ally_01" ][ "intro_ride" ] = %nx_tp_skyscraper_intro_ride_ally_01;
	level._scr_anim[ "driver" ][ "intro_ride" ] = %nx_tp_skyscraper_intro_ride_civ_01;

	//Baker airlock
	// level._scr_anim[ "ally_01" ][ "lobby_airlock" ] = %nx_tp_skyscraper_airlock_ally_01;

	//Lobby Baker Walk
	level._scr_anim[ "ally_01" ][ "lobby_walk" ] = %nx_tp_skyscraper_lobby_walk_ally_01;

	//Security Checkpoint Baker
	level._scr_anim[ "ally_01" ][ "security_baker" ] = %nx_tp_skyscraper_security_baker_01;
	level._scr_anim[ "guard" ][ "security_baker" ] = %nx_tp_skyscraper_security_guard_01;

	//Security Checkpoint Civilian
	level._scr_anim[ "civilian" ][ "securitypoint_civilian" ] = %nx_tp_skyscraper_securitypoint_civ_01;
	level._scr_anim[ "guard" ][ "securitypoint_civilian" ] = %nx_tp_skyscraper_securitypoint_guard_01;

	// Vault Holo Table P1
	level._scr_anim[ "ally_01" ][ "vault_holotable" ] = %nx_tp_skyscraper_vault_servers_ally_01_p1;

	// Vault Holo Table P2
	level._scr_anim[ "ally_01" ][ "vault_holotable_p2" ] = %nx_tp_skyscraper_vault_servers_ally_01_p2;

	// walkup temp anims added by design
	level._scr_anim[ "civilian_argue" ][ "civilian_directions_1_A" ][ 0 ]	 		= %civilian_directions_1_A;
	level._scr_anim[ "security_guard_argue" ][ "civilian_directions_1_B" ][ 0 ]	 	= %civilian_directions_1_B;
	level._scr_anim[ "ally_01" ][ "hunted_dazed_walk_C_limp" ]		= %hunted_dazed_walk_C_limp;

	// Design
	level._scr_anim[ "ally_01" ][ "rappel_setup" ]				 = %launchfacility_a_setup_2_rappel_2;
	level._scr_anim[ "ally_01" ][ "corner_standR_explosion_divedown" ] 	= %corner_standR_explosion_divedown;
	level._scr_anim[ "ally_01" ][ "hunted_pronehide_2_stand_v2" ]		= %hunted_pronehide_2_stand_v2;

	level._scr_anim[ "ally_01" ][ "baker_vtol_melee" ]		= %cornerSdR_melee_winA_attacker;
	level._scr_anim[ "victim" ][ "baker_vtol_melee" ]		= %cornerSdR_melee_winA_defender;

	// motorcycle rider
	level._scr_animtree[ "rider" ] 							 = #animtree;
	level._scr_anim[ "rider" ][ "forward" ][ 0 ]				 = %motorcycle_rider_pose_f;
	level._scr_model[ "rider" ] = "body_complete_civilian_suit_male_1";

	// Hanger room guys
	level._scr_anim[ "sitter" ][ "civilian_sitting_talking_B_1" ][ 0 ] = %civilian_sitting_talking_B_1;
	level._scr_anim[ "sitter" ][ "civilian_sitting_talking_A_1" ][ 0 ] = %civilian_sitting_talking_A_1;
	level._scr_anim[ "sitter" ][ "civilian_sitting_talking_A_2" ][ 0 ] = %civilian_sitting_talking_A_2; 

	// Lab to Vault halon floor anims
	level._scr_anim[ "scientist" ][ "escalator_up_generic_guy_idle" ][ 0 ] = %escalator_up_generic_guy_idle; 
	level._scr_anim[ "scientist" ][ "civilian_directions_2_A_idle" ][ 0 ] = %civilian_directions_2_A_idle;	 
	level._scr_anim[ "scientist" ][ "cliff_guardB_idle" ][ 0 ] = %cliff_guardB_idle;
	level._scr_anim[ "scientist" ][ "laptop_stand_idle" ][ 0 ] = %laptop_stand_idle;

	// Security Guard Talks to FP
	level._scr_anim[ "guard" ][ "security_guard_talks_to_fp" ] = %nx_tp_skyscraper_security_guard_02;

}

civilian_stand_loops()
{
	// STAND LOOPS
	
	//level._scr_anim[ "civilian" ][ "stand_idle" ][ 0 ]	 					= %civilian_stand_idle;
	
	level._scr_anim[ "civilian" ][ "smoking1" ][ 0 ]	 						= %civilian_smoking_A;
	level._scr_anim[ "civilian" ][ "smoking1" ][ 1 ]	 						= %civilian_smoking_A;
	
	level._scr_anim[ "civilian" ][ "smoking2" ][ 0 ]	 						= %civilian_smoking_B;
	level._scr_anim[ "civilian" ][ "smoking2" ][ 1 ]	 						= %civilian_smoking_B;

	level._scr_anim[ "civilian" ][ "info_desk_guard" ][ 0 ]	 						= %guardA_sit_sleeper_idle;
	level._scr_anim[ "civilian" ][ "info_desk_civ" ][ 0 ]	 						= %unarmed_shout_window;

	level._scr_anim[ "civilian" ][ "lunch_1" ][ 0 ]	 						= %civilian_sitting_business_lunch_A_1;
	level._scr_anim[ "civilian" ][ "lunch_2" ][ 0 ]	 						= %civilian_sitting_business_lunch_B_1;

	//level._scr_anim[ "civilian" ][ "texting_stand" ][ 0 ]	 				= %civilian_texting_standing;
	
	//level._scr_anim[ "civilian" ][ "atm" ][ 0 ]	 							= %civilian_atm;
	
	//level._scr_anim[ "civilian" ][ "directions_A" ][ 0 ]	 					= %civilian_directions_1_A;
	
	//level._scr_anim[ "civilian" ][ "directions_B" ][ 0 ]	 					= %civilian_directions_1_B;
	
	//Direction 1 & 2, using two characters, A & B.
	//Direction 1 is loopable, still need PDA for direction 2
	//civilian_directions_2_A
	//civilian_directions_2_B
}

civilian_walk_loops()
{
	three_twitch_weights = [];
	three_twitch_weights[0] = 2;
	three_twitch_weights[1] = 1;
	three_twitch_weights[2] = 1;
	three_twitch_weights[3] = 1;

	level._scr_anim[ "civilian_crazy_walk" ][ "run_noncombat" ][ 0 ]			= %civilian_crazywalker_loop;
	level._scr_anim[ "civilian_crazy_walk" ][ "run_noncombat" ][ 1 ]			= %civilian_crazywalker_twitchA;
	level._scr_anim[ "civilian_crazy_walk" ][ "run_noncombat" ][ 2 ]			= %civilian_crazywalker_twitchB;
	level._scr_anim[ "civilian_crazy_walk" ][ "run_noncombat" ][ 3 ]			= %civilian_crazywalker_twitchC;
	level._scr_anim[ "civilian_crazy_walk" ][ "run_weights" ]				= three_twitch_weights;
	
	weights = [];
	weights[0] = 7;
	weights[1] = 3;
	one_twitch_weights = get_cumulative_weights( weights );
	
	level._scr_anim[ "civilian_cellphone_walk" ][ "run_noncombat" ][ 0 ]		= %civilian_cellphonewalk;
	//level.scr_anim[ "civilian_cellphone_walk" ][ "run_noncombat" ][ 1 ]		= %civilian_cellphonewalk_twitch;
	//level.scr_anim[ "civilian_cellphone_walk" ][ "run_weights" ]			= one_twitch_weights;
	
	level._scr_anim[ "civilian_cellphone_walk" ][ "dodge_left" ]				= %civilian_cellphonewalk_dodge_L;
	level._scr_anim[ "civilian_cellphone_walk" ][ "dodge_right" ]			= %civilian_cellphonewalk_dodge_R;
	
	level._scr_anim[ "civilian_cellphone_walk" ][ "turn_left_90" ]			= %civilian_cellphonewalk_turn_L;
	level._scr_anim[ "civilian_cellphone_walk" ][ "turn_right_90" ]			= %civilian_cellphonewalk_turn_R;
	
	level._scr_anim[ "civilian_soda_walk" ][ "run_noncombat" ][ 0 ]			= %civilian_sodawalk;
	level._scr_anim[ "civilian_soda_walk" ][ "run_noncombat" ][ 1 ]			= %civilian_sodawalk_twitch;
	level._scr_anim[ "civilian_soda_walk" ][ "run_weights" ]					= one_twitch_weights;
	
	level._scr_anim[ "civilian_hurried_walk" ][ "run_noncombat" ][ 0 ]		= %civilian_walk_hurried_1;
	level._scr_anim[ "civilian_hurried_walk" ][ "run_noncombat" ][ 1 ]		= %civilian_walk_hurried_2;
	
	level._scr_anim[ "civilian_nervous_walk" ][ "run_noncombat" ][ 0 ]		= %civilian_walk_nervous;
	
	level._scr_anim[ "civilian_cool_walk" ][ "run_noncombat" ][ 0 ]			= %civilian_walk_cool;
	
	level._scr_anim[ "civilian_paper_walk" ][ "run_noncombat" ][ 0 ]			= %civilian_walk_paper;
	
	level._scr_anim[ "civilian_coffee_walk" ][ "run_noncombat" ][ 0 ]		= %civilian_walk_coffee;
	
	level._scr_anim[ "civilian_backpack_walk" ][ "run_noncombat" ][ 0 ]		= %civilian_walk_backpack;
	level._scr_anim[ "civilian_backpack_walk" ][ "run_noncombat" ][ 1 ]		= %civilian_walk_backpack_twitch;
	level._scr_anim[ "civilian_backpack_walk" ][ "run_weights" ]				= one_twitch_weights;
	
	level._scr_anim[ "civilian_pda_walk" ][ "run_noncombat" ][ 0 ]			= %civilian_walk_pda;
	
	level._scr_anim[ "civilian_briefcase_walk" ][ "run_noncombat" ][ 0 ]		= %civilian_briefcase_walk;
	//level.scr_anim[ "civilian_briefcase_walk" ][ "run_noncombat" ][ 1 ]		= %civilian_briefcase_walk;
	//level.scr_anim[ "civilian_briefcase_walk" ][ "run_noncombat" ][ 2 ]		= %civilian_briefcase_walk;
	//level.scr_anim[ "civilian_briefcase_walk" ][ "run_noncombat" ][ 3 ]		= %civilian_briefcase_walk_shoelace;
	level._scr_anim[ "civilian_briefcase_walk" ][ "dodge_left" ]				= %civilian_briefcase_walk_dodge_L;
	level._scr_anim[ "civilian_briefcase_walk" ][ "dodge_right" ]			= %civilian_briefcase_walk_dodge_R;
	
	level._scr_anim[ "civilian_briefcase_walk" ][ "turn_left_90" ]			= %civilian_briefcase_walk_turn_L;
	level._scr_anim[ "civilian_briefcase_walk" ][ "turn_right_90" ]			= %civilian_briefcase_walk_turn_R;

}

enable_casual_lobby_anims()
{
	// move animations
	animset = [];
	animset[ "sprint" ] = %nx_tp_ss_baker_walk;
	animset[ "straight" ] = %nx_tp_ss_baker_walk;
	animset[ "straight_variation" ] = %nx_tp_ss_baker_walk;

	animset[ "stand_idle" ] = %civilian_stand_idle;
	
	animset[ "move_f" ] = %nx_tp_ss_baker_walk;
	animset[ "move_l" ] = %walk_left;
	animset[ "move_r" ] = %walk_right;
	animset[ "move_b" ] = %walk_backward;
	
	animset[ "crouch" ] = %crouch_fastwalk_F;
	animset[ "crouch_l" ] = %crouch_fastwalk_L;
	animset[ "crouch_r" ] = %crouch_fastwalk_R;
	animset[ "crouch_b" ] = %crouch_fastwalk_B;
	
	animset[ "stairs_up" ] = %nx_tp_ss_baker_walk;
	animset[ "stairs_down" ] = %nx_tp_ss_baker_walk;
		
	self.customMoveAnimSet[ "run" ] = animset;
	self.customMoveAnimSet[ "walk" ] = animset;

	// self anim_spawn_tag_model( "com_cellphone_on", "tag_inhand" );

	self.disableExits = true;
	self.disableArrivals = true;
	self disable_turnAnims();
}

disable_casual_lobby_anims()
{
	self.disableExits = false;
	self.disableArrivals = false;
	self enable_turnAnims();
	// self detach( "com_cellphone_on", "tag_inhand" );

	self animscripts\init_common::clear_custom_animset();
}

#using_animtree( "player" );
player_anims()
{
	//Standard arm model	
	level._scr_animtree[ "player_rig" ] = #animtree;
	level._scr_model[ "player_rig" ] = "viewhands_player_us_army";
	//Suit arm model
	level._scr_animtree[ "player_rig_suit" ] = #animtree;
	level._scr_model[ "player_rig_suit" ] = "viewhands_player_airport";

	// Rappel Jump
	level._scr_anim[ "player_rig" ][ "rappel_jump" ] = %nx_fp_skyscraper_rappeljump_player;

	// Rappel Swing Slid
	level._scr_anim[ "player_rig" ][ "rappel_swing_jump" ] = %nx_fp_skyscraper_rappelswingslide_player;
	addNotetrack_customFunction( "rappel_swing_jump", "slomo_weapon_firing", ::rappel_laser );

	// After UAV Floor collapse
	level._scr_anim[ "player_rig" ][ "get_up" ] = %nx_fp_skyscraper_get_up_player;

	// Halon Gas Mask
	level._scr_anim[ "player_rig" ][ "halon_gas_mask" ] = %nx_fp_skyscraper_halon_mask_player;

	// Landing Pad Climb Jump Player
	level._scr_anim[ "player_rig" ][ "landing_pad_climbjump_player" ] = %nx_fp_skyscraper_landing_pad_climbjump_player;

	// Landing Pad Window Player
	level._scr_anim[ "player_rig" ][ "landing_pad_window_player" ] = %nx_fp_skyscraper_landing_pad_window_player;

	// Landing Pad Edge Climb
	level._scr_anim[ "player_rig" ][ "landing_pad_edgeclimb" ] = %nx_fp_skyscraper_landing_pad_edgeclimb_player;

	// Elevator Exit
	level._scr_anim[ "player_rig_suit" ][ "elevator_out_lift" ] = %nx_fp_skyscraper_elevator_out_player_lift;
	level._scr_anim[ "player_rig" ][ "elevator_out_lift" ] = %nx_fp_skyscraper_elevator_out_player_lift;
	addNotetrack_customFunction( "player_rig_suit", "swap_player_models", ::swap_player_models_suit );
	addNotetrack_customFunction( "player_rig", "swap_player_models", ::swap_player_models );

	//Elevator Shaft Sequence
	// Elevator Shaft
	level._scr_anim[ "player_rig" ][ "elevator_shaft1" ] = %nx_fp_skyscraper_elevator_shaft1_player;
	level._scr_anim[ "player_rig" ][ "elevator_shaftjump" ] = %nx_fp_skyscraper_elevator_shaftjump_player;
	level._scr_anim[ "player_rig" ][ "elevator_shaftdive" ] = %nx_fp_skyscraper_elevator_shaftdive_player;
	level._scr_anim[ "player_rig" ][ "elevator_shaftclimb" ] = %nx_fp_skyscraper_elevator_shaftclimb_player;
	level._scr_anim[ "player_rig" ][ "elevator_shafthookup" ] = %nx_fp_skyscraper_elevator_shafthookup_player;
	level._scr_anim[ "player_rig" ][ "elevator_shafthookup_init" ] = %nx_fp_skyscraper_elevator_shafthookup_init_player;
	level._scr_anim[ "player_rig" ][ "elevator_shafthookup_armup" ] = %nx_fp_skyscraper_elevator_shafthookup_armup_player;
	level._scr_anim[ "player_rig" ][ "elevator_shafthookup_armdown" ] = %nx_fp_skyscraper_elevator_shafthookup_armdown_player;

	//Elevator Red Disembark
	level._scr_anim[ "player_rig" ][ "red_disembark" ] = %nx_fp_skyscraper_red_disembark_player;

	//Lab Stealth Kill
	level._scr_anim[ "player_rig" ][ "lab_stealth_kill" ] = %nx_fp_ss_lab_stealth_kill_player;


	//UAV Crash
	level._scr_anim[ "player_rig" ][ "uav_crash" ] = %nx_fp_skyscraper_uav_crash_player;
	level._scr_anim[ "player_rig" ][ "uav_crash_p2" ] = %nx_fp_skyscraper_uav_crash_player_p2;
	level._scr_anim[ "player_rig" ][ "uav_crash_p3" ] = %nx_fp_skyscraper_uav_crash_player_p3;
	level._scr_anim[ "player_rig" ][ "uav_crash_p2_idle" ][0] = %nx_fp_skyscraper_uav_crash_player_p2_idle;
	level._scr_anim[ "player_rig" ][ "uav_crash_idle" ][0] = %nx_fp_skyscraper_uav_crash_player_idle;

	//Atrium Crash
	level._scr_anim[ "player_rig" ][ "atrium_crash" ] = %nx_fp_skyscraper_atrium_crash_player;

	// Vault Holo Table P2
	level._scr_anim[ "player_rig" ][ "vault_holotable_p2" ] = %nx_fp_skyscraper_vault_servers_player_p2;
	level._scr_anim[ "player_rig" ][ "hookup" ] 		= %gulag_end_evac_player_hookup;
}

#using_animtree("script_model");
script_models()
{
	// After floor collapse
	level._scr_animtree[ "prop_rubble" ] = #animtree;
	level._scr_anim[ "prop_rubble" ][ "get_up" ] = %nx_pr_skyscraper_get_up_prop_01;
	level._scr_model[ "prop_rubble" ] = "nx_dcburning_rubble02";

	//Halon Gas Mask
	level._scr_animtree[ "halon_gas_mask_01" ] = #animtree;
	level._scr_anim[ "halon_gas_mask_01" ][ "halon_gas_mask" ] = %nx_pr_skyscraper_halon_mask_01;
	level._scr_model[ "halon_gas_mask_01" ] = "viewmodel_gasmask";

	level._scr_animtree[ "halon_gas_mask_02" ] = #animtree;
	level._scr_anim[ "halon_gas_mask_02" ][ "halon_gas_mask" ] = %nx_pr_skyscraper_halon_mask_02;
	level._scr_model[ "halon_gas_mask_02" ] = "viewmodel_gasmask";

	//Dummy elevator that wizzes by the player
	level._scr_animtree[ "elevator01" ] = #animtree;
	level._scr_anim[ "elevator01" ][ "elevator_shaft1" ] = %nx_pr_skyscraper_elevator_shaft1_elevator1;
	//level._scr_anim[ "elevator01" ][ "elevator_shaftjump" ] = %nx_pr_skyscraper_elevator_shaftjump_elevator1;
	level._scr_model[ "elevator01" ] = "nx_pr_skyscraper_elevator";
	//Dummy elevator that wizzes by the player
	level._scr_animtree[ "elevator02" ] = #animtree;
	level._scr_anim[ "elevator02" ][ "elevator_shaft1" ] = %nx_pr_skyscraper_elevator_shaft1_elevator2;
	level._scr_anim[ "elevator02" ][ "elevator_shaftjump" ] = %nx_pr_skyscraper_elevator_shaftjump_elevator2;
	level._scr_model[ "elevator02" ] = "nx_pr_skyscraper_elevator";

	//Dummy elevator that wizzes by the player
	level._scr_animtree[ "elevator03" ] = #animtree;
	level._scr_anim[ "elevator03" ][ "elevator_shaft1" ] = %nx_pr_skyscraper_elevator_shaft1_elevator3;
	level._scr_model[ "elevator03" ] = "nx_pr_skyscraper_elevator";

	//Dummy elevator that wizzes by the player
	level._scr_animtree[ "elevator04" ] = #animtree;
	level._scr_anim[ "elevator04" ][ "elevator_shaft1" ] = %nx_pr_skyscraper_elevator_shaft1_elevator4;
	level._scr_model[ "elevator04" ] = "nx_pr_skyscraper_elevator";

	level._scr_animtree[ "elevatorA" ] = #animtree;
	level._scr_anim[ "elevatorA" ][ "elevator_shaftprejump" ] = %nx_pr_skyscraper_elevator_shaftprejump_elevatorA;
	level._scr_anim[ "elevatorA" ][ "elevator_shaftjump" ] = %nx_pr_skyscraper_elevator_shaftjump_elevatorA;
	level._scr_model[ "elevatorA" ] = "nx_pr_skyscraper_elevator";

	level._scr_animtree[ "elevatorB" ] = #animtree;
	level._scr_anim[ "elevatorB" ][ "elevator_shaftjump" ] = %nx_pr_skyscraper_elevator_shaftjump_elevatorB;
	level._scr_anim[ "elevatorB" ][ "elevator_shaftclimb" ] = %nx_pr_skyscraper_elevator_shaftclimb_elevatorB;
	level._scr_anim[ "elevatorB" ][ "elevator_shaftclimb_move" ] = %nx_pr_skyscraper_elevator_shaftclimb_elevatorB_move;
	level._scr_model[ "elevatorB" ] = "nx_pr_skyscraper_elevator";

	level._scr_animtree[ "elevatorC" ] = #animtree;
	level._scr_anim[ "elevatorC" ][ "elevator_shafthookup" ] = %nx_pr_skyscraper_elevator_shafthookup_elevatorC;
	level._scr_model[ "elevatorC" ] = "nx_pr_skyscraper_elevator";

	addNotetrack_customFunction( "elevator01", "elevator_quake", ::elevator_quake );
	addNotetrack_customFunction( "elevator02", "elevator_quake", ::elevator_quake );
	addNotetrack_customFunction( "elevator03", "elevator_quake", ::elevator_quake );
	addNotetrack_customFunction( "elevator04", "elevator_quake", ::elevator_quake );

	// UAV Crash Floor
	level._scr_animtree[ "floor" ] = #animtree;
	level._scr_anim[ "floor" ][ "uav_crash" ] = %nx_skyscraper_vtol_floorcollapse_anim;
	level._scr_model[ "floor" ] = "nx_skyscraper_vtol_floorcollapse";

	level._scr_animtree[ "floor" ] = #animtree;
	level._scr_anim[ "floor" ][ "uav_crash_p2" ] = %nx_skyscraper_vtol_floorcollapse_anim_p2;
	level._scr_model[ "floor" ] = "nx_skyscraper_vtol_floorcollapse";

	level._scr_animtree[ "floor" ] = #animtree;
	level._scr_anim[ "floor" ][ "uav_crash_p3" ] = %nx_skyscraper_vtol_floorcollapse_anim_p3;
	level._scr_model[ "floor" ] = "nx_skyscraper_vtol_floorcollapse";

	level._scr_animtree[ "floor" ] = #animtree;
	level._scr_anim[ "floor" ][ "uav_crash_p2_idle" ][0] = %nx_skyscraper_vtol_floorcollapse_anim_p2_idle;
	level._scr_model[ "floor" ] = "nx_skyscraper_vtol_floorcollapse";

	level._scr_animtree[ "floor" ] = #animtree;

	level._scr_anim[ "floor" ][ "uav_crash_idle" ][0] = %nx_skyscraper_vtol_floorcollapse_anim_idle;

	level._scr_model[ "floor" ] = "nx_skyscraper_vtol_floorcollapse";

	// Vault Holo Table P2
	level._scr_animtree[ "servers" ] = #animtree;
	level._scr_anim[ "servers" ][ "vault_holotable_p2" ] = %nx_skyscraper_vault_servers_anim_p2;
	level._scr_model[ "servers" ] = "nx_skyscraper_vault_servers";

	level._scr_animtree[ "holotable" ] = #animtree;
	level._scr_anim[ "holotable" ][ "vault_holotable_p2" ] = %nx_skyscraper_vault_table_anim_p2;
	level._scr_model[ "holotable" ] = "nx_skyscraper_vault_table";

	// Vault Holo Table P1
	level._scr_animtree[ "servers" ] = #animtree;
	level._scr_anim[ "servers" ][ "vault_holotable" ] = %nx_skyscraper_vault_servers_anim_p1;
	level._scr_model[ "servers" ] = "nx_skyscraper_vault_servers";

	level._scr_animtree[ "holotable" ] = #animtree;
	level._scr_anim[ "holotable" ][ "vault_holotable" ] = %nx_skyscraper_vault_table_anim_p1;
	level._scr_model[ "holotable" ] = "nx_skyscraper_vault_table";

}

#using_animtree("vehicles");
vehicles()
{
	//Landing Pad VTOL
	level._scr_anim[ "chinese_vtol" ][ "landing_pad_vtol" ] = %nx_vh_skyscraper_landing_pad_vtol_01;

	//VTOL Floor Collapse
	level._scr_anim[ "chinese_uav" ][ "uav_crash" ] = %nx_vh_skyscraper_uav_crash_01;
	level._scr_anim[ "chinese_uav" ][ "uav_crash_p2" ] = %nx_vh_skyscraper_uav_crash_01_p2;
	level._scr_anim[ "chinese_uav" ][ "uav_crash_p3" ] = %nx_vh_skyscraper_uav_crash_01_p3;
	level._scr_anim[ "chinese_uav" ][ "uav_crash_p2_idle" ][0] = %nx_vh_skyscraper_uav_crash_01_p2_idle;
	level._scr_anim[ "chinese_uav" ][ "uav_crash_idle" ][0] = %nx_vh_skyscraper_uav_crash_01_idle;

	//Atrium Crash
	level._scr_anim[ "helicopter" ][ "atrium_crash" ] = %nx_vh_skyscraper_atrium_crash_01;
}

//*******************************************************************
// DRIVE IN AND LOBBY                                               *
//                                                                  *
//*******************************************************************

intro_ride( )
{

	wait 3;

	level.driver.animname = "driver";

	guys = [];
	guys["ally_01"] = level.baker;
	guys["driver"] = level.driver;
	level.taxi anim_single(guys, "intro_ride", "tag_passenger");

}
/*
lobby_airlock_spawn()
{
	lobby_airlock(level.baker);
}

lobby_airlock(baker)
{

	node = getstruct("lobby_airlock", "script_noteworthy");

	guys = [];
	guys["ally_01"] = baker;

	node anim_single(guys, "lobby_airlock");
}

lobby_walk_spawn()
{

	lobby_walk(level.baker);

}

lobby_walk(baker)
{

	node = getstruct("lobby_walk", "script_noteworthy");
	guys = [];
	guys["ally_01"] = baker;
	node anim_single(guys, "lobby_walk");
}
*/
security_baker_spawn()
{
	if ( !flag ("flag_outro_start"))
	{
		level.lobby_guard_1.animname = "guard";
		security_baker(level.baker, level.lobby_guard_1);
	}
}

security_baker(baker, guard)
{
	node = getstruct("security_baker", "script_noteworthy");

	guys = [];
	guys["ally_01"] = baker;
	guys["guard"] = guard;

	node anim_single(guys, "security_baker");
}


securitypoint_civilian_spawn()
{
	civilian = vignette_actor_spawn("civ_02", "civilian"); //"value" (kvp), "anim_name"
	guard = vignette_actor_spawn("civ_03", "guard"); //"value" (kvp), "anim_name"

	securitypoint_civilian(civilian, guard);

	civilian vignette_actor_delete();
	guard vignette_actor_delete();
}

securitypoint_civilian(civilian, guard)
{
	node = getstruct("securitypoint_civilian", "script_noteworthy");

	guys = [];
	guys["civilian"] = civilian;
	guys["guard"] = guard;

	node anim_single(guys, "securitypoint_civilian");
}

//*******************************************************************
// ELEVATOR                                                         *
//                                                                  *
//*******************************************************************
// Climb out of elevator

outelevator_spawn()
{
	// ss_outelevator_baker = vignette_actor_spawn("ss_outelevator_baker", "ss_outelevator_baker"); //"value" (kvp), "anim_name"
	// ss_outelevator_baker = GetEnt ("platform_buddy", "targetname");
	level.baker Unlink();
	outelevator(level.baker);

	// ss_outelevator_baker vignette_actor_delete();
}

outelevator()
{
	
	guys = [];
	guys["ally_01"] = level.baker;

	level.baker.animname = "ally_01";

	flag_set ("baker_exit_elevator_start");

	node = GetEnt ("player_elevator_anim_node", "targetname");
	level.baker linkto ( node );
	node anim_single(guys, "elevator_out_intro");
	node thread anim_loop_solo (level.baker, "elevator_out_idle", "stop_idle");

	trigger = GetEnt ("player_ready_for_elevator_lift", "targetname");
	trigger SetHintString( &"NX_SKYSCRAPER_HINT_GRAB" );
	trigger waittill ("trigger");
	elevator_out_lift();
	
}

elevator_out_lift()
{
	player_rig_suit = spawn_anim_model( "player_rig_suit" );
	player_rig = spawn_anim_model( "player_rig" );
	player_body = spawn_anim_model( "player_body" );
	// player_body = vignette_actor_spawn("elevator_out_playerbody", "player_body"); //"value" (kvp), "anim_name"

	guys = [];
	guys["player_body"] = player_body;
	guys["player_rig"] = player_rig;
	guys["player_rig_suit"] = player_rig_suit;
	node = GetEnt ("player_elevator_anim_node", "targetname");
	node notify ("stop_idle");
	level.baker linkto ( node );
	player_body linkto ( node );

	arc = 15;
	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	thread maps\nx_skyscraper_fx::trigger_elev_shaft();

	player_rig linkto ( node ); //, undefined, (0,0,0), (0,0,0) );
	player_rig_suit linkto ( node ); 
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);
	level._player PlayerLinkToDelta( player_rig_suit, "tag_player", 1, arc, arc, arc, arc, 1);

	//Add a gun model
	player_rig Attach( "viewmodel_lancer_xray", "tag_weapon" );

	//Hide the regular arms
	player_rig hide();

	//thread baker's animation so we can swap his model when it's done
	thread elevator_out_lift_baker( node );
	//play the vignette for the player
	//the player models should get swapped by a ntoetrack trigger.
	node anim_single(guys, "elevator_out_lift");

	player_rig unlink();
	player_rig delete();
	
	player_rig_suit unlink( );
	player_rig_suit delete();
	// player_body vignette_actor_delete();
	player_body delete();
	
	//level._player unlink();
	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

	flag_set ("elevator_out_lift_done");
	level notify ("elevator_out_lift_done");

}
elevator_out_lift_baker( node )
{
	//play baker's animation
	node notify ("stop_idle");
	node anim_single_solo(level.baker, "elevator_out_lift");
	// swap out business baker for specops baker. 
	teleport_location = level.baker.origin;
	teleport_angles = level.baker.angles;
	level.baker stop_magic_bullet_shield();
	level.baker delete();
	maps\nx_skyscraper_util::spawn_baker();
	level.baker ForceTeleport( teleport_location, teleport_angles );
	level.baker linkto ( node );
	node thread anim_loop_solo (level.baker, "elevator_ontop_idle", "stop_idle");
}

swap_player_models( guy )
{
	guy show();
}

swap_player_models_suit( guy )
{
	//hide the suit
	// iprintln ( "Swapping models" );
	guy hide();
}

elevator_push_spawn()
{
	// ally_01 = vignette_actor_spawn("ally_01", "ally_01"); //"value" (kvp), "anim_name"
	flag_wait ("baker_in_elevator");
	ally_01 = level.baker;
	civ_01 = vignette_actor_spawn("elevator_push_civilian", "civ_01"); //"value" (kvp), "anim_name"
	node = GetEnt ("player_elevator_anim_node", "targetname");
	thread elevator_push_civ( node, civ_01 );
	thread elevator_push_baker( node, ally_01 );
	//wait some point into the animation and close the doors and start the ride up
	wait 7;
}

elevator_push_civ( node, civ_01 )
{
	node anim_single_solo( civ_01, "elevator_push" );
	civ_01 vignette_actor_delete();
}

elevator_push_baker( node, ally_01 )
{
	node notify ("stop_idle");
	node anim_single_solo( ally_01, "elevator_push" );
	//stop baker's old idle and start a new one
	node thread anim_loop_solo (level.baker, "elevator_idle_loop", "stop_idle"); 
}

//*******************************************************************
// SHAFT                                                            *
//                                                                  *
//*******************************************************************


// Ally goes around the pole
elevator_shaft1_baker()
{
	//iprintln ("Shaft 1 Baker");
	old_node = GetEnt ("player_elevator_anim_node", "targetname");
	old_node notify ("stop_idle");
	node = GetEnt ("baker_shaft_teleport", "targetname");
	//node notify ("stop_idle");
	//send the first elevator past
	thread elevator_shaft1_e1();
	thread elevator_shaft1_e2();

	node anim_single_solo( level.baker, "elevator_shaft1");
	node thread anim_loop_solo (level.baker, "elevator_shaft1_idle", "stop_idle");
}

// Player goes around the pole
elevator_shaft1_player()
{
	node = GetEnt ("elevator_shaft_pole", "targetname");
	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player disableweapons();

	if ( level._player GetStance() != "stand") 
	{
		wait .5;
	}
	level._player setstance( "stand" );

	player_rig = spawn_anim_model( "player_rig" );
	player_body = spawn_anim_model( "player_body" );	

	guys = [];
	guys["player_rig"] = player_rig;
	guys["player_body"] = player_body;
	
	xray = GetEnt ("lancer_silencer_xray", "targetname");

	arc = 0;
	//level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);
	level._player PlayerLinkToBlend( player_rig, "tag_player", .5, .25, .25 );
	
	xray LinkTo( player_rig, "tag_weapon", (0,0,0), (0,0,0) );	
	//send an eleavtor past
	//thread elevator_shaft1_e3();

	node anim_single(guys, "elevator_shaft1");
	level._player unlink();

	player_rig delete();
	player_body delete();
	xray delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	//send one last elevator past
	thread elevator_shaft1_e4();

	flag_set ("shaft_player_past_pole");
	thread elevator_shaft_elevatorA_start();
}

elevator_shaft1_e1()
{
	//wait 5.25;
	node = GetEnt ("baker_shaft_teleport", "targetname");
	elevator01 = spawn_anim_model("elevator01");
	node anim_single_solo(elevator01, "elevator_shaft1");
	elevator01 delete();
}

elevator_shaft1_e2()
{
	wait 11;
	node = GetEnt ("baker_shaft_teleport", "targetname");
	elevator02 = spawn_anim_model("elevator02");
	elevator02 playsound("scn_skyscraper_elevator_passby_02");
	node anim_single_solo(elevator02, "elevator_shaft1");
	elevator02 delete();
}
elevator_shaft1_e3()
{
	//wait 2;
	node = GetEnt ("elevator_shaft_pole", "targetname");
	elevator03 = spawn_anim_model("elevator03");
	elevator03 playsound("scn_skyscraper_elevator_passby_03");
	node anim_single_solo(elevator03, "elevator_shaft1");
	elevator03 delete();
}
elevator_shaft1_e4()
{
	//wait 2;
	node = GetEnt ("elevator_shaft_pole", "targetname");
	elevator04 = spawn_anim_model("elevator04");
	elevator04 playsound("scn_skyscraper_elevator_passby_04");
	node anim_single_solo(elevator04, "elevator_shaft1");
	elevator04 delete();
}
elevator_shaft_elevatorA_start()
{
	node = GetEnt ("elevator_shaft_jump", "targetname");
	level.elevatorA = spawn_anim_model("elevatorA");
	node anim_first_frame_solo(level.elevatorA, "elevator_shaftprejump");
	waittillframeend;

	// Attach the trigger to the elevator anim model
	trigger = GetEnt ("player_ready_elevator_jump", "targetname");
	trigger linkto (level.elevatorA, "tag_origin");
	blend_trigger = GetEnt ("player_ready_elevator_jump_blend", "targetname");
	blend_trigger linkto (level.elevatorA, "tag_origin");

	// Attach animation node to Elevator anim model
	next_node = spawn ("script_origin", level.elevatorA.origin);
	next_node linkto (level.elevatorA);

	thread elevator_shaftjump_player( blend_trigger, trigger, next_node );

	node anim_single_solo(level.elevatorA, "elevator_shaftprejump");

	flag_set ("elevator_a_in_position");
}

elevator_quake( elevator )
{
	level._player playsound("scn_skyscraper_elevator_passby_air");
	level._player PlayRumbleOnEntity( "damage_light" );
	Earthquake( 0.2, 3, elevator.origin, 850 );
}

// Ally jumps down onto elevator from walkway
elevator_shaftjump( )
{
	// iprintln ("Shaft JUMP!!");
	
	node = GetEnt ("elevator_shaft_jump", "targetname");
	// Spawn elevators and set them to first frame early
	guys = [];

	//elevator01 = spawn_anim_model("elevator01", level.baker.origin);
	elevator02 = spawn_anim_model("elevator02");
	level.elevatorB = spawn_anim_model("elevatorB");

	guys["elevatorA"] = level.elevatorA;
	guys["elevatorB"] = level.elevatorB;
	guys["elevator02"] = elevator02;

	node anim_first_frame(guys, "elevator_shaftjump");

	/* Attach the trigger to the elevator anim model
	trigger = GetEnt ("player_ready_elevator_jump", "targetname");
	trigger linkto (level.elevatorA, "tag_origin");
	blend_trigger = GetEnt ("player_ready_elevator_jump_blend", "targetname");
	blend_trigger linkto (level.elevatorA, "tag_origin");
	
	thread elevator_shaftjump_player( blend_trigger, trigger );
	*/
	
	guys["ally_01"] = level.baker;

	trigger = GetEnt ("player_ready_elevator_jump", "targetname");
	trigger wait_for_notify_or_timeout( "trigger", 5);
	flag_wait ("elevator_a_in_position");

	//Kill the old looping anim
	old_node =  GetEnt ("baker_shaft_teleport", "targetname");
	old_node notify ("stop_idle");
	
	// node notify ("stop_idle");

	// add_dialogue_line( "Baker", "Jump now!", "green", 2 );
	level.baker dialogue_queue ("sky_bak_shaft_jumpnow");

	node anim_single(guys, "elevator_shaftjump");

	elevator02 delete();
	//loop baker in an idle
	//adding this so we can tweak the amount of time baker needs to idle before the second Jump

	old_node notify ("stop_idle");
	node thread anim_loop_solo (level.baker, "elevator_shaftjump_idle", "stop_idle");
		
	//loop baker in an idle
	//node thread anim_loop_solo (level.baker, "elevator_shaftjump_idle", "stop_idle");
}

// Player jumps down onto elevator from walkway
elevator_shaftjump_player( blend_trigger, trigger, node )
{
	// node = spawn ("script_origin", level.elevatorA.origin);
	// node linkto (level.elevatorA);
	level._player disableweapons();
	// Create, hide, and set the player rig to first frame for a blend destination
	player_rig = spawn_anim_model( "player_rig" );
	player_rig hide();

	guys["player_rig"] = player_rig;
	node anim_first_frame(guys, "elevator_shaftjump");

	// Wait until the player hits the blend trigger, then start lerping them into position
	blend_trigger waittill ("trigger");

	xray = GetEnt ("lancer_silencer_xray2", "targetname");
	
	flag_set ( "player_made_first_elevator_jump" );
	
	
	level._player PlayerLinkToBlend( player_rig, "tag_player", .5, .1, .1, true );
	xray LinkTo( player_rig, "tag_weapon", (0,0,0), (0,0,0) );
	xray show();	

	// Since the player may be falling at varied rates, wait until they "collide" with the elevator (trigger) or the blend has finished.
	trigger wait_for_notify_or_timeout ("trigger", .5);
	player_rig linkto ( node );
	player_rig show();

	// Grant some amoutn of view control
	arc = 30;
	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "elevator_shaftjump");

	flag_wait ("player_elevator_dive");

	level._player disableweapons();
	// iprintln ("Shaft Dive");
	node anim_single(guys, "elevator_shaftdive");

	level._player unlink();

	level.baker playsound("scn_skyscraper_elevator_climb_up_baker");

	player_rig delete();
	xray delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player AllowSprint(true);

	thread maps\nx_skyscraper_anim::elevator_shaftclimb();
}

elevator_shaftdive_player( guy )
{
	flag_set( "player_elevator_dive" );
}

elevator_shaftdive_player_prompt ( guy )
{
	// iprintln ( "DUCK NOW!" );
	if ( !flag ("player_made_first_elevator_jump"))
	{
		SetDvar( "ui_deadquote", &"NX_SKYSCRAPER_FAIL_MISSED_JUMP" );
		missionFailedWrapper();
	}
	else
	{
		display_hint ("NX_SKYSCRAPER_HINT_GO_PRONE");
		flag_wait ("player_elevator_dive");
		if ( !flag ("player_pressed_prone"))
		{
			RadiusDamage( level._player.origin, 1, 80, 50 );
		}
	}
}
/*
elevator_shaft_elevatorB_start()
{
	node = GetEnt ("elevator_shaft_jump", "targetname");
	level.elevatorB = spawn_anim_model("elevatorB");
	node anim_single_solo(level.elevatorA, "elevator_shaftprejump");
}*/

elevator_shaftclimb()
{
	maps\nx_skyscraper_util::player_restore_abilities();
	blocker = GetEnt ("player_second_jump_blocker", "targetname");
	blocker Solid();

	trigger = GetEnt ("second_elevator_jump", "targetname");
	trigger linkto (level.elevatorB, "tag_origin");

	trigger_land = GetEnt ("second_elevator_land", "targetname");
	trigger_land linkto (level.elevatorB, "tag_origin"); 

	node = spawn ("script_origin", level.elevatorB.origin);
	node linkto (level.elevatorB);
	
	//play Baker jumping to the other elevator
	thread elevator_shaftclimb_ally( node );
	
	level._player_rig = spawn_anim_model( "player_rig" );
	level._player_rig hide();

	node anim_first_frame_solo( level._player_rig, "elevator_shaftclimb" );

	// Wait until the player hits the blend trigger, then start lerping them into position
	trigger waittill ("trigger");

	level._player DisableWeapons();
	level._player PlayerLinkToBlend( level._player_rig, "tag_player", .4, .1, 0, true );

	// Since the player may be falling at varied rates, wait until they "collide" with the elevator (trigger) or the blend has finished.
	trigger_land wait_for_notify_or_timeout ("trigger", .5);

	// Grant some amoutn of view control
	level._player_rig linkto ( node );
	level._player_rig show();
	//level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);
	level._player PlayerLinkToDelta( level._player_rig, "tag_player", 0, 60, 60, 45, 15 );

	// node = GetEnt( "elevator_shaft_jump", "targetname" );
	level._player playsound("scn_skyscraper_elevator_climb_up");
	node thread anim_single_solo( level._player_rig, "elevator_shaftclimb" );

	level._player allowprone( false );
	level._player allowcrouch( false );

	level._player_rig elevator_shaftclimb_controls( "elevator_shaftclimb" );
	
	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player PlayerSetGroundReferenceEnt( undefined );

	level._player LerpViewAngleClamp( 1, 0.25, 0.25, 25, 25, 25, 25 );
	level._player_rig Hide();

	//this doesn't work great.  The player can finish before the elevator stops.
	//level notify ("shaftclimb_player_done");
	flag_set ( "shaftclimb_player_done" );
}

elevator_shaftclimb_ally( node )
{
	// wait 1;
	old_node = GetEnt ("elevator_shaft_jump", "targetname");
	old_node notify ("stop_idle");

	guys = [];
	guys["ally_01"] = level.baker;
	guys["elevatorB"] = level.elevatorB;

	//node anim_single(guys, "elevator_shaftclimb");
	//play baker jumping to the elevator B
	//this wait determines how much time before baker jumps
	wait 2;
	old_node anim_single( guys, "elevator_shaftclimb" );

	//start Baker looping
	level.baker linkto ( node );	
	node thread anim_loop_solo (level.baker, "elevator_shaftclimb_idle", "stop_idle");
	
	//move the elevator
	//This wait determines how much time there is before this happens
	wait 2;
	old_node anim_single_solo( level.elevatorB, "elevator_shaftclimb_move" );
	
	flag_set ("elevator_b_in_position");
	flag_wait ( "shaftclimb_player_done" );

	node notify ("stop_idle");
}

elevator_shaftclimb_controls( vignette )
{
	// self is player_rig

	legs_anime = undefined;

	anime = level._scr_anim[ "player_rig" ][ vignette ];
	stop_points = GetNotetrackTimes( anime, "step" );

	time = 0;

	anim_length = GetAnimLength( anime );
	// iprintln ("animlength: " + anim_length);
	STOP_HEADER = STOP_HEADER_SEC / anim_length;

	level._hint_given_count = 0;

	// for each stop point in the animation
	for ( stop_idx = 0; stop_idx < stop_points.size; )
	{
		stop_time = stop_points[ stop_idx ];

		begin_stopping_time = stop_time - STOP_HEADER;

		wait 0.05;
		time = self GetAnimTime( anime );
		level.player_move_vignette_time = anim_length * time;

		// wait until we're a few seconds before the stop point

		if ( time > begin_stopping_time )
		{
			if ( !player_moving_forward( stop_idx ) )
			{
				
				thread climb_hint( stop_idx );

				// slow to a stop until the player presses forward
				while ( !player_moving_forward( stop_idx ) )
				{
					if ( time > stop_time )
					{
						self SetFlaggedAnimLimited( "single anim", anime, 1, stop_points[ stop_idx ], 0 );
						break;
					}

					// good curve for rate drop off
					rate = 1 - Squared( 1 - ( ( stop_time - time ) / STOP_HEADER ) );
					self SetFlaggedAnimLimited( "single anim", anime, 1, stop_points[ stop_idx ], rate );
	
					wait 0.05;
					time = self GetAnimTime( anime );
					level.player_move_vignette_time = anim_length * time;
				}

				while ( !player_moving_forward( stop_idx ) )
				{
					wait 0.05;
				}
			}
			level notify ("climb_hint_clear");
			// start moving again; advance to the next stop point
			level._player playsound("skyscraper_elevator_climb_up");
			self SetFlaggedAnimLimited( "single anim", anime, 1, stop_points[ stop_idx ], 1 );
			self notify( "cancel_wait_then_show_hint" );
			// iprintln (" step: " + stop_idx );
			stop_idx++;
		}
	}

	time = self GetAnimTime( anime );
	level.player_move_vignette_time = anim_length * time;

	// force the player to look forward
	time_left = ( 1 - time ) * anim_length;
	// level._player LerpViewAngleClamp( time_left, 0.25 * time_left, 0.25 * time_left, 0, 0, 0, 0 );

	while ( time < 1 )
	{
		wait 0.05;
		time = self GetAnimTime( anime );
		level.player_move_vignette_time = anim_length * time;
	}
}

climb_hint( stop_idx )
{
	level endon ("climb_hint_clear");
	//wait 2;
	wait .25;
	// if stop_idx is an even number
	if ( stop_idx % 2 == 0)
	{
		display_hint ("NX_SKYSCRAPER_HINT_LEFT_HAND");
	}
	else
	{
		display_hint ("NX_SKYSCRAPER_HINT_RIGHT_HAND");
	}
}

player_moving_forward( stop_idx )
{
	// return level._player getNormalizedMovement()[ 0 ] > 0.5;
	// if stop_idx is an even number
	if ( stop_idx % 2 == 0)
	{
		return level._player AdsButtonPressed();
	}
	else
	{
		return level._player AttackButtonPressed();
	}
}

elevator_shafthookup()
{
	// iprintln ("Shaft Hookup");

	level notify ("shaft_vignette_done");

	node = GetEnt ("elevator_shaft_jump", "targetname");
	node notify ("stop_idle");
	level.elevatorC = spawn_anim_model("elevatorC");

	guys = [];
	guys["ally_01"] = level.baker;
	guys["elevatorC"] = level.elevatorC;
	
	thread elevator_shafthookup_player_init();
	node anim_single(guys, "elevator_shafthookup");

	level notify ("freight_elevator_stop");
}

//baker's animation should trigger the player hookup
player_elevator_hookup( guy )
{
	if ( flag ("player_used_hook") )
	{
		elevator_shafthookup_player();
	}
	else 
	{
		wait 2;
		missionFailedWrapper();
	}
}

elevator_shafthookup_player_init()
{
	flag_wait ( "player_used_hook");

	node = GetEnt ("elevator_shaft_jump", "targetname");
	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level.player_rig = spawn_anim_model( "player_rig" );
	player_body = spawn_anim_model( "player_body" );

	guys = [];
	guys["player_rig"] = level.player_rig;
	guys["player_body"] = player_body;

	level._player PlayerLinkToBlend( level.player_rig, "tag_player", .5, .25, .25 );
	node anim_single( guys, "elevator_shafthookup_init" );
	
	// player_body vignette_actor_delete();
	player_body delete();

	level._player FreezeControls( false );
	//player_rig delete();
}

// This system isn't very much fun and is more work than it's worth for a single timed event.
/*
elevator_hook_up_controls()
{
	player_rig = spawn_anim_model( "player_rig", level._player.origin );

	arc = 15;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node = GetEnt ("elevator_shaft_jump", "targetname");

	while ( 1 )
	{
		while ( !level._player UseButtonPressed() )
		{
			wait .1;
		}
		node anim_single_solo( player_rig, "elevator_shafthookup_armup" );
		flag_set ( "player_used_hook");
		while ( level._player UseButtonPressed() )
		{
			wait .1;
		}
		flag_clear ( "player_used_hook");
		node anim_single_solo( player_rig, "elevator_shafthookup_armdown" );
	}
}
*/

elevator_shafthookup_player( player_rig )
{	
	node = GetEnt ("elevator_shaft_jump", "targetname");
	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	//player_rig = spawn_anim_model( "player_rig" );
	//player_rig hide();
	//level._player PlayerLinkToDelta( player_rig, "tag_player", 1, 180,180, arc, arc );
	//level._player PlayerLinkToBlend( player_rig, "tag_player", .5, .25, .25 );
	arc = 15;
	level._player PlayerLinkToDelta( level.player_rig, "tag_player", 1, arc,arc, arc, arc );
	node anim_single_solo( level.player_rig, "elevator_shafthookup" );
	level._player unlink();
	arc = 60;
	level._player PlayerLinkToDelta( level.player_rig, "tag_player", 1, 180,180, arc, arc );

	level._player FreezeControls( false );
	level.player_rig hide();
	// level._player SwitchToWeapon( "lancer_silencer_xray" ); 
	maps\nx_skyscraper_util::player_weapon_init( false );
	level._player EnableWeapons();
	flag_wait ("flag_elevator_red_disembark");
	level.player_rig delete();

	level._player allowprone( true );
	level._player allowcrouch( true );
	
}

red_disembark_spawn()
{
	// ally01 = vignette_actor_spawn("ally_01", "ally_01"); //"value" (kvp), "anim_name"
	opfor = vignette_actor_spawn("vignette_opfor_01", "opfor"); //"value" (kvp), "anim_name"
	opfor gun_remove();
	red_disembark(level.baker, opfor);

	// ally01 vignette_actor_delete();
	opfor vignette_actor_delete();
}

red_disembark(ally01, opfor)
{

	node = getstruct("red_disembark", "script_noteworthy");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["ally_01"] = ally01;
	guys["opfor"] = opfor;
	guys["player_rig"] = player_rig;

	arc = 70;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "red_disembark");

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player EnableWeapons();

}

//*******************************************************************
// Lab Stealth Kill                                                 *
//                                                                  *
//*******************************************************************

lab_stealth_kill_spawn()
{
	vignette_lab_stealth_kill_baker = vignette_actor_spawn("vignette_lab_stealth_kill_baker", "vignette_lab_stealth_kill_baker"); //"value" (kvp), "anim_name"
	vignette_lab_stealth_kill_opfor_02 = vignette_actor_spawn("vignette_lab_stealth_kill_opfor_02", "vignette_lab_stealth_kill_opfor_02"); //"value" (kvp), "anim_name"
	vignette_lab_stealth_kill_opfor_01 = vignette_actor_spawn("vignette_lab_stealth_kill_opfor_01", "vignette_lab_stealth_kill_opfor_01"); //"value" (kvp), "anim_name"

	lab_stealth_kill(vignette_lab_stealth_kill_baker, vignette_lab_stealth_kill_opfor_02, vignette_lab_stealth_kill_opfor_01);

	vignette_lab_stealth_kill_baker vignette_actor_delete();
	vignette_lab_stealth_kill_opfor_02 vignette_actor_delete();
	vignette_lab_stealth_kill_opfor_01 vignette_actor_delete();
}

lab_stealth_kill(vignette_lab_stealth_kill_baker, vignette_lab_stealth_kill_opfor_02, vignette_lab_stealth_kill_opfor_01)
{

	node = getstruct("vignette_lab_stealth_kill", "script_noteworthy");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["vignette_lab_stealth_kill_baker"] = vignette_lab_stealth_kill_baker;
	guys["vignette_lab_stealth_kill_opfor_02"] = vignette_lab_stealth_kill_opfor_02;
	guys["vignette_lab_stealth_kill_opfor_01"] = vignette_lab_stealth_kill_opfor_01;
	guys["player_rig"] = player_rig;

	arc = 15;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "lab_stealth_kill");

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

}

//*******************************************************************
// xray kill                                                        *
//                                                                  *
//*******************************************************************

xray_kill_intro()
{
	node = GetEnt("vignette_xraykill", "script_noteworthy");

	guys = [];
	guys["baker"] = level.baker;

	node anim_single(guys, "xray_kill_intro");
}

xray_kill_thru_door()
{
	node = GetEnt("vignette_xraykill", "script_noteworthy");

	guys = [];
	guys["baker"] = level.baker;

	node anim_single(guys, "xray_kill_outro");
	level.baker enable_ai_color();
}

//*******************************************************************
// RAPPEL                                                           *
//                                                                  *
//*******************************************************************

rappel_jump_spawn()
{
	//rappel_jump_baker = vignette_actor_spawn("ally_01", "rappel_jump_baker"); //"value" (kvp), "anim_name"

	rappel_jump(level.baker);

	//rappel_jump_baker vignette_actor_delete();
}

rappel_jump(rappel_jump_baker)
{
	node = getstruct("rappel_jump", "script_noteworthy");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["player_rig"] = player_rig;
	guys["ally_01"] = rappel_jump_baker;

	arc = 15;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "rappel_jump");

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player EnableWeapons();
}

rappel_swing_jump_spawn()
{
	// swing_slide_baker = vignette_actor_spawn("ally_01", "swing_slide_baker"); //"value" (kvp), "anim_name"

	rappel_swing_jump(level.baker);

	// swing_slide_baker vignette_actor_delete();
}

rappel_swing_jump(swing_slide_baker)
{

	node = getstruct("rappel_swing_jump", "script_noteworthy");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["player_rig"] = player_rig;
	guys["ally_01"] = swing_slide_baker;

	level._player PlayerSetGroundReferenceEnt( undefined );
	arc = 40;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1 );

	node anim_single(guys, "rappel_swing_jump");

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player EnableWeapons();

	flag_set( "flag_rappel_swing_done" );
}


rappel_bakersign_spawn()
{
	// bakersign = vignette_actor_spawn("bakersign", "bakersign"); //"value" (kvp), "anim_name"

	rappel_bakersign(level.baker);

	// bakersign vignette_actor_delete();
}

rappel_bakersign(bakersign)
{
	node = getstruct("rappel_bakersign", "script_noteworthy");

	guys = [];
	guys["ally_01"] = bakersign;

	node anim_single(guys, "rappel_bakersign");

}

rappel_baker_section_01_spawn()
{
	baker_section_01 = vignette_actor_spawn("player_body", "baker_section_01"); //"value" (kvp), "anim_name"

	rappel_baker_section_01(baker_section_01);

	baker_section_01 vignette_actor_delete();
}

rappel_baker_section_01(baker_section_01)
{

	node = getstruct("rappel_bakersign", "script_noteworthy");

	guys = [];
	guys["baker_section_01"] = baker_section_01;

	node anim_single(guys, "rappel_baker_section_01");

}

rappel_baker_section_02_spawn()
{
	baker_section_02 = vignette_actor_spawn("player_body", "baker_section_02"); //"value" (kvp), "anim_name"

	rappel_baker_section_02(baker_section_02);

	baker_section_02 vignette_actor_delete();
}

rappel_baker_section_02(baker_section_02)
{

	node = getstruct("rappel_bakersign", "script_noteworthy");


	guys = [];
	guys["baker_section_02"] = baker_section_02;

	node anim_single(guys, "rappel_baker_section_02");

}

rappel_baker_section_03_spawn()
{
	baker_section_03 = vignette_actor_spawn("player_body", "baker_section_03"); //"value" (kvp), "anim_name"

	rappel_baker_section_03(baker_section_03);

	baker_section_03 vignette_actor_delete();
}

rappel_baker_section_03(baker_section_03)
{

	node = getstruct("rappel_bakersign", "script_noteworthy");


	guys = [];
	guys["baker_section_03"] = baker_section_03;

	node anim_single(guys, "rappel_baker_section_03");

}

rappel_bakerwindow_spawn()
{
	// rappel_bakerwindow = vignette_actor_spawn("ally_01", "rappel_bakerwindow"); //"value" (kvp), "anim_name"

	rappel_bakerwindow(level.baker);

	// rappel_bakerwindow vignette_actor_delete();
}

rappel_bakerwindow(rappel_bakerwindow)
{

	node = getstruct("rappel_bakersign", "script_noteworthy");

	guys = [];
	guys["ally_01"] = rappel_bakerwindow;

	node anim_single(guys, "rappel_bakerwindow");

}

rappel_laser( player_rig )
{
	//level notify( "notify_start_laser" );
	iprintln( "laser notetrack start!" );
}

//*******************************************************************
// VTOL AND FLOOR COLLAPSE                                          *
//                                                                  *
//*******************************************************************

uav_crash_spawn( )
{
	level._player EnableInvulnerability();
	level notify ("destroy_all_vtols");
	if (isAlive ( level.lab_vtol))
		level.lab_vtol delete();
	if (isAlive ( level.lab_vtol2))
		level.lab_vtol2 delete();
	if (isAlive ( level.lab_vtol3))
		level.lab_vtol3 delete();
	if (isAlive ( level.lab_vtol4))
		level.lab_vtol4 delete();
	node = getstruct("uav_crash", "script_noteworthy");
	floor = spawn_anim_model("floor");

	level.chinese_uav =  vignette_vehicle_spawn("anim_nx_vehicle_chinese_vtol", "chinese_uav");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["ally_01"] = level.baker;
	guys["player_rig"] = player_rig;
	guys["floor"] = floor;
	guys["chinese_uav"] = level.chinese_uav;

	arc = 15;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);
	
	// Part 1
	node anim_single(guys, "uav_crash");

	// Part 1 Idle
	node thread anim_loop(guys, "uav_crash_idle", "stop_idle");

	display_hint_timeout ("NX_SKYSCRAPER_HINT_PICK_UP_LASER", 10);

	while ( !level._player UseButtonPressed() )
		wait .1;
	
	node notify ("stop_idle");

	// Part 2
	node anim_single(guys, "uav_crash_p2");
	thread maps\nx_skyscraper_vtol::laser_setup();
	player_rig hide();

	// Part 2 idle
	node thread anim_loop(guys, "uav_crash_p2_idle", "stop_idle");
	
	level waittill ( "laser_coordinates_received" );

	node notify ("stop_idle");
	player_rig show();

	// Part 3
	level._player DisableWeapons();
	node anim_single(guys, "uav_crash_p3");

	level._player unlink();

	player_rig delete();
	level.chinese_uav delete();
	floor delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

	flag_set( "flag_getup" );

}

get_up(ally_01)
{

	node = getstruct("get_up", "script_noteworthy");

	prop_rubble = spawn_anim_model("prop_rubble");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["player_rig"] = player_rig;
	guys["ally_01"] = level.baker;
	guys["prop_rubble"] = prop_rubble;

	arc = 0;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "get_up");

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player EnableWeapons();
	flag_set( "flag_vtol_floor_collapse_done" );
	level notify ( "floor_collapsed" );
	level._player DisableInvulnerability();

}

//*******************************************************************
// HALON                                                            *
//                                                                  *
//*******************************************************************

halon_gas_mask_spawn()
{
	// ally_01 = vignette_actor_spawn("ally_01", "ally_01"); //"value" (kvp), "anim_name"

	halon_gas_mask(level.baker);

	// ally_01 vignette_actor_delete();
}

halon_gas_mask(ally_01)
{

	node = getstruct("halon_gas_mask", "script_noteworthy");

	halon_gas_mask_01 = spawn_anim_model("halon_gas_mask_01");

	halon_gas_mask_02 = spawn_anim_model("halon_gas_mask_02");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["player_rig"] = player_rig;
	guys["ally_01"] = ally_01;
	guys["halon_gas_mask_01"] = halon_gas_mask_01;
	guys["halon_gas_mask_02"] = halon_gas_mask_02;

	arc = 0;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "halon_gas_mask");

	level._player unlink();

	player_rig delete();
	halon_gas_mask_01 delete();
	halon_gas_mask_02 delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player EnableWeapons();

}

lab_exit_stairs_spawn()
{
	ally01 = vignette_actor_spawn("ally_01", "ally_01"); //"value" (kvp), "anim_name"

	lab_exit_stairs(ally01);

	ally01 vignette_actor_delete();
}

lab_exit_stairs(ally01)
{

	node = getstruct("lab_exit_stairs", "script_noteworthy");


	guys = [];
	guys["ally_01"] = ally01;

	node anim_single(guys, "lab_exit_stairs");

}

lab_exit_stairs_corner_spawn()
{
	ally01 = vignette_actor_spawn("ally_01", "ally_01"); //"value" (kvp), "anim_name"

	lab_exit_stairs_corner(ally01);

	ally01 vignette_actor_delete();
}

lab_exit_stairs_corner(ally01)
{

	node = getstruct("lab_exit_stairs", "script_noteworthy");


	guys = [];
	guys["ally_01"] = ally01;

	node anim_single(guys, "lab_exit_stairs_corner");

}

//*******************************************************************
// VAULT                                                            *
//                                                                  *
//*******************************************************************

vault_entrance_spawn()
{
	ally01 = vignette_actor_spawn("ally_01", "ally_01"); //"value" (kvp), "anim_name"
	civ_01 = vignette_actor_spawn("civ_01", "civ_01"); //"value" (kvp), "anim_name"
	civ_02 = vignette_actor_spawn("civ_02", "civ_02"); //"value" (kvp), "anim_name"
	civ_03 = vignette_actor_spawn("civ_03", "civ_03"); //"value" (kvp), "anim_name"

	vault_entrance(ally01, civ_01, civ_02, civ_03);

	ally01 vignette_actor_delete();
	civ_01 vignette_actor_delete();
	civ_02 vignette_actor_delete();
	civ_03 vignette_actor_delete();
}

vault_entrance(ally01, civ_01, civ_02, civ_03)
{

	node = getstruct("vault_entrance", "script_noteworthy");


	guys = [];
	guys["ally_01"] = ally01;
	guys["civ_01"] = civ_01;
	guys["civ_02"] = civ_02;
	guys["civ_03"] = civ_03;

	node anim_single(guys, "vault_entrance");

}

vault_holotable_spawn()
{

	vault_holotable(level.baker);

}

vault_holotable(baker)
{
	node = getstruct("vault_holotable", "script_noteworthy");

	servers = spawn_anim_model("servers");

	holotable = spawn_anim_model("holotable");

	guys = [];
	guys["servers"] = servers;
	guys["holotable"] = holotable;
	guys["ally_01"] = baker;

	node anim_single(guys, "vault_holotable");

}

vault_holotable_p2_spawn()
{
	vault_holotable_p2(level.baker);
}

vault_holotable_p2(baker)
{

	node = getstruct("vault_holotable", "script_noteworthy");

	servers = spawn_anim_model("servers");

	holotable = spawn_anim_model("holotable");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["servers"] = servers;
	guys["holotable"] = holotable;
	guys["ally_01"] = baker;
	guys["player_rig"] = player_rig;

	arc = 15;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "vault_holotable_p2");

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player EnableWeapons();

}

//*******************************************************************
// HANGAR                                                           *
//                                                                  *
//*******************************************************************

landing_pad_vtol_disembark_spawn()
{
	civ_01 = vignette_actor_spawn("civ_01", "civ_01"); //"value" (kvp), "anim_name"
	civ_02 = vignette_actor_spawn("civ_02", "civ_02"); //"value" (kvp), "anim_name"
	civ_03 = vignette_actor_spawn("civ_03", "civ_03"); //"value" (kvp), "anim_name"

	landing_pad_vtol_disembark(civ_01, civ_02, civ_03);

	civ_01 vignette_actor_delete();
	civ_02 vignette_actor_delete();
	civ_03 vignette_actor_delete();
}

landing_pad_vtol_disembark(civ_01, civ_02, civ_03)
{

	node = getstruct("landing_pad_vtol_disembark", "script_noteworthy");


	guys = [];
	guys["civ_01"] = civ_01;
	guys["civ_02"] = civ_02;
	guys["civ_03"] = civ_03;

	node anim_single(guys, "landing_pad_vtol_disembark");

}

landing_pad_vtol_spawn()
{
	//ally_01 = vignette_actor_spawn("ally_01", "ally_01"); //"value" (kvp), "anim_name"
	chinese_vtol = vignette_vehicle_spawn("anim_nx_vehicle_chinese_vtol", "chinese_vtol"); //"value" (kvp), "anim_name"

	landing_pad_vtol(level.baker, chinese_vtol);

	// ally_01 vignette_actor_delete();
	chinese_vtol vignette_vehicle_delete();
}

landing_pad_vtol(ally_01, chinese_vtol)
{

	node = getstruct("landing_pad_vtol", "script_noteworthy");

	guys = [];
	guys["ally_01"] = ally_01;
	guys["chinese_vtol"] = chinese_vtol;

	node anim_single(guys, "landing_pad_vtol");

}

landing_pad_window( )
{

	node = getstruct("landing_pad_window", "script_noteworthy");

	guys = [];
	guys["ally_01"] = level.baker;

	node anim_single(guys, "landing_pad_window");
	flag_set ("landing_pad_window_open");

}

landing_pad_climbjump_ally()
{

	node = getstruct("landing_pad_climbjump_ally", "script_noteworthy");

	guys = [];
	guys["ally_01"] = level.baker;

	node anim_single(guys, "landing_pad_climbjump_ally");

}

landing_pad_climbjump_player(ally01)
{

	node = getstruct("landing_pad_climbjump_ally", "script_noteworthy");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["ally_01"] = level.baker;
	guys["player_rig"] = player_rig;

	arc = 0;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "landing_pad_climbjump_player");

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );

}

landing_pad_window_player( )
{
	flag_wait ("flag_landing_pad_window_player");
	// player_body = vignette_actor_spawn("player_body", "player_body"); //"value" (kvp), "anim_name"

	node = getstruct("landing_pad_window", "script_noteworthy");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );
	player_body = spawn_anim_model( "player_body" );

	guys = [];
	guys["player_body"] = player_body;
	guys["player_rig"] = player_rig;

	arc = 0;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "landing_pad_window_player");

	level._player unlink();

	player_rig delete();
	player_body delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	maps\nx_skyscraper_util::player_remove_abilities();

	level notify ("player_out_window");

	//player_body vignette_actor_delete();
}

landing_pad_edgeclimb(ally01)
{

	node = getstruct("landing_pad_edgeclimb", "script_noteworthy");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["ally_01"] = level.baker;
	guys["player_rig"] = player_rig;

	arc = 0;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "landing_pad_edgeclimb");

	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	level._player EnableWeapons();
	maps\nx_skyscraper_util::player_restore_abilities();

	level notify ("landing_pad_vignettes_done");

}

//*******************************************************************
// OUTRO                                                            *
//                                                                  *
//*******************************************************************

atrium_crash_spawn()
{
	helicopter = vignette_vehicle_spawn("anim_nx_vehicle_littlebird", "helicopter"); //"value" (kvp), "anim_name"

	atrium_crash(level.baker, helicopter);

	helicopter vignette_vehicle_delete();
}

atrium_crash(baker, helicopter)
{

	flag_wait( "flag_rappel_swing_done" );

	node = getstruct("atrium_crash", "script_noteworthy");

	level._player FreezeControls( true );
	level._player allowprone( false );
	level._player allowcrouch( false );
	level._player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["player_rig"] = player_rig;
	guys["ally_01"] = baker;
	guys["helicopter"] = helicopter;

	arc = 0;

	level._player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "atrium_crash");
	level._player unlink();

	player_rig delete();

	level._player FreezeControls( false );
	level._player allowprone( true );
	level._player allowcrouch( true );
	flag_set( "flag_atrum_crash_done" );

}
//*******************************************************************
// Security checkpoint guard                                        *
//                                                                  *
//*******************************************************************

security_guard_talks_to_fp(security_guard_at_checkpoint)
{

	node = getstruct("security_baker", "script_noteworthy");

	guys = [];
	guys["security_guard_at_checkpoint"] = level.lobby_guard_1;

	node anim_single(guys, "security_guard_talks_to_fp");

}









