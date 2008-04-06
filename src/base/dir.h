/**
 * \file   dir.h
 * \brief  Directory handling.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_DIR_H)
#define PREMAKE_DIR_H

int   dir_create(const char* path);
int   dir_exists(const char* path);
char* dir_get_current(void);
int   dir_set_current(const char* path);

#endif
