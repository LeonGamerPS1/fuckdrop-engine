package shitengine.objects;

import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;

enum abstract AtlasType(String) from String to String
{
	var SPARROW = 'sparrow';
	var ANIMATE = 'animate';
}

class FunkinSprite extends OffsetSprite
{
	public function new(x:Float = 0, y:Float = 0, ?graphic:FlxGraphicAsset)
	{
		super(x, y, graphic);
		// useRenderTexture = true; // glup glup glup
	}

	public function addAnimPrefix(name:String, prefix:String, ?frameRate = 24, ?looped = false, ?flipX = false, ?flipY = false)
	{
		if (!isAnimate)
			animation.addByPrefix(name, prefix, frameRate, looped, flipX, flipY);
		else
			anim.addBySymbol(name, prefix, frameRate, looped, flipX, flipY);
		return this;
	}

	public function addAnimIndices(Name:String, Prefix:String, Indices:Array<Int>, ?Postfix:String, ?FrameRate:Float = 24, ?Looped:Bool = false,
			?FlipX:Bool = false, ?FlipY:Bool = false)
	{
		if (!isAnimate)
			animation.addByIndices(Name, Prefix, Indices, Postfix, FrameRate, Looped, flipX, flipY);
		else
			anim.addBySymbolIndices(Name, Prefix, Indices, FrameRate, Looped, flipX, flipY);
		return this;
	}

	public function loadAtlas(atlasName:String, type:AtlasType)
	{
		if (type == ANIMATE)
			frames = Paths.getAnimateAtlas(atlasName);
		else
			frames = Paths.getSparrowAtlas(atlasName);
		return this;
	}

	override function set_clipRect(r:FlxRect)
	{
		clipRect = r;

		if (frames != null)
			frame = frames.frames[animation.frameIndex];
		return r;
	}

	public function loadImage(key:String)
	{
		loadGraphic(Paths.getGraphic(key));
		return this;
	}

	public function solidColor(i:Int, i2:Float, i3:FlxColor = 0xFFFFFFFF)
	{
		trace(i3);
		makeGraphic(1, 1, i3);
		setGraphicSize(i, i2);
		updateHitbox();
		return this;
	}
}
