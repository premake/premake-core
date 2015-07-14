/**
 * \file   os_mkdir.c
 * \brief  Create a subdirectory.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <sys/stat.h>
#include "premake.h"


int do_mkdir(const char* path)
{
	char sub_path[2048];
	int i, z;

	size_t path_length = strlen(path);
	for (i = 0; i < path_length; ++i)
	{
		if (path[i] == '/' || path[i] == '\\')
		{
			memcpy(sub_path, path, i);
			sub_path[i] = '\0';

#if PLATFORM_WINDOWS
			z = CreateDirectory(sub_path, NULL);
#else
			z =  (mkdir(sub_path, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH) == 0);
#endif

			if (!z)
			{
				return FALSE;
			}
		}
	}

	return TRUE;
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

