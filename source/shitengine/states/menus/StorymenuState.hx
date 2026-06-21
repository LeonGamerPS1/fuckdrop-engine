package shitengine.states.menus;

import shitengine.backend.data.WeekJsonData;

class StorymenuState extends FlxTransitionableState
{
	public var weeks:FlxSpriteGroup;

	var weekJsons:Array<WeekJson> = [];
	var CurSelected = 0;
	var txtWeekTitle:FlxText;

	public override function create()
	{
		WeekJsonData.reload();
		weeks = new FlxSpriteGroup();
		add(weeks);

		var i = 0;
		for (week in WeekJsonData.getOrderedWeeks())
		{
			var weekSpr:FunkinSprite = new FunkinSprite(0, 500 + (109 * i), Paths.getGraphic('menus/story/titles/${week.weekName}'));
			weekSpr.screenCenter(X);
			weekSpr.antialiasing = true;
			weekSpr.ID = i;
			weeks.add(weekSpr);
			weekJsons.push(week);
			i++;
		}
		super.create();
		add(new FunkinSprite(0, 56).solidColor(FlxG.width, 400, 0xFFF9CF51));

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat(Paths.getFont("vcr"), 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;
		txtWeekTitle.antialiasing = true;
		add(txtWeekTitle);

		changeSelection();
	}

	public function changeSelection(add:Int = 0)
	{
		CurSelected += add;
		CurSelected = FlxMath.wrap(CurSelected, 0, weekJsons.length - 1);
		for (item in weeks)
		{
			item.alpha = item.ID != CurSelected ? 0.5 : 1;
		}
		txtWeekTitle.text = weekJsons[CurSelected].weekDescription.toUpperCase();
			txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (inputSystem.UI_DOWN_P)
			changeSelection(1);
		if (inputSystem.UI_UP_P)
			changeSelection(-1);
		if(inputSystem.BACK)
			FlxG.switchState(()->new MainMenuState());

		for (item in weeks)
		{
			final yADD = -109 * CurSelected;
			item.y = FlxMath.lerp(500 + (109 * item.ID) + yADD, item.y, Math.exp(-elapsed * 3));
			item.visible = item.active = (item.y > 480 - item.height);
		}
	}
}
