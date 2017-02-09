/**
 * \file   os_chmod.c
 * \brief  Change file permissions
 * \author Copyright (c) 2014 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <sys/stat.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#if PLATFORM_WINDOWS
#include <io.h>
#endif

int os_chmod(lua_State* L)
{
	int rv;
	char* endPtr;

	const char* path = luaL_checkstring(L, 1);
	const char* modeStr = luaL_checkstring(L, 2);

	int mode = (int)strtol(modeStr, &endPtr, 8);

#if PLATFORM_WINDOWS
	/* DOS-mode permissions only support the low word */
	mode = mode & 0x0000ffff;
	rv = _chmod(path, mode);
#else
	rv = chmod(path, mode);
#endif

	if (rv != 0)
	{
		lua_pushnil(L);
		lua_pushfstring(L, "unable to set mode %o on '%s', errno %d : %s", mode, path, errno, strerror(errno));
		return 2;
	}
	else
	{
		lua_pushboolean(L, 1);
		return 1;
	}
}
