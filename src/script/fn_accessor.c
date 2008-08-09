/**
 * \file   fn_accessor.c
 * \brief  A generic getter/setter for project fields.
 * \author Copyright (c) 2007-2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_internal.h"
#include "base/cstr.h"
#include "base/error.h"


static int  fn_accessor_object_has_field(struct FieldInfo* fields, const char* field_name);
static int  fn_accessor_register(lua_State* L, struct FieldInfo* fields);
static int  fn_accessor_register_field(lua_State* L, struct FieldInfo* field);
static void fn_accessor_append_value(lua_State* L, struct FieldInfo* field, int tbl, int idx);


/**
 * Using the field information lists for each of the project objects (solution, project,
 * and configuration) register accessor functions in the script environment. Examples of
 * accessor functions include location(), language(), kind(), and so on; function that
 * get and set the project object properties.
 * \returns OKAY if successful.
 */
int fn_accessor_register_all(lua_State* L)
{
	int z = OKAY;
	if (z == OKAY) z = fn_accessor_register(L, SolutionFieldInfo);
	if (z == OKAY) z = fn_accessor_register(L, ProjectFieldInfo);
	if (z == OKAY) z = fn_accessor_register(L, BlockFieldInfo);
	return z;
}


/**
 * Register the accessor functions for a particular set of fields.
 * \returns OKAY if successful.
 */
static int fn_accessor_register(lua_State* L, struct FieldInfo* fields)
{
	int i, z = OKAY;

	for (i = 0; z == OKAY && fields[i].name != NULL; ++i)
	{
		z = fn_accessor_register_field(L, &fields[i]);
	}

	return z;
}


/**
 * Register a single accessor function.
 * \returns OKAY if successful.
 */
static int fn_accessor_register_field(lua_State* L, struct FieldInfo* field)
{
	int container_type, z;

	/* has this accessor already been registered? This will happen if two object
	 * types (ie. solution and project) define the same property. If so, skip it */
	lua_getglobal(L, field->name);
	z = lua_isnil(L, -1);
	lua_pop(L, 1);
	if (!z) return OKAY;

	/* figure out what object types this accessor applies to; may be more than one */
	container_type = 0;
	if (fn_accessor_object_has_field(SolutionFieldInfo, field->name))  container_type |= SolutionObject;
	if (fn_accessor_object_has_field(ProjectFieldInfo,  field->name))  container_type |= ProjectObject;
	if (fn_accessor_object_has_field(BlockFieldInfo,    field->name))  container_type |= BlockObject;

	/* register the accessor function	*/
	lua_pushnumber(L, container_type);
	lua_pushlightuserdata(L, field);
	lua_pushcclosure(L, fn_accessor, 2);
	lua_setglobal(L, field->name);
	return OKAY;
}


/**
 * Determine if a field list contains a field with a particular name.
 * \returns True if the field is contained by the list.
 */
static int fn_accessor_object_has_field(struct FieldInfo* fields, const char* field_name)
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
 * The accessor script function; all of the individually registered accessors
 * (location(), language(), etc.) point to here, and this is where all of the
 * work gets done to get or set an object property or list.
 * \returns The current value of the field.
 */
int fn_accessor(lua_State* L)
{
	struct FieldInfo* field;
	int container_type;

	/* get the required container object */
	container_type = lua_tointeger(L, lua_upvalueindex(1));
	if (!script_internal_get_active_object(L, container_type, IS_REQUIRED))
	{
		return 0;
	}

	/* get information about the field being accessed */
	field = (struct FieldInfo*)lua_touserdata(L, lua_upvalueindex(2));

	/* if a value is provided, set the field */
	if (lua_gettop(L) > 1)
	{
		if (field->kind == StringField)
		{
			fn_accessor_set_string_value(L, field);
		}
		else
		{
			fn_accessor_set_list_value(L, field);
		}
	}

	/* return the current value of the field */
	lua_getfield(L, -1, field->name);
	return 1;
}


/**
 * Sets a string field to the value on the bottom of the Lua stack.
 * \returns OKAY if successful.
 */
int fn_accessor_set_string_value(lua_State* L, struct FieldInfo* field)
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
 * Appends the value or list at the bottom of the Lua stack to the specified list field.
 * \returns OKAY if successful.
 */
int fn_accessor_set_list_value(lua_State* L, struct FieldInfo* field)
{
	/* get the current value of the field */
	lua_getfield(L, -1, field->name);
	
	/* move the values into the field */
	fn_accessor_append_value(L, field, lua_gettop(L), 1);

	/* remove the field value from the stack */
	lua_pop(L, 1);
	return OKAY;
}


/**
 * Append a value to table. If the value is itself a table, it is "flattened" into the
 * destination table by iterating over each of its items and adding each in turn to the
 * target table.
 * \param   L      The current Lua state.
 * \param   field  A description of the field being populated.
 * \param   tbl    The table to contain the values.
 * \param   idx    The value to add to the table.
 */
static void fn_accessor_append_value(lua_State* L, struct FieldInfo* field, int tbl, int idx)
{
	int i, n;

	/* if the value to be appended is a table, expand it and insert each item individually */
	if (lua_istable(L, idx))
	{
		n = luaL_getn(L, idx);
		for (i = 1; i <= n; ++i)
		{
			lua_rawgeti(L, idx, i);
			fn_accessor_append_value(L, field, tbl, lua_gettop(L));
			lua_pop(L, 1);
		}
	}
	else
	{
		/* if this field contains files, check for and expand wildcards by calling match() */
		const char* value = lua_tostring(L, idx);
		if (field->kind == FilesField && cstr_contains(value, "*"))
		{
			lua_getglobal(L, "match");
			lua_pushvalue(L, idx);
			lua_call(L, 1, 1);
			fn_accessor_append_value(L, field, tbl, lua_gettop(L));
			lua_pop(L, 1);
		}
		else
		{
			lua_pushvalue(L, idx);
			n = luaL_getn(L, tbl);
			lua_rawseti(L, tbl, n + 1);
		}
	}
}
