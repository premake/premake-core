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

#ifdef _MSC_VER
#pragma comment(lib, "version.lib")
#endif

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
				return true;
			}
		}
	}
	return false;
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

#include <CoreFoundation/CoreFoundation.h>
#include <sys/param.h>
#include <sys/sysctl.h>
#include <string.h>
#include <stdio.h>

int getversion(struct OsVersionInfo* info)
{
	const char * propertyListFilePath = "/System/Library/CoreServices/SystemVersion.plist";
	Boolean fallback = true;

	info->description = "Mac OS";
	info->majorversion = 10;

	if (access (propertyListFilePath, R_OK) == 0)
	{
		CFPropertyListFormat format;
		CFErrorRef errorDescriptor = NULL;
		CFStringRef stringRef = NULL;
		CFURLRef urlRef = NULL;
		CFReadStreamRef streamRef = NULL;
		CFPropertyListRef propertyListRef = NULL;
		CFTypeID typeId = 0;
		Boolean result = false;

		stringRef = CFStringCreateWithCStringNoCopy(
						kCFAllocatorDefault,
						propertyListFilePath,
						kCFStringEncodingASCII,
						kCFAllocatorNull);
		if (stringRef == NULL)
		{
			goto getversion_macosx_cleanup;
		};

		urlRef = CFURLCreateWithFileSystemPath(
						kCFAllocatorDefault,
						stringRef,
						kCFURLPOSIXPathStyle,
						false);
		if (urlRef == NULL)
		{
			goto getversion_macosx_cleanup;
		}

		streamRef = CFReadStreamCreateWithFile(
						kCFAllocatorDefault,
						urlRef);
		if (streamRef == NULL)
		{
			goto getversion_macosx_cleanup;
		}

		result = CFReadStreamOpen (streamRef);

		if (result == false)
		{
			goto getversion_macosx_cleanup;
		}

		propertyListRef = CFPropertyListCreateWithStream(
						kCFAllocatorDefault,
						streamRef,
						0,
						kCFPropertyListImmutable,
						&format,
						&errorDescriptor);

		CFReadStreamClose (streamRef);

		if (!(propertyListRef && CFPropertyListIsValid(propertyListRef, format)) || errorDescriptor)
		{
			goto getversion_macosx_cleanup;
		}

		typeId = CFGetTypeID(propertyListRef);
		if (typeId == CFDictionaryGetTypeID())
		{
			const CFDictionaryRef dictionaryRef = (const CFDictionaryRef)propertyListRef;
			char versionString[128];
			CFStringRef stringValueRef = NULL;
			if (CFDictionaryGetValueIfPresent(dictionaryRef, CFSTR("ProductVersion"), (const void **)(&stringValueRef)))
			{
				CFStringGetCString(stringValueRef, &versionString[0], (CFIndex)sizeof (versionString), kCFStringEncodingASCII);
				sscanf (versionString, "%d.%d.%d", &info->majorversion, &info->minorversion, &info->revision);

				fallback = false;
			}
		}

getversion_macosx_cleanup:

		if (propertyListRef) CFRelease (propertyListRef);
		if (streamRef) CFRelease (streamRef);
		if (urlRef) CFRelease (urlRef);
		if (stringRef) CFRelease (stringRef);
	}

	if (fallback == true)
	{
		int mib[] = { CTL_KERN, KERN_OSRELEASE };
		size_t len;
		sysctl(mib, sizeof(mib) / sizeof(mib[0]), NULL, &len, NULL, 0);

		char kernel_version[len];
		sysctl(mib, sizeof(mib) / sizeof(mib[0]), kernel_version, &len, NULL, 0);

		int kern_major;
		int kern_minor;
		sscanf(kernel_version, "%d.%d.%*d", &kern_major, &kern_minor);

		info->minorversion = kern_major - 4;
		info->revision = kern_minor;
	}

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
				info->description = "OS X Lion";
			break;
			case 8:
				info->description = "OS X Mountain Lion";
			break;
			case 9:
				info->description = "OS X Mavericks";
			case 10:
				info->description = "OS X Yosemite";
			case 11:
				info->description = "OS X El Capitan";
			break;
			case 12:
				info->description = "macOS Sierra";
			break;
			case 13:
				info->description = "macOS High Sierra";
			break;
			case 14:
				info->description = "macOS Mojave";
			break;
			case 15:
				info->description = "macOS Catalina";
			break;
		}
	}

	return 1;
}


/*************************************************************/

#elif defined(PLATFORM_BSD) || defined(PLATFORM_LINUX) || defined(PLATFORM_SOLARIS) || defined(PLATFORM_HURD) || defined(PLATFORM_HAIKU)

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

