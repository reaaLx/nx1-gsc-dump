#include common_scripts\utility;
#include maps\mp\_utility;


attachmentGroup( attachmentName )
{
	return tableLookup( "mp/attachmentTable.csv", 4, attachmentName, 2 );
}

getAttachmentList()
{
	attachmentList = [];
	
	index = 0;
	attachmentName = tableLookup( "mp/attachmentTable.csv", 9, index, 4 );
	
	while ( attachmentName != "" )
	{
		attachmentList[attachmentList.size] = attachmentName;
		
		index++;
		attachmentName = tableLookup( "mp/attachmentTable.csv", 9, index, 4 );
	}
	
	return alphabetize( attachmentList );
}

init()
{
	level._scavenger_altmode = true;
	level._scavenger_secondary = true;
	
	// 0 is not valid
	level._maxPerPlayerExplosives = max( getIntProperty( "scr_maxPerPlayerExplosives", 2 ), 1 );
	level._riotShieldXPBullets = getIntProperty( "scr_riotShieldXPBullets", 15 );

	switch ( getIntProperty( "perk_scavengerMode", 0 ) )
	{
		case 1: // disable altmode
			level._scavenger_altmode = false;
			break;

		case 2: // disable secondary
			level._scavenger_secondary = false;
			break;
			
		case 3: // disable altmode and secondary
			level._scavenger_altmode = false;
			level._scavenger_secondary = false;
			break;		
	}
	
	attachmentList = getAttachmentList();	
	
	// assigns weapons with stat numbers from 0-149
	// attachments are now shown here, they are per weapon settings instead
	
	max_weapon_num = 149;

	weapon_stats_init();

	level._weaponList = [];
	for( weaponId = 0; weaponId <= max_weapon_num; weaponId++ )
	{
		weapon_name = tablelookup( "mp/statstable.csv", 0, weaponId, 4 );
		if( weapon_name == "" )
			continue;
	
		if ( !isSubStr( tableLookup( "mp/statsTable.csv", 0, weaponId, 2 ), "weapon_" ) )
			continue;
			
		level._weaponList[level._weaponList.size] = weapon_name + "_mp";
		/#
		if ( getDvar( "scr_dump_weapon_assets" ) != "" )
		{
			printLn( "" );
			printLn( "// " + weapon_name + " real assets" );
			printLn( "weapon,mp/" + weapon_name + "_mp" );
		}
		#/

		// the alphabetize function is slow so we try not to do it for every weapon/attachment combo; a code solution would be better.
		attachmentNames = [];
		for ( innerLoopCount = 0; innerLoopCount < 10; innerLoopCount++ )
		{
			// generating attachment combinations
			attachmentName = tablelookup( "mp/statStable.csv", 0, weaponId, innerLoopCount + 11 );
			
			if( attachmentName == "" )
				break;
			
			attachmentNames[attachmentName] = true;
		}

		// generate an alphabetized attachment list
		attachments = [];
		foreach ( attachmentName in attachmentList )
		{
			if ( !isDefined( attachmentNames[attachmentName] ) )
				continue;
				
			level._weaponList[level._weaponList.size] = weapon_name + "_" + attachmentName + "_mp";
			attachments[attachments.size] = attachmentName;
			/#
			if ( getDvar( "scr_dump_weapon_assets" ) != "" )
				println( "weapon,mp/" + weapon_name + "_" + attachmentName + "_mp" );
			#/
		}

		attachmentCombos = [];
		for ( i = 0; i < (attachments.size - 1); i++ )
		{
			colIndex = tableLookupRowNum( "mp/attachmentCombos.csv", 0, attachments[i] );
			for ( j = i + 1; j < attachments.size; j++ )
			{
				if ( tableLookup( "mp/attachmentCombos.csv", 0, attachments[j], colIndex ) == "no" )
					continue;
					
				attachmentCombos[attachmentCombos.size] = attachments[i] + "_" + attachments[j];
			}
		}

		/#
		if ( getDvar( "scr_dump_weapon_assets" ) != "" && attachmentCombos.size )
			println( "// " + weapon_name + " virtual assets" );
		#/
		
		foreach ( combo in attachmentCombos )
		{
			/#
			if ( getDvar( "scr_dump_weapon_assets" ) != "" )
				println( "weapon,mp/" + weapon_name + "_" + combo + "_mp" );
			#/

			level._weaponList[level._weaponList.size] = weapon_name + "_" + combo + "_mp";
		}
	}

	foreach ( weaponName in level._weaponList )
	{
		precacheItem( weaponName );
		
		/#
		if ( getDvar( "scr_dump_weapon_assets" ) != "" )
		{
			altWeapon = weaponAltWeaponName( weaponName );
			if ( altWeapon != "none" )
				println( "weapon,mp/" + altWeapon );				
		}
		#/
	}

	precacheItem( "flare_mp" );
	precacheItem( "scavenger_bag_mp" );
	precacheItem( "frag_grenade_short_mp" );	
	precacheItem( "destructible_car" );
	precacheItem( "portable_radar_mp" );

	//Sean
	precacheItem( "uav_strike_projectile_mp" );
	
	precacheShellShock( "default" );
	precacheShellShock( "concussion_grenade_mp" );
	precacheShellShock( "gas_grenade_mp" );
	precacheShellShock( "melee_trophy_suit" );
	thread maps\mp\_flashgrenades::main();
	thread maps\mp\_entityheadicons::init();
	thread maps\mp\_gasgrenades::init();

	claymoreDetectionConeAngle = 70;
	level._claymoreDetectionDot = cos( claymoreDetectionConeAngle );
	level._claymoreDetectionMinDist = 20;
	level._claymoreDetectionGracePeriod = .75;
	level._claymoreDetonateRadius = 192;
	
	level._sonicWardenRadius = 300;
	
	// this should move to _stinger.gsc
	level._stingerFXid = loadfx ("explosions/aerial_explosion_large");

	// generating weapon type arrays which classifies the weapon as primary (back stow), pistol, or inventory (side pack stow)
	// using mp/statstable.csv's weapon grouping data ( numbering 0 - 149 )
	level._primary_weapon_array = [];
	level._side_arm_array = [];
	level._grenade_array = [];
	level._inventory_array = [];
	level._stow_priority_model_array = [];
	level._stow_offset_array = [];
	
	max_weapon_num = 149;
	for( i = 0; i < max_weapon_num; i++ )
	{
		weapon = tableLookup( "mp/statsTable.csv", 0, i, 4 );
		stow_model = tableLookup( "mp/statsTable.csv", 0, i, 9 );
		
		if ( stow_model == "" )
			continue;

		precacheModel( stow_model );		

		if ( isSubStr( stow_model, "weapon_stow_" ) )
			level._stow_offset_array[ weapon ] = stow_model;
		else
			level._stow_priority_model_array[ weapon + "_mp" ] = stow_model;
	}
	
	precacheModel( "weapon_sonic_warden_bombsquad" );
	precacheModel( "weapon_claymore_bombsquad" );
	precacheModel( "weapon_c4_bombsquad" );
	precacheModel( "projectile_m67fraggrenade_bombsquad" );
	precacheModel( "projectile_semtex_grenade_bombsquad" );
	precacheModel( "weapon_light_stick_tactical_bombsquad" );
	//precacheModel( "weapon_portable_radar" );
	
	level._killStreakSpecialCaseWeapons = [];
	level._killStreakSpecialCaseWeapons["cobra_player_minigun_mp"] = true;
	level._killStreakSpecialCaseWeapons["artillery_mp"] = true;
	level._killStreakSpecialCaseWeapons["stealth_bomb_mp"] = true;
	level._killStreakSpecialCaseWeapons["pavelow_minigun_mp"] = true;
	level._killStreakSpecialCaseWeapons["abrams_minigun_mp"] = true;
	level._killStreakSpecialCaseWeapons["ugv_main_turret_mp"] = true;
	level._killStreakSpecialCaseWeapons["sentry_minigun_mp"] = true;
	level._killStreakSpecialCaseWeapons["harrier_20mm_mp"] = true;
	level._killStreakSpecialCaseWeapons["ac130_105mm_mp"] = true;
	level._killStreakSpecialCaseWeapons["ac130_40mm_mp"] = true;
	level._killStreakSpecialCaseWeapons["ac130_25mm_mp"] = true;
	level._killStreakSpecialCaseWeapons["remotemissile_projectile_mp"] = true;
	level._killStreakSpecialCaseWeapons["cobra_20mm_mp"] = true;
	level._killStreakSpecialCaseWeapons["sentry_minigun_mp"] = true;
	level._killStreakSpecialCaseWeapons["atbr_detonate_mp"] = true;
	level._killStreakSpecialCaseWeapons["heli_remote_mp"] = true;
	level._killStreakSpecialCaseWeapons["remote_mortar_missile_mp"] = true;
	level._killStreakSpecialCaseWeapons["aresminigun_mp"] = true;
	level._killStreakSpecialCaseWeapons["atbr_bullet_mp"] = true;
	level._killStreakSpecialCaseWeapons["nx_miniuav_rifle_player_mp"] = true;
	level._killStreakSpecialCaseWeapons["uav_strike_projectile_mp"] = true;
	level._killStreakSpecialCaseWeapons["manned_minigun_turret_mp"] = true;
	level._killStreakSpecialCaseWeapons["miniuav_viewmodel_mp"] = true;
	level._killStreakSpecialCaseWeapons["lsdnightravenmissile_mp"] = true;
	level._killStreakSpecialCaseWeapons["lsdguidedmissile_mp"] = true;
	level._killStreakSpecialCaseWeapons["lock_seek_die_mp"] = true;
	
	level thread onPlayerConnect();
	
	level._c4explodethisframe = false;

	array_thread( getEntArray( "misc_turret", "classname" ), ::turret_monitorUse );
	
	level._empGrenadeTime = getDvarFloat( "scr_empGrenadeTime" );
	level._empRadius = getDvarInt( "scr_empGrenadeRadius" );
	
//	thread dumpIt();
}


