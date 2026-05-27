package states;

import backend.data.SongChartData;
import backend.data.SongStageData.StageJSON;
import backend.data.SongStageData;
import backend.gameplay.HighScore.SongHighScoreEntry;
import backend.gameplay.HighScore;
import backend.gameplay.SongLoader;
import backend.scripting.NxScriptM;
import flixel.math.FlxPoint;
import flixel.sound.FlxSoundGroup;
import flixel.tweens.FlxEase;
import haxe.Timer;
import nx.script.NativeProxy;
import objects.Note;
import objects.Playfield;
import objects.gameplay.Character;
import states.menus.MainMenuState;
import states.sub.PauseSubState;

class PlayState extends flixel.addons.transition.FlxTransitionableState
{
	public var playfield:Playfield;

	public static var song:SongChartData;

	public var inst:FlxSound;
	public var invalidatedRun(default, set):Bool = false;
	public var currentScoreEntry:SongHighScoreEntry = {
		score: 0,
		misses: 0,
		accuracy: 0,
		ratings: [],
		name: ""
	};

	public var enemyVocals:FlxSoundGroup;
	public var playerVocals:FlxSoundGroup;

	public var camGame(get, null):FlxCamera;
	public var camUnderlay:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOverlay:FlxCamera;

	// enemy
	public var dadLayer:FlxGroup;
	public var dadPosition:FlxPoint = FlxPoint.get(100, 100);

	// gf
	public var gfLayer:FlxGroup;
	public var gfPosition:FlxPoint = FlxPoint.get(400, 130);

	// player
	public var boyfriendLayer:FlxGroup;
	public var boyfriendPosition:FlxPoint = FlxPoint.get(770, 100);

	public var dad:Character;
	public var gf:Character;
	public var bf:Character;

	public var camtracker:FlxObject = new FlxObject(0, 0, 1, 1);

	public var stageJSON:StageJSON;

	public static var instance:PlayState;

	override public function create()
	{
		instance = this;
		FlxG.fixedTimestep = FlxG.autoPause = false;
		final songFolder = song.songFolder;
		FlxG.sound.music?.stop();
		camUnderlay = new FlxCamera();
		FlxG.cameras.add(camUnderlay, false);
		camHUD = new FlxCamera();
		FlxG.cameras.add(camHUD, false);
		camOverlay = new FlxCamera();
		FlxG.cameras.add(camOverlay, false);
		loadNXScripts(Paths.listDirectory('assets/$songFolder/scripts'));
		loadNXScripts(Paths.listDirectory('assets/data/scripts'));

		Conductor.timeChanges.resize(0);
		super.create();
		song ??= SongLoader.loadSong("bopeebo");
		currentScoreEntry.name = HighScore.formatName(song.meta.data.songDisplayName);
		stageJSON = SongStageData.getStageJSON(song.data.stage);
		boyfriendPosition.set(stageJSON.bfPos[0], stageJSON.bfPos[1]);
		dadPosition.set(stageJSON.dadPos[0], stageJSON.dadPos[1]);
		gfPosition.set(stageJSON.gfPos[0], stageJSON.gfPos[1]);
		defaultZoomGame = stageJSON.zoom;

		Conductor.bpm = song.data.bpm;
		Conductor.time = -(Conductor.beatLength * 5);

		var instPath = '$songFolder/audio/${song.data.characters.instPath}';
		inst = FlxG.sound.list.add(new FlxSound());
		inst.load(Paths.getSound(instPath, true), false);

		enemyVocals = new FlxSoundGroup();
		playerVocals = new FlxSoundGroup();

		for (vocalEnemy in song.data.characters.enemyVocals)
		{
			var vocalPath = '$songFolder/audio/${vocalEnemy}';
			var flxsound:FlxSound = new FlxSound();
			flxsound.load(Paths.getSound(vocalPath, true), false);
			enemyVocals.add(flxsound);
		}
		for (playerVocal in song.data.characters.playerVocals)
		{
			var vocalPath = '$songFolder/audio/${playerVocal}';
			var flxsound:FlxSound = new FlxSound();
			flxsound.load(Paths.getSound(vocalPath, true), false);
			playerVocals.add(flxsound);
		}
		add(playfield = new Playfield(song, song.data.noteStyle));
		set('modchart', playfield.modchartSystem);
		playfield.cameras = playfield.modchartingCameras = [camHUD];
		// playfield.modchartingCamera = camHUD;

		set('playfield', playfield);
		camGame.bgColor = 0x0;
		for (strumLines in [playfield.dadStrumline, playfield.bfStrumline])
		{
			strumLines.onHitNote.add(hitNote);
			strumLines.onMissNote.add(missNote);
		}
		Conductor.onMeasure.add((e) ->
		{
			sectionHit();
		});
		Conductor.onBeat.add((e) ->
		{
			beatHit();
		});
		Conductor.onStep.add((e) ->
		{
			stepHit();
		});
		loadNXScript('assets/data/stages/${song.data.stage}.nx');

		call('onCreate');
		call('onStageLoad', [stageJSON, song.data.stage]);

		gfLayer = new FlxGroup();
		dadLayer = new FlxGroup();
		boyfriendLayer = new FlxGroup();

		add(gfLayer);
		add(dadLayer);
		add(boyfriendLayer);

		if (song.data.characters.dad == song.data.characters.gf)
		{
			dadPosition.copyFrom(gfPosition);
			gfLayer.kill();
		}
		dad = new Character(0, 0, song.data.characters.dad);
		dad.setPosition(dadPosition.x, dadPosition.y);
		dad.setPosition(dad.x + dad.json.pos_offset[0], dad.y + dad.json.pos_offset[1]);

		gf = new Character(0, 0, song.data.characters.gf);
		gf.setPosition(gfPosition.x, gfPosition.y);
		gf.setPosition(gf.x + gf.json.pos_offset[0], gf.y + gf.json.pos_offset[1]);

		bf = new Character(0, 0, song.data.characters.boyfriend, true);
		bf.setPosition(boyfriendPosition.x, boyfriendPosition.y);
		bf.setPosition(bf.x + bf.json.pos_offset[0], bf.y + bf.json.pos_offset[1]);

		gfLayer.add(gf);
		dadLayer.add(dad);
		boyfriendLayer.add(bf);

		focusCharList = [bf, dad, gf];

		playfield.dadStrumline.char = dad;
		playfield.bfStrumline.char = bf;

		camGame.follow(camtracker, LOCKON, 0.06);
		add(camtracker);

		song.data.events ??= [];
		for (event in song.data.events)
		{
			onEventLoad(event);
			events.push(event);
		}
		events.sort((e, e2) -> return e.t - e2.t);
		startCallback();

		focusOnChar(dad);
		camGame.snapToTarget();
		call('onCreatePost');

		playfield.iconP1.changeIcon(bf.json.icon);
		playfield.iconP2.changeIcon(dad.json.icon);
		invalidatedRun = SaveData.currentSettings.botplay;
		super.create();
	}

