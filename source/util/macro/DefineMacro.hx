package util.macro;

import haxe.macro.Context;

class DefineMacro
{
	public static macro function defined(define:String)
	{
		return macro $v{Context.defined(define)};
	}
}
