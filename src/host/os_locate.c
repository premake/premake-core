/**
 * \file   os_locate.c
 * \brief  Locates a file, given a set of search paths.
 * \author Copyright (c) 2014 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"


int os_locate(lua_State* L)
{
	int i, top;
	const char* premake_path = getenv("PREMAKE_PATH");

	top = lua_gettop(L);
	for (i = 1; i <= top; ++i) {
		/* direct path to file? */
		if (do_isfile(lua_tostring(L, i))) {
			lua_pushvalue(L, i);
			return 1;
		}

		/* search for it */
		lua_pushcfunction(L, os_pathsearch);
		lua_pushvalue(L, i);
		lua_getglobal(L, "_MAIN_SCRIPT_DIR");
		lua_pushstring(L, scripts_path);
		lua_pushstring(L, premake_path);
		lua_call(L, 4, 1);

		if (!lua_isnil(L, -1)) {
			lua_pushcfunction(L, path_join);
			lua_pushvalue(L, -2);
			lua_pushvalue(L, i);
			lua_call(L, 2, 1);
			return 1;
		}
	}

	return 0;
}
