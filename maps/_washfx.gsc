#include maps\_utility;
main( vehicletype )
{
	//this sets default wash fx for vehicles - they can be overwritten in level scripts
	if ( !IsDefined( vehicletype ) )
		return;

	level._wash_effect[ vehicletype ] = [];
	switch( vehicletype )
	{
		case "apache":
		case "cobra":
		case "cobra_harbor":
		case "cobra_player":
		case "littlebird":
		case "littlebird_player":
		case "blackhawk":
		case "nx_chinese_vtol":
		case "blackhawk_minigun":
		case "blackhawk_minigun_so":
		case "hind":
		case "harrier":		
		case "pavelow":
		case "nx_miniuav":
		case "nx_miniuav_player":
		case "nx_blackhawk_minigun":
		case "nx_blackhawk_player":
			setvehiclefx( vehicletype, "asphalt", "low_bank", "low", "nx/treadfx/nx_blackhawk_asphalt_low_low" );
			setvehiclefx( vehicletype, "asphalt", "low_bank", "med", "nx/treadfx/nx_blackhawk_asphalt_low_med" );
			setvehiclefx( vehicletype, "asphalt", "low_bank", "high", "nx/treadfx/nx_blackhawk_asphalt_low_high" );
			setvehiclefx( vehicletype, "asphalt", "med_bank", "low", "nx/treadfx/nx_blackhawk_asphalt_default" );
			setvehiclefx( vehicletype, "asphalt", "med_bank", "med", "nx/treadfx/nx_blackhawk_asphalt_default" );
			setvehiclefx( vehicletype, "asphalt", "med_bank", "high", "nx/treadfx/nx_blackhawk_asphalt_low_high" );
			setvehiclefx( vehicletype, "asphalt", "high_bank", "low", "nx/treadfx/nx_blackhawk_asphalt_default" );
			setvehiclefx( vehicletype, "asphalt", "high_bank", "med", "nx/treadfx/nx_blackhawk_asphalt_default" );
			setvehiclefx( vehicletype, "asphalt", "high_bank", "high", "nx/treadfx/nx_blackhawk_asphalt_low_high" );

			setvehiclefx( vehicletype, "water", "low_bank", "low", "nx/treadfx/nx_blackhawk_minigun_water_low" );
			setvehiclefx( vehicletype, "water", "low_bank", "med", "nx/treadfx/nx_blackhawk_minigun_water_default" );
			setvehiclefx( vehicletype, "water", "low_bank", "high", "nx/treadfx/nx_blackhawk_minigun_water_high" );
			setvehiclefx( vehicletype, "water", "med_bank", "low", "nx/treadfx/nx_blackhawk_minigun_water_bank_default" );
			setvehiclefx( vehicletype, "water", "med_bank", "med", "nx/treadfx/nx_blackhawk_minigun_water_bank_default" );
			setvehiclefx( vehicletype, "water", "med_bank", "high", "nx/treadfx/nx_blackhawk_minigun_water_high" );
			setvehiclefx( vehicletype, "water", "high_bank", "low", "nx/treadfx/nx_blackhawk_minigun_water_bank_default" );
			setvehiclefx( vehicletype, "water", "high_bank", "med", "nx/treadfx/nx_blackhawk_minigun_water_bank_default" );
			setvehiclefx( vehicletype, "water", "high_bank", "high", "nx/treadfx/nx_blackhawk_minigun_water_high" );

			setvehiclefx( vehicletype, "default", "low_bank", "low", "nx/treadfx/nx_blackhawk_default_low_low" );
			setvehiclefx( vehicletype, "default", "low_bank", "med", "nx/treadfx/nx_blackhawk_default_low_med" );
			setvehiclefx( vehicletype, "default", "low_bank", "high", "nx/treadfx/nx_blackhawk_default_low_high" );
			setvehiclefx( vehicletype, "default", "med_bank", "low", "nx/treadfx/nx_blackhawk_default_default" );
			setvehiclefx( vehicletype, "default", "med_bank", "med", "nx/treadfx/nx_blackhawk_default_default" );
			setvehiclefx( vehicletype, "default", "med_bank", "high", "nx/treadfx/nx_blackhawk_default_low_high" );
			setvehiclefx( vehicletype, "default", "high_bank", "low", "nx/treadfx/nx_blackhawk_default_default" );
			setvehiclefx( vehicletype, "default", "high_bank", "med", "nx/treadfx/nx_blackhawk_default_default" );
			setvehiclefx( vehicletype, "default", "high_bank", "high", "nx/treadfx/nx_blackhawk_default_low_high" );

			break;
		default:// if the vehicle isn't in this list it will use these effects
	}
}

setvehiclefx( vehicletype, material, dot, height, fx )
{
	if ( !IsDefined( level._wash_effect ) )
		level._wash_effect = [];
	if ( !IsDefined( fx ) )
		level._wash_effect[ vehicletype ][ material ][dot][height] = -1;
	else
		level._wash_effect[ vehicletype ][ material ][dot][height] = loadfx( fx );
}
