/**
 * \file   premake.c
 * \brief  Program entry point.
 * \author Copyright (c) 2002-2017 Jess Perkins and the Premake project
 */

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "premake.h"
#ifdef LUA_STATICLIB
#include "lua_shimtable.h"
#include "lauxlib.h"
#endif

#if PLATFORM_MACOSX
#include <CoreFoundation/CFBundle.h>
#endif

#if PLATFORM_BSD
#include <sys/types.h>
#include <sys/sysctl.h>
#endif

#define ERROR_MESSAGE  "Error: %s\n"


static void build_premake_path(lua_State* L);
static int process_arguments(lua_State* L, int argc, const TCHAR** argv);
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
	{ "deferredjoin", path_deferred_join },
	{ "hasdeferredjoin", path_has_deferred_join },
	{ "resolvedeferredjoin", path_resolve_deferred_join },
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
	{ "getnumcpus",             os_getnumcpus           },
	{ "getpass",                os_getpass              },
	{ "getWindowsRegistry",     os_getWindowsRegistry   },
	{ "listWindowsRegistry",    os_listWindowsRegistry  },
	{ "getversion",             os_getversion           },
	{ "host",                   os_host                 },
	{ "hostarch",               os_hostarch             },
	{ "isfile",                 os_isfile               },
	{ "islink",                 os_islink               },
	{ "linkdir",                os_linkdir              },
	{ "linkfile",               os_linkfile             },
	{ "locate",                 os_locate               },
	{ "matchdone",              os_matchdone            },
	{ "matchisfile",            os_matchisfile          },
	{ "matchname",              os_matchname            },
	{ "matchnext",              os_matchnext            },
	{ "matchstart",             os_matchstart           },
	{ "mkdir",                  os_mkdir                },
#if PLATFORM_WINDOWS
	// utf8 functions for Windows (assuming posix already handle utf8)
	{ "remove",                 os_remove               },
	{ "rename",                 os_rename               },
#endif
	{ "pathsearch",             os_pathsearch           },
	{ "realpath",               os_realpath             },
	{ "rmdir",                  os_rmdir                },
	{ "stat",                   os_stat                 },
	{ "uuid",                   os_uuid                 },
	{ "writefile_ifnotequal",   os_writefile_ifnotequal },
	{ "touchfile",              os_touchfile            },
#ifdef LUA_STATICLIB
	{ "compile",                os_compile              },
#endif
	{ NULL, NULL }
};

static const luaL_Reg premake_functions[] = {
	{ "getEmbeddedResource", premake_getEmbeddedResource },
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
	{ "list", zip_list},
	{ NULL, NULL }
};
#endif


static void lua_getorcreate_table(lua_State *L, const char *modname)
{
	luaL_getsubtable(L, LUA_REGISTRYINDEX, "_LOADED");      // get _LOADED table            stack = {_LOADED}
	lua_getfield(L, -1, modname);                           // get _LOADED[modname]         stack = { _LOADED, result }
	if (!lua_istable(L, -1))                                // not found?                   stack = { _LOADED, result }
	{
		lua_pop(L, 1);                                      // remove previous result       stack = { _LOADED }
		lua_pushglobaltable(L);                             // push _G onto stack           stack = { _LOADED, _G }
		lua_createtable(L, 0, 0);                           // new table for field          stack = { _LOADED, _G, result }
		lua_pushlstring(L, modname, strlen(modname));       //                              stack = { _LOADED, _G, result, modname }
		lua_pushvalue(L, -2);                               //                              stack = { _LOADED, _G, result, modname, result }
		lua_settable(L, -4);                                // _G[modname] = result         stack = { _LOADED, _G, result }
		lua_remove(L, -2);                                  // remove _G from stack         stack = { _LOADED, result }
		lua_pushvalue(L, -1);                               // duplicate result             stack = { _LOADED, result, result }
		lua_setfield(L, -3, modname);                       // _LOADED[modname] = result    stack = { _LOADED, result }
	}

	lua_remove(L, -2);                                      // remove _LOADED from stack    stack = { result }
}


void luaL_register(lua_State *L, const char *libname, const luaL_Reg *l)
{
	lua_getorcreate_table(L, libname);
	luaL_setfuncs(L, l, 0);
	lua_pop(L, 1);
}

