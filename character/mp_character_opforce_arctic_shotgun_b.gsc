// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main(){	self setModel("mp_body_opforce_arctic_shotgun_b");	codescripts\character::attachHead( "alias_opforce_arctic_heads", xmodelalias\alias_opforce_arctic_heads::main() );	self setViewmodel("viewhands_arctic_opforce");	self.voice = "russian";}precache(){	precacheModel("mp_body_opforce_arctic_shotgun_b");	codescripts\character::precacheModelArray(xmodelalias\alias_opforce_arctic_heads::main());	precacheModel("viewhands_arctic_opforce");}