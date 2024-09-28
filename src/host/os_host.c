/**
 * \file   os_host.c
 * \brief  Get the current host OS we're executing on.
 * \author Copyright (c) 2014-2017 Tom van Dijck, Jason Perkins and the Premake project
 */

#include "premake.h"

int os_host(lua_State* L)
{
	lua_pushstring(L, PLATFORM_OS);
	return 1;
}
