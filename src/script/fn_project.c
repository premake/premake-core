/**
 * \file   fn_project.c
 * \brief  Create or select a project object.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_internal.h"
#include "base/guid.h"


/**
 * Create a new project object, or select an existing one.
 */
int fn_project(lua_State* L)
{
	const char* name;

	/* if there are no parameters, return the active project */
	if (lua_gettop(L) == 0)
	{
		script_internal_get_active_object(L, ProjectObject, IS_OPTIONAL);
		return 1;
	}

	/* get the active solution, which will contain this project */
	if (!script_internal_get_active_object(L, SolutionObject, IS_REQUIRED))
	{
		return 0;
	}

	name = luaL_checkstring(L, 1);

	/* get the projects list from the solution */
	lua_getfield(L, -1, PROJECTS_KEY);

	/* check to see if a project with this name already exists */
	lua_getfield(L, -1, name);
	if (lua_isnil(L, -1))
	{
		/* this is a new project; check to be sure the configurations have been set */
		lua_getfield(L, -3, SolutionFieldInfo[SolutionConfigurations].name);
		if (luaL_getn(L, -1) == 0)
		{
			luaL_error(L, "no configurations defined");
			return 0;
		}
		lua_pop(L, 1);

		/* project does not exists, create it */
		lua_newtable(L);

		/* set the name */
		lua_pushvalue(L, 1);
		lua_setfield(L, -2, ProjectFieldInfo[ProjectName].name);

		/* set the base directory */
		lua_pushstring(L, script_internal_script_dir(L));
		lua_setfield(L, -2, ProjectFieldInfo[ProjectBaseDirectory].name);

		/* set a default GUID */
		lua_pushstring(L, guid_create());
		lua_setfield(L, -2, ProjectFieldInfo[ProjectGuid].name);

		/* configure the initial configuration block list */
		lua_newtable(L);
		lua_setfield(L, -2, BLOCKS_KEY);
		script_internal_create_block(L);

		/* use the list of fields to populate the object properties and accessor functions */
		script_internal_populate_object(L, ProjectFieldInfo);

		/* add it to solution's list of projects, keyed by name */
		lua_pushvalue(L, -1);
		lua_setfield(L, -4, name);

		/* also add with integer key */
		lua_pushvalue(L, -1);
		lua_rawseti(L, -4, luaL_getn(L, -4) + 1);
	}

	/* activate and return the solution object */
	script_internal_set_active_object(L, ProjectObject);
	return 1;
}

