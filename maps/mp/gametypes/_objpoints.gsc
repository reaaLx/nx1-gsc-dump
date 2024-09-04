#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	precacheShader("objpoint_default");

	level._objPointNames = [];
	level._objPoints = [];
	
	if ( level._splitscreen )
		level._objPointSize = 15;
	else
		level._objPointSize = 8;
	
	level._objpoint_alpha_default = .5;
	level._objPointScale = 1.0;
}


createTeamObjpoint( name, origin, team, shader, alpha, scale )
{
	if( !level._multiteambased )
	{
		assert( team == "axis" || team == "allies" || team == "all" );
	}
	
	objPoint = getObjPointByName( name );
	
	if ( isDefined( objPoint ) )
		deleteObjPoint( objPoint );
	
	if ( !isDefined( shader ) )
		shader = "objpoint_default";

	if ( !isDefined( scale ) )
		scale = 1.0;
		
	if ( team != "all" )
		objPoint = newTeamHudElem( team );
	else
		objPoint = newHudElem();
	
	objPoint.name = name;
	objPoint.x = origin[0];
	objPoint.y = origin[1];
	objPoint.z = origin[2];
	objPoint.team = team;
	objPoint.isFlashing = false;
	objPoint.isShown = true;
	
	objPoint setShader( shader, level._objPointSize, level._objPointSize );
	objPoint setWaypoint( true, false );
	
	if ( isDefined( alpha ) )
		objPoint.alpha = alpha;
	else
		objPoint.alpha = level._objpoint_alpha_default;
	objPoint.baseAlpha = objPoint.alpha;
		
	objPoint.index = level._objPointNames.size;
	level._objPoints[name] = objPoint;
	level._objPointNames[level._objPointNames.size] = name;
	
	return objPoint;
}


deleteObjPoint( oldObjPoint )
{
	assert( level._objPoints.size == level._objPointNames.size );
	
	if ( level._objPoints.size == 1 )
	{
		assert( level._objPointNames[0] == oldObjPoint.name );
		assert( isDefined( level._objPoints[oldObjPoint.name] ) );
		
		level._objPoints = [];
		level._objPointNames = [];
		oldObjPoint destroy();
		return;
	}
	
	newIndex = oldObjPoint.index;
	oldIndex = (level._objPointNames.size - 1);
	
	objPoint = getObjPointByIndex( oldIndex );
	level._objPointNames[newIndex] = objPoint.name;
	objPoint.index = newIndex;
	
	level._objPointNames[oldIndex] = undefined;
	level._objPoints[oldObjPoint.name] = undefined;
	
	oldObjPoint destroy();
}


updateOrigin( origin )
{
	if ( self.x != origin[0] )
		self.x = origin[0];

	if ( self.y != origin[1] )
		self.y = origin[1];

	if ( self.z != origin[2] )
		self.z = origin[2];
}


setOriginByName( name, origin )
{
	objPoint = getObjPointByName( name );
	objPoint updateOrigin( origin );
}


getObjPointByName( name )
{
	if ( isDefined( level._objPoints[name] ) )
		return level._objPoints[name];
	else
		return undefined;
}

getObjPointByIndex( index )
{
	if ( isDefined( level._objPointNames[index] ) )
		return level._objPoints[level._objPointNames[index]];
	else
		return undefined;
}

startFlashing()
{
	self endon("stop_flashing_thread");
	
	if ( self.isFlashing )
		return;
	
	self.isFlashing = true;
	
	while ( self.isFlashing )
	{
		self fadeOverTime( 0.75 );
		self.alpha = 0.35 * self.baseAlpha;
		wait ( 0.75 );
		
		self fadeOverTime( 0.75 );
		self.alpha = self.baseAlpha;
		wait ( 0.75 );
	}
	
	self.alpha = self.baseAlpha;
}

stopFlashing()
{
	if ( !self.isFlashing )
		return;

	self.isFlashing = false;
}