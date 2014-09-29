/**
 * \file   os_locate.c
 * \brief  Locates files along the standard built-in search paths.
 * \author Copyright (c) 2014 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"


int os_locate(lua_State* L)
{
	int i, top, vars;
	const char* premake_path = getenv("PREMAKE_PATH");

	top = lua_gettop(L);

	/* see if the global environment variables have been set yet */
	lua_getglobal(L, "_USER_HOME_DIR");
	vars = !lua_isnil(L, -1);
	lua_pop(L, 1);

	for (i = 1; i <= top; ++i) {
		/* direct path to file? */
		if (do_isfile(lua_tostring(L, i))) {
			lua_pushvalue(L, i);
			return 1;
		}

		/* search for it */
		lua_pushcfunction(L, os_pathsearch);
		lua_pushvalue(L, i);

		if (vars) {
			lua_getglobal(L, "_MAIN_SCRIPT_DIR");
		}

		lua_pushstring(L, ".");

		if (vars) {
			lua_getglobal(L, "_USER_HOME_DIR");
			lua_pushstring(L, "/.premake");
			lua_concat(L, 2);
		}

		if (scripts_path) {
			lua_pushstring(L, scripts_path);
		}

		if (premake_path) {
			lua_pushstring(L, premake_path);
		}

		if (vars) {
			lua_getglobal(L, "_PREMAKE_DIR");
		}

		if (vars) {
			lua_getglobal(L, "_USER_HOME_DIR");
			lua_pushstring(L, "/Library/Application Support/Premake");
			lua_concat(L, 2);
		}

		lua_pushstring(L, "/usr/local/share/premake");
		lua_pushstring(L, "/usr/share/premake");

		lua_call(L, lua_gettop(L) - top - 1, 1);
		if (!lua_isnil(L, -1)) {
			lua_pushcfunction(L, path_join);
			lua_pushvalue(L, -2);
			lua_pushvalue(L, i);
			lua_call(L, 2, 1);
			return 1;
		}

		lua_pop(L, 1);
	}

	return 0;
}
