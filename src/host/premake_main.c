/**
 * \file   premake_main.c
 * \brief  Program entry point.
 * \author Copyright (c) 2002-2013 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <time.h>

int main(int argc, const char** argv)
{
	double duration;
	clock_t start_t, end_t;
	lua_State* L;
	int z;

	start_t = clock();

	L = luaL_newstate();
	luaL_openlibs(L);

	z = premake_init(L);
	if (z == OKAY) {
		z = premake_execute(L, argc, argv, "src/_premake_main.lua");
	}

	lua_close(L);

	end_t = clock();
	duration = (double)(end_t - start_t) / CLOCKS_PER_SEC;
	printf("%dms.\n", (int)(duration * 1000.0));
	return z;
}
