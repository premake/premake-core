#ifndef HAD_CONFIG_H
#define HAD_CONFIG_H

#include "../common.h"
#include "zipconf.h"


#define HAVE_FILENO
#define HAVE_FSEEKO
#define HAVE_FTELLO
#define HAVE_OPEN
#define HAVE_MKSTEMP
#define HAVE_SNPRINTF
#define HAVE_SSIZE_T_LIBZIP
#define HAVE_STRDUP
#define HAVE_STDBOOL_H

#ifndef _WIN32
	#define HAVE_STRINGS_H
	#define HAVE_UNISTD_H
	#define HAVE_STRCASECMP
#else
	#define HAVE__STRICMP
#endif


#define INT8_T_LIBZIP		1
#define UINT8_T_LIBZIP		1
#define INT16_T_LIBZIP		2
#define UINT16_T_LIBZIP		2
#define INT32_T_LIBZIP		4
#define UINT32_T_LIBZIP		4
#define INT64_T_LIBZIP		8
#define UINT64_T_LIBZIP		8

#define SIZEOF_OFF_T		8
#define SIZE_T_LIBZIP		PREMAKE_SIZE_T
#define SSIZE_T_LIBZIP		PREMAKE_SIZE_T

#define PACKAGE "libzip"
#define VERSION "1.1.3"

#ifndef HAVE_SSIZE_T_LIBZIP
#  if SIZE_T_LIBZIP == INT_LIBZIP
typedef int ssize_t;
#  elif SIZE_T_LIBZIP == LONG_LIBZIP
typedef long ssize_t;
#  elif SIZE_T_LIBZIP == LONG_LONG_LIBZIP
typedef long long ssize_t;
#  else
#error no suitable type for ssize_t found
#  endif
#endif

#endif /* HAD_CONFIG_H */
