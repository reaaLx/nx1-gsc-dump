// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
/*QUAKED actor_nx_opfor_ec_lab_smg (1.0 0.25 0.0) (-16 -16 0) (16 16 72) SPAWNER FORCESPAWN UNDELETABLE PERFECTENEMYINFO DONTSHAREENEMYINFO
defaultmdl="nx_ec_lab_body_a"
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
	self.secondaryweapon = "m9";
	self.sidearm = "m9";
	self.grenadeWeapon = "flash_grenade";
	self.grenadeAmmo = 2;

	if ( isAI( self ) )
	{
		self setEngagementMinDist( 256.000000, 0.000000 );
		self setEngagementMaxDist( 768.000000, 1024.000000 );
	}

	self.weapon = "mpx";

	character\nx_character_ec_lab::main();
}

spawner()
{
	self setspawnerteam("axis");
}

precache()
{
	character\nx_character_ec_lab::precache();

	precacheItem("mpx");
	precacheItem("m9");
	precacheItem("m9");
	precacheItem("flash_grenade");
}
