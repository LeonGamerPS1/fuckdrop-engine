package backend.assets;

import animate.FlxAnimateFrames;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxMatrix;
import haxe.MainLoop;
import openfl.media.Sound;
import openfl.utils.AssetType;
import states.PlayState;

class Paths
{
	public static var cachedImages:haxe.ds.StringMap<FlxGraphic> = new haxe.ds.StringMap<FlxGraphic>();
	public static var cachedSounds:haxe.ds.StringMap<Sound> = new haxe.ds.StringMap<Sound>();
	public static var cachedAtlases:haxe.ds.StringMap<FlxFramesCollection> = new haxe.ds.StringMap<FlxFramesCollection>();

	public static function clearGraphics()
	{
		for (img in cachedImages)
		{
			if (img == null || img.destroyOnNoUse)
				continue;

			img.persist = false;
			@:bypassAccessor
			img.destroyOnNoUse = true;
			img.destroy();
			img = null;
		}
		cachedImages.clear();
		for (atlas in cachedAtlases)
			atlas.destroy();
		cachedAtlases.clear();

		FlxG.bitmap.clearCache();
	}

	public static inline function getPath(path:String)
		return 'assets/$path';

	static public var defaultMatrix:FlxMatrix = new FlxMatrix();

	public static function getGraphic(path:String):FlxGraphic
	{
		path = getPath('images/$path.png');
		if (cachedImages.exists(path))
			return cachedImages.get(path);

		if (!OpenFLAssets.exists(path))
		{
			trace('oh noes! image not here $path');
			return null;
		}

		var bitmap = OpenFLAssets.getBitmapData(path);

		bitmap.disposeImage();

		var graphic = FlxGraphic.fromBitmapData(bitmap, false, path, false);
		graphic.persist = true;
		cachedImages.set(path, graphic);
		return graphic;
	}

	public static function clear()
	{
		if (FlxG.state is PlayState)
			return;
		clearGraphics();
	}

	public static var defaultListExludes = ['assets/data/scripts/stages'];

	public static function listDirectory(startPath:String, type:AssetType = null, ?excludes:Array<String>):Array<String>
	{
		excludes ??= defaultListExludes;
		var dir = OpenFLAssets.list(type).filter((e) ->
		{
			return e.startsWith(startPath) && !excludes.contains(startPath);
		});

		return dir;
	}

	public static function getSound(path:String, stream:Bool = false, soundType:SoundExtension = #if flash MP3 #else OGG #end):Sound
	{
		path = getPath('$path.$soundType');
		#if !sys stream = false; #end
		if (cachedSounds.exists(path))
			return cachedSounds.get(path);

		if (!OpenFLAssets.exists(path, SOUND))
			return getSound('sounds/beep', stream, OGG);

		var sound:Sound = #if FLX_STREAM_SOUND stream ? FlxG.assets.streamSound(path) : #end
		FlxG.assets.getSound(path, false);
		cachedSounds.set(path, sound);
		return sound;
	}

	public static function exists(s:String, ?type:AssetType)
	{
		var path = getPath(s);
		return OpenFLAssets.exists(path, type);
	}

	public static function getFont(path:String, fontType:FontExtension = TTF):String
	{
		path = getPath('fonts/$path.$fontType');

		return path;
	}

	//* for example, notes/poo, xml and png get added on their own
	public static function getSparrowAtlas(path:String):FlxAtlasFrames
	{
		var pathXML = getPath('images/$path.xml');
		var pathPng = getPath('images/$path.png');

		if (cachedAtlases.exists(pathXML))
			return cast cachedAtlases.get(pathXML);
		else if (cachedAtlases.exists(pathPng))
			return cast cachedAtlases.get(pathXML);
		if (!OpenFLAssets.exists(pathPng) || !OpenFLAssets.exists(pathXML))
		{
			trace('oh noes!!! atlas not here!!! $pathPng | $pathXML');
			return null;
		}

		var atlas = FlxAtlasFrames.fromSparrow(getGraphic(path), pathXML);
		atlas.parent.persist = true;
		cachedAtlases.set(pathXML, atlas);
		cachedAtlases.set(pathPng, atlas);
		return atlas;
	}

	public static function getAnimateAtlas(path:String):FlxAnimateFrames
	{
		var path = getPath('images/$path');
		final animJSON = path + "/Animation.json";

		if (cachedAtlases.exists(animJSON))
			return cast cachedAtlases.get(animJSON);
		if (!OpenFLAssets.exists(animJSON))
		{
			trace('oh noes!!! atlas not here!!! $path');
			return null;
		}

		var atlas = FlxAnimateFrames.fromAnimate(path);
		atlas.parent?.bitmap.disposeImage();
		cachedAtlases.set(animJSON, atlas);
		atlas.parent.persist = true;
		return atlas;
	}

	/**
	 * @author TheRealJake12, slightly edited by LeonGamerPS1
	 * Wack Ass Attempt To Make An OpenFl Equivalent For `FileSystem.readDirectory`
	 * @param path Directory To Scan. Doesn't Need the `assets/` prefix.
	 * @param type Type Of Files To List. "" Gets All Files While "TEXT" Will Only Retrieve Text Files (duh)
	 * @param suffix The Suffix Of The Files To Find. .lua Would Only Return Lua Files.
	 * @param removePath To Keep The `assets/path` Prefix When Returned. If True, It'll Just Be The Name Of The File With The Extension.
	 * @return Array<String>
	 */
	public static function readAssetsDirectoryFromLibrary(path:String, ?type:String, ?suffix:String = "", ?removePath:Bool = false,
			?library:String = "default"):Array<String>
	{
		final lib = OpenFLAssets.getLibrary(library ?? 'default');
		final list:Array<String> = lib.list(type);
		path = 'assets/$path';
		var stringList:Array<String> = [];
		for (hmm in list)
		{
			if (!hmm.startsWith(path) || !hmm.endsWith(suffix))
				continue;
			var bruh:String = null;
			if (removePath)
				bruh = hmm.replace('$path/', '');
			else
				bruh = hmm;
			stringList.push(bruh);
		}
		stringList.sort(Reflect.compare);
		return stringList;
	}

	public static function fragShader(shaderName:String)
	{
		var path = getPath('shaders/$shaderName.frag');
		return path;
	}

	public static function vertShader(shaderName:String)
	{
		var path = getPath('shaders/$shaderName.vert');
		return path;
	}

	public static function GetVertShader(shaderName:String):String
	{
		if (!SaveData.currentSettings.enableShaders)
			return null;
		var path = vertShader(shaderName);
		return FlxG.assets.getText(path, false);
	}

	public static function GetFragShader(shaderName:String):String
	{
		if (!SaveData.currentSettings.enableShaders)
			return null;
		var path = fragShader(shaderName);
		return FlxG.assets.getText(path, false);
	}
}

enum abstract SoundExtension(String)
{
	var WAV = "wav";
	var OGG = "ogg";
	var MP3 = "mp3";
}

enum abstract FontExtension(String)
{
	var TTF = "ttf";
	var OTF = "otf";
	var WOFF = "woff";
	var WOFF2 = "woff2";
	var EOT = "eot";
	var SVG = "svg";
}
