package states.gameplay;

import backend.data.SongChartData;
import backend.gameplay.SongLoader;

class Charter extends FlxTransitionableState
{
	var song:SongChartData = SongLoader.loadSong('bopeebo', 'easy');

	public function new(song:SongChartData)
	{
		super();
		if (song != null)
			this.song = song;
	}

	var inst:FlxSound;

	override function create()
	{
		Conductor.bpm = song.data.bpm;
		Conductor.time = 0;
		trace(msToY(song.data.notes[0].tms, Conductor.bpm));

		inst = new FlxSound().load(Paths.getSound(song.songFolder + '/audio/' + song.data.characters.instPath, true));
        FlxG.sound.list.add(inst);
        inst.play();
        inst.pause();
        // it wont do anything otherwise ok
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (inputSystem.BACK)
			FlxG.switchState(() -> new PlayState());
		if (inst.playing)
			Conductor.time = inst.time;
		if (inputSystem.ACCEPT)
			togglePause();
	}

	function togglePause()
	{
		if (inst.playing)
			inst.pause();
		else
			inst.resume();
	}

	public static function yToMs(y:Float, bpm:Float):Float
	{
		var step:Float = y / Constants.GRID_SIZE;
		var beat:Float = step / Constants.STEPS_PER_BEAT;
		return beat * (60000 / bpm);
	}

	public static function msToY(ms:Float, bpm:Float):Float
	{
		var beat:Float = ms / (60000 / bpm);
		var step:Float = beat * Constants.STEPS_PER_BEAT;
		return step * Constants.GRID_SIZE;
	}
}
