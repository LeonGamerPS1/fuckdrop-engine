package shitengine.backend.graphics;

import modchart.backend.standalone.IAdapter;
import shitengine.objects.*;

class ModchartBackend implements IAdapter
{
	public function new() {}

	public static var instance:IModchartInstance;

	public function onModchartingInitialization():Void {}

	public function onModchartingDispose()
	{
		instance = null;
	}

	// Song-related stuff
	public function getSongPosition()
	{
		return Conductor.time + Conductor.offset;
	}

	// public function getCrochet():Float           // Current beat crochet
	public function getCurrentBeat():Float
	{
		return Conductor.curBeat;
	}

	public function getCurrentCrochet():Float
	{
		return Conductor.beatLength;
	}

	public function getCurrentScrollSpeed():Float
	{
		return instance.speed * .45;
	}

	public function getBeatFromStep(step:Float)
	{
		return step * .25;
	}

	// Arrow-related stuff
	public function getDefaultReceptorX(lane:Int, player:Int):Float // Get default strum x position
	{
		var strums = player == 0 ? instance.dadStrumline : instance.bfStrumline;
		return strums.strums.members[lane % strums.strums.length].x;
	}

	public function getDefaultReceptorY(lane:Int, player:Int)
	{
		var strums = player == 0 ? instance.dadStrumline : instance.bfStrumline;
		if (getDownscroll())
			return (strums.strums.members[lane % strums.strums.length].y * -1) + FlxG.height - strums.strums.members[lane % strums.strums.length].height;
		return strums.strums.members[lane % strums.strums.length].y;
	}

	public function getTimeFromArrow(arrow:FlxSprite)
	{
		if (arrow is Note)
		{
			var n:Note = cast arrow;
			return n.noteData.tms;
		}
		return 0;
	}

	public function isTapNote(sprite:FlxSprite)
	{
		return sprite is Note;
	}

	public function isHoldEnd(sprite:FlxSprite)
	{
		if (sprite is Note)
		{
			var n:Note = cast sprite;
			return n.isEndNote;
		}
		return false;
	}

	public function arrowHit(sprite:FlxSprite)
	{
		if (sprite is Note)
		{
			var n:Note = cast sprite;
			return n.hit;
		}
		return false;
	}

	public function getHoldParentTime(sprite:FlxSprite)
	{
		if (sprite is Note)
		{
			var n:Note = cast sprite;
			if (n.isSustainNote && n.parentNote != null)
				return n.parentNote.noteData.tms;
			return n.noteData.tms;
		}
		return 0;
	}

	/**
	 * Get the individual hold fragment length.
	 * 
	 * On most FNF engines, holds divided into fragments/tiles,
	 * each of them has a length of a step, so in this case, this
	 * function should return the length of a step.
	 * 
	 * Also on other FNF engines, the holds uses one single fragment
	 * (two actually, ond for the body and other for the end),
	 * so in that case, this should return the full hold length in ms.
	 * @param sprite : The hold arrow
	 * @return Float
	 */
	public function getHoldLength(sprite:FlxSprite)
	{
		return Conductor.stepLength;
	}

	public function getLaneFromArrow(sprite:FlxSprite)
	{
		if (sprite is Strum)
		{
			return cast(sprite, Strum).dir;
		}

		if (sprite is Note)
		{
			return cast(sprite, Note).lane;
		}

		if (sprite is NoteSplash)
		{
			return cast(sprite, NoteSplash).strum.dir;
		}
		return 0;
	}

	public function getPlayerFromArrow(sprite:FlxSprite)
	{
		if (sprite is Strum)
		{
			return cast(sprite, Strum).strumline == instance.dadStrumline ? 0 : 1;
		}

		if (sprite is Note)
		{
			return cast(sprite, Note).strumline == instance.dadStrumline ? 0 : 1;
		}

		if (sprite is NoteSplash)
		{
			return cast(sprite, NoteSplash).strum.strumline == instance.dadStrumline ? 0 : 1;
		}

		return 0;
	}

	public function getKeyCount(?player:Int)
	{
		return player == 0 ? instance.dadStrumline.strums.length : instance.bfStrumline.strums.length;
	}

	public function getPlayerCount():Int
	{
		return 2;
	}

	// Get cameras to render the arrows (camHUD for almost every engine)
	public function getArrowCamera()
	{
		return instance.modchartingCameras;
	}

	// Options section
	public function getHoldSubdivisions(item:FlxSprite)
	{
		return 1;
	}

	public function getDownscroll():Bool
	{
		return SaveData.currentSettings.downScroll;
	}

	/**
	 * Get the every arrow/lane indexed by player.
	 * Example:
	 * [
	 *      [ // Player 0
	 *          [strum1, strum2...],
	 *          [arrow1, arrow2...],
	 *          [hold1, hold2....],
	 * 			[splash1, splash2....]
	 *      ],
	 *      [ // Player 2
	 *          [strum1, strum2...],
	 *          [arrow1, arrow2...],
	 *          [hold1, hold2....],
	 * 			[splash1, splash2....]
	 *      ]
	 * ]
	 * @return Array<Array<Array<FlxSprite>>>
	 */
	static var emptyArray:Array<Array<Array<FlxSprite>>> = [];

	public var strumlines:Array<Array<Array<FlxSprite>>> = [[[], [], []], [[], [], []]];

	public function getArrowItems():Array<Array<Array<FlxSprite>>>
	{
		if (!instance.modchartEnabled)
			return emptyArray;
		var dadStrumline = instance.dadStrumline;
		var bfStrumline = instance.bfStrumline;
		var dadStrums:Array<Array<FlxSprite>> = cast [dadStrumline.strums.members, [], [], []];
		var bfStrums:Array<Array<FlxSprite>> = cast [bfStrumline.strums.members, [], [], []];
		for (note in dadStrumline.notes)
			dadStrums[isHoldNote(note) ? 2 : 1].push(note);

		for (note in bfStrumline.notes)
			bfStrums[isHoldNote(note) ? 2 : 1].push(note);

		for (splash in instance.noteSplashes)
		{
			var sl = getPlayerFromArrow(splash) == 0 ? dadStrums : bfStrums;
			sl[3].push(splash);
		}
		// clear the arrays to prevent duplicates

		return [dadStrums, bfStrums];
	}

	public function isHoldNote(n:Note)
	{
		return n.isSustainNote;
	}

	public function isNotHoldNote(n:Note)
	{
		return !isHoldNote(n);
	}
}

interface IModchartInstance
{
	var dadStrumline:Strumline;
	var bfStrumline:Strumline;
	var modchartingCameras:Array<FlxCamera>;
	var speed:Float;
	var noteSplashes:FlxTypedGroup<NoteSplash>;
	var modchartEnabled:Bool;
}
