/**
 * \file   path_normalize.c
 * \brief  Removes any weirdness from a file system path string.
 * \author Copyright (c) 2013 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <string.h>


int path_normalize(lua_State* L)
{
	char buffer[0x4000];
	char* src;
	char* dst;
	char last;

	const char* path = luaL_checkstring(L, 1);
	strcpy(buffer, path);

	src = buffer;
	dst = buffer;
	last = '\0';

	while (*src != '\0') {
		char ch = (*src);

		/* make sure we're using '/' for all separators */
		if (ch == '\\') {
			ch = '/';
		}

		/* add to the result, filtering out duplicate slashes */
		if (ch != '/' || last != '/') {
			*(dst++) = ch;
		}

		/* ...except at the start of a string, for UNC paths */
		if (src != buffer) {
			last = (*src);
		}

		++src;
	}

	/* remove any trailing slashes */
    for (--src; src > buffer && *src == '/'; --src) {
         *src = '\0';
    }

    /* remove any leading "./" sequences */
    src = buffer;
    while (strncmp(src, "./", 2) == 0) {
    	src += 2;
    }

	*dst = '\0';
	lua_pushstring(L, src);
	return 1;
}


/* Call the scripted path.normalize(), to allow for overrides */
void do_normalize(lua_State* L, char* buffer, const char* path)
{
	int top = lua_gettop(L);

	lua_getglobal(L, "path");
	lua_getfield(L, -1, "normalize");
	lua_pushstring(L, path);
	lua_call(L, 1, 1);

	path = luaL_checkstring(L, -1);
	strcpy(buffer, path);

	lua_settop(L, top);
}
