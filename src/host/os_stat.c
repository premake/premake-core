/**
 * \file   os_stat.c
 * \brief  Retrieve information about a file.
 * \author Copyright (c) 2011 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <sys/stat.h>
#include <errno.h>

int os_stat(lua_State* L)
{
	const char* filename = luaL_checkstring(L, 1);

#if PLATFORM_WINDOWS
	struct _stat s;

	wchar_t wide_filename[PATH_MAX];
	if (MultiByteToWideChar(CP_UTF8, 0, filename, -1, wide_filename, PATH_MAX) == 0)
	{
		lua_pushstring(L, "unable to encode source path");
		return lua_error(L);
	}

	if (_wstat(wide_filename, &s) != 0)
#else
	struct stat s;

	if (stat(filename, &s) != 0)
#endif
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
			lua_pushfstring(L, "An  unknown error %d occured while accessing '%s'", errno, filename);
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
