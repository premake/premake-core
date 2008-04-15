/**
 * \file   posix.c
 * \brief  POSIX implementation of Premake platform abstraction.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "platform/platform.h"
#if !defined(PLATFORM_WINDOWS)

#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <dirent.h>
#include <fnmatch.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <ctype.h>


int platform_create_dir(const char* path)
{
	return mkdir(path, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
}


void platform_create_guid(char* buffer)
{
	/* not sure how to get a UUID here, so I fake it */
	FILE* rnd = fopen("/dev/random", "rb");
	fread(buffer, 16, 1, rnd);
	fclose(rnd);
}


int platform_dir_get_current(char* buffer, int size)
{
	char* result = getcwd(buffer, size);
	return (result != NULL) ? OKAY : !OKAY;
}


int platform_dir_set_current(const char* path)
{
	return chdir(path);
}


#endif

