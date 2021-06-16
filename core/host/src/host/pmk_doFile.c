#include "../premake_internal.h"

/**
 * Replacement implementation for Lua's `dofile()` which knows how
 * to search for files along Premake's search paths.
 *
 * @param L
 *    The Lua state.
 * @param filename
 *    The name of the script to be loaded and run.
 */
int pmk_doFile(lua_State* L, const char* filename)
{
	int status = pmk_loadFile(L, filename);

	if (status == OKAY) {
		status = lua_pcall(L, 0, LUA_MULTRET, 0);
	}

	return (status);
}
