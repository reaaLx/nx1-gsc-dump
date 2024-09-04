#include common_scripts\utility;
#include common_scripts\_fx;
#include common_scripts\_createfxMenu;

createEffect( type, fxid )
{
	ent = spawnStruct();
	if ( !isdefined( level._createFXent ) )
		level._createFXent = [];

	level._createFXent[ level._createFXent.size ] = ent;
	ent.v = [];
	ent.v[ "type" ] = type;
	ent.v[ "fxid" ] = fxid;
	ent.v[ "angles" ] = ( 0, 0, 0 );
	ent.v[ "origin" ] = ( 0, 0, 0 );
	ent.drawn = true;
	return ent;
}

add_effect( name, effect )
{
	if ( !isdefined( level._effect ) )
		level._effect = [];

	level._effect[ name ] = loadfx( effect );
}

createLoopSound()
{
	ent = spawnStruct();
	if ( !isdefined( level._createFXent ) )
		level._createFXent = [];

	level._createFXent[ level._createFXent.size ] = ent;
	ent.v = [];
	ent.v[ "type" ] = "soundfx";
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "soundalias" ] = "nil";
	ent.v[ "angles" ] = ( 0, 0, 0 );
	ent.v[ "origin" ] = ( 0, 0, 0 );
	ent.drawn = true;
	return ent;
}

createNewExploder()
{
	ent = spawnStruct();
	if ( !isdefined( level._createFXent ) )
		level._createFXent = [];

	level._createFXent[ level._createFXent.size ] = ent;

	ent.v = [];
	ent.v[ "type" ] = "exploder";
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "soundalias" ] = "nil";
	ent.v[ "loopsound" ] = "nil";
	ent.v[ "angles" ] = ( 0, 0, 0 );
	ent.v[ "origin" ] = ( 0, 0, 0 );
	ent.v[ "flag" ] = "nil";
	ent.v[ "exploder" ] = 1;
	ent.v[ "exploder_type" ] = "normal";
	ent.drawn = true;

	return ent;
}

createOneShotEntity()
{
	ent = spawnStruct();
	if ( !isdefined( level._createFXent ) )
		level._createFXent = [];

	level._createFXent[ level._createFXent.size ] = ent;

	ent.v = [];
	ent.v[ "type" ] = "oneshotfx";
	ent.v[ "fxid" ] = "No FX";
	ent.v[ "soundalias" ] = "nil";
	ent.v[ "loopsound" ] = "nil";
	ent.v[ "angles" ] = ( 0, 0, 0 );
	ent.v[ "origin" ] = ( 0, 0, 0 );
	ent.v[ "flag" ] = "nil";
	ent.drawn = true;

	return ent;
}

set_forward_and_up_vectors()
{
	self.v[ "up" ] = anglestoup( self.v[ "angles" ] );
	self.v[ "forward" ] = anglestoforward( self.v[ "angles" ] );
}

createfx_common()
{
	precacheShader( "black" );

	if( level._mp_createfx )
	{
		hack_start( "painter_mp" );
	}
	else
	{
		hack_start( "painter" );
	}

	flag_init( "createfx_saving" );

	// Effects placing tool
	if ( !isdefined( level._createFX ) )
	{
		level._createFX = [];
	}

	level._createfx_loopcounter = 0;
	
	triggers = getentarray( "trigger_multiple", "classname" );
	for ( i = 0;i < triggers.size;i++ )
	{
		triggers[ i ] delete();
	}

	triggers = getentarray( "trigger_radius", "classname" );
	for ( i = 0;i < triggers.size;i++ )
	{
		triggers[ i ] delete();
	}	
}

