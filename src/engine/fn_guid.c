/**
 * \file   fn_guid.c
 * \brief  Specify a project GUID.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "internals.h"
#include "base/guid.h"


/**
 * Specify a project GUID, which is used by the Visual Studio actions to 
 * identify the project in the solution.
 */
int fn_guid(lua_State* L)
{
	const char* guid = luaL_optstring(L, 1, NULL);

	/* retrieve the project being set */
	if (!engine_get_active_object(L, ProjectObject, REQUIRED))
		return 0;

	/* if a value is provided, set it */
	if (guid != NULL)
	{
		if (!guid_is_valid(guid))
		{
			luaL_error(L, "invalid GUID");
			return 0;
		}
		lua_pushvalue(L, 1);
		lua_setfield(L, -2, ProjectFieldInfo[ProjectGuid].name);
	}

	/* return the current value */
	lua_getfield(L, -1, ProjectFieldInfo[ProjectGuid].name);
	return 1;
}
