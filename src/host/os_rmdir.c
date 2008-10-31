/**
 * \file   os_rmdir.c
 * \brief  Remove a subdirectory.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"


int os_rmdir(lua_State* L)
{
	int z;
	const char* path = luaL_checkstring(L, 1);

#if PLATFORM_WINDOWS
	z = RemoveDirectory(path);
#else
	lua_pushfstring(L, "rm -rf %s", path);
	z = (system(lua_tostring(L, -1)) == 0);
	lua_pop(L, 1);
#endif

	if (!z)
	{
		lua_pushnil(L);
		lua_pushfstring(L, "unable to remove directory '%s'", path);
		return 2;
	}
	else
	{
		lua_pushboolean(L, 1);
		return 1;
	}
}
