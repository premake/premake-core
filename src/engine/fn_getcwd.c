/**
 * \file   fn_getcwd.c
 * \brief  os.getcwd() returns the current working directory.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "internals.h"
#include "base/dir.h"

int fn_getcwd(lua_State* L)
{
	const char* cwd = dir_get_current();
	lua_pushstring(L, cwd);
	return 1;
}
