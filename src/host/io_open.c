/**
 * \file   os_rmdir.c
 * \brief  Remove a subdirectory.
 * \author Copyright (c) 2002-2013 Jason Perkins and the Premake project
 */

#include "premake.h"

#if PLATFORM_WINDOWS

/* from Lua source code */
static FILE** newfile(lua_State *L)
{
	FILE **pf = (FILE **) lua_newuserdata(L, sizeof(FILE *));
	*pf = NULL;  /* file handle is currently `closed' */
	luaL_getmetatable(L, LUA_FILEHANDLE);
	lua_setmetatable(L, -2);
	return pf;
}

static int pushresult(lua_State *L, int i, const char *filename) {
	int en = errno;  /* calls to Lua API may change this value */
	if (i) {
		lua_pushboolean(L, 1);
		return 1;
	}
	else {
		lua_pushnil(L);
		if (filename)
			lua_pushfstring(L, "%s: %s", filename, strerror(en));
		else
			lua_pushfstring(L, "%s", strerror(en));
		lua_pushinteger(L, en);
		return 3;
	}
}


int io_open(lua_State *L)
{
	const char* filename = luaL_checkstring(L, 1);
	const char* mode = luaL_optstring(L, 2, "r");

	wchar_t wide_path[PATH_MAX];
	if (MultiByteToWideChar(CP_UTF8, 0, filename, -1, wide_path, PATH_MAX) == 0)
	{
		lua_pushstring(L, "unable to encode path");
		return lua_error(L);
	}

	wchar_t wide_mode[64];
	if (MultiByteToWideChar(CP_UTF8, 0, mode, -1, wide_mode, 64) == 0)
	{
		lua_pushstring(L, "unable to encode open mode");
		return lua_error(L);
	}

	FILE **pf = newfile(L);
	*pf = _wfopen(wide_path, wide_mode);
	return (*pf == NULL) ? pushresult(L, 0, filename) : 1;
}

#endif
