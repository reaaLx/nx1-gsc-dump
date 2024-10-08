#include maps\_utility;
#include common_scripts\utility;
#using_animtree( "generic_human" );

init()
{
	// drone type specific stuff
	level._drone_anims[ "neutral" ][ "stand" ][ "idle" ]		= %casual_stand_idle;
	level._drone_anims[ "neutral" ][ "stand" ][ "run" ]	 		= %unarmed_scared_run;
	level._drone_anims[ "neutral" ][ "stand" ][ "death" ]	 	= %exposed_death;
	
	level._attachPropsFunction = animscripts\civilian\civilian_init_common::attachProps;
	
	// init the generic drone script
	maps\_drone::initGlobals();
}