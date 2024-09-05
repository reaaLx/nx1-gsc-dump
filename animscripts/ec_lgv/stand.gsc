#include maps\_utility;
#include common_scripts\utility;

#using_animtree( "generic_human" );

// self = the guy using the turret
main()
{
	turret = self getTurret();
	
	self.desired_anim_pose = "stand";
	animscripts\utility::UpdateAnimPose();

	// .primaryTurretAnim is used by code so don't change this variable name
	self.primaryTurretAnim			= %LGVGunner_aim;
	
	self.additiveTurretRotateLeft	= %nx_tp_chinese_lgv_gunner_aim_2_add;
	self.additiveTurretRotateRight	= %nx_tp_chinese_lgv_gunner_aim_4_add;
	self.additiveRotateRoot			= %additive_LGVGunner_aim_leftright;

	self.additiveTurretIdle			= %nx_tp_chinese_lgv_gunner_idle;
	self.additiveTurretDriveIdle	= %nx_tp_chinese_lgv_gunner_driveidle;
	self.additiveTurretFire			= %nx_tp_chinese_lgv_gunner_fire;
	self.additiveUsegunRoot			= %additive_LGVGunner_usegun;
	
	self.turretDeathAnimRoot		= %LGVGunner_death;
	self.turretDeathAnim			= %nx_tp_chinese_lgv_gunner_death;
	self.turretPainAnims[ 0 ]		= %nx_tp_chinese_lgv_gunner_pain;

    self.turretReloadAnim			= %nx_tp_chinese_lgv_gunner_rechamber;
	
	self.turretSpecialAnimsRoot		= %LGVGunner;
	arr = [];
	arr[ "nx_tp_chinese_lgv_gunner_rechamber" ]			= %nx_tp_chinese_lgv_gunner_rechamber;
	self.turretSpecialAnims = arr;
	
	turret setup_turret_anims();

	self thread animscripts\hummer_turret\minigun_code::main( turret );

	// Setting verious parameters for LGV turret after minigun_code::main, which sets it to hummer values.

	shots_per_second = turret GetTurretShotsPerSecondAI();
	if ( shots_per_second > 0.0 )
	{
		turret.fireInterval							= 1.0 / shots_per_second;
	}
	turret.secsOfFiringBeforeReload					= 15.0;
	turret.reloadDuration							= 2.17;
	turret.centerTurretForReload					= true;
	turret.extraFireTime_min						= 0;
	turret.extraFireTime_max						= 1;
	turret.wait_duration_after_aiming_before_firing = 0.2;

	turret thread reload_fx();
}

#using_animtree( "vehicles" );
setup_turret_anims()
{
	self UseAnimTree( #animtree );
	self.passenger2turret_anime = %nx_vh_chinese_lgv_gunner_mount_turret;
	self.turret2passenger_anime = %nx_vh_chinese_lgv_gunner_getout_turret;
}

reload_fx()
{
	for (;;)
	{
		self waittill( "starting_reload" );

		playFXOnTag( level._effect[ "nx_chinese_lgv_turret_steam" ], self, "tag_origin" );
		playFXOnTag( level._effect[ "nx_chinese_lgv_turret_steam_muzzle" ], self, "tag_flash" );
	}
}
