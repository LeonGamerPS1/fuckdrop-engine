package states;

import flixel.math.FlxPoint;
import objects.gameplay.Character;

class GameoverState extends FlxState
{
	var bfpos:FlxPoint = FlxPoint.get();
	var oldCamPos:FlxPoint = FlxPoint.get();
	var bf:Character;
	var camPos:FlxObject = new FlxObject();
	var oldZoom:Float = 1;

	static public var deathSound = 'fnf_loss_sfx';
	static public var deathMusic = 'gameOver';
	static public var deathEnd = 'gameOverEnd';
	static public var gameoverChar = 'bf-dead';

	public function new(bfPos:FlxPoint, oldCamPos:FlxPoint)
	{
		super();
		this.oldCamPos.copyFrom(oldCamPos);
		this.bfpos = bfPos ?? FlxPoint.get();
		oldZoom = FlxG.camera.zoom;
	}

	override function create()
	{
		super.create();
		FlxG.sound.play(Paths.getSound('sounds/$deathSound'));

		bf = new Character(0, 0, gameoverChar, true);
		bf.setPosition(bfpos.x + bf.json.pos_offset[0], bfpos.y + bf.json.pos_offset[1]);
		bf.playAnim('firstDeath');
		add(bf);
		add(camPos);

		// make it seamlessly transition lol
		FlxG.camera.scroll.copyFrom(oldCamPos);
		FlxG.camera.follow(camPos, LOCKON, 0.03);
		FlxG.camera.zoom = oldZoom;
		camPos.setPosition(bf.getMidpoint().x - 100, bf.getMidpoint().y - 100);
		camPos.x -= bf.json.cam_offset[0];
		camPos.y += bf.json.cam_offset[1];

		// clean up
		bfpos.put();
		oldCamPos.put();
		oldCamPos = bfpos = null;
		new FlxTimer().start(2.3, onDieMiddle);
	}

	var confirmed = false;

	// play music
	public function onDieMiddle(m)
	{
		if (confirmed)
			return;
		bf.playAnim('deathLoop');
		FlxG.sound.playMusic(Paths.getSound('music/$deathMusic', true));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (inputSystem.ACCEPT && !confirmed)
		{
			confirmed = true;
			bf.playAnim('deathConfirm');
			FlxG.sound.playMusic(Paths.getSound('sounds/$deathEnd'));
			FlxG.camera.fade(0xFF000000, 4, exit);
		}
	}

	public function exit()
	{
		FlxG.switchState(new PlayState());
	}
}