dumpIt()
{
	
	wait ( 5.0 );
	/#
	max_weapon_num = 149;

	for( weaponId = 0; weaponId <= max_weapon_num; weaponId++ )
	{
		weapon_name = tablelookup( "mp/statstable.csv", 0, weaponId, 4 );
		if( weapon_name == "" )
			continue;
	
		if ( !isSubStr( tableLookup( "mp/statsTable.csv", 0, weaponId, 2 ), "weapon_" ) )
			continue;
			
		if ( getDvar( "scr_dump_weapon_challenges" ) != "" )
		{
			/*
			sharpshooter
			marksman
			veteran
			expert
			master
			*/

			weaponLStringName = tableLookup( "mp/statsTable.csv", 0, weaponId, 3 );
			weaponRealName = tableLookupIString( "mp/statsTable.csv", 0, weaponId, 3 );

			prefix = "WEAPON_";
			weaponCapsName = getSubStr( weaponLStringName, prefix.size, weaponLStringName.size );

			weaponGroup = tableLookup( "mp/statsTable.csv", 0, weaponId, 2 );
			
			weaponGroupSuffix = getSubStr( weaponGroup, prefix.size, weaponGroup.size );

			/*
			iprintln( "REFERENCE           TITLE_" + weaponCapsName + "_SHARPSHOOTER" );
			iprintln( "LANG_ENGLISH        ", weaponRealName, ": Sharpshooter" );
			iprintln( "" );
			iprintln( "REFERENCE           TITLE_" + weaponCapsName + "_MARKSMAN" );
			iprintln( "LANG_ENGLISH        ", weaponRealName, ": Marksman" );
			iprintln( "" );
			iprintln( "REFERENCE           TITLE_" + weaponCapsName + "_VETERAN" );
			iprintln( "LANG_ENGLISH        ", weaponRealName, ": Veteran" );
			iprintln( "" );
			iprintln( "REFERENCE           TITLE_" + weaponCapsName + "_EXPERT" );
			iprintln( "LANG_ENGLISH        ", weaponRealName, ": Expert" );
			iprintln( "" );
			iprintln( "REFERENCE           TITLE_" + weaponCapsName + "_Master" );
			iprintln( "LANG_ENGLISH        ", weaponRealName, ": Master" );
			*/
			
			iprintln( "cardtitle_" + weapon_name + "_sharpshooter,PLAYERCARDS_TITLE_" + weaponCapsName + "_SHARPSHOOTER,cardtitle_" + weaponGroupSuffix + "_sharpshooter,1,1,1" );
			iprintln( "cardtitle_" + weapon_name + "_marksman,PLAYERCARDS_TITLE_" + weaponCapsName + "_MARKSMAN,cardtitle_" + weaponGroupSuffix + "_marksman,1,1,1" );
			iprintln( "cardtitle_" + weapon_name + "_veteran,PLAYERCARDS_TITLE_" + weaponCapsName + "_VETERAN,cardtitle_" + weaponGroupSuffix + "_veteran,1,1,1" );
			iprintln( "cardtitle_" + weapon_name + "_expert,PLAYERCARDS_TITLE_" + weaponCapsName + "_EXPERT,cardtitle_" + weaponGroupSuffix + "_expert,1,1,1" );
			iprintln( "cardtitle_" + weapon_name + "_master,PLAYERCARDS_TITLE_" + weaponCapsName + "_MASTER,cardtitle_" + weaponGroupSuffix + "_master,1,1,1" );
			
			wait ( 0.05 );
		}
	}
	#/
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
///ScriptDocBegin
"Name: weapon_stats_init()"
"CallOn: Nothing"
"Summary: To init our weapon usage stats system."
"Author: Eric Milota"
"Returns: None"
"Module: C:\trees\nx1\game\share\raw\maps\mp\gametypes\_weapons.gsc"
"Example: weapon_stats_init();"
"SPMP: both"
///ScriptDocEnd
*/
weapon_stats_init()
{
	level._weapon_stats_used_array = [];

	//println( "weapon_stats_init() Called." );
	//bbPrint( "breakpoint: " );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
///ScriptDocBegin
"Name: weapon_stats_find_item()"
"CallOn: Nothing"
"Summary: To find an item in our array."
"Author: Eric Milota"
"Returns: index 0...x of our entry, or -1 if not found"
"Module: C:\trees\nx1\game\share\raw\maps\mp\gametypes\_weapons.gsc"
"Example: index = weapon_stats_find_item(self GetXuid(), self GetCurrentWeapon());"
"SPMP: both"
///ScriptDocEnd
*/
weapon_stats_find_item(xuid_in, weaponname_in)
{
	//assert( IsDefined( level._weapon_stats_used_array ) );
	if( IsDefined( level._weapon_stats_used_array ) )
	{
		for( index = 0; index < level._weapon_stats_used_array.size; index++ )
		{
			item = level._weapon_stats_used_array[ index ];
			
			if( item.xuid == xuid_in )
			{
				if( item.weaponname == weaponname_in )
				{
					return index;	// found item!
				}
			}
		}
	}
	
	return -1;	// can't find item
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
///ScriptDocBegin
"Name: weapon_stats_add_item()"
"CallOn: Nothing"
"Summary: To add an item in our array."
"Author: Eric Milota"
"Returns: index 0...x of our entry, or -1 if error"
"Module: C:\trees\nx1\game\share\raw\maps\mp\gametypes\_weapons.gsc"
"Example: index = weapon_stats_add_item(self GetXuid(), self GetCurrentWeapon());"
"SPMP: both"
///ScriptDocEnd
*/
weapon_stats_add_item(xuid_in, weaponname_in)
{
	//assert( IsDefined( level._weapon_stats_used_array ) );
	if( !IsDefined( level._weapon_stats_used_array ) )
	{
		return -1;	// error
	}
	index = level._weapon_stats_used_array.size;

	item = spawnstruct();
	item.xuid = xuid_in;
	item.weaponname = weaponname_in;
	item.fired = 0;
	item.hits = 0;
	item.headshots = 0;
	item.damage = 0;
	item.gothitby = 0;
	item.gotheadshotby = 0;
	item.gotdamageby = 0;
	level._weapon_stats_used_array[ index ] = item;
		
	return index;	// all good
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
///ScriptDocBegin
"Name: weapon_stats_get_item()"
"CallOn: Nothing"
"Summary: To find an item in our array, or create a new one if it doesn't exist."
"Author: Eric Milota"
"Returns: index 0...x of our entry, or -1 if not found and couldn't create new one."
"Module: C:\trees\nx1\game\share\raw\maps\mp\gametypes\_weapons.gsc"
"Example: index = weapon_stats_get_item(self GetXuid(), self GetCurrentWeapon());"
"SPMP: both"
///ScriptDocEnd
*/
weapon_stats_get_item(xuid_in, weaponname_in)
{
	index = weapon_stats_find_item( xuid_in, weaponname_in );
	if( index < 0 )
	{
		index = weapon_stats_add_item( xuid_in, weaponname_in );
		if( index < 0 )
		{
			return -1;	// error
		}
	}
	return index;	// all good
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
///ScriptDocBegin
"Name: weapon_stats_record_fire()"
"CallOn: Nothing"
"Summary: To record a weapon fire."
"Author: Eric Milota"
"Returns: None"
"Module: C:\trees\nx1\game\share\raw\maps\mp\gametypes\_weapons.gsc"
"Example: weapon_stats_record_fire( self, self GetCurrentWeapon() );"
"SPMP: both"
///ScriptDocEnd
*/
weapon_stats_record_fire( player, weaponname )
{
	assert( IsDefined( level._weapon_stats_used_array ) );
	if( IsDefined( level._weapon_stats_used_array ) )
	{
		//-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x
		//iPrintLn( "FIRE: player=" + player GetXuid() + ", weaponname='" + weaponname + "'" );
		//-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

		//println( "weapon_stats_record_fire() Called with player=" + player GetXuid() + ", weaponname = '" + weaponname + "'." );
		//bbPrint( "breakpoint: " );

		index = weapon_stats_get_item( player GetXuid(), weaponname );
		if( index >= 0 )
		{	
			level._weapon_stats_used_array[ index ].fired++;
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
///ScriptDocBegin
"Name: weapon_stats_record_hit()"
"CallOn: Nothing"
"Summary: To record a weapon hit."
"Author: Eric Milota"
"Returns: None"
"Module: C:\trees\nx1\game\share\raw\maps\mp\gametypes\_weapons.gsc"
"Example: weapon_stats_record_hit( self, self GetCurrentWeapon(), damage, meansofdeath, victim );"
"SPMP: both"
///ScriptDocEnd
*/
weapon_stats_record_hit( player, weaponname, damage, meansofdeath, victim )
{
	assert( IsDefined( level._weapon_stats_used_array ) );
	if( IsDefined( level._weapon_stats_used_array ) )
	{
		//-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x
		//iPrintLn( "HIT: player=" + player GetXuid() + ", weaponname='" + weaponname + "'" );
		//-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

		//println( "weapon_stats_record_hit() Called with player=" + player GetXuid() + ", weaponname = '" + weaponname + "'." );
		//bbPrint( "breakpoint: " );
		
		player_xuid = player GetXuid();
		index = weapon_stats_get_item( player_xuid, weaponname );
		if( index >= 0 )
		{
			level._weapon_stats_used_array[ index ].hits++;
			if( meansofdeath == "MOD_HEAD_SHOT" )
			{
				level._weapon_stats_used_array[ index ].headshots++;
			}
			level._weapon_stats_used_array[ index ].damage += damage;

			// now, let's let the victim accumulate info about being hit by this weapon		
			if( IsDefined( victim ) )
			{
				victim_xuid = victim GetXuid();

				victim_weapon_stat_index = weapon_stats_get_item( victim_xuid, weaponname );
				if( victim_weapon_stat_index >= 0 )
				{	
					level._weapon_stats_used_array[ victim_weapon_stat_index ].gothitby++;
					if( meansofdeath == "MOD_HEAD_SHOT" )
					{
						level._weapon_stats_used_array[ victim_weapon_stat_index ].gotheadshotby++;
					}
					level._weapon_stats_used_array[ victim_weapon_stat_index ].gotdamageby += damage;
				}
			}
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
///ScriptDocBegin
"Name: weapon_stats_dump_to_black_box()"
"CallOn: Nothing"
"Summary: To report the stats to the black box."
"Author: Eric Milota"
"Returns: None"
"Module: C:\trees\nx1\game\share\raw\maps\mp\gametypes\_weapons.gsc"
"Example: weapon_stats_dump_to_black_box();"
"SPMP: both"
///ScriptDocEnd
*/
weapon_stats_dump_to_black_box()
{
	assert( IsDefined( level._weapon_stats_used_array ) );
	if( IsDefined( level._weapon_stats_used_array ) )
	{
		//statversion = GetPersistentDataDefVersion();
		//statformatchecksum = GetPersistentDataDefFormatChecksum();
		
		//-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x
		//println( "weapon_stats_dump_to_black_box() Called." );
		//println( "mpweaponusage: There are " + level._weapon_stats_used_array.size + " items in our weapon usage stats array." );
		for( index = 0; index < level._weapon_stats_used_array.size; index++ )
		{
			item = level._weapon_stats_used_array[ index ];

			//println( "mpweaponusage: " + index + " - PLAYER='" + item.xuid + "', WEAPONNAME='" + item.weaponname + "', FIRED=" + item.fired + ", HITS=" + item.hits + ", HEADSHOTS=" + item.headshots + ", DAMAGE=" + item.damage + ", GOTHITBY=" + item.gothitby + ", GOTHEADSHOTBY=" + item.gotheadshotby + ", GOTDAMAGEBY=" + item.gotdamageby + " " );		

			bbPrint( "mpweaponusage: xuid %llu weaponname %s fired %u hits %u headshots %u damage %u gothitby %u gotheadshotby %u gotdamageby %u ", 
				item.xuid, item.weaponname, item.fired, item.hits, item.headshots, item.damage, item.gothitby, item.gotheadshotby, item.gotdamageby );
		}
		//-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x
	}
}


bombSquadWaiter()
{
	self endon ( "disconnect" );
	
	for ( ;; )
	{
		self waittill ( "grenade_fire", weaponEnt, weaponName );
		
		if ( weaponName == "c4_mp" )
			weaponEnt thread createBombSquadModel( "weapon_c4_bombsquad", "tag_origin", self );
		else if ( weaponName == "lidarmine_mp" )
			weaponEnt thread createBombSquadModel( "weapon_claymore_bombsquad", "tag_origin", self );
		else if ( weaponName == "claymore_mp" )
			weaponEnt thread createBombSquadModel( "weapon_claymore_bombsquad", "tag_origin", self );
		else if ( weaponName == "sonic_warden_mp" )
			weaponEnt thread createBombSquadModel( "weapon_sonic_warden_bombsquad", "tag_origin", self );
		else if ( weaponName == "frag_grenade_mp" )
			weaponEnt thread createBombSquadModel( "projectile_m67fraggrenade_bombsquad", "tag_weapon", self );
		else if ( weaponName == "frag_grenade_short_mp" )
			weaponEnt thread createBombSquadModel( "projectile_m67fraggrenade_bombsquad", "tag_weapon", self );
		else if ( weaponName == "semtex_mp" )
			weaponEnt thread createBombSquadModel( "projectile_semtex_grenade_bombsquad", "tag_weapon", self );
	}
}


createBombSquadModel( modelName, tagName, owner )
{
	bombSquadModel = spawn( "script_model", (0,0,0) );
	bombSquadModel hide();
	wait ( 0.05 );
	
	if (!isDefined( self ) ) //grenade model may not be around if picked up
		return;
		
	//ensure owner is defined within the grende object
	if( !isDefined( self.owner ))
	{
		self.owner = owner;
	}
		
	bombSquadModel thread bombSquadVisibilityUpdater( self );
	bombSquadModel setModel( modelName );
	bombSquadModel linkTo( self, tagName, (0,0,0), (0,0,0) );
	bombSquadModel SetContents( 0 );
	
	self waittill ( "death" );
	
	bombSquadModel delete();
}


bombSquadVisibilityUpdater( item )
{
	self endon ( "death" );
	
	for ( ;; )
	{
		self hide();
		
		owner = item.owner;
		teamName = owner.team;

		foreach ( player in level._players )
		{
			if ( level._teamBased )
			{
				if ( player.team != teamName && player _hasPerk( "specialty_detectexplosive" ))
				{
					self showToPlayer( player );
				}
			}
			else
			{
				show_to_player = true;
				if ( isDefined( owner ) && player == owner )
				{
					show_to_player = false;
				}
				
				if ( !player _hasPerk( "specialty_detectexplosive" ))
				{
					show_to_player = false;
				}
				
				if( show_to_player == true )
				{	
					self showToPlayer( player );
				}
			}		
		}
		
		level waittill_any( "joined_team", "player_spawned", "changed_kit", "c4_hacked", "claymore_hacked" );
	}
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);

		player.hits = 0;
		player.hasDoneCombat = false;

		player KC_RegWeaponForFXRemoval( "remotemissile_projectile_mp" );

		player thread onPlayerSpawned();
		player thread bombSquadWaiter();
	}
}


onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");
		
		self.currentWeaponAtSpawn = self getCurrentWeapon(); // optimization so these threads we start don't have to call it.
		
		self.empEndTime = 0;
		self.concussionEndTime = 0;
		self.hasDoneCombat = false;
		self thread watchWeaponUsage();
		self thread watchGrenadeUsage();
		self thread watchWeaponChange();
		self thread watchStingerUsage();
		self thread watchJavelinUsage();
		self thread watchMissileUsage();
		self thread watchSentryUsage();
		self thread watchWeaponReload();
		self thread maps\mp\gametypes\_class::trackRiotShield();
		self thread stanceRecoilAdjuster();
		self thread maps\mp\_gasgrenades::watchEmpClouded();

		self.lastHitTime = [];
		
		self.droppedDeathWeapon = undefined;
		self.tookWeaponFrom = [];
		
		self thread updateStowedWeapon();
		
		self thread updateSavedLastWeapon();
		
		if ( self hasWeapon( "semtex_mp" ) )
			self thread monitorSemtex();
		
		self.currentWeaponAtSpawn = undefined;
	}
}

WatchStingerUsage()
{
	self maps\mp\_stinger::StingerUsageLoop();
}


WatchJavelinUsage()
{
	self maps\mp\_javelin::JavelinUsageLoop();
}

watchWeaponChange()
{
	self endon("death");
	self endon("disconnect");
	
	self thread watchStartWeaponChange();
	self.lastDroppableWeapon = self.currentWeaponAtSpawn;
	self.hitsThisMag = [];

	weapon = self getCurrentWeapon();
	
	if ( isCACPrimaryWeapon( weapon ) && !isDefined( self.hitsThisMag[ weapon ] ) )
		self.hitsThisMag[ weapon ] = weaponClipSize( weapon );

	self.bothBarrels = undefined;

	if ( isSubStr( weapon, "ranger" ) )
		self thread watchRangerUsage( weapon );

	while(1)
	{
		self waittill( "weapon_change", newWeapon );
		
		tokedNewWeapon = StrTok( newWeapon, "_" );

		self.bothBarrels = undefined;

		if ( isSubStr( newWeapon, "ranger" ) )
			self thread watchRangerUsage( newWeapon );

		if ( tokedNewWeapon[0] == "gl" || ( tokedNewWeapon.size > 2 && tokedNewWeapon[2] == "attach" ) )
			newWeapon = self getCurrentPrimaryWeapon();

		if ( newWeapon != "none" )
		{
			if ( isCACPrimaryWeapon( newWeapon ) && !isDefined( self.hitsThisMag[ newWeapon ] ) )
				self.hitsThisMag[ newWeapon ] = weaponClipSize( newWeapon );
		}
		self.changingWeapon = undefined;
		if ( mayDropWeapon( newWeapon ) )
			self.lastDroppableWeapon = newWeapon;
	}
}


watchStartWeaponChange()
{
	self endon("death");
	self endon("disconnect");
	self.changingWeapon = undefined;

	while(1)
	{
		self waittill( "weapon_switch_started", newWeapon );
		self.changingWeapon = newWeapon;
	}
}

watchWeaponReload()
{
	self endon("death");
	self endon("disconnect");

	for ( ;; )
	{
		self waittill( "reload" );

		weaponName = self getCurrentWeapon();

		self.bothBarrels = undefined;
		
		if ( !isSubStr( weaponName, "ranger" ) )
			continue;

		self thread watchRangerUsage( weaponName );
	}
}


watchRangerUsage( rangerName )
{
	rightAmmo = self getWeaponAmmoClip( rangerName, "right" );
	leftAmmo = self getWeaponAmmoClip( rangerName, "left" );

	self endon ( "reload" );
	self endon ( "weapon_change" );

	for ( ;; )
	{
		self waittill ( "weapon_fired", weaponName );
		
		if ( weaponName != rangerName )
			continue;

		self.bothBarrels = undefined;

		if ( isSubStr( rangerName, "akimbo" ) )
		{
			newLeftAmmo = self getWeaponAmmoClip( rangerName, "left" );
			newRightAmmo = self getWeaponAmmoClip( rangerName, "right" );

			if ( leftAmmo != newLeftAmmo && rightAmmo != newRightAmmo )
				self.bothBarrels = true;
			
			if ( !newLeftAmmo || !newRightAmmo )
				return;
				
				
			leftAmmo = newLeftAmmo;
			rightAmmo = newRightAmmo;
		}
		else if ( rightAmmo == 2 && !self getWeaponAmmoClip( rangerName, "right" ) )
		{
			self.bothBarrels = true;
			return;
		}
	}
}


isHackWeapon( weapon )
{
	if ( weapon == "radar_mp" || weapon == "airstrike_mp" || weapon == "helicopter_mp" )
		return true;
	if ( weapon == "briefcase_bomb_mp" )
		return true;
	return false;
}


mayDropWeapon( weapon )
{
	if ( weapon == "none" )
		return false;
		
	if ( isSubStr( weapon, "ac130" ) )
		return false;
		
	//atbr_detonator is a primary weapon but we do not want to allow the player to drop it
	if ( isSubStr( weapon, "atbr" ) )
		return false;

	if ( isSubStr( weapon, "uavstrikebinoculars" ) )
		return false;

	invType = WeaponInventoryType( weapon );
	if ( invType != "primary" )
		return false;
	
	return true;
}

dropWeaponForDeath( attacker )
{
	if ( isDefined( level._blockWeaponDrops ) )
		return;

	weapon = self.lastDroppableWeapon;
	
	if ( isdefined( self.droppedDeathWeapon ) )
		return;

	if ( level._inGracePeriod )
		return;
	
	if ( !isdefined( weapon ) )
	{
		/#
		if ( getdvar("scr_dropdebug") == "1" )
			println( "didn't drop weapon: not defined" );
		#/
		return;
	}
	
	if ( weapon == "none" )
	{
		/#
		if ( getdvar("scr_dropdebug") == "1" )
			println( "didn't drop weapon: weapon == none" );
		#/
		return;
	}
	
	if ( !self hasWeapon( weapon ) )
	{
		/#
		if ( getdvar("scr_dropdebug") == "1" )
			println( "didn't drop weapon: don't have it anymore (" + weapon + ")" );
		#/
		return;
	}
	
	if ( weapon != "riotshield_mp" )
	{
		if ( !(self AnyAmmoForWeaponModes( weapon )) )
		{
			/#
			if ( getdvar("scr_dropdebug") == "1" )
			  println( "didn't drop weapon: no ammo for weapon modes" );
			#/
			return;
		}

		clipAmmoR = self GetWeaponAmmoClip( weapon, "right" );
		clipAmmoL = self GetWeaponAmmoClip( weapon, "left" );
		if ( !clipAmmoR && !clipAmmoL )
		{
			/#
			if ( getdvar("scr_dropdebug") == "1" )
			  println( "didn't drop weapon: no ammo in clip" );
			#/
			return;
		}
  
		stockAmmo = self GetWeaponAmmoStock( weapon );
		stockMax = WeaponMaxAmmo( weapon );
		if ( stockAmmo > stockMax )
			stockAmmo = stockMax;

		item = self dropItem( weapon );
		item ItemWeaponSetAmmo( clipAmmoR, stockAmmo, clipAmmoL );
	}
	else
	{
		item = self dropItem( weapon );	
		if ( !isDefined( item ) )
			return;
		item ItemWeaponSetAmmo( 1, 1, 0 );
	}

	/#
	if ( getdvar("scr_dropdebug") == "1" )
		println( "dropped weapon: " + weapon );
	#/

	self.droppedDeathWeapon = true;

	item.owner = self;
	item.ownersattacker = attacker;

	item thread watchPickup();

	item thread deletePickupAfterAWhile();

	detach_model = getWeaponModel( weapon );

	if ( !isDefined( detach_model ) )
		return;

	if( isDefined( self.tag_stowed_back ) && detach_model == self.tag_stowed_back )
		self detach_back_weapon();

	if ( !isDefined( self.tag_stowed_hip ) )
		return;

	if( detach_model == self.tag_stowed_hip )
		self detach_hip_weapon();
}


detachIfAttached( model, baseTag )
{
	attachSize = self getAttachSize();
	
	for ( i = 0; i < attachSize; i++ )
	{
		attach = self getAttachModelName( i );
		
		if ( attach != model )
			continue;
		
		tag = self getAttachTagName( i );			
		self detach( model, tag );
		
		if ( tag != baseTag )
		{
			attachSize = self getAttachSize();
			
			for ( i = 0; i < attachSize; i++ )
			{
				tag = self getAttachTagName( i );
				
				if ( tag != baseTag )
					continue;
					
				model = self getAttachModelName( i );
				self detach( model, tag );
				
				break;
			}
		}		
		return true;
	}
	return false;
}


deletePickupAfterAWhile()
{
	self endon("death");
	
	wait 60;

	if ( !isDefined( self ) )
		return;

	self delete();
}

getItemWeaponName()
{
	classname = self.classname;
	assert( getsubstr( classname, 0, 7 ) == "weapon_" );
	weapname = getsubstr( classname, 7 );
	return weapname;
}

watchPickup()
{
	self endon("death");
	
	weapname = self getItemWeaponName();
	
	while(1)
	{
		self waittill( "trigger", player, droppedItem );
		
		if ( isdefined( droppedItem ) )
			break;
		// otherwise, player merely acquired ammo and didn't pick this up
	}
	
	/#
	if ( getdvar("scr_dropdebug") == "1" )
		println( "picked up weapon: " + weapname + ", " + isdefined( self.ownersattacker ) );
	#/

	assert( isdefined( player.tookWeaponFrom ) );
	
	// make sure the owner information on the dropped item is preserved
	droppedWeaponName = droppedItem getItemWeaponName();
	if ( isdefined( player.tookWeaponFrom[ droppedWeaponName ] ) )
	{
		droppedItem.owner = player.tookWeaponFrom[ droppedWeaponName ];
		droppedItem.ownersattacker = player;
		player.tookWeaponFrom[ droppedWeaponName ] = undefined;
	}
	droppedItem thread watchPickup();
	
	// take owner information from self and put it onto player
	if ( isdefined( self.ownersattacker ) && self.ownersattacker == player )
	{
		player.tookWeaponFrom[ weapname ] = self.owner;
	}
	else
	{
		player.tookWeaponFrom[ weapname ] = undefined;
	}
}

itemRemoveAmmoFromAltModes()
{
	origweapname = self getItemWeaponName();
	
	curweapname = weaponAltWeaponName( origweapname );
	
	altindex = 1;
	while ( curweapname != "none" && curweapname != origweapname )
	{
		self itemWeaponSetAmmo( 0, 0, 0, altindex );
		curweapname = weaponAltWeaponName( curweapname );
		altindex++;
	}
}


handleScavengerBagPickup( scrPlayer )
{
	self endon( "death" );
	level endon ( "game_ended" );

	assert( isDefined( scrPlayer ) );

	// Wait for the pickup to happen
	self waittill( "scavenger", destPlayer );
	assert( isDefined ( destPlayer ) );

	destPlayer notify( "scavenger_pickup" );
	destPlayer playLocalSound( "scavenger_pack_pickup" );
	
	offhandWeapons = destPlayer getWeaponsListOffhands();
	
	if ( destPlayer _hasPerk( "specialty_tacticalinsertion" ) && destPlayer getAmmoCount( "flare_mp" ) < 1 )
		destPlayer _setPerk( "specialty_tacticalinsertion");
		
	if ( destPlayer _hasPerk( "specialty_portable_radar" ) && destPlayer getAmmoCount( "portable_radar_mp" ) < 1 )
		destPlayer _setPerk( "specialty_portable_radar");	
		
	foreach ( offhand in offhandWeapons )
	{		
		currentClipAmmo = destPlayer GetWeaponAmmoClip( offhand );
		destPlayer SetWeaponAmmoClip( offhand, currentClipAmmo + 1);
	}

	primaryWeapons = destPlayer getWeaponsListPrimaries();	
	foreach ( primary in primaryWeapons )
	{
		if ( !isCACPrimaryWeapon( primary ) && !level._scavenger_secondary )
			continue;
			
		currentStockAmmo = destPlayer GetWeaponAmmoStock( primary );
		addStockAmmo = weaponClipSize( primary );
		
		destPlayer setWeaponAmmoStock( primary, currentStockAmmo + addStockAmmo );

		altWeapon = weaponAltWeaponName( primary );

		if ( !isDefined( altWeapon ) || (altWeapon == "none") || !level._scavenger_altmode )
			continue;

		currentStockAmmo = destPlayer GetWeaponAmmoStock( altWeapon );
		addStockAmmo = weaponClipSize( altWeapon );

		destPlayer setWeaponAmmoStock( altWeapon, currentStockAmmo + addStockAmmo );
	}

	destPlayer maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "scavenger" );
}


dropScavengerForDeath( attacker )
{
	if ( level._inGracePeriod )
		return;
	
 	if( !isDefined( attacker ) )
 		return;

 	if( attacker == self )
 		return;

	dropBag = self dropScavengerBag( "scavenger_bag_mp" );	
	dropBag thread handleScavengerBagPickup( self );

}

getWeaponBasedGrenadeCount(weapon)
{
	return 2;
}

getWeaponBasedSmokeGrenadeCount(weapon)
{
	return 1;
}

getFragGrenadeCount()
{
	grenadetype = "frag_grenade_mp";

	count = self getammocount(grenadetype);
	return count;
}

getSmokeGrenadeCount()
{
	grenadetype = "smoke_grenade_mp";

	count = self getammocount(grenadetype);
	return count;
}


watchWeaponUsage( weaponHand )
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon ( "game_ended" );
	
	for ( ;; )
	{	
		self waittill ( "weapon_fired", weaponName );

		self.hasDoneCombat = true;

		weapon_stats_record_fire( self, weaponName );		

		if ( !maps\mp\gametypes\_weapons::isPrimaryWeapon( weaponName ) && !maps\mp\gametypes\_weapons::isSideArm( weaponName ) )
			continue;
		
		if ( isDefined( self.hitsThisMag[ weaponName ] ) )
			self thread updateMagShots( weaponName );
		
		totalShots = self maps\mp\gametypes\_persistence::statGetBuffered( "totalShots" ) + 1;
		hits = self maps\mp\gametypes\_persistence::statGetBuffered( "hits" );
		self maps\mp\gametypes\_persistence::statSetBuffered( "totalShots", totalShots );
		self maps\mp\gametypes\_persistence::statSetBuffered( "accuracy", int(hits * 10000 / totalShots) );		
		self maps\mp\gametypes\_persistence::statSetBuffered( "misses", int(totalShots - hits) );
	}
}


updateMagShots( weaponName )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "updateMagShots_" + weaponName );
	
	self.hitsThisMag[ weaponName ]--;
	
	wait ( 0.05 );
	
	self.hitsThisMag[ weaponName ] = weaponClipSize( weaponName );
}


checkHitsThisMag( weaponName )
{
	self endon ( "death" );
	self endon ( "disconnect" );

	self notify ( "updateMagShots_" + weaponName );
	waittillframeend;
	
	if ( self.hitsThisMag[ weaponName ] == 0 )
	{
		weaponClass = getWeaponClass( weaponName );
		
		maps\mp\gametypes\_missions::genericChallenge( weaponClass );

		self.hitsThisMag[ weaponName ] = weaponClipSize( weaponName );
	}	
}


checkHit( weaponName, victim, damage, meansofdeath )
{
	if ( !maps\mp\gametypes\_weapons::isPrimaryWeapon( weaponName ) && !maps\mp\gametypes\_weapons::isSideArm( weaponName ) )
		return;

	// sometimes the "weapon_fired" notify happens after we hit the guy...
	waittillframeend;

	if ( isDefined( self.hitsThisMag[ weaponName ] ) )
		self thread checkHitsThisMag( weaponName );

	if ( !isDefined( self.lastHitTime[ weaponName ] ) )
		self.lastHitTime[ weaponName ] = 0;
	
	now =  getTime();

	// already hit with this weapon on this frame
	if ( self.lastHitTime[ weaponName ] == now )
		return;

	self.lastHitTime[ weaponName ] = now;

	weapon_stats_record_hit( self, weaponName, damage, meansofdeath, victim );		

	totalShots = self maps\mp\gametypes\_persistence::statGetBuffered( "totalShots" );		
	hits = self maps\mp\gametypes\_persistence::statGetBuffered( "hits" ) + 1;

	if ( hits <= totalShots )
	{
		self maps\mp\gametypes\_persistence::statSetBuffered( "hits", hits );
		self maps\mp\gametypes\_persistence::statSetBuffered( "misses", int(totalShots - hits) );
		self maps\mp\gametypes\_persistence::statSetBuffered( "accuracy", int(hits * 10000 / totalShots) );
	}
}


attackerCanDamageItem( attacker, itemOwner )
{
	return friendlyFireCheck( itemOwner, attacker );
}

// returns true if damage should be done to the item given its owner and the attacker
friendlyFireCheck( owner, attacker, forcedFriendlyFireRule )
{
	if ( !isdefined( owner ) )// owner has disconnected? allow it
		return true;

	if ( !level._teamBased )// not a team based mode? allow it
		return true;

	attackerTeam = attacker.team;

	friendlyFireRule = level._friendlyfire;
	if ( isdefined( forcedFriendlyFireRule ) )
		friendlyFireRule = forcedFriendlyFireRule;

	if ( friendlyFireRule != 0 )// friendly fire is on? allow it
		return true;

	if ( attacker == owner )// owner may attack his own items
		return true;

	if ( !isdefined( attackerTeam ) )// attacker not on a team? allow it
		return true;

	if ( attackerTeam != owner.team )// attacker not on the same team as the owner? allow it
		return true;

	return false;// disallow it
}

//called on a player when they are spawned
watchGrenadeUsage()
{
	self endon( "death" );
	self endon( "disconnect" );

	self.throwingGrenade = undefined;
	self.gotPullbackNotify = false;

	if ( getIntProperty( "scr_deleteexplosivesonspawn", 1 ) == 1 )
	{
		// delete c4 from previous spawn
		if ( isdefined( self.c4array ) )
		{
			for ( i = 0; i < self.c4array.size; i++ )
			{
				if ( isdefined( self.c4array[ i ] ) )
				{
					self.c4array[ i ] delete();
				}	
			}
		}
		self.c4array = [];
		// delete claymores from previous spawn
		if ( isdefined( self.claymorearray ) )
		{
			for ( i = 0; i < self.claymorearray.size; i++ )
			{
				if ( isdefined( self.claymorearray[ i ] ) )
				{
					self.claymorearray[ i ] delete();
				}
			}
		}
		self.claymorearray = [];
		
		// delete claymores from previous spawn
		if ( isdefined( self.lidararray ) )
		{
			for ( i = 0; i < self.lidararray.size; i++ )
			{
				if ( isdefined( self.lidararray[ i ] ) )
				{
					self.lidararray[ i ] delete();
				}
			}
		}
		self.lidararray = [];
	}
	else
	{
		if ( !isdefined( self.c4array ) )
			self.c4array = [];
		if ( !isdefined( self.claymorearray ) )
			self.claymorearray = [];
		if ( !isdefined( self.lidararray ) )
			self.lidararray = [];
	}

	thread watchC4();
	thread watchC4Detonation();
	thread watchC4AltDetonation();
	thread watchClaymores();
	thread watchLidarMines();
	thread deleteC4AndClaymoresOnDisconnect();

	self thread watchForThrowbacks();

	for ( ;; )
	{
		self waittill( "grenade_pullback", weaponName );

		self.hasDoneCombat = true;

		if ( weaponName == "claymore_mp" )
			continue;
			
		if ( weaponName == "lidarmine_mp" )
			continue;

		self.throwingGrenade = weaponName;
		self.gotPullbackNotify = true;
		
		if ( weaponName == "c4_mp" )
		{
			self beginC4Tracking();
			self.throwingGrenade = undefined;
		}
		else if( weaponName == "gas_grenade_mp" || weaponName == "empcloud_grenade_mp" || weaponName == "hulc_gas_grenade_mp" )
		{
			self thread beginCloudGrenadeTracking();
		}
		else
		{
			self beginGrenadeTracking();
			self.throwingGrenade = undefined;
		}
	}
}

beginCloudGrenadeTracking()
{
	self endon( "disconnect" );
	self endon( "offhand_end" );
	self endon( "weapon_change" );
	self endon( "end_respawn" );

	//checking life id's to make sure this script never gets caught without getting the "grenade_fire" notification.
	initialid = self.lifeID;
	self waittill( "grenade_fire", grenade, weaponName );
	nextid = self.lifeID;

	deltaID = nextid - initialid;
	assert( deltaId < 2 );

	if( isDefined( grenade ))
	{
		self.changingWeapon = undefined;
	
		if( weaponName == "empcloud_grenade_mp" )
		{
			grenade.owner = self;
			grenade thread empExplodeWaiter( "emp" );
			grenade thread maps\mp\_gasgrenades::gasGrenadeExplodeWaiter("emp");
		}
	
		if( weaponName == "gas_grenade_mp" )
		{
			grenade.owner = self;
			grenade thread maps\mp\_gasgrenades::gasGrenadeExplodeWaiter("gas");
		}

		if( weaponName == "hulc_gas_grenade_mp" )
		{
			grenade.owner = self;
			grenade thread maps\mp\_gasgrenades::gasGrenadeExplodeWaiter("gas");
		}
	
		self.throwingGrenade = undefined;
	}
}

beginGrenadeTracking()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "offhand_end" );
	self endon( "weapon_change" );

	startTime = getTime();

	self waittill( "grenade_fire", grenade, weaponName );

	if ( ( getTime() - startTime > 1000 ) && weaponName == "frag_grenade_mp" )
		grenade.isCooked = true;

	self.changingWeapon = undefined;

	if ( weaponName == "frag_grenade_mp" || weaponName == "semtex_mp" )
	{
		grenade thread maps\mp\gametypes\_shellshock::grenade_earthQuake();
		grenade.originalOwner = self;
	}

	if ( weaponName == "flash_grenade_mp" )
	{
		grenade.owner = self;
		grenade thread empExplodeWaiter( "flash" );
	}
	
	
	if( weaponName == "concussion_grenade_mp" )
	{
		grenade.owner = self;
		grenade thread empExplodeWaiter( "stun" );
	}
	
	//emp grenade watcher
	if( weaponName == "emp_grenade_mp" )
	{
		grenade.owner = self;
		grenade thread empGrenadeExplodeWaiter();
	}

	if( weaponName == "emp_grenade_mp" )
	{
		grenade thread empExplodeWaiter( "emp" );
	}

	if( weaponName == "grapplinghook_mp" )
	{
		grenade.owner = self;
		grenade thread grapplinghookWaiter();
	}
	
	if( weaponName == "lidar_grenade_mp" )
	{
		grenade.owner = self;
		grenade thread lidarGrenadeExplodeWaiter();
	}

	if( weaponName == "hulc_lidar_mp" )
	{
		grenade.owner = self;
		grenade thread lidarGrenadeExplodeWaiter();
		grenade thread empGrenadeExplodeWaiter();
		grenade thread empExplodeWaiter( "emp" );
	}

	//Sean 
	if( weaponName == "pred_grenade_mp" )
	{
		grenade.owner = self;
		grenade thread PredatorGrenadeExplodeWaiter();
	}
}

AddMissileToSightTraces( team )
{
	self.team = team;
	level._missilesForSightTraces[ level._missilesForSightTraces.size ] = self;
	
	self waittill( "death" );
	
	newArray = [];
	foreach( missile in level._missilesForSightTraces )
	{
		if ( missile != self )
			newArray[ newArray.size ] = missile;
	}
	level._missilesForSightTraces = newArray;
}

watchMissileUsage()
{
	self endon( "death" );
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill( "missile_fire", missile, weaponName );
		
		if ( isSubStr( weaponName, "gl_" ) )
		{
			missile.primaryWeapon = self getCurrentPrimaryWeapon();
			missile thread maps\mp\gametypes\_shellshock::grenade_earthQuake();
		}

		switch ( weaponName )
		{
			case "at4_mp":
			case "stinger_mp":
				level notify ( "stinger_fired", self, missile, self.stingerTarget );
				self thread setAltSceneObj( missile, "tag_origin", 65 );
				break;
			case "javelin_mp":
				level notify ( "stinger_fired", self, missile, self.javelinTarget );
				self thread setAltSceneObj( missile, "tag_origin", 65 );
				break;			
			default:
				break;
		}

		switch ( weaponName )
		{
			case "at4_mp":
			case "javelin_mp":
			case "rpg_mp":
			case "ac130_105mm_mp":
			case "ac130_40mm_mp":
			case "remotemissile_projectile_mp":
				missile thread maps\mp\gametypes\_shellshock::grenade_earthQuake();
			default:
				break;
		}
	}
}


