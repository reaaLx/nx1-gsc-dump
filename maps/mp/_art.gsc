// This function should take care of grain and glow settings for each map, plus anything else that artists 
// need to be able to tweak without bothering level designers.
#include common_scripts\utility;
#include common_scripts\_artCommon;

main()
{
	/#
	setDevDvarIfUninitialized( "scr_art_tweak", 0 );
	setDevDvarIfUninitialized( "scr_dof_enable", "1" );
	setDevDvarIfUninitialized( "scr_cmd_plr_sun", "0" );
	setDevDvarIfUninitialized( "scr_cinematic_autofocus", "1" );
	setDevDvarIfUninitialized( "scr_art_visionfile", level._script );

	if ( !isDefined( level._dofDefault ) )
	{
		level._dofDefault[ "nearStart" ] = 0;
		level._dofDefault[ "nearEnd" ] = 1;
		level._dofDefault[ "farStart" ] = 8000;
		level._dofDefault[ "farEnd" ] = 10000;
		level._dofDefault[ "nearBlur" ] = 6;
		level._dofDefault[ "farBlur" ] = 0;
	}

	level._curDoF = ( level._dofDefault[ "farStart" ] - level._dofDefault[ "nearEnd" ] ) / 2;

	thread tweakart();

	if ( !isdefined( level._script ) )
		level._script = ToLower( GetDvar( "mapname" ) );
	#/
}

tweakart()
{
	/#
	if ( !isdefined( level._tweakfile ) )
		level._tweakfile = false;

	// not in DEVGUI
	SetDevDvar( "scr_fog_fraction", "1.0" );
	SetDevDvar( "scr_art_dump", "0" );

	// update the devgui variables to current settings
	SetDevDvar( "scr_dof_nearStart", level._dofDefault[ "nearStart" ] );
	SetDevDvar( "scr_dof_nearEnd", level._dofDefault[ "nearEnd" ] );
	SetDevDvar( "scr_dof_farStart", level._dofDefault[ "farStart" ] );
	SetDevDvar( "scr_dof_farEnd", level._dofDefault[ "farEnd" ] );
	SetDevDvar( "scr_dof_nearBlur", level._dofDefault[ "nearBlur" ] );
	SetDevDvar( "scr_dof_farBlur", level._dofDefault[ "farBlur" ] );

	// not in DEVGUI
	level._fogfraction = 1.0;

	file = undefined;
	filename = undefined;

	for ( ;; )
	{
		while ( GetDvarInt( "scr_art_tweak", 0 ) == 0 )
		{
			AssertEx( GetDvarInt( "scr_art_dump", 0 ) == 0, "Must Enable Art Tweaks to export _art file." );
			wait .05;
			if ( ! GetDvarInt( "scr_art_tweak", 0 ) == 0 )
				common_scripts\_artCommon::setfogsliders();// sets the sliders to whatever the current fog value is
		}


		if ( GetDvarInt( "scr_art_tweak_message" ) )
		{
			SetDevDvar( "scr_art_tweak_message", "0" );
			IPrintLnBold( "ART TWEAK ENABLED" );
		}

		//translate the slider values to script variables
		common_scripts\_artCommon::translateFogSlidersToScript();

//		dofvarupdate();

		// catch all those cases where a slider can be pushed to a place of conflict
		fovslidercheck();

		dump = dumpsettings();// dumps and returns true if the dump dvar is set

		common_scripts\_artCommon::updateFogFromScript();

//		level.player setDefaultDepthOfField();
		if ( dump )
		{
			IPrintLnBold( "Art settings dumped success!" );
			SetdevDvar( "scr_art_dump", "0" );
 		}
		wait .1;
	}
	#/
}

