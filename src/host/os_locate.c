/**
 * \file   os_locate.c
 * \brief  Locates files along the standard built-in search paths.
 * \author Copyright (c) 2014-2015 Jess Perkins and the Premake project
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
	const char* path;
	int i;
	int nArgs = lua_gettop(L);

	/* Fetch premake.path */
	lua_getglobal(L, "premake");
	lua_getfield(L, -1, "path");
	path = lua_tostring(L, -1);

	for (i = 1; i <= nArgs; ++i) {
		const char* name = lua_tostring(L, i);

		/* Direct path to an embedded file? */
		if (name[0] == '$' && name[1] == '/' && premake_find_embedded_script(name + 2)) {
			lua_pushvalue(L, i);
			return 1;
		}

		/* Direct path to file? Return as absolute path */
		if (do_isfile(L, name)) {
			lua_pushcfunction(L, path_getabsolute);
			lua_pushvalue(L, i);
			lua_call(L, 1, 1);
			return 1;
		}

		/* do_locate(arg[i], premake.path) */
		if (do_locate(L, name, path)) {
			return 1;
		}

		/* embedded in the executable? */
		if (premake_find_embedded_script(name)) {
			lua_pushstring(L, "$/");
			lua_pushvalue(L, i);
			lua_concat(L, 2);
			return 1;
		}
	}

	return 0;
}
