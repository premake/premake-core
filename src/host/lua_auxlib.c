/**
 * \file   lua_auxlib.c
 * \brief  Modifications and extensions to Lua's library functions.
 * \author Copyright (c) 2014 Jason Perkins and the Premake project
 */

#include "premake.h"


#define luaL_loadfile  original_luaL_loadfile

#include "lua-5.1.4/src/lauxlib.c"

#undef luaL_loadfile


/**
 * Execute a chunk of code previous loaded by my customized version of
 * luaL_loadfile(), below. Sets the _SCRIPT global variable to the
 * absolute path of the loaded chunk, and makes its enclosing directory
 * current so that relative path references to other files or scripts
 * can be used.
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
	 * restore them after the script chunk has been run. */

	do_getcwd(cwd, PATH_MAX);
	lua_getglobal(L, "_SCRIPT");

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

	return lua_gettop(L) - args - 1;
}



/**
 * Extend the default implementation of luaL_loadfile() to call my chunk
 * wrapper, above, before executing any scripts loaded from a file.
 */

LUALIB_API int luaL_loadfile (lua_State* L, const char* filename)
{
	int z = original_luaL_loadfile(L, filename);
	if (z == 0) {
		lua_pushstring(L, filename);
		lua_pushcclosure(L, chunk_wrapper, 2);
	}

	return z;
}
