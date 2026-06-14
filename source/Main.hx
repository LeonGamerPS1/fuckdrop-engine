package;

import openfl.display.Sprite;
import shitengine.util.macro.DefineMacro;
import shitengine.util.macro.EmbedMacro;

class Main extends Sprite
{
	public static var isDebug(default, null):Bool = Define.debug;

	public static var version:String = EmbedMacro.embedFileContent('.VERSION').split('\n')[0].trim();

	public static var debugCounter:FPS;

	public function new()
	{
		if (Define.DISCORD_ALLOWED)
			shitengine.backend.DiscordClient.init();
		CustomLogger.init();

		super();
		addChild(new FlxGame(1280, 720, shitengine.states.InitState, 60, 60));
		addChild(debugCounter = new FPS(10, 10, 0xFFFFFFFF));
	}
}
