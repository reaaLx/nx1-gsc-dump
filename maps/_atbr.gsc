#include maps\_utility;
#include maps\_hud_util;
#include common_scripts\utility;
#include common_scripts\_atbr;



//*******************************************************************
//																	*
//																	*
//*******************************************************************
init_atbr()
{
	// Register local callbacks. 
	level._atbr_callback_set_targets = ::atbr_set_targets;
	level._atbr_callback_remove_targets = ::atbr_remove_targets;
	
	// Weapons. 
	level._atbr_weapons = [];
	level._atbr_weapons["base"] = "atbr_base";
 	level._atbr_weapons["detonate"] = "atbr_detonate";
 	level._atbr_weapons["missile"] = "atbr_missile";
 	level._atbr_weapons["bullet"] = "atbr_bullet";

	common_scripts\_atbr::atbr_common_init();
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
give_atbr()
{
	common_scripts\_atbr::atbr_common_give();
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
atbr_set_targets( missile )
{
	// Targets. 
	self thread add_target_draw();
	ai_list = getaiarray( "all" );
	foreach( ai in ai_list )
	{
		ai thread add_target_draw();
	}
	thread draw_targets( missile, self );
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
atbr_remove_targets()
{
	thread remove_targets();
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
add_target_draw()
{
	if ( !isdefined( level._atbr_targets ) )
	{
		level._atbr_targets = [];
	}
	level._atbr_targets[ level._atbr_targets.size ] = self;

	// Remove target on death. 
	self waittill( "death" );
	self remove_target_draw();
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
remove_target_draw()
{
	if ( IsDefined( self.has_target_shader ) )
	{
		self.has_target_shader = undefined;
		Target_Remove( self );
	}
	level._atbr_targets = array_remove( level._atbr_targets, self );
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
draw_targets( missile, controlling_player )
{
	missile endon( "death" );

	if ( !isdefined( level._atbr_targets ) )
	{
		return;
	}

	// Draw update. 
	targets_per_frame = 5;
	targets_drawn = 0;
	time_between_updates = .05;
	for( ;; )
	{
		foreach( tgt in level._atbr_targets )
		{
			if( IsAlive( tgt ))
			{
				tgt draw_target( controlling_player );
				targets_drawn++;
				if( targets_drawn >= targets_per_frame )
				{
					targets_drawn = 0;
					wait time_between_updates;
				}
			}
		}
		wait( 0.001 );
	}
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
draw_target( controlling_player )
{
	// Shader setup. 
	self.has_target_shader = true;
	Target_Set( self, ( 0, 0, 64 ) );
	if( IsAI( self ))
	{
		Target_SetShader( self, "remotemissile_infantry_target" );
	}
	else if( IsPlayer( self ) )
	{
		Target_SetShader( self, "hud_fofbox_self_sp" );
	}
	else
	{
		Target_SetShader( self, "veh_hud_target" );
	}

	// Target drawing. 
	Target_ShowToPlayer( self, controlling_player );
	if( IsPlayer( self ) && self != controlling_player )
	{
		Target_HideFromPlayer( controlling_player, self );
	}
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
remove_targets()
{
	foreach( tgt in level._atbr_targets )
	{
		tgt remove_target_draw();
	}
}
