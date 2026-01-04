/**
 * \file   os_getnumcpus.c
 * \brief  Retrieve the logical number of CPUs of the host system.
 * \author Copyright (c) 2002-2024 Jess Perkins and the Premake project
 */

#if __linux__
#define _GNU_SOURCE
#endif

#include "premake.h"

#if PLATFORM_LINUX | PLATFORM_COSMO
#include <sched.h>
#elif PLATFORM_AIX | PLATFORM_MACOSX | PLATFORM_BSD
#include <sys/sysctl.h>
#elif PLATFORM_SOLARIS
#include <unistd.h>
#elif PLATFORM_WINDOWS
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif

int do_getnumcpus()
{
#if PLATFORM_WINDOWS
	SYSTEM_INFO sysinfo;
	GetSystemInfo(&sysinfo);
	return sysinfo.dwNumberOfProcessors;
#elif PLATFORM_LINUX | PLATFORM_COSMO
	cpu_set_t set;
	int count, i;

	if (sched_getaffinity(0, sizeof(cpu_set_t), &set) != -1)
	{
		count = 0;
		for (i = 0; i < CPU_SETSIZE; i++)
		{
			if (CPU_ISSET(i, &set))
			{
				count++;
			}
		}

		return count;
	}
	else
	{
		return 0;
	}
#elif PLATFORM_SOLARIS | PLATFORM_AIX | PLATFORM_MACOSX | PLATFORM_BSD | PLATFORM_HURD
	return sysconf(_SC_NPROCESSORS_ONLN);
#else
	#warning do_getnumcpus is not implemented for your platform yet
	return 0;
#endif
}

int os_getnumcpus(lua_State* L)
{
	int result = do_getnumcpus();
	if (result > 0)
	{
		lua_pushinteger(L, result);
		return 1;
	}
	else
	{
		return 0;
	}
}

