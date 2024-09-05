#include maps\_utility;
#include animscripts\Combat_utility;
#include animscripts\utility;
#using_animtree( "generic_human" );

// (Note that animations called left are used with right corner nodes, and vice versa.)

main()
{
	self.animArrayFuncs = [];
	self.animArrayFuncs[ "hiding" ][ "stand" ] = ::set_animarray_standing_right;
	self.animArrayFuncs[ "hiding" ][ "crouch" ] = ::set_animarray_crouching_right;

	if ( IsDefined( self.customAnimFunc ) && IsDefined( self.customAnimFunc[ "cover_right" ] ) )
	{
		if ( IsDefined( self.customAnimFunc[ "cover_right" ][ "stand" ] ) )
		{
			self.animArrayFuncs[ "hiding" ][ "stand" ] = self.customAnimFunc[ "cover_right" ][ "stand" ];
		}
		if ( IsDefined( self.customAnimFunc[ "cover_right" ][ "crouch" ] ) )
		{
			self.animArrayFuncs[ "hiding" ][ "crouch" ] = self.customAnimFunc[ "cover_right" ][ "crouch" ];
		}
	}

	self endon( "killanimscript" );
    animscripts\utility::initialize( "cover_right" );

	animscripts\corner::corner_think( "right", -90 );
}

end_script()
{
	animscripts\corner::end_script_corner();
	animscripts\cover_behavior::end_script( "right" );
}


set_animarray_standing_right() /* void */
{
	assert( IsDefined(anim.coverRightStand));
	self.hideYawOffset = -90;
	self.a.array = anim.coverRightStand;
}

set_animarray_crouching_right()
{
	assert( IsDefined(anim.coverRightCrouch));
	self.hideYawOffset = -90;
	self.a.array = anim.coverRightCrouch;
}


