// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("nx_us_secretservice_body_b");
	self attach("nx_us_secretservice_head_b", "", true);
	self.headModel = "nx_us_secretservice_head_b";
	self.voice = "american";
}

precache()
{
	precacheModel("nx_us_secretservice_body_b");
	precacheModel("nx_us_secretservice_head_b");
}
