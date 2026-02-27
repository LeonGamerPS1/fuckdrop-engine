package objects.gameplay;

class Strumline extends FlxGroup
{
	public var playfield:Playfield;
    public var bot:Bool = false;

	public function new(pf:Playfield, skin:String = "default")
	{
		super();
		this.playfield = pf;
	}
}
