/**
 * \file   os_getpass.c
 * \brief  Prompt and retrieve a password from the user.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"


int os_getpass(lua_State* L)
{
	const char* prompt = luaL_checkstring(L, 1);

	#if PLATFORM_WINDOWS
		HANDLE hstdout = GetStdHandle(STD_OUTPUT_HANDLE);
		HANDLE hstdin = GetStdHandle(STD_INPUT_HANDLE);
		DWORD read_chars, mode, written_chars;
		char buffer[1024];
		const char* newline = "\n";

		WriteConsoleA(hstdout, prompt, (DWORD)strlen(prompt), &written_chars, NULL);

		GetConsoleMode(hstdin, &mode);
		SetConsoleMode(hstdin, ENABLE_LINE_INPUT | ENABLE_PROCESSED_INPUT);
		ReadConsoleA(hstdin, buffer, sizeof (buffer), &read_chars, NULL);
		SetConsoleMode(hstdin, mode);

		WriteConsoleA(hstdout, newline, (DWORD)strlen(newline), &written_chars, NULL);

		buffer[strcspn(buffer, "\r\n")] = '\0';

		lua_pushstring(L, buffer);
		return 1;
	#else
		lua_pushstring(L, getpass(prompt));
		return 1;
	#endif
}
