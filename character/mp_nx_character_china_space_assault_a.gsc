// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{	
	self setModel("mp_nx_china_space_assault_body");
	self attach("mp_nx_china_space_assault_head", "", true);
	self.headModel = "mp_nx_china_space_assault_head";
	self setViewmodel("viewhands_chinese_lunar");
	self.voice = "american";
}
precache()
{	
	precacheModel("mp_nx_china_space_assault_body");
	precacheModel("mp_nx_china_space_assault_head");
	precacheModel("viewhands_chinese_lunar");
}