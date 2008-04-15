/**
 * \file   platform.h
 * \brief  Platform abstraction API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */
#if !defined(PREMAKE_PLATFORM_H)
#define PREMAKE_PLATFORM_H


/* Determine the current OS. I'm not sure how to reliably detect Windows
 * but since it is the most common I use it as the default */
#if defined(__linux__)
#define PLATFORM_LINUX 1
#elif defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__)
#define PLATFORM_BSD 1
#elif defined(__APPLE__) && defined(__MACH__)
#define PLATFORM_MACOSX 1
#else
#define PLATFORM_WINDOWS 1
#endif


/**
 * Create a directory, if it doesn't exist already.
 * \returns OKAY if successful.
 */
int platform_create_dir(const char* path);


/**
 * Create a GUID and copy it into the supplied buffer.
 * \param buffer  The buffer to hold the new GUID; must hold at least 36 characters.
 */
void platform_create_guid(char* buffer);


/**
 * Get the current working directory.
 * \param   buffer    A buffer to hold the directory.
 * \param   size      The size of the buffer.
 * \returns OKAY if successful.
 */
int platform_dir_get_current(char* buffer, int size);


/**
 * Set the current working directory.
 * \param   path   The new working directory.
 * \returns OKAY if successful.
 */
int platform_dir_set_current(const char* path);


#endif
