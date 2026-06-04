package states;

import backend.gameplay.HighScore;
import backend.input.Controls;
import backend.modding.PolymodHandler;
import backend.settings.SaveData;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileCircle;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
#if android import extension.androidtools.*; #end
import haxe.io.Path;
import lime.app.Application;
import modchart.backend.standalone.Adapter;
import states.menus.TitleState;
import states.options.subs.ControlsSubstate;


class InitState extends flixel.addons.transition.FlxTransitionableState
{
	#if android
	static var defaultAndroidPermissions:Array<String> = ['READ_EXTERNAL_STORAGE'];
	#end

	override function create()
	{

		FlxG.scaleMode = new backend.scalemodes.FullScreenScalemode();
		#if android
		Permissions.requestPermissions(defaultAndroidPermissions);
		Sys.setCwd(Path.addTrailingSlash(extension.androidtools.content.Context.getExternalFilesDir()));
		#end
		//modchart.Config.PREVENT_SCALED_HOLD_END = true;
		modchart.Config.OPTIMIZE_HOLDS = true;

		SaveData.init();
		HighScore.init();
		modchart.Config.HOLDS_BEHIND_STRUM = SaveData.currentSettings.sustainsBehind;

		PolymodHandler.init();
		Controls.init();
		ControlsSubstate.applyControlSchemeToKeyboard(SaveData.currentSettings.currentScheme);
		FlxG.drawFramerate = FlxG.updateFramerate = SaveData.currentSettings.fps;

		Adapter.instance = new backend.graphics.ModchartBackend();
		FlxG.cameras.useBufferLocking = true;
		FlxG.signals.preStateCreate.add((s) ->
		{
			var c = Conductor;
			for (ass in [c.onBeat, c.onMeasure, c.onStep])
				ass.removeAll();
		});

		#if sys
		Application.current.onExit.add((i) ->
		{
			var txt = "";
			for (txt2 in CustomLogger.allTraces)
			{
				txt += '\n$txt2';
			}
			if (!sys.FileSystem.exists('./logs'))
				sys.FileSystem.createDirectory("./logs");
			sys.io.File.saveContent(("./logs/" + Date.now().toString()).replace(":", '-').replace(" ", '-'), txt);
		}, false, 999);
		#end
		var dia = FlxGraphic.fromClass(GraphicTransTileCircle);
		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.5, FlxPoint.get(0, -1), {
			asset: dia,
			width: 32,
			height: 32,
		}, FlxRect.get(0, 0, FlxG.width, FlxG.height), TOP);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.5, FlxPoint.get(0, 1), {
			asset: dia,
			width: 32,
			height: 32,
		}, FlxRect.get(0, 0, FlxG.width, FlxG.height), TOP);
		FlxG.switchState(new states.menus.TitleState());
		FlxG.switchState(() -> new TitleState());
	}
}
