/**
 * \file   platform.c
 * \brief  Platform abstraction API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include "premake.h"
#include "platform.h"

static enum Platform CurrentPlatform = Unknown;


enum Platform platform_get()
{
	if (CurrentPlatform == Unknown)
	{
#if defined(PLATFORM_BSD)
		CurrentPlatform = BSD;
#elif defined(PLATFORM_LINUX)
		CurrentPlatform = Linux;
#elif defined(PLATFORM_MACOSX)
		CurrentPlatform = MacOSX;
#else
		CurrentPlatform = Windows;
#endif
	}
	return CurrentPlatform;
}


const char* platform_get_name(void)
{
	enum Platform id = platform_get();
	switch (id)
	{
	case BSD:
		return "BSD";
	case Linux:
		return "Linux";
	case MacOSX:
		return "MacOSX";
	case Windows:
		return "Windows";
	default:
		assert(0);
		return 0;
	}
}


void platform_set(enum Platform id)
{
	CurrentPlatform = id;
}