createFxLogic()
{
	waittillframeend;// let _load run first

	menu_init();

	if ( !isdefined( level._effect ) )
		level._effect = [];

	if ( GetDvar( "createfx_map" ) == "" )
		SetDevDvar( "createfx_map", level._script );
	else if ( GetDvar( "createfx_map" ) == level._script )
		[[ level._func_position_player ]]();

	// restore player position & orientation
	level._player restore_for_createfx();

	level._createFxHudElements = [];
	level._createFx_hudElements = 30;
	// all this offset stuff lets us duplicate the text which puts an outline around
	// it and makes it more legible
	strOffsetX = [];
	strOffsetY = [];
	strOffsetX[ 0 ] = 0;
	strOffsetY[ 0 ] = 0;
	strOffsetX[ 1 ] = 1;
	strOffsetY[ 1 ] = 1;
	strOffsetX[ 2 ] = -2;
	strOffsetY[ 2 ] = 1;
	strOffsetX[ 3 ] = 1;
	strOffsetY[ 3 ] = -1;
	strOffsetX[ 4 ] = -2;
	strOffsetY[ 4 ] = -1;

	SetDevDvar( "fx", "nil" );

	// setup "crosshair"
	crossHair = newHudElem();
	crossHair.location = 0;
	crossHair.alignX = "center";
	crossHair.alignY = "middle";
	crossHair.foreground = 1;
	crossHair.fontScale = 2;
	crossHair.sort = 20;
	crossHair.alpha = 1;
	crossHair.x = 320;
	crossHair.y = 233;
	crossHair setText( "." );

	// setup the free text marker to allow some permanent strings
	level._clearTextMarker = newHudElem();
	level._clearTextMarker.alpha = 0;
	level._clearTextMarker setText( "marker" );

	for ( i = 0; i < level._createFx_hudElements; i++ )
	{
		newStrArray = [];

		for ( p = 0; p < 1; p++ )
		{
			newStr = newHudElem();
			newStr.alignX = "left";
			newStr.location = 0;
			newStr.foreground = 1;
			newStr.fontScale = 1.40;
			newStr.alpha = 1;
			newStr.archived = 0;
			newStr.x = 0 + strOffsetX[ p ];
			newStr.y = 60 + strOffsetY[ p ] + i * 15;
			newStr.sort = newStr.y;
			//newStr.sort = 20 - p;

			if ( p > 0 )
			{
				newStr.color = ( 0, 0, 0 );
			}

			newStrArray[ newStrArray.size ] = newStr;
		}

		level._createFxHudElements[ i ] = newStrArray;
	}

	newStrArray = [];

	for ( p = 0; p < 5; p++ )
	{
		// setup instructional text
		newStr = newHudElem();
		newStr.alignX = "center";
		newStr.location = 0;
		newStr.foreground = 1;
		newStr.fontScale = 1.40;
		newStr.alpha = 1;
		newStr.x = 320 + strOffsetX[ p ];
		newStr.y = 80 + strOffsetY[ p ];
		newStr.sort = newStr.y;
		newStr.archived = 0;
		// newStr.sort = 20 - p;
		
		if ( p > 0 )
		{
			newStr.color = ( 0, 0, 0 );
		}

		newStrArray[ newStrArray.size ] = newStr;
	}

	level._createFX_centerPrint = newStrArray;

	// gets cumulatively added to to create digital accelleration
	level._selectedMove_up = 0;
	level._selectedMove_forward = 0;
	level._selectedMove_right = 0;
	level._selectedRotate_pitch = 0;
	level._selectedRotate_roll = 0;
	level._selectedRotate_yaw = 0;
	level._selected_fx = [];
	level._selected_fx_ents = [];

	level._createfx_lockedList = [];
	level._createfx_lockedList[ "escape" ] = true;
	level._createfx_lockedList[ "BUTTON_LSHLDR" ] = true;
	level._createfx_lockedList[ "BUTTON_RSHLDR" ] = true;
	level._createfx_lockedList[ "mouse1" ] = true;
	level._createfx_lockedList[ "ctrl" ] = true;

	level._createfx_draw_enabled = true;
	level._last_displayed_ent = undefined;

	level._buttonIsHeld = [];
	axisMode = false;
	lastPlayerOrigin = (0,0,0);

	if( !level._mp_createfx )
	{
		lastPlayerOrigin = level._player.origin;
	}

	colors = [];
	colors[ "loopfx" ][ "selected" ] 		 = ( 1.0, 1.0, 0.2 );
	colors[ "loopfx" ][ "highlighted" ] 	 = ( 0.4, 0.95, 1.0 );
	colors[ "loopfx" ][ "default" ]		 	 = ( 0.3, 0.8, 1.0 );

	colors[ "oneshotfx" ][ "selected" ] 	 = ( 1.0, 1.0, 0.2 );
	colors[ "oneshotfx" ][ "highlighted" ] 	 = ( 0.4, 0.95, 1.0 );
	colors[ "oneshotfx" ][ "default" ]		 = ( 0.3, 0.8, 1.0 );

	colors[ "exploder" ][ "selected" ] 		 = ( 1.0, 1.0, 0.2 );
	colors[ "exploder" ][ "highlighted" ] 	 = ( 1.0, 0.2, 0.2 );
	colors[ "exploder" ][ "default" ]		 = ( 1.0, 0.1, 0.1 );

	colors[ "rainfx" ][ "selected" ] 		 = ( 1.0, 1.0, 0.2 );
	colors[ "rainfx" ][ "highlighted" ] 	 = ( .95, 0.4, 0.95 );
	colors[ "rainfx" ][ "default" ]			 = ( .78, 0.0, 0.73 );

	colors[ "soundfx" ][ "selected" ]	 	 = ( 1.0, 1.0, 0.2 );
	colors[ "soundfx" ][ "highlighted" ] 	 = ( .5, 1.0, 0.75 );
	colors[ "soundfx" ][ "default" ]		 = ( .2, 0.9, 0.2 );

	lastHighlightedEnt = undefined;
	level._fx_rotating = false;
	setMenu( "none" );
	level._createfx_selecting = false;

	// black background for text
	black = newHudElem();
	black.x = -120;
	black.y = 200;
	//	black[i].alignX = "center";
	//	black[i].alignY = "middle";
	black.foreground = 0;
	black setShader( "black", 250, 160 );
	black.alpha = 0;// 0.6;

	level._createfx_inputlocked = false;

	for ( i = 0; i < level._createFXent.size; i++ )
	{
		ent = level._createFXent[ i ];
		ent post_entity_creation_function();
	}

	thread draw_distance();
	lastSelectEntity = undefined;
	thread createfx_autosave();

	for ( ;; )
	{
		wait( 0.02 );
		
		changedSelectedEnts = false;

		// calculate the "cursor"
		right = anglestoright( level._player getplayerangles() );
		forward = anglestoforward( level._player getplayerangles() );
		up = anglestoup( level._player getplayerangles() );
		dot = 0.85;

		placeEnt_vector = vector_multiply( forward, 750 );
		level._createfxCursor = bullettrace( level._player geteye(), level._player geteye() + placeEnt_vector, false, undefined );
		highlightedEnt = undefined;

		// ************************************************************
		//
		// 				General input
		//
		// ************************************************************

		level._buttonClick = [];
		level._button_is_kb = [];
		process_button_held_and_clicked();
		ctrlHeld = button_is_held( "ctrl", "BUTTON_LSHLDR" );
		leftClick = button_is_clicked( "mouse1", "BUTTON_A" );
		leftHeld = button_is_held( "mouse1", "BUTTON_A" );

		create_fx_menu();

		if ( button_is_clicked( "shift", "BUTTON_X" ) )
			axisMode = !axisMode;

		//changing to allow devgui item
		if ( button_is_clicked( "F5" ) )
			SetDevDvar( "scr_createfx_dump", 1 );
			
		if( GetDvarInt( "scr_createfx_dump" ) )
		{
			SetDevDvar( "scr_createfx_dump", 0 );
			generate_fx_log();
		}
		
		if ( button_is_clicked( "F2" ) )
			toggle_createfx_drawing();

		if ( button_is_clicked( "ins" ) )
			insert_effect();

		if ( button_is_clicked( "del" ) )
			delete_pressed();

		if ( button_is_clicked( "end", "l" ) )
		{
			drop_selection_to_ground();
			changedSelectedEnts = true;
		}

		if ( button_is_clicked( "escape" ) )
			clear_settable_fx();

		if ( button_is_clicked( "space" ) )
			set_off_exploders();

		if ( button_is_clicked( "g" ) )
		{
			select_all_exploders_of_currently_selected( "exploder" );
			select_all_exploders_of_currently_selected( "flag" );
		}

		if ( button_is_clicked( "tab", "BUTTON_RSHLDR" ) )
		{
			move_selection_to_cursor();
			changedSelectedEnts = true;
		}

		if ( button_is_held( "h", "F1" ) )
		{
			show_help();
			//wait( 0.05 );
			continue;
		}

		if ( button_is_clicked( "BUTTON_LSTICK" ) )
			copy_ents();
		if ( button_is_clicked( "BUTTON_RSTICK" ) )
			paste_ents();

		if ( ctrlHeld )
		{
			if ( button_is_clicked( "c" ) )
				copy_ents();

			if ( button_is_clicked( "v" ) )
				paste_ents();
		}

		if ( isdefined( level._selected_fx_option_index ) )
			menu_fx_option_set();

		// ************************************************************
		//
		// 				Highlighted Entity Handling
		//
		// ************************************************************
		for ( i = 0; i < level._createFXent.size; i++ )
		{
			ent = level._createFXent[ i ];

			difference = vectornormalize( ent.v[ "origin" ] - ( level._player.origin + ( 0, 0, 55 ) ) );
			newdot = vectordot( forward, difference );
			if ( newdot < dot )
				continue;

			dot = newdot;
			highlightedEnt = ent;
		}
		level._fx_highLightedEnt = highLightedEnt;

		if ( isdefined( highLightedEnt ) )
		{
			if ( isdefined( lastHighlightedEnt ) )
			{
				if ( lastHighlightedEnt != highlightedEnt )
				{
					// a highlighted ent is no longer highlighted so scale down the text size
//					lastHighlightedEnt.text = ".";
//					lastHighlightedEnt.textsize = 2;
					if ( !ent_is_selected( lastHighlightedEnt ) )
						lastHighlightedEnt thread entity_highlight_disable();

					// an ent became highlighted for the first time so scale up the text size on the new ent
//					highlightedEnt.text = HighlightedEnt.v["fxid"];
//					highlightedEnt.textsize = 1;
					if ( !ent_is_selected( highlightedEnt ) )
						highlightedEnt thread entity_highlight_enable();
				}
			}
			else
			{
				// an ent became highlighted for the first time so scale up the text size on the new ent
//				HighlightedEnt.text = HighlightedEnt.v["fxid"];
//				HighlightedEnt.textsize = 1;
				if ( !ent_is_selected( highlightedEnt ) )
					highlightedEnt thread entity_highlight_enable();
			}
		}

		manipulate_createfx_ents( highlightedEnt, leftClick, leftHeld, ctrlHeld, colors, right );

		// ************************************************************
		//
		// 				Rotation and Movement
		//
		// ************************************************************

		if ( axisMode && level._selected_fx_ents.size > 0 )
		{
			// draw axis and do rotation if shift is held
			thread [[ level._func_process_fx_rotater ]]();
			if ( button_is_clicked( "enter", "p" ) )
				reset_axis_of_selected_ents();

			if ( button_is_clicked( "v" ) )
				copy_angles_of_selected_ents();

			for ( i = 0; i < level._selected_fx_ents.size; i++ )
				level._selected_fx_ents[ i ] draw_axis();

			if ( level._selectedRotate_pitch != 0 || level._selectedRotate_yaw != 0  || level._selectedRotate_roll != 0 )
				changedSelectedEnts = true;
			//wait( 0.05 );
/*
			for ( i=0; i < level.selected_fx_ents.size; i++)
			{
				ent = level.selected_fx_ents[i];
				ent.angles = ent.angles + (level.selectedRotate_pitch, level.selectedRotate_yaw, 0);
				ent set_forward_and_up_vectors();
			}
			
			if (level.selectedRotate_pitch != 0 || level.selectedRotate_yaw != 0)
				changedSelectedEnts = true;
*/
		}
		else
		{
			selectedMove_vector = get_selected_move_vector();
			for ( i = 0; i < level._selected_fx_ents.size; i++ )
			{
				ent = level._selected_fx_ents[ i ];
				if ( isdefined( ent.model ) )// ents with brushmodels are from radiant and dont get moved
					continue;

				ent.v[ "origin" ] = ent.v[ "origin" ] + selectedMove_vector;
			}

			if ( distance( ( 0, 0, 0 ), selectedMove_vector ) > 0 )
				changedSelectedEnts = true;
			
			//wait( 0.05 );
		}

		if ( changedSelectedEnts )
			update_selected_entities();

		if( !level._mp_createfx )
			lastPlayerOrigin = [[ level._func_position_player_get ]]( lastPlayerOrigin );

		lastHighlightedEnt = highlightedEnt;

		// if the last selected entity changes then reset the options offset
		if ( last_selected_entity_has_changed( lastSelectEntity ) )
		{
			level._effect_list_offset = 0;
			clear_settable_fx();
			setmenu( "none" );
		}

		if ( level._selected_fx_ents.size )
			lastSelectEntity = level._selected_fx_ents[ level._selected_fx_ents.size - 1 ];
		else
			lastSelectEntity = undefined;
	}
}

