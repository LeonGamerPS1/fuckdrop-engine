package backend.scripting;

import backend.graphics.FlxWindowUtil;
import haxe.Constraints.Function;
import shaders.RuntimeShader;

class ScriptBase
{
	public var name:String;

	public function new(scriptName:String, path:String)
	{
		this.name = scriptName;

		load(path);
	}

	function load(path:String)
	{
		setVariable('game', FlxG.state);
		setVariable('FlxSprite', FlxSprite, false);
		setVariable('FunkinSprite', FunkinSprite, false);
		setVariable('FlxG', FlxG, false);
		setVariable('FlxWindowUtil', FlxWindowUtil, false);
		setFunction('createShader', (n:String, ?glVersion:Int) ->
		{
			return new RuntimeShader(n, glVersion);
		});
	}

	public function get(vari:String)
	{
		return null;
	}

	public function setVariable(name:String, val:Dynamic, ?convert:Bool = true) {}

	public function setFunction(name:String, func:Function) {}

	public function dispose() {}

	public function call(fn:String, ?fv:Array<Dynamic>):Dynamic {
        return null;
    }
}
