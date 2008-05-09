/**
 * \file   fn_error.c
 * \brief  Script error handler.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_internal.h"
#include "base/error.h"


/**
 * Handler for errors reported out the script; copies the error message to
 * Premake's global error state.
 */
int fn_error(lua_State* L)
{
	const char* message = lua_tostring(L, 1);
	error_set(message);
	return 0;
}