copy_angles_of_selected_ents()
{
	// so it stops rotating them over time
	level notify( "new_ent_selection" );

	for ( i = 0; i < level._selected_fx_ents.size; i++ )
	{
		ent = level._selected_fx_ents[ i ];
		ent.v[ "angles" ] = level._selected_fx_ents[ level._selected_fx_ents.size - 1 ].v[ "angles" ];
		ent set_forward_and_up_vectors();
	}

	update_selected_entities();
}

reset_axis_of_selected_ents()
{
	// so it stops rotating them over time
	level notify( "new_ent_selection" );

	for ( i = 0; i < level._selected_fx_ents.size; i++ )
	{
		ent = level._selected_fx_ents[ i ];
		ent.v[ "angles" ] = ( 0, 0, 0 );
		ent set_forward_and_up_vectors();
	}

	update_selected_entities();
}

last_selected_entity_has_changed( lastSelectEntity )
{
	if ( isdefined( lastSelectEntity ) )
	{
		if ( !entities_are_selected() )
			return true;
	}
	else
		return entities_are_selected();

	return( lastSelectEntity != level._selected_fx_ents[ level._selected_fx_ents.size - 1 ] );
}

createfx_showOrigin( id, org, delay, org2, type, exploder, id2, fireFx, fireFxDelay, fireFxSound, fxSound, fxQuake, fxDamage, soundalias, repeat, delay_min, delay_max, damage_radius, fireFxTimeout )
{
}

drop_selection_to_ground()
{
	for ( i = 0; i < level._selected_fx_ents.size; i++ )
	{
		ent = level._selected_fx_ents[ i ];
		trace = bullettrace( ent.v[ "origin" ], ent.v[ "origin" ] + ( 0, 0, -2048 ), false, undefined );
		ent.v[ "origin" ] = trace[ "position" ];
	}
}

set_off_exploders()
{
	level notify( "createfx_exploder_reset" );
	exploders = [];
	for ( i = 0; i < level._selected_fx_ents.size; i++ )
	{
		ent = level._selected_fx_ents[ i ];
		if ( isdefined( ent.v[ "exploder" ] ) )
			exploders[ ent.v[ "exploder" ] ] = true;
	}

	keys = getarraykeys( exploders );
	for ( i = 0; i < keys.size; i++ )
		exploder( keys[ i ] );
}

draw_distance()
{
	count = 0;
	if ( GetDvarInt( "createfx_drawdist" ) == 0 )
		SetDevDvar( "createfx_drawdist", "1500" );

	for ( ;; )
	{
		maxDist = GetDvarInt( "createfx_drawdist" );
		for ( i = 0; i < level._createFXent.size; i++ )
		{
			ent = level._createFXent[ i ];
			ent.drawn = distance( level._player.origin, ent.v[ "origin" ] ) <= maxDist;

			count++ ;
			if ( count > 100 )
			{
				count = 0;
				wait( 0.05 );
			}
		}
		if ( level._createFXent.size == 0 )
			wait( 0.05 );
	}
}

createfx_autosave()
{
	for ( ;; )
	{
		wait( 300 );
		flag_waitopen( "createfx_saving" );
		generate_fx_log( true );
	}
}

rotate_over_time( org, rotater )
{
	level endon( "new_ent_selection" );
	timer = 0.1;
	for ( p = 0;p < timer * 20;p++ )
	{
		if ( level._selectedRotate_pitch != 0 )
			org AddPitch( level._selectedRotate_pitch );
		else
		if ( level._selectedRotate_yaw != 0 )
			org AddYaw( level._selectedRotate_yaw );
		else
			org AddRoll( level._selectedRotate_roll );

		wait( 0.05 );
		org draw_axis();

		for ( i = 0; i < level._selected_fx_ents.size; i++ )
		{
			ent = level._selected_fx_ents[ i ];
			if ( isdefined( ent.model ) )// ents with brushmodels are from radiant and dont get moved
				continue;

			ent.v[ "origin" ] = rotater[ i ].origin;
			ent.v[ "angles" ] = rotater[ i ].angles;
		}
	}
}

delete_pressed()
{
	if ( level._createfx_inputlocked )
	{
		remove_selected_option();
		return;
	}

	delete_selection();
}

remove_selected_option()
{
	if ( !isdefined( level._selected_fx_option_index ) )
	{
		return;
	}

	name = level._createFX_options[ level._selected_fx_option_index ][ "name" ];
	for ( i = 0; i < level._createFXent.size; i++ )
	{
		ent = level._createFXent[ i ];
		if ( !ent_is_selected( ent ) )
			continue;

		ent remove_option( name );
	}

	update_selected_entities();
	clear_settable_fx();
}

