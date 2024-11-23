/**
* \file   path_normalize.c
* \brief  Removes any weirdness from a file system path string.
* \author Copyright (c) 2013 Jess Perkins and the Premake project
*/

#include "premake.h"
#include <ctype.h>
#include <string.h>

#define	IS_SEP(__c)			((__c) == '/' || (__c) == '\\')
#define	IS_QUOTE(__c)		((__c) == '\"' || (__c) == '\'')

#define IS_UPPER_ALPHA(__c)	((__c) >= 'A' && (__c) <= 'Z')
#define IS_LOWER_ALPHA(__c)	((__c) >= 'a' && (__c) <= 'z')
#define IS_ALPHA(__c)		(IS_UPPER_ALPHA(__c) || IS_LOWER_ALPHA(__c))

#define IS_SPACE(__c)		((__c >= '\t' && __c <= '\r') || __c == ' ')

#define IS_WIN_ENVVAR_START(__c)	(*__c == '%')
#define IS_WIN_ENVVAR_END(__c)		(*__c == '%')

#define IS_VS_VAR_START(__c)		(*__c == '$' && __c[1] == '(')
#define IS_VS_VAR_END(__c)			(*__c == ')')

#define IS_UNIX_ENVVAR_START(__c)	(*__c == '$' && __c[1] == '{')
#define IS_UNIX_ENVVAR_END(__c)		(*__c == '}')

#define IS_PREMAKE_TOKEN_START(__c)	(*__c == '%' && __c[1] == '{')
#define IS_PREMAKE_TOKEN_END(__c)	(*__c == '}')

static void* normalize_substring(const char* srcPtr, const char* srcEnd, char* dstPtr)
{
#define IS_END(__p)			(__p >= srcEnd || *__p == '\0')
#define IS_SEP_OR_END(__p)	(IS_END(__p) || IS_SEP(*__p))

	// Handle Windows absolute paths
	if (IS_ALPHA(srcPtr[0]) && srcPtr[1] == ':')
	{
		*(dstPtr++) = srcPtr[0];
		*(dstPtr++) = ':';

		srcPtr += 2;
	}

	// Handle path starting with a sep (C:/ or /)
	if (IS_SEP(*srcPtr))
	{
		++srcPtr;
		*(dstPtr++) = '/';
		// Handle path starting with //
		if (IS_SEP(*srcPtr))
		{
			++srcPtr;
			*(dstPtr++) = '/';
		}
	}

	const char * const dstRoot = dstPtr;
	unsigned int folderDepth = 0;

	while (!IS_END(srcPtr))
	{
		// Skip multiple sep and "./" pattern
		while (IS_SEP(*srcPtr) || (srcPtr[0] == '.' && IS_SEP_OR_END(&srcPtr[1])))
			++srcPtr;

		if (IS_END(srcPtr))
			break;

		// Handle "../ pattern"
		if (srcPtr[0] == '.' && srcPtr[1] == '.' && IS_SEP_OR_END(&srcPtr[2]))
		{
			if (folderDepth > 0)
			{
				// Here dstPtr[-1] is safe as folderDepth > 0.
				while (--dstPtr != dstRoot && !IS_SEP(dstPtr[-1]));

				--folderDepth;
			}
			else
			{
				*(dstPtr++) = '.';
				*(dstPtr++) = '.';
				*(dstPtr++) = '/';
			}
			srcPtr += 3;
		}
		else
		{
			while (!IS_SEP_OR_END(srcPtr))
				*(dstPtr++) = *(srcPtr++);

			if (IS_SEP(*srcPtr))
			{
				*(dstPtr++) = '/';
				++srcPtr;
				++folderDepth;
			}
		}
	}

	// Remove trailing slash except for C:/ or / (root)
	while (dstPtr != dstRoot && IS_SEP(dstPtr[-1]))
		--dstPtr;

	return dstPtr;
#undef IS_END
#undef IS_SEP_OR_END
}

static int skip_tokens(const char *readPtr)
{
	int skipped = 0;

#define DO_SKIP_FOR(__kind)\
if (IS_ ## __kind ## _START(readPtr)) { \
	do \
	{ \
		skipped++; \
	} while (!IS_ ## __kind ## _END(readPtr++)); \
} \
// DO_SKIP_FOR

	do
	{
		DO_SKIP_FOR(PREMAKE_TOKEN)
		DO_SKIP_FOR(WIN_ENVVAR)
		DO_SKIP_FOR(VS_VAR)
		DO_SKIP_FOR(UNIX_ENVVAR)

	} while (IS_WIN_ENVVAR_START(readPtr) ||
			IS_VS_VAR_START(readPtr) ||
			IS_UNIX_ENVVAR_START(readPtr) ||
			IS_PREMAKE_TOKEN_START(readPtr));

	return skipped;
#undef DO_SKIP_FOR
}

int path_normalize(lua_State* L)
{
	const char *path = luaL_checkstring(L, 1);
	const char *readPtr = path;
	char buffer[0x4000] = { 0 };
	char *writePtr = buffer;
	const char *endPtr;

	// skip leading white spaces
	while (IS_SPACE(*readPtr))
		++readPtr;

	endPtr = readPtr;

	while (*endPtr) {

		int skipped = skip_tokens(readPtr);
		if (skipped > 0) {

			if (readPtr != path && writePtr != buffer &&
				IS_SEP(readPtr[-1]) && !IS_SEP(writePtr[-1]))
			{
				*(writePtr++) = (readPtr[-1]);
			}

			while (skipped-- > 0)
				*(writePtr++) = *(readPtr++);

			endPtr = readPtr;
		}

		// find the end of sub path
		while (*endPtr && !IS_SPACE(*endPtr) &&
			!IS_WIN_ENVVAR_START(endPtr) &&
			!IS_VS_VAR_START(endPtr) &&
			!IS_UNIX_ENVVAR_START(endPtr) &&
			!IS_PREMAKE_TOKEN_START(endPtr))
		{
			++endPtr;
		}

		// path is surrounded with quotes
		if (readPtr != endPtr &&
			IS_QUOTE(*readPtr))
		{
			*(writePtr++) = *(readPtr++);
		}

		writePtr = normalize_substring(readPtr, endPtr, writePtr);

		// skip any white spaces between sub paths
		while (IS_SPACE(*endPtr))
			*(writePtr++) = *(endPtr++);

		readPtr = endPtr;
	}

	// skip any trailing white spaces
	while (writePtr != buffer && IS_SPACE(writePtr[-1]))
		--writePtr;

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
