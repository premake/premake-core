/**
 * \file   os_rmdir.c
 * \brief  Remove a subdirectory.
 * \author Copyright (c) 2002-2013 Jess Perkins and the Premake project
 */

#include <sys/stat.h>
#include <stdlib.h>
#include "premake.h"


int os_rmdir(lua_State* L)
{
	int z;

#if PLATFORM_WINDOWS
	const wchar_t *path = luaL_checkconvertstring(L, 1);
	z = RemoveDirectoryW(path);
	lua_pop(L, 1);
#else
	const char* path = luaL_checkstring(L, 1);
	struct stat buf;
	if (lstat(path, &buf) == 0 && S_ISLNK(buf.st_mode))
	{
		z = (0 == unlink(path));
	}
	else
	{
		z = (0 == rmdir(path));
	}
#endif

	if (!z)
	{
		lua_pushnil(L);
		lua_pushfstring(L, "unable to remove directory '%s'", path);
		return 2;
	}
	else
	{
		lua_pushboolean(L, 1);
		return 1;
	}
}
