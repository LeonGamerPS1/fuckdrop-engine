package objects;

import backend.NoteSkin;
import backend.data.SongChartData.SongNoteData;
import backend.scripting.NxScriptM;
import flixel.input.keyboard.FlxKey;
import shaders.RGBSwap;

class Note extends FunkinSprite
{
	public var strumline:Strumline;
	public var noteScript:NxScriptM;

	public var rgbswap:RGBSwap;
	public var noteData:SongNoteData;
	public var multSpeed:Float = 1;
	public var hit(default, set):Bool = false;
	public var isSustainNote:Bool = false;
	public var isEndNote:Bool = false;
	public var parentNote:Note;
	public var prevNote:Note;

	public var canBeHit(get, null):Bool;
	public var earlyHitMult:Float = 1;
	public var lateHitMult:Float = 1;

	public var children:Array<Note> = [];
	public var lane(get, null):Int;
	public var offsetY:Float = 0;

	public static var swag:Float = (160 * 0.7);

	public static var noteShaders = [for (i in 0...4) new RGBSwap()];

	public var type:String = "unknown";
	public var rating:String;

	public function new(dir:SongNoteData, strumline:Strumline, isSusNote:Bool = false, isEndNote:Bool = false)
	{
		super();
		this.strumline = strumline;
		this.noteData = dir;
		this.isEndNote = isEndNote;
		this.isSustainNote = isSusNote;
		rgbswap = getSwapShaderForLane(lane);
		shader = rgbswap.shader;

		reload(strumline != null ? strumline.skin : 'funkin');
		if (!isSustainNote)
			earlyHitMult *= 0.5;
		else
			earlyHitMult = 0;
		initscript(dir.t ?? 'normal');
	}

	public function initscript(type:String = 'normal')
	{
		if (!OpenFLAssets.exists(Paths.getPath('data/noteTypes/$type.nx'), TEXT))
			return;
		noteScript = new NxScriptM(type, Paths.getPath('data/noteTypes/$type.nx'));
		noteScript.setFunction('close', () ->
		{
			noteScript.call('destroy');
			trace('ended notetype script for type ${noteScript.name} at strumtime ${noteData.tms}');
			noteScript = null;
		});
	}

	public var lastSkin = "";
	public var tempskin:Sskindat;

	function reload(skin = "default")
	{
		lastSkin = skin;
		tempskin = NoteSkin.getSkin(skin);
		applySkinRaw(tempskin);
	}

	public function applySkinRaw(tempskin:Sskindat)
	{
		var color:String = NoteSkin.noteColors[noteData.l % 4];
		frames = Paths.getSparrowAtlas('noteskins/${tempskin.name}/${tempskin.image}');
		animation.addByPrefix("arrow", '${color}0', 24, true);
		animation.addByPrefix("hold", '${color} hold piece0', 24, true);
		animation.addByPrefix("end", '${color} hold end0', 24, true);
		scale.set(tempskin.scale, tempskin.scale);

		antialiasing = tempskin.antialiasing;
		playAnim("arrow", false);
		if (isSustainNote)
			playAnim(!isEndNote ? 'hold' : 'end');

		updateHitbox();
		alpha = isSustainNote && !SaveData.currentSettings.opaqueSustains ? 0.6 : 1;
		if (isSustainNote && !isEndNote)
		{
			scale.y = (63 / frameHeight) * 0.7;
			scale.y = ((Conductor.stepLength * 0.45 * (strumline?.speed ?? 1)) / frameHeight);
			updateHitbox();
			earlyHitMult = 0;
		}
	}

	var hue:Float = 0;

	override function update(d:Float)
	{
		noteScript?.call('onUpdate', [d]);
		super.update(d);
		noteScript?.call('onUpdatePost', [d]);
	}

	public var dir:SongNoteData;

	public override function playAnim(animName:String, force = false, reversed = false, frame = 0)
	{
		animController.play(animName, force, reversed, frame);
		centerOffsets();
		centerOrigin();
	}

	public var staticshader:FlxShader;

	override function destroy()
	{
		noteScript?.call('close');
		tempskin = null;
		shader = null;
		rgbswap = null;
		super.destroy();
	}

	function get_canBeHit():Bool
	{
		return ((noteData.tms > Conductor.time - Conductor.offset - (Conductor.sfz * lateHitMult)
			&& noteData.tms < Conductor.time - Conductor.offset + (Conductor.sfz * earlyHitMult)))
			&& !strumline.isBot;
	}

	function get_lane():Int
	{
		return noteData?.l % 4 ?? 0;
	}

	public static var defaultLanes = [new RGBSwap(), new RGBSwap(), new RGBSwap(), new RGBSwap()];
	public static function getSwapShaderForLane(lane:Int):RGBSwap
	{
		return defaultLanes[lane % defaultLanes.length].copy();
	}

	function set_hit(value:Bool):Bool
	{
		if (hit == value)
			return hit;
		hit = value;
		if (value)
			noteScript?.call('onNoteHit', [this]);
		return hit;
	}
}
