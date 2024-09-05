#include animscripts\Combat_utility;
#include animscripts\Utility;
#include common_scripts\Utility;

// Note that this script is called from the level script command animscripted, only for AI.  If animscripted 
// is done on a script model, this script is not called - startscriptedanim is called directly.

#using_animtree( "generic_human" );
main()
{
	//thread [[anim.println]]("Entering animscripts\\scripted. anim: ",self.codeScripted["anim"],",  notify: ",self.codeScripted["notifyName"],", dialogue: ",self.scripted_dialogue,", facial: ",self.facial_animation, "root: ", self.codeScripted["root"]);#/
	self endon( "death" );

//	wait (0);
	self notify( "killanimscript" );
	self notify( "clearSuppressionAttack" );
	self.a.suppressingEnemy = false;


	self.codeScripted[ "root" ] = %body;	// TEMP!

	self endon( "end_sequence" );
//	Causes potential variable overflow in Stalingrad
//	self thread DebugPrintEndSequence();

	animation = %sprint_loop_distant;  // Hardcoded default
	if ( isdefined( self.node.script_animation ) )
	{
		animation = self.node.script_animation;
	}

	self setFlaggedAnimRestart( "custom", animation, 1, .1, 1.0 );

	wait( 5.0 );
	self lookForBetterCover();
}
