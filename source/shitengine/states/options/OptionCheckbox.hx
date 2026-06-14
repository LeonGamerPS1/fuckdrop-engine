package shitengine.states.options;

class OptionCheckbox extends FunkinSprite
{
	public var option:Option;

	public function new(option:Option)
	{
		super(0, 0);
		this.option = option;
		loadAtlas("menus/options/checkbox", SPARROW);
		addAnimPrefix("unselected", "Check Box unselected");
		addAnimPrefix("selected", "Check Box selecting animation");

		playAnim("unselected");
		scale.set(0.9, 0.9);
		updateHitbox();
		playAnim(option.value ? "selected" : "unselected");
		option.onValChange.add((option:Option) ->
		{
			playAnim(option.value ? "selected" : "unselected");
		});

		antialiasing = true;
	}

	override function update(elapsed:Float)
	{
		var targetX = option.x + option.displayText?.width + 20;
		var targetY = option.y + (option.displayText?.height / 2 - height / 2);
		if (x != targetX)
			x = targetX;
		if (y != targetY)
			y = targetY;
		super.update(elapsed);
	}
}
