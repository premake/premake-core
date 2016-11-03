/**
 * \file   path_isabsolute.c
 * \brief  Determines if a path is absolute or relative.
 * \author Copyright (c) 2002-2016 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <ctype.h>
#include <string.h>


int path_isabsolute(lua_State* L)
{
	const char* path = luaL_checkstring(L, -1);
	lua_pushboolean(L, do_isabsolute(path));
	return 1;
}


int do_isabsolute(const char* path)
{
	char c;
	const char* closing;

	if (path[0] == '/' || path[0] == '\\')
		return 1;
	if (isalpha(path[0]) && path[1] == ':')
		return 1;
	if (path[0] == '"' || path[0] == '!')
		return do_isabsolute(path + 1);

	// $(foo) and %(foo)
	if ((path[0] == '%' || path[0] == '$') && path[1] == '(')
	{
		path += 2;
		closing = strchr(path, ')');
		if (closing == NULL)
			return 0;

		// only alpha, digits, _ and . allowed inside $()
		while (path < closing) {
			c = *path++;
			if (!isalpha(c) && !isdigit(c) && c != '_' && c != '.')
				return 0;
		}

		return 1;
	}

	// $ORIGIN.
	if (path[0] == '$')
		return 1;

	// %foo%
	if (path[0] == '%')
	{
		// find the second closing %
		path += 1;
		closing = strchr(path, '%');
		if (closing == NULL)
			return 0;

		// need at least one character between the %%
		if (path == closing)
			return 0;

		// only alpha, digits and _ allowed inside %..%
		while (path < closing) {
			c = *path++;
			if (!isalpha(c) && !isdigit(c) && c != '_')
				return 0;
		}
		return 1;
	}

	return 0;
}
