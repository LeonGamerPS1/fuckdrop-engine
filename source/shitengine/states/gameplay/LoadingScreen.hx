package shitengine.states.gameplay;

import shitengine.backend.data.SongChartData;
import shitengine.backend.gameplay.SongLoader;
import shitengine.objects.Strum;
import shitengine.objects.gameplay.Character;
#if (target.threaded) import sys.thread.Thread; #end

enum abstract CacheAssetType(String)
{
	var SOUND = "SOUND";
	var IMAGE = "IMAGE";
	var ATLASSPARROW = "SPARROW";
	var ATLASBTA = "FLXANIMATE";
	var custom = "custom";
	var SOUNDc = "sound_paths_cache";
}

typedef CacheType =
{
	var assetPath:String;
	var assetType:CacheAssetType;
	@:optional var customfunc:Void->Void;
}

class LoadingScreen extends flixel.addons.transition.FlxTransitionableState
{
	public var song:SongChartData;
	public var shiToCache:Array<CacheType> = [];

	private var bg:FunkinSprite;

	#if (target.threaded) public var thread:Thread; #end
	public var thingsComplete = 0;
	public var thingsCompleteLerp = 0.0;

	var healthBarBG:FlxSprite;
	var healthBar:FlxBar;

	public function new(songName:String, difficulty:String)
	{
		super();
		song = SongLoader.loadSong(songName, difficulty);
	}

	public override function create()
	{
		var songFolder = song.songFolder;

		addShitToCache({assetType: SOUNDc, assetPath: 'sounds/hitsound'});
		addShitToCache({
			assetType: custom,
			assetPath: null,
			customfunc: () ->
			{
				var strum:Strum = new Strum();

				strum.destroy();
				strum = null;
			}
		});
		var chars = [
			song.data.characters.boyfriend,
			song.data.characters.dad,
			song.data.characters.gf
		];
		for (char in chars)
		{
			addShitToCache({
				assetType: custom,
				assetPath: null,
				customfunc: () ->
				{
					new Character(0, 0, char).destroy();
				}
			});
		}
		chars = null;

		bg = new FunkinSprite();
		bg.loadGraphic(Paths.getGraphic('menus/menuDesat'));
		add(bg);

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.getGraphic('healthBar'));
		healthBarBG.screenCenter(X);
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x, healthBarBG.y, LEFT_TO_RIGHT, Std.int(healthBarBG.width), Std.int(healthBarBG.height), this,
			'thingsCompleteLerp', 0, shiToCache.length - 1);
		healthBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		healthBar.numDivisions = 500;
		// healthBar
		insert(members.indexOf(healthBarBG), healthBar);

		for (i in 0...shiToCache.length)
		{
			var thing = shiToCache[i];
			doShit(thing);
			thingsComplete = i;
		}
	}

	function doShit(thing:CacheType)
	{
		switch (thing.assetType)
		{
			default:
			case SOUND:
				FlxG.sound.cache(thing.assetPath);
			case SOUNDc:
				Paths.getSound(thing.assetPath);
		}
	}

	public override function update(elapsed:Float)
	{
		thingsCompleteLerp = FlxMath.lerp(thingsComplete, thingsCompleteLerp, Math.exp(-elapsed * 10));
		if (Math.abs((shiToCache.length - 1) - thingsComplete) < 0.1)
		{ // close enough
			thingsCompleteLerp = thingsComplete; // snap to target
			PlayState.song = song;
			FlxG.switchState(() -> new PlayState());
		}
		super.update(elapsed);
	}

	public function addShitToCache(assetEntry:CacheType)
	{
		shiToCache.push(assetEntry);
	}
}
