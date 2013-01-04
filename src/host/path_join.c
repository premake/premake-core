/**
 * \file   path_join.c
 * \brief  Join two or more pieces of a file system path.
 * \author Copyright (c) 2002-2013 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <string.h>


int path_join(lua_State* L)
{
	int i, len;
	const char* part;
	char buffer[0x4000];
	char* ptr = buffer;

	/* for each argument... */
	int argc = lua_gettop(L);
	for (i = 1; i <= argc; ++i) {
		/* if next argument is nil, skip it */
		if (lua_isnil(L, i)) {
			continue;
		}

		/* grab the next argument */
		part = luaL_checkstring(L, i);
		len = strlen(part);

		/* remove trailing slashes */
		while (len > 1 && part[len - 1] == '/') {
			--len;
		}

		/* ignore empty segments and "." */
		if (len == 0 || (len == 1 && part[0] == '.')) {
			continue;
		}

		/* if I encounter an absolute path, restart my result */
		if (do_isabsolute(part)) {
			ptr = buffer;
		}

		/* if the path is already started, split parts */
		if (ptr != buffer && *(ptr - 1) != '/') {
			*(ptr++) = '/';
		}

		/* append new part */
		strcpy(ptr, part);
		ptr += len;
	}

	*ptr = '\0';
	lua_pushstring(L, buffer);
	return 1;
}
