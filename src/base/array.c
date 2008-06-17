/**
 * \file   array.c
 * \brief  Dynamic array object.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include "premake.h"
#include "base/array.h"

#define INITIAL_SIZE  16

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
	arr->contents = (void**)malloc(sizeof(void*) * INITIAL_SIZE);
	arr->size = 0;
	arr->capacity = INITIAL_SIZE;
	return arr;
}


/**
 * Destroy an array object and release the associated memory.
 * \param arr  The array to destroy.
 */
void array_destroy(Array arr)
{
	free(arr->contents);
	free(arr);
}


/**
 * Get the number of item in the array.
 * \param   arr  The array to query.
 * \returns The number elements currently in the array.
 */
int array_size(Array arr)
{
	return arr->size;
}


/**
 * Add a new item to the end of the array, growing the array if necessary.
 * \param arr   The array object.
 * \param item  The item to add.
 */
void array_add(Array arr, void* item)
{
	if (arr->size == arr->capacity)
	{
		arr->capacity *= 2;
		arr->contents = (void**)realloc(arr->contents, arr->capacity);
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
	for (i = 0; i < src->size; ++i)
	{
		array_add(dest, src->contents[i]);
	}
}
