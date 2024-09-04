#include common_scripts\utility;

artStartVisionFileExport()
{
	fileprint_launcher_start_file();
}

artEndVisionFileExport()
{
	return fileprint_launcher_end_file( "\\share\\raw\\vision\\"+level._script+ ".vision", true );
}

artStartFogFileExport()
{
	fileprint_launcher_start_file();

}

artEndFogFileExport()
{
	return	fileprint_launcher_end_file( "\\share\\raw\\maps\\createart\\"+level._script+ "_art.gsc", true );
}

artCommonfxprintln( string )
{
	fileprint_launcher( string );
}


setfogsliders()
{
	/#
	fogcolor = getdvarvector( "g_fogColorReadOnly" );
	maxOpacity = GetDvar( "g_fogMaxOpacityReadOnly" );
	halfplane = GetDvar( "g_fogHalfDistReadOnly" );
	nearplane = GetDvar( "g_fogStartDistReadOnly" );

	sunFogEnabled = GetDvar( "g_sunFogEnabledReadOnly" );
	sunFogColor = getdvarvector( "g_sunFogColorReadOnly" );
	sunFogDir = getdvarvector( "g_sunFogDirReadOnly" );
	sunFogBeginFadeAngle = GetDvar( "g_sunFogBeginFadeAngleReadOnly" );
	sunFogEndFadeAngle = GetDvar( "g_sunFogEndFadeAngleReadOnly" );
	sunFogScale = GetDvar( "g_sunFogScaleReadOnly" );
	
	mulFogBlend = GetDvar( "g_mulFogBlendReadOnly" );
	mulFogNearColor = GetDvar( "g_mulFogNearColorReadOnly" );
	mulFogFarColor = GetDvar( "g_mulFogFarColorReadOnly" );

	if ( !isdefined( mulFogBlend )
		 || !isdefined( mulFogNearColor )
		 || !isdefined( mulFogFarColor )
		 )
	{
		mulFogBlend = 0.0;
		mulFogNearColor = ( 1, 1, 1 );
		mulFogFarColor = ( 1, 1, 1 );
	}

	if ( !isdefined( fogcolor )
		 || !isdefined( maxOpacity )
		 || !isdefined( halfplane )
		 || !isdefined( nearplane )
		 || !isdefined( sunFogEnabled )
		 || !isdefined( sunFogColor )
		 || !isdefined( sunFogDir )
		 || !isdefined( sunFogBeginFadeAngle )
		 || !isdefined( sunFogEndFadeAngle )
		 || !isdefined( sunFogScale )
		 )
	{
		fogcolor = ( 1, 1, 1 );
		halfplane = 10000001;
		nearplane = 10000000;
		maxOpacity = 1;

		sunFogEnabled = false;
		sunFogColor = ( 1, 1, 1 );
		sunFogDir = ( 1.0, 0.0, 0.0 );
		sunFogBeginFadeAngle = GetDvar( "g_sunFogBeginFadeAngle" );
		sunFogEndFadeAngle = GetDvar( "g_sunFogEndFadeAngle" );
		sunFogScale = GetDvar( "g_sunFogScaleReadOnly" );

	}

	SetDevDvar( "scr_fog_exp_halfplane", halfplane );
	SetDevDvar( "scr_fog_nearplane", nearplane );
	SetDevDvar( "scr_fog_color", fogcolor );
	SetDevDvar( "scr_fog_max_opacity", maxOpacity );

	SetDevDvar( "scr_sunFogEnabled", sunFogEnabled );
	SetDevDvar( "scr_sunFogColor", sunFogColor );
	SetDevDvar( "scr_sunFogDir", sunFogDir );
	SetDevDvar( "scr_sunFogBeginFadeAngle", sunFogBeginFadeAngle );
	SetDevDvar( "scr_sunFogEndFadeAngle", sunFogEndFadeAngle );
	SetDevDvar( "scr_sunFogScale", sunFogScale );

	SetDevDvar( "scr_mulFogBlend", mulFogBlend );
	SetDevDvar( "scr_mulFogNearColor", mulFogNearColor );
	SetDevDvar( "scr_mulFogFarColor", mulFogFarColor );
	#/
}


