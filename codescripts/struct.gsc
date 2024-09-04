InitStructs()
{
	level._struct = [];
}

CreateStruct()
{
	struct = spawnstruct();
	level._struct[level._struct.size] = struct;
	return struct;
}

FindStruct( position )
{
	for( i = 0; i < level._struct.size; i++ )
	{
		if( DistanceSquared( level._struct[i].origin, position ) < 1 )
		{
			return level._struct[i];
		}
	}
	return undefined;
}