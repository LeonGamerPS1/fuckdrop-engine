package states.sub;

import states.menus.FreeplayState;
import states.menus.MainMenuState;

class PauseSubState extends FlxSubState
{
	var itemsA:Array<String> = [
		'Continue',
		'Reboot',
		'Toggle BotPlay (invalidates current run)',
		'Exit to Main Menu',
		'Exit to freeplay'
	];

	public var itemIndex:Int = 0;
	public var item:Alphabet;
	public var items:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();

	override function create()
	{
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		var h:FunkinSprite = cast new FunkinSprite(0, 0).makeGraphic(1, 1, 0x75000000);
		h.scale.set(2000, 2000);
		h.updateHitbox();
		add(h);

		add(items);
		for (item in itemsA)
		{
			var songOBJ = new Alphabet(0, 0, item, true);
			songOBJ.alpha = 0.7;
			items.add(songOBJ);
			songOBJ.isMenuItem = true;
			songOBJ.targetY = items.length - 1;
		}
		super.create();
	}

	function changeSelection(add:Int = 0)
	{
		item = items.members[itemIndex];
		item.alpha = 0.5;

		itemIndex = FlxMath.wrap(itemIndex + add, 0, items.length - 1);
		item = items.members[itemIndex];
		item.alpha = 1;
		FlxG.sound.play(Paths.getSound('sounds/scrollMenu'));
	}

	override function update(dT:Float)
	{
		super.update(dT);
		if (inputSystem.ACCEPT && item != null)
		{
			switch (item.text.toLowerCase())
			{
				case 'continue':
					close();
				case 'reboot':
					closeCallback = null;
					close();
					FlxG.resetState();
				case 'toggle botplay (invalidates current run)':
					SaveData.currentSettings.botplay = !SaveData.currentSettings.botplay;
					PlayState.instance.invalidatedRun = SaveData.currentSettings.botplay;

				case 'exit to main menu':
					closeCallback = null;
					close();
					FlxG.switchState(() -> new MainMenuState());

				case 'exit to freeplay':
					closeCallback = null;
					close();

					FlxG.switchState(() -> new FreeplayState());
			}
		}
		else if (inputSystem.UI_DOWN_P)
			changeSelection(1);
		else if (inputSystem.UI_UP_P)
			changeSelection(-1);
		else if (inputSystem.BACK)
		{
			close();
		}

		for (i in 0...items.length)
		{
			var item = items.members[i];
			item.targetY = i - itemIndex;
		}
	}
}
