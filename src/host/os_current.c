/**
 * \file   os_current.c
 * \brief  Get the current OS we're executing on.
 * \author Copyright (c) 2014-2017 Tom van Dijck, Jason Perkins and the Premake project
 */

#include "premake.h"

int os_current(lua_State* L)
{
	lua_pushstring(L, PLATFORM_STRING);
	return 1;
}
