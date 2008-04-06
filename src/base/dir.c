/**
 * \file   dir.c
 * \brief  Directory handling.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <string.h>
#include <sys/stat.h>
#include "premake.h"
#include "base/buffers.h"
#include "base/error.h"
#include "base/dir.h"
#include "base/path.h"
#include "platform/platform.h"


/**
 * Create a directory, if it doesn't exist already.
 * \returns OKAY if successful.
 */
int dir_create(const char* path)
{
	char* parent;

	assert(path);

	if (dir_exists(path))
		return OKAY;

	/* make sure the parent directory exists */
	parent = path_directory(path);
	if (strlen(parent) > 0)
	{
		if (dir_create(parent) != OKAY)
			return !OKAY;
	}

	if (platform_create_dir(path) != OKAY)
	{
		error_set("Unable to create directory %s", path);
		return !OKAY;
	}

	return OKAY;
}


/**
 * Determine if a particular directory exists on the filesystem.
 * \returns True if the directory exists.
 */
int dir_exists(const char* path)
{
	struct stat buf;

	assert(path);

	/* empty path is equivalent to ".", must be true */
	if (strlen(path) == 0)
	{
		return 1;
	}

	if (stat(path, &buf) == 0)
	{
		return (buf.st_mode & S_IFDIR); 
	}
	else
	{
		return 0;
	}
}


/**
 * Get the current working directory.
 * \returns The current working directory, or NULL on error. Path separators 
 *          are converted to forward slashes, regardless of platform.
 */
char* dir_get_current()
{
	char* buffer = buffers_next();

	int result = platform_dir_get_current(buffer, BUFFER_SIZE);
	if (result == OKAY)
	{
		return path_translate(buffer, "/");
	}
	else
	{
		return NULL;
	}
}


/**
 * Set the current working directory.
 * \param   path    The new working directory.
 * \returns OKAY if successful.
 */
int dir_set_current(const char* path)
{
	assert(path);
	return platform_dir_set_current(path);
}
