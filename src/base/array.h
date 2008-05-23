/**
 * \file   array.h
 * \brief  Dynamic array object.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 *
 * \defgroup array Array
 * \ingroup  base
 *
 * A dynamic array class.
 *
 * @{
 */
#if !defined(PREMAKE_ARRAY_H)
#define PREMAKE_ARRAY_H

DECLARE_CLASS(Array);

Array array_create(void);
void  array_destroy(Array arr);
int   array_size(Array arr);
void  array_add(Array arr, void* item);
void* array_item(Array arr, int index);
void  array_set(Array arr, int index, void* item);
void  array_append(Array dest, Array src);

#endif
/** @} */
