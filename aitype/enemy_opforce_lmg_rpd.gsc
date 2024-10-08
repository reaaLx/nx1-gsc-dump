// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
/*QUAKED actor_enemy_opforce_LMG_rpd (1.0 0.25 0.0) (-16 -16 0) (16 16 72) SPAWNER FORCESPAWN UNDELETABLE PERFECTENEMYINFO DONTSHAREENEMYINFO
defaultmdl="body_sp_opforce_b"
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
		self setEngagementMinDist( 512.000000, 400.000000 );
		self setEngagementMaxDist( 1024.000000, 1250.000000 );
	}

	switch( codescripts\character::get_random_weapon(4) )
	{
	case 0:
		self.weapon = "rpd";
		break;
	case 1:
		self.weapon = "rpd_acog";
		break;
	case 2:
		self.weapon = "rpd_grip";
		break;
	case 3:
		self.weapon = "rpd_reflex";
		break;
	}

	switch( codescripts\character::get_random_character(8) )
	{
	case 0:
		character\character_sp_opforce_b::main();
		break;
	case 1:
		character\character_sp_opforce_c::main();
		break;
	case 2:
		character\character_sp_opforce_d::main();
		break;
	case 3:
		character\character_sp_opforce_e::main();
		break;
	case 4:
		character\character_sp_opforce_f::main();
		break;
	case 5:
		character\character_sp_opforce_collins::main();
		break;
	case 6:
		character\character_sp_opforce_geoff::main();
		break;
	case 7:
		character\character_sp_opforce_derik::main();
		break;
	}
}

spawner()
{
	self setspawnerteam("axis");
}

precache()
{
	character\character_sp_opforce_b::precache();
	character\character_sp_opforce_c::precache();
	character\character_sp_opforce_d::precache();
	character\character_sp_opforce_e::precache();
	character\character_sp_opforce_f::precache();
	character\character_sp_opforce_collins::precache();
	character\character_sp_opforce_geoff::precache();
	character\character_sp_opforce_derik::precache();

	precacheItem("rpd");
	precacheItem("rpd_acog");
	precacheItem("rpd_grip");
	precacheItem("rpd_reflex");
	precacheItem("beretta");
	precacheItem("beretta");
	precacheItem("fraggrenade");
}
