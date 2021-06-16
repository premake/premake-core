#include "../premake_internal.h"

/**
 * A module "searcher" which knows how to use Premake's search paths and
 * module naming conventions. Installed into the first position of Lua's
 * `package.searchers` table on startup.
 */
int pmk_moduleLoader(lua_State* L)
{
	char buffer[PATH_MAX];

	const char* moduleName = luaL_checkstring(L, 1);

	const char* locatedAt = pmk_locateModule(buffer, L, moduleName);
	if (!locatedAt) {
		return (0);
	}

	int status = pmk_load(L, locatedAt);
	if (status == LUA_OK) {
		lua_pushstring(L, locatedAt);
		return (2);
	} else {
		return luaL_error(L, "error loading module '%s' from file '%s':\n\t%s",
			lua_tostring(L, 1),
			locatedAt,
			lua_tostring(L, -1));
	}
}
