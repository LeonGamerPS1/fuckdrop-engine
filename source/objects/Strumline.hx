package objects;

import backend.NoteSkin;
import backend.data.SongChartData.SongNoteData;
import flixel.math.FlxRect;
import flixel.util.FlxSignal.FlxTypedSignal;
import objects.gameplay.Character;

using util.ArrayUtil;

class Strumline extends FlxGroup
{
	public var stains:FlxTypedGroup<Stain>;
	public var strums:FlxTypedSpriteGroup<Strum>;
	public var playfield:Playfield;
	public var isBot:Bool = false;

	public var unspawnedNotes:Array<Note> = [];
	public var skin:String = "default";
	public var zone:Float = 1500;
	public var speed:Float;
	public var char:Character;

	public var onHitNote:FlxTypedSignal<Note->Void> = new FlxTypedSignal<Note->Void>();
	public var onMissNote:FlxTypedSignal<Note->Null<Int>->Strumline->Void> = new FlxTypedSignal<Note->Null<Int>->Strumline->Void>();

	public function new(pf:Playfield, skin:String = "funkin", keys:Int = 4)
	{
		super();
		this.playfield = pf;

		strums = new FlxTypedSpriteGroup();
		add(strums);

		stains = new FlxTypedGroup<Stain>();
		add(stains);

		notes = new FlxTypedGroup<Note>();
		notes.active = false;
		add(notes);

		genstrums(keys, skin);
	}

	function genstrums(keys:Int = 4, skin:String = "funkin")
	{
		this.skin = skin;
		for (i in 0...keys)
		{
			var strum:Strum = new Strum(skin, i, keys);
			strum.strumline = this;
			strum.flipScroll = SaveData.currentSettings.downScroll;
			strum.x = strum.width * i;
			strums.add(strum);
		}
	}

	public function generateNotes(noteSet:Array<SongNoteData>)
	{
		if (noteSet == null || noteSet.length < 1)
			return;
		for (shit in unspawnedNotes)
			killNote(shit);

		var oldbpm = Conductor.bpm;
		for (i in 0...noteSet.length)
		{
			var noteData = noteSet[i];
			var note:Note = new Note(noteData, this);
			note.setPosition(-5000, -5000);
			unspawnedNotes.push(note);
			note.prevNote = unspawnedNotes[unspawnedNotes.length - 1] ?? note;
		}
		unspawnedNotes.sort((n1, n2) ->
		{
			return Math.floor(n1.noteData.tms - n2.noteData.tms);
		});
		Conductor.bpm = oldbpm;
	}

	public function killNote(note:Note)
	{
		notes.remove(note, true);
		note?.destroy();
		stains.remove(note.stain, true);
		note.stain?.destroy();
		note.stain = null;
		unspawnedNotes.remove(note);
	}

	public var notes:FlxTypedGroup<Note>;

	public override function update(elapsed:Float)
	{
		if (unspawnedNotes.length > 0)
		{
			final note = unspawnedNotes[0];
			final realZone = zone / speed / note.multSpeed;
			if (note.noteData.tms <= (Conductor.time - Conductor.offset) + realZone)
			{
				var note:Note = unspawnedNotes[0];
				notes.insert(1, note);
				notes.sort(sortNotesByTimeHelper, FlxSort.DESCENDING);

				var index:Int = unspawnedNotes.indexOf(note);
				unspawnedNotes.splice(index, 1);

				if (note.noteData.lms > 0)
				{
					var sus:Stain = new Stain(note);
					note.stain = sus;
					sus.setPosition(-1000, -1000);
					stains.add(sus);
				}
			}
		}
		notes.sort(sortNotesByTimeHelper, FlxSort.DESCENDING);
		if (!isBot)
			inputSystemStuff();
		notes.forEachAlive(updateNote);

		super.update(elapsed);
	}

	public var pressedShit = [-1];
	public var hitNotes:Array<Note> = [];

	public var hitNotesInt:Array<Int> = [];

