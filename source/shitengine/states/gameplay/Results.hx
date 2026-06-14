package shitengine.states.gameplay;

import shitengine.backend.gameplay.HighScore.SongHighScoreEntry;
import shitengine.backend.gameplay.HighScore;

class Results extends FlxTransitionableState
{
	var highscoreEntry:SongHighScoreEntry;
	var ratingMap:Map<String, Array<Float>> = [];

	public function new(highscoreEntry:SongHighScoreEntry)
	{
		super();

		this.highscoreEntry = highscoreEntry;
        this.ratingMap = HighScore.getRatingMap(this.highscoreEntry.name);
	}

	override function create()
	{
		super.create();
	}
}
