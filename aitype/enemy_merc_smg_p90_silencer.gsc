// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
/*QUAKED actor_enemy_merc_SMG_p90_silencer (1.0 0.25 0.0) (-16 -16 0) (16 16 72) SPAWNER FORCESPAWN UNDELETABLE PERFECTENEMYINFO DONTSHAREENEMYINFO
defaultmdl="body_complete_sp_spetsnaz_boris"
"count" -- max AI to ever spawn from this spawner
SPAWNER -- makes this a spawner instead of a guy
FORCESPAWN -- will try to delete an AI if spawning fails from too many AI
UNDELETABLE -- this AI (or AI spawned from here) cannot be deleted to make room for FORCESPAWN guys
PERFECTENEMYINFO -- this AI when spawned will get a snapshot of perfect info about all enemies
DONTSHAREENEMYINFO -- do not get shared info about enemies at spawn time from teammates
*/
main()
{
	self.animTree = "";
	self.additionalAssets = "";
	self.team = "axis";
	self.type = "human";
	self.subclass = "regular";
	self.accuracy = 0.2;
	self.health = 150;
	self.secondaryweapon = "beretta";
	self.sidearm = "beretta";
	self.grenadeWeapon = "fraggrenade";
	self.grenadeAmmo = 0;

	if ( isAI( self ) )
	{
		self setEngagementMinDist( 128.000000, 0.000000 );
		self setEngagementMaxDist( 512.000000, 768.000000 );
	}

	self.weapon = "p90_silencer";

	switch( codescripts\character::get_random_character(7) )
	{
	case 0:
		character\character_sp_spetsnaz_boris::main();
		break;
	case 1:
		character\character_sp_spetsnaz_demetry::main();
		break;
	case 2:
		character\character_sp_spetsnaz_vlad::main();
		break;
	case 3:
		character\character_sp_spetsnaz_yuri::main();
		break;
	case 4:
		character\character_sp_spetsnaz_collins::main();
		break;
	case 5:
		character\character_sp_spetsnaz_geoff::main();
		break;
	case 6:
		character\character_sp_spetsnaz_derik::main();
		break;
	}
}

spawner()
{
	self setspawnerteam("axis");
}

precache()
{
	character\character_sp_spetsnaz_boris::precache();
	character\character_sp_spetsnaz_demetry::precache();
	character\character_sp_spetsnaz_vlad::precache();
	character\character_sp_spetsnaz_yuri::precache();
	character\character_sp_spetsnaz_collins::precache();
	character\character_sp_spetsnaz_geoff::precache();
	character\character_sp_spetsnaz_derik::precache();

	precacheItem("p90_silencer");
	precacheItem("beretta");
	precacheItem("beretta");
	precacheItem("fraggrenade");
}
