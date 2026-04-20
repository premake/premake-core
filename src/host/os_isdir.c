/**
 * \file   os_isdir.c
 * \brief  Returns true if the specified directory exists.
 * \author Copyright (c) 2002-2008 Jess Perkins and the Premake project
 */

#include <string.h>
#include <sys/stat.h>
#include "premake.h"

#if PLATFORM_WINDOWS
#include <windows.h>
#endif

int os_isdir(lua_State* L)
{
	const char* path = luaL_checkstring(L, 1);

	/* empty path is equivalent to ".", must be true */
	if (*path == '\0')
	{
		lua_pushboolean(L, 1);
		return 1;
	}

#if PLATFORM_WINDOWS
	struct _stat buf;
	const wchar_t *wpath = luaL_checkconvertstring(L, 1);
	if (_wstat(wpath, &buf) == 0)
	{
		int isdir = (buf.st_mode & S_IFDIR) != 0;
		lua_pushboolean(L, isdir);
	}
#else
	struct stat buf;
	if (stat(path, &buf) == 0)
	{
		int isdir = (buf.st_mode & S_IFDIR) != 0;
		lua_pushboolean(L, isdir);
	}
#endif
	else
	{
		lua_pushboolean(L, 0);
	}

	return 1;
}


