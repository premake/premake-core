/**
 * \file   premake.c
 * \brief  Program entry point.
 * \author Copyright (c) 2002-2015 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "premake.h"

#if PLATFORM_MACOSX
#include <CoreFoundation/CFBundle.h>
#endif

#if PLATFORM_BSD
#include <sys/types.h>
#include <sys/sysctl.h>
#endif

#define ERROR_MESSAGE  "Error: %s\n"


static void build_premake_path(lua_State* L);
static int process_arguments(lua_State* L, int argc, const char** argv);
static int run_premake_main(lua_State* L, const char* script);


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
	{ "wildcards", path_wildcards },
	{ NULL, NULL }
};

static const luaL_Reg os_functions[] = {
	{ "chdir",                  os_chdir                },
	{ "chmod",                  os_chmod                },
	{ "comparefiles",           os_comparefiles         },
	{ "copyfile",               os_copyfile             },
	{ "_is64bit",               os_is64bit              },
	{ "isdir",                  os_isdir                },
	{ "getcwd",                 os_getcwd               },
	{ "getpass",                os_getpass              },
	{ "getWindowsRegistry",     os_getWindowsRegistry   },
	{ "getversion",             os_getversion           },
	{ "host",                   os_host                 },
	{ "isfile",                 os_isfile               },
	{ "islink",                 os_islink               },
	{ "locate",                 os_locate               },
	{ "matchdone",              os_matchdone            },
	{ "matchisfile",            os_matchisfile          },
	{ "matchname",              os_matchname            },
	{ "matchnext",              os_matchnext            },
	{ "matchstart",             os_matchstart           },
	{ "mkdir",                  os_mkdir                },
#if PLATFORM_WINDOWS
	// utf8 functions for Windows (assuming posix already handle utf8)
	{"remove",                  os_remove               },
	{"rename",                  os_rename               },
#endif
	{ "pathsearch",             os_pathsearch           },
	{ "realpath",               os_realpath             },
	{ "rmdir",                  os_rmdir                },
	{ "stat",                   os_stat                 },
	{ "uuid",                   os_uuid                 },
	{ "writefile_ifnotequal",   os_writefile_ifnotequal },
	{ "compile",                os_compile              },
	{ NULL, NULL }
};

static const luaL_Reg string_functions[] = {
	{ "endswith",  string_endswith },
	{ "hash", string_hash },
	{ "sha1", string_sha1 },
	{ "startswith", string_startswith },
	{ NULL, NULL }
};

static const luaL_Reg buffered_functions[] = {
	{ "new", buffered_new },
	{ "write", buffered_write },
	{ "writeln", buffered_writeln },
	{ "tostring", buffered_tostring },
	{ "close", buffered_close },
	{ NULL, NULL }
};

static const luaL_Reg term_functions[] = {
	{ "getTextColor",  term_getTextColor },
	{ "setTextColor",  term_setTextColor },
	{ NULL, NULL }
};

#ifdef PREMAKE_CURL
static const luaL_Reg http_functions[] = {
	{ "get",       http_get },
	{ "post",      http_post },
	{ "download",  http_download },
	{ NULL, NULL }
};
#endif

#ifdef PREMAKE_COMPRESSION
static const luaL_Reg zip_functions[] = {
	{ "extract",  zip_extract },
	{ NULL, NULL }
};
#endif

/**
 * Initialize the Premake Lua environment.
 */
int premake_init(lua_State* L)
{
	const char* value;

	luaL_register(L, "criteria", criteria_functions);
	luaL_register(L, "debug",    debug_functions);
	luaL_register(L, "path",     path_functions);
	luaL_register(L, "os",       os_functions);
	luaL_register(L, "string",   string_functions);
	luaL_register(L, "buffered", buffered_functions);
	luaL_register(L, "term",     term_functions);

#ifdef PREMAKE_CURL
	luaL_register(L, "http",     http_functions);
#endif

#ifdef PREMAKE_COMPRESSION
	luaL_register(L, "zip",     zip_functions);
#endif

	/* push the application metadata */
	lua_pushstring(L, LUA_COPYRIGHT);
	lua_setglobal(L, "_COPYRIGHT");

	lua_pushstring(L, PREMAKE_VERSION);
	lua_setglobal(L, "_PREMAKE_VERSION");

	lua_pushstring(L, PREMAKE_COPYRIGHT);
	lua_setglobal(L, "_PREMAKE_COPYRIGHT");

	lua_pushstring(L, PREMAKE_PROJECT_URL);
	lua_setglobal(L, "_PREMAKE_URL");

	/* set the OS platform variable */
	lua_pushstring(L, PLATFORM_STRING);
	lua_setglobal(L, "_TARGET_OS");

	/* find the user's home directory */
	value = getenv("HOME");
	if (!value) value = getenv("USERPROFILE");
	if (!value) value = "~";
	lua_pushstring(L, value);
	lua_setglobal(L, "_USER_HOME_DIR");

	/* publish the initial working directory */
	os_getcwd(L);
	lua_setglobal(L, "_WORKING_DIR");

	/* start the premake namespace */
	lua_newtable(L);
	lua_setglobal(L, "premake");

	return OKAY;
}



