package backend;

class Constants
{
	//public static var gitcommit(default, null):?;
	// general gameplay stuff
	public static inline var PIXEL_PER_MS:Float = 0.46;

	// charter
	public static inline var GRID_SIZE:Int = 40;
	public static inline var STEPS_PER_BEAT:Int = 4;

      public static inline var gitcommit:String = #if gitcommit haxe.macro.Compiler.getDefine("gitcommit") #else 'unknown' #end;
}
