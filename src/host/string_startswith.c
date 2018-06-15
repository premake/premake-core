/**
 * \file   string_startswith.c
 * \brief  Determines if a string starts with the given sequence.
 * \author Copyright (c) 2013 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <string.h>


int string_startswith(lua_State* L)
{
	const char* haystack = luaL_optstring(L, 1, NULL);
	const char* needle   = luaL_optstring(L, 2, NULL);

	if (haystack && needle)
	{
		size_t nlen = strlen(needle);
		lua_pushboolean(L, strncmp(haystack, needle, nlen) == 0);
		return 1;
	}

	return 0;
}
