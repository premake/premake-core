/**
 * \file   os_getcwd.c
 * \brief  Retrieve the current working directory.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"

int os_getcwd(lua_State* L)
{
	char buffer[0x4000];
	if (do_getcwd(buffer, 0x4000)) {
		lua_pushstring(L, buffer);
		return 1;
	}
	else {
		return 0;
	}
}


int do_getcwd(char* buffer, size_t size)
{
	int result;

#if PLATFORM_WINDOWS
	wchar_t wbuffer[PATH_MAX];

	result = (GetCurrentDirectoryW(PATH_MAX, wbuffer) != 0);
	if (result) {
		WideCharToMultiByte(CP_UTF8, 0, wbuffer, -1, buffer, size, NULL, NULL);

		do_translate(buffer, '/');
	}
#else
	result = (getcwd(buffer, size) != 0);
#endif

	return result;
}
