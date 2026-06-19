package shitengine.states.menus;

import flixel.addons.transition.FlxTransitionableState;
import shitengine.states.options.*;

class OptionsState extends FlxTransitionableState
{
	var categories = ['visuals and ui', 'gameplay', 'controls'];
	var curSelected:Alphabet;
	var itemIndex:Int = 0;
	var itemGroup:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();

	override function create()
	{
		super.create();
		var bg:FunkinSprite = new FunkinSprite(0, 0, Paths.getGraphic("menus/menuDesat"));
		add(bg);

		add(itemGroup);

		for (catName in categories)
		{
			var text:Alphabet = new Alphabet(0, 55, catName, true);
			text.y += (100 * itemGroup.length);
			text.x = -FlxG.width / 2;
			text.antialiasing = true;
			itemGroup.add(text);
		}

		changeSelected(0);
	}

	function changeSelected(addition:Int)
	{
		if (addition != 0)
			FlxG.sound.play(Paths.getSound("sounds/scrollMenu"));

		itemIndex += addition;
		itemIndex = FlxMath.wrap(itemIndex, 0, itemGroup.length - 1);
		var sprite = itemGroup.members[itemIndex];
		itemGroup.forEachAlive((o) ->
		{
			o.alpha = o == sprite ? 1 : 0.5;
			o.screenCenter(X);
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (inputSystem.UI_DOWN_P)
			changeSelected(1);
		else if (inputSystem.UI_UP_P)
			changeSelected(-1);
		else if (inputSystem.BACK)
			FlxG.switchState(() -> new MainMenuState());
		else if (inputSystem.ACCEPT)
		{
			FlxG.sound.play(Paths.getSound("sounds/confirmMenu"));
			switch (categories[itemIndex])
			{
				default:
					FlxG.resetState();
				case 'gameplay':
					FlxG.switchState(() -> new shitengine.states.options.Gameplay());
				case 'controls':
					openSubState(new shitengine.states.options.subs.ControlsSubstate());
				case "visuals and ui":
					FlxG.switchState(() -> new shitengine.states.options.UI_and_Looks());
			}
		}
	}
}
