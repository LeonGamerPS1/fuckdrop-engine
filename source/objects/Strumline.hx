package objects;

import backend.NoteSkin;
import backend.data.SongChartData.SongNoteData;
import flixel.math.FlxRect;
import flixel.util.FlxSignal.FlxTypedSignal;
import objects.gameplay.Character;

class Strumline extends FlxGroup
{
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
			var hmm = note.noteData.lms;

			if (hmm > 0)
			{
				var cock = hmm / Conductor.stepLength;

				for (segmentID in 0...Math.floor(cock))
				{
					var sData = Reflect.copy(noteData);

					var isEnd = (segmentID) == Math.floor(cock) - 1;
					var noteHold:Note = new Note(sData, this, true, isEnd);
					sData.tms = noteData.tms + 2 + (Conductor.stepLength * segmentID);
					noteHold.offsetY = note.height / 2;
					note.children.push(noteHold);
					unspawnedNotes.push(noteHold);
					noteHold.setPosition(-5000, -5000);
					noteHold.parentNote = note;
					noteHold.prevNote = unspawnedNotes[unspawnedNotes.length - 1];
				}
			}
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

	public function inputSystemStuff()
	{
		pressedShit.resize(0);
		hitNotes.resize(0);
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
			notes.forEachAlive((n:Note) ->
			{
				if (n.canBeHit && !isBot && !n.hit)
				{
					hitNotes.push(n);
					pressedShit.push(n.noteData.l % strums.length);
				}
			});

			if (hitNotes.length > 0)
			{
				for (note in hitNotes)
				{
					var i = note.noteData.l % strums.length;
					var pressed = pressed[i];
					var holding = holding[i];

					if (!note.isSustainNote && pressed)
						hitNote(note);
					if (note.isSustainNote && (note.parentNote.hit || note.prevNote.hit) && holding)
						hitNote(note);
				}
			}
		}
		for (i in 0...pressed.length)
		{
			var strum = strums.members[i % strums.length];
			var pressed = pressed[i];
			var holding = holding[i];
			strum.holding = holding;
			if (pressed && strum.animation.name != 'confirm')
				strum.playAnim('press', true);
			else if (!holding)
				strum.playAnim('static', false, true);

			if (hitNotes.length > 0 && !pressedShit.contains(strum.dir) && pressed)
				onMissNote.dispatch(null, strum.dir, this);
		}
	}

	public function hitNote(note:Note)
	{
		var strum = strums.members[note.noteData.l % strums.length];
		strum.rgbswap = note.rgbswap;

		strum.playAnim("confirm", true);
		note.hit = true;
		onHitNote.dispatch(note);
		char?.hitNote(note);

		if (isBot)
			strum.rT = strum.animation.curAnim.numFrames / strum.animation.curAnim.frameRate;

		if (!note.isSustainNote)
			killNote(note);
	}

	public dynamic function updateNote(note:Note)
	{
		note.update(FlxG.elapsed);
		var strum = strums.members[note.noteData.l % strums.length];
		note.x = strum.x + (strum.width * 0.5 - note.width * 0.5);
		final distance = (note.noteData.tms - Conductor.time) * (Constants.PIXEL_PER_MS * speed * note.multSpeed) * (strum.flipScroll ? -1 : 1);
		note.y = strum.y + distance + note.offsetY;
		if (strum.flipScroll && note.isSustainNote)
		{
			note.y -= note.height;
			note.y += Note.swag - 10;
		}

		if (!note.hit && isBot && note.noteData.tms <= Conductor.time)
			hitNote(note);

		var center = strum.y + Note.swag * 0.5;
		note.flipY = note.isSustainNote && strum.flipScroll;
		note.strumline = this;
		if (strum.flipScroll)
		{
			if ((note.parentNote != null && note.parentNote.hit)
				&& note.y + note.height >= center
				&& (isBot || (note.hit || (note.prevNote.hit && !note.canBeHit)))
				|| ((strum.holding || isBot) && note.overlaps(strum) && note.isSustainNote))
			{
				var swagRect = recycleClipRect(note, 0, 0, note.frameWidth, note.frameHeight);
				swagRect.height = (center - note.y) / note.scale.y;
				swagRect.y = note.frameHeight - swagRect.height;
				note.clipRect = swagRect;
			}
		}
		else
		{
			if ((note.parentNote != null && note.parentNote.hit)
				&& note.y <= center
				&& (isBot || (note.hit || (note.prevNote.hit && !note.canBeHit)))
				|| ((strum.holding || isBot) && note.overlaps(strum) && note.isSustainNote))
			{
				var swagRect:FlxRect = recycleClipRect(note, 0, 0, note.width / note.scale.x, note.height / note.scale.y);
				swagRect.y = (center - note.y) / note.scale.y;
				swagRect.height -= swagRect.y;
				note.clipRect = swagRect;
			}
		}

		if (note.noteData.tms <= Conductor.time - (350 / note.multSpeed / speed))
		{
			if (!isBot && !note.hit)
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
