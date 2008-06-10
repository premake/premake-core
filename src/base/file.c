/**
 * \file   file.c
 * \brief  File handling.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <sys/stat.h>
#include "premake.h"
#include "base.h"


/**
 * Determine if a particular file exists on the filesystem.
 * \returns True if the file exists.
 */
int file_exists(const char* path)
{
	struct stat buf;

	assert(path);

	if (stat(path, &buf) == 0)
	{
		return ((buf.st_mode & S_IFDIR) == 0);
	}
	else
	{
		return 0;
	}
}
