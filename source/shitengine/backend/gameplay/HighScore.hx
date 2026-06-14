package shitengine.backend.gameplay;

import flixel.util.FlxSave;
import lime.app.Application;

typedef RatingEntry =
{
	var rating:String;
	var time:Float;
}

typedef SongHighScoreEntry =
{
	var score:Int;
	var misses:Int;
	var ratings:Array<RatingEntry>;
	var accuracy:Float;
	var name:String;
}

class ScoreBoard
{
	public var songs:Map<String, SongHighScoreEntry>;

	public function new()
	{
		songs = new Map();
	}
}

class HighScore
{
	static var highScoreSave:FlxSave;

	public static var scoreBoard:ScoreBoard = new ScoreBoard();

	public static function init()
	{
		highScoreSave = new FlxSave();
		highScoreSave.bind("highscores");

		// Ensure save structure exists
		if (highScoreSave.data.songs == null)
		{
			highScoreSave.data.songs = {};
		}

		scoreBoard = new ScoreBoard();

		var raw:Dynamic = highScoreSave.data.songs;

		// LOAD (Dynamic -> Map)
		for (key in Reflect.fields(raw))
		{
			var entry:SongHighScoreEntry = cast Reflect.field(raw, key);
			scoreBoard.songs.set(key, entry);
		}

		// SAVE ON EXIT (Map -> Dynamic)
		Application.current.onExit.add((_) ->
		{
			var out:Dynamic = {};

			for (key in scoreBoard.songs.keys())
			{
				Reflect.setField(out, key, scoreBoard.songs.get(key));
			}

			highScoreSave.data.songs = out;
			highScoreSave.flush();
			highScoreSave = null;
		}, false, 999);
	}

	public static function postHighScore(entryName:String, entry:SongHighScoreEntry)
	{
		final formattedName = formatName(entryName);
		final old = scoreBoard.songs.get(formattedName);

		if (old != null && entry.score <= old.score)
			return;
		trace('New Highscore Points ${entry.score} for Song $entryName!');
		scoreBoard.songs.set(formattedName, entry);
	}

	public static function getHighScore(entryName:String):Int
	{
		final entry = getHighScoreEntry(entryName);
		return entry != null ? entry.score : 0;
	}

	public static function getHighScoreEntry(entryName:String):Null<SongHighScoreEntry>
	{
		return scoreBoard.songs.get(formatName(entryName));
	}

	public static function formatName(s:String):String
	{
		return s.toLowerCase().replace(" ", "-");
	}

	public static function getRatingMap(song:String):Map<String, Array<Float>>
	{
		var ratings:Map<String, Array<Float>> = [];
		var highscoreEntry = getHighScoreEntry(song);

		if (highscoreEntry == null)
			return ratings;

		for (rating in highscoreEntry.ratings)
		{
			if (!ratings.exists(rating.rating))
				ratings.set(rating.rating, []);

			ratings.get(rating.rating).push(rating.time);
		}

		return ratings;
	}
}
