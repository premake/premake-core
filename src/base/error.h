/**
 * \file   error.h
 * \brief  Application-wide error reporting.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 *
 * \defgroup array Array
 * \ingroup  base
 *
 * Application-wide error reporting.
 *
 * @{
 */
#if !defined(PREMAKE_ERROR_H)
#define PREMAKE_ERROR_H

void        error_clear(void);
const char* error_get(void);
void        error_set(const char* message, ...);

#endif
/** @} */
