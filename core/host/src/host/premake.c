#include "../premake_internal.h"
#include <string.h>

#define PREMAKE_MAIN_SCRIPT_PATH   "core/host/src/_premake_main.lua"
#define PREMAKE_MAIN_ENTRY_NAME    "_premake_main"

static int  getCurrentScriptDir(lua_State* L);
static const char* getScriptsPath(int argc, const char** argv);
static void installModuleLoader(lua_State* L);
static void registerGlobalLibrary(lua_State* L, const char* name, const luaL_Reg* functions);
static void registerInternalLibrary(lua_State* L, const char* name, const luaL_Reg* functions);
static void reportScriptError(pmk_State* P);
static void setArgsGlobal(lua_State* L, int argc, const char** argv);
static void setCommandGlobals(lua_State* L, const char* argv0);
static void setSearchPath(lua_State* L, int argc, const char** argv);


static const luaL_Reg g_functions[] = {
	{ "dofile", g_doFile },
	{ "doFile", g_doFile },
	{ "forceRequire", g_forceRequire },
	{ "loadfile", g_loadFile },
	{ "loadFile", g_loadFile },
	{ "loadFileOpt", g_loadFileOpt },
	{ NULL, NULL }
};

static const luaL_Reg buffer_functions[] = {
	{ "new", pmk_buffer_new },
	{ "close", pmk_buffer_close },
	{ "toString", pmk_buffer_toString },
	{ "write", pmk_buffer_write },
	{ "writeLine", pmk_buffer_writeLine },
	{ NULL, NULL }
};

static const luaL_Reg io_functions[] = {
	{ "compareFile", pmk_io_compareFile },
	{ "writeFile", pmk_io_writeFile },
	{ NULL, NULL }
};

static const luaL_Reg os_functions[] = {
	{ "chdir", pmk_os_chdir },
	{ "getCwd", pmk_os_getCwd },
	{ "isFile", pmk_os_isFile },
	{ "matchDone", pmk_os_matchDone },
	{ "matchName", pmk_os_matchName },
	{ "matchNext", pmk_os_matchNext },
	{ "matchStart", pmk_os_matchStart },
	{ "mkdir", pmk_os_mkdir },
	{ "touch", pmk_os_touch },
	{ "uuid", pmk_os_uuid },
	{ NULL, NULL }
};

static const luaL_Reg path_functions[] = {
	{ "getAbsolute", pmk_path_getAbsolute },
	{ "getBaseName", pmk_path_getBaseName },
	{ "getDirectory", pmk_path_getDirectory },
	{ "getKind", pmk_path_getKind },
	{ "getName", pmk_path_getName },
	{ "getRelative", pmk_path_getRelative },
	{ "getRelativeFile", pmk_path_getRelativeFile },
	{ "isAbsolute", pmk_path_isAbsolute },
	{ "join", pmk_path_join },
	{ "normalize", pmk_path_normalize },
	{ "translate", pmk_path_translate },
	{ NULL, NULL }
};

static const luaL_Reg premake_functions[] = {
	{ "locateModule", pmk_premake_locateModule },
	{ "locateScript", pmk_premake_locateScript },
	{ NULL, NULL }
};

static const luaL_Reg string_functions[] = {
	{ "contains", pmk_string_contains },
	{ "endsWith", pmk_string_endsWith },
	{ "join", pmk_string_join },
	{ "hash", pmk_string_hash },
	{ "patternFromWildcards", pmk_string_patternFromWildcards },
	{ "startsWith", pmk_string_startsWith },
	{ NULL, NULL }
};

static const luaL_Reg terminal_functions[] = {
	{ "textColor", pmk_terminal_textColor },
	{ NULL, NULL }
};

static const luaL_Reg xml_functions[] = {
	{ "escape", pmk_xml_escape },
	{ NULL, NULL }
};


