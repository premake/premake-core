/**
 * \file   string.h
 * \brief  Dynamic string handling.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_STRING_H)
#define PREMAKE_STRING_H

DECLARE_CLASS(string);

string      string_create(const char* value);
void        string_destroy(string str);
const char* string_cstr(string str);

#endif
