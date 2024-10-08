// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
/*QUAKED actor_nx_opfor_china_space_smg_l3 (1.0 0.25 0.0) (-16 -16 0) (16 16 72) SPAWNER FORCESPAWN UNDELETABLE PERFECTENEMYINFO DONTSHAREENEMYINFO
defaultmdl="nx_ec_space_assault_body"
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

	self.weapon = "ecr_smg";

	character\nx_character_ec_space_assault_b::main();
}

spawner()
{
	self setspawnerteam("axis");
}

precache()
{
	character\nx_character_ec_space_assault_b::precache();

	precacheItem("ecr_smg");
	precacheItem("beretta");
	precacheItem("beretta");
	precacheItem("fraggrenade");

	//----------------
	maps\_moon_actor::main();
	//----------------
}
