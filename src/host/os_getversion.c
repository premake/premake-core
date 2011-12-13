/**
 * \file   os_getversioninfo.c
 * \brief  Retrieve operating system version information.
 * \author Copyright (c) 2011 Jason Perkins and the Premake project
 */

#include "premake.h"

struct OsVersionInfo
{
	int majorversion;
	int minorversion;
	int revision;
	const char* description;
} ;

static void getversion(struct OsVersionInfo* info);

int os_getversion(lua_State* L)
{
	struct OsVersionInfo info;
	getversion(&info);

	lua_newtable(L);

	lua_pushstring(L, "majorversion");
	lua_pushnumber(L, info.majorversion);
	lua_settable(L, -3);

	lua_pushstring(L, "minorversion");
	lua_pushnumber(L, info.minorversion);
	lua_settable(L, -3);

	lua_pushstring(L, "revision");
	lua_pushnumber(L, info.revision);
	lua_settable(L, -3);

	lua_pushstring(L, "description");
	lua_pushstring(L, info.description);
	lua_settable(L, -3);

	return 1;
}

/*************************************************************/

#if defined(PLATFORM_WINDOWS)

#if !defined(VER_SUITE_WH_SERVER)
#define VER_SUITE_WH_SERVER   (0x00008000)
#endif

#ifndef SM_SERVERR2
#	define SM_SERVERR2 89
#endif

SYSTEM_INFO getsysteminfo()
{
	typedef void (WINAPI *GetNativeSystemInfoSig)(LPSYSTEM_INFO);
	GetNativeSystemInfoSig nativeSystemInfo = (GetNativeSystemInfoSig)
	GetProcAddress(GetModuleHandle(TEXT("kernel32")), "GetNativeSystemInfo");

	SYSTEM_INFO systemInfo = {{0}};
	if ( nativeSystemInfo ) nativeSystemInfo(&systemInfo);
	else GetSystemInfo(&systemInfo);
	return systemInfo;
}

void getversion(struct OsVersionInfo* info)
{
	OSVERSIONINFOEX versionInfo = {0};

	versionInfo.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);
	GetVersionEx((OSVERSIONINFO*)&versionInfo);

	info->majorversion = versionInfo.dwMajorVersion;
	info->minorversion = versionInfo.dwMinorVersion;
	info->revision = versionInfo.wServicePackMajor;

	if (versionInfo.dwMajorVersion == 5 && versionInfo.dwMinorVersion == 0)
	{
		info->description = "Windows 2000";
	}
	else if (versionInfo.dwMajorVersion == 5 && versionInfo.dwMinorVersion == 1)
	{
		info->description = "Windows XP";
	}
	else if (versionInfo.dwMajorVersion == 5 && versionInfo.dwMinorVersion == 2)
	{
		SYSTEM_INFO systemInfo = getsysteminfo();
		if (versionInfo.wProductType == VER_NT_WORKSTATION &&
			systemInfo.wProcessorArchitecture == PROCESSOR_ARCHITECTURE_AMD64)
		{
			info->description = "Windows XP Professional x64";
		}
		else if (versionInfo.wSuiteMask & VER_SUITE_WH_SERVER)
		{
			info->description = "Windows Home Server";
		}
		else if (GetSystemMetrics(SM_SERVERR2) == 0)
		{
			info->description = "Windows Server 2003";
		}
		else
		{
			info->description = "Windows Server 2003 R2";
		}
	}
	else if (versionInfo.dwMajorVersion == 6 && versionInfo.dwMinorVersion == 0)
	{
		if (versionInfo.wProductType == VER_NT_WORKSTATION)
		{
			info->description = "Windows Vista";
		}
		else
		{
			info->description = "Windows Server 2008";
		}
	}
	else if (versionInfo.dwMajorVersion == 6 && versionInfo.dwMinorVersion == 1 )
	{
		if (versionInfo.wProductType != VER_NT_WORKSTATION)
		{
			info->description = "Windows Server 2008 R2";
		}
		else
		{
			info->description = "Windows 7";
		}
	}
	else
	{
		info->description = "Windows";
	}
}

/*************************************************************/

#elif defined(PLATFORM_MACOSX)

#include <CoreServices/CoreServices.h>

void getversion(struct OsVersionInfo* info)
{
	SInt32 majorversion, minorversion, bugfix;
	Gestalt(gestaltSystemVersionMajor, &majorversion);
	Gestalt(gestaltSystemVersionMinor, &minorversion);
	Gestalt(gestaltSystemVersionBugFix, &bugfix);

	info->majorversion = majorversion;
	info->minorversion = minorversion;
	info->revision = bugfix;

	info->description = "Mac OS X";
	if (info->majorversion == 10)
	{
		switch (info->minorversion)
		{
		case 4:
			info->description = "Mac OS X Tiger";
			break;
		case 5:
			info->description = "Mac OS X Leopard";
			break;
		case 6:
			info->description = "Mac OS X Snow Leopard";
			break;
		case 7:
			info->description = "Mac OS X Lion";
			break;
		}
	}
}

/*************************************************************/

#else

void getversion(struct OsVersionInfo* info)
{
	info->majorversion = 0;
	info->minorversion = 0;
	info->revision = 0;
	info->description = PLATFORM_STRING;
}

#endif

