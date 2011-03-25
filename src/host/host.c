/**
 * \file   host.c
 * \brief  Functions to query the specifics of the operating environment.
 * \author Copyright (c) 2011 Jason Perkins and the Premake project
 */

#include "premake.h"

#if PLATFORM_WINDOWS
#define VER_SUITE_WH_SERVER   (0x00008000)
#endif


int windows_is_64bit_running_under_wow(struct lua_State* L)
{
#if PLATFORM_WINDOWS
	typedef BOOL (WINAPI * wow_func_sig)(HANDLE,PBOOL);

	BOOL is_wow = FALSE;
	wow_func_sig func = (wow_func_sig)GetProcAddress(GetModuleHandle(TEXT("kernel32")),"IsWow64Process");
	if(func)
		if(! func(GetCurrentProcess(),&is_wow))
			luaL_error(L, "IsWow64Process returned an error");
#else
	int is_wow = 0;
#endif
	lua_pushboolean(L, is_wow);
	return 1;
}

int windows_version(struct lua_State* L)
{
#if PLATFORM_WINDOWS
    OSVERSIONINFOEX versionInfo;
	SYSTEM_INFO systemInfo;

	ZeroMemory(&versionInfo, sizeof(OSVERSIONINFOEX));
	versionInfo.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);
	GetVersionEx((OSVERSIONINFO*)&versionInfo);

	ZeroMemory(&systemInfo, sizeof(SYSTEM_INFO));
	GetSystemInfo(&systemInfo);
	
	if (versionInfo.dwMajorVersion == 5 && versionInfo.dwMinorVersion == 0)
	{
		lua_pushliteral(L, "Windows2000");
	}
	else if (versionInfo.dwMajorVersion == 5 && versionInfo.dwMinorVersion == 1)
	{
		lua_pushliteral(L, "WindowsXP");
	}
	else if (versionInfo.dwMajorVersion == 5 && versionInfo.dwMinorVersion == 2)
	{
		if (versionInfo.wProductType == VER_NT_WORKSTATION &&
			systemInfo.wProcessorArchitecture == PROCESSOR_ARCHITECTURE_AMD64)
		{
			lua_pushliteral(L, "WindowsXPProfessionalx64");
		}
		else if (versionInfo.wSuiteMask & VER_SUITE_WH_SERVER)
		{
			lua_pushliteral(L, "WindowsHomeServer");
		}
		else if (GetSystemMetrics(SM_SERVERR2) == 0)
		{
			lua_pushliteral(L,  "WindowsServer2003");
		}
		else
		{
			lua_pushliteral(L, "WindowsServer2003R2");
		}
	}
	else if (versionInfo.dwMajorVersion == 6 && versionInfo.dwMinorVersion == 0)
	{
		if (versionInfo.wProductType == VER_NT_WORKSTATION)
		{
			lua_pushliteral(L, "WindowsVista");
		}
		else
		{
			lua_pushliteral(L, "WindowsServer2008");
		}
	}
	else if (versionInfo.dwMajorVersion == 6 && versionInfo.dwMinorVersion == 1 )
	{
		if (versionInfo.wProductType != VER_NT_WORKSTATION)
		{
			lua_pushliteral(L, "WindowsServer2008R2");
		}
		else 
		{
			lua_pushliteral(L, "Windows7");
		}
	}
	else
	{
		lua_pushliteral(L, "unknown windows version");
	}
#else
	lua_pushliteral(L, "host is not windows");
#endif

	return 1;
}