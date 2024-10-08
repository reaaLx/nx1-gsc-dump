// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
/*QUAKED actor_nx_opfor_china_specops_ar (1.0 0.25 0.0) (-16 -16 0) (16 16 72) SPAWNER FORCESPAWN UNDELETABLE PERFECTENEMYINFO DONTSHAREENEMYINFO
defaultmdl="nx_china_specops_body_assault_a"
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
	self.grenadeWeapon = "fraggrenade";
	self.grenadeAmmo = 2;

	if ( isAI( self ) )
	{
		self setEngagementMinDist( 256.000000, 0.000000 );
		self setEngagementMaxDist( 768.000000, 1024.000000 );
	}

	self.weapon = "asmk27_reflex";

	character\nx_character_china_specops_assault_a::main();
}

spawner()
{
	self setspawnerteam("axis");
}

precache()
{
	character\nx_character_china_specops_assault_a::precache();

	precacheItem("asmk27_reflex");
	precacheItem("m9");
	precacheItem("m9");
	precacheItem("fraggrenade");
}
