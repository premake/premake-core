/**
 * \file   os_chdir.c
 * \brief  Change the current working directory.
 * \author Copyright (c) 2002-2014 Jess Perkins and the Premake project
 */

#include "premake.h"


int do_chdir(lua_State* L, const char* path)
{
	int z;

#if PLATFORM_WINDOWS
	wchar_t wide_buffer[PATH_MAX];
	if (MultiByteToWideChar(CP_UTF8, 0, path, -1, wide_buffer, PATH_MAX) == 0)
	{
		lua_pushstring(L, "unable to encode path");
		return lua_error(L);
	}

	z = SetCurrentDirectoryW(wide_buffer);
#else
	(void)(L);  /* warning: unused parameter */

	z = !chdir(path);
#endif

	return z;
}



int os_chdir(lua_State* L)
{
	const char* path = luaL_checkstring(L, 1);

	int z = do_chdir(L, path);
	if (!z)
	{
		lua_pushnil(L);
		lua_pushfstring(L, "unable to switch to directory '%s'", path);
		return 2;
	}
	else
	{
		lua_pushboolean(L, 1);
		return 1;
	}
}
