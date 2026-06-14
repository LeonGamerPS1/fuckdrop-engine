package shitengine.backend.assets;

import flixel.util.FlxSignal.FlxTypedSignal;
import haxe.io.Path;
import shitengine.backend.assets.Paths;
import shitengine.backend.data.MusicMetaData;

class ShitTrack extends FlxSound
{
	public var data:MusicMetaData;

	var _addedSignals:Bool = false;

	public var onBeatHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	public var onStepHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	override function destroy()
	{
		_addedSignals = false;

		Conductor.onBeat.remove(hitBeat);
		Conductor.onStep.remove(hitStep);

		onBeatHit.destroy();
		onStepHit.destroy();

		super.destroy();
	}

	public function loadFromMetadataID(fileID:String):ShitTrack
	{
		var soundPath = Paths.getPath('music/$fileID.${#if flash SoundExtension.MP3 #else SoundExtension.OGG #end}');
		var metaPath = soundPath.replace(Path.extension(soundPath), 'json');

		if (!Paths.exists(metaPath))
		{
			trace('Failed to locate music metadata path: "$metaPath"');
			return this;
		}

		data = FlxG.assets.getJson(metaPath);

		if (data == null)
		{
			throw 'Unparsable music metadata: "$metaPath"';
			return this;
		}

		if (data.timingChanges == null)
		{
			throw 'Missing timing changes in audio metadata: "$metaPath"';
			return this;
		}

		if (data.timingChanges?.length == 0)
		{
			throw 'Missing timing change entries in audio metadata: "$metaPath"';
			return this;
		}

		Conductor.bpm = data.timingChanges[0].bpm;
		data.timingChanges.remove(data.timingChanges[0]);

		for (timingChange in data.timingChanges)
			Conductor.addTimeChangeAt(timingChange.time, timingChange.bpm);

		if (!_addedSignals)
		{
			_addedSignals = true;

			Conductor.onBeat.add(hitBeat);
			Conductor.onStep.add(hitStep);
		}

		load(soundPath);

		return this;
	}

	function hitBeat(beat:Float)
		onBeatHit.dispatch(Math.floor(beat));

	function hitStep(step:Float)
		onStepHit.dispatch(Math.floor(step));
}
