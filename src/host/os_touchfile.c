/**
 * \file   os_touchfile.c
 * \brief markes a file as modified without changing its contents.
 * \author Blizzard Entertainment (contact tvandijck@blizzard.com)
 * \author Copyright (c) 2015 Jess Perkins and the Premake project
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "premake.h"

#if PLATFORM_WINDOWS
	#include <io.h>
#else
	#include <unistd.h>
	#include <sys/types.h>
	#include <utime.h>
	#include <time.h>
#endif

#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE 1
#endif

#if !PLATFORM_WINDOWS
/* if this is ever used on windows, we need to convert to properly treat `fn` as UTF-8 */
static int touch_file(const char* fn)
{
	struct utimbuf buf;
	buf.actime = buf.modtime = time(NULL);
	return utime(fn, &buf) == 0;
}
#endif

int os_touchfile(lua_State* L)
{
	FILE* file;
	const char* dst     = luaL_checkstring(L, 1);

	// if destination exist, mark the file as modified
	if (do_isfile(L, dst))
	{
		/* existing file */
#if PLATFORM_WINDOWS
		SYSTEMTIME systemTime;
		FILETIME fileTime;
		HANDLE fileHandle;
		const wchar_t *wpath = luaL_convertstringi(L, 1);
		if (!wpath)
		{
			lua_pushinteger(L, -1);
			lua_pushstring(L, "unable to encode path");
			return 2;
		}

		fileHandle = CreateFileW(wpath, FILE_WRITE_ATTRIBUTES, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
		lua_pop(L, 1);
		if (fileHandle == NULL || fileHandle == INVALID_HANDLE_VALUE)
		{
			lua_pushinteger(L, -1);
			lua_pushfstring(L, "unable to touch file '%s'", dst);
			return 2;
		}

		GetSystemTime(&systemTime);
		if (SystemTimeToFileTime(&systemTime, &fileTime) == 0)
		{
			CloseHandle(fileHandle);
			lua_pushinteger(L, -1);
			lua_pushfstring(L, "unable to touch file '%s'", dst);
			return 2;
		}

		if (SetFileTime(fileHandle, NULL, NULL, &fileTime) == 0)
		{
			CloseHandle(fileHandle);
			lua_pushinteger(L, -1);
			lua_pushfstring(L, "unable to touch file '%s'", dst);
			return 2;
		}

		CloseHandle(fileHandle);
		lua_pushinteger(L, 0);
		return 1;
#else
		if (touch_file(dst))
		{
			lua_pushinteger(L, 0);
			return 1;
		} else {
			lua_pushinteger(L, -1);
			lua_pushfstring(L, "unable to touch file '%s'", dst);
			return 2;
		}
#endif
	}

	/* new file (doesn't previously exist) */
#if PLATFORM_WINDOWS
	const wchar_t *wpath = luaL_convertstring(L, dst);
	if (!wpath)
	{
		lua_pushinteger(L, -1);
		lua_pushstring(L, "unable to encode path");
		return 2;
	}

	file = _wfopen(wpath, L"wb");
	lua_pop(L, 1);
#else
	file = fopen(dst, "wb");
#endif

	if (file != NULL)
	{
		fclose(file);

		lua_pushinteger(L, 1);
		return 1;
	}

	lua_pushinteger(L, -1);
	lua_pushfstring(L, "unable to touch file '%s'", dst);
	return 2;
}
