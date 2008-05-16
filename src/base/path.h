/**
 * \file   path.h
 * \brief  Path handling.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_PATH_H)
#define PREMAKE_PATH_H

char* path_absolute(const char* path);
char* path_assemble(const char* dir, const char* filename, const char* ext);
char* path_basename(const char* path);
char* path_directory(const char* path);
char* path_extension(const char* path);
char* path_filename(const char* path);
int   path_is_absolute(const char* path);
int   path_is_cpp_source(const char* path);
char* path_join(const char* leading, const char* trailing);
char* path_relative(const char* base, const char* target);
char* path_translate(const char* path, const char* sep);

#endif
