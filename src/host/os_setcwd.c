/**
 * \file   os_setcwd.c
 * \brief  Sets the current working directory.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"

int os_setcwd(lua_State* L)
{
	const char* path = luaL_checkstring(L, -1);
	lua_pushboolean(L, do_setcwd(path));

	return 1;
}


int do_setcwd(const char* path)
{
	int result;

#if PLATFORM_WINDOWS
	result = (SetCurrentDirectoryA(path) != 0);
#else
	result = (chdir(path) == 0);
#endif

	return result;
}
