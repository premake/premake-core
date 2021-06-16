/**
 * Implementations for Premake's global Lua functions.
 */

#include "../premake_internal.h"


/* Continuation stub for lua_callk(), used by g_doFile() */
static int continuation(lua_State* L, int status, lua_KContext context)
{
	(void)status;
	(void)context;
	return (lua_gettop(L) - 1);
}


/**
 * Replacement for Lua's built-in `dofile()` which knows how to look for
 * files along Premake's search paths.
 */
int g_doFile(lua_State* L)
{
	const char* filename = luaL_optstring(L, 1, NULL);
	lua_settop(L, 1);

	int status = (filename != NULL)
		? pmk_loadFile(L, filename)
		: luaL_loadfile(L, filename);

	if (status != LUA_OK) {
		return lua_error(L);
	}

	lua_callk(L, 0, LUA_MULTRET, 0, continuation);
	return continuation(L, 0, 0);
}


/**
 * Force a module to be loaded, even it was loaded previously.
 */
int g_forceRequire(lua_State* L)
{
	char buffer[PATH_MAX];

	const char* moduleName = luaL_checkstring(L, 1);

	const char* locatedAt = pmk_locateModule(buffer, L, moduleName);
	if (!locatedAt) {
		lua_pushfstring(L, "no such module `%s`", moduleName);
		lua_error(L);
	}

	if (pmk_doFile(L, locatedAt) != LUA_OK)
		lua_error(L);

	/* Add the just loaded module to Lua's "loaded" table */
	luaL_getsubtable(L, LUA_REGISTRYINDEX, LUA_LOADED_TABLE);
    lua_pushvalue(L, -2);
    lua_setfield(L, -2, moduleName);
	lua_pop(L, 1);

	return (1);
}


/**
 * Replacement for Lua's built-in `loadfile()` which knows how to look for
 * files along Premake's search paths.
 */
int g_loadFile(lua_State* L)
{
	const char* filename = luaL_optstring(L, 1, NULL);
	const char* mode = luaL_optstring(L, 2, NULL);

	int status = (filename != NULL)
		? pmk_loadFile(L, filename)
		: luaL_loadfilex(L, filename, mode);

	if (status != LUA_OK) {
		lua_pushnil(L);
		lua_insert(L, -2);  /* error message pushed by loadfile */
		return (2);
	}

	return (1);
}


/**
 * Like `loadfile()`, but returns nil if the file does not exist rather
 * than raising an error.
 */
int g_loadFileOpt(lua_State* L)
{
	const char* filename = luaL_optstring(L, 1, NULL);
	const char* mode = luaL_optstring(L, 2, NULL);

	int status = (filename != NULL)
		? pmk_loadFile(L, filename)
		: luaL_loadfilex(L, filename, mode);

	if (status == LUA_ERRFILE) {
		return (0);
	}
	else if (status != LUA_OK) {
		lua_pushnil(L);
		lua_insert(L, -2);  /* error message pushed by loadfile */
		return (2);
	}
	else {
		return (1);
	}
}
