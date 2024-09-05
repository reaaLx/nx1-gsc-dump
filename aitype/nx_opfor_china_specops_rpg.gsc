// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
/*QUAKED actor_nx_opfor_china_specops_rpg (1.0 0.25 0.0) (-16 -16 0) (16 16 72) SPAWNER FORCESPAWN UNDELETABLE PERFECTENEMYINFO DONTSHAREENEMYINFO
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
	self.secondaryweapon = "asmk27_reflex";
	self.sidearm = "m9";
	self.grenadeWeapon = "fraggrenade";
	self.grenadeAmmo = 0;

	if ( isAI( self ) )
	{
		self setEngagementMinDist( 768.000000, 512.000000 );
		self setEngagementMaxDist( 1024.000000, 1500.000000 );
	}

	self.weapon = "rpgx_straight";

	character\nx_character_china_specops_assault_a::main();
}

spawner()
{
	self setspawnerteam("axis");
}

precache()
{
	character\nx_character_china_specops_assault_a::precache();

	precacheItem("rpgx_straight");
	precacheItem("asmk27_reflex");
	precacheItem("m9");
	precacheItem("fraggrenade");
}
