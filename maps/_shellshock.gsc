main( duration, nMaxDamageBase, nRanDamageBase, nMinDamageBase, nExposed, customShellShock )
{
	level thread internalMain( duration, nMaxDamageBase, nRanDamageBase, nMinDamageBase, nExposed, customShellShock );
}

internalMain( duration, nMaxDamageBase, nRanDamageBase, nMinDamageBase, nExposed, customShellShock )
{
	if ( !isdefined( duration ) )
	{
		duration = 12;
	}
	else
	if ( duration < 7 )
	{
		duration = 7;
	}

	if ( !isdefined( nMaxDamageBase ) )
	{
		nMaxDamageBase = 150;
	}

	if ( !isdefined( nRanDamageBase ) )
	{
		nRanDamageBase = 100;
	}

	if ( !isdefined( nMinDamageBase ) )
	{
		nMinDamageBase = 100;
	}

	if ( !isdefined( customShellShock ) )
	{
		strShocktype = "default";
	}
	else
	{
		strShocktype = customShellShock;
	}


	origin = ( level._player getorigin() + ( 0, 8, 2 ) );
	range = 320;
	maxdamage = nMaxDamageBase + randomint( nRanDamageBase );
	mindamage = nMinDamageBase;

	level._player playsound( "weapons_rocket_explosion" );
	wait 0.25;

	radiusDamage( origin, range, maxdamage, mindamage );
	earthquake( 0.75, 2, origin, 2250 );

	if ( isalive( level._player ) )
	{
		level._player allowStand( false );
		level._player allowCrouch( false );
		level._player allowProne( true );

		wait 0.15;
		level._player viewkick( 127, level._player.origin ); // Amount should be in the range 0 - 127, and is normalized "damage".  No damage is done.
		level._player shellshock( strShocktype, duration );

		if ( !isdefined( nExposed ) )
		{
			level._player thread playerHitable( duration );
		}

		wait 1.5;

		level._player allowStand( true );
		level._player allowCrouch( true );
	}
}

playerHitable( duration )
{
	assert( isplayer( self ) );

	self.shellshocked = true;
	self.ignoreme = true;
	self notify( "player is shell shocked" );
	self endon( "player is shell shocked" );
	wait( duration - 1 );
	self.shellshocked = false;
	self.ignoreme = false;
}