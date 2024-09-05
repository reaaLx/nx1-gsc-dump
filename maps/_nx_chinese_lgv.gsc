/*QUAKED script_vehicle_nx_ec_chinese_lgv (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER


maps\_nx_chinese_lgv::main("nx_vehicle_chinese_lgv","nx_chinese_lgv");


include,nx_vehicle_chinese_lgv

defaultmdl="nx_vehicle_chinese_lgv"
default:"vehicletype" "nx_chinese_lgv"
default:"script_team" "axis"
*/

#include common_scripts\utility;
#include maps\_utility;
#include maps\_vehicle;
#include maps\_vehicle_aianim;
#include maps\_anim;
#using_animtree( "vehicles" );

TAG_MOUNT_OFFSET = 25;

main( model, type )
{
	build_template( "nx_chinese_lgv", model, type );
	build_localinit( ::init_local );
	build_life( 99999, 99998, 99999 );
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_drive( %nx_vh_chinese_lgv_movement,%nx_vh_chinese_lgv_movement_backwards, 5 );
	build_unload_groups( ::unload_groups );
	build_spawn_callback( ::turret_spawn_callback );

	build_treadfx( "nx_chinese_lgv" );

	build_turret(	"nx_chinese_lgv_turret",
					"TAG_Turret",
					"nx_vehicle_chinese_lgv_main_turret",
					undefined,
					"auto_ai",
					0.2,
					15,//there is a bug in the turret code, this value is actually half way the real pitch should be.
					-14 );

	build_light( model, "headlight",	"TAG_BODY",	"nx/misc/nx_chinese_lgv_headlight",	"running",	0.0 );
	
	level._effect[ "nx_chinese_lgv_turret_steam" ]					= LoadFX( "nx/misc/nx_chinese_lgv_turret_steam" );
	level._effect[ "nx_chinese_lgv_turret_steam_muzzle" ]			= LoadFX( "nx/misc/nx_chinese_lgv_turret_steam_muzzle" );

	turret_precache();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************
init_local()
{
}

set_vehicle_anims( positions )
{		
	positions[ 0 ].vehicle_getoutanim = %nx_vh_chinese_lgv_door_open;
	/*
	positions[ 0 ].vehicle_getoutanim_clear = true;
	positions[ 2 ].vehicle_getoutanim_clear = true;
	positions[ 3 ].vehicle_getoutanim_clear = true;
	positions[ 4 ].vehicle_getoutanim_clear = true;
	positions[ 5 ].vehicle_getoutanim_clear = true;
	positions[ 6 ].vehicle_getoutanim_clear = true;
	positions[ 7 ].vehicle_getoutanim_clear = true;
	positions[ 8 ].vehicle_getoutanim_clear = true;
	positions[ 9 ].vehicle_getoutanim_clear = true;
	*/
	return positions;
	
}


//*******************************************************************
//																	*
//																	*
//*******************************************************************
#using_animtree( "generic_human" );
setanims()
{
	positions = [];
	for ( i = 0;i < 11;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_gunner";
	positions[ 2 ].sittag = "tag_guy1";
	positions[ 3 ].sittag = "tag_guy2";
	positions[ 4 ].sittag = "tag_guy3";
	positions[ 5 ].sittag = "tag_guy4";
	positions[ 6 ].sittag = "tag_guy5";
	positions[ 7 ].sittag = "tag_guy6";
	positions[ 8 ].sittag = "tag_guy7";
	positions[ 9 ].sittag = "tag_guy8";
	positions[ 10 ].sittag = "tag_guy9";
	
	positions[ 0 ].idle = %nx_tp_chinese_lgv_driver_idle;
	positions[ 1 ].idle = %nx_tp_chinese_lgv_gunner_idle;
	positions[ 2 ].idle = %nx_tp_chinese_lgv_guy1_idle;
	positions[ 3 ].idle = %nx_tp_chinese_lgv_guy2_idle;
	positions[ 4 ].idle = %nx_tp_chinese_lgv_guy3_idle;
	positions[ 5 ].idle = %nx_tp_chinese_lgv_guy4_idle;
	positions[ 6 ].idle = %nx_tp_chinese_lgv_guy5_idle;
	positions[ 7 ].idle = %nx_tp_chinese_lgv_guy6_idle;
	positions[ 8 ].idle = %nx_tp_chinese_lgv_guy7_idle;
	positions[ 9 ].idle = %nx_tp_chinese_lgv_guy7_idle;
	positions[ 10 ].idle = %nx_tp_chinese_lgv_guy7_idle;

	positions[ 0 ].getin = %humvee_driver_climb_in;
	positions[ 1 ].getin = %nx_tp_chinese_lgv_gunner_mount;
	positions[ 2 ].getin = %humvee_passenger_in_L;
	positions[ 3 ].getin = %humvee_passenger_in_L;
	positions[ 4 ].getin = %humvee_passenger_in_L;
	positions[ 5 ].getin = %humvee_passenger_in_L;
	positions[ 6 ].getin = %humvee_passenger_in_L;
	positions[ 7 ].getin = %humvee_passenger_in_L;
	positions[ 8 ].getin = %humvee_passenger_in_L;
	positions[ 9 ].getin = %humvee_passenger_in_L;

	positions[ 0 ].getout = %nx_tp_chinese_lgv_driver_getout;
	positions[ 1 ].getout = %nx_tp_chinese_lgv_gunner_getout;
	positions[ 2 ].getout = %nx_tp_chinese_lgv_guy1_getout;
	positions[ 3 ].getout = %nx_tp_chinese_lgv_guy2_getout;
	positions[ 4 ].getout = %nx_tp_chinese_lgv_guy3_getout;
	positions[ 5 ].getout = %nx_tp_chinese_lgv_guy4_getout;
	positions[ 6 ].getout = %nx_tp_chinese_lgv_guy5_getout;
	positions[ 7 ].getout = %nx_tp_chinese_lgv_guy6_getout;
	positions[ 8 ].getout = %nx_tp_chinese_lgv_guy7_getout;
	positions[ 9 ].getout = %nx_tp_chinese_lgv_guy7_getout;
	positions[ 10 ].getout = %nx_tp_chinese_lgv_guy7_getout;

	positions[ 0 ].death = %nx_tp_chinese_lgv_driver_death;
	positions[ 1 ].death = %nx_tp_chinese_lgv_gunner_death;
	positions[ 2 ].death = %nx_tp_chinese_lgv_guy1_death;
	positions[ 3 ].death = %nx_tp_chinese_lgv_guy2_death;
	positions[ 4 ].death = %nx_tp_chinese_lgv_guy3_death;
	positions[ 5 ].death = %nx_tp_chinese_lgv_guy4_death;
	positions[ 6 ].death = %nx_tp_chinese_lgv_guy5_death;
	positions[ 7 ].death = %nx_tp_chinese_lgv_guy6_death;
	positions[ 8 ].death = %nx_tp_chinese_lgv_guy7_death;
	positions[ 9 ].death = %nx_tp_chinese_lgv_guy7_death;
	positions[ 10 ].death = %nx_tp_chinese_lgv_guy7_death;
	
	positions[ 0 ].exit_allow_death = true;
	positions[ 1 ].exit_allow_death = true;
	positions[ 2 ].exit_allow_death = true;
	positions[ 3 ].exit_allow_death = true;
	positions[ 4 ].exit_allow_death = true;
	positions[ 5 ].exit_allow_death = true;
	positions[ 6 ].exit_allow_death = true;
	positions[ 7 ].exit_allow_death = true;
	positions[ 8 ].exit_allow_death = true;
	positions[ 9 ].exit_allow_death = true;
	positions[ 10 ].exit_allow_death = true;

	positions[ 0 ].exit_death_ragdoll_immediate = true;
	positions[ 1 ].exit_death_ragdoll_immediate = true;
	positions[ 2 ].exit_death_ragdoll_immediate = true;
	positions[ 3 ].exit_death_ragdoll_immediate = true;
	positions[ 4 ].exit_death_ragdoll_immediate = true;
	positions[ 5 ].exit_death_ragdoll_immediate = true;
	positions[ 6 ].exit_death_ragdoll_immediate = true;
	positions[ 7 ].exit_death_ragdoll_immediate = true;
	positions[ 8 ].exit_death_ragdoll_immediate = true;
	positions[ 9 ].exit_death_ragdoll_immediate = true;
	positions[ 10 ].exit_death_ragdoll_immediate = true;




	positions[ 0 ].death_no_ragdoll = true;
	positions[ 1 ].death_no_ragdoll = true;
	positions[ 2 ].death_no_ragdoll = true;
	positions[ 3 ].death_no_ragdoll = true;
	positions[ 4 ].death_no_ragdoll = true;
	positions[ 5 ].death_no_ragdoll = true;
	positions[ 6 ].death_no_ragdoll = true;
	positions[ 7 ].death_no_ragdoll = true;
	positions[ 8 ].death_no_ragdoll = true;
	positions[ 9 ].death_no_ragdoll = true;
	positions[ 10 ].death_no_ragdoll = true;


	//positions[ 1 ].turret_fire = %humvee_turret_fire;
	positions[ 1 ].mgturret = 0;// which of the turrets is this guy going to use


	return positions;

}

unload_groups()
{
	unload_groups = [];
	unload_groups[ "passengers" ] = [];
	unload_groups[ "all_but_gunner_and_driver" ] = [];
	unload_groups[ "all" ] = [];
	unload_groups[ "gunner" ] = [];

	group = "passengers";
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ group ][ unload_groups[ group ].size ] = 4;
	unload_groups[ group ][ unload_groups[ group ].size ] = 5;
	unload_groups[ group ][ unload_groups[ group ].size ] = 6;
	unload_groups[ group ][ unload_groups[ group ].size ] = 7;
	unload_groups[ group ][ unload_groups[ group ].size ] = 8;
	unload_groups[ group ][ unload_groups[ group ].size ] = 9;
	unload_groups[ group ][ unload_groups[ group ].size ] = 10;

	group = "all_but_gunner_and_driver";
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ group ][ unload_groups[ group ].size ] = 4;
	unload_groups[ group ][ unload_groups[ group ].size ] = 5;
	unload_groups[ group ][ unload_groups[ group ].size ] = 6;
	unload_groups[ group ][ unload_groups[ group ].size ] = 7;
	unload_groups[ group ][ unload_groups[ group ].size ] = 8;
	unload_groups[ group ][ unload_groups[ group ].size ] = 9;
	unload_groups[ group ][ unload_groups[ group ].size ] = 10;


	group = "all";
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ group ][ unload_groups[ group ].size ] = 4;
	unload_groups[ group ][ unload_groups[ group ].size ] = 5;
	unload_groups[ group ][ unload_groups[ group ].size ] = 6;
	unload_groups[ group ][ unload_groups[ group ].size ] = 7;
	unload_groups[ group ][ unload_groups[ group ].size ] = 8;
	unload_groups[ group ][ unload_groups[ group ].size ] = 9;
	unload_groups[ group ][ unload_groups[ group ].size ] = 10;

	group = "gunner";
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;

	unload_groups[ "default" ] = unload_groups[ "passengers" ];

	return unload_groups;
}


