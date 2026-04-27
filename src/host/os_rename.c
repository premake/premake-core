/**
* \file   os_rename.c
* \brief  Rename a path on Windows.
* \author Copyright (c) 2002-2013 Jess Perkins and the Premake project
*/

#include "premake.h"

#if PLATFORM_WINDOWS

int os_rename(lua_State* L)
{
	const wchar_t *toname = luaL_checkconvertstring(L, 2);
	const wchar_t *fromname = luaL_checkconvertstring(L, 1);

	BOOL b = MoveFileExW(fromname, toname, MOVEFILE_COPY_ALLOWED);
	if (b)
	{
		lua_pop(L, 2);
		lua_pushboolean(L, 1);
		return 1;
	}
	else
	{
		DWORD err = GetLastError();
		const char *fromname_utf8 = lua_tostring(L, 1); /* get original UTF-8 before popping converted strings */
		lua_pop(L, 2);

		LPWSTR messageBuffer = NULL;
		int pushed = 0;
		lua_pushnil(L);
		if (FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, NULL, err, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPWSTR) &messageBuffer, 0, NULL) != 0)
		{
			pushed = !!luaL_convertwstring(L, messageBuffer, NULL);
			LocalFree(messageBuffer);
		}

		lua_pushfstring(L, "%s: %s (%I)", fromname_utf8, pushed ? lua_tostring(L, -1) : "<failed to get error message>", (lua_Integer)err);
		if (pushed) lua_remove(L, -2); /* remove converted string */
		lua_pushinteger(L, err);
		return 3;
	}
}

#endif
