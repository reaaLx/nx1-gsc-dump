#include maps\_utility;
#include animscripts\utility;
#include common_scripts\utility;

setParent( element )
{
	if ( isDefined( self.parent ) && self.parent == element )
		return;

	if ( isDefined( self.parent ) )
		self.parent removeChild( self );

	self.parent = element;
	self.parent addChild( self );

	if ( isDefined( self.point ) )
		self setPoint( self.point, self.relativePoint, self.xOffset, self.yOffset );
	else
		self setPoint( "TOPLEFT" );
}

getParent()
{
	return self.parent;
}

addChild( element )
{
	element.index = self.children.size;
	self.children[ self.children.size ] = element;
}

removeChild( element )
{
	element.parent = undefined;

	if ( self.children[ self.children.size - 1 ] != element )
	{
		self.children[ element.index ] = self.children[ self.children.size - 1 ];
		self.children[ element.index ].index = element.index;
	}
	self.children[ self.children.size - 1 ] = undefined;

	element.index = undefined;
}


setPoint( point, relativePoint, xOffset, yOffset, moveTime )
{
	if ( !isDefined( moveTime ) )
		moveTime = 0;

	element = self getParent();

	if ( moveTime )
		self moveOverTime( moveTime );

	if ( !isDefined( xOffset ) )
		xOffset = 0;
	self.xOffset = xOffset;

	if ( !isDefined( yOffset ) )
		yOffset = 0;
	self.yOffset = yOffset;

	self.point = point;

	self.alignX = "center";
	self.alignY = "middle";

	if ( isSubStr( point, "TOP" ) )
		self.alignY = "top";
	if ( isSubStr( point, "BOTTOM" ) )
		self.alignY = "bottom";
	if ( isSubStr( point, "LEFT" ) )
		self.alignX = "left";
	if ( isSubStr( point, "RIGHT" ) )
		self.alignX = "right";

	if ( !isDefined( relativePoint ) )
		relativePoint = point;

	self.relativePoint = relativePoint;

	relativeX = "center";
	relativeY = "middle";

	if ( isSubStr( relativePoint, "TOP" ) )
		relativeY = "top";
	if ( isSubStr( relativePoint, "BOTTOM" ) )
		relativeY = "bottom";
	if ( isSubStr( relativePoint, "LEFT" ) )
		relativeX = "left";
	if ( isSubStr( relativePoint, "RIGHT" ) )
		relativeX = "right";

	if ( element == level._uiParent )
	{
		self.horzAlign = relativeX;
		self.vertAlign = relativeY;
	}
	else
	{
		self.horzAlign = element.horzAlign;
		self.vertAlign = element.vertAlign;
	}


	if ( relativeX == element.alignX )
	{
		offsetX = 0;
		xFactor = 0;
	}
	else if ( relativeX == "center" || element.alignX == "center" )
	{
		offsetX = int( element.width / 2 );
		if ( relativeX == "left" || element.alignX == "right" )
			xFactor = -1;
		else
			xFactor = 1;
	}
	else
	{
		offsetX = element.width;
		if ( relativeX == "left" )
			xFactor = -1;
		else
			xFactor = 1;
	}
	self.x = element.x + ( offsetX * xFactor );

	if ( relativeY == element.alignY )
	{
		offsetY = 0;
		yFactor = 0;
	}
	else if ( relativeY == "middle" || element.alignY == "middle" )
	{
		offsetY = int( element.height / 2 );
		if ( relativeY == "top" || element.alignY == "bottom" )
			yFactor = -1;
		else
			yFactor = 1;
	}
	else
	{
		offsetY = element.height;
		if ( relativeY == "top" )
			yFactor = -1;
		else
			yFactor = 1;
	}
	self.y = element.y + ( offsetY * yFactor );

	self.x += self.xOffset;
	self.y += self.yOffset;

	switch( self.elemType )
	{
		case "bar":
			setPointBar( point, relativePoint, xOffset, yOffset );
			break;
	}

	self updateChildren();
}


setPointBar( point, relativePoint, xOffset, yOffset )
{
	self.bar.horzAlign = self.horzAlign;
	self.bar.vertAlign = self.vertAlign;

	self.bar.alignX = "left";
	self.bar.alignY = self.alignY;
	self.bar.y = self.y;

	if ( self.alignX == "left" )
		self.bar.x = self.x + self.padding;
	else if ( self.alignX == "right" )
		self.bar.x = self.x - ( self.width - self.padding );
	else
		self.bar.x = self.x - int( ( self.width - self.padding ) / 2 );

	self updateBar( self.bar.frac );
}


updateBar( barFrac )
{
	barWidth = int( ( self.width - ( self.padding * 2 ) ) * barFrac );

	if ( !barWidth )
		barWidth = 1;

	self.bar.frac = barFrac;
	self.bar setShader( self.bar.shader, barWidth, self.height - ( self.padding * 2 ) );
}