fovslidercheck()
{
	/#
	// catch all those cases where a slider can be pushed to a place of conflict
	if ( level._dofDefault[ "nearStart" ] >= level._dofDefault[ "nearEnd" ] )
	{
		level._dofDefault[ "nearStart" ] = level._dofDefault[ "nearEnd" ] - 1;
		SetDevDvar( "scr_dof_nearStart", level._dofDefault[ "nearStart" ] );
	}
	if ( level._dofDefault[ "nearEnd" ] <= level._dofDefault[ "nearStart" ] )
	{
		level._dofDefault[ "nearEnd" ] = level._dofDefault[ "nearStart" ] + 1;
		SetDevDvar( "scr_dof_nearEnd", level._dofDefault[ "nearEnd" ] );
	}
	if ( level._dofDefault[ "farStart" ] >= level._dofDefault[ "farEnd" ] )
	{
		level._dofDefault[ "farStart" ] = level._dofDefault[ "farEnd" ] - 1;
		SetDevDvar( "scr_dof_farStart", level._dofDefault[ "farStart" ] );
	}
	if ( level._dofDefault[ "farEnd" ] <= level._dofDefault[ "farStart" ] )
	{
		level._dofDefault[ "farEnd" ] = level._dofDefault[ "farStart" ] + 1;
		SetDevDvar( "scr_dof_farEnd", level._dofDefault[ "farEnd" ] );
	}
	if ( level._dofDefault[ "farBlur" ] >= level._dofDefault[ "nearBlur" ] )
	{
		level._dofDefault[ "farBlur" ] = level._dofDefault[ "nearBlur" ] - .1;
		SetDevDvar( "scr_dof_farBlur", level._dofDefault[ "farBlur" ] );
	}
	if ( level._dofDefault[ "farStart" ] <= level._dofDefault[ "nearEnd" ] )
	{
		level._dofDefault[ "farStart" ] = level._dofDefault[ "nearEnd" ] + 1;
		SetDevDvar( "scr_dof_farStart", level._dofDefault[ "farStart" ] );
	}
	#/
}

dumpsettings()
{
	/#
	if ( GetDvarInt( "scr_art_dump" ) == 0 )
		return false;

	filename = "createart/" + GetDvar( "scr_art_visionfile" ) + "_art.gsc";

	artStartFogFileExport();
	fileprint_launcher( "// _createart generated.  modify at your own risk. Changing values should be fine." );
	fileprint_launcher( "main()" );
	fileprint_launcher( "{" );

	fileprint_launcher( "" );
	fileprint_launcher( "\tlevel.tweakfile = true;" );
	fileprint_launcher( " " );

	artfxprintlnFog();
	fileprint_launcher( "\tVisionSetNaked( \"" + level._script + "\", 0 );" );

	fileprint_launcher( "" );
	fileprint_launcher( "}" );
	artEndFogFileExport();

	visionFilename = "vision/" + GetDvar( "scr_art_visionfile" ) + ".vision";

	artStartVisionFileExport();

	fileprint_launcher( "r_glow                    \"" + GetDvar( "r_glowTweakEnable" ) + "\"" );
	fileprint_launcher( "r_glowRadius0             \"" + GetDvar( "r_glowTweakRadius0" ) + "\"" );
	fileprint_launcher( "r_glowBloomCutoff         \"" + GetDvar( "r_glowTweakBloomCutoff" ) + "\"" );
	fileprint_launcher( "r_glowBloomDesaturation   \"" + GetDvar( "r_glowTweakBloomDesaturation" ) + "\"" );
	fileprint_launcher( "r_glowBloomIntensity0     \"" + GetDvar( "r_glowTweakBloomIntensity0" ) + "\"" );
	fileprint_launcher( " " );
	fileprint_launcher( "r_filmEnable              \"" + GetDvar( "r_filmTweakEnable" ) + "\"" );
	fileprint_launcher( "r_filmContrast            \"" + GetDvar( "r_filmTweakContrast" ) + "\"" );
	fileprint_launcher( "r_filmBrightness          \"" + GetDvar( "r_filmTweakBrightness" ) + "\"" );
	fileprint_launcher( "r_filmDesaturation        \"" + GetDvar( "r_filmTweakDesaturation" ) + "\"" );
	fileprint_launcher( "r_filmDesaturationDark    \"" + GetDvar( "r_filmTweakDesaturationDark" ) + "\"" );
	fileprint_launcher( "r_filmInvert              \"" + GetDvar( "r_filmTweakInvert" ) + "\"" );
	fileprint_launcher( "r_filmLightTint           \"" + GetDvar( "r_filmTweakLightTint" ) + "\"" );
	fileprint_launcher( "r_filmMediumTint          \"" + GetDvar( "r_filmTweakMediumTint" ) + "\"" );
	fileprint_launcher( "r_filmDarkTint            \"" + GetDvar( "r_filmTweakDarkTint" ) + "\"" );
	fileprint_launcher( " " );
	fileprint_launcher( "r_primaryLightUseTweaks              \"" + GetDvar( "r_primaryLightUseTweaks" ) + "\"" );
	fileprint_launcher( "r_primaryLightTweakDiffuseStrength   \"" + GetDvar( "r_primaryLightTweakDiffuseStrength" ) + "\"" );
	fileprint_launcher( "r_primaryLightTweakSpecularStrength  \"" + GetDvar( "r_primaryLightTweakSpecularStrength" ) + "\"" );

	if ( ! artEndVisionFileExport() )
		return false;

	IPrintLnBold( "ART DUMPED SUCCESSFULLY" );
	return true;
	#/
}