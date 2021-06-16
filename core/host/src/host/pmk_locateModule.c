#include "../premake_internal.h"

/**
 * Locate a module file on the standard Premake search paths.
 *
 * @param result
 *    A buffer to hold the results of the search. If successful, will contain
 *    the resolved path to the script file.
 * @param L
 *     The Lua state.
 * @param moduleName
 *     The name of the module to be located.
 * @return
 *    If successful, returns `result`. Otherwise returns `NULL`.
 */
const char* pmk_locateModule(char* result, lua_State* L, const char* moduleName)
{
	static const char* patterns[] = {
		"core/modules/?/?.lua",
		"?/?.lua",
		"modules/?/?.lua",
		"?.lua",
		"modules/?.lua",
		NULL
	};

	return (pmk_locate(result, moduleName, pmk_searchPaths(L), patterns));
}
