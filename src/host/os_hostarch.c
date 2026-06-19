/**
 * \file   os_hostarch.c
 * \brief  Get the architecture for the current host OS we're executing on.
 * \author Copyright (c) 2014-2024 Jess Perkins and the Premake project
 */

#include "premake.h"
#include <string.h>

#if !PLATFORM_WINDOWS
#include <sys/utsname.h>
#endif

#if PLATFORM_MACOSX
#include <sys/sysctl.h>
#endif


#if PLATFORM_WINDOWS

static const char* os_hostarch_detect(void)
{
	/* Try IsWow64Process2 first (Windows 10 1511+): gives true native machine type
	 * even when running a 32-bit on a 64-bit host, or a 64-bit on a ARM64 host. */
	typedef BOOL (WINAPI *PFN_ISWOW64PROCESS2)(HANDLE, USHORT*, USHORT*);
	PFN_ISWOW64PROCESS2 fnIsWow64Process2 =
	    (PFN_ISWOW64PROCESS2)(void*)GetProcAddress(
	        GetModuleHandleA("kernel32"), "IsWow64Process2");

	if (fnIsWow64Process2)
	{
		USHORT processMachine = 0;
		USHORT nativeMachine  = 0;
		if (fnIsWow64Process2(GetCurrentProcess(), &processMachine, &nativeMachine))
		{
			switch (nativeMachine)
			{
				case IMAGE_FILE_MACHINE_AMD64: return "x86_64";
				case IMAGE_FILE_MACHINE_I386:  return "x86";
				case IMAGE_FILE_MACHINE_ARM64: return "ARM64";
				case IMAGE_FILE_MACHINE_ARMNT: return "ARM";
				default:     break;
			}
		}
	}

	// Fall back to GetNativeSystemInfo (available since Windows XP)
	{
		SYSTEM_INFO si;
		GetNativeSystemInfo(&si);
		switch (si.wProcessorArchitecture)
		{
			case PROCESSOR_ARCHITECTURE_AMD64: return "x86_64";
			case PROCESSOR_ARCHITECTURE_INTEL: return "x86";
			case PROCESSOR_ARCHITECTURE_ARM64: return "ARM64";
			case PROCESSOR_ARCHITECTURE_ARM:   return "ARM";
			default: break;
		}
	}

	return PLATFORM_ARCHITECTURE;
}

#elif PLATFORM_MACOSX

static const char* os_hostarch_detect(void)
{
	// hw.optional.arm64 == 1 on Apple Silicon (including Rosetta 2 processes)
	int arm64 = 0;
	size_t size = sizeof(arm64);
	if (sysctlbyname("hw.optional.arm64", &arm64, &size, NULL, 0) == 0 && arm64)
		return "ARM64";

	// hw.machine reports the native CPU type string
	char machine[64];
	size = sizeof(machine) - 1;
	if (sysctlbyname("hw.machine", machine, &size, NULL, 0) == 0)
	{
		machine[size] = '\0';
		if (strncmp(machine, "arm64",  5) == 0) return "ARM64";
		if (strncmp(machine, "x86_64", 6) == 0) return "x86_64";
		if (strncmp(machine, "i386",   4) == 0) return "x86";
		// not sure whether the following are really working, but try to detect them just in case
		if (strncmp(machine, "ppc64",  5) == 0) return "ppc64";
		if (strncmp(machine, "ppc",    3) == 0) return "ppc";
	}

	/* uname reports the architecture of the current process, which may be running under
	 * Rosetta 2 translation on Apple Silicon, but is better than nothing. */
	{
		struct utsname u;
		if (uname(&u) == 0)
		{
			if (strcmp(u.machine, "arm64")  == 0) return "ARM64";
			if (strcmp(u.machine, "x86_64") == 0) return "x86_64";
			if (strcmp(u.machine, "i386")   == 0) return "x86";
		}
	}

	return PLATFORM_ARCHITECTURE;
}

#else // All other POSIX platforms (Linux, BSD, Haiku, Solaris, AIX, …)

static const char* os_hostarch_detect(void)
{
	struct utsname u;
	if (uname(&u) == 0)
	{
		const char* m = u.machine;
		if (strcmp(m, "x86_64")    == 0 || strcmp(m, "amd64")    == 0) return "x86_64";
		if (strcmp(m, "i386")      == 0 || strcmp(m, "i686")     == 0) return "x86";
		if (strcmp(m, "aarch64")   == 0 || strcmp(m, "arm64")    == 0) return "ARM64";
		if (strcmp(m, "arm")       == 0 || strncmp(m, "armv", 4) == 0) return "ARM";
		if (strcmp(m, "riscv64")   == 0)                               return "RISCV64";
		if (strcmp(m, "loongarch64") == 0)                             return "loongarch64";
		if (strcmp(m, "e2k")       == 0)                               return "e2k";
		if (strcmp(m, "ppc64le")   == 0 || strcmp(m, "ppc64")    == 0) return "ppc64";
		if (strcmp(m, "ppc")       == 0)                               return "ppc";
		if (strcmp(m, "mips64el")  == 0)                               return "mips64el";
	}

	return PLATFORM_ARCHITECTURE;
}

#endif


int os_hostarch(lua_State* L)
{
	lua_pushstring(L, os_hostarch_detect());
	return 1;
}
