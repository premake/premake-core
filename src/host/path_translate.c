/**
 * \file   path_translate.c
 * \brief  Translates between path separators.
 * \author Copyright (c) 2002-2013 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <string.h>


void do_translate(char* value, const char sep)
{
	char* ch;
	for (ch = value; *ch != '\0'; ++ch) {
		if (*ch == '/' || *ch == '\\') {
			*ch = sep;
		}
	}
}


static void translate(char* result, const char* value, const char sep)
{
	strcpy(result, value);
	do_translate(result, sep);
}


int path_translate(lua_State* L)
{
	const char* os;
	const char* sep;
	char buffer[0x4000];

	if (lua_gettop(L) == 1) {
		// Get target OS
		lua_getglobal(L, "os");
		lua_getfield(L, -1, "target");
		lua_call(L, 0, 1);
		os = luaL_checkstring(L, -1);
		lua_pop(L, 2);

		// Use target OS separator
		if (strcmp(os, "windows") == 0) {
			sep = "\\";
		}
		else {
			sep = "/";
		}
	}
	else {
		sep = luaL_checkstring(L, 2);
	}

	if (lua_istable(L, 1)) {
		int i = 0;
		lua_newtable(L);
		lua_pushnil(L);
		while (lua_next(L, 1)) {
			const char* value = luaL_checkstring(L, 4);
			translate(buffer, value, sep[0]);
			lua_pop(L, 1);

			lua_pushstring(L, buffer);
			lua_rawseti(L, -3, ++i);
		}
		return 1;
	}
	else {
		const char* value = luaL_checkstring(L, 1);
		translate(buffer, value, sep[0]);
		lua_pushstring(L, buffer);
		return 1;
	}
}
