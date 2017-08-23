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

static int getversion(struct OsVersionInfo* info);

int os_getversion(lua_State* L)
{
	struct OsVersionInfo info = {0, 0, 0, NULL, 0};
	if (!getversion(&info))
	{
		return 0;
	}

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

#pragma comment(lib, "version.lib")

int getKernelVersion(struct OsVersionInfo* info)
{
	DWORD size = GetFileVersionInfoSizeA("kernel32.dll", NULL);
	if (size > 0)
	{
		void* data = malloc(size);
		if (GetFileVersionInfoA("kernel32.dll", 0, size, data))
		{
			void* fixedInfoPtr;
			UINT fixedInfoSize;
			if (VerQueryValueA(data, "\\", &fixedInfoPtr, &fixedInfoSize))
			{
				VS_FIXEDFILEINFO* fileInfo = (VS_FIXEDFILEINFO*)fixedInfoPtr;
				info->majorversion = HIWORD(fileInfo->dwProductVersionMS);
				info->minorversion = LOWORD(fileInfo->dwProductVersionMS);
				info->revision = HIWORD(fileInfo->dwProductVersionLS);
				return TRUE;
			}
		}
	}
	return FALSE;
}

int getversion(struct OsVersionInfo* info)
{
	HKEY key;
	info->description = "Windows";

	// First get a friendly product name from the registry.
	if (RegOpenKeyExA(HKEY_LOCAL_MACHINE, "Software\\Microsoft\\Windows NT\\CurrentVersion", 0, KEY_READ, &key) == ERROR_SUCCESS)
	{
		char value[512];
		DWORD value_length = sizeof(value);
		DWORD type;
		RegQueryValueExA(key, "productName", NULL, &type, (LPBYTE)value, &value_length);
		RegCloseKey(key);
		if (type == REG_SZ)
		{
			info->description = strdup(value);
			info->isalloc = 1;
		}
	}

	// See if we can get a product version number from kernel32.dll
	return getKernelVersion(info);
}

/*************************************************************/

#elif defined(PLATFORM_MACOSX)

#include <sys/param.h>
#include <sys/sysctl.h>
#include <string.h>
#include <stdio.h>

int getversion(struct OsVersionInfo* info)
{
	info->description = "Mac OS";

	int mib[] = { CTL_KERN, KERN_OSRELEASE };
	size_t len;
	sysctl(mib, sizeof(mib) / sizeof(mib[0]), NULL, &len, NULL, 0);

	char kernel_version[len];
	sysctl(mib, sizeof(mib) / sizeof(mib[0]), kernel_version, &len, NULL, 0);

	int kern_major;
	int kern_minor;
	sscanf(kernel_version, "%d.%d.%*d", &kern_major, &kern_minor);
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
			info->description = "OS X Lion";
			info->majorversion = 10;
			info->minorversion = 7;
			info->revision = kern_minor;
			break;
		case 12:
			info->description = "OS X Mountain Lion";
			info->majorversion = 10;
			info->minorversion = 8;
			info->revision = kern_minor;
			break;
		case 13:
			info->description = "OS X Mavericks";
			info->majorversion = 10;
			info->minorversion = 9;
			info->revision = kern_minor;
			break;
		case 14:
			info->description = "OS X Yosemite";
			info->majorversion = 10;
			info->minorversion = 10;
			info->revision = kern_minor;
			break;
		case 15:
			info->description = "OS X El Capitan";
			info->majorversion = 10;
			info->minorversion = 11;
			info->revision = kern_minor;
			break;
		case 16:
			info->description = "macOS Sierra";
			info->majorversion = 10;
			info->minorversion = 12;
			info->revision = kern_minor;
			break;
		default:
			break;
	}

	return 1;
}


/*************************************************************/

#elif defined(PLATFORM_BSD) || defined(PLATFORM_LINUX) || defined(PLATFORM_SOLARIS) || defined(PLATFORM_HURD)

#include <string.h>
#include <sys/utsname.h>

int getversion(struct OsVersionInfo* info)
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
		return 0;
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

	return 1;
}

/*************************************************************/

#else

int getversion(struct OsVersionInfo* info)
{
	return 0;
}

#endif

