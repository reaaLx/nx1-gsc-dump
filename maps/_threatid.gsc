//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Common file for all things threat ID							**
//                                                                          **
//    Created: 04.25.2011 - Riggs											**
//                                                                          **
//****************************************************************************

#include common_scripts\utility;
#include maps\_hud_util;
#include maps\_utility;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
main()
{
	precacheshader( "hud_loading_bar" );
	precacheshader( "hud_loading_bar_frame" );
	precacheshader( "threat_detection_grid" );
	precacheshader( "hud_color_swatch" );
	precacheshader( "hud_tid_bracket" );

	// Press^3 [{+actionslot 1}] ^7to toggle Threat ID.
	add_hint_string( "tid", &"SCRIPT_THREATID_USE" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
threat_id_enable_toggling()
{
	// tagBR< note >: Disabled for the GL
	return;

	thread display_hint( "tid" );
	level._player SetActionSlot( 1, "threatid" );

	thread threat_id_think();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
threat_id_think()
{
	level._player endon( "death" );

	// state can be:
	THREAT_ID_OFF = 0;
	THREAT_ID_BOOTUP = 1;
	THREAT_ID_ACTIVE = 2;
	THREAT_ID_DISABLE = 3;

	while ( 1 )
	{
		state = level._player GetThreatVisualizationState();
	
		switch( state )
		{
			case 1: //THREAT_ID_BOOTUP
				threatid_bootup_and_enable( true );
				break;
	
			case 3: //THREAT_ID_DISABLE
				threatid_disable_overlay_and_effect();
				break;
	
			default:
				// do nothing
				break;
		}

		wait 0.05;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
threatid_bootup_and_enable( toggle )
{
	THREAT_ID_BOOTUP = 1;
	THREAT_ID_ACTIVE = 2;

	state = level._player GetThreatVisualizationState();

	if ( state != THREAT_ID_ACTIVE )
	{
		if ( ( state != THREAT_ID_BOOTUP ) || ( IsDefined( toggle ) && toggle ) )
		{
			level._player SetThreatVisualizationState( THREAT_ID_BOOTUP );

			thread maps\_hud_util::play_threat_detect_bootup();
			level._player waittill( "threat_id_done_loading" );
			level._player SetThreatVisualizationState( THREAT_ID_ACTIVE );
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
threatid_disable_overlay_and_effect()
{
	THREAT_ID_OFF = 0;

	maps\_hud_util::disable_threat_id_overlay();
	level._player SetThreatVisualizationState( THREAT_ID_OFF );
}

