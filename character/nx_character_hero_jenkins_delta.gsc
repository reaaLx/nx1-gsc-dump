// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("nx_hero_baker_body_delta");
	self attach("nx_hero_jenkins_head", "", true);
	self.headModel = "nx_hero_jenkins_head";
	self.voice = "american";
}

precache()
{
	precacheModel("nx_hero_baker_body_delta");
	precacheModel("nx_hero_jenkins_head");
}
