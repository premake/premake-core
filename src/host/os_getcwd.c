/**
 * \file   os_getcwd.c
 * \brief  Retrieve the current working directory.
 * \author Copyright (c) 2002-2008 Jess Perkins and the Premake project
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
#if PLATFORM_WINDOWS
	DWORD result = GetCurrentDirectoryW(0, NULL), result2;
	wchar_t *wbuffer;
	int s;
	if (!result) return 0;
	wbuffer = (wchar_t *)malloc(result * sizeof(wchar_t));
	if (!wbuffer) return 0;
	result2 = GetCurrentDirectoryW(result, wbuffer);
	if (!result2 || result2 >= result)
	{
		free(wbuffer);
		return 0;
	}
	s = WideCharToMultiByte(CP_UTF8, 0, wbuffer, result2, buffer, (int)(size ? size - 1 : 0), NULL, NULL);
	free(wbuffer);
	if (!s || s >= (int)size) return 0;
	buffer[s] = '\0';
	do_translate(buffer, '/');
	return 1;
#else
	return (getcwd(buffer, size) != 0);
#endif
}
