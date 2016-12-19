/**
* \file   path_normalize.c
* \brief  Removes any weirdness from a file system path string.
* \author Copyright (c) 2013 Jason Perkins and the Premake project
*/

#include "premake.h"
#include <ctype.h>
#include <string.h>


static void* normalize_substring(const char* str, const char* endPtr, char* writePtr) {
	const char* const source = str;
	const char* const writeBegin = writePtr;
	const char* ptr;
	char last = 0;
	char ch;

	while (str != endPtr) {
		ch = (*str);

		/* make sure we're using '/' for all separators */
		if (ch == '\\') {
			ch = '/';
		}

		/* filter out .. except when it's part of the file or folder name */
		if (ch == '.' && last == '.' && *(str - 2) == '/' && (*(str + 1) == '/' || str + 1 == endPtr)) {
			last = 0;

			ptr = writePtr - 3;
			while (ptr >= writeBegin) {
				if (ptr[0] == '/' && ptr[1] != '.' && ptr[2] != '.') {
					writePtr -= writePtr - ptr;

					/* special fix for cases, when '..' is the last chars in path i.e. d:\game\.., this should be converted into d:\,
					but without this case, it will be converted into d: */
					if (writePtr - 1 >= writeBegin && *(writePtr - 1) == ':' && str + 1 == endPtr) {
						++writePtr;
					}
					break;
				}
				--ptr;
			}

			if (ptr < writeBegin) {
				*(writePtr++) = ch;
			}

			++str;
			continue;
		}

		/* filter out /./ */
		if (ch == '/' && last == '.') {
			ptr = str - 2;
			if (*ptr == '/') {	// there is no need to check whether ptr >= source since all the leading ./ will be skipped in path_normalize
				if (ptr - 1 < source || *(ptr - 1) != ':') {
					--writePtr;
				}

				++str;
				continue;
			}
		}

		/* add to the result, filtering out duplicate slashes */
		if (ch != '/' || last != '/') {
			*(writePtr++) = ch;
		}

		last = ch;
		++str;
	}

	/* remove any trailing slashes, except those, that follow the ':', to avoid a path corruption i.e. D:\ -> D: */
	while (*(--endPtr) == '/' && *(endPtr - 1) != ':') {
		--writePtr;
	}

	*writePtr = *str;

	return writePtr;
}


int path_normalize(lua_State* L)
{
	const char* path = luaL_checkstring(L, 1);
	const char* readPtr = path;
	char buffer[0x4000] = { 0 };
	char* writePtr = buffer;
	const char* endPtr;

	// skip leading white spaces
	while (*readPtr && isspace(*readPtr)) {
		++readPtr;
	}

	endPtr = readPtr;

	while (*endPtr) {
		/* remove any leading "./" sequences */
		while (strncmp(readPtr, "./", 2) == 0) {
			readPtr += 2;
		}

		// find the end of sub path
		while (*endPtr && !isspace(*endPtr)) {
			++endPtr;
		}

		writePtr = normalize_substring(readPtr, endPtr, writePtr);

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
