/**
 * \file   windows.c
 * \brief  Windows implementation of Premake platform abstraction.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "platform/platform.h"
#if defined(PLATFORM_WINDOWS)

#define WIN32_LEAN_AND_MEAN
#include <windows.h>


int platform_create_dir(const char* path)
{
	return CreateDirectory(path, NULL) ? OKAY : !OKAY;
}


int platform_dir_get_current(char* buffer, int size)
{
	DWORD result = GetCurrentDirectory(size, buffer);
	return (result != 0) ? OKAY : !OKAY;
}


int platform_dir_set_current(const char* path)
{
	DWORD result = SetCurrentDirectory(path);
	return (result != 0) ? OKAY : !OKAY;
}


#endif
