// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main(){	self setModel("mp_nx_ec_ninja_body");	codescripts\character::attachHead( "alias_mp_nx_ec_ninja_heads", xmodelalias\alias_mp_nx_ec_ninja_heads::main() );	self setViewmodel("viewhands_us_specops");	self.voice = "american";}precache(){	precacheModel("mp_nx_ec_ninja_body");	codescripts\character::precacheModelArray(xmodelalias\alias_mp_nx_ec_ninja_heads::main());	precacheModel("viewhands_us_specops");}