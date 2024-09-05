#include maps\_utility;
#include animscripts\Combat_utility;
#include animscripts\utility;
#using_animtree( "generic_human" );

// (Note that animations called right are used with left corner nodes, and vice versa.)

main()
{
	self.animArrayFuncs = [];
	self.animArrayFuncs[ "hiding" ][ "stand" ] = ::set_animarray_standing_left;
	self.animArrayFuncs[ "hiding" ][ "crouch" ] = ::set_animarray_crouching_left;

	if ( IsDefined( self.customAnimFunc ) && IsDefined( self.customAnimFunc[ "cover_left" ] ) )
	{
		if ( IsDefined( self.customAnimFunc[ "cover_left" ][ "stand" ] ) )
		{
			self.animArrayFuncs[ "hiding" ][ "stand" ] = self.customAnimFunc[ "cover_left" ][ "stand" ];
		}

		if ( IsDefined( self.customAnimFunc[ "cover_left" ][ "crouch" ] ) )
		{
			self.animArrayFuncs[ "hiding" ][ "crouch" ] = self.customAnimFunc[ "cover_left" ][ "crouch" ];
		}
	}	

	self endon( "killanimscript" );
    animscripts\utility::initialize( "cover_left" );

	animscripts\corner::corner_think( "left", 90 );
}

end_script()
{
	animscripts\corner::end_script_corner();
	animscripts\cover_behavior::end_script( "left" );
}

set_animarray_standing_left() /* void */ 
{	
	assert( IsDefined(anim.coverLeftStand) );
	self.hideYawOffset = 90;
	self.a.array = anim.coverLeftStand;
}


set_animarray_crouching_left()
{
	assert( IsDefined(anim.coverLeftCrouch) );
	self.hideYawOffset = 90;
	self.a.array = anim.coverLeftCrouch;
}

