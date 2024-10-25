/**
 * \file   premake_main.c
 * \brief  Program entry point.
 * \author Copyright (c) 2002-2013 Jess Perkins and the Premake project
 */

#include "premake.h"

int main(int argc, const char** argv)
{
	lua_State* L;
	int z;

	L = luaL_newstate();
	luaL_openlibs(L);

	z = premake_init(L);
	if (z == OKAY) {
		z = premake_execute(L, argc, argv, "src/_premake_main.lua");
	}

	lua_close(L);
	return z;
}
