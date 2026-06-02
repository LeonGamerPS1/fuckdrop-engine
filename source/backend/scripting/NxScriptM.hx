package backend.scripting;

import backend.graphics.FlxWindowUtil;
import haxe.Constraints.Function;
import nx.bridge.NxStd;
import nx.script.Bytecode.Value;
import nx.script.Interpreter;
import shaders.RuntimeShader;

class NxScriptM extends ScriptBase
{
	public var interp:Interpreter;


	override function load(path:String)
	{
		if (interp == null)
			interp = new Interpreter(Main.isDebug, false);
		super.load(path);

		interp.runFile(path);
	}

	override public function get(vari:String)
	{
		return interp.getDynamic(vari);
	}

	override public function setVariable(name:String, val:Dynamic, ?convert:Bool = true)
	{
		interp.globals.set(name, interp.vm.haxeToValue(val));
	}

	override public function setFunction(name:String, func:Function)
	{
		interp.globals.set(name, interp.vm.haxeToValue(func));
	}

	override public function dispose()
	{
		interp = null;
	}

	override public function call(fn:String, ?fv:Array<Dynamic>):Dynamic
	{
		var val = interp.safeCall(fn, arrayToValues(fv, interp));
		return val != null ? interp.vm.valueToHaxe(val) : null;
	}

	static function arrayToValues(fv:Array<Dynamic>, interp:Interpreter)
	{
		if (fv == null)
			return null;
		return [for (huh in fv) interp.vm.haxeToValue(huh)];
	}
}
