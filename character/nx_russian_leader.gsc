// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("nx_russian_leader_body");
	self attach("nx_russian_leader_head", "", true);
	self.headModel = "nx_russian_leader_head";
	self.voice = "american";
}

precache()
{
	precacheModel("nx_russian_leader_body");
	precacheModel("nx_russian_leader_head");
}
