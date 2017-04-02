/**
 * \file   utf8handking.c
 * \brief  Handles conversions between Unicode (UTF-8) and system native encoding (wide chars on Windows)
 * \author Copyright (c) 2017 Jérôme Leclercq and the Premake project
 */

#include "premake.h"
#include "stdlib.h"

#ifdef PLATFORM_WINDOWS
const char* utf8_fromwide(lua_State* L, const wchar_t* wstr)
{
	int size_required = WideCharToMultiByte(CP_UTF8, 0, wstr, -1, NULL, 0, NULL, NULL);

	char* unicode_str = (char*) malloc(size_required * sizeof(char));
	WideCharToMultiByte(CP_UTF8, 0, wstr, -1, unicode_str, size_required, NULL, NULL);

	lua_pushstring(L, unicode_str);
	free(unicode_str);
	
	return unicode_str;
}

const wchar_t* utf8_towide(lua_State* L, const char* str)
{
	int size_required = MultiByteToWideChar(CP_UTF8, 0, str, -1, NULL, 0);

	wchar_t* wide_string = (wchar_t*) lua_newuserdata(L, size_required * sizeof(wchar_t));
	MultiByteToWideChar(CP_UTF8, 0, str, -1, wide_string, size_required);

	return wide_string;
}
#endif
