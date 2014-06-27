/**
 * \file   path_getabsolute.c
 * \brief  Returns an absolute version of a relative path.
 * \author Copyright (c) 2002-2013 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <string.h>


void do_getabsolute(char* result, const char* value, const char* relative_to)
{
	int i;
	char* ch;
	char* prev;
	char buffer[0x4000] = { '\0' };

	/* if the path is not already absolute, base it on working dir */
	if (!do_isabsolute(value)) {
		if (relative_to) {
			strcpy(buffer, relative_to);
		}
		else {
			do_getcwd(buffer, 0x4000);
		}
		strcat(buffer, "/");
	}

	/* normalize the path */
	strcat(buffer, value);
	do_translate(buffer, '/');

	/* process it part by part */
	result[0] = '\0';
	if (buffer[0] == '/') {
		strcat(result, "/");
	}

	prev = NULL;
	ch = strtok(buffer, "/");
	while (ch) {
		/* remove ".." where I can */
		if (strcmp(ch, "..") == 0 && (prev == NULL || (prev[0] != '$' && strcmp(prev, "..") != 0))) {
			i = strlen(result) - 2;
			while (i >= 0 && result[i] != '/') {
				--i;
			}
			if (i >= 0) {
				result[i + 1] = '\0';
			}
			ch = NULL;
		}

		/* allow everything except "." */
		else if (strcmp(ch, ".") != 0) {
			strcat(result, ch);
			strcat(result, "/");
		}

		prev = ch;
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
	const char* relative_to;
	char buffer[0x4000];

	relative_to = NULL;
	if (lua_gettop(L) > 1 && !lua_isnil(L,2)) {
		relative_to = luaL_checkstring(L, 2);
	}

	if (lua_istable(L, 1)) {
		int i = 0;
		lua_newtable(L);
		lua_pushnil(L);
		while (lua_next(L, 1)) {
			const char* value = luaL_checkstring(L, -1);
			do_getabsolute(buffer, value, relative_to);
			lua_pop(L, 1);

			lua_pushstring(L, buffer);
            lua_rawseti(L, -3, ++i);
		}
		return 1;
	}
	else {
		const char* value = luaL_checkstring(L, 1);
		do_getabsolute(buffer, value, relative_to);
		lua_pushstring(L, buffer);
		return 1;
	}
}
