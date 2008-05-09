/**
 * \file   script.c
 * \brief  The project scripting engine.
 * \author Copyright (c) 2008 Jason Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "premake.h"
#include "script_internal.h"
#include "base/cstr.h"
#include "base/error.h"


/** Functions to add to the global namespace */
static const luaL_Reg global_funcs[] = {
	{ "dofile",         fn_dofile },
	{ "include",        fn_include },
	{ "project",        fn_project },
	{ "solution",       fn_solution },
	{ NULL, NULL }
};

/** Functions to add to Lua's "os" namespace */
static const luaL_Reg os_funcs[] = {
	{ "getcwd",         fn_getcwd },
	{ NULL, NULL }
};


DEFINE_CLASS(Script)
{
	lua_State* L;
};


/**
 * Create a new instance of the project scripting engine.
 * \returns A new engine object, or NULL if an error occurred.
 */
Script script_create(void)
{
	Script script;

	/* create a new Lua scripting environment */
	lua_State* L = lua_open();
	if (L == NULL)
	{
		error_set("failed to start Lua scripting engine");
		return NULL;
	}

	/* register all the standard Lua libraries */
	luaL_openlibs(L);

	/* register the Premake non-configuration related functions */
	luaL_register(L, "_G", global_funcs);
	luaL_register(L, "os", os_funcs);

	/* create an empty list of solutions in the script environment */
	lua_newtable(L);
	lua_setglobal(L, SOLUTIONS_KEY);

	/* register the project object accessor functions */
	fn_accessor_register_all(L);

	script = ALLOC_CLASS(Script);
	script->L = L;
	return script;
}


/**
 * Destroy an instance of the project scripting engine, including any contained
 * scripting project objects.
 * \param   script   The script engine instance to destroy.
 */
void script_destroy(Script script)
{
	assert(script);
	lua_close(script->L);
	free(script);
}


/**
 * Get the current value of the _ACTION global variable.
 * \param   script   The project scripting engine instance.
 * \returns The action name if set, or NULL if not.
 */
const char* script_get_action(Script script)
{
	const char* result;
	assert(script);
	lua_getglobal(script->L, ACTION_KEY);
	result = lua_tostring(script->L, -1);
	lua_pop(script->L, 1);
	return result;
}


/**
 * Retrieve the Lua scripting environment object from the project scripting engine.
 * \param   script   The script engine instance.
 * \returns The Lua scripting environment associated with the script engine instance.
 */
lua_State* script_get_lua(Script script)
{
	assert(script);
	return script->L;
}


/**
 * Internal shared implementation for script_run_file() and script_run_string().
 * \param L        The Lua scripting environment.
 * \param param    The filename, or the code string, to be run.
 * \param is_file  True if param is a file, false if it is a code string.
 * \returns If the script returns a value, it is converted to a string and returned.
 *          If the script does not return a value, NULL is returned. If an error
 *          occurs in the script, the error message is returned.
 */
static const char* script_run(lua_State* L, const char* param, int is_file)
{
	const char* result;
	int top, status;

	/* set an error handler */
	lua_pushcfunction(L, fn_error);

	/* remember stack top, to figure out how many values were returned by the script */
	top = lua_gettop(L);

	if (is_file)
	{
		/* call Lua's dofile() function to do the work. I've implemented a
		 * custom version in fn_dofile.c; routing the call there keeps all
		 * of the logic in one place. */
		lua_getglobal(L, "dofile");
		lua_pushstring(L, param);
		status = lua_pcall(L, 1, LUA_MULTRET, -3);
	}
	else
	{
		status = luaL_loadstring(L, param);
		if (status == OKAY)
		{
			/* fake a file name for the _FILE global */
			lua_pushstring(L, "(string)/(string)");
			lua_setglobal(L, FILE_KEY);

			status = lua_pcall(L, 0, LUA_MULTRET, -2);
		}
	}

	if (status == OKAY)
	{
		/* if results were returned, pass them back to the caller */
		if (lua_gettop(L) > top)
		{
			if (lua_isboolean(L, top + 1))
			{
				int value = lua_toboolean(L, top + 1);
				result = (value) ? "true" : "false";
			}
			else
			{
				result = lua_tostring(L, top + 1);
			}
		}
		else
		{
			result = NULL;
		}
	}
	else
	{
		result = error_get();
	}

	return result;
}


/**
 * Execute a project script stored in a file.
 * \param   script    The project scripting engine instance.
 * \param   filename  The name of the file containing the script code to be executed.
 * \returns If the script returns a value, it is converted to a string and returned.
 *          If the script does not return a value, NULL is returned. If an error
 *          occurs in the script, the error message is returned.
 */
const char* script_run_file(Script script, const char* filename)
{
	assert(script);
	assert(filename);
	return script_run(script->L, filename, 1);
}


/**
 * Execute a project script stored in a string.
 * \param   script  The project scripting engine instance.
 * \param   code    The string containing the script code to be executed.
 * \returns If the script returns a value, it is converted to a string and returned.
 *          If the script does not return a value, NULL is returned. If an error
 *          occurs in the script, the error message is returned.
 */
const char* script_run_string(Script script, const char* code)
{
	const char* result;

	assert(script);
	assert(code);
	
	result = script_run(script->L, code, 0);

	/* if an error was returned, clean up the message to make it easier to test */
	if (cstr_starts_with(result, "[string "))
	{
		result = strstr(result, ":1:") + 4;
	}

	return result;
}


/**
 * Set the value of the _ACTION global variable.
 * \param   script  The project scripting engine instance.
 * \param   action  The name of the action to be performed.
 */
void script_set_action(Script script, const char* action)
{
	assert(script);
	lua_pushstring(script->L, action);
	lua_setglobal(script->L, ACTION_KEY);
}


/**
 * Copy project information out of the scripting environment and into C objects that
 * can be more easily manipulated by the action code.
 * \param   script  The project scripting engine instance.
 * \param   slns    An array to hold the list of unloaded solutions.
 * \returns OKAY if successful.
 */
int script_unload(Script script, Array slns)
{
	struct UnloadFuncs funcs;
	int result;

	assert(script);
	assert(slns);

	funcs.unload_solution = unload_solution;
	funcs.unload_project  = unload_project;
	result = unload_all(script->L, slns, &funcs);
	return result;
}


