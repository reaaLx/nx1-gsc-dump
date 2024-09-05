#include common_scripts\utility;
#include maps\_utility;

init()
{
	max_objectives = Objective_GetMaxObjectives();
	for ( obj_index = 0; obj_index < max_objectives; obj_index++ )
	{
		obj_name = "objective_" + obj_index;
		array_thread( getentarray( obj_name, "script_noteworthy" ), ::objective_route_toggle, obj_index );
	}
}

objective_route_toggle( obj_index )
{
	Objective_AddRoute( self, obj_index );
	self Hide();
	for ( ;; )
	{
		self waittill( "objective_route_on" );
		self Show();
		self waittill( "objective_route_off" );
		self Hide();
	}
}
