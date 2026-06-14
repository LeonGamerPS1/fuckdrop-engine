package states.menus;

import backend.data.SongMetaData;
import backend.data.WeekJsonData;
import backend.gameplay.SongLoader;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import objects.ui.HealthIcon;
import states.gameplay.LoadingScreen;

class FreeplayAlphabet extends Alphabet
{
	public var week:WeekJson;
	public var song:String;
	public var icon:HealthIcon;
	public var meta:SongMetaData;
	public var preventSelection:Bool = false;

	public function new(songName:String, week:WeekJson)
	{
		super(0, 0, songName.toUpperCase(), true);
		this.week = week;
		song = songName;
		var index:Int = week.songs.indexOf(songName);
		icon = new HealthIcon(week.icons[index]);
		icon.sprTracker = this;
		isMenuItem = true;
		meta = SongMetaData.frompath(Paths.getPath('data/songs/$song/meta.json'), true);
		if (meta.data == null)
			preventSelection = true;
		if (preventSelection)
			color = icon.color = 0xFF505050;
	}
}

class FreeplayState extends FlxTransitionableState
{
	public var itemIndex:Int = 0;
	public var item:FreeplayAlphabet;
	public var items:FlxTypedGroup<FreeplayAlphabet> = new FlxTypedGroup<FreeplayAlphabet>();

	override public function create()
	{
		super.create();
		persistentDraw = persistentUpdate = true;
		var bg:FunkinSprite = new FunkinSprite();
		bg.loadImage('menus/menuDesat');
		bg.color = 0xFF999999;
		add(bg);
		WeekJsonData.reload();

		add(items);

		var weekList = WeekJsonData.weekCache.keyValueIterator();
		var weeks = [];
		for (week in weekList)
			weeks.push(week.value);
		weekList = null;
		weeks.sort((w, v) ->
		{
			return w.weekOrder - v.weekOrder;
		});

		for (week in weeks)
		{
			for (song in week.songs)
			{
				var songOBJ = new FreeplayAlphabet(song, week);
				songOBJ.alpha = 0.7;
				items.add(songOBJ);
				songOBJ.targetY = items.length - 1;
				add(songOBJ.icon);
			}
		}
		curDiffText = new FlxText(0, 0, 0, 'stuff');
		curDiffText.size = 20;
		curDiffText.screenCenter(Y);
		add(curDiffText);
		weeks = null;
		changeSelection();
		changeDiff();
	}

	function changeDiff(add:Int = 0)
	{
		if (item.preventSelection)
		{
			FlxG.sound.play(Paths.getSound('sounds/cancelMenu'));
			curDiffText.text = 'Song Difficulty or Meta Missing\n<UNAVAILABLE>';
			return;
		}
		FlxG.sound.play(Paths.getSound('sounds/scrollMenu'));
		curDiff = FlxMath.wrap(curDiff + add, 0, diffs.length - 1);
		var curDiff = diffs[curDiff];
		curDiffText.text = 'Song Difficulty\n<$curDiff>';
		curDiffText.screenCenter(Y);
	}

	var curDiffText:FlxText;

	function changeSelection(add:Int = 0)
	{
		item = items.members[itemIndex];
		item.alpha = 0.5;

		itemIndex = FlxMath.wrap(itemIndex + add, 0, items.length - 1);
		item = items.members[itemIndex];
		item.alpha = 1;
		FlxG.sound.play(Paths.getSound('sounds/scrollMenu'));

		diffs = item.preventSelection ? ['UNAVAILABLE'] : item.meta.data.difficulties;
		curDiff = Math.floor(diffs.length / 2);
		var curDiff = diffs[curDiff];
		if (item.preventSelection)
		{
			curDiffText.text = 'Song Difficulty or Meta Missing\n<UNAVAILABLE>';
		}
		else
			curDiffText.text = 'Song Difficulty\n<$curDiff>';
		curDiffText.screenCenter(Y);
	}

	var selected = false;
	var diffs = ['UK'];
	var curDiff = 0;

	override function update(dT:Float)
	{
		if (!selected)
		{
			if (inputSystem.UI_DOWN_P)
				changeSelection(1);
			else if (inputSystem.UI_UP_P)
				changeSelection(-1);
			if (inputSystem.UI_LEFT_P)
				changeDiff(-1);
			else if (inputSystem.UI_RIGHT_P)
				changeDiff(1);
			else if (inputSystem.BACK)
			{
				FlxG.switchState(() -> new MainMenuState());
			}
			else if (inputSystem.ACCEPT)
			{
				if (!item.preventSelection)
				{
					FlxG.sound.play(Paths.getSound('sounds/confirmMenu'));
					FlxFlicker.flicker(item, 1, 0.07);
					new FlxTimer().start(1, (?t) ->
					{
						try
						{
							FlxG.switchState(() -> new LoadingScreen(item.song, diffs[curDiff]));
						}
						catch (e:Dynamic)
						{
							FlxG.log.error(e);
							Application.current.window.alert(Std.string(e), 'error');
						}
					});
				}
				else
				{
					FlxG.sound.play(Paths.getSound('sounds/cancelMenu'));
				}
			}
		}
		for (i in 0...items.length)
		{
			var item = items.members[i];
			item.targetY = i - itemIndex;
			item.xAdd = (i == itemIndex) ? 150 : 100;
		}
		super.update(dT);
	}
}
