/**
 * \file   os_copyfile.c
 * \brief  Copy a file from one location to another.
 * \author Copyright (c) 2002-2008 Jess Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"

int os_copyfile(lua_State* L)
{
	int z;


#if PLATFORM_WINDOWS
	// if we read the first argument first, it might push to the stack obscuring
	// a missing second argument. So read the second argument first.
	const wchar_t* dst = luaL_checkconvertstring(L, 2);
	const wchar_t* src = luaL_checkconvertstring(L, 1);
	z = CopyFileW(src, dst, FALSE);
#else
	const char* src = luaL_checkstring(L, 1);
	const char* dst = luaL_checkstring(L, 2);
	lua_pushfstring(L, "cp \"%s\" \"%s\"", src, dst);
	z = (system(lua_tostring(L, -1)) == 0);
#endif

	if (!z)
	{
		lua_pushnil(L);
#if PLATFORM_WINDOWS
		wchar_t buf[256];
		DWORD ec = GetLastError();
		const char *err = NULL;
		if (FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM, NULL, ec,
			MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), buf, 256, NULL) && (err = luaL_convertwstring(L, buf, NULL)) != NULL)
		{
			lua_pushfstring(L, "unable to copy file to '%s', reason: '%s' (%lu)", dst, err, ec);
			lua_remove(L, -2); /* converted string */
		}
		else
			lua_pushfstring(L, "unable to copy file to '%s', error code: %lu", dst, ec);
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
