//TagZP<NOTE> We want this to do the same thing that the sp setup does.  If any of these commented out
//tweak values are changed move them into constatns so both sp and mp has access.

main()
{
	//gravity_scale = common_scripts\_moon::getMoonGlobalGravityScale();
	turn_scale = 1.0; //common_scripts\_moon::getMoonGlobalTurnRateScale();
	ads_yaw = common_scripts\_moon::getMoonGlobalADSYaw();
	ads_pitch = common_scripts\_moon::getMoonGlobalADSPitch();
	//moongrav = getdvarint( "player_moon_grav_scale" );

	//println( "!!!!!setting global gravity scale!!!!!!!!!!!!" );
	setdvar( "phys_global_gravity_scale", 0.25 );
	setdvar( "aim_scale_turn_rate", turn_scale );
	setdvar( "aim_turnrate_pitch_ads", ads_pitch);
	setdvar( "aim_turnrate_yaw_ads", ads_yaw);
	
	level._use_moon_gravity = true;
	
	//these values can be changed to effect the way in which the player behaves in gravity.
	//Setting values to 1.0 will make them behave like on earth. I've given them values here
	//of their defaults, ones that seemed correct for me. They will have no effect without 
	//the below call to SetMoonGravity as they are only used in the player movement code.
	//These shouldn't stay dvars, but become #define once we're happy with them.
	//setdvar( "player_moon_grav_stop_scalar", "0.20");
	//setdvar( "player_moon_grav_start_scalar", "0.20");
	//setdvar( "player_moon_grav_speed_scalar", "0.65");
	
	//These values effect the way in which the player rig behaves in moon gravity.
	//Larger vertical bob amplitude will cause the player to bob higher in their steps.
	//Larger horizontal bob amplitude will give the impression of more sway in the walk.
	//Smaller bob speeds will decrease how quickly the player rig bob cycles, not the actual movement speed.
	//They will have no effect without the below call to SetMoonGravity as they are 
	//only used in the player movement code.
	//These shouldn't stay dvars, but become #define once we're happy with them.
	//setdvar( "weapon_view_moon_vertical_bob_amp", "4.0" );
	//setdvar( "weapon_view_moon_horizontal_bob_amp", "1.5" );
	//setdvar( "weapon_view_moon_bob_speed", "0.5" );
	
	//This value effects the overall height of the jump. Adding in variable jump height, I had to suppress some of
	//jump height because it was getting too high. 
	//setdvar( "player_moon_grav_variable_jump_scalar", "0.2" );
}

init_moon_player()
{
	if( isDefined( level._use_moon_gravity ))
	{
		if( level._use_moon_gravity == true )
		{
			//println( "!!!!!setting player moon gravity!!!!!!!!!!!!" );			
			self SetMoonGravity( true );
			self EnableMoonHelmetHUD();

			maps\mp\perks\_perks::givePerk( "specialty_moonsuit" );
		}
		else
		{
			//println( "!!!!!setting player Earth gravity!!!!!!!!!!!!" );
			self SetMoonGravity( false );
			self DisableMoonHelmetHud();
		}
	}
	else
	{
		//println( "!!!!!setting player Earth gravity!!!!!!!!!!!!" );
		self SetMoonGravity( false );
		self DisableMoonHelmetHud();
	}
}