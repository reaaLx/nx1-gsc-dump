// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("nx_us_space_assault_body_bloody");
	self attach("nx_us_space_assault_head_crack", "", true);
	self.headModel = "nx_us_space_assault_head_crack";
	self.voice = "american";
}

precache()
{
	precacheModel("nx_us_space_assault_body_bloody");
	precacheModel("nx_us_space_assault_head_crack");
}
