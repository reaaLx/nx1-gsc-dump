//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  NX FX Utility Scripts										**
//                                                                          **
//    Created: 3/30/2011 - Johnny Ow										**
//                                                                          **
//****************************************************************************

#include common_scripts\utility;
#include maps\_utility;

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: fx_delete_createFXEnt_by_fxID( fxID, removeFromArray, immediate )"
"Summary: Delete entities from level._createFXEnt[] by fxID"
"Module: FX Utility"
"CallOn: "
"MandatoryArg: <fxID> fxID of the entities to delete"
"OptionalArg: <removeFromArray> whether the entities should also be removed from level.createFXEnt[]"
"OptionalArg: <immediate> whether to delete particles immediately"
"Example: fx_delete_createFXEnt_by_fxID( "fx_test", false, false );"
"SPMP: both"
///ScriptDocEnd
=============
*/

fx_delete_createFXEnt_by_fxID( fxID, removeFromArray, immediate )
{
	if ( !isDefined( removeFromArray ) )
		removeFromArray = false;

	if ( !isDefined( immediate ) )
		immediate = false;

	inc = 0;

	foreach ( ent in level._createFXEnt )
	{
		if ( ent.v[ "fxid" ] == fxID )
		{
			if ( isDefined( ent.looper ) )
			{
				if ( removeFromArray )
					level._createFXEnt = array_Remove( level._createFXEnt, ent );
	
				ent.looper delete( immediate );
			}
		}

		inc++;

		if ( inc > 3 )
		{
			inc = 0;
			wait .05;
		}
	}
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: fx_delete_createFXEnt_by_vol( volName, removeFromArray, immediate )"
"Summary: Delete entities from level._createFXEnt[] by volume"
"Module: FX Utility"
"CallOn: "
"MandatoryArg: <volName> name of volume that contains entities to delete"
"OptionalArg: <removeFromArray> whether the entities should also be removed from level.createFXEnt[]"
"OptionalArg: <immediate> whether to delete particles immediately"
"Example: fx_delete_createFXEnt_by_fxID( "fx_test", false );"
"SPMP: both"
///ScriptDocEnd
=============
*/

fx_delete_createFXEnt_by_vol( volName, removeFromArray, immediate )
{
	volume = getEnt( volName, "targetname" );
	assert( isDefined( volume ) );

	if ( !isDefined( removeFromArray ) )
		removeFromArray = false;

	if ( !isDefined( immediate ) )
		immediate = false;

	tester = spawn( "script_origin", ( 0, 0, 0) );
	inc = 0;

	foreach ( ent in level._createFXEnt )
	{
		if ( isDefined( ent.looper ) )
		{
			tester.origin = ent.v[ "origin" ];

			if (tester isTouching( volume ) )
			{
				if ( removeFromArray )
					level._createFXEnt = array_Remove( level._createFXEnt, ent );

				ent.looper delete( immediate );
			}
		}

		inc++;

		if ( inc > 3 )
		{
			inc = 0;
			wait .05;
		}
	}

	tester delete();
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: fx_restart_createFXEnt_by_vol( volName )"
"Summary: Restart level._createFXEnt[] entities by volume"
"Module: FX Utility"
"CallOn: "
"MandatoryArg: <volName> name of volume that contains entities to delete"
"Example: fx_delete_createFXEnt_by_fxID( "fx_test" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

fx_restart_createFXEnt_by_vol( volName )
{
	volume = getEnt( volName, "targetname" );
	assert( isDefined( volume ) );

	tester = spawn( "script_origin", ( 0, 0, 0) );
	inc = 0;

	foreach ( ent in level._createFXEnt )
	{
		tester.origin = ent.v[ "origin" ];

		if (tester isTouching( volume ) )
		{
			ent restartEffect();
		}

		inc++;

		if ( inc > 3 )
		{
			inc = 0;
			wait .05;
		}
	}

	tester delete();
}

//*******************************************************************
//					                                              	*
//					                                              	*
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: fx_delete_all( immediate )"
"Summary: Delete all entities from level._createFXEnt[]"
"Module: FX Utility"
"CallOn: "
"OptionalArg: <immediate> kills all existing FX elements belong to this entity immediately."
"Example: fx_delete_all();"
"SPMP: both"
///ScriptDocEnd
=============
*/

fx_delete_all( immediate )
{
	foreach ( entFx in level._createfxent )
	{
		if ( isdefined( entFx.looper ) )
		{
			if ( isdefined( immediate ) )
			{
				entFx.looper delete( immediate );
			}
			else
			{
				entFx.looper delete();
			}
		}
		entFx notify( "stop_loop" );
    }
	level._createFXent = [];
}


/*
=============
///ScriptDocBegin
"Name: fx_set_skyfog( height_start, height_end, height_blend, transition_time )"
"Summary: Set new target skyfog parameters"
"Module: FX Utility"
"CallOn: "
"OptionalArg: "
"Example: fx_set_skyfog( 0.6, 1.4, 0.8, 3.0 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

fx_set_skyfog( height_start, height_end, height_blend, transition_time )
{
	if (transition_time > 0.2)
	{
		thread lerp_savedDvar( "r_fog_height_blend", height_blend, transition_time );
		thread lerp_savedDvar( "r_fog_height_start", height_start, transition_time );
		thread lerp_savedDvar( "r_fog_height_end", height_end, transition_time );
	} else {
		// small values don't lerp well - just set the value
		SetSavedDVar( "r_fog_height_blend", height_blend);
		SetSavedDVar( "r_fog_height_start", height_start);
		SetSavedDVar( "r_fog_height_end", height_end);
	}

	wait transition_time; // wait until they're done transitioning to return
}

/*
=============
///ScriptDocBegin
"Name: fx_secondary_damage_trigger( ent )"
"Summary: setup secondary effects trigger for this effect entity"
"Module: FX Utility"
"CallOn: "
"OptionalArg: "
"Example: fx_secondary_damage_trigger( ent );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
fx_secondary_damage_trigger( ent )
{
	bDebugDraw = false;

    // Create a node at the FX's position
    org = Spawn( "script_model", ent.v[ "origin"] + (0,0,10) );

	// debug locations
	if (bDebugDraw)
		thread draw_circle_until_notify( org.origin, 1, 0, 1, 0, ent, "stop_drawing_circle" );

    // Make it damageable
    org setCanDamage( true );
	org SetCanRadiusDamage( true );

    ent.v[ "new_org" ] = org; 

    while( true )
    {
        org waittill( "damage", damage, attacker, direction_vec, point, damageType, modelName, tagName );

		wait_timer = 0;
		damage_speed = 0;
		delay_mult = 0.0; // delay factor to mult against distance and use for the wait timer.

		// ********************************************************
		// speeds of concussive forces
		// speed of sound (for reference) = 13512 inches per second

		// dynamite = 11811 inches/second
		// c4 = 354331 inches/second
		// ********************************************************

		switch( damageType )
		{
			case "mod_melee":
			case "mod_crush":
			case "melee":
			case "mod_pistol_bullet":
			case "mod_rifle_bullet":
			case "bullet":
			case "mod_grenade":
			case "MOD_GRENADE_SPLASH":
				damage_speed = 11811; // dynamite
				break;
			case "mod_projectile":
			case "mod_projectile_splash":
			case "mod_explosive":
			case "c4":
				damage_speed = 354331; // c4
				break;
			case "splash":
				damage_speed = 11811; // dynamite
				break;
			case "mod_impact":
			case "unknown":
			default:
				break;
		}

		wait_factor = 2.0; // multiplier on the wait
		if ( damage_speed > 0 )
		{
			// Get distance from explosion to this fx origin

			distance_from_damage = distance( point, org.origin );  // raw distance
			wait_timer = (distance_from_damage / damage_speed); // time to wait
			direction_vec = vectornormalize(org.origin - point);

			wait (wait_timer * wait_factor);
			PlayFX( level._effect[ ent.v["fxid"] ], org.origin, direction_vec, ent.v[ "up" ] );
		}
		wait 1; // wait for reset
    }
}

/*
=============
///ScriptDocBegin
"Name: fx_setup_secondary_damage_effects()"
"Summary: setup secondary effects triggers for CreateFX placed nodes with a fxid that starts with nx_fx_react"
"Module: FX Utility"
"CallOn: "
"OptionalArg: "
"Example: fx_setup_secondary_damage_effects();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
fx_setup_secondary_damage_effects()
{
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		for ( i = 0; i < level._createFXent.size; i++ )
		{
			ent = level._createFXent[ i ];
	
			if ( ent.v[ "type" ] == "exploder" )
			{
				if (string_starts_with(ent.v[ "fxid" ], "nx_fx_react") )
				{
					thread fx_secondary_damage_trigger( ent ); // setup the trigger on this createfx entity
				}
			}
		}
	}
	thread setup_reactive_animated_models();
}

#using_animtree( "animated_props" );
setup_reactive_animated_models()
{
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		reactive_models = GetEntArray( "reactive_animated_model", "targetname" );
	
/*		for ( i=0; i<reactive_models.size; i++ )
		{
			reactive_models[i].animname = level._anim_prop_models[ reactive_models[i].model ][ "idle" ];
			reactive_models[i] assign_animtree();
		}
	
		anim_rate = 0.5;
	*/
		for ( i=0; i<reactive_models.size; i++ )
		{

			// wait running_offset;
			// reactive_models[i] SetAnim( reactive_models[i] getAnim("nx_pinetree_react0_idle"), 0.5, 0.1, 0.2); //(RandomFloat(0.5) + 0.5));
	//		reactive_models[i] SetAnimRestart( self getAnim("nx_pinetree_react0_static"), static_weight, blend_to_time, anim_speed);
			reactive_models[i] thread fx_secondary_damage_anim_trigger();
		}
	}
}

