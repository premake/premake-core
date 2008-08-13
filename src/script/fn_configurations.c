/**
 * \file   fn_configurations.c
 * \brief  Specify the build configurations.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_internal.h"


/**
 * Specify the build configurations for a solution.
 */
int fn_configurations(lua_State* L)
{
	FieldInfo* field;

	if (!script_internal_get_active_object(L, SolutionObject, IS_REQUIRED))
	{
		return 0;
	}

	/* configurations may not be modified once projects are defined */
	lua_getfield(L, -1, PROJECTS_KEY);
	if (luaL_getn(L, -1) > 0)
	{
		luaL_error(L, "configurations may not be modified after projects are defined");
	}
	lua_pop(L, 1);

	/* get information about the field being accessed */
	field = (FieldInfo*)lua_touserdata(L, lua_upvalueindex(2));

	/* if a value is provided, set the field */
	if (lua_gettop(L) > 1)
	{
		fn_accessor_set_list_value(L, &SolutionFieldInfo[SolutionConfigurations]);
	}

	/* return the current value of the field */
	lua_getfield(L, -1, SolutionFieldInfo[SolutionConfigurations].name);
	return 1;
}
