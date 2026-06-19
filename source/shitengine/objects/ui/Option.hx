package shitengine.objects.ui;

import flixel.util.FlxSignal;

enum OptionType
{
	BOOL;
	INT(min:Int, max:Float, increment:Int);
	FLOAT(min:Float, max:Float, increment:Float);
	STRING(options:Array<String>);
	N;
}

class Option extends FlxSpriteGroup
{
	public var saveName:String;
	public var type:OptionType;
	public var value:Dynamic;
	public var basic:FlxBasic;
	public var intenName = ""; // display name
	public var selected:Bool = false;
	public var displayText:Alphabet;

	public var onValChange:FlxTypedSignal<Option->Void> = new FlxTypedSignal<Option->Void>();

	public function new(saveName:String, type:OptionType)
	{
		super();
		this.saveName = saveName;
		this.type = type;
		value = Reflect.getProperty(SaveData.currentSettings, saveName);
	}

	public function upload()
	{
		SaveData.setVal(saveName, value);
		onValChange.dispatch(this);
		FlxG.sound.play(Paths.getSound("sounds/scrollMenu"));
	}

	public override function reset(x, y)
	{
		SaveData.setVal(saveName, Reflect.getProperty(SaveData.defaultSettings, saveName));
		value = Reflect.getProperty(SaveData.defaultSettings, saveName);
		onValChange.dispatch(this);
	}

	override function destroy()
	{
		basic = null;
		onValChange.removeAll();
		onValChange = null;
		super.destroy();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (type == N)
			return;

		// i have no better way of doing this rn :sob:
		switch (type)
		{
			case BOOL:
				if (selected && inputSystem.ACCEPT)
				{
					value = !value;
					upload();
				}
			case INT(min, max, increment):
				if (selected)
				{
					var currentVal:Int = value;
					if (inputSystem.UI_LEFT_P)
					{
						currentVal -= increment;
						value = FlxMath.bound(currentVal, min, max);
						upload();
					}
					else if (inputSystem.UI_RIGHT_P)
					{
						currentVal += increment;
						value = FlxMath.bound(currentVal, min, max);
						upload();
					}
				}

			case FLOAT(min, max, increment):
				if (selected)
				{
					var currentVal:Float = value;
					if (inputSystem.UI_LEFT_P)
						currentVal -= increment;
					else if (inputSystem.UI_RIGHT_P)
						currentVal += increment;
					value = FlxMath.bound(currentVal, min, max);
					upload();
				}
			default: // here so the compiler doesnt nag about Unmatched patterns: FLOAT | INT | STRING
		}
	}
}
