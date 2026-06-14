package;

import openfl.display.Sprite;
import util.macro.EmbedMacro;

class Main extends Sprite
{
	public static var isDebug(default, null):Bool = #if debug true #else false #end;
	// ReleaseName-Month-Year-releasecount
	public static var version:String = EmbedMacro.embedFileContent('.VERSION');
	public static var debugCounter:FPS;

	public function new()
	{
		#if DISCORD_ALLOWED backend.DiscordClient.init(); #end
		CustomLogger.init();

		super();
		addChild(new FlxGame(1280, 720, states.InitState, 60, 60));
		addChild(debugCounter = new FPS(10, 10, 0xFFFFFFFF));
	}
}
