/**
 * \file   premake.h
 * \brief  Program-wide constants and definitions.
 * \author Copyright (c) 2002-2013 Jason Perkins and the Premake project
 */

#define lua_c
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"


/* Identify the current platform I'm not sure how to reliably detect
 * Windows but since it is the most common I use it as the default */
#if defined(__linux__)
#define PLATFORM_LINUX    (1)
#define PLATFORM_STRING   "linux"
#elif defined(__FreeBSD__) || defined(__FreeBSD_kernel__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__DragonFly__)
#define PLATFORM_BSD      (1)
#define PLATFORM_STRING   "bsd"
#elif defined(__APPLE__) && defined(__MACH__)
#define PLATFORM_MACOSX   (1)
#define PLATFORM_STRING   "macosx"
#elif defined(__sun__) && defined(__svr4__)
#define PLATFORM_SOLARIS  (1)
#define PLATFORM_STRING   "solaris"
#elif defined(__HAIKU__)
#define PLATFORM_HAIKU    (1)
#define PLATFORM_STRING   "haiku"
#elif defined (_AIX)
#define PLATFORM_AIX  (1)
#define PLATFORM_STRING  "aix"
#elif defined (__GNU__)
#define PLATFORM_HURD  (1)
#define PLATFORM_STRING  "hurd"
#else
#define PLATFORM_WINDOWS  (1)
#define PLATFORM_STRING   "windows"
#endif


/* Pull in platform-specific headers required by built-in functions */
#if PLATFORM_WINDOWS
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#else
#include <unistd.h>
#endif


/* A success return code */
#define OKAY   (0)


/* Bootstrapping helper functions */
unsigned long do_hash(const char* str, int seed);
int do_getcwd(char* buffer, size_t size);
int do_isabsolute(const char* path);
int do_isfile(const char* filename);
void do_translate(char* value, const char sep);


/* Built-in functions */
int path_getabsolute(lua_State* L);
int path_getrelative(lua_State* L);
int path_isabsolute(lua_State* L);
int path_join(lua_State* L);
int path_translate(lua_State* L);
int os_chdir(lua_State* L);
int os_copyfile(lua_State* L);
int os_getcwd(lua_State* L);
int os_getversion(lua_State* L);
int os_is64bit(lua_State* L);
int os_isdir(lua_State* L);
int os_isfile(lua_State* L);
int os_matchdone(lua_State* L);
int os_matchisfile(lua_State* L);
int os_matchname(lua_State* L);
int os_matchnext(lua_State* L);
int os_matchstart(lua_State* L);
int os_mkdir(lua_State* L);
int os_pathsearch(lua_State* L);
int os_rmdir(lua_State* L);
int os_stat(lua_State* L);
int os_uuid(lua_State* L);
int string_endswith(lua_State* L);
int string_hash(lua_State* L);

/* Engine interface */
int premake_init(lua_State* L);
int premake_locate(lua_State* L, const char* argv0);
int premake_execute(lua_State* L, int argc, const char** argv);
