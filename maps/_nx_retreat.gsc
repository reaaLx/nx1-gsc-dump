//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX Retreat													**
//                                                                          **
//    Created: 7/8/2011 - Travis Chen (trchen x4143)						**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// this - enemy ai
check_retreat_triggers()
{
	if( !IsDefined( self.script_retreat ) )
	{
		return;
	}
	retreat_trigger_name = self.script_retreat;

	self endon( "death" );

	// Get the associated retreat triggers
	retreat_triggers = GetEntArray( "retreat_trigger", "targetname" );

	foreach( retreat_trigger in retreat_triggers )
	{
		if( retreat_trigger.script_retreat == retreat_trigger_name )
		{
			self thread retreat_trigger( retreat_trigger, retreat_trigger_name );
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// this - enemy ai
retreat_trigger( trigger, retreat_trigger_name )
{
	self endon( "death" );

	// Wait for retreat trigger
	trigger waittill( "trigger" );

	// Notify that enemy has new retreat
	self notify( "new_retreat" );
	self endon( "new_retreat" ); 

	// Wait for look at if defined
	if( IsDefined( trigger.script_dot ) )
	{
		self wait_for_look_at_enemy( retreat_trigger_name, trigger.script_dot );
	}

	// Retreat enemy
	if( IsAlive( self ) )
	{
		self notify( "retreating" );
		
		self.goalradius = 0;

		retreat_node = GetNode( trigger.target, "targetname" );  
		if( IsDefined( retreat_node ) )
		{
			self SetGoalNode( retreat_node );
		}
		else
		{
			IPrintln( "WARNING: Retreat " + retreat_trigger_name + " missing Goal Node" );
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// this - enemy ai
wait_for_look_at_enemy( retreat_trigger_name, dot )
{
	self endon( "death" );
	self endon( "new_retreat" );

	// Wait for player to see enemy
	while( 1 )
	{
		look_at_enemy = within_fov( level._player.origin, level._player getplayerangles(), self.origin, Cos( dot ) );
		if( look_at_enemy )
		{
			break;
		}
		wait( 0.05 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