remove_option( name )
{
	self.v[ name ] = undefined;
}

delete_selection()
{
	newArray = [];

	for ( i = 0; i < level._createFXent.size; i++ )
	{
		ent = level._createFXent[ i ];
		if ( ent_is_selected( ent ) )
		{
			if ( isdefined( ent.looper ) )
				ent.looper delete();

			ent notify( "stop_loop" );
		}
		else
			newArray[ newArray.size ] = ent;
	}

	level._createFXent = newArray;

	level._selected_fx = [];
	level._selected_fx_ents = [];
	clear_fx_hudElements();
}

move_selection_to_cursor()
{
	origin = level._createfxCursor[ "position" ];
	if ( level._selected_fx_ents.size <= 0 )
		return;

	center = get_center_of_array( level._selected_fx_ents );
	difference = center - origin;
	for ( i = 0; i < level._selected_fx_ents.size; i++ )
	{
		ent = level._selected_fx_ents[ i ];
		if ( isdefined( ent.model ) )// ents with brushmodels are from radiant and dont get moved
			continue;

		ent.v[ "origin" ] -= difference;
	}
}

insert_effect()
{
	setMenu( "creation" );
	level._effect_list_offset = 0;
	clear_fx_hudElements();
	
	set_fx_hudElement( "Pick effect type to create:" );
	set_fx_hudElement( "1. Ambient/OneShot fx" );
	set_fx_hudElement( "2. Scripted/Exploder fx" );
	set_fx_hudElement( "3. Looping sound" );
	set_fx_hudElement( "(c) Cancel" );
	set_fx_hudElement( "(x) Exit" );
	
	/*
	set_fx_hudElement( "2. Looping fx" ); // no more
	set_fx_hudElement("Pick an effect:");
	set_fx_hudElement("In the console, type");
	set_fx_hudElement("/fx name");
	set_fx_hudElement("Where name is the name of the sound alias");
	*/
}

show_help()
{
	clear_fx_hudElements();
	set_fx_hudElement( "Help:" );
	set_fx_hudElement( "Insert          Insert entity" );
	set_fx_hudElement( "L               Drop selected entities to the ground" );
	set_fx_hudElement( "A               Add option to the selected entities" );
	set_fx_hudElement( "P               Reset the rotation of the selected entities" );
	set_fx_hudElement( "V               Copy the angles from the most recently selected fx onto all selected fx." );
	set_fx_hudElement( "Delete          Kill the selected entities" );
	set_fx_hudElement( "ESCAPE          Cancel out of option-modify-mode, must have console open" );
	set_fx_hudElement( "Ctrl-C          Copy" );
	set_fx_hudElement( "Ctrl-V          Paste" );
	set_fx_hudElement( "F2              Toggle createfx dot and text drawing" );
	set_fx_hudElement( "F5              SAVES your work" );
	set_fx_hudElement( "Dpad            Move selected entitise on X/Y or rotate pitch/yaw" );
	set_fx_hudElement( "A button        Toggle the selection of the current entity" );
	set_fx_hudElement( "X button        Toggle entity rotation mode" );
	set_fx_hudElement( "Y button        Move selected entites up or rotate roll" );
	set_fx_hudElement( "B button        Move selected entites down or rotate roll" );
	set_fx_hudElement( "R Shoulder      Move selected entities to the cursor" );
	set_fx_hudElement( "L Shoulder      Hold to select multiple entites" );
	set_fx_hudElement( "L JoyClick      Copy" );
	set_fx_hudElement( "R JoyClick      Paste" );
	set_fx_hudElement( "N               UFO" );
	set_fx_hudElement( "T               Toggle Timescale FAST" );
	set_fx_hudElement( "Y               Toggle Timescale SLOW" );
	set_fx_hudElement( "[               Toggle FX Visibility" );
	set_fx_hudElement( "]               Toggle ShowTris" );
	set_fx_hudElement( "F11             Toggle FX Profile" );
}


select_last_entity()
{
	select_entity( level._createFXent.size - 1, level._createFXent[ level._createFXent.size - 1 ] );
}

select_all_exploders_of_currently_selected( key )
{
	selected_exploders = [];
	foreach ( ent in level._selected_fx_ents )
	{
		if ( !isdefined( ent.v[ key ] ) )
			continue;
		
		value = ent.v[ key ];
		selected_exploders[ value ] = true;
	}
	
	foreach ( value, _ in selected_exploders )
	{
		foreach ( index, ent in level._createFXent )
		{
			if ( index_is_selected( index ) )
				continue;
			if ( !isdefined( ent.v[ key ] ) )
				continue;
			if ( ent.v[ key ] != value )
				continue;			

			select_entity( index, ent );
		}
	}
	
	update_selected_entities();
}

copy_ents()
{
	if ( level._selected_fx_ents.size <= 0 )
		return;

	array = [];
	for ( i = 0; i < level._selected_fx_ents.size; i++ )
	{
		ent = level._selected_fx_ents[ i ];
		newent = spawnstruct();

		newent.v = ent.v;
		newent post_entity_creation_function();
		array[ array.size ] = newent;
	}

	level._stored_ents = array;
}

post_entity_creation_function()
{
	self.textAlpha = 0;
	self.drawn = true;
}

paste_ents()
{
	if ( !isdefined( level._stored_ents ) )
		return;

	clear_entity_selection();

	for ( i = 0;i < level._stored_ents.size;i++ )
		add_and_select_entity( level._stored_ents[ i ] );

	move_selection_to_cursor();
	update_selected_entities();
	level._stored_ents = [];
	copy_ents();// roundabout way to put new entities in the copy queue
}

add_and_select_entity( ent )
{
	level._createFXent[ level._createFXent.size ] = ent;
	select_last_entity();
}

get_center_of_array( array )
{
	center = ( 0, 0, 0 );
	for ( i = 0; i < array.size; i++ )
		center = ( center[ 0 ] + array[ i ].v[ "origin" ][ 0 ], center[ 1 ] + array[ i ].v[ "origin" ][ 1 ], center[ 2 ] + array[ i ].v[ "origin" ][ 2 ] );

	return( center[ 0 ] / array.size, center[ 1 ] / array.size, center[ 2 ] / array.size );
}

ent_draw_axis()
{
	self endon( "death" );
	for ( ;; )
	{
		draw_axis();
		wait( 0.05 );
	}
}

rotation_is_occuring()
{
	if ( level._selectedRotate_roll != 0 )
		return true;
	if ( level._selectedRotate_pitch != 0 )
		return true;
	return level._selectedRotate_yaw != 0;
}

