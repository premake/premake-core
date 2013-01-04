/**
 * \file   path_getabsolute.c
 * \brief  Returns an absolute version of a relative path.
 * \author Copyright (c) 2002-2013 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <string.h>


static void getabsolute(char* result, const char* value)
{
	int i;
	char* ch;
	char buffer[0x4000] = { '\0' };

	/* if the path is not already absolute, base it on working dir */
	if (!do_isabsolute(value)) {
		do_getcwd(buffer, 0x4000);
		strcat(buffer, "/");
	}

	/* normalize the path */
	strcat(buffer, value);
	for (ch = buffer; *ch != '\0'; ++ch) {
		if (*ch == '\\') {
			*ch = '/';
		}
	}

	/* process it part by part */
	result[0] = '\0';
	if (buffer[0] == '/') {
		strcat(result, "/");
	}

	ch = strtok(buffer, "/");
	while (ch) {
		/* remove ".." */
		if (strcmp(ch, "..") == 0) {
			i = strlen(result) - 2;
			while (i >= 0 && result[i] != '/') {
				--i;
			}
			if (i >= 0) {
				result[i + 1] = '\0';
			}
		}

		/* allow everything except "." */
		else if (strcmp(ch, ".") != 0) {
			strcat(result, ch);
			strcat(result, "/");
		}

		ch = strtok(NULL, "/");
	}

	/* remove trailing slash */
	i = strlen(result) - 1;
	if (result[i] == '/') {
		result[i] = '\0';
	}
}


int path_getabsolute(lua_State* L)
{
	char buffer[0x4000];

	if (lua_istable(L, 1)) {
		int i = 0;
		lua_newtable(L);
		lua_pushnil(L);
		while (lua_next(L, 1)) {
			const char* value = luaL_checkstring(L, 4);
			getabsolute(buffer, value);
			lua_pop(L, 1);

			lua_pushnumber(L, ++i);
			lua_pushstring(L, buffer);
			lua_settable(L, 2);
		}
		return 1;
	}
	else {
		const char* value = luaL_checkstring(L, 1);
		getabsolute(buffer, value);
		lua_pushstring(L, buffer);
		return 1;
	}
}
