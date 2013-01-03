/**
 * \file   path_isabsolute.c
 * \brief  Determines if a path is absolute or relative.
 * \author Copyright (c) 2002-2013 Jason Perkins and the Premake project
 */

#include "premake.h"


int path_isabsolute(lua_State* L)
{
	const char* path = luaL_checkstring(L, -1);
	lua_pushboolean(L, do_isabsolute(path));
	return 1;
}


int do_isabsolute(const char* path)
{
	return (
		path[0] == '/' ||
	    path[0] == '\\' ||
	    path[0] == '$' ||
	    (path[0] == '"' && path[1] == '$') ||
	    (path[0] != '\0' && path[1] == ':')
	);
}
