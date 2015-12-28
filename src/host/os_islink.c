/**
 * \file   os_islink.c
 * \brief  Returns true if the given path is a symbolic link or reparse point.
 * \author Copyright (c) 2014 Jason Perkins and the Premake project
 */

#include <sys/stat.h>
#include "premake.h"


int os_islink(lua_State* L)
{
	const char* path = luaL_checkstring(L, 1);

#if PLATFORM_WINDOWS
	{
		DWORD attr = GetFileAttributesA(path);
		if (attr != INVALID_FILE_ATTRIBUTES) {
			lua_pushboolean(L, (attr & FILE_ATTRIBUTE_REPARSE_POINT) != 0);
			return 1;
		}
	}
#else
	{
		struct stat buf;
	    if (lstat(path, &buf) == 0) {
	    	lua_pushboolean(L, S_ISLNK(buf.st_mode));
	    	return 1;
	    }
	}
#endif

	lua_pushboolean(L, 0);
	return 1;
}
