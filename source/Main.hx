package;

import openfl.display.Sprite;

class Main extends Sprite
{
	public static var isDebug(default, null):Bool = #if debug true #else false #end;
	// ReleaseName-Month-Year-releasecount
	public static var version:String = "BETA-06-2026-r4";
	public static var debugCounter:FPS;

	public function new()
	{
		#if DISCORD_ALLOWED backend.DiscordClient.init(); #end
		CustomLogger.init();

		super();
		addChild(new FlxGame(1280, 720, states.InitState, 60, 60));
		addChild(debugCounter = new FPS(10, 10, 0xFFFFFFFF));
		FlxG.signals.focusGained.add(() ->
		{
			FlxG.sound.resume();
		});
	}
}
