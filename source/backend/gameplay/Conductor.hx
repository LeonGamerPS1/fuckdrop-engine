package backend.gameplay;

import backend.data.SongChartData.SongTmPoint;
import lime.app.Event;

class Conductor
{
	public static var safeFrames:Int = 10;
	public static var sfz:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds
	public static var timeChanges:Array<SongTmPoint> = [];

	public static var time(default, set):Float = 0;
	public static var bpm(default, set):Float = 100;
	public static var beatLength = (60 / bpm) * 1000;
	public static var stepLength = (beatLength * 0.25);
	public static var measureLength:Float = (beatLength * 4);

	public static var curStep:Float = 0;
	public static var curBeat:Float = 0;
	public static var curSection:Float = 0;

	public static var onStep:Event<Float->Void> = new Event<Float->Void>();
	public static var onBeat:Event<Float->Void> = new Event<Float->Void>();
	public static var onMeasure:Event<Float->Void> = new Event<Float->Void>();

	static function set_time(value:Float):Float
	{
		update(time);
		return time = value;
	}

	public static function update(time:Float)
	{
		var flo = Math.floor;
		timeChanges.sort((tm:SongTmPoint, tm2:SongTmPoint) ->
		{
			return Math.floor(tm.time - tm2.time);
		});

		var lastStep = curStep;
		updateStep();
		if (flo(curStep) != flo(lastStep))
			onStep.dispatch(flo(curStep));

		var lastBeat = curBeat;
		updateBeat();
		if (flo(curBeat) != flo(lastBeat))
			onBeat.dispatch(flo(curBeat));

		var lastSec = curSection;
		updateSec();
		if (flo(curSection) != flo(lastSec))
			onMeasure.dispatch(flo(curSection));
	}

	static function set_bpm(value:Float):Float
	{
		bpm = value;
		beatLength = (60 / bpm) * 1000;
		stepLength = (beatLength / 4);
		measureLength = (beatLength * 4);

		return bpm = value;
	}

	public static function getTimeChangeAt(time:Float):SongTmPoint
	{
		var lastTimeChange:SongTmPoint = {time: 0, bpm: bpm};
		for (timeChange in timeChanges)
			if (timeChange.time <= (time - offset))
				lastTimeChange = timeChange;
		return lastTimeChange;
	}

	public static function addTimeChangeAt(time:Float, bpm:Float)
	{
		var lastTimeChange:SongTmPoint = {time: time, bpm: bpm};
		timeChanges.push(lastTimeChange);
		timeChanges.sort((tm:SongTmPoint, tm2:SongTmPoint) ->
		{
			return Math.floor(tm.time - tm2.time);
		});
	}

	public static function removeLatestTimeChangeAt(time:Float)
	{
		var lastTimeChange:SongTmPoint = getTimeChangeAt(time);
		if (lastTimeChange == null)
			return;
		timeChanges.remove(lastTimeChange);
		timeChanges.sort((tm:SongTmPoint, tm2:SongTmPoint) ->
		{
			return Math.floor(tm.time - tm2.time);
		});
	}

	public static var offset:Float = 0;

	public static function updateStep()
	{
		var songTime:Float = time - offset;

		// calculate step relative to that change
		curStep = songTime / stepLength;
	}

	public static function updateBeat()
	{
		curBeat = curStep / 4;
	}

	public static function updateSec()
	{
		curSection = curStep / 16;
	}
}
