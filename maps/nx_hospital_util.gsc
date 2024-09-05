//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Mission Utils												**
//                                                                          **
//    Created: DATE - CREATOR												**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_nx_utility;


//*******************************************************************
//   Utility                                                        *
//                                                                  *
//*******************************************************************
waittill_flag_timeout( flag, timeout )//SCRIPT_KEEP
{
	if( !IsDefined( flag ) || !IsDefined( timeout ) )
	   return;
	   
	if( flag_exist( flag ) && flag( flag ) )
		return;

	level endon( flag );
	
	wait( timeout );	
}

//*******************************************************************
//   Actors                                                         *
//                                                                  *
//*******************************************************************
actor_teleport( actor, origin_targetname )//SCRIPT_KEEP
{
	org = GetEnt( origin_targetname, "targetname" );

	if( IsPlayer( actor ) )
	{
		actor SetPlayerAngles( org.angles );
		actor SetOrigin( org.origin );
	}
	else if(IsAI( actor ) )
	{
		actor ForceTeleport( org.origin, org.angles );
	}
}


// Deletes an actor after time
delete_after_time( time )
{
	self endon( "death" );

	wait time;
	if( !player_can_see_ai( self ))
	{
		self delete();
	}
}


//*******************************************************************
//      AI				                                            *
//                                                                  *
//*******************************************************************
ai_color_reset( color )// SCRIPT_KEEP
{
	if( !IsDefined( color ) )
	{
		if( IsDefined( self.ai_color ) )
			color = self.ai_color;
	}

	if( IsDefined( color ) )
	{
		self set_force_color( color );
		self enable_ai_color();
	}
}

ai_color_reset_array( ai_array, color )// SCRIPT_KEEP
{
	foreach( ai in ai_array )
	{
		ai ai_color_reset( color );
	}
}

ai_ignore_until_damage()
{
	self endon( "death" );

	self.ignoreAll = true;
	self.ignoreMe = true;

	self waittill( "damage" );

	self.ignoreAll = false;
	self.ignoreMe = false;
}

ai_ignore_until_damage_group( team )
{
	self.ignoreAll = true;
	self.ignoreMe = true;

	self waittill( "damage" );

	guys = array_removedead( team );

	foreach( guy in guys )
	{
		guy.ignoreAll = false;
		guy.ignoreMe = false;
	}
}

ai_ignore_until_flag( flag_name )
{
	self endon( "death" );

	self.ignoreAll = true;
	self.ignoreMe = true;

	flag_wait( flag_name );

	self.ignoreAll = false;
	self.ignoreMe = false;
}

//*******************************************************************
//      SQUAD			                                            *
//                                                                  *
//*******************************************************************
squad_add_ally( script_name, spawner_targetname, animname )// SCRIPT_KEEP
{
	if( !IsDefined( level.squad ) )
		level.squad = [];
	spawner = GetEnt( spawner_targetname, "targetname" );
	ally = spawner spawn_ai();
	ally.animname = animname;

	ally thread magic_bullet_shield();
	ally.ai_color = ally.script_forcecolor;
	ally ai_color_reset();
	ally.hero = true;
	ally make_hero();
	
	level.squad[script_name] = ally;
	if( ally.animname == "ally_alpha" )
		level.squad[ "ALLY_ALPHA" ] set_battlechatter_id( "bak" );

	
	return ally;	
}

squad_color_reset() //SCRIPT_KEEP
{
	ai_color_reset_array( level.squad );
}

squad_cqb( enable )
{
	foreach( actor in level.squad )
	{
		if( enable )
			actor enable_cqbwalk();
		else
			actor disable_cqbwalk();
	}
}

squad_sprint( enable )
{
	foreach( actor in level.squad )
	{
		if( enable )
			actor enable_sprint();
		else
			actor disable_sprint();
	}
}

//*******************************************************************
//      OFFENSIVE GRENADES		                                    *
//                                                                  *
//*******************************************************************


BLAST_RADIUS = 350;
DEBRIS_RADIUS = 500;
FUSE_DELAY = 1.0;

grenade_behavior()
{
	level._player waittill ( "grenade_fire", grenade, weaponname );
	volumes = GetEntArray ("indoor_volume", "script_noteworthy");
	if ( weaponname == "offensive_grenade")
	{
		foreach ( volume in volumes )
		{
			grenade thread check_for_interior_detonation( volume );
		}
		thread grenade_percussion_fuse( grenade );
	}
	thread grenade_behavior();
}

grenade_percussion_fuse( grenade )
{
	// wait until impact of any sort
	grenade waittill( "other" );
	wait( FUSE_DELAY );
	if( IsDefined( grenade ) )
	{
		grenade detonate();
	}
}

