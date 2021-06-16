/**
 * Implementations for Premake's `premake.*` functions.
 */

#include "../premake_internal.h"


int pmk_premake_locateModule(lua_State* L)
{
	char result[PATH_MAX];

	const char* moduleName = luaL_checkstring(L, 1);
	if (pmk_locateModule(result, L, moduleName)) {
		lua_pushstring(L, result);
		return (1);
	}

	return (0);
}


int pmk_premake_locateScript(lua_State* L)
{
	char result[PATH_MAX];

	/* if given an array if names to check, iterate and return first hit */
	if (lua_istable(L, 1)) {
		int n = lua_rawlen(L, 1);
		for (int i = 1; i <= n; ++i) {
			lua_rawgeti(L, 1, i);
			const char* scriptName = lua_tostring(L, -1);
			if (pmk_locateScript(result, L, scriptName)) {
				lua_pushstring(L, result);
				return (1);
			}
		}
	} else {
		const char* scriptName = lua_tostring(L, 1);
		if (pmk_locateScript(result, L, scriptName)) {
			lua_pushstring(L, result);
			return (1);
		}
	}

	return (0);
}
