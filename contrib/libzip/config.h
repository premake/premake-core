#ifndef HAD_CONFIG_H
#define HAD_CONFIG_H
#ifndef _HAD_ZIPCONF_H
#include "zipconf.h"
#endif
/* BEGIN DEFINES */
#define HAVE__CLOSE
#define HAVE__DUP
#define HAVE__FDOPEN
#define HAVE__FILENO
#define HAVE__OPEN
#define HAVE__SNPRINTF
#define HAVE__STRDUP
#define HAVE__STRICMP
/* #undef HAVE_FSEEKO */
/* #undef HAVE_FTELLO */
#define HAVE_OPEN
/* #undef HAVE_MKSTEMP */
/* #undef HAVE_SNPRINTF */
/* #undef HAVE_STRCASECMP */
#define HAVE_STRDUP
/* #undef HAVE_STRUCT_TM_TM_ZONE */
#ifdef _WIN32
#define HAVE_MOVEFILEEXA
#endif
/* #undef HAVE_STRINGS_H */
/* #undef HAVE_UNISTD_H */
#define __INT8_LIBZIP 1
#define INT8_T_LIBZIP 1
#define UINT8_T_LIBZIP 1
#define __INT16_LIBZIP 2
#define INT16_T_LIBZIP 2
#define UINT16_T_LIBZIP 2
#define __INT32_LIBZIP 4
#define INT32_T_LIBZIP 4
#define UINT32_T_LIBZIP 4
#define __INT64_LIBZIP 8
#define INT64_T_LIBZIP 8
#define UINT64_T_LIBZIP 8
#define SIZEOF_OFF_T 4
#define SIZE_T_LIBZIP 8
/* #undef SSIZE_T_LIBZIP */
/* END DEFINES */
#define PACKAGE "libzip"
#define VERSION "0.11.2"

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
