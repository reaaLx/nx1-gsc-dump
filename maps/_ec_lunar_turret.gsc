#include maps\_utility;
#include common_scripts\utility;

//call after _load::main()
main()
{
	turret_vehicle_anims();

	//not sure how I feel about basing this off of the model name. It's more automatic 
	//than leaving a special targetname or script_noteworthy which might be needed for 
	//something else, but is easier to break;
	turrets = getEntArray( "misc_turret", "code_classname" );
	array_thread( turrets, ::animate_player_hands );

}

#using_animtree( "vehicles" );
turret_vehicle_anims()
{
	//animation of the hands on the turret.
	level._scr_animtree[ "lunar_hands" ] 					= #animtree;
	level._scr_model[ "lunar_hands" ] 						= "viewhands_us_lunar_scripted";
	level._scr_anim[ "lunar_hands" ][ "idle_L" ]			= %player_chinese_lgv_turret_idle_L;
	level._scr_anim[ "lunar_hands" ][ "idle_R" ]			= %player_chinese_lgv_turret_idle_R;
	level._scr_anim[ "lunar_hands" ][ "idle2fire_L" ]		= %player_chinese_lgv_turret_idle2fire_L;
	level._scr_anim[ "lunar_hands" ][ "idle2fire_R" ]		= %player_chinese_lgv_turret_idle2fire_R;
	level._scr_anim[ "lunar_hands" ][ "fire2idle_L" ]		= %player_chinese_lgv_turret_fire2idle_L;
	level._scr_anim[ "lunar_hands" ][ "fire2idle_R" ]		= %player_chinese_lgv_turret_fire2idle_R;
	level._scr_anim[ "lunar_hands" ][ "patch_R" ]			= %player_chinese_lgv_turret_suitshield_inject_R;
	level._scr_anim[ "lunar_hands" ][ "patch_L" ]			= %player_chinese_lgv_turret_suitshield_inject_L;
	level._scr_anim[ "lunar_hands" ][ "react_R" ]			= %player_chinese_lgv_turret_reaction_R;
	level._scr_anim[ "lunar_hands" ][ "react_L" ]			= %player_chinese_lgv_turret_reaction_L;
	level._scr_anim[ "lunar_hands" ][ "react_turret" ]		= %nx_chinese_lgv_turret_reaction;	
}


//called on a turret
animate_player_hands()
{
	self endon( "death" );

	//oh my this is uggly, but the hand animations were written to work specifically with this model 
	//so lets only do this script if that's the case.
	if( self.model != "nx_vehicle_chinese_lgv_main_turret" )
	{
		return;
	}

	//got to wait until it's used.
	mounted = false;
	while ( true )
	{
		if ( IsTurretPlayerControlled( self ) )
		{
			if( !mounted )
			{
				self.animname = "lunar_hands";
				self useAnimTree( level._scr_animtree[ self.animname ] );
				self Attach( level._scr_model[ self.animname ] , "tag_player" );
				self SetAnim( level._scr_anim[ self.animname ][ "idle_L" ]	, 1, 0, 1 );
				self SetAnim( level._scr_anim[ self.animname ][ "idle_R" ]	, 1, 0, 1 );

				self thread turret_player_viewhands_hand( "LEFT" );
				self thread turret_player_viewhands_hand( "RIGHT" );
				self thread turret_player_viewhands_patch();
			}

			mounted = true;
		}
		else
		{
			if( mounted )
			{
				self Detach(  level._scr_model[ self.animname ], "tag_player" );
				self notify( "dismount" );
			}

			mounted = false;
		}
		wait 0.05;
	}
}

turret_player_viewhands_hand( hand )
{
	self endon( "death" );
	self endon( "patching" );
	self endon( "dismount" );
	self endon( "reacting" );
	
	checkFunc = undefined;
	if ( hand == "LEFT" )
	{
		checkFunc = ::turret_ads_button_pressed;
	}
	else if ( hand == "RIGHT" )
	{
		checkFunc = ::turret_fire_button_pressed;
	}
	assert( isdefined( checkFunc ) );
	
	while( true )
	{
		if( level._player [[checkFunc]]() )
		{
			thread turret_player_viewhands_presed( hand );
			while( level._player [[checkFunc]]() )
			{
				wait 0.05;
			}
		}
		else
		{
			thread turret_player_viewhands_idle( hand );
			while( !level._player [[checkFunc]]() )
			{
				wait 0.05;
			}
		}
	}
}

turret_ads_button_pressed()
{
	if ( level._player AdsButtonPressed() )
	{
		return true;
	}
	if ( level._player AttackButtonPressed() )
	{
		return true;
	}
	return false;
}

turret_fire_button_pressed()
{
	return level._player AttackButtonPressed();
}