/*
=============
///ScriptDocBegin
"Name: createFontString( <font>, <fontScale> )"
"Summary: Creates a hud element for font purposes"
"Module: Hud"
"MandatoryArg: <font>: Apparently this is always set to default."
"MandatoryArg: <fontScale>: The scale you want."
"Example: level.hintElem = createFontString( "default", 2.0 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

createFontString( font, fontScale )
{
	fontElem = newHudElem();
	fontElem.elemType = "font";
	fontElem.font = font;
	fontElem.fontscale = fontScale;
	fontElem.x = 0;
	fontElem.y = 0;
	fontElem.width = 0;
	fontElem.height = int( level._fontHeight * fontScale );
	fontElem.xOffset = 0;
	fontElem.yOffset = 0;
	fontElem.children = [];
	fontElem setParent( level._uiParent );

	return fontElem;
}


/*
=============
///ScriptDocBegin
"Name: createClientFontString( <font>, <fontScale> )"
"Summary: Creates a client hud element for font purposes"
"Module: Hud"
"MandatoryArg: <font>: Apparently this is always set to default."
"MandatoryArg: <fontScale>: The scale you want."
"Example: level.hintElem = level.player createClientFontString( "default", 2.0 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

createClientFontString( font, fontScale )
{
	assert( isplayer( self ) );

	fontElem = newClientHudElem( self );
	fontElem.elemType = "font";
	fontElem.font = font;
	fontElem.fontscale = fontScale;
	fontElem.x = 0;
	fontElem.y = 0;
	fontElem.width = 0;
	fontElem.height = int( level._fontHeight * fontScale );
	fontElem.xOffset = 0;
	fontElem.yOffset = 0;
	fontElem.children = [];
	fontElem setParent( level._uiParent );

	return fontElem;
}

createClientTimer( font, fontScale )
{
	assert( isplayer( self ) );

	timerElem = newClientHudElem( self );
	timerElem.elemType = "timer";
	timerElem.font = font;
	timerElem.fontscale = fontScale;
	timerElem.x = 0;
	timerElem.y = 0;
	timerElem.width = 0;
	timerElem.height = int( level._fontHeight * fontScale );
	timerElem.xOffset = 0;
	timerElem.yOffset = 0;
	timerElem.children = [];
	timerElem setParent( level._uiParent );

	return timerElem;
}


createServerFontString( font, fontScale )
{
	fontElem = newHudElem();
	fontElem.elemType = "font";
	fontElem.font = font;
	fontElem.fontscale = fontScale;
	fontElem.x = 0;
	fontElem.y = 0;
	fontElem.width = 0;
	fontElem.height = int( level._fontHeight * fontScale );
	fontElem.xOffset = 0;
	fontElem.yOffset = 0;
	fontElem.children = [];
	fontElem setParent( level._uiParent );

	return fontElem;
}

createServerTimer( font, fontScale )
{
	timerElem = newHudElem();
	timerElem.elemType = "timer";
	timerElem.font = font;
	timerElem.fontscale = fontScale;
	timerElem.x = 0;
	timerElem.y = 0;
	timerElem.width = 0;
	timerElem.height = int( level._fontHeight * fontScale );
	timerElem.xOffset = 0;
	timerElem.yOffset = 0;
	timerElem.children = [];
	timerElem setParent( level._uiParent );

	return timerElem;
}

createIcon( shader, width, height )
{
	iconElem = newHudElem();
	return createIcon_Hudelem( iconElem, shader, width, height );
}

createClientIcon( shader, width, height )
{
	iconElem = newClientHudElem( self );
	return createIcon_Hudelem( iconElem, shader, width, height );
}

createIcon_Hudelem( iconElem, shader, width, height )
{
	iconElem.elemType = "icon";
	iconElem.x = 0;
	iconElem.y = 0;
	iconElem.width = width;
	iconElem.height = height;
	iconElem.xOffset = 0;
	iconElem.yOffset = 0;
	iconElem.children = [];
	iconElem setParent( level._uiParent );

	if ( isDefined( shader ) )
		iconElem setShader( shader, width, height );

	return iconElem;
}


createBar( shader, bgshader, width, height, flashFrac )
{
	if ( !isdefined( shader ) )
		shader = "white";

	if ( !isdefined( bgshader ) )
		bgshader = "black";

	if ( !isdefined( width ) )
		width = 100;

	if ( !isdefined( height ) )
		height = 9;

	barElem = newHudElem();
	barElem.x = 0 + 2;
	barElem.y = 0 + 2;
	barElem.frac = 0.25;
	barElem.shader = shader;
	barElem.sort = -1;
	barElem setShader( shader, width - 2, height - 2 );
	if ( isDefined( flashFrac ) )
	{
		barElem.flashFrac = flashFrac;
		barElem thread flashThread();
	}

	barElemBG = newHudElem();
	barElemBG.elemType = "bar";
	barElemBG.x = 0;
	barElemBG.y = 0;
	barElemBG.width = width;
	barElemBG.height = height;
	barElemBG.xOffset = 0;
	barElemBG.yOffset = 0;
	barElemBG.bar = barElem;
	barElemBG.children = [];
	barElemBG.padding = 2;
	barElemBG.sort = -2;
	barElemBG.alpha = 0.5;
	barElemBG setParent( level._uiParent );
	barElemBG setShader( bgshader, width, height );

	return barElemBG;
}

createClientProgressBar( player, offset )
{
	if ( !isdefined( player ) )
		player = level._player;

	if ( !isdefined( offset ) )
		offset = 90;
		
    bar = player createClientBar( "white", "black", 100, 9 );
	bar setPoint( "CENTER", undefined, 0, offset );

    return bar;
}

createClientBar( shader, bgshader, width, height, flashFrac )
{
	barElem = newClientHudElem( self );
	barElem.x = 0 + 2;
	barElem.y = 0 + 2;
	barElem.frac = 0.25;
	barElem.shader = shader;
	barElem.sort = -1;
	barElem setShader( shader, width - 2, height - 2 );
	if ( isDefined( flashFrac ) )
	{
		barElem.flashFrac = flashFrac;
		barElem thread flashThread();
	}

	barElemBG = newClientHudElem( self );
	barElemBG.elemType = "bar";
	barElemBG.x = 0;
	barElemBG.y = 0;
	barElemBG.width = width;
	barElemBG.height = height;
	barElemBG.xOffset = 0;
	barElemBG.yOffset = 0;
	barElemBG.bar = barElem;
	barElemBG.children = [];
	barElemBG.padding = 2;
	barElemBG.sort = -2;
	barElemBG.alpha = 0.5;
	barElemBG setParent( level._uiParent );
	barElemBG setShader( bgshader, width, height );

	return barElemBG;
}


setFlashFrac( flashFrac )
{
	self.bar.flashFrac = flashFrac;
}

/*
=============
///ScriptDocBegin
"Name: fade_over_time( <target_alpha> , <fade_time> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
fade_over_time( target_alpha, fade_time )
{
	self fadeOverTime( fade_time );
	self.alpha = target_alpha;
	wait fade_time;
}

flashThread()
{
	self endon( "death" );

	self.alpha = 1;
	while ( 1 )
	{
		if ( self.frac >= self.flashFrac )
		{
			self fadeOverTime( 0.3 );
			self.alpha = .2;
			wait( 0.35 );
			self fadeOverTime( 0.3 );
			self.alpha = 1;
			wait( 0.7 );
		}
		else
		{
			self.alpha = 1;
			wait( 0.05 );
		}
	}
}


destroyElem()
{
	tempChildren = [];

	for ( index = 0; index < self.children.size; index++ )
		tempChildren[ index ] = self.children[ index ];

	for ( index = 0; index < tempChildren.size; index++ )
		tempChildren[ index ] setParent( self getParent() );

	if ( self.elemType == "bar" )
		self.bar destroy();

	self destroy();
}

setIconShader( shader )
{
	self setShader( shader, self.width, self.height );
}

setWidth( width )
{
	self.width = width;
}


setHeight( height )
{
	self.height = height;
}

setSize( width, height )
{
	self.width = width;
	self.height = height;
}

updateChildren()
{
	for ( index = 0; index < self.children.size; index++ )
	{
		child = self.children[ index ];
		child setPoint( child.point, child.relativePoint, child.xOffset, child.yOffset );
	}
}

/*
	thread stance_carry_icon_enable( bool );
	Diasables all stance icons and replaces with an icon of 
	a person carrying another person on his back. True/false
*/
stance_carry_icon_enable( bool )
{
	if ( isdefined( bool ) && bool == false )
	{
		stance_carry_icon_disable();
		return;
	}

	if ( isDefined( level._stance_carry ) )
		level._stance_carry destroy();

	SetSavedDvar( "hud_showStance", "0" );

	level._stance_carry = newHudElem();
	level._stance_carry.x = 100;
	if ( level._console )
		level._stance_carry.y = 20;
	else
		level._stance_carry.y = 10;
	level._stance_carry setshader( "stance_carry", 64, 64 );
	level._stance_carry.alignX = "left";
	level._stance_carry.alignY = "bottom";
	level._stance_carry.horzAlign = "left";
	level._stance_carry.vertAlign = "bottom";
	level._stance_carry.foreground = true;
	level._stance_carry.alpha = 0;
	level._stance_carry fadeOverTime( 0.5 );
	level._stance_carry.alpha = 1;
}

