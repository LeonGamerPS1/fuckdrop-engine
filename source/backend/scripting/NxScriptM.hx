package backend.scripting;

import backend.graphics.FlxWindowUtil;
import haxe.Constraints.Function;
import nx.bridge.NxStd;
import nx.script.Bytecode.Value;
import nx.script.Interpreter;
import nx.script.SyntaxRules;
import shaders.RuntimeShader;

class NxScriptM
{
	public var interp:Interpreter;
	public var name:String;

	public function new(scriptName:String, path:String)
	{
		this.name = scriptName;
		interp = new Interpreter(Main.isDebug, false, SyntaxRules.nxScript());
		load(path);
	}

	function load(path:String)
	{
		NxStd.registerAll(interp.vm);
		setVariable('game', FlxG.state);
		setVariable('FlxSprite', VNativeObject(FlxSprite), false);
		setVariable('FunkinSprite', VNativeObject(FunkinSprite), false);
		setVariable('FlxG', VNativeObject(FlxG), false);
		setVariable('FlxWindowUtil', VNativeObject(FlxWindowUtil), false);
		setFunction('createShader',(n:String,?glVersion:Int)->{
			return new RuntimeShader(n);
		});
		

		interp.runFile(path);

	
	}

	public function get(vari:String)
	{
		return interp.getDynamic(vari);
	}

	public function setVariable(name:String, val:Dynamic, ?convert:Bool = true)
	{
		interp.globals.set(name, convert ? interp.vm.haxeToValue(val) : val);
	}

	public function setFunction(name:String, func:Function)
	{
		interp.globals.set(name, interp.vm.haxeToValue(func));
	}

	public function dispose()
	{
		interp = null;
	}

	public function call(fn:String, ?fv:Array<Dynamic>)
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