static void set_home_dir(lua_State* L)
{
	const char *value = luaL_getenv(L, "HOME");
	if (!value) value = luaL_getenv(L, "USERPROFILE");
	if (!value) lua_pushstring(L, "~");
	lua_setglobal(L, "_USER_HOME_DIR");
}


/**
 * Initialize the Premake Lua environment.
 */
int premake_init(lua_State* L)
{
	// Replace Lua functions
	lua_pushcfunction(L, premake_luaB_loadfile);
	lua_setglobal(L, "loadfile");

	lua_pushcfunction(L, premake_luaB_dofile);
	lua_setglobal(L, "dofile");

	lua_getglobal(L, "package"); /* Load 'package' */
	lua_getfield(L, -1, "searchers"); /* Load 'package.searchers' */
	lua_pushinteger(L, 2); /* Prepare 'package.searchers[2]' for replacement */
	lua_pushvalue(L, -3);  /* set 'package' as upvalue for all searchers */
	lua_pushcclosure(L, premake_searcher_Lua, 1);
	lua_settable(L, -3);
	lua_pop(L, 2);

	luaL_register(L, "premake",  premake_functions);
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

#ifdef LUA_STATICLIB
	lua_pushlightuserdata(L, &s_shimTable);
	lua_rawseti(L, LUA_REGISTRYINDEX, 0x5348494D); // equal to 'SHIM'
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

	/* for Windows builds we require building with our own Lua for UTF-8 support */
#if !PLATFORM_WINDOWS || defined(LUA_STATICLIB)
	lua_pushboolean(L, TRUE);
	lua_setglobal(L, "_UTF8_ENABLED");
#endif

#if PLATFORM_COSMO
	/* set _COSMOPOLITAN if its a Cosmopolitan build */
	lua_pushboolean(L, TRUE);
	lua_setglobal(L, "_COSMOPOLITAN");
#endif

	/* find the user's home directory */
	set_home_dir(L);

	/* publish the initial working directory */
	os_getcwd(L);
	lua_setglobal(L, "_WORKING_DIR");

#if !defined(PREMAKE_NO_BUILTIN_SCRIPTS)
	/* let native modules initialize themselves */
	registerModules(L);
#endif

	return OKAY;
}


static void setErrorColor(lua_State* L)
{
	int errorColor = 12;

	lua_getglobal(L, "term");
	lua_pushstring(L, "errorColor");
	lua_gettable(L, -2);

	if (!lua_isnil(L, -1))
		errorColor = (int)luaL_checkinteger(L, -1);

	term_doSetTextColor(errorColor);

	lua_pop(L, 2);
}



void premake_handle_lua_error(lua_State* L)
{
	const char* message = lua_tostring(L, -1);
	int oldColor = term_doGetTextColor();
	setErrorColor(L);
	/* avoid printing a double Error: prefix for premake.error() messages */
	int has_error_prefix = strncmp(message, "** Error:", 9) == 0;
	printf(has_error_prefix ? "%s\n" : ERROR_MESSAGE, message);
	term_doSetTextColor(oldColor);
}

static int lua_error_handler(lua_State* L)
{
	// in debug mode, show full traceback on all errors
#if !defined(NDEBUG)
	lua_getglobal(L, "debug");
	lua_getfield(L, -1, "traceback");
	lua_remove(L, -2);     // remove debug table
	lua_insert(L, -2);     // insert traceback function before error message
	lua_pushinteger(L, 3); // push level
	lua_call(L, 2, 1);     // call traceback
#else
	(void) L;
#endif

	return 1;
}

int premake_pcall(lua_State* L, int nargs, int nresults)
{
	lua_pushcfunction(L, lua_error_handler);

	int error_handler_index = lua_gettop(L) - nargs - 1;
	lua_insert(L, error_handler_index); // insert lua_error_handler before call parameters
	int result = lua_pcall(L, nargs, nresults, error_handler_index);
	lua_remove(L, error_handler_index); // remove lua_error_handler from stack
	return result;
}

int premake_execute(lua_State* L, int argc, const TCHAR** argv, const char* script)
{
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
		premake_handle_lua_error(L);
		return !OKAY;
	}

	/* and call the main entry point */
	lua_getglobal(L, "_premake_main");
	if (premake_pcall(L, 0, 1) != OKAY) {
		premake_handle_lua_error(L);
		return !OKAY;
	}
	else {
		int exitCode = (int)lua_tonumber(L, -1);
		return exitCode;
	}
}