// to do:
// + take into account the local rotation of the tree
// + re-reig with fewer trunk bones and some branch bones
// + 3 idles of varying intensity for general wind
// + adjust strength of bend based on distance
// + notetracks for bending when we want dust and such to come off
// + dust tag arrays
// + bird tag arrays
// + leaves tag arrays
// + effect names for these tag arrays

#using_animtree( "animated_props" );
fx_secondary_damage_anim_trigger()
{
	bDebug = false; // debug locations

	model = self.model;

	if (bDebug)
		thread draw_circle_until_notify( self.origin, 10, 1, 1, 1, self, "stop_drawing_circle" );

    // Make it damageable
    self setCanDamage( true );
	self SetCanRadiusDamage( true );

    while( true )
    {
		self UseAnimTree( #animtree );
		keys = GetArrayKeys( level._anim_prop_models[ model ][ "anims" ] );
		animkey = keys[0]; // idle
		// animkey = keys[ RandomInt( keys.size ) ];
		animation = level._anim_prop_models[ model ][ "anims" ][ animkey ];
		
		self SetAnimRestart( animation, 1, 1, 0.33 );
		//self SetAnimTime( animation, RandomFloatRange( 0, 1 ) );

		// iprintln ("start waiting ...");
        self waittill( "damage", damage, attacker, direction_vec, point, damageType, modelName, tagName );
		
		if (bDebug)
			IPrintLn( "damage!" );

		// iprintln ("Damage Type : " + damageType );

		wait_timer = 0;
		damage_speed = 0;
		delay_mult = 0.0; // delay factor to mult against distance and use for the wait timer.

		// ********************************************************
		// speeds of concussive forces
		// speed of sound (for reference) = 13512 inches per second

		// dynamite = 11811 inches/second
		// c4 = 354331 inches/second
		// ********************************************************

		switch( damageType )
		{
			case "mod_melee":
			case "mod_crush":
			case "melee":
			case "mod_pistol_bullet":
			case "mod_rifle_bullet":
			case "bullet":
			case "mod_grenade":
			case "MOD_GRENADE_SPLASH":
				damage_speed = 11811; // dynamite
				break;
			case "mod_projectile":
			case "mod_projectile_splash":
			case "mod_explosive":
			case "c4":
				damage_speed = 354331; // c4
				break;
			case "splash":
				damage_speed = 11811; // dynamite
				break;
			case "mod_impact":
			case "unknown":
			default:
				break;
		}

		// iprintln ("Ds " + damage_speed );
		if ( damage_speed > 0 )
		{
			// Get distance from explosion to this fx origin
			distance_from_damage = distance( point, self.origin );  // raw distance
			wait_timer = (distance_from_damage / damage_speed); // time to wait
			direction_vec = (self.origin - point);

			dir_north = false;
			dir_east = false;
			direction_vec *= (1,1,0); // don't consider z for this
			direction_vec = vectornormalize(direction_vec);

			if (bDebug)
			{
				thread draw_line_for_time( self.origin, self.origin + (direction_vec * 200), 1, 1, 1, 10.0 );
				//thread draw_line_for_time( self.origin, self.origin + (AnglesToForward(self.angles) * 50), 1, 0, 0, 10.0 );
				//thread draw_line_for_time( self.origin, self.origin + (AnglesToRight(self.angles) * 50), 0, 1, 0, 10.0 );
				//thread draw_line_for_time( self.origin, self.origin + (AnglesToUp(self.angles) * 50), 0, 0, 1, 10.0 );

				thread draw_line_for_time( self.origin + (0,0,10), self.origin + (20,0,10), 1, 0, 0, 10.0 );
				thread draw_line_for_time( self.origin + (0,0,10), self.origin + (0,20,10), 0, 1, 0, 10.0 );
				thread draw_line_for_time( self.origin + (0,0,10), self.origin + (0,0, 30), 0, 0, 1, 10.0 );
			}


			if ( direction_vec[0] > 0 )
				dir_east = true;
			if ( direction_vec[1] > 0 )
				dir_north = true;

			// init weights
			north_weight = 0;
			east_weight = 0;
			west_weight = 0;
			south_weight = 0;
			north_weight_angle = 0;
			south_weight_angle = 0;
			east_weight_angle = 0;
			west_weight_angle = 0;

			if (dir_north)
			{
				north_weight_angle = acos( VectorDot(direction_vec, (0,1,0)) );
			} else {
				south_weight_angle = acos( VectorDot(direction_vec, (0,-1,0)) );
			}

			if (dir_east)
			{
				east_weight_angle = acos( VectorDot(direction_vec, (1,0,0)) );
			} else {
				west_weight_angle = acos( VectorDot(direction_vec, (-1,0,0)) );
			}

			//north_weight_angle = acos( VectorDot(direction_vec, (0,1,0)) );
			//south_weight_angle = acos( VectorDot(direction_vec, (0,-1,0)) );
			//east_weight_angle  = acos( VectorDot(direction_vec, (-1,0,0)) );
			//west_weight_angle  = acos( VectorDot(direction_vec, (1,0,0)) );

			if (north_weight_angle > 90.0) {north_weight_angle = 0;}
			if (south_weight_angle > 90.0) {south_weight_angle = 0;}
			if (east_weight_angle > 90.0) {east_weight_angle = 0;}
			if (west_weight_angle > 90.0) {west_weight_angle = 0;}

			north_weight = (north_weight_angle / 90.0);
			south_weight = (south_weight_angle / 90.0);
			east_weight = (east_weight_angle / 90.0);
			west_weight = (west_weight_angle / 90.0);

			//if (bDebug)
//				IPrintLn( ("weights: " + north_weight + ", " + south_weight + ", " + east_weight + ", " + west_weight));


			anim_speed = 0.2;
			blend_to_time = 0.02;

			// calc weight for anim of the static (unmoving animation)
			// we're dampening the amount of bend based on the distance from the explosion
			static_weight = 0; // (wait_timer / 0.5);
			dampen_amt = abs(1.0-static_weight);

			wait (wait_timer * 2.5);

			if ((north_weight > 0) && (east_weight > 0))
			{
				if (bDebug)
					IPrintLn( ("NE: " + north_weight + ", " + east_weight + ":" + (north_weight + east_weight)));

				self SetAnimRestart( level._anim_prop_models[ model ][ "anims" ][ "static" ], static_weight, blend_to_time, anim_speed);
				self SetAnimRestart( level._anim_prop_models[ model ][ "anims" ][ "north" ], north_weight, blend_to_time, anim_speed);
				self SetAnimRestart( level._anim_prop_models[ model ][ "anims" ][ "east" ], east_weight, blend_to_time, anim_speed);
			}
			else if ((north_weight > 0) && (west_weight > 0))
			{
				if (bDebug)
					IPrintLn( ("NW: " + north_weight + ", " + west_weight + ":" + (north_weight + west_weight)));
				self SetAnimRestart( level._anim_prop_models[ model ][ "anims" ][ "static" ], static_weight, blend_to_time, anim_speed);
				self SetAnimRestart( level._anim_prop_models[ model ][ "anims" ][ "north" ], north_weight, blend_to_time, anim_speed);
				self SetAnimRestart( level._anim_prop_models[ model ][ "anims" ][ "west" ], west_weight, blend_to_time, anim_speed);
			}
			else if ((south_weight > 0) && (east_weight > 0))
			{
				if (bDebug)
					IPrintLn( ("SE: " + south_weight + ", " + east_weight + ":" + (south_weight + east_weight)));
				self SetAnimRestart( level._anim_prop_models[ model ][ "anims" ][ "static" ], static_weight, blend_to_time, anim_speed);
				self SetAnimRestart( level._anim_prop_models[ model ][ "anims" ][ "south" ], south_weight, blend_to_time, anim_speed);
				self SetAnimRestart( level._anim_prop_models[ model ][ "anims" ][ "east" ], east_weight, blend_to_time, anim_speed);
				
			}
			else if ((south_weight > 0) && (west_weight > 0))
			{
				if (bDebug)
					IPrintLn( ("SW: " + south_weight + ", " + west_weight + ":" + (south_weight + west_weight)));
				self SetAnimRestart( level._anim_prop_models[ model ][ "anims" ][ "static" ], static_weight, blend_to_time, anim_speed);
				self SetAnimRestart( level._anim_prop_models[ model ][ "anims" ][ "south" ], south_weight, blend_to_time, anim_speed);
				self SetAnimRestart( level._anim_prop_models[ model ][ "anims" ][ "west" ], west_weight, blend_to_time, anim_speed);
			}

			// dust --------------------------------------------------------------------------------------------------------
			chance_to_create_dust = level._anim_prop_models[ model ][ "dust_chance" ];
			if (chance_to_create_dust > 0)
			{
				for (i=0; i<level._anim_prop_models[ model ][ "dust_tags" ].size; i++)
				{
					if (randomFloat(1.0) <= chance_to_create_dust)
					{
						tag_pos = self getTagOrigin( level._anim_prop_models[ model ][ "dust_tags" ][i] );
						PlayFX( level._effect[ level._anim_prop_models[ model ][ "dust_fx" ] ], tag_pos, direction_vec, (0,0,1) );
					}
				}
			}


			// leaves --------------------------------------------------------------------------------------------------------
			chance_to_create_dust = level._anim_prop_models[ model ][ "leaves_chance" ];
			if (chance_to_create_dust > 0)
			{
				for (i=0; i<level._anim_prop_models[ model ][ "leaves_tags" ].size; i++)
				{
					if (randomFloat(1.0) <= chance_to_create_dust)
					{
						tag_pos = self getTagOrigin( level._anim_prop_models[ model ][ "leaves_tags" ][i] );
						PlayFX( level._effect[ level._anim_prop_models[ model ][ "leaves_fx" ] ], tag_pos, direction_vec, (0,0,1) );
					}
				}
			}

			// birds --------------------------------------------------------------------------------------------------------
			chance_to_create_dust = level._anim_prop_models[ model ][ "birds_chance" ];
			if (chance_to_create_dust > 0)
			{
				for (i=0; i<level._anim_prop_models[ model ][ "birds_tags" ].size; i++)
				{
					if (randomFloat(1.0) <= chance_to_create_dust)
					{
						tag_pos = self getTagOrigin( level._anim_prop_models[ model ][ "birds_tags" ][i] );
						PlayFX( level._effect[ level._anim_prop_models[ model ][ "birds_fx" ] ], tag_pos, direction_vec, (0,0,1) );
					}
				}
			}
		}
		wait 0.2; // wait for reset
    }
}
