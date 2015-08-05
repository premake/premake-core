/**
 * \file   path_normalize.c
 * \brief  Removes any weirdness from a file system path string.
 * \author Copyright (c) 2013 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <ctype.h>
#include <string.h>


static void normalize_sub_string(const char* str, const char* endPtr, char** writePtr) {
	const char* const source = str;
	const char* const writeBegin = *writePtr;
	char last = 0;

	while (str != endPtr) {
		char ch = (*str);

		/* make sure we're using '/' for all separators */
		if (ch == '\\') {
			ch = '/';
		}

		/* filter out .. */
		if (ch == '.' && last == '.') {
			last = 0;

			const char* ptr = *writePtr - 3;
			while (ptr >= writeBegin) {
				if (ptr[0] == '/' && ptr[1] != '.' && ptr[2] != '.') {
					*writePtr -= *writePtr - ptr;
					break;
				}
				--ptr;
			}

			if (ptr < writeBegin) {
				*((*writePtr)++) = ch;				
			}

			++str;
			continue;
		}

		/* filter out /./ */
		if (ch == '/' && last == '.') {
			const char* ptr = str - 2;
			if (ptr >= source && ptr[0] == '/') {
				*writePtr -= 1;
				++str;
				continue;
			}
		}

		/* add to the result, filtering out duplicate slashes */
		if (ch != '/' || last != '/') {
			*((*writePtr)++) = ch;
		}

		last = ch;
		++str;
	}

	/* remove any trailing slashes */
	while (*(--endPtr) == '/') {
		--*writePtr;
	}

	**writePtr = *str;
}


int path_normalize(lua_State* L)
{
	const char* path = luaL_checkstring(L, 1);
	const char* readPtr = path;
	char buffer[0x4000] = { 0 };
	char* writePtr = buffer;

	// skip leading white spaces
	while (*readPtr && isspace(*readPtr)) {
		++readPtr;
	}

	const char* endPtr = readPtr;

	while (*endPtr) {
		/* remove any leading "./" sequences */
		while (strncmp(readPtr, "./", 2) == 0) {
			readPtr += 2;
		}

		// find the end of sub path
		while (*endPtr && !isspace(*endPtr)) {
			++endPtr;
		}

		normalize_sub_string(readPtr, endPtr, &writePtr);

		// skip any white spaces between sub paths
		while (*endPtr && isspace(*endPtr)) {
			*(writePtr++) = *(endPtr++);
		}

		readPtr = endPtr;
	}

	// skip any trailing white spaces
	while (isspace(*(--endPtr))) {
		--writePtr;
	}

	*writePtr = 0;

	lua_pushstring(L, buffer);
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
