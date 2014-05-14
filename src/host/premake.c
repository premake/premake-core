/**
 * \file   premake.c
 * \brief  Program entry point.
 * \author Copyright (c) 2002-2014 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "premake.h"

#if PLATFORM_MACOSX
#include <CoreFoundation/CFBundle.h>
#endif


#define VERSION        "HEAD"
#define COPYRIGHT      "Copyright (C) 2002-2014 Jason Perkins and the Premake Project"
#define PROJECT_URL    "https://bitbucket.org/premake/premake-dev/wiki"
#define ERROR_MESSAGE  "%s\n"


static int process_arguments(lua_State* L, int argc, const char** argv);
static int load_builtin_scripts(lua_State* L);

int premake_locate(lua_State* L, const char* argv0);


/* A search path for script files */
static const char* scripts_path = NULL;


/* precompiled bytecode buffer; in bytecode.c */
extern const char* builtin_scripts[];


/* Built-in functions */
static const luaL_Reg criteria_functions[] = {
	{ "_compile", criteria_compile },
	{ "_delete", criteria_delete },
	{ "matches", criteria_matches },
	{ NULL, NULL }
};

static const luaL_Reg debug_functions[] = {
	{ "prompt", debug_prompt },
	{ NULL, NULL }
};

static const luaL_Reg path_functions[] = {
	{ "getabsolute", path_getabsolute },
	{ "getrelative", path_getrelative },
	{ "isabsolute",  path_isabsolute },
	{ "join", path_join },
	{ "normalize", path_normalize },
	{ "translate", path_translate },
	{ NULL, NULL }
};

static const luaL_Reg os_functions[] = {
	{ "chdir",       os_chdir       },
	{ "chmod",       os_chmod       },
	{ "copyfile",    os_copyfile    },
	{ "_is64bit",    os_is64bit     },
	{ "isdir",       os_isdir       },
	{ "getcwd",      os_getcwd      },
	{ "getversion",  os_getversion  },
	{ "isfile",      os_isfile      },
	{ "matchdone",   os_matchdone   },
	{ "matchisfile", os_matchisfile },
	{ "matchname",   os_matchname   },
	{ "matchnext",   os_matchnext   },
	{ "matchstart",  os_matchstart  },
	{ "mkdir",       os_mkdir       },
	{ "pathsearch",  os_pathsearch  },
	{ "rmdir",       os_rmdir       },
	{ "stat",        os_stat        },
	{ "uuid",        os_uuid        },
	{ NULL, NULL }
};

static const luaL_Reg string_functions[] = {
	{ "endswith",  string_endswith },
	{ "hash", string_hash },
	{ "startswith", string_startswith },
	{ NULL, NULL }
};


/**
 * Initialize the Premake Lua environment.
 */
int premake_init(lua_State* L)
{
	luaL_register(L, "criteria", criteria_functions);
	luaL_register(L, "debug",    debug_functions);
	luaL_register(L, "path",     path_functions);
	luaL_register(L, "os",       os_functions);
	luaL_register(L, "string",   string_functions);

	/* push the application metadata */
	lua_pushstring(L, LUA_COPYRIGHT);
	lua_setglobal(L, "_COPYRIGHT");

	lua_pushstring(L, VERSION);
	lua_setglobal(L, "_PREMAKE_VERSION");

	lua_pushstring(L, COPYRIGHT);
	lua_setglobal(L, "_PREMAKE_COPYRIGHT");

	lua_pushstring(L, PROJECT_URL);
	lua_setglobal(L, "_PREMAKE_URL");

	/* set the OS platform variable */
	lua_pushstring(L, PLATFORM_STRING);
	lua_setglobal(L, "_OS");

	return OKAY;
}


int premake_execute(lua_State* L, int argc, const char** argv)
{
	int z;

	/* push the absolute path to the Premake executable */
	lua_pushcfunction(L, path_getabsolute);
	premake_locate(L, argv[0]);
	lua_call(L, 1, 1);
	lua_setglobal(L, "_PREMAKE_COMMAND");

	/* Parse the command line arguments */
	z = process_arguments(L, argc, argv);

	/* Run the built-in Premake scripts */
	if (z == OKAY)  z = load_builtin_scripts(L);

	return z;
}


/**
 * Locate the Premake executable, and push its full path to the Lua stack.
 * Based on:
 * http://sourceforge.net/tracker/index.php?func=detail&aid=3351583&group_id=71616&atid=531880
 * http://stackoverflow.com/questions/933850/how-to-find-the-location-of-the-executable-in-c
 * http://stackoverflow.com/questions/1023306/finding-current-executables-path-without-proc-self-exe
 */
