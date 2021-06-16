#include "../premake_internal.h"
#include <string.h>

static int runScriptChunk(lua_State* L);


/**
 * Premake specific low-level script loader; all other script loading calls end
 * up here eventually.
 *
 * @param filename
 *    The path to the file to be loaded. Any path searching should have already
 *    been done before getting here; this path is assumed correct as-is. If path
 *    searching is needed, use `pmk_loadFile()` instead.
 * @return
 *    Return behavior matches [lua_load](https://www.lua.org/manual/5.3/manual.html#lua_load),
 */
int pmk_load(lua_State* L, const char* filename)
{
	/* TODO: support for more file system protocols will cut in here */

	int status = luaL_loadfile(L, filename);
	if (status != LUA_OK) {
		return (status);
	}

	/* The loaded chunk is now on the stack. Wrap it together with its filename
	 * into a closure that can be called to prepare the _SCRIPT globals prior
	 * to running the chunk. */
	lua_pushstring(L, filename);
	lua_pushcclosure(L, runScriptChunk, 2);

	return (status);
}


/**
 * Execute a chunk of code previously loaded by pmk_load(), above. Sets the
 * _SCRIPT and _SCRIPT_DIR global variables to the absolute path of the
 * chunk's filename.
 */
static int runScriptChunk(lua_State* L)
{
	int numArgs = lua_gettop(L);

	/* set in the closure by pmk_loader() */
	const char* filename = lua_tostring(L, lua_upvalueindex(2));

	/* get absolute path to the script */
	char scriptPath[PATH_MAX];
	pmk_getAbsolutePath(scriptPath, filename, NULL);

	/* note current _SCRIPT & _SCRIPT_DIR on the stack; will restore after chunk has run */
	lua_getglobal(L, "_SCRIPT");
	lua_getglobal(L, "_SCRIPT_DIR");

	/* set new _SCRIPT global */
	lua_pushstring(L, scriptPath);
	lua_setglobal(L, "_SCRIPT");

	/* separate out directory portion of _SCRIPT and assign to _SCRIPT_DIR */
	const char* ptr = strrchr(scriptPath, '/');
	int endAt = (ptr != NULL) ? (ptr - scriptPath) : (int)strlen(scriptPath);
	lua_pushlstring(L, scriptPath, endAt);
	lua_setglobal(L, "_SCRIPT_DIR");

	/* move the script chunk and any arguments to the top of the stack */
	lua_pushvalue(L, lua_upvalueindex(1));
	for (int i = 1; i <= numArgs; ++i) {
		lua_pushvalue(L, i);
	}

	/* run it */
	lua_call(L, numArgs, LUA_MULTRET);

	/* restore previous _SCRIPT and _SCRIPT_DIR */
	lua_pushvalue(L, numArgs + 1);
	lua_setglobal(L, "_SCRIPT");
	lua_pushvalue(L, numArgs + 2);
	lua_setglobal(L, "_SCRIPT_DIR");

	return (lua_gettop(L) - numArgs - 2);
}