	public function inputSystemStuff()
	{
		pressedShit.resize(0);
		hitNotes.resize(0);
		hitNotesInt.resize(0);

		final holding = [
			inputSystem.pressed('note_left'),
			inputSystem.pressed('note_down'),
			inputSystem.pressed('note_up'),
			inputSystem.pressed('note_right')
		];

		final released = [
			inputSystem.justReleased('note_left'),
			inputSystem.justReleased('note_down'),
			inputSystem.justReleased('note_up'),
			inputSystem.justReleased('note_right')
		];

		final pressed = [
			inputSystem.justPressed('note_left'),
			inputSystem.justPressed('note_down'),
			inputSystem.justPressed('note_up'),
			inputSystem.justPressed('note_right')
		];

		if (holding.contains(true))
		{
			var laneNotes:Array<Note> = [null, null, null, null];

			notes.forEachAlive((n:Note) ->
			{
				if (n.canBeHit && !isBot && !n.hit)
				{
					var lane = n.lane;

					if (laneNotes[lane] == null)
					{
						laneNotes[lane] = n;
					}
					else if (n.noteData.tms < laneNotes[lane].noteData.tms)
					{
						laneNotes[lane] = n;
					}
				}
			});

			for (note in laneNotes)
			{
				if (note == null)
					continue;

				hitNotes.push(note);
				pressedShit[note.lane] = note.lane;
			}

			if (hitNotes.length > 0)
			{
				for (note in hitNotes)
				{
					var lane = note.lane;
					var lanePressed = pressed[lane];
					var laneHolding = holding[lane];

					if (!note.isSustainNote && lanePressed)
					{
						hitNote(note);
					}
					else if (note.isSustainNote && laneHolding)
					{
						hitNote(note);
					}
				}
			}
		}

		for (i in 0...pressed.length)
		{
			var strum = strums.members[i % strums.length];
			var lanePressed = pressed[i];
			var laneHolding = holding[i];

			strum.holding = laneHolding;

			if (lanePressed && strum.animation.name != 'confirm')
				strum.playAnim('press', true);
			else if (!laneHolding)
				strum.playAnim('static', false, true);

			if (hitNotes.length > 0 && !pressedShit.contains(strum.dir) && lanePressed)
				onMissNote.dispatch(null, strum.dir, this);
		}
	}

	public function hitNote(note:Note)
	{
		var strum = strums.members[note.noteData.l % strums.length];
		strum.rgbswap = note.rgbswap;

		strum.playAnim("confirm", true);
		note._fmVisible = false;
		note.visible = false;
		char?.hitNote(note);

		if (isBot)
			strum.rT = Conductor.stepLength * 1.5 / 1000;
		onHitNote.dispatch(note);

		note.hit = true;
	}

	public function updateNote(note:Note)
	{
		note.update(FlxG.elapsed);
		var strum = strums.members[note.noteData.l % strums.length];
		final TX = strum.x + (strum.width * 0.5 - note.width * 0.5);
		if (note.x != TX)
			note.x = TX;
		final distance = (note.noteData.tms - Conductor.time) * (Constants.PIXEL_PER_MS * speed * note.multSpeed) * (strum.flipScroll ? -1 : 1);
		note.y = strum.y + distance + note.offsetY;

		var _maxTime:Float = note.noteData.tms + note.noteData.lms + Conductor.stepLength;
		var _inHoldRange:Bool = note.noteData.lms > 0 && Conductor.time < _maxTime - Conductor.stepLength * 2;
		if (isBot && note.noteData.tms <= Conductor.time && note.noteData.lms < 1 || note.noteData.lms > 0 && _inHoldRange && isBot
			&& note.noteData.tms <= Conductor.time)
			hitNote(note);
		if (strum.holding && !isBot && note.hit && note.noteData.lms > 0 && _inHoldRange)
			hitNote(note);
		note.stain?.updateVisuals();

		if (note.hit && note.noteData.tms + note.noteData.lms <= Conductor.time)
		{
			killNote(note);
		}

		if (_inHoldRange && !strum.holding && !isBot && note.hit)
		{
			onMissNote.dispatch(note, note.lane, this);
			killNote(note);
		}

		if (note.noteData.tms <= Conductor.time - (350 / note.multSpeed / speed) && !note.hit)
		{
			if (!isBot)
				onMissNote.dispatch(note, note.lane, this);

			for (child in note.children)
			{
				if (!guitarHeroSustains && !isBot)
					onMissNote.dispatch(child, child.lane, this);
				killNote(child);
			}
			killNote(note);
		}
	}

	static function recycleClipRect(sprite:FlxSprite, i:Int = 0, i2:Int = 0, f:Float = 0, f2:Float = 0)
	{
		var rect = sprite.clipRect ?? new FlxRect(i, i2, f, f2);
		rect.set(i, i2, f, f2);
		rect.round();
		return rect;
	}

	public static var guitarHeroSustains:Bool = true;

	inline public static function sortNotesByTimeHelper(Order:Int, Obj1:Note, Obj2:Note)
		return FlxSort.byValues(Order, Obj1.noteData.tms, Obj2.noteData.tms);

	public function beatHit() {}

	public function stepHit() {}
}
