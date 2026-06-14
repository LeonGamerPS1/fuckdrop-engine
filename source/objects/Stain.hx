package objects;

import objects.ui.TileRender;

class Stain extends TileRender
{
	var parent:Note;

	public function new(parent:Note)
	{
		super();
		reload(parent);
	}

	public function reload(n:Note)
	{
		parent = n;
		frames = n.frames;
		animation.copyFrom(n.animation);
		animation.play('hold');
		setTailAnim('end');
		scale.copyFrom(n.scale);
		updateHitbox();
		updateVisuals();
	}

	public function updateVisuals()
	{
		flipY = parent?.strumline?.strums?.members[parent.noteData.l % parent?.strumline?.strums.length]?.flipScroll ?? false;

		var vertScrollMult = (flipY ? -1 : 1);

		var l = parent.noteData.lms;
		shader = parent.shader;
		x = parent.x + parent.width * .5 - width * .5;
		alpha = parent.alpha * 0.7;
		antialiasing = parent.antialiasing;

		var multiplierForNoteYOffsetShit = 0.0;

		y = parent.y + (((parent.height * multiplierForNoteYOffsetShit) + getHeight(l)) * vertScrollMult);

		if (parent.hit)
		{
			l -= Conductor.time - parent.noteData.tms;

			if (flipY)
				multiplierForNoteYOffsetShit = -0.5;

			final strumline = parent.strumline.strums.members[parent.lane];
			y = strumline.y + (((strumline.height * multiplierForNoteYOffsetShit) + getHeight(l)) * vertScrollMult);
		}

		height = getHeight(l);
	}

	function getHeight(l:Float)
	{
		return 0.45 * (parent.strumline?.speed ?? 1) * l;
	}
}
