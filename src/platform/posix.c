/**
 * \file   posix.c
 * \brief  POSIX implementation of Premake platform abstraction.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "platform/platform.h"
#include "base/path.h"
#include "base/string.h"

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

DEFINE_CLASS(PlatformSearch)
{
	String directory;
	String mask;
	DIR* handle;
	struct dirent* entry;
};


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


PlatformSearch platform_search_create(const char* mask)
{
	PlatformSearch search;
	const char* dir;

	dir  = path_directory(mask);
	mask = path_filename(mask);
	if (strlen(dir) == 0)
	{
		dir = ".";
	}

	search = ALLOC_CLASS(PlatformSearch);
	search->directory = string_create(dir);
	search->mask      = string_create(mask);
	search->handle    = opendir(dir);
	search->entry     = NULL;
	return search;
}


void platform_search_destroy(PlatformSearch search)
{
	if (search->handle != NULL)
	{
		closedir(search->handle);
	}
	free(search);
}


const char* platform_search_get_name(PlatformSearch search)
{
	return search->entry->d_name;
}


int platform_search_is_file(PlatformSearch search)
{
	struct stat info;
	
	const char* dir = string_cstr(search->directory);
	const char* path = path_join(dir, search->entry->d_name);
	if (stat(path, &info) == 0)
	{
		return S_ISREG(info.st_mode);
	}

	return 0;
}


int platform_search_next(PlatformSearch search)
{
	const char* mask = string_cstr(search->mask);

	if (search->handle == NULL)
	{
		return 0;
	}

	search->entry = readdir(search->handle);
	while (search->entry != NULL)
	{
		if (fnmatch(mask, search->entry->d_name, 0) == 0)
		{
			return 1;
		}
		search->entry = readdir(search->handle);
	}

	return 0;
}

#endif

