// _createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;
 

	//* Fog section * 

	setDevDvar( "scr_fog_disable", "0" );

	//setExpFog( 0, 80579, 0.627451, 0.717647, 0.745098, 0.38927, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0.839216, 0.690196, 0.568627, (0.00390755, 0.00323934, -1), 83.5416, 92.7872, 2.25266 );
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>,<Maximum Opacity>, <Transition Time>, <Mult Fog Blend Value>, <NearMultFogColor.R>, <NearMultFogColor.G>, <NearMultFogColor.B>, <FarMultFogColor.R>,<FarMultFogColor.G>, <FarMultFogColor.B>);
	setExpFog( 1600, 50000, 0.6784314, 0.8156863, 0.9882353, 0.0505, 0, 0, 0, 1, 1, 1, 1, 1, 1 );
	VisionSetNaked( "mp_nx_pitstop", 0 );

}