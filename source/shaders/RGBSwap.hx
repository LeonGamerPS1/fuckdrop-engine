package shaders;

import flixel.util.FlxColor;

// made by inky03 https://github.com/inky03/FUNKINX3/blob/notepool/source/funkin/shaders/RGBSwap.hx, edited by me
class RGBSwap
{
	public var red(default, set):FlxColor;
	public var blue(default, set):FlxColor;
	public var green(default, set):FlxColor;
	public var shader(default, null):RGBSwapShader = new RGBSwapShader();
	public var enabled(default, set):Bool = true;

	public function set_enabled(newE:Bool)
	{
		enabled = newE;
		if (shader != null && shader.enabled != null)
			shader.enabled.value = [newE];
		return newE;
	}

	public function copy(?targetShd:RGBSwap):RGBSwap
	{
		if (targetShd != null)
		{
			targetShd.green = green;
			targetShd.blue = blue;
			targetShd.red = red;
		}
		else
		{
			targetShd = new RGBSwap(red, green, blue);
		}
		return targetShd;
	}

	public function set_red(newC:FlxColor)
	{
		red = newC;
		if (shader != null && shader.red != null)
			shader.red.value = [newC.redFloat, newC.greenFloat, newC.blueFloat];
		return newC;
	}

	public function set_green(newC:FlxColor)
	{
		green = newC;
		if (shader != null && shader.green != null)
			shader.green.value = [newC.redFloat, newC.greenFloat, newC.blueFloat];
		return newC;
	}

	public function set_blue(newC:FlxColor)
	{
		blue = newC;
		if (shader != null && shader.blue != null)
			shader.blue.value = [newC.redFloat, newC.greenFloat, newC.blueFloat];
		return newC;
	}

	public function set(red:FlxColor = FlxColor.RED, green:FlxColor = FlxColor.LIME, blue:FlxColor = FlxColor.BLUE)
	{
		this.red = red;
		this.green = green;
		this.blue = blue;
	}

	public function new(red:FlxColor = FlxColor.RED, green:FlxColor = FlxColor.LIME, blue:FlxColor = FlxColor.BLUE)
	{
		// 1. Force the custom FlxShader class to initialize its uniforms first
		@:privateAccess {
			if (shader.__initGL != null)
				shader.__initGL();
		}

		// 2. Set internal properties safely
		this.set(red, green, blue);
		this.enabled = true;
	}
}

class RGBSwapShader extends flixel.system.FlxAssets.FlxShader
{
	@:glFragmentHeader('
		#pragma header

		uniform vec3 red;
		uniform vec3 green;
		uniform vec3 blue;
		uniform bool enabled;
		
		vec4 applyColorTransform(vec4 color) {
		    if (color.a == 0.) {
		        return vec4(0.);
		    }
		    if (!hasTransform) {
		        return color;
		    }
		    if (!hasColorTransform) {
		        return color * openfl_Alphav;
		    }

		    color = vec4(color.rgb / color.a, color.a);
		    color = clamp(openfl_ColorOffsetv + color * openfl_ColorMultiplierv, 0., 1.);

		    if (color.a > 0.) {
		        return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
		    }
		    return vec4(0.);
		}

		vec4 flixel_texture2DCustom(sampler2D bitmap, vec2 uv) {
			vec4 color = texture2D(bitmap, uv);
			if (color.a == 0.0) {
				return color;
			}

			// Clean swap math: isolate input channels before scaling by target colors
			vec3 swapped = (color.r * red) + (color.g * green) + (color.b * blue);
			color.rgb = min(swapped, color.a);
			return applyColorTransform(color);
		}
	')
	@:glFragmentSource('
		#pragma header

		void main() {
			if(enabled)
				gl_FragColor = flixel_texture2DCustom(bitmap, openfl_TextureCoordv);
			else 
				gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
		}
	')
	public function new()
	{
		super();
	}
}
