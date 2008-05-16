/**
 * \file   cstr.h
 * \brief  C string handling.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_CSTR_H)
#define PREMAKE_CSTR_H

int   cstr_ends_with(const char* str, const char* expected);
int   cstr_eq(const char* str, const char* expected);
char* cstr_format(const char* format, ...);
int   cstr_starts_with(const char* str, const char* expected);

#endif
