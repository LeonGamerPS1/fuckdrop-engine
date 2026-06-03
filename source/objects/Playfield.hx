package objects;

import backend.data.SongChartData;
import flixel.ui.FlxBar;
import modchart.Manager;
import objects.ui.HealthIcon;

class Playfield extends FlxGroup implements backend.graphics.ModchartBackend.IModchartInstance
{
	public var dadStrumline:Strumline;
	public var bfStrumline:Strumline;
	public var modchartingCameras:Array<FlxCamera> = [FlxG.camera];
	public var speed:Float = 1;

	public var currentSong:SongChartData;

	// healthbar
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	// timeBar
	public var progressBarBG:FlxSprite;
	public var progressBar:FlxBar;
	public var time:FlxText;

	public var health:Float = 1;

	private var curHealth:Float = 1;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public var modchartSystem:Manager;
	public var bot:Bool = false;

	public function new(song:SongChartData, skin:String = "default", keys:Int = 4)
	{
		backend.graphics.ModchartBackend.instance = this;
		modchart.Config.HOLDS_BEHIND_STRUM = SaveData.currentSettings.sustainsBehind;
		speed = song.data.speed;
		super();
		modchartSystem = new Manager();
		add(modchartSystem);
		final strumY = SaveData.currentSettings.downScroll ? FlxG.height - 150 : 50;
		Conductor.offset = song.data.offset ?? 0;
		Conductor.bpm = song.data.bpm;
		dadStrumline = cast(add(new Strumline(this, song.data.oppSkin ?? skin, keys)));
		bfStrumline = cast(add(new Strumline(this, skin, keys)));

		for (sL in [dadStrumline, bfStrumline])
		{
			sL.onHitNote.add(hitNote);
			sL.onMissNote.add(missNote);
		}

		dadStrumline.isBot = true;
		dadStrumline.visible = SaveData.currentSettings.opponentStrums;
		dadStrumline.strums.setPosition(100, strumY);
		bfStrumline.strums.setPosition(100 + (FlxG.width / 2), strumY);
		bfStrumline.speed = dadStrumline.speed = song.data.speed;
		currentSong = song;

		if (!SaveData.currentSettings.opponentStrums || SaveData.currentSettings.middleScroll)
			dadStrumline.strums.x = -1000;
		if (SaveData.currentSettings.middleScroll)
			bfStrumline.strums.screenCenter(X);

		for (tm in song.data.timingChanges)
			Conductor.addTimeChangeAt(tm.time, tm.bpm);

		dadStrumline.generateNotes(song.data.notes.filter((n) ->
		{
			return n.l < 4;
		}));
		bfStrumline.generateNotes(song.data.notes.filter((n) ->
		{
			return n.l > 3;
		}));

		Conductor.onBeat.add(beatHit);
		Conductor.onStep.add(stepHit);

		healthBarBG = new FlxSprite(0, !SaveData.currentSettings.downScroll ? FlxG.height * 0.9 + 1 : 120).loadGraphic(Paths.getGraphic('healthBar'));
		healthBarBG.screenCenter(X);
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x, healthBarBG.y, RIGHT_TO_LEFT, Std.int(healthBarBG.width), Std.int(healthBarBG.height), this, 'curHealth', 0, 2);
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.numDivisions = 500;
		// healthBar
		insert(members.indexOf(healthBarBG), healthBar);

		progressBarBG = new FlxSprite(0, 25).loadGraphic(Paths.getGraphic('healthBar'));
		progressBarBG.screenCenter(X);
		add(progressBarBG);

		progressBar = new FlxBar(progressBarBG.x, progressBarBG.y, LEFT_TO_RIGHT, Std.int(progressBarBG.width), Std.int(progressBarBG.height), Conductor,
			'time', -200 * 200, 0);
		progressBar.createFilledBar(0xFF6D6D6D, 0xFF66FF33);
		progressBar.alpha = 0;
		progressBar.numDivisions = 1000;
		// healthBar
		insert(members.indexOf(progressBarBG), progressBar);