pmk_State* pmk_init(pmk_ErrorHandler onError)
{
	lua_State* L = luaL_newstate();

	/* Set up a state object to keep track of things */
	pmk_State* pmk = (pmk_State*)malloc(sizeof(struct pmk_State));
	pmk->L = L;
	pmk->onError = onError;

	/* Find the user's home directory */
	const char* value = getenv("HOME");
	if (!value) value = getenv("USERPROFILE");
	if (!value) value = "~";
	lua_pushstring(L, value);
	lua_setglobal(L, "_USER_HOME_DIR");

	/* Create a "_PREMAKE" global to hold meta about the run */
	lua_newtable(L);
	lua_setglobal(L, "_PREMAKE");

	/* Add some metadata to the _PREMAKE global */
	lua_pushstring(L, LUA_COPYRIGHT);
	lua_setglobal(L, "_COPYRIGHT");

	/* Publish Premake's extensions to the standard libraries */
	luaL_openlibs(L);

	registerGlobalLibrary(L, "_G", g_functions);
	registerGlobalLibrary(L, "io", io_functions);
	registerGlobalLibrary(L, "os", os_functions);
	registerGlobalLibrary(L, "string", string_functions);

	registerInternalLibrary(L, "buffer", buffer_functions);
	registerInternalLibrary(L, "path", path_functions);
	registerInternalLibrary(L, "premake", premake_functions);
	registerInternalLibrary(L, "terminal", terminal_functions);
	registerInternalLibrary(L, "xml", xml_functions);

	/* Install Premake's module locator */
	installModuleLoader(L);

	return (pmk);
}


void pmk_close(pmk_State* P)
{
	lua_close(P->L);
	free(P);
}


int pmk_execute(pmk_State* P, int argc, const char** argv)
{
	lua_State* L = P->L;

	/* Copy command line arguments into _ARGS global */
	setArgsGlobal(L, argc, argv);

	/* Set _COMMAND and _COMMAND_DIR to the path to the executable */
	setCommandGlobals(L, argv[0]);

	/* Set up the script search path */
	setSearchPath(L, argc, argv);

	/* Run the entry point script */
	if (pmk_doFile(L, PREMAKE_MAIN_SCRIPT_PATH) != OKAY) {
		reportScriptError(P);
		return (!OKAY);
	}

	/* Initialization is complete; call the main entry point */
	lua_getglobal(L, PREMAKE_MAIN_ENTRY_NAME);
	if (pmk_pcall(L, 0, 1) != OKAY) {
		reportScriptError(P);
		return (!OKAY);
	} else {
		int exitCode = (int)lua_tonumber(P->L, -1);
		return (exitCode);
	}
}


lua_State* pmk_luaState(pmk_State* P)
{
	return (P->L);
}


/**
 * Adds functions to one of Lua's global libraries, e.g. `string`, `table`.
 */
static void registerGlobalLibrary(lua_State* L, const char* name, const luaL_Reg* functions)
{
	lua_getglobal(L, name);
	luaL_setfuncs(L, functions, 0);
	lua_pop(L, 1);
}


/**
 * Publishes the internally implemented part of one of the Premake modules, e.g.
 * `premake`, `path`. These are placed into the `_PREMAKE` global, where they are
 * later picked up by the scripted portion of the module.
 */
static void registerInternalLibrary(lua_State* L, const char* name, const luaL_Reg* functions)
{
	lua_getglobal(L, "_PREMAKE");
	lua_newtable(L);
	luaL_setfuncs(L, functions, 0);
	lua_setfield(L, -2, name);
	lua_pop(L, 1);
}


/**
 * Push all command line arguments into _ARGS global.
 */
static void setArgsGlobal(lua_State* L, int argc, const char** argv)
{
	lua_newtable(L);

	for (int i = 0; i < argc; ++i) {
		lua_pushstring(L, argv[i]);
		lua_rawseti(L, -2, i);
	}

	lua_setglobal(L, "_ARGS");
}


/**
 * Set the _PREMAKE.COMMAND and _PREMAKE.COMMAND_DIR globals.
 */
static void setCommandGlobals(lua_State* L, const char* argv0)
{
	char buffer[PATH_MAX];

	lua_getglobal(L, "_PREMAKE");

	pmk_locateExecutable(buffer, argv0);
	lua_pushstring(L, buffer);
	lua_setfield(L, -2, "COMMAND");

	pmk_getDirectory(buffer, buffer);
	lua_pushstring(L, buffer);
	lua_setfield(L, -2, "COMMAND_DIR");

	lua_pop(L, 1);
}


/**
 * Initializes the _PREMAKE.PATH search path use to locate scripts. This
 * needs to be done in the host to help it find the entry point script.
 */
