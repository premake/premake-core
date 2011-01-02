/**
 * \file   premake.c
 * \brief  Program entry point.
 * \author Copyright (c) 2002-2011 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include <string.h>
#include "premake.h"


#define VERSION        "HEAD"
#define COPYRIGHT      "Copyright (C) 2002-2011 Jason Perkins and the Premake Project"
#define ERROR_MESSAGE  "%s\n"


static int process_arguments(lua_State* L, int argc, const char** argv);
static int process_option(lua_State* L, const char* arg);
static int load_builtin_scripts(lua_State* L);


/* A search path for script files */
static const char* scripts_path = NULL;


/* precompiled bytecode buffer; in bytecode.c */
extern const char* builtin_scripts[];


/* Built-in functions */
static const luaL_Reg path_functions[] = {
	{ "isabsolute",  path_isabsolute },
	{ NULL, NULL }
};

static const luaL_Reg os_functions[] = {
	{ "chdir",       os_chdir       },
	{ "copyfile",    os_copyfile    },
	{ "isdir",       os_isdir       },
	{ "getcwd",      os_getcwd      },
	{ "isfile",      os_isfile      },
	{ "matchdone",   os_matchdone   },
	{ "matchisfile", os_matchisfile },
	{ "matchname",   os_matchname   },
	{ "matchnext",   os_matchnext   },
	{ "matchstart",  os_matchstart  },
	{ "mkdir",       os_mkdir       },
	{ "pathsearch",  os_pathsearch  },
	{ "rmdir",       os_rmdir       },
	{ "uuid",        os_uuid        },
	{ NULL, NULL }
};

static const luaL_Reg string_functions[] = {
	{ "endswith",  string_endswith },
	{ NULL, NULL }
};



/**
 * Program entry point.
 */
int main(int argc, const char** argv)
{
	lua_State* L;
	int z = OKAY;

	/* prepare Lua for use */
	L = lua_open();
	luaL_openlibs(L);
	luaL_register(L, "path",   path_functions);
	luaL_register(L, "os",     os_functions);
	luaL_register(L, "string", string_functions);

	/* push the application metadata */
	lua_pushstring(L, LUA_COPYRIGHT);
	lua_setglobal(L, "_COPYRIGHT");

	lua_pushstring(L, VERSION);
	lua_setglobal(L, "_PREMAKE_VERSION");

	lua_pushstring(L, COPYRIGHT);
	lua_setglobal(L, "_PREMAKE_COPYRIGHT");

	/* set the OS platform variable */
	lua_pushstring(L, PLATFORM_STRING);
	lua_setglobal(L, "_OS");

	/* Parse the command line arguments */
	if (z == OKAY)  z = process_arguments(L, argc, argv);

	/* Run the built-in Premake scripts */
	if (z == OKAY)  z = load_builtin_scripts(L);

	/* Clean up and turn off the lights */
	lua_close(L);
	return z;
}



/**
 * Process the command line arguments, splitting them into options, the
 * target action, and any arguments to that action. The results are pushed
 * into the session for later use. I could have done this in the scripts,
 * but I need the value of the /scripts option to find them.
 * \returns OKAY if successful.
 */
int process_arguments(lua_State* L, int argc, const char** argv)
{
	int i;
	
	/* Create empty lists for Options and Args */
	lua_newtable(L);
	lua_newtable(L);

	for (i = 1; i < argc; ++i)
	{
		/* Options start with '/' or '--'. The first argument that isn't an option
		 * is the action. Anything after that is an argument to the action */
		if (argv[i][0] == '/')
		{
			process_option(L, argv[i] + 1);
		}
		else if (argv[i][0] == '-' && argv[i][1] == '-')
		{
			process_option(L, argv[i] + 2);
		}
		else
		{
			/* not an option, is the action */
			lua_pushstring(L, argv[i++]);
			lua_setglobal(L, "_ACTION");

			/* everything else is an argument */
			while (i < argc)
			{
				lua_pushstring(L, argv[i++]);
				lua_rawseti(L, -2, luaL_getn(L, -2) + 1);
			}
		}
	}

	/* push the Options and Args lists */
	lua_setglobal(L, "_ARGS");
	lua_setglobal(L, "_OPTIONS");
	return OKAY;
}



/**
 * Parse an individual command-line option.
 * \returns OKAY if successful.
 */
int process_option(lua_State* L, const char* arg)
{
	char key[512];
	const char* value;

	/* If a value is specified, split the option into a key/value pair */
	char* ptr = strchr(arg, '=');
	if (ptr)
	{
		int len = ptr - arg;
		if (len > 511) len = 511;
		strncpy(key, arg, len);
		key[len] = '\0';
		value = ptr + 1;
	}
	else
	{
		strcpy(key, arg);
		value = "";
	}

	/* Store it in the Options table, which is already on the stack */
	lua_pushstring(L, value);
	lua_setfield(L, -3, key);

	/* The /scripts option gets picked up here to find the built-in scripts */
	if (strcmp(key, "scripts") == 0 && strlen(value) > 0)
	{
		scripts_path = value;
	}

	return OKAY;
}



#if defined(_DEBUG)
/**
 * When running in debug mode, the scripts are loaded from the disk. The path to
 * the scripts must be provided via either the /scripts command line option or
 * the PREMAKE_PATH environment variable.
 */
int load_builtin_scripts(lua_State* L)
{
	const char* filename;
	
	/* call os.pathsearch() to locate _premake_main.lua */
	lua_pushcfunction(L, os_pathsearch);
	lua_pushstring(L, "_premake_main.lua");
	lua_pushstring(L, scripts_path);
	lua_pushstring(L, getenv("PREMAKE_PATH"));
	lua_call(L, 3, 1);

	if (lua_isnil(L, -1))
	{
		printf(ERROR_MESSAGE, 
			"Unable to find _premake_main.lua; use /scripts option when in debug mode!\n"
			"Please refer to the documentation (or build in release mode instead)."
		);
		return !OKAY;
	}

	/* run the bootstrapping script */
	scripts_path = lua_tostring(L, -1);
	filename = lua_pushfstring(L, "%s/_premake_main.lua", scripts_path);
	if (luaL_dofile(L, filename))
	{
		printf(ERROR_MESSAGE, lua_tostring(L, -1));
		return !OKAY;
	}

	/* hand off control to the scripts */
	lua_getglobal(L, "_premake_main");
	lua_pushstring(L, scripts_path);
	if (lua_pcall(L, 1, 1, 0) != OKAY)
	{
		printf(ERROR_MESSAGE, lua_tostring(L, -1));
		return !OKAY;
	}
	else
	{
		return (int)lua_tonumber(L, -1);
	}
}
#endif


#if defined(NDEBUG)
/**
 * When running in release mode, the scripts are loaded from a static data
 * buffer, where they were stored by a preprocess. To update these embedded
 * scripts, run `premake4 embed` then rebuild.
 */
int load_builtin_scripts(lua_State* L)
{
	int i;
	for (i = 0; builtin_scripts[i]; ++i)
	{
		if (luaL_dostring(L, builtin_scripts[i]) != OKAY)
		{
			printf(ERROR_MESSAGE, lua_tostring(L, -1));
			return !OKAY;
		}
	}

	/* hand off control to the scripts */
	lua_getglobal(L, "_premake_main");
	if (lua_pcall(L, 0, 1, 0) != OKAY)
	{
		printf(ERROR_MESSAGE, lua_tostring(L, -1));
		return !OKAY;
	}
	else
	{
		return (int)lua_tonumber(L, -1);
	}
}
#endif
