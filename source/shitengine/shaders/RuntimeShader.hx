package shitengine.shaders;

import flixel.addons.display.FlxRuntimeShader;

class RuntimeShader extends FlxRuntimeShader
{
	public function new(shaderName:String, ?glVersion:Int)
	{
		var shaderFrag = Paths.GetFragShader(shaderName);
		var shaderVert = Paths.GetVertShader(shaderName);
		super(shaderFrag, shaderVert);
	}
}
