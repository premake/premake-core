/**
 * \file   term_textColor.c
 * \brief  Change the foreground color of the terminal output.
 * \author Copyright (c) 2017 Blizzard Entertainment and the Premake project
 */

#include "premake.h"


int term_getTextColor(lua_State* L)
{
#if PLATFORM_WINDOWS
	CONSOLE_SCREEN_BUFFER_INFO info;
	if (!GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &info))
		return 0;
	lua_pushinteger(L, (int)info.wAttributes);
	return 1;
#else
	(void)(L);  /* warning: unused parameter */
	return 0;
#endif
}


int term_setTextColor(lua_State* L)
{
#if PLATFORM_WINDOWS
	lua_Integer color = luaL_optinteger(L, 1, -1);
	if (color >= 0)
	{
		SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), (WORD)color);
		SetConsoleTextAttribute(GetStdHandle(STD_ERROR_HANDLE), (WORD)color);
	}
#else
	(void)(L);  /* warning: unused parameter */
#endif

	return 0;
	}