/**
 * Locate the Premake executable, and push its full path to the Lua stack.
 * Based on:
 * http://sourceforge.net/tracker/index.php?func=detail&aid=3351583&group_id=71616&atid=531880
 * http://stackoverflow.com/questions/933850/how-to-find-the-location-of-the-executable-in-c
 * http://stackoverflow.com/questions/1023306/finding-current-executables-path-without-proc-self-exe
 */
int premake_locate_executable(lua_State* L, const TCHAR* argv0)
{
	const char* path = NULL;
	const char *pargv0 = NULL;

#if PLATFORM_WINDOWS
	int argv0idx = lua_gettop(L) + 1;
	int filenameidx = lua_gettop(L) + 2;

	pargv0 = luaL_convertwstring(L, argv0, NULL);
	if (!pargv0)
	{
		argv0idx = 0;
		--filenameidx;
	}

	{
		wchar_t widebuffer[PATH_MAX + 1];
		DWORD len = GetModuleFileNameW(NULL, widebuffer, PATH_MAX + 1);
		if (len > 0 && len <= PATH_MAX)
		{
			path = luaL_convertwstring(L, widebuffer, NULL);
			if (!path) filenameidx = 0;
		}
	}
#else
	char buffer[PATH_MAX + 1];
	pargv0 = argv0;
#endif

#if PLATFORM_MACOSX
	CFURLRef bundleURL = CFBundleCopyExecutableURL(CFBundleGetMainBundle());
	CFStringRef pathRef = CFURLCopyFileSystemPath(bundleURL, kCFURLPOSIXPathStyle);
	if (CFStringGetCString(pathRef, buffer, PATH_MAX, kCFStringEncodingUTF8))
		path = buffer;
#endif

#if PLATFORM_LINUX
	int len = readlink("/proc/self/exe", buffer, PATH_MAX);
	if (len > 0)
	{
		buffer[len] = '\0';
		path = buffer;
	}
#endif

#if PLATFORM_BSD && !defined(__OpenBSD__)
	int len = readlink("/proc/curproc/file", buffer, PATH_MAX);
	if (len < 0)
		len = readlink("/proc/curproc/exe", buffer, PATH_MAX);
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
		buffer[len] = '\0';
		path = buffer;
	}
#endif

#if PLATFORM_SOLARIS
	int len = readlink("/proc/self/path/a.out", buffer, PATH_MAX);
	if (len > 0)
	{
		buffer[len] = '\0';
		path = buffer;
	}
#endif

	/* As a fallback, search the PATH with argv[0] */
	if (!path)
	{
		lua_pushcfunction(L, os_pathsearch);
		lua_pushstring(L, pargv0);
		if (!luaL_getenv(L, "PATH")) lua_pushnil(L);
		if (lua_pcall(L, 2, 1, 0) == OKAY && !lua_isnil(L, -1))
		{
			lua_pushstring(L, "/");
			lua_pushstring(L, pargv0);
			lua_concat(L, 3);
			path = lua_tostring(L, -1);
		}
		lua_pop(L, 1);
	}

	/* If all else fails, use argv[0] as-is and hope for the best */
	if (!path)
	{
		/* make it absolute, if needed */
		os_getcwd(L);
		lua_pushstring(L, "/");
		lua_pushstring(L, pargv0);

		if (!do_isabsolute(pargv0)) {
			lua_concat(L, 3);
		}
		else {
			lua_pop(L, 3);
			lua_pushstring(L, pargv0);
		}

		path = lua_tostring(L, -1);
		lua_pop(L, 1);
	}

	lua_pushstring(L, path);
#if PLATFORM_WINDOWS
	/* cleanup translation stack slots; note this must be in reverse order */
	if (filenameidx) lua_remove(L, filenameidx);
	if (argv0idx) lua_remove(L, argv0idx);
#endif
	return 1;
}



/**
 * Checks one or more of the standard script search locations to locate the
 * specified file. If found, returns the discovered path to the script on
 * the top of the Lua stack.
 */
