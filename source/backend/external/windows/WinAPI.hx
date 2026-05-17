package backend.external.windows;

#if (windows && cpp)
/**
 * This class provides handling for Windows API-related functions.
 */
@:build(util.macro.LinkerMacro.xml('project/Build.xml'))
@:include('winapi.hpp')
extern class WinAPI
{
	/**
	 * Retrieves the current working set size (in bytes) of the process.
	 *
	 * @return The size of the working set memory used by the process.
	 */
	@:native('WINAPI_GetProcessMemoryWorkingSetSize')
	static function getProcessMemoryWorkingSetSize():cpp.SizeT;
}
#end
