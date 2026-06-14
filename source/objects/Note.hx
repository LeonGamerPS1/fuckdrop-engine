package objects;

import backend.NoteSkin;
import backend.data.SongChartData.SongNoteData;
import backend.scripting.NxScriptM;
import flixel.input.keyboard.FlxKey;
import shaders.RGBSwap;

@:structInit
class Quantization
{
	public var snap:Int;
	public var color:FlxColor;
}

class Note extends FlxSprite
{
	static var localQuantization:Array<Quantization> = [
		{snap: 4, color: 0xE51919},
		{snap: 8, color: 0x193BE5},
		{snap: 12, color: 0xA119E5},
		{snap: 16, color: 0x26D93E},
		{snap: 20, color: 0x0000B2},
		{snap: 24, color: 0xA119E5},
		{snap: 32, color: 0xE5C319},
		{snap: 48, color: 0xA119E5},
		{snap: 64, color: 0x13ECA4},
		{snap: 96, color: 0x3A3A6C},
		{snap: 192, color: 0x3A3A6C}
	];

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

	public var type:String = "unknown";
	public var rating:String;

	static var unknownNote:SongNoteData = {
		tms: 0,
		l: 0,
		lms: 0,
		t: "normal"
	};

	public function new(?dir:SongNoteData, ?strumline:Strumline, isSusNote:Bool = false, isEndNote:Bool = false)
	{
		super();
		this.strumline = strumline;
		this.noteData = dir ?? unknownNote;
		this.isEndNote = isEndNote;
		this.isSustainNote = isSusNote;

		reload(strumline != null ? strumline.skin : 'funkin');
		if (isSustainNote)
	
			earlyHitMult = 0;
		initscript(dir?.t ?? 'normal');
	}

	public static function getQuantForTime(t:Float):RGBSwap
	{
		var beat = Conductor.getBeat(t);

		// convert to 4-beat measure space
		var measurePos = beat % 4;

		var snaps = SaveData.currentSettings.quantRGB.length;

		var index = Std.int((measurePos * snaps) % snaps);

		var c = SaveData.currentSettings.quantRGB[index];

		return new RGBSwap(c[0], c[1], c[2]);
	}

	static var quants:Map<Int, RGBSwap> = [];

	public var stain:Stain;

	static function cacheQuant(quantized:Quantization)
	{
		if (quants.exists(quantized.snap))
			return quants.get(quantized.snap);
		var quant = new RGBSwap(quantized.color.red, quantized.color.green, quantized.color.blue);
		quants.set(quantized.snap, quant);
		return quant;
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

	function reload(skin = "funkin")
	{
		lastSkin = skin;
		tempskin = NoteSkin.getSkin(skin);
		applySkinRaw(tempskin);

		rgbswap = !SaveData.currentSettings.quants ? getSwapShaderForLane(lane) : getQuantForTime(noteData.tms);
		if (!tempskin.disableRGB)
			shader = rgbswap.shader;
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
			scale.y = ((Conductor.stepLength * Constants.PIXEL_PER_MS * (strumline?.speed ?? 1) + (tempskin.susScale ?? 0)) / frameHeight);
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

	public function playAnim(animName:String, force = false, reversed = false, frame = 0)
	{
		animation.play(animName, force, reversed, frame);
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

	public static var defaultLanes:Array<RGBSwap> = [];

	public static function getSwapShaderForLane(lane:Int):RGBSwap
	{
		if (defaultLanes[lane] == null)
		{
			trace('e');
			var swap:RGBSwap = new RGBSwap(SaveData.currentSettings.arrowRGB[lane][0], SaveData.currentSettings.arrowRGB[lane][1],
				SaveData.currentSettings.arrowRGB[lane][2]);
			defaultLanes[lane] = swap;
			return swap;
		}
		return defaultLanes[lane];
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
