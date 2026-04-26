/**
 * \file   os_mkdir.c
 * \brief  Create a subdirectory.
 * \author Copyright (c) 2002-2008 Jess Perkins and the Premake project
 */

#include <sys/stat.h>
#include <string.h>
#include <stdio.h>

#include "premake.h"

#if PLATFORM_WINDOWS
#include <direct.h>
#include <errno.h>
#if _MSC_VER
#define alloca _alloca
#endif
#endif
#if defined(__has_include)
#if __has_include(<alloca.h>)
#include <alloca.h>
#endif
#endif

int do_mkdir(lua_State *L, const char* path)
{
	int i, length, s;
#if PLATFORM_WINDOWS
	struct _stat sb;
	const wchar_t *wpath = luaL_convertstring(L, path);
	if (!wpath) return 0;  /* unable to encode path */
	s = _wstat(wpath, &sb);
	lua_pop(L, 1);
#else
	struct stat sb;
	s = stat(path, &sb);
#endif

	// if it already exists, return.
	if (s == 0)
		return 1;

	// find the parent folder name.
	length = (int)strlen(path);
	for (i = length - 1; i >= 0; --i)
	{
		if (path[i] == '/' || path[i] == '\\')
			break;
	}

	// if we found one, recursively create it.
	if (i > 0)
	{
		char* sub_path = alloca(i + 2); /* null terminator plus trailing slash on Windows */

		memcpy(sub_path, path, i);
		sub_path[i] = '\0';

#if PLATFORM_WINDOWS
		if (sub_path[i - 1] == ':')
		{
			sub_path[i + 0] = '/';
			sub_path[i + 1] = '\0';
		}
#endif

		if (!do_mkdir(L, sub_path))
			return 0;
	}

	// now finally create the actual folder we want.
#if PLATFORM_WINDOWS
	if ((wpath = luaL_convertstring(L, path)) == NULL) return 0;
	int res = (_wmkdir(wpath) == 0);
	lua_pop(L, 1);
	return res;
#else
	return  mkdir(path, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH) == 0;
#endif
}


int os_mkdir(lua_State* L)
{
	const char* path = luaL_checkstring(L, 1);

	int z = do_mkdir(L, path);
	if (!z)
	{
		lua_pushnil(L);
		lua_pushfstring(L, "unable to create directory '%s'", path);
		return 2;
	}

	lua_pushboolean(L, 1);
	return 1;
}

