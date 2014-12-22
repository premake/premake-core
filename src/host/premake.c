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
#define ERROR_MESSAGE  "Error: %s\n"


static int process_arguments(lua_State* L, int argc, const char** argv);


/* A search path for script files */
const char* scripts_path = NULL;


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
	{ "islink",      os_islink      },
	{ "locate",      os_locate      },
	{ "matchdone",   os_matchdone   },
	{ "matchisfile", os_matchisfile },
	{ "matchname",   os_matchname   },
	{ "matchnext",   os_matchnext   },
	{ "matchstart",  os_matchstart  },
	{ "mkdir",       os_mkdir       },
	{ "pathsearch",  os_pathsearch  },
	{ "realpath",    os_realpath    },
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

	/* publish the initial working directory */
	os_getcwd(L);
	lua_setglobal(L, "_WORKING_DIR");

	return OKAY;
}


int premake_execute(lua_State* L, int argc, const char** argv, const char* script)
{
	int iErrFunc;

	/* push the absolute path to the Premake executable */
	lua_pushcfunction(L, path_getabsolute);
	premake_locate(L, argv[0]);
	lua_call(L, 1, 1);
	lua_setglobal(L, "_PREMAKE_COMMAND");

	/* Parse the command line arguments */
	if (process_arguments(L, argc, argv) != OKAY) {
		return !OKAY;
	}

	/* load the main script */
	if (luaL_dofile(L, script) != OKAY) {
		printf(ERROR_MESSAGE, lua_tostring(L, -1));
		return !OKAY;
	}

	/* in debug mode, show full traceback on all errors */
#if defined(NDEBUG)
	iErrFunc = 0;
#else
	lua_getglobal(L, "debug");
	lua_getfield(L, -1, "traceback");
	iErrFunc = -2;
#endif

	/* and call the main entry point */
	lua_getglobal(L, "_premake_main");
	if (lua_pcall(L, 0, 1, iErrFunc) != OKAY) {
		printf(ERROR_MESSAGE, lua_tostring(L, -1));
		return !OKAY;
	}
	else {
		return (int)lua_tonumber(L, -1);
	}
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



const char* set_scripts_path(const char* relativePath)
{
	char* path = (char*)malloc(PATH_MAX);
	do_getabsolute(path, relativePath, NULL);
	scripts_path = path;
	return scripts_path;
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
			argv[i] = set_scripts_path(argv[i] + 9);
		}
		else if (strncmp(argv[i], "--scripts=", 10) == 0)
		{
			argv[i] = set_scripts_path(argv[i] + 10);
		}
	}
	lua_setglobal(L, "_ARGV");

	return OKAY;
}



/**
 * Load a script that was previously embedded into the executable. If
 * successful, a function containing the new script chunk is pushed to
 * the stack, just like luaL_loadfile would do had the chunk been loaded
 * from a file.
 */

int premake_load_embedded_script(lua_State* L, const char* filename)
{
	int i;
	const char* chunk = NULL;
#if !defined(NDEBUG)
	static int warned = 0;
#endif

	/* Try to locate a record matching the filename */
	for (i = 0; builtin_scripts_index[i] != NULL; ++i) {
		if (strcmp(builtin_scripts_index[i], filename) == 0) {
			chunk = builtin_scripts[i];
			break;
		}
	}

	if (chunk == NULL) {
		return !OKAY;
	}

	/* Debug builds probably want to be loading scripts from the disk */
#if !defined(NDEBUG)
	if (!warned) {
		warned = 1;
		printf("** warning: using embedded script '%s'; use /scripts argument to load from files\n", filename);
	}
#endif

	/* "Fully qualify" the filename by turning it into the form $/filename */
	lua_pushstring(L, "$/");
	lua_pushstring(L, filename);
	lua_concat(L, 2);

	/* Load the chunk */
	return luaL_loadbuffer(L, chunk, strlen(chunk), filename);
}
