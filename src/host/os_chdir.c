/**
 * \file   os_chdir.c
 * \brief  Change the current working directory.
 * \author Copyright (c) 2002-2014 Jason Perkins and the Premake project
 */

#include "premake.h"


int do_chdir(lua_State* L, const char* path)
{
	int z;

	(void)(L);  /* warning: unused parameter */

#if PLATFORM_WINDOWS
	z = SetCurrentDirectoryA(path);
#else
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
