/**
 * \file   script_internal.h
 * \brief  Project scripting engine internal API.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include <string.h>
#include "premake.h"
#include "script_internal.h"
#include "base/buffers.h"
#include "base/path.h"


/**
 * Create a new configuration block in the object at the top of the stack.
 * \param   L            The Lua state.
 */
int script_internal_create_block(lua_State* L)
{
	int i;

	/* get the current list of configuration blocks */
	lua_getfield(L, -1, BLOCKS_KEY);

	/* create a new block and make it active */
	lua_newtable(L);
	script_internal_set_active_object(L, BlockObject);

	/* set all list-type configuration block values to empty tables */
	for (i = 0; i < NumBlockFields; ++i)
	{
		int kind = BlockFieldInfo[i].kind;
		if (kind != StringField && kind != PathField)
		{
			lua_newtable(L);
			lua_setfield(L, -2, BlockFieldInfo[i].name);
		}
	}

	/* add it to the list of blocks */
	lua_rawseti(L, -2, luaL_getn(L,-2) + 1);
	lua_pop(L, 1);
	return OKAY;
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
int script_internal_get_active_object(lua_State* L, enum ObjectType type, int is_required)
{
	int top;

	lua_getregistry(L);
	top = lua_gettop(L);

	if (lua_gettop(L) == top && (type & BlockObject))
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
		case BlockObject:
			strcat(buffer, "configuration block");
			break;
		case SolutionObject | ProjectObject:
			strcat(buffer, "solution or project");
			break;
		case SolutionObject | ProjectObject | BlockObject:
			strcat(buffer, "solution, project, or configuration block");
			break;
		default:
			strcat(buffer, "object");
		}
		luaL_error(L, buffer);
		return 0;
	}
}


/**
 * Remembers the object at the top of the stack as active for the given object type. 
 * This function is used to indicate the current solution, project, etc.
 * \param   L     The Lua state.
 * \param   type  One of the script object type enumerations.
 */
void script_internal_set_active_object(lua_State* L, enum ObjectType type)
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
 * Returns the directory containing the currently executing script file. Used to
 * locate external resources (files, etc.) specified relative to the current script.
 * \param   L    The Lua script environment.
 * \returns The directory containing the currently executing script file.
 */
const char* script_internal_script_dir(lua_State* L)
{
	const char* result;
	lua_getglobal(L, FILE_KEY);
	result = lua_tostring(L, -1);
	result = path_directory(result);
	lua_pop(L, 1);
	return result;
}


/**
 * Uses a list of fields to populate a project object (solution, project, or
 * configuration) with a matching set of properties and accessor functions.
 * \param   L       The Lua state.
 * \param   fields  The list of object fields.
 */
void script_internal_populate_object(lua_State* L, FieldInfo* fields)
{
	FieldInfo* field;

	/* set all list-type configuration values to empty tables */
	for (field = fields; field->name != NULL; ++field)
	{
		if (field->kind != StringField && field->kind != PathField)
		{
			lua_newtable(L);
			lua_setfield(L, -2, field->name);
		}
	}
}
