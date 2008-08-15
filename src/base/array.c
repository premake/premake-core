/**
 * \file   array.c
 * \brief  Dynamic array object.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include "premake.h"
#include "base/array.h"

#define ALLOCATION_SIZE  (16)

DEFINE_CLASS(Array)
{
	void** contents;
	int    size;
	int    capacity;
};


/**
 * Create a new, empty array object.
 * \returns A new array object.
 */
Array array_create()
{
	Array arr = ALLOC_CLASS(Array);
	arr->contents = NULL;
	arr->size = 0;
	arr->capacity = 0;
	return arr;
}


/**
 * Destroy an array object and release the associated memory.
 * \param arr  The array to destroy.
 */
void array_destroy(Array arr)
{
	assert(arr);
	if (arr->contents != NULL)
	{
		free(arr->contents);
	}
	free(arr);
}


/**
 * Get the number of item in the array.
 * \param   arr  The array to query.
 * \returns The number elements currently in the array.
 */
int array_size(Array arr)
{
	assert(arr);
	return arr->size;
}


/**
 * Add a new item to the end of the array, growing the array if necessary.
 * \param arr   The array object.
 * \param item  The item to add.
 */
void array_add(Array arr, void* item)
{
	assert(arr);
	assert(item);
	if (arr->size == arr->capacity)
	{
		arr->capacity += ALLOCATION_SIZE;
		arr->contents = (void**)realloc(arr->contents, sizeof(void*) * arr->capacity);
	}

	arr->contents[arr->size] = item;
	arr->size++;
}


/**
 * Retrieve the item at the specified index in the array.
 * \param   arr   The array to query.
 * \param   index The index of the item to retrieve.
 * \returns A pointer to the item.
 */
void* array_item(Array arr, int index)
{
	assert(arr);
	assert((index >= 0 && index < arr->size) || (index == 0 && arr->size == 0));
	return arr->contents[index];
}


/**
 * Store an item at a particular index in the array, overwriting any existing value.
 * \param   arr    The array.
 * \param   index  The index at which to store the item
 * \param   item   The new item.
 */
void array_set(Array arr, int index, void* item)
{
	assert(arr);
	assert(index >= 0 && index < arr->size);
	arr->contents[index] = item;
}


/**
 * Append the contents of one array to another.
 * \param   dest    The destination array.
 * \param   src     The source array.
 */
void array_append(Array dest, Array src)
{
	int i;

	assert(dest);
	assert(src);

	for (i = 0; i < src->size; ++i)
	{
		array_add(dest, src->contents[i]);
	}
}
