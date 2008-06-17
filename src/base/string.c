/**
 * \file   string.c
 * \brief  Dynamic string handling.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include <string.h>
#include "premake.h"
#include "base/string.h"


DEFINE_CLASS(String)
{
	char* contents;
	int capacity;
};


/**
 * Create a new dynamic string object from an existing C string.
 * \param   value   The C string value.
 * \returns A new dynamic string object containing a copy of the string.
 */
String string_create(const char* value)
{
	if (value != NULL)
	{
		String str = ALLOC_CLASS(String);
		str->capacity = strlen(value) + 1;
		str->contents = (char*)malloc(str->capacity);
		strcpy(str->contents, value);
		return str;
	}
	else
	{
		return NULL;
	}
}


/**
 * Destroy a dynamic string object and free the associated memory.
 * \param   str   The string to destroy.
 */
void string_destroy(String str)
{
	if (str != NULL)
	{
		free(str->contents);
		free(str);
	}
}


/**
 * Return the contents of a dynamic string as a C string.
 * \param   str   The string to query.
 * \returns The C string value.
 */
const char* string_cstr(String str)
{
	if (str != NULL)
		return str->contents;
	else
		return NULL;
}