check_for_interior_detonation( volume )
{
	self waittill ("explode", position);
	proxy = spawn("script_model", position );
	if ( proxy IsTouching ( volume ))
	{
		PlayFX ( level._effect[ "offensive_grenade_indoor_explosion" ], proxy.origin );
		BadPlace_Brush( "", 5, volume, "axis" );
		Earthquake (0.3, 3, volume.origin, 850);
		volume activate_destructibles_in_volume(  );
		// iprintln ( "I blew up in: " + volume.targetname );
		grenade_victims = volume get_ai_touching_volume( "axis" );
		if ( level._player IsTouching( volume ) )
		{
			distance = Distance ( level._player.origin, proxy.origin );
			if ( distance <= BLAST_RADIUS )
			{
				SetDvar( "ui_deadquote", &"NX_HOSPITAL_FAIL_OFFENSIVE_GRENADE" );
				waittillframeend;
				level._player kill( proxy.origin, level._player );
			}
		}
		foreach ( victim in grenade_victims )
		{
			distance = Distance ( victim.origin, proxy.origin );
			if ( distance <= BLAST_RADIUS )
			{
				victim kill( proxy.origin, level._player );
				PlayFX ( level._effect[ "nx_concussion_grenade_gibs" ], victim.origin ); 
			}
			else if ( distance <= DEBRIS_RADIUS )
			{
				victim DoDamage ( 50, proxy.origin, level._player);
				victim flashBangStart( 3 );
			}
		}
		if ( IsDefined ( volume.target ))
		{
			openings = GetEntArray ( volume.target, "targetname");
			foreach ( opening in openings )
			{
				if ( opening.script_noteworthy == "window")
				{
					GlassRadiusDamage( opening.origin, 100, 1000, 1000 );
					PhysicsExplosionSphere( opening.origin, 100, 80, 2000 );
					forward = AnglesToForward( opening.angles );
					PlayFX ( level._effect[ "offensive_grenade_window" ], opening.origin, forward );
				}
				
				if ( opening.script_noteworthy == "door")
				{
					forward = AnglesToForward( opening.angles );
					PlayFX ( level._effect[ "offensive_grenade_door" ], opening.origin, forward);
				}
				
			}
		}
	}
	//waittillframeend;
	proxy delete();
}

// FLASHLIGHT ON GUN
FLASHLIGHT_FX = "flashlight";

attach_flashlight_gun( state )
{
	effect_id = level._effect[ FLASHLIGHT_FX ];
	effect_tag = "tag_flash";

	if( state )
	{
		PlayFXOnTag( effect_id, self, "tag_flash" );
		self thread detach_flashlight_gun_on_death();
	}
	else
	{
		StopFXOnTag( effect_id, self, "tag_flash" );
	}

	self.have_flashlight = state;
}

detach_flashlight_gun()
{
	self attach_flashlight_gun( false );
}

detach_flashlight_gun_on_death()
{
	self waittill( "death" );
	self detach_flashlight_gun();
}

// FLASHLIGHT IN HAND
attach_flashlight( state )
{
	if( IsDefined( self.patrol_walk_flashlight ) )
	{
		self set_generic_run_anim( random( self.patrol_walk_flashlight ), true );
	}
	
	self attach( "com_flashlight_on", "tag_inhand", true );
	self.have_flashlight = true;
	self flashlight_light( state );
	self thread detach_flashlight_on_death();
}

detach_flashlight_on_death()
{
	self waittill( "death" );
	if ( isdefined( self ) )
		self detach_flashlight();
}

detach_flashlight()
{
	if ( !isdefined( self.have_flashlight ) )
		return;
//	self detach( "com_flashlight_on", "tag_inhand" );	// This failed for some reason ( PJ )
	self flashlight_light( false );
	self.have_flashlight = undefined;
}

flashlight_light( state )
{
	flash_light_tag = "tag_light";

	if ( state )
	{
		flashlight_fx_ent = spawn( "script_model", ( 0, 0, 0 ) );
		flashlight_fx_ent setmodel( "tag_origin" );
		flashlight_fx_ent hide();
		flashlight_fx_ent linkto( self, flash_light_tag, ( 0, 0, 0 ), ( 0, 0, 0 ) );

		self thread flashlight_light_death( flashlight_fx_ent );
		playfxontag( level._effect[ FLASHLIGHT_FX ], flashlight_fx_ent, "tag_origin" );
	}
	else if ( isdefined( self.have_flashlight ) )
		self notify( "flashlight_off" );
}

flashlight_light_death( flashlight_fx_ent )
{
	self waittill_either( "death", "flashlight_off" );

	flashlight_fx_ent delete();
	self.have_flashlight = undefined;

}