// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("nx_ec_lab_body_hazmat_a");
	self attach("nx_ec_lab_head_mask_a", "", true);
	self.headModel = "nx_ec_lab_head_mask_a";
	self.voice = "american";
}

precache()
{
	precacheModel("nx_ec_lab_body_hazmat_a");
	precacheModel("nx_ec_lab_head_mask_a");
}