		iconP1 = new HealthIcon("bf", true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		iconP2 = new HealthIcon("dad", false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		add(iconP2);
		add(iconP1);
		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 150, healthBarBG.y + 50, 0, "", 20);
		scoreTxt.setFormat(Paths.getFont("vcr"), 14, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		add(scoreTxt);

		var shitWatermark = new FlxText(4, FlxG.height - 17, 0, song.meta.data.songDisplayName + "-" + (song.diff) + " | SE " + Main.version, 16);
		shitWatermark.setFormat(Paths.getFont("vcr"), 14, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		shitWatermark.scrollFactor.set();
		shitWatermark.antialiasing = scoreTxt.antialiasing = true;

		add(shitWatermark);

		time = new FlxText(4, FlxG.height - 17, 0, song.meta.data.songDisplayName + "-" + (song.diff) + " | SE " + Main.version, 16);
		time.setFormat(Paths.getFont("vcr"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		time.antialiasing = scoreTxt.antialiasing = true;
		time.screenCenter(X);
		time.y = progressBar.y + (progressBar.height / 2 - time.height / 2);
		add(time);

		for (member in members)
			if (!(member is Strumline) && member != modchartSystem && SaveData.currentSettings.hideHUD)
				member.kill();

		noteSplashes = new FlxTypedGroup<NoteSplash>();
		add(noteSplashes);
	}

	public var modchartEnabled:Bool = false;

	public function spawnSplashOnStrum(s:Strum)
	{
		var s2 = noteSplashes.recycle(NoteSplash);
		s2.setupNoteSplash(s);
		s2.revive();
	}

	public var songScore:Int = 0;
	public var misses:Int = 0;
	public var accuracy:Float = 0.000000000000000001;

	var scoreTxt:FlxText;

	public function missNote(n:Note, dir:Int, strumline)
	{
		health -= 0.20;
		songScore -= 350;
		misses++;
		updateAccuracy();
	}

	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;

	public function hitNote(n:Note)
	{
		if (!n.strumline.isBot || n.strumline == bfStrumline)
		{
			if (health < 2)
				health += 0.04;
			if (n.isSustainNote)
				totalNotesHit += 1;
			else
			{
				accuracyUpdate(n);
			}
			updateAccuracy();
		}
	}

	public var ss:Bool = false;
	public var noteSplashes:FlxTypedGroup<NoteSplash>;

	function accuracyUpdate(n:Note)
	{
		var noteDiff:Float = Math.abs(n.noteData.tms - Conductor.time);
		var daRating:String = "sick";
		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		if (noteDiff > Conductor.sfz * 0.9)
		{
			daRating = 'shit';
			totalNotesHit += 0.1;
			score = 50;
			ss = false;
		}
		else if (noteDiff > Conductor.sfz * 0.75)
		{
			daRating = 'bad';
			score = 100;
			totalNotesHit += 0.2;
			ss = false;
		}
		else if (noteDiff > Conductor.sfz * 0.25)
		{
			daRating = 'good';
			totalNotesHit += 0.65;
			score = 200;
			ss = false;
		}

		if (daRating == "sick")
		{
			totalNotesHit += 1;
			spawnSplashOnStrum(n.strumline.strums.members[n.noteData.l % 4]);
		}
		n.rating = daRating;
		songScore += score;
	}

	public var fc:Bool = false;

	function updateAccuracy()
	{
		if (misses > 0 || accuracy < 96)
			fc = false;
		else
			fc = true;
		totalPlayed += 1;
		accuracy = totalNotesHit / totalPlayed * 100;
	}

	public function beatHit(beat:Float)
	{
		dadStrumline?.beatHit();
		bfStrumline?.beatHit();

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();
		for (icon in [iconP1, iconP2])
		{
			FlxTween.cancelTweensOf(icon.scale);
			FlxTween.tween(icon.scale, {x: 1, y: 1}, 0.02);
		}
	}

	public function stepHit(step:Float)
	{
		dadStrumline?.stepHit();
		bfStrumline?.stepHit();
	}

	override function update(elapsed:Float)
	{
		// clean this up later

		time.text = FlxStringUtil.formatTime(Conductor.time / 1000);
		time.screenCenter(X);
		if (healthBarBG.alpha != healthBar.alpha)
			healthBarBG.alpha = healthBar.alpha;
		if (progressBarBG.alpha != progressBar.alpha)
			progressBarBG.alpha = progressBar.alpha;
		FlxTween.cancelTweensOf(this, ["curHealth"]);
		FlxTween.tween(this, {curHealth: health}, 0.2);
		super.update(elapsed);
		// var scaleP1 = FlxMath.lerp(1, iconP1.scale.x, Math.exp(-elapsed * 8));
		// var scaleP2 = FlxMath.lerp(1, iconP2.scale.x, Math.exp(-elapsed * 8));
		// iconP1.scale.set(scaleP1, scaleP1);
		// iconP2.scale.set(scaleP2, scaleP2);

		var scoreTextText = !bot ? "Score:"
			+ songScore
			+ " | Misses:"
			+ misses
			+ " | Accuracy:"
			+ FlxMath.roundDecimal(accuracy, 2)
			+ "% "
			+ (misses < 1 ? "| FC" : misses == 0 ? "| A" : accuracy <= 75 ? "| BAD" : "") : "Invalidated Run - BotPlay Enabled";
		if (scoreTxt.text != scoreTextText)
		{
			scoreTxt.text = scoreTextText;
			scoreTxt.screenCenter(X);
		}

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;
	}
}
