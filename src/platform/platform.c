/**
 * \file   platform.c
 * \brief  Platform abstraction API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

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


void platform_set(enum Platform id)
{
	CurrentPlatform = id;
}
