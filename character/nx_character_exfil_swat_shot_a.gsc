// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("nx_jk_swat_body_a");
	self attach("exfil_swat_head_a_shot", "", true);
	self.headModel = "exfil_swat_head_a_shot";
	self.voice = "indonesian";
}

precache()
{
	precacheModel("nx_jk_swat_body_a");
	precacheModel("exfil_swat_head_a_shot");
}