watchSentryUsage()
{
	self endon( "death" );
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill( "sentry_placement_finished", sentry );
		
		self thread setAltSceneObj( sentry, "tag_flash", 65 );
	}
}


empExplodeWaiter( empType )
{
	self thread maps\mp\gametypes\_shellshock::endOnDeath();
	self endon( "end_explode" );

	self waittill( "explode", position );

	ents = getEMPDamageEnts( position, 512, false );

	foreach ( ent in ents )
	{
		if ( isDefined( ent.owner ) && !friendlyFireCheck( self.owner, ent.owner ) )
			continue;

		ent notify( "emp_damage", self.owner, empType );
	}
}

empGrenadeExplodeWaiter()
{
	//self thread maps\mp\gametypes\_shellshock::endOnDeath();
	self endon( "end_explode" );
	doLOS = false;  //not set up yet.
	team = self.owner.team;
	
	self waittill( "explode", position );
	
	foreach( player in level._players )
	{	
		if( level._teamBased )
		{
			if( player.team == team && player != self.owner )
			{
				continue;
			}
		}

		if ( !isAlive( player ) || player.sessionstate != "playing" )
		{
			continue;
		}
		
		dist = distance( position, player.origin );
		if( dist < level._empRadius )
		{
			player thread maps\mp\killstreaks\_emp::EMPGrenade_JamPlayer( level._empGrenadeTime );
		}
	}
}

