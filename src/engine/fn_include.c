/**
 * \file   fn_include.c
 * \brief  Include an directory in the script, running the contained "premake4.lua".
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "internals.h"
#include "base/path.h"


/**
 * Include a directory into the current script, calling the enclosed "premake4.lua".
 * This is a shortcut for `dofile("some_directory/premake4.lua")`.
 */
int fn_include(lua_State* L)
{
	/* append default file name to the passed in path */
	const char* directory = luaL_checkstring(L, 1);
	const char* path = path_join(directory, DEFAULT_SCRIPT_NAME);

	/* then pass it to dofile() */
	lua_pop(L, 1);
	lua_pushstring(L, path);
	return fn_dofile(L);
}
