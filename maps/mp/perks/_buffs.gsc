#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\perks\_perkfunctions;

BUFFTABLE_BUFF_REF_COL = 0;
BUFFTABLE_PERK_REF_COL = 5;
BUFFTABLE_MAT_REF_COL = 2;

init()
{
	//if ( level._teamBased )
	if ( false ) // tagTMR<NOTE>: Network perks disabled for the time being
	{
		level._buffToPerkMap	= [];
		level._netPerkMaterials	= [];
		
		i = 0;
		while ( 1 )
		{
			buff = tableLookupByRow( "mp/buffTable.csv", i, 0 );
			if ( buff == "" )
			{
				break;
			}
			else
			{
				level._buffToPerkMap[ buff ]	= tablelookup( "mp/buffTable.csv", BUFFTABLE_BUFF_REF_COL, buff, BUFFTABLE_PERK_REF_COL );
				level._netPerkMaterials[ buff ] = tablelookup( "mp/buffTable.csv", BUFFTABLE_BUFF_REF_COL, buff, BUFFTABLE_MAT_REF_COL );
				precacheShader( level._netPerkMaterials[ buff ] );

				i++;
			}
		}

		level thread onPlayerConnect();
		level thread networkSoldierPerkMon();
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		player thread onPlayerSpawned();		
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
onPlayerSpawned()
{
	self endon( "disconnect" );

	self._netBuff = undefined;
	self._networkedPerks = [];
	
	for( ;; )
	{
		self waittill( "spawned_player" );
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
networkSoldierPerkMon()
{
	self endon ( "game_ended" );

	while ( 1 )
	{
		networked_perks = [];

		for ( i = 0; i < level._players.size; i++ )
		{
			networked_perks[ i ] = [];
		}

		for( i = 0; i < ( level._players.size - 1 ); i++ )
		{
			player_i = level._players[i];

			if ( isAlive( player_i ))
			{
				for ( j = (i + 1); j < level._players.size; j++ )
				{
					player_j = level._players[j];

					if ( isAlive( player_j ))
					{
						if ( player_i.team == player_j.team )
						{
							dist = distance( player_i.origin, player_j.origin );
							radius = getDvarFloat( "perk_netSoldierEffectiveRadius" );

							if ( dist < radius )
							{
								networked_perks = buff_link_players( networked_perks, i, j );
							}
						}
					}
				}
			}
		}

		for ( i=0; i < level._players.size; i++ )
		{
			level._players[i] updateNetworkPerks( networked_perks[ i ] );
		}

		wait 1;
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
updateNetworkPerks( updated_network_perks )
{
	self endon( "death" );
	self endon( "disconnect" );	

	foreach( perkName,perkCount in self._networkedPerks )
	{
		if ( !isDefined( updated_network_perks[ perkName ] ))
		{
			// This player previously had a perk that it no longer does, turn it off
			self _unsetPerk( perkName );
		}
	}

	foreach( perkName,perkCount in updated_network_perks )
	{
		if ( !isDefined( self._networkedPerks[ perkName ] ))
		{
			// This is a new perk for this player's perk array, turn it on
			self maps\mp\perks\_perks::givePerk( perkName );
		}
	}

	self._networkedPerks = updated_network_perks;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
buff_link_players( network, player_index, other_player_index )
{
	network = network_buff( network, player_index, other_player_index );
	network = network_buff( network, other_player_index, player_index );

	return network;
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
network_buff( network, buffee_index, buffer_index )
{
	buffee	= level._players[ buffee_index ];
	buffer	= level._players[ buffer_index ];

	if ( isDefined( buffer._netBuff ) && buffer._netBuff != "specialty_null" )
	{
		network_perk = level._buffToPerkMap[ buffer._netBuff ];

		if ( isDefined( network[ buffee_index ][ network_perk ] ))
		{
			network[ buffee_index ][ network_perk ]++;
		}
		else
		{
			network[ buffee_index ][ network_perk ] = 1;
		}

		// Buffer must buff ones self
		if ( isDefined( network[ buffer_index ][ network_perk ] ))
		{
			network[ buffer_index ][ network_perk ]++;
		}
		else
		{
			network[ buffer_index ][ network_perk ] = 1;
		}
	}

	return network;
}