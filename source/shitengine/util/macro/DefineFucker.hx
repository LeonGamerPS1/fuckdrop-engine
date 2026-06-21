package shitengine.util.macro;

import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.macro.Expr;

class DefineFucker
{
	static final VALID_IDENTIFIER = ~/^[A-Za-z_][A-Za-z0-9_]*$/;

	public static macro function make():Array<Field>
	{
		var fields = Context.getBuildFields();

		var defFields:Map<String, String> = [];
		var defines:Array<String> = [];
		var strDefines:Array<String> = [];

		#if sys
		if (sys.FileSystem.exists(".DEFINES"))
		{
			defines = [
				for (s in sys.io.File.getContent(".DEFINES").split("\n"))
				{
					var trimmed = s.trim();

					if (trimmed.length > 0)
						trimmed;
				}
			];
		}
		#end

		for (define in defines)
		{
			var isString = false;

			if (define.endsWith("="))
			{
				define = define.substr(0, define.length - 1);
				isString = true;
			}

			if (!wantedDefine(define))
				continue;

			var exists = false;

			for (field in fields)
			{
				if (field.name == define)
				{
					exists = true;
					break;
				}
			}

			if (exists)
				continue;

			if (isString)
				strDefines.push(define);

			defFields.set(define, Context.definedValue(define));
		}

		for (define => value in defFields)
		{
			var isString = strDefines.contains(define);

			fields.push({
				name: define,
				doc:
					'Define: $define\n\n'
					+ (isString
						? 'Value: $value'
						: 'Defined: ${value != null}'),
				kind: FVar(
					isString ? macro : String : macro : Bool,
					macro $v{isString ? value : value != null}
				),
				access: [APublic, AStatic, AFinal],
				pos: Context.currentPos()
			});
		}

		return fields;
	}

	public static function wantedDefine(define:String):Bool
	{
		if (define == null)
			return false;

		define = define.trim();

		if (define.length < 1)
			return false;

		if (!VALID_IDENTIFIER.match(define))
			return false;

		var containsz:Array<String> = [
			".",
			"-"
		];

		var startsWith:Array<String> = [
			"FLX_",
			"ANDROID_",
			"JAVA_",
			"lime_",
			"openfl_",
			"haxe",
			"hxcpp",
			"display",
			"utf"
		];

		var isit:Array<String> = [
			"true",
			"static",
			"no_compilation",
			"dce",
			"native",
			"source_header",
			"tools",

			// use #if instead
			"flash",
			"sys",
			"windows",
			"android",
			"mobile",
			"web",
			"linux",
			"mac",
			"desktop",
			"cpp"
		];

		for (thing in isit)
		{
			if (define == thing)
				return false;
		}

		for (thing in containsz)
		{
			if (define.contains(thing))
				return false;
		}

		for (thing in startsWith)
		{
			if (define.startsWith(thing))
				return false;
		}

		return true;
	}
}