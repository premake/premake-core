/**
 * \file   os_hostarch.c
 * \brief  Get the architecture for the current host OS we're executing on.
 * \author Copyright (c) 2014-2024 Jason Perkins and the Premake project
 */

#include "premake.h"

int os_hostarch(lua_State* L)
{
	lua_pushstring(L, PLATFORM_ARCHITECTURE);
	return 1;
}
