// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("nx_us_space_assault_body");
	self attach("nx_us_space_assault_head_a", "", true);
	self.headModel = "nx_us_space_assault_head_a";
	self.voice = "american";
}

precache()
{
	precacheModel("nx_us_space_assault_body");
	precacheModel("nx_us_space_assault_head_a");
}