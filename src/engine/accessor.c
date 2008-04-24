/**
 * \file   accessor.c
 * \brief  A generic getter/setter for project fields.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "internals.h"
#include "base/cstr.h"
#include "base/error.h"


static int accessor_object_has_field(struct FieldInfo* fields, const char* field_name);
static int accessor_register(lua_State* L, struct FieldInfo* fields);
static int accessor_register_field(lua_State* L, struct FieldInfo* field);
static int accessor_set_string_value(lua_State* L, struct FieldInfo* field);
static int fn_accessor(lua_State* L);


/**
 * Register all of the accessors listed in the project object field information.
 * \param   L    The Lua scripting state.
 * \returns OKAY if successful.
 */
int accessor_register_all(lua_State* L)
{
	int z = OKAY;
	if (z == OKAY) z = accessor_register(L, SolutionFieldInfo);
	if (z == OKAY) z = accessor_register(L, ProjectFieldInfo);
	return z;
}


/**
 * Register accessor functions for a set of fields.
 * \param   L      The Lua scripting state.
 * \param   fields The list of fields to register.
 * \returns OKAY if successful.
 */
int accessor_register(lua_State* L, struct FieldInfo* fields)
{
	int i, z = OKAY;

	for (i = 0; z == OKAY && fields[i].name != NULL; ++i)
	{
		z = accessor_register_field(L, &fields[i]);
	}

	return z;
}


/**
 * Register a single accessor function.
 * \param   L      The Lua scripting state.
 * \param   field  The field to register.
 * \returns OKAY if successful.
 */
int accessor_register_field(lua_State* L, struct FieldInfo* field)
{
	int container_type, z;

	/* has this accessor already been registered? If so, skip it now */
	lua_getglobal(L, field->name);
	z = lua_isnil(L, -1);
	lua_pop(L, 1);
	if (!z) return OKAY;

	/* figure out what object types this accessor applies to */
	container_type = 0;
	if (accessor_object_has_field(SolutionFieldInfo, field->name))  container_type |= SolutionObject;
	if (accessor_object_has_field(ProjectFieldInfo,  field->name))  container_type |= ProjectObject;

	/* register the accessor function	*/
	lua_pushnumber(L, container_type);
	lua_pushlightuserdata(L, field);
	lua_pushcclosure(L, fn_accessor, 2);
	lua_setglobal(L, field->name);
	return OKAY;
}


/**
 * Determine if a field list contains a field with a particular name.
 * \param   fields     The list of fields to check.
 * \param   field_name The field to look for.
 * \returns True if the field is contained by the list.
 */
int accessor_object_has_field(struct FieldInfo* fields, const char* field_name)
{
	int i;
	for (i = 0; fields[i].name != NULL; ++i)
	{
		if (cstr_eq(fields[i].name, field_name))
			return 1;
	}
	return 0;
}


/**
 * Sets a string field, using the value on the stack.
 * \param   L      The Lua state.
 * \param   field  The field to set.
 * \returns OKAY if successful.
 */
int accessor_set_string_value(lua_State* L, struct FieldInfo* field)
{
	/* can't set lists to simple fields */
	if (lua_istable(L, 1))
	{
		luaL_error(L, "the field '%s' does not support lists of values", field->name);
		return !OKAY;
	}

	/* if a validator function is present, call it */
	if (field->validator != NULL)
	{
		const char* value = luaL_checkstring(L, 1);
		if (!field->validator(value))
		{
			luaL_error(L, "invalid value '%s'", value);
			return !OKAY;
		}
	}

	/* set the field */
	lua_pushvalue(L, 1);
	lua_setfield(L, -2, field->name);
	return OKAY;
}


/**
 * The accessor function; this is what gets called by Lua when an accessor
 * function is called in a script.
 * \param   L    The Lua state.
 * \returns The current value of the field.
 */
int fn_accessor(lua_State* L)
{
	struct FieldInfo* field;
	int container_type;

	/* get the required container object */
	container_type = lua_tointeger(L, lua_upvalueindex(1));
	if (!engine_get_active_object(L, container_type, REQUIRED))
	{
		return 0;
	}

	/* get field information */
	field = (struct FieldInfo*)lua_touserdata(L, lua_upvalueindex(2));

	/* if a value is provided, set the field */
	if (lua_gettop(L) > 1)
	{
		accessor_set_string_value(L, field);
	}

	/* return the current value of the field */
	lua_getfield(L, -1, field->name);
	return 1;
}
