package backend;

typedef NoteSkinD =
{
	var scale:Float;
	var antialiasing:Bool;
	var image:String;
	var splashImage:String;
}

class NoteSkin
{
	public static function getSkin(skin:String = "default")
	{
		return FlxG.assets.getText(Paths.getPath('images/noteskins/$skin/skin.json'));
	}
}
