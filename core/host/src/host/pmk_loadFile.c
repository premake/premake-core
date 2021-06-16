#include "../premake_internal.h"


/**
 * Premake specific implementation of Lua's `loadfile()`.
 *
 * @return
 *    Return behavior matches [luaL_loadfilex](https://www.lua.org/manual/5.3/manual.html#luaL_loadfilex).
 */
int pmk_loadFile(lua_State* L, const char* filename)
{
	char buffer[PATH_MAX];

	const char* locatedAt = pmk_locateScript(buffer, L, filename);

	if (!locatedAt) {
		lua_pushfstring(L, "cannot open %s: No such file or directory", filename);
		return (LUA_ERRFILE);
	}

	int status = pmk_load(L, locatedAt);
	return (status);
}
