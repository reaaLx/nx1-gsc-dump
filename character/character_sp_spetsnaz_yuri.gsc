// THIS FILE IS AUTOGENERATED, DO NOT MODIFY
main()
{
	self setModel("body_sp_spetsnaz_yuri");
	self attach("head_sp_spetsnaz_yuri_yuribody", "", true);
	self.headModel = "head_sp_spetsnaz_yuri_yuribody";
	self.voice = "russian";
}

precache()
{
	precacheModel("body_sp_spetsnaz_yuri");
	precacheModel("head_sp_spetsnaz_yuri_yuribody");
}
