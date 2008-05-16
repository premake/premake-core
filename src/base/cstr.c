/**
 * \file   cstr.c
 * \brief  C string handling.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include "premake.h"
#include "base/buffers.h"
#include "base/cstr.h"


/**
 * Determines if the string ends with a particular sequence.
 * \param str        The string to test.
 * \param expected   The sequence for which to look.
 * \returns True if the string ends with the sequence, false otherwise.
 */
int cstr_ends_with(const char* str, const char* expected)
{
	if (str != NULL && expected != NULL)
	{
		int str_len = strlen(str);
		int exp_len = strlen(expected);
		if (str_len >= exp_len)
		{
			const char* start = str + str_len - exp_len;
			return (strcmp(start, expected) == 0);
		}
	}
	return 0;
}


/**
 * Compares two C strings for equality.
 * \param   str        The string to compare.
 * \param   expected   The value to compare against.
 * \returns Nonzero if the strings match, zero otherwise.
 */
int cstr_eq(const char* str, const char* expected)
{
	if (str != NULL && expected != NULL)
	{
		return (strcmp(str, expected) == 0);
	}
	return 0;
}


/**
 * Builds a string using printf-style formatting codes.
 * \param   format   The format string, which may contain printf-style formatting codes.
 * \returns The formatted string.
 */
char* cstr_format(const char* format, ...)
{
	va_list args;
	char* buffer = buffers_next();

	va_start(args, format);
	vsprintf(buffer, format, args);
	va_end(args);

	return buffer;
}


/**
 * Determines if the given C string starts with a particular sequence.
 * \param   str        The string to test.
 * \param   expected   The sequence for which to look.
 * \returns True if the string starts with the sequence, false otherwise.
 */
int cstr_starts_with(const char* str, const char* expected)
{
	if (str != NULL && expected != NULL)
	{
		return (strncmp(str, expected, strlen(expected)) == 0);
	}
	return 0;
}
