package shitengine.states.gameplay;

import shitengine.backend.assets.ShitTrack;
import shitengine.backend.gameplay.HighScore.SongHighScoreEntry;
import shitengine.backend.gameplay.HighScore;

class Results extends MusicState
{
	var highscoreEntry:SongHighScoreEntry;
	var ratingMap:Map<String, Array<Float>> = [];

	public function new(highscoreEntry:SongHighScoreEntry)
	{
		super();

		this.highscoreEntry = highscoreEntry;
		this.ratingMap = HighScore.getRatingMap(this.highscoreEntry.name);
	}

	var resultsOST:ShitTrack;

	override function create()
	{
		super.create();

		resultsOST = new ShitTrack().loadFromMetadataID('results/resultsNORMAL');
		resultsOST.play();

		resultsOST.onBeatHit.add(onBeatHit);
		resultsOST.onStepHit.add(onStepHit);

		trace(ratingMap);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		Conductor.time = resultsOST.time;
	}
}
