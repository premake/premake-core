/**
 * \file   fn_solution.c
 * \brief  Create or select a solution object.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "internals.h"


/**
 * Create a new solution object, or select an existing one.
 */
int fn_solution(lua_State* L)
{
	const char* name;

	/* if there are no parameters, return the active solution */
	if (lua_gettop(L) == 0)
	{
		engine_get_active_object(L, SolutionObject, OPTIONAL);
		return 1;
	}

	name = luaL_checkstring(L, 1);

	/* check to see if a solution with this name already exists */
	lua_getglobal(L, SOLUTIONS_KEY);
	lua_getfield(L, -1, name);
	if (lua_isnil(L, -1))
	{
		/* solution does not exists, create it */
		lua_newtable(L);

		/* set the name */
		lua_pushstring(L, name);
		lua_setfield(L, -2, SolutionFieldInfo[SolutionName].name);

		/* set the base directory */
		lua_pushstring(L, engine_get_script_dir(L));
		lua_setfield(L, -2, SolutionFieldInfo[SolutionBaseDirectory].name);

		/* create an empty list of projects */
		lua_newtable(L);
		lua_setfield(L, -2, PROJECTS_KEY);

		/* finish the configuration */
		engine_configure_project_object(L, SolutionFieldInfo);

		/* add it to the master list of solutions, keyed by name */
		lua_pushvalue(L, -1);
		lua_setfield(L, -4, name);

		/* also add with integer key */
		lua_pushvalue(L, -1);
		lua_rawseti(L, -4, luaL_getn(L, -4) + 1);
	}

	/* activate and return the solution object */
	engine_set_active_object(L, SolutionObject);
	return 1;
}
