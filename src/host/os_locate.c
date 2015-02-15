/**
 * \file   os_locate.c
 * \brief  Locates files along the standard built-in search paths.
 * \author Copyright (c) 2014-2015 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"


int do_locate(lua_State* L, const char* filename, const char* path)
{
	if (do_pathsearch(L, filename, path)) {
		lua_pushstring(L, "/");
		lua_pushstring(L, filename);
		lua_concat(L, 3);
		return 1;
	}

	return 0;
}



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

		/* do_locate(arg[i], premake.path) */
		if (do_locate(L, lua_tostring(L, i), lua_tostring(L, -1))) {
			return 1;
		}
	}

	return 0;
}