//*******************************************************************
//               Start of Grappling Hook Code                       *
//                                                                  *
//*******************************************************************
grapplinghookWaiter()
{
	wait ( 0.15 );  //tagJC<NOTE>: To allow the targeting/reticle script having a chance to set the necessary parameters.
	if ( isdefined (self.owner.TargetedGrappleEntity) && isdefined (self.owner.GrappleTargetDetected))
	{
		player = self.owner;	
		grappleLocation = player.TargetedGrappleEntity;

		if ( player.GrappleTargetDetected == 1 )
		{ 
			player thread move_player_grappling();
			self playsound ( "weap_grap_impact_good" );
		}
		else 
		{
			self playsound ( "weap_grap_impact_bad" );
		}
	}
}

move_player_grappling()
{
	GRAPPLING_SPEED = 650;	
	
	end_point = self.TargetedGrappleTarget - (0, 0, 100);
	AssertEx( IsDefined( end_point ), "grapple_end_point cannot be found" );

	self.moving_ent = spawn( "script_model", self.origin );
	self.moving_ent SetModel( "tag_origin" );
	self.moving_ent.origin = self.origin; 
	self.moving_ent.angles = self.angles;
	grapple_distance = distance ( end_point, self.moving_ent.origin );
	grapple_time = grapple_distance / GRAPPLING_SPEED;
	wait ( 0.15 );
	self thread PlayGrappleSound ( grapple_time );
	self PlayerLinkToDeltaGrapple( self.moving_ent, "tag_origin", 1);
	
	self.moving_ent MoveTo ( end_point, grapple_time, grapple_time * 0.7, grapple_time * 0.3);
	self.moving_ent waittill ( "movedone" );

	self Unlink();
	self.moving_ent delete();
}

PlayGrappleSound ( grapple_time )
{
	if ( grapple_time > 0.35)
	{
		move_time = grapple_time - 0.35;
		self playsound ( "weap_grap_move_start_npc" );
		wait ( move_time );
		self stopsounds ();
		//self stopsounds ( "weap_grap_move_start_plr" );
	}
	self playsound ( "weap_grap_move_end_npc" );
}
//*******************************************************************
//               End of Grappling Hook Code                         *
//                                                                  *
//*******************************************************************


//Sean's missile marker
PredatorGrenadeExplodeWaiter()
{
	//self endon( "death" );
	//self endon( "end_explode" );
	team = self.owner.team;
	
	//self.owner notify( "pred_grenade_thrown" );	

	//println( "Predator marker out" );

	self waittill( "explode", position );

	
	//println( "Predator marker ka blooey" );

	//sean
	magicBullet( "uav_strike_projectile_mp", position + (0,0,4000) , position, self.owner );		
}


LIDARGrenadeExplodeWaiter()
{
	self endon( "end_explode" );
	team = self.owner.team;
	
	self waittill( "explode", position );
	
	println( "Lidar grenade out" );
	
	lidarObj = Spawn( "script_origin", position );
	
	lidarObj.owner = self.owner;
	lidarObj.team = team;

	lidarObj thread lidarGrenadeMonitor();
}

lidarGrenadeMonitor()
{
	self endon( "death" );
	
	//design tweakable values
	pulseRadius = getDvarInt( "scr_LIDARPulseRadius" );
	lidarTickTime = getDvarInt( "scr_LIDARTickTime" );
	lidarNumTicks = getDvarFloat( "scr_LIDARNumTicks" );
		
	//apply lidar fx to players in the radius
	foreach( player in level._players )
	{	
		if( level._teamBased )
		{
			if( !isDefined( player.team ))
			{
				continue;
			}
			
			if( !isDefined( self.owner ))
			{
				continue;
			}
			
			if( player.team == self.team )
			{
				continue;
			}
		}
		else
		{
			//dont tag myself in ffa games
			if( player == self.owner )
			{
				continue;
			}
		}
		
		dist = distance( self.origin, player.origin );
		if( dist < pulseRadius )
		{
			visArg = self.team;
			if( !level._teambased )
			{
				//in non team based games just show the icons to me.
				visArg = self.owner;
			}
			
			player thread applyLidarHeadIcon( visArg, lidarTickTime, lidarNumTicks );
		}
	}
	
	self delete();
}

applyLidarHeadIcon( teamVisibility, lidarTickTime, lidarNumTicks )
{
	self endon( "death" );
	self endon( "disconnect" );
	
	//wait( 0.05 );
	
	lidarParams = SpawnStruct();
	lidarParams.showTo = teamVisibility;
	lidarParams.icon = "compassping_lidar";
	lidarParams.offset = ( 0, 0, 64 );
	lidarParams.width = 10;
	lidarParams.height = 10;
	lidarParams.archived = false;
	lidarParams.delay = lidarTickTime;
	lidarParams.constantSize = false;
	lidarParams.pinToScreenEdge = true;
	lidarParams.fadeOutPinnedIcon = false;
	lidarParams.is3D = false;
	self.lidarParams = lidarParams;
	
	lidarTickCount = 0;
	
	while( lidarTickCount < lidarNumTicks )
	{	
		theIcon = self maps\mp\_entityheadIcons::setHeadIcon( 
			lidarParams.showTo, 
			lidarParams.icon, 
			lidarParams.offset, 
			lidarParams.width, 
			lidarParams.height, 
			lidarParams.archived, 
			lidarParams.delay, 
			lidarParams.constantSize, 
			lidarParams.pinToScreenEdge, 
			lidarParams.fadeOutPinnedIcon,
			lidarParams.is3D );
			
		wait( lidarParams.delay );
		lidarTickCount += 1;
		
		//remove the icon
		if( isDefined( self.entityHeadIcons ))
		{
			foreach( key, headIcon in self.entityHeadIcons )
			{	
				if( !isDefined( headIcon ) )
					continue;
				
				if( headIcon == theIcon )
				{
					headIcon destroy();
				}
			}
		}
	}
}


beginC4Tracking()
{
	self endon( "death" );
	self endon( "disconnect" );

	self waittill_any( "grenade_fire", "weapon_change", "offhand_end" );
}


watchForThrowbacks()
{
	self endon( "death" );
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill( "grenade_fire", grenade, weapname );
		
		if ( self.gotPullbackNotify )
		{
			self.gotPullbackNotify = false;
			continue;
		}
		if ( !isSubStr( weapname, "frag_" ) && !isSubStr( weapname, "semtex_" ) )
			continue;

		// no grenade_pullback notify! we must have picked it up off the ground.
		grenade.threwBack = true;
		self thread incPlayerStat( "throwbacks", 1 );

		grenade thread maps\mp\gametypes\_shellshock::grenade_earthQuake();
		grenade.originalOwner = self;
	}
}


//called on a player
watchC4()
{
	self endon( "spawned_player" );
	self endon( "disconnect" );

	//maxc4 = 2;

	while ( 1 )
	{
		self waittill( "grenade_fire", c4, weapname );
		if ( weapname == "c4" || weapname == "c4_mp" )
		{
			if ( !self.c4array.size )
				self thread watchC4AltDetonate();

			if ( self.c4array.size )
			{
				self.c4array = array_removeUndefined( self.c4array );
				
				if( self.c4array.size >= level._maxPerPlayerExplosives )
				{
					self.c4array[0] detonate();
				}
			}

			self.c4array[ self.c4array.size ] = c4;
			c4.owner = self;
			c4.team = self.team;
			c4.activated = false;
			c4.weaponName = weapname;
			c4.hacked = false;

			c4 thread maps\mp\gametypes\_shellshock::c4_earthQuake();
			c4 thread c4Activate();
			c4 thread c4Damage();
			// tagJWP<NOTE> this is taken care of by the _gasgrenade.gsc file for the emp grenade
			// c4 thread c4EMPDamage();
			c4 thread c4EMPKillstreakWait();
			//c4 thread c4DetectionTrigger( self.pers[ "team" ] );
			
			//println( "spawning watch for pickup1" );
			c4 thread WatchForPickup( self );
		}
	}
}


