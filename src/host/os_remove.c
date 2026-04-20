/**
 * \file   os_remove.c
 * \brief  Remove a file on Windows.
 * \author Copyright (c) 2002-2013 Jess Perkins and the Premake project
 */

#include "premake.h"

#if PLATFORM_WINDOWS

int os_remove(lua_State* L)
{
	const wchar_t* filename = luaL_checkconvertstring(L, 1);
	if (DeleteFileW(filename))
	{
		lua_pushboolean(L, 1);
		return 1;
	}
	else
	{
		DWORD err = GetLastError();

		LPWSTR messageBuffer = NULL;
		int pushed = 0;
		lua_pushnil(L);
		if (FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, NULL, err, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPWSTR) &messageBuffer, 0, NULL) != 0)
		{
			pushed = !!luaL_convertwstring(L, messageBuffer, NULL);
			LocalFree(messageBuffer);
		}

		lua_pushfstring(L, "%s: %s (%lu)", filename, pushed ? lua_tostring(L, -1) : "<failed to get error message>", err);
		if (pushed) lua_remove(L, -2);
		lua_pushinteger(L, err);
		return 3;
	}
}

#endif
