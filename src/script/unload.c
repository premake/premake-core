/**
 * \file   unload.c
 * \brief  Unload project objects from the scripting environment.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include "premake.h"
#include "script/script_internal.h"


static int unload_blocks(lua_State* L, struct UnloadFuncs* funcs, Blocks blocks);
static int unload_projects(lua_State* L, struct UnloadFuncs* funcs, Solution sln);


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
	assert(funcs->unload_project);
	assert(funcs->unload_block);

	/* iterate over the list of solutions */
	lua_getglobal(L, SOLUTIONS_KEY);
	sn = luaL_getn(L, -1);
	for (si = 1; z == OKAY && si <= sn; ++si)
	{
		/* add a new solution to the master list */
		Solution sln = solution_create();
		array_add(slns, sln);

		/* get the scripted solution object from the solutions list */
		lua_rawgeti(L, -1, si);

		/* unload the solution fields, then configuration blocks, then projects */
		z = funcs->unload_solution(L, sln);
		if (z == OKAY)
		{
			Blocks blocks = solution_get_blocks(sln);
			z = unload_blocks(L, funcs, blocks);
		}
		if (z == OKAY)
		{
			z = unload_projects(L, funcs, sln);
		}

		/* remove solution object from stack */
		lua_pop(L, 1);
	}

	/* remove list of solutions from stack */
	lua_pop(L, 1);
	return z;
}


static int unload_projects(lua_State* L, struct UnloadFuncs* funcs, Solution sln)
{
	int pi, pn, z = OKAY;

	/* iterate over list of projects from the solution */
	lua_getfield(L, -1, PROJECTS_KEY);
	pn = luaL_getn(L, -1);
	for (pi = 1; z == OKAY && pi <= pn; ++pi)
	{
		/* add a new project to the master list */
		Project prj = project_create();
		solution_add_project(sln, prj);

		/* get the scripted project object from the solutions list */
		lua_rawgeti(L, -1, pi);
	
		/* unload the project fields, then configuration blocks */
		z = funcs->unload_project(L, prj);
		if (z == OKAY)
		{
			Blocks blocks = project_get_blocks(prj);
			z = unload_blocks(L, funcs, blocks);
		}
		
		/* remove project object from stack */
		lua_pop(L, 1);
	}

	/* remove list of projects from stack */
	lua_pop(L, 1);
	return z;
}


static int unload_blocks(lua_State* L, struct UnloadFuncs* funcs, Blocks blocks)
{
	int ci, cn, z = OKAY;
	
	/* iterate over the list configuration blocks from the solution */
	lua_getfield(L, -1, BLOCKS_KEY);
	cn = luaL_getn(L, -1);
	for (ci = 1; z == OKAY && ci <= cn; ++ci)
	{
		Block blk = block_create();
		blocks_add(blocks, blk);

		/* unload the configuration block fields */
		lua_rawgeti(L, -1, ci);
		z = funcs->unload_block(L, blk);

		/* remove the configuration block object from the stack */
		lua_pop(L, 1);
	}

	/* remove the list of blocks from the stack */
	lua_pop(L, 1);
	return z;
}


int unload_fields(lua_State* L, Fields fields, struct FieldInfo* info)
{
	const char* value;
	int fi;

	for (fi = 0; info[fi].name != NULL; ++fi)
	{
		Strings values = strings_create();

		lua_getfield(L, -1, info[fi].name);
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
		fields_set_values(fields, fi, values);
	}

	return OKAY;
}


/**
 * Unload information from the scripting environment for a particular solution.
 * \param L      The Lua scripting engine state.
 * \param sln    The solution object to be populated.
 * \returns OKAY if successful.
 */
int unload_solution(lua_State* L, Solution sln)
{
	return unload_fields(L, solution_get_fields(sln), SolutionFieldInfo);
}


/**
 * Unload information from the scripting environment for a particular project.
 * \param   L      The Lua scripting engine state.
 * \param   prj    The project object to be populated.
 * \returns OKAY if successful.
 */
int unload_project(lua_State* L, Project prj)
{
	return unload_fields(L, project_get_fields(prj), ProjectFieldInfo);
}


/**
 * Unload information from the scripting environment for a particular configuration.
 * \param   L      The Lua scripting engine state.
 * \param   blk    The configuration block to be populated.
 * \returns OKAY if successful.
 */
int unload_block(lua_State* L, Block blk)
{
	return unload_fields(L, block_get_fields(blk), BlockFieldInfo);
}
