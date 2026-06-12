package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import haxe.io.Path;

class NoteSplash extends FlxSprite
{
	public function new(x:Float, y:Float, noteData:Int = 0):Void
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('noteskins/funkin/noteSplashes');

		alpha = 0.75;
	}

	public var strum:Strum = null;
	public function setupNoteSplash(strumNote:Strum)
	{
		strum = strumNote;
		shader = strumNote.shader;
		setPosition(strumNote.x, strumNote.y);
		frames = Paths.getSparrowAtlas('noteskins/${strumNote.lastSkin}/${strumNote.tempskin.splashImage}');
		if (frames == null)
			frames = Paths.getSparrowAtlas('noteskins/funkin/noteSplashes');

		animation.addByPrefix('note1-0', 'note impact 1 blue', 24, false);
		animation.addByPrefix('note2-0', 'note impact 1 green', 24, false);
		animation.addByPrefix('note0-0', 'note impact 1 purple', 24, false);
		animation.addByPrefix('note3-0', 'note impact 1 red', 24, false);
		animation.addByPrefix('note1-1', 'note impact 2 blue', 24, false);
		animation.addByPrefix('note2-1', 'note impact 2 green', 24, false);
		animation.addByPrefix('note0-1', 'note impact 2 purple', 24, false);
		animation.addByPrefix('note3-1', 'note impact 2 red', 24, false);

		animation.play('note' + (strumNote.dir) % 4 + '-' + FlxG.random.int(0, 1), true);
		animation.curAnim.frameRate = 24 + FlxG.random.int(-5, 5);
		scale.set(2, 2);
		if(strumNote.tempskin.splashScale != null)
			scale.set(strumNote.tempskin.splashScale,strumNote.tempskin.splashScale);
		updateHitbox();
		centerOffsets();
		centerOrigin();
		setPosition(strumNote.x + (strumNote.width * 0.5 - width * 0.5), strumNote.y + (strumNote.height * 0.5 - height * 0.5));
		alpha = 1;
	}

	override function kill() {
		alpha = 0;
		super.kill();
	}
	override function update(elapsed:Float)
	{
		if (animation.curAnim.finished)
		{
			alpha = 0;
		}

		super.update(elapsed);
	}
}
