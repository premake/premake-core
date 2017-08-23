/**
 * \file   os_copyfile.c
 * \brief  Copy a file from one location to another.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"

int os_copyfile(lua_State* L)
{
	int z;
	const char* src = luaL_checkstring(L, 1);
	const char* dst = luaL_checkstring(L, 2);

#if PLATFORM_WINDOWS
	wchar_t wide_src[PATH_MAX];
	wchar_t wide_dst[PATH_MAX];

	if (MultiByteToWideChar(CP_UTF8, 0, src, -1, wide_src, PATH_MAX) == 0)
	{
		lua_pushstring(L, "unable to encode source path");
		return lua_error(L);
	}

	if (MultiByteToWideChar(CP_UTF8, 0, dst, -1, wide_dst, PATH_MAX) == 0)
	{
		lua_pushstring(L, "unable to encode source path");
		return lua_error(L);
	}

	z = CopyFileW(wide_src, wide_dst, FALSE);
#else
	lua_pushfstring(L, "cp \"%s\" \"%s\"", src, dst);
	z = (system(lua_tostring(L, -1)) == 0);
#endif

	if (!z)
	{
		lua_pushnil(L);
		lua_pushfstring(L, "unable to copy file to '%s'", dst);
		return 2;
	}
	else
	{
		lua_pushboolean(L, 1);
		return 1;
	}
}
