/**
 * \file   premake_main.c
 * \brief  Program entry point.
 * \author Copyright (c) 2002-2013 Jason Perkins and the Premake project
 */

#include "premake.h"

int main(int argc, const char** argv)
{
	lua_State* L;
	int z;

	L = lua_open();
	luaL_openlibs(L);

	z = premake_init(L);
	if (z == OKAY) {
		z = premake_execute(L, argc, argv);
	}

	lua_close(L);
	return z;
}
