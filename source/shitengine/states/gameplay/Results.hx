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

	var lines:Array<String> = [];

	override function create()
	{
		super.create();

		resultsOST = new ShitTrack().loadFromMetadataID('results/resultsNORMAL');
		resultsOST.play();

		resultsOST.onBeatHit.add(onBeatHit);
		resultsOST.onStepHit.add(onStepHit);

		lines.push('sicks:');
		for (key => value in ratingMap) {}

		// trace(ratingMap);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		Conductor.time = resultsOST.time;
	}
}
