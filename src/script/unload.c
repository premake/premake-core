/**
 * \file   unload.c
 * \brief  Unload project objects from the scripting environment.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include "premake.h"
#include "script/script_internal.h"


static int unload_solution_projects(lua_State* L, struct UnloadFuncs* funcs, Solution sln);


/**
 * Copy project information out of the scripting environment and into C objects that
 * can be more easily manipulated by the action code.
 * \param L      The Lua scripting engine state.
 * \param slns   An array to contain the list of unloaded solutions.
 * \param funcs  The unloading "interface", providing an opportunity to mock for automated testing.
 * \returns OKAY if successful.
 */
int unload_all(lua_State* L, Array slns, struct UnloadFuncs* funcs)
{
	int si, sn, z = OKAY;

	assert(L);
	assert(slns);
	assert(funcs);
	assert(funcs->unload_solution);

	/* iterate over the list of solutions */
	lua_getglobal(L, SOLUTIONS_KEY);
	sn = luaL_getn(L, -1);
	for (si = 1; z == OKAY && si <= sn; ++si)
	{
		Solution sln = solution_create();
		array_add(slns, sln);
		lua_rawgeti(L, -1, si);

		/* hardcoded a standard set of configurations for now */
		solution_add_config_name(sln, "Debug");
		solution_add_config_name(sln, "Release");

		/* extract the project fields */
		z = funcs->unload_solution(L, sln);
		if (z == OKAY)
		{
			z = unload_solution_projects(L, funcs, sln);
		}

		/* remove solution object from stack */
		lua_pop(L, 1);
	}

	/* remove list of solutions from stack */
	lua_pop(L, 1);
	return z;
}


static int unload_solution_projects(lua_State* L, struct UnloadFuncs* funcs, Solution sln)
{
	int pi, pn, z = OKAY;

	/* iterate over list of projects from the solution */
	lua_getfield(L, -1, PROJECTS_KEY);
	pn = luaL_getn(L, -1);
	for (pi = 1; z == OKAY && pi <= pn; ++pi)
	{
		Project prj = project_create();
		solution_add_project(sln, prj);

		/* unload the project fields */
		lua_rawgeti(L, -1, pi);
		z = funcs->unload_project(L, prj);
		
		/* remove project object from stack */
		lua_pop(L, 1);
	}

	/* remove list of projects from stack */
	lua_pop(L, 1);
	return z;
}


/**
 * Unload information from the scripting environment for a particular solution.
 * \param L      The Lua scripting engine state.
 * \param sln    The solution object to be populated.
 * \returns OKAY if successful.
 */
int unload_solution(lua_State* L, Solution sln)
{
	const char* value;

	assert(L);
	assert(sln);

	lua_getfield(L, -1, "name");
	value = lua_tostring(L, -1);
	solution_set_name(sln, value);
	lua_pop(L, 1);

	lua_getfield(L, -1, "basedir");
	value = lua_tostring(L, -1);
	solution_set_base_dir(sln, value);
	lua_pop(L, 1);

	return OKAY;
}


/**
 * Unload information from the scripting environment for a particular project.
 * \param L      The Lua scripting engine state.
 * \param prj    The project object to be populated.
 * \returns OKAY if successful.
 */
int unload_project(lua_State* L, Project prj)
{
	const char* value;
	int fi;

	assert(L);
	assert(prj);

	for (fi = 0; fi < NumProjectFields; ++fi)
	{
		Strings values = strings_create();

		lua_getfield(L, -1, ProjectFieldInfo[fi].name);
		if (lua_istable(L, -1))
		{
			int i, n;
			n = luaL_getn(L, -1);
			for (i = 1; i <= n; ++i)
			{
				lua_rawgeti(L, -1, i);
				value = lua_tostring(L, -1);
				if (value != NULL)
				{
					strings_add(values, value);
				}
				lua_pop(L, 1);
			}
		}
		else
		{
			value = lua_tostring(L, -1);
			if (value != NULL)
			{
				strings_add(values, value);
			}
		}

		/* remove the field value from the top of the stack */
		lua_pop(L, 1);

		/* store the field values */
		project_set_values(prj, fi, values);
	}

	return OKAY;
}


