/**
 * \file   os_comparefiles.c
 * \brief  Check if two files are identical.
 * \author Copyright (c) 2015 Jérôme "Lynix" Leclercq and the Premake project
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "premake.h"

int os_comparefiles(lua_State* L)
{
	FILE* firstFile;
	FILE* secondFile;
	size_t firstSize;
	size_t secondSize;
	size_t count;
	size_t read;
	char firstBuffer[4096];
	char secondBuffer[4096];
	const char* firstPath = luaL_checkstring(L, 1);
	const char* secondPath = luaL_checkstring(L, 2);

	#if PLATFORM_WINDOWS
	wchar_t wide_firstPath[PATH_MAX];
	if (MultiByteToWideChar(CP_UTF8, 0, firstPath, -1, wide_firstPath, PATH_MAX) == 0)
	{
		lua_pushnil(L);
		lua_pushstring(L, "unable to encode first path");
		return 2;
	}

	wchar_t wide_secondPath[PATH_MAX];
	if (MultiByteToWideChar(CP_UTF8, 0, secondPath, -1, wide_secondPath, PATH_MAX) == 0)
	{
		lua_pushnil(L);
		lua_pushstring(L, "unable to encode second path");
		return 2;
	}

	firstFile = _wfopen(wide_firstPath, L"rb");
	secondFile = _wfopen(wide_secondPath, L"rb");
	#else
	firstFile = fopen(firstPath, "rb");
	secondFile = fopen(secondPath, "rb");
	#endif

	if (!firstFile)
	{
		if (secondFile)
			fclose(secondFile);

		lua_pushnil(L);
		lua_pushstring(L, "failed to open first file");
		return 2;
	}


	if (!secondFile)
	{
		fclose(firstFile);

		lua_pushnil(L);
		lua_pushstring(L, "failed to open second file");
		return 2;
	}

	// check sizes.
	fseek(firstFile, 0, SEEK_END);
	firstSize = ftell(firstFile);
	fseek(firstFile, 0, SEEK_SET);

	fseek(secondFile, 0, SEEK_END);
	secondSize = ftell(secondFile);
	fseek(secondFile, 0, SEEK_SET);

	if (firstSize != secondSize)
	{
		fclose(firstFile);
		fclose(secondFile);

		lua_pushboolean(L, 0);
		return 1;
	}

	// compare file content
	while (firstSize > 0)
	{
		count = firstSize > 4096 ? 4096 : firstSize;

		read = fread(firstBuffer, 1, count, firstFile);
		if (read != count)
		{
			fclose(firstFile);
			fclose(secondFile);

			lua_pushnil(L);
			lua_pushstring(L, "failed to read first file content");
			return 2;
		}

		read = fread(secondBuffer, 1, count, secondFile);
		if (read != count)
		{
			fclose(firstFile);
			fclose(secondFile);

			lua_pushnil(L);
			lua_pushstring(L, "failed to read second file content");
			return 2;
		}

		if (memcmp(firstBuffer, secondBuffer, count) != 0)
		{
			fclose(firstFile);
			fclose(secondFile);

			lua_pushboolean(L, 0);
			return 1;
		}

		firstSize -= count;
	}

	// File content match
	fclose(firstFile);
	fclose(secondFile);

	lua_pushboolean(L, 1);
	return 1;
}
