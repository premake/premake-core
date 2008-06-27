/**
 * \file   fn_configuration.c
 * \brief  Implements the configuration() function.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_internal.h"


/**
 * Specify the build configurations for a solution.
 */
int fn_configuration(lua_State* L)
{
	/* if there are parameters, create a new configuration block */
	if (lua_gettop(L) > 0)
	{
		/* get the active object, which will contain this new configuration */
		if (!script_internal_get_active_object(L, SolutionObject | ProjectObject, REQUIRED))
		{
			return 0;
		}

		/* create a new configuration block in the container */
		script_internal_create_block(L);
	}

	script_internal_get_active_object(L, BlockObject, OPTIONAL);
	return 1;
}

