// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("nx_hero_gypsy_body_spec_pchute");
	self attach("nx_hero_gypsy_head", "", true);
	self.headModel = "nx_hero_gypsy_head";
	self.voice = "american";
}

precache()
{
	precacheModel("nx_hero_gypsy_body_spec_pchute");
	precacheModel("nx_hero_gypsy_head");
}