static void setSearchPath(lua_State* L, int argc, const char** argv)
{
	int n = 0;

	lua_getglobal(L, "_PREMAKE");
	lua_newtable(L);

	/* a function returning current value of _SCRIPT_DIR; enables script-relative paths */
	lua_pushcfunction(L, getCurrentScriptDir);
	lua_rawseti(L, -2, ++n);

	/* the path specified by --scripts, if present */
	const char* scripts = getScriptsPath(argc, argv);
	if (scripts != NULL) {
		lua_pushstring(L, scripts);
		lua_rawseti(L, -2, ++n);
	}

	/* TODO: if release build, look in embedded files */

	/* the current working directory */
	lua_pushstring(L, ".");
	lua_rawseti(L, -2, ++n);

	/* any locations specified on PREMAKE6_PATH */
	char* path = getenv("PREMAKE6_PATH");
	if (path != NULL) {
		const char* segment = strtok(path, ";");
		while (segment != NULL) {
			lua_pushstring(L, segment);
			lua_rawseti(L, -2, ++n);
			segment = strtok(NULL, ";");
		}
	}

	/* the user's ~/.premake folder */
	lua_getglobal(L, "_USER_HOME_DIR");
	lua_pushstring(L, "/.premake");
	lua_concat(L, 2);
	lua_rawseti(L, -2, ++n);

	/* the user's Application Support folder */
#if PLATFORM_MACOSX
	lua_getglobal(L, "_USER_HOME_DIR");
	lua_pushstring(L, "/Library/Application Support/Premake");
	lua_concat(L, 2);
	lua_rawseti(L, -2, ++n);
#endif

	/* system and user "share" folders */
#if PLATFORM_POSIX
	lua_pushstring(L, "/usr/local/share/premake");
	lua_rawseti(L, -2, ++n);

	lua_pushstring(L, "/usr/share/premake");
	lua_rawseti(L, -2, ++n);
#endif

	/* the directory containing the Premake executable */
	lua_getglobal(L, "_PREMAKE");
	lua_getfield(L, -1, "COMMAND_DIR");
	lua_rawseti(L, -3, ++n);
	lua_pop(L, 1);

	lua_setfield(L, -2, "PATH");
	lua_pop(L, 1);
}


static const char* getScriptsPath(int argc, const char** argv)
{
	for (int i = 0; i < argc; ++i)
	{
		const char* arg = argv[i];

		if (strcmp("--scripts", arg) == 0) {
			return (argv[i + 1]);
		}

		if (strncmp("--scripts=", arg, 10) == 0) {
			const char* splitAt = strchr(arg, '=');
			return (splitAt + 1);
		}
	}

	return (NULL);
}


/**
 * Retrieve the current value of the _SCRIPT_DIR global and return it on
 * the stack. This is placed early in the script search path and allows for
 * loading things relative to the currently running script.
 */
static int getCurrentScriptDir(lua_State* L)
{
	lua_getglobal(L, "_SCRIPT_DIR");
	return (1);
}


/**
 * Install a new module "searcher" that knows how to use Premake's search
 * paths and loaders.
 */
static void installModuleLoader(lua_State* L)
{
	/* get the `package.searchers` table */
	lua_getglobal(L, "package");
	lua_getfield(L, -1, "searchers");

	/* insert our custom searcher at the first position */
	lua_getglobal(L, "table");
	lua_getfield(L, -1, "insert");
	lua_pushvalue(L, -3);
	lua_pushinteger(L, 1);
	lua_pushcfunction(L, pmk_moduleLoader);
	lua_call(L, 3, 0);

	lua_pop(L, 3);
}


/**
 * Called when a fatal error occurs in a script. Collects information
 * about the error and reports it to the host to handle.
 */
static void reportScriptError(pmk_State* P)
{
	const char* message;
	const char* traceback;

	lua_State* L = P->L;

	if (lua_istable(L, -1)) {
		/* received a { message, traceback } pair from onRuntimeError() */
		lua_getfield(L, -1, "message");
		lua_getfield(L, -2, "traceback");
		message = lua_tostring(L, -2);
		traceback = lua_tostring(L, -1);
		lua_pop(L, 2);
	} else {
		/* received a simple syntax error message */
		message = lua_tostring(L, -1);
		traceback = NULL;
	}

	if (P->onError != NULL) {
		P->onError(message, traceback);
	}
}
