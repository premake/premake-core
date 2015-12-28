/**
 * \file   os_isdir.c
 * \brief  Returns true if the specified directory exists.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <string.h>
#include <sys/stat.h>
#include "premake.h"

#ifdef _WIN32
#include <Windows.h>
#endif

int os_isdir(lua_State* L)
{
	struct stat buf;
	const char* path = luaL_checkstring(L, 1);
#ifdef _WIN32
	int attr;
#endif

	/* empty path is equivalent to ".", must be true */
	if (strlen(path) == 0)
	{
		lua_pushboolean(L, 1);
	}
#ifdef _WIN32
	// Use Windows-specific GetFileAttributes since it deals with symbolic links.
	else if ((attr = GetFileAttributesA(path)) != INVALID_FILE_ATTRIBUTES)
	{
		int isdir = (attr & FILE_ATTRIBUTE_DIRECTORY) != 0;
		lua_pushboolean(L, isdir);
	}
#endif
	else if (stat(path, &buf) == 0)
	{
		int isdir = (buf.st_mode & S_IFDIR) != 0;
		lua_pushboolean(L, isdir);
	}
	else
	{
		lua_pushboolean(L, 0);
	}

	return 1;
}


