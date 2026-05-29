package states.options;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.plugin.taskManager.FlxTask;
import flixel.addons.transition.FlxTransitionableState;
import objects.ui.Option;
import states.menus.OptionsState;

class BaseOptionCat extends FlxTransitionableState
{
	public var options:Array<Option> = [];
	public var itemIndex = 0;
	public var optionsGroup:FlxTypedGroup<Option>;
	public var curSelected(get, null):Option;
	public var camTarget:FlxObject;

	public function new()
	{
		super();
		persistentDraw = persistentUpdate = true;
		var bg:FlxBackdrop = new FlxBackdrop(Paths.getGraphic("menus/menuDesat"), XY, 0, 0);
		bg.velocity.set(-20, 0);
		add(bg);

		optionsGroup = new FlxTypedGroup();
		add(optionsGroup);

		camTarget = new FlxObject(0, 0, 1, 1);

		add(camTarget);
	}

	override function create()
	{
		super.create();
		FlxG.camera.follow(camTarget, 0.06);
	}

	public function addOption(opName:String, option:Option)
	{
		options.push(option);

		option.intenName = opName;

		var optionName:Alphabet = new Alphabet(0, 0, option.intenName, true, false);
		option.add(optionName);

		optionsGroup.add(option);
		option.displayText = optionName;
		option.setPosition(0, 120 * optionsGroup.length);
		option.screenCenter(X);
		option.y += FlxG.height / 2;

		switch (option.type)
		{
			case BOOL:
				var checkbox:OptionCheckbox = new OptionCheckbox(option);
				option.add(checkbox);
			default:
				trace("type " + option.type.getName() + " has no display thing yet");
		}
		return option;
	}

	var canMoveBack = true;
	var trig = false;

	override function update(elapsed:Float)
	{
		if (!trig)
		{
			trig = true;
			changeSelected();
		}
		else
		{
			if (inputSystem.UI_DOWN_P)
				changeSelected(1);
			else if (inputSystem.NOTE_UP_P)
				changeSelected(-1);
		}
		super.update(elapsed);
		if (inputSystem.BACK && canMoveBack)
			FlxG.switchState(new OptionsState());
	}

	public function changeSelected(addition:Int = 0)
	{
		if (addition != 0)
			FlxG.sound.play(Paths.getSound("sounds/scrollMenu"));

		var len = optionsGroup.length;
		if (len == 0)
			return;

		var startIndex = itemIndex;

		for (i in 0...len)
		{
			itemIndex = FlxMath.wrap(itemIndex + addition, 0, len - 1);

			if (optionsGroup.members[itemIndex].type != N)
				break;

			// if we've looped all the way around, stop
			if (itemIndex == startIndex)
				break;
		}

		var curSelected = optionsGroup.members[itemIndex];

		camTarget.setPosition(curSelected.getMidpoint().x, curSelected.getMidpoint().y);

		optionsGroup.forEachAlive((o) ->
		{
			o.alpha = (o == curSelected) ? 1 : 0.5;
			o.selected = (o == curSelected);
		});
	}

	function get_curSelected():Option
	{
		return optionsGroup.members[itemIndex];
	}
}
