/**
 * \file   lua_auxlib.c
 * \brief  Modifications and extensions to Lua's library functions.
 * \author Copyright (c) 2014 Jason Perkins and the Premake project
 */

#include "premake.h"


static int chunk_wrapper(lua_State* L);



/* Pull in Lua's aux lib implementation, but rename luaL_loadfile() so I
 * can replace it with my own implementation. */

#define luaL_loadfile  original_luaL_loadfile
#include "lua-5.1.4/src/lauxlib.c"
#undef luaL_loadfile



/**
 * Extend the default implementation of luaL_loadfile() to call my chunk
 * wrapper, above, before executing any scripts loaded from a file.
 */

LUALIB_API int luaL_loadfile (lua_State* L, const char* filename)
{
	int z;

	/* try to locate the script on the filesystem */

	if (do_isfile(filename)) {
		lua_pushstring(L, filename);
	}
	else {
		lua_pushcfunction(L, os_pathsearch);
		lua_pushstring(L, filename);
		lua_pushstring(L, scripts_path);
		lua_pushstring(L, getenv("PREMAKE_PATH"));
		lua_call(L, 3, 1);

		if (!lua_isnil(L, -1)) {
			lua_pushstring(L, "/");
			lua_pushstring(L, filename);
			lua_concat(L, 3);
		}
	}

	if (!lua_isnil(L, -1)) {
		int i = lua_gettop(L);
		z = original_luaL_loadfile(L, lua_tostring(L, -1));
		lua_remove(L, i);
	}
	else {
		lua_pop(L, 1);
		z = premake_load_embedded_script(L, filename);
	}

	if (z == OKAY) {
		lua_pushstring(L, filename);
		lua_pushcclosure(L, chunk_wrapper, 2);
	}

	return z;
}



/**
 * Execute a chunk of code previously loaded by my customized version of
 * luaL_loadfile(), below. Sets the _SCRIPT global variable to the absolute
 * path of the loaded chunk, and makes its enclosing directory current so
 * that relative path references to other files or scripts can be used.
 */

static int chunk_wrapper(lua_State* L)
{
	char cwd[PATH_MAX];
	char script[PATH_MAX];
	const char* filename;
	char* ptr;
	int i, args;

	args = lua_gettop(L);

	/* Remember the current _SCRIPT and working directory so I can
	 * restore them after this new chunk has been run. */

	do_getcwd(cwd, PATH_MAX);
	lua_getglobal(L, "_SCRIPT");
	lua_getglobal(L, "_SCRIPT_DIR");

	/* Set the new _SCRIPT variable... */

	filename = lua_tostring(L, lua_upvalueindex(2));
	do_getabsolute(script, filename, NULL);
	lua_pushstring(L, script);
	lua_setglobal(L, "_SCRIPT");

	/* ...and make it's containing directory current */

	ptr = strrchr(script, '/');
	if (ptr) *ptr = '\0';
	lua_pushstring(L, script);
	lua_setglobal(L, "_SCRIPT_DIR");
	do_chdir(script);
	if (ptr) *ptr = '/';

	/* Move the function's arguments to the top of the stack and
	 * execute the function created by luaL_loadfile() */

	lua_pushvalue(L, lua_upvalueindex(1));
	for (i = 1; i <= args; ++i) {
		lua_pushvalue(L, i);
	}

	lua_call(L, args, LUA_MULTRET);

	/* Finally, restore the previous _SCRIPT variable and working directory
	 * before returning control to the previously executing script. */

	do_chdir(cwd);
	lua_pushvalue(L, args + 1);
	lua_setglobal(L, "_SCRIPT");
	lua_pushvalue(L, args + 2);
	lua_setglobal(L, "_SCRIPT_DIR");

	return lua_gettop(L) - args - 2;
}
