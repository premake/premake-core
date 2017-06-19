/**
 * \file   term_textColor.c
 * \brief  Change the foreground color of the terminal output.
 * \author Copyright (c) 2017 Blizzard Entertainment and the Premake project
 */

#include "premake.h"

#if PLATFORM_POSIX
static int s_currentColor = -1;
#endif

int term_doGetTextColor()
{
#if PLATFORM_WINDOWS
	CONSOLE_SCREEN_BUFFER_INFO info;
	if (!GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &info))
		return -1;
	return (int)info.wAttributes;
#else
	return s_currentColor;
#endif
}

void term_doSetTextColor(int color)
{
#if PLATFORM_WINDOWS
	if (color >= 0)
	{
		SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), (WORD)color);
		SetConsoleTextAttribute(GetStdHandle(STD_ERROR_HANDLE), (WORD)color);
	}
#else
	s_currentColor = color;

	const char* colorTable[] = 
	{
		"\x1B[0;30m", // term.black       = 0
		"\x1B[0;34m", // term.blue        = 1
		"\x1B[0;32m", // term.green       = 2
		"\x1B[0;36m", // term.cyan        = 3
		"\x1B[0;31m", // term.red         = 4
		"\x1B[0;35m", // term.purple      = 5
		"\x1B[0;33m", // term.brown       = 6
		"\x1B[0;37m", // term.lightGray   = 7
		"\x1B[1;30m", // term.gray        = 8
		"\x1B[1;34m", // term.lightBlue   = 9
		"\x1B[1;32m", // term.lightGreen  = 10
		"\x1B[1;36m", // term.lightCyan   = 11
		"\x1B[1;31m", // term.lightRed    = 12
		"\x1B[1;35m", // term.magenta     = 13
		"\x1B[1;33m", // term.yellow      = 14
		"\x1B[1;37m", // term.white       = 15
	};
	if (color >= 0 && color < 16)
	{
		puts(colorTable[color]);
	} else
	{
		puts("\x1B[0m");
	}
#endif
}


int term_getTextColor(lua_State* L)
{
	int color = term_doGetTextColor();
	lua_pushinteger(L, color);
	return 1;
}


int term_setTextColor(lua_State* L)
{
	term_doSetTextColor((int)luaL_optinteger(L, 1, -1));
	return 0;
}
