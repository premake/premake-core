/**
 * \file   string_hash.c
 * \brief  Computes a hash value for a string.
 * \author Copyright (c) 2012-2014 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <string.h>


int string_hash(lua_State* L)
{
	const char* str = luaL_checkstring(L, 1);
	int seed = (int)luaL_optinteger(L, 2, 0);
	lua_pushinteger(L, do_hash(str, seed));
	return 1;
}


uint32_t do_hash(const char* str, int seed)
{
	/* DJB2 hashing; see http://www.cse.yorku.ca/~oz/hash.html */

	uint32_t hash = 5381;

	if (seed != 0) {
		hash = hash * 33 + seed;
	}

	while (*str) {
		hash = hash * 33 + (*str);
		str++;
	}

	return hash;
}
