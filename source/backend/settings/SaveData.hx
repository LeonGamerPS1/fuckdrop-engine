package backend.settings;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import lime.app.Application;

@:structInit
class OptionSaveData
{
	public var quants:Bool = false;
	public var opaqueSustains:Bool = false;
	public var opponentStrums:Bool = true;
	public var hideHUD:Bool = false;
	public var botplay:Bool = false;

	// gameplay
	public var downScroll:Bool = false;
	public var enableShaders:Bool = true;
	public var sustainsBehind:Bool = true;

	// sfx
	public var hitSounds:Bool = false;

	public var keyBinds:Map<String, Array<FlxKey>> = [
		// Key Bind, Name for ControlsSubState
		'note_up' => [W, UP],
		'note_left' => [A, LEFT],
		'note_down' => [S, DOWN],
		'note_right' => [D, RIGHT],
		'ui_up' => [W, UP],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_right' => [D, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R],
		'volume_mute' => [ZERO],
		'volume_up' => [NUMPADPLUS, PLUS],
		'volume_down' => [NUMPADMINUS, MINUS],
		'debug_1' => [SEVEN],
		'debug_2' => [EIGHT]
	];
	public var gamepadBinds:Map<String, Array<FlxGamepadInputID>> = [
		'note_up' => [DPAD_UP, Y],
		'note_left' => [DPAD_LEFT, X],
		'note_down' => [DPAD_DOWN, A],
		'note_right' => [DPAD_RIGHT, B],
		'ui_up' => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
		'ui_left' => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
		'ui_down' => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
		'ui_right' => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
		'accept' => [A, START],
		'back' => [B],
		'pause' => [START],
		'reset' => [BACK]
	];

	public var controlSchemeOptions:Array<String> = ['ARROW KEYS + WASD', 'DFJK', 'ASKL'];
	public var currentScheme:String = 'ARROW KEYS + WASD';

	public var fps:Int = 64;
	public var middleScroll:Bool = false;

	// colors
	public var arrowRGB:Array<Array<FlxColor>> = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038]
	];

	public var quantRGB:Array<Array<FlxColor>> = [
		[0xFFE51919, 0xFFFFFFFF, 0xFF7A0C0C], // 4
		[0xFF193BE5, 0xFFFFFFFF, 0xFF0F247A], // 8
		[0xFFA119E5, 0xFFFFFFFF, 0xFF4B0F7A], // 12
		[0xFF26D93E, 0xFFFFFFFF, 0xFF0F5A1A], // 16
		[0xFF0000B2, 0xFFFFFFFF, 0xFF00004A], // 20
		[0xFFA119E5, 0xFFFFFFFF, 0xFF4B0F7A], // 24
		[0xFFE5C319, 0xFFFFFFFF, 0xFF6A5700], // 32
		[0xFFA119E5, 0xFFFFFFFF, 0xFF4B0F7A], // 48
		[0xFF13ECA4, 0xFFFFFFFF, 0xFF0A6B4A], // 64
		[0xFF3A3A6C, 0xFFFFFFFF, 0xFF1A1A2F], // 96
		[0xFF3A3A6C, 0xFFFFFFFF, 0xFF1A1A2F] // 192
	];
}

class SaveData
{
	static public var defaultSettings:OptionSaveData = {};
	static public var currentSettings:OptionSaveData = {};

	public static function setVal(name:String, val:Dynamic)
	{
		try
		{
			Reflect.setProperty(currentSettings, name, val);
		}
		catch (e:Dynamic)
		{
			Application.current.window.alert(Std.string(e), 'Error');
		}
		FlxG.save.flush();
	}

	public static function init()
	{
		Application.current.onExit.add((_) ->
		{
			for (field in Reflect.fields(currentSettings))
			{
				Reflect.setField(FlxG.save.data, field, Reflect.getProperty(currentSettings, field));
			}
			FlxG.save.flush();
		}, false, 999);

		for (field in Reflect.fields(defaultSettings))
		{
			if (Reflect.hasField(FlxG.save.data, field))
				setVal(field, Reflect.getProperty(FlxG.save.data, field));
			else
				Reflect.setField(FlxG.save.data, field, Reflect.getProperty(defaultSettings, field));
		}
	}
}
