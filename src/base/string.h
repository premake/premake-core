/**
 * \file   string.h
 * \brief  Dynamic string handling.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 *
 * \defgroup string Strings
 * \ingroup  base
 *
 * A dynamic string class.
 *
 * @{
 */
#if !defined(PREMAKE_STRING_H)
#define PREMAKE_STRING_H

DECLARE_CLASS(String);

String      string_create(const char* value);
void        string_destroy(String str);
const char* string_cstr(String str);

#endif
/** @} */