stance_carry_icon_disable()
{
	if ( isDefined( level._stance_carry ) )
	{
		level._stance_carry fadeOverTime( 0.5 );
		level._stance_carry.alpha = 0;
		level._stance_carry destroy();
	}
	SetSavedDvar( "hud_showStance", "1" );
}


/*
=============
///ScriptDocBegin
"Name: create_mantle( <create_mantle> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
create_mantle()
{
	if ( level._console )
	{
		text = createFontString( "default", 1.8 );
		text setPoint( "CENTER", undefined, -23, 115 );
		text settext( level._strings[ "mantle" ] );

		icon = createIcon( "hint_mantle", 40, 40 );
		icon setPoint( "CENTER", undefined, 73, 0 );
		icon setparent( text );
	}
	else
	{
		text = createFontString( "default", 1.6 );
		text setPoint( "CENTER", undefined, 0, 115 );
		text settext( level._strings[ "mantle" ] );

		icon = createIcon( "hint_mantle", 40, 40 );
		icon setPoint( "CENTER", undefined, 0, 30 );
		icon setparent( text );
	}

	icon.alpha = 0;
	text.alpha = 0;

	level._hud_mantle = [];
	level._hud_mantle[ "text" ] = text;
	level._hud_mantle[ "icon" ] = icon;
}

get_countdown_hud( x, y, player )
{
	xPos = undefined;
	if ( !level._Console )
		xPos = -250; //override x-position if this is PC or the timer will get cut off
	else if ( !isdefined( x ) )
		xPos = -225;
	else
		xPos = x;

	if ( !isdefined( y ) )
		yPos = 100;
	else
		yPos = y;

	if ( isdefined( player ) )
		hudelem = newClientHudElem( player );
	else
		hudelem = newHudElem();
	
	hudelem.alignX = "left";
	hudelem.alignY = "middle";
	hudelem.horzAlign = "right";
	hudelem.vertAlign = "top";
	hudelem.x = xPos;
	hudelem.y = yPos;
	hudelem.fontScale = 1.6;
	hudelem.color = ( getdvarfloat( "color_neutral_r" ), getdvarfloat( "color_neutral_g" ), getdvarfloat( "color_neutral_b" ) );
	hudelem.font = "fwmed";
	//hudelem.glowColor = ( 0.3, 0.6, 0.3 );
	//hudelem.glowAlpha = 1;
	hudelem.foreground = 1;
	hudelem.hidewheninmenu = true;
	hudelem.hidewhendead = true;
	return hudelem;
}

get_download_state_hud( x, y, player )
{
	xPos = undefined;
	if ( !level._Console )
		xPos = -250; //override x-position if this is PC or the timer will get cut off
	else if ( !isdefined( x ) )
		xPos = -170;
	else
		xPos = x;

	if ( !isdefined( y ) )
		yPos = 100;
	else
		yPos = y;

	if ( isdefined( player ) )
		hudelem = newClientHudElem( player );
	else
		hudelem = newHudElem();
	
	hudelem.alignX = "right";
	hudelem.alignY = "middle";
	hudelem.horzAlign = "right";
	hudelem.vertAlign = "top";
	hudelem.x = xPos;
	hudelem.y = yPos;
	hudelem.fontScale = 1.6;
	hudelem.color = ( getdvarfloat( "color_neutral_r" ), getdvarfloat( "color_neutral_g" ), getdvarfloat( "color_neutral_b" ) );
	hudelem.font = "fwmed";
	//hudelem.glowColor = ( 0.3, 0.6, 0.3 );
	//hudelem.glowAlpha = 1;
	hudelem.foreground = 1;
	hudelem.hidewheninmenu = true;
	hudelem.hidewhendead = true;
	return hudelem;
}

/*
=============
///ScriptDocBegin
"Name: create_client_overlay( <shader_name>, <start_alpha>, <player> )"
"Summary: Creates a full screen client hud overlay. Must also use code command precacheShader( <shader_name> ) to precache the element used (black, white, etc)."
"Module: Hud"
"MandatoryArg: <shader_name>: Name of the shader precached that you want to have displayed."
"MandatoryArg: <start_alpha>: Beginning alpha value for the element."
"OptionalArg: <player>: Pointer to the player for which the overlay will be displayed. If left blank, overlay will be displayed for all players."
"Example: black_overlay = create_client_overlay( "black", 0, level.player );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
create_client_overlay( shader_name, start_alpha, player )
{
	if ( isdefined( player ) )
		overlay = newClientHudElem( player );
	else
		overlay = newHudElem();
	overlay.x = 0;
	overlay.y = 0;
	overlay setshader( shader_name, 640, 480 );
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.sort = 1;
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha = start_alpha;
	overlay.foreground = true;
	return overlay;
}

/*
=============
///ScriptDocBegin
"Name: create_client_overlay_custom_size( <shader_name>, <start_alpha>, <w>, <h> )"
"Summary: Creates a full screen client hud overlay. Must also use code command precacheShader( <shader_name> ) to precache the element used (black, white, etc)."
"Module: Hud"
"MandatoryArg: <shader_name>: Name of the shader precached that you want to have displayed."
"MandatoryArg: <start_alpha>: Beginning alpha value for the element."
"MandatoryArg: <w>: Width."
"MandatoryArg: <h>: Height."
"CallOn: A player"
"Example: black_overlay = create_client_overlay_custom_size( "black", 0, 100, 50 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
create_client_overlay_custom_size( shader_name, start_alpha, w, h )
{
	player = get_player_from_self();
	overlay = newClientHudElem( player );

	overlay.x = 0;
	overlay.y = 0;
	overlay setshader( shader_name, w, h );
	overlay.alignX = "center";
	overlay.alignY = "middle";
	overlay.sort = 1;
	overlay.horzAlign = "center";
	overlay.vertAlign = "middle";
	overlay.alpha = start_alpha;
	overlay.foreground = true;
	return overlay;
}

/*
=============
///ScriptDocBegin
"Name: create_client_overlay_postfx_custom_size( <shader_name>, <start_alpha>, <w>, <h> )"
"Summary: Creates a full screen client hud overlay that works with postfx shaders (i.e. refraction). Must also use code command precacheShader( <shader_name> ) to precache the element used (black, white, etc)."
"Module: Hud"
"MandatoryArg: <shader_name>: Name of the shader precached that you want to have displayed."
"MandatoryArg: <start_alpha>: Beginning alpha value for the element."
"MandatoryArg: <w>: Width."
"MandatoryArg: <h>: Height."
"CallOn: A player"
"Example: black_overlay = create_client_overlay_custom_size( "black", 0, 100, 50 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
create_client_overlay_postfx_custom_size( shader_name, start_alpha, w, h )
{
	player = get_player_from_self();
	overlay = newClientHudElem( player );

	overlay.x = 0;
	overlay.y = 0;
	overlay.postfx = true;
	overlay setshader( shader_name, w, h );
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.sort = 50;
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha = start_alpha;
	overlay.foreground = true;
	return overlay;
}

/*
=============
///ScriptDocBegin
"Name: create_cinematic_hud_overlay( <x>, <y>, <w>, <h>, <trans> )"
"Summary: Creates a cinematic hud overlay."
"Module: Hud"
"MandatoryArg: <x, y>: Position of the middle center of the hud element."
"MandatoryArg: <w, h>: Dimensions for the element."
"OptionalArg: <trans>: If true, the default texture that shows during loading and unloading of the movie should be zero alpha"
"Example: cinema_overlay = create_cinematic_hud_overlay( 0, 0, 640, 480 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
create_cinematic_hud_overlay( x, y, w, h, trans )
{
	overlay = newHudElem();
	overlay.x = x;
	overlay.y = y;
	if( isDefined( trans ) && trans == true )
	{
		overlay setshader( "cinematic_trans", w, h );
	}
	else
	{
		overlay setshader( "cinematic", w, h );
	}
	overlay.alignX = "center";
	overlay.alignY = "middle";
	overlay.sort = 1;
	overlay.horzAlign = "center";
	overlay.vertAlign = "middle";
	overlay.alpha = 1;
	overlay.foreground = false;
	return overlay;
}

/*
=============
///ScriptDocBegin
"Name: destroy_cinematic_hud_overlay( <overlay> )"
"Summary: Deletes a cinematic hud overlay."
"Module: Hud"
"MandatoryArg: <overlay>: The hud element to remove."
"Example: destroy_cinematic_hud_overlay( cinema_overlay );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
destroy_cinematic_hud_overlay( overlay )
{
	overlay Destroy();
}

/*
=============
///ScriptDocBegin
"Name: play_cinematic_streamed( <movie> )"
"Summary: Plays a movie on a cinematic hud overlay, streamed from disk."
"Module: Hud"
"MandatoryArg: <movie>: The bink to play."
"Example: play_cinematic_streamed( "test_movie" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
/*
play_cinematic_streamed( movie )
{
	setsaveddvar( "cg_cinematicFullScreen", "0" );
	CinematicInGame( movie );
}
*/

