package shitengine.backend.gameplay;

import lime.app.Event;
import shitengine.backend.data.MusicTimeChangePoint;

class Conductor
{
	public static var safeFrames:Int = 10;
	public static var sfz:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds
	public static var timeChanges:Array<MusicTimeChangePoint> = [];

	public static var time(default, set):Float = 0;
	public static var bpm(default, set):Float = 100;
	public static var beatLength = (bpm / 60) * 1000;
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
		timeChanges.sort((tm:MusicTimeChangePoint, tm2:MusicTimeChangePoint) ->
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

	public static function getTimeChangeAt(time:Float):MusicTimeChangePoint
	{
		var lastTimeChange:MusicTimeChangePoint = {time: 0, bpm: bpm};
		for (timeChange in timeChanges)
			if (timeChange.time <= (time - offset))
				lastTimeChange = timeChange;
		return lastTimeChange;
	}

	public static function addTimeChangeAt(time:Float, bpm:Float)
	{
		var lastTimeChange:MusicTimeChangePoint = {time: time, bpm: bpm};
		timeChanges.push(lastTimeChange);
		timeChanges.sort((tm:MusicTimeChangePoint, tm2:MusicTimeChangePoint) ->
		{
			return Math.floor(tm.time - tm2.time);
		});
	}

	public static function removeLatestTimeChangeAt(time:Float)
	{
		var lastTimeChange:MusicTimeChangePoint = getTimeChangeAt(time);
		if (lastTimeChange == null)
			return;
		timeChanges.remove(lastTimeChange);
		timeChanges.sort((tm:MusicTimeChangePoint, tm2:MusicTimeChangePoint) ->
		{
			return Math.floor(tm.time - tm2.time);
		});
	}

	public static var offset:Float = 0;

	public static function updateStep()
	{
		// calculate step relative to that change
		curStep = getStep(time);
	}

	public static function updateBeat()
	{
		curBeat = curStep / 4;
	}

	public static function updateSec()
	{
		curSection = curStep / 16;
	}

	public static function getStep(time:Float):Float
	{
		var step:Float = 0;
		var lastTime:Float = 0;
		var lastBpm:Float = bpm;

		for (i in 0...timeChanges.length)
		{
			var tc = timeChanges[i];

			if (tc.time >= time)
				break;

			var stepLen = (60 / lastBpm) * 1000 / 4;

			step += (tc.time - lastTime) / stepLen;

			lastTime = tc.time;
			lastBpm = tc.bpm;
		}
		if (bpm != lastBpm)
			bpm = lastBpm;

		var stepLenFinal = (60 / lastBpm) * 1000 / 4;
		step += (time - lastTime) / stepLenFinal;

		return step;
	}

	public static function getBeat(time:Float)
	{
		return getStep(time) / 4;
	}
}
