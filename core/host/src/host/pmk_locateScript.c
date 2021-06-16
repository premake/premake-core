#include "../premake_internal.h"

/**
 * Locate a script file on the standard Premake search paths.
 *
 * @param result
 *    A buffer to hold the results of the search. If successful, will contain
 *    the resolved path to the script file.
 * @param L
 *     The Lua state.
 * @param filename
 *     The full name of the script to be located, including the file extension.
 * @return
 *    If successful, returns `result`. Otherwise returns `NULL`.
 */
const char* pmk_locateScript(char* result, lua_State* L, const char* filename)
{
	const char* patterns[] = { "?", NULL };
	return (pmk_locate(result, filename, pmk_searchPaths(L), patterns));
}
