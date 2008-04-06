/**
 * \file   error.c
 * \brief  Application-wide error reporting.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include "premake.h"
#include "error.h"

static char error_message[8192] = { 0 };


/**
 * Clear any existing error state.
 */
void error_clear(void)
{
	error_message[0] = 0;
}


/**
 * Returns the most recent error message set by error_set().
 * \returns The error message, or NULL if no error message has been set.
 */
const char* error_get(void)
{
	return (strlen(error_message) > 0) ? error_message : NULL;
}


/**
 * Set the description of an error condition, which may be retrieved with session_get_error().
 * The session uses a fixed length (around 8K) buffer for storing the error message, so make
 * sure the final size of the formatted message will fall under that limit.
 * \param   message A description of the error condition.
 */
void error_set(const char* message, ...)
{
	va_list args;

	assert(message);

	va_start(args, message);
	vsprintf(error_message, message, args);
	va_end(args);
}
