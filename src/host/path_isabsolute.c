/**
 * \file   path_isabsolute.c
 * \brief  Determines if a path is absolute or relative.
 * \author Copyright (c) 2002-2016 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <ctype.h>
#include <string.h>
#include "path_isabsolute.h"

#if PLATFORM_WINDOWS
#define strncasecmp _strnicmp
#endif

int do_absolutetype(const char* path)
{
	char c;
	const char* closing;
	size_t length;

	while (path[0] == '"' || path[0] == '!')
		path++;
	if (path[0] == '/' || path[0] == '\\')
		return JOIN_ABSOLUTE;
	if (isalpha(path[0]) && path[1] == ':')
		return JOIN_ABSOLUTE;

	// $(foo) and %(foo)
	if ((path[0] == '%' || path[0] == '$') && path[1] == '(')
	{
		char delimiter = path[0];
		closing = strchr(path + 2, ')');
		if (closing == NULL)
			return JOIN_RELATIVE;

		path += 2;
		// special case VS macros %(filename) and %(extension) as normal text
		if (delimiter == '%')
		{
			length = closing - path;
			switch (length) {
			case 8:
				if (strncasecmp(path, "Filename)", length) == 0)
					return JOIN_RELATIVE;
				break;
			case 9:
				if (strncasecmp(path, "Extension)", length) == 0)
					return JOIN_RELATIVE;
				break;
			default:
				break;
			}
		}

		// only alpha, digits, _ and . allowed inside $()
		while (path < closing) {
			c = *path++;
			if (!isalpha(c) && !isdigit(c) && c != '_' && c != '.')
				return JOIN_RELATIVE;
		}

		return JOIN_ABSOLUTE;
	}

	// $ORIGIN.
	if (path[0] == '$')
		return JOIN_ABSOLUTE;

	// either %ORIGIN% or %{<lua code>}
	if (path[0] == '%')
	{
		if (path[1] == '{') //${foo} need to defer join until after detokenization
		{
			closing = strchr(path + 2, '}');
			if (closing != NULL)
				return JOIN_MAYBE_ABSOLUTE;
		}
		// find the second closing %
		path += 1;
		closing = strchr(path, '%');
		if (closing == NULL)
			return JOIN_RELATIVE;

		// need at least one character between the %%
		if (path == closing)
			return JOIN_RELATIVE;

		// only alpha, digits and _ allowed inside %..%
		while (path < closing) {
			c = *path++;
			if (!isalpha(c) && !isdigit(c) && c != '_')
				return JOIN_RELATIVE;
		}
		return JOIN_ABSOLUTE;
	}

	return JOIN_RELATIVE;
}

int do_isabsolute(const char* path)
{
	// backwards compatibility
	return (do_absolutetype(path) == 1) ? 1 : 0;
}

int path_isabsolute(lua_State* L)
{
	const char* path = luaL_checkstring(L, -1);
	lua_pushboolean(L, do_isabsolute(path));
	return 1;
}

int path_absolutetype(lua_State* L)
{
	const char* path = luaL_checkstring(L, -1);
	lua_pushinteger(L, do_absolutetype(path));
	return 1;
}
