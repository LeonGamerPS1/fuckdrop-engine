package shitengine.backend.data;

import flixel.FlxG;

typedef PreviewWindow =
{
	var startTime:Float;
	var endTime:Float;
}

typedef SongMetaDataRAW =
{
	var songDisplayName:String;
	var previewBPM:Float;
	var previewWindow:PreviewWindow;
	var volume:Float;
	var icon:String;
	var difficulties:Array<String>;
	var charter:String;
	var artist:String;
	var version:Int;
	var generatedBy:String;
}

class SongMetaData
{
	public var data:SongMetaDataRAW;

	public function new(path:String, skipError:Bool = false)
	{
		var raw:SongMetaDataRAW = null;
		if (path != null)
			raw = FlxG.assets.getJson(path);

		if (raw == null && !skipError)
			throw "Failed to load SongMetaData at: " + path;

		if (raw != null)
			data = cast raw;
	}

	public static function fromRaw(raw:SongMetaDataRAW)
	{
		var newMeta = new SongMetaData(null, true);
		newMeta.data = raw;
		return newMeta;
	}

	public static function fromString(jsonString:String)
	{
		return fromRaw(FlxG.assets.parseJson(jsonString));
	}

	public static function frompath(Path:String, skipErrors:Bool = false)
	{
		return new SongMetaData(Path, skipErrors);
	}
}