turret_player_viewhands_idle( hand )
{
	self endon( "death" );
	self endon( "dismount" );
	
	animHand = undefined;
	if ( hand == "LEFT" )
	{
		animHand = "L";
	}
	else if ( hand == "RIGHT" )
	{
		animHand = "R";
	}
	assert( isdefined( animHand ) );
	
	self.animname = "lunar_hands";
	self useAnimTree( level._scr_animtree[ self.animname ] );
	
	self clearAnim( self getanim( "idle2fire_" + animHand ), 0.2 );
	self setFlaggedAnimRestart( "anim", self getanim( "fire2idle_" + animHand ) );
	self waittillmatch( "anim", "end" );
	self clearAnim( self getanim( "fire2idle_" + animHand ), 0.2 );
	self setAnim( self getanim( "idle_" + animHand ) );
}

turret_player_viewhands_presed( hand )
{
	self endon( "death" );
	self endon( "dismount" );
	
	animHand = undefined;
	if ( hand == "LEFT" )
	{
		animHand = "L";
	}
	else if ( hand == "RIGHT" )
	{
		animHand = "R";
	}
	assert( isdefined( animHand ) );
	
	self.animname = "lunar_hands";
	self useAnimTree( level._scr_animtree[ self.animname ] );
	
	self clearAnim( self getanim( "idle_" + animHand ), 0.1 );  //made it twice faster
	self setAnim( self getanim( "idle2fire_" + animHand ) ); 
}

//fairly analogous to _suitsheild::suit_shield_use_watch()
turret_player_viewhands_patch()
{
	self endon("death");
	self endon( "dismount" );
	self endon( "reacting" );
	
	//level._player EnableActionSlot( 4, true );
	
	patching = false;
	
	while ( true )
	{
		wait 0.05;

		if( ! level._player IsSuitShieldEnabled() )
		{
			continue;
		}
		
		//if the button is pressed and not already patching...
		if( level._player SuitShieldButtonPressed() && !patching )
		{
			//see if we meet the conditions for actually patching.
			if ( ((level._player GetSuitShieldHealth() >= Int(GetDvar("player_suitshield_max_health"))) 
				|| (0 == level._player GetAmmoCount( "nx_suitshield" )))
				&& !IsGodMode( level._player ) )
			{
				continue;
			}
						
			//lock out additional patching and stop idle watching scripts.
			patching = true;
			self notify( "patching" );
			level._player FreezeControls( true );		
			
			//blend in the patch animation.
			self SetFlaggedAnimKnobRestart( "patch", self getanim( "patch_R" ), 1, 0.2, 1 );
			self SetFlaggedAnimKnobRestart( "patch", self getanim( "patch_L" ), 1, 0.2, 1 );
			
			//wait for partway through the animation to reward the patch success.
			wait Float(GetDvar("suit_shield_patch_wait")); 
			
			//award health and subtract the ammo. 
			level._player SetSuitShieldHealth( Int(GetDvar("player_suitshield_max_health")) );
			level._player SetWeaponAmmoClip( "nx_suitshield", level._player GetWeaponAmmoClip( "nx_suitshield" ) - 1 );
			level._player notify("suit_repaired");	
			
			//wait for the animation to finish.
			self waittillmatch( "patch", "end" );
			self clearAnim( self getanim( "patch_R" ), 0.2 );
			self clearAnim( self getanim( "patch_L" ), 0.2 );

			//restart the idle scripts.
			self thread turret_player_viewhands_hand( "LEFT" );
			self thread turret_player_viewhands_hand( "RIGHT" );
			
			//release control and let patching be able to be used some more.
			level._player FreezeControls( false );		
			patching = false;					
		}
	}
}

//play a react anim that interupts the current hand anims.
turret_player_viewhands_react( look_at_ent_name )
{
	self endon("death");
	self endon( "dismount" );

	self notify( "reacting" );
	level._player FreezeControls( true );		
	look_at_ent = GetEnt( look_at_ent_name, "targetname" );
	level._player TurnToFaceTarget( look_at_ent.origin, 3.0, 1.0 );
	
	//blend in the react animation.
	self SetAnimKnobRestart( self getanim( "react_turret" ), 1, 0.2, 1  );
	self SetFlaggedAnimKnobRestart( "react", self getanim( "react_R" ), 1, 0.2, 1 );
	self SetFlaggedAnimKnobRestart( "react", self getanim( "react_L" ), 1, 0.2, 1 );
			
	//wait for the animation to finish.
	self waittillmatch( "react", "end" );
	self clearAnim( self getanim( "react_turret" ), 0.2 );
	self clearAnim( self getanim( "react_R" ), 0.2 );
	self clearAnim( self getanim( "react_L" ), 0.2 );

	//restart the idle scripts.
	self thread turret_player_viewhands_hand( "LEFT" );
	self thread turret_player_viewhands_hand( "RIGHT" );
	self thread turret_player_viewhands_patch();
			
	//release control
	level._player FreezeControls( false );	
}