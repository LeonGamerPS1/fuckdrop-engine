package shitengine.backend.external.windows;

#if (windows && cpp)
/**
 * This class provides handling for Windows API-related functions.
 */
@:build(shitengine.util.macro.LinkerMacro.xml('project/Build.xml'))
@:include('winapi.hpp')
extern
#end class WinAPI
{
	/**
	 * Retrieves the current working set size (in bytes) of the process.
	 *
	 * @return The size of the working set memory used by the process.
	 */
	#if (windows && cpp)
	@:native('WINAPI_GetProcessMemoryWorkingSetSize')
	static function getProcessMemoryWorkingSetSize():cpp.SizeT;
	#else
	static function getProcessMemoryWorkingSetSize()
	{
		return 0;
	}
	#end
}
