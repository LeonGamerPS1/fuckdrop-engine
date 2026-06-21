package shitengine.states.menus;

import shitengine.states.gameplay.LoadingScreen;
import shitengine.states.options.subs.VSLICEFreeplay;

class MainMenuState extends flixel.addons.transition.FlxTransitionableState
{
	public static var items:Array<String> = ["playstate", "story_mode", "freeplay", "credits", "options"];

	public var itemGroup:FlxTypedGroup<FunkinSprite>;
	public var itemIndex:Int = 0;

	public var bg:FunkinSprite;
	public var camTarget:FlxObject;

	public override function create()
	{
		super.create();

		bg = new FunkinSprite(0, -50, Paths.getGraphic("menus/menuDesat"));
		bg.scale.set(1.4, 1.4);
		bg.scrollFactor.set(0, 0.2);
		bg.updateHitbox();
		bg.antialiasing = true;
		bg.color = FlxColor.YELLOW;
		add(bg);

		itemGroup = new FlxTypedGroup<FunkinSprite>();
		add(itemGroup);

		camTarget = new FlxObject(0, 0, 1, 1);
		FlxG.camera.follow(camTarget, 0.06);
		add(camTarget);

		for (itemID in items)
		{
			var item:FunkinSprite = new FunkinSprite(0, 50);
			item.loadAtlas('menus/main/$itemID', SPARROW);
			item.addAnimPrefix('idle', '$itemID idle', 24, true);
			item.addAnimPrefix('selected', '$itemID selected', 24, true);
			item.playAnim("idle");
			item.updateHitbox();
			item.scrollFactor.y = 0.75;
			item.antialiasing = true;
			item.screenCenter(X);
			item.y += (230 * 0.7 * itemGroup.length);
			itemGroup.add(item);
		}
		changeSelected(0);

		var text:FlxText = new FlxText();
		text.setFormat(Paths.getFont('vcr'), 20, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
		var someshitig = 'Git Commit(' + Constants.gitcommit + ')' + ' Release version ' + Main.version;
		text.text = 'FNF 0.2.8\nShit Engine ' + someshitig;
		text.y = FlxG.height - text.height * 1.1;
		text.scrollFactor.set();
		add(text);
	}

	public function changeSelected(addition:Int = 0)
	{
		if (addition != 0)
			FlxG.sound.play(Paths.getSound("sounds/scrollMenu"));

		itemIndex += addition;
		itemIndex = FlxMath.wrap(itemIndex, 0, itemGroup.length - 1);
		var sprite = itemGroup.members[itemIndex];
		camTarget.setPosition(sprite.getMidpoint().x, sprite.getMidpoint().y);
		itemGroup.forEachAlive((o) ->
		{
			o.playAnim(o == sprite ? 'selected' : 'idle');
			o.updateHitbox();
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
		if (inputSystem.ACCEPT && !exiting)
		{
			var curSelected = itemGroup.members[itemIndex];
			for (item in itemGroup)
				if (item != curSelected)
					FlxTween.tween(item, {alpha: 0}, 0.3);
			FlxG.sound.play(Paths.getSound("sounds/confirmMenu"));
			new FlxTimer().start(0.6, (?e) -> exit(items[itemIndex]));
			exiting = true;
		}
	}

	var exiting = false;

	public function exit(itemSelected:String)
	{
		var curSelected = itemGroup.members[itemIndex];
		switch (itemSelected)
		{
			default:
				exiting = false;
				for (item in itemGroup)
					FlxTween.tween(item, {alpha: 1}, 0.3);
				curSelected.color = FlxColor.RED;
				FlxTween.color(curSelected, 0.3, curSelected.color, 0xFFFFFFFF);
				FlxG.camera.shake(0.01, 0.3);
				FlxG.sound.play(Paths.getSound("sounds/cancelMenu"));
			case "playstate":
				FlxG.switchState(() -> new LoadingScreen('bopeebo', 'hard'));
			case "story_mode":
				FlxG.switchState(() -> new StorymenuState());
			case "freeplay":
				FlxG.switchState(() -> new FreeplayState());
			case "options":
				FlxG.switchState(() -> new OptionsState());
		}
	}
}
