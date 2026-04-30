/**
 * \file   os_stat.c
 * \brief  Retrieve information about a file.
 * \author Copyright (c) 2011 Jess Perkins and the Premake project
 */

#include "premake.h"
#include <sys/stat.h>
#include <errno.h>
#include <string.h>

int os_stat(lua_State* L)
{

#if PLATFORM_WINDOWS
	const wchar_t *wfilename = luaL_checkconvertstring(L, 1);
	const char *filename = lua_tostring(L, 1); /* save original path before popping converted string */
	struct _stat s;

	int failed = (_wstat(wfilename, &s) != 0);
	lua_pop(L, 1);
#else
	const char* filename = luaL_checkstring(L, 1);
	struct stat s;

	int failed = (stat(filename, &s) != 0);
#endif

	if (failed)
	{
		lua_pushnil(L);
		switch (errno)
		{
		case EACCES:
			lua_pushfstring(L, "'%s' could not be accessed", filename);
			break;
		case ENOENT:
			lua_pushfstring(L, "'%s' was not found", filename);
			break;
		default:
			lua_pushfstring(L, "An unknown error %d (%s) occurred while accessing '%s'", errno, strerror(errno), filename);
			break;
		}
		return 2;
	}


	lua_newtable(L);

	lua_pushstring(L, "mtime");
	lua_pushinteger(L, (lua_Integer)s.st_mtime);
	lua_settable(L, -3);

	lua_pushstring(L, "size");
	lua_pushnumber(L, (lua_Number)s.st_size);
	lua_settable(L, -3);

	return 1;
}
