/**
 * \file   strings.c
 * \brief  A dynamic array of C strings.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"
#include "strings.h"
#include "base/array.h"

DEFINE_CLASS(Strings)
{
	Array contents;
};



/**
 * Create a new dynamic array of C strings.
 * \returns A new string array.
 */
Strings strings_create()
{
	Strings strs = ALLOC_CLASS(Strings);
	strs->contents = array_create();
	return strs;
}


/**
 * Create a dynamic array of C strings, initialized from an existing array.
 * \param   items  The initial list of items for the strings collection.
 * \returns A new string array.
 */
Strings strings_create_from_array(const char* items[])
{
	Strings strs = strings_create();
	for ( ; *items != NULL; ++items)
	{
		strings_add(strs, *items);
	}
	return strs;
}


/**
 * Destroy a strings array and free the associated memory.
 * \param   strs  The string array to destroy.
 */
void strings_destroy(Strings strs)
{
	array_destroy(strs->contents);
	free(strs);
}


/**
 * Add a new item to the end of an array of strings.
 * \param   strs  The array of strings.
 * \param   item  The C string item to add.
 */
void strings_add(Strings strs, const char* item)
{
	array_add(strs->contents, (void*)item);
}


/**
 * Append the contents of one string vector to another.
 * \param   dest    The destination vector.
 * \param   src     The source vector.
 */
void strings_append(Strings dest, Strings src)
{
	array_append(dest->contents, src->contents);
}


/**
 * Retrieve an C string item from an array of strings.
 * \param   strs   The string array to query.
 * \param   index  The index of the item to retrieve.
 * \returns A pointer to the C string item.
 */
const char* strings_item(Strings strs, int index)
{
	return (const char*)array_item(strs->contents, index);
}


/**
 * Set the value at a particular index of the array.
 * \param   strs   The string array.
 * \param   index  The index of the item to set.
 * \param   item   The new item.
 */
void strings_set(Strings strs, int index, const char* item)
{
	array_set(strs->contents, index, (void*)item);
}


/**
 * Get the number of items in the string array.
 * \param   strs   The string array to query.
 * \returns The number elements currently in the array.
 */
int strings_size(Strings strs)
{
	return array_size(strs->contents);
}

