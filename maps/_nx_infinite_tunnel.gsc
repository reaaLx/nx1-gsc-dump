//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2011            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module: Infnite Tunnel Util											**
//    Streaming moving geo around static geo (moving train in tunnel)		**
//                                                                          **
//    Created: 10/17/11 - Travis Chen (trchen x 4143) Neversoft 			**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include maps\_utility_code;
#include common_scripts\utility;
#include maps\_nx_utility;

MPH_TO_IPS = ( 63360.0 / 3600.0 );
IPS_TO_MPH = ( 1.0 / MPH_TO_IPS );

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

infinite_tunnel_init( segment_array, infinite_tunnel_before_name, infinite_tunnel_after_name, infinite_tunnel_clip )
{	
	level.infinite_tunnel_segments = [];

	infinite_tunnel_start_point = GetEnt( "infinite_tunnel_start_pos", "targetname" );
	base_start_pos = infinite_tunnel_start_point.origin;
	start_pos = infinite_tunnel_start_point.origin;

	foreach( index, segment_name in segment_array )
	{
		segment_pieces = GetEntArray( segment_name, "targetname" );

		start_point = undefined;
		end_point = undefined;
		light_point_1 = undefined;
		light_point_2 = undefined;

		// Find the start and end points
		foreach( segment_piece in segment_pieces )
		{
			script_noteworthy = segment_piece.script_noteworthy;
	
			if( IsDefined( script_noteworthy ) )
			{
				if( script_noteworthy == "infinite_tunnel_start_point" )
				{
					start_point = segment_piece;
				}
				else if( script_noteworthy == "infinite_tunnel_end_point" )
				{
					end_point = segment_piece;
				}
				else if( script_noteworthy == "infinite_tunnel_light_point_1" )
				{
					light_point_1 = segment_piece;
				}
				else if( script_noteworthy == "infinite_tunnel_light_point_2" )
				{
					light_point_2 = segment_piece;
				}
				else if( script_noteworthy == "infinite_tunnel_static_light_point" )
				{
					segment_piece thread attach_static_light_to_segment();
				}
			}
		}

		level.infinite_tunnel_segments[ index ][ "start_point" ] = start_point;
		level.infinite_tunnel_segments[ index ][ "end_point" ] = end_point;
		level.infinite_tunnel_segments[ index ][ "light_point_1" ] = light_point_1;
		level.infinite_tunnel_segments[ index ][ "light_point_2" ] = light_point_2;
		level.infinite_tunnel_segments[ index ][ "pieces" ] = [];

		// Link geo to start point
		foreach( segment_piece in segment_pieces )
		{
			type = segment_piece.code_classname;

			if( type == "script_model" || type == "script_brushmodel" || segment_piece.script_noteworthy == "infinite_tunnel_static_light_point" )
			{
				// Save pieces
				pieces_size = level.infinite_tunnel_segments[ index ][ "pieces" ].size;
				level.infinite_tunnel_segments[ index ][ "pieces" ][ pieces_size ] = segment_piece;

				// Link Pieces
				segment_piece Hide();
				segment_piece LinkTo( level.infinite_tunnel_segments[ index ][ "start_point" ] );
			}
		}

		// Link the end point to the start point
		level.infinite_tunnel_segments[ index ][ "end_point" ] LinkTo( level.infinite_tunnel_segments[ index ][ "start_point" ] );
		level.infinite_tunnel_segments[ index ][ "light_point_1" ] LinkTo( level.infinite_tunnel_segments[ index ][ "start_point" ] );
		level.infinite_tunnel_segments[ index ][ "light_point_2" ] LinkTo( level.infinite_tunnel_segments[ index ][ "start_point" ] );

		// Move the tunnel to the right place, set the next start pos
		level.infinite_tunnel_segments[ index ][ "start_point" ].origin = start_pos;
		wait( 0.05 );
		start_pos = level.infinite_tunnel_segments[ index ][ "end_point" ].origin;
	}

	// Get before, link and move
	level.infinite_tunnel_before = GetEntArray( infinite_tunnel_before_name, "targetname" );
	before_start_point = infinite_tunnel_get_start_point( level.infinite_tunnel_before );
	foreach( item in level.infinite_tunnel_before )
	{
		type = 	item.code_classname;
		if( type == "script_model" || type == "script_brushmodel" )
		{
			item LinkTo( before_start_point );
		}
	}
	before_start_point.origin = base_start_pos; 

	// Get after, link, move and hide
	level.infinite_tunnel_after = GetEntArray( infinite_tunnel_after_name, "targetname" );
	after_start_point = infinite_tunnel_get_start_point( level.infinite_tunnel_after );
	foreach( item in level.infinite_tunnel_after )
	{
		type = 	item.code_classname;
		if( type == "script_model" || type == "script_brushmodel" )
		{
			item LinkTo( after_start_point );
		}
	}
	after_start_point.origin = base_start_pos; 
	level.infinite_tunnel_after hide_all_in_array();

	// Get clip
	level.infinite_tunnel_clip = GetEntArray( infinite_tunnel_clip, "targetname" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

infinite_tunnel_start( infinite_tunnel_speed )
{
	level.infinite_tunnel_before hide_all_in_array();
	level thread infinite_tunnel_mover( infinite_tunnel_speed );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

infinite_tunnel_mover( infinite_tunnel_speed )
{
	level endon( "infinite_tunnel_end" );

	// Get base info
	first_start_point = level.infinite_tunnel_segments[0][ "start_point" ];
	first_end_point = level.infinite_tunnel_segments[0][ "end_point" ];
	distance = Distance2D( first_start_point.origin, first_end_point.origin ); 
	travel_time = ( distance / ( infinite_tunnel_speed * MPH_TO_IPS ) );	

	// Make travel time an integer multiple of the server frame time.
	server_frames = Int( travel_time / 0.05 );
	travel_time = Float( server_frames * 0.05 );

	// Attach audio points to segments
	level thread infinite_tunnel_attach_audio();
	
	// Infinite loop through each segment
	segment_index = 0;
	segment_size = level.infinite_tunnel_segments.size; 
	first_move = true;
	while( 1 )
	{
		// Move all segements
		foreach( index, segment in level.infinite_tunnel_segments )
		{
			start_point = segment[ "start_point" ];
			end_point = segment[ "end_point" ];
	
			start_point_normal = VectorNormalize( start_point.angles );	 
			move_to_point = ( start_point.origin - ( start_point_normal * distance ) );

			start_point MoveTo(	move_to_point, travel_time );

			// Show the segements
			if( first_move )
			{
				segment thread segment_show_all_pieces();
			}
			else
			{
				segment thread segment_show_all_pieces_delay();
			}
		}

		// Get the first and the last segment
		first_segment = level.infinite_tunnel_segments[ segment_index ];
		last_segment_index = ( segment_index + ( segment_size - 1 ) );
		middle_segment_index = Int( segment_index + ( ( segment_size - 1 ) / 2 ) );
		if( last_segment_index >= segment_size )
		{
			last_segment_index -= segment_size;
		}
		if( middle_segment_index >= segment_size )
		{
			middle_segment_index -= segment_size;
		}
		last_segment = level.infinite_tunnel_segments[ last_segment_index ]; 
		
		// Figure out player position relative to middle two segments
		cur_size = level.infinite_tunnel_segments[ middle_segment_index ][ "start_point" ].origin;
		player_dist_front = Distance2D( level._player.origin, cur_size ); 

		cur_size = level.infinite_tunnel_segments[ middle_segment_index ][ "end_point" ].origin;		
		player_dist_back = Distance2D( level._player.origin, cur_size ); 

		// Player is in first middle segment
		next_segment_index = middle_segment_index;
		if( abs(player_dist_back - player_dist_front) <= 3500)
		{
			// Player is in close to center of both middle segments
			next_segment_index += 1;
			if(next_segment_index==segment_size)
				next_segment_index = 0;
		}
		else if(player_dist_back < player_dist_front)
		{
			// Player is in second middle segment
			middle_segment_index = next_segment_index;
		}
	
		// Attach moving light to middle segment
		level.infinite_tunnel_segments[ middle_segment_index ][ "light_point_1" ] thread attach_moving_light_to_segment_1();
		level.infinite_tunnel_segments[ next_segment_index ][ "light_point_2" ] thread attach_moving_light_to_segment_2();	

		// Wait till movement is done
//		last_segment[ "start_point" ] waittill( "movedone" );
		while( 1 )
		{
			if( last_segment[ "start_point" ] istrajectorystationary())
			{
				break;
			}
			else
			{
				wait 0.05;
			}
		}
		
		// Remove moving light
		level.infinite_tunnel_segments[ middle_segment_index ][ "light_point_1" ] notify( "remove_moving_light_from_segment" );
		level.infinite_tunnel_segments[ next_segment_index ][ "light_point_2" ] notify( "remove_moving_light_from_segment" );											
	
		// Move first to back of last
		first_segment segment_hide_all_pieces(); 
		first_segment[ "start_point" ].origin = last_segment[ "end_point" ].origin;

		// Iterate segments
		segment_index++;
		if( segment_index >= segment_size )
		{
			segment_index = 0;
		}
		first_move = false;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

infinite_tunnel_attach_audio()
{
	foreach( segment in level.infinite_tunnel_segments )
	{
		segment[ "light_point_1" ] thread infinite_tunnel_audio_point_thread();
		segment[ "light_point_2" ] thread infinite_tunnel_audio_point_thread();
	}
}

infinite_tunnel_audio_point_thread()
{
	// Here self is a point attached to the big beam structure that flies by overhead
	// Attach your audio to self
	
	// Debug print to show you the position of the point
	// self print_pos();
	self playloopsound( "emt_train_pass" );

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

infinite_tunnel_get_start_point( segment_array )
{
	start_point = undefined;
	foreach( segment_piece in segment_array )
	{
		script_noteworthy = segment_piece.script_noteworthy;

		if( IsDefined( script_noteworthy ) )
		{
			if( script_noteworthy == "infinite_tunnel_start_point" )
			{
				start_point = segment_piece;
				break;
			}
		}
	}

	return start_point;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

attach_static_light_to_segment()
{
	//static_lgt_array = ["tunnel_light_static_1", "tunnel_light_static_1", "tunnel_light_static_2", "tunnel_light_static_1",
	//	"tunnel_light_static_3", "tunnel_light_static_1","tunnel_light_static_1", "tunnel_light_static_3",
	//	"tunnel_light_static_1","tunnel_light_static_1", "tunnel_light_static_1","tunnel_light_static_1"];
	//static_lgt = random (static_lgt_array);

	// IPrintln( "Static Light Position: " + self.origin );
	tag_origin = spawn( "script_model", self.origin );
	tag_origin.angles = self.angles;
	tag_origin setmodel( "tag_origin" );

	tag_origin LinkTo( self );	

	PlayFXOnTag( level._effect[ "tunnel_light_static_1" ], tag_origin, "tag_origin" );
	//PlayFXOnTag( level._effect[ static_lgt ], tag_origin, "tag_origin" );
	//tag_origin thread print_pos();
	level waittill( "infinite_tunnel_end" );

	// Clean up the static light
	tag_origin Unlink(); 
	PlayFXOnTag( level._effect[ "tunnel_light_static_1" ], tag_origin, "tag_origin" );
	//PlayFXOnTag( level._effect[ static_lgt ], tag_origin, "tag_origin" );
	tag_origin delete();
	
}

attach_moving_light_to_segment_1()
{
	// Create tag origin, pointing down
	tag_origin = spawn( "script_model", self.origin );
	tag_origin.angles = self.angles;
	tag_origin setmodel( "tag_origin" );

	// Link tag origin
	tag_origin LinkTo( self );

	//release the dustmotes!
	maps\nx_lava_fx::release_the_dustmotes_fx_1();

	// set and play spotlight fx
	setsaveddvar( "r_spotlightstartradius", "800" );
	setsaveddvar( "r_spotlightEndradius", "1200" );
	setsaveddvar( "r_spotlightfovinnerfraction", ".5" );
	setsaveddvar( "r_spotlightexponent", "4" );
	setsaveddvar( "r_spotlightBrightness", "10" );

	PlayFXOnTag( level._effect[ "tunnel_light_1" ], tag_origin, "tag_origin" );
	//tag_origin thread print_pos();
	
	// Wail till remove light
	self waittill( "remove_moving_light_from_segment" );
	//wait(0.5);

	// Stop FX and remove light
	tag_origin Unlink(); 
	StopFXOnTag( level._effect[ "tunnel_light_1" ], tag_origin, "tag_origin", true );
	tag_origin delete();
}

attach_moving_light_to_segment_2()
{
	// Create tag origin, pointing down
	tag_origin = spawn( "script_model", self.origin );
	tag_origin.angles = self.angles;
	tag_origin setmodel( "tag_origin" );

	// Link tag origin
	tag_origin LinkTo( self );

	//release the dustmotes!
	maps\nx_lava_fx::release_the_dustmotes_fx_2();	

	// Play spotlight fx
	setsaveddvar( "r_spotlightstartradius", "800" );
	setsaveddvar( "r_spotlightEndradius", "1200" );
	setsaveddvar( "r_spotlightfovinnerfraction", ".5" );
	setsaveddvar( "r_spotlightexponent", "4" );
	setsaveddvar( "r_spotlightBrightness", "10" );

	PlayFXOnTag( level._effect[ "tunnel_light_2" ], tag_origin, "tag_origin" );
	//tag_origin thread print_pos();
	
	// Wail till remove light
	self waittill( "remove_moving_light_from_segment" );
	//wait(0.5);

	// Stop FX and remove light
	tag_origin Unlink(); 
	StopFXOnTag( level._effect[ "tunnel_light_2" ], tag_origin, "tag_origin", true );
	tag_origin delete();
}

print_pos()
{
	self endon( "death" );
	for( ; ; )
	{
		Print3d( self.origin, "POS " + self.origin, (1,0,0), 1, 1, 1 );
		wait(0.05);
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

infinite_tunnel_end()
{
	level notify( "infinite_tunnel_end" );

	// Hide all segements
	foreach( index, segment in level.infinite_tunnel_segments )
	{
		segment thread segment_hide_all_pieces();	
	}

	// Delete clip geo
	level.infinite_tunnel_clip delete_all_in_array();

	// Show after geo
	level.infinite_tunnel_after show_all_in_array();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

hide_all_in_array()
{
	if( self.size <= 0 )
	{
		return;
	}

	foreach( piece in self )
	{
		piece hide();
	}	
}

delete_all_in_array()
{
	if( self.size <= 0 )
	{
		return;
	}

	foreach( piece in self )
	{
		piece delete();
	}	
}

show_all_in_array()
{
	if( self.size <= 0 )
	{
		return;
	}

	foreach( piece in self )
	{
		piece show();
	}	
}

segment_hide_all_pieces()
{
	// Hide pieces during origin teleport to cover up movement glitch
	pieces_array = self[ "pieces" ];
	pieces_array hide_all_in_array();
}

segment_show_all_pieces()
{
	pieces_array = self[ "pieces" ];
	pieces_array show_all_in_array();
}

segment_show_all_pieces_delay()
{  
	// Wait a frame past movment glitch to reshow pieces
	wait( 0.05 );
	segment_show_all_pieces();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************