// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("nx_us_secretservice_body_a");
	self attach("nx_us_secretservice_head_a", "", true);
	self.headModel = "nx_us_secretservice_head_a";
	self.voice = "american";
}

precache()
{
	precacheModel("nx_us_secretservice_body_a");
	precacheModel("nx_us_secretservice_head_a");
}
