
#include "premake.h"

int windows_is_64bit_running_under_wow(struct lua_State* l)
{
#if PLATFORM_WINDOWS == 1
	typedef BOOL (WINAPI * wow_func_sig)(HANDLE,PBOOL);

	BOOL is_wow = FALSE;
	wow_func_sig func = (wow_func_sig)GetProcAddress(GetModuleHandle(TEXT("kernel32")),"IsWow64Process");
	if(func)
		if(! func(GetCurrentProcess(),&is_wow))
			luaL_error(l,"IsWow64Process returned an error");
#else
	int is_wow = 0;
#endif
	lua_pushboolean(l,is_wow);
	return 1;
}