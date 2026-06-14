package shitengine.states.options;

class UI_and_Looks extends BaseOptionCat
{
	public override function create()
	{
		super.create();

		// hud stuff
		addOption("Opaque Sustains", new Option("opaqueSustains", BOOL));
		addOption("Opponent Strums", new Option("opponentStrums", BOOL));
		addOption("Hide HUD", new Option("hideHUD", BOOL));

		addOption("Cover Sustains", new Option("sustainsBehind", BOOL));
	}
}
