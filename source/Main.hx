package;

import haxe.Timer;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Float;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;
	@:noCompletion private var lastText:String = null;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 12, color);
		text = "FPS: ";
		width += 200;

		cacheCount = 0;
		currentTime = 0;
		autoSize = LEFT;
		times = [];
		background = true;
		backgroundColor = 0x88000000; // semi-transparent black (ARGB)
		border = true;
		borderColor = 0xFFFFFFFF; // optional white border

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.floor((currentCount + cacheCount) / 2);

		if (getMem() > peakMemory)
			peakMemory = getMem();

		var newText = "FPS: " + FlxMath.bound(currentFPS, 0, SaveData.currentSettings?.fps ?? stage.frameRate);

		#if (gl_stats && !disable_cffi && (!html5 || !canvas))
		newText += "\ntotalDC: " + Context3DStats.totalDrawCalls();
		newText += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
		newText += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
		#end
		newText += '\nRAM: ' + FlxStringUtil.formatBytes(getMem()) + ' / PEAK: ' + FlxStringUtil.formatBytes(peakMemory);
		if (text != newText)
			text = newText;

		cacheCount = currentCount;
	}

	var peakMemory:Float = 0;

	function getMem():Float
	{
		return #if (windows && cpp) Math.round(backend.external.windows.WinAPI.getProcessMemoryWorkingSetSize()) #else cast System.totalMemoryNumber #end;
	}
}

class Main extends Sprite
{
	public static var isDebug(default, null):Bool = #if debug true #else false #end;
	// ReleaseName-Month-Year-releasecount
	public static var version:String = "BETA-06-2026-r4";
	public static var debugCounter:FPS;

	public function new()
	{
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
