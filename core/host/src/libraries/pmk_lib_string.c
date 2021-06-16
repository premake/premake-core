/**
 * Implementations for Premake's `string.*` functions.
 */

#include "../premake_internal.h"
#include <string.h>


int pmk_string_contains(lua_State* L)
{
	const char* haystack = luaL_checkstring(L, 1);
	const char* needle = luaL_checkstring(L, 2);

	int doesContain = (strstr(haystack, needle) != NULL);
	lua_pushboolean(L, doesContain);
	return (1);
}


int pmk_string_endsWith(lua_State* L)
{
	return (pmk_testStrings(L, pmk_endsWith));
}


int pmk_string_join(lua_State* L)
{
	char buffer[PATH_MAX] = { '\0' };

	const char* separator = luaL_checkstring(L, 1);

	int n = lua_gettop(L);
	if (n == 1)
		return (0);

	for (int i = 2; i <= n; ++i) {
		const char* value = lua_tostring(L, i);
		if (value != NULL) {
			if (i > 2)
				strcat(buffer, separator);
			strcat(buffer, value);
		}
	}

	lua_pushstring(L, buffer);
	return (1);
}


int pmk_string_hash(lua_State* L)
{
	const char* value = luaL_checkstring(L, 1);
	int seed = (int)luaL_optinteger(L, 2, 0);
	lua_pushinteger(L, pmk_hash(value, seed));
	return (1);
}


int pmk_string_patternFromWildcards(lua_State* L)
{
	char buffer[PATH_MAX];

	const char* value = luaL_checkstring(L, 1);

	if (!pmk_patternFromWildcards(buffer, PATH_MAX, value, 0)) {
		lua_pushstring(L, "wildcard expansion is too large");
		lua_error(L);
	}

	lua_pushstring(L, buffer);
	return (1);
}


int pmk_string_startsWith(lua_State* L)
{
	return (pmk_testStrings(L, pmk_startsWith));
}