	public var scripts:Map<String, NxScriptM> = [];

	function loadNXScripts(paths:Array<String>)
	{
		for (hm in paths)
			loadNXScript(hm);
	}

	function loadNXScript(hm:String)
	{
		var script = scripts.get(hm);
		if (script != null)
			scripts.remove(hm);
		script?.dispose();
		if (!OpenFLAssets.exists(hm))
			return;
		trace(hm);
		script = new NxScriptM(hm, hm);
		scripts.set(hm, script);
		script.setVariable('isPlayState', true);
		script.call('new');
	}

	public function call(fn:String, ?fv:Array<Dynamic>):Dynamic
	{
		var value:Dynamic = null;

		for (script in scripts.keyValueIterator())
		{
			var result = script.value.call(fn, fv);

			if (result != null)
			{
				value = result;
			}
		}

		return value;
	}

	public function set(n:String, v:Dynamic)
	{
		for (script in scripts.keyValueIterator())
			script.value.setVariable(n, v);
	}

	public var events:Array<SongEventData> = [];

	public function get_camGame()
	{
		return FlxG.camera;
	}

	public function hitNote(n:Note)
	{
		call('onNoteHit', [n]);
		if (!n.strumline.isBot)
		{
			playerVolume = 1;
			if (!n.isSustainNote)
			{
				if (SaveData.currentSettings.hitSounds)
					FlxG.sound.play(Paths.getSound('sounds/hitsound'), 0.7);
				currentScoreEntry.ratings.push({rating: n.rating, time: Conductor.time});
			}
		}
		else
			enemyVolume = 1;
	}

	public function missNote(n:Note, ?dir:Int, strumline)
	{
		call('onNoteMiss', [n, dir, strumline]);
		if (!strumline.isBot)
			playerVolume = 0;
		else
			enemyVolume = 0;
	}

	var autoFocus:Bool = true;

	public function onEventLoad(event:SongEventData)
	{
		call("onEventLoad", [event]);
		switch (event.n)
		{
			case 'change character':
				var charname = event.v[0];
				var chartoreplace = event.v[1];
				var charOBJ = getCharFromString(chartoreplace);
				var oldchar = charOBJ.curCharacter;
				charOBJ.loadJson(charname ?? charOBJ.curCharacter);
				charOBJ.loadJson(oldchar);
				playfield.iconP1.changeIcon(bf.json.icon);
				playfield.iconP2.changeIcon(dad.json.icon);
		}
	}

