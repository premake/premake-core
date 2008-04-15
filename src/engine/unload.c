/**
 * \file   unload.c
 * \brief  Unload project objects from the scripting environment.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include "premake.h"
#include "internals.h"


/**
 * Copy project information out of the scripting environment and into C objects that
 * can be more easily manipulated by the action code.
 * \param sess   The session object which contains the scripted project objects.
 * \param L      The Lua scripting engine state.
 * \param funcs  The unloading "interface", providing an opportunity to mock for automated testing.
 * \returns OKAY if successful.
 */
int unload_all(Session sess, lua_State* L, struct UnloadFuncs* funcs)
{
	int si, sn;
	int status = OKAY;

	assert(sess);
	assert(L);
	assert(funcs);
	assert(funcs->unload_solution);

	/* iterate over the list of solutions */
	lua_getglobal(L, SOLUTIONS_KEY);
	sn = luaL_getn(L, -1);
	for (si = 1; status == OKAY && si <= sn; ++si)
	{
		Solution sln = solution_create();
		session_add_solution(sess, sln);

		lua_rawgeti(L, -1, si);
		status = funcs->unload_solution(sess, L, sln);
		if (status == OKAY)
		{
			/* iterate over list of projects */
			int pi, pn;
			lua_getfield(L, -1, PROJECTS_KEY);
			pn = luaL_getn(L, -1);
			for (pi = 1; status == OKAY && pi <= pn; ++pi)
			{
				Project prj = project_create();
				solution_add_project(sln, prj);

				lua_rawgeti(L, -1, pi);
				status = funcs->unload_project(sess, L, prj);
				
				/* remove project object from stack */
				lua_pop(L, 1);
			}

			/* remove list of projects from stack */
			lua_pop(L, 1);
		}

		/* remove solution object from stack */
		lua_pop(L, 1);
	}

	/* remove list of solutions from stack */
	lua_pop(L, 1);
	return status;
}


/**
 * Unload information from the scripting environment for a particular solution.
 * \param sess   The session object which contains the scripted project objects.
 * \param L      The Lua scripting engine state.
 * \param sln    The solution object to be populated.
 * \returns OKAY if successful.
 */
int unload_solution(Session sess, lua_State* L, Solution sln)
{
	const char* value;

	assert(sess);
	assert(L);
	assert(sln);

	sess = 0;  /* unused */

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
 * \param sess   The session object which contains the scripted project objects.
 * \param L      The Lua scripting engine state.
 * \param prj    The project object to be populated.
 * \returns OKAY if successful.
 */
int unload_project(Session sess, lua_State* L, Project prj)
{
	const char* value;

	assert(sess);
	assert(L);
	assert(prj);

	sess = 0;  /* unused */

	lua_getfield(L, -1, "name");
	value = lua_tostring(L, -1);
	project_set_name(prj, value);
	lua_pop(L, 1);

	lua_getfield(L, -1, "basedir");
	value = lua_tostring(L, -1);
	project_set_base_dir(prj, value);
	lua_pop(L, 1);

	lua_getfield(L, -1, "guid");
	value = lua_tostring(L, -1);
	project_set_guid(prj, value);
	lua_pop(L, 1);

	return OKAY;
}
