/**
 * \file   os_pathsearch.c
 * \brief  Locates a file, given a set of search paths.
 * \author Copyright (c) 2002-2015 Jason Perkins and the Premake project
 *
 * \note This function is required by the bootstrapping code; it must be
 *       implemented here in the host and not scripted.
 */

#include <string.h>
#include "premake.h"


int do_pathsearch(lua_State* L, const char* filename, const char* path)
{
	do
	{
		const char* split;

		/* look for the closest path separator ; or : */
		/* can't use : on windows because it breaks on C:\path */
		const char* semi = strchr(path, ';');
#if !defined(PLATFORM_WINDOWS)
		const char* full = strchr(path, ':');
#else
		const char* full = NULL;
#endif

		if (!semi)
		{
			split = full;
		}
		else if (!full)
		{
			split = semi;
		}
		else
		{
			split = (semi < full) ? semi : full;
		}

		/* push this piece of the full search string onto the stack */
		if (split)
		{
			lua_pushlstring(L, path, split - path);
		}
		else
		{
			lua_pushstring(L, path);
		}

		/* keep an extra copy around, so I can return it if I have a match */
		lua_pushvalue(L, -1);

		/* append the filename to make the full test path */
		lua_pushstring(L, "/");
		lua_pushstring(L, filename);
		lua_concat(L, 3);

		/* test it - if it exists, return the absolute path */
		if (do_isfile(lua_tostring(L, -1)))
		{
			lua_pop(L, 1);
			lua_pushcfunction(L, path_getabsolute);
			lua_pushvalue(L, -2);
			lua_call(L, 1, 1);
			return 1;
		}

		/* no match, set up the next try */
		lua_pop(L, 2);
		path = (split) ? split + 1 : NULL;
	}
	while (path);

	return 0;
}



int os_pathsearch(lua_State* L)
{
	int i;

	const char* filename = luaL_checkstring(L, 1);
	for (i = 2; i <= lua_gettop(L); ++i)
	{
		if (lua_isnil(L, i)) continue;
		if (do_pathsearch(L, filename, luaL_checkstring(L, i))) return 1;
	}

	return 0;
}