int premake_locate_file(lua_State* L, const char* filename, int searchMask)
{
	if (searchMask & SEARCH_LOCAL) {
		if (do_isfile(L, filename)) {
			lua_pushcfunction(L, path_getabsolute);
			lua_pushstring(L, filename);
			lua_call(L, 1, 1);
			return OKAY;
		}
	}

	if (scripts_path && (searchMask & SEARCH_SCRIPTS)) {
		if (do_locate(L, filename, scripts_path)) return OKAY;
	}

	if (searchMask & SEARCH_PATH) {
		const char *path = luaL_getenv(L, "PREMAKE_PATH");
		if (path)
		{
			int idx = lua_gettop(L);
			int result = do_locate(L, filename, path);
			lua_remove(L, idx); /* remove env var from stack */
			if (result) return OKAY;
		}
	}

#if !defined(PREMAKE_NO_BUILTIN_SCRIPTS)
	if ((searchMask & SEARCH_EMBEDDED) != 0) {
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
	lua_pushstring(L, ";");
	if (luaL_getenv(L, "PREMAKE_PATH"))
		lua_pushstring(L, ";");  /* push another ';' for the next path */

	/* Then in ~/.premake */
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
static int process_arguments(lua_State* L, int argc, const TCHAR** argv)
{
	/* Copy all arguments in the _ARGV global */
	int table_idx = lua_gettop(L) + 1;
	lua_newtable(L);
	for (int i = 1; i < argc; ++i)
	{
#if PLATFORM_WINDOWS
		const char *parg = luaL_convertwstring(L, argv[i], NULL);
		if (!parg)
			parg = lua_pushstring(L, "<conversion error>");
		lua_pushvalue(L, -1); /* make a copy so `parg` can still be used */
#else
		const char *parg = argv[i];
		lua_pushstring(L, parg);
#endif
		lua_rawseti(L, table_idx, i);

		/* The /scripts option gets picked up here; used later to find the
		 * manifest and scripts later if necessary */
		if (strncmp(parg, "/scripts=", 9) == 0)
		{
			set_scripts_path(parg + 9);
		}
		else if (strncmp(parg, "--scripts=", 10) == 0)
		{
			set_scripts_path(parg + 10);
		}
#if PLATFORM_WINDOWS
		lua_pop(L, 1); /* pop the original converted parg string */
#endif
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
	int z = premake_locate_file(L, script,
		SEARCH_SCRIPTS | SEARCH_EMBEDDED);
#else
	int z = premake_locate_file(L, script,
		SEARCH_LOCAL | SEARCH_SCRIPTS | SEARCH_PATH | SEARCH_EMBEDDED);
#endif

	/* If no embedded script can be found, release builds will then
	 * try to fall back to the local file system, just in case */
#if defined(NDEBUG)
	if (z != OKAY) {
		z = premake_locate_file(L, script, SEARCH_LOCAL | SEARCH_PATH);
	}
#endif

	if (z == OKAY) {
		const char* filename = lua_tostring(L, -1);
		z = premake_luaL_dofile(L, filename);
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
		return LUA_ERRFILE;
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


/**
 * Give the lua runtime raw access to embedded files.
 */
int premake_getEmbeddedResource(lua_State* L)
{
	const char* filename = luaL_checkstring(L, 1);
	const buildin_mapping* chunk = premake_find_embedded_script(filename);
	if (chunk == NULL)
	{
		return 0;
	}

	lua_pushlstring(L, (const char*)chunk->bytecode, chunk->length);
	return 1;
}

#ifndef LUA_STATICLIB
// Functions added to our version of Lua in contrib/lua; need to reimplement when building against system Lua
// Copied from lauxlib.c in contrib/lua
const char *luaL_getenv(lua_State *L, const char *name)
{
#if PLATFORM_WINDOWS
	const wchar_t *wname = luaL_convertstring(L, name);
	const char *s;
	wchar_t *wvar;
	DWORD rc;
	luaL_Buffer wbuf;
	if (wname == NULL) return NULL;
	rc = GetEnvironmentVariableW(wname, NULL, 0);
	if (!rc) {
	  lua_pop(L, 1);
	  return NULL;
	}
	wvar = (wchar_t *)luaL_buffinitsize(L, &wbuf, rc * sizeof(wchar_t));
	GetEnvironmentVariableW(wname, wvar, rc);
	luaL_pushresultsize(&wbuf, rc * sizeof(wchar_t));
	wvar = (wchar_t *)lua_tostring(L, -1);
	s = luaL_convertlwstring(L, wvar, rc - 1, NULL);
	lua_remove(L, -2); /* remove the string from wbuf */
	lua_remove(L, -2); /* remove the string from wname */
	return s;
#else
	const char *value = getenv(name);
	if (!value) return NULL;
	lua_pushstring(L, value);
	return lua_tostring(L, -1);
#endif
}

#if PLATFORM_WINDOWS
typedef struct UWideString {
	size_t len;
	wchar_t s[1]; /* actual size is len + 1 */
} UWideString;
  
#define LUA_WIDESTRING "LUA_WIDESTRING"
  
static UWideString *newwidestr (lua_State *L, const wchar_t *s, size_t len) {
	UWideString *ws = (UWideString *)lua_newuserdata(L, sizeof(UWideString) + len * sizeof(wchar_t));
	luaL_newmetatable(L, LUA_WIDESTRING);
	lua_setmetatable(L, -2);
	if (s) memcpy(ws->s, s, len * sizeof(wchar_t));
	ws->s[len] = L'\0';
	ws->len = len;
	return ws;
}
  
const wchar_t *luaL_convertlstringi (lua_State *L, int idx, size_t *len)
{
	size_t nlen;
	const char *s = lua_tolstring(L, idx, &nlen);
	return luaL_convertlstring(L, s, nlen, len);
}
  
const char *luaL_convertlwstring (lua_State *L, const wchar_t *ws, size_t wlen, size_t *len)
{
	int size;
	luaL_Buffer buf;
	char *s;
	if (ws == NULL) {
	  if (len != NULL) *len = 0;
	  return NULL;
	}
	size = WideCharToMultiByte(CP_UTF8, 0, ws, wlen, NULL, 0, NULL, NULL);
	if (size == 0) { /* conversion failure */
	  if (len != NULL) *len = 0;
	  return NULL;
	}
	s = luaL_buffinitsize(L, &buf, size);
	WideCharToMultiByte(CP_UTF8, 0, ws, wlen, s, size, NULL, NULL);
	luaL_pushresultsize(&buf, size);
	if (len != NULL) *len = size;
	return lua_tostring(L, -1);
}
  
const wchar_t *luaL_convertlstring (lua_State *L, const char *s, size_t nlen, size_t *len)
{
	int size;
	UWideString *ws;
	if (s == NULL) {
	  if (len != NULL) *len = 0;
	  return NULL;
	}
	size = MultiByteToWideChar(CP_UTF8, 0, s, nlen, NULL, 0);
	if (size == 0) { /* conversion failure */
	  if (len != NULL) *len = 0;
	  return NULL;
	}
  
	ws = newwidestr(L, NULL, size);
	MultiByteToWideChar(CP_UTF8, 0, s, nlen, ws->s, size);
	if (len != NULL) *len = size;
	return ws->s;
}
  
const char *(luaL_convertwstring) (lua_State *L, const wchar_t *ws, size_t *len)
{
	int size, wlen;
	luaL_Buffer buf;
	char *s;
	if (ws == NULL) {
	  if (len != NULL) *len = 0;
	  return NULL;
	}
	wlen = wcslen(ws);
	size = WideCharToMultiByte(CP_UTF8, 0, ws, wlen, NULL, 0, NULL, NULL);
	if (size == 0) { /* conversion failure */
	  if (len != NULL) *len = 0;
	  return NULL;
	}
	s = luaL_buffinitsize(L, &buf, size);
	WideCharToMultiByte(CP_UTF8, 0, ws, wlen, s, size, NULL, NULL);
	luaL_pushresultsize(&buf, size);
	if (len != NULL) *len = size;
	return lua_tostring(L, -1);
}
  
const wchar_t *luaL_checkconvertlstring (lua_State *L, int idx, size_t *len)
{
	size_t nlen;
	const char *s = luaL_checklstring(L, idx, &nlen);
	const wchar_t *ws = luaL_convertlstring(L, s, nlen, len);
	if (ws == NULL) luaL_error(L, "conversion failure");
	return ws;
}
  
const wchar_t *luaL_optconvertlstring (lua_State *L, int idx, const wchar_t *def, size_t *len)
{
	if (lua_isnoneornil(L, idx)) {
	  if (len != NULL) *len = (def ? wcslen(def) : 0);
	  return def;
	}
	return luaL_checkconvertlstring(L, idx, len);
}
#endif /* PLATFORM_WINDOWS */
#endif /* LUA_STATICLIB */
