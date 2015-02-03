/**
 * \file   os_locate.c
 * \brief  Locates files along the standard built-in search paths.
 * \author Copyright (c) 2014 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"


int os_locate(lua_State* L)
{
	int i, nArgs, vars;
	const char* premake_path = getenv("PREMAKE_PATH");

	nArgs = lua_gettop(L);

	/* see if the global environment variables have been set yet */
	lua_getglobal(L, "_USER_HOME_DIR");
	vars = !lua_isnil(L, -1);
	lua_pop(L, 1);

	for (i = 1; i <= nArgs; ++i) {
		/* Direct path to file? Return fully qualified version */
		if (do_isfile(lua_tostring(L, i))) {
			lua_pushcfunction(L, path_getabsolute);
			lua_pushvalue(L, i);
			lua_call(L, 1, 1);
			return 1;
		}

		/* Search for it... */
		lua_pushcfunction(L, os_pathsearch);
		lua_pushvalue(L, i);

		/* ...relative to the main project script */
		if (vars) {
			lua_getglobal(L, "_MAIN_SCRIPT_DIR");
		}

		/* ...relative to the CWD */
		lua_pushstring(L, ".");

		/* ...on the paths specified by --scripts, if set */
		if (scripts_path) {
			lua_pushstring(L, scripts_path);
		}

		/* ... relative to ~/.premake */
		if (vars) {
			lua_getglobal(L, "_USER_HOME_DIR");
			lua_pushstring(L, "/.premake");
			lua_concat(L, 2);
		}

		/* ...on the PREMAKE_PATH environment variable, if set */
		if (premake_path) {
			lua_pushstring(L, premake_path);
		}

		/* ...relative to the Premake executable */
		if (vars) {
			lua_getglobal(L, "_PREMAKE_DIR");
		}

		/* ...in ~/Library/Application Support/Premake (for OS X) */
		if (vars) {
			lua_getglobal(L, "_USER_HOME_DIR");
			lua_pushstring(L, "/Library/Application Support/Premake");
			lua_concat(L, 2);
		}

		/* ...in the expected Unix-y places */
		lua_pushstring(L, "/usr/local/share/premake");
		lua_pushstring(L, "/usr/share/premake");

		lua_call(L, lua_gettop(L) - nArgs - 1, 1);
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
