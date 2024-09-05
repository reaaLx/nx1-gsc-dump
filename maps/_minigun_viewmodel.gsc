#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

#using_animtree( "vehicles" );
player_viewhands_minigun( turret )
{
	/*
	viewhands = spawn_anim_model( "suburban_hands", turret getTagOrigin( "tag_player" ) );
	viewhands.angles = turret getTagAngles( "tag_player" );
	viewhands linkto( turret, "tag_player" );
	
	viewhands setAnim( viewhands getanim( "idle_L" ), 1, 0, 1 );
	viewhands setAnim( viewhands getanim( "idle_R" ), 1, 0, 1 );
	
	viewhands thread player_viewhands_minigun_hand( "LEFT" );
	viewhands thread player_viewhands_minigun_hand( "RIGHT" );
	*/
	
	turret useAnimTree( #animtree );
	turret.animname = "suburban_hands";
	turret attach( "viewhands_player_us_army", "tag_player" );
	turret setAnim( %player_suburban_minigun_idle_L, 1, 0, 1 );
	turret setAnim( %player_suburban_minigun_idle_R, 1, 0, 1 );
	//turret setAnim( %player_blackhawk_minigun_turret_idle_L, 1, 0, 1 ); //change to NX version
	//turret setAnim( %player_blackhawk_minigun_turret_idle_R, 1, 0, 1 ); //change to NX version

	turret thread player_viewhands_minigun_hand( "LEFT" );
	turret thread player_viewhands_minigun_hand( "RIGHT" );
}


#using_animtree( "vehicles" );
anim_minigun_hands()
{
	level._scr_animtree[ "suburban_hands" ] 							 		= #animtree;
	level._scr_model[ "suburban_hands" ] 									    = "viewhands_player_us_army";
	level._scr_anim[ "suburban_hands" ][ "idle_L" ]						 	    = %player_suburban_minigun_idle_L;
	level._scr_anim[ "suburban_hands" ][ "idle_R" ]						 	    = %player_suburban_minigun_idle_R;
	level._scr_anim[ "suburban_hands" ][ "idle2fire_L" ]						= %player_suburban_minigun_idle2fire_L;
	level._scr_anim[ "suburban_hands" ][ "idle2fire_R" ]						= %player_suburban_minigun_idle2fire_R;
	level._scr_anim[ "suburban_hands" ][ "fire2idle_L" ]						= %player_suburban_minigun_fire2idle_L;
	level._scr_anim[ "suburban_hands" ][ "fire2idle_R" ]						= %player_suburban_minigun_fire2idle_R;
	level._scr_anim[ "suburban_hands" ][ "puton_L" ]							= %player_blackhawk_minigun_turret_hud_puton_L;
	level._scr_anim[ "suburban_hands" ][ "puton_R" ]							= %player_blackhawk_minigun_turret_hud_puton_R;
	level._scr_anim[ "suburban_hands" ][ "takeoff_L" ]							= %player_blackhawk_minigun_turret_hud_takeoff_L;
	level._scr_anim[ "suburban_hands" ][ "takeoff_R" ]							= %player_blackhawk_minigun_turret_hud_takeoff_R;
	//level._scr_anim[ "suburban_hands" ][ "idle_L" ]						 	= %player_blackhawk_minigun_turret_idle_L;        //change to NX version
	//level._scr_anim[ "suburban_hands" ][ "idle_R" ]						 	= %player_blackhawk_minigun_turret_idle_R;        //change to NX version
	//level._scr_anim[ "suburban_hands" ][ "idle2fire_L" ]						= %player_blackhawk_minigun_turret_idle2fire_L;   //change to NX version
	//level._scr_anim[ "suburban_hands" ][ "idle2fire_R" ]						= %player_blackhawk_minigun_turret_idle2fire_R;   //change to NX version
	//level._scr_anim[ "suburban_hands" ][ "fire2idle_L" ]						= %player_blackhawk_minigun_turret_fire2idle_L;   //change to NX version
	//level._scr_anim[ "suburban_hands" ][ "fire2idle_R" ]						= %player_blackhawk_minigun_turret_fire2idle_R;   //change to NX version
	
	//
	//
}

player_viewhands_minigun_hand( hand )
{
	self endon( "death" );
	checkFunc = undefined;
	if ( hand == "LEFT" )
		checkFunc = ::spinButtonPressed;
	else if ( hand == "RIGHT" )
		checkFunc = ::fireButtonPressed;
	assert( isdefined( checkFunc ) );
	
	for(;;)
	{
		if( level._player [[checkFunc]]() )
		{
			thread player_viewhands_minigun_presed( hand );
			while( level._player [[checkFunc]]() )
				wait 0.05;
		}
		else
		{
			thread player_viewhands_minigun_idle( hand );
			while( !level._player [[checkFunc]]() )
				wait 0.05;
		}
	}
}

spinButtonPressed()
{
	if ( level._player AdsButtonPressed() )
		return true;
	if ( level._player AttackButtonPressed() )
		return true;
	return false;
}

fireButtonPressed()
{
	return level._player AttackButtonPressed();
}

player_viewhands_minigun_idle( hand )
{
	animHand = undefined;
	if ( hand == "LEFT" )
		animHand = "L";
	else if ( hand == "RIGHT" )
		animHand = "R";
	assert( isdefined( animHand ) );
	
	self clearAnim( self getanim( "idle2fire_" + animHand ), 0.2 );
	self setFlaggedAnimRestart( "anim", self getanim( "fire2idle_" + animHand ) );
	self waittillmatch( "anim", "end" );
	self clearAnim( self getanim( "fire2idle_" + animHand ), 0.2 );
	self setAnim( self getanim( "idle_" + animHand ) );
}

player_viewhands_minigun_presed( hand )
{
	animHand = undefined;
	if ( hand == "LEFT" )
		animHand = "L";
	else if ( hand == "RIGHT" )
		animHand = "R";
	assert( isdefined( animHand ) );
	
	self clearAnim( self getanim( "idle_" + animHand ), 0.07 );  //made it twice faster
	self setAnim( self getanim( "idle2fire_" + animHand ) );
}