/*c4EMPDamage()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "emp_damage", attacker, duration );

		playfxOnTag( getfx( "sentry_explode_mp" ), self, "tag_origin" );

		self.disabled = true;
		self notify( "disabled" );

		wait( duration );

		self.disabled = undefined;
		self notify( "enabled" );
	}
}*/


c4EMPKillstreakWait()
{
	self endon( "death" );

	for ( ;; )
	{
		level waittill( "emp_update" );

		if ( (level._teamBased && level._teamEMPed[self.team]) || (!level._teamBased && isDefined( level._empPlayer ) && level._empPlayer != self.owner ) )
		{
			self.disabled = true;
			self notify( "disabled" );
		}
		else
		{
			self.disabled = undefined;
			self notify( "enabled" );
		}
	}
}


claymoreWatchForEmpCloud()
{
	self endon( "death" );

	assert( isDefined( self.owner ));
	assert( isDefined( level._empCloudList ));
	
	/*
	if( !isDefined( level._empCloudList ))
	{
		return;
	}
	*/

	myteam = self.owner.pers["team"];

	for ( ;; )
	{
		if( maps\mp\_gasgrenades::checkIsInCloud( self, level._empCloudList, myteam ))
		{
			println( "claymore in emp cloud, disabeling" );
			
			self.disabled = true;
			//self.inCloud = true;
			self notify( "disabled" );
		}
		else
		{
			self.disabled = undefined;
			//self.inCloud = undefined;
			self notify( "enabled" );
		}

		waitframe();
	}
}


setSonicWardenTeamHeadIcon( team )
{
	self endon( "death" );
	wait .05;
	
	//clear any previous head icons.
	if ( level._teamBased )
		self maps\mp\_entityheadicons::setTeamHeadIcon( "none", ( 0, 0, 50 ) );
	else if ( isDefined( self.owner ))
	{
		if( isDefined( self.entityHeadIcon ))
		{
			self.entityHeadIcon destroy();
		}
	}
	
	//reset proper icon.
	if ( level._teamBased )
		self maps\mp\_entityheadicons::setTeamHeadIcon( team, ( 0, 0, 50 ) );
	else if ( isDefined( self.owner ) )
		self maps\mp\_entityheadicons::setPlayerHeadIcon( self.owner, (0,0,50) );
}


setClaymoreTeamHeadIcon( team )
{
	self endon( "death" );
	wait .05;
	
	//clear any previous head icons.
	if ( level._teamBased )
		self maps\mp\_entityheadicons::setTeamHeadIcon( "none", ( 0, 0, 20 ) );
	else if ( isDefined( self.owner ))
	{
		if( isDefined( self.entityHeadIcon ))
		{
			self.entityHeadIcon destroy();
		}
	}
	
	//reset proper icon.
	if ( level._teamBased )
		self maps\mp\_entityheadicons::setTeamHeadIcon( team, ( 0, 0, 20 ) );
	else if ( isDefined( self.owner ) )
		self maps\mp\_entityheadicons::setPlayerHeadIcon( self.owner, (0,0,20) );
}


watchClaymores()
{
	self endon( "spawned_player" );
	self endon( "disconnect" );

	self.claymorearray = [];
	while ( 1 )
	{
		self waittill( "grenade_fire", claymore, weapname );
		if ( weapname == "claymore" || weapname == "claymore_mp" )
		{
			self.claymorearray = array_removeUndefined( self.claymorearray );
			
			if( self.claymoreArray.size >= level._maxPerPlayerExplosives )
			{
				self.claymoreArray[0] detonate();
			}
			
			self.claymorearray[ self.claymorearray.size ] = claymore;
			claymore.owner = self;
			claymore.team = self.team;
			claymore.weaponName = weapname;
			claymore.hacked = false;

			claymore thread c4Damage();
			// tagJWP<NOTE> this is taken care of by the _gasgrenade.gsc file for the emp grenade
			//claymore thread c4EMPDamage();
			claymore thread c4EMPKillstreakWait();
			claymore thread claymoreDetonation();
			claymore thread claymoreWatchForEmpCloud();
			//claymore thread claymoreDetectionTrigger_wait( self.pers[ "team" ] );
			claymore thread setClaymoreTeamHeadIcon( self.pers[ "team" ] );
			
			claymore thread WatchForPickup( self );

			 /#
			if ( getdvarint( "scr_claymoredebug" ) )
			{
				claymore thread claymoreDebug();
			}
			#/
		}
		if ( weapname == "sonic_warden_mp" )
		{
			self.claymorearray = array_removeUndefined( self.claymorearray );
			
			if( self.claymoreArray.size >= level._maxPerPlayerExplosives )
			{
				self.claymoreArray[0] detonate();
			}
			
			self.claymorearray[ self.claymorearray.size ] = claymore;
			claymore.owner = self;
			claymore.team = self.team;
			claymore.weaponName = weapname;
			claymore.hacked = false;

			claymore thread c4Damage();
			// tagJWP<NOTE> this is taken care of by the _gasgrenade.gsc file for the emp grenade
			// claymore thread c4EMPDamage();
			claymore thread c4EMPKillstreakWait();
			claymore thread sonic_wardenDetonation();
			claymore thread setSonicWardenTeamHeadIcon( self.pers[ "team" ] );
			
			claymore thread WatchForPickup( self );
		}
	}
}

watchLidarMines()
{
	self endon( "spawned_player" );
	self endon( "disconnect" );

	self.lidararray = [];
	while ( 1 )
	{
		self waittill( "grenade_fire", lidarmine, weapname );
		if ( weapname == "lidarmine" || weapname == "lidarmine_mp" )
		{
			self.lidararray = array_removeUndefined( self.lidararray );
			
			if( self.lidararray.size >= level._maxPerPlayerExplosives )
			{
				self.lidararray[0] detonate();
			}
			
			self.lidararray[ self.lidararray.size ] = lidarmine;
			lidarmine.owner = self;
			lidarmine.team = self.team;
			lidarmine.weaponName = weapname;
			lidarmine.hacked = false;

			//used to monitor damage taken by this lidar device
			lidarmine thread c4Damage();
			
			//thread monitors emp damage, emps will disable the device for the duration of the EMP
			//lidarmine thread c4EMPDamage();
			//lidarmine thread c4EMPKillstreakWait();
			
			//lidar main pulse handeling
			lidarmine thread pulseLidarSweeps();
			
			//destroy on owner death
			lidarmine thread watchForOwnerDeath();
			
			//will want to set this up
			//lidarmine thread setClaymoreTeamHeadIcon( self.pers[ "team" ] );
			
			//will want to set this up
			lidarmine thread WatchForPickup( self );

		}
	}
}

pulseLidarSweeps()
{
	self endon( "death" );
	
	//design tweakable values
	pulseRadius = getDvarInt( "scr_LIDARPulseRadius" );
	lidarTickTime = getDvarInt( "scr_LIDARTickTime" );
	lidarNumTicks = getDvarFloat( "scr_LIDARNumTicks" );
	
	lidarMineTotalTime = 0;
	duration = lidarNumTicks * lidarTickTime;

	//while( lidarMineTotalTime < duration )
	while( true )
	{
		//apply lidar fx to players in the radius
		foreach( player in level._players )
		{	
			if( level._teamBased )
			{
				if( !isDefined( player.team ))
				{
					continue;
				}
				
				if( !isDefined( self.owner ))
				{
					continue;
				}
				
				if( player.team == self.team )
				{
					continue;
				}
			}
			else
			{
				//dont tag myself in ffa games
				if( player == self.owner )
				{
					continue;
				}
			}
			
			dist = distance( self.origin, player.origin );
			if( dist < pulseRadius )
			{
				visArg = self.team;
				if( !level._teambased )
				{
					//in non team based games just show the icons to me.
					visArg = self.owner;
				}
				
				numTicks = 1;
				player thread applyLidarHeadIcon( visArg, lidarTickTime, numTicks );
				//player applyLidarHeadIcon( visArg, lidarTickTime, numTicks );
			}
		}
		
		wait( lidarTickTime );
		lidarMineTotalTime += lidarTickTime;
	}
		
	self delete();
}

watchForOwnerDeath()
{
	self endon( "death" );
	self.owner waittill( "death" );
	self delete();
}

 /#
claymoreDebug()
{
	self waittill( "missile_stuck" );
	self thread showCone( acos( level._claymoreDetectionDot ), level._claymoreDetonateRadius, ( 1, .85, 0 ) );
	self thread showCone( 60, 256, ( 1, 0, 0 ) );
}

minevectorcross( v1, v2 )
{
	return( v1[ 1 ] * v2[ 2 ] - v1[ 2 ] * v2[ 1 ], v1[ 2 ] * v2[ 0 ] - v1[ 0 ] * v2[ 2 ], v1[ 0 ] * v2[ 1 ] - v1[ 1 ] * v2[ 0 ] ); 
}

showCone( angle, range, color )
{
	self endon( "death" );

	start = self.origin;
	forward = anglestoforward( self.angles );
	right = minevectorcross( forward, ( 0, 0, 1 ) );
	up = minevectorcross( forward, right );

	fullforward = forward * range * cos( angle );
	sideamnt = range * sin( angle );

	while ( 1 )
	{
		prevpoint = ( 0, 0, 0 );
		for ( i = 0; i <= 20; i++ )
		{
			coneangle = i / 20.0 * 360;
			point = start + fullforward + sideamnt * ( right * cos( coneangle ) + up * sin( coneangle ) );
			if ( i > 0 )
			{
				line( start, point, color );
				line( prevpoint, point, color );
			}
			prevpoint = point;
		}
		wait .05;
	}
}
#/

sonic_wardenDetonation()
{
	self endon( "death" );

	self waittill( "missile_stuck" );

	damagearea = spawn( "trigger_radius", self.origin + ( 0, 0, 0 - level._sonicWardenRadius ), 0, level._sonicWardenRadius, level._sonicWardenRadius * 2 );

	dummysonic = spawn( "script_model", self.origin+ (0,0,0) );
	dummysonic playLoopSound( "emt_road_flare_burn" );	 

	self thread deleteOnDeath( damagearea, dummysonic );

	// JU: add a delay so it doesn't take effect as soon as it's placed.
	wait 2;

//	wait 3;		// PJR. Temp: give chance to get away for testing.
	while ( 1 )
	{
		damagearea waittill( "trigger", player );

		is_enemy = 1;
		if ( getdvarint( "scr_claymoredebug" ) != 1 )
		{
			if ( isdefined( self.owner ) && player == self.owner )
			{
				is_enemy = 0;
			}
			else if ( !friendlyFireCheck( self.owner, player, 0 ) )
			{
				is_enemy = 0;
			}
		}

		if ( is_enemy == 1 )
		{
			// Now that we've triggered & we've verified that this is an enemy player, monitor until we no longer trigger.
			currently_shocked = 0;
			while ( 1 )
			{
				// Get distance to emitter.
				emitter = damagearea.origin * ( 1, 1, 0 );
				playerpos = player.origin * ( 1, 1, 0 );
				dist = distance( playerpos, emitter );
				
				

				radius = level._sonicWardenRadius;
	
				if ( dist < radius )
				{
					// Inside radius.  Shellshock the player.
					if ( currently_shocked == 0 )
					{
						player shellShock( "default", 30 );		// Long enough...
						currently_shocked = 1;
					}
				}
				else
				{
					// Out of radius area - done.  Remove ShellShock.
					player fadeoutshellshock();	
					break;
				}
				wait .05;
			}
		}
	}
}

claymoreDetonation()
{
	self endon( "death" );

	self waittill( "missile_stuck" );

	damagearea = spawn( "trigger_radius", self.origin + ( 0, 0, 0 - level._claymoreDetonateRadius ), 0, level._claymoreDetonateRadius, level._claymoreDetonateRadius * 2 );
	self thread deleteOnDeath( damagearea );

	while ( 1 )
	{
		damagearea waittill( "trigger", player );

		if ( getdvarint( "scr_claymoredebug" ) != 1 )
		{
			if ( isdefined( self.owner ) && player == self.owner )
				continue;
			if ( !friendlyFireCheck( self.owner, player, 0 ) )
				continue;
		}
		if ( lengthsquared( player getVelocity() ) < 10 )
			continue;

		if ( !player shouldAffectClaymore( self ) )
			continue;

		if ( player damageConeTrace( self.origin, self ) > 0 )
			break;
	}
	
	self playsound ("claymore_activated");
	
	
	if ( player _hasPerk( "specialty_delaymine" ) )
		wait 3.0;
	else 
		wait level._claymoreDetectionGracePeriod;
		
	self detonate( self.owner );
}

shouldAffectClaymore( claymore )
{
	if ( isDefined( claymore.disabled ) )
		return false;

	if( isDefined( claymore.inCloud ))
		return false;

	pos = self.origin + ( 0, 0, 32 );

	dirToPos = pos - claymore.origin;
	claymoreForward = anglesToForward( claymore.angles );

	dist = vectorDot( dirToPos, claymoreForward );
	if ( dist < level._claymoreDetectionMinDist )
		return false;

	dirToPos = vectornormalize( dirToPos );

	dot = vectorDot( dirToPos, claymoreForward );
	return( dot > level._claymoreDetectionDot );
}

deleteOnDeath( ent,ent2 )
{
	self waittill( "death" );
	wait .05;
	if ( isdefined( ent ) )
		ent delete();
	if ( isdefined( ent2 ) )
		ent2 delete();
}

c4Activate()
{
	self endon( "death" );

	self waittill( "missile_stuck" );

	wait 0.05;

	self notify( "activated" );
	self.activated = true;
}

watchC4AltDetonate()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "detonated" );
	level endon( "game_ended" );

	buttonTime = 0;
	for ( ;; )
	{
		if ( self UseButtonPressed() )
		{
			buttonTime = 0;
			while ( self UseButtonPressed() )
			{
				buttonTime += 0.05;
				wait( 0.05 );
			}

			println( "pressTime1: " + buttonTime );
			if ( buttonTime >= 0.5 )
				continue;

			buttonTime = 0;
			while ( !self UseButtonPressed() && buttonTime < 0.5 )
			{
				buttonTime += 0.05;
				wait( 0.05 );
			}

			println( "delayTime: " + buttonTime );
			if ( buttonTime >= 0.5 )
				continue;

			if ( !self.c4Array.size )
				return;

			self notify( "alt_detonate" );
			//println( "sending alt_detonate notify");
		}
		wait( 0.05 );
	}
}

