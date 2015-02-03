/**
 * \file   os_getversioninfo.c
 * \brief  Retrieve operating system version information.
 * \author Copyright (c) 2011-2012 Jason Perkins and the Premake project
 */

#include "premake.h"
#include <stdlib.h>

struct OsVersionInfo
{
	int majorversion;
	int minorversion;
	int revision;
	const char* description;
	int isalloc;
};

static void getversion(struct OsVersionInfo* info);


int os_getversion(lua_State* L)
{
	struct OsVersionInfo info = {0, 0, 0, NULL, 0};
	getversion(&info);

	lua_newtable(L);

	lua_pushstring(L, "majorversion");
	lua_pushnumber(L, (lua_Number)info.majorversion);
	lua_settable(L, -3);

	lua_pushstring(L, "minorversion");
	lua_pushnumber(L, (lua_Number)info.minorversion);
	lua_settable(L, -3);

	lua_pushstring(L, "revision");
	lua_pushnumber(L, (lua_Number)info.revision);
	lua_settable(L, -3);

	lua_pushstring(L, "description");
	lua_pushstring(L, info.description);
	lua_settable(L, -3);

	if (info.isalloc) {
		free((void*)info.description);
	}

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
	else if (versionInfo.dwMajorVersion == 6 && versionInfo.dwMinorVersion == 2 )
	{
		if (versionInfo.wProductType != VER_NT_WORKSTATION)
		{
			info->description = "Windows Server 2012";
		}
		else
		{
			info->description = "Windows 8";
		}
	}
	else if (versionInfo.dwMajorVersion == 6 && versionInfo.dwMinorVersion == 3 )
	{
		if (versionInfo.wProductType != VER_NT_WORKSTATION)
		{
			info->description = "Windows Server 2012 R2";
		}
		else
		{
			info->description = "Windows 8.1";
		}
	}
	else
	{
		info->description = "Windows";
	}
}

/*************************************************************/

#elif defined(PLATFORM_MACOSX)

#include <sys/param.h>
#include <sys/sysctl.h>
#include <string.h>
#include <stdio.h>

void getversion(struct OsVersionInfo* info)
{
	info->description = "Mac OS";
	info->majorversion=0;
	info->minorversion=0;
	info->revision=0;

    int mib[] = {CTL_KERN, KERN_OSRELEASE};
    size_t len;
    sysctl(mib, sizeof(mib)/sizeof(mib[0]), NULL, &len, NULL, 0);

	char kernel_version[len];
    sysctl(mib, sizeof(mib)/sizeof(mib[0]), kernel_version, &len, NULL, 0);

	int kern_major;
	int kern_minor;
	sscanf(kernel_version, "%d.%d.%*d",&kern_major,&kern_minor);
	switch (kern_major)
	{
		case 8:
			info->description = "Mac OS X Tiger";
			info->majorversion = 10;
			info->minorversion = 4;
			info->revision = kern_minor;
			break;
		case 9:
			info->description = "Mac OS X Leopard";
			info->majorversion = 10;
			info->minorversion = 5;
			info->revision = kern_minor;
			break;
		case 10:
			info->description = "Mac OS X Snow Leopard";
			info->majorversion = 10;
			info->minorversion = 6;
			info->revision = kern_minor;
			break;
		case 11:
			info->description = "Mac OS X Lion";
			info->majorversion = 10;
			info->minorversion = 7;
			info->revision = kern_minor;
			break;
		case 12:
			info->description = "Mac OS X Mountain Lion";
			info->majorversion = 10;
			info->minorversion = 8;
			info->revision = kern_minor;
			break;
		case 13:
			info->description = "Mac OS X Mavericks";
			info->majorversion = 10;
			info->minorversion = 9;
			info->revision = kern_minor;
			break;
		case 14:
			info->description = "Mac OS X Yosemite";
			info->majorversion = 10;
			info->minorversion = 10;
			info->revision = kern_minor;
			break;
		default:
			break;
	}
}


/*************************************************************/

#elif defined(PLATFORM_BSD) || defined(PLATFORM_LINUX) || defined(PLATFORM_SOLARIS) || defined(PLATFORM_HURD)

#include <string.h>
#include <sys/utsname.h>

void getversion(struct OsVersionInfo* info)
{
	struct utsname u;
	char* ver;

	info->majorversion = 0;
	info->minorversion = 0;
	info->revision = 0;

	if (uname(&u))
	{
		// error
		info->description = PLATFORM_STRING;
		return;
	}

#if __GLIBC__
	// When using glibc, info->description gets set to u.sysname,
	// but it isn't passed out of this function, so we need to copy
	// the string.
	info->description = malloc(strlen(u.sysname) + 1);
	strcpy((char*)info->description, u.sysname);
	info->isalloc = 1;
#else
	info->description = u.sysname;
#endif

	if ((ver = strtok(u.release, ".-")) != NULL)
	{
		info->majorversion = atoi(ver);
		// continue parsing from the previous position
		if ((ver = strtok(NULL, ".-")) != NULL)
		{
			info->minorversion = atoi(ver);
			if ((ver = strtok(NULL, ".-")) != NULL)
				info->revision = atoi(ver);
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

