package shitengine.util.macro;

import haxe.macro.Context;

class EmbedMacro
{
	public static macro function embedFileContent(filePath:String)
	{
		var data = '';

		if (sys.FileSystem.exists(filePath))
		{
			data = sys.io.File.getContent(filePath);
		}
		else
		{
			Context.error('Missing filepath: "$filePath". Cannot embed contents.', Context.currentPos());
		}

		return macro $v{data};
	}
}