print_fx_options( ent, tab, file, autosave )
{
	for ( i = 0; i < level._createFX_options.size; i++ )
	{
		option = level._createFX_options[ i ];
		if ( !isdefined( ent.v[ option[ "name" ] ] ) )
			continue;
		if ( !mask( option[ "mask" ], ent.v[ "type" ] ) )
			continue;

		if ( option[ "type" ] == "string" )
		{
//			if ( !autosave )
//				println( "	ent.v[ \"" + option[ "name" ] + "\" ] = \"" + ent.v[ option[ "name" ] ] + "\";" );
			cfxprintln( file, tab + "ent.v[ \"" + option[ "name" ] + "\" ] = \"" + ent.v[ option[ "name" ] ] + "\";" );
			continue;
		}

		// int or float
//		if ( !autosave )
//			println( "	ent.v[ \"" + option[ "name" ] + "\" ] = " + ent.v[ option[ "name" ] ] + ";" );
		cfxprintln( file, tab + "ent.v[ \"" + option[ "name" ] + "\" ] = " + ent.v[ option[ "name" ] ] + ";" );
	}
}

entity_highlight_disable()
{
	self notify( "highlight change" );
	self endon( "highlight change" );

	for ( ;; )
	{
		self.textalpha = self.textalpha * 0.85;
		self.textalpha = self.textalpha - 0.05;
		if ( self.textalpha < 0 )
			break;
		wait( 0.05 );
	}

	self.textalpha = 0;
}

entity_highlight_enable()
{
	self notify( "highlight change" );
	self endon( "highlight change" );

	for ( ;; )
	{
//		self.textalpha = sin(gettime()) * 0.5 + 0.5;
		self.textalpha = self.textalpha + 0.05;
		self.textalpha = self.textalpha * 1.25;
		if ( self.textalpha > 1 )
			break;
		wait( 0.05 );
	}

	self.textalpha = 1;

}


toggle_createfx_drawing()
{
	level._createfx_draw_enabled = !level._createfx_draw_enabled;
}

manipulate_createfx_ents( highlightedEnt, leftClick, leftHeld, ctrlHeld, colors, right )
{
	if ( !level._createfx_draw_enabled )
		return;

	for ( i = 0; i < level._createFXent.size; i++ )
	{
		ent = level._createFXent[ i ];
		if ( !ent.drawn )
			continue;

		scale = GetDvarFloat( "createfx_scaleid" );

		if ( isdefined( highlightedEnt ) && ent == highlightedEnt )
		{
			if ( !entities_are_selected() )
				display_fx_info( ent );

			if ( leftClick )
			{
				entWasSelected = index_is_selected( i );
				level._createfx_selecting = !entWasSelected;// used for drag select / deselect
				if ( !ctrlHeld )
				{
					selectedSize = level._selected_fx_ents.size;
					clear_entity_selection();
					if ( entWasSelected && selectedSize == 1 )
						select_entity( i, ent );
				}
				toggle_entity_selection( i, ent );
			}
			else
			if ( leftHeld )
			{
				if ( ctrlHeld )
				{
					if ( level._createfx_selecting )
						select_entity( i, ent );

					if ( !level._createfx_selecting )
						deselect_entity( i, ent );
				}
			}


			colorIndex = "highlighted";
			if ( index_is_selected( i ) )
				colorIndex = "selected";


			print3d( ent.v[ "origin" ], ".", colors[ ent.v[ "type" ] ][ colorIndex ], 1, scale );
			if ( ent.textalpha > 0 )
			{
				printRight = vector_multiply( right, ent.v[ "fxid" ].size * - 2.93 * scale );
				print3d( ent.v[ "origin" ] + printRight + ( 0, 0, 15 ), ent.v[ "fxid" ], colors[ ent.v[ "type" ] ][ colorIndex ], ent.textalpha, scale );
			}
		}
		else
		{
			colorIndex = "default";
			if ( index_is_selected( i ) )
				colorIndex = "selected";

			print3d( ent.v[ "origin" ], ".", colors[ ent.v[ "type" ] ][ colorIndex ], 1, scale );
			if ( ent.textalpha > 0 )
			{
				printRight = vector_multiply( right, ent.v[ "fxid" ].size * - 2.93 );
				print3d( ent.v[ "origin" ] + printRight + ( 0, 0, 15 ), ent.v[ "fxid" ], colors[ ent.v[ "type" ] ][ colorIndex ], ent.textalpha, scale );
			}
		}
	}
}

clear_settable_fx()
{
	level._createfx_inputlocked = false;
	SetDevDvar( "fx", "nil" );
	// in case we were modifying an option
	level._selected_fx_option_index = undefined;
	reset_fx_hud_colors();
}

reset_fx_hud_colors()
{
	for ( i = 0;i < level._createFx_hudElements; i++ )
		level._createFxHudElements[ i ][ 0 ].color = ( 1, 1, 1 );
}


button_is_held( name, name2 )
{
	if ( isdefined( name2 ) )
	{
		if ( isdefined( level._buttonIsHeld[ name2 ] ) )
			return true;
	}
	return isdefined( level._buttonIsHeld[ name ] );
}

button_is_clicked( name, name2 )
{
	if ( isdefined( name2 ) )
	{
		if ( isdefined( level._buttonClick[ name2 ] ) )
			return true;
	}
	return isdefined( level._buttonClick[ name ] );
}

toggle_entity_selection( index, ent )
{
	if ( isdefined( level._selected_fx[ index ] ) )
		deselect_entity( index, ent );
	else
		select_entity( index, ent );
}

select_entity( index, ent )
{
	if ( isdefined( level._selected_fx[ index ] ) )
		return;
	clear_settable_fx();
	level notify( "new_ent_selection" );

	ent thread entity_highlight_enable();

	level._selected_fx[ index ] = true;
	level._selected_fx_ents[ level._selected_fx_ents.size ] = ent;
}

ent_is_highlighted( ent )
{
	if ( !isdefined( level._fx_highLightedEnt ) )
		return false;
	return ent == level._fx_highLightedEnt;
}


deselect_entity( index, ent )
{
	if ( !isdefined( level._selected_fx[ index ] ) )
		return;

	clear_settable_fx();
	level notify( "new_ent_selection" );

	level._selected_fx[ index ] = undefined;

	if ( !ent_is_highlighted( ent ) )
		ent thread entity_highlight_disable();

	// remove the entity from the array of selected entities
	newArray = [];
	for ( i = 0; i < level._selected_fx_ents.size; i++ )
	{
		if ( level._selected_fx_ents[ i ] != ent )
			newArray[ newArray.size ] = level._selected_fx_ents[ i ];
	}
	level._selected_fx_ents = newArray;
}

index_is_selected( index )
{
	return isdefined( level._selected_fx[ index ] );
}

ent_is_selected( ent )
{
	for ( i = 0; i < level._selected_fx_ents.size; i++ )
	{
		if ( level._selected_fx_ents[ i ] == ent )
			return true;
	}
	return false;
}

clear_entity_selection()
{
	for ( i = 0; i < level._selected_fx_ents.size; i++ )
	{
		if ( !ent_is_highlighted( level._selected_fx_ents[ i ] ) )
			level._selected_fx_ents[ i ] thread entity_highlight_disable();
	}
	level._selected_fx = [];
	level._selected_fx_ents = [];
}

draw_axis()
{
	range = 25 * GetDvarFloat( "createfx_scaleid" );

//	range = 25;
	forward = anglestoforward( self.v[ "angles" ] );
	forward = vector_multiply( forward, range );
	right = anglestoright( self.v[ "angles" ] );
	right = vector_multiply( right, range );
	up = anglestoup( self.v[ "angles" ] );
	up = vector_multiply( up, range );
	line( self.v[ "origin" ], self.v[ "origin" ] + forward, ( 1, 0, 0 ), 1 );
	line( self.v[ "origin" ], self.v[ "origin" ] + up, ( 0, 1, 0 ), 1 );
	line( self.v[ "origin" ], self.v[ "origin" ] + right, ( 0, 0, 1 ), 1 );
}