watchC4Detonation()
{
	self endon( "death" );
	self endon( "disconnect" );

	while ( 1 )
	{
		self waittillmatch( "detonate", "c4_mp" );
		newarray = [];
		for ( i = 0; i < self.c4array.size; i++ )
		{
			c4 = self.c4array[ i ];
			if ( isdefined( self.c4array[ i ] ) )
				c4 thread waitAndDetonate( 0.1 );
		}
		self.c4array = newarray;
		self notify( "detonated" );
	}
}


watchC4AltDetonation()
{
	self endon( "death" );
	self endon( "disconnect" );

	while ( 1 )
	{
		self waittill( "alt_detonate" );
		//println( "alt det triggered" );
		
		newarray = [];
		for ( i = 0; i < self.c4array.size; i++ )
		{
			c4 = self.c4array[ i ];
			if ( isdefined( self.c4array[ i ] ) )
				c4 thread waitAndDetonate( 0.1 );
		}
		self.c4array = newarray;
		self notify( "detonated" );
	}
}


waitAndDetonate( delay )
{
	self endon( "death" );
	wait delay;

	self waitTillEnabled();
	self detonate();
}

deleteC4AndClaymoresOnDisconnect()
{
	self endon( "death" );
	self waittill( "disconnect" );

	c4array = self.c4array;
	claymorearray = self.claymorearray;

	wait .05;

	for ( i = 0; i < c4array.size; i++ )
	{
		if ( isdefined( c4array[ i ] ) )
		{
			c4array[ i ] delete();
		}
			
	}
	for ( i = 0; i < claymorearray.size; i++ )
	{
		if ( isdefined( claymorearray[ i ] ) )
		{
			claymorearray[ i ] delete();
		}
	}
}

c4Damage()
{
	self endon( "death" );

	self setcandamage( true );
	self.maxhealth = 100000;
	self.health = self.maxhealth;

	attacker = undefined;

	while ( 1 )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, iDFlags );
		if ( !isPlayer( attacker ) )
			continue;

		// don't allow people to destroy C4 on their team if FF is off
		if ( !friendlyFireCheck( self.owner, attacker ) )
			continue;

		if ( damage < 5 )// ignore concussion grenades
			continue;

		break;
	}

	if ( level._c4explodethisframe )
		wait .1 + randomfloat( .4 );
	else
		wait .05;

	if ( !isdefined( self ) )
		return;

	level._c4explodethisframe = true;

	thread resetC4ExplodeThisFrame();

	if ( isDefined( type ) && ( isSubStr( type, "MOD_GRENADE" ) || isSubStr( type, "MOD_EXPLOSIVE" ) ) )
		self.wasChained = true;

	if ( isDefined( iDFlags ) && ( iDFlags & level._iDFLAGS_PENETRATION ) )
		self.wasDamagedFromBulletPenetration = true;

	self.wasDamaged = true;

	if ( level._teamBased )
	{
		// "destroyed_explosive" notify, for challenges
		if ( isdefined( attacker ) && isdefined( attacker.pers[ "team" ] ) && isdefined( self.owner ) && isdefined( self.owner.pers[ "team" ] ) )
		{
			if ( attacker.pers[ "team" ] != self.owner.pers[ "team" ] )
				attacker notify( "destroyed_explosive" );
		}
	}
	else
	{
		// checking isDefined attacker is defensive but it's too late in the project to risk issues by not having it
		if ( isDefined( self.owner ) && isDefined( attacker ) && attacker != self.owner )
			attacker notify( "destroyed_explosive" );		
	}

	self detonate( attacker );
	// won't get here; got death notify.
}

resetC4ExplodeThisFrame()
{
	wait .05;
	level._c4explodethisframe = false;
}

saydamaged( orig, amount )
{
	for ( i = 0; i < 60; i++ )
	{
		print3d( orig, "damaged! " + amount );
		wait .05;
	}
}

waitTillEnabled()
{
	if ( !isDefined( self.disabled ) )
		return;

	self waittill( "enabled" );
	assert( !isDefined( self.disabled ) );
}

//called on c4 and claymores and lidar mines
watchForPickup( owner )
{
	//TagZP<NOTE> once an explosive has been hacked it can no longer be picked up by the owner.
	//this solves the equipment slot issue ( issue = i hack claymore, but dont have space for it in my inventory )
	
	//set up c4 triggers
	if( self.weaponname == "c4" || self.weaponname == "c4_mp" )
	{
		if( self.activated == false )
		{
			self waittill( "activated" );
		}
		//println( "Watch For Pickup Activated!!!");
	
		//set up hacking trigger
		self.enemyTrigger = spawn( "script_origin", self.origin );
		self thread deleteOnDeath( self.enemyTrigger );
		self thread C4EnemyUseListener( owner );
		
		//set up triger for owener to pick explosive back up
		if( self.hacked == false )
		{
			self.allyTrigger = spawn( "script_origin", self.origin );
			self thread deleteOnDeath( self.allyTrigger );
			self thread C4UseListener( owner );
		}
	}

	//set up claymore triggers
	if( self.weaponname == "claymore" || self.weaponname == "claymore_mp" )
	{
		//set up hacking trigger
		self.enemyTrigger = spawn( "script_origin", self.origin );
		self thread deleteOnDeath( self.enemyTrigger );
		self thread ClaymoreEnemyUseListener( owner );
		
		//set up triger for owener to pick explosive back up
		if( self.hacked == false )
		{
			self.allyTrigger = spawn( "script_origin", self.origin );
			self thread deleteOnDeath( self.allyTrigger );
			self thread ClaymoreUseListener( owner );
		}
	}

	//set up sonic warden triggers
	if( self.weaponname == "sonic_warden_mp" )
	{
		self.allyTrigger = spawn( "script_origin", self.origin );
		self thread deleteOnDeath( self.allyTrigger );
		self thread SonicWardenUseListener( owner );
	}
	
	//set up sonic warden triggers
	if( self.weaponname == "lidarmine_mp" )
	{
		self.allyTrigger = spawn( "script_origin", self.origin );
		self thread deleteOnDeath( self.allyTrigger );
		self thread LidarMineUseListener( owner );
	}
}

//watches for enemys to hack this instance C4
//runs on C4 object
C4EnemyUseListener( owner )
{
	self endon ( "death" );
	level endon ( "game_ended" );
	owner endon ( "disconnect" );
	
	self.enemyTrigger setCursorHint( "HINT_NOICON" );
	self.enemyTrigger setHintString( &"MP_PRESS_TO_HACK_EXPLOSIVE" );
	self.enemyTrigger makeEnemyUsable( owner );
	
	self.enemyTrigger thread ManageHackTriggers( owner );
	
	//wait for a player to activate the trigger
	self.enemyTrigger waittill ( "trigger", player );
	
	//remove this c4 from the previous owners c4 array
	newArray = [];
	for( i = 0;  i < owner.c4array.size; i++ )
	{
		if( owner.c4array[i] != self )
		{
			newArray[newArray.size] = owner.c4array[i];
		}
	}
	
	//it is possible that the player detonated the c4 as i tried to hack it.
	if( newArray.size == owner.c4array.size )
	{
		//we didnt find this c4 in his list, bail
		return;
	}
	
	//assert that we have sucessfully removed one c4 insance from the previous owner
	assert( newArray.size == (owner.c4array.size - 1 ));
	owner.c4array = newArray;
	
	//update the C4 instance data
	self.owner = player;
	self.team = player.team;
	self.hacked = true;
	self setmissileowner( player );
	
	//if the alt detonate thread is not running, get it going
	if ( !player.c4array.size )
	{
		player thread watchC4AltDetonate();
	}
		
	//If the player alreasy has the maximum number of explosives allowed, remove the first c4 from his array
	if ( player.c4array.size == level._maxPerPlayerExplosives )
	{
		firstC4 = player.c4array[0];
		firstC4 delete();
		for ( i = 0; i < player.c4array.size - 1; i++ )
		{
			player.c4array[i] = player.c4array[i+1];
		}
	}
	//add this c4 to my c4 array
	player.c4array[player.c4array.size] = self;
	
	level notify( "c4_hacked" );
	
	//reset the triggers on this C4 instance
	self PlantedExplosiveDeleteUseTriggers();
	self thread watchForPickup( player );	
}

C4UseListener( owner )
{
	self endon ( "death" );
	level endon ( "game_ended" );
	owner endon ( "disconnect" );
	
	self.allyTrigger setCursorHint( "HINT_NOICON" );
	self.allyTrigger setHintString( &"MP_C4_PRESS_TO_PICKUP" );
	self.allyTrigger MakeUsable( owner );
	
	//only I can use my C4, disable any one elses usage here.
	foreach ( player in level._players )
	{
		if ( player == owner )
		{
			self.allyTrigger enablePlayerUse( player );
		}
		else
		{
			self.allyTrigger disablePlayerUse( player );
		}
	}

	//wait for a player to activate the trigger
	self.allyTrigger waittill ( "trigger", player );
	
	//i am picking up my own c4
	if( self.owner == player )
	{	
		//reset my c4 inventory
		newArray = [];
		for( i = 0;  i < player.c4array.size; i++ )
		{
			if( player.c4array[i] != self )
			{
				newArray[newArray.size] = player.c4array[i];
			}
		}
		assert( newArray.size == (owner.c4array.size - 1 ));
		player.c4array = newArray;
		player SetWeaponAmmoStock( "c4_mp", (player GetWeaponAmmoStock ( "c4_mp" ) + 1 ));
		self delete();
	}
	//my teamate is picking up the c4
	else
	{
		//At the moment this is not supported ( may never be supported )
		println("Teamate is picking up c4");
	}
}

//runs on a claymore, waits for an enemy to hack it.
ClaymoreEnemyUseListener( owner )
{
	self endon ( "death" );
	level endon ( "game_ended" );
	owner endon ( "disconnect" );
	
	self.enemyTrigger setCursorHint( "HINT_NOICON" );
	self.enemyTrigger setHintString( &"MP_PRESS_TO_HACK_EXPLOSIVE" );
	self.enemyTrigger makeEnemyUsable( owner );
	
	self.enemyTrigger thread ManageHackTriggers( owner );
	
	//wait for a player to activate the trigger
	self.enemyTrigger waittill ( "trigger", player );
	
	//remove this claymore from the previous owners claymore array
	newArray = [];
	for( i = 0;  i < owner.claymorearray.size; i++ )
	{
		if( owner.claymorearray[i] != self )
		{
			newArray[newArray.size] = owner.claymorearray[i];
		}
	}
	//assert that we have sucessfully removed one claymore insance from the previous owner
	assert( newArray.size == (owner.claymorearray.size - 1 ));
	owner.claymorearray = newArray;
	
	//update the claymore instance data
	self.owner = player;
	self.team = player.team;
	self.hacked = true;
		
	//add this claymore to my claymore array
	player.claymorearray[player.claymorearray.size] = self;
	
	//reset the head icon
	self thread setClaymoreTeamHeadIcon( player.pers[ "team" ] );
	
	level notify( "claymore_hacked" );
	
	//reset the use triggers
	self PlantedExplosiveDeleteUseTriggers();
	self thread watchForPickup( player );
}

//This script will run on a hackable device and keep the enemy use triggers up to date as player loadouts change
ManageHackTriggers( owner )
{
	self endon( "death" );
	
	for( ;; )
	{
		foreach ( player in level._players )
		{
			//when hacker perk goes live add a check for it here. and enable this code
			if ( player.pers["team"] != owner.pers["team"] && player _hasPerk("specialty_equipmenthack") )
			{
				self enablePlayerUse( player );
			}
			else
			{
				self disablePlayerUse( player );
			}
		}
		
		level waittill( "player_spawned", spawned_player );
	}
	
}

//Runs on a claymore, watches for the owner to come pick it back up
ClaymoreUseListener( owner )
{
	self endon ( "death" );
	level endon ( "game_ended" );
	owner endon ( "disconnect" );
	
	self.allyTrigger setCursorHint( "HINT_NOICON" );
	self.allyTrigger setHintString( &"MP_CLAYMORE_PRESS_TO_PICKUP" );
	self.allyTrigger MakeUsable( owner );
	
	//only I can use my C4, disable any one elses usage here.
	foreach ( player in level._players )
	{
		if ( player == owner )
		{
			self.allyTrigger enablePlayerUse( player );
		}
		else
		{
			self.allyTrigger disablePlayerUse( player );
		}
	}

	//wait for a player to activate the trigger
	self.allyTrigger waittill ( "trigger", player );
		
	//i am picking up my own claymore
	if( self.owner == player )
	{	
		//reset my claymore inventory
		player.claymorearray = [];
		player giveWeapon( "claymore_mp" );
		player giveMaxAmmo( "claymore_mp" );
		self delete();
	}
	//my teamate is picking up the claymore
	else
	{
		//At the moment this is not supported ( may never be supported )
		println("Teamate is picking up claymore");
	}
}

//Runs on a sonic warden, watches for the owner to come pick it back up
SonicWardenUseListener( owner )
{
	self endon ( "death" );
	level endon ( "game_ended" );
	owner endon ( "disconnect" );
	
	self.allyTrigger setCursorHint( "HINT_NOICON" );
	self.allyTrigger setHintString( &"MP_SONIC_WARDEN_PRESS_TO_PICKUP" );
	self.allyTrigger MakeUsable( owner );
	
	//only I can use my sonic warden, disable any one elses usage here.
	foreach ( player in level._players )
	{
		if ( player == owner )
		{
			self.allyTrigger enablePlayerUse( player );
		}
		else
		{
			self.allyTrigger disablePlayerUse( player );
		}
	}

	//wait for a player to activate the trigger
	self.allyTrigger waittill ( "trigger", player );
		
	//i am picking up my own sonic warden
	if( self.owner == player )
	{	
		//reset my claymore inventory
		player.claymorearray = [];
		player giveWeapon( "sonic_warden_mp" );
		player giveMaxAmmo( "sonic_warden_mp" );
		self delete();
	}
	//my teamate is picking up the claymore
	else
	{
		//At the moment this is not supported ( may never be supported )
		println("Teamate is picking up sonic warden");
	}
}

LidarMineUseListener( owner )
{
	self endon ( "death" );
	level endon ( "game_ended" );
	owner endon ( "disconnect" );
	
	self.allyTrigger setCursorHint( "HINT_NOICON" );
	self.allyTrigger setHintString( &"MP_CLAYMORE_PRESS_TO_PICKUP" );
	self.allyTrigger MakeUsable( owner );
	
	//only I can use my lidar mine, disable any one elses usage here.
	foreach ( player in level._players )
	{
		if ( player == owner )
		{
			self.allyTrigger enablePlayerUse( player );
		}
		else
		{
			self.allyTrigger disablePlayerUse( player );
		}
	}

	//wait for a player to activate the trigger
	self.allyTrigger waittill ( "trigger", player );
		
	//i am picking up my own lidar mine
	if( self.owner == player )
	{	
		//reset my lidar mine
		player.lidararray = [];
		player giveWeapon( "lidarmine_mp" );
		player giveMaxAmmo( "lidarmine_mp" );
		self delete();
	}
	//my teamate is picking up the lidarmine
	else
	{
		//At the moment this is not supported ( may never be supported )
		println("Teamate is picking up sonic warden");
	}
}

