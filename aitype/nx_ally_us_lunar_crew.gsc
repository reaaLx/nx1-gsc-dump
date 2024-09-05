// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
/*QUAKED actor_nx_ally_us_lunar_crew (0.5 0.5 0.5) (-16 -16 0) (16 16 72) SPAWNER FORCESPAWN UNDELETABLE PERFECTENEMYINFO DONTSHAREENEMYINFO
defaultmdl="nx_civ_astronaut_body_complete_a"
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
	self.additionalAssets = "moon_civilian.csv";
	self.team = "neutral";
	self.type = "civilian";
	self.subclass = "moon";
	self.accuracy = 0.3;
	self.health = 30;
	self.secondaryweapon = "";
	self.sidearm = "";
	self.grenadeWeapon = "";
	self.grenadeAmmo = 0;

	if ( isAI( self ) )
	{
		self setEngagementMinDist( 256.000000, 0.000000 );
		self setEngagementMaxDist( 768.000000, 1024.000000 );
	}

	self.weapon = "none";

	character\nx_character_us_lunar_crew::main();
}

spawner()
{
	self setspawnerteam("neutral");
}

precache()
{
	character\nx_character_us_lunar_crew::precache();


	//----------------
	maps\_moon_civilian::main(); //init anims.
	//----------------
}