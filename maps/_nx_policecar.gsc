#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type )
{
	//SNDFILE=vehicle_coupe_car
	build_template( "policecar", model, type );
	build_localinit( ::init_local );
	
	build_destructible( "nx_vehicle_exfil_policecar", "nx_vehicle_exfil_policecar" );
	
	//build_deathmodel( "nx_vehicle_exfil_policecar", "nx_vehicle_exfil_policecar_destroy" );
	
	build_drive( %technical_driving_idle_forward, %technical_driving_idle_backward, 10 );

	build_treadfx();
	build_life( 1700, 1500, 1900 );
	build_team( "allies" );
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_compassicon( "automobile", false );

    //police car fx/////
	level._effect[ "police_headlight_l" ]		= loadfx( "nx/lights/nx_exfil_car_headlight_l_01" );
	level._effect[ "police_headlight_r" ]		= loadfx( "nx/lights/nx_exfil_car_headlight_r_01" );
	level._effect[ "police_headlight_light" ]	= loadfx( "nx/lights/nx_exfil_car_headlight_02" );
	level._effect[ "police_light_blue" ]		= loadfx( "nx/misc/nx_copcar_light_blue_loop_01" );
	////////////////////////
	
	build_light( model, "coplight_headlight_l",  "TAG_LIGHT_LEFT_FRONT", "nx/lights/nx_exfil_car_headlight_l_01",     "headlight_l",     0.1 );
    build_light( model, "coplight_headlight_r",  "TAG_LIGHT_RIGHT_FRONT", "nx/lights/nx_exfil_car_headlight_l_01",     "headlight_r",     0.0 );
	build_light( model, "police_headlight_light", "TAG_LIGHT_RIGHT_FRONT", "nx/lights/nx_exfil_car_headlight_02",   "headlight_light",     0.1 );
}

init_local()
{
	//maps\_vehicle::lights_on( "headlight_l" );
	//maps\_vehicle::lights_on( "headlight_r" );
	//maps\_vehicle::lights_on( "headlight_light" );
	thread headlights();
	thread coplights();
}

//MO EDIT: Nate told me to put this in here ( from _uaz.gsc )
set_vehicle_anims( positions )
{


		positions[ 0 ].vehicle_getoutanim = %nx_vh_exfil_policecar_driver_door_open;
		positions[ 1 ].vehicle_getoutanim = %uaz_driver_exit_into_stand_door;
		

		positions[ 0 ].vehicle_getoutanim_clear = false;
		positions[ 1 ].vehicle_getoutanim_clear = false;
		
		//positions[ 0 ].vehicle_getinanim = %uaz_passenger_enter_from_huntedrun_door;
		//positions[ 1 ].vehicle_getinanim = %uaz_driver_enter_from_huntedrun_door;
		

		//positions[ 0 ].vehicle_getinsound = "truck_door_open";
		//positions[ 1 ].vehicle_getinsound = "truck_door_open";
		

		return positions;
}


#using_animtree( "generic_human" );
//MO EDIT: Nate told me to put this in here ( from _uaz.gsc )
setanims()
{

	positions = [];
	for ( i = 0;i < 2;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_passenger";
	positions[ 1 ].sittag = "tag_driver";

	positions[ 0 ].idle = %nx_tp_exfil_policecar_driver_idle;
	positions[ 1 ].idle = %uaz_driver_idle_drive;


	positions[ 0 ].getout = %nx_tp_exfil_policecar_driver_dismount;
	positions[ 1 ].getout = %uaz_driver_exit_into_stand;

	//positions[ 0 ].getin = %uaz_passenger_enter_from_huntedrun;
	//positions[ 1 ].getin = %uaz_driver_enter_from_huntedrun;



	return positions;


}

headlights()
{
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_headlight_l" ), self, "TAG_light_left_front" );
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_headlight_r" ), self, "TAG_light_right_front" );

	//apm: disabling till i figure out why it does not always kill the fx 
	/*
	self endon( "turn_off_headlight" );
	self endon( "death" );
	self endon( "explode" );

	//self endon( "exploded" );	
	ent_flag_init( "lights" );	
	ent_flag_set( "lights" );
	for ( ;; )
	{
		ent_flag_wait( "lights" );
		common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_headlight_l" ), self, "TAG_light_left_front" );
		common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_headlight_r" ), self, "TAG_light_right_front" );
		ent_flag_waitopen( "lights" );
		stopFXontag( getfx( "police_headlight_l" ), self, "TAG_light_left_front" );
		stopFXontag( getfx( "police_headlight_r" ), self, "TAG_light_right_front" );
	}
	*/
}

coplights()
{

	wait RandomFloatRange( 0.1, 0.9 );
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue" ), self, "TAG_FX_LIGHT_01" );
	wait (0.2);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue" ), self, "TAG_FX_LIGHT_02" );
	wait (0.2);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue" ), self, "TAG_FX_LIGHT_03" );
	wait (0.2);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue" ), self, "TAG_FX_LIGHT_04" );
	wait (0.2);
	common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue" ), self, "TAG_FX_LIGHT_05" );

	/*
	self endon( "turn_off_coplight" );
	self endon( "death" );
	self endon( "explode" );

	ent_flag_init( "cop_lights" );	
	ent_flag_set( "cop_lights" );
	for ( ;; )
	{
		ent_flag_wait( "cop_lights" );
			wait RandomFloatRange( 0.1, 0.9 );
			common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue" ), self, "TAG_FX_LIGHT_01" );
			wait (0.2);
			common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue" ), self, "TAG_FX_LIGHT_02" );
			wait (0.2);
			common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue" ), self, "TAG_FX_LIGHT_03" );
			wait (0.2);
			common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue" ), self, "TAG_FX_LIGHT_04" );
			wait (0.2);
			common_scripts\_destructible::PlayFxOnTag_KillOnDestructibleSwap( getfx( "police_light_blue" ), self, "TAG_FX_LIGHT_05" );

		ent_flag_waitopen( "cop_lights" );
			stopFXontag( getfx( "police_light_blue" ), self, "TAG_FX_LIGHT_01" );
			wait (0.01);
			stopFXontag( getfx( "police_light_blue" ), self, "TAG_FX_LIGHT_02" );
			wait (0.01);
			stopFXontag( getfx( "police_light_blue" ), self, "TAG_FX_LIGHT_03" );
			wait (0.01);
			stopFXontag( getfx( "police_light_blue" ), self, "TAG_FX_LIGHT_04" );
			wait (0.01);
			stopFXontag( getfx( "police_light_blue" ), self, "TAG_FX_LIGHT_05" );
	}
	*/
}

/*QUAKED script_vehicle_nx_exfil_policecar (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_policecar::main( "nx_vehicle_exfil_policecar" );


include,nx_vehicle_exfil_policecar
include,nx_destructible_vehicle_exfil_policecar_destructible
sound,vehicle_policecar_lapd,vehicle_standard,all_sp
sound,vehicle_car_exp,vehicle_standard,all_sp

defaultmdl="nx_vehicle_exfil_policecar"
default:"vehicletype" "policecar"
default:"script_team" "axis"
*/
