#include common_scripts\utility;

//dierction of atbr missile, just off perefectly straight up.
ATBR_MISSILE_DIRECTION = ( 1.0, 1.0, 20.0 );

ATBR_HUD_TIMER_POS_X = 0.0;
ATBR_HUD_TIMER_POS_Y = -85.0;


//*******************************************************************
//																	*
//																	*
//*******************************************************************
atbr_common_init()
{
	// TagZP<NOTE> Moved atbr weapons into a new array as defined in the comment below
	// I did this because now mp and sp do not share the same weapon defs.
	//level._atbr_weapons["base"];
	//level._atbr_weapons["detonate"];
	//level._atbr_weapons["missile"];
	//level._atbr_weapons["bullet"];
	
	foreach( weapon in level._atbr_weapons )
	{
	 	PreCacheItem( weapon );
	}

	// Misc. 
   	VisionSetMissilecam( "missilecam" );
   	PreCacheShader( "remotemissile_infantry_target" );
   	PreCacheShader( "hud_fofbox_self_sp" );
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
atbr_common_give()
{
	
	self giveWeapon( level._atbr_weapons["base"] );
	if( isSP( ))
	{
		self givemaxammo( level._atbr_weapons["base"] );
	}
	else
	{
		//mp kill streak only supports one atbr missile
		self givestartammo( level._atbr_weapons["base"] );
	}
	
 	if( !isDefined( self.atbr_planted ))
 	{
 		self.atbr_planted = false;
 	}
	
	self SetActionSlot( 4, "weapon", level._atbr_weapons["base"] );	
	self.atbr_planted = false;
	
	// Watch the ATBR for this player. 
	self thread atbr_common_watch_base();
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
atbr_common_watch_base()
{
	self endon( "death" );

 	for( ;; )
 	{
 		self waittill( "grenade_fire", atbr_base, weapname );
 		if ( weapname == level._atbr_weapons["base"] || weapname == "claymore_mp" )
 		{
 			self.atbr_planted = true;
 			atbr_base.owner = self;
			self.attached = false;
 			atbr_base thread atbr_common_watch_detonation( self );
 			
 			self giveWeapon( level._atbr_weapons["detonate"] );
			self givemaxammo( level._atbr_weapons["detonate"] );
 			
			self switchtoweapon( level._atbr_weapons["detonate"] );
			
			if( !isSP( ))
			{
				return;
			}
 		}
 	}
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
atbr_common_watch_detonation( player )
{
	self endon( "death" );

 	for( ;; )
	{
 		player waittill( "detonate", weapname );
 		if ( weapname == level._atbr_weapons["detonate"] )
 		{			
			player.atbr_planted = false;
			
			atbr_takeoff_direction = ATBR_MISSILE_DIRECTION;
			missile = MagicBullet( level._atbr_weapons["missile"], self.origin, self.origin + atbr_takeoff_direction, player );
			
			missile.angles = (-90, self.angles[1], 0);
			self hide();

			atbr_common_attach_to_bullet( player, missile );

			if( isSP( ))
			{
				player switchtoweapon( level._atbr_weapons["base"] );
			}
			
			player TakeWeapon( level._atbr_weapons["detonate"] );
		
			// tagTMR<NOTE> Notifying complete switches weapons back to primary, causing incorrect
			// killstreak and stat tallies as the player gets kills while following the missle
			player notify( "atbr_complete" );

			self delete();
		}
		wait( 0.1 );
	}
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
atbr_common_attach_to_bullet( player, missile )
{
	wait( 0.25 );
	if( isdefined( missile ))
	{
		// Do not attach the player to multiple rockets. 
		if( player.attached == false )
		{
			
			if( isDefined( level._atbr_ammo_count ))
			{
				player._atbr_ammo_count = level._atbr_ammo_count;
			}
			
			if( isAlive( player ))
			{
				player.attached = true;
				player link_camera_and_controls( missile );
				player atbr_common_follow_missile( missile );
				missile waittill( "death" );
				player unlink_camera_and_controls();
			}
		}
	}
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************
atbr_common_follow_missile( missile )
{
	self endon( "death" );
	missile endon( "death" );
	
	// Link player. 
	self thread atbr_common_fire_shots( missile );
}

link_camera_and_controls( missile )
{
	self CameraLinkTo( missile, "tag_origin", 1);
	self ControlsLinkTo( missile );
	
	// Targets. 
	if( isdefined( level._atbr_callback_set_targets ))
	{
		self [[ level._atbr_callback_set_targets ]]( missile );
	}
	
	//if ammo count is defined create a hud elem for it.
	if( isDefined( self._atbr_ammo_count ))
	{
		self createHudATBRAmmoCounter( self._atbr_ammo_count );
	}
}

unlink_camera_and_controls( )
{
	self CameraUnlink();
	self ControlsUnLink();
	
	// Targets.
	if( isdefined( level._atbr_callback_remove_targets ))
	{
		self [[ level._atbr_callback_remove_targets ]]();
	}
	
	if( isDefined( self._atbr_ammo_count ))
	{
		self destroyHudATBRAmmoCounter();
	}
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************
atbr_common_fire_shots( missile )
{
	missile endon( "death" );
	self endon( "death" );
	self NotifyOnPlayerCommand( "fire_shot", "+attack" );
	for( ;; )
	{
		self waittill( "fire_shot" );
		
		//if a ammo count is defined, update hud, and cut off when all ammo is used.
		if( isDefined( self._atbr_ammo_count ))
		{
			if( self._atbr_ammo_count <= 0 )
			{
				//keep the camera attached till the missile has span its entire life
				//wait( 0.05 );
				//continue;
				
				//exit missile cam back to player
				wait( 0.2 );
				break;
			}
			
			self._atbr_ammo_count = self._atbr_ammo_count - 1;
			self updateHudATBRAmmoCounter( self._atbr_ammo_count );
		}

		Earthquake( 0.2, 1, missile.origin, 5000 );
		start = missile.origin;
		forward = AnglesToForward( missile.angles );
		forward = forward * ( 1, -1, -1 );
		end = start + ( forward * 2000.0 );
 		MagicBullet( level._atbr_weapons["bullet"], start, end, self );
		wait( 0.1 );
	}
}


createHudATBRAmmoCounter( count )
{	
	self.atbrAmmoCounter = newClientHudElem( self );
	self.atbrAmmoCounter.x = ATBR_HUD_TIMER_POS_X;
	self.atbrAmmoCounter.y = ATBR_HUD_TIMER_POS_Y;
	self.atbrAmmoCounter.alignX = "center";
	self.atbrAmmoCounter.alignY = "bottom";
	self.atbrAmmoCounter.horzAlign = "center_adjustable";
	self.atbrAmmoCounter.vertAlign = "bottom_adjustable";
	self.atbrAmmoCounter.fontScale = 2.5;
	self.atbrAmmoCounter setValue( count );
	self.atbrAmmoCounter.alpha = 1.0;
}

updateHudATBRAmmoCounter( value )
{
	if( isDefined( self.atbrAmmoCounter ))
	{
		self.atbrAmmoCounter setValue( value );
	}
}

destroyHudATBRAmmoCounter()
{
	if( isDefined( self.atbrAmmoCounter ))
	{
		self.atbrAmmoCounter Destroy();
	}
}

//returns true if sWeapon is an atbr weapon
is_atbr_weapons( sWeapon )
{	
	if( isDefined( level._atbr_weapons ))
	{
		foreach( weapon in level._atbr_weapons )
		{
			if( weapon == sWeapon )
			{
				return true;
			}
		}
	}
	return false; 	
}


