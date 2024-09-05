//self = actor
main()
{
	level._subclass_spawn_functions[ "moon" ] = ::subclass_moon_actor;
	setdvar( "scr_expDeathMayMoveCheck", "off" );

	SetSavedDvar( "ai_maxturnlookaheaddist", 120 );
	SetSavedDvar( "ai_maxforwardlookaheaddist", 50 );
}

subclass_moon_actor()
{
	self.no_pistol_switch = true;
	self.a.disableLongDeath = true;
	//self.dontMelee = true;
	self.turnrate = 0.1;
	self.noRunNGun = true;
	self.noReactToBullets = true; //don't allow bullet reactions for the MS. We don't have anims yet.

	/#
	if( IsDefined( anim.animSetLoaded ) )
	{
		AssertEX( anim.animSetLoaded == "lunar", "Tried to load a moon actor in a non-lunar map. If this is a lunar level verify your level is in audiotable.csv" );
	}
	#/
}