/////////////////////////////////////////////////////////////////////////
//////////////////// Player Turret Usage Scripts ////////////////////////
/////////////////////////////////////////////////////////////////////////

#using_animtree( "player" );
turret_player_anims()
{
	level._scr_animtree[ "player_rig" ] 					 = #animtree;
	level._scr_model[ "player_rig" ] 						 = "viewhands_us_lunar_scripted";
	level._scr_anim[ "player_rig" ][ "player_getin" ] 		 = %nx_fp_roverturret_mount;
	level._scr_anim[ "player_rig" ][ "player_getout" ] 		 = %nx_fp_roverturret_dismount;
}

#using_animtree( "vehicles" );
turret_vehicle_anims()
{
	//animation to be played on the turret in the same scene as the hands. 
	level._scr_anim[ "turret" ][ "player_getin" ]			= %nx_chinese_lgv_turret_mount;
	level._scr_animtree[ "turret" ]							= #animtree;
	
	//animation of the hands on the turret.
	maps\_ec_lunar_turret::turret_vehicle_anims();
}

turret_precache()
{
	PreCacheModel( "viewmodel_chinese_lgv_main_turret" );
	PreCacheModel( "viewhands_us_lunar_scripted" ); 

	//anims associated with mounting the turret.
	turret_player_anims();
	turret_vehicle_anims();
}

