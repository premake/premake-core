/**
 * \file   os_is64bit.c
 * \brief  Native code-side checking for a 64-bit architecture.
 * \author Copyright (c) 2011 Jess Perkins and the Premake project
 */

#include "premake.h"
#if defined(PLATFORM_MACOSX) || defined(PLATFORM_BSD) || defined(PLATFORM_LINUX) || defined(PLATFORM_SOLARIS) || defined(PLATFORM_HURD) || defined(PLATFORM_HAIKU) || defined(PLATFORM_COSMO)

#if !defined(HAVE_UNAME)
#define HAVE_UNAME 1
#endif
#include <sys/utsname.h>
#include <string.h>

#else

#define HAVE_UNAME 0

#endif

int os_is64bit(lua_State* L)
{
	// If this code returns true, then the platform is 64-bit. If it
	// returns false, the platform might still be 64-bit, but more
	// checking will need to be done on the Lua side of things.
#if PLATFORM_WINDOWS
	typedef BOOL (WINAPI* WowFuncSig)(HANDLE, PBOOL);
	WowFuncSig func = (WowFuncSig)GetProcAddress(GetModuleHandle(TEXT("kernel32")), "IsWow64Process");
	if (func)
	{
		BOOL isWow = FALSE;
		if (func(GetCurrentProcess(), &isWow))
		{
			lua_pushboolean(L, isWow);
			return 1;
		}
	}
#endif
#if HAVE_UNAME
	struct utsname data;
	if (uname(&data) >= 0)
	{
		// Non-exhaustive list of 64bit architectures reported by uname -m
		static const char *knownArchitectures[] = {
				"x86_64", "adm64",
				"arm64", "aarch64",
				"ppc64", "ppc64le",
				"s390x",
				"mips64", "mips64el",
				"riscv64",
				"longarch64"
		};
		for (size_t a = 0; a < (sizeof(knownArchitectures) / sizeof(const char *)); ++a)
		{
			if (strcmp(data.machine, knownArchitectures[a]) == 0)
			{
				lua_pushboolean(L, 1);
				return 1;
			}
		}
	}
#endif

	lua_pushboolean(L, 0);
	return 1;
}
