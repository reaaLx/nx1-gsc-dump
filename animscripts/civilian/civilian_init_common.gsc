#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include animscripts\shared;


#using_animtree( "generic_human" );

civilian_init()
{
	self.allowdeath = 1;
	self.disablearrivals = true;
	self.disableexits = true;
	self.neverEnableCQB = true;
	self.alwaysRunForward = true;
	self OrientMode( "face default" );
	self.combatmode = "no_cover";
	self.pushplayer = false;
	self pushplayer( false );
	self.a.reactToBulletChance = 1;

	
	
	// set the civilians animname to use defaults, or specific group if specified in radiant
	animName = undefined;
	if ( isdefined( self.civilian_walk_animation ) )
	{
		self.animname = self.civilian_walk_animation;
		self attachProps( self.civilian_walk_animation );
		self.alertLevel = "noncombat";
		startNonCombat();
	}
	else
	{
		self.animname = "default_civilian";
		self.alertLevel = "alert";
		startCombat();
	}

	self thread checkCombatState();
		
	// Make sure all required anims exist for this civilian, or set some defaults if they weren't specified
	assert( isdefined( level._scr_anim[ self.animname ][ "run_noncombat" ] ) );
	
	self.dropWeapon = false;
	self DropAIWeapon();
	self.saved = false;
}

attachProps( anime )
{
	if ( isdefined( self.hasAttachedProps ) )
		return;
		
	initCivilianProps();
	
	prop_model = anim.civilianProps[ anime ];

	if ( isdefined( prop_model ) )
	{
		self attach( prop_model, "tag_inhand", true );
		self.hasAttachedProps = true;
	}
}

detachProps( anime )
{
	if ( isdefined( self.hasAttachedProps ) )
	{
		self.hasAttachedProps = undefined;
		self detach( anim.civilianProps[ anime ], "tag_inhand" );
	}
}

initCivilianProps()
{
	if ( isdefined( anim.civilianProps ) )
		return;
		
	anim.civilianProps = [];
	anim.civilianProps[ "civilian_briefcase_walk" ]		 = "com_metal_briefcase";
	anim.civilianProps[ "civilian_crazy_walk" ]			 = "electronics_pda";
	anim.civilianProps[ "civilian_cellphone_walk" ]		 = "com_cellphone_on";
	anim.civilianProps[ "sit_lunch_A" ]					 = "com_cellphone_on";
	anim.civilianProps[ "civilian_soda_walk" ]			 = "ma_cup_single_closed";
	anim.civilianProps[ "civilian_paper_walk" ]			 = "paper_memo";
	anim.civilianProps[ "civilian_coffee_walk" ]		 = "cs_coffeemug02";
	anim.civilianProps[ "civilian_pda_walk" ]			 = "electronics_pda";
	anim.civilianProps[ "reading1" ]					 = "open_book";
	anim.civilianProps[ "reading2" ]					 = "open_book";
	anim.civilianProps[ "texting_stand" ]				 = "electronics_pda";
	anim.civilianProps[ "texting_sit" ]					 = "electronics_pda";
	anim.civilianProps[ "smoking1" ]					 = "prop_cigarette";
	anim.civilianProps[ "smoking2" ]					 = "prop_cigarette";
}




