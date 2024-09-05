//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX Vignette utility functions								**
//                                                                          **
//    Created: 3/8/2011 - Travis Chen (trchen x4143)						**
//                                                                          **
//****************************************************************************

#include maps\_anim;
#include maps\_utility;
#include common_scripts\utility;
#include maps\_hud_util;
#include maps\_vehicle;

// tagTC<note> - Current functions to support the NX Vignette Pipeline
// We will extends as we work through the pipeline and prove it out

// See wiki write up at:
// http://wiki2.neversoft.com/index.php/COD:_NX_Vignette_Pipeline

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// tagTC<note> - Register function currently checks for valid flag and waits, 
// then plays the vignette. It'll also be a central hook point if we plan
// to extend the vignette logic (e.g. adding debug points to test scenes)
vignette_register( vignette_func, vignette_flag )
{
	// Return if the vignette flag doesn't exist
	if ( !flag_exist ( vignette_flag ) )
	{
		IPrintLn( "VIGNETTE ERROR: vignette flag " + vignette_flag + " doesn't exist." );
		return;		
	}

	// Wait for vignette
	flag_wait( vignette_flag );

	// Play the vignette
	level thread [[vignette_func]]();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_actor_spawn( spawner_name, anim_name )
{
    // Force spawn vignette actor
    spawner = GetEnt( spawner_name, "targetname" );
	spawner.script_forcespawn = 1;
    spawner thread add_spawn_function( ::vignette_actor_spawn_func );

    vignette_actor = spawner spawn_ai();
    vignette_actor.animname = anim_name;

    return vignette_actor;
}

vignette_actor_spawn_func()
{
    self endon ( "death" );

    // Ignore vignette actors, thread magic bullet shield
    self thread magic_bullet_shield();
	self thread vignette_actor_ignore_everything();
}

vignette_actor_delete()
{
	if( IsDefined( self.magic_bullet_shield ) )
	{
		self stop_magic_bullet_shield();
	}
    self delete();    
}

vignette_actor_kill()
{
    if ( !isalive( self ) )
        return;

	if( IsDefined( self.magic_bullet_shield ) )
	{	
		self stop_magic_bullet_shield();
	}

    self.allowDeath = true;
    self.a.nodeath = true;
    self set_battlechatter( false );

    self kill(); 
}

vignette_actor_ignore_everything()
{
	self.ignoreall = true;
	self.ignoreme = true;
	self.grenadeawareness = 0;
	self.ignoreexplosionevents = true;
	self.ignorerandombulletdamage = true;
	self.ignoresuppression = true;
	self.fixednode = false;
	self.disableBulletWhizbyReaction = true;
	self disable_pain();
	self.dontavoidplayer = true;
	self.og_newEnemyReactionDistSq = self.newEnemyReactionDistSq;
	self.newEnemyReactionDistSq = 0;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_vehicle_spawn( vehicle_name, anim_name )
{
	vehicle = spawn_vehicle_from_targetname( vehicle_name );
	vehicle.animname = anim_name;

	return vehicle;
}

vignette_vehicle_delete()
{
	self delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************