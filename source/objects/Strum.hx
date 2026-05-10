package objects;

import backend.NoteSkin;
import shaders.RGBSwap;

class Strum extends FlxAnimate
{
	public var flipScroll = false;

	public static var RESET_TIME = 0.15;

	public var rT = .0;
	public var rgbswap:RGBSwap;
	public var strumline:Strumline;

	public function new(skin = "default", dir:Int = 0, k = 4)
	{
		super();
		this.dir = dir;
		// rgbswap = Note.getSwapShaderForLane(dir);
		// shader = rgbswap.shader;
		reload(skin, k);
	}

	public var lastSkin = "";
	public var tempskin:Sskindat;

	function reload(skin = "default", ?keys:Int = 4)
	{
		lastSkin = skin;
		tempskin = NoteSkin.getSkin(skin);
		applySkinRaw(tempskin, keys);
	}

	public function applySkinRaw(tempskin:Sskindat, keys:Int = 4)
	{
		frames = Paths.getSparrowAtlas('noteskins/${tempskin.name}/${tempskin.image}');
		var fps = tempskin.fps ?? 24;
		var direction:String = NoteSkin.strumDirections[keys - 1][dir];
		animation.addByPrefix("static", 'arrow${direction.toUpperCase()}', fps, true);

		animation.addByPrefix("confirm", direction + ' confirm', fps, false);
		animation.addByPrefix("press", direction + ' press', fps, false);
		scale.set(tempskin.scale, tempskin.scale);
		updateHitbox();

		antialiasing = tempskin.antialiasing;
		playAnim("static", false, true);
	}

	public var holding:Bool = false;

	override function update(d:Float)
	{
		super.update(d);

		if (rT != 0)
		{
			rT -= d;
			if (rT <= 0)
			{
				rT = 0;
				playAnim('static', true);
			}
		}
	}

	public var dir = 0;

	public function playAnim(s:String, force:Bool = false, rotate:Bool = false)
	{
		animation.play(s, force);
		centerOffsets();
		centerOrigin();
		if (rgbswap != null)
			shader = s != 'static' ? rgbswap.shader : null;
	}

	public var staticshader:FlxShader;

	override function destroy()
	{
		tempskin = null;
		shader = null;
		rgbswap = null;
		super.destroy();
	}
}
