// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("nx_ec_space_assault_body");
	codescripts\character::attachHead( "alias_nx_ec_space_heads", xmodelalias\alias_nx_ec_space_heads::main() );
	codescripts\character::determineHeadshotModel( "alias_nx_ec_space_heads", xmodelalias\alias_nx_ec_space_heads_crack::main() );
	self.voice = "american";
}

precache()
{
	precacheModel("nx_ec_space_assault_body");
	codescripts\character::precacheModelArray(xmodelalias\alias_nx_ec_space_heads::main());
	codescripts\character::precacheModelArray(xmodelalias\alias_nx_ec_space_heads_crack::main());
}
