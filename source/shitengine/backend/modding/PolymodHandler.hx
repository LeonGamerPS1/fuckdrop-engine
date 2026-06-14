package shitengine.backend.modding;

import polymod.Polymod;
import polymod.format.ParseRules;

class PolymodHandler
{
	static public var modROOT:String = "./mods";

	public static function init()
	{
		var mods = Polymod.scan({
			modRoot: modROOT
		});
		var modIDS:Array<String> = [];

		for (mod in mods)
			if (mod != null)
				modIDS.push(mod.id);

		Polymod.init({
			modRoot: modROOT,
			dirs: modIDS,
			framework: OPENFL,
			parseRules: getParseRules(),
			useScriptedClasses: true
		});
	}

	public static function getParseRules()
	{
		var rules = ParseRules.getDefault();
		rules.addType('txt', TextFileFormat.LINES);
		rules.addType('hscript', TextFileFormat.PLAINTEXT);
		rules.addType('hxs', TextFileFormat.PLAINTEXT);
		rules.addType('hxc', TextFileFormat.PLAINTEXT);
		rules.addType('hx', TextFileFormat.PLAINTEXT);
		rules.addType('nx', TextFileFormat.PLAINTEXT);
		rules.addType('frag', TextFileFormat.PLAINTEXT);
		rules.addType('vert', TextFileFormat.PLAINTEXT);
		return rules;
	}
}