clear_fx_hudElements()
{
	level._clearTextMarker clearAllTextAfterHudElem();

	for ( i = 0; i < level._createFx_hudElements; i++ )
	{
		for ( p = 0; p < 1; p++ )
		{
			level._createFxHudElements[ i ][ p ] setText( "" );
		}
	}

	level._fxHudElements = 0;
}


set_fx_hudElement( text )
{
	for ( p = 0; p < 1; p++ )
	{
		level._createFxHudElements[ level._fxHudElements ][ p ] setText( text );
	}

	level._fxHudElements++ ;
	assert( level._fxHudElements < level._createFx_hudElements );
}

createfx_centerprint( text )
{
	thread createfx_centerprint_thread( text );
}

createfx_centerprint_thread( text )
{
	level notify( "new_createfx_centerprint" );
	level endon( "new_createfx_centerprint" );
	for ( p = 0;p < 5;p++ )
		level._createFX_centerPrint[ p ] setText( text );
	wait( 4.5 );
	for ( p = 0;p < 5;p++ )
		level._createFX_centerPrint[ p ] setText( "" );
}

buttonDown( button, button2 )
{
	return buttonPressed_internal( button ) || buttonPressed_internal( button2 );
}



buttonPressed_internal( button )
{
	if ( !isdefined( button ) )
		return false;

	// keyboard buttons can be locked so you can type in the fx info on the keyboard without
	// accidentally activating features
	if ( kb_locked( button ) )
		return false;

	return level._player buttonPressed( button );
}


get_selected_move_vector()
{
	yaw = level._player getplayerangles()[ 1 ];
	angles = ( 0, yaw, 0 );
	right = anglestoright( angles );
	forward = anglestoforward( angles );
	up = anglestoup( angles );

	keypressed = false;
	rate = 1;

	if ( buttonDown( "kp_uparrow", "DPAD_UP" ) )
	{
		if ( level._selectedMove_forward < 0 )
			level._selectedMove_forward = 0;

		level._selectedMove_forward = level._selectedMove_forward + rate;
	}
	else
	if ( buttonDown( "kp_downarrow", "DPAD_DOWN" ) )
	{
		if ( level._selectedMove_forward > 0 )
			level._selectedMove_forward = 0;
		level._selectedMove_forward = level._selectedMove_forward - rate;
	}
	else
		level._selectedMove_forward = 0;

	if ( buttonDown( "kp_rightarrow", "DPAD_RIGHT" ) )
	{
		if ( level._selectedMove_right < 0 )
			level._selectedMove_right = 0;

		level._selectedMove_right = level._selectedMove_right + rate;
	}
	else
	if ( buttonDown( "kp_leftarrow", "DPAD_LEFT" ) )
	{
		if ( level._selectedMove_right > 0 )
			level._selectedMove_right = 0;
		level._selectedMove_right = level._selectedMove_right - rate;
	}
	else
		level._selectedMove_right = 0;

	if ( buttonDown( "BUTTON_Y" ) )
	{
		if ( level._selectedMove_up < 0 )
			level._selectedMove_up = 0;

		level._selectedMove_up = level._selectedMove_up + rate;
	}
	else
	if ( buttonDown( "BUTTON_B" ) )
	{
		if ( level._selectedMove_up > 0 )
			level._selectedMove_up = 0;
		level._selectedMove_up = level._selectedMove_up - rate;
	}
	else
		level._selectedMove_up = 0;

//	vector = (level.selectedMove_right, level.selectedMove_forward, level.selectedMove_up);
	vector = ( 0, 0, 0 );
	vector += vector_multiply( forward, level._selectedMove_forward );
	vector += vector_multiply( right, level._selectedMove_right );
	vector += vector_multiply( up, level._selectedMove_up );

	return vector;
}

process_button_held_and_clicked()
{
	add_button( "mouse1" );
	add_kb_button( "shift" );
	add_kb_button( "ctrl" );
	add_button( "BUTTON_RSHLDR" );
	add_button( "BUTTON_LSHLDR" );
	add_button( "BUTTON_RSTICK" );
	add_button( "BUTTON_LSTICK" );
	add_button( "BUTTON_A" );
	add_button( "BUTTON_B" );
	add_button( "BUTTON_X" );
	add_button( "BUTTON_Y" );
	add_button( "DPAD_UP" );
	add_button( "DPAD_LEFT" );
	add_button( "DPAD_RIGHT" );
	add_button( "DPAD_DOWN" );
	add_kb_button( "escape" );

	add_kb_button( "a" );
	add_kb_button( "g" );
	add_button( "F1" );
	add_button( "F5" );
	add_button( "F2" );
	add_kb_button( "c" );
	add_kb_button( "h" );
	add_kb_button( "i" );
	add_kb_button( "k" );
	add_kb_button( "l" );
	add_kb_button( "m" );
	add_kb_button( "p" );
	add_kb_button( "t" );
	add_kb_button( "x" );
	add_button( "del" );// DEL is allowed to be pressed while in select mode
	add_kb_button( "end" );
	add_kb_button( "tab" );
	add_kb_button( "ins" );
	add_kb_button( "add" );
	add_kb_button( "space" );
	add_kb_button( "enter" );
	add_kb_button( "v" );
	add_kb_button( "1" );
	add_kb_button( "2" );
	add_kb_button( "3" );
	add_kb_button( "4" );
	add_kb_button( "5" );
	add_kb_button( "6" );
	add_kb_button( "7" );
	add_kb_button( "8" );
	add_kb_button( "9" );
	add_kb_button( "0" );
}


locked( name )
{
	if ( isdefined( level._createfx_lockedList[ name ] ) )
		return false;

	return kb_locked( name );
}

kb_locked( name )
{
	return level._createfx_inputlocked && isdefined( level._button_is_kb[ name ] );
}


add_button( name )
{
	if ( locked( name ) )
		return;

	if ( !isdefined( level._buttonIsHeld[ name ] ) )
	{
		if ( level._player buttonPressed( name ) )
		{
			level._buttonIsHeld[ name ] = true;
			level._buttonClick[ name ] = true;
//			println("Button: " + name);
		}
	}
	else
	{
		if ( !level._player buttonPressed( name ) )
		{
			level._buttonIsHeld[ name ] = undefined;
		}
	}
}

add_kb_button( name )
{
	level._button_is_kb[ name ] = true;
	add_button( name );
}



