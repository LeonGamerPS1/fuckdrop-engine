package shitengine.backend;

typedef Sskindat =
{
	var fallback:Sskindat;
	var scale:Float;
	var image:String;
	var splashImage:String;
	var antialiasing:Bool;
	var name:String;
	@:optional var susScale:Float;
	@:optional var disableRGB:Bool;
	@:optional var splashScale:Float;
	@:optional var fps:Int;
}

class NoteSkin
{
	public static var strumDirections:Array<Array<String>> = [
		['up'], // 1K
		['left', 'right'], // 2K
		['left', 'down', 'right'], // 3K
		['left', 'down', 'up', 'right'], // 4K
		['left', 'up', 'down', 'up', 'right'], // 5K
		['left', 'up', 'down', 'left', 'down', 'right'] // 6K
	];

	public static var noteColors:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var noteScaleMults:Array<Float> = [
		1, // 1K
		1, // 2K
		1, // 3K
		0.97, // 4K
		0.97, // 5K
		0.9 // 6K
	];

	public static function getSkin(skin:String):Sskindat
	{
		var sus = haxe.Json.parse(OpenFLAssets.getText(Paths.getPath("images/noteskins/bbs/skin.json".replace("bbs", skin))));
		sus.name = skin;
		return sus;
	}
}