turret_spawn_callback( vehicle )
{
	vehicle endon( "death" );
	
	vehicle turret_make_usable();
}

turret_make_usable()
{
	turret = self.mgturret[ 0 ];
	turret.player_mounting = false;

	//Add in the hint.
	mount = Spawn( "script_model", ( 0, 0, 0 ) );
	//mount SetModel( mount_model ); //TagCC<NOTE>: Need a new turret model
	mount LinkTo( self, "TAG_PLAYER_TURRET_MOUNT", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	mount MakeUsable();
	// Press and hold^3 &&1 ^7to board.
	mount SetHintString( &"NX_VEHICLES_TURRET_MOUNT" );
	
	self.mount = mount;
	
	self thread watch_mountable();
	self thread watch_mount();

	turret.animname = "turret";
	turret assign_animtree();
	self anim_first_frame_solo( turret, "player_getin", "TAG_PLAYER_TURRET_MOUNT" );
}

watch_mountable()
{
	self endon( "death" );
	
	turret = self.mgturret[ 0 ];
	
	assert( IsDefined(self.mount) );
	
	fov = cos(Float(GetDvar("cg_fov")));
	
	while ( true )
	{
		being_mounted = false;
		if	( IsDefined( self.runningtovehicle ) )
		{
			being_mounted = ( self.runningtovehicle.size > 0 );		
		}
				
		//need a new origin that's moved forward...
		forward = AnglesToForward( self.angles );
		origin = self.mount.origin + forward * TAG_MOUNT_OFFSET;
		
// 		/#		
// 		debug_draw_origin( origin );
// 		#/
		
		if ( IsTurretActive( turret ) || being_mounted || !within_fov_2d(level._player.origin, level._player.angles, origin, fov) )
		{
			self.mount MakeUnusable();
		}
		else
		{
			self.mount MakeUsable();
		}
		wait 0.05;
	}
}

/#
debug_draw_origin( origin )
{
	Line( origin + ( 16, 0, 0 ), origin + ( -16, 0, 0 ), ( 1, 0, 0 ), 1, 0, 1 );
	Line( origin + ( 0, 16, 0 ), origin + ( 0, -16, 0 ), ( 0, 1, 0 ), 1, 0, 1 );
	Line( origin + ( 0, 0, 16 ), origin + ( 0, 0, -16 ), ( 0, 0, 1 ), 1, 0, 1 );
	Print3d( origin + (0, 0, 32) , "( " + origin[0] + ", " + origin[1] + ", " + origin[2] + " )", (1,1,1), 1, 1, 1 );
}
#/

watch_mount()
{
	self endon( "death" );
	
	while ( true )
	{
		self.mount waittill( "trigger" );
		self turret_make_mountable();
	}
}


//self is  the vehicle
turret_make_mountable()
{
	//self.dontdisconnectpaths = true; //TagCC<NOTE>: I don't think this is important
	//mount_model = "vehicle_hummer_seat_rb_obj";//TagCC<NOTE>: Need a new turret model
	//self HidePart( "tag_seat_rb_hide" );//TagCC<NOTE>: don't hvae this yet.
	

	/*	
	Glowing seat model:
	     Use model => ( vehicle_hummer_seat_rb_obj ) as glowing seat.  
	     I didn't set any glowing attributes for it yet, you'll have to set that
	up.
	
	To hide regular seat:
	     Use ( tag_seat_rb_hide ).
	
	To attach glowing seat to regular:  
	     Attach ( tag_seat_rb , from vehicle_hummer_seat_rb_obj) to (
	tag_seat_rb_attach )
	*/
	//self Attach( mount_model, "tag_seat_rb_attach" );
	
	turret = self.mgturret[ 0 ];
	
	turret.player_mounting = true;

//	turret delayThread( 1, ::lerp_out_drop_pitch, 1.5 );//TagCC<NOTE>: Not sure what this does..
	turret SetDefaultDropPitch( 0 );
	self turret_animate_board( turret );

	//spawn off a thread to handle the animation for the minigun.
	self thread turret_player_viewhands( turret );
}

turret_animate_board( turret )
{
	//create a player rig for the mounting vignette, but hide it for now.
	player_rig = spawn_anim_model( "player_rig" );
	player_rig LinkTo( self, "TAG_PLAYER_TURRET_MOUNT", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	player_rig Hide();

	//get the correct animation state set on the player rig so it's ready to play.
	self anim_first_frame_solo( player_rig, "player_getin", "TAG_PLAYER_TURRET_MOUNT" );

	//disable the weapons the player has, we cant let them shoot while mounting.
	level._player DisableWeapons();
	level._player notify( "mount_turret" );

	//changes the FOV over a couple seconds. Goes from 65 to 55
	self thread turret_fov_zoom_in_for_mount(); 
	
	//disallow stance changes in the vignette
	level._player SetStance( "stand" );
	level._player AllowCrouch( false );
	level._player AllowProne( false );

	//attatch the player to the player rig, and show it after a bit.
	level._player PlayerLinkToBlend( player_rig, "tag_player", 0.4, 0.2, 0.2 );
	player_rig delayCall( 0.2, ::Show );

	//player_rig delaythread( 0.0, ::play_sound_on_entity, "scn_roadkill_enter_humvee_plr" );//TagCC<NOTE>: play sound, we dont have yet.

	// Play anim. 	
	turret.animname = "turret";
	turret assign_animtree();
	guys = [];
	guys[ "player_rig" ] = player_rig;
	guys[ "turret" ] = turret;
	self anim_single( guys, "player_getin", "TAG_PLAYER_TURRET_MOUNT" );

	// Draw line test. 
	//origin = player_rig GetTagOrigin( "tag_player" );
	//Line( origin, origin + ( 0, 0, 100 ), ( 1, 1, 1 ), 1, 0, 1000 );
	//origin = turret GetTagOrigin( "tag_player" );
	//Line( origin, origin + ( 0, 0, 100 ), ( 1, 0, 0 ), 1, 0, 1000 );

	// Link to turret. 	
	turret MakeUsable();
	turret SetMode( "manual" );
	turret UseBy( level._player );
	turret SetTurretInitView( false );
	turret MakeUnusable();
	level.player_turret = turret;
	turret Show();

	wait( 0.1 );

	//once we're done with that anim, we can delete the rig.
	player_rig Delete();

	//re-enable the weapon so the player can fire, and 
	level._player EnableWeapons();

	level._player AllowCrouch( true );
	level._player AllowProne( true );

	// reset the fov
//	SetSavedDvar( "cg_fov", 65 );
}

turret_player_dismount()
{	
	//create a new player rig but hide it for now.
	player_rig = spawn_anim_model( "player_rig" );
	player_rig LinkTo( self, "TAG_PLAYER_TURRET_MOUNT", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	player_rig Hide();

	//get the player rig into the right anim state.
	self anim_first_frame_solo( player_rig, "player_getout", "TAG_PLAYER_TURRET_MOUNT" );

	//don't allow the player to use weapons.
	level._player DisableWeapons();
	level._player notify( "dismount_turret" );

	//blend the fov back over time from 55 to 65 over 2s
	self thread turret_fov_zoom_out_for_dismount(); //zoom back out.
	
	//grab the turret from the vehicle.
	turret = self.mgturret[ 0 ];
		
	turret_model = spawn( "script_model", turret GetTagOrigin( "TAG_Origin" ) );
	turret_model SetModel("nx_vehicle_chinese_lgv_main_turret");
	turret_model.angles = turret GetTagAngles( "TAG_Origin" );
	turret_model.animname = "turret";
	turret_model assign_animtree();
	
	turret Hide();
	
	//get rid of the hands, and return the model to what it was.
	turret Detach( level._scr_model[ "player_rig" ], "tag_player" );

	//disallow stances
	level._player SetStance( "stand" );
	level._player AllowCrouch( false );
	level._player AllowProne( false );

	//attatch the rig
	level._player PlayerLinkToDelta( player_rig, "tag_player", 0.35, 360, 360, 45, 30, true );
	level._player LerpViewAngleClamp( 1, 0.25, 0.25, 0, 0, 0, 0 );
	player_rig delayCall( 1.0, ::Show );
	
	drop_rotate_blend_time = 0.5;//magical number of how quickly to blend the rotation of the turret back to 0 while getting off before doing anims.
	drop_rotate_delay = 0.5;
	
	//oh god save me for this!
	turret_angles = AnglesToForward( turret GetTagAngles( "TAG_Origin" ) );
	vehicle_angles = AnglesToForward( self GetTagAngles( "TAG_Turret" ) );
	//if it's poining backward we need to stash it to the side first so the player doesnt clip through stepping off.
	if( VectorDot( turret_angles, vehicle_angles ) < 0 ) 
	{
		//but which side?
		orientation = 1;
		if( VectorDot( AnglesToRight( turret GetTagAngles( "TAG_Origin" ) ), AnglesToForward( self GetTagAngles( "TAG_Turret" ) ) ) < 0 )
		{
			orientation = 1;
		}
		else
		{
			orientation = -1;
		}
		
		turret_temp_angles = self GetTagAngles( "TAG_Origin" ) - (orientation * (0, 90, 0) );
		
		//we're going to lerp it out to the right 90 degrees first.
		turret_model lerp_out_drop_transform( turret GetTagOrigin( "TAG_Origin" ), turret_temp_angles, drop_rotate_blend_time );
		drop_rotate_delay = drop_rotate_delay + drop_rotate_blend_time; // account for the time it takes to finish the lerp. 
	}
	
	turret delayThread( 1, ::lerp_out_drop_pitch, 1.5 );
	turret_model delayThread( drop_rotate_delay, ::lerp_out_drop_transform, self GetTagOrigin( "TAG_Turret" ), self.angles + (15, 0, 0), drop_rotate_blend_time );
	//player_rig delaythread( 0.0, ::play_sound_on_entity, "scn_roadkill_enter_humvee_plr" );//TagCC<NOTE>: play sound, we dont have yet.
	
	//play the animation.
	self anim_single_solo( player_rig, "player_getout", "TAG_PLAYER_TURRET_MOUNT" );
	
	turret_model Delete();
	
	turret SetModel("nx_vehicle_chinese_lgv_main_turret");
	turret Show();	
	
	player_rig Delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

turret_fov_zoom_in_for_mount()
{
	wait( 0.1 );
	lerp_fov_overtime( 0.5, 55 );
}

turret_fov_zoom_out_for_dismount()
{
	wait( 1 );
	lerp_fov_overtime( 2, 65 );
}

#using_animtree( "vehicles" );
turret_player_viewhands( turret )
{
	turret.animname = "lunar_hands";
	turret useAnimTree( #animtree );	
	turret Attach( level._scr_model[ turret.animname ], "tag_player" );
	turret SetAnim( level._scr_anim[ turret.animname ][ "idle_L" ]	, 1, 0, 1 );
	turret SetAnim( level._scr_anim[ turret.animname ][ "idle_R" ]	, 1, 0, 1 );
	
	turret thread maps\_ec_lunar_turret::turret_player_viewhands_hand( "LEFT" );
	turret thread maps\_ec_lunar_turret::turret_player_viewhands_hand( "RIGHT" );	
	turret thread maps\_ec_lunar_turret::turret_player_viewhands_patch();

	turret thread turret_watch_for_dismount();
}

turret_cleanup()
{
	//unlink the player
	level._player Unlink();
	
	level._player EnableWeapons();
	
	level._player AllowCrouch( true );
	level._player AllowProne( true );
	
	self.player_mounting = false;
}

turret_watch_for_dismount()
{
	self endon("death");
	
	//wait just a little so they dont try to immediately dismount
	wait 0.5;
	
	while ( true )
	{
		if( level._player UseButtonPressed() )
		{
			self notify("dismount");
			self.ownervehicle turret_player_dismount();
			self turret_cleanup();
			return;
		}
		
		wait 0.05;
	}
}


lerp_out_drop_pitch( time )
{
	blend = self create_blend( ::blend_dropPitch, 0, 15 );
	blend.time = time;
}

blend_dropPitch( progress, start, end )
{
	val = start * ( 1 - progress ) + end * progress;
	self SetDefaultDropPitch( val );
}

lerp_out_drop_transform( origin, angles, time )
{
	self RotateTo( angles, time );
	self MoveTo( origin, time );
}