package shitengine.util.macro;

import haxe.macro.Context;
import haxe.macro.Expr.Field;

/**
 * https://github.com/bopel-maki-macohi/Enboch/blob/6b62d2f70d2e1c88885cf5523ec26ed8247017b4/source/enboch/util/macro/DefineFucker.hx
 * My thing, I can yoink it
 * - Maki
 */

class DefineFucker
{
	public static macro function make():Array<Field>
	{
		var fields = Context.getBuildFields();

		var defFields:Map<String, String> = [];

		var defines:Array<String> = [];

		#if sys
		defines = [
			for (s in sys.io.File.getContent('.DEFINES').split('\n'))
				if (s.trim().length > 0) s.trim()
		];
		#end

		var strDefines:Array<String> = [];

		for (define in defines)
		{
			if (define.endsWith('='))
			{
				define = define.substr(0, define.length - 1);
				strDefines.push(define);
			}

			if (!wantedDefine(define))
				continue;

			for (field in fields)
				if (field.name == define)
					continue;

			defFields.set(define, Context.definedValue(define));
		}

		for (define => value in defFields)
		{
			trace(define);
			fields.push({
				name: define,
				doc: 'Define: $define\n\n' + (strDefines.contains(define) ? 'Value: $value' : 'Defined: ${value != null}'),
				kind: FVar(strDefines.contains(define) ? macro :String : macro :Bool, macro $v{strDefines.contains(define) ? value : value != null}),
				access: [APublic, AStatic, AFinal],
				pos: Context.currentPos(),
			});
		}

		return fields;
	}

	public static function wantedDefine(define:String):Bool
	{
		var containsz:Array<String> = ['.', '-',];
		var startsWith:Array<String> = [
			'FLX_',
			'ANDROID_',
			'JAVA_',
			'lime_',
			'openfl_',
			'haxe',
			'hxcpp',
			'display',
			'utf',
		];
		var isit:Array<String> = [
			'true',
			'static',
			'no_compilation',
			'dce',
			'native',
			'source_header',
			'tools',

			// use an #if
			'flash',
			'sys',
			'windows',
			'android',
			'mobile',
			'web',
			'linux',
			'mac',
			'desktop',
			'cpp',
		];

		for (thing in isit)
			if (define == thing)
				return false;

		for (thing in containsz)
			if (define.contains(thing))
				return false;

		for (thing in startsWith)
			if (define.startsWith(thing))
				return false;

		if (define.trim().length < 1)
			return false;

		return true;
	}
}
