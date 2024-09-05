//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Rappel Util													**
//                                                                          **
//    Created: 4/13/2011 - Ben Kutcher										**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_nx_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_anim;
#include maps\_hud_util;

//*******************************************************************
//																	*
//																	*
//*******************************************************************
rappel_setup()
{
	objective_ent = GetEnt( "rappel_objective", "targetname" );
	objective_ent Hide();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
rappel_start()
{	
	level._player player_rappel();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
player_rappel()
{
	// Hide normal pipe
	pipe = GetEnt( "rappel_pipe", "targetname" );
	pipe Hide();

	rappel_trigger = getent( "player_rappel_use_trigger", "targetname" );
	rappel_trigger SetHintString( &"NX_HITHARD_RAPPEL_HINT" );	
	
	objective_ent = GetEnt( "rappel_objective", "targetname" );
	objective_ent Show();
	
	for ( ;; )
	{
		rappel_trigger waittill( "trigger" );
		
		if ( self isthrowinggrenade())
		{
			continue;
		}
		
		if ( self isswitchingweapon())
		{
			continue;
		}
		
		break;
	}

	level._player notify( "notify_rappel_start" );
	
	// Hide objective marker.
	objective_ent Hide();
	pipe Show();
	rappel_trigger delete();
	
	// Dvars. 
	SetSavedDvar( "compass", 0 );
	SetSavedDvar( "ammoCounterHide", 1 );
	SetSavedDvar( "actionSlotsHide", 1 );
	SetSavedDvar( "hud_showStance", 0 );
	SetSavedDvar( "hud_drawhud", 0 );
	
	// Player state. 
	self DisableWeapons();
	self DisableOffhandWeapons();
	self DisableWeaponSwitch();
	self AllowCrouch( false );
	self AllowProne( false );
	stance = self GetStance();
	self SetStance( "stand" );
	if ( stance != "stand" )
	{
		wait( 0.5 );
	}

	// Backup weapon. 
	old_weapon = self GetCurrentWeapon();

	// Hook up.
	player_rig = spawn_anim_model( "player_rig_rappel" );
	player_rig Hide();
	player_rope = spawn_anim_model( "rope" );
	player_rope Hide();
	player_rope.origin = self.origin;
	rig_and_rope[ 0 ] = player_rig;
	rig_and_rope[ 1 ] = player_rope;
	ent = GetEnt( "player_rappel_animent", "targetname" );
	ent anim_first_frame( rig_and_rope, "rappel_hookup" );

	// Link player. 	
	level.player_rig = player_rig;
	tag_origin = spawn_tag_origin();
	tag_origin LinkTo( player_rig, "tag_player", ( 0, 0, 0 ), ( 0, 0, 0 ));
	tag_origin_start = spawn_tag_origin();
	tag_origin_start.angles = self GetPlayerAngles();
	tag_origin_start.origin = self.origin;
	self PlayerLinkTo( tag_origin_start );
	self PlayerLinkToBlend( tag_origin, "tag_origin", 0.5, 0.2, 0.2 );
	tag_origin_start Delete();
	
	// Wait for the blend to complete and show the new rig. 
	wait( 0.5 ); 
	player_rig Show();
	player_rig DontCastShadows();
	player_rope Show();
	
	// Play the anim.
	ent anim_single( rig_and_rope, "rappel_hookup" );

	// Cleanup.	
 	self Unlink();
 	
 	player_rig Delete();
	player_rope Delete();
	
	self EnableWeapons();
	self EnableOffhandWeapons();
	self EnableWeaponSwitch();
	self AllowCrouch( true );
	self AllowProne( true );

 	SetSavedDvar( "compass", 1 );
 	SetSavedDvar( "ammoCounterHide", 0 );
 	SetSavedDvar( "actionSlotsHide", 0 );
 	SetSavedDvar( "hud_showStance", 1 );
 	SetSavedDvar( "hud_drawhud", 1 );

	level notify( "notify_rappel_complete" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
