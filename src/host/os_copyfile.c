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

	z = CopyFileW(wide_src, wide_dst, false);
#else
	lua_pushfstring(L, "cp \"%s\" \"%s\"", src, dst);
	z = (system(lua_tostring(L, -1)) == 0);
#endif

	if (!z)
	{
		lua_pushnil(L);
#if PLATFORM_WINDOWS
		wchar_t buf[256];
		FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM, NULL, GetLastError(),
			MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), buf, 256, NULL);

		char bufA[256];
		WideCharToMultiByte(CP_UTF8, 0, buf, 256, bufA, 256, 0, 0);

		lua_pushfstring(L, "unable to copy file to '%s', reason: '%s'", dst, bufA);
#else
		lua_pushfstring(L, "unable to copy file to '%s'", dst);
#endif
		return 2;
	}
	else
	{
		lua_pushboolean(L, 1);
		return 1;
	}
}
