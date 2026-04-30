/**
 * \file   os_writefile_ifnotequal.c
 * \brief  Writes a file only if it differs with its current contents.
 * \author Blizzard Entertainment (contact tvandijck@blizzard.com)
 * \author Copyright (c) 2015 Jess Perkins and the Premake project
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "premake.h"

static int compare_file(lua_State *L, const char* content, size_t length, const char* dst)
{
	FILE* file;
	size_t size;
	size_t read;
	char buffer[4096];
	size_t num;

#if PLATFORM_WINDOWS
	const wchar_t *wpath = luaL_convertstring(L, dst);
	if (!wpath)
		return FALSE;

	file = _wfopen(wpath, L"rb");
	lua_pop(L, 1);
#else
	(void)(L);
	file = fopen(dst, "rb");
#endif

	if (file == NULL)
	{
		return FALSE;
	}

	// check sizes.
	fseek(file, 0, SEEK_END);
	size = ftell(file);
	fseek(file, 0, SEEK_SET);

	if (length != size)
	{
		fclose(file);
		return FALSE;
	}

	while (size > 0)
	{
		num = size > 4096 ? 4096 : size;

		read = fread(buffer, 1, num, file);
		if (read != num)
		{
			fclose (file);
			return FALSE;
		}

		if (memcmp(content, buffer, num) != 0)
		{
			fclose(file);
			return FALSE;
		}

		size    -= num;
		content += num;
	}

	fclose(file);
	return TRUE;
}


int os_writefile_ifnotequal(lua_State* L)
{
	FILE* file;
	size_t length;
	const char* content = luaL_checklstring(L, 1, &length);
	const char* dst     = luaL_checkstring(L, 2);

	// if destination exist, and they are the same, no need to copy.
	if (do_isfile(L, dst) && compare_file(L, content, length, dst))
	{
		lua_pushinteger(L, 0);
		return 1;
	}

	#if PLATFORM_WINDOWS
	const wchar_t *wpath = luaL_convertstring(L, dst);
	if (!wpath)
		return FALSE;

	file = _wfopen(wpath, L"wb");
	lua_pop(L, 1);
	#else
	(void)(L);
	file = fopen(dst, "wb");
	#endif

	if (file != NULL)
	{
		int error = fwrite(content, length, 1, file) != 1;
		fclose(file);

		if (!error)
		{
			lua_pushinteger(L, 1);
			return 1;
		}
	}

	lua_pushinteger(L, -1);
	lua_pushfstring(L, "unable to write file to '%s'", dst);
	return 2;
}
