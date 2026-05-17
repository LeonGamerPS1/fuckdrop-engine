package states.options;

class Gameplay extends BaseOptionCat
{
	public override function create()
	{
		super.create();

		addOption("Misc", new Option("", N));
		addOption("Frame Rate", new Option("", INT(10,240,10)));

		addOption("Gameplay", new Option("", N));
		addOption("Middle Scroll", new Option("middleScroll", BOOL));
		addOption("Down Scroll", new Option("downScroll", BOOL));

		addOption("", new Option("", N));
		addOption("Other", new Option("", N));
		addOption("Hitsounds", new Option("hitSounds", BOOL));
		addOption("Enable Shaders", new Option("enableShaders", BOOL));
	}
}
