// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("body_us_army_assault_paul");
	self attach("nx_head_us_army_e", "", true);
	self.headModel = "nx_head_us_army_e";
	self.voice = "american";
}

precache()
{
	precacheModel("body_us_army_assault_paul");
	precacheModel("nx_head_us_army_e");
}