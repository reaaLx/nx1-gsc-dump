#include common_scripts\utility;
#include maps\_utility;

/*QUAKED info_volume_translation (0.1 0.3 1.0)?
defaulttexture="translation"
Used to determine where a translated bit of text is.
translation - The string reference name to be used for this translation.
radius - The distance at which the translation can be seen.
*/

TRANSLATION_DETECTION_FOV = 15;
TRANSLATION_MIN_ANGLE = 0.7; //from 0 to 1. Dot product result.
main()
{
	level._translation_ents = GetEntArray( "info_volume_translation", "classname" ); 
	
	level._player thread watch_for_view();	
}

//called on the player.
watch_for_view()
{
	//loop indefinately.
	while ( true )
	{
		translation_ents = [];
		has_changed = false;
		
		//loop over all of the translation ents to see if they're in view.
		for ( i = 0; i < level._translation_ents.size; i ++ )
		{
			translation_ent = level._translation_ents[i];

			if( !IsDefined( translation_ent.draw ) )
			{
				translation_ent.draw = false;
			}

			AssertEx( IsDefined(translation_ent.radius), "translation ent at pos ("+translation_ent.origin[0]+", "+translation_ent.origin[1]+", "+translation_ent.origin[2]+") does not have radius." );

			//debug_draw_origin( translation_ent.origin );
			
//			/#
//			normal = translation_ent GetVolumeNormal();
//			Line( translation_ent.origin, translation_ent.origin + 32*normal, ( 1, 0, 0 ), 1, 0, 10000000 );
//			#/

			//is it close enough?
			if ( Distance( self.origin, translation_ent.origin ) < translation_ent.radius )
			{
				if ( within_fov_of_players( translation_ent.origin, Cos( TRANSLATION_DETECTION_FOV ) ) )
				{
					angle = VectorDot( translation_ent GetVolumeNormal(), VectorNormalize(self.origin - translation_ent.origin) );
					if( abs( angle ) > TRANSLATION_MIN_ANGLE )
					{
						//now that we've culled down how many object's are being tested, lets do a trace for occulusion.
						sight_trace = SightTracePassed( translation_ent.origin, self GetEye(), false, undefined );
						if ( sight_trace )
						{
							//if not already being drawn.
							if ( !translation_ent.draw )
							{
								//ok if we've made it this far we want to actually draw this one. I've tried placing these if clauses from quickest to slowest.
								translation_ent.draw = true;
								has_changed = true;
								translation_ents[translation_ents.size] = translation_ent;
								continue;
							}
						}
							else if ( translation_ent.draw )
						{
							has_changed = true;
							translation_ent.draw = false;
						}
					}
					else if ( translation_ent.draw )
					{
						has_changed = true;
						translation_ent.draw = false;
					}
				}
				else if ( translation_ent.draw )
				{
					has_changed = true;
					translation_ent.draw = false;
				}	
			}
			else if ( translation_ent.draw )
			{
				has_changed = true;
				translation_ent.draw = false;
			}	

			//was previously being drawn, but isn't now, we need to send a new command. Give it some time though.
				
		}

		if ( has_changed )
		{
			level._player DrawTranslationText( translation_ents );
		}

		wait 0.5;
	}
}

debug_draw_origin( origin )
{
	Line( origin + ( 16, 0, 0 ), origin + ( -16, 0, 0 ), ( 1, 0, 0 ), 1, 0, 10000000 );
	Line( origin + ( 0, 16, 0 ), origin + ( 0, -16, 0 ), ( 0, 1, 0 ), 1, 0, 10000000 );
	Line( origin + ( 0, 0, 16 ), origin + ( 0, 0, -16 ), ( 0, 0, 1 ), 1, 0, 10000000 );
}