// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	codescripts\character::setModelFromArray(xmodelalias\alias_nx_civ_china_urban_male_body::main());
	codescripts\character::attachHead( "alias_nx_ec_security_guard_heads", xmodelalias\alias_nx_ec_security_guard_heads::main() );
	self.voice = "american";
}

precache()
{
	codescripts\character::precacheModelArray(xmodelalias\alias_nx_civ_china_urban_male_body::main());
	codescripts\character::precacheModelArray(xmodelalias\alias_nx_ec_security_guard_heads::main());
}
