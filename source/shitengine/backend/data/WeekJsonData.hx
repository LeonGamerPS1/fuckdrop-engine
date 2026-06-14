package shitengine.backend.data;

typedef WeekJson =
{
	var weekName:String;
	var weekDescription:String;
	var songs:Array<String>;
	var weekOrder:Int;
	var icons:Array<String>;
}

class WeekJsonData
{
	public static var weekCache:Map<String, WeekJson> = [];

	public static function getWeek(week:String)
	{
		if (weekCache.exists(week))
			return weekCache[week];
		var path = Paths.getPath('data/weeks/$week');
		if (!OpenFLAssets.exists(path, TEXT))
		{
			FlxG.log.error('week $path not found');
			return null;
		}
		var weekJSON:WeekJson = cast Json.parse(OpenFLAssets.getText(path));
		weekCache.set(week, weekJSON);
		return weekJSON;
	}

	public static function reload()
	{
		weekCache.clear();
		for (week in Paths.listDirectory('assets/data/weeks', TEXT))
		{
			var weekName = week.split('assets/data/weeks/')[1];
			getWeek(weekName);
		}
	}
}
