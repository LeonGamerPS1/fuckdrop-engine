package objects.ui;

class HealthIcon extends FunkinSprite
{
	public var char:String = 'bf';
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;
	public var baseScale:Float = 1;

	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(?char:String = "bf", ?isPlayer:Bool = false)
	{
		super();

		this.char = char;
		this.isPlayer = isPlayer;

		isPlayer = isOldIcon = false;

		changeIcon(char);
	}

	public function swapOldIcon()
	{
		(isOldIcon = !isOldIcon) ? changeIcon("bf-old") : changeIcon(char);
	}

	public function changeIcon(char:String)
	{
		if (!OpenFLAssets.exists(Paths.getPath('images/icons/icon-' + char + '.png')))
			char = 'face';

		var graphic = Paths.getGraphic('icons/icon-' + char);
		loadGraphic(Paths.getGraphic('icons/icon-' + char), true, graphic.height, graphic.height);

		if (char.endsWith('-pixel') || char.startsWith('senpai') || char.startsWith('spirit'))
			antialiasing = false;
		else
			antialiasing = true;

		animation.add(char, [for (i in 0...frames.frames.length) i], 0, false, isPlayer);
		animation.play(char);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 50, sprTracker.y + (sprTracker.height * .5 - frameHeight * .5));
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		centerOffsets();
		centerOrigin();
	}
}
