/**
 * \file   unload.c
 * \brief  Unload project objects from the scripting environment.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include "premake.h"
#include "script/script_internal.h"
#include "base/path.h"


static int unload_blocks(lua_State* L, struct UnloadFuncs* funcs, Blocks blocks);
static int unload_projects(lua_State* L, struct UnloadFuncs* funcs, Solution sln);
static int unload_repoint_paths(Fields fields, int base_dir_idx, int location_idx);


/**
 * Copy project information out of the scripting environment and into C objects that
 * can be more easily manipulated by the action code.
 * \param L      The Lua scripting engine state.
 * \param sess   The session will contain the unloaded objects.
 * \param funcs  The unloading "interface", providing an opportunity to mock for automated testing.
 * \returns OKAY if successful.
 */
int unload_all(lua_State* L, Session sess, struct UnloadFuncs* funcs)
{
	int si, sn, z = OKAY;

	assert(L);
	assert(sess);
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
		session_add_solution(sess, sln);

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


int unload_fields(lua_State* L, Fields fields, FieldInfo* info)
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
	Fields fields = solution_get_fields(sln);
	int z = unload_fields(L, fields, SolutionFieldInfo);
	unload_repoint_paths(fields, SolutionBaseDir, SolutionLocation);
	return z;
}


/**
 * Unload information from the scripting environment for a particular project.
 * \param   L      The Lua scripting engine state.
 * \param   prj    The project object to be populated.
 * \returns OKAY if successful.
 */
int unload_project(lua_State* L, Project prj)
{
	Fields fields = project_get_fields(prj);
	int z = unload_fields(L, fields, ProjectFieldInfo);
	unload_repoint_paths(fields, ProjectBaseDir, ProjectLocation);
	return z;
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



/**
 * Walks a list of fields and repoints all paths to be relative to
 * base_directory/location. Once this is done, all paths will end up
 * relative to the generated project or solution file.
 * \param   fields        The list of fields to repoint.
 * \param   base_dir_idx  The index of the BaseDir field in the field list.
 * \param   location_idx  The index of the Location field in the field list.
 */
int unload_repoint_paths(Fields fields, int base_dir_idx, int location_idx)
{
	const char* base_dir;
	const char* location;
	int fi, fn;

	/* first I have to update the Location field; this is the absolute path that
	 * I will base all the other relative paths upon */
	base_dir = fields_get_value(fields, base_dir_idx);
	location = path_join(base_dir, fields_get_value(fields, location_idx));
	fields_set_value(fields, location_idx, location);

	/* now I can can for other pathed fields and repoint them */
	fn = fields_size(fields);
	for (fi = 0; fi < fn; ++fi)
	{
		/* only repoint pathed fields */
		int kind = fields_get_kind(fields, fi);
		if (kind == FilesField || kind == PathField)
		{
			/* enumerate all values of the field */
			int vi, vn;
			Strings values = fields_get_values(fields, fi);
			vn = strings_size(values);
			for (vi = 0; vi < vn; ++vi)
			{
				const char* value = strings_item(values, vi);

				const char* abs_path = path_join(base_dir, value);
				const char* rel_path = path_relative(location, abs_path);

				strings_set(values, vi, rel_path);
			}
		}
	}

	return OKAY;
}
