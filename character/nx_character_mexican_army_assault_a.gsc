// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	codescripts\character::setModelFromArray(xmodelalias\alias_nx_mexican_army_body_ar::main());
	codescripts\character::attachHead( "alias_nx_mexican_army_heads", xmodelalias\alias_nx_mexican_army_heads::main() );
	self.voice = "mexican";
}

precache()
{
	codescripts\character::precacheModelArray(xmodelalias\alias_nx_mexican_army_body_ar::main());
	codescripts\character::precacheModelArray(xmodelalias\alias_nx_mexican_army_heads::main());
}
