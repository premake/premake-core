
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

int windows_version(struct lua_State* l)
{
#if PLATFORM_WINDOWS == 1
    OSVERSIONINFO info = OSVERSIONINFO{0};
    info.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
	GetVersionEx(&info);
	
	if( info.dwMajorVersion == 5 && info.dwMinorVersion == 0 )
		lua_pushliteral(l,"Windows2000");
	else if (info.dwMajorVersion == 5 && info.dwMinorVersion == 1 )
		lua_pushliteral(l,"WindowsXP");
	else if( info.dwMajorVersion == 5 && info.dwMinorVersion == 2 )
	{
		if ( OSVERSIONINFOEX.wProductType == VER_NT_WORKSTATION 
			&& SYSTEM_INFO.wProcessorArchitecture==PROCESSOR_ARCHITECTURE_AMD64)
				lua_pushliteral(l,"WindowsXPProfessionalx64)"
			else if(OSVERSIONINFOEX.wSuiteMask & VER_SUITE_WH_SERVER)
				lua_pushliteral(l,"WindowsHomeServer");
			else if( GetSystemMetrics(SM_SERVERR2) == 0)
				lua_pushliteral(l,"WindowsServer2003");
			else
				lua_pushliteral(l,"WindowsServer2003R2")
				}
	else if( info.dwMajorVersion == 6 && info.dwMinorVersion == 0  )
	{
		if( OSVERSIONINFOEX.wProductType == VER_NT_WORKSTATION )
			lua_pushliteral(l,"WindowsVista");
		else
			lua_pushliteral(l,"WindowsServer2008");
	}
	else if ( info.dwMajorVersion == 6 && info.dwMinorVersion == 1  )
	{
		if (OSVERSIONINFOEX.wProductType != VER_NT_WORKSTATION)
			lua_pushliteral(l,"WindowsServer2008R2");
		else lua_pushliteral(l,"Windows7");
	}
	else
		lua_pushliteral(l,"unknown windows version");
#else
	lua_pushliteral(l,"host is not windows");
#endif

	return 1;
}