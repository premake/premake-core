/**
 * \file   host.c
 * \brief  Functions to query the specifics of the operating environment.
 * \author Copyright (c) 2011 Jason Perkins and the Premake project
 */

#include "premake.h"

/**
 * Determine if we're running under 64-bit Windows.
 */
int windows_is_64bit_running_under_wow(struct lua_State* L)
{
#if PLATFORM_WINDOWS
	typedef BOOL (WINAPI * wow_func_sig)(HANDLE,PBOOL);

	BOOL is_wow = FALSE;
	wow_func_sig func = (wow_func_sig)GetProcAddress(GetModuleHandle(TEXT("kernel32")),"IsWow64Process");
	if (func)
	{
		if(! func(GetCurrentProcess(),&is_wow))
			luaL_error(L, "IsWow64Process returned an error");
	}
#else
	int is_wow = 0;
#endif
	lua_pushboolean(L, is_wow);
	return 1;
}