startNonCombat()
{
	self.turnRate = 0.2;
	
	// dodge animations
	if ( isdefined( self.civilian_walk_animation ) )
	{
		dodgeLeft = level._scr_anim[ "default_civilian" ][ "dodge_left" ];
		dodgeRight = level._scr_anim[ "default_civilian" ][ "dodge_right" ];

		if ( isdefined( level._scr_anim[ self.animname ][ "dodge_left" ] ) )
			dodgeLeft = level._scr_anim[ self.animname ][ "dodge_left" ];

		if ( isdefined( level._scr_anim[ self.animname ][ "dodge_right" ] ) )
			dodgeRight = level._scr_anim[ self.animname ][ "dodge_right" ];

		self animscripts\move::setDodgeAnims( dodgeLeft, dodgeRight );	
	}
	
	// move turn animations
	if ( isdefined( level._scr_anim[ self.animname ][ "turn_left_90" ] ) )
	{
		assert( isdefined( level._scr_anim[ self.animname ][ "turn_right_90" ] ) );
		self.pathTurnAnimOverrideFunc = animscripts\civilian\civilian_move::civilian_nonCombatMoveTurn;
		self.pathTurnAnimBlendTime = 0.1;
		self enable_turnAnims();
	}
	else
	{
		self disable_turnAnims();
	}
	
	self.run_overrideanim = level._scr_anim[ self.animname ][ "run_noncombat" ];
	self.walk_overrideanim = self.run_overrideanim;
	
	self.run_overrideBulletReact = undefined;
	
	if ( self.animname == "default_civilian" )
	{
		self.run_override_weights = level._scr_anim[ self.animname ][ "run_weights_noncombat" ];
		self.walk_override_weights = self.run_override_weights;
	}
}

startCombat()
{
	self notify( "combat" );
	
	self animscripts\move::clearDodgeAnims();

	self.pathTurnAnimBlendTime = undefined;
	self enable_turnAnims();
	
	self.turnRate = 0.3;
	
	standing_run = randomint( 3 ) < 1;
	if ( isdefined( self.force_civilian_stand_run ) )
	{
		standing_run = true;
	}
	else
	if ( isdefined( self.force_civilian_hunched_run ) )
	{
		standing_run = false;
	}
	
	if ( standing_run )
	{
		self.pathTurnAnimOverrideFunc = animscripts\civilian\civilian_move::civilian_combatMoveTurn;

		self.run_overrideanim = level._scr_anim[ "default_civilian" ][ "run_combat" ];
		self.run_override_weights = level._scr_anim[ "default_civilian" ][ "run_weights" ];
		
		//now check if this animset defines it's own anims
		if ( IsDefined( level._scr_anim[ self.animname ][ "run_combat" ] ) )
		{
			self.run_overrideanim = level._scr_anim[ self.animname ][ "run_combat" ];
			self.run_override_weights = level._scr_anim[ self.animname ][ "run_weights" ];
		}		
	}
	else
	{
		self.pathTurnAnimOverrideFunc = animscripts\civilian\civilian_move::civilian_combatHunchedMoveTurn;

		self.run_overrideanim = level._scr_anim[ "default_civilian" ][ "run_hunched_combat" ];
		self.run_override_weights = level._scr_anim[ "default_civilian" ][ "run_hunched_weights" ];
		
		//now check if this animset defines it's own anims
		if ( IsDefined( level._scr_anim[ self.animname ][ "run_hunched_combat" ] ) )
		{
			self.run_overrideanim = level._scr_anim[ self.animname ][ "run_hunched_combat" ];
			self.run_override_weights = level._scr_anim[ self.animname ][ "run_hunched_weights" ];
		}
	}

	self.run_overrideBulletReact = level._scr_anim[ "default_civilian" ][ "react_stumble" ];
	
	//now check if this animset defines it's own anims
	if ( IsDefined( level._scr_anim[ self.animname ][ "react_stumble" ] ) )
	{
		self.run_overrideBulletReact = level._scr_anim[ self.animname ][ "react_stumble" ];
	}

	self.walk_overrideanim = self.run_overrideanim;
	self.walk_override_weights = self.run_override_weights;
	
	detachProps( self.civilian_walk_animation );
}


checkCombatState()
{
	self endon( "death" );
	
	wasInCombat = ( self.alertLevelInt > 1 );

	while ( 1 )
	{
		isInCombat = ( self.alertLevelInt > 1 );
		
		if ( wasInCombat && !isInCombat )
			startNonCombat();
		else if ( !wasInCombat && isInCombat )
			startCombat();
			
		wasInCombat = isInCombat;
		
		wait 0.05;	// TEMP make this an alert level change wait when code is in.
	}	
}