PlantedExplosiveDeleteUseTriggers()
{
	if( isDefined( self.EnemyTrigger ))
	{
		self.EnemyTrigger Delete();
	}
	
	if( isDefined( self.AllyTrigger ))
	{
		self.AllyTrigger Delete();
	}
}


c4DetectionTrigger( ownerTeam )
{
	self waittill( "activated" );
	
	trigger = spawn( "trigger_radius", self.origin - ( 0, 0, 128 ), 0, 512, 256 );
	trigger.detectId = "trigger" + getTime() + randomInt( 1000000 );

	trigger.owner = self;
	trigger thread detectIconWaiter( level._otherTeam[ ownerTeam ] );

	self waittill( "death" );
	trigger notify( "end_detection" );

	if ( isDefined( trigger.bombSquadIcon ))
		trigger.bombSquadIcon destroy();

	trigger delete();
}


claymoreDetectionTrigger_wait( ownerTeam )
{
	self endon( "death" );
	self waittill( "missile_stuck" );

	self thread claymoreDetectionTrigger( ownerTeam );
}

claymoreDetectionTrigger( ownerTeam )
{
	trigger = spawn( "trigger_radius", self.origin - ( 0, 0, 128 ), 0, 512, 256 );
	trigger.detectId = "trigger" + getTime() + randomInt( 1000000 );

	trigger.owner = self;
	trigger thread detectIconWaiter( level._otherTeam[ ownerTeam ] );

	self waittill( "death" );
	trigger notify( "end_detection" );

	if ( isDefined( trigger.bombSquadIcon ) )
		trigger.bombSquadIcon destroy();

	trigger delete();
}


detectIconWaiter( detectTeam )
{
	self endon( "end_detection" );
	level endon( "game_ended" );

	while ( !level._gameEnded )
	{
		self waittill( "trigger", player );

		if ( !player.detectExplosives )
			continue;

		if ( level._teamBased && player.team != detectTeam )
			continue;
		else if ( !level._teamBased && player == self.owner.owner )
			continue;

		if ( isDefined( player.bombSquadIds[ self.detectId ] ) )
			continue;

		player thread showHeadIcon( self );
	}
}


setupBombSquad()
{
	self.bombSquadIds = [];

	if ( self.detectExplosives && !self.bombSquadIcons.size )
	{
		for ( index = 0; index < 4; index++ )
		{
			self.bombSquadIcons[ index ] = newClientHudElem( self );
			self.bombSquadIcons[ index ].x = 0;
			self.bombSquadIcons[ index ].y = 0;
			self.bombSquadIcons[ index ].z = 0;
			self.bombSquadIcons[ index ].alpha = 0;
			self.bombSquadIcons[ index ].archived = true;
			self.bombSquadIcons[ index ] setShader( "waypoint_bombsquad", 14, 14 );
			self.bombSquadIcons[ index ] setWaypoint( false, false );
			self.bombSquadIcons[ index ].detectId = "";
		}
	}
	else if ( !self.detectExplosives )
	{
		for ( index = 0; index < self.bombSquadIcons.size; index++ )
			self.bombSquadIcons[ index ] destroy();

		self.bombSquadIcons = [];
	}
}


showHeadIcon( trigger )
{
	triggerDetectId = trigger.detectId;
	useId = -1;
	for ( index = 0; index < 4; index++ )
	{
		detectId = self.bombSquadIcons[ index ].detectId;

		if ( detectId == triggerDetectId )
			return;

		if ( detectId == "" )
			useId = index;
	}

	if ( useId < 0 )
		return;

	self.bombSquadIds[ triggerDetectId ] = true;

	self.bombSquadIcons[ useId ].x = trigger.origin[ 0 ];
	self.bombSquadIcons[ useId ].y = trigger.origin[ 1 ];
	self.bombSquadIcons[ useId ].z = trigger.origin[ 2 ] + 24 + 128;

	self.bombSquadIcons[ useId ] fadeOverTime( 0.25 );
	self.bombSquadIcons[ useId ].alpha = 1;
	self.bombSquadIcons[ useId ].detectId = trigger.detectId;

	while ( isAlive( self ) && isDefined( trigger ) && self isTouching( trigger ) )
		wait( 0.05 );

	if ( !isDefined( self ) )
		return;

	self.bombSquadIcons[ useId ].detectId = "";
	self.bombSquadIcons[ useId ] fadeOverTime( 0.25 );
	self.bombSquadIcons[ useId ].alpha = 0;
	self.bombSquadIds[ triggerDetectId ] = undefined;
}


// these functions are used with scripted weapons (like c4, claymores, artillery)
// returns an array of objects representing damageable entities (including players) within a given sphere.
// each object has the property damageCenter, which represents its center (the location from which it can be damaged).
// each object also has the property entity, which contains the entity that it represents.
// to damage it, call damageEnt() on it.
getDamageableEnts( pos, radius, doLOS, startRadius )
{
	ents = [];

	if ( !isdefined( doLOS ) )
		doLOS = false;

	if ( !isdefined( startRadius ) )
		startRadius = 0;
	
	radiusSq = radius * radius;

	// players
	players = level._players;
	for ( i = 0; i < players.size; i++ )
	{
		if ( !isalive( players[ i ] ) || players[ i ].sessionstate != "playing" )
			continue;

		playerpos = get_damageable_player_pos( players[ i ] );
		distSq = distanceSquared( pos, playerpos );
		if ( distSq < radiusSq && ( !doLOS || weaponDamageTracePassed( pos, playerpos, startRadius, players[ i ] ) ) )
		{
			ents[ ents.size ] = get_damageable_player( players[ i ], playerpos );
		}
	}

	// grenades
	grenades = getentarray( "grenade", "classname" );
	for ( i = 0; i < grenades.size; i++ )
	{
		entpos = get_damageable_grenade_pos( grenades[ i ] );
		distSq = distanceSquared( pos, entpos );
		if ( distSq < radiusSq && ( !doLOS || weaponDamageTracePassed( pos, entpos, startRadius, grenades[ i ] ) ) )
		{
			ents[ ents.size ] = get_damageable_grenade( grenades[ i ], entpos );
		}
	}

	destructibles = getentarray( "destructible", "targetname" );
	for ( i = 0; i < destructibles.size; i++ )
	{
		entpos = destructibles[ i ].origin;
		distSq = distanceSquared( pos, entpos );
		if ( distSq < radiusSq && ( !doLOS || weaponDamageTracePassed( pos, entpos, startRadius, destructibles[ i ] ) ) )
		{
			newent = spawnstruct();
			newent.isPlayer = false;
			newent.isADestructable = false;
			newent.entity = destructibles[ i ];
			newent.damageCenter = entpos;
			ents[ ents.size ] = newent;
		}
	}

	destructables = getentarray( "destructable", "targetname" );
	for ( i = 0; i < destructables.size; i++ )
	{
		entpos = destructables[ i ].origin;
		distSq = distanceSquared( pos, entpos );
		if ( distSq < radiusSq && ( !doLOS || weaponDamageTracePassed( pos, entpos, startRadius, destructables[ i ] ) ) )
		{
			newent = spawnstruct();
			newent.isPlayer = false;
			newent.isADestructable = true;
			newent.entity = destructables[ i ];
			newent.damageCenter = entpos;
			ents[ ents.size ] = newent;
		}
	}
	
	//sentries
	sentries = getentarray( "misc_turret", "classname" );
	foreach ( sentry in sentries )
	{
		entpos = sentry.origin + (0,0,32);
		distSq = distanceSquared( pos, entpos );
		if ( distSq < radiusSq && ( !doLOS || weaponDamageTracePassed( pos, entpos, startRadius, sentry ) ) )
		{
			if ( sentry.model == "sentry_minigun" )
				ents[ ents.size ] = get_damageable_sentry(sentry, entpos);
		}
	}

	return ents;
}


getEMPDamageEnts( pos, radius, doLOS, startRadius )
{
	ents = [];

	if ( !isDefined( doLOS ) )
		doLOS = false;

	if ( !isDefined( startRadius ) )
		startRadius = 0;

	grenades = getEntArray( "grenade", "classname" );
	foreach ( grenade in grenades )
	{
		//if ( !isDefined( grenade.weaponName ) )
		//	continue;

		entpos = grenade.origin;
		dist = distance( pos, entpos );
		if ( dist < radius && ( !doLOS || weaponDamageTracePassed( pos, entpos, startRadius, grenade ) ) )
			ents[ ents.size ] = grenade;
	}

	turrets = getEntArray( "misc_turret", "classname" );
	foreach ( turret in turrets )
	{
		//if ( !isDefined( turret.weaponName ) )
		//	continue;

		entpos = turret.origin;
		dist = distance( pos, entpos );
		if ( dist < radius && ( !doLOS || weaponDamageTracePassed( pos, entpos, startRadius, turret ) ) )
			ents[ ents.size ] = turret;
	}

	return ents;
}


weaponDamageTracePassed( from, to, startRadius, ent )
{
	midpos = undefined;

	diff = to - from;
	if ( lengthsquared( diff ) < startRadius * startRadius )
		return true;
	
	dir = vectornormalize( diff );
	midpos = from + ( dir[ 0 ] * startRadius, dir[ 1 ] * startRadius, dir[ 2 ] * startRadius );

	trace = bullettrace( midpos, to, false, ent );

	if ( getdvarint( "scr_damage_debug" ) != 0 )
	{
		thread debugprint( from, ".dmg" );
		if ( isdefined( ent ) )
			thread debugprint( to, "." + ent.classname );
		else
			thread debugprint( to, ".undefined" );
		if ( trace[ "fraction" ] == 1 )
		{
			thread debugline( midpos, to, ( 1, 1, 1 ) );
		}
		else
		{
			thread debugline( midpos, trace[ "position" ], ( 1, .9, .8 ) );
			thread debugline( trace[ "position" ], to, ( 1, .4, .3 ) );
		}
	}

	return( trace[ "fraction" ] == 1 );
}

// eInflictor = the entity that causes the damage (e.g. a claymore)
// eAttacker = the player that is attacking
// iDamage = the amount of damage to do
// sMeansOfDeath = string specifying the method of death (e.g. "MOD_PROJECTILE_SPLASH")
// sWeapon = string specifying the weapon used (e.g. "claymore_mp")
// damagepos = the position damage is coming from
// damagedir = the direction damage is moving in
damageEnt( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, damagepos, damagedir )
{
	if ( self.isPlayer )
	{
		self.damageOrigin = damagepos;
		self.entity thread [[ level._callbackPlayerDamage ]](
			eInflictor,// eInflictor The entity that causes the damage.( e.g. a turret )
			eAttacker,// eAttacker The entity that is attacking.
			iDamage,// iDamage Integer specifying the amount of damage done
			0,// iDFlags Integer specifying flags that are to be applied to the damage
			sMeansOfDeath,// sMeansOfDeath Integer specifying the method of death
			sWeapon,// sWeapon The weapon number of the weapon used to inflict the damage
			damagepos,// vPoint The point the damage is from?
			damagedir,// vDir The direction of the damage
			"none",// sHitLoc The location of the hit
			0// psOffsetTime The time offset for the damage
		 );
	}
	else
	{
		// destructable walls and such can only be damaged in certain ways.
		if ( self.isADestructable && ( sWeapon == "artillery_mp" || sWeapon == "claymore_mp" ) || sWeapon == "stealth_bomb_mp" )
			return;

		self.entity notify( "damage", iDamage, eAttacker, ( 0, 0, 0 ), ( 0, 0, 0 ), "mod_explosive", "", "" );
	}
}


debugline( a, b, color )
{
	for ( i = 0; i < 30 * 20; i++ )
	{
		line( a, b, color );
		wait .05;
	}
}

debugprint( pt, txt )
{
	for ( i = 0; i < 30 * 20; i++ )
	{
		print3d( pt, txt );
		wait .05;
	}
}


onWeaponDamage( eInflictor, sWeapon, meansOfDeath, damage, eAttacker )
{
	self endon( "death" );
	self endon( "disconnect" );

	switch( sWeapon )
	{
		case "concussion_grenade_mp":
			// should match weapon settings in gdt
			radius = 512;
			scale = 1 - ( distance( self.origin, eInflictor.origin ) / radius );

			if ( scale < 0 )
				scale = 0;

			time = 2 + ( 4 * scale );

			//NX1 StunResistance perk
			if ( isDefined( self.stunScaler ) )
				time = time * self.stunScaler;
			
			wait( 0.05 );

			if ( eAttacker != self )
			{
				eAttacker notify( "stun_hit" );
			}

			self shellShock( "concussion_grenade_mp", time );
			self.concussionEndTime = getTime() + ( time * 1000 );
		break;

		case "weapon_cobra_mk19_mp":
			// mk19 is too powerful with shellshock slowdown
		break;

		default:
			// shellshock will only be done if meansofdeath is an appropriate type and if there is enough damage.
			maps\mp\gametypes\_shellshock::shellshockOnDamage( meansOfDeath, damage );
		break;
	}

}

// weapon stowing logic ===================================================================

// weapon class boolean helpers
isPrimaryWeapon( weapName )
{
	if ( weapName == "none" )
		return false;
		
	if ( weaponInventoryType( weapName ) != "primary" )
		return false;

	switch ( weaponClass( weapName ) )
	{
		case "rifle":
		case "smg":
		case "mg":
		case "spread":
		case "pistol":
		case "rocketlauncher":
		case "sniper":
			return true;

		default:
			return false;
	}	
}


isAltModeWeapon( weapName )
{
	if ( weapName == "none" )
		return false;
		
	return ( weaponInventoryType( weapName ) == "altmode" );
}

isInventoryWeapon( weapName )
{
	if ( weapName == "none" )
		return false;
		
	return ( weaponInventoryType( weapName ) == "item" );
}

isRiotShield( weapName )
{
	if ( weapName == "none" )
		return false;
		
	return ( WeaponType( weapName ) == "riotshield" );
}

isOffhandWeapon( weapName )
{
	if ( weapName == "none" )
		return false;
		
	return ( weaponInventoryType( weapName ) == "offhand" );
}

isSideArm( weapName )
{
	if ( weapName == "none" )
		return false;

	if ( weaponInventoryType( weapName ) != "primary" )
		return false;

	return ( weaponClass( weapName ) == "pistol" );
}