int premake_execute(lua_State* L, int argc, const char** argv, const char* script)
{
	int iErrFunc;

	/* push the absolute path to the Premake executable */
	lua_pushcfunction(L, path_getabsolute);
	premake_locate_executable(L, argv[0]);
	lua_call(L, 1, 1);
	lua_setglobal(L, "_PREMAKE_COMMAND");

	/* Parse the command line arguments */
	if (process_arguments(L, argc, argv) != OKAY) {
		return !OKAY;
	}

	/* Use --scripts and PREMAKE_PATH to populate premake.path */
	build_premake_path(L);

	/* Find and run the main Premake bootstrapping script */
	if (run_premake_main(L, script) != OKAY) {
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
int premake_locate_executable(lua_State* L, const char* argv0)
{
	char buffer[PATH_MAX];
	const char* path = NULL;

#if PLATFORM_WINDOWS
	wchar_t widebuffer[PATH_MAX];

	DWORD len = GetModuleFileNameW(NULL, widebuffer, PATH_MAX);
	if (len > 0)
	{
		WideCharToMultiByte(CP_UTF8, 0, widebuffer, len, buffer, PATH_MAX, NULL, NULL);

		buffer[len] = 0;
		path = buffer;
	}
#endif

#if PLATFORM_MACOSX
	CFURLRef bundleURL = CFBundleCopyExecutableURL(CFBundleGetMainBundle());
	CFStringRef pathRef = CFURLCopyFileSystemPath(bundleURL, kCFURLPOSIXPathStyle);
	if (CFStringGetCString(pathRef, buffer, PATH_MAX - 1, kCFStringEncodingUTF8))
		path = buffer;
#endif

#if PLATFORM_LINUX
	int len = readlink("/proc/self/exe", buffer, PATH_MAX - 1);
	if (len > 0)
	{
		buffer[len] = 0;
		path = buffer;
	}
#endif

#if PLATFORM_BSD
	int len = readlink("/proc/curproc/file", buffer, PATH_MAX - 1);
	if (len < 0)
		len = readlink("/proc/curproc/exe", buffer, PATH_MAX - 1);
	if (len < 0)
	{
		int mib[4];
		mib[0] = CTL_KERN;
		mib[1] = KERN_PROC;
		mib[2] = KERN_PROC_PATHNAME;
		mib[3] = -1;
		size_t cb = sizeof(buffer);
		sysctl(mib, 4, buffer, &cb, NULL, 0);
		len = (int)cb;
	}
	if (len > 0)
	{
		buffer[len] = 0;
		path = buffer;
	}
#endif

#if PLATFORM_SOLARIS
	int len = readlink("/proc/self/path/a.out", buffer, PATH_MAX - 1);
	if (len > 0)
	{
		buffer[len] = 0;
		path = buffer;
	}
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
 * Checks one or more of the standard script search locations to locate the
 * specified file. If found, returns the discovered path to the script on
 * the top of the Lua stack.
 */
int premake_test_file(lua_State* L, const char* filename, int searchMask)
{
	if (searchMask & TEST_LOCAL) {
		if (do_isfile(L, filename)) {
			lua_pushcfunction(L, path_getabsolute);
			lua_pushstring(L, filename);
			lua_call(L, 1, 1);
			return OKAY;
		}
	}

	if (scripts_path && (searchMask & TEST_SCRIPTS)) {
		if (do_locate(L, filename, scripts_path)) return OKAY;
	}

	if (searchMask & TEST_PATH) {
		const char* path = getenv("PREMAKE_PATH");
		if (path && do_locate(L, filename, path)) return OKAY;
	}

	#if !defined(PREMAKE_NO_BUILTIN_SCRIPTS)
	if ((searchMask & TEST_EMBEDDED) != 0) {
		/* Try to locate a record matching the filename */
		if (premake_find_embedded_script(filename) != NULL) {
			lua_pushstring(L, "$/");
			lua_pushstring(L, filename);
			lua_concat(L, 2);
			return OKAY;
		}
	}
	#endif

	return !OKAY;
}



static const char* set_scripts_path(const char* relativePath)
{
	char* path = (char*)malloc(PATH_MAX);
	do_getabsolute(path, relativePath, NULL);
	scripts_path = path;
	return scripts_path;
}



/**
 * Set the premake.path variable, pulling from the --scripts argument
 * and PREMAKE_PATH environment variable if present.
 */
static void build_premake_path(lua_State* L)
{
	int top;
	const char* value;

	lua_getglobal(L, "premake");
	top = lua_gettop(L);

	/* Start by searching the current working directory */
	lua_pushstring(L, ".");

	/* The --scripts argument goes next, if present */
	if (scripts_path) {
		lua_pushstring(L, ";");
		lua_pushstring(L, scripts_path);
	}

	/* Then the PREMAKE_PATH environment variable */
	value = getenv("PREMAKE_PATH");
	if (value) {
		lua_pushstring(L, ";");
		lua_pushstring(L, value);
	}

	/* Then in ~/.premake */
	lua_pushstring(L, ";");
	lua_getglobal(L, "_USER_HOME_DIR");
	lua_pushstring(L, "/.premake");

	/* In the user's Application Support folder */
#if defined(PLATFORM_MACOSX)
	lua_pushstring(L, ";");
	lua_getglobal(L, "_USER_HOME_DIR");
	lua_pushstring(L, "/Library/Application Support/Premake");
#endif

	/* In the /usr tree */
	lua_pushstring(L, ";/usr/local/share/premake;/usr/share/premake");

	/* Put it all together */
	lua_concat(L, lua_gettop(L) - top);

	/* Match Lua's package.path; use semicolon separators */
#if !defined(PLATFORM_WINDOWS)
	lua_getglobal(L, "string");
	lua_getfield(L, -1, "gsub");
	lua_pushvalue(L, -3);
	lua_pushstring(L, ":");
	lua_pushstring(L, ";");
	lua_call(L, 3, 1);
	/* remove the string global table */
	lua_remove(L, -2);
	/* remove the previously concatonated result */
	lua_remove(L, -2);
#endif

	/* Store it in premake.path */
	lua_setfield(L, -2, "path");

	/* Remove the premake namespace table */
	lua_pop(L, 1);
}



/**
 * Copy all command line arguments into the script-side _ARGV global, and
 * check for the presence of a /scripts=<path> argument to help locate
 * the manifest if needed.
 * \returns OKAY if successful.
 */
static int process_arguments(lua_State* L, int argc, const char** argv)
{
	int i;

	/* Copy all arguments in the _ARGV global */
	lua_newtable(L);
	for (i = 1; i < argc; ++i)
	{
		lua_pushstring(L, argv[i]);
		lua_rawseti(L, -2, lua_objlen(L, -2) + 1);

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
 * Find and run the main Premake bootstrapping script. The loading of the
 * bootstrap and the other core scripts use a limited set of search paths
 * to avoid mismatches between the native host code and the scripts
 * themselves.
 */
static int run_premake_main(lua_State* L, const char* script)
{
	/* Release builds want to load the embedded scripts, with --scripts
	 * argument allowed as an override. Debug builds will look at the
	 * local file system first, then fall back to embedded. */
#if defined(NDEBUG)
	int z = premake_test_file(L, script,
		TEST_SCRIPTS | TEST_EMBEDDED);
#else
	int z = premake_test_file(L, script,
		TEST_LOCAL | TEST_SCRIPTS | TEST_PATH | TEST_EMBEDDED);
#endif

	/* If no embedded script can be found, release builds will then
	 * try to fall back to the local file system, just in case */
#if defined(NDEBUG)
	if (z != OKAY) {
		z = premake_test_file(L, script, TEST_LOCAL | TEST_PATH);
	}
#endif

	if (z == OKAY) {
		z = luaL_dofile(L, lua_tostring(L, -1));
	}
	return z;
}



/**
 * Locate a file in the embedded script index. If found, returns the
 * contents of the file's script.
 */

const buildin_mapping* premake_find_embedded_script(const char* filename)
{
#if !defined(PREMAKE_NO_BUILTIN_SCRIPTS)
	int i;
	for (i = 0; builtin_scripts[i].name != NULL; ++i) {
		if (strcmp(builtin_scripts[i].name, filename) == 0) {
			return builtin_scripts + i;
		}
	}
#endif
	return NULL;
}



/**
 * Load a script that was previously embedded into the executable. If
 * successful, a function containing the new script chunk is pushed to
 * the stack, just like luaL_loadfile would do had the chunk been loaded
 * from a file.
 */

int premake_load_embedded_script(lua_State* L, const char* filename)
{
#if !defined(NDEBUG)
	static int warned = 0;
#endif

	const buildin_mapping* chunk = premake_find_embedded_script(filename);
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
	return luaL_loadbuffer(L, (const char*)chunk->bytecode, chunk->length, filename);
}
