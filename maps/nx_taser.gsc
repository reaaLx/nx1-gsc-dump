
main()
{
	SetDvar( "nx_taser_lockon_range", "1024" );
	SetDvar( "nx_taser_lockon_pull", "100000" );
	SetDvar( "nx_taser_lockon_cos_halfcone", "0.7" );// = cos(5 degrees)
	
	//I think I can use notetracks to play the fx, and not a call, this will make it flexible.
	
	animscripts\utility::add_note_track_effect( "taser_fx", "J_Knee_LE", "all", LoadFX( "nx/impacts/nx_taser_paralyze_sparks_runner" ) );
	animscripts\utility::add_note_track_effect( "taser_fx", "J_CoatRear_LE", "all", LoadFX( "nx/impacts/nx_taser_paralyze_sparks_runner" ) );
	animscripts\utility::add_note_track_effect( "taser_fx", "J_Elbow_LE", "all", LoadFX( "nx/impacts/nx_taser_paralyze_sparks_runner" ) );
	animscripts\utility::add_note_track_effect( "taser_fx", "J_Shoulder_RI", "all", LoadFX( "nx/impacts/nx_taser_paralyze_sparks_runner" ) );
	animscripts\utility::add_note_track_effect( "taser_fx", "J_CoatFront_RI", "all", LoadFX( "nx/impacts/nx_taser_paralyze_sparks_runner" ) );
	animscripts\utility::add_note_track_effect( "taser_fx", "J_Spine4", "all", LoadFX( "nx/impacts/nx_taser_paralyze" ) );
	
	// Dan: taser no longer locks on
	//foreach ( player in level._players )
	//{
	//	player nx_taser_clear_lock_on();
	//	player thread nx_taser_fired_notify();
	//}
}

/* Dan: taser no longer locks on

nx_taser_fired_notify()
{
	self endon( "death" );
	
	assert( self.classname == "player" );

	while ( true )
	{
		self waittill( "weapon_fired" );

		weap = self GetCurrentWeapon();
		if ( weap != "nx_taser" )
		{
			continue;
		}	
		
		// self nx_taser_lock_on();

		self notify( "taser_fired" );
		
		
	}
}


//called on the player.
nx_taser_lock_on()
{	
	aim_dir = vectornormalize( AnglesToForward(self GetPlayerAngles()) );
	target = self GetEnemyInCone( self.origin, aim_dir, GetDvarFloat( "nx_taser_lockon_cos_halfcone" ) , GetDvarFloat( "nx_taser_lockon_range" ) );
	
	if ( IsDefined(target))
	{
		///#iprintln("Found target" );#/
		//check for target change. Also pre-emptively check if no target has previously been set.
		if ( !IsDefined(self.taser.target) || target != self.taser.target)
		{
			self.taser.target = target;
			self notify( "taser_target_changed" );
			
			target thread debug_draw_tag_bipod();
		}	
		
		if ( self.taser.target_attractor != -1 )
		{
			///#iprintln("Removing attractor so it can be refreshed...." );#/
			Missile_DeleteAttractor( self.taser.target_attractor );
		}
		
		///#iprintln("Setting attractor on target." );#/		
		offset = (target GetTagOrigin( "J_Spine4" )) - (target GetTagOrigin( "tag_origin" ));
		self.taser.target_attractor = Missile_CreateAttractorEnt( target, GetDvarFloat( "nx_taser_lockon_pull" ), GetDvarFloat( "nx_taser_lockon_range" ), self, offset );	
	}
	else
	{
		///#iprintln("No Farget Found, clearing taser targeting" );#/
		nx_taser_clear_lock_on();
	}
}

nx_taser_clear_lock_on()
{
	if ( !isdefined( self.taser ) )
	{
		self.taser = spawnStruct();
	}	
	
	if ( IsDefined(self.taser.target_attractor) && self.taser.target_attractor != -1 )
	{
		Missile_DeleteAttractor( self.taser.target_attractor );
	}	

	self.taser.target = undefined;
	self.taser.target_attractor = -1;
}

debug_draw_tag_bipod()
{
	self endon("death");
	self endon("taser_target_changed");
	while ( true )
	{	
		pos = self GetTagOrigin( "J_Spine4" );
		
		debug_draw_origin(pos);
		
		wait .05;
	}
}

debug_draw_origin( origin )
{
	line( origin + ( 16, 0, 0 ), origin + ( -16, 0, 0 ), ( 1, 0, 0 ), 1 );
	line( origin + ( 0, 16, 0 ), origin + ( 0, -16, 0 ), ( 0, 1, 0 ), 1 );
	line( origin + ( 0, 0, 16 ), origin + ( 0, 0, -16 ), ( 0, 0, 1 ), 1 );
}

*/
