// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("nx_jk_swat_body_a");
	self attach("exfil_swat_head_a", "", true);
	self.headModel = "exfil_swat_head_a";
	self.voice = "indonesian";
}

precache()
{
	precacheModel("nx_jk_swat_body_a");
	precacheModel("exfil_swat_head_a");
}
