package states.gameplay;

import backend.data.SongChartData;
import backend.gameplay.SongLoader;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxSlider;
import flixel.group.FlxSpriteContainer;
import objects.Note;
import objects.Strum;
import objects.Strumline;
import objects.gameplay.Character;
import objects.ui.HealthIcon;

typedef ChartSection =
{
	var notes:Array<SongNoteData>;
	var events:Array<SongEventData>;
	var startTime:Float;
	var endTime:Float;
}

class Charter extends FlxTransitionableState
{
	static var song:SongChartData;

	var charterCam:FlxCamera;

	var box:FunkinSprite;

	public function new(?song:SongChartData)
	{
		super();
		if (song != null)
			Charter.song = song;
		Charter.song ??= SongLoader.loadSong('bopeebo', 'easy');
	}

	var inst:FlxSound;
	var sections:Array<ChartSection> = [];

	var strumline:FlxSprite;
	var baseIconScale = 1.;
	var ui:FlxGroup;

	override function create()
	{
		super.create();
		charterCam = new FlxCamera();
		charterCam.bgColor = 0x0;
		FlxG.cameras.add(charterCam, false);

		ui = new FlxGroup();
		ui.cameras = [charterCam];
		add(ui);

		box = new FunkinSprite().solidColor(size - 1, size - 1);
		add(box);

		Conductor.bpm = song.data.bpm;
		Conductor.time = 0;

		inst = new FlxSound().load(Paths.getSound(song.songFolder + '/audio/' + song.data.characters.instPath, true));
		FlxG.sound.list.add(inst);
		inst.play();
		inst.pause();
		var firstNoteLol:Int = 0;
		var lastNoteIndex:Int = 0;

		final suspectedSections:Int = Math.floor(inst.length / (Conductor.stepLength * 16));

		for (section in 0...suspectedSections)
		{
			var region = {
				start: Conductor.stepLength * section * 16,
				end: Conductor.stepLength * (section + 1) * 16
			};

			// Find first note in region
			while (firstNoteLol < song.data.notes.length && song.data.notes[firstNoteLol].tms < region.start)
			{
				firstNoteLol++;
			}

			// Find first note after region
			lastNoteIndex = firstNoteLol;

			while (lastNoteIndex < song.data.notes.length && song.data.notes[lastNoteIndex].tms < region.end)
			{
				lastNoteIndex++;
			}

			var _section:ChartSection = {
				notes: [],
				startTime: region.start,
				endTime: region.end,
				events: []
			};
			// Process notes in this region
			for (noteIndex in firstNoteLol...lastNoteIndex)
			{
				var note = song.data.notes[noteIndex];
				_section.notes.push(note);
				// Do something with note
			}
			sections.push(_section);
			region = null;
		}

		for (i in 0...3)
		{
			var grid:FlxSprite = FlxGridOverlay.create(size, size, size * 8, size * 16);
			chartGrids.push(grid);
			grid.color = i == 1 ? FlxColor.WHITE : FlxColor.GRAY;
			grid.y = grid.height * i;
			add(grid);
		}
		mainGrid = chartGrids[1];

		strumline = new FlxSprite(0, 0);
		strumline.makeGraphic(Math.floor(size * 8), 4);
		strumline.color = 0xB9B9B9;
		add(strumline);

		curSustains = new FlxTypedGroup<Note>();
		add(curSustains);

		curNotes = new FlxTypedGroup<Note>();
		add(curNotes);

		for (i in 0...8)
		{
			var strum = new Strum('funkin', i % 4);
			strums.push(strum);
			strum.setGraphicSize(size, size);
			strum.updateHitbox();
			strum.x = size * i;
			add(strum);
		}

		FlxG.camera.follow(strumline);

		currentSection = sections[0];
		Conductor.onMeasure.add(onSectionChange);
		Conductor.onBeat.add(beatHit);
		onSectionChange();

		final jsons = [
			Character.getJson(song.data.characters.dad),
			Character.getJson(song.data.characters.boyfriend)
		];

		for (i in 0...jsons.length)
		{
			var json = jsons[i];

			var icon:HealthIcon = new HealthIcon(json.icon, i > 0);
			icon.setGraphicSize(size * 2);
			icon.updateHitbox();
			icon.scrollFactor.set(1, 0);
			baseIconScale = icon.scale.x;
			add(icon);

			var iconSize = icon.width;

			if (i == 0)
			{
				// LEFT side of grid
				icon.x = mainGrid.x - iconSize - 8;
			}
			else if (i == 1)
			{
				// RIGHT side of grid
				icon.x = mainGrid.x + mainGrid.width + 8;
			}

			icon.y = (mainGrid.height * 0.5) - (icon.height * 0.5);

			icons.push(icon);
		}
	}