	public var focusCharList:Array<Character> = [];

	public function onEventTrigger(event:SongEventData)
	{
		call("onEventTrigger", [event]);
		switch (event.n)
		{
			case 'change character':
				var charname = event.v[0];
				var chartoreplace = event.v[1];
				var charOBJ = getCharFromString(chartoreplace);
				charOBJ.loadJson(charname ?? charOBJ.curCharacter);
				var pos = charOBJ.player ? boyfriendPosition : dadPosition;
				charOBJ.setPosition(pos.x + charOBJ.json.pos_offset[0], pos.y + charOBJ.json.pos_offset[1]);
			case 'focus on character', 'FocusCamera':
				var character = null;

				switch (event.v.length)
				{
					default:
						character = getCharFromString(event.v[0]);
					case 5:
						character = focusCharList[event.v[4]];
				}
				focusOnChar(character);
			case 'PlayAnimation':
				var anim = event.v[0];
				var char = getCharFromString(event.v[1]);
				char.playAnim(anim, event.v[2]);
				if (char.animation.curAnim != null)
					char.holdTimer = char.animation.numFrames / char.animation.curAnim.frameRate;
			case 'ZoomCamera':
				switch (event.v.length)
				{
					default:
						var ease = Reflect.getProperty(FlxEase, event.v[0]);
						var steeLength:Float = event.v[1] * Conductor.stepLength;
						var direct:Bool = event.v[2] != 'stage';
						var zoom:Float = event.v[3];
						var zoomTarget = direct ? zoom : zoom * stageJSON.zoom;

						FlxTween.num(camGame.zoom, zoomTarget, steeLength / 1000, {ease: ease}, (val) ->
						{
							defaultZoomGame = val;
							camGame.zoom = val;
						});

					case 3:
						var ease = Reflect.getProperty(FlxEase, event.v[0]);
						var length = (Conductor.stepLength * event.v[1]) * 0.001;
						var zoom = event.v[2];
						FlxTween.num(camGame.zoom, zoom, length, {ease: ease}, (v:Float) ->
						{
							camGame.zoom = v * stageJSON.zoom;
							defaultZoomGame = camGame.zoom;
						});
				}
			case 'SetCameraBop':
				sectionBops = event.v[0];
		}
	}

	public function getCharFromString(charname:Dynamic):Character
	{
		if (charname is Int)
			return focusCharList[charname];
		var customChar = null;
		var char:Character = customChar;

		if (char == null)
		{
			switch (charname)
			{
				case "gf", 'girlfriend':
					char = gf;
				case "dad", 'opponent':
					char = dad;
				case "bf", 'boyfriend':
					char = bf;
			}
		}
		return char;
	}

	public var canPause:Bool = true;

	public function focusOnChar(char:Character)
	{
		if (char.player)
		{
			camtracker.setPosition(char.getMidpoint().x - 100, char.getMidpoint().y - 100);
			camtracker.x -= char.json.cam_offset[0];
			camtracker.y += char.json.cam_offset[1];
		}
		else
		{
			camtracker.setPosition(char.getMidpoint().x + 160, char.getMidpoint().y - 100);
			camtracker.x += char.json.cam_offset[0];
			camtracker.y += char.json.cam_offset[1];
		}
	}

	public var playerVolume:Float = 1;
	public var enemyVolume:Float = 1;
	public var focusLost:Bool = false;
	public var startTimer:FlxTimer;

	override function onFocusLost()
	{
		super.onFocusLost();
		focusLost = true;
		if (paused)
			return;
		pauseOrSmth();
	}

	override function onFocus()
	{
		super.onFocus();
		focusLost = false;
		if (paused)
		{
			inst.pause();
			for (shit in playerVocals.sounds.concat(enemyVocals.sounds))
				shit.pause();
		}
	}

	var startedCountdown:Bool = false;
	var startedSong:Bool = false;

	dynamic public function startCallback()
	{
		startCountdown();
	}

	public var camBopMult:Float = 1;
	public var hudBopMult:Float = 1;
	public var defaultZoomHUD:Float = 1;
	public var defaultZoomGame:Float = 1;

	public function sectionHit()
	{
		for (vocalSFX in playerVocals.sounds.concat(enemyVocals.sounds))
		{
			if (paused)
				break;
			if (!vocalSFX.playing || !inst.playing || Math.floor(Conductor.curBeat) % 2 != 0)
				continue;
			if (Math.abs(Conductor.time - vocalSFX.time) > 200)
				vocalSFX.time = Conductor.time;
		}
		call('sectionHit', [Math.floor(Conductor.curSection)]);
	}

