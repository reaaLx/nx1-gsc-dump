// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	codescripts\character::setModelFromArray(xmodelalias\alias_nx_us_army_bodies::main());
	codescripts\character::attachHead( "alias_nx_us_army_heads", xmodelalias\alias_nx_us_army_heads::main() );
	self.voice = "american";
}

precache()
{
	codescripts\character::precacheModelArray(xmodelalias\alias_nx_us_army_bodies::main());
	codescripts\character::precacheModelArray(xmodelalias\alias_nx_us_army_heads::main());
}