/**
 * Implementations for Premake's `io.*` functions.
 */

#include "../premake_internal.h"


int pmk_io_compareFile(lua_State* L)
{
	const char* path = luaL_checkstring(L, 1);
	const char* contents = luaL_checkstring(L, 2);

	int result = pmk_compareFile(path, contents);
	if (result >= 0) {
		lua_pushboolean(L, result);
		return (1);
	} else {
		lua_pushnil(L);
		lua_pushfstring(L, "unable to read file '%s'", path);
		return (2);
	}
}


int pmk_io_writeFile(lua_State* L)
{
	const char* path = luaL_checkstring(L, 1);
	const char* contents = luaL_checkstring(L, 2);

	if (pmk_writeFile(path, contents) == OKAY) {
		lua_pushboolean(L, TRUE);
		return (1);
	} else {
		lua_pushnil(L);
		lua_pushfstring(L, "unable to write file to '%s'", path);
		return (2);
	}
}
