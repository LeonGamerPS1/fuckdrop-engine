package shitengine.objects;

import animate.FlxAnimate;
import flixel.animation.FlxAnimationController;

typedef OffsetTypeDef =
{
	var offsetX:Float;
	var offsetY:Float;
}

/**
 * Allows you to offset sprites when playing animations
 */
class OffsetSprite extends FlxAnimate
{
	public var updateOffsets:Bool = false;

	public var animController(get, null):FlxAnimationController;

	public var offsets:Map<String, OffsetTypeDef> = new Map<String, OffsetTypeDef>();

	public function setOffset(animName:String, x:Float = 0, y:Float = 0)
	{
		offsets.set(animName, {offsetX: x, offsetY: y});
	}

	public function removeOffset(animName:String)
	{
		offsets.set(animName, null);
	}

	public function playAnim(animName:String, force = false, reversed = false, frame = 0)
	{
		animController.play(animName, force, reversed, frame);
		if (offsets.exists(animName) && isValidAnim(animName))
		{
			offset.set(offsets[animName].offsetX, offsets[animName].offsetY);
		}
	}

	function isValidAnim(animName:String)
	{
		return animController.getByName(animName) != null;
	}

	function get_animController():FlxAnimationController
	{
		return isAnimate ? anim : animation;
	}
}
