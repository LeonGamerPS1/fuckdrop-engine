package objects.gameplay;

class Playfield extends FlxGroup
{
	public var dadStrumline:Strumline;
	public var bfStrumline:Strumline;

	public function new(skin:String = "default")
	{
		super();

		dadStrumline = cast(add(new Strumline(this, skin)));
		bfStrumline = cast(add(new Strumline(this, skin)));
	}
}
