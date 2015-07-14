/**
 * \file   os_mkdir.c
 * \brief  Create a subdirectory.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <sys/stat.h>
#include <string.h>
#include <stdio.h>

#include "premake.h"

#if PLATFORM_WINDOWS
#include <direct.h>
#include <errno.h>
#endif

int do_mkdir(const char* path)
{
	struct stat sb;
	char sub_path[1024];
	int i, length;

	// if it already exists, return.
	if (stat(path, &sb) == 0)
		return 1;

	// find the parent folder name.
	length = strlen(path);
	for (i = length - 1; i >= 0; --i)
	{
		if (path[i] == '/' || path[i] == '\\')
			break;
	}

	// if we found one, create it.
	if (i > 0)
	{
		memcpy(sub_path, path, i);
		sub_path[i] = '\0';

#if PLATFORM_WINDOWS
		if (sub_path[i - 1] == ':')
		{
			sub_path[i + 0] = '/';
			sub_path[i + 1] = '\0';
		}
#endif

		if (!do_mkdir(sub_path))
			return 0;
	}

	// now finally create the actual folder we want.
#if PLATFORM_WINDOWS
	return _mkdir(path) == 0;
#else
	return  mkdir(path, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH) == 0;
#endif
}


int os_mkdir(lua_State* L)
{
	const char* path = luaL_checkstring(L, 1);

	int z = do_mkdir(path);
	if (!z)
	{
		lua_pushnil(L);
		lua_pushfstring(L, "unable to create directory '%s'", path);
		return 2;
	}

	lua_pushboolean(L, 1);
	return 1;
}

