/**
 * \file   strings.h
 * \brief  A dynamic array of C strings.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 *
 * \defgroup strings String Collection
 * \ingroup  base
 *
 * A dynamic array of C strings.
 *
 * @{
 */
#if !defined(PREMAKE_STRINGS_H)
#define PREMAKE_STRINGS_H

DECLARE_CLASS(Strings);

Strings     strings_create(void);
Strings     strings_create_from_array(const char** items);
void        strings_destroy(Strings strs);

void        strings_add(Strings strs, const char* item);
void        strings_append(Strings dest, Strings src);
int         strings_contains(Strings strs, const char* item);
const char* strings_item(Strings strs, int index);
void        strings_set(Strings strs, int index, const char* item);
int         strings_size(Strings strs);

#endif
/** @} */