int premake_locate(lua_State* L, const char* argv0)
{
#if !defined(PATH_MAX)
#define PATH_MAX  (4096)
#endif

	char buffer[PATH_MAX];
	const char* path = NULL;

#if PLATFORM_WINDOWS
	DWORD len = GetModuleFileName(NULL, buffer, PATH_MAX);
	if (len > 0)
		path = buffer;
#endif

#if PLATFORM_MACOSX
	CFURLRef bundleURL = CFBundleCopyExecutableURL(CFBundleGetMainBundle());
	CFStringRef pathRef = CFURLCopyFileSystemPath(bundleURL, kCFURLPOSIXPathStyle);
	if (CFStringGetCString(pathRef, buffer, PATH_MAX - 1, kCFStringEncodingUTF8))
		path = buffer;
#endif

#if PLATFORM_LINUX
	int len = readlink("/proc/self/exe", buffer, PATH_MAX);
	if (len > 0)
		path = buffer;
#endif

#if PLATFORM_BSD
	int len = readlink("/proc/curproc/file", buffer, PATH_MAX);
	if (len < 0)
		len = readlink("/proc/curproc/exe", buffer, PATH_MAX);
	if (len > 0)
		path = buffer;
#endif

#if PLATFORM_SOLARIS
	int len = readlink("/proc/self/path/a.out", buffer, PATH_MAX);
	if (len > 0)
		path = buffer;
#endif

	/* As a fallback, search the PATH with argv[0] */
	if (!path)
	{
		lua_pushcfunction(L, os_pathsearch);
		lua_pushstring(L, argv0);
		lua_pushstring(L, getenv("PATH"));
		if (lua_pcall(L, 2, 1, 0) == OKAY && !lua_isnil(L, -1))
		{
			lua_pushstring(L, "/");
			lua_pushstring(L, argv0);
			lua_concat(L, 3);
			path = lua_tostring(L, -1);
		}
	}

	/* If all else fails, use argv[0] as-is and hope for the best */
	if (!path)
	{
		/* make it absolute, if needed */
		os_getcwd(L);
		lua_pushstring(L, "/");
		lua_pushstring(L, argv0);

		if (!path_isabsolute(L)) {
			lua_concat(L, 3);
		}
		else {
			lua_pop(L, 1);
		}

		path = lua_tostring(L, -1);
	}

	lua_pushstring(L, path);
	return 1;
}



/**
 * Copy all command line arguments into the script-side _ARGV global, and
 * check for the presence of a /scripts=<path> argument to help locate
 * the manifest if needed.
 * \returns OKAY if successful.
 */
int process_arguments(lua_State* L, int argc, const char** argv)
{
	int i;

	/* Copy all arguments in the _ARGV global */
	lua_newtable(L);
	for (i = 1; i < argc; ++i)
	{
		lua_pushstring(L, argv[i]);
		lua_rawseti(L, -2, luaL_getn(L, -2) + 1);

		/* The /scripts option gets picked up here; used later to find the
		 * manifest and scripts later if necessary */
		if (strncmp(argv[i], "/scripts=", 9) == 0)
		{
			scripts_path = argv[i] + 9;
		}
		else if (strncmp(argv[i], "--scripts=", 10) == 0)
		{
			scripts_path = argv[i] + 10;
		}
	}
	lua_setglobal(L, "_ARGV");

	return OKAY;
}



#if !defined(NDEBUG)
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

	/* set the _SCRIPTS variable for the manifest, so it can locate everything */
	scripts_path = lua_tostring(L, -1);
	filename = lua_pushfstring(L, "%s/_manifest.lua", scripts_path);
	lua_pushvalue(L, -1);
	lua_setglobal(L, "_SCRIPT");

	/* load the manifest, which includes all the required scripts */
	if (luaL_dofile(L, filename))
	{
		printf(ERROR_MESSAGE, lua_tostring(L, -1));
		return !OKAY;
	}

	lua_pushnil(L);
	while (lua_next(L, -2))
	{
		filename = lua_pushfstring(L, "%s/%s", scripts_path, lua_tostring(L, -1));
		if (luaL_dofile(L, filename)) {
			printf(ERROR_MESSAGE, lua_tostring(L, -1));
			return !OKAY;
		}
		lua_pop(L, 2);
	}
	lua_pop(L, 1);

	/* run the bootstrapping script */
	filename = lua_pushfstring(L, "%s/_premake_main.lua", scripts_path);
	if (luaL_dofile(L, filename))
	{
		printf(ERROR_MESSAGE, lua_tostring(L, -1));
		return !OKAY;
	}

	/* in debug mode, show full traceback on all errors */
	lua_getglobal(L, "debug");
	lua_getfield(L, -1, "traceback");

	/* hand off control to the scripts */
	lua_getglobal(L, "_premake_main");
	if (lua_pcall(L, 0, 1, -2) != OKAY)
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
 * scripts, run `premake5 embed` then rebuild.
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