set_anglemod_move_vector()
{
	rate = 2;

	if ( buttonDown( "kp_uparrow", "DPAD_UP" ) )
	{
		if ( level._selectedRotate_pitch < 0 )
			level._selectedRotate_pitch = 0;

		level._selectedRotate_pitch = level._selectedRotate_pitch + rate;
	}
	else
	if ( buttonDown( "kp_downarrow", "DPAD_DOWN" ) )
	{
		if ( level._selectedRotate_pitch > 0 )
			level._selectedRotate_pitch = 0;
		level._selectedRotate_pitch = level._selectedRotate_pitch - rate;
	}
	else
		level._selectedRotate_pitch = 0;

	if ( buttonDown( "kp_leftarrow", "DPAD_LEFT" ) )
	{
		if ( level._selectedRotate_yaw < 0 )
			level._selectedRotate_yaw = 0;

		level._selectedRotate_yaw = level._selectedRotate_yaw + rate;
	}
	else
	if ( buttonDown( "kp_rightarrow", "DPAD_RIGHT" ) )
	{
		if ( level._selectedRotate_yaw > 0 )
			level._selectedRotate_yaw = 0;
		level._selectedRotate_yaw = level._selectedRotate_yaw - rate;
	}
	else
		level._selectedRotate_yaw = 0;

	if ( buttonDown( "BUTTON_Y" ) )
	{
		if ( level._selectedRotate_roll < 0 )
			level._selectedRotate_roll = 0;

		level._selectedRotate_roll = level._selectedRotate_roll + rate;
	}
	else
	if ( buttonDown( "BUTTON_B" ) )
	{
		if ( level._selectedRotate_roll > 0 )
			level._selectedRotate_roll = 0;
		level._selectedRotate_roll = level._selectedRotate_roll - rate;
	}
	else
		level._selectedRotate_roll = 0;

}

cfxprintlnStart()
{
	fileprint_launcher_start_file();
}

cfxprintln( file, string )
{
	fileprint_launcher( string );
	if ( file == -1 )
		return;
	fprintln( file, string );
}

cfxprintlnEnd( file, autosave, radiant_exploder_add_string )
{
	bP4add = true;
	
	if( radiant_exploder_add_string != "" || autosave )
		bP4add = false;

	scriptname = level._script+radiant_exploder_add_string+"_fx.gsc";
	if( autosave )
		scriptname = "backup.gsc";

	fileprint_launcher_end_file( "/share/raw/maps/createfx/" + scriptname, bP4add );
} 

update_selected_entities()
{
	for ( i = 0; i < level._selected_fx_ents.size; i++ )
	{
		ent = level._selected_fx_ents[ i ];
		ent [[ level._func_updatefx ]]();
	}
}

hack_start( painter_spmp )
{
	if ( !isdefined( painter_spmp ) )
		painter_spmp = "painter_mp";
	precachemenu( painter_spmp );
	if( painter_spmp == "painter_mp" )
		return;
	
	wait .05;
	level._player openpopupmenu( painter_spmp );// painter.menu execs some console commands( ufo mode ).. sneaky hacks.
	level._player closepopupmenu( painter_spmp );
}

get_player()
{
	return getentarray( "player", "classname" )[ 0 ];
}

// bobble sort, performance does not really matter since it's only used by createFX tool.
create_fx_sort_array( fx_array )
{
	loop_count = 0;
	wait_count = 2000;

	for ( i = 0; i < fx_array.size - 1; i++ )
	{
		for ( j = i; j < fx_array.size; j++ )
		{
			// compare 2 fx entities
			result = compareFXent( fx_array[ i ], fx_array[ j ] );
			if ( result > 0 )
			{
				// swap
				a = fx_array[ i ];
				fx_array[ i ] = fx_array[ j ];
				fx_array[ j ] = a;
			}

			loop_count = loop_count + 1;
			if ( loop_count > wait_count )
			{
				wait( 0.001 );
				loop_count = 0;
			}
		}	
	}
}

// bobble sort, performance does not really matter since it's only used by createFX tool.
sort_fx_entities()
{
	create_fx_sort_array( level._createFXent );
}

createfx_orgranize_array()
{
	types = [];
	types[ 0 ] = "soundfx";
	types[ 1 ] = "loopfx";
	types[ 2 ] = "oneshotfx";
	types[ 3 ] = "exploder";
	
	array = [];
	foreach ( index, _ in types )
	{
		array[ index ] = [];
	}
	
	foreach ( ent in level._createFXent )
	{
		found_type = false;
		foreach ( index, type in types )
		{
			if ( ent.v[ "type" ] != type )
				continue;
				
			found_type = true;
			array[ index ][ array[ index ].size ] = ent;
			break;
		}
		
		assertex( found_type, "Didnt understand createfx type " + ent.v[ "type" ] );
	}

	new_array = [];	

	for ( i = 0; i < types.size; i++ )
	{
		create_fx_sort_array( array[i] );

		foreach ( ent in array[ i ] )
		{
			new_array[ new_array.size ] = ent;
		}
	}
	
	level._createFXent = new_array;
}

stop_fx_looper( killElements )
{
	if ( isdefined( self.looper ) )
	{
		if ( isdefined( killElements ) )
		{
			self.looper delete(killElements);
		}
		else
		{
			self.looper delete();
		}
	}
	self stop_loopsound();
}

stop_loopsound()
{
	self notify( "stop_loop" );
}

func_get_level_fx()
{
	AssertEx( IsDefined( level._effect ), "No effect aliases defined!" );

	if ( !IsDefined( level._effect_keys ) )
	{
		keys = getarraykeys( level._effect );
	}
	else
	{
		keys = getarraykeys( level._effect );
		if ( keys.size == level._effect_keys.size )
		{
			return level._effect_keys;
		}
	}

	println( "alphabetizing fx" );
	
	keys = sortString( keys ); // faster version
	//keys = alphabetize( keys ); // this is slow
	
	level._effect_keys = keys;
	return keys;
}

restart_fx_looper()
{
	stop_fx_looper( 1 );

	self set_forward_and_up_vectors();
	if ( self.v[ "type" ] == "loopfx" )
	{
		// new entities from copy/paste wont have a looper
		self create_looper();
	}

	if ( self.v[ "type" ] == "oneshotfx" )
	{
		// new entities from copy/paste wont have a looper
		self create_triggerfx();
	}

	if ( self.v[ "type" ] == "soundfx" )
	{
		// new entities from copy/paste wont have a looper
		self create_loopsound();
	}
}

process_fx_rotater()
{
	if ( level._fx_rotating )
		return;


	set_anglemod_move_vector();

	if ( !rotation_is_occuring() )
		return;

	level._fx_rotating = true;

	if ( level._selected_fx_ents.size > 1 )
	{
	center = get_center_of_array( level._selected_fx_ents );
	org = spawn( "script_origin", center );
	org.v[ "angles" ] = level._selected_fx_ents[ 0 ].v[ "angles" ];
	org.v[ "origin" ] = center;

	rotater = [];
	for ( i = 0; i < level._selected_fx_ents.size; i++ )
	{
		rotater[ i ] = spawn( "script_origin", level._selected_fx_ents[ i ].v[ "origin" ] );
		rotater[ i ].angles = level._selected_fx_ents[ i ].v[ "angles" ];
		rotater[ i ] linkto( org );
	}

//	println ("pitch " + level.selectedRotate_pitch + " yaw " + level.selectedRotate_yaw);

	rotate_over_time( org, rotater );

	org delete();

	for ( i = 0; i < rotater.size; i++ )
		rotater[ i ] delete();
	}
	else if ( level._selected_fx_ents.size == 1 )
	{
		ent = level._selected_fx_ents[ 0 ];
		rotater = spawn( "script_origin", ( 0, 0, 0 ) );
		rotater.angles = ent.v[ "angles" ];
		if ( level._selectedRotate_pitch != 0 )
			rotater AddPitch( level._selectedRotate_pitch );
		else
		if ( level._selectedRotate_yaw != 0 )
			rotater AddYaw( level._selectedRotate_yaw );
		else
			rotater AddRoll( level._selectedRotate_roll );
		ent.v[ "angles" ] = rotater.angles;
		rotater delete();
		wait( 0.05 );
	}

	level._fx_rotating = false;
}

