/**
 * \file   platform.h
 * \brief  Platform abstraction API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 *
 * \defgroup platform Platform
 *
 * Platform abstraction; primarily file system and directory management. 
 *
 * @{
 */
#if !defined(PREMAKE_PLATFORM_H)
#define PREMAKE_PLATFORM_H


/**
 * The currently support platforms. If you add to this list be sure to
 * also update the platform detection logic below, and the platform
 * identifier initialization in platform.c.
 */
enum Platform
{
	Unknown,
	BSD,
	Linux,
	MacOSX,
	Windows
};


#if defined(__linux__)
#define PLATFORM_LINUX   (1)
#elif defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__)
#define PLATFORM_BSD     (1)
#elif defined(__APPLE__) && defined(__MACH__)
#define PLATFORM_MACOSX  (1)
#else
#define PLATFORM_WINDOWS (1)
#endif

DECLARE_CLASS(PlatformSearch)


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


/**
 * Retrieve the current platform identifier.
 */
enum Platform platform_get(void);


/**
 * Create a new platform file search context.
 */
PlatformSearch platform_search_create(const char* mask);


/**
 * Destroy a platform search context.
 */
void platform_search_destroy(PlatformSearch search);


/**
 * Retrieve the name of the current match in the search.
 */
const char* platform_search_get_name(PlatformSearch search);


/**
 * Determine if the current match is a file or a directory.
 */
int platform_search_is_file(PlatformSearch search);


/**
 * Retrieve the next match in a file system search.
 * \returns True if another match is available.
 */
int platform_search_next(PlatformSearch search);


/**
 * Set the platform identification string, forcing a platform-specific
 * behavior regardless of the actual current platform.
 * \param   id    One of the platform identifiers.
 */
void platform_set(enum Platform id);


#endif
/** @} */
