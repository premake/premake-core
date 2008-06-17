/**
 * \file   fn_dofile.c
 * \brief  A custom implementation of dofile().
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include "premake.h"
#include "script_internal.h"
#include "base/dir.h"
#include "base/path.h"
#include "base/string.h"


/**
 * Replacement implementation for Lua's dofile() function; manages Premake specific
 * features like the _FILE variable, and makes sure the directory containing the
 * running script is kept current.
 */
int fn_dofile(lua_State* L)
{
	const char *filename;
	const char* full_path;
	const char* script_dir;
	String old_file;
	String old_working_dir;
	int top, result;

	filename = luaL_checkstring(L, 1);

	/* remember the previous file that was being run; will restore after script runs */
	lua_getglobal(L, FILE_KEY);
	old_file = string_create(lua_tostring(L, -1));
	lua_pop(L, 1);
	
	/* remember the current working directory; will restore after script runs */
	old_working_dir = string_create(dir_get_current());

	/* set the _FILE global to the full path of the script being run */
	full_path = path_absolute(filename);
	lua_pushstring(L, full_path);
	lua_setglobal(L, FILE_KEY);

	/* make the script directory the current directory */
	script_dir = path_directory(full_path);
	dir_set_current(script_dir);

	/* I'll need this to figure the number of return values later */
	top = lua_gettop(L);

	/* use absolute path to run script so full path will be shown in error messages */
	full_path = path_translate(full_path, NULL);
	result = luaL_loadfile(L, full_path);
	if (result == OKAY)
	{
		lua_call(L, 0, LUA_MULTRET);
	}

	/* restore the previous working directory */
	dir_set_current(string_cstr(old_working_dir));

	/* restore the previous file value */
	lua_pushstring(L, string_cstr(old_file));
	lua_setglobal(L, FILE_KEY);

	/* clean up */
	string_destroy(old_working_dir);
	string_destroy(old_file);

	if (result != OKAY)
	{
		lua_error(L);
	}

	/* return the number of values returned by the script */
	return lua_gettop(L) - top;
}
