package backend.terminal;

import flixel.system.debug.log.LogStyle;
import haxe.Log;
import haxe.PosInfos;

#if (windows && cpp)
// Cunty coloring i hope you work
@:cppFileCode('
#include <windows.h>
#ifndef ENABLE_VIRTUAL_TERMINAL_PROCESSING
#define ENABLE_VIRTUAL_TERMINAL_PROCESSING 0x0004
#endif
')
#end
class CustomLogger
{
	private static var oldLog = null;
	public static var allTraces:Array<String> = [];

	public static function init()
	{
		#if (sys && windows)
		Sys.command("chcp 65001 > nul"); // Setzt Codepage auf UTF-8
		#end
		#if (sys && windows && cpp)
		// Schaltet den ANSI-Support in der Windows-Konsole ein
		untyped __cpp__('
            HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
            DWORD dwMode = 0;
            if (GetConsoleMode(hOut, &dwMode)) {
                dwMode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
                SetConsoleMode(hOut, dwMode);
            }
        ');
		#end
		oldLog = Log.trace;
		Log.trace = CustomLogger.trace;

		// hack FlxG.los so warnings and errors show up in console
		FlxG.log.styles.normal.onLog.add((d, ?d2) ->
		{
			log(d, d2, 'NORMAL');
		});
		FlxG.log.styles.error.onLog.add((d, ?d2) ->
		{
			log(d, d2, 'ERROR');
		});
		FlxG.log.styles.warning.onLog.add((d, ?d2) ->
		{
			log(d, d2, 'WARNING');
		});
		FlxG.log.styles.notice.onLog.add((d, ?d2) ->
		{
			log(d, d2, 'NOTICE');
		});
	}

	public static function rawTrace(str:Dynamic):Void
	{
		#if js
		if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
			(untyped console).log(str);
		#elseif lua
		untyped __define_feature__("use._hx_print", _hx_print(str));
		#elseif sys
		Sys.println(str);
		#end
	}

	public static function trace(content:Dynamic, ?posInfo:PosInfos)
	{
		var str = Std.string(content);
		log(str, posInfo, 'TRACE');
	}

	public static var colorTextInput:Bool = #if (!sys || web) false #else true #end;

	static function log(str:Dynamic, posInfo:Null<PosInfos>, status:String)
	{
		str = Std.string(str);
		var thingToBeLogged = '[$status] ${posInfo?.fileName}:${posInfo?.methodName}(${posInfo?.lineNumber}) $str';

		#if sys
		if (colorTextInput)
		{
			var firstPoop = '[' + colorText(Date.now().toString(), AnsiColor.Magenta) + ']';
			var secondPart = '[' + colorText(status, getColorForStatus(status)) + ']';
			var lastPart = colorText('${posInfo?.fileName}:${posInfo?.methodName}(${posInfo?.lineNumber}) $str', getColorForStatus(status));
			var coloredText = '$firstPoop $secondPart $lastPart';
			Sys.println(coloredText);
		}
		else
			oldLog(thingToBeLogged, posInfo);
		#else
		oldLog(thingToBeLogged, posInfo);
		#end
		allTraces.push(thingToBeLogged);
	}

	static function getColorForStatus(status:String):AnsiColor
	{
		switch (status.toLowerCase())
		{
			default:
				return Empty;
			case 'info':
				return Blue;
			case "warning" | 'notice':
				return Yellow;
			case "error":
				return Red;
		}
	}

	static function colorText(text:String, color:AnsiColor):String
	{
		if (color == Empty)
			return text;
		return color.code() + text + AnsiColor.White.code(); // reset to default after
	}
}
