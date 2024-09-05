#include maps\_hud_util;
#include common_scripts\utility;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*
=============
///ScriptDocBegin
"Name: viewmodel_create_ammo_counter()"
"Summary: create client hud elements to be applied to weapon view model"
"Module: Utility"
"CallOn: nothing"
"MandatoryArg:"
"Example: viewmodel_create_ammo_counter();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
viewmodel_apply_ui( weapon_name )
{
	// always cleanup our old stuff first

	// cleanup our update functions
	self notify( "viewmodel_ui_update" );

	// cleanup our old weapons stuff, value for _viewmodel_ui_weapon should already be set
	if ( level._viewmodel_ui_weapon != "" )
	{
		[[ level._viewmodel_ui[ level._viewmodel_ui_weapon ][ 0 ] ]]();
	}

	// now we create our new stuff
	if ( weapon_name != "" )
	{
		// set our weapon for create process and subsequent destroy
		level._viewmodel_ui_weapon = weapon_name;


		// create all of our elements
		[[ level._viewmodel_ui[ level._viewmodel_ui_weapon ][ 1 ] ]]();


		// thread our update functions
		self thread viewmodel_magazine_ammo_update();
		self thread viewmodel_reserve_ammo_update();
		self thread viewmodel_range_update();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

viewmodel_ui_setup()
{
	// dvar used to help see where you elements are currently placed. Usefull when working on UV mapping
	//SetSavedDvar( "r_drawUiTextureOverlay", "1" );


	// make sure everything is setup properly
	if ( !IsDefined( level._viewmodel_ui_weapon ) )
	{
		level._viewmodel_ui_weapon = "";
	}


	// tagMJS<TODO> we should move all our assets into the GDT entry
	// so we don't make our common.csv file larger than it needs to be
	// make sure all our assets are loaded
	viewmodel_precache_assets();


	// add to our level array all our needed functions
	viewmodel_add_create_and_destroy_functions();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

viewmodel_precache_assets()
{
	// need this icon precached for viewmodel ui
	PreCacheShader( "ammo_counter_med" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

viewmodel_add_create_and_destroy_functions()
{
	level._viewmodel_ui[ "lunarrifle" ][ 0 ] = ::cleanup_lunarrifle_ui_elements;
	level._viewmodel_ui[ "lunarrifle" ][ 1 ] = ::setup_lunarrifle_ui_elements;
	level._viewmodel_ui[ "glo_reflex_mp" ][ 0 ] = ::delete_glo_ui_elements;
	level._viewmodel_ui[ "glo_reflex_mp" ][ 1 ] = ::create_glo_ui_elements;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

viewmodel_magazine_ammo_update()
{
	self endon( "viewmodel_ui_update" );

	magazine_size = level._player GetMagazineMaxAmmoCount( level._viewmodel_ui_weapon );
	while( 1 )
	{
		remaining = level._player GetMagazineAmmoCount( level._viewmodel_ui_weapon );

		if ( IsDefined( level.magazine_counter ) )
		{
			// update lens count
			//level.ammo_counter SetText( " " + level._player getmagazineammocount( level._viewmodel_ui_weapon ) + "/" + level._player getmagazinemaxammocount( level._viewmodel_ui_weapon ) );
			level.magazine_counter SetText( remaining );
		}

		if ( IsDefined( level.magazine_pips ) )
		{
			// update frame pips
			for( index = 0; index < magazine_size; index++ )
			{
				if ( index < remaining )
				{
					level.magazine_pips[index].color = ( 1.0, 1.0, 1.0 );
				}
				else
				{
					level.magazine_pips[index].color = ( 0.35, 0.35, 0.35 );
				}
			}
		}
		wait( 0.05 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

viewmodel_reserve_ammo_update()
{
	self endon( "viewmodel_ui_update" );

	if( IsDefined( level.reserve_counter ) )
	{
		while( 1 )
		{
			level.reserve_counter SetText( level._player GetAmmoCount( level._viewmodel_ui_weapon ) - level._player GetMagazineAmmoCount( level._viewmodel_ui_weapon ) );
			wait( 0.05 );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

viewmodel_range_update()
{
	self endon( "viewmodel_ui_update" );

	if( IsDefined( level.range_display ) )
	{
		while( 1 )
		{
			eye = self geteye();
			angles = self getplayerangles();

			forward = anglestoforward( angles );
			end = eye + vector_multiply( forward, 7000 );
			trace = bullettrace( eye, end, true, self );
			level.range_display SetText( int( distance( level._player.origin, trace["position"] ) * ( 100 / 39.37 ) ) / 100 );

			wait( 0.33 );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//			Create and Destroy Functions below here
//			Please
//			-MJS

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

setup_lunarrifle_ui_elements()
{
	level.reserve_counter = newClientHudElem( level._player );
	level.reserve_counter.elemType = "font";
	level.reserve_counter.font = "hudbig";
	level.reserve_counter.sort = 50;
	level.reserve_counter.pre3d = true;
	level.reserve_counter.horzAlign = "fullscreen";
	level.reserve_counter.vertAlign = "fullscreen";
	level.reserve_counter.alpha = 1;
	level.reserve_counter.alignX = "center";
	level.reserve_counter.alignY = "top";
	level.reserve_counter.fontScale = 38;
	level.reserve_counter.x = 3900;
	level.reserve_counter.y = 768;
	level.reserve_counter.color = ( 1.0, 1.0, 1.0 );

	level.magazine_counter = newClientHudElem( level._player );
	level.magazine_counter.elemType = "font";
	level.magazine_counter.font = "hudbig";
	level.magazine_counter.sort = 50;
	level.magazine_counter.pre3d = true;
	level.magazine_counter.horzAlign = "fullscreen";
	level.magazine_counter.vertAlign = "fullscreen";
	level.magazine_counter.alpha = 1;
	level.magazine_counter.alignX = "center";
	level.magazine_counter.alignY = "top";
	level.magazine_counter.fontScale = 64;
	level.magazine_counter.x = 1385;
	level.magazine_counter.y = -192;
	level.magazine_counter.color = ( 1.0, 0.35, 0.35 );

	magazine_size = level._player GetMagazineMaxAmmoCount( level._viewmodel_ui_weapon );
	level.magazine_pips = [];
	spacing = 320;
	for( index = 0; index < magazine_size; index++ )
	{
		level.magazine_pips[index] = createIcon( "ammo_counter_med", 512, 2048 );
		level.magazine_pips[index].x = ( 6050 - ( spacing * index ) );
		level.magazine_pips[index].y = 1536;
		level.magazine_pips[index].pre3d = true;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

cleanup_lunarrifle_ui_elements()
{
	if ( IsDefined( level.reserve_counter ) )
	{
		level.reserve_counter Destroy();
		level.reserve_counter = undefined;
	}
	if ( IsDefined( level.magazine_counter ) )
	{
		level.magazine_counter Destroy();
		level.magazine_counter = undefined;
	}
	if ( IsDefined( level.magazine_pips ) )
	{
		magazine_size = level.magazine_pips.size;
		for( index = 0; index < magazine_size; index++ )
		{
			level.magazine_pips[index] Destroy();
		}
		level.magazine_pips = undefined;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

delete_glo_ui_elements()
{
	if ( IsDefined( level.magazine_counter ) )
	{
		level.magazine_counter Destroy();
		level.magazine_counter = undefined;
	}
	if ( IsDefined( level.range_display ) )
	{
		level.range_display Destroy();
		level.range_display = undefined;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

create_glo_ui_elements()
{
	level.magazine_counter = newClientHudElem( level._player );
	level.magazine_counter.elemType = "font";
	level.magazine_counter.font = "hudbig";
	level.magazine_counter.sort = 50;
	level.magazine_counter.pre3d = true;
	level.magazine_counter.horzAlign = "fullscreen";
	level.magazine_counter.vertAlign = "fullscreen";
	level.magazine_counter.alpha = 1;
	level.magazine_counter.alignX = "center";
	level.magazine_counter.alignY = "top";
	level.magazine_counter.fontScale = 80;
	level.magazine_counter.x = 3000;
	level.magazine_counter.y = 400;
	level.magazine_counter.color = ( 0.0, 0.941176471, 1.0 );

	level.range_display = newClientHudElem( level._player );
	level.range_display.elemType = "font";
	level.range_display.font = "hudbig";
	level.range_display.sort = 50;
	level.range_display.pre3d = true;
	level.range_display.horzAlign = "fullscreen";
	level.range_display.vertAlign = "fullscreen";
	level.range_display.alpha = 1;
	level.range_display.alignX = "center";
	level.range_display.alignY = "top";
	level.range_display.fontScale = 32;
	level.range_display.x = 2500;
	level.range_display.y = -64;
	level.range_display.color = ( 0.0, 0.941176471, 1.0 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************