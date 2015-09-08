/**
 * \file   path_join.c
 * \brief  Join two or more pieces of a file system path.
 * \author Copyright (c) 2002-2013 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <string.h>


int path_join(lua_State* L)
{
	int i;
	size_t len;
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

		/* remove leading "./" */
		while (strncmp(part, "./", 2) == 0) {
			part += 2;
			len -= 2;
		}

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

		/* if source has a .. prefix then take off last dest path part
		   note that this doesn't guarantee a normalized result as this
		   code doesn't check for .. in the mid path, however .. occurring
		   mid path are much more likely to occur during path joins
		   and its faster if we handle here as we don't have to remove
		   substrings from the middle of the string. */

		while (ptr != buffer && len >= 2 && part[0] == '.' && part[1] == '.') {
			/* locate start of previous segment */
			char* start = strrchr(buffer, '/');
			if (!start) {
				start = buffer;
			}
			else {
				++start;
			}

			/* if I hit a segment I can't trim, bail out */
			if (strcmp(start, "..") == 0	/* parent dir */
				|| strcmp(start, ".") == 0	/* current dir */
				|| strstr(start, "**") != NULL	/* recursive wildcard */
				|| strchr(start, '$') != NULL)	/* property expansion */
			{
				break;
			}

			/* otherwise trim segment and the ".." sequence */
			if (start != buffer) {
				--start;
			}
			*start = '\0';
			ptr = start;
			part += 2;
			len -= 2;
			if (len > 0 && part[0] == '/') {
				++part;
				--len;
			}
		}

		/* if the path is already started, split parts */
		if (ptr != buffer && *(ptr - 1) != '/') {
			*(ptr++) = '/';
		}

		/* append new part */
		strncpy(ptr, part, len);
		ptr += len;
		*ptr = '\0';
	}

	lua_pushstring(L, buffer);
	return 1;
}
