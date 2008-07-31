/**
 * \file   cstr.c
 * \brief  C string handling.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <ctype.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include "premake.h"
#include "base/buffers.h"
#include "base/cstr.h"


/**
 * Determines if the sequence appears anywhere in the target string.
 * \param   str      The string to test.
 * \param   expected The sequence to search for.
 * \returns True if the sequence is contained in the string.
 */
int cstr_contains(const char* str, const char* expected)
{
	assert(str);
	assert(expected);
	return (strstr(str, expected) != NULL);
}


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
 * \returns True if the strings match, zero otherwise.
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
 * Performs a case-insensitive comparasion on two C strings for equality.
 * \param   str      The string to compare.
 * \param   expected The value to compare against.
 * \returns True if the strings match, zero otherwise.
 */
int cstr_eqi(const char* str, const char* expected)
{
	if (str != NULL && expected != NULL)
	{
		while (*str && *expected)
		{
			if (tolower(*str) != tolower(*expected))
			{
				return 0;
			}

			str++;
			expected++;
		}

		return (*str == *expected);
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


/**
 * Removes spaces any other special characters from a string, converting it
 * into a C/C++/C# safe identifier.
 * \param   str       The string to process.
 * \returns An identifier-safe string.
 */
char* cstr_to_identifier(const char* str)
{
	char* buffer = buffers_next();
	char* dst = buffer;

	while (*str != '\0')
	{
		if (isalnum(*str) || *str == '_')
		{
			*(dst++) = *str;
		}
		str++;
	}

	*dst = '\0';
	return buffer;
}


/**
 * Remove a character from the end of a string, if present.
 * \param   str       The string to trim.
 * \param   ch        The character to trim.
 */
void cstr_trim(char* str, char ch)
{
	int i;
	assert(str);
	i = strlen(str) - 1;
	while (i >= 0 && str[i] == ch)
	{
		str[i] = '\0';
		i--;
	}
}