computeFXentKey( ent )
{
	primaryKey = 0;
	
	if ( ent.v[ "type" ] == "loopfx" )
	{
		primaryKey = 1;
	}
	else if ( ent.v[ "type" ] == "oneshotfx" )
	{
		primaryKey = 2;
	}
	else if ( ent.v[ "type" ] == "exploder" )
	{
		primaryKey = 3;
	}
	else if ( ent.v[ "type" ] == "soundfx" )
	{
		primaryKey = 4;
	}
	
	return primaryKey;
}

compareFXent( ent0, ent1 )
{
	// compare fx type
	key0 = computeFXentKey( ent0 );
	key1 = computeFXentKey( ent1 );

	if ( key0 < key1 )
	{
		return -1;
	}
	else if ( key0 > key1 )
	{
		return 1;
	}	

	str0 = "";
	str1 = "";
	
	// sound type
	if ( key0==4 )
	{
		str0 = ent0.v[ "soundalias" ];
		str1 = ent1.v[ "soundalias" ];
	}
	else
	{
		str0 = ent0.v[ "fxid" ];
		str1 = ent1.v[ "fxid" ];
	}
	
	// compare fx id
	result = compareString( str0, str1 );
	
	if ( result != 0 )
	{
		return result;
	}
	
	// compare fx origin
	diff = ent0.v[ "origin" ] - ent1.v[ "origin" ];
	for ( i=0; i<3; i++ )
	{	
		if ( diff[i] < 0 )
		{
			return -1;
		}
		else if ( diff[i] > 0 )
		{
			return 1;
		}
	}

	// same	
	return 0;
}

generate_fx_log( autosave )
{
	// first lets fix all the really small numbers so they dont cause errors because the game will print out
	// 4.2343-7e or whatever but cant accept it back in from script

	flag_waitopen( "createfx_saving" );
	flag_set( "createfx_saving" );
	autosave = isdefined( autosave );
	tab = "\t";
	
	radiant_exploder_add_string = "";
	if( GetDvarInt("scr_map_exploder_dump") )
		radiant_exploder_add_string = "_radiant_exploders";
		
	filename = "createfx/" + level._script + radiant_exploder_add_string + "_fx.gsc";
	if ( autosave )
		filename = "createfx/backup.gsc";

//	file = openfile( filename, "write" );
//	assertex( file != -1, "File not writeable (maybe you should check it out): " + filename );
	file = -1;

	// backup _createFXent array
	fxEntityBackup = level._createFXent;
	
	cfxprintlnStart();
	cfxprintln( file, "//_createfx generated. Do not touch!!" );
	cfxprintln( file, "#include common_scripts\\utility;" );
	cfxprintln( file, "#include common_scripts\\_createfx;\n" );
	cfxprintln( file, "main()" );
	cfxprintln( file, "{" );
	
	createfx_orgranize_array();	

	limit = 0.1;
	for ( p = 0; p < level._createFXent.size; p++ )
	{
		ent = level._createFXent[ p ];
		origin = [];
		angles = [];
		for ( i = 0;i < 3;i++ )
		{
			origin[ i ] = ent.v[ "origin" ][ i ];
			angles[ i ] = ent.v[ "angles" ][ i ];

			if ( origin[ i ] < limit && origin[ i ] > limit * - 1 )
				origin[ i ] = 0;
			if ( angles[ i ] < limit && angles[ i ] > limit * - 1 )
				angles[ i ] = 0;
		}

		ent.v[ "origin" ] = ( origin[ 0 ], origin[ 1 ], origin[ 2 ] );
		ent.v[ "angles" ] = ( angles[ 0 ], angles[ 1 ], angles[ 2 ] );
	}

	cfxprintln( file, tab + "// CreateFX entities size: " + level._createFxEnt.size );
	
	processed = 0;
	
	for ( i = 0; i < level._createFXent.size; i++ )
	{
		if ( file != -1 && level._createfx_loopcounter > 32 )
		{
			level._createfx_loopcounter = 0;
			wait .05; // loop protection fails on writing the file
		}
		level._createfx_loopcounter++;

		e = level._createFXent[ i ];
		assertEX( isdefined( e.v[ "type" ] ), "effect at origin " + e.v[ "origin" ] + " has no type" );

		// don't post .map effects in the script.
//		if (e.v["worldfx"])
//			continue;

		// when scr_map_exploder_dump is set just output the exploders from radiant.  could output two scripts but keeping it simple.
		if( GetDvarInt("scr_map_exploder_dump") )
		{
			if ( !isdefined( e.model ) )
			{
				continue;
			}
		}
		else if ( isdefined( e.model ) )
		{
			continue; // entities with models are from radiant and don't get reported
		}
			
		if ( e.v[ "type" ] == "loopfx" )
		{
			cfxprintln( file, tab + "ent = createLoopEffect( \"" + e.v[ "fxid" ] + "\" );" );
			processed++;
		}
		else if ( e.v[ "type" ] == "oneshotfx" )
		{
			cfxprintln( file, tab + "ent = createOneshotEffect( \"" + e.v[ "fxid" ] + "\" );" );
			processed++;
		}
		else if ( e.v[ "type" ] == "exploder" )
		{
			cfxprintln( file, tab + "ent = createExploder( \"" + e.v[ "fxid" ] + "\" );" );
			processed++;
		}
		else if ( e.v[ "type" ] == "soundfx" )
		{
			cfxprintln( file, tab + "ent = createLoopSound();" );
			processed++;
		}

		cfxprintln( file, tab + "ent.v[ \"origin\" ] = ( " + e.v[ "origin" ][ 0 ] + ", " + e.v[ "origin" ][ 1 ] + ", " + e.v[ "origin" ][ 2 ] + " );" );
		cfxprintln( file, tab + "ent.v[ \"angles\" ] = ( " + e.v[ "angles" ][ 0 ] + ", " + e.v[ "angles" ][ 1 ] + ", " + e.v[ "angles" ][ 2 ] + " );" );

		print_fx_options( e, tab, file, autosave );
		cfxprintln( file, "" );
	}

	cfxprintln( file, tab + "// CreateFX entities placed: " + processed );
	cfxprintln( file, "}" );
	cfxprintln( file, " " );
	cfxprintlnEnd( file, autosave,  radiant_exploder_add_string );
	
//	saved = closefile( file );
//	assertex( saved == 1, "File not saved (see above message?): " + filename );
	flag_clear( "createfx_saving" );
	
	// restore
	level._createFXent = fxEntityBackup;
}

deleteAllEffects()
{
	immediate = 1;
	
	foreach ( entFx in level._createfxent )
	{
		if ( isdefined( entFx.looper ) )
		{
			if ( isdefined( immediate ) )
			{
				entFx.looper delete( immediate );
			}
			else
			{
				entFx.looper delete();
			}
		}
		entFx notify( "stop_loop" );
    }
}