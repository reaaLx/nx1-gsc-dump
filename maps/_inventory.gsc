/*
Usage:

	inventory_hud_elem = inventory_cr	eate(shader,show_icon)
		Creates a new hud element.
		Shader is the name of a shader found in the hud.gdt. 
		show_icon defaults to false.
		Inventory items will stack in the order they are created.
		
	inventory_hud_elem inventory_show();
		Shows the hud element

	inventory_hud_elem inventory_hide();
		Hides the hud element

	inventory_hud_elem inventory_destroy();
		Destroyed the hud element
*/

main()
{
	level._inventory = [];
}

inventory_create( shader, show_icon )
{
	// feature disabled.
	if ( true )
		return spawnstruct();

	// Creates a hud element for the inventroy.
	// Shader is the name of a shader found in the hud.gdt. Assumed to be 64x64 units.
	assert( isdefined( shader ) );

	if ( !isdefined( show_icon ) )
		show_icon = false;

	ent = newHudElem();

	ent.alignX = "right";
	ent.alignY = "top";
	ent.horzAlign = "right";
	ent.vertAlign = "top";

	ent.alpha = 0;

	ent.index = level._inventory.size;
	ent.show_icon = show_icon;

	ent setshader( shader, 40, 40 );	// 40, 40 makes for ~64x64 in 1024 * 768

	level._inventory[ ent.index ] = ent;

	inventroy_update();

	return ent;
}

inventory_hide()
{
	// feature disabled.
	if ( true )
		return;

	self.show_icon = false;
	inventroy_update();
}

inventory_show()
{
	// feature disabled.
	if ( true )
		return;

	self.show_icon = true;
	inventroy_update();
}

inventroy_update()
{
	// feature disabled.
	if ( true )
		return;

	// Updates the location and visibility state for each item in the inventory

	x = -18;
	y = 8;

	gap = 42;
	position = 0;

	for ( i = 0; i < level._inventory.size; i++ )
	{
		if ( level._inventory[ i ].show_icon )
		{
			new_y = y + ( gap * position );

			if ( new_y != level._inventory[ i ].y )
			{
				level._inventory[ i ].x = x;
				if ( level._inventory[ i ].alpha != 0 )
					level._inventory[ i ] moveovertime( .3 );
				level._inventory[ i ].y = new_y;
			}
			if ( level._inventory[ i ].alpha != 1 )
			{
				level._inventory[ i ] fadeovertime( .3 );
				level._inventory[ i ].alpha = 1;
			}
			position++ ;
		}
		else
		{
			level._inventory[ i ] fadeovertime( .3 );
			level._inventory[ i ].alpha = 0;
		}
	}
}

inventory_destroy()
{
	// feature disabled.
	if ( true )
		return;

	// Destroyes the hud element and removes it from the inventory.
	self destroy();

	index = 0;
	old_inventory = level._inventory;
	level._inventory = [];
	for ( i = 0; i < old_inventory.size; i++ )
	{
		if ( isdefined( old_inventory[ i ] ) )
			level._inventory[ level._inventory.size ] = old_inventory[ i ];
	}
	inventroy_update();
}