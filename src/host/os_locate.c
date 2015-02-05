/**
 * \file   os_locate.c
 * \brief  Locates files along the standard built-in search paths.
 * \author Copyright (c) 2014-2015 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"


int os_locate(lua_State* L)
{
	int i;
	int nArgs = lua_gettop(L);

	/* Fetch premake.path */
	lua_getglobal(L, "premake");
	lua_getfield(L, -1, "path");

	for (i = 1; i <= nArgs; ++i) {
		/* Direct path to file? Return as absolute path */
		if (do_isfile(lua_tostring(L, i))) {
			lua_pushcfunction(L, path_getabsolute);
			lua_pushvalue(L, i);
			lua_call(L, 1, 1);
			return 1;
		}

		/* Call os.pathsearch(arg[i], premake.path) */
		lua_pushcfunction(L, os_pathsearch);
		lua_pushvalue(L, i);
		lua_pushvalue(L, -3);
		lua_call(L, 2, 1);

		/* os.pathsearch() returns the directory containing the file;
		 * append the filename to complete the path */
		if (!lua_isnil(L, -1)) {
			lua_pushstring(L, "/");
			lua_pushvalue(L, 1);
			lua_concat(L, 3);
			return 1;
		}

		lua_pop(L, 1);
	}

	return 0;
}