/*
=============
///ScriptDocBegin
"Name: load_cinematic( <movie> )"
"Summary: Loads a movie."
"Module: Hud"
"MandatoryArg: <movie>: The bink to play."
"Example: load_cinematic( "test_movie" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
load_cinematic( movie )
{
	load_cinematic_streamed( movie );
}

/*
=============
///ScriptDocBegin
"Name: load_cinematic_resident( <movie> )"
"Summary: Loads a movie, blocking until the movie is loaded into memory."
"Module: Hud"
"MandatoryArg: <movie>: The bink to play."
"Example: load_cinematic_resident( "test_movie" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
load_cinematic_resident( movie )
{
	// wait until any previous playback finishes
	while ( IsCinematicPlaying() )
	{
		wait 0.05;
	}

	setsaveddvar( "cg_cinematicFullScreen", "0" );
	CinematicInGameResident( movie );
	while ( !IsCinematicLoaded() )
	{
		wait 0.05;
	}
	PauseCinematicInGame();
}


/*
=============
///ScriptDocBegin
"Name: load_cinematic_streamed( <movie> )"
"Summary: Opens a movie for playback from disk."
"Module: Hud"
"MandatoryArg: <movie>: The bink to play."
"Example: load_cinematic_streamed( "test_movie" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
load_cinematic_streamed( movie )
{
	// wait until any previous playback finishes
	while ( IsCinematicPlaying() )
	{
		wait 0.05;
	}

	setsaveddvar( "cg_cinematicFullScreen", "0" );
	CinematicInGame( movie );
	while ( !IsCinematicLoaded() )
	{
		wait 0.05;
	}
	PauseCinematicInGame();
}

/*
=============
///ScriptDocBegin
"Name: play_cinematic()"
"Summary: Plays/unpauses a movie."
"Module: Hud"
"Example: play_cinematic();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
play_cinematic()
{
	UnpauseCinematicInGame();

	// it takes a frame or two before the cinematic actually starts playing
	while ( !IsCinematicPlaying() )
	{
		wait 0.05;
	}
}

/*
=============
///ScriptDocBegin
"Name: pause_cinematic()"
"Summary: Pauses a movie."
"Module: Hud"
"Example: pause_cinematic();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
pause_cinematic()
{
	PauseCinematicInGame();
}

/*
=============
///ScriptDocBegin
"Name: stop_cinematic()"
"Summary: Stops a movie."
"Module: Hud"
"Example: stop_cinematic();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
stop_cinematic()
{
	StopCinematicInGame();
}

////////////////////////////////////////
//           BINK HUD TEST            //
////////////////////////////////////////

bink_hud_test_wait_and_destroy( overlay )
{
	while ( IsCinematicPlaying() )
	{
		wait 0.05;
	}
	destroy_cinematic_hud_overlay( overlay );
}

bink_hud_test()
{
	if ( getdvar("profile_test_bink") != "" )
	{
		cinema_overlay = create_cinematic_hud_overlay( 0, 0, 640, 480 );
		if ( GetDvarInt( "profile_test_bink_loop" ) == 1 )
		{
			if ( GetDvarInt( "profile_test_bink_streamed" ) != 1 )
			{
				setsaveddvar( "cg_cinematicFullScreen", "0" );
				CinematicInGameLoopResident( getdvar("profile_test_bink") );
			}
			else
			{
				setsaveddvar( "cg_cinematicFullScreen", "0" );
				CinematicInGameLoop( getdvar("profile_test_bink") );
			}
		}
		else
		{
			if ( GetDvarInt( "profile_test_bink_streamed" ) != 1 )
			{
				load_cinematic_resident( getdvar("profile_test_bink") );
			}
			else
			{
				load_cinematic_streamed( getdvar("profile_test_bink") );
			}
			play_cinematic();
			thread bink_hud_test_wait_and_destroy( cinema_overlay );
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
lerp_threatID_wipe_color( rgb, a, time )
{
	curr_rgb = 	GetDvarVector( "gp_threatid_fullscreen_base_rgb" );
	curr_a = GetDvarFloat( "gp_threatid_fullscreen_base_a" );

	interval = .05;
	count = Int( time / interval );

	while ( count )
	{
		// tagBR< note >: Cannot loop here as you cannot change individual vector components...fuck
		range = rgb[0] - curr_rgb[0];
		delta = range / count;
		curr_rgb += ( delta, 0, 0 );

		range = rgb[1] - curr_rgb[1];
		delta = range / count;
		curr_rgb += ( 0, delta, 0 );

		range = rgb[2] - curr_rgb[2];
		delta = range / count;
		curr_rgb += ( 0, 0, delta );

		range = a - curr_a;
		delta = range / count;
		curr_a += delta;

		SetSavedDvar( "gp_threatid_fullscreen_base_rgb", "" + curr_rgb[0] + " " + curr_rgb[1] + " " + curr_rgb[2] );
		SetSavedDvar( "gp_threatid_fullscreen_base_a", curr_a );

		wait interval;
		count--;
	}

	SetSavedDvar( "gp_threatid_fullscreen_base_rgb", "" + rgb[0] + " " + rgb[1] + " " + rgb[2] + " " + a );
	SetSavedDvar( "gp_threatid_fullscreen_base_a", a );
}

// Play the threat ID bootup sequence
play_threat_detect_bootup()
{
	level endon( "threat_id_destroy" );

	//color_swatch_overlay = create_client_overlay_custom_size( "hud_color_swatch", 0.2, 835, 0 );
	color_swatch_overlay = create_client_overlay_custom_size( "hud_color_swatch", 0.0, 835, 480 );
	color_swatch_overlay.color = ( getdvarfloat("color_enemy_r"), getdvarfloat("color_enemy_g"), getdvarfloat("color_enemy_b") );
	color_swatch_overlay.alignX = "left";
	color_swatch_overlay.alignY = "top";
	color_swatch_overlay.horzAlign = "fullscreen";
	color_swatch_overlay.vertAlign = "fullscreen"; 
	color_swatch_overlay.x = 0;
	color_swatch_overlay.y = 0;
	color_swatch_overlay.foreground = false;
	color_swatch_overlay.lowresbackground = true;
	color_swatch_overlay.sort = 2;
	color_swatch_overlay.hidewheninmenu = true;
	color_swatch_overlay.hidewhendead = true;

	color_swatch_overlay FadeOverTime( 0.9 );
	color_swatch_overlay.alpha = 0.2;

	//color_swatch_overlay ScaleOvertime( 0.9, 835, 480 );
	//level._player setHudNoiseEffect( 0.6, 16, 12, 0.695313, ( getdvarfloat("color_enemy_r"), getdvarfloat("color_enemy_g"), getdvarfloat("color_enemy_b") ) );

	level._player playsound("threat_id_enabled");

	level.threat_grid_overlay_tl = create_client_overlay_custom_size( "threat_detection_grid", 0, 427, 240 );
	level.threat_grid_overlay_tl.alignX = "right";
	level.threat_grid_overlay_tl.alignY = "bottom";
	level.threat_grid_overlay_tl.horzAlign = "center";
	level.threat_grid_overlay_tl.vertAlign = "middle"; 
	level.threat_grid_overlay_tl.x = 0;
	level.threat_grid_overlay_tl.y = 0;
	level.threat_grid_overlay_tl.foreground = false;
	level.threat_grid_overlay_tl.lowresbackground = true;
	level.threat_grid_overlay_tl.sort = 1;
	level.threat_grid_overlay_tl.hidewheninmenu = true;
	level.threat_grid_overlay_tl.hidewhendead = true;

	level.threat_grid_overlay_tr = create_client_overlay_custom_size( "threat_detection_grid", 0, 427, 240 );
	level.threat_grid_overlay_tr.alignX = "left";
	level.threat_grid_overlay_tr.alignY = "bottom";
	level.threat_grid_overlay_tr.horzAlign = "center";
	level.threat_grid_overlay_tr.vertAlign = "middle"; 
	level.threat_grid_overlay_tr.x = 0;
	level.threat_grid_overlay_tr.y = 0;
	level.threat_grid_overlay_tr.foreground = false;
	level.threat_grid_overlay_tr.lowresbackground = true;
	level.threat_grid_overlay_tr.sort = 1;
	level.threat_grid_overlay_tr.hidewheninmenu = true;
	level.threat_grid_overlay_tr.hidewhendead = true;

	level.threat_grid_overlay_bl = create_client_overlay_custom_size( "threat_detection_grid", 0, 427, 240 );
	level.threat_grid_overlay_bl.alignX = "right";
	level.threat_grid_overlay_bl.alignY = "top";
	level.threat_grid_overlay_bl.horzAlign = "center";
	level.threat_grid_overlay_bl.vertAlign = "middle"; 
	level.threat_grid_overlay_bl.x = 0;
	level.threat_grid_overlay_bl.y = 0;
	level.threat_grid_overlay_bl.foreground = false;
	level.threat_grid_overlay_bl.lowresbackground = true;
	level.threat_grid_overlay_bl.sort = 1;
	level.threat_grid_overlay_bl.hidewheninmenu = true;
	level.threat_grid_overlay_bl.hidewhendead = true;

	level.threat_grid_overlay_br = create_client_overlay_custom_size( "threat_detection_grid", 0, 427, 240 );
	level.threat_grid_overlay_br.alignX = "left";
	level.threat_grid_overlay_br.alignY = "top";
	level.threat_grid_overlay_br.horzAlign = "center";
	level.threat_grid_overlay_br.vertAlign = "middle"; 
	level.threat_grid_overlay_br.x = 0;
	level.threat_grid_overlay_br.y = 0;
	level.threat_grid_overlay_br.foreground = false;
	level.threat_grid_overlay_br.lowresbackground = true;
	level.threat_grid_overlay_br.sort = 1;
	level.threat_grid_overlay_br.hidewheninmenu = true;
	level.threat_grid_overlay_br.hidewhendead = true;

	loading_bar_width = 85;
	loading_bar_height = 11;
	xPos = 165;
	yPos = 20;

	loading_text = newClientHudElem( level._player );
	loading_text.color = ( getdvarfloat("color_enemy_r"), getdvarfloat("color_enemy_g"), getdvarfloat("color_enemy_b") );
	loading_text.alpha = 1;
	loading_text.font = "fwmed";
	loading_text.fontscale = 1.5;
	loading_text.label = &"SCRIPT_THREATID_LOADING";
	loading_text.alignX = "left";
	loading_text.alignY = "middle";
	loading_text.horzAlign = "right_adjustable";
	loading_text.vertAlign = "top_adjustable"; 
	loading_text.x = ( -1 * xPos );
	loading_text.y = yPos;
	loading_text.foreground = true;
	loading_text.sort = 1;
	loading_text.layer = "visor";
	loading_text.hidewheninmenu = true;
	loading_text.hidewhendead = true;

	loading_bar_frame = create_client_overlay_custom_size( "hud_loading_bar_frame", 1, loading_bar_width, loading_bar_height );
	loading_bar_frame.color = ( getdvarfloat("color_enemy_r"), getdvarfloat("color_enemy_g"), getdvarfloat("color_enemy_b") );
	loading_bar_frame.alignX = "right";
	loading_bar_frame.alignY = "middle";
	loading_bar_frame.horzAlign = "right_adjustable";
	loading_bar_frame.vertAlign = "top_adjustable"; 
	loading_bar_frame.x = -5;
	loading_bar_frame.y = yPos;
	loading_bar_frame.layer = "visor";
	loading_bar_frame.hidewheninmenu = true;
	loading_bar_frame.hidewhendead = true;

	loading_bar = create_client_overlay_custom_size( "hud_loading_bar", 1, loading_bar_width, loading_bar_height );
	loading_bar.color = ( getdvarfloat("color_enemy_r"), getdvarfloat("color_enemy_g"), getdvarfloat("color_enemy_b") );
	loading_bar.alignX = "left";
	loading_bar.alignY = "middle";
	loading_bar.horzAlign = "right_adjustable";
	loading_bar.vertAlign = "top_adjustable"; 
	loading_bar.x = ( -1 * loading_bar_width ) - 5;
	loading_bar.y = yPos;
	loading_bar.layer = "visor";
	loading_bar.hidewheninmenu = true;
	loading_bar.hidewhendead = true;

	percent = 0;
	while ( percent < 100 )
	{
		width = int( ( percent / 100 ) * loading_bar_width );
		loading_bar setshader( "hud_loading_bar", width, loading_bar_height );
		percent += randomintrange( 3, 9 );
		wait 0.05;
	}

	loading_bar setshader( "hud_loading_bar", loading_bar_width, loading_bar_height );
	waittillframeend;

	loading_text Fadeovertime( 0.5 );
	loading_bar Fadeovertime( 0.5 );
	loading_bar_frame Fadeovertime( 0.5 );
	color_swatch_overlay Fadeovertime( 0.5 );

	// Set color back to default over time
	wipe_rgb_default = ( 0.5, 0.6, 0.9 );
	wipe_a_default = 0.2;
	thread lerp_threatID_wipe_color( wipe_rgb_default, wipe_a_default, 0.5 );

	loading_text.alpha = 0;
	loading_bar.alpha = 0;
	loading_bar_frame.alpha = 0;
	color_swatch_overlay.alpha = 0;

	level._player notify( "threat_id_done_loading" );

	wait 0.2;

	if ( IsDefined( level.threat_grid_overlay_tl ) )
	{
		level.threat_grid_overlay_tl FadeOvertime( 0.2 );
		level.threat_grid_overlay_tl.alpha = 1;
	}

	if ( IsDefined( level.threat_grid_overlay_tr ) )
	{
		level.threat_grid_overlay_tr FadeOvertime( 0.2 );
		level.threat_grid_overlay_tr.alpha = 1;
	}

	if ( IsDefined( level.threat_grid_overlay_bl ) )
	{
		level.threat_grid_overlay_bl FadeOvertime( 0.2 );
		level.threat_grid_overlay_bl.alpha = 1;
	}

	if ( IsDefined( level.threat_grid_overlay_br ) )
	{
		level.threat_grid_overlay_br FadeOvertime( 0.2 );
		level.threat_grid_overlay_br.alpha = 1;
	}

	wait 0.3;

	level._player setHudNoiseEffect( 0.0, 16, 12, 0.695313 );
	loading_text Destroy();
	loading_bar Destroy();
	loading_bar_frame Destroy();
	color_swatch_overlay Destroy();

	level.threat_id_bracket = create_client_overlay_custom_size( "hud_tid_bracket", 1, 32, 32 );
	level.threat_id_bracket.color = ( getdvarfloat("color_enemy_r"), getdvarfloat("color_enemy_g"), getdvarfloat("color_enemy_b") );
	level.threat_id_bracket.alignX = "right";
	level.threat_id_bracket.alignY = "top";
	level.threat_id_bracket.horzAlign = "right_adjustable";
	level.threat_id_bracket.vertAlign = "top_adjustable"; 
	level.threat_id_bracket.x = 0;
	level.threat_id_bracket.y = 0;
	level.threat_id_bracket.layer = "visor";
	level.threat_id_bracket.hidewheninmenu = true;
	level.threat_id_bracket.hidewhendead = true;

	level.threatid_active_text = newClientHudElem( level._player );
	level.threatid_active_text.color = ( getdvarfloat("color_enemy_r"), getdvarfloat("color_enemy_g"), getdvarfloat("color_enemy_b") );
	level.threatid_active_text.alpha = 0;
	level.threatid_active_text.font = "fwmed";
	level.threatid_active_text.fontscale = 1.5;
	level.threatid_active_text.label = &"SCRIPT_THREATID_ACTIVE";
	level.threatid_active_text.alignX = "left";
	level.threatid_active_text.alignY = "middle";
	level.threatid_active_text.horzAlign = "right_adjustable";
	level.threatid_active_text.vertAlign = "top_adjustable"; 
	level.threatid_active_text.x = ( -1 * xPos );
	level.threatid_active_text.y = yPos;
	level.threatid_active_text.foreground = true;
	level.threatid_active_text.sort = 1;
	level.threatid_active_text.layer = "visor";
	level.threatid_active_text.hidewheninmenu = true;
	level.threatid_active_text.hidewhendead = true;

	level.threatid_active_text FadeOvertime( 0.5 );
	level.threatid_active_text.alpha = 1;

	level.threat_id_bracket FadeOvertime( 0.5 );
	level.threat_id_bracket.alpha = 1;

	wait 0.5;

	scanning_text = newClientHudElem( level._player );
	scanning_text.color = ( getdvarfloat("color_enemy_r"), getdvarfloat("color_enemy_g"), getdvarfloat("color_enemy_b") );
	scanning_text.alpha = 1;
	scanning_text.font = "fwmed";
	scanning_text.fontscale = 1.0;
	scanning_text SetText( &"SCRIPT_THREATID_SCANNING" );
	scanning_text.alignX = "left";
	scanning_text.alignY = "middle";
	scanning_text.horzAlign = "right_adjustable";
	scanning_text.vertAlign = "top_adjustable"; 
	scanning_text.x = ( -1 * xPos );
	scanning_text.y = yPos + 13;
	scanning_text.foreground = true;
	scanning_text.sort = 1;
	scanning_text.layer = "visor";
	scanning_text.hidewheninmenu = true;
	scanning_text.hidewhendead = true;
	scanning_text SetPulseFX( 40, 2000, 600 );

	wait 1.0;

	scanning_text FadeOvertime( 0.5 );
	scanning_text.alpha = 0;

	wait 0.5;

	scanning_text Destroy();

	level._player setActiveThreatCount( 0 );

	level.active_threat_text = newClientHudElem( level._player );
	level.active_threat_text.color = ( getdvarfloat("color_enemy_r"), getdvarfloat("color_enemy_g"), getdvarfloat("color_enemy_b") );
	level.active_threat_text.alpha = 1;
	level.active_threat_text.font = "fwmed";
	level.active_threat_text.fontscale = 1.0;
	level.active_threat_text SetText( &"SCRIPT_THREATID_ACTIVE_THREATS" );
	level.active_threat_text.alignX = "left";
	level.active_threat_text.alignY = "middle";
	level.active_threat_text.horzAlign = "right_adjustable";
	level.active_threat_text.vertAlign = "top_adjustable"; 
	level.active_threat_text.x = ( -1 * xPos );
	level.active_threat_text.y = yPos + 13;
	level.active_threat_text.foreground = true;
	level.active_threat_text.sort = 1;
	level.active_threat_text.layer = "visor";
	level.active_threat_text.hidewheninmenu = true;
	level.active_threat_text.hidewhendead = true;
	level.active_threat_text SetPulseFX( 40, 2000, 60 );

	wait 1.0;

	level.active_threat_text Destroy();

	level.active_threat_text = newClientHudElem( level._player );
	level.active_threat_text.color = ( getdvarfloat("color_enemy_r"), getdvarfloat("color_enemy_g"), getdvarfloat("color_enemy_b") );
	level.active_threat_text.alpha = 1;
	level.active_threat_text.font = "fwmed";
	level.active_threat_text.fontscale = 1.0;
	level.active_threat_text SetText( &"SCRIPT_THREATID_ACTIVE_THREATS" );
	level.active_threat_text.alignX = "left";
	level.active_threat_text.alignY = "middle";
	level.active_threat_text.horzAlign = "right_adjustable";
	level.active_threat_text.vertAlign = "top_adjustable"; 
	level.active_threat_text.x = ( -1 * xPos );
	level.active_threat_text.y = yPos + 13;
	level.active_threat_text.foreground = true;
	level.active_threat_text.sort = 1;
	level.active_threat_text.layer = "visor";
	level.active_threat_text.hidewheninmenu = true;
	level.active_threat_text.hidewhendead = true;
}

disable_threat_id_overlay()
{
	level notify( "threat_id_destroy" );

	level._player playsound("threat_id_disabled");

	fade_out_time = 0.3;

	if ( isDefined( level.threat_grid_overlay_tl ) )
	{
		level.threat_grid_overlay_tl FadeOvertime( fade_out_time );
		level.threat_grid_overlay_tl.alpha = 0;
	}

	if ( isDefined( level.threat_grid_overlay_tr ) )
	{
		level.threat_grid_overlay_tr FadeOvertime( fade_out_time );
		level.threat_grid_overlay_tr.alpha = 0;
	}

	if ( isDefined( level.threat_grid_overlay_bl ) )
	{
		level.threat_grid_overlay_bl FadeOvertime( fade_out_time );
		level.threat_grid_overlay_bl.alpha = 0;
	}

	if ( isDefined( level.threat_grid_overlay_br ) )
	{
		level.threat_grid_overlay_br FadeOvertime( fade_out_time );
		level.threat_grid_overlay_br.alpha = 0;
	}

	if ( isDefined( level.active_threat_text ) )
	{
		level.active_threat_text FadeOvertime( fade_out_time );
		level.active_threat_text.alpha = 0;
	}

	if ( isDefined( level.threat_id_bracket ) )
	{
		level.threat_id_bracket FadeOvertime( fade_out_time );
		level.threat_id_bracket.alpha = 0;
	}

	if ( isDefined( level.threatid_active_text ) )
	{
		level.threatid_active_text FadeOvertime( fade_out_time );
		level.threatid_active_text.alpha = 0;
	}

	wait fade_out_time;

	if ( IsDefined( level.threat_grid_overlay_tl ) )
	{
		level.threat_grid_overlay_tl Destroy();
	}

	if ( IsDefined( level.threat_grid_overlay_tr ) )
	{
		level.threat_grid_overlay_tr Destroy();
	}

	if ( IsDefined( level.threat_grid_overlay_bl ) )
	{
		level.threat_grid_overlay_bl Destroy();
	}

	if ( IsDefined( level.threat_grid_overlay_br ) )
	{
		level.threat_grid_overlay_br Destroy();
	}

	if ( IsDefined( level.active_threat_text ) )
	{
		level.active_threat_text Destroy();
	}

	if ( IsDefined( level.threatid_active_text ) )
	{
		level.threatid_active_text Destroy();
	}

	if ( IsDefined( level.threat_id_bracket ) )
	{
		level.threat_id_bracket Destroy();
	}
}