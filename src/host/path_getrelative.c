/**
 * \file   path_getrelative.c
 * \brief  Returns a path relative to another.
 * \author Copyright (c) 2002-2013 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <string.h>


static void normalize(char* buffer, const char* path)
{
	char* src;
	char* dst;
	char last;

	strcpy(buffer, path);
	do_translate(buffer, '/');

	/* remove any duplicate slashes within the path */
	src = buffer;
	dst = buffer;
	last = '\0';

	while (*src != '\0') {
		/* if I don't have consecutive slashes, keep the char */
		if (*src != '/' || last != '/') {
			*(dst++) = *src;
		}

		/* Allow double-slash at the start of the string, so absolute
		 * UNC paths can be expressed, but nowhere else */
		if (src != buffer) {
			last = (*src);
		}

		/* check the next one */
		++src;
	}

	*dst = '\0';
}


int path_getrelative(lua_State* L)
{
	int i, last, count;
	char src[0x4000];
	char dst[0x4000];

	const char* p1 = luaL_checkstring(L, 1);
	const char* p2 = luaL_checkstring(L, 2);

	/* normalize the paths */
	normalize(src, p1);
	normalize(dst, p2);

	/* same directory? */
	if (strcmp(src, dst) == 0) {
		lua_pushstring(L, ".");
		return 1;
	}

	/* dollar macro? Can't tell what the real path might be, so treat
	 * as absolute. This enables paths like $(SDK_ROOT)/include to
	 * work as expected. */
	if (dst[0] == '$') {
		lua_pushstring(L, dst);
		return 1;
	}

	/* find the common leading directories */
	strcat(src, "/");
	strcat(dst, "/");

	last = -1;
	i = 0;
	while (src[i] && dst[i] && src[i] == dst[i]) {
		if (src[i] == '/') {
			last = i;
		}
		++i;
	}

	/* if they have nothing in common return absolute path */
	if (last <= 0) {
		dst[strlen(dst) - 1] = '\0';
		lua_pushstring(L, dst);
		return 1;
	}

	/* count remaining levels in src */
	count = 0;
	for (i = last + 1; src[i] != '\0'; ++i) {
		if (src[i] == '/') {
			++count;
		}
	}

	/* start my result by backing out that many levels */
	src[0] = '\0';
	for (i = 0; i < count; ++i) {
		strcat(src, "../");
	}

	/* append what's left */
	strcat(src, dst + last + 1);

	/* remove trailing slash and done */
	src[strlen(src) - 1] = '\0';
	lua_pushstring(L, src);
	return 1;
}
