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
	const wchar_t *wpath = luaL_checkconvertstring(L, 1);
	DWORD attributes = GetFileAttributesW(wpath);
	lua_pushboolean(L, attributes != INVALID_FILE_ATTRIBUTES && (attributes & FILE_ATTRIBUTE_DIRECTORY) != 0);
#else
	struct stat buf;
	lua_pushboolean(L, stat(path, &buf) == 0 && S_ISDIR(buf.st_mode));
#endif

	return 1;
}