	final size = Constants.GRID_SIZE;
	var sectionDirty = false;
	var currentSectionIndex = -1;
	var sectionAddons:Array<FlxObject> = [];

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, mainGrid.y, mainGrid.y + mainGrid.height, 0, 16 * Conductor.stepLength);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepLength, mainGrid.y, mainGrid.y + mainGrid.height);
	}

	public function onSectionChange(sec:Float = 0)
	{
		currentSectionIndex = Std.int(sec);
		sectionDirty = true;
		camera.zoom += 1 / 12;
		applySection(currentSectionIndex);
	}

	public function beatHit(beat:Float = 0)
	{
		for (icon in icons)
		{
			icon.scale.set(baseIconScale * 1.2, baseIconScale * 1.2);
			icon.updateHitbox();
		}
	}

	var curNotes:FlxTypedGroup<Note>;
	var curSustains:FlxTypedGroup<Note>;
	var mainGrid:FlxSprite;
	var chartGrids:Array<FlxSprite> = [];
	var currentSection:ChartSection;

	var strums:Array<Strum> = [];

	var icons:Array<HealthIcon> = [];

	var _pendingRemake = false;

	override function update(elapsed:Float)
	{
		#if FLX_MOUSE box.setPosition(Math.floor(FlxG.mouse.x / size) * size, Math.floor(FlxG.mouse.y / size) * size); #end
		if (inputSystem.BACK)
			FlxG.switchState(() -> new PlayState());

		if (inputSystem.ACCEPT)
			togglePause();
		if (inst.playing)
			Conductor.time = inst.time;

		var localTime = Conductor.time - currentSection.startTime;
		localTime = Math.max(0, localTime);
		localTime = Math.min(localTime, currentSection.endTime - currentSection.startTime);

		strumline.y = getYfromStrum(localTime);
		for (strum in strums)
			strum.y = strumline.y;

		for (icon in icons)
		{
			icon.scale.set(FlxMath.lerp(baseIconScale, icon.scale.x, Math.exp(-elapsed * 8)),
				FlxMath.lerp(baseIconScale, icon.scale.y, Math.exp(-elapsed * 8)));
		}

		curNotes.forEachAlive((note:Note) ->
		{
			if (note.noteData.tms <= Conductor.time && !note.hit)
			{
				note.hit = true;
				var strum = strums[note.noteData.l];
				strum.playAnim('confirm', true);
				strum.rT = 0.15;
				if (note.noteData.lms > 0)
					strum.rT = note.noteData.lms / 1000;
			}
			if (note.noteData.tms >= Conductor.time)
				note.hit = false;
			note.alpha = note.hit ? 0.5 : 1;
			#if FLX_MOUSE
			if (box.overlaps(note))
			{
				if (FlxG.mouse.justPressed)
				{
					if (FlxG.keys.justPressed.CONTROL || FlxG.mouse.pressedRight)
					{
						// select note
						curSelectedNote = note.noteData;
					}
					else
					{
						// delete note
						if (curSelectedNote == note.noteData)
							curSelectedNote = null;
						currentSection.notes.remove(note.noteData);
						trace('deleting silly note ${note.noteData}');
						_pendingRemake = true;
					}
				}
			}
			#end
		});

		if (box.overlaps(mainGrid) && !box.overlaps(curNotes))
		{
			#if FLX_MOUSE
			if (FlxG.mouse.justPressed)
			{
				var noteData:SongNoteData = {
					t: 'normal',
					l: Math.floor(box.x / size),
					tms: getStrumTime(box.y) + currentSection.startTime,
					lms: 0
				};
				curSelectedNote = noteData;
				currentSection.notes.push(noteData);
				_pendingRemake = true;
			}
			#end
		}

		if (_pendingRemake)
		{
			_pendingRemake = false;
			regenNotes();
		}
		camera.zoom = FlxMath.lerp(1, camera.zoom, Math.exp(-elapsed * 8));
		super.update(elapsed);
	}

	var curSelectedNote:SongNoteData;
	var cSec = 0;

	function applySection(section:Int)
	{
		if (sections[section] == null)
			return;
		currentSection = sections[section];
		cSec = section;

		curNotes.killMembers();
		curSustains.killMembers();

		if (sections[section - 1] != null)
			spawnNotes(0, sections[section - 1]);

		regenNotes();
	}

	function regenNotes()
	{
		curNotes.killMembers();
		curSustains.killMembers();

		if (sections[cSec - 1] != null)
			spawnNotes(0, sections[cSec - 1]);

		spawnNotes(1, currentSection);
		if (sections[cSec + 1] != null)
			spawnNotes(2, sections[cSec + 1]);
	}

	function spawnNotes(id:Int = 0, sec:ChartSection)
	{
		if (sec == null)
			return;
		var currentGrid = chartGrids[id];

		@:privateAccess
		for (noteData in sec.notes)
		{
			var newNote = curNotes.recycle(Note);
			newNote.noteData = noteData;
			newNote.reload('funkin');
			newNote.setGraphicSize(size, size);
			newNote.x = size * noteData.l;
			newNote.updateHitbox();
			newNote.color = currentGrid.color;
			newNote.y = currentGrid.y + msToY(noteData.tms - sec.startTime - 1, Conductor.bpm);

			if (noteData.lms > 0)
			{
				var curSustain1 = curSustains.recycle(Note);
				curSustain1.noteData = noteData;
				curSustain1.isSustainNote = true;
				curSustain1.reload('funkin');
				curSustain1.setGraphicSize(size / 4, msToY(noteData.lms, Conductor.bpm) - size / 2);
				curSustain1.x = newNote.x + newNote.width * .5 - size / 8;
				curSustain1.updateHitbox();
				curSustain1.color = currentGrid.color;
				curSustain1.y = newNote.y + newNote.height / 2;

				var curSustain = curSustains.recycle(Note);
				curSustain.noteData = noteData;
				curSustain.isSustainNote = true;
				curSustain.isEndNote = true;
				curSustain.reload('funkin');
				// curSustain.playAnim('end');
				curSustain.setGraphicSize(size / 4, size / 3);
				curSustain.x = newNote.x + newNote.width * .5 - size / 8;
				curSustain.updateHitbox();
				curSustain.color = currentGrid.color;
				curSustain.y = curSustain1.height + curSustain1.y;
			}
		}
	}

	var some = .0;

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

	override function destroy()
	{
		song.data.notes.resize(0);

		for (section in sections)
		{
			for (note in section.notes)
			{
				song.data.notes.push(note);
			}
		}
		super.destroy();
	}
}
