// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
/*QUAKED actor_nx_opfor_china_space_breacher (1.0 0.25 0.0) (-16 -16 0) (16 16 72) SPAWNER FORCESPAWN UNDELETABLE PERFECTENEMYINFO DONTSHAREENEMYINFO
defaultmdl="nx_china_space_assault_body"
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
	self.additionalAssets = "moon_actor.csv";
	self.team = "axis";
	self.type = "human";
	self.subclass = "moon";
	self.accuracy = 0.35;
	self.health = 150;
	self.secondaryweapon = "";
	self.sidearm = "m9";
	self.grenadeWeapon = "fraggrenade";
	self.grenadeAmmo = 0;

	if ( isAI( self ) )
	{
		self setEngagementMinDist( 256.000000, 0.000000 );
		self setEngagementMaxDist( 768.000000, 1024.000000 );
	}

	self.weapon = "breacher";

	character\nx_character_china_space_assault_a::main();
}

spawner()
{
	self setspawnerteam("axis");
}

precache()
{
	character\nx_character_china_space_assault_a::precache();

	precacheItem("breacher");
	precacheItem("m9");
	precacheItem("fraggrenade");

	//----------------
	maps\_moon_actor::main();
	//----------------
}
