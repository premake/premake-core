/**
 * \file   os_realpath.c
 * \brief  Return the canonical absolute version of a given path.
 * \author Copyright (c) 2014 Jess Perkins and the Premake project
 */

#include "premake.h"
#include <stdlib.h>
#include <string.h>
#include <errno.h>


int os_realpath(lua_State* L)
{
	char result[PATH_MAX];
	int ok;

	const char* path = luaL_checkstring(L, 1);

#if PLATFORM_POSIX
	ok = (realpath(path, result) != NULL);
#elif PLATFORM_WINDOWS
	ok = (_fullpath(result, path, PATH_MAX) != NULL);
#else
	do_getabsolute(result, path, NULL);
	ok = 1;
#endif

	if (!ok) {
		lua_pushnil(L);
		lua_pushfstring(L, "unable to fetch real path of '%s', errno %d : %s", path, errno, strerror(errno));
		return 2;
	}

	lua_pushstring(L, result);
	return 1;
}
