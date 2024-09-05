#include maps\_vehicle;
#include maps\_utility;
#include maps\_vehicle_aianim;
#include common_scripts\utility;
#using_animtree( "vehicles" );

main( model_override, type_override )
{
	if( !IsDefined( model_override ) )
		model = "nx_vehicle_lunar_rover";
	else
		model = model_override;

	build_template( "nx_lunar_rover", model, type_override );
	build_localinit( ::init_local );
	build_life( 99999, 99998, 99999 );

	// Dan:  Commenting out drive animation for player driven rover.
	// We can add this back in once we break out the player and non-player rover.
	build_drive( %nx_vh_lunar_rover_movement, %nx_vh_lunar_rover_movement_backwards, 5 );

	build_treadfx( "nx_lunar_rover" );

	build_light( model, "headlight_L", 		"TAG_HEADLIGHT_LEFT", 	"nx/misc/nx_lunar_rover_headlight",			"running", 	0.0 );
	build_light( model, "headlight_R", 		"TAG_HEADLIGHT_RIGHT", 	"nx/misc/nx_lunar_rover_headlight",			"running", 	0.0 );
	build_light( model, "headlight_SPOT",	"TAG_HEADLIGHT_LEFT",	"nx/misc/nx_lunar_rover_headlight_light",	"spot",		0.0 );
	build_light( model, "interiorlight",	"TAG_ORIGIN",			"nx/misc/nx_lunar_rover_interiorlight",		"interior",	0.0 );
}

get_anims()
{
	anims = [];

	//anims[ "left_arm" ]              	= %player_snowmobile_left_arm;                               
	//anims[ "drive_left_arm" ]       	= %player_snowmobile_drive_left_arm;                             
	anims[ "turn_left2right_L" ]    	= %player_snowmobile_drive_turn_left2right_L;                    
	anims[ "turn_right2left_L" ]    	= %player_snowmobile_drive_turn_right2left_L;                    
																								
	//anims[ "right_arm" ]            	= %player_snowmobile_right_arm;                                  
	anims[ "turn_left2right_R" ]    	= %player_snowmobile_drive_turn_left2right_R;                    
	anims[ "turn_right2left_R" ]    	= %player_snowmobile_drive_turn_right2left_R;                    
																								
	//anims[ "throttle_add" ]     		= %player_snowmobile_drive_throttle_add;                             
	anims[ "throttle" ]        			= %player_snowmobile_drive_throttle;                                 
																								
	//anims[ "throttle_add_left" ]    	= %player_snowmobile_drive_throttle_add_left;                    
	anims[ "throttle_left" ]        	= %player_snowmobile_drive_throttle_left;                        
																								
	//anims[ "throttle_add_right" ]   	= %player_snowmobile_drive_throttle_add_right;                   
	anims[ "throttle_right" ]       	= %player_snowmobile_drive_throttle_right;																					

	return anims;

}

init_local()
{
}

/*QUAKED script_vehicle_nx_lunar_rover (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_lunar_rover::main("nx_vehicle_lunar_rover","nx_lunar_rover");


include,_nx_lunar_rover

defaultmdl="nx_vehicle_lunar_rover"
default:"vehicletype" "nx_lunar_rover"
default:"script_team" "allies"

*/
