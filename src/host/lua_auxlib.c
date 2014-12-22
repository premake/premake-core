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

	/* Try to locate the script on the filesystem */
	lua_pushcfunction(L, os_locate);
	lua_pushstring(L, filename);
	lua_call(L, 1, 1);

	/* If I found it, load it from the file system... */
	if (!lua_isnil(L, -1)) {
		z = original_luaL_loadfile(L, lua_tostring(L, -1));
	}

	/* ...otherwise try to load from embedded scripts */
	else {
		lua_pop(L, 1);
		z = premake_load_embedded_script(L, filename);

		/* Special case relative loading of embedded scripts */
		if (z != OKAY) {
			const char* script_dir;
			lua_getglobal(L, "_SCRIPT_DIR");
			script_dir = lua_tostring(L, -1);
			if (script_dir && script_dir[0] == '$') {
				/* call path.getabsolute() to handle ".." if present */
				lua_pushcfunction(L, path_getabsolute);
				lua_pushstring(L, filename);
				lua_pushvalue(L, -3);
				lua_call(L, 2, 1);

				filename = lua_tostring(L, -1);
				z = premake_load_embedded_script(L, filename + 2);

				lua_remove(L, -3);
				lua_remove(L, -3);
			}
			else {
				lua_pop(L, 1);
			}
		}

	}

	/* Either way I should have ended up with the file name followed by the
	 * script chunk on the stack. Turn these into a closure that will call my
	 * wrapper below when the loaded script needs to be executed. */
	if (z == OKAY) {
		lua_pushcclosure(L, chunk_wrapper, 2);
	}
	else if (z == LUA_YIELD) {
		lua_pushstring(L, "cannot open ");
		lua_pushstring(L, filename);
		lua_pushstring(L, ": No such file or directory");
		lua_concat(L, 3);
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
	const char* filename;
	char* ptr;
	int i, args;

	args = lua_gettop(L);

	/* Remember the current _SCRIPT and working directory so I can
	 * restore them after this new chunk has been run. */

	do_getcwd(cwd, PATH_MAX);
	lua_getglobal(L, "_SCRIPT");
	lua_getglobal(L, "_SCRIPT_DIR");

	/* Set the new _SCRIPT variable */

	lua_pushvalue(L, lua_upvalueindex(1));
	lua_setglobal(L, "_SCRIPT");

	/* And the new _SCRIPT_DIR variable (const cheating) */

	filename = lua_tostring(L, lua_upvalueindex(1));
	ptr = strrchr(filename, '/');
	if (ptr) *ptr = '\0';
	lua_pushstring(L, filename);
	lua_setglobal(L, "_SCRIPT_DIR");

	/* And make that the CWD (and fix the const cheat) */

	if (filename[0] != '$') {
		do_chdir(L, filename);
	}
	if (ptr) *ptr = '/';

	/* Move the function's arguments to the top of the stack and
	 * execute the function created by luaL_loadfile() */

	lua_pushvalue(L, lua_upvalueindex(2));
	for (i = 1; i <= args; ++i) {
		lua_pushvalue(L, i);
	}

	lua_call(L, args, LUA_MULTRET);

	/* Finally, restore the previous _SCRIPT variable and working directory
	 * before returning control to the previously executing script. */

	do_chdir(L, cwd);
	lua_pushvalue(L, args + 1);
	lua_setglobal(L, "_SCRIPT");
	lua_pushvalue(L, args + 2);
	lua_setglobal(L, "_SCRIPT_DIR");

	return lua_gettop(L) - args - 2;
}
