/**
 * \file   os_host.c
 * \brief  Get the current host OS we're executing on.
 * \author Copyright (c) 2014-2017 Tom van Dijck, Jason Perkins and the Premake project
 */

#include "premake.h"

#if PLATFORM_COSMO
#include <cosmo.h>
#include <assert.h>
#endif

static const char* host_os()
{
#if PLATFORM_COSMO
	if (IsLinux()) { return "linux"; }
	else if (IsWindows()) { return "windows"; }
	else if (IsXnu()) { return "macosx"; }
	else if (IsBsd()) { return "bsd"; }
	else
	{
		assert(0 && "Platform is unknown to Cosmopolitan Libc");
		return 0;
	}
#else
	return PLATFORM_OS;
#endif
}

int os_host(lua_State* L)
{
	lua_pushstring(L, host_os());
	return 1;
}
