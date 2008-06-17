/**
 * \file   path.c
 * \brief  Path handling.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "premake.h"
#include "base/path.h"
#include "platform/platform.h"
#include "base/buffers.h"
#include "base/cstr.h"
#include "base/dir.h"

static char* CppFileExtensions[] = { ".cc", ".cpp", ".cxx", ".c", ".s", NULL };


/**
 * Create an absolute path from a relative one.
 * \param   path      The relative path to convert.
 * \returns An absolute version of the relative path.
 */
char* path_absolute(const char* path)
{
	char* source;
	char* result;

	assert(path);

	/* normalize the target path */
	source = path_translate(path, "/");
	if (strlen(source) == 0)
		strcpy(source, ".");

	/* If the directory is already absolute I don't have to do anything */
	if (path_is_absolute(source))
		return source;

	/* start from the current location */
	result = dir_get_current();

	/* split up the supplied relative path and tackle it bit by bit */
	while (source)
	{
		char* end = strchr(source, '/');
		if (end)
			*end = 0;

		if (cstr_eq(source, ".."))
		{
			char* up = strrchr(result, '/');
			if (up)
				*up = 0;
		}
		else if (!cstr_eq(source, "."))
		{
			strcat(result, "/");
			strcat(result, source);
		}

		source = end ? end + 1 : NULL;
	}

	return result;
}


/**
 * Assemble a complete file path from its component parts.
 * \param   dir       The directory portion of the path.
 * \param   filename  The file name portion of the path.
 * \param   ext       The extension portion of the path.
 * \returns The assembled file path.
 */
char* path_assemble(const char* dir, const char* filename, const char* ext)
{
	char* buffer;

	assert(dir);
	assert(filename);
	assert(ext);
	
	buffer = path_join(dir, filename);
	if (ext)
	{
		strcat(buffer, ext);
	}
	return buffer;
}


/**
 * Returns the base name in a path: the filename, without the directory or
 * file extension.
 * \param   path     The path to split.
 * \returns The base name part of the path.
 */
char* path_basename(const char* path)
{
	char* buffer = path_filename(path);
	char* ptr = strrchr(buffer, '.');
	if (ptr)
	{
		*ptr = '\0';
	}
	return buffer;
}


/**
 * Retrieve the directory portion of a path.
 * \param   path  The path to split.
 * \returns The directory portion of the path. Returns an empty string ("") if
 *          the path does not contain any directory information.
 */
char* path_directory(const char* path)
{
	char* ptr;
	char* buffer = buffers_next();
	
	assert(path);
	strcpy(buffer, path);
	
	ptr = strrchr(buffer, '/');
	if (ptr)
		*ptr = '\0';
	else
		*buffer = '\0';

	return buffer;
}


/**
 * Retrieve the file extension portion of a path. If the path has multiple
 * dots in the filename (ie. filename.my.ext) only the last bit (.ext) will
 * be returned. The dot is included in the extension.
 * \param   path    The path to split.
 * \returns The extension portion of the path, or an empty string if no extension is present.
 */
char* path_extension(const char* path)
{
	char* ptr;
	char* buffer = buffers_next();

	assert(path);
	strcpy(buffer, path);
	ptr = strrchr(buffer, '.');
	return (ptr) ? ptr : "";
}


/**
 * Retrieve the fileame (filename.ext) portion of a path.
 * \param   path      The path to split.
 * \returns The filename portion of the path. Returns an empty string ("") if
 *          the path is empty.
 */
char* path_filename(const char* path)
{
	char* ptr;
	char* buffer = buffers_next();

	assert(path);

	ptr = strrchr(path, '/');
	if (ptr)
	{
		strcpy(buffer, ptr + 1);
	}
	else
	{
		strcpy(buffer, path);
	}

	return buffer;
}


/**
 * Determine is a path is absolute (rooted at base of filesystem).
 * \param   path      The path to check.
 * \returns True if the path is absolute.
 */
int path_is_absolute(const char* path)
{
	assert(path);

	if (path[0] == '/' || path[0] == '\\')
		return 1;
	if (path[1] == ':')
		return 1;
	return 0;
}


/**
 * Returns true if the path represents a C++ source code file; by checking
 * the file extension.
 * \param   path      The path to check.
 * \returns True if the path uses a known C++ file extension.
 */
int path_is_cpp_source(const char* path)
{
	int i;

	char* ext = path_extension(path);
	if (cstr_eq(ext, ""))
	{
		return 0;
	}

	for (i = 0; CppFileExtensions[i] != NULL; ++i)
	{
		if (cstr_eqi(CppFileExtensions[i], ext))
			return 1;
	}

	return 0;
}


/**
 * Join two paths togethers.
 * \param   leading   The leading path.
 * \param   trailing  The trailing path.
 * \returns A unified path.
 * \note If the trailing path is absolute, that will be the return value.
 *       A join is only performed if the trailing path is relative.
 */
char* path_join(const char* leading, const char* trailing)
{
	char* buffer = buffers_next();
	
	/* treat nulls like empty paths */
	leading = (leading != NULL) ? leading : "";
	trailing = (trailing != NULL) ? trailing : "";

	if (!trailing)
	{
		strcpy(buffer, leading);
		return buffer;
	}

	if (!leading || path_is_absolute(trailing))
	{
		strcpy(buffer, trailing);
		return buffer;
	}

	if (leading)
	{
		strcat(buffer, leading);
	}

	if (strlen(buffer) > 0 && !cstr_ends_with(buffer, "/"))
	{
		strcat(buffer, "/");
	}
		
	strcat(buffer, trailing);
	return buffer;
}


/**
 * \brief   Compute the relative path between two locations.
 * \param   base    The base path.
 * \param   target  The target path.
 * \returns A relative path from the base to the target.
 */
char* path_relative(const char* base, const char* target)
{
	int start, i;
	char* result;

	/* normalize the two paths */
	char* full_base = path_absolute(base);
	char* full_targ = path_absolute(target);

	strcat(full_base, "/");
	strcat(full_targ, "/");

	/* trim off the common directories from the start */
	for (start = 0, i = 0; full_base[i] && full_targ[i] && full_base[i] == full_targ[i]; ++i)
	{
		if (full_base[i] == '/')
			start = i + 1;
	}

	/* same directory? */
	if (full_base[i] == 0 && full_targ[i] == 0)
		return ".";

	/* build a connecting path */
	result = buffers_next();
	if (strlen(full_base) - start > 0)
	{
		strcpy(result, "../");
		for (i = start; full_base[i]; ++i)
		{
			if (full_base[i] == '/' && full_base[i + 1])
				strcat(result, "../");
		}
	}

	if (strlen(full_targ) - start > 0)
	{
		strcat(result, full_targ + start);
	}

	/* remove the trailing slash */
	result[strlen(result) - 1] = 0;

	if (strlen(result) == 0)
		strcpy(result, ".");
	return result;
}


/**
 * Replace all path separator characters in a path.
 * \param   path    The path to translate.
 * \param   sep     The desired separator, or NULL for the platform's native separator.
 * \returns The translated path.
 */
char* path_translate(const char* path, const char* sep)
{
	char* ptr;
	char* buffer;

	assert(path);

	buffer = buffers_next();
	if (sep == NULL)
	{
#if defined(PLATFORM_WINDOWS)
		sep = "\\";
#else
		sep = "/";
#endif
	}

	strcpy(buffer, path);
	for (ptr = buffer; *ptr; ++ptr)
	{
		if (*ptr == '/' || *ptr == '\\')
			*ptr = *sep;
	}

	return buffer;
}
