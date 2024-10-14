/**
* \file   os_rename.c
* \brief  Rename a path on Windows.
* \author Copyright (c) 2002-2013 Jess Perkins and the Premake project
*/

#include "premake.h"

#if PLATFORM_WINDOWS

int os_rename(lua_State* L)
{
	const char *fromname = luaL_checkstring(L, 1);
	const char *toname = luaL_checkstring(L, 2);

	wchar_t wide_frompath[PATH_MAX];
	if (MultiByteToWideChar(CP_UTF8, 0, fromname, -1, wide_frompath, PATH_MAX) == 0)
	{
		lua_pushstring(L, "unable to encode source path");
		return lua_error(L);
	}

	wchar_t wide_topath[PATH_MAX];
	if (MultiByteToWideChar(CP_UTF8, 0, toname, -1, wide_topath, PATH_MAX) == 0)
	{
		lua_pushstring(L, "unable to encode dest path");
		return lua_error(L);
	}

	if (MoveFileExW(wide_frompath, wide_topath, MOVEFILE_COPY_ALLOWED))
	{
		lua_pushboolean(L, 1);
		return 1;
	}
	else
	{
		DWORD err = GetLastError();

		char unicodeErr[512];

		LPWSTR messageBuffer = NULL;
		if (FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, NULL, err, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPWSTR) &messageBuffer, 0, NULL) != 0)
		{
			if (WideCharToMultiByte(CP_UTF8, 0, messageBuffer, -1, unicodeErr, sizeof(unicodeErr), NULL, NULL) == 0)
				strcpy(unicodeErr, "failed to translate error message");

			LocalFree(messageBuffer);
		}
		else
			strcpy(unicodeErr, "failed to get error message");

		lua_pushnil(L);
		lua_pushfstring(L, "%s: %s", fromname, unicodeErr);
		lua_pushinteger(L, err);
		return 3;
	}
}

#endif