translateFogSlidersToScript()
{
	level._fogexphalfplane = GetDvarFloat( "scr_fog_exp_halfplane" );
	level._fognearplane = GetDvarFloat( "scr_fog_nearplane" );
	level._fogcolor = getdvarvector( "scr_fog_color" );
	level._fogmaxopacity = GetDvarFloat( "scr_fog_max_opacity" );

	level._sunFogEnabled = GetDvarInt( "scr_sunFogEnabled" );
	level._sunFogColor = getdvarvector( "scr_sunFogColor" );
	level._sunFogDir = getdvarvector( "scr_sunFogDir" );
	level._sunFogBeginFadeAngle = GetDvarFloat( "scr_sunFogBeginFadeAngle" );
	level._sunFogEndFadeAngle = GetDvarFloat( "scr_sunFogEndFadeAngle" );
	level._sunFogScale = GetDvarFloat( "scr_sunFogScale" );

	level._mulFogBlend = GetDvarFloat( "scr_mulFogBlend" );
	level._mulFogNearColor = getdvarvector( "scr_mulFogNearColor" );
	level._mulFogFarColor = getdvarvector( "scr_mulFogFarColor" );
}


updateFogFromScript()
{
	/#
	if ( GetDvarInt( "scr_cmd_plr_sun" ) )
	{
		SetDevDvar( "scr_sunFogDir", AnglesToForward( level._player GetPlayerAngles() ) );
		SetDevDvar( "scr_cmd_plr_sun", 0 );
	}

	#/

	if ( ! GetDvarInt( "scr_fog_disable" ) )
	{
		if ( level._sunFogEnabled )
			SetExpFog(	level._fognearplane, level._fogexphalfplane, level._fogcolor[ 0 ], level._fogcolor[ 1 ], level._fogcolor[ 2 ], level._fogmaxopacity, 0,
						level._mulFogBlend, 0, level._mulFogNearColor[ 0 ], level._mulFogNearColor[ 1 ], level._mulFogNearColor[ 2 ], level._mulFogFarColor[ 0 ], level._mulFogFarColor[ 1 ], level._mulFogFarColor[ 2 ],
						level._sunFogColor[ 0 ], level._sunFogColor[ 1 ], level._sunFogColor[ 2 ], level._sunFogDir, level._sunFogBeginFadeAngle, level._sunFogEndFadeAngle, level._sunFogScale );
		else
			SetExpFog(	level._fognearplane, level._fogexphalfplane, level._fogcolor[ 0 ], level._fogcolor[ 1 ], level._fogcolor[ 2 ], level._fogmaxopacity, 0, 
   						level._mulFogBlend, 0, level._mulFogNearColor[ 0 ], level._mulFogNearColor[ 1 ], level._mulFogNearColor[ 2 ], level._mulFogFarColor[ 0 ], level._mulFogFarColor[ 1 ], level._mulFogFarColor[ 2 ] );
	}
	else
	{		       
		SetExpFog( 1000000000, 1000000001, 0, 0, 0, 0, 0 );// couldn't find discreet fog disabling other than to never set it in the first place
	}
}


artfxprintlnFog()
{
	fileprint_launcher( "" );
	fileprint_launcher( "\t//* Fog section * " );
	fileprint_launcher( "" );

	fileprint_launcher( "\tsetDevDvar( \"scr_fog_disable\"" + ", " + "\"" + GetDvarInt( "scr_fog_disable" ) + "\"" + " );" );

	fileprint_launcher( "" );
	if ( ! GetDvarInt( "scr_fog_disable" ) )
	{
		if ( level._sunFogEnabled )
			fileprint_launcher( "\tsetExpFog( " + level._fognearplane + ", " + level._fogexphalfplane + ", " + level._fogcolor[0] + ", " + level._fogcolor[1] + ", " + level._fogcolor[2] + ", " + level._fogmaxopacity + ", 0, " + 
								level._mulFogBlend + ", 0, " + level._mulFogNearColor[0] + ", " + level._mulFogNearColor[1] + ", " + level._mulFogNearColor[2] + ", " + level._mulFogFarColor[0] + ", " + level._mulFogFarColor[1] + ", " + level._mulFogFarColor[2] + ", " +
								level._sunFogColor[0] + ", " + level._sunFogColor[1] + ", " + level._sunFogColor[2] + ", (" + level._sunFogDir[0] + ", " + level._sunFogDir[1] + ", " + level._sunFogDir[2] + "), " + level._sunFogBeginFadeAngle + ", " + level._sunFogEndFadeAngle + ", " + level._sunFogScale + " );" );
		else
			fileprint_launcher( "\tsetExpFog( " + level._fognearplane + ", " + level._fogexphalfplane + ", " + level._fogcolor[0] + ", " + level._fogcolor[1] + ", " + level._fogcolor[2] + ", " + level._fogmaxopacity + ", 0, " + 
								level._mulFogBlend + ", 0, " + level._mulFogNearColor[0] + ", " + level._mulFogNearColor[1] + ", " + level._mulFogNearColor[2] + ", " + level._mulFogFarColor[0] + ", " + level._mulFogFarColor[1] + ", " + level._mulFogFarColor[2] + ");" );
	}
}