	var sectionBops = 4;

	public override function destroy()
	{
		call('destroy');
		for (vocalSFX in playerVocals.sounds.concat(enemyVocals.sounds))
		{
			vocalSFX.destroy();
			playerVocals.remove(vocalSFX);
			enemyVocals.remove(vocalSFX);
			vocalSFX = null;
		}
		playerVocals.sounds = null;
		enemyVocals.sounds = null;
		playerVocals = enemyVocals = null;
		super.destroy();
	}

	public function beatHit()
	{
		call('beatHit', [Math.floor(Conductor.curBeat)]);
		if (Math.floor(Conductor.curBeat) % sectionBops == 0)
		{
			FlxG.camera.zoom += 0.015 * camBopMult;
			camHUD.zoom += 0.03 * hudBopMult;
		}
	}

	public function stepHit()
	{
		call('stepHit', [Math.floor(Conductor.curStep)]);
	}

	public var paused:Bool = false;

	public function startSong()
	{
		startedSong = true;
		inst.play();
		inst.onComplete = onEndSong;
		playfield.progressBar.setRange(0, inst.length);
		FlxTween.tween(playfield.progressBar, {alpha: 1}, Conductor.beatLength / 1000);
		call('startSong');
		for (shit in playerVocals.sounds.concat(enemyVocals.sounds))
			shit.play();
	}

	public function startCountdown()
	{
		startedCountdown = true;
		startTimer = new FlxTimer().start(Conductor.beatLength / 1000, (t) ->
		{
			call('tickCountdown', [t]);
		}, 4);
		startTimer.active = true;
		call('startCountdown');
	}

	override public function update(elapsed:Float)
	{
		call('onUpdatePre', [elapsed]);
		if (currentScoreEntry.score != playfield.songScore)
			currentScoreEntry.score = playfield.songScore;
		if (currentScoreEntry.misses != playfield.misses)
			currentScoreEntry.misses = playfield.misses;
		if (currentScoreEntry.accuracy != playfield.accuracy)
			currentScoreEntry.accuracy = playfield.accuracy;
		FlxG.camera.zoom = FlxMath.lerp(defaultZoomGame, FlxG.camera.zoom, Math.exp(-elapsed * 6));
		camHUD.zoom = FlxMath.lerp(defaultZoomHUD, camHUD.zoom, Math.exp(-elapsed * 6));
		camUnderlay.zoom = camHUD.zoom;
		enemyVocals.volume = enemyVolume * inst.getActualVolume();
		playerVocals.volume = playerVolume * inst.getActualVolume();
		inst.volume = FlxG.sound.volume > 0 ? 1 : 0;

		if (!paused)
		{
			if (startedCountdown && !startedSong)
			{
				Conductor.time += elapsed * 1000;
				if (Conductor.time >= Conductor.offset)
				{
					startSong();
					Conductor.time = inst.time;
				}
			}
			else
			{
				Conductor.time = inst.time;
			}
		}

		if (events.length > 0)
		{
			var event = events[0];
			if (event == null)
				events.remove(event);
			else if (event.t <= Conductor.time - Conductor.offset)
			{
				var index:Int = events.indexOf(event);
				events.splice(index, 1);
				onEventTrigger(event);
			}
		}
		call('onUpdate', [elapsed]);
		super.update(elapsed);
		call('onUpdatePost', [elapsed]);

		if (inputSystem.ACCEPT)
		{
			pauseOrSmth();
		}
	}

	function pauseOrSmth()
	{
		var subState = new PauseSubState();
		subState.closeCallback = unPause;
		openSubState(subState);
		call('onPause');
		paused = true;

		inst.pause();
		for (shit in playerVocals.sounds.concat(enemyVocals.sounds))
			shit.pause();
	}

	public function unPause()
	{
		paused = false;
		inst.resume();
		for (shit in playerVocals.sounds.concat(enemyVocals.sounds))
			shit.resume();
	}

	public dynamic function onEndSong()
	{
		var val = call('onEndSong');
		if (val == 'stop')
			return;
		endSong();
	}

	public function endSong()
	{
		call('endSong');
		HighScore.postHighScore(currentScoreEntry.name, currentScoreEntry);
		FlxG.switchState(new states.menus.FreeplayState());
	}

	function set_invalidatedRun(value:Bool):Bool
	{
		if (playfield != null)
		{
			if (value)
				playfield.bot = value;
			playfield.bfStrumline.isBot = value;
		}

		return invalidatedRun = value;
	}
}
