// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("nx_jk_swat_body_a");
	self attach("head_opforce_fsb_a", "", true);
	self.headModel = "head_opforce_fsb_a";
	self.voice = "indonesian";
}

precache()
{
	precacheModel("nx_jk_swat_body_a");
	precacheModel("head_opforce_fsb_a");
}