package shitengine.backend.data;

typedef StageJSON =
{
	var bfPos:Array<Int>;
	var dadPos:Array<Int>;
	var gfPos:Array<Int>;
	var zoom:Float;
}

class SongStageData
{
	public static function getStageJSON(stage:String = "mainStage"):StageJSON
	{
		var path = 'data/stages/$stage.json';
		if (!OpenFLAssets.exists(Paths.getPath(path), TEXT))
		{
			stage = 'mainStage';
			path = 'data/stages/mainStage.json';
		}

		return cast haxe.Json.parse(OpenFLAssets.getText(Paths.getPath(path)));
	}
}