// This needs for than this.. this would qualify c4 as a grenade
isGrenade( weapName )
{
	weapClass = weaponClass( weapName );
	weapType = weaponInventoryType( weapName );

	if ( weapClass != "grenade" )
		return false;
		
	if ( weapType != "offhand" )
		return false;
}

// Those are grenade that create lasting effects on players once hit
isGrenadeWithLastingEffect( weapName )
{
	result = false;
	switch ( weapName )
	{
		case "flash_grenade_mp":
		case "concussion_grenade_mp":
		case "emp_grenade_mp":
		case "empcloud_grenade_mp":
		case "gas_grenade_mp":
		case "lidar_grenade_mp":
		case "hulc_emp_grenade_mp":
		case "hulc_gas_grenade_mp":
		case "hulc_lidar_grenade_mp":
			result = true;
	}
	return result;
}

getStowOffsetModel( weaponName )
{
	assert( isDefined( level._stow_offset_array ) );

	baseName = getBaseWeaponName( weaponName );
	
	return( level._stow_offset_array[baseName] );
}


stowPriorityWeapon()
{
	assert( isdefined( level._stow_priority_model_array ) );

	// returns the first large projectil the player owns in case player owns more than one
	foreach ( weapon_name, priority_weapon in level._stow_priority_model_array )
	{
		weaponName = getBaseWeaponName( weapon_name );
		weaponList = self getWeaponsListAll();
		
		foreach ( weapon in weaponList )
		{
			if( self getCurrentWeapon() == weapon )
				continue;
			
			if ( weaponName == getBaseWeaponName( weapon ) )
				return weaponName + "_mp";
		}
	}

	return "";
}

// thread loop life = player's life
updateStowedWeapon()
{
	self endon( "spawned" );
	self endon( "killed_player" );
	self endon( "disconnect" );

	self.tag_stowed_back = undefined;
	self.tag_stowed_hip = undefined;
	self.should_stow_weapon = true;
	
	team = self.team;
	class = self.class;
	
	self thread stowedWeaponsRefresh();
	
	while ( true )
	{
		self waittill( "weapon_change", newWeapon );
		
		if ( newWeapon == "none" )
		{
			continue;
		}

		if( !self.should_stow_weapon )
		{
			continue;
		}
			
		self thread stowedWeaponsRefresh();
	}
}

stowedWeaponsRefresh()
{
	self endon( "spawned" );
	self endon( "killed_player" );
	self endon( "disconnect" );
	
	detach_all_weapons();
	stow_on_back();
	stow_on_hip();
}


detach_all_weapons()
{
	if ( isDefined( self.tag_stowed_back ) )
		self detach_back_weapon();

	if ( isDefined( self.tag_stowed_hip ) )
		self detach_hip_weapon();
}


detach_back_weapon()
{
	detach_success = self detachIfAttached( self.tag_stowed_back, "tag_stowed_back" );

	// test for bug
	//assertex( detach_success, "Detaching: " + self.tag_stowed_back + " from tag: tag_stowed_back failed." );
	self.tag_stowed_back = undefined;
}


detach_hip_weapon()
{
	detach_success = self detachIfAttached( self.tag_stowed_hip, "tag_stowed_hip" );

	// test for bug
	//assertex( detach_success, "Detaching: " + detach_model + " from tag: tag_stowed_hip failed." );
	self.tag_stowed_hip = undefined;
}


stow_on_back()
{
	prof_begin( "stow_on_back" );
	currentWeapon = self getCurrentWeapon();
	currentIsAlt = isAltModeWeapon( currentWeapon );

	assert( !isDefined( self.tag_stowed_back ) );

	stowWeapon = undefined;
	stowCamo = 0;
	large_projectile = self stowPriorityWeapon();
	stowOffsetModel = undefined;

	if ( large_projectile != "" )
	{
		stowWeapon = large_projectile;
	}
	else
	{
		weaponsList = self getWeaponsListPrimaries();
		foreach ( weaponName in weaponsList )
		{
			if ( weaponName == currentWeapon )
				continue;
			
			invType = weaponInventoryType( weaponName );
			
			if ( invType != "primary" )
			{
				if ( invType == "altmode" )
					continue;
				
				if ( weaponClass( weaponName ) == "pistol" )
					continue;
			}
			
			if ( WeaponType( weaponName ) == "riotshield" )
				continue;
			
			// Don't stow the current on our back when we're using the alt
			if ( currentIsAlt && weaponAltWeaponName( weaponName ) == currentWeapon )
				continue;
				
			stowWeapon = weaponName;
			stowOffsetModel = getStowOffsetModel( stowWeapon );
			
			if ( stowWeapon == self.primaryWeapon )
				stowCamo = self.loadoutPrimaryCamo;
			else if ( stowWeapon == self.secondaryWeapon )
				stowCamo = self.loadoutSecondaryCamo;
			else
				stowCamo = 0;
		}		
	}

	if ( !isDefined( stowWeapon ) )
	{
		prof_end( "stow_on_back" );
		return;
	}

	if ( large_projectile != "" )
	{
		self.tag_stowed_back = level._stow_priority_model_array[ large_projectile ];
	}
	else
	{
		self.tag_stowed_back = getWeaponModel( stowWeapon, stowCamo );	
	}

	if ( isDefined( stowOffsetModel ) )
	{
		self attach( stowOffsetModel, "tag_stowed_back", true );
		attachTag = "tag_stow_back_mid_attach";
	}
	else
	{
		attachTag = "tag_stowed_back";
	}

	self attach( self.tag_stowed_back, attachTag, true );

	hideTagList = GetWeaponHideTags( stowWeapon );

	if ( !isDefined( hideTagList ) )
	{
		prof_end( "stow_on_back" );
		return;
	}

	for ( i = 0; i < hideTagList.size; i++ )
		self HidePart( hideTagList[ i ], self.tag_stowed_back );
	
	prof_end( "stow_on_back" );
}

stow_on_hip()
{
	currentWeapon = self getCurrentWeapon();

	assert( !isDefined( self.tag_stowed_hip ) );

	stowWeapon = undefined;

	weaponsList = self getWeaponsListOffhands();
	foreach ( weaponName in weaponsList )
	{
		if ( weaponName == currentWeapon )
			continue;
			
		if ( weaponName != "c4_mp" && weaponName != "claymore_mp" )
			continue;
		
		stowWeapon = weaponName;
	}

	if ( !isDefined( stowWeapon ) )
		return;

	self.tag_stowed_hip = getWeaponModel( stowWeapon );
	self attach( self.tag_stowed_hip, "tag_stowed_hip_rear", true );

	hideTagList = GetWeaponHideTags( stowWeapon );
	
	if ( !isDefined( hideTagList ) )
		return;
	
	for ( i = 0; i < hideTagList.size; i++ )
		self HidePart( hideTagList[ i ], self.tag_stowed_hip );
}


updateSavedLastWeapon()
{
	self endon( "death" );
	self endon( "disconnect" );

	currentWeapon = self.currentWeaponAtSpawn;
	self.saved_lastWeapon = currentWeapon;

	for ( ;; )
	{
		self waittill( "weapon_change", newWeapon );
	
		if ( newWeapon == "none" )
		{
			self.saved_lastWeapon = currentWeapon;
			continue;
		}

		weaponInvType = weaponInventoryType( newWeapon );

		if ( weaponInvType != "primary" && weaponInvType != "altmode" )
		{
			self.saved_lastWeapon = currentWeapon;
			continue;
		}
		
		if ( newWeapon == "onemanarmy_mp" )
		{
			self.saved_lastWeapon = currentWeapon;
			continue;
		}

		self updateMoveSpeedScale( "primary" );

		self.saved_lastWeapon = currentWeapon;
		currentWeapon = newWeapon;
	}
}


EMPPlayer( numSeconds )
{
	self endon( "disconnect" );
	self endon( "death" );

	self thread clearEMPOnDeath();

}


clearEMPOnDeath()
{
	self endon( "disconnect" );

	self waittill( "death" );
}


updateMoveSpeedScale( weaponType )
{
	/*
	if ( self _hasPerk( "specialty_lightweight" ) )
		self.moveSpeedScaler = 1.10;
	else
		self.moveSpeedScaler = 1;
	*/
	
	if ( !isDefined( weaponType ) || weaponType == "primary" || weaponType != "secondary" )
		weaponType = self.primaryWeapon;
	else
		weaponType = self.secondaryWeapon;
	
	if( isDefined(self.primaryWeapon ) && self.primaryWeapon == "riotshield_mp" )
	{
		self setMoveSpeedScale( 1.0 * self.moveSpeedScaler );
		return;
	}
	
	if ( !isDefined( weaponType ) )
		weapClass = "none";
	else 
		weapClass = weaponClass( weaponType );
	
	
	switch ( weapClass )
	{
		case "rifle":
			self setMoveSpeedScale( 1.0 * self.moveSpeedScaler );
			break;
		case "pistol":
			self setMoveSpeedScale( 1.0 * self.moveSpeedScaler );
			break;
		case "mg":
			self setMoveSpeedScale( 1.0 * self.moveSpeedScaler );
			break;
		case "smg":
			self setMoveSpeedScale( 1.0 * self.moveSpeedScaler );
			break;
		case "spread":
			self setMoveSpeedScale( 1.0 * self.moveSpeedScaler );
			break;
		case "rocketlauncher":
			self setMoveSpeedScale( 1.0 * self.moveSpeedScaler );
			break;
		case "sniper":
			self setMoveSpeedScale( 1.0 * self.moveSpeedScaler );
			break;
		default:
			self setMoveSpeedScale( 1.0 * self.moveSpeedScaler );
			break;
	}
}

stanceRecoilAdjuster()
{
	self endon ( "death" );
	self endon ( "disconnect" );	
	
	self notifyOnPlayerCommand( "adjustedStance", "+stance" );
	self notifyOnPlayerCommand( "adjustedStance", "+goStand" );
	
	for ( ;; )
	{
		self waittill_any( "adjustedStance", "sprint_begin" );
		
		weapClass = getWeaponClass( self GetCurrentPrimaryWeapon() );
		
		if ( weapClass != "weapon_lmg" && weapClass != "weapon_sniper" )
			continue;
		
		wait (.5 ); //necessary to ensure proper stance is given and to balance to ensure duck diving isnt a valid tactic
		
		self.stance = self GetStance();
		
		if ( self.stance == "prone" )
		{	
			if ( weapClass == "weapon_lmg" )
				self setRecoilScale( 0,40 );	
			else if ( weapClass == "weapon_sniper" )
				self setRecoilScale( 0,60 );
			else
				self setRecoilScale();		
		}
		else if ( self.stance == "crouch" )
		{
			if ( weapClass == "weapon_lmg" )
				self setRecoilScale( 0,10 );
			else if ( weapClass == "weapon_sniper" )
				self setRecoilScale( 0,30 );
			else
				self setRecoilScale();
		}
		else
		{
			self setRecoilScale();
		}
	}
}

buildWeaponData( filterPerks )
{
	attachmentList = getAttachmentList();		
	max_weapon_num = 149;

	baseWeaponData = [];
	
	for( weaponId = 0; weaponId <= max_weapon_num; weaponId++ )
	{
		baseName = tablelookup( "mp/statstable.csv", 0, weaponId, 4 );
		if( baseName == "" )
			continue;

		assetName = baseName + "_mp";

		if ( !isSubStr( tableLookup( "mp/statsTable.csv", 0, weaponId, 2 ), "weapon_" ) )
			continue;
		
		if ( weaponInventoryType( assetName ) != "primary" )
			continue;

		weaponInfo = spawnStruct();
		weaponInfo.baseName = baseName;
		weaponInfo.assetName = assetName;
		weaponInfo.variants = [];

		weaponInfo.variants[0] = assetName;
		// the alphabetize function is slow so we try not to do it for every weapon/attachment combo; a code solution would be better.
		attachmentNames = [];
		for ( innerLoopCount = 0; innerLoopCount < 6; innerLoopCount++ )
		{
			// generating attachment combinations
			attachmentName = tablelookup( "mp/statStable.csv", 0, weaponId, innerLoopCount + 11 );
			
			if ( filterPerks )
			{
				switch ( attachmentName )
				{
					case "fmj":
					case "xmags":
					case "rof":
						continue;
				}
			}
			
			if( attachmentName == "" )
				break;
			
			attachmentNames[attachmentName] = true;
		}

		// generate an alphabetized attachment list
		attachments = [];
		foreach ( attachmentName in attachmentList )
		{
			if ( !isDefined( attachmentNames[attachmentName] ) )
				continue;
			
			weaponInfo.variants[weaponInfo.variants.size] = baseName + "_" + attachmentName + "_mp";
			attachments[attachments.size] = attachmentName;
		}

		for ( i = 0; i < (attachments.size - 1); i++ )
		{
			colIndex = tableLookupRowNum( "mp/attachmentCombos.csv", 0, attachments[i] );
			for ( j = i + 1; j < attachments.size; j++ )
			{
				if ( tableLookup( "mp/attachmentCombos.csv", 0, attachments[j], colIndex ) == "no" )
					continue;
					
				weaponInfo.variants[weaponInfo.variants.size] = baseName + "_" + attachments[i] + "_" + attachments[j] + "_mp";
			}
		}
		
		baseWeaponData[baseName] = weaponInfo;
	}
	
	return ( baseWeaponData );
}

monitorSemtex()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	for( ;; )
	{
		self waittill( "grenade_fire", weapon );

		if ( !isSubStr(weapon.model, "semtex" ) )
			continue;
			
		weapon waittill( "missile_stuck", stuckTo );
			
		if ( !isPlayer( stuckTo ) )
			continue;
			
		if ( level._teamBased && isDefined( stuckTo.team ) && stuckTo.team == self.team )
		{
			weapon.isStuck = "friendly";
			continue;
		}
	
		weapon.isStuck = "enemy";
		weapon.stuckEnemyEntity = stuckTo;
		
		stuckTo maps\mp\gametypes\_hud_message::playerCardSplashNotify( "semtex_stuck", self );
		
		self thread maps\mp\gametypes\_hud_message::SplashNotify( "stuck_semtex", 100 );
		self notify( "process", "ch_bullseye" );
	}	
}


turret_monitorUse()
{
	for( ;; )
	{
		self waittill ( "trigger", player );
		
		self thread turret_playerThread( player );
	}
}

turret_playerThread( player )
{
	player endon ( "death" );
	player endon ( "disconnect" );

	player notify ( "weapon_change", "none" );
	
	self waittill ( "turret_deactivate" );
	
	player notify ( "weapon_change", player getCurrentWeapon() );
}

isEquipment ( weapon_name )
{
	result = false;
	switch ( weapon_name )
	{
		case "claymore_mp":
		case "c4_mp":
		case "frag_grenade_mp":
		case "semtex_mp":
		case "gas_grenade_mp":
			result = true;
	}
	return result;
}