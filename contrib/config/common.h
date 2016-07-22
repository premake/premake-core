#ifndef PREMAKE_COMMON_CONFIG_H
#define PREMAKE_COMMON_CONFIG_H

/* ===================================== */
/*    VISUAL STUDIO                      */
/* ===================================== */
#if defined(_MSC_VER)
#  if defined(_M_X64) || defined(_WIN64)
#    define PREMAKE_SIZE_T           8
#  else
#    define PREMAKE_SIZE_T           4
#  endif

/* ===================================== */
/*    KEEP GENERIC GCC THE LAST ENTRY    */
/* ===================================== */
#elif defined(__GNUC__)
#  if defined(__ILP32__) || defined(__i386__) || defined(__ppc__) || defined(__arm__) || defined(__sparc__)
#    define PREMAKE_SIZE_T           4
#  elif defined(__LP64__) || defined(__x86_64__) || defined(__ppc64__) || defined(__sparc64__)
#    define PREMAKE_SIZE_T           8
#  endif
#else
#  error "Unknown non-configure build target!"
Error Compilation_aborted_Unknown_non_configure_build_target
#endif

#endif
