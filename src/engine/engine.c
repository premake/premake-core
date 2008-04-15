/**
 * \file   engine.c
 * \brief  Project scripting internal implementation.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <string.h>
#include "premake.h"
#include "internals.h"
#include "base/buffers.h"
#include "base/path.h"


/**
 * Configure a new project object (solution, project). Initializes all list
 * fields and creates an initial configuration list.
 * \param   L       The Lua state.
 * \param   fields  The list of object fields.
 */
void engine_configure_project_object(lua_State* L, struct FieldInfo* fields)
{
	struct FieldInfo* field;

	/* set all list-type configuration values to empty tables */
	for (field = fields; field->name != NULL; ++field)
	{
		if (field->kind == ListField)
		{
			lua_newtable(L);
			lua_setfield(L, -2, field->name);
		}
	}
}


/**
 * Pushes the active value for the given object type to the top of the stack.
 * This function is used to retrieve the current solution, project, etc.
 * \param   L            The Lua state.
 * \param   type         One or more of the script object type enumerations.
 *                       A bitmask may be supplied if more than one object type
 *                       can be valid. If so, the objects will be returned in
 *                       following order: configuration, project, then solution.
 * \param   is_required  If true, will set error if no active object is found.
 * \returns The active object, pushed onto the stack. May be nil if there is
 *          no currently active object. If is_required is true, returns true
 *          if an active object was found, false otherwise.
 */
int engine_get_active_object(lua_State* L, enum ObjectType type, int is_required)
{
	int top;

	lua_getregistry(L);
	top = lua_gettop(L);

	if (lua_gettop(L) == top && (type & ConfigObject))
	{
		lua_getfield(L, -1, CONFIGURATION_KEY);
		if (lua_isnil(L, -1))
			lua_pop(L, 1);
	}

	if (lua_gettop(L) == top && (type & ProjectObject))
	{
		lua_getfield(L, -1, PROJECT_KEY);
		if (lua_isnil(L, -1))
			lua_pop(L, 1);
	}

	if (lua_gettop(L) == top && (type & SolutionObject))
	{
		lua_getfield(L, -1, SOLUTION_KEY);
		if (lua_isnil(L, -1))
			lua_pop(L, 1);
	}

	/* if an active object was found, return it */
	if (lua_gettop(L) > top)
	{
		/* remove the registry table first */
		lua_remove(L, -2);
		return 1;
	}

	/* if no active object was found, and none is required, return nil */
	else if (!is_required)
	{
		/* remove the registry table first */
		lua_pop(L, 1);
		lua_pushnil(L);
		return 1;
	}

	/* else set an error */
	else
	{
		/* build an error message */
		char* buffer = buffers_next();
		strcpy(buffer, "no active ");
		switch (type)
		{
		case SolutionObject:
			strcat(buffer, "solution");
			break;
		case ProjectObject:
			strcat(buffer, "project");
			break;
		case ConfigObject:
			strcat(buffer, "configuration");
			break;
		case SolutionObject | ProjectObject:
			strcat(buffer, "solution or project");
			break;
		case SolutionObject | ProjectObject | ConfigObject:
			strcat(buffer, "solution, project, or configuration");
			break;
		default:
			strcat(buffer, "object");
		}
		luaL_error(L, buffer);
		return 0;
	}
}


/**
 * Get the directory which contains the currently executing script. This is 
 * used to locate resources specified in the script using relative paths.
 * \param   L    The Lua state.
 * \returns The directory containing the current script, as an absolute path.
 */
const char* engine_get_script_dir(lua_State* L)
{
	const char* path;

	lua_getglobal(L, FILE_KEY);
	path = lua_tostring(L, -1);
	lua_pop(L, 1);

	path = path_directory(path);
	return path;
}


/**
 * Remembers the object at the top of the stack as active for the given object type. 
 * This function is used to indicate the current solution, project, etc.
 * \param   L     The Lua state.
 * \param   type  One of the script object type enumerations.
 */
void engine_set_active_object(lua_State* L, enum ObjectType type)
{
	lua_getregistry(L);
	lua_pushvalue(L, -2);

	if (type == SolutionObject)
	{
		lua_setfield(L, -2, SOLUTION_KEY);
	}
	else if (type == ProjectObject)
	{
		lua_setfield(L, -2, PROJECT_KEY);
	}
	else
	{
		lua_setfield(L, -2, CONFIGURATION_KEY);
	}

	lua_pop(L, 1);
}


/**
 * Remembers the name of the currently executing script file, exposing it
 * to the script via the _FILE global. The script file path is used to
 * locate any resources specified in the script using relative paths.
 * \param   L         The Lua state.
 * \param   filename  The script filename; should be absolute.
 */
void engine_set_script_file(lua_State* L, const char* filename)
{
	lua_pushstring(L, filename);
	lua_setglobal(L, FILE_KEY);
}


