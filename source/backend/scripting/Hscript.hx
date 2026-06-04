package backend.scripting;

import backend.graphics.FlxWindowUtil;
import haxe.Constraints.Function;
import insanity.Script;
import nx.bridge.NxStd;
import nx.script.Bytecode.Value;
import nx.script.Interpreter;
import shaders.RuntimeShader;

class Hscript extends ScriptBase
{
	public var script:Script;

	override function load(path:String)
	{
		script = new Script(OpenFLAssets.getText(path));
         	script.start();
		super.load(path);
       
	}

	override public function get(variable:String):Dynamic
	{
		return (script.variables.get(variable) ?? script.interp.getLocal(variable));
	}

	override public function setVariable(name:String, val:Dynamic, ?convert:Bool = true)
	{
      //  script.interp.environment.variables.set(name, val);
		script.variables.set(name, val);
	}

	override public function setFunction(name:String, func:Dynamic)
	{
		setVariable(name, func);
	}

	override public function dispose()
	{
		script = null;
	}

	override public function call(fn:String, ?fv:Array<Dynamic>):Dynamic
	{
        if(get(fn) == null)
            return null;
		return script.call(fn, fv);
	}
}
