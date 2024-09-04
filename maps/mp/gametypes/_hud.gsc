// Edge relative placement values for rect->h_align and rect->v_align
#define HORIZONTAL_ALIGN_SUBLEFT		0	// left edge of a 4:3 screen (safe area not included)
#define HORIZONTAL_ALIGN_LEFT			1	// left viewable (safe area) edge
#define HORIZONTAL_ALIGN_CENTER			2	// center of the screen (reticle)
#define HORIZONTAL_ALIGN_RIGHT			3	// right viewable (safe area) edge
#define HORIZONTAL_ALIGN_FULLSCREEN		4	// disregards safe area
#define HORIZONTAL_ALIGN_NOSCALE		5	// uses exact parameters - neither adjusts for safe area nor scales for screen size
#define HORIZONTAL_ALIGN_TO640			6	// scales a real-screen resolution x down into the 0 - 640 range
#define HORIZONTAL_ALIGN_CENTER_SAFEAREA 7	// center of the safearea
#define HORIZONTAL_ALIGN_MAX			HORIZONTAL_ALIGN_CENTER_SAFEAREA
#define HORIZONTAL_ALIGN_DEFAULT		HORIZONTAL_ALIGN_SUBLEFT

#define VERTICAL_ALIGN_SUBTOP			0	// top edge of the 4:3 screen (safe area not included)
#define VERTICAL_ALIGN_TOP				1	// top viewable (safe area) edge
#define VERTICAL_ALIGN_CENTER			2	// center of the screen (reticle)
#define VERTICAL_ALIGN_BOTTOM			3	// bottom viewable (safe area) edge
#define VERTICAL_ALIGN_FULLSCREEN		4	// disregards safe area
#define VERTICAL_ALIGN_NOSCALE			5	// uses exact parameters - neither adjusts for safe area nor scales for screen size
#define VERTICAL_ALIGN_TO480			6	// scales a real-screen resolution y down into the 0 - 480 range
#define VERTICAL_ALIGN_CENTER_SAFEAREA	7	// center of the save area
#define VERTICAL_ALIGN_MAX				VERTICAL_ALIGN_CENTER_SAFEAREA
#define VERTICAL_ALIGN_DEFAULT			VERTICAL_ALIGN_SUBTOP

static const char *g_he_font[] =
{
	"default",		// HE_FONT_DEFAULT
	"bigfixed",		// HE_FONT_BIGFIXED
	"smallfixed",	// HE_FONT_SMALLFIXED
	"objective",	// HE_FONT_OBJECTIVE
};


// These values correspond to the defines in q_shared.h
static const char *g_he_alignx[] =
{
	"left",   // HE_ALIGN_LEFT
	"center", // HE_ALIGN_CENTER
	"right",  // HE_ALIGN_RIGHT
};


static const char *g_he_aligny[] =
{
	"top",    // HE_ALIGN_TOP
	"middle", // HE_ALIGN_MIDDLE
	"bottom", // HE_ALIGN_BOTTOM
};


// These values correspond to the defines in menudefinition.h
static const char *g_he_horzalign[] =
{
	"subleft",			// HORIZONTAL_ALIGN_SUBLEFT
	"left",				// HORIZONTAL_ALIGN_LEFT
	"center",			// HORIZONTAL_ALIGN_CENTER
	"right",			// HORIZONTAL_ALIGN_RIGHT
	"fullscreen",		// HORIZONTAL_ALIGN_FULLSCREEN
	"noscale",			// HORIZONTAL_ALIGN_NOSCALE
	"alignto640",		// HORIZONTAL_ALIGN_TO640
	"center_safearea",	// HORIZONTAL_ALIGN_CENTER_SAFEAREA
};
cassert( ARRAY_COUNT( g_he_horzalign ) == HORIZONTAL_ALIGN_MAX + 1 );


static const char *g_he_vertalign[] =
{
	"subtop",			// VERTICAL_ALIGN_SUBTOP
	"top",				// VERTICAL_ALIGN_TOP
	"middle",			// VERTICAL_ALIGN_CENTER
	"bottom",			// VERTICAL_ALIGN_BOTTOM
	"fullscreen",		// VERTICAL_ALIGN_FULLSCREEN
	"noscale",			// VERTICAL_ALIGN_NOSCALE
	"alignto480",		// VERTICAL_ALIGN_TO480
	"center_safearea",	// VERTICAL_ALIGN_CENTER_SAFEAREA
};
cassert( ARRAY_COUNT( g_he_vertalign ) == VERTICAL_ALIGN_MAX + 1 );
*/

init()
{
	precacheShader( "progress_bar_bg" );
	precacheShader( "progress_bar_fg" );
	precacheShader( "progress_bar_fill" );
	
	level._uiParent = spawnstruct();
	level._uiParent.horzAlign = "left";
	level._uiParent.vertAlign = "top";
	level._uiParent.alignX = "left";
	level._uiParent.alignY = "top";
	level._uiParent.x = 0;
	level._uiParent.y = 0;
	level._uiParent.width = 0;
	level._uiParent.height = 0;
	level._uiParent.children = [];
	
	level._fontHeight = 12;
	
	level._hud["allies"] = spawnstruct();
	level._hud["axis"] = spawnstruct();
	
	// we can, of course, separate out the following constants for splitscreen.	
	// primary progress bars are for things like capturing flags or planting bombs - big, important things that happen as you play a gametype
	level._primaryProgressBarY = -61; // from center
	level._primaryProgressBarX = 0;
	level._primaryProgressBarHeight = 9; //28; // this is the height and width of the whole progress bar, including the outline. the part that actually moves is 2 pixels smaller.
	level._primaryProgressBarWidth = 120;
	level._primaryProgressBarTextY = -75;
	level._primaryProgressBarTextX = 0;
	level._primaryProgressBarFontSize = .6; // 1.4 before font change from "objective"
	
	level._teamProgressBarY = 32; // 205;
	level._teamProgressBarHeight = 14;
	level._teamProgressBarWidth = 192;
	level._teamProgressBarTextY = 8; // 155;
	level._teamProgressBarFontSize = 1.65;

	if ( level._splitscreen )
	{
		level._lowerTextYAlign = "BOTTOM";
		level._lowerTextY = -76;
		level._lowerTextFontSize = 1.14;
	}
	else
	{
		level._lowerTextYAlign = "CENTER";
		level._lowerTextY = 70;
		level._lowerTextFontSize = 1.6;
	}
}


fontPulseInit( maxFontScale )
{
	self.baseFontScale = self.fontScale;
	if ( isDefined( maxFontScale ) )
		self.maxFontScale = min( maxFontScale, 6.3 );
	else
		self.maxFontScale = min( self.fontScale * 2, 6.3 );
	self.inFrames = 2;
	self.outFrames = 4;
}


fontPulse(player)
{
	self notify ( "fontPulse" );
	self endon ( "fontPulse" );
	self endon( "death" );
	
	player endon("disconnect");
	player endon("joined_team");
	player endon("joined_spectators");
	
	self ChangeFontScaleOverTime( self.inFrames * 0.05 );
	self.fontScale = self.maxFontScale;	
	wait self.inFrames * 0.05;
	
	self ChangeFontScaleOverTime( self.outFrames * 0.05 );
	self.fontScale = self.baseFontScale;
}