#include common_scripts\utility;
#include common_scripts\_atbr;

ATBR_KILLSTREAK_AMMO_COUNT = 3;

//*******************************************************************
//																	*
//																	*
//*******************************************************************
atbr_init()
{	
	level._killstreakFuncs["atbr"] = ::atbr_give;
	
	level._atbr_callback_set_targets = ::atbr_set_targets;
	level._atbr_callback_remove_targets = ::atbr_remove_targets;
	
	// Weapons. 
	level._atbr_weapons = [];
	level._atbr_weapons["base"] = "atbr_base_mp";
 	level._atbr_weapons["detonate"] = "atbr_detonate_mp";
 	level._atbr_weapons["missile"] = "atbr_missile_mp";
 	level._atbr_weapons["bullet"] = "atbr_bullet_mp";
 	
 	level._atbr_ammo_count = ATBR_KILLSTREAK_AMMO_COUNT;
	
	common_scripts\_atbr::atbr_common_init();
}



//*******************************************************************
//																	*
//																	*
//*******************************************************************
atbr_give( lifeId )
{
	//self endon ( "death" );
	
	common_scripts\_atbr::atbr_common_give();
	
	self waittill_any( "atbr_complete", "death" );		//self waittill( "atbr_complete" );
	
	foreach( weapon in level._atbr_weapons )
	{
	 	self TakeWeapon( weapon );
	}
	
	return true;
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************
atbr_set_targets( missile )
{
	println( "mp set targets" );
	//TagZP<NOTE> FOF = Friend or Foe
	self ThermalVisionFOFOverlayOn();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
atbr_remove_targets()
{
	println( "atbr remove targets" );
	self ThermalVisionFOFOverlayOff();
}