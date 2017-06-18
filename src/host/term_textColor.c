/**
 * \file   term_textColor.c
 * \brief  Change the foreground color of the terminal output.
 * \author Copyright (c) 2017 Blizzard Entertainment and the Premake project
 */

#include "premake.h"

int term_doGetTextColor()
{
#if PLATFORM_WINDOWS
	CONSOLE_SCREEN_BUFFER_INFO info;
	if (!GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &info))
		return -1;
	return (int)info.wAttributes;
#else
	return -1;
#endif
}

void term_dosetTextColor(int color)
{
#if PLATFORM_WINDOWS
	if (color >= 0)
	{
		SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), (WORD)color);
		SetConsoleTextAttribute(GetStdHandle(STD_ERROR_HANDLE), (WORD)color);
	}
#else
	(void)(color);  /* warning: unused parameter */
#endif
}


int term_getTextColor(lua_State* L)
{
	int color = term_doGetTextColor();
	if (color >= 0)
	{
		lua_pushinteger(L, color);
		return 1;
	}
	return 0;
}


int term_setTextColor(lua_State* L)
{
	term_dosetTextColor((int)luaL_optinteger(L, 1, -1));
	return 0;
}
