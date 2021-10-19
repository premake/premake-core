#include "../premake_internal.h"
#include <string.h>

#define SEARCH_PATH_MAX   (128)

static const char* paths[SEARCH_PATH_MAX];


/**
 * Retrieve the current value of `_PREMAKE.PATH` as an array of strings.
 */
const char** pmk_searchPaths(lua_State* L)
{
	lua_getglobal(L, "_PREMAKE");
	lua_pushstring(L, "PATH");
	lua_rawget(L, -2);

	size_t len = lua_rawlen(L, -1);
	size_t n = 0;

	for (size_t i = 1; i <= len && i < SEARCH_PATH_MAX; ++i) {
		lua_rawgeti(L, -1, i);

		if (lua_isfunction(L, -1)) {
			lua_call(L, 0, 1);
		}

		if (!lua_isnil(L, -1) && n < SEARCH_PATH_MAX) {
			paths[n++] = lua_tostring(L, -1);
		}

		lua_pop(L, 1);
	}

	lua_pop(L, 2);
	paths[n] = NULL;
	return (paths);
}
