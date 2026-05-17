package states.options.subs;

class VSLICEFreeplay extends FlxSubState
{
	var DJ:FunkinSprite;

	public override function create()
	{
		super.create();
		DJ = new FunkinSprite();
		DJ.loadAtlas('menus/freeplay/freeplay-boyfriend', ANIMATE);
		DJ.addAnimPrefix('slidein', 'boyfriend dj intro', 24);
		DJ.addAnimPrefix('defaultIdle', 'Boyfriend DJ', 24, true);
		DJ.addAnimPrefix('confirm', 'Boyfriend DJ confirm', 24);
		DJ.addAnimPrefix('yeahh', 'Boyfriend DJ fist pump', 24);
		DJ.addAnimPrefix('nooo', 'Boyfriend DJ loss reaction 1', 24);
		DJ.addAnimPrefix('watchin tv', 'Boyfriend DJ watchin tv OG', 24);
		DJ.antialiasing = true;
		DJ.playAnim('slidein');

		DJ.anim.onFinish.addOnce((e) ->
		{
			DJ.playAnim('defaultIdle');
		});
		add(DJ);
		var pinkBack = new FunkinSprite();
		pinkBack.color = FlxColor.PINK;
		pinkBack.loadImage('menus/freeplay/pinkBack');

		var backingImage = new FunkinSprite(pinkBack.width * 0.74, 0);
		backingImage.loadImage('menus/freeplay/freeplayBGweek1-bf');
		add(pinkBack);
		add(backingImage);
